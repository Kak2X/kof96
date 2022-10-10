; 
; =============== START OF MODULE CharSel ===============
;
; =============== Module_CharSel ===============
; EntryPoint for character select screen. Called by rst $00 jump from Module_Title.
L1E4000:
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
	or   a						; Playing on the Pl1 side? (== ACTIVE_CTRL_PL1)
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
	bit  LASTWIN_PL1, a					; Did the CPU win?
	jp   z, .clearCPUTeam				; If not, jump
	jp   .lost				
	
.cpu2P:
	; Same thing as above, except when playing as 1P
	
	ld   a, $01							; 2P CPU autopicks team
	ld   [wCharSelRandom2P], a
	
	ld   hl, wCharSelP2Char0			; HL = Cursor position
	ld   de, wCharSelP2CursorPos		; DE = Cursor position
	ld   a, [wLastWinner]
	bit  LASTWIN_PL2, a					; Did the other player win?
	jp   z, .clearCPUTeam				; If not, jump
	
.lost:
	; The player lost the previous match, so the CPU keeps its opponents.
	
	; Additionally, if we lost to a boss, we have to set their selected "team" manually.
	; This is because they go alone instead of being part of a team. 
	; If we didn't check this, the game would try to select three characters anyway.
	ld   a, [wRoundSeqId]
	cp   STAGE_KAGURA		; Did we lose to Kagura?
	jp   z, .lostOnBoss		; If so, jump
	cp   STAGE_GOENITZ		; Did we lose to Goenitz?
	jp   z, .lostOnBoss		; If so, jump
	jp   .chkInitialMode
	
.lostOnBoss:
	
	; Retrieve the current wRoundSeqTbl value.
	; The index is high enough that the value isn't stored as CHARSEL_ID_*, but directly as CHAR_ID_*.
	;                                                                    (see ModeSelect_MakeRoundSeq)
	push hl
		ld   hl, wRoundSeqTbl	; HL = Sequence table
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
	call CharSel_IsVSRandCharEnabled	; Are *both players* randomizing their teams?
	jp   nc, .chkInitialMode			; If not, jump
	ld   a, $01							; Otherwise, set the autopicker flag for both
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
	
	; Don't draw the two other placeholders if we're in a boss round.
	; No "boss rounds" in VS mode
	ld   a, [wPlayMode]
	bit  MODEB_VS, a			; Playing in VS mode?
	jp   nz, .team1PDrawEmpty	; If so, jump
	; 2P should be the active player
	ld   a, [wJoyActivePl]
	or   a						; Are we playing on the 1P side? (wJoyActivePl == ACTIVE_CTRL_PL1)
	jp   z, .team1PDrawEmpty	; If so, jump
	
	; Round sequence check
	ld   a, [wRoundSeqId]
	cp   STAGE_KAGURA			; Fighting Kagura next?
	jp   z, .team2PDraw			; If so, skip
	cp   STAGE_GOENITZ			; Fighting Goenitz next?
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
	
	; Don't draw the two other placeholders if we're in a boss round.
	; No "boss rounds" in VS mode
	ld   a, [wPlayMode]
	bit  MODEB_VS, a			; Playing in VS mode?
	jp   nz, .team2PDrawEmpty	; If so, jump
	; 1P should be the active player
	ld   a, [wJoyActivePl]
	or   a						; Are we playing on the 1P side? (wJoyActivePl == ACTIVE_CTRL_PL1)
	jp   nz, .team2PDrawEmpty	; If *not*, jump
	
	; Round sequence check
	ld   a, [wRoundSeqId]
	cp   STAGE_KAGURA			; Fighting Kagura next?
	jp   z, .fillSelChars1P		; If so, skip
	cp   STAGE_GOENITZ			; Fighting Goenitz next?
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
	ld   a, [wPlInfo_Pl1+iPlInfo_Status]
	bit  PSB_CPU, a			; Is this character a CPU?
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
	ld   a, [wPlInfo_Pl2+iPlInfo_Status]
	bit  PSB_CPU, a			; Is this character a CPU?
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
	
	
	call Pl_Unknown_InitBeforeRound
	call Serial_DoHandshake
	
	;
	; In VS mode, $C166 = Rand & $03
	;
	ld   a, [wPlayMode]
	bit  MODEB_VS, a	; Playing in VS mode? 
	jp   z, .initEnd		; If not, skip
	call Rand
	and  a, $03
	ld   [$C166], a
	
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
	jp   nc, L00179D	; If not, jump
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
	call CharSelect_IsLastWinner						;
	jp   c, .confirm					; If so, jump
	call CharSel_IsVSRandCharEnabled	; Randomizing characters in VS mode?
	jp   c, .confirm					; If so, there's no rerolling
	
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
	ld   a, SFX_CHARCURSORMOVE
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
	;
	call Rand			; A = Random byte
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
			
			; No round sequence in VS modes
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
			; CharId = wRoundSeqTbl[wRoundSeqId + TeamPos]
			;          Where TeamPos is the 0-based number of the first free slot found.
			;
			
			; Index wRoundSeqTbl by wRoundSeqId
			ld   a, [wRoundSeqId]	; A = SeqId
			ld   de, wRoundSeqTbl	; DE = SeqTbl
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
; - 5: Alternate char id
; - 6: Alternate character id (CHAR_ID_*)
; - 7: Alternate portrait id (CHARSEL_ID_*)
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
	cp   \2	; Is normal character selectable?
	jr   z, .setAlt_\@	; If so, jump (switch to alternate)
.setNorm_\@:
	;
	; Switch from alternate to normal portrait
	;
	
	; Set normal character ID (ie: CHAR_ID_IORI) to wCharSelIdMapTbl entry
	ld   [hl], \2		
	
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
	ld   [hl], \5
	
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
	;                 | OBJINFO          | NORMAL                                         | ALT
	;                 |                  | CHAR ID            PORTRAIT ID         TILE ID | CHAR ID         PORTRAIT ID             TILE ID
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
	
	; Play a sound effect
	ld   a, SND_ID_26
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
	ld   hl, $C1AA
	ld   de, $D6C0
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
	; In single mode, check which round we're in
	ld   a, [wPlayMode]
	bit  MODEB_VS, a		; Playing in VS mode?
	jr   z, .chkRound		; If not, jump
	
	; In VS *serial* mode, don't allow exiting
	ld   hl, wMisc_C025
	bit  MISCB_IS_SGB, [hl]	; Running on a SGB?
	jr   z, .no				; If not, jump
	
	; Skip round check, it's not applicable in VS mode
	jr   .chkSel
	
.chkRound:
	; No exit on next rounds
	ld   a, [wRoundSeqId]
	or   a					; Beaten at least one round? (not the first char select screen)
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
	ld   hl, wRoundSeqTbl	; HL = Round sequence table
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
; - HL: Ptr to start of wRoundSeqTbl 
.drawCross:
	bit  CHARSEL_POSFB_BOSS, a		; Did we beat this opponent yet?
	ret  z							; If not, return
	and  a, $FF^CHARSEL_POSF_BOSS	; Filter out flag to get real cursor pos id
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
	db $08 ; String length
	db "        "
; Actual player names.
; @ is a stand-in for "r.".
TextC_Char_Kyo:
	db $03
	db "KYO"
TextC_Char_Daimon:
	db $06
	db "DAIMON"
TextC_Char_Terry:
	db $05
	db "TERRY"
TextC_Char_Andy:
	db $04
	db "ANDY"
TextC_Char_Ryo:
	db $03
	db "RYO"
TextC_Char_Robert:
	db $06
	db "ROBERT"
TextC_Char_Athena:
	db $06
	db "ATHENA"
TextC_Char_Mai:
	db $03
	db "MAI"
TextC_Char_Leona:
	db $05
	db "LEONA"
TextC_Char_Geese:
	db $05
	db "GEESE"
TextC_Char_Krauser:
	db $07
	db "KRAUSER"
TextC_Char_MrBig:
	db $05
	db "M@BIG"
TextC_Char_Iori:
	db $04
	db "IORI"
TextC_Char_Mature:
	db $06
	db "MATURE"
TextC_Char_Chizuru:
	db $07
	db "CHIZURU"
TextC_Char_Goenitz:
	db $07
	db "GOENITZ"
TextC_Char_MrKarate:
	db $08
	db "M@KARATE"
TextC_Char_OIori:
	db $05
	db "IORI`"
TextC_Char_OLeona:
	db $06
	db "LEONA`"
TextC_Char_Kagura:
	db $06
	db "KAGURA"
	
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
	db $05
	db "START"
TextC_CharSel_StartBlank:
	db $05
	db "     "
	
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

; =============== CharSel_IsVSRandCharEnabled ===============
; Checks if the automatic character picker is enabled for both players in VS mode.
; OUT
; - C flag: If set, the autopicker is enabled
CharSel_IsVSRandCharEnabled:
	; Since CPUs don't exist in VS mode, the PS_CPU flag is reused to
	; check if both players enabled the autopicker.
	ld   a, [wPlayMode]
	bit  MODEB_VS, a						; Are we in VS mode?
	jp   z, .notSet							; If not, jump
	ld   a, [wPlInfo_Pl1+iPlInfo_Status]
	ld   b, a								; B = P1 status
	ld   a, [wPlInfo_Pl2+iPlInfo_Status]	; A = P2 status
	and  b									; Merge them
	and  a, PS_CPU							; Is the CPU flag set on both?
	jr   z, .notSet							; If not, jump
.set:
	scf  ; Autopicker enabled
	ret 
.notSet:
	scf
	ccf  ; Autopicker disabled
	ret
	
; =============== CharSelect_IsCPUOpponent ===============
; Checks if the current player is a CPU opponent, meaning it's not actively
; controlled by the GB's joypad input.
;
; Note that this is separate from a player being CPU-controlled, as in CPU vs CPU matches
; the player does get to control one of the cursors.
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
	or   a						; Playing on the 1P side? (== ACTIVE_CTRL_PL1)
	jp   z, .retClear			; If so, return clear
	
	jp   .retSet
.chkCpu2P:
	; Currently handling 2P.
	; For 2P to be a CPU opponent, 1P must have control on the char select screen
	ld   a, [wJoyActivePl]
	or   a						; Playing on the 2P side? (!= ACTIVE_CTRL_PL1)
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
	bit  LASTWIN_PL1, a		; Did 1P win the last round?
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
	bit  LASTWIN_PL2, a		; Did 2P win the last round?
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
	db CHAR_ID_KYO,    CHAR_ID_ANDY,    CHAR_ID_TERRY,    CHAR_ID_RYO,      CHAR_ID_ROBERT,  CHAR_ID_IORI
	db CHAR_ID_DAIMON, CHAR_ID_MAI,     CHAR_ID_GEESE,    CHAR_ID_MRBIG,    CHAR_ID_KRAUSER, CHAR_ID_MATURE
	db CHAR_ID_ATHENA, CHAR_ID_CHIZURU, CHAR_ID_MRKARATE, CHAR_ID_MRKARATE, CHAR_ID_GOENITZ, CHAR_ID_LEONA
	; [TCRF] Unused entries in the list. Not used by tile flipping since it switches between hardcoded char IDs.
	;        These may have been used before the tile flipping was implemented, and still work properly.
	;        They all work as intended as they also have (unused) CharSel_CursorPosTable entries.
	db CHAR_ID_OIORI
	db CHAR_ID_OLEONA
	db CHAR_ID_KAGURA
.end:
; Relative tile IDs for portraits
BG_CharSel_Portrait: INCBIN "data/bg/charsel_portrait.bin"
BG_CharSel_EmptyPortrait: INCBIN "data/bg/charsel_emptyportrait.bin"
TextDef_CharSel_SingleTitle:
	dw $9823
	db $0E
	db "PLAYER  SELECT"
TextDef_CharSel_TeamTitle:
	dw $9824
	db $0C
	db "TEAM  SELECT"
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
	db $00 ; iOBJInfo_OBJLstFlagsOld
	db $28 ; iOBJInfo_X
	db $00 ; iOBJInfo_XSub
	db $40 ; iOBJInfo_Y
	db $00 ; iOBJInfo_YSub
	db $00 ; iOBJInfo_SpeedX
	db $00 ; iOBJInfo_SpeedXSub
	db $00 ; iOBJInfo_Unknown_09
	db $00 ; iOBJInfo_Unknown_0A
	db $00 ; iOBJInfo_RelX (auto)
	db $00 ; iOBJInfo_RelY (auto)
	db $00 ; iOBJInfo_TileIDBase
	db LOW($8000) ; iOBJInfo_VRAMPtr_Low
	db HIGH($8000) ; iOBJInfo_VRAMPtr_High
	db BANK(OBJLstPtrTable_CharSel_Cursor) ; iOBJInfo_BankNum (BANK $1E)
	db LOW(OBJLstPtrTable_CharSel_Cursor) ; iOBJInfo_OBJLstPtrTbl_Low
	db HIGH(OBJLstPtrTable_CharSel_Cursor) ; iOBJInfo_OBJLstPtrTbl_High
	db $00 ; iOBJInfo_OBJLstPtrTblOffset
	db $00 ; iOBJInfo_BankNumOld (N/A)
	db LOW(OBJLstPtrTable_CharSel_Cursor) ; iOBJInfo_OBJLstPtrTbl_LowOld
	db HIGH(OBJLstPtrTable_CharSel_Cursor) ; iOBJInfo_OBJLstPtrTbl_HighOld
	db $00 ; iOBJInfo_OBJLstPtrTblOffset
	db $00 ; iOBJInfo_OBJLstByte1 (auto)
	db $00 ; iOBJInfo_OBJLstByte2 (auto)
	db $00 ; iOBJInfo_Unknown_1A
	db $02 ; iOBJInfo_FrameLeft
	db $02 ; iOBJInfo_FrameTotal
	db LOW(wGFXBufInfo_Pl1) ; iOBJInfo_BufInfoPtr_Low
	db HIGH(wGFXBufInfo_Pl1) ; iOBJInfo_BufInfoPtr_High
	
OBJLstPtrTable_CharSel_Cursor:
	dw OBJLstHdrA_CharSel_CursorPl1P, OBJLSTPTR_NONE
	dw OBJLstHdrA_CharSel_CursorPl1PWide, OBJLSTPTR_NONE
	dw OBJLstHdrA_CharSel_CursorPl2P, OBJLSTPTR_NONE
	dw OBJLstHdrA_CharSel_CursorPl2PWide, OBJLSTPTR_NONE
	dw OBJLstHdrA_CharSel_CursorCPU1P, OBJLSTPTR_NONE
	dw OBJLstHdrA_CharSel_CursorCPU1PWide, OBJLSTPTR_NONE
	dw OBJLstHdrA_CharSel_CursorCPU2P, OBJLSTPTR_NONE
	dw OBJLstHdrA_CharSel_CursorCPU2PWide, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		
OBJLstHdrA_CharSel_CursorPl1P:
	db OLF_USETILEFLAGS|OLF_NOBUF ; iOBJLstHdrA_Flags
	db $00 ; iOBJLstHdrA_Byte1
	db $00 ; iOBJLstHdrA_Byte2
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID+FLAG
	db $28,$0B,$00 ; $00
	db $28,$13,$04 ; $01
	db $28,$08,$0C ; $02
	db $30,$18,$CC ; $03
		
OBJLstHdrA_CharSel_CursorPl1PWide:
	db OLF_USETILEFLAGS|OLF_NOBUF ; iOBJLstHdrA_Flags
	db $00 ; iOBJLstHdrA_Byte1
	db $00 ; iOBJLstHdrA_Byte2
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID+FLAG
	db $28,$17,$00 ; $00
	db $28,$1F,$04 ; $01
	db $28,$08,$0C ; $02
	db $30,$30,$CC ; $03
		
OBJLstHdrA_CharSel_CursorPl2P:
	db OLF_USETILEFLAGS|OLF_NOBUF ; iOBJLstHdrA_Flags
	db $00 ; iOBJLstHdrA_Byte1
	db $00 ; iOBJLstHdrA_Byte2
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID+FLAG
	db $38,$0C,$02 ; $00
	db $38,$14,$04 ; $01
	db $28,$18,$4C ; $02
	db $30,$08,$8C ; $03
		
OBJLstHdrA_CharSel_CursorPl2PWide:
	db OLF_USETILEFLAGS|OLF_NOBUF ; iOBJLstHdrA_Flags
	db $00 ; iOBJLstHdrA_Byte1
	db $00 ; iOBJLstHdrA_Byte2
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID+FLAG
	db $38,$18,$02 ; $00
	db $38,$20,$04 ; $01
	db $28,$30,$4C ; $02
	db $30,$08,$8C ; $03
	
OBJLstHdrA_CharSel_CursorCPU1P:
	db OLF_USETILEFLAGS|OLF_NOBUF ; iOBJLstHdrA_Flags
	db $00 ; iOBJLstHdrA_Byte1
	db $00 ; iOBJLstHdrA_Byte2
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID+FLAG
	db $29,$08,$06 ; $00
	db $29,$10,$08 ; $01
	db $29,$18,$0A ; $02
	db $28,$08,$0C ; $03
	db $30,$18,$CC ; $04
		
OBJLstHdrA_CharSel_CursorCPU1PWide:
	db OLF_USETILEFLAGS|OLF_NOBUF ; iOBJLstHdrA_Flags
	db $00 ; iOBJLstHdrA_Byte1
	db $00 ; iOBJLstHdrA_Byte2
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID+FLAG
	db $29,$14,$06 ; $00
	db $29,$1C,$08 ; $01
	db $29,$24,$0A ; $02
	db $28,$08,$0C ; $03
	db $30,$30,$CC ; $04
	
OBJLstHdrA_CharSel_CursorCPU2P:
	db OLF_USETILEFLAGS|OLF_NOBUF ; iOBJLstHdrA_Flags
	db $00 ; iOBJLstHdrA_Byte1
	db $00 ; iOBJLstHdrA_Byte2
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID+FLAG
	db $37,$08,$06 ; $00
	db $37,$10,$08 ; $01
	db $37,$18,$0A ; $02
	db $28,$18,$4C ; $03
	db $30,$08,$8C ; $04
		
OBJLstHdrA_CharSel_CursorCPU2PWide:
	db OLF_USETILEFLAGS|OLF_NOBUF ; iOBJLstHdrA_Flags
	db $00 ; iOBJLstHdrA_Byte1
	db $00 ; iOBJLstHdrA_Byte2
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID+FLAG
	db $37,$14,$06 ; $00
	db $37,$1C,$08 ; $01
	db $37,$24,$0A ; $02
	db $28,$30,$4C ; $03
	db $30,$08,$8C ; $04
		
OBJLstPtrTable_CharSel_Flip:
	dw OBJLstHdrA_CharSel_FlipP0, OBJLSTPTR_NONE
	dw OBJLstHdrA_CharSel_FlipP1, OBJLSTPTR_NONE
	dw OBJLstHdrA_CharSel_FlipP2, OBJLSTPTR_NONE
	dw OBJLstHdrA_CharSel_FlipP3, OBJLSTPTR_NONE
	dw OBJLstHdrA_CharSel_FlipP4, OBJLSTPTR_NONE
	dw OBJLstHdrA_CharSel_FlipP3, OBJLSTPTR_NONE
	dw OBJLstHdrA_CharSel_FlipP2, OBJLSTPTR_NONE
	dw OBJLstHdrA_CharSel_FlipP1, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		
OBJLstHdrA_CharSel_FlipP2:
	db OLF_NOBUF ; iOBJLstHdrA_Flags
	db $00 ; iOBJLstHdrA_Byte1
	db $00 ; iOBJLstHdrA_Byte2
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLst_CharSel_Flip0 ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_CharSel_FlipP0:
	db OLF_NOBUF ; iOBJLstHdrA_Flags
	db $00 ; iOBJLstHdrA_Byte1
	db $00 ; iOBJLstHdrA_Byte2
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLst_CharSel_Flip1 ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_CharSel_FlipP1:
	db OLF_NOBUF ; iOBJLstHdrA_Flags
	db $00 ; iOBJLstHdrA_Byte1
	db $00 ; iOBJLstHdrA_Byte2
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLst_CharSel_Flip2 ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_CharSel_FlipP4:
	db OLF_NOBUF ; iOBJLstHdrA_Flags
	db $00 ; iOBJLstHdrA_Byte1
	db $00 ; iOBJLstHdrA_Byte2
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLst_CharSel_Flip3 ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_CharSel_FlipP3:
	db OLF_NOBUF ; iOBJLstHdrA_Flags
	db $00 ; iOBJLstHdrA_Byte1
	db $00 ; iOBJLstHdrA_Byte2
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLst_CharSel_Flip4 ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLst_CharSel_Flip0:
	db $02 ; OBJ Count
	;    Y   X  ID+FLAG
	db $28,$13,$00 ; $00
	db $38,$13,$02 ; $01
		
OBJLst_CharSel_Flip1:
	db $04 ; OBJ Count
	;    Y   X  ID+FLAG
	db $28,$0C,$04 ; $00
	db $28,$14,$06 ; $01
	db $38,$0C,$08 ; $02
	db $38,$14,$0A ; $03
		
OBJLst_CharSel_Flip2:
	db $02 ; OBJ Count
	;    Y   X  ID+FLAG
	db $28,$10,$0C ; $00
	db $38,$10,$0E ; $01
		
OBJLst_CharSel_Flip3:
	db $04 ; OBJ Count
	;    Y   X  ID+FLAG
	db $28,$0C,$10 ; $00
	db $28,$14,$12 ; $01
	db $38,$0C,$14 ; $02
	db $38,$14,$16 ; $03
		
OBJLst_CharSel_Flip4:
	db $02 ; OBJ Count
	;    Y   X  ID+FLAG
	db $28,$10,$18 ; $00
	db $38,$10,$1A ; $01
; 
; =============== END OF MODULE CharSel ===============
;

; 
; =============== START OF MODULE OrdSel ===============
;
; =============== Module_OrdSel ===============
; EntryPoint for team order select screen. Called by rst $00 jump from Module_CharSel.
L1E626E:
Module_OrdSel:;I
	ld   sp, $DD00
	di
	rst  $10
	xor  a
	ldh  [rBGP], a
	ldh  [rOBP0], a
	ldh  [rOBP1], a
	ld   [wCharSelTeamFull], a
	ld   [wCharSelP1CursorMode], a
	ld   [wCharSelP2CursorMode], a
	ld   [wCharSelCurPl], a
	ld   [wCharSelRandom1P], a
	ld   [wCharSelRandom2P], a
	ld   [wLZSS_Buffer], a
	ld   [$C1CB], a
	ld   [$C1CC], a
	ld   [$C1CD], a
	ld   [$C1CE], a
	ld   [$C1CF], a
	ld   [$C1D0], a
	ld   [$C1D1], a
	ld   [$C1D2], a
	ld   [$C1D3], a
	ld   [$C1D4], a
	ld   [$C1D5], a
	ld   [$C1D6], a
	ld   [$C1D7], a
	ld   [$C1D8], a
	ld   [$C1D9], a
	ld   [$C1DA], a
	ld   [$C1DB], a
	ld   a, [wPlayMode]
	cp   $01
	jp   nz, L1E62E1
	ld   a, [wJoyActivePl]
	or   a
	jp   z, L1E62D9
L1E62D1: db $3E;X
L1E62D2: db $01;X
L1E62D3: db $EA;X
L1E62D4: db $B1;X
L1E62D5: db $C1;X
L1E62D6: db $C3;X
L1E62D7: db $EF;X
L1E62D8: db $62;X
L1E62D9:;J
	ld   a, $01
	ld   [wCharSelRandom2P], a
	jp   L1E62EF
L1E62E1: db $CD;X
L1E62E2: db $B4;X
L1E62E3: db $4E;X
L1E62E4: db $D2;X
L1E62E5: db $EF;X
L1E62E6: db $62;X
L1E62E7: db $3E;X
L1E62E8: db $01;X
L1E62E9: db $EA;X
L1E62EA: db $B1;X
L1E62EB: db $C1;X
L1E62EC: db $EA;X
L1E62ED: db $B2;X
L1E62EE: db $C1;X
L1E62EF:;J
	ld   de, SCRPAL_ORDERSELECT
	call HomeCall_SGB_ApplyScreenPalSet
	call ClearBGMap
	call ClearWINDOWMap
	xor  a
	ldh  [hScrollX], a
	ldh  [hScrollY], a
	ld   [wOBJScrollX], a
	ld   [wOBJScrollY], a
	ld   hl, $7BB7
	ld   de, $C1EA
	call DecompressLZSS
	ld   hl, $C1EA
	ld   de, Tiles_Begin
	ld   b, $1C
	call CopyTiles
	ld   hl, $6998
	ld   de, $C1EA
	call DecompressLZSS
	ld   hl, $C1EA
	ld   de, $9000
	ld   b, $5A
	call CopyTiles
	ld   hl, $6D22
	ld   de, $C1EA
	call DecompressLZSS
	ld   de, $C1EA
	ld   hl, $9803
	ld   b, $0E
	ld   c, $09
	call CopyBGToRect
	call L1E6937
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamCharId0]
	ld   de, $8800
	ld   c, a
	call L1E68D2
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamCharId1]
	cp   $FF
	jr   z, L1E6361
	ld   de, $8920
	ld   c, a
	call L1E68D2
	jr   L1E636B
L1E6361:;R
	ld   a, $01
	ld   [$C1D0], a
	ld   a, $FF
	ld   [$C1D1], a
L1E636B:;R
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamCharId2]
	cp   $FF
	jr   z, L1E637B
	ld   de, $8A40
	ld   c, a
	call L1E68D2
	jr   L1E6385
L1E637B:;R
	ld   a, $01
	ld   [$C1D2], a
	ld   a, $FF
	ld   [$C1D3], a
L1E6385:;R
	ld   a, [wPlInfo_Pl2+iPlInfo_TeamCharId0]
	ld   de, $8B60
	ld   c, a
	call L1E68E5
	ld   a, [wPlInfo_Pl2+iPlInfo_TeamCharId1]
	cp   $FF
	jr   z, L1E639F
	ld   de, $8C80
	ld   c, a
	call L1E68E5
	jr   L1E63A9
