; =============== MoveC_Base_None ===============
; "No move" used after defeating an opponent.
MoveC_Base_None:
	; [POI] Completely pointless code that does nothing.
	ld   hl, iPlInfo_IntroMoveId
	add  hl, bc
	ld   a, [hl]
	or   a
	jr   z, .ret
	jp   .ret
.unused:
	call Play_Pl_EndMove
.ret:
	ret
	
; =============== MoveC_Base_Std ===============
; Simple move code handler that doesn't allow box overlapping.
MoveC_Base_Std:
	call Play_Pl_MoveByColiBoxOverlapX
	call OBJLstS_DoAnimTiming_Loop_by_DE
	ret
; =============== MoveC_Base_WalkH ===============
; Like MoveC_Base_Std, but allowing horizontal movement.
; Used for walking horizontally.
MoveC_Base_WalkH:
	call Play_Pl_MoveByColiBoxOverlapX
	call OBJLstS_ApplyXSpeed
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
	
; =============== MoveC_Base_NoAnim ===============
; Like MoveC_Base_Std, but without animating the player.
; Used when crouching or blocking, which don't animate the player.
MoveC_Base_NoAnim:
	call Play_Pl_MoveByColiBoxOverlapX
	ret
	
; =============== MoveC_Base_ChargeMeter ===============
; Custom code for MOVE_BASE_CHARGEMETER.
MoveC_Base_ChargeMeter:
	call Play_Pl_MoveByColiBoxOverlapX	; Prevent box overlap
	call Play_Pl_IsMoveLoading			; Is the move still loading?
	jp   c, .ret						; If so, return
.main:

	;
	; Force the player to charge until reaching the target animation frame.
	; Note that moves always use the Old set, since with player sprites
	; that's guaranteed to always be what's currently visible on screen.
	;
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetOld
	add  hl, de
	ld   a, [hl]	; A = Sprite mapping ID
	ld   hl, iPlInfo_OBJLstPtrTblOffsetMoveEnd
	add  hl, bc		; HL = Ptr to target
	cp   a, [hl]	; Did we reach the target ID?
	jp   z, .chkEnd	; If so, jump
	; Otherwise, wait and continue animating
	jp   .continue
	
.chkEnd:

	;
	; Check if the charge is ending.
	;
	
	; Syncronize to end of anim frame
	call OBJLstS_IsFrameEnd		; Is the frame about to change?
	jp   nc, .continue			; If not, continue animating it
	
	; If we reached Max Power, we can't charge anymore.
	; This is checking iPlInfo_MaxPowDecSpeed since it's the very first
	; variable that gets updated when we get in MAX Power mode.
	ld   hl, iPlInfo_MaxPowDecSpeed
	add  hl, bc
	ld   a, [hl]
	or   a				; iPlInfo_MaxPowDecSpeed != 0?
	jp   nz, .end		; If so, jump
	
	; After the charge starts, only holding A+B is needed to continue it.
	ld   hl, iPlInfo_JoyKeys
	add  hl, bc
	ld   a, [hl]
	and  a, KEY_A|KEY_B	; Holding A+B?
	cp   KEY_A|KEY_B	
	jp   z, .continue	; If not, jump
.end:
	; If we got here, the charge is over
	call Play_Pl_EndMove
	jp   .ret
.continue:
	; Continue animating it, which means the anim can restart
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
L024061:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L0240BB
	call OBJLstS_IsFrameEnd
	jp   nc, L024093
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L024093
	cp   $08
	jp   z, L024093
	ld   hl, $002C
	add  hl, bc
	ld   a, [hl]
	cp   $02
	jp   z, L02408E
	ld   a, $9D
	jp   L024090
L02408E:;J
	ld   a, $A6
L024090:;J
	call HomeCall_Sound_ReqPlayExId
L024093:;J
	call Play_Pl_CreateJoyMergedKeysLH
	jp   c, L0240A9
	call Play_Pl_GetDirKeys_ByXFlipR
	jp   nc, L0240A9
	bit  2, a
	jp   nz, L0240A9
	bit  0, a
	jp   nz, L0240B5
L0240A9:;J
	call Play_Pl_EndMove
	ld   hl, $0033
	add  hl, bc
	ld   a, $16
	ld   [hl], a
	jr   L0240BB
L0240B5:;J
	call OBJLstS_ApplyXSpeed
	call OBJLstS_DoAnimTiming_Loop_by_DE
L0240BB:;JR
	ret
L0240BC:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L024128
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L0240E5
	cp   $04
	jp   z, L024107
	cp   $08
	jp   z, L02411A
L0240D9: db $C3;X
L0240DA: db $07;X
L0240DB: db $41;X
L0240DC: db $21;X
L0240DD: db $1C;X
L0240DE: db $00;X
L0240DF: db $19;X
L0240E0: db $36;X
L0240E1: db $FF;X
L0240E2: db $C3;X
L0240E3: db $25;X
L0240E4: db $41;X
L0240E5:;J
	ld   hl, $0000
	add  hl, de
	bit  3, [hl]
	jp   z, L0240FD
	ld   hl, $FD00
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FD00
	call Play_OBJLstS_SetSpeedV
	jp   L024107
L0240FD:;J
	ld   a, $FD
	ld   h, $FF
	call OBJLstS_ReqAnimOnGtYSpeed
	jp   L024107
L024107:;J
	ld   hl, $0060
	call OBJLstS_ApplyGravity
	jp   nc, L024125
	ld   a, $08
	ld   h, $00
	call Play_Pl_SetJumpLandAnimFrame
	jp   L024128
L02411A:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L024125
	call Play_Pl_EndMove
	jr   L024128
L024125:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L024128:;JR
	ret
L024129:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L024172
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L02414E
	cp   $04
	jp   z, L02415A
	cp   $08
	jp   z, L024166
	cp   $10
	jp   z, L02418B
	jp   L024172
L02414E:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L024172
	inc  hl
	ld   [hl], $12
	jp   L024172
L02415A:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L024172
	inc  hl
	ld   [hl], $03
	jp   L024172
L024166:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L024172
	inc  hl
	ld   [hl], $FF
	jp   L024172
L024172:;J
	ld   hl, $0060
	call OBJLstS_ApplyGravity
	jp   nc, L024196
	ld   hl, $0021
	add  hl, bc
	res  2, [hl]
	ld   a, $10
	ld   h, $00
	call Play_Pl_SetJumpLandAnimFrame
	jp   L024199
L02418B:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L024196
	call Play_Pl_EndMove
	jr   L024199
L024196:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L024199:;JR
	ret
L02419A:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L0241B5
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L0241B5
	cp   $04
	jp   z, L0241CE
L0241B2: db $C3;X
L0241B3: db $B5;X
L0241B4: db $41;X
L0241B5:;J
	ld   hl, $0060
	call OBJLstS_ApplyGravity
	jp   nc, L0241D9
	ld   a, $04
	ld   h, $00
	call Play_Pl_SetJumpLandAnimFrame
	ld   hl, $0021
	add  hl, bc
	res  3, [hl]
	jp   L0241DC
L0241CE:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0241D9
	call Play_Pl_EndMove
	jr   L0241DC
L0241D9:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L0241DC:;JR
	ret
L0241DD:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L024255
	call Play_Pl_CreateJoyMergedKeysLH
	jp   nc, L0241F5
	ld   hl, $001B
	add  hl, de
	ld   [hl], $00
	inc  hl
	ld   [hl], $00
L0241F5:;J
	call Play_Pl_IsMoveLoading
	jp   c, L024255
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L024213
	cp   $04
	jp   z, L024221
	ld   hl, $0039
	add  hl, bc
	cp   a, [hl]
	jr   z, L024247
L024211: db $18;X
L024212: db $3F;X
L024213:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L024252
	ld   a, $08
	call HomeCall_Sound_ReqPlayExId
	jp   L024252
L024221:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L024252
	ld   hl, $0049
	add  hl, bc
	ld   a, [hl]
	and  a, $F0
	jr   z, L024252
	ld   hl, $001B
	add  hl, de
	ld   [hl], $00
	inc  hl
	ld   [hl], $00
	ld   hl, $0039
	add  hl, bc
	ld   a, [hl]
	sub  a, $04
	ld   hl, $0013
	add  hl, de
	ld   [hl], a
	jr   L024252
L024247:;R
	call OBJLstS_IsFrameEnd
	jp   nc, L024252
	call Play_Pl_EndMove
	jr   L024255
L024252:;JR
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L024255:;JR
	ret
L024256:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L024279
	call OBJLstS_IsFrameEnd
	jp   nc, L024276
	ld   hl, $0013
	add  hl, de
	ld   a, [hl]
	ld   hl, $0039
	add  hl, bc
	cp   a, [hl]
	jr   nz, L024276
	call Play_Pl_EndMove
	jr   L024279
L024276:;JR
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L024279:;JR
	ret
L02427A:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L02432B
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L02429A
	cp   $0C
	jp   z, L0242E2
	cp   $10
	jp   z, L0242EE
	jp   L024325
L02429A:;J
	ld   hl, $0000
	add  hl, de
	bit  3, [hl]
	jp   z, L0242DF
	ld   hl, $0033
	add  hl, bc
	ld   a, [hl]
	cp   $1E
	jp   z, L0242B2
	cp   $20
	jp   z, L0242C7
L0242B2:;J
	ld   hl, $0083
	add  hl, bc
	ld   a, [hl]
	or   a
	jp   nz, L0242C1
	ld   hl, $0200
	jp   L0242DC
L0242C1:;J
	ld   hl, $0280
	jp   L0242DC
L0242C7:;J
	ld   hl, $0083
	add  hl, bc
	ld   a, [hl]
	or   a
	jp   nz, L0242D6
	ld   hl, OAM_Begin
	jp   L0242DC
L0242D6: db $21;X
L0242D7: db $80;X
L0242D8: db $FD;X
L0242D9: db $C3;X
L0242DA: db $DC;X
L0242DB: db $42;X
L0242DC:;J
	call Play_OBJLstS_SetSpeedH_ByXFlipR
L0242DF:;J
	jp   L024325
L0242E2:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L024325
	inc  hl
	ld   [hl], $04
	jp   L024325
L0242EE:;J
	ld   hl, $0000
	add  hl, de
	bit  3, [hl]
	jp   z, L02431A
	ld   hl, $0083
	add  hl, bc
	ld   a, [hl]
	or   a
	jp   z, L02430C
	ld   hl, $0020
	add  hl, bc
	res  6, [hl]
	inc  hl
	res  2, [hl]
	jp   L024314
L02430C:;J
	ld   hl, $0022
	add  hl, bc
	res  6, [hl]
	res  7, [hl]
L024314:;J
	ld   hl, $0000
	call Play_OBJLstS_SetSpeedH_ByXFlipR
L02431A:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L024328
	call Play_Pl_EndMove
	jr   L02432B
L024325:;J
	call OBJLstS_ApplyXSpeed
L024328:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L02432B:;JR
	ret
L02432C:;I
	ld   hl, $002C
	add  hl, bc
	ld   a, [hl]
	cp   $0E
	jp   z, L0243A3
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L0243A2
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L024354
	ld   hl, $0039
	add  hl, bc
	cp   a, [hl]
	jp   z, L024394
	jp   L02439F
L024354:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L02439F
	ld   hl, $002C
	add  hl, bc
	ld   a, [hl]
	cp   $0C
	jp   z, L024385
	cp   $10
	jp   z, L024385
	cp   $24
	jp   z, L024385
	cp   $18
	jp   z, L024385
	cp   $22
	jp   z, L024385
	cp   $14
	jp   z, L024385
	cp   $20
	jp   z, L024385
	jp   L02439F
L024385:;J
	ld   a, $02
	jp   L02438C
L02438A: db $3E;X
L02438B: db $03;X
L02438C:;J
	ld   hl, $001C
	add  hl, de
	ld   [hl], a
	jp   L02439F
L024394:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L02439F
	call Play_Pl_EndMove
	jr   L0243A2
L02439F:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L0243A2:;JR
	ret
L0243A3:;J
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L02441F
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L0243D5
	cp   $04
	jp   z, L0243E1
	cp   $08
	jp   z, L0243ED
	cp   $18
	jp   z, L0243F9
	cp   $1C
	jp   z, L024405
	ld   hl, $0039
	add  hl, bc
	cp   a, [hl]
	jp   z, L024411
	jp   L02441C
L0243D5:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L02441C
	inc  hl
	ld   [hl], $1E
	jp   L02441C
L0243E1:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L02441C
	inc  hl
	ld   [hl], $14
	jp   L02441C
L0243ED:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L02441C
	inc  hl
	ld   [hl], $00
	jp   L02441C
L0243F9:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L02441C
	inc  hl
	ld   [hl], $28
	jp   L02441C
L024405:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L02441C
	inc  hl
	ld   [hl], $0A
	jp   L02441C
L024411:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L02441C
	call Play_Pl_EndMove
	jr   L02441F
L02441C:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L02441F:;JR
	ret
L024420:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L024454
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $04
	jp   z, L024445
	ld   hl, $0000
	add  hl, de
	bit  3, [hl]
	jp   z, L024442
	ld   hl, $0021
	add  hl, bc
	res  2, [hl]
L024442:;J
	jp   L024451
L024445:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L024451
	call L024455
	jp   L024454
L024451:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L024454:;J
	ret
L024455:;C
	call Play_Pl_IsDizzy
	jp   z, L02448F
	ld   hl, $005B
	add  hl, bc
	ld   a, [hl]
	add  a, $08
	jp   nc, L024467
L024465: db $3E;X
L024466: db $FF;X
L024467:;J
	ldd  [hl], a
	ldd  [hl], a
	ld   a, $FF
	ldd  [hl], a
	ld   [hl], $00
	ld   hl, $005E
	add  hl, bc
	ld   [hl], $00
	ld   hl, $0020
	add  hl, bc
	res  2, [hl]
	res  3, [hl]
	res  4, [hl]
	res  5, [hl]
	inc  hl
	set  2, [hl]
	res  4, [hl]
	res  6, [hl]
	res  7, [hl]
	ld   a, $24
	call Pl_Unk_SetNewMoveAndAnim_StopSpeed
	ret
L02448F:;J
	call Play_Pl_EndMove
	ret
L024493:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L0244BE
	call L0244BF
	ld   hl, $0059
	add  hl, bc
	ld   a, [hl]
	or   a
	jp   z, L0244B6
	call OBJLstS_IsFrameEnd
	jp   nc, L0244BB
	ld   a, $01
	call HomeCall_Sound_ReqPlayExId
	jp   L0244BB
L0244B6:;J
	call Play_Pl_EndMove
	jr   L0244BE
L0244BB:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L0244BE:;JR
	ret
L0244BF:;C
	ld   a, [wRoundTime]
	or   a
	jp   nz, L0244CF
	xor  a
	ld   hl, $0059
	add  hl, bc
	ld   [hl], a
	jp   L024528
L0244CF:;J
	ld   hl, $0020
	add  hl, bc
	bit  7, [hl]
	jp   z, L024506
	ld   a, [wDifficulty]
	cp   $00
	jp   z, L0244FB
	cp   $01
	jp   z, L0244F0
	ld   a, [wTimer]
	and  a, $F0
	jp   nz, L02451C
	jp   L024510
L0244F0:;J
	ld   a, [wTimer]
	and  a, $30
	jp   nz, L02451C
	jp   L024510
L0244FB:;J
	ld   a, [wTimer]
	and  a, $00
	jp   nz, L02451C
	jp   L024510
L024506:;J
	ld   hl, $0044
	add  hl, bc
	ld   a, [hl]
	and  a, $7F
	jp   nz, L02451C
L024510:;J
	ld   hl, $0059
	add  hl, bc
	dec  [hl]
	jp   nc, L024519
L024518: db $AF;X
L024519:;J
	jp   L024528
L02451C:;J
	ld   hl, $0059
	add  hl, bc
	ld   a, [hl]
	sub  a, $08
	jp   nc, L024527
	xor  a
L024527:;J
	ld   [hl], a
L024528:;J
	ret
L024529:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L024564
	call OBJLstS_IsFrameEnd
	jp   nc, L024561
	ld   hl, $0013
	add  hl, de
	ld   a, [hl]
	ld   hl, $0039
	add  hl, bc
	cp   a, [hl]
	jr   nz, L024561
	ld   hl, $0033
	add  hl, bc
	ld   a, [hl]
	cp   $28
	jr   nz, L024559
	ld   hl, $002C
	add  hl, bc
	ld   a, [hl]
	cp   $04
	jr   nz, L024559
	call L024565
L024559:;R
	call Play_Pl_EndMove
	call Task_RemoveCurAndPassControl
L02455F: db $18;X
L024560: db $03;X
L024561:;JR
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L024564:;J
	ret
L024565:;C
	push bc
	push de
	push de
	pop  bc
	ld   de, wOBJInfo2+iOBJInfo_Status
	ld   hl, $0000
	add  hl, de
	ld   [hl], $80
	ld   hl, $000D
	add  hl, de
	ld   [hl], $80
	ld   hl, $0020
	add  hl, de
	ld   [hl], $02
	inc  hl
	ld   [hl], $BA
	inc  hl
	ld   [hl], $45
	ld   hl, $0010
	add  hl, de
	ld   [hl], $01
	inc  hl
	ld   [hl], $E8
	inc  hl
	ld   [hl], $48
	inc  hl
	ld   [hl], $00
	ld   hl, $001B
	add  hl, de
	ld   [hl], $08
	inc  hl
	ld   [hl], $08
	call OBJLstS_Overlap
	ld   hl, $1000
	call Play_OBJLstS_MoveH_ByXFlipR
	ld   hl, $D000
	call Play_OBJLstS_MoveV
	ld   hl, $0100
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FD00
	call Play_OBJLstS_SetSpeedV
	pop  de
	pop  bc
	ret
L0245BA:;I
	call L0028B2
	ld   hl, $0030
	call L003672
	jp   c, L0245CA
	call OBJLstS_DoAnimTiming_Loop_by_DE
	ret
L0245CA:;J
	ld   hl, $0000
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $0000
	call Play_OBJLstS_SetSpeedV
	ret
; =============== ExOBJ_SuperSparkle ===============
; Animation code for the sparkle effect shown at the start of a move.
; IN
; - DE: Ptr to wOBJInfo_Pl*SuperSparkle
; - BC: Ptr to wOBJInfo_Pl*+$200
ExOBJ_SuperSparkle:

	;
	; Continue animating the sparkle until the timer reaches 0.
	; As this is set to $14 by default, that's how long the sparkle plays.
	;
	; While the sparkle is active, the player is invulnerable.
	; This helps pulling off supers without getting immediately damaged,
	; especially if a guard cancel was performed.
	;
	
	ld   hl, iOBJInfo_SuperSparkle_EnaTimer
	add  hl, de			; Seek to timer
	dec  [hl]			; Timer--
	jp   z, .hide		; Did it reach 0? If so, jump
.anim:
	;
	; Give invulnerability while the sparkle is active.
	;
	; This is accomplished by setting PF1B_INVULN to the iPlInfo_Flags1 field of the
	; wPlInfo structure associated with the sparkle.
	;
	; As a side effect of the subroutine that calls this one,
	; when we get here, BC is pointing to an invalid wPlInfo structure.
	; This is always $200 bytes past the wPlInfo for the player side we want, so...
	; 
	ld   hl, -$200+iPlInfo_Flags1
	add  hl, bc
	set  PF1B_INVULN, [hl]	; Set proj. invul flag
	
	; Animate sparkle
	call OBJLstS_DoAnimTiming_Loop_by_DE
	ret
.hide:
	;
	; Make it disappear when it gets to 0, and disable invulnerability.
	;
	ld   hl, -$200+iPlInfo_Flags1
	add  hl, bc
	res  PF1B_INVULN, [hl]	; Clear proj.
	
	; Hide sparkle
	call OBJLstS_Hide
	ret
	
; =============== Play_Pl_DoHit ===============
; Handles the hit/block state and its animations.
; Note that this is called every frame by the player tasks.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
; OUT
; - C flag: If set, a move was started (by guard cancelling)
Play_Pl_DoHit:

	; For all intents and purposes Play_Pl_DoHit is a direct continuation of Play_Pl_SetHitAnim.
	; Set up everything, update counters, damage player, (...) if it's applicable.
	; A = HitAnim ID * 2
	call Play_Pl_SetHitAnim	; Did the opponent's attack make contact?
	jp   nc, .noHit			; If not, jump
	
	; We only get here for the single frame the attack makes contact.
	; After that, the hit animation code gets executed, which takes exclusive control
	; for a bit due to it calling the hitstun/blockstun code (only for the duration of the initial shake).
	
	; Empty the pow meter in case we got hit out of a super
	push af
		call Play_Pl_EmptyPowOnSuperEnd
	pop  af
	
	; HITANIM_DROP_SPEC_AIR_0E does not increment the combo counter
	cp   HITANIM_DROP_SPEC_AIR_0E*2	; HitAnimId >= $0E?
	jp   nc, .updateFlags			; If so, skip
	
	push af
		;
		; If we got hit, increment the combo counter shown on the opponent's side.
		;
		ld   hl, iPlInfo_Flags1
		add  hl, bc
		bit  PF1B_GUARD, [hl]	; Did we block the hit?
		jp   nz, .noComboInc	; If so, skip
		ld   hl, iPlInfo_HitComboRecvSet
		add  hl, bc				
		ld   a, [hl]			; A = iPlInfo_HitComboRecvSet
		inc  a					; A++
		daa						; account for decimal
		ld   [hl], a			; Save back
	pop  af
	jp   .updateFlags
.noComboInc:
	pop  af
	
.updateFlags:
	;
	; If we didn't block the hit, we're definitely not doing a special or super move.
	;
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	bit  PF1B_GUARD, [hl]		; Did we block the hit?
	jp   nz, .updateFlags1		; If so, skip
	ld   hl, iPlInfo_Flags0		; Otherwise, clear move type flags
	add  hl, bc
	res  PF0B_SPECMOVE, [hl]		
	res  PF0B_SUPERMOVE, [hl]
	inc  hl
	
