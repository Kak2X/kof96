GFX_Play_HUD_1PHuman: INCBIN "data/gfx/play_hud_1phuman.bin"
GFX_Play_HUD_2PHuman: INCBIN "data/gfx/play_hud_2phuman.bin"
GFX_Play_HUD_1PCPU: INCBIN "data/gfx/play_hud_1pcpu.bin"
GFX_Play_HUD_2PCPU: INCBIN "data/gfx/play_hud_2pcpu.bin"
GFXLZ_Play_HUD_CharNames: INCBIN "data/gfx/play_hud_charnames.lzc"
; "Tilemaps" for the character names in the HUD
BGXDef_Play_HUD_CharName_Kyo: mBinDef "data/bg/play_hud_charname_kyo.bin"
BGXDef_Play_HUD_CharName_Daimon: mBinDef "data/bg/play_hud_charname_daimon.bin"
BGXDef_Play_HUD_CharName_Terry: mBinDef "data/bg/play_hud_charname_terry.bin"
BGXDef_Play_HUD_CharName_Andy: mBinDef "data/bg/play_hud_charname_andy.bin"
BGXDef_Play_HUD_CharName_Ryo: mBinDef "data/bg/play_hud_charname_ryo.bin"
BGXDef_Play_HUD_CharName_Robert: mBinDef "data/bg/play_hud_charname_robert.bin"
BGXDef_Play_HUD_CharName_Athena: mBinDef "data/bg/play_hud_charname_athena.bin"
BGXDef_Play_HUD_CharName_Mai: mBinDef "data/bg/play_hud_charname_mai.bin"
BGXDef_Play_HUD_CharName_Leona: mBinDef "data/bg/play_hud_charname_leona.bin"
BGXDef_Play_HUD_CharName_Geese: mBinDef "data/bg/play_hud_charname_geese.bin"
BGXDef_Play_HUD_CharName_Krauser: mBinDef "data/bg/play_hud_charname_krauser.bin"
BGXDef_Play_HUD_CharName_MrBig: mBinDef "data/bg/play_hud_charname_mrbig.bin"
BGXDef_Play_HUD_CharName_Iori: mBinDef "data/bg/play_hud_charname_iori.bin"
BGXDef_Play_HUD_CharName_Mature: mBinDef "data/bg/play_hud_charname_mature.bin"
BGXDef_Play_HUD_CharName_Chizuru: mBinDef "data/bg/play_hud_charname_chizuru.bin"
BGXDef_Play_HUD_CharName_Goenitz: mBinDef "data/bg/play_hud_charname_goenitz.bin"
BGXDef_Play_HUD_CharName_MrKarate: mBinDef "data/bg/play_hud_charname_mrkarate.bin"
BGXDef_Play_HUD_CharName_OIori: mBinDef "data/bg/play_hud_charname_oiori.bin"
BGXDef_Play_HUD_CharName_OLeona: mBinDef "data/bg/play_hud_charname_oleona.bin"
BGXDef_Play_HUD_CharName_Kagura: mBinDef "data/bg/play_hud_charname_kagura.bin"

GFX_Char_Icons: INCBIN "data/gfx/char_icons.bin"
GFXLZ_Play_HUD: INCBIN "data/gfx/play_hud.lzc"
BG_Play_HUD_Time: INCBIN "data/bg/play_hud_time.bin"
BG_Play_HUD_HealthBarL: INCBIN "data/bg/play_hud_healthbarl.bin"
BG_Play_HUD_HealthBarR: INCBIN "data/bg/play_hud_healthbarr.bin"
BG_Play_HUD_BlankPowBar: INCBIN "data/bg/play_hud_blankpowbar.bin"
BG_Play_HUD_1PMarker: INCBIN "data/bg/play_hud_1pmarker.bin"
BG_Play_HUD_2PMarker: INCBIN "data/bg/play_hud_2pmarker.bin"
GFX_Play_HUD_SingleWinMarker: INCBIN "data/gfx/play_hud_singlewinmarker.bin"
GFX_Play_HUD_Cross: INCBIN "data/gfx/play_hud_cross.bin"
GFX_Play_HUD_Cross_Mask: INCBIN "data/gfx/play_hud_cross_mask.bin"

; Note that the actual BGP palette used effectively inverts white/black
FontDef_Default:
	dw $9000 	; Destination ptr
IF REV_LANG_EN == 0
	db $80 		; Tiles to copy
ELSE
	db $4E 		; Tiles to copy
ENDC
.col:
	db COL_WHITE ; Bit0 color map (background)
	db COL_BLACK ; Bit1 color map (foreground)
	; 1bpp font gfx
.gfx:
IF REV_LANG_EN == 0
	INCBIN "data/gfx/jp/font.bin"
ELSE
	INCBIN "data/gfx/en/font.bin"
ENDC
; 
; =============== START OF MODULE Win ===============
;
; =============== Module_Win ===============
; Entry point for the post-stage module.
; This handles everything between rounds:
; - Win Screen
; - Stage progression / Bonus Fights
; - "DRAW" Screen
; - Continue/Game Over
; - Cutscenes
; - Credits
Module_Win:

	;
	; Shared initialization code.
	; Depending on what we're doing, other initialization code may be also called (ie: SubModule_WinScr)
	;

	ld   sp, $DD00
	di
	;-----------------------------------
	rst  $10				; Stop LCD
	
	; We're no longer in gameplay, so disable the player/sprite range enforcement
	ld   hl, wMisc_C028
	res  MISCB_PL_RANGE_CHECK, [hl]
	
	; Reset DMG pal
	xor  a
	ldh  [rBGP], a
	ldh  [rOBP0], a
	ldh  [rOBP1], a
	
	; Reset tilemaps
	call ClearBGMap
	call ClearWINDOWMap
	
	; Reset screen scrolling
	xor  a
	ldh  [hScrollX], a
	ldh  [hScrollY], a
	ld   [wOBJScrollX], a
	ld   [wOBJScrollY], a
	
	; Load font GFX
	call LoadGFX_1bppFont_Default
	
	; Clear all sprites
	call ClearOBJInfo
	
	; If serial is enabled, syncronize with other GB.
	; The win screen timing should 100% match across the two GBs, like with gameplay.
	call Serial_DoHandshake
	
	;
	; Determine which path of execution we're taking, depending on who won/lost the last round.
	;
	
	; If the last round ended in a draw, display the "DRAW" screen.
	ld   a, [wStageDraw]
	or   a
	jp   nz, .draw
	
.chkWon1P:
	; Note that wLastWinner can have only one bit set at most.
	; ie: if 1P is marked as winner, 2P definitely isn't marked.
	ld   a, [wLastWinner]
	bit  PLB1, a			; Did 1P win the last round?
	jp   z, .chkWon2P		; If not, jump
.won1P:
	; Save the address of the winner (1P) to wWinPlInfoPtr.
	; This will be the player sprite that gets animated in SubModule_WinScr.
	ld   bc, wPlInfo_Pl1
	ld   a, c
	ld   [wWinPlInfoPtr_Low], a
	ld   a, b
	ld   [wWinPlInfoPtr_High], a
	
	; VS mode doesn't distinguish between winning/losing.
	ld   a, [wPlayMode]
	bit  MODEB_VS, a		; Playing in VS mode?
	jp   nz, .vsWon1P		; If so, jump
	
	; Single mode, obviously, have to distinguish between those.
	; Winning lets you continue, while losing throws you
	; Determine if the active player won or lost the round.
	ld   a, [wJoyActivePl]
	or   a					; Is the current player on the 1P side? (wJoyActivePl == PL1)
	jp   nz, .lost			; If not, jump (2P lost)
	jp   .won				; (1P won)
.chkWon2P:
	
	; 1P didn't win.
	; If 2P didn't win too, this also counts as a draw.
	ld   a, [wLastWinner]
	bit  PLB2, a		; Did 2P win the stage?
	jp   z, .draw		; If not, jump
.won2P:

	; Save the address of the winner (2P) to wWinPlInfoPtr.
	; This will be the player sprite that gets animated in SubModule_WinScr.
	ld   bc, wPlInfo_Pl2
	ld   a, c
	ld   [wWinPlInfoPtr_Low], a
	ld   a, b
	ld   [wWinPlInfoPtr_High], a
	
	; VS mode doesn't distinguish between winning/losing.
	ld   a, [wPlayMode]
	bit  MODEB_VS, a		; Playing in VS mode?
	jp   nz, .vsWon2P		; If so, jump
	
	; Determine if the active player won or lost the round.
	ld   a, [wJoyActivePl]
	or   a					; Is the current player on the 1P side? (wJoyActivePl == PL1)
	jp   z, .lost			; If so, jump (1P lost)
	jp   .won				; (2P won)
	
.draw:
	; Print out "DRAW" to the center of the screen
	ld   hl, TextDef_Win_Draw
	call TextPrinter_Instant
	
	; A draw counts as a loss, and just like losing the round:
	; - In Single mode, you are thrown to the continue screen
	; - In VS mode, you return back to the character select screen
	ld   a, [wPlayMode]
	bit  MODEB_VS, a
	jp   nz, .vsDraw
	
.singleDraw:
	jp   Win_Mode_SingleDraw
.vsDraw:
	jp   Win_Mode_VSDraw
; Both point to the same location, as in VS mode, regardless of winning or losing,
; both players return to the character select.
.vsWon1P:
	jp   Win_Mode_VS
.vsWon2P:
	jp   Win_Mode_VS
.won:
	jp   Win_Mode_SingleWon
.lost:
	jp   Win_Mode_SingleLost
	
; =============== Win_Mode_VS ===============
; VS Match ended.
Win_Mode_VS:
	; Show win screen with the character who won
	call Win_DoWinScr
	; Clear both team members to vary up watch mode
	call Win_ResetCharsOnEndlessCpuVsCpu
	; We're done
	jp   Win_SwitchToCharSel
; =============== Win_Mode_SingleWon ===============
; Won a stage in Single Mode.
Win_Mode_SingleWon:
	; Show win screen with the character who won
	call Win_DoWinScr
	; Fall-through
	
; =============== Win_StartNextStage ===============
; Advances the stage progession for Single mode, handling cutscenes and bonus rounds.
Win_StartNextStage:
	; Increment stage sequence number
	call Win_IncStageSeq
	
	; Display cutscenes when the higher stage sequence numbers are reached.
	; Note that all of the cutscenes skip the character select screen, and either
	; jump to gameplay (1P mode), or put you into the order select screen (team mode).
	ld   a, [wCharSeqId]				; A = New stage number
	cp   STAGESEQ_KAGURA				; Is KAGURA's stage next?
	jp   z, Win_KaguraCutscene			; If so, jump
	cp   STAGESEQ_GOENITZ				; Is GOENITZ's stage next?
	jp   z, Win_GoenitzCutscene			; If so, jump
	cp   STAGESEQ_GOENITZ+1				; Did we just defeat Goenitz?
	jp   z, Win_EndingCutscene			; If so, jump
	cp   STAGESEQ_BONUS+1				; Did we just defeat the bonus O.Iori/O.Leona opponent?
	jp   z, Win_CreditsStub				; If so, jump
	cp   STAGESEQ_MRKARATE+1			; Did we just defeat Mr.Karate?
	jp   z, Win_MrKarateDefeatCutscene	; If so, jump
	
	; Otherwise, go back to the character select screen
	jp   Win_SwitchToCharSel
	
; =============== Win_KaguraCutscene ===============
; Displays the pre-match Kagura cutscene.
Win_KaguraCutscene:
	; Execute cutscene
	ld   b, BANK(SubModule_CutsceneKagura) ; BANK $1D
	ld   hl, SubModule_CutsceneKagura
	rst  $08
.cont:
	;---
	ld   bc, $0000 				; Not needed
	; Set new opponent
	call Win_SetSpecRoundChar
	
	ld   a, [wPlayMode]
	bit  MODEB_TEAM, a		; Playing in Team Mode?
	jp   nz, .team			; If so, jump
.single:
	; Since there's no order select screen in 1P mode, Immediately proceed to gameplay.
	call Pl_InitBeforeStageLoad
	jp   Module_Play
.team:
	; Switch to the order select screen.
	call Pl_InitBeforeStageLoad
	ld   b, BANK(Module_OrdSel) ; BANK $1E
	ld   hl, Module_OrdSel
	rst  $00
	
; =============== Win_GoenitzCutscene ===============
; Displays the pre-match Goenitz cutscene.
Win_GoenitzCutscene:
	; Execute cutscene
	ld   b, BANK(SubModule_CutsceneGoenitz) ; BANK $1D
	ld   hl, SubModule_CutsceneGoenitz
	rst  $08
	
	;
	; The game ends here on EASY mode, you don't get to fight Goenitz.
	;
	ld   a, [wDifficulty]
	cp   DIFFICULTY_EASY	; Playing on EASY, eh?
	jp   nz, .cont			; If not, jump
.easy:
	; Display the credits
	ld   b, BANK(SubModule_Credits) ; BANK $1D
	ld   hl, SubModule_Credits
IF REV_VER_2 == 1
	; Play the credits music, since the Kagura cutscene music is still playing
	ld   d, $01	
ENDC
	rst  $08
	
	; THE END
	ld   b, BANK(SubModule_TheEnd) ; BANK $1D
	ld   hl, SubModule_TheEnd
	rst  $08
	
	; Reset!
	ld   b, BANK(Module_TakaraLogo) ; BANK $0A
	ld   hl, Module_TakaraLogo
	rst  $00
	
.cont:
	;---
	ld   bc, $0000 				; Not needed
	; Set new opponent
	call Win_SetSpecRoundChar
	
	ld   a, [wPlayMode]
	bit  MODEB_TEAM, a		; Playing in Team Mode?
	jp   nz, .team			; If so, jump
.single:
	; Since there's no order select screen in 1P mode, Immediately proceed to gameplay.
	call Pl_InitBeforeStageLoad
	jp   Module_Play
.team:
	; Switch to the order select screen.
	call Pl_InitBeforeStageLoad
	ld   b, BANK(Module_OrdSel) ; BANK $1E
	ld   hl, Module_OrdSel
	rst  $00
