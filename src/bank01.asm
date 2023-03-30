GFXLZ_Play_PreRoundText: INCBIN "data/gfx/play_preroundtext.lzc"
GFXLZ_Play_PostRoundText: INCBIN "data/gfx/play_postroundtext.lzc"

OBJInfoInit_Play_CharCross:
	db $00 ; iOBJInfo_Status
	db $10 ; iOBJInfo_OBJLstFlags
	db $00 ; iOBJInfo_OBJLstFlagsView
	db $60 ; iOBJInfo_X
	db $00 ; iOBJInfo_XSub
	db $68 ; iOBJInfo_Y
	db $00 ; iOBJInfo_YSub
	db $00 ; iOBJInfo_SpeedX
	db $00 ; iOBJInfo_SpeedXSub
	db $00 ; iOBJInfo_SpeedY
	db $00 ; iOBJInfo_SpeedYSub
	db $00 ; iOBJInfo_RelX (auto)
	db $00 ; iOBJInfo_RelY (auto)
	db $80 ; iOBJInfo_TileIDBase
	db LOW($8800) ; iOBJInfo_VRAMPtr_Low
	db HIGH($8800) ; iOBJInfo_VRAMPtr_High
	db BANK(OBJLstPtrTable_CharCross) ; iOBJInfo_BankNum (BANK $01)
	db LOW(OBJLstPtrTable_CharCross) ; iOBJInfo_OBJLstPtrTbl_Low
	db HIGH(OBJLstPtrTable_CharCross) ; iOBJInfo_OBJLstPtrTbl_High
	db $00 ; iOBJInfo_OBJLstPtrTblOffset
	db BANK(OBJLstPtrTable_CharCross) ; iOBJInfo_BankNum (BANK $01)
	db LOW(OBJLstPtrTable_CharCross) ; iOBJInfo_OBJLstPtrTbl_Low
	db HIGH(OBJLstPtrTable_CharCross) ; iOBJInfo_OBJLstPtrTbl_High
	db $00 ; iOBJInfo_OBJLstPtrTblOffset
	db $00 ; iOBJInfo_ColiBoxId (auto)
	db $00 ; iOBJInfo_HitboxId (auto)
	db $00 ; iOBJInfo_ForceHitboxId
	db $00 ; iOBJInfo_FrameLeft
	db $00 ; iOBJInfo_FrameTotal
	db $00 ; iOBJInfo_BufInfoPtr_Low
	db $00 ; iOBJInfo_BufInfoPtr_High
OBJInfoInit_Play_RoundText:
	db $00 ; iOBJInfo_Status
	db $10 ; iOBJInfo_OBJLstFlags
	db $00 ; iOBJInfo_OBJLstFlagsView
	db $80 ; iOBJInfo_X
	db $00 ; iOBJInfo_XSub
	db $60 ; iOBJInfo_Y
	db $00 ; iOBJInfo_YSub
	db $00 ; iOBJInfo_SpeedX
	db $00 ; iOBJInfo_SpeedXSub
	db $00 ; iOBJInfo_SpeedY
	db $00 ; iOBJInfo_SpeedYSub
	db $00 ; iOBJInfo_RelX (auto)
	db $00 ; iOBJInfo_RelY (auto)
	db $80 ; iOBJInfo_TileIDBase
	db LOW($8800) ; iOBJInfo_VRAMPtr_Low
	db HIGH($8800) ; iOBJInfo_VRAMPtr_High
	db BANK(OBJLstPtrTable_PreRoundText) ; iOBJInfo_BankNum (BANK $01)
	db LOW(OBJLstPtrTable_PreRoundText) ; iOBJInfo_OBJLstPtrTbl_Low
	db HIGH(OBJLstPtrTable_PreRoundText) ; iOBJInfo_OBJLstPtrTbl_High
	db $00 ; iOBJInfo_OBJLstPtrTblOffset
	db BANK(OBJLstPtrTable_PreRoundText) ; iOBJInfo_BankNum (BANK $01)
	db LOW(OBJLstPtrTable_PreRoundText) ; iOBJInfo_OBJLstPtrTbl_Low
	db HIGH(OBJLstPtrTable_PreRoundText) ; iOBJInfo_OBJLstPtrTbl_High
	db $00 ; iOBJInfo_OBJLstPtrTblOffset
	db $00 ; iOBJInfo_ColiBoxId (auto)
	db $00 ; iOBJInfo_HitboxId (auto)
	db $00 ; iOBJInfo_ForceHitboxId
	db $00 ; iOBJInfo_FrameLeft
	db $00 ; iOBJInfo_FrameTotal
	db $00 ; iOBJInfo_BufInfoPtr_Low
	db $00 ; iOBJInfo_BufInfoPtr_High

INCLUDE "data/objlst/play_misc.asm"
		
GFXLZ_Projectiles: INCBIN "data/gfx/play_projectiles.lzc"
GFX_Play_SuperSparkle: INCBIN "data/gfx/play_supersparkle.bin"

; =============== ProjGFXDef_* ===============
; Defines the tiles to copy when loading projectile/effect graphics for characters.
; These are expressed in tile ranges (as pairs of starting offsets + tile count).
;
; Because parts of the graphics may be reused between characters, multiple ranges
; can be defined, with the GFX being stored in that order in VRAM.
;
; The starting offsets are relative to an uncompressed copy of GFXLZ_Projectiles,
; which should be stored in the LZSS buffer when these are used by Play_LoadProjectileGFXFromDef.

; IN
; - 1: Starting offset
; - 2: Tile count (as 8x8 tiles)
mProjDef: MACRO
	dw \1
	db \2
ENDM

ProjGFXDef_Terry:
	db $01
	mProjDef $0000, $1C
ProjGFXDef_RyoRobert:
	db $02
	mProjDef $0940, $0E
	mProjDef $01C0, $0C
ProjGFXDef_MrKarate:
	db $02
	mProjDef $0940, $0E
	mProjDef $01C0, $12
ProjGFXDef_Athena: 
	db $01
	mProjDef $02E0, $20
ProjGFXDef_Mai:
	db $01
	mProjDef $04E0, $04
ProjGFXDef_Leona:
	db $01
	mProjDef $0520, $24
ProjGFXDef_Geese:
	db $01
	mProjDef $0760, $1E
ProjGFXDef_Krauser:
	db $01
	mProjDef $0940, $1A
ProjGFXDef_MrBig:
	db $02
	mProjDef $0000, $0E
	mProjDef $0AE0, $0A
ProjGFXDef_Iori:
	db $01
	mProjDef $0B80, $18
ProjGFXDef_Mature:
	db $01
	mProjDef $0B80, $10
ProjGFXDef_ChizuruKagura:
	db $01
	mProjDef $0DC0, $20
ProjGFXDef_Goenitz:
	db $01
	mProjDef $0FC0, $22
ProjGFXDef_OIori:
	db $01
	mProjDef $0B80, $24
ProjGFXDef_OLeona:
	db $03
	mProjDef $0B80, $10
	mProjDef $11E0, $08
	mProjDef $06A0, $0C

INCLUDE "data/objlst/proj.asm"

; This uses a placeholder OBJLstPtrTbl that's not pointing to a real OBJLstPtrTable.
; Those fields gets properly set when "spawning" a projectile. (MoveC_*)
OBJInfoInit_Projectile:
	db $00 ; iOBJInfo_Status
	db $00 ; iOBJInfo_OBJLstFlags
	db $00 ; iOBJInfo_OBJLstFlagsView
	db $60 ; iOBJInfo_X
	db $00 ; iOBJInfo_XSub
	db $88 ; iOBJInfo_Y
	db $00 ; iOBJInfo_YSub
	db $00 ; iOBJInfo_SpeedX
	db $00 ; iOBJInfo_SpeedXSub
	db $00 ; iOBJInfo_SpeedY
	db $00 ; iOBJInfo_SpeedYSub
	db $00 ; iOBJInfo_RelX (auto)
	db $00 ; iOBJInfo_RelY (auto)
	db $80 ; iOBJInfo_TileIDBase
	db LOW($8800) ; iOBJInfo_VRAMPtr_Low
	db HIGH($8800) ; iOBJInfo_VRAMPtr_High
	db $09 ; iOBJInfo_BankNum (BANK $09)
	db LOW($58D7) ; iOBJInfo_OBJLstPtrTbl_Low
	db HIGH($58D7) ; iOBJInfo_OBJLstPtrTbl_High
	db $00 ; iOBJInfo_OBJLstPtrTblOffset
	db $00 ; iOBJInfo_BankNum [N/A]
	db $00 ; iOBJInfo_OBJLstPtrTbl_Low
	db $00 ; iOBJInfo_OBJLstPtrTbl_High
	db $00 ; iOBJInfo_OBJLstPtrTblOffset
	db $00 ; iOBJInfo_ColiBoxId (auto)
	db $00 ; iOBJInfo_HitboxId (auto)
	db $00 ; iOBJInfo_ForceHitboxId
	db $00 ; iOBJInfo_FrameLeft
	db $00 ; iOBJInfo_FrameTotal
	db $00 ; iOBJInfo_BufInfoPtr_Low
	db $00 ; iOBJInfo_BufInfoPtr_High
	

; =============== Play_Main ===============
; The main gameplay loop.
; Should be executed alongside the two other tasks Play_DoPl_1P and Play_DoPl_2P.
Play_Main:
	ld   sp, $DD00
	; Initialize subsecond timer to 60 frames
	ld   a, 60
	ld   [wRoundTimeSub], a
	ei
	; Here we go
.mainLoop:
	call Play_ChkEnd
	call Play_DoPlInput
	call Play_ChkPause
	call Play_DoHUD
	call Play_DoMisc
	call Play_DoPlColi
	call Play_WriteKeysToBuffer
	call Play_DoScrollPos
	call Play_ExecExOBJCode
	call Task_PassControlFar
	jp   .mainLoop
	
; =============== Play_DoPlInput ===============
; Handles input for both players during gameplay.
; Essentially does some processing to the hJoyKeys fields before
; copying them to the player struct.
Play_DoPlInput:
	; Increase play timer as long as we have input
	ld   hl, wPlayTimer
	inc  [hl]
	
	;
	; PLAYER 1
	;
.do1P:
	;
	; CPU inputs are faked separately by the AI.
	; This part handles only inputs read from the joypad (so, for human players).
	;
	ld   hl, wPlInfo_Pl1+iPlInfo_Flags0
	bit  PF0B_CPU, [hl]		; Is 1P CPU controlled?
	jp   nz, .cpu1P			; If so, jump ahead
	
	;
	; Copy over the raw joypad inputs to the player 1 struct
	;
	ldh  a, [hJoyKeys]
	ld   [wPlInfo_Pl1+iPlInfo_JoyKeys], a
	ldh  a, [hJoyNewKeys]
	ld   [wPlInfo_Pl1+iPlInfo_JoyNewKeys], a
	
	;--
	;
	; Generate a special version of iPlInfo_JoyNewKeys which keeps the directional keys bits,
	; and tells if the Punch (A) or Kick (B) buttons are for the light or heavy attacks.
	;
	; Effectively this removes the START and SELECT bits, but they aren't used for moves anyway
	; so who cares.
	;
	; The punch/kick is treated as heavy if the button is pressed, then held for 6 frames.
	; If it's released before 6 frames, it instead counts as a light.
	;
	
	; The lower nybble with directional keys is identical to what's in iPlInfo_JoyNewKeys.
	and  a, $0F
	ld   [wPlInfo_Pl1+iPlInfo_JoyNewKeysLH], a
	
	;
	; A Button - Check light/heavy counter for punches
	;
.aBufChk1P:

	; If we've started counting held frames already, jump
	ld   a, [wPlInfo_Pl1+iPlInfo_JoyHeavyCountA]
	or   a					; iPlInfo_JoyHeavyCountA != 0?
	jp   nz, .aBufNext1P	; If so, jump
	
	; Otherwise, check for having started to press A.
	; This prevents starting another punch if we were still holding A continuously.
	ldh  a, [hJoyNewKeys]
	bit  KEYB_A, a			; Pressed A just now?
	jp   z, .bBufChk1P		; If not, don't do anything
.aBufNext1P:
	; If we released A, reset the counter and set the LIGHT bit
	ldh  a, [hJoyKeys]
	bit  KEYB_A, a			; Holding A?
	jp   z, .aLight1P		; If not, jump
	
	; Otherwise, increase the held key timer.
	ld   hl, wPlInfo_Pl1+iPlInfo_JoyHeavyCountA
	inc  [hl]
	
	; If we held it for less than 6 frames, don't do anything
	ld   a, $06			
	cp   a, [hl]			; iPlInfo_JoyHeavyCountA < 6?
	jp   nc, .bBufChk1P		; If so, jump
	
.aHeavy1P:
	; Set the heavy attack on A
	ld   hl, wPlInfo_Pl1+iPlInfo_JoyNewKeysLH
	res  KEPB_A_LIGHT, [hl]
	set  KEPB_A_HEAVY, [hl]
	xor  a
	ld   [wPlInfo_Pl1+iPlInfo_JoyHeavyCountA], a
	jp   .bBufChk1P
.aLight1P:
	; Set the light attack on A
	ld   hl, wPlInfo_Pl1+iPlInfo_JoyNewKeysLH
	set  KEPB_A_LIGHT, [hl]
	res  KEPB_A_HEAVY, [hl]
	xor  a
	ld   [wPlInfo_Pl1+iPlInfo_JoyHeavyCountA], a
	
.bBufChk1P:

	;
	; B Button - Check light/heavy counter for kicks.
	;

	; Check new/current
	ld   a, [wPlInfo_Pl1+iPlInfo_JoyHeavyCountB]
	or   a					
	jp   nz, .bBufNext1P
	
	ldh  a, [hJoyNewKeys]
	bit  KEYB_B, a
	jp   z, .endBufChk1P
.bBufNext1P:
	; Check if premature stop (LIGHT)
	ldh  a, [hJoyKeys]
	bit  KEYB_B, a
	jp   z, .bLight1P
	
	; Increase counter and check for 6 frames (HEAVY)
	ld   hl, wPlInfo_Pl1+iPlInfo_JoyHeavyCountB
	inc  [hl]
	
	ld   a, $06			
	cp   a, [hl]
	jp   nc, .endBufChk1P
.bHeavy1P:
	; Set HEAVY B press
	ld   hl, wPlInfo_Pl1+iPlInfo_JoyNewKeysLH
	res  KEPB_B_LIGHT, [hl]
	set  KEPB_B_HEAVY, [hl]
	xor  a
	ld   [wPlInfo_Pl1+iPlInfo_JoyHeavyCountB], a
	jp   .endBufChk1P
.bLight1P:
	; Set LIGHT B press
	ld   hl, wPlInfo_Pl1+iPlInfo_JoyNewKeysLH
	set  KEPB_B_LIGHT, [hl]
	res  KEPB_B_HEAVY, [hl]
	xor  a
	ld   [wPlInfo_Pl1+iPlInfo_JoyHeavyCountB], a
	
.endBufChk1P:
	jp   .do2P
	
.cpu1P:
	; Generate inputs for the CPU
	ld   bc, wPlInfo_Pl1
	ld   de, wOBJInfo_Pl1
	call HomeCall_Play_CPU_Do
	
.do2P:

	;
	; PLAYER 2
	; Do the same.
	;
	
	ld   hl, wPlInfo_Pl2+iPlInfo_Flags0
	bit  PF0B_CPU, [hl]		; Is 2P CPU controlled?
	jp   nz, .cpu2P			; If so, jump ahead
	
	;
	; Copy over the raw joypad inputs to the player 1 struct
	;
	ldh  a, [hJoyKeys2]
	ld   [wPlInfo_Pl2+iPlInfo_JoyKeys], a
	ldh  a, [hJoyNewKeys2]
	ld   [wPlInfo_Pl2+iPlInfo_JoyNewKeys], a
	
	;--
	; The lower nybble with directional keys is identical to what's in iPlInfo_JoyNewKeys.
	and  a, $0F
	ld   [wPlInfo_Pl2+iPlInfo_JoyNewKeysLH], a
	
	;
	; A Button - Check light/heavy counter for punches
	;
.aBufChk2P:

	; If we've started counting held frames already, jump
	ld   a, [wPlInfo_Pl2+iPlInfo_JoyHeavyCountA]
	or   a					; iPlInfo_JoyHeavyCountA != 0?
	jp   nz, .aBufNext2P	; If so, jump
	
	; Otherwise, check for having started to press A.
	; This prevents starting another punch if we were still holding A continuously.
	ldh  a, [hJoyNewKeys2]
	bit  KEYB_A, a			; Pressed A just now?
	jp   z, .bBufChk2P		; If not, don't do anything
.aBufNext2P:
	; If we released A, reset the counter and set the LIGHT bit
	ldh  a, [hJoyKeys2]
	bit  KEYB_A, a			; Holding A?
	jp   z, .aLight2P		; If not, jump
	
	; Otherwise, increase the held key timer.
	ld   hl, wPlInfo_Pl2+iPlInfo_JoyHeavyCountA
	inc  [hl]
	
	; If we held it for less than 6 frames, don't do anything
	ld   a, $06			
	cp   a, [hl]		; iPlInfo_JoyHeavyCountA < 6?
	jp   nc, .bBufChk2P	; If so, jump
	
.aHeavy2P:
	; Set the heavy attack on A
	ld   hl, wPlInfo_Pl2+iPlInfo_JoyNewKeysLH
	res  KEPB_A_LIGHT, [hl]
	set  KEPB_A_HEAVY, [hl]
	xor  a
	ld   [wPlInfo_Pl2+iPlInfo_JoyHeavyCountA], a
	jp   .bBufChk2P
.aLight2P:
	; Set the light attack on A
	ld   hl, wPlInfo_Pl2+iPlInfo_JoyNewKeysLH
	set  KEPB_A_LIGHT, [hl]
	res  KEPB_A_HEAVY, [hl]
	xor  a
	ld   [wPlInfo_Pl2+iPlInfo_JoyHeavyCountA], a
	
.bBufChk2P:

	;
	; B Button - Check light/heavy counter for kicks.
	;

	; Check new/current
	ld   a, [wPlInfo_Pl2+iPlInfo_JoyHeavyCountB]
	or   a					
	jp   nz, .bBufNext2P
	
	ldh  a, [hJoyNewKeys2]
	bit  KEYB_B, a
	jp   z, .endBufChk2P
.bBufNext2P:
	; Check if premature stop (LIGHT)
	ldh  a, [hJoyKeys2]
	bit  KEYB_B, a
	jp   z, .bLight2P
	
	; Increase counter and check for 6 frames (HEAVY)
	ld   hl, wPlInfo_Pl2+iPlInfo_JoyHeavyCountB
	inc  [hl]
	
	ld   a, $06			
	cp   a, [hl]
	jp   nc, .endBufChk2P
.bHeavy2P:
	; Set HEAVY B press
	ld   hl, wPlInfo_Pl2+iPlInfo_JoyNewKeysLH
	res  KEPB_B_LIGHT, [hl]
	set  KEPB_B_HEAVY, [hl]
	xor  a
	ld   [wPlInfo_Pl2+iPlInfo_JoyHeavyCountB], a
	jp   .endBufChk2P
.bLight2P:
	; Set LIGHT B press
	ld   hl, wPlInfo_Pl2+iPlInfo_JoyNewKeysLH
	set  KEPB_B_LIGHT, [hl]
	res  KEPB_B_HEAVY, [hl]
	xor  a
	ld   [wPlInfo_Pl2+iPlInfo_JoyHeavyCountB], a
.endBufChk2P:
	jp   .end
	
.cpu2P:
	; Generate inputs for the CPU
	ld   bc, wPlInfo_Pl2
	ld   de, wOBJInfo_Pl2
	call HomeCall_Play_CPU_Do
.end:
	ret
	
; =============== Play_ChkPause ===============
; Handles pausing during gameplay.
;
; Any player can pause the game.
; However, only the player that paused the game can unpause it,
; as there are separate main loops for each player.
Play_ChkPause:

	; When pressing START, enter the paused state.
	ldh  a, [hJoyNewKeys]
	and  a, KEY_START		; Did 1P press START?
	jp   z, .chk2P			; If not, skip
	
	;
	; As long as the game is paused, this main loop takes exclusive control.
	;
	ld   hl, wPauseFlags
	set  PLB1, [hl]		; Set pause flag
	call Play_Pause
.mainLoop1P:
	ldh  a, [hJoyNewKeys]
	bit  KEYB_START, a		; Pressed START?
	jp   nz, .unpause1P		; If so, unpause the game
	bit  KEYB_SELECT, a		; Pressed SELECT?
	jp   nz, .frameAdv1P	; If so, frame advance
	; Skip other tasks to freeze players and pause the music
	call Task_SkipAllAndWaitVBlank
	jp   .mainLoop1P
.frameAdv1P:
	call Play_FrameAdv
	jp   .mainLoop1P
.unpause1P:
	call Play_Unpause
	ld   hl, wPauseFlags
	res  PLB1, [hl]		; Unset pause flag
	ret
	
.chk2P:
	ldh  a, [hJoyNewKeys2]
	and  a, KEY_START		; Did 2P press START?
	jp   z, .ret			; If not, return
	;
	; As long as the game is paused, this main loop takes exclusive control.
	;
	ld   hl, wPauseFlags
	set  PLB2, [hl]		; Set pause flag
	call Play_Pause
.mainLoop2P:
	ldh  a, [hJoyNewKeys2]
	bit  KEYB_START, a		; Pressed START?
	jp   nz, .unpause2P		; If so, unpause the game
	bit  KEYB_SELECT, a		; Pressed SELECT?
	jp   nz, .frameAdv2P	; If so, frame advance
	; Skip other tasks to freeze players and pause the music
	call Task_SkipAllAndWaitVBlank
	jp   .mainLoop2P
.frameAdv2P:
	call Play_FrameAdv
	jp   .mainLoop2P
.unpause2P:
	call Play_Unpause
	ld   hl, wPauseFlags
	res  PLB2, [hl]		; Unset pause flag
	ret
.ret:
	ret
; =============== Play_Pause ===============
; Pauses the game.
Play_Pause:
	; Stop player animations
	ld   a, $01
	ld   [wNoCopyGFXBuf], a
	
	; Pause the music playback
	ld   a, SNC_PAUSE
	call HomeCall_Sound_ReqPlayExId
	
	; Draw "PAUSE" on the HUD.
	; This gets drawn to the side of the player that paused the game.
	ld   a, [wPauseFlags]
	bit  PLB1, a		; Did 1P pause the game?
	jp   z, .bg2P		; If not, jump
.bg1P:
	ld   hl, $9C46		; HL = Tilemap ptr for 1P side
	jp   .drawBG
.bg2P:
	ld   hl, $9C4B		; HL = Tilemap ptr for 2P side
.drawBG:
	; This uses tile IDs $F9-$FB.
	ld   b, $03			; B = Number of tiles
	ld   a, $F9			; A = Initial tile ID
.loop:
	push af
	di
	mWaitForVBlankOrHBlank
	pop  af
	ldi  [hl], a		; Write tile ID, VRAMPtr++
	ei
	inc  a				; TileID++
	dec  b				; Drawn all tiles?
	jp   nz, .loop		; If not, loop
	
	call Task_PassControlFar
	ret
	
; =============== Play_Unpause ===============
; Unpauses the game.
Play_Unpause:
	; Resume player animations
	xor  a
	ld   [wNoCopyGFXBuf], a
	
	; Unpause music playback
	ld   a, SNC_UNPAUSE
	call HomeCall_Sound_ReqPlayExId
	
	; Blank out "PAUSE" from the HUD
	ld   a, [wPauseFlags]
	bit  PLB1, a		; Did 1P pause the game?
	jp   z, .bg2P		; If not, jump
.bg1P:
	ld   hl, $9C46		; HL = Tilemap ptr for 1P side
	jp   .drawBG
.bg2P:
	ld   hl, $9C4B		; HL = Tilemap ptr for 2P side
.drawBG:
	; Fill with blank ($00) tiles
	ld   b, $03			; B = Number of tiles
.loop:
	di
	mWaitForVBlankOrHBlank
	xor  a				
	ldi  [hl], a		; Write blank tile, VRAMPtr++
	ei
	dec  b				; Drawn all tiles?
	jp   nz, .loop		; If not, loop
	ret
	
; =============== Play_FrameAdv ===============
; Advances the game by a single frame.
Play_FrameAdv:
	; This unpauses the game, and executes gameplay code for a frame.
	; After it's done, the game is repaused.
	xor  a					; Enable player animations
	ld   [wNoCopyGFXBuf], a
	ld   a, [wPauseFlags]	; Save pause info
	push af
	xor  a					; Unpause the game
	ld   [wPauseFlags], a
	; Execute gameplay routines
	call Play_DoPlInput
	call Play_DoHUD
	call Play_DoMisc
	call Play_DoPlColi
	call Play_WriteKeysToBuffer
	call Play_DoScrollPos
	call Play_ExecExOBJCode
	call Task_PassControlFar
	pop  af					; Repause the game
	ld   [wPauseFlags], a
	ld   a, $01				; Pause player animations
	ld   [wNoCopyGFXBuf], a
	ret
	
