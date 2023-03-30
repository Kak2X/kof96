; 
; =============== START OF MODULE CharSel ===============
;
; =============== Module_CharSel ===============
; EntryPoint for character select screen.
Module_CharSel:
	ld   sp, $DD00
	di
	;-----------------------------------
	rst  $10				; Stop LCD
	ld   hl, wMisc_C028
	; No player sprites here
	res  MISCB_PL_RANGE_CHECK, [hl]
	
	; Reset palette as usual
	xor  a
	ldh  [rBGP], a
	ldh  [rOBP0], a
	ldh  [rOBP1], a
	
	; Apply SGB palette for characters
	ld   de, SCRPAL_CHARSELECT
	call HomeCall_SGB_ApplyScreenPalSet
	
	; Reset tilemaps
	call ClearBGMap
	call ClearWINDOWMap
	; Reset screen coords to top-left corner
	xor  a
	ldh  [hScrollX], a
	ldh  [hScrollY], a
	ld   [wOBJScrollX], a
	ld   [wOBJScrollY], a
	
	;
	; Copy graphics
	;
	
	; We're displaying character names here.
	; Only the letters, period and the dash are usable as everything
	; else gets overwritten.
	call LoadGFX_1bppFont_Default
	
	; This set of graphics is uncompressed, and is written over the 
	; Japanese font characters, leaving us with the ASCII ones.
	; Also note the numbers are overwritten with the small 16x16 icons on the fly.
	ld   hl, GFX_CharSel_BG0	; Player portraits
	ld   de, $92F0
	ld   b, $51
	call CopyTiles
	
	ld   hl, GFXLZ_CharSel_BG1	; Player tiles, icon placeholders
	ld   de, wLZSS_Buffer
	call DecompressLZSS
	ld   hl, wLZSS_Buffer
	ld   de, $8800
	ld   b, $78
	call CopyTiles
	
	ld   hl, GFXLZ_CharSel_OBJ	; All OBJ (cursors, tile flip anim)
	ld   de, wLZSS_Buffer
	call DecompressLZSS
	ld   hl, wLZSS_Buffer
	ld   de, Tiles_Begin		; At the start of the GFX area
	ld   b, $62
	call CopyTiles
	
	; Copy default values for CHARSEL_ID_* -> CHAR_ID_* mapping table.
	; These determine what character you get depending on the cursor's position,
	; and it can be updated when flipping tiles.
	ld   hl, wCharSelIdMapTbl 						; HL = Destination
	ld   de, CharSel_IdMapTbl						; DE = Source
	ld   b, CharSel_IdMapTbl.end-CharSel_IdMapTbl	; B = Bytes to copy
.idInitLoop:
	ld   a, [de]		
	ldi  [hl], a
	inc  de
	dec  b
	jp   nz, .idInitLoop
	
	
	; Init
	xor  a
	ld   [wCharSelTeamFull], a
	ld   [wCharSelP1CursorMode], a
	ld   [wCharSelP2CursorMode], a
	ld   [wCharSelCurPl], a
	ld   [wCharSelRandom1P], a
	ld   [wCharSelRandom2P], a
	
	; Set the delay timers used to ranzomize the cursor before picking the character.
	;
	; For both players, it may take anything between $07 and $26 frames
	; before the CPU picks the next character in the sequence:
	; Delay = (Rand & $1F) + 7
	;
	; See also: CharSel_SetRandomPortrait
	call Rand
	and  a, $1F
	add  a, $07
	ld   [wCharSelRandomDelay1P], a
	
	; wCharSelRandomDelay2P = (Rand & $1F) + 7
	call Rand
	and  a, $1F
	add  a, $07
	ld   [wCharSelRandomDelay2P], a
	
	;--
	;
	; In single modes, the CPU *opponent* (the inactive side) has the autopicker enabled
	; to have it automatically select the characters in the previously generated CPU sequence.
	;
	; This behaviour is toggled by wCharSelRandom1P and wCharSelRandom2P, and can be
	; also enabled by 1P/2P through a button combination (though it skips the sequence code and does set random characters)
	; 	
	

	ld   a, [wPlayMode]
	bit  MODEB_VS, a			; Is VS mode?
	jp   nz, .initVSMode		; If so, jump
	
.init1PMode:
	;
	; Check which player is the CPU opponent.
	; See also: CharSelect_IsCPUOpponent
	;
	ld   a, [wJoyActivePl]
	or   a						; Playing on the Pl1 side? (== PL1)
	jp   z, .cpu2P				; If so, jump
.cpu1P:
	; We're playing on the 2P side, and the CPU is 1P
	
	ld   a, $01							; 1P CPU autopicks team
	ld   [wCharSelRandom1P], a
	
	;
	; If the CPU lost, clear out its selected opponents.
	; Since wCharSelRandom1P is set, a new set of opponents will be quickly filled in (elsewhere).
	;
	ld   hl, wCharSelP1Char0			; HL = Team start
	ld   de, wCharSelP1CursorPos		; DE = Cursor position
	
	ld   a, [wLastWinner]		
	bit  PLB1, a						; Did the CPU win?
	jp   z, .clearCPUTeam				; If not, jump
	jp   .lost				
	
.cpu2P:
	; Same thing as above, except when playing as 1P
	
	ld   a, $01							; 2P CPU autopicks team
	ld   [wCharSelRandom2P], a
	
	ld   hl, wCharSelP2Char0			; HL = Cursor position
	ld   de, wCharSelP2CursorPos		; DE = Cursor position
	ld   a, [wLastWinner]
	bit  PLB2, a						; Did the other player win?
	jp   z, .clearCPUTeam				; If not, jump
	
.lost:
	; The player lost the previous match, so the CPU keeps its opponents.
	
	; Additionally, if we lost to a boss, we have to set their selected "team" manually.
	; This is because they go alone instead of being part of a team. 
	; If we didn't check this, the game would try to select three characters anyway.
	ld   a, [wCharSeqId]
	cp   STAGESEQ_KAGURA		; Did we lose to Kagura?
	jp   z, .lostOnBoss			; If so, jump
	cp   STAGESEQ_GOENITZ		; Did we lose to Goenitz?
	jp   z, .lostOnBoss			; If so, jump
	jp   .chkInitialMode
	
.lostOnBoss:
	
	; Retrieve the current wCharSeqTbl value.
	; The index is high enough that the value isn't stored as CHARSEL_ID_*, but directly as CHAR_ID_*.
	;                                                                    (see ModeSelect_MakeStageSeq)
	push hl
		ld   hl, wCharSeqTbl	; HL = Sequence table
		ld   b, $00				; BC = RoundId
		ld   c, a
		add  hl, bc				; Index the table
		ld   a, [hl]			; A = CPU character id
		
	; Set the boss as part of the team
	pop  hl				; HL = Ptr to start of CPU team
	ld   [de], a		; Whatever
	ldi  [hl], a		; 1st opponent: Boss
	ld   a, CHAR_ID_NONE
	ldi  [hl], a		; 2nd opponent: Nobody
	ld   [hl], a		; 3rd opponent: Nobody
	jp   .chkInitialMode
	
.clearCPUTeam:
	; The CPU lost.
	; Clear its three characters off the team.
	ld   a, CHAR_ID_NONE
	ldi  [hl], a
	ldi  [hl], a
	ld   [hl], a
	
	; Draw the cross over defeated characters.
	; This is specifically only done while the CPU picks a new set of characters,
	; presumably because it would be annoying having the crosses cover the portraits
	; when the player can select them.
	call CharSel_DrawCrossOnDefeatedChars
	jp   .chkInitialMode
	
.initVSMode:
	; In an endless CPU vs CPU battle, the game autopicks characters for both players.
	call CharSel_IsEndlessCpuVsCpu
	jp   nc, .chkInitialMode
	ld   a, $01						
	ld   [wCharSelRandom1P], a
	ld   [wCharSelRandom2P], a
	
.chkInitialMode:
	;
	; Determine which mode to start with.
	; If a player has at least the first character set when initializing
	; the char select screen, he's considered ready (cursor frozen, blinking START).
	;
	; This way it works universally for Single mode, Team mode and bosses.
	;
	ld   a, [wCharSelP1Char0]
	cp   CHAR_ID_NONE					; Is the first character empty?
	jp   z, chkInitialModeP2			; If so, skip
	ld   a, CHARSEL_MODE_READY			; Otherwise, skip to the next mode for P1
	ld   [wCharSelP1CursorMode], a
chkInitialModeP2:
	ld   a, [wCharSelP2Char0]			; Same as above, for P2
	cp   CHAR_ID_NONE
	jp   z, .drawBG
	ld   a, CHARSEL_MODE_READY
	ld   [wCharSelP2CursorMode], a
	
.drawBG:
	;
	; Draw the initial tilemap.
	;

	; Draw character portraits
	call CharSel_DrawUnlockedChars
	
	call IsInTeamMode		; Are we in Team mode?
	jp   c, .drawBG_Team	; If so, jump
;--
.drawBG_Single:

	ld   hl, TextDef_CharSel_SingleTitle
	call TextPrinter_Instant
	
	;
	; Draw the placeholders for the icons of selected characters at the bottom of the screen.
	; In single mode, draw one for each player.
	;
	
	; 1P side, leftmost
	ld   hl, BG_CHARSEL_P1ICON0		; Tilemap ptr
	ld   c, TILE_CHARSEL_ICONEMPTY1	; Initial tile ID
	call CharSel_DrawEmptyIcon
	; 2P side, rightmost
	ld   hl, BG_CHARSEL_P2ICON0		; Tilemap ptr
	ld   c, TILE_CHARSEL_ICONEMPTY1	; Initial tile ID
	call CharSel_DrawEmptyIcon
	
.singleChkIconP1:

	ld   a, [wCharSelP1Char0]
	cp   CHAR_ID_NONE			; Has P1 the first character selected?
	jp   z, .singleChkIconP2	; If not, skip
	
	; Otherwise, draw the character icon
	ld   de, $8F80					; Where to load GFX
	ld   hl, $99E2					; Top-right corner of icon in tilemap
	ld   c, TILE_CHARSEL_P1ICON0	; Starting tile ID 
	call CharSel_DrawP1CharIcon
	; And print its name
	ld   de, wOBJInfo_Pl1			; 1P side
	call CharSel_PrintCharName
	
.singleChkIconP2:
	ld   a, [wCharSelP2Char0]
	cp   CHAR_ID_NONE			; Has P2 the first character selected?
	jp   z, .initOBJ				; If not, skip
	
	; Otherwise, draw the character icon
	ld   de, $8FC0
	ld   hl, $99F1
	ld   c, TILE_CHARSEL_P2ICON0
	call CharSel_DrawP2CharIcon
	; And print its name
	ld   de, wOBJInfo_Pl2		;2P side
	call CharSel_PrintCharName
	jp   .initOBJ
;--
.drawBG_Team:
	ld   hl, TextDef_CharSel_TeamTitle
	call TextPrinter_Instant
	
	;
	; Draw the placeholders for the icons of selected characters at the bottom of the screen.
	; In team mode, draw either one or three icon slots for each player.
	;
	
.team1PDraw:
	;
	; 1P SIDE
	;
	
	; The first placeholder is always drawn
	ld   hl, BG_CHARSEL_P1ICON0	; 1P side, leftmost	
	ld   c, TILE_CHARSEL_ICONEMPTY1
	call CharSel_DrawEmptyIcon
	
	; Don't draw the two other placeholders if we're in a boss stage.
	; No "boss rounds" in VS mode
	ld   a, [wPlayMode]
	bit  MODEB_VS, a			; Playing in VS mode?
	jp   nz, .team1PDrawEmpty	; If so, jump
	; 2P should be the active player
	ld   a, [wJoyActivePl]
	or   a						; Are we playing on the 1P side? (wJoyActivePl == PL1)
	jp   z, .team1PDrawEmpty	; If so, jump
	
	; Stage sequence check
	ld   a, [wCharSeqId]
	cp   STAGESEQ_KAGURA		; Fighting Kagura next?
	jp   z, .team2PDraw			; If so, skip
	cp   STAGESEQ_GOENITZ		; Fighting Goenitz next?
	jp   z, .team2PDraw			; If so, skip
.team1PDrawEmpty:
	; Draw second and third placeholder
	ld   hl, BG_CHARSEL_P1ICON1
	ld   c, TILE_CHARSEL_ICONEMPTY2
	call CharSel_DrawEmptyIcon
	ld   hl, BG_CHARSEL_P1ICON2
	ld   c, TILE_CHARSEL_ICONEMPTY3
	call CharSel_DrawEmptyIcon
	
.team2PDraw:
	;
	; Do the same for the
	; 2P SIDE
	;
	
	; The first placeholder is always drawn
	ld   hl, BG_CHARSEL_P2ICON0	; 2P side, rightmost	
	ld   c, TILE_CHARSEL_ICONEMPTY1		
	call CharSel_DrawEmptyIcon
	
	; Don't draw the two other placeholders if we're in a boss stage.
	; No "boss rounds" in VS mode
	ld   a, [wPlayMode]
	bit  MODEB_VS, a			; Playing in VS mode?
	jp   nz, .team2PDrawEmpty	; If so, jump
	; 1P should be the active player
	ld   a, [wJoyActivePl]
	or   a						; Are we playing on the 1P side? (wJoyActivePl == PL1)
	jp   nz, .team2PDrawEmpty	; If *not*, jump
	
	; Stage sequence check
	ld   a, [wCharSeqId]
	cp   STAGESEQ_KAGURA		; Fighting Kagura next?
	jp   z, .fillSelChars1P		; If so, skip
	cp   STAGESEQ_GOENITZ		; Fighting Goenitz next?
	jp   z, .fillSelChars1P		; If so, skip
.team2PDrawEmpty:
	; Draw second and third placeholder
	ld   hl, BG_CHARSEL_P2ICON1
	ld   c, TILE_CHARSEL_ICONEMPTY2
	call CharSel_DrawEmptyIcon
	ld   hl, BG_CHARSEL_P2ICON2
	ld   c, TILE_CHARSEL_ICONEMPTY3
	call CharSel_DrawEmptyIcon
	
.fillSelChars1P:

	;
	; The placeholder numeric icons are written.
	; Now replace them, in order, with the icons of the actual selected characters.
	;
	; The character names are also written, with only the last one remaining
	; as they overwrite each other.
	;
	
	ld   a, [wCharSelP1Char0]
	cp   CHAR_ID_NONE				; Is there a character on the first slot?
	jp   z, .fillSelChars2P			; If not, skip
	
	; Because the player 1 icons are X flipped, the BG_CHARSEL_P1ICON* are offset by 1
	; to point to the top-right tile of the icon. See also: Char_DrawIconFlipX
	
	; Set the icon in slot 1
	ld   de, $8F80					; Where to load the GFX
	ld   hl, BG_CHARSEL_P1ICON0+1	; Top-right corner of icon in tilemap
	ld   c, TILE_CHARSEL_P1ICON0	; Tile ID of DE
	call CharSel_DrawP1CharIcon
	; Write the character name
	ld   de, wOBJInfo_Pl1			; P1 side
	call CharSel_PrintCharName
	
	; Player 1 - Icon 2
	ld   a, [wCharSelP1Char1]
	cp   CHAR_ID_NONE
	jp   z, .fillSelChars2P	
	ld   de, $91F0
	ld   hl, BG_CHARSEL_P1ICON1+1
	ld   c, TILE_CHARSEL_P1ICON1
	call CharSel_DrawP1CharIcon
	ld   de, wOBJInfo_Pl1
	call CharSel_PrintCharName
	
	; Player 1 - Icon 3
	ld   a, [wCharSelP1Char2]
	cp   CHAR_ID_NONE
	jp   z, .fillSelChars2P
	ld   de, $9230
	ld   hl, BG_CHARSEL_P1ICON2+1
	ld   c, TILE_CHARSEL_P1ICON2
	call CharSel_DrawP1CharIcon
	ld   de, wOBJInfo_Pl1
	call CharSel_PrintCharName
	
.fillSelChars2P:

	; Player 2 - Icon 1
	ld   a, [wCharSelP2Char0]
	cp   CHAR_ID_NONE
	jp   z, .initDefaultNames
	ld   de, $8FC0
	ld   hl, BG_CHARSEL_P2ICON0
	ld   c, $FC
	call CharSel_DrawP2CharIcon
	ld   de, wOBJInfo_Pl2
	call CharSel_PrintCharName
	
	; Player 2 - Icon 2
	ld   a, [wCharSelP2Char1]
	cp   CHAR_ID_NONE
	jp   z, .initOBJ
	ld   de, $9270
	ld   hl, BG_CHARSEL_P2ICON1
	ld   c, TILE_CHARSEL_P2ICON1
	call CharSel_DrawP2CharIcon
	ld   de, wOBJInfo_Pl2
	call CharSel_PrintCharName
	
	; Player 2 - Icon 3
	ld   a, [wCharSelP2Char2]
	cp   CHAR_ID_NONE
	jp   z, .initOBJ
	ld   de, $92B0
	ld   hl, BG_CHARSEL_P2ICON2
	ld   c, TILE_CHARSEL_P2ICON2
	call CharSel_DrawP2CharIcon
	ld   de, wOBJInfo_Pl2
	call CharSel_PrintCharName
	