L1E639F:;R
	ld   a, $01
	ld   [$C1D6], a
	ld   a, $FF
	ld   [$C1D7], a
L1E63A9:;R
	ld   a, [wPlInfo_Pl2+iPlInfo_TeamCharId2]
	cp   $FF
	jr   z, L1E63B9
	ld   de, $8DA0
	ld   c, a
	call L1E68E5
	jr   L1E63C3
L1E63B9:;R
	ld   a, $01
	ld   [$C1D8], a
	ld   a, $FF
	ld   [$C1D9], a
L1E63C3:;R
	ld   hl, $9920
	call L1E6927
	ld   a, [$C1D0]
	cp   $00
	jr   nz, L1E63D6
	ld   hl, $9923
	call L1E6933
L1E63D6:;R
	ld   a, [$C1D2]
	cp   $00
	jr   nz, L1E63E5
	ld   hl, $9926
	ld   a, $A4
	call L1E6929
L1E63E5:;R
	ld   de, $695E
	ld   hl, $9931
	ld   a, $B6
	call L1E692C
	ld   a, [$C1D6]
	cp   $00
	jr   nz, L1E6402
	ld   de, $695E
	ld   hl, $992E
	ld   a, $C8
	call L1E692C
L1E6402:;R
	ld   a, [$C1D8]
	cp   $00
	jr   nz, L1E6414
	ld   de, $695E
	ld   hl, $992B
	ld   a, $DA
	call L1E692C
L1E6414:;R
	call ClearOBJInfo
	ld   hl, wOBJInfo_Pl1+iOBJInfo_Status
	ld   de, OBJInfoInit_CharSel_Cursor
	call OBJLstS_InitFrom
	ld   hl, wOBJInfo_Pl1+iOBJInfo_OBJLstPtrTbl_Low
	ld   [hl], $DB
	inc  hl
	ld   [hl], $7C
	ld   a, $00
	ld   [wOBJInfo_Pl1+iOBJInfo_X], a
	ld   a, $80
	ld   [wOBJInfo_Pl1+iOBJInfo_Y], a
	ld   hl, wOBJInfo_Pl2+iOBJInfo_Status
	ld   de, OBJInfoInit_CharSel_Cursor
	call OBJLstS_InitFrom
	ld   hl, wOBJInfo_Pl2+iOBJInfo_OBJLstPtrTbl_Low
	ld   [hl], $DB
	inc  hl
	ld   [hl], $7C
	ld   a, $88
	ld   [wOBJInfo_Pl2+iOBJInfo_X], a
	ld   a, $80
	ld   [wOBJInfo_Pl2+iOBJInfo_Y], a
	ld   hl, wOBJInfo2+iOBJInfo_Status
	ld   de, OBJInfoInit_CharSel_Cursor
	call OBJLstS_InitFrom
	ld   hl, wOBJInfo2+iOBJInfo_OBJLstFlags
	ld   [hl], $90
	ld   hl, wOBJInfo2+iOBJInfo_OBJLstPtrTbl_Low
	ld   [hl], $D5
	inc  hl
	ld   [hl], $7C
	ld   a, $32
	ld   [wOBJInfo2+iOBJInfo_X], a
	ld   a, $58
	ld   [wOBJInfo2+iOBJInfo_Y], a
	call Pl_Unknown_InitBeforeRound
	call Serial_DoHandshake
	ld   a, $C7
	rst  $18
	ei
	call Task_PassControl_NoDelay
	call Task_PassControl_NoDelay
	ld   a, $1E
	ldh  [rOBP0], a
	ld   a, $3E
	ldh  [rOBP1], a
	ld   a, $2D
	ldh  [rBGP], a
	ld   a, $81
	call HomeCall_Sound_ReqPlayExId_Stub
	call Task_PassControl_Delay1D
L1E6491:;J
	call L1E6940
	call JoyKeys_DoCursorDelayTimer
	ld   a, $00
	ld   [wCharSelCurPl], a
	call L1E6503
	ld   a, [wCharSelP1CursorMode]
	cp   $03
	jp   nz, L1E64AC
	ld   hl, wOBJInfo_Pl1+iOBJInfo_Status
	res  7, [hl]
L1E64AC:;J
	ld   a, $01
	ld   [wCharSelCurPl], a
	call L1E6503
	ld   a, [wCharSelP2CursorMode]
	cp   $03
	jp   nz, L1E64C1
	ld   hl, wOBJInfo_Pl2+iOBJInfo_Status
	res  7, [hl]
L1E64C1:;J
	ld   a, [wCharSelP1CursorMode]
	ld   hl, wCharSelP2CursorMode
	cp   a, [hl]
	jp   nz, L1E64D3
	cp   $03
	jp   nz, L1E64D3
	jp   L1E64D9
L1E64D3:;J
	call Task_PassControl_NoDelay
	jp   L1E6491
L1E64D9:;J
	ld   a, [$C1CF]
	ld   [wPlInfo_Pl1+iPlInfo_TeamCharId0], a
	ld   a, [$C1D1]
	ld   [wPlInfo_Pl1+iPlInfo_TeamCharId1], a
	ld   a, [$C1D3]
	ld   [wPlInfo_Pl1+iPlInfo_TeamCharId2], a
	ld   a, [$C1D5]
	ld   [wPlInfo_Pl2+iPlInfo_TeamCharId0], a
	ld   a, [$C1D7]
	ld   [wPlInfo_Pl2+iPlInfo_TeamCharId1], a
	ld   a, [$C1D9]
	ld   [wPlInfo_Pl2+iPlInfo_TeamCharId2], a
	call Task_PassControl_Delay3B
	jp   L00179D
L1E6503:;C
	ld   a, [wCharSelCurPl]
	or   a
	jp   nz, L1E6522
	ld   a, [wCharSelP1CursorMode]
	cp   $02
	jr   z, L1E6559
	ld   a, [wCharSelRandom1P]
	and  a, a
	jp   z, L1E653A
L1E6518: db $FE;X
L1E6519: db $01;X
L1E651A: db $CA;X
L1E651B: db $4D;X
L1E651C: db $65;X
L1E651D: db $3D;X
L1E651E: db $EA;X
L1E651F: db $B1;X
L1E6520: db $C1;X
L1E6521: db $C9;X
L1E6522:;J
	ld   a, [wCharSelP2CursorMode]
	cp   $02
	jr   z, L1E6559
	ld   a, [wCharSelRandom2P]
	and  a, a
	jp   z, L1E653A
	cp   $01
	jp   z, L1E6554
	dec  a
	ld   [wCharSelRandom2P], a
	ret
L1E653A:;J
	call CharSel_GetInput
	bit  4, a
	jp   nz, L1E6559
	bit  1, b
	jp   nz, L1E6792
	bit  0, b
	jp   nz, L1E6832
	ret
L1E654D: db $3E;X
L1E654E: db $3C;X
L1E654F: db $EA;X
L1E6550: db $B1;X
L1E6551: db $C1;X
L1E6552: db $18;X
L1E6553: db $05;X
L1E6554:;J
	ld   a, $3C
	ld   [wCharSelRandom2P], a
L1E6559:;JR
	ld   a, [wCharSelCurPl]
	or   a
	jp   nz, L1E6679
	ld   a, [wCharSelP1CursorMode]
	cp   $03
	ret  z
	ld   a, [wLZSS_Buffer]
	ld   b, a
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamCharId1]
	ld   hl, $C1D0
	dec  b
	jr   z, L1E65AD
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamCharId2]
	ld   hl, $C1D2
	dec  b
	jr   z, L1E65D9
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamCharId0]
	ld   hl, $C1CE
	push af
	ld   a, [wOBJInfo_Pl1+iOBJInfo_X]
	add  a, $18
	ld   [wOBJInfo_Pl1+iOBJInfo_X], a
	ld   a, [wLZSS_Buffer]
	ld   [$C1DA], a
	inc  a
	ld   [wLZSS_Buffer], a
	ld   a, [$C1D0]
	and  a, a
	jr   z, L1E65AA
	ld   a, [wOBJInfo_Pl1+iOBJInfo_X]
	add  a, $18
	ld   [wOBJInfo_Pl1+iOBJInfo_X], a
	ld   a, [wLZSS_Buffer]
	inc  a
	ld   [wLZSS_Buffer], a
L1E65AA:;R
	pop  af
	jr   L1E6602
L1E65AD:;R
	push af
	ld   a, [wOBJInfo_Pl1+iOBJInfo_X]
	add  a, $18
	ld   [wOBJInfo_Pl1+iOBJInfo_X], a
	ld   a, [wLZSS_Buffer]
	ld   [$C1DA], a
	inc  a
	ld   [wLZSS_Buffer], a
	ld   a, [$C1D2]
	and  a, a
	jr   z, L1E65D6
	ld   a, [wOBJInfo_Pl1+iOBJInfo_X]
	sub  a, $30
	ld   [wOBJInfo_Pl1+iOBJInfo_X], a
	ld   a, [wLZSS_Buffer]
	dec  a
	dec  a
	ld   [wLZSS_Buffer], a
L1E65D6:;R
	pop  af
	jr   L1E6602
L1E65D9:;R
	push af
	ld   a, [wOBJInfo_Pl1+iOBJInfo_X]
	sub  a, $18
	ld   [wOBJInfo_Pl1+iOBJInfo_X], a
	ld   a, [wLZSS_Buffer]
	ld   [$C1DA], a
	dec  a
	ld   [wLZSS_Buffer], a
	ld   a, [$C1D0]
	and  a, a
	jr   z, L1E6601
	ld   a, [wOBJInfo_Pl1+iOBJInfo_X]
	sub  a, $18
	ld   [wOBJInfo_Pl1+iOBJInfo_X], a
	ld   a, [wLZSS_Buffer]
	dec  a
	ld   [wLZSS_Buffer], a
L1E6601:;R
	pop  af
L1E6602:;R
	ld   [hl], $01
	ld   [$C1CC], a
	ld   a, [wCharSelP1CursorMode]
	inc  a
	ld   [wCharSelP1CursorMode], a
	ld   a, [$C1DA]
	ld   hl, $99E3
	dec  a
	jr   z, L1E6620
	ld   hl, $99E6
	dec  a
	jr   z, L1E6620
	ld   hl, $99E0
L1E6620:;R
	ld   a, [wCharSelP1CursorMode]
	dec  a
	jr   z, L1E662D
	dec  a
	jr   z, L1E6651
	dec  a
	jr   z, L1E6669
L1E662C: db $C9;X
L1E662D:;R
	ld   a, [$C1CC]
	ld   [$C1CF], a
	ld   de, $6D8A
	ld   b, $03
	ld   c, $03
	call CopyBGToRect
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamCharId1]
	cp   $FF
	ret  nz
L1E6643:;R
	ld   a, [wOBJInfo_Pl1+iOBJInfo_X]
	sub  a, $10
	ld   [wOBJInfo_Pl1+iOBJInfo_X], a
	ld   a, $03
	ld   [wCharSelP1CursorMode], a
	ret
L1E6651:;R
	ld   a, [$C1CC]
	ld   [$C1D1], a
	ld   de, $6D93
	ld   b, $03
	ld   c, $03
	call CopyBGToRect
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamCharId2]
	cp   $FF
	ret  nz
	jr   L1E6643
L1E6669:;R
	ld   a, [$C1CC]
	ld   [$C1D3], a
	ld   de, $6D9C
	ld   b, $03
	ld   c, $03
	jp   CopyBGToRect
L1E6679:;J
	ld   a, [wCharSelP2CursorMode]
	cp   $03
	ret  z
	ld   a, [$C1CB]
	ld   b, a
	ld   a, [wPlInfo_Pl2+iPlInfo_TeamCharId1]
	ld   hl, $C1D6
	dec  b
	jr   z, L1E66C6
	ld   a, [wPlInfo_Pl2+iPlInfo_TeamCharId2]
	ld   hl, $C1D8
	dec  b
	jr   z, L1E66F2
	ld   a, [wPlInfo_Pl2+iPlInfo_TeamCharId0]
	ld   hl, $C1D4
	push af
	ld   a, [wOBJInfo_Pl2+iOBJInfo_X]
	sub  a, $18
	ld   [wOBJInfo_Pl2+iOBJInfo_X], a
	ld   a, [$C1CB]
	ld   [$C1DB], a
	inc  a
	ld   [$C1CB], a
	ld   a, [$C1D6]
	and  a, a
	jr   z, L1E66C3
	ld   a, [wOBJInfo_Pl2+iOBJInfo_X]
	sub  a, $18
	ld   [wOBJInfo_Pl2+iOBJInfo_X], a
	ld   a, [$C1CB]
	inc  a
	ld   [$C1CB], a
L1E66C3:;R
	pop  af
	jr   L1E671B
L1E66C6:;R
	push af
	ld   a, [wOBJInfo_Pl2+iOBJInfo_X]
	add  a, $18
	ld   [wOBJInfo_Pl2+iOBJInfo_X], a
	ld   a, [$C1CB]
	ld   [$C1DB], a
	dec  a
	ld   [$C1CB], a
	ld   a, [$C1D4]
	and  a, a
	jr   z, L1E66EF
	ld   a, [wOBJInfo_Pl2+iOBJInfo_X]
	sub  a, $30
	ld   [wOBJInfo_Pl2+iOBJInfo_X], a
	ld   a, [$C1CB]
	inc  a
	inc  a
	ld   [$C1CB], a
L1E66EF:
	pop  af
	jr   L1E671B
L1E66F2:;R
	push af
	ld   a, [wOBJInfo_Pl2+iOBJInfo_X]
	add  a, $18
	ld   [wOBJInfo_Pl2+iOBJInfo_X], a
	ld   a, [$C1CB]
	ld   [$C1DB], a
	dec  a
	ld   [$C1CB], a
	ld   a, [$C1D6]
	and  a, a
	jr   z, L1E671A
	ld   a, [wOBJInfo_Pl2+iOBJInfo_X]
	add  a, $18
	ld   [wOBJInfo_Pl2+iOBJInfo_X], a
	ld   a, [$C1CB]
	dec  a
	ld   [$C1CB], a
L1E671A:
	pop  af
L1E671B:;R
	ld   [hl], $01
	ld   [$C1CD], a
	ld   a, [wCharSelP2CursorMode]
	inc  a
	ld   [wCharSelP2CursorMode], a
	ld   a, [$C1DB]
	ld   hl, $99EE
	dec  a
	jr   z, L1E6739
	ld   hl, $99EB
	dec  a
	jr   z, L1E6739
	ld   hl, $99F1
L1E6739:;R
	ld   a, [wCharSelP2CursorMode]
	dec  a
	jr   z, L1E6746
	dec  a
	jr   z, L1E676A
	dec  a
	jr   z, L1E6782
L1E6745: db $C9;X
L1E6746:;R
	ld   a, [$C1CD]
	ld   [$C1D5], a
	ld   de, $6D8A
	ld   b, $03
	ld   c, $03
	call CopyBGToRect
	ld   a, [wPlInfo_Pl2+iPlInfo_TeamCharId1]
	cp   $FF
	ret  nz
L1E675C:;R
	ld   a, [wOBJInfo_Pl2+iOBJInfo_X]
	sub  a, $10
	ld   [wOBJInfo_Pl2+iOBJInfo_X], a
	ld   a, $03
	ld   [wCharSelP2CursorMode], a
	ret
L1E676A:;R
	ld   a, [$C1CD]
	ld   [$C1D7], a
	ld   de, $6D93
	ld   b, $03
	ld   c, $03
	call CopyBGToRect
	ld   a, [wPlInfo_Pl2+iPlInfo_TeamCharId2]
	cp   $FF
	ret  nz
	jr   L1E675C
L1E6782:;R
	ld   a, [$C1CD]
	ld   [$C1D9], a
	ld   de, $6D9C
	ld   b, $03
	ld   c, $03
	jp   CopyBGToRect
L1E6792:;J
	ld   a, [wCharSelCurPl]
	or   a
	jp   nz, L1E67E4
	ld   a, [wCharSelP1CursorMode]
	cp   $03
	ret  z
	ld   a, [wLZSS_Buffer]
	and  a, a
	ret  z
	dec  a
	ld   [wLZSS_Buffer], a
	jr   nz, L1E67B8
	ld   a, [$C1CE]
	and  a, a
	jr   z, L1E67DB
	ld   a, [wLZSS_Buffer]
	inc  a
	ld   [wLZSS_Buffer], a
	ret
L1E67B8:;R
	ld   a, [$C1D0]
	and  a, a
	jr   z, L1E67DB
	ld   a, [$C1CE]
	and  a, a
	jr   z, L1E67CC
L1E67C4: db $FA;X
L1E67C5: db $CA;X
L1E67C6: db $C1;X
L1E67C7: db $3C;X
L1E67C8: db $EA;X
L1E67C9: db $CA;X
L1E67CA: db $C1;X
L1E67CB: db $C9;X
L1E67CC:;R
	ld   a, [wLZSS_Buffer]
	dec  a
	ld   [wLZSS_Buffer], a
	ld   a, [wOBJInfo_Pl1+iOBJInfo_X]
	sub  a, $18
	ld   [wOBJInfo_Pl1+iOBJInfo_X], a
L1E67DB:;R
	ld   a, [wOBJInfo_Pl1+iOBJInfo_X]
	sub  a, $18
	ld   [wOBJInfo_Pl1+iOBJInfo_X], a
	ret
L1E67E4: db $FA;X
L1E67E5: db $B5;X
L1E67E6: db $C1;X
L1E67E7: db $FE;X
L1E67E8: db $03;X
L1E67E9: db $C8;X
L1E67EA: db $FA;X
L1E67EB: db $CB;X
L1E67EC: db $C1;X
L1E67ED: db $FE;X
L1E67EE: db $02;X
L1E67EF: db $C8;X
L1E67F0: db $3C;X
L1E67F1: db $EA;X
L1E67F2: db $CB;X
L1E67F3: db $C1;X
L1E67F4: db $FE;X
L1E67F5: db $02;X
L1E67F6: db $20;X
L1E67F7: db $0E;X
L1E67F8: db $FA;X
L1E67F9: db $D8;X
L1E67FA: db $C1;X
L1E67FB: db $A7;X
L1E67FC: db $28;X
L1E67FD: db $2B;X
L1E67FE: db $FA;X
L1E67FF: db $CB;X
L1E6800: db $C1;X
L1E6801: db $3D;X
L1E6802: db $EA;X
L1E6803: db $CB;X
L1E6804: db $C1;X
L1E6805: db $C9;X
L1E6806: db $FA;X
L1E6807: db $D6;X
L1E6808: db $C1;X
L1E6809: db $A7;X
L1E680A: db $28;X
L1E680B: db $1D;X
L1E680C: db $FA;X
L1E680D: db $D8;X
L1E680E: db $C1;X
L1E680F: db $A7;X
L1E6810: db $28;X
L1E6811: db $08;X
L1E6812: db $FA;X
L1E6813: db $CB;X
L1E6814: db $C1;X
L1E6815: db $3D;X
L1E6816: db $EA;X
L1E6817: db $CB;X
L1E6818: db $C1;X
L1E6819: db $C9;X
L1E681A: db $FA;X
L1E681B: db $CB;X
L1E681C: db $C1;X
L1E681D: db $3C;X
L1E681E: db $EA;X
L1E681F: db $CB;X
L1E6820: db $C1;X
L1E6821: db $FA;X
L1E6822: db $C3;X
L1E6823: db $D6;X
L1E6824: db $D6;X
L1E6825: db $18;X
L1E6826: db $EA;X
L1E6827: db $C3;X
L1E6828: db $D6;X
L1E6829: db $FA;X
L1E682A: db $C3;X
L1E682B: db $D6;X
L1E682C: db $D6;X
L1E682D: db $18;X
L1E682E: db $EA;X
L1E682F: db $C3;X
L1E6830: db $D6;X
L1E6831: db $C9;X
L1E6832:;J
	ld   a, [wCharSelCurPl]
	or   a
	jp   nz, L1E6887
	ld   a, [wCharSelP1CursorMode]
	cp   $03
	ret  z
	ld   a, [wLZSS_Buffer]
	cp   $02
	ret  z
	inc  a
	ld   [wLZSS_Buffer], a
	cp   $02
	jr   nz, L1E685B
	ld   a, [$C1D2]
	and  a, a
	jr   z, L1E687E
	ld   a, [wLZSS_Buffer]
	dec  a
	ld   [wLZSS_Buffer], a
	ret
L1E685B:;R
	ld   a, [$C1D0]
	and  a, a
	jr   z, L1E687E
	ld   a, [$C1D2]
	and  a, a
	jr   z, L1E686F
L1E6867: db $FA;X
L1E6868: db $CA;X
L1E6869: db $C1;X
L1E686A: db $3D;X
L1E686B: db $EA;X
L1E686C: db $CA;X
L1E686D: db $C1;X
L1E686E: db $C9;X
L1E686F:;R
	ld   a, [wLZSS_Buffer]
	inc  a
	ld   [wLZSS_Buffer], a
	ld   a, [wOBJInfo_Pl1+iOBJInfo_X]
	add  a, $18
	ld   [wOBJInfo_Pl1+iOBJInfo_X], a
L1E687E:;R
	ld   a, [wOBJInfo_Pl1+iOBJInfo_X]
	add  a, $18
	ld   [wOBJInfo_Pl1+iOBJInfo_X], a
	ret
L1E6887: db $FA;X
L1E6888: db $B5;X
L1E6889: db $C1;X
L1E688A: db $FE;X
L1E688B: db $03;X
L1E688C: db $C8;X
L1E688D: db $FA;X
L1E688E: db $CB;X
L1E688F: db $C1;X
L1E6890: db $A7;X
L1E6891: db $C8;X
L1E6892: db $3D;X
L1E6893: db $EA;X
L1E6894: db $CB;X
L1E6895: db $C1;X
L1E6896: db $20;X
L1E6897: db $0E;X
L1E6898: db $FA;X
L1E6899: db $D4;X
L1E689A: db $C1;X
L1E689B: db $A7;X
L1E689C: db $28;X
L1E689D: db $2B;X
L1E689E: db $FA;X
L1E689F: db $CB;X
L1E68A0: db $C1;X
L1E68A1: db $3C;X
L1E68A2: db $EA;X
L1E68A3: db $CB;X
L1E68A4: db $C1;X
L1E68A5: db $C9;X
L1E68A6: db $FA;X
L1E68A7: db $D6;X
L1E68A8: db $C1;X
L1E68A9: db $A7;X
L1E68AA: db $28;X
L1E68AB: db $1D;X
L1E68AC: db $FA;X
L1E68AD: db $D4;X
L1E68AE: db $C1;X
L1E68AF: db $A7;X
L1E68B0: db $28;X
L1E68B1: db $08;X
L1E68B2: db $FA;X
L1E68B3: db $CB;X
L1E68B4: db $C1;X
L1E68B5: db $3C;X
L1E68B6: db $EA;X
L1E68B7: db $CB;X
L1E68B8: db $C1;X
L1E68B9: db $C9;X
L1E68BA: db $FA;X
L1E68BB: db $CB;X
L1E68BC: db $C1;X
L1E68BD: db $3D;X
L1E68BE: db $EA;X
L1E68BF: db $CB;X
L1E68C0: db $C1;X
L1E68C1: db $FA;X
L1E68C2: db $C3;X
L1E68C3: db $D6;X
L1E68C4: db $C6;X
L1E68C5: db $18;X
L1E68C6: db $EA;X
L1E68C7: db $C3;X
L1E68C8: db $D6;X
L1E68C9: db $FA;X
L1E68CA: db $C3;X
L1E68CB: db $D6;X
L1E68CC: db $C6;X
L1E68CD: db $18;X
L1E68CE: db $EA;X
L1E68CF: db $C3;X
L1E68D0: db $D6;X
L1E68D1: db $C9;X
L1E68D2:;CI
	call L1E68F8
L1E68D5:;J
	push bc
	push hl
	call L1E690A
	call CopyTilesHBlankFlipX
	pop  hl
	inc  hl
	pop  bc
	dec  b
	jp   nz, L1E68D5
	ret
L1E68E5:;CI
	call L1E68F8
L1E68E8:;J
	push bc
	push hl
	call L1E690A
	call CopyTiles
	pop  hl
	inc  hl
	pop  bc
	dec  b
	jp   nz, L1E68E8
	ret
L1E68F8:;C
	ld   a, c
	push de
	ld   l, a
	ld   h, $00
	ld   de, $6970
	add  hl, de
	ld   e, [hl]
	inc  hl
	ld   d, [hl]
	push de
	pop  hl
	ld   b, $12
	pop  de
	ret
L1E690A:;C
	ld   a, [hl]
	ld   l, a
	ld   h, $00
	sla  l
	rl   h
	sla  l
	rl   h
	sla  l
	rl   h
	sla  l
	rl   h
	push de
	ld   de, $C1EA
	add  hl, de
	pop  de
	ld   b, $01
	ret
L1E6927:;C
	ld   a, $80
L1E6929:;CR
	ld   de, $694C
L1E692C:;JC
	ld   b, $03
	ld   c, $06
	jp   CopyBGToRectWithBase
L1E6933:;C
	ld   a, $92
	jr   L1E6929
L1E6937:;CI
	ld   hl, $6DA5
	ld   de, $C1EA
	jp   DecompressLZSS
L1E6940:;C
	ld   a, [wTimer]
	and  a, $01
	ret  nz
	ldh  a, [rOBP0]
	rlca
	ldh  [rOBP0], a
	ret