.updateFlags1:
	; Don't override hitstun/blockstun with basic moves/normals
	set  PF1B_NOBASICINPUT, [hl]
	; Prevent the player from autoswitching direction during hitstun or blockstun
	set  PF1B_XFLIPLOCK, [hl]	
	; Mark that the opponent's attack made contact.
	; This a few effects, like making any next hit in the combo deal less penalty to the dizzy or guard break counters.
	set  PF1B_COMBORECV, [hl]
	
	;
	; Prevent cancelling out of hitstun.
	; (though there's a special override in PF1B_ALLOWHITCANCEL)
	;
	cp   HITANIM_BLOCKED			; Are we in the blockstun anim?
	jp   z, .execCode				; If so, skip
	set  PF1B_NOSPECSTART, [hl]	; Otherwise, we got hit. Prevent specials from starting.
.execCode:
	;
	; Execute the code for the currently set Hit Animation.
	; This has the same purpose as the move code, except it's specifically for getting hit/blocking.
	;
	
	push bc
		; Index Play_HitAnimPtrTable by HitAnimId
		ld   hl, Play_HitAnimPtrTable	; HL = Ptr to start of table
		ld   b, $00		; BC = HitAnimId (* 2)
		ld   c, a
		add  hl, bc		; Index it
		; Read it out to BC
		ld   c, [hl]
		inc  hl
		ld   b, [hl]
		push bc
		; Move to HL
		pop  hl			
	pop  bc
	jp   hl	; And jump there
.noHit:
	;
	; When the opponent's attack didn't come in contact and we're out of "combo mode",
	; hide the combo counter that's displayed on the opponent side.
	;
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	bit  PF1B_COMBORECV, [hl]			; Is the combo mode enabled?
	jp   nz, .end						; If so, skip
	ld   hl, iPlInfo_HitComboRecvSet	; Otherwise, reset hit counter
	add  hl, bc
	ld   [hl], $00
.end:
	xor  a	; C flag clear
	ret
	
Play_HitAnimPtrTable:
	dw HitAnim_Blocked
	dw HitAnim_GuardBreakGround
	dw HitAnim_GuardBreakAir
	dw HitAnim_Hit0Mid
	dw HitAnim_Hit1Mid
	dw HitAnim_HitLow
	dw HitAnim_06
	dw HitAnim_07
	dw HitAnim_08
	dw HitAnim_09
	dw HitAnim_0A
	dw HitAnim_0B
	dw HitAnim_0C
	dw HitAnim_0D
	dw HitAnim_0E
	dw HitAnim_0F
	dw HitAnim_ThrowStart
	dw HitAnim_ThrowRotU
	dw HitAnim_ThrowRotL
	dw HitAnim_ThrowRotD
	dw HitAnim_ThrowRotR


HitAnim_Blocked:;I
	ld   a, $0D
	ld   hl, $0020
	add  hl, bc
	bit  1, [hl]
	jp   nz, L024695
	bit  6, [hl]
	jp   nz, L024695
	ld   a, $0A
L024695:;J
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0021
	add  hl, bc
	set  3, [hl]
	ld   hl, $0023
	add  hl, bc
	res  1, [hl]
	res  6, [hl]
	ld   hl, $001B
	add  hl, de
	ld   [hl], $05
	ld   hl, $0050
	add  hl, bc
	ld   a, [hl]
	cp   $28
	jp   z, L0246BC
	ld   hl, $0021
	add  hl, bc
	set  2, [hl]
L0246BC:;J
	call Play_Pl_DoBlockstun
	jp   c, L024702
	call Play_Pl_MoveByColiBoxOverlapX
	ld   hl, $0033
	add  hl, bc
	ld   a, [hl]
	cp   $10
	jp   z, L0246DC
	cp   $12
	jp   z, L0246DC
	cp   $14
	jp   z, L0246E1
	jp   L024702
L0246DC:;J
	ld   [hl], $70
	jp   L024700
L0246E1:;J
	ld   hl, $001B
	add  hl, de
	ld   [hl], $FF
	ld   hl, $0080
	call Play_OBJLstS_SetSpeedH_ByXDirL
	ld   hl, $0009
	add  hl, de
	ld   a, [hl]
	bit  7, a
	jp   nz, L024700
	ld   hl, $0000
	call Play_OBJLstS_SetSpeedV
	jp   L024700
L024700:;J
	scf
	ret
L024702:;J
	scf
	ccf
	ret
HitAnim_GuardBreakGround:;I
	ld   hl, $0023
	add  hl, bc
	res  1, [hl]
	res  6, [hl]
	ld   a, $1C
	call HomeCall_Sound_ReqPlayExId
	ld   a, $72
	call Pl_Unk_SetNewMoveAndAnim_ShakeScreenReset
	ld   a, $0F
	call L025003
	ld   a, $00
	ld   [wStageBGP], a
	call Play_Unk_Pl_BlockstunNormal
	call Play_Pl_MoveByColiBoxOverlapX
	ld   hl, $0050
	add  hl, bc
	ld   a, [hl]
	cp   $28
	jp   nz, L024733
	ld   [hl], $00
L024733:;J
	scf
	ret
HitAnim_GuardBreakAir: db $21;X
L024736: db $23;X
L024737: db $00;X
L024738: db $09;X
L024739: db $CB;X
L02473A: db $8E;X
L02473B: db $CB;X
L02473C: db $B6;X
L02473D: db $3E;X
L02473E: db $1C;X
L02473F: db $CD;X
L024740: db $16;X
L024741: db $10;X
L024742: db $3E;X
L024743: db $74;X
L024744: db $CD
L024745: db $51
L024746: db $34
L024747: db $3E
L024748: db $00;X
L024749: db $EA;X
L02474A: db $7C;X
L02474B: db $C1;X
L02474C: db $CD;X
L02474D: db $E8;X
L02474E: db $3A;X
L02474F: db $CD;X
L024750: db $7B;X
L024751: db $34;X
L024752: db $21;X
L024753: db $80;X
L024754: db $00;X
L024755: db $CD;X
L024756: db $85;X
L024757: db $35;X
L024758: db $21;X
L024759: db $09;X
L02475A: db $00;X
L02475B: db $19;X
L02475C: db $7E;X
L02475D: db $CB;X
L02475E: db $7F;X
L02475F: db $C2;X
L024760: db $68;X
L024761: db $47;X
L024762: db $21;X
L024763: db $00;X
L024764: db $00;X
L024765: db $CD;X
L024766: db $AD;X
L024767: db $35;X
L024768: db $21;X
L024769: db $50;X
L02476A: db $00;X
L02476B: db $09;X
L02476C: db $7E;X
L02476D: db $FE;X
L02476E: db $28;X
L02476F: db $C2;X
L024770: db $74;X
L024771: db $47;X
L024772: db $36;X
L024773: db $00;X
L024774: db $37;X
L024775: db $C9;X
HitAnim_Hit0Mid:;I
	ld   a, $76
	jp   L024782
HitAnim_Hit1Mid:;I
	ld   a, $78
	jp   L024782
HitAnim_HitLow:;I
	ld   a, $7A
L024782:;J
	push af
	call L0249F2
	pop  af
	call Pl_Unk_SetNewMoveAndAnim_ShakeScreenReset
	ld   a, $0F
	call L025003
	call L02504C
	call Play_Unk_Pl_BlockstunNormal
	call Play_Pl_MoveByColiBoxOverlapX
	scf
	ret
HitAnim_08:;I
	ld   hl, $0020
	add  hl, bc
	bit  1, [hl]
	jp   z, L0247AA
L0247A3: db $23;X
L0247A4: db $23;X
L0247A5: db $23;X
L0247A6: db $CB;X
L0247A7: db $C6;X
L0247A8: db $CB;X
L0247A9: db $E6;X
L0247AA:;J
	ld   hl, $004E
	add  hl, bc
	ld   a, [hl]
	ld   hl, $0020
	add  hl, bc
	or   a
	jp   z, L0247C3
	inc  hl
	inc  hl
	inc  hl
	bit  4, [hl]
	jp   nz, L0247C3
	dec  hl
	dec  hl
	set  7, [hl]
L0247C3:;J
	call L0249F2
	ld   a, $7C
	call Pl_Unk_SetNewMoveAndAnim_ShakeScreenReset
	ld   a, $1E
	call L025003
	call L02504C
	call Play_Unk_Pl_BlockstunNormal
	call Play_Pl_MoveByColiBoxOverlapX
	ld   hl, $0023
	add  hl, bc
	bit  7, [hl]
	jp   nz, L024802
	bit  0, [hl]
	jp   nz, L0247F6
	ld   hl, $0140
	call Play_OBJLstS_SetSpeedH_ByXDirL
	ld   hl, $FC00
	call Play_OBJLstS_SetSpeedV
	jp   L024802
L0247F6:;J
	ld   hl, $0180
	call Play_OBJLstS_SetSpeedH_ByXDirL
	ld   hl, $FA00
	call Play_OBJLstS_SetSpeedV
L024802:;J
	scf
	ret
HitAnim_0C:;I
	ld   hl, $004E
	add  hl, bc
	ld   a, [hl]
	ld   hl, $0020
	add  hl, bc
	or   a
	jp   z, L02481D
	inc  hl
	inc  hl
	inc  hl
	bit  4, [hl]
	jp   nz, L02481D
	dec  hl
	dec  hl
	set  7, [hl]
L02481D:;J
	call L0249F2
	ld   a, $7E
	call Pl_Unk_SetNewMoveAndAnim_ShakeScreenReset
	call L02504C
	call Play_Unk_Pl_BlockstunNormal
	call Play_Pl_MoveByColiBoxOverlapX
	ld   hl, $0023
	add  hl, bc
	bit  0, [hl]
	jp   nz, L02483D
	ld   hl, $0500
	jp   L024840
L02483D:;J
	ld   hl, $0600
L024840:;J
	call Play_OBJLstS_SetSpeedH_ByXDirL
	ld   hl, $0600
	call Play_OBJLstS_SetSpeedV
	scf
	ret
HitAnim_0D:;I
	ld   hl, $0023
	add  hl, bc
	bit  4, [hl]
	jp   nz, L024858
	dec  hl
	dec  hl
	set  7, [hl]
L024858:;J
	call L0249F2
	ld   a, $80
	call Pl_Unk_SetNewMoveAndAnim_ShakeScreenReset
	call L02504C
	call Play_Unk_Pl_BlockstunNormalOnce
	call Play_Pl_MoveByColiBoxOverlapX
	scf
	ret
HitAnim_0F:;I
	ld   hl, $004E
	add  hl, bc
	ld   a, [hl]
	ld   hl, $0020
	add  hl, bc
	or   a
	jp   z, L024884
	inc  hl
	inc  hl
	inc  hl
	bit  4, [hl]
	jp   nz, L024884
	dec  hl
	dec  hl
	set  7, [hl]
L024884:;J
	ld   hl, $007C
	add  hl, bc
	ld   [hl], $01
	ld   a, $8E
	call Pl_Unk_SetNewMoveAndAnim_ShakeScreenReset
	ld   hl, $0071
	add  hl, bc
	ld   a, [hl]
	cp   $1A
	jp   z, L0248A1
	cp   $0E
	jp   z, L0248B3
	jp   L0248DE
L0248A1:;J
	ld   hl, $0072
	add  hl, bc
	ld   a, [hl]
	cp   $48
	jp   z, L0248C0
	cp   $4A
	jp   z, L0248C0
L0248B0: db $C3;X
L0248B1: db $DE;X
L0248B2: db $48;X
L0248B3:;J
	ld   hl, $0072
	add  hl, bc
	ld   a, [hl]
	cp   $6C
	jp   z, L0248CF
L0248BD: db $C3;X
L0248BE: db $DE;X
L0248BF: db $48;X
L0248C0:;J
	ld   hl, $0900
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FC00
	call Play_OBJLstS_SetSpeedV
	jp   L0248F9
L0248CF:;J
	ld   hl, $FD00
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FC00
	call Play_OBJLstS_SetSpeedV
	jp   L0248F9
L0248DE:;J
	ld   hl, $0023
	add  hl, bc
	bit  0, [hl]
	jp   nz, L0248ED
	ld   hl, $0200
	jp   L0248F0
L0248ED:;J
	ld   hl, $0300
L0248F0:;J
	call Play_OBJLstS_SetSpeedH_ByXDirL
	ld   hl, $FC00
	call Play_OBJLstS_SetSpeedV
L0248F9:;J
	scf
	ret
HitAnim_0E:;I
	ld   hl, $0071
	add  hl, bc
	ld   a, [hl]
	cp   $02
	jp   nz, L024937
	ld   a, $82
	call Pl_Unk_SetNewMoveAndAnim_ShakeScreenReset
	call Play_Pl_GiveKnockbackCornered
	ld   hl, $0021
	add  hl, bc
	set  7, [hl]
	ld   hl, $0072
	add  hl, bc
	ld   a, [hl]
	cp   $64
	jr   nc, L024928
	ld   hl, $F900
	call Play_OBJLstS_SetSpeedV
	ld   hl, $0300
	jp   L024931
L024928:;R
	ld   hl, $F400
	call Play_OBJLstS_SetSpeedV
	ld   hl, $0200
L024931:;J
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	jp   L02497F
L024937:;J
	ld   hl, $004E
	add  hl, bc
	ld   a, [hl]
	ld   hl, $0020
	add  hl, bc
	or   a
	jp   z, L024950
	inc  hl
	inc  hl
	inc  hl
	bit  4, [hl]
	jp   nz, L024950
	dec  hl
	dec  hl
	set  7, [hl]
L024950:;J
	ld   hl, $0021
	add  hl, bc
	set  7, [hl]
	ld   a, $82
	call Pl_Unk_SetNewMoveAndAnim_ShakeScreenReset
	call Play_Pl_MoveByColiBoxOverlapX
	ld   hl, $0180
	call Play_OBJLstS_MoveH_ByOtherProjOnR
	ld   hl, $0023
	add  hl, bc
	bit  0, [hl]
	jp   nz, L024973
L02496D: db $21;X
L02496E: db $00;X
L02496F: db $00;X
L024970: db $C3;X
L024971: db $76;X
L024972: db $49;X
L024973:;J
	ld   hl, $0000
	call Play_OBJLstS_SetSpeedH_ByXDirL
	ld   hl, OAM_Begin
	call OBJLstS_ApplyGravity
L02497F:;J
	scf
	ret
HitAnim_06:;I
	ld   hl, $0020
	add  hl, bc
	or   a
	jp   z, L024995
	inc  hl
	inc  hl
	inc  hl
	bit  4, [hl]
	jp   nz, L024995
	dec  hl
	dec  hl
	set  7, [hl]
L024995:
	call L0249F2
	ld   a, $84
	call Pl_Unk_SetNewMoveAndAnim_ShakeScreenReset
	call Play_Unk_Pl_BlockstunNormal
	call Play_Pl_MoveByColiBoxOverlapX
	ld   hl, $0180
	call Play_OBJLstS_SetSpeedH_ByXDirL
	ld   hl, $0023
	add  hl, bc
	bit  0, [hl]
	jp   nz, L0249B8
	ld   hl, $FD00
	jp   L0249BB
L0249B8: db $21;X
L0249B9: db $00;X
L0249BA: db $FC;X
L0249BB:;J
	call Play_OBJLstS_SetSpeedV
	scf
	ret
HitAnim_07:;I
	ld   hl, $0020
	add  hl, bc
	inc  hl
	set  7, [hl]
	call L0249F2
	ld   a, $86
	call Pl_Unk_SetNewMoveAndAnim_ShakeScreenReset
	call Play_Unk_Pl_BlockstunNormal
	call Play_Pl_MoveByColiBoxOverlapX
	ld   hl, $0023
	add  hl, bc
	bit  0, [hl]
	jp   nz, L0249E4
	ld   hl, $0180
	jp   L0249E7
L0249E4:;J
	ld   hl, $0180
L0249E7:;J
	call Play_OBJLstS_SetSpeedH_ByXDirL
	ld   hl, $FC00
	call Play_OBJLstS_SetSpeedV
	scf
	ret
L0249F2:;C
	ld   hl, $0023
	add  hl, bc
	bit  1, [hl]
	jp   nz, L024A00
	ld   a, $0B
	jp   L024A02
L024A00:;J
	ld   a, $13
L024A02:;J
	call HomeCall_Sound_ReqPlayExId
	ret
HitAnim_09:;I
	ld   a, $88
	jp   L024A0D
HitAnim_0A:;I
	ld   a, $8A
L024A0D:;J
	push af
	ld   a, $0C
	call HomeCall_Sound_ReqPlayExId
	pop  af
	call Pl_Unk_SetNewMoveAndAnim_ShakeScreenReset
	call L024A5B
	call L02504C
	call Play_Unk_Pl_BlockstunNormalOnce
	call Play_Pl_GiveKnockbackCornered
	scf
	ret
HitAnim_0B:;I
	ld   a, $8C
	push af
	ld   a, $0C
	call HomeCall_Sound_ReqPlayExId
	pop  af
	call Pl_Unk_SetNewMoveAndAnim_ShakeScreenReset
	ld   hl, $0005
	add  hl, de
	ld   [hl], $88
	call L024AB1
	ld   hl, $0071
	add  hl, bc
	ld   a, [hl]
	cp   $02
	jp   z, L024A4A
	ld   hl, $F000
	jp   L024A4D
L024A4A:;J
	ld   hl, $E000
L024A4D:;J
	call Play_OBJLstS_MoveH_ByXDirR
	call L02504C
	call Play_Unk_Pl_BlockstunNormalOnce
	call Play_Pl_GiveKnockbackCornered
	scf
	ret
L024A5B:;C
	ld   hl, $0071
	add  hl, bc
	ld   a, [hl]
	cp   $08
	jp   z, L024A68
	jp   L024AA1
L024A68:;J
	ld   hl, $0072
	add  hl, bc
	ld   a, [hl]
	cp   $50
	jp   z, L024A7A
	cp   $52
	jp   z, L024A7A
	jp   L024AA1
L024A7A: db $21;X
L024A7B: db $2B;X
L024A7C: db $00;X
L024A7D: db $09;X
L024A7E: db $CB;X
L024A7F: db $46;X
L024A80: db $C2;X
L024A81: db $89;X
L024A82: db $4A;X
L024A83: db $FA;X
L024A84: db $83;X
L024A85: db $DA;X
L024A86: db $C3;X
L024A87: db $8C;X
L024A88: db $4A;X
L024A89: db $FA;X
L024A8A: db $83;X
L024A8B: db $D9;X
L024A8C: db $2F;X
L024A8D: db $3C;X
L024A8E: db $C6;X
L024A8F: db $88;X
L024A90: db $21;X
L024A91: db $05;X
L024A92: db $00;X
L024A93: db $19;X
L024A94: db $77;X
L024A95: db $CD;X
L024A96: db $B1;X
L024A97: db $4A;X
L024A98: db $21;X
L024A99: db $00;X
L024A9A: db $E8;X
L024A9B: db $CD;X
L024A9C: db $13;X
L024A9D: db $35;X
L024A9E: db $C3;X
L024A9F: db $B0;X
L024AA0: db $4A;X
L024AA1:;J
	ld   hl, $0005
	add  hl, de
	ld   [hl], $88
	call L024AB1
	ld   hl, $E800
	call Play_OBJLstS_MoveH_ByXDirR
	ret
L024AB1:;C
	push bc
	ld   hl, $0080
	add  hl, bc
	push hl
	pop  bc
	ld   hl, $0003
	add  hl, de
	ld   a, [bc]
	inc  bc
	ldi  [hl], a
	pop  bc
	ret
L024AC1:;C
	push bc
	ld   hl, $0080
	add  hl, bc
	push hl
	pop  bc
	ld   hl, $0003
	add  hl, de
	ld   a, [bc]
	inc  bc
	ldi  [hl], a
	inc  hl
	ld   a, [bc]
	ld   [hl], a
	pop  bc
	ret
HitAnim_ThrowStart:;I
	ld   a, [wPlayPlThrowActId]
	cp   $01
	jp   nz, L024B37
	ld   hl, $005F
	add  hl, bc
	ld   [hl], $0F
	ld   hl, $0021
	add  hl, bc
	res  7, [hl]
	res  1, [hl]
	ld   a, $90
	call Pl_Unk_SetNewMoveAndAnim_ShakeScreenReset
	ld   a, $02
	ld   [wPlayPlThrowActId], a
L024AF4:;J
	call Task_PassControlFar
	ld   a, [wPlayPlThrowActId]
	cp   $00
	jp   z, L024B37
	cp   $03
	jp   nz, L024AF4
	ld   a, $14
	ld   [$C179], a
	ld   a, $1B
	call HomeCall_Sound_ReqPlayExId
	call OBJLstS_SyncXFlip
	ld   hl, $0021
	add  hl, bc
	set  1, [hl]
	ld   hl, $001B
	add  hl, de
	ld   [hl], $FF
	inc  hl
	ld   [hl], $FF
	call L024AB1
	ld   hl, $F000
	call Play_OBJLstS_MoveH_ByXDirR
	ld   hl, $007C
	add  hl, bc
	ld   [hl], $01
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_GiveKnockbackCornered
	scf
	ret
L024B37: db $AF;X
L024B38: db $C9;X
HitAnim_ThrowRotU:;I
	ld   a, $92
	jp   L024B4D
HitAnim_ThrowRotL:;I
	ld   a, $94
	jp   L024B4D
HitAnim_ThrowRotD:;I
	ld   a, $96
	jp   L024B4D
HitAnim_ThrowRotR:;I
	ld   a, $98
	jp   L024B4D
L024B4D:;J
	call Pl_Unk_SetNewMoveAndAnim_ShakeScreenReset
	call L024AC1
	ld   a, [$C176]
	ld   h, a
	ld   l, $00
	call Play_OBJLstS_MoveH_ByOtherXFlipL
	ld   a, [$C177]
	ld   h, a
	ld   l, $00
	call Play_OBJLstS_MoveV
	ld   hl, $007C
	add  hl, bc
	ld   [hl], $01
	call Play_Pl_GiveKnockbackCornered
	scf
	ret
	
; =============== Play_Pl_SetHitAnim ===============
; Handles the player status and damage-related fields when getting hit.
; This does a lot of setup for Play_Pl_DoHit to do the final adjustments
; and execute the HitAnim code.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
; OUT
; - A: Hit Animation ID that was set, * 2 (HITANIM_*)
; - C flag: If set, we got hit or blocked the attack. The return value in A can be used.
;           If cleared, the hit didn't have any effect.
Play_Pl_SetHitAnim:
	push bc
		push de
		
		;--------------------------------
		;
		; Update the airborne flag on the player status,
		; since it's used later on when validating hit animations.
		; (As some animations are switched when in the air or on the ground)
		;
		Play_Pl_SetHitAnim_SetAirFlag:
			ld   hl, iOBJInfo_Y
			add  hl, de
			ld   a, [hl]		; A = iOBJInfo_Y
			ld   hl, iPlInfo_Flags0
			add  hl, bc			; HL = Ptr to iPlInfo_Flags0
			cp   PL_FLOOR_POS	; Are we on the ground?
			jp   nz, .setAir	; If not, set PF0B_AIR
		.setGround:
			res  PF0B_AIR, [hl]	; Otherwise, reset it
			jp   .end
		.setAir:
			set  PF0B_AIR, [hl]
		.end:
		
		;--------------------------------
		;
		; Start by dividing between projectile hits and physical hits.
		; 
		; There are significant differences between the handling of those, though the code paths later
		; converge back at Play_Pl_SetHitAnim_ChkGuardBypass (but not before setting the PF0B_FARHIT flag)
		; when it comes to applying the damage and hit animation.
		;
		Play_Pl_SetHitAnim_ChkHitType:		
			; The flags checked here were previously set this frame during collision detection by the main task.
			ld   hl, iPlInfo_ColiFlags
			add  hl, bc
			bit  PCF_PROJHIT, [hl]				; Were we hit by a projectile?
			jp   nz, .proj						; If so, jump
			; Both PCF_PUSHED and PCF_HIT must be set for it to count as a physical hit.
			; Checking PCF_HIT isn't enough, because PCF_HIT is also used alongside PCF_PROJREMOTHER
			; when the opponent reflects/removes a projectile.
			bit  PCF_PUSHED, [hl]				; Did we get knockback'd or pushed by the other player?			
			jp   nz, .phys						; If so, jump
			
			; Otherwise, we definitely didn't get hit. Return.
			jp   Play_Pl_SetHitAnim_RetClear
			
		;--------------------------------
		;
		; PROJECTILE HIT
		; [POI] This contains a bunch of checks that don't matter, probably as it was based on .phys,
		;       which had to account for getting called across multiple frames even when it's not needed.
		;       This one though is only called once, for the single frame the projectile hits.
		;
		.proj:
			;
			; Can't get hit when we're invincible.
			; Curiously, of all code in the subroutine for checking collision, the projectile checks
			; are the only ones that check this flag beforehand, making the check here pointless.
			;
			ld   hl, iPlInfo_Flags1
			add  hl, bc							; Seek to iPlInfo_Flags1
			bit  PF1B_INVULN, [hl]				; Can we get hit?
			jp   nz, Play_Pl_SetHitAnim_RetClear	; If not, return
			
			;
			; Throws have more priority than projectiles.
			;
			; If the projectile hit us while being/attempting to get thrown by the opponent, ignore the hit
			; and continue to the physical hit code, where we'll continue to handle the throw.
			;
			ld   a, [wPlayPlThrowActId]
			or   a								; Is a throw in progress (wPlayPlThrowActId != 0)?
			jp   z, .getProjDamage				; If not, jump
			
			;
			; [POI] This check is pointless, as if a throw is in progress PCF_PUSHED is always set
			;       for the duration of the throw until we are actually thrown.
			;
			ld   hl, iPlInfo_ColiFlags
			add  hl, bc							; Seek to iPlInfo_ColiFlags
			bit  PCF_PUSHED, [hl]				; Did we push another player?	
			jp   nz, .phys						; If so, jump (always happens)
			
			jp   Play_Pl_SetHitAnim_RetClear	; We never get here
			
		.getProjDamage:
		
			;
			; Seek to the move damage fields from the opponent's projectile.
			;
			ld   hl, iPlInfo_PlId
			add  hl, bc							; Seek to iPlInfo_PlId
			bit  0, [hl]						; iPlInfo_PlId == PL2? ($01)
			jp   nz, .useProj1P					; If so, use 1P's projectile damage value
		.useProj2P:							
			ld   hl, wOBJInfo_Pl2Projectile+iOBJInfo_Proj_DamageVal		 
			jp   .chkProjDamage
		.useProj1P:
			ld   hl, wOBJInfo_Pl1Projectile+iOBJInfo_Proj_DamageVal		
		.chkProjDamage:
			; 
			; Just like the PF1B_INVULN check, this was checked beforehand in the box check code.
			; This is structured like the code checking iPlInfo_MoveDamageValOther in .phys,
			; but the damage check in there has a real purpose.
			;
			ld   a, [hl]
			or   a								; Is there damage assigned to the projectile?
			jp   z, Play_Pl_SetHitAnim_RetClear	; If not, return
			
			;
			; Retrieve the move damage fields from the projectile.
			;
			ld   d, [hl]	; D = iOBJInfo_Proj_DamageVal
			inc  hl
			ld   e, [hl]	; E = iOBJInfo_Proj_DamageHitAnimId
			inc  hl
			ld   a, [hl]	; A = iOBJInfo_Proj_DamageFlags3
			
			; Set that we were hit by a projectile
			ld   hl, iPlInfo_Flags0
			add  hl, bc							; Seek to iPlInfo_Flags0
			set  PF0B_FARHIT, [hl]
			
			inc  hl								; Seek to iPlInfo_Flags1
			inc  hl								; Seek to iPlInfo_Flags2
			; Projectiles bypass autoguard
			res  PF2B_AUTOGUARDMID, [hl]
			res  PF2B_AUTOGUARDLOW, [hl]
			; Since it should be possible to combo off a projectile hit, restore collision boxes.
			res  PF2B_NOHURTBOX, [hl]
			res  PF2B_NOCOLIBOX, [hl]
			
			; Apply the opponent's iOBJInfo_Proj_DamageFlags3
			inc  hl								; Seek to iPlInfo_Flags3
			ld   [hl], a						; Copy iOBJInfo_Proj_DamageFlags3 there
			
			; There's nothing else to check here, skip to the shared code
			jp   Play_Pl_SetHitAnim_ChkGuardBypass
			
			
		;--------------------------------
		;
		; PHYSICAL HIT ("Player Hit")
		;
		.phys:

			;
			; Make sure we actually got hit, as we can get here just by pushing another player.
			;
			ld   hl, iPlInfo_ColiFlags
			add  hl, bc							
			bit  PCF_HIT, [hl]					; Did we get hit?
			jp   z, Play_Pl_SetHitAnim_RetClear	; If not, return
			
			;
			; Make sure the opponent can damage the player.
			;
			; We're checking this because of what the game does to prevent a move from dealing
			; damage for multiple continuous frames.
			; 
			; To ensure that, the main task at Play_DoUnkChain_ResetDamage blanks the damage field
			; for the opponent if it detects that a physical hit happened the previous frame.
			; Right after that, we're given visibility to those updated damage fields, so the opponent's
			; iPlInfo_MoveDamageVal gets copied to our iPlInfo_MoveDamageValOther.
			;
			; So, if that is empty, return immediately.
			;
			ld   hl, iPlInfo_MoveDamageValOther
			add  hl, bc							; Seek to iPlInfo_MoveDamageValOther
			ld   a, [hl]
			or   a								; iPlInfo_MoveDamageValOther == 0?
			jp   z, Play_Pl_SetHitAnim_RetClear	; If so, return
			
			;
			; Retrieve the move damage fields from the other player.
			;
			ld   d, [hl]				; D = iPlInfo_MoveDamageValOther
			inc  hl
			ld   e, [hl]				; E = iPlInfo_MoveDamageHitAnimIdOther
			inc  hl
			ld   a, [hl]				; A = iPlInfo_MoveDamageFlags3Other
			
			; Set that we weren't hit by a projectile
			ld   hl, iPlInfo_Flags0
			add  hl, bc					; Seek to iPlInfo_Flags0
			res  PF0B_FARHIT, [hl]
			
			inc  hl						; Seek to iPlInfo_Flags1
			inc  hl						; Seek to iPlInfo_Flags2
			
			; Restore collision boxes to allow combo hits.
			res  PF2B_NOHURTBOX, [hl]
			res  PF2B_NOCOLIBOX, [hl]
			
			; Copy the opponent's iPlInfo_MoveDamageFlags3Other to our iPlInfo_Flags3 value
			inc  hl						; Seek to iPlInfo_Flags3
			ld   [hl], a				
			
			ld   a, e		; A = HitAnimId
			
			;
			; Perform extra validation before registering that we got damaged.
			;
			; First determine what type of damage move (set hit animation ID) this was, as set by the move code.
			; The hit animation IDs are grouped in a specific order:
			; - All standard hit/drop animations (including the end of a throw) use IDs < $10
			; - ID $10 is used when starting a throw
			; - IDs > $10 are the rotation frames used for the "next" parts of a throw.
			;         Each character decides how to cycle between them.
			;
			; All of the validation to check if we can be grabbed happens at the start of the throw (HITANIM_THROW_START).
			; If the throw was already started (HitAnimId >= $10) then we're definitely allowed to continue it.
			; (as long as we don't get throw tech, but that's handled elsewhere).
			;
			; The throws are also special since they never cause damage directly (read: as long as HitAnimId >= $10),
			; so when they are confirmed (.setThrowFlags) they just set some flags to force the throw state and jump 
			; directly to the end, skipping the damage evaluator.
			; The actual damage only happens the when the code for the throw sets HitAnimId < $10, which makes
			; it count as a normal hit.
			;
			cp   HITANIM_THROW_START	; HitAnimId == $10?
			jp   z, .chkThrow			; If so, jump
			cp   HITANIM_THROW_START	; HitAnimId >= $10?
			jp   nc, .setThrowFlags		; If so, jump
			; Otherwise, iPlInfo_MoveDamageHitAnimIdOther < $10, meaning it's a generic hit.
			jp   .chkHit
			
			;################
			;
			; THROWS
			;
		.chkThrow:
			;
			; Return immediately if the other player didn't start yet a throw.
			; Note this works in conjunction with the other player currently "waiting" in Play_Pl_ChkThrowInput.tryStart
			; or in MoveInputS_TryStartCommandThrow when starting a throw, which is when wPlayPlThrowActId got set 
			; to PLAY_THROWACT_START.
			;
			ld   a, [wPlayPlThrowActId]
			cp   PLAY_THROWACT_START				; wPlayPlThrowActId == $01?
			jp   nz, Play_Pl_SetHitAnim_RetClear	; If not, return
			
			;
			; If we got thrown by a special move (command throw), always allow the throw to start.
			; The air/ground and invulnerability checks (PF1B_INVULN) also get ignored.
			;
			ld   hl, iPlInfo_Flags0Other
			add  hl, bc					; Seek to iPlInfo_Flags0Other
			bit  PF0B_SPECMOVE, [hl]	; Is PF0B_SPECMOVE set?
			jp   nz, .setThrowFlags		; If so, jump
			
			;
			; Throws can either work for opponents in the air or on the ground.
			; Verify that we can be thrown depending on what was set as "opponent throw mode" (wPlayPlThrowOpMode).
			; 
			ld   a, [wPlayPlThrowOpMode]
			cp   PLAY_THROWOP_GROUND	; Is it against grounded players?
			jp   z, .chkThrowForGround	; If so, jump
			cp   PLAY_THROWOP_AIR		; Is it against airborne players?
			jr   z, .chkThrowForAir		; If so, jump
			
			; [TCRF] Unreachable broken code for a type that's only used for command throws. 
			; [BUG]  Broken indexing. "add  hl, bc" is missing, so it reads garbage value at address $0021.
			;        This is $FF, causing the check to always return.			
		.chkThrow_Unused_ForBoth:
			ld   hl, iPlInfo_Flags1
			bit  PF1B_INVULN, [hl]		; Are we invulnerable against throws?
			jp   nz, Play_Pl_SetHitAnim_RetClear	; If so, return
			jp   .setThrowFlags			; Otherwise, jump
			
		.chkThrowForGround:
		
			;
			; We must be on the ground for the throw to start.
			;
			ld   hl, iPlInfo_Flags0
			add  hl, bc					
			bit  PF0B_AIR, [hl]						; Are we in the air?
			jp   nz, Play_Pl_SetHitAnim_RetClear	; If so, return
			
			;
			; Standard invulnerability check.
			;
			inc  hl									; Seek to iPlInfo_Flags1
			bit  PF1B_INVULN, [hl]					; Are we invulnerable?
			jp   nz, Play_Pl_SetHitAnim_RetClear	; If so, return
			
			; OK
			jp   .setThrowFlags
			
		.chkThrowForAir:
		
			;
			; We must be in the air for the throw to start.
			;
			ld   hl, iPlInfo_Flags0
			add  hl, bc							; Seek to iPlInfo_Flags0
			bit  PF0B_AIR, [hl]					; Are we in the air?
			jp   z, Play_Pl_SetHitAnim_RetClear	; If not, return
			
			;
			; [POI] The CPU can't be thrown in the air.
			;
			bit  PF0B_CPU, [hl]					; Are we a CPU player?
			jp   nz, Play_Pl_SetHitAnim_RetClear	; If so, return
			
		.setThrowFlags:
			;
			; When the throw is confirmed, we can't block the hit at all
			; to reduce the damage.
			;
			ld   hl, iPlInfo_Flags1
			add  hl, bc				; Seek to iPlInfo_Flags1
			res  PF1B_GUARD, [hl]	; Clear main guard flag
			inc  hl					; Seek to iPlInfo_Flags2
			res  PF2B_AUTOGUARDDONE, [hl] ; Clear autoguard flags
			res  PF2B_AUTOGUARDMID, [hl]
			res  PF2B_AUTOGUARDLOW, [hl]
			
			; Throws don't cause damage directly.
			; Just set the updated hit animation ID from E and return.
			jp   Play_Pl_SetHitAnim_SetHitAnimId
			
			;################
			;
			; HIT
			;
		.chkHit:	
			;
			; If we're invulnerable we can't get damaged.
			; This also clears out the damage flashing effect, in case it was enabled when
			; the opponent's iPlInfo_MoveDamageFlags3Other was copied over to our iPlInfo_Flags3.
			;
			ld   hl, iPlInfo_Flags1
			add  hl, bc					; Seek to iPlInfo_Flags1
			bit  PF1B_INVULN, [hl]		; Are we fully invulnerable?
			jp   z, .chkAutoguard		; If not, jump
			
			inc  hl			; Seek to iPlInfo_Flags2
			inc  hl			; Seek to iPlInfo_Flags3
			; Stop flashing 
			res  PF3B_FLASH_B_SLOW, [hl]
			res  PF3B_FLASH_B_FAST, [hl]
			; Exit hit state
			jp   Play_Pl_SetHitAnim_RetClear
			;--
			
		.chkAutoguard:
			;
			; By default, it's impossible to guard while performing a special move,
			; though some special moves may use PF1B_GUARD to reduce the damage received.
			;
			; If one of the autoguard flags are set, however, special moves can be
			; set to either block lows or highs automatically.
			; Unlike with normal blocks, blocking the hit prevents *any* damage from 
			; being received (read: we return).
			;
			ld   hl, iPlInfo_Flags2
			add  hl, bc						; Seek to iPlInfo_Flags2
			bit  PF2B_AUTOGUARDMID, [hl]	; Guarding mid?
			jp   nz, .onAutoguardMid		; If so, jump
			bit  PF2B_AUTOGUARDLOW, [hl]	; Guarding low?
			jp   nz, .onAutoguardLow		; If so, jump
			
			; Otherwise, reset the autoguard indicator
			res  PF2B_AUTOGUARDDONE, [hl]			; Clear result flag
			jp   Play_Pl_SetHitAnim_ChkGuardBypass	; Skip to the common block
			
		.onAutoguardMid:
			; If the attack hits low, we got hit
			ld   hl, iPlInfo_Flags3
			add  hl, bc									
			bit  PF3B_HITLOW, [hl]
			jp   nz, Play_Pl_SetHitAnim_BlockBypass
			
			; When playing as KYO, autoguarding overheads only works against normals.
			; [BUG?] Suspicious. Was this meant to check if the opponent is KYO (iPlInfo_CharIdOther)?
			;        It makes more sense if KYO's overheads autoguards were unblockable.
			ld   hl, iPlInfo_CharId
			add  hl, bc				
			ld   a, [hl]
			cp   CHAR_ID_KYO		; Are we KYO?
			jp   z, .chkSpecial		; If so, jump
			
			jp   .autoguardOk		; autoguard ok!
			
		.onAutoguardLow:
			; If the attack is an overhead, we got hit
			ld   hl, iPlInfo_Flags3
			add  hl, bc		 		
			bit  PF3B_OVERHEAD, [hl]
			jp   nz, Play_Pl_SetHitAnim_BlockBypass
			
		.chkSpecial:
			; Autoguarding lows only works against normals in general.
			ld   hl, iPlInfo_Flags0Other
			add  hl, bc
			ld   a, [hl]
			and  a, PF0_SUPERMOVE|PF0_SPECMOVE			; Did we get hit by a special move?
			jp   nz, Play_Pl_SetHitAnim_BlockBypass		; If so, jump
		.autoguardOk:
			
			ld   hl, iPlInfo_Flags2
			add  hl, bc				; Seek to iPlInfo_Flags2
			
			; Flag that we guarded it this way
			set  PF2B_AUTOGUARDDONE, [hl]
			inc  hl					; Seek to iPlInfo_Flags3
			; Stop flashing
			res  PF3B_FLASH_B_SLOW, [hl]
			res  PF3B_FLASH_B_FAST, [hl]
			jp   Play_Pl_SetHitAnim_RetClear
			;###
			
		;--------------------------------
		;
		; SHARED - Block Check.
		;
		Play_Pl_SetHitAnim_ChkGuardBypass:
			;
			; If we're blocking, determine if the attack was properly blocked.
			; If not, the guard is removed and we take full damage.
			; ie: blocking overheads while crouching
			;
			; Moves can be set to either require blocking low (PF3B_HITLOW) or to be overheads (PF3B_OVERHEAD).
			; Most moves don't set either flag, meaning they can be blocked in both ways.
			; The few unblockables have both PF3B_OVERHEAD and PF3B_HITLOW set at the same time.
			;
			ld   hl, iPlInfo_Flags1
			add  hl, bc									
			bit  PF1B_GUARD, [hl]					; Were we blocking the attack?
			jp   z, Play_Pl_SetHitAnim_ApplyDamage	; If not, skip ahead
			bit  PF1B_CROUCH, [hl]					; Did we block low?
			jp   z, .onBlockMid						; If not, jump
		.onBlockLow:
			ld   hl, iPlInfo_Flags3
			add  hl, bc								; Seek to iPlInfo_Flags3
			bit  PF3B_OVERHEAD, [hl]				; Is this an overhead?
			jp   nz, Play_Pl_SetHitAnim_BlockBypass	; If so, we got hit
			jp   Play_Pl_SetHitAnim_Blocked			; Otherwise, we blocked it
		.onBlockMid:
			ld   hl, iPlInfo_Flags3
			add  hl, bc								; Seek to iPlInfo_Flags3
			bit  PF3B_HITLOW, [hl]					; Does the attack require blocking low?
			jp   nz, Play_Pl_SetHitAnim_BlockBypass	; If so, we got hit
			jp   Play_Pl_SetHitAnim_Blocked			; Otherwise, we blocked it
			
		Play_Pl_SetHitAnim_Blocked:
			; Since we blocked the attack, remove the hit effect
			; so we can continue blocking.
			ld   e, $00
			jp   Play_Pl_SetHitAnim_ApplyDamage
			
		Play_Pl_SetHitAnim_BlockBypass:
			; We didn't guard the attack correctly.
			; This counts as a standard hit.
			
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			; Stop blocking the attack
			res  PF1B_GUARD, [hl]	
			inc  hl
			res  PF2B_AUTOGUARDDONE, [hl]
			res  PF2B_AUTOGUARDMID, [hl]
			res  PF2B_AUTOGUARDLOW, [hl]
			
		;--------------------------------
		;
		; SHARED - Apply Damage
		;
		Play_Pl_SetHitAnim_ApplyDamage:
			
			; Play_Pl_ApplyDamageToStats recalculates the values in DE, so save/restore it
			push de
				call Play_Pl_ApplyDamageToStats
			pop  de
			
		;--------------------------------
		;
		; SHARED - Set Hit Animation
		;
		Play_Pl_SetHitAnim_SetHitAnim:
			;
			; Second pass to validate the animation to play when getting hit,
			; as it may get replaced with something else depending on the player status flags.
			; After this last series of checks in made, save it to iPlInfo_HitAnimId.
			;
			
			ld   a, e						; A = HitAnimId
			
			; These animation IDs can always be used
			cp   HITANIM_HIT_SPEC_09				; E == $09?
			jp   z, Play_Pl_SetHitAnim_SetHitAnimId	; If so, jump
			cp   HITANIM_HIT_SPEC_0A				; ...
			jp   z, Play_Pl_SetHitAnim_SetHitAnimId
			cp   HITANIM_HIT_SPEC_0B
			jp   z, Play_Pl_SetHitAnim_SetHitAnimId
			cp   HITANIM_DROP_MD
			jp   z, Play_Pl_SetHitAnim_SetHitAnimId
			cp   HITANIM_DROP_SPEC_AIR_0E
			jp   z, Play_Pl_SetHitAnim_SetHitAnimId
		
		.chkDead:
			;
			; Getting KO'd restricts the number of allowed hit animations, as the player
			; has to visibily drop to the ground, something not all HitAnims do.
			;
			ld   hl, iPlInfo_Health
			add  hl, bc
			ld   a, [hl]
			or   a						; Do we have any health left?
			jp   nz, .notDead			; If so, jump
			
			ld   hl, iPlInfo_Flags1
			add  hl, bc					; Seek to our iPlInfo_Flags1
			res  PF1B_GUARD, [hl]		; Disable blocking
			
			; E = HitAnimId (Opponent)
			ld   hl, iPlInfo_MoveDamageHitAnimIdOther
			add  hl, bc					
			ld   a, [hl]				
			ld   e, a
			
			; There are different allowed HitAnims depending on whether we got
			; killed by a hit or a throw.
			ld   a, [wPlayPlThrowActId]
			or   a						; Did we get thrown?
			jp   nz, .deadThrown		; If so, jump
		.deadHit:
			; Getting KO'd by a normal always sets HITANIM_DROP_MD.
			; For specials there's a whitelist.
			ld   hl, iPlInfo_Flags0Other
			add  hl, bc					; Seek to opponent's status
			bit  PF0B_SPECMOVE, [hl]		; Did we get killed by a special move?
			jp   nz, .deadSpecHit		; If so, jump
			jp   .useStdDrop				; Otherwise, use HITANIM_DROP_MD
		.deadThrown:
			; There are three allowed animations when getting KO's by a throw.
			; Otherwise, default to HITANIM_DROP_MD.
			ld   a, e
			cp   HITANIM_DROP_SPEC_0C		; HitAnimId == $0C?
			jp   z, .useDrop0C				; If so, jump
			cp   HITANIM_DROP_SPEC_0F		; ...
			jp   z, Play_Pl_SetHitAnim_SetHitAnimId
			;--
			; [TCRF?] Unreachable code?
			cp   a, HITANIM_DROP_SPEC_AIR_0E
			jp   z, Play_Pl_SetHitAnim_SetHitAnimId
			jp   .useStdDrop
			;--
		.deadSpecHit:
			; Whitelist of allowed hit animations when getting KO'd by a hit.
			; Otherwise, default to HITANIM_DROP_MD.
			ld   a, e
			cp   HITANIM_HIT_SPEC_09
			jp   z, Play_Pl_SetHitAnim_SetHitAnimId
			cp   HITANIM_HIT_SPEC_0A
			jp   z, Play_Pl_SetHitAnim_SetHitAnimId
			cp   HITANIM_HIT_SPEC_0B
			jp   z, Play_Pl_SetHitAnim_SetHitAnimId
			cp   HITANIM_DROP_SPEC_0C
			jp   z, .useDrop0C
			cp   HITANIM_DROP_SPEC_0F
			jp   z, Play_Pl_SetHitAnim_SetHitAnimId
			cp   HITANIM_DROP_SPEC_AIR_0E
			jp   z, Play_Pl_SetHitAnim_SetHitAnimId
			jp   .useStdDrop
			
		.notDead:
			ld   a, e
			
			; If we blocked the hit, determine if guard broke as that uses its own anims.
			; Note that HITANIM_BLOCKED got set previously by the subroutine, overriding
			; whatever the attack set when blocking it successfully.
			cp   HITANIM_BLOCKED		; Did we block the hit?
			jp   nz, .noBlock			; If not, jump
			call Play_Pl_DoGuardBreak	; Did our guard break?
			jp   z, .useGuardBreak		; If so, jump
			jp   Play_Pl_SetHitAnim_SetHitAnimId	; Otherwise, confirm HITANIM_BLOCKED
			
		.noBlock:
			call Play_Pl_IsDizzy		; Did we get dizzy? 
			jp   z, .noDizzy			; If not, jump
		.dizzy:
			; Handle the animation whitelist when getting hit "right before getting" dizzy.
			; The practical result is that moves that normally would cause minor pushback
			; will cause the player to drop to the ground (by reaching .useStdDrop).
			ld   a, e
			cp   HITANIM_HIT_SPEC_09
			jp   z, Play_Pl_SetHitAnim_SetHitAnimId
			cp   HITANIM_HIT_SPEC_0A
			jp   z, Play_Pl_SetHitAnim_SetHitAnimId
			cp   HITANIM_HIT_SPEC_0B
			jp   z, Play_Pl_SetHitAnim_SetHitAnimId
			cp   HITANIM_DROP_SPEC_0C
			jp   z, .useDrop0C
			cp   HITANIM_DROP_SPEC_0F
			jp   z, Play_Pl_SetHitAnim_SetHitAnimId
			cp   HITANIM_DROP_SPEC_AIR_0E
			jp   z, Play_Pl_SetHitAnim_SetHitAnimId
			jp   .useStdDrop
		.noDizzy:
		
			; Air and ground use different validations
			ld   a, e
			ld   hl, iPlInfo_Flags0
			add  hl, bc
			bit  PF0B_AIR, [hl]		; Are we in the air?
			jp   z, .noAir			; If not, jump
			
			;##
		.air:
			; HITANIM_DROP_SPEC_AIR_0E is always allowed when getting hit in the air
			; (alongside HITANIM_DROP_SPEC_0C and HITANIM_DROP_SPEC_0F...)
			cp   HITANIM_DROP_SPEC_AIR_0E
			jp   z, Play_Pl_SetHitAnim_SetHitAnimId
			
			;
			; When getting hit by a normal in the air, the player recovers before touching the ground.
			; Otherwise, it's an hard drop.
			;
			bit  PF0B_FARHIT, [hl]	; Did we get hit by a projectile?
			jp   nz, .airSpec		; If so, jump
			ld   hl, iPlInfo_Flags0Other
			add  hl, bc				
			bit  PF0B_SPECMOVE, [hl]	; Did we get hit by a special move?
			jp   nz, .airSpec		; If so, jump
		.airNorm:
			;--
			; [POI] This is the same between .noAirNoSpec and .noAirSpec.
			;       It could have been moved before the PF0B_FARHIT check.
			cp   HITANIM_DROP_SPEC_0C
			jp   z, .useDrop0C
			cp   HITANIM_DROP_SPEC_0F
			jp   z, Play_Pl_SetHitAnim_SetHitAnimId
			;--
			jp   .useHitAirRec		; Use HITANIM_DROP_SM_REC
		.airSpec:
			;--
			; [POI] See above
			cp   HITANIM_DROP_SPEC_0C
			jp   z, .useDrop0C
			cp   HITANIM_DROP_SPEC_0F
			jp   z, Play_Pl_SetHitAnim_SetHitAnimId
			;--
			jp   .useStdDrop		; Use HITANIM_DROP_MD
			;##
			
		.noAir:
			;
			; This is the only part that doesn't define default values.
			; When getting hit on the ground without getting dizzy or blocking,
			; every HitAnim value is valid as long as it doesn't get replaced
			; by the crouching checks.
			;
			bit  PF0B_FARHIT, [hl]	; Did we get hit by a projectile?
			jp   nz, .noAirSpec		; If so, jump
			ld   hl, iPlInfo_Flags0Other
			add  hl, bc				
			bit  PF0B_SPECMOVE, [hl]	; Did we get hit by a special move?
			jp   nz, .noAirSpec		; If so, jump
		.noAirNorm:
			; HITANIM_DROP_SM is always allowed
			cp   HITANIM_DROP_SM
			jp   z, Play_Pl_SetHitAnim_SetHitAnimId
			
			; If we got hit by a normal while crouching, force use HITANIM_HIT_LOW
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			bit  PF1B_CROUCH, [hl]		; Are we crouching?
			jp   nz, .useHitLow			; If so, jump
			
			; Otherwise, use the existing value
			;
			; Of course, this assumes that normals will never set anims
			; they aren't intended to use, like HITANIM_DROP_SPEC_0C.
			jp   Play_Pl_SetHitAnim_SetHitAnimId
		.noAirSpec:
			; No special behaviour when hit by a special move, other
			; than the standard special case for HITANIM_DROP_SPEC_0C
			; that's also everywhere else.
			cp   HITANIM_DROP_SPEC_0C
			jp   z, .useDrop0C
			jp   Play_Pl_SetHitAnim_SetHitAnimId
			;##
			
		.useDrop0C:
			; If we're not in the air, replace HITANIM_DROP_SPEC_0C with its ground version,
			; which is a shortened version without the downwards movement.
			ld   hl, iPlInfo_Flags0
			add  hl, bc
			bit  PF0B_AIR, [hl]						; Are we in the air?
			jp   nz, Play_Pl_SetHitAnim_SetHitAnimId			; If so, confirm the air ver
			ld   e, HITANIM_DROP_SPEC_0C_GROUND		; Otherwise, replace it with the ground ver
			jp   Play_Pl_SetHitAnim_SetHitAnimId
			
		.useGuardBreak:
			; Like .useDrop0C, but for the guard break.
			ld   hl, iPlInfo_Flags0
			add  hl, bc						
			bit  PF0B_AIR, [hl]				; Are we in the air?
			jp   z, .useGuardBreakGround	; If not, jump
		.useGuardBreakAir:
			ld   e, HITANIM_GUARDBREAK_AIR
			jp   Play_Pl_SetHitAnim_SetHitAnimId
		.useGuardBreakGround:
			ld   e, HITANIM_GUARDBREAK_GROUND
			jp   Play_Pl_SetHitAnim_SetHitAnimId
			
		;--
		; [TCRF] Unreferenced code to force the standard hit animations
		.unused_useHit03:
			ld   e, HITANIM_HIT0_MID
			jp   Play_Pl_SetHitAnim_SetHitAnimId
		.unused_useHit04:
			ld   e, HITANIM_HIT1_MID
			jp   Play_Pl_SetHitAnim_SetHitAnimId
		;--
		
		.useStdDrop:
			ld   e, HITANIM_DROP_MD
			jp   Play_Pl_SetHitAnim_SetHitAnimId
		.useHitAirRec:
			ld   e, HITANIM_DROP_SM_REC
			jp   Play_Pl_SetHitAnim_SetHitAnimId
		.useHitLow:
			ld   e, HITANIM_HIT_LOW
			jp   Play_Pl_SetHitAnim_SetHitAnimId
			
		Play_Pl_SetHitAnim_SetHitAnimId:
			; Save the updated hit animation ID.
			; iPlInfo_HitAnimId = E
			ld   a, e			; A = E
			ld   hl, iPlInfo_HitAnimId
			add  hl, bc			; Seek to iPlInfo_HitAnimId
			ld   [hl], a		; Write it over
			
			; Return the same value to A, except multiplied by 2.
			; A = E * 2
			sla  a
			scf		; C flag set
		pop  de
	pop  bc
	ret
		Play_Pl_SetHitAnim_RetClear:
			or   a	; A = 0, C flag clear
		pop  de
	pop  bc
	ret
	
; =============== Play_Pl_ApplyDamageToStats ===============
; Applies the damage values and its related effects to the specified player.
; This is for specifically applying the stats, not the move, so:
; - Dizzy / guard break stats
; - POW meter
; - Special effects
; - Health
; IN
; - BC: Ptr to wPlInfo
Play_Pl_ApplyDamageToStats:

	;
	; D = Base damage value.
	;
	; Pick the correct damage field:
	; - If we got hit by a projectile, use the damage from the opponent's projectile.
	; - Otherwise, use the damage from the opponent we were given visibility to.
	;

	ld   hl, iPlInfo_Flags0
	add  hl, bc					; Seek to iPlInfo_Flags0
	bit  PF0B_FARHIT, [hl]		; Did we get hit by a projectile?
	jr   nz, .chkDamageProj		; If so, jump
	
.getDamagePl:
	; We received a physical hit. 
	; Use the opponent damage we were given visibility to at iPlInfo_MoveDamageValOther.
	ld   hl, iPlInfo_MoveDamageValOther
	add  hl, bc				; Seek to iPlInfo_MoveDamageValOther
	ld   d, [hl]			; D = iPlInfo_MoveDamageValOther
	jr   .applyDamage
	
.chkDamageProj:
	; We got hit by a projectile.
	; Determine which wOBJInfo_Pl*Projectile struct to use, and use iOBJInfo_Proj_DamageVal from there.
	ld   hl, iPlInfo_PlId
	add  hl, bc					; Seek to iPlInfo_PlId
	bit  0, [hl]				; wPlInfo_Pl == 2P?
	jp   nz, .use1P				; If so, 1P is the opponent. Use 1P's projectile's damage
.use2P:							; Otherwise, use 2P's one
	ld   hl, wOBJInfo_Pl2Projectile+iOBJInfo_Proj_DamageVal		 
	jp   .getDamageProj
.use1P:
	ld   hl, wOBJInfo_Pl1Projectile+iOBJInfo_Proj_DamageVal		
.getDamageProj:
	ld   d, [hl]				; D = iOBJInfo_Proj_DamageVal
	;--
	
.applyDamage:

	; Don't do this when the time runs out
	ld   a, [wRoundTime]
	or   a
	jp   z, .ret
	
	; Apply a penalty to the appropriate stun timer, which is directly proportional to the damage received
	call Play_Pl_DecStunTimer
	
	; Increment POW meter by 3 lines
	call Play_Pl_IncPowOnHit
	
	; Check for any special effects on contact
	; The only one in this game is for Chizuru's super
	call Play_Pl_ChkSetHitEffect_NoSpecial
	;--
	
	; Finally, decrement the health.
	;
	; There is damage scaling done here:
	; Health $30-MAX -> Full damage
	; Health $18-$2F -> 3/4 damage
	; Health $00-$17 -> 1/2 damage
	;
	; Modify the damage value in D if we're doing the scaling.
	;
	ld   hl, iPlInfo_Health
	add  hl, bc
	ld   a, [hl]
	cp   $30			; Health >= $30?
	jp   nc, .chkBlock	; If so, jump
	cp   $18			; Health >= $18?
	jp   nc, .hLow	; If so, jump
	; Otherwise, health is < $18 (critical)
.hCritical:
	; 1/2
	srl  d		; D = D / 2
	jp   .chkBlock
.hLow:
	; 3/4
	ld   a, d
	srl  a		; A = Damage / 4
	srl  a
	srl  d		; D = Damage / 2
	add  a, d	; A += D
	ld   d, a
.chkBlock:

	;
	; If we blocked the attack, determine by how much damage should be reduced.
	;
	
	; Not applicable if we didn't block it
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	bit  PF1B_GUARD, [hl]	; Did we block the attack?
	jp   z, .chkPow			; If not, skip
	
	; Blocking a projectile, special or super move divides the damage by 8.
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	bit  PF0B_FARHIT, [hl]	; Were we hit by a projectile?
	jr   nz, .damageDiv8	; If so, jump
	ld   hl, iPlInfo_Flags0Other
	add  hl, bc
	bit  PF0B_SPECMOVE, [hl]	; Were we hit by a special or super move?
	jp   nz, .damageDiv8	; If so, jump
	
	; Otherwise, we got hit by a normal.
	; Blocking a normal doesn't deal damage, so return.
	jp   .ret
	
.damageDiv8:
	srl  d	; D = D / 8
	srl  d
	srl  d
	
.chkPow:
	;
	; Moves deal 1/8th more damage at Max Power.
	;
	ld   hl, iPlInfo_PowOther
	add  hl, bc			; Seek to opponent POW meter
	ld   a, [hl]
	cp   PLAY_POW_MAX	; iPlInfo_PowOther == $28?
	jp   nz, .minCap	; If not, skip
	ld   a, d
	srl  a				; A = Damage / 8
	srl  a
	srl  a
	add  a, d			; A += Damage
	ld   d, a			; Damage = A
	
.minCap:
	;
	; If we got here, the minimum amount of damage received must be 1.
	;
	ld   a, d
	or   a				; Damage != 0?
	jr   nz, .subHealth	; If so, skip
	ld   d, $01			; Otherwise, Damage = 1
.subHealth:

	;
	; Finally, subtract the resulting damage to the health value.
	; If we underflow it, force it back to 0.
	;
	ld   hl, iPlInfo_Health
	add  hl, bc			; Seek to health
	ld   a, [hl]		; A = Health
	sub  a, d			; Health -= Damage
	jp   nc, .setHealth	; Health >= 0? If so, skip
	xor  a				; Otherwise, force it back in range
.setHealth:
	ld   [hl], a		; Save the health.
	
	;
	; If we just died, run the game at half-speed for 10 frames.
	;
	or   a					; Health != 0?
	jp   nz, .ret			; If so, return
	ld   a, $0A				; For 10 frames...
	ld   [wPlaySlowdownTimer], a
	ld   a, $01				; Run gameplay every other frame
	ld   [wPlaySlowdownSpeed], a
.ret:
	ret
	
; =============== Play_Pl_ChkSetHitEffect_NoSpecial ===============
; Applies the "No Special Move" effect to the player, if applicable.
; If it triggers, it prevents
; IN
; - BC: Ptr to wPlInfo
Play_Pl_ChkSetHitEffect_NoSpecial:

	;
	; This effect triggers only when getting hit by one of Chizuru's/Kagura super moves.
	; These are completely hardcoded checks, which makes you think how they handled it elsewhere. :^)
	;

	; If we blocked the hit, return
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	bit  PF1B_GUARD, [hl]
	ret  nz
	
