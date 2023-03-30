; =============== MoveC_Base_AttackG_SF04M0040 ===============
; Generic move code used for A+B ground attacks that move the player forward at 4px/frame,
; which slowly decreases by 40 subpixels every frame.
MoveC_Base_AttackG_SF04M0040:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .anim					; Do nothing special on #0
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim ; We never get here
; --------------- frame #1 ---------------
; When switching to frame #2, get manual control of the animation.
.obj1:
	mMvC_ValFrameEnd .anim
	mMvC_SetAnimSpeed ANIMSPEED_NONE
	jp   .anim
; --------------- frame #2 ---------------	
.chkEnd:
	; A+B attacks move the player forward at 4px/frame, which slowly decreases by 40 subpixels every frame.
	; The move ends when we stop moving completely.
	
	
	; The first time we get here, set the initial speed
	mMvC_ValFrameStart .tryEnd
	; Play SFX for it
	ld   a, SCT_MOVEJUMP_A
	call HomeCall_Sound_ReqPlayExId
	; Move 4px/frame forward
	mMvC_SetSpeedH $0400
	jp   .anim
.tryEnd:
	; From the second time, decrease the speed until we stop moving.
	mMvC_DoFrictionH $0040						; Decrease by $00.40px/frame	; Is our X speed already 0?
	jp   nc, .anim						; If not, continue
	call Play_Pl_EndMove				; Otherwise, we're done
	jr   .ret
; --------------- common ---------------	
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveInputReader_Kyo ===============
; Special move input checker for KYO.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
; OUT
; - C flag: If set, a move was started
MoveInputReader_Kyo:
	mMvIn_Validate Kyo
	
; AIR SPECIALS
.chkAir:
	jp   MoveInputReader_Kyo_NoMove
	
; GROUND SPECIALS
.chkGround:
	;             SELECT + B                       SELECT + A
	mMvIn_ChkEasy MoveInit_Kyo_UraOrochiNagi, MoveInit_Kyo_NueTumi
	mMvIn_ChkGA Kyo, .chkPunch, .chkKick
	
.chkPunch:
	mMvIn_ValSuper .chkPunchNoSuper
	; DBDF+P -> Ura 108 Shiki Orochi Nagi
	mMvIn_ChkDir MoveInput_DBDF, MoveInit_Kyo_UraOrochiNagi
.chkPunchNoSuper:
	; FDF+P -> 100 Shiki Oni Yaki
	mMvIn_ChkDir MoveInput_FDF, MoveInit_Kyo_OniYaki
	; DF+P -> 114 Shiki Ara Kami
	mMvIn_ChkDir MoveInput_DF, MoveInit_Kyo_AraKami
	; DB+P -> 910 Shiki Nue Tumi
	mMvIn_ChkDir MoveInput_DB, MoveInit_Kyo_NueTumi
	; End
	jp   MoveInputReader_Kyo_NoMove
	
.chkKick:
	; FDB+K -> 212 Shiki Kototsuki You 
	mMvIn_ChkDir MoveInput_FDB, MoveInit_Kyo_KototsukiYou
	; BDB+K -> R.E.D. Kick
	mMvIn_ChkDir MoveInput_BDB, MoveInit_Kyo_RedKick
	; DF+K -> 75 Shiki Kai
	mMvIn_ChkDir MoveInput_DF, MoveInit_Kyo_Kai
	; End
	jp   MoveInputReader_Kyo_NoMove
	
; =============== MoveInit_Kyo_AraKami ===============
MoveInit_Kyo_AraKami:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_KYO_ARA_KAMI_L, MOVE_KYO_ARA_KAMI_H
	call MoveInputS_SetSpecMove_StopSpeed
	; Block mids/overheads at first when getting hit out of this
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_GUARD, [hl]		; Allow transition to block anim
	res  PF1B_CROUCH, [hl]		; For anything but lows
	jp   MoveInputReader_Kyo_MoveSet
	
; =============== MoveInit_Kyo_OniYaki ===============	
MoveInit_Kyo_OniYaki:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_KYO_ONIYAKI_L, MOVE_KYO_ONIYAKI_H
	call MoveInputS_SetSpecMove_StopSpeed
	; Same as above
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_GUARD, [hl]
	res  PF1B_CROUCH, [hl]
	jp   MoveInputReader_Kyo_MoveSet
	
; =============== MoveInit_Kyo_RedKick ===============	
MoveInit_Kyo_RedKick:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_KYO_RED_KICK_L, MOVE_KYO_RED_KICK_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Kyo_MoveSet
	
; =============== MoveInit_Kyo_KototsukiYou ===============	
MoveInit_Kyo_KototsukiYou:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_KYO_KOTOTSUKI_YOU_L, MOVE_KYO_KOTOTSUKI_YOU_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Kyo_MoveSet
	
; =============== MoveInit_Kyo_Kai ===============	
MoveInit_Kyo_Kai:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_KYO_KAI_L, MOVE_KYO_KAI_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Kyo_MoveSet
	
; =============== MoveInit_Kyo_NueTumi ===============	
MoveInit_Kyo_NueTumi:
	ld   hl, iPlInfo_Kyo_NueTumi_AutoguardShakeDone
	add  hl, bc
	ld   [hl], $00
	
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_KYO_NUE_TUMI_L, MOVE_KYO_NUE_TUMI_H
	call MoveInputS_SetSpecMove_StopSpeed
	
	ld   hl, iPlInfo_Flags2
	add  hl, bc
	set  PF2B_AUTOGUARDLOW, [hl]
	jp   MoveInputReader_Kyo_MoveSet
	
; =============== MoveInit_Kyo_UraOrochiNagi ===============
MoveInit_Kyo_UraOrochiNagi:
	call Play_Pl_ClearJoyDirBuffer
IF REV_VER_2 == 0
	mMvIn_GetSD MOVE_KYO_URA_OROCHI_NAGI_S, MOVE_KYO_URA_OROCHI_NAGI_D
ELSE
	; [POI] Hidden version of the move added in the English version.
	mMvIn_GetSDE MOVE_KYO_URA_OROCHI_NAGI_S, MOVE_KYO_URA_OROCHI_NAGI_D, MOVE_KYO_URA_OROCHI_NAGI_E
ENDC
	call MoveInputS_SetSpecMove_StopSpeed
	
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	set  PF0B_PROJREM, [hl]
	jp   MoveInputReader_Kyo_MoveSet
	
; =============== MoveInputReader_Kyo_MoveSet ===============
; Return value when a move was started.
; OUT
; - C flag: Set, to mark the result
MoveInputReader_Kyo_MoveSet:
	scf
	ret
; =============== MoveInputReader_Kyo_NoMove ===============
; Return value when no move was started.
; OUT
; - C flag: Clear, to mark the result
MoveInputReader_Kyo_NoMove:
	or   a
	ret
	
; =============== MoveC_Kyo_AraKami ===============
; Move code for Kyo's 114 Shiki Ara Kami (MOVE_KYO_ARA_KAMI_L).
; This move can optionally trigger separate "submoves", which are accessed by 
; jumping to a specific animation frame as they are part of the animation sequence.
; Therefore this move also contains:
; - 128 Shiki Kono Kizu
; - 127 Shiki Yano Sabi
; - 125 Shiki Nana Se
; - Ge Shiki Migiri Ugachi
MoveC_Kyo_AraKami:
	call Play_Pl_AddToJoyBufKeysLH
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .araKami_obj0
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .araKami_obj1
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .araKami_obj2
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .araKami_obj3
	
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .konoKizu_obj0
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .konoKizu_obj1
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .konoKizu_obj1
	cp   $07*OBJLSTPTR_ENTRYSIZE
	jp   z, .konoKizu_obj3
	
	cp   $08*OBJLSTPTR_ENTRYSIZE
	jp   z, .yanoSabi_obj0
	cp   $09*OBJLSTPTR_ENTRYSIZE
	jp   z, .yanoSabi_obj1
	cp   $0A*OBJLSTPTR_ENTRYSIZE
	jp   z, .yanoSabi_obj1
	cp   $0B*OBJLSTPTR_ENTRYSIZE
	jp   z, .yanoSabi_obj3
	
	cp   $0C*OBJLSTPTR_ENTRYSIZE
	jp   z, .konoKizu2_obj0
	cp   $0D*OBJLSTPTR_ENTRYSIZE
	jp   z, .konoKizu2_obj1
	cp   $0E*OBJLSTPTR_ENTRYSIZE
	jp   z, .konoKizu2_obj1
	cp   $0F*OBJLSTPTR_ENTRYSIZE
	jp   z, .konoKizu2_obj3
	
	cp   $10*OBJLSTPTR_ENTRYSIZE
	jp   z, .migiriUgachi_obj0
	cp   $11*OBJLSTPTR_ENTRYSIZE
	jp   z, .migiriUgachi_obj1
	cp   $12*OBJLSTPTR_ENTRYSIZE
	jp   z, .migiriUgachi_obj1
	cp   $13*OBJLSTPTR_ENTRYSIZE
	jp   z, .migiriUgachi_obj3
	
	cp   $14*OBJLSTPTR_ENTRYSIZE
	jp   z, .nanaSe_obj0
	cp   $15*OBJLSTPTR_ENTRYSIZE
	jp   z, .nanaSe_obj1
	
	cp   $16*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim ; We never get here
	
; --------------- 114 Shiki Ara Kami - frame #0 ---------------
.araKami_obj0:
	; Move forward 7px the first time we get here
	mMvC_ValFrameStart .araKami_obj0_chkEnd
		mMvC_SetMoveH $0700
.araKami_obj0_chkEnd:
	; Play SFX when switching to #2
	mMvC_ValFrameEnd .anim
		mMvC_PlaySound SFX_FIREHIT_A
		jp   .anim
; --------------- 114 Shiki Ara Kami - frame #1 ---------------
.araKami_obj1:
	; Move forward 7px and disable reduced damage the first time we get here
	mMvC_ValFrameStart .obj1_chkEnd
		mMvC_SetMoveH $0700
		ld   hl, iPlInfo_Flags1
		add  hl, bc
		res  PF1B_GUARD, [hl]	; Originally set by MoveInit_Kyo_AraKami
.obj1_chkEnd:
	; Does nothing
	mMvC_ValFrameEnd .anim
		jp   .anim
; --------------- 114 Shiki Ara Kami - input check macro ---------------	
mAraKami_ChkInpt: MACRO
	ld   hl, iPlInfo_JoyNewKeysLH
	add  hl, bc
	ld   a, [hl]
	bit  KEPB_B_LIGHT, a		; Pressed LP?
	jr   nz, ._chkInput\@		; If so, jump
	jr   ._anim\@
._chkInput\@:
	; FDB+P (light) -> 127 Shiki Yano Sabi
	mMvIn_ChkDir MoveInput_FDB, .startYanoSabi
	; DF+P (light) -> 128 Shiki Kono Kizu 
	mMvIn_ChkDir MoveInput_DF, .startKonoKizu 
._anim\@:
ENDM
; --------------- 114 Shiki Ara Kami - frame #2 ---------------
; Input checks.
.araKami_obj2:
	mAraKami_ChkInpt
	jp   .anim
; --------------- 114 Shiki Ara Kami - frame #3 ---------------
; Exactly like #2 to give a larger window for performing the inputs.
; If none of the inputs are performed, the move ends immediately (.setLastFrame).
; This is a common thing across these moves, with frame #3 being almost identical to the previous one.
.araKami_obj3:
	mAraKami_ChkInpt
	mMvC_ValFrameEnd .anim
		jp   .setLastFrame
	
; --------------- 128 Shiki Kono Kizu - frame #0 ---------------
.konoKizu_obj0:
	; Move forward 7px the first time we get here.
	mMvC_ValFrameStart .konoKizu_obj0_anim
		mMvC_SetMoveH $0700
.konoKizu_obj0_anim:
	; Nothing here
	mMvC_ValFrameEnd .anim
		jp   .anim
; --------------- 128 Shiki Kono Kizu - input check macro ---------------
mKonoKizu_ChkInput: MACRO
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	bit  PF0B_CPU, [hl]			; Current player is a CPU?
	jp   z, ._human\@			; If not, jump
._cpu\@:
	; The CPU randomly chooses what to do.
	;
	; Since this is executed for multiple frames, the global timer may increase
	; in a way that the new submove gets triggered.
	; (ie: what the first time we get here may jump to _anim\@, in the next time may jump to _startNanaSe\@)
	ld   a, [wTimer]
	bit  4, a					; wTimer & $10 == 0?
	jp   z, ._anim\@			; If so, don't do anything
	bit  0, a					; wTimer & $01 == 0?
	jp   z, ._startNanaSe\@		; If so, start 125 Shiki Nana Se
	jp   ._startYanoSabi\@		; Otherwise, start 
._human\@:
	; Human players need to press a single button to continue the move.
	ld   hl, iPlInfo_JoyNewKeysLH
	add  hl, bc
	ld   a, [hl]
	; A -> 125 Shiki Nana Se
	bit  KEPB_A_LIGHT, a		; Pressed light kick?
	jr   nz, ._startNanaSe\@	; If so, jump
	; B -> 127 Shiki Yano Sabi 
	bit  KEPB_B_LIGHT, a		; Pressed light punch?
	jr   nz, ._startYanoSabi\@	; If so, jump
	jr   ._anim\@
._startYanoSabi\@:
	jp   .startYanoSabiFromKonoKizu
._startNanaSe\@:
	jp   .startNanaSe
._anim\@:
ENDM
; --------------- 128 Shiki Kono Kizu - frames #1-2 ---------------
.konoKizu_obj1:
	mKonoKizu_ChkInput
	jp   .anim
; --------------- 128 Shiki Kono Kizu - frame #3 ---------------
; Identical to #2 except the move ends if no inputs are performed.
.konoKizu_obj3:
	mKonoKizu_ChkInput
	mMvC_ValFrameEnd .anim
		jp   .setLastFrame
	
; --------------- 127 Shiki Yano Sabi - frame #0 ---------------
.yanoSabi_obj0:
	; Move forward 7px the first time we get here.
	mMvC_ValFrameStart .yanoSabi_obj0_anim
		mMvC_SetMoveH $0700
.yanoSabi_obj0_anim:
	; Nothing here
	mMvC_ValFrameEnd .anim
		jp   .anim
; --------------- 127 Shiki Yano Sabi - input check macro ---------------
mYanoSabi_ChkInpt: MACRO
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	bit  PF0B_CPU, [hl]
	jp   z, ._human\@
._cpu\@:
	; The CPU randomly chooses what to do.
	ld   a, [wTimer]
	bit  4, a						; wTimer & $10 == 0?
	jp   z, ._anim\@				; If so, don't do anything
	bit  0, a						; wTimer & $01 == 0?
	jp   z, ._startNanaSe\@			; If so, jump
	jp   ._startMigiriUgachi\@
._human\@:
	; Human players need to press a single button to continue the move.
	ld   hl, iPlInfo_JoyNewKeysLH
	add  hl, bc
	ld   a, [hl]
	; A -> 125 Shiki Nana Se
	bit  KEPB_A_LIGHT, a			; Pressed light kick?
	jr   nz, ._startNanaSe\@		; If so, jump
	; B -> Ge Shiki Migiri Ugachi
	bit  KEPB_B_LIGHT, a			; Pressed light punch?
	jr   nz, ._startMigiriUgachi\@	; If so, jump
	jr   ._anim\@
._startMigiriUgachi\@:
	jp   .startMigiriUgachi
._startNanaSe\@:
	jp   .startNanaSe
._anim\@:
ENDM
; --------------- 127 Shiki Yano Sabi - frame #1-2 ---------------
; Input checks.
.yanoSabi_obj1:
	mYanoSabi_ChkInpt
	jp   .anim
; --------------- 127 Shiki Yano Sabi - frame #3 ---------------
; Like #2, except the move ends if no inputs are pressed.
.yanoSabi_obj3:
	mYanoSabi_ChkInpt
	mMvC_ValFrameEnd .anim
		jp   .setLastFrame
	
; --------------- 128 Shiki Kono Kizu (from 128 Shiki Kono Kizu) - frame #0 ---------------
; Version of the move which doesn't allow comboing into anything else.
.konoKizu2_obj0:
	; Move forward 7px the first time we get here
	mMvC_ValFrameStart .konoKizu2_obj0_anim
		mMvC_SetMoveH $0700
.konoKizu2_obj0_anim:
	mMvC_ValFrameEnd .anim
		jp   .anim
; --------------- 128 Shiki Kono Kizu (from 128 Shiki Kono Kizu) - frame #1-2 ---------------
.konoKizu2_obj1:
	; Do nothing but wait
	jp   .anim
; --------------- 128 Shiki Kono Kizu (from 128 Shiki Kono Kizu) - frame #3 ---------------
.konoKizu2_obj3:
	; End the move when the frame ends
	mMvC_ValFrameEnd .anim
		jp   .setLastFrame
	
; --------------- Ge Shiki Migiri Ugachi - frame #0 ---------------
; Move forward 7px the first time we get here
.migiriUgachi_obj0:
	; Move forward 7px the first time we get here
	mMvC_ValFrameStart .migiriUgachi_obj0_anim
		mMvC_SetMoveH $0700
.migiriUgachi_obj0_anim:
	mMvC_ValFrameEnd .anim
		jp   .anim
; --------------- Ge Shiki Migiri Ugachi - frame #1-2 ---------------
.migiriUgachi_obj1:
	; Do nothing but wait
	jp   .anim
; --------------- Ge Shiki Migiri Ugachi - frame #3 ---------------
.migiriUgachi_obj3:
	; End the move when the frame ends
	mMvC_ValFrameEnd .anim
		jp   .setLastFrame
	
; --------------- 125 Shiki Nana Se - frame #0 ---------------
; Move forward 7px the first time we get here
.nanaSe_obj0:
	; Move forward 7px the first time we get here
	mMvC_ValFrameStart .nanaSe_obj0_setSpeed
		mMvC_SetMoveH $0700
.nanaSe_obj0_setSpeed:
	; Set speed to $08 before switching to #2
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $08
		jp   .anim
; --------------- 125 Shiki Nana Se - frame #2 ---------------
.nanaSe_obj1:
	; Move forward 7px the first time we get here
	mMvC_ValFrameStart .nanaSe_obj1_chkEnd
		mMvC_SetMoveH $0700
.nanaSe_obj1_chkEnd:
	; End the move when the frame ends
	mMvC_ValFrameEnd .anim
		jp   .setLastFrame
	
; --------------- submoves ---------------

; Starts 128 Shiki Kono Kizu
.startKonoKizu:
	mMvC_SetDamageNext $08, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_LASTHIT
	mMvC_SetFrame $04*OBJLSTPTR_ENTRYSIZE, $00
	mMvC_PlaySound SFX_FIREHIT_A
	jp   .ret
	
; Starts 127 Shiki Yano Sabi
.startYanoSabi:
	mMvC_SetDamageNext $08, HITTYPE_DROP_DB_A, PF3_HEAVYHIT|PF3_FIRE|PF3_OVERHEAD|PF3_LASTHIT
	mMvC_SetFrame $08*OBJLSTPTR_ENTRYSIZE, $00
	mMvC_PlaySound SFX_FIREHIT_A
	jp   .ret
; Starts 127 Shiki Yano Sabi from 128 Shiki Kono Kizu
.startYanoSabiFromKonoKizu:
	mMvC_SetDamageNext $08, HITTYPE_DROP_DB_A, PF3_HEAVYHIT|PF3_FIRE|PF3_OVERHEAD|PF3_LASTHIT
	mMvC_SetFrame $0C*OBJLSTPTR_ENTRYSIZE, $00
	mMvC_PlaySound SFX_FIREHIT_A
	jp   .ret
	
; Starts Ge Shiki Migiri Ugachi
.startMigiriUgachi:
	mMvC_SetDamageNext $08, HITTYPE_DROP_DB_A, PF3_HEAVYHIT|PF3_FIRE|PF3_LASTHIT
	mMvC_SetFrame $10*OBJLSTPTR_ENTRYSIZE, $00
	mMvC_PlaySound SFX_FIREHIT_A
	jp   .ret
	
; Starts 125 Shiki Nana Se
.startNanaSe:
	mMvC_SetDamageNext $08, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_LASTHIT
	mMvC_SetFrame $14*OBJLSTPTR_ENTRYSIZE, $00
	mMvC_PlaySound SFX_FIREHIT_A
	jp   .ret
	
; --------------- common ---------------
.setLastFrame:
	; Switches to the last frame of the animation, when the move ends
	mMvC_SetFrame $16*OBJLSTPTR_ENTRYSIZE, $01
		jp   .ret
; --------------- frame #16 ---------------
.chkEnd:
	; When the animation tries to loop, end the move
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Kyo_AraKami ===============
; Move code for Kyo's 115 Shiki Doku Kami (MOVE_KYO_ARA_KAMI_H).
; Contains these submoves:
; - 401 Shiki Tumi Yomi 
; - 402 Shiki Batu Yomi 
MoveC_Kyo_DokuKami:
	call Play_Pl_AddToJoyBufKeysLH
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .dokuKami_obj0
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .dokuKami_obj1
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .dokuKami_obj2
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .dokuKami_obj3
	
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .tumiYomi_obj0
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .tumiYomi_obj1
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .tumiYomi_obj2
	
	cp   $07*OBJLSTPTR_ENTRYSIZE
	jp   z, .batuYomi_obj0
	cp   $08*OBJLSTPTR_ENTRYSIZE
	jp   z, .batuYomi_obj1
	cp   $09*OBJLSTPTR_ENTRYSIZE
	jp   z, .batuYomi_obj2
	cp   $0A*OBJLSTPTR_ENTRYSIZE
	jp   z, .batuYomi_doGravity
	cp   $0B*OBJLSTPTR_ENTRYSIZE
	jp   z, .batuYomi_obj4
	
	cp   $0C*OBJLSTPTR_ENTRYSIZE
	jp   z, .earlyStop
	jp   .anim ; We never get here
	
; --------------- 115 Shiki Doku Kami - frame #0 ---------------
.dokuKami_obj0:
	; The first time we get here, move 7px forward
	mMvC_ValFrameStart .dokuKami_obj0_chkInput
		mMvC_SetMoveH $0700
		ld   hl, iPlInfo_Kyo_AraKami_SubInputMask	; Initialize this
		add  hl, bc
		ld   [hl], $00
.dokuKami_obj0_chkInput:
	; Check input for next submove
	call MoveC_Kyo_DokuKami_ChkTumiYomiInput
	; When switching to #1, play SFX
	mMvC_ValFrameEnd .anim
		mMvC_PlaySound SFX_FIREHIT_A
		jp   .anim
; --------------- 115 Shiki Doku Kami - frame #1 ---------------
.dokuKami_obj1:
	; Check input for next submove
	call MoveC_Kyo_DokuKami_ChkTumiYomiInput
	; The first time we get here, move 7px forward and disable reduced damage
	mMvC_ValFrameStart .dokuKami_obj1_anim
		mMvC_SetMoveH $0700
		ld   hl, iPlInfo_Flags1
		add  hl, bc
		res  PF1B_GUARD, [hl]
.dokuKami_obj1_anim:;J
	mMvC_ValFrameEnd .anim
		jp   .anim
; --------------- 115 Shiki Doku Kami - frame #2-3 input check macro ---------------
mDokuKami_ChkInput: MACRO
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	bit  PF0B_CPU, [hl]	; Current player is CPU?
	jp   z, ._human\@	; If not, jump
._cpu\@:
	; The CPU randomly chooses when/if to perform the submove, depending on the timer
	ld   a, [wTimer]
	bit  4, a					; wTimer & $10 == 0?
	jp   z, ._anim\@			; If so, jump
	jp   .startTumiYomi	; Otherwise, start the move
._human\@:
	; Check input for next submove
	call MoveC_Kyo_DokuKami_ChkTumiYomiInput
	
	; If we pressed all required inputs (order doesn't matter), start the next submove, so:
	; DB+P or P+DB -> 401 Shiki Tumi Yomi
	ld   hl, iPlInfo_Kyo_AraKami_SubInputMask
	add  hl, bc
	ld   a, [hl]
	bit  MSIB_K0S0_P, a		; Pressed P?
	jp   z, ._anim\@		; If not, skip
	bit  MSIB_K0S0_DB, a	; Pressed DB?
	jp   z, ._anim\@		; If not, skip
	jp   .startTumiYomi		; DB+P Ok
._anim\@:
ENDM
; --------------- 115 Shiki Doku Kami - frame #2 ---------------
.dokuKami_obj2:
	mDokuKami_ChkInput
	jp   .anim
; --------------- 115 Shiki Doku Kami - frame #3 ---------------
.dokuKami_obj3:
	mDokuKami_ChkInput
	; If the submove didn't start by the end of the frame, end the move early
	mMvC_ValFrameEnd .anim
		jp   .setLastFrame
	
; --------------- 401 Shiki Tumi Yomi - frame #0 ---------------	
.tumiYomi_obj0:
	; Check input for next submove
	call MoveC_Kyo_DokuKami_ChkBatuYomiInput
	; The first time we get here, move 7px forward
	mMvC_ValFrameStart .tumiYomi_obj0_anim
		mMvC_SetMoveH $0700
.tumiYomi_obj0_anim:
	; Nothing here
	mMvC_ValFrameEnd .anim
		jp   .anim
; --------------- 401 Shiki Tumi Yomi - frame #1-2 input check macro ---------------
mTumiYomi_ChkInput: MACRO
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	bit  PF0B_CPU, [hl]
	jp   z, ._human\@
._cpu\@:
	; The CPU randomly chooses when/if to perform the submove, depending on the timer
	ld   a, [wTimer]
	bit  4, a					; wTimer & $10 == 0?
	jp   z, ._anim\@			; If so, jump
	jp   .startBatuYomi	; Otherwise, start the move  
._human\@:
	; Check input for next submove
	call MoveC_Kyo_DokuKami_ChkBatuYomiInput
	
	; If we pressed the required input, start the next submove, so:
	; P or (previous DB+P) -> 402 Shiki Batu Yomi
	ld   hl, iPlInfo_Kyo_AraKami_SubInputMask
	add  hl, bc
	ld   a, [hl]
	bit  MSIB_K0S1_P, a
	jp   nz, .startBatuYomi
._anim\@:
ENDM	
; --------------- 401 Shiki Tumi Yomi - frame #1 ---------------	
.tumiYomi_obj1:
	mTumiYomi_ChkInput
	jp   .anim
; --------------- 401 Shiki Tumi Yomi - frame #2 ---------------	
.tumiYomi_obj2:
	mTumiYomi_ChkInput
	; If the submove didn't start by the end of the frame, end the move early
	mMvC_ValFrameEnd .anim
		jp   .setLastFrame
	
; --------------- 402 Shiki Batu Yomi - frame #0 ---------------	
.batuYomi_obj0:
	; Move 4px forward the first time we get here
	mMvC_ValFrameStart .batuYomi_obj0_cont
		mMvC_SetMoveH $0400
.batuYomi_obj0_cont:
	; When switching to #1, get manual control and play SFX
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		mMvC_PlaySound SFX_FIREHIT_A
		jp   .anim
; --------------- 402 Shiki Batu Yomi - frame #1 ---------------	
.batuYomi_obj1:
	; The first time we get here...
	mMvC_ValFrameStart .batuYomi_obj1_cont
		; Move 4px forward
		mMvC_SetMoveH $0400
		
		;--
		; [POI] This doesn't make sense and is pointless.
		ld   hl, iPlInfo_Flags0
		add  hl, bc
		res  PF0B_PROJHIT, [hl]
		;--
		
		; Initialize jump speed. Different settings are used at MAX Power.
		ld   hl, iPlInfo_Pow
		add  hl, bc
		ld   a, [hl]						; A = iPlInfo_Pow
		cp   PLAY_POW_MAX					; iPlInfo_Pow == PLAY_POW_MAX?
		jp   z, .batuYomi_obj1_setSpeedMax	; If so, jump
	.batuYomi_obj1_setSpeedNorm:
		mMvC_SetSpeedH +$0100 ; 1px/frame forward
		mMvC_SetSpeedV -$0400 ; 4px/frame up
		jp   .batuYomi_obj1_doGravity
	.batuYomi_obj1_setSpeedMax:
		mMvC_SetSpeedH +$0200 ; 2px/frame forward
		mMvC_SetSpeedV -$0400 ; 4px/frame up
	.batuYomi_obj1_doGravity:
		jp   .batuYomi_doGravity
.batuYomi_obj1_cont:
	; Advance animation when moving down faster than -2px/frame
	mMvC_NextFrameOnGtYSpeed -$02, ANIMSPEED_NONE
	; What
	jp   nc, .batuYomi_doGravity
	jp   .batuYomi_doGravity
; --------------- 402 Shiki Batu Yomi - frame #2 ---------------	
; Advance animation when moving down faster than -1px/frame
.batuYomi_obj2:
	mMvC_NextFrameOnGtYSpeed -$01, ANIMSPEED_NONE
	jp   .batuYomi_doGravity
; --------------- 402 Shiki Batu Yomi - frame #3 / common gravity check ---------------
; Move the player down at $00.60px/frame until touching the ground.
; When that happens, switch to frame $0B (#4) and disable manual control.
; As this is called for frames #1-3, touching the ground early will directly skip to #4.
.batuYomi_doGravity:
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $0B*OBJLSTPTR_ENTRYSIZE, $08
		jp   .ret
; --------------- 402 Shiki Batu Yomi - frame #4 ---------------
; Landing frame. When this ends, the move ends completely.
.batuYomi_obj4:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- submoves ---------------
; 401 Shiki Tumi Yomi
.startTumiYomi:
	mMvC_SetFrame $04*OBJLSTPTR_ENTRYSIZE, $00	; Was the frame set already?
	jp   z, .ret								; If so, return
	mMvC_SetDamageNext $08, HITTYPE_HIT_MID0, PF3_HEAVYHIT|PF3_FIRE|PF3_LASTHIT
	mMvC_PlaySound SFX_FIREHIT_A
	; Reset the LH status for the next keypress
	ld   hl, iPlInfo_JoyBufKeysLH
	add  hl, bc
	ld   [hl], $00
	jp   .ret
; 402 Shiki Batu Yomi
.startBatuYomi:
	mMvC_SetFrame $07*OBJLSTPTR_ENTRYSIZE, $00	; Was the frame set already?
	jp   z, .ret								; If so, return
	mMvC_SetDamageNext $08, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_LASTHIT
	mMvC_PlaySound SFX_FIREHIT_A
	; Reset the LH status for the next keypress (not needed)
	ld   hl, iPlInfo_JoyBufKeysLH
	add  hl, bc
	ld   [hl], $00
	jp   .ret
; --------------- common ---------------
.setLastFrame:
	mMvC_SetFrame $0C*OBJLSTPTR_ENTRYSIZE, $01
	jp   .ret
; --------------- frame #C ---------------
; Recovery frame used when the move ends before 402 Shiki Batu Yomi.
.earlyStop:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
; =============== MoveC_Kyo_DokuKami_ChkTumiYomiInput ===============
; Handles the input for the submove 401 Shiki Tumi Yomi.
; This requires pressing the inputs DB+P.
; If pressed in that order, the next submove 402 Shiki Batu Yomi is also confirmed.
MoveC_Kyo_DokuKami_ChkTumiYomiInput:
	; If we've already pressed P and DB, return.
	ld   hl, iPlInfo_Kyo_AraKami_SubInputMask
	add  hl, bc
	bit  MSIB_K0S0_P, [hl]	; Pressed LP yet?
	jp   z, .chkBtn			; If not, jump
	bit  MSIB_K0S0_DB, [hl]	; Pressed DB yet?
	jp   z, .chkBtn			; If not, jump
	jp   .ret				; Otherwise, return as we've done it already
.chkBtn:
	; Mark if we've pressed light punch.
	ld   hl, iPlInfo_JoyBufKeysLH
	add  hl, bc
	ld   a, [hl]
	bit  KEPB_B_LIGHT, a	; Did we press LP?
	jp   z, .chkInput		; If not, skip
	ld   hl, iPlInfo_Kyo_AraKami_SubInputMask
	add  hl, bc
	set  MSIB_K0S0_P, [hl]	; Sets its bit
.chkInput:
	; Mark if we've performed the DB input.
	mMvIn_ChkDirNot MoveInput_DB_Copy, .chkShortcut	; Did we press DB? If not, jump
	ld   hl, iPlInfo_Kyo_AraKami_SubInputMask
	add  hl, bc
	set  MSIB_K0S0_DB, [hl]	; Sets its bit
	; Reset the LH status for the next keypress
	ld   hl, iPlInfo_JoyBufKeysLH
	add  hl, bc
	ld   [hl], $00
	jp   .ret
.chkShortcut:
	;
	; Weird shortcut for confirming immediately both submoves when performing the DB+P input
	; by pressing P when the DB motion isn't detected as inputted.
	;
	; The window for doing this is very tight, as MoveInput checks keep a buffer of the last
	; few keypresses, so you'd have to perform the DB motion, quickly press other d-pad keys to
	; push it out of the buffer, and only then press P. 
	; 
	; This works due to a combination of:
	; - Only getting here when *not* pressing the DB move input.
	; - The current subroutine locking itself out when DB and P are pressed.
	; - The called subroutine not diing anything until DB and P are pressed.
	; 
	; If we were to input DB after P, we wouldn't be getting here, and further calls
	; to this subroutine would return immediately.
	; 
	; Pressing only P would get us here, but the called subroutine validates that both inputs were pressed.
	;
	call MoveC_Kyo_DokuKami_ChkBatuYomiInput
.ret:
	ret
; =============== MoveC_Kyo_DokuKami_ChkBatuYomiInput ===============
; Handles the input for the submove 402 Shiki Batu Yomi.
; This requires pressing P.
MoveC_Kyo_DokuKami_ChkBatuYomiInput:
	
	ld   hl, iPlInfo_Kyo_AraKami_SubInputMask
	add  hl, bc
	
	; If we didn't already perform the inputs for 401 Shiki Tumi Yomi, return.
	; This is because of the shortcut (see call above), as otherwise if we got to
	; 401 Shiki Tumi Yomi this validation always passes.
	bit  MSIB_K0S0_P, [hl]	; Pressed LP yet?
	jp   z, .ret			; If not, return
	bit  MSIB_K0S0_DB, [hl]	; Pressed DB yet?
	jp   z, .ret			; If not, return
	
	; If we pressed LP already, return
	bit  MSIB_K0S1_P, [hl]	; Pressed LP yet?
	jp   nz, .ret			; If so, return
	
	; If we're pressing LP, set its bit
	ld   hl, iPlInfo_JoyBufKeysLH
	add  hl, bc
	ld   a, [hl]
	bit  KEPB_B_LIGHT, a	; Pressed LP *now*?
	jp   nz, .orderOk		; If so, jump
	; Otherwise, return
	jp   .ret
.orderOk:
	; Set the bit
	ld   hl, iPlInfo_Kyo_AraKami_SubInputMask
	add  hl, bc
	set  MSIB_K0S1_P, [hl]
	; Reset the LH status for the next keypress
	ld   hl, iPlInfo_JoyBufKeysLH
	add  hl, bc
	ld   [hl], $00
.ret:
	ret
	
; =============== MoveC_Kyo_OniYaki ===============
; Move code for Kyo's 100 Shiki Oni Yaki (MOVE_KYO_ONIYAKI_L, MOVE_KYO_ONIYAKI_H).
MoveC_Kyo_OniYaki:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .anim
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj2
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj3
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj4
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .doGravity
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	
; --------------- frame #1 ---------------
; Invincible startup.
.obj1:
	; The first time we get here, move forward 4px
	mMvC_ValFrameStart .obj1_setSpeed
		mMvC_SetMoveH $0400
.obj1_setSpeed:
	; When switching to #2, get manual control (since advancing the animation will
	; depend on the Y speed / touching the ground) and set the move damage.
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		mMvC_PlaySound SFX_FIREHIT_A
		
		; Deal 4 lines of damage on contact.
		; Light and heavy do identical damage, there's no point in checking it.
		mMvIn_ChkLH .obj1_setDamageH
	.obj1_setDamageL:
		mMvC_SetDamageNext $04, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE
		jp   .anim
	.obj1_setDamageH:
		mMvC_SetDamageNext $04, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE
		jp   .anim
; --------------- frame #2 ---------------
; Starts the jump.
; Touching the ground at any point in this and the next few frames immediately jumps to the landing frame.
.obj2:
	; The first time we get here...
	mMvC_ValFrameStart .obj2_cont
		; Move 4px forward
		mMvC_SetMoveH $0400
		; Disable invulnerability
		ld   hl, iPlInfo_Flags0
		add  hl, bc
		inc  hl
		res  PF1B_INVULN, [hl]
		res  PF1B_GUARD, [hl]
		
		; Depending on the move strength, use different jump settings.
		mMvIn_ChkLHE .obj2_setJumpH, .obj2_setJumpE
	.obj2_setJumpL: ; Light
		mMvC_SetSpeedH +$0080
		mMvC_SetSpeedV -$0600
		jp   .obj2_doGravity
	.obj2_setJumpH: ; Heavy
		mMvC_SetSpeedH +$0100
		mMvC_SetSpeedV -$0700
		jp   .obj2_doGravity
	.obj2_setJumpE: ; [POI] Hidden heavy
		mMvC_SetSpeedH +$0200
		mMvC_SetSpeedV -$0800
	.obj2_doGravity:
		jp   .doGravity
.obj2_cont:
	;--
	; YSpeed will always be > -$0A, so this advances the animation immediately.
	mMvC_NextFrameOnGtYSpeed -$0A, ANIMSPEED_NONE
	jp   nc, .doGravity ; We never take the jump
	;--
	; Deal 4 lines of damage on contact.
	mMvIn_ChkLH .obj2_heavyDamage ; Pointless check, both are the same.
.obj2_lightDamage:
	mMvC_SetDamageNext $04, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE
	jp   .doGravity
.obj2_heavyDamage:
	mMvC_SetDamageNext $04, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE
	jp   .doGravity
; --------------- frame #3 ---------------
; Immediately advances the anim during the jump.
.obj3:
	mMvC_NextFrameOnGtYSpeed -$0A, ANIMSPEED_NONE
	jp   .doGravity
; --------------- frame #4 ---------------
; Set movement speed of $00.40px/frame forward while we're here.
; This is until YSpeed > 1.
.obj4:
	mMvC_NextFrameOnGtYSpeed +$01, ANIMSPEED_NONE
	mMvC_SetSpeedH $0040
	jp   .doGravity
; --------------- frame #5 / common gravity ---------------
; Move down until touching the ground. Switch to #6 on that.
.doGravity:
	; Move down $00.60px/frame
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $06*OBJLSTPTR_ENTRYSIZE, $0A
		jp   .ret
; --------------- frame #6 ---------------
; Landing frame.
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Kyo_RedKick ===============
; Move code for Kyo's R.E.D. Kick (MOVE_KYO_RED_KICK_L, MOVE_KYO_RED_KICK_H).
MoveC_Kyo_RedKick:
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
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .doGravity
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
; --------------- frame #0 ---------------
.obj0:
	;--
	; Not needed
	mMvC_ValFrameStart .obj0_setSpeed
.obj0_setSpeed:
	;--
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		mMvC_SetDamageNext $08, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_LASTHIT
	jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameStart .obj1_cont
		mMvC_PlaySound SCT_MOVEJUMP_B
		mMvIn_ChkLHE .obj1_jumpH, .obj1_jumpE
	.obj1_jumpL: ; Light
		mMvC_SetSpeedH +$0400
		mMvC_SetSpeedV -$0400
		jp   .obj1_doGravity
	.obj1_jumpH: ; Heavy
		mMvC_SetSpeedH +$0500
		mMvC_SetSpeedV -$0400
		jp   .obj1_doGravity
	.obj1_jumpE: ; [POI] Hidden heavy
		mMvC_SetSpeedH +$0600
		mMvC_SetSpeedV -$0400
	.obj1_doGravity:
		jp   .doGravity
.obj1_cont:
	; instant switch, -$04 is always > -$06
	mMvC_NextFrameOnGtYSpeed -$06, ANIMSPEED_NONE
	jp   nc, .doGravity
	jp   .doGravity
; --------------- frame #2 ---------------
.obj2:;J
	mMvC_NextFrameOnGtYSpeed -$02, ANIMSPEED_NONE
	jp   nc, .doGravity
	mMvC_SetDamageNext $08, HITTYPE_DROP_DB_A, PF3_HEAVYHIT
	jp   .doGravity
; --------------- frame #3 ---------------
.obj3:
	mMvC_NextFrameOnGtYSpeed -$01, ANIMSPEED_NONE
	jp   nc, .doGravity
	jp   .doGravity
; --------------- frame #4 / common gravity check ---------------
.doGravity:
	mMvC_ChkGravityHV $0060, .anim
	mMvC_SetLandFrame $05*OBJLSTPTR_ENTRYSIZE, $08
	jp   .ret
; --------------- frame #5 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
	call Play_Pl_EndMove
	jr   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Kyo_KototsukiYou ===============
; Move code for Kyo's 212 Shiki Kototsuki You (MOVE_KYO_KOTOTSUKI_YOU_L, MOVE_KYO_KOTOTSUKI_YOU_H).
; 2-hit run move.
MoveC_Kyo_KototsukiYou:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .runStart
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .run1
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .run2
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .run3
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .runEnd
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj5
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim ; We never get here
; --------------- frame #0 ---------------
; Run startup.
.runStart:
	; Set fast anim speed at the end of the frame.
	mMvC_ValFrameEnd .chkNearPl
		mMvC_SetAnimSpeed $01
		jp   .chkNearPl
; --------------- frame #1 ---------------
; First of the three run frames.
; All of these jump to .chkNearPl, and if the player doesn't get close to the opponent
; by the end of the third one, we switch to #4, where the player slows down and the move ends.
.run1:
	; Start the run at the start of the frame.
	mMvC_ValFrameStart .obj1_chkNearPl
		mMvC_PlaySound SFX_STEP
		; Set different run speed depending on move strength
		mMvIn_ChkLHE .obj1_setRunSpeedH, .obj1_setRunSpeedE
	.obj1_setRunSpeedL: ; Light
		mMvC_SetSpeedH +$0500
		jp   .moveH_anim
	.obj1_setRunSpeedH: ; Heavy
		mMvC_SetSpeedH +$0600
		jp   .moveH_anim
	.obj1_setRunSpeedE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH +$0700
		jp   .moveH_anim
.obj1_chkNearPl:
	jp   .chkNearPl
; --------------- frame #2 ---------------
; Run frame.
.run2:
	; Play step SFX at the start of the frame.
	mMvC_ValFrameStart .chkNearPl
		mMvC_PlaySound SFX_STEP
		jp   .chkNearPl
; --------------- frame #3 ---------------
; Run frame.
.run3:
	; Play step SFX at the start of the frame.
	mMvC_ValFrameStart .obj3_getManCtrl
		mMvC_PlaySound SFX_STEP
.obj3_getManCtrl:
	; Get manual control at the end of the frame, since it shouldn't advance to #5
	mMvC_ValFrameEnd .chkNearPl
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		jp   .moveH_anim
; --------------- frame #4 ---------------
; End of run (early abort).
; Set friction at 1px/frame, ending the move when we stop running.
.runEnd:
	mMvC_DoFrictionH +$0100
	jp   nc, .ret
	jp   .end
	
; --------------- distance check for run -> hit transition ---------------
.chkNearPl:
	; Continue running until we get close to the opponent.
	mMvIn_ValClose .moveH_anim
		mMvC_SetFrame $05*OBJLSTPTR_ENTRYSIZE, $01
		call OBJLstS_ApplyXSpeed
		jp   .ret
.moveH_anim:
	call OBJLstS_ApplyXSpeed
	jp   .anim
; --------------- frame #5 ---------------
; Collsion checker
.obj5:
	; Gradually slow down $00.80px/frame
	mMvC_DoFrictionH +$0080
	
	; End the run abruptly doing the second hit if, by the end of the frame, either:
	; - We didn't *attack* the opponent (ie: we got close, but our hitbox didn't overlap)
	; - The opponent is invincible
	ld   hl, iPlInfo_ColiFlags
	add  hl, bc
	bit  PCF_HITOTHER, [hl]		; Did the opponent get hit/blocked the attack?
	jp   z, .obj5_abort			; If not, end the run
	ld   hl, iPlInfo_Flags1Other
	add  hl, bc
	bit  PF1B_INVULN, [hl]		; Is the opponent invulnerable?
	jp   z, .obj5_setHit2		; If not, jump