L1E694C: db $02
L1E694D: db $01
L1E694E: db $00
L1E694F: db $05
L1E6950: db $04
L1E6951: db $03
L1E6952: db $08
L1E6953: db $07
L1E6954: db $06
L1E6955: db $0B
L1E6956: db $0A
L1E6957: db $09
L1E6958: db $0E
L1E6959: db $0D
L1E695A: db $0C
L1E695B: db $11
L1E695C: db $10
L1E695D: db $0F
L1E695E: db $00
L1E695F: db $01
L1E6960: db $02
L1E6961: db $03
L1E6962: db $04
L1E6963: db $05
L1E6964: db $06
L1E6965: db $07
L1E6966: db $08
L1E6967: db $09
L1E6968: db $0A
L1E6969: db $0B
L1E696A: db $0C
L1E696B: db $0D
L1E696C: db $0E
L1E696D: db $0F
L1E696E: db $10
L1E696F: db $11
L1E6970: db $4F
L1E6971: db $7A
L1E6972: db $61
L1E6973: db $7A
L1E6974: db $73
L1E6975: db $7A
L1E6976: db $85
L1E6977: db $7A
L1E6978: db $97
L1E6979: db $7A
L1E697A: db $A9
L1E697B: db $7A
L1E697C: db $BB
L1E697D: db $7A
L1E697E: db $CD
L1E697F: db $7A
L1E6980: db $DF
L1E6981: db $7A
L1E6982: db $F1
L1E6983: db $7A
L1E6984: db $03
L1E6985: db $7B
L1E6986: db $15
L1E6987: db $7B
L1E6988: db $27
L1E6989: db $7B
L1E698A: db $39
L1E698B: db $7B
L1E698C: db $4B
L1E698D: db $7B
L1E698E: db $5D
L1E698F: db $7B
L1E6990: db $6F
L1E6991: db $7B
L1E6992: db $81
L1E6993: db $7B
L1E6994: db $93
L1E6995: db $7B
L1E6996: db $A5
L1E6997: db $7B
L1E6998: db $64
L1E6999: db $40
L1E699A: db $7E
L1E699B: db $00
L1E699C: db $07
L1E699D: db $07
L1E699E: db $07
L1E699F: db $07
L1E69A0: db $07
L1E69A1: db $00
L1E69A2: db $0C
L1E69A3: db $AE
L1E69A4: db $00
L1E69A5: db $0B
L1E69A6: db $00
L1E69A7: db $04
L1E69A8: db $00
L1E69A9: db $6F
L1E69AA: db $05
L1E69AB: db $C0
L1E69AC: db $B3
L1E69AD: db $00
L1E69AE: db $03
L1E69AF: db $18
L1E69B0: db $08
L1E69B1: db $01
L1E69B2: db $07
L1E69B3: db $10
L1E69B4: db $09
L1E69B5: db $D4
L1E69B6: db $C0
L1E69B7: db $1C
L1E69B8: db $06
L1E69B9: db $58
L1E69BA: db $F7
L1E69BB: db $78
L1E69BC: db $FF
L1E69BD: db $E3
L1E69BE: db $AA
L1E69BF: db $08
L1E69C0: db $33
L1E69C1: db $09
L1E69C2: db $CC
L1E69C3: db $1C
L1E69C4: db $1C
L1E69C5: db $58
L1E69C6: db $3F
L1E69C7: db $9C
L1E69C8: db $78
L1E69C9: db $7F
L1E69CA: db $1E
L1E69CB: db $08
L1E69CC: db $38
L1E69CD: db $08
L1E69CE: db $30
L1E69CF: db $61
L1E69D0: db $DF
L1E69D1: db $29
L1E69D2: db $E8
L1E69D3: db $4C
L1E69D4: db $38
L1E69D5: db $29
L1E69D6: db $A8
L1E69D7: db $F9
L1E69D8: db $90
L1E69D9: db $E5
L1E69DA: db $08
L1E69DB: db $68
L1E69DC: db $09
L1E69DD: db $C1
L1E69DE: db $3E
L1E69DF: db $19
L1E69E0: db $CF
L1E69E1: db $08
L1E69E2: db $57
L1E69E3: db $C0
L1E69E4: db $58
L1E69E5: db $F7
L1E69E6: db $79
L1E69E7: db $E3
L1E69E8: db $08
L1E69E9: db $B8
L1E69EA: db $09
L1E69EB: db $4E
L1E69EC: db $1C
L1E69ED: db $29
L1E69EE: db $63
L1E69EF: db $CC
L1E69F0: db $28
L1E69F1: db $09
L1E69F2: db $F9
L1E69F3: db $F8
L1E69F4: db $D7
L1E69F5: db $A8
L1E69F6: db $09
L1E69F7: db $78
L1E69F8: db $08
L1E69F9: db $48
L1E69FA: db $1A
L1E69FB: db $FB
L1E69FC: db $79
L1E69FD: db $79
L1E69FE: db $7F
L1E69FF: db $18
L1E6A00: db $08
L1E6A01: db $38
L1E6A02: db $09
L1E6A03: db $41
L1E6A04: db $3E
L1E6A05: db $19
L1E6A06: db $D2
L1E6A07: db $7D
L1E6A08: db $08
L1E6A09: db $F3
L1E6A0A: db $08
L1E6A0B: db $03
L1E6A0C: db $F7
L1E6A0D: db $08
L1E6A0E: db $14
L1E6A0F: db $55
L1E6A10: db $E3
L1E6A11: db $19
L1E6A12: db $FC
L1E6A13: db $08
L1E6A14: db $0C
L1E6A15: db $58
L1E6A16: db $F0
L1E6A17: db $78
L1E6A18: db $3A
L1E6A19: db $F8
L1E6A1A: db $E0
L1E6A1B: db $08
L1E6A1C: db $B8
L1E6A1D: db $09
L1E6A1E: db $18
L1E6A1F: db $29
L1E6A20: db $60
L1E6A21: db $74
L1E6A22: db $C8
L1E6A23: db $28
L1E6A24: db $09
L1E6A25: db $FA
L1E6A26: db $1E
L1E6A27: db $08
L1E6A28: db $33
L1E6A29: db $7F
L1E6A2A: db $B5
L1E6A2B: db $38
L1E6A2C: db $48
L1E6A2D: db $08
L1E6A2E: db $19
L1E6A2F: db $CC
L1E6A30: db $38
L1E6A31: db $E1
L1E6A32: db $59
L1E6A33: db $A5
L1E6A34: db $79
L1E6A35: db $3F
L1E6A36: db $08
L1E6A37: db $0C
L1E6A38: db $9E
L1E6A39: db $08
L1E6A3A: db $12
L1E6A3B: db $1A
L1E6A3C: db $5F
L1E6A3D: db $92
L1E6A3E: db $0A
L1E6A3F: db $80
L1E6A40: db $78
L1E6A41: db $09
L1E6A42: db $07
L1E6A43: db $07
L1E6A44: db $07
L1E6A45: db $7D
L1E6A46: db $03
L1E6A47: db $00
L1E6A48: db $F0
L1E6A49: db $00
L1E6A4A: db $5F
L1E6A4B: db $01
L1E6A4C: db $C0
L1E6A4D: db $00
L1E6A4E: db $55
L1E6A4F: db $40
L1E6A50: db $00
L1E6A51: db $80
L1E6A52: db $00
L1E6A53: db $04
L1E6A54: db $00
L1E6A55: db $02
L1E6A56: db $00
L1E6A57: db $6A
L1E6A58: db $01
L1E6A59: db $02
L1E6A5A: db $AF
L1E6A5B: db $30
L1E6A5C: db $00
L1E6A5D: db $0C
L1E6A5E: db $00
L1E6A5F: db $03
L1E6A60: db $F5
L1E6A61: db $00
L1E6A62: db $39
L1E6A63: db $C9
L1E6A64: db $E9
L1E6A65: db $20
L1E6A66: db $00
L1E6A67: db $10
L1E6A68: db $00
L1E6A69: db $55
L1E6A6A: db $08
L1E6A6B: db $00
L1E6A6C: db $0E
L1E6A6D: db $00
L1E6A6E: db $05
L1E6A6F: db $00
L1E6A70: db $04
L1E6A71: db $00
L1E6A72: db $5D
L1E6A73: db $02
L1E6A74: db $00
L1E6A75: db $01
L1E6A76: db $02
L1E6A77: db $B9
L1E6A78: db $05
L1E6A79: db $E0
L1E6A7A: db $00
L1E6A7B: db $5D
L1E6A7C: db $18
L1E6A7D: db $00
L1E6A7E: db $06
L1E6A7F: db $00
L1E6A80: db $7F
L1E6A81: db $07
L1E6A82: db $C0
L1E6A83: db $00
L1E6A84: db $6A
L1E6A85: db $30
L1E6A86: db $00
L1E6A87: db $3B
L1E6A88: db $80
L1E6A89: db $00
L1E6A8A: db $60
L1E6A8B: db $00
L1E6A8C: db $1C
L1E6A8D: db $B5
L1E6A8E: db $00
L1E6A8F: db $03
L1E6A90: db $00
L1E6A91: db $4B
L1E6A92: db $0E
L1E6A93: db $00
L1E6A94: db $01
L1E6A95: db $00
L1E6A96: db $AB
L1E6A97: db $FF
L1E6A98: db $F0
L1E6A99: db $00
L1E6A9A: db $0F
L1E6A9B: db $00
L1E6A9C: db $3F
L1E6A9D: db $67
L1E6A9E: db $06
L1E6A9F: db $75
L1E6AA0: db $7F
L1E6AA1: db $47
L1E6AA2: db $07
L1E6AA3: db $00
L1E6AA4: db $80
L1E6AA5: db $00
L1E6AA6: db $60
L1E6AA7: db $00
L1E6AA8: db $57
L1E6AA9: db $18
L1E6AAA: db $00
L1E6AAB: db $06
L1E6AAC: db $00
L1E6AAD: db $01
L1E6AAE: db $00
L1E6AAF: db $8F
L1E6AB0: db $BF
L1E6AB1: db $B6
L1E6AB2: db $BB
L1E6AB3: db $FF
L1E6AB4: db $77
L1E6AB5: db $06
L1E6AB6: db $BF
L1E6AB7: db $47
L1E6AB8: db $06
L1E6AB9: db $1E
L1E6ABA: db $EA
L1E6ABB: db $47
L1E6ABC: db $07
L1E6ABD: db $06
L1E6ABE: db $01
L1E6ABF: db $00
L1E6AC0: db $06
L1E6AC1: db $00
L1E6AC2: db $18
L1E6AC3: db $B6
L1E6AC4: db $00
L1E6AC5: db $60
L1E6AC6: db $00
L1E6AC7: db $3F
L1E6AC8: db $80
L1E6AC9: db $00
L1E6ACA: db $AB
L1E6ACB: db $03
L1E6ACC: db $EB
L1E6ACD: db $00
L1E6ACE: db $FF
L1E6ACF: db $5B
L1E6AD0: db $0C
L1E6AD1: db $00
L1E6AD2: db $30
L1E6AD3: db $00
L1E6AD4: db $4D
L1E6AD5: db $56
L1E6AD6: db $1C
L1E6AD7: db $00
L1E6AD8: db $60
L1E6AD9: db $00
L1E6ADA: db $80
L1E6ADB: db $00
L1E6ADC: db $5B
L1E6ADD: db $C0
L1E6ADE: db $EB
L1E6ADF: db $00
L1E6AE0: db $FF
L1E6AE1: db $A9
L1E6AE2: db $7C
L1E6AE3: db $00
L1E6AE4: db $88
L1E6AE5: db $00
L1E6AE6: db $39
L1E6AE7: db $55
L1E6AE8: db $01
L1E6AE9: db $00
L1E6AEA: db $06
L1E6AEB: db $00
L1E6AEC: db $18
L1E6AED: db $00
L1E6AEE: db $E1
L1E6AEF: db $00
L1E6AF0: db $55
L1E6AF1: db $02
L1E6AF2: db $02
L1E6AF3: db $04
L1E6AF4: db $00
L1E6AF5: db $30
L1E6AF6: db $00
L1E6AF7: db $C1
L1E6AF8: db $00
L1E6AF9: db $AA
L1E6AFA: db $4D
L1E6AFB: db $08
L1E6AFC: db $00
L1E6AFD: db $10
L1E6AFE: db $00
L1E6AFF: db $20
L1E6B00: db $00
L1E6B01: db $80
L1E6B02: db $B5
L1E6B03: db $00
L1E6B04: db $00
L1E6B05: db $07
L1E6B06: db $04
L1E6B07: db $40
L1E6B08: db $00
L1E6B09: db $C0
L1E6B0A: db $00
L1E6B0B: db $EA
L1E6B0C: db $99
L1E6B0D: db $AF
L1E6B0E: db $7B
L1E6B0F: db $30
L1E6B10: db $00
L1E6B11: db $0C
L1E6B12: db $00
L1E6B13: db $03
L1E6B14: db $AD
L1E6B15: db $00
L1E6B16: db $02
L1E6B17: db $00
L1E6B18: db $01
L1E6B19: db $02
L1E6B1A: db $79
L1E6B1B: db $08
L1E6B1C: db $00
L1E6B1D: db $6A
L1E6B1E: db $04
L1E6B1F: db $00
L1E6B20: db $59
L1E6B21: db $81
L1E6B22: db $00
L1E6B23: db $70
L1E6B24: db $00
L1E6B25: db $0F
L1E6B26: db $DA
L1E6B27: db $00
L1E6B28: db $69
L1E6B29: db $80
L1E6B2A: db $00
L1E6B2B: db $F9
L1E6B2C: db $20
L1E6B2D: db $00
L1E6B2E: db $18
L1E6B2F: db $AE
L1E6B30: db $00
L1E6B31: db $0E
L1E6B32: db $00
L1E6B33: db $05
L1E6B34: db $00
L1E6B35: db $A9
L1E6B36: db $01
L1E6B37: db $01
L1E6B38: db $B5
L1E6B39: db $00
L1E6B3A: db $F0
L1E6B3B: db $00
L1E6B3C: db $59
L1E6B3D: db $71
L1E6B3E: db $00
L1E6B3F: db $3E
L1E6B40: db $00
L1E6B41: db $55
L1E6B42: db $9F
L1E6B43: db $00
L1E6B44: db $4F
L1E6B45: db $00
L1E6B46: db $CF
L1E6B47: db $00
L1E6B48: db $27
L1E6B49: db $00
L1E6B4A: db $6A
L1E6B4B: db $04
L1E6B4C: db $00
L1E6B4D: db $A9
L1E6B4E: db $C1
L1E6B4F: db $00
L1E6B50: db $3C
L1E6B51: db $00
L1E6B52: db $83
L1E6B53: db $AA
L1E6B54: db $00
L1E6B55: db $80
L1E6B56: db $00
L1E6B57: db $C0
L1E6B58: db $02
L1E6B59: db $17
L1E6B5A: db $00
L1E6B5B: db $13
L1E6B5C: db $AB
L1E6B5D: db $00
L1E6B5E: db $0B
L1E6B5F: db $00
L1E6B60: db $09
L1E6B61: db $00
L1E6B62: db $C5
L1E6B63: db $00
L1E6B64: db $99
L1E6B65: db $D5
L1E6B66: db $C9
L1E6B67: db $01
L1E6B68: db $E0
L1E6B69: db $00
L1E6B6A: db $E1
L1E6B6B: db $00
L1E6B6C: db $F3
L1E6B6D: db $00
L1E6B6E: db $55
L1E6B6F: db $F7
L1E6B70: db $00
L1E6B71: db $FF
L1E6B72: db $04
L1E6B73: db $7F
L1E6B74: db $00
L1E6B75: db $00
L1E6B76: db $04
L1E6B77: db $56
L1E6B78: db $80
L1E6B79: db $00
L1E6B7A: db $F0
L1E6B7B: db $00
L1E6B7C: db $0F
L1E6B7D: db $00
L1E6B7E: db $39
L1E6B7F: db $7E
L1E6B80: db $D5
L1E6B81: db $00
L1E6B82: db $19
L1E6B83: db $01
L1E6B84: db $00
L1E6B85: db $02
L1E6B86: db $00
L1E6B87: db $04
L1E6B88: db $00
L1E6B89: db $5A
L1E6B8A: db $3F
L1E6B8B: db $00
L1E6B8C: db $C0
L1E6B8D: db $00
L1E6B8E: db $89
L1E6B8F: db $FF
L1E6B90: db $00
L1E6B91: db $FE
L1E6B92: db $B6
L1E6B93: db $00
L1E6B94: db $F8
L1E6B95: db $00
L1E6B96: db $D9
L1E6B97: db $E0
L1E6B98: db $00
L1E6B99: db $69
L1E6B9A: db $80
L1E6B9B: db $F7
L1E6B9C: db $00
L1E6B9D: db $19
L1E6B9E: db $39
L1E6B9F: db $B9
L1E6BA0: db $1F
L1E6BA1: db $07
L1E6BA2: db $04
L1E6BA3: db $A9
L1E6BA4: db $55
L1E6BA5: db $00
L1E6BA6: db $00
L1E6BA7: db $07
L1E6BA8: db $00
L1E6BA9: db $78
L1E6BAA: db $00
L1E6BAB: db $87
L1E6BAC: db $00
L1E6BAD: db $55
L1E6BAE: db $7F
L1E6BAF: db $00
L1E6BB0: db $FF
L1E6BB1: db $02
L1E6BB2: db $1C
L1E6BB3: db $00
L1E6BB4: db $E3
L1E6BB5: db $00
L1E6BB6: db $55
L1E6BB7: db $1E
L1E6BB8: db $00
L1E6BB9: db $FC
L1E6BBA: db $00
L1E6BBB: db $F9
L1E6BBC: db $00
L1E6BBD: db $F2
L1E6BBE: db $00
L1E6BBF: db $5A
L1E6BC0: db $F7
L1E6BC1: db $00
L1E6BC2: db $E4
L1E6BC3: db $00
L1E6BC4: db $89
L1E6BC5: db $F1
L1E6BC6: db $00
L1E6BC7: db $01
L1E6BC8: db $EA
L1E6BC9: db $02
L1E6BCA: db $79
L1E6BCB: db $39
L1E6BCC: db $F0
L1E6BCD: db $00
L1E6BCE: db $F4
L1E6BCF: db $00
L1E6BD0: db $C8
L1E6BD1: db $AA
L1E6BD2: db $00
L1E6BD3: db $D0
L1E6BD4: db $00
L1E6BD5: db $90
L1E6BD6: db $00
L1E6BD7: db $A1
L1E6BD8: db $00
L1E6BD9: db $2E
L1E6BDA: db $AA
L1E6BDB: db $00
L1E6BDC: db $71
L1E6BDD: db $00
L1E6BDE: db $41
L1E6BDF: db $00
L1E6BE0: db $82
L1E6BE1: db $00
L1E6BE2: db $10
L1E6BE3: db $AA
L1E6BE4: db $00
L1E6BE5: db $20
L1E6BE6: db $00
L1E6BE7: db $40
L1E6BE8: db $00
L1E6BE9: db $87
L1E6BEA: db $00
L1E6BEB: db $39
L1E6BEC: db $AA
L1E6BED: db $00
L1E6BEE: db $C2
L1E6BEF: db $00
L1E6BF0: db $02
L1E6BF1: db $00
L1E6BF2: db $04
L1E6BF3: db $00
L1E6BF4: db $08
L1E6BF5: db $AB
L1E6BF6: db $00
L1E6BF7: db $30
L1E6BF8: db $00
L1E6BF9: db $C0
L1E6BFA: db $00
L1E6BFB: db $00
L1E6BFC: db $07
L1E6BFD: db $00
L1E6BFE: db $AD
L1E6BFF: db $79
L1E6C00: db $10
L1E6C01: db $00
L1E6C02: db $20
L1E6C03: db $00
L1E6C04: db $89
L1E6C05: db $80
L1E6C06: db $00
L1E6C07: db $AD
L1E6C08: db $7D
L1E6C09: db $81
L1E6C0A: db $00
L1E6C0B: db $41
L1E6C0C: db $00
L1E6C0D: db $79
L1E6C0E: db $18
L1E6C0F: db $00
L1E6C10: db $55
L1E6C11: db $07
L1E6C12: db $00
L1E6C13: db $01
L1E6C14: db $04
L1E6C15: db $79
L1E6C16: db $00
L1E6C17: db $3C
L1E6C18: db $00
L1E6C19: db $56
L1E6C1A: db $BC
L1E6C1B: db $00
L1E6C1C: db $9E
L1E6C1D: db $00
L1E6C1E: db $3F
L1E6C1F: db $02
L1E6C20: db $E9
L1E6C21: db $FF
L1E6C22: db $B6
L1E6C23: db $00
L1E6C24: db $05
L1E6C25: db $07
L1E6C26: db $00
L1E6C27: db $02
L1E6C28: db $02
L1E6C29: db $F9
L1E6C2A: db $F7
L1E6C2B: db $AA
L1E6C2C: db $00
L1E6C2D: db $FB
L1E6C2E: db $00
L1E6C2F: db $7D
L1E6C30: db $00
L1E6C31: db $3E
L1E6C32: db $00
L1E6C33: db $1F
L1E6C34: db $B5
L1E6C35: db $00
L1E6C36: db $BF
L1E6C37: db $00
L1E6C38: db $F9
L1E6C39: db $F0
L1E6C3A: db $00
L1E6C3B: db $E7
L1E6C3C: db $00
L1E6C3D: db $55
L1E6C3E: db $F8
L1E6C3F: db $00
L1E6C40: db $FD
L1E6C41: db $00
L1E6C42: db $FE
L1E6C43: db $00
L1E6C44: db $7F
L1E6C45: db $00
L1E6C46: db $57
L1E6C47: db $9F
L1E6C48: db $00
L1E6C49: db $0F
L1E6C4A: db $02
L1E6C4B: db $E0
L1E6C4C: db $04
L1E6C4D: db $B9
L1E6C4E: db $01
L1E6C4F: db $5B
L1E6C50: db $FC
L1E6C51: db $00
L1E6C52: db $FF
L1E6C53: db $00
L1E6C54: db $A9
L1E6C55: db $07
L1E6C56: db $04
L1E6C57: db $CB
L1E6C58: db $6A
L1E6C59: db $3F
L1E6C5A: db $00
L1E6C5B: db $79
L1E6C5C: db $FE
L1E6C5D: db $00
L1E6C5E: db $05
L1E6C5F: db $00
L1E6C60: db $3D
L1E6C61: db $AA
L1E6C62: db $00
L1E6C63: db $C6
L1E6C64: db $00
L1E6C65: db $84
L1E6C66: db $00
L1E6C67: db $41
L1E6C68: db $00
L1E6C69: db $46
L1E6C6A: db $AD
L1E6C6B: db $00
L1E6C6C: db $B8
L1E6C6D: db $00
L1E6C6E: db $A0
L1E6C6F: db $00
L1E6C70: db $49
L1E6C71: db $08
L1E6C72: db $00
L1E6C73: db $55
L1E6C74: db $10
L1E6C75: db $00
L1E6C76: db $60
L1E6C77: db $00
L1E6C78: db $80
L1E6C79: db $00
L1E6C7A: db $00
L1E6C7B: db $04
L1E6C7C: db $DA
L1E6C7D: db $89
L1E6C7E: db $07
L1E6C7F: db $40
L1E6C80: db $02
L1E6C81: db $A9
L1E6C82: db $BF
L1E6C83: db $00
L1E6C84: db $4F
L1E6C85: db $AE
L1E6C86: db $00
L1E6C87: db $30
L1E6C88: db $00
L1E6C89: db $0F
L1E6C8A: db $00
L1E6C8B: db $ED
L1E6C8C: db $01
L1E6C8D: db $FD
L1E6C8E: db $AB
L1E6C8F: db $00
L1E6C90: db $F2
L1E6C91: db $00
L1E6C92: db $0C
L1E6C93: db $00
L1E6C94: db $F0
L1E6C95: db $00
L1E6C96: db $7F
L1E6C97: db $D8
L1E6C98: db $07
L1E6C99: db $02
L1E6C9A: db $01
L1E6C9B: db $0C
L1E6C9C: db $03
L1E6C9D: db $3E
L1E6C9E: db $3C
L1E6C9F: db $7E
L1E6CA0: db $17
L1E6CA1: db $7C
L1E6CA2: db $FE
L1E6CA3: db $FC
L1E6CA4: db $0A
L1E6CA5: db $1C
L1E6CA6: db $09
L1E6CA7: db $58
L1E6CA8: db $0F
L1E6CA9: db $DD
L1E6CAA: db $0F
L1E6CAB: db $0D
L1E6CAC: db $00
L1E6CAD: db $09
L1E6CAE: db $07
L1E6CAF: db $03
L1E6CB0: db $01
L1E6CB1: db $00
L1E6CB2: db $6A
L1E6CB3: db $03
L1E6CB4: db $0D
L1E6CB5: db $6C
L1E6CB6: db $FF
L1E6CB7: db $05
L1E6CB8: db $C3
L1E6CB9: db $09
L1E6CBA: db $E7
L1E6CBB: db $EE
L1E6CBC: db $58
L1E6CBD: db $8D
L1E6CBE: db $07
L1E6CBF: db $01
L1E6CC0: db $70
L1E6CC1: db $88
L1E6CC2: db $08
L1E6CC3: db $07
L1E6CC4: db $A0
L1E6CC5: db $00
L1E6CC6: db $0F
L1E6CC7: db $00
L1E6CC8: db $1F
L1E6CC9: db $1E
L1E6CCA: db $3F
L1E6CCB: db $3C
L1E6CCC: db $7E
L1E6CCD: db $0A
L1E6CCE: db $78
L1E6CCF: db $FC
L1E6CD0: db $F0
L1E6CD1: db $F8
L1E6CD2: db $BE
L1E6CD3: db $80
L1E6CD4: db $00
L1E6CD5: db $C0
L1E6CD6: db $F9
L1E6CD7: db $0F
L1E6CD8: db $0B
L1E6CD9: db $79
L1E6CDA: db $BE
L1E6CDB: db $00
L1E6CDC: db $01
L1E6CDD: db $03
L1E6CDE: db $0D
L1E6CDF: db $E7
L1E6CE0: db $40
L1E6CE1: db $09
L1E6CE2: db $04
L1E6CE3: db $E0
L1E6CE4: db $FF
L1E6CE5: db $05
L1E6CE6: db $40
L1E6CE7: db $09
L1E6CE8: db $9D
L1E6CE9: db $05
L1E6CEA: db $C0
L1E6CEB: db $80
L1E6CEC: db $0C
L1E6CED: db $39
L1E6CEE: db $7E
L1E6CEF: db $03
L1E6CF0: db $3E
L1E6CF1: db $D4
L1E6CF2: db $6E
L1E6CF3: db $00
L1E6CF4: db $E7
L1E6CF5: db $08
L1E6CF6: db $07
L1E6CF7: db $00
L1E6CF8: db $FF
L1E6CF9: db $7F
L1E6CFA: db $F3
L1E6CFB: db $0A
L1E6CFC: db $29
L1E6CFD: db $49
L1E6CFE: db $69
L1E6CFF: db $80
L1E6D00: db $C0
L1E6D01: db $0B
L1E6D02: db $B8
L1E6D03: db $EF
L1E6D04: db $10
L1E6D05: db $09
L1E6D06: db $4D
L1E6D07: db $01
L1E6D08: db $90
L1E6D09: db $0D
L1E6D0A: db $78
L1E6D0B: db $10
L1E6D0C: db $CB
L1E6D0D: db $08
L1E6D0E: db $04
L1E6D0F: db $C3
L1E6D10: db $E7
L1E6D11: db $08
L1E6D12: db $FF
L1E6D13: db $05
L1E6D14: db $50
L1E6D15: db $CF
L1E6D16: db $09
L1E6D17: db $02
L1E6D18: db $80
L1E6D19: db $C0
L1E6D1A: db $0D
L1E6D1B: db $41
L1E6D1C: db $FD
L1E6D1D: db $07
L1E6D1E: db $E0
L1E6D1F: db $07
L1E6D20: db $07
L1E6D21: db $07
L1E6D22: db $0B
L1E6D23: db $40
L1E6D24: db $44
L1E6D25: db $01
L1E6D26: db $02
L1E6D27: db $04
L1E6D28: db $05
L1E6D29: db $08
L1E6D2A: db $08
L1E6D2B: db $0B
L1E6D2C: db $0C
L1E6D2D: db $90
L1E6D2E: db $4B
L1E6D2F: db $02
L1E6D30: db $03
L1E6D31: db $19
L1E6D32: db $06
L1E6D33: db $07
L1E6D34: db $09
L1E6D35: db $0A
L1E6D36: db $10
L1E6D37: db $0D
L1E6D38: db $0E
L1E6D39: db $0F
L1E6D3A: db $38
L1E6D3B: db $10
L1E6D3C: db $11
L1E6D3D: db $12
L1E6D3E: db $13
L1E6D3F: db $04
L1E6D40: db $15
L1E6D41: db $16
L1E6D42: db $19
L1E6D43: db $1A
L1E6D44: db $1D
L1E6D45: db $00
L1E6D46: db $1E
L1E6D47: db $1F
L1E6D48: db $08
L1E6D49: db $22
L1E6D4A: db $23
L1E6D4B: db $26
L1E6D4C: db $27
L1E6D4D: db $80
L1E6D4E: db $14
L1E6D4F: db $17
L1E6D50: db $18
L1E6D51: db $20
L1E6D52: db $1B
L1E6D53: db $1C
L1E6D54: db $F9
L1E6D55: db $20
L1E6D56: db $21
L1E6D57: db $24
L1E6D58: db $25
L1E6D59: db $28
L1E6D5A: db $C0
L1E6D5B: db $31
L1E6D5C: db $00
L1E6D5D: db $29
L1E6D5E: db $2A
L1E6D5F: db $2C
L1E6D60: db $2D
L1E6D61: db $30
L1E6D62: db $31
L1E6D63: db $0C
L1E6D64: db $34
L1E6D65: db $35
L1E6D66: db $38
L1E6D67: db $39
L1E6D68: db $62
L1E6D69: db $01
L1E6D6A: db $2B
L1E6D6B: db $2E
L1E6D6C: db $03
L1E6D6D: db $2F
L1E6D6E: db $32
L1E6D6F: db $33
L1E6D70: db $36
L1E6D71: db $37
L1E6D72: db $3A
L1E6D73: db $64
L1E6D74: db $01
L1E6D75: db $03
L1E6D76: db $3B
L1E6D77: db $3C
L1E6D78: db $3E
L1E6D79: db $3F
L1E6D7A: db $42
L1E6D7B: db $43
L1E6D7C: db $66
L1E6D7D: db $01
L1E6D7E: db $0C
L1E6D7F: db $3D
L1E6D80: db $40
L1E6D81: db $41
L1E6D82: db $44
L1E6D83: db $5F
L1E6D84: db $02
L1E6D85: db $45
L1E6D86: db $46
L1E6D87: db $80
L1E6D88: db $3D
L1E6D89: db $00
L1E6D8A: db $47
L1E6D8B: db $48
L1E6D8C: db $01
L1E6D8D: db $01
L1E6D8E: db $49
L1E6D8F: db $01
L1E6D90: db $01
L1E6D91: db $4A
L1E6D92: db $01
L1E6D93: db $4B
L1E6D94: db $4C
L1E6D95: db $4F
L1E6D96: db $4D
L1E6D97: db $4E
L1E6D98: db $50
L1E6D99: db $51
L1E6D9A: db $52
L1E6D9B: db $53
L1E6D9C: db $4B
L1E6D9D: db $4C
L1E6D9E: db $4F
L1E6D9F: db $54
L1E6DA0: db $55
L1E6DA1: db $56
L1E6DA2: db $57
L1E6DA3: db $58
L1E6DA4: db $59
L1E6DA5: db $67
L1E6DA6: db $41
L1E6DA7: db $7A
L1E6DA8: db $00
L1E6DA9: db $07
L1E6DAA: db $07
L1E6DAB: db $07
L1E6DAC: db $02
L1E6DAD: db $01
L1E6DAE: db $08
L1E6DAF: db $07
L1E6DB0: db $D5
L1E6DB1: db $57
L1E6DB2: db $04
L1E6DB3: db $1E
L1E6DB4: db $08
L1E6DB5: db $7F
L1E6DB6: db $08
L1E6DB7: db $FF
L1E6DB8: db $08
L1E6DB9: db $35
L1E6DBA: db $F3
L1E6DBB: db $7E
L1E6DBC: db $19
L1E6DBD: db $08
L1E6DBE: db $0C
L1E6DBF: db $08
L1E6DC0: db $60
L1E6DC1: db $08
L1E6DC2: db $56
L1E6DC3: db $3A
L1E6DC4: db $08
L1E6DC5: db $B0
L1E6DC6: db $08
L1E6DC7: db $DC
L1E6DC8: db $DF
L1E6DC9: db $03
L1E6DCA: db $80
L1E6DCB: db $BA
L1E6DCC: db $08
L1E6DCD: db $F0
L1E6DCE: db $11
L1E6DCF: db $07
L1E6DD0: db $00
L1E6DD1: db $0C
L1E6DD2: db $08
L1E6DD3: db $72
L1E6DD4: db $95
L1E6DD5: db $10
L1E6DD6: db $A5
L1E6DD7: db $5A
L1E6DD8: db $39
L1E6DD9: db $01
L1E6DDA: db $08
L1E6DDB: db $07
L1E6DDC: db $10
L1E6DDD: db $95
L1E6DDE: db $08
L1E6DDF: db $02
L1E6DE0: db $03
L1E6DE1: db $18
L1E6DE2: db $05
L1E6DE3: db $18
L1E6DE4: db $04
L1E6DE5: db $20
L1E6DE6: db $E8
L1E6DE7: db $09
L1E6DE8: db $EF
L1E6DE9: db $03
L1E6DEA: db $30
L1E6DEB: db $08
L1E6DEC: db $70
L1E6DED: db $20
L1E6DEE: db $E0
L1E6DEF: db $C8
L1E6DF0: db $18
L1E6DF1: db $08
L1E6DF2: db $C0
L1E6DF3: db $F0
L1E6DF4: db $10
L1E6DF5: db $E3
L1E6DF6: db $40
L1E6DF7: db $CC
L1E6DF8: db $01
L1E6DF9: db $83
L1E6DFA: db $D0
L1E6DFB: db $8F
L1E6DFC: db $A0
L1E6DFD: db $1F
L1E6DFE: db $A2
L1E6DFF: db $1D
L1E6E00: db $CD
L1E6E01: db $7D
L1E6E02: db $80
L1E6E03: db $08
L1E6E04: db $80
L1E6E05: db $10
L1E6E06: db $D0
L1E6E07: db $B8
L1E6E08: db $60
L1E6E09: db $18
L1E6E0A: db $E9
L1E6E0B: db $C0
L1E6E0C: db $30
L1E6E0D: db $59
L1E6E0E: db $1E
L1E6E0F: db $08
L1E6E10: db $31
L1E6E11: db $0E
L1E6E12: db $30
L1E6E13: db $42
L1E6E14: db $3F
L1E6E15: db $09
L1E6E16: db $42
L1E6E17: db $3D
L1E6E18: db $47
L1E6E19: db $3A
L1E6E1A: db $20
L1E6E1B: db $02
L1E6E1C: db $ED
L1E6E1D: db $FF
L1E6E1E: db $F9
L1E6E1F: db $0B
L1E6E20: db $C0
L1E6E21: db $75
L1E6E22: db $02
L1E6E23: db $01
L1E6E24: db $08
L1E6E25: db $74
L1E6E26: db $03
L1E6E27: db $10
L1E6E28: db $0B
L1E6E29: db $5B
L1E6E2A: db $78
L1E6E2B: db $08
L1E6E2C: db $FC
L1E6E2D: db $18
L1E6E2E: db $2C
L1E6E2F: db $FE
L1E6E30: db $B8
L1E6E31: db $08
L1E6E32: db $E0
L1E6E33: db $08
L1E6E34: db $F8
L1E6E35: db $BE
L1E6E36: db $58
L1E6E37: db $9E
L1E6E38: db $DF
L1E6E39: db $07
L1E6E3A: db $02
L1E6E3B: db $08
L1E6E3C: db $28
L1E6E3D: db $08
L1E6E3E: db $30
L1E6E3F: db $6F
L1E6E40: db $F5
L1E6E41: db $08
L1E6E42: db $7B
L1E6E43: db $C0
L1E6E44: db $08
L1E6E45: db $F0
L1E6E46: db $10
L1E6E47: db $F8
L1E6E48: db $18
L1E6E49: db $AB
L1E6E4A: db $08
L1E6E4B: db $40
L1E6E4C: db $08
L1E6E4D: db $B0
L1E6E4E: db $08
L1E6E4F: db $10
L1E6E50: db $7B
L1E6E51: db $07
L1E6E52: db $B4
L1E6E53: db $01
L1E6E54: db $3C
L1E6E55: db $47
L1E6E56: db $6E
L1E6E57: db $C2
L1E6E58: db $10
L1E6E59: db $0F
L1E6E5A: db $07
L1E6E5B: db $22
L1E6E5C: db $1F
L1E6E5D: db $0C
L1E6E5E: db $08
L1E6E5F: db $0B
L1E6E60: db $3F
L1E6E61: db $13
L1E6E62: db $08
L1E6E63: db $1B
L1E6E64: db $09
L1E6E65: db $3B
L1E6E66: db $15
L1E6E67: db $71
L1E6E68: db $2E
L1E6E69: db $08
L1E6E6A: db $1E
L1E6E6B: db $7B
L1E6E6C: db $88
L1E6E6D: db $4D
L1E6E6E: db $7E
L1E6E6F: db $08
L1E6E70: db $7C
L1E6E71: db $38
L1E6E72: db $00
L1E6E73: db $EA
L1E6E74: db $01
L1E6E75: db $0C
L1E6E76: db $35
L1E6E77: db $FF
L1E6E78: db $61
L1E6E79: db $08
L1E6E7A: db $19
L1E6E7B: db $BB
L1E6E7C: db $08
L1E6E7D: db $DD
L1E6E7E: db $0A
L1E6E7F: db $58
L1E6E80: db $B0
L1E6E81: db $08
L1E6E82: db $0F
L1E6E83: db $08
L1E6E84: db $00
L1E6E85: db $F8
L1E6E86: db $D0
L1E6E87: db $FC
L1E6E88: db $D6
L1E6E89: db $E0
L1E6E8A: db $08
L1E6E8B: db $D8
L1E6E8C: db $08
L1E6E8D: db $C8
L1E6E8E: db $08
L1E6E8F: db $38
L1E6E90: db $FE
L1E6E91: db $56
L1E6E92: db $3C
L1E6E93: db $08
L1E6E94: db $BC
L1E6E95: db $08
L1E6E96: db $1C
L1E6E97: db $89
L1E6E98: db $00
L1E6E99: db $5F
L1E6E9A: db $A1
L1E6E9B: db $0A
L1E6E9C: db $00
L1E6E9D: db $09
L1E6E9E: db $0E
L1E6E9F: db $F1
L1E6EA0: db $1B
L1E6EA1: db $E4
L1E6EA2: db $09
L1E6EA3: db $AA
L1E6EA4: db $88
L1E6EA5: db $88
L1E6EA6: db $48
L1E6EA7: db $9E
L1E6EA8: db $09
L1E6EA9: db $C6
L1E6EAA: db $D8
L1E6EAB: db $C4
L1E6EAC: db $41
L1E6EAD: db $38
L1E6EAE: db $09
L1E6EAF: db $E8
L1E6EB0: db $D0
L1E6EB1: db $F0
L1E6EB2: db $E0
L1E6EB3: db $01
L1E6EB4: db $B8
L1E6EB5: db $D4
L1E6EB6: db $0B
L1E6EB7: db $05
L1E6EB8: db $03
L1E6EB9: db $08
L1E6EBA: db $04
L1E6EBB: db $10
L1E6EBC: db $4B
L1E6EBD: db $B4
L1E6EBE: db $00
L1E6EBF: db $5E
L1E6EC0: db $B3
L1E6EC1: db $3F
L1E6EC2: db $E2
L1E6EC3: db $FF
L1E6EC4: db $1E
L1E6EC5: db $7F
L1E6EC6: db $35
L1E6EC7: db $8A
L1E6EC8: db $08
L1E6EC9: db $1D
L1E6ECA: db $BF
L1E6ECB: db $4A
L1E6ECC: db $18
L1E6ECD: db $A6
L1E6ECE: db $99
L1E6ECF: db $07
L1E6ED0: db $AE
L1E6ED1: db $F0
L1E6ED2: db $0F
L1E6ED3: db $09
L1E6ED4: db $05
L1E6ED5: db $08
L1E6ED6: db $D0
L1E6ED7: db $08
L1E6ED8: db $02
L1E6ED9: db $F5
L1E6EDA: db $48
L1E6EDB: db $58
L1E6EDC: db $01
L1E6EDD: db $C8
L1E6EDE: db $38
L1E6EDF: db $08
L1E6EE0: db $87
L1E6EE1: db $0A
L1E6EE2: db $83
L1E6EE3: db $B0
L1E6EE4: db $3B
L1E6EE5: db $C4
L1E6EE6: db $10
L1E6EE7: db $EF
L1E6EE8: db $80
L1E6EE9: db $F0
L1E6EEA: db $38
L1E6EEB: db $F4
L1E6EEC: db $8A
L1E6EED: db $28
L1E6EEE: db $0A
L1E6EEF: db $01
L1E6EF0: db $C0
L1E6EF1: db $08
L1E6EF2: db $B8
L1E6EF3: db $40
L1E6EF4: db $00
L1E6EF5: db $0C
L1E6EF6: db $F0
L1E6EF7: db $3E
L1E6EF8: db $CC
L1E6EF9: db $1E
L1E6EFA: db $E8
L1E6EFB: db $BE
L1E6EFC: db $5C
L1E6EFD: db $AE
L1E6EFE: db $A8
L1E6EFF: db $02
L1E6F00: db $08
L1E6F01: db $3A
L1E6F02: db $08
L1E6F03: db $50
L1E6F04: db $E0
L1E6F05: db $9C
L1E6F06: db $49
L1E6F07: db $DE
L1E6F08: db $CA
L1E6F09: db $08
L1E6F0A: db $07
L1E6F0B: db $0B
L1E6F0C: db $04
L1E6F0D: db $03
L1E6F0E: db $90
L1E6F0F: db $71
L1E6F10: db $01
L1E6F11: db $00
L1E6F12: db $58
L1E6F13: db $03
L1E6F14: db $51
L1E6F15: db $8E
L1E6F16: db $FB
L1E6F17: db $60
L1E6F18: db $08
L1E6F19: db $6F
L1E6F1A: db $93
L1E6F1B: db $A7
L1E6F1C: db $59
L1E6F1D: db $90
L1E6F1E: db $FA
L1E6F1F: db $0F
L1E6F20: db $F6
L1E6F21: db $20
L1E6F22: db $9F
L1E6F23: db $64
L1E6F24: db $00
L1E6F25: db $1B
L1E6F26: db $F0
L1E6F27: db $20
L1E6F28: db $70
L1E6F29: db $C0
L1E6F2A: db $D2
L1E6F2B: db $18
L1E6F2C: db $08
L1E6F2D: db $F8
L1E6F2E: db $08
L1E6F2F: db $FC
L1E6F30: db $90
L1E6F31: db $80
L1E6F32: db $54
L1E6F33: db $29
L1E6F34: db $FD
L1E6F35: db $EA
L1E6F36: db $08
L1E6F37: db $6A
L1E6F38: db $70
L1E6F39: db $1F
L1E6F3A: db $10
L1E6F3B: db $C0
L1E6F3C: db $4A
L1E6F3D: db $08
L1E6F3E: db $E0
L1E6F3F: db $0E
L1E6F40: db $01
L1E6F41: db $20
L1E6F42: db $06
L1E6F43: db $08
L1E6F44: db $02
L1E6F45: db $B0
L1E6F46: db $50
L1E6F47: db $0C
L1E6F48: db $08
L1E6F49: db $40
L1E6F4A: db $79
L1E6F4B: db $86
L1E6F4C: db $0A
L1E6F4D: db $F4
L1E6F4E: db $1A
L1E6F4F: db $1C
L1E6F50: db $E0
L1E6F51: db $38
L1E6F52: db $F8
L1E6F53: db $20
L1E6F54: db $28
L1E6F55: db $08
L1E6F56: db $A8
L1E6F57: db $07
L1E6F58: db $FA
L1E6F59: db $64
L1E6F5A: db $FF
L1E6F5B: db $D6
L1E6F5C: db $00
L1E6F5D: db $00
L1E6F5E: db $E0
L1E6F5F: db $08
L1E6F60: db $A9
L1E6F61: db $B0
L1E6F62: db $03
L1E6F63: db $98
L1E6F64: db $05
L1E6F65: db $09
L1E6F66: db $09
L1E6F67: db $06
L1E6F68: db $09
L1E6F69: db $6B
L1E6F6A: db $08
L1E6F6B: db $60
L1E6F6C: db $88
L1E6F6D: db $3C
L1E6F6E: db $00
L1E6F6F: db $C3
L1E6F70: db $E8
L1E6F71: db $20
L1E6F72: db $58
L1E6F73: db $44
L1E6F74: db $08
L1E6F75: db $40
L1E6F76: db $1A
L1E6F77: db $39
L1E6F78: db $80
L1E6F79: db $7F
L1E6F7A: db $04
L1E6F7B: db $CB
L1E6F7C: db $D8
L1E6F7D: db $09
L1E6F7E: db $02
L1E6F7F: db $01
L1E6F80: db $00
L1E6F81: db $00
L1E6F82: db $03
L1E6F83: db $29
L1E6F84: db $EA
L1E6F85: db $09
L1E6F86: db $90
L1E6F87: db $09
L1E6F88: db $5E
L1E6F89: db $A0
L1E6F8A: db $A7
L1E6F8B: db $08
L1E6F8C: db $BE
L1E6F8D: db $AA
L1E6F8E: db $28
L1E6F8F: db $7D
L1E6F90: db $08
L1E6F91: db $67
L1E6F92: db $08
L1E6F93: db $9D
L1E6F94: db $08
L1E6F95: db $E3
L1E6F96: db $54
L1E6F97: db $80
L1E6F98: db $78
L1E6F99: db $60
L1E6F9A: db $10
L1E6F9B: db $98
L1E6F9C: db $10
L1E6F9D: db $C8
L1E6F9E: db $30
L1E6F9F: db $32
L1E6FA0: db $88
L1E6FA1: db $70
L1E6FA2: db $09
L1E6FA3: db $39
L1E6FA4: db $B8
L1E6FA5: db $40
L1E6FA6: db $3B
L1E6FA7: db $90
L1E6FA8: db $8B
L1E6FA9: db $38
L1E6FAA: db $D0
L1E6FAB: db $20
L1E6FAC: db $E0
L1E6FAD: db $A8
L1E6FAE: db $C0
L1E6FAF: db $C8
L1E6FB0: db $08
L1E6FB1: db $AA
L1E6FB2: db $1A
L1E6FB3: db $01
L1E6FB4: db $08
L1E6FB5: db $03
L1E6FB6: db $08
L1E6FB7: db $0F
L1E6FB8: db $09
L1E6FB9: db $02
L1E6FBA: db $4D
L1E6FBB: db $1E
L1E6FBC: db $30
L1E6FBD: db $1F
L1E6FBE: db $05
L1E6FBF: db $18
L1E6FC0: db $60
L1E6FC1: db $1C
L1E6FC2: db $29
L1E6FC3: db $A1
L1E6FC4: db $58
L1E6FC5: db $0A
L1E6FC6: db $38
L1E6FC7: db $09
L1E6FC8: db $06
L1E6FC9: db $0B
L1E6FCA: db $04
L1E6FCB: db $19
L1E6FCC: db $E4
L1E6FCD: db $09
L1E6FCE: db $49
L1E6FCF: db $09
L1E6FD0: db $FF
L1E6FD1: db $F0
L1E6FD2: db $08
L1E6FD3: db $10
L1E6FD4: db $F7
L1E6FD5: db $05
L1E6FD6: db $68
L1E6FD7: db $EF
L1E6FD8: db $12
L1E6FD9: db $47
L1E6FDA: db $FA
L1E6FDB: db $08
L1E6FDC: db $FD
L1E6FDD: db $48
L1E6FDE: db $1A
L1E6FDF: db $F9
L1E6FE0: db $43
L1E6FE1: db $FC
L1E6FE2: db $F0
L1E6FE3: db $00
L1E6FE4: db $80
L1E6FE5: db $08
L1E6FE6: db $E0
L1E6FE7: db $E8
L1E6FE8: db $08
L1E6FE9: db $A0
L1E6FEA: db $0C
L1E6FEB: db $F8
L1E6FEC: db $0A
L1E6FED: db $7B
L1E6FEE: db $84
L1E6FEF: db $23
L1E6FF0: db $C5
L1E6FF1: db $98
L1E6FF2: db $09
L1E6FF3: db $9E
L1E6FF4: db $60
L1E6FF5: db $9C
L1E6FF6: db $08
L1E6FF7: db $22
L1E6FF8: db $28
L1E6FF9: db $96
L1E6FFA: db $09
L1E6FFB: db $71
L1E6FFC: db $DE
L1E6FFD: db $89
L1E6FFE: db $10
L1E6FFF: db $F0
L1E7000: db $09
L1E7001: db $D0
L1E7002: db $32
L1E7003: db $20
L1E7004: db $90
L1E7005: db $78
L1E7006: db $0D
L1E7007: db $7F
L1E7008: db $08
L1E7009: db $08
L1E700A: db $04
L1E700B: db $00
L1E700C: db $BF
L1E700D: db $42
L1E700E: db $9F
L1E700F: db $61
L1E7010: db $8F
L1E7011: db $70
L1E7012: db $87
L1E7013: db $78
L1E7014: db $C1
L1E7015: db $18
L1E7016: db $F0
L1E7017: db $57
L1E7018: db $2D
L1E7019: db $FC
L1E701A: db $40
L1E701B: db $FF
L1E701C: db $88
L1E701D: db $EA
L1E701E: db $08
L1E701F: db $88
L1E7020: db $08
L1E7021: db $72
L1E7022: db $08
L1E7023: db $92
L1E7024: db $08
L1E7025: db $25
L1E7026: db $A0
L1E7027: db $08
L1E7028: db $BD
L1E7029: db $08
L1E702A: db $DD
L1E702B: db $47
L1E702C: db $3D
L1E702D: db $27
L1E702E: db $1E
L1E702F: db $01
L1E7030: db $23
L1E7031: db $1F
L1E7032: db $13
L1E7033: db $0C
L1E7034: db $0F
L1E7035: db $01
L1E7036: db $02
L1E7037: db $0A
L1E7038: db $98
L1E7039: db $C0
L1E703A: db $03
L1E703B: db $FE
L1E703C: db $88
L1E703D: db $08
L1E703E: db $9D
L1E703F: db $BE
L1E7040: db $5D
L1E7041: db $2E
L1E7042: db $3E
L1E7043: db $D5
L1E7044: db $18
L1E7045: db $C9
L1E7046: db $08
L1E7047: db $48
L1E7048: db $0B
L1E7049: db $00
L1E704A: db $A8
L1E704B: db $02
L1E704C: db $C0
L1E704D: db $08
L1E704E: db $F8
L1E704F: db $08
L1E7050: db $FC
L1E7051: db $18
L1E7052: db $7E
L1E7053: db $44
L1E7054: db $BC
L1E7055: db $08
L1E7056: db $98
L1E7057: db $BF
L1E7058: db $60
L1E7059: db $08
L1E705A: db $78
L1E705B: db $88
L1E705C: db $2D
L1E705D: db $70
L1E705E: db $F0
L1E705F: db $68
L1E7060: db $80
L1E7061: db $0F
L1E7062: db $EA
L1E7063: db $0F
L1E7064: db $08
L1E7065: db $48
L1E7066: db $1E
L1E7067: db $10
L1E7068: db $1F
L1E7069: db $0E
L1E706A: db $10
L1E706B: db $01
L1E706C: db $07
L1E706D: db $02
L1E706E: db $F5
L1E706F: db $00
L1E7070: db $18
L1E7071: db $00
L1E7072: db $58
L1E7073: db $3F
L1E7074: db $08
L1E7075: db $E3
L1E7076: db $60
L1E7077: db $C0
L1E7078: db $18
L1E7079: db $10
L1E707A: db $BF
L1E707B: db $68
L1E707C: db $FF
L1E707D: db $58
L1E707E: db $7F
L1E707F: db $8D
L1E7080: db $BA
L1E7081: db $18
L1E7082: db $DE
L1E7083: db $08
L1E7084: db $18
L1E7085: db $F9
L1E7086: db $80
L1E7087: db $08
L1E7088: db $C0
L1E7089: db $A0
L1E708A: db $0A
L1E708B: db $E0
L1E708C: db $0E
L1E708D: db $DF
L1E708E: db $32
L1E708F: db $9D
L1E7090: db $7E
L1E7091: db $81
L1E7092: db $84
L1E7093: db $08
L1E7094: db $40
L1E7095: db $3F
L1E7096: db $21
L1E7097: db $1E
L1E7098: db $10
L1E7099: db $1D
L1E709A: db $47
L1E709B: db $4A
L1E709C: db $3C
L1E709D: db $08
L1E709E: db $3E
L1E709F: db $F0
L1E70A0: db $90
L1E70A1: db $D0
L1E70A2: db $08
L1E70A3: db $B8
L1E70A4: db $86
L1E70A5: db $10
L1E70A6: db $FC
L1E70A7: db $38
L1E70A8: db $FE
L1E70A9: db $0C
L1E70AA: db $80
L1E70AB: db $20
L1E70AC: db $9C
L1E70AD: db $D4
L1E70AE: db $48
L1E70AF: db $F9
L1E70B0: db $03
L1E70B1: db $08
L1E70B2: db $04
L1E70B3: db $10
L1E70B4: db $05
L1E70B5: db $02
L1E70B6: db $E6
L1E70B7: db $08
L1E70B8: db $18
L1E70B9: db $00
L1E70BA: db $01
L1E70BB: db $07
L1E70BC: db $28
L1E70BD: db $09
L1E70BE: db $0F
L1E70BF: db $81
L1E70C0: db $28
L1E70C1: db $59
L1E70C2: db $A6
L1E70C3: db $3D
L1E70C4: db $C2
L1E70C5: db $FD
L1E70C6: db $32
L1E70C7: db $08
L1E70C8: db $40
L1E70C9: db $1A
L1E70CA: db $08
L1E70CB: db $A2
L1E70CC: db $FA
L1E70CD: db $F4
L1E70CE: db $FC
L1E70CF: db $70
L1E70D0: db $F0
L1E70D1: db $2B
L1E70D2: db $A0
L1E70D3: db $1F
L1E70D4: db $F8
L1E70D5: db $1D
L1E70D6: db $A8
L1E70D7: db $1E
L1E70D8: db $A8
L1E70D9: db $29
L1E70DA: db $F7
L1E70DB: db $C8
L1E70DC: db $08
L1E70DD: db $E8
L1E70DE: db $08
L1E70DF: db $03
L1E70E0: db $08
L1E70E1: db $40
L1E70E2: db $08
L1E70E3: db $C0
L1E70E4: db $88
L1E70E5: db $08
L1E70E6: db $D8
L1E70E7: db $20
L1E70E8: db $EC
L1E70E9: db $10
L1E70EA: db $E6
L1E70EB: db $18
L1E70EC: db $91
L1E70ED: db $09
L1E70EE: db $FE
L1E70EF: db $C0
L1E70F0: db $08
L1E70F1: db $60
L1E70F2: db $7C
L1E70F3: db $80
L1E70F4: db $E0
L1E70F5: db $D9
L1E70F6: db $90
L1E70F7: db $0B
L1E70F8: db $04
L1E70F9: db $D0
L1E70FA: db $09
L1E70FB: db $08
L1E70FC: db $07
L1E70FD: db $0B
L1E70FE: db $AA
L1E70FF: db $D0
L1E7100: db $0F
L1E7101: db $09
L1E7102: db $1C
L1E7103: db $58
L1E7104: db $3F
L1E7105: db $10
L1E7106: db $7E
L1E7107: db $54
L1E7108: db $2C
L1E7109: db $E8
L1E710A: db $00
L1E710B: db $09
L1E710C: db $6C
L1E710D: db $08
L1E710E: db $1B
L1E710F: db $E4
L1E7110: db $00
L1E7111: db $1F
L1E7112: db $E0
L1E7113: db $0C
L1E7114: db $F3
L1E7115: db $4A
L1E7116: db $B1
L1E7117: db $52
L1E7118: db $A1
L1E7119: db $83
L1E711A: db $09
L1E711B: db $62
L1E711C: db $81
L1E711D: db $41
L1E711E: db $80
L1E711F: db $F0
L1E7120: db $68
L1E7121: db $08
L1E7122: db $0D
L1E7123: db $40
L1E7124: db $D0
L1E7125: db $20
L1E7126: db $10
L1E7127: db $28
L1E7128: db $09
L1E7129: db $08
L1E712A: db $40
L1E712B: db $3B
L1E712C: db $88
L1E712D: db $70
L1E712E: db $19
L1E712F: db $89
L1E7130: db $A0
L1E7131: db $00
L1E7132: db $09
L1E7133: db $20
L1E7134: db $F4
L1E7135: db $08
L1E7136: db $07
L1E7137: db $89
L1E7138: db $09
L1E7139: db $F8
L1E713A: db $28
L1E713B: db $7C
L1E713C: db $38
L1E713D: db $1A
L1E713E: db $7E
L1E713F: db $34
L1E7140: db $7F
L1E7141: db $28
L1E7142: db $09
L1E7143: db $36
L1E7144: db $8A
L1E7145: db $01
L1E7146: db $C8
L1E7147: db $0E
L1E7148: db $05
L1E7149: db $B0
L1E714A: db $4F
L1E714B: db $D0
L1E714C: db $C7
L1E714D: db $6C
L1E714E: db $93
L1E714F: db $80
L1E7150: db $09
L1E7151: db $0C
L1E7152: db $F3
L1E7153: db $8D
L1E7154: db $72
L1E7155: db $8E
L1E7156: db $71
L1E7157: db $96
L1E7158: db $68
L1E7159: db $69
L1E715A: db $B6
L1E715B: db $04
L1E715C: db $01
L1E715D: db $0A
L1E715E: db $85
L1E715F: db $78
L1E7160: db $45
L1E7161: db $29
L1E7162: db $38
L1E7163: db $44
L1E7164: db $0A
L1E7165: db $7C
L1E7166: db $48
L1E7167: db $F8
L1E7168: db $70
L1E7169: db $08
L1E716A: db $6B
L1E716B: db $F0
L1E716C: db $08
L1E716D: db $28
L1E716E: db $80
L1E716F: db $08
L1E7170: db $40
L1E7171: db $10
L1E7172: db $09
L1E7173: db $21
L1E7174: db $20
L1E7175: db $C0
L1E7176: db $09
L1E7177: db $10
L1E7178: db $E0
L1E7179: db $90
L1E717A: db $60
L1E717B: db $90
L1E717C: db $A8
L1E717D: db $48
L1E717E: db $18
L1E717F: db $28
L1E7180: db $08
L1E7181: db $A8
L1E7182: db $A4
L1E7183: db $58
L1E7184: db $9C
L1E7185: db $D3
L1E7186: db $48
L1E7187: db $F9
L1E7188: db $3E
L1E7189: db $50
L1E718A: db $3F
L1E718B: db $1E
L1E718C: db $08
L1E718D: db $28
L1E718E: db $55
L1E718F: db $01
L1E7190: db $0C
L1E7191: db $02
L1E7192: db $10
L1E7193: db $03
L1E7194: db $18
L1E7195: db $07
L1E7196: db $08
L1E7197: db $3A
L1E7198: db $0F
L1E7199: db $04
L1E719A: db $08
L1E719B: db $18
L1E719C: db $88
L1E719D: db $1A
L1E719E: db $08
L1E719F: db $0D
L1E71A0: db $01
L1E71A1: db $2F
L1E71A2: db $14
L1E71A3: db $4F
L1E71A4: db $34
L1E71A5: db $46
L1E71A6: db $38
L1E71A7: db $E4
L1E71A8: db $F8
L1E71A9: db $40
L1E71AA: db $F8
L1E71AB: db $68
L1E71AC: db $B9
L1E71AD: db $40
L1E71AE: db $FF
L1E71AF: db $A0
L1E71B0: db $E8
L1E71B1: db $D0
L1E71B2: db $86
L1E71B3: db $09
L1E71B4: db $C8
L1E71B5: db $B0
L1E71B6: db $88
L1E71B7: db $70
L1E71B8: db $09
L1E71B9: db $79
L1E71BA: db $FC
L1E71BB: db $84
L1E71BC: db $08
L1E71BD: db $09
L1E71BE: db $F0
L1E71BF: db $11
L1E71C0: db $E0
L1E71C1: db $09
L1E71C2: db $32
L1E71C3: db $C0
L1E71C4: db $BD
L1E71C5: db $09
L1E71C6: db $CC
L1E71C7: db $58
L1E71C8: db $10
L1E71C9: db $08
L1E71CA: db $01
L1E71CB: db $14
L1E71CC: db $58
L1E71CD: db $A4
L1E71CE: db $09
L1E71CF: db $10
L1E71D0: db $08
L1E71D1: db $90
L1E71D2: db $60
L1E71D3: db $09
L1E71D4: db $B0
L1E71D5: db $40
L1E71D6: db $B5
L1E71D7: db $F8
L1E71D8: db $30
L1E71D9: db $08
L1E71DA: db $78
L1E71DB: db $01
L1E71DC: db $0C
L1E71DD: db $02
L1E71DE: db $10
L1E71DF: db $B4
L1E71E0: db $09
L1E71E1: db $03
L1E71E2: db $28
L1E71E3: db $09
L1E71E4: db $04
L1E71E5: db $10
L1E71E6: db $FF
L1E71E7: db $7E
L1E71E8: db $81
L1E71E9: db $00
L1E71EA: db $BD
L1E71EB: db $3C
L1E71EC: db $C3
L1E71ED: db $18
L1E71EE: db $E7
L1E71EF: db $24
L1E71F0: db $18
L1E71F1: db $E6
L1E71F2: db $10
L1E71F3: db $68
L1E71F4: db $09
L1E71F5: db $44
L1E71F6: db $83
L1E71F7: db $89
L1E71F8: db $09
L1E71F9: db $08
L1E71FA: db $5E
L1E71FB: db $07
L1E71FC: db $0B
L1E71FD: db $0F
L1E71FE: db $68
L1E71FF: db $0B
L1E7200: db $89
L1E7201: db $09
L1E7202: db $A3
L1E7203: db $8F
L1E7204: db $28
L1E7205: db $A6
L1E7206: db $01
L1E7207: db $9A
L1E7208: db $08
L1E7209: db $B0
L1E720A: db $28
L1E720B: db $10
L1E720C: db $96
L1E720D: db $0A
L1E720E: db $40
L1E720F: db $80
L1E7210: db $0F
L1E7211: db $C0
L1E7212: db $58
L1E7213: db $09
L1E7214: db $60
L1E7215: db $AE
L1E7216: db $28
L1E7217: db $50
L1E7218: db $08
L1E7219: db $D0
L1E721A: db $28
L1E721B: db $19
L1E721C: db $7B
L1E721D: db $E0
L1E721E: db $A1
L1E721F: db $38
L1E7220: db $F0
L1E7221: db $0A
L1E7222: db $0E
L1E7223: db $01
L1E7224: db $0A
L1E7225: db $05
L1E7226: db $09
L1E7227: db $57
L1E7228: db $06
L1E7229: db $28
L1E722A: db $02
L1E722B: db $0E
L1E722C: db $03
L1E722D: db $09
L1E722E: db $98
L1E722F: db $10
L1E7230: db $F3
L1E7231: db $08
L1E7232: db $05
L1E7233: db $39
L1E7234: db $59
L1E7235: db $71
L1E7236: db $DE
L1E7237: db $0F
L1E7238: db $0D
L1E7239: db $4E
L1E723A: db $F0
L1E723B: db $88
L1E723C: db $98
L1E723D: db $70
L1E723E: db $09
L1E723F: db $29
L1E7240: db $07
L1E7241: db $FF
L1E7242: db $E3
L1E7243: db $88
L1E7244: db $08
L1E7245: db $18
L1E7246: db $22
L1E7247: db $DC
L1E7248: db $FC
L1E7249: db $18
L1E724A: db $0B
L1E724B: db $48
L1E724C: db $FE
L1E724D: db $0A
L1E724E: db $04
L1E724F: db $03
L1E7250: db $0B
L1E7251: db $08
L1E7252: db $07
L1E7253: db $0C
L1E7254: db $BA
L1E7255: db $18
L1E7256: db $0F
L1E7257: db $30
L1E7258: db $08
L1E7259: db $28
L1E725A: db $1F
L1E725B: db $10
L1E725C: db $BE
L1E725D: db $4A
L1E725E: db $D5
L1E725F: db $0A
L1E7260: db $CD
L1E7261: db $3E
L1E7262: db $09
L1E7263: db $DD
L1E7264: db $09
L1E7265: db $FF
L1E7266: db $58
L1E7267: db $1C
L1E7268: db $F8
L1E7269: db $BC
L1E726A: db $89
L1E726B: db $08
L1E726C: db $0E
L1E726D: db $3F
L1E726E: db $16
L1E726F: db $80
L1E7270: db $58
L1E7271: db $18
L1E7272: db $7E
L1E7273: db $0C
L1E7274: db $4C
L1E7275: db $30
L1E7276: db $8C
L1E7277: db $70
L1E7278: db $03
L1E7279: db $F8
L1E727A: db $00
L1E727B: db $FC
L1E727C: db $38
L1E727D: db $7C
L1E727E: db $28
L1E727F: db $08
L1E7280: db $68
L1E7281: db $F0
L1E7282: db $08
L1E7283: db $58
L1E7284: db $08
L1E7285: db $38
L1E7286: db $7A
L1E7287: db $24
L1E7288: db $61
L1E7289: db $1E
L1E728A: db $5E
L1E728B: db $7F
L1E728C: db $78
L1E728D: db $80
L1E728E: db $0F
L1E728F: db $0A
L1E7290: db $07
L1E7291: db $03
L1E7292: db $01
L1E7293: db $A2
L1E7294: db $08
L1E7295: db $02
L1E7296: db $10
L1E7297: db $04
L1E7298: db $03
L1E7299: db $07
L1E729A: db $A9
L1E729B: db $7F
L1E729C: db $0A
L1E729D: db $C1
L1E729E: db $3E
L1E729F: db $FF
L1E72A0: db $41
L1E72A1: db $08
L1E72A2: db $77
L1E72A3: db $0A
L1E72A4: db $73
L1E72A5: db $0E
L1E72A6: db $F7
L1E72A7: db $63
L1E72A8: db $F3
L1E72A9: db $61
L1E72AA: db $78
L1E72AB: db $89
L1E72AC: db $0C
L1E72AD: db $C0
L1E72AE: db $C9
L1E72AF: db $10
L1E72B0: db $0D
L1E72B1: db $F1
L1E72B2: db $40
L1E72B3: db $08
L1E72B4: db $60
L1E72B5: db $F0
L1E72B6: db $08
L1E72B7: db $5B
L1E72B8: db $A0
L1E72B9: db $28
L1E72BA: db $20
L1E72BB: db $50
L1E72BC: db $09
L1E72BD: db $E0
L1E72BE: db $A8
L1E72BF: db $40
L1E72C0: db $FD
L1E72C1: db $08
L1E72C2: db $18
L1E72C3: db $48
L1E72C4: db $68
L1E72C5: db $10
L1E72C6: db $79
L1E72C7: db $90
L1E72C8: db $08
L1E72C9: db $01
L1E72CA: db $48
L1E72CB: db $30
L1E72CC: db $28
L1E72CD: db $10
L1E72CE: db $24
L1E72CF: db $18
L1E72D0: db $3C
L1E72D1: db $78
L1E72D2: db $2E
L1E72D3: db $02
L1E72D4: db $01
L1E72D5: db $09
L1E72D6: db $03
L1E72D7: db $28
L1E72D8: db $08
L1E72D9: db $18
L1E72DA: db $07
L1E72DB: db $E8
L1E72DC: db $10
L1E72DD: db $0D
L1E72DE: db $A8
L1E72DF: db $D0
L1E72E0: db $09
L1E72E1: db $78
L1E72E2: db $A0
L1E72E3: db $F8
L1E72E4: db $66
L1E72E5: db $50
L1E72E6: db $08
L1E72E7: db $19
L1E72E8: db $70
L1E72E9: db $FC
L1E72EA: db $40
L1E72EB: db $08
L1E72EC: db $38
L1E72ED: db $94
L1E72EE: db $AD
L1E72EF: db $0F
L1E72F0: db $05
L1E72F1: db $09
L1E72F2: db $0B
L1E72F3: db $08
L1E72F4: db $0E
L1E72F5: db $01
L1E72F6: db $8B
L1E72F7: db $40
L1E72F8: db $00
L1E72F9: db $FE
L1E72FA: db $1C
L1E72FB: db $08
L1E72FC: db $04
L1E72FD: db $A9
L1E72FE: db $D8
L1E72FF: db $5B
L1E7300: db $30
L1E7301: db $08
L1E7302: db $60
L1E7303: db $08
L1E7304: db $58
L1E7305: db $F0
L1E7306: db $08
L1E7307: db $19
L1E7308: db $DA
L1E7309: db $07
L1E730A: db $05
L1E730B: db $78
L1E730C: db $47
L1E730D: db $02
L1E730E: db $07
L1E730F: db $08
L1E7310: db $0F
L1E7311: db $AA
L1E7312: db $08
L1E7313: db $03
L1E7314: db $2C
L1E7315: db $1F
L1E7316: db $2E
L1E7317: db $13
L1E7318: db $08
L1E7319: db $06
L1E731A: db $6A
L1E731B: db $01
L1E731C: db $EF
L1E731D: db $01
L1E731E: db $80
L1E731F: db $08
L1E7320: db $D0
L1E7321: db $08
L1E7322: db $F8
L1E7323: db $AA
L1E7324: db $0A
L1E7325: db $FC
L1E7326: db $08
L1E7327: db $FE
L1E7328: db $08
L1E7329: db $FF
L1E732A: db $09
L1E732B: db $04
L1E732C: db $82
L1E732D: db $08
L1E732E: db $0C
L1E732F: db $9E
L1E7330: db $60
L1E7331: db $E5
L1E7332: db $1A
L1E7333: db $EF
L1E7334: db $01
L1E7335: db $AD
L1E7336: db $08
L1E7337: db $07
L1E7338: db $08
L1E7339: db $03
L1E733A: db $1A
L1E733B: db $03
L1E733C: db $80
L1E733D: db $08
L1E733E: db $55
L1E733F: db $70
L1E7340: db $08
L1E7341: db $F8
L1E7342: db $08
L1E7343: db $FC
L1E7344: db $1C
L1E7345: db $0F
L1E7346: db $AC
L1E7347: db $A5
L1E7348: db $0B
L1E7349: db $05
L1E734A: db $4A
L1E734B: db $06
L1E734C: db $01
L1E734D: db $89
L1E734E: db $FE
L1E734F: db $0B
L1E7350: db $56
L1E7351: db $60
L1E7352: db $08
L1E7353: db $88
L1E7354: db $48
L1E7355: db $F0
L1E7356: db $08
L1E7357: db $28
L1E7358: db $7A
L1E7359: db $7D
L1E735A: db $84
L1E735B: db $50
L1E735C: db $07
L1E735D: db $00
L1E735E: db $D0
L1E735F: db $0A
L1E7360: db $0F
L1E7361: db $08
L1E7362: db $42
L1E7363: db $7E
L1E7364: db $08
L1E7365: db $7F
L1E7366: db $02
L1E7367: db $FF
L1E7368: db $04
L1E7369: db $08
L1E736A: db $0A
L1E736B: db $DF
L1E736C: db $08
L1E736D: db $28
L1E736E: db $FE
L1E736F: db $28
L1E7370: db $08
L1E7371: db $58
L1E7372: db $49
L1E7373: db $EF
L1E7374: db $AA
L1E7375: db $05
L1E7376: db $C0
L1E7377: db $1A
L1E7378: db $01
L1E7379: db $08
L1E737A: db $03
L1E737B: db $08
L1E737C: db $05
L1E737D: db $E9
L1E737E: db $0A
L1E737F: db $03
L1E7380: db $49
L1E7381: db $FC
L1E7382: db $08
L1E7383: db $FE
L1E7384: db $F0
L1E7385: db $08
L1E7386: db $35
L1E7387: db $08
L1E7388: db $FF
L1E7389: db $C0
L1E738A: db $08
L1E738B: db $94
L1E738C: db $08
L1E738D: db $50
L1E738E: db $08
L1E738F: db $5B
L1E7390: db $74
L1E7391: db $08
L1E7392: db $2E
L1E7393: db $B4
L1E7394: db $04
L1E7395: db $80
L1E7396: db $0A
L1E7397: db $B0
L1E7398: db $A8
L1E7399: db $08
L1E739A: db $01
L1E739B: db $08
L1E739C: db $07
L1E739D: db $10
L1E739E: db $0F
L1E739F: db $06
L1E73A0: db $1F
L1E73A1: db $55
L1E73A2: db $0D
L1E73A3: db $08
L1E73A4: db $0B
L1E73A5: db $08
L1E73A6: db $09
L1E73A7: db $38
L1E73A8: db $04
L1E73A9: db $49
L1E73AA: db $A1
L1E73AB: db $DD
L1E73AC: db $38
L1E73AD: db $08
L1E73AE: db $7C
L1E73AF: db $28
L1E73B0: db $FE
L1E73B1: db $5C
L1E73B2: db $08
L1E73B3: db $4D
L1E73B4: db $58
L1E73B5: db $08
L1E73B6: db $14
L1E73B7: db $FF
L1E73B8: db $28
L1E73B9: db $08
L1E73BA: db $39
L1E73BB: db $08
L1E73BC: db $D0
L1E73BD: db $68
L1E73BE: db $08
L1E73BF: db $AD
L1E73C0: db $08
L1E73C1: db $DB
L1E73C2: db $D9
L1E73C3: db $A7
L1E73C4: db $8C
L1E73C5: db $2A
L1E73C6: db $73
L1E73C7: db $8B
L1E73C8: db $B0
L1E73C9: db $80
L1E73CA: db $58
L1E73CB: db $E0
L1E73CC: db $10
L1E73CD: db $F0
L1E73CE: db $17
L1E73CF: db $60
L1E73D0: db $F8
L1E73D1: db $70
L1E73D2: db $08
L1E73D3: db $B0
L1E73D4: db $09
L1E73D5: db $39
L1E73D6: db $08
L1E73D7: db $E5
L1E73D8: db $60
L1E73D9: db $70
L1E73DA: db $00
L1E73DB: db $01
L1E73DC: db $02
L1E73DD: db $08
L1E73DE: db $04
L1E73DF: db $0A
L1E73E0: db $D4
L1E73E1: db $41
L1E73E2: db $00
L1E73E3: db $03
L1E73E4: db $08
L1E73E5: db $07
L1E73E6: db $10
L1E73E7: db $C6
L1E73E8: db $38
L1E73E9: db $02
L1E73EA: db $4A
L1E73EB: db $B4
L1E73EC: db $BD
L1E73ED: db $52
L1E73EE: db $FE
L1E73EF: db $B5
L1E73F0: db $08
L1E73F1: db $ED
L1E73F2: db $29
L1E73F3: db $FF
L1E73F4: db $48
L1E73F5: db $08
L1E73F6: db $79
L1E73F7: db $08
L1E73F8: db $0B
L1E73F9: db $0F
L1E73FA: db $90
L1E73FB: db $CD
L1E73FC: db $0A
L1E73FD: db $A8
L1E73FE: db $1F
L1E73FF: db $0E
L1E7400: db $18
L1E7401: db $D8
L1E7402: db $08
L1E7403: db $38
L1E7404: db $35
L1E7405: db $09
L1E7406: db $06
L1E7407: db $09
L1E7408: db $88
L1E7409: db $32
L1E740A: db $08
L1E740B: db $0A
L1E740C: db $08
L1E740D: db $58
L1E740E: db $5B
L1E740F: db $08
L1E7410: db $5D
L1E7411: db $08
L1E7412: db $88
L1E7413: db $BF
L1E7414: db $70
L1E7415: db $3F
L1E7416: db $1A
L1E7417: db $FC
L1E7418: db $7F
L1E7419: db $8A
L1E741A: db $B0
L1E741B: db $04
L1E741C: db $80
L1E741D: db $08
L1E741E: db $40
L1E741F: db $A3
L1E7420: db $10
L1E7421: db $E0
L1E7422: db $18
L1E7423: db $F0
L1E7424: db $C0
L1E7425: db $F8
L1E7426: db $98
L1E7427: db $08
L1E7428: db $F6
L1E7429: db $20
L1E742A: db $A0
L1E742B: db $10
L1E742C: db $08
L1E742D: db $10
L1E742E: db $1A
L1E742F: db $68
L1E7430: db $08
L1E7431: db $83
L1E7432: db $48
L1E7433: db $C8
L1E7434: db $30
L1E7435: db $28
L1E7436: db $D0
L1E7437: db $01
L1E7438: db $38
L1E7439: db $0D
L1E743A: db $53
L1E743B: db $03
L1E743C: db $08
L1E743D: db $07
L1E743E: db $08
L1E743F: db $0B
L1E7440: db $04
L1E7441: db $09
L1E7442: db $20
L1E7443: db $D6
L1E7444: db $07
L1E7445: db $02
L1E7446: db $78
L1E7447: db $08
L1E7448: db $FE
L1E7449: db $57
L1E744A: db $06
L1E744B: db $38
L1E744C: db $AA
L1E744D: db $08
L1E744E: db $FF
L1E744F: db $09
L1E7450: db $0C
L1E7451: db $08
L1E7452: db $12
L1E7453: db $08
L1E7454: db $08
L1E7455: db $E0
L1E7456: db $C8
L1E7457: db $29
L1E7458: db $48
L1E7459: db $81
L1E745A: db $7E
L1E745B: db $80
L1E745C: db $7F
L1E745D: db $78
L1E745E: db $31
L1E745F: db $30
L1E7460: db $FC
L1E7461: db $A0
L1E7462: db $08
L1E7463: db $60
L1E7464: db $7A
L1E7465: db $04
L1E7466: db $90
L1E7467: db $81
L1E7468: db $78
L1E7469: db $F1
L1E746A: db $0E
L1E746B: db $31
L1E746C: db $CE
L1E746D: db $29
L1E746E: db $D6
L1E746F: db $A0
L1E7470: db $AC
L1E7471: db $04
L1E7472: db $07
L1E7473: db $08
L1E7474: db $0F
L1E7475: db $0A
L1E7476: db $28
L1E7477: db $06
L1E7478: db $1F
L1E7479: db $7A
L1E747A: db $01
L1E747B: db $6B
L1E747C: db $21
L1E747D: db $0B
L1E747E: db $01
L1E747F: db $04
L1E7480: db $08
L1E7481: db $0E
L1E7482: db $AA
L1E7483: db $10
L1E7484: db $7F
L1E7485: db $18
L1E7486: db $FF
L1E7487: db $0B
L1E7488: db $10
L1E7489: db $08
L1E748A: db $38
L1E748B: db $0B
L1E748C: db $BF
L1E748D: db $11
L1E748E: db $3F
L1E748F: db $1E
L1E7490: db $F8
L1E7491: db $0C
L1E7492: db $FB
L1E7493: db $03
L1E7494: db $56
L1E7495: db $80
L1E7496: db $08
L1E7497: db $C0
L1E7498: db $0E
L1E7499: db $F8
L1E749A: db $01
L1E749B: db $D8
L1E749C: db $E8
L1E749D: db $38
L1E749E: db $28
L1E749F: db $E0
L1E74A0: db $4A
L1E74A1: db $99
L1E74A2: db $09
L1E74A3: db $04
L1E74A4: db $03
L1E74A5: db $0A
L1E74A6: db $0F
L1E74A7: db $05
L1E74A8: db $0E
L1E74A9: db $01
L1E74AA: db $0F
L1E74AB: db $30
L1E74AC: db $09
L1E74AD: db $28
L1E74AE: db $08
L1E74AF: db $7B
L1E74B0: db $0C
L1E74B1: db $68
L1E74B2: db $0B
L1E74B3: db $38
L1E74B4: db $1A
L1E74B5: db $06
L1E74B6: db $08
L1E74B7: db $07
L1E74B8: db $18
L1E74B9: db $85
L1E74BA: db $7B
L1E74BB: db $84
L1E74BC: db $08
L1E74BD: db $18
L1E74BE: db $7A
L1E74BF: db $43
L1E74C0: db $BD
L1E74C1: db $48
L1E74C2: db $FD
L1E74C3: db $48
L1E74C4: db $7D
L1E74C5: db $38
L1E74C6: db $30
L1E74C7: db $04
L1E74C8: db $A1
L1E74C9: db $5E
L1E74CA: db $6D
L1E74CB: db $80
L1E74CC: db $38
L1E74CD: db $0B
L1E74CE: db $C0
L1E74CF: db $10
L1E74D0: db $09
L1E74D1: db $E0
L1E74D2: db $10
L1E74D3: db $9D
L1E74D4: db $08
L1E74D5: db $40
L1E74D6: db $70
L1E74D7: db $48
L1E74D8: db $89
L1E74D9: db $09
L1E74DA: db $FF
L1E74DB: db $28
L1E74DC: db $82
L1E74DD: db $08
L1E74DE: db $6E
L1E74DF: db $7F
L1E74E0: db $2E
L1E74E1: db $7E
L1E74E2: db $2C
L1E74E3: db $09
L1E74E4: db $FC
L1E74E5: db $56
L1E74E6: db $58
L1E74E7: db $89
L1E74E8: db $30
L1E74E9: db $0A
L1E74EA: db $60
L1E74EB: db $08
L1E74EC: db $07
L1E74ED: db $09
L1E74EE: db $37
L1E74EF: db $06
L1E74F0: db $0D
L1E74F1: db $08
L1E74F2: db $19
L1E74F3: db $0F
L1E74F4: db $38
L1E74F5: db $08
L1E74F6: db $18
L1E74F7: db $00
L1E74F8: db $0E
L1E74F9: db $04
L1E74FA: db $1E
L1E74FB: db $0C
L1E74FC: db $1D
L1E74FD: db $08
L1E74FE: db $15
L1E74FF: db $FA
L1E7500: db $00
L1E7501: db $0A
L1E7502: db $FD
L1E7503: db $1B
L1E7504: db $FC
L1E7505: db $83
L1E7506: db $7C
L1E7507: db $FF
L1E7508: db $01
L1E7509: db $33
L1E750A: db $7F
L1E750B: db $38
L1E750C: db $18
L1E750D: db $A8
L1E750E: db $07
L1E750F: db $F8
L1E7510: db $88
L1E7511: db $18
L1E7512: db $B7
L1E7513: db $09
L1E7514: db $1F
L1E7515: db $E9
L1E7516: db $08
L1E7517: db $05
L1E7518: db $08
L1E7519: db $80
L1E751A: db $0C
L1E751B: db $41
L1E751C: db $02
L1E751D: db $D8
L1E751E: db $2A
L1E751F: db $D4
L1E7520: db $1A
L1E7521: db $E4
L1E7522: db $FE
L1E7523: db $38
L1E7524: db $D5
L1E7525: db $08
L1E7526: db $19
L1E7527: db $EC
L1E7528: db $08
L1E7529: db $DC
L1E752A: db $60
L1E752B: db $C8
L1E752C: db $40
L1E752D: db $AB
L1E752E: db $00
L1E752F: db $80
L1E7530: db $08
L1E7531: db $C0
L1E7532: db $10
L1E7533: db $E0
L1E7534: db $10
L1E7535: db $19
L1E7536: db $C3
L1E7537: db $39
L1E7538: db $03
L1E7539: db $0F
L1E753A: db $06
L1E753B: db $07
L1E753C: db $02
L1E753D: db $0D
L1E753E: db $49
L1E753F: db $EA
L1E7540: db $08
L1E7541: db $20
L1E7542: db $09
L1E7543: db $17
L1E7544: db $10
L1E7545: db $19
L1E7546: db $08
L1E7547: db $1E
L1E7548: db $DD
L1E7549: db $28
L1E754A: db $00
L1E754B: db $01
L1E754C: db $00
L1E754D: db $EC
L1E754E: db $01
L1E754F: db $FF
L1E7550: db $50
L1E7551: db $A7
L1E7552: db $08
L1E7553: db $05
L1E7554: db $0C
L1E7555: db $03
L1E7556: db $FB
L1E7557: db $48
L1E7558: db $09
L1E7559: db $28
L1E755A: db $1F
L1E755B: db $BD
L1E755C: db $C0
L1E755D: db $80
L1E755E: db $00
L1E755F: db $98
L1E7560: db $09
L1E7561: db $29
L1E7562: db $0B
L1E7563: db $74
L1E7564: db $E0
L1E7565: db $10
L1E7566: db $09
L1E7567: db $88
L1E7568: db $6D
L1E7569: db $09
L1E756A: db $7E
L1E756B: db $A9
L1E756C: db $BD
L1E756D: db $18
L1E756E: db $81
L1E756F: db $08
L1E7570: db $98
L1E7571: db $28
L1E7572: db $0A
L1E7573: db $3C
L1E7574: db $08
L1E7575: db $57
L1E7576: db $D0
L1E7577: db $90
L1E7578: db $30
L1E7579: db $08
L1E757A: db $F0
L1E757B: db $A8
L1E757C: db $00
L1E757D: db $38
L1E757E: db $E6
L1E757F: db $E0
L1E7580: db $08
L1E7581: db $05
L1E7582: db $03
L1E7583: db $01
L1E7584: db $08
L1E7585: db $18
L1E7586: db $07
L1E7587: db $6D
L1E7588: db $02
L1E7589: db $0A
L1E758A: db $30
L1E758B: db $0F
L1E758C: db $10
L1E758D: db $08
L1E758E: db $04
L1E758F: db $08
L1E7590: db $81
L1E7591: db $38
L1E7592: db $FF
L1E7593: db $42
L1E7594: db $DF
L1E7595: db $FA
L1E7596: db $BF
L1E7597: db $F8
L1E7598: db $08
L1E7599: db $0B
L1E759A: db $F3
L1E759B: db $DC
L1E759C: db $6F
L1E759D: db $93
L1E759E: db $08
L1E759F: db $9F
L1E75A0: db $08
L1E75A1: db $68
L1E75A2: db $6E
L1E75A3: db $EF
L1E75A4: db $C9
L1E75A5: db $F9
L1E75A6: db $01
L1E75A7: db $0C
L1E75A8: db $05
L1E75A9: db $88
L1E75AA: db $AE
L1E75AB: db $37
L1E75AC: db $FE
L1E75AD: db $B0
L1E75AE: db $F0
L1E75AF: db $09
L1E75B0: db $A0
L1E75B1: db $08
L1E75B2: db $48
L1E75B3: db $0B
L1E75B4: db $4F
L1E75B5: db $78
L1E75B6: db $08
L1E75B7: db $C0
L1E75B8: db $80
L1E75B9: db $00
L1E75BA: db $18
L1E75BB: db $0F
L1E75BC: db $0B
L1E75BD: db $27
L1E75BE: db $07
L1E75BF: db $02
L1E75C0: db $08
L1E75C1: db $01
L1E75C2: db $03
L1E75C3: db $08
L1E75C4: db $00
L1E75C5: db $38
L1E75C6: db $FD
L1E75C7: db $01
L1E75C8: db $19
L1E75C9: db $0B
L1E75CA: db $70
L1E75CB: db $10
L1E75CC: db $09
L1E75CD: db $04
L1E75CE: db $80
L1E75CF: db $B0
L1E75D0: db $0B
L1E75D1: db $08
L1E75D2: db $C0
L1E75D3: db $0B
L1E75D4: db $D3
L1E75D5: db $BE
L1E75D6: db $E7
L1E75D7: db $DF
L1E75D8: db $2C
L1E75D9: db $FF
L1E75DA: db $C7
L1E75DB: db $00
L1E75DC: db $38
L1E75DD: db $18
L1E75DE: db $C8
L1E75DF: db $1C
L1E75E0: db $E3
L1E75E1: db $02
L1E75E2: db $36
L1E75E3: db $C9
L1E75E4: db $32
L1E75E5: db $CD
L1E75E6: db $E0
L1E75E7: db $C0
L1E75E8: db $08
L1E75E9: db $40
L1E75EA: db $E8
L1E75EB: db $10
L1E75EC: db $58
L1E75ED: db $03
L1E75EE: db $80
L1E75EF: db $0C
L1E75F0: db $63
L1E75F1: db $9C
L1E75F2: db $6B
L1E75F3: db $00
L1E75F4: db $94
L1E75F5: db $08
L1E75F6: db $F7
L1E75F7: db $48
L1E75F8: db $B7
L1E75F9: db $5C
L1E75FA: db $A3
L1E75FB: db $1D
L1E75FC: db $07
L1E75FD: db $E2
L1E75FE: db $9D
L1E75FF: db $62
L1E7600: db $BE
L1E7601: db $41
L1E7602: db $E0
L1E7603: db $90
L1E7604: db $09
L1E7605: db $24
L1E7606: db $20
L1E7607: db $C0
L1E7608: db $0B
L1E7609: db $10
L1E760A: db $E0
L1E760B: db $09
L1E760C: db $88
L1E760D: db $70
L1E760E: db $24
L1E760F: db $09
L1E7610: db $06
L1E7611: db $0B
L1E7612: db $05
L1E7613: db $02
L1E7614: db $0F
L1E7615: db $EF
L1E7616: db $F7
L1E7617: db $04
L1E7618: db $FB
L1E7619: db $C7
L1E761A: db $FF
L1E761B: db $38
L1E761C: db $F9
L1E761D: db $88
L1E761E: db $80
L1E761F: db $7F
L1E7620: db $24
L1E7621: db $90
L1E7622: db $6F
L1E7623: db $09
L1E7624: db $C8
L1E7625: db $37
L1E7626: db $89
L1E7627: db $07
L1E7628: db $00
L1E7629: db $A4
L1E762A: db $08
L1E762B: db $01
L1E762C: db $EF
L1E762D: db $0B
L1E762E: db $04
L1E762F: db $89
L1E7630: db $CB
L1E7631: db $34
L1E7632: db $02
L1E7633: db $E7
L1E7634: db $99
L1E7635: db $F7
L1E7636: db $EB
L1E7637: db $FF
L1E7638: db $E3
L1E7639: db $08
L1E763A: db $63
L1E763B: db $62
L1E763C: db $FB
L1E763D: db $68
L1E763E: db $08
L1E763F: db $75
L1E7640: db $88
L1E7641: db $70
L1E7642: db $0B
L1E7643: db $94
L1E7644: db $04
L1E7645: db $68
L1E7646: db $84
L1E7647: db $78
L1E7648: db $C4
L1E7649: db $38
L1E764A: db $09
L1E764B: db $44
L1E764C: db $B8
L1E764D: db $F0
L1E764E: db $09
L1E764F: db $3A
L1E7650: db $19
L1E7651: db $0C
L1E7652: db $E4
L1E7653: db $18
L1E7654: db $E2
L1E7655: db $DC
L1E7656: db $02
L1E7657: db $11
L1E7658: db $0E
L1E7659: db $12
L1E765A: db $0D
L1E765B: db $22
L1E765C: db $1D
L1E765D: db $09
L1E765E: db $2E
L1E765F: db $90
L1E7660: db $40
L1E7661: db $26
L1E7662: db $19
L1E7663: db $59
L1E7664: db $09
L1E7665: db $06
L1E7666: db $07
L1E7667: db $00
L1E7668: db $60
L1E7669: db $01
L1E766A: db $0F
L1E766B: db $0C
L1E766C: db $C4
L1E766D: db $3B
L1E766E: db $C6
L1E766F: db $39
L1E7670: db $C3
L1E7671: db $10
L1E7672: db $3C
L1E7673: db $45
L1E7674: db $BA
L1E7675: db $48
L1E7676: db $FE
L1E7677: db $42
L1E7678: db $BC
L1E7679: db $62
L1E767A: db $61
L1E767B: db $9C
L1E767C: db $20
L1E767D: db $78
L1E767E: db $02
L1E767F: db $FC
L1E7680: db $0C
L1E7681: db $F0
L1E7682: db $00
L1E7683: db $F9
L1E7684: db $28
L1E7685: db $07
L1E7686: db $01
L1E7687: db $88
L1E7688: db $78
L1E7689: db $FF
L1E768A: db $DE
L1E768B: db $08
L1E768C: db $55
L1E768D: db $DA
L1E768E: db $08
L1E768F: db $87
L1E7690: db $08
L1E7691: db $ED
L1E7692: db $08
L1E7693: db $E6
L1E7694: db $08
L1E7695: db $15
L1E7696: db $E7
L1E7697: db $F7
L1E7698: db $A3
L1E7699: db $AD
L1E769A: db $80
L1E769B: db $0C
L1E769C: db $C0
L1E769D: db $10
L1E769E: db $86
L1E769F: db $09
L1E76A0: db $1E
L1E76A1: db $0C
L1E76A2: db $1F
L1E76A3: db $0E
L1E76A4: db $0B
L1E76A5: db $00
L1E76A6: db $05
L1E76A7: db $4A
L1E76A8: db $07
L1E76A9: db $78
L1E76AA: db $04
L1E76AB: db $03
L1E76AC: db $09
L1E76AD: db $7F
L1E76AE: db $08
L1E76AF: db $BF
L1E76B0: db $00
L1E76B1: db $57
L1E76B2: db $9F
L1E76B3: db $66
L1E76B4: db $47
L1E76B5: db $B8
L1E76B6: db $32
L1E76B7: db $CD
L1E76B8: db $FC
L1E76B9: db $86
L1E76BA: db $48
L1E76BB: db $A1
L1E76BC: db $FF
L1E76BD: db $EA
L1E76BE: db $F5
L1E76BF: db $B0
L1E76C0: db $28
L1E76C1: db $06
L1E76C2: db $FE
L1E76C3: db $08
L1E76C4: db $C8
L1E76C5: db $BA
L1E76C6: db $39
L1E76C7: db $00
L1E76C8: db $F8
L1E76C9: db $03
L1E76CA: db $CE
L1E76CB: db $20
L1E76CC: db $F3
L1E76CD: db $8D
L1E76CE: db $08
L1E76CF: db $D7
L1E76D0: db $F8
L1E76D1: db $AF
L1E76D2: db $FB
L1E76D3: db $86
L1E76D4: db $C9
L1E76D5: db $08
L1E76D6: db $F9
L1E76D7: db $F4
L1E76D8: db $4F
L1E76D9: db $18
L1E76DA: db $43
L1E76DB: db $C0
L1E76DC: db $88
L1E76DD: db $29
L1E76DE: db $A0
L1E76DF: db $40
L1E76E0: db $09
L1E76E1: db $50
L1E76E2: db $10
L1E76E3: db $10
L1E76E4: db $E0
L1E76E5: db $09
L1E76E6: db $53
L1E76E7: db $70
L1E76E8: db $08
L1E76E9: db $D0
L1E76EA: db $38
L1E76EB: db $60
L1E76EC: db $80
L1E76ED: db $00
L1E76EE: db $88
L1E76EF: db $F8
L1E76F0: db $01
L1E76F1: db $19
L1E76F2: db $0D
L1E76F3: db $E8
L1E76F4: db $10
L1E76F5: db $FC
L1E76F6: db $58
L1E76F7: db $7C
L1E76F8: db $3D
L1E76F9: db $18
L1E76FA: db $78
L1E76FB: db $38
L1E76FC: db $09
L1E76FD: db $28
L1E76FE: db $08
L1E76FF: db $A6
L1E7700: db $48
L1E7701: db $13
L1E7702: db $A3
L1E7703: db $5E
L1E7704: db $FF
L1E7705: db $28
L1E7706: db $03
L1E7707: db $01
L1E7708: db $0A
L1E7709: db $29
L1E770A: db $AB
L1E770B: db $08
L1E770C: db $02
L1E770D: db $28
L1E770E: db $04
L1E770F: db $20
L1E7710: db $07
L1E7711: db $09
L1E7712: db $38
L1E7713: db $AC
L1E7714: db $F8
L1E7715: db $98
L1E7716: db $09
L1E7717: db $9C
L1E7718: db $28
L1E7719: db $09
L1E771A: db $94
L1E771B: db $08
L1E771C: db $05
L1E771D: db $92
L1E771E: db $0C
L1E771F: db $93
L1E7720: db $0E
L1E7721: db $9F
L1E7722: db $38
L1E7723: db $3C
L1E7724: db $08
L1E7725: db $57
L1E7726: db $7C
L1E7727: db $08
L1E7728: db $78
L1E7729: db $0A
L1E772A: db $70
L1E772B: db $1A
L1E772C: db $48
L1E772D: db $98
L1E772E: db $75
L1E772F: db $6E
L1E7730: db $6A
L1E7731: db $09
L1E7732: db $99
L1E7733: db $3E
L1E7734: db $09
L1E7735: db $04
L1E7736: db $08
L1E7737: db $08
L1E7738: db $14
L1E7739: db $7E
L1E773A: db $20
L1E773B: db $EE
L1E773C: db $38
L1E773D: db $10
L1E773E: db $0F
L1E773F: db $11
L1E7740: db $02
L1E7741: db $0E
L1E7742: db $21
L1E7743: db $1E
L1E7744: db $23
L1E7745: db $1C
L1E7746: db $63
L1E7747: db $08
L1E7748: db $76
L1E7749: db $08
L1E774A: db $29
L1E774B: db $FF
L1E774C: db $70
L1E774D: db $F8
L1E774E: db $78
L1E774F: db $B6
L1E7750: db $41
L1E7751: db $36
L1E7752: db $16
L1E7753: db $C1
L1E7754: db $77
L1E7755: db $80
L1E7756: db $0D
L1E7757: db $E3
L1E7758: db $68
L1E7759: db $01
L1E775A: db $88
L1E775B: db $C8
L1E775C: db $98
L1E775D: db $09
L1E775E: db $44
L1E775F: db $B8
L1E7760: db $09
L1E7761: db $66
L1E7762: db $98
L1E7763: db $EE
L1E7764: db $49
L1E7765: db $14
L1E7766: db $F8
L1E7767: db $0E
L1E7768: db $1F
L1E7769: db $78
L1E776A: db $0B
L1E776B: db $04
L1E776C: db $0F
L1E776D: db $C9
L1E776E: db $09
L1E776F: db $70
L1E7770: db $01
L1E7771: db $03
L1E7772: db $78
L1E7773: db $FB
L1E7774: db $34
L1E7775: db $A8
L1E7776: db $75
L1E7777: db $30
L1E7778: db $08
L1E7779: db $28
L1E777A: db $1A
L1E777B: db $78
L1E777C: db $08
L1E777D: db $E0
L1E777E: db $80
L1E777F: db $25
L1E7780: db $F8
L1E7781: db $FC
L1E7782: db $48
L1E7783: db $E2
L1E7784: db $DC
L1E7785: db $0A
L1E7786: db $1C
L1E7787: db $08
L1E7788: db $00
L1E7789: db $5C
L1E778A: db $EE
L1E778B: db $50
L1E778C: db $F4
L1E778D: db $08
L1E778E: db $44
L1E778F: db $38
L1E7790: db $7C
L1E7791: db $B4
L1E7792: db $78
L1E7793: db $01
L1E7794: db $0F
L1E7795: db $0A
L1E7796: db $03
L1E7797: db $0A
L1E7798: db $F7
L1E7799: db $C3
L1E779A: db $0A
L1E779B: db $F3
L1E779C: db $E1
L1E779D: db $E3
L1E779E: db $41
L1E779F: db $10
L1E77A0: db $80
L1E77A1: db $08
L1E77A2: db $C0
L1E77A3: db $7E
L1E77A4: db $E0
L1E77A5: db $09
L1E77A6: db $68
L1E77A7: db $10
L1E77A8: db $09
L1E77A9: db $48
L1E77AA: db $28
L1E77AB: db $40
L1E77AC: db $EA
L1E77AD: db $08
L1E77AE: db $19
L1E77AF: db $30
L1E77B0: db $F0
L1E77B1: db $10
L1E77B2: db $F8
L1E77B3: db $38
L1E77B4: db $FC
L1E77B5: db $2A
L1E77B6: db $08
L1E77B7: db $7C
L1E77B8: db $78
L1E77B9: db $01
L1E77BA: db $0C
L1E77BB: db $03
L1E77BC: db $10
L1E77BD: db $02
L1E77BE: db $B2
L1E77BF: db $08
L1E77C0: db $05
L1E77C1: db $20
L1E77C2: db $70
L1E77C3: db $07
L1E77C4: db $0F
L1E77C5: db $48
L1E77C6: db $B3
L1E77C7: db $01
L1E77C8: db $CC
L1E77C9: db $B8
L1E77CA: db $C7
L1E77CB: db $36
L1E77CC: db $C9
L1E77CD: db $AB
L1E77CE: db $D6
L1E77CF: db $C8
L1E77D0: db $96
L1E77D1: db $10
L1E77D2: db $FF
L1E77D3: db $94
L1E77D4: db $00
L1E77D5: db $6B
L1E77D6: db $18
L1E77D7: db $78
L1E77D8: db $C0
L1E77D9: db $6C
L1E77DA: db $80
L1E77DB: db $08
L1E77DC: db $18
L1E77DD: db $E0
L1E77DE: db $10
L1E77DF: db $08
L1E77E0: db $40
L1E77E1: db $60
L1E77E2: db $A7
L1E77E3: db $38
L1E77E4: db $70
L1E77E5: db $20
L1E77E6: db $F8
L1E77E7: db $30
L1E77E8: db $08
L1E77E9: db $58
L1E77EA: db $07
L1E77EB: db $A9
L1E77EC: db $01
L1E77ED: db $1C
L1E77EE: db $08
L1E77EF: db $62
L1E77F0: db $10
L1E77F1: db $81
L1E77F2: db $7E
L1E77F3: db $6F
L1E77F4: db $B5
L1E77F5: db $05
L1E77F6: db $03
L1E77F7: db $47
L1E77F8: db $04
L1E77F9: db $C0
L1E77FA: db $08
L1E77FB: db $F0
L1E77FC: db $57
L1E77FD: db $AA
L1E77FE: db $04
L1E77FF: db $01
L1E7800: db $FC
L1E7801: db $08
L1E7802: db $08
L1E7803: db $0C
L1E7804: db $08
L1E7805: db $FE
L1E7806: db $00
L1E7807: db $04
L1E7808: db $7E
L1E7809: db $34
L1E780A: db $FF
L1E780B: db $1A
L1E780C: db $F7
L1E780D: db $EA
L1E780E: db $E3
L1E780F: db $D6
L1E7810: db $30
L1E7811: db $DF
L1E7812: db $80
L1E7813: db $0A
L1E7814: db $C0
L1E7815: db $10
L1E7816: db $09
L1E7817: db $01
L1E7818: db $D4
L1E7819: db $28
L1E781A: db $09
L1E781B: db $05
L1E781C: db $08
L1E781D: db $0E
L1E781E: db $10
L1E781F: db $1F
L1E7820: db $06
L1E7821: db $BE
L1E7822: db $08
L1E7823: db $08
L1E7824: db $08
L1E7825: db $38
L1E7826: db $08
L1E7827: db $60
L1E7828: db $0A
L1E7829: db $0D
L1E782A: db $23
L1E782B: db $3F
L1E782C: db $1D
L1E782D: db $08
L1E782E: db $1E
L1E782F: db $3E
L1E7830: db $1C
L1E7831: db $00
L1E7832: db $68
L1E7833: db $81
L1E7834: db $03
L1E7835: db $C1
L1E7836: db $FE
L1E7837: db $C7
L1E7838: db $F8
L1E7839: db $FF
L1E783A: db $07
L1E783B: db $98
L1E783C: db $40
L1E783D: db $EA
L1E783E: db $78
L1E783F: db $D9
L1E7840: db $FC
L1E7841: db $3B
L1E7842: db $B9
L1E7843: db $D6
L1E7844: db $BB
L1E7845: db $55
L1E7846: db $45
L1E7847: db $9B
L1E7848: db $80
L1E7849: db $08
L1E784A: db $C0
L1E784B: db $08
L1E784C: db $20
L1E784D: db $10
L1E784E: db $58
L1E784F: db $E0
L1E7850: db $18
L1E7851: db $F0
L1E7852: db $10
L1E7853: db $09
L1E7854: db $7B
L1E7855: db $B5
L1E7856: db $73
L1E7857: db $04
L1E7858: db $AD
L1E7859: db $F1
L1E785A: db $6E
L1E785B: db $F3
L1E785C: db $6C
L1E785D: db $19
L1E785E: db $FF
L1E785F: db $01
L1E7860: db $3B
L1E7861: db $BF
L1E7862: db $50
L1E7863: db $09
L1E7864: db $9A
L1E7865: db $C8
L1E7866: db $F8
L1E7867: db $10
L1E7868: db $08
L1E7869: db $7C
L1E786A: db $30
L1E786B: db $08
L1E786C: db $38
L1E786D: db $29
L1E786E: db $49
L1E786F: db $00
L1E7870: db $00
L1E7871: db $07
L1E7872: db $9A
L1E7873: db $0A
L1E7874: db $0F
L1E7875: db $02
L1E7876: db $08
L1E7877: db $1A
L1E7878: db $1F
L1E7879: db $F8
L1E787A: db $67
L1E787B: db $1F
L1E787C: db $19
L1E787D: db $97
L1E787E: db $6A
L1E787F: db $40
L1E7880: db $00
L1E7881: db $30
L1E7882: db $0F
L1E7883: db $0A
L1E7884: db $40
L1E7885: db $03
L1E7886: db $10
L1E7887: db $83
L1E7888: db $7D
L1E7889: db $13
L1E788A: db $ED
L1E788B: db $F3
L1E788C: db $0D
L1E788D: db $B8
L1E788E: db $08
L1E788F: db $EC
L1E7890: db $1A
L1E7891: db $39
L1E7892: db $08
L1E7893: db $EF
L1E7894: db $C0
L1E7895: db $FC
L1E7896: db $C5
L1E7897: db $98
L1E7898: db $08
L1E7899: db $20
L1E789A: db $FE
L1E789B: db $70
L1E789C: db $0A
L1E789D: db $30
L1E789E: db $08
L1E789F: db $01
L1E78A0: db $40
L1E78A1: db $F2
L1E78A2: db $E0
L1E78A3: db $E8
L1E78A4: db $D0
L1E78A5: db $E4
L1E78A6: db $18
L1E78A7: db $08
L1E78A8: db $75
L1E78A9: db $D8
L1E78AA: db $09
L1E78AB: db $39
L1E78AC: db $08
L1E78AD: db $50
L1E78AE: db $19
L1E78AF: db $F0
L1E78B0: db $E8
L1E78B1: db $EA
L1E78B2: db $08
L1E78B3: db $E8
L1E78B4: db $07
L1E78B5: db $01
L1E78B6: db $0A
L1E78B7: db $03
L1E78B8: db $10
L1E78B9: db $07
L1E78BA: db $E8
L1E78BB: db $10
L1E78BC: db $09
L1E78BD: db $2B
L1E78BE: db $37
L1E78BF: db $18
L1E78C0: db $7D
L1E78C1: db $26
L1E78C2: db $7A
L1E78C3: db $D0
L1E78C4: db $20
L1E78C5: db $09
L1E78C6: db $3F
L1E78C7: db $98
L1E78C8: db $7E
L1E78C9: db $3C
L1E78CA: db $7F
L1E78CB: db $1A
L1E78CC: db $2A
L1E78CD: db $FF
L1E78CE: db $42
L1E78CF: db $08
L1E78D0: db $3E
L1E78D1: db $08
L1E78D2: db $9D
L1E78D3: db $08
L1E78D4: db $28
L1E78D5: db $AD
L1E78D6: db $08
L1E78D7: db $3D
L1E78D8: db $08
L1E78D9: db $59
L1E78DA: db $80
L1E78DB: db $06
L1E78DC: db $80
L1E78DD: db $08
L1E78DE: db $42
L1E78DF: db $C0
L1E78E0: db $08
L1E78E1: db $E0
L1E78E2: db $40
L1E78E3: db $F0
L1E78E4: db $60
L1E78E5: db $88
L1E78E6: db $41
L1E78E7: db $AB
L1E78E8: db $08
L1E78E9: db $63
L1E78EA: db $08
L1E78EB: db $B6
L1E78EC: db $08
L1E78ED: db $BE
L1E78EE: db $0A
L1E78EF: db $78
L1E78F0: db $1E
L1E78F1: db $DD
L1E78F2: db $3E
L1E78F3: db $5D
L1E78F4: db $08
L1E78F5: db $89
L1E78F6: db $AA
L1E78F7: db $10
L1E78F8: db $F6
L1E78F9: db $85
L1E78FA: db $E0
L1E78FB: db $DF
L1E78FC: db $B2
L1E78FD: db $AF
L1E78FE: db $76
L1E78FF: db $09
L1E7900: db $7E
L1E7901: db $98
L1E7902: db $AA
L1E7903: db $01
L1E7904: db $01
L1E7905: db $08
L1E7906: db $1E
L1E7907: db $10
L1E7908: db $0E
L1E7909: db $08
L1E790A: db $1F
L1E790B: db $18
L1E790C: db $06
L1E790D: db $3F
L1E790E: db $0F
L1E790F: db $18
L1E7910: db $0A
L1E7911: db $68
L1E7912: db $17
L1E7913: db $EC
L1E7914: db $0B
L1E7915: db $53
L1E7916: db $2F
L1E7917: db $D0
L1E7918: db $20
L1E7919: db $F0
L1E791A: db $97
L1E791B: db $40
L1E791C: db $08
L1E791D: db $1D
L1E791E: db $6C
L1E791F: db $CE
L1E7920: db $B5
L1E7921: db $30
L1E7922: db $40
L1E7923: db $80
L1E7924: db $07
L1E7925: db $08
L1E7926: db $DD
L1E7927: db $D8
L1E7928: db $10
L1E7929: db $03
L1E792A: db $00
L1E792B: db $18
L1E792C: db $00
L1E792D: db $00
L1E792E: db $05
L1E792F: db $6A
L1E7930: db $FF
L1E7931: db $D8
L1E7932: db $08
L1E7933: db $81
L1E7934: db $08
L1E7935: db $F1
L1E7936: db $08
L1E7937: db $F9
L1E7938: db $A0
L1E7939: db $00
L1E793A: db $F6
L1E793B: db $18
L1E793C: db $60
L1E793D: db $EE
L1E793E: db $11
L1E793F: db $8A
L1E7940: db $75
L1E7941: db $69
L1E7942: db $80
L1E7943: db $88
L1E7944: db $0B
L1E7945: db $E0
L1E7946: db $08
L1E7947: db $20
L1E7948: db $C0
L1E7949: db $19
L1E794A: db $27
L1E794B: db $70
L1E794C: db $A0
L1E794D: db $09
L1E794E: db $F8
L1E794F: db $10
L1E7950: db $08
L1E7951: db $40
L1E7952: db $08
L1E7953: db $78
L1E7954: db $F0
L1E7955: db $0A
L1E7956: db $50
L1E7957: db $10
L1E7958: db $CC
L1E7959: db $9F
L1E795A: db $68
L1E795B: db $9A
L1E795C: db $00
L1E795D: db $64
L1E795E: db $82
L1E795F: db $7C
L1E7960: db $C2
L1E7961: db $3C
L1E7962: db $CA
L1E7963: db $34
L1E7964: db $C6
L1E7965: db $14
L1E7966: db $38
L1E7967: db $E1
L1E7968: db $1E
L1E7969: db $09
L1E796A: db $61
L1E796B: db $0A
L1E796C: db $71
L1E796D: db $0E
L1E796E: db $24
L1E796F: db $73
L1E7970: db $0C
L1E7971: db $F0
L1E7972: db $0F
L1E7973: db $FF
L1E7974: db $D8
L1E7975: db $DE
L1E7976: db $EF
L1E7977: db $D3
L1E7978: db $19
L1E7979: db $07
L1E797A: db $80
L1E797B: db $0E
L1E797C: db $03
L1E797D: db $01
L1E797E: db $0A
L1E797F: db $29
L1E7980: db $E0
L1E7981: db $0C
L1E7982: db $40
L1E7983: db $BA
L1E7984: db $E4
L1E7985: db $C3
L1E7986: db $C4
L1E7987: db $83
L1E7988: db $C9
L1E7989: db $24
L1E798A: db $06
L1E798B: db $CC
L1E798C: db $60
L1E798D: db $D0
L1E798E: db $0F
L1E798F: db $08
L1E7990: db $8F
L1E7991: db $A0
L1E7992: db $1F
L1E7993: db $1F
L1E7994: db $21
L1E7995: db $1E
L1E7996: db $92
L1E7997: db $04
L1E7998: db $D9
L1E7999: db $90
L1E799A: db $10
L1E799B: db $70
L1E799C: db $07
L1E799D: db $10
L1E799E: db $08
L1E799F: db $28
L1E79A0: db $4E
L1E79A1: db $30
L1E79A2: db $44
L1E79A3: db $38
L1E79A4: db $00
L1E79A5: db $8C
L1E79A6: db $70
L1E79A7: db $B8
L1E79A8: db $40
L1E79A9: db $90
L1E79AA: db $60
L1E79AB: db $F0
L1E79AC: db $80
L1E79AD: db $32
L1E79AE: db $E0
L1E79AF: db $C0
L1E79B0: db $00
L1E79B1: db $78
L1E79B2: db $48
L1E79B3: db $B0
L1E79B4: db $09
L1E79B5: db $58
L1E79B6: db $16
L1E79B7: db $A0
L1E79B8: db $E8
L1E79B9: db $10
L1E79BA: db $29
L1E79BB: db $88
L1E79BC: db $A8
L1E79BD: db $0B
L1E79BE: db $C8
L1E79BF: db $F8
L1E79C0: db $F8
L1E79C1: db $59
L1E79C2: db $3B
L1E79C3: db $78
L1E79C4: db $38
L1E79C5: db $5C
L1E79C6: db $28
L1E79C7: db $7E
L1E79C8: db $7B
L1E79C9: db $1C
L1E79CA: db $08
L1E79CB: db $F8
L1E79CC: db $07
L1E79CD: db $01
L1E79CE: db $01
L1E79CF: db $0C
L1E79D0: db $3F
L1E79D1: db $AA
L1E79D2: db $09
L1E79D3: db $03
L1E79D4: db $08
L1E79D5: db $04
L1E79D6: db $10
L1E79D7: db $07
L1E79D8: db $18
L1E79D9: db $5D
L1E79DA: db $09
L1E79DB: db $3E
L1E79DC: db $DD
L1E79DD: db $7F
L1E79DE: db $C1
L1E79DF: db $08
L1E79E0: db $FF
L1E79E1: db $77
L1E79E2: db $0A
L1E79E3: db $5A
L1E79E4: db $36
L1E79E5: db $00
L1E79E6: db $E3
L1E79E7: db $09
L1E79E8: db $F9
L1E79E9: db $80
L1E79EA: db $0E
L1E79EB: db $C0
L1E79EC: db $B5
L1E79ED: db $08
L1E79EE: db $40
L1E79EF: db $20
L1E79F0: db $09
L1E79F1: db $F7
L1E79F2: db $28
L1E79F3: db $14
L1E79F4: db $98
L1E79F5: db $3B
L1E79F6: db $22
L1E79F7: db $C1
L1E79F8: db $0B
L1E79F9: db $00
L1E79FA: db $48
L1E79FB: db $41
L1E79FC: db $68
L1E79FD: db $19
L1E79FE: db $EA
L1E79FF: db $B9
L1E7A00: db $AB
L1E7A01: db $0B
L1E7A02: db $E0
L1E7A03: db $48
L1E7A04: db $10
L1E7A05: db $10
L1E7A06: db $F0
L1E7A07: db $D6
L1E7A08: db $18
L1E7A09: db $01
L1E7A0A: db $01
L1E7A0B: db $0C
L1E7A0C: db $02
L1E7A0D: db $10
L1E7A0E: db $0D
L1E7A0F: db $96
L1E7A10: db $12
L1E7A11: db $69
L1E7A12: db $16
L1E7A13: db $E9
L1E7A14: db $09
L1E7A15: db $0C
L1E7A16: db $F3
L1E7A17: db $0B
L1E7A18: db $1C
L1E7A19: db $12
L1E7A1A: db $E3
L1E7A1B: db $3E
L1E7A1C: db $C1
L1E7A1D: db $89
L1E7A1E: db $04
L1E7A1F: db $03
L1E7A20: db $09
L1E7A21: db $05
L1E7A22: db $93
L1E7A23: db $30
L1E7A24: db $0F
L1E7A25: db $00
L1E7A26: db $08
L1E7A27: db $07
L1E7A28: db $1F
L1E7A29: db $10
L1E7A2A: db $08
L1E7A2B: db $84
L1E7A2C: db $28
L1E7A2D: db $19
L1E7A2E: db $E6
L1E7A2F: db $28
L1E7A30: db $C7
L1E7A31: db $09
L1E7A32: db $45
L1E7A33: db $82
L1E7A34: db $35
L1E7A35: db $47
L1E7A36: db $81
L1E7A37: db $20
L1E7A38: db $A8
L1E7A39: db $87
L1E7A3A: db $08
L1E7A3B: db $83
L1E7A3C: db $78
L1E7A3D: db $5E
L1E7A3E: db $80
L1E7A3F: db $08
L1E7A40: db $40
L1E7A41: db $10
L1E7A42: db $0F
L1E7A43: db $0F
L1E7A44: db $0B
L1E7A45: db $C0
L1E7A46: db $AE
L1E7A47: db $B8
L1E7A48: db $E0
L1E7A49: db $10
L1E7A4A: db $F0
L1E7A4B: db $10
L1E7A4C: db $08
L1E7A4D: db $28
L1E7A4E: db $00
L1E7A4F: db $00
L1E7A50: db $00
L1E7A51: db $00
L1E7A52: db $00
L1E7A53: db $CB
L1E7A54: db $CC
L1E7A55: db $00
L1E7A56: db $D6
L1E7A57: db $D9
L1E7A58: db $D7
L1E7A59: db $D8
L1E7A5A: db $DA
L1E7A5B: db $EA
L1E7A5C: db $EB
L1E7A5D: db $EE
L1E7A5E: db $EC
L1E7A5F: db $ED
L1E7A60: db $EF
L1E7A61: db $00
L1E7A62: db $02
L1E7A63: db $00
L1E7A64: db $01
L1E7A65: db $03
L1E7A66: db $04
L1E7A67: db $12
L1E7A68: db $14
L1E7A69: db $15
L1E7A6A: db $13
L1E7A6B: db $16
L1E7A6C: db $17
L1E7A6D: db $3E
L1E7A6E: db $40
L1E7A6F: db $41
L1E7A70: db $3F
L1E7A71: db $42
L1E7A72: db $43
L1E7A73: db $00
L1E7A74: db $00
L1E7A75: db $00
L1E7A76: db $00
L1E7A77: db $CA
L1E7A78: db $00
L1E7A79: db $D0
L1E7A7A: db $D2
L1E7A7B: db $D3
L1E7A7C: db $D1
L1E7A7D: db $D4
L1E7A7E: db $D5
L1E7A7F: db $00
L1E7A80: db $E7
L1E7A81: db $00
L1E7A82: db $46
L1E7A83: db $E8
L1E7A84: db $E9
L1E7A85: db $00
L1E7A86: db $00
L1E7A87: db $00
L1E7A88: db $00
L1E7A89: db $10
L1E7A8A: db $00
L1E7A8B: db $DB
L1E7A8C: db $DD
L1E7A8D: db $DE
L1E7A8E: db $DC
L1E7A8F: db $DF
L1E7A90: db $E0
L1E7A91: db $F0
L1E7A92: db $F2
L1E7A93: db $F3
L1E7A94: db $F1
L1E7A95: db $F4
L1E7A96: db $F5
L1E7A97: db $00
L1E7A98: db $00
L1E7A99: db $00
L1E7A9A: db $00
L1E7A9B: db $05
L1E7A9C: db $00
L1E7A9D: db $18
L1E7A9E: db $19
L1E7A9F: db $1C
L1E7AA0: db $1A
L1E7AA1: db $1B
L1E7AA2: db $1D
L1E7AA3: db $44
L1E7AA4: db $45
L1E7AA5: db $48
L1E7AA6: db $46
L1E7AA7: db $47
L1E7AA8: db $49
L1E7AA9: db $00
L1E7AAA: db $00
L1E7AAB: db $00
L1E7AAC: db $00
L1E7AAD: db $82
L1E7AAE: db $83
L1E7AAF: db $81
L1E7AB0: db $84
L1E7AB1: db $85
L1E7AB2: db $AD
L1E7AB3: db $AF
L1E7AB4: db $B0
L1E7AB5: db $AE
L1E7AB6: db $B1
L1E7AB7: db $B2
L1E7AB8: db $C4
L1E7AB9: db $C5
L1E7ABA: db $C6
L1E7ABB: db $00
L1E7ABC: db $00
L1E7ABD: db $00
L1E7ABE: db $00
L1E7ABF: db $10
L1E7AC0: db $00
L1E7AC1: db $35
L1E7AC2: db $36
L1E7AC3: db $37
L1E7AC4: db $00
L1E7AC5: db $38
L1E7AC6: db $39
L1E7AC7: db $00
L1E7AC8: db $60
L1E7AC9: db $61
L1E7ACA: db $5F
L1E7ACB: db $62
L1E7ACC: db $63
L1E7ACD: db $00
L1E7ACE: db $00
L1E7ACF: db $00
L1E7AD0: db $00
L1E7AD1: db $86
L1E7AD2: db $89
L1E7AD3: db $87
L1E7AD4: db $88
L1E7AD5: db $8A
L1E7AD6: db $B3
L1E7AD7: db $B4
L1E7AD8: db $B7
L1E7AD9: db $B5
L1E7ADA: db $B6
L1E7ADB: db $B8
L1E7ADC: db $C7
L1E7ADD: db $C8
L1E7ADE: db $C9
L1E7ADF: db $00
L1E7AE0: db $00
L1E7AE1: db $00
L1E7AE2: db $6D
L1E7AE3: db $6E
L1E7AE4: db $00
L1E7AE5: db $6F
L1E7AE6: db $70
L1E7AE7: db $00
L1E7AE8: db $91
L1E7AE9: db $92
L1E7AEA: db $95
L1E7AEB: db $93
L1E7AEC: db $94
L1E7AED: db $00
L1E7AEE: db $BA
L1E7AEF: db $BB
L1E7AF0: db $00
L1E7AF1: db $00
L1E7AF2: db $00
L1E7AF3: db $00
L1E7AF4: db $00
L1E7AF5: db $78
L1E7AF6: db $00
L1E7AF7: db $77
L1E7AF8: db $79
L1E7AF9: db $7A
L1E7AFA: db $A1
L1E7AFB: db $A3
L1E7AFC: db $A4
L1E7AFD: db $A2
L1E7AFE: db $A5
L1E7AFF: db $A6
L1E7B00: db $BE
L1E7B01: db $BF
L1E7B02: db $C0
L1E7B03: db $00
L1E7B04: db $68
L1E7B05: db $00
L1E7B06: db $7B
L1E7B07: db $7C
L1E7B08: db $7F
L1E7B09: db $7D
L1E7B0A: db $7E
L1E7B0B: db $80
L1E7B0C: db $A7
L1E7B0D: db $A8
L1E7B0E: db $AB
L1E7B0F: db $A9
L1E7B10: db $AA
L1E7B11: db $AC
L1E7B12: db $C1
L1E7B13: db $C2
L1E7B14: db $C3
L1E7B15: db $00
L1E7B16: db $00
L1E7B17: db $00
L1E7B18: db $0E
L1E7B19: db $0F
L1E7B1A: db $00
L1E7B1B: db $2F
L1E7B1C: db $30
L1E7B1D: db $33
L1E7B1E: db $31
L1E7B1F: db $32
L1E7B20: db $34
L1E7B21: db $5A
L1E7B22: db $5B
L1E7B23: db $5E
L1E7B24: db $5C
L1E7B25: db $5D
L1E7B26: db $00
L1E7B27: db $00
L1E7B28: db $00
L1E7B29: db $00
L1E7B2A: db $00
L1E7B2B: db $0A
L1E7B2C: db $0B
L1E7B2D: db $23
L1E7B2E: db $24
L1E7B2F: db $27
L1E7B30: db $25
L1E7B31: db $26
L1E7B32: db $28
L1E7B33: db $4F
L1E7B34: db $50
L1E7B35: db $53
L1E7B36: db $51
L1E7B37: db $52
L1E7B38: db $54
L1E7B39: db $00
L1E7B3A: db $00
L1E7B3B: db $00
L1E7B3C: db $00
L1E7B3D: db $11
L1E7B3E: db $00
L1E7B3F: db $3A
L1E7B40: db $3B
L1E7B41: db $00
L1E7B42: db $3C
L1E7B43: db $3D
L1E7B44: db $00
L1E7B45: db $64
L1E7B46: db $65
L1E7B47: db $00
L1E7B48: db $66
L1E7B49: db $67
L1E7B4A: db $00
L1E7B4B: db $00
L1E7B4C: db $00
L1E7B4D: db $00
L1E7B4E: db $00
L1E7B4F: db $68
L1E7B50: db $00
L1E7B51: db $74
L1E7B52: db $75
L1E7B53: db $76
L1E7B54: db $9C
L1E7B55: db $9D
L1E7B56: db $A0
L1E7B57: db $9E
L1E7B58: db $9F
L1E7B59: db $00
L1E7B5A: db $00
L1E7B5B: db $BD
L1E7B5C: db $00
L1E7B5D: db $00
L1E7B5E: db $00
L1E7B5F: db $00
L1E7B60: db $0C
L1E7B61: db $0D
L1E7B62: db $00
L1E7B63: db $29
L1E7B64: db $2B
L1E7B65: db $2C
L1E7B66: db $2A
L1E7B67: db $2D
L1E7B68: db $2E
L1E7B69: db $55
L1E7B6A: db $57
L1E7B6B: db $58
L1E7B6C: db $56
L1E7B6D: db $59
L1E7B6E: db $00
L1E7B6F: db $00
L1E7B70: db $00
L1E7B71: db $00
L1E7B72: db $CD
L1E7B73: db $CE
L1E7B74: db $CF
L1E7B75: db $E1
L1E7B76: db $E2
L1E7B77: db $E5
L1E7B78: db $E3
L1E7B79: db $E4
L1E7B7A: db $E6
L1E7B7B: db $F6
L1E7B7C: db $F7
L1E7B7D: db $FA
L1E7B7E: db $F8
L1E7B7F: db $F9
L1E7B80: db $FB
L1E7B81: db $00
L1E7B82: db $07
L1E7B83: db $00
L1E7B84: db $06
L1E7B85: db $08
L1E7B86: db $09
L1E7B87: db $1E
L1E7B88: db $1F
L1E7B89: db $20
L1E7B8A: db $00
L1E7B8B: db $21
L1E7B8C: db $22
L1E7B8D: db $00
L1E7B8E: db $4B
L1E7B8F: db $4C
L1E7B90: db $4A
L1E7B91: db $4D
L1E7B92: db $4E
L1E7B93: db $00
L1E7B94: db $00
L1E7B95: db $00
L1E7B96: db $69
L1E7B97: db $6B
L1E7B98: db $00
L1E7B99: db $6A
L1E7B9A: db $6C
L1E7B9B: db $00
L1E7B9C: db $8B
L1E7B9D: db $8D
L1E7B9E: db $8E
L1E7B9F: db $8C
L1E7BA0: db $8F
L1E7BA1: db $90
L1E7BA2: db $00
L1E7BA3: db $B9
L1E7BA4: db $00
L1E7BA5: db $00
L1E7BA6: db $00
L1E7BA7: db $00
L1E7BA8: db $00
L1E7BA9: db $10
L1E7BAA: db $00
L1E7BAB: db $71
L1E7BAC: db $72
L1E7BAD: db $73
L1E7BAE: db $96
L1E7BAF: db $98
L1E7BB0: db $99
L1E7BB1: db $97
L1E7BB2: db $9A
L1E7BB3: db $9B
L1E7BB4: db $00
L1E7BB5: db $BC
L1E7BB6: db $00
L1E7BB7: db $1F
L1E7BB8: db $00
L1E7BB9: db $6A
L1E7BBA: db $00
L1E7BBB: db $0F
L1E7BBC: db $00
L1E7BBD: db $07
L1E7BBE: db $00
L1E7BBF: db $04
L1E7BC0: db $12
L1E7BC1: db $06
L1E7BC2: db $BA
L1E7BC3: db $10
L1E7BC4: db $03
L1E7BC5: db $00
L1E7BC6: db $F5
L1E7BC7: db $0F
L1E7BC8: db $FF
L1E7BC9: db $00
L1E7BCA: db $01
L1E7BCB: db $A2
L1E7BCC: db $12
L1E7BCD: db $03
L1E7BCE: db $10
L1E7BCF: db $86
L1E7BD0: db $FE
L1E7BD1: db $C2
L1E7BD2: db $10
L1E7BD3: db $43
L1E7BD4: db $6A
L1E7BD5: db $7F
L1E7BD6: db $F1
L1E7BD7: db $0F
L1E7BD8: db $07
L1E7BD9: db $00
L1E7BDA: db $04
L1E7BDB: db $12
L1E7BDC: db $06
L1E7BDD: db $AF
L1E7BDE: db $10
L1E7BDF: db $03
L1E7BE0: db $00
L1E7BE1: db $02
L1E7BE2: db $10
L1E7BE3: db $51
L1E7BE4: db $F1
L1E7BE5: db $0F
L1E7BE6: db $55
L1E7BE7: db $FF
L1E7BE8: db $00
L1E7BE9: db $01
L1E7BEA: db $12
L1E7BEB: db $03
L1E7BEC: db $10
L1E7BED: db $0F
L1E7BEE: db $10
L1E7BEF: db $0D
L1E7BF0: db $1A
L1E7BF1: db $FB
L1E7BF2: db $12
L1E7BF3: db $F3
L1E7BF4: db $F1
L1E7BF5: db $0F
L1E7BF6: db $3F
L1E7BF7: db $00
L1E7BF8: db $1D
L1E7BF9: db $E0
L1E7BFA: db $FF
L1E7BFB: db $80
L1E7BFC: db $10
L1E7BFD: db $60
L1E7BFE: db $10
L1E7BFF: db $0F
L1E7C00: db $10
L1E7C01: db $3A
L1E7C02: db $18
L1E7C03: db $F8
L1E7C04: db $11
L1E7C05: db $F1
L1E7C06: db $0F
L1E7C07: db $FF
L1E7C08: db $00
L1E7C09: db $31
L1E7C0A: db $AA
L1E7C0B: db $10
L1E7C0C: db $01
L1E7C0D: db $12
L1E7C0E: db $81
L1E7C0F: db $10
L1E7C10: db $E1
L1E7C11: db $91
L1E7C12: db $3F
L1E7C13: db $14
L1E7C14: db $61
L1E7C15: db $7F
L1E7C16: db $21
L1E7C17: db $30
L1E7C18: db $30
L1E7C19: db $10
L1E7C1A: db $10
L1E7C1B: db $1F
L1E7C1C: db $44
L1E7C1D: db $18
L1E7C1E: db $10
L1E7C1F: db $08
L1E7C20: db $0F
L1E7C21: db $0C
L1E7C22: db $10
L1E7C23: db $04
L1E7C24: db $07
L1E7C25: db $4A
L1E7C26: db $06
L1E7C27: db $10
L1E7C28: db $02
L1E7C29: db $03
L1E7C2A: db $01
L1E7C2B: db $01
L1E7C2C: db $02
L1E7C2D: db $00
L1E7C2E: db $A2
L1E7C2F: db $04
L1E7C30: db $04
L1E7C31: db $F0
L1E7C32: db $8C
L1E7C33: db $8F
L1E7C34: db $88
L1E7C35: db $10
L1E7C36: db $D8
L1E7C37: db $22
L1E7C38: db $DF
L1E7C39: db $50
L1E7C3A: db $10
L1E7C3B: db $70
L1E7C3C: db $FF
L1E7C3D: db $21
L1E7C3E: db $12
L1E7C3F: db $03
L1E7C40: db $88
L1E7C41: db $10
L1E7C42: db $02
L1E7C43: db $FE
L1E7C44: db $06
L1E7C45: db $10
L1E7C46: db $04
L1E7C47: db $FC
L1E7C48: db $8C
L1E7C49: db $8A
L1E7C4A: db $10
L1E7C4B: db $88
L1E7C4C: db $F8
L1E7C4D: db $D8
L1E7C4E: db $10
L1E7C4F: db $70
L1E7C50: db $00
L1E7C51: db $32
L1E7C52: db $00
L1E7C53: db $F3
L1E7C54: db $23
L1E7C55: db $E3
L1E7C56: db $61
L1E7C57: db $E1
L1E7C58: db $41
L1E7C59: db $C1
L1E7C5A: db $C0
L1E7C5B: db $A9
L1E7C5C: db $00
L1E7C5D: db $80
L1E7C5E: db $00
L1E7C5F: db $83
L1E7C60: db $00
L1E7C61: db $02
L1E7C62: db $03
L1E7C63: db $1D
L1E7C64: db $92
L1E7C65: db $01
L1E7C66: db $0E
L1E7C67: db $FE
L1E7C68: db $20
L1E7C69: db $FF
L1E7C6A: db $00
L1E7C6B: db $10
L1E7C6C: db $80
L1E7C6D: db $A2
L1E7C6E: db $10
L1E7C6F: db $C0
L1E7C70: db $10
L1E7C71: db $70
L1E7C72: db $7F
L1E7C73: db $FC
L1E7C74: db $30
L1E7C75: db $27
L1E7C76: db $02
L1E7C77: db $E7
L1E7C78: db $31
L1E7C79: db $F1
L1E7C7A: db $10
L1E7C7B: db $F0
L1E7C7C: db $1C
L1E7C7D: db $80
L1E7C7E: db $07
L1E7C7F: db $AC
L1E7C80: db $90
L1E7C81: db $00
L1E7C82: db $12
L1E7C83: db $30
L1E7C84: db $10
L1E7C85: db $01
L1E7C86: db $11
L1E7C87: db $1F
L1E7C88: db $50
L1E7C89: db $9F
L1E7C8A: db $00
L1E7C8B: db $E0
L1E7C8C: db $00
L1E7C8D: db $38
L1E7C8E: db $F8
L1E7C8F: db $0C
L1E7C90: db $FC
L1E7C91: db $15
L1E7C92: db $06
L1E7C93: db $FE
L1E7C94: db $02
L1E7C95: db $10
L1E7C96: db $03
L1E7C97: db $F0
L1E7C98: db $C1
L1E7C99: db $10
L1E7C9A: db $2E
L1E7C9B: db $61
L1E7C9C: db $7F
L1E7C9D: db $11
L1E7C9E: db $C3
L1E7C9F: db $50
L1E7CA0: db $B1
L1E7CA1: db $F1
L1E7CA2: db $1C
L1E7CA3: db $28
L1E7CA4: db $FC
L1E7CA5: db $F0
L1E7CA6: db $00
L1E7CA7: db $18
L1E7CA8: db $00
L1E7CA9: db $24
L1E7CAA: db $3C
L1E7CAB: db $42
L1E7CAC: db $1F
L1E7CAD: db $66
L1E7CAE: db $99
L1E7CAF: db $C3
L1E7CB0: db $40
L1E7CB1: db $20
L1E7CB2: db $40
L1E7CB3: db $20
L1E7CB4: db $40
L1E7CB5: db $B4
L1E7CB6: db $74
L1E7CB7: db $00
L1E7CB8: db $0F
L1E7CB9: db $04
L1E7CBA: db $01
L1E7CBB: db $00
L1E7CBC: db $02
L1E7CBD: db $03
L1E7CBE: db $03
L1E7CBF: db $04
L1E7CC0: db $06
L1E7CC1: db $09
L1E7CC2: db $0C
L1E7CC3: db $13
L1E7CC4: db $19
L1E7CC5: db $F5
L1E7CC6: db $0F
L1E7CC7: db $40
L1E7CC8: db $80
L1E7CC9: db $00
L1E7CCA: db $40
L1E7CCB: db $C0
L1E7CCC: db $20
L1E7CCD: db $60
L1E7CCE: db $90
L1E7CCF: db $30
L1E7CD0: db $30
L1E7CD1: db $C8
L1E7CD2: db $98
L1E7CD3: db $F5
L1E7CD4: db $07
L1E7CD5: db $E1
L1E7CD6: db $7C
L1E7CD7: db $FF
L1E7CD8: db $FF
L1E7CD9: db $FF;X
L1E7CDA: db $FF;X
L1E7CDB: db $0D
L1E7CDC: db $7D
L1E7CDD: db $FF
L1E7CDE: db $FF
L1E7CDF: db $FF;X
L1E7CE0: db $FF;X
L1E7CE1: db $80
L1E7CE2: db $00
L1E7CE3: db $00
L1E7CE4: db $FF;X
L1E7CE5: db $FF;X
L1E7CE6: db $FF;X
L1E7CE7: db $EB
L1E7CE8: db $7C
L1E7CE9: db $00
L1E7CEA: db $00
L1E7CEB: db $0B
L1E7CEC: db $07
L1E7CED: db $03
L1E7CEE: db $00
L1E7CEF: db $07
L1E7CF0: db $0B
L1E7CF1: db $02
L1E7CF2: db $07
L1E7CF3: db $13
L1E7CF4: db $04
L1E7CF5: db $07
L1E7CF6: db $1B
L1E7CF7: db $06
L1E7CF8: db $07
L1E7CF9: db $23
L1E7CFA: db $08
L1E7CFB: db $07
L1E7CFC: db $2B
L1E7CFD: db $0A
L1E7CFE: db $17
L1E7CFF: db $0B
L1E7D00: db $0C
L1E7D01: db $17
L1E7D02: db $13
L1E7D03: db $0E
L1E7D04: db $17
L1E7D05: db $1B
L1E7D06: db $10
L1E7D07: db $17
L1E7D08: db $23
L1E7D09: db $12
L1E7D0A: db $17
L1E7D0B: db $2B
L1E7D0C: db $14
L1E7D0D: db $80
L1E7D0E: db $00
L1E7D0F: db $00
L1E7D10: db $FF;X
L1E7D11: db $FF;X
L1E7D12: db $FF;X
L1E7D13: db $17
L1E7D14: db $7D
L1E7D15: db $00
L1E7D16: db $00
L1E7D17: db $03
L1E7D18: db $0C
L1E7D19: db $08
L1E7D1A: db $16
L1E7D1B: db $0C
L1E7D1C: db $00
L1E7D1D: db $18
L1E7D1E: db $0C
L1E7D1F: db $10
L1E7D20: db $1A
L1E7D21:;I
	rst  $10
	xor  a
	ld   [wGFXBufInfo_Pl1+iGFXBufInfo_TilesLeftA], a
	ld   [wGFXBufInfo_Pl1+iGFXBufInfo_TilesLeftB], a
	ld   [wGFXBufInfo_Pl2+iGFXBufInfo_TilesLeftA], a
	ld   [wGFXBufInfo_Pl2+iGFXBufInfo_TilesLeftB], a
	ld   a, $FF
	ldh  [rBGP], a
	ldh  [rOBP0], a
	ldh  [rOBP1], a
	ld   de, SCRPAL_STAGECLEAR
	call HomeCall_SGB_ApplyScreenPalSet
	call ClearBGMap
	ld   a, $18
	ld   b, $5A
	call SetSectLYC
	ld   hl, $6DA5
	ld   de, $C1EA
	call DecompressLZSS
	ld   hl, wOBJInfo_Pl1+iOBJInfo_Status
	ld   de, OBJInfoInit_Terry_WinA
	call OBJLstS_InitFrom
	call L1E7DEE
	ld   a, $60
	ldh  [rWY], a
	ld   a, $0F
	ldh  [rWX], a
	ld   a, $E7
	rst  $18
	ldh  a, [rSTAT]
	or   a, $40
	ldh  [rSTAT], a
	ei
	call Task_PassControl_Delay09
	ld   a, $8C
	ldh  [rOBP0], a
	ld   a, $2D
	ldh  [rBGP], a
	ldh  [hScreenSect1BGP], a
	ld   a, $13
	ldh  [hScreenSect0BGP], a
	ldh  [hScreenSect2BGP], a
	ld   a, $82
	call HomeCall_Sound_ReqPlayExId_Stub
	ld   a, BANK(L1E7DE8)
	ld   [wTextPrintFrameCodeBank], a
	ld   hl, wTextPrintFrameCodePtr_Low
	ld   [hl], LOW(L1E7DE8)
	inc  hl
	ld   [hl], HIGH(L1E7DE8)
	ld   a, [wCharSelTeamFull]
	ld   c, a
	ld   a, [wCharSelP1CursorMode]
	ld   b, a
	ld   hl, $002C
	add  hl, bc
	ld   d, $00
	ld   e, [hl]
	ld   hl, $7F3A
	add  hl, de
	ld   e, [hl]
	inc  hl
	ld   d, [hl]
	push de
	pop  hl
	ld   de, WINDOWMap_Begin
	ld   b, $1C
	ld   c, $04
	ld   a, $03
	call TextPrinter_MultiFrameFarCustomPos
	call L1E7EC9
	ld   a, $FF
	ldh  [rBGP], a
	ldh  [rOBP0], a
	ldh  [rOBP1], a
	ldh  [hScreenSect1BGP], a
	call ClearBGMap
	ld   hl, wMisc_C028
	res  0, [hl]
	xor  a
	ldh  [rSTAT], a
	ld   [wOBJInfo_Pl1+iOBJInfo_Status], a
	ld   [wOBJInfo_Pl1+iOBJInfo_X], a
	ld   [wOBJInfo_Pl1+iOBJInfo_Y], a
	xor  a
	ld   [wGFXBufInfo_Pl1+iGFXBufInfo_TilesLeftA], a
	ld   [wGFXBufInfo_Pl1+iGFXBufInfo_TilesLeftB], a
	ld   [wGFXBufInfo_Pl2+iGFXBufInfo_TilesLeftA], a
	ld   [wGFXBufInfo_Pl2+iGFXBufInfo_TilesLeftB], a
	jp   Task_PassControl_NoDelay