.chkChar:
	; The opponent must be Chizuru
	ld   hl, iPlInfo_CharIdOther
	add  hl, bc
	ld   a, [hl]			; A = Character ID of opponent
	cp   CHAR_ID_CHIZURU*2	; Playing as normal Chizuru?
	jp   z, .chkMove		; If so, jump
	cp   CHAR_ID_KAGURA*2	; Playing as boss Chizuru?
	ret  nz					; If not, return
	
.chkMove:
	; Must be hit by a specific super (either variant)
	ld   hl, iPlInfo_MoveIdOther
	add  hl, bc
	ld   a, [hl]			; A = Opponent Move ID
	cp   MOVE_CHIZURU_SAN_RAI_FUI_JIN_S	; Were we hit by the super?
	jp   z, .setEffect		; If so, jump
	cp   MOVE_CHIZURU_SAN_RAI_FUI_JIN_D	; Were we hit by its desperation variant?
	ret  nz					; If not, return
	
.setEffect:
	; If we got here, apply the effect.
	; The player won't be able to use special moves for $FF frames.
	ld   hl, iPlInfo_NoSpecialTimer
	add  hl, bc
	ld   [hl], $FF
	ret
	
; =============== Play_Pl_IncPowOnHit ===============
; Increments the POW Meter, meant to be called when the player gets hit.
; IN
; - BC: Ptr to wPlInfo
; - D: Base damage received
Play_Pl_IncPowOnHit:
	push de
	
		; Don't receive POW meter when the attack deals no damage.
		ld   a, d
		or   a				; Was an initial penalty set?
		jp   z, .ret		; If not, return
		
		; Can't increment it if we're already at MAX Power
		ld   hl, iPlInfo_Pow
		add  hl, bc			; Seek to iPlInfo_Pow
		ld   a, PLAY_POW_MAX
		cp   a, [hl]		; iPlInfo_Pow == $28?
		jp   z, .ret		; If so, return
		
		;--
		
		; Increment the POW Meter by 3.
		ld   a, $03
		add  a, [hl]		; A = iPlInfo_Pow + 3
		
		; If we filled the meter just now, we got into MAX Power mode.
		cp   PLAY_POW_MAX	; iPlInfo_Pow >= $28?
		jp   nc, .setMax	; If so, jump
		
		; Otherwise, just save back the updated value
		jp   .savePow
		
	.setMax:
		; Cap the meter at $28
		ld   a, PLAY_POW_MAX
		; Make the MAX Power meter decrease slowly on its own
		ld   hl, iPlInfo_MaxPowDecSpeed
		add  hl, bc				; Seek to dec speed mask
		ld   [hl], $0F			; Decrement every $10 frames
		
	.savePow:
		ld   hl, iPlInfo_Pow
		add  hl, bc				; Seek to iPlInfo_Pow
		ld   [hl], a			; Save the value back
	.ret:
	pop  de
	ret
	
; =============== Play_Pl_DecStunTimer ===============
; Updates the correct stun timer as a result of getting hit.
;
; There are two stun timers, which cause the specified action when they underflow:
; - iPlInfo_DizzyProg
; - iPlInfo_GuardBreakProg
;
; See also: Play_DoUnkChain_IncDizzyTimer
;
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
; - D: Base damage received.
;      This will get processed, then subtracted as "penalty" to a stun timer.
Play_Pl_DecStunTimer:
	push de
	
		; A = Base damage
		ld   a, d
		
		;
		; First, check if we're in a state that allows blocking attacks.
		; If the player is blocking, it must have the guard flag set (PF1B_GUARD).
		;
		ld   hl, iPlInfo_Flags1
		add  hl, bc						; Seek to iPlInfo_Flags1
		bit  PF1B_GUARD, [hl]	; Is the flag set?
		jp   nz, .chkGuard				; If so, jump
		
	.noGuard:
		;
		; We didn't block the attack, so the damage influences the dizzy timer.
		;
		; Perform various checks which influence the initial value
		; before iPlInfo_DizzyProg gets subtracted by it.
		;
		
		;
		; Halve the penalty with hits received after the first one in a combo string.
		;
		bit  PF1B_COMBORECV, [hl]	; Were we hit at least once in the combo string?
		jp   z, .noGuard_chkOther	; If not, jump
		srl  a						; Otherwise, Penalty /= 2
	.noGuard_chkOther:
	
		;
		; Modify the penalty based on the current status of the other player.
		; We can read that to determine what kind of move hit us.
		;
	
		;
		; Getting hit by a super move doesn't add any penalty (return)
		;
		ld   hl, iPlInfo_Flags0Other
		add  hl, bc
		bit  PF0B_SUPERMOVE, [hl]	; Were we hit by a super?
		jp   nz, .ret				; If so, return
		
		;
		; Getting hit by special moves adds one extra point of penalty.
		;
		
		bit  PF0B_SPECMOVE, [hl]		; Were we hit by a special move?
		jp   nz, .noGuard_add1		; If so, jump
		; Projectiles require their own check since they can hit the opponent
		; independently from the player's action.
		; [POI] This check only works properly because it has the same penalty as special moves
		;       -- if the penalties were different and we were hit by a projectile while the opponent
		;       was in the middle of an unrelated special move, the PF0B_SPECMOVE check would jump.
		ld   hl, iPlInfo_Flags0
		add  hl, bc
		bit  PF0B_FARHIT, [hl]	; Were we hit by a projectile? (special move)
		jp   nz, .noGuard_add1	; If so, jump
		
		;
		; Getting hit by normals quadruples the penalty.
		;
		sla  a
		sla  a
		jp   .addDizzyPenalty
	.noGuard_add1:
		inc  a
		
		;
		; Subtract the processed penalty from the timer,
		; If it underflows, the timer is reset and the dizzy flag is set.
		; This causes the next hit (in this case, the current one) to knock down,
		; with the player getting dizzy when getting up.
		;
	.addDizzyPenalty:
		ld   e, a					; E = Penalty
		ld   hl, iPlInfo_DizzyProg
		add  hl, bc
		ld   a, [hl]				; A = iPlInfo_DizzyProg
		sub  a, e					; A -= Penalty
		jp   nc, .saveDizzyPenalty	; Did we underflow? If not, skip
		; Otherwise...
		xor  a						; Force it back to 0
		push hl						; Set the dizzy marker
			ld   hl, iPlInfo_Dizzy
			add  hl, bc
			ld   [hl], $01
		pop  hl
	.saveDizzyPenalty:
		ld   [hl], a
		jp   .ret
		
	.chkGuard:
		ld   a, d	; Not necessary
		
		;
		; We got here by having PF1B_GUARD set.
		;
		; However, some special moves set that flag as well to reduce the damage 
		; received when getting hit out of them.
		;
		; The player isn't explicitly blocking in that case, so if we're in the middle
		; of a special or super move, return immediately to leave the guard break timer unchanged.
		;
		ld   hl, iPlInfo_Flags0
		add  hl, bc
		bit  PF0B_SPECMOVE, [hl]
		jp   nz, .ret
		bit  PF0B_SUPERMOVE, [hl]
		jp   nz, .ret
		
	.guard:
		;
		; We blocked the attack, so the damage influences the guard break timer.
		;
		; Perform various checks which influence the base damage value
		; before iPlInfo_GuardBreakProg gets subtracted by it.
		;
		
		;
		; Halve the penalty if needed, like with dizzies.
		;
		inc  hl						; Seek to iPlInfo_Flags1
		bit  PF1B_COMBORECV, [hl]	; Were we hit at least once in the combo string?
		jp   z, .guard_chkOther		; If not, jump
		srl  a						; Otherwise, Penalty /= 2
	.guard_chkOther:
	
		;
		; Blocking a special or super move essentially halves the penalty.
		; The result is also incremented by one, likely to make sure the penalty doesn't become 0.
		;
		ld   hl, iPlInfo_Flags0Other
		add  hl, bc
		bit  PF0B_SUPERMOVE, [hl]	
		jp   nz, .guard_half
		bit  PF0B_SPECMOVE, [hl]
		jp   nz, .guard_half
		
		;
		; The same happens if we got hit by a projectile
		;
		ld   hl, iPlInfo_Flags0
		add  hl, bc
		bit  PF0B_FARHIT, [hl]
		jp   nz, .guard_half
		
		;
		; Otherwise, Penalty = Penalty / 4
		;
		sla  a
		sla  a
		jp   .addGuardPenalty
		
	.guard_half:
		srl  a		; Penalty = (Penalty / 2) + 1
		inc  a		
		
		;
		; Subtract the processed penalty from the timer.
		; When this becomes 0, guard breaks, so only prevent it from underflowing here.
		;
	.addGuardPenalty:
		ld   e, a					; E = A
		ld   hl, iPlInfo_GuardBreakProg
		add  hl, bc
		ld   a, [hl]				; A = iPlInfo_GuardBreakProg
		sub  a, e					; A -= E
		jp   nc, .saveGuardPenalty	; Did we underflow? If not, jump
		; Otherwise, force it back to 0
		xor  a
	.saveGuardPenalty:
		ld   [hl], a
		
	.ret:
	pop  de
	ret
	
; =============== Play_Pl_DoGuardBreak ===============
; Resets the guard break counters if we got guard break'd.
; This is also used to detect if our guard was broken.
; IN
; - BC: Ptr to wPlInfo
; OUT
; - Z flag: If set, the guard break status was reset.
;           This means our guard was broken.
Play_Pl_DoGuardBreak:

	;
	; If our guard wasn't broken, return without doing anything.
	; This will keep the Z flag cleared, preventing the guard break HitAnim from being set.
	;
	ld   hl, iPlInfo_GuardBreakProg
	add  hl, bc
	ld   a, [hl]
	or   a						; iPlInfo_GuardBreakProg != 0? 
	jp   nz, .ret				; If so, return (Z flag cleared)
	
	;
	; The main effect of the guard break.
	; The guard is removed (as if the player stopped blocking), giving a few
	; frames to the opponent to start a new attack that won't get blocked.
	;
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	res  PF1B_GUARD, [hl]		; Remove guard flag
	
	;
	; Every time guard breaks, the cap is increased by 8.
	;
	ld   hl, iPlInfo_GuardBreakProgCap
	add  hl, bc
	ld   a, [hl]		; A = iPlInfo_GuardBreakProgCap
	add  a, $08			; A += 8
	jp   nc, .resetVals	; Did we overflow? If not, skip
.cap:
	ld   a, $FF			; Otherwise, cap the counters at $FF
.resetVals:
	;
	; Reset the guard break counters to the max value.
	;
	ldd  [hl], a		; Reset iPlInfo_GuardBreakProgCap
	ld   [hl], a		; Reset iPlInfo_GuardBreakProg
	xor  a				; Z flag set
.ret:
	ret
	
L025003:;C
	push af
	ld   hl, $004E
	add  hl, bc
	ld   a, [hl]
	or   a
	jp   z, L025023
	ld   hl, $0023
	add  hl, bc
	bit  5, [hl]
	jp   nz, L025019
	jp   L025023
L025019:;J
	pop  af
	ld   [wPlaySlowdownTimer], a
	ld   a, $01
	ld   [wPlaySlowdownSpeed], a
	ret
L025023:;J
	pop  af
	ret
