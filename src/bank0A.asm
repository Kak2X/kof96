INCLUDE "data/objlst/char/ryo_mrkarate.asm"
INCLUDE "data/objlst/char/leona.asm"

; 
; =============== START OF MODULE TakaraLogo ===============
;
; =============== Module_TakaraLogo ===============
; EntryPoint for TakaraLogo. Called as first task by the task handler.
Module_TakaraLogo:
	ld   sp, $DD00
	
IF REV_LOGO_EN == 1
	; LAGUNA ENTERTAINMENT PROUDLY PRESENT
	; a game without 96 in the title
	call LagunaLogo_Do
ENDC
	call TakaraLogo_Do
	
	; Determine which SGB border to load.
	ld   a, BORDER_MAIN
	ld   hl, wDipSwitch
	bit  DIPB_UNLOCK_OTHER, [hl]	; Was the code to unlock "all" characters entered?
	jr   z, .loadBorder				; If not, jump
	ld   a, BORDER_ALTERNATE		; Otherwise, use the alternate border
.loadBorder:
	call SGB_LoadBorder
	
	; Switch module
	ld   b, BANK(Module_Intro)
	ld   hl, Module_Intro
	rst  $00

IF REV_LOGO_EN == 1
; =============== LagunaLogo_Do ===============
; Main code for displaying the Laguna logo.
LagunaLogo_Do:
	di
	; Set base bank (self)
	ld   a, BANK(Module_TakaraLogo) 
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	;-----------------------------------
	rst  $10				; Stop LCD
	
	; Use screen continuously
	ld   hl, wMisc_C028
	ld   [hl], $00
	
	; Reset DMG Pal
	xor  a
	ldh  [rBGP], a
	ldh  [rOBP0], a
	ldh  [rOBP1], a
	
	ld   de, SCRPAL_LAGUNALOGO
	call HomeCall_SGB_ApplyScreenPalSet
	
	call ClearBGMap
	call ClearWINDOWMap
	
	; Reset coords
	xor  a
	ldh  [hScrollX], a
	ldh  [hScrollY], a
	
	; Load the graphics/tilemap for the screen, which were thrown elsewhere
	ld   b, BANK(LagunaLogo_LoadVRAM) ; BANK $1D
	ld   hl, LagunaLogo_LoadVRAM
	rst  $08

	; Wipe sprites
	call ClearOBJInfo
	
	; Disable window 
	xor  a
	ldh  [rWY], a
	ldh  [rWX], a
	ldh  [rSTAT], a
	
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_WTILEMAP|LCDC_ENABLE
	rst  $18				; Resume LCD
	;-----------------------------------
	ei
	; (VBlank will hit now) 
	call Task_PassControl_NoDelay
	
	; Set DMG palettes
	ld   a, $E4
	ldh  [rOBP0], a
	ld   a, $FF
	ldh  [rOBP1], a
	ld   a, $E4
	ldh  [rBGP], a
	
	; Mute sound
	ld   a, SND_MUTE
	call HomeCall_Sound_ReqPlayExId_Stub
	
	; Show this screen for 180 frames
	ld   bc, $00B4
.mainLoop:	
	call Task_PassControl_NoDelay	; Pass control
	dec  bc						; FramesLeft--
	ld   a, b
	or   a, c					; FramesLeft == 0?
	jp   nz, .mainLoop			; If not, loop
.end:
	ret							; Otherwise we're done
ENDC
	
; =============== TakaraLogo_Do ===============
; Main code for displaying the Takara logo.
TakaraLogo_Do:

	di
	; Set base bank (self)
	ld   a, BANK(Module_TakaraLogo) 
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	;-----------------------------------
	rst  $10				; Stop LCD
	
	; Reset DMG Pal
	xor  a
	ldh  [rBGP], a
	ldh  [rOBP0], a
	ldh  [rOBP1], a
	
	; Use screen continuously
	ld   hl, wMisc_C028
	ld   [hl], $00
	
	ld   de, SCRPAL_TAKARALOGO
	call HomeCall_SGB_ApplyScreenPalSet
	
	call ClearBGMap
	call ClearWINDOWMap
	
	; Reset coords
IF REV_VER_2 == 0
	xor  a
	ldh  [hScrollX], a 
	ldh  [hScrollY], a 
ELSE
	xor  a
	ldh  [hScrollX], a
	ld   a, -$04
	ldh  [hScrollY], a
ENDC

	; Copy logo GFX
	ld   hl, GFXLZ_TakaraLogo
	ld   de, wLZSS_Buffer
	call DecompressLZSS
	ld   hl, wLZSS_Buffer
	ld   de, $9000
	call CopyTiles
	
	; Copy logo tilemap. The newer logo is shorter.
	ld   de, BG_TakaraLogo
IF REV_VER_2 == 0
	ld   hl, $98C2	; VRAM Destination
	ld   b, $10		; Width
	ld   c, $05		; Height
ELSE
	ld   hl, $98E2	; VRAM Destination
	ld   b, $10		; Width
	ld   c, $03		; Height
ENDC
	call CopyBGToRect
	
	; Wipe sprites
	call ClearOBJInfo
	
	; Disable window 
	xor  a
	ldh  [rWY], a
	ldh  [rWX], a
	ldh  [rSTAT], a
	
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_WTILEMAP|LCDC_ENABLE
	rst  $18				; Resume LCD
	;-----------------------------------
	ei
	; (VBlank will hit now)
	call Task_PassControl_NoDelay
	
	; Set DMG palette for sprites
	ld   a, $E4
	ldh  [rOBP0], a
	ld   a, $FF
	ldh  [rOBP1], a
	
	; And for the logo itself
IF REV_VER_2 == 0
	; Always white text on black background
	ld   a, $93
	ldh  [rBGP], a
ELSE
	
	;
	; The palette depends on the hardware.
	;
	; On a DMG, it uses black text on a white background for some reason,
	; while the proper palette is used for SGB mode (to have red text on black background).
	;
	
	ld   a, [wMisc_C025]
	bit  MISCB_IS_SGB, a	; Running on SGB?
	jp   z, .setDMGPal		; If not, jump
.setSGBPal:
	ld   a, $93				; W on B
	jp   .setPal
.setDMGPal:
	ld   a, $6C				; B on W
.setPal:
	ldh  [rBGP], a
ENDC

	; Mute sound
	ld   a, SND_MUTE
	call HomeCall_Sound_ReqPlayExId_Stub
	
	; Initialize variables for cheat count (on top of the LZSS buffer)
	ld   hl, wCheatGoenitzKeysLeft
	ld   a, 3		; wCheatGoenitzKeysLeft
	ldi  [hl], a
	ld   a, 20		; wCheatAllCharKeysLeft
	ldi  [hl], a
	ld   a, 25		; wCheat_Unused_KeysLeft [TCRF] Not used, may have been for DIPB_TEAM_DUPL and DIPB_POWERUP
	ldi  [hl], a
	ld   a, 30		; wCheatEasyMovesKeysLeft
	ldi  [hl], a
	
	; Show this screen for 360 frames (+ whatever it takes for the SGB features to load)
	ld   bc, $0168				
	
.mainLoop:
	call TakaraLogo_CheckCheat
	
	
	; When pressing START from either controller, skip the delay
	; This got removed in the English version!
IF REV_LOGO_EN == 0
	ldh  a, [hJoyNewKeys]
	ld   d, a
	ldh  a, [hJoyNewKeys2]
	or   a, d
	bit  KEYB_START, a			; Start pressed?
	jp   nz, .end				; If so, jump
ENDC

.chkWait:	
	call Task_PassControl_NoDelay	; Pass control
	dec  bc						; FramesLeft--
	ld   a, b
	or   a, c					; FramesLeft == 0?
	jp   nz, .mainLoop			; If not, loop
.end:
	ret							; Otherwise we're done
	
; =============== TakaraLogo_CheckCheat ===============
; Activates dip switches when certain button combinations are pressed X times.
TakaraLogo_CheckCheat:

	ld   hl, hJoyKeys
	ld   d, [hl]			; D = Held keys
	inc  hl
	ld   e, [hl]			; E = Newly pressed keys
	ld   hl, wDipSwitch		; HL = Dip switches
	