L1E7DE8:;I
	ld   hl, wOBJInfo_Pl1+iOBJInfo_Status
	jp   OBJLstS_DoAnimTiming_NoLoop
L1E7DEE:;C
	ld   a, [wCharSelTeamFull]
	ld   c, a
	ld   a, [wCharSelP1CursorMode]
	ld   b, a
	push bc
	ld   hl, $002C
	add  hl, bc
	ld   d, $00
	ld   e, [hl]
	sla  e
	rl   d
	ld   hl, $7EEA
	add  hl, de
	push hl
	pop  bc
	ld   de, wOBJInfo_Pl1+iOBJInfo_Status
	ld   a, [de]
	and  a, $EF
	or   a, $80
	ld   [de], a
	ld   hl, $0010
	add  hl, de
	ld   a, [bc]
	ldi  [hl], a
	inc  bc
	ld   a, [bc]
	ldi  [hl], a
	inc  bc
	ld   a, [bc]
	ldi  [hl], a
	inc  bc
	xor  a
	ld   [hl], a
	ld   hl, $0003
	add  hl, de
	ld   a, $50
	ldi  [hl], a
	inc  hl
	ld   [hl], $20
	ld   hl, $001B
	add  hl, de
	ld   a, [bc]
	ldi  [hl], a
	ld   [hl], a
	push de
	pop  hl
	call OBJLstS_DoAnimTiming_Initial
	pop  bc
	ld   hl, $002D
	add  hl, bc
	ld   a, [hl]
	cp   $01
	jr   z, L1E7E6B
	cp   $02
	jr   z, L1E7E92
	ld   hl, $002F
	add  hl, bc
	ld   a, [hl]
	cp   $FF
	jr   z, L1E7E59
	ld   de, $8800
	push bc
	ld   c, a
	call L1E68D2
	call L1E7EC2
	pop  bc