.initDefaultNames:
	; NOTE: In KOF95, before .initOBJ there was code to write the default character names
	;       when no characters are selected yet.
	;       The removal of this code means that CharSel_Select_DoCtrl_NoAction gets to do 
	;       it every frame (which didn't exist in 95)
	
;--
.initOBJ:

	;
	; Set the initial sprite mappings for the cursors
	;
	
	call ClearOBJInfo
	
.cursor_1P:
	;
	; Player 1 Cursor
	;
	
	; Initialize the sprite
	ld   hl, wOBJInfo_Pl1
	ld   de, OBJInfoInit_CharSel_Cursor
	call OBJLstS_InitFrom
	
	ld   hl, wOBJInfo_Pl1+iOBJInfo_OBJLstPtrTblOffset
	ld   de, wOBJInfo_Pl1+iOBJInfo_CharSel_CursorOBJId
	
	; Set the correct sprites for the normal/wide versions
	ld   a, [wPlInfo_Pl1+iPlInfo_Flags0]
	bit  PF0B_CPU, a			; Is this character a CPU?
	jp   nz, .cursorCPU_1P	; If so, jump
	
.cursorPl_1P:
	; Use this as current 1P cursor and when moving on a normal portrait
	ld   a, CHARSEL_OBJ_CURSOR1P
	ld   [hl], a	; Save to iOBJInfo_OBJLstPtrTblOffset
	ld   [de], a	; Save to iOBJInfo_CharSel_CursorOBJId
	inc  de
	; Use the ptr table entry right after when moving on a wide portrait
	add  a, CHARSEL_OBJ_CURSOR1PWIDE - CHARSEL_OBJ_CURSOR1P
	ld   [de], a	; Save to iOBJInfo_CharSel_CursorWideOBJId
	jp   .cursorRefresh_1P
.cursorCPU_1P:
	; Cursor for the CPU, regardless of the player having control or not
	ld   a, CHARSEL_OBJ_CURSORCPU1P
	ld   [hl], a
	ld   [de], a
	inc  de
	add  a, CHARSEL_OBJ_CURSORCPU1PWIDE - CHARSEL_OBJ_CURSORCPU1P
	ld   [de], a
	
.cursorRefresh_1P:
	; Refresh the cursor to set its sprite and coords
	ld   a, [wCharSelP1CursorPos]
	ld   de, wOBJInfo_Pl1
	call CharSel_RefreshCursor
	
.cursor_2P:
	;
	; Player 2 Cursor
	;
	; Do the same thing, but for player 2
	
	; Initialize the sprite
	ld   hl, wOBJInfo_Pl2
	ld   de, OBJInfoInit_CharSel_Cursor
	call OBJLstS_InitFrom
	
	; 2P cursor uses its own palette.
	; This allows unique flashing speed for both players.
	ld   hl, wOBJInfo_Pl2+iOBJInfo_OBJLstFlags
	ld   [hl], SPR_OBP1
	
	ld   hl, wOBJInfo_Pl2+iOBJInfo_OBJLstPtrTblOffset
	ld   de, wOBJInfo_Pl2+iOBJInfo_CharSel_CursorOBJId
	
	; Set the correct sprites for the normal/wide versions
	ld   a, [wPlInfo_Pl2+iPlInfo_Flags0]
	bit  PF0B_CPU, a			; Is this character a CPU?
	jp   nz, .cursorCPU_2P	; If so, jump
	
.cursorPl_2P:
	; Use this as current 2P cursor and when moving on a normal portrait
	ld   a, CHARSEL_OBJ_CURSOR2P
	ld   [hl], a	; Save to iOBJInfo_OBJLstPtrTblOffset
	ld   [de], a	; Save to iOBJInfo_CharSel_CursorOBJId
	inc  de
	; Use the ptr table entry right after when moving on a wide portrait
	add  a, CHARSEL_OBJ_CURSOR2PWIDE - CHARSEL_OBJ_CURSOR2P
	ld   [de], a	; Save to iOBJInfo_CharSel_CursorWideOBJId
	jp   .cursorRefresh_2P
.cursorCPU_2P:
	; Cursor for the CPU, regardless of the player having control or not
	ld   a, CHARSEL_OBJ_CURSORCPU2P
	ld   [hl], a
	ld   [de], a
	inc  de
	add  a, CHARSEL_OBJ_CURSORCPU2PWIDE - CHARSEL_OBJ_CURSORCPU2P
	ld   [de], a
	
.cursorRefresh_2P:
	; Refresh the cursor to set its sprite and coords
	ld   a, [wCharSelP2CursorPos]
	ld   de, wOBJInfo_Pl2
	call CharSel_RefreshCursor
	
	;
	; Set the sprite mappings for the three tile flip animations.
	; Each of them takes its own wOBJInfo slot, and all are hidden by default.
	;
	; All of these tile flipping anims use the same exact sprite mapping, but
	; with different Tile ID base values.
	; As a result, the graphics for the tile flipping (stored in GFXLZ_CharSel_OBJ)
	; have to all be stored in the same order.
	;
	
	; IORI <-> IORI'
	ld   hl, wOBJInfo2+iOBJInfo_Status
	ld   de, OBJInfoInit_CharSel_Cursor
	call OBJLstS_InitFrom					; Copy default settings from Cursor sprite mapping
	ld   hl, wOBJInfo2+iOBJInfo_Status		; Hide sprite
	ld   [hl], $00							
	ld   hl, wOBJInfo2+iOBJInfo_X			; Set X position -- over Iori's portrait
	ld   [hl], $78							
	ld   hl, wOBJInfo2+iOBJInfo_Y			; Set Y position -- over Iori's portrait
	ld   [hl], $00							
	ld   hl, wOBJInfo2+iOBJInfo_TileIDBase	; Add $0E to every tile ID
	ld   [hl], $0E
	ld   hl, wOBJInfo2+iOBJInfo_OBJLstPtrTbl_Low	; Use tile flip sprite mapping
	ld   [hl], LOW(OBJLstPtrTable_CharSel_Flip)
	inc  hl
	ld   [hl], HIGH(OBJLstPtrTable_CharSel_Flip)
	
	; LEONA <-> LEONA'
	ld   hl, wOBJInfo3+iOBJInfo_Status
	ld   de, OBJInfoInit_CharSel_Cursor
	call OBJLstS_InitFrom
	ld   hl, wOBJInfo3+iOBJInfo_Status
	ld   [hl], $00
	ld   hl, wOBJInfo3+iOBJInfo_X
	ld   [hl], $78
	ld   hl, wOBJInfo3+iOBJInfo_Y
	ld   [hl], $30
	ld   hl, wOBJInfo3+iOBJInfo_TileIDBase
	ld   [hl], $2A
	ld   hl, wOBJInfo3+iOBJInfo_OBJLstPtrTbl_Low
	ld   [hl], LOW(OBJLstPtrTable_CharSel_Flip)
	inc  hl
	ld   [hl], HIGH(OBJLstPtrTable_CharSel_Flip)
	
	; CHIZURU <-> KAGURA
	ld   hl, wOBJInfo4+iOBJInfo_Status
	ld   de, OBJInfoInit_CharSel_Cursor
	call OBJLstS_InitFrom
	ld   hl, wOBJInfo4+iOBJInfo_Status
	ld   [hl], $00
	ld   hl, wOBJInfo4+iOBJInfo_X
	ld   [hl], $18
	ld   hl, wOBJInfo4+iOBJInfo_Y
	ld   [hl], $30
	ld   hl, wOBJInfo4+iOBJInfo_TileIDBase
	ld   [hl], $46
	ld   hl, wOBJInfo4+iOBJInfo_OBJLstPtrTbl_Low
	ld   [hl], LOW(OBJLstPtrTable_CharSel_Flip)
	inc  hl
	ld   [hl], HIGH(OBJLstPtrTable_CharSel_Flip)
	
	
	call Pl_InitBeforeStageLoad
	call Serial_DoHandshake
	
	;
	; In VS mode, wStageId = Rand & $03
	;
	ld   a, [wPlayMode]
	bit  MODEB_VS, a	; Playing in VS mode? 
	jp   z, .initEnd		; If not, skip
	call Rand
	and  a, $03
	ld   [wStageId], a
	
.initEnd:
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_OBJSIZE|LCDC_WTILEMAP|LCDC_ENABLE
	rst  $18				; Resume LCD
	;-----------------------------------
	ei
	
	call Task_PassControl_NoDelay
	call Task_PassControl_NoDelay
	; Set DMG palette
	ld   a, $74
	ldh  [rOBP0], a
	ld   a, $74
	ldh  [rOBP1], a
	ld   a, $1B
	ldh  [rBGP], a
	; Play character select BGM
	ld   a, BGM_ROULETTE
	call HomeCall_Sound_ReqPlayExId_Stub
	call Task_PassControl_NoDelay
	
.mainLoop:
	call JoyKeys_DoCursorDelayTimer
	call CharSel_DoMode1P
	call CharSel_DoMode2P
	
	; Unless both players have confirmed their characters, continue looping
	ld   a, [wCharSelP1CursorMode]
	cp   CHARSEL_MODE_CONFIRMED		; Did player 1 confirm their character(s)?
	jp   nz, .noEnd					; If not, jump
	ld   a, [wCharSelP2CursorMode]
	cp   CHARSEL_MODE_CONFIRMED		; Did player 2 confirm their character(s)?
	jp   nz, .noEnd					; If not, jump
	jp   .end						; Otherwise, we're done
.noEnd:
	call Task_PassControl_NoDelay
	jp   .mainLoop
.end:

	; Wait for $3C frames before switching
	ld   b, $3C
.endDelayLoop:
	call Task_PassControl_NoDelay
	dec  b
	jp   nz, .endDelayLoop
	
	; 
	; If we aren't in team mode, gameplay can start right away.
	; Otherwise, we've still got to choose the team order.
	;
	call IsInTeamMode	; Are we in team mode?
	jp   nc, Module_Play	; If not, jump
	ld   b, BANK(Module_OrdSel) ; BANK $1E
	ld   hl, Module_OrdSel
	rst  $00
; =============== CharSel_DoMode1P ===============	
; Handles the character select mode for Player 1.
CharSel_DoMode1P:
	ld   a, CHARSEL_1P
	ld   [wCharSelCurPl], a
	ld   a, [wCharSelP1CursorMode]
	call CharSel_DoMode
	ret
; =============== CharSel_DoMode2P ===============	
; Handles the character select mode for Player 2.
CharSel_DoMode2P:
	ld   a, CHARSEL_2P
	ld   [wCharSelCurPl], a
	ld   a, [wCharSelP2CursorMode]
	call CharSel_DoMode
	ret
; =============== CharSel_DoMode ===============
; IN
; - A: Mode ID
CharSel_DoMode:
	ld   hl, .tbl	; HL = Jump table
	ld   d, $00		; DE = Mode ID
	ld   e, a
	add  hl, de		; Index the table
	ld   e, [hl]	; Read it out to DE
	inc  hl
	ld   d, [hl]
	push de
	pop  hl			; Move to HL and jump there
	jp   hl
.tbl:
	dw CharSel_Mode_Select
	dw CharSel_Mode_Ready
	dw CharSel_Mode_Confirmed
	
; =============== CharSel_Mode_Confirmed ===============
; After all characters are confirmed.
; This does nothing at all - the game uses this mode to wait until both players are 
; in this mode before continuing.
CharSel_Mode_Confirmed:
	ret
	
; =============== CharSel_Mode_Ready ===============
; After all three characters are selected.
CharSel_Mode_Ready:
	call CharSel_AnimCursorPalSlow
	call CharSel_BlinkStartText
	
	; Autoconfirm checks
	call CharSelect_IsCPUOpponent		; Is the current player the CPU opponent?
	jp   c, .confirm					; If so, autoconfirm the choice
	call CharSelect_IsLastWinner		; Did we win last time? (single mode only)
	jp   c, .confirm					; If so, autoconfirm
	call CharSel_IsEndlessCpuVsCpu		; Is this an endless CPU vs CPU match?
	jp   c, .confirm					; If so, autoconfirm (the player should never need to input anything)
	
	; Input checks
	call CharSel_GetInput
	
	; - START or A -> Confirm selected characters
	bit  KEYB_START, a
	jp   nz, .confirm
	; - SELECT -> Remove all characters from team (like in CHARSEL_MODE_SELECT)
	bit  KEYB_SELECT, a
	jp   nz, .removeAll
	;
	bit  KEYB_A, a
	jp   nz, .confirm
	; - B -> Remove last character from team (like in CHARSEL_MODE_SELECT)
	bit  KEYB_B, a
	jp   nz, .removeOne
	ret
	
; =============== .removeAll ===============
.removeAll
	; Remove all three characters from the team.
	call CharSel_HideStartText	; For changing mode
	call CharSel_RemoveChar
	call CharSel_RemoveChar
	call CharSel_RemoveChar
	jp   .switchToSelectMode
	
; =============== .removeOne ===============
.removeOne:
	; Remove the third character from the team
	call CharSel_HideStartText	; For changing mode
	call CharSel_RemoveChar
	
; =============== .switchToSelectMode ===============
.switchToSelectMode:
	; Enable controllable cursor for current player
	ld   a, [wCharSelCurPl]
	or   a					; Currently handling player 1?
	jp   nz, .selectP2		; If not, jump
.selectP1:
	ld   a, CHARSEL_MODE_SELECT
	ld   [wCharSelP1CursorMode], a
	ret
.selectP2:
	ld   a, CHARSEL_MODE_SELECT
	ld   [wCharSelP2CursorMode], a
	ret
	
; =============== .confirm ===============
.confirm:
	; Disable controls for current player by switching to the next mode.
	call CharSel_HideStartText
	call CharSel_HideCursor
	call CharSel_SetPlInfo
	; Switch for the current player
	ld   a, [wCharSelCurPl]
	or   a					
	jp   nz, .confirmPl2
.confirmPl1:
	ld   a, $04
	ld   [wCharSelP1CursorMode], a
	ret
.confirmPl2:
	ld   a, $04
	ld   [wCharSelP2CursorMode], a
	ret
	
; =============== CharSel_Mode_Select ===============
; Initial mode when characters are selectable.
CharSel_Mode_Select:
	call CharSel_AnimPortraitFlip
	call CharSel_AnimCursorPalFast
	ret  z							; Is the cursor visible? If not, return
	
	;
	; Detect if we're randomizing/autopicking characters
	;
	ld   a, [wCharSelCurPl]
	or   a						; Are we handling player 1? (== CHARSEL_1P)
	jp   nz, .pl2				; If not, jump
.pl1:
	ld   a, [wCharSelRandom1P]
	or   a						; Randomizing 1P characters?
	jp   z, .doCtrl				; If not, jump
	jp   .randomPick
.pl2:
	ld   a, [wCharSelRandom2P]
	or   a						; Randomizing 2P characters?
	jp   z, .doCtrl				; If not, jump
.randomPick:	
	call CharSel_RandomPick			; Randomize selected character
	jp   c, CharSel_Select_DoCtrl_A	; Signaled to add it to the team? If so, jump
	ret
	
.doCtrl:
	call CharSel_GetInput
	; Input list:

	; START -> Flips the selected tile, if possible
	; START + B -> Enable autopicker
	bit  KEYB_START, b						; Holding START?
	jp   nz, CharSel_Select_DoCtrl_Start	; If so, jump
	
	; SELECT -> Removes all selected characters
	;           If there are none, returns to the title screen.
	bit  KEYB_SELECT, a						; Pressed SELECT?
	jp   nz, CharSel_Select_DoCtrl_Select	; If so, jump
	
	; A -> Selects a character
	bit  KEYB_A, a							; Pressed A?
	jp   nz, CharSel_Select_DoCtrl_A		; If so, jump
	
	; Directional keys -> Move cursor
	bit  KEYB_DOWN, b						; Holding down?
	jp   nz, CharSel_Select_DoCtrl_Down		; If so, jump
	bit  KEYB_UP, b							; Holding up?
	jp   nz, CharSel_Select_DoCtrl_Up		; If so, jump
	bit  KEYB_LEFT, b						; Holding left?
	jp   nz, CharSel_Select_DoCtrl_Left		; If so, jump
	bit  KEYB_RIGHT, b						; Holding right?
	jp   nz, CharSel_Select_DoCtrl_Right	; If so, jump
	
	; B -> Removes the last selected character
	bit  KEYB_B, a							; Pressed B?
	jp   nz, CharSel_Select_DoCtrl_B		; If so, jump
	
	call CharSel_Select_DoCtrl_NoAction		; Why
	ret
	
; =============== CharSel_Select_DoCtrl_Select ===============
CharSel_Select_DoCtrl_Select:
	call CharSel_CanExitToTitle		; Can we exit?
	jp   c, .toTitle				; If so, jump
	; Otherwise, remove all selected characters.
	; Note that at most 2 characters can be selected in this mode.
	call CharSel_RemoveChar
	call CharSel_RemoveChar
	ret
.toTitle:
	ld   b, BANK(Module_Title) ; BANK $1C
	ld   hl, Module_Title
	rst  $00
	
; =============== CharSel_Select_DoCtrl_Start ===============
CharSel_Select_DoCtrl_Start:
	bit  KEYB_B, c					; Holding B as well?
	jp   nz, .chkSetRandom			; If so, try enabling the random picker
	call CharSel_StartPortraitFlip	; Otherwise, try flipping the tile
	ret
.chkSetRandom:
	;
	; Do not enable the autopicker when playing through serial, otherwise things will desync.
	; VS mode under the SGB is fine, since everything is handled locally.
	;
	ld   a, [wPlayMode]
	bit  MODEB_VS, a		; Playing in VS mode?
	jp   z, .setRandom		; If not, jump
	ld   hl, wMisc_C025
	bit  MISCB_IS_SGB, [hl]	; Playing on a SGB?
	ret  z					; If not, return
.setRandom:
	; Enable random picker for current player
	ld   a, [wCharSelCurPl]
	or   a					; Are we handling player 1?
	jp   nz, .pl2			; If not, jump
	ld   a, $01				; Set random for 1P
	ld   [wCharSelRandom1P], a
	ret  
.pl2:
	ld   a, $01				; Set random for 2P
	ld   [wCharSelRandom2P], a
	ret  
	
; =============== CharSel_Select_DoCtrl_A ===============	
CharSel_Select_DoCtrl_A:
	call CharSel_AddChar
	
	;
	; When the full team is set, switch to the next mode
	;
	ld   a, [wCharSelTeamFull]
	or   a						; Is the team full now?
	ret  z						; If not, return
	ld   a, [wCharSelCurPl]
	or   a						; Are we handling player 1?
	jp   nz, .ready2P			; If not, jump
.ready1P:
	ld   a, CHARSEL_MODE_READY
	ld   [wCharSelP1CursorMode], a
	ret
.ready2P:
	ld   a, CHARSEL_MODE_READY
	ld   [wCharSelP2CursorMode], a
	ret
; =============== CharSel_Select_DoCtrl_B ===============		
CharSel_Select_DoCtrl_B:
	call CharSel_RemoveChar
	ret
; =============== CharSel_Select_DoCtrl_Down ===============
CharSel_Select_DoCtrl_Down:
	call CharSel_MoveCursorD
	jp   CharSel_PlayCursorMoveSFX
; =============== CharSel_Select_DoCtrl_Up ===============
CharSel_Select_DoCtrl_Up:
	call CharSel_MoveCursorU
	jp   CharSel_PlayCursorMoveSFX
; =============== CharSel_Select_DoCtrl_Left ===============
CharSel_Select_DoCtrl_Left:
	call CharSel_MoveCursorL
	jp   CharSel_PlayCursorMoveSFX
; =============== CharSel_Select_DoCtrl_Right ===============
CharSel_Select_DoCtrl_Right:
	call CharSel_MoveCursorR
	; Fall-through
; =============== CharSel_PlayCursorMoveSFX ===============
CharSel_PlayCursorMoveSFX:
	ld   a, SFX_CURSORMOVE
	call HomeCall_Sound_ReqPlayExId
	ret
	
; =============== CharSel_Select_DoCtrl_NoAction ===============
; Updates the cursor OBJInfo and redraws the character name every frame without player input.
;
; This is a bizzare change from KOF95, which didn't need to do this.
; The only side effect of removing this is that the character name won't be visible until
; the cursor moves, because the game doesn't write the default player name anymore during init (unlike KOF95).
CharSel_Select_DoCtrl_NoAction:
	ld   a, [wCharSelCurPl]
	or   a
	jp   nz, .pl2
.pl1:
	ld   hl, wCharSelP1CursorPos
	ld   de, wOBJInfo_Pl1+iOBJInfo_Status
	jp   .refresh
.pl2:
	ld   hl, wCharSelP2CursorPos
	ld   de, wOBJInfo_Pl2+iOBJInfo_Status
.refresh:
	ld   a, [hl]
	call CharSel_RefreshNameAndCursor
	ret
	
; =============== CharSel_RandomPick ===============
; Handles the automatic cursor picker.
;
; OUT
; - C flag: If set, the character should be added to the team
;           (bubbled up from CharSel_SetRandomPortrait)
CharSel_RandomPick:
	ld   a, [wCharSelCurPl]
	or   a						; Currently handling player 1?
	jp   nz, .pl2				; If not, jump
.pl1:
	; Randomize 1P cursor position
	ld   bc, wCharSelRandomDelay1P
	ld   hl, wCharSelP1CursorPos
	ld   de, wOBJInfo_Pl1+iOBJInfo_Status
	call CharSel_SetRandomPortrait
	; If it was requested to add the character, return (preserving the C flag)
	jp   c, .ret							
	jp   .chkRandomFlip
.pl2:
	; Randomize 2P cursor position
	ld   bc, wCharSelRandomDelay2P
	ld   hl, wCharSelP2CursorPos
	ld   de, wOBJInfo_Pl2+iOBJInfo_Status
	call CharSel_SetRandomPortrait
	; If it was requested to add the character, return (preserving the C flag)
	jp   c, .ret
	
.chkRandomFlip:
	;
	; Try to randomly flip the current tile.
	; This is only executed when we aren't told to select the character yet.
	;
	; If the tile does get flipped, there's no need to call CharSel_RefreshNameAndCursor
	; since CharSel_StartPortraitFlip does it already.
	;
	push af
		call CharSelect_IsCPUOpponent	; Is this a CPU opponent?
		jp   c, .refresh				; If so, jump
		; Try to flip the tile
		call CharSel_StartPortraitFlip	; Did we manage to start the tile flip?
		jr   c, .refresh				; If not, jump
	pop  af
	xor  a		; C flag clear, no select
	ret
	
	.refresh:
	pop  af
	call CharSel_RefreshNameAndCursor
	xor  a		; C flag clear, no select
.ret:
	ret
; =============== CharSel_SetRandomPortrait ===============	
; Randomizes the cursor position on the character select screen
; and decides if it should be selected or not.
;
; IN
; - BC: Ptr to CPU delay timer. Not applicable on user-triggered randomizer.
; - HL: Ptr to selected portrait. The new portrait ID will be set here.
; - DE: Ptr to cursor OBJLst
; OUT
; - C flag: If set, the character should be added to the team
CharSel_SetRandomPortrait:
	;
	; Wait until the delay timer expires before signaling that the character should be selected.
	;
	ld   a, [bc]
	or   a					; DelayTimer == 0?
	jp   z, .setPick		; If so, jump
	dec  a					; DelayTimer--
	ld   [bc], a
.genRandomPos:

	;--
	;
	; Generate a random portrait ID
	; A = HIGH(Rand * $12)
	; Since the cursor randomizer can't be done with serial mode anyway,
	; the English version uses the LY version.
	;
IF REV_VER_2 == 0
	call Rand			; A = Random byte
ELSE
	call RandLY
ENDC
	push hl
		ld   h, $00		; HL = A
		ld   l, a
		push hl
REPT 4
			sla  l		; HL *= $10
			rl   h
ENDR
			push hl
			pop  bc		; Move to BC
		pop  hl
		
		sla  l			; HL = A * 2
		rl   h
		add  hl, bc		; Merge those (HL = A * $12)
		ld   a, h		; Only pick the high byte (which will always be in $00-$11 range)
	pop  hl
	;--
	
	; Regenerate it if the portrait is locked 
	push af
		call CharSel_IsPortraitLocked	; Is this a locked character?
		jp   nc, .setRandomPos			; If not, jump
	pop  af
	jp   .genRandomPos					; Otherwise, rerand
.setRandomPos:
	pop  af
	ld   [hl], a			; Set selected portrait ID
	scf
	ccf						; C flag = 0
	ret
	
.setPick:
	push de
		push hl
			
			; Generate a new random delay value identically to the init code.
			call Rand
			and  a, $1F
			add  a, $07
			ld   [bc], a
			;--
			
			;
			; If the current player is the CPU opponent, replace whatever portrait is selected
			; with the correct value from the CPU opponent sequence.
			;
			; See also: CharSelect_IsCPUOpponent
			;
			
			; No stage sequence in VS modes
			ld   a, [wPlayMode]
			bit  MODEB_VS, a		; Playing in VS mode?
			jp   nz, .noChange		; If so, skip
			
			; The current player must be a CPU opponent (ie: no way to control cursor movement)
			ld   a, [wCharSelCurPl]
			or   a					; Currently handling player 1?
			jp   nz, .chkPl2		; If not, jump
		.chkPl1:
			; If the active player is 2P, 1P is the CPU opponent
			ld   a, [wJoyActivePl]
			or   a					; Is 1P the active player?
			jp   z, .noChange		; If so, skip
			ld   hl, wCharSelP1Char0
			jp   .getSeqOffset
		.chkPl2:
			; If the active player is 1P, 2P is the CPU opponent
			ld   a, [wJoyActivePl]
			or   a					; Is 1P the active player?
			jp   nz, .noChange		; If not, skip
			ld   hl, wCharSelP2Char0
		.getSeqOffset:
			;--
			
			;
			; Get the char ID off the sequence of CPU opponents.
			;
			; CharId = wCharSeqTbl[wCharSeqId + TeamPos]
			;          Where TeamPos is the 0-based number of the first free slot found.
			;
			
			; Index wCharSeqTbl by wCharSeqId
			ld   a, [wCharSeqId]	; A = SeqId
			ld   de, wCharSeqTbl	; DE = SeqTbl
			add  a, e				; DE += A
			jp   nc, .chkFreeSlot
			inc  d 					; We never get here
		.chkFreeSlot:
			ld   e, a				

			; Add TeamPos by incrementing DE for every filled slot
			ldi  a, [hl]			; A = First slot, TeamSlot++
			cp   CHAR_ID_NONE		; Is the first slot filled?
			jp   z, .setChar		; If so, fill it
			inc  de					; + 1
			
			ldi  a, [hl]			; A = Second slot, TeamSlot++
			cp   CHAR_ID_NONE		; Is the first slot filled?
			jp   z, .setChar		; If so, fill it
			inc  de					; + 2
		.setChar:
			ld   a, [de]			; Get character ID from sequence
		pop  hl
	pop  de
	
	; Update cursor position with new CharId we just got
	ld   [hl], a				
	; Reload screen due to update
	call CharSel_RefreshNameAndCursor
	; C flag set, request char select
	scf		
	ret
	
		.noChange:
		
		pop  hl
	pop  de
	; C flag set, request char select
	scf		
	ret  
	
; =============== CharSel_StartPortraitFlip ===============
; Attempts to start flipping the tile.
; OUT
; - C flag: If set, the request was denied
CharSel_StartPortraitFlip:
	; The characters accessible through tile flipping are all unlockables
	ld   a, [wDipSwitch]
	bit  DIPB_UNLOCK_OTHER, a	; Are all characters unlocked?
	jr   z, .notDone			; If not, return
	
	; Use player-specific vars.
	; Palette lines are different between players, just like with the cursors, to avoid palette conflicts.
	ld   a, [wCharSelCurPl]
	or   a							; Playing as 1P?
	jp   nz, .pl2					; If not, jump
.pl1:
	ld   hl, wCharSelP1CursorPos	; HL = 1P Cursor position
	ld   de, wOBJInfo_Pl1			; DE = 1P Cursor wOBJInfo
	ld   b, $00						; B = OBJLst flags (use OBP0)
	push de
	push hl
	call CharSel_StartPortraitFlip_CheckChar
	pop  hl
	pop  de
	jp   c, .notDone				; Was a portrait flip started? If not, return
	ld   a, $1B						; Set tile flip palette
	ldh  [rOBP0], a
	jp   .started
.pl2:
	ld   hl, wCharSelP2CursorPos	; HL = 2P Cursor position
	ld   de, wOBJInfo_Pl2			; DE = 2P Cursor wOBJInfo
	ld   b, SPR_OBP1				; B = OBJLst flags (use OBP1)
	push de
	push hl
	call CharSel_StartPortraitFlip_CheckChar
	pop  hl
	pop  de
	jp   c, .notDone				; Was a portrait flip started? If not, return
	ld   a, $1B						; Set tile flip palette
	ldh  [rOBP1], a
.started:
	; Refresh the character name with the updated one
	ld   a, [hl]						; A = wCharSelP*CursorPos
	call CharSel_RefreshNameAndCursor
	; Play SFX when starting a tile flip
	ld   a, SFX_HEAVY
	call HomeCall_Sound_ReqPlayExId
	xor  a	; C flag clear -- Started
	ret
.notDone:
	scf		; C flag set -- Not started
	ret
; =============== CharSel_StartPortraitFlip_CheckChar ===============
; Attempts to starts the portrait flip animation and sets up the updated character IDs.
; IN
; - HL: Ptr to cursor position
; - DE: Ptr to cursor wOBJInfo
; - B: OBJLst flags for tile flip
; OUT
; - C flag: If set, we can't do it
CharSel_StartPortraitFlip_CheckChar:
	; Determine what to do based on these hardcoded positions
	ld   a, [hl]			; Read wCharSelP*CursorPos
	cp   CHARSEL_ID_IORI	; Over Iori's position?
	jp   z, .iori			; If so, switch between Iori and O. Iori
	cp   CHARSEL_ID_CHIZURU	; Over Chizuru's position?
	jp   z, .chizuru		; If so, switch between Chizuru and Kagura
	cp   CHARSEL_ID_LEONA	; Over Leona's position?
	jp   z, .leona			; If so, switch between Leona and O. Leona
	; Otherwise, the tile's not flippable
	scf	
	ret
; =============== mStartFlipPortrait ===============
; Generates code to start flipping a specific portrait.
; IN
; - 1: Ptr to OBJInfo for tile flip
; - 2: Normal character id (CHAR_ID_*)
; - 3: Normal portrait id (CHARSEL_ID_*)
; - 4: Normal tile id base
; - 5: Alternate char id (CHAR_ID_*)
; - 6: Alternate portrait id (CHARSEL_ID_*)
; - 7: Alternate tile id base
mStartFlipPortrait: MACRO

	; Not applicable if this tile flip is in progress already.
	push af
		ld   a, [\1+iOBJInfo_Status]
		bit  OSTB_VISIBLE, a		; Is the tile flip sprite visible?
		jp   nz, .retFail			; If so, return
	pop  af
	
	; Initialize common things (set data in cursor wOBJInfo, blank out portrait)
	ld   c, LOW(\1-wOBJInfo_IoriFlip)	; C = Offset to correct wOBJInfo from wOBJInfo_IoriFlip (the first one)
	call .initAndGetArgs	; Init things and get HL, A
	; - HL: Ptr to wCharSelIdMapTbl entry.
	; - A: Character ID currently selectable at this position
	
	
	; Toggle between original and alterate depending on the currently active character.
	cp   \2/2	; Is normal character selectable?
	jr   z, .setAlt_\@	; If so, jump (switch to alternate)
.setNorm_\@:
	;
	; Switch from alternate to normal portrait
	;
	
	; Set normal character ID (ie: CHAR_ID_IORI) to wCharSelIdMapTbl entry
	ld   [hl], \2/2		
	
	; Display and start tile flipping anim (alt to norm)
	ld   de, \1
	call .setFlipToNorm
	
	; Save in the tile flip wOBJInfo the arguments to CharSel_DrawPortrait.
	; It will be called with these args when the new portrait gets drawn once the tile flip animation ends.
	ld   hl, \1+iOBJInfo_CharSelFlip_PortraitId
	ld   [hl], \3	; Portrait ID (ie: CHARSEL_ID_IORI)
	inc  hl
	ld   [hl], \4	; Tile ID
	jp   .retOk
.setAlt_\@:
	;
	; Switch from normal to alternate portrait
	;
	
	; Set alternate character ID (ie: CHAR_ID_OIORI) to wCharSelIdMapTbl entry
	ld   [hl], \5/2
	
	; Display and start tile flipping anim (norm to alt)
	ld   de, \1
	call .setFlipToAlt
	
	; Like the other part
	ld   hl, \1+iOBJInfo_CharSelFlip_PortraitId
	ld   [hl], \6	; Portrait ID (ie: CHARSEL_ID_SPEC_OIORI)
	inc  hl
	ld   [hl], \7	; Tile ID
ENDM
	

.iori:
	;                 | OBJINFO            | NORMAL                                       | ALT
	;                 |                    | CHAR ID          PORTRAIT ID         TILE ID | CHAR ID         PORTRAIT ID             TILE ID
	mStartFlipPortrait wOBJInfo_IoriFlip   , CHAR_ID_IORI   , CHARSEL_ID_IORI   , $2D     , CHAR_ID_OIORI , CHARSEL_ID_SPEC_OIORI , $A2
	jp   .retOk
.leona:
	mStartFlipPortrait wOBJInfo_LeonaFlip  , CHAR_ID_LEONA  , CHARSEL_ID_LEONA  , $99     , CHAR_ID_OLEONA, CHARSEL_ID_SPEC_OLEONA, $AB
	jp   .retOk	
.chizuru:
	mStartFlipPortrait wOBJInfo_ChizuruFlip, CHAR_ID_CHIZURU, CHARSEL_ID_CHIZURU, $75     , CHAR_ID_KAGURA, CHARSEL_ID_SPEC_KAGURA, $B4
.retOk:
	; Tile flip was started (C flag clear)
	xor  a
	ret
.retFail:
	; Error (C flag set)
	pop  af
	scf  
	ret 
	
; =============== .initAndGetArgs ===============
; Contains the init code shared across all tile flips, and returns out needed vars.
; IN
; - A: Cursor position (CHARSEL_ID_*)
; - C: OBJInfo offset (multiple of OBJINFO_SIZE)
; - DE: Ptr to cursor wOBJInfo
; OUT
; - HL: Ptr to wCharSelIdMapTbl entry.
;       Writing here will change the character you get when selecting the tile.
; - A: Character ID currently selectable at this position
.initAndGetArgs:

	; Hide the cursor
	ld   hl, iOBJInfo_Status
	add  hl, de
	ld   [hl], $00		; Clear out OST_VISIBLE flag
	
	; Write the offset for the flip OBJInfo to the cursor's free space
	ld   hl, iOBJInfo_CharSel_FlipOBJInfoOffset
	add  hl, de			; DE = Seek to offset byte
	ld   [hl], c		; Write it
	
	; Blank out the portrait, since the flipping tile sprite will take its place
	call .blankPortrait		
	
	; Get the character ID we get by selecting the tile (before it changes)
	ld   hl, wCharSelIdMapTbl	; HL = Pos to ID map table
	ld   d, $00					; DE = Cursor position
	ld   e, a
	add  hl, de					; Index the table
	ld   a, [hl]				; A = Source character ID
	ret
.blankPortrait:
	; Save all args
	push af
	push bc
	push de
	push hl
	ld   b, a		; B = Cursor position
	ld   c, $00		; A = Base tile ID (all black tiles)
	call CharSel_ClearPortrait
	pop  hl
	pop  de
	pop  bc
	pop  af
	ret

; =============== .setFlipToNorm ===============
; Updates the tile flip OBJInfo when switching from alternate to normal.
; IN
; - DE: Ptr to tile flip wOBJInfo
; - B: OBJLst flags for tile flip (coming from CharSel_StartPortraitFlip_CheckChar)
.setFlipToNorm:

	; Show the sprite mapping
	ld   hl, iOBJInfo_Status
	add  hl, de					; Seek to OBJInfo flags
	ld   [hl], OST_VISIBLE		; Set visibility flag
	
	; Set sprite mapping flags (to use OBP1 for 2P)
	ld   a, b					
	ld   hl, iOBJInfo_OBJLstFlags
	add  hl, de					; Seek to spr. map flags
	ld   [hl], a				; Write them out
	
	;--
	; The alternate-to-normal tile flip displays these frames in sequence:
	; 4-5-6-7-0
	;
	; Note that the 4 and 0 overlap with the other flip animation.
	;
	; Start animation from 4
	ld   hl, iOBJInfo_OBJLstPtrTblOffset
	add  hl, de
	ld   [hl], 4*OBJLSTPTR_ENTRYSIZE

	; End animation when 0 finishes displaying
	ld   hl, iOBJInfo_CharSelFlip_OBJIdTarget
	add  hl, de
	ld   [hl], 0*OBJLSTPTR_ENTRYSIZE
	;--
	
	; Reset the anim frame counter
	ld   hl, iOBJInfo_FrameTotal
	add  hl, de		; Seek to iOBJInfo_FrameTotal
	ld   a, [hl]	; Read anim speed value
	dec  hl			; Seek back to iOBJInfo_FrameLeft
	ld   [hl], a	; Copy it here
	ret
	
; =============== .setFlipToAlt ===============
; Updates the tile flip OBJInfo when switching from normal to alternate.
; See also: .setFlipToNorm
; IN
; - DE: Ptr to tile flip wOBJInfo
.setFlipToAlt:

	; Show the sprite mapping
	ld   hl, iOBJInfo_Status
	add  hl, de					; Seek to OBJInfo flags
	ld   [hl], OST_VISIBLE		; Set visibility flag
	
	; Set sprite mapping flags (to use OBP1 for 2P)
	ld   a, b					
	ld   hl, iOBJInfo_OBJLstFlags
	add  hl, de					; Seek to spr. map flags
	ld   [hl], a				; Write them out
	
	;--
	; The normal-to-alt tile flip displays these frames in sequence:
	; 0-1-2-3-4
	;
	; Start animation from 0
	ld   hl, iOBJInfo_OBJLstPtrTblOffset
	add  hl, de
	ld   [hl], 0*OBJLSTPTR_ENTRYSIZE

	; End animation when 4 finishes displaying
	ld   hl, iOBJInfo_CharSelFlip_OBJIdTarget
	add  hl, de
	ld   [hl], 4*OBJLSTPTR_ENTRYSIZE
	;--
	
	; Reset the anim frame counter
	ld   hl, iOBJInfo_FrameTotal
	add  hl, de		; Seek to iOBJInfo_FrameTotal
	ld   a, [hl]	; Read anim speed value
	dec  hl			; Seek back to iOBJInfo_FrameLeft
	ld   [hl], a	; Copy it here
	ret
	
; =============== CharSel_AnimPortraitFlip ===============
; Handles the animation for flipping portraits (aka tile flip).
CharSel_AnimPortraitFlip:

	;
	; Pick the wOBJInfo for the current player cursor
	;
	ld   a, [wCharSelCurPl]
	or   a						; Playing as Player 1? (== CHARSEL_1P)
	jp   nz, .pl2				; If not, jump
.pl1:
	ld   de, wOBJInfo_Pl1+iOBJInfo_Status
	jp   .go
.pl2:
	ld   de, wOBJInfo_Pl2+iOBJInfo_Status
	
.go:

	; The cursor must be hidden to do this
	ld   hl, iOBJInfo_Status
	add  hl, de					; Seek to the status
	bit  OSTB_VISIBLE, [hl]		; Is the visibility flag set?
	ret  nz						; If so, return
	
	; Seek to the wOBJInfo for the tile flip animation and store it to DE.
	;
	; Three continuous OBJInfo (slots 2,3,4) are allocated for the three different tile flips,
	; with the value in the cursor custom area iOBJInfo_CharSel_FlipOBJInfoOffset being added to the first slot's address.
	; DE = wOBJInfo_IoriFlip + *iOBJInfo_CharSel_FlipOBJInfoOffset
	ld   hl, iOBJInfo_CharSel_FlipOBJInfoOffset	; Seek to offset (will be multiple of wOBJInfo size)
	add  hl, de
	ld   l, [hl]					; Read out the value to HL
	ld   h, $00
	ld   de, wOBJInfo_IoriFlip		; DE = Ptr to first OBJInfo used for the tile flip
	add  hl, de						; Offset it
	push hl
	pop  de							; Move it out to DE
	
	; If the tile flip OBJInfo isn't visible, return
	ld   hl, iOBJInfo_Status
	add  hl, de
	bit  OSTB_VISIBLE, [hl]
	ret  z
	
	;
	; Determine if the animation is over.
	;
	
	; If we aren't displaying the last sprite mapping (the target), skip
	ld   hl, iOBJInfo_OBJLstPtrTblOffset
	add  hl, de								; Seek to iOBJInfo_OBJLstPtrTblOffset
	ld   a, [hl]							; A = Current Sprite mapping ID
	ld   hl, iOBJInfo_CharSelFlip_OBJIdTarget
	add  hl, de								; Seek to iOBJInfo_CharSelFlip_OBJIdTarget
	cp   a, [hl]							; Does the current value match the target?
	jp   nz, .animCont						; If not, jump
	
	; If there are anim. frames left, skip
	ld   hl, iOBJInfo_FrameLeft
	add  hl, de								; Seek to iOBJInfo_FrameLeft
	ld   a, [hl]
	or   a									; FramesLeft == 0?
	jp   nz, .animCont						; If not, jump
	
.animEnd:
	;
	; It's over
	;
	
	; When the animation started, we blanked out the portrait.
	; Draw the updated portrait with the args we've saved in the OBJInfo custom area.
	ld   hl, iOBJInfo_CharSelFlip_PortraitId
	add  hl, de								; 
	ld   b, [hl]							; B = Portrait ID
	inc  hl
	ld   c, [hl]							; C = Base Tile ID
	push de
		call CharSel_DrawPortrait			; Draw the portrait
	pop  de
	
	; Hide the tile flip sprite mapping
	ld   hl, iOBJInfo_Status
	add  hl, de								; Seek to tile flip iOBJInfo_Status
	ld   [hl], $00							; Clear out status field, hiding it
	
	; Display the current player cursor again
	ld   a, [wCharSelCurPl]
	or   a									; Playing as Player 1? (== CHARSEL_1P)
	jp   nz, .endPl2						; If not, jump
.endPl1:
	ld   hl, wOBJInfo_Pl1+iOBJInfo_Status	; HL = Status for 1P cursor
	jp   .end
.endPl2:
	ld   hl, wOBJInfo_Pl2+iOBJInfo_Status	; HL = Status for 2P cursor
.end:
	ld   [hl], OST_VISIBLE					; Set visibility flag
	
	; Reuse this sound effect once the flip is done
	ld   a, SFX_STEP_HEAVY
	call HomeCall_Sound_ReqPlayExId
	ret
	
.animCont:
	; Continue animating the sprite mapping for the tile flip
	push de
	pop  hl
	call OBJLstS_DoAnimTiming_Loop
	ret
	
; =============== CharSel_MoveCursorD ===============
; Moves the cursor for the current player down in the character select screen.
CharSel_MoveCursorD:
	; Pick current player args
	ld   a, [wCharSelCurPl]
	or   a
	jp   nz, .pl2
.pl1:
	ld   hl, wCharSelP1CursorPos
	ld   de, wOBJInfo_Pl1+iOBJInfo_Status
	call CharSel_MoveCursorPosD
	jp   .redraw
.pl2: 
	ld   hl, wCharSelP2CursorPos
	ld   de, wOBJInfo_Pl2+iOBJInfo_Status
	call CharSel_MoveCursorPosD
.redraw:
	; Refesh the cursor OBJInfo and char name for the new position
	call CharSel_RefreshNameAndCursor
	ret
	
; =============== CharSel_MoveCursorPosD ===============
; Moves the specified cursor position down by 1 in the character select screen.
; IN
; - HL: Ptr to cursor position
CharSel_MoveCursorPosD:
	; The character select grid is 6x3, which is $12 slots.
	ld   a, [hl]				; A = CursorPos
.moveD:
	; Move down by 1 portrait 
	add  a, CHARSEL_GRID_W		; CursorPos += RowSize
.chkBound:
	; Handle the bounds check.
	; If we moved past the last entry, wrap back to the top
	cp   CHARSEL_GRID_SIZE		; CursorPos >= GridSize?
	jp   c, .chkLock			; If not, skip
	sub  a, CHARSEL_GRID_SIZE	; CursorPos -= GridSize
.chkLock:
	; Skip locked characters
	push af
		call CharSel_IsPortraitLocked	; Is the cursor over a locked character?
		jp   nc, .save					; If not, save the value back
	pop  af
	jp   .moveD			; Otherwise, move down again
.save:
	pop  af
	ld   [hl], a		; Save back CursorPos
	ret
	
; =============== CharSel_MoveCursorU ===============
; Moves the cursor for the current player up in the character select screen.
; See also: CharSel_MoveCursorD
CharSel_MoveCursorU:
	ld   a, [wCharSelCurPl]
	or   a
	jp   nz, .pl2
.pl1:
	ld   hl, wCharSelP1CursorPos
	ld   de, wOBJInfo_Pl1+iOBJInfo_Status
	call CharSel_MoveCursorPosU
	jp   .redraw
.pl2:
	ld   hl, wCharSelP2CursorPos
	ld   de, wOBJInfo_Pl2+iOBJInfo_Status
	call CharSel_MoveCursorPosU
.redraw:
	call CharSel_RefreshNameAndCursor
	ret
	
; =============== CharSel_MoveCursorPosU ===============
; IN
; - HL: Ptr to cursor position
CharSel_MoveCursorPosU:
	ld   a, [hl]			; A = CursorPos
.moveU:
	; Move up by 1 portrait
	sub  a, CHARSEL_GRID_W	; CursorPos -= RowSize
.chkBound:
	; Handle the bounds check.
	; If we underflowed (could have been a "jr c"), wrap to the bottom
	bit  7, a					; CursorPos < 0?
	jp   z, .chkLock			; If not, skip
	add  a, CHARSEL_GRID_SIZE	; CursorPos += GridSize
.chkLock:
	; Skip locked characters
	push af
		call CharSel_IsPortraitLocked	; Is the cursor over a locked character?
		jp   nc, .save					; If not, save the value back
	pop  af
	jp   .moveU			; Otherwise, move up again
.save:
	pop  af
	ld   [hl], a		; Save back CursorPos
	ret
	
; =============== CharSel_MoveCursorL ===============
; Moves the cursor for the current player left in the character select screen.
; See also: CharSel_MoveCursorD
CharSel_MoveCursorL:
	ld   a, [wCharSelCurPl]
	or   a
	jp   nz, .pl2
.pl1:
	ld   hl, wCharSelP1CursorPos
	ld   de, wOBJInfo_Pl1+iOBJInfo_Status
	call CharSel_MoveCursorPosL
	jp   .refresh
.pl2:
	ld   hl, wCharSelP2CursorPos
	ld   de, wOBJInfo_Pl2+iOBJInfo_Status
	call CharSel_MoveCursorPosL
.refresh:
	call CharSel_RefreshNameAndCursor
	ret
	
; =============== CharSel_MoveCursorPosL ===============
; IN
; - HL: Ptr to cursor position
CharSel_MoveCursorPosL:
	ld   a, [hl]			; A = CursorPos
.moveL:
	; Handle row wrapping
	cp   CHARSEL_GRID_W*0	; First row
	jp   z, .wrapH
	cp   CHARSEL_GRID_W*1	; Second row
	jp   z, .wrapH
	cp   CHARSEL_GRID_W*2	; Third row
	jp   z, .wrapH
	
	; Handle wide portrait special case.
	; If we're on the right side of Mr. Karate's portrait, skip the left side when moving left.
	cp   CHARSEL_ID_MRKARATE1
	jp   z, .mrKarate
	
.moveNorm:
	dec  a					; Otherwise, move left once
	jp   .chkLock
.wrapH:
	add  a, CHARSEL_GRID_W-1	; Move to rightmost portrait in row
	jp   .chkLock
.mrKarate:
	sub  a, $02				; Skip left side of portrait
.chkLock:
	; Skip locked characters
	push af
		call CharSel_IsPortraitLocked	; Is the cursor over a locked character?
		jp   nc, .save					; If not, save the value back
	pop  af
	jp   .moveL			; Otherwise, move left again
.save:
	pop  af
	ld   [hl], a		; Save back CursorPos
	ret
	
; =============== CharSel_MoveCursorR ===============
; Moves the cursor for the current player right in the character select screen.
; See also: CharSel_MoveCursorD
CharSel_MoveCursorR:
	ld   a, [wCharSelCurPl]
	or   a
	jp   nz, .pl2
.pl1:
	ld   hl, wCharSelP1CursorPos
	ld   de, wOBJInfo_Pl1+iOBJInfo_Status
	call CharSel_MoveCursorPosR
	jp   .refresh
.pl2:
	ld   hl, wCharSelP2CursorPos
	ld   de, wOBJInfo_Pl2+iOBJInfo_Status
	call CharSel_MoveCursorPosR
.refresh:
	call CharSel_RefreshNameAndCursor
	ret
	
; =============== CharSel_MoveCursorPosR ===============
; IN
; - HL: Ptr to cursor position
CharSel_MoveCursorPosR:
	ld   a, [hl]		; A = CursorPos
.moveR:
	; Handle row wrapping
	cp   (CHARSEL_GRID_W*1)-1	; First row
	jp   z, .wrapH
	cp   (CHARSEL_GRID_W*2)-1	; Second row
	jp   z, .wrapH
	cp   (CHARSEL_GRID_W*3)-1	; Third row
	jp   z, .wrapH
	
	; Handle wide portrait special case.
	; If we're on the left side of Mr. Karate's portrait, skip the right side when moving right.
	cp   CHARSEL_ID_MRKARATE0
	jp   z, .mrKarate
	
.moveNorm:
	inc  a					; Otherwise, move right once
	jp   .chkLock
.wrapH:
	sub  a, CHARSEL_GRID_W-1	; Move to leftmost portrait in row
	jp   .chkLock
.mrKarate:
	add  a, $02			; Skip right side of portrait
.chkLock:
	; Skip locked characters
	push af
		call CharSel_IsPortraitLocked	; Is the cursor over a locked character?
		jp   nc, .save					; If not, save the value back
	pop  af
	jp   .moveR			; Otherwise, move right again
.save:
	pop  af
	ld   [hl], a		; Save back CursorPos
	ret
	
; =============== CharSel_IsPortraitLocked ===============
; Determines if the specified cursor is over a locked character.
;
; IN
; - A: Portrait ID (cursor position)
; OUT
; - C flag: If set, the cursor is over a locked character
CharSel_IsPortraitLocked:
	; Locked characters are set during init by repacing their entries
	; in the "PortraitID to CharID" table to CHAR_ID_NONE.
	;
	; Determining if a character is unlocked, therefore, only involves checking 
	; for that value without dealing with dip switches or character ID checks.
	push hl
		ld   hl, wCharSelIdMapTbl	; HL = Mapping table
		; Index it with the portrait ID
		; HL += A
		add  a, l
		jp   nc, .noInc
		inc  h
	.noInc:
		ld   l, a
		;--
		ld   a, [hl]			; A = Character ID
		cp   CHAR_ID_NONE		; Is this entry CHAR_ID_NONE?
		jp   nz, .isUnlocked	; If not, jump
.isLocked:
	pop  hl
	scf		; C flag set, locked
	ret
.isUnlocked:
	pop  hl
	xor  a	; C flag clear, unlocked
	ret
	
; =============== CharSel_CanExitToTitle ===============
; Determines if it's possible to return to the title screen.
;
; This is NOT possible when:
; - Playing VS mode through serial
; - A character is selected
; - In Single mode, at least one stage is beaten (prevents exit after a game over)
;
; OUT
; - C flag: If set, the game can return to the title screen
CharSel_CanExitToTitle:
	; In single mode, check which stage we're in
	ld   a, [wPlayMode]
	bit  MODEB_VS, a		; Playing in VS mode?
	jr   z, .chkRound		; If not, jump
	
	; In VS *serial* mode, don't allow exiting
	ld   hl, wMisc_C025
	bit  MISCB_IS_SGB, [hl]	; Running on a SGB?
	jr   z, .no				; If not, jump
	
	; Skip stage check, it's not applicable in VS mode
	jr   .chkSel
	
.chkRound:
	; No exit on next rounds
	ld   a, [wCharSeqId]
	or   a					; Beaten at least one stage? (not the first char select screen)
	jp   nz, .no			; If so, jump
.chkSel:

	; Check if at least one character is selected on the current side
	ld   a, [wCharSelCurPl]
	or   a						; Playing as 1P?
	jp   nz, .pl2				; If not, jump
.pl1:
	ld   hl, wCharSelP1Char0	; Check 1P side
	jr   .doChk
.pl2:
	ld   hl, wCharSelP2Char0	; Check 2P side
.doChk:
	ld   a, [hl]				; Read character id
	cp   CHAR_ID_NONE			; Is the first character slot empty?
	jr   z, .ok					; If so, we can exit
.no:
	xor  a		; C flag = 0, can't exit
	ret
.ok:
	scf			; C flag = 1, can exit
	ret
	
; =============== CharSel_RemoveChar ===============
; Removes the last selected character for the current player.
CharSel_RemoveChar:

	; Pick the player-specific initial address
	ld   a, [wCharSelCurPl]
	or   a						; Playing as 1P?
	jp   nz, .pl2				; If so, jump
.pl1:
	ld   de, wCharSelP1Char2
	call CharSel_ClearSlot		; Try to clear a slot
	jp   c, .ret				; If nothing found, return
	call CharSel_ClearTopIcon1P	; Otherwise, also remove the char icon
	jp   .ret
.pl2:
	ld   de, wCharSelP2Char2
	call CharSel_ClearSlot
	jp   c, .ret
	call CharSel_ClearTopIcon2P
.ret:
	ret
	
; =============== CharSel_ClearSlot ===============
; Clears the first filled slot found, searching from highest to lowest.
; IN
; - DE: Ptr to third selected character
; OUT
; - B: Updated number of selected characters
; - C flag: If set, no slot was found
CharSel_ClearSlot:
	;
	; In single mode, there's only one slot to check.
	;
	call IsInTeamMode		; Are we in team mode?
	jp   c, .team			; If so, jump
.single:
	ld   b, $00				; B = No characters selected
	
	push de					; Seek back to first character slot
	pop  hl
	dec  hl					; HL -= 2
	dec  hl
	
	ld   a, CHAR_ID_NONE	; A = Comparison valye
	jp   .chkSlot0
	
	;
	; In Team mode, check all 3 characters.
	;
.team:
	; Start B with the highest value, and decrement it as slot
	ld   b, $02				; 3 characters (with 1 removed)
	push de
	pop  hl					; HL = Third team slot
	ld   a, CHAR_ID_NONE	; A = Comparison valye
.chkSlot2:
	cp   a, [hl]			; Is the third character empty?
	jp   nz, .clearSlot		; If not, clear it
	dec  b					; RemNum--
	dec  hl					; Seek to previous slot
.chkSlot1:
	cp   a, [hl]			; Is the second character empty?
	jp   nz, .clearSlot		; If not, clear it
	dec  b					; RemNum--
	dec  hl					; Seek to previous slot
.chkSlot0:
	cp   a, [hl]			; Is the first character empty?
	jp   nz, .clearSlot		; If not, clear it
	; Otherwise, there's nothing to clear
	scf						; C flag cleared, no slot found
	ret
.clearSlot:
	ld   [hl], CHAR_ID_NONE	; Clear out slot
	xor  a					; C flag cleared, slot found
	ret
; =============== CharSel_ClearTopIcon1P ===============
; Clears the icon for the deselected character, replacing it with the numeric placeholder.
; IN
; - B: Updated number of selected characters (passed by CharSel_ClearSlot)
CharSel_ClearTopIcon1P:
	ld   a, b
	cp   $01			; Is there 1 selected character now (down from 2)?
	jp   z, .blank2		; If so, jump
	cp   $02			; Are there 2 selected characters now (down from 3)?
	jp   z, .blank3		; If so, jump
	; Otherwise, there are no selected characters (down from 1).
.blank1:
	; Blank out the icon for the first slot.
	ld   hl, BG_CHARSEL_P1ICON0
	ld   c, TILE_CHARSEL_ICONEMPTY1
	jp   .go
.blank2:
	; Blank out the icon for the second slot.
	ld   hl, BG_CHARSEL_P1ICON1
	ld   c, TILE_CHARSEL_ICONEMPTY2
	jp   .go
.blank3:
	; Blank out the icon for the third slot.
	ld   hl, BG_CHARSEL_P1ICON2
	ld   c, TILE_CHARSEL_ICONEMPTY3
.go:
	call CharSel_DrawEmptyIcon
	ret
	
; =============== CharSel_ClearTopIcon2P ===============
; Clears the icon for the deselected character, replacing it with the numeric placeholder.
; IN
; - B: Updated number of selected characters	
CharSel_ClearTopIcon2P:
	ld   a, b
	cp   $01			; Is there 1 selected character now (down from 2)?
	jp   z, .blank2		; If so, jump
	cp   $02			; Are there 2 selected characters now (down from 3)?
	jp   z, .blank3		; If so, jump
	; Otherwise, there are no selected characters (down from 1).
.blank1:
	; Blank out the icon for the first slot.
	ld   hl, BG_CHARSEL_P2ICON0
	ld   c, TILE_CHARSEL_ICONEMPTY1
	jp   .go
.blank2:
	; Blank out the icon for the second slot.
	ld   hl, BG_CHARSEL_P2ICON1
	ld   c, TILE_CHARSEL_ICONEMPTY2
	jp   .go
.blank3:
	; Blank out the icon for the third slot.
	ld   hl, BG_CHARSEL_P2ICON2
	ld   c, TILE_CHARSEL_ICONEMPTY3
.go:
	call CharSel_DrawEmptyIcon
	ret

; =============== CharSel_DrawEmptyIcon ===============
; Draws an empty 2x2 square, for blank slots in the list of selected characters.
; Used when initializing the character select screen, or when removing a selected character.
; - HL: Ptr to tilemap
; - C: Base tile ID (TILE_CHARSEL_ICONEMPTY*)
;      The icon will use the four next tiles starting from this one.
CharSel_DrawEmptyIcon:
	mWaitForVBlankOrHBlank
	
	; Top left corner -> TileId
	ld   a, c		
	ldi  [hl], a	; BGPtr++
	inc  a		
	; Top right corner -> TileId+1	
	ldd  [hl], a	; BGPtr--
	inc  a
	
	; Move down 1 tile
	ld   de, BG_TILECOUNT_H	; BgPtr += $20
	add  hl, de
	
	; Wait for next HBlank
	push af
		mWaitForVBlankOrHBlank
	pop  af
	
	; Bottom left corner -> TileId+2
	ldi  [hl], a
	inc  a
	
	; Bottom right corner -> TileId+3
	ld   [hl], a
	ret
	
; =============== CharSel_AddChar ===============
; Adds the character the cursor is placed on to the team.
CharSel_AddChar:
	; Default with $00, to mark that further characters are selectable
	ld   a, CHARSEL_TEAM_REMAIN
	ld   [wCharSelTeamFull], a
	
	; Depending on the current player...
	ld   a, [wCharSelCurPl]
	or   a
	jp   nz, .pl2
.pl1:
	ld   de, wCharSelP1Char0			; DE = 1st char in 1P team
	ld   a, [wCharSelP1CursorPos]		; C = Selected portrait id
	ld   c, a
	call CharSel_AddCharToFirstFreeSlot	; Was the character added?
	jp   c, .ret						; If not, return
	; Otherwise, draw icon and play its specific SFX
	call CharSel_DrawP1CharIconForNew	
	ld   a, SFX_CHARSELECTED
	call HomeCall_Sound_ReqPlayExId
	jp   .ret
.pl2:
	ld   de, wCharSelP2Char0			; DE = 1st char in 2P team
	ld   a, [wCharSelP2CursorPos]		; C = Selected portrait id
	ld   c, a
	call CharSel_AddCharToFirstFreeSlot	; Was the character added?
	jp   c, .ret						; If not, return
	; Otherwise, draw icon and play its specific SFX
	call CharSel_DrawP2CharIconForNew
	ld   a, SFX_CHARSELECTED
	call HomeCall_Sound_ReqPlayExId
.ret:
	ret
	
; =============== CharSel_AddCharToFirstFreeSlot ===============
; Adds the specified character to the first free team slot.
; IN
; - DE: Ptr to first character in team
; - C: Portrait ID
; OUT
; - B: Team slot number the character was added to (0-based)
; - C flag: If set, the character couldn't be added
CharSel_AddCharToFirstFreeSlot:
	; C = ID of the character we want to add
	ld   a, c
	call CharSel_GetCharIdByPortraitId
	ld   c, a				; Save CharID
	
	;
	; In team mode, prevent selecting duplicate characters,
	; unless the cheat for it is enablead.
	;
	call IsInTeamMode		; Are we in team mode?
	jp   nc, .single		; If not, jump
	ld   a, [wDipSwitch]
	bit  DIPB_TEAM_DUPL, a	; Allow selecting duplicate characters?
	jp   nz, .teamSet		; If so, skip check
	
	ld   a, c				; A = CharID
	push de
	pop  hl					; HL = wCharSelP*Char0
	
	; If the character is already in the team, return
	cp   a, [hl]			; Is it already the first member?
	jp   z, .noAdd			; If so, jump
	inc  hl
	cp   a, [hl]			; 2
	jp   z, .noAdd
	inc  hl
	cp   a, [hl]			; 3
	jp   z, .noAdd
	; OK
	jp   .teamSet
.single:
	ld   b, $00				; Slot 0 (only one)
	
	; In single mode, only one character can be selected, so only wCharSelP*Char0 is checked.
	
	;--
	; This can never jump, as this is never called when a character is already selected.
	ld   a, CHAR_ID_NONE	; Comparison value
	push de
	pop  hl					; HL = First slot
	cp   a, [hl]			; Is this slot free?
	jp   nz, .noAdd			; If not, jump
	;--
	
	; Write the char ID to the first slot
	ld   a, c
	ld   [hl], a
	; Mark that no further characters can be added
	ld   a, CHARSEL_TEAM_FILLED
	ld   [wCharSelTeamFull], a
	; C flag cleared, added OK
	xor  a
	ret
	
.teamSet:
	ld   b, $00				; Slot 0
	
	; Find the first free slot in the team
	ld   a, CHAR_ID_NONE	; A = Comparison value (no char)
	push de
	pop  hl					; HL = Ptr to first slot
	;--
	cp   a, [hl]			; Is the first char slot empty?
	jp   z, .setSlot		; If so, write CharID here
	inc  hl					; Otherwise, check the next
	inc  b					; Slot 1
	;--
	cp   a, [hl]			; Is the second char slot empty?
	jp   z, .setSlot		; If so, write CharID here
	inc  hl					; Otherwise, check the next
	inc  b					; Slot 2
	
	;--
	; This can never jump, as this is never called when the team is full
	cp   a, [hl]			; Is the second char in the team set?
	jp   nz, .noAdd			; If so, don't add anything
	;--
	; Mark that no further characters can be added
	ld   a, CHARSEL_TEAM_FILLED
	ld   [wCharSelTeamFull], a
.setSlot:
	; Write the char ID to the picked slot
	ld   a, c
	ld   [hl], a			
	; C flag cleared, added OK
	xor  a
	ret
.noAdd:
	; C flag set, not added
	scf
	ret
	
; =============== CharSel_DrawP1CharIconForNew ===============
; Draws the icon for a newly selected character on the 1P side.
;
; IN
; - B: Slot number (0-based)
; - C: Character ID
CharSel_DrawP1CharIconForNew:
	;
	; Depending on the slot the character was added to, pick a different location
	; and tile numbers to draw the icon to.
	;
	ld   a, b
	cp   $01			; Is this the second character in the team?
	jp   z, .char1		; If so, jump
	cp   $02			; Is this the third character in the team?
	jp   z, .char2		; If so, jump
	
	; Otherwise, it's the first.
	; In single mode, this is the only one available.
.char0:
	ld   a, c						; A = Character ID
	ld   de, $8F80					; DE = GFX Ptr
	ld   hl, $99E2					; HL = Tilemap ptr
	ld   c, TILE_CHARSEL_P1ICON0	; C = Tile ID pointing to DE
	jp   .draw
.char1:
	ld   a, c
	ld   de, $91F0
	ld   hl, $99E4
	ld   c, TILE_CHARSEL_P1ICON1
	jp   .draw
.char2:
	ld   a, c
	ld   de, $9230
	ld   hl, $99E6
	ld   c, TILE_CHARSEL_P1ICON2
.draw:
	call CharSel_DrawP1CharIcon
	ret
	
; =============== CharSel_DrawP2CharIconForNew ===============
; Draws the icon for a newly selected character on the 2P side.
; See also: CharSel_DrawP1CharIconForNew
;
; IN
; - B: Slot number (0-based)
; - C: Character ID
CharSel_DrawP2CharIconForNew:
	ld   a, b
	cp   $01
	jp   z, .char1
	cp   $02
	jp   z, .char2
.char0:
	ld   a, c
	ld   de, $8FC0
	ld   hl, $99F1
	ld   c, TILE_CHARSEL_P2ICON0
	jp   .draw
.char1:
	ld   a, c
	ld   de, $9270
	ld   hl, $99EF
	ld   c, TILE_CHARSEL_P2ICON1
	jp   .draw
.char2:
	ld   a, c
	ld   de, $92B0
	ld   hl, $99ED
	ld   c, TILE_CHARSEL_P2ICON2
.draw:
	call CharSel_DrawP2CharIcon
	ret
	
; =============== CharSel_DrawP1CharIcon ===============
; Draws the icon for the specified character on the player 1 side to the tilemap.
;
; The reason this doesn't reuse CharSel_DrawEmptyIcon is because the graphics
; for the empty number icons are always loaded to VRAM at fixed locations.
;
; The graphics for the actual character icons instead are written to VRAM dynamically
; as they are requested, over parts of the 1bpp font not used in the character select screen,
; and may be loaded at different locations.
;
; IN	
; - DE: Ptr to GFX ptr in VRAM
; - HL: Ptr to top-*right* corner of the icon in the tilemap
;       This is because 
; - C: Tile number DE points to
; - A: Character ID to draw
CharSel_DrawP1CharIcon:
	push af
	sla  a					; A *= 2
	call Char_DrawIconFlipX
	pop  af
	ret
	
; =============== CharSel_DrawP2CharIcon ===============
; Draws the icon for the specified character on the player 2 side to the tilemap.
CharSel_DrawP2CharIcon:
	push af
	sla  a					; A *= 2
	call Char_DrawIcon
	pop  af
	ret
	
; =============== CharSel_GetCharIdByPortraitId ===============
; Gets the character ID from the specified cursor position ID,
; without the extra flags stored in the upper bits.
;
; IN
; - A: Portrait ID (CHARSEL_ID_*)
; OUT
; - A: Character ID (CHAR_ID_*)
CharSel_GetCharIdByPortraitId:
	push hl
	push de
	
	; CharID = wCharSelIdMapTbl[A] & $3F
	
	ld   hl, wCharSelIdMapTbl	; HL = wCharSelIdMapTbl
	ld   d, $00					; DE = A
	ld   e, a
	add  hl, de					; Index the thing
	ld   a, [hl]				; A = Character ID + flags
	and  a, $3F					; Filter away flags (why not filter by $1F)? 
	
	pop  de
	pop  hl
	ret
	
; =============== CharSel_GetInput ===============
; Gets the player input for the character select screen.
; This merges the key info from the delayed held input fields set in JoyKeys_DoCursorDelayTimer.
; See also: Title_GetMenuInput
; OUT
; - A: Newly pressed KEY_*
; - B: Intermittent KEY_*
; - C: Held KEY_*
CharSel_GetInput:

	;
	; Pick the controller from the active side
	;
	ld   a, [wCharSelCurPl]
	cp   CHARSEL_1P			; Playing as player 1?
	jp   nz, .pl2			; If not, jump
.pl1:
	ld   hl, hJoyKeys
	jp   .go
.pl2:
	ld   hl, hJoyKeys2
.go:
	ld   c, [hl]		; C = Held keys
	inc  hl				; Seek to hJoyNewKeys
	ld   a, [hl]		; A = Newly held keys
	
	push af
		push bc
			inc  hl
			inc  hl					; Seek to hJoyKeysDelayTbl
			
			;
			; Merge back the bits in the 8 iKeyMenuHeld fields into a into a KEY_* bitmask.
			;
			
			; For each DelayTbl entry mark the MSB if needed and rotate left.
			
			ld   b, $00				; B = Output KEY_* mask
			ld   c, $08				; C = Bits in byte
		.loop:
			ldi  a, [hl]			; A = iKeyMenuHeld
			inc  hl					; Skip to next entry
			; Only use key entries with value $01, which means that either:
			; - The key was just pressed
			; - The delay countdown reached 0, which set the key entry to $01
			cp   $01				; iKeyMenuHeld == $01?
			jp   nz, .next			; If not, skip
			set  7, b				; Set the MSB
		.next:
			rlc  b					; Next bit (<<R 1)
			dec  c					; BitsLeft--
			jp   nz, .loop			; Are we done? If not, loop	

			ld   d, b		; Save B
		pop  bc				; Restore C
		ld   b, d			; Restore B
	pop  af
	ret
; =============== CharSel_DrawCrossOnDefeatedChars ===============
; Draws an X over all portraits of defeated characters.
; This is done for characters in the sequence $00-$0E, which is up to and excluding Kagura.
; Characters from Kagura and above don't have a CHARSEL_ID_* value in the sequence anyway.
CharSel_DrawCrossOnDefeatedChars:
	ld   hl, wCharSeqTbl	; HL = Stage sequence table
	ld   b, $0F				; HL = Number of slots remaining
.loop:
	ldi  a, [hl]			; A = Char portrait ID
	push bc
	push hl
	call .drawCross
	pop  hl
	pop  bc
	dec  b					; Next char
	jp   nz, .loop			; Processed all chars? If not, loop
	ret
; IN
; - A: CHARSEL_ID_* value
; - HL: Ptr to start of wCharSeqTbl 
.drawCross:
	bit  CHARSEL_POSFB_DEFEATED, a	; Did we beat this opponent yet?
	ret  z							; If not, return
	and  a, $FF^CHARSEL_POSF_DEFEATED	; Filter out flag to get real cursor pos id
	sla  a							; A *= 2
	ld   de, CharSel_IdTilesMapTbl	; DE = Table of VRAM pointers
	ld   h, $00						; HL = A * 2
	ld   l, a
	add  hl, de						; Index it
	ld   e, [hl]					; DE = Ptr to portrait GFX in VRAM
	inc  hl
	ld   d, [hl]
	ld   hl, GFXDef_CharSel_Cross	; HL = Ptr to (Tile count + cross GFX)
	ld   bc, GFX_CharSel_Cross_Mask	; DE = Ptr to transparency mask
	call CopyTilesOver				; Draw the cross
	ret
	
; =============== CharSel_IdTilesMapTbl ===============
; This table maps portrait IDs to the position of their portrait GFX in VRAM.
;
; Specifically, this maps CHARSEL_ID_*, which are commonly used in the character select
; in place of real character IDs as they correspond to the order of characters in the
; character select screen.
;
; These pointers of course are based on the location GFX_CharSel_BG0 and GFXLZ_CharSel_BG1 are loaded to.
;
; [TCRF] These also contain unique pointers for Mr. Karate and Goenitz, which aren't possible
;        to see normally.
CharSel_IdTilesMapTbl:
	dw $92F0 ; CHARSEL_ID_KYO      
	dw $9380 ; CHARSEL_ID_ANDY     
	dw $9410 ; CHARSEL_ID_TERRY    
	dw $94A0 ; CHARSEL_ID_RYO      
	dw $9530 ; CHARSEL_ID_ROBERT   
	dw $95C0 ; CHARSEL_ID_IORI     
	dw $9650 ; CHARSEL_ID_DAIMON   
	dw $96E0 ; CHARSEL_ID_MAI      
	dw $9770 ; CHARSEL_ID_GEESE    
	dw $8800 ; CHARSEL_ID_MRBIG    
	dw $8890 ; CHARSEL_ID_KRAUSER  
	dw $8920 ; CHARSEL_ID_MATURE   
	dw $89B0 ; CHARSEL_ID_ATHENA   
	dw $8A40 ; CHARSEL_ID_CHIZURU  
	dw $8AD0 ; CHARSEL_ID_MRKARATE0 (impossible to see)
	dw $8B60 ; CHARSEL_ID_MRKARATE1 (impossible to see)
	dw $8BF0 ; CHARSEL_ID_GOENITZ   (impossible to see)
	dw $8C80 ; CHARSEL_ID_LEONA    
	
; =============== CharSel_RefreshNameAndCursor ===============
; Updates the character name and cursor sprite for the specified portrait.
; This is called after the cursor is moved, to update the tilemap and sprites.
; IN
; - A: Portrait ID
; - DE: Ptr to wOBJInfo
CharSel_RefreshNameAndCursor:
	; Display the character name
	push af
		call CharSel_GetCharIdByPortraitId
		call CharSel_PrintCharName
	pop  af
	; Fall-through
	
; =============== CharSel_RefreshCursor ===============
; Displays the cursor over the specified portrait.
; IN
; - A: Portrait ID
; - DE: Ptr to wOBJInfo
CharSel_RefreshCursor:

	;
	; Determine the size of the cursor to display.
	; In practice, Mr. Karate is the only character to have a wide portrait,
	; who as a result has two portrait "slots".
	;
	
	cp   CHARSEL_ID_MRKARATE0	; Cursor over Mr. Karate?
	jp   z, .wide				; If so, jump
	cp   CHARSEL_ID_MRKARATE1	; ""
	jp   z, .wide				; ""
.normal:
	; Otherwise, we're on a normal sized tile.
	; A = iOBJInfo_CharSel_CursorOBJId
	push af
		ld   hl, iOBJInfo_CharSel_CursorOBJId
		add  hl, de				
		ld   a, [hl]			
		jp   .setInfo
.wide:
	; A = iOBJInfo_CharSel_CursorWideOBJId
	push af
		ld   hl, iOBJInfo_CharSel_CursorWideOBJId
		add  hl, de
		ld   a, [hl]	
		
	.setInfo:
		; Copy A to the sprite mapping ID field
		ld   hl, iOBJInfo_OBJLstPtrTblOffset
		add  hl, de
		ld   [hl], a
	pop  af
	
	;
	; Determine the X and Y positions of the cursor.
	; This is determined by a table of coordinates.
	;
	push bc
	
		; Seek to the table entry.
		sla  a				; PicId * 2 since entries are 2 bytes
		ld   bc, CharSel_CursorPosTable	; BC = Table start
		ld   h, $00			; HL = A
		ld   l, a
		add  hl, bc			; Offset the table
		push hl
		pop  bc				; Move result to BC
		
		; 
		ld   hl, iOBJInfo_X	; Seek to iOBJInfo_X
		add  hl, de
		ld   a, [bc]		; Read X position from byte0
		ld   [hl], a		; Write it
		inc  bc				; Seek to byte1
		ld   hl, iOBJInfo_Y	; Seek to iOBJInfo_Y
		add  hl, de
		ld   a, [bc]		; Read Y position from byte1
		ld   [hl], a		; Write it
	pop  bc
	ret
	
; =============== CharSel_CursorPosTable ===============
; Maps portrait IDs to cursor sprite positions.
CharSel_CursorPosTable:
	db $00,$00 ; CHARSEL_ID_KYO      
	db $18,$00 ; CHARSEL_ID_ANDY     
	db $30,$00 ; CHARSEL_ID_TERRY    
	db $48,$00 ; CHARSEL_ID_RYO      
	db $60,$00 ; CHARSEL_ID_ROBERT   
	db $78,$00 ; CHARSEL_ID_IORI     
	db $00,$18 ; CHARSEL_ID_DAIMON   
	db $18,$18 ; CHARSEL_ID_MAI      
	db $30,$18 ; CHARSEL_ID_GEESE    
	db $48,$18 ; CHARSEL_ID_MRBIG    
	db $60,$18 ; CHARSEL_ID_KRAUSER  
	db $78,$18 ; CHARSEL_ID_MATURE   
	db $00,$30 ; CHARSEL_ID_ATHENA   
	db $18,$30 ; CHARSEL_ID_CHIZURU
	; Mr. Karate has a trick -- the same position is used for both slots.
	; Even if they look identical, having two different slots prevents the cursor from jumping
	; to another column when scrolling up.
	db $30,$30 ; CHARSEL_ID_MRKARATE0
	db $30,$30 ; CHARSEL_ID_MRKARATE1
	db $60,$30 ; CHARSEL_ID_GOENITZ  
	db $78,$30 ; CHARSEL_ID_LEONA  
	; [TCRF] The secret characters accessible by flipping the portraits
	;        reuse the previous portrait IDs, leaving these unreachable.
	db $78,$00 ; CHARSEL_ID_SPEC_OIORI 
	db $78,$30 ; CHARSEL_ID_SPEC_OLEONA
	db $18,$30 ; CHARSEL_ID_SPEC_KAGURA
; =============== CharSel_PrintCharName ===============
; Writes the name for the specified character to the tilemap.
; IN
; -  A: Character ID
; - DE: Ptr to start of wOBJInfo, marks player
CharSel_PrintCharName:
	push af
		push de
			ld   b, a			; B = CharId
			
			; Determine the player we're printing text for through wOBJInfo's location.
			; This is checked since player 1 and player 2 align the text differently.
			ld   a, LOW(wOBJInfo_Pl1)	; A = Player 1 location
			cp   a, e					; Does it match with what we sent?
			jp   nz, .pl2				; If not, it's player 2
			
		.pl1:
			; Blank out the old name
			push bc
				ld   hl, TextC_Char_None
				ld   de, $99A1
				call TextPrinter_Instant_CustomPos
			pop  bc
			
			; Player 1 aligns the name to the left.
			; There's nothing special to do, the starting location is always the same.
			ld   de, $99A1
			jp   .printString
			
		.pl2:
			; Blank out the old name
			push bc
				ld   hl, TextC_Char_None
				ld   de, $99B3-$08
				call TextPrinter_Instant_CustomPos
			pop  bc
			
			; Player 2 aligns the name to the right.
			
			; The strings here aren't padded (as they are shared between players),
			; so the starting location depends on the character and is obtained through a table.
			; DE = CharSel_CharNameBGPtrTbl[CharId]
			push bc
				ld   a, b							; A = CharId * 2
				sla  a
				ld   bc, CharSel_CharNameBGPtrTbl	; BC = VRAM Ptr table
				ld   h, $00							; HL = A
				ld   l, a
				add  hl, bc							; Index it
				ld   e, [hl]						; Read it out to DE
				inc  hl
				ld   d, [hl]
			pop  bc
			
		.printString:
			; Get the ptr to the TextC structure off the table
			; HL = CharSel_CharNamePtrTable[CharId]
			ld   a, b							; A = CharId * 2
			sla  a
			ld   bc, CharSel_CharNamePtrTable	; BC = Text ptr table
			ld   h, $00							; HL = A
			ld   l, a
			add  hl, bc							; Index it
			ld   c, [hl]						; Read it out to BC
			inc  hl
			ld   b, [hl]
			push bc
			pop  hl								; Move it to HL
			
			; HL = Ptr to TextC structure
			; DE = Tilemap ptr
			call TextPrinter_Instant_CustomPos
		pop  de
	pop  af
	ret
; =============== CharSel_CharNameBGPtrTbl ===============
; Ptr table to the starting tilemap positions on 2P side, indexed by character ID.
; The pointer for each character should always be equal to $99B3-(name length).
CharSel_CharNameBGPtrTbl:
	dw $99B0 ; CHAR_ID_KYO     
	dw $99AD ; CHAR_ID_DAIMON  
	dw $99AE ; CHAR_ID_TERRY   
	dw $99AF ; CHAR_ID_ANDY    
	dw $99B0 ; CHAR_ID_RYO     
	dw $99AD ; CHAR_ID_ROBERT  
	dw $99AD ; CHAR_ID_ATHENA  
	dw $99B0 ; CHAR_ID_MAI     
	dw $99AE ; CHAR_ID_LEONA   
	dw $99AE ; CHAR_ID_GEESE   
	dw $99AC ; CHAR_ID_KRAUSER 
	dw $99AE ; CHAR_ID_MRBIG   
	dw $99AF ; CHAR_ID_IORI    
	dw $99AD ; CHAR_ID_MATURE  
	dw $99AC ; CHAR_ID_CHIZURU 
	dw $99AC ; CHAR_ID_GOENITZ 
	dw $99AB ; CHAR_ID_MRKARATE
	dw $99AE ; CHAR_ID_OIORI   
	dw $99AD ; CHAR_ID_OLEONA  
	dw $99AD ; CHAR_ID_KAGURA  
; =============== CharSel_CharNamePtrTable ===============
; Ptr table to the character names, indexed by character ID.
CharSel_CharNamePtrTable:
	dw TextC_Char_Kyo
	dw TextC_Char_Daimon
	dw TextC_Char_Terry
	dw TextC_Char_Andy
	dw TextC_Char_Ryo
	dw TextC_Char_Robert
	dw TextC_Char_Athena
	dw TextC_Char_Mai
	dw TextC_Char_Leona
	dw TextC_Char_Geese
	dw TextC_Char_Krauser
	dw TextC_Char_MrBig
	dw TextC_Char_Iori
	dw TextC_Char_Mature
	dw TextC_Char_Chizuru
	dw TextC_Char_Goenitz
	dw TextC_Char_MrKarate
	dw TextC_Char_OIori
	dw TextC_Char_OLeona
	dw TextC_Char_Kagura

; =============== TextC_Char_* ===============
; Lite versions of TextDef which lack the tilemap offset, as they are passed to TextPrinter_Instant_CustomPos.

; Empty line used to clear out the old character name.
TextC_Char_None:
	db .end-.start
.start:
	db "        "
.end:
; Actual player names.
TextC_Char_Kyo:
	db .end-.start
.start:
	db "KYO"
.end:
TextC_Char_Daimon:
	db .end-.start
.start:
	db "DAIMON"
.end:
TextC_Char_Terry:
	db .end-.start
.start:
	db "TERRY"
.end:
TextC_Char_Andy:
	db .end-.start
.start:
	db "ANDY"
.end:
TextC_Char_Ryo:
	db .end-.start
.start:
	db "RYO"
.end:
TextC_Char_Robert:
	db .end-.start
.start:
	db "ROBERT"
.end:
TextC_Char_Athena:
	db .end-.start
.start:
	db "ATHENA"
.end:
TextC_Char_Mai:
	db .end-.start
.start:
	db "MAI"
.end:
TextC_Char_Leona:
	db .end-.start
.start:
	db "LEONA"
.end:
TextC_Char_Geese:
	db .end-.start
.start:
	db "GEESE"
.end:
TextC_Char_Krauser:
	db .end-.start
.start:
	db "KRAUSER"
.end:
TextC_Char_MrBig:
	db .end-.start
.start:
	db "M@BIG"
.end:
TextC_Char_Iori:
	db .end-.start
.start:
	db "IORI"
.end:
TextC_Char_Mature:
	db .end-.start
.start:
	db "MATURE"
.end:
TextC_Char_Chizuru:
	db .end-.start
.start:
	db "CHIZURU"
.end:
TextC_Char_Goenitz:
	db .end-.start
.start:
	db "GOENITZ"
.end:
TextC_Char_MrKarate:
	db .end-.start
.start:
	db "M<r.>KARATE"
.end:
TextC_Char_OIori:
	db .end-.start
.start:
	db "IORI`"
.end:
TextC_Char_OLeona:
	db .end-.start
.start:
	db "LEONA`"
.end:
TextC_Char_Kagura:
	db .end-.start
.start:
	db "KAGURA"
.end:
; =============== CharSel_AnimCursorPalFast ===============
; Cycles the cursor palette fast, used when still selecting something.
; OUT
; - Z: If set, the cursor isn't visible
CharSel_AnimCursorPalFast:
	; A = (Timer % 8) / 2
	ld   a, [wTimer]
	and  a, $07
	srl  a			; / 2 for fast speed
	jp   CharSel_AnimCursorPal
; =============== CharSel_AnimCursorPalSlow ===============
; Cycles the cursor palette slowly, used after selecting all characters.
; OUT
; - Z: If set, the cursor isn't visible
CharSel_AnimCursorPalSlow:
	; A = (Timer % $10) / 4
	ld   a, [wTimer]
	and  a, $0F
	srl  a			; / 2 for slow speed
	srl  a
; =============== CharSel_AnimCursorPal ===============
; IN
; - A: Palette ID (0-3)
; OUT
; - Z: If set, the cursor isn't visible
CharSel_AnimCursorPal:
	cp   $01			; A == 1?
	jp   z, .pal1		; If so, jump
	cp   $02			; ...
	jp   z, .pal2
	cp   $03
	jp   z, .pal3
	; Otherwise, A == 0
.pal0:
	ld   a, $3C			; A = OBP pal 0
	jp   .setPal
.pal1:
	ld   a, $34
	jp   .setPal
.pal2:
	ld   a, $F0
	jp   .setPal
.pal3:
	ld   a, $F4
	
.setPal:
	ld   hl, wCharSelCurPl
	bit  0, [hl]			; Are we player 1?
	jp   nz, .pl2			; If not, jump
.pl1:
	; If the 1P cursor isn't visible, return
	push af
		ld   a, [wOBJInfo_Pl1+iOBJInfo_Status]
		ld   b, a			; B = Status flags
	pop  af
	bit  OSTB_VISIBLE, b	; Is the visibility flag set?
	ret  z					; If not, return
	; Set the previously specified palette
	ldh  [rOBP0], a
	ret
.pl2:
	; If the 2P cursor isn't visible, return
	push af
		ld   a, [wOBJInfo_Pl2+iOBJInfo_Status]
		ld   b, a			; B = Status flags
	pop  af
	bit  OSTB_VISIBLE, b	; Is the visibility flag set?
	ret  z					; If not, return
	; Set the previously specified palette
	ldh  [rOBP1], a
	ret
	
; =============== CharSel_BlinkStartText ===============
; Blinks the "START" text under the character icons.
CharSel_BlinkStartText:

	; Alternate every 8 frames between showing and hiding the string
	ld   a, [wTimer]
	bit  3, a						; (wTimer & 8) != 0?
	jp   nz, CharSel_PrintStartText	; If so, jump
	; Fall-through
	
; =============== CharSel_HideStartText ===============
; Hides the START text for the current character.
CharSel_HideStartText:
	ld   hl, TextC_CharSel_StartBlank
	
	; Different tilemap ptr between players
	ld   a, [wCharSelCurPl]
	bit  0, a				; Handling player 1? (CurPl == 0)
	jp   nz, .pl2			; If not, jump
.pl1:
	ld   de, $9A21
	jp   .print
.pl2:
	ld   de, $9A2E
.print:
	call TextPrinter_Instant_CustomPos
	ret
	
; =============== CharSel_PrintStartText ===============
; Displays the START text for the current character.
CharSel_PrintStartText:
	ld   hl, TextC_CharSel_Start
	; Different tilemap ptr between players
	ld   a, [wCharSelCurPl]
	bit  0, a				; Handling player 1? (CurPl == 0)
	jp   nz, .pl2		; If not, jump
.pl1:
	ld   de, $9A21
	jp   .print
.pl2:
	ld   de, $9A2E
.print:
	call TextPrinter_Instant_CustomPos
	ret
	
TextC_CharSel_Start:
	db .end-.start
.start:
	db "START"
.end:
TextC_CharSel_StartBlank:
	db .end-.start
.start:
	db "     "
.end:
	
; =============== CharSel_HideCursor ===============
; Hides the cursor for the current player.
CharSel_HideCursor:
	ld   a, [wCharSelCurPl]
	or   a					; wCharSelCurPl == CHARSEL_1P?
	jp   nz, .pl2			; If not, jump
.pl1:
	ld   hl, wOBJInfo_Pl1+iOBJInfo_Status
	res  OSTB_VISIBLE, [hl]
	ret
.pl2:;J
	ld   hl, wOBJInfo_Pl2+iOBJInfo_Status
	res  OSTB_VISIBLE, [hl]
	ret
	
; =============== CharSel_SetPlInfo ===============
; Sets the selected characters into the player struct (wPlInfo).
CharSel_SetPlInfo:
	ld   a, [wCharSelCurPl]
	or   a					; wCharSelCurPl == CHARSEL_1P?
	jp   nz, .pl2			; If not, jump
.pl1:
	; Set the first team member for 1P, which always exist.
	;
	; Note that the character IDs written to the player struct are
	; all multiplied by 2, to work as-is with ptr tables.
	ld   de, wCharSelP1Char0		; DE = Ptr to 1st team member
	ld   a, [de]					; A = CharId * 2
	sla  a
	
	; Copy to current character ID (first to fight)
	ld   hl, wPlInfo_Pl1+iPlInfo_CharId
	ld   [hl], a
	; Write to 1st team member ID
	ld   hl, wPlInfo_Pl1+iPlInfo_TeamCharId0
	ld   [hl], a
	jp   .setOther
.pl2:
	; Like the other, but for 2P
	ld   de, wCharSelP2Char0
	ld   a, [de]
	sla  a
	
	ld   hl, wPlInfo_Pl2+iPlInfo_CharId
	ld   [hl], a
	
	ld   hl, wPlInfo_Pl2+iPlInfo_TeamCharId0
	ld   [hl], a
	
.setOther:
	;
	; Write the 2nd and 3rd team members, which may not exist in case of CPU bosses or single mode.
	; In those cases, both characters are set to the magic value CHAR_ID_NONE.
	;
	
	; Switch to 2nd team member
	inc  hl			; Seek to iPlInfo_TeamCharId1
	inc  de			; Seek to wCharSelP*Char1
	ld   b, 3-1		; B = Remaining characters
.loop:
	; Do not multiply the CHAR_ID_NONE marker.
	ld   a, [de]		; A = CharId
	cp   CHAR_ID_NONE	; Is this an empty slot?
	jr   z, .noMul		; If so, jump
	sla  a				; CharId *= 2
.noMul:
	ld   [hl], a		; Write it
	inc  hl				; Next team member
	inc  de				; ""
	dec  b				; Copied all other members?
	jp   nz, .loop		; If not, loop
	ret
	
; =============== CharSel_DrawUnlockedChars ===============
; Draws all of the portraits for unlocked characters.
; This also sets the values that prevent the cursor from moving over
; the locked characters.
CharSel_DrawUnlockedChars:
	; Go in the CHARSEL_ID_* order, since it's the order of the characters
	ld   b, $00		; B = Starting character id
	ld   c, $00		; C = Starting tile id base
.loop:

	;
	; Hide locked characters.
	;
	; Hiding locked characters is simply accomplished by skipping the
	; call to draw the portrait to the tilemap.
	; Additionally, it also sets the wCharSelIdMapTbl entries for locked
	; characters to CHAR_ID_NONE, which prevents access to those.
	;

	; Mr. Karate is only drawn when the "All Characters" dip switch is set
	ld   a, b
	cp   CHARSEL_ID_MRKARATE0	; Trying to draw the first part of Mr. Karate's portrait?
	jp   z, .chkUnlockMrKarate	; If so, jump
	cp   CHARSEL_ID_MRKARATE1	; Trying to draw the second part of Mr. Karate's portrait?
	jp   z, .chkUnlockMrKarate	; If so, jump
	jp   .chkGoenitz			; Skip ahead
.chkUnlockMrKarate:
	ld   a, [wDipSwitch]
	bit  DIPB_UNLOCK_OTHER, a	; Are all characters unlocked?
	jp   nz, .charOk			; If so, jump
	; Otherwise, disable his slots and skip him
	ld   a, CHAR_ID_NONE
	ld   [wCharSelIdMapTbl+CHARSEL_ID_MRKARATE0], a
	ld   [wCharSelIdMapTbl+CHARSEL_ID_MRKARATE1], a
	jp   .nextChar
.chkGoenitz:
	ld   a, b
	cp   CHARSEL_ID_GOENITZ		; Trying to draw Goenitz's portrait?
	jp   z, .chkUnlockGoenitz	; If so, jump
	jp   .charOk				; Everything else can be drawn
.chkUnlockGoenitz:
	ld   a, [wDipSwitch]
	bit  DIPB_UNLOCK_GOENITZ, a	; Is Goenitz unlocked?
	jp   nz, .charOk			; If so, jump
	; Otherwise, disable his slot and skip him
	ld   a, CHAR_ID_NONE
	ld   [wCharSelIdMapTbl+CHARSEL_ID_GOENITZ], a
	jp   .nextChar
.charOk:
	push bc
	call CharSel_DrawPortrait
	pop  bc
.nextChar:
	; Set the info for the next portrait.
	; Each portrait uses 9 continuous tiles, and they are also ordered by CHARSEL_ID_* in the GFX.
	; Therefore, increasing the TileId offset by 9 is all that's needed to seek to the next. 
	ld   a, $09				; TileId += 9
	add  c					
	ld   c, a
	inc  b					; Next portrait id
	ld   a, b
	cp   CHARSEL_ID_LEONA+1	; Went past the last valid portrait?
	jp   nz, .loop			; If so, jump
	ret
	
; =============== CharSel_DrawPortrait ===============
; Draws a character portrait.
;
; IN
; - B: Portrait ID (CHARSEL_ID_*)
;      Determines the portrait position.
; - C: Base tile ID.
;      This is supplied separately because some portraits are used by multiple characters
;      (ie: Iori / Orochi Iori)
CharSel_DrawPortrait:
	;
	; Index CharSel_IdBGMapTbl with B and read out its pointer to HL.
	; 
	ld   hl, CharSel_IdBGMapTbl	; HL = Map index
	ld   a, b					; A = L + (CharselId * 2)			
	sla  a
	add  a, l
	jp   nc, .noInc				; Did we overflow? If not, skip
	inc  h						; If so, H++ (never happens)
.noInc:
	ld   l, a					; HL = CharSel_IdBGMapTbl entry
	; Read out the tilemap ptr to DE
	ld   e, [hl]				
	inc  hl
	ld   d, [hl]				
	push de						; And move it to HL
	pop  hl						; HL = Tilemap ptr
	
	;
	; Draw the portrait.
	; The tilemap for the portrait is always the same as it uses 9 consecutive tiles.
	; What makes the difference is the base tile ID CopyBGToRectWithBase.
	;
	ld   de, BG_CharSel_Portrait; DE = Relative tile IDs
	ld   a, c					; A = Tile ID base
	ld   b, $03					; B = Portrait width
	ld   c, $03					; C = Portrait height
	call CopyBGToRectWithBase
	ret
	
; =============== CharSel_ClearPortrait ===============
; Clears a character portrait.
; See also: CharSel_DrawPortrait
;
; IN
; - B: Portrait ID (CHARSEL_ID_*)
;      Determines the portrait position.
; - C: Base tile ID. 
;      Should always be $00, pointing to a black tile.
CharSel_ClearPortrait:
	;
	; Index CharSel_IdBGMapTbl with B and read out its pointer to HL.
	; 
	ld   hl, CharSel_IdBGMapTbl	; HL = Map index
	ld   a, b					; A = L + (CharselId * 2)			
	sla  a
	add  a, l
	jp   nc, .noInc				; Did we overflow? If not, skip
	inc  h						; If so, H++ (never happens)
.noInc:
	ld   l, a					; HL = CharSel_IdBGMapTbl entry
	; Read out the tilemap ptr to DE
	ld   e, [hl]				
	inc  hl
	ld   d, [hl]				
	push de						; And move it to HL
	pop  hl						; HL = Tilemap ptr
	
	; Replace the 3x3 portrait area with black tiles
	ld   de, BG_CharSel_EmptyPortrait
	ld   a, c
	ld   b, $03
	ld   c, $03
	call CopyBGToRectWithBase
	ret
	
; =============== CharSel_IdBGMapTbl ===============
; This table maps portrait IDs to their origin in the tilemap.
;
; Portraits are 3 tiles wide and 3 tiles high, and their origin is the top-left tile.
;
CharSel_IdBGMapTbl:
	dw $9861 ; CHARSEL_ID_KYO      
	dw $9864 ; CHARSEL_ID_ANDY     
	dw $9867 ; CHARSEL_ID_TERRY    
	dw $986A ; CHARSEL_ID_RYO      
	dw $986D ; CHARSEL_ID_ROBERT   
	dw $9870 ; CHARSEL_ID_IORI     
	dw $98C1 ; CHARSEL_ID_DAIMON   
	dw $98C4 ; CHARSEL_ID_MAI      
	dw $98C7 ; CHARSEL_ID_GEESE    
	dw $98CA ; CHARSEL_ID_MRBIG    
	dw $98CD ; CHARSEL_ID_KRAUSER  
	dw $98D0 ; CHARSEL_ID_MATURE   
	dw $9921 ; CHARSEL_ID_ATHENA   
	dw $9924 ; CHARSEL_ID_CHIZURU  
	dw $9927 ; CHARSEL_ID_MRKARATE0
	dw $992A ; CHARSEL_ID_MRKARATE1
	dw $992D ; CHARSEL_ID_GOENITZ  
	dw $9930 ; CHARSEL_ID_LEONA
	; These still happen to get used, unlike what's in CharSel_CursorPosTable.
	; Unsurprisingly, they have the same tilemap pointers as their normal versions.
	dw $9870 ; CHARSEL_ID_SPEC_OIORI 
	dw $9930 ; CHARSEL_ID_SPEC_OLEONA
	dw $9924 ; CHARSEL_ID_SPEC_KAGURA

; =============== CharSel_IsEndlessCpuVsCpu ===============
; Checks if both players are set as CPU during VS mode.
; OUT
; - C flag: If set, the checks passed
CharSel_IsEndlessCpuVsCpu:
	ld   a, [wPlayMode]
	bit  MODEB_VS, a						; Are we in VS mode?
	jp   z, .retClear						; If not, jump
	ld   a, [wPlInfo_Pl1+iPlInfo_Flags0]
	ld   b, a								; B = P1 status
	ld   a, [wPlInfo_Pl2+iPlInfo_Flags0]	; A = P2 status
	and  b									; Merge them
	and  a, PF0_CPU							; Is the CPU flag set on both?
	jr   z, .retClear						; If not, jump
.retSet:
	scf  ; C flag set
	ret 
.retClear:
	scf
	ccf  ; C flag clear
	ret
	
; =============== CharSelect_IsCPUOpponent ===============
; Checks if the current player is a CPU opponent, meaning it's not actively
; controlled by the GB's joypad input.
;
; Note that this is separate from a player being CPU-controlled, as in non-endless
; CPU vs CPU matches the player does get to control one of the cursors.
;
; OUT
; - C flag: If set, this player is the CPU opponent
CharSelect_IsCPUOpponent:

	; No CPU opponents in VS modes
	ld   a, [wPlayMode]
	bit  MODEB_VS, a			; Are we in VS mode?
	jp   nz, .retClear			; If so, return clear
	
	; Depending on the current player...
	ld   a, [wCharSelCurPl]
	or   a						; Currently handling player 1? (== CHARSEL_1P)
	jp   nz, .chkCpu2P			; If not, jump
.chkCpu1P:
	; Currently handling 1P.
	; For 1P to be a CPU opponent, P2 must have control on the char select screen
	ld   a, [wJoyActivePl]
	or   a						; Playing on the 1P side? (== PL1)
	jp   z, .retClear			; If so, return clear
	
	jp   .retSet
.chkCpu2P:
	; Currently handling 2P.
	; For 2P to be a CPU opponent, 1P must have control on the char select screen
	ld   a, [wJoyActivePl]
	or   a						; Playing on the 2P side? (!= PL1)
	jp   nz, .retClear			; If so, return clear 
.retSet:
	scf		; C flag = 1, not controllable by player
	ret
.retClear:
	scf
	ccf		; C flag = 0, controllable by player
	ret
	
; =============== CharSelect_IsLastWinner ===============
; Checks if, in single modes, the active player won the last round.
;
; This is used to prevent the player from changing team between rounds,
; unless it's after a game over.
; OUT
; - C flag: If set, the active side won
CharSelect_IsLastWinner:
	; Not applicable in VS mode, since both players are allowed to change teams
	ld   a, [wPlayMode]
	bit  MODEB_VS, a		; Playing in VS mode?
	jp   nz, .retClear		; If so, return clear
	
	; Depending on the current player...
	ld   a, [wCharSelCurPl]
	or   a					; Are we handling 1P?
	jp   nz, .pl2			; If not, jump
.pl1:
	; Not applicable here if 1P is the CPU opponent
	ld   a, [wJoyActivePl]
	or   a					; Playing on the 1P side?
	jp   nz, .retClear		; If not, return clear
	
	; Final check
	ld   a, [wLastWinner]
	bit  PLB1, a			; Did 1P win the last round?
	jp   nz, .retSet		; If so, return set
	
	; Otherwise, we game over'd before.
	; Allow changing the team.
	jp   .retClear
.pl2:
	; Not applicable here if 2P is the CPU opponent
	ld   a, [wJoyActivePl]
	or   a					; Playing on the 1P side?
	jp   z, .retClear		; If so, return clear
	
	; Final check
	ld   a, [wLastWinner]
	bit  PLB2, a			; Did 2P win the last round?
	jp   nz, .retSet		; If so, return set
	
	; Otherwise, we game over'd before.
	; Allow changing the team.
	jp   .retClear
.retSet:
	scf		; C flag = 1
	ret
.retClear:
	scf
	ccf		; C flag = 0
	ret
	
; =============== CharSel_IdMapTbl ===============
; CHARSEL_ID_* -> CHAR_ID_* mapping table.
; The chars declarations below are organized like how they appear in the character select screen.
CharSel_IdMapTbl:
	db CHAR_ID_KYO/2,    CHAR_ID_ANDY/2,    CHAR_ID_TERRY/2,    CHAR_ID_RYO/2,      CHAR_ID_ROBERT/2,  CHAR_ID_IORI/2
	db CHAR_ID_DAIMON/2, CHAR_ID_MAI/2,     CHAR_ID_GEESE/2,    CHAR_ID_MRBIG/2,    CHAR_ID_KRAUSER/2, CHAR_ID_MATURE/2
	db CHAR_ID_ATHENA/2, CHAR_ID_CHIZURU/2, CHAR_ID_MRKARATE/2, CHAR_ID_MRKARATE/2, CHAR_ID_GOENITZ/2, CHAR_ID_LEONA/2
	; [TCRF] Unused entries in the list. Not used by tile flipping since it switches between hardcoded char IDs.
	;        These may have been used before the tile flipping was implemented, and still work properly.
	;        They all work as intended as they also have (unused) CharSel_CursorPosTable entries.
	db CHAR_ID_OIORI/2
	db CHAR_ID_OLEONA/2
	db CHAR_ID_KAGURA/2
.end:
; Relative tile IDs for portraits
BG_CharSel_Portrait: INCBIN "data/bg/charsel_portrait.bin"
BG_CharSel_EmptyPortrait: INCBIN "data/bg/charsel_emptyportrait.bin"
TextDef_CharSel_SingleTitle:
	dw $9823
	db .end-.start
.start:
	db "PLAYER  SELECT"
.end:
TextDef_CharSel_TeamTitle:
	dw $9824
	db .end-.start
.start:
	db "TEAM  SELECT"
.end:
GFX_CharSel_BG0: INCBIN "data/gfx/charsel_bg0.bin"
GFXLZ_CharSel_BG1: INCBIN "data/gfx/charsel_bg1.lzc"
GFXLZ_CharSel_OBJ: INCBIN "data/gfx/charsel_obj.lzc"
GFXDef_CharSel_Cross:
	db $09 ; Tile count
GFX_CharSel_Cross: INCBIN "data/gfx/charsel_cross.bin"
GFX_CharSel_Cross_Mask: INCBIN "data/gfx/charsel_cross_mask.bin"

OBJInfoInit_CharSel_Cursor:
	db OST_VISIBLE ; iOBJInfo_Status
	db $00 ; iOBJInfo_OBJLstFlags
	db $00 ; iOBJInfo_OBJLstFlagsView
	db $28 ; iOBJInfo_X
	db $00 ; iOBJInfo_XSub
	db $40 ; iOBJInfo_Y
	db $00 ; iOBJInfo_YSub
	db $00 ; iOBJInfo_SpeedX
	db $00 ; iOBJInfo_SpeedXSub
	db $00 ; iOBJInfo_SpeedY
	db $00 ; iOBJInfo_SpeedYSub
	db $00 ; iOBJInfo_RelX (auto)
	db $00 ; iOBJInfo_RelY (auto)
	db $00 ; iOBJInfo_TileIDBase
	db LOW($8000) ; iOBJInfo_VRAMPtr_Low
	db HIGH($8000) ; iOBJInfo_VRAMPtr_High
	db BANK(OBJLstPtrTable_CharSel_Cursor) ; iOBJInfo_BankNum (BANK $1E)
	db LOW(OBJLstPtrTable_CharSel_Cursor) ; iOBJInfo_OBJLstPtrTbl_Low
	db HIGH(OBJLstPtrTable_CharSel_Cursor) ; iOBJInfo_OBJLstPtrTbl_High
	db $00 ; iOBJInfo_OBJLstPtrTblOffset
	db $00 ; iOBJInfo_BankNumView (N/A)
	db LOW(OBJLstPtrTable_CharSel_Cursor) ; iOBJInfo_OBJLstPtrTbl_LowView
	db HIGH(OBJLstPtrTable_CharSel_Cursor) ; iOBJInfo_OBJLstPtrTbl_HighView
	db $00 ; iOBJInfo_OBJLstPtrTblOffset
	db $00 ; iOBJInfo_ColiBoxId (auto)
	db $00 ; iOBJInfo_HitboxId (auto)
	db $00 ; iOBJInfo_ForceHitboxId
	db $02 ; iOBJInfo_FrameLeft
	db $02 ; iOBJInfo_FrameTotal
	db LOW(wGFXBufInfo_Pl1) ; iOBJInfo_BufInfoPtr_Low
	db HIGH(wGFXBufInfo_Pl1) ; iOBJInfo_BufInfoPtr_High
	
INCLUDE "data/objlst/charsel.asm"	
; 
; =============== END OF MODULE CharSel ===============
;

; 
; =============== START OF MODULE OrdSel ===============
;
; =============== Module_OrdSel ===============
; EntryPoint for team order select screen.
Module_OrdSel:
	ld   sp, $DD00
	di
	;-----------------------------------
	rst  $10				; Stop LCD
	
	; Initialize all variables
	xor  a
	ldh  [rBGP], a
	ldh  [rOBP0], a
	ldh  [rOBP1], a
	ld   [wCharSelTeamFull], a
	ld   [wOrdSelP1CharsSelected], a
	ld   [wOrdSelP2CharsSelected], a
	ld   [wOrdSelCurPl], a
	ld   [wOrdSelCPUDelay1P], a
	ld   [wOrdSelCPUDelay2P], a
	ld   [wOrdSelP1CursorPos], a
	ld   [wOrdSelP2CursorPos], a
	ld   [wOrdSelTmpP1CharId], a
	ld   [wOrdSelTmpP2CharId], a
	ld   [wOrdSelP1CharSel0], a
	ld   [wOrdSelP1CharId0], a
	ld   [wOrdSelP1CharSel1], a
	ld   [wOrdSelP1CharId1], a
	ld   [wOrdSelP1CharSel2], a
	ld   [wOrdSelP1CharId2], a
	ld   [wOrdSelP2CharSel0], a
	ld   [wOrdSelP2CharId0], a
	ld   [wOrdSelP2CharSel1], a
	ld   [wOrdSelP2CharId1], a
	ld   [wOrdSelP2CharSel2], a
	ld   [wOrdSelP2CharId2], a
	ld   [wOrdSelP1CursorPosBak], a
	ld   [wOrdSelP2CursorPosBak], a
	
	;
	; Initialize the delay timers, used by the CPU to wait for a bit
	; between selections.
	;
	ld   a, [wPlayMode]
	cp   MODE_TEAM1P		; Playing in 1P mode?				
	jp   nz, .vsMode		; If not, jump
.singleMode:
	; In single mode, randomize the inactive side
	ld   a, [wJoyActivePl]
	or   a					; Playing on the 1P side?
	jp   z, .random2P		; If so, jump
.random1P:
	; Playing as 2P, so set the delay on 1P side
	ld   a, $01				
	ld   [wOrdSelCPUDelay1P], a
	jp   .loadVRAM
.random2P:
	; Playing as 1P, so autopick on 2P side
	ld   a, $01
	ld   [wOrdSelCPUDelay2P], a
	jp   .loadVRAM
.vsMode:
	; In an endless CPU vs CPU battle in VS mode, set the same delay since the autopicker is on.
	; Otherwise, skip to .loadVRAM since both players manually have to choose (including if only one player is a CPU).
	call CharSel_IsEndlessCpuVsCpu	
	jp   nc, .loadVRAM
	ld   a, $01
	ld   [wOrdSelCPUDelay1P], a
	ld   [wOrdSelCPUDelay2P], a

.loadVRAM:
	; Load SGB palettes
	ld   de, SCRPAL_ORDERSELECT
	call HomeCall_SGB_ApplyScreenPalSet
	
	; Clear tilemaps
	call ClearBGMap
	call ClearWINDOWMap
	
	; Reset scrolling to top left
	xor  a
	ldh  [hScrollX], a
	ldh  [hScrollY], a
	ld   [wOBJScrollX], a
	ld   [wOBJScrollY], a
	
	; All OBJ tiles
	ld   hl, GFXLZ_OrdSel_OBJ
	ld   de, wLZSS_Buffer+$20
	call DecompressLZSS
	ld   hl, wLZSS_Buffer+$20
	ld   de, Tiles_Begin
	ld   b, $1C
	call CopyTiles
	
	; Shared BG tiles
	ld   hl, GFXLZ_OrdSel_BG
	ld   de, wLZSS_Buffer+$20
	call DecompressLZSS
	ld   hl, wLZSS_Buffer+$20
	ld   de, $9000
	ld   b, $5A
	call CopyTiles
	
	; Tilemap for "ORDER SELECT" and KOF logo
	ld   hl, BGLZ_OrdSel_Main
	ld   de, wLZSS_Buffer+$20
	call DecompressLZSS
	ld   de, wLZSS_Buffer+$20
	ld   hl, $9803
	ld   b, $0E
	ld   c, $09
	call CopyBGToRect
	
	;
	; Load character GFX
	;
	; These are all decompressed to a buffer, and specific tile ranges
	; are then copied to specific VRAM locations from there.
	;
	
	; Decompress block
	call OrdSel_DecompressCharGFX
	
	; Player 1 - Team Member 1
	; This is always defined.
.load1PChar0GFX:
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamCharId0]
	ld   de, $8800				; Destination ptr
	ld   c, a					; C = CharId * 2
	call OrdSel_LoadCharGFX1P
	
	; Player 1 - Team Member 2