.chkTeamDupeInfMeter:
	;
	; Duplicate chars in team + Powerup POW meter
	; Hold A + B + SELECT
	;
	bit  KEYB_SELECT, e					; Pressed SELECT?
	jp   z, .chkGoenitz					; If not, skip
	bit  DIPB_TEAM_DUPL, [hl]			; Already unlocked?
	jp   nz, .chkGoenitz				; If so, skip
	ld   a, d
	and  a, KEY_A|KEY_B|KEY_SELECT		; Holding the button combination?
	cp   KEY_A|KEY_B|KEY_SELECT
	jp   nz, .chkGoenitz				; If not, skip
	; Set cheats
	set  DIPB_TEAM_DUPL, [hl]
	set  DIPB_POWERUP, [hl]
	; Play SGB sound
	push hl
		ld   hl, (SGB_SND_A_CUPBREAK << 8)|$01
		call SGB_PrepareSoundPacketA
		ld   a, SFX_CURSORMOVE
		call HomeCall_Sound_ReqPlayExId
	pop  hl
	
.chkGoenitz:
	;
	; Unlock Goenitz
	; Press SELECT 3 times.
	;
	bit  KEYB_SELECT, e					; Pressed SELECT?
	jp   z, .chkAllChar					; If not, skip
	bit  DIPB_UNLOCK_GOENITZ, [hl]		; Already unlocked?
	jp   nz, .chkAllChar				; If so, skip
	
	; Decrement key counter. If 0, enable the cheat
	ld   a, [wCheatGoenitzKeysLeft]
	dec  a								
	ld   [wCheatGoenitzKeysLeft], a		
	jp   nz, .chkAllChar				
	set  DIPB_UNLOCK_GOENITZ, [hl]
	push hl
		ld   hl, (SGB_SND_A_ESCBUBL << 8)|$00
		call SGB_PrepareSoundPacketA
		ld   a, SFX_CHARSELECTED
		call HomeCall_Sound_ReqPlayExId
	pop  hl
	
.chkAllChar:
	;
	; Unlock other characters
	; Press SELECT 20 times.
	;
	bit  KEYB_SELECT, e				; Pressed SELECT?
	jp   z, .chkEasyMovesSGB					; If not, skip
	bit  DIPB_UNLOCK_OTHER, [hl]	; Already unlocked?
	jp   nz, .chkEasyMovesSGB				; If so, skip
	
	; Decrement key counter. If 0, enable the cheat
	; This is decremented simultaneously with the Goenitz counter.
	ld   a, [wCheatAllCharKeysLeft]
	dec  a
	ld   [wCheatAllCharKeysLeft], a
	jp   nz, .chkEasyMovesSGB
	
	set  DIPB_UNLOCK_OTHER, [hl]
	push hl
		ld   hl, (SGB_SND_A_ESCBUBL << 8)|$01
		call SGB_PrepareSoundPacketA
		ld   a, SFX_SUPERMOVE
		call HomeCall_Sound_ReqPlayExId
	pop  hl
	
.chkEasyMovesSGB:
	;
	; Easy Moves + SGB Sound Test
	; Press LEFT + A + B + SELECT 30 times.
	; (can be done by holding LEFT + A + B and tapping SELECT 30 times)
	;
	bit  KEYB_SELECT, e				; Pressed SELECT?
	jp   z, .end					; If not, skip
	ld   a, d
	and  a, KEY_LEFT|KEY_A|KEY_B|KEY_SELECT	; Holding the button combination?
	cp   KEY_LEFT|KEY_A|KEY_B|KEY_SELECT
	jp   nz, .end					; If not, skip
	bit  DIPB_EASY_MOVES, [hl]		; Already unlocked?
	jp   nz, .end					; If so, skip
	
	; Decrement key counter. If 0, enable the cheat
	ld   a, [wCheatEasyMovesKeysLeft]
	dec  a
	ld   [wCheatEasyMovesKeysLeft], a
	jp   nz, .end
	
	set  DIPB_EASY_MOVES, [hl]
	set  DIPB_SGB_SOUND_TEST, [hl]
	push hl
		ld   hl, (SGB_SND_A_PUNCH_A << 8)|$01
		call SGB_PrepareSoundPacketA
		ld   a, SFX_FIREHIT_B
		call HomeCall_Sound_ReqPlayExId
	pop  hl
.end:
	ret
IF REV_VER_2 == 0
GFXLZ_TakaraLogo: INCBIN "data/gfx/jp/takaralogo.lzc"
BG_TakaraLogo: INCBIN "data/bg/jp/takaralogo.bin"
ELSE
GFXLZ_TakaraLogo: INCBIN "data/gfx/en/takaralogo.lzc"
BG_TakaraLogo: INCBIN "data/bg/en/takaralogo.bin"
ENDC
; 
; =============== END OF MODULE TakaraLogo ===============
;

; =============== MoveInputReader_Goenitz ===============
; Special move input checker for GOENITZ.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
; OUT
; - C flag: If set, a move was started
MoveInputReader_Goenitz:
	mMvIn_Validate Goenitz
	
	; This character handles the super desperations differently.
	; Both the normal and desperation supers have light/heavy variations,
	; which is why it's using mMvIn_JpSD to then jump to the light/heavy check.
	
	; Only the heavy versions can be started in the air.
	
.chkAir:
	;             SELECT + B                            SELECT + A
	mMvIn_ChkEasy .startAirPunchSuper, MoveInit_Goenitz_Hyouga.heavy
	mMvIn_ChkGA Goenitz, .chkAirPunch, .chkAirKick
.chkAirPunch:
	; DBDF+P (air) -> Shinyaotome Mizuchi / Shinyaotome Jissoukoku (always heavy)
	mMvIn_ValSuper .chkAirPunchNoSuper
	mMvIn_ChkDirNot MoveInput_DBDF, .chkAirPunchNoSuper
.startAirPunchSuper:
	mMvIn_JpSD MoveInit_Goenitz_ShinyaotomeMizuchi.heavy, MoveInit_Goenitz_ShinyaotomeJissoukoku.heavy
.chkAirPunchNoSuper:
	jp   MoveInputReader_Goenitz_NoMove
.chkAirKick:
	; DB+K (air) -> Hyouga
	mMvIn_ChkDir MoveInput_DB, MoveInit_Goenitz_Hyouga.heavy
	jp   MoveInputReader_Goenitz_NoMove
	
.chkGround:
	;             SELECT + B                               SELECT + A
	mMvIn_ChkEasy .startPunchSuper, MoveInit_Goenitz_Yamidoukoku
	mMvIn_ChkGA Goenitz, .chkPunch, .chkKick
.chkPunch:
	; DBDF+P -> Shinyaotome Mizuchi / Shinyaotome Jissoukoku 
	mMvIn_ValSuper .chkPunchNoSuper
	mMvIn_ChkDirNot MoveInput_DBDF, .chkPunchNoSuper
.startPunchSuper:
	mMvIn_JpSD MoveInit_Goenitz_ShinyaotomeMizuchi, MoveInit_Goenitz_ShinyaotomeJissoukoku
.chkPunchNoSuper:
	; FDBx2+P -> Yamidoukoku (Other super move)
	mMvIn_ChkDir MoveInput_FDBFDB, MoveInit_Goenitz_Yamidoukoku
	; BDF+P -> Yonokaze (Near)
	mMvIn_ChkDir MoveInput_BDF, MoveInit_Goenitz_YonokazeNear
	; DB+P -> Wanpyou Tokobuse
	mMvIn_ChkDir MoveInput_DB, MoveInit_Goenitz_WanpyouTokobuse
	jp   MoveInputReader_Goenitz_NoMove
.chkKick:
	; BDF+K -> Yonokaze (Far)
	mMvIn_ChkDir MoveInput_BDF, MoveInit_Goenitz_YonokazeFar
	; DB+K -> Hyouga
	mMvIn_ChkDir MoveInput_DB, MoveInit_Goenitz_Hyouga
	jp   MoveInputReader_Goenitz_NoMove
	
; =============== MoveInit_Goenitz_YonokazeNear ===============
MoveInit_Goenitz_YonokazeNear:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_GOENITZ_YONOKAZE1, MOVE_GOENITZ_YONOKAZE2
	call MoveInputS_SetSpecMove_StopSpeed
	call Play_Proj_CopyMoveDamageFromPl
	jp   MoveInputReader_Goenitz_SetMove