; =============== Play_DoMisc ===============
; Handles miscelanneous actions related to gameplay / moves.
Play_DoMisc:
	
	;
	; PLAYFIELD FLASHING
	;
	;
	; This is triggered by writing $00 to wStageBGP (though any value that isn't $FF or $1B would work too).
	; When we get here, that value causes the playfield palette to be set to $FF (all black).
	; The effect only lasts for a single frame, as getting here with $FF restores the original palette.
	;
	
	; If the palette is normal, ignore this and continue using the normal palette
	ld   a, [wStageBGP]
	cp   $1B			; wStageBGP == normal?
	jp   z, .useNormPal	; If so, jump
	
	; If the palette is currently black (as set by .setFlash last frame), restore the normal palette
	ld   hl, wStageBGP
	cp   $FF			; wStageBGP == flashing?
	jp   z, .setNorm	; If so, jump
	
.setFlash:
	; Otherwise, wStageBGP is set to $00.
	; Set the playfield palette as completely black.
	ld   [hl], $FF
	jp   .useCustomPal
.setNorm:
	ld   [hl], $1B
	jp   .useCustomPal
	
.useNormPal:
	ld   a, $1B
.useCustomPal:
	ldh  [hScreenSect1BGP], a
	; Fall-through
	
;
; OBJ FLASHING
;

; =============== mFlashPlPal ===============
; Generates code to handle the palette flashing/cycling effects for sprites.
; This is a palette cycle effect based off wPlayTimer and an incrementing internal counter.
; wPlayTimer is used as we want the effect to pause while the game is paused.
;
; There are 4 different ways the palette is cycled:
; - Palette Set A:
;   - "No Special" -> Under the effect of Chizuru's super move
;   - Super Move -> Hit by any super move
; - Palette Set B:
;   - Hit by fire
;   - Super Move -> A few super moves use the second palette cycle
;
; IN
; - 1: Ptr to wPlInfo struct
; - 2: Ptr to target palette
; - 3: Normal palette
; - 4: Set A, Id 0 color
; - 5: Set A, Id 1 color
; - 6: Set A, Id 2 color
; - 7: Set A, Id 3 color
; - 8: Set B, Id 0 color
; - 9: Set B, Id 1 color
; - 10: Set B, Id 2 color
; - 11: Set B, Id 3 color
mFlashPlPal: MACRO
	; These two use palette set B
	ld   a, [\1+iPlInfo_Flags3]
	bit  PF3B_FIRE, a		; bit1 set?	
	jp   nz, .flashSlowB	; If so, jump
	bit  PF3B_SUPERALT, a	; bit6 set?	
	jp   nz, .flashSuperB		; If so, jump
	
	;
	; OBJ FLASHING (Set A) - NO SPECIAL RESTRICTION
	; 
	; This makes use of an additional field, iPlInfo_NoSpecialTimer.
	; This is a countdown timer set by one of Chizuru's super moves
	; that restricts the other player to normals until it elapses.
	;
	; To visually indicate how much time is left, the lower the timer is,
	; the faster the palette flashes.
	;
	
	; Skip if it isn't set
	ld   a, [\1+iPlInfo_NoSpecialTimer]
	or   a					; FlashTimer == 0?
	jp   z, .flashSuperA	; If so, jump
	
.flashDecA:
	; Decrement iPlInfo_NoSpecialTimer every 2 frames
	ld   hl, wPlayTimer
	ld   b, [hl]			; B = wPlayTimer
	bit  0, b				; wPlayTimer % 2 != 0?
	jp   nz, .chkSpeedRange	; If so, skip
	dec  a					; Otherwise, iPlInfo_NoSpecialTimer--
	ld   [\1+iPlInfo_NoSpecialTimer], a
	
.chkSpeedRange:
	;
	; Determine the palette cycle speed.
	; These are triggered by iPlInfo_NoSpecialTimer reaching certain ranges.
	;
	; The higher the value is, more wPlayTimer gets divided by 2, slowing
	; down the speed, with the topmost range using an outright fixed palette (ID 3).
	;
	cp   $0A		; iPlInfo_NoSpecialTimer < $0A?
	jp   c, .speed4	; If so, A = wPlayTimer
	cp   $78		; iPlInfo_NoSpecialTimer < $78?
	jp   c, .speed3	; If so, A = wPlayTimer / 2
	cp   $B4		; iPlInfo_NoSpecialTimer < $BA?
	jp   c, .speed2	; If so, A = wPlayTimer / 4
	cp   $F0		; iPlInfo_NoSpecialTimer < $F0?
	jp   c, .speed1	; If so, A = wPlayTimer / 8
.speed0:			; Otherwise, iPlInfo_NoSpecialTimer >= $F0
	ld   a, $03		; A = 3 (fixed palette)
	jp   .filter		
.speed1:
	srl  b
.speed2:
	srl  b
.speed3:
	srl  b
.speed4:
	ld   a, b
.filter:
	and  a, $03		; Filter in range 0-3
	jp   .flashA
	
.flashSlowB:
	;
	; OBJ FLASHING (Set B) - HIT BY FIRE
	; When hit by a fire attack, cycle the palette slowly.
	; 
	
	; PalId = ((wPlayTimer & $0F) / 4) % 4
	ld   a, [wPlayTimer]
	and  a, $0F
	srl  a
	srl  a
	jp   .flashB
	
.flashSuperB:
	;
	; OBJ FLASHING (Set B) - SUPER MOVE
	; The player flashes at max speed when hit by some special moves, quickly cycle the palette.
	; Like .flashSuperA, the player flashes at max speed for the duration of the super move.
	; However, individual hits can set PF3_SUPERALT to make them use the alternate palette.
	; 
	; PalId = wPlayTimer % 4
	;
	ld   a, [wPlayTimer]
	and  a, $03
.flashB:
	; Palette cycle B.
	; Pick the palette by ID
	cp   $01			; PalId == 1?
	jp   z, .flashB1	; If so, jump
	cp   $02			; ...
	jp   z, .flashB2
	cp   $03
	jp   z, .flashB3
.flashB0:				; Otherwise, PalId == 0
	ld   a, \<8>
	jp   .setPalB
.flashB1:
	ld   a, \<9>
	jp   .setPalB
.flashB2:
	ld   a, \<10>
	jp   .setPalB
.flashB3:
	ld   a, \<11>
.setPalB:
	ldh  [\2], a
	jp   .endFlash
.flashSuperA:
	;
	; OBJ FLASHING (Set A) - SUPER MOVE
	;
	; The player flashes at max speed for the duration of the super move.
	;
	; PalId = wPlayTimer % 4
	; 
	ld   a, [\1+iPlInfo_Flags0]
	bit  PF0B_SUPERMOVE, a		; Is the super move bit set?
	jp   z, .useNormPal			; If not, force the normal palette
	ld   a, [wPlayTimer]
	and  a, $03
.flashA:
	; Palette cycle A
	; Pick the palette by ID
	cp   $01			; PalId == 1?
	jp   z, .flashA1	; If so, jump
	cp   $02			; ...
	jp   z, .flashA2
	cp   $03
	jp   z, .flashA3
.flashA0:				; Otherwise, PalId == 0
	ld   a, \4
	jp   .setPalA
.flashA1:
	ld   a, \5
	jp   .setPalA
.flashA2:
	ld   a, \6
	jp   .setPalA
.flashA3:
	ld   a, \7
.setPalA:
	ldh  [\2], a
	jp   .endFlash
	
.useNormPal:
	; Use/restore normal 1P palette
	ld   a, \3
	ldh  [\2], a
.endFlash:
ENDM

;                                                      NORM | SET A          | SET B	
Play_DoMisc_FlashOBJ1P: mFlashPlPal wPlInfo_Pl1, rOBP0, $8C, $8C,$0C,$8C,$80, $4C,$D0,$34,$54
; Fall-through
Play_DoMisc_FlashOBJ2P: mFlashPlPal wPlInfo_Pl2, rOBP1, $4C, $4C,$0C,$4C,$40, $8C,$E0,$38,$A8
; Fall-through

Play_DoMisc_ApplyHitstop:
	; Copy over value
	ld   a, [wPlayHitstopSet]
	ld   [wPlayHitstop], a
	
Play_DoMisc_ClearInputProcOnStop:	
	; If inputs aren't processed, clear out the existing fields from both players
	ld   a, [wMisc_C027]
	bit  MISCB_PLAY_STOP, a
	jr   z, .end
	xor  a
	ld   [wPlInfo_Pl1+iPlInfo_JoyKeys], a
	ld   [wPlInfo_Pl1+iPlInfo_JoyNewKeysLH], a
	ld   [wPlInfo_Pl1+iPlInfo_JoyNewKeys], a
	ld   [wPlInfo_Pl2+iPlInfo_JoyKeys], a
	ld   [wPlInfo_Pl2+iPlInfo_JoyNewKeysLH], a
	ld   [wPlInfo_Pl2+iPlInfo_JoyNewKeys], a
.end:
	
Play_DoMisc_CalcDistance:
	call Play_CalcPlDistanceAndXFlip
	
Play_DoMisc_SetPlProjFlag:

	;
	; Update the player status flag marking if a projectile is visible & active on-screen.
	; This flag will be used as a shortcut to avoid checking two different fields every time
	;
	
	ld   hl, wPlInfo_Pl1+iPlInfo_Flags0
	res  PF0B_PROJ, [hl]		; Reset the flag to zero
	
	ld   a, [wOBJInfo_Pl1Projectile+iOBJInfo_Status]
	and  a, OST_VISIBLE		; Is the projectile visible?
	jr   z, .do2P			; If not, skip
	ld   a, [wOBJInfo_Pl1Projectile+iOBJInfo_Play_DamageVal]
	or   a					; Is there a penalty assigned to it (ie: it was thrown)?
	jr   z, .do2P			; If not, skip
	
	set  PF0B_PROJ, [hl] 	; Otherwise, don
	
.do2P:
	; Do the same for 2P
	ld   hl, wPlInfo_Pl2+iPlInfo_Flags0
	res  PF0B_PROJ, [hl]
	
	ld   a, [wOBJInfo_Pl2Projectile+iOBJInfo_Status]
	and  a, OST_VISIBLE
	jr   z, .end
	ld   a, [wOBJInfo_Pl2Projectile+iOBJInfo_Play_DamageVal]
	or   a
	jr   z, .end
	set  PF0B_PROJ, [hl]
.end:
	
Play_DoMisc_ShareVars:
	; Give visibility to some of the other player's variables.
	; This gives functions receiving the player struct known locations
	; to read data for the other player without having to do manual offset checks.
	
	ld   a, [wPlInfo_Pl1+iPlInfo_Flags0]		; Copy 1P status...
	ld   [wPlInfo_Pl2+iPlInfo_Flags0Other], a	; ...to 2P player's struct
	ld   a, [wPlInfo_Pl1+iPlInfo_Flags1]		; And so on
	ld   [wPlInfo_Pl2+iPlInfo_Flags1Other], a
	ld   a, [wPlInfo_Pl1+iPlInfo_Flags2]
	ld   [wPlInfo_Pl2+iPlInfo_Flags2Other], a
	ld   a, [wPlInfo_Pl1+iPlInfo_Flags3]
	ld   [wPlInfo_Pl2+iPlInfo_Flags3Other], a
	ld   a, [wPlInfo_Pl2+iPlInfo_Flags0]
	ld   [wPlInfo_Pl1+iPlInfo_Flags0Other], a
	ld   a, [wPlInfo_Pl2+iPlInfo_Flags1]
	ld   [wPlInfo_Pl1+iPlInfo_Flags1Other], a
	ld   a, [wPlInfo_Pl2+iPlInfo_Flags2]
	ld   [wPlInfo_Pl1+iPlInfo_Flags2Other], a
	ld   a, [wPlInfo_Pl2+iPlInfo_Flags3]
	ld   [wPlInfo_Pl1+iPlInfo_Flags3Other], a
	ld   a, [wOBJInfo_Pl1+iOBJInfo_OBJLstFlags]
	ld   [wPlInfo_Pl2+iPlInfo_OBJInfoFlagsOther], a
	ld   a, [wOBJInfo_Pl2+iOBJInfo_OBJLstFlags]
	ld   [wPlInfo_Pl1+iPlInfo_OBJInfoFlagsOther], a
	ld   a, [wOBJInfo_Pl1+iOBJInfo_X]
	ld   [wPlInfo_Pl2+iPlInfo_OBJInfoXOther], a
	ld   a, [wOBJInfo_Pl2+iOBJInfo_X]
	ld   [wPlInfo_Pl1+iPlInfo_OBJInfoXOther], a
	ld   a, [wOBJInfo_Pl1+iOBJInfo_Y]
	ld   [wPlInfo_Pl2+iPlInfo_OBJInfoYOther], a
	ld   a, [wOBJInfo_Pl2+iOBJInfo_Y]
	ld   [wPlInfo_Pl1+iPlInfo_OBJInfoYOther], a
	ld   a, [wPlInfo_Pl1+iPlInfo_Pow]
	ld   [wPlInfo_Pl2+iPlInfo_PowOther], a
	ld   a, [wPlInfo_Pl2+iPlInfo_Pow]
	ld   [wPlInfo_Pl1+iPlInfo_PowOther], a
	ld   a, [wPlInfo_Pl1+iPlInfo_MoveId]
	ld   [wPlInfo_Pl2+iPlInfo_MoveIdOther], a
	ld   a, [wPlInfo_Pl2+iPlInfo_MoveId]
	ld   [wPlInfo_Pl1+iPlInfo_MoveIdOther], a
	ld   a, [wPlInfo_Pl1+iPlInfo_HitTypeId]
	ld   [wPlInfo_Pl2+iPlInfo_HitTypeIdOther], a
	ld   a, [wPlInfo_Pl2+iPlInfo_HitTypeId]
	ld   [wPlInfo_Pl1+iPlInfo_HitTypeIdOther], a
	
Play_DoMisc_ResetDamage:
	;
	; If we got hit *DIRECTLY* by the opponent the last frame (doesn't matter if we blocked it):
	; - Reset physical damage-related variables to prevent the move from causing continuous damage every frame
	; - Allow the opponent to combo off the hit.
	;
	; Note this isn't applicable to projectile hits, they are handled by the collision check code.
	; This is, however, applicable to parts of the throw sequence.
	;
	ld   a, [wPlInfo_Pl1+iPlInfo_PhysHitRecv]
	or   a										; Did we get hit by the opponent?
	jr   z, .chkHit2P							; If not, skip
	xor  a
	ld   [wPlInfo_Pl2+iPlInfo_MoveDamageVal], a	; Prevent the move from dealing further damage
	ld   [wPlInfo_Pl1+iPlInfo_PhysHitRecv], a	; Unmark damage received flag
	ld   hl, wPlInfo_Pl2+iPlInfo_Flags1
	set  PF1B_ALLOWHITCANCEL, [hl] 			; Allow the opponent to start a new special off the hit
	inc  hl
	res  PF2B_HITCOMBO, [hl]					; Unmark the combo flag for the next time we hit cancel
	
.chkHit2P:
	; Same for the 2P side
	ld   a, [wPlInfo_Pl2+iPlInfo_PhysHitRecv]
	or   a					; Did we get hit by the opponent?
	jr   z, .copyDamageVars	; If not, skip
	xor  a
	ld   [wPlInfo_Pl1+iPlInfo_MoveDamageVal], a
	ld   [wPlInfo_Pl2+iPlInfo_PhysHitRecv], a
	ld   hl, wPlInfo_Pl1+iPlInfo_Flags1
	set  PF1B_ALLOWHITCANCEL, [hl]
	inc  hl
	res  PF2B_HITCOMBO, [hl]
	
.copyDamageVars:
	; Give visibility to the player-to-player push request
	ld   a, [wPlInfo_Pl1+iPlInfo_PushSpeedHReq]
	ld   [wPlInfo_Pl2+iPlInfo_PushSpeedHRecv], a
	ld   a, [wPlInfo_Pl2+iPlInfo_PushSpeedHReq]
	ld   [wPlInfo_Pl1+iPlInfo_PushSpeedHRecv], a
	
	; Give visibility to the move damage fields, which get copied over in the VBlank GFX Buffer handler.
	ld   hl, wPlInfo_Pl1+iPlInfo_MoveDamageVal
	ld   bc, wPlInfo_Pl2+iPlInfo_MoveDamageValOther
	call Play_CopyHLtoBC_3
	ld   hl, wPlInfo_Pl1+iPlInfo_MoveDamageValNext
	ld   bc, wPlInfo_Pl2+iPlInfo_MoveDamageValNextOther
	call Play_CopyHLtoBC_3
	ld   hl, wPlInfo_Pl2+iPlInfo_MoveDamageVal
	ld   bc, wPlInfo_Pl1+iPlInfo_MoveDamageValOther
	call Play_CopyHLtoBC_3
	ld   hl, wPlInfo_Pl2+iPlInfo_MoveDamageValNext
	ld   bc, wPlInfo_Pl1+iPlInfo_MoveDamageValNextOther
	call Play_CopyHLtoBC_3
	
; =============== mDecMaxPow ===============
; Generates code to automatically decrement the Max Power meter over time.
; IN
; - 1: Ptr to player struct
mDecMaxPow: MACRO
	; Pass the gauntlet of checks before checking if the bar should be decremented.
	ld   a, [\1+iPlInfo_Pow]
	
	; If our POW Meter got zeroed out, immediately disable MAX Power mode.
	; This is because elsewhere, the points where MAX Mode is set to end
	; only zero out iPlInfo_Pow but not the others.
	cp   $00			; iPlInfo_Pow == 0?
	jp   z, .powEmpty	; If so, jump
	; The bar must be full, otherwise this can't be MAX Power mode.
	cp   PLAY_POW_MAX	; Is the POW bar full?
	jp   nz, .end		; If not, skip
	; If there's still something in the MAX Power meter or the dec speed isn't 0,
	; decrement it slowly. Otherwise, empty it out completely.
	ld   a, [\1+iPlInfo_MaxPow]
	cp   $00			; Is the MAX Power mode enabled (!= 0)?
	jp   nz, .tryDec	; If so, jump
	; This check is weird. Why does it try decrementing even when iPlInfo_MaxPow is 0?
	ld   a, [\1+iPlInfo_MaxPowDecSpeed]
	cp   $00			; Is the decrementation speed set?
	jp   nz, .tryDec	; If so, jump
.powEmpty:
	; Empty the MAX Power meter
	xor  a
	ld   [\1+iPlInfo_Pow], a
	ld   [\1+iPlInfo_MaxPow], a
	ld   [\1+iPlInfo_MaxPowDecSpeed], a
	jp   .end
.tryDec:
	; Decrement the Max Power meter at the set speed.
	; The speed value is a bitmask, as the bar is only decremented when (wPlayTimer & iPlInfo_MaxPowDecSpeed) == 0
	; This results in the bar getting decremented at a slower rate when iPlInfo_MaxPowDecSpeed is higher.
	; Also, to have a constant decrementing speed, all set bits should be on the "right", ie:
	; %00000001
	; %00000011
	; %00000111
	; ...
	ld   a, [\1+iPlInfo_MaxPowDecSpeed]
	ld   b, a				; B = iPlInfo_MaxPowDecSpeed (mask)
	ld   a, [wPlayTimer]	; A = wPlayTimer (gameplay timer)
	and  a, b				; A & B != 0?
	jp   nz, .end			; If so, skip
	; Otherwise, decrement the bar
	; Once this reaches 0 and Play_UpdatePowBars decrements iPlInfo_MaxPowVisual to $00 too,
	; iPlInfo_Pow will be set to 0. This allows the jump to .powEmpty.
	ld   hl, \1+iPlInfo_MaxPow
	dec  [hl]
.end:
ENDM

Play_DoMisc_DecMaxPow1P: mDecMaxPow wPlInfo_Pl1
Play_DoMisc_DecMaxPow2P: mDecMaxPow wPlInfo_Pl2
	
; =============== mIncPlPow ===============
; Generates code to increment the normal POW meter if possible.
; This also handles the cheat for the meter powerup.
; If that cheat is enabled, the meters increment automatically and increments/decrements slower.
;
; IN
; - 1: Ptr to player struct
mIncPlPow: MACRO
	; Don't increment if the meter is at max value already
	ld   a, [\1+iPlInfo_Pow]
	cp   PLAY_POW_MAX		; Pow meter at max value?
	jp   z, .end			; If so, skip
	
	; When charging meter, increment at 0.5px/frame
	ld   a, [\1+iPlInfo_MoveId]
	cp   MOVE_SHARED_CHARGEMETER	; In the charge move?
	jp   z, .chargeSpeed	; If so, jump
	
	; If meter charges up automatically, do it at a slower rate (0.1px/frame)
	ld   a, [wDipSwitch]
	bit  DIPB_POWERUP, a	; Powerup cheat enabled?
	jp   z, .end				; If not, jump 
.autoSpeed:
	ld   b, $0F		; B = Speed mask, slow (see also: mDecMaxPow)
	jp   .tryInc
.chargeSpeed:
	ld   b, $01		; B = Speed mask, fast
	jp   .tryInc
.tryInc:
	
	; Try to increment the pow meter
	ld   a, [wPlayTimer]
	and  a, b		; wPlayTimer & SpeedMask != 0?
	jp   nz, .end	; If so, skip
	; Otherwise, iPlInfo_Pow++
	ld   hl, \1+iPlInfo_Pow
	inc  [hl]
	
	; If we reached the max value for the power bar, set the Max Power decrement speed.
	ld   a, [hl]
	cp   PLAY_POW_MAX		; Max power reached?
	jp   nz, .end			; If not, skip
	; If meter charged up automatically, decrement the meter at a slower rate
	ld   hl, \1+iPlInfo_MaxPowDecSpeed
	ld   a, [wDipSwitch]
	bit  DIPB_POWERUP, a	; Powerup cheat enabled?
	jp   nz, .decSlow			; If not, jump
.decFast:
	ld   [hl], $1F				; Write speed to iPlInfo_MaxPowDecSpeed
	jp   .end
.decSlow:
	ld   [hl], $3F				; ...
.end:
ENDM
	
Play_DoMisc_IncPow1P: mIncPlPow wPlInfo_Pl1
Play_DoMisc_IncPow2P: mIncPlPow wPlInfo_Pl2


; =============== mDecPlPow ===============
; Generates code to decrement the normal POW meter when the other player is taunting.
; IN
; - 1: Ptr to player struct
; - 2: Ptr to other player struct
mDecPlPow: MACRO
	; Only applicable if we're not at Max Power and there's something in the bar
	ld   a, [\1+iPlInfo_Pow]
	cp   PLAY_POW_MAX	; Is the current player at max power?
	jp   z, .end		; If so, skip
	cp   $00			; Is the current player's power bar empty?
	jp   z, .end		; If so, skip
	
	; If the other player is taunting, decrease the meter at 0.25px/frame
	; In the English version, this got upped to 1px/frame for some reason, meaning
	; one single taunt can wipe out the entire POW bar.
	ld   a, [\2+iPlInfo_MoveId]
	cp   MOVE_SHARED_TAUNT	; Is the other player taunting?
	jp   nz, .end			; If not, skip
IF REV_TAUNT == 0
	ld   a, [wPlayTimer]
	and  a, $03				; wPlayTimer % 4 != 0?
	jp   nz, .end			; If so, skip
ENDC

.doDec:
	ld   hl, \1+iPlInfo_Pow	; Otherwise, Pow--
	dec  [hl]
.end:
ENDM

Play_DoMisc_DecPowOnTaunt1P: mDecPlPow wPlInfo_Pl1, wPlInfo_Pl2
Play_DoMisc_DecPowOnTaunt2P: mDecPlPow wPlInfo_Pl2, wPlInfo_Pl1
	
;
; Increment the stun timers over time, until they reach the cap.
;
; As these timers are decremented when the player is hit/blocks a hit and the effect
; triggers when they reach 0, this results in requiring the player to hit the opponent
; multiple times in a short period of time to either dizzy or guard break
;
; See also: Play_Pl_DecStunTimer, which is executed by player tasks.
;
Play_DoMisc_IncDizzyTimer:
	; Every $10 frames, increment iPlInfo_DizzyProg
	ld   a, [wPlayTimer]
	and  a, $0F			
	jp   nz, .end
	ld   a, [wPlInfo_Pl1+iPlInfo_DizzyProgCap]
	ld   hl, wPlInfo_Pl1+iPlInfo_DizzyProg
	call Play_DoMisc_IncCustomTimer
	ld   a, [wPlInfo_Pl2+iPlInfo_DizzyProgCap]
	ld   hl, wPlInfo_Pl2+iPlInfo_DizzyProg
	call Play_DoMisc_IncCustomTimer
.end:	
Play_DoMisc_IncGuardBreakTimer:
	; Every $20 frames, increment iPlInfo_GuardBreakProg
	ld   a, [wPlayTimer]
	and  a, $1F
	jp   nz, .end
	ld   a, [wPlInfo_Pl1+iPlInfo_GuardBreakProgCap]
	ld   hl, wPlInfo_Pl1+iPlInfo_GuardBreakProg
	call Play_DoMisc_IncCustomTimer
	ld   a, [wPlInfo_Pl2+iPlInfo_GuardBreakProgCap]
	ld   hl, wPlInfo_Pl2+iPlInfo_GuardBreakProg
	call Play_DoMisc_IncCustomTimer
.end:
	jp   Play_DoMisc_DecNoThrowTimers
	
; =============== Play_DoMisc_IncCustomTimer ===============
; Increments a custom timer in the player struct until the target is reached.
; IN
; -  A: Timer target (iPlInfo_DizzyProgCap or iPlInfo_GuardBreakProgCap)
; - HL: Ptr to timer (iPlInfo_DizzyProg or iPlInfo_GuardBreakProg)
Play_DoMisc_IncCustomTimer:
	cp   a, [hl]		
	jp   z, .ret	; Target == Timer? If so, jump
	jp   nc, .inc	; Target >= Timer? If so, jump
	; [TCRF] Unreachable code.
	;        In case the timer went past the target, force it back to the max value.
	ld   [hl], a	; Copy Target to Timer
	jp   .ret
.inc:
	inc  [hl]		; Increment Timer
.ret:
	ret
	
Play_DoMisc_DecNoThrowTimers:
	; Decrement the wake up timer if it's not 0 already
	; iPlInfo_NoThrowTimer = MAX(iPlInfo_NoThrowTimer - 1, 0)
	ld   a, [wPlInfo_Pl1+iPlInfo_NoThrowTimer]
	or   a				; Timer == 0?
	jr   z, .chk2P		; If so, jump
	ld   hl, wPlInfo_Pl1+iPlInfo_NoThrowTimer
	dec  [hl]
.chk2P:
	; Do the same for 2P
	ld   a, [wPlInfo_Pl2+iPlInfo_NoThrowTimer]
	or   a
	jr   z, .end
	ld   hl, wPlInfo_Pl2+iPlInfo_NoThrowTimer
	dec  [hl]
.end:

Play_DoMisc_ShareThrowTimerVars:
	; Give visibility to throw-related timers
	ld   a, [wPlInfo_Pl1+iPlInfo_NoThrowTimer]
	ld   [wPlInfo_Pl2+iPlInfo_NoThrowTimerOther], a
	ld   a, [wPlInfo_Pl2+iPlInfo_NoThrowTimer]
	ld   [wPlInfo_Pl1+iPlInfo_NoThrowTimerOther], a
	; [TCRF] This one too
	ld   a, [wPlInfo_Pl1+iPlInfo_Unused_ThrowKeyTimer]
	ld   [wPlInfo_Pl2+iPlInfo_Unused_ThrowKeyTimerOther], a
	ld   a, [wPlInfo_Pl2+iPlInfo_Unused_ThrowKeyTimer]
	ld   [wPlInfo_Pl1+iPlInfo_Unused_ThrowKeyTimerOther], a
	ret
	
; =============== Play_CopyHLtoBC_3 ===============
; Copies three bytes from HL to BC in sequence, used to copy sets of
; data across the two player structs. 
; IN
; - HL: Ptr to source (wPlInfo entry)
; - BC: Ptr to destination (wPlInfo entry for the other player)
Play_CopyHLtoBC_3:
	ldi  a, [hl]	; Read from current player
	ld   [bc], a	; Write to other player
	inc  bc			; ...
	ldi  a, [hl]
	ld   [bc], a
	inc  bc
	ld   a, [hl]
	ld   [bc], a
	ret
	
; =============== Play_CalcPlDistanceAndXFlip ===============
; Calculates the distance between players, and between player and projectile.
; This also sets additional properties related to distances.
Play_CalcPlDistanceAndXFlip:

	;
	; 1P CHAR - 2P CHAR DISTANCE
	;
	; These related flags which are related to each other are also updated:
	; - SPRB_XFLIP
	; - SPRXB_PLDIR_R
	;
	ld   a, [wOBJInfo_Pl2+iOBJInfo_X]
	ld   b, a							; B = Player 2 X position
	ld   a, [wOBJInfo_Pl1+iOBJInfo_X]	; A = Player 1 X position
	sub  a, b				; A = Distance between players (1P - 2P)	
	jp   z, .setDistance	; Are they the same? If so, skip ahead
	jp   nc, .onRight		; Is 1P on the right of 2P? If so, jump (1P > 2P)
	; 
.onLeft:

	;
	; Player 1 is on the left of Player 2.
	;
	push af		; Save distance
	
	.onLeftChk1P:
		; The other player (2P) internally faces right
		ld   hl, wOBJInfo_Pl1+iOBJInfo_OBJLstFlags
		set  SPRXB_PLDIR_R, [hl]
		
		; Sometimes, the horizontal flip flag may get locked.
		; ie: when jumping over another player, we don't want to change direction
		ld   a, [wPlInfo_Pl1+iPlInfo_Flags1]
		bit  PF1B_XFLIPLOCK, a	; X Flip lock flag set?
		jp   nz, .onLeftChk2P	; If so, skip
		
		; Like the icons, character sprites face left by default.
		; Set the XFlip flag to make 1P face right.
		set  SPRB_XFLIP, [hl]
		
		;
		; Save the settings to iOBJInfo_OBJLstFlagsView as well, if possible.
		; This can be done only after the GFX finish loading (which also copies
		; iOBJInfo_OBJLstFlags to iOBJInfo_OBJLstFlagsView, but as we updated it just now, we resave it again)
		;
		ld   a, [wOBJInfo_Pl1+iOBJInfo_Status]
		bit  OSTB_GFXLOAD, a		; Are the GFX loading for this character?
		jp   nz, .onLeftChk2P		; If so, skip
		ld   a, [wPlInfo_Pl1+iPlInfo_MoveId]
		or   a						; Is there a move ID defined?
		jp   z, .onLeftChk2P		; If not, skip
		ldi  a, [hl]				; Read iOBJInfo_OBJLstFlags
		ld   [hl], a				; Write to iOBJInfo_OBJLstFlagsView
		
	.onLeftChk2P:
		; The other player (1P) internally faces left
		ld   hl, wOBJInfo_Pl2+iOBJInfo_OBJLstFlags
		res  SPRXB_PLDIR_R, [hl]
		
		; Don't make the character face left if the direction is locked
		ld   a, [wPlInfo_Pl2+iPlInfo_Flags1]
		bit  PF1B_XFLIPLOCK, a
		jr   nz, .onLeftChkEnd
		
		; Make 2P face left
		res  SPRB_XFLIP, [hl]
		
		; Save the settings to the visible set, if possible.
		ld   a, [wOBJInfo_Pl2+iOBJInfo_Status]
		bit  OSTB_GFXLOAD, a		; Are the GFX loading for this character?
		jp   nz, .onLeftChkEnd		; If so, skip
		ld   a, [wPlInfo_Pl2+iPlInfo_MoveId]
		or   a						; Is there a move ID defined?
		jp   z, .onLeftChkEnd		; If not, skip
		ldi  a, [hl]				; Read iOBJInfo_OBJLstFlags
		ld   [hl], a				; Write to iOBJInfo_OBJLstFlagsView
	.onLeftChkEnd:
	
	pop  af		; Restore distance
	
	; Since 1P is on the left of 2P, the 1P - 2P calculation returned a negative value.
	; iPlInfo_PlDistance must be a positive value, so:
	cpl			; A = -A
	inc  a
	jr   .setDistance
	
.onRight:
	;
	; Player 1 is on the right of Player 2.
	;
	push af
	
	.onRightChk1P:
		; The current player (2P) internally faces left
		ld   hl, wOBJInfo_Pl1+iOBJInfo_OBJLstFlags
		res  SPRXB_PLDIR_R, [hl]
		
		; Don't make the character face left if the direction is locked
		ld   a, [wPlInfo_Pl1+iPlInfo_Flags1]
		bit  PF1B_XFLIPLOCK, a		; X Flip lock flag set?
		jr   nz, .onRightChk2P		; If so, skip
		;--
		; [POI] Broken code.
		bit  0, c
		jr   nz, .onRightChk2P
		;--
		; Make 1P face left
		res  SPRB_XFLIP, [hl]
		
		; Save the settings to the visible set, if possible.
		ld   a, [wOBJInfo_Pl1+iOBJInfo_Status]
		bit  OSTB_GFXLOAD, a		; Are the GFX loading for this character?
		jp   nz, .onRightChk2P		; If so, skip
		ld   a, [wPlInfo_Pl1+iPlInfo_MoveId]
		or   a						; Is there a move ID defined?
		jp   z, .onRightChk2P		; If not, skip
		ldi  a, [hl]				; Read iOBJInfo_OBJLstFlags
		ld   [hl], a				; Write to iOBJInfo_OBJLstFlagsView
	.onRightChk2P:
		; The other player (1P) internally faces right
		ld   hl, wOBJInfo_Pl2+iOBJInfo_OBJLstFlags
		set  SPRXB_PLDIR_R, [hl]
		
		; Don't make the character face right if the direction is locked
		ld   a, [wPlInfo_Pl2+iPlInfo_Flags1]
		bit  PF1B_XFLIPLOCK, a
		jr   nz, .onRightChkEnd
		;--
		; [POI] Broken code.
		bit  0, c
		jr   nz, .onRightChkEnd
		;--
		; Make 2P face right
		set  SPRB_XFLIP, [hl]
		
		; Save the settings to the visible set, if possible.
		ld   a, [wOBJInfo_Pl2+iOBJInfo_Status]
		bit  OSTB_GFXLOAD, a		; Are the GFX loading for this character?
		jp   nz, .onRightChkEnd		; If so, skip
		ld   a, [wPlInfo_Pl2+iPlInfo_MoveId]
		or   a						; Is there a move ID defined?
		jp   z, .onRightChkEnd		; If not, skip
		ldi  a, [hl]				; Read iOBJInfo_OBJLstFlags
		ld   [hl], a				; Write to iOBJInfo_OBJLstFlagsView
	.onRightChkEnd:
	pop  af
	
.setDistance:
	; Save the calculated player distance
	ld   [wPlInfo_Pl1+iPlInfo_PlDistance], a
	ld   [wPlInfo_Pl2+iPlInfo_PlDistance], a
	;--

	;
	; 1P CHAR - 2P PROJECTILE DISTANCE
	;
	ld   a, [wOBJInfo_Pl2Projectile+iOBJInfo_X]
	ld   b, a							; B = 2P Projectile X
	ld   a, [wOBJInfo_Pl2Projectile+iOBJInfo_Status]
	bit  OSTB_VISIBLE, a				; Is the projectile visible?
	jp   nz, .chkProjDir1P				; If so, jump
	ld   a, [wOBJInfo_Pl2+iOBJInfo_X]	; Otherwise, use 2P's X position
	ld   b, a
	
.chkProjDir1P:
	; By default, set that 2P's projectile is on the left of Player 1.
	ld   hl, wOBJInfo_Pl1+iOBJInfo_OBJLstFlags
	res  SPRXB_OTHERPROJR, [hl]
	
	ld   a, [wOBJInfo_Pl1+iOBJInfo_X]	; A = 1P X Position
	sub  a, b							; A = Distance between 1P Char - 2P Projectile
	jp   z, .setProjDistance1P			; Are they the same? If so, jump
	jp   nc, .setProjDistance1P			; Is 1P on the right of 2P's projectile? If so, jump (1P > 2P)
	; Otherwise, 2P's projectile is on the right of Player 1.
	; Set that flag and force the negative distance to positive.
	set  SPRXB_OTHERPROJR, [hl]
	cpl		; A = -A
	inc  a
.setProjDistance1P:
	ld   [wPlInfo_Pl1+iPlInfo_ProjDistance], a
	;--	
	
	;
	; 2P CHAR - 1P PROJECTILE DISTANCE
	;
	ld   a, [wOBJInfo_Pl1Projectile+iOBJInfo_X]
	ld   b, a							; B = 1P Projectile X
	ld   a, [wOBJInfo_Pl1Projectile+iOBJInfo_Status]
	bit  OSTB_VISIBLE, a				; Is the projectile visible?
	jp   nz, .chkProjDir2P				; If so, jump
	ld   a, [wOBJInfo_Pl1+iOBJInfo_X]	; Otherwise, use 1P's X position
	ld   b, a
	
.chkProjDir2P:
	; By default, set that 1P's projectile is on the left of Player 2.
	ld   hl, wOBJInfo_Pl2+iOBJInfo_OBJLstFlags
	res  SPRXB_OTHERPROJR, [hl]
	
	ld   a, [wOBJInfo_Pl2+iOBJInfo_X]	; A = 2P X Position
	sub  a, b							; A = Distance between 2P Char - 1P Projectile
	jp   z, .setProjDistance2P			; Are they the same? If so, jump
	jp   nc, .setProjDistance2P			; Is 2P on the right of 1P's projectile? If so, jump (2P > 1P)
	; Otherwise, 1P's projectile is on the right of Player 1.
	; Set that flag and force the negative distance to positive.
	set  SPRXB_OTHERPROJR, [hl]
	cpl		; A = -A
	inc  a
.setProjDistance2P:
	ld   [wPlInfo_Pl2+iPlInfo_ProjDistance], a
	ret
	
; =============== Play_DoPlColi ===============
; Handles collision detection between players/projectile combinations.
; This subroutine sets up the flags/fields which tell if the player are overlapping
; with something and with what.
; How this is actually used is something that the hit code (Pl_DoHit) decides.
Play_DoPlColi:
	; Start by clearing out the collision flags from the last frame
	xor  a
	ld   [wPlInfo_Pl1+iPlInfo_ColiFlags], a
	ld   [wPlInfo_Pl2+iPlInfo_ColiFlags], a
	ld   [wPlInfo_Pl1+iPlInfo_ColiBoxOverlapX], a
	ld   [wPlInfo_Pl2+iPlInfo_ColiBoxOverlapX], a
	ld   [wOBJInfo_Pl1Projectile+iOBJInfo_Play_HitMode], a
	ld   [wOBJInfo_Pl2Projectile+iOBJInfo_Play_HitMode], a

	;
	; Handle collision detection between players.
	; This is a chain of subroutines which follow the same pattern.
	; When something is detected that would cause a player to not have collision,
	; the check is skipped, leaving blank the values in the collision flags for both players.
	;
	
Play_DoPlColi_1PChar2PChar:
	;
	; 1P Character Hurtbox - 2P Character Hurtbox
	; This is a bounds check against the generic collision box of both characters,
	; used for things like preventing two characters from overlapping.
	;


	; If any of the players has the "no hurtbox" flag get, skip this
	ld   a, [wPlInfo_Pl1+iPlInfo_Flags2]
	bit  PF2B_NOCOLIBOX, a
	jp   nz, .end
	ld   a, [wPlInfo_Pl2+iPlInfo_Flags2]
	bit  PF2B_NOCOLIBOX, a
	jp   nz, .end
	
	;
	; Get the variables for Player 1 used for the calculation.
	;
	
	; If Player 1 isn't using a collision box, skip this
	ld   a, [wOBJInfo_Pl1+iOBJInfo_ColiBoxId]
	or   a				; Collision box ID == 0?
	jr   z, .end		; If so, skip
	
	; Otherwise, get the variables for Player 1.
	ld   de, wPlayTmpColiA
	call Play_GetPlColiBox				; wPlayTmpColiA_* = 1P collision box sizes
	ld   a, [wOBJInfo_Pl1+iOBJInfo_X]	; B = 1P X position
	ld   b, a
	ld   a, [wOBJInfo_Pl1+iOBJInfo_Y]	; C = 1P Y position
	ld   c, a
	ld   a, [wOBJInfo_Pl1+iOBJInfo_OBJLstFlagsView]	; wPlayTmpColiA_OBJLstFlags = 1P Flags
	ld   [wPlayTmpColiA_OBJLstFlags], a				; Not enough registers to hold this
	
	;
	; Get the variables for Player 2 used for the calculation.
	;
	
	; If Player 2 isn't using a collision box, skip this
	ld   a, [wOBJInfo_Pl2+iOBJInfo_ColiBoxId]
	or   a				; Collision box ID == 0?
	jr   z, .end		; If so, skip
	
	; Otherwise, get the variables for Player 2.
	ld   de, wPlayTmpColiB
	call Play_GetPlColiBox				; wPlayTmpColiB_* = 2P collision box sizes
	ld   a, [wOBJInfo_Pl2+iOBJInfo_X]	; D = 2P X position
	ld   d, a
	ld   a, [wOBJInfo_Pl2+iOBJInfo_Y]	; E = 2P Y position
	ld   e, a
	ld   a, [wOBJInfo_Pl2+iOBJInfo_OBJLstFlagsView]
	ld   [wPlayTmpColiB_OBJLstFlags], a	; wPlayTmpColiA_OBJLstFlags = 1P Flags
	
	; 
	; Perform the collision checks between those boxes.
	;
	call Play_CheckColi	; Did a collision occur?
	jr   nc, .end		; If not, skip
	
.coliOk:
	; Make both players push each other, by having both
	; send and receive the outwards push.
	
	; This also saves the the amount of how much the collision boxes overlap horizontally.
	; How this is actually used depends on the move code. 
	; The various MoveC_* subroutines may optionally decide to call Play_Pl_MoveByColiBoxOverlapX
	; to push the player out based on it.
		
	ld   hl, wPlInfo_Pl1+iPlInfo_ColiFlags
	set  PCF_PUSHED, [hl]
	set  PCF_PUSHEDOTHER, [hl]
	inc  hl			; Seek to iPlInfo_ColiBoxOverlapX
	ld   [hl], b	; Save overlap amount
	
	ld   hl, wPlInfo_Pl2+iPlInfo_ColiFlags
	set  PCF_PUSHED, [hl]
	set  PCF_PUSHEDOTHER, [hl]
	inc  hl			
	ld   [hl], b
.end:

Play_DoPlColi_1PCharHitbox2PChar:
	;
	; 1P Character Hitbox - 2P Character Hurtbox
	; If the 1P Hitbox overlaps with the generic 2P collision box.
	;
	
	; Temporary hitboxes like the one for throw range can do collision
	; with moves that otherwise disable the hurtbox.
	; (this still would need to pass the guard check if it were a physical hit, but throws don't check that to begin with)
	ld   a, [wOBJInfo_Pl1+iOBJInfo_ForceHitboxId]
	or   a					; Is there a forced hitbox overriding the other two checks?
	jr   nz, .check			; If so, jump	
	ld   a, [wPlInfo_Pl2+iPlInfo_Flags2]
	bit  PF2B_NOHURTBOX, a	; Can the other player be hit?
	jp   nz, .end			; If not, skip
	ld   a, [wOBJInfo_Pl1+iOBJInfo_HitboxId]
	or   a					; Is there an actual hitbox defined?
	jr   z, .end			; If not, skip
.check:
	;
	; Get 1P Hitbox data
	;
	; A = Hitbox ID
	ld   de, wPlayTmpColiA
	call Play_GetPlColiBox
	ld   a, [wOBJInfo_Pl1+iOBJInfo_X]
	ld   b, a
	ld   a, [wOBJInfo_Pl1+iOBJInfo_Y]
	ld   c, a
	ld   a, [wOBJInfo_Pl1+iOBJInfo_OBJLstFlagsView]
	ld   [wPlayTmpColiA_OBJLstFlags], a
	
	;
	; Get 2P Hurtbox data
	;
	ld   a, [wOBJInfo_Pl2+iOBJInfo_ColiBoxId]
	or   a
	jr   z, .end
	ld   de, wPlayTmpColiB
	call Play_GetPlColiBox
	ld   a, [wOBJInfo_Pl2+iOBJInfo_X]
	ld   d, a
	ld   a, [wOBJInfo_Pl2+iOBJInfo_Y]
	ld   e, a
	ld   a, [wOBJInfo_Pl2+iOBJInfo_OBJLstFlagsView]
	ld   [wPlayTmpColiB_OBJLstFlags], a
	
	;
	; Perform the collision check
	;
	call Play_CheckColi
	jr   nc, .end
.coliOk:
	; A common detail across these hit handlers is that when a player is hit, it receives knockback (PCF_PUSHED).
	; It's also mandatory when receiving physical damage, as both PCF_PUSHED and PCF_HIT must be set.
	
	; Signal that 1P has hit the other player.	
	ld   hl, wPlInfo_Pl1+iPlInfo_ColiFlags
	set  PCF_HITOTHER, [hl]
	set  PCF_PUSHEDOTHER, [hl]
	
	; Signal that 2P has received a hit and is being pushed out.
	ld   hl, wPlInfo_Pl2+iPlInfo_ColiFlags
	set  PCF_PUSHED, [hl]
	set  PCF_HIT, [hl]
.end:

Play_DoPlColi_1PChar2PCharHitbox:
	;
	; 2P Character Hitbox - 1P Character Hurtbox
	; Like the other one, but the other way around.
	;

	ld   a, [wOBJInfo_Pl2+iOBJInfo_ForceHitboxId]
	or   a					; Is there a forced hitbox overriding the other two checks?
	jr   nz, .check			; If so, jump	
	ld   a, [wPlInfo_Pl1+iPlInfo_Flags2]
	bit  PF2B_NOHURTBOX, a	; Can the other player be hit?
	jp   nz, .end			; If not, skip
	ld   a, [wOBJInfo_Pl2+iOBJInfo_HitboxId]
	or   a					; Is there an actual hitbox defined?
	jr   z, .end			; If not, skip
.check:
	;
	; Get 2P Hitbox data
	;
	ld   de, wPlayTmpColiA
	call Play_GetPlColiBox
	ld   a, [wOBJInfo_Pl2+iOBJInfo_X]
	ld   b, a
	ld   a, [wOBJInfo_Pl2+iOBJInfo_Y]
	ld   c, a
	ld   a, [wOBJInfo_Pl2+iOBJInfo_OBJLstFlagsView]
	ld   [wPlayTmpColiA_OBJLstFlags], a
	
	;
	; Get 1P Hurtbox data
	;
	ld   a, [wOBJInfo_Pl1+iOBJInfo_ColiBoxId]
	or   a
	jr   z, .end
	ld   de, wPlayTmpColiB
	call Play_GetPlColiBox
	ld   a, [wOBJInfo_Pl1+iOBJInfo_X]
	ld   d, a
	ld   a, [wOBJInfo_Pl1+iOBJInfo_Y]
	ld   e, a
	ld   a, [wOBJInfo_Pl1+iOBJInfo_OBJLstFlagsView]
	ld   [wPlayTmpColiB_OBJLstFlags], a
	
	;
	; Perform the collision check
	;
	call Play_CheckColi
	jr   nc, .end
.coliOk:

	; Signal that 1P has received a hit
	ld   hl, wPlInfo_Pl1+iPlInfo_ColiFlags
	set  PCF_PUSHED, [hl]
	set  PCF_HIT, [hl]
	
	; Signal that 2P has hit the other player
	ld   hl, wPlInfo_Pl2+iPlInfo_ColiFlags
	set  PCF_HITOTHER, [hl]
	set  PCF_PUSHEDOTHER, [hl]
.end:

Play_DoPlColi_1PProj2PChar:
	;
	; 1P Projectile Hitbox - 2P Character Hurtbox
	;
	
	ld   a, [wPlInfo_Pl2+iPlInfo_Flags1]
	bit  PF1B_INVULN, a	; Is the other player invulnerable?
	jp   nz, .end			; If so, skip
	ld   a, [wPlInfo_Pl2+iPlInfo_Flags2]
	bit  PF2B_NOHURTBOX, a	; Can the other player be hit in general?
	jp   nz, .end			; If not, skip
	ld   a, [wOBJInfo_Pl1Projectile+iOBJInfo_Status]
	bit  OSTB_VISIBLE, a	; Is the projectile visible?
	jp   z, .end			; If not, skip
	ld   a, [wOBJInfo_Pl1Projectile+iOBJInfo_HitboxId]
	or   a					; Does the projectile have an hitbox?
	jp   z, .end			; If not, skip
.check:

	;
	; Get 1P Projectile data
	;
	ld   de, wPlayTmpColiA
	call Play_GetPlColiBox
	ld   a, [wOBJInfo_Pl1Projectile+iOBJInfo_X]
	ld   b, a
	ld   a, [wOBJInfo_Pl1Projectile+iOBJInfo_Y]
	ld   c, a
	ld   a, [wOBJInfo_Pl1Projectile+iOBJInfo_OBJLstFlags]
	ld   [wPlayTmpColiA_OBJLstFlags], a
	
	;
	; Get 2P Hurtbox data
	;
	ld   a, [wOBJInfo_Pl2+iOBJInfo_ColiBoxId]
	or   a
	jr   z, .end
	ld   de, wPlayTmpColiB
	call Play_GetPlColiBox
	ld   a, [wOBJInfo_Pl2+iOBJInfo_X]
	ld   d, a
	ld   a, [wOBJInfo_Pl2+iOBJInfo_Y]
	ld   e, a
	ld   a, [wOBJInfo_Pl2+iOBJInfo_OBJLstFlagsView]
	ld   [wPlayTmpColiB_OBJLstFlags], a
	
	;
	; Perform the collision check
	;
	call Play_CheckColi
	jr   nc, .end
.coliOk:
	; 1P projectile hit the other player, so remove it
	ld   a, PHM_REMOVE
	ld   [wOBJInfo_Pl1Projectile+iOBJInfo_Play_HitMode], a
	; 1P hit the other player with a projectile
	ld   hl, wPlInfo_Pl1+iPlInfo_ColiFlags
	set  PCF_PROJHITOTHER, [hl]
	set  PCF_PUSHEDOTHER, [hl]
	; 2P received a hit by a projectile
	ld   hl, wPlInfo_Pl2+iPlInfo_ColiFlags
	set  PCF_PUSHED, [hl]
	set  PCF_PROJHIT, [hl]
.end:

Play_DoPlColi_1PChar2PProj:
	;
	; 2P Projectile Hitbox - 1P Character Hurtbox
	;
	ld   a, [wPlInfo_Pl1+iPlInfo_Flags1]
	bit  PF1B_INVULN, a	; Is the other player invulnerable?
	jp   nz, .end			; If so, skip
	ld   a, [wPlInfo_Pl1+iPlInfo_Flags2]
	bit  PF2B_NOHURTBOX, a	; Can the other player be hit in general?
	jp   nz, .end			; If not, skip
	ld   a, [wOBJInfo_Pl2Projectile+iOBJInfo_Status]
	bit  OSTB_VISIBLE, a	; Is the projectile visible?
	jp   z, .end			; If not, skip
	ld   a, [wOBJInfo_Pl2Projectile+iOBJInfo_HitboxId]
	or   a					; Does the projectile have an hitbox?
	jp   z, .end			; If not, skip
.check:
	;
	; Get 2P Projectile data
	;
	ld   de, wPlayTmpColiA
	call Play_GetPlColiBox
	ld   a, [wOBJInfo_Pl2Projectile+iOBJInfo_X]
	ld   b, a
	ld   a, [wOBJInfo_Pl2Projectile+iOBJInfo_Y]
	ld   c, a
	ld   a, [wOBJInfo_Pl2Projectile+iOBJInfo_OBJLstFlags]
	ld   [wPlayTmpColiA_OBJLstFlags], a
	
	;
	; Get 1P Hurtbox data
	;
	ld   a, [wOBJInfo_Pl1+iOBJInfo_ColiBoxId]
	or   a
	jr   z, .end
	ld   de, wPlayTmpColiB
	call Play_GetPlColiBox
	ld   a, [wOBJInfo_Pl1+iOBJInfo_X]
	ld   d, a
	ld   a, [wOBJInfo_Pl1+iOBJInfo_Y]
	ld   e, a
	ld   a, [wOBJInfo_Pl1+iOBJInfo_OBJLstFlagsView]
	ld   [wPlayTmpColiB_OBJLstFlags], a
	
	;
	; Perform the collision check
	;
	call Play_CheckColi
	jr   nc, .end
.coliOk:
	; 2P projectile hit the other player, so remove it
	ld   a, PHM_REMOVE
	ld   [wOBJInfo_Pl2Projectile+iOBJInfo_Play_HitMode], a
	; 2P hit the other player with a projectile
	ld   hl, wPlInfo_Pl2+iPlInfo_ColiFlags
	set  PCF_PROJHITOTHER, [hl]
	set  PCF_PUSHEDOTHER, [hl]
	; 1P received a hit by a projectile
	ld   hl, wPlInfo_Pl1+iPlInfo_ColiFlags
	set  PCF_PUSHED, [hl]
	set  PCF_PROJHIT, [hl]
.end:

Play_DoPlColi_1PProj2PCharHitbox:
	;
	; 1P Projectile Hitbox - 2P Character Hitbox
	;
	; This is used when a move from 2P with an hitbox that can influence a projectile thrown by 1P.
	; 
	; Moves can set the player status bit PF0_PROJREM or PF0_PROJREFLECT, and this happens:
	; - PF0_PROJREM -> The projectile is deleted (as if it hit the target)
	; - PF0_PROJREFLECT -> The projectile is reflected
	;

	; If neiher of those bits is set, this collision check is skipped.
	ld   a, [wPlInfo_Pl2+iPlInfo_Flags0]
	and  a, PF0_PROJREM|PF0_PROJREFLECT		; Is 2P currently able to hit or reflect projectiles?
	jp   z, .end							; If not, skip
	
	; If there's no active projectile, skip
	ld   a, [wOBJInfo_Pl1Projectile+iOBJInfo_Status]
	bit  OSTB_VISIBLE, a		; Is the projectile visible?
	jp   z, .end				; If not, skip
	ld   a, [wOBJInfo_Pl1Projectile+iOBJInfo_HitboxId]
	or   a						; Does the projectile have an hitbox?
	jp   z, .end				; If not, skip
.check:
	;
	; Get 1P Projectile data
	;
	ld   de, wPlayTmpColiA
	call Play_GetPlColiBox
	ld   a, [wOBJInfo_Pl1Projectile+iOBJInfo_X]
	ld   b, a
	ld   a, [wOBJInfo_Pl1Projectile+iOBJInfo_Y]
	ld   c, a
	ld   a, [wOBJInfo_Pl1Projectile+iOBJInfo_OBJLstFlags]
	ld   [wPlayTmpColiA_OBJLstFlags], a
	ld   a, [wOBJInfo_Pl2+iOBJInfo_HitboxId]
	or   a
	jr   z, .end
	
	;
	; Get 2P Hitbox data
	;
	ld   de, wPlayTmpColiB
	call Play_GetPlColiBox
	ld   a, [wOBJInfo_Pl2+iOBJInfo_X]
	ld   d, a
	ld   a, [wOBJInfo_Pl2+iOBJInfo_Y]
	ld   e, a
	ld   a, [wOBJInfo_Pl2+iOBJInfo_OBJLstFlagsView]
	ld   [wPlayTmpColiB_OBJLstFlags], a
	call Play_CheckColi
	jr   nc, .end
.coliOk:
	;
	; Determine what to do if the hitbox and projectile collide
	;
	
	; If 2P can reflect projectiles, do just that.
	ld   a, [wPlInfo_Pl2+iPlInfo_Flags0]
	bit  PF0B_PROJREFLECT, a		; Is the flag set?
	jp   nz, .reflectProj		; If so, jump
	
	; If 2P is performing a super move that can remove projectiles (ie: Chizuru's),
	; any type of projectile can be erased, even from super moves.
	ld   a, [wPlInfo_Pl2+iPlInfo_Flags0]
	bit  PF0B_SUPERMOVE, a		; Flashing at max speed?
	jp   nz, .removeProj		; If so, jump
	
	; Otherwise, don't allow erasing projectiles with high priority.
	; (ie: 1P did one in his super)
	ld   a, [wOBJInfo_Pl1Projectile+iOBJInfo_Play_Priority]
	or   a						; Does the projectile have high priority?
	jp   nz, .end				; If so, skip
.removeProj:
	ld   a, PHM_REMOVE
	ld   [wOBJInfo_Pl1Projectile+iOBJInfo_Play_HitMode], a
	jp   .setFlags
.reflectProj:
	ld   a, PHM_REFLECT
	ld   [wOBJInfo_Pl1Projectile+iOBJInfo_Play_HitMode], a
.setFlags:
	; [POI] Set the flags for both players... which aren't actually used.
	;       Only the value at iOBJInfo_Play_HitMode matters.
	;       Also, inexplicably, this is also setting PCF_HIT/PCF_HITOTHER, which is only
	;       intended for physical hits that reach the opponent.
	;       But because this is being set, code like Play_Pl_SetHitTypeC_ChkHitType still has to account for this.
	ld   hl, wPlInfo_Pl1+iPlInfo_ColiFlags
	set  PCF_PROJREMOTHER, [hl]
	set  PCF_HIT, [hl]
	
	ld   hl, wPlInfo_Pl2+iPlInfo_ColiFlags
	set  PCF_HITOTHER, [hl]
	set  PCF_PROJREM, [hl]
.end:

Play_DoPlColi_1PCharHitbox2PProj:
	;
	; 2P Projectile Hitbox - 1P Character Hitbox
	;
	; Same thing, but for the other player
	
	ld   a, [wPlInfo_Pl1+iPlInfo_Flags0]
	and  a, PF0_PROJREM|PF0_PROJREFLECT
	jp   z, .end
	ld   a, [wOBJInfo_Pl2Projectile+iOBJInfo_Status]
	bit  OSTB_VISIBLE, a
	jp   z, .end
	ld   a, [wOBJInfo_Pl2Projectile+iOBJInfo_HitboxId]
	or   a
	jr   z, .end
.check:
	;
	; Get 2P Projectile data
	;
	ld   de, wPlayTmpColiA
	call Play_GetPlColiBox
	ld   a, [wOBJInfo_Pl2Projectile+iOBJInfo_X]
	ld   b, a
	ld   a, [wOBJInfo_Pl2Projectile+iOBJInfo_Y]
	ld   c, a
	ld   a, [wOBJInfo_Pl2Projectile+iOBJInfo_OBJLstFlags]
	ld   [wPlayTmpColiA_OBJLstFlags], a
	ld   a, [wOBJInfo_Pl1+iOBJInfo_HitboxId]
	or   a
	jr   z, .end
	
	;
	; Get 1P Hitbox data
	;
	ld   de, wPlayTmpColiB
	call Play_GetPlColiBox
	ld   a, [wOBJInfo_Pl1+iOBJInfo_X]
	ld   d, a
	ld   a, [wOBJInfo_Pl1+iOBJInfo_Y]
	ld   e, a
	ld   a, [wOBJInfo_Pl1+iOBJInfo_OBJLstFlagsView]
	ld   [wPlayTmpColiB_OBJLstFlags], a
	call Play_CheckColi
	jr   nc, .end
.coliOk:
	;
	; Determine what to do if the hitbox and projectile collide
	;
	ld   a, [wPlInfo_Pl1+iPlInfo_Flags0]
	bit  PF0B_PROJREFLECT, a
	jp   nz, .reflectProj
	ld   a, [wPlInfo_Pl1+iPlInfo_Flags0]
	bit  PF0B_SUPERMOVE, a
	jp   nz, .removeProj
	ld   a, [wOBJInfo_Pl2Projectile+iOBJInfo_Play_Priority]
	or   a
	jp   nz, .end
.removeProj:
	ld   a, PHM_REMOVE
	ld   [wOBJInfo_Pl2Projectile+iOBJInfo_Play_HitMode], a
	jp   .setFlags
.reflectProj:
	ld   a, PHM_REFLECT
	ld   [wOBJInfo_Pl2Projectile+iOBJInfo_Play_HitMode], a
.setFlags:
	ld   hl, wPlInfo_Pl2+iPlInfo_ColiFlags
	set  PCF_PROJREMOTHER, [hl]
	set  PCF_HIT, [hl]
	ld   hl, wPlInfo_Pl1+iPlInfo_ColiFlags
	set  PCF_HITOTHER, [hl]
	set  PCF_PROJREM, [hl]
.end:

Play_DoPlColi_1PProj2PProj:
	;
	; 1P Projectile Hitbox - 2P Projectile Hitbox
	;
	; In general, they cancel each other out.
	
	; Both projectiles must be visible
	ld   a, [wOBJInfo_Pl1Projectile+iOBJInfo_Status]
	bit  OSTB_VISIBLE, a
	jp   z, .end
	ld   a, [wOBJInfo_Pl2Projectile+iOBJInfo_Status]
	bit  OSTB_VISIBLE, a
	jp   z, .end
.check:
	;
	; Get 1P Projectile data
	;
	ld   a, [wOBJInfo_Pl1Projectile+iOBJInfo_HitboxId]
	or   a
	jr   z, .end
	ld   de, wPlayTmpColiA
	call Play_GetPlColiBox
	ld   a, [wOBJInfo_Pl1Projectile+iOBJInfo_X]
	ld   b, a
	ld   a, [wOBJInfo_Pl1Projectile+iOBJInfo_Y]
	ld   c, a
	ld   a, [wOBJInfo_Pl1Projectile+iOBJInfo_OBJLstFlags]
	ld   [wPlayTmpColiA_OBJLstFlags], a
	;
	; Get 2P Projectile data
	;
	ld   a, [wOBJInfo_Pl2Projectile+iOBJInfo_HitboxId]
	or   a
	jr   z, .end
	ld   de, wPlayTmpColiB
	call Play_GetPlColiBox
	ld   a, [wOBJInfo_Pl2Projectile+iOBJInfo_X]
	ld   d, a
	ld   a, [wOBJInfo_Pl2Projectile+iOBJInfo_Y]
	ld   e, a
	ld   a, [wOBJInfo_Pl2Projectile+iOBJInfo_OBJLstFlags]
	ld   [wPlayTmpColiB_OBJLstFlags], a
	call Play_CheckColi
	jr   nc, .end
.coliOk:
	; Check projectile priority.
	; The one with higher priority value erases the other, or both cancel each
	; other out when they have same priority.
	; Note that, generally, super move projectiles have the higher priority.
	ld   a, [wOBJInfo_Pl2Projectile+iOBJInfo_Play_Priority]
	ld   b, a												; B = 2P Projectile Priority
	ld   a, [wOBJInfo_Pl1Projectile+iOBJInfo_Play_Priority]	; A = 1P Projectile Priority
	cp   b				
	jp   z, .remAllProj	; 1P == 2P? If so, jump
	jp   c, .remProj1P	; 1P < 2P? If so, jump
.remProj2P:
	; Otherwise, 1P > 2P.
	; 1P Projectile stays, 2P removed
	ld   a, PHM_NONE
	ld   [wOBJInfo_Pl1Projectile+iOBJInfo_Play_HitMode], a
	ld   a, PHM_REMOVE
	ld   [wOBJInfo_Pl2Projectile+iOBJInfo_Play_HitMode], a
	jp   .end
.remProj1P:
	; 2P Projectile stays, 1P removed
	ld   a, PHM_NONE
	ld   [wOBJInfo_Pl2Projectile+iOBJInfo_Play_HitMode], a
	ld   a, PHM_REMOVE
	ld   [wOBJInfo_Pl1Projectile+iOBJInfo_Play_HitMode], a
	jp   .end
.remAllProj:
	; Both projectiles removed
	ld   a, PHM_REMOVE
	ld   [wOBJInfo_Pl1Projectile+iOBJInfo_Play_HitMode], a
	ld   [wOBJInfo_Pl2Projectile+iOBJInfo_Play_HitMode], a
.end:
	ret 
	
; =============== Play_GetPlColiBox ===============
; Gets the length of the collision boxes.
; This copies 4 bytes from the indexed Play_ColiBoxTbl entry to DE.
; IN
; - A: Collision box ID
; - DE: Ptr to destination
Play_GetPlColiBox:

	; Index the table with collision boxes (4 byte entries)
	; HL = A * 4
	ld   h, $00
	ld   l, a		; HL = A
	add  hl, hl		; HL * 2
	add  hl, hl		; HL * 2
	push de
		; Offset the table
		ld   de, Play_ColiBoxTbl
		add  hl, de
	pop  de
	
	; Read out the entries to DE
	ldi  a, [hl]	; byte0 - X Origin
	ld   [de], a
	inc  de
	ldi  a, [hl]	; byte1 - Y Origin
	ld   [de], a
	inc  de
	ldi  a, [hl]	; byte2 - H Radius
	ld   [de], a
	inc  de
	ld   a, [hl]	; byte3 - V Radius
	ld   [de], a
	ret
	
; =============== Play_CheckColi ===============
; Checks if the specified collision boxes overlap.
;
; Note that player sprites don't get V-flipped, so the only special checks are made against SPRB_XFLIP.
;
; IN:
; - B: 1P X position
; - C: 1P Y position
; - D: 2P X position
; - E: 2P Y position
; OUT
; - C flag: If set, the collision boxes overlap
; - B: X Box Overlapping (how much the collision boxes overlap horizontally)
; - C: Y Box Overlapping (...)
; - D: 1P Absolute X Box Origin
; - E: 1P Absolute Y Box Origin
Play_CheckColi:
	
	;--
	;
	; X BOUNDS CHECK
	;
	; In this one, we have to deal with the sprite being X flipped.
	; When a sprite is flipped, the collision box origin is flipped relative to the player's absolute X position.
	; (which, in practice, means A = -A)
	; ie: the negative value (left of origin) becomes positive (right of origin).
	;
	; Note that it won't change the box width at all, as it's a radius that always extends equally
	; to both the left and right sides of the box origin.
	;
	
	
	;##
	;
	; B = H = 1P Absolute H Origin
	; 
	; Convert the relative origin in wPlayTmpColiA_OriginH to absolute,
	; by adding the X player position to it.
	;
	
	; H = OBJLst flags (for the X flip flag)
	ld   a, [wPlayTmpColiA_OBJLstFlags]
	ld   h, a
	; A = Relative X Origin (accounting for X flip)
	ld   a, [wPlayTmpColiA_OriginH]
	bit  SPRB_XFLIP, h		; Is the player X flipped?
	jr   z, .setHOrigin1P	; If not, jump
	cpl						; Otherwise, A = -A
	inc  a
.setHOrigin1P:
	; Convert the relative origin to absolute.
	add  b					; AbsXOrg = RelXOrg + AbsPlX
	; Save the result to B and H
	ld   b, a ; Why save it to B?
	ld   h, a
	

.getHOrigin2P:
	;##
	;
	; A = 2P Absolute H Origin
	;
	
	; L = OBJLst flags (for the X flip flag)
	ld   a, [wPlayTmpColiB_OBJLstFlags]
	ld   l, a
	; A = Relative X origin (accounting for X flip)
	ld   a, [wPlayTmpColiB_OriginH]
	bit  SPRB_XFLIP, l
	jr   z, .setHOrigin2P
	cpl
	inc  a
.setHOrigin2P:
	; Convert the relative origin to absolute.
	add  a, d				; AbsXOrg = RelXOrg + AbsPlX
	
	
.getHDist:
	;##
	;
	; B = Distance between collision box origins.
	;     
	sub  a, b			; A = 2P - 1P
	jp   nc, .setHDist	; Is that >= 0 (2P to the right of 1P)? If so, jump
	cpl					; Otherwise, A = -A
	inc  a
.setHDist:
	ld   b, a

.getLimitH:
	;##
	;
	; Determine the range threshold (max distance for collision).
	;
	; As the widths are radiuses that extend to both sides equally, this is always the 
	; sum of the two players' horizontal widths, regardless of a player's position or X flip.
	;
	; A = wPlayTmpColiA_RadH + wPlayTmpColiB_RadH
	push bc
		;
		ld   a, [wPlayTmpColiA_RadH]	; B = 1P Box Width
		ld   b, a
		ld   a, [wPlayTmpColiB_RadH]	; A = 2P Box Width
		add  b							; Add those together
	pop  bc
	
.chkBoundsH:
	;##
	;
	; Perform the bounds check.
	; If the distance between box origins is larger than the threshold, the boxes aren't overlapping.
	; so we can return.
	;
	; Otherwise, save to B by how much they overlap
	sub  a, b			; A -= DistanceH
	jp   c, .retClear	; A < 0? If so, return
	ld   b, a			; Otherwise, save the result to B
	
	;---
	
.doV:

	;--
	;
	; Y BOUNDS CHECK
	;
	; This is essentially the same, except there's no Y flip here.
	;
	
	;
	; C = L = 1P Absolute V Origin
	;
	ld   a, [wPlayTmpColiA_OriginV]
	add  c
	ld   c, a	; Why save a copy here?
	ld   l, a
.getVOrigin2P:
	;##
	;
	; A = 2P Absolute V Origin
	;
	ld   a, [wPlayTmpColiB_OriginV]
	add  a, e
	
.getVDist:
	;##
	;
	; C = Distance between collision box origins.
	;   
	sub  a, c			; A = 2P - 1P
	jp   nc, .setVDist	; Is that >= 0 (2P to the right of 1P)? If so, jump
	cpl					; Otherwise, A = -A
	inc  a
.setVDist:
	ld   c, a
	
	;##
	;
	; Determine threshold
	;
	; A = wPlayTmpColiA_RadV + wPlayTmpColiB_RadV
	push bc
		ld   a, [wPlayTmpColiA_RadV]
		ld   b, a
		ld   a, [wPlayTmpColiB_RadV]
		add  b
	pop  bc
	
.chkBoundsV:
	;##
	;
	; Perform the bounds check.
	;
	
	; Distance must be positive
	sub  a, c						; A -= DistanceV
	jp   c, .retClear				; A < 0? If so, jump
	ld   c, a						; Otherwise, save the result to C
	
	; Move the 1P/2P distances to DE
	push hl
	pop  de
	
.retSet:
	scf			; Set carry
	ret
.retClear:
	or   a		; Clear carry
	ret
Play_ColiBoxTbl:
	; [TCRF] The ones marked by  be unused (needs further checks)
	db $00,$00,$00,$00 ; $00 [POI] Dummy, unused
	db $00,$FC,$08,$10 ; $01 
	db $F7,$00,$0D,$09 ; $02 
	db $00,$00,$10,$10 ; $03 
	db $00,$00,$10,$12 ; $04 
	db $00,$00,$A0,$7F ; $05 
	db $0D,$02,$10,$08 ; $06 ; [TCRF] Never used
	db $00,$09,$08,$08 ; $07 
	db $FE,$F0,$12,$20 ; $08 
	db $00,$EE,$10,$20 ; $09 ; [TCRF] Never used
	db $00,$00,$08,$08 ; $0A 
	db $00,$00,$06,$12 ; $0B 
	db $03,$00,$08,$1D ; $0C 
	db $00,$F0,$20,$20 ; $0D 
	db $00,$C2,$28,$4F ; $0E 
	db $00,$10,$A0,$06 ; $0F 
	db $00,$C2,$08,$6F ; $10 
	db $00,$00,$0C,$0C ; $11 
	db $0D,$00,$15,$1D ; $12 
	db $00,$F4,$11,$1C ; $13 
	db $EA,$FC,$08,$0E ; $14 
	db $F2,$FC,$0E,$14 ; $15 
	db $F9,$F9,$19,$14 ; $16 
	db $00,$FC,$0B,$0B ; $17
	db $00,$F5,$12,$12 ; $18
	db $00,$EE,$18,$18 ; $19
	db $00,$0C,$0B,$0B ; $1A
	db $00,$05,$12,$12 ; $1B
	db $00,$FE,$18,$18 ; $1C
	db $F5,$FB,$11,$09 ; $1D 
	db $F5,$02,$13,$11 ; $1E 
	db $EA,$FA,$0F,$0D ; $1F 
	db $F3,$FB,$0D,$0F ; $20
	db $F7,$F4,$0E,$0D ; $21 
	db $00,$F9,$11,$18 ; $22 
	db $F3,$E3,$0C,$09 ; $23 
	db $EE,$07,$0E,$0A ; $24 
	db $FD,$F8,$0D,$10 ; $25 
	db $F8,$F8,$0D,$0F ; $26 
	db $FA,$FF,$0B,$0B ; $27 
	db $FB,$FC,$0E,$14 ; $28 
	db $E0,$FC,$0B,$08 ; $29 
	db $DD,$FC,$0E,$08 ; $2A 
	db $FA,$00,$12,$13 ; $2B 
	db $E8,$FB,$0B,$10 ; $2C 
	db $FB,$F4,$0D,$16 ; $2D 
	db $ED,$F9,$0D,$10 ; $2E 
	db $00,$04,$0C,$0C ; $2F 
	db $E8,$00,$0E,$09 ; $30
	db $E8,$FE,$0A,$0B ; $31
	db $F5,$EE,$0C,$17 ; $32
	db $EC,$00,$0D,$0D ; $33
	db $EB,$FA,$0D,$12 ; $34
	db $FE,$FC,$14,$0E ; $35
	db $F6,$FA,$14,$0E ; $36
	db $F7,$02,$11,$0F ; $37 
	db $F9,$FA,$12,$10 ; $38 
	db $FB,$09,$0D,$0B ; $39 
	db $FE,$FC,$14,$13 ; $3A 
	db $F4,$F7,$09,$09 ; $3B 
	db $00,$FC,$10,$17 ; $3C 
	db $F0,$FB,$0D,$16 ; $3D 
	db $E8,$F8,$10,$18 ; $3E 
	db $F5,$FE,$14,$0D ; $3F 
	db $F4,$FE,$13,$09 ; $40
	db $F8,$00,$15,$09 ; $41
	db $FE,$F5,$1A,$09 ; $42
	db $EC,$FE,$13,$05 ; $43
	db $EE,$00,$0D,$09 ; $44 
	db $F0,$FD,$13,$0D ; $45 
	db $EF,$F8,$0D,$12 ; $46 
	db $ED,$05,$0D,$0C ; $47 
	db $F3,$FC,$0D,$13 ; $48 
	db $F6,$FA,$0C,$13 ; $49 
	db $F0,$00,$0D,$09 ; $4A 
	db $FA,$ED,$0D,$09 ; $4B 
	db $F7,$09,$0D,$09 ; $4C 
	db $F2,$09,$0D,$09 ; $4D 
	db $F1,$05,$0D,$09 ; $4E 
	db $F0,$F5,$0D,$09 ; $4F 
	db $EE,$00,$0D,$09 ; $50
	db $F3,$00,$0D,$09 ; $51
	db $F5,$09,$0D,$09 ; $52
	db $EE,$07,$0D,$09 ; $53 
	db $FF,$F5,$0D,$09 ; $54 
	db $FB,$00,$0D,$09 ; $55 
	db $F9,$09,$0D,$09 ; $56 
	db $F2,$00,$0D,$09 ; $57 
	db $EB,$00,$0D,$09 ; $58 
	db $F2,$F3,$0D,$09 ; $59 
	db $FD,$F1,$0D,$09 ; $5A 
	db $EF,$09,$0D,$09 ; $5B 
	db $FC,$00,$0D,$09 ; $5C 
	db $F7,$F5,$0D,$09 ; $5D 
	db $F4,$09,$0D,$09 ; $5E 
	db $F4,$F6,$0D,$09 ; $5F 
	db $FC,$FC,$0D,$09 ; $60
	db $F3,$FD,$0D,$09 ; $61
	db $F4,$F9,$0D,$09 ; $62
	db $FD,$EB,$0D,$09 ; $63
	db $F8,$09,$0D,$09 ; $64
	db $EA,$09,$0D,$09 ; $65 
	db $ED,$FA,$0D,$09 ; $66 
	db $E7,$00,$0D,$09 ; $67 
	db $F4,$09,$0D,$09 ; $68 
	db $F2,$F8,$0D,$09 ; $69 
	db $ED,$09,$0D,$09 ; $6A 
	db $FA,$09,$0D,$09 ; $6B 
	db $FC,$09,$0D,$09 ; $6C 
	db $FC,$F3,$0D,$09 ; $6D 
	db $EF,$FC,$0D,$09 ; $6E 
	db $F6,$F4,$0D,$09 ; $6F 
	db $F8,$F5,$0D,$09 ; $70 
	db $FA,$00,$0D,$09 ; $71 
; =============== Play_ChkEnd ===============
; Series of checks that handle the triggers that can end a round.
Play_ChkEnd:
	;
	; Enable input processing as long as the round isn't over.
	; There are a few different triggers that cause the round to end,
	; which will be checked for now.
	;
	ld   hl, wMisc_C027			; Enable by default
	res  MISCB_PLAY_STOP, [hl]
	; Fall-through
	
; =============== Play_ChkEnd_TimeOver ===============
Play_ChkEnd_TimeOver:
	;
	; TIME OVER CHECK
	;
	ld   a, [wRoundTime]
	or   a							; wRoundTime != 0?
	jp   nz, Play_ChkEnd_Slowdown	; If so, jump
.timeOver:							; Otherwise...
	ld   hl, wMisc_C027				; Lock controls
	set  MISCB_PLAY_STOP, [hl]
	call Play_LoadPostRoundText0	; Prepare text set
	call Play_DoTimeOverText		; 
	jp   Play_ChkEnd_KO.chkWaitPost	; Continue to the standard post-round handler
	
; =============== Play_ChkEnd_Slowdown ===============
Play_ChkEnd_Slowdown:
	;
	; Handles slowdown effect.
	; As long as slowdown is active, this takes control as main gameplay loop.
	;
	; This is here because the game slows down for a moment when KO'ing an opponent,
	; through it's also used occasionally for other parts.
	;
	
	; Do the slowdown until wPlaySlowdownTimer elapses.
	ld   a, [wPlaySlowdownTimer]
	or   a						; wPlaySlowdownTimer == 0?
	jp   z, Play_ChkEnd_KO		; If so, skip
	; Otherwise, execute the slowdown
	dec  a						; wPlaySlowdownTimer--
	ld   [wPlaySlowdownTimer], a
	
	; Count down from wPlaySlowdownSpeed.
	; When it reaches 0, execute once a complete gameplay loop.
	ld   a, [wPlaySlowdownSpeed]	; A = TickLeft
.loop:
	or   a				; TickLeft == 0?
	jp   z, .execNorm	; If so, execute a normal gameplay loop
.execBlank:				; Otherwise, execute a simplified one that essentially doesn't process OBJInfo
	push af				; Save TickLeft				
		; Keep GFX buffer intact, as copying tiles to the buffer influences the animation timing.
		ld   a, $01					
		ld   [wNoCopyGFXBuf], a
		call Play_DoPlInput
		call Play_DoHUD
		call Play_DoMisc
		call Play_WriteKeysToBuffer
		; Calling this is the main key behind how the slowdown works.
		; This will skip processing the two other tasks, which are used
		; to handle player movement.
		call Task_SkipAllAndWaitVBlank
		xor  a
		ld   [wNoCopyGFXBuf], a
	pop  af				; Restore TickLeft
	dec  a				; TickLeft--
	jp   .loop			; Go check if we're done "waiting"
.execNorm:
	call Play_DoPlInput
	call Play_DoHUD
	call Play_DoMisc
	call Play_DoPlColi
	call Play_WriteKeysToBuffer
	call Play_DoScrollPos
	call Play_ExecExOBJCode
	call Task_PassControlFar
	jp   Play_ChkEnd_Slowdown
	
; =============== Play_ChkEnd_KO ===============
Play_ChkEnd_KO:
	;
	; KO CHECK
	;
	; If any player has no health, handle the KO display
	ld   a, [wPlInfo_Pl1+iPlInfo_Health]
	or   a				; 1P Health == 0?
	jr   z, .showKO		; If so, round's over
	ld   a, [wPlInfo_Pl2+iPlInfo_Health]
	or   a				; 2P Health == 0?
	jp   nz, Play_ChkEnd_Ret		; If not, return
.showKO:
	ld   hl, wMisc_C027
	set  MISCB_PLAY_STOP, [hl]
	call Play_LoadPostRoundText0
	call Play_DoKOText
	;--
	; [POI] Checking if the players were ready was already done in Play_LoadPostRoundText0.
	;       What's the point of checking this again? (note it's also an oddity in 95).
	;       Players can only be in the moves MOVE_SHARED_NONE or MOVE_SHARED_IDLE when we get here.
.chkWaitPost:
	; Execute main loop
	ld   b, $01
	call Play_MainLoop_PostRoundTextNoDisplay
.chkWaitPost1P:
	; Players must be either in the idle move (winner/draw) or have no move (lost).
	; This is to allow any currently executing move to finish.
	ld   a, [wPlInfo_Pl1+iPlInfo_MoveId]
	cp   MOVE_SHARED_NONE	; MoveId == 0?
	jr   z, .chkWaitPost2P	; If so, jump
	cp   MOVE_SHARED_IDLE	; MoveId == 2?
	jr   nz, .chkWaitPost	; If not, wait again
.chkWaitPost2P:
	ld   a, [wPlInfo_Pl2+iPlInfo_MoveId]
	cp   MOVE_SHARED_NONE	; MoveId == 0?
	jr   z, .chkEndType; If so, jump
	cp   MOVE_SHARED_IDLE	; MoveId == 2?
	jr   nz, .chkWaitPost	; If not, wait again
	;--
.chkEndType:
	;
	; Determine what kind of text to follow up the "KO" or "TIME OVER" with.
	; Decide depending on the player health.
	;
	ld   a, [wPlInfo_Pl1+iPlInfo_Health]	; A = 1P Health
	ld   hl, wPlInfo_Pl2+iPlInfo_Health		; B = Ptr to 2P Health
	cp   a, [hl]		; Compare them
	jr   z, .draw		; Do they match? If so, it's a DRAW GAME
	jr   c, .won2P		; 1P < 2P? If so, 2P Won
	; Otherwise, 1P Won
.won1P:
	call Play_Set1PWin
	ld   bc, wPlInfo_Pl1		; Winner
	ld   de, wPlInfo_Pl2		; Loser
	call Play_SetWinLoseMoves
	jr   .showPostRoundText
.won2P:
	call Play_Set2PWin
	ld   bc, wPlInfo_Pl2		; Winner
	ld   de, wPlInfo_Pl1		; Loser
	call Play_SetWinLoseMoves
	jr   .showPostRoundText
.draw:
	call Play_SetDraw
	call Play_SetDrawMoves
	
.showPostRoundText:
	; Display the win/lose anim for a long time while the text is on-screen.
	; This is enough time for all win poses to finish, and still having a small delay when they end.
	ld   b, $F0
	call Play_MainLoop_PostRoundTextDisplay
	

	
Play_ChkEnd_ChkNewRound:
	;
	; Determines if a new round should start.
	;
	
	xor  a
	ld   [wStageDraw], a
	
	call IsInTeamMode	; Playing in team mode?
	jp   c, .team		; If so, jump
	
.single:
	;
	; SINGLE MODE
	; 
	
	; The final round uses its own set of rules.
	ld   a, [wRoundNum]
	cp   $03					; Is this the FINAL!! round? (round 4)
	jp   z, .chkFinalRoundRes	; If so, jump
	
	; If any player won two rounds in single mode, the stage is over.
	ld   a, [wPlInfo_Pl1+iPlInfo_SingleWinCount]
	cp   $02			; Did 1P win two rounds?
	jp   z, .win1P		; If so, jump
	ld   a, [wPlInfo_Pl2+iPlInfo_SingleWinCount]
	cp   $02			; Did 2P win two rounds?
	jp   z, .win2P		; If so, jump
	
	; Otherwise, start a new round.
	jp   .startNewRound
	
.team:
	;
	; TEAM MODE
	; 
	; The team with at least 3 losses or with no characters left loses.
	;
	
	; Check if the player with the largest amount of losses has iPlInfo_TeamLossCount >= $03.
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamLossCount]	; A = 1P Loss count
	ld   hl, wPlInfo_Pl2+iPlInfo_TeamLossCount	; HL = Ptr to 2P Loss count
	cp   a, [hl]		
	jp   z, .teamLossEq		; Do they match? If so, jump
	jp   nc, .chkLossCnt1P	; 1P >= 2P? If so, jump
.chkLossCnt2P:				; Otherwise 1P < 2P. Check for 2P losses.
	ld   a, [wPlInfo_Pl2+iPlInfo_TeamLossCount]
	cp   $03				; Did 2P lose at least 3 times?
	jp   nc, .win1P			; If so, 1P won
	jp   .chkBossLoss		; Otherwise, check if any team is completely defeated
.chkLossCnt1P:
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamLossCount]
	cp   $03				; Did 1P lose at least 3 times?
	jp   nc, .win2P			; If so, 2P won
	jp   .chkBossLoss		; Otherwise, check if any team is completely defeated
.teamLossEq:
	; These involve the FINAL!! round, and must be checked for to avoid getting into
	; .chkBossLoss with > $03 dead chars.
	
	; If we've finished the final round, skip this as a shortcut
	cp   $04					; Do both players have 4 losses set?
	jp   z, .chkFinalRoundRes	; If so, jump (show "DRAW" screen)
	
	; If we're stepping into the FINAL!! round, force start it.
	cp   $03					; Do both players have 3 losses set?
	jp   z, .startNewRound		; If so, start the FINAL!! round
	
.chkBossLoss:
	
	;
	; Even though we checked if a team lost by having >= $03 defeated characters,
	; it's not always possible to rely on it.
	; Some "teams" (bosses and extra characters) go alone, and technically it's possible
	; to have a 2-character team. Those teams can never pass the "3 losses" checks for obvious reasons.
	;
	;
	; To deal with those, check if the new active character points to an CHAR_ID_NONE entry,	;
	; as these teams have that value as "padding" in place of the missing characters.
	;
	
	;
	; Index the teams by loss count to get the active character. The indexed result may
	; be a real character ID, or an CHAR_ID_NONE entry if the boss team is defeated.
	; There's no bounds checking -- this code should never be called when a player has 3+ losses.
	; (.teamLossEq and chkLossCnt*P should handle the >= 3 loss count before execution gets here)
	;
	
	; B = Active char for 2P side
	ld   a, [wPlInfo_Pl2+iPlInfo_TeamLossCount]	; A = Loss count
	ld   hl, wPlInfo_Pl2+iPlInfo_TeamCharId0	; HL = Ptr to 2P team
	ld   d, $00		; DE = Index
	ld   e, a
	add  hl, de		; Index the team tbl
	ld   a, [hl]	; A = Active Char ID
	ld   b, a		; Move to B
	
	; A = Active char for 1P side
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamLossCount]
	ld   hl, wPlInfo_Pl1+iPlInfo_TeamCharId0
	ld   d, $00
	ld   e, a
	add  hl, de
	ld   a, [hl]
	
	;--
	; [POI] This check is here to switch to the FINAL!! round when both teams are
	;       made of < 3 characters, which can happen in the extra stage on 1-VS-2 matches.
	cp   a, b					; New1PChar == New2PChar?
	jp   z, .chkBossFinal		; If so, jump
	;--
	; If 1P's character is pointing to the NONE entry, 2P wins
	cp   CHAR_ID_NONE	; New1PChar == CHAR_ID_NONE?
	jp   z, .win2P		; If so, jump
	; If 2P's character is pointing to the NONE entry, 1P wins
	ld   a, b			; A = New2PChar
	cp   CHAR_ID_NONE	; New2PChar == CHAR_ID_NONE?
	jp   z, .win1P		; If so, jump
	jp   .startNewRound