.load1PChar1GFX:
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamCharId1]
	cp   CHAR_ID_NONE		; Is this slot empty?
	jr   z, .no1PChar1		; If so, jump
	ld   de, $8920				
	ld   c, a
	call OrdSel_LoadCharGFX1P
	jr   .load1PChar2GFX
.no1PChar1:
	ld   a, $01				; Prevent cursor from moving over middle option
	ld   [wOrdSelP1CharSel1], a
	ld   a, CHAR_ID_NONE	; Nothing selected as 2nd member
	ld   [wOrdSelP1CharId1], a
	
	; Player 1 - Team Member 3
.load1PChar2GFX:
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamCharId2]
	cp   CHAR_ID_NONE		; Is this slot empty?
	jr   z, .no1PChar2		; If so, jump
	ld   de, $8A40				
	ld   c, a
	call OrdSel_LoadCharGFX1P
	jr   .load2PChar0GFX
.no1PChar2:
	ld   a, $01				; Prevent cursor from moving over rightmost option
	ld   [wOrdSelP1CharSel2], a
	ld   a, CHAR_ID_NONE	; Nothing selected as 3rd member
	ld   [wOrdSelP1CharId2], a
	
.load2PChar0GFX:
	; Player 2 - Team Member 1
	; This is always defined.
	ld   a, [wPlInfo_Pl2+iPlInfo_TeamCharId0]
	ld   de, $8B60
	ld   c, a
	call OrdSel_LoadCharGFX2P
	