L025025: db $FA;X
L025026: db $69;X
L025027: db $C1;X
L025028: db $B7;X
L025029: db $CA;X
L02502A: db $3F;X
L02502B: db $50;X
L02502C: db $21;X
L02502D: db $4E;X
L02502E: db $00;X
L02502F: db $09;X
L025030: db $7E;X
L025031: db $B7;X
L025032: db $CA;X
L025033: db $3F;X
L025034: db $50;X
L025035: db $21;X
L025036: db $44;X
L025037: db $00;X
L025038: db $09;X
L025039: db $7E;X
L02503A: db $E6;X
L02503B: db $7F;X
L02503C: db $CA;X
L02503D: db $4B;X
L02503E: db $50;X
L02503F: db $21;X
L025040: db $5F;X
L025041: db $00;X
L025042: db $09;X
L025043: db $7E;X
L025044: db $D6;X
L025045: db $01;X
L025046: db $D2;X
L025047: db $4A;X
L025048: db $50;X
L025049: db $AF;X
L02504A: db $77;X
L02504B: db $C9;X
L02504C:;C
	ld   hl, $006D
	add  hl, bc
	bit  6, [hl]
	jp   z, L02505A
	ld   a, $00
	ld   [wStageBGP], a
L02505A:;J
	ret
L02505B:;I
	call Play_Pl_GiveKnockbackCornered
	call Play_Pl_MoveByColiBoxOverlapX
	call OBJLstS_IsGFXLoadDone
	jp   nz, L02509D
	ld   hl, $001B
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L025090
	cp   $01
	jp   nz, L02509D
	ld   [hl], $00
	ld   hl, $0023
	add  hl, bc
	bit  0, [hl]
	jp   nz, L025087
	ld   hl, $0280
	jp   L02508A
L025087:;J
	ld   hl, $0400
L02508A:;J
	call Play_OBJLstS_SetSpeedH_ByXDirL
	jp   L02509C
L025090:;J
	ld   hl, $0040
	call L0035D9
	jp   nc, L02509C
	call Play_Pl_EndMove
L02509C:;J
	ret
L02509D:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L0250A0:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L0251F1
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L0250CA
	cp   $04
	jp   z, L02511B
	cp   $08
	jp   z, L02512D
	cp   $0C
	jp   z, L025139
	cp   $10
	jp   z, L0251E2
L0250C7: db $C3;X
L0250C8: db $EE;X
L0250C9: db $51;X
L0250CA:;J
	ld   hl, $0023
	add  hl, bc
	bit  7, [hl]
	jp   nz, L0250DF
	call OBJLstS_IsFrameEnd
	jp   nc, L025160
	inc  hl
	ld   [hl], $FF
	jp   L025160
L0250DF:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0251EE
	inc  hl
	ld   [hl], $FF
	ld   hl, $0023
	add  hl, bc
	bit  0, [hl]
	jp   nz, L025100
	ld   hl, $0140
	call Play_OBJLstS_SetSpeedH_ByXDirL
	ld   hl, $FC00
	call Play_OBJLstS_SetSpeedV
	jp   L02510C
L025100:;J
	ld   hl, $0180
	call Play_OBJLstS_SetSpeedH_ByXDirL
	ld   hl, $FA00
	call Play_OBJLstS_SetSpeedV
L02510C:;J
	ld   hl, rJOYP
	call Play_OBJLstS_MoveV
	ld   hl, $0000
	call OBJLstS_ApplyGravity
	jp   L0251EE
L02511B:;J
	ld   hl, $0000
	add  hl, de
	bit  3, [hl]
	jp   z, L025160
	ld   hl, rJOYP
	call Play_OBJLstS_MoveV
	jp   L025160
L02512D:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0251EE
	inc  hl
	ld   [hl], $FF
	jp   L0251EE
L025139:;J
	ld   hl, $0000
	add  hl, de
	bit  3, [hl]
	jp   z, L02515D
	push bc
	ld   hl, $0007
	add  hl, de
	ld   b, [hl]
	inc  hl
	ld   c, [hl]
	push bc
	pop  hl
	pop  bc
	sra  h
	rr   l
	call Play_OBJLstS_SetSpeedH
	ld   hl, $FD00
	call Play_OBJLstS_SetSpeedV
	jp   L0251CF
L02515D:;J
	jp   L0251CF
L025160:;J
	ld   hl, $0060
	call OBJLstS_ApplyGravity
	jp   nc, L0251EE
	call Play_Pl_IsDizzy
	jp   nz, L02517E
	ld   hl, $004E
	add  hl, bc
	ld   a, [hl]
	or   a
	jp   z, L02517E
	call Play_Pl_AreBothBtnHeld
	jp   c, L025196
L02517E:;J
	ld   a, $08
	ld   h, $05
	call L002E1A
	ld   hl, $0021
	add  hl, bc
	set  7, [hl]
	ld   hl, $0023
	add  hl, bc
	res  1, [hl]
	res  6, [hl]
	jp   L0251F1
L025196:;J
	ld   hl, $0083
	add  hl, bc
	ld   [hl], $00
	ld   hl, $0021
	add  hl, bc
	res  3, [hl]
	res  5, [hl]
	set  0, [hl]
	set  1, [hl]
	set  2, [hl]
	inc  hl
	set  6, [hl]
	set  7, [hl]
	inc  hl
	res  1, [hl]
	res  6, [hl]
	call Play_Pl_GetDirKeys_ByXFlipR
	jp   nc, L0251BF
	bit  0, a
	jp   nz, L0251C4
L0251BF:;J
	ld   a, $20
	jp   L0251C9
L0251C4:;J
	ld   a, $1E
	jp   L0251C9
L0251C9:;J
	call Pl_Unk_SetNewMoveAndAnim_StopSpeed
	jp   L0251F1
L0251CF:;J
	ld   hl, $0060
	call OBJLstS_ApplyGravity
	jp   nc, L0251EE
	ld   a, $10
	ld   h, $05
	call L002E1A
	jp   L0251F1
L0251E2:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0251EE
	call L003CB3
	jp   L0251F1
L0251EE:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L0251F1:;J
	ret
L0251F2:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L0252CA
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L025217
	cp   $04
	jp   z, L025245
	cp   $08
	jp   z, L025258
	cp   $0C
	jp   z, L0252BB
L025214: db $C3;X
L025215: db $C7;X
L025216: db $52;X
L025217:;J
	ld   hl, $0071
	add  hl, bc
	ld   a, [hl]
	cp   $1A
	jp   nz, L025242
	ld   hl, $0072
	add  hl, bc
	ld   a, [hl]
	cp   $48
	jp   z, L025233
	cp   $4A
	jp   z, L025233
	jp   L025242
L025233:;J
	ld   hl, $0009
	add  hl, de
	bit  7, [hl]
	jp   nz, L02527F
	ld   hl, $0300
	call Play_OBJLstS_SetSpeedH_ByXFlipR
L025242:;J
	jp   L02527F
L025245:;J
	call Play_Pl_DoGroundScreenShake
	call OBJLstS_IsFrameEnd
	jp   nc, L0252C7
	inc  hl
	ld   [hl], $FF
	xor  a
	ld   [wScreenShakeY], a
	jp   L0252C7
L025258:;J
	ld   hl, $0000
	add  hl, de
	bit  3, [hl]
	jp   z, L02527C
	push bc
	ld   hl, $0007
	add  hl, de
	ld   b, [hl]
	inc  hl
	ld   c, [hl]
	push bc
	pop  hl
	pop  bc
	sra  h
	rr   l
	call Play_OBJLstS_SetSpeedH
	ld   hl, $FD00
	call Play_OBJLstS_SetSpeedV
	jp   L0252A8
L02527C:;J
	jp   L0252A8
L02527F:;J
	ld   hl, $0060
	call OBJLstS_ApplyGravity
	jp   nc, L0252C7
	ld   a, $04
	ld   h, $09
	call L002E1A
	jp   z, L0252CA
	ld   hl, $0021
	add  hl, bc
	set  7, [hl]
	ld   a, $0E
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0023
	add  hl, bc
	res  1, [hl]
	res  6, [hl]
	jp   L0252CA
L0252A8:;J
	ld   hl, $0060
	call OBJLstS_ApplyGravity
	jp   nc, L0252C7
	ld   a, $0C
	ld   h, $05
	call L002E1A
	jp   L0252CA
L0252BB:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0252C7
	call L003CB3
	jp   L0252CA
L0252C7:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L0252CA:;J
	ret
L0252CB:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L025326
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L0252EB
	cp   $04
	jp   z, L0252FC
	cp   $08
	jp   z, L025317
L0252E8: db $C3;X
L0252E9: db $23;X
L0252EA: db $53;X
L0252EB:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L025323
	inc  hl
	ld   [hl], $05
	ld   a, $0E
	call HomeCall_Sound_ReqPlayExId
	jp   L025323
L0252FC:;J
	call Play_Pl_DoGroundScreenShake
	call OBJLstS_IsFrameEnd
	jp   nc, L025323
	inc  hl
	ld   [hl], $10
	xor  a
	ld   [wScreenShakeY], a
	ld   hl, $0023
	add  hl, bc
	res  1, [hl]
	res  6, [hl]
	jp   L025323
L025317:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L025323
	call L003CB3
	jp   L025326
L025323:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L025326:;J
	ret
L025327:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L025495
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L02535B
	cp   $04
	jp   z, L02536E
	cp   $08
	jp   z, L0253A8
	cp   $0C
	jp   z, L0253BB
	cp   $10
	jp   z, L0253DA
	cp   $14
	jp   z, L0253E9
	cp   $18
	jp   z, L025486
L025358: db $C3;X
L025359: db $92;X
L02535A: db $54;X
L02535B:;J
	ld   hl, $0009
	add  hl, de
	ld   a, [hl]
	bit  7, a
	jp   nz, L02541B
	ld   hl, $0013
	add  hl, de
	ld   [hl], $08
	jp   L025424
L02536E:;J
	ld   hl, $0009
	add  hl, de
	ld   a, [hl]
	bit  7, a
	jp   nz, L025381
	ld   hl, $0013
	add  hl, de
	ld   [hl], $08
	jp   L025424
L025381:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L02541B
	ld   hl, $0071
	add  hl, bc
	ld   a, [hl]
	cp   $02
	jp   nz, L025399
	ld   a, $08
	call HomeCall_Sound_ReqPlayExId
	jp   L02539F
L025399:;J
	ld   hl, $0021
	add  hl, bc
	res  7, [hl]
L02539F:;J
	ld   hl, $0013
	add  hl, de
	ld   [hl], $18
	jp   L02541B
L0253A8:;J
	ld   hl, $0071
	add  hl, bc
	ld   a, [hl]
	cp   $02
	jp   nz, L025424
	ld   hl, $0021
	add  hl, bc
	res  7, [hl]
	jp   L025424
L0253BB:;J
	ld   hl, $0071
	add  hl, bc
	ld   a, [hl]
	cp   $02
	jp   nz, L0253CB
	ld   hl, $0021
	add  hl, bc
	res  7, [hl]
L0253CB:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L025424
	ld   hl, $0013
	add  hl, de
	ld   [hl], $04
	jp   L025424
L0253DA:;J
	call Play_Pl_DoGroundScreenShake
	call OBJLstS_IsFrameEnd
	jp   nc, L025492
	inc  hl
	ld   [hl], $FF
	jp   L025492
L0253E9:;J
	ld   hl, $0000
	add  hl, de
	bit  3, [hl]
	jp   z, L025418
	push bc
	ld   hl, $0007
	add  hl, de
	ld   b, [hl]
	inc  hl
	ld   c, [hl]
	push bc
	pop  hl
	pop  bc
	sra  h
	rr   l
	call Play_OBJLstS_SetSpeedH
	ld   hl, $0083
	add  hl, bc
	ld   a, [hl]
	sra  a
	add  a, $04
	cpl
	inc  a
	ld   h, a
	ld   l, $FF
	call Play_OBJLstS_SetSpeedV
	jp   L025473
L025418:;J
	jp   L025473
L02541B:;J
	ld   hl, OAM_Begin
	ld   hl, $0030
	jp   L025437
L025424:;J
	ld   hl, $0071
	add  hl, bc
	ld   a, [hl]
	cp   $02
	jp   z, L025434
	ld   hl, $0021
	add  hl, bc
	set  7, [hl]
L025434:;J
	ld   hl, $0060
L025437:;J
	push hl
	ld   hl, $0009
	add  hl, de
	ld   a, [hl]
	ld   hl, $0083
	add  hl, bc
	ld   [hl], a
	pop  hl
	call OBJLstS_ApplyGravity
	jp   nc, L025492
	ld   a, $10
	ld   h, $0B
	call L002E1A
	jp   z, L025495
	ld   a, $0E
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0071
	add  hl, bc
	ld   a, [hl]
	cp   $02
	jp   z, L025468
	ld   hl, $0021
	add  hl, bc
	set  7, [hl]
L025468:;J
	ld   hl, $0023
	add  hl, bc
	res  1, [hl]
	res  6, [hl]
	jp   L025495
L025473:;J
	ld   hl, $0060
	call OBJLstS_ApplyGravity
	jp   nc, L025492
	ld   a, $18
	ld   h, $05
	call L002E1A
	jp   L025495
L025486:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L025492
	call L003CB3
	jp   L025495
L025492:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L025495:;J
	ret
L025496:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L0254EF
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L0254B6
	cp   $04
	jp   z, L0254C2
	cp   $08
	jp   z, L0254E0
L0254B3: db $C3;X
L0254B4: db $EC;X
L0254B5: db $54;X
L0254B6:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0254C5
	inc  hl
	ld   [hl], $FF
	jp   L0254C5
L0254C2:;J
	jp   L0254C5
L0254C5:;J
	ld   hl, $0060
	call OBJLstS_ApplyGravity
	jp   nc, L0254EC
	ld   a, $08
	ld   h, $05
	call L002E1A
	ld   hl, $0023
	add  hl, bc
	res  1, [hl]
	res  6, [hl]
	jp   L0254EF
L0254E0:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0254EC
	call L003CB3
	jp   L0254EF
L0254EC:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L0254EF:;J
	ret
L0254F0:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L025576
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L025521
	cp   $04
	jp   z, L02552D
	cp   $08
	jp   z, L025537
	cp   $0C
	jp   z, L025541
	cp   $10
	jp   z, L02554B
	cp   $14
	jp   z, L025555
	cp   $18
	jp   z, L025568
L025521:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L025555
	inc  hl
	ld   [hl], $FF
	jp   L025555
L02552D:;J
	ld   a, $F9
	ld   h, $FF
	call OBJLstS_ReqAnimOnGtYSpeed
	jp   L025555
L025537:;J
	ld   a, $FB
	ld   h, $FF
	call OBJLstS_ReqAnimOnGtYSpeed
	jp   L025555
L025541:;J
	ld   a, $FF
	ld   h, $FF
	call OBJLstS_ReqAnimOnGtYSpeed
	jp   L025555
L02554B:;J
	ld   a, $01
	ld   h, $FF
	call OBJLstS_ReqAnimOnGtYSpeed
	jp   L025555
L025555:;J
	ld   hl, $0060
	call OBJLstS_ApplyGravity
	jp   nc, L025573
	ld   a, $18
	ld   h, $00
	call Play_Pl_SetJumpLandAnimFrame
	jp   L025576
L025568:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L025573
	call Play_Pl_EndMove
	jr   L025576
L025573:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L025576:;JR
	ret
L025577: db $CD;X
L025578: db $7B;X
L025579: db $34;X
L02557A: db $CD;X
L02557B: db $B3;X
L02557C: db $38;X
L02557D: db $DA;X
L02557E: db $B0;X
L02557F: db $55;X
L025580: db $21;X
L025581: db $17;X
L025582: db $00;X
L025583: db $19;X
L025584: db $7E;X
L025585: db $FE;X
L025586: db $00;X
L025587: db $CA;X
L025588: db $8F;X
L025589: db $55;X
L02558A: db $FE;X
L02558B: db $04;X
L02558C: db $CA;X
L02558D: db $A2;X
L02558E: db $55;X
L02558F: db $21;X
L025590: db $60;X
L025591: db $00;X
L025592: db $CD;X
L025593: db $14;X
L025594: db $36;X
L025595: db $D2;X
L025596: db $AD;X
L025597: db $55;X
L025598: db $3E;X
L025599: db $04;X
L02559A: db $26;X
L02559B: db $00;X
L02559C: db $CD;X
L02559D: db $EC;X
L02559E: db $2D;X
L02559F: db $C3;X
L0255A0: db $B0;X
L0255A1: db $55;X
L0255A2: db $CD;X
L0255A3: db $D9;X
L0255A4: db $2D;X
L0255A5: db $D2;X
L0255A6: db $AD;X
L0255A7: db $55;X
L0255A8: db $CD;X
L0255A9: db $A2;X
L0255AA: db $2E;X
L0255AB: db $18;X
L0255AC: db $03;X
L0255AD: db $C3;X
L0255AE: db $0B;X
L0255AF: db $2F;X
L0255B0: db $C9;X
L0255B1:;I
	call Play_Pl_GiveKnockbackCornered
	call Play_Pl_IsMoveLoading
	jp   c, L02561B
	call OBJLstS_IsGFXLoadDone
	jp   nz, L02561C
	ld   hl, $001B
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L0255F6
	cp   $01
	jp   z, L0255D2
	jp   L02561C
L0255D2:;J
	ld   [hl], $00
	ld   hl, $0023
	add  hl, bc
	bit  0, [hl]
	jp   nz, L0255E3
	ld   hl, $0280
	jp   L0255E6
L0255E3:;J
	ld   hl, $0400
L0255E6:;J
	call Play_OBJLstS_SetSpeedH_ByXDirL
	ld   hl, $0005
	add  hl, de
	ld   a, [hl]
	cp   $88
	jp   nz, L025610
	jp   L02561B
L0255F6:;J
	ld   hl, $0040
	call L0035D9
	jp   nc, L02561B
	ld   hl, $004E
	add  hl, bc
	ld   a, [hl]
	or   a
	jp   z, L025610
	ld   hl, $0071
	add  hl, bc
	ld   a, [hl]
	jp   L025610
L025610:;J
	ld   a, $7C
	call Pl_Unk_SetNewMoveAndAnim_StopSpeed
	jp   L02561B
L025618: db $CD;X
L025619: db $A2;X
L02561A: db $2E;X
L02561B:;J
	ret
L02561C:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L02561F:;I
	call Play_Pl_GiveKnockbackCornered
	call Play_Pl_IsMoveLoading
	jp   c, L02564F
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L025637
	cp   $04
	jp   z, L025643
L025637:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L025650
	inc  hl
	ld   [hl], $FF
	jp   L025650
L025643:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L025650
L025649: db $CD;X
L02564A: db $B3;X
L02564B: db $3C;X
L02564C: db $C3;X
L02564D: db $4F;X
L02564E: db $56;X
L02564F:;J
	ret
L025650:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L025653:;I
	ld   hl, $0072
	add  hl, bc
	ld   a, [hl]
	cp   $6C
	jp   nz, L0256FC
	ld   hl, $C179
	ld   a, [hl]
	or   a
	jp   z, L0256F7
	dec  [hl]
	jp   z, L0256F7
	ld   hl, $0020
	add  hl, bc
	bit  7, [hl]
	jp   z, L025697
	ld   a, [wDifficulty]
	cp   $00
	jp   z, L025757
	cp   $01
	jp   z, L025687
	ld   a, [wTimer]
	and  a, $F0
	jp   L02569C
L025687:;J
	ld   a, [wTimer]
	and  a, $80
	jp   z, L025757
	ld   a, [wPlayTimer]
	and  a, $F0
	jp   L02569C
L025697:;J
	ld   hl, $0046
	add  hl, bc
	ld   a, [hl]
L02569C:;J
	bit  4, a
	jp   nz, L0256BD
	bit  5, a
	jp   nz, L0256B3
	bit  6, a
	jp   nz, L0256C2
	bit  7, a
	jp   nz, L0256B8
	jp   L025757
L0256B3:;J
	ld   a, $30
	jp   L0256C4
L0256B8:;J
	ld   a, $32
	jp   L0256C4
L0256BD:;J
	ld   a, $34
	jp   L0256C4
L0256C2:;J
	ld   a, $36
L0256C4:;J
	ld   hl, $007C
	add  hl, bc
	ld   [hl], $01
	ld   hl, $0021
	add  hl, bc
	res  3, [hl]
	res  5, [hl]
	set  0, [hl]
	set  1, [hl]
	set  2, [hl]
	call Pl_Unk_SetNewMoveAndAnim_ShakeScreenReset
	ld   hl, $001B
	add  hl, de
	ld   [hl], $00
	inc  hl
	ld   [hl], $00
	ld   hl, $0021
	add  hl, bc
	set  7, [hl]
	ld   a, $00
	ld   [wPlayPlThrowActId], a
	ld   a, $00
	ld   [$C179], a
	jp   L025757
L0256F7:;J
	ld   a, $04
	ld   [wPlayPlThrowActId], a
L0256FC:;J
	ld   hl, $001B
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L025732
	cp   $01
	jp   z, L02570E
	jp   L025758
L02570E: db $36;X
L02570F: db $00;X
L025710: db $21;X
L025711: db $23;X
L025712: db $00;X
L025713: db $09;X
L025714: db $CB;X
L025715: db $46;X
L025716: db $C2;X
L025717: db $1F;X
L025718: db $57;X
L025719: db $21;X
L02571A: db $80;X
L02571B: db $02;X
L02571C: db $C3;X
L02571D: db $22;X
L02571E: db $57;X
L02571F: db $21;X
L025720: db $00;X
L025721: db $04;X
L025722: db $CD;X
L025723: db $85;X
L025724: db $35;X
L025725: db $21;X
L025726: db $05;X
L025727: db $00;X
L025728: db $19;X
L025729: db $7E;X
L02572A: db $FE;X
L02572B: db $88;X
L02572C: db $C2;X
L02572D: db $4C;X
L02572E: db $57;X
L02572F: db $C3;X
L025730: db $57;X
L025731: db $57;X
L025732: db $21;X
L025733: db $40;X
L025734: db $00;X
L025735: db $CD;X
L025736: db $D9;X
L025737: db $35;X
L025738: db $D2;X
L025739: db $57;X
L02573A: db $57;X
L02573B: db $21;X
L02573C: db $4E;X
L02573D: db $00;X
L02573E: db $09;X
L02573F: db $7E;X
L025740: db $B7;X
L025741: db $CA;X
L025742: db $4C;X
L025743: db $57;X
L025744: db $21;X
L025745: db $71;X
L025746: db $00;X
L025747: db $09;X
L025748: db $7E;X
L025749: db $C3;X
L02574A: db $4C;X
L02574B: db $57;X
L02574C: db $3E;X
L02574D: db $7C;X
L02574E: db $CD;X
L02574F: db $1B;X
L025750: db $34;X
L025751: db $C3;X
L025752: db $57;X
L025753: db $57;X
L025754: db $CD;X
L025755: db $A2;X
L025756: db $2E;X
L025757:;J
	ret
L025758:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L02575B:;I
	call Play_Pl_GiveKnockbackCornered
	call OBJLstS_IsGFXLoadDone
	jp   nz, L025773
	ld   hl, $001B
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L0257B6
	cp   $01
	jp   z, L025792
L025773:;J
	ld   a, [$C178]
	or   a
	jp   z, L0257D4
	call L024AC1
	ld   a, [$C176]
	ld   h, a
	ld   l, $00
	call Play_OBJLstS_MoveH_ByOtherXFlipL
	ld   a, [$C177]
	ld   h, a
	ld   l, $00
	call Play_OBJLstS_MoveV
	jp   L0257D4
L025792:;J
	ld   [hl], $00
	ld   hl, $0023
	add  hl, bc
	bit  0, [hl]
	jp   nz, L0257A3
L02579D: db $21;X
L02579E: db $80;X
L02579F: db $02;X
L0257A0: db $C3;X
L0257A1: db $A6;X
L0257A2: db $57;X
L0257A3:;J
	ld   hl, $0400
	call Play_OBJLstS_SetSpeedH_ByXDirL
	ld   hl, $0005
	add  hl, de
	ld   a, [hl]
	cp   $88
	jp   nz, L0257C8
L0257B3: db $C3;X
L0257B4: db $D3;X
L0257B5: db $57;X
L0257B6: db $21;X
L0257B7: db $40;X
L0257B8: db $00;X
L0257B9: db $CD;X
L0257BA: db $D9;X
L0257BB: db $35;X
L0257BC: db $D2;X
L0257BD: db $D3;X
L0257BE: db $57;X
L0257BF: db $21;X
L0257C0: db $4E;X
L0257C1: db $00;X
L0257C2: db $09;X
L0257C3: db $7E;X
L0257C4: db $B7;X
L0257C5: db $C2;X
L0257C6: db $D0;X
L0257C7: db $57;X
L0257C8:;J
	ld   a, $7C
	call Pl_Unk_SetNewMoveAndAnim_StopSpeed
	jp   L0257D3
L0257D0: db $CD;X
L0257D1: db $A2;X
L0257D2: db $2E;X
L0257D3:;J
	ret
L0257D4:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
; =============== MoveInputReader_Ryo ===============
; Special move input checker for RYO.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
; OUT
; - C flag: If set, a move was started
MoveInputReader_Ryo:
	mMvIn_Validate Ryo
	
.chkAir:
	; Different shortcuts in the air
	;             SELECT + B               SELECT + A
	mMvIn_ChkEasy MoveInit_Ryo_RyuKoRanbu, MoveInit_Ryo_KoHou_Hidden
	
	; But no actual air moves. This is pointless.
	mMvIn_ChkGA Ryo, .chkAirPunch, .chkAirKick
.chkAirPunch:
.chkAirKick:
	jp   MoveInputReader_Ryo_NoMove
	
.chkGround:
	;             SELECT + B               SELECT + A
	mMvIn_ChkEasy MoveInit_Ryo_RyuKoRanbu, MoveInit_Ryo_MouKoRaiJinGou
	mMvIn_ChkGA Ryo, .chkPunch, .chkKick
	
.chkPunch:
	mMvIn_ValidateSuper .chkPunchNoSuper
	; DFDB+P -> Ryu Ko Ranbu
	mMvIn_ChkDir MoveInput_DFDB, MoveInit_Ryo_RyuKoRanbu
	; FBDF+P -> Haoh Shokoh Ken 
	mMvIn_ChkDir MoveInput_FBDF, MoveInit_Ryo_HaohShokohKen 
.chkPunchNoSuper:
	; FDF+P -> Ko Hou
	mMvIn_ChkDir MoveInput_FDF, MoveInit_Ryo_KoHou
	; DB+P -> Mou Ko Rai Jin Gou
	mMvIn_ChkDir MoveInput_DB, MoveInit_Ryo_MouKoRaiJinGou
	; BDF+P (close) -> Kyokuken Ryu Renbu Ken
	mMvIn_ChkDir MoveInput_BDF, MoveInit_Ryo_KyokukenRyuRenbuKen
	; DF+P -> Ko Ou Ken 
	mMvIn_ChkDir MoveInput_DF, MoveInit_Ryo_KoOuKen 
	; End
	jp   MoveInputReader_Ryo_NoMove
.chkKick:
	; DB+K -> Hien Shippu Kyaku
	mMvIn_ChkDir MoveInput_DB, MoveInit_Ryo_HienShippuKyaku
	; End
	jp   MoveInputReader_Ryo_NoMove
; =============== MoveInit_Ryo_KoOuKen ===============
MoveInit_Ryo_KoOuKen:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_RYO_KO_OU_KEN_L, MOVE_RYO_KO_OU_KEN_H
	call MoveInputS_SetSpecMove_StopSpeed
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	set  PF0B_PROJREM, [hl]
	jp   MoveInputReader_Ryo_SetMove
; =============== MoveInit_Ryo_MouKoRaiJinGou ===============
MoveInit_Ryo_MouKoRaiJinGou:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_RYO_MOU_KO_RAI_JIN_GOU_L, MOVE_RYO_MOU_KO_RAI_JIN_GOU_H
	call MoveInputS_SetSpecMove_StopSpeed
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_GUARD, [hl]
	res  PF1B_CROUCH, [hl]
	jp   MoveInputReader_Ryo_SetMove
; =============== MoveInit_Ryo_HienShippuKyaku ===============
MoveInit_Ryo_HienShippuKyaku:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_RYO_HIEN_SHIPPU_KYAKU_L, MOVE_RYO_HIEN_SHIPPU_KYAKU_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Ryo_SetMove
; =============== MoveInit_Ryo_KoHou ===============
MoveInit_Ryo_KoHou:
	call Play_Pl_ClearJoyDirBuffer
	; [POI] Hidden heavy version with the autocharge cheat.
	;       It moves further horizontally than the normal one and hits multiple
	;       times, like Rising Tackle.
	mMvIn_GetLHE MOVE_RYO_KO_HOU_L, MOVE_RYO_KO_HOU_H, MoveInit_Ryo_KoHou_Hidden
	call MoveInputS_SetSpecMove_StopSpeed
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_INVULN, [hl]
	jp   MoveInputReader_Ryo_SetMove
; =============== MoveInit_Ryo_KyokukenRyuRenbuKen ===============
MoveInit_Ryo_KyokukenRyuRenbuKen:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_ValidateClose MoveInputReader_Ryo_NoMove
	mMvIn_GetLH MOVE_RYO_KYOKUKEN_RYU_RENBU_KEN_L, MOVE_RYO_KYOKUKEN_RYU_RENBU_KEN_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Ryo_SetMove
; =============== MoveInit_Ryo_KoHou_Hidden ===============
MoveInit_Ryo_KoHou_Hidden: 
	call Play_Pl_ClearJoyDirBuffer
	; [POI] There's an hidden light version, which is unreachable without the move shortcut (SELECT + A in the air)
	;       because hidden light moves are disallowed normally.
	mMvIn_GetLH MOVE_RYO_KO_HOU_EL, MOVE_RYO_KO_HOU_EH
	call MoveInputS_SetSpecMove_StopSpeed
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_INVULN, [hl]
	jp   MoveInputReader_Ryo_SetMove
; =============== MoveInit_Ryo_RyuKoRanbu ===============
MoveInit_Ryo_RyuKoRanbu:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetSD MOVE_RYO_RYU_KO_RANBU_S, MOVE_RYO_RYU_KO_RANBU_D
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Ryo_SetMove
; =============== MoveInit_Ryo_HaohShokohKen ===============
MoveInit_Ryo_HaohShokohKen:
	mMvIn_ValidateProjActive Ryo
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetSD MOVE_RYO_HAOH_SHOKOH_KEN_S, MOVE_RYO_HAOH_SHOKOH_KEN_D
	call MoveInputS_SetSpecMove_StopSpeed
	call Play_Proj_CopyMoveDamageFromPl
	jp   MoveInputReader_Ryo_SetMove
; =============== MoveInputReader_Ryo_SetMove ===============
MoveInputReader_Ryo_SetMove:
	scf
	ret
; =============== MoveInputReader_Ryo_NoMove ===============
MoveInputReader_Ryo_NoMove:
	or   a
	ret
L02593B:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L02599F
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $04
	jp   z, L02595B
	cp   $08
	jp   z, L02597B
	cp   $10
	jp   z, L025990
	jp   L02599C