.chkBossFinal:
	;--
	; See [POI] above
	cp   CHAR_ID_NONE			; New1PChar == New2PChar == CHAR_ID_NONE?
	jp   z, .chkFinalRoundRes	; If so, trigger the FINAL!! round
	;--
	jp   .startNewRound
.startNewRound:
	call Play_PrepForWinScreen
	jp   Module_Play
	
.chkFinalRoundRes:
	;
	; FINAL ROUND CHECK
	;
	; After the FINAL!! round is over, there's no starting a new round.
	; The stage forcefully ends, and the win screen code decides how to handle it.
	; 
	xor  a
	ld   [wStageDraw], a
	
	;
	; Because there is no stage progression in VS mode, the win screen
	; is handled differently and there's no need for wStageDraw.
	;
	ld   a, [wPlayMode]
	bit  MODEB_VS, a		; Playing a VS battle?	
	jp   nz, .endStage		; If so, jump
	
	;
	; If anyone won the FINAL!! round, the stage can end as normal
	;
	ld   a, [wLastWinner]
	or   a					; Is 2P the winner?
	jp   nz, .endStage		; If so, jump
	
	;
	; Otherwise, show the DRAW screen.
	;
	; As this is single mode, we also need to fake the wLastWinner data to make
	; the game think the CPU opponent won. This will cause the continue prompt to show up
	; instead of the game continuing anyway to the next stage.
	;
	; yep.
	;
	ld   a, $01				; Show DRAW screen
	ld   [wStageDraw], a
	
	; Make the CPU opponent win
	ld   a, [wJoyActivePl]
	or   a					; wJoyActivePl == PL1? (2P is opponent)
	jp   z, .win2P			; If so, 2P won