; =============== Win_EndingCutscene ===============
; Displays the post-match Goenitz cutscene.
Win_EndingCutscene:
	;
	; There are multiple variations of the ending, depending on the team used.
	; Some variations just add extra lines to the end of the cutscene, while others
	; are completely different (ie: Team Sacred Treasure's ending).
	;
	; Every special team triggers a bonus 1 vs 2 / 2 vs 1 fight, which is the
	; only time teams can be made of two characters.
	;
	
	; A = Speciala Team ID
	call Win_GetSpecTeamId
	; Depending on that...
	cp   TEAM_ID_SACTREAS
	jp   z, .teamSacTre
	cp   TEAM_ID_OLEONA
	jp   z, .teamOLeona
	cp   TEAM_ID_FFGEESE
	jp   z, .teamFFGeese
	cp   TEAM_ID_AOFMRBIG
	jp   z, .teamAOFMrBig
	cp   TEAM_ID_KTR
	jp   z, .teamKTR
	cp   TEAM_ID_BOSS
	jp   z, .teamBoss
.noSpec:
	; Generic ending with no extra scenes
	ld   b, BANK(SubModule_Ending_Generic) ; BANK $1D
	ld   hl, SubModule_Ending_Generic
	rst  $08
IF REV_VER_2 == 1
	; The generic ending in the English version starts the credits theme already,
	; so don't start playing anything alse.
	ld   d, $00
ENDC
	jp   Win_Credits
.teamSacTre:
	; Unique ending #1
	ld   b, BANK(SubModule_Ending_SacredTreasures) ; BANK $1D
	ld   hl, SubModule_Ending_SacredTreasures
	rst  $08
	jp   .setBonusFight
.teamOLeona:
	; Unique ending #2
	ld   b, BANK(SubModule_Ending_OLeona) ; BANK $1D
	ld   hl, SubModule_Ending_OLeona
	rst  $08
	jp   .setBonusFight
.teamFFGeese:
	ld   b, BANK(SubModule_Ending_Generic) ; BANK $1D
	ld   hl, SubModule_Ending_Generic
	rst  $08
	ld   b, BANK(SubModule_EndingPost_FFGeese) ; BANK $1D
	ld   hl, SubModule_EndingPost_FFGeese
	rst  $08
	jp   .setBonusFight
.teamAOFMrBig:
	ld   b, BANK(SubModule_Ending_Generic) ; BANK $1D
	ld   hl, SubModule_Ending_Generic
	rst  $08
	ld   b, BANK(SubModule_EndingPost_AOFMrBig) ; BANK $1D
	ld   hl, SubModule_EndingPost_AOFMrBig
	rst  $08
	jp   .setBonusFight
.teamKTR:
	ld   b, BANK(SubModule_Ending_Generic) ; BANK $1D
	ld   hl, SubModule_Ending_Generic
	rst  $08
	ld   b, BANK(SubModule_EndingPost_KTR) ; BANK $1D
	ld   hl, SubModule_EndingPost_KTR
	rst  $08
	jp   .setBonusFight
.teamBoss:
	ld   b, BANK(SubModule_Ending_Generic) ; BANK $1D
	ld   hl, SubModule_Ending_Generic
	rst  $08
	ld   b, BANK(SubModule_EndingPost_Boss) ; BANK $1D
	ld   hl, SubModule_EndingPost_Boss
	rst  $08
	jp   .setBonusFight
.setBonusFight:

	; Set up team members for bonus fight
	ld   a, [wBonusFightId]
	call Win_InitBonusFightTeams
	
	; Switch to bonus stage from the Goenitz one
	ld   a, STAGESEQ_BONUS
	ld   [wCharSeqId], a
	
	; Switch to order select screen.
	; We only get here from Team Mode, so we can call this directly.
	call Pl_InitBeforeStageLoad
	ld   b, BANK(Module_OrdSel) ; BANK $1E
	ld   hl, Module_OrdSel
	rst  $00
	
; =============== Win_CreditsStub ===============
; Wrapper for Win_Credits called when defeating the bonus opponent.
Win_CreditsStub:
IF REV_VER_2 == 1
	; The bonus opponents use their own music, so starts the credits theme
	ld   d, $01
ENDC
	jp   Win_Credits
	
; =============== Win_MrKarateDefeatCutscene ===============
; Displays the cutscene for defeating Mr.Karate.
; This is a congratulatory speech that also tells how to unlock him.
Win_MrKarateDefeatCutscene:
	ld   b, BANK(SubModule_CutsceneMrKarateDefeat) ; BANK $1D
	ld   hl, SubModule_CutsceneMrKarateDefeat
	rst  $08
	
	; Reset!
	ld   b, BANK(Module_TakaraLogo) ; BANK $0A
	ld   hl, Module_TakaraLogo
	rst  $00
	
; =============== Win_Credits ===============
; Displays the credits.
; This isn't called on EASY difficulties, to not give away the cheats. (it just calls the submodules)
Win_Credits:
	; Display the main credits
	ld   b, BANK(SubModule_Credits) ; BANK $1D
	ld   hl, SubModule_Credits
	rst  $08
	
	; THE END
	ld   b, BANK(SubModule_TheEnd) ; BANK $1D
	ld   hl, SubModule_TheEnd
	rst  $08
	
	;
	; On HARD mode, there's an extra Mr.Karate fight on hard difficulty.
	;
	ld   a, [wDifficulty]
	cp   DIFFICULTY_HARD	; Playing on HARD?
	jp   nz, .showCheats	; If not, jump
	
	; Display intro cutscene
	ld   b, BANK(SubModule_CutsceneMrKarate); BANK $1D
	ld   hl, SubModule_CutsceneMrKarate
	rst  $08
	
	; Set next stage
	ld   a, STAGESEQ_MRKARATE
	ld   [wCharSeqId], a
	
	; Set opponent team
	ld   bc, $0000
	call Win_SetSpecRoundChar
	
	; Start gameplay, completely skipping the Order Select screen even in Team Mode.
	call Pl_InitBeforeStageLoad
	jp   Module_Play
	
.showCheats:
	;
	; On NORMAL mode, display codes for the TAKARA logo.
	;
	ld   b, BANK(SubModule_CutsceneCheat); BANK $1D
	ld   hl, SubModule_CutsceneCheat
	rst  $08
	
	; Reset!
	ld   b, BANK(Module_TakaraLogo) ; BANK $0A
	ld   hl, Module_TakaraLogo
	rst  $00
	
; =============== Win_Unused_TheEnd ===============
; [TCRF] Unreferenced code showing "THE END", then resetting the game.
Win_Unused_TheEnd:
	ld   b, BANK(SubModule_TheEnd) ; BANK $1D
	ld   hl, SubModule_TheEnd
	rst  $08
	
	; Reset!
	ld   b, BANK(Module_TakaraLogo) ; BANK $0A
	ld   hl, Module_TakaraLogo
	rst  $00

; =============== Win_GetSpecTeamId ===============
; Checks if the team used is eligible for a special ending.
; OUT
; - A: Special Team ID (TEAM_ID_*)
; - wBonusFightId: Bonus Fight ID (BONUS_ID_*)
;                  Every special team has at least one bonus fight assigned to it,
;                  so this will be filled if a valid special team is set.
Win_GetSpecTeamId:
	; Not applicable outside of team mode, as 3 characters are required.
	ld   a, [wPlayMode]
	bit  MODEB_TEAM, a
	jp   z, .none
	
	; Seek to the team of the active wPlInfo
	ld   a, [wJoyActivePl]
	or   a				; Playing on the 1P side?
	jp   nz, .tm2P		; If not, jump
.tm1P:
	ld   hl, wPlInfo_Pl1+iPlInfo_TeamCharId0
	ld   a, [wPlInfo_Pl1+iPlInfo_CharId]
	jp   .mkList
.tm2P:
	ld   hl, wPlInfo_Pl2+iPlInfo_TeamCharId0
	ld   a, [wPlInfo_Pl2+iPlInfo_CharId]
	

	; Generate ordered CHAR_ID_* list
.mkList:
	ld   b, a
	call Win_MakeSortedCharIdList
	
	
	;
	; Check special character combinations one by one.
	; The first one that matches returns a team ID.
	; Each of these Win_IsSpecTeam* also sets the bonus fight id.
	;
	
.chk1:
	call Win_IsSpecTeamSacTre			; Playing as spec. team #1?
	jr   nc, .chk2						; If not, check the next one
	ld   a, TEAM_ID_SACTREAS	; Otherwise, return this group id
	jp   .ret
.chk2:
	call Win_IsSpecTeamOLeona			; ...
	jr   nc, .chk3
	ld   a, TEAM_ID_OLEONA
	jp   .ret
.chk3:
	call Win_IsSpecTeamFFGeese
	jr   nc, .chk4
	ld   a, TEAM_ID_FFGEESE
	jp   .ret
.chk4:
	call Win_IsSpecTeamAOFMrBig
	jr   nc, .chk5
	ld   a, TEAM_ID_AOFMRBIG
	jp   .ret
.chk5:
	call Win_IsSpecTeamKTR
	jr   nc, .chk6
	ld   a, TEAM_ID_KTR
	jp   .ret
.chk6:
	call Win_IsSpecTeamBoss
	jr   nc, .none
	ld   a, TEAM_ID_BOSS
	jp   .ret
.ret:
	ret
.none:
	; No special team found, or not in team mode.
	ld   a, BONUS_ID_NONE
	ld   [wBonusFightId], a
	ret
	
; =============== Win_MakeSortedCharIdList ===============
; Generates a sorted list of team members from the specified wPlInfo, ordered by ID in ascending order.
; This must be done before starting the checks to determine the value for wBonusFightId,
; as the character ID checks are made on this list. 
; IN
; - HL: Ptr to active iPlInfo_TeamCharId0 (source)
Win_MakeSortedCharIdList:
	push bc
	
		;
		; First, perform a direct copy of the table from the wPlInfo to wSpecTeamActiveCharId*
		;
		ld   de, wSpecTeamActiveCharId0	; DE = Destination
		ld   b, $03						; B = Bytes to copy (3 team members)
	.loop:
		ldi  a, [hl]	; Read from iPlInfo_TeamCharId*, seek to next
		ld   [de], a	; Write to wSpecTeamActiveCharId0
		inc  de			; Seek to next dest. entry
		dec  b			; Done copying?
		jr   nz, .loop	; If not, loop
		
		;
		; Then, sort the IDs from lowest to highest.
		;
		; This is done by comparing all of the unique combinations
		; of the slots, and switching them around when the one on
		; the left is > than the one on the right.
		;
		; The sorting is done to simplify the character ID checks, as they
		; guarantee that, for any given special team, the character IDs will
		; be in specific slots. (only need to check 3 slots instead of 3*3)
		;
		
		; HL = DE = Ptr to Slot0
		ld   hl, wSpecTeamActiveCharId0
		push hl
		pop  de
		
		; Since there are three slots, there are three unique combinations, as seen below.
		
		; Compare Slot0 with Slot1
		inc  de				; Seek DE to Slot1
		call .sortOrder
		; Compare Slot0 with Slot2
		inc  de				; Seek DE to Slot2
		call .sortOrder
		; Compare Slot1 with Slot2
		inc  hl				; Seek HL to Slot1
		call .sortOrder
	pop  bc
	ret
	
; =============== .sortOrder ===============
; Helper function to switch two wSpecTeamActiveCharId* slots depending on their order.
; If Id1 > Id2, the slots are switched.
; IN
; - HL: "SlotA". Ptr to a wSpecTeamActiveCharId* slot.
; - DE: "SlotB". Ptr to a later wSpecTeamActiveCharId* slot.
.sortOrder:
	ld   a, [de]	; A = Id2 from SlotB
	ld   b, [hl]	; B = Id1 from SlotA
	cp   a, b		; Id2 >= Id1?
	jr   nc, .ret	; If so, return
	; Otherwise, Id2 < Id1.
	; Switch the slots for A and B to fix that.
	ld   [hl], a	; SlotA = Id2
	ld   a, b
	ld   [de], a	; SlotB = Id1
.ret:
	ret

; =============== mWinIsSpecTeam ===============
; Generates code to check if we're playing with a specific special team.
;
; To have a special team set, the player team must have all three specified characters.
; If checks pass, then the bonus fight type is determined.
;
; The fight type depends on the current team lead character (the one who defeated Goenitz).
; Fights can check for either one or two lead characters:
; - In the case of 1, it's for fights that pit two characters against one.
;   (ie: Kyo and Chizuru vs O.Iori, and the other way around) (2 fights assigned)
; - In the case of 2, every character always fights two other ones.
;   (ie: Kyo vs Terry and Ryo, but *not* the other way around) (3 fights assigned)
;
; Note that the IDs passed to this macro must be sorted from lowest to highest,
; to go with the sorting order of wSpecTeamActiveCharId*.
;
; IN (2 VS 1)
; - 1: Fight ID (without lead character matching)
; - 2: Fight ID (when the lead character matches)
; - 3: Lead character ID
; - 4: Character ID 1
; - 5: Character ID 2
; - 6: Character ID 3
; - B: Current lead character (active team member)
; IN (1 VS 1 VS 1)
; - 1: Fight ID (when the lead character 1 matches)
; - 2: Fight ID (when the lead character 2 matches)
; - 3: Fight ID (when the lead character 3 matches)
; - 4: Lead character ID 1
; - 5: Lead character ID 2
; - 6: Character ID 1
; - 7: Character ID 2
; - 8: Character ID 3
; - B: Current lead character (active team member)
; OUT
; - C flag: If set, we're using that special team.
; - wBonusFightId: Set to the bonus team ID when C is set.
mWinIsSpecTeam: MACRO

IF _NARG < 7
	;
	; 2 VS 1 VARIANT
	;

	; Check if all three characters match. If any check fails, return.
	ld   hl, wSpecTeamActiveCharId0	; Seek to first entry to check
	ldi  a, [hl]		
	cp   \4				; wSpecTeamActiveCharId0 != CharId1?
	jr   nz, .retNone	; If so, return
	ldi  a, [hl]
	cp   \5				; wSpecTeamActiveCharId1 != CharId2?
	jr   nz, .retNone	; If so, return
	ldi  a, [hl]
	cp   \6				; wSpecTeamActiveCharId2 != CharId3?
	jr   nz, .retNone	; If so, return
	
	; Determine the bonus fight type, depending on who the current active character is.
	ld   a, b			; A = CurLeadCharId
	cp   \3				; A != LeadCharId?
	jr   nz, .noLead	; If so, jump
.leadMatch:
	ld   a, \2			; Lead character matches
	jr   .retOk
.noLead:
	ld   a, \1			; Lead character didn't match
	jr   .retOk
.retOk:
	ld   [wBonusFightId], a	; Save fight ID
	scf					; C flag set (can use wBonusFightId)
	ret
.retNone:
	xor  a	; C flag clear
	ret
ELSE
	;
	; 1 VS 1 VS 1 VARIANT
	;
	
	; Check if all three characters match. If any check fails, return.
	ld   hl, wSpecTeamActiveCharId0	; Seek to first entry to check
	ldi  a, [hl]		
	cp   \6				; wSpecTeamActiveCharId0 != CharId1?
	jr   nz, .retNone	; If so, return
	ldi  a, [hl]
	cp   \7				; wSpecTeamActiveCharId1 != CharId2?
	jr   nz, .retNone	; If so, return
	ldi  a, [hl]
	cp   \8				; wSpecTeamActiveCharId2 != CharId3?
	jr   nz, .retNone	; If so, return
	
	; Determine the bonus fight type, depending on who the current active character is.
	ld   a, b			; A = CurLeadCharId
	cp   a, \4			; A == LeadCharId1?
	jr   z, .leadMatch1	; If so, jump
	cp   a, \5			; A == LeadCharId2?
	jr   z, .leadMatch2	; If so, jump
.leadMatch3:			; Otherwise, it's the third character
	ld   a, \3			; Lead character 3 matches
	jr   .retOk
.leadMatch2:
	ld   a, \2			; Lead character 2 matches
	jr   .retOk
.leadMatch1:
	ld   a, \1			; Lead character 1 matches
	jr   .retOk
.retOk:
	ld   [wBonusFightId], a	; Save fight ID
	scf 				 ; C flag set (can use wBonusFightId)
	ret  
.retNone:
	xor  a	; C flag clear
	ret
ENDC
ENDM
	                                                       
; BONUS FIGHT DEF (2 VS 1)           |            FIGHT |   FIGHT W/ LEAD |                     LEAD CHAR ID |                     CHAR ID 1 |     CHAR ID 2 |       CHAR ID 3     
Win_IsSpecTeamSacTre:   mWinIsSpecTeam     BONUS_ID_KC_I,    BONUS_ID_I_KC,                      CHAR_ID_IORI,                    CHAR_ID_KYO,   CHAR_ID_IORI, CHAR_ID_CHIZURU
Win_IsSpecTeamOLeona:   mWinIsSpecTeam     BONUS_ID_IM_L,    BONUS_ID_L_IM,                     CHAR_ID_LEONA,                  CHAR_ID_LEONA,   CHAR_ID_IORI,  CHAR_ID_MATURE
Win_IsSpecTeamFFGeese:  mWinIsSpecTeam     BONUS_ID_TA_G,    BONUS_ID_G_TA,                     CHAR_ID_GEESE,                  CHAR_ID_TERRY,   CHAR_ID_ANDY,   CHAR_ID_GEESE
Win_IsSpecTeamAOFMrBig: mWinIsSpecTeam     BONUS_ID_RR_B,    BONUS_ID_B_RR,                     CHAR_ID_MRBIG,                    CHAR_ID_RYO, CHAR_ID_ROBERT,   CHAR_ID_MRBIG
; BONUS FIGHT DEF (1 VS 1 VS 1)      |  FIGHT W/ LEAD 1 | FIGHT W/ LEAD 2 | FIGHT W/ LEAD 3 | LEAD CHAR ID 1 | LEAD CHAR ID 2 |    CHAR ID 1 |      CHAR ID 2 |      CHAR ID 3     
Win_IsSpecTeamKTR:      mWinIsSpecTeam     BONUS_ID_K_TR,    BONUS_ID_T_KR,    BONUS_ID_R_KT,     CHAR_ID_KYO,   CHAR_ID_TERRY,   CHAR_ID_KYO,   CHAR_ID_TERRY,    CHAR_ID_RYO
Win_IsSpecTeamBoss:     mWinIsSpecTeam     BONUS_ID_G_KB,    BONUS_ID_K_GB,    BONUS_ID_B_GK,   CHAR_ID_GEESE, CHAR_ID_KRAUSER, CHAR_ID_GEESE, CHAR_ID_KRAUSER,  CHAR_ID_MRBIG


; =============== Win_InitBonusFightTeams ===============
; Sets up the teams for the specified bonus fight.
; IN
; - A: Bonus Fight ID
Win_InitBonusFightTeams:
	;
	; Get the destination ptrs
	; HL = Ptr to active player character ID
	; DE = Ptr to CPU opponent character ID
	;
	push af
		ld   a, [wJoyActivePl]
		or   a				; Playing on the 1P side?
		jp   nz, .d2P	; If not, jump
	.d1P:
		ld   hl, wPlInfo_Pl1+iPlInfo_CharId
		ld   de, wPlInfo_Pl2+iPlInfo_CharId
		jp   .setChars
	.d2P:
		ld   hl, wPlInfo_Pl2+iPlInfo_CharId
		ld   de, wPlInfo_Pl1+iPlInfo_CharId
	.setChars:
	pop  af
	
	;
	; Index the entry from the table of bonus fight definitions. (source)
	; Each entry is 8 bytes long, and it contains character IDs.
	;
	
	push hl	; Save active charId ptr
		ld   hl, Win_BonusFightTbl	; HL = Table base
		ld   b, $00					; BC = A * 8
		sla  a
		sla  a
		sla  a
		ld   c, a
		add  hl, bc					; Offset it
	pop  bc	; BC = Ptr to active player character ID
	
	;
	; Copy its data over
	;
	
	;--
	; Player Team
	
	ldi  a, [hl]	; Read from byte0, SrcPtr++
	ld   [bc], a	; Copy to player iPlInfo_CharId
	inc  bc			; Seek to iPlInfo_TeamLossCount
	inc  bc			; Seek to iPlInfo_TeamCharId0
	
	; For some reason, this is a separate value even though it has to be always the same
	ldi  a, [hl]	; Read from byte1, SrcPtr++
	ld   [bc], a	; Copy to player iPlInfo_TeamCharId0
	
	inc  bc			; Seek to iPlInfo_TeamCharId1
	ldi  a, [hl]	; Read from byte2, SrcPtr++
	ld   [bc], a	; Copy to player iPlInfo_TeamCharId1
	inc  bc			; Seek to iPlInfo_TeamCharId2
	ldi  a, [hl]	; Read from byte3, SrcPtr++
	ld   [bc], a	; Copy to player iPlInfo_TeamCharId2
	
	;--
	; CPU Opponent Team
	
	ldi  a, [hl]	; Read from byte4, SrcPtr++
	ld   [de], a	; Copy to opponent iPlInfo_CharId
	inc  de			; Seek to iPlInfo_TeamLossCount
	inc  de			; Seek to iPlInfo_TeamCharId0
	
	; For some reason, this is a separate value even though it has to be always the same
	ldi  a, [hl]	; Read from byte5, SrcPtr++
	ld   [de], a	; Copy to opponent iPlInfo_TeamCharId0
	
	inc  de			; Seek to iPlInfo_TeamCharId1
	ldi  a, [hl]	; Read from byte6, SrcPtr++
	ld   [de], a	; Copy to opponent iPlInfo_TeamCharId1
	inc  de			; Seek to iPlInfo_TeamCharId2
	ldi  a, [hl]	; Read from byte7, SrcPtr++
	ld   [de], a	; Copy to opponent iPlInfo_TeamCharId2
	ret
	
; =============== Win_BonusFightTbl ===============
; Team definitions for bonus fights (STAGESEQ_BONUS).
Win_BonusFightTbl:
	; PLAYER SIDE                                                        | OPPONENT SIDE
	;        CUR CHAR |    TEAM CHAR 1 |    TEAM CHAR 2 |    TEAM CHAR 3 |       CUR CHAR |    TEAM CHAR 1 |    TEAM CHAR 2 |     TEAM CHAR 3 |      BONUS ID
	db   CHAR_ID_OIORI,   CHAR_ID_OIORI,    CHAR_ID_NONE,    CHAR_ID_NONE,     CHAR_ID_KYO,     CHAR_ID_KYO, CHAR_ID_CHIZURU,    CHAR_ID_NONE ; BONUS_ID_I_KC
	db     CHAR_ID_KYO,     CHAR_ID_KYO, CHAR_ID_CHIZURU,    CHAR_ID_NONE,   CHAR_ID_OIORI,   CHAR_ID_OIORI,    CHAR_ID_NONE,    CHAR_ID_NONE ; BONUS_ID_KC_I
	db  CHAR_ID_OLEONA,  CHAR_ID_OLEONA,    CHAR_ID_NONE,    CHAR_ID_NONE,    CHAR_ID_IORI,    CHAR_ID_IORI,  CHAR_ID_MATURE,    CHAR_ID_NONE ; BONUS_ID_L_IM
	db    CHAR_ID_IORI,    CHAR_ID_IORI,  CHAR_ID_MATURE,    CHAR_ID_NONE,  CHAR_ID_OLEONA,  CHAR_ID_OLEONA,    CHAR_ID_NONE,    CHAR_ID_NONE ; BONUS_ID_IM_L
	db   CHAR_ID_TERRY,   CHAR_ID_TERRY,    CHAR_ID_ANDY,    CHAR_ID_NONE,   CHAR_ID_GEESE,   CHAR_ID_GEESE,    CHAR_ID_NONE,    CHAR_ID_NONE ; BONUS_ID_TA_G
	db   CHAR_ID_GEESE,   CHAR_ID_GEESE,    CHAR_ID_NONE,    CHAR_ID_NONE,   CHAR_ID_TERRY,   CHAR_ID_TERRY,    CHAR_ID_ANDY,    CHAR_ID_NONE ; BONUS_ID_G_TA
	db     CHAR_ID_RYO,     CHAR_ID_RYO,  CHAR_ID_ROBERT,    CHAR_ID_NONE,   CHAR_ID_MRBIG,   CHAR_ID_MRBIG,    CHAR_ID_NONE,    CHAR_ID_NONE ; BONUS_ID_RR_B
	db   CHAR_ID_MRBIG,   CHAR_ID_MRBIG,    CHAR_ID_NONE,    CHAR_ID_NONE,     CHAR_ID_RYO,     CHAR_ID_RYO,  CHAR_ID_ROBERT,    CHAR_ID_NONE ; BONUS_ID_B_RR
	db     CHAR_ID_KYO,     CHAR_ID_KYO,    CHAR_ID_NONE,    CHAR_ID_NONE,   CHAR_ID_TERRY,   CHAR_ID_TERRY,     CHAR_ID_RYO,    CHAR_ID_NONE ; BONUS_ID_K_TR
	db   CHAR_ID_TERRY,   CHAR_ID_TERRY,    CHAR_ID_NONE,    CHAR_ID_NONE,     CHAR_ID_KYO,     CHAR_ID_KYO,     CHAR_ID_RYO,    CHAR_ID_NONE ; BONUS_ID_T_KR
	db     CHAR_ID_RYO,     CHAR_ID_RYO,    CHAR_ID_NONE,    CHAR_ID_NONE,     CHAR_ID_KYO,     CHAR_ID_KYO,   CHAR_ID_TERRY,    CHAR_ID_NONE ; BONUS_ID_R_KT
	db   CHAR_ID_GEESE,   CHAR_ID_GEESE,    CHAR_ID_NONE,    CHAR_ID_NONE, CHAR_ID_KRAUSER, CHAR_ID_KRAUSER,   CHAR_ID_MRBIG,    CHAR_ID_NONE ; BONUS_ID_G_KB
	db CHAR_ID_KRAUSER, CHAR_ID_KRAUSER,    CHAR_ID_NONE,    CHAR_ID_NONE,   CHAR_ID_GEESE,   CHAR_ID_GEESE,   CHAR_ID_MRBIG,    CHAR_ID_NONE ; BONUS_ID_K_GB
	db   CHAR_ID_MRBIG,   CHAR_ID_MRBIG,    CHAR_ID_NONE,    CHAR_ID_NONE,   CHAR_ID_GEESE,   CHAR_ID_GEESE, CHAR_ID_KRAUSER,    CHAR_ID_NONE ; BONUS_ID_B_GK
	
; =============== Win_SetSpecRoundChar ===============
; Sets the CPU opponent character to fight for the new boss/extra stage.
; This should not be used for the bonus fight (STAGESEQ_BONUS), since it uses a special team definition.
Win_SetSpecRoundChar:
	;
	; Read out the character ID off the current wCharSeqTbl entry.
	; This subroutine is expected to be called only for boss/extra rounds, 
	; as those are the only rounds that contain straight CHAR_ID_* entries
	; compared to the normal CHARSEL_ID_*.
	;
	ld   a, [wCharSeqId]	; A = Stage sequence ID
	ld   hl, wCharSeqTbl	; HL = Sequence table
	ld   d, $00				; DE = A
	ld   e, a
	add  hl, de				; Index it
	ld   a, [hl]			; Read out character ID

	; These entries are one of the very few times the game stores character IDs
	; without having them already multiplied by two.
	; So we've got to do it manually.
	sla  a					; A * = 2
	
	;
	; Update the team members for the inactive side/CPU opponent side.
	; All of the boss/extra rounds make you fight one CPU opponent at most,
	; so A gets written into the first slot, and the other two get CHAR_ID_NONE.
	;
	push af
		; Determine the inactive side
		ld   a, [wJoyActivePl]
		or   a				; wJoyActivePl == PL1? (Playing as 1P?)
		jp   nz, .op1P		; If not, jump (Playing as 2P)
	.op2P:
		; Playing as 1P, CPU is 2P
		ld   hl, wPlInfo_Pl2+iPlInfo_TeamCharId0
		ld   de, wPlInfo_Pl2+iPlInfo_CharId
		jp   .setChar
	.op1P:
		; Playing as 2P, CPU is 1P
		ld   hl, wPlInfo_Pl1+iPlInfo_TeamCharId0
		ld   de, wPlInfo_Pl1+iPlInfo_CharId
	.setChar:
		; Write the character ID to the current character slot + first team member
	pop  af		; A = CHAR_ID_*
	
	ld   [de], a	; Save it to iPlInfo_CharId
	ldi  [hl], a	; Save it to iPlInfo_TeamCharId0, seek to next
	; Clear out the other two team members
	ld   a, CHAR_ID_NONE
	ldi  [hl], a	; Save it to iPlInfo_TeamCharId1, seek to next
	ld   [hl], a	; Save it to iPlInfo_TeamCharId2
	ret
	
; =============== Win_Mode_SingleLost ===============
; Lost a round on Single Mode by having the opponent win.
Win_Mode_SingleLost:
	; Losing the bonus fights doesn't affect anything.
	ld   a, [wCharSeqId]
	cp   STAGESEQ_BONUS			; Did we lose to the bonus opponent or Mr.Karate?
	jp   nc, Win_Mode_SingleWon	; If so, pretend we won anyway
	
	; Display the opponent team's win animation
	call Win_DoWinScr
	
	;
	; INITIALIZE CONTINUE SCREEN
	;
	
	;-----------------------------------
	rst  $10				; Stop LCD
	
	; Black out palette
	ld   a, $FF
	ldh  [rBGP], a
	
	; Hide opponent team off-screen
	ld   a, $80
	ldh  [hScrollY], a
	
	; Load standard font
	call LoadGFX_1bppFont_Default
	
	; Delete opponent team tilemap
	call ClearBGMap
	
	; Load SGB palette
	ld   de, SCRPAL_INTRO
	call HomeCall_SGB_ApplyScreenPalSet
	
	; Display "CONTINUE 9" text
	ld   hl, TextDef_Continue
	call TextPrinter_Instant
	
	; Init continue timer
	ld   a, $09					; 9 seconds
	ld   [wWinContinueTimer], a
	ld   a, 60					; Decrement after 60 frames
	ld   [wWinContinueTimerSub], a
	
	; Set real text palette
	ld   a, $1B
	ldh  [rBGP], a
	
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_OBJSIZE|LCDC_WTILEMAP|LCDC_ENABLE
	rst  $18				; Resume LCD
	;-----------------------------------
	
	jp   Win_Continue

; =============== Win_Mode_SingleDraw ===============
; Lost a round on Single Mode by ending the stage on a DRAW.
; Note that, by the time we get here, "DRAW" should already be in the tilemap.
Win_Mode_SingleDraw:
	; Music kills itself in shame
	ld   a, SND_MUTE
	call HomeCall_Sound_ReqPlayExId_Stub
	
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_OBJSIZE|LCDC_WTILEMAP|LCDC_ENABLE
	rst  $18				; Resume LCD
	;-----------------------------------
	call Task_PassControl_NoDelay
	; Enable palette
	ld   a, $1B
	ldh  [rBGP], a
.wait:
	call Win_IdleWaitLong
	jp   c, .toContinue
	;--
	; [TCRF] C is always set, so we never get here.
	;        Seems like pressing START would have reset the wait timer.
	;        See also: other instances of Win_IdleWaitLong calls.
	call Task_PassControl_NoDelay
	jp   .wait
	;--
.toContinue:
	; Losing the bonus fights doesn't affect anything.
	ld   a, [wCharSeqId]
	cp   STAGESEQ_BONUS			; Did we lose to the bonus opponent or Mr.Karate?
	jp   nc, Win_StartNextStage	; If so, pretend we won anyway
	
	;
	; INITIALIZE CONTINUE SCREEN
	;
	
	;-----------------------------------
	rst  $10				; Stop LCD
	
	; Black out palette
	ld   a, $FF
	ldh  [rBGP], a
	
	; Hide opponent team off-screen
	ld   a, $80
	ldh  [hScrollY], a
	
	; Load standard font
	call LoadGFX_1bppFont_Default
	
	; Delete opponent team tilemap
	call ClearBGMap
	
	; Load SGB palette
	ld   de, SCRPAL_INTRO
	call HomeCall_SGB_ApplyScreenPalSet
	
	; Display "CONTINUE 9" text
	ld   hl, TextDef_Continue
	call TextPrinter_Instant
	
	; Init continue timer
	ld   a, $09					; 9 seconds
	ld   [wWinContinueTimer], a
	ld   a, 60					; Decrement after 60 frames
	ld   [wWinContinueTimerSub], a
	
	; Set real text palette
	ld   a, $1B
	ldh  [rBGP], a
	
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_OBJSIZE|LCDC_WTILEMAP|LCDC_ENABLE
	rst  $18				; Resume LCD
	;-----------------------------------
	
	jp   Win_Continue
; =============== Win_Mode_SingleDraw ===============
; Lost in VS mode by ending the stage on a DRAW.
; Note that, by the time we get here, "DRAW" should already be in the tilemap.
Win_Mode_VSDraw:
	; Music kills itself in shame
	ld   a, SND_MUTE
	call HomeCall_Sound_ReqPlayExId_Stub
	
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_OBJSIZE|LCDC_WTILEMAP|LCDC_ENABLE
	rst  $18				; Resume LCD
	;-----------------------------------
	call Task_PassControl_NoDelay
	; Enable palette
	ld   a, $1B
	ldh  [rBGP], a
.wait:
	call Win_IdleWaitLong
	jp   c, .toCharSel
	;--
	; [TCRF] We never get here
	call Task_PassControl_NoDelay
	jp   .wait
	;--
	; [TCRF] Unreferenced code
.unused_resetChar:
	call Win_ResetCharsOnEndlessCpuVsCpu
	;--
.toCharSel:
	jp   Win_SwitchToCharSel
	
; =============== Win_ResetCharsOnEndlessCpuVsCpu ===============
; In an endless CPU vs CPU battle, force the game to pick new characters for both teams.
Win_ResetCharsOnEndlessCpuVsCpu:

	;
	; Not applicable if we aren't in endless CPU vs CPU mode.
	; This is a special case for CPU vs CPU battles done in VS mode.
	;
	
	; Must be in VS mode
	ld   a, [wPlayMode]
	bit  MODEB_VS, a
	ret  z
	
	; Must be two CPUs
	ld   a, [wPlInfo_Pl1+iPlInfo_Flags0]
	ld   b, a								; B = 1P Flags
	ld   a, [wPlInfo_Pl2+iPlInfo_Flags0]	; A = 2P Flags
	and  b									; Merge both
	bit  PF0B_CPU, a						; Are both players CPUs?
	ret  z									; If not, return
	
	;
	; Clear selected team characters
	;
	ld   a, $FF
	ld   [wCharSelP1Char0], a
	ld   [wCharSelP1Char1], a
	ld   [wCharSelP1Char2], a
	ld   [wCharSelP2Char0], a
	ld   [wCharSelP2Char1], a
	ld   [wCharSelP2Char2], a
	ret 
	
; =============== Win_Continue ===============
; Handles the Continue screen.
Win_Continue:
	call Task_PassControl_NoDelay
.loop:
	; Pressing START returns to the character select.
	call Win_IsStartPressed
	jp   c, .toCharSel
	
.decSubSec:
	; Decrement the subsecond timer
	ld   a, [wWinContinueTimerSub]
	or   a				; TimerSub == 0?
	jp   z, .decSec		; If so, jump
	dec  a				; Otherwise, TimerSub--
	ld   [wWinContinueTimerSub], a
	call Task_PassControl_NoDelay
	jp   .loop
.decSec:
	; Reset subtimer to 60 frames
	ld   a, 60
	ld   [wWinContinueTimerSub], a
	
	; Decrement second timer
	ld   a, [wWinContinueTimer]
	or   a				; Timer == 0?
	jp   z, .gameOver	; If so, jump
	dec  a				; Otherwise, Timer--
	ld   [wWinContinueTimer], a
	
	; Play sound when second ticks away
	ld   a, SFX_CURSORMOVE
	call HomeCall_Sound_ReqPlayExId
	
	;
	; Update tilemap with new number.
	; Because NumberPrinter_Instant writes two digits, after that
	; replace the leading 0 with a space.
	;
	ld   a, [wWinContinueTimer]
	ld   de, $9AED
	call NumberPrinter_Instant
	ld   hl, TextDef_ContinueNumSpace
	call TextPrinter_Instant
	
	call Task_PassControl_NoDelay
	jp   .loop
	
.gameOver:
	ld   a, SFX_GAMEOVER
	call HomeCall_Sound_ReqPlayExId
	
	ld   hl, TextDef_GameOver
	call TextPrinter_Instant
	jp   .toTitle
	
.toCharSel:
	;--
	; [TCRF] Mark that a continue was used. This is never read from.
	ld   a, $01
	ld   [wUnused_ContinueUsed], a
	;--
	jp   Win_SwitchToCharSel
	
.toTitle:
	call Win_IdleWaitLong
	jp   c, Win_SwitchToTitle
	; [TCRF] Unreachable code, Win_IdleWaitLong always returns C flag set.
	call Task_PassControl_NoDelay
	jp   .toTitle
; =============== Win_SwitchToTitle ===============
; Switches to the Title screen.
Win_SwitchToTitle:
	ld   b, BANK(Module_Title) ; BANK $1C
	ld   hl, Module_Title
	rst  $00
; =============== Win_SwitchToCharSel ===============
; Switches to the Character Select screen.
Win_SwitchToCharSel:
	ld   b, BANK(Module_CharSel) ; BANK $1E
	ld   hl, Module_CharSel
	rst  $00
; =============== Win_DoWinScr ===============
; Performs initialization of the Win Screen.
Win_DoWinScr:
	ld   b, BANK(SubModule_WinScr) ; BANK $1E
	ld   hl, SubModule_WinScr
	rst  $08
	ret
; =============== Win_Unused_IdleWaitShort ===============
; [TCRF] Unreferenced code.
; Waits for $F0 frames, or until someone presses START.
; OUT
; - C flag: Always set (leftover from WnScr_IdleWait)
Win_Unused_IdleWaitShort:
	ld   b, $F0			; B = Number of frames
.loop:
	; If any player presses START, the wait ends early
	ldh  a, [hJoyNewKeys]
	bit  KEYB_START, a
	jp   nz, .abort
	ldh  a, [hJoyNewKeys2]
	bit  KEYB_START, a
	jp   nz, .abort
	; Wait a frame
	call Task_PassControl_NoDelay
	dec  b				; Are we finished?
	jp   nz, .loop		; If not, loop
.abort:
	scf  
	ret
	
; =============== Win_IdleWaitLong ===============
; Waits for $01E0 frames, or until someone presses START.
; OUT
; - C flag: Always set (leftover from WnScr_IdleWait)
Win_IdleWaitLong:
	ld   bc, $01E0			; BC = Number of frames
.loop:
	; If any player presses START, the wait ends early
	ldh  a, [hJoyNewKeys]
	bit  KEYB_START, a
	jp   nz, .abort
	ldh  a, [hJoyNewKeys2]
	bit  KEYB_START, a
	jp   nz, .abort
	; Wait a frame
	call Task_PassControl_NoDelay
	dec  bc			; FramesLeft--
	ld   a, b
	or   a, c		; B == 0 && C == 0?
	jp   nz, .loop	; If not, loop
	; Otherwise, we're done
.abort:
	scf
	ret
	
; =============== Win_IsStartPressed ===============
; Checks if any player pressed START.
; OUT
; - C flag: If set, someone did
Win_IsStartPressed:
	; If any player presses START, return set
	ldh  a, [hJoyNewKeys]
	bit  KEYB_START, a
	jp   nz, .abort
	ldh  a, [hJoyNewKeys2]
	bit  KEYB_START, a
	jp   nz, .abort
	; Otherwise, return clear
	xor  a
	ret
.abort:
	scf
	ret
	
; =============== Win_IncStageSeq ===============
; Increases the stage sequence id by the number of opponents in the stage.
;
; This also marks them as defeated, which allows CharSel_DrawCrossOnDefeatedChars
; to display crosses over defeated character icons
;
; Calling this allows the game to progress in Single Modes, and shouldn't be called in VS modes.
Win_IncStageSeq:
	;
	; Seek to the current slot in the stage sequence table.
	; DE = Ptr to current CHARSEL_ID_* entry in the opponent sequence table.
	;
	ld   hl, wCharSeqTbl	; HL = Sequence table
	ld   a, [wCharSeqId]	; A = RoundId
	add  a, l				; Index the table
	jp   nc, .noOvf			; (we never overflow L)
	inc  h
.noOvf:
	ld   l, a				; Save it back
	push hl					; Move ptr to DE
	pop  de
	
	; HL = Ptr to wCharSeqId
	; This will later be incremented for every opponent marked as defeated.
	ld   hl, wCharSeqId
	
	;
	; Determine by how much to increase the stage sequence id.
	;
	
	; There's only one opponent in the boss and extra rounds.
	ld   a, [wCharSeqId]	; A = RoundSeqId
	cp   STAGESEQ_KAGURA	; On KAGURA's stage?
	jp   z, .set1			; If so, jump
	cp   STAGESEQ_GOENITZ	; ...
	jp   z, .set1
	cp   STAGESEQ_BONUS
	jp   z, .set1
	cp   STAGESEQ_MRKARATE
	jp   z, .set1
	
	; Otherwise, if we're in team mode, there are three opponents, so the stage sequence
	; should increment by three.
	ld   b, $03				; B = Slots to mark
	ld   a, [wPlayMode]		
	bit  MODEB_TEAM, a		; Are we in team mode?
	jp   nz, .loop			; If so, skip
.set1:						; Otherwise, there's only one opponent in single modes.
	ld   b, $01				; B = Slots to mark
	
	;
	; Advance the stage progress B times.
	;
.loop:
	; Mark the opponent as defeated
	ld   a, [de]					; A = Slot
	set  CHARSEL_POSFB_DEFEATED, a	; Mark as defeated
	ld   [de], a					; Save it back
	inc  de							; Seek to next slot
	
	; Increment stage id
	inc  [hl]						; wCharSeqId++
	
	dec  b							; Are we done?
	jp   nz, .loop					; If not, loop
	ret
	
TextDef_Win_Draw:
	dw $9888
	db .end-.start
.start:
	db "DRAW"
.end:
TextDef_Continue:
	dw $9AE5
	db .end-.start
.start:
	db "CONTINUE 9"
.end:
TextDef_ContinueNumSpace:
	dw $9AED
	db .end-.start
.start:
	db " "
.end:
TextDef_GameOver:
	dw $9AE5
	db .end-.start
.start:
	db "GAME  OVER"
.end:

GFXLZ_Cutscene_StadiumBG: INCBIN "data/gfx/cutscene_stadiumbg.lzc"
BGLZ_Cutscene_StadiumBG: INCBIN "data/bg/cutscene_stadiumbg.lzs"
GFXLZ_Cutscene_Goenitz: INCBIN "data/gfx/cutscene_goenitz.lzc"
BGLZ_Cutscene_Goenitz: INCBIN "data/bg/cutscene_goenitz.lzs"
BGLZ_Cutscene_GoenitzDefeated: INCBIN "data/bg/cutscene_goenitzdefeated.lzs"
GFXLZ_Cutscene_GoenitzEscape: INCBIN "data/gfx/cutscene_goenitzescape.lzc"
BGLZ_Cutscene_GoenitzEscape: INCBIN "data/bg/cutscene_goenitzescape.lzs"
GFXLZ_Cutscene_Kagura: INCBIN "data/gfx/cutscene_kagura.lzc"

; =============== SubModule_CutsceneKagura ===============
; This submodule handles the cutscene before fighting Kagura.
SubModule_CutsceneKagura:
	call Cutscene_SharedInit
	call Cutscene_LoadKaguraOBJLst
	
	; Set screen sectors
	ld   a, $18		; Second sector starts here (BG)
	ld   b, $5C		; Text sector starts here (WINDOW)
	call SetSectLYC
	
	; Enable the LCD
	call Cutscene_ResumeLCDWithLYC
	
	; Initialize vars
	xor  a
	ld   [wCutMoveLargeChars], a
	ld   [wCutFlashTimer], a
	ei
	
	; Wait for next frame, to displaythe sectors
	call Task_PassControl_NoDelay
	
	; Set Kagura's OBJ palette
	ld   a, $6C
	ldh  [rOBP0], a
	
	; Set white palette for middle section BG
	xor  a
	ldh  [rBGP], a
	ldh  [rOBP1], a
	ldh  [hScreenSect1BGP], a
	
	; Set different palette for top and bottom section BG.
	; The font is black text on white background in the ROM, but on-screen it needs to be the other way around.
	ld   a, $13
	ldh  [hScreenSect0BGP], a
	ldh  [hScreenSect2BGP], a
	
	; Start cutscene music
	ld   a, BGM_PROTECTOR
	call HomeCall_Sound_ReqPlayExId_Stub
	
	;
	; TEXT PRINTING
	;
	
	; Don't execute custom code when writing lettters
	ld   a, TXB_NONE
	ld   [wTextPrintFrameCodeBank], a
	
	; Print out the screens of text one by one
IF REV_LANG_EN == 0
	ld   hl, TextC_CutsceneKagura0
	call Cutscene_WriteTextBank1C
	ld   hl, TextC_CutsceneKagura1
	call Cutscene_WriteTextBank1C
	ld   hl, TextC_CutsceneKagura2
	call Cutscene_WriteTextBank1C
	ld   hl, TextC_CutsceneKagura3
	call Cutscene_WriteTextBank1C
	ld   hl, TextC_CutsceneKagura4
	call Cutscene_WriteTextBank1C
ELSE
	ld   hl, TextC_CutsceneKagura0
	call Cutscene_WriteTextBank05
	ld   hl, TextC_CutsceneKagura1
	call Cutscene_WriteTextBank05
	ld   hl, TextC_CutsceneKagura2
	call Cutscene_WriteTextBank05
	ld   hl, TextC_CutsceneKagura3
	call Cutscene_WriteTextBank05
	ld   hl, TextC_CutsceneKagura4
	call Cutscene_WriteTextBank05
	ld   hl, TextC_CutsceneKagura5
	call Cutscene_WriteTextBank05
ENDC

	; Fall-through
	
; =============== Cutscene_End ===============
; Common code to end a cutscene.
Cutscene_End:

	; Clear tilemap
	call ClearBGMap
	
	; Hide Kagura sprite mapping
	ld   hl, wOBJInfo_Kagura+iOBJInfo_Status
	res  OSTB_VISIBLE, [hl]
	
	; Disable sections
	ld   hl, wMisc_C028
	res  MISCB_USE_SECT, [hl]
	xor  a
	ldh  [rSTAT], a
	
	; Reset DMG palette
	ld   a, $FF
	ldh  [rBGP], a
	ldh  [rOBP0], a
	ldh  [rOBP1], a
	ret
	
; =============== Cutscene_LoadKaguraOBJLst ===============
; Loads the sprite mapping for Kagura's cutscene sprite.
; The entire sprite has BG Priority set, to make it show up behind Goenitz.
Cutscene_LoadKaguraOBJLst:
	; Decompress/load the graphics to $8000
	ld   hl, GFXLZ_Cutscene_Kagura
	ld   de, wLZSS_Buffer+$10
	call DecompressLZSS
	ld   hl, wLZSS_Buffer+$10
	ld   de, Tiles_Begin
	ld   b, $28
	call CopyTiles
	
	; Load the sprite mapping from ROM.
	; As this is an unique sprite definition, the needed coordinates and flags are directly set in the OBJInfoInit.
	ld   hl, wOBJInfo_Kagura
	ld   de, OBJInfoInit_Cutscene_Kagura
	call OBJLstS_InitFrom
	
	; Initialize it
	ld   hl, wOBJInfo_Kagura
	jp   OBJLstS_DoAnimTiming_Initial

; =============== Cutscene_ResumeLCDWithLYC ===============
; Resumes LCD output and enables LYC, which is required for the section system.
Cutscene_ResumeLCDWithLYC:
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_OBJSIZE|LCDC_WENABLE|LCDC_WTILEMAP|LCDC_ENABLE
	rst  $18				; Resume LCD
	;-----------------------------------
	; Enable LYC
	ldh  a, [rSTAT]
	or   a, STAT_LYC
	ldh  [rSTAT], a
	ret
; =============== Cutscene_WriteText* ===============
; Set of subroutines to write a screen worth of text to the tilemap,
; letter by letter through TextPrinter_MultiFrameFarCustomPos.
;
; The text is written from the beginning of the second row of the WINDOW layer.
;
; The English version has significantly more of them, since text was spread
; around multiple banks to fit in the free space.
	
IF REV_LANG_EN == 0
; =============== Cutscene_WriteTextBank1C ===============
; Writes text from BANK $1C.
; IN
; - HL: Ptr to TextC structure. Must point to BANK $1C.
Cutscene_WriteTextBank1C:
	ld   b, $1C ; Bank
	call Cutscene_WriteText_Custom
	ld   b, $F0 ; Wait for $F0 frames
	jp   Cutscene_PostTextWrite
; =============== Cutscene_WriteTextBank1D ===============
; Writes text from BANK $1D.
; IN
; - HL: Ptr to TextC structure. Must point to BANK $1D.
Cutscene_WriteTextBank1D:
	ld   b, $1D
	call Cutscene_WriteText_Custom
	ld   b, $F0
	jp   Cutscene_PostTextWrite
; =============== Cutscene_WriteTextBank1CSFX ===============
; Writes text from BANK $1C, playing SFX for every char printed.
; IN
; - HL: Ptr to TextC structure. Must point to BANK $1C.
Cutscene_WriteTextBank1CSFX:
	ld   b, $1C
	call Cutscene_WriteText_CustomSFX
	ld   b, $F0
	jp   Cutscene_PostTextWrite
	
ELSE

; =============== Cutscene_WriteTextBank05 ===============
; IN
; - HL: Ptr to TextC structure. Must point to BANK $05.
Cutscene_WriteTextBank05:
	ld   b, $05
	jp   Cutscene_WriteTextNoSFX
; =============== Cutscene_WriteTextBank1C ===============
; IN
; - HL: Ptr to TextC structure. Must point to BANK $1C.
Cutscene_WriteTextBank1C:
	ld   b, $1C
	jp   Cutscene_WriteTextNoSFX
; =============== Cutscene_WriteTextBank09 ===============
; IN
; - HL: Ptr to TextC structure. Must point to BANK $09.
Cutscene_WriteTextBank09:
	ld   b, $09
	jp   Cutscene_WriteTextNoSFX
; =============== Cutscene_WriteTextBank1C_Copy ===============
; Unnecessary duplicate.
; IN
; - HL: Ptr to TextC structure. Must point to BANK $1C.
Cutscene_WriteTextBank1C_Copy:
	ld   b, $1C
	jp   Cutscene_WriteTextNoSFX
; =============== Cutscene_WriteTextBank08 ===============
; IN
; - HL: Ptr to TextC structure. Must point to BANK $08.
Cutscene_WriteTextBank08:
	ld   b, $08
	jp   Cutscene_WriteTextNoSFX
; =============== Cutscene_WriteTextBank1D ===============
; IN
; - HL: Ptr to TextC structure. Must point to BANK $1D.
Cutscene_WriteTextBank1D:
	ld   b, $1D
	jp   Cutscene_WriteTextNoSFX
; =============== Cutscene_WriteTextBank0A ===============
; IN
; - HL: Ptr to TextC structure. Must point to BANK $0A.
Cutscene_WriteTextBank0A:
	ld   b, $0A
	jp   Cutscene_WriteTextNoSFX
; =============== Cutscene_WriteTextBank1D_Copy ===============
; Unnecessary duplicate.
; IN
; - HL: Ptr to TextC structure. Must point to BANK $1D.
Cutscene_WriteTextBank1D_Copy:
	ld   b, $1D
	jp   Cutscene_WriteTextNoSFX
; =============== Cutscene_WriteTextBank03 ===============
; IN
; - HL: Ptr to TextC structure. Must point to BANK $03.
Cutscene_WriteTextBank03:
	ld   b, $03
	jp   Cutscene_WriteTextNoSFX
; =============== Cutscene_WriteTextBank04 ===============
; IN
; - HL: Ptr to TextC structure. Must point to BANK $04.
Cutscene_WriteTextBank04:
	ld   b, $04
	jp   Cutscene_WriteTextNoSFX
; =============== Cutscene_WriteTextBank07 ===============
; IN
; - HL: Ptr to TextC structure. Must point to BANK $07.
Cutscene_WriteTextBank07:
	ld   b, $07
	jp   Cutscene_WriteTextNoSFX
	
; =============== Cutscene_WriteTextBank1CSFX ===============
Cutscene_WriteTextBank06:
	ld   b, $06
	; Fall-through
	
; =============== Cutscene_WriteTextBank1CSFX ===============
; Writes text for the specified bank without playing SFX.
; IN
; - HL: Ptr to TextC structure
; - B: Bank number of TextDef structure
Cutscene_WriteTextNoSFX:
	call Cutscene_WriteText_Custom
	ld   b, $F0
	jp   Cutscene_PostTextWrite
	
; =============== Cutscene_WriteTextBank08SFX ===============
; Writes text from BANK $08, playing SFX for every char printed.
; IN
; - HL: Ptr to TextC structure. Must point to BANK $08.
Cutscene_WriteTextBank08SFX:
	ld   b, $08
	call Cutscene_WriteText_CustomSFX
	ld   b, $F0
	jp   Cutscene_PostTextWrite
	
ENDC
	
; =============== Cutscene_WriteText_Custom ===============
; Writes out a screen of text for a cutscene over multiple frames.
; IN
; - HL: Ptr to TextC structure
; - B: Bank number of TextDef structure
Cutscene_WriteText_Custom:

	;
	; Blank out any existing text from the WINDOW layer.
	; Because this is done during HBLANK, it can't be done in a single frame.
	;
	push bc
		push hl
			; Wait start of next frame, to avoid running out of time
			call Task_PassControl_NoDelay
			
			; Clear the rows 1-3
			ld   hl, WINDOWMap_Begin	; BG Ptr
			ld   b, $14	; Rect Width
			ld   c, $03 ; Rect Height
			ld   d, $00 ; Tile ID
			call FillBGRect
			call Task_PassControl_NoDelay	; Wait next frame
			
			; Clear the rows 4-6
			ld   hl, WINDOWMap_Begin+$60	; BG Ptr
			ld   b, $14	; Rect Width
			ld   c, $03 ; Rect Height
			ld   d, $00 ; Tile ID
			call FillBGRect
			call Task_PassControl_NoDelay	; Wait next frame
		pop  hl
	pop  bc
	
	;
	; Write text from the second row of the WINDOW
	;
	ld   de, WINDOWMap_Begin+$20 ; Destination ptr in the tilemap
	ld   c, $04 ; Delay between letter printing
	ld   a, TXT_ALLOWFAST ; Option flags
	jp   TextPrinter_MultiFrameFarCustomPos	
	
; =============== Cutscene_WriteText_CustomSFX ===============
; Writes out a screen of text for a cutscene over multiple frames.
; Identical to Cutscene_WriteText_Custom except that this plays a SGB SFX whenever a character is printed.
; IN
; - HL: Ptr to TextC structure
; - B: Bank number of TextDef structure
Cutscene_WriteText_CustomSFX:
	;
	; Blank out any existing text from the WINDOW layer.
	; Because this is done during HBLANK, it can't be done in a single frame.
	;
	push bc
		push hl
			; Wait start of next frame, to avoid running out of time
			call Task_PassControl_NoDelay
			
			; Clear the rows 1-3
			ld   hl, WINDOWMap_Begin	; BG Ptr
			ld   b, $14	; Rect Width
			ld   c, $03 ; Rect Height
			ld   d, $00 ; Tile ID
			call FillBGRect
			call Task_PassControl_NoDelay	; Wait next frame
			
			; Clear the rows 4-6
			ld   hl, WINDOWMap_Begin+$60	; BG Ptr
			ld   b, $14	; Rect Width
			ld   c, $03 ; Rect Height
			ld   d, $00 ; Tile ID
			call FillBGRect
			call Task_PassControl_NoDelay	; Wait next frame
		pop  hl
	pop  bc
	
	;
	; Write text from the second row of the WINDOW
	;
	ld   de, WINDOWMap_Begin+$20 ; Destination ptr in the tilemap
	ld   c, $04 ; Delay between letter printing
	ld   a, TXT_PLAYSFX|TXT_ALLOWFAST ; Option flags
	jp   TextPrinter_MultiFrameFarCustomPos

; This OBJInfoInit structure is truncated, as every byte after iOBJInfo_OBJLstPtrTblOffset isn't needed.
OBJInfoInit_Cutscene_Kagura:
	db OST_VISIBLE ; iOBJInfo_Status
	db SPR_BGPRIORITY ; iOBJInfo_OBJLstFlags
	db $00 ; iOBJInfo_OBJLstFlagsView
	db $28 ; iOBJInfo_X
	db $00 ; iOBJInfo_XSub
	db $35 ; iOBJInfo_Y
	db $00 ; iOBJInfo_YSub
	db $00 ; iOBJInfo_SpeedX
	db $00 ; iOBJInfo_SpeedXSub
	db $00 ; iOBJInfo_SpeedY
	db $00 ; iOBJInfo_SpeedYSub
	db $00 ; iOBJInfo_RelX (auto)
	db $00 ; iOBJInfo_RelY (auto)
	db $00 ; iOBJInfo_TileIDBase
	db $00 ; iOBJInfo_VRAMPtr_Low
	db $00 ; iOBJInfo_VRAMPtr_High
	db BANK(OBJLstPtrTable_Cutscene_Kagura) ; iOBJInfo_BankNum (BANK $1D)
	db LOW(OBJLstPtrTable_Cutscene_Kagura) ; iOBJInfo_OBJLstPtrTbl_Low
	db HIGH(OBJLstPtrTable_Cutscene_Kagura) ; iOBJInfo_OBJLstPtrTbl_High
	db $00 ; iOBJInfo_OBJLstPtrTblOffset
	
INCLUDE "data/objlst/cutscene_kagura.asm"		

; =============== SubModule_CutsceneGoenitz ===============
; This submodule handles the cutscene before fighting Goenitz.
SubModule_CutsceneGoenitz:
	call Cutscene_SharedInit
	
	;
	; This part of the cutscene has a large picture of the stadium.
	;
	
	; Set screen sectors.
	ld   a, $00		; Second sector starts here (BG)
	ld   b, $5C		; Text sector starts here (WINDOW)
	call SetSectLYC
	
	; Load the BG graphics for the stadium
	ld   hl, GFXLZ_Cutscene_StadiumBG
	ld   de, wLZSS_Buffer+$10
	call DecompressLZSS
	ld   hl, wLZSS_Buffer+$10
	ld   de, $8800
	ld   b, $68
	call CopyTiles
	
	; Load the tilemap for the stadium picture as a rectangle
	ld   hl, BGLZ_Cutscene_StadiumBG
	ld   de, wLZSS_Buffer+$10
	call DecompressLZSS
	ld   de, wLZSS_Buffer+$10 ; Ptr to uncompressed tilemap
	ld   hl, $9823 ; Destination Ptr in VRAM
	ld   b, $0E ; Rect Width
	ld   c, $0A ; Rect Height
	ld   a, $80 ; Tile ID base offset (from $8800)
	call CopyBGToRectWithBase
	
	; Enable screen
	call Cutscene_ResumeLCDWithLYC
	
	; Initialize effect vars
	xor  a
	ld   [wCutMoveLargeChars], a
	ld   [wCutFlashTimer], a
	ei
	
	; Sync screen before setting palette
	call Task_PassControl_NoDelay
	
	; Set picture palette
	ld   a, $1B
	ldh  [rBGP], a
	ldh  [hScreenSect1BGP], a
	
	; Set text palette
	ld   a, $13
	ldh  [hScreenSect0BGP], a
	ldh  [hScreenSect2BGP], a
	
	; Play cutscene BGM
	ld   a, BGM_PROTECTOR
	call HomeCall_Sound_ReqPlayExId_Stub
	
	;
	; TEXT PRINTING
	;
	
	; No code between letters
	ld   a, TXB_NONE
	ld   [wTextPrintFrameCodeBank], a
	
	; Write the text, screen by screen	
	ld   hl, TextC_CutsceneGoenitz00
	call Cutscene_WriteTextBank1C
	ld   hl, TextC_CutsceneGoenitz01
	call Cutscene_WriteTextBank1C
	ld   hl, TextC_CutsceneGoenitz02
	call Cutscene_WriteTextBank1C
	ld   hl, TextC_CutsceneGoenitz03
	call Cutscene_WriteTextBank1C
	ld   hl, TextC_CutsceneGoenitz04
	call Cutscene_WriteTextBank1C
	ld   hl, TextC_CutsceneGoenitz05
	call Cutscene_WriteTextBank1C
	ld   hl, TextC_CutsceneGoenitz06
	call Cutscene_WriteTextBank1C
	ld   hl, TextC_CutsceneGoenitz07
	call Cutscene_WriteTextBank1C
	ld   hl, TextC_CutsceneGoenitz08
	call Cutscene_WriteTextBank1C
	ld   hl, TextC_CutsceneGoenitz09
	call Cutscene_WriteTextBank1C
	ld   hl, TextC_CutsceneGoenitz0A
	call Cutscene_WriteTextBank1C
	ld   hl, TextC_CutsceneGoenitz0B
	call Cutscene_WriteTextBank1C
	
	
	; On EASY difficulty, the cutscene ends in an alternate way
	ld   a, [wDifficulty]
	cp   DIFFICULTY_EASY
	jp   z, CutsceneGoenitz_Easy
	

	
IF REV_VER_2 == 0

	;##
	;
	; Do the flashing effect.
	;
	; In the Japanese version, the stadium background disappears and the music continues.
	;
	
	; White out palette for center section
	xor  a
	ldh  [rBGP], a
	ldh  [hScreenSect1BGP], a
	
	; Scroll viewport to show an empty area of the tilemap in the middle sector.
	; This scrolls off-screen the area where the Stadium background was located.
	ld   a, $80
	ldh  [hScrollY], a

	; Flash screen
	ld   a, $01
	ld   [wCutFlashTimer], a
	
	; Flash screen while writing text.
	; Because this happens only after a character is printed, it's relatively slow.
	ld   a, BANK(Cutscene_FlashBGPal)
	ld   [wTextPrintFrameCodeBank], a
	ld   hl, wTextPrintFrameCodePtr_Low
	ld   [hl], LOW(Cutscene_FlashBGPal)
	inc  hl
	ld   [hl], HIGH(Cutscene_FlashBGPal)
	
	; Write the two screens of text
	ld   hl, TextC_CutsceneGoenitz0C
	call Cutscene_WriteTextBank1C
	
	ld   hl, TextC_CutsceneGoenitz0D
	call Cutscene_WriteTextBank1C
ELSE
	
	;
	; The English version sets this up differently to make it more in line with the arcade version:
	;
	; - The music cuts itself off, with a sound effect playing for the wind
	; - The stadium background doesn't go away until Goenitz appears, meaning
	;   it's also still there while the screen flashes
	; - The first line of text is printed before the screen flashes
	; - The screen flashes less time, only during one text string,
	;   and it doesn't stop at the same time Goenitz shows up.
	;

	; Stop cutscene music
	ld   a, SND_MUTE
	call HomeCall_Sound_ReqPlayExId_Stub
	
	; Print the text "Hey!! What's that wind?!"
	ld   hl, TextC_CutsceneGoenitz0C
	call Cutscene_WriteTextBank1C
	
	; Flash screen while writing the next text.
	; Because this happens only after a character is printed, it's relatively slow.
	ld   a, BANK(Cutscene_FlashBGPal)
	ld   [wTextPrintFrameCodeBank], a
	ld   hl, wTextPrintFrameCodePtr_Low
	ld   [hl], LOW(Cutscene_FlashBGPal)
	inc  hl
	ld   [hl], HIGH(Cutscene_FlashBGPal)
	
	; Start the wind effect with it
	ld   a, SFX_FIREHIT_A
	call HomeCall_Sound_ReqPlayExId

	;
	; Do the flashing effect NOW
	;
	
	ld   a, $01
	ld   [wCutFlashTimer], a
	
	; Display the next line of text.
	; This is done manually since the text displayed while it's flashing
	; stays up half the time of the normal $F0 frames.
	ld   hl, TextC_CutsceneGoenitz0D
	ld   b, BANK(TextC_CutsceneGoenitz0D) ; BANK $1C
	call Cutscene_WriteText_Custom
	ld   b, $78
	call Cutscene_PostTextWrite
	
	; Restore standard palette
	ld   a, $1B
	ldh  [rBGP], a
	ldh  [hScreenSect1BGP], a
	
	; Resu
	
	; Disable flashing and wait for a few seconds
	ld   a, $00
	ld   [wCutFlashTimer], a
	ld   b, $78
	call Cutscene_PostTextWrite
	
	; Clear the palettes in preparation of Goenitz loading.
	; This version of the game doesn't scroll the BG offscreen, so Goenitz would
	; show up immediately otherwise.
	xor  a
	ldh  [rBGP], a
	ldh  [hScreenSect0BGP], a
	ldh  [hScreenSect1BGP], a
	ldh  [hScreenSect2BGP], a
ENDC

	
	;##
	;
	; Goenitz appears
	;
	
	di
	;-----------------------------------
	rst  $10				; Stop LCD
	
IF REV_VER_2 == 1
	; Not necessary
	xor  a
	ldh  [rBGP], a
ENDC
	
	; Clear tilemap for center sector
	call ClearBGMap
	
	; Load Goenitz off-screen above
	call Cutscene_LoadGoenitzBG
	
	ei
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_OBJSIZE|LCDC_WENABLE|LCDC_WTILEMAP|LCDC_ENABLE
	rst  $18				; Resume LCD
	;-----------------------------------
	
	; Play new music
	ld   a, BGM_WIND
	call HomeCall_Sound_ReqPlayExId_Stub
	
	; Stop flashing
	xor  a
	ld   [wCutFlashTimer], a
	
	; Wait 4 frames
	call Task_PassControl_Delay04
	
	; Scroll the screen back up to show Goenitz
	ld   a, -$05
	ldh  [hScrollY], a
	
IF REV_VER_2 == 1
	call Task_PassControl_NoDelay
ENDC
	
	;
	; Set sector palette data
	;
	
	; Middle
	ld   a, $6C
	ldh  [rBGP], a
	ldh  [hScreenSect1BGP], a
	
	; Top + bottom
	ld   a, $13
	ldh  [hScreenSect0BGP], a
	ldh  [hScreenSect2BGP], a
	
	;
	; TEXT PRINTING
	;
	
	ld   a, TXB_NONE
	ld   [wTextPrintFrameCodeBank], a
	
IF REV_LANG_EN == 0
	ld   hl, TextC_CutsceneGoenitz0E
	call Cutscene_WriteTextBank1C
	ld   hl, TextC_CutsceneGoenitz0F
	call Cutscene_WriteTextBank1C
	ld   hl, TextC_CutsceneGoenitz10
	call Cutscene_WriteTextBank1C
	ld   hl, TextC_CutsceneGoenitz11
	call Cutscene_WriteTextBank1C
	ld   hl, TextC_CutsceneGoenitz12
	call Cutscene_WriteTextBank1C
	ld   hl, TextC_CutsceneGoenitz13
	call Cutscene_WriteTextBank1C
ELSE
	ld   hl, TextC_CutsceneGoenitz0E
	call Cutscene_WriteTextBank09
	ld   hl, TextC_CutsceneGoenitz0F
	call Cutscene_WriteTextBank09
	ld   hl, TextC_CutsceneGoenitz10
	call Cutscene_WriteTextBank09
	ld   hl, TextC_CutsceneGoenitz11
	call Cutscene_WriteTextBank09
	ld   hl, TextC_CutsceneGoenitz12
	call Cutscene_WriteTextBank09
	ld   hl, TextC_CutsceneGoenitz13
	call Cutscene_WriteTextBank09
	ld   hl, TextC_CutsceneGoenitz14
	call Cutscene_WriteTextBank09
ENDC
	;##
	;
	; Show the characters in the player team.
	;
	
	
	; Black out center section
	ld   a, $FF
	ldh  [rBGP], a
	ldh  [hScreenSect1BGP], a
	di
	;-----------------------------------
	rst  $10				; Stop LCD
	
	; Clear tilemap for center sector
	call ClearBGMap
	
	; Load character sprites in the tilemap, similar to the win screen.
	call Cutscene_InitChars
	
	ei
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_OBJSIZE|LCDC_WENABLE|LCDC_WTILEMAP|LCDC_ENABLE
	rst  $18				; Resume LCD
	;-----------------------------------
	
	call Task_PassControl_Delay04
	
	; Initialize other character screen field
	call Cutscene_InitCharMisc
	
	; Show one last screen of text to go with the shot of the team
IF REV_LANG_EN == 0
	ld   hl, TextC_CutsceneGoenitz14
	call Cutscene_WriteTextBank1C
ELSE
	ld   hl, TextC_CutsceneGoenitz15
	call Cutscene_WriteTextBank09
ENDC
	;
	; We're done
	;
	jp   Cutscene_End
	
; =============== Cutscene_FlashBGPal ===============
; Flashes the background palette for the middle section of the screen.
Cutscene_FlashBGPal:

	;
	; Don't do this if it's disabled (Timer == 0)
	;
	ld   a, [wCutFlashTimer]
	cp   $00
	ret  z
	
	;
	; Increment the flash timer, which determines the palette.
	;
	; This increments by one, except when it overflows.
	; To avoid the flash effect from ending and to keep the timing consistent,
	; the timer goes from $FF to $02.
	; Though it could have jumped to $04 to avoid a 4-frame window of black frames.
	; $FE -> black
	; $FF -> black
	; $00 -> (none)
	; $01 -> norm
	; $02 -> black
	; $03 -> black
	;
	inc  a				; Timer++
	jr   nz, .saveTimer	; Timer > 0? If so, jump
	inc  a				; Timer += 2
	inc  a
.saveTimer:
	ld   [wCutFlashTimer], a
	
	;
	; Determine the palette to set.
	; Every two frames, switch to a different palette.
	;
	and  a, $02				; FlashTimer & %10 == 0?
	jr   z, .setPalNorm		; If so, restore the normal palette
.setPalBlack:				; Otherwise, completely black it
	; Use completely black palette
	ld   a, $FF
	ldh  [rBGP], a
	ldh  [hScreenSect1BGP], a
	ret
.setPalNorm:
	; Restore normal palette
	ld   a, $6C
	ldh  [rBGP], a
	ldh  [hScreenSect1BGP], a
	ret
	
; =============== Cutscene_LoadGoenitzBG ===============
; Loads the graphics and tilemap for Goenitz during cutscenes.
Cutscene_LoadGoenitzBG:
	; Load GFX
	ld   hl, GFXLZ_Cutscene_Goenitz
	ld   de, wLZSS_Buffer+$10
	call DecompressLZSS
	ld   hl, wLZSS_Buffer+$10
	ld   de, $8800
	ld   b, $4C
	call CopyTiles
	
	; Load tilemap
	ld   hl, BGLZ_Cutscene_Goenitz
	ld   de, wLZSS_Buffer+$10
	call DecompressLZSS
	ld   de, wLZSS_Buffer+$10
	ld   hl, $9844 ; Destination Ptr in VRAM
	ld   b, $0C ; Rect Width
	ld   c, $09 ; Rect Height
	ld   a, $80 ; Tile ID base offset (from $8800)
	jp   CopyBGToRectWithBase
	
; =============== Cutscene_LoadGoenitzDefeatedBG ===============
; Loads the patch tilemap for defeated Goenitz in the ending cutscene.
; This is applied over the existing one loaded by Cutscene_LoadGoenitzBG.
Cutscene_LoadGoenitzDefeatedBG:
	ld   de, BGLZ_Cutscene_GoenitzDefeated
	ld   hl, $98C8 ; Destination Ptr in VRAM
	ld   b, $04 ; Rect Width
	ld   c, $03 ; Rect Height
	ld   a, $80 ; Tile ID base offset (from $8800)
	jp   CopyBGToRectWithBase
	
; =============== CutsceneGoenitz_Easy ===============
; EASY-mode specific ending for SubModule_CutsceneGoenitz.
CutsceneGoenitz_Easy:
	; Black out palette for center sector
	ld   a, $FF
	ldh  [rBGP], a
	ldh  [hScreenSect1BGP], a
	
	;
	; Clear tilemap for center sector.
	; In easy mode, there's no screen flashing and Goenitz doesn't appear.
	;
	di
	;-----------------------------------
	rst  $10				; Stop LCD
	call ClearBGMap
	ei
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_OBJSIZE|LCDC_WENABLE|LCDC_WTILEMAP|LCDC_ENABLE
	rst  $18				; Resume LCD
	;-----------------------------------
	
	ld   a, BGM_WIND
	call HomeCall_Sound_ReqPlayExId_Stub
	
	call Task_PassControl_Delay04
	
	;
	; Set sector palette data
	;
	
	; Middle
	ld   a, $6C
	ldh  [rBGP], a
	ldh  [hScreenSect1BGP], a
	
	; Top + bottom
	ld   a, $13
	ldh  [hScreenSect0BGP], a
	ldh  [hScreenSect2BGP], a
	
	; Middle (OBJ)
	ld   a, $8C
	ldh  [rOBP0], a
	
	;
	; TEXT PRINTING
	;
	
	; Telling you to play on NORMAL difficulty
IF REV_LANG_EN == 0
	ld   hl, TextC_CutsceneGoenitz0C_Easy
	call Cutscene_WriteTextBank1C
	ld   hl, TextC_CutsceneGoenitz0D_Easy
	call Cutscene_WriteTextBank1C
ELSE
	ld   hl, TextC_CutsceneGoenitz0C_Easy
	call Cutscene_WriteTextBank1C_Copy
	ld   hl, TextC_CutsceneGoenitz0D_Easy
	call Cutscene_WriteTextBank1C_Copy
ENDC

	jp   Cutscene_End

; =============== SubModule_Ending_Generic ===============
; Generic ending after defeating Goenitz.
SubModule_Ending_Generic:
	call Cutscene_SharedInit
	
	; Top section collapsed
	ld   a, $00
	ld   b, $5C
	call SetSectLYC
	
	; Show defeated Goenitz in the tilemap
	call Cutscene_LoadGoenitzBG
	call Cutscene_LoadGoenitzDefeatedBG
	
	; Move viewport to the right, so Goenitz appears partially off-screen on the left.
	ld   a, $40
	ldh  [hScrollX], a
	
	; Show Kagura sprite mapping
	call Cutscene_LoadKaguraOBJLst
	
	; Move Kagura to the right, so she appears partially off-screen on the right.
	ld   a, $80
	ld   [wOBJInfo_Kagura+iOBJInfo_X], a
	
	; Move the characters towards the center
	call Cutscene_ResumeLCDWithLYC	; A = (something != 0)
	ld   [wCutMoveLargeChars], a
	
	; No flashing
	xor  a
	ld   [wCutFlashTimer], a
	
	; Wait for start of the frame before continuing
	ei
	
	; [BUG] This needs to be below hScrollY, otherwise Goenitz willl look cut off for a frame.
IF FIX_BUGS == 0
	call Task_PassControl_NoDelay
ENDC
	; Move viewport up so Goenitz is aligned to the end of the sector.
	; Otherwise he'd visibly look cut off.
	ld   a, -$05
	ldh  [hScrollY], a
	
	; Set Kagura palette
	ld   a, $6C
	ldh  [rOBP0], a
	
	; Set Goenitz palette
	ld   a, $6C
	ldh  [rBGP], a
	ldh  [hScreenSect1BGP], a
	
	; Set text sector palette
	ld   a, $03
	ldh  [hScreenSect0BGP], a
	ldh  [hScreenSect2BGP], a
	
IF FIX_BUGS == 1
	call Task_PassControl_NoDelay
ENDC

	; Play ending cutscene music
	ld   a, BGM_TOTHESKY
	call HomeCall_Sound_ReqPlayExId_Stub
	
	; Move the characters while printing the text
	ld   a, BANK(Cutscene_MoveLargeChars) ; BANK $1D
	ld   [wTextPrintFrameCodeBank], a
	ld   hl, wTextPrintFrameCodePtr_Low
	ld   [hl], LOW(Cutscene_MoveLargeChars)
	inc  hl
	ld   [hl], HIGH(Cutscene_MoveLargeChars)
	
	;
	; TEXT PRINTING
	;
	
IF REV_LANG_EN == 0
	ld   hl, TextC_Ending_Generic0
	call Cutscene_WriteTextBank1C
	ld   hl, TextC_Ending_Generic1
	call Cutscene_WriteTextBank1C
	ld   hl, TextC_Ending_Generic2
	call Cutscene_WriteTextBank1C
	ld   hl, TextC_Ending_Generic3
	call Cutscene_WriteTextBank1C
	ld   hl, TextC_Ending_Generic4
	call Cutscene_WriteTextBank1C
	ld   hl, TextC_Ending_Generic5
	call Cutscene_WriteTextBank1C
ELSE
	ld   hl, TextC_Ending_Generic0
	call Cutscene_WriteTextBank1C_Copy
	ld   hl, TextC_Ending_Generic1
	call Cutscene_WriteTextBank1C_Copy
	ld   hl, TextC_Ending_Generic2
	call Cutscene_WriteTextBank1C_Copy
	ld   hl, TextC_Ending_Generic3
	call Cutscene_WriteTextBank1C_Copy
	ld   hl, TextC_Ending_Generic4
	call Cutscene_WriteTextBank1C_Copy
	ld   hl, TextC_Ending_Generic5
	call Cutscene_WriteTextBank1C_Copy
	ld   hl, TextC_Ending_Generic6
	call Cutscene_WriteTextBank1C_Copy
ENDC
	;--
	
	call Ending_GoenitzLeave
	
	di
	;-----------------------------------
	rst  $10				; Stop LCD
	
	; Delete center sector
	call ClearBGMap
	
	; Show and move Kagura to the center of the screen
	ld   a, OST_VISIBLE
	ld   [wOBJInfo_Kagura+iOBJInfo_Status], a
	ld   a, $28
	ld   [wOBJInfo_Kagura+iOBJInfo_X], a
	ei
	
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_OBJSIZE|LCDC_WENABLE|LCDC_WTILEMAP|LCDC_ENABLE
	rst  $18				; Resume LCD
	;-----------------------------------
	call Task_PassControl_NoDelay
	
IF REV_VER_2 == 1
	; Play the credits music in the English version.
	; Because it starts here, a check was done later on to not restart it again
	; when the actual credits show up.
	ld   a, BGM_RISINGRED
	call HomeCall_Sound_ReqPlayExId_Stub
	call Task_PassControl_NoDelay
ENDC
	
	; Stop moving characters
	xor  a
	ld   [wCutMoveLargeChars], a
	ld   a, TXB_NONE
	ld   [wTextPrintFrameCodeBank], a
	
	; Display the last lines of text
IF REV_LANG_EN == 0
	ld   hl, TextC_Ending_KaguraGeneric0
	call Cutscene_WriteTextBank1C
	ld   hl, TextC_Ending_KaguraGeneric1
	call Cutscene_WriteTextBank1C
	ld   hl, TextC_Ending_KaguraGeneric2
	call Cutscene_WriteTextBank1C
ELSE
	ld   hl, TextC_Ending_KaguraGeneric0
	call Cutscene_WriteTextBank08
	ld   hl, TextC_Ending_KaguraGeneric1
	call Cutscene_WriteTextBank08
	ld   hl, TextC_Ending_KaguraGeneric2
	call Cutscene_WriteTextBank08
ENDC
	jp   Cutscene_End
	
; =============== Ending_GoenitzLeave ===============
; Part of the ending where Goentiz leaves while flashing the palette.
Ending_GoenitzLeave:
	di
	;-----------------------------------
	rst  $10				; Stop LCD
	
	; Delete existing Goenitz
	call ClearBGMap
	
	; Hide Kagura
	xor  a
	ld   [wOBJInfo_Pl1+iOBJInfo_Status], a
	
	; Set center sector to focus on Goenitz (which will be loaded shortly after).
	; [TCRF] The Y position cuts off the lower part of the graphic, and the screen only scrolls up.
	ld   a, -$10
	ldh  [hScrollX], a
	ld   a, +$20
	ldh  [hScrollY], a
	
	; Enable sector system
	ld   a, $18		; Start middle sector here
	ld   b, $5C		; End it here
	call SetSectLYC
	
	; Load GFX for Goenitz holding an hand up
	ld   hl, GFXLZ_Cutscene_GoenitzEscape
	ld   de, wLZSS_Buffer+$10
	call DecompressLZSS
	ld   hl, wLZSS_Buffer+$10
	ld   de, $8800
	ld   b, $50
	call CopyTiles
	
	; And load the respective tilemap
	ld   hl, BGLZ_Cutscene_GoenitzEscape
	ld   de, wLZSS_Buffer+$10
	call DecompressLZSS
	ld   de, wLZSS_Buffer+$10
	ld   hl, $9844 ; Destination Ptr in VRAM
	ld   b, $08 ; Rect Width
	ld   c, $0E ; Rect Height
	ld   a, $80 ; Tile ID base offset (from $8800)
	call CopyBGToRectWithBase
	
	ei
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_OBJSIZE|LCDC_WENABLE|LCDC_WTILEMAP|LCDC_ENABLE
	rst  $18				; Resume LCD
	;-----------------------------------
	
	; Set fully black palette for top sector.
	ld   a, $FF
	ldh  [hScreenSect0BGP], a
	; Set standard palette for middle sector
	ld   a, $6C
	ldh  [rBGP], a
	ldh  [hScreenSect1BGP], a
	; Set palette for text sector
	ld   a, $03
	ldh  [hScreenSect2BGP], a
	
	; Don't move characters horizontally.
	; Goenitz will be moved vertically, but that's handled separately.
	xor  a
	ld   [wCutMoveLargeChars], a
	call Task_PassControl_Delay04
	
	;
	; TEXT PRINTING
	;
	ld   a, TXB_NONE
	ld   [wTextPrintFrameCodeBank], a
IF REV_LANG_EN == 0
	ld   hl, TextC_Ending_GoenitzLeave0
	call Cutscene_WriteTextBank1C
ELSE
	ld   hl, TextC_Ending_GoenitzLeave0
	call Cutscene_WriteTextBank1C_Copy
ENDC

	; Start moving up while printing the next text, scrolling
	; Goenitz's hand into view.
	ld   a, BANK(Cutscene_ScrollUp)
	ld   [wTextPrintFrameCodeBank], a
	ld   hl, wTextPrintFrameCodePtr_Low
	ld   [hl], LOW(Cutscene_ScrollUp)
	inc  hl
	ld   [hl], HIGH(Cutscene_ScrollUp)
	
	; Because Cutscene_WriteTextBank1C calls Cutscene_PostTextWrite, and that subroutine
	; doesn't call Cutscene_ScrollUp, we have to call Cutscene_WriteText_Custom manually.
IF REV_LANG_EN == 0
	ld   hl, TextC_Ending_GoenitzLeave1
	ld   b, BANK(TextC_Ending_GoenitzLeave1) ; BANK $1C
	call Cutscene_WriteText_Custom
	ld   hl, TextC_Ending_GoenitzLeave2
	ld   b, BANK(TextC_Ending_GoenitzLeave2) ; BANK $1C
	call Cutscene_WriteText_Custom
ELSE
	ld   hl, TextC_Ending_GoenitzLeave1
	ld   b, BANK(TextC_Ending_GoenitzLeave1) ; BANK $1C
	call Cutscene_WriteText_Custom
	ld   hl, TextC_Ending_GoenitzLeave2
	ld   b, BANK(TextC_Ending_GoenitzLeave2) ; BANK $1C
	call Cutscene_WriteText_Custom
ENDC
	

	; Continue scrolling up until reaching the target position.
.mvLoop:
	call Task_PassControl_NoDelay
	call Cutscene_ScrollUp
	ldh  a, [hScrollY]
	cp   $E0						; Reached the target position yet?
	jr   nz, .mvLoop				; If not, loop
	call Task_PassControl_Delay3B
	
	; Scroll away from Goenitz's hand, to blank the center sector
	; in preparation of the flashing.
	ld   a, $80
	ldh  [hScrollX], a
	ldh  [hScrollY], a
	ld   [wCutFlash2Timer], a
IF REV_VER_2 == 1
	; Mute the music before starting the flashing
	ld   a, SND_MUTE
	call HomeCall_Sound_ReqPlayExId_Stub
ENDC
	call Task_PassControl_NoDelay
	
	;
	; Do the palette flash effect.
	; Unlike the normal palette flashing by Cutscene_FlashBGPal, this one
	; gets progressively faster as time goes on.
	;
	; There are four different thresholds for flashing speed, each handled
	; by its own subroutine.
	;
	
	
	; Speed 0 (8 frames)
	ld   b, $20
.s0Loop:
	call Cutscene_Flash2Spd0
	call Task_PassControl_NoDelay
	dec  b
	jr   nz, .s0Loop
	
	; Speed 1 (4 frames)
	ld   b, $20
.s1Loop:
	call Cutscene_Flash2Spd1
	call Task_PassControl_NoDelay
	dec  b
	jr   nz, .s1Loop
	
	; Speed 2 (2 frames)
	ld   b, $20
.s2Loop:
	call Cutscene_Flash2Spd2
	call Task_PassControl_NoDelay
	dec  b
	jr   nz, .s2Loop
	
	; Speed 3 (1 frame)
	ld   b, $20
.s3Loop:
	call Cutscene_Flash2Spd3
	call Task_PassControl_NoDelay
	dec  b
	jr   nz, .s3Loop
	
	; We're done, restore the normal palette
	ld   a, $6C
	ldh  [hScreenSect1BGP], a
	
IF REV_VER_2 == 1
	; In the English version, where no music is currently playing, 
	; plays a sound effect to go with Goenitz leaving
	call Task_PassControl_NoDelay
	ld   a, SFX_FIREHIT_A
	call HomeCall_Sound_ReqPlayExId
	call Task_PassControl_Delay3B ; Not necessary
ENDC
	jp   Task_PassControl_Delay3B
	
	
; =============== Cutscene_Flash2Spd0 ===============
; Switches between palettes every 8 frames.
Cutscene_Flash2Spd0:
	ld   a, [wCutFlash2Timer]			; Timer++
	inc  a
	ld   [wCutFlash2Timer], a
	and  a, $08							; (Timer & %1000) == 0?
	jr   z, Cutscene_Flash2SetPalWhite	; If so, jump
	; Fall-through
	
; =============== Cutscene_Flash2SetPal* ===============
; Helper subroutines called by every Cutscene_Flash2Spd*.
Cutscene_Flash2SetPalBlack:
	ld   a, $FF
	ldh  [hScreenSect1BGP], a
	ret
Cutscene_Flash2SetPalWhite:
	ld   a, $6C
	ldh  [hScreenSect1BGP], a
	ret
	
; =============== Cutscene_Flash2Spd1 ===============
; Switches between palettes every 4 frames.
Cutscene_Flash2Spd1:
	ld   a, [wCutFlash2Timer]
	inc  a
	ld   [wCutFlash2Timer], a
	and  a, $04
	jr   z, Cutscene_Flash2SetPalWhite
	jr   Cutscene_Flash2SetPalBlack
	
; =============== Cutscene_Flash2Spd2 ===============
; Switches between palettes every 2 frames.	
Cutscene_Flash2Spd2:
	ld   a, [wCutFlash2Timer]
	inc  a
	ld   [wCutFlash2Timer], a
	and  a, $02
	jr   z, Cutscene_Flash2SetPalWhite
	jr   Cutscene_Flash2SetPalBlack
	
; =============== Cutscene_Flash2Spd3 ===============
; Switches between palettes every other frame.
Cutscene_Flash2Spd3:
	ld   a, [wCutFlash2Timer]
	inc  a
	ld   [wCutFlash2Timer], a
	and  a, $01
	jr   z, Cutscene_Flash2SetPalWhite
	jr   Cutscene_Flash2SetPalBlack
	
; =============== Cutscene_MoveLargeChars ===============
; Moves the large cutscene characters (Kagura, Goenitz) until they reach their target position.
; This is used in the main ending cutscene, where both characters are visible at the same
; time, with Goenitz moving right and Kagura left from the edges of the screen.
Cutscene_MoveLargeChars:

	; This must be manually enabled
	ld   a, [wCutMoveLargeChars]
	and  a
	ret  z
	
	; If we reached the target position of $50 already, return.
	ld   a, [wOBJInfo_Kagura+iOBJInfo_X]
	cp   $50
	ret  z
	
	;
	; Move Kagura left at $00.10px/frame.
	; This is in the sprite layer, so moving left accomplishes just that.
	;

	; H = Kagura X Pos
	ld   h, a						
	; L = Kagura Y Pos
	ld   a, [wOBJInfo_Kagura+iOBJInfo_XSub]	; L = Sub Pos
	ld   l, a
	
	; Move left by -$00.10
	ld   de, -$0010
	add  hl, de
	
	; Save the updated value back
	ld   a, h
	ld   [wOBJInfo_Kagura+iOBJInfo_X], a
	ld   a, l
	ld   [wOBJInfo_Kagura+iOBJInfo_XSub], a
	
	
	;
	; Move Goenitz right at $00.10px/frame.
	; Because Goenitz is part of the BG layer, this is done by moving the viewport to the left.
	;
	
	; HL = Goenitz X Pos
	ldh  a, [hScrollX]
	ld   h, a
	ldh  a, [hScrollXSub]
	ld   l, a
	
	; Scroll viewport left by -$00.10
	add  hl, de
	
	; Save the updated value back
	ld   a, h
	ldh  [hScrollX], a
	ld   a, l
	ldh  [hScrollXSub], a
	ret
	
; =============== Cutscene_ScrollUp ===============
; Scrolls the screen up at $00.40px/frame, until the target is reached.
; This is used to move Goenitz down to display his hand in his escape/death anim.
Cutscene_ScrollUp:
	; DE = Movement speed
	ld   de, -$0040
	
	; If we reached the target position already, return
	ldh  a, [hScrollY]
	cp   $E0
	ret  z
	
	; hScrollY += -$0040
	ld   h, a
	ldh  a, [hScrollYSub]
	ld   l, a
	add  hl, de
	ld   a, h
	ldh  [hScrollY], a
	ld   a, l
	ldh  [hScrollYSub], a
	ret
	
; =============== SubModule_Ending_SacredTreasures ===============
; Special ending after defeating Goenitz with Iori, Kyo and Chizuru in the team.	
SubModule_Ending_SacredTreasures:
	call Cutscene_SharedInit
	
	; Top section collapsed
	ld   a, $00
	ld   b, $5C
	call SetSectLYC
	
	; Show defeated Goenitz in the tilemap
	call Cutscene_LoadGoenitzBG
	call Cutscene_LoadGoenitzDefeatedBG
	
	; Move viewport up so Goenitz is aligned to the end of the sector.
	ld   a, -$05
	ldh  [hScrollY], a
	
	call Cutscene_ResumeLCDWithLYC
	
	; Don't do any effects.
	; Goenitz stays fixed at the center of the screen.
	xor  a
	ld   [wCutMoveLargeChars], a
	ld   [wCutFlashTimer], a
	
	; Wait for start of the frame before continuing
	ei
	call Task_PassControl_Delay09
	
	; Set Goenitz palette
	ld   a, $6C
	ldh  [rBGP], a
	ldh  [hScreenSect1BGP], a
	
	; Set text sector palette
	ld   a, $13
	ldh  [hScreenSect0BGP], a
	ldh  [hScreenSect2BGP], a
	
	
	; Play ending cutscene music
	ld   a, BGM_TOTHESKY
	call HomeCall_Sound_ReqPlayExId_Stub
	
	;
	; TEXT PRINTING
	;
	ld   a, TXB_NONE
	ld   [wTextPrintFrameCodeBank], a
	ld   hl, TextC_Ending_SacredTreasures00
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_Ending_SacredTreasures01
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_Ending_SacredTreasures02
	call Cutscene_WriteTextBank1D

	;
	; FLASH EFFECT
	;
	
	; White out screen
	xor  a
	ldh  [rBGP], a				; Fully white palette
	ldh  [hScreenSect1BGP], a
	ld   a, $80					; Scroll Goenitz off-screen
	ldh  [hScrollY], a
	
	; Set up flashing
	ld   a, $01
	ld   [wCutFlashTimer], a
	ld   a, BANK(Cutscene_FlashBGPal)
	ld   [wTextPrintFrameCodeBank], a
	ld   hl, wTextPrintFrameCodePtr_Low
	ld   [hl], LOW(Cutscene_FlashBGPal)
	inc  hl
	ld   [hl], HIGH(Cutscene_FlashBGPal)
	
	; Print this while flashing
	ld   hl, TextC_Ending_SacredTreasures03
	call Cutscene_WriteTextBank1D
	
	; Stop flashing
	xor  a
	ld   [wCutFlashTimer], a
	call Task_PassControl_NoDelay
	
	;
	; DISPLAY TEAM MEMBERS
	;
	
	; Black out palette before load.
	; This is required to hide that graphics are loading of graphics while the display is enabled.
	; Why doing that? If display were disabled, the screen would flash white while doing this.
	ld   a, $FF
	ldh  [rBGP], a
	ldh  [hScreenSect1BGP], a
	ldh  [rOBP0], a
	
	; Wait for next frame
	call Task_PassControl_NoDelay
	di
	;-----------------------------------
	rst  $10				; Stop LCD
	
	; Scroll screen to top left
	xor  a
	ldh  [hScrollX], a
	ldh  [hScrollY], a
	
	; Delete Goenitz
	call ClearBGMap
	
	; Display team members
	call Cutscene_InitChars
	ei
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_OBJSIZE|LCDC_WENABLE|LCDC_WTILEMAP|LCDC_ENABLE
	rst  $18				; Resume LCD
	;-----------------------------------
	
	; Wait a bit
	call Task_PassControl_Delay09
	
	; Set up palettes, etc...
	call Cutscene_InitCharMisc
	
	;
	; Print all of the screens of text.
	;
	ld   a, TXB_NONE
	ld   [wTextPrintFrameCodeBank], a
	ld   hl, TextC_Ending_SacredTreasures04
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_Ending_SacredTreasures05
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_Ending_SacredTreasures06
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_Ending_SacredTreasures07
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_Ending_SacredTreasures08
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_Ending_SacredTreasures09
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_Ending_SacredTreasures0A
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_Ending_SacredTreasures0B
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_Ending_SacredTreasures0C
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_Ending_SacredTreasures0D
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_Ending_SacredTreasures0E
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_Ending_SacredTreasures0F
	call Cutscene_WriteTextBank1D
IF REV_LANG_EN == 1
	ld   hl, TextC_Ending_SacredTreasures10
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_Ending_SacredTreasures11
	call Cutscene_WriteTextBank1D
ENDC
	jp   Cutscene_End
	
; =============== SubModule_Ending_OLeona ===============
; Special ending after defeating Goenitz with Leona, Iori, and Mature in the team.		
SubModule_Ending_OLeona:

	call Cutscene_SharedInit
	
	; Top section collapsed
	ld   a, $00
	ld   b, $5C
	call SetSectLYC
	
	; Show defeated Goenitz in the tilemap
	call Cutscene_LoadGoenitzBG
	call Cutscene_LoadGoenitzDefeatedBG
	
	; Move viewport up so Goenitz is aligned to the end of the sector.
	ld   a, -$05
	ldh  [hScrollY], a
	
	call Cutscene_ResumeLCDWithLYC
	
	; Don't do any effects.
	; Goenitz stays fixed at the center of the screen.
	xor  a
	ld   [wCutMoveLargeChars], a
	ld   [wCutFlashTimer], a
	
	; Wait for start of the frame before continuing
	ei
	call Task_PassControl_Delay09
	
	; Set Goenitz palette
	ld   a, $6C
	ldh  [rBGP], a
	ldh  [hScreenSect1BGP], a
	ldh  [rOBP0], a
	
	; Set text sector palette
	ld   a, $13
	ldh  [hScreenSect0BGP], a
	ldh  [hScreenSect2BGP], a
	
	
	; Play ending cutscene music
	ld   a, BGM_TOTHESKY
	call HomeCall_Sound_ReqPlayExId_Stub
	
	;
	; TEXT PRINTING
	;
	ld   a, TXB_NONE
	ld   [wTextPrintFrameCodeBank], a
IF REV_LANG_EN == 0
	ld   hl, TextC_Ending_OLeona0
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_Ending_OLeona1
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_Ending_OLeona2
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_Ending_OLeona3
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_Ending_OLeona4
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_Ending_OLeona5
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_Ending_OLeona6
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_Ending_Generic5 ; TextC_Ending_OLeona7
	call Cutscene_WriteTextBank1C
ELSE
	ld   hl, TextC_Ending_OLeona0
	call Cutscene_WriteTextBank1D_Copy
	ld   hl, TextC_Ending_OLeona1
	call Cutscene_WriteTextBank1D_Copy
	ld   hl, TextC_Ending_OLeona2
	call Cutscene_WriteTextBank1D_Copy
	ld   hl, TextC_Ending_OLeona3
	call Cutscene_WriteTextBank1D_Copy
	ld   hl, TextC_Ending_OLeona4
	call Cutscene_WriteTextBank1D_Copy
	ld   hl, TextC_Ending_OLeona5
	call Cutscene_WriteTextBank1D_Copy
	ld   hl, TextC_Ending_OLeona6
	call Cutscene_WriteTextBank1D_Copy
	ld   hl, TextC_Ending_Generic6 ; TextC_Ending_OLeona7
	call Cutscene_WriteTextBank1C_Copy
ENDC
	; Goenitz flies away with the palette flash, like the normal ending
	call Ending_GoenitzLeave
	call Task_PassControl_NoDelay
	
	;
	; DISPLAY TEAM MEMBERS
	;
	
	; Black out palette before load.
	ld   a, $FF
	ldh  [rBGP], a
	ldh  [hScreenSect0BGP], a
	ldh  [hScreenSect1BGP], a
	ldh  [hScreenSect2BGP], a
	ldh  [rOBP0], a
	
	; Wait for next frame
	call Task_PassControl_NoDelay
	di
	;-----------------------------------
	rst  $10				; Stop LCD
	
	; Delete Goenitz
	call ClearBGMap
	
	; Scroll screen to top left
	xor  a
	ldh  [hScrollX], a
	ldh  [hScrollY], a
	
	; Display team members
	call Cutscene_InitChars
	ei
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_OBJSIZE|LCDC_WENABLE|LCDC_WTILEMAP|LCDC_ENABLE
	rst  $18				; Resume LCD
	;-----------------------------------
	
	; Wait a bit
	call Task_PassControl_Delay04
	
	; Set up palettes, etc...
	call Cutscene_InitCharMisc
	
	; Disable flash
	xor  a
	ld   [wCutFlashTimer], a
	
	;
	; Print all of the screens of text.
	;
	ld   a, TXB_NONE
	ld   [wTextPrintFrameCodeBank], a
IF REV_LANG_EN == 0
	ld   hl, TextC_Ending_OLeona8
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_Ending_OLeona9
	call Cutscene_WriteTextBank1D
ELSE
	ld   hl, TextC_Ending_OLeona8
	call Cutscene_WriteTextBank1D_Copy
	ld   hl, TextC_Ending_OLeona9
	call Cutscene_WriteTextBank1D_Copy
ENDC
	jp   Cutscene_End
	
; =============== SubModule_EndingPost_FFGeese ===============
; Special post ending scene after defeating Goenitz with Terry, Andy and Geese in the team.
; All of the EndingPost_* cutscenes are set on the team display screen.
SubModule_EndingPost_FFGeese:
	call Cutscene_SharedInit
	
	; Top section collapsed
	ld   a, $00
	ld   b, $5C
	call SetSectLYC
	
	; Display team members
	call Cutscene_InitChars
	
	call Cutscene_ResumeLCDWithLYC
	
	; No special effects
	xor  a
	ld   [wCutMoveLargeChars], a
	ld   [wCutFlashTimer], a
	ei
	
	; Wait a bit before showing anything
	call Task_PassControl_Delay09
	
	; Set up palettes, etc...
	call Cutscene_InitCharMisc
	ld   a, TXB_NONE
	ld   [wTextPrintFrameCodeBank], a
	
	; Print out the special text
IF REV_LANG_EN == 0
	ld   hl, TextC_EndingPost_FFGeese0
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_EndingPost_FFGeese1
	call Cutscene_WriteTextBank1D
ELSE
	ld   hl, TextC_EndingPost_FFGeese0
	call Cutscene_WriteTextBank06
	ld   hl, TextC_EndingPost_FFGeese1
	call Cutscene_WriteTextBank06
ENDC
	jp   Cutscene_End

; =============== SubModule_EndingPost_AOFMrBig ===============
; Special post ending scene after defeating Goenitz with Ryo, Robert and Mr.Big in the team.	
SubModule_EndingPost_AOFMrBig:
	call Cutscene_SharedInit
	
	; Top section collapsed
	ld   a, $00
	ld   b, $5C
	call SetSectLYC
	
	; Display team members
	call Cutscene_InitChars
	
	call Cutscene_ResumeLCDWithLYC
	
	; No special effects
	xor  a
	ld   [wCutMoveLargeChars], a
	ld   [wCutFlashTimer], a
	ei
	
	; Wait a bit before showing anything
	call Task_PassControl_Delay09
	
	; Set up palettes, etc...
	call Cutscene_InitCharMisc
	ld   a, TXB_NONE
	ld   [wTextPrintFrameCodeBank], a
	
	; Print out the special text
IF REV_LANG_EN == 0
	ld   hl, TextC_EndingPost_AOFMrBig0
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_EndingPost_AOFMrBig1
	call Cutscene_WriteTextBank1D
ELSE
	ld   hl, TextC_EndingPost_AOFMrBig0
	call Cutscene_WriteTextBank06
	ld   hl, TextC_EndingPost_AOFMrBig1
	call Cutscene_WriteTextBank06
ENDC
	jp   Cutscene_End

; =============== SubModule_EndingPost_KTR ===============
; Special post ending scene after defeating Goenitz with Kyo, Terry and Ryo in the team.	
SubModule_EndingPost_KTR:
	call Cutscene_SharedInit
	
	; Top section collapsed
	ld   a, $00
	ld   b, $5C
	call SetSectLYC
	
	; Display team members
	call Cutscene_InitChars
	
	call Cutscene_ResumeLCDWithLYC
	
	; No special effects
	xor  a
	ld   [wCutMoveLargeChars], a
	ld   [wCutFlashTimer], a
	ei
	
	; Wait a bit before showing anything
	call Task_PassControl_Delay09
	
	; Set up palettes, etc...
	call Cutscene_InitCharMisc
	ld   a, TXB_NONE
	ld   [wTextPrintFrameCodeBank], a
	
	; Print out the special text
IF REV_LANG_EN == 0
	ld   hl, TextC_EndingPost_KTR0
	call Cutscene_WriteTextBank1D
ELSE
	ld   hl, TextC_EndingPost_KTR0
	call Cutscene_WriteTextBank06
ENDC
	jp   Cutscene_End
	
; =============== SubModule_EndingPost_Boss ===============
; Special post ending scene after defeating Goenitz with Geese, Krauser and Mr.Big in the team.	
SubModule_EndingPost_Boss:
	call Cutscene_SharedInit
	
	; Top section collapsed
	ld   a, $00
	ld   b, $5C
	call SetSectLYC
	
	; Display team members
	call Cutscene_InitChars
	
	call Cutscene_ResumeLCDWithLYC
	
	; No special effects
	xor  a
	ld   [wCutMoveLargeChars], a
	ld   [wCutFlashTimer], a
	ei
	
	; Wait a bit before showing anything
	call Task_PassControl_Delay09
	
	; Set up palettes, etc...
	call Cutscene_InitCharMisc
	ld   a, TXB_NONE
	ld   [wTextPrintFrameCodeBank], a
	
	; Print out the special text
IF REV_LANG_EN == 0
	ld   hl, TextC_EndingPost_Boss0
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_EndingPost_Boss1
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_EndingPost_Boss2
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_EndingPost_Boss3
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_EndingPost_Boss4
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_EndingPost_Boss5
	call Cutscene_WriteTextBank1D
ELSE
	ld   hl, TextC_EndingPost_Boss0
	call Cutscene_WriteTextBank0A
	ld   hl, TextC_EndingPost_Boss1
	call Cutscene_WriteTextBank0A
	ld   hl, TextC_EndingPost_Boss2
	call Cutscene_WriteTextBank0A
	ld   hl, TextC_EndingPost_Boss3
	call Cutscene_WriteTextBank0A
	ld   hl, TextC_EndingPost_Boss4
	call Cutscene_WriteTextBank0A
	ld   hl, TextC_EndingPost_Boss5
	call Cutscene_WriteTextBank0A
	ld   hl, TextC_EndingPost_Boss6
	call Cutscene_WriteTextBank0A
ENDC
	jp   Cutscene_End
	
; =============== SubModule_EndingPost_Boss ===============
; Post-credits scene displayed in NORMAL mode.
SubModule_CutsceneCheat:
	call Cutscene_SharedInit
	
	; The text is printed into the WINDOW layer.
	; Move it down a bit to vertically center the text.
	ld   a, $20
	ldh  [rWY], a
	
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_OBJSIZE|LCDC_WENABLE|LCDC_WTILEMAP|LCDC_ENABLE
	rst  $18				; Resume LCD
	;-----------------------------------
	
	; No special effect
	xor  a
	ld   [wCutMoveLargeChars], a
	ld   [wCutFlashTimer], a
	
	; Wait, then set text palette
	ei
	call Task_PassControl_NoDelay
	ld   a, $03
	ldh  [rBGP], a
	
	; Print out the instructions, while playing SGB SFX for each letter
	ld   a, TXB_NONE
	ld   [wTextPrintFrameCodeBank], a
IF REV_LANG_EN == 0
	ld   hl, TextC_CheatList
	call Cutscene_WriteTextBank1CSFX
ELSE
	ld   hl, TextC_CheatList
	call Cutscene_WriteTextBank08SFX
ENDC
	jp   Cutscene_End
	
; =============== SubModule_CutsceneMrKarate ===============
; Post-credits scene displayed in HARD mode.	
SubModule_CutsceneMrKarate:
	call Cutscene_SharedInit
	
	; Enable sectors
	ld   a, $18	; Middle sector starts here
	ld   b, $5C ; Ends here
	call SetSectLYC
	
	;
	; Load Mr.Karate to wOBJInfo_Pl1 and place it at the center of the middle sector.
	;
	
	; Reload player sprite mapping
	ld   hl, wOBJInfo_Pl1+iOBJInfo_Status
	ld   de, OBJInfoInit_Pl1
	call OBJLstS_InitFrom
	; Setup properties (position, etc...) from an hardcoded entry
	ld   hl, Cutscene_CharAnimTbl.mrKarate
	call Cutscene_InitCharOBJLst
	
	call Cutscene_ResumeLCDWithLYC
	
	; No text effects
	xor  a
	ld   [wCutMoveLargeChars], a
	ld   [wCutFlashTimer], a
	ei
	
	; Wait frame then load char display palettes, etc...
	call Task_PassControl_Delay09
	call Cutscene_InitCharMisc
	
	;
	; TEXT PRINTING
	;
	ld   a, TXB_NONE
	ld   [wTextPrintFrameCodeBank], a
IF REV_LANG_EN == 0
	ld   hl, TextC_CutsceneMrKarate0
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_CutsceneMrKarate1
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_CutsceneMrKarate2
	call Cutscene_WriteTextBank1D
ELSE
	ld   hl, TextC_CutsceneMrKarate0
	call Cutscene_WriteTextBank03
	ld   hl, TextC_CutsceneMrKarate1
	call Cutscene_WriteTextBank03
	ld   hl, TextC_CutsceneMrKarate2
	call Cutscene_WriteTextBank03
ENDC
	jp   Cutscene_End
	
; =============== Cutscene_InitChars ===============
; Initializes the player characters when cutscenes want to display team members.
; This is very similar to WinScr_InitChars, and calls some code from that bank too.
Cutscene_InitChars:
	;
	; Initialize the sprite mapping for the player at the center of the screen.
	; Note that even though it uses sprites, the player at the center is *not* animated
	; unlike the win screen.
	;
	ld   hl, wOBJInfo_Winner
	ld   de, OBJInfoInit_Pl1
	call OBJLstS_InitFrom
	
	; BC = Ptr to winner wPlInfo
	ld   a, [wWinPlInfoPtr_Low]
	ld   c, a
	ld   a, [wWinPlInfoPtr_High]
	ld   b, a
	
	;
	; Initialize and use wOBJInfo_Winner to display the sprite of the winner.
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
		; HL = Ptr to animation table entry
		ld   hl, Cutscene_CharAnimTbl
		add  hl, de
		
	pop  bc
	push bc
		;
		; Set the animation / update the sprite mapping.
		;
		call Cutscene_InitCharOBJLst
		
		; Load the block of compressed character GFX to the LZSS buffer
		ld   b, BANK(OrdSel_DecompressCharGFX) ; BANK $1E
		ld   hl, OrdSel_DecompressCharGFX
		rst  $08
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
	
; =============== mCutDrawSecChar ===============
; Generates code to draw the other team members to the tilemap.
; IN
; - 1: Field for the character on the left
; - 2: Field for the character on the right
mCutDrawSecChar: MACRO
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
		;##
		ld   b, BANK(OrdSel_LoadCharGFX1P) ; BANK $1E
		ld   hl, OrdSel_LoadCharGFX1P
		rst  $08					; Copy them to DE, horizontally flipped
		;##
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
	;##
	ld   b, BANK(OrdSel_LoadCharGFX2P) ; BANK $1E
	ld   hl, OrdSel_LoadCharGFX2P
	rst  $08					; Copy them to DE
	;##
	; Fall-through to .copyCharBG_R
ENDM
	
.loss0:
	; With no losses, draw the team members in their normal order
	mCutDrawSecChar iPlInfo_TeamCharId1, iPlInfo_TeamCharId2
	jr   .copyCharBG_R
.loss1:
	; With 1 loss, iPlInfo_TeamCharId0 and iPlInfo_TeamCharId1 get switched 
	mCutDrawSecChar iPlInfo_TeamCharId0, iPlInfo_TeamCharId2
	jr   .copyCharBG_R
.loss2:
	; With 2 losses, iPlInfo_TeamCharId2 pushes both back
	mCutDrawSecChar iPlInfo_TeamCharId0, iPlInfo_TeamCharId1
	; Fall-through
	
; =============== .copyCharBG_R ===============
; Writes the tilemap for the team member on the right, facing left.
.copyCharBG_R:
	ld   hl, $988E				; Destination ptr to tilemap
	ld   de, BG_Cutscene_Char2P	; Ptr to uncompressed tilemap
	ld   a, $92					; Tile ID base offset
	jp   Cutscene_CopyCharBG
; =============== .copyCharBG_L ===============
; Writes the tilemap for the team member on the left, facing right.
.copyCharBG_L:
	ld   hl, $9883		; Destination ptr to tilemap
	call Cutscene_CopyCharBG_1P0
.ret:
	ret
	
; =============== Cutscene_InitCharOBJLst ===============
; Updates wOBJInfo_Winner with the specified animation data.	
; Almost identical to the sprite mapping update code from WinScr_InitChars.
; IN
; - HL: Ptr to Cutscene_CharAnimTbl entry (4 byte entries, same format as WinScr_CharAnimTbl)
Cutscene_InitCharOBJLst:
	; Move the ptr to BC
	push hl
	pop  bc
	
	;##
	; (this is the only different part)
	;
	; Show the sprite mapping and loop the first frame indefinitely
	ld   de, wOBJInfo_Winner+iOBJInfo_Status
	ld   a, OST_ANIMEND|OST_VISIBLE
	ld   [de], a
	;##
	
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
	jp   OBJLstS_DoAnimTiming_Initial
	
; =============== Cutscene_CopyCharBG_* ===============
; These are copied from the respective code in Module_OrdSel.

; =============== Cutscene_CopyCharBG_1P0 ===============
; Writes the tilemap for the leftmost 1P characters.
; See also: OrdSel_CopyCharBG_1P0
; IN
; - HL: Destination ptr in VRAM	
Cutscene_CopyCharBG_1P0:
	ld   a, $80
	; Fall-through
	
; =============== OrdSel_CopyCharBG_1P ===============
; Writes the tilemap for a 1P character.
; IN
; - A: Tile ID base offset
; - HL: Destination ptr in VRAM
Cutscene_CopyCharBG_1P:
	ld   de, BG_Cutscene_Char1P
	; Fall-through
	
; =============== Cutscene_CopyCharBG ===============
; Writes the tilemap for a character to VRAM.
; IN
; - DE: Ptr to uncompressed tilemap
; - HL: Destination Ptr in VRAM
; - A: Tile ID base offset
Cutscene_CopyCharBG:
	ld   b, $03		; B = Rect Width
	ld   c, $06		; C = Rect Height
	jp   CopyBGToRectWithBase
	
; =============== Cutscene_Unused_CopyCharBG_1P1 ===============
; [TCRF] Unreferenced copied code.
; Writes the tilemap for the 1P character in the middle.
; - HL: Destination ptr in VRAM
Cutscene_Unused_CopyCharBG_1P1:
	ld   a, $92
	jr   Cutscene_CopyCharBG_1P

; =============== BG_Cutscene_Char*P ===============
; Normal tilemaps with relative tile IDs, shared across characters.
; Identical to ordsel version.
BG_Cutscene_Char1P: INCBIN "data/bg/ordsel_char1p.bin"
BG_Cutscene_Char2P: INCBIN "data/bg/ordsel_char2p.bin"

; =============== Cutscene_CharAnimTbl ===============
; This table assigns every character to its own animation, used when the
; team member in the middle is displayed.
; Note that only the first frame of these animations will be played.
; See also: WinScr_CharAnimTbl
Cutscene_CharAnimTbl:
	; CHAR_ID_KYO
	dp OBJLstPtrTable_Kyo_Idle ; BANK $07
	db $00

	; CHAR_ID_DAIMON
	dp OBJLstPtrTable_Daimon_Idle ; BANK $09
	db $00

	; CHAR_ID_TERRY
	dp OBJLstPtrTable_Terry_Idle ; BANK $09
	db $00

	; CHAR_ID_ANDY
	dp OBJLstPtrTable_Andy_Idle ; BANK $08
	db $00

	; CHAR_ID_RYO
	dp OBJLstPtrTable_Ryo_Idle ; BANK $0A
	db $00

	; CHAR_ID_ROBERT
	dp OBJLstPtrTable_Robert_Idle ; BANK $07
	db $00

	; CHAR_ID_ATHENA
	dp OBJLstPtrTable_Athena_Idle ; BANK $08
	db $00

	; CHAR_ID_MAI
	dp OBJLstPtrTable_Mai_Idle ; BANK $08
	db $00

	; CHAR_ID_LEONA
	dp OBJLstPtrTable_Leona_Idle ; BANK $0A
	db $00

	; CHAR_ID_GEESE
	dp OBJLstPtrTable_Geese_Idle ; BANK $07
	db $00

	; CHAR_ID_KRAUSER
	dp OBJLstPtrTable_Krauser_Idle ; BANK $09
	db $00

	; CHAR_ID_MRBIG
	dp OBJLstPtrTable_MrBig_Idle ; BANK $07
	db $00

	; CHAR_ID_IORI
	dp OBJLstPtrTable_Iori_Idle ; BANK $05
	db $00

	; CHAR_ID_MATURE
	dp OBJLstPtrTable_Mature_Idle ; BANK $09
	db $00

	; CHAR_ID_CHIZURU
	dp OBJLstPtrTable_Chizuru_Idle ; BANK $05
	db $00

	; CHAR_ID_GOENITZ
	dp OBJLstPtrTable_Goenitz_Idle ; BANK $08
	db $00
.mrKarate:
	; CHAR_ID_MRKARATE
	dp OBJLstPtrTable_MrKarate_Idle ; BANK $0A
	db $00

	; CHAR_ID_OIORI
	dp OBJLstPtrTable_OIori_Idle ; BANK $05
	db $00

	; CHAR_ID_OLEONA
	dp OBJLstPtrTable_OLeona_Idle ; BANK $0A
	db $00

	; CHAR_ID_KAGURA
	dp OBJLstPtrTable_Chizuru_Idle ; BANK $05
	db $00

; =============== Cutscene_InitCharMisc ===============
; Initializes miscellaneous data when displaying team members.
Cutscene_InitCharMisc:
	; Set center sector palette
	ld   a, $8C
	ldh  [rOBP0], a
	ld   a, $2D
	ldh  [rBGP], a
	ldh  [hScreenSect1BGP], a
	
	; Set top/text sector palette
	ld   a, $13
	ldh  [hScreenSect0BGP], a
	ldh  [hScreenSect2BGP], a
	
	; The player at the center of the screen is slightly above the two other ones
	ld   a, $20
	ld   [wOBJInfo_Winner+iOBJInfo_Y], a
	
	; Set pre-fight cutscene music
	ld   a, BGM_MRKARATECUTSCENE
	call HomeCall_Sound_ReqPlayExId_Stub
	
	; Wait frame
	jp   Task_PassControl_NoDelay
	
; =============== SubModule_CutsceneMrKarateDefeat ===============
; Cutscene displayed after defeating the extra Mr.Karate stage.
SubModule_CutsceneMrKarateDefeat:
	call Cutscene_SharedInit
	
	; Enable sectors
	ld   a, $18	; Middle sector starts here
	ld   b, $5C ; Ends here
	call SetSectLYC
	
	;
	; Load Mr.Karate to wOBJInfo_Pl1 and place it at the center of the middle sector.
	;
	
	; Reload player sprite mapping
	ld   hl, wOBJInfo_Pl1+iOBJInfo_Status
	ld   de, OBJInfoInit_Pl1
	call OBJLstS_InitFrom
	; Setup properties (position, etc...) from an hardcoded entry
	ld   hl, Cutscene_CharAnimTbl.mrKarate
	call Cutscene_InitCharOBJLst
	
	call Cutscene_ResumeLCDWithLYC
	
	; No text effects
	xor  a
	ld   [wCutMoveLargeChars], a
	ld   [wCutFlashTimer], a
	ei
	
	; Wait frame then load char display palettes, etc...
	call Task_PassControl_Delay09
	call Cutscene_InitCharMisc
	
	;
	; TEXT PRINTING
	;
	ld   a, TXB_NONE
	ld   [wTextPrintFrameCodeBank], a
IF REV_LANG_EN == 0
	ld   hl, TextC_CutsceneMrKarateDefeat0
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_CutsceneMrKarateDefeat1
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_CutsceneMrKarateDefeat2
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_CutsceneMrKarateDefeat3
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_CutsceneMrKarateDefeat4
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_CutsceneMrKarateDefeat5
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_CutsceneMrKarateDefeat6
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_CutsceneMrKarateDefeat7
	call Cutscene_WriteTextBank1D
	ld   hl, TextC_CutsceneMrKarateDefeat8
	call Cutscene_WriteTextBank1D
ELSE
	ld   hl, TextC_CutsceneMrKarateDefeat0
	call Cutscene_WriteTextBank04
	ld   hl, TextC_CutsceneMrKarateDefeat1
	call Cutscene_WriteTextBank04
	ld   hl, TextC_CutsceneMrKarateDefeat2
	call Cutscene_WriteTextBank04
	ld   hl, TextC_CutsceneMrKarateDefeat3
	call Cutscene_WriteTextBank07
	ld   hl, TextC_CutsceneMrKarateDefeat4
	call Cutscene_WriteTextBank07
	ld   hl, TextC_CutsceneMrKarateDefeat5
	call Cutscene_WriteTextBank07
	ld   hl, TextC_CutsceneMrKarateDefeat6
	call Cutscene_WriteTextBank07
	ld   hl, TextC_CutsceneMrKarateDefeat7
	call Cutscene_WriteTextBank07
	ld   hl, TextC_CutsceneMrKarateDefeat8
	call Cutscene_WriteTextBank07
ENDC
	jp   Cutscene_End
	
; =============== Cutscene_SharedInit ===============
; Initialization code common between all cutscenes.
Cutscene_SharedInit:
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_OBJSIZE|LCDC_WENABLE|LCDC_WTILEMAP|LCDC_ENABLE
	rst  $18				; Resume LCD
	;-----------------------------------
	ei
	; Reset all palettes
	ld   a, $FF
	ldh  [rBGP], a
	ldh  [rOBP0], a
	ldh  [rOBP1], a
	ldh  [hScreenSect0BGP], a
	ldh  [hScreenSect1BGP], a
	ldh  [hScreenSect2BGP], a
	; Wait frame show the changes
	call Task_PassControl_NoDelay
	di
	;-----------------------------------
	rst  $10				; Stop LCD
	
	; Cutscenes aren't gameplay
	ld   hl, wMisc_C028
	res  MISCB_PL_RANGE_CHECK, [hl]
	
	; Reuse the SGB palette from the Intro, which is also visually setup in screen sections like cutscenes
	ld   de, SCRPAL_INTRO
	call HomeCall_SGB_ApplyScreenPalSet
	
	; Clear the tilemap
	call ClearBGMap
	call ClearWINDOWMap
	
	; Reset screen scroll to top left
	xor  a
	ldh  [hScrollX], a
	ldh  [hScrollY], a
	ld   [wOBJScrollX], a
	ld   [wOBJScrollY], a
	
	; Load standard font
	call LoadGFX_1bppFont_Default
	
	; Delete all sprites
	call ClearOBJInfo
	
	; Move the WINDOW layer on the bottom of the screen, exactly where the text should start.
	; Because of how screen sections enable/disable the WINDOW layer, the value of rWY should 
	; match what's passed to SetSectLYC.
	; The actual call to SetSectLYC is done after the subroutine returns, by the code which calls this,
	; since while the third sector always starts at $5C, the top/center ones have variable height.
	ld   a, $5C		; This is the same value
	ldh  [rWY], a
IF REV_LANG_EN == 0
	ld   a, $0F
ELSE
	ld   a, $07
ENDC
	ldh  [rWX], a
	ret
	
; =============== SubModule_Credits ===============
; Displays the credits, shared across all difficulties.
; IN
; - D: If set, starts playing the credits music. [English-only]
SubModule_Credits:
	di
IF REV_VER_2 == 1
	push de		; Save D
ENDC
		;-----------------------------------
		rst  $10				; Stop LCD
		
		; We're not in gameplay
		ld   hl, wMisc_C028
		res  MISCB_PL_RANGE_CHECK, [hl]
		
		; Clear DMG palettes
		xor  a
		ldh  [rBGP], a
		ldh  [rOBP0], a
		ldh  [rOBP1], a
		
IF REV_VER_2 == 0
		; Not necessary, since only B&W text is being displayed
		ld   de, SCRPAL_INTRO
		call HomeCall_SGB_ApplyScreenPalSet
ENDC
		; Clear tilemaps
		call ClearBGMap
		call ClearWINDOWMap
		
		; Reset scrolling to top left
		xor  a
		ldh  [hScrollX], a
		ldh  [hScrollY], a
		ld   [wOBJScrollX], a
		ld   [wOBJScrollY], a
		
IF REV_VER_2 == 0		
		; Load standard font (not necessary, the cutscene already loaded it)
		call LoadGFX_1bppFont_Default
ENDC

		; Delete all sprite mappings
		call ClearOBJInfo

		; Disable sectors
		ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_OBJSIZE|LCDC_WTILEMAP|LCDC_ENABLE
		rst  $18				; Resume LCD
		;-----------------------------------
		ei
		
		; Wait start of next frame before setting palettes, to avoid tearing
		call Task_PassControl_NoDelay
		
		; Set actual DMG pals
		ld   a, $3F
		ldh  [rOBP0], a
		ld   a, $00
		ldh  [rOBP1], a
		ld   a, $1B
		ldh  [rBGP], a
	
IF REV_VER_2 == 1
	pop  de
	
	; The English version of the game can play the credits music during some cutscenes.
	; Those cutscenes transition here, so if we're told that the music is already playing,
	; don't restart it.
	ld   a, d		
	cp   $00			; D == 0? (music already playing)
	jp   z, .showText	; If so, skip	
ENDC
	ld   a, BGM_RISINGRED
	call HomeCall_Sound_ReqPlayExId_Stub
	
.showText:
	;
	; Print all screens of text in one go.
	; When all text for a screen is printed, wait for a bit before continuing.
	;
	
	; 0
	ld   hl, TextDef_Credits0_0
	call TextPrinter_Instant
	ld   b, $04
	call Cutscene_ClearBG_Delay1D8
	
	; 1
	ld   hl, TextDef_Credits1_0
	call TextPrinter_Instant
	ld   hl, TextDef_Credits1_1
	call TextPrinter_Instant
	ld   b, $08
	call Cutscene_ClearBG_Delay1D8
	
	; 2
	ld   hl, TextDef_Credits2_0
	call TextPrinter_Instant
	ld   hl, TextDef_Credits2_1
	call TextPrinter_Instant
	ld   hl, TextDef_Credits2_2
	call TextPrinter_Instant
	ld   hl, TextDef_Credits2_3
	call TextPrinter_Instant
	ld   b, $08
	call Cutscene_ClearBG_Delay1D8
	
	; 3
	ld   hl, TextDef_Credits3_0
	call TextPrinter_Instant
	ld   hl, TextDef_Credits3_1
	call TextPrinter_Instant
	ld   b, $08
	call Cutscene_ClearBG_Delay1D8
	
	; 4
	ld   hl, TextDef_Credits4_0
	call TextPrinter_Instant
	ld   hl, TextDef_Credits4_1
	call TextPrinter_Instant
	ld   hl, TextDef_Credits4_2
	call TextPrinter_Instant
IF REV_LANG_EN == 1
	; A.TUYUKI got added to ARRANGEMENT, shifting down the 2nd row
	ld   hl, TextDef_Credits4_3
	call TextPrinter_Instant
ENDC
	ld   b, $08
	call Cutscene_ClearBG_Delay1D8
	
	; 5
	ld   hl, TextDef_Credits5_0
	call TextPrinter_Instant
	ld   hl, TextDef_Credits5_1
	call TextPrinter_Instant
	ld   hl, TextDef_Credits5_2
	call TextPrinter_Instant
	ld   b, $08
	call Cutscene_ClearBG_Delay1D8
	
	; 6
	ld   hl, TextDef_Credits6_0
	call TextPrinter_Instant
	ld   hl, TextDef_Credits6_1
	call TextPrinter_Instant
	ld   hl, TextDef_Credits6_2
	call TextPrinter_Instant
	ld   hl, TextDef_Credits6_3
	call TextPrinter_Instant
	ld   b, $08
	call Cutscene_ClearBG_Delay1D8
	
	; 7
	ld   hl, TextDef_Credits7_0
	call TextPrinter_Instant
	ld   hl, TextDef_Credits7_1
	call TextPrinter_Instant
	ld   b, $08
	call Cutscene_ClearBG_Delay1D8
	
	; 8
	ld   hl, TextDef_Credits8_0
	call TextPrinter_Instant
	ld   hl, TextDef_Credits8_1
	call TextPrinter_Instant
	ld   hl, TextDef_Credits8_2
	call TextPrinter_Instant
	ld   b, $08
	call Cutscene_ClearBG_Delay1D8
	
	; 9
	ld   hl, TextDef_Credits9_0
	call TextPrinter_Instant
	ld   hl, TextDef_Credits9_1
	call TextPrinter_Instant
	ld   hl, TextDef_Credits9_2
	call TextPrinter_Instant
	ld   hl, TextDef_Credits9_3
	call TextPrinter_Instant
	ld   b, $08
	call Cutscene_ClearBG_Delay1D8
	
	; A
	ld   hl, TextDef_CreditsA_0
	call TextPrinter_Instant
	ld   hl, TextDef_CreditsA_1
	call TextPrinter_Instant
	ld   hl, TextDef_CreditsA_2
	call TextPrinter_Instant
	ld   hl, TextDef_CreditsA_3
	call TextPrinter_Instant
	ld   hl, TextDef_CreditsA_4
	call TextPrinter_Instant
	ld   hl, TextDef_CreditsA_5
	call TextPrinter_Instant
	ld   hl, TextDef_CreditsA_6
	call TextPrinter_Instant
	ld   hl, TextDef_CreditsA_7
	call TextPrinter_Instant
	ld   hl, TextDef_CreditsA_8
	call TextPrinter_Instant
	ld   hl, TextDef_CreditsA_9
	call TextPrinter_Instant
	ld   hl, TextDef_CreditsA_A
	call TextPrinter_Instant
	ld   hl, TextDef_CreditsA_B
	call TextPrinter_Instant
	ld   hl, TextDef_CreditsA_C
	call TextPrinter_Instant
	ld   hl, TextDef_CreditsA_D
	call TextPrinter_Instant
	ld   hl, TextDef_CreditsA_E
	call TextPrinter_Instant
	ld   b, $08
	call Cutscene_ClearBG_Delay1D8
	
	; B
	ld   hl, TextDef_CreditsB_0
	call TextPrinter_Instant
	ld   hl, TextDef_CreditsB_1
	call TextPrinter_Instant
	ld   b, $08
	call Cutscene_ClearBG_Delay1D8
	
	; C
	ld   hl, TextDef_CreditsC_0
	call TextPrinter_Instant
	ld   hl, TextDef_CreditsC_1
	call TextPrinter_Instant
IF REV_LANG_EN == 0
	; PRESENTED BY TAKARA is in two lines in the English version
	ld   hl, TextDef_CreditsC_2
	call TextPrinter_Instant
ENDC
	ld   b, $08
	call Cutscene_ClearBG_Delay1D8
	
	ret
	
; =============== SubModule_TheEnd ===============
; Displays "THE END" on the screen.
SubModule_TheEnd:

	;
	; Initialization code almost identical to SubModule_Credits, only difference
	; is that it doesn't set a SGB palette.
	;
	di
	;-----------------------------------
	rst  $10				; Stop LCD
	
	; We're not in gameplay
	ld   hl, wMisc_C028
	res  MISCB_PL_RANGE_CHECK, [hl]
	
	; Clear DMG palettes
	xor  a
	ldh  [rBGP], a
	ldh  [rOBP0], a
	ldh  [rOBP1], a
	
	; Clear tilemaps
	call ClearBGMap
	call ClearWINDOWMap
	
	; Reset scrolling to top left
	xor  a
	ldh  [hScrollX], a
	ldh  [hScrollY], a
	ld   [wOBJScrollX], a
	ld   [wOBJScrollY], a
	
IF REV_VER_2 == 0		
	; Load standard font (not necessary, the credits already loaded it)
	call LoadGFX_1bppFont_Default
ENDC
	
	; Delete all sprite mappings
	call ClearOBJInfo

	; Disable sectors
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_OBJSIZE|LCDC_WTILEMAP|LCDC_ENABLE
	rst  $18				; Resume LCD
	;-----------------------------------
	ei
	
	; Wait start of next frame before setting palettes, to avoid tearing
	call Task_PassControl_NoDelay
	
	; Set actual DMG pals
	ld   a, $3F
	ldh  [rOBP0], a
	ld   a, $00
	ldh  [rOBP1], a
	ld   a, $1B
	ldh  [rBGP], a
	
	; THE END
	ld   hl, TextDef_TheEnd
	call TextPrinter_Instant
	
	; Stop all sound
	ld   a, SND_MUTE
	call HomeCall_Sound_ReqPlayExId_Stub
	
	; Wait 590 frames before returning
	ld   b, $0A
.loop:
	call Task_PassControl_Delay3B
	dec  b
	jp   nz, .loop
	
	jp   ClearBGMap
	
; =============== Cutscene_PostTextWrite ===============
; Shared code executed after text finishes writing for a cutscene.
; This delays the cutscene from continuing, while handling animations,
; until the timer elapses or START is pressed.
; IN
; - B: Max number of frames to wait
; OUT
; - C flag: If set, it was aborted early
Cutscene_PostTextWrite:
	
	;
	; These are the two subroutines that were previously used by wTextPrintFrameCodePtr
	; to be executed while printing text. Their effect should also continue here.
	;
	; Even though only one effect can be active at a time when printing text, this
	; subroutine is shared, so it had to call both of them.
	; This is partially why there are flags to enable each individual effect, it's
	; to avoid having them both execute here.
	; 
	call Cutscene_MoveLargeChars
	call Cutscene_FlashBGPal
	
	; Check early abort
	call Cutscene_IsStartPressed	; Did anyone press START?
	jr   nc, .contWait				; If not, jump
.abort:
	; Wait frame, this also preserves C flag
	call Task_PassControl_NoDelay
	ret		; C flag set
.contWait:
	; Wait frame
	call Task_PassControl_NoDelay
	dec  b							; Are we done?
	jp   nz, Cutscene_PostTextWrite	; If not, loop
.end:
	xor  a	; C flag clear
	ret
	
; =============== Cutscene_ClearBG_Delay1D8 ===============
; Waits for $1D8 frames and then clears the BG tilemap, which clears the middle section.
Cutscene_ClearBG_Delay1D8:
	ld   b, $08	; For 8 times...
.loop:
	; Wait $3B frames
	call Task_PassControl_Delay3B
	dec  b
	jp   nz, .loop
	; Clear middle section (Goenitz, characters)
	call ClearBGMap
	ret
	
	
; =============== Cutscene_IsStartPressed ===============
; Checks if any player pressed START.
; Identical to Win_IsStartPressed.
; OUT
; - C flag: If set, someone did
Cutscene_IsStartPressed:
	; If any player presses START, return set
	ldh  a, [hJoyNewKeys]
	bit  KEYB_START, a
	jp   nz, .abort
	ldh  a, [hJoyNewKeys2]
	bit  KEYB_START, a
	jp   nz, .abort
	; Otherwise, return clear
	xor  a
	ret
.abort:
	scf
	ret

IF REV_LANG_EN == 0
TextDef_Credits0_0:
	dw $9906
	db .end-.start
.start:
	db "-STAFF-"
.end:
TextDef_Credits1_0:
	dw $98C0
	db .end-.start
.start:
	db "-EXECUTIVE PRODUCER-"
.end:
TextDef_Credits1_1:
	dw $9943
	db .end-.start
.start:
	db "HIROHISA SATOH"
.end:
TextDef_Credits2_0:
	dw $98A5
	db .end-.start
.start:
	db "-PRODUCER-"
.end:
TextDef_Credits2_1:
	dw $9901
	db .end-.start
.start:
	db "MASAHIRO MORIKAWA"
.end:
TextDef_Credits2_2:
	dw $9942
	db .end-.start
.start:
	db "TAKAYUKI NAKANO"
.end:
TextDef_Credits2_3:
	dw $9985
	db .end-.start
.start:
	db "T.ISHIGAI"
.end:
TextDef_Credits3_0:
	dw $98C5
	db .end-.start
.start:
	db "-DIRECTOR-"
.end:
TextDef_Credits3_1:
	dw $9921
	db .end-.start
.start:
	db "HIROFUMI KASAKAWA"
.end:
TextDef_Credits4_0:
	dw $98C3
	db .end-.start
.start:
	db "-ARRANGEMENT-"
.end:
TextDef_Credits4_1:
	dw $9925
	db .end-.start
.start:
	db "T.SAITOH"
.end:
TextDef_Credits4_2:
	dw $9965
	db .end-.start
.start:
	db "H.KOISO"
.end:
TextDef_Credits5_0:
	dw $98C4
	db .end-.start
.start:
	db "-PROGRAMMER-"
.end:
TextDef_Credits5_1:
	dw $9926
	db .end-.start
.start:
	db "H.KOISO"
.end:
TextDef_Credits5_2:
	dw $9965
	db .end-.start
.start:
	db "T.ISHIGAI"
.end:
TextDef_Credits6_0:
	dw $98A5
	db .end-.start
.start:
	db "-DESIGNER-"
.end:
TextDef_Credits6_1:
	dw $9906
	db .end-.start
.start:
	db "T.SAITOU"
.end:
TextDef_Credits6_2:
	dw $9946
	db .end-.start
.start:
	db "A.TUYUKI"
.end:
TextDef_Credits6_3:
	dw $9986
	db .end-.start
.start:
	db "A.HANDA"
.end:
TextDef_Credits7_0:
	dw $98C5
	db .end-.start
.start:
	db "MUSIC BY"
.end:
TextDef_Credits7_1:
	dw $9921
	db .end-.start
.start:
	db "STUDIO PJ CO.,LTD"
.end:
TextDef_Credits9_0:
	dw $98A1
	db .end-.start
.start:
	db "-SUPER MARKETTER-"
.end:
TextDef_Credits9_1:
	dw $9902
	db .end-.start
.start:
	db "TOSHIHIRO MORIOKA"
.end:
TextDef_Credits9_2:
	dw $9942
	db .end-.start
.start:
	db "KATUYA TORIHAMA"
.end:
TextDef_Credits9_3:
	dw $9982
	db .end-.start
.start:
	db "MASAHIRO IWASAKI"
.end:
TextDef_Credits8_0:
	dw $98C2
	db .end-.start
.start:
	db "-ARTWORK DESIGN-"
.end:
TextDef_Credits8_1:
	dw $9923
	db .end-.start
.start:
	db "DESIGN OFFICE"
.end:
TextDef_Credits8_2:
	dw $9963
	db .end-.start
.start:
	db "SPACE LAP INC."
.end:
TextDef_CreditsB_0:
	dw $98A3
	db .end-.start
.start:
	db "SPECIAL THANKS"
.end:
TextDef_CreditsB_1:
	dw $9923
	db .end-.start
.start:
	db "SNK ALL STAFF"
.end:
TextDef_CreditsC_0:
	dw $98E6
	db .end-.start
.start:
	db "PRESENTED"
.end:
TextDef_CreditsC_1:
	dw $9949
	db .end-.start
.start:
	db "BY"
.end:
TextDef_CreditsC_2:
	dw $9987
	db .end-.start
.start:
	db "TAKARA"
.end:
TextDef_CreditsA_0:
	dw $9821
	db .end-.start
.start:
	db "-SPECIAL THANKS-"
.end:
TextDef_CreditsA_1:
	dw $9862
	db .end-.start
.start:
	db "TATUYA HOCHO"
.end:
TextDef_CreditsA_2:
	dw $9882
	db .end-.start
.start:
	db "SHUNICHI OHKUSA"
.end:
TextDef_CreditsA_3:
	dw $98A2
	db .end-.start
.start:
	db "TAKESHI IKENOUE"
.end:
TextDef_CreditsA_4:
	dw $98C2
	db .end-.start
.start:
	db "NAOYUKI TAKADA"
.end:
TextDef_CreditsA_5:
	dw $98E2
	db .end-.start
.start:
	db "AKIHIKO KIMURA"
.end:
TextDef_CreditsA_6:
	dw $9902
	db .end-.start
.start:
	db "NORIHIRO HAYASAKA"
.end:
TextDef_CreditsA_7:
	dw $9922
	db .end-.start
.start:
	db "S.H"
.end:
TextDef_CreditsA_8:
	dw $9942
	db .end-.start
.start:
	db "MITSUNORI SHOJI"
.end:
TextDef_CreditsA_9:
	dw $9962
	db .end-.start
.start:
	db "FUMIHIKO OZAWA"
.end:
TextDef_CreditsA_A:
	dw $9982
	db .end-.start
.start:
	db "SATOSHI KUMATA"
.end:
TextDef_CreditsA_B:
	dw $99A2
	db .end-.start
.start:
	db "TATSUYA YAURA"
.end:
TextDef_CreditsA_C:
	dw $99C2
	db .end-.start
.start:
	db "TETSUYA IIDA"
.end:
TextDef_CreditsA_D:
	dw $99E2
	db .end-.start
.start:
	db "TAKAO SATOU"
.end:
TextDef_CreditsA_E:
	dw $9A02
	db .end-.start
.start:
	db "MUTSUMI NAKAMURA"
.end:
TextDef_TheEnd:
	dw $9906
	db .end-.start
.start:
	db "THE  END"
.end:	
	
; Text scattered to the four winds in the English version
TextC_Ending_SacredTreasures00:
	db .end-.start
.start:
	db "これほとﾞとは・・・。", C_NL
	db C_NL
	db "しかし、これてﾞおしまいてﾞは", C_NL
	db C_NL
	db "あリません。", C_NL
.end:
TextC_Ending_SacredTreasures01:
	db .end-.start
.start:
	db "ちぃっ!", C_NL
.end:
TextC_Ending_SacredTreasures02:
	db .end-.start
.start:
	db "くらいやかﾞれええいっ!", C_NL
.end:
TextC_Ending_SacredTreasures03:
	db .end-.start
.start:
	db "くﾞあああああっ!", C_NL
.end:
TextC_Ending_SacredTreasures04:
	db .end-.start
.start:
	db "なせﾞたﾞ!? なせﾞあかい・・・?", C_NL
	db C_NL
	db "おれのほのうかﾞあかいわけかﾞない!", C_NL
.end:
TextC_Ending_SacredTreasures05:
	db .end-.start
.start:
	db "はらうもの、くさなきﾞ", C_NL
	db C_NL
	db "ふうすﾞるもの、やかﾞみ。", C_NL
.end:
TextC_Ending_SacredTreasures06:
	db .end-.start
.start:
	db "あななたちはいま1800ねんのときを", C_NL
	db C_NL
	db "なそﾞらえたのよ。", C_NL
.end:
TextC_Ending_SacredTreasures07:
	db .end-.start
.start:
	db "オロチはやかﾞみのあかいほのうてﾞ", C_NL
	db C_NL
	db "ふうしﾞられ、くさなきﾞによって", C_NL
	db C_NL
	db "なきﾞはらわれた。", C_NL
.end:
TextC_Ending_SacredTreasures08:
	db .end-.start
.start:
	db "やかﾞみのあかきほのうは、あなたかﾞ", C_NL
	db C_NL
	db "もつひとのふﾞふﾞんのほんのうかﾞ", C_NL
	db C_NL
	db "うみたﾞしたものよ。", C_NL
.end:
TextC_Ending_SacredTreasures09:
	db .end-.start
.start:
	db "あなたかﾞあやつるあおきほのう。", C_NL
	db C_NL
	db "それはあなたになかﾞれるオロチの", C_NL
	db C_NL
	db "ちからうまれるもの・・・。", C_NL
.end:
TextC_Ending_SacredTreasures0A:
	db .end-.start
.start:
	db "あなたのいちそﾞくかﾞ", C_NL
	db C_NL
	db "たﾞいたﾞいたんめいなのは、", C_NL
	db C_NL
	db "そのオロチのちのせいよ。", C_NL
.end:
TextC_Ending_SacredTreasures0B:
	db .end-.start
.start:
	db "このままそのちからをつかい", C_NL
	db C_NL
	db "つつﾞけれはﾞやかﾞみ、", C_NL
	db C_NL
	db "あなたもいすﾞれ・・・。", C_NL
.end:
TextC_Ending_SacredTreasures0C:
	db .end-.start
.start:
	db "くたﾞらないことを・・・。", C_NL
	db C_NL
	db "なんたﾞ?・・・な、なにもみえん!?", C_NL
	db C_NL
	db "く、くﾞふっ!!", C_NL
.end:
TextC_Ending_SacredTreasures0D:
	db .end-.start
.start:
	db "とﾞうした、やかﾞみ・・・!", C_NL
.end:
TextC_Ending_SacredTreasures0E:
	db .end-.start
.start:
	db "まさか・・・ちの・・・ほﾞうそう!?", C_NL
.end:
TextC_Ending_SacredTreasures0F:
	db .end-.start
.start:
	db "くﾞうおおおううう!!", C_NL
.end:
TextC_EndingPost_Boss0:
	db .end-.start
.start:
	db "オロチ・・・。", C_NL
	db C_NL
	db "くちほとﾞにもなかったな。", C_NL
.end:
TextC_EndingPost_Boss1:
	db .end-.start
.start:
	db "GEESE!!", C_NL
	db C_NL
	db "きさま、とﾞういうつもリたﾞ!", C_NL
.end:
TextC_EndingPost_Boss2:
	db .end-.start
.start:
	db "なんたﾞ!?", C_NL
.end:
TextC_EndingPost_Boss3:
	db .end-.start
.start:
	db "みょうなトｰナメントにひっはﾟリ", C_NL
	db C_NL
	db "こまれるは、てこﾞまにされるわ。", C_NL
	db C_NL
	db "いすﾞれかならすﾞけリをつける。", C_NL
	db C_NL
.end:
TextC_EndingPost_Boss4:
	db .end-.start
.start:
	db "いすﾞれてﾞはなく、いま", C_NL
	db C_NL
	db "けリをつけようてﾞはないか。", C_NL
.end:
TextC_EndingPost_Boss5:
	db .end-.start
.start:
	db "ふっふっふ! よかろう。", C_NL
.end:
TextC_Ending_OLeona0:
	db .end-.start
.start:
	db "おとﾞろきてﾞすね。これほとﾞ", C_NL
	db C_NL
	db "まてﾞとは。 8ねんまえのことは", C_NL
	db C_NL
	db "おほﾞえていますか・・・。", C_NL
.end:
TextC_Ending_OLeona1:
	db .end-.start
.start:
	db "・・・!?  まさか・・・?", C_NL
	db C_NL
	db "わたしのかそﾞくをころしたのは。", C_NL
.end:
TextC_Ending_OLeona2:
	db .end-.start
.start:
	db "かんちかﾞいされてはこまリますね。", C_NL
	db C_NL
	db "・・・あなたなのてﾞすよ。", C_NL
	db C_NL
	db "しﾞふﾞんのかそﾞくをころしたのは。", C_NL
.end:
TextC_Ending_OLeona3:
	db .end-.start
.start:
	db "!・・・うそ・・・・・・。", C_NL
.end:
TextC_Ending_OLeona4:
	db .end-.start
.start:
	db "うそてﾞはあリません。", C_NL
	db C_NL
	db "あなたのからたﾞにはオロチのち", C_NL
	db C_NL
	db "かﾞなかﾞれているのてﾞす。", C_NL
.end:
TextC_Ending_OLeona5:
	db .end-.start
.start:
	db "てみやけﾞに8ねんまえとおなしﾞ", C_NL
	db C_NL
	db "ようにめさﾞめさせてあけﾞましょう。", C_NL
.end:
TextC_Ending_OLeona6:
	db .end-.start
.start:
	db "ふふふ・・・。", C_NL
	db C_NL
	db "いいかせﾞかﾞきましたね。", C_NL
	db C_NL
	db "そろそろころあいてﾞす。", C_NL
.end:
TextC_Ending_OLeona8:
	db .end-.start
.start:
	db "な、なに?", C_NL
	db C_NL
	db "・・・なにもみえない・・・!", C_NL
.end:
TextC_Ending_OLeona9:
	db .end-.start
.start:
	db "とﾞうした? LEONA・・・!", C_NL
	db C_NL
	db "まさか、オロチの・・・。", C_NL
.end:
TextC_CutsceneMrKarate0:
	db .end-.start
.start:
	db "はっはっは!", C_NL
	db C_NL
	db "てﾞんせつのかくとうか!", C_NL
	db C_NL
	db "MR.KARATEさんしﾞょう!", C_NL
.end:
TextC_CutsceneMrKarate1:
	db .end-.start
.start:
	db "わしは、おまえたちのたたかいを", C_NL
	db C_NL
	db "つねにみてきた。 さすかﾞゆうしょう", C_NL
	db C_NL
	db "したたﾞけのことはある。", C_NL
.end:
TextC_CutsceneMrKarate2:
	db .end-.start
.start:
	db "たﾞかﾞ、またﾞまたﾞみしﾞゅく!", C_NL
	db C_NL
	db "わしかﾞ、けいこをつけてやろう!!", C_NL
	db C_NL
	db "てﾞは、いくそﾞ!!!", C_NL
.end:
TextC_CutsceneMrKarateDefeat0:
	db .end-.start
.start:
	db "むむ・・・なかなかやリおる。", C_NL
	db C_NL
	db "せﾞんたいかいよリ、いちたﾞんと", C_NL
	db C_NL
	db "つよくなったな・・・。", C_NL
.end:
TextC_CutsceneMrKarateDefeat1:
	db .end-.start
.start:
	db "せﾞんたいかい・・・?", C_NL
	db C_NL
	db "やはリ、あなたは・・・?", C_NL
.end:
TextC_CutsceneMrKarateDefeat2:
	db .end-.start
.start:
	db "ちかﾞうっ! たﾞんしﾞてちかﾞう!", C_NL
	db C_NL
	db "わしはてﾞんせつのかくとうか、", C_NL
	db C_NL
	db "MR.KARATE!", C_NL
.end:
TextC_CutsceneMrKarateDefeat3:
	db .end-.start
.start:
	db "たくまてﾞはない・・・!", C_NL
.end:
TextC_CutsceneMrKarateDefeat4:
	db .end-.start
.start:
	db "や、やはリ・・・。", C_NL
.end:
; [TCRF] Unused text, obvious purpose considering where it's placed.
TextC_CutsceneMrKarateDefeat_Unused_0:
	db .end-.start
.start:
	db "きょうのところはここまてﾞに", C_NL
	db C_NL
	db "しておいてやろう。", C_NL
	db C_NL
	db "また、あおう!!", C_NL
.end:
TextC_CutsceneMrKarateDefeat5:
	db .end-.start
.start:
	db "もうすこしてﾞ、しょうたいかﾞ", C_NL
	db C_NL
	db "はﾞれるところてﾞあった・・・。", C_NL
.end:
TextC_CutsceneMrKarateDefeat6:
	db .end-.start
.start:
	db "こんとﾞはわしもたいかいに", C_NL
	db C_NL
	db "さんかするそﾞ。", C_NL
.end:
TextC_CutsceneMrKarateDefeat7:
	db .end-.start
.start:
	db "TAKARAロコﾞのひょうしﾞ", C_NL
	db C_NL
	db "ちゅうにSELECTホﾞタン", C_NL
	db C_NL
	db "を20かいおす。", C_NL
.end:
TextC_CutsceneMrKarateDefeat8:
	db .end-.start
.start:
	db "SELECTかﾞめんてﾞわしを", C_NL
	db C_NL
	db "えらんてﾞ、さいきょうを", C_NL
	db C_NL
	db "めさﾞすのたﾞ。", C_NL
.end:
TextC_EndingPost_FFGeese0:
	db .end-.start
.start:
	db "ここまてﾞきたら、", C_NL
	db C_NL
	db "きさまらにようはない。", C_NL
.end:
TextC_EndingPost_FFGeese1:
	db .end-.start
.start:
	db "GEESE!", C_NL
	db C_NL
	db "こんとﾞこそけリをつけてやるせﾞ!!", C_NL
.end:
TextC_EndingPost_AOFMrBig0:
	db .end-.start
.start:
	db "RYO、ROBERT、", C_NL
	db C_NL
	db "かリはかえさせてもらうせﾞ。", C_NL
.end:
TextC_EndingPost_AOFMrBig1:
	db .end-.start
.start:
	db "のそﾞむところたﾞ!", C_NL
.end:
TextC_EndingPost_KTR0:
	db .end-.start
.start:
	db "ゆうしょうはもらった。", C_NL
	db C_NL
	db "しゅやくはおれたﾞ!", C_NL
	db C_NL
	db "けっちゃくをつけようせﾞ!", C_NL
	db C_NL
.end:

ELSE

TextDef_Credits0_0:
	dw $9906
	db .end-.start
.start:
	db "-STAFF-"
.end:
TextDef_Credits1_0:
	dw $98C0
	db .end-.start
.start:
	db "-EXECUTIVE PRODUCER-"
.end:
TextDef_Credits1_1:
	dw $9943
	db .end-.start
.start:
	db "HIROHISA SATOH"
.end:
TextDef_Credits2_0:
	dw $98A5
	db .end-.start
.start:
	db "-PRODUCER-"
.end:
TextDef_Credits2_1:
	dw $9901
	db .end-.start
.start:
	db "MASAHIRO MORIKAWA"
.end:
TextDef_Credits2_2:
	dw $9942
	db .end-.start
.start:
	db "TAKAYUKI NAKANO"
.end:
TextDef_Credits2_3:
	dw $9985
	db .end-.start
.start:
	db "T.ISHIGAI"
.end:
TextDef_Credits3_0:
	dw $98C5
	db .end-.start
.start:
	db "-DIRECTOR-"
.end:
TextDef_Credits3_1:
	dw $9921
	db .end-.start
.start:
	db "HIROFUMI KASAKAWA"
.end:
TextDef_Credits4_0:
	dw $98A3
	db .end-.start
.start:
	db "-ARRANGEMENT-"
.end:
TextDef_Credits4_1:
	dw $9905
	db .end-.start
.start:
	db "T.SAITOU"
.end:
TextDef_Credits4_2:
	dw $9945
	db .end-.start
.start:
	db "A.TUYUKI"
.end:
TextDef_Credits4_3:
	dw $9985
	db .end-.start
.start:
	db "H.KOISO"
.end:
TextDef_Credits5_0:
	dw $98C4
	db .end-.start
.start:
	db "-PROGRAMMER-"
.end:
TextDef_Credits5_1:
	dw $9926
	db .end-.start
.start:
	db "H.KOISO"
.end:
TextDef_Credits5_2:
	dw $9965
	db .end-.start
.start:
	db "T.ISHIGAI"
.end:
TextDef_Credits6_0:
	dw $98A5
	db .end-.start
.start:
	db "-DESIGNER-"
.end:
TextDef_Credits6_1:
	dw $9906
	db .end-.start
.start:
	db "T.SAITOU"
.end:
TextDef_Credits6_2:
	dw $9946
	db .end-.start
.start:
	db "A.TUYUKI"
.end:
TextDef_Credits6_3:
	dw $9986
	db .end-.start
.start:
	db "A.HANDA"
.end:
TextDef_Credits7_0:
	dw $98C6
	db .end-.start
.start:
	db "MUSIC BY"
.end:
TextDef_Credits7_1:
	dw $9921
	db .end-.start
.start:
	db "STUDIO PJ CO.,LTD"
.end:
TextDef_Credits9_0:
	dw $98A1
	db .end-.start
.start:
	db "-SUPER MARKETTER-"
.end:
TextDef_Credits9_1:
	dw $9902
	db .end-.start
.start:
	db "TOSHIHIRO MORIOKA"
.end:
TextDef_Credits9_2:
	dw $9942
	db .end-.start
.start:
	db "KATUYA TORIHAMA"
.end:
TextDef_Credits9_3:
	dw $9982
	db .end-.start
.start:
	db "MASAHIRO IWASAKI"
.end:
TextDef_Credits8_0:
	dw $98C2
	db .end-.start
.start:
	db "-ARTWORK DESIGN-"
.end:
TextDef_Credits8_1:
	dw $9923
	db .end-.start
.start:
	db "DESIGN OFFICE"
.end:
TextDef_Credits8_2:
	dw $9963
	db .end-.start
.start:
	db "SPACE LAP INC."
.end:
TextDef_CreditsB_0:
	dw $98A3
	db .end-.start
.start:
	db "SPECIAL THANKS"
.end:
TextDef_CreditsB_1:
	dw $9923
	db .end-.start
.start:
	db "SNK ALL STAFF"
.end:
TextDef_CreditsC_0:
	dw $98E4
	db .end-.start
.start:
	db "PRESENTED BY"
.end:
TextDef_CreditsC_1:
	dw $9947
	db .end-.start
.start:
	db "TAKARA"
.end:
TextDef_CreditsA_0:
	dw $9822
	db .end-.start
.start:
	db "-SPECIAL THANKS-"
.end:
TextDef_CreditsA_1:
	dw $9864
	db .end-.start
.start:
	db "TATUYA HOCHO"
.end:
TextDef_CreditsA_2:
	dw $9882
	db .end-.start
.start:
	db "SHUNICHI OHKUSA"
.end:
TextDef_CreditsA_3:
	dw $98A3
	db .end-.start
.start:
	db "TAKESHI IKENOUE"
.end:
TextDef_CreditsA_4:
	dw $98C3
	db .end-.start
.start:
	db "NAOYUKI TAKADA"
.end:
TextDef_CreditsA_5:
	dw $98E3
	db .end-.start
.start:
	db "AKIHIKO KIMURA"
.end:
TextDef_CreditsA_6:
	dw $9902
	db .end-.start
.start:
	db "NORIHIRO HAYASAKA"
.end:
TextDef_CreditsA_7:
	dw $9929
	db .end-.start
.start:
	db "S.H"
.end:
TextDef_CreditsA_8:
	dw $9941
	db .end-.start
.start:
	db "MITSUNORI SHOJI"
.end:
TextDef_CreditsA_9:
	dw $9962
	db .end-.start
.start:
	db "FUMIHIKO OZAWA"
.end:
TextDef_CreditsA_A:
	dw $9983
	db .end-.start
.start:
	db "SATOSHI KUMATA"
.end:
TextDef_CreditsA_B:
	dw $99A3
	db .end-.start
.start:
	db "TATSUYA YAURA"
.end:
TextDef_CreditsA_C:
	dw $99C3
	db .end-.start
.start:
	db "TETSUYA IIDA"
.end:
TextDef_CreditsA_D:
	dw $99E5
	db .end-.start
.start:
	db "TAKAO SATOU"
.end:
TextDef_CreditsA_E:
	dw $9A03
	db .end-.start
.start:
	db "MUTSUMI NAKAMURA"
.end:
TextDef_TheEnd:
	dw $9906
	db .end-.start
.start:
	db "THE  END"
.end:
TextDef_Credits_Unused_Laguna_0:
	dw $98C3
	db .end-.start
.start:
	db "-LAGUNA STAFF-"
.end:
TextDef_Credits_Unused_Laguna_1:
	dw $9924
	db .end-.start
.start:
	db "FRANK GLASER"
.end:
TextC_Ending_SacredTreasures00:
	db .end-.start
.start:
	db "I did not think you", C_NL
	db " were that strong...", C_NL
	db "But it is not yet", C_NL
	db "               over.", C_NL
.end:
TextC_Ending_SacredTreasures01:
	db .end-.start
.start:
	db "(Iori)", C_NL
	db "Ah!", C_NL
.end:
TextC_Ending_SacredTreasures02:
	db .end-.start
.start:
	db "Take that!", C_NL
.end:
TextC_Ending_SacredTreasures03:
	db .end-.start
.start:
	db "Uhhhhoooooo!", C_NL
.end:
TextC_Ending_SacredTreasures04:
	db .end-.start
.start:
	db "Why are", C_NL
	db "     the flames red?", C_NL
	db "They shouldn`t", C_NL
	db "             be red!", C_NL
.end:
TextC_Ending_SacredTreasures05:
	db .end-.start
.start:
	db "(Chizuru)", C_NL
	db "Kusanagi,who cuts", C_NL
	db "     down the enemy.", C_NL
	db "Yagami,who locks", C_NL
	db "          them away.", C_NL
.end:
TextC_Ending_SacredTreasures06:
	db .end-.start
.start:
	db "You experienced", C_NL
	db " 1,800 years in a", C_NL
	db " single second.", C_NL
.end:
TextC_Ending_SacredTreasures07:
	db .end-.start
.start:
	db "The Orochi was", C_NL
	db " sealed up with", C_NL
	db " Yagami`s red flames", C_NL
	db ",and cut down by", C_NL
	db "           Kusanagi.", C_NL
.end:
TextC_Ending_SacredTreasures08:
	db .end-.start
.start:
	db "Yagami,the red", C_NL
	db " flames come from", C_NL
	db " the part of you", C_NL
	db "      that is human.", C_NL
.end:
TextC_Ending_SacredTreasures09:
	db .end-.start
.start:
	db "The blue flames that", C_NL
	db " you control come", C_NL
	db " from the power of", C_NL
	db " the Orochi which", C_NL
	db " flows within you...", C_NL
.end:
TextC_Ending_SacredTreasures0A:
	db .end-.start
.start:
	db "Members of your", C_NL
	db " family have always", C_NL
	db " met untimely deaths", C_NL
	db " through the", C_NL
	db "         generations", C_NL
.end:
TextC_Ending_SacredTreasures0B:
	db .end-.start
.start:
	db " because of the", C_NL
	db "     Orochi`s blood.", C_NL
.end:
TextC_Ending_SacredTreasures0C:
	db .end-.start
.start:
	db "If you continue to", C_NL
	db " use its power,the", C_NL
	db " gods will someday", C_NL
	db "     take you too...", C_NL
.end:
TextC_Ending_SacredTreasures0D:
	db .end-.start
.start:
	db "(Iori)", C_NL
	db "What nonsense", C_NL
	db "          is this...", C_NL
.end:
TextC_Ending_SacredTreasures0E:
	db .end-.start
.start:
	db "What`s going on?!", C_NL
	db C_NL
	db "I can`t see anything!", C_NL
	db C_NL
	db "Aaahhuu!!..", C_NL
.end:
TextC_Ending_SacredTreasures0F:
	db .end-.start
.start:
	db "(Kyo)", C_NL
	db "Yagami!", C_NL
	db "Are you all right?!", C_NL
.end:
TextC_Ending_SacredTreasures10:
	db .end-.start
.start:
	db "(Chizuru)", C_NL
	db "No...", C_NL
	db "Am I becoming...?", C_NL
.end:
TextC_Ending_SacredTreasures11:
	db .end-.start
.start:
	db "(Iori)", C_NL
	db "uuWOOooohhh!!!!", C_NL
.end:
TextC_Ending_OLeona0:
	db .end-.start
.start:
	db "I`m surprised you", C_NL
	db "   made it this far.", C_NL
	db "Do you remember what", C_NL
	db " happened 8 years", C_NL
	db "                ago?", C_NL
.end:
TextC_Ending_OLeona1:
	db .end-.start
.start:
	db "(Leona)", C_NL
	db "...!? It can`t be...", C_NL
	db "The person who", C_NL
	db "   killed my family!", C_NL
.end:
TextC_Ending_OLeona2:
	db .end-.start
.start:
	db "No.", C_NL
	db "I did not kill", C_NL
	db "        your family.", C_NL
	db "You did.", C_NL
.end:
TextC_Ending_OLeona3:
	db .end-.start
.start:
	db "(Leona)", C_NL
	db "Liar!!!", C_NL
.end:
TextC_Ending_OLeona4:
	db .end-.start
.start:
	db "It is the truth.", C_NL
	db "The blood of the", C_NL
	db " Orochi run in your", C_NL
	db "              veins.", C_NL
.end:
TextC_Ending_OLeona5:
	db .end-.start
.start:
	db "Let me remind you of", C_NL
	db " that fact like", C_NL
	db " I did 8 years ago.", C_NL
.end:
TextC_Ending_OLeona6:
	db .end-.start
.start:
	db "Ha,ha,ha...", C_NL
	db "The wind blows...", C_NL
	db "The time is right.", C_NL
.end:
TextC_Ending_OLeona8:
	db .end-.start
.start:
	db "(Leona)", C_NL
	db "W-what?", C_NL
	db "I can`t see", C_NL
	db "         anything!", C_NL
.end:
TextC_Ending_OLeona9:
	db .end-.start
.start:
	db "What`s the matter?", C_NL
	db "It can`t be...", C_NL
	db " the Orochi`s...", C_NL
.end:
ENDC

IF REV_LOGO_EN == 1
; =============== LagunaLogo_LoadVRAM ===============
; Loads the graphics and tilemap for the EU publisher logo.
LagunaLogo_LoadVRAM:
	; Load compressed graphics
	ld   hl, GFXLZ_LagunaLogo
	ld   de, wLZSS_Buffer
	call DecompressLZSS
	ld   hl, wLZSS_Buffer
	ld   de, $9000
	call CopyTiles
	
	; Load 16x6 tilemap
	ld   de, BG_LagunaLogo
	ld   hl, $98C2
	ld   b, $10
	ld   c, $06
	call CopyBGToRect
	ret  

GFXLZ_LagunaLogo: INCBIN "data/gfx/en/lagunalogo.lzc"
BG_LagunaLogo: INCBIN "data/bg/en/lagunalogo.bin"
ENDC

IF REV_VER_2 == 0
; =============== END OF BANK ===============
; Junk area below.
	mIncJunk "L1D7D66"
ELSE
	mIncJunk "L1D7FD8"
ENDC