L02595B:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L02596D
	call MoveInputS_CheckMoveLHVer
	jp   z, L02596D
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
L02596D:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L02599C
	ld   a, $16
	call HomeCall_Sound_ReqPlayExId
	jp   L02599C
L02597B:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L025987
	call MoveInputS_CheckMoveLHVer
	jp   z, L025987
L025987:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L02599C
	jp   L02599C
L025990:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L02599C
	call Play_Pl_EndMove
	jp   L02599F
L02599C:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L02599F:;J
	ret
L0259A0:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L025A66
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L0259CF
	cp   $04
	jp   z, L0259DB
	cp   $08
	jp   z, L025A23
	cp   $0C
	jp   z, L025A34
	cp   $10
	jp   z, L025A49
	cp   $14
	jp   z, L025A52
L0259CC: db $C3;X
L0259CD: db $63;X
L0259CE: db $5A;X
L0259CF:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L025A63
	inc  hl
	ld   [hl], $02
	jp   L025A63
L0259DB:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L025A12
	ld   a, $11
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0021
	add  hl, bc
	res  7, [hl]
	res  3, [hl]
	call MoveInputS_CheckMoveLHVer
	jp   c, L025A09
	jp   nz, L025A00
	ld   hl, $0400
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	jp   L025A40
L025A00:;J
	ld   hl, $0500
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	jp   L025A40
L025A09:;J
	ld   hl, $0600
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	jp   L025A40
L025A12:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L025A40
	ld   hl, $0404
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	jp   L025A40
L025A23:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L025A40
	ld   hl, $0408
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	jp   L025A40
L025A34:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L025A40
	inc  hl
	ld   [hl], $08
	jp   L025A40
L025A40:;J
	ld   hl, $0040
	call L0035D9
	jp   L025A63
L025A49:;J
	ld   hl, $0080
	call L0035D9
	jp   L025A63
L025A52:;J
	ld   hl, $0080
	call L0035D9
	call OBJLstS_IsFrameEnd
	jp   nc, L025A63
	call Play_Pl_EndMove
	jr   L025A66
L025A63:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L025A66:;JR
	ret
L025A67:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L025B37
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L025A96
	cp   $04
	jp   z, L025AA2
	cp   $08
	jp   z, L025B15
	cp   $0C
	jp   z, L025B01
	cp   $10
	jp   z, L025B15
	cp   $14
	jp   z, L025B28
L025A93: db $C3;X
L025A94: db $15;X
L025A95: db $5B;X
L025A96:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L025B34
	inc  hl
	ld   [hl], $03
	jp   L025B34
L025AA2:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L025AE3
	ld   a, $11
	call HomeCall_Sound_ReqPlayExId
	call MoveInputS_CheckMoveLHVer
	jp   c, L025AD4
	jp   nz, L025AC5
	ld   hl, $0300
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, OAM_Begin
	call Play_OBJLstS_SetSpeedV
	jp   L025B15
L025AC5:;J
	ld   hl, $0400
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FD80
	call Play_OBJLstS_SetSpeedV
	jp   L025B15
L025AD4: db $21;X
L025AD5: db $00;X
L025AD6: db $05;X
L025AD7: db $CD;X
L025AD8: db $69;X
L025AD9: db $35;X
L025ADA: db $21;X
L025ADB: db $00;X
L025ADC: db $FD;X
L025ADD: db $CD;X
L025ADE: db $AD;X
L025ADF: db $35;X
L025AE0: db $C3;X
L025AE1: db $15;X
L025AE2: db $5B;X
L025AE3:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L025B15
	inc  hl
	push hl
	ld   hl, $0033
	add  hl, bc
	ld   a, [hl]
	cp   $52
	jp   z, L025AFB
	pop  hl
	ld   [hl], $FF
	jp   L025B15
L025AFB:;J
	pop  hl
	ld   [hl], $03
	jp   L025B15
L025B01:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L025B15
	inc  hl
	ld   [hl], $FF
	ld   hl, $0808
	ld   a, $01
	call Play_Pl_SetMoveDamageNext
	jp   L025B15
L025B15:;J
	ld   hl, $0030
	call OBJLstS_ApplyGravity
	jp   nc, L025B34
	ld   a, $14
	ld   h, $05
	call Play_Pl_SetJumpLandAnimFrame
	jp   L025B37
L025B28:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L025B34
	call Play_Pl_EndMove
	jp   L025B37
L025B34:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L025B37:;J
	ret
L025B38:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L025CAE
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L025B94
	cp   $04
	jp   z, L025BA6
	cp   $08
	jp   z, L025C2C
	cp   $0C
	jp   z, L025C18
	cp   $14
	jp   z, L025C18
	cp   $1C
	jp   z, L025C18
	cp   $24
	jp   z, L025C18
	cp   $2C
	jp   z, L025C18
	cp   $34
	jp   z, L025C18
	cp   $3C
	jp   z, L025C18
	cp   $40
	jp   z, L025C6B
	cp   $44
	jp   z, L025C18
	cp   $4C
	jp   z, L025C18
	cp   $54
	jp   z, L025C6B
	cp   $58
	jp   z, L025C9F
	jp   L025C43
L025B94:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L025B9A
L025B9A:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L025CAB
	inc  hl
	ld   [hl], $FF
	jp   L025CAB
L025BA6:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L025BD5
	ld   a, $11
	call HomeCall_Sound_ReqPlayExId
	call MoveInputS_CheckMoveLHVer
	jp   nz, L025BC6
	ld   hl, $05FF
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, OAM_Begin
	call Play_OBJLstS_SetSpeedV
	jp   L025C8C
L025BC6:;J
	ld   hl, $06FF
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FD80
	call Play_OBJLstS_SetSpeedV
	jp   L025C8C
L025BD5:;J
	ld   hl, $0063
	add  hl, bc
	bit  1, [hl]
	jp   z, L025C15
	ld   hl, $006E
	add  hl, bc
	bit  7, [hl]
	jp   nz, L025C15
	bit  4, [hl]
	jp   z, L025C15
	bit  3, [hl]
	jp   nz, L025C0F
	ld   hl, $010A
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	ld   a, $08
	ld   h, $01
	call L002E49
	ld   hl, $0000
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $0005
	add  hl, de
	ld   [hl], $88
	jp   L025CAE
L025C0F:;J
	ld   hl, $0100
	call Play_OBJLstS_SetSpeedH_ByXFlipR
L025C15:;J
	jp   L025C8C
L025C18:;J
	call OBJLstS_ApplyXSpeed
	call OBJLstS_IsFrameNewLoad
	jp   z, L025CAB
	ld   hl, $010A
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	jp   L025C54
L025C2C:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L025CAB
	ld   hl, $0109
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	ld   hl, $0080
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	jp   L025CAB
L025C43:;J
	call OBJLstS_ApplyXSpeed
	call OBJLstS_IsFrameNewLoad
	jp   z, L025CAB
	ld   hl, $0109
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
L025C54:;J
	ld   hl, $0073
	add  hl, bc
	ld   a, [hl]
	cp   $09
	jp   z, L025CAB
	cp   $0A
	jp   z, L025CAB
L025C63: db $3E;X
L025C64: db $18;X
L025C65: db $CD;X
L025C66: db $1B;X
L025C67: db $34;X
L025C68: db $C3;X
L025C69: db $AE;X
L025C6A: db $5C;X
L025C6B:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L025CAB
	call MoveInputS_CheckMoveLHVer
	jp   nz, L025C7C
	ld   a, $54
	jp   L025C7E
L025C7C:;J
	ld   a, $56
L025C7E:;J
	call MoveInputS_SetSpecMove_StopSpeed
	ld   hl, $0608
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	jp   L025CAE
L025C8C:;J
	ld   hl, $0030
	call OBJLstS_ApplyGravity
	jp   nc, L025CAB
	ld   a, $58
	ld   h, $07
	call Play_Pl_SetJumpLandAnimFrame
	jp   L025CAE
L025C9F:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L025CAB
	call Play_Pl_EndMove
	jp   L025CAE
L025CAB:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L025CAE:;J
	ret
L025CAF:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L025E5B
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L025D47
	cp   $04
	jp   z, L025D53
	cp   $08
	jp   z, L025DD9
	cp   $0C
	jp   z, L025DC5
	cp   $14
	jp   z, L025DC5
	cp   $1C
	jp   z, L025DC5
	cp   $24
	jp   z, L025DC5
	cp   $2C
	jp   z, L025DC5
	cp   $34
	jp   z, L025DC5
	cp   $3C
	jp   z, L025DC5
	cp   $44
	jp   z, L025DC5
	cp   $4C
	jp   z, L025DC5
	cp   $54
	jp   z, L025DC5
	cp   $5C
	jp   z, L025DC5
	cp   $64
	jp   z, L025DC5
	cp   $6C
	jp   z, L025DC5
	cp   $74
	jp   z, L025DC5
	cp   $7C
	jp   z, L025DC5
	cp   $84
	jp   z, L025DC5
	cp   $8C
	jp   z, L025DC5
	cp   $94
	jp   z, L025DC5
	cp   $98
	jp   z, L025E18
	cp   $9C
	jp   z, L025DC5
	cp   $A4
	jp   z, L025DC5
	cp   $AC
	jp   z, L025DC5
	cp   $B0
	jp   z, L025E18
	cp   $B4
	jp   z, L025E4C
	jp   L025DF0
L025D47:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L025E58
	inc  hl
	ld   [hl], $FF
	jp   L025E58
L025D53:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L025D82
	ld   a, $11
	call HomeCall_Sound_ReqPlayExId
	call MoveInputS_CheckMoveLHVer
	jp   nz, L025D73
	ld   hl, $05FF
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, OAM_Begin
	call Play_OBJLstS_SetSpeedV
	jp   L025E39
L025D73:;J
	ld   hl, $06FF
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FD80
	call Play_OBJLstS_SetSpeedV
	jp   L025E39
L025D82:;J
	ld   hl, $0063
	add  hl, bc
	bit  1, [hl]
	jp   z, L025DC2
	ld   hl, $006E
	add  hl, bc
	bit  7, [hl]
	jp   nz, L025DC2
	bit  4, [hl]
	jp   z, L025DC2
	bit  3, [hl]
	jp   nz, L025DBC
	ld   hl, $010A
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	ld   a, $08
	ld   h, $01
	call L002E49
	ld   hl, $0000
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $0005
	add  hl, de
	ld   [hl], $88
	jp   L025E5B
L025DBC: db $21;X
L025DBD: db $00;X
L025DBE: db $01;X
L025DBF: db $CD;X
L025DC0: db $69;X
L025DC1: db $35;X
L025DC2:;J
	jp   L025E39
L025DC5:;J
	call OBJLstS_ApplyXSpeed
	call OBJLstS_IsFrameNewLoad
	jp   z, L025E58
	ld   hl, $010A
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	jp   L025E01
L025DD9:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L025E58
	ld   hl, $0109
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	ld   hl, $0080
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	jp   L025E58
L025DF0:;J
	call OBJLstS_ApplyXSpeed
	call OBJLstS_IsFrameNewLoad
	jp   z, L025E58
	ld   hl, $0109
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
L025E01:;J
	ld   hl, $0073
	add  hl, bc
	ld   a, [hl]
	cp   $09
	jp   z, L025E58
	cp   $0A
	jp   z, L025E58
L025E10: db $3E;X
L025E11: db $18;X
L025E12: db $CD;X
L025E13: db $1B;X
L025E14: db $34;X
L025E15: db $C3;X
L025E16: db $5B;X
L025E17: db $5E;X
L025E18:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L025E58
	call MoveInputS_CheckMoveLHVer
	jp   nz, L025E29
	ld   a, $5C
	jp   L025E2B
L025E29:;J
	ld   a, $5E
L025E2B:;J
	call MoveInputS_SetSpecMove_StopSpeed
	ld   hl, $0208
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	jp   L025E5B
L025E39:;J
	ld   hl, $0030
	call OBJLstS_ApplyGravity
	jp   nc, L025E58
L025E42: db $3E;X
L025E43: db $B4;X
L025E44: db $26;X
L025E45: db $07;X
L025E46: db $CD;X
L025E47: db $EC;X
L025E48: db $2D;X
L025E49: db $C3;X
L025E4A: db $5B;X
L025E4B: db $5E;X
L025E4C: db $CD;X
L025E4D: db $D9;X
L025E4E: db $2D;X
L025E4F: db $D2;X
L025E50: db $58;X
L025E51: db $5E;X
L025E52: db $CD;X
L025E53: db $A2;X
L025E54: db $2E;X
L025E55: db $C3;X
L025E56: db $5B;X
L025E57: db $5E;X
L025E58:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L025E5B:;J
	ret

; =============== MoveInputReader_Robert ===============
; Special move input checker for ROBERT.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
; OUT
; - C flag: If set, a move was started
MoveInputReader_Robert:
	mMvIn_Validate Robert
	
.chkAir:
	;             SELECT + B                  SELECT + A
	mMvIn_ChkEasy MoveInit_Robert_RyuKoRanbu, MoveInit_Robert_HienRyuuShinKya
	mMvIn_ChkGA Robert, .chkAirPunch, .chkAirKick
.chkAirPunch:
	jp   MoveInputReader_Robert_NoMove
.chkAirKick:
	; DB+K (air) -> Hien Ryuu Shin Kya
	mMvIn_ChkDir MoveInput_DB, MoveInit_Robert_HienRyuuShinKya
	; End
	jp   MoveInputReader_Robert_NoMove
	
.chkGround:
	;             SELECT + B                  SELECT + A
	mMvIn_ChkEasy MoveInit_Robert_RyuKoRanbu, MoveInit_Robert_RyuuGa_Hidden
	mMvIn_ChkGA Robert, .chkPunch, .chkKick
.chkPunch:
	mMvIn_ValidateSuper .chkPunchNoSuper
	; DFDB+P -> Ryu Ko Ranbu
	mMvIn_ChkDir MoveInput_DFDB, MoveInit_Robert_RyuKoRanbu
	; FBDF+P -> Haoh Shokoh Ken 
	mMvIn_ChkDir MoveInput_FBDF, MoveInit_Robert_HaohShokohKen
.chkPunchNoSuper:
	; FDF+P -> Ryuu Ga
	mMvIn_ChkDir MoveInput_FDF, MoveInit_Robert_RyuuGa
	; DF+P -> Ryuu Geki Ken
	mMvIn_ChkDir MoveInput_DF, MoveInit_Robert_RyuuGekiKen
	; End
	jp   MoveInputReader_Robert_NoMove
.chkKick:
	; BDF+K -> Kyokugen Ryu Ranbu Kyaku
	mMvIn_ChkDir MoveInput_BDF, MoveInit_Robert_KyokugenRyuRanbuKyaku
	; FDB+K -> Hien Shippu Kyaku
	mMvIn_ChkDir MoveInput_FDB, MoveInit_Robert_HienShippuKyaku
	; End
	jp   MoveInputReader_Robert_NoMove
; =============== MoveInit_Robert_RyuuGekiKen ===============
MoveInit_Robert_RyuuGekiKen:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_ROBERT_RYUU_GEKI_KEN_L, MOVE_ROBERT_RYUU_GEKI_KEN_H
	call MoveInputS_SetSpecMove_StopSpeed
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	set  PF0B_PROJREM, [hl]
	jp   MoveInputReader_Robert_SetMove
; =============== MoveInit_Robert_HienShippuKyaku ===============
MoveInit_Robert_HienShippuKyaku:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_ROBERT_HIEN_SHIPPU_KYAKU_L, MOVE_ROBERT_HIEN_SHIPPU_KYAKU_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Robert_SetMove
; =============== MoveInit_Robert_HienRyuuShinKya ===============
MoveInit_Robert_HienRyuuShinKya:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_ROBERT_HIEN_RYUU_SHIN_KYA_L, MOVE_ROBERT_HIEN_RYUU_SHIN_KYA_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Robert_SetMove
; =============== MoveInit_Robert_RyuuGa ===============
MoveInit_Robert_RyuuGa:
	call Play_Pl_ClearJoyDirBuffer
	; [POI] Move has hidden version.
	;       Compared to the normal one, ???
	mMvIn_GetLHE MOVE_ROBERT_RYUU_GA_L, MOVE_ROBERT_RYUU_GA_H, MoveInit_Robert_RyuuGa_Hidden
	call MoveInputS_SetSpecMove_StopSpeed
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_INVULN, [hl]
	jp   MoveInputReader_Robert_SetMove
; =============== MoveInit_Robert_KyokugenRyuRanbuKyaku ===============
MoveInit_Robert_KyokugenRyuRanbuKyaku:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_ValidateClose MoveInputReader_Robert_NoMove
	mMvIn_GetLH MOVE_ROBERT_KYOKUGEN_RYU_RANBU_KYAKU_L, MOVE_ROBERT_KYOKUGEN_RYU_RANBU_KYAKU_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Robert_SetMove
; =============== MoveInit_Robert_RyuuGa_Hidden ===============
MoveInit_Robert_RyuuGa_Hidden:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_ROBERT_RYUU_GA_HIDDEN_L, MOVE_ROBERT_RYUU_GA_HIDDEN_H
	call MoveInputS_SetSpecMove_StopSpeed
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_INVULN, [hl]
	jp   MoveInputReader_Robert_SetMove
; =============== MoveInit_Robert_RyuKoRanbu ===============
MoveInit_Robert_RyuKoRanbu:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetSD MOVE_ROBERT_RYU_KO_RANBU_S, MOVE_ROBERT_RYU_KO_RANBU_D
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Robert_SetMove
; =============== MoveInit_Robert_HaohShokohKen ===============
MoveInit_Robert_HaohShokohKen:
	mMvIn_ValidateProjActive Robert
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetSD MOVE_ROBERT_HAOH_SHOKOH_KEN_S, MOVE_ROBERT_HAOH_SHOKOH_KEN_D
	call MoveInputS_SetSpecMove_StopSpeed
	call Play_Proj_CopyMoveDamageFromPl
	jp   MoveInputReader_Robert_SetMove
; =============== MoveInputReader_Robert_SetMove ===============
MoveInputReader_Robert_SetMove:
	scf
	ret
; =============== MoveInputReader_Robert_NoMove ===============
MoveInputReader_Robert_NoMove:
	or   a
	ret
L025FBB:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L026025
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $04
	jp   z, L025FDB
	cp   $08
	jp   z, L025FFB
	cp   $24
	jp   z, L026016
	jp   L026022
L025FDB:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L025FED
	call MoveInputS_CheckMoveLHVer
	jp   z, L025FED
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
L025FED:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L026022
	ld   a, $16
	call HomeCall_Sound_ReqPlayExId
	jp   L026022
L025FFB:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L02600D
	call MoveInputS_CheckMoveLHVer
	jp   z, L02600D
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
L02600D:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L026022
	jp   L026022
L026016:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L026022
	call Play_Pl_EndMove
	jp   L026025
L026022:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L026025:;J
	ret
L026026:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L026103
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L026057
	cp   $04
	jp   z, L026063
	cp   $08
	jp   z, L0260A4
	cp   $0C
	jp   z, L0260BA
	cp   $10
	jp   z, L0260BD
	cp   $14
	jp   z, L0260D3
	cp   $18
	jp   z, L0260F5
L026057:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L026100
	inc  hl
	ld   [hl], $00
	jp   L026100
L026063:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L0260A1
	ld   a, $11
	call HomeCall_Sound_ReqPlayExId
	call MoveInputS_CheckMoveLHVer
	jp   c, L026095
	jp   nz, L026086
	ld   hl, $0300
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FE80
	call Play_OBJLstS_SetSpeedV
	jp   L0260A1
L026086:;J
	ld   hl, $0400
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, OAM_Begin
	call Play_OBJLstS_SetSpeedV
	jp   L0260A1
L026095:;J
	ld   hl, $0500
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FDC0
	call Play_OBJLstS_SetSpeedV
L0260A1:;J
	jp   L0260E2
L0260A4:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0260E2
	ld   hl, $0404
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	ld   a, $11
	call HomeCall_Sound_ReqPlayExId
	jp   L0260E2
L0260BA:;J
	jp   L0260E2
L0260BD:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0260E2
	ld   hl, $0403
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	ld   a, $11
	call HomeCall_Sound_ReqPlayExId
	jp   L0260E2
L0260D3:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0260E2
	ld   hl, $0013
	add  hl, de
	ld   [hl], $04
	jp   L0260E2
L0260E2:;J
	ld   hl, $0018
	call OBJLstS_ApplyGravity
	jp   nc, L026100
	ld   a, $18
	ld   h, $08
	call Play_Pl_SetJumpLandAnimFrame
	jp   L026103
L0260F5:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L026100
	call Play_Pl_EndMove
	jr   L026103
L026100:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L026103:;JR
	ret
L026104:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L02623E
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L026147
	cp   $04
	jp   z, L026153
	cp   $08
	jp   z, L026230
L026121: db $FE;X
L026122: db $0C;X
L026123: db $CA;X
L026124: db $D9;X
L026125: db $61;X
L026126: db $FE;X
L026127: db $10;X
L026128: db $CA;X
L026129: db $F5;X
L02612A: db $61;X
L02612B: db $FE;X
L02612C: db $14;X
L02612D: db $CA;X
L02612E: db $FF;X
L02612F: db $61;X
L026130: db $FE;X
L026131: db $18;X
L026132: db $CA;X
L026133: db $09;X
L026134: db $62;X
L026135: db $FE;X
L026136: db $1C;X
L026137: db $CA;X
L026138: db $13;X
L026139: db $62;X
L02613A: db $FE;X
L02613B: db $20;X
L02613C: db $CA;X
L02613D: db $1D;X
L02613E: db $62;X
L02613F: db $FE;X
L026140: db $24;X
L026141: db $CA;X
L026142: db $30;X
L026143: db $62;X
L026144: db $C3;X
L026145: db $3B;X
L026146: db $62;X
L026147:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L02623B
	inc  hl
	ld   [hl], $FF
	jp   L02623B
L026153:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L026194
	ld   a, $11
	call HomeCall_Sound_ReqPlayExId
	call MoveInputS_CheckMoveLHVer
	jp   c, L026185
	jp   nz, L026176
	ld   hl, $0300
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $0200
	call Play_OBJLstS_SetSpeedV
	jp   L026191
L026176:;J
	ld   hl, $0500
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $0180
	call Play_OBJLstS_SetSpeedV
	jp   L026191
L026185: db $21;X
L026186: db $00;X
L026187: db $07;X
L026188: db $CD;X
L026189: db $69;X
L02618A: db $35;X
L02618B: db $21;X
L02618C: db $00;X
L02618D: db $00;X
L02618E: db $CD;X
L02618F: db $AD;X
L026190: db $35;X
L026191:;J
	jp   L0261C6
L026194:;J
	ld   hl, $0063
	add  hl, bc
	bit  1, [hl]
	jp   z, L0261C3
	ld   hl, $006E
	add  hl, bc
	bit  7, [hl]
	jp   nz, L0261C3
	bit  4, [hl]
	jp   z, L0261C3
L0261AB: db $CB;X
L0261AC: db $5E;X
L0261AD: db $CA;X
L0261AE: db $C3;X
L0261AF: db $61;X
L0261B0: db $3E;X
L0261B1: db $0C;X
L0261B2: db $26;X
L0261B3: db $FF;X
L0261B4: db $CD;X
L0261B5: db $49;X
L0261B6: db $2E;X
L0261B7: db $21;X
L0261B8: db $00;X
L0261B9: db $00;X
L0261BA: db $CD;X
L0261BB: db $69;X
L0261BC: db $35
L0261BD: db $21
L0261BE: db $00
L0261BF: db $00
L0261C0: db $CD;X
L0261C1: db $AD;X
L0261C2: db $35;X
L0261C3:;J
	jp   L0261C6
L0261C6:;J
	ld   hl, $0018
	call OBJLstS_ApplyGravity
	jp   nc, L02623B
	ld   a, $08
	ld   h, $08
	call Play_Pl_SetJumpLandAnimFrame
	jp   L02623E
L0261D9: db $CD;X
L0261DA: db $D2;X
L0261DB: db $2D;X
L0261DC: db $CA;X
L0261DD: db $EB;X
L0261DE: db $61;X
L0261DF: db $21;X
L0261E0: db $00;X
L0261E1: db $FD;X
L0261E2: db $CD;X
L0261E3: db $69;X
L0261E4: db $35;X
L0261E5: db $21;X
L0261E6: db $00;X
L0261E7: db $FA;X
L0261E8: db $CD;X
L0261E9: db $AD;X
L0261EA: db $35;X
L0261EB: db $3E;X
L0261EC: db $F8;X
L0261ED: db $26;X
L0261EE: db $FF;X
L0261EF: db $CD;X
L0261F0: db $63;X
L0261F1: db $2E;X
L0261F2: db $C3;X
L0261F3: db $1D;X
L0261F4: db $62;X
L0261F5: db $3E;X
L0261F6: db $FB;X
L0261F7: db $26;X
L0261F8: db $FF;X
L0261F9: db $CD;X
L0261FA: db $63;X
L0261FB: db $2E;X
L0261FC: db $C3;X
L0261FD: db $1D;X
L0261FE: db $62;X
L0261FF: db $3E;X
L026200: db $FD;X
L026201: db $26;X
L026202: db $FF;X
L026203: db $CD;X
L026204: db $63;X
L026205: db $2E;X
L026206: db $C3;X
L026207: db $1D;X
L026208: db $62;X
L026209: db $3E;X
L02620A: db $FF;X
L02620B: db $26;X
L02620C: db $FF;X
L02620D: db $CD;X
L02620E: db $63;X
L02620F: db $2E;X
L026210: db $C3;X
L026211: db $1D;X
L026212: db $62;X
L026213: db $3E;X
L026214: db $00;X
L026215: db $26;X
L026216: db $FF;X
L026217: db $CD;X
L026218: db $63;X
L026219: db $2E;X
L02621A: db $C3;X
L02621B: db $1D;X
L02621C: db $62;X
L02621D: db $21;X
L02621E: db $60;X
L02621F: db $00;X
L026220: db $CD;X
L026221: db $14;X
L026222: db $36;X
L026223: db $D2;X
L026224: db $3B;X
L026225: db $62;X
L026226: db $3E;X
L026227: db $24;X
L026228: db $26;X
L026229: db $04;X
L02622A: db $CD;X
L02622B: db $EC;X
L02622C: db $2D;X
L02622D: db $C3;X
L02622E: db $3E;X
L02622F: db $62;X
L026230:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L02623B
	call Play_Pl_EndMove
	jr   L02623E
L02623B:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L02623E:;JR
	ret
L02623F:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L026330
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L02632D
	cp   $04
	jp   z, L02626B
	cp   $08
	jp   z, L0262A3
	cp   $0C
	jp   z, L0262F9
	cp   $10
	jp   z, L026309
	cp   $14
	jp   z, L026322
L02626B:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L02632D
	inc  hl
	ld   [hl], $FF
	ld   a, $A8
	call HomeCall_Sound_ReqPlayExId
	call MoveInputS_CheckMoveLHVer
	jp   c, L026298
	jp   nz, L02628D
	ld   hl, $0608
	ld   a, $01
	call Play_Pl_SetMoveDamageNext
	jp   L02632D
L02628D:;J
	ld   hl, $0608
	ld   a, $01
	call Play_Pl_SetMoveDamageNext
	jp   L02632D
L026298:;J
	ld   hl, $0608
	ld   a, $11
	call Play_Pl_SetMoveDamageNext
	jp   L02632D
L0262A3:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L0262EC
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
	ld   hl, $0020
	add  hl, bc
	inc  hl
	res  7, [hl]
	call MoveInputS_CheckMoveLHVer
	jp   c, L0262DD
	jp   nz, L0262CE
	ld   hl, $0080
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FA00
	call Play_OBJLstS_SetSpeedV
	jp   L0262E9
L0262CE:;J
	ld   hl, $0100
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $F900
	call Play_OBJLstS_SetSpeedV
	jp   L0262E9
L0262DD:;J
	ld   hl, $0200
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $F800
	call Play_OBJLstS_SetSpeedV
L0262E9:;J
	jp   L02630F
L0262EC:;J
	ld   a, $FA
	ld   h, $FF
	call OBJLstS_ReqAnimOnGtYSpeed
	jp   nc, L02630F
	jp   L02630F
L0262F9:;J
	ld   hl, $0040
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   a, $01
	ld   h, $FF
	call OBJLstS_ReqAnimOnGtYSpeed
	jp   L02630F
L026309:;J
	ld   hl, $0040
	call Play_OBJLstS_SetSpeedH_ByXFlipR
L02630F:;J
	ld   hl, $0060
	call OBJLstS_ApplyGravity
	jp   nc, L02632D
	ld   a, $14
	ld   h, $03
	call Play_Pl_SetJumpLandAnimFrame
	jp   L026330
L026322:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L02632D
	call Play_Pl_EndMove
	jr   L026330
L02632D:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L026330:;JR
	ret
L026331:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L026452
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L026367
	cp   $04
	jp   z, L026380
	cp   $08
	jp   z, L0263D6
	cp   $0C
	jp   z, L0263D6
	cp   $10
	jp   z, L0263F7
	cp   $14
	jp   z, L02641B
	cp   $18
	jp   z, L02642B
	cp   $1C
	jp   z, L026444
L026367:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L02644F
	inc  hl
	ld   [hl], $00
	ld   a, $A8
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0208
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	jp   L02644F
L026380:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L0263CB
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
	ld   hl, $0020
	add  hl, bc
	inc  hl
	res  7, [hl]
	res  3, [hl]
	call MoveInputS_CheckMoveLHVer
	jp   c, L0263BC
	jp   nz, L0263AD
	ld   hl, $0080
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FA00
	call Play_OBJLstS_SetSpeedV
	jp   L0263C8
L0263AD:;J
	ld   hl, $0100
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $F900
	call Play_OBJLstS_SetSpeedV
	jp   L0263C8
L0263BC:;J
	ld   hl, $01C0
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $F800
	call Play_OBJLstS_SetSpeedV
L0263C8:;J
	jp   L026431
L0263CB:;J
	ld   hl, $0208
	ld   a, $10
	call Play_Pl_SetMoveDamage
	jp   L026431
L0263D6:;J
	ld   hl, $0208
	ld   a, $10
	call Play_Pl_SetMoveDamage
	call OBJLstS_IsFrameEnd
	jp   nc, L026431
	ld   a, $FD
	ld   h, $FF
	call OBJLstS_ReqAnimOnGtYSpeed
	jp   nc, L026431
	ld   hl, $0013
	add  hl, de
	ld   [hl], $10
	jp   L026431
L0263F7:;J
	ld   hl, $0208
	ld   a, $10
	call Play_Pl_SetMoveDamage
	call OBJLstS_IsFrameEnd
	jp   nc, L026431
	ld   a, $FD
	ld   h, $FF
	call OBJLstS_ReqAnimOnGtYSpeed
	jp   nc, L026412
	jp   L026431
L026412:;J
	ld   hl, $0013
	add  hl, de
	ld   [hl], $04
	jp   L026431
L02641B:;J
	ld   hl, $0040
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   a, $00
	ld   h, $FF
	call OBJLstS_ReqAnimOnGtYSpeed
	jp   L026431
L02642B:;J
	ld   hl, $0040
	call Play_OBJLstS_SetSpeedH_ByXFlipR