.win1P:						; Otherwise, 1P won
	;--
	;
	; 1P won the stage.
	;
	
	; Restore the original iPlInfo_TeamLossCount value from the start of the round.
	; Most of the time we get here, this value doesn't need to be changed... unless
	; there was a draw that caused the stage to end (ie: when 1P Char 1 vs 2P Char 3 ends in draw)
	; due to the $03 loss limit.
	; That will still increase iPlInfo_TeamLossCount to both players, so we must decrement it back.
	
	ld   hl, wPlInfo_Pl1+iPlInfo_TeamLossCount
	ld   a, [wLastWinner]
	or   a					; Was there a winner in this round? (can only be 1P)
	jp   nz, .win1P_capId	; If so, skip
	dec  [hl]				; Otherwise, iPlInfo_TeamLossCount--
	
.win1P_capId:
	; Cap iPlInfo_TeamLossCount to the last valid value for indexing.
	; This only has an effect if the FINAL!! round ends in a draw.
	ld   a, [hl]
	cp   $03				; iPlInfo_TeamLossCount == $03
	jp   nz, .win1P_setLast	; If not, jump
	ld   [hl], $02			; Otherwise, cap to $02
.win1P_setLast:
	; Set 1P as the last winner.
	; This is what determines if the stage sequence should continue or not,
	; even in case of the "DRAW" screen showing up.
	ld   hl, wLastWinner
	set  PLB1, [hl]
	res  PLB2, [hl]
	jp   .endStage