.load2PChar1GFX:	
	; Player 2 - Team Member 2
	ld   a, [wPlInfo_Pl2+iPlInfo_TeamCharId1]
	cp   CHAR_ID_NONE		; Is this slot empty?
	jr   z, .no2PChar1		; If so, jump
	ld   de, $8C80
	ld   c, a
	call OrdSel_LoadCharGFX2P
	jr   .load2PChar2GFX
.no2PChar1:
	ld   a, $01				; Prevent cursor from moving over middle option
	ld   [wOrdSelP2CharSel1], a
	ld   a, CHAR_ID_NONE	; Nothing selected as 2nd member
	ld   [wOrdSelP2CharId1], a
	
	; Player 2 - Team Member 3
.load2PChar2GFX:
	ld   a, [wPlInfo_Pl2+iPlInfo_TeamCharId2]
	cp   CHAR_ID_NONE		; Is this slot empty?
	jr   z, .no2PChar2		; If so, jump
	ld   de, $8DA0
	ld   c, a
	call OrdSel_LoadCharGFX2P
	jr   .loadCharBG
.no2PChar2:
	ld   a, $01				; Prevent cursor from moving over leftmost option
	ld   [wOrdSelP2CharSel2], a
	ld   a, CHAR_ID_NONE	; Nothing selected as 3rd member
	ld   [wOrdSelP2CharId2], a
	;--
	
	;
	; Load character tilemaps
	;
	; Since the char graphics are stored contiguously, the same tilemap with relative tile IDs
	; can be reused for all characters, with different base tile IDs for each slot.
	;
	; Also, because the GFX on the 1P side are H-flipped, 1P and 2P use separate tilemaps.
	; In particular, the 2P tilemap has the tile IDs in order, while the 1P one reverses
	; the tile order for each row (3 tiles).
	;