L026431:;J
	ld   hl, $0060
	call OBJLstS_ApplyGravity
	jp   nc, L02644F
	ld   a, $1C
	ld   h, $08
	call Play_Pl_SetJumpLandAnimFrame
	jp   L026452
L026444:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L02644F
	call Play_Pl_EndMove
	jr   L026452
L02644F:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L026452:;JR
	ret
L026453:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L0264EC
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $04
	jp   z, L026478
	cp   $0C
	jp   z, L02649A
	cp   $14
	jp   z, L0264BC
	cp   $1C
	jp   z, L0264DE
	jp   L0264E9
L026478:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L026484
	ld   hl, $0400
	call Play_OBJLstS_MoveH_ByXFlipR
L026484:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0264E9
	ld   hl, $0403
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	ld   a, $09
	call HomeCall_Sound_ReqPlayExId
	jp   L0264E9
L02649A:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L0264A6
	ld   hl, $0200
	call Play_OBJLstS_MoveH_ByXFlipR
L0264A6:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0264E9
	ld   hl, $0404
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	ld   a, $09
	call HomeCall_Sound_ReqPlayExId
	jp   L0264E9
L0264BC:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L0264C8
	ld   hl, $0600
	call Play_OBJLstS_MoveH_ByXFlipR
L0264C8:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0264E9
	ld   hl, $0408
	ld   a, $11
	call Play_Pl_SetMoveDamageNext
	ld   a, $09
	call HomeCall_Sound_ReqPlayExId
	jp   L0264E9
L0264DE:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0264E9
	call Play_Pl_EndMove
	jr   L0264EC
L0264E9:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L0264EC:;JR
	ret
L0264ED:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L026654
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L02653A
	cp   $04
	jp   z, L02654C
	cp   $08
	jp   z, L0265D2
	cp   $0C
	jp   z, L0265BE
	cp   $14
	jp   z, L0265BE
	cp   $1C
	jp   z, L0265BE
	cp   $24
	jp   z, L0265BE
	cp   $2C
	jp   z, L0265BE
	cp   $34
	jp   z, L0265BE
	cp   $3C
	jp   z, L0265BE
	cp   $40
	jp   z, L026611
	cp   $44
	jp   z, L026645
	jp   L0265E9
L02653A:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L026540
L026540:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L026651
	inc  hl
	ld   [hl], $FF
	jp   L026651
L02654C:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L02657B
	ld   a, $11
	call HomeCall_Sound_ReqPlayExId
	call MoveInputS_CheckMoveLHVer
	jp   nz, L02656C
	ld   hl, $05FF
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, OAM_Begin
	call Play_OBJLstS_SetSpeedV
	jp   L026632
L02656C:;J
	ld   hl, $06FF
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FD80
	call Play_OBJLstS_SetSpeedV
	jp   L026632
L02657B:;J
	ld   hl, $0063
	add  hl, bc
	bit  1, [hl]
	jp   z, L0265BB
	ld   hl, $006E
	add  hl, bc
	bit  7, [hl]
	jp   nz, L0265BB
	bit  4, [hl]
	jp   z, L0265BB
	bit  3, [hl]
	jp   nz, L0265B5
	ld   hl, $010A
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	ld   a, $08
	ld   h, $01
	call L002E49
	ld   hl, $0000
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $0005
	add  hl, de
	ld   [hl], $88
	jp   L026654
L0265B5:;J
	ld   hl, $0100
	call Play_OBJLstS_SetSpeedH_ByXFlipR
L0265BB:;J
	jp   L026632
L0265BE:;J
	call OBJLstS_ApplyXSpeed
	call OBJLstS_IsFrameNewLoad
	jp   z, L026651
	ld   hl, $010A
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	jp   L0265FA
L0265D2:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L026651
	ld   hl, $0109
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	ld   hl, $0080
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	jp   L026651
L0265E9:;J
	call OBJLstS_ApplyXSpeed
	call OBJLstS_IsFrameNewLoad
	jp   z, L026651
	ld   hl, $0109
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
L0265FA:;J
	ld   hl, $0073
	add  hl, bc
	ld   a, [hl]
	cp   $09
	jp   z, L026651
	cp   $0A
	jp   z, L026651
L026609: db $3E;X
L02660A: db $18;X
L02660B: db $CD;X
L02660C: db $1B;X
L02660D: db $34;X
L02660E: db $C3;X
L02660F: db $54;X
L026610: db $66;X
L026611:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L026651
	call MoveInputS_CheckMoveLHVer
	jp   nz, L026622
	ld   a, $54
	jp   L026624
L026622:;J
	ld   a, $56
L026624:;J
	call MoveInputS_SetSpecMove_StopSpeed
	ld   hl, $0608
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	jp   L026654
L026632:;J
	ld   hl, $0030
	call OBJLstS_ApplyGravity
	jp   nc, L026651
	ld   a, $44
	ld   h, $07
	call Play_Pl_SetJumpLandAnimFrame
	jp   L026654
L026645:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L026651
	call Play_Pl_EndMove
	jp   L026654
L026651:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L026654:;J
	ret
L026655:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L0267E4
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L0266CA
	cp   $04
	jp   z, L0266DC
	cp   $08
	jp   z, L026762
	cp   $0C
	jp   z, L02674E
	cp   $14
	jp   z, L02674E
	cp   $1C
	jp   z, L02674E
	cp   $24
	jp   z, L02674E
	cp   $2C
	jp   z, L02674E
	cp   $34
	jp   z, L02674E
	cp   $3C
	jp   z, L02674E
	cp   $44
	jp   z, L02674E
	cp   $4C
	jp   z, L02674E
	cp   $54
	jp   z, L02674E
	cp   $5C
	jp   z, L02674E
	cp   $64
	jp   z, L02674E
	cp   $6C
	jp   z, L02674E
	cp   $74
	jp   z, L02674E
	cp   $7C
	jp   z, L02674E
	cp   $80
	jp   z, L0267A1
	cp   $84
	jp   z, L0267D5
	jp   L026779
L0266CA:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L0266D0
L0266D0:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0267E1
	inc  hl
	ld   [hl], $FF
	jp   L0267E1
L0266DC:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L02670B
	ld   a, $11
	call HomeCall_Sound_ReqPlayExId
	call MoveInputS_CheckMoveLHVer
	jp   nz, L0266FC
	ld   hl, $05FF
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, OAM_Begin
	call Play_OBJLstS_SetSpeedV
	jp   L0267C2
L0266FC:;J
	ld   hl, $06FF
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FD80
	call Play_OBJLstS_SetSpeedV
	jp   L0267C2
L02670B:;J
	ld   hl, $0063
	add  hl, bc
	bit  1, [hl]
	jp   z, L02674B
	ld   hl, $006E
	add  hl, bc
	bit  7, [hl]
	jp   nz, L02674B
	bit  4, [hl]
	jp   z, L02674B
	bit  3, [hl]
	jp   nz, L026745
	ld   hl, $010A
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	ld   a, $08
	ld   h, $01
	call L002E49
	ld   hl, $0000
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $0005
	add  hl, de
	ld   [hl], $88
	jp   L0267E4
L026745:;J
	ld   hl, $0100
	call Play_OBJLstS_SetSpeedH_ByXFlipR
L02674B:;J
	jp   L0267C2
L02674E:;J
	call OBJLstS_ApplyXSpeed
	call OBJLstS_IsFrameNewLoad
	jp   z, L0267E1
	ld   hl, $010A
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	jp   L02678A
L026762:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L0267E1
	ld   hl, $0109
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	ld   hl, $0080
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	jp   L0267E1
L026779:;J
	call OBJLstS_ApplyXSpeed
	call OBJLstS_IsFrameNewLoad
	jp   z, L0267E1
	ld   hl, $0109
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
L02678A:;J
	ld   hl, $0073
	add  hl, bc
	ld   a, [hl]
	cp   $09
	jp   z, L0267E1
	cp   $0A
	jp   z, L0267E1
	ld   a, $18
	call Pl_Unk_SetNewMoveAndAnim_StopSpeed
	jp   L0267E4
L0267A1:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0267E1
	call MoveInputS_CheckMoveLHVer
	jp   nz, L0267B2
	ld   a, $5C
	jp   L0267B4
L0267B2:;J
	ld   a, $5E
L0267B4:;J
	call MoveInputS_SetSpecMove_StopSpeed
	ld   hl, $0208
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	jp   L0267E4
L0267C2:;J
	ld   hl, $0030
	call OBJLstS_ApplyGravity
	jp   nc, L0267E1
	ld   a, $84
	ld   h, $07
	call Play_Pl_SetJumpLandAnimFrame
	jp   L0267E4
L0267D5:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0267E1
	call Play_Pl_EndMove
	jp   L0267E4
L0267E1:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L0267E4:;J
	ret
L0267E5:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L026845
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $08
	jp   z, L026805
	cp   $0C
	jp   z, L026811
	cp   $10
	jp   z, L026836
	jp   L026842
L026805:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L026842
	inc  hl
	ld   [hl], $1E
	jp   L026842
L026811:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L02682A
	ld   hl, $0033
	add  hl, bc
	ld   a, [hl]
	cp   $6A
	jp   z, L026827
	call L0026F4
	jp   L02682A
L026827:;J
	call L00272D
L02682A:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L026842
	inc  hl
	ld   [hl], $04
	jp   L026842
L026836:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L026842
	call Play_Pl_EndMove
	jp   L026845
L026842:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L026845:;J
	ret
; =============== MoveInputReader_Leona ===============
; Special move input checker for LEONA and OLEONA.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
; OUT
; - C flag: If set, a move was started
MoveInputReader_Leona:
	mMvIn_Validate Leona
.chkAir:
	;             SELECT + B               SELECT + A
	mMvIn_ChkEasy MoveInit_Leona_VSlasher, MoveInit_Leona_BalticLauncher
	mMvIn_ChkGA Leona, .chkAirPunch, .chkAirKick
.chkAirPunch:
	; DFDB+P (air) -> V Slasher
	mMvIn_ValidateSuper .chkAirPunchNoSuper
	mMvIn_ChkDir MoveInput_DFDB, MoveInit_Leona_VSlasher
.chkAirPunchNoSuper:
	jp   MoveInputReader_Leona_NoMove
.chkAirKick:
	jp   MoveInputReader_Leona_NoMove
	
.chkGround:
	;             SELECT + B               SELECT + A
	mMvIn_ChkEasy MoveInit_Leona_VSlasher, MoveInit_Leona_BalticLauncher
	mMvIn_ChkGA Leona, .chkPunch, .chkKick
.chkPunch:
	; O.Leona only!
	mMvIn_ValSkipWithChar CHAR_ID_LEONA, .chkPunchNorm
	;##
	; DFDB+P -> Super Moon Slasher
	mMvIn_ValidateSuper .chkPunchNoSuper
	mMvIn_ChkDir MoveInput_DFDB, MoveInit_OLeona_SuperMoonSlasher
.chkPunchNoSuper:
	; FDB+P -> Storm Bringer
	mMvIn_ChkDir MoveInput_FDB, MoveInit_OLeona_StormBringer
	;##
.chkPunchNorm:
	; DU+P -> Moon Slasher
	mMvIn_ChkDir MoveInput_DU_Slow, MoveInit_Leona_MoonSlasher
	; BF+P -> Baltic Launcher
	mMvIn_ChkDir MoveInput_BF_Slow, MoveInit_Leona_BalticLauncher
	jp   MoveInputReader_Leona_NoMove
.chkKick:
	; DU+K -> X-Calibur
	mMvIn_ChkDir MoveInput_DU_Slow, MoveInit_Leona_XCalibur
	; BF+K -> Grand Sabre
	mMvIn_ChkDir MoveInput_BF_Slow, MoveInit_Leona_GrandSabre
	jp   MoveInputReader_Leona_NoMove
; =============== MoveInit_Leona_BalticLauncher ===============
MoveInit_Leona_BalticLauncher:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_LEONA_BALTIC_LAUNCHER_L, MOVE_LEONA_BALTIC_LAUNCHER_H
	call MoveInputS_SetSpecMove_StopSpeed
	call Play_Proj_CopyMoveDamageFromPl
	jp   MoveInputReader_Leona_SetMove
; =============== MoveInit_Leona_GrandSabre ===============
MoveInit_Leona_GrandSabre:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_LEONA_GRAND_SABRE_L, MOVE_LEONA_GRAND_SABRE_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Leona_SetMove
; =============== MoveInit_Leona_XCalibur ===============
MoveInit_Leona_XCalibur:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_LEONA_X_CALIBUR_L, MOVE_LEONA_X_CALIBUR_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Leona_SetMove
; =============== MoveInit_Leona_MoonSlasher ===============
MoveInit_Leona_MoonSlasher:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_LEONA_MOON_SLASHER_L, MOVE_LEONA_MOON_SLASHER_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Leona_SetMove
; =============== MoveInit_OLeona_StormBringer ===============
MoveInit_OLeona_StormBringer:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_ValStartCmdThrow04 Leona
	mMvIn_GetLH MOVE_OLEONA_STORM_BRINGER_L, MOVE_OLEONA_STORM_BRINGER_H
	call MoveInputS_SetSpecMove_StopSpeed
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_INVULN, [hl]
	jp   MoveInputReader_Leona_SetMove
; =============== MoveInit_Leona_VSlasher ===============
MoveInit_Leona_VSlasher:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetSD MOVE_LEONA_V_SLASHER_S, MOVE_LEONA_V_SLASHER_D
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Leona_SetMove
; =============== MoveInit_OLeona_SuperMoonSlasher ===============
MoveInit_OLeona_SuperMoonSlasher:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetSD MOVE_OLEONA_SUPER_MOON_SLASHER_S, MOVE_OLEONA_SUPER_MOON_SLASHER_D
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Leona_SetMove
; =============== MoveInputReader_Leona_SetMove ===============
MoveInputReader_Leona_SetMove:
	scf
	ret
; =============== MoveInputReader_Leona_NoMove ===============
MoveInputReader_Leona_NoMove:
	or   a
	ret
L026990:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L0269E2
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L0269B0
	cp   $08
	jp   z, L0269BC
	cp   $14
	jp   z, L0269D4
	jp   L0269DF
L0269B0:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0269DF
	inc  hl
	ld   [hl], $00
	jp   L0269DF
L0269BC:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L0269C8
	call L00253E
	jp   L0269DF
L0269C8:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0269DF
L0269CE: db $23;X
L0269CF: db $36;X
L0269D0: db $00;X
L0269D1: db $C3;X
L0269D2: db $DF;X
L0269D3: db $69;X
L0269D4:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0269DF
	call Play_Pl_EndMove
	jr   L0269E2
L0269DF:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L0269E2:;JR
	ret
L0269E3:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L026A73
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L026A08
	cp   $04
	jp   z, L026A14
	cp   $08
	jp   z, L026A52
	cp   $0C
	jp   z, L026A65
L026A05: db $C3;X
L026A06: db $70;X
L026A07: db $6A;X
L026A08:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L026A70
	inc  hl
	ld   [hl], $FF
	jp   L026A70
L026A14:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L026A45
	call L00253E
	ld   hl, $0050
	add  hl, bc
	ld   a, [hl]
	cp   $28
	jp   z, L026A36
	ld   hl, $0100
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FC00
	call Play_OBJLstS_SetSpeedV
	jp   L026A52
L026A36:;J
	ld   hl, $0200
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FC00
	call Play_OBJLstS_SetSpeedV
	jp   L026A52
L026A45:;J
	ld   a, $FE
	ld   h, $FF
	call OBJLstS_ReqAnimOnGtYSpeed
	jp   nc, L026A52
	jp   L026A52
L026A52:;J
	ld   hl, $0060
	call OBJLstS_ApplyGravity
	jp   nc, L026A70
	ld   a, $0C
	ld   h, $08
	call Play_Pl_SetJumpLandAnimFrame
	jp   L026A73
L026A65:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L026A70
	call Play_Pl_EndMove
	jr   L026A73
L026A70:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L026A73:;JR
	ret
L026A74:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L026C1E
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L026AD5
	cp   $04
	jp   z, L026AE1
	cp   $08
	jp   z, L026B13
	cp   $0C
	jp   z, L026B13
	cp   $10
	jp   z, L026B13
	cp   $14
	jp   z, L026B38
	cp   $18
	jp   z, L026B61
	cp   $1C
	jp   z, L026B61
	cp   $20
	jp   z, L026B61
	cp   $24
	jp   z, L026B6A
	cp   $28
	jp   z, L026BA6
	cp   $2C
	jp   z, L026BDE
	cp   $30
	jp   z, L026BE8
	cp   $34
	jp   z, L026BF2
	cp   $38
	jp   z, L026BFC
	cp   $3C
	jp   z, L026C0F
L026AD2: db $C3;X
L026AD3: db $1B;X
L026AD4: db $6C;X
L026AD5:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L026B44
	inc  hl
	ld   [hl], $01
	jp   L026B44
L026AE1:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L026B10
	ld   a, $9D
	call HomeCall_Sound_ReqPlayExId
	call MoveInputS_CheckMoveLHVer
	jp   c, L026B07
	jp   nz, L026AFE
	ld   hl, $0400
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	jp   L026B5B
L026AFE:;J
	ld   hl, $0500
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	jp   L026B5B
L026B07:;J
	ld   hl, $0600
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	jp   L026B5B
L026B10:;J
	jp   L026B44
L026B13:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L026B44
	ld   a, $9D
	call HomeCall_Sound_ReqPlayExId
	jp   L026B44
L026B21: db $CD;X
L026B22: db $D2;X
L026B23: db $2D;X
L026B24: db $CA;X
L026B25: db $2C;X
L026B26: db $6B;X
L026B27: db $3E;X
L026B28: db $9D;X
L026B29: db $CD;X
L026B2A: db $16;X
L026B2B: db $10;X
L026B2C: db $CD;X
L026B2D: db $D9;X
L026B2E: db $2D;X
L026B2F: db $D2;X
L026B30: db $44;X
L026B31: db $6B;X
L026B32: db $23;X
L026B33: db $36;X
L026B34: db $FF;X
L026B35: db $C3;X
L026B36: db $5B;X
L026B37: db $6B;X
L026B38:;J
	ld   hl, $0100
	call L0035D9
	jp   nc, L026C1E
	jp   L026C15
L026B44:;J
	ld   hl, $0061
	add  hl, bc
	ld   a, [hl]
	cp   $20
	jp   nc, L026B5B
	ld   a, $18
	ld   h, $01
	call L002E49
	call OBJLstS_ApplyXSpeed
	jp   L026C1E
L026B5B:;J
	call OBJLstS_ApplyXSpeed
	jp   L026C1B
L026B61:;J
	ld   hl, $0080
	call L0035D9
	jp   L026B79
L026B6A:;J
	ld   hl, $0080
	call L0035D9
	call OBJLstS_IsFrameEnd
	jp   nc, L026C1B
	jp   L026C15
L026B79:;J
	ld   hl, $0063
	add  hl, bc
	bit  1, [hl]
	jp   z, L026C1B
	ld   hl, $006E
	add  hl, bc
	bit  7, [hl]
	jp   nz, L026C1B
	call MoveInputS_CheckGAType
	jp   nc, L026C1B
	jp   z, L026C1B
	ld   hl, $0808
	ld   a, $01
	call Play_Pl_SetMoveDamageNext
	ld   a, $28
	ld   h, $FF
	call L002E49
	jp   L026C1E
L026BA6:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L026BD4
	ld   hl, $0050
	add  hl, bc
	ld   a, [hl]
	cp   $28
	jp   z, L026BC5
	ld   hl, $0100
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FB00
	call Play_OBJLstS_SetSpeedV
	jp   L026BFC
L026BC5:;J
	ld   hl, $0200
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FA80
	call Play_OBJLstS_SetSpeedV
	jp   L026BFC
L026BD4:;J
	ld   a, $FC
	ld   h, $FF
	call OBJLstS_ReqAnimOnGtYSpeed
	jp   L026BFC
L026BDE:;J
	ld   a, $FE
	ld   h, $FF
	call OBJLstS_ReqAnimOnGtYSpeed
	jp   L026BFC
L026BE8:;J
	ld   a, $FF
	ld   h, $FF
	call OBJLstS_ReqAnimOnGtYSpeed
	jp   L026BFC
L026BF2:;J
	ld   a, $00
	ld   h, $FF
	call OBJLstS_ReqAnimOnGtYSpeed
	jp   L026BFC
L026BFC:;J
	ld   hl, $0060
	call OBJLstS_ApplyGravity
	jp   nc, L026C1B
	ld   a, $3C
	ld   h, $08
	call Play_Pl_SetJumpLandAnimFrame
	jp   L026C1E
L026C0F:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L026C1B
L026C15:;J
	call Play_Pl_EndMove
	jp   L026C1E
L026C1B:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L026C1E:;J
	ret
L026C1F:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L026D25
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L026C55
	cp   $04
	jp   z, L026C72
	cp   $08
	jp   z, L026CAF
	cp   $0C
	jp   z, L026CB9
	cp   $10
	jp   z, L026CC3
	cp   $14
	jp   z, L026CD7
	cp   $18
	jp   z, L026D0A
	cp   $1C
	jp   z, L026D16
L026C55:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L026D22
	inc  hl
	ld   [hl], $FF
	call MoveInputS_CheckMoveLHVer
	jp   c, L026C67
	jp   L026C6F
L026C67:;J
	ld   hl, $0208
	ld   a, $92
	call Play_Pl_SetMoveDamageNext
L026C6F:;J
	jp   L026D22
L026C72:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L026CA5
	ld   hl, $F900
	call Play_OBJLstS_SetSpeedV
	ld   hl, $0061
	add  hl, bc
	ld   a, [hl]
	ld   h, $26
	cp   a, h
	jp   nc, L026C93
	sla  a
	sla  a
	ld   l, a
	ld   h, $00
	jp   L026C9F
L026C93:;J
	srl  a
	srl  a
	srl  a
	srl  a
	srl  a
	ld   h, a
	ld   l, a
L026C9F:;J
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	jp   L026CF7
L026CA5:;J
	ld   a, $F6
	ld   h, $FF
	call OBJLstS_ReqAnimOnGtYSpeed
	jp   L026CF7
L026CAF:;J
	ld   a, $FA
	ld   h, $FF
	call OBJLstS_ReqAnimOnGtYSpeed
	jp   L026CF7
L026CB9:;J
	ld   a, $FD
	ld   h, $00
	call OBJLstS_ReqAnimOnGtYSpeed
	jp   L026CF7
L026CC3:;J
	call MoveInputS_CheckMoveLHVer
	jp   c, L026CCC
	jp   L026CF7
L026CCC:;J
	ld   hl, $0208
	ld   a, $92
	call Play_Pl_SetMoveDamage
	jp   L026CF7
L026CD7:;J
	call MoveInputS_CheckMoveLHVer
	jp   c, L026CE0
	jp   L026CE8
L026CE0:;J
	ld   hl, $0208
	ld   a, $92
	call Play_Pl_SetMoveDamage
L026CE8:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L026CF7
	ld   hl, $0013
	add  hl, de
	ld   [hl], $0C
	jp   L026CF7
L026CF7:;J
	ld   hl, $0060
	call OBJLstS_ApplyGravity
	jp   nc, L026D22
	ld   a, $18
	ld   h, $02
	call Play_Pl_SetJumpLandAnimFrame
	jp   L026D25
L026D0A:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L026D22
	inc  hl
	ld   [hl], $0A
	jp   L026D22
L026D16:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L026D22
	call Play_Pl_EndMove
	jp   L026D25
L026D22:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L026D25:;J
	ret
L026D26:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L026DC0
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L026D4D
	cp   $04
	jp   z, L026D70
	cp   $08
	jp   z, L026D7F
	cp   $0C
	jp   z, L026DA6
	cp   $10
	jp   z, L026DB2
L026D4D:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L026DBD
	inc  hl
	ld   [hl], $00
	ld   a, $A8
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0050
	add  hl, bc
	ld   a, [hl]
	cp   $28
	jp   nz, L026DBD
	ld   hl, $0808
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	jp   L026DBD
L026D70:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L026D7C
	ld   hl, $0400
	call Play_OBJLstS_MoveH_ByXFlipR
L026D7C:;J
	jp   L026D8B
L026D7F:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L026D8B
	ld   hl, $0400
	call Play_OBJLstS_MoveH_ByXFlipR
L026D8B:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L026DBD
	ld   hl, $0050
	add  hl, bc
	ld   a, [hl]
	cp   $28
	jp   nz, L026DBD
	ld   hl, $0808
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	jp   L026DBD
L026DA6:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L026DBD
	inc  hl
	ld   [hl], $08
	jp   L026DBD
L026DB2:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L026DBD
	call Play_Pl_EndMove
	jr   L026DC0
L026DBD:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L026DC0:;JR
	ret
L026DC1:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L026E6E
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L026DF0
	cp   $04
	jp   z, L026E0A
	cp   $08
	jp   z, L026E1B
	cp   $0C
	jp   z, L026E51
	cp   $10
	jp   z, L026E51
	cp   $14
	jp   z, L026E5A
L026DED: db $C3;X
L026DEE: db $6B;X
L026DEF: db $6E;X
L026DF0:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L026E6B
	inc  hl
	ld   [hl], $01
	ld   hl, $0083
	add  hl, bc
	ld   [hl], $08
	ld   hl, $0109
	ld   a, $C0
	call Play_Pl_SetMoveDamageNext
	jp   L026E6B
L026E0A:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L026E6B
	ld   hl, $010A
	ld   a, $C0
	call Play_Pl_SetMoveDamageNext
	jp   L026E43
L026E1B:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L026E6B
	ld   hl, $0083
	add  hl, bc
	dec  [hl]
	jp   z, L026E3A
	ld   hl, $0013
	add  hl, de
	ld   [hl], $00
	ld   hl, $0109
	ld   a, $C0
	call Play_Pl_SetMoveDamageNext
	jp   L026E43
L026E3A:;J
	ld   hl, $001C
	add  hl, de
	ld   [hl], $0A
	jp   L026E6B
L026E43:;J
	ld   hl, $004E
	add  hl, bc
	ld   a, [hl]
	cp   $48
	jp   z, L026E4E
	inc  [hl]
L026E4E:;J
	jp   L026E6B
L026E51:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L026E6B
	jp   L026E6B
L026E5A:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L026E6B
	call Play_Pl_EndMove
	ld   a, $00
	ld   [wPlayPlThrowActId], a
	jp   L026E6E
L026E6B:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L026E6E:;J
	ret
L026E6F:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L026FC3
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L026EA0
	cp   $04
	jp   z, L026EAC
	cp   $08
	jp   z, L026EEC
	cp   $0C
	jp   z, L026EEF
	cp   $10
	jp   z, L026F1B
	cp   $14
	jp   z, L026F9B
	cp   $18
	jp   z, L026FB4
L026EA0:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L026FC0
	inc  hl
	ld   [hl], $FF
	jp   L026FC0
L026EAC:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L026ED6
	call MoveInputS_CheckMoveLHVer
	jp   nz, L026EC7
	ld   hl, $0400
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $0400
	call Play_OBJLstS_SetSpeedV
	jp   L026F52
L026EC7:;J
	ld   hl, $0600
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $0400
	call Play_OBJLstS_SetSpeedV
	jp   L026F52
L026ED6:;J
	call L003745
	jp   nc, L026F52
	jp   nz, L026F52
	ld   a, $08
	ld   h, $FF
	call L002E49
	call Play_Pl_TempPauseOtherAnim
	jp   L026FC3
L026EEC:;J
	jp   L026F7B
L026EEF:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L026FC0
	inc  hl
	ld   [hl], $FF
	ld   hl, $002C
	add  hl, bc
	ld   a, [hl]
	cp   $10
	jp   nz, L026F0D
	ld   hl, $1408
	ld   a, $03
	call Play_Pl_SetMoveDamageNext
	jp   L026FC0
L026F0D:;J
	ld   hl, $020E
	ld   a, $03
	call Play_Pl_SetMoveDamageNext
	call Play_Proj_CopyMoveDamageFromPl
	jp   L026FC0
L026F1B:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L026F48
	call L0025D0
	call MoveInputS_CheckMoveLHVer
	jp   nz, L026F39
	ld   hl, $0300
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FB00
	call Play_OBJLstS_SetSpeedV
	jp   L026F9B
L026F39:;J
	ld   hl, $0400
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FB00
	call Play_OBJLstS_SetSpeedV
	jp   L026F9B
L026F48:;J
	ld   a, $FE
	ld   h, $FF
	call OBJLstS_ReqAnimOnGtYSpeed
	jp   L026F9B
L026F52:;J
	ld   hl, $0000
	call OBJLstS_ApplyGravity
	jp   nc, L026FC0
	call L003745
	jp   nc, L026F71
L026F61: db $C2;X
L026F62: db $71;X
L026F63: db $6F;X
L026F64: db $3E;X
L026F65: db $0C;X
L026F66: db $26;X
L026F67: db $02;X
L026F68: db $CD;X
L026F69: db $EC;X
L026F6A: db $2D;X
L026F6B: db $CD;X
L026F6C: db $77;X
L026F6D: db $3D;X
L026F6E: db $C3;X
L026F6F: db $C3;X
L026F70: db $6F;X
L026F71:;J
	ld   a, $18
	ld   h, $02
	call Play_Pl_SetJumpLandAnimFrame
	jp   L026FC3
L026F7B:;J
	ld   hl, $0005
	add  hl, de
	ld   a, [hl]
	ld   hl, $0081
	add  hl, bc
	cp   a, [hl]
	jp   nc, L026F91
	ld   hl, $0000
	call OBJLstS_ApplyGravity
	jp   nc, L026FC0
L026F91:;J
	ld   a, $0C
	ld   h, $02
	call Play_Pl_SetJumpLandAnimFrame
	jp   L026FC3
L026F9B:;J
	ld   hl, $0040
	call L0035D9
	ld   hl, $0060
	call OBJLstS_ApplyGravity
	jp   nc, L026FC0
	ld   a, $18
	ld   h, $02
	call Play_Pl_SetJumpLandAnimFrame
	jp   L026FC3
L026FB4:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L026FC0
	call Play_Pl_EndMove
	jp   L026FC3
L026FC0:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L026FC3:;J
	ret
L026FC4:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L027146
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $08
	jp   z, L02700C
	cp   $0C
	jp   z, L02701E
	cp   $10
	jp   z, L027060
	cp   $14
	jp   z, L027074
	cp   $18
	jp   z, L027088
	cp   $1C
	jp   z, L0270D2
	cp   $20
	jp   z, L0270F1
	cp   $24
	jp   z, L0270FB
	cp   $28
	jp   z, L027105
	cp   $2C
	jp   z, L02710F
	cp   $30
	jp   z, L027122
	jp   L027143
L02700C:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L027143
	inc  hl
	ld   [hl], $10
	ld   hl, $0083
	add  hl, bc
	ld   [hl], $08
	jp   L027143
L02701E:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L027030
	ld   hl, $0021
	add  hl, bc
	res  7, [hl]
	ld   hl, $0700
	call Play_OBJLstS_SetSpeedH_ByXFlipR
L027030:;J
	call L003745
	jp   nc, L027057
	jp   nz, L027051
	ld   a, $10
	ld   h, $00
	call L002E49
	ld   hl, $0080
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $0109
	ld   a, $C0
	call Play_Pl_SetMoveDamageNext
	jp   L027146
L027051:;J
	ld   hl, $0000
	call Play_OBJLstS_SetSpeedH_ByXFlipR
L027057:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L02712B
	jp   L02713D
L027060:;J
	call OBJLstS_ApplyXSpeed
	call OBJLstS_IsFrameEnd
	jp   nc, L027143
	ld   hl, $010A
	ld   a, $C0
	call Play_Pl_SetMoveDamageNext
	jp   L0270BB
L027074:;J
	call OBJLstS_ApplyXSpeed
	call OBJLstS_IsFrameEnd
	jp   nc, L027143
	ld   hl, $0109
	ld   a, $C0
	call Play_Pl_SetMoveDamageNext
	jp   L0270BB
L027088:;J
	call OBJLstS_ApplyXSpeed
	call OBJLstS_IsFrameEnd
	jp   nc, L027143
	ld   hl, $0083
	add  hl, bc
	dec  [hl]
	jp   z, L0270AA
	ld   hl, $0013
	add  hl, de
	ld   [hl], $0C
	ld   hl, $0109
	ld   a, $C0
	call Play_Pl_SetMoveDamageNext
	jp   L0270BB
L0270AA:;J
	ld   hl, $0C08
	ld   a, $41
	call Play_Pl_SetMoveDamageNext
	ld   hl, $001C
	add  hl, de
	ld   [hl], $FF
	jp   L027143
L0270BB:;J
	ld   hl, $0073
	add  hl, bc
	ld   a, [hl]
	cp   $09
	jp   z, L027143
	cp   $0A
	jp   z, L027143
L0270CA: db $3E;X
L0270CB: db $18;X
L0270CC: db $CD;X
L0270CD: db $1B;X
L0270CE: db $34;X
L0270CF: db $C3;X
L0270D0: db $46;X
L0270D1: db $71;X
L0270D2:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L0270E7
	ld   hl, $FD00
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FA80
	call Play_OBJLstS_SetSpeedV
	jp   L02710F
L0270E7:;J
	ld   a, $FC
	ld   h, $FF
	call OBJLstS_ReqAnimOnGtYSpeed
	jp   L02710F
L0270F1:;J
	ld   a, $FE
	ld   h, $FF
	call OBJLstS_ReqAnimOnGtYSpeed
	jp   L02710F
L0270FB:;J
	ld   a, $FF
	ld   h, $FF
	call OBJLstS_ReqAnimOnGtYSpeed
	jp   L02710F
L027105:;J
	ld   a, $00
	ld   h, $FF
	call OBJLstS_ReqAnimOnGtYSpeed
	jp   L02710F
L02710F:;J
	ld   hl, $0060
	call OBJLstS_ApplyGravity
	jp   nc, L027143
	ld   a, $30
	ld   h, $08
	call Play_Pl_SetJumpLandAnimFrame
	jp   L027146
L027122:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L027143
	jp   L02713D
L02712B:;J
	call OBJLstS_ApplyXSpeed
	jp   L027143
L027131: db $21;X
L027132: db $80;X
L027133: db $00;X
L027134: db $CD;X
L027135: db $D9;X
L027136: db $35;X
L027137: db $CD;X
L027138: db $D9;X
L027139: db $2D;X
L02713A: db $D2;X
L02713B: db $43;X
L02713C: db $71;X
L02713D:;J
	call Play_Pl_EndMove
	jp   L027146
L027143:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L027146:;J
	ret
L027147:;I
	ld   hl, $0028
	add  hl, de
	dec  [hl]
	jp   z, L02715F
	ld   hl, $0021
	add  hl, bc
	bit  4, [hl]
	jp   nz, L02715F
	call L0028B2
	call OBJLstS_DoAnimTiming_Loop_by_DE
	ret
L02715F:;J
	call OBJLstS_Hide
	ret
	
; =============== MoveInputReader_MrKarate ===============
; Special move input checker for MRKARATE.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
; OUT
; - C flag: If set, a move was started
MoveInputReader_MrKarate:
	mMvIn_Validate MrKarate
	
.chkAir:
	;             SELECT + B                    SELECT + A
	mMvIn_ChkEasy MoveInit_MrKarate_RyukoRanbu, MoveInit_MrKarate_HienShippuuKyaku
	mMvIn_ChkGA MrKarate, .chkAirPunch, .chkAirKick
.chkAirPunch:
.chkAirKick:
	jp   MoveInputReader_MrKarate_NoMove
	
.chkGround:
	;             SELECT + B                    SELECT + A
	mMvIn_ChkEasy MoveInit_MrKarate_RyukoRanbu, MoveInit_MrKarate_Zenretsuken
	mMvIn_ChkGA MrKarate, .chkPunch, .chkKick
.chkPunch:
	mMvIn_ValidateSuper .chkPunchNoSuper
	; DFDB+P -> Ryuko Ranbu
	mMvIn_ChkDir MoveInput_DFDB, MoveInit_MrKarate_RyukoRanbu
	; FBDF+P -> Haoh Sho Koh Ken
	mMvIn_ChkDir MoveInput_FBDF, MoveInit_MrKarate_HaohShoKohKen
.chkPunchNoSuper:
	; FDB+P -> Zenretsuken
	mMvIn_ChkDir MoveInput_FDB, MoveInit_MrKarate_Zenretsuken
	; BDF+P (close) -> ?????
	mMvIn_ChkDir MoveInput_BDF, MoveInit_MrKarate_PunchCombo
	; DF+P -> Ko-Ou Ken
	mMvIn_ChkDir MoveInput_DF, MoveInit_MrKarate_KoOuKen
	jp   MoveInputReader_MrKarate_NoMove
.chkKick:
	; DB+K -> Hien Shippuu Kyaku
	mMvIn_ChkDir MoveInput_DB, MoveInit_MrKarate_HienShippuuKyaku
	; BDF+K -> Shouran Kyaku
	mMvIn_ChkDir MoveInput_BDF, MoveInit_MrKarate_ShouranKyaku
	jp   MoveInputReader_MrKarate_NoMove
	
; =============== MoveInit_MrKarate_KoOuKen ===============
MoveInit_MrKarate_KoOuKen:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_MRKARATE_SHOURAN_KO_OU_KEN_L, MOVE_MRKARATE_SHOURAN_KO_OU_KEN_H
	call MoveInputS_SetSpecMove_StopSpeed
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	set  PF0B_PROJREM, [hl]
	call Play_Proj_CopyMoveDamageFromPl
	jp   MoveInputReader_MrKarate_SetMove
; =============== MoveInit_MrKarate_ShouranKyaku ===============
MoveInit_MrKarate_ShouranKyaku:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_MRKARATE_SHOURAN_KYAKU_L, MOVE_MRKARATE_SHOURAN_KYAKU_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_MrKarate_SetMove
; =============== MoveInit_MrKarate_HienShippuuKyaku ===============
MoveInit_MrKarate_HienShippuuKyaku:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_MRKARATE_HIEN_SHIPPUU_KYAKU_L, MOVE_MRKARATE_HIEN_SHIPPUU_KYAKU_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_MrKarate_SetMove
; =============== MoveInit_MrKarate_Zenretsuken ===============
MoveInit_MrKarate_Zenretsuken:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_MRKARATE_ZENRETSUKEN_L, MOVE_MRKARATE_ZENRETSUKEN_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_MrKarate_SetMove
; =============== MoveInit_MrKarate_PunchCombo ===============
MoveInit_MrKarate_PunchCombo:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_ValidateClose MoveInputReader_MrKarate_NoMove
	mMvIn_GetLH MOVE_MRKARATE_PUNCH_COMBO_L, MOVE_MRKARATE_PUNCH_COMBO_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_MrKarate_SetMove
; =============== MoveInit_MrKarate_RyukoRanbu ===============
MoveInit_MrKarate_RyukoRanbu:
	call Play_Pl_ClearJoyDirBuffer
	; [TCRF] Suspicious use of mMvIn_GetSD.
	;        Very likely that that a reference to MOVE_MRKARATE_RYUKO_RANBU_UNUSED_D got
	;        quickly patched out since it didn't work properly.
	mMvIn_GetSD MOVE_MRKARATE_RYUKO_RANBU_S, MOVE_MRKARATE_RYUKO_RANBU_S
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_MrKarate_SetMove
; =============== MoveInit_MrKarate_HaohShoKohKen ===============
MoveInit_MrKarate_HaohShoKohKen:
	mMvIn_ValidateProjActive MrKarate
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetSD MOVE_MRKARATE_HAOH_SHO_KOH_KEN_S, MOVE_MRKARATE_HAOH_SHO_KOH_KEN_D
	call MoveInputS_SetSpecMove_StopSpeed
	call Play_Proj_CopyMoveDamageFromPl
	jp   MoveInputReader_MrKarate_SetMove
; =============== MoveInputReader_MrKarate_SetMove ===============
MoveInputReader_MrKarate_SetMove:
	scf
	ret
; =============== MoveInputReader_MrKarate_NoMove ===============
MoveInputReader_MrKarate_NoMove:
	or   a
	ret
L02729F:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L027301
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $04
	jp   z, L0272BF
	cp   $08
	jp   z, L0272BF
	cp   $0C
	jp   z, L0272E9
	jp   L0272FE
L0272BF:;J
	ld   hl, $0108
	ld   a, $90
	call Play_Pl_SetMoveDamage
	call OBJLstS_IsFrameEnd
	jp   nc, L0272FE
	ld   a, $16
	call HomeCall_Sound_ReqPlayExId
	jp   L0272FE
L0272D5: db $21;X
L0272D6: db $08;X
L0272D7: db $01;X
L0272D8: db $3E;X
L0272D9: db $10;X
L0272DA: db $CD;X
L0272DB: db $82;X
L0272DC: db $38;X
L0272DD: db $CD;X
L0272DE: db $D9;X
L0272DF: db $2D;X
L0272E0: db $D2;X
L0272E1: db $FE;X
L0272E2: db $72;X
L0272E3: db $23;X
L0272E4: db $36;X
L0272E5: db $14;X
L0272E6: db $C3;X
L0272E7: db $FE;X
L0272E8: db $72;X
L0272E9:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L0272F2
	call L002674
L0272F2:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0272FE
	call Play_Pl_EndMove
	jp   L027301
L0272FE:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L027301:;J
	ret
L027302:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L027409
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L027336
	cp   $04
	jp   z, L027336
	cp   $08
	jp   z, L027336
	cp   $0C
	jp   z, L0273A6
	cp   $10
	jp   z, L0273B7
	cp   $14
	jp   z, L0273C8
	cp   $18
	jp   z, L0273FB
L027333: db $C3;X
L027334: db $06;X
L027335: db $74;X
L027336:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L027362
	ld   a, $9D
	call HomeCall_Sound_ReqPlayExId
	call MoveInputS_CheckMoveLHVer
	jp   c, L02735C
	jp   nz, L027353
	ld   hl, $0500
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	jp   L027362
L027353:;J
	ld   hl, $0600
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	jp   L027362
L02735C:;J
	ld   hl, $0700
	call Play_OBJLstS_SetSpeedH_ByXFlipR
L027362:;J
	call L003745
	jp   nc, L027389
	jp   nz, L027383
	ld   a, $0C
	ld   h, $00
	call L002E49
	ld   hl, $0109
	ld   a, $00
	call Play_Pl_SetMoveDamageNext
	ld   hl, $0083
	add  hl, bc
	ld   [hl], $03
	jp   L027409
L027383:;J
	ld   hl, $0000
	call Play_OBJLstS_SetSpeedH_ByXFlipR
L027389:;J
	call OBJLstS_ApplyXSpeed
	call OBJLstS_IsFrameEnd
	jp   nc, L027406
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $08
	jp   nz, L027406
	ld   a, $18
	ld   h, $0A
	call L002E49
	jp   L027409
L0273A6:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L027406
	ld   hl, $010A
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	jp   L027406
L0273B7:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L027406
	ld   hl, $0109
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	jp   L027406
L0273C8:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L027406
	ld   hl, $0083
	add  hl, bc
	dec  [hl]
	jp   z, L0273E7
	ld   hl, $0109
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	ld   hl, $0013
	add  hl, de
	ld   [hl], $08
	jp   L027406
L0273E7:;J
	ld   a, $86
	call Pl_Unk_SetNewMoveAndAnim_StopSpeed
	ld   hl, $FD00
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FB00
	call Play_OBJLstS_SetSpeedV
	jp   L027409
L0273FB:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L027406
	call Play_Pl_EndMove
	jr   L027409
L027406:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L027409:;JR
	ret
L02740A:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L0274FE
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L02743E
	cp   $04
	jp   z, L02744A
	cp   $08
	jp   z, L0274DC
	cp   $0C
	jp   z, L0274B4
	cp   $10
	jp   z, L0274C8
	cp   $14
	jp   z, L0274DC
	cp   $18
	jp   z, L0274EF
L02743B: db $C3;X
L02743C: db $DC;X
L02743D: db $74;X
L02743E:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0274FB
	inc  hl
	ld   [hl], $03
	jp   L0274FB
L02744A:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L027496
	ld   a, $11
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0033
	add  hl, bc
	ld   a, [hl]
	cp   $52
	jp   z, L02746E
	ld   hl, $0300
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, OAM_Begin
	call Play_OBJLstS_SetSpeedV
	jp   L0274DC
L02746E:;J
	ld   hl, $0050
	add  hl, bc
	ld   a, [hl]
	cp   $28
	jp   z, L027487
	ld   hl, $0400
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FD80
	call Play_OBJLstS_SetSpeedV
	jp   L0274DC
L027487:;J
	ld   hl, $0500
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FD00
	call Play_OBJLstS_SetSpeedV
	jp   L0274DC
L027496:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0274DC
	inc  hl
	push hl
	ld   hl, $0033
	add  hl, bc
	ld   a, [hl]
	cp   $52
	jp   z, L0274AE
	pop  hl
	ld   [hl], $FF
	jp   L0274DC
L0274AE:;J
	pop  hl
	ld   [hl], $00
	jp   L0274DC
L0274B4:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0274DC
	inc  hl
	ld   [hl], $00
	ld   hl, $0808
	ld   a, $11
	call Play_Pl_SetMoveDamageNext
	jp   L0274DC
L0274C8:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0274DC
	inc  hl
	ld   [hl], $FF
	ld   hl, $080C
	ld   a, $11
	call Play_Pl_SetMoveDamageNext
	jp   L0274DC
L0274DC:;J
	ld   hl, $0030
	call OBJLstS_ApplyGravity
	jp   nc, L0274FB
	ld   a, $18
	ld   h, $01
	call Play_Pl_SetJumpLandAnimFrame
	jp   L0274FE
L0274EF:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0274FB
	call Play_Pl_EndMove
	jp   L0274FE
L0274FB:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L0274FE:;J
	ret
L0274FF:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L0275EE
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L027538
	cp   $04
	jp   z, L027557
	cp   $08
	jp   z, L027562
	cp   $0C
	jp   z, L027599
	cp   $10
	jp   z, L0275AA
	cp   $14
	jp   z, L0275BB
	cp   $18
	jp   z, L0275D4
	cp   $20
	jp   z, L0275E0
	jp   L0275EB
L027538:;J
	ld   hl, $0109
	ld   a, $90
	call Play_Pl_SetMoveDamage
	call OBJLstS_IsFrameEnd
	jp   nc, L0275EB
	inc  hl
	ld   [hl], $00
	ld   a, $A8
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0083
	add  hl, bc
	ld   [hl], $04
	jp   L0275EB
L027557:;J
	ld   hl, $010A
	ld   a, $90
	call Play_Pl_SetMoveDamage
	jp   L0275EB
L027562:;J
	ld   hl, $0109
	ld   a, $90
	call Play_Pl_SetMoveDamage
	call OBJLstS_IsFrameEnd
	jp   nc, L0275EB
	ld   a, $A8
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0083
	add  hl, bc
	dec  [hl]
	jp   z, L02758E
	ld   hl, $0109
	ld   a, $10
	call Play_Pl_SetMoveDamage
	ld   hl, $0013
	add  hl, de
	ld   [hl], $00
	jp   L0275EB
L02758E:;J
	ld   hl, $010A
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	jp   L0275EB
L027599:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0275EB
	ld   hl, $0109
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	jp   L0275EB
L0275AA:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0275EB
	ld   hl, $010A
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	jp   L0275EB
L0275BB:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0275EB
	inc  hl
	ld   [hl], $1E
	ld   a, $A8
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0108
	ld   a, $11
	call Play_Pl_SetMoveDamageNext
	jp   L0275EB
L0275D4:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0275EB
	inc  hl
	ld   [hl], $08
	jp   L0275EB
L0275E0:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0275EB
	call Play_Pl_EndMove
	jr   L0275EE
L0275EB:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L0275EE:;JR
	ret
L0275EF:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L027763
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L027646
	cp   $04
	jp   z, L027658
	cp   $08
	jp   z, L0276DE
	cp   $0C
	jp   z, L0276CA
	cp   $14
	jp   z, L0276CA
	cp   $1C
	jp   z, L0276CA
	cp   $24
	jp   z, L0276CA
	cp   $2C
	jp   z, L0276CA
	cp   $34
	jp   z, L0276CA
	cp   $3C
	jp   z, L0276CA
	cp   $44
	jp   z, L0276CA
	cp   $4C
	jp   z, L0276CA
	cp   $50
	jp   z, L02771D
	cp   $58
	jp   z, L027754
	jp   L0276F5
L027646:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L02764C
L02764C:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L027760
	inc  hl
	ld   [hl], $FF
	jp   L027760
L027658:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L027687
	ld   a, $11
	call HomeCall_Sound_ReqPlayExId
	call MoveInputS_CheckMoveLHVer
	jp   nz, L027678
	ld   hl, $05FF
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, OAM_Begin
	call Play_OBJLstS_SetSpeedV
	jp   L02773E
L027678:;J
	ld   hl, $06FF
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FD80
	call Play_OBJLstS_SetSpeedV
	jp   L02773E
L027687:;J
	ld   hl, $0063
	add  hl, bc
	bit  1, [hl]
	jp   z, L0276C7
	ld   hl, $006E
	add  hl, bc
	bit  7, [hl]
	jp   nz, L0276C7
	bit  4, [hl]
	jp   z, L0276C7
	bit  3, [hl]
	jp   nz, L0276C1
	ld   hl, $010A
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	ld   a, $08
	ld   h, $01
	call L002E49
	ld   hl, $0000
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $0005
	add  hl, de
	ld   [hl], $88
	jp   L027763
L0276C1:;J
	ld   hl, $0100
	call Play_OBJLstS_SetSpeedH_ByXFlipR
L0276C7:;J
	jp   L02773E
L0276CA:;J
	call OBJLstS_ApplyXSpeed
	call OBJLstS_IsFrameNewLoad
	jp   z, L027760
	ld   hl, $010A
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	jp   L027706
L0276DE:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L027760
	ld   hl, $0109
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	ld   hl, $0080
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	jp   L027760
L0276F5:;J
	call OBJLstS_ApplyXSpeed
	call OBJLstS_IsFrameNewLoad
	jp   z, L027760
	ld   hl, $0109
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
L027706:;J
	ld   hl, $0073
	add  hl, bc
	ld   a, [hl]
	cp   $09
	jp   z, L027760
	cp   $0A
	jp   z, L027760
L027715: db $3E;X
L027716: db $18;X
L027717: db $CD;X
L027718: db $1B;X
L027719: db $34;X
L02771A: db $C3;X
L02771B: db $63;X
L02771C: db $77;X
L02771D:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L027760
	call MoveInputS_CheckMoveLHVer
	jp   nz, L02772E
	ld   a, $54
	jp   L027730
L02772E:;J
	ld   a, $56
L027730:;J
	call MoveInputS_SetSpecMove_StopSpeed
	ld   hl, $0608
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	jp   L027763
L02773E:;J
	ld   hl, $0030
	call OBJLstS_ApplyGravity
	jp   nc, L027760
	jp   L02775A
L02774A: db $3E;X
L02774B: db $58;X
L02774C: db $26;X
L02774D: db $07;X
L02774E: db $CD;X
L02774F: db $EC;X
L027750: db $2D;X
L027751: db $C3;X
L027752: db $63;X
L027753: db $77;X
L027754: db $CD;X
L027755: db $D9;X
L027756: db $2D;X
L027757: db $D2;X
L027758: db $60;X
L027759: db $77;X
L02775A:;J
	call Play_Pl_EndMove
	jp   L027763
L027760:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L027763:;J
	ret
L027764: db $CD;X
L027765: db $7B;X
L027766: db $34;X
L027767: db $CD;X
L027768: db $B3;X
L027769: db $38;X
L02776A: db $DA;X
L02776B: db $09;X
L02776C: db $79;X
L02776D: db $21;X
L02776E: db $17;X
L02776F: db $00;X
L027770: db $19;X
L027771: db $7E;X
L027772: db $FE;X
L027773: db $00;X
L027774: db $CA;X
L027775: db $F2;X
L027776: db $77;X
L027777: db $FE;X
L027778: db $04;X
L027779: db $CA;X
L02777A: db $FE;X
L02777B: db $77;X
L02777C: db $FE;X
L02777D: db $08;X
L02777E: db $CA;X
L02777F: db $84;X
L027780: db $78;X
L027781: db $FE;X
L027782: db $0C;X
L027783: db $CA;X
L027784: db $70;X
L027785: db $78;X
L027786: db $FE;X
L027787: db $14;X
L027788: db $CA;X
L027789: db $70;X
L02778A: db $78;X
L02778B: db $FE;X
L02778C: db $1C;X
L02778D: db $CA;X
L02778E: db $70;X
L02778F: db $78;X
L027790: db $FE;X
L027791: db $24;X
L027792: db $CA;X
L027793: db $70;X
L027794: db $78;X
L027795: db $FE;X
L027796: db $2C;X
L027797: db $CA;X
L027798: db $70;X
L027799: db $78;X
L02779A: db $FE;X
L02779B: db $34;X
L02779C: db $CA;X
L02779D: db $70;X
L02779E: db $78;X
L02779F: db $FE;X
L0277A0: db $3C;X
L0277A1: db $CA;X
L0277A2: db $70;X
L0277A3: db $78;X
L0277A4: db $FE;X
L0277A5: db $44;X
L0277A6: db $CA;X
L0277A7: db $70;X
L0277A8: db $78;X
L0277A9: db $FE;X
L0277AA: db $4C;X
L0277AB: db $CA;X
L0277AC: db $70;X
L0277AD: db $78;X
L0277AE: db $FE;X
L0277AF: db $54;X
L0277B0: db $CA;X
L0277B1: db $70;X
L0277B2: db $78;X
L0277B3: db $FE;X
L0277B4: db $5C;X
L0277B5: db $CA;X
L0277B6: db $70;X
L0277B7: db $78;X
L0277B8: db $FE;X
L0277B9: db $64;X
L0277BA: db $CA;X
L0277BB: db $70;X
L0277BC: db $78;X
L0277BD: db $FE;X
L0277BE: db $6C;X
L0277BF: db $CA;X
L0277C0: db $70;X
L0277C1: db $78;X
L0277C2: db $FE;X
L0277C3: db $74;X
L0277C4: db $CA;X
L0277C5: db $70;X
L0277C6: db $78;X
L0277C7: db $FE;X
L0277C8: db $7C;X
L0277C9: db $CA;X
L0277CA: db $70;X
L0277CB: db $78;X
L0277CC: db $FE;X
L0277CD: db $84;X
L0277CE: db $CA;X
L0277CF: db $70;X
L0277D0: db $78;X
L0277D1: db $FE;X
L0277D2: db $8C;X
L0277D3: db $CA;X
L0277D4: db $70;X
L0277D5: db $78;X
L0277D6: db $FE;X
L0277D7: db $94;X
L0277D8: db $CA;X
L0277D9: db $70;X
L0277DA: db $78;X
L0277DB: db $FE;X
L0277DC: db $9C;X
L0277DD: db $CA;X
L0277DE: db $70;X
L0277DF: db $78;X
L0277E0: db $FE;X
L0277E1: db $A4;X
L0277E2: db $CA;X
L0277E3: db $70;X
L0277E4: db $78;X
L0277E5: db $FE;X
L0277E6: db $B0;X
L0277E7: db $CA;X
L0277E8: db $C3;X
L0277E9: db $78;X
L0277EA: db $FE;X
L0277EB: db $B4;X
L0277EC: db $CA;X
L0277ED: db $FA;X
L0277EE: db $78;X
L0277EF: db $C3;X
L0277F0: db $9B;X
L0277F1: db $78;X
L0277F2: db $CD;X
L0277F3: db $D9;X
L0277F4: db $2D;X
L0277F5: db $D2;X
L0277F6: db $06;X
L0277F7: db $79;X
L0277F8: db $23;X
L0277F9: db $36;X
L0277FA: db $FF;X
L0277FB: db $C3;X
L0277FC: db $06;X
L0277FD: db $79;X
L0277FE: db $CD;X
L0277FF: db $D2;X
L027800: db $2D;X
L027801: db $CA;X
L027802: db $2D;X
L027803: db $78;X
L027804: db $3E;X
L027805: db $11;X
L027806: db $CD;X
L027807: db $16;X
L027808: db $10;X
L027809: db $CD;X
L02780A: db $6A;X
L02780B: db $37;X
L02780C: db $C2;X
L02780D: db $1E;X
L02780E: db $78;X
L02780F: db $21;X
L027810: db $FF;X
L027811: db $05;X
L027812: db $CD;X
L027813: db $69;X
L027814: db $35;X
L027815: db $21;X
L027816: db $00;X
L027817: db $FE;X
L027818: db $CD;X
L027819: db $AD;X
L02781A: db $35;X
L02781B: db $C3;X
L02781C: db $E4;X
L02781D: db $78;X
L02781E: db $21;X
L02781F: db $FF;X
L027820: db $06;X
L027821: db $CD;X
L027822: db $69;X
L027823: db $35;X
L027824: db $21;X
L027825: db $80;X
L027826: db $FD;X
L027827: db $CD;X
L027828: db $AD;X
L027829: db $35;X
L02782A: db $C3;X
L02782B: db $E4;X
L02782C: db $78;X
L02782D: db $21;X
L02782E: db $63;X
L02782F: db $00;X
L027830: db $09;X
L027831: db $CB;X
L027832: db $4E;X
L027833: db $CA;X
L027834: db $6D;X
L027835: db $78;X
L027836: db $21;X
L027837: db $6E;X
L027838: db $00;X
L027839: db $09;X
L02783A: db $CB;X
L02783B: db $7E;X
L02783C: db $C2;X
L02783D: db $6D;X
L02783E: db $78;X
L02783F: db $CB;X
L027840: db $66;X
L027841: db $CA;X
L027842: db $6D;X
L027843: db $78;X
L027844: db $CB;X
L027845: db $5E;X
L027846: db $C2;X
L027847: db $67;X
L027848: db $78;X
L027849: db $21;X
L02784A: db $0A;X
L02784B: db $01;X
L02784C: db $3E;X
L02784D: db $10;X
L02784E: db $CD;X
L02784F: db $90;X
L027850: db $38;X
L027851: db $3E;X
L027852: db $08;X
L027853: db $26;X
L027854: db $01;X
L027855: db $CD;X
L027856: db $49;X
L027857: db $2E;X
L027858: db $21;X
L027859: db $00;X
L02785A: db $00;X
L02785B: db $CD;X
L02785C: db $69;X
L02785D: db $35;X
L02785E: db $21;X
L02785F: db $05;X
L027860: db $00;X
L027861: db $19;X
L027862: db $36;X
L027863: db $88;X
L027864: db $C3;X
L027865: db $09;X
L027866: db $79;X
L027867: db $21;X
L027868: db $00;X
L027869: db $01;X
L02786A: db $CD;X
L02786B: db $69;X
L02786C: db $35;X
L02786D: db $C3;X
L02786E: db $E4;X
L02786F: db $78;X
L027870: db $CD;X
L027871: db $B9;X
L027872: db $35;X
L027873: db $CD;X
L027874: db $D2;X
L027875: db $2D;X
L027876: db $CA;X
L027877: db $06;X
L027878: db $79;X
L027879: db $21;X
L02787A: db $0A;X
L02787B: db $01;X
L02787C: db $3E;X
L02787D: db $10;X
L02787E: db $CD;X
L02787F: db $90;X
L027880: db $38;X
L027881: db $C3;X
L027882: db $AC;X
L027883: db $78;X
L027884: db $CD;X
L027885: db $D2;X
L027886: db $2D;X
L027887: db $CA;X
L027888: db $06;X
L027889: db $79;X
L02788A: db $21;X
L02788B: db $09;X
L02788C: db $01;X
L02788D: db $3E;X
L02788E: db $10;X
L02788F: db $CD;X
L027890: db $90;X
L027891: db $38;X
L027892: db $21;X
L027893: db $80;X
L027894: db $00;X
L027895: db $CD;X
L027896: db $69;X
L027897: db $35;X
L027898: db $C3;X
L027899: db $06;X
L02789A: db $79;X
L02789B: db $CD;X
L02789C: db $B9;X
L02789D: db $35;X
L02789E: db $CD;X
L02789F: db $D2;X
L0278A0: db $2D;X
L0278A1: db $CA;X
L0278A2: db $06;X
L0278A3: db $79;X
L0278A4: db $21;X
L0278A5: db $09;X
L0278A6: db $01;X
L0278A7: db $3E;X
L0278A8: db $10;X
L0278A9: db $CD;X
L0278AA: db $90;X
L0278AB: db $38;X
L0278AC: db $21;X
L0278AD: db $73;X
L0278AE: db $00;X
L0278AF: db $09;X
L0278B0: db $7E;X
L0278B1: db $FE;X
L0278B2: db $09;X
L0278B3: db $CA;X
L0278B4: db $06;X
L0278B5: db $79;X
L0278B6: db $FE;X
L0278B7: db $0A;X
L0278B8: db $CA;X
L0278B9: db $06;X
L0278BA: db $79;X
L0278BB: db $3E;X
L0278BC: db $18;X
L0278BD: db $CD;X
L0278BE: db $1B;X
L0278BF: db $34;X
L0278C0: db $C3;X
L0278C1: db $09;X
L0278C2: db $79;X
L0278C3: db $CD;X
L0278C4: db $D9;X
L0278C5: db $2D;X
L0278C6: db $D2;X
L0278C7: db $06;X
L0278C8: db $79;X
L0278C9: db $CD;X
L0278CA: db $6A;X
L0278CB: db $37;X
L0278CC: db $C2;X
L0278CD: db $D4;X
L0278CE: db $78;X
L0278CF: db $3E;X
L0278D0: db $5C;X
L0278D1: db $C3;X
L0278D2: db $D6;X
L0278D3: db $78;X
L0278D4: db $3E;X
L0278D5: db $5E;X
L0278D6: db $CD;X
L0278D7: db $D0;X
L0278D8: db $37;X
L0278D9: db $21;X
L0278DA: db $08;X
L0278DB: db $02;X
L0278DC: db $3E;X
L0278DD: db $10;X
L0278DE: db $CD;X
L0278DF: db $90;X
L0278E0: db $38;X
L0278E1: db $C3;X
L0278E2: db $09;X
L0278E3: db $79;X
L0278E4: db $21;X
L0278E5: db $30;X
L0278E6: db $00;X
L0278E7: db $CD;X
L0278E8: db $14;X
L0278E9: db $36;X
L0278EA: db $D2;X
L0278EB: db $06;X
L0278EC: db $79;X
L0278ED: db $C3;X
L0278EE: db $00;X
L0278EF: db $79;X
L0278F0: db $3E;X
L0278F1: db $B4;X
L0278F2: db $26;X
L0278F3: db $07;X
L0278F4: db $CD;X
L0278F5: db $EC;X
L0278F6: db $2D;X
L0278F7: db $C3;X
L0278F8: db $09;X
L0278F9: db $79;X
L0278FA: db $CD;X
L0278FB: db $D9;X
L0278FC: db $2D;X
L0278FD: db $D2;X
L0278FE: db $06;X
L0278FF: db $79;X
L027900: db $CD;X
L027901: db $A2;X
L027902: db $2E;X
L027903: db $C3;X
L027904: db $09;X
L027905: db $79;X
L027906: db $CD;X
L027907: db $0B;X
L027908: db $2F;X
L027909: db $C9;X
L02790A:;I
	call Play_Pl_IsMoveLoading
	jp   c, L027948
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $04
	jp   z, L027925
	ld   hl, $0039
	add  hl, bc
	cp   a, [hl]
	jp   z, L027936
	jp   L027945
L027925:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L027945
	ld   hl, $0608
	ld   a, $01
	call Play_Pl_SetMoveDamageNext
	jp   L027945
L027936:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L027945
	call Play_Pl_EndMove
	xor  a
	ld   [wPlayPlThrowActId], a
	jr   L027948
L027945:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L027948:;R
	ret
L027949:;I
	call Play_Pl_IsMoveLoading
	jp   c, L0279BF
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L02796E
	cp   $04
	jp   z, L027985
	cp   $08
	jp   z, L02799C
	ld   hl, $0039
	add  hl, bc
	cp   a, [hl]
	jp   z, L0279AD
L02796B: db $C3;X
L02796C: db $BC;X
L02796D: db $79;X
L02796E:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L027982
	ld   hl, $0611
	ld   a, $01
	call Play_Pl_SetMoveDamage
	ld   hl, $F800
	call L003875
L027982:;J
	jp   L0279BC
L027985:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L027999
	ld   hl, $0612
	ld   a, $01
	call Play_Pl_SetMoveDamage
	ld   hl, $08F8
	call L003875
L027999:;J
	jp   L0279BC
L02799C:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L0279AA
	ld   hl, $060C
	ld   a, $01
	call Play_Pl_SetMoveDamage
L0279AA:;J
	jp   L0279BC
L0279AD:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0279BC
	call Play_Pl_EndMove
	xor  a
	ld   [wPlayPlThrowActId], a
	jr   L0279BF
L0279BC:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L0279BF:;R
	ret
L0279C0:;I
	call Play_Pl_IsMoveLoading
	jp   c, L0279FE
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L0279DB
	ld   hl, $0039
	add  hl, bc
	cp   a, [hl]
	jp   z, L0279EC
	jp   L0279FB
L0279DB:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0279FB
	ld   hl, $0608
	ld   a, $01
	call Play_Pl_SetMoveDamageNext
	jp   L0279FB
L0279EC:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0279FB
	call Play_Pl_EndMove
	xor  a
	ld   [wPlayPlThrowActId], a
	jr   L0279FE
L0279FB:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L0279FE:;R
	ret
L0279FF:;I
	call Play_Pl_IsMoveLoading
	jp   c, L027AD6
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L027A26
	cp   $04
	jp   z, L027A46
	cp   $08
	jp   z, L027A86
	cp   $0C
	jp   z, L027A9D
	cp   $10
	jp   z, L027AB4
L027A23: db $C3;X
L027A24: db $D3;X
L027A25: db $7A;X
L027A26:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L027A3A
	ld   hl, $0612
	ld   a, $01
	call Play_Pl_SetMoveDamage
	ld   hl, $FEE0
	call L003875
L027A3A:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0279FB
	inc  hl
	ld   [hl], $FF
	jp   L027AD3
L027A46:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L027A70
	ld   a, $12
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0000
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FA00
	call Play_OBJLstS_SetSpeedV
	ld   hl, $0614
	ld   a, $01
	call Play_Pl_SetMoveDamage
	ld   hl, $FEF0
	call L003875
	ld   a, $01
	ld   [$C178], a
L027A70:;J
	jp   L027A73
L027A73:;J
	ld   hl, $0060
	call OBJLstS_ApplyGravity
	jp   nc, L027AD3
	ld   a, $08
	ld   h, $0A
	call Play_Pl_SetJumpLandAnimFrame
	jp   L027AD6
L027A86:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L027AD3
	ld   hl, $0614
	ld   a, $01
	call Play_Pl_SetMoveDamage
	ld   hl, OAM_Begin
	call L003875
	jp   L027AD3
L027A9D:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L027AD3
	ld   hl, $0614
	ld   a, $01
	call Play_Pl_SetMoveDamage
	ld   hl, OAM_Begin
	call L003875
	jp   L027AD3
L027AB4:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L027AC2
	ld   hl, $0608
	ld   a, $01
	call Play_Pl_SetMoveDamage
L027AC2:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L027AD3
	call Play_Pl_EndMove
	ld   a, $00
	ld   [wPlayPlThrowActId], a
	jp   L027AD6
L027AD3:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L027AD6:;J
	ret
L027AD7:;I
	call Play_Pl_IsMoveLoading
	jp   c, L027B4A
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L027AF9
	cp   $04
	jp   z, L027B10
	cp   $08
	jp   z, L027B27
	cp   $0C
	jp   z, L027B38
L027AF6: db $C3;X
L027AF7: db $47;X
L027AF8: db $7B;X
L027AF9:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L027B47
	ld   hl, $0611
	ld   a, $01
	call Play_Pl_SetMoveDamage
	ld   hl, $F800
	call L003875
	jp   L027B47
L027B10:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L027B47
	ld   hl, $0612
	ld   a, $01
	call Play_Pl_SetMoveDamage
	ld   hl, $01F0
	call L003875
	jp   L027B47
L027B27:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L027B47
	ld   hl, $060F
	ld   a, $01
	call Play_Pl_SetMoveDamage
	jp   L027B47
L027B38:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L027B47
	call Play_Pl_EndMove
	xor  a
	ld   [wPlayPlThrowActId], a
	jr   L027B4A
L027B47:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L027B4A:;R
	ret
L027B4B:;I
	call Play_Pl_IsMoveLoading
	jp   c, L027B94
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $04
	jp   z, L027B63
	cp   $08
	jp   z, L027B74
	jp   L027B91
L027B63:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L027B91
	ld   hl, $0608
	ld   a, $01
	call Play_Pl_SetMoveDamageNext
	jp   L027B91
L027B74:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L027B91
	ld   a, $86
	call Pl_Unk_SetNewMoveAndAnim_StopSpeed
	ld   hl, $FD00
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FB00
	call Play_OBJLstS_SetSpeedV
	xor  a
	ld   [wPlayPlThrowActId], a
	jr   L027B94
L027B91:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L027B94:;R
	ret
L027B95:;I
	call Play_Pl_IsMoveLoading
	jp   c, L027C40
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $04
	jp   z, L027BC1
	cp   $08
	jp   z, L027BD8
	cp   $0C
	jp   z, L027BEF
	cp   $10
	jp   z, L027C06
	cp   $14
	jp   z, L027C1D
	cp   $18
	jp   z, L027C2E
	jp   L027C3D
L027BC1:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L027C3D
	ld   hl, $0612
	ld   a, $01
	call Play_Pl_SetMoveDamage
	ld   hl, $01F8
	call L003875
	jp   L027C3D
L027BD8:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L027C3D
	ld   hl, $0613
	ld   a, $01
	call Play_Pl_SetMoveDamage
	ld   hl, $FEF8
	call L003875
	jp   L027C3D
L027BEF:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L027C3D
	ld   hl, $0614
	ld   a, $01
	call Play_Pl_SetMoveDamage
	ld   hl, $01F8
	call L003875
	jp   L027C3D
L027C06:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L027C3D
	ld   hl, $0611
	ld   a, $01
	call Play_Pl_SetMoveDamage
	ld   hl, $FEF8
	call L003875
	jp   L027C3D
L027C1D:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L027C3D
	ld   hl, $060F
	ld   a, $01
	call Play_Pl_SetMoveDamage
	jp   L027C3D
L027C2E:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L027C3D
	call Play_Pl_EndMove
	xor  a
	ld   [wPlayPlThrowActId], a
	jr   L027C40
L027C3D:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L027C40:;R
	ret
L027C41: db $CD;X
L027C42: db $B3;X
L027C43: db $38;X
L027C44: db $DA;X
L027C45: db $E1;X
L027C46: db $7C;X
L027C47: db $21;X
L027C48: db $17;X
L027C49: db $00;X
L027C4A: db $19;X
L027C4B: db $7E;X
L027C4C: db $FE;X
L027C4D: db $00;X
L027C4E: db $CA;X
L027C4F: db $68;X
L027C50: db $7C;X
L027C51: db $FE;X
L027C52: db $04;X
L027C53: db $CA;X
L027C54: db $7F;X
L027C55: db $7C;X
L027C56: db $FE;X
L027C57: db $08;X
L027C58: db $CA;X
L027C59: db $96;X
L027C5A: db $7C;X
L027C5B: db $FE;X
L027C5C: db $0C;X
L027C5D: db $CA;X
L027C5E: db $BC;X
L027C5F: db $7C;X
L027C60: db $FE;X
L027C61: db $10;X
L027C62: db $CA;X
L027C63: db $CF;X
L027C64: db $7C;X
L027C65: db $C3;X
L027C66: db $DE;X
L027C67: db $7C;X
L027C68: db $CD;X
L027C69: db $D2;X
L027C6A: db $2D;X
L027C6B: db $CA;X
L027C6C: db $DE;X
L027C6D: db $7C;X
L027C6E: db $21;X
L027C6F: db $12;X
L027C70: db $06;X
L027C71: db $3E;X
L027C72: db $01;X
L027C73: db $CD;X
L027C74: db $82;X
L027C75: db $38;X
L027C76: db $21;X
L027C77: db $F8;X
L027C78: db $F8;X
L027C79: db $CD;X
L027C7A: db $75;X
L027C7B: db $38;X
L027C7C: db $C3;X
L027C7D: db $DE;X
L027C7E: db $7C;X
L027C7F: db $CD;X
L027C80: db $D2;X
L027C81: db $2D;X
L027C82: db $CA;X
L027C83: db $DE;X
L027C84: db $7C;X
L027C85: db $21;X
L027C86: db $13;X
L027C87: db $06;X
L027C88: db $3E;X
L027C89: db $01;X
L027C8A: db $CD;X
L027C8B: db $82;X
L027C8C: db $38;X
L027C8D: db $21;X
L027C8E: db $F8;X
L027C8F: db $F8;X
L027C90: db $CD;X
L027C91: db $75;X
L027C92: db $38;X
L027C93: db $C3;X
L027C94: db $DE;X
L027C95: db $7C;X
L027C96: db $CD;X
L027C97: db $D2;X
L027C98: db $2D;X
L027C99: db $CA;X
L027C9A: db $B0;X
L027C9B: db $7C;X
L027C9C: db $21;X
L027C9D: db $0C;X
L027C9E: db $06;X
L027C9F: db $3E;X
L027CA0: db $01;X
L027CA1: db $CD;X
L027CA2: db $82;X
L027CA3: db $38;X
L027CA4: db $21;X
L027CA5: db $00;X
L027CA6: db $FE;X
L027CA7: db $CD;X
L027CA8: db $69;X
L027CA9: db $35;X
L027CAA: db $21;X
L027CAB: db $00;X
L027CAC: db $FE;X
L027CAD: db $CD;X
L027CAE: db $AD;X
L027CAF: db $35;X
L027CB0: db $CD;X
L027CB1: db $D9;X
L027CB2: db $2D;X
L027CB3: db $D2;X
L027CB4: db $BC;X
L027CB5: db $7C;X
L027CB6: db $23;X
L027CB7: db $36;X
L027CB8: db $FF;X
L027CB9: db $C3;X
L027CBA: db $BC;X
L027CBB: db $7C;X
L027CBC: db $21;X
L027CBD: db $60;X
L027CBE: db $00;X
L027CBF: db $CD;X
L027CC0: db $14;X
L027CC1: db $36;X
L027CC2: db $D2;X
L027CC3: db $DE;X
L027CC4: db $7C;X
L027CC5: db $3E;X
L027CC6: db $10;X
L027CC7: db $26;X
L027CC8: db $04;X
L027CC9: db $CD;X
L027CCA: db $EC;X
L027CCB: db $2D;X
L027CCC: db $C3;X
L027CCD: db $E1;X
L027CCE: db $7C;X
L027CCF: db $CD;X
L027CD0: db $D9;X
L027CD1: db $2D;X
L027CD2: db $D2;X
L027CD3: db $DE;X
L027CD4: db $7C;X
L027CD5: db $CD;X
L027CD6: db $A2;X
L027CD7: db $2E;X
L027CD8: db $AF;X
L027CD9: db $EA;X
L027CDA: db $73;X
L027CDB: db $C1;X
L027CDC: db $18;X
L027CDD: db $03;X
L027CDE: db $C3;X
L027CDF: db $0B;X
L027CE0: db $2F;X
L027CE1: db $C9;X
L027CE2:;I
	call Play_Pl_IsMoveLoading
	jp   c, L027DAB
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L027D0E
	cp   $04
	jp   z, L027D2B
	cp   $08
	jp   z, L027D48
	cp   $0C
	jp   z, L027D65
	cp   $10
	jp   z, L027D82
	cp   $14
	jp   z, L027D99
L027D0B: db $C3;X
L027D0C: db $A8;X
L027D0D: db $7D;X
L027D0E:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L027DA8
	ld   hl, $0000
	call Play_OBJLstS_MoveH_ByXFlipR
	ld   hl, $0611
	ld   a, $01
	call Play_Pl_SetMoveDamage
	ld   hl, $F800
	call L003875
	jp   L027DA8
L027D2B:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L027DA8
	ld   hl, $F800
	call Play_OBJLstS_MoveH_ByXFlipR
	ld   hl, $0611
	ld   a, $01
	call Play_Pl_SetMoveDamage
	ld   hl, $F000
	call L003875
	jp   L027DA8
L027D48:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L027DA8
	ld   hl, $1000
	call Play_OBJLstS_MoveH_ByXFlipR
	ld   hl, $0611
	ld   a, $01
	call Play_Pl_SetMoveDamage
	ld   hl, $0000
	call L003875
	jp   L027DA8
L027D65:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L027DA8
	ld   hl, $0800
	call Play_OBJLstS_MoveH_ByXFlipR
	ld   hl, $0611
	ld   a, $01
	call Play_Pl_SetMoveDamage
	ld   hl, $1000
	call L003875
	jp   L027DA8
L027D82:;J
	call OBJLstS_IsFrameNewLoad
	jp   z, L027DA8
	ld   hl, $0000
	call Play_OBJLstS_MoveH_ByXFlipR
	ld   hl, $060F
	ld   a, $01
	call Play_Pl_SetMoveDamage
	jp   L027DA8
L027D99:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L027DA8
	call Play_Pl_EndMove
	xor  a
	ld   [wPlayPlThrowActId], a
	jr   L027DAB
L027DA8:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L027DAB:;R
	ret
L027DAC: db $CD;X
L027DAD: db $B3;X
L027DAE: db $38;X
L027DAF: db $DA;X
L027DB0: db $6B;X
L027DB1: db $7E;X
L027DB2: db $21;X
L027DB3: db $17;X
L027DB4: db $00;X
L027DB5: db $19;X
L027DB6: db $7E;X
L027DB7: db $FE;X
L027DB8: db $00;X
L027DB9: db $CA;X
L027DBA: db $C9;X
L027DBB: db $7D;X
L027DBC: db $FE;X
L027DBD: db $04;X
L027DBE: db $CA;X
L027DBF: db $E9;X
L027DC0: db $7D;X
L027DC1: db $FE;X
L027DC2: db $08;X
L027DC3: db $CA;X
L027DC4: db $3C;X
L027DC5: db $7E;X
L027DC6: db $C3;X
L027DC7: db $68;X
L027DC8: db $7E;X
L027DC9: db $CD;X
L027DCA: db $D2;X
L027DCB: db $2D;X
L027DCC: db $CA;X
L027DCD: db $DD;X
L027DCE: db $7D;X
L027DCF: db $21;X
L027DD0: db $14;X
L027DD1: db $06;X
L027DD2: db $3E;X
L027DD3: db $01;X
L027DD4: db $CD;X
L027DD5: db $82;X
L027DD6: db $38;X
L027DD7: db $21;X
L027DD8: db $FF;X
L027DD9: db $FE;X
L027DDA: db $CD;X
L027DDB: db $75;X
L027DDC: db $38;X
L027DDD: db $CD;X
L027DDE: db $D9;X
L027DDF: db $2D;X
L027DE0: db $D2;X
L027DE1: db $A8;X
L027DE2: db $7D;X
L027DE3: db $23;X
L027DE4: db $36;X
L027DE5: db $FF;X
L027DE6: db $C3;X
L027DE7: db $D3;X
L027DE8: db $7A;X
L027DE9: db $CD;X
L027DEA: db $D2;X
L027DEB: db $2D;X
L027DEC: db $CA;X
L027DED: db $13;X
L027DEE: db $7E;X
L027DEF: db $3E;X
L027DF0: db $12;X
L027DF1: db $CD;X
L027DF2: db $16;X
L027DF3: db $10;X
L027DF4: db $21;X
L027DF5: db $00;X
L027DF6: db $00;X
L027DF7: db $CD;X
L027DF8: db $69;X
L027DF9: db $35;X
L027DFA: db $21;X
L027DFB: db $00;X
L027DFC: db $FF;X
L027DFD: db $CD;X
L027DFE: db $AD;X
L027DFF: db $35;X
L027E00: db $21;X
L027E01: db $14;X
L027E02: db $06;X
L027E03: db $3E;X
L027E04: db $01;X
L027E05: db $CD;X
L027E06: db $82;X
L027E07: db $38;X
L027E08: db $21;X
L027E09: db $FF;X
L027E0A: db $FE;X
L027E0B: db $CD;X
L027E0C: db $75;X
L027E0D: db $38;X
L027E0E: db $3E;X
L027E0F: db $01;X
L027E10: db $EA;X
L027E11: db $78;X
L027E12: db $C1;X
L027E13: db $C3;X
L027E14: db $16;X
L027E15: db $7E;X
L027E16: db $21;X
L027E17: db $60;X
L027E18: db $00;X
L027E19: db $CD;X
L027E1A: db $14;X
L027E1B: db $36;X
L027E1C: db $D2;X
L027E1D: db $68;X
L027E1E: db $7E;X
L027E1F: db $3E;X
L027E20: db $08;X
L027E21: db $26;X
L027E22: db $02;X
L027E23: db $CD;X
L027E24: db $EC;X
L027E25: db $2D;X
L027E26: db $21;X
L027E27: db $14;X
L027E28: db $06;X
L027E29: db $3E;X
L027E2A: db $01;X
L027E2B: db $CD;X
L027E2C: db $82;X
L027E2D: db $38;X
L027E2E: db $21;X
L027E2F: db $FF;X
L027E30: db $FE;X
L027E31: db $CD;X
L027E32: db $75;X
L027E33: db $38;X
L027E34: db $3E;X
L027E35: db $00;X
L027E36: db $EA;X
L027E37: db $78;X
L027E38: db $C1;X
L027E39: db $C3;X
L027E3A: db $6B;X
L027E3B: db $7E;X
L027E3C: db $CD;X
L027E3D: db $D2;X
L027E3E: db $2D;X
L027E3F: db $CA;X
L027E40: db $4A;X
L027E41: db $7E;X
L027E42: db $21;X
L027E43: db $0C;X
L027E44: db $06;X
L027E45: db $3E;X
L027E46: db $01;X
L027E47: db $CD;X
L027E48: db $82;X
L027E49: db $38;X
L027E4A: db $CD;X
L027E4B: db $D9;X
L027E4C: db $2D;X
L027E4D: db $D2;X
L027E4E: db $A8;X
L027E4F: db $7D;X
L027E50: db $3E;X
L027E51: db $86;X
L027E52: db $CD;X
L027E53: db $1B;X
L027E54: db $34;X
L027E55: db $21;X
L027E56: db $00;X
L027E57: db $FD;X
L027E58: db $CD;X
L027E59: db $69;X
L027E5A: db $35;X
L027E5B: db $21;X
L027E5C: db $00;X
L027E5D: db $FB;X
L027E5E: db $CD;X
L027E5F: db $AD;X
L027E60: db $35;X
L027E61: db $AF;X
L027E62: db $EA;X
L027E63: db $73;X
L027E64: db $C1;X
L027E65: db $C3;X
L027E66: db $6B;X
L027E67: db $7E;X
L027E68: db $C3;X
L027E69: db $0B;X
L027E6A: db $2F;X
L027E6B: db $C9;X
L027E6C:;I
	call Play_Pl_IsMoveLoading
	jp   c, L027EBE
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L027E89
	cp   $04
	jp   z, L027E9A
	cp   $08
	jp   z, L027E9D
L027E86: db $C3;X
L027E87: db $BB;X
L027E88: db $7E;X
L027E89:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L027EBB
	ld   hl, $0608
	ld   a, $01
	call Play_Pl_SetMoveDamageNext
	jp   L027EBB
L027E9A:;J
	jp   L027EBB
L027E9D:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L027EBB
	ld   a, $86
	call Pl_Unk_SetNewMoveAndAnim_StopSpeed
	ld   hl, $FD00
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FB00
	call Play_OBJLstS_SetSpeedV
	xor  a
	ld   [wPlayPlThrowActId], a
	jp   L027EBE
L027EBB:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L027EBE:;J
	ret
L027EBF: db $00;X
L027EC0: db $FB;X
L027EC1: db $CD;X
L027EC2: db $07;X
L027EC3: db $43;X
L027EC4: db $AF;X
L027EC5: db $EA;X
L027EC6: db $73;X
L027EC7: db $C1;X
L027EC8: db $C3;X
L027EC9: db $CE;X
L027ECA: db $7E;X
L027ECB: db $C3;X
L027ECC: db $65;X
L027ECD: db $3C;X
L027ECE: db $C9;X
L027ECF: db $CD;X
L027ED0: db $0D;X
L027ED1: db $46;X
L027ED2: db $DA;X
L027ED3: db $21;X
L027ED4: db $7F;X
L027ED5: db $21;X
L027ED6: db $17;X
L027ED7: db $00;X
L027ED8: db $19;X
L027ED9: db $7E;X
L027EDA: db $FE;X
L027EDB: db $00;X
L027EDC: db $CA;X
L027EDD: db $EC;X
L027EDE: db $7E;X
L027EDF: db $FE;X
L027EE0: db $04;X
L027EE1: db $CA;X
L027EE2: db $FD;X
L027EE3: db $7E;X
L027EE4: db $FE;X
L027EE5: db $08;X
L027EE6: db $CA;X
L027EE7: db $00;X
L027EE8: db $7F;X
L027EE9: db $C3;X
L027EEA: db $1E;X
L027EEB: db $7F;X
L027EEC: db $CD;X
L027EED: db $33;X
L027EEE: db $3B;X
L027EEF: db $D2;X
L027EF0: db $1E;X
L027EF1: db $7F;X
L027EF2: db $21;X
L027EF3: db $08;X
L027EF4: db $06;X
L027EF5: db $3E;X
L027EF6: db $01;X
L027EF7: db $CD;X
L027EF8: db $EA;X
L027EF9: db $45;X
L027EFA: db $C3;X
L027EFB: db $1E;X
L027EFC: db $7F;X
L027EFD: db $C3;X
L027EFE: db $1E;X
L027EFF: db $7F;X
L027F00: db $CD;X
L027F01: db $33;X
L027F02: db $3B;X
L027F03: db $D2;X
L027F04: db $1E;X
L027F05: db $7F;X
L027F06: db $3E;X
L027F07: db $86;X
L027F08: db $CD;X
L027F09: db $75;X
L027F0A: db $41;X
L027F0B: db $21;X
L027F0C: db $00;X
L027F0D: db $FD;X
L027F0E: db $CD;X
L027F0F: db $C3;X
L027F10: db $42;X
L027F11: db $21;X
L027F12: db $00;X
L027F13: db $FB;X
L027F14: db $CD;X
L027F15: db $07;X
L027F16: db $43;X
L027F17: db $AF;X
L027F18: db $EA;X
L027F19: db $73;X
L027F1A: db $C1;X
L027F1B: db $C3;X
L027F1C: db $21;X
L027F1D: db $7F;X
L027F1E: db $C3;X
L027F1F: db $65;X
L027F20: db $3C;X
L027F21: db $C9;X
L027F22: db $23;X
L027F23: db $36;X
L027F24: db $FF;X
L027F25: db $C3;X
L027F26: db $30;X
L027F27: db $80;X
L027F28: db $CD;X
L027F29: db $8F;X
L027F2A: db $2E;X
L027F2B: db $CA;X
L027F2C: db $57;X
L027F2D: db $7F;X
L027F2E: db $3E;X
L027F2F: db $11;X
L027F30: db $CD;X
L027F31: db $16;X
L027F32: db $10;X
L027F33: db $CD;X
L027F34: db $CC;X
L027F35: db $37;X
L027F36: db $C2;X
L027F37: db $48;X
L027F38: db $7F;X
L027F39: db $21;X
L027F3A: db $FF;X
L027F3B: db $05;X
L027F3C: db $CD;X
L027F3D: db $DB;X
L027F3E: db $35;X
L027F3F: db $21;X
L027F40: db $00;X
L027F41: db $FE;X
L027F42: db $CD;X
L027F43: db $1F;X
L027F44: db $36;X
L027F45: db $C3;X
L027F46: db $0E;X
L027F47: db $80;X
L027F48: db $21;X
L027F49: db $FF;X
L027F4A: db $06;X
L027F4B: db $CD;X
L027F4C: db $DB;X
L027F4D: db $35;X
L027F4E: db $21;X
L027F4F: db $80;X
L027F50: db $FD;X
L027F51: db $CD;X
L027F52: db $1F;X
L027F53: db $36;X
L027F54: db $C3;X
L027F55: db $0E;X
L027F56: db $80;X
L027F57: db $21;X
L027F58: db $62;X
L027F59: db $00;X
L027F5A: db $09;X
L027F5B: db $CB;X
L027F5C: db $4E;X
L027F5D: db $CA;X
L027F5E: db $97;X
L027F5F: db $7F;X
L027F60: db $21;X
L027F61: db $6D;X
L027F62: db $00;X
L027F63: db $09;X
L027F64: db $CB;X
L027F65: db $7E;X
L027F66: db $C2;X
L027F67: db $97;X
L027F68: db $7F;X
L027F69: db $CB;X
L027F6A: db $66;X
L027F6B: db $CA;X
L027F6C: db $97;X
L027F6D: db $7F;X
L027F6E: db $CB;X
L027F6F: db $5E;X
L027F70: db $C2;X
L027F71: db $91;X
L027F72: db $7F;X
L027F73: db $21;X
L027F74: db $0A;X
L027F75: db $01;X
L027F76: db $3E;X
L027F77: db $10;X
L027F78: db $CD;X
L027F79: db $E7;X
L027F7A: db $38;X
L027F7B: db $3E;X
L027F7C: db $08;X
L027F7D: db $26;X
L027F7E: db $01;X
L027F7F: db $CD;X
L027F80: db $06;X
L027F81: db $2F;X
L027F82: db $21;X
L027F83: db $00;X
L027F84: db $00;X
L027F85: db $CD;X
L027F86: db $DB;X
L027F87: db $35;X
L027F88: db $21;X
L027F89: db $05;X
L027F8A: db $00;X
L027F8B: db $19;X
L027F8C: db $36;X
L027F8D: db $88;X
L027F8E: db $C3;X
L027F8F: db $33;X
L027F90: db $80;X
L027F91: db $21;X
L027F92: db $00;X
L027F93: db $01;X
L027F94: db $CD;X
L027F95: db $DB;X
L027F96: db $35;X
L027F97: db $C3;X
L027F98: db $0E;X
L027F99: db $80;X
L027F9A: db $CD;X
L027F9B: db $2B;X
L027F9C: db $36;X
L027F9D: db $CD;X
L027F9E: db $8F;X
L027F9F: db $2E;X
L027FA0: db $CA;X
L027FA1: db $30;X
L027FA2: db $80;X
L027FA3: db $21;X
L027FA4: db $0A;X
L027FA5: db $01;X
L027FA6: db $3E;X
L027FA7: db $10;X
L027FA8: db $CD;X
L027FA9: db $E7;X
L027FAA: db $38;X
L027FAB: db $C3;X
L027FAC: db $D6;X
L027FAD: db $7F;X
L027FAE: db $CD;X
L027FAF: db $8F;X
L027FB0: db $2E;X
L027FB1: db $CA;X
L027FB2: db $30;X
L027FB3: db $80;X
L027FB4: db $21;X
L027FB5: db $09;X
L027FB6: db $01;X
L027FB7: db $3E;X
L027FB8: db $10;X
L027FB9: db $CD;X
L027FBA: db $E7;X
L027FBB: db $38;X
L027FBC: db $21;X
L027FBD: db $80;X
L027FBE: db $00;X
L027FBF: db $CD;X
L027FC0: db $DB;X
L027FC1: db $35;X
L027FC2: db $C3;X
L027FC3: db $30;X
L027FC4: db $80;X
L027FC5: db $CD;X
L027FC6: db $2B;X
L027FC7: db $36;X
L027FC8: db $CD;X
L027FC9: db $8F;X
L027FCA: db $2E;X
L027FCB: db $CA;X
L027FCC: db $30;X
L027FCD: db $80;X
L027FCE: db $21;X
L027FCF: db $09;X
L027FD0: db $01;X
L027FD1: db $3E;X
L027FD2: db $10;X
L027FD3: db $CD;X
L027FD4: db $E7;X
L027FD5: db $38;X
L027FD6: db $21;X
L027FD7: db $72;X
L027FD8: db $00;X
L027FD9: db $09;X
L027FDA: db $7E;X
L027FDB: db $FE;X
L027FDC: db $09;X
L027FDD: db $CA;X
L027FDE: db $30;X
L027FDF: db $80;X
L027FE0: db $FE;X
L027FE1: db $0A;X
L027FE2: db $CA;X
L027FE3: db $30;X
L027FE4: db $80;X
L027FE5: db $3E;X
L027FE6: db $18;X
L027FE7: db $CD;X
L027FE8: db $9C;X
L027FE9: db $34;X
L027FEA: db $C3;X
L027FEB: db $33;X
L027FEC: db $80;X
L027FED: db $CD;X
L027FEE: db $96;X
L027FEF: db $2E;X
L027FF0: db $D2;X
L027FF1: db $30;X
L027FF2: db $80;X
L027FF3: db $CD;X
L027FF4: db $CC;X
L027FF5: db $37;X
L027FF6: db $C2;X
L027FF7: db $FE;X
L027FF8: db $7F;X
L027FF9: db $3E;X
L027FFA: db $5C;X
L027FFB: db $C3;X
L027FFC: db $00;X
L027FFD: db $80;X
L027FFE: db $3E;X
L027FFF: db $5E;X