; =============== MoveInit_Goenitz_YonokazeFar ===============
MoveInit_Goenitz_YonokazeFar:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_GOENITZ_YONOKAZE3, MOVE_GOENITZ_YONOKAZE4
	call MoveInputS_SetSpecMove_StopSpeed
	call Play_Proj_CopyMoveDamageFromPl
	jp   MoveInputReader_Goenitz_SetMove
; =============== MoveInit_Goenitz_Hyouga ===============
MoveInit_Goenitz_Hyouga:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_GOENITZ_HYOUGA_L, MOVE_GOENITZ_HYOUGA_H
	call MoveInputS_SetSpecMove_StopSpeed
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_INVULN, [hl]
	inc  hl
	set  PF2B_NOCOLIBOX, [hl]
	jp   MoveInputReader_Goenitz_SetMove
; =============== MoveInit_Goenitz_WanpyouTokobuse ===============
MoveInit_Goenitz_WanpyouTokobuse:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_GOENITZ_WANPYOU_TOKOBUSE_L, MOVE_GOENITZ_WANPYOU_TOKOBUSE_H
	call MoveInputS_SetSpecMove_StopSpeed
	call Play_Proj_CopyMoveDamageFromPl
	jp   MoveInputReader_Goenitz_SetMove
; =============== MoveInit_Goenitz_Yamidoukoku ===============
; Extra super move.
MoveInit_Goenitz_Yamidoukoku:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_ValStartCmdThrow_StdColi Goenitz
	mMvIn_GetLH MOVE_GOENITZ_YAMIDOUKOKU_SL, MOVE_GOENITZ_YAMIDOUKOKU_SH
	call MoveInputS_SetSpecMove_StopSpeed
	; We want this to be a super move, even though it's not in a slot reserved for one.
	; So we've got to set it up manually.
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	set  PF0B_SUPERMOVE, [hl]
	inc  hl
	set  PF1B_INVULN, [hl]
	; The super sparkle is offset, unlike the normal one
	ld   hl, $08F0
	call Play_StartSuperSparkle
	jp   MoveInputReader_Goenitz_SetMove
; =============== MoveInit_Goenitz_ShinyaotomeMizuchi ===============
; Super move.
MoveInit_Goenitz_ShinyaotomeMizuchi:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_GOENITZ_SHINYAOTOME_MIZUCHI_SL, MOVE_GOENITZ_SHINYAOTOME_MIZUCHI_SH
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Goenitz_SetMove
; =============== MoveInit_Goenitz_ShinyaotomeJissoukoku ===============
; Desperation super.
MoveInit_Goenitz_ShinyaotomeJissoukoku:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_GOENITZ_SHINYAOTOME_JISSOUKOKU_DL, MOVE_GOENITZ_SHINYAOTOME_JISSOUKOKU_DH
	call MoveInputS_SetSpecMove_StopSpeed
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_INVULN, [hl]
	jp   MoveInputReader_Goenitz_SetMove
; =============== MoveInputReader_Goenitz_SetMove ===============
MoveInputReader_Goenitz_SetMove:
	scf
	ret
; =============== MoveInputReader_Goenitz_NoMove ===============
MoveInputReader_Goenitz_NoMove:
	or   a
	ret
	
; =============== MoveC_Goenitz_Yonokaze ===============
; Move code for Goenitz's Yonokaze (MOVE_GOENITZ_YONOKAZE1, MOVE_GOENITZ_YONOKAZE2, MOVE_GOENITZ_YONOKAZE3, MOVE_GOENITZ_YONOKAZE4).
MoveC_Goenitz_Yonokaze:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj2
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim
; --------------- frame #2 ---------------
.obj2:
	mMvC_ValFrameStart .obj2_cont
		; Pick a different spawn distance depending on the move started.
		; Store it to H and clear L for later.
		ld   hl, iPlInfo_MoveId
		add  hl, bc
		ld   a, [hl]				; A = iPlInfo_MoveId
		cp   MOVE_GOENITZ_YONOKAZE2	; A == MOVE_GOENITZ_YONOKAZE2?
		jp   z, .obj2_type2			; If so, jump
		cp   MOVE_GOENITZ_YONOKAZE3	; ...
		jp   z, .obj2_type3
		cp   MOVE_GOENITZ_YONOKAZE4
		jp   z, .obj2_type4
	.obj2_type1:
		ld   hl, $1000				; H = $10px forward
		jp   .obj2_chkE
	.obj2_type2:
		ld   hl, $3000				; H = $30px forward
		jp   .obj2_chkE
	.obj2_type3:
		ld   hl, $5000				; H = $50px forward
		jp   .obj2_chkE
	.obj2_type4:
		ld   hl, $7000				; H = $70px forward
		
	.obj2_chkE:
		; Determine if the wind projectile should move forward or not.
		; [POI] It moves forward only with the hidden heavy.
		push hl
			call MoveInputS_CheckMoveLHVer	; Performed an hidden heavy? 
			jp   nc, .obj2_verLH			; If not, jump
		.obj2_verE:
		pop  hl
		ld   l, $04							; L = 4px/frame
		call ProjInit_Goenitz_Yonokaze
		jp   .anim
		.obj2_verLH:
		pop  hl								; L = 0
		call ProjInit_Goenitz_Yonokaze
.obj2_cont:
	jp   .anim
; --------------- frame #5 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jp   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Goenitz_HyougaL ===============
; Move code for the light version of Goenitz's Hyouga (MOVE_GOENITZ_HYOUGA_L).
; This is a long ground dash.
MoveC_Goenitz_HyougaL:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj2
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj3
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim
; --------------- frame #1 ---------------
.obj1:
	; Player is invulnerable until $0A frames into #2
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $05
		ld   hl, iPlInfo_Goenitz_Hyouga_InvulnTimer
		add  hl, bc
		ld   [hl], $0A
		jp   .anim
; --------------- frame #2 ---------------
.obj2:
	mMvC_ValFrameStart .obj2_cont
		mMvC_PlaySound SCT_MOVEJUMP_A
		mMvC_SetSpeedH +$0700
.obj2_cont:
	; Remove invulnerability when the timer elapses.
	; Dubious timer check since it doesn't check for underflow.
	ld   hl, iPlInfo_Goenitz_Hyouga_InvulnTimer
	add  hl, bc
	dec  [hl]
	jp   nz, .moveH
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	res  PF1B_INVULN, [hl]
	jp   .moveH
; --------------- frame #3 ---------------
.obj3:
	; Allow chaining into other specials from this
	mMvC_ValFrameStart .obj3_cont
		ld   hl, iPlInfo_Flags0
		add  hl, bc
		res  PF0B_SPECMOVE, [hl]
		inc  hl			; Seek to iPlInfo_Flags1
		res  PF1B_NOSPECSTART, [hl]
.obj3_cont:
	; [TCRF] / [BUG] Was invulnerability meant to last until #3?
	; #2 already decremented the timer to 0 (and underflowed it), so we never get to
	; execute the mMvC_ValFrameEnd part (not like it makes much difference).
	; The timer check here is also bad since it doesn't check for underflow.
IF FIX_BUGS == 0
	ld   hl, iPlInfo_Goenitz_Hyouga_InvulnTimer
	add  hl, bc
	dec  [hl]
	jp   nz, .moveH
	;##
	; We never get here
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	res  PF1B_INVULN, [hl]
ENDC
	mMvC_ValFrameEnd .moveH
		mMvC_SetAnimSpeed $03
		jp   .moveH
	;##
; --------------- frame #4 ---------------
.chkEnd:
	mMvC_DoFrictionH $0080
	mMvC_ValFrameEnd .anim
		jp   .end
; --------------- common ---------------
.moveH:
	call OBJLstS_ApplyXSpeed
	jp   .anim
.end:
	call Play_Pl_EndMove
	jr   .ret
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Goenitz_HyougaH ===============
; Move code for the hard version of Goenitz's Hyouga (MOVE_GOENITZ_HYOUGA_H).
; This is a long air dash that can also be started on the ground.
MoveC_Goenitz_HyougaH:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj2
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		; Player is invulnerable until $0A frames into #2
		ld   hl, iPlInfo_Goenitz_Hyouga_InvulnTimer
		add  hl, bc
		ld   [hl], $0A
		jp   .anim