.loadCharBG:
	; Draw 1P char 1
	ld   hl, $9920				; Leftmost
	call OrdSel_CopyCharBG_1P0
	
	; Draw 1P char 2 if it exists
	ld   a, [wOrdSelP1CharSel1]
	cp   $00					; Is this character set?
	jr   nz, .loadCharBG1P2		; If not, jump
	ld   hl, $9923				; Middle
	call OrdSel_CopyCharBG_1P1
	
.loadCharBG1P2:
	; Draw 1P char 3 if it exists
	ld   a, [wOrdSelP1CharSel2]
	cp   $00
	jr   nz, .loadCharBG2P0
	ld   hl, $9926				; Rightmost
	ld   a, $A4					; Base tile ID
	call OrdSel_CopyCharBG_1P
	
.loadCharBG2P0:
	; Draw 2P char 1
	ld   de, BG_OrdSel_Char2P
	ld   hl, $9931				; Rightmost
	ld   a, $B6
	call OrdSel_CopyCharBG
	
	; Draw 2P char 2 if it exists
	ld   a, [wOrdSelP2CharSel1]
	cp   $00
	jr   nz, .loadCharBG2P2
	ld   de, BG_OrdSel_Char2P
	ld   hl, $992E				; Middle
	ld   a, $C8
	call OrdSel_CopyCharBG
	