.obj5_abort:					; Otherwise, end the run
	; but only before attempting to switch to #6
	mMvC_ValFrameEnd .anim
		jp   .end
.obj5_setHit2:
	; Immediately switch to the second attack frame.
	; The second hit will deal 8 lines of damage and drop him on the ground.
	mMvC_SetDamageNext $08, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE
	mMvC_SetFrame $06*OBJLSTPTR_ENTRYSIZE, $08
	jp   .ret
; --------------- frame #6 ---------------	
; Waits for the second hit to end. No recovery frame here.
.chkEnd:
	mMvC_ValFrameEnd .anim
	; Fall-through
; --------------- common ---------------	
.end:
	call Play_Pl_EndMove
	jp   .ret
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Kyo_Kai ===============
; Move code for Kyo's 75 Shiki Kai (MOVE_KYO_KAI_L, MOVE_KYO_KAI_H).
; Slide with small hop.
MoveC_Kyo_Kai:
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
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj4
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	
; --------------- frame #0 ---------------	
.obj0:
	mMvC_ValFrameStart .obj0_moveF
		mMvC_SetSpeedH +$0400
.obj0_moveF:
	mMvC_DoFrictionH $0070		; Did we stop moving?
	jp   nc, .anim							; If not, jump
	
	; Otherwise, switch to the next frame.
	ld   hl, iOBJInfo_FrameLeft
	add  hl, de
	ld   [hl], $00 ; Switch to next frame
	
	; And set the new animation speed.
	
	; The heavy version uses speed $01, allowing the move to animate as normal.
	; The light one instead uses ANIMSPEED_NONE. This prevents the animation from moving
	; past frame #1, and instead can only wait for the player landing on the ground.
	
	; What this means, in practice, is that the heavy version hits twice, since frame #2
	; sets new move damage values.
	
	mMvC_SetAnimSpeed $01		; Use fast anim for heavy
	
	ld   hl, iPlInfo_MoveId
	add  hl, bc
	ld   a, [hl]
	cp   MOVE_KYO_KAI_H	; Doing the heavy version?
	jp   z, .anim				; If so, jump
	; Otherwise, get manual control
	ld   hl, iOBJInfo_FrameTotal
	add  hl, de
	ld   [hl], ANIMSPEED_NONE
	jp   .anim
; --------------- frame #1 ---------------	
; Initialize the hop at the start
.obj1:
	mMvC_ValFrameStart .obj1_doGravity
		mMvC_PlaySound SCT_HEAVY
		mMvC_SetSpeedH +$0300
		mMvC_SetSpeedV -$0300
		jp   .doGravity
.obj1_doGravity:
	jp   .doGravity
; --------------- frame #4 ---------------
; Heavy attack only.
; Just waits the gravity.
.obj4:
	jp   .doGravity
; --------------- frame #2 ---------------	
; Heavy attack only.
; Set damage for 2nd hit when the frame ends.
.obj2:
	mMvC_ValFrameEnd .doGravity
		mMvC_SetDamageNext $08, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_LASTHIT
		mMvC_PlaySound SCT_HEAVY
		jp   .doGravity
; --------------- frame #3 ---------------
; Heavy attack only.
; Sets a slower horizontal speed for #4.
.obj3:
	mMvC_ValFrameEnd .doGravity
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		mMvC_SetSpeedH +$0080
		jp   .doGravity
; --------------- frames #1-#4 / common gravity check ---------------
; Switches to the landing frame when touching the ground.
.doGravity:
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $05*OBJLSTPTR_ENTRYSIZE, $08
		jp   .ret
; --------------- frame #5 ---------------	
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------	
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Kyo_NueTumi ===============
; Move code for Kyo's 910 Shiki Nue Tumi (MOVE_KYO_NUE_TUMI_L, MOVE_KYO_NUE_TUMI_H).
MoveC_Kyo_NueTumi:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	; #0-#3 main
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj0
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj2
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	; #4-#7 low autoguard on frame #0
	cp   $07*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	; #8-#B mid autoguard on frame #1
	cp   $0B*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim

;
; This move has a special effect when autoguarded.
; Normally, when the move hits, the opponent is damaged and gets thrown up in the air.
; If the autoguard triggers, however, the opponent flashes, uses a different hit effect, and receives more damage.
;

; --------------- frame #0 ---------------	
; Autoguard on low.
.obj0:
	ld   hl, iPlInfo_Flags2
	add  hl, bc
	bit  PF2B_AUTOGUARDDONE, [hl]	; Did the autoguard trigger?
	jp   z, .obj0_noAutoguard		; If not, jump
.obj0_autoguard:
	;--
	; Seems pointless, since we only get here once.
	; The whole usage of iPlInfo_Kyo_NueTumi_AutoguardShakeDone is pointless.
	ld   hl, iPlInfo_Kyo_NueTumi_AutoguardShakeDone
	add  hl, bc
	ld   a, [hl]
	or   a									; ShakeDone != 0?
	jp   nz, .obj0_autoguard_setNextFrame	; If so, skip
	;--
	; Play SFX
	mMvC_PlaySound SCT_BLOCK
	; Do hitstop for 2 frames
	ld   a, $01					; Enable hitstop
	ld   [wPlayHitstopSet], a
	call Play_Pl_ShakeFor		; Shake for 1(*2) frames
	ld   a, $00					; Disable it
	ld   [wPlayHitstopSet], a
	;--
	ld   hl, iPlInfo_Kyo_NueTumi_AutoguardShakeDone
	add  hl, bc
	ld   [hl], $01				; Shake effect done
	;--
.obj0_autoguard_setNextFrame:
	; Immediately switch to frame #4, hitting the opponent
	mMvC_SetFrame $04*OBJLSTPTR_ENTRYSIZE, $01
	mMvC_SetDamageNext $08, HITTYPE_DROP_DB_A, PF3_HEAVYHIT|PF3_FIRE
	jp   .ret
.obj0_noAutoguard:
	mMvC_ValFrameEnd .anim
		;--
		; Reset this as long as the autoguard didn't trigger.
		; Seems pointless, as it's done by the move init code already
		ld   hl, iPlInfo_Kyo_NueTumi_AutoguardShakeDone
		add  hl, bc
		ld   [hl], $00
		;--
		; For the second frame, switch from low to mid autoguard
		ld   hl, iPlInfo_Flags2
		add  hl, bc
		set  PF2B_AUTOGUARDMID, [hl]
		res  PF2B_AUTOGUARDLOW, [hl]
		jp   .anim
; --------------- frame #1 ---------------
; Autoguard on mid. Almost the same as #0 otherwise.
.obj1:
	ld   hl, iPlInfo_Flags2
	add  hl, bc
	bit  PF2B_AUTOGUARDDONE, [hl]	; Did the autoguard trigger?
	jp   z, .obj1_noAutoguard		; If not, jump
.obj1_autoguard:
	;--
	ld   hl, iPlInfo_Kyo_NueTumi_AutoguardShakeDone
	add  hl, bc
	ld   a, [hl]
	or   a									; ShakeDone != 0?
	jp   nz, .obj1_autoguard_setNextFrame	; If so, skip
	;--
	; Play SFX
	mMvC_PlaySound SCT_BLOCK
	; Do hitstop for 2 frames
	ld   a, $01					; Enable hitstop
	ld   [wPlayHitstopSet], a
	call Play_Pl_ShakeFor		; Shake for 1(*2) frames
	ld   a, $00					; Disable it
	ld   [wPlayHitstopSet], a
	;--
	ld   hl, iPlInfo_Kyo_NueTumi_AutoguardShakeDone
	add  hl, bc
	ld   [hl], $01				; Shake effect done
	;--
.obj1_autoguard_setNextFrame:
	; Immediately switch to frame #8, hitting the opponent
	mMvC_SetFrame $08*OBJLSTPTR_ENTRYSIZE, $01
	mMvC_SetDamageNext $08, HITTYPE_HIT_MID0, PF3_HEAVYHIT|PF3_FIRE
	jp   .ret
.obj1_noAutoguard:
	mMvC_ValFrameEnd .anim
		;--
		ld   hl, iPlInfo_Kyo_NueTumi_AutoguardShakeDone
		add  hl, bc
		ld   [hl], $00
		;--
		; From the frame #2, there's no autoguard anymore.
		ld   hl, iPlInfo_Flags2
		add  hl, bc
		res  PF2B_AUTOGUARDMID, [hl]
		res  PF2B_AUTOGUARDLOW, [hl]
		jp   .anim
; --------------- frame #2 ---------------	
.obj2:
	mMvC_ValFrameStart .anim
		mMvC_PlaySound SCT_HEAVY
		jp   .anim
; --------------- frames #3, #7, #B ---------------	
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------	
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
; =============== MoveC_Kyo_UraOrochiNagi ===============
; Move code for Kyo's Ura 108 Shiki Orochi Nagi (MOVE_KYO_URA_OROCHI_NAGI_S, MOVE_KYO_URA_OROCHI_NAGI_D).
MoveC_Kyo_UraOrochiNagi:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj0
IF REV_VER_2 == 1
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
ENDC
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj2
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj3
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj4
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj5
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj6
	cp   $07*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim
	
; --------------- frame #0 ---------------	
.obj0:
	mMvC_ValFrameEnd .anim
		; Initialize number of ticks until we automatically stop releasing B.
		ld   hl, iPlInfo_Kyo_UraOrochiNagi_ChargeTimer
		add  hl, bc
IF REV_VER_2 == 0
		ld   [hl], $14
ELSE
		; The English version reduces this, possibly to avoid being able to waste too much time
		ld   [hl], $0F
ENDC
		jp   .anim
IF REV_VER_2 == 1
; --------------- frame #1 ---------------
.obj1:
	; [POI] The hidden version deals continuous damage here.
	ld   hl, iPlInfo_MoveId
	add  hl, bc
	ld   a, [hl]
	cp   MOVE_KYO_URA_OROCHI_NAGI_E		; Doing the hidden super?
	jp   nz, .anim						; If not, skip	
		mMvC_SetDamage $01, HITTYPE_HIT_MID0, PF3_FIRE|PF3_LASTHIT
		jp   .anim