; --------------- frame #2 ---------------
.obj2:
	mMvC_ValFrameStart .obj2_cont
		mMvC_PlaySound SCT_MOVEJUMP_A
		
		;
		; Determine by how much to move the player up, while the player is hidden
		; in the first frame #2 starts.
		;
		
		; If this move was started while on the ground, move up by $20px so we won't just end it immediately.
		ld   hl, iOBJInfo_Y
		add  hl, de
		ld   a, [hl]				; A = YPos
		cp   PL_FLOOR_POS			; YPos != PL_FLOOR_POS
		jp   nz, .obj2_setOffsetA	; If so, jump
	.obj2_setOffsetG:
		ld   hl, -$2000		; HL = $20px up
		jp   .obj2_moveUp
	.obj2_setOffsetA:
		; If we did it in the air, move up by $08px if we aren't too close to the top of the screen.
		ld   hl, iOBJInfo_Y
		add  hl, de
		ld   a, [hl]				; A = YPos
		cp   $08					; YPos < $08?
		jp   c, .obj2_setDashSpeed	; If so, skip (don't underflow the Y coord)
		ld   hl, -$0800				; HL = $08px up
	.obj2_moveUp:
		call Play_OBJLstS_MoveV
	.obj2_setDashSpeed:
		; Dash forwards in the air
		mMvC_SetSpeedH +$0700
		mMvC_SetSpeedV +$0000
		
		; [POI] The hidden heavy version can chain into other specials
		call MoveInputS_CheckMoveLHVer
		jp   nc, .anim
		ld   hl, iPlInfo_Flags0
		add  hl, bc
		res  PF0B_SPECMOVE, [hl]
		inc  hl			; Seek to iPlInfo_Flags1
		res  PF1B_NOSPECSTART, [hl]
		jp   .anim
	
.obj2_cont:
	; Handle invulnerability timer. When it elapses we aren't invulnerable anymore.
	ld   hl, iPlInfo_Goenitz_Hyouga_InvulnTimer
	add  hl, bc
	dec  [hl]				; Timer--
	jp   nz, .doGravity		; Timer != 0? If so, skip
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	res  PF1B_INVULN, [hl]	; No more invulnerable
	jp   .doGravity
	
.doGravity:
	; Move down at $00.18px/frame, switch to #3 when touching the ground
	mMvC_ChkGravityHV $0018, .anim
	mMvC_SetLandFrame $03*OBJLSTPTR_ENTRYSIZE, $03
	jp   .ret
; --------------- frame #3 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Goenitz_WanpyouTokobuse ===============
; Move code for Goenitz's Wanpyou Tokobuse (MOVE_GOENITZ_WANPYOU_TOKOBUSE_L, MOVE_GOENITZ_WANPYOU_TOKOBUSE_H).
MoveC_Goenitz_WanpyouTokobuse:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj2
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameStart .obj1_cont
		mMvC_PlaySound SCT_GRAB
.obj1_cont:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $1E
		jp   .anim
; --------------- frame #2 ---------------
.obj2:
	; Set the projectile's origin, relative to the player's, depending on the move strength.
	; The heavy version is $18px above the light one.
	mMvC_ValFrameStart .obj2_cont
		mMvIn_ChkLH .obj2_setPosH
	.obj2_setPosL: ; Light
		mkhl $1C, $00 ; $1Cpx fwd
		ld   hl, CHL
		jp   .obj2_initProj
	.obj2_setPosH: ; Heavy
		mkhl $18, -$18 ; $18px fwd, $18px up
		ld   hl, CHL
	.obj2_initProj:
		call ProjInit_Goenitz_WanpyouTokobuse
.obj2_cont:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $02
		jp   .anim
; --------------- frame #4 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jp   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Goenitz_Yamidoukoku ===============
; Move code for Goenitz's Yamidoukoku (MOVE_GOENITZ_YAMIDOUKOKU_SL, MOVE_GOENITZ_YAMIDOUKOKU_SH).
MoveC_Goenitz_Yamidoukoku:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj0
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj2
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj3
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameStart .obj0_cont
		mMvC_SetDamage $06, HITTYPE_THROW_ROTU, PF3_HEAVYHIT
		mMvC_MoveThrowOp -$10, -$10
.obj0_cont:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $06
		jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameStart .anim
		mMvC_SetDamage $06, HITTYPE_THROW_ROTU, PF3_HEAVYHIT
		mMvC_MoveThrowOp -$10, -$11
		jp   .anim
; --------------- frame #2 ---------------
.obj2:
	mMvC_ValFrameStart .obj2_cont
		mMvC_SetDamage $06, HITTYPE_THROW_ROTU, PF3_HEAVYHIT
		mMvC_MoveThrowOp -$10, -$12
.obj2_cont:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $1E
		jp   .anim
; --------------- frame #3 ---------------
.obj3:
	mMvC_ValFrameStart .obj3_cont
		mMvC_SetDamageNext $02, HITTYPE_DROP_SWOOPUP, PF3_HEAVYHIT
		call Play_Proj_CopyMoveDamageFromPl
		call ProjInit_Goenitz_Yamidoukoku
.obj3_cont:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $06
		jp   .anim
; --------------- frame #5 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		mMvC_EndThrow_Slow
		jp   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
; =============== MoveC_Goenitz_ShinyaotomeThrowL ===============
; Move code for:
; - Goenitz's throw (MOVE_SHARED_THROW_G)
; - The third part of Goenitz's light supers (MOVE_GOENITZ_SHINYAOTOME_THROW_L)
MoveC_Goenitz_ShinyaotomeThrowL:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .setSpeed06
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .rotU1
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .rotU2
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .rotL
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .rotD
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage
	jp   .anim ; We never get here
; --------------- frame #0 ---------------
.setSpeed06:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $06
		jp   .anim
; --------------- frame #1 ---------------
.rotU1:
	mMvC_ValFrameStart .anim
		mMvC_SetDamage $06, HITTYPE_THROW_ROTU, PF3_HEAVYHIT
		mMvC_MoveThrowOp -$10, -$10
		jp   .anim
; --------------- frame #2 ---------------
.rotU2:
	mMvC_ValFrameStart .anim
		mMvC_SetDamage $06, HITTYPE_THROW_ROTU, PF3_HEAVYHIT
		mMvC_MoveThrowOp -$0D, -$10
		jp   .anim
; --------------- frame #3 ---------------
.rotL:
	mMvC_ValFrameStart .anim
		mMvC_SetDamage $06, HITTYPE_THROW_ROTL, PF3_HEAVYHIT
		mMvC_MoveThrowOp +$0C, -$20
		jp   .anim
; --------------- frame #4 ---------------
.rotD:
	mMvC_ValFrameStart .rotD_setSpeed14
		mMvC_SetDamage $06, HITTYPE_THROW_ROTD, PF3_HEAVYHIT
		mMvC_MoveThrowOp +$10, -$04
		jp   .anim
.rotD_setSpeed14:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $14
		jp   .anim
; --------------- frame #5 ---------------
.setDamage:
	mMvC_ValFrameStart .chkEnd
		; Goenitz's throw deals almost double the damage of other character's throws.
		mMvC_SetDamage $0A, HITTYPE_DROP_DB_A, PF3_HEAVYHIT
		jp   .anim
.chkEnd:
	mMvC_ValFrameEnd .anim
		mMvC_EndThrow_Slow
		jp   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Goenitz_ShinyaotomeThrowH ===============
; Move code for the third part of Goenitz's heavy supers (MOVE_GOENITZ_SHINYAOTOME_THROW_H).
; The player jumps while grabbing the opponent, then releases him on the ground for big damage.
MoveC_Goenitz_ShinyaotomeThrowH:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .rotU1
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .rotU2
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .rotU3
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .rotU4Jump
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .rotDJump
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim ; We never get here
; --------------- frame #0 ---------------
.rotU1:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $06
		jp   .anim
; --------------- frame #1 ---------------
.rotU2:
	mMvC_ValFrameStart .anim
		mMvC_SetDamage $06, HITTYPE_THROW_ROTU, PF3_HEAVYHIT
		mMvC_MoveThrowOp -$10, -$10
		jp   .anim
; --------------- frame #2 ---------------
.rotU3:
	mMvC_ValFrameStart .rotU3_cont
		mMvC_SetDamage $06, HITTYPE_THROW_ROTU, PF3_HEAVYHIT
		mMvC_MoveThrowOp -$0D, -$10
		jp   .anim
.rotU3_cont:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		jp   .anim
; --------------- frame #3 ---------------
.rotU4Jump:
	mMvC_ValFrameStart .rotU4Jump_cont
		mMvC_PlaySound SCT_MOVEJUMP_B
		mMvC_SetSpeedH +$0000
		mMvC_SetSpeedV -$0600
		mMvC_SetDamage $06, HITTYPE_THROW_ROTU, PF3_HEAVYHIT
		mMvC_MoveThrowOp -$0D, -$10
		mMvC_MoveThrowOpSync
.rotU4Jump_cont:
	mMvC_NextFrameOnGtYSpeed -$04, ANIMSPEED_NONE
	jp   nc, .doGravity
	jp   .doGravity
; --------------- frame #4 ---------------
.rotDJump:
	mMvC_ValFrameStart .rotDJump_cont
		mMvC_SetDamage $06, HITTYPE_THROW_ROTD, PF3_HEAVYHIT
		mMvC_MoveThrowOp +$04, -$18
		mMvC_MoveThrowOpSync
.rotDJump_cont:
	jp   .doGravity
; --------------- frame #5 ---------------
.setDamage:
	mMvC_ValFrameStart .setDamage_cont
		; Just in case we got from #4 normally, set this again
		mMvC_SetDamage $0A, HITTYPE_DROP_DB_A, PF3_HEAVYHIT
		mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $14 ; We never get here?
.setDamage_cont:
	jp   .anim
; --------------- common gravity check ---------------
; If we land at any point, switch to #5 and deal the damage.
.doGravity:
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $05*OBJLSTPTR_ENTRYSIZE, $04
		mMvC_SetDamageNext $0A, HITTYPE_DROP_DB_A, PF3_HEAVYHIT
		jp   .ret
; --------------- frame #6 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		mMvC_EndThrow_Slow
		jp   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Goenitz_ShinyaotomePart2 ===============
; Move code for the second part Goenitz's supers (MOVE_GOENITZ_SHINYAOTOME_PART2_L, MOVE_GOENITZ_SHINYAOTOME_PART2_H).
; This is the part that deals the large amount of damage. Every light/heavy super transitions into this when the dash ends.
MoveC_Goenitz_ShinyaotomePart2:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj0
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj2
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .unused_end ; We never get here
; --------------- frame #0 ---------------
; Initial loop. Horizontal movement, with speed setup.
; Every frame in the first loop deals 1 line of damage, but it's repeated several times.
.obj0:
	mMvC_ValFrameStart .obj0_cont
		mMvC_SetSpeedH +$0080
.obj0_cont:
	call OBJLstS_ApplyXSpeed
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI1, PF3_LASTHIT
		jp   .chkOtherEscape
; --------------- frame #1 ---------------
; Initial loop. Horizontal movement.
.obj1:
	call OBJLstS_ApplyXSpeed
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI1, PF3_LASTHIT
		jp   .chkOtherEscape
; --------------- frame #2 ---------------
; Initial loop. Horizontal movement.
.obj2:
	call OBJLstS_ApplyXSpeed
	mMvC_ValFrameEnd .anim	
		; Loop back to #0 until the timer elapses.
		; Note that this timer was set by whoever started the move.
		ld   hl, iPlInfo_Goenitz_Shinyaotome_LoopTimer
		add  hl, bc
		dec  [hl]
		jp   z, .obj2_noLoop
	.obj2_loop:
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI0, PF3_LASTHIT
		mMvC_SetFrame $00*OBJLSTPTR_ENTRYSIZE, $00
		jp   .ret
	.obj2_noLoop:
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI1, PF3_LASTHIT
		jp   .chkOtherEscape
		
; --------------- frame #3 ---------------
; Start the actual command throw for the third part, and transitions into it.
.chkEnd:
	call OBJLstS_ApplyXSpeed
	mMvC_ValFrameEnd .anim
		; Try to start the command throw, which shouldn't fail if we got here.
		mMvIn_ValStartCmdThrow_AllColi .ret
			; We're invulnerable during the throw.
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			set  PF1B_INVULN, [hl]
			
			; Switch to the appropriate version of the throw.
			; If we're doing the light version of the move (MOVE_GOENITZ_SHINYAOTOME_PART2_L), switch to MOVE_GOENITZ_SHINYAOTOME_THROW_L.
			ld   hl, iPlInfo_MoveId
			add  hl, bc
			ld   a, [hl]
			cp   MOVE_GOENITZ_SHINYAOTOME_PART2_L		; Doing the light move?
			jp   nz, .chkEnd_startThrowH				; If not, start the heavy version of the throw.
		.chkEnd_startThrowL:
			ld   a, MOVE_GOENITZ_SHINYAOTOME_THROW_L
			call MoveInputS_SetSpecMove_StopSpeed
			jp   .chkEnd_setLastDamage
		.chkEnd_startThrowH:
			ld   a, MOVE_GOENITZ_SHINYAOTOME_THROW_H
			call MoveInputS_SetSpecMove_StopSpeed
		.chkEnd_setLastDamage:
			; Deal one last line of damage
			mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI1, PF3_LASTHIT
			jp   .ret
; --------------- frames #0-2 / common escape check ---------------
.chkOtherEscape:
IF REV_VER_2 == 0
		;
		; [POI] If the opponent somehow isn't in one of the hit effects 
		;       this move sets, hop back instead of continuing.
		;       This can happen if the opponent gets hit by a previously thrown
		;       fireball in the middle of the move.
		;
		ld   hl, iPlInfo_HitTypeIdOther
		add  hl, bc
		ld   a, [hl]
		cp   HITTYPE_HIT_MULTI0	; A == HITTYPE_HIT_MULTI0?
		jp   z, .anim			; If so, skip
		cp   HITTYPE_HIT_MULTI1	; A == HITTYPE_HIT_MULTI1?
		jp   z, .anim			; If so, skip
ELSE
		mMvC_ValEscape .anim
ENDC
			ld   a, MOVE_SHARED_HOP_B
			call Pl_SetMove_StopSpeed
			jp   .ret
; --------------- common ---------------
.unused_end: ; [TCRF] Unreferenced code, this isn't used here
	call Play_Pl_EndMove
	jp   .ret
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret

; The remainder of the moves for Goenitz are the first parts of his supers.
; These are all ground or air dashes towards the opponent.
; They all transition to MoveC_Goenitz_ShinyaotomePart2 if the opponent didn't block the move,
; so they must set a proper value for iPlInfo_Goenitz_Shinyaotome_LoopTimer.
	
; =============== MoveC_Goenitz_ShinyaotomeMizuchiSL ===============
; Move code for the light version of Goenitz's Shinyaotome - Mizuchi (MOVE_GOENITZ_SHINYAOTOME_MIZUCHI_SL).
; Ground version.
MoveC_Goenitz_ShinyaotomeMizuchiSL:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj0
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj2
	cp   a, $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim ; We never get here
; --------------- frame #0 ---------------
; Startup.
.obj0:
	mMvC_ValFrameStart .obj0_cont
		mMvC_PlaySound SCT_HEAVY
.obj0_cont:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $02
		jp   .anim
; --------------- frame #1 ---------------
; Fast dash forward.
.obj1:
	mMvC_ValFrameStart .obj1_cont
		mMvC_SetSpeedH +$0700
.obj1_cont:
	; Continue moving forward until we hit the opponent or switch to #2.
	mMvC_ValHit .obj1_noHit, .obj1_block
		; If we hit it, switch to the attack move
		ld   a, MOVE_GOENITZ_SHINYAOTOME_PART2_L
		call MoveInputS_SetSpecMove_StopSpeed
		ld   hl, iPlInfo_Goenitz_Shinyaotome_LoopTimer
		add  hl, bc
		ld   [hl], $04	; 4 loops of attacks
		jp   .ret
.obj1_block:
	; Significantly slow down on block
	mMvC_SetSpeedH +$0100
.obj1_noHit:
	mMvC_ValFrameEnd .moveH
		mMvC_SetAnimSpeed $0A
		jp   .moveH
; --------------- frame #2 ---------------
; Fast dash forward.
.obj2:
	; Exactly like above
	mMvC_ValHit .obj2_noHit, .obj2_block
		ld   a, MOVE_GOENITZ_SHINYAOTOME_PART2_L
		call MoveInputS_SetSpecMove_StopSpeed
		ld   hl, iPlInfo_Goenitz_Shinyaotome_LoopTimer
		add  hl, bc
		ld   [hl], $04
		jp   .ret
.obj2_block:
	mMvC_SetSpeedH +$0100
.obj2_noHit:
	mMvC_ValFrameEnd .moveH
		mMvC_SetAnimSpeed $04
		jp   .moveH
; --------------- common movement ---------------
.moveH:
	call OBJLstS_ApplyXSpeed
	jp   .anim
; --------------- frame #3 ---------------
; Recovery.
; We only get here if the opponent blocked the hit or the move whiffed.
.chkEnd:
	mMvC_DoFrictionH $0080
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jp   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Goenitz_ShinyaotomeJissoukokuDL ===============
; Move code for the light version of Goenitz's Shinyaotome - Jissoukoku (MOVE_GOENITZ_SHINYAOTOME_JISSOUKOKU_DL).
; Ground version.	
MoveC_Goenitz_ShinyaotomeJissoukokuDL:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj0
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj2
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj3
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj4
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim
; --------------- frame #0 ---------------
; Startup.
.obj0:
	; The player gets to be invulnerable when doing the desperation super.
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_INVULN, [hl]
	mMvC_ValFrameStart .obj0_cont
		mMvC_PlaySound SCT_HEAVY
.obj0_cont:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_INSTANT
		jp   .anim
; --------------- frame #2 ---------------
; Preparing dash.
.obj2:
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_INVULN, [hl]
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $02
		; Initialize invuln timer for #3
		ld   hl, iPlInfo_Goenitz_Jissoukoku_InvulnTimer
		add  hl, bc
		ld   [hl], $06
		jp   .anim
; --------------- frame #3 ---------------
; Forwards dash.
.obj3:
	mMvC_ValFrameStart .obj3_cont
		mMvC_SetSpeedH $0700
.obj3_cont:

	; Remove invulnerability when the timer expires
	ld   hl, iPlInfo_Goenitz_Jissoukoku_InvulnTimer
	add  hl, bc
	dec  [hl]
	jp   nz, .obj3_chkHit
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	res  PF1B_INVULN, [hl]
.obj3_chkHit:
	; Continue moving forward until we hit the opponent.
	mMvC_ValHit .obj3_noHit, .obj3_blocked
		ld   a, MOVE_GOENITZ_SHINYAOTOME_PART2_H
		call MoveInputS_SetSpecMove_StopSpeed
		ld   hl, iPlInfo_Goenitz_Shinyaotome_LoopTimer
		add  hl, bc
		ld   [hl], $08
		jp   .ret
.obj3_blocked:
	; Significantly slow down on block
	mMvC_SetSpeedH $0100
.obj3_noHit:
	mMvC_ValFrameEnd .moveH
		mMvC_SetAnimSpeed $0A
		jp   .moveH
		
; --------------- frame #4 ---------------
; Like #3, except without initializing the speed.
.obj4:
	; Remove invulnerability when the timer expires
	ld   hl, iPlInfo_Goenitz_Jissoukoku_InvulnTimer
	add  hl, bc
	dec  [hl]
	jp   nz, .obj4_chkHit
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	res  PF1B_INVULN, [hl]
.obj4_chkHit:
	; Continue moving forward until we hit the opponent.
	; If the animation is allowed to continue to #5, the move ends.
	mMvC_ValHit .obj4_noHit, .obj4_blocked
		ld   a, MOVE_GOENITZ_SHINYAOTOME_PART2_H
		call MoveInputS_SetSpecMove_StopSpeed
		ld   hl, iPlInfo_Goenitz_Shinyaotome_LoopTimer
		add  hl, bc
		ld   [hl], $08		; 8 loops of attacks for desperation
		jp   .ret
.obj4_blocked:
	; Significantly slow down on block
	mMvC_SetSpeedH $0100
.obj4_noHit:
	mMvC_ValFrameEnd .moveH
		mMvC_SetAnimSpeed $04
		jp   .moveH
; --------------- common movement ---------------
.moveH:
	call OBJLstS_ApplyXSpeed
	jp   .anim
; --------------- frame #5 ---------------
; Recovery.
; We only get here if the opponent blocked the hit or the move whiffed.
.chkEnd:
	mMvC_DoFrictionH $0080
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jp   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Goenitz_ShinyaotomeMizuchiSH ===============
; Move code for the hard version of Goenitz's Shinyaotome - Mizuchi (MOVE_GOENITZ_SHINYAOTOME_MIZUCHI_SH).
; Air/ground version.
MoveC_Goenitz_ShinyaotomeMizuchiSH:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj0
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj2
	cp   a, $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim ; We never get here
; --------------- frame #0 ---------------
; Startup.
.obj0:
	mMvC_ValFrameStart .obj0_cont
		mMvC_PlaySound SCT_HEAVY
.obj0_cont:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		jp   .anim
; --------------- frame #1 ---------------
; Small forwards hop.
.obj1:
	; This version handles the air by starting a small jump, forcing the player
	; to be in the air by #2 if he wasn't already.
	mMvC_ValFrameStart .obj1_cont
		mMvC_SetSpeedH +$0100
		mMvC_SetSpeedV -$0200
.obj1_cont:
	mMvC_NextFrameOnGtYSpeed -$09, ANIMSPEED_NONE
	jp   .doGravity
	
; --------------- frame #2 ---------------
; Fast dash forward, falling down.
.obj2:
	mMvC_ValFrameStart .obj2_cont
		mMvC_SetSpeedH +$0700
.obj2_cont:
	; Continue dashing forward until we hit the opponent or switch to #3.
	mMvC_ValHit .obj2_noHit, .obj2_block
		; If we hit it...
		
		; ...snap to the ground and 
		ld   hl, iOBJInfo_Y
		add  hl, de
		ld   [hl], PL_FLOOR_POS
		; ...switch to the attack move
		ld   a, MOVE_GOENITZ_SHINYAOTOME_PART2_L
		call MoveInputS_SetSpecMove_StopSpeed
		ld   hl, iPlInfo_Goenitz_Shinyaotome_LoopTimer
		add  hl, bc
		ld   [hl], $04	; 4 loops of attacks
		jp   .ret
.obj2_block:
	; Significantly slow down on block
	mMvC_SetSpeedH +$0100
.obj2_noHit:
	jp   .doGravity
; --------------- common gravity check ---------------
.doGravity:
	mMvC_ChkGravityHV $0020, .anim
		mMvC_SetLandFrame $03*OBJLSTPTR_ENTRYSIZE, $06
		jp   .ret
; --------------- frame #3 ---------------
; Recovery.
; We only get here if the opponent blocked the hit or the move whiffed.
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jp   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Goenitz_ShinyaotomeJissoukokuDH ===============
; Move code for the hard version of Goenitz's Shinyaotome - Jissoukoku (MOVE_GOENITZ_SHINYAOTOME_JISSOUKOKU_DH).
; Air/ground version.	
MoveC_Goenitz_ShinyaotomeJissoukokuDH:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj0
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj2
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj3
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim
; --------------- frame #0 ---------------
; Startup.	
.obj0:
	; The player gets to be invulnerable when doing the desperation super.
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_INVULN, [hl]
	mMvC_ValFrameStart .obj0_cont
		mMvC_PlaySound SCT_HEAVY
.obj0_cont:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_INSTANT
		jp   .anim
; --------------- frame #2 ---------------
; Preparing dash.
.obj2:
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_INVULN, [hl]
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		; Initialize invuln timer for #3
		ld   hl, iPlInfo_Goenitz_Jissoukoku_InvulnTimer
		add  hl, bc
		ld   [hl], $06
		jp   .anim
; --------------- frame #3 ---------------
; Forwards dash.
.obj3:
	; The first frame is for the "hidden" warp, at least when on the ground.
	mMvC_ValFrameStart .obj3_cont
		; Only warp up $20px if we're on the ground.
		ld   hl, iOBJInfo_Y
		add  hl, de
		ld   a, [hl]			; A = YPos
		cp   PL_FLOOR_POS		; A != PL_FLOOR_POS?
		jp   nz, .obj3_setDash	; If so, skip (we're in the air already)
		mMvC_SetMoveV -$2000	; Warp up $20px while "hidden" in the ground
	.obj3_setDash:
		; Set dash speed
		mMvC_SetSpeedH +$0700	
		mMvC_SetSpeedV +$0000
.obj3_cont:

	; Remove invulnerability when the timer expires
	ld   hl, iPlInfo_Goenitz_Jissoukoku_InvulnTimer
	add  hl, bc
	dec  [hl]
	jp   nz, .obj3_chkHit
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	res  PF1B_INVULN, [hl]
.obj3_chkHit:

	; Continue moving forward until we hit the opponent.
	mMvC_ValHit .obj3_noHit, .obj3_blocked
		; If we hit it...
		
		; ...snap to the ground and 
		ld   hl, iOBJInfo_Y
		add  hl, de
		ld   [hl], PL_FLOOR_POS
		; ...switch to the attack move
		ld   a, MOVE_GOENITZ_SHINYAOTOME_PART2_H
		call MoveInputS_SetSpecMove_StopSpeed
		ld   hl, iPlInfo_Goenitz_Shinyaotome_LoopTimer
		add  hl, bc
		ld   [hl], $08	; 8 loops of attacks for desperation
		jp   .ret
.obj3_blocked:
	; Significantly slow down on block
	mMvC_SetSpeedH $0100
.obj3_noHit:
	; Continue moving down
	jp   .doGravity
; --------------- common gravity check ---------------
.doGravity:
	mMvC_ChkGravityHV $0018, .anim
		mMvC_SetLandFrame $04*OBJLSTPTR_ENTRYSIZE, $06
		jp   .ret
; --------------- frame #4 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jp   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== ProjInit_Goenitz_Yonokaze ===============
; Initializes the projectile for Goenitz's Yonokaze.
; 
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
; - H: Horizontal offset, relative to the player's origin
; - L: Horizontal movement speed
ProjInit_Goenitz_Yonokaze:
	mMvC_PlaySound SFX_FIREHIT_A
	push bc
		push de
			push hl
				call ProjInitS_InitAndGetOBJInfo	; DE = Ptr to wOBJInfo_Pl*Projectile
				
				; Set code pointer
				ld   hl, iOBJInfo_Play_CodeBank
				add  hl, de
				ld   [hl], BANK(ProjC_Goenitz_Yonokaze)	; BANK $0A ; iOBJInfo_Play_CodeBank
				inc  hl
				ld   [hl], LOW(ProjC_Goenitz_Yonokaze)	; iOBJInfo_Play_CodePtr_Low
				inc  hl
				ld   [hl], HIGH(ProjC_Goenitz_Yonokaze)	; iOBJInfo_Play_CodePtr_High
				
				; Write sprite mapping ptr for this projectile.
				ld   hl, iOBJInfo_BankNum
				add  hl, de
				ld   [hl], BANK(OBJLstPtrTable_Proj_Goenitz_Yonokaze)	; BANK $01 ; iOBJInfo_BankNum
				inc  hl
				ld   [hl], LOW(OBJLstPtrTable_Proj_Goenitz_Yonokaze)	; iOBJInfo_OBJLstPtrTbl_Low
				inc  hl
				ld   [hl], HIGH(OBJLstPtrTable_Proj_Goenitz_Yonokaze)	; iOBJInfo_OBJLstPtrTbl_High
				inc  hl
				ld   [hl], $00	; iOBJInfo_OBJLstPtrTblOffset

				; Set animation speed.
				ld   hl, iOBJInfo_FrameLeft
				add  hl, de
				ld   [hl], $00	; iOBJInfo_FrameLeft
				inc  hl
				ld   [hl], ANIMSPEED_INSTANT	; iOBJInfo_FrameTotal
				
				; Set priority value
				ld   hl, iOBJInfo_Play_Priority
				add  hl, de
				ld   [hl], $02
				
				; Set despawn timer
				inc  hl
				ld   [hl], $28 ; iOBJInfo_Play_EnaTimer
				
				; Set initial position relative to the player's origin
				call OBJLstS_Overlap
			pop  hl
			; Move horizontally by H
			push hl
				ld   l, $00
				call Play_OBJLstS_MoveH_ByXFlipR
			pop  hl
			
			; Make the wind move forward.
			; XSpeed = L / 4
			; This is only used for the hidden heavy version, it's always $00 in any other case.
			ld   h, l
			ld   l, $00
REPT 4
			srl  h
			rr   l
ENDR
			call Play_OBJLstS_SetSpeedH_ByXFlipR
		pop  de
	pop  bc
	ret
; =============== ProjInit_Goenitz_Yamidoukoku ===============
; Initializes the projectile for Goenitz's Yamidoukoku.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
ProjInit_Goenitz_Yamidoukoku:
	mMvC_PlaySound SFX_FIREHIT_A
	push bc
		push de
			push hl
				call ProjInitS_InitAndGetOBJInfo	; DE = Ptr to wOBJInfo_Pl*Projectile
				
				; Set code pointer
				ld   hl, iOBJInfo_Play_CodeBank
				add  hl, de
				ld   [hl], BANK(ProjC_Goenitz_Yonokaze)	; BANK $0A ; iOBJInfo_Play_CodeBank
				inc  hl
				ld   [hl], LOW(ProjC_Goenitz_Yonokaze)	; iOBJInfo_Play_CodePtr_Low
				inc  hl
				ld   [hl], HIGH(ProjC_Goenitz_Yonokaze)	; iOBJInfo_Play_CodePtr_High
				
				; Write sprite mapping ptr for this projectile.
				ld   hl, iOBJInfo_BankNum
				add  hl, de
				ld   [hl], BANK(OBJLstPtrTable_Proj_Goenitz_Yamidoukoku)	; BANK $01 ; iOBJInfo_BankNum
				inc  hl
				ld   [hl], LOW(OBJLstPtrTable_Proj_Goenitz_Yamidoukoku)		; iOBJInfo_OBJLstPtrTbl_Low
				inc  hl
				ld   [hl], HIGH(OBJLstPtrTable_Proj_Goenitz_Yamidoukoku)	; iOBJInfo_OBJLstPtrTbl_High
				inc  hl
				ld   [hl], $00	; iOBJInfo_OBJLstPtrTblOffset

				; Set animation speed.
				ld   hl, iOBJInfo_FrameLeft
				add  hl, de
				ld   [hl], $00	; iOBJInfo_FrameLeft
				inc  hl
				ld   [hl], ANIMSPEED_INSTANT	; iOBJInfo_FrameTotal
				
				; Set priority value
				ld   hl, iOBJInfo_Play_Priority
				add  hl, de
				ld   [hl], $05 ; Highest priority value!
				
				; Set despawn timer
				inc  hl
				ld   [hl], $78 ; iOBJInfo_Play_EnaTimer
				
				; Set initial position relative to the player's origin
				call OBJLstS_Overlap
			pop  hl
			mMvC_SetMoveH +$1000
			mMvC_SetSpeedH +$0000
		pop  de
	pop  bc
	ret
; =============== ProjInit_Goenitz_WanpyouTokobuse ===============
; Initializes the projectile for Goenitz's Wanpyou Tokobuse.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
; - H: Horizontal offset
; - L: Vertical offset
ProjInit_Goenitz_WanpyouTokobuse:
	mMvC_PlaySound SFX_FIREHIT_A
	push bc
		push de
			push hl ; Save coords
				call ProjInitS_InitAndGetOBJInfo	; DE = Ptr to wOBJInfo_Pl*Projectile
				
				; Set code pointer
				ld   hl, iOBJInfo_Play_CodeBank
				add  hl, de
				ld   [hl], BANK(ProjC_Goenitz_WanpyouTokobuse)	; BANK $0A ; iOBJInfo_Play_CodeBank
				inc  hl
				ld   [hl], LOW(ProjC_Goenitz_WanpyouTokobuse)	; iOBJInfo_Play_CodePtr_Low
				inc  hl
				ld   [hl], HIGH(ProjC_Goenitz_WanpyouTokobuse)	; iOBJInfo_Play_CodePtr_High
				
				; Write sprite mapping ptr for this projectile.
				ld   hl, iOBJInfo_BankNum
				add  hl, de
				ld   [hl], BANK(OBJLstPtrTable_Proj_Goenitz_WanpyouTokobuse)	; BANK $01 ; iOBJInfo_BankNum
				inc  hl
				ld   [hl], LOW(OBJLstPtrTable_Proj_Goenitz_WanpyouTokobuse)		; iOBJInfo_OBJLstPtrTbl_Low
				inc  hl
				ld   [hl], HIGH(OBJLstPtrTable_Proj_Goenitz_WanpyouTokobuse)	; iOBJInfo_OBJLstPtrTbl_High
				inc  hl
				ld   [hl], $00	; iOBJInfo_OBJLstPtrTblOffset

				; Set animation speed.
				ld   hl, iOBJInfo_FrameLeft
				add  hl, de
				ld   [hl], $00	; iOBJInfo_FrameLeft
				inc  hl
				ld   [hl], ANIMSPEED_INSTANT	; iOBJInfo_FrameTotal
				
				; Set priority value
				ld   hl, iOBJInfo_Play_Priority
				add  hl, de
				ld   [hl], $00
				
				; Set despawn timer
				inc  hl
				ld   [hl], $1E ; iOBJInfo_Play_EnaTimer
				
				
				; Set initial position relative to the player's origin
				call OBJLstS_Overlap
			pop  hl 
			
			; Move it horizontally by H
			push hl
				ld   l, $00							; H -> h offset, L -> 0 subpixels
				call Play_OBJLstS_MoveH_ByXFlipR	; Move by that
			pop  hl
			; Move it vertically by L
			ld   h, l				; H -> v offset,
			ld   l, $00				; L -> 0 subpixels
			call Play_OBJLstS_MoveV	; Move by that
			
			;
			; Keep track of the player's position when the projectile is first spawned.
			; This is because it's used as the projectile's origin.
			;
			ld   hl, iOBJInfo_X	; A = Player X position
			add  hl, de
			ld   a, [hl]
			ld   hl, iOBJInfo_Proj_WanToko_OrigX	
			add  hl, de			; Seek to X origin
			ld   [hl], a		; Copy it there
			
			ld   hl, iOBJInfo_Y	; A = Player X position
			add  hl, de
			ld   a, [hl]
			ld   hl, iOBJInfo_Proj_WanToko_OrigY
			add  hl, de			; Seek to Y origin
			ldi  [hl], a		; Copy it there, seek to speed
			
			; Initialize movement speed
			ld   [hl], $00		; iOBJInfo_Proj_WanToko_MoveSpeed
		pop  de
	pop  bc
	ret
; =============== ProjC_Goenitz_Yonokaze ===============
; Projectile code for Goenitz's Yonokaze and Yamidoukoku.
; Like ProjC_Horz, except it despawns automatically when the despawn timer elapses.
ProjC_Goenitz_Yonokaze:
	call ExOBJS_Play_ChkHitModeAndMoveH		; Did it go off-screen? (or hit the opponent, for Yonokaze)
	jp   c, .despawn						; If so, jump
	
	; Handle despawn timer
	ld   hl, iOBJInfo_Play_EnaTimer
	add  hl, de
	dec  [hl]
	jp   z, .despawn
	
	; Continue animating
	call OBJLstS_DoAnimTiming_Loop_by_DE
	ret
.despawn:
	call OBJLstS_Hide
	ret
; =============== ProjC_Goenitz_WanpyouTokobuse ===============
ProjC_Goenitz_WanpyouTokobuse:

	; Projectile goes away if we get hit
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	bit  PF1B_HITRECV, [hl]
	jp   nz, .despawn
	
	; Handle the despawn timer
	ld   hl, iOBJInfo_Play_EnaTimer
	add  hl, de
	dec  [hl]
	jp   z, .despawn
	
	; Only execute the code below between frames... pointless for projectiles with ANIMSPEED_INSTANT.
	mMvC_ValFrameEnd .anim
	
	;
	; This projectile is animated in a way to make it look like there are many transparent
	; projectiles spreading from Goenitz's hand.
	;
	; In practice, it's just a single projectile that gets moved every frame.
	;
	; This projectile first moves top to bottom in three frames, each using unique sprite mappings
	; for the top, middle and bottom part.
	; After the bottom part is displayed, we move right and return to the top projectile.
	; Every time we move right, the vertical offset also increases.
	; After the third "column" is finished, it resets back to the first one with its original movement offsets.
	;
	; The horizontal and vertical movements are always MoveSpeed * 4, resulting in a cone-like shape.
	;
	
	; Depending on the internal frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffset
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .objTopMid
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .objTopMid
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .objBottom
	jp   .anim ; We never get here
; --------------- frame #0-1 ---------------
; Top and mid frame.
; We only need to move down by iOBJInfo_Proj_WanToko_MoveSpeed.
.objTopMid:
	; HL = MoveSpeed * 4
	; Since the first MoveSpeed is 0, the first column will display the three frames at the same location.
	ld   hl, iOBJInfo_Proj_WanToko_MoveSpeed
	add  hl, de
	ld   a, [hl] 
	add  a, a
	add  a, a
	ld   h, a
	ld   l, $00
	; Move vertically by that
	call Play_OBJLstS_MoveV
	jp   .anim
	
; --------------- frame #0-1 ---------------
; Bottom frame.
; Needs to reset to the top frame of the next row.
; This means moving to the right, unless we're on the third row, which resets it back to the beginning.
.objBottom:

	;
	; Before doing anything, reset the projectile's to its origin.
	; This simplifies the movement later on.
	;
	
	; iOBJInfo_X = iOBJInfo_Proj_WanToko_OrigX
	ld   hl, iOBJInfo_Proj_WanToko_OrigX
	add  hl, de
	ld   a, [hl]
	ld   hl, iOBJInfo_X
	add  hl, de
	ld   [hl], a
	; iOBJInfo_Y = iOBJInfo_Proj_WanToko_OrigY
	ld   hl, iOBJInfo_Proj_WanToko_OrigY
	add  hl, de
	ld   a, [hl]
	ld   hl, iOBJInfo_Y
	add  hl, de
	ld   [hl], a
	
	;
	; Cycle to the next movement speed.
	; If we're on speed $03, loop back to the first one.
	; 
	; MoveSpeed = (MoveSpeed + 1) % 4
	;
	ld   hl, iOBJInfo_Proj_WanToko_MoveSpeed
	add  hl, de
	ld   a, [hl]	; A = MoveSpeed
	inc  a			; A++
	and  a, $03		; Loop a "4th" row back to 0
	ld   [hl], a	; Save it back
	
	;
	; Move right from the origin to the target column.
	;
	
	; A = MoveSpeed * 4
	add  a, a
	add  a, a
	; HL = A
	ld   h, a
	ld   l, $00
	; Move horizontally by that
	push af
		call Play_OBJLstS_MoveH_ByXFlipR
	pop  af
	
	;
	; Move up by the same amount.
	;
	
	; HL = -A
	cpl
	inc  a
	ld   h, a
	ld   l, $00
	call Play_OBJLstS_MoveV
	jp   .anim
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
	ret
.despawn:
	call OBJLstS_Hide
	ret
	
IF REV_LANG_EN == 1
TextC_EndingPost_Boss0:
	db .end-.start
.start:
	db "The Orochi...", C_NL
	db "It wasn`t much of", C_NL
	db "        an opponent.", C_NL
.end:
TextC_EndingPost_Boss1:
	db .end-.start
.start:
	db "(Big)", C_NL
	db "Geese!!", C_NL
	db "What are you", C_NL
	db "        playing at?!", C_NL
.end:
TextC_EndingPost_Boss2:
	db .end-.start
.start:
	db "(Geese)", C_NL
	db "What?!", C_NL
.end:
TextC_EndingPost_Boss3:
	db .end-.start
.start:
	db "(Big)", C_NL
	db "You were drawn into", C_NL
	db " this tournament,and", C_NL
	db " used for another`s", C_NL
	db " purposes.", C_NL
.end:
TextC_EndingPost_Boss4:
	db .end-.start
.start:
	db "And soon the time", C_NL
	db " will come for me to", C_NL
	db " put an end to", C_NL
	db "             things.", C_NL
.end:
TextC_EndingPost_Boss5:
	db .end-.start
.start:
	db "(Geese)", C_NL
	db "There`s no time like", C_NL
	db "    the present,Big!", C_NL
.end:
TextC_EndingPost_Boss6:
	db .end-.start
.start:
	db "(Krauser)", C_NL
	db "Ha,ha,ha! Good!", C_NL
.end:
ENDC

IF REV_VER_2 == 0
; =============== END OF BANK ===============
; Junk area below.
	mIncJunk "L0A7F58"
ELSE
	mIncJunk "L0A7FC9"
ENDC