.loadCharBG2P2:
	; Draw 2P char 3 if it exists
	ld   a, [wOrdSelP2CharSel2]
	cp   $00
	jr   nz, .initOBJ
	ld   de, BG_OrdSel_Char2P
	ld   hl, $992B				; Leftmost
	ld   a, $DA
	call OrdSel_CopyCharBG
	
.initOBJ:
	;
	; Load sprite mappings for cursors
	; These reuse the base OBJInfo from character select screen
	;
	call ClearOBJInfo
	
	;
	; Player 1 cursor
	;
	ld   hl, wOBJInfo_Pl1+iOBJInfo_Status
	ld   de, OBJInfoInit_CharSel_Cursor
	call OBJLstS_InitFrom
	ld   hl, wOBJInfo_Pl1+iOBJInfo_OBJLstPtrTbl_Low
	ld   [hl], LOW(OBJLstPtrTable_OrdSel_Cursor)
	inc  hl
	ld   [hl], HIGH(OBJLstPtrTable_OrdSel_Cursor)
	; Start at the leftmost position
	ld   a, $00
	ld   [wOBJInfo_Pl1+iOBJInfo_X], a
	ld   a, $80
	ld   [wOBJInfo_Pl1+iOBJInfo_Y], a
	
	;
	; Player 2 cursor
	;
	ld   hl, wOBJInfo_Pl2+iOBJInfo_Status
	ld   de, OBJInfoInit_CharSel_Cursor
	call OBJLstS_InitFrom
	ld   hl, wOBJInfo_Pl2+iOBJInfo_OBJLstPtrTbl_Low
	ld   [hl], LOW(OBJLstPtrTable_OrdSel_Cursor)
	inc  hl
	ld   [hl], HIGH(OBJLstPtrTable_OrdSel_Cursor)
	; Start at the rightmost position
	ld   a, $88
	ld   [wOBJInfo_Pl2+iOBJInfo_X], a
	ld   a, $80
	ld   [wOBJInfo_Pl2+iOBJInfo_Y], a
	
	;
	; VS sign between teams
	;
	ld   hl, wOBJInfo2+iOBJInfo_Status
	ld   de, OBJInfoInit_CharSel_Cursor
	call OBJLstS_InitFrom
	ld   hl, wOBJInfo2+iOBJInfo_OBJLstFlags
	ld   [hl], $90
	ld   hl, wOBJInfo2+iOBJInfo_OBJLstPtrTbl_Low
	ld   [hl], LOW(OBJLstPtrTable_OrdSel_VS)
	inc  hl
	ld   [hl], HIGH(OBJLstPtrTable_OrdSel_VS)
	ld   a, $32
	ld   [wOBJInfo2+iOBJInfo_X], a
	ld   a, $58
	ld   [wOBJInfo2+iOBJInfo_Y], a
	
	call Pl_InitBeforeStageLoad	; Just in case? This is already done by CharSel
	call Serial_DoHandshake
	
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_OBJSIZE|LCDC_WTILEMAP|LCDC_ENABLE
	rst  $18				; Resume LCD
	;-----------------------------------
	ei
	call Task_PassControl_NoDelay
	call Task_PassControl_NoDelay
	
	; Set DMG palettes
	ld   a, $1E
	ldh  [rOBP0], a
	ld   a, $3E
	ldh  [rOBP1], a
	ld   a, $2D
	ldh  [rBGP], a
	
	; Reuse character select music
	ld   a, BGM_ROULETTE
	call HomeCall_Sound_ReqPlayExId_Stub
	call Task_PassControl_Delay1D
	
.mainLoop:
	;
	; The goal of this module is to fill in all wOrdSelP*CharId* variables.
	; Once that's done, they get copied back to the player structs.
	;
	call OrdSel_AnimCursor
	call JoyKeys_DoCursorDelayTimer
	
.doPl1:
	;
	; Handle Player 1
	;
	ld   a, PL1
	ld   [wOrdSelCurPl], a
	call OrdSel_DoMode
	; Hide the cursor when all characters are selected
	ld   a, [wOrdSelP1CharsSelected]
	cp   ORDSEL_SELDONE					; CursorMode == ORDSEL_SELDONE?
	jp   nz, .doPl2							; If not, skip
	ld   hl, wOBJInfo_Pl1+iOBJInfo_Status	; Otherwise, hide the 1P cursor sprite
	res  OSTB_VISIBLE, [hl]
.doPl2:

	;
	; Handle Player 1
	;
	ld   a, PL2
	ld   [wOrdSelCurPl], a
	call OrdSel_DoMode
	; Hide the cursor when all characters are selected
	ld   a, [wOrdSelP2CharsSelected]
	cp    ORDSEL_SELDONE					; CursorMode == ORDSEL_SELDONE?
	jp   nz, .chkEnd						; If not, skip
	ld   hl, wOBJInfo_Pl2+iOBJInfo_Status	; Otherwise, hide the 2P cursor sprite
	res  OSTB_VISIBLE, [hl]
	
.chkEnd:
	;
	; If both players have selected all characters, switch to gameplay after a small delay
	;
	ld   a, [wOrdSelP1CharsSelected]	; A = P1Cursor
	ld   hl, wOrdSelP2CharsSelected	; HL = P2Cursor Ptr
	cp   a, [hl]					; Are both cursors in the same mode?
	jp   nz, .noEnd					; If not, jump
	cp   ORDSEL_SELDONE			; Has 1P finished selecting characters?
	jp   nz, .noEnd					; If not, jump
	; Otherwise, it means ORDSEL_SELDONE is set to both players.
	; We're done.
	jp   .end
.noEnd:
	; Wait for the end of the frame and continue
	call Task_PassControl_NoDelay
	jp   .mainLoop
	
.end:
	;
	; Save the new team order from the temp vars back to the player struct.
	;
	ld   a, [wOrdSelP1CharId0]
	ld   [wPlInfo_Pl1+iPlInfo_TeamCharId0], a
	ld   a, [wOrdSelP1CharId1]
	ld   [wPlInfo_Pl1+iPlInfo_TeamCharId1], a
	ld   a, [wOrdSelP1CharId2]
	ld   [wPlInfo_Pl1+iPlInfo_TeamCharId2], a
	ld   a, [wOrdSelP2CharId0]
	ld   [wPlInfo_Pl2+iPlInfo_TeamCharId0], a
	ld   a, [wOrdSelP2CharId1]
	ld   [wPlInfo_Pl2+iPlInfo_TeamCharId1], a
	ld   a, [wOrdSelP2CharId2]
	ld   [wPlInfo_Pl2+iPlInfo_TeamCharId2], a
	
	; Wait $3B frames, and then init gameplay
	call Task_PassControl_Delay3B
	jp   Module_Play
	
; =============== OrdSel_DoMode ===============
OrdSel_DoMode:
	ld   a, [wOrdSelCurPl]
	or   a						; Handling player 1?
	jp   nz, .pl2				; If not, jump
.pl1:
	; When two characters are already selected, autoselect the third one.
	ld   a, [wOrdSelP1CharsSelected]
	cp   ORDSEL_SEL2		; Selected two characters already?
	jr   z, OrdSel_Ctrl_SelChar	; If so, jump
	
	;
	; [CPU-only]
	; 
	; Wait for the specified amount of frames before automatically selecting the character
	; the cursor is hovering.
	;
	; This is used to delay the CPU from picking characters, otherwise it would instantly
	; pick all 3 of them in 3 frames.
	; The timer is reset when it reaches $01, and the character the CPU cursor is over is autopicked.
	; Because of this, the CPU always selects the characters in order (ie: from right to left if 2P is the CPU).
	;
	; For human players, the delay is always $00, which allows full control.
	;
	ld   a, [wOrdSelCPUDelay1P]
	and  a					; Delay == 0?
	jp   z, .checkCtrl		; If so, ignore completely (we're a human player)
	cp   a, $01				; Is it exactly 1?
	jp   z, .pl1CPUSel		; If so, jump (the CPU can pick the character)
	; Otherwise, wait
	dec  a					; Delay--
	ld   [wOrdSelCPUDelay1P], a
	ret  
.pl2:
	; Same thing, but for player 2.
	
	; Autoselect the third character
	ld   a, [wOrdSelP2CharsSelected]
	cp   ORDSEL_SEL2		; Selected two characters already?
	jr   z, OrdSel_Ctrl_SelChar				; If so, jump
	
	; Wait a bit for CPUs
	ld   a, [wOrdSelCPUDelay2P]
	and  a
	jp   z, .checkCtrl
	cp   $01
	jp   z, .pl2CPUSel
	dec  a
	ld   [wOrdSelCPUDelay2P], a
	ret
.checkCtrl:
	;
	; Handle human player controls
	;
	call CharSel_GetInput
	bit  KEYB_A, a
	jp   nz, OrdSel_Ctrl_SelChar
	bit  KEYB_LEFT, b
	jp   nz, OrdSel_Ctrl_MoveL
	bit  KEYB_RIGHT, b
	jp   nz, OrdSel_Ctrl_MoveR
	ret
.pl1CPUSel:
	; Reset 1P delay timer and pick character
	ld   a, $3C
	ld   [wOrdSelCPUDelay1P], a
	jr   OrdSel_Ctrl_SelChar
.pl2CPUSel:
	; Reset 2P delay timer and pick character
	ld   a, $3C
	ld   [wOrdSelCPUDelay2P], a
	
; =============== OrdSel_Ctrl_SelChar ===============
; Selects the character the cursor points to.
OrdSel_Ctrl_SelChar:
	ld   a, [wOrdSelCurPl]
	or   a							; Handling player 1?
	jp   nz, OrdSel_Ctrl_SelChar_P2	; If not, jump
	; Fall-through
	
; =============== OrdSel_Ctrl_SelChar_P1 ===============
OrdSel_Ctrl_SelChar_P1:
	; Don't select any more characters if we've selected them all
	ld   a, [wOrdSelP1CharsSelected]
	cp   ORDSEL_SELDONE
	ret  z
	
	;
	; Determine which character we've selected, based on the cursor's position.
	; Iterate over CursorPos until it reaches 0. 
	;
	ld   a, [wOrdSelP1CursorPos]
	ld   b, a									; B = CursorPos						
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamCharId1]	; Char 2 settings
	ld   hl, wOrdSelP1CharSel1
	dec  b										; CursorPos == 1?
	jr   z, .char1Chk							; If so, jump
	
	; Otherwise, check we're over the third character
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamCharId2]	; Char 3 settings
	ld   hl,wOrdSelP1CharSel2
	dec  b										; CursorPos == 2?
	jr   z, .char2Chk							; If so, jump
	
	; Otherwise, we must have selected the first character
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamCharId0]
	ld   hl, wOrdSelP1CharSel0
	
	;
	; Each of these routines move the cursor over another character.
	; If the new character is already selected, it moves to a third character.
	; No attempt is made to check if the failsafe choice is already selected, since
	; it won't make a difference when only 3 characters are selectable.
	;
	
.char0Chk:
	;
	; Move the cursor from the 1st to 2nd character. If it fails, move to the 3rd one.
	;		
	push af

		; Move cursor sprite three tiles to the right
		ld   a, [wOBJInfo_Pl1+iOBJInfo_X]
		add  a, TILE_H*3				; iOBJInfo_X += $18
		ld   [wOBJInfo_Pl1+iOBJInfo_X], a
		
		; Increment cursor position, saving a backup of the original for later
		; as the original value is used to determine where to draw the large number.
		ld   a, [wOrdSelP1CursorPos]
		ld   [wOrdSelP1CursorPosBak], a	; Save backup
		inc  a							; CursorPos++
		ld   [wOrdSelP1CursorPos], a
		
		; If the 2nd character was already selected, move the cursor to the 3rd character.
		ld   a, [wOrdSelP1CharSel1]
		and  a, a						; Is the second character selected?
		jr   z, .char0Done				; If not, skip
	.char0Ex:
		; Otherwise, move cursor sprite right again
		ld   a, [wOBJInfo_Pl1+iOBJInfo_X]
		add  a, TILE_H*3				; iOBJInfo_X += $18
		ld   [wOBJInfo_Pl1+iOBJInfo_X], a
		; And increase cursor position
		ld   a, [wOrdSelP1CursorPos]
		inc  a
		ld   [wOrdSelP1CursorPos], a
	.char0Done:
	pop  af
	jr   .setChar
	
.char1Chk:
	;
	; Move the cursor from the 2st to 3nd character. If it fails, move to the 1st one.
	;
	push af
	
		; Move cursor sprite three tiles to the right
		ld   a, [wOBJInfo_Pl1+iOBJInfo_X]
		add  a, TILE_H*3				; iOBJInfo_X += $18
		ld   [wOBJInfo_Pl1+iOBJInfo_X], a
		
		; Increment cursor position, saving a backup of the original for later
		ld   a, [wOrdSelP1CursorPos]
		ld   [wOrdSelP1CursorPosBak], a
		inc  a
		ld   [wOrdSelP1CursorPos], a
		
		; If the 3rd character was already selected, move the cursor back to the 1st character.
		ld   a, [wOrdSelP1CharSel2]
		and  a, a						; Is the third character selected?
		jr   z, .char1Done				; If not, skip
		; Otherwise, move cursor sprite left 6 tiles
		ld   a, [wOBJInfo_Pl1+iOBJInfo_X]
		sub  a, TILE_H*3*2				; iOBJInfo_X -= $30
		ld   [wOBJInfo_Pl1+iOBJInfo_X], a
		; And reset cursor position (will always be $00)
		ld   a, [wOrdSelP1CursorPos]
		dec  a
		dec  a
		ld   [wOrdSelP1CursorPos], a
	.char1Done:
	pop  af
	jr   .setChar
.char2Chk:
	;
	; Move the cursor from the 3rd to 2nd character. If it fails, move to the 1st one.
	;
	push af
		; Move cursor sprite three tiles to the left
		ld   a, [wOBJInfo_Pl1+iOBJInfo_X]
		sub  a, TILE_H*3			; iOBJInfo_X -= $18
		ld   [wOBJInfo_Pl1+iOBJInfo_X], a
		
		; Decrement cursor position, saving a backup of the original for later
		ld   a, [wOrdSelP1CursorPos]
		ld   [wOrdSelP1CursorPosBak], a
		dec  a
		ld   [wOrdSelP1CursorPos], a
		
		; If the 2nd character was already selected, move the cursor back to the 1st character.
		ld   a, [wOrdSelP1CharSel1]
		and  a, a					; Is the second character selected?
		jr   z, .char2Done			; If not, skip
		ld   a, [wOBJInfo_Pl1+iOBJInfo_X]
		sub  a, TILE_H*3			; iOBJInfo_X -= $18
		ld   [wOBJInfo_Pl1+iOBJInfo_X], a
		ld   a, [wOrdSelP1CursorPos]	; Decrease cursor position
		dec  a
		ld   [wOrdSelP1CursorPos], a
	.char2Done:
	pop  af
.setChar:

	;
	; Mark the character as selected.
	;
	
	; Prevent the cursor from moving over this position again.
	ld   [hl], $01		; Set wOrdSelP1CharSel*
	
	; Remember the character ID for later, as we haven't yet determined
	; where to save it.
	ld   [wOrdSelTmpP1CharId], a
	
	; Increase number of selected characters.
	; Note that when the third character is selected, this increases it to ORDSEL_SELDONE.
	ld   a, [wOrdSelP1CharsSelected]
	inc  a
	ld   [wOrdSelP1CharsSelected], a
	
	;
	; Determine where to draw the number in the tilemap
	;
	ld   a, [wOrdSelP1CursorPosBak]	; A = Original position
	
	ld   hl, $99E3				; HL = Tilemap ptr for 2nd character
	dec  a						; OrigPos == 1?
	jr   z, .chkDrawNum			; If so, jump
	
	ld   hl, $99E6				; HL = Tilemap ptr for 3rd character
	dec  a						; OrigPos == 2?
	jr   z, .chkDrawNum			; If so, jump
	
	; Otherwise, OrigPos == 0
	ld   hl, $99E0				; HL = Tilemap ptr for 1st character
.chkDrawNum:

	;
	; Determine the order for the character in the team.
	;
	ld   a, [wOrdSelP1CharsSelected]
	dec  a				; SelCount == 1?
	jr   z, .setNum1	; If so, jump
	dec  a				; SelCount == 2?
	jr   z, .setNum2	; If so, jump
	dec  a				; SelCount == 3?
	jr   z, .setNum3	; If so, jump
	ret ; We never get here
.setNum1:
	; Save current character as first one
	ld   a, [wOrdSelTmpP1CharId]
	ld   [wOrdSelP1CharId0], a
	
	; Draw number 1 to tilemap.
	; These numbers have the same width as the character tilemaps.
	ld   de, BG_OrdSel_Num1
	ld   b, $03		; Width
	ld   c, $03		; Height
	call CopyBGToRect
	
	;
	; If there's only one character in the team, we're done.
	; This is the case for bosses, which have the first character slot defined
	; and the other two empty.
	;
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamCharId1]
	cp   CHAR_ID_NONE			; Is there a second character in the team?		
	ret  nz						; If not, return
.endPremature:
	; Why?
	ld   a, [wOBJInfo_Pl1+iOBJInfo_X]
	sub  a, TILE_H*2			; iOBJInfo_X -= $10
	ld   [wOBJInfo_Pl1+iOBJInfo_X], a
	; Set that all characters were selected
	ld   a, ORDSEL_SELDONE
	ld   [wOrdSelP1CharsSelected], a
	ret
