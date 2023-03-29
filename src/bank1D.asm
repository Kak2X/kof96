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
IF ENGLISH == 0
	db $80 		; Tiles to copy
ELSE
	db $4E 		; Tiles to copy
ENDC
.col:
	db COL_WHITE ; Bit0 color map (background)
	db COL_BLACK ; Bit1 color map (foreground)
	; 1bpp font gfx
.gfx:
IF ENGLISH == 0
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
	; .
	call Win_ResetCharsOnUnusedVsModeCpuVsCpu
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
IF ENGLISH == 1
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
IF ENGLISH == 1
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
IF ENGLISH == 1
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
	call Win_ResetCharsOnUnusedVsModeCpuVsCpu
	;--
.toCharSel:
	jp   Win_SwitchToCharSel
	
; =============== Win_ResetCharsOnUnusedVsModeCpuVsCpu ===============
; [TCRF] In a CPU vs CPU battle in VS mode, force the game to pick new characters for both teams.
Win_ResetCharsOnUnusedVsModeCpuVsCpu:
	; Not applicable if not in VS mode
	ld   a, [wPlayMode]
	bit  MODEB_VS, a
	ret  z
	
	; Not applicable if
	ld   a, [wPlInfo_Pl1+iPlInfo_Flags0]
	ld   b, a								; B = 1P Flags
	ld   a, [wPlInfo_Pl2+iPlInfo_Flags0]	; A = 2P Flags
	and  b									; Merge both
	bit  PF0B_CPU, a						; Are both players CPUs?
	ret  z									; If not, return
	
	; Clear selected team characters
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
	db $04
	db "DRAW"
TextDef_Continue:
	dw $9AE5
	db $0A
	db "CONTINUE 9"
TextDef_ContinueNumSpace:
	dw $9AED
	db $01
	db " "
TextDef_GameOver:
	dw $9AE5
	db $0A
	db "GAME  OVER"

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
IF ENGLISH == 0
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
	
IF ENGLISH == 0
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
	

	
IF ENGLISH == 0

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
	; The English version sets this up differently:
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
	
	; Display the next line of text
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
	
IF ENGLISH == 1
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
	
IF ENGLISH == 1
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
	
IF ENGLISH == 0
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
IF ENGLISH == 0
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
IF ENGLISH == 0
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
	call Task_PassControl_NoDelay
	
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
	
IF ENGLISH == 0
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
	
IF ENGLISH == 1
	; Restart the music
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
IF ENGLISH == 0
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
IF ENGLISH == 0
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
IF ENGLISH == 0
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
IF ENGLISH == 1
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
	
IF ENGLISH == 1
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
	and  a, a
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
IF ENGLISH == 1
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
IF ENGLISH == 0
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
IF ENGLISH == 0
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
IF ENGLISH == 0
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
IF ENGLISH == 0
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
IF ENGLISH == 0
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
IF ENGLISH == 0
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
IF ENGLISH == 0
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
IF ENGLISH == 0
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
IF ENGLISH == 0
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
IF ENGLISH == 0
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
IF ENGLISH == 1
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
		
IF ENGLISH == 0
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
		
IF ENGLISH == 0		
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
	
IF ENGLISH == 1
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
IF ENGLISH == 1
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
IF ENGLISH == 0
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
	
IF ENGLISH == 0		
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

IF ENGLISH == 0
TextDef_Credits0_0:
	dw $9906
	db $07
	db "-STAFF-"
TextDef_Credits1_0:
	dw $98C0
	db $14
	db "-EXECUTIVE PRODUCER-"
TextDef_Credits1_1:
	dw $9943
	db $0E
	db "HIROHISA SATOH"
TextDef_Credits2_0:
	dw $98A5
	db $0A
	db "-PRODUCER-"
TextDef_Credits2_1:
	dw $9901
	db $11
	db "MASAHIRO MORIKAWA"
TextDef_Credits2_2:
	dw $9942
	db $0F
	db "TAKAYUKI NAKANO"
TextDef_Credits2_3:
	dw $9985
	db $09
	db "T.ISHIGAI"
TextDef_Credits3_0:
	dw $98C5
	db $0A
	db "-DIRECTOR-"
TextDef_Credits3_1:
	dw $9921
	db $11
	db "HIROFUMI KASAKAWA"
TextDef_Credits4_0:
	dw $98C3
	db $0D
	db "-ARRANGEMENT-"
TextDef_Credits4_1:
	dw $9925
	db $08
	db "T.SAITOH"
TextDef_Credits4_2:
	dw $9965
	db $07
	db "H.KOISO"
TextDef_Credits5_0:
	dw $98C4
	db $0C
	db "-PROGRAMMER-"
TextDef_Credits5_1:
	dw $9926
	db $07
	db "H.KOISO"
TextDef_Credits5_2:
	dw $9965
	db $09
	db "T.ISHIGAI"
TextDef_Credits6_0:
	dw $98A5
	db $0A
	db "-DESIGNER-"
TextDef_Credits6_1:
	dw $9906
	db $08
	db "T.SAITOU"
TextDef_Credits6_2:
	dw $9946
	db $08
	db "A.TUYUKI"
TextDef_Credits6_3:
	dw $9986
	db $07
	db "A.HANDA"
TextDef_Credits7_0:
	dw $98C5
	db $08
	db "MUSIC BY"
TextDef_Credits7_1:
	dw $9921
	db $11
	db "STUDIO PJ CO.,LTD"
TextDef_Credits9_0:
	dw $98A1
	db $11
	db "-SUPER MARKETTER-"
TextDef_Credits9_1:
	dw $9902
	db $11
	db "TOSHIHIRO MORIOKA"
TextDef_Credits9_2:
	dw $9942
	db $0F
	db "KATUYA TORIHAMA"
TextDef_Credits9_3:
	dw $9982
	db $10
	db "MASAHIRO IWASAKI"
TextDef_Credits8_0:
	dw $98C2
	db $10
	db "-ARTWORK DESIGN-"
TextDef_Credits8_1:
	dw $9923
	db $0D
	db "DESIGN OFFICE"
TextDef_Credits8_2:
	dw $9963
	db $0E
	db "SPACE LAP INC."
TextDef_CreditsB_0:
	dw $98A3
	db $0E
	db "SPECIAL THANKS"
TextDef_CreditsB_1:
	dw $9923
	db $0D
	db "SNK ALL STAFF"
TextDef_CreditsC_0:
	dw $98E6
	db $09
	db "PRESENTED"
TextDef_CreditsC_1:
	dw $9949
	db $02
	db "BY"
TextDef_CreditsC_2:
	dw $9987
	db $06
	db "TAKARA"
TextDef_CreditsA_0:
	dw $9821
	db $10
	db "-SPECIAL THANKS-"
TextDef_CreditsA_1:
	dw $9862
	db $0C
	db "TATUYA HOCHO"
TextDef_CreditsA_2:
	dw $9882
	db $0F
	db "SHUNICHI OHKUSA"
TextDef_CreditsA_3:
	dw $98A2
	db $0F
	db "TAKESHI IKENOUE"
TextDef_CreditsA_4:
	dw $98C2
	db $0E
	db "NAOYUKI TAKADA"
TextDef_CreditsA_5:
	dw $98E2
	db $0E
	db "AKIHIKO KIMURA"
TextDef_CreditsA_6:
	dw $9902
	db $11
	db "NORIHIRO HAYASAKA"
TextDef_CreditsA_7:
	dw $9922
	db $03
	db "S.H"
TextDef_CreditsA_8:
	dw $9942
	db $0F
	db "MITSUNORI SHOJI"
TextDef_CreditsA_9:
	dw $9962
	db $0E
	db "FUMIHIKO OZAWA"
TextDef_CreditsA_A:
	dw $9982
	db $0E
	db "SATOSHI KUMATA"
TextDef_CreditsA_B:
	dw $99A2
	db $0D
	db "TATSUYA YAURA"
TextDef_CreditsA_C:
	dw $99C2
	db $0C
	db "TETSUYA IIDA"
TextDef_CreditsA_D:
	dw $99E2
	db $0B
	db "TAKAO SATOU"
TextDef_CreditsA_E:
	dw $9A02
	db $10
	db "MUTSUMI NAKAMURA"
TextDef_TheEnd:
	dw $9906
	db $08
	db "THE  END"
		
; Text scattered to the four winds in the English version
TextC_Ending_SacredTreasures00:
	db $25
	db "これほとﾞとは・・・。", C_NL
	db C_NL
	db "しかし、これてﾞおしまいてﾞは", C_NL
	db C_NL
	db "あリません。", C_NL
TextC_Ending_SacredTreasures01:
	db $05
	db "ちぃっ!", C_NL
TextC_Ending_SacredTreasures02:
	db $0D
	db "くらいやかﾞれええいっ!", C_NL
TextC_Ending_SacredTreasures03:
	db $0A
	db "くﾞあああああっ!", C_NL
TextC_Ending_SacredTreasures04:
	db $27
	db "なせﾞたﾞ!? なせﾞあかい・・・?", C_NL
	db C_NL
	db "おれのほのうかﾞあかいわけかﾞない!", C_NL
TextC_Ending_SacredTreasures05:
	db $1B
	db "はらうもの、くさなきﾞ", C_NL
	db C_NL
	db "ふうすﾞるもの、やかﾞみ。", C_NL
TextC_Ending_SacredTreasures06:
	db $1E
	db "あななたちはいま1800ねんのときを", C_NL
	db C_NL
	db "なそﾞらえたのよ。", C_NL
TextC_Ending_SacredTreasures07:
	db $2F
	db "オロチはやかﾞみのあかいほのうてﾞ", C_NL
	db C_NL
	db "ふうしﾞられ、くさなきﾞによって", C_NL
	db C_NL
	db "なきﾞはらわれた。", C_NL
TextC_Ending_SacredTreasures08:
	db $32
	db "やかﾞみのあかきほのうは、あなたかﾞ", C_NL
	db C_NL
	db "もつひとのふﾞふﾞんのほんのうかﾞ", C_NL
	db C_NL
	db "うみたﾞしたものよ。", C_NL
TextC_Ending_SacredTreasures09:
	db $32
	db "あなたかﾞあやつるあおきほのう。", C_NL
	db C_NL
	db "それはあなたになかﾞれるオロチの", C_NL
	db C_NL
	db "ちからうまれるもの・・・。", C_NL
TextC_Ending_SacredTreasures0A:
	db $2A
	db "あなたのいちそﾞくかﾞ", C_NL
	db C_NL
	db "たﾞいたﾞいたんめいなのは、", C_NL
	db C_NL
	db "そのオロチのちのせいよ。", C_NL
TextC_Ending_SacredTreasures0B:
	db $2A
	db "このままそのちからをつかい", C_NL
	db C_NL
	db "つつﾞけれはﾞやかﾞみ、", C_NL
	db C_NL
	db "あなたもいすﾞれ・・・。", C_NL
TextC_Ending_SacredTreasures0C:
	db $2C
	db "くたﾞらないことを・・・。", C_NL
	db C_NL
	db "なんたﾞ?・・・な、なにもみえん!?", C_NL
	db C_NL
	db "く、くﾞふっ!!", C_NL
TextC_Ending_SacredTreasures0D:
	db $0F
	db "とﾞうした、やかﾞみ・・・!", C_NL
TextC_Ending_SacredTreasures0E:
	db $13
	db "まさか・・・ちの・・・ほﾞうそう!?", C_NL
TextC_Ending_SacredTreasures0F:
	db $0C
	db "くﾞうおおおううう!!", C_NL
TextC_EndingPost_Boss0:
	db $17
	db "オロチ・・・。", C_NL
	db C_NL
	db "くちほとﾞにもなかったな。", C_NL
TextC_EndingPost_Boss1:
	db $19
	db "GEESE!!", C_NL
	db C_NL
	db "きさま、とﾞういうつもリたﾞ!", C_NL
TextC_EndingPost_Boss2:
	db $07
	db "なんたﾞ!?", C_NL
TextC_EndingPost_Boss3:
	db $36
	db "みょうなトｰナメントにひっはﾟリ", C_NL
	db C_NL
	db "こまれるは、てこﾞまにされるわ。", C_NL
	db C_NL
	db "いすﾞれかならすﾞけリをつける。", C_NL
	db C_NL
TextC_EndingPost_Boss4:
	db $1D
	db "いすﾞれてﾞはなく、いま", C_NL
	db C_NL
	db "けリをつけようてﾞはないか。", C_NL
TextC_EndingPost_Boss5:
	db $0D
	db "ふっふっふ! よかろう。", C_NL
TextC_Ending_OLeona0:
	db $31
	db "おとﾞろきてﾞすね。これほとﾞ", C_NL
	db C_NL
	db "まてﾞとは。 8ねんまえのことは", C_NL
	db C_NL
	db "おほﾞえていますか・・・。", C_NL
TextC_Ending_OLeona1:
	db $21
	db "・・・!?  まさか・・・?", C_NL
	db C_NL
	db "わたしのかそﾞくをころしたのは。", C_NL
TextC_Ending_OLeona2:
	db $35
	db "かんちかﾞいされてはこまリますね。", C_NL
	db C_NL
	db "・・・あなたなのてﾞすよ。", C_NL
	db C_NL
	db "しﾞふﾞんのかそﾞくをころしたのは。", C_NL
TextC_Ending_OLeona3:
	db $0E
	db "!・・・うそ・・・・・・。", C_NL
TextC_Ending_OLeona4:
	db $2D
	db "うそてﾞはあリません。", C_NL
	db C_NL
	db "あなたのからたﾞにはオロチのち", C_NL
	db C_NL
	db "かﾞなかﾞれているのてﾞす。", C_NL
TextC_Ending_OLeona5:
	db $25
	db "てみやけﾞに8ねんまえとおなしﾞ", C_NL
	db C_NL
	db "ようにめさﾞめさせてあけﾞましょう。", C_NL