.win2P:
	;--
	;
	; 2P won the stage.
	;
	ld   hl, wPlInfo_Pl2+iPlInfo_TeamLossCount
	ld   a, [wLastWinner]
	or   a
	jp   nz, .win2P_capId
	dec  [hl]
.win2P_capId:
	ld   a, [hl]
	cp   $03
	jp   nz, .win2P_setLast
	ld   [hl], $02
.win2P_setLast:
	ld   hl, wLastWinner
	res  PLB1, [hl]
	set  PLB2, [hl]
	jp   .endStage
	;--
.endStage:
	; Stop SGB SFX
	ld   hl, (SGB_SND_B_STOP << 8)|$00
	call SGB_PrepareSoundPacketB
	call Task_PassControlFar
	
	; Cleanup the screen
	call Play_PrepForWinScreen
	
	; Initialize the win screen
	ld   b, BANK(Module_Win) ; BANK $1D
	ld   hl, Module_Win
	rst  $00
Play_ChkEnd_Ret:
	ret
	ret ; We never get here
; =============== Play_SetWinLoseMoves ===============
; Sets the win and lose moves to the specified players.
; This shouldn't be called when there are no winning players (ie: a draw).
; IN
; - BC: Ptr to winner wPlInfo
; - DE: Ptr to loser wPlInfo
Play_SetWinLoseMoves:
	;
	; Additionally...
	; In team mode, the winner recovers health between rounds.
	;
	call IsInTeamMode		; Are we in team mode?
	jp   nc, .chkWinMove	; If not, skip
	
	; The health recovered is 4 + (wRoundTime / 10).
	ld   a, [wRoundTime]
	srl  a				; A = A / 10
	srl  a
	srl  a
	srl  a
	add  a, $04			; + 4
	ld   h, a			; Save it to H
	
	; A = Current health
	push hl
		ld   hl, iPlInfo_Health
		add  hl, bc				; Seek to iPlInfo_Health
		ld   a, [hl]
	pop  hl
	
	; Add the health over, capping it at the standard value
	add  a, h				; iPlInfo_Health += H
	cp   $48				; Is it still < $48?
	jp   c, .saveHealthInc	; If so, jump
	ld   a, $48				; Otherwise, cap it
.saveHealthInc:
	; Save the new health value
	ld   hl, iPlInfo_Health
	add  hl, bc				; Seek to iPlInfo_Health
	ld   [hl], a			; Save new value
	
	
.chkWinMove:
	;
	; WINNING PLAYER -> Set the win move.
	; If we've won 2 or more rounds in a row, use the alternate one.
	;
	ld   hl, iPlInfo_RoundWinStreak
	add  hl, bc
	ld   a, [hl]			; A = iPlInfo_RoundWinStreak 
	cp   $02				; iPlInfo_RoundWinStreak >= $02?
	jr   nc, .winAlt		; If so, jump
.winNorm:
	ld   a, MOVE_SHARED_WIN_A	; A = Move ID to use
	jr   .setWinMove
.winAlt:
	ld   a, MOVE_SHARED_WIN_B		; A = Move ID to use
.setWinMove:
	ld   hl, iPlInfo_IntroMoveId
	add  hl, bc				; Seek to iPlInfo_IntroMoveId
	ld   [hl], a			; Save it here
	

.chkLoseMove:
	;
	; LOSING PLAYER -> Set the lose move if possible.
	; This is only applicable with time overs -- as otherwise the
	; opponent stays dead on the ground.
	;
	ld   hl, iPlInfo_Health
	add  hl, de
	ld   a, [hl]			; A = iPlInfo_Health
	or   a					; iPlInfo_Health != 0?
	jr   nz, .loseTimeOver	; If so, jump
.loseNorm:
	; Otherwise, set a dummy value which gets ignored since the player tasks
	; for dead players get destroyed.
	; This really could have returned instead of setting this.
	ld   a, MOVE_FF						; A = Move ID to use
	jr   .setLoseMove
.loseTimeOver:
	ld   a, MOVE_SHARED_LOST_TIMEOVER	; A = Move ID to use
.setLoseMove:
	ld   hl, iPlInfo_IntroMoveId
	add  hl, de		; Seek to iPlInfo_IntroMoveId
	ld   [hl], a	; Save it here
	ret
	
; =============== Play_SetDrawMoves ===============
; Sets the move for draws to both players
Play_SetDrawMoves:
	;
	; BOTH PLAYERS -> Set the lose move *if* possible.
	; This is because it has to handle Double KOs as well, and with
	; those both players lie dead on the ground.
	;
	
	; Since both players have the same health, checking 1P is enough.
	ld   a, [wPlInfo_Pl1+iPlInfo_Health]
	or   a					; iPlInfo_Health == 0?
	jr   z, .doubleKo		; If so, it's a double KO (set dummy move)
.timeOver:					; Otherwise, set a real move
	ld   a, MOVE_SHARED_LOST_TIMEOVER
	jr   .setMove
.doubleKo:
	ld   a, MOVE_FF
.setMove:
	ld   [wPlInfo_Pl1+iPlInfo_IntroMoveId], a
	ld   [wPlInfo_Pl2+iPlInfo_IntroMoveId], a
	ret
	