L1E7E59:;R
	ld   hl, $0030
	add  hl, bc
	ld   a, [hl]
	cp   $FF
	jr   z, L1E7EC8
	ld   de, $8920
	ld   c, a
	call L1E68E5
	jr   L1E7EB7
L1E7E6B:;R
	ld   hl, $002E
	add  hl, bc
	ld   a, [hl]
	cp   $FF
	jr   z, L1E7E80
	ld   de, $8800
	push bc
	ld   c, a
	call L1E68D2
	call L1E7EC2
	pop  bc
L1E7E80:
	ld   hl, $0030
	add  hl, bc
	ld   a, [hl]
	cp   $FF
	jr   z, L1E7EC8
	ld   de, $8920
	ld   c, a
	call L1E68E5
	jr   L1E7EB7
L1E7E92:;R
	ld   hl, $002E
	add  hl, bc
	ld   a, [hl]
	cp   $FF
	jr   z, L1E7EA7
	ld   de, $8800
	push bc
	ld   c, a
	call L1E68D2
	call L1E7EC2
	pop  bc
L1E7EA7:
	ld   hl, $002F
	add  hl, bc
	ld   a, [hl]
	cp   $FF
	jr   z, L1E7EC8
	ld   de, $8920
	ld   c, a
	call L1E68E5