TextC_Ending_OLeona6:
	db $25
	db "ふふふ・・・。", C_NL
	db C_NL
	db "いいかせﾞかﾞきましたね。", C_NL
	db C_NL
	db "そろそろころあいてﾞす。", C_NL
TextC_Ending_OLeona8:
	db $16
	db "な、なに?", C_NL
	db C_NL
	db "・・・なにもみえない・・・!", C_NL
TextC_Ending_OLeona9:
	db $1F
	db "とﾞうした? LEONA・・・!", C_NL
	db C_NL
	db "まさか、オロチの・・・。", C_NL
TextC_CutsceneMrKarate0:
	db $27
	db "はっはっは!", C_NL
	db C_NL
	db "てﾞんせつのかくとうか!", C_NL
	db C_NL
	db "MR.KARATEさんしﾞょう!", C_NL
TextC_CutsceneMrKarate1:
	db $32
	db "わしは、おまえたちのたたかいを", C_NL
	db C_NL
	db "つねにみてきた。 さすかﾞゆうしょう", C_NL
	db C_NL
	db "したたﾞけのことはある。", C_NL
TextC_CutsceneMrKarate2:
	db $32
	db "たﾞかﾞ、またﾞまたﾞみしﾞゅく!", C_NL
	db C_NL
	db "わしかﾞ、けいこをつけてやろう!!", C_NL
	db C_NL
	db "てﾞは、いくそﾞ!!!", C_NL
TextC_CutsceneMrKarateDefeat0:
	db $2E
	db "むむ・・・なかなかやリおる。", C_NL
	db C_NL
	db "せﾞんたいかいよリ、いちたﾞんと", C_NL
	db C_NL
	db "つよくなったな・・・。", C_NL
TextC_CutsceneMrKarateDefeat1:
	db $1A
	db "せﾞんたいかい・・・?", C_NL
	db C_NL
	db "やはリ、あなたは・・・?", C_NL
TextC_CutsceneMrKarateDefeat2:
	db $30
	db "ちかﾞうっ! たﾞんしﾞてちかﾞう!", C_NL
	db C_NL
	db "わしはてﾞんせつのかくとうか、", C_NL
	db C_NL
	db "MR.KARATE!", C_NL
TextC_CutsceneMrKarateDefeat3:
	db $0D
	db "たくまてﾞはない・・・!", C_NL
TextC_CutsceneMrKarateDefeat4:
	db $0A
	db "や、やはリ・・・。", C_NL
; [TCRF] Unused text, obvious purpose considering where it's placed.
TextC_Unused_0:
	db $24
	db "きょうのところはここまてﾞに", C_NL
	db C_NL
	db "しておいてやろう。", C_NL
	db C_NL
	db "また、あおう!!", C_NL
TextC_CutsceneMrKarateDefeat5:
	db $22
	db "もうすこしてﾞ、しょうたいかﾞ", C_NL
	db C_NL
	db "はﾞれるところてﾞあった・・・。", C_NL
TextC_CutsceneMrKarateDefeat6:
	db $18
	db "こんとﾞはわしもたいかいに", C_NL
	db C_NL
	db "さんかするそﾞ。", C_NL
TextC_CutsceneMrKarateDefeat7:
	db $2A
	db "TAKARAロコﾞのひょうしﾞ", C_NL
	db C_NL
	db "ちゅうにSELECTホﾞタン", C_NL
	db C_NL
	db "を20かいおす。", C_NL
TextC_CutsceneMrKarateDefeat8:
	db $28
	db "SELECTかﾞめんてﾞわしを", C_NL
	db C_NL
	db "えらんてﾞ、さいきょうを", C_NL
	db C_NL
	db "めさﾞすのたﾞ。", C_NL
TextC_EndingPost_FFGeese0:
	db $17
	db "ここまてﾞきたら、", C_NL
	db C_NL
	db "きさまらにようはない。", C_NL
TextC_EndingPost_FFGeese1:
	db $1B
	db "GEESE!", C_NL
	db C_NL
	db "こんとﾞこそけリをつけてやるせﾞ!!", C_NL
TextC_EndingPost_AOFMrBig0:
	db $1C
	db "RYO、ROBERT、", C_NL
	db C_NL
	db "かリはかえさせてもらうせﾞ。", C_NL
TextC_EndingPost_AOFMrBig1:
	db $0B
	db "のそﾞむところたﾞ!", C_NL
TextC_EndingPost_KTR0:
	db $28
	db "ゆうしょうはもらった。", C_NL
	db C_NL
	db "しゅやくはおれたﾞ!", C_NL
	db C_NL
	db "けっちゃくをつけようせﾞ!", C_NL
	db C_NL

; =============== END OF BANK ===============
; Junk area below.
	mIncJunk "L1D7D66"

ELSE