.setNum2:
	; Save current character as second one
	ld   a, [wOrdSelTmpP1CharId]
	ld   [wOrdSelP1CharId1], a
	
	; Draw number 2 to tilemap
	ld   de, BG_OrdSel_Num2
	ld   b, $03
	ld   c, $03
	call CopyBGToRect
	
	;
	; If there are only two characters in the team, we're done.
	; [TCRF] This can never happen, but it is supported.
	;
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamCharId2]
	cp   $FF
	ret  nz

	jr   .endPremature
.setNum3:
	; Save current character as third one
	ld   a, [wOrdSelTmpP1CharId]
	ld   [wOrdSelP1CharId2], a
	
	; Draw number 3 to tilemap
	ld   de, BG_OrdSel_Num3
	ld   b, $03
	ld   c, $03
	jp   CopyBGToRect
	; Done.
	; We already increased the wOrdSelP1CharsSelected to ORDSEL_SELDONE in .setChar
	
; =============== OrdSel_Ctrl_SelChar_P2 ===============
; See also: OrdSel_Ctrl_SelChar_P1
OrdSel_Ctrl_SelChar_P2:
	; Don't select any more characters if we've selected them all
	ld   a, [wOrdSelP2CharsSelected]
	cp   ORDSEL_SELDONE
	ret  z
	
	;
	; Determine which character we've selected, based on the cursor's position.
	;
	ld   a, [wOrdSelP2CursorPos]
	ld   b, a
	ld   a, [wPlInfo_Pl2+iPlInfo_TeamCharId1]
	ld   hl, wOrdSelP2CharSel1
	dec  b
	jr   z, .char1Chk
	ld   a, [wPlInfo_Pl2+iPlInfo_TeamCharId2]
	ld   hl, wOrdSelP2CharSel2
	dec  b
	jr   z, .char2Chk
	ld   a, [wPlInfo_Pl2+iPlInfo_TeamCharId0]
	ld   hl, wOrdSelP2CharSel0
	
.char0Chk:
	;
	; Move the cursor from the 1st to 2nd character. If it fails, move to the 3rd one.
	;		
	push af
		;--
		; Move cursor sprite three tiles to the *left*
		ld   a, [wOBJInfo_Pl2+iOBJInfo_X]
		sub  a, TILE_H*3				; iOBJInfo_X -= $18
		ld   [wOBJInfo_Pl2+iOBJInfo_X], a
		;--
		
		; Increment cursor position, saving a backup of the original for later.
		ld   a, [wOrdSelP2CursorPos]
		ld   [wOrdSelP2CursorPosBak], a
		inc  a
		ld   [wOrdSelP2CursorPos], a
		
		; If the 2nd character was already selected, move the cursor to the 3rd character.
		ld   a, [wOrdSelP2CharSel1]
		and  a, a						; Is the second character selected?
		jr   z, .char0Done				; If not, skip
		;--
		; Otherwise, move cursor sprite *left* again
		ld   a, [wOBJInfo_Pl2+iOBJInfo_X]
		sub  a, TILE_H*3				; iOBJInfo_X -= $18
		ld   [wOBJInfo_Pl2+iOBJInfo_X], a
		;--
		; And increase cursor position
		ld   a, [wOrdSelP2CursorPos]
		inc  a
		ld   [wOrdSelP2CursorPos], a
	.char0Done:
	pop  af
	jr   .setChar
.char1Chk:
	;
	; Move the cursor from the 2st to *1st* character. If it fails, move to the *3rd* one.
	;		
	push af
		; Move cursor sprite three tiles to the right
		ld   a, [wOBJInfo_Pl2+iOBJInfo_X]
		add  a, TILE_H*3				; iOBJInfo_X += $18	
		ld   [wOBJInfo_Pl2+iOBJInfo_X], a
		
		;--
		; *Decrement* cursor position, saving a backup of the original for later
		ld   a, [wOrdSelP2CursorPos]
		ld   [wOrdSelP2CursorPosBak], a
		dec  a
		ld   [wOrdSelP2CursorPos], a
		
		; If the *1st* character was already selected, move the cursor to the *3rd* character.
		ld   a, [wOrdSelP2CharSel0]
		and  a, a						; Is the first character selected?
		jr   z, .char1Done				; If not, skip
		
		; Otherwise, move cursor sprite left 6 tiles
		ld   a, [wOBJInfo_Pl2+iOBJInfo_X]
		sub  a, TILE_H*3*2				; iOBJInfo_X -= $30
		ld   [wOBJInfo_Pl2+iOBJInfo_X], a
		; And increase cursor position from $00 to $02
		ld   a, [wOrdSelP2CursorPos]
		inc  a
		inc  a
		ld   [wOrdSelP2CursorPos], a
		;--
	.char1Done:
	pop  af
	jr   .setChar
.char2Chk:
	;
	; Move the cursor from the 3rd to 2nd character. If it fails, move to the 1st one.
	;
	push af
		;--
		; Move cursor sprite three tiles to the *right*
		ld   a, [wOBJInfo_Pl2+iOBJInfo_X]
		add  a, TILE_H*3			; iOBJInfo_X += $18
		ld   [wOBJInfo_Pl2+iOBJInfo_X], a
		;--
		
		; Decrement cursor position, saving a backup of the original for later
		ld   a, [wOrdSelP2CursorPos]
		ld   [wOrdSelP2CursorPosBak], a
		dec  a
		ld   [wOrdSelP2CursorPos], a
		
		; If the 2nd character was already selected, move the cursor back to the 1st character.
		ld   a, [wOrdSelP2CharSel1]
		and  a, a					; Is the second character selected?
		jr   z, .char2Done			; If not, skip
		;--
		; Otherwise, move cursor sprite *right* 3 tiles
		ld   a, [wOBJInfo_Pl2+iOBJInfo_X]
		add  a, TILE_H*3			; iOBJInfo_X += $18
		ld   [wOBJInfo_Pl2+iOBJInfo_X], a
		;--
		; And decrease cursor position
		ld   a, [wOrdSelP2CursorPos]
		dec  a
		ld   [wOrdSelP2CursorPos], a
	.char2Done:
	pop  af
.setChar:

	;
	; Mark the character as selected.
	;
	
	; Prevent the cursor from moving over this position again.
	ld   [hl], $01
	; Remember the character ID for later
	ld   [wOrdSelTmpP2CharId], a
	
	; Increase number of selected characters.
	ld   a, [wOrdSelP2CharsSelected]
	inc  a
	ld   [wOrdSelP2CharsSelected], a
	
	;
	; Determine where to draw the number in the tilemap
	;
	ld   a, [wOrdSelP2CursorPosBak]	; A = Original position
	ld   hl, $99EE
	dec  a							; 2nd char (middle)?
	jr   z, .chkDrawNum				; If so, jump
	ld   hl, $99EB
	dec  a							; 3rd char (left)?
	jr   z, .chkDrawNum				; If so, jump
	; Otherwise, it's the first one (right)
	ld   hl, $99F1
.chkDrawNum:

	;
	; Determine the order for the character in the team.
	;
	ld   a, [wOrdSelP2CharsSelected]
	dec  a
	jr   z, .setNum1
	dec  a
	jr   z, .setNum2
	dec  a
	jr   z, .setNum3
	ret ; We never get here
.setNum1:
	; Save current character as first one
	ld   a, [wOrdSelTmpP2CharId]
	ld   [wOrdSelP2CharId0], a
	
	; Draw number 1 to tilemap.
	ld   de, BG_OrdSel_Num1
	ld   b, $03
	ld   c, $03
	call CopyBGToRect
	
	; Stop if this this is a 1-character team
	ld   a, [wPlInfo_Pl2+iPlInfo_TeamCharId1]
	cp   CHAR_ID_NONE		; Is there a second character in the team?	
	ret  nz					; If not, return
.endPremature:
	; Why?
	ld   a, [wOBJInfo_Pl2+iOBJInfo_X]
	sub  a, TILE_H*2			; iOBJInfo_X -= $10
	ld   [wOBJInfo_Pl2+iOBJInfo_X], a
	
	; Set that all characters were selected
	ld   a, ORDSEL_SELDONE
	ld   [wOrdSelP2CharsSelected], a
	ret
	
.setNum2:
	; Save current character as second one
	ld   a, [wOrdSelTmpP2CharId]
	ld   [wOrdSelP2CharId1], a
	
	; Draw number 2 to tilemap
	ld   de, BG_OrdSel_Num2
	ld   b, $03
	ld   c, $03
	call CopyBGToRect
	
	; [TCRF] Stop if this this is a 1-character team
	ld   a, [wPlInfo_Pl2+iPlInfo_TeamCharId2]
	cp   CHAR_ID_NONE
	ret  nz
	jr   .endPremature
.setNum3:
	; Save current character as third one
	ld   a, [wOrdSelTmpP2CharId]
	ld   [wOrdSelP2CharId2], a
	
	; Draw number 3 to tilemap
	ld   de, BG_OrdSel_Num3
	ld   b, $03
	ld   c, $03
	jp   CopyBGToRect
	
; =============== OrdSel_Ctrl_MoveL ===============
; Moves the cursor to the left.
OrdSel_Ctrl_MoveL:
	; Depending on the player side...
	ld   a, [wOrdSelCurPl]
	or   a
	jp   nz, OrdSel_Ctrl_MoveL_P2
	; Fall-through
	
; =============== OrdSel_Ctrl_MoveL_P1 ===============
; Moves the player 1 cursor to the left, decreasing the cursor position.
OrdSel_Ctrl_MoveL_P1:
	; No movement when all characters are picked
	ld   a, [wOrdSelP1CharsSelected]
	cp   ORDSEL_SELDONE
	ret  z
	
	; Decrement cursor position unless it's already at the leftmost one.
	ld   a, [wOrdSelP1CursorPos]
	and  a, a						; CursorPos == 0?
	ret  z							; If so, return
	dec  a							; Otherwise, CursorPos--
	ld   [wOrdSelP1CursorPos], a
	
	;
	; Make the cursor skip over any already selected characters.
	; If the leftmost boundary is reached, restore the old wOrdSelP1CursorPos value.
	;
	jr   nz, .chkMid				; On the middle position now? If so, jump
.chkLeft:
	; Otherwise, we're on the leftmost one.
	ld   a, [wOrdSelP1CharSel0]
	and  a, a						; Is the leftmost char already selected? (wOrdSelP1CharSel0 != 0)
	jr   z, .moveOk					; If not, jump
	; Otherwise, increment the cursor position back
	ld   a, [wOrdSelP1CursorPos]
	inc  a
	ld   [wOrdSelP1CursorPos], a
	ret
.chkMid:
	ld   a, [wOrdSelP1CharSel1]
	and  a, a						; Is the middle char already selected?	
	jr   z, .moveOk					; If not, jump
	ld   a, [wOrdSelP1CharSel0]
	and  a, a						; Is the leftmost char already selected?	
	jr   z, .moveSkipOk				; If not, jump (always the case)
	; [TCRF] Unreachable code. Would be possible to reach it only if the the third character wasn't autoselected.
	ld   a, [wOrdSelP1CursorPos]
	inc  a
	ld   [wOrdSelP1CursorPos], a
	ret  
.moveSkipOk:
	; Move cursor again to the left, to skip the middle char
	ld   a, [wOrdSelP1CursorPos]
	dec  a
	ld   [wOrdSelP1CursorPos], a
	ld   a, [wOBJInfo_Pl1+iOBJInfo_X]
	sub  a, TILE_H*3			; iOBJInfo_X -= $18
	ld   [wOBJInfo_Pl1+iOBJInfo_X], a
.moveOk:
	; Finally, move the cursor sprite to the left
	ld   a, [wOBJInfo_Pl1+iOBJInfo_X]
	sub  a, TILE_H*3			; iOBJInfo_X -= $18
	ld   [wOBJInfo_Pl1+iOBJInfo_X], a
	ret
	
; =============== OrdSel_Ctrl_MoveL_P2 ===============
; Moves the player 2 cursor to the left, increasing the cursor position.
OrdSel_Ctrl_MoveL_P2:

	; No movement when all characters are picked
	ld   a, [wOrdSelP2CharsSelected]
	cp   ORDSEL_SELDONE
	ret  z
	
	; Increment cursor position unless it's already at the leftmost one.
	ld   a, [wOrdSelP2CursorPos]
	cp   a, $02						; CursorPos == 2?
	ret  z							; If so, return
	inc  a							; Otherwise, CursorPos++
	ld   [wOrdSelP2CursorPos], a
	
	;
	; Make the cursor skip over any already selected characters.
	; If the leftmost boundary is reached, restore the old wOrdSelP2CursorPos value.
	;
	cp   a, $02						; On the middle position now (wOrdSelP2CursorPos != 2)? If so, jump
	jr   nz, .chkMid
.chkLeft:
	; Otherwise, we're on the leftmost one.
	ld   a, [wOrdSelP2CharSel2]
	and  a							; Is the leftmost char already selected? (wOrdSelP2CharSel2 != 0)
	jr   z, .moveOk					; If not, jump
	
	; Otherwise, decrement the cursor position back
	ld   a, [wOrdSelP2CursorPos]
	dec  a
	ld   [wOrdSelP2CursorPos], a
	ret  
	
.chkMid:
	ld   a, [wOrdSelP2CharSel1]
	and  a							; Is the middle char already selected?	
	jr   z, .moveOk					; If not, jump
	ld   a, [wOrdSelP2CharSel2]
	and  a							; Is the leftmost char already selected?	
	jr   z, .moveSkipOk				; If not, jump (always the case)
	
	; [TCRF] Unreachable code. Would be possible to reach it only if the the third character wasn't autoselected.
	ld   a, [wOrdSelP2CursorPos]
	dec  a
	ld   [wOrdSelP2CursorPos], a
	ret  
.moveSkipOk:
	; Move cursor again to the left, to skip the middle char
	ld   a, [wOrdSelP2CursorPos]
	inc  a
	ld   [wOrdSelP2CursorPos], a
	ld   a, [wOBJInfo_Pl2+iOBJInfo_X]
	sub  a, TILE_H*3			; iOBJInfo_X -= $18
	ld   [wOBJInfo_Pl2+iOBJInfo_X], a
.moveOk:
	; Finally, move the cursor sprite to the left
	ld   a, [wOBJInfo_Pl2+iOBJInfo_X]
	sub  a, TILE_H*3			; iOBJInfo_X -= $18
	ld   [wOBJInfo_Pl2+iOBJInfo_X], a
	ret  
	
; =============== OrdSel_Ctrl_MoveR ===============
; Moves the cursor to the right.
OrdSel_Ctrl_MoveR:
	; Depending on the player side...
	ld   a, [wOrdSelCurPl]
	or   a
	jp   nz, OrdSel_Ctrl_MoveR_P2

; =============== OrdSel_Ctrl_MoveR_P1 ===============
; Moves the player 1 cursor to the right, increasing the cursor position.	
OrdSel_Ctrl_MoveR_P1:
	; No movement when all characters are picked
	ld   a, [wOrdSelP1CharsSelected]
	cp   ORDSEL_SELDONE
	ret  z
	
	; Increment cursor position unless it's already at the rightmost one.
	ld   a, [wOrdSelP1CursorPos]
	cp   $02						; CursorPos == 2?
	ret  z							; If so, return
	inc  a							; Otherwise, CursorPos++
	ld   [wOrdSelP1CursorPos], a
	
	;
	; Make the cursor skip over any already selected characters.
	; If the rightmost boundary is reached, restore the old wOrdSelP2CursorPos value.
	;
	cp   $02						; On the middle position now (wOrdSelP1CursorPos != 2)? If so, jump
	jr   nz, .chkMid
.chkRight:
	; Otherwise, we're on the rightmost one.
	ld   a, [wOrdSelP1CharSel2]
	and  a							; Is the rightmost char already selected? (wOrdSelP1CharSel2 != 0)
	jr   z, .moveOk					; If not, jump
	
	; Otherwise, decrement the cursor position back
	ld   a, [wOrdSelP1CursorPos]
	dec  a
	ld   [wOrdSelP1CursorPos], a
	ret
	
.chkMid:
	ld   a, [wOrdSelP1CharSel1]
	and  a, a						; Is the middle char already selected?	
	jr   z, .moveOk					; If not, jump
	ld   a, [wOrdSelP1CharSel2]
	and  a, a						; Is the rightmost char already selected?	
	jr   z, .moveSkipOk				; If not, jump (always the case)
	
	; [TCRF] Unreachable code. Would be possible to reach it only if the the third character wasn't autoselected.
	ld   a, [wOrdSelP1CursorPos]
	dec  a
	ld   [wOrdSelP1CursorPos], a
	ret  
.moveSkipOk:
	; Move cursor again to the right, to skip the middle char
	ld   a, [wOrdSelP1CursorPos]
	inc  a
	ld   [wOrdSelP1CursorPos], a
	ld   a, [wOBJInfo_Pl1+iOBJInfo_X]
	add  a, TILE_H*3			; iOBJInfo_X += $18
	ld   [wOBJInfo_Pl1+iOBJInfo_X], a
.moveOk:
	; Finally, move the cursor sprite to the right
	ld   a, [wOBJInfo_Pl1+iOBJInfo_X]
	add  a, TILE_H*3			; iOBJInfo_X += $18
	ld   [wOBJInfo_Pl1+iOBJInfo_X], a
	ret
	
; =============== OrdSel_Ctrl_MoveR_P2 ===============
; Moves the player 2 cursor to the right, decreasing the cursor position.	
OrdSel_Ctrl_MoveR_P2:
	; No movement when all characters are picked
	ld   a, [wOrdSelP2CharsSelected]
	cp   ORDSEL_SELDONE
	ret  z
	
	; Decrement cursor position unless it's already at the rightmost one.
	ld   a, [wOrdSelP2CursorPos]
	and  a							; CursorPos == 0?
	ret  z							; If so, return
	dec  a							; Otherwise, CursorPos--
	ld   [wOrdSelP2CursorPos], a
	
	;
	; Make the cursor skip over any already selected characters.
	; If the rightmost boundary is reached, restore the old wOrdSelP2CursorPos value.
	;
	jr   nz, .chkMid				; On the middle position now? If so, jump
.chkRight:
	; Otherwise, we're on the rightmost one.
	ld   a, [wOrdSelP2CharSel0]
	and  a							; Is the rightmost char already selected? (wOrdSelP2CharSel0 != 0)
	jr   z, .moveOk					; If not, jump
	; Otherwise, increment the cursor position back
	ld   a, [wOrdSelP2CursorPos]
	inc  a
	ld   [wOrdSelP2CursorPos], a
	ret  
.chkMid:
	ld   a, [wOrdSelP2CharSel1]
	and  a							; Is the middle char already selected?	
	jr   z, .moveOk					; If not, jump
	ld   a, [wOrdSelP2CharSel0]
	and  a							; Is the rightmost char already selected?	
	jr   z, .moveSkipOk				; If not, jump (always the case)
	; [TCRF] Unreachable code. Would be possible to reach it only if the the third character wasn't autoselected.
	ld   a, [wOrdSelP2CursorPos]
	inc  a
	ld   [wOrdSelP2CursorPos], a
	ret  
.moveSkipOk:
	; Move cursor again to the right, to skip the middle char
	ld   a, [wOrdSelP2CursorPos]
	dec  a
	ld   [wOrdSelP2CursorPos], a
	ld   a, [wOBJInfo_Pl2+iOBJInfo_X]
	add  a, TILE_H*3			; iOBJInfo_X += $18
	ld   [wOBJInfo_Pl2+iOBJInfo_X], a
.moveOk:
	; Finally, move the cursor sprite to the right
	ld   a, [wOBJInfo_Pl2+iOBJInfo_X]
	add  a, TILE_H*3			; iOBJInfo_X += $18
	ld   [wOBJInfo_Pl2+iOBJInfo_X], a
	ret
	
; =============== OrdSel_LoadCharGFX1P ===============
; Copies to VRAM the graphics for the specified character.
;
; 1P-only, as it horizontally flips the graphics, making them face right.
;
; This requires OrdSel_DecompressCharGFX to be called first, as it expects 
; an uncompressed copy of the character GFX inside the LZSS buffer.
;
; IN
; -  C: Character ID * 2
; - DE: Destination ptr in VRAM
OrdSel_LoadCharGFX1P:
	; Get "tilemap" ptr + length
	call OrdSel_GetCharBGXPtr
	
	; For every tile in the "tilemap" copy the GFX it points to to VRAM.
	; This is used to copy the GFX into the VRAM locations required by BG_OrdSel_Char1P.
.loop:
	push bc
		push hl
			call OrdSel_GetCharTileGFXPtr	; Get GFX ptr
			call CopyTilesHBlankFlipX		; Copy tile to VRAM
		pop  hl
		inc  hl		; TileIdPtr++
	pop  bc
	dec  b			; Copied all tiles?
	jp   nz, .loop	; If not, jump
	ret
	
; =============== OrdSel_LoadCharGFX2P ===============
; Like OrdSel_LoadCharGFX1P, but the graphics aren't horizontally flipped.
OrdSel_LoadCharGFX2P:
	; Get "tilemap" ptr + length
	call OrdSel_GetCharBGXPtr
	
	; For every tile in the "tilemap" copy the GFX it points to to VRAM.
	; This is used to copy the GFX into the VRAM locations required by BG_OrdSel_Char2P.
.loop:
	push bc
		push hl
			call OrdSel_GetCharTileGFXPtr	; Get GFX ptr
			call CopyTiles					; Copy tile to VRAM
		pop  hl
		inc  hl		; TileIdPtr++
	pop  bc
	dec  b			; Copied all tiles?
	jp   nz, .loop	; If not, jump
	ret
	
; =============== OrdSel_GetCharBGXPtr ===============
; Gets a pointer to the start of the special character-specific "tilemap".
;
; See OrdSel_CharBGXPtrTable for more info.
;
; IN
; - C: Character ID * 2
; OUT
; - HL: Ptr to "tilemap"
; - B: Number of tiles
OrdSel_GetCharBGXPtr:

	;
	; "Tilemap" ptr
	;
	ld   a, c				
	push de
		; Index the ptr table by CharId
		ld   l, a						; HL = CharId * 2
		ld   h, $00
		ld   de, OrdSel_CharBGXPtrTable	; DE = Ptr table
		add  hl, de						; Offset it
		; Read out the entry to DE
		ld   e, [hl]		
		inc  hl
		ld   d, [hl]
		; And move it to HL
		push de
		pop  hl
		
		;
		; Number of tiles.
		;
		; Each "tilemap" is $12 tiles long (therefore, the actual tilemap copied to VRAM is also same size),
		; as all characters are treated as a 3x6 partial tilemap.
		;
		ld   b, $12			; Always the same for every character			
	pop  de
	ret
	
; =============== OrdSel_GetCharTileGFXPtr ===============
; Gets the ptr to a tile in the uncompressed copy of GFXLZ_OrdSel_Char.
; IN
; - HL: Ptr to tile ID
; OUT
; - HL: Ptr to uncompressed tile GFX
; - B: Number of tiles to copy
OrdSel_GetCharTileGFXPtr:

	; A = Tile ID
	ld   a, [hl]
	
	; Multiply it by $10 (TILESIZE) into HL 
	ld   l, a
	ld   h, $00
REPT 4
	sla  l
	rl   h
ENDR

	; Offset the LZSS buffer by that amount to get the GFX ptr.
	; HL += DE
	push de
		ld   de, wLZSS_Buffer+$20
		add  hl, de
	pop  de
	
	; Always copy one tile at a time
	ld   b, $01
	ret
	

; =============== OrdSel_CopyCharBG_1P0 ===============
; Writes the tilemap for the leftmost 1P characters.
; IN
; - HL: Destination ptr in VRAM
OrdSel_CopyCharBG_1P0:
	ld   a, $80
	
; =============== OrdSel_CopyCharBG_1P ===============
; Writes the tilemap for a 1P character.
; IN
; - A: Tile ID base offset
; - HL: Destination ptr in VRAM
OrdSel_CopyCharBG_1P:
	ld   de, BG_OrdSel_Char1P
	
; =============== OrdSel_CopyCharBG ===============
; Writes the tilemap for a character to VRAM.
; IN
; - DE: Ptr to uncompressed tilemap
; - HL: Destination Ptr in VRAM
; - A: Tile ID base offset
OrdSel_CopyCharBG:
	ld   b, $03		; B = Rect Width
	ld   c, $06		; C = Rect Height
	jp   CopyBGToRectWithBase

; =============== OrdSel_CopyCharBG_1P1 ===============
; Writes the tilemap for the 1P character in the middle.
; - HL: Destination ptr in VRAM
OrdSel_CopyCharBG_1P1:
	ld   a, $92
	jr   OrdSel_CopyCharBG_1P
	
; =============== OrdSel_DecompressCharGFX ===============
; Loads the block of compressed graphics containing a frame for every character.
; These are copied to a temporary buffer, and them copied to VRAM by OrdSel_LoadCharGFX*P.
OrdSel_DecompressCharGFX:
	ld   hl, GFXLZ_OrdSel_Char
	ld   de, wLZSS_Buffer+$20
	jp   DecompressLZSS
	