; =============== Play_PrepForWinScreen ===============
; Performs cleanup before switching to the win screen.
Play_PrepForWinScreen:
	; Blank all DMG palettes
	ld   a, $FF
	ldh  [rBGP], a
	ldh  [rOBP0], a
	ldh  [rOBP1], a
	ldh  [hScreenSect0BGP], a
	ldh  [hScreenSect1BGP], a
	ldh  [hScreenSect2BGP], a
	
	; Stop all GFX buffers
	xor  a
	ld   [wGFXBufInfo_Pl1+iGFXBufInfo_TilesLeftA], a
	ld   [wGFXBufInfo_Pl1+iGFXBufInfo_TilesLeftB], a
	ld   [wGFXBufInfo_Pl2+iGFXBufInfo_TilesLeftA], a
	ld   [wGFXBufInfo_Pl2+iGFXBufInfo_TilesLeftB], a
	call Task_PassControlFar
	
	; Reset screen scroll
	xor  a
	ldh  [rWY], a
	ldh  [rWX], a
	ldh  [rSTAT], a
	
	; Disable range check since we'll be outside gameplay
	ld   hl, wMisc_C028
	res  MISCB_PL_RANGE_CHECK, [hl]
	
	; Disable screen sections (for now, they'll get re-enabled later if not on draw)
	call DisableSectLYC
	
	; Remove the two player tasks
	ld   a, $02
	call Task_RemoveAt
	ld   a, $03
	call Task_RemoveAt
	
	; stop GFX loader
	xor  a
	ld   [wGFXBufInfo_Pl1+iGFXBufInfo_TilesLeftA], a
	ld   [wGFXBufInfo_Pl1+iGFXBufInfo_TilesLeftB], a
	ld   [wGFXBufInfo_Pl2+iGFXBufInfo_TilesLeftA], a
	ld   [wGFXBufInfo_Pl2+iGFXBufInfo_TilesLeftB], a
	call Task_PassControlFar
	
	ret
; =============== Play_LoadPostRoundText0 ===============
; Loads the sprite mappings + graphics for the first set of post-round text.
; See also: Play_LoadPreRoundTextAndIncRound
Play_LoadPostRoundText0:

	;
	; Wait for the players / objects to be ready before finishing the round.
	; This is the state the game is in after defeating an opponent / timer runs out
	; before the WIN/LOST/DRAW text appears.
	;
	; IMPORTANT: There's no timeout implemented, so if players or projectiles
	;            get "stuck", the game softlocks.
	;

	; Execute once a cut down version of the gameplay loop without the joypad reader.
	ld   b, $01
	call Play_MainLoop_PostRoundTextNoDisplay
	
.chkWait1P:
	; Players must be either in the idle move (winner/draw) or have no move (lost).
	; This is to allow any currently executing move to finish.
	ld   a, [wPlInfo_Pl1+iPlInfo_MoveId]
	cp   MOVE_SHARED_NONE		; MoveId == 0?
	jr   z, .chkWait2P			; If so, jump
	cp   MOVE_SHARED_IDLE		; MoveId == 2?
	jr   nz, Play_LoadPostRoundText0	; If not, wait again
.chkWait2P:
	ld   a, [wPlInfo_Pl2+iPlInfo_MoveId]
	cp   MOVE_SHARED_NONE		; MoveId == 0?
	jr   z, .chkWaitEx			; If so, jump
	cp   MOVE_SHARED_IDLE		; MoveId == 2?
	jr   nz, Play_LoadPostRoundText0	; If not, wait again
.chkWaitEx:

	; Also wait for the extra sprites to become invisible, as their
	; graphics are getting overwritten with new ones.
	xor  a
	; Merge the status bits of all OBJinfo
	ld   hl, wOBJInfo_Pl1Projectile+iOBJInfo_Status
	or   a, [hl]
	ld   hl, wOBJInfo_Pl2Projectile+iOBJInfo_Status
	or   a, [hl]
	ld   hl, wOBJInfo_Pl1SuperSparkle+iOBJInfo_Status
	or   a, [hl]
	ld   hl, wOBJInfo_Pl2SuperSparkle+iOBJInfo_Status
	or   a, [hl]
	and  a, OST_VISIBLE				; Are any of these visible?
	jr   nz, Play_LoadPostRoundText0		; If so, wait again
	
	; Wait for 2 more frames
	ld   b, $02
	call Play_MainLoop_PostRoundTextNoDisplay
	
.loadGFX:

	;
	; Load the full set of post-round graphics to the LZSS buffer.
	; For now, only copy the "KO" and cross sprite graphics to VRAM (tiles $00-$2E)
	;
	
	; Do not update the GFX buffers while this is done.
	; There's no reason for doing this though, and it causes a slight
	ld   a, $01
	ld   [wNoCopyGFXBuf], a
	call Task_PassControlFar
	; Decompress to the temporary buffer
	ld   hl, GFXLZ_Play_PostRoundText
	ld   de, wLZSS_Buffer+$1E
	call DecompressLZSS
	; Unpause and wait
	ld   a, $00
	ld   [wNoCopyGFXBuf], a
	call Task_PassControlFar
	ld   b, $01
	call Play_MainLoop_PostRoundTextNoDisplay
	
	; Copy the first set of graphics over during HBlank
	ld   hl, wLZSS_Buffer+$1E	; HL = Source ptr
	ld   de, $8800				; DE = Destination ptr
	ld   b, $2E					; B = Tile count
	call Play_CopyPostRoundGFXToVRAM
	
	;
	; Load the OBJInfo for the round text, with the sprite mapping
	; table for the KO text.
	;
	
	ld   hl, wOBJInfo_RoundText+iOBJInfo_Status
	ld   de, OBJInfoInit_Play_RoundText
	call OBJLstS_InitFrom
	ld   hl, wOBJInfo_RoundText+iOBJInfo_OBJLstPtrTbl_Low
	ld   [hl], LOW(OBJLstPtrTable_PostRoundTextA)
	inc  hl
	ld   [hl], HIGH(OBJLstPtrTable_PostRoundTextA)
	ld   b, $01
	call Play_MainLoop_PostRoundTextNoDisplay
	
	;
	; Load the OBJInfo for both crosses.
	; These mark the newly defeated character(s) in team mode.
	; Usually only one ends up being visible, but draws and time overs can cause both to show up.
	;
	
	; Over 2P's side
	ld   hl, wOBJInfo_Pl2Cross+iOBJInfo_Status
	ld   de, OBJInfoInit_Play_CharCross
	call OBJLstS_InitFrom
	ld   b, $01
	call Play_MainLoop_PostRoundTextNoDisplay
	
	; Over 1P's side
	ld   hl, wOBJInfo_Pl1Cross+iOBJInfo_Status
	ld   de, OBJInfoInit_Play_CharCross
	call OBJLstS_InitFrom
	ld   b, $01
	call Play_MainLoop_PostRoundTextNoDisplay
	
	ret
	
; =============== Play_CopyPostRoundGFXToVRAM ===============
; Copies the specified block of graphics to VRAM, during HBlank.
; This is used specifically for the "post round text" (ie: KO, YOU WON, ...)
; IN
; - HL: Ptr to source uncompressed GFX
; - DE: Ptr to destination in VRAM
; - B: Tiles to copy from HL ($10*B bytes)
Play_CopyPostRoundGFXToVRAM:
	push bc
		; Copy a tile at a time every frame
		ld   b, TILESIZE	; B = Bytes to copy ($10)
	.loop:
		di
		mWaitForVBlankOrHBlank
		ldi  a, [hl]		; Read from source, SrcPtr++
		ld   [de], a		; Copy it to destination
		ei
		inc  de				; DestPtr++
		dec  b				; Copied the tile?
		jr   nz, .loop		; If not, loop
		push de
			push hl
				ld   b, $01
				call Play_MainLoop_PostRoundTextNoDisplay
			pop  hl
		pop  de
	pop  bc
	dec  b									; Finished copying all tiles?
	jr   nz, Play_CopyPostRoundGFXToVRAM	; If not, loop
	ret
	
; =============== Play_DoTimeOverText ===============
; Handles the TIME OVER text display while the characters continue their animations.
Play_DoTimeOverText:
	ld   hl, wOBJInfo_RoundText+iOBJInfo_OBJLstPtrTblOffset
	ld   [hl], PLAY_POSTROUND0_OBJ_TIMEOVER
	jp   Play_DoPostRoundText0
	
; =============== Play_DoKOText ===============
; Handles the KO text display while the characters continue their animations.
Play_DoKOText:
	ld   hl, wOBJInfo_RoundText+iOBJInfo_OBJLstPtrTblOffset
	ld   [hl], PLAY_POSTROUND0_OBJ_KO
	
; =============== Play_DoPostRoundText0 ===============
; Displays text for the first set of post-round text.
; Whem it's finished, it loads the data for the second set.
Play_DoPostRoundText0:

	; Display the text horizontally centered...
	ld   hl, wOBJInfo_RoundText+iOBJInfo_Status
	set  OSTB_VISIBLE, [hl]
	call Play_CenterRoundText
	call Task_PassControlFar
	; ...for $78 frames
	ld   b, $78
	call Play_MainLoop_PostRoundTextDisplay
	
	; Then disable it again
	ld   hl, wOBJInfo_RoundText+iOBJInfo_Status
	res  OSTB_VISIBLE, [hl]
	
	
	;
	; Make the OBJInfo point to the second set of sprite mappings.
	;
	ld   hl, wOBJInfo_RoundText+iOBJInfo_OBJLstPtrTbl_Low
	ld   [hl], LOW(OBJLstPtrTable_PostRoundTextB)
	inc  hl
	ld   [hl], HIGH(OBJLstPtrTable_PostRoundTextB)
	
	;
	; Load to VRAM the second set of text from the buffer, which contains GFX for "YOU WIN", ...
	; This starts right after the end of the previous set 
	; (hence the $2E*TILESIZE, with $2E being the tile count for last time)
	;
	
	; Note this is copied from $8880 instead of $8800, as the first 8 tiles (ie: cross gfx) 
	; should be left untouched.
	ld   hl, (wLZSS_Buffer+$1E)+($2E*TILESIZE); HL = Source ptr
	ld   de, $8880						; DE = Destination ptr
	ld   b, $36 						; B = Tiles to copy
	call Play_CopyPostRoundGFXToVRAM
	ret
	
; =============== Play_Set1PWin ===============
; Sets 1P as the winner of the current round.
; This updates all of the needed variables across the two players and
; handles the text display.
Play_Set1PWin:

	;
	; Update win streaks (shared across modes)
	;
	ld   hl, wPlInfo_Pl1+iPlInfo_RoundWinStreak
	inc  [hl]		; 1P won, RoundWinStreak++
	ld   hl, wPlInfo_Pl2+iPlInfo_RoundWinStreak
	ld   [hl], $00	; 2P lost, resetting the streak
	
	;
	; The "win counters" are handled differently in single and team mode.
	;
	call IsInTeamMode	; In team mode?
	jp   c, .team		; If so, jump
.single:
	; 
	; SINGLE MODE
	; In single mode, iPlInfo_SingleWinCount is incremented
	; and a round marker is filled on the winner side.
	;
	ld   hl, wPlInfo_Pl1+iPlInfo_SingleWinCount
	inc  [hl]		; 1P Win Count++
	
	; Determine which of the two markers/boxes in the HUD to draw.
	ld   a, [hl]		; Read counter
	cp   $02			; Is this the second win?
	jp   z, .boxWin2	; If so, jump
.boxWin1:
	ld   hl, $9C42		; Leftmost box for first win
	jp   .drawBox
.boxWin2:
	ld   hl, $9C43		; The one on its right for the second
.drawBox:
	ld   c, $74			; C = Tile ID for filled box
	call CopyByteIfNotSingleFinalRound
	jp   .chkTextType
	
.team:
	; 
	; TEAM MODE
	; In team mode, the loss counter on the losing team is incremented,
	; and its cross is made visible.
	;
	ld   hl, wPlInfo_Pl2+iPlInfo_TeamLossCount
	inc  [hl]	; 2P Loss Count++
	
	; Set the base position for the cross.
	; Because the active character is always on the front, it has a fixed position.
	ld   a, [wOBJScrollX]
	add  a, $98
	ld   [wOBJInfo_Pl2Cross+iOBJInfo_X], a
	; Display the cross
	ld   hl, wOBJInfo_Pl2Cross+iOBJInfo_Status
	ld   [hl], $80
	
.chkTextType:
	;
	; Determine which text to display.
	;
	
	ld   a, [wPlayMode]
	bit  MODEB_VS, a	; Playing in VS mode?
	jp   nz, .chkVS		; If so, jump
.chkSingle:
	
	; In single mode, if the CPU opponent wins, "YOU LOST".
	; Otherwise we win.
	
	ld   a, [wJoyActivePl]
	or   a				; Is 1P the active player? (not CPU opponent)
	jp   z, .won		; If so, we won
	jp   .lost			; Otherwise, the CPU opponent is on the 1P side.
.chkVS:
	ld   a, [wMisc_C025]
	bit  MISCB_IS_SGB, a	; Running on the SGB?
	jp   z, .chkVS_serial	; If not, jump
	jp   .chkVS_sgb
.chkVS_serial:
	; On a VS serial battle, show "YOU WIN" on the master side (as it's always 1P)
	ld   a, [wMisc_C025]
	bit  MISCB_SERIAL_SLAVE, a	; Are we a slave?
	jr   nz, .vsSerialLost		; If not, we lost
	jp   .won
.vsSerialLost:
	jp   .lost
.lost:
	ld   a, PLAY_POSTROUND1_OBJ_YOULOST
	jp   .showText
.won:
	ld   a, PLAY_POSTROUND1_OBJ_YOUWON
	jp   .showText
.chkVS_sgb:
	; On a SGB VS battle, explicitly say that 1P won (since there's a single screen).
	ld   a, PLAY_POSTROUND1_OBJ_1PWON
	jp   .showText
.chkVS_sgb_unused:
	; [TCRF] Unreachable code "leftover" from Play_Set2PWin.
	ld   a, PLAY_POSTROUND1_OBJ_2PWON
.showText:
	ld   bc, wPlInfo_Pl1
	call Play_DoPostRoundText1PreWin
	
	; Set only 1P as last winner
	ld   hl, wLastWinner
	set  PLB1, [hl]
	res  PLB2, [hl]
	ret
	
; =============== Play_Set2PWin ===============
; Sets 2P as the winner of the current round.
; This updates all of the needed variables across the two players and
; handles the text display.
; See also: Play_Set1PWin
Play_Set2PWin:

	;
	; Update win streaks (shared across modes)
	;
	ld   hl, wPlInfo_Pl2+iPlInfo_RoundWinStreak
	inc  [hl]		; 2P won, RoundWinStreak++
	ld   hl, wPlInfo_Pl1+iPlInfo_RoundWinStreak
	ld   [hl], $00	; 1P lost, resetting the streak
	
	;
	; The "win counters" are handled differently in single and team mode.
	;
	call IsInTeamMode	; In team mode?
	jp   c, .team		; If so, jump
.single:
	; 
	; SINGLE MODE
	; In single mode, iPlInfo_SingleWinCount is incremented
	; and a round marker is filled on the winner side.
	;
	ld   hl, wPlInfo_Pl2+iPlInfo_SingleWinCount
	inc  [hl]		; 2P Win Count++
	
	; Determine which of the two markers/boxes in the HUD to draw.
	ld   a, [hl]		; Read counter
	cp   $02			; Is this the second win?
	jp   z, .boxWin2	; If so, jump
.boxWin1:
	ld   hl, $9C51		; Leftmost box for first win
	jp   .drawBox
.boxWin2:
	ld   hl, $9C50		; The one on its right for the second
.drawBox:
	ld   c, $74			; C = Tile ID for filled box
	call CopyByteIfNotSingleFinalRound
	jp   .chkTextType
	
.team:
	; 
	; TEAM MODE
	; In team mode, the loss counter on the losing team is incremented,
	; and its cross is made visible.
	;
	ld   hl, wPlInfo_Pl1+iPlInfo_TeamLossCount
	inc  [hl]	; 1P Loss Count++
	
	; Set the base position for the cross.
	; Because the active character is always on the front, it has a fixed position.
	ld   a, [wOBJScrollX]
	add  a, $08
	ld   [wOBJInfo_Pl1Cross+iOBJInfo_X], a
	; Display the cross
	ld   hl, wOBJInfo_Pl1Cross+iOBJInfo_Status
	ld   [hl], $80
	
.chkTextType:
	;
	; Determine which text to display.
	;
	
	ld   a, [wPlayMode]
	bit  MODEB_VS, a	; Playing in VS mode?
	jp   nz, .chkVS		; If so, jump
.chkSingle:
	; In single mode, if the CPU opponent wins, "YOU LOST".
	; Otherwise we win.
	
	ld   a, [wJoyActivePl]
	or   a				; Is 2P the active player? (not CPU opponent)
	jp   nz, .won		; If so, we won
	jp   .lost			; Otherwise, the CPU opponent is on the 2P side.
.chkVS:
	ld   a, [wMisc_C025]
	bit  MISCB_IS_SGB, a	; Running on the SGB?
	jp   z, .chkVS_serial	; If not, jump
	jp   .chkVS_sgb
.chkVS_serial:
	; On a VS serial battle, show "YOU WIN" on the slave side (as it's always 2P)
	ld   a, [wMisc_C025]
	bit  MISCB_SERIAL_SLAVE, a	; Are we a slave?
	jr   nz, .vsSerialWon		; If so, we won
	jp   .lost
.vsSerialWon:
	jp   .won
.lost:
	ld   a, PLAY_POSTROUND1_OBJ_YOULOST
	jp   .showText
.won:
	ld   a, PLAY_POSTROUND1_OBJ_YOUWON
	jp   .showText
.chkVS_sgb_unused:
	; [TCRF] Unreachable code "leftover" from Play_Set1PWin
	ld   a, PLAY_POSTROUND1_OBJ_1PWON
	jp   .showText
.chkVS_sgb:
	; On a SGB VS battle, explicitly say that 2P won (since there's a single screen).
	ld   a, PLAY_POSTROUND1_OBJ_2PWON
.showText:
	ld   bc, wPlInfo_Pl2
	call Play_DoPostRoundText1PreWin
	
	; Set only 2P as last winner
	ld   hl, wLastWinner
	res  PLB1, [hl]
	set  PLB2, [hl]
	ret
	
; =============== Play_DoPostRoundText1PreWin ===============
; Displays the post-round text for a second.
; Note that this doesn't start the win pose -- that's set elsewhere
; and has to wait for this to return first.
; IN
; - A: Sprite mapping ID for the text (PLAY_POSTROUND0_OBJ_*)
; - BC: Ptr to wPlInfo
Play_DoPostRoundText1PreWin:
	; Display the text
	ld   hl, wOBJInfo_RoundText+iOBJInfo_Status
	ld   [hl], OST_VISIBLE
	; Set the sprite mapping ID
	ld   [wOBJInfo_RoundText+iOBJInfo_OBJLstPtrTblOffset], a
	; Center it and update the display
	call Play_CenterRoundText
	call Task_PassControlFar
	
	; Display the text for one second
	ld   b, 60
	call Play_MainLoop_PostRoundTextDisplay
	ret

; =============== Play_SetDraw ===============
; Sets the round result as a Draw, making both players lose.
; This updates all of the needed variables across the two players and
; handles the text display.
Play_SetDraw:
	; Reset all win streaks
	ld   hl, wPlInfo_Pl1+iPlInfo_RoundWinStreak
	ld   [hl], $00
	ld   hl, wPlInfo_Pl2+iPlInfo_RoundWinStreak
	ld   [hl], $00
	
	; There's no last winner
	ld   hl, wLastWinner
	res  PLB1, [hl]
	res  PLB2, [hl]
	
	;
	; If we're in team mode, set its specific variables and the cross sprites over the active icons.
	; There's no box filling with single mode here.
	;
	call IsInTeamMode	; Are we in team mode?
	jp   nc, .setText	; If not, skip
	
	; Both players lost
	ld   hl, wPlInfo_Pl1+iPlInfo_TeamLossCount
	inc  [hl]
	ld   hl, wPlInfo_Pl2+iPlInfo_TeamLossCount
	inc  [hl]
	
	; Draw both cross sprites as long as we didn't *reach* the FINAL!! round just now.
	; In other words, if both loss counts have been incremented to $03, don't draw
	; the crosses as there's a final round with the same active characters.
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamLossCount]	; A = 1P loss count
	ld   hl, wPlInfo_Pl2+iPlInfo_TeamLossCount	; HL = Ptr to 2P loss count
	cp   a, [hl]		; Are they the same value?
	jp   nz, .setCross	; If not, draw the crosses
	cp   $03			; Are they both 3?
	jp   z, .setText	; If so, skip
.setCross:
	; Set 2P side cross position
	ld   a, [wOBJScrollX]
	add  a, $98
	ld   [wOBJInfo_Pl2Cross+iOBJInfo_X], a
	; Set 1P side cross position
	ld   a, [wOBJScrollX]
	add  a, $08
	ld   [wOBJInfo_Pl1Cross+iOBJInfo_X], a
	; Display the cross for both characters
	ld   hl, wOBJInfo_Pl2Cross+iOBJInfo_Status
	ld   [hl], OST_VISIBLE
	ld   hl, wOBJInfo_Pl1Cross+iOBJInfo_Status
	ld   [hl], OST_VISIBLE
.setText:
	; Display the round text centered
	ld   hl, wOBJInfo_RoundText+iOBJInfo_Status
	ld   [hl], OST_VISIBLE
	call Play_CenterRoundText
	
	ld   a, PLAY_POSTROUND1_OBJ_DRAWGAME
	
	;--
	; why
	jp   .setOBJ
.setOBJ:
	;--

	ld   [wOBJInfo_RoundText+iOBJInfo_OBJLstPtrTblOffset], a
	call Task_PassControlFar
	
	; Display text for a second
	; After exiting, other code will set the draw pose to both players
	ld   b, 60
	call Play_MainLoop_PostRoundTextDisplay
	ret
; =============== Play_MainLoop_PostRoundTextNoDisplay ===============
; Version of the main loop used post-round when the text isn't visible.
; IN
; - B: Frames of execution (usually short)
Play_MainLoop_PostRoundTextNoDisplay:
	push bc
		call Play_DoPlInput
		call Play_DoHUD
		call Play_DoMisc
		call Play_DoPlColi
		call Play_WriteKeysToBuffer
		call Play_DoScrollPos
		call Play_ExecExOBJCode
		call Task_PassControlFar
	pop  bc
	dec  b											; Done all frames?	
	jp   nz, Play_MainLoop_PostRoundTextNoDisplay	; If not, loop
	ret
; =============== Play_MainLoop_PostRoundTextDisplay ===============
; Version of the main loop used when displaying post-round text.
; IN
; - B: Frames of execution (at least 1 sec)
Play_MainLoop_PostRoundTextDisplay:
	push bc
		; It's possible to end the loop prematurely if a player presses any of the non-directional keys.
		ldh  a, [hJoyNewKeys]						; A = 1P inputs
		ld   hl, hJoyNewKeys2						; HL = Ptr to 2P inputs
		or   a, [hl]								; Merge 1P & 2P inputs
		and  a, KEY_A|KEY_B|KEY_SELECT|KEY_START	; Pressing any of these keys?
		jp   nz, .abort								; If so, we're done
		
		; Flash the round text here
		call Play_AnimTextPal
		
		; Standard calls
		call Play_DoPlInput
		call Play_DoHUD
		call Play_DoMisc
		call Play_DoPlColi
		call Play_WriteKeysToBuffer
		call Play_DoScrollPos
		call Play_ExecExOBJCode
		call Task_PassControlFar
		
	pop  bc
	dec  b										; Executed this for all frames?
	jp   nz, Play_MainLoop_PostRoundTextDisplay	; If not, loop
	ret
.abort:;J
	pop  bc
	ret
	
; =============== Play_AnimTextPal ===============
; Flashes the palette for the three extra sprites at wOBJInfo3-wOBJInfo5, used for the text.
Play_AnimTextPal:
	ld   hl, wOBJInfo_RoundText+iOBJInfo_Status		; HL = Initial wOBJInfo
	ld   b, $03			; B = wOBJInfo to process
.loop:
	push hl
		bit  OSTB_VISIBLE, [hl]		; Is the sprite visible?
		jr   z, .nextOBJ			; If not, skip
		inc  hl
		
		; Every 4 frames, switch between OBP0 and OBP1.
		; This flashes the text color between the two shades of grays.
		ld   a, [wTimer]
		bit  2, a			; wTimer & $04 == 0?
		jp   nz, .obp1		; If not, jump
	.obp0:
		ld   [hl], SPR_OBP0
		jr   .nextOBJ
	.obp1:
		ld   [hl], SPR_OBP1
	.nextOBJ:
	
	pop  hl
	; Seek to the next OBJInfo
	ld   de, OBJINFO_SIZE	; HL += OBJINFO_SIZE
	add  hl, de
	dec  b					; Handled all wOBJInfo?
	jp   nz, .loop			; If not, loop
	ret
; =============== Play_CenterRoundText ===============
; Aligns the round text to the center of the screen.
Play_CenterRoundText:
	ld   a, [wOBJScrollX]
	add  a, SCREEN_H/2 ; Add half a screen
	ld   [wOBJInfo_RoundText+iOBJInfo_X], a
	ret
	
; =============== Play_DoScrollPos ===============
; Updates the screen scroll positions for playfield and sprites.
Play_DoScrollPos:

	;
	; HORIZONTAL SCROLLING
	;
	; Moving too close to the edge of the screen ($20px in practice) will cause the screen to scroll,
	; but if both players are far enough to trigger the opposite screen edges, there's special handling involved.
	;
	; Note that, while we're updating wOBJScrollX and the checks are performed there
	; this value will be directly copied to hScrollX.
	;
SCROLL_BORDER_H EQU $20
	
	;
	; If both players aren't far enough (distance < $60), a simple border check can be made.
	;
	; Note that $60 is the largest applicable value before the $20px border would kick in
	; on both sides. ($60 + $20*2 = SCREEN_H)
	;
	ld   a, [wPlInfo_Pl1+iPlInfo_PlDistance]
	cp   SCREEN_H-(SCROLL_BORDER_H*2)		; PlDistance < $60?
	jp   c, .chkNearX					; If so, jump
	
.chkFarX:
	;
	; Otherwise, the screen should be positioned so both players are
	; equally far to the edge of the screen, as long as the edge of the playfield isn't reached.
	;
	
	; Calculate the new target position.
	; This is the absolute "center point" between the two players, and the screen
	; should be positioned so the center of the screen points to that coordinate.
	; B = (X2 + X1) / 2
	ld   a, [wOBJInfo_Pl2+iOBJInfo_X]
	ld   b, a							; B = 2P X Pos
	ld   a, [wOBJInfo_Pl1+iOBJInfo_X]	; A = 1P X Pos
	srl  a		; A = A / 2
	srl  b		; B = B / 2
	add  b		; B += A
	ld   b, a
	
	; However, wOBJScrollX points to the left corner of the screen, not the center.
	; Additionally, checks are needed to prevent the camera from moving past the edge.
	; To satisfy those conditions the calculation will be done by .moveL and .moveR.
	;
	; Those subroutines though scroll the screen by a specified amount and don't accept
	; an absolute value. For this, convert the absolute value to relative (to the center of the screen):
	
	; Calculate absolute position currently at the center of the screen
	ld   a, [wOBJScrollX]	; A = Absolute left corner position
	add  a, SCREEN_H/2		; Add half a screen
	
	; The offset will be the distance between the center and target.
	; Add or remove it depending on whether it's on the left or right of the screen center.
	cp   a, b				
	jp   z, .setScrollX	; MidPoint == Target? If so, don't change anything
	jp   c, .moveFarR 	; MidPoint < Target? If so, move it right
.moveFarL:				; Otherwise, move it left
	; The target is on the left of the midpoint.
	; Move left by:
	; B = Target - MidPoint
	sub  a, b		; A = MidPoint - Target
	cpl				; Convert to negative
	inc  a
	ld   b, a
	
.moveL:
	;
	; Scroll the playfield left by B. Force it back to $00 if it underflows.
	;
	
	; wOBJScrollX = MAX(wOBJScrollX + B, 0)
	; B must be a negative value.
	ld   a, [wOBJScrollX]	; wOBJScrollX += B
	add  b
	ld   [wOBJScrollX], a
	bit  7, a				; wOBJScrollX < 0?
	jp   z, .setScrollX		; If so, jump
	ld   a, $00				; Otherwise, force it back to 0
	ld   [wOBJScrollX], a
	jp   .setScrollX
.moveFarR:
	; The target is on the right side of the screen.
	; Move right by:
	; B = Target - MidPoint
	sub  a, b		; A = MidPoint - Target
	cpl				; Convert to positive
	inc  a
	ld   b, a
.moveR:

	;
	; Scroll the playfield right by B. Force it back to $60 if it goes past that.
	;
	
	; As wOBJScrollX/hScrollX point to the left corner of the screen,
	; subtracting the screen width from the tilemap width will give the max value as $60.
	
	; wOBJScrollX = MIN(wOBJScrollX + B, $60)
	ld   a, [wOBJScrollX]
	add  b
	ld   [wOBJScrollX], a
	cp   TILEMAP_H-SCREEN_H	; $60
	jp   c, .setScrollX
	ld   a, TILEMAP_H-SCREEN_H ; $60
	ld   [wOBJScrollX], a
	jp   .setScrollX
.chkNearX:
	;
	; If any player is $20px (SCROLL_BORDER_H) near the edge of the screen, scroll it accordingly.
	; As the players are close to each other, no special checks are needed.
	;
	; However, the thresholds checked aren't directly $20px, since this is going off iOBJInfo_RelX.
	; That value is offset to the right by OBJ_OFFSET_X, and as a result: 
	;
SCROLL_THRESHOLD_L EQU SCROLL_BORDER_H+OBJ_OFFSET_X
SCROLL_THRESHOLD_R EQU SCREEN_H-(SCROLL_BORDER_H-OBJ_OFFSET_X)
	
	ld   a, [wOBJInfo_Pl1+iOBJInfo_RelX]
	cp   SCROLL_THRESHOLD_L			; iOBJInfo_RelX < $28?
	jp   c, .moveNearL				; If so, scroll left
	cp   SCROLL_THRESHOLD_R+1		; iOBJInfo_RelX >= $89? (> $88?)
	jp   nc, .moveNearR				; If so, scroll right
	; Same for 2P
	ld   a, [wOBJInfo_Pl2+iOBJInfo_RelX]
	cp   SCROLL_THRESHOLD_L
	jp   c, .moveNearL
	cp   SCROLL_THRESHOLD_R+1
	jp   nc, .moveNearR
	jp   .setScrollX
.moveNearL:
	; Scroll the screen left by how much the threshold was passed.
	; ie: if currently at position SCROLL_THRESHOLD_L-2, scroll left by 2px
	sub  a, SCROLL_THRESHOLD_L	; B = iOBJInfo_RelX - SCROLL_THRESHOLD_L
	ld   b, a
	jp   .moveL
.moveNearR:
	; Scroll the screen right by how much the threshold was passed, like in .moveNearL
	sub  a, SCROLL_THRESHOLD_R ; B = iOBJInfo_RelX - SCROLL_THRESHOLD_R
	ld   b, a
	jp   .moveR
.setScrollX:
	; Save the same result to the playfield scroll position
	ld   a, [wOBJScrollX]
	ldh  [hScrollX], a
	
.doY:
	;
	; VERTICAL SCROLLING
	;
	
	;
	; Calculate the base hScrollY position.
	;
	; On the floor, characters have the internal Y position $88 (PL_FLOOR_POS).
	; It will never be higher than that, and jumping decreases the value.
	;
	; As characters move jump up, the screen scrolls up slowly, so:
	;
	; hScrollY = -MAX((PL_FLOOR_POS - Y1) + (PL_FLOOR_POS - Y2)) / $10, 8)
	;
	; Note the negative sign.
	; When both characters stand on the floor, the Y scrolling is set up so
	; it's at coordinate 0, and jumping makes it underflow.
	; The tilemap of course accounts for this.
	;
	;
	
	; Get how much the 1P has jumped up
	; H = $88 - iOBJInfo_Y (1P)
	ld   a, [wOBJInfo_Pl1+iOBJInfo_Y]
	ld   b, a
	ld   a, PL_FLOOR_POS
	sub  a, b		
	ld   h, a
	; Get how much the 2P has jumped up
	; A = $88 - iOBJInfo_Y (2P)
	ld   a, [wOBJInfo_Pl2+iOBJInfo_Y]
	ld   b, a
	ld   a, PL_FLOOR_POS
	sub  a, b
	; Sum those together, so that if both players jump if makes it go even higher
	add  a, h
	; Slow down vertical movement as much as possible
	; A /= $10
	srl  a
	srl  a
	srl  a
	srl  a
	
	; Cap the result at 8.
	; This prevents scrolling the screen in a way that would make the characters
	; move below the bottom HUD, or scroll into the blank part of the tilemap.
	cp   $08			; A < $08?
	jp   c, .invY		; If so, jump
	ld   a, $08			; Otherwise, A = $08
.invY:
	; Invert the result since we're scrolling up from coord 0
	cpl		; A -= A
	inc  a
	; Save the result for now
	ldh  [hScrollY], a
	
	; The sprites are always have their origins least $40px from the bottom of the screen
	add  a, $40
	ld   [wOBJScrollY], a
	
	;
	; Screen shake support.
	;
	; If the optional offset is specified, add it exclusively to hScrollY without affecting sprites.
	; Note that the value is relative to the inverted version of hScrollY, so we must flip that back first.
	;
	ld   a, [wScreenShakeY]
	or   a					; wScreenShakeY == 0?
	jp   z, .ret			; If so, skip
	
	; Otherwise...
	; hScrollY = MIN(hScrollY - wScreenShakeY
	ld   b, a			; B = wScreenShakeY
	ldh  a, [hScrollY]	; A = -hScrollY
	cpl
	inc  a
	add  b				; A += B
	
	; Perform the same cap as above
	cp   $08			; A < $08?
	jp   c, .inv2Y		; If so, jump
	ld   a, $08			; Otherwise, A = $08
.inv2Y:
	cpl					; A = -A
	inc  a
	
	; Save the result
	ldh  [hScrollY], a
.ret:
	ret
	
; =============== Play_DoHUD ===============
; Updates the HUD and the related variables during gameplay.
; This includes decrementing the timer, as that's part of the subroutine
; that draws it to the HUD.
Play_DoHUD:
	call Play_UpdateHealthBars
	call Play_UpdatePowBars
	call Play_DoTime
	call Play_UpdateHUDHitCount
	ret
	
; =============== Play_UpdateHealthBars ===============
; Draws/updates the health bar display for both players.
;
; This subroutine keeps the visual health value (what's displayed in the health bar) 
; synched up with the actual health (the target).
;
; The health bar increases or decreases 1px/frame, until the target value is reached.
;
Play_UpdateHealthBars:


; =============== mDrawHealthBarTile ===============
; Generates the common code used to write to the health bar tilemap when flashing.
; IN
; - HL: Ptr to tilemap
; - B: Tile ID
mDrawHealthBarTile: MACRO
	push af
		di
		mWaitForVBlankOrHBlank
		ld   [hl], b
		ei
	pop  af
ENDM
	
	ld   a, [wPlInfo_Pl1+iPlInfo_Health]
	ld   b, a									; B = Target health
	ld   a, [wPlInfo_Pl1+iPlInfo_HealthVisual]	; A = Visual Health
	cp   a, b				; Do they match?
	; If they match, skip ahead.
	jp   z, .eqTarget1P		; Health == Target?
	; If the visual health is less than the target, increase the bar.
	jp   c, .ltTarget1P		; Health < Target?
	; Otherwise, Health > Target. Decrease the bar.
.gtTarget1P:
	; Bar decreases to the right
	ld   hl, vBGHealthBar1P					; HL = Ptr to start of health bar in tilemap
	ld   bc, Play_Bar_TileIdTbl_RGrow		; BC = Tile ID table (bytes 7-0)
	ld   de, Play_Bar_BGOffsetTbl_RGrow		; DE = Tilemap offset table
	
	; VisualHealth--
	ld   a, [wPlInfo_Pl1+iPlInfo_HealthVisual] ; (not necessary, already in A)
	dec  a
	ld   [wPlInfo_Pl1+iPlInfo_HealthVisual], a
	; Update health bar
	call Play_DrawBarTip
	jp   .eqTarget1P
	
.ltTarget1P:
	; Bar grows to the left
	ld   hl, vBGHealthBar1P				; HL = Ptr to start of health bar in tilemap
	ld   bc, Play_Bar_TileIdTbl_RGrow+1	; BC = Tile ID table (bytes 1-8)
	ld   de, Play_Bar_BGOffsetTbl_RGrow	; DE = Tilemap offset table
	; VisualHealth++
	inc  a
	ld   [wPlInfo_Pl1+iPlInfo_HealthVisual], a
	; When the bar grows, it should always update the tile for the previous health value.
	; If we didn't, there'd be an empty gap between tiles when the modulo'd health goes from 7 to 8.
	;
	; ie:
	; -> 7 % 8 = 7 -> Tile+0 set at 7 filled pixels, 1 empty
	; -> 8 % 8 = 0 -> NG Tile+1 set at 8 empty pixels, leaving the previous value at Tile+0
	;                 OK Tile+0 set at 8 filled pixels
	; -> (then continuing as normal with 1 filled pixel on Tile+1)
	;
	; The VisualHealth being offset by -1 is also the reason behind the +1 offset
	; to Play_Bar_TileIdTbl_RGrow, as it shifts the tile IDs down by 1 too.
	dec  a
	call Play_DrawBarTip
	
	;--
	
.chkFixFlash1P:
	;
	; When the health increases from critical to fine, force replace
	; the blank bar graphics with the filled ones.
	;
	; This is because the flashing is done by alternating between empty and filled bar,
	; and it's very possible to switch while the bar is using the empty tiles.
	;
	
	ld   a, [wPlInfo_Pl1+iPlInfo_HealthVisual]
	cp   PLAY_HEALTH_CRITICAL		; VisualHealth != $18?
	jp   nz, .eqTarget1P			; If so, jump
	ld   hl, vBGHealthBar1P_Last	; Start at lowest tile
	
	; Write filled bar to lowest tile
	di
	mWaitForVBlankOrHBlank
	ld   a, TID_BAR_BASE			; Tile ID for filled bar.	
	ldd  [hl], a
	ei
	
	; Write filled bar to 2nd-lowest tile
	push af	; Save TID_BAR_BASE
		di
		mWaitForVBlankOrHBlank
	pop  af	; Restore TID_BAR_BASE
	ldd  [hl], a			
	ei
	; No need to write it to the 3rd-lowest tile, as it's already seen done when the tip
	; was drawn due to the -1 offset.
	
.eqTarget1P:
	;
	; Handle the aforemented health bar flashing at critical health.
	; This is handled by alternating between blank and filled tiles every 4 frames
	; when the health is lower than 18 (meaning 3 tiles at most do the effect)
	;
	ld   a, [wPlInfo_Pl1+iPlInfo_HealthVisual]
	cp   PLAY_HEALTH_CRITICAL	; VisualHealth >= $18?
	jp   nc, .do2P				; If so, skip
	
	; Every 4 frames...
	ld   a, [wPlayTimer]
	and  a, $04				; wPlayTimer % 4 != 0?	
	jp   nz, .flashShow1P	; If so, fill the bar
	
.flashBlank1P:
	ld   a, [wPlInfo_Pl1+iPlInfo_HealthVisual]	; A = Current health
	ld   b, $E0						; B = Tile ID for empty bar
	ld   hl, vBGHealthBar1P_Last	; HL = Lowest tile of 1P health bar
	
	; To save time, only write to the non-empty tiles.	
	; Decrease the health by 8 every time, until it goes negative or we updated all 3 tiles.
	
	;
	; Lowest tile
	;
	mDrawHealthBarTile
	
	;
	; 2nd-lowest tile
	;
	sub  a, $08		; VisualHealth < $08?
	jp   c, .do2P	; If so, skip (2nd-lowest tile is already empty)
	dec  hl			; Move left in tilemap
	mDrawHealthBarTile
	
	;
	; 3rd-lowest tile
	;
	sub  a, $08		; VisualHealth < $10?
	jp   c, .do2P	; If so, skip
	dec  hl
	mDrawHealthBarTile
	
	jp   .do2P
	
.flashShow1P:
	; Display the bar
	ld   a, [wPlInfo_Pl1+iPlInfo_HealthVisual]	; A = Current health
	ld   b, TID_BAR_BASE			; B = Tile ID for filled bar
	ld   hl, vBGHealthBar1P_Last	; HL = Lowest tile of 1P health bar
	
	; Move left from the lowest tile of the health bar, drawing completely filled tiles.
	; Stop when reaching the tip as that doesn't always use the filled tile.
	
	;
	; Lowest tile
	;
	sub  a, $08				; VisualHealth < $08?
	jp   c, .flashTip1P		; If so, jump (tip already reached)
	mDrawHealthBarTile
	dec  hl					; Move left in tilemap
	
	;
	; 2nd-lowest tile
	;
	sub  a, $08				; VisualHealth < $10?
	jp   c, .flashTip1P		; If so, jump 
	mDrawHealthBarTile
	dec  hl					; Move left in tilemap
	
	;
	; 3rd-lowest tile
	;
	sub  a, $08				; VisualHealth < $18?
	jp   c, .flashTip1P		; If so, jump (always)
	;--
	; [TCRF] Unreachable code, as the health bar only flashes at VisualHealth < 18.
	mDrawHealthBarTile
	jp   .do2P
	;--
.flashTip1P:
	;
	; Draw the tip of the health bar.
	; This is a simplified version of Play_DrawBarTip with somewhat hardcoded values.
	;
	
	; TileId = $E7 + (Health % 8)
	and  a, $07		; A = VisualHealth % 8
	; The tile for the empty tile is $E0, which doesn't work with the formula above
	or   a						; Is it $00?
	jp   z, .flashTipEmpty1P	; If so, skip
	add  a, $E7					; Add tile ID base
	; Write TileId to the tilemap
	push af
		di
		mWaitForVBlankOrHBlank
	pop  af
	ld   [hl], a
	ei
	jp   .do2P
.flashTipEmpty1P:
	; Write $E0 to the tilemap
	di
	mWaitForVBlankOrHBlank
	ld   a, $E0
	ld   [hl], a
	ei
	
.do2P:
	;
	; Same thing for the 2P Health Bar
	;
	
	ld   a, [wPlInfo_Pl2+iPlInfo_Health]
	ld   b, a									; B = Target health
	ld   a, [wPlInfo_Pl2+iPlInfo_HealthVisual]	; A = Visual Health
	cp   a, b										
	jp   z, .eqTarget2P		; Health == Target? If so, jump
	jp   c, .ltTarget2P 	; Health < Target?
	
.gtTarget2P:
	; Decrease the bar to the left
	ld   hl, vBGHealthBar2P						; HL = Ptr to start of health bar in tilemap
	ld   bc, Play_Bar_TileIdTbl_LGrow			; BC = Tile ID table (bytes 0-7)
	ld   de, Play_Bar_BGOffsetTbl_LGrow		; DE = Tilemap offset table
	ld   a, [wPlInfo_Pl2+iPlInfo_HealthVisual]	; VisualHealth--
	dec  a
	ld   [wPlInfo_Pl2+iPlInfo_HealthVisual], a
	call Play_DrawBarTip
	jp   .eqTarget2P
	
.ltTarget2P:
	; Increase the bar to the right
	ld   hl, vBGHealthBar2P
	ld   bc, Play_Bar_TileIdTbl_LGrow+1
	ld   de, Play_Bar_BGOffsetTbl_LGrow
	inc  a										; VisualHealth++
	ld   [wPlInfo_Pl2+iPlInfo_HealthVisual], a
	dec  a										; Update tile for previous health value
	call Play_DrawBarTip
.chkFixFlash2P:
	; Force replace the blank bar graphics with the filled ones.
	ld   a, [wPlInfo_Pl2+iPlInfo_HealthVisual]
	cp   PLAY_HEALTH_CRITICAL	; VisualHealth != $18?
	jp   nz, .eqTarget2P		; If so, jump
	ld   hl, vBGHealthBar2P		; Start at lowest tile (matches origin in 2P)
	
	; Write filled bar to lowest tile
	di
	mWaitForVBlankOrHBlank
	ld   a, TID_BAR_BASE
	ldi  [hl], a
	ei
	
	; Write filled bar to 2nd-lowest tile
	push af
		di
		mWaitForVBlankOrHBlank
	pop  af
	ldi  [hl], a
	ei
	
.eqTarget2P:
	;
	; Handle the health bar flashing at critical health.
	;
	ld   a, [wPlInfo_Pl2+iPlInfo_HealthVisual]
	cp   PLAY_HEALTH_CRITICAL	; VisualHealth >= $18?
	jp   nc, .ret				; If so, skip
	; Every 4 frames...
	ld   a, [wPlayTimer]
	and  a, $04				; wPlayTimer % 4 != 0?	
	jp   nz, .flashShow2P	; If so, show the bar
	
.flashBlank2P:
	ld   a, [wPlInfo_Pl2+iPlInfo_HealthVisual]	; A = Current health
	ld   b, $E0				; B = Tile ID for empty bar
	ld   hl, vBGHealthBar2P	; HL = Lowest tile of 2P health bar
	
	;
	; Lowest tile
	;
	mDrawHealthBarTile
	
	;
	; 2nd-lowest tile
	;
	sub  a, $08		; VisualHealth < $08?
	jp   c, .ret	; If so, skip (2nd-lowest tile is already empty)
	inc  hl			; Move right in tilemap
	mDrawHealthBarTile
	
	;
	; 3rd-lowest tile
	;
	sub  a, $08		; VisualHealth < $10?
	jp   c, .ret	; If so, skip
	inc  hl
	mDrawHealthBarTile
	
	jp   .ret
.flashShow2P:
	; Display the bar
	ld   a, [wPlInfo_Pl2+iPlInfo_HealthVisual]	; A = Current health
	ld   b, TID_BAR_BASE		; B = Tile ID for filled bar
	ld   hl, vBGHealthBar2P		; HL = Lowest tile of 2P health bar
	
	; Move right from the lowest tile of the health bar, drawing completely filled tiles.
	
	ASSERT(PLAY_HEALTH_CRITICAL == $18)
	;
	; Lowest tile
	;
	sub  a, $08				; VisualHealth < $08?
	jp   c, .flashTip2P		; If so, jump (tip already reached)
	mDrawHealthBarTile
	inc  hl					; Move left in tilemap
	
	;
	; 2nd-lowest tile
	;
	sub  a, $08				; VisualHealth < $10?
	jp   c, .flashTip2P		; If so, jump 
	mDrawHealthBarTile
	inc  hl					; Move left in tilemap
	
	;
	; 3rd-lowest tile
	;
	sub  a, $08				; VisualHealth < $18?
	jp   c, .flashTip2P		; If so, jump (always)
	;--
	; [TCRF] Unreachable code, as the health bar only flashes at VisualHealth < 18.
	mDrawHealthBarTile
	jp   .ret
	;--
.flashTip2P:
	; Draw the tip of the health bar.
	; TileId = $E0 + (Health % 8)
	and  a, $07
	or   a						; This check is unnecessary for the 2P tilemap
	jp   z, .flashTipEmpty2P	; as the empty bar and tile ID base are the same
	add  a, $E0
	; Write TileId to the tilemap
	push af
		di
		mWaitForVBlankOrHBlank
	pop  af
	ld   [hl], a
	ei
	jp   .ret
.flashTipEmpty2P:
	; Write $E0 to the tilemap
	di
	mWaitForVBlankOrHBlank
	ld   a, $E0
	ld   [hl], a
	ei
.ret:
	ret
	
; =============== Play_DrawBarTip ===============
; Updates the tip tile of a bar.
; IN
; - HL: Ptr to bar in the tilemap (leftmost tile, even on 2P side)
; - BC: Ptr to tile id table. An 8 byte window of this is used.
; - DE: Ptr to tilemap offset table
; -  A: Visual bar value
Play_DrawBarTip:
	
	;
	; The bar graphics include multiple bar tiles to allow pixel-level precision.
	; Determine which tile id we're using for the tip of the bar.
	; A = TileId
	;
	push af
		; As tiles are 8px long, the tip can use 8 possible tiles (VisualHealth % 8).
		and  a, $07		; A = VisualHealth % 8
		; Use that as index to a table mapping sub-tile values to tile IDs.
		; This is different 
		add  c			; BC += A
		ld   c, a
		ld   a, [bc]	; Read value
	pop  bc
	
	;
	; Determine the tilemap ptr to the tip of the bar.
	; HL = TilemapPtr
	;
	push af
		; As tiles are 8px long...
		ld   a, b		; A = B / 8
		srl  a
		srl  a
		srl  a
		; Use that as index to a table of tilemap *offsets*.
		; The byte read out from here is added to the tilemap's origin passed in HL.
		;
		; Note that there are two different tables for the two players, as both
		; bars grow from the center of the screen.
		; Because the bar origin is always the leftmost tile for both sides, these
		; offsets are always positive.
		add  a, e		; DE += A (index table)
		ld   e, a
		ld   a, [de]	; A = TilemapOffset
		add  a, l		; HL += A (add it to tilemap ptr)
		ld   l, a
		
	;
	; Write the tile id to the tilemap
	;
		di
		mWaitForVBlankOrHBlank
	pop  af
	
	ld   [hl], a	
	ei
	
	ret
	
; =============== Play_UpdatePowBars ===============
; Draws/updates the POW bar display for both players, including in the MAXIMUM POW mode.
; See also: Play_UpdateHealthBars
Play_UpdatePowBars:

	; In max power mode, a different bar is handled.
	ld   a, [wPlInfo_Pl1+iPlInfo_MaxPowExtraLen]
	cp   PLAY_MAXMODE_NONE		; In Max Power mode? (!= $00)
	jp   nz, .maxPow1P			; If so, jump
	
	ld   a, [wPlInfo_Pl1+iPlInfo_Pow]
	ld   b, a								; B = Target POW
	ld   a, [wPlInfo_Pl1+iPlInfo_PowVisual]	; A = Visual POW
	cp   a, b
	; If nothing changes, skip to checking the 2P POW bar
	jp   z, .chk2P		; VisualPOW == Target? If so, jump
	; If the visual POW value is less than the target, increase the bar.
	jp   c, .ltTarget1P	; VisualPOW < Target? If so, jump
	; Otherwise, POW > Target. Decrease the POW bar.
.gtTarget1P:
	; If we're decreasing the bar from $28, it means the MAXIMUM POW effect just ended.
	; That uses its own different tilemap, so replace it with the normal POW bar.
	cp   PLAY_POW_MAX			; VisualPOW == $28?
	jp   nz, .decPow1P			; If not, jump
	ld   hl, vBGPowBar1P_Left-1	; HL = Ptr to left *border* of the POW bar
	push af
		call Play_DrawFilledPowBar		; Write the normal POW tilemap
	pop  af
.decPow1P:

	; Decrease the POW bar
	ld   hl, vBGPowBar1P_Left
	ld   bc, Play_Bar_TileIdTbl_LGrow
	ld   de, Play_Bar_BGOffsetTbl_LGrow	; Use offsets 0-4
	; VisualPOW--
	dec  a
	ld   [wPlInfo_Pl1+iPlInfo_PowVisual], a
	call Play_DrawBarTip
	jp   .chk2P
.ltTarget1P:
	;
	; Increase the POW bar
	;
	ld   hl, vBGPowBar1P_Left
	ld   bc, Play_Bar_TileIdTbl_LGrow+1
	ld   de, Play_Bar_BGOffsetTbl_LGrow	; Use offsets 0-4
	inc  a
	ld   [wPlInfo_Pl1+iPlInfo_PowVisual], a
	
	;
	; If we've filled the POW bar, switch to MAXIMUM POW mode
	;
	cp   PLAY_POW_MAX 		; VisualPOW == $28?			
	jp   z, .setMaxPow1P	; If so, jump
	; Otherwise, draw the tip of the normal POW bar.
	; Like with the health bar, draw it for VisualPOW-1 for modulo reasons
	dec  a
	call Play_DrawBarTip
	jp   .chk2P
.setMaxPow1P:
	; Replace normal POW bar with "MAXIMUM" text
	ld   hl, vBGPowBar1P_Left-1 ; Left corner 
	call Play_DrawMaximumText
	; Set final bar info
	ld   bc, wPlInfo_Pl1
	ld   de, Play_MaxPowBGPtrTbl_1P
	call Play_PlSetMaxPowInfo
	
	;
	; Prepare the scroll-in to the right.
	;
	
	; Enable scroll-in for the 1P bar
	ld   hl, wPlayMaxPowScroll1P
	ld   a, PLAY_MAXPOWFADE_IN
	ldi  [hl], a
	; Set initial BG offset for the effect.
	; As the bar moves to the right, this points to its right corner, which is always $00 here.
	ld   a, $00			; wPlayMaxPowScrollBGOffset1P
	ldi  [hl], a
	; Move right for $0A frames.
	ld   a, $0A			; wPlayMaxPowScrollTimer1P
	ld   [hl], a
	jp   .chk2P
	
.maxPow1P:
	; Check if the MAX power bar is moving in or out
	ld   a, [wPlayMaxPowScroll1P]
	cp   PLAY_MAXPOWFADE_IN		; Scrolling on-screen the MAX power bar?
	jp   z, .maxPowScrollIn1P	; If so, jump
	cp   PLAY_MAXPOWFADE_OUT	; Scrolling off-screen the MAX power bar?
	jp   z, .maxPowScrollOut1P	; If so, jump
	
	ld   a, [wPlInfo_Pl1+iPlInfo_MaxPow]
	ld   b, a									; B = Target MaxPow
	ld   a, [wPlInfo_Pl1+iPlInfo_MaxPowVisual]	; A = Visual MaxPow
	cp   a, b
	jp   z, .chk2P		; VisualMaxPow == Target? If so, skip
	; [TCRF] The MAX power bar always shrinks slowly and never grows.
	;        In case it is, don't do anything.
	jp   c, .unused_ltTargetMax1P	; VisualMaxPow < Target? If so, skip
	
	; Otherwise, VisualMaxPow > Target.
.gtTargetMax1P:

	;
	; Decrease the MAX power bar.
	;
	
	; Prepare the args for Play_DrawBarTip
	push af
		; HL = Ptr to start of MAX power bar in tilemap
		ld   hl, wPlInfo_Pl1+iPlInfo_MaxPowBGPtr_High
		ldi  a, [hl]	; D = iPlInfo_MaxPowBGPtr_High
		ld   d, a
		ld   a, [hl]	; E = iPlInfo_MaxPowBGPtr_Low
		ld   e, a
		push de			; Move to HL
		pop  hl
	pop  af
	ld   bc, Play_Bar_TileIdTbl_LGrow	; BC = Tile ID table (bytes 0-8)
	ld   de, Play_Bar_BGOffsetTbl_LGrow	; DE = Tilemap offset table (bytes 0-x)
	
	; VisualMaxPOW--
	dec  a
	ld   [wPlInfo_Pl1+iPlInfo_MaxPowVisual], a
	call Play_DrawBarTip
	
	;
	; If the MAX power bar is visually empty now, start the animation
	; to move it off-screen to the left.
	;
	ld   a, [wPlInfo_Pl1+iPlInfo_MaxPowVisual]
	cp   $00			; VisualMaxPOW == 0?
	jp   nz, .chk2P		; If not, skip
	
	; Set animation mode
	ld   hl, wPlayMaxPowScroll1P
	ld   a, PLAY_MAXPOWFADE_OUT		
	ldi  [hl], a	
	
	; Set offset to the left corner of the MAX pow bar.
	; As the bar can grow to the left:
	; wPlayMaxPowScrollBGOffset1P = (Max Length) - (Additional Length) - 1
	;   With the extra -1 since the entire thing is being already moved to the left.
	ld   a, [wPlInfo_Pl1+iPlInfo_MaxPowExtraLen]
	ld   b, a		
	ld   a, PLAY_MAXMODE_LENGTH4
	sub  a, b		
	dec  a					
	ldi  [hl], a			; wPlayMaxPowScrollBGOffset1P = 4 - iPlInfo_MaxPowExtraLen - 1
	; Move it left for $0A frames, to make it go fully off-screen
	ld   a, $0A
	ld   [hl], a			; wPlayMaxPowScrollTimer1P = $0A
	jp   .chk2P
	
.unused_ltTargetMax1P:
	jp   .chk2P
	
.maxPowScrollIn1P:
	;
	; The 1P scroll-in effect is handled by partially redrawing the bar every frame,
	; and moving it right $0A times.
	;
	ld   a, [wPlayMaxPowScrollBGOffset1P]
	ld   e, a							; E = Bar Origin (in tiles)
	ld   a, [wPlInfo_Pl1+iPlInfo_MaxPowExtraLen]
	add  a, PLAY_MAXMODE_BASELENGTH		; B = iPlInfo_MaxPowExtraLen + $04
	ld   b, a
	ld   c, TID_BAR_BASE				; C = Filled bar tile ID
	call Play_DrawMaxPowBarFromR
	
	;
	; Move bar to the right by 1 tile for the next time we get here
	; When this is repeated for the last time, the bar should be
	; in the same position that the previously set iPlInfo_MaxPowBGPtr expects it to be.
	;
	ld   hl, wPlayMaxPowScrollBGOffset1P
	inc  [hl]
	; Decrease scroll counter
	inc  hl			; Seek to wPlayMaxPowScrollTimer1P
	dec  [hl]		; Counter == 0?
	jp   nz, .chk2P	; If not, jump
	
	; Otherwise, we're done moving the bar
	ld   a, PLAY_MAXPOWFADE_NONE	; Disable fade
	ld   [wPlayMaxPowScroll1P], a
	ld   a, SCT_CHARGEFULL			; Play max power SFX
	call HomeCall_Sound_ReqPlayExId
	jp   .chk2P
	
.maxPowScrollOut1P:
	;
	; Move the max pow bar to the left, until it goes off-screen.
	;
	ld   a, [wPlayMaxPowScrollBGOffset1P]
	ld   e, a						; E = Bar Origin (in tiles)
	ld   a, [wPlInfo_Pl1+iPlInfo_MaxPowExtraLen]
	add  a, PLAY_MAXMODE_BASELENGTH	; B = iPlInfo_MaxPowExtraLen + $04
	ld   b, a
	ld   c, $E0						; C = Empty bar tile ID
	call Play_DrawMaxPowBarFromL
	
	; Move bar to the left by 1 tile for the next time we get here
	ld   hl, wPlayMaxPowScrollBGOffset1P
	dec  [hl]
	; Decrease scroll counter
	inc  hl			; Seek to wPlayMaxPowScrollTimer1P
	dec  [hl]		; Counter == 0?
	jp   nz, .chk2P	; If not, jump
	; Otherwise, we're done moving the bar
	ld   a, PLAY_MAXPOWFADE_NONE
	ld   [wPlayMaxPowScroll1P], a		; Stop moving the bar
	ld   [wPlInfo_Pl1+iPlInfo_MaxPowExtraLen], a ; Return to normal POW display
	; Reset *actual POW* value to $00, forcing the POW bar to deplete from the previous
	; filled state to empty.
	ld   [wPlInfo_Pl1+iPlInfo_Pow], a
	jp   .chk2P
	
.chk2P:
	
	; In max power mode, a different bar is handled.
	ld   a, [wPlInfo_Pl2+iPlInfo_MaxPowExtraLen]
	cp   PLAY_MAXMODE_NONE		; In Max Power mode? (!= $00)
	jp   nz, .maxPow2P			; If so, jump
	
	ld   a, [wPlInfo_Pl2+iPlInfo_Pow]
	ld   b, a								; B = Target POW
	ld   a, [wPlInfo_Pl2+iPlInfo_PowVisual]	; A = Visual POW
	cp   a, b
	; If nothing changes, skip to checking the 2P POW bar
	jp   z, .ret		; VisualPOW == Target? If so, jump
	; If the visual POW value is less than the target, increase the bar.
	jp   c, .ltTarget2P	; VisualPOW < Target? If so, jump
	; Otherwise, POW > Target. Decrease the POW bar.
.gtTarget2P:
	; If we're decreasing the bar from $28, it means the MAXIMUM POW effect just ended.
	; That uses its own different tilemap, so replace it with the normal POW bar.
	cp   PLAY_POW_MAX			; VisualPOW == $28?
	jp   nz, .decPow2P			; If not, jump
	ld   hl, vBGPowBar2P_Left-1	; HL = Ptr to left *border* of the POW bar
	push af
		call Play_DrawFilledPowBar		; Write the normal POW tilemap
	pop  af
.decPow2P:
	; Decrease the POW bar.
	ld   hl, vBGPowBar2P_Left
	ld   bc, Play_Bar_TileIdTbl_RGrow
	ld   de, Play_Bar_BGOffsetTbl_RGrow+4	; Use offsets 4-8 (due to the reverse order of Play_Bar_BGOffsetTbl_RGrow)
	; VisualPOW--
	dec  a
	ld   [wPlInfo_Pl2+iPlInfo_PowVisual], a
	call Play_DrawBarTip
	jp   .ret
.ltTarget2P:
	;
	; Increase the POW bar
	;
	ld   hl, vBGPowBar2P_Left
	ld   bc, Play_Bar_TileIdTbl_RGrow+1
	ld   de, Play_Bar_BGOffsetTbl_RGrow+4	; Use offsets 4-8
	inc  a
	ld   [wPlInfo_Pl2+iPlInfo_PowVisual], a
	;
	; If we've filled the POW bar, switch to MAXIMUM POW mode
	;
	cp   PLAY_POW_MAX 		; VisualPOW == $28?			
	jp   z, .setMaxPow2P	; If so, jump
	; Otherwise, draw the tip of the normal POW bar.
	; Like with the health bar, draw it for VisualPOW-1 for modulo reasons
	dec  a
	call Play_DrawBarTip
	jp   .ret
.setMaxPow2P:
	; Replace normal POW bar with "MAXIMUM" text
	ld   hl, vBGPowBar2P_Left-1 ; Left corner 
	call Play_DrawMaximumText
	; Set final bar info
	ld   bc, wPlInfo_Pl2
	ld   de, Play_MaxPowBGPtrTbl_2P
	call Play_PlSetMaxPowInfo
	
	;
	; Prepare the scroll-in to the left.
	;
	
	; Enable scroll-in for the 2P bar
	ld   hl, wPlayMaxPowScroll2P
	ld   a, PLAY_MAXPOWFADE_IN
	ldi  [hl], a
	; Set initial BG offset for the effect.
	; As the bar moves to the left, this points to its left corner, which is always $13 here.
	ld   a, (SCREEN_H/TILE_H)-1			; wPlayMaxPowScrollBGOffset2P
	ldi  [hl], a
	; Move left for $0A frames.
	ld   a, $0A			; wPlayMaxPowScrollTimer2P
	ld   [hl], a
	jp   .ret
.maxPow2P:
	; Check if the MAX power bar is moving in or out
	ld   a, [wPlayMaxPowScroll2P]
	cp   PLAY_MAXPOWFADE_IN		; Scrolling on-screen the MAX power bar?
	jp   z, .maxPowScrollIn2P	; If so, jump
	cp   PLAY_MAXPOWFADE_OUT	; Scrolling off-screen the MAX power bar?
	jp   z, .maxPowScrollOut2P	; If so, jump
	
	ld   a, [wPlInfo_Pl2+iPlInfo_MaxPow]
	ld   b, a									; B = Target MaxPow
	ld   a, [wPlInfo_Pl2+iPlInfo_MaxPowVisual]	; A = Visual MaxPow
	cp   a, b
	jp   z, .ret		; VisualMaxPow == Target? If so, skip
	; [TCRF] The MAX power bar always shrinks slowly and never grows.
	;        In case it is, don't do anything.
	jp   c, .unused_ltTargetMax2P	; VisualMaxPow < Target? If so, skip
	
	; Otherwise, VisualMaxPow > Target.
.gtTargetMax2P:

	;
	; Decrease the MAX power bar.
	;
	push af
		; HL = Ptr to start of MAX power bar in tilemap
		ld   hl, wPlInfo_Pl2+iPlInfo_MaxPowBGPtr_High
		ldi  a, [hl]	; D = iPlInfo_MaxPowBGPtr_High
		ld   d, a
		ld   a, [hl]	; E = iPlInfo_MaxPowBGPtr_Low
		ld   e, a
		push de			; Move to HL
		pop  hl
	pop  af
	
	ld   bc, Play_Bar_TileIdTbl_RGrow	; BC = Tile ID table
	
	; Determine the starting ptr to the tilemap offset table.
	push af
		; Start with byte range 4-8 (5 bytes) as entries are right-aligned.
		; For any extension to the bar, decrement the starting offset by 1.
		ld   de, Play_Bar_BGOffsetTbl_RGrow+4  
		
		ld   a, [wPlInfo_Pl2+iPlInfo_MaxPowExtraLen]
		cp   PLAY_MAXMODE_LENGTH1	; No extra length?
		jp   z, .setVisual2P		; If so, jump
		dec  de						; Otherwise, byte range is 3-8
		cp   PLAY_MAXMODE_LENGTH2	; 1 additional tile?
		jp   z, .setVisual2P		; If so, jump
		dec  de						; Otherwise, byte range is 2-8
		cp   PLAY_MAXMODE_LENGTH3	; 2 additional tiles?
		jp   z, .setVisual2P		; If so, jump
		dec  de						; Otherwise, byte range is 1-8
	.setVisual2P:
	pop  af
	
	; VisualMaxPOW--
	dec  a
	ld   [wPlInfo_Pl2+iPlInfo_MaxPowVisual], a
	call Play_DrawBarTip
	
	;
	; If the MAX power bar is visually empty now, start the animation
	; to move it off-screen to the right.
	;
	ld   a, [wPlInfo_Pl2+iPlInfo_MaxPowVisual]
	cp   $00			; VisualMaxPOW == 0?
	jp   nz, .ret		; If not, skip
	
	; Set animation mode
	ld   hl, wPlayMaxPowScroll2P
	ld   a, PLAY_MAXPOWFADE_OUT		
	ldi  [hl], a	
	
	; Set initial bar offset for the effect. 
	; On the 2P side, this is the right corner of the bar.
	ld   a, [wPlInfo_Pl2+iPlInfo_MaxPowExtraLen]
	add  a, $10
	ldi  [hl], a	; wPlayMaxPowScrollBGOffset2P = $10 + iPlInfo_MaxPowExtraLen
	; Move it right for $0A frames, to make it go fully off-screen
	ld   a, $0A
	ld   [hl], a	; wPlayMaxPowScrollTimer2P = $0A
	jp   .ret
.unused_ltTargetMax2P:
	jp   .ret
.maxPowScrollIn2P:
	;
	; The 2P scroll-in effect is handled by partially redrawing the bar every frame,
	; and moving it left $0A times.
	;
	ld   a, [wPlayMaxPowScrollBGOffset2P]
	ld   e, a							; E = Bar Origin (in tiles)
	ld   a, [wPlInfo_Pl2+iPlInfo_MaxPowExtraLen]
	add  a, PLAY_MAXMODE_BASELENGTH		; B = iPlInfo_MaxPowExtraLen + $04
	ld   b, a
	ld   c, TID_BAR_BASE				; C = Filled bar tile ID
	call Play_DrawMaxPowBarFromL
	
	;
	; Move bar to the left by 1 tile for the next time we get here.
	; When this is repeated for the last time, the bar should be
	; in the same position that the previously set iPlInfo_MaxPowBGPtr expects it to be.
	;
	ld   hl, wPlayMaxPowScrollBGOffset2P
	dec  [hl]
	; Decrease scroll counter
	inc  hl			; Seek to wPlayMaxPowScrollTimer2P
	dec  [hl]		; Counter == 0?
	jp   nz, .ret	; If not, jump
	
	; Otherwise, we're done moving the bar
	ld   a, PLAY_MAXPOWFADE_NONE	; Disable fade
	ld   [wPlayMaxPowScroll2P], a
	ld   a, SCT_CHARGEFULL			; Play max power SFX
	call HomeCall_Sound_ReqPlayExId
	jp   .ret
	
.maxPowScrollOut2P:
	;
	; Move the max pow bar to the right, until it goes off-screen.
	;
	ld   a, [wPlayMaxPowScrollBGOffset2P]
	ld   e, a						; E = Bar Origin (in tiles)
	ld   a, [wPlInfo_Pl2+iPlInfo_MaxPowExtraLen]
	add  a, PLAY_MAXMODE_BASELENGTH	; B = iPlInfo_MaxPowExtraLen + $04
	ld   b, a
	ld   c, $E0						; C = Empty bar tile ID
	call Play_DrawMaxPowBarFromR
	
	; Move bar to the right by 1 tile for the next time we get here
	ld   hl, wPlayMaxPowScrollBGOffset2P
	inc  [hl]
	; Decrease scroll counter
	inc  hl			; Seek to wPlayMaxPowScrollTimer2P
	dec  [hl]		; Counter == 0?
	jp   nz, .ret	; If not, jump
	; Otherwise, we're done moving the bar
	ld   a, PLAY_MAXPOWFADE_NONE
	ld   [wPlayMaxPowScroll2P], a		; Stop moving the bar
	ld   [wPlInfo_Pl2+iPlInfo_MaxPowExtraLen], a ; Return to normal POW display
	; Reset *actual POW* value to $00, forcing the POW bar to deplete from the previous
	; filled state to empty.
	ld   [wPlInfo_Pl2+iPlInfo_Pow], a
	jp   .ret
	
.ret:
	ret
	
; =============== Play_DrawMaxPowBarFromR ===============
; Draws part of the MAX Power bar from right to left,
; intended to be used when doing the scroll animation.
; IN
; - E: Offset to the right corner of the bar, relative to wBGMaxPowBarRow
; - B: Bar content length (in tiles)
; - C: Tile ID for the bar contents.
Play_DrawMaxPowBarFromR:
	;
	; Sign extend E to DE
	;
	ld   d, $00		
	bit  7, e		; E < 0?
	jp   z, .draw	; If not, jump
	ld   d, $FF 	; We never get here?
	
.draw:

	; Only the 4 edges need to be updated to move the bar.

	; Draw right corner
	ld   a, TID_BAR_R	; A = TID_BAR_R
	call Play_WriteTileToMaxPowBar
	dec  de				; Seek left in tilemap
	
	; Draw bar content
	ld   a, c
	call Play_WriteTileToMaxPowBar
	
	;
	; Seek to the left corner of the bar by subtracting
	; the bar length to the tilemap ptr.
	;
	; DE -= B (Bar length)
	;
	
	; HL = B
	ld   h, $00	
	ld   l, b
	; Convert HL to negative
	; H = ^H (flip bits)
	ld   a, h	
	cpl
	ld   h, a
	; L = -L (invert L)
	ld   a, l	
	cpl
	ld   l, a
	inc  l		
	; If this overflowed to 0, increase H
	jp   nz, .setOffset
	inc  h ; We never get here
.setOffset:
	; Add that negative offset to HL, then move it to DE
	add  hl, de	
	push hl
	pop  de
	
	; Draw left corner
	ld   a, TID_BAR_L
	call Play_WriteTileToMaxPowBar
	dec  de
	
	; Draw empty tile, to clear out the left corner of the previous frame
	ld   a, $00
	call Play_WriteTileToMaxPowBar
	ret
	
; =============== Play_DrawMaxPowBarFromL ===============
; Draws part of the MAX Power bar from *left* to *right*,
; intended to be used when doing the scroll animation.
; See also: Play_DrawMaxPowBarFromR
; IN
; - E: Offset to the *left* corner of the bar, relative to wBGMaxPowBarRow
; - B: Bar content length (in tiles)
; - C: Tile ID for the bar contents.
Play_DrawMaxPowBarFromL:
	;
	; Sign extend E to DE
	;
	ld   d, $00		
	bit  7, e		; E < 0?
	jp   z, .draw	; If not, jump
	ld   d, $FF 	; We never get here?
	
.draw:
	; Draw left corner
	ld   a, TID_BAR_L
	call Play_WriteTileToMaxPowBar
	inc  de
	
	; Draw bar content
	ld   a, c
	call Play_WriteTileToMaxPowBar
	
	; Seek to the right corner of the bar
	; DE += B
	ld   h, $00
	ld   l, b
	add  hl, de
	push hl
	pop  de
	
	; Draw right corner
	ld   a, TID_BAR_R
	call Play_WriteTileToMaxPowBar
	inc  de
	
	; Draw empty tile
	ld   a, $00
	call Play_WriteTileToMaxPowBar
	ret
	
; =============== Play_WriteTileToMaxPowBar ===============
; Writes a tile to the tilemap for the MAX power bar.
; IN
; - A: Tile ID
; - DE: Tilemap offset, relative to wBGMaxPowBarRow
Play_WriteTileToMaxPowBar:
	; Don't write off-screen tiles.
	; This is checked because the scroll-in/scroll-out animation
	; makes the bar move from or to the off-screen area.
	push af
		ld   a, e			
		bit  7, a				; DE < 0?
		jp   nz, .popRet		; If so, return
		cp   SCREEN_H/TILE_H	; DE >= $14?
		jp   nc, .popRet		; If so, return
	pop  af
	
	; Get ptr to tilemap
	ld   hl, wBGMaxPowBarRow	; HL = wBGMaxPowBarRow + DE
	add  hl, de
	
	; Wait for VRAM to be writable
	push af
		di
		mWaitForVBlankOrHBlank
	pop  af
	
	; Write to the tilemap
	ld   [hl], a
	ei
	jp   .ret
.popRet:
	pop  af
.ret:
	ret
	

	
; =============== Play_Unused_ScrollInMaxPowBar1P ===============
; [TCRF] Unreferenced code.
;
; Earlier version of the code for scrolling in the MAX pow bar.
; This does nothing the used code doesn't do already, and it's more limited
; as it can only handle a specific player.
;
; Like the normal code, this only draws the edges of the bar, with the middle
; portion being filled in with repeated calls.
;
; IN
; - HL: wBGMaxPowBarRow
; - BC: Ptr to wPlInfo
Play_Unused_ScrollInMaxPowBar1P:

	;
	; Move/Draw the right side of the MAX power bar.
	;
	push hl
	
		;
		; Seek to the tile wPlayMaxPowScrollBGOffset1P points to, then write a filled bar there.
		; This is where the bar ends on the right side.
		;
		; As wPlayMaxPowScrollBGOffset1P increases at the end of the subroutine,
		; every call progressively moves the bar further to the right.
		;
		ld   a, [wPlayMaxPowScrollBGOffset1P]
		ld   d, $00
		ld   e, a
		
		push af
			; Get the absolute ptr to the tilemap
			add  hl, de
			
			; Draw a filled tile
			di   
			mWaitForVBlankOrHBlank
			ld   a, TID_BAR_BASE
			ldi  [hl], a			; Move to the right
			ei   
			
			; Draw right border
			di   
			mWaitForVBlankOrHBlank
			ld   a, TID_BAR_R
			ld   [hl], a
			ei   
			
			;
			; Draw the left border too as long as it's on-screen.
			;

			;
			; Determine first where the bar starts:
			; OffsetL = wPlayMaxPowScrollBGOffset1P - (iPlInfo_MaxPowExtraLen + 4)
			; - wPlayMaxPowScrollBGOffset1P -> offset to right corner
			; - iPlInfo_MaxPowExtraLen -> extra length (min 1) added over the base length of 4
			;
			; If that doesn't point before the start of the row, write the left border tile there,
			; as well as a blank tile further left to clean the previous left border tile.
			;
			
			; B = Bar length
			ld   hl, iPlInfo_MaxPowExtraLen
			add  hl, bc		; Seek to iPlInfo_MaxPowExtraLen
			ld   a, [hl]	; A = Additional length
			add  a, $04		; Add base length
			ld   b, a		; Store to B
		pop  af ; A = wPlayMaxPowScrollBGOffset1P
	pop  hl
	; Calculate offset
	sub  b				; A = wPlayMaxPowScrollBGOffset1P - (iPlInfo_MaxPowExtraLen + 4)
	; Add it over if not before start of row
	jp   c, .incInfo	; A < 0? If so, skip
	
	; DE = Offset to the left corner of the bar, relative to HL
	ld   d, $00
	ld   e, a
	; Get the absolute ptr to the tilemap
	add  hl, de
	
	; Draw left border
	push af
		di   
		mWaitForVBlankOrHBlank
		ld   a, TID_BAR_L
		ldd  [hl], a		; Move to the left
		ei   
	pop  af
	
	; Draw an empty tile if we aren't on the first tile of the row.
	; This gets rid of the previous left border if possible.
	cp   a, $00			; Offset == 0?
	jp   z, .incInfo	; If so, skip
	di   
	mWaitForVBlankOrHBlank
	ld   a, $00
	ld   [hl], a
	ei   
	
	;
	; NEXT!
	;
.incInfo:
	; Increment the offset, so the next time we call this the bar is drawn further right
	ld   a, [wPlayMaxPowScrollBGOffset1P]
	inc  a
	ld   [wPlayMaxPowScrollBGOffset1P], a
	
	; If we reached the max scroll value, end the scroll effect
	cp   a, $09
	jp   nz, .ret
	ld   a, $00
	ld   [wPlayMaxPowScroll1P], a
.ret:
	ret  
	
; =============== Play_Unused_ScrollInMaxPowBar1P_2 ===============
; [TCRF] Unreferenced code.
; Almost identical to Play_Unused_ScrollInMaxPowBar1P, except this goes off iPlInfo_MaxPowBGPtr,
; which is never supposed to be used for scrolling in-the bar, since it already points to the 
; final position and not the left edge of the screen.
;
; IN
; - BC: Ptr to wPlInfo
Play_Unused_ScrollInMaxPowBar1P_2:
	; HL = Ptr to leftmost tile of MAX power bar in tilemap
	ld   hl, iPlInfo_MaxPowBGPtr_High
	add  hl, bc		; Seek to there
	ldi  a, [hl]	; D = iPlInfo_MaxPowBGPtr_High
	ld   d, a
	ld   a, [hl]	; E = iPlInfo_MaxPowBGPtr_Low
	ld   e, a
	push de			; Move to HL
	pop  hl	
	dec  hl			; Move left in the tilemap
	
	;--
	; The rest is identical to Play_Unused_ScrollInMaxPowBar1P
	
	push hl
		;
		; Seek to the tile wPlayMaxPowScrollBGOffset1P points to, then write a filled bar there.
		;
		ld   a, [wPlayMaxPowScrollBGOffset1P]
		ld   d, $00
		ld   e, a
		
		push af
			; Get the absolute ptr to the tilemap
			add  hl, de
			
			; Draw a filled tile
			di   
			mWaitForVBlankOrHBlank
			ld   a, TID_BAR_BASE
			ldi  [hl], a			; Move to the right
			ei   
			
			; Draw right border
			di   
			mWaitForVBlankOrHBlank
			ld   a, TID_BAR_R
			ld   [hl], a
			ei   
			
			;
			; Draw the left border too as long as it's on-screen.
			;
			
			; B = Bar length
			ld   hl, iPlInfo_MaxPowExtraLen
			add  hl, bc		; Seek to iPlInfo_MaxPowExtraLen
			ld   a, [hl]	; A = Additional length
			add  a, $04		; Add base length
			ld   b, a		; Store to B
		pop  af ; A = wPlayMaxPowScrollBGOffset1P
	pop  hl
	; Calculate offset
	sub  b				; A = wPlayMaxPowScrollBGOffset1P - (iPlInfo_MaxPowExtraLen + 4)
	; Add it over if not before start of row
	jp   c, .incInfo	; A < 0? If so, skip
	
	; DE = Offset to the left corner of the bar, relative to HL
	ld   d, $00
	ld   e, a
	; Get the absolute ptr to the tilemap
	add  hl, de
	
	; Draw left border
	push af
		di   
		mWaitForVBlankOrHBlank
		ld   a, TID_BAR_L
		ldd  [hl], a		; Move to the left
		ei   
	pop  af
	
	; Draw an empty tile if we aren't on the first tile of the row.
	; This gets rid of the previous left border if possible.
	cp   a, $00			; Offset == 0?
	jp   z, .incInfo	; If so, skip
	di   
	mWaitForVBlankOrHBlank
	ld   a, $00
	ld   [hl], a
	ei   
	
	;
	; NEXT!
	;
.incInfo:
	; Increment the offset, so the next time we call this the bar is drawn further right
	ld   a, [wPlayMaxPowScrollBGOffset1P]
	inc  a
	ld   [wPlayMaxPowScrollBGOffset1P], a
	
	; If we reached the max scroll value, end the scroll effect
	cp   a, $09
	jp   nz, .ret
	ld   a, $00
	ld   [wPlayMaxPowScroll1P], a
.ret:
	ret  
	
; =============== Play_Unused_DrawMaxPowBar ===============
; [TCRF] Unreferenced code.
; Fully redraws a full MAX pow bar for the specified player.
; This may have been used before the scroll-in effect was implemented.
; IN
; - BC: Ptr to wPlInfo
Play_Unused_DrawMaxPowBar:
	;
	; Seek to the leftmost tile of the MAX power bar in tilemap.
	;
	ld   hl, iPlInfo_MaxPowBGPtr_High
	add  hl, bc		; Seek to there
	ldi  a, [hl]	; D = iPlInfo_MaxPowBGPtr_High
	ld   d, a
	ld   a, [hl]	; E = iPlInfo_MaxPowBGPtr_Low
	ld   e, a
	push de			; Move to HL
	pop  hl
	
	; iPlInfo_MaxPowBGPtr points to the first "full bar" tile, but we need to draw the border.
	dec  hl			; Move left in the tilemap
	
	;
	; Draw the left border of the bar
	;
	di   
	mWaitForVBlankOrHBlank
	ld   a, TID_BAR_L	; Move right
	ldi  [hl], a
	ei   
	
	;
	; Draw the filled contents of the bar.
	;
	
	; B = Bar Length
	push hl
		ld   hl, iPlInfo_MaxPowExtraLen
		add  hl, bc		
		ld   a, [hl]	; A = Extra length (1-4)
	pop  hl
	add  a, $04			; Add the base over
	ld   b, a			; B = Bar length
.loop:
	di   
	mWaitForVBlankOrHBlank
	ld   a, TID_BAR_BASE
	ldi  [hl], a		; Draw filled bar, move right in the tilemap
	ei   
	dec  b				; Are we done?
	jp   nz, .loop		; If not, loop
	
	;
	; Draw the right border of the bar.
	;
	di   
	mWaitForVBlankOrHBlank
	ld   a, TID_BAR_R
	ldi  [hl], a
	ei   
	ret 
; =============== Play_Unused_ClearMaxPowBar ===============
; [TCRF] Unreferenced code.
; Blanks out $0A tiles from the tilemap, starting from HL and moving right.
; Has to involve the MAX Power bar due to where this code is located,
; but $0A tiles is much longer than the max length of that bar.
; IN
; - HL: Tilemap Ptr
Play_Unused_ClearMaxPowBar:
	ld   b, $0A		; B = Tiles to clear
.loop:
	di   
	mWaitForVBlankOrHBlank
	ld   a, $00
	ldi  [hl], a	; Blank it, move right
	ei   
	dec  b			; Are we done?
	jp   nz, .loop	; If not, loop
	ret

; =============== Play_PlSetMaxPowInfo ===============
; Sets the final length of the MAX Power bar for the specified player.
; - BC: Ptr to wPlInfo struct
; - DE: Ptr to ptr table of iPlInfo_MaxPowBGPtr
Play_PlSetMaxPowInfo:
	;
	; The MAX Power bar is longer when the player has less health.
	;
	
	; A = Current health
	ld   hl, iPlInfo_Health
	add  hl, bc		
	ld   a, [hl]
	
	ld   hl, iPlInfo_MaxPow
	add  hl, bc		; Seek to max power for writing
	
	cp   $08		; Health < $08?
	jp   c, .lv4	; If so, jump
	cp   $18		; Health < $18?
	jp   c, .lv3	; If so, jump
	cp   $30		; Health < $30?
	jp   c, .lv2	; If so, jump
	
.lv1:
	; Otherwise, HP >= $30.
	ld   [hl], $28	; iPlInfo_MaxPow
	inc  hl
	ld   [hl], $28	; iPlInfo_MaxPowVisual
	inc  hl
	ld   [hl], $01	; iPlInfo_MaxPowExtraLen
	; Use for ptr table offset 0
	jp   .setBGPtr
.lv2:
	ld   [hl], $30	; iPlInfo_MaxPow
	inc  hl
	ld   [hl], $30	; iPlInfo_MaxPowVisual
	inc  hl
	ld   [hl], $02	; iPlInfo_MaxPowExtraLen
	; Use for ptr table offset 2
	inc  de
	inc  de
	jp   .setBGPtr
.lv3:
	ld   [hl], $38	; iPlInfo_MaxPow
	inc  hl
	ld   [hl], $38	; iPlInfo_MaxPowVisual
	inc  hl
	ld   [hl], $03	; iPlInfo_MaxPowExtraLen
	; Use for ptr table offset 4
	inc  de
	inc  de
	inc  de
	inc  de
	jp   .setBGPtr
.lv4:
	ld   [hl], $40	; iPlInfo_MaxPow
	inc  hl
	ld   [hl], $40	; iPlInfo_MaxPowVisual
	inc  hl
	ld   [hl], $04	; iPlInfo_MaxPowExtraLen
	; Use for ptr table offset 6
	inc  de
	inc  de
	inc  de
	inc  de
	inc  de
	inc  de
.setBGPtr:

	; Copy the entry from the table to iPlInfo_MaxPowBGPtr.
	; This will be the *final* origin of the Max POW bar used after it finishes scrolling on-screen.
	; This always points to the leftmost usable tile (see: not the corner tile) of the bar.
	
	; This is also stored as big endian on the wPlInfo, so more ldd usage.
	inc  hl			; Seek to iPlInfo_MaxPowBGPtr_High
	inc  hl 		; Seek to iPlInfo_MaxPowBGPtr_Low
	ld   a, [de]	; Read byte0 of entry
	inc  de
	ldd  [hl], a	; Write to iPlInfo_MaxPowBGPtr_Low, seek to iPlInfo_MaxPowBGPtr_High
	ld   a, [de]	; Read byte1 of entry
	ld   [hl], a	; Write to iPlInfo_MaxPowBGPtr_High
	ret
Play_MaxPowBGPtrTbl_1P:
	dw $9CA4 ; PLAY_MAXMODE_LENGTH1
	dw $9CA3 ; PLAY_MAXMODE_LENGTH2
	dw $9CA2 ; PLAY_MAXMODE_LENGTH3
	dw $9CA1 ; PLAY_MAXMODE_LENGTH4
Play_MaxPowBGPtrTbl_2P:
	dw $9CAB ; PLAY_MAXMODE_LENGTH1
	dw $9CAB ; PLAY_MAXMODE_LENGTH2
	dw $9CAB ; PLAY_MAXMODE_LENGTH3
	dw $9CAB ; PLAY_MAXMODE_LENGTH4

; =============== Play_DrawFilledPowBar ===============
; Draws a completely filled POW bar.
; Meant to be used when redrawing the POW bar after Max POW mode ends,
; since it's always visually full the first frame (only to deplete immediately).
; IN
; - HL: Ptr to left corner of bar in tilemap
Play_DrawFilledPowBar:

	; Left corner
	di
	mWaitForVBlankOrHBlank
	ld   a, TID_BAR_L
	ldi  [hl], a
	ei
	
	; Filled bar tiles
	ld   b, $05		; B = Bar length (5 tiles)
.loop:
	di
	mWaitForVBlankOrHBlank
	ld   a, TID_BAR_BASE
	ldi  [hl], a
	ei
	dec  b			; Copied all tiles?
	jp   nz, .loop	; If not, loop
	
	; Right corner
	di
	mWaitForVBlankOrHBlank
	ld   a, TID_BAR_R
	ldi  [hl], a
	ei
	ret
	
; =============== Play_DrawMaximumText ===============
; Draws the "MAXIMUM" text, replacing a normal POW bar.
; IN
; - HL: Ptr to tilemap
Play_DrawMaximumText:
	di
	mWaitForVBlankOrHBlank
	ld   a, $D8 ; M
	ldi  [hl], a
	mWaitForVBlankOrHBlank
	ld   a, $D9 ; A
	ldi  [hl], a
	mWaitForVBlankOrHBlank
	ld   a, $DA ; X
	ldi  [hl], a
	mWaitForVBlankOrHBlank
	ld   a, $DB ; IM
	ldi  [hl], a
	mWaitForVBlankOrHBlank
	ld   a, $DC ; M
	ldi  [hl], a
	mWaitForVBlankOrHBlank
	ld   a, $DD ; U
	ldi  [hl], a
	mWaitForVBlankOrHBlank
	ld   a, $DE ; M
	ld   [hl], a
	ei
	ret
	
	
; =============== Play_DoTime ===============
; Handles the round timer during gameplay.
Play_DoTime:

	;
	; There's a gauntlet of checks before we're allowed to draw the timer or decrement a timer digit.
	;
	
	ld   a, [wRoundTime]
	or   a						; Time Over?
	jp   z, Play_NoDrawTime		; If so, return
	cp   TIMER_INFINITE			; Is the timer set to infinite?
	jp   z, Play_NoDrawTime		; If so, return
	
	; If any player lost (has no health), constantly redraw the current time
	ld   a, [wPlInfo_Pl1+iPlInfo_Health]
	or   a						
	jp   z, Play_DrawTime
	ld   a, [wPlInfo_Pl2+iPlInfo_Health]
	or   a
	jp   z, Play_DrawTime
	
	; If we're in a scene with controls disabled (ie: intro), return
	ld   hl, wMisc_C027
	bit  MISCB_PLAY_STOP, [hl]
	jp   nz, Play_NoDrawTime
	
	; Decrement subsecond counter.
	; If it reaches 0, jump and decrement the seconds too.
	ld   hl, wRoundTimeSub
	dec  [hl]
	jp   z, .decTime
	
	; The rest is to handle the timer flashing with 10 or less seconds.
	ld   a, [wRoundTime]
	cp   $11				; Timer < 11?
	jp   c, .flashTime			; If so, jump
	jp   Play_NoDrawTime	; Otherwise, return
.flashTime:
	; Show/hide the timer every 4 frames
	ld   a, [wPlayTimer]
	bit  2, a				; wPlayTimer & 4 == 0?
	jp   nz, .flashTimeShow	; If not, jump
.flashTimeHide:
	; Replace the two timer digits in the tilemap with blank tiles
	ld   hl, vBGRoundTime
	di
	mWaitForVBlankOrHBlank
	xor  a
	ldi  [hl], a
	mWaitForVBlankOrHBlank
	xor  a
	ld   [hl], a
	ei
	jp   Play_NoDrawTime
.flashTimeShow:
	; Redraw the timer normally
	jp   Play_DrawTime
.decTime:
	; wRoundTime--
	ld   a, [wRoundTime]
	sub  a, $01
	daa
	ld   [wRoundTime], a
	; Reset counter to 60 frames
	ld   a, 60
	ld   [wRoundTimeSub], a
	jp   Play_DrawTime
	
; =============== Play_DrawTime ===============
; Draws the round timer in the HUD.
Play_DrawTime:
	ld   hl, vBGRoundTime			; HL = Ptr to high digit in the tilemap
	
	;
	; Get the tile ID for the upper nybble.
	; As the round timer is in BCD format, it can be done by isolating the upper nybble
	; and then using it as index to a number -> tileID table.
	;
	
	ld   a, [wRoundTime]		; A  = Time
	ld   de, Play_HUDTileIdTbl	; DE = Tile ID table
	; Generate index
	swap a				; A = A >> 4
	and  a, $0F	 
	; Index the map table
	add  a, e			; DE += A
	ld   e, a
	; Write it to the tilemap
	di
	mWaitForVBlankOrHBlank
	ld   a, [de]		; Read tile ID
	ldi  [hl], a		; Write it over, VRAMPtr++
	ei
	
	;
	; Do the same for the lower digit.
	;
	ld   a, [wRoundTime]		; A  = Time
	ld   de, Play_HUDTileIdTbl	; DE = Tile ID table
	; Generate index
	and  a, $0F			; A = A & $0F
	; Index the map table
	add  a, e			; DE += A
	ld   e, a
	; Write it to the tilemap
	di
	mWaitForVBlankOrHBlank
	ld   a, [de]		; Read tile ID
	ld   [hl], a		; Write it over
	ei
	; Fall-through
	
; =============== Play_NoDrawTime ===============
; Target used to skip writing the time.
Play_NoDrawTime:
	ret
	
; =============== Play_UpdateHUDHitCount ===============
; Checks if the number of combo hits to the HUD should be updated.
Play_UpdateHUDHitCount:

	;
	; Note that the hit counter is displayed to the OTHER player's side.
	;
	; This is because we want to display how many hits a player dishes out, however what
	; the hit count variable actually tracks is how many hits the player *received*.
	;
	; ie: the iPlInfo_HitComboRecv field on 1P tracks 2P's combo.
	;
	
	; Don't redraw the hit combo counter if the current value didn't change.
	ld   hl, $9C6B									; HL = Ptr to tilemap (2P side)
	ld   a, [wPlInfo_Pl1+iPlInfo_HitComboRecv]		; B = Previous hit count
	ld   b, a
	ld   a, [wPlInfo_Pl1+iPlInfo_HitComboRecvSet]	; A = New hit count
	cp   a, b										; Do they match?
	jp   z, .noChg1P								; If so, jump
.chg1P:
	; Otherwise, update the tilemap.
	ld   [wPlInfo_Pl1+iPlInfo_HitComboRecv], a
	call Play_DrawHitCountBG
	jp   .chk2P
.noChg1P:
	; Weirdly, the check to clear the combo counter is done here,
	; when HitComboRecv and HitComboRecvSet don't match.
	; This causes it to execute and redraw the screen every time the hit counter is $02,
	; instead of only doing it when HitComboRecvSet changes.
	cp   $02					; NewCount >= $02?
	jp   nc, .chk2P				; If so, jump
	call Play_BlankHitCountBG	; Otherwise, wipe the hit counter.
.chk2P:

	;
	; Same thing for Player 2
	;
	ld   hl, $9C65									; HL = Ptr to tilemap (1P side)
	ld   a, [wPlInfo_Pl2+iPlInfo_HitComboRecv]		; B = Previous hit count
	ld   b, a										
	ld   a, [wPlInfo_Pl2+iPlInfo_HitComboRecvSet]	; A = New hit count
	cp   a, b										; Do they match?
	jp   z, .noChg2P								; If so, jump
.chg2P:
	; Otherwise, update the tilemap.
	ld   [wPlInfo_Pl2+iPlInfo_HitComboRecv], a
	call Play_DrawHitCountBG
	jp   .end
.noChg2P:
	cp   $02					; NewCount >= $02?
	jp   nc, .end				; If so, jump
	call Play_BlankHitCountBG	; Otherwise, wipe the hit counter.
.end:
	ret
	
; =============== Play_DrawHitCountBG ===============
; Draws the hit count to the specified location, if possible.
; This is in the format of "nnHIT".
; IN
; - HL: Destination ptr to tilemap
; -  A: Hit count
Play_DrawHitCountBG:
	; Don't draw if the hit count is less than 2.
	cp   $02
	jp   c, .ret
	
	;
	; Draw upper digit (high nybble)
	;
	push af	; Save full digit
		; Separate the high nybble and use it as index
		; to a table mapping numbers to tile IDs.
		ld   de, Play_HUDTileIdTbl	; DE = Ptr to Tile ID table
		swap a			; A = A >> 4
		and  a, $0F
		; Index the table
		add  a, e		; DE += A
		ld   e, a
		di
		mWaitForVBlankOrHBlank
		ld   a, [de]	; Read tile ID from entry
		ldi  [hl], a	; Write it over, move right in tilemap
		ei
	pop  af	; Restore full digit
	
	;
	; Draw lower digit (low nybble)
	;
	ld   de, Play_HUDTileIdTbl	; DE = Ptr to Tile ID table
	and  a, $0F					; A = A & $0F
	add  a, e					; DE += A
	ld   e, a
	di
	mWaitForVBlankOrHBlank
	ld   a, [de]				; Read tile ID from entry
	ldi  [hl], a				; Write it over, move right in tilemap
	ei
	
	;
	; Draw "HIT" (2 tiles)
	;
	ld   de, BG_Play_HUDHit		; DE = Ptr to BG
	ld   b, $02					; B = BG Length
.loop:
	di
	mWaitForVBlankOrHBlank
	ld   a, [de]				; Read tile ID
	ldi  [hl], a				; Write it over, move right in tilemap
	ei
	inc  de						; Next tile ID
	dec  b						; Are we done?
	jp   nz, .loop				; If not, loop
.ret:
	ret
; =============== Play_DrawHitCountBG ===============
; Erases the hit count with black tiles from the specified location.
; IN
; - HL: Destination ptr to tilemap
Play_BlankHitCountBG:
	; Clear the bytes from HL to HL+3
	ld   a, $00		; A = TileID of black tile
	ld   b, $04		; B = Tiles to clear
.loop:
	push af
		di
		mWaitForVBlankOrHBlank
	pop  af
	ldi  [hl], a				; Blank tile, move right in tilemap
	ei	
	dec  b						; Are we done?
	jp   nz, .loop				; If not, loop
	ret
	
; =============== Play_WriteKeysToBuffer ===============
; Updates the input buffers for both players.
Play_WriteKeysToBuffer:
	; Human player only
	ld   hl, wPlInfo_Pl1+iPlInfo_Flags0
	bit  PF0B_CPU, [hl]
	jr   nz, .chk2P
	call Play_WriteDirKeysToBuffer1P
	call Play_WriteBtnKeysToBuffer1P
.chk2P:
	; Same thing for 2P
	ld   hl, wPlInfo_Pl2+iPlInfo_Flags0
	bit  PF0B_CPU, [hl]
	jr   nz, .ret
	call Play_WriteDirKeysToBuffer2P
	call Play_WriteBtnKeysToBuffer2P
.ret:
	ret
	
; =============== mWriteDirKeysToBuffer ===============
; Generates code to write the held directional keys to its wPlInfo joypad buffer.
; IN
; - 1: Ptr to wPlInfo
; - 2: Ptr to wOBJInfo
mWriteDirKeysToBuffer: MACRO
	; DE = Offset to buffer entry
	;      This must be a multiple of 2 as each entry in this table
	;      is 2 bytes long (key, timer)
	ld   d, $00
	ld   a, [\1+iPlInfo_JoyDirBufferOffset]
	ld   e, a
	
	; Write the directional keys only
	; A = Held directional keys
	ld   a, [\1+iPlInfo_JoyKeys]
	and  a, $0F
	
	;
	; Invert the left/right inputs if we're (internally) facing right.
	; For consistency with the sprite display, move inputs are stored relative to players facing left (on the 2P side).
	; 
	ld   hl, \2+iOBJInfo_OBJLstFlags
	bit  SPRXB_PLDIR_R, [hl]	; Is 1P facing right?
	jr   z, .writeToBuf			; If not, jump
	
	; Don't invert input bits if neither L nor R are held
	ld   b, a					; Save orig inputs
	and  a, KEY_LEFT|KEY_RIGHT	; Holding either left or right?
	jr   z, .noLr				; If not, jump
	ld   a, b					; Restore input bits
	xor  KEY_LEFT|KEY_RIGHT		; Invert left/right inputs
	jr   .writeToBuf
.noLr:
	ld   a, b					; Restore orig inputs as there's nothing to invert
	
.writeToBuf:
	; Seek HL to the current buffer entry
	ld   hl, \1+iPlInfo_JoyDirBuffer
	add  hl, de			; HL = iPlInfo_JoyDirBuffer + iPlInfo_JoyDirBufferOffset
	
	; If the currently held d-pad keys are the same as what's in the buffer entry,
	; continue increasing its timer.
	cp   a, [hl]		; CurKeys == BufKeys?
	jr   z, .incTimer	; If so, jump

.newKey:	
	;
	; Seek to the next buffer entry.
	;
	
	; Generate the new buffer offset from the ptr, looping back to $00 when it goes past the buffer.
	; Index = (DE + 2) & $0F 
	;
	; This works due to the buffer being aligned to a specific address and for having a specific size.
	inc  e			; DE += 2 (next entry)
	inc  e
	push af			; E &= $0F (force in range/loop to $00 if needed)
		ld   a, e	
		and  a, $0F
		ld   e, a
	pop  af
	; Seek to the new offset 
	ld   hl, \1+iPlInfo_JoyDirBuffer
	add  hl, de
	
	; Write the new keys
	ld   [hl], a
	; Initialize the timer at 1
	inc  hl
	ld   [hl], $01
	
	; Save back the new buffer offset
	ld   a, e
	ld   [\1+iPlInfo_JoyDirBufferOffset], a
	ret
.incTimer:
	; Increase timer, maxing out at $FF
	inc  hl			; Seek to timer byte
	ld   a, [hl]	
	cp   $FF		; Timer == $FF?
	ret  z			; If so, return
	inc  [hl]		; Otherwise, Timer++
	ret
ENDM

; =============== mWriteBtnKeysToBuffer ===============
; Generates code to write the held button keys to its wPlInfo joypad buffer.
; See also: mWriteDirKeysToBuffer
; IN
; - 1: Ptr to player struct
mWriteBtnKeysToBuffer: MACRO

	; This uses its own buffer, separate from the one with directional keys.

	; DE = Offset to buffer entry
	ld   d, $00
	ld   a, [\1+iPlInfo_JoyBtnBufferOffset]
	ld   e, a
	; Write the directional keys only
	ld   a, [\1+iPlInfo_JoyKeys]
	and  a, KEY_A|KEY_B
	
	; (the buttons aren't afffected by facing left/right for obvious reasons, so direct skip to .writeToBuf)
.writeToBuf:
	; Seek HL to the current buffer entry
	ld   hl, \1+iPlInfo_JoyBtnBuffer
	add  hl, de
	
	; If the currently held buttons are the same as what's in the buffer entry,
	; continue increasing its timer.
	cp   a, [hl]		; CurKeys == BufKeys?
	jr   z, .incTimer	; If so, jump
	
.newKey:	
	;
	; Seek to the next buffer entry, exactly like in the other function.
	;
	
	; Index = (DE + 2) & $0F  
	inc  e
	inc  e
	push af
		ld   a, e
		and  a, $0F
		ld   e, a
	pop  af
	
	; Seek to the new offset 
	ld   hl, \1+iPlInfo_JoyBtnBuffer
	add  hl, de
	
	; Write the new keys
	ld   [hl], a
	; Initialize the timer at 1
	inc  hl
	ld   [hl], $01
	
	; Save back the new buffer offset
	ld   a, e
	ld   [\1+iPlInfo_JoyBtnBufferOffset], a
	ret
.incTimer:
	; Increase timer, maxing out at $FF
	inc  hl			; Seek to timer byte
	ld   a, [hl]	
	cp   $FF		; Timer == $FF?
	ret  z			; If so, return
	inc  [hl]		; Otherwise, Timer++
	ret
ENDM

Play_WriteDirKeysToBuffer1P: mWriteDirKeysToBuffer wPlInfo_Pl1, wOBJInfo_Pl1
Play_WriteDirKeysToBuffer2P: mWriteDirKeysToBuffer wPlInfo_Pl2, wOBJInfo_Pl2
Play_WriteBtnKeysToBuffer1P: mWriteBtnKeysToBuffer wPlInfo_Pl1
Play_WriteBtnKeysToBuffer2P: mWriteBtnKeysToBuffer wPlInfo_Pl2
; =============== END OF BANK ===============
; Junk area below with incomplete copies of the above subroutines.
IF REV_VER_2 == 0
	mIncJunk "L017FA8"
ELSE
	mIncJunk "L017F98"
ENDC