TextDef_Credits0_0: db $06
L1D734E: db $99
L1D734F: db $07
L1D7350: db $2D
L1D7351: db $53
L1D7352: db $54
L1D7353: db $41
L1D7354: db $46
L1D7355: db $46
L1D7356: db $2D
TextDef_Credits1_0: db $C0
L1D7358: db $98
L1D7359: db $14
L1D735A: db $2D
L1D735B: db $45
L1D735C: db $58
L1D735D: db $45
L1D735E: db $43
L1D735F: db $55
L1D7360: db $54
L1D7361: db $49
L1D7362: db $56
L1D7363: db $45
L1D7364: db $20
L1D7365: db $50
L1D7366: db $52
L1D7367: db $4F
L1D7368: db $44
L1D7369: db $55
L1D736A: db $43
L1D736B: db $45
L1D736C: db $52
L1D736D: db $2D
TextDef_Credits1_1: db $43
L1D736F: db $99
L1D7370: db $0E
L1D7371: db $48
L1D7372: db $49
L1D7373: db $52
L1D7374: db $4F
L1D7375: db $48
L1D7376: db $49
L1D7377: db $53
L1D7378: db $41
L1D7379: db $20
L1D737A: db $53
L1D737B: db $41
L1D737C: db $54
L1D737D: db $4F
L1D737E: db $48
TextDef_Credits2_0: db $A5
L1D7380: db $98
L1D7381: db $0A
L1D7382: db $2D
L1D7383: db $50
L1D7384: db $52
L1D7385: db $4F
L1D7386: db $44
L1D7387: db $55
L1D7388: db $43
L1D7389: db $45
L1D738A: db $52
L1D738B: db $2D
TextDef_Credits2_1: db $01
L1D738D: db $99
L1D738E: db $11
L1D738F: db $4D
L1D7390: db $41
L1D7391: db $53
L1D7392: db $41
L1D7393: db $48
L1D7394: db $49
L1D7395: db $52
L1D7396: db $4F
L1D7397: db $20
L1D7398: db $4D
L1D7399: db $4F
L1D739A: db $52
L1D739B: db $49
L1D739C: db $4B
L1D739D: db $41
L1D739E: db $57
L1D739F: db $41
TextDef_Credits2_2: db $42
L1D73A1: db $99
L1D73A2: db $0F
L1D73A3: db $54
L1D73A4: db $41
L1D73A5: db $4B
L1D73A6: db $41
L1D73A7: db $59
L1D73A8: db $55
L1D73A9: db $4B
L1D73AA: db $49
L1D73AB: db $20
L1D73AC: db $4E
L1D73AD: db $41
L1D73AE: db $4B
L1D73AF: db $41
L1D73B0: db $4E
L1D73B1: db $4F
TextDef_Credits2_3: db $85
L1D73B3: db $99
L1D73B4: db $09
L1D73B5: db $54
L1D73B6: db $2E ; M
L1D73B7: db $49
L1D73B8: db $53
L1D73B9: db $48
L1D73BA: db $49
L1D73BB: db $47
L1D73BC: db $41
L1D73BD: db $49
TextDef_Credits3_0: db $C5
L1D73BF: db $98
L1D73C0: db $0A
L1D73C1: db $2D
L1D73C2: db $44
L1D73C3: db $49
L1D73C4: db $52
L1D73C5: db $45
L1D73C6: db $43
L1D73C7: db $54
L1D73C8: db $4F
L1D73C9: db $52
L1D73CA: db $2D
TextDef_Credits3_1: db $21
L1D73CC: db $99
L1D73CD: db $11
L1D73CE: db $48 ; M
L1D73CF: db $49
L1D73D0: db $52
L1D73D1: db $4F
L1D73D2: db $46
L1D73D3: db $55
L1D73D4: db $4D
L1D73D5: db $49
L1D73D6: db $20
L1D73D7: db $4B
L1D73D8: db $41
L1D73D9: db $53
L1D73DA: db $41
L1D73DB: db $4B
L1D73DC: db $41
L1D73DD: db $57
L1D73DE: db $41
TextDef_Credits4_0: db $A3
L1D73E0: db $98
L1D73E1: db $0D
L1D73E2: db $2D
L1D73E3: db $41
L1D73E4: db $52
L1D73E5: db $52
L1D73E6: db $41 ; M
L1D73E7: db $4E
L1D73E8: db $47
L1D73E9: db $45
L1D73EA: db $4D
L1D73EB: db $45
L1D73EC: db $4E
L1D73ED: db $54
L1D73EE: db $2D
TextDef_Credits4_1: db $05
L1D73F0: db $99
L1D73F1: db $08
L1D73F2: db $54
L1D73F3: db $2E
L1D73F4: db $53
L1D73F5: db $41
L1D73F6: db $49
L1D73F7: db $54
L1D73F8: db $4F
L1D73F9: db $55
TextDef_Credits4_2: db $45
L1D73FB: db $99 ; M
L1D73FC: db $08
L1D73FD: db $41
L1D73FE: db $2E
L1D73FF: db $54
L1D7400: db $55
L1D7401: db $59
L1D7402: db $55
L1D7403: db $4B
L1D7404: db $49
TextDef_Credits4_3: db $85
L1D7406: db $99
L1D7407: db $07
L1D7408: db $48
L1D7409: db $2E
L1D740A: db $4B
L1D740B: db $4F
L1D740C: db $49
L1D740D: db $53
L1D740E: db $4F
TextDef_Credits5_0: db $C4
L1D7410: db $98
L1D7411: db $0C
L1D7412: db $2D
L1D7413: db $50
L1D7414: db $52
L1D7415: db $4F
L1D7416: db $47
L1D7417: db $52
L1D7418: db $41
L1D7419: db $4D
L1D741A: db $4D
L1D741B: db $45
L1D741C: db $52
L1D741D: db $2D
TextDef_Credits5_1: db $26
L1D741F: db $99
L1D7420: db $07
L1D7421: db $48
L1D7422: db $2E
L1D7423: db $4B
L1D7424: db $4F
L1D7425: db $49
L1D7426: db $53
L1D7427: db $4F
TextDef_Credits5_2: db $65
L1D7429: db $99
L1D742A: db $09
L1D742B: db $54
L1D742C: db $2E
L1D742D: db $49
L1D742E: db $53
L1D742F: db $48
L1D7430: db $49
L1D7431: db $47
L1D7432: db $41
L1D7433: db $49
TextDef_Credits6_0: db $A5
L1D7435: db $98
L1D7436: db $0A
L1D7437: db $2D
L1D7438: db $44
L1D7439: db $45
L1D743A: db $53
L1D743B: db $49
L1D743C: db $47
L1D743D: db $4E
L1D743E: db $45
L1D743F: db $52
L1D7440: db $2D
TextDef_Credits6_1: db $06
L1D7442: db $99
L1D7443: db $08
L1D7444: db $54
L1D7445: db $2E
L1D7446: db $53
L1D7447: db $41
L1D7448: db $49
L1D7449: db $54
L1D744A: db $4F
L1D744B: db $55
TextDef_Credits6_2: db $46
L1D744D: db $99
L1D744E: db $08
L1D744F: db $41
L1D7450: db $2E
L1D7451: db $54
L1D7452: db $55
L1D7453: db $59
L1D7454: db $55
L1D7455: db $4B
L1D7456: db $49
TextDef_Credits6_3: db $86
L1D7458: db $99
L1D7459: db $07
L1D745A: db $41
L1D745B: db $2E
L1D745C: db $48
L1D745D: db $41
L1D745E: db $4E
L1D745F: db $44
L1D7460: db $41
TextDef_Credits7_0: db $C6
L1D7462: db $98
L1D7463: db $08
L1D7464: db $4D
L1D7465: db $55
L1D7466: db $53
L1D7467: db $49
L1D7468: db $43
L1D7469: db $20
L1D746A: db $42
L1D746B: db $59
TextDef_Credits7_1: db $21
L1D746D: db $99
L1D746E: db $11
L1D746F: db $53
L1D7470: db $54
L1D7471: db $55
L1D7472: db $44
L1D7473: db $49
L1D7474: db $4F
L1D7475: db $20
L1D7476: db $50
L1D7477: db $4A
L1D7478: db $20
L1D7479: db $43
L1D747A: db $4F
L1D747B: db $2E
L1D747C: db $2C
L1D747D: db $4C
L1D747E: db $54
L1D747F: db $44
TextDef_Credits9_0: db $A1
L1D7481: db $98
L1D7482: db $11
L1D7483: db $2D
L1D7484: db $53
L1D7485: db $55
L1D7486: db $50
L1D7487: db $45
L1D7488: db $52
L1D7489: db $20
L1D748A: db $4D
L1D748B: db $41
L1D748C: db $52
L1D748D: db $4B
L1D748E: db $45
L1D748F: db $54
L1D7490: db $54
L1D7491: db $45
L1D7492: db $52
L1D7493: db $2D
TextDef_Credits9_1: db $02
L1D7495: db $99
L1D7496: db $11
L1D7497: db $54
L1D7498: db $4F
L1D7499: db $53
L1D749A: db $48
L1D749B: db $49
L1D749C: db $48
L1D749D: db $49
L1D749E: db $52
L1D749F: db $4F
L1D74A0: db $20
L1D74A1: db $4D
L1D74A2: db $4F
L1D74A3: db $52
L1D74A4: db $49
L1D74A5: db $4F
L1D74A6: db $4B
L1D74A7: db $41
TextDef_Credits9_2: db $42
L1D74A9: db $99
L1D74AA: db $0F
L1D74AB: db $4B
L1D74AC: db $41
L1D74AD: db $54 ; M
L1D74AE: db $55
L1D74AF: db $59
L1D74B0: db $41
L1D74B1: db $20
L1D74B2: db $54
L1D74B3: db $4F
L1D74B4: db $52
L1D74B5: db $49
L1D74B6: db $48
L1D74B7: db $41
L1D74B8: db $4D
L1D74B9: db $41
TextDef_Credits9_3: db $82
L1D74BB: db $99
L1D74BC: db $10
L1D74BD: db $4D ; M
L1D74BE: db $41
L1D74BF: db $53
L1D74C0: db $41
L1D74C1: db $48
L1D74C2: db $49
L1D74C3: db $52
L1D74C4: db $4F
L1D74C5: db $20
L1D74C6: db $49
L1D74C7: db $57 ; M
L1D74C8: db $41
L1D74C9: db $53
L1D74CA: db $41
L1D74CB: db $4B
L1D74CC: db $49
TextDef_Credits8_0: db $C2
L1D74CE: db $98
L1D74CF: db $10
L1D74D0: db $2D
L1D74D1: db $41
L1D74D2: db $52
L1D74D3: db $54
L1D74D4: db $57
L1D74D5: db $4F
L1D74D6: db $52
L1D74D7: db $4B
L1D74D8: db $20 ; M
L1D74D9: db $44
L1D74DA: db $45
L1D74DB: db $53
L1D74DC: db $49
L1D74DD: db $47
L1D74DE: db $4E
L1D74DF: db $2D
TextDef_Credits8_1: db $23
L1D74E1: db $99
L1D74E2: db $0D
L1D74E3: db $44
L1D74E4: db $45
L1D74E5: db $53
L1D74E6: db $49
L1D74E7: db $47
L1D74E8: db $4E
L1D74E9: db $20
L1D74EA: db $4F
L1D74EB: db $46
L1D74EC: db $46
L1D74ED: db $49
L1D74EE: db $43
L1D74EF: db $45 ; M
TextDef_Credits8_2: db $63
L1D74F1: db $99
L1D74F2: db $0E
L1D74F3: db $53
L1D74F4: db $50
L1D74F5: db $41
L1D74F6: db $43
L1D74F7: db $45
L1D74F8: db $20
L1D74F9: db $4C
L1D74FA: db $41
L1D74FB: db $50
L1D74FC: db $20
L1D74FD: db $49
L1D74FE: db $4E
L1D74FF: db $43
L1D7500: db $2E
TextDef_CreditsB_0: db $A3
L1D7502: db $98
L1D7503: db $0E
L1D7504: db $53
L1D7505: db $50
L1D7506: db $45
L1D7507: db $43 ; M
L1D7508: db $49
L1D7509: db $41
L1D750A: db $4C
L1D750B: db $20
L1D750C: db $54
L1D750D: db $48
L1D750E: db $41
L1D750F: db $4E
L1D7510: db $4B ; M
L1D7511: db $53
TextDef_CreditsB_1: db $23
L1D7513: db $99
L1D7514: db $0D
L1D7515: db $53
L1D7516: db $4E
L1D7517: db $4B
L1D7518: db $20
L1D7519: db $41
L1D751A: db $4C
L1D751B: db $4C
L1D751C: db $20
L1D751D: db $53
L1D751E: db $54 ; M
L1D751F: db $41
L1D7520: db $46
L1D7521: db $46
TextDef_CreditsC_0: db $E4
L1D7523: db $98
L1D7524: db $0C
L1D7525: db $50
L1D7526: db $52
L1D7527: db $45
L1D7528: db $53
L1D7529: db $45
L1D752A: db $4E
L1D752B: db $54
L1D752C: db $45
L1D752D: db $44
L1D752E: db $20
L1D752F: db $42
L1D7530: db $59
TextDef_CreditsC_1: db $47
L1D7532: db $99
L1D7533: db $06
L1D7534: db $54
L1D7535: db $41
L1D7536: db $4B
L1D7537: db $41
L1D7538: db $52
L1D7539: db $41
TextDef_CreditsA_0: db $22 ; M
L1D753B: db $98
L1D753C: db $10
L1D753D: db $2D
L1D753E: db $53
L1D753F: db $50
L1D7540: db $45
L1D7541: db $43
L1D7542: db $49
L1D7543: db $41
L1D7544: db $4C
L1D7545: db $20
L1D7546: db $54
L1D7547: db $48 ; M
L1D7548: db $41
L1D7549: db $4E
L1D754A: db $4B
L1D754B: db $53
L1D754C: db $2D
TextDef_CreditsA_1: db $64
L1D754E: db $98
L1D754F: db $0C
L1D7550: db $54
L1D7551: db $41
L1D7552: db $54
L1D7553: db $55
L1D7554: db $59
L1D7555: db $41
L1D7556: db $20
L1D7557: db $48
L1D7558: db $4F
L1D7559: db $43
L1D755A: db $48
L1D755B: db $4F ; M
TextDef_CreditsA_2: db $82
L1D755D: db $98
L1D755E: db $0F
L1D755F: db $53
L1D7560: db $48
L1D7561: db $55 ; M
L1D7562: db $4E
L1D7563: db $49
L1D7564: db $43
L1D7565: db $48
L1D7566: db $49
L1D7567: db $20
L1D7568: db $4F
L1D7569: db $48
L1D756A: db $4B
L1D756B: db $55
L1D756C: db $53
L1D756D: db $41
TextDef_CreditsA_3: db $A3
L1D756F: db $98
L1D7570: db $0F
L1D7571: db $54 ; M
L1D7572: db $41 ; M
L1D7573: db $4B
L1D7574: db $45
L1D7575: db $53
L1D7576: db $48
L1D7577: db $49
L1D7578: db $20
L1D7579: db $49
L1D757A: db $4B
L1D757B: db $45
L1D757C: db $4E
L1D757D: db $4F
L1D757E: db $55
L1D757F: db $45
TextDef_CreditsA_4: db $C3
L1D7581: db $98
L1D7582: db $0E
L1D7583: db $4E
L1D7584: db $41
L1D7585: db $4F
L1D7586: db $59
L1D7587: db $55
L1D7588: db $4B
L1D7589: db $49
L1D758A: db $20
L1D758B: db $54
L1D758C: db $41
L1D758D: db $4B
L1D758E: db $41
L1D758F: db $44
L1D7590: db $41
TextDef_CreditsA_5: db $E3
L1D7592: db $98
L1D7593: db $0E
L1D7594: db $41
L1D7595: db $4B
L1D7596: db $49
L1D7597: db $48
L1D7598: db $49
L1D7599: db $4B
L1D759A: db $4F
L1D759B: db $20 ; M
L1D759C: db $4B
L1D759D: db $49
L1D759E: db $4D
L1D759F: db $55
L1D75A0: db $52 ; M
L1D75A1: db $41
TextDef_CreditsA_6: db $02
L1D75A3: db $99
L1D75A4: db $11
L1D75A5: db $4E
L1D75A6: db $4F
L1D75A7: db $52
L1D75A8: db $49
L1D75A9: db $48
L1D75AA: db $49
L1D75AB: db $52
L1D75AC: db $4F
L1D75AD: db $20
L1D75AE: db $48
L1D75AF: db $41
L1D75B0: db $59
L1D75B1: db $41
L1D75B2: db $53
L1D75B3: db $41
L1D75B4: db $4B
L1D75B5: db $41
TextDef_CreditsA_7: db $29
L1D75B7: db $99
L1D75B8: db $03 ; M
L1D75B9: db $53
L1D75BA: db $2E
L1D75BB: db $48
TextDef_CreditsA_8: db $41
L1D75BD: db $99
L1D75BE: db $0F
L1D75BF: db $4D
L1D75C0: db $49
L1D75C1: db $54
L1D75C2: db $53
L1D75C3: db $55 ; M
L1D75C4: db $4E
L1D75C5: db $4F
L1D75C6: db $52
L1D75C7: db $49
L1D75C8: db $20
L1D75C9: db $53
L1D75CA: db $48
L1D75CB: db $4F
L1D75CC: db $4A
L1D75CD: db $49
TextDef_CreditsA_9: db $62
L1D75CF: db $99
L1D75D0: db $0E
L1D75D1: db $46
L1D75D2: db $55
L1D75D3: db $4D
L1D75D4: db $49
L1D75D5: db $48
L1D75D6: db $49
L1D75D7: db $4B
L1D75D8: db $4F
L1D75D9: db $20
L1D75DA: db $4F
L1D75DB: db $5A
L1D75DC: db $41
L1D75DD: db $57
L1D75DE: db $41
TextDef_CreditsA_A: db $83
L1D75E0: db $99 ; M
L1D75E1: db $0E
L1D75E2: db $53
L1D75E3: db $41
L1D75E4: db $54
L1D75E5: db $4F
L1D75E6: db $53
L1D75E7: db $48
L1D75E8: db $49 ; M
L1D75E9: db $20
L1D75EA: db $4B
L1D75EB: db $55
L1D75EC: db $4D
L1D75ED: db $41
L1D75EE: db $54
L1D75EF: db $41
TextDef_CreditsA_B: db $A3
L1D75F1: db $99
L1D75F2: db $0D
L1D75F3: db $54
L1D75F4: db $41
L1D75F5: db $54
L1D75F6: db $53
L1D75F7: db $55 ; M
L1D75F8: db $59
L1D75F9: db $41
L1D75FA: db $20
L1D75FB: db $59
L1D75FC: db $41
L1D75FD: db $55
L1D75FE: db $52
L1D75FF: db $41
TextDef_CreditsA_C: db $C3
L1D7601: db $99
L1D7602: db $0C
L1D7603: db $54
L1D7604: db $45
L1D7605: db $54
L1D7606: db $53
L1D7607: db $55
L1D7608: db $59
L1D7609: db $41
L1D760A: db $20
L1D760B: db $49
L1D760C: db $49
L1D760D: db $44
L1D760E: db $41
TextDef_CreditsA_D: db $E5
L1D7610: db $99
L1D7611: db $0B
L1D7612: db $54
L1D7613: db $41
L1D7614: db $4B
L1D7615: db $41
L1D7616: db $4F
L1D7617: db $20
L1D7618: db $53
L1D7619: db $41
L1D761A: db $54
L1D761B: db $4F
L1D761C: db $55
TextDef_CreditsA_E: db $03 ; M
L1D761E: db $9A
L1D761F: db $10
L1D7620: db $4D
L1D7621: db $55
L1D7622: db $54
L1D7623: db $53
L1D7624: db $55
L1D7625: db $4D
L1D7626: db $49
L1D7627: db $20
L1D7628: db $4E
L1D7629: db $41
L1D762A: db $4B ; M
L1D762B: db $41
L1D762C: db $4D
L1D762D: db $55
L1D762E: db $52
L1D762F: db $41
TextDef_TheEnd: db $06
L1D7631: db $99
L1D7632: db $08
L1D7633: db $54
L1D7634: db $48
L1D7635: db $45
L1D7636: db $20 ; M
L1D7637: db $20
L1D7638: db $45
L1D7639: db $4E
L1D763A: db $44
TextDef_Credits_Unused_Laguna_0: db $C3
L1D763C: db $98
L1D763D: db $0E
L1D763E: db $2D
L1D763F: db $4C
L1D7640: db $41
L1D7641: db $47
L1D7642: db $55
L1D7643: db $4E
L1D7644: db $41
L1D7645: db $20
L1D7646: db $53
L1D7647: db $54
L1D7648: db $41
L1D7649: db $46
L1D764A: db $46
L1D764B: db $2D
TextDef_Credits_Unused_Laguna_1: db $24
L1D764D: db $99
L1D764E: db $0C
L1D764F: db $46
L1D7650: db $52
L1D7651: db $41
L1D7652: db $4E
L1D7653: db $4B
L1D7654: db $20
L1D7655: db $47
L1D7656: db $4C
L1D7657: db $41
L1D7658: db $53 ; M
L1D7659: db $45
L1D765A: db $52
TextC_Ending_SacredTreasures00: db $50
L1D765C: db $49
L1D765D: db $20
L1D765E: db $64
L1D765F: db $69
L1D7660: db $64
L1D7661: db $20
L1D7662: db $6E
L1D7663: db $6F
L1D7664: db $74
L1D7665: db $20
L1D7666: db $74
L1D7667: db $68
L1D7668: db $69
L1D7669: db $6E
L1D766A: db $6B
L1D766B: db $20
L1D766C: db $79
L1D766D: db $6F
L1D766E: db $75
L1D766F: db $FF
L1D7670: db $20
L1D7671: db $77
L1D7672: db $65
L1D7673: db $72
L1D7674: db $65
L1D7675: db $20
L1D7676: db $74
L1D7677: db $68 ; M
L1D7678: db $61
L1D7679: db $74
L1D767A: db $20
L1D767B: db $73
L1D767C: db $74
L1D767D: db $72
L1D767E: db $6F
L1D767F: db $6E
L1D7680: db $67
L1D7681: db $2E
L1D7682: db $2E
L1D7683: db $2E
L1D7684: db $FF
L1D7685: db $42
L1D7686: db $75
L1D7687: db $74
L1D7688: db $20
L1D7689: db $69
L1D768A: db $74
L1D768B: db $20
L1D768C: db $69
L1D768D: db $73
L1D768E: db $20
L1D768F: db $6E
L1D7690: db $6F
L1D7691: db $74
L1D7692: db $20
L1D7693: db $79
L1D7694: db $65
L1D7695: db $74
L1D7696: db $FF
L1D7697: db $20
L1D7698: db $20
L1D7699: db $20
L1D769A: db $20
L1D769B: db $20
L1D769C: db $20
L1D769D: db $20 ; M
L1D769E: db $20
L1D769F: db $20
L1D76A0: db $20
L1D76A1: db $20
L1D76A2: db $20
L1D76A3: db $20
L1D76A4: db $20
L1D76A5: db $20
L1D76A6: db $6F
L1D76A7: db $76
L1D76A8: db $65
L1D76A9: db $72
L1D76AA: db $2E
L1D76AB: db $FF
TextC_Ending_SacredTreasures01: db $0B
L1D76AD: db $28
L1D76AE: db $49
L1D76AF: db $6F
L1D76B0: db $72
L1D76B1: db $69
L1D76B2: db $29
L1D76B3: db $FF
L1D76B4: db $41
L1D76B5: db $68
L1D76B6: db $21
L1D76B7: db $FF
TextC_Ending_SacredTreasures02: db $0B
L1D76B9: db $54 ; M
L1D76BA: db $61
L1D76BB: db $6B ; M
L1D76BC: db $65
L1D76BD: db $20 ; M
L1D76BE: db $74
L1D76BF: db $68 ; M
L1D76C0: db $61
L1D76C1: db $74 ; M
L1D76C2: db $21
L1D76C3: db $FF
TextC_Ending_SacredTreasures03: db $0D
L1D76C5: db $55 ; M
L1D76C6: db $68
L1D76C7: db $68
L1D76C8: db $68
L1D76C9: db $68
L1D76CA: db $6F
L1D76CB: db $6F
L1D76CC: db $6F
L1D76CD: db $6F
L1D76CE: db $6F
L1D76CF: db $6F
L1D76D0: db $21
L1D76D1: db $FF
TextC_Ending_SacredTreasures04: db $41
L1D76D3: db $57
L1D76D4: db $68
L1D76D5: db $79
L1D76D6: db $20
L1D76D7: db $61
L1D76D8: db $72
L1D76D9: db $65
L1D76DA: db $FF
L1D76DB: db $20 ; M
L1D76DC: db $20
L1D76DD: db $20
L1D76DE: db $20
L1D76DF: db $20
L1D76E0: db $74
L1D76E1: db $68
L1D76E2: db $65
L1D76E3: db $20
L1D76E4: db $66
L1D76E5: db $6C
L1D76E6: db $61 ; M
L1D76E7: db $6D
L1D76E8: db $65
L1D76E9: db $73 ; M
L1D76EA: db $20
L1D76EB: db $72
L1D76EC: db $65
L1D76ED: db $64
L1D76EE: db $3F
L1D76EF: db $FF ; M
L1D76F0: db $54
L1D76F1: db $68
L1D76F2: db $65
L1D76F3: db $79 ; M
L1D76F4: db $20
L1D76F5: db $73
L1D76F6: db $68 ; M
L1D76F7: db $6F
L1D76F8: db $75 ; M
L1D76F9: db $6C
L1D76FA: db $64
L1D76FB: db $6E
L1D76FC: db $60
L1D76FD: db $74 ; M
L1D76FE: db $FF ; M
L1D76FF: db $20 ; M
L1D7700: db $20
L1D7701: db $20
L1D7702: db $20
L1D7703: db $20
L1D7704: db $20
L1D7705: db $20
L1D7706: db $20
L1D7707: db $20
L1D7708: db $20
L1D7709: db $20
L1D770A: db $20
L1D770B: db $20
L1D770C: db $62
L1D770D: db $65 ; M
L1D770E: db $20
L1D770F: db $72
L1D7710: db $65
L1D7711: db $64
L1D7712: db $21
L1D7713: db $FF
TextC_Ending_SacredTreasures05: db $57
L1D7715: db $28
L1D7716: db $43
L1D7717: db $68
L1D7718: db $69
L1D7719: db $7A
L1D771A: db $75
L1D771B: db $72
L1D771C: db $75
L1D771D: db $29
L1D771E: db $FF
L1D771F: db $4B
L1D7720: db $75
L1D7721: db $73 ; M
L1D7722: db $61
L1D7723: db $6E ; M
L1D7724: db $61
L1D7725: db $67 ; M
L1D7726: db $69
L1D7727: db $2C ; M
L1D7728: db $77
L1D7729: db $68 ; M
L1D772A: db $6F
L1D772B: db $20 ; M
L1D772C: db $63
L1D772D: db $75
L1D772E: db $74
L1D772F: db $73
L1D7730: db $FF
L1D7731: db $20
L1D7732: db $20
L1D7733: db $20 ; M
L1D7734: db $20
L1D7735: db $20
L1D7736: db $64
L1D7737: db $6F
L1D7738: db $77
L1D7739: db $6E ; M
L1D773A: db $20
L1D773B: db $74
L1D773C: db $68
L1D773D: db $65
L1D773E: db $20
L1D773F: db $65
L1D7740: db $6E
L1D7741: db $65
L1D7742: db $6D
L1D7743: db $79
L1D7744: db $2E
L1D7745: db $FF
L1D7746: db $59
L1D7747: db $61
L1D7748: db $67
L1D7749: db $61
L1D774A: db $6D
L1D774B: db $69 ; M
L1D774C: db $2C
L1D774D: db $77
L1D774E: db $68
L1D774F: db $6F
L1D7750: db $20
L1D7751: db $6C
L1D7752: db $6F
L1D7753: db $63 ; M
L1D7754: db $6B
L1D7755: db $73 ; M
L1D7756: db $FF
L1D7757: db $20
L1D7758: db $20
L1D7759: db $20
L1D775A: db $20
L1D775B: db $20
L1D775C: db $20
L1D775D: db $20
L1D775E: db $20
L1D775F: db $20
L1D7760: db $20
L1D7761: db $74
L1D7762: db $68
L1D7763: db $65
L1D7764: db $6D
L1D7765: db $20
L1D7766: db $61
L1D7767: db $77
L1D7768: db $61
L1D7769: db $79 ; M
L1D776A: db $2E
L1D776B: db $FF
TextC_Ending_SacredTreasures06: db $32
L1D776D: db $59
L1D776E: db $6F
L1D776F: db $75 ; M
L1D7770: db $20
L1D7771: db $65
L1D7772: db $78
L1D7773: db $70
L1D7774: db $65
L1D7775: db $72
L1D7776: db $69
L1D7777: db $65
L1D7778: db $6E
L1D7779: db $63 ; M
L1D777A: db $65
L1D777B: db $64 ; M
L1D777C: db $FF
L1D777D: db $20 ; M
L1D777E: db $31
L1D777F: db $2C ; M
L1D7780: db $38
L1D7781: db $30
L1D7782: db $30 ; M
L1D7783: db $20
L1D7784: db $79
L1D7785: db $65
L1D7786: db $61
L1D7787: db $72
L1D7788: db $73
L1D7789: db $20
L1D778A: db $69
L1D778B: db $6E
L1D778C: db $20
L1D778D: db $61
L1D778E: db $FF
L1D778F: db $20
L1D7790: db $73
L1D7791: db $69
L1D7792: db $6E
L1D7793: db $67
L1D7794: db $6C
L1D7795: db $65
L1D7796: db $20
L1D7797: db $73
L1D7798: db $65
L1D7799: db $63
L1D779A: db $6F
L1D779B: db $6E ; M
L1D779C: db $64
L1D779D: db $2E
L1D779E: db $FF
TextC_Ending_SacredTreasures07: db $5A
L1D77A0: db $54
L1D77A1: db $68
L1D77A2: db $65
L1D77A3: db $20
L1D77A4: db $4F
L1D77A5: db $72 ; M
L1D77A6: db $6F
L1D77A7: db $63
L1D77A8: db $68
L1D77A9: db $69
L1D77AA: db $20
L1D77AB: db $77
L1D77AC: db $61
L1D77AD: db $73
L1D77AE: db $FF
L1D77AF: db $20
L1D77B0: db $73
L1D77B1: db $65
L1D77B2: db $61 ; M
L1D77B3: db $6C
L1D77B4: db $65
L1D77B5: db $64
L1D77B6: db $20
L1D77B7: db $75
L1D77B8: db $70
L1D77B9: db $20
L1D77BA: db $77
L1D77BB: db $69
L1D77BC: db $74
L1D77BD: db $68
L1D77BE: db $FF ; M
L1D77BF: db $20
L1D77C0: db $59
L1D77C1: db $61
L1D77C2: db $67
L1D77C3: db $61
L1D77C4: db $6D
L1D77C5: db $69
L1D77C6: db $60
L1D77C7: db $73
L1D77C8: db $20 ; M
L1D77C9: db $72
L1D77CA: db $65
L1D77CB: db $64
L1D77CC: db $20
L1D77CD: db $66
L1D77CE: db $6C
L1D77CF: db $61
L1D77D0: db $6D
L1D77D1: db $65
L1D77D2: db $73
L1D77D3: db $FF
L1D77D4: db $2C
L1D77D5: db $61
L1D77D6: db $6E
L1D77D7: db $64 ; M
L1D77D8: db $20
L1D77D9: db $63
L1D77DA: db $75
L1D77DB: db $74
L1D77DC: db $20
L1D77DD: db $64
L1D77DE: db $6F
L1D77DF: db $77
L1D77E0: db $6E
L1D77E1: db $20
L1D77E2: db $62
L1D77E3: db $79
L1D77E4: db $FF
L1D77E5: db $20
L1D77E6: db $20
L1D77E7: db $20
L1D77E8: db $20
L1D77E9: db $20
L1D77EA: db $20
L1D77EB: db $20
L1D77EC: db $20
L1D77ED: db $20
L1D77EE: db $20
L1D77EF: db $20 ; M
L1D77F0: db $4B
L1D77F1: db $75
L1D77F2: db $73
L1D77F3: db $61
L1D77F4: db $6E ; M
L1D77F5: db $61
L1D77F6: db $67
L1D77F7: db $69
L1D77F8: db $2E
L1D77F9: db $FF
TextC_Ending_SacredTreasures08: db $47
L1D77FB: db $59
L1D77FC: db $61
L1D77FD: db $67
L1D77FE: db $61
L1D77FF: db $6D
L1D7800: db $69
L1D7801: db $2C
L1D7802: db $74
L1D7803: db $68
L1D7804: db $65 ; M
L1D7805: db $20
L1D7806: db $72
L1D7807: db $65 ; M
L1D7808: db $64
L1D7809: db $FF ; M
L1D780A: db $20
L1D780B: db $66
L1D780C: db $6C
L1D780D: db $61 ; M
L1D780E: db $6D
L1D780F: db $65 ; M
L1D7810: db $73
L1D7811: db $20
L1D7812: db $63
L1D7813: db $6F
L1D7814: db $6D
L1D7815: db $65
L1D7816: db $20
L1D7817: db $66
L1D7818: db $72
L1D7819: db $6F
L1D781A: db $6D ; M
L1D781B: db $FF
L1D781C: db $20
L1D781D: db $74
L1D781E: db $68
L1D781F: db $65
L1D7820: db $20
L1D7821: db $70
L1D7822: db $61
L1D7823: db $72 ; M
L1D7824: db $74 ; M
L1D7825: db $20
L1D7826: db $6F
L1D7827: db $66
L1D7828: db $20
L1D7829: db $79
L1D782A: db $6F
L1D782B: db $75
L1D782C: db $FF
L1D782D: db $20 ; M
L1D782E: db $20
L1D782F: db $20
L1D7830: db $20
L1D7831: db $20
L1D7832: db $20
L1D7833: db $74
L1D7834: db $68 ; M
L1D7835: db $61
L1D7836: db $74
L1D7837: db $20
L1D7838: db $69
L1D7839: db $73
L1D783A: db $20
L1D783B: db $68
L1D783C: db $75 ; M
L1D783D: db $6D ; M
L1D783E: db $61
L1D783F: db $6E
L1D7840: db $2E
L1D7841: db $FF
TextC_Ending_SacredTreasures09: db $61 ; M
L1D7843: db $54
L1D7844: db $68
L1D7845: db $65 ; M
L1D7846: db $20
L1D7847: db $62
L1D7848: db $6C
L1D7849: db $75
L1D784A: db $65
L1D784B: db $20
L1D784C: db $66
L1D784D: db $6C
L1D784E: db $61
L1D784F: db $6D ; M
L1D7850: db $65
L1D7851: db $73 ; M
L1D7852: db $20
L1D7853: db $74
L1D7854: db $68
L1D7855: db $61
L1D7856: db $74
L1D7857: db $FF
L1D7858: db $20
L1D7859: db $79
L1D785A: db $6F
L1D785B: db $75
L1D785C: db $20
L1D785D: db $63
L1D785E: db $6F
L1D785F: db $6E
L1D7860: db $74
L1D7861: db $72
L1D7862: db $6F
L1D7863: db $6C
L1D7864: db $20
L1D7865: db $63
L1D7866: db $6F
L1D7867: db $6D
L1D7868: db $65
L1D7869: db $FF
L1D786A: db $20
L1D786B: db $66
L1D786C: db $72
L1D786D: db $6F
L1D786E: db $6D
L1D786F: db $20
L1D7870: db $74
L1D7871: db $68
L1D7872: db $65 ; M
L1D7873: db $20
L1D7874: db $70
L1D7875: db $6F
L1D7876: db $77 ; M
L1D7877: db $65
L1D7878: db $72
L1D7879: db $20 ; M
L1D787A: db $6F
L1D787B: db $66
L1D787C: db $FF
L1D787D: db $20
L1D787E: db $74
L1D787F: db $68
L1D7880: db $65
L1D7881: db $20
L1D7882: db $4F
L1D7883: db $72
L1D7884: db $6F
L1D7885: db $63
L1D7886: db $68
L1D7887: db $69
L1D7888: db $20
L1D7889: db $77
L1D788A: db $68
L1D788B: db $69
L1D788C: db $63
L1D788D: db $68
L1D788E: db $FF
L1D788F: db $20
L1D7890: db $66
L1D7891: db $6C
L1D7892: db $6F ; M
L1D7893: db $77
L1D7894: db $73
L1D7895: db $20
L1D7896: db $77
L1D7897: db $69
L1D7898: db $74
L1D7899: db $68
L1D789A: db $69
L1D789B: db $6E
L1D789C: db $20
L1D789D: db $79
L1D789E: db $6F
L1D789F: db $75
L1D78A0: db $2E
L1D78A1: db $2E
L1D78A2: db $2E ; M
L1D78A3: db $FF
TextC_Ending_SacredTreasures0A: db $5B ; M
L1D78A5: db $4D
L1D78A6: db $65
L1D78A7: db $6D
L1D78A8: db $62
L1D78A9: db $65
L1D78AA: db $72 ; M
L1D78AB: db $73
L1D78AC: db $20
L1D78AD: db $6F
L1D78AE: db $66
L1D78AF: db $20
L1D78B0: db $79
L1D78B1: db $6F
L1D78B2: db $75
L1D78B3: db $72 ; M
L1D78B4: db $FF
L1D78B5: db $20
L1D78B6: db $66
L1D78B7: db $61
L1D78B8: db $6D
L1D78B9: db $69
L1D78BA: db $6C
L1D78BB: db $79
L1D78BC: db $20
L1D78BD: db $68
L1D78BE: db $61
L1D78BF: db $76
L1D78C0: db $65
L1D78C1: db $20 ; M
L1D78C2: db $61
L1D78C3: db $6C
L1D78C4: db $77
L1D78C5: db $61
L1D78C6: db $79
L1D78C7: db $73
L1D78C8: db $FF ; M
L1D78C9: db $20 ; M
L1D78CA: db $6D
L1D78CB: db $65
L1D78CC: db $74
L1D78CD: db $20
L1D78CE: db $75
L1D78CF: db $6E
L1D78D0: db $74
L1D78D1: db $69
L1D78D2: db $6D ; M
L1D78D3: db $65 ; M
L1D78D4: db $6C
L1D78D5: db $79
L1D78D6: db $20
L1D78D7: db $64
L1D78D8: db $65
L1D78D9: db $61
L1D78DA: db $74
L1D78DB: db $68
L1D78DC: db $73
L1D78DD: db $FF
L1D78DE: db $20
L1D78DF: db $74
L1D78E0: db $68
L1D78E1: db $72
L1D78E2: db $6F
L1D78E3: db $75
L1D78E4: db $67
L1D78E5: db $68 ; M
L1D78E6: db $20
L1D78E7: db $74
L1D78E8: db $68
L1D78E9: db $65
L1D78EA: db $FF ; M
L1D78EB: db $20
L1D78EC: db $20
L1D78ED: db $20
L1D78EE: db $20
L1D78EF: db $20
L1D78F0: db $20
L1D78F1: db $20
L1D78F2: db $20
L1D78F3: db $20 ; M
L1D78F4: db $67
L1D78F5: db $65
L1D78F6: db $6E
L1D78F7: db $65 ; M
L1D78F8: db $72
L1D78F9: db $61
L1D78FA: db $74
L1D78FB: db $69
L1D78FC: db $6F
L1D78FD: db $6E
L1D78FE: db $73
L1D78FF: db $FF
TextC_Ending_SacredTreasures0B: db $25
L1D7901: db $20 ; M
L1D7902: db $62
L1D7903: db $65
L1D7904: db $63
L1D7905: db $61
L1D7906: db $75
L1D7907: db $73
L1D7908: db $65
L1D7909: db $20
L1D790A: db $6F
L1D790B: db $66
L1D790C: db $20
L1D790D: db $74
L1D790E: db $68 ; M
L1D790F: db $65 ; M
L1D7910: db $FF
L1D7911: db $20 ; M
L1D7912: db $20
L1D7913: db $20 ; M
L1D7914: db $20
L1D7915: db $20
L1D7916: db $4F
L1D7917: db $72 ; M
L1D7918: db $6F
L1D7919: db $63
L1D791A: db $68
L1D791B: db $69
L1D791C: db $60
L1D791D: db $73 ; M
L1D791E: db $20
L1D791F: db $62
L1D7920: db $6C
L1D7921: db $6F
L1D7922: db $6F
L1D7923: db $64
L1D7924: db $2E ; M
L1D7925: db $FF
TextC_Ending_SacredTreasures0C: db $4E ; M
L1D7927: db $49
L1D7928: db $66
L1D7929: db $20
L1D792A: db $79
L1D792B: db $6F
L1D792C: db $75
L1D792D: db $20
L1D792E: db $63
L1D792F: db $6F
L1D7930: db $6E
L1D7931: db $74
L1D7932: db $69
L1D7933: db $6E ; M
L1D7934: db $75
L1D7935: db $65 ; M
L1D7936: db $20
L1D7937: db $74
L1D7938: db $6F ; M
L1D7939: db $FF
L1D793A: db $20
L1D793B: db $75
L1D793C: db $73 ; M
L1D793D: db $65
L1D793E: db $20
L1D793F: db $69
L1D7940: db $74
L1D7941: db $73
L1D7942: db $20
L1D7943: db $70
L1D7944: db $6F ; M
L1D7945: db $77
L1D7946: db $65
L1D7947: db $72
L1D7948: db $2C
L1D7949: db $74
L1D794A: db $68
L1D794B: db $65
L1D794C: db $FF
L1D794D: db $20
L1D794E: db $67
L1D794F: db $6F
L1D7950: db $64
L1D7951: db $73
L1D7952: db $20
L1D7953: db $77
L1D7954: db $69 ; M
L1D7955: db $6C
L1D7956: db $6C
L1D7957: db $20
L1D7958: db $73
L1D7959: db $6F
L1D795A: db $6D
L1D795B: db $65
L1D795C: db $64 ; M
L1D795D: db $61
L1D795E: db $79
L1D795F: db $FF
L1D7960: db $20
L1D7961: db $20
L1D7962: db $20
L1D7963: db $20
L1D7964: db $20
L1D7965: db $74
L1D7966: db $61 ; M
L1D7967: db $6B
L1D7968: db $65
L1D7969: db $20
L1D796A: db $79
L1D796B: db $6F
L1D796C: db $75
L1D796D: db $20
L1D796E: db $74
L1D796F: db $6F
L1D7970: db $6F
L1D7971: db $2E
L1D7972: db $2E
L1D7973: db $2E
L1D7974: db $FF
TextC_Ending_SacredTreasures0D: db $2A
L1D7976: db $28
L1D7977: db $49
L1D7978: db $6F
L1D7979: db $72
L1D797A: db $69 ; M
L1D797B: db $29
L1D797C: db $FF
L1D797D: db $57
L1D797E: db $68
L1D797F: db $61
L1D7980: db $74
L1D7981: db $20
L1D7982: db $6E
L1D7983: db $6F
L1D7984: db $6E ; M
L1D7985: db $73
L1D7986: db $65
L1D7987: db $6E
L1D7988: db $73
L1D7989: db $65
L1D798A: db $FF
L1D798B: db $20
L1D798C: db $20
L1D798D: db $20
L1D798E: db $20
L1D798F: db $20
L1D7990: db $20
L1D7991: db $20
L1D7992: db $20
L1D7993: db $20
L1D7994: db $20
L1D7995: db $69
L1D7996: db $73
L1D7997: db $20
L1D7998: db $74
L1D7999: db $68
L1D799A: db $69
L1D799B: db $73
L1D799C: db $2E
L1D799D: db $2E
L1D799E: db $2E
L1D799F: db $FF
TextC_Ending_SacredTreasures0E: db $36
L1D79A1: db $57
L1D79A2: db $68
L1D79A3: db $61
L1D79A4: db $74 ; M
L1D79A5: db $60
L1D79A6: db $73
L1D79A7: db $20
L1D79A8: db $67
L1D79A9: db $6F ; M
L1D79AA: db $69
L1D79AB: db $6E
L1D79AC: db $67 ; M
L1D79AD: db $20 ; M
L1D79AE: db $6F
L1D79AF: db $6E ; M
L1D79B0: db $3F
L1D79B1: db $21 ; M
L1D79B2: db $FF
L1D79B3: db $FF
L1D79B4: db $49 ; M
L1D79B5: db $20 ; M
L1D79B6: db $63
L1D79B7: db $61
L1D79B8: db $6E
L1D79B9: db $60
L1D79BA: db $74
L1D79BB: db $20
L1D79BC: db $73
L1D79BD: db $65
L1D79BE: db $65
L1D79BF: db $20
L1D79C0: db $61
L1D79C1: db $6E ; M
L1D79C2: db $79
L1D79C3: db $74
L1D79C4: db $68
L1D79C5: db $69
L1D79C6: db $6E
L1D79C7: db $67
L1D79C8: db $21
L1D79C9: db $FF
L1D79CA: db $FF
L1D79CB: db $41 ; M
L1D79CC: db $61 ; M
L1D79CD: db $61
L1D79CE: db $68
L1D79CF: db $68
L1D79D0: db $75
L1D79D1: db $75
L1D79D2: db $21
L1D79D3: db $21
L1D79D4: db $2E
L1D79D5: db $2E
L1D79D6: db $FF
TextC_Ending_SacredTreasures0F: db $22
L1D79D8: db $28
L1D79D9: db $4B
L1D79DA: db $79 ; M
L1D79DB: db $6F
L1D79DC: db $29
L1D79DD: db $FF
L1D79DE: db $59
L1D79DF: db $61
L1D79E0: db $67
L1D79E1: db $61
L1D79E2: db $6D
L1D79E3: db $69 ; M
L1D79E4: db $21 ; M
L1D79E5: db $FF
L1D79E6: db $41
L1D79E7: db $72
L1D79E8: db $65
L1D79E9: db $20
L1D79EA: db $79
L1D79EB: db $6F
L1D79EC: db $75
L1D79ED: db $20
L1D79EE: db $61
L1D79EF: db $6C
L1D79F0: db $6C
L1D79F1: db $20 ; M
L1D79F2: db $72
L1D79F3: db $69
L1D79F4: db $67
L1D79F5: db $68
L1D79F6: db $74
L1D79F7: db $3F
L1D79F8: db $21
L1D79F9: db $FF
TextC_Ending_SacredTreasures10: db $22
L1D79FB: db $28
L1D79FC: db $43
L1D79FD: db $68
L1D79FE: db $69
L1D79FF: db $7A
L1D7A00: db $75
L1D7A01: db $72
L1D7A02: db $75
L1D7A03: db $29
L1D7A04: db $FF
L1D7A05: db $4E
L1D7A06: db $6F
L1D7A07: db $2E
L1D7A08: db $2E
L1D7A09: db $2E
L1D7A0A: db $FF
L1D7A0B: db $41
L1D7A0C: db $6D
L1D7A0D: db $20 ; M
L1D7A0E: db $49
L1D7A0F: db $20
L1D7A10: db $62
L1D7A11: db $65
L1D7A12: db $63
L1D7A13: db $6F
L1D7A14: db $6D
L1D7A15: db $69
L1D7A16: db $6E
L1D7A17: db $67
L1D7A18: db $2E
L1D7A19: db $2E
L1D7A1A: db $2E ; M
L1D7A1B: db $3F
L1D7A1C: db $FF
TextC_Ending_SacredTreasures11: db $17
L1D7A1E: db $28 ; M
L1D7A1F: db $49
L1D7A20: db $6F
L1D7A21: db $72
L1D7A22: db $69 ; M
L1D7A23: db $29
L1D7A24: db $FF
L1D7A25: db $75 ; M
L1D7A26: db $75
L1D7A27: db $57
L1D7A28: db $4F
L1D7A29: db $4F
L1D7A2A: db $6F
L1D7A2B: db $6F
L1D7A2C: db $6F
L1D7A2D: db $68
L1D7A2E: db $68
L1D7A2F: db $68
L1D7A30: db $21 ; M
L1D7A31: db $21
L1D7A32: db $21
L1D7A33: db $21
L1D7A34: db $FF
TextC_Ending_OLeona0: db $63
L1D7A36: db $49
L1D7A37: db $60
L1D7A38: db $6D
L1D7A39: db $20
L1D7A3A: db $73
L1D7A3B: db $75
L1D7A3C: db $72
L1D7A3D: db $70
L1D7A3E: db $72
L1D7A3F: db $69
L1D7A40: db $73 ; M
L1D7A41: db $65
L1D7A42: db $64
L1D7A43: db $20
L1D7A44: db $79
L1D7A45: db $6F
L1D7A46: db $75
L1D7A47: db $FF
L1D7A48: db $20
L1D7A49: db $20
L1D7A4A: db $20
L1D7A4B: db $6D
L1D7A4C: db $61
L1D7A4D: db $64
L1D7A4E: db $65
L1D7A4F: db $20
L1D7A50: db $69
L1D7A51: db $74
L1D7A52: db $20
L1D7A53: db $74
L1D7A54: db $68
L1D7A55: db $69
L1D7A56: db $73
L1D7A57: db $20
L1D7A58: db $66
L1D7A59: db $61
L1D7A5A: db $72
L1D7A5B: db $2E
L1D7A5C: db $FF
L1D7A5D: db $44
L1D7A5E: db $6F
L1D7A5F: db $20
L1D7A60: db $79
L1D7A61: db $6F
L1D7A62: db $75
L1D7A63: db $20
L1D7A64: db $72
L1D7A65: db $65 ; M
L1D7A66: db $6D
L1D7A67: db $65
L1D7A68: db $6D
L1D7A69: db $62 ; M
L1D7A6A: db $65 ; M
L1D7A6B: db $72
L1D7A6C: db $20
L1D7A6D: db $77
L1D7A6E: db $68
L1D7A6F: db $61
L1D7A70: db $74
L1D7A71: db $FF
L1D7A72: db $20
L1D7A73: db $68
L1D7A74: db $61
L1D7A75: db $70
L1D7A76: db $70
L1D7A77: db $65
L1D7A78: db $6E
L1D7A79: db $65
L1D7A7A: db $64
L1D7A7B: db $20
L1D7A7C: db $38
L1D7A7D: db $20
L1D7A7E: db $79
L1D7A7F: db $65
L1D7A80: db $61
L1D7A81: db $72
L1D7A82: db $73
L1D7A83: db $FF
L1D7A84: db $20
L1D7A85: db $20
L1D7A86: db $20
L1D7A87: db $20
L1D7A88: db $20
L1D7A89: db $20
L1D7A8A: db $20
L1D7A8B: db $20
L1D7A8C: db $20
L1D7A8D: db $20
L1D7A8E: db $20
L1D7A8F: db $20
L1D7A90: db $20
L1D7A91: db $20
L1D7A92: db $20
L1D7A93: db $20
L1D7A94: db $61
L1D7A95: db $67
L1D7A96: db $6F
L1D7A97: db $3F
L1D7A98: db $FF
TextC_Ending_OLeona1: db $41
L1D7A9A: db $28
L1D7A9B: db $4C
L1D7A9C: db $65
L1D7A9D: db $6F
L1D7A9E: db $6E
L1D7A9F: db $61
L1D7AA0: db $29
L1D7AA1: db $FF
L1D7AA2: db $2E
L1D7AA3: db $2E
L1D7AA4: db $2E
L1D7AA5: db $21
L1D7AA6: db $3F ; M
L1D7AA7: db $20
L1D7AA8: db $49
L1D7AA9: db $74
L1D7AAA: db $20 ; M
L1D7AAB: db $63
L1D7AAC: db $61 ; M
L1D7AAD: db $6E
L1D7AAE: db $60 ; M
L1D7AAF: db $74
L1D7AB0: db $20 ; M
L1D7AB1: db $62
L1D7AB2: db $65 ; M
L1D7AB3: db $2E
L1D7AB4: db $2E
L1D7AB5: db $2E ; M
L1D7AB6: db $FF
L1D7AB7: db $54
L1D7AB8: db $68
L1D7AB9: db $65 ; M
L1D7ABA: db $20 ; M
L1D7ABB: db $70
L1D7ABC: db $65
L1D7ABD: db $72
L1D7ABE: db $73 ; M
L1D7ABF: db $6F ; M
L1D7AC0: db $6E
L1D7AC1: db $20
L1D7AC2: db $77
L1D7AC3: db $68
L1D7AC4: db $6F
L1D7AC5: db $FF
L1D7AC6: db $20
L1D7AC7: db $20
L1D7AC8: db $20 ; M
L1D7AC9: db $6B
L1D7ACA: db $69
L1D7ACB: db $6C
L1D7ACC: db $6C
L1D7ACD: db $65
L1D7ACE: db $64
L1D7ACF: db $20
L1D7AD0: db $6D
L1D7AD1: db $79
L1D7AD2: db $20
L1D7AD3: db $66
L1D7AD4: db $61
L1D7AD5: db $6D
L1D7AD6: db $69
L1D7AD7: db $6C ; M
L1D7AD8: db $79
L1D7AD9: db $21
L1D7ADA: db $FF
TextC_Ending_OLeona2: db $31
L1D7ADC: db $4E ; M
L1D7ADD: db $6F
L1D7ADE: db $2E
L1D7ADF: db $FF
L1D7AE0: db $49
L1D7AE1: db $20
L1D7AE2: db $64
L1D7AE3: db $69
L1D7AE4: db $64
L1D7AE5: db $20 ; M
L1D7AE6: db $6E
L1D7AE7: db $6F
L1D7AE8: db $74 ; M
L1D7AE9: db $20
L1D7AEA: db $6B
L1D7AEB: db $69
L1D7AEC: db $6C
L1D7AED: db $6C
L1D7AEE: db $FF
L1D7AEF: db $20
L1D7AF0: db $20
L1D7AF1: db $20
L1D7AF2: db $20
L1D7AF3: db $20
L1D7AF4: db $20
L1D7AF5: db $20
L1D7AF6: db $20
L1D7AF7: db $79
L1D7AF8: db $6F ; M
L1D7AF9: db $75
L1D7AFA: db $72
L1D7AFB: db $20
L1D7AFC: db $66
L1D7AFD: db $61
L1D7AFE: db $6D
L1D7AFF: db $69
L1D7B00: db $6C
L1D7B01: db $79
L1D7B02: db $2E
L1D7B03: db $FF
L1D7B04: db $59 ; M
L1D7B05: db $6F
L1D7B06: db $75
L1D7B07: db $20
L1D7B08: db $64
L1D7B09: db $69
L1D7B0A: db $64
L1D7B0B: db $2E
L1D7B0C: db $FF
TextC_Ending_OLeona3: db $10
L1D7B0E: db $28
L1D7B0F: db $4C ; M
L1D7B10: db $65
L1D7B11: db $6F ; M
L1D7B12: db $6E
L1D7B13: db $61 ; M
L1D7B14: db $29 ; M
L1D7B15: db $FF ; M
L1D7B16: db $4C
L1D7B17: db $69 ; M
L1D7B18: db $61
L1D7B19: db $72
L1D7B1A: db $21
L1D7B1B: db $21
L1D7B1C: db $21
L1D7B1D: db $FF
TextC_Ending_OLeona4: db $4B
L1D7B1F: db $49
L1D7B20: db $74
L1D7B21: db $20
L1D7B22: db $69
L1D7B23: db $73
L1D7B24: db $20
L1D7B25: db $74
L1D7B26: db $68
L1D7B27: db $65
L1D7B28: db $20
L1D7B29: db $74
L1D7B2A: db $72
L1D7B2B: db $75
L1D7B2C: db $74 ; M
L1D7B2D: db $68
L1D7B2E: db $2E
L1D7B2F: db $FF
L1D7B30: db $54
L1D7B31: db $68
L1D7B32: db $65
L1D7B33: db $20
L1D7B34: db $62
L1D7B35: db $6C ; M
L1D7B36: db $6F
L1D7B37: db $6F
L1D7B38: db $64
L1D7B39: db $20
L1D7B3A: db $6F
L1D7B3B: db $66
L1D7B3C: db $20
L1D7B3D: db $74
L1D7B3E: db $68 ; M
L1D7B3F: db $65
L1D7B40: db $FF
L1D7B41: db $20
L1D7B42: db $4F
L1D7B43: db $72
L1D7B44: db $6F
L1D7B45: db $63
L1D7B46: db $68
L1D7B47: db $69 ; M
L1D7B48: db $20
L1D7B49: db $72
L1D7B4A: db $75
L1D7B4B: db $6E
L1D7B4C: db $20
L1D7B4D: db $69
L1D7B4E: db $6E
L1D7B4F: db $20
L1D7B50: db $79
L1D7B51: db $6F
L1D7B52: db $75
L1D7B53: db $72
L1D7B54: db $FF
L1D7B55: db $20 ; M
L1D7B56: db $20
L1D7B57: db $20
L1D7B58: db $20
L1D7B59: db $20
L1D7B5A: db $20
L1D7B5B: db $20
L1D7B5C: db $20
L1D7B5D: db $20
L1D7B5E: db $20
L1D7B5F: db $20
L1D7B60: db $20
L1D7B61: db $20
L1D7B62: db $20
L1D7B63: db $76 ; M
L1D7B64: db $65
L1D7B65: db $69
L1D7B66: db $6E
L1D7B67: db $73
L1D7B68: db $2E
L1D7B69: db $FF
TextC_Ending_OLeona5: db $39
L1D7B6B: db $4C
L1D7B6C: db $65
L1D7B6D: db $74 ; M
L1D7B6E: db $20
L1D7B6F: db $6D
L1D7B70: db $65
L1D7B71: db $20
L1D7B72: db $72
L1D7B73: db $65
L1D7B74: db $6D
L1D7B75: db $69
L1D7B76: db $6E
L1D7B77: db $64 ; M
L1D7B78: db $20
L1D7B79: db $79
L1D7B7A: db $6F
L1D7B7B: db $75 ; M
L1D7B7C: db $20
L1D7B7D: db $6F
L1D7B7E: db $66
L1D7B7F: db $FF ; M
L1D7B80: db $20
L1D7B81: db $74
L1D7B82: db $68
L1D7B83: db $61 ; M
L1D7B84: db $74
L1D7B85: db $20
L1D7B86: db $66
L1D7B87: db $61
L1D7B88: db $63
L1D7B89: db $74
L1D7B8A: db $20
L1D7B8B: db $6C
L1D7B8C: db $69 ; M
L1D7B8D: db $6B
L1D7B8E: db $65
L1D7B8F: db $FF
L1D7B90: db $20
L1D7B91: db $49
L1D7B92: db $20 ; M
L1D7B93: db $64
L1D7B94: db $69
L1D7B95: db $64
L1D7B96: db $20
L1D7B97: db $38
L1D7B98: db $20
L1D7B99: db $79
L1D7B9A: db $65 ; M
L1D7B9B: db $61
L1D7B9C: db $72
L1D7B9D: db $73
L1D7B9E: db $20 ; M
L1D7B9F: db $61
L1D7BA0: db $67
L1D7BA1: db $6F
L1D7BA2: db $2E
L1D7BA3: db $FF
TextC_Ending_OLeona6: db $31
L1D7BA5: db $48
L1D7BA6: db $61
L1D7BA7: db $2C
L1D7BA8: db $68
L1D7BA9: db $61
L1D7BAA: db $2C ; M
L1D7BAB: db $68
L1D7BAC: db $61
L1D7BAD: db $2E
L1D7BAE: db $2E
L1D7BAF: db $2E
L1D7BB0: db $FF
L1D7BB1: db $54
L1D7BB2: db $68 ; M
L1D7BB3: db $65
L1D7BB4: db $20
L1D7BB5: db $77
L1D7BB6: db $69
L1D7BB7: db $6E ; M
L1D7BB8: db $64
L1D7BB9: db $20
L1D7BBA: db $62
L1D7BBB: db $6C
L1D7BBC: db $6F ; M
L1D7BBD: db $77
L1D7BBE: db $73
L1D7BBF: db $2E
L1D7BC0: db $2E
L1D7BC1: db $2E
L1D7BC2: db $FF
L1D7BC3: db $54
L1D7BC4: db $68
L1D7BC5: db $65
L1D7BC6: db $20
L1D7BC7: db $74
L1D7BC8: db $69
L1D7BC9: db $6D
L1D7BCA: db $65 ; M
L1D7BCB: db $20
L1D7BCC: db $69
L1D7BCD: db $73
L1D7BCE: db $20
L1D7BCF: db $72
L1D7BD0: db $69 ; M
L1D7BD1: db $67
L1D7BD2: db $68
L1D7BD3: db $74
L1D7BD4: db $2E
L1D7BD5: db $FF
TextC_Ending_OLeona8: db $2F
L1D7BD7: db $28
L1D7BD8: db $4C
L1D7BD9: db $65
L1D7BDA: db $6F
L1D7BDB: db $6E ; M
L1D7BDC: db $61
L1D7BDD: db $29 ; M
L1D7BDE: db $FF
L1D7BDF: db $57
L1D7BE0: db $2D
L1D7BE1: db $77
L1D7BE2: db $68
L1D7BE3: db $61
L1D7BE4: db $74
L1D7BE5: db $3F ; M
L1D7BE6: db $FF
L1D7BE7: db $49
L1D7BE8: db $20
L1D7BE9: db $63
L1D7BEA: db $61
L1D7BEB: db $6E
L1D7BEC: db $60
L1D7BED: db $74 ; M
L1D7BEE: db $20
L1D7BEF: db $73
L1D7BF0: db $65
L1D7BF1: db $65
L1D7BF2: db $FF
L1D7BF3: db $20 ; M
L1D7BF4: db $20
L1D7BF5: db $20
L1D7BF6: db $20
L1D7BF7: db $20
L1D7BF8: db $20
L1D7BF9: db $20
L1D7BFA: db $20
L1D7BFB: db $20
L1D7BFC: db $61
L1D7BFD: db $6E
L1D7BFE: db $79 ; M
L1D7BFF: db $74
L1D7C00: db $68
L1D7C01: db $69 ; M
L1D7C02: db $6E
L1D7C03: db $67
L1D7C04: db $21
L1D7C05: db $FF
TextC_Ending_OLeona9: db $33
L1D7C07: db $57
L1D7C08: db $68
L1D7C09: db $61
L1D7C0A: db $74
L1D7C0B: db $60
L1D7C0C: db $73
L1D7C0D: db $20
L1D7C0E: db $74
L1D7C0F: db $68
L1D7C10: db $65
L1D7C11: db $20
L1D7C12: db $6D
L1D7C13: db $61 ; M
L1D7C14: db $74
L1D7C15: db $74 ; M
L1D7C16: db $65
L1D7C17: db $72 ; M
L1D7C18: db $3F
L1D7C19: db $FF ; M
L1D7C1A: db $49
L1D7C1B: db $74 ; M
L1D7C1C: db $20
L1D7C1D: db $63
L1D7C1E: db $61
L1D7C1F: db $6E
L1D7C20: db $60
L1D7C21: db $74
L1D7C22: db $20
L1D7C23: db $62
L1D7C24: db $65
L1D7C25: db $2E ; M
L1D7C26: db $2E
L1D7C27: db $2E
L1D7C28: db $FF
L1D7C29: db $20
L1D7C2A: db $74
L1D7C2B: db $68
L1D7C2C: db $65
L1D7C2D: db $20 ; M
L1D7C2E: db $4F
L1D7C2F: db $72
L1D7C30: db $6F
L1D7C31: db $63
L1D7C32: db $68
L1D7C33: db $69
L1D7C34: db $60
L1D7C35: db $73
L1D7C36: db $2E ; M
L1D7C37: db $2E
L1D7C38: db $2E
L1D7C39: db $FF
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