; =============== OrdSel_AnimCursor ===============
; Cycles the cursor palette.
OrdSel_AnimCursor:
	; Update every other frame
	ld   a, [wTimer]
	and  a, $01
	ret  nz
	
	; Perform a smooth palette cycle by rotating the bits once.
	; As palettes are 2bpp, this causes the edge to transition from black to white and vice versa.
	;
	; This requires the palette to have a block of contiguous bits set (cursors start with $1E),
	; otherwise it will look broken when colors shift randomly.
	ldh  a, [rOBP0]
	rlca				; rOBP0 =<< 1
	ldh  [rOBP0], a
	ret
; =============== BG_OrdSel_Char*P ===============
; Normal tilemaps with relative tile IDs, shared across characters.
BG_OrdSel_Char1P: INCBIN "data/bg/ordsel_char1p.bin"
BG_OrdSel_Char2P: INCBIN "data/bg/ordsel_char2p.bin"

; =============== OrdSel_CharBGXPtrTable ===============
; These point to the start of the "tilemaps" for every character.
;
; These aren't normal tilemaps, and as such aren't copied to VRAM (that purpose goes to BG_OrdSel_Char1P and BG_OrdSel_Char2P).
; Instead, these are used to determine which tiles from an uncompressed copy of GFXLZ_OrdSel_Char have to be copied
; from the LZSS buffer to VRAM.
;
; Therefore, all of the "tile IDs" inside are relative to the start of said copy of GFXLZ_OrdSel_Char.
OrdSel_CharBGXPtrTable:
	dw BGX_OrdSel_Char_Kyo ; CHAR_ID_KYO     
	dw BGX_OrdSel_Char_Daimon ; CHAR_ID_DAIMON  
	dw BGX_OrdSel_Char_Terry ; CHAR_ID_TERRY   
	dw BGX_OrdSel_Char_Andy ; CHAR_ID_ANDY    
	dw BGX_OrdSel_Char_Ryo ; CHAR_ID_RYO     
	dw BGX_OrdSel_Char_Robert ; CHAR_ID_ROBERT  
	dw BGX_OrdSel_Char_Athena ; CHAR_ID_ATHENA  
	dw BGX_OrdSel_Char_Mai ; CHAR_ID_MAI     
	dw BGX_OrdSel_Char_Leona ; CHAR_ID_LEONA   
	dw BGX_OrdSel_Char_Geese ; CHAR_ID_GEESE   
	dw BGX_OrdSel_Char_Krauser ; CHAR_ID_KRAUSER 
	dw BGX_OrdSel_Char_MrBig ; CHAR_ID_MRBIG   
	dw BGX_OrdSel_Char_Iori ; CHAR_ID_IORI    
	dw BGX_OrdSel_Char_Mature ; CHAR_ID_MATURE  
	dw BGX_OrdSel_Char_Chizuru ; CHAR_ID_CHIZURU 
	dw BGX_OrdSel_Char_Goenitz ; CHAR_ID_GOENITZ 
	dw BGX_OrdSel_Char_MrKarate ; CHAR_ID_MRKARATE
	dw BGX_OrdSel_Char_OIori ; CHAR_ID_OIORI   
	dw BGX_OrdSel_Char_OLeona ; CHAR_ID_OLEONA  
	dw BGX_OrdSel_Char_OKagura ; CHAR_ID_KAGURA  

GFXLZ_OrdSel_BG: INCBIN "data/gfx/ordsel_bg.lzc"
BGLZ_OrdSel_Main: INCBIN "data/bg/ordsel_main.lzs"
BG_OrdSel_Num1: INCBIN "data/bg/ordsel_num1.bin"
BG_OrdSel_Num2: INCBIN "data/bg/ordsel_num2.bin"
BG_OrdSel_Num3: INCBIN "data/bg/ordsel_num3.bin"
GFXLZ_OrdSel_Char: INCBIN "data/gfx/ordsel_char.lzc"

BGX_OrdSel_Char_Kyo: INCBIN "data/bg/ordsel_char_kyo.bin"
BGX_OrdSel_Char_Daimon: INCBIN "data/bg/ordsel_char_daimon.bin"
BGX_OrdSel_Char_Terry: INCBIN "data/bg/ordsel_char_terry.bin"
BGX_OrdSel_Char_Andy: INCBIN "data/bg/ordsel_char_andy.bin"
BGX_OrdSel_Char_Ryo: INCBIN "data/bg/ordsel_char_ryo.bin"
BGX_OrdSel_Char_Robert: INCBIN "data/bg/ordsel_char_robert.bin"
BGX_OrdSel_Char_Athena: INCBIN "data/bg/ordsel_char_athena.bin"
BGX_OrdSel_Char_Mai: INCBIN "data/bg/ordsel_char_mai.bin"
BGX_OrdSel_Char_Leona: INCBIN "data/bg/ordsel_char_leona.bin"
BGX_OrdSel_Char_Geese: INCBIN "data/bg/ordsel_char_geese.bin"
BGX_OrdSel_Char_Krauser: INCBIN "data/bg/ordsel_char_krauser.bin"
BGX_OrdSel_Char_MrBig: INCBIN "data/bg/ordsel_char_mrbig.bin"
BGX_OrdSel_Char_Iori: INCBIN "data/bg/ordsel_char_iori.bin"
BGX_OrdSel_Char_Mature: INCBIN "data/bg/ordsel_char_mature.bin"
BGX_OrdSel_Char_Chizuru: INCBIN "data/bg/ordsel_char_chizuru.bin"
BGX_OrdSel_Char_Goenitz: INCBIN "data/bg/ordsel_char_goenitz.bin"
BGX_OrdSel_Char_MrKarate: INCBIN "data/bg/ordsel_char_mrkarate.bin"
BGX_OrdSel_Char_OIori: INCBIN "data/bg/ordsel_char_oiori.bin"
BGX_OrdSel_Char_OLeona: INCBIN "data/bg/ordsel_char_oleona.bin"
BGX_OrdSel_Char_OKagura: INCBIN "data/bg/ordsel_char_okagura.bin"
GFXLZ_OrdSel_OBJ: INCBIN "data/gfx/ordsel_obj.lzc"
INCLUDE "data/objlst/ordsel.asm"	
	
; 
; =============== END OF MODULE OrdSel ===============
;

; 
; =============== START OF MODULE Win ===============
;

; =============== SubModule_WinScr ===============
; This submodule handles the display of the win screen, without touching any of 
; the gameplay variables (ie: stage progression).
;
; This is structured like a module, but cannot be run directly -- it must be called by Module_Win.
SubModule_WinScr:
	;-----------------------------------
	rst  $10				; Stop LCD
	
	; Stop any existing player animation
	xor  a
	ld   [wGFXBufInfo_Pl1+iGFXBufInfo_TilesLeftA], a
	ld   [wGFXBufInfo_Pl1+iGFXBufInfo_TilesLeftB], a
	ld   [wGFXBufInfo_Pl2+iGFXBufInfo_TilesLeftA], a
	ld   [wGFXBufInfo_Pl2+iGFXBufInfo_TilesLeftB], a
	
	; Reset DMG pal
	ld   a, $FF
	ldh  [rBGP], a
	ldh  [rOBP0], a
	ldh  [rOBP1], a
	
	; Set SGB pal
	; [POI] The Japanese version uses its own unique screen configuration,
	;       which colors the middle section with a green background.
	;       The English version reuses the colors of the Order Select screen,
	;       resulting in a red background. This renders SCRPAL_STAGECLEAR unused.
IF REV_VER_2 == 0
	ld   de, SCRPAL_STAGECLEAR
ELSE
	; The English version reuses the palette config from the Order Select screen.
	ld   de, SCRPAL_ORDERSELECT
ENDC
	call HomeCall_SGB_ApplyScreenPalSet
		
	; Reset tilemap
	call ClearBGMap
	
	; The screen is divided into the three sections the usual way.
	; Set where the middle section is located
	ld   a, $18			; Start at this scanline
	ld   b, $5A			; End here
	call SetSectLYC
	
	; Decompress the special block of character win sprites to the buffer.
	;
	; To get around the sprite limit, only the last played character is a real animated sprite.
	; The other two are background graphics, and as a result aren't animated.
	ld   hl, GFXLZ_OrdSel_Char
	ld   de, wLZSS_Buffer+$20
	call DecompressLZSS
	
	; Init default win sprite.
	ld   hl, wOBJInfo_Winner+iOBJInfo_Status
	ld   de, OBJInfoInit_Pl1
	call OBJLstS_InitFrom
	
	; Update that win sprite with character-specific data, and draw team members
	call WinScr_InitChars
	
	; Set WINDOW position to align win quote.
	; Set to similar values of Cutscene_SharedInit.
	ld   a, $60
	ldh  [rWY], a
IF REV_LANG_EN == 0
	ld   a, $0F
ELSE
	ld   a, $07
ENDC
	ldh  [rWX], a
	
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_OBJSIZE|LCDC_WENABLE|LCDC_WTILEMAP|LCDC_ENABLE
	rst  $18				; Resume LCD
	;-----------------------------------
	
	; Enable LYC
	ldh  a, [rSTAT]
	or   a, STAT_LYC
	ldh  [rSTAT], a
	
	ei
	; Wait $09 frames
	call Task_PassControl_Delay09
	
	; Set DMG palettes 
	ld   a, $8C			; OBJ Palette (animated win sprite)
	ldh  [rOBP0], a
	ld   a, $2D			; BG Palette (second section, with other team chars if present)
	ldh  [rBGP], a
	ldh  [hScreenSect1BGP], a
	ld   a, $13			; BG/WIN Palette (first and third section)
	ldh  [hScreenSect0BGP], a
	ldh  [hScreenSect2BGP], a
	
	; Play stage win BGM
	ld   a, BGM_STAGECLEAR
	call HomeCall_Sound_ReqPlayExId_Stub
	
	;--
	;
	; Print out the Win Quote for the character wWinPlInfo is pointing to.
	;
	
	; Make the win pose animates every frame the TextPrinter runs.
	ld   a, BANK(WinScr_OBJLstAnim)
	ld   [wTextPrintFrameCodeBank], a
	ld   hl, wTextPrintFrameCodePtr_Low
	ld   [hl], LOW(WinScr_OBJLstAnim)
	inc  hl
	ld   [hl], HIGH(WinScr_OBJLstAnim)
	
	; Read out the wPlInfo of the player who won to BC
	ld   a, [wWinPlInfoPtr_Low]		
	ld   c, a
	ld   a, [wWinPlInfoPtr_High]
	ld   b, a
	; Use iPlInfo_CharId as table offset
	ld   hl, iPlInfo_CharId			
	add  hl, bc							; Seek to iPlInfo_CharId
	ld   d, $00							; DE = iPlInfo_CharId
	ld   e, [hl]
	; Index the table
	ld   hl, WinScr_CharTextPtrTbl		; HL = Ptr to table base
	add  hl, de	
	; Read out the ptr
	ld   e, [hl]						; Read out the entry to DE
	inc  hl
	ld   d, [hl]
	push de								; HL = Ptr to the character-specific TextC_* structure.
	pop  hl
	ld   de, WINDOWMap_Begin			; Start at the top of the WINDOW layer
	ld   b, BANK(TextC_Win_Marker)		; The TextC ptr points to BANK $1C
	ld   c, $04							; 4 frames between between letter printing
IF REV_VER_2 == 0
	ld   a, TXT_PLAYSFX|TXT_ALLOWFAST	; Play SGB SFX for every letter + allow speeding up text printing
ELSE
	ld   a, TXT_ALLOWFAST				; The English version doesn't play any SFX
ENDC
	call TextPrinter_MultiFrameFarCustomPos
	;--
	
	; Wait a bit after the printing finishes
	call WnScr_IdleWait
	
	; Reset DMG pal
	ld   a, $FF
	ldh  [rBGP], a
	ldh  [rOBP0], a
	ldh  [rOBP1], a
	ldh  [hScreenSect1BGP], a
	
	; Reset tilemap
	call ClearBGMap
	
	; With the win screen gone, disable the screen sections
	ld   hl, wMisc_C028
	res  MISCB_USE_SECT, [hl]
	xor  a
	ldh  [rSTAT], a
	; Remove player sprite mapping
	ld   [wOBJInfo_Winner+iOBJInfo_Status], a
	ld   [wOBJInfo_Winner+iOBJInfo_X], a
	ld   [wOBJInfo_Winner+iOBJInfo_Y], a
	; Force stop GFX loading
	xor  a
	ld   [wGFXBufInfo_Pl1+iGFXBufInfo_TilesLeftA], a
	ld   [wGFXBufInfo_Pl1+iGFXBufInfo_TilesLeftB], a
	ld   [wGFXBufInfo_Pl2+iGFXBufInfo_TilesLeftA], a
	ld   [wGFXBufInfo_Pl2+iGFXBufInfo_TilesLeftB], a
	
	; Wait a frame to give time for the screen to disable itself, and return.
	jp   Task_PassControl_NoDelay
	
; =============== WinScr_OBJLstAnim ===============
; Helper subroutine setup to be called by TextPrinter_MultiFrame to
; animate the player sprite every frame.
WinScr_OBJLstAnim:
	ld   hl, wOBJInfo_Winner
	jp   OBJLstS_DoAnimTiming_NoLoop
	
; =============== WinScr_InitChars ===============	
; Initializes the player characters for the Win Screen.
; This will load the animation for the sprite mapping for the active character, 
; and the GFX/tilemap for the other two team members.
WinScr_InitChars:

	; BC = Ptr to winner wPlInfo
	; Since the wPlInfo gets untouched from the end of the stage, it will still
	; contain useful info, like the character ID we won the stage as.
	ld   a, [wWinPlInfoPtr_Low]
	ld   c, a
	ld   a, [wWinPlInfoPtr_High]
	ld   b, a
	
	;
	; Initialize and use wOBJInfo_Winner to display the animated sprite of the winner.
	; Both 1P and 2P use this slot in the win screen.
	;
	push bc
		;
		; Index the table that assigns animations for every character.
		; Each entry in this table is 4 bytes long, so:
		;
		
		; DE = iPlInfo_CharId * 2
		ld   hl, iPlInfo_CharId
		add  hl, bc		; Seek to iPlInfo_CharId
		ld   d, $00		; DE = iPlInfo_CharId
		ld   e, [hl]
		sla  e			; DE << 1
		rl   d
		; Index the table
		ld   hl, WinScr_CharAnimTbl
		add  hl, de
		; Move the ptr to BC
		push hl
		pop  bc
		
		;
		; Update the sprite mapping.
		;
		
		; Update sprite mapping status
		ld   de, wOBJInfo_Winner+iOBJInfo_Status
		ld   a, [de]			; Get status
		and  a, $FF^OST_ANIMEND	; [POI] Not necessary, as the OBJInfo got reinitialized.
		or   a, OST_VISIBLE		; Display the sprite mapping
		ld   [de], a			; Save it back
		
		; Copy over the animation info from the previously indexed table entry
		ld   hl, iOBJInfo_BankNum
		add  hl, de
		ld   a, [bc]	; Read byte0
		ldi  [hl], a	; Copy it to iOBJInfo_BankNum
		inc  bc
		ld   a, [bc]	; Read byte1
		ldi  [hl], a	; Copy it to iOBJInfo_OBJLstPtrTbl_Low
		inc  bc
		ld   a, [bc]	; Read byte2
		ldi  [hl], a	; Copy it to iOBJInfo_OBJLstPtrTbl_High
		inc  bc
		xor  a
		ld   [hl], a	; Restart animation (iOBJInfo_OBJLstPtrTblOffset = 0)

		; Center the sprite
		ld   hl, iOBJInfo_X
		add  hl, de
		ld   a, $50		; X Position $50
		ldi  [hl], a
		inc  hl
		ld   [hl], $20	; Y Position $20
		
		; Update the animation speed from the last byte of the entry
		ld   hl, iOBJInfo_FrameLeft
		add  hl, de
		ld   a, [bc]	; Read byte3
		ldi  [hl], a	; Copy it to iOBJInfo_FrameLeft
		ld   [hl], a	; Copy it to iOBJInfo_FrameTotal
		
		push de
		pop  hl
		call OBJLstS_DoAnimTiming_Initial
	pop  bc
	
	;
	; Draw the other team members to the tilemap, if applicable.
	;
	
	;
	; The game doesn't reorder the character slots for team members (iPlInfo_TeamCharId*),
	; so depending on how many team members lost, pick different character slots.
	;
	; Note these aren't consistent with the order of character icons in the team, but who cares.
	;
	ld   hl, iPlInfo_TeamLossCount
	add  hl, bc
	ld   a, [hl]
	cp   $01		; Did 1 member lose?
	jr   z, .loss1	; If so, jump
	cp   $02		; Did 2 members lose?
	jr   z, .loss2	; If so, jump
	; Otherwise, no members lost
	
; =============== mWinDrawSecChar ===============
; Generates code to draw the other team members to the tilemap.
; IN
; - 1: Field for the character on the left
; - 2: Field for the character on the right
mWinDrawSecChar: MACRO
	;
	; Draw the character on the left facing right.
	;
	ld   hl, \1
	add  hl, bc			; Seek to team char id
	ld   a, [hl]		; A = CharId
	cp   CHAR_ID_NONE	; Is there any character on this slot?
	jr   z, .drawR_\@	; If not, skip
	
	; Otherwise, draw it
	ld   de, $8800		; DE = Destination ptr for char GFX
	push bc
		ld   c, a					; C = CharId
		call OrdSel_LoadCharGFX1P	; Copy them to DE, horizontally flipped
		call .copyCharBG_L	; Update the tilemap
	pop  bc
.drawR_\@:
	;
	; Draw the character on the right facing left.
	;
	ld   hl, \2
	add  hl, bc			; Seek to team char id
	ld   a, [hl]		; A = CharId
	cp   CHAR_ID_NONE	; Is there any character on this slot?
	jr   z, .ret		; If not, return (this never happens, there are no 2-character teams)
	; Otherwise, draw it
	ld   de, $8920		; DE = Destination ptr for char GFX
	ld   c, a			; C = CharId
	call OrdSel_LoadCharGFX2P	; Copy them to DE
	; Fall-through to .copyCharBG_R
ENDM
	
.loss0:
	; With no losses, draw the team members in their normal order
	mWinDrawSecChar iPlInfo_TeamCharId1, iPlInfo_TeamCharId2
	jr   .copyCharBG_R
.loss1:
	; With 1 loss, iPlInfo_TeamCharId0 and iPlInfo_TeamCharId1 get switched 
	mWinDrawSecChar iPlInfo_TeamCharId0, iPlInfo_TeamCharId2
	jr   .copyCharBG_R
.loss2:
	; With 2 losses, iPlInfo_TeamCharId2 pushes both back
	mWinDrawSecChar iPlInfo_TeamCharId0, iPlInfo_TeamCharId1
	; Fall-through
	
; =============== .copyCharBG_R ===============
; Writes the tilemap for the team member on the right, facing left.
.copyCharBG_R:
	ld   hl, $988E				; Destination ptr to tilemap
	ld   de, BG_OrdSel_Char2P	; Ptr to uncompressed tilemap
	ld   a, $92					; Tile ID base offset
	jp   OrdSel_CopyCharBG
; =============== .copyCharBG_L ===============
; Writes the tilemap for the team member on the left, facing right.
.copyCharBG_L:
	ld   hl, $9883		; Destination ptr to tilemap
	call OrdSel_CopyCharBG_1P0
.ret:
	ret

; =============== WnScr_IdleWait ===============
; Waits for $F0 frames showing the Win Screen.
; OUT
; - C flag: If set, the wait ended prematurely
WnScr_IdleWait:
	ld   b, $F0	; B = Number of frames
.loop:
	; If any player presses START, the wait ends early
	ldh  a, [hJoyNewKeys]
	bit  KEYB_START, a
	jp   nz, .abort
	ldh  a, [hJoyNewKeys2]
	bit  KEYB_START, a
	jp   nz, .abort
	
	; Continue animating the player sprite
	ld   hl, wOBJInfo_Winner
	call OBJLstS_DoAnimTiming_NoLoop
	
	; Wait a frame
	call Task_PassControl_NoDelay
	
	dec  b			; Are we finished?
	jp   nz, .loop	; If not, loop
	
	xor  a	; C flag clear
	ret
.abort:
	scf		; C flag set
	ret
	
; =============== WinScr_CharAnimTbl ===============
; This table assigns every character to its own win animation.
; FORMAT
; - 0-2: Ptr to sprite mapping table with bank number (iOBJInfo_BankNum + iOBJInfo_OBJLstPtrTbl)
; - 3: Animation speed (iOBJInfo_FrameLeft / iOBJInfo_FrameTotal)
;      These are all set to 8 in the Japanese version, while the English version changes some of them.
WinScr_CharAnimTbl:
	
	; CHAR_ID_KYO
	dp OBJLstPtrTable_Kyo_WinB ; BANK $07
	db $08
	
	; CHAR_ID_DAIMON
	dp OBJLstPtrTable_Daimon_WinB ; BANK $09
	db $08

	; CHAR_ID_TERRY
	dp OBJLstPtrTable_Terry_WinA ; BANK $09
	db $08

	; CHAR_ID_ANDY
	dp OBJLstPtrTable_Andy_WinB ; BANK $08
	db $08

	; CHAR_ID_RYO
	dp OBJLstPtrTable_Ryo_WinB ; BANK $0A
IF REV_VER_2 == 0
	db $08
ELSE
	db $03
ENDC

	; CHAR_ID_ROBERT
	dp OBJLstPtrTable_Robert_WinB ; BANK $07
	db $08

	; CHAR_ID_ATHENA
	dp OBJLstPtrTable_Athena_WinB ; BANK $08
IF REV_VER_2 == 0
	db $08
ELSE
	db $06
ENDC

	; CHAR_ID_MAI
	dp OBJLstPtrTable_Mai_WinB ; BANK $08
IF REV_VER_2 == 0
	db $08
ELSE
	db $04
ENDC

	; CHAR_ID_LEONA
	dp OBJLstPtrTable_Leona_WinB ; BANK $0A
	db $08

	; CHAR_ID_GEESE
	dp OBJLstPtrTable_Geese_WinB ; BANK $07
IF REV_VER_2 == 0
	db $08
ELSE
	db $06
ENDC

	; CHAR_ID_KRAUSER
	dp OBJLstPtrTable_Krauser_WinB ; BANK $09
	db $08

	; CHAR_ID_MRBIG
	dp OBJLstPtrTable_MrBig_WinB ; BANK $07
	db $08

	; CHAR_ID_IORI
	dp OBJLstPtrTable_Iori_WinB ; BANK $05
	db $08

	; CHAR_ID_MATURE
	dp OBJLstPtrTable_Mature_WinB ; BANK $09
	db $08

	; CHAR_ID_CHIZURU
	dp OBJLstPtrTable_Chizuru_WinB ; BANK $05
	db $08

	; CHAR_ID_GOENITZ
	dp OBJLstPtrTable_Goenitz_WinB ; BANK $08
	db $08

	; CHAR_ID_MRKARATE
	dp OBJLstPtrTable_MrKarate_WinA ; BANK $0A
IF REV_VER_2 == 0
	db $08
ELSE
	db $03
ENDC

	; CHAR_ID_OIORI
IF REV_VER_2 == 0
	dp OBJLstPtrTable_OIori_WinB ; BANK $05
	db $08
ELSE
	dp OBJLstPtrTable_OIori_Intro  ; BANK $05
	db $03
ENDC

	; CHAR_ID_OLEONA
	dp OBJLstPtrTable_OLeona_WinB ; BANK $0A
	db $08

	; CHAR_ID_KAGURA
	dp OBJLstPtrTable_Kagura_WinB ; BANK $05
IF REV_VER_2 == 0
	db $08
ELSE
	db $06
ENDC	

; =============== WinScr_CharTextPtrTbl ===============
; This table maps every character to its own win quote.
; These pointers all point to BANK $1C.
WinScr_CharTextPtrTbl:
	dw TextC_Win_Kyo ; CHAR_ID_KYO
	dw TextC_Win_Daimon ; CHAR_ID_DAIMON
	dw TextC_Win_Terry ; CHAR_ID_TERRY
	dw TextC_Win_Andy ; CHAR_ID_ANDY
	dw TextC_Win_Ryo ; CHAR_ID_RYO
	dw TextC_Win_Robert ; CHAR_ID_ROBERT
	dw TextC_Win_Athena ; CHAR_ID_ATHENA
	dw TextC_Win_Mai ; CHAR_ID_MAI
	dw TextC_Win_Leona ; CHAR_ID_LEONA
	dw TextC_Win_Geese ; CHAR_ID_GEESE
	dw TextC_Win_Krauser ; CHAR_ID_KRAUSER
	dw TextC_Win_MrBig ; CHAR_ID_MRBIG
	dw TextC_Win_Iori ; CHAR_ID_IORI
	dw TextC_Win_Mature ; CHAR_ID_MATURE
	dw TextC_Win_Chizuru ; CHAR_ID_CHIZURU
	dw TextC_Win_Goenitz ; CHAR_ID_GOENITZ
	dw TextC_Win_MrKarate ; CHAR_ID_MRKARATE
	dw TextC_Win_OIori ; CHAR_ID_OIORI
	dw TextC_Win_OLeona ; CHAR_ID_OLEONA
	dw TextC_Win_Kagura ; CHAR_ID_KAGURA
	
; =============== END OF BANK ===============
; Junk area below.
	mIncJunk "L1E7F62"