L1E7EB7:;R
	ld   hl, $988E
	ld   de, $695E
	ld   a, $92
	jp   L1E692C
L1E7EC2:;C
	ld   hl, $9883
	call L1E6927
L1E7EC8:;R
	ret
L1E7EC9:;C
	ld   b, $F0
L1E7ECB:;J
	ldh  a, [hJoyNewKeys]
	bit  7, a
	jp   nz, L1E7EE8
	ldh  a, [hJoyNewKeys2]
	bit  7, a
	jp   nz, L1E7EE8
	ld   hl, wOBJInfo_Pl1+iOBJInfo_Status
	call OBJLstS_DoAnimTiming_NoLoop
	call Task_PassControl_NoDelay
	dec  b
	jp   nz, L1E7ECB
	xor  a
	ret
L1E7EE8:;J
	scf
	ret
L1E7EEA: db $07
L1E7EEB: db $58
L1E7EEC: db $41
L1E7EED: db $08
L1E7EEE: db $09
L1E7EEF: db $C2
L1E7EF0: db $40
L1E7EF1: db $08
L1E7EF2: db $09
L1E7EF3: db $AE
L1E7EF4: db $4E
L1E7EF5: db $08
L1E7EF6: db $08
L1E7EF7: db $BE
L1E7EF8: db $41
L1E7EF9: db $08
L1E7EFA: db $0A
L1E7EFB: db $40
L1E7EFC: db $41
L1E7EFD: db $08
L1E7EFE: db $07
L1E7EFF: db $EB
L1E7F00: db $53
L1E7F01: db $08
L1E7F02: db $08
L1E7F03: db $8F
L1E7F04: db $52
L1E7F05: db $08
L1E7F06: db $08
L1E7F07: db $FE
L1E7F08: db $60
L1E7F09: db $08
L1E7F0A: db $0A
L1E7F0B: db $AB
L1E7F0C: db $5D
L1E7F0D: db $08
L1E7F0E: db $07
L1E7F0F: db $4A
L1E7F10: db $62
L1E7F11: db $08
L1E7F12: db $09
L1E7F13: db $53
L1E7F14: db $5B
L1E7F15: db $08
L1E7F16: db $07
L1E7F17: db $C1
L1E7F18: db $70
L1E7F19: db $08
L1E7F1A: db $05
L1E7F1B: db $5C
L1E7F1C: db $41
L1E7F1D: db $08
L1E7F1E: db $09
L1E7F1F: db $91
L1E7F20: db $68
L1E7F21: db $08
L1E7F22: db $05
L1E7F23: db $93
L1E7F24: db $55
L1E7F25: db $08
L1E7F26: db $08
L1E7F27: db $FC
L1E7F28: db $6F
L1E7F29: db $08
L1E7F2A: db $0A
L1E7F2B: db $22
L1E7F2C: db $46
L1E7F2D: db $08
L1E7F2E: db $05
L1E7F2F: db $72
L1E7F30: db $41
L1E7F31: db $08
L1E7F32: db $0A
L1E7F33: db $BD
L1E7F34: db $5D
L1E7F35: db $08
L1E7F36: db $05
L1E7F37: db $9D
L1E7F38: db $55
L1E7F39: db $08
L1E7F3A: db $1A
L1E7F3B: db $75
L1E7F3C: db $46
L1E7F3D: db $75
L1E7F3E: db $71
L1E7F3F: db $75
L1E7F40: db $9A
L1E7F41: db $75
L1E7F42: db $BB
L1E7F43: db $75
L1E7F44: db $F4
L1E7F45: db $75
L1E7F46: db $1F
L1E7F47: db $76
L1E7F48: db $45
L1E7F49: db $76
L1E7F4A: db $7C
L1E7F4B: db $76
L1E7F4C: db $9B
L1E7F4D: db $76
L1E7F4E: db $CC
L1E7F4F: db $76
L1E7F50: db $00
L1E7F51: db $77
L1E7F52: db $27
L1E7F53: db $77
L1E7F54: db $56
L1E7F55: db $77
L1E7F56: db $86
L1E7F57: db $77
L1E7F58: db $B7
L1E7F59: db $77
L1E7F5A: db $EA
L1E7F5B: db $77
L1E7F5C: db $0F
L1E7F5D: db $78
L1E7F5E: db $1C
L1E7F5F: db $78
L1E7F60: db $28
L1E7F61: db $78
L1E7F62: db $76;X
L1E7F63: db $00;X
L1E7F64: db $77;X
L1E7F65: db $27;X
L1E7F66: db $77;X
L1E7F67: db $56;X
L1E7F68: db $77;X
L1E7F69: db $86;X
L1E7F6A: db $77;X
L1E7F6B: db $B7;X
L1E7F6C: db $77;X
L1E7F6D: db $EA;X
L1E7F6E: db $77;X
L1E7F6F: db $0F;X
L1E7F70: db $78;X
L1E7F71: db $1C;X
L1E7F72: db $78;X
L1E7F73: db $28;X
L1E7F74: db $78;X
L1E7F75: db $3E;X
L1E7F76: db $82;X
L1E7F77: db $CD;X
L1E7F78: db $31;X
L1E7F79: db $11;X
L1E7F7A: db $CD;X
L1E7F7B: db $55;X
L1E7F7C: db $81;X
L1E7F7D: db $DA;X
L1E7F7E: db $86;X
L1E7F7F: db $7F;X
L1E7F80: db $CD;X
L1E7F81: db $08;X
L1E7F82: db $04;X
L1E7F83: db $C3;X
L1E7F84: db $7A;X
L1E7F85: db $7F;X
L1E7F86: db $CD;X
L1E7F87: db $08;X
L1E7F88: db $04;X
L1E7F89: db $C9;X
L1E7F8A: db $01;X
L1E7F8B: db $00;X
L1E7F8C: db $D9;X
L1E7F8D: db $FA;X
L1E7F8E: db $5E;X
L1E7F8F: db $C1;X
L1E7F90: db $B7;X
L1E7F91: db $CA;X
L1E7F92: db $97;X
L1E7F93: db $7F;X
L1E7F94: db $01;X
L1E7F95: db $00;X
L1E7F96: db $DA;X
L1E7F97: db $C5;X
L1E7F98: db $21;X
L1E7F99: db $2C;X
L1E7F9A: db $00;X
L1E7F9B: db $09;X
L1E7F9C: db $7E;X
L1E7F9D: db $11;X
L1E7F9E: db $40;X
L1E7F9F: db $8A;X
L1E7FA0: db $06;X
L1E7FA1: db $01;X
L1E7FA2: db $CD;X
L1E7FA3: db $37;X
L1E7FA4: db $80;X
L1E7FA5: db $21;X
L1E7FA6: db $67;X
L1E7FA7: db $98;X
L1E7FA8: db $11;X
L1E7FA9: db $FC;X
L1E7FAA: db $81;X
L1E7FAB: db $3E;X
L1E7FAC: db $A4;X
L1E7FAD: db $06;X
L1E7FAE: db $06;X
L1E7FAF: db $0E;X
L1E7FB0: db $06;X
L1E7FB1: db $CD;X
L1E7FB2: db $BC;X
L1E7FB3: db $0D;X
L1E7FB4: db $C1;X
L1E7FB5: db $FA;X
L1E7FB6: db $29;X
L1E7FB7: db $C0;X
L1E7FB8: db $FE;X
L1E7FB9: db $03;X
L1E7FBA: db $C2;X
L1E7FBB: db $CF;X
L1E7FBC: db $7F;X
L1E7FBD: db $FA;X
L1E7FBE: db $74;X
L1E7FBF: db $C1;X
L1E7FC0: db $FE;X
L1E7FC1: db $0F;X
L1E7FC2: db $CA;X
L1E7FC3: db $36;X
L1E7FC4: db $80;X
L1E7FC5: db $FE;X
L1E7FC6: db $10;X
L1E7FC7: db $CA;X
L1E7FC8: db $36;X
L1E7FC9: db $80;X
L1E7FCA: db $FE;X
L1E7FCB: db $11;X
L1E7FCC: db $CA;X
L1E7FCD: db $36;X
L1E7FCE: db $80;X
L1E7FCF: db $FA;X
L1E7FD0: db $5D;X
L1E7FD1: db $C1;X
L1E7FD2: db $CB;X
L1E7FD3: db $47;X
L1E7FD4: db $CA;X
L1E7FD5: db $36;X
L1E7FD6: db $80;X
L1E7FD7: db $FA;X
L1E7FD8: db $49;X
L1E7FD9: db $D9;X
L1E7FDA: db $21;X
L1E7FDB: db $49;X
L1E7FDC: db $DA;X
L1E7FDD: db $BE;X
L1E7FDE: db $C2;X
L1E7FDF: db $E6;X
L1E7FE0: db $7F;X
L1E7FE1: db $21;X
L1E7FE2: db $67;X
L1E7FE3: db $00;X
L1E7FE4: db $09;X
L1E7FE5: db $35;X
L1E7FE6: db $C5;X
L1E7FE7: db $21;X
L1E7FE8: db $67;X
L1E7FE9: db $00;X
L1E7FEA: db $09;X
L1E7FEB: db $2A;X
L1E7FEC: db $FE;X
L1E7FED: db $00;X
L1E7FEE: db $C2;X
L1E7FEF: db $F2;X
L1E7FF0: db $7F;X
L1E7FF1: db $23;X
L1E7FF2: db $7E;X
L1E7FF3: db $11;X
L1E7FF4: db $00;X
L1E7FF5: db $88;X
L1E7FF6: db $06;X
L1E7FF7: db $00;X
L1E7FF8: db $CD;X
L1E7FF9: db $37;X
L1E7FFA: db $80;X
L1E7FFB: db $21;X
L1E7FFC: db $61;X
L1E7FFD: db $98;X
L1E7FFE: db $11;X
L1E7FFF: db $FC;X