ENDC
; --------------- frame #2 ---------------	
; Charge frame (along with #1)
.obj2:
IF REV_VER_2 == 1
	; The English version deals continuous damage here, even outside of the hidden version.
	; It more or less moved the line from below here.
	mMvC_SetDamage $01, HITTYPE_HIT_MID0, PF3_FIRE|PF3_LASTHIT
ENDC
	mMvC_ValFrameEnd .anim
	
		;
		; If the frame is allowed to continue animating normally, the charge will be released.
		;
		; It's possible to extend its charge time by holding B, and if so, the frame can loop
		; back to #1. There's a limit to how many times the animation can loop though, and when
		; reaching it B will be treated as released.
		;

		; If we stopped releasing B, animate normally
		ld   hl, iPlInfo_JoyKeys
		add  hl, bc
		ld   a, [hl]
		and  a, KEY_B	; Holding B?
		jp   z, .anim	; If not, animate
		
		; If the charge timer elapsed, animate normally
		ld   hl, iPlInfo_Kyo_UraOrochiNagi_ChargeTimer
		add  hl, bc
		dec  [hl]		; ChargeTimer--
		jp   z, .anim	; Did it elapse? If so, animate
		
		; Otherwise, loop back to #1
		mMvC_SetFrame $01*OBJLSTPTR_ENTRYSIZE, ANIMSPEED_INSTANT
IF REV_VER_2 == 0
		mMvC_SetDamageNext $01, HITTYPE_HIT_MID0, PF3_FIRE|PF3_LASTHIT
ENDC
		jp   .ret
; --------------- frame #3 ---------------
.obj3:
	; When switching to #4, initialize the move damage.
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_INSTANT
IF REV_VER_2 == 0
		mMvC_SetDamageNext $18, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED
ELSE
		; [POI] Hidden version deals way less damage for this hit, since from #4 it deals continuous damage.
		ld   hl, iPlInfo_MoveId
		add  hl, bc
		ld   a, [hl]
		cp   MOVE_KYO_URA_OROCHI_NAGI_E		; Doing the hidden super?
		jp   z, .obj3_setDamageE			; If so, jump
	.obj3_setDamageN:
		mMvC_SetDamageNext $18, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED
		jr   .obj3_anim
	.obj3_setDamageE:
		mMvC_SetDamageNext $01, HITTYPE_DROP_MAIN, PF3_FIRE|PF3_LASTHIT|PF3_LIGHTHIT	
	.obj3_anim:
ENDC
		;--
		; [POI] Where does this come from? We didn't have this set to begin with.
		ld   hl, iPlInfo_Flags2
		add  hl, bc
		res  PF2B_NOHURTBOX, [hl]
		;--
		jp   .anim
; --------------- frame #4 ---------------
; Move horizontally, slowing down gradually.
.obj4:
	; Set the initial movement speed the first time we get here.
	mMvC_ValFrameStart .obj4_cont
		mMvC_PlaySound SCT_PHYSFIRE
		mMvC_SetSpeedH +$07C0
		; [BUG] The animation speed is currently set to ANIMSPEED_INSTANT.
		;       That means mMvC_ValFrameEnd will also trigger this frame, but we're skipping it. 
		;       This prevents animation speed from being updated to $01 (not like it makes great difference).
		IF FIX_BUGS == 0
			jp   .doFriction
		ENDC
.obj4_cont:
	
	mMvC_ValFrameEnd .doFriction
		;--
		; [TCRF] Unreachable due to bug above.
		mMvC_SetAnimSpeed $01
		jp   .doFriction
		;--
; --------------- frame #5 ---------------
; Move horizontally, slowing down gradually.
.obj5:
	; Get manual ctrl when the frame ends.
	mMvC_ValFrameEnd .doFriction
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		jp   .doFriction
; --------------- frames #4-5 common friction check ---------------	
; Continue moving horizontally and slow down.
.doFriction:
	; [POI] The hidden version deals continuous damage during these frames, 5 lines at a time.
IF REV_VER_2 == 1
	ld   hl, iPlInfo_MoveId
	add  hl, bc
	ld   a, [hl]
	cp   MOVE_KYO_URA_OROCHI_NAGI_E	; Doing the hidden super?
	jp   nz, .doFriction_main		; If so, jump
	mMvC_SetDamage $05, HITTYPE_DROP_MAIN, PF3_FIRE|PF3_LASTHIT|PF3_LIGHTHIT
.doFriction_main:
ENDC
	mMvC_DoFrictionH $0060
	jp   .anim
; --------------- frame #6 ---------------	
.obj6:
	; [POI] And here too, one line less.
IF REV_VER_2 == 1
	ld   hl, iPlInfo_MoveId
	add  hl, bc
	ld   a, [hl]
	cp   MOVE_KYO_URA_OROCHI_NAGI_E	; Doing the hidden super?
	jp   nz, .obj6_main		; If so, jump
	mMvC_SetDamage $04, HITTYPE_DROP_MAIN, PF3_FIRE|PF3_LASTHIT|PF3_LIGHTHIT
.obj6_main:
ENDC	

	; Slow down even faster
	mMvC_DoFrictionH $0080
	jp   nc, .ret
	; Switch to the next frame we stop moving
	ld   hl, iOBJInfo_FrameLeft
	add  hl, de
	ld   [hl], $00
	mMvC_SetAnimSpeed $05
	jp   .anim
; --------------- frame #7 ---------------	
.chkEnd:
	mMvC_ValFrameEnd .anim
	call Play_Pl_EndMove
	jp   .ret
; --------------- common ---------------	
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveInputReader_Terry ===============
; Special move input checker for TERRY.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
; OUT
; - C flag: If set, a move was started
MoveInputReader_Terry:
	mMvIn_Validate Terry
	
.chkAir:
	jp   MoveInputReader_Terry_NoMove
	
.chkGround:
	;             SELECT + B                  SELECT + A
	mMvIn_ChkEasy MoveInit_Terry_PowerGeyser, MoveInit_Terry_RisingTackle
	mMvIn_ChkGA Terry, .chkPunch, .chkKick
	
.chkPunch:
	mMvIn_ValSuper .chkPunchNoSuper
	
	; DBDF+P -> Power Geyser
	mMvIn_ChkDir MoveInput_DBDF, MoveInit_Terry_PowerGeyser
.chkPunchNoSuper:
	; FDF+P -> Rising Tackle
	mMvIn_ChkDir MoveInput_FDF, MoveInit_Terry_RisingTackle
	; DF+P -> Power Wave
	mMvIn_ChkDir MoveInput_DF, MoveInit_Terry_PowerWave
	; DB+P -> Burn Knuckle
	mMvIn_ChkDir MoveInput_DB, MoveInit_Terry_BurnKnuckle
	; End
	jp   MoveInputReader_Terry_NoMove
.chkKick:
	; DB+K -> Crack Shot
	mMvIn_ChkDir MoveInput_DB, MoveInit_Terry_CrackShot
	; FDF+K -> Power Dunk
	mMvIn_ChkDir MoveInput_FDF, MoveInit_Terry_PowerDunk
	; End
	jp   MoveInputReader_Terry_NoMove
; =============== MoveInit_Terry_PowerWave ===============
MoveInit_Terry_PowerWave:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_TERRY_POWER_WAVE_L, MOVE_TERRY_POWER_WAVE_H
	call MoveInputS_SetSpecMove_StopSpeed
	call Play_Proj_CopyMoveDamageFromPl
	jp   MoveInputReader_Terry_MoveSet
; =============== MoveInit_Terry_BurnKnuckle ===============
MoveInit_Terry_BurnKnuckle:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_TERRY_BURN_KNUCKLE_L, MOVE_TERRY_BURN_KNUCKLE_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Terry_MoveSet
; =============== MoveInit_Terry_CrackShot ===============
MoveInit_Terry_CrackShot:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_TERRY_CRACK_SHOT_L, MOVE_TERRY_CRACK_SHOT_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Terry_MoveSet
; =============== MoveInit_Terry_RisingTackle ===============
MoveInit_Terry_RisingTackle:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_TERRY_RISING_TACKLE_L, MOVE_TERRY_RISING_TACKLE_H
	call MoveInputS_SetSpecMove_StopSpeed
	; Automatically block mids
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_GUARD, [hl]
	res  PF1B_CROUCH, [hl]
	jp   MoveInputReader_Terry_MoveSet
; =============== MoveInit_Terry_PowerDunk ===============
MoveInit_Terry_PowerDunk:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_TERRY_POWER_DUNK_L, MOVE_TERRY_POWER_DUNK_H
	call MoveInputS_SetSpecMove_StopSpeed
	;--
	; [POI] What
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	;--
	jp   MoveInputReader_Terry_MoveSet
; =============== MoveInit_Terry_PowerGeyser ===============
MoveInit_Terry_PowerGeyser:
	; [POI] Power Geyser is the only move with an hidden desperation super.
	;       See: MoveInputS_CheckSuperDesperation
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetSDE MOVE_TERRY_POWER_GEYSER_S, MOVE_TERRY_POWER_GEYSER_D, MOVE_TERRY_POWER_GEYSER_E
	call MoveInputS_SetSpecMove_StopSpeed
	call Play_Proj_CopyMoveDamageFromPl ; The geyser does the damage, not the player
	jp   MoveInputReader_Terry_MoveSet
; =============== MoveInputReader_Terry_MoveSet ===============
MoveInputReader_Terry_MoveSet:
	scf
	ret
; =============== MoveInputReader_Terry_NoMove ===============
MoveInputReader_Terry_NoMove:
	or   a
	ret
	
; =============== MoveC_Terry_PowerWave ===============
; Move code for Terry's:
; - Power Wave (MOVE_TERRY_POWER_WAVE_L, MOVE_TERRY_POWER_WAVE_H)
; - The normal version of Power Geyser (MOVE_TERRY_POWER_GEYSER_S)
MoveC_Terry_PowerWave:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj2
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim
; --------------- frame #2 ---------------
.obj2:
	mMvC_ValFrameStart .anim
	
		;
		; Update the animation speed and spawn the proper projectile.
		;
		
		ld   hl, iPlInfo_MoveId
		add  hl, bc
		ld   a, [hl]
		cp   MOVE_TERRY_POWER_GEYSER_S	; Doing the super?
		jp   z, .obj2_super				; If so, jump
		
	.obj2_pw:
		; Spawn the prrojectile
		call ProjInit_Terry_PowerWave
		
		; Determine anim speed
		ld   hl, iPlInfo_MoveId
		add  hl, bc
		ld   a, [hl]					; A = iPlInfo_MoveId
		ld   hl, iOBJInfo_FrameTotal
		add  hl, de						; HL = Ptr to iOBJInfo_FrameTotal
		cp   MOVE_TERRY_POWER_WAVE_H	; Doing the heavy version?
		jp   z, .obj2_setSpeedH			; If so, jump
	.obj2_setSpeedL:
		ld   [hl], $0A	; iOBJInfo_FrameTotal for light
		jp   .anim
	.obj2_setSpeedH:
		ld   [hl], $14	; iOBJInfo_FrameTotal for heavy
		jp   .anim
		
	.obj2_super:
		; Spawn projectile $18px forward
		ld   hl, $1800
		call ProjInit_Terry_PowerGeyser
		; Update anim speed
		ld   hl, iOBJInfo_FrameTotal
		add  hl, de
		ld   [hl], $28
		jp   .anim
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
	
; =============== MoveC_Terry_PowerGeyserD ===============
; Move code for the desperation version of Terry's Power Geyser (MOVE_TERRY_POWER_GEYSER_D).
; Spawns three Power Geysers, each one further forward.
MoveC_Terry_PowerGeyserD:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .setPostSpawnWait
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .spawnProj0
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .setPostSpawnWait
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .spawnProj1
	cp   $07*OBJLSTPTR_ENTRYSIZE
	jp   z, .setPostSpawnWait
	cp   $08*OBJLSTPTR_ENTRYSIZE
	jp   z, .spawnProj2
	cp   $09*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim
; --------------- frame #1,#4,#7 ---------------
; Delays movement after spawning the projectile by $14 frames.
.setPostSpawnWait:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $14
		jp   .anim
; --------------- frame #2 ---------------
.spawnProj0:
	mMvC_ValFrameStart .setDelayWait
		ld   hl, $1800
		call ProjInit_Terry_PowerGeyser
		jp   .setDelayWait
; --------------- frame #5 ---------------
.spawnProj1:
	mMvC_ValFrameStart .setDelayWait
		ld   hl, $4000
		call ProjInit_Terry_PowerGeyser
		jp   .setDelayWait
; --------------- frame #2,#5 / common post-frame wait ---------------
; Sets the animation speed for the frames that call .setPostSpawnWait .
.setDelayWait:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $02
		jp   .anim
; --------------- frame #8 ---------------	
.spawnProj2:
	mMvC_ValFrameStart .setRecoveryWait
		ld   hl, $6800
		call ProjInit_Terry_PowerGeyser
.setRecoveryWait:
	; Stay $32 frames in the recovery
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $32
		jp   .anim
; --------------- frame #9 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Terry_PowerGeyserE ===============
; [POI] Move code for the hidden desperation version of Terry's Power Geyser (MOVE_TERRY_POWER_GEYSER_E)
MoveC_Terry_PowerGeyserE:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   a, $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj0
	cp   a, $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
	cp   a, $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj2
	cp   a, $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj3
	cp   a, $13*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj13
	cp   a, $14*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .shake
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $02
		jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $08
		mMvC_PlaySound SCT_PROJ_LG_A
		jp   .anim
; --------------- frame #2 ---------------
.obj2:
	call Play_Pl_DoGroundScreenShake
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $08
		xor  a
		ld   [wScreenShakeY], a
		jp   .anim
; --------------- frame #3 ---------------
.obj3:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $05
		ld   hl, iPlInfo_Terry_PowerGeyserE_LastXPos
		add  hl, bc
		ld   [hl], $00
		jp   .anim
; --------------- common earthquake handler ---------------
.shake:
	call Play_Pl_DoGroundScreenShake
	mMvC_ValFrameEnd .anim
		jp   .spawnProj
; --------------- frame #13 ---------------
.obj13:
	call Play_Pl_DoGroundScreenShake
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $3C
; --------------- common projectile spawner ---------------
	.spawnProj:
		xor  a
		ld   [wScreenShakeY], a
		
		; Generate random X position for projectile.
		; A = (Rand & $38) + $18
		call Rand
		and  a, $38
		add  a, $18
		
		; A += $08 if the position matches with the last one generated.
		
		ld   hl, iPlInfo_Terry_PowerGeyserE_LastXPos
		add  hl, bc	; Seek to 
		cp   [hl]					; iPlInfo_Terry_PowerGeyserE_LastXPos != A?
		jp   nz, .spawnProj_diff	; If so, skip
		add  a, $08					; A += $08
	.spawnProj_diff:
		; Save the newly generated position
		ld   [hl], a
		
		; Spawn the thing
		ld   h, a	; A pixels
		ld   l, $00	; 0 subpixels
		call ProjInit_Terry_PowerGeyser
		jp   .anim
		
; --------------- frame #14 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret 

; =============== MoveC_Terry_BurnKnuckle ===============
; Move code for Terry's Burn Knuckle (MOVE_TERRY_BURN_KNUCKLE_L, MOVE_TERRY_BURN_KNUCKLE_H)
MoveC_Terry_BurnKnuckle:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .anim
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .anim
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj2
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj3
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj4
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj5
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
; --------------- frame #2 ---------------
.obj2:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_INSTANT
		jp   .anim
; --------------- frame #3 ---------------
.obj3:
	mMvC_ValFrameStart .obj3_cont
		mMvC_PlaySound SCT_MOVEJUMP_A
		; Set jump speed
		mMvIn_ChkLHE .obj3_setJumpH, .obj3_setJumpE
	.obj3_setJumpL: ; Light
		mMvC_SetSpeedH +$0500
		mMvC_SetSpeedV -$0300
		jp   .obj3_doGravity
	.obj3_setJumpH: ; Heavy
		mMvC_SetSpeedH +$0600
		mMvC_SetSpeedV -$0380
		jp   .obj3_doGravity
	.obj3_setJumpE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH +$0700
		mMvC_SetSpeedV -$0400
		mMvC_SetDamage $02, HITTYPE_DROP_MAIN, PF3_FIRE|PF3_LASTHIT
	.obj3_doGravity:
		jp   .doGravity
.obj3_cont:
	jp   .doGravity
; --------------- frame #4 ---------------
.obj4:
	; [POI] Hidden heavy deals continuous damage
	mMvIn_ChkNotE .doGravity
		mMvC_SetDamage $02, HITTYPE_DROP_MAIN, PF3_FIRE|PF3_LASTHIT|PF3_LIGHTHIT
		jp   .doGravity
; --------------- frame #5 ---------------
.obj5:
	; [POI] Hidden heavy deals continuous damage
	mMvIn_ChkNotE .obj5_chkLoop
		mMvC_SetDamage $02, HITTYPE_DROP_MAIN, PF3_FIRE|PF3_LASTHIT|PF3_LIGHTHIT
.obj5_chkLoop:
	; Loop to #4 (until we touch the ground)
	mMvC_ValFrameEnd .doGravity
		ld   hl, iOBJInfo_OBJLstPtrTblOffset
		add  hl, de
		ld   [hl], $03*OBJLSTPTR_ENTRYSIZE ; offset by -1
		jp   .doGravity
; --------------- frames #3-5 / common gravity check ---------------		
.doGravity:
	; Switch to #6 when we touch the ground
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $06*OBJLSTPTR_ENTRYSIZE, $06
		jp   .ret
; --------------- frame #6 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret

; =============== MoveC_Terry_CrackShot ===============
; Move code for Terry's Crack Shot (MOVE_TERRY_CRACK_SHOT_L, MOVE_TERRY_CRACK_SHOT_H)
MoveC_Terry_CrackShot:
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
	jp   z, .doGravity
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameStart .obj0_cont
		mMvC_SetMoveH +$0700
.obj0_cont:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameStart .obj1_cont
		mMvC_PlaySound SCT_MOVEJUMP_B
		mMvIn_ChkLHE .obj1_setJumpH, .obj1_setJumpE
	.obj1_setJumpL: ; Light
		mMvC_SetSpeedH +$0400
		mMvC_SetSpeedV -$0300
		jp   .obj1_doGravity
	.obj1_setJumpH: ; Heavy
		mMvC_SetSpeedH +$0500
		mMvC_SetSpeedV -$0380
		jp   .obj1_doGravity
	.obj1_setJumpE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH +$0600
		mMvC_SetSpeedV -$0400
	.obj1_doGravity:
		jp   .doGravity
.obj1_cont:
	mMvC_NextFrameOnGtYSpeed -$03, ANIMSPEED_NONE
	jp   nc, .doGravity
		mMvC_SetDamageNext $08, HITTYPE_HIT_MID0, PF3_HEAVYHIT
		jp   .doGravity
; --------------- frame #2 ---------------
.obj2:
	mMvC_NextFrameOnGtYSpeed -$01, ANIMSPEED_NONE
	jp   nc, .doGravity
		mMvC_SetDamageNext $08, HITTYPE_HIT_MID0, PF3_HEAVYHIT
		jp   .doGravity
; --------------- frame #1-3 / common gravity check ---------------
.doGravity:
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $04*OBJLSTPTR_ENTRYSIZE, $0A
		jp   .ret
; --------------- frame #4 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
	call Play_Pl_EndMove
	jr   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Terry_PowerDunk ===============
; Move code for Terry's Power Dunk (MOVE_TERRY_POWER_DUNK_L, MOVE_TERRY_POWER_DUNK_H)
MoveC_Terry_PowerDunk:
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
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj4
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .doGravity
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameStart .obj1_cont
		mMvC_PlaySound SFX_SUPERJUMP
		ld   hl, iPlInfo_Flags0
		add  hl, bc
		inc  hl	; Seek to iPlInfo_Flags1
		res  PF1B_INVULN, [hl]
		; Determine jump speed
		mMvIn_ChkLHE .obj1_setJumpH, .obj1_setJumpE
	.obj1_setJumpL: ; Light
		mMvC_SetSpeedH +$0100
		mMvC_SetSpeedV -$0600
		jp   .obj1_doGravity
	.obj1_setJumpH: ; Heavy
		mMvC_SetSpeedH +$0180
		mMvC_SetSpeedV -$0680
		jp   .obj1_doGravity
	.obj1_setJumpE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH +$0200
		mMvC_SetSpeedV -$0680
	.obj1_doGravity:
		jp   .doGravity
.obj1_cont:
	mMvC_NextFrameOnGtYSpeed -$0A, $05
	jp   .doGravity
; --------------- frame #2 ---------------
.obj2:
	mMvC_ValFrameEnd .doGravity
		mMvC_SetAnimSpeed ANIMSPEED_INSTANT
		mMvC_PlaySound SCT_FIREHIT
		; Heavy version shakes opponent longer
		mMvIn_ChkLH .obj2_setDamageH
	.obj2_setDamageL:
		mMvC_SetDamageNext $08, HITTYPE_DROP_DB_A, $00
		jp   .doGravity
	.obj2_setDamageH:
		mMvC_SetDamageNext $08, HITTYPE_DROP_DB_A, PF3_HEAVYHIT
		jp   .doGravity
; --------------- frame #3 ---------------
.obj3:
	jp   .doGravity
; --------------- frame #4 ---------------
.obj4:
	; Get manual control when switching to #5 (final jump frame with gravity check).
	mMvC_ValFrameEnd .doGravity
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		jp   .doGravity
; --------------- frames #1-5 / common gravity check ---------------
.doGravity:
	; Switch to #6 when we land on the floor
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $06*OBJLSTPTR_ENTRYSIZE, $0A
		jp   .ret
; --------------- frame #6 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== ProjInit_Terry_PowerWave ===============
; Initializes the projectile for Terry's Power Wave and Mr.Big's Ground Blaster.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
; - HL: Horizontal offset, relative to origin
ProjInit_Terry_PowerWave:
	mMvC_PlaySound SCT_PROJ_SM
	
	push bc
		push de
		
			; --------------- common projectile init code ---------------
			
			;
			; C flag = If set, we're at max power
			;
			ld   hl, iPlInfo_Pow
			add  hl, bc
			ld   a, [hl]		; A = Pow meter
			cp   PLAY_POW_MAX	; Are we at max power?
			jp   z, .initMaxPow	; If so, jump
			xor  a				; C flag clear
			jp   .getFlags2
		.initMaxPow:
			scf					; C flag set
		.getFlags2:
			;
			; A = iPlInfo_Flags2
			;
			ld   hl, iPlInfo_Flags2
			push af				; Preserve C flag for this
				add  hl, bc		; Seek to iPlInfo_Flags2
			pop  af
			ld   a, [hl]		; Read out to A
			
			push af ; Save A & C flag
				
				call ProjInitS_InitAndGetOBJInfo	; DE = Ptr to wOBJInfo_Pl*Projectile
				
				; --------------- main ---------------
			
				; Set code pointer
				ld   hl, iOBJInfo_Play_CodeBank
				add  hl, de
				ld   [hl], BANK(ProjC_Terry_PowerWave)	; BANK $06 ; iOBJInfo_Play_CodeBank
				inc  hl
				ld   [hl], LOW(ProjC_Terry_PowerWave)	; iOBJInfo_Play_CodePtr_Low
				inc  hl
				ld   [hl], HIGH(ProjC_Terry_PowerWave)	; iOBJInfo_Play_CodePtr_High
				
				; Write sprite mapping ptr for this projectile.
				ld   hl, iOBJInfo_BankNum
				add  hl, de
				ld   [hl], BANK(OBJLstPtrTable_Proj_Terry_PowerWave)	; BANK $01 ; iOBJInfo_BankNum
				inc  hl
				ld   [hl], LOW(OBJLstPtrTable_Proj_Terry_PowerWave)		; iOBJInfo_OBJLstPtrTbl_Low
				inc  hl
				ld   [hl], HIGH(OBJLstPtrTable_Proj_Terry_PowerWave)	; iOBJInfo_OBJLstPtrTbl_High
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
				
				; Set initial position relative to the player's origin
				call OBJLstS_Overlap
				mMvC_SetMoveH +$0800
				
			;
			; Determine projectile horizontal speed.
			;
		
			pop  af						; Restore A & C flag
			jp   nc, .fldNoMaxPow		; Are we at max power? If not, jump
		.fldMaxPow:
			bit  PF2B_HEAVY, a			; Was this an heavy attack?
			jp   nz, .fldHeavyMaxPow	; If so, jump
			jp   .fldLight
		.fldNoMaxPow:
			bit  PF2B_HEAVY, a			; Was this an heavy attack?
			jp   nz, .fldHeavy			; If so, jump
		.fldLight:
			ld   hl, +$0100
			jp   .setSpeed
		.fldHeavy:
			ld   hl, +$0200
			jp   .setSpeed
		.fldHeavyMaxPow:
			ld   hl, +$0400
		.setSpeed:
			call Play_OBJLstS_SetSpeedH_ByXFlipR
		pop  de
	pop  bc
	ret
; =============== ProjInit_Terry_PowerGeyser ===============
; Initializes the projectile for Terry's Power Geyser.
; The desperation and hidden desperation moves can spawn multiple projectiles,
; though only one is visible on-screen.
; The hidden version in particular spawns projectiles before the previous one despawns
; on its own, causing it to disappear when a new one is initialized.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
; - HL: Horizontal offset, relative to the player origin
ProjInit_Terry_PowerGeyser:
	mMvC_PlaySound SCT_PROJ_LG_A
	push bc
		push de
			push hl	; Save X offset
				call ProjInitS_InitAndGetOBJInfo
				
				; Set code pointer
				ld   hl, iOBJInfo_Play_CodeBank
				add  hl, de
				ld   [hl], BANK(ProjC_Terry_PowerGeyser)	; BANK $06 ; iOBJInfo_Play_CodeBank
				inc  hl
				ld   [hl], LOW(ProjC_Terry_PowerGeyser)		; iOBJInfo_Play_CodePtr_Low
				inc  hl
				ld   [hl], HIGH(ProjC_Terry_PowerGeyser)	; iOBJInfo_Play_CodePtr_High
				
				
				; Write sprite mapping ptr for this projectile.
				ld   hl, iOBJInfo_BankNum
				add  hl, de
				ld   [hl], BANK(OBJLstPtrTable_Proj_Terry_PowerGeyser)	; BANK $01 ; iOBJInfo_BankNum
				inc  hl
				ld   [hl], LOW(OBJLstPtrTable_Proj_Terry_PowerGeyser)	; iOBJInfo_OBJLstPtrTbl_Low
				inc  hl
				ld   [hl], HIGH(OBJLstPtrTable_Proj_Terry_PowerGeyser)	; iOBJInfo_OBJLstPtrTbl_High
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
				
				; Set initial position over the player's origin
				call OBJLstS_Overlap
			pop  hl	; HL = Movement amount
			call Play_OBJLstS_MoveH_ByXFlipR
		pop  de
	pop  bc
	ret

; =============== ProjC_Horz ===============
; Generic projectile code for those that only move horizontally.
ProjC_Horz:
	call ExOBJS_Play_ChkHitModeAndMoveH		; Can it despawn?
	jp   c, .despawn						; If so, jump
	call OBJLstS_DoAnimTiming_Loop_by_DE	; Otherwise, continue animating
	ret
.despawn:
	call OBJLstS_Hide
	ret
	
; =============== ProjC_Terry_PowerWave ===============	
; Projectile code for Terry's Power Wave and Mr.Big's Ground Blaster.
; Like ProjC_Horz, except it despawns automatically when frame #C ends.
ProjC_Terry_PowerWave:
	call ExOBJS_Play_ChkHitModeAndMoveH
	
	; Depending on the internal frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffset
	add  hl, de
	ld   a, [hl]
	cp   $0C*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
	ret
.chkEnd:
	mMvC_ValFrameEnd .anim
	call OBJLstS_Hide
	ret
	
; =============== ProjC_Terry_PowerGeyser ===============	
; Projectile code for Terry's Power Geyser.
; This despawns automatically when frame #A ends.	
ProjC_Terry_PowerGeyser:
	
	; Depending on the internal frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffset
	add  hl, de
	ld   a, [hl]
	cp   $0A*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
	ret
.chkEnd:
	mMvC_ValFrameEnd .anim
	call OBJLstS_Hide
	ret
; =============== MoveInputReader_Mai ===============
; Special move input checker for MAI.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
; OUT
; - C flag: If set, a move was started
MoveInputReader_Mai:
	mMvIn_Validate Mai
	
.chkAir:
	;             SELECT + B                            SELECT + A
	mMvIn_ChkEasy MoveInit_Mai_ChoHissatsuShinobibachi, MoveInit_Mai_KuuchuuMusasabiMai
	mMvIn_ChkGA Mai, .chkAirPunch, .chkAirKick
.chkAirKick:
	jp   MoveInputReader_Mai_NoMove
.chkAirPunch:
	; DB+P (Air) -> Kuuchuu Musasabi no Mai
	mMvIn_ChkDir MoveInput_DB, MoveInit_Mai_KuuchuuMusasabiMai
	jp   MoveInputReader_Mai_NoMove
	
.chkGround:
	;             SELECT + B                            SELECT + A
	mMvIn_ChkEasy MoveInit_Mai_ChoHissatsuShinobibachi, MoveInit_Mai_HishoRyuEnJin
	mMvIn_ChkGA Mai, .chkPunch, .chkKick
.chkPunch:
	; FDB+P -> Chijou Musasabi no Mai 
	mMvIn_ChkDir MoveInput_FDB, MoveInit_Mai_ChijouMusasabiMai
	; DF+P -> Ka Cho Sen
	mMvIn_ValProjActive .chkPunchNoProj
	mMvIn_ChkDir MoveInput_DF, MoveInit_Mai_KaChoSen
.chkPunchNoProj:
	; DB+P -> Ryu En Bu
	mMvIn_ChkDir MoveInput_DB, MoveInit_Mai_RyuEnBu
	jp   MoveInputReader_Mai_NoMove
.chkKick:
	; DBDF+K -> Cho Hissatsu Shinobibachi
	mMvIn_ValSuper .chkKickNoSuper
	mMvIn_ChkDir MoveInput_DBDF, MoveInit_Mai_ChoHissatsuShinobibachi
.chkKickNoSuper:
	; BDF+K -> Hissatsu Shinobibachi
	mMvIn_ChkDir MoveInput_BDF, MoveInit_Mai_HissatsuShinobibachi
	; FDF+K -> Hisho Ryu En Jin
	mMvIn_ChkDir MoveInput_FDF, MoveInit_Mai_HishoRyuEnJin
	jp   MoveInputReader_Mai_NoMove
; =============== MoveInit_Mai_KaChoSen ===============	
MoveInit_Mai_KaChoSen:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_MAI_KA_CHO_SEN_L, MOVE_MAI_KA_CHO_SEN_H
	call MoveInputS_SetSpecMove_StopSpeed
	call Play_Proj_CopyMoveDamageFromPl
	jp   MoveInputReader_Mai_SetMove
; =============== MoveInit_Mai_HissatsuShinobibachi ===============
MoveInit_Mai_HissatsuShinobibachi:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_MAI_HISSATSU_SHINOBIBACHI_L, MOVE_MAI_HISSATSU_SHINOBIBACHI_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Mai_SetMove
; =============== MoveInit_Mai_RyuEnBu ===============
MoveInit_Mai_RyuEnBu:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_MAI_RYU_EN_BU_L, MOVE_MAI_RYU_EN_BU_H
	call MoveInputS_SetSpecMove_StopSpeed
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	set  PF0B_PROJREM, [hl]
	jp   MoveInputReader_Mai_SetMove
; =============== MoveInit_Mai_HishoRyuEnJin ===============
MoveInit_Mai_HishoRyuEnJin:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_MAI_HISHO_RYU_EN_JIN_L, MOVE_MAI_HISHO_RYU_EN_JIN_H
	call MoveInputS_SetSpecMove_StopSpeed
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	set  PF0B_PROJREM, [hl]
	inc  hl
	jp   MoveInputReader_Mai_SetMove
; =============== MoveInit_Mai_ChijouMusasabiMai ===============
MoveInit_Mai_ChijouMusasabiMai:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_MAI_CHIJOU_MUSASABI_L, MOVE_MAI_CHIJOU_MUSASABI_H
	call MoveInputS_SetSpecMove_StopSpeed
	;--
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	;--
	jp   MoveInputReader_Mai_SetMove
; =============== MoveInit_Mai_KuuchuuMusasabiMai ===============
MoveInit_Mai_KuuchuuMusasabiMai:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_MAI_KUUCHUU_MUSASABI_L, MOVE_MAI_KUUCHUU_MUSASABI_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Mai_SetMove
; =============== MoveInit_Mai_ChoHissatsuShinobibachi ===============
MoveInit_Mai_ChoHissatsuShinobibachi:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetSD MOVE_MAI_CHO_HISSATSU_SHINOBIBACHI_S, MOVE_MAI_CHO_HISSATSU_SHINOBIBACHI_D
	call MoveInputS_SetSpecMove_StopSpeed
	;--
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	;--
	jp   MoveInputReader_Mai_SetMove
; =============== MoveInputReader_Mai_SetMove ===============
MoveInputReader_Mai_SetMove:
	scf
	ret
; =============== MoveInputReader_Mai_NoMove ===============
MoveInputReader_Mai_NoMove:
	or   a
	ret
	
; =============== MoveC_Mai_KaChoSen ===============
; Move code for Mai's Ka Cho Sen (MOVE_MAI_KA_CHO_SEN_L, MOVE_MAI_KA_CHO_SEN_H).
MoveC_Mai_KaChoSen:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj2
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim
; --------------- frame #2 ---------------
.obj2:;J
	mMvC_ValFrameStart .obj2_cont
		call ProjInit_Mai_KaChoSen
.obj2_cont:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $07
		jp   .anim
; --------------- frame #4 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Mai_HissatsuShinobibachi ===============
; Move code for Mai's Hissatsu Shinobibachi (MOVE_MAI_HISSATSU_SHINOBIBACHI_L, MOVE_MAI_HISSATSU_SHINOBIBACHI_H).
MoveC_Mai_HissatsuShinobibachi:
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
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameStart .moveH
		mMvC_PlaySound SFX_STEP
		mMvC_SetSpeedH $0200
		mMvC_SetDamageNext $06, HITTYPE_HIT_MID0, PF3_LASTHIT
		jp   .moveH
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameEnd .moveH
		mMvC_PlaySound SFX_STEP
		mMvC_SetDamageNext $06, HITTYPE_HIT_MID1, PF3_LASTHIT
		jp   .moveH
; --------------- frame #2 ---------------
.obj2:
	mMvC_ValFrameEnd .moveH
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		mMvC_PlaySound SFX_STEP
		mMvC_SetDamageNext $0A, HITTYPE_DROP_MAIN, PF3_HEAVYHIT
; --------------- frames #0-2 / common horizontal movement ---------------
.moveH:
	call OBJLstS_ApplyXSpeed
	jp   .anim
; --------------- frame #3 ---------------
.obj3:;J
	mMvC_ValFrameStart .obj3_cont
		mMvC_PlaySound SCT_MOVEJUMP_A
		mMvIn_ChkLHE .obj3_setJumpH, .obj3_setJumpE
	.obj3_setJumpL: ; Light
		mMvC_SetSpeedH +$0500
		mMvC_SetSpeedV -$0300
		jp   .obj3_doGravity
	.obj3_setJumpH: ; Heavy
		mMvC_SetSpeedH +$0600
		mMvC_SetSpeedV -$0380
		jp   .obj3_doGravity
	.obj3_setJumpE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH +$0700
		mMvC_SetSpeedV -$0400
	.obj3_doGravity:
		jp   .doGravity
.obj3_cont:
	jp   .doGravity
; --------------- frame #3 / common gravity check ---------------
.doGravity:
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $04*OBJLSTPTR_ENTRYSIZE, $07
		jp   .ret
; --------------- frame #4 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Mai_RyuEnBu ===============
; Move code for Mai's Ryu En Bu (MOVE_MAI_RYU_EN_BU_L, MOVE_MAI_RYU_EN_BU_H).
MoveC_Mai_RyuEnBu:
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
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim ; We never get here
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameEnd .anim
		mMvC_PlaySound SCT_PHYSFIRE
		mMvC_SetDamageNext $09, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED
		jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameStart .obj1_cont
		mMvC_SetMoveH $0400
.obj1_cont:
	mMvC_ValFrameEnd .anim
	jp   .anim
; --------------- frame #2 ---------------
.obj2:
	mMvC_ValFrameStart .obj2_cont
		mMvIn_ChkL .obj2_cont ; Performed a light attack? If so, jump
		mMvC_SetMoveH $0700
.obj2_cont:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $09, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED
		jp   .anim
; --------------- frame #3 ---------------
.obj3:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $08
		jp   .anim
; --------------- frame #4 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Mai_HishoRyuEnJin ===============
; Move code for Mai's Hisho Ryu En Jin (MOVE_MAI_HISHO_RYU_EN_JIN_L, MOVE_MAI_HISHO_RYU_EN_JIN_H).
MoveC_Mai_HishoRyuEnJin:
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
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .doGravity
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
; --------------- frame #0 ---------------
.obj0:
	jp   .anim
; --------------- frame #1 ---------------
.obj1:
	; Move 7px forward, 1px above
	mMvC_ValFrameStart .obj1_cont
		mMvC_SetMoveH +$0700
		mMvC_SetMoveV -$0100
.obj1_cont:
	; Enable manual control / set damage for #2
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		mMvC_SetDamageNext $08, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED
		jp   .anim
; --------------- frame #2 ---------------
.obj2:
	mMvC_ValFrameStart .obj2_cont
		mMvC_PlaySound SCT_PHYSFIRE
		ld   hl, iPlInfo_Flags0
		add  hl, bc
		inc  hl			; Seek to iPlInfo_Flags1
		res  PF1B_INVULN, [hl]
		
		; Set jump speed depending on LHE status
		mMvIn_ChkLHE .obj2_setJumpH, .obj2_setJumpE
	.obj2_setJumpL: ; Light
		mMvC_SetSpeedH +$0080
		mMvC_SetSpeedV -$0600
		jp   .obj2_doGravity
	.obj2_setJumpH: ; Heavy
		mMvC_SetSpeedH +$0100
		mMvC_SetSpeedV -$0700
		jp   .obj2_doGravity
	.obj2_setJumpE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH +$0200
		mMvC_SetSpeedV -$0800
	.obj2_doGravity:
		jp   .doGravity
.obj2_cont:
	; Immediately switch to the next frame as soon as possible (it will always be > -$08)
	mMvC_NextFrameOnGtYSpeed -$08, ANIMSPEED_NONE
	; and then set the damage settings for #3
	mMvC_ValFrameEnd .doGravity
		mMvC_SetDamageNext $08, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED
		jp   .doGravity
; --------------- frame #3 ---------------
.obj3:
	; Switch to #4 when YSpeed > -$04.
	; The frame we switch, set a much smaller horz. movement speed. 
	mMvC_NextFrameOnGtYSpeed -$04, ANIMSPEED_NONE
	jp   nc, .doGravity	; Did we advance the anim? If not, skip
		mMvC_SetSpeedH +$0040
		jp   .doGravity
; --------------- frames #2-4 / common gravity check ---------------
; Switches directly to #5 (recovery) when landing on the ground in frames #2-4
.doGravity:
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $05*OBJLSTPTR_ENTRYSIZE, $08
		jp   .ret
; --------------- frame #5 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Mai_ChijouMusasabi ===============
; Move code for Mai's Chijou Musasabi no Mai (MOVE_MAI_CHIJOU_MUSASABI_L, MOVE_MAI_CHIJOU_MUSASABI_H).
MoveC_Mai_ChijouMusasabi:
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
	jp   z, .playSFXOnEnd
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .playSFXOnEnd
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .playSFXOnEnd
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .playSFXOnEnd
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj6
	cp   $07*OBJLSTPTR_ENTRYSIZE
	jp   z, .doGravity
	cp   $08*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	cp   $09*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkStartKuuchuu
; --------------- frame #0 ---------------
; Startup.
.obj0:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $02
		jp   .anim
; --------------- frame #1 ---------------
; Jump setup.
.obj1:
	mMvC_ValFrameStart .playSFXOnEnd
		mMvC_PlaySound SFX_SUPERJUMP
		
		; No longer invulnerable
		ld   hl, iPlInfo_Flags0
		add  hl, bc
		inc  hl		; Seek to iPlInfo_Flags1
		res  PF1B_INVULN, [hl]
		
		;
		; Pick the jump direction depending on what we're holding.
		; Note that, regardless of the jump direction, the resulting jump is always a backwards jump.
		; As a result, the player's direction must be adjusted so that:
		; - When holding left, the player must be facing right.
		; - When holding right, the player must be facing left.
		;
		
		ld   hl, iPlInfo_JoyKeys
		add  hl, bc
		bit  KEYB_RIGHT, [hl]		; Holding right?
		jp   nz, .obj1_chkFlipR		; If so, jump
		bit  KEYB_LEFT, [hl]		; Holding left?
		jp   nz, .obj1_chkFlipL		; If so, jump
		
		; If we're not holding anything, don't alter the player's direction.
		; This could have jumped directly to .obj1_setBackJump... but, for some reason, they
		; went with jumping to the .obj1_chkFlip* check that won't cause a jump to .obj1_flip.
		; WHY
		ld   hl, iOBJInfo_OBJLstFlags
		add  hl, de
		bit  SPRB_XFLIP, [hl]	; Visually facing right? (1P side)
		jp   z, .obj1_chkFlipR	; If not, jump
		
	.obj1_chkFlipL:
		; We held left.
		; The player must be facing right before getting to .obj1_setBackJump.
		ld   hl, iOBJInfo_OBJLstFlags
		add  hl, de
		bit  SPRB_XFLIP, [hl]	; Visually facing right? (1P side)
		jp   z, .obj1_flip		; If not, jump
		jp   .obj1_setBackJump
		
	.obj1_chkFlipR:
		; We held right.
		; The player must be facing left before getting to .obj1_setBackJump.
		ld   hl, iOBJInfo_OBJLstFlags
		add  hl, de
		bit  SPRB_XFLIP, [hl]	; Visually facing right? (1P side)
		jp   nz, .obj1_flip		; If so, jump
		jp   .obj1_setBackJump
	.obj1_flip:
		; Flip the player horizontally
		ld   a, [hl]
		xor  SPR_XFLIP
		ld   [hl], a
		
	.obj1_setBackJump:
		mMvC_SetSpeedH -$0600
		mMvC_ChkMaxPow .obj1_setBackJumpMaxPow
	.obj1_setBackJumpNoMaxPow:
		mMvC_SetSpeedV -$0780
		jp   .obj1_doGravity
	.obj1_setBackJumpMaxPow:
		mMvC_SetSpeedV -$0700
	.obj1_doGravity:
		jp   .doGravity
; --------------- frames #1-5 / mid jump ---------------
.playSFXOnEnd:
	mMvC_ValFrameEnd .doGravity
		mMvC_PlaySound SCT_LIGHT
		jp   .doGravity
; --------------- frame #6 ---------------
; End of jump check.
.obj6:
	; Loop back to #2 if, by the end of the frame, we didn't touch the edge of the screen yet.
	; Otherwise, switch to #9.
	ld   hl, iOBJInfo_RangeMoveAmount
	add  hl, de
	ld   a, [hl]
	or   a				; iOBJInfo_RangeMoveAmount != 0?
	jp   nz, .obj6_setNext	; If so, jump
	mMvC_ValFrameEnd .doGravity
		ld   hl, iOBJInfo_OBJLstPtrTblOffset
		add  hl, de
		ld   [hl], $01*OBJLSTPTR_ENTRYSIZE ; offset by -1
		jp   .doGravity
.obj6_setNext:
	mMvC_SetFrame $09*OBJLSTPTR_ENTRYSIZE, $03
	jp   .ret
; --------------- frame #9 ---------------
; Checks for the input to transition to Kuuchuu Musasabi no Mai.
.chkStartKuuchuu:
	mMvC_ValFrameEnd .anim
	
		; Holding B transitions to the wall dive attack
		ld   hl, iPlInfo_JoyKeys
		add  hl, bc
		bit  KEYB_B, [hl]			; Pressed B?
		jp   nz, .startKuuChuu		; If so, jump
		
		; [POI] The CPU always starts it
		ld   hl, iPlInfo_Flags0
		add  hl, bc
		bit  PF0B_CPU, [hl]			; Are we a CPU?
		jp   nz, .startKuuChuu		; If so, jump
		
		; If we didn't hold anything, just continue to #7 where we fall down normally.
		mMvC_SetFrame $07*OBJLSTPTR_ENTRYSIZE, ANIMSPEED_NONE
		jp   .ret
		
	.startKuuChuu:
		; Switch to the appropriate version of Kuuchuu Musasabi no Mai
		mMvIn_ChkLH .startKuuChuuH
	.startKuuChuuL:
		ld   a, MOVE_MAI_KUUCHUU_MUSASABI_L
		call MoveInputS_SetSpecMove_StopSpeed
		jp   .ret
	.startKuuChuuH:
		ld   a, MOVE_MAI_KUUCHUU_MUSASABI_H
		call MoveInputS_SetSpecMove_StopSpeed
		jp   .ret
; --------------- frame #1-7 / common gravity check ---------------
.doGravity:
	; Switch to #8 if we touched the ground instead of the screen edge
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $08*OBJLSTPTR_ENTRYSIZE, $07
		jp   .ret
; --------------- frame #8 ---------------
; Ends the move at the end of the frame.
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Mai_KuuchuuMusasabi ===============
; Move code for Mai's Kuuchuu Musasabi no Mai (MOVE_MAI_KUUCHUU_MUSASABI_L, MOVE_MAI_KUUCHUU_MUSASABI_H).
; Dive attack.
MoveC_Mai_KuuchuuMusasabi:
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
	jp   .anim ; We never get here
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameStart .doGravity
		mMvC_PlaySound SCT_MOVEJUMP_A
		mMvIn_ChkLHE .obj1_setDiveH, .obj1_setDiveE
	.obj1_setDiveL: ; Light
		mMvC_SetSpeedH +$0300
		mMvC_SetSpeedV +$0200
		jp   .obj1_doGravity
	.obj1_setDiveH: ; Heavy
		mMvC_SetSpeedH +$0500
		mMvC_SetSpeedV +$0180
		jp   .obj1_doGravity
	.obj1_setDiveE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH +$0700
		mMvC_SetSpeedV +$0000
	.obj1_doGravity:
		jp   .doGravity
; --------------- frame #1 / common gravity check ---------------
.doGravity:
	mMvC_ChkGravityHV $0018, .anim
		mMvC_SetLandFrame $02*OBJLSTPTR_ENTRYSIZE, $08
		jp   .ret
; --------------- frame #2 ---------------
.obj2:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Mai_ChoHissatsuShinobibachiS ===============
; Move code for the super version of Mai's Cho Hissatsu Shinobibachi (MOVE_MAI_CHO_HISSATSU_SHINOBIBACHI_S).
MoveC_Mai_ChoHissatsuShinobibachiS:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj0
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .moveH
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj2
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj3
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj4
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj5
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
; --------------- frame #0 ---------------
; Initial forward dash.
.obj0:
	mMvC_ValFrameStart .obj0_cont
		ld   hl, iPlInfo_Flags1
		add  hl, bc
		res  PF1B_INVULN, [hl]
		mMvC_PlaySound SFX_STEP
		mMvC_SetSpeedH +$0300
.obj0_cont:
	mMvC_ValFrameEnd .moveH
		mMvC_SetDamageNext $02, HITTYPE_HIT_MID0, PF3_LASTHIT
		jp   .moveH
; --------------- [TCRF] unreferenced frame #1 ---------------
; This being skipped makes the move deal one less hit.
.unused_obj1:
	mMvC_ValFrameEnd .moveH
		mMvC_PlaySound SFX_STEP
		mMvC_SetDamageNext $02, HITTYPE_HIT_MID1, PF3_LASTHIT
		jp   .moveH
; --------------- frame #2 ---------------
; Initial forward dash, dealing damage.
.obj2:
	mMvC_ValFrameEnd .moveH
		mMvC_PlaySound SFX_STEP
		mMvC_SetDamageNext $02, HITTYPE_DROP_MAIN, PF3_FIRE|PF3_LASTHIT
		jp   .moveH
; --------------- frames #0-2 / common movement ---------------
.moveH:
	call OBJLstS_ApplyXSpeed
	jp   .anim
; --------------- frame #3 ---------------
; Jump.
.obj3:
	mMvC_ValFrameStart .obj3_cont
		mMvC_PlaySound SCT_PHYSFIRE
		ld   hl, iPlInfo_Flags0
		add  hl, bc
		inc  hl	; Seek to iPlInfo_Flags1
		res  PF1B_INVULN, [hl]
		; Set jump settings
		mMvC_SetSpeedH +$0680
		mMvC_SetSpeedV -$0500
		jp   .doGravity
.obj3_cont:
	mMvC_ValFrameEnd .doGravity
		; Do we get here?
		mMvC_SetDamageNext $02, HITTYPE_DROP_MAIN, PF3_FIRE|PF3_LASTHIT
		jp   .doGravity
; --------------- frame #4 ---------------
; Mid-jump loop
.obj4:
	mMvC_ValFrameEnd .doGravity
		mMvC_SetDamageNext $02, HITTYPE_DROP_MAIN, PF3_FIRE|PF3_LASTHIT
		jp   .doGravity
; --------------- frame #5 ---------------
; Mid-jump loop.
.obj5:
	; Loop back to #4 if we didn't touch the ground by the end of the frame
	mMvC_ValFrameEnd .doGravity
		ld   hl, iOBJInfo_OBJLstPtrTblOffset
		add  hl, de
		ld   [hl], $03*OBJLSTPTR_ENTRYSIZE ; offset by -1
		mMvC_SetDamageNext $02, HITTYPE_DROP_MAIN, PF3_FIRE|PF3_LASTHIT
		jp   .doGravity
; --------------- frames #3-5 / common gravity check ---------------
.doGravity:
	; Switch to #6 when we touch the ground
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $06*OBJLSTPTR_ENTRYSIZE, $0F
		jp   .ret
; --------------- frame #6 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Mai_ChoHissatsuShinobibachiD ===============
; Move code for the desperation version of Mai's Cho Hissatsu Shinobibachi (MOVE_MAI_CHO_HISSATSU_SHINOBIBACHI_D).
; The code is similar to MoveC_Mai_ChoHissatsuShinobibachiS, with the main difference being 4 extra frames
; at the beginning that deal 4 extra hits to the opponent, and the continuous damage during the main jump.
; See also: MoveC_Mai_ChoHissatsuShinobibachiS
MoveC_Mai_ChoHissatsuShinobibachiD:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	
	; Extra damage
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj0
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj0
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
	
	; Main
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj4
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .moveH
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj6
	cp   $07*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj7
	cp   $08*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj8
	cp   $09*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj9
	cp   $0A*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
; --------------- frame #0 ---------------
; Initial damage 0
.obj0:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $02, HITTYPE_HIT_MID0, PF3_LASTHIT
		jp   .anim
; --------------- frame #1 ---------------
; Initial damage 1
.obj1:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $02, HITTYPE_HIT_MID1, PF3_LASTHIT
		jp   .anim
		
; --------------- frame #4 ---------------
; Initial forward dash.
.obj4:
	mMvC_ValFrameStart .obj4_cont
		ld   hl, iPlInfo_Flags1
		add  hl, bc
		res  PF1B_INVULN, [hl]
		mMvC_PlaySound SFX_STEP
		mMvC_SetSpeedH +$0300
.obj4_cont:
	mMvC_ValFrameEnd .moveH
		mMvC_SetDamageNext $02, HITTYPE_HIT_MID0, PF3_LASTHIT
		jp   .moveH
		
; --------------- [TCRF] unreferenced frame #5 ---------------
; This being skipped makes the move deal one less hit.
.unused_obj1:
	mMvC_ValFrameEnd .moveH
		mMvC_PlaySound SFX_STEP
		mMvC_SetDamageNext $02, HITTYPE_HIT_MID1, PF3_LASTHIT
		jp   .moveH
; --------------- frame #6 ---------------
; Initial forward dash, dealing damage.
.obj6:
	mMvC_ValFrameEnd .moveH
		mMvC_PlaySound SFX_STEP
		mMvC_SetDamageNext $02, HITTYPE_DROP_MAIN, PF3_FIRE|PF3_LASTHIT
		jp   .moveH
; --------------- frames #4-6 / common movement ---------------
.moveH:
	call OBJLstS_ApplyXSpeed
	jp   .anim
; --------------- frame #7 ---------------
; Jump.
.obj7:
	mMvC_ValFrameStart .obj7_cont
		mMvC_PlaySound SCT_PHYSFIRE
		ld   hl, iPlInfo_Flags0
		add  hl, bc
		inc  hl	; Seek to iPlInfo_Flags1
		res  PF1B_INVULN, [hl]
		; Set jump settings
		mMvC_SetSpeedH +$0680
		mMvC_SetSpeedV -$0500
		jp   .doGravity
.obj7_cont:
	; Continuous damage
	mMvC_SetDamage $02, HITTYPE_DROP_MAIN, PF3_FIRE|PF3_LASTHIT|PF3_LIGHTHIT
	jp   .doGravity
; --------------- frame #8 ---------------
; Mid-jump loop
.obj8:
	; Continuous damage
	mMvC_SetDamage $02, HITTYPE_DROP_MAIN, PF3_FIRE|PF3_LASTHIT|PF3_LIGHTHIT
	mMvC_ValFrameEnd .doGravity
		jp   .doGravity
; --------------- frame #9 ---------------
; Mid-jump loop.
.obj9:
	; Continuous damage
	mMvC_SetDamage $02, HITTYPE_DROP_MAIN, PF3_FIRE|PF3_LASTHIT|PF3_LIGHTHIT
	; Loop back to #8 if we didn't touch the ground by the end of the frame
	mMvC_ValFrameEnd .doGravity
		ld   hl, iOBJInfo_OBJLstPtrTblOffset
		add  hl, de
		ld   [hl], $07*OBJLSTPTR_ENTRYSIZE ; offset by -1
		jp   .doGravity
; --------------- frames #7-9 / common gravity check ---------------
.doGravity:
	; Switch to #A when we touch the ground
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $0A*OBJLSTPTR_ENTRYSIZE, $12
		jp   .ret
; --------------- frame #A ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== ProjInit_Mai_KaChoSen ===============
; Initializes the projectile for Mai's Ka Cho Sen.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
ProjInit_Mai_KaChoSen:
	mMvC_PlaySound SCT_HEAVY
	push bc
		push de
		
			; --------------- common projectile init code ---------------
			
			;
			; C flag = If set, we're at max power
			;
			ld   hl, iPlInfo_Pow
			add  hl, bc
			ld   a, [hl]		; A = Pow meter
			cp   PLAY_POW_MAX	; Are we at max power?
			jp   z, .initMaxPow	; If so, jump
			xor  a				; C flag clear
			jp   .getFlags2
		.initMaxPow:
			scf					; C flag set
		.getFlags2:
			;
			; A = iPlInfo_Flags2
			;
			ld   hl, iPlInfo_Flags2
			push af				; Preserve C flag for this
				add  hl, bc		; Seek to iPlInfo_Flags2
			pop  af
			ld   a, [hl]		; Read out to A
			
			push af ; Save A & C flag
				
				call ProjInitS_InitAndGetOBJInfo	; DE = Ptr to wOBJInfo_Pl*Projectile
				
				; --------------- main ---------------
			
				; Set code pointer
				ld   hl, iOBJInfo_Play_CodeBank
				add  hl, de
				ld   [hl], BANK(ProjC_Horz)	; BANK $06 ; iOBJInfo_Play_CodeBank
				inc  hl
				ld   [hl], LOW(ProjC_Horz)	; iOBJInfo_Play_CodePtr_Low
				inc  hl
				ld   [hl], HIGH(ProjC_Horz)	; iOBJInfo_Play_CodePtr_High
				
				; Write sprite mapping ptr for this projectile.
				ld   hl, iOBJInfo_BankNum
				add  hl, de
				ld   [hl], BANK(OBJLstPtrTable_Proj_Mai_KaChoSen)	; BANK $01 ; iOBJInfo_BankNum
				inc  hl
				ld   [hl], LOW(OBJLstPtrTable_Proj_Mai_KaChoSen)	; iOBJInfo_OBJLstPtrTbl_Low
				inc  hl
				ld   [hl], HIGH(OBJLstPtrTable_Proj_Mai_KaChoSen)	; iOBJInfo_OBJLstPtrTbl_High
				inc  hl
				ld   [hl], $00	; iOBJInfo_OBJLstPtrTblOffset

				; Set animation speed.
				ld   hl, iOBJInfo_FrameLeft
				add  hl, de
				ld   [hl], $03	; iOBJInfo_FrameLeft
				inc  hl
				ld   [hl], $03	; iOBJInfo_FrameTotal
				
				; Set priority value
				ld   hl, iOBJInfo_Play_Priority
				add  hl, de
				ld   [hl], $00
				
				; Set initial position relative to the player's origin
				call OBJLstS_Overlap
				mMvC_SetMoveH +$0800
				
			;
			; Determine projectile horizontal speed.
			;
		
			pop  af						; Restore A & C flag
			jp   nc, .fldNoMaxPow		; Are we at max power? If not, jump
		.fldMaxPow:
			bit  PF2B_HEAVY, a			; Was this an heavy attack?
			jp   nz, .fldHeavyMaxPow	; If so, jump
			jp   .fldLight
		.fldNoMaxPow:
			bit  PF2B_HEAVY, a			; Was this an heavy attack?
			jp   nz, .fldHeavy			; If so, jump
		.fldLight:
			ld   hl, +$0100
			jp   .setSpeed
		.fldHeavy:
			ld   hl, +$0200
			jp   .setSpeed
		.fldHeavyMaxPow:
			ld   hl, +$0400
		.setSpeed:
			call Play_OBJLstS_SetSpeedH_ByXFlipR
		pop  de
	pop  bc
	ret
	
; =============== MoveInputReader_Athena ===============
; Special move input checker for ATHENA.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
; OUT
; - C flag: If set, a move was started
MoveInputReader_Athena:
	mMvIn_Validate Athena
	
.chkAir:
	;             SELECT + B                            SELECT + A
	mMvIn_ChkEasy MoveInit_Athena_ShCrystAir, MoveInit_Athena_PhoenixArrow
	mMvIn_ChkGA Athena, .chkAirPunch, .chkAirKick
.chkAirPunch:
	mMvIn_ValSuper .chkAirPunchNoSuper
	; BFDB+P (air) -> Shining Crystal Bit
	mMvIn_ChkDir MoveInput_BFDB, MoveInit_Athena_ShCrystAir
.chkAirPunchNoSuper:
	; FDF+P (air) -> Psycho Sword
	mMvIn_ChkDir MoveInput_FDF, MoveInit_Athena_PsychoSword
	; DB+P (air) -> Phoenix Arrow
	mMvIn_ChkDir MoveInput_DB, MoveInit_Athena_PhoenixArrow
	; End
	jp   MoveInputReader_Athena_NoMove
.chkAirKick:
	; DF+K (air) -> Psycho Teleport
	; [POI] With the powerup cheat enabled, this move can be pulled off mid-air.
	;       Though since it wasn't designed for this, as soon as the move ends Athena snaps to the ground.
	mMvIn_ValDipPowerup MoveInputReader_Athena_NoMove
	mMvIn_ChkDir MoveInput_DF, MoveInit_Athena_PsychoTeleport
	; End
	jp   MoveInputReader_Athena_NoMove
	
.chkGround:
	;             SELECT + B                               SELECT + A
	mMvIn_ChkEasy MoveInit_Athena_ShCrystGround, MoveInit_Athena_PsychoReflector
	mMvIn_ChkGA Athena, .chkPunch, .chkKick
.chkPunch:
	mMvIn_ValSuper .chkPunchNoSuper
	; BFDB+P -> Shining Crystal Bit
	mMvIn_ChkDir MoveInput_BFDB, MoveInit_Athena_ShCrystGround
.chkPunchNoSuper:
	; FDF+P -> Psycho Sword
	mMvIn_ChkDir MoveInput_FDF, MoveInit_Athena_PsychoSword
	; DB+P -> Psycho Ball
	mMvIn_ChkDir MoveInput_DB, MoveInit_Athena_PsychoBall
	; End
	jp   MoveInputReader_Athena_NoMove
.chkKick:
	; FDB+K -> Psycho Reflector
	mMvIn_ChkDir MoveInput_FDB, MoveInit_Athena_PsychoReflector
	; DF+K -> Psycho Teleport
	mMvIn_ChkDir MoveInput_DF, MoveInit_Athena_PsychoTeleport
	; End
	jp   MoveInputReader_Athena_NoMove
; =============== MoveInit_Athena_PsychoBall ===============	
MoveInit_Athena_PsychoBall:
	mMvIn_ValProjActive Athena
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_ATHENA_PSYCHO_BALL_L, MOVE_ATHENA_PSYCHO_BALL_H
	call MoveInputS_SetSpecMove_StopSpeed
	call Play_Proj_CopyMoveDamageFromPl
	jp   MoveInputReader_Athena_SetMove
; =============== MoveInit_Athena_PhoenixArrow ===============
MoveInit_Athena_PhoenixArrow:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_ATHENA_PHOENIX_ARROW_L, MOVE_ATHENA_PHOENIX_ARROW_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Athena_SetMove
; =============== MoveInit_Athena_PsychoReflector ===============
MoveInit_Athena_PsychoReflector:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_ATHENA_PSYCHO_REFLECTOR_L, MOVE_ATHENA_PSYCHO_REFLECTOR_H
	call MoveInputS_SetSpecMove_StopSpeed
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	set  PF0B_PROJREFLECT, [hl]
	jp   MoveInputReader_Athena_SetMove
; =============== MoveInit_Athena_PsychoSword ===============
MoveInit_Athena_PsychoSword:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_ATHENA_PSYCHO_SWORD_L, MOVE_ATHENA_PSYCHO_SWORD_H
	call MoveInputS_SetSpecMove_StopSpeed
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_INVULN, [hl]
	jp   MoveInputReader_Athena_SetMove
; =============== MoveInit_Athena_PsychoTeleport ===============
MoveInit_Athena_PsychoTeleport:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_ATHENA_PSYCHO_TELEPORT_L, MOVE_ATHENA_PSYCHO_TELEPORT_H
	call MoveInputS_SetSpecMove_StopSpeed
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_INVULN, [hl]
	inc  hl
	set  PF2B_NOCOLIBOX, [hl]
	jp   MoveInputReader_Athena_SetMove
; =============== MoveInit_Athena_ShCrystGround ===============
MoveInit_Athena_ShCrystGround:
	mMvIn_ValProjActive Athena
	mMvIn_ValProjVisible Athena
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetSD MOVE_ATHENA_SHINING_CRYSTAL_BIT_GS, MOVE_ATHENA_SHINING_CRYSTAL_BIT_GD
	call MoveInputS_SetSpecMove_StopSpeed
	call Play_Proj_CopyMoveDamageFromPl
	jp   MoveInputReader_Athena_SetMove
; =============== MoveInit_Athena_ShCrystAir ===============
MoveInit_Athena_ShCrystAir:
	mMvIn_ValProjActive Athena
	mMvIn_ValProjVisible Athena
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetSD MOVE_ATHENA_SHINING_CRYSTAL_BIT_AS, MOVE_ATHENA_SHINING_CRYSTAL_BIT_AD
	call MoveInputS_SetSpecMove_StopSpeed
	call Play_Proj_CopyMoveDamageFromPl
	jp   MoveInputReader_Athena_SetMove
; =============== MoveInputReader_Athena_SetMove ===============
MoveInputReader_Athena_SetMove:
	scf
	ret
; =============== MoveInputReader_Athena_NoMove ===============
MoveInputReader_Athena_NoMove:
	or   a
	ret
	
; =============== MoveC_Athena_PsychoBall ===============
; Move code for Athena's Psycho Ball (MOVE_ATHENA_PSYCHO_BALL_L, MOVE_ATHENA_PSYCHO_BALL_H).
MoveC_Athena_PsychoBall:
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
	jp   z, .chkEnd
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $10
		jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameStart .obj1_cont
		call ProjInit_Athena_PsychoBall
.obj1_cont:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $03
		jp   .anim
; --------------- frame #2 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jp   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Athena_PhoenixArrow ===============
; Move code for Athena's Phoenix Arrow (MOVE_ATHENA_PHOENIX_ARROW_L, MOVE_ATHENA_PHOENIX_ARROW_H).
MoveC_Athena_PhoenixArrow:
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
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj4
	; [BUG] The Japanese version repeats .obj4 here, leaving unreferenced .obj5.
IF REV_VER_2 == 0
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj4
ELSE
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj5
ENDC
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim ; We never get here
; --------------- frame #0 ---------------
; Startup.
.obj0:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_INSTANT
		jp   .anim
; --------------- frame #1 ---------------
; Diagonal forward-down dive from the air.
.obj1:
	mMvC_ValFrameStart .obj1_cont
		mMvC_PlaySound SCT_MOVEJUMP_A
		mMvIn_ChkLHE .obj1_setDashH, .obj1_setDashE
	.obj1_setDashL: ; Light
		mMvC_SetSpeedH +$0300
		mMvC_SetSpeedV +$0200
		jp   .obj1_cont
	.obj1_setDashH: ; Heavy
		mMvC_SetSpeedH +$0500
		mMvC_SetSpeedV +$0180
		jp   .obj1_cont
	.obj1_setDashE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH +$0700
		mMvC_SetSpeedV +$0000
.obj1_cont:
	mMvC_ValFrameEnd .doGravity
		mMvC_SetDamageNext $01, HITTYPE_HIT_MID0, PF3_LASTHIT
		jp   .doGravity
; --------------- frame #2 ---------------
; Again.
.obj2:
	mMvC_ValFrameEnd .doGravity
		mMvC_SetDamageNext $01, HITTYPE_HIT_MID1, PF3_LASTHIT
		jp   .doGravity
; --------------- frame #3 ---------------
; Again.
.obj3:
	mMvC_ValFrameEnd .doGravity
		; Loop to #2 if we didn't touch the ground by the end of the frame
		mMvC_SetDamageNext $01, HITTYPE_HIT_MID0, PF3_LASTHIT
		ld   hl, iOBJInfo_OBJLstPtrTblOffset
		add  hl, de
		ld   [hl], $01*OBJLSTPTR_ENTRYSIZE ; offset by -1
		jp   .doGravity
; --------------- frames #1-3 / common gravity check ---------------
.doGravity:
	mMvC_ChkGravityHV $0018, .anim
		; The heavy version performs a kick at the end by switching to #4.
		; The light one doesn't, and skips to #6 instead.
		ld   hl, iPlInfo_MoveId
		add  hl, bc
		ld   a, [hl]
		cp   MOVE_ATHENA_PHOENIX_ARROW_L	; Using the light version?
		jp   z, .doGravity_setNextL			; If so, jump
	.doGravity_setNextH:
		mMvC_SetLandFrame $04*OBJLSTPTR_ENTRYSIZE, $04
		jp   .ret
	.doGravity_setNextL:
		mMvC_SetLandFrame $06*OBJLSTPTR_ENTRYSIZE, $0C
		jp   .ret
; --------------- frame #4 ---------------
; Kick.
.obj4:
	mMvC_ValFrameStart .obj4_cont
		; Autocorrect the kick
		call OBJLstS_SyncXFlip
.obj4_cont:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $10
		; Note this won't hit twice since HITTYPE_DROP_MAIN makes the opponent unhittable.
		; (while the English version uses .obj5 properly, so this only gets executed once.
IF REV_VER_2 == 0
		mMvC_SetDamageNext $04, HITTYPE_DROP_MAIN, $00
ELSE
		mMvC_SetDamageNext $04, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; Longer shake
ENDC
		jp   .anim
; --------------- frame #5 ---------------
.obj5:
	mMvC_ValFrameEnd .anim
IF REV_VER_2 == 0
		mMvC_SetAnimSpeed $06
ELSE
		mMvC_SetAnimSpeed $0E ; Not that much faster for the one that's used
ENDC
		jp   .anim
; --------------- frame #6 ---------------
; Recovery.
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Athena_PsychoReflector ===============
; Move code for Athena's Psycho Reflector (MOVE_ATHENA_PSYCHO_REFLECTOR_L, MOVE_ATHENA_PSYCHO_REFLECTOR_H).
MoveC_Athena_PsychoReflector:
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
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj4
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj5
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim ; We never get here
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameEnd .anim
		ld   hl, iPlInfo_MoveId
		add  hl, bc
		ld   a, [hl]
		cp   MOVE_ATHENA_PSYCHO_REFLECTOR_H		; Using the heavy version?
		jp   z, .obj0_setSpeedH					; If so, jump
	.obj0_setSpeedL:
		; The light version doesn't move, so there's no jump to wait for
		ld   hl, iOBJInfo_FrameTotal
		add  hl, de
		ld   [hl], ANIMSPEED_INSTANT
		jp   .anim
	.obj0_setSpeedH:
		; The heavy one proceeds from #1 to #2 only when landing on the ground
		ld   hl, iOBJInfo_FrameTotal
		add  hl, de
		ld   [hl], ANIMSPEED_NONE
		jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameStart .obj1_cont
		; Initialize the jump speed
		mMvIn_ChkLHE .obj1_setJumpH, .obj1_setJumpE
	.obj1_setJumpL: ; Light - no jump
		mMvC_SetSpeedH +$0000
		mMvC_SetSpeedV +$0000
		jp   .obj1_doGravity
	.obj1_setJumpH: ; Heavy - jump
		mMvC_SetSpeedH +$0400
		mMvC_SetSpeedV -$0300
		jp   .obj1_doGravity
	.obj1_setJumpE: ; [POI] Hidden Heavy - higher jump
		mMvC_SetSpeedH +$0600
		mMvC_SetSpeedV -$0400
	.obj1_doGravity:
		jp   .doGravity
	.obj1_cont:
		jp   .doGravity
.doGravity:
	; Switch to #2 when landing on the ground
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $02*OBJLSTPTR_ENTRYSIZE, ANIMSPEED_INSTANT
		mMvC_PlaySound SCT_PSYCREFLAND
		jp   .ret
; --------------- frame #2 ---------------
.obj2:
	; Deal continuous damage while this is displayed
	mMvC_SetDamage $01, HITTYPE_DROP_MAIN, PF3_LASTHIT|PF3_LIGHTHIT
	mMvC_ValFrameEnd .anim
		mMvIn_ChkLH .obj2_setSpeedH
	.obj2_setSpeedL:
		ld   hl, iOBJInfo_FrameTotal
		add  hl, de
		ld   [hl], ANIMSPEED_INSTANT
		jp   .anim
	.obj2_setSpeedH:
		ld   hl, iOBJInfo_FrameTotal
		add  hl, de
		ld   [hl], $03
		jp   .anim
; --------------- frame #3 ---------------
; Deal continuous damage while this is displayed
.obj3:
	mMvC_SetDamage $01, HITTYPE_DROP_MAIN, PF3_LASTHIT|PF3_LIGHTHIT
	jp   .anim
; --------------- frame #3 ---------------
; Deal continuous damage while this is displayed
.obj4:
	mMvC_SetDamage $01, HITTYPE_DROP_MAIN, PF3_LASTHIT|PF3_LIGHTHIT
	mMvC_ValFrameEnd .anim
		ld   hl, iOBJInfo_FrameTotal
		add  hl, de
		ld   [hl], $0A
		jp   .anim
; --------------- frame #5 ---------------
.obj5:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $08
		jp   .anim
; --------------- frame #6 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jp   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Athena_PsychoTeleport ===============
; Move code for Athena's Psycho Teleport (MOVE_ATHENA_PSYCHO_TELEPORT_L, MOVE_ATHENA_PSYCHO_TELEPORT_H).
MoveC_Athena_PsychoTeleport:
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
	jp   z, .chkEnd
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameEnd .anim
		mMvC_PlaySound SCT_MOVEJUMP_A
		jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $0C
		; Invulnerable for $05 frames into #2
		ld   hl, iPlInfo_Athena_PsychoTeleport_InvulnTimer
		add  hl, bc
		ld   [hl], $05
		jp   .anim
; --------------- frame #2 ---------------
.obj2:
	mMvC_ValFrameStart .obj2_cont
		; Show particle effect
		call ProjInit_Athena_PsychoTeleport
		; Set dash speed depending on move strength
		mMvIn_ChkLHE .obj2_setDashH, .obj2_setDashE
	.obj2_setDashL: ; Light
		mMvC_SetSpeedH +$0480
		jp   .obj2_cont
	.obj2_setDashH: ; Heavy
		mMvC_SetSpeedH +$0600
		jp   .obj2_cont
	.obj2_setDashE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH +$0780
.obj2_cont:
	; Handle invulnerability timer
	ld   hl, iPlInfo_Athena_PsychoTeleport_InvulnTimer
	add  hl, bc
	dec  [hl]
	jp   nz, .obj2_moveH
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	res  PF1B_INVULN, [hl]
.obj2_moveH:
	call OBJLstS_ApplyXSpeed
	mMvC_ValFrameEnd .anim
		; Recovery lasts the least time possible
		mMvC_SetAnimSpeed ANIMSPEED_INSTANT
		jp   .anim
; --------------- frame #3 ---------------
.chkEnd:
	; Abruptly stop moving
	mMvC_SetSpeedH $0000
	mMvC_ValFrameEnd .anim
		;
		; If we started this move from the air, display the teleport sprite.
		;
		; This masks how ending a move snaps the player to the ground, since this
		; move really wasn't designed to be used in the air.
		; Actual moves designed to be done in the air wait for the player to have
		; landed on the ground before calling Play_Pl_EndMove.
		;
		ld   hl, iOBJInfo_Y
		add  hl, de
		ld   a, [hl]
		cp   PL_FLOOR_POS	; iOBJInfo_Y == PL_FLOOR_POS?
		jp   z, .end		; If so, skip
		call ProjInit_Athena_PsychoTeleport
	.end:
		call Play_Pl_EndMove
		jp   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Athena_ShCryst ===============
; Move code for Athena's Shining Crystal Bit (MOVE_ATHENA_SHINING_CRYSTAL_BIT_AD, MOVE_ATHENA_SHINING_CRYSTAL_BIT_GD, MOVE_ATHENA_SHINING_CRYSTAL_BIT_AS, MOVE_ATHENA_SHINING_CRYSTAL_BIT_AD).
MoveC_Athena_ShCryst:
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
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj4
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj5
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj6
	cp   $07*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj7
	cp   $08*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj8
; --------------- frame #0 ---------------
; Startup.
.obj0:
	; At the end of the frame...
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $01
		
		; Loop initial two-sphere part (#2 to #1) $0E times.
		ld   hl, iPlInfo_Athena_ShCryst_LoopTimer
		add  hl, bc
		ld   [hl], $0E
		; Start thrown projectile at the smallest size
		inc  hl			
		ld   [hl], $00	; iPlInfo_Athena_ShCryst_ProjSize = 0
		
		; Initialize the projectile
		call Task_PassControlFar
		call ProjInit_Athena_ShCrystCharge
		call Task_PassControlFar
		
		; Play ching SGB/DMG SFX
		mMvC_PlaySound SCT_SHCRYSTSPAWN
		call Task_PassControlFar
		jp   .anim
; --------------- frame #1-2 / Phase 1 input check macro ---------------
; This is the main logic that's performed during the first phase of the move.
; While the projectile code makes a small sphere orbit around Athena, we check for the following inputs:
; - DF+P (treated as light)
; - DB+P (treated as heavy)
;
; Performing any of them quickly switches to #4, past the point where the first
; part of the move would naturally end.
;
; The light/heavy flag influences the initial movement speed for the thrown projectile.
; If none of the inputs are performed, whatever LH settings we started the move with remain.
; However, to continue to #4 without performing the motions above, we must be holding B.
; Doing so causes the MoveInputS_CheckGAType call below to set the heavy flag anyway!
;
; So, the only real way to use the light speed versions is to perform the DF motions.
; IN
; - \1: [Optional] If set, enable easy move shortcuts
mShCr0_ChkInpt: MACRO
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	bit  PF0B_CPU, [hl]		; Is this player a CPU?
	jp   z, ._human_\@		; If not, jump
._cpu_\@:
	;
	; The CPU randomly decides what to do depending on the timer.
	;
	
	; If any of the lower 7 bits is set, don't do anything.
	; This leaves a $7F frame window at most for the CPU to not continue the move.
	ld   a, [wTimer]
	and  a, $7F				; (wTimer & $7F) != 0?
	jp   nz, ._noCont_\@	; If so, jump
	
	; Start the light or heavy versions of the second phase depending on the MSB.
	ld   a, [wTimer]
	bit  7, a					; MSB set?
	jp   z, .part1_startPart2L	; If not, start the light version
	jp   .part1_startPart2H		; Otherwise, start the heavy
._human_\@:
	;
	; Humans do the input check.
	;
IF _NARG > 0
IF \1 == 1
	; If enabled, allow shortcuts for the move inputs below
	;             SELECT + B          SELECT + A
	mMvIn_ChkEasy .part1_startPart2L, .part1_startPart2H
ENDC
ENDC
	; Must have pressed the punch button.
	call MoveInputS_CheckGAType
	jp   nc, ._noCont_\@	; Was an attack button pressed? If not, return
	jp   z, ._chkDir_\@		; Was the punch button pressed? If so, jump
	jp   ._noCont_\@		; Otherwise, the kick button was pressed.
._chkDir_\@:
	; Must have performed one of these two motions
	mMvIn_ChkDir MoveInput_DF, .part1_startPart2L
	mMvIn_ChkDir MoveInput_DB, .part1_startPart2H
._noCont_\@:
	; If we got here, we didn't continue to the next part this frame
ENDM

; --------------- frame #1 ---------------
; Phase 1 - double small sphere.
.obj1:
	mShCr0_ChkInpt
	jp   .anim
; --------------- frame #2 ---------------
; Phase 1 - double small sphere + loop check.
.obj2:
	; [POI] The English version has easy move shortcuts for this
	mShCr0_ChkInpt REV_VER_2
	mMvC_ValFrameEnd .anim
		; If we got here by the end of #2, check if we're looping back to #1.
		
		; If the counter elapsed, continue to #3.
		ld   hl, iPlInfo_Athena_ShCryst_LoopTimer
		add  hl, bc
		dec  [hl]		; LoopTimer--
		jp   z, .anim	; Did it elapse? If so, jump
		
		; Holding A ends the move early.
		ld   hl, iPlInfo_JoyKeys
		add  hl, bc
		bit  KEYB_A, [hl]			; Holding A?
		jp   nz, .part1_earlyEnd	; If so, jump
		
		; Loop back to #1
		mMvC_SetFrame $01*OBJLSTPTR_ENTRYSIZE, $01
		jp   .ret
; --------------- frames #1-2 / common phase 2 switch ---------------
; Phase 1 - Switches to the second phase through directional inputs.
.part1_startPart2L:
	ld   hl, iPlInfo_Flags2
	add  hl, bc
	res  PF2B_HEAVY, [hl]		; Continue with light version
	jp   .part1_earlySwitchToPart2
.part1_startPart2H:
	ld   hl, iPlInfo_Flags2
	add  hl, bc
	set  PF2B_HEAVY, [hl]		; Continue with hard version
.part1_earlySwitchToPart2:
	; Start from a clean buffer when checking for 360s
	call Play_Pl_ClearJoyDirBuffer
	
	; Switch to #4
	mMvC_SetFrame $04*OBJLSTPTR_ENTRYSIZE, $01
	
	; Slow down orbiting speed (new proj mode)
	call MoveS_Athena_ShCryst_SetOrbitNear
	
	; Initialize proj release timer to $100 for second phase.
	; This is how much time we're given to hold it/charge it before it automatically releases.
	ld   hl, iPlInfo_Athena_ShCryst_ReleaseTimer
	add  hl, bc
	ld   [hl], $00
	
	; Spawn the sparkle over Athena's hand (where the projectile orbits around in phase 2)
	mkhl -$08, -$18	; $08px back, $18px up
	ld   hl, CHL
	call Play_StartSuperSparkle
	jp   .ret
; --------------- frames #1-3 / early end ---------------
; Phase 1 - Ends the move immediately (as it's called under mMvC_ValFrameEnd)
.part1_earlyEnd:
	call Task_PassControlFar
	jp   .obj6
; --------------- frame #3 ---------------
; Phase 1 - Last frame for the first phase.
.obj3:
	mMvC_ValFrameEnd .anim
		
		; If not holding B, the move ends immediately.
		; To throw the projectile, we must held B at least until phase 2 starts.
		ld   hl, iPlInfo_JoyKeys
		add  hl, bc
		bit  KEYB_B, [hl]
		jp   z, .part1_earlyEnd
		
		;--
		; [POI] This doesn't make sense and is pointless.
		ld   hl, iPlInfo_Flags2
		add  hl, bc
		res  PF2B_MOVESTART, [hl]
		;--
		
		; Set orbiting mode to projectile
		call MoveS_Athena_ShCryst_SetOrbitNear
		
		; Initialize proj release timer to $100 for second phase.
		; This is how much time we're given to hold it/charge it before it automatically releases.
		ld   hl, iPlInfo_Athena_ShCryst_ReleaseTimer
		add  hl, bc
		ld   [hl], $00
		
		; Spawn the sparkle over Athena's hand (where the projectile orbits around in phase 2)
		mkhl -$08, -$18	; $08px back, $18px up
		ld   hl, CHL
		call Play_StartSuperSparkle
		jp   .anim
		
; --------------- frame #4 ---------------
; Phase 2 - Charging up the projectile.
; During this phase, the projectile orbits around Athena's hand, slowing down
; until it almost stops moving over it.
; From here, two actions can be performed:
; - Releasing B to immediately release the projectile
; - Performing 360s to increase its size up to 4 times (powerup cheat only)
.obj4:
	mMvC_ValFrameEnd .anim
		; Set a significant delay after releasing the projectile.
		; (it's done at the start of #5)
		mMvC_SetAnimSpeed $28
		
		; If the very long timer elapses, force release the projectile by continuing to #5 anyway.
		ld   hl, iPlInfo_Athena_ShCryst_ReleaseTimer
		add  hl, bc
		dec  [hl]		; LoopTimer--
		jp   z, .anim	; Is it 0 now? If so, jump
		
		;
		; Perform the immediate release check.
		;
		ld   hl, iPlInfo_Flags0
		add  hl, bc
		bit  PF0B_CPU, [hl]			; Are we a CPU?
		jp   z, .obj4_chkRelHuman	; If not, jump
	.obj4_chkRelCPU:
		; The CPU randomly picks when to release it.
		; The projectile is released when the global timer is > $7F && <= $FF
		ld   a, [wTimer]
		bit  7, a				; MSB set?
		jp   nz, .anim			; If so, release it
		jp   .obj4_chkEnlarge
	.obj4_chkRelHuman:
		; If the human player releases B, the projectile is thrown
		ld   hl, iPlInfo_JoyKeys
		add  hl, bc
		bit  KEYB_B, [hl]		; Releasing B?
		jp   z, .anim			; If so, continue to #5
		
	.obj4_chkEnlarge:
		;
		; [POI] With the powerup cheat, it's possible to enlarge the projectile up to 4 times.
		;       If we can't, we just return.
		;       Since we aren't calling .anim, it means we'll keep getting here until something
		;       else calls .anim (either by releasing B or having the release timer elapses).
		;
		ld   a, [wDipSwitch]
		bit  DIPB_POWERUP, a		; Cheat enabled?
		jp   z, .ret					; If not, return
		
		ld   hl, iPlInfo_Flags0
		add  hl, bc
		bit  PF0B_CPU, [hl]				; Are we a CPU?
		jp   z, .obj4_chkEnlargeHuman	; If not, jump
	.obj4_chkEnlargeCPU:
		; The CPU enlarges the projectile quickly over time, depending on the global timer.
		; (as long as we get here...)
		ld   a, [wTimer]
		and  a, $0F				; Any bits in the low nybble set? (wTimer & $0F != 0?)
		jp   z, .obj4_enlarge	; If so, enlarge it
		jp   .obj4_ret			; Otherwise, return
	.obj4_chkEnlargeHuman:
	
	

IF REV_VER_2 == 1
		; [POI] Easy move shortcut in the English version.
		;       Pressing SELECT + B gives a 12.5% chance of enlarging the sphere.
		call MoveInputS_CheckEasyMoveKeys
		jp   nc, .obj4_chkEnlargeHumanNoEasy	; SELECT + B pressed? If not, skip
		ld   a, [wTimer]
		and  $1F				; wTimer % $20 == 0?
		jp   z, .obj4_enlarge	; If so, jump
	.obj4_chkEnlargeHumanNoEasy:
ENDC
		; Human players must perform the input:
		; Backwards 360 -> Increase sphere size
		mMvIn_ChkDirNot MoveInput_DFUBD, .obj4_ret
		
			; Try to increase the projectile size
		.obj4_enlarge:
	
			; Don't increase it past the largest size
			ld   hl, iPlInfo_Athena_ShCryst_ProjSize
			add  hl, bc
			ld   a, [hl]			; A = ProjSize
			cp   a, PACT_SIZE_04	; A == $04?
			jp   z, .obj4_ret		; If so, return
			
			; Clear buffer for next 360 input
			call Play_Pl_ClearJoyDirBuffer
			
			; Re-display sparkle any time we successfully pulled off the 360 
			mkhl -$08, -$18	; $08px back, $18px up
			ld   hl, CHL
			call Play_StartSuperSparkle
			
			; *RESET* the release timer.
			; This means the 360s can be used to significantly extend how long
			; you can hold the sphere.
			ld   hl, iPlInfo_Athena_ShCryst_ReleaseTimer
			add  hl, bc
			ld   [hl], $00
			
			; Increase projectile size
			inc  hl		; Seek to iPlInfo_Athena_ShCryst_ProjSize
			inc  [hl]	; ++
			
			;
			; Switch to the appropriate animation/sprite mapping list for the new size.
			; All of the animation tables are in BANK $01.
			;
			ld   a, [hl]	; A = ProjSize
			push bc			; Save wPlInfo ptr
				push de		; Save wOBJInfo ptr
				
					; BC = Ptr to animation table		
					cp   a, PACT_SIZE_01		; ProjSize == 1?
					jp   z, .obj4_enlargeTo1	; If so, jump
					cp   a, PACT_SIZE_02		; ProjSize == 1?
					jp   z, .obj4_enlargeTo2	; If so, jump
					cp   a, PACT_SIZE_03		; ProjSize == 1?
					jp   z, .obj4_enlargeTo3	; If so, jump
												; Otherwise, ProjSize == 4
				.obj4_enlargeTo4:
					ld   bc, OBJLstPtrTable_Proj_Athena_ShCryst_OrbitS4
					jp   .obj4_setOBJLst
				.obj4_enlargeTo3:
					ld   bc, OBJLstPtrTable_Proj_Athena_ShCryst_OrbitS3
					jp   .obj4_setOBJLst
				.obj4_enlargeTo2:
					ld   bc, OBJLstPtrTable_Proj_Athena_ShCryst_OrbitS2
					jp   .obj4_setOBJLst
				.obj4_enlargeTo1:
					ld   bc, OBJLstPtrTable_Proj_Athena_ShCryst_OrbitS1
					
				.obj4_setOBJLst:
					; Seek to the sprite mapping table ptr
					ld   hl, (OBJINFO_SIZE*2) ; 2 slots after ours
					add  hl, de		; DE = Ptr to the wOBJInfo of our projectile
					push hl
					pop  de			; Move it to DE
					ld   hl, iOBJInfo_OBJLstPtrTbl_Low
					add  hl, de		; Seek to its iOBJInfo_OBJLstPtrTbl_Low
					
					; Write the new values over
					ld   [hl], c	; iOBJInfo_OBJLstPtrTbl_Low
					inc  hl
					ld   [hl], b	; iOBJInfo_OBJLstPtrTbl_High
					
				pop  de		; Restore wOBJInfo ptr
			pop  bc			; Restore wPlInfo ptr
	.obj4_ret:
		jp   .ret
; --------------- frame #5 ---------------
; Phase 3 - Throwing the (charged up) projectile.
.obj5:
	mMvC_ValFrameStart .obj5_cont
		
		; Each projectile size has its own damage settings.
		ld   hl, iPlInfo_Athena_ShCryst_ProjSize
		add  hl, bc
		ld   a, [hl]				; A = ProjSize
		cp   PACT_SIZE_04			; ProjSize == 4?
		jp   z, .obj5_setDamage4	; If so, jump
		cp   PACT_SIZE_03			; ProjSize == 3?
		jp   z, .obj5_setDamage3	; If so, jump
		cp   PACT_SIZE_02			; ProjSize == 2?
		jp   z, .obj5_setDamage2	; If so, jump
		cp   PACT_SIZE_01			; ProjSize == 1?
		jp   z, .obj5_setDamage1	; If so, jump
									; Otherwise, it's the normal sized one.
	.obj5_setDamageNorm:
		; Normal size.
		; This delivers a single hit, with the sphere despawning on hit.
		mMvC_PlaySound SCT_PROJ_SM
		mkhl $14, HITTYPE_DROP_MAIN
		ld   hl, CHL
		ld   a, PF3_HEAVYHIT|PF3_SUPERALT
		jp   .obj5_setDamage
	.obj5_setDamage1:
		; Size 1.
		; Single hit, more damage than the normal projectile.
		mMvC_PlaySound SCT_PROJ_SM
		mkhl $19, HITTYPE_DROP_MAIN
		ld   hl, CHL
		ld   a, PF3_HEAVYHIT|PF3_SUPERALT
		jp   .obj5_setDamage
	.obj5_setDamage2:
		; Sizes 2 - 4
		; These are all the same and deal low, continuous damage.
		mMvC_PlaySound SCT_PROJ_LG_B
		mkhl $03, HITTYPE_DROP_MAIN
		ld   hl, CHL
		ld   a, PF3_LASTHIT|PF3_SUPERALT|PF3_LIGHTHIT
		jp   .obj5_setDamage
	.obj5_setDamage3:
		mMvC_PlaySound SCT_PROJ_LG_B
		mkhl $03, HITTYPE_DROP_MAIN
		ld   hl, CHL
		ld   a, PF3_LASTHIT|PF3_SUPERALT|PF3_LIGHTHIT
		jp   .obj5_setDamage
	.obj5_setDamage4:
		mMvC_PlaySound SCT_PROJ_LG_B
		mkhl $03, HITTYPE_DROP_MAIN
		ld   hl, CHL
		ld   a, PF3_LASTHIT|PF3_SUPERALT|PF3_LIGHTHIT
	.obj5_setDamage:
		; Save the damage
		call Play_Pl_SetMoveDamageNext
		; Apply it to the projectile
		call Play_Proj_CopyMoveDamageFromPl
		; Throw the sphere projectile.
		call ProjInit_Athena_ShCrystThrown
.obj5_cont:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $03
		jp   .anim
		
; --------------- frame #6 ---------------
; Phase 1/4 - Recovery.
; This frame is shared between ground an air versions.
.obj6:
	mMvC_ValFrameEnd .anim
	
	; Ground-based versions of the move end here.
	; Meanwhile, air-based ones continue since we have to land on the ground first.
	; Not doing so would snap the player to the ground.
	ld   hl, iPlInfo_MoveId
	add  hl, bc
	ld   a, [hl]							
	cp   MOVE_ATHENA_SHINING_CRYSTAL_BIT_AS	; Doing the air super?
	jp   z, .obj6_setNext					; If so, jump
	cp   MOVE_ATHENA_SHINING_CRYSTAL_BIT_AD	; Doing the air desperation?
	jp   z, .obj6_setNext					; If so, jump
	call Play_Pl_EndMove
	jr   .ret
.obj6_setNext:
	mMvC_SetFrame $07*OBJLSTPTR_ENTRYSIZE, ANIMSPEED_NONE
	; In case we get here by having the move end early in Phase 1.
	; Make the projectile move in a spiral motion, extending outwards.
	call MoveS_Athena_ShCryst_SetOrbitExpand
	jp   .ret
; --------------- frame #7 ---------------
; Waits for the player to land on the ground before continuing.
; Exclusively when the move is started in the air.
.obj7:
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $08*OBJLSTPTR_ENTRYSIZE, $03
		jp   .ret
; --------------- frame #8 ---------------
; Recovery frame, after landing.
.obj8:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== ProjInit_Athena_PsychoTeleport ===============
; Initializes the special effect for Athena's Psycho Teleport.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo	
ProjInit_Athena_PsychoTeleport:
	mMvC_PlaySound SCT_PSYCTEL

	push bc
		push de
		
			; The oval thing we're spawning is an optional visual effect.
			; Don't spawn it if a projectile is already on screen.
			call MoveInputS_CanStartProjMove
			jp   nz, .end
			
			call ProjInitS_InitAndGetOBJInfo	; DE = Ptr to wOBJInfo_Pl*Projectile
		
			; Set code pointer
			ld   hl, iOBJInfo_Play_CodeBank
			add  hl, de
			ld   [hl], BANK(ProjC_NoMove)	; BANK $05 ; iOBJInfo_Play_CodeBank
			inc  hl
			ld   [hl], LOW(ProjC_NoMove)	; iOBJInfo_Play_CodePtr_Low
			inc  hl
			ld   [hl], HIGH(ProjC_NoMove)	; iOBJInfo_Play_CodePtr_High
			
			; Write sprite mapping ptr for this projectile.
			ld   hl, iOBJInfo_BankNum
			add  hl, de
			ld   [hl], BANK(OBJLstPtrTable_Proj_Athena_PsychoTeleport)	; BANK $01 ; iOBJInfo_BankNum
			inc  hl
			ld   [hl], LOW(OBJLstPtrTable_Proj_Athena_PsychoTeleport)	; iOBJInfo_OBJLstPtrTbl_Low
			inc  hl
			ld   [hl], HIGH(OBJLstPtrTable_Proj_Athena_PsychoTeleport)	; iOBJInfo_OBJLstPtrTbl_High
			inc  hl
			ld   [hl], $00	; iOBJInfo_OBJLstPtrTblOffset

			; Set animation speed.
			ld   hl, iOBJInfo_FrameLeft
			add  hl, de
			ld   [hl], $00	; iOBJInfo_FrameLeft
			inc  hl
			ld   [hl], ANIMSPEED_INSTANT	; iOBJInfo_FrameTotal
			
			; Set priority value and despawn timer
			ld   hl, iOBJInfo_Play_Priority
			add  hl, de
			ld   [hl], $00	; iOBJInfo_Play_Priority
			inc  hl
			ld   [hl], $0B	; iOBJInfo_Play_EnaTimer
			
			; Place on the current player's position and stay there
			call OBJLstS_Overlap
			mMvC_SetMoveH $0000
			mMvC_SetMoveV $0000
			mMvC_SetSpeedH $0000
		.end:
		pop  de
	pop  bc
	ret
; =============== ProjInit_Athena_PsychoBall ===============
; Initializes the projectile for Athena's Psycho Ball.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
ProjInit_Athena_PsychoBall:
	mMvC_PlaySound SCT_PROJ_LG_B
	
	push bc
		push de
		
			; --------------- common projectile init code ---------------
			
			;
			; C flag = If set, we're at max power
			;
			ld   hl, iPlInfo_Pow
			add  hl, bc
			ld   a, [hl]		; A = Pow meter
			cp   PLAY_POW_MAX	; Are we at max power?
			jp   z, .initMaxPow	; If so, jump
			xor  a				; C flag clear
			jp   .getFlags2
		.initMaxPow:
			scf					; C flag set
		.getFlags2:
			;
			; A = iPlInfo_Flags2
			;
			ld   hl, iPlInfo_Flags2
			push af				; Preserve C flag for this
				add  hl, bc		; Seek to iPlInfo_Flags2
			pop  af
			ld   a, [hl]		; Read out to A
			
			push af ; Save A & C flag
				
				call ProjInitS_InitAndGetOBJInfo	; DE = Ptr to wOBJInfo_Pl*Projectile
				
				; --------------- main ---------------
			
				; Set code pointer
				ld   hl, iOBJInfo_Play_CodeBank
				add  hl, de
				ld   [hl], BANK(ProjC_Horz)	; BANK $06 ; iOBJInfo_Play_CodeBank
				inc  hl
				ld   [hl], LOW(ProjC_Horz)	; iOBJInfo_Play_CodePtr_Low
				inc  hl
				ld   [hl], HIGH(ProjC_Horz)	; iOBJInfo_Play_CodePtr_High
				
				; Write sprite mapping ptr for this projectile.
				ld   hl, iOBJInfo_BankNum
				add  hl, de
				ld   [hl], BANK(OBJLstPtrTable_Proj_Athena_PsychoBall)	; BANK $01 ; iOBJInfo_BankNum
				inc  hl
				ld   [hl], LOW(OBJLstPtrTable_Proj_Athena_PsychoBall)	; iOBJInfo_OBJLstPtrTbl_Low
				inc  hl
				ld   [hl], HIGH(OBJLstPtrTable_Proj_Athena_PsychoBall)	; iOBJInfo_OBJLstPtrTbl_High
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
				
				; Set initial position relative to the player's origin
				call OBJLstS_Overlap
				mMvC_SetMoveH +$1000
				mMvC_SetMoveV -$0400
				
			;
			; Determine projectile horizontal speed.
			;
		
			pop  af						; Restore A & C flag
			jp   nc, .fldNoMaxPow		; Are we at max power? If not, jump
		.fldMaxPow:
			bit  PF2B_HEAVY, a			; Was this an heavy attack?
			jp   nz, .fldHeavyMaxPow	; If so, jump
			jp   .fldLight
		.fldNoMaxPow:
			bit  PF2B_HEAVY, a			; Was this an heavy attack?
			jp   nz, .fldHeavy			; If so, jump
		.fldLight:
			ld   hl, +$0100
			jp   .setSpeed
		.fldHeavy:
			ld   hl, +$0200
			jp   .setSpeed
		.fldHeavyMaxPow:
			ld   hl, +$0400
		.setSpeed:
			call Play_OBJLstS_SetSpeedH_ByXFlipR
		pop  de
	pop  bc
	ret
	
; =============== ProjInit_Athena_ShCrystThrown ===============
; Initializes the projectile for Athena's Shining Crystal Bit after it gets thrown (phase 3).
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
ProjInit_Athena_ShCrystThrown:
	push bc
		push de
			; A = Projectile size
			ld   hl, iPlInfo_Athena_ShCryst_ProjSize
			add  hl, bc
			ld   a, [hl]
			
			; Generate the C flag value, which later is used to distinguish between groups of throw speeds.
			; See also: mShCr0_ChkInpt, where the heavy/light flag could be influenced.
			push af
				mMvIn_ChkLH .isH	; Light or heavy?
			.isL:
				xor  a	; C clear - light
				jp   .getMoveId
			.isH:
				scf		; C set - heavy
				
			.getMoveId:
				; A = Move Id
				ld   hl, iPlInfo_MoveId
				push af
					add  hl, bc
				pop  af
				ld   a, [hl]
				
				push af
				
					; A = Projectile size
					ld   hl, iPlInfo_Athena_ShCryst_ProjSize
					add  hl, bc
					ld   a, [hl]
					
					push af
						call ProjInitS_InitAndGetOBJInfo	; DE = Ptr to wOBJInfo_Pl*Projectile
						
						; Set code pointer
						ld   hl, iOBJInfo_Play_CodeBank
						add  hl, de
						ld   [hl], BANK(ProjC_Athena_ShCrystThrown)	; BANK $06 ; iOBJInfo_Play_CodeBank
						inc  hl
						ld   [hl], LOW(ProjC_Athena_ShCrystThrown)	; iOBJInfo_Play_CodePtr_Low
						inc  hl
						ld   [hl], HIGH(ProjC_Athena_ShCrystThrown)	; iOBJInfo_Play_CodePtr_High
					pop  af
					
					push bc
					
						;
						; Each size uses its own sprite mappings and priority value.
						; All of the sprite mappings must be in BANK $01.
						;
						; The larger projetiles use priority $04, which is treated in a special way here.
						; These are projectiles dealing continuous damage (as it is >= $03) that
						; override the default speed settings (see .setSpeed*)
						;
						; These types map to the four various move assignments associated to the move.
						;
						cp   PACT_SIZE_NORM	; Normal size?
						jp   z, .sizeNorm	; If so, jump
						cp   PACT_SIZE_01	; Size 1?
						jp   z, .size1		; If so, jump
						cp   PACT_SIZE_02	; Size 2?
						jp   z, .size2		; If so, jump
						cp   PACT_SIZE_03	; Size 3?
						jp   z, .size3		; If so, jump
					.size4:					; Otherwise, assume size 4
						ld   bc, OBJLstPtrTable_Proj_Athena_ShCryst_ThrownS4	; Sprite mapping ptr
						ld   a, PROJ_PRIORITY_ALTSPEED							; Priority	
						jp   .setOBJLst
					.size3:
						ld   bc, OBJLstPtrTable_Proj_Athena_ShCryst_ThrownS3
						ld   a, PROJ_PRIORITY_ALTSPEED
						jp   .setOBJLst
					.size2:
						ld   bc, OBJLstPtrTable_Proj_Athena_ShCryst_ThrownS2
						ld   a, PROJ_PRIORITY_ALTSPEED
						jp   .setOBJLst
					.size1:
						ld   bc, OBJLstPtrTable_Proj_Athena_ShCryst_ThrownS1
						ld   a, $01
						jp   .setOBJLst
					.sizeNorm:
						ld   bc, OBJLstPtrTable_Proj_Athena_ShCryst_ThrownNorm	
						ld   a, $01
						
					.setOBJLst:
					
						; Set priority value
						ld   hl, iOBJInfo_Play_Priority
						add  hl, de
						ld   [hl], a
						
						; Write sprite mapping ptr for this projectile.
						ld   hl, iOBJInfo_BankNum
						add  hl, de
						ld   [hl], BANK(OBJLstPtrTable_Proj_Athena_ShCryst_ThrownNorm) ; BANK $01 ; iOBJInfo_BankNum
						inc  hl
						ld   [hl], c	; iOBJInfo_OBJLstPtrTbl_Low
						inc  hl
						ld   [hl], b	; iOBJInfo_OBJLstPtrTbl_High
						inc  hl
						ld   [hl], $00	; iOBJInfo_OBJLstPtrTblOffset
					pop  bc
					
					; Set animation speed.
					ld   hl, iOBJInfo_FrameLeft
					add  hl, de
					ld   [hl], $00	; iOBJInfo_FrameLeft
					inc  hl
					ld   [hl], ANIMSPEED_INSTANT	; iOBJInfo_FrameTotal
				
					; Set initial position relative to the player's origin
					call OBJLstS_Overlap
					mMvC_SetMoveH +$1000
					mMvC_SetMoveV -$1000
					
				;
				; Determine the initial throw speed depending on the combination of:
				; - If the super move was triggered by a light or heavy (C flag here)
				; - If we did the ground or air version
				;
				; What actually differs between these is the ball's vertical speed.
				; Notably, the value is larger in the air version to make the projectile move diagonally down.
				;
				; For convenience in the projectile code later on, each combination is also assigned its own unique ID,
				; which is then used to execute type-specific movement code.
				;
					
				pop  af ; A = Move Id
				
				jp   nc, .setSpeedL	; Was it done as a heavy? If not, jump
			.setSpeedH:
				cp   MOVE_ATHENA_SHINING_CRYSTAL_BIT_GS	; Ground super?
				jp   z, .setSpeedHG						; If so, jump
				cp   MOVE_ATHENA_SHINING_CRYSTAL_BIT_GD	; Ground desperation?
				jp   z, .setSpeedHG						; If so, jump
				jp   .setSpeedHA						; Otherwise, it's the air variant
			.setSpeedL:
				cp   MOVE_ATHENA_SHINING_CRYSTAL_BIT_GS	; Ground super?
				jp   z, .setSpeedLG						; If so, jump
				cp   MOVE_ATHENA_SHINING_CRYSTAL_BIT_GD	; Ground desperation?
				jp   z, .setSpeedLG						; If so, jump
				jp   .setSpeedLA						; Otherwise, it's the air variant
				
			.setSpeedLG:
				; Type $01 - Straight projectile
			pop  af
			mMvC_SetSpeedH +$0500
			mMvC_SetSpeedV +$0000
			ld   hl, iOBJInfo_Proj_ShCrystThrow_TypeId
			add  hl, de
			ld   [hl], PROJ_SHCRYST2_TYPE_GL
			jp   .end
			
			.setSpeedHG:
				; Type $02 - Projectile moving slightly downwards (before it rises up)
			pop  af
			mMvC_SetSpeedH +$0500
			mMvC_SetSpeedV +$0100
			ld   hl, iOBJInfo_Proj_ShCrystThrow_TypeId
			add  hl, de
			ld   [hl], PROJ_SHCRYST2_TYPE_GH
			jp   .end
			
			.setSpeedLA:
				; Type $03 - Air projectile moving diagonally down
			pop  af
			mMvC_SetSpeedH +$0500
			mMvC_SetSpeedV +$0400
			ld   hl, iOBJInfo_Proj_ShCrystThrow_TypeId
			add  hl, de
			ld   [hl], PROJ_SHCRYST2_TYPE_AL
			jp   .end
			
			.setSpeedHA:
				; Type $04 - Air projectile moving diagonally down (before it rises up)
			pop  af
			mMvC_SetSpeedH +$0500
			mMvC_SetSpeedV +$0500
			ld   hl, iOBJInfo_Proj_ShCrystThrow_TypeId
			add  hl, de
			ld   [hl], PROJ_SHCRYST2_TYPE_AH
			jp   .end
			
			.end:
		pop  de
	pop  bc
	ret
	
; =============== ProjC_Athena_ShCrystThrown ===============
; Projectile code for Athena's Shining Crystal Bit
ProjC_Athena_ShCrystThrown:
	; Handle movement
	call ExOBJS_Play_ChkHitModeAndMoveH
	jp   c, .despawn
	
	; Animate
	call OBJLstS_DoAnimTiming_Loop_by_DE
	
	; Execute the animation code depending on the throw type.
	; There are three handlers:
	; - Light ground:
	;   Direct horizontal movement (fwd), with no gravity.
	; - Light air: 
	;   Direct horizontal/vertical movement (fwd, down), with no gravity.
	;   This despawns when it touches the ground, unlike the others.
	; - Heavy (both ground and air):
	;   Like the light air version, except These are subject to reverse gravity, making the projectile
	;   progressively move up faster.
	;
	; Note that *ALL* of these handlers have to account for the special priority type $04,
	; as that's determined by the unrelated projectile size.
	; This priority type overrides the default horizontal speed of +$05 with a lower value
	; that becomes even lower when it collides with the opponent.
	;
	ld   hl, iOBJInfo_Proj_ShCrystThrow_TypeId
	add  hl, de
	ld   a, [hl]				; A = TypeId
	cp   PROJ_SHCRYST2_TYPE_GH	; Ground Heavy type?
	jp   z, .typeH				; If so, jump
	cp   PROJ_SHCRYST2_TYPE_AL	; Light air type?
	jp   z, .typeAL				; If so, jump
	cp   PROJ_SHCRYST2_TYPE_AH	; Heavy air type?
	jp   z, .typeH				; If so, jump
	; Otherwise, assume PROJ_SHCRYST2_TYPE_LG, the ground light type

; --------------- GROUND - LIGHT ---------------
.typeGL:
	; Don't do anything if Priority != $04
	ld   hl, iOBJInfo_Play_Priority
	add  hl, de
	ld   a, [hl]
	cp   PROJ_PRIORITY_ALTSPEED	; Priority != $04?
	jp   nz, .typeGL_ret		; If so, jump
	
	; If the projectile didn't collide, move it at 3px/frame.
	; Otherwise, move it at 0.5px/frame.
	ld   hl, iOBJInfo_Play_HitMode
	add  hl, de
	ld   a, [hl]
	cp   a, PHM_NONE			; Did the projectile collide with the opponent?
	jp   z, .typeGL_noHit		; If not, jump
.typeGL_hit:
	mMvC_SetSpeedH +$0080
	jp   .ret
.typeGL_noHit:
	mMvC_SetSpeedH +$0300
	jp   .ret
.typeGL_ret:
	jp   .ret
	
; --------------- GROUND/AIR - HEAVY ---------------
.typeH:
	; Use simple settings if Priority != $04
	ld   hl, iOBJInfo_Play_Priority
	add  hl, de
	ld   a, [hl]
	cp   PROJ_PRIORITY_ALTSPEED	; Priority != $04?
	jp   nz, .typeH_norm		; If so, jump
	
	; If the projectile didn't collide, move it at 4px/frame.
	; Otherwise, move it at 0.5px/frame and set its gravity to 2px/frame down.
	; This has the effect of these "heavy" projectiles that normally curve up to switch direction.
	
	; The English version uses completely different speed settings, which makes the direction
	; switching seen in the Japanese version impossible to do (but they still curve).
	ld   hl, iOBJInfo_Play_HitMode
	add  hl, de
	ld   a, [hl]
	cp   a, PHM_NONE			; Did the projectile collide with the opponent?
	jp   z, .typeH_noHit		; If not, jump
	
IF REV_VER_2 == 0

.typeH_hit:
	mMvC_SetSpeedH +$0080
	mMvC_DoGravityV +$0200
	jp   .ret
.typeH_noHit:
	mMvC_SetSpeedH +$0400
	mMvC_DoGravityV -$0060
	jp   .ret
.typeH_norm:
	mMvC_DoGravityV -$0060
	jp   .ret
	
ELSE	
	
.typeH_hit:
	mMvC_SetSpeedH +$0040
	mMvC_DoGravityV +$0000
	jp   .ret
.typeH_noHit:
	; The projectile slows down when it touches the ground
	mMvC_ChkGravityV -$0030, .typeH_noHit_groundHit
		mMvC_SetSpeedH +$0300
		jp   .ret
.typeH_noHit_groundHit:
	mMvC_SetSpeedH +$0080
	jp   .ret
.typeH_norm:
	mMvC_DoGravityV -$0060
	jp   .ret
ENDC

; --------------- AIR - LIGHT ---------------
.typeAL:
	; Only handle downwards movement if Priority != $04
	ld   hl, iOBJInfo_Play_Priority
	add  hl, de
	ld   a, [hl]
	cp   PROJ_PRIORITY_ALTSPEED	; Priority != $04?
	jp   nz, .typeAL_norm		; If so, jump

	; If the projectile didn't collide, move it at 3px/frame forward, 2px/frame down.
	; Otherwise, move it at 0.5px/frame forward, and at 2px/frame *up*.
	;
	; Like with Heavy projectiles, the English version uses different speed settings
	; that prevent the direction from switching -- the sphere keeps moving down.
	; They also move diagonally down at fixed 45° angles.
	ld   hl, iOBJInfo_Play_HitMode
	add  hl, de
	ld   a, [hl]
	cp   a, PHM_NONE			; Did the projectile collide with the opponent?
	jp   z, .typeAL_noHit		; If not, jump
	
IF REV_VER_2 == 0
.typeAL_hit:
	mMvC_SetSpeedH +$0080
	mMvC_SetSpeedV -$0200
	mMvC_ChkGravityV +$0000, .despawn
	jp   .ret
.typeAL_noHit:
	mMvC_SetSpeedH +$0300
	mMvC_SetSpeedV +$0200
	mMvC_ChkGravityV +$0000, .despawn
	jp   .ret
.typeAL_norm:
	; Despawn the projectile when it moves off-screen below
	mMvC_ChkGravityV $0000, .despawn
	jp   .ret
ELSE
.typeAL_hit:
	mMvC_SetSpeedH +$0040
	mMvC_SetSpeedV +$0040
	mMvC_DoGravityV +$0000
	jp   .ret
.typeAL_noHit:
	mMvC_SetSpeedH +$0200
	mMvC_SetSpeedV +$0200
	mMvC_DoGravityV +$0000
	jp   .ret
.typeAL_norm:
	; Despawn the projectile when it moves off-screen below
	mMvC_ChkGravityV $0000, .despawn
	jp   .ret
ENDC
	
; --------------- common ---------------
.ret:
	ret
.despawn:
	call OBJLstS_Hide
	ret
	
; =============== ProjInit_Athena_ShCrystCharge ===============
; Initializes the projectile for Athena's Shining Crystal Bit before it gets thrown.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
ProjInit_Athena_ShCrystCharge:
	push bc
		push de
			call ProjInitS_InitAndGetOBJInfo
			
			; Set code pointer
			ld   hl, iOBJInfo_Play_CodeBank
			add  hl, de
			ld   [hl], BANK(ProjC_Athena_ShCrystCharge)	; BANK $06 ; iOBJInfo_Play_CodeBank
			inc  hl
			ld   [hl], LOW(ProjC_Athena_ShCrystCharge)	; iOBJInfo_Play_CodePtr_Low
			inc  hl
			ld   [hl], HIGH(ProjC_Athena_ShCrystCharge)	; iOBJInfo_Play_CodePtr_High
			
			; Write sprite mapping ptr for this projectile.
			; We start out in dual swirl mode.
			ld   hl, iOBJInfo_BankNum
			add  hl, de
			ld   [hl], BANK(OBJLstPtrTable_Proj_Athena_ShCryst_Swirl)	; BANK $01 ; iOBJInfo_BankNum
			inc  hl
			ld   [hl], LOW(OBJLstPtrTable_Proj_Athena_ShCryst_Swirl)	; iOBJInfo_OBJLstPtrTbl_Low
			inc  hl
			ld   [hl], HIGH(OBJLstPtrTable_Proj_Athena_ShCryst_Swirl)	; iOBJInfo_OBJLstPtrTbl_High
			inc  hl
			ld   [hl], $00	; iOBJInfo_OBJLstPtrTblOffset

			; Set animation speed.
			ld   hl, iOBJInfo_FrameLeft
			add  hl, de
			ld   [hl], $00	; iOBJInfo_FrameLeft
			inc  hl
			ld   [hl], ANIMSPEED_INSTANT	; iOBJInfo_FrameTotal
			
			; Set initial position relative to the player's origin
			call OBJLstS_Overlap
			mMvC_SetMoveH +$0000
			mMvC_SetMoveV -$1000
			
			; Save a copy of the player's position to the projectile's slot.
			; This is because it's used as the projectile's origin.
			; This exact thing will be also done when updating the origin through ProjC_Athena_ShCrystCharge_SetOrigin
			push bc
				; BC = Ptr to X Position
				ld   hl, iOBJInfo_X
				add  hl, de
				push hl
				pop  bc
				
				; Copy it over to iOBJInfo_Proj_ShCrystCharge_OrigX
				ld   hl, iOBJInfo_Proj_ShCrystCharge_OrigX
				add  hl, de		
				ld   a, [bc]	; A = X Position
				ldi  [hl], a	; Save it to iOBJInfo_Proj_ShCrystCharge_OrigX, seek to iOBJInfo_Proj_ShCrystCharge_OrigY
				
				; Copy over the Y position to iOBJInfo_Proj_ShCrystCharge_OrigY
				inc  bc			; Seek to iOBJInfo_XSub
				inc  bc			; Seek to iOBJInfo_Y
				ld   a, [bc]	; A = Y Position
				ld   [hl], a	; Save it to iOBJInfo_Proj_ShCrystCharge_OrigY
			pop  bc
			
			; Set priority value
			ld   hl, iOBJInfo_Play_Priority
			add  hl, de
			ld   [hl], $02
				
			; Initialize the X and Y indexes for the sine coords table.
			; For the electron-like movement, the indexes are set up so that the projectile
			; initially moves right and down, and increment by $20 and $22 respectively
			; so they won't sync.
			xor  a
			ld   hl, iOBJInfo_Proj_ShCrystCharge_XPosId
			add  hl, de
			ld   [hl], $00	; iOBJInfo_Proj_ShCrystCharge_XPosId ($0000, then right)
			inc  hl ; neg
			ld   [hl], $80	; iOBJInfo_Proj_ShCrystCharge_YPosId ($0000, then down)
			
			; Multipliers start at $00
			inc  hl
			ldi  [hl], a	; iOBJInfo_Proj_ShCrystCharge_XPosMul
			ld   [hl], a	; iOBJInfo_Proj_ShCrystCharge_YPosMul
			
			; Start from the first phase
			ld   hl, iOBJInfo_Proj_ShCrystCharge_OrbitMode
			add  hl, de
			ld   [hl], PROJ_SHCRYST_ORBITMODE_OVAL
			
			; 8 times for smooth origin transition between Slow and Hold mode
			ld   hl, iOBJInfo_Proj_ShCrystCharge_OrigMoveLeft
			add  hl, de
			ld   [hl], $08
		pop  de
	pop  bc
	ret
	
; =============== MoveS_Athena_ShCryst_SetOrbitNear ===============
; Sets the initial orbit mode for "Phase 2".
; This is when Athena holds an hand up, with the projectile's orbit slowly
; getting smaller. 
; IN
; - DE: Ptr to player wOBJInfo
MoveS_Athena_ShCryst_SetOrbitNear:
	push bc
		push de
			; BC = DE = Ptr to wOBJInfo
			push de
			pop  bc
			
			; DE = Ptr to the wOBJInfo of our projectile
			ld   hl, (OBJINFO_SIZE*2) ; 2 slots after ours
			add  hl, bc
			push hl
			pop  de
			
			; Set the new orbit mode
			ld   hl, iOBJInfo_Proj_ShCrystCharge_OrbitMode
			add  hl, de
			ld   [hl], PROJ_SHCRYST_ORBITMODE_SLOW
		pop  de
	pop  bc
	ret
	
; =============== MoveS_Athena_ShCryst_SetOrbitExpand ===============
; Sets the orbit mode used when the move ends early, before reaching "Phase 2".
; This causes the projectile to expand in a spiral motion.
; IN
; - DE: Ptr to player wOBJInfo
MoveS_Athena_ShCryst_SetOrbitExpand:
	push bc
		push de
			; BC = DE = Ptr to wOBJInfo
			push de
			pop  bc
			
			; DE = Ptr to the wOBJInfo of our projectile
			ld   hl, (OBJINFO_SIZE*2) ; 2 slots after ours
			add  hl, bc
			push hl
			pop  de
			
			; Set the new orbit mode.
			; This value will cause the mode checker to fall into .switchToSpiral
			ld   hl, iOBJInfo_Proj_ShCrystCharge_OrbitMode
			add  hl, de
			ld   [hl], PROJ_SHCRYST_ORBITMODE_SPIRAL
		pop  de
	pop  bc
	ret
	
; =============== ProjC_Athena_ShCrystCharge ===============
; Projectile code for Athena's Shining Crystal Bit while it gets charged up.
; While charging, the projectile always orbits something.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo for the projectile
ProjC_Athena_ShCrystCharge:
	; 30FPS exec, across players
	call ProjC_Athena_ShCrystCharge_CanExec
	ret  c
	
	; Just in case, make the projectile move in an expanding spiral motion if the move ended early.
	; This is already handled by the code calling MoveS_Athena_ShCryst_SetOrbitExpand though.
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	bit  PF0B_SUPERMOVE, [hl]
	jp   z, .switchToSpiral
	
	; Depending on the phase of the projectile...
	ld   hl, iOBJInfo_Proj_ShCrystCharge_OrbitMode
	add  hl, de
	ld   a, [hl]
	cp   PROJ_SHCRYST_ORBITMODE_OVAL
	jp   z, ProjC_Athena_ShCrystCharge_Oval
	cp   PROJ_SHCRYST_ORBITMODE_SLOW
	jp   z, ProjC_Athena_ShCrystCharge_Slow
	cp   PROJ_SHCRYST_ORBITMODE_HOLD
	jp   z, ProjC_Athena_ShCrystCharge_Hold

.switchToSpiral:

	;
	; The spiral motion isn't an oval-like orbit, and it gets its own different code pointer
	; so it won't be able to switch to some other mode.
	;

	; Reset indexes to fixed values
	ld   hl, iOBJInfo_Proj_ShCrystCharge_XPosId
	add  hl, de
	ld   [hl], $00	; iOBJInfo_Proj_ShCrystCharge_XPosId ($0000, moves right)
	inc  hl
	ld   [hl], $40	; iOBJInfo_Proj_ShCrystCharge_YPosId ($4000, rightmost value, so first to move left)
	
	; Move deals no damage
	ld   hl, iOBJInfo_Play_DamageVal
	add  hl, de
	xor  a
	ldi  [hl], a	; iOBJInfo_Play_DamageVal
	ldi  [hl], a	; iOBJInfo_Play_DamageHitTypeId
	ld   [hl], a	; iOBJInfo_Play_DamageFlags3
	
	; Set a new code pointer
	ld   hl, iOBJInfo_Play_CodeBank
	add  hl, de
	ld   [hl], BANK(ProjC_Athena_ShCrystCharge_Spiral) 	; BANK $06 ; iOBJInfo_Play_CodeBank
	inc  hl
	ld   [hl], LOW(ProjC_Athena_ShCrystCharge_Spiral)	; iOBJInfo_Play_CodePtr_Low
	inc  hl
	ld   [hl], HIGH(ProjC_Athena_ShCrystCharge_Spiral)	; iOBJInfo_Play_CodePtr_High
	
	; Base multiplier is large
	ld   hl, iOBJInfo_Proj_ShCrystCharge_XPosMul
	add  hl, de
	ld   [hl], $04	; iOBJInfo_Proj_ShCrystCharge_XPosMul
	inc  hl
	ld   [hl], $05	; iOBJInfo_Proj_ShCrystCharge_YPosMul
	
	; Display spiral for $0E frames
	ld   hl, iOBJInfo_Proj_ShCrystCharge_DespawnTimer
	add  hl, de
	ld   [hl], $0E	; iOBJInfo_Proj_ShCrystCharge_DespawnTimer
	ret
	
; =============== ProjC_Athena_ShCrystCharge_Oval ===============
; Initial electron-like mode.
ProjC_Athena_ShCrystCharge_Oval:
	;
	; First, always sync the origin 16px above the player's origin
	;
	ld   b, +$00
	ld   c, -$10
	call ProjC_Athena_ShCrystCharge_SetOrigin
	
	
	;
	; Then, update the X and Y coordinates, starting with the former.
	; In short, positions are read from a table of 16bit values (pixel + subpixels)
	; and exponentially multiplied ( << ) by some value.
	; Each coordinate has its own index to the table and multiplier, but the table
	; of coordinates is the same.
	;

	;
	; X POSITION
	;
	; XPos = POW(Coords[XPosId+$20], MAX(XPosMul+1, 5))
	; 
	
	;
	; Increase the position multiplier from $00 until it reaches $05.
	; This is done every time we get here, so the multiplier quickly reaches
	; the target value.
	; This is to make it look like the projectile "launched" itself from the origin
	; before following the normal oval path.
	;
	ld   hl, iOBJInfo_Proj_ShCrystCharge_XPosMul
	add  hl, de		; HL = Ptr to Multiplier
	ld   a, [hl]	; A = Multiplier
	cp   $05		; A == 5?
	jp   z, .getX	; If so, jump
	inc  [hl]		; Otherwise, Multiplier++
.getX:

	;
	; Read out to B the relative X position off the table.
	;
		
	; Get/save the new index to the table of coords.
	; A = XPosId + $20
	ld   hl, iOBJInfo_Proj_ShCrystCharge_XPosId
	add  hl, de
	ld   a, [hl]
	add  a, $20		; Index += $20
	ld   [hl], a	; and save back the updated index
	
	; B = Value multiplier
	ld   hl, iOBJInfo_Proj_ShCrystCharge_XPosMul
	add  hl, de
	ld   b, [hl]
	
	; B = Rel. X Position
	call ProjC_Athena_ShCrystCharge_GetSinePos
	
	;
	; Set the new X position.
	; ProjX = OriginX + RelX
	;
	
	ld   hl, iOBJInfo_Proj_ShCrystCharge_OrigX
	add  hl, de
	ld   a, [hl]			; A = X Origin
	add  b					; A += B
	ld   hl, iOBJInfo_X		
	add  hl, de				; HL = Ptr to X Pos
	ld   [hl], a			; Update it
	
	;--
	
	;
	; Y POSITION
	; Same thing, but with a different addresses/settings.
	;
	
	; Increase multiplier every time, up to $06
	ld   hl, iOBJInfo_Proj_ShCrystCharge_YPosMul
	add  hl, de
	ld   a, [hl]
	cp   $06
	jp   z, .getY
	inc  [hl]
.getY:
	; Get/save table index
	; A = LastId + $22
	; This extra $02 compared to the horz one makes the vertical movement faster than the horizontal one.
	ld   hl, iOBJInfo_Proj_ShCrystCharge_YPosId
	add  hl, de
	ld   a, [hl]
	add  a, $22
	ld   [hl], a	; and save it back
	
	; B = Multiplier
	ld   hl, iOBJInfo_Proj_ShCrystCharge_YPosMul
	add  hl, de
	ld   b, [hl]
	
	; B = Rel. Y position
	call ProjC_Athena_ShCrystCharge_GetSinePos
	
	; ProjY = OrigY + RelY
	ld   hl, iOBJInfo_Proj_ShCrystCharge_OrigY
	add  hl, de
	ld   a, [hl]			; A = Y Origin
	add  b					; A += B
	ld   hl, iOBJInfo_Y		
	add  hl, de				; HL = Ptr to Y Pos
	ld   [hl], a			; Update it
	ret
	
; =============== ProjC_Athena_ShCrystCharge_Hold ===============
; Only different thing from ProjC_Athena_ShCrystCharge_Slow in that
; the origin is on Athena's hand.
; It's not even necessary anyway, since ProjC_Athena_ShCrystCharge_Slow aligns it perfectly already.
ProjC_Athena_ShCrystCharge_Hold:
	; Origin is...
	ld   b, +$08 ; 8px behind player (hand)
	ld   c, -$18 ; $18px above player
	call ProjC_Athena_ShCrystCharge_SetOrigin
	; Fall-through
	
; =============== ProjC_Athena_ShCrystCharge_Slow ===============
; Like oval mode, but the arc keeps getting smaller.
ProjC_Athena_ShCrystCharge_Slow:

	;
	; First, slowly move the origin over Athena's hand for a smooth transition
	; to Hold mode. When we're done, switch to Hold mode when we're done.
	;
	; This moves the origin 1px backwards and 1px upwards every 8 frames,
	; and it gets done $08 times (what iOBJInfo_Proj_ShCrystCharge_OrigMoveLeft was set to).
	;
	; Considering the origin before getting here is set to:
	; - $00px horz
	; - $10px up
	; By the time we switch to Hold mode, it will be:
	; - $08px back
	; - $18px up
	; Which is the exact origin used by that mode.
	;
	
	; Only do this every 8 frames
	ld   hl, iOBJInfo_Proj_ShCrystCharge_OrigMoveTimer
	add  hl, de
	inc  [hl]		; Timer++
	ld   a, [hl]		
	and  a, $07		; Timer % 8 != 0?
	jp   nz, .doX	; If so, skip
	
	; Don't do this if we switched to Hold mode already, as that uses its own origin.
	; (it's the only point OrigMoveLeft can be 0 here)
	ld   hl, iOBJInfo_Proj_ShCrystCharge_OrigMoveLeft
	add  hl, de
	ld   a, [hl]
	or   a			; OrigMoveLeft == 0?
	jp   z, .doX	; If so, skip
	
	; Decrement counter of remaining UB movements.
	; If this is the last time we're getting here (OrigMoveLeft-1 == 0), switch to Hold mode.
	dec  [hl]				; MoveLeft--
	jp   nz, .moveOrigBack	; MoveLeft != 0? If so, skip
	; Otherwise, switch to Hold mode
	ld   hl, iOBJInfo_Proj_ShCrystCharge_OrbitMode
	add  hl, de
	ld   [hl], PROJ_SHCRYST_ORBITMODE_HOLD
	
.moveOrigBack:
	; Move origin backwards by 1px.
	; Determine which side the projectile is facing first.
	ld   hl, iOBJInfo_OBJLstFlags
	add  hl, de
	bit  SPRB_XFLIP, [hl]	; Facing right? (originally thrown on 1P side)
	jp   nz, .moveOrigL		; If so, move it left (backwards for 1P side)
	; Otherwise, move it right (backwards for 2P side)
.moveOrigR:
	; OrigX++
	ld   hl, iOBJInfo_Proj_ShCrystCharge_OrigX
	add  hl, de
	inc  [hl]
	jp   .moveOrigU
.moveOrigL:
	; OrigX--
	ld   hl, iOBJInfo_Proj_ShCrystCharge_OrigX
	add  hl, de
	dec  [hl]
	
.moveOrigU:
	; Move origin up by 1px
	ld   hl, iOBJInfo_Proj_ShCrystCharge_OrigY
	add  hl, de
	dec  [hl]
	
	
.doX:
	;
	; Then, update the X and Y coordinates, starting with the former.
	; This process is very similar to what's done in ProjC_Athena_ShCrystCharge_Oval,
	; except that the multipliers get decremented slowly (not incremented every frame)
	; and that the YPos index is incremented by a different value.
	;

	;
	; X POSITION
	;

	;
	; Slowly decrement the X Position multiplier from $05 to $01 every $20 frames.
	;
	
	; DecTimer++
	ld   hl, iOBJInfo_Proj_ShCrystCharge_XPosMulUpdTimer
	add  hl, de
	inc  [hl]
	
	; Get divider mask.
	; B = DecTimer % $20
	ld   a, [hl]
	and  a, $1F
	ld   b, a
	
	; Seek to XPosMul
	; HL = Ptr to iOBJInfo_Proj_ShCrystCharge_XPosMul
	ld   hl, iOBJInfo_Proj_ShCrystCharge_XPosMul
	add  hl, de
	
	; If the multiplier is already $01, don't decrement it further
	ld   a, [hl]		; A = XPosMul
	cp   $01			; XPosMul == 1?
	jp   z, .getX		; If so, skip
	
	; Otherwise, decrement the multiplier if (DecTimer % $20) != 0
	ld   a, b			
	or   a				; DecTimer != 0?
	jp   nz, .getX		; If so, skip
	dec  [hl]			; Otherwise, XPosMul--	
	
.getX:
	;
	; Read out to B the relative X position off the table, then apply it.
	;
	
	; Get/save table index
	; A = LastId + $20
	ld   hl, iOBJInfo_Proj_ShCrystCharge_XPosId
	add  hl, de
	ld   a, [hl]
	add  a, $20
	ld   [hl], a	; and save it back
	
	; B = Multiplier
	ld   hl, iOBJInfo_Proj_ShCrystCharge_XPosMul
	add  hl, de
	ld   b, [hl]
	
	; B = Rel. X position
	call ProjC_Athena_ShCrystCharge_GetSinePos
	
	; ProjX = OrigX + RelX
	ld   hl, iOBJInfo_Proj_ShCrystCharge_OrigX
	add  hl, de
	ld   a, [hl]			; A = X Origin
	add  b					; A += B
	ld   hl, iOBJInfo_X		
	add  hl, de				; HL = Ptr to X Pos
	ld   [hl], a			; Update it
	
.doY:
	;
	; Y POSITION
	;
	
	;
	; Decrement the Y Position multiplier from $06 to $01 every *alternating* $20 frames.
	; (that is, decrement for $20 continuous frames, then nothing for the next $20, and so on).
	; This causes the Y Multiplier to decrement much faster than the horizontal one, though
	; because YPosMulDecTimer (and XPosMulDecTimer) don't get initialized, the actual point this happens
	; is effectively randomized depending on how long we held the projectile the previous times.
	;
	
	; DecTimer++
	ld   hl, iOBJInfo_Proj_ShCrystCharge_YPosMulUpdTimer
	add  hl, de
	inc  [hl]
	
	; Get divider mask.
	; B = DecTimer & $20
	ld   a, [hl]
	and  a, $20
	ld   b, a
	
	; Seek to YPosMul
	; HL = Ptr to iOBJInfo_Proj_ShCrystCharge_YPosMul
	ld   hl, iOBJInfo_Proj_ShCrystCharge_YPosMul
	add  hl, de
	
	; If the multiplier is already $01, don't decrement it further
	ld   a, [hl]		; A = YPosMul
	cp   $01			; YPosMul == 1?
	jp   z, .getY		; If so, skip
	
	; Otherwise, decrement the multiplier if (DecTimer & $20) != 0
	ld   a, b			
	or   a				; DecTimer != 0?
	jp   nz, .getY		; If so, skip
	dec  [hl]			; Otherwise, YPosMul--	
	
.getY:
	;
	; Read out to B the relative Y position off the table, then apply it.
	;
	
	; Get/save table index
	; A = LastId + $1F
	; This makes the vertical movement slightly slower than the horizontal one ($20).
	ld   hl, iOBJInfo_Proj_ShCrystCharge_YPosId
	add  hl, de
	ld   a, [hl]
	add  a, $1F
	ld   [hl], a	; and save it back
	
	; B = Multiplier
	ld   hl, iOBJInfo_Proj_ShCrystCharge_YPosMul
	add  hl, de
	ld   b, [hl]
	
	; B = Rel. Y position
	call ProjC_Athena_ShCrystCharge_GetSinePos
	
	; ProjY = OrigY + RelY
	ld   hl, iOBJInfo_Proj_ShCrystCharge_OrigY
	add  hl, de
	ld   a, [hl]			; A = Y Origin
	add  b					; A += B
	ld   hl, iOBJInfo_Y		
	add  hl, de				; HL = Ptr to Y Pos
	ld   [hl], a			; Update it
	ret
	
; =============== ProjC_Athena_ShCrystCharge_Spiral ===============
; Spiral outwards motion, used to despawn the projectile when the move ends early.
; Code-wise, it's very similar to the other modes.
ProjC_Athena_ShCrystCharge_Spiral:
	; 30FPS exec, across players
	call ProjC_Athena_ShCrystCharge_CanExec
	ret  c
	
	; Not necessary, already done by .switchToSpiral
	ld   hl, iOBJInfo_Play_DamageVal
	add  hl, de
	xor  a
	ldi  [hl], a	; iOBJInfo_Play_DamageVal
	ldi  [hl], a	; iOBJInfo_Play_DamageHitTypeId
	ld   [hl], a	; iOBJInfo_Play_DamageFlags3
	
	; Despawn the projectile when the timer expires
	ld   hl, iOBJInfo_Proj_ShCrystCharge_DespawnTimer
	add  hl, de
	dec  [hl]
	jp   z, OBJLstS_Hide
	
.doX:
	;
	; X POSITION
	;

	;
	; Quickly increment the X Position multiplier every 4 frames, with no upper limit.
	;
	
	; IncTimer++
	ld   hl, iOBJInfo_Proj_ShCrystCharge_XPosMulUpdTimer
	add  hl, de
	inc  [hl]
	
	; Get divider mask.
	; B = IncTimer % 4
	ld   a, [hl]
	and  a, $03
	ld   b, a
	
	; Seek to XPosMul
	; HL = Ptr to iOBJInfo_Proj_ShCrystCharge_XPosMul
	ld   hl, iOBJInfo_Proj_ShCrystCharge_XPosMul
	add  hl, de
	
	; Increment the multiplier with no upper limit if (IncTimer % 4) != 0
	ld   a, b
	or   a				; IncTimer % 4 != 0?
	jp   nz, .getX		; If so, skip
	inc  [hl]			; Otherwise, XPosMul++	
	
.getX:
	;
	; Read out to B the relative X position off the table, then apply it.
	;
	
	; Get/save table index
	; A = LastId + $20
	ld   hl, iOBJInfo_Proj_ShCrystCharge_XPosId
	add  hl, de
	ld   a, [hl]
	add  a, $20
	ld   [hl], a	; and save it back
	
	; B = Multiplier
	ld   hl, iOBJInfo_Proj_ShCrystCharge_XPosMul
	add  hl, de
	ld   b, [hl]
	
	; B = Rel. X position
	call ProjC_Athena_ShCrystCharge_GetSinePos
	
	; ProjX = OrigX + RelX
	ld   hl, iOBJInfo_Proj_ShCrystCharge_OrigX
	add  hl, de
	ld   a, [hl]			; A = X Origin
	add  b					; A += B
	ld   hl, iOBJInfo_X		
	add  hl, de				; HL = Ptr to X Pos
	ld   [hl], a			; Update it
	
.doY:
	;
	; Y POSITION
	;
	
	;
	; Quickly increment the X Position multiplier every 8 frames, with no upper limit.
	;
	
	; IncTimer++
	ld   hl, iOBJInfo_Proj_ShCrystCharge_YPosMulUpdTimer
	add  hl, de
	inc  [hl]
	
	; Get divider mask.
	; B = IncTimer % 8
	ld   a, [hl]
	and  a, $07
	ld   b, a
	
	; Seek to YPosMul
	; HL = Ptr to iOBJInfo_Proj_ShCrystCharge_YPosMul
	ld   hl, iOBJInfo_Proj_ShCrystCharge_YPosMul
	add  hl, de
	
	; Increment the multiplier with no upper limit if (IncTimer % 8) != 0
	ld   a, b
	or   a				; IncTimer % 8 != 0?
	jp   nz, .getY		; If so, skip
	inc  [hl]			; Otherwise, YPosMul++	
.getY:
	;
	; Read out to B the relative Y position off the table, then apply it.
	;
	
	; Get/save table index
	; A = LastId + $20
	; This is exactly the same as the horizontal one, resulting in a spiral motion
	; as the multipliers grow without limit.
	ld   hl, iOBJInfo_Proj_ShCrystCharge_YPosId
	add  hl, de
	ld   a, [hl]
	add  a, $20
	ld   [hl], a	; and save it back
	
	; B = Multiplier
	ld   hl, iOBJInfo_Proj_ShCrystCharge_YPosMul
	add  hl, de
	ld   b, [hl]
	
	; B = Rel. Y position
	call ProjC_Athena_ShCrystCharge_GetSinePos
	
	; ProjY = OrigY + RelY
	ld   hl, iOBJInfo_Proj_ShCrystCharge_OrigY
	add  hl, de
	ld   a, [hl]			; A = Y Origin
	add  b					; A += B
	ld   hl, iOBJInfo_Y		
	add  hl, de				; HL = Ptr to Y Pos
	ld   [hl], a			; Update it
	ret
	
; =============== ProjC_Athena_ShCrystCharge_CanExec ===============
; Called at the start of the charging projectile code to determine if 
; the rest of the code should be executed.
; This projectile is special in that it executes its code every other
; gameplay frame, alternating between 1P and 2P.
; Even frames -> 2P exec
; Odd  frames -> 1P exec
; IN
; - BC: Ptr to wPlInfo
; OUT
; - C flag: If set, the code should not execute
ProjC_Athena_ShCrystCharge_CanExec:
	ld   hl, iPlInfo_PlId
	add  hl, bc
	ld   a, [hl]
	cp   PL2			; Playing as 2P?
	jp   z, .pl2		; If so, jump
.pl1:
	ld   a, [wPlayTimer]
	bit  0, a			; wPlayTimer % 2 == 0? (even frame)
	jp   z, .retSet		; If so, no exec
	jp   .retClear		; Otherwise, exec it
.pl2:
	ld   a, [wPlayTimer]
	bit  0, a			; wPlayTimer % 2 != 0? (odd frame)
	jp   nz, .retSet	; If so, no exec
.retClear:
	scf
	ccf		; C flag clear
	ret
.retSet:
	scf		; C flag set
	ret
	
; =============== ProjC_Athena_ShCrystCharge_GetSinePos ===============
; Gets a value from the coordinates table and shifts it left B times.
; IN
; - A: Index to coordinates table
; - B: Multiplier
; OUT
; - B: Returned position.
;      This will be treated as an X or Y position depending on the context.
ProjC_Athena_ShCrystCharge_GetSinePos:
	push de
		push hl
			; HL = Base 16bit value (for multiplier $00)
			call ProjC_Athena_ShCrystCharge_GetBaseSinePos
			
			; Shift it left B times. B will be at most 6.
			; HL = HL << B
		.loop:
			sla  l			; HL << 1
			rl   h
			dec  b			; Did it all times?
			jp   nz, .loop	; If not, loop
			
			; And move it to BC.
			; Only the high byte (pixel count) is usable, since the subpixels got trashed
			; by the shifting, which is fine as projectile positions don't use subpixels.
			push hl	; BC = HL
			pop  bc
			
		pop  hl
	pop  de
	ret
	
; =============== ProjC_Athena_ShCrystCharge_SetOrigin ===============
; Sets a new origin for the projectile, relative to the player's current position.
; IN
; - B: X Offset.
;      This is relative to the projectile facing *left*, so positive values move it backwards.
; - C: Y Offset.
; - DE: Ptr to wOBJInfo for projectile
ProjC_Athena_ShCrystCharge_SetOrigin:

	;
	; Refresh the base origin first.
	; Copy the player's X and Y positions to iOBJInfo_Proj_ShCrystCharge_Orig*.
	;
	push bc
		push de
			; BC = Ptr to the X Origin of the projectile (Destination)
			ld   hl, iOBJInfo_Proj_ShCrystCharge_OrigX
			add  hl, de
			push hl
			pop  bc
			
			; HL = Ptr to the player's X position (Source)
			push de
				; This requires seeking back to the player's wOBJInfo.
				; As always, it's 2 slots before the one for the projectile, in DE.
				ld   hl, -(OBJINFO_SIZE*2)
				add  hl, de		; HL = iOBJInfo_Status for player
				
				; Seek to the X position
				ld   de, iOBJInfo_X
				add  hl, de
			pop  de
			
			; Sync the X origin
			ld   a, [hl]	; Read Player X Position
			ld   [bc], a	; Copy it over as new X origin
			
			; Sync the Y origin
			inc  hl			; Seek to iOBJInfo_XSub
			inc  hl			; Seek to iOBJInfo_YSub
			inc  bc			; Seek to iOBJInfo_Proj_ShCrystCharge_OrigY
			ld   a, [hl]	; Read Player Y Position
			ld   [bc], a	; Copy it over as new Y origin
		pop  de
	pop  bc
	
	;
	; Apply the X Offset.
	; Bizzarely, positive offset values make set it backwards here.
	;
	ld   hl, iOBJInfo_OBJLstFlags
	add  hl, de
	bit  SPRB_XFLIP, [hl]	; Is the projectile facing right? (initially thrown on the 1P side?)
	jp   nz, .setPosR		; If so, jump
	; Otherwise, it's facing left (2P side)
.setPosL:
	; iOBJInfo_Proj_ShCrystCharge_OrigX += B
	ld   hl, iOBJInfo_Proj_ShCrystCharge_OrigX
	add  hl, de
	ld   a, [hl]	; A = OrigX
	add  b			; += OffsetX
	ld   [hl], a	; Save it back
	jp   .setPosY
	
.setPosR:
	; iOBJInfo_Proj_ShCrystCharge_OrigX -= B
	ld   hl, iOBJInfo_Proj_ShCrystCharge_OrigX
	add  hl, de		; HL = Ptr to OrigX
	ld   a, b		; A = -OffsetX
	cpl
	inc  a
	ld   b, [hl]	; B = OrigX
	add  b			; += OffsetX
	ld   [hl], a	; Save it back
	
	;
	; Apply the Y Offset.
	;
.setPosY:
	; iOBJInfo_Proj_ShCrystCharge_OrigY += C
	ld   hl, iOBJInfo_Proj_ShCrystCharge_OrigY
	add  hl, de
	ld   a, [hl]	; A = OrigY
	add  c			; += OffsetY
	ld   [hl], a	; Save it back
	ret
	
; =============== ProjC_Athena_ShCrystCharge_GetBaseSinePos ===============
; Gets a base coordinate position for the projectile from the coordinates table.
; IN
; - A: Position ID.
; OUT
; - HL: Position (pixels + subpixels)
;       This value will be treated as either an X or Y position, depending
;       on the context this ended up getting called.
ProjC_Athena_ShCrystCharge_GetBaseSinePos:
	push bc
		; Generate offset to a table of 2-byte positions
		; BC = A * 2
		ld   b, $00
		ld   c, a
		sla  c
		rl   b
		
		; Offset the table
		ld   hl, .sineTbl
		add  hl, bc
		
		; Read out the raw value to BC
		ld   c, [hl]
		inc  hl
		ld   b, [hl]
		
		; For whatever reason, the raw value isn't directly the base value pre-multiplication.
		; Instead, it's the base value shifted right 6 times (*$40), which is the value that
		; would be used with the max multiplier.
		
		; Since we want the base value though, divide it by $40 (>> 6).
		; As we're only using the upper byte (so what's the point of the low one?), we're fine
		; since 6 < 9 shifts.
		; HL = BC / $40
REPT 6
		sra  b	; >> 1 , 6 times
		rr   c
ENDR
		push bc	; Move it to HL
		pop  hl
		
	pop  bc
	ret
	
; SINE TABLE
; Table of incrementing and decrementing 16bit signed numbers (pixels + subpixels).
; Used in order, one by one, these result in the projectile moving in a smooth sine motion.
; To generate the various movement patterns, the X and Y indexes are incremented by
; different offsets.
.sineTbl: 
	dw $0000
	dw $0192
	dw $0324
	dw $04B5
	dw $0646
	dw $07D6
	dw $0964
	dw $0AF1
	dw $0C7C
	dw $0E06
	dw $0F8D
	dw $1112
	dw $1294
	dw $1413
	dw $1590
	dw $1709
	dw $187E
	dw $19EF
	dw $1B5D
	dw $1CC6
	dw $1E2B
	dw $1F8C
	dw $20E7
	dw $223D
	dw $238E
	dw $24DA
	dw $2620
	dw $2760
	dw $289A
	dw $29CE
	dw $2AFB
	dw $2C21
	dw $2D41
	dw $2E5A
	dw $2F6C
	dw $3076
	dw $3179
	dw $3274
	dw $3368
	dw $3453
	dw $3537
	dw $3612
	dw $36E5
	dw $37AF
	dw $3871
	dw $392B
	dw $39DB
	dw $3A82
	dw $3B21
	dw $3BB6
	dw $3C42
	dw $3CC5
	dw $3D3F
	dw $3DAF
	dw $3E15
	dw $3E72
	dw $3EC5
	dw $3F0F
	dw $3F4F
	dw $3F85
	dw $3FB1
	dw $3FD4
	dw $3FEC
	dw $3FFB
	dw $4000
	dw $3FFB
	dw $3FEC
	dw $3FD4
	dw $3FB1
	dw $3F85
	dw $3F4F
	dw $3F0F
	dw $3EC5
	dw $3E72
	dw $3E15
	dw $3DAF
	dw $3D3F
	dw $3CC5
	dw $3C42
	dw $3BB6
	dw $3B21
	dw $3A82
	dw $39DB
	dw $392B
	dw $3871
	dw $37AF
	dw $36E5
	dw $3612
	dw $3537
	dw $3453
	dw $3368
	dw $3274
	dw $3179
	dw $3076
	dw $2F6C
	dw $2E5A
	dw $2D41
	dw $2C21
	dw $2AFB
	dw $29CE
	dw $289A
	dw $2760
	dw $2620
	dw $24DA
	dw $238E
	dw $223D
	dw $20E7
	dw $1F8C
	dw $1E2B
	dw $1CC6
	dw $1B5D
	dw $19EF
	dw $187E
	dw $1709
	dw $1590
	dw $1413
	dw $1294
	dw $1112
	dw $0F8D
	dw $0E06
	dw $0C7C
	dw $0AF1
	dw $0964
	dw $07D6
	dw $0646
	dw $04B5
	dw $0324
	dw $0192
	dw $0000
	dw $FE6E
	dw $FCDC
	dw $FB4B
	dw $F9BA
	dw $F82A
	dw $F69C
	dw $F50F
	dw $F384
	dw $F1FA
	dw $F073
	dw $EEEE
	dw $ED6C
	dw $EBED
	dw $EA70
	dw $E8F8
	dw $E782
	dw $E611
	dw $E4A3
	dw $E33A
	dw $E1D5
	dw $E074
	dw $DF19
	dw $DDC3
	dw $DC72
	dw $DB26
	dw $D9E0
	dw $D8A0
	dw $D766
	dw $D632
	dw $D505
	dw $D3DF
	dw $D2BF
	dw $D1A6
	dw $D094
	dw $CF8A
	dw $CE87
	dw $CD8C
	dw $CC98
	dw $CBAD
	dw $CAC9
	dw $C9EE
	dw $C91B
	dw $C851
	dw $C78F
	dw $C6D5
	dw $C625
	dw $C57E
	dw $C4DF
	dw $C44A
	dw $C3BE
	dw $C33B
	dw $C2C2
	dw $C252
	dw $C1EB
	dw $C18E
	dw $C13B
	dw $C0F1
	dw $C0B1
	dw $C07B
	dw $C04F
	dw $C02C
	dw $C014
	dw $C005
	dw $C000
	dw $C005
	dw $C014
	dw $C02C
	dw $C04F
	dw $C07B
	dw $C0B1
	dw $C0F1
	dw $C13B
	dw $C18E
	dw $C1EB
	dw $C252
	dw $C2C2
	dw $C33B
	dw $C3BE
	dw $C44A
	dw $C4DF
	dw $C57E
	dw $C625
	dw $C6D5
	dw $C78F
	dw $C851
	dw $C91B
	dw $C9EE
	dw $CAC9
	dw $CBAD
	dw $CC98
	dw $CD8C
	dw $CE87
	dw $CF8A
	dw $D094
	dw $D1A6
	dw $D2BF
	dw $D3DF
	dw $D505
	dw $D632
	dw $D766
	dw $D8A0
	dw $D9E0
	dw $DB26
	dw $DC72
	dw $DDC3
	dw $DF19
	dw $E074
	dw $E1D5
	dw $E33A
	dw $E4A3
	dw $E611
	dw $E782
	dw $E8F8
	dw $EA70
	dw $EBED
	dw $ED6C
	dw $EEEE
	dw $F073
	dw $F1FA
	dw $F384
	dw $F50F
	dw $F69C
	dw $F82A
	dw $F9BA
	dw $FB4B
	dw $FCDC
	dw $FE6E


; =============== MoveC_Base_AttackG_MF07 ===============
; Generic move code used for A+B ground attacks that move the player 7px forwards once.
MoveC_Base_AttackG_MF07:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]	; A = OBJLst ID
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj0
; --------------- frames #1-(end) ---------------	
.chkMatch:
	; Check for ending the move when reaching the target sprite
	mMvC_ChkTarget .chkEnd
	jp   .anim
; --------------- frame #0 ---------------
; Move the player forwards by 7px when switching to frame #1.
.obj0:
	mMvC_ValFrameStart .obj0_anim
	mMvC_SetMoveH $0700						; 7px forwards
.obj0_anim:
	jp   .anim
; --------------- common ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
	call Play_Pl_EndMove
	jp   .ret
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveInputReader_Andy ===============
; Special move input checker for ANDY.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
; OUT
; - C flag: If set, a move was started
MoveInputReader_Andy:
	mMvIn_Validate Andy
	
.chkAir:
	mMvIn_ChkGA Andy, .chkAirPunch, .chkAirKick
.chkAirKick:
	; DF+K (air) -> Genei Shiranui
	mMvIn_ChkDir MoveInput_DF, MoveInit_Andy_GeneiShiranui
.chkAirPunch:
	; End
	jp   MoveInputReader_Andy_NoMove
	
.chkGround:
	;             SELECT + B                 SELECT + A
	mMvIn_ChkEasy MoveInit_Andy_ChoReppaDan, MoveInit_Andy_HiShoKen
	mMvIn_ChkGA Andy, .chkPunch, .chkKick

.chkPunch:
	; BDF+P (close) -> Geki Heki Hai Sui Sho
	mMvIn_ValClose .chkPunchNoClose
	mMvIn_ChkDir MoveInput_BDF, MoveInit_Andy_GekiHekiHaiSuiSho
.chkPunchNoClose:
	; BF+P -> Zan Ei Ken
	mMvIn_ChkDir MoveInput_BF_Fast, MoveInit_Andy_ZanEiKen
	; FDF+P -> Sho Ryu Dan
	mMvIn_ChkDir MoveInput_FDF, MoveInit_Andy_ShoRyuDan
	; DB+P -> Hi Sho Ken
	mMvIn_ChkDir MoveInput_DB, MoveInit_Andy_HiShoKen
	; End
	jp   MoveInputReader_Andy_NoMove
.chkKick:
	mMvIn_ValSuper .chkKickNoSuper
	; DBDF+K -> Cho Reppa Dan
	mMvIn_ChkDir MoveInput_DBDF, MoveInit_Andy_ChoReppaDan
.chkKickNoSuper:
	; BDF+K -> Ku Ha Dan 
	mMvIn_ChkDir MoveInput_BDF, MoveInit_Andy_KuHaDan 
	; End
	jp   MoveInputReader_Andy_NoMove
; =============== MoveInit_Andy_HiShoKen ===============
MoveInit_Andy_HiShoKen:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_ANDY_HI_SHO_KEN_L, MOVE_ANDY_HI_SHO_KEN_H
	call MoveInputS_SetSpecMove_StopSpeed
	;--
	; What
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	;--
	jp   MoveInputReader_Andy_SetMove
; =============== MoveInit_Andy_ZanEiKen ===============
MoveInit_Andy_ZanEiKen:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_ANDY_ZAN_EI_KEN_L, MOVE_ANDY_ZAN_EI_KEN_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Andy_SetMove
; =============== MoveInit_Andy_KuHaDan ===============
MoveInit_Andy_KuHaDan:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_ANDY_KU_HA_DAN_L, MOVE_ANDY_KU_HA_DAN_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Andy_SetMove
; =============== MoveInit_Andy_ShoRyuDan ===============
MoveInit_Andy_ShoRyuDan:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_ANDY_SHO_RYU_DAN_L, MOVE_ANDY_SHO_RYU_DAN_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Andy_SetMove
; =============== MoveInit_Andy_GekiHekiHaiSuiSho ===============
MoveInit_Andy_GekiHekiHaiSuiSho:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_ANDY_GEKI_HEKI_HAI_SUI_SHO_L, MOVE_ANDY_GEKI_HEKI_HAI_SUI_SHO_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Andy_SetMove
; =============== MoveInit_Andy_GeneiShiranui ===============
MoveInit_Andy_GeneiShiranui:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_ANDY_GENEI_SHIRANUI_L, MOVE_ANDY_GENEI_SHIRANUI_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Andy_SetMove
; =============== MoveInit_Andy_ChoReppaDan ===============
MoveInit_Andy_ChoReppaDan:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetSD MOVE_ANDY_CHO_REPPA_DAN_S, MOVE_ANDY_CHO_REPPA_DAN_D
	call MoveInputS_SetSpecMove_StopSpeed
	; This super removes projectiles
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	set  PF0B_PROJREM, [hl]
	inc  hl
	inc  hl
	jp   MoveInputReader_Andy_SetMove
; =============== MoveInputReader_Andy_SetMove ===============
MoveInputReader_Andy_SetMove:
	scf
	ret
; =============== MoveInputReader_Andy_NoMove ===============
MoveInputReader_Andy_NoMove:
	or   a
	ret

; =============== MoveC_Andy_HiShoKen ===============
; Move code for Andy's Hi Sho Ken (MOVE_ANDY_HI_SHO_KEN_L, MOVE_ANDY_HI_SHO_KEN_H).
MoveC_Andy_HiShoKen:
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
	jp   z, .chkEnd
	jp   .anim ; We never get here
; --------------- frame #0 ---------------	
.obj0:
	mMvC_ValFrameStart .obj0_cont
		call MoveInputS_CheckMoveLHVer
		jp   z, .obj0_cont
		mMvC_SetMoveH $0700
.obj0_cont:
	mMvC_ValFrameEnd .anim
		mMvC_PlaySound SCT_HISHOKEN
		jp   .anim
; --------------- frame #1 ---------------	
.obj1:
	mMvC_ValFrameStart .obj1_cont
		call MoveInputS_CheckMoveLHVer
		jp   z, .obj1_cont
		mMvC_SetMoveH $0700
.obj1_cont:
	mMvC_ValFrameEnd .anim
		jp   .anim
; --------------- frame #2 ---------------	
.obj2:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $06
		jp   .anim
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
	
; =============== MoveC_Andy_ZanEiKen ===============
; Move code for Andy's Zan Sho Ken (MOVE_ANDY_ZAN_EI_KEN_L, MOVE_ANDY_ZAN_EI_KEN_H).
; Contains submove:
; - Gadankoh
MoveC_Andy_ZanEiKen:
	call Play_Pl_AddToJoyBufKeysLH
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
	jp   z, .chkEnd
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .gadankoh_obj0
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim ; We never get here
; --------------- frame #0 ---------------	
.obj0:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $05
		; Initialize marker
		ld   hl, iPlInfo_Andy_ZanEiKen_OtherHit
		add  hl, bc
		ld   [hl], $00
		jp   .anim
; --------------- frame #1 ---------------	
.obj1:
	mMvC_ValFrameStart .obj1_cont
		mMvC_PlaySound SFX_STEP
		; Set a different horizontal speed depending on move strength
		mMvIn_ChkLHE .obj1_setSpeedH, .obj1_setSpeedE
	.obj1_setSpeedL: ; Light
		ld   hl, $0500
		jp   .obj1_setSpeed
	.obj1_setSpeedH: ; Heavy
		ld   hl, $0600
		jp   .obj1_setSpeed
	.obj1_setSpeedE: ; [POI] Hidden Heavy
		ld   hl, $0700
	.obj1_setSpeed:
		call Play_OBJLstS_SetSpeedH_ByXFlipR
.obj1_cont:
	jp   .chkSubInput
; --------------- frame #2 ---------------	
.obj2:
	; Apply friction of 1px/frame until the player stops moving.
	; When that happens, switch to #3.
	; As OBJLstS_ApplyFrictionHAndMoveH already moves the player, calling OBJLstS_ApplyXSpeed will
	; will effectively move the player twice as fast / frame.
	mMvC_DoFrictionH $0100
	jp   nc, .chkSubInput
	mMvC_SetFrame $03*OBJLSTPTR_ENTRYSIZE, $0A
	jp   .ret
; --------------- frames #1,#2 / common submove check ---------------	
; Performs checks if the submove (Gadankoh) should start.
; This is triggered by hitting the opponent (no whiff) and *after* that doing a light punch.
.chkSubInput:
	; Set the marker if our hitbox overlapped the player's collision box
	ld   hl, iPlInfo_ColiFlags
	add  hl, bc
	bit  PCF_HITOTHER, [hl]		; Did we reach?
	jp   z, .chkSubInput_val	; If not, skip
	ld   hl, iPlInfo_Andy_ZanEiKen_OtherHit
	add  hl, bc
	ld   [hl], $01				; Otherwise, OtherHit = 1
.chkSubInput_val:

	; Move should not whiff
	ld   hl, iPlInfo_Andy_ZanEiKen_OtherHit
	add  hl, bc
	bit  0, [hl]				; OtherHit == 0?
	jp   z, .moveH				; If so, jump
	
	; Doing a light punch NOW will deal a second hit and drop the opponent
	ld   hl, iPlInfo_JoyNewKeysLH
	add  hl, bc
	ld   a, [hl]
	bit  KEPB_B_LIGHT, a		; Did we press LP now?
	jp   z, .moveH				; If not, jump
	
	; Otherwise, switch to the submove
	mMvC_SetFrame $04*OBJLSTPTR_ENTRYSIZE, $06
	call OBJLstS_ApplyXSpeed
	mMvC_SetDamageNext $04, HITTYPE_DROP_MAIN, PF3_HEAVYHIT
	jp   .ret
; --------------- Gadankoh frame #0 (frame #4) ---------------	
.gadankoh_obj0:
	mMvC_DoFrictionH $0080
	; OBJLstS_ApplyFrictionHAndMoveH already moves the sprite. 
	; Calling OBJLstS_ApplyXSpeed too will effectively move it twice as fast / frame.
	mMvC_ValFrameEnd .moveH
		jp   .anim
; --------------- frames #2,#4 / common horizontal movement ---------------	
.moveH:
	call OBJLstS_ApplyXSpeed
	jp   .anim
; --------------- frames #3,#5 ---------------	
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jp   .ret
; --------------- common ---------------	
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Andy_KuHaDan ===============
; Move code for Andy's Ku Ha Dan (MOVE_ANDY_KU_HA_DAN_L, MOVE_ANDY_KU_HA_DAN_H).	
MoveC_Andy_KuHaDan:
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
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .doGravity
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
; --------------- frame #0 ---------------	
.obj0:
	mMvC_ValFrameStart .obj0_cont
		mMvC_SetMoveH +$0700
.obj0_cont:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $04, HITTYPE_HIT_MID1, PF3_HEAVYHIT|PF3_LASTHIT
		jp   .anim
; --------------- frame #1 ---------------	
.obj1:
	mMvC_ValFrameStart .obj1_cont
		mMvC_SetMoveH +$0700
.obj1_cont:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		mMvC_SetDamageNext $04, HITTYPE_HIT_MID0, PF3_HEAVYHIT|PF3_LASTHIT
		jp   .anim
; --------------- frame #2 ---------------	
.obj2:
	mMvC_ValFrameStart .obj2_cont
		mMvC_PlaySound SCT_MOVEJUMP_B
		mMvC_SetMoveH +$0700
		; Set jump speed depending on move strength
		mMvIn_ChkLHE .obj2_setJumpH, .obj2_setJumpE
	.obj2_setJumpL: ; Light
		mMvC_SetSpeedH +$0300
		mMvC_SetSpeedV -$0480
		jp   .obj2_setJump
	.obj2_setJumpH: ; Heavy
		mMvC_SetSpeedH +$0400
		mMvC_SetSpeedV -$0500
		jp   .obj2_setJump
	.obj2_setJumpE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH +$0500
		mMvC_SetSpeedV -$0580
	.obj2_setJump:
		jp   .doGravity
.obj2_cont:
	mMvC_NextFrameOnGtYSpeed -$02, ANIMSPEED_NONE
	jp   nc, .doGravity	; Reached Y Speed > - $02? If not, jump
		mMvC_SetDamageNext $04, HITTYPE_HIT_MID0, PF3_HEAVYHIT|PF3_LASTHIT
		jp   .doGravity
; --------------- frame #3 ---------------	
.obj3:
	mMvC_NextFrameOnGtYSpeed +$00, ANIMSPEED_NONE
	jp   nc, .doGravity	; Reached Y Speed > 0? If not, jump
		mMvC_SetDamageNext $04, HITTYPE_HIT_MID0, PF3_HEAVYHIT|PF3_LASTHIT
		jp   .doGravity
; --------------- frame #2-4 / common gravity check ---------------	
.doGravity:
	; Increase YSpeed at $00.60px/frame
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $05*OBJLSTPTR_ENTRYSIZE, $06
		jp   .ret
; --------------- frame #5 ---------------	
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------	
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Andy_ShoRyuDan ===============
; Move code for: 
; - Andy's Sho Ryu Dan (MOVE_ANDY_SHO_RYU_DAN_L, MOVE_ANDY_SHO_RYU_DAN_H)
; - Athena's Psycho Sword (MOVE_ATHENA_PSYCHO_SWORD_L, MOVE_ATHENA_PSYCHO_SWORD_H)
MoveC_Andy_ShoRyuDan:
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
	jp   z, .obj2
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj4
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj5
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj5
	cp   $07*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj7
	cp   $08*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
; --------------- frame #0 ---------------	
.obj0:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_INSTANT
		mMvC_PlaySound SFX_FIREHIT_A
		mMvC_SetDamageNext $02, HITTYPE_DROP_MAIN, PF3_LASTHIT
		jp   .anim
; --------------- frame #1 ---------------	
.obj1:
	mMvC_ValFrameStart .obj1_cont
		mMvC_SetMoveH $0700
		ld   hl, iPlInfo_Flags0
		add  hl, bc
		inc  hl			; Seek to iPlInfo_Flags1
		res  PF1B_INVULN, [hl]
		
		; Set different jump speed depending on attack strength
		mMvIn_ChkLHE .obj1_setJumpH, .obj1_setJumpE
	.obj1_setJumpL: ; Light
		mMvC_SetSpeedH $0080
		mMvC_SetSpeedV $FA00
		jp   .obj1_chkGravity
	.obj1_setJumpH: ; Heavy
		mMvC_SetSpeedH $0100
		mMvC_SetSpeedV $F900
		jp   .obj1_chkGravity
	.obj1_setJumpE: ; [POI] Hidden heavy
		mMvC_SetSpeedH $01C0
		mMvC_SetSpeedV $F800
	.obj1_chkGravity:
		jp   .chkGravity
.obj1_cont:
	; This and the next frames always call mMvC_SetDamage every time.
	; This causes continuous damage to be applied, which is why the damage value is low.
	mMvC_SetDamage $02, HITTYPE_DROP_MAIN, PF3_LASTHIT
	jp   .chkGravity
; --------------- frame #2,#3 ---------------	
.obj2:
	mMvC_SetDamage $02, HITTYPE_DROP_MAIN, PF3_LASTHIT
	mMvC_ValFrameEnd .chkGravity
		; If we don't have enough vertical speed, switch to #5
		mMvC_NextFrameOnGtYSpeed -$03, ANIMSPEED_NONE	; YSpeed > -$03?
		jp   nc, .chkGravity							; If so, jump
		ld   hl, iOBJInfo_OBJLstPtrTblOffset
		add  hl, de
		ld   [hl], $04*OBJLSTPTR_ENTRYSIZE ; -1 since .anim will increase it
		jp   .chkGravity
; --------------- frame #4 ---------------	
.obj4:
	mMvC_SetDamage $02, HITTYPE_DROP_MAIN, PF3_LASTHIT
	mMvC_ValFrameEnd .chkGravity
		; As long as we still have enough vertical speed, loop back to #2
		mMvC_NextFrameOnGtYSpeed -$03, ANIMSPEED_NONE	; YSpeed < -$03?
		jp   c, .chkGravity								; If so, jump
		ld   hl, iOBJInfo_OBJLstPtrTblOffset
		add  hl, de
		ld   [hl], $01*OBJLSTPTR_ENTRYSIZE ; -1 since .anim will increase it
		jp   .chkGravity
; --------------- frame #5,#6 ---------------	
.obj5:
	; This quickly switches to #6 then #7, since $00.40 > $00
	mMvC_SetSpeedH +$0040
	mMvC_NextFrameOnGtYSpeed +$00, ANIMSPEED_NONE
	jp   .chkGravity
; --------------- frame #7 ---------------
; Continue moving downwards until we touch the ground.
.obj7:
	mMvC_SetSpeedH +$0040
; --------------- common gravity handler ---------------
; If we touch the ground at any point between #1-#7, switch to #8.
.chkGravity:
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $08*OBJLSTPTR_ENTRYSIZE, $08
		jp   .ret
; --------------- frame #8 ---------------	
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------	
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Andy_GekiHekiHaiSuiSho ===============
; Move code for Andy's Geki Heki Hai Sui Sho (MOVE_ANDY_GEKI_HEKI_HAI_SUI_SHO_L, MOVE_ANDY_GEKI_HEKI_HAI_SUI_SHO_H).
MoveC_Andy_GekiHekiHaiSuiSho:;I
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .anim
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj2
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj3
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .anim
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj5
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj6
	cp   $07*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj7
	cp   $08*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
; --------------- frame #1 ---------------	
.obj1:
	mMvC_ValFrameStart .obj1_anim
		mMvC_SetMoveH +$0700
.obj1_anim:
	jp   .anim
; --------------- frame #2 ---------------	
.obj2:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $08, HITTYPE_HIT_MID0, PF3_LASTHIT
		mMvC_PlaySound SCT_HEAVY
		jp   .anim
; --------------- frame #3 ---------------	
.obj3:
	mMvC_ValFrameStart .obj3_anim
		mMvC_SetMoveH +$0700
.obj3_anim:
	jp   .anim
; --------------- frame #5 ---------------	
.obj5:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $08, HITTYPE_HIT_MID1, PF3_LASTHIT
		mMvC_PlaySound SCT_HEAVY
		jp   .anim
; --------------- frame #6 ---------------	
.obj6:
	mMvC_ValFrameStart .obj6_anim
		mMvC_SetMoveH +$0700
.obj6_anim:
	jp   .anim
; --------------- frame #7 ---------------	
.obj7:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $03
		mMvC_SetDamageNext $08, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_LASTHIT
		mMvC_PlaySound SCT_HEAVY
		jp   .anim
; --------------- frame #8 ---------------	
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------	
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Andy_GeneiShiranui ===============
; Move code for Andy's Genei Shiranui (MOVE_ANDY_GENEI_SHIRANUI_L, MOVE_ANDY_GENEI_SHIRANUI_H).
; This move can transition to these moves:
; - Genei Shiranui Shimo Agito (MOVE_ANDY_SHIMO_AGITO)
; - Genei Shiranui Uwa Agito (MOVE_ANDY_UWA_AGITO)
MoveC_Andy_GeneiShiranui:
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
	jp   z, .unused_obj2
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj3
	jp   .anim ; We never get here
; --------------- frame #0 ---------------
; Air movement.
.obj0:
	mMvC_ValFrameStart .obj0_chkGravity
		mMvC_PlaySound SCT_MOVEJUMP_A
		; Depending on the attack strength, set different diagonal down angles
		mMvIn_ChkLHE .obj0_setJumpH, .obj0_setJumpE
	.obj0_setJumpL: ; Light
		mMvC_SetSpeedH $0300
		mMvC_SetSpeedV $0200
		jp   .obj0_chkGravity
	.obj0_setJumpH: ; Heavy
		mMvC_SetSpeedH $0500
		mMvC_SetSpeedV $0180
		jp   .obj0_chkGravity
	.obj0_setJumpE: ; [POI] Hidden heavy
		mMvC_SetSpeedH $0700
		mMvC_SetSpeedV $0000
.obj0_chkGravity:
	jp   .chkGravity
.chkGravity:
	; When the ground is touched, switch to a different landing frame.
	mMvC_ChkGravityHV $0018, .anim
		mMvIn_ChkLH .obj0_setNextH
	.obj0_setNextL:
		; The light version starts at #3, which does nothing special.
		mMvC_SetLandFrame $03*OBJLSTPTR_ENTRYSIZE, $08
		jp   .ret
	.obj0_setNextH:
		; The heavy version starts at #1, which makes the player dash forward.
		mMvC_SetLandFrame $01*OBJLSTPTR_ENTRYSIZE, ANIMSPEED_INSTANT
		jp   .ret
; --------------- frame #1 ---------------
; Landing frame - Heavy version.	
.obj1:
	mMvC_ValFrameStart .obj1_chkInput
		mMvC_SetSpeedH $0200
.obj1_chkInput:
	jp   .chkInput
; --------------- unused ---------------
; [TCRF] Frame not used.
.unused_obj2:
	jp   .chkInput
; --------------- frame #1 ---------------
; Landing frame - Light version.	
.obj3:
	jp   .chkInput
	
; --------------- common move chain check ---------------
; Input check for starting chainable moves.
.chkInput:
	
	; This move can transition to other two moves when landing on the ground,
	; though these are glorified punches and kicks.
	; Note that the current move doesn't deal damage by itself -- to make it do
	; so you have to transition.

	; Save the MoveId for later
	ld   hl, iPlInfo_MoveId
	add  hl, bc
	ld   a, [hl]	; A = iPlInfo_MoveId
	push af 		; Save it
	
		; Perform the input check
		ld   hl, iPlInfo_JoyKeys
		add  hl, bc
		ld   a, [hl]
		bit  KEYB_A, a				; Pressed kick?
		jr   nz, .startUwaAgito		; If so, jump
		bit  KEYB_B, a				; Pressed punch?
		jr   nz, .startShimoAgito	; If so, jump
		
		; Otherwise, nothing to do
	pop  af
	jp   .chkEnd
	
	.startShimoAgito:
		ld   a, MOVE_ANDY_SHIMO_AGITO
		call MoveInputS_SetSpecMove_StopSpeed
		jp   .setSubmoveSpeedH
	.startUwaAgito:
		ld   a, MOVE_ANDY_UWA_AGITO
		call MoveInputS_SetSpecMove_StopSpeed
	.setSubmoveSpeedH:
	
	; When starting a new move from the heavy version, give the player some initial fwd speed.
	pop  af	; A = Original MoveId
	cp   MOVE_ANDY_GENEI_SHIRANUI_L	; Were we doing the light version?
	jp   z, .ret					; If so, return
	mMvC_SetSpeedH $0400
	jp   .ret
; --------------- common ---------------	
.chkEnd:
	mMvC_ValFrameEnd .moveH
		call Play_Pl_EndMove
		jr   .ret
.moveH:
	call OBJLstS_ApplyXSpeed
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Andy_GeneiShiranuiSubmove ===============
; Move code for Andy's:
; - Genei Shiranui Shimo Agito (MOVE_ANDY_SHIMO_AGITO)
; - Genei Shiranui Uwa Agito (MOVE_ANDY_UWA_AGITO)
MoveC_Andy_GeneiShiranuiSubmove:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; End the move when reaching the target
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	mMvC_ChkTarget .chkEnd
	
	; Otherwise, continue moving forward while slowing down
	mMvC_DoFrictionH $0040
	jp   .anim
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jp   .ret
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Andy_ChoReppaDan ===============
; Move code for Andy's Cho Reppa Dan (MOVE_ANDY_CHO_REPPA_DAN_S, MOVE_ANDY_CHO_REPPA_DAN_D)
MoveC_Andy_ChoReppaDan:;I
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
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamageCont
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
; --------------- frame #0 ---------------	
.obj0:
	mMvC_ValFrameStart .obj0_cont
		mMvC_SetMoveH +$0700
.obj0_cont:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamage $02, HITTYPE_DROP_MAIN, PF3_LASTHIT
		jp   .anim
; --------------- frame #1 ---------------	
.obj1:
	mMvC_ValFrameStart .obj1_cont
		mMvC_SetMoveH +$0700
.obj1_cont:
	mMvC_ValFrameEnd .anim
		; Get manual control for #2 as the next frames animate depending on the Y Speed
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		mMvC_SetDamage $02, HITTYPE_DROP_MAIN, PF3_LASTHIT
		jp   .anim
; --------------- frame #2 ---------------	
.obj2:
	mMvC_ValFrameStart .obj2_cont
		; Set initial jump settings
		mMvC_PlaySound SCT_MOVEJUMP_B
		mMvC_SetMoveH +$0700
		
		; Desperation version moves less vertically
		ld   hl, iPlInfo_MoveId
		add  hl, bc
		ld   a, [hl]
		cp   MOVE_ANDY_CHO_REPPA_DAN_D
		jp   z, .obj2_setJumpD
	.obj2_setJumpS:
		mMvC_SetSpeedH +$0500
		mMvC_SetSpeedV -$0680
		jp   .move
	.obj2_setJumpD:
		mMvC_SetSpeedH +$0500
		mMvC_SetSpeedV -$03C0
		jp   .move
.obj2_cont:
	mMvC_NextFrameOnGtYSpeed -$02, ANIMSPEED_NONE
	jp   .setDamageCont
; --------------- frame #3 ---------------	
.obj3:
	mMvC_NextFrameOnGtYSpeed +$00, ANIMSPEED_NONE
	jp   .setDamageCont
; --------------- frame #2-3 / common damage handler ---------------	
.setDamageCont:
	; Deal continuous damage during frames #2 and #3.
	; The only difference between normal and desperation here is that the
	; latter shakes the opponent.
	ld   hl, iPlInfo_MoveId
	add  hl, bc
	ld   a, [hl]
	cp   MOVE_ANDY_CHO_REPPA_DAN_D
	jp   z, .setDamageContD
.setDamageContS:
	mMvC_SetDamage $02, HITTYPE_DROP_MAIN, PF3_LASTHIT
	jp   .move
.setDamageContD:
	mMvC_SetDamage $02, HITTYPE_DROP_MAIN, PF3_LASTHIT|PF3_LIGHTHIT
	jp   .move
	
; --------------- common movement code ---------------
; Handles gravity. The move can end early by touching the ground quickly.
.move:
	; Use lower gravity for the desperation version
	ld   hl, iPlInfo_MoveId
	add  hl, bc
	ld   a, [hl]
	cp   MOVE_ANDY_CHO_REPPA_DAN_D	; Using the desperation version?
	jp   z, .setGravityD			; If so, jump
.setGravityS:
	ld   hl, $0060
	jp   .setGravity
.setGravityD:
	ld   hl, $0030
.setGravity:
	; Handle gravity and move until we touch the ground
	call OBJLstS_ApplyGravityVAndMoveHV
	jp   nc, .anim
		mMvC_SetLandFrame $05*OBJLSTPTR_ENTRYSIZE, $12
		jp   .ret
; --------------- frame #5 ---------------	
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------	
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:;
	ret
	
; =============== MoveInputReader_MrBig ===============
; Special move input checker for MRBIG.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
; OUT
; - C flag: If set, a move was started
MoveInputReader_MrBig:
	mMvIn_Validate MrBig
	
.chkAir:
	jp   MoveInputReader_MrBig_NoMove
	
.chkGround:
	;             SELECT + B                               SELECT + A
	mMvIn_ChkEasy MoveInit_MrBig_BlasterWave, MoveInit_MrBig_DrumShot
	mMvIn_ChkGA MrBig, .chkPunch, .chkKick
.chkPunch:
	; DFDF+P -> Blaster Wave
	mMvIn_ValSuper .chkPunchNoSuper
	mMvIn_ChkDir MoveInput_DFDF, MoveInit_MrBig_BlasterWave
.chkPunchNoSuper:
	; FDF+P -> California Romance
	mMvIn_ChkDir MoveInput_FDF, MoveInit_MrBig_CaliforniaRomance
	; FDB+P -> Cross Diving
	mMvIn_ChkDir MoveInput_FDB, MoveInit_MrBig_CrossDiving
	; DF+P -> Ground Blaster
	mMvIn_ChkDir MoveInput_DF, MoveInit_MrBig_GroundBlaster
	; Px3 -> Crazy Drum Dram
	mMvIn_ChkBtnStrict MoveInput_PPP, MoveInit_MrBig_DrumShot
	jp   MoveInputReader_MrBig_NoMove
.chkKick:
	; FDB+K -> Spinning Lancer
	mMvIn_ChkDir MoveInput_FDB, MoveInit_MrBig_SpinningLancer
	jp   MoveInputReader_MrBig_NoMove
	
; =============== MoveInit_MrBig_GroundBlaster ===============
MoveInit_MrBig_GroundBlaster:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_MRBIG_GROUND_BLASTER_L, MOVE_MRBIG_GROUND_BLASTER_H
	call MoveInputS_SetSpecMove_StopSpeed
	call Play_Proj_CopyMoveDamageFromPl
	jp   MoveInputReader_MrBig_SetMove
; =============== MoveInit_MrBig_CrossDiving ===============
MoveInit_MrBig_CrossDiving:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_MRBIG_CROSS_DIVING_L, MOVE_MRBIG_CROSS_DIVING_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_MrBig_SetMove
; =============== MoveInit_MrBig_SpinningLancer ===============
MoveInit_MrBig_SpinningLancer:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_MRBIG_SPINNING_LANCER_L, MOVE_MRBIG_SPINNING_LANCER_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_MrBig_SetMove
; =============== MoveInit_MrBig_CaliforniaRomance ===============
MoveInit_MrBig_CaliforniaRomance:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_MRBIG_CALIFORNIA_ROMANCE_L, MOVE_MRBIG_CALIFORNIA_ROMANCE_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_MrBig_SetMove
; =============== MoveInit_MrBig_DrumShot ===============
MoveInit_MrBig_DrumShot:
	call Play_Pl_ClearJoyBtnBuffer
	mMvIn_GetLH MOVE_MRBIG_DRUM_SHOT_L, MOVE_MRBIG_DRUM_SHOT_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_MrBig_SetMove
; =============== MoveInit_MrBig_BlasterWave ===============
MoveInit_MrBig_BlasterWave:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetSD MOVE_MRBIG_BLASTER_WAVE_S, MOVE_MRBIG_BLASTER_WAVE_D
	call MoveInputS_SetSpecMove_StopSpeed
	call Play_Proj_CopyMoveDamageFromPl
	jp   MoveInputReader_MrBig_SetMove
; =============== MoveInputReader_MrBig_SetMove ===============
MoveInputReader_MrBig_SetMove:
	scf
	ret
; =============== MoveInputReader_MrBig_NoMove ===============
MoveInputReader_MrBig_NoMove:
	or   a
	ret
	
; =============== MoveC_MrBig_GroundBlaster ===============
; Move code for Mr.Big's Ground Blaster (MOVE_MRBIG_GROUND_BLASTER_L, MOVE_MRBIG_GROUND_BLASTER_H).
MoveC_MrBig_GroundBlaster:
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
	jp   .anim
	
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameEnd .anim
	
	; Set a slower animation speed for the heavy version.
	; This makes #2 linger a bit more after the projectile spawns.
	inc  hl	; Seek to iOBJInfo_FrameTotal
	push hl
		mMvIn_ChkLH .setSpeedH
	.setSpeedL:
	pop  hl
	ld   [hl], $0C	; iOBJInfo_FrameTotal = $0C
	jp   .anim
	.setSpeedH:
	pop  hl
	ld   [hl], $18	; iOBJInfo_FrameTotal = $18
	jp   .anim
; --------------- frame #2 ---------------
.obj2:
	mMvC_ValFrameStart .chkEnd
		call ProjInit_Terry_PowerWave
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_MrBig_CrossDiving ===============
; Move code for Mr.Big's Cross Diving (MOVE_MRBIG_CROSS_DIVING_L, MOVE_MRBIG_CROSS_DIVING_H).
MoveC_MrBig_CrossDiving:
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
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj4
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .doFriction
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .doFriction
	cp   $07*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim ; We never get here
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_INSTANT
		; [POI] Hidden heavy version deals damage on next frame
		mMvIn_ChkLHE .obj0_noDamage, .obj0_damage
		jp   .anim
	.obj0_noDamage:
		jp   .anim
	.obj0_damage:
		mMvC_SetDamageNext $04, HITTYPE_HIT_MID1, PF3_LASTHIT
		jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameStart .obj1_cont
		mMvC_PlaySound SFX_HEAVY
		; Set forward movement speed
		mMvIn_ChkLHE .obj1_setSpeedH, .obj1_setSpeedE
	.obj1_setSpeedL: ; Light
		mMvC_SetSpeedH $0400
		jp   .obj1_cont
	.obj1_setSpeedH: ; Heavy
		mMvC_SetSpeedH $0500
		jp   .obj1_cont
	.obj1_setSpeedE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH $0600
.obj1_cont:
	mMvC_ValFrameEnd .moveH
		; [POI] Hidden version deals damage the next frame
		mMvIn_ChkLHE .obj1_noDamage, .obj1_damage
		jp   .moveH
	.obj1_noDamage:
		jp   .moveH
	.obj1_damage: 
		mMvC_SetDamageNext $04, HITTYPE_HIT_MID0, PF3_LASTHIT
		jp   .moveH
; --------------- frame #2 ---------------
.obj2:
	mMvC_ValFrameEnd .moveH
		; [POI] Hidden version deals damage the next frame
		mMvIn_ChkLHE .obj2_noDamage, .obj2_damage
		jp   .moveH
	.obj2_noDamage:
		jp   .moveH
	.obj2_damage: 
		mMvC_SetDamageNext $04, HITTYPE_HIT_MID1, PF3_LASTHIT
		jp   .moveH
; --------------- frame #3 ---------------
.obj3:
	mMvC_ValFrameEnd .moveH
		; [POI] Hidden version deals damage the next frame
		mMvIn_ChkLHE .obj3_noDamage, .obj3_damage
		jp   .moveH
	.obj3_noDamage:
		jp   .moveH
	.obj3_damage: 
		mMvC_SetDamageNext $04, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_LASTHIT
		jp   .moveH
; --------------- frame #4 ---------------
.obj4:
	mMvC_ValFrameEnd .moveH
		mMvC_SetAnimSpeed $03
		jp   .moveH
; --------------- frames #5-6 ---------------
.doFriction:
	mMvC_DoFrictionH $0040
	jp   .anim
; --------------- frame #7 ---------------
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
	jp   .ret
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_MrBig_SpinningLancer ===============
; Move code for Mr.Big's Spinning Lancer (MOVE_MRBIG_SPINNING_LANCER_L, MOVE_MRBIG_SPINNING_LANCER_H).
MoveC_MrBig_SpinningLancer:
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
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkLoop
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj5
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj6
	cp   $07*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim ; We never get here
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_INSTANT
		
		; Initialize the loop counter, which determines how far to move.
		ld   hl, iPlInfo_MrBig_SpinningLancer_LoopTimer
		add  hl, bc
		push hl
		mMvIn_ChkLHE .obj0_setRepH, .obj0_setRepE
	.obj0_setRepL: ; Light
		ld   a, $01
		jp   .obj0_setRep
	.obj0_setRepH: ; Heavy
		ld   a, $02
		jp   .obj0_setRep
	.obj0_setRepE: ; [POI] Hidden Heavy
		ld   a, $03
	.obj0_setRep:
		pop  hl
		ld   [hl], a
		jp   .anim	
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameStart .obj3
		mMvC_PlaySound SFX_HEAVY
		mMvIn_ChkLHE .obj1_setSpeedH, .obj1_setSpeedE
	.obj1_setSpeedL: ; Light
		mMvC_SetSpeedH $0100
		jp   .obj3
	.obj1_setSpeedH: ; Heavy
		mMvC_SetSpeedH $0200
		jp   .obj3
	.obj1_setSpeedE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH $0300
; --------------- frame #3 ---------------
.obj3:
	mMvC_ValFrameEnd .moveH
		mMvC_PlaySound SFX_HEAVY
		jp   MoveC_MrBig_DrumShot.setDamageHit0
; --------------- frame #2 ---------------
.obj2:
	mMvC_ValFrameEnd .moveH
		mMvC_PlaySound SFX_HEAVY
		jp   MoveC_MrBig_DrumShot.setDamageHit1
; --------------- frame #4 ---------------
.chkLoop:
	mMvC_ValFrameEnd .moveH
		; Loop to #1 until the loop counter reaches 0
		ld   hl, iPlInfo_MrBig_SpinningLancer_LoopTimer
		add  hl, bc
		dec  [hl]		; LoopTimer--
		jp   z, MoveC_MrBig_DrumShot.setDamageHit1	; LoopTimer == 0? If so, jump
		ld   hl, iOBJInfo_OBJLstPtrTblOffset
		add  hl, de
		ld   [hl], $00*OBJLSTPTR_ENTRYSIZE ; offset by -1
		jp   MoveC_MrBig_DrumShot.setDamageHit1
; --------------- frame #5 ---------------
.obj5:
	mMvC_DoFrictionH $0040
	jp   .anim
; --------------- frame #6 ---------------
.obj6:
	mMvC_DoFrictionH $0040
		mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $1E
		mMvC_SetDamageNext $04, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_LASTHIT
		jp   .anim
; --------------- frame #7 ---------------
.chkEnd:
	mMvC_DoFrictionH $0040
	mMvC_ValFrameEnd .anim
		jp   .end
; --------------- common ---------------
.moveH:
	call OBJLstS_ApplyXSpeed
	jp   .anim
.end:
	call Play_Pl_EndMove
	jp   .ret
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_MrBig_CaliforniaRomanceH ===============
; Move code for the heavy version of Mr.Big's California Romance (MOVE_MRBIG_CALIFORNIA_ROMANCE_H).
MoveC_MrBig_CaliforniaRomanceH:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj0
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .playSFXDamage1
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .playSFXDamage0
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkLoop
	jp   .anim ; We never get here
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameStart .playSFXDamage0
		; Initialize player speed and loop counter
		mMvIn_ChkLHE .obj0_setSpeedH, .obj0_setSpeedE
		; [TCRF] Unreachable code.
		;        This move code isn't used for the light version, so we can't get here.
	.obj0_unused_setSpeedL: ; Light
		mMvC_SetSpeedH $0300
		ld   a, $01
		jp   .obj0_setLoop
	.obj0_setSpeedH: ; Heavy
		mMvC_SetSpeedH $0400
		ld   a, $01
		jp   .obj0_setLoop
	.obj0_setSpeedE: ; [POI] Hidden Light
		mMvC_SetSpeedH $0500
		ld   a, $02
	.obj0_setLoop:
		ld   hl, iPlInfo_MrBig_CaliforniaRomance_LoopTimer
		add  hl, bc
		ld   [hl], a
; --------------- frames #0,#2 / step sfx + damage 0 ---------------
.playSFXDamage0:
	mMvC_ValFrameEnd .moveH
		mMvC_PlaySound SFX_STEP
		jp   MoveC_MrBig_DrumShot.setDamageHit0
; --------------- frame #1 / step sfx + damage 1 ---------------
.playSFXDamage1:
	mMvC_ValFrameEnd .moveH
		mMvC_PlaySound SFX_STEP
		jp   MoveC_MrBig_DrumShot.setDamageHit1
; --------------- frame #3 ---------------
.chkLoop:
	mMvC_ValFrameEnd .moveH
		; Loop to #1 until the loop counter reaches 0.
		; When that happens, end the move and transition to California Romance.
		ld   hl, iPlInfo_MrBig_CaliforniaRomance_LoopTimer
		add  hl, bc
		dec  [hl]
		jp   z, .switchToCaliforniaRomance
		
		ld   hl, iOBJInfo_OBJLstPtrTblOffset
		add  hl, de
		ld   [hl], $00*OBJLSTPTR_ENTRYSIZE ; offset by -1
		mMvC_PlaySound SFX_STEP
		jp   MoveC_MrBig_DrumShot.setDamageHit1
	.switchToCaliforniaRomance:
		ld   a, MOVE_MRBIG_CALIFORNIA_ROMANCE_L
		call MoveInputS_SetSpecMove_StopSpeed
		mMvC_SetDamageNext $06, HITTYPE_HIT_MID1, PF3_LASTHIT
		jp   .ret
; --------------- common ---------------
.moveH:
	call OBJLstS_ApplyXSpeed
	jp   .anim
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_MrBig_DrumShot ===============
; Move code for Mr.Big's Drum Shot (MOVE_MRBIG_DRUM_SHOT_L, MOVE_MRBIG_DRUM_SHOT_H).
MoveC_MrBig_DrumShot:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj0
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .playSFXDamage1
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .playSFXDamage0
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .playSFXDamage1
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .playSFXDamage0
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .playSFXDamage1
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj6
	cp   $07*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim ; We never get here
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameStart .playSFXDamage0
		mMvC_PlaySound SFX_HEAVY	
		; Determine horizontal speed and loop count
		mMvIn_ChkLHE .obj0_setSpeedH, .obj0_setSpeedE
	.obj0_setSpeedL: ; Light
		mMvC_SetSpeedH $0200
		ld   a, $01
		jp   .obj0_setLoop
	.obj0_setSpeedH: ; Heavy
		mMvC_SetSpeedH $0240
		ld   a, $02
		jp   .obj0_setLoop
	.obj0_setSpeedE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH $0280
		ld   a, $03
	.obj0_setLoop:
		ld   hl, iPlInfo_MrBig_DrumShot_LoopTimer
		add  hl, bc
		ld   [hl], a
; --------------- frames #0,#2,#4 / sfx + damage 0 ---------------
.playSFXDamage0:
	mMvC_ValFrameEnd .moveH
		mMvC_PlaySound SFX_HEAVY
		jp   .setDamageHit0
; --------------- frames #1,#3,#5 / sfx + damage 1 ---------------
.playSFXDamage1:
	mMvC_ValFrameEnd .moveH
		mMvC_PlaySound SFX_HEAVY
		jp   .setDamageHit1
; --------------- frame #6 ---------------
.obj6:
	mMvC_ValFrameEnd .moveH
		mMvC_PlaySound SFX_HEAVY
		; Loop to #1 until the loop counter reaches 0
		ld   hl, iPlInfo_MrBig_DrumShot_LoopTimer
		add  hl, bc
		dec  [hl]
		jp   z, .obj6_loopEnd
	.obj6_loop:
		ld   hl, iOBJInfo_OBJLstPtrTblOffset
		add  hl, de
		ld   [hl], $00*OBJLSTPTR_ENTRYSIZE ; offset by -1
		jp   .setDamageHit0
	.obj6_loopEnd:
		ld   hl, iOBJInfo_FrameTotal
		add  hl, de
		ld   [hl], $14
		jp   .anim
; --------------- common damage setup ---------------
; These routines to set damage are called by multiple Mr.Big moves.
.setDamageHit1:
	mkhl $02, HITTYPE_HIT_MID1
	ld   hl, CHL
	jp   .setDamage
.setDamageHit0:
	mkhl $02, HITTYPE_HIT_MID0
	ld   hl, CHL
.setDamage:
	ld   a, PF3_LASTHIT
	call Play_Pl_SetMoveDamageNext
; --------------- common ---------------
.moveH:
	call OBJLstS_ApplyXSpeed
	jp   .anim
; --------------- frame #7 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_ClearJoyBtnBuffer
		call Play_Pl_EndMove
		jp   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_MrBig_BlasterWave ===============
; Move code for Mr.Big's Blaster Wave (MOVE_MRBIG_BLASTER_WAVE_S, MOVE_MRBIG_BLASTER_WAVE_D).
MoveC_MrBig_BlasterWave:
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
	jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $64
		jp   .anim
; --------------- frame #2 ---------------
.obj2:
	mMvC_ValFrameStart .chkEnd
		ld   hl, $2000
		call ProjInit_MrBig_BlasterWave
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== ProjInit_MrBig_BlasterWave ===============
; Initializes the projectile for Mr.Big's Blaster Wave.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
ProjInit_MrBig_BlasterWave:
	mMvC_PlaySound SCT_PROJ_LG_A
	
	push bc
		push de
			; A = MoveId (not needed)
			ld   hl, iPlInfo_MoveId
			add  hl, bc
			ld   a, [hl]
			push af
				call ProjInitS_InitAndGetOBJInfo
				
				; Set code pointer
				ld   hl, iOBJInfo_Play_CodeBank
				add  hl, de
				ld   [hl], BANK(ProjC_MrBig_BlasterWave)	; BANK $06 ; iOBJInfo_Play_CodeBank
				inc  hl
				ld   [hl], LOW(ProjC_MrBig_BlasterWave)		; iOBJInfo_Play_CodePtr_Low
				inc  hl
				ld   [hl], HIGH(ProjC_MrBig_BlasterWave)	; iOBJInfo_Play_CodePtr_High
				
				; Write sprite mapping ptr for this projectile.
				ld   hl, iOBJInfo_BankNum
				add  hl, de
				ld   [hl], BANK(OBJLstPtrTable_Proj_MrBig_BlasterWave)	; BANK $01 ; iOBJInfo_BankNum
				inc  hl
				ld   [hl], LOW(OBJLstPtrTable_Proj_MrBig_BlasterWave)	; iOBJInfo_OBJLstPtrTbl_Low
				inc  hl
				ld   [hl], HIGH(OBJLstPtrTable_Proj_MrBig_BlasterWave)	; iOBJInfo_OBJLstPtrTbl_High
				inc  hl
				ld   [hl], $00	; iOBJInfo_OBJLstPtrTblOffset

				; Set animation speed.
				ld   hl, iOBJInfo_FrameLeft
				add  hl, de
				ld   [hl], $03	; iOBJInfo_FrameLeft
				inc  hl
				ld   [hl], $03	; iOBJInfo_FrameTotal
				
				; Set priority value
				ld   hl, iOBJInfo_Play_Priority
				add  hl, de
				ld   [hl], $02
				
				; Set despawn timer
				inc  hl
			pop  af
			
			cp   MOVE_MRBIG_BLASTER_WAVE_S	; Using the normal version of the move?
			jp   nz, .setTimerD				; If not, jump
		.setTimerS:
			ld   [hl], $28 ; iOBJInfo_Play_EnaTimer
			jp   .setPos
		.setTimerD:
			ld   [hl], $50 ; iOBJInfo_Play_EnaTimer
			
		.setPos:
			; Set initial position relative to the player's origin
			call OBJLstS_Overlap
			mMvC_SetMoveH +$2000
			mMvC_SetMoveV +$0000
		pop  de
	pop  bc
	ret
	
; =============== ProjC_MrBig_BlasterWave ===============
; Code for the Mr.Big's Blaster Wave projectile / special effect.
ProjC_MrBig_BlasterWave:

	; Despawn if we got hit out of this
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	bit  PF1B_HITRECV, [hl]
	jp   nz, .despawn
	
	; Handle despawn timer
	ld   hl, iOBJInfo_Play_EnaTimer
	add  hl, de
	dec  [hl]
	jp   z, .despawn
	
	; Alternate between moving the projectile up and down, while moving forward.
	; This goes off the despawn timer, so higher the value, the earlier it is triggered.
	ld   a, [hl]		; A = iOBJInfo_Play_EnaTimer
	cp   $46
	jp   z, .moveU
	cp   $3C
	jp   z, .moveD
	cp   $32
	jp   z, .moveU
	cp   $28
	jp   z, .moveD
	cp   $1E
	jp   z, .moveU
	cp   $14
	jp   z, .moveD
	cp   $0A
	jp   z, .moveU
	jp   .anim
.moveD:
	mMvC_SetMoveH +$0200
	mMvC_SetMoveV +$0800
	jp   .anim
.moveU:
	mMvC_SetMoveH +$0200
	mMvC_SetMoveV -$0800
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
	ret
.despawn:
	call OBJLstS_Hide
	ret
	
; =============== MoveInputReader_Geese ===============
; Special move input checker for GEESE.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
; OUT
; - C flag: If set, a move was started
MoveInputReader_Geese:
	mMvIn_Validate Geese
	
.chkAir:
	;             SELECT + B                        SELECT + A
	mMvIn_ChkEasy MoveInit_Geese_HishouNichirinZan, MoveInit_Geese_ShippuKen
	mMvIn_ChkGA Geese, .chkAirPunch, .chkAirKick
.chkAirPunch:
	; DB+P (air) -> Shippu Ken
	mMvIn_ChkDir MoveInput_DB, MoveInit_Geese_ShippuKen
.chkAirKick:
	jp   MoveInputReader_Geese_NoMove
	
.chkGround:
	;             SELECT + B                  SELECT + A
	mMvIn_ChkEasy MoveInit_Geese_RagingStorm, MoveInit_Geese_AtemiNage
	mMvIn_ChkGA Geese, .chkPunch, .chkKick
.chkPunch:
	mMvIn_ValSuper .chkPunchNoSuper
	; BFDBF+P -> Raging Storm
	mMvIn_ChkDir MoveInput_BFDBF, MoveInit_Geese_RagingStorm
.chkPunchNoSuper:
	; FDF+P -> Hishou Nichirin Zan
	mMvIn_ChkDir MoveInput_FDF, MoveInit_Geese_HishouNichirinZan
	; FDB+P -> Ja ei ken
	mMvIn_ChkDir MoveInput_FDB, MoveInit_Geese_JaEiKen
	; DF+P -> Reppuken
	mMvIn_ChkDir MoveInput_DF, MoveInit_Geese_Reppuken
	jp   MoveInputReader_Geese_NoMove
.chkKick:
	; BDF+K -> Atemi Nage
	mMvIn_ChkDir MoveInput_BDF, MoveInit_Geese_AtemiNage
	jp   MoveInputReader_Geese_NoMove
; =============== MoveInit_Geese_Reppuken ===============	
MoveInit_Geese_Reppuken:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_GEESE_REPPUKEN_L, MOVE_GEESE_REPPUKEN_H
	call MoveInputS_SetSpecMove_StopSpeed
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	set  PF0B_PROJREM, [hl]
	jp   MoveInputReader_Geese_SetMove
; =============== MoveInit_Geese_JaEiKen ===============	
MoveInit_Geese_JaEiKen:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_GEESE_JA_EI_KEN_L, MOVE_GEESE_JA_EI_KEN_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Geese_SetMove
; =============== MoveInit_Geese_HishouNichirinZan ===============	
MoveInit_Geese_HishouNichirinZan:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_GEESE_HISHOU_NICHIRIN_ZAN_L, MOVE_GEESE_HISHOU_NICHIRIN_ZAN_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Geese_SetMove
; =============== MoveInit_Geese_ShippuKen ===============	
MoveInit_Geese_ShippuKen:
	call Play_Pl_ClearJoyDirBuffer
	
	; Preserve the player's momentum when starting the move
	ld   hl, iOBJInfo_SpeedX
	add  hl, de
	ldi  a, [hl]	
	push af				; Save iOBJInfo_SpeedX
		ldi  a, [hl]
		push af				; Save iOBJInfo_SpeedXSub
			ldi  a, [hl]
			push af				; Save iOBJInfo_SpeedY
				ld   a, [hl]
				push af				; Save iOBJInfo_SpeedYSub
					push hl				; Save OBJInfo ptr
						mMvIn_GetLH MOVE_GEESE_SHIPPU_KEN_L, MOVE_GEESE_SHIPPU_KEN_H
						call MoveInputS_SetSpecMove_StopSpeed
						call Play_Proj_CopyMoveDamageFromPl
					pop  hl				; Restore OBJInfo ptr
				pop  af
				ldd  [hl], a		; Restore iOBJInfo_SpeedYSub
			pop  af
			ldd  [hl], a		; Restore iOBJInfo_SpeedY
		pop  af
		ldd  [hl], a		; Restore iOBJInfo_SpeedXSub
	pop  af
	ld   [hl], a		; Restore iOBJInfo_SpeedX
	
	jp   MoveInputReader_Geese_SetMove
; =============== MoveInit_Geese_AtemiNage ===============	
MoveInit_Geese_AtemiNage:
	ld   hl, iPlInfo_Geese_AtemiNage_AutoguardShakeDone
	add  hl, bc
	ld   [hl], $00
	
	call Play_Pl_ClearJoyDirBuffer
	
	; The two versions autoguard in different points.
	call MoveInputS_CheckMoveLHVer
	jr   nz, .heavy
.light:
	ld   a, MOVE_GEESE_ATEMI_NAGE_L
	call MoveInputS_SetSpecMove_StopSpeed
	ld   hl, iPlInfo_Flags2
	add  hl, bc
	set  PF2B_AUTOGUARDMID, [hl]
	jp   MoveInputReader_Geese_SetMove
.heavy:
	ld   a, MOVE_GEESE_ATEMI_NAGE_H
	call MoveInputS_SetSpecMove_StopSpeed
	ld   hl, iPlInfo_Flags2
	add  hl, bc
	set  PF2B_AUTOGUARDLOW, [hl]
	jp   MoveInputReader_Geese_SetMove
; =============== MoveInit_Geese_RagingStorm ===============	
MoveInit_Geese_RagingStorm:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetSD MOVE_GEESE_RAGING_STORM_S, MOVE_GEESE_RAGING_STORM_D
	call MoveInputS_SetSpecMove_StopSpeed
	call Play_Proj_CopyMoveDamageFromPl
	jp   MoveInputReader_Geese_SetMove
; =============== MoveInputReader_Geese_SetMove ===============	
MoveInputReader_Geese_SetMove:
	scf
	ret
; =============== MoveInputReader_Geese_NoMove ===============	
MoveInputReader_Geese_NoMove:
	or   a
	ret
	
; =============== MoveC_Geese_ReppukenL ===============
; Move code for the light version of Geese's Reppuken (MOVE_GEESE_REPPUKEN_L).
MoveC_Geese_ReppukenL:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .end
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj0
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj3
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameEnd .anim
		mMvC_PlaySound SFX_FIREHIT_A
		jp   .anim
; --------------- frame #3 ---------------
.obj3:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $1E
		jp   .anim
; --------------- frame #4 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .end
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.end:
	ret
	
; =============== MoveC_Geese_ReppukenH ===============
; Move code for the hard version of Geese's Reppuken (MOVE_GEESE_REPPUKEN_H).	
MoveC_Geese_ReppukenH:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .end
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, MoveC_Geese_ReppukenL.obj0
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj3
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj6
	cp   $07*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim
; --------------- frame #3 ---------------
.obj3:
	mMvC_ValFrameStart .obj3_cont
		mMvC_SetMoveH +$0700
.obj3_cont:
	mMvC_ValFrameEnd .anim
		mMvC_PlaySound SFX_FIREHIT_A
		mMvC_SetDamageNext $08, HITTYPE_DROP_MAIN, PF3_HEAVYHIT
		jp   .anim
; --------------- frame #6 ---------------
.obj6:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $1E
		jp   .anim
; --------------- frame #7 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .end
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.end:
	ret
	
; =============== MoveC_Geese_JaEiKen ===============
; Move code for Geese's Ja ei ken (MOVE_GEESE_JA_EI_KEN_L, MOVE_GEESE_JA_EI_KEN_H).	
MoveC_Geese_JaEiKen:
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
	jp   .anim ; We never get here
; --------------- frame #0 ---------------
; Startup, gets manual ctrl.
.obj0:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		jp   .anim
; --------------- frame #1 ---------------
; Initial sprint forward.
.obj1:
	mMvC_ValFrameStart .obj1_chkHit
		mMvC_PlaySound SFX_HEAVY
		; Pick different speed for first sprint forward
		mMvIn_ChkLHE .obj1_setDashH, .obj1_setDashE
	.obj1_setDashL: ; Light
		mMvC_SetSpeedH +$0500
		jp   .obj1_chkHit
	.obj1_setDashH: ; Heavy
		mMvC_SetSpeedH +$0600
		jp   .obj1_chkHit
	.obj1_setDashE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH +$0700
		
.obj1_chkHit:

	; If the opponent didn't get hit by the time we stop moving, end the move.
	ld   hl, iPlInfo_ColiFlags
	add  hl, bc
	bit  PCF_HITOTHER, [hl]		; Did we hit the opponent yet?
	jp   z, .obj1_moveH			; If not, jump
	ld   hl, iPlInfo_Flags1Other
	add  hl, bc
	bit  PF1B_INVULN, [hl]		; Is the opponent invulnerable?
	jp   nz, .obj1_moveH		; If so, jump
	
.obj1_hitOk:
	; Otherwise, continue to #2 and disable manual control.
	; The next two frames will deal damage.
	mMvC_SetDamageNext $08, HITTYPE_HIT_MID1, PF3_HEAVYHIT
	mMvC_SetFrame $02*OBJLSTPTR_ENTRYSIZE, $05
	call OBJLstS_ApplyXSpeed
	jp   .ret
.obj1_moveH:
	mMvC_DoFrictionH $0080
	jp   nc, .anim
	jp   .end
; --------------- frame #2 ---------------
; Hit confirmed. Second sprint forward.
.obj2:
	mMvC_ValFrameStart .obj2_cont
		mMvC_PlaySound SFX_HEAVY
		mMvC_SetSpeedH +$0500
.obj2_cont:
	mMvC_ValFrameEnd .moveH
		mMvC_SetAnimSpeed $0A
		mMvC_SetDamageNext $08, HITTYPE_DROP_MAIN, PF3_HEAVYHIT
		jp   .moveH
; --------------- frame #3 ---------------
; Hit confirmed. Last sprint before the move ends.
.obj3:
	mMvC_ValFrameStart .obj3_chkEnd
		mMvC_PlaySound SFX_HEAVY
		mMvC_SetSpeedH $0600
.obj3_chkEnd:
	; Progressively slow down by $00.80px/frame.
	; End the move when we stop moving.
	mMvC_DoFrictionH $0080
	jp   nc, .anim	; Did we stop? If not, jump
	jp   .end
; --------------- common ---------------
.moveH:
	mMvC_DoFrictionH +$0080
	jp   .anim
.end:
	call Play_Pl_EndMove
	jp   .ret
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Geese_HishouNichirinZan ===============
; Move code for Geese's Hishou Nichirin Zan (MOVE_GEESE_HISHOU_NICHIRIN_ZAN_L, MOVE_GEESE_HISHOU_NICHIRIN_ZAN_H).		
MoveC_Geese_HishouNichirinZan:
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
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj4
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .doGravity
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameStart .obj0_cont
		mMvC_SetMoveH $0700
		jp   .anim
.obj0_cont:
	jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameStart .obj1_cont
		mMvC_SetMoveH $0400
.obj1_cont:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		mMvC_SetDamageNext $08, HITTYPE_DROP_MAIN, PF3_HEAVYHIT
		jp   .anim
; --------------- frame #2 ---------------
.obj2:
	mMvC_ValFrameStart .obj2_cont
		mMvC_PlaySound SFX_FIREHIT_A
		mMvIn_ChkLHE .obj2_setJumpH, .obj2_setJumpE
	.obj2_setJumpL: ; Light
		mMvC_SetSpeedH +$0100
		mMvC_SetSpeedV -$0600
		jp   .obj2_doGravity
	.obj2_setJumpH: ; Heavy
		mMvC_SetSpeedH +$0180
		mMvC_SetSpeedV -$0680
		jp   .obj2_doGravity
	.obj2_setJumpE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH +$0200
		mMvC_SetSpeedV -$0680
	.obj2_doGravity:
		jp   .doGravity
.obj2_cont:
	mMvC_NextFrameOnGtYSpeed -$06, ANIMSPEED_NONE
	jp   nc, .doGravity
	jp   .doGravity
; --------------- frame #3 ---------------
.obj3:
	mMvC_NextFrameOnGtYSpeed $01, ANIMSPEED_NONE
	jp   nc, .doGravity
	jp   .doGravity
; --------------- frame #4 ---------------
.obj4:
	mMvC_NextFrameOnGtYSpeed $02, ANIMSPEED_NONE
	jp   nc, .doGravity
	jp   .doGravity
; --------------- frames #2-5 / common gravity check ---------------
.doGravity:
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $06*OBJLSTPTR_ENTRYSIZE, $06
		jp   .ret
; --------------- frame #6 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
	call Play_Pl_EndMove
	jr   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Geese_ShippuKen ===============
; Move code for Geese's Shippu Ken (MOVE_GEESE_SHIPPU_KEN_L, MOVE_GEESE_SHIPPU_KEN_H).	
MoveC_Geese_ShippuKen:
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
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .doGravity
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameEnd .doGravity
		mMvC_SetAnimSpeed $0A
		jp   .doGravity
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameStart .obj1_cont
		call ProjInit_Geese_ShippuKen
.obj1_cont:
	mMvC_ValFrameEnd .doGravity
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		jp   .doGravity
; --------------- frames #0-2 / common gravity check ---------------
.doGravity:
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $03*OBJLSTPTR_ENTRYSIZE, ANIMSPEED_INSTANT
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
	
; =============== MoveC_Geese_AtemiNage ===============
; Move code for Geese's Atemi Nage (MOVE_GEESE_ATEMI_NAGE_L, MOVE_GEESE_ATEMI_NAGE_H).	
MoveC_Geese_AtemiNage:
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
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj4
	jp   .anim ; We never get here
	
; --------------- frame #0 ---------------
.obj0:

	; This is a counter attack.
	; It activates only when the autoguard triggers (read: we blocked an incoming hit).
	
	; If the autoguard doesn't trigger by the end of the frame, the move continues to #2
	; where it ends early, without doing anything.
	; If the autoguard does trigger, we switch to #3 and throw the opponent.
	
	ld   hl, iPlInfo_Flags2
	add  hl, bc
	bit  PF2B_AUTOGUARDDONE, [hl]	; Did the autoguard trigger?
	jp   z, .obj0_waitEnd					
	
	; Do the hitstop/shake effect only once
	ld   hl, iPlInfo_Geese_AtemiNage_AutoguardShakeDone
	add  hl, bc
	ld   a, [hl]
	or   a
	jp   nz, .shakeDone
	call Play_Pl_TempPauseOtherAnim
	mMvC_PlaySound SCT_BLOCK
	
	; Shake for 2 frames while hitstop is enabled
	ld   a, $01
	ld   [wPlayHitstopSet], a
	call Play_Pl_ShakeFor
	ld   a, $00
	ld   [wPlayHitstopSet], a
	
	ld   hl, iPlInfo_Geese_AtemiNage_AutoguardShakeDone
	add  hl, bc
	ld   [hl], $01
	
.shakeDone:
	; Put the opponent into the grabbed state
	IF FIX_BUGS == 1
		mMvIn_ValStartCmdThrow_AllColi .anim
	ELSE
		mMvIn_ValStartCmdThrow_AllColi MoveC_Geese_HishouNichirinZan.anim
	ENDC
		; We're invulnerable when it's confirmed
		ld   hl, iPlInfo_Flags1
		add  hl, bc
		set  PF1B_INVULN, [hl]
		; Switch to #2
		mMvC_SetFrame $02*OBJLSTPTR_ENTRYSIZE, $08
		jp   .ret
	
.obj0_waitEnd:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $0F
		jp   .anim
; --------------- frame #1 ---------------
; No autoguard.
.obj1:
	mMvC_ValFrameEnd .anim
	jp   .end
; --------------- frame #2 ---------------
; Autoguard. Grab frame L.
.obj2:
	mMvC_ValFrameStart .anim
		mMvC_SetDamage $06, HITTYPE_THROW_ROTL, PF3_HEAVYHIT
		mMvC_MoveThrowOp +$08, -$28
		jp   .anim
; --------------- frame #3 ---------------
; Autoguard. Grab frame D.
.obj3:
	mMvC_ValFrameStart .obj3_cont
		mMvC_SetDamage $06, HITTYPE_THROW_ROTD, PF3_HEAVYHIT
		mMvC_MoveThrowOp +$18, -$04
		jp   .anim
.obj3_cont:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $14
		jp   .anim
; --------------- frame #4 ---------------
; Autoguard. Throw.
.obj4:
	mMvC_ValFrameStart .chkEnd
		mMvC_SetDamage $0A, HITTYPE_DROP_DB_A, PF3_HEAVYHIT
		jp   .anim
.chkEnd:
	mMvC_ValFrameEnd .anim
; --------------- common ---------------
.end:
	mMvC_EndThrow_Slow
	jr   .ret
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Geese_RagingStorm ===============
; Move code for Geese's Raging Storm (MOVE_GEESE_RAGING_STORM_S, MOVE_GEESE_RAGING_STORM_D).	
MoveC_Geese_RagingStorm:
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
	jp   .anim ; We never get here
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_INSTANT
		jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $3C
		jp   .anim
; --------------- frame #2 ---------------
.obj2:
	mMvC_ValFrameStart .chkEnd
	
	; Spawn the correct effect depending on the move type
	ld   hl, iPlInfo_MoveId
	add  hl, bc
	ld   a, [hl]
	cp   MOVE_GEESE_RAGING_STORM_D	; Started the desperation version?
	jp   z, .obj2_initProjD			; If so, jump
.obj2_initProjS:
	ld   hl, $0000
	call ProjInit_Geese_RagingStormS
	jp   .chkEnd
.obj2_initProjD:
	ld   hl, $0000
	call ProjInit_Geese_RagingStormD
.chkEnd:
	mMvC_ValFrameEnd .anim
	call Play_Pl_EndMove
	jr   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== ProjInit_Geese_ShippuKen ===============
; Initializes the projectile for Geese's Shippu Ken.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
ProjInit_Geese_ShippuKen:
	mMvC_PlaySound SFX_FIREHIT_A
	
	push bc
		push de
		
			; --------------- common projectile init code ---------------
			
			;
			; C flag = If set, we're at max power
			;
			ld   hl, iPlInfo_Pow
			add  hl, bc
			ld   a, [hl]		; A = Pow meter
			cp   PLAY_POW_MAX	; Are we at max power?
			jp   z, .initMaxPow	; If so, jump
			xor  a				; C flag clear
			jp   .getFlags2
		.initMaxPow:
			scf					; C flag set
		.getFlags2:
			;
			; A = iPlInfo_Flags2
			;
			ld   hl, iPlInfo_Flags2
			push af				; Preserve C flag for this
				add  hl, bc		; Seek to iPlInfo_Flags2
			pop  af
			ld   a, [hl]		; Read out to A
			
			push af ; Save A & C flag
				
				call ProjInitS_InitAndGetOBJInfo	; DE = Ptr to wOBJInfo_Pl*Projectile
				
				; --------------- main ---------------
			
				; Set code pointer
				ld   hl, iOBJInfo_Play_CodeBank
				add  hl, de
				ld   [hl], BANK(ProjC_Geese_ShippuKen)	; BANK $06 ; iOBJInfo_Play_CodeBank
				inc  hl
				ld   [hl], LOW(ProjC_Geese_ShippuKen)	; iOBJInfo_Play_CodePtr_Low
				inc  hl
				ld   [hl], HIGH(ProjC_Geese_ShippuKen)	; iOBJInfo_Play_CodePtr_High
				
				; Write sprite mapping ptr for this projectile.
				ld   hl, iOBJInfo_BankNum
				add  hl, de
				ld   [hl], BANK(OBJLstPtrTable_Proj_Geese_ShippuKen)	; BANK $01 ; iOBJInfo_BankNum
				inc  hl
				ld   [hl], LOW(OBJLstPtrTable_Proj_Geese_ShippuKen)		; iOBJInfo_OBJLstPtrTbl_Low
				inc  hl
				ld   [hl], HIGH(OBJLstPtrTable_Proj_Geese_ShippuKen)	; iOBJInfo_OBJLstPtrTbl_High
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
				
				; Set initial position relative to the player's origin
				call OBJLstS_Overlap
				mMvC_SetMoveH +$0800
				mMvC_SetMoveV -$1000
				
			;
			; Determine projectile horizontal speed.
			;
		
			pop  af						; Restore A & C flag
			jp   nc, .fldNoMaxPow		; Are we at max power? If not, jump
		.fldMaxPow:
			bit  PF2B_HEAVY, a			; Was this an heavy attack?
			jp   nz, .fldHeavyMaxPow	; If so, jump
			jp   .fldLight
		.fldNoMaxPow:
			bit  PF2B_HEAVY, a			; Was this an heavy attack?
			jp   nz, .fldHeavy			; If so, jump
		.fldLight:
			ld   hl, +$0100
			jp   .setSpeed
		.fldHeavy:
			ld   hl, +$0200
			jp   .setSpeed
		.fldHeavyMaxPow:
			ld   hl, +$0400
		.setSpeed:
			call Play_OBJLstS_SetSpeedH_ByXFlipR
			mMvC_SetSpeedV $0200
		pop  de
	pop  bc
	ret
; =============== ProjInit_Geese_RagingStormS ===============
; Initializes the projectile for Geese's Raging Storm (normal).
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
ProjInit_Geese_RagingStormS:
	mMvC_PlaySound SCT_PROJ_LG_A
	push bc
		push de
			push hl
				call ProjInitS_InitAndGetOBJInfo
				
				; Set code pointer
				ld   hl, iOBJInfo_Play_CodeBank
				add  hl, de
				ld   [hl], BANK(ProjC_Geese_RagingStorm)	; BANK $06 ; iOBJInfo_Play_CodeBank
				inc  hl
				ld   [hl], LOW(ProjC_Geese_RagingStorm)		; iOBJInfo_Play_CodePtr_Low
				inc  hl
				ld   [hl], HIGH(ProjC_Geese_RagingStorm)	; iOBJInfo_Play_CodePtr_High
				
				; Write sprite mapping ptr for this projectile.
				ld   hl, iOBJInfo_BankNum
				add  hl, de
				ld   [hl], BANK(OBJLstPtrTable_Proj_Geese_RagingStormS)	; BANK $01 ; iOBJInfo_BankNum
				inc  hl
				ld   [hl], LOW(OBJLstPtrTable_Proj_Geese_RagingStormS)	; iOBJInfo_OBJLstPtrTbl_Low
				inc  hl
				ld   [hl], HIGH(OBJLstPtrTable_Proj_Geese_RagingStormS)	; iOBJInfo_OBJLstPtrTbl_High
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
				ld   [hl], $3C ; iOBJInfo_Play_EnaTimer
				
				call OBJLstS_Overlap
			pop  hl
			call Play_OBJLstS_MoveH_ByXFlipR
		pop  de
	pop  bc
	ret
; =============== ProjInit_Geese_RagingStormD ===============
; Initializes the projectile for Geese's Raging Storm (desperation).
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
; - HL: Horizontal offset. Always $00.
ProjInit_Geese_RagingStormD:
	mMvC_PlaySound SCT_PROJ_LG_A
	push bc
		push de
			push hl
				call ProjInitS_InitAndGetOBJInfo
				
				; Set code pointer
				ld   hl, iOBJInfo_Play_CodeBank
				add  hl, de
				ld   [hl], BANK(ProjC_Geese_RagingStorm)	; BANK $06 ; iOBJInfo_Play_CodeBank
				inc  hl
				ld   [hl], LOW(ProjC_Geese_RagingStorm)		; iOBJInfo_Play_CodePtr_Low
				inc  hl
				ld   [hl], HIGH(ProjC_Geese_RagingStorm)	; iOBJInfo_Play_CodePtr_High
				
				; Write sprite mapping ptr for this projectile.
				ld   hl, iOBJInfo_BankNum
				add  hl, de
				ld   [hl], BANK(OBJLstPtrTable_Proj_Geese_RagingStormD)	; BANK $01 ; iOBJInfo_BankNum
				inc  hl
				ld   [hl], LOW(OBJLstPtrTable_Proj_Geese_RagingStormD)	; iOBJInfo_OBJLstPtrTbl_Low
				inc  hl
				ld   [hl], HIGH(OBJLstPtrTable_Proj_Geese_RagingStormD)	; iOBJInfo_OBJLstPtrTbl_High
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
				ld   [hl], $5A ; iOBJInfo_Play_EnaTimer
				
				call OBJLstS_Overlap
				
			; [TCRF] The horizontal offset is always $00, so it doesn't do anything.
			;        This being here is probably a result of copy/paste though.
			pop  hl
			call Play_OBJLstS_MoveH_ByXFlipR
		pop  de
	pop  bc
	ret
; =============== ProjC_Geese_ShippuKen ===============
; Projectile code for Geese's Shippu Ken.
ProjC_Geese_ShippuKen:
	; Move horz. and despawn on hit
	call ExOBJS_Play_ChkHitModeAndMoveH
	jp   c, .despawn
	
	call OBJLstS_DoAnimTiming_Loop_by_DE
	
	; Despawn when touching the ground
	mMvC_ChkGravityV $0000, .despawn
	ret
.despawn:
	call OBJLstS_Hide
	ret
	
; =============== ProjC_Geese_RagingStorm ===============
; Projectile code for Geese's Raging Storm.
ProjC_Geese_RagingStorm:

	; Handle the despawn timer
	ld   hl, iOBJInfo_Play_EnaTimer
	add  hl, de
	dec  [hl]
	jp   z, .despawn
	
	; Slow down a tiny bit the animation over time, based on the despawn timer.
	; Initially, it's set to $00.
	; Once it goes below $10, set it to $01.
	ld   a, [hl]	; A = iOBJInfo_Play_EnaTimer
	cp   $08		; A < $08?
	jp   c, .setSpeed2	; If so, jump
	cp   $10		; A < $10?
	jp   c, .setSpeed1	; If so jump
	jp   .anim
.setSpeed1:
	ld   a, $01		; A = New speed
	jp   .setSpeed
.setSpeed2:
	ld   a, $02		; A = New speed
.setSpeed:
	ld   hl, iOBJInfo_FrameTotal
	add  hl, de
	ld   [hl], a	; iOBJInfo_FrameTotal = A
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
	ret
.despawn:
	call OBJLstS_Hide
	ret
	
IF REV_LANG_EN == 1
TextC_EndingPost_FFGeese0:
	db .end-.start
.start:
	db "I`ll handle this one", C_NL
	db " my own.", C_NL
.end:
TextC_EndingPost_FFGeese1:
	db .end-.start
.start:
	db "Geese!", C_NL
	db "This time we`re", C_NL
	db " going to get you", C_NL
	db "           for good!", C_NL
.end:
TextC_EndingPost_AOFMrBig0:
	db .end-.start
.start:
	db "Ryo and Robert...", C_NL
	db "It`s time for you to", C_NL
	db " pay your debts!", C_NL
.end:
TextC_EndingPost_AOFMrBig1:
	db .end-.start
.start:
	db "Come on!", C_NL
.end:
TextC_EndingPost_KTR0:
	db .end-.start
.start:
	db "I am going to win!", C_NL
	db "I am the strongest!", C_NL
	db "Now it`s time to", C_NL
	db " settle things", C_NL
	db "           for good!", C_NL
.end:
ENDC

; =============== END OF BANK ===============
; Junk area with broken copies of the above subroutines.
IF REV_VER_2 == 0
	mIncJunk "L067E72"
ELSE
	mIncJunk "L067FEA"
ENDC