GFXLZ_LagunaLogo: db $58
L1D7C5B: db $40
L1D7C5C: db $75
L1D7C5D: db $00
L1D7C5E: db $07 ; M
L1D7C5F: db $07
L1D7C60: db $00
L1D7C61: db $0C
L1D7C62: db $00
L1D7C63: db $0F ; M
L1D7C64: db $07
L1D7C65: db $D0
L1D7C66: db $02 ; M
L1D7C67: db $AF
L1D7C68: db $C0
L1D7C69: db $00
L1D7C6A: db $B8
L1D7C6B: db $F8
L1D7C6C: db $87
L1D7C6D: db $FF
L1D7C6E: db $65
L1D7C6F: db $81
L1D7C70: db $0F
L1D7C71: db $08
L1D7C72: db $82
L1D7C73: db $FE
L1D7C74: db $0B
L1D7C75: db $02
L1D7C76: db $08
L1D7C77: db $B1
L1D7C78: db $FF
L1D7C79: db $01
L1D7C7A: db $00
L1D7C7B: db $58
L1D7C7C: db $03
L1D7C7D: db $04
L1D7C7E: db $07 ; M
L1D7C7F: db $09
L1D7C80: db $FD ; M
L1D7C81: db $7F ; M
L1D7C82: db $05
L1D7C83: db $90 ; M
L1D7C84: db $00
L1D7C85: db $4F
L1D7C86: db $03 ; M
L1D7C87: db $0C
L1D7C88: db $00
L1D7C89: db $20
L1D7C8A: db $CB
L1D7C8B: db $CF
L1D7C8C: db $10
L1D7C8D: db $0F
L1D7C8E: db $30
L1D7C8F: db $3F
L1D7C90: db $40
L1D7C91: db $7F
L1D7C92: db $3D
L1D7C93: db $80
L1D7C94: db $FF
L1D7C95: db $60
L1D7C96: db $0A
L1D7C97: db $E0
L1D7C98: db $08
L1D7C99: db $07
L1D7C9A: db $08
L1D7C9B: db $15
L1D7C9C: db $28
L1D7C9D: db $EF
L1D7C9E: db $18
L1D7C9F: db $18
L1D7CA0: db $08
L1D7CA1: db $5A
L1D7CA2: db $01
L1D7CA3: db $0A
L1D7CA4: db $5F
L1D7CA5: db $81
L1D7CA6: db $08
L1D7CA7: db $C1
L1D7CA8: db $49
L1D7CA9: db $07
L1D7CAA: db $02
L1D7CAB: db $88
L1D7CAC: db $00
L1D7CAD: db $35
L1D7CAE: db $82
L1D7CAF: db $83
L1D7CB0: db $3D
L1D7CB1: db $01
L1D7CB2: db $07
L1D7CB3: db $00
L1D7CB4: db $7F
L1D7CB5: db $00
L1D7CB6: db $54
L1D7CB7: db $87
L1D7CB8: db $E8 ; M
L1D7CB9: db $03
L1D7CBA: db $08
L1D7CBB: db $84
L1D7CBC: db $20
L1D7CBD: db $88
L1D7CBE: db $8F
L1D7CBF: db $82
L1D7CC0: db $09
L1D7CC1: db $90
L1D7CC2: db $9F
L1D7CC3: db $30
L1D7CC4: db $3F
L1D7CC5: db $71
L1D7CC6: db $78
L1D7CC7: db $63
L1D7CC8: db $9D
L1D7CC9: db $08
L1D7CCA: db $E2
L1D7CCB: db $FE
L1D7CCC: db $C0
L1D7CCD: db $9A
L1D7CCE: db $09
L1D7CCF: db $77 ; M
L1D7CD0: db $08
L1D7CD1: db $AA
L1D7CD2: db $03
L1D7CD3: db $FB
L1D7CD4: db $00
L1D7CD5: db $73
L1D7CD6: db $00
L1D7CD7: db $00
L1D7CD8: db $00
L1D7CD9: db $18
L1D7CDA: db $8B
L1D7CDB: db $00
L1D7CDC: db $E9
L1D7CDD: db $F9
L1D7CDE: db $09
L1D7CDF: db $08
L1D7CE0: db $0F
L1D7CE1: db $68
L1D7CE2: db $0D
L1D7CE3: db $8B
L1D7CE4: db $7B
L1D7CE5: db $E8
L1D7CE6: db $F8
L1D7CE7: db $08
L1D7CE8: db $0C
L1D7CE9: db $0B
L1D7CEA: db $F8
L1D7CEB: db $09
L1D7CEC: db $DD
L1D7CED: db $BF
L1D7CEE: db $0D
L1D7CEF: db $8F
L1D7CF0: db $08
L1D7CF1: db $9B
L1D7CF2: db $09
L1D7CF3: db $8B
L1D7CF4: db $08
L1D7CF5: db $D4
L1D7CF6: db $49
L1D7CF7: db $0D
L1D7CF8: db $00
L1D7CF9: db $02
L1D7CFA: db $60
L1D7CFB: db $00
L1D7CFC: db $58
L1D7CFD: db $78
L1D7CFE: db $13
L1D7CFF: db $46
L1D7D00: db $7E
L1D7D01: db $42
L1D7D02: db $0A
L1D7D03: db $C2
L1D7D04: db $FE
L1D7D05: db $7B
L1D7D06: db $03
L1D7D07: db $C2
L1D7D08: db $80
L1D7D09: db $8C
L1D7D0A: db $44
L1D7D0B: db $7C
L1D7D0C: db $83
L1D7D0D: db $FF
L1D7D0E: db $0B
L1D7D0F: db $93
L1D7D10: db $A4
L1D7D11: db $08
L1D7D12: db $13
L1D7D13: db $0E
L1D7D14: db $C4
L1D7D15: db $FC
L1D7D16: db $09
L1D7D17: db $C8
L1D7D18: db $F8
L1D7D19: db $A0
L1D7D1A: db $09
L1D7D1B: db $88
L1D7D1C: db $0A
L1D7D1D: db $91
L1D7D1E: db $F1
L1D7D1F: db $92
L1D7D20: db $F3
L1D7D21: db $00
L1D7D22: db $A0
L1D7D23: db $00
L1D7D24: db $03
L1D7D25: db $00
L1D7D26: db $0C
L1D7D27: db $0F ; M
L1D7D28: db $30
L1D7D29: db $3F
L1D7D2A: db $40
L1D7D2B: db $3E
L1D7D2C: db $7F
L1D7D2D: db $80 ; M
L1D7D2E: db $D8
L1D7D2F: db $50
L1D7D30: db $0A
L1D7D31: db $58
L1D7D32: db $00
L1D7D33: db $CB
L1D7D34: db $0A
L1D7D35: db $CF
L1D7D36: db $28
L1D7D37: db $EF
L1D7D38: db $18
L1D7D39: db $38
L1D7D3A: db $08
L1D7D3B: db $5A
L1D7D3C: db $01
L1D7D3D: db $FE
L1D7D3E: db $0A
L1D7D3F: db $F9
L1D7D40: db $B8
L1D7D41: db $07
L1D7D42: db $00
L1D7D43: db $59
L1D7D44: db $01
L1D7D45: db $0F
L1D7D46: db $B4
L1D7D47: db $02
L1D7D48: db $1F
L1D7D49: db $07
L1D7D4A: db $00
L1D7D4B: db $1E
L1D7D4C: db $0E
L1D7D4D: db $3E
L1D7D4E: db $3F
L1D7D4F: db $C2
L1D7D50: db $0D
L1D7D51: db $01
L1D7D52: db $02
L1D7D53: db $FE
L1D7D54: db $04
L1D7D55: db $FC
L1D7D56: db $0F
L1D7D57: db $07
L1D7D58: db $25
L1D7D59: db $FF
L1D7D5A: db $00
L1D7D5B: db $08
L1D7D5C: db $08
L1D7D5D: db $0F
L1D7D5E: db $09
L1D7D5F: db $10
L1D7D60: db $F8
L1D7D61: db $AF
L1D7D62: db $09
L1D7D63: db $30
L1D7D64: db $C8
L1D7D65: db $F0
L1D7D66: db $58
L1D7D67: db $18
L1D7D68: db $0A
L1D7D69: db $89 ; M
L1D7D6A: db $A5
L1D7D6B: db $0F
L1D7D6C: db $01
L1D7D6D: db $08
L1D7D6E: db $3E
L1D7D6F: db $FE
L1D7D70: db $01
L1D7D71: db $38
L1D7D72: db $28
L1D7D73: db $B6 ; M
L1D7D74: db $09
L1D7D75: db $3C
L1D7D76: db $49
L1D7D77: db $08
L1D7D78: db $1F
L1D7D79: db $08
L1D7D7A: db $01
L1D7D7B: db $0F
L1D7D7C: db $BF
L1D7D7D: db $00
L1D7D7E: db $07
L1D7D7F: db $00
L1D7D80: db $10
L1D7D81: db $29
L1D7D82: db $0C
L1D7D83: db $40
L1D7D84: db $08
L1D7D85: db $55
L1D7D86: db $00
L1D7D87: db $0C
L1D7D88: db $C1
L1D7D89: db $0C
L1D7D8A: db $81
L1D7D8B: db $08
L1D7D8C: db $01
L1D7D8D: db $7E
L1D7D8E: db $B5
L1D7D8F: db $0F
L1D7D90: db $83
L1D7D91: db $08
L1D7D92: db $03
L1D7D93: db $FE
L1D7D94: db $00
L1D7D95: db $10
L1D7D96: db $18
L1D7D97: db $56
L1D7D98: db $30
L1D7D99: db $08
L1D7D9A: db $70
L1D7D9B: db $08 ; M
L1D7D9C: db $F0
L1D7D9D: db $0A
L1D7D9E: db $01
L1D7D9F: db $7E
L1D7DA0: db $89
L1D7DA1: db $02
L1D7DA2: db $E4 ; M
L1D7DA3: db $FC
L1D7DA4: db $C4
L1D7DA5: db $08
L1D7DA6: db $C8
L1D7DA7: db $F8
L1D7DA8: db $0B
L1D7DA9: db $22
L1D7DAA: db $C9
L1D7DAB: db $F9
L1D7DAC: db $09
L1D7DAD: db $CB
L1D7DAE: db $FB
L1D7DAF: db $23
L1D7DB0: db $00
L1D7DB1: db $03
L1D7DB2: db $AA
L1D7DB3: db $00
L1D7DB4: db $F3
L1D7DB5: db $00
L1D7DB6: db $8F
L1D7DB7: db $D8
L1D7DB8: db $83
L1D7DB9: db $0A
L1D7DBA: db $C7
L1D7DBB: db $AA
L1D7DBC: db $0C
L1D7DBD: db $43
L1D7DBE: db $08
L1D7DBF: db $40
L1D7DC0: db $0A
L1D7DC1: db $60
L1D7DC2: db $08
L1D7DC3: db $E0
L1D7DC4: db $A8
L1D7DC5: db $08
L1D7DC6: db $F0
L1D7DC7: db $08
L1D7DC8: db $F8
L1D7DC9: db $08
L1D7DCA: db $C5
L1D7DCB: db $FD
L1D7DCC: db $89
L1D7DCD: db $2D
L1D7DCE: db $F9
L1D7DCF: db $09
L1D7DD0: db $08
L1D7DD1: db $08
L1D7DD2: db $40
L1D7DD3: db $09
L1D7DD4: db $10
L1D7DD5: db $70
L1D7DD6: db $AD
L1D7DD7: db $09
L1D7DD8: db $70
L1D7DD9: db $08
L1D7DDA: db $8F
L1D7DDB: db $88
L1D7DDC: db $09
L1D7DDD: db $87
L1D7DDE: db $0A
L1D7DDF: db $55
L1D7DE0: db $C7
L1D7DE1: db $08
L1D7DE2: db $C3
L1D7DE3: db $08
L1D7DE4: db $C0
L1D7DE5: db $0A
L1D7DE6: db $8E
L1D7DE7: db $0E
L1D7DE8: db $55
L1D7DE9: db $0C
L1D7DEA: db $0C
L1D7DEB: db $1C
L1D7DEC: db $08
L1D7DED: db $E0
L1D7DEE: db $0A
L1D7DEF: db $F0
L1D7DF0: db $08
L1D7DF1: db $6A
L1D7DF2: db $F8
L1D7DF3: db $08
L1D7DF4: db $01
L1D7DF5: db $7F
L1D7DF6: db $00
L1D7DF7: db $3F
L1D7DF8: db $00
L1D7DF9: db $1E
L1D7DFA: db $AA
L1D7DFB: db $00
L1D7DFC: db $18
L1D7DFD: db $38
L1D7DFE: db $38
L1D7DFF: db $0A
L1D7E00: db $70
L1D7E01: db $9A
L1D7E02: db $BF
L1D7E03: db $AD
L1D7E04: db $00
L1D7E05: db $79
L1D7E06: db $02
L1D7E07: db $33
L1D7E08: db $38
L1D7E09: db $0D
L1D7E0A: db $72 ; M
L1D7E0B: db $0E
L1D7E0C: db $0D
L1D7E0D: db $14
L1D7E0E: db $F7
L1D7E0F: db $2C
L1D7E10: db $EF
L1D7E11: db $F9
L1D7E12: db $09
L1D7E13: db $30
L1D7E14: db $0A
L1D7E15: db $5D
L1D7E16: db $70
L1D7E17: db $0A ; M
L1D7E18: db $F0
L1D7E19: db $0F
L1D7E1A: db $0A
L1D7E1B: db $01
L1D7E1C: db $FE
L1D7E1D: db $00
L1D7E1E: db $AA
L1D7E1F: db $9B ; M
L1D7E20: db $78
L1D7E21: db $0A
L1D7E22: db $3C
L1D7E23: db $08
L1D7E24: db $3E
L1D7E25: db $7A
L1D7E26: db $3F
L1D7E27: db $AB
L1D7E28: db $00
L1D7E29: db $03
L1D7E2A: db $18
L1D7E2B: db $07
L1D7E2C: db $08
L1D7E2D: db $0F
L1D7E2E: db $0E
L1D7E2F: db $49
L1D7E30: db $56
L1D7E31: db $00
L1D7E32: db $08
L1D7E33: db $81
L1D7E34: db $08
L1D7E35: db $C1
L1D7E36: db $0E ; M
L1D7E37: db $49
L1D7E38: db $01
L1D7E39: db $F7
L1D7E3A: db $0A
L1D7E3B: db $89
L1D7E3C: db $0F
L1D7E3D: db $09
L1D7E3E: db $83
L1D7E3F: db $08
L1D7E40: db $01
L1D7E41: db $3B
L1D7E42: db $55
L1D7E43: db $10
L1D7E44: db $08
L1D7E45: db $30
L1D7E46: db $08
L1D7E47: db $70
L1D7E48: db $08
L1D7E49: db $F0
L1D7E4A: db $0A
L1D7E4B: db $A6
L1D7E4C: db $01
L1D7E4D: db $80
L1D7E4E: db $06
L1D7E4F: db $40 ; M
L1D7E50: db $C0
L1D7E51: db $0B
L1D7E52: db $01
L1D7E53: db $0C
L1D7E54: db $96
L1D7E55: db $00
L1D7E56: db $0F
L1D7E57: db $0B
L1D7E58: db $08
L1D7E59: db $08
L1D7E5A: db $0F
L1D7E5B: db $09
L1D7E5C: db $3F
L1D7E5D: db $BA
L1D7E5E: db $00
L1D7E5F: db $FF
L1D7E60: db $01
L1D7E61: db $19
L1D7E62: db $09
L1D7E63: db $38
L1D7E64: db $08
L1D7E65: db $00
L1D7E66: db $C9
L1D7E67: db $0B
L1D7E68: db $89
L1D7E69: db $07
L1D7E6A: db $04
L1D7E6B: db $0D
L1D7E6C: db $03
L1D7E6D: db $02 ; M
L1D7E6E: db $0A
L1D7E6F: db $E7
L1D7E70: db $00
L1D7E71: db $AD
L1D7E72: db $0E
L1D7E73: db $01
L1D7E74: db $FE
L1D7E75: db $02
L1D7E76: db $28
L1D7E77: db $01
L1D7E78: db $AB
L1D7E79: db $19 ; M
L1D7E7A: db $C0
L1D7E7B: db $6A
L1D7E7C: db $10
L1D7E7D: db $0A
L1D7E7E: db $08
L1D7E7F: db $90
L1D7E80: db $00
L1D7E81: db $D6
L1D7E82: db $7A
L1D7E83: db $ED
L1D7E84: db $42
L1D7E85: db $0A
L1D7E86: db $82
L1D7E87: db $89
L1D7E88: db $08
L1D7E89: db $05
L1D7E8A: db $BF
L1D7E8B: db $0A
L1D7E8C: db $02
L1D7E8D: db $8C
L1D7E8E: db $11
L1D7E8F: db $19
L1D7E90: db $89
L1D7E91: db $59
L1D7E92: db $0B
L1D7E93: db $9B
L1D7E94: db $49
L1D7E95: db $3F
L1D7E96: db $C0
L1D7E97: db $00
L1D7E98: db $79
L1D7E99: db $F8
L1D7E9A: db $00
L1D7E9B: db $A9
L1D7E9C: db $D4
L1D7E9D: db $DC
L1D7E9E: db $09
L1D7E9F: db $1E
L1D7EA0: db $08
L1D7EA1: db $11
L1D7EA2: db $08
L1D7EA3: db $10
L1D7EA4: db $7F
L1D7EA5: db $D5
L1D7EA6: db $00
L1D7EA7: db $18 ; M
L1D7EA8: db $FE
L1D7EA9: db $7E
L1D7EAA: db $0F
L1D7EAB: db $08
L1D7EAC: db $08
L1D7EAD: db $08
L1D7EAE: db $7F
L1D7EAF: db $88
L1D7EB0: db $89
L1D7EB1: db $0A
L1D7EB2: db $B9
L1D7EB3: db $D9
L1D7EB4: db $79
L1D7EB5: db $11
L1D7EB6: db $02
L1D7EB7: db $BF
L1D7EB8: db $20
L1D7EB9: db $8F
L1D7EBA: db $9A
L1D7EBB: db $B9
L1D7EBC: db $D9
L1D7EBD: db $49
L1D7EBE: db $8C
L1D7EBF: db $19
L1D7EC0: db $AB
L1D7EC1: db $00
L1D7EC2: db $7F
L1D7EC3: db $08
L1D7EC4: db $3F
L1D7EC5: db $08
L1D7EC6: db $0E
L1D7EC7: db $6A
L1D7EC8: db $19
L1D7EC9: db $6B
L1D7ECA: db $11
L1D7ECB: db $0A
L1D7ECC: db $01
L1D7ECD: db $C0
L1D7ECE: db $08
L1D7ECF: db $80
L1D7ED0: db $EC
L1D7ED1: db $0D
L1D7ED2: db $FF
L1D7ED3: db $9B
L1D7ED4: db $09
L1D7ED5: db $FB
L1D7ED6: db $09
L1D7ED7: db $11
L1D7ED8: db $AF
L1D7ED9: db $0D
L1D7EDA: db $7A
L1D7EDB: db $6A
L1D7EDC: db $FE
L1D7EDD: db $00
L1D7EDE: db $20
L1D7EDF: db $01
L1D7EE0: db $6E
L1D7EE1: db $0E ; M
L1D7EE2: db $08
L1D7EE3: db $11
L1D7EE4: db $BD
L1D7EE5: db $08
L1D7EE6: db $20
L1D7EE7: db $60
L1D7EE8: db $69
L1D7EE9: db $01
L1D7EEA: db $8D
L1D7EEB: db $02
L1D7EEC: db $08
L1D7EED: db $55
L1D7EEE: db $05
L1D7EEF: db $0A
L1D7EF0: db $27
L1D7EF1: db $08
L1D7EF2: db $21
L1D7EF3: db $BA
L1D7EF4: db $0F
L1D7EF5: db $8C
L1D7EF6: db $D6
L1D7EF7: db $11
L1D7EF8: db $19
L1D7EF9: db $08
L1D7EFA: db $5A
L1D7EFB: db $10
L1D7EFC: db $0A
L1D7EFD: db $49
L1D7EFE: db $1F
L1D7EFF: db $6F
L1D7F00: db $E0
L1D7F01: db $00
L1D7F02: db $79
L1D7F03: db $FE
L1D7F04: db $00
L1D7F05: db $A9
L1D7F06: db $00
L1D7F07: db $19
L1D7F08: db $AF
L1D7F09: db $EB
L1D7F0A: db $04
L1D7F0B: db $08
L1D7F0C: db $06
L1D7F0D: db $09
L1D7F0E: db $A0
L1D7F0F: db $00
L1D7F10: db $7A
L1D7F11: db $55
L1D7F12: db $01
L1D7F13: db $7C
L1D7F14: db $11
L1D7F15: db $08
L1D7F16: db $31
L1D7F17: db $0A
L1D7F18: db $85
L1D7F19: db $08
L1D7F1A: db $5F
L1D7F1B: db $84
L1D7F1C: db $08
L1D7F1D: db $44
L1D7F1E: db $0A
L1D7F1F: db $79
L1D7F20: db $11
L1D7F21: db $02
L1D7F22: db $20
L1D7F23: db $59
L1D7F24: db $51
L1D7F25: db $08
L1D7F26: db $91
L1D7F27: db $0C
L1D7F28: db $49
L1D7F29: db $F8
L1D7F2A: db $07
L1D7F2B: db $00
L1D7F2C: db $FA
L1D7F2D: db $7A
L1D7F2E: db $03
L1D7F2F: db $48
L1D7F30: db $6A
L1D7F31: db $09
L1D7F32: db $F0
L1D7F33: db $08
L1D7F34: db $01
L1D7F35: db $BD
L1D7F36: db $09
L1D7F37: db $7E
L1D7F38: db $00
L1D7F39: db $7A
L1D7F3A: db $19
L1D7F3B: db $7B
L1D7F3C: db $E0
L1D7F3D: db $08
L1D7F3E: db $7F
L1D7F3F: db $10
L1D7F40: db $2C
L1D7F41: db $19
L1D7F42: db $B9
L1D7F43: db $D9
L1D7F44: db $8B
L1D7F45: db $11
L1D7F46: db $AD
L1D7F47: db $EB
L1D7F48: db $09 ; M
L1D7F49: db $AB
L1D7F4A: db $5A
L1D7F4B: db $1F
L1D7F4C: db $00
L1D7F4D: db $07
L1D7F4E: db $00
L1D7F4F: db $28
L1D7F50: db $55
L1D7F51: db $F8
L1D7F52: db $4A
L1D7F53: db $1E
L1D7F54: db $08
L1D7F55: db $21
L1D7F56: db $08
L1D7F57: db $5C
L1D7F58: db $08
L1D7F59: db $73
L1D7F5A: db $52
L1D7F5B: db $19
L1D7F5C: db $60
L1D7F5D: db $01
L1D7F5E: db $08
L1D7F5F: db $F0
L1D7F60: db $F8
L1D7F61: db $0C
L1D7F62: db $4E
L1D7F63: db $90
L1D7F64: db $09
L1D7F65: db $E0
L1D7F66: db $A0
L1D7F67: db $9A
L1D7F68: db $C9
L1D7F69: db $E9
L1D7F6A: db $00
L1D7F6B: db $F6
L1D7F6C: db $0E
L1D7F6D: db $00
L1D7F6E: db $89
L1D7F6F: db $08
L1D7F70: db $20
L1D7F71: db $0F
L1D7F72: db $F8
L1D7F73: db $10
L1D7F74: db $C0
L1D7F75: db $08
L1D7F76: db $00
L1D7F77: db $00
BG_LagunaLogo: db $00
L1D7F79: db $00
L1D7F7A: db $02
L1D7F7B: db $00
L1D7F7C: db $05
L1D7F7D: db $06
L1D7F7E: db $09
L1D7F7F: db $0A
L1D7F80: db $0D
L1D7F81: db $0E
L1D7F82: db $11
L1D7F83: db $12
L1D7F84: db $00
L1D7F85: db $00
L1D7F86: db $00
L1D7F87: db $00
L1D7F88: db $00
L1D7F89: db $01
L1D7F8A: db $03
L1D7F8B: db $04
L1D7F8C: db $07
L1D7F8D: db $08
L1D7F8E: db $0B
L1D7F8F: db $0C
L1D7F90: db $0F
L1D7F91: db $10
L1D7F92: db $13
L1D7F93: db $14
L1D7F94: db $15
L1D7F95: db $16
L1D7F96: db $17
L1D7F97: db $00
L1D7F98: db $00
L1D7F99: db $18
L1D7F9A: db $1A
L1D7F9B: db $1B
L1D7F9C: db $1E
L1D7F9D: db $1F
L1D7F9E: db $22
L1D7F9F: db $23
L1D7FA0: db $26
L1D7FA1: db $27
L1D7FA2: db $2A
L1D7FA3: db $2B
L1D7FA4: db $2E
L1D7FA5: db $2F
L1D7FA6: db $00 ; M
L1D7FA7: db $00
L1D7FA8: db $00
L1D7FA9: db $19
L1D7FAA: db $1C
L1D7FAB: db $1D
L1D7FAC: db $20
L1D7FAD: db $21
L1D7FAE: db $24
L1D7FAF: db $25
L1D7FB0: db $28
L1D7FB1: db $29
L1D7FB2: db $2C
L1D7FB3: db $2D
L1D7FB4: db $30
L1D7FB5: db $31
L1D7FB6: db $32
L1D7FB7: db $00
L1D7FB8: db $33
L1D7FB9: db $34
L1D7FBA: db $37
L1D7FBB: db $38
L1D7FBC: db $3B
L1D7FBD: db $3C
L1D7FBE: db $3F
L1D7FBF: db $40
L1D7FC0: db $43
L1D7FC1: db $44
L1D7FC2: db $47
L1D7FC3: db $48
L1D7FC4: db $4B
L1D7FC5: db $4C
L1D7FC6: db $4F
L1D7FC7: db $50
L1D7FC8: db $35
L1D7FC9: db $36
L1D7FCA: db $39
L1D7FCB: db $3A
L1D7FCC: db $3D
L1D7FCD: db $3E
L1D7FCE: db $41
L1D7FCF: db $42 ; M
L1D7FD0: db $45
L1D7FD1: db $46
L1D7FD2: db $49
L1D7FD3: db $4A
L1D7FD4: db $4D
L1D7FD5: db $4E
L1D7FD6: db $51
L1D7FD7: db $52

; =============== END OF BANK ===============
	mIncJunk "L1D7FD8"
ENDC