L064000:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L064051
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L06404E
	cp   $04
	jp   z, L064020
	cp   $08
	jp   z, L06402C
L06401D: db $C3;X
L06401E: db $4E;X
L06401F: db $40;X
L064020:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06404E
	inc  hl
	ld   [hl], $FF
	jp   L06404E
L06402C:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L064040
	ld   a, $11
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0400
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	jp   L06404E
L064040:;J
	ld   hl, $0040
	call L0035D9
	jp   nc, L06404E
	call Play_Pl_EndMove
	jr   L064051
L06404E:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L064051:;JR
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
	mMvIn_ChkEasy MoveInit_Kyo_UraShikiOrochinagi, MoveInit_Kyo_ShikiNueTumi
	mMvIn_ChkGA Kyo, .chkPunch, .chkKick
	
.chkPunch:
	mMvIn_ValidateSuper .chkPunchNoSuper
	; DBDF+P -> Ura 108 Shiki Orochinagi
	mMvIn_ChkDir MoveInput_DBDF, MoveInit_Kyo_UraShikiOrochinagi
.chkPunchNoSuper:
	; FDF+P -> 100 Shiki Oniyaki
	mMvIn_ChkDir MoveInput_FDF, MoveInit_Kyo_ShikiOniyaki
	; DF+P -> 114 Shiki Ara Kami
	mMvIn_ChkDir MoveInput_DF, MoveInit_Kyo_ShikiAraKami
	; DB+P -> 910 Shiki Nue Tumi
	mMvIn_ChkDir MoveInput_DB, MoveInit_Kyo_ShikiNueTumi
	; End
	jp   MoveInputReader_Kyo_NoMove
	
.chkKick:
	; FDB+K -> 212 Shiki Kototsuki You 
	mMvIn_ChkDir MoveInput_FDB, MoveInit_Kyo_ShikiKototsukiYou
	; BDB+K -> R.E.D. Kick
	mMvIn_ChkDir MoveInput_BDB, MoveInit_Kyo_RedKick
	; DF+K -> 75 Shiki Kai
	mMvIn_ChkDir MoveInput_DF, MoveInit_Kyo_ShikiKai
	; End
	jp   MoveInputReader_Kyo_NoMove
	
; =============== MoveInit_Kyo_ShikiAraKami ===============
MoveInit_Kyo_ShikiAraKami:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_KYO_SHIKI_ARA_KAMI_L, MOVE_KYO_SHIKI_ARA_KAMI_H
	call MoveInputS_SetSpecMove_StopSpeed
	
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_GUARD, [hl]		; Reduce damage when getting hit out of this
	res  PF1B_CROUCH, [hl]		; Not crouching
	jp   MoveInputReader_Kyo_MoveSet
	
; =============== MoveInit_Kyo_ShikiOniyaki ===============	
MoveInit_Kyo_ShikiOniyaki:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_KYO_SHIKI_ONIYAKI_L, MOVE_KYO_SHIKI_ONIYAKI_H
	call MoveInputS_SetSpecMove_StopSpeed
	
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
	
; =============== MoveInit_Kyo_ShikiKototsukiYou ===============	
MoveInit_Kyo_ShikiKototsukiYou:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_KYO_SHIKI_KOTOTSUKI_YOU_L, MOVE_KYO_SHIKI_KOTOTSUKI_YOU_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Kyo_MoveSet
	
; =============== MoveInit_Kyo_ShikiKai ===============	
MoveInit_Kyo_ShikiKai:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_KYO_SHIKI_KAI_L, MOVE_KYO_SHIKI_KAI_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Kyo_MoveSet
	
; =============== MoveInit_Kyo_ShikiNueTumi ===============	
MoveInit_Kyo_ShikiNueTumi:
	; Clear flag because ???
	ld   hl, iPlInfo_RunningJump
	add  hl, bc
	ld   [hl], $00
	
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_KYO_SHIKI_NUE_TUMI_L, MOVE_KYO_SHIKI_NUE_TUMI_H
	call MoveInputS_SetSpecMove_StopSpeed
	
	ld   hl, iPlInfo_Flags2
	add  hl, bc
	set  PF2B_AUTOGUARDLOW, [hl]
	jp   MoveInputReader_Kyo_MoveSet
	
; =============== MoveInit_Kyo_UraShikiOrochinagi ===============
MoveInit_Kyo_UraShikiOrochinagi:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetSD MOVE_KYO_URA_SHIKI_OROCHINAGI_S, MOVE_KYO_URA_SHIKI_OROCHINAGI_D
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
	
L06417B:;I
	call Play_Pl_CreateJoyMergedKeysLH
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L064471
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L064202
	cp   $04
	jp   z, L06421C
	cp   $08
	jp   z, L064237
	cp   $0C
	jp   z, L064257
	cp   $10
	jp   z, L06427D
	cp   $14
	jp   z, L064292
	cp   $18
	jp   z, L064292
	cp   $1C
	jp   z, L0642C3
	cp   $20
	jp   z, L0642FA
	cp   $24
	jp   z, L06430F
	cp   $28
	jp   z, L06430F
	cp   $2C
	jp   z, L064340
	cp   $30
	jp   z, L064377
	cp   $34
	jp   z, L06438C
	cp   $38
	jp   z, L06438C
	cp   $3C
	jp   z, L06438F
	cp   $40
	jp   z, L064398
	cp   $44
	jp   z, L0643AD
	cp   $48
	jp   z, L0643AD
	cp   $4C
	jp   z, L0643B0
	cp   $50
	jp   z, L0643B9
	cp   $54
	jp   z, L0643D1
	cp   $58
	jp   z, L064463
L0641FF: db $C3;X
L064200: db $6E;X
L064201: db $44;X
L064202:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L06420E
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
L06420E:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06446E
	ld   a, $A8
	call HomeCall_Sound_ReqPlayExId
	jp   L06446E
L06421C:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L06422E
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
	ld   hl, $0021
	add  hl, bc
	res  3, [hl]
L06422E:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06446E
	jp   L06446E
L064237:;J
	ld   hl, $0046
	add  hl, bc
	ld   a, [hl]
	bit  5, a
	jr   nz, L064242
	jr   L064254
L064242:;R
	mMvIn_ChkDir MoveInput_FDB, L0643FD
	mMvIn_ChkDir MoveInput_DF, L0643E6
L064254:;R
	jp   L06446E
L064257:;J
	ld   hl, $0046
	add  hl, bc
	ld   a, [hl]
	bit  5, a
	jr   nz, L064262
	jr   L064274
L064262:;R
	mMvIn_ChkDir MoveInput_FDB, L0643FD
	mMvIn_ChkDir MoveInput_DF, L0643E6
L064274:;R
	call OBJLstS_IsFrameEnd
	jp   nc, L06446E
	jp   L064459
L06427D:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L064289
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
L064289:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06446E
	jp   L06446E
L064292:;J
	ld   hl, $0020
	add  hl, bc
	bit  7, [hl]
	jp   z, L0642AB
L06429B: db $FA;X
L06429C: db $05;X
L06429D: db $C0;X
L06429E: db $CB;X
L06429F: db $67;X
L0642A0: db $CA;X
L0642A1: db $C0;X
L0642A2: db $42;X
L0642A3: db $CB;X
L0642A4: db $47;X
L0642A5: db $CA;X
L0642A6: db $BD;X
L0642A7: db $42;X
L0642A8: db $C3;X
L0642A9: db $BA;X
L0642AA: db $42;X
L0642AB:;J
	ld   hl, $0046
	add  hl, bc
	ld   a, [hl]
	bit  4, a
	jr   nz, L0642BD
	bit  5, a
	jr   nz, L0642BA
	jr   L0642C0
L0642BA:;R
	jp   L064414
L0642BD:;R
	jp   L064442
L0642C0:;R
	jp   L06446E
L0642C3:;J
	ld   hl, $0020
	add  hl, bc
	bit  7, [hl]
	jp   z, L0642DC
L0642CC: db $FA;X
L0642CD: db $05;X
L0642CE: db $C0;X
L0642CF: db $CB;X
L0642D0: db $67;X
L0642D1: db $CA;X
L0642D2: db $F1;X
L0642D3: db $42;X
L0642D4: db $CB;X
L0642D5: db $47;X
L0642D6: db $CA;X
L0642D7: db $EE;X
L0642D8: db $42;X
L0642D9: db $C3;X
L0642DA: db $EB;X
L0642DB: db $42;X
L0642DC:;J
	ld   hl, $0046
	add  hl, bc
	ld   a, [hl]
	bit  4, a
	jr   nz, L0642EE
	bit  5, a
	jr   nz, L0642EB
	jr   L0642F1
L0642EB:;R
	jp   L064414
L0642EE: db $C3;X
L0642EF: db $42;X
L0642F0: db $44;X
L0642F1:;R
	call OBJLstS_IsFrameEnd
	jp   nc, L06446E
	jp   L064459
L0642FA:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L064306
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
L064306:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06446E
	jp   L06446E
L06430F:;J
	ld   hl, $0020
	add  hl, bc
	bit  7, [hl]
	jp   z, L064328
L064318: db $FA;X
L064319: db $05;X
L06431A: db $C0;X
L06431B: db $CB;X
L06431C: db $67;X
L06431D: db $CA;X
L06431E: db $3D;X
L06431F: db $43;X
L064320: db $CB;X
L064321: db $47;X
L064322: db $CA;X
L064323: db $3A;X
L064324: db $43;X
L064325: db $C3;X
L064326: db $37;X
L064327: db $43;X
L064328:;J
	ld   hl, $0046
	add  hl, bc
	ld   a, [hl]
	bit  4, a
	jr   nz, L06433A
	bit  5, a
	jr   nz, L064337
	jr   L06433D
L064337:;R
	jp   L06442B
L06433A: db $C3;X
L06433B: db $42;X
L06433C: db $44;X
L06433D:;R
	jp   L06446E
L064340:;J
	ld   hl, $0020
	add  hl, bc
	bit  7, [hl]
	jp   z, L064359
L064349: db $FA;X
L06434A: db $05;X
L06434B: db $C0;X
L06434C: db $CB;X
L06434D: db $67;X
L06434E: db $CA;X
L06434F: db $6E;X
L064350: db $43;X
L064351: db $CB;X
L064352: db $47;X
L064353: db $CA;X
L064354: db $6B;X
L064355: db $43;X
L064356: db $C3;X
L064357: db $68;X
L064358: db $43;X
L064359:;J
	ld   hl, $0046
	add  hl, bc
	ld   a, [hl]
	bit  4, a
	jr   nz, L06436B
	bit  5, a
	jr   nz, L064368
	jr   L06436E
L064368: db $C3;X
L064369: db $2B;X
L06436A: db $44;X
L06436B: db $C3;X
L06436C: db $42;X
L06436D: db $44;X
L06436E:;R
	call OBJLstS_IsFrameEnd
	jp   nc, L06446E
	jp   L064459
L064377:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L064383
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
L064383:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06446E
	jp   L06446E
L06438C:;J
	jp   L06446E
L06438F:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06446E
	jp   L064459
L064398:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L0643A4
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
L0643A4:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06446E
	jp   L06446E
L0643AD:;J
	jp   L06446E
L0643B0:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06446E
	jp   L064459
L0643B9:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L0643C5
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
L0643C5:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06446E
	inc  hl
	ld   [hl], $08
	jp   L06446E
L0643D1:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L0643DD
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
L0643DD:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06446E
	jp   L064459
L0643E6:;J
	ld   hl, $0808
	ld   a, $13
	call Play_Pl_SetMoveDamageNext
	ld   a, $10
	ld   h, $00
	call L002E49
	ld   a, $A8
	call HomeCall_Sound_ReqPlayExId
	jp   L064471
L0643FD:;J
	ld   hl, $080C
	ld   a, $1B
	call Play_Pl_SetMoveDamageNext
	ld   a, $20
	ld   h, $00
	call L002E49
	ld   a, $A8
	call HomeCall_Sound_ReqPlayExId
	jp   L064471
L064414:;J
	ld   hl, $080C
	ld   a, $1B
	call Play_Pl_SetMoveDamageNext
	ld   a, $30
	ld   h, $00
	call L002E49
	ld   a, $A8
	call HomeCall_Sound_ReqPlayExId
	jp   L064471
L06442B:;J
	ld   hl, $080C
	ld   a, $13
	call Play_Pl_SetMoveDamageNext
	ld   a, $40
	ld   h, $00
	call L002E49
	ld   a, $A8
	call HomeCall_Sound_ReqPlayExId
	jp   L064471
L064442:;J
	ld   hl, $0808
	ld   a, $11
	call Play_Pl_SetMoveDamageNext
	ld   a, $50
	ld   h, $00
	call L002E49
	ld   a, $A8
	call HomeCall_Sound_ReqPlayExId
	jp   L064471
L064459:;J
	ld   a, $58
	ld   h, $01
	call L002E49
	jp   L064471
L064463:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06446E
	call Play_Pl_EndMove
	jr   L064471
L06446E:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L064471:;JR
	ret
L064472:;I
	call Play_Pl_CreateJoyMergedKeysLH
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L0646B0
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L0644C7
	cp   $04
	jp   z, L0644EA
	cp   $08
	jp   z, L064508
	cp   $0C
	jp   z, L064534
	cp   $10
	jp   z, L064566
	cp   $14
	jp   z, L06457E
	cp   $18
	jp   z, L0645A2
	cp   $1C
	jp   z, L0645CC
	cp   $20
	jp   z, L0645E9
	cp   $24
	jp   z, L064630
	cp   $28
	jp   z, L06463A
	cp   $2C
	jp   z, L06464D
	cp   $30
	jp   z, L0646A2
L0644C4: db $C3;X
L0644C5: db $AD;X
L0644C6: db $46;X
L0644C7:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L0644D9
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
	ld   hl, $0083
	add  hl, bc
	ld   [hl], $00
L0644D9:;J
	call L0646B1
	call OBJLstS_IsFrameEnd
	jp   nc, L0646AD
	ld   a, $A8
	call HomeCall_Sound_ReqPlayExId
	jp   L0646AD
L0644EA:;J
	call L0646B1
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L0644FF
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
	ld   hl, $0021
	add  hl, bc
	res  3, [hl]
L0644FF:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0646AD
	jp   L0646AD
L064508:;J
	ld   hl, $0020
	add  hl, bc
	bit  7, [hl]
	jp   z, L06451C
	ld   a, [wTimer]
	bit  4, a
	jp   z, L064531
	jp   L064658
L06451C:;J
	call L0646B1
	ld   hl, $0083
	add  hl, bc
	ld   a, [hl]
	bit  0, a
	jp   z, L064531
	bit  1, a
	jp   z, L064531
	jp   L064658
L064531:;J
	jp   L0646AD
L064534:;J
	ld   hl, $0020
	add  hl, bc
	bit  7, [hl]
	jp   z, L064548
L06453D: db $FA;X
L06453E: db $05;X
L06453F: db $C0;X
L064540: db $CB;X
L064541: db $67;X
L064542: db $CA;X
L064543: db $5D;X
L064544: db $45;X
L064545: db $C3;X
L064546: db $58;X
L064547: db $46;X
L064548:;J
	call L0646B1
	ld   hl, $0083
	add  hl, bc
	ld   a, [hl]
	bit  0, a
	jp   z, L06455D
	bit  1, a
	jp   z, L06455D
	jp   L064658
L06455D:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0646AD
	jp   L064698
L064566:;J
	call L0646EE
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L064575
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
L064575:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0646AD
	jp   L0646AD
L06457E:;J
	ld   hl, $0020
	add  hl, bc
	bit  7, [hl]
	jp   z, L064592
	ld   a, [wTimer]
	bit  4, a
	jp   z, L06459F
	jp   L064678
L064592:;J
	call L0646EE
	ld   hl, $0083
	add  hl, bc
	ld   a, [hl]
	bit  2, a
	jp   nz, L064678
L06459F:;J
	jp   L0646AD
L0645A2:;J
	ld   hl, $0020
	add  hl, bc
	bit  7, [hl]
	jp   z, L0645B6
L0645AB: db $FA;X
L0645AC: db $05;X
L0645AD: db $C0;X
L0645AE: db $CB;X
L0645AF: db $67;X
L0645B0: db $CA;X
L0645B1: db $C3;X
L0645B2: db $45;X
L0645B3: db $C3;X
L0645B4: db $78;X
L0645B5: db $46;X
L0645B6:;J
	call L0646EE
	ld   hl, $0083
	add  hl, bc
	ld   a, [hl]
	bit  2, a
	jp   nz, L064678
	call OBJLstS_IsFrameEnd
	jp   nc, L0646AD
	jp   L064698
L0645CC:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L0645D8
	ld   hl, $0400
	call Play_OBJLstS_MoveH_ByXFlipR
L0645D8:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0646AD
	inc  hl
	ld   [hl], $FF
	ld   a, $A8
	call HomeCall_Sound_ReqPlayExId
	jp   L0646AD
L0645E9:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L064623
	ld   hl, $0400
	call Play_OBJLstS_MoveH_ByXFlipR
	ld   hl, $0020
	add  hl, bc
	res  3, [hl]
	ld   hl, $0050
	add  hl, bc
	ld   a, [hl]
	cp   $28
	jp   z, L064614
	ld   hl, $0100
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FC00
	call Play_OBJLstS_SetSpeedV
	jp   L064620
L064614:;J
	ld   hl, $0200
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FC00
	call Play_OBJLstS_SetSpeedV
L064620:;J
	jp   L06463A
L064623:;J
	ld   a, $FE
	ld   h, $FF
	call L002E63
	jp   nc, L06463A
	jp   L06463A
L064630:;J
	ld   a, $FF
	ld   h, $FF
	call L002E63
	jp   L06463A
L06463A:;J
	ld   hl, $0060
	call L003614
	jp   nc, L0646AD
	ld   a, $2C
	ld   h, $08
	call L002DEC
	jp   L0646B0
L06464D:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0646AD
	call Play_Pl_EndMove
	jr   L0646B0
L064658:;J
	ld   a, $10
	ld   h, $00
	call L002E49
	jp   z, L0646B0
	ld   hl, $0803
	ld   a, $13
	call Play_Pl_SetMoveDamageNext
	ld   a, $A8
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0049
	add  hl, bc
	ld   [hl], $00
	jp   L0646B0
L064678:;J
	ld   a, $1C
	ld   h, $00
	call L002E49
	jp   z, L0646B0
	ld   hl, $0808
	ld   a, $11
	call Play_Pl_SetMoveDamageNext
	ld   a, $A8
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0049
	add  hl, bc
	ld   [hl], $00
	jp   L0646B0
L064698:;J
	ld   a, $30
	ld   h, $01
	call L002E49
	jp   L0646B0
L0646A2:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0646AD
	call Play_Pl_EndMove
	jr   L0646B0
L0646AD:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L0646B0:;JR
	ret
L0646B1:;C
	ld   hl, $0083
	add  hl, bc
	bit  0, [hl]
	jp   z, L0646C2
	bit  1, [hl]
	jp   z, L0646C2
	jp   L0646ED
L0646C2:;J
	ld   hl, $0049
	add  hl, bc
	ld   a, [hl]
	bit  5, a
	jp   z, L0646D2
	ld   hl, $0083
	add  hl, bc
	set  0, [hl]
L0646D2:;J
	mMvIn_ChkDirNot MoveInput_DB_Copy, L0646EA
	ld   hl, $0083
	add  hl, bc
	set  1, [hl]
	ld   hl, $0049
	add  hl, bc
	ld   [hl], $00
	jp   L0646ED
L0646EA:;J
	call L0646EE
L0646ED:;J
	ret
L0646EE:;C
	ld   hl, $0083
	add  hl, bc
	bit  0, [hl]
	jp   z, L06471A
	bit  1, [hl]
	jp   z, L06471A
	bit  2, [hl]
	jp   nz, L06471A
	ld   hl, $0049
	add  hl, bc
	ld   a, [hl]
	bit  5, a
	jp   nz, L06470E
	jp   L06471A
L06470E:;J
	ld   hl, $0083
	add  hl, bc
	set  2, [hl]
	ld   hl, $0049
	add  hl, bc
	ld   [hl], $00
L06471A:;J
	ret
L06471B:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L06482E
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L06482B
	cp   $04
	jp   z, L06474C
	cp   $08
	jp   z, L064782
	cp   $0C
	jp   z, L0647F3
	cp   $10
	jp   z, L0647FD
	cp   $14
	jp   z, L06480D
	cp   $18
	jp   z, L064820
L06474C:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L064758
	ld   hl, $0400
	call Play_OBJLstS_MoveH_ByXFlipR
L064758:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06482B
	inc  hl
	ld   [hl], $FF
	ld   a, $A8
	call HomeCall_Sound_ReqPlayExId
	call MoveInputS_CheckMoveLHVer
	jp   nz, L064777
	ld   hl, $0408
	ld   a, $03
	call Play_Pl_SetMoveDamageNext
	jp   L06482B
L064777:;J
	ld   hl, $0408
	ld   a, $03
	call Play_Pl_SetMoveDamageNext
	jp   L06482B
L064782:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L0647CD
	ld   hl, $0400
	call Play_OBJLstS_MoveH_ByXFlipR
	ld   hl, $0020
	add  hl, bc
	inc  hl
	res  7, [hl]
	res  3, [hl]
	call MoveInputS_CheckMoveLHVer
	jp   c, L0647BE
	jp   nz, L0647AF
	ld   hl, $0080
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FA00
	call Play_OBJLstS_SetSpeedV
	jp   L0647CA
L0647AF:;J
	ld   hl, $0100
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $F900
	call Play_OBJLstS_SetSpeedV
	jp   L0647CA
L0647BE:;J
	ld   hl, $0200
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $F800
	call Play_OBJLstS_SetSpeedV
L0647CA:;J
	jp   L06480D
L0647CD:;J
	ld   a, $F6
	ld   h, $FF
	call L002E63
	jp   nc, L06480D
	call MoveInputS_CheckMoveLHVer
	jp   nz, L0647E8
	ld   hl, $0408
	ld   a, $03
	call Play_Pl_SetMoveDamageNext
	jp   L06480D
L0647E8:;J
	ld   hl, $0408
	ld   a, $03
	call Play_Pl_SetMoveDamageNext
	jp   L06480D
L0647F3:;J
	ld   a, $F6
	ld   h, $FF
	call L002E63
	jp   L06480D
L0647FD:;J
	ld   a, $01
	ld   h, $FF
	call L002E63
	ld   hl, $0040
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	jp   L06480D
L06480D:;J
	ld   hl, $0060
	call L003614
	jp   nc, L06482B
	ld   a, $18
	ld   h, $0A
	call L002DEC
	jp   L06482E
L064820:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06482B
	call Play_Pl_EndMove
	jr   L06482E
L06482B:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L06482E:;JR
	ret
L06482F:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L064906
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L06485B
	cp   $04
	jp   z, L064875
	cp   $08
	jp   z, L0648C3
	cp   $0C
	jp   z, L0648D8
	cp   $10
	jp   z, L0648E5
	cp   $14
	jp   z, L0648F8
L06485B:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L064861
L064861:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L064903
	inc  hl
	ld   [hl], $FF
	ld   hl, $0808
	ld   a, $11
	call Play_Pl_SetMoveDamageNext
	jp   L064903
L064875:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L0648B6
	ld   a, $12
	call HomeCall_Sound_ReqPlayExId
	call MoveInputS_CheckMoveLHVer
	jp   c, L0648A7
	jp   nz, L064898
	ld   hl, $0400
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FC00
	call Play_OBJLstS_SetSpeedV
	jp   L0648B3
L064898:;J
	ld   hl, $0500
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FC00
	call Play_OBJLstS_SetSpeedV
	jp   L0648B3
L0648A7:;J
	ld   hl, $0600
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FC00
	call Play_OBJLstS_SetSpeedV
L0648B3:;J
	jp   L0648E5
L0648B6:;J
	ld   a, $FA
	ld   h, $FF
	call L002E63
	jp   nc, L0648E5
	jp   L0648E5
L0648C3:;J
	ld   a, $FE
	ld   h, $FF
	call L002E63
	jp   nc, L0648E5
	ld   hl, $080C
	ld   a, $01
	call Play_Pl_SetMoveDamageNext
	jp   L0648E5
L0648D8:;J
	ld   a, $FF
	ld   h, $FF
	call L002E63
	jp   nc, L0648E5
	jp   L0648E5
L0648E5:;J
	ld   hl, $0060
	call L003614
	jp   nc, L064903
	ld   a, $14
	ld   h, $08
	call L002DEC
	jp   L064906
L0648F8:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L064903
	call Play_Pl_EndMove
	jr   L064906
L064903:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L064906:;JR
	ret
L064907:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L064A09
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L06493B
	cp   $04
	jp   z, L064947
	cp   $08
	jp   z, L064979
	cp   $0C
	jp   z, L064987
	cp   $10
	jp   z, L06499E
	cp   $14
	jp   z, L0649C7
	cp   $18
	jp   z, L0649FA
L064938: db $C3;X
L064939: db $06;X
L06493A: db $4A;X
L06493B:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0649AA
	inc  hl
	ld   [hl], $01
	jp   L0649AA
L064947:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L064976
	ld   a, $9D
	call HomeCall_Sound_ReqPlayExId
	call MoveInputS_CheckMoveLHVer
	jp   c, L06496D
	jp   nz, L064964
	ld   hl, $0500
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	jp   L0649C1
L064964:;J
	ld   hl, $0600
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	jp   L0649C1
L06496D:;J
	ld   hl, $0700
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	jp   L0649C1
L064976:;J
	jp   L0649AA
L064979:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L0649AA
	ld   a, $9D
	call HomeCall_Sound_ReqPlayExId
	jp   L0649AA
L064987:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L064992
	ld   a, $9D
	call HomeCall_Sound_ReqPlayExId
L064992:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0649AA
	inc  hl
	ld   [hl], $FF
	jp   L0649C1
L06499E:;J
	ld   hl, $0100
	call L0035D9
	jp   nc, L064A09
	jp   L064A00
L0649AA:;J
	ld   hl, $0061
	add  hl, bc
	ld   a, [hl]
	cp   $18
	jp   nc, L0649C1
	ld   a, $14
	ld   h, $01
	call L002E49
	call OBJLstS_ApplyXSpeed
	jp   L064A09
L0649C1:;J
	call OBJLstS_ApplyXSpeed
	jp   L064A06
L0649C7:;J
	ld   hl, $0080
	call L0035D9
	ld   hl, $0063
	add  hl, bc
	bit  1, [hl]
	jp   z, L0649DF
	ld   hl, $006E
	add  hl, bc
	bit  7, [hl]
	jp   z, L0649E8
L0649DF:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L064A06
	jp   L064A00
L0649E8:;J
	ld   hl, $0808
	ld   a, $03
	call Play_Pl_SetMoveDamageNext
	ld   a, $18
	ld   h, $08
	call L002E49
	jp   L064A09
L0649FA:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L064A06
L064A00:;J
	call Play_Pl_EndMove
	jp   L064A09
L064A06:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L064A09:;J
	ret
L064A0A:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L064AD0
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L064A36
	cp   $04
	jp   z, L064A67
	cp   $08
	jp   z, L064A87
	cp   $0C
	jp   z, L064A9D
	cp   $10
	jp   z, L064A84
	cp   $14
	jp   z, L064AC2
L064A36:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L064A42
	ld   hl, $0400
	call Play_OBJLstS_SetSpeedH_ByXFlipR
L064A42:;J
	ld   hl, $0070
	call L0035D9
	jp   nc, L064ACD
	ld   hl, $001B
	add  hl, de
	ld   [hl], $00
	inc  hl
	ld   [hl], $01
	ld   hl, $0033
	add  hl, bc
	ld   a, [hl]
	cp   $5A
	jp   z, L064ACD
	ld   hl, $001C
	add  hl, de
	ld   [hl], $FF
	jp   L064ACD
L064A67:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L064A81
	ld   a, $09
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0300
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FD00
	call Play_OBJLstS_SetSpeedV
	jp   L064AAF
L064A81:;J
	jp   L064AAF
L064A84:;J
	jp   L064AAF
L064A87:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L064AAF
	ld   hl, $0808
	ld   a, $11
	call Play_Pl_SetMoveDamageNext
	ld   a, $09
	call HomeCall_Sound_ReqPlayExId
	jp   L064AAF
L064A9D:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L064AAF
	inc  hl
	ld   [hl], $FF
	ld   hl, $0080
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	jp   L064AAF
L064AAF:;J
	ld   hl, $0060
	call L003614
	jp   nc, L064ACD
	ld   a, $14
	ld   h, $08
	call L002DEC
	jp   L064AD0
L064AC2:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L064ACD
	call Play_Pl_EndMove
	jr   L064AD0
L064ACD:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L064AD0:;JR
	ret
L064AD1:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L064BC2
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L064B00
	cp   $04
	jp   z, L064B53
	cp   $08
	jp   z, L064BA6
	cp   $0C
	jp   z, L064BB4
	cp   $1C
	jp   z, L064BB4
	cp   $2C
	jp   z, L064BB4
	jp   L064BBF
L064B00:;J
	ld   hl, $0022
	add  hl, bc
	bit  3, [hl]
	jp   z, L064B3C
	ld   hl, $0083
	add  hl, bc
	ld   a, [hl]
	or   a
	jp   nz, L064B2A
	ld   a, $0A
	call HomeCall_Sound_ReqPlayExId
	ld   a, $01
	ld   [wPlayHitstopSet], a
	call Play_Pl_ShakeFor
	ld   a, $00
	ld   [wPlayHitstopSet], a
	ld   hl, $0083
	add  hl, bc
	ld   [hl], $01
L064B2A:;J
	ld   a, $10
	ld   h, $01
	call L002E49
	ld   hl, $080C
	ld   a, $03
	call Play_Pl_SetMoveDamageNext
	jp   L064BC2
L064B3C:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L064BBF
	ld   hl, $0083
	add  hl, bc
	ld   [hl], $00
	ld   hl, $0022
	add  hl, bc
	set  4, [hl]
	res  5, [hl]
	jp   L064BBF
L064B53:;J
	ld   hl, $0022
	add  hl, bc
	bit  3, [hl]
	jp   z, L064B8F
	ld   hl, $0083
	add  hl, bc
	ld   a, [hl]
	or   a
	jp   nz, L064B7D
	ld   a, $0A
	call HomeCall_Sound_ReqPlayExId
	ld   a, $01
	ld   [wPlayHitstopSet], a
	call Play_Pl_ShakeFor
	ld   a, $00
	ld   [wPlayHitstopSet], a
	ld   hl, $0083
	add  hl, bc
	ld   [hl], $01
L064B7D:;J
	ld   a, $20
	ld   h, $01
	call L002E49
	ld   hl, $0803
	ld   a, $03
	call Play_Pl_SetMoveDamageNext
	jp   L064BC2
L064B8F:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L064BBF
	ld   hl, $0083
	add  hl, bc
	ld   [hl], $00
	ld   hl, $0022
	add  hl, bc
	res  4, [hl]
	res  5, [hl]
	jp   L064BBF
L064BA6:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L064BBF
	ld   a, $09
	call HomeCall_Sound_ReqPlayExId
	jp   L064BBF
L064BB4:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L064BBF
	call Play_Pl_EndMove
	jr   L064BC2
L064BBF:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L064BC2:;JR
	ret
L064BC3:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L064CA3
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L064BF7
	cp   $08
	jp   z, L064C06
	cp   $0C
	jp   z, L064C30
	cp   $10
	jp   z, L064C4A
	cp   $14
	jp   z, L064C6A
	cp   $18
	jp   z, L064C7F
	cp   $1C
	jp   z, L064C94
	jp   L064CA0
L064BF7:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L064CA0
	ld   hl, $0083
	add  hl, bc
	ld   [hl], $14
	jp   L064CA0
L064C06:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L064CA0
	ld   hl, $0045
	add  hl, bc
	ld   a, [hl]
	and  a, $20
	jp   z, L064CA0
	ld   hl, $0083
	add  hl, bc
	dec  [hl]
	jp   z, L064CA0
	ld   a, $04
	ld   h, $00
	call L002E49
	ld   hl, $0103
	ld   a, $12
	call Play_Pl_SetMoveDamageNext
	jp   L064CA3
L064C30:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L064CA0
	inc  hl
	ld   [hl], $00
	ld   hl, $1808
	ld   a, $23
	call Play_Pl_SetMoveDamageNext
	ld   hl, $0022
	add  hl, bc
	res  6, [hl]
	jp   L064CA0
L064C4A:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L064C5E
	ld   a, $15
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $07C0
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	jp   L064C76
L064C5E:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L064C76
L064C64: db $23;X
L064C65: db $36;X
L064C66: db $01;X
L064C67: db $C3;X
L064C68: db $76;X
L064C69: db $4C;X
L064C6A:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L064C76
	inc  hl
	ld   [hl], $FF
	jp   L064C76
L064C76:;J
	ld   hl, $0060
	call L0035D9
	jp   L064CA0
L064C7F:;J
	ld   hl, $0080
	call L0035D9
	jp   nc, L064CA3
	ld   hl, $001B
	add  hl, de
	ld   [hl], $00
	inc  hl
	ld   [hl], $05
	jp   L064CA0
L064C94:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L064CA0
	call Play_Pl_EndMove
	jp   L064CA3
L064CA0:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L064CA3:;J
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
	mMvIn_ValidateSuper .chkPunchNoSuper
	
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
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_GUARD, [hl] ; Take less damage if we're hit out of this
	res  PF1B_CROUCH, [hl] ; [POI] Not necessary, already done by MoveInputS_SetSpecMove_StopSpeed
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
L064DAA:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L064E0D
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $08
	jp   z, L064DC5
	cp   $0C
	jp   z, L064DFF
	jp   L064E0A
L064DC5:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L064E0A
	ld   hl, $0033
	add  hl, bc
	ld   a, [hl]
	cp   $64
	jp   z, L064DF0
	call L0651E5
	ld   hl, $0033
	add  hl, bc
	ld   a, [hl]
	ld   hl, $001C
	add  hl, de
	cp   $4A
	jp   z, L064DEB
	ld   [hl], $0A
	jp   L064E0A
L064DEB:;J
	ld   [hl], $14
	jp   L064E0A
L064DF0:;J
	ld   hl, $1800
	call L06525F
	ld   hl, $001C
	add  hl, de
	ld   [hl], $28
	jp   L064E0A
L064DFF:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L064E0A
	call Play_Pl_EndMove
	jr   L064E0D
L064E0A:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L064E0D:;JR
	ret
L064E0E:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L064E9E
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $04
	jp   z, L064E42
	cp   $08
	jp   z, L064E4E
	cp   $10
	jp   z, L064E42
	cp   $14
	jp   z, L064E5D
	cp   $1C
	jp   z, L064E42
	cp   $20
	jp   z, L064E78
	cp   $24
	jp   z, L064E90
	jp   L064E9B
L064E42:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L064E9B
	inc  hl
	ld   [hl], $14
	jp   L064E9B
L064E4E:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L064E6C
	ld   hl, $1800
	call L06525F
	jp   L064E6C
L064E5D:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L064E6C
	ld   hl, $4000
	call L06525F
	jp   L064E6C
L064E6C:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L064E9B
	inc  hl
	ld   [hl], $02
	jp   L064E9B
L064E78:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L064E84
	ld   hl, $6800
	call L06525F
L064E84:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L064E9B
	inc  hl
	ld   [hl], $32
	jp   L064E9B
L064E90:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L064E9B
	call Play_Pl_EndMove
	jr   L064E9E
L064E9B:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L064E9E:;JR
	ret
L064E9F: db $CD;X
L064EA0: db $7B;X
L064EA1: db $34;X
L064EA2: db $CD;X
L064EA3: db $B3;X
L064EA4: db $38;X
L064EA5: db $DA;X
L064EA6: db $55;X
L064EA7: db $4F;X
L064EA8: db $21;X
L064EA9: db $17;X
L064EAA: db $00;X
L064EAB: db $19;X
L064EAC: db $7E;X
L064EAD: db $FE;X
L064EAE: db $00;X
L064EAF: db $CA;X
L064EB0: db $CE;X
L064EB1: db $4E;X
L064EB2: db $FE;X
L064EB3: db $04;X
L064EB4: db $CA;X
L064EB5: db $DA;X
L064EB6: db $4E;X
L064EB7: db $FE;X
L064EB8: db $08;X
L064EB9: db $CA;X
L064EBA: db $EB;X
L064EBB: db $4E;X
L064EBC: db $FE;X
L064EBD: db $0C;X
L064EBE: db $CA;X
L064EBF: db $FE;X
L064EC0: db $4E;X
L064EC1: db $FE;X
L064EC2: db $4C;X
L064EC3: db $CA;X
L064EC4: db $1C;X
L064EC5: db $4F;X
L064EC6: db $FE;X
L064EC7: db $50;X
L064EC8: db $CA;X
L064EC9: db $47;X
L064ECA: db $4F;X
L064ECB: db $C3;X
L064ECC: db $10;X
L064ECD: db $4F;X
L064ECE: db $CD;X
L064ECF: db $D9;X
L064ED0: db $2D;X
L064ED1: db $D2;X
L064ED2: db $52;X
L064ED3: db $4F;X
L064ED4: db $23;X
L064ED5: db $36;X
L064ED6: db $02;X
L064ED7: db $C3;X
L064ED8: db $52;X
L064ED9: db $4F;X
L064EDA: db $CD;X
L064EDB: db $D9;X
L064EDC: db $2D;X
L064EDD: db $D2;X
L064EDE: db $52;X
L064EDF: db $4F;X
L064EE0: db $23;X
L064EE1: db $36;X
L064EE2: db $08;X
L064EE3: db $3E;X
L064EE4: db $14;X
L064EE5: db $CD;X
L064EE6: db $16;X
L064EE7: db $10;X
L064EE8: db $C3;X
L064EE9: db $52;X
L064EEA: db $4F;X
L064EEB: db $CD;X
L064EEC: db $6D;X
L064EED: db $3C;X
L064EEE: db $CD;X
L064EEF: db $D9;X
L064EF0: db $2D;X
L064EF1: db $D2;X
L064EF2: db $52;X
L064EF3: db $4F;X
L064EF4: db $23;X
L064EF5: db $36;X
L064EF6: db $08;X
L064EF7: db $AF;X
L064EF8: db $EA;X
L064EF9: db $59;X
L064EFA: db $C1;X
L064EFB: db $C3;X
L064EFC: db $52;X
L064EFD: db $4F;X
L064EFE: db $CD;X
L064EFF: db $D9;X
L064F00: db $2D;X
L064F01: db $D2;X
L064F02: db $52;X
L064F03: db $4F;X
L064F04: db $23;X
L064F05: db $36;X
L064F06: db $05;X
L064F07: db $21;X
L064F08: db $83;X
L064F09: db $00;X
L064F0A: db $09;X
L064F0B: db $36;X
L064F0C: db $00;X
L064F0D: db $C3;X
L064F0E: db $52;X
L064F0F: db $4F;X
L064F10: db $CD;X
L064F11: db $6D;X
L064F12: db $3C;X
L064F13: db $CD;X
L064F14: db $D9;X
L064F15: db $2D;X
L064F16: db $D2;X
L064F17: db $52;X
L064F18: db $4F;X
L064F19: db $C3;X
L064F1A: db $28;X
L064F1B: db $4F;X
L064F1C: db $CD;X
L064F1D: db $6D;X
L064F1E: db $3C;X
L064F1F: db $CD;X
L064F20: db $D9;X
L064F21: db $2D;X
L064F22: db $D2;X
L064F23: db $52;X
L064F24: db $4F;X
L064F25: db $23;X
L064F26: db $36;X
L064F27: db $3C;X
L064F28: db $AF;X
L064F29: db $EA;X
L064F2A: db $59;X
L064F2B: db $C1;X
L064F2C: db $CD;X
L064F2D: db $70;X
L064F2E: db $11;X
L064F2F: db $E6;X
L064F30: db $38;X
L064F31: db $C6;X
L064F32: db $18;X
L064F33: db $21;X
L064F34: db $83;X
L064F35: db $00;X
L064F36: db $09;X
L064F37: db $BE;X
L064F38: db $C2;X
L064F39: db $3D;X
L064F3A: db $4F;X
L064F3B: db $C6;X
L064F3C: db $08;X
L064F3D: db $77;X
L064F3E: db $67;X
L064F3F: db $2E;X
L064F40: db $00;X
L064F41: db $CD;X
L064F42: db $5F;X
L064F43: db $52;X
L064F44: db $C3;X
L064F45: db $52;X
L064F46: db $4F;X
L064F47: db $CD;X
L064F48: db $D9;X
L064F49: db $2D;X
L064F4A: db $D2;X
L064F4B: db $52;X
L064F4C: db $4F;X
L064F4D: db $CD;X
L064F4E: db $A2;X
L064F4F: db $2E;X
L064F50: db $18;X
L064F51: db $03;X
L064F52: db $C3;X
L064F53: db $0B;X
L064F54: db $2F;X
L064F55: db $C9;X
L064F56:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L06502E
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L06502B
	cp   $04
	jp   z, L06502B
	cp   $08
	jp   z, L064F87
	cp   $0C
	jp   z, L064F93
	cp   $10
	jp   z, L064FDF
	cp   $14
	jp   z, L064FF0
	cp   $18
	jp   z, L065020
L064F87:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06502B
	inc  hl
	ld   [hl], $00
	jp   L06502B
L064F93:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L064FDC
	ld   a, $11
	call HomeCall_Sound_ReqPlayExId
	call MoveInputS_CheckMoveLHVer
	jp   c, L064FC5
	jp   nz, L064FB6
	ld   hl, $0500
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FD00
	call Play_OBJLstS_SetSpeedV
	jp   L064FD9
L064FB6:;J
	ld   hl, $0600
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FC80
	call Play_OBJLstS_SetSpeedV
	jp   L064FD9
L064FC5:;J
	ld   hl, $0700
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FC00
	call Play_OBJLstS_SetSpeedV
	ld   hl, $0208
	ld   a, $12
	call Play_Pl_SetMoveDamage
L064FD9:;J
	jp   L06500D
L064FDC:;J
	jp   L06500D
L064FDF:;J
	call MoveInputS_CheckMoveLHVer
	jp   nc, L06500D
	ld   hl, $0208
	ld   a, $92
	call Play_Pl_SetMoveDamage
	jp   L06500D
L064FF0:;J
	call MoveInputS_CheckMoveLHVer
	jp   nc, L064FFE
	ld   hl, $0208
	ld   a, $92
	call Play_Pl_SetMoveDamage
L064FFE:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06500D
	ld   hl, $0013
	add  hl, de
	ld   [hl], $0C
	jp   L06500D
L06500D:;J
	ld   hl, $0060
	call L003614
	jp   nc, L06502B
	ld   a, $18
	ld   h, $06
	call L002DEC
	jp   L06502E
L065020:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06502B
	call Play_Pl_EndMove
	jr   L06502E
L06502B:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L06502E:;JR
	ret
L06502F:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L0650FA
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L065056
	cp   $04
	jp   z, L06506E
	cp   $08
	jp   z, L0650C4
	cp   $0C
	jp   z, L0650D9
	cp   $10
	jp   z, L0650EC
L065056:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L065062
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
L065062:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0650F7
	inc  hl
	ld   [hl], $FF
	jp   L0650F7
L06506E:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L0650AF
	ld   a, $12
	call HomeCall_Sound_ReqPlayExId
	call MoveInputS_CheckMoveLHVer
	jp   c, L0650A0
	jp   nz, L065091
	ld   hl, $0400
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FD00
	call Play_OBJLstS_SetSpeedV
	jp   L0650AC
L065091:;J
	ld   hl, $0500
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FC80
	call Play_OBJLstS_SetSpeedV
	jp   L0650AC
L0650A0:;J
	ld   hl, $0600
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FC00
	call Play_OBJLstS_SetSpeedV
L0650AC:;J
	jp   L0650D9
L0650AF:;J
	ld   a, $FD
	ld   h, $FF
	call L002E63
	jp   nc, L0650D9
	ld   hl, $0803
	ld   a, $01
	call Play_Pl_SetMoveDamageNext
	jp   L0650D9
L0650C4:;J
	ld   a, $FF
	ld   h, $FF
	call L002E63
	jp   nc, L0650D9
	ld   hl, $0803
	ld   a, $01
	call Play_Pl_SetMoveDamageNext
	jp   L0650D9
L0650D9:;J
	ld   hl, $0060
	call L003614
	jp   nc, L0650F7
	ld   a, $10
	ld   h, $0A
	call L002DEC
	jp   L0650FA
L0650EC:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0650F7
	call Play_Pl_EndMove
	jr   L0650FA
L0650F7:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L0650FA:;JR
	ret
L0650FB:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L0651E4
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L06512C
	cp   $04
	jp   z, L065138
	cp   $08
	jp   z, L06518A
	cp   $0C
	jp   z, L0651B4
	cp   $10
	jp   z, L0651B7
	cp   $14
	jp   z, L0651C3
	cp   $18
	jp   z, L0651D6
L06512C:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0651E1
	inc  hl
	ld   [hl], $FF
	jp   L0651E1
L065138:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L065180
	ld   a, $9C
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0020
	add  hl, bc
	inc  hl
	res  7, [hl]
	call MoveInputS_CheckMoveLHVer
	jp   c, L065171
	jp   nz, L065162
	ld   hl, $0100
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FA00
	call Play_OBJLstS_SetSpeedV
	jp   L06517D
L065162:;J
	ld   hl, $0180
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $F980
	call Play_OBJLstS_SetSpeedV
	jp   L06517D
L065171:;J
	ld   hl, $0200
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $F980
	call Play_OBJLstS_SetSpeedV
L06517D:;J
	jp   L0651C3
L065180:;J
	ld   a, $F6
	ld   h, $05
	call L002E63
	jp   L0651C3
L06518A:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0651C3
	inc  hl
	ld   [hl], $00
	ld   a, $13
	call HomeCall_Sound_ReqPlayExId
	call MoveInputS_CheckMoveLHVer
	jp   nz, L0651A9
	ld   hl, $080C
	ld   a, $00
	call Play_Pl_SetMoveDamageNext
	jp   L0651C3
L0651A9:;J
	ld   hl, $080C
	ld   a, $01
	call Play_Pl_SetMoveDamageNext
	jp   L0651C3
L0651B4:;J
	jp   L0651C3
L0651B7:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0651C3
	inc  hl
	ld   [hl], $FF
	jp   L0651C3
L0651C3:;J
	ld   hl, $0060
	call L003614
	jp   nc, L0651E1
	ld   a, $18
	ld   h, $0A
	call L002DEC
	jp   L0651E4
L0651D6:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0651E1
	call Play_Pl_EndMove
	jr   L0651E4
L0651E1:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L0651E4:;JR
	ret
L0651E5:;C
	ld   a, $10
	call HomeCall_Sound_ReqPlayExId
	push bc
	push de
	ld   hl, $0050
	add  hl, bc
	ld   a, [hl]
	cp   $28
	jp   z, L0651FA
	xor  a
	jp   L0651FB
L0651FA:;J
	scf
L0651FB:;J
	ld   hl, $0022
	push af
	add  hl, bc
	pop  af
	ld   a, [hl]
	push af
	call L0024F8
	ld   hl, $0020
	add  hl, de
	ld   [hl], $06
	inc  hl
	ld   [hl], $AC
	inc  hl
	ld   [hl], $52
	ld   hl, $0010
	add  hl, de
	ld   [hl], $01
	inc  hl
	ld   [hl], $A1
	inc  hl
	ld   [hl], $58
	inc  hl
	ld   [hl], $00
	ld   hl, $001B
	add  hl, de
	ld   [hl], $00
	inc  hl
	ld   [hl], $00
	ld   hl, $0027
	add  hl, de
	ld   [hl], $00
	call OBJLstS_Overlap
	ld   hl, $0800
	call Play_OBJLstS_MoveH_ByXFlipR
	pop  af
	jp   nc, L065245
	bit  1, a
	jp   nz, L065256
	jp   L06524A
L065245:;J
	bit  1, a
	jp   nz, L065250
L06524A:;J
	ld   hl, $0100
	jp   L065259
L065250:;J
	ld   hl, $0200
	jp   L065259
L065256:;J
	ld   hl, $0400
L065259:;J
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	pop  de
	pop  bc
	ret
L06525F:;C
	ld   a, $14
	call HomeCall_Sound_ReqPlayExId
	push bc
	push de
	push hl
	call L0024F8
	ld   hl, $0020
	add  hl, de
	ld   [hl], $06
	inc  hl
	ld   [hl], $C7
	inc  hl
	ld   [hl], $52
	ld   hl, $0010
	add  hl, de
	ld   [hl], $01
	inc  hl
	ld   [hl], $D7
	inc  hl
	ld   [hl], $58
	inc  hl
	ld   [hl], $00
	ld   hl, $001B
	add  hl, de
	ld   [hl], $00
	inc  hl
	ld   [hl], $00
	ld   hl, $0027
	add  hl, de
	ld   [hl], $02
	call OBJLstS_Overlap
	pop  hl
	call Play_OBJLstS_MoveH_ByXFlipR
	pop  de
	pop  bc
	ret
L06529E:;I
	call L0028B2
	jp   c, L0652A8
	call OBJLstS_DoAnimTiming_Loop_by_DE
	ret
L0652A8:;J
	call OBJLstS_Hide
	ret
L0652AC:;I
	call L0028B2
	ld   hl, $0013
	add  hl, de
	ld   a, [hl]
	cp   $30
	jp   z, L0652BD
L0652B9:
	call OBJLstS_DoAnimTiming_Loop_by_DE
	ret
L0652BD:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0652B9
	call OBJLstS_Hide
	ret
L0652C7:;I
	ld   hl, $0013
	add  hl, de
	ld   a, [hl]
	cp   $28
	jp   z, L0652D5
L0652D1:
	call OBJLstS_DoAnimTiming_Loop_by_DE
	ret
L0652D5:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0652D1
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
	mMvIn_ValidateProjActive .chkPunchNoProj
	mMvIn_ChkDir MoveInput_DF, MoveInit_Mai_KaChoSen
.chkPunchNoProj:
	; DB+P -> Ryu En Bu
	mMvIn_ChkDir MoveInput_DB, MoveInit_Mai_RyuEnBu
	jp   MoveInputReader_Mai_NoMove
.chkKick:
	; DBDF+K -> Cho Hissatsu Shinobibachi
	mMvIn_ValidateSuper .chkKickNoSuper
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
	mMvIn_GetLH MOVE_MAI_CHIJOU_MUSASABI_MAI_L, MOVE_MAI_CHIJOU_MUSASABI_MAI_H
	call MoveInputS_SetSpecMove_StopSpeed
	;--
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	;--
	jp   MoveInputReader_Mai_SetMove
; =============== MoveInit_Mai_KuuchuuMusasabiMai ===============
MoveInit_Mai_KuuchuuMusasabiMai:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_MAI_KUUCHUU_MUSASABI_MAI_L, MOVE_MAI_KUUCHUU_MUSASABI_MAI_H
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
L06541F:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L06545D
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $08
	jp   z, L06543A
	cp   $10
	jp   z, L06544F
	jp   L06545A
L06543A:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L065443
	call L065AC0
L065443:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06545A
	inc  hl
	ld   [hl], $07
	jp   L06545A
L06544F:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06545A
	call Play_Pl_EndMove
	jr   L06545D
L06545A:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L06545D:;JR
	ret
L06545E:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L065538
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L065485
	cp   $04
	jp   z, L0654A1
	cp   $08
	jp   z, L0654B7
	cp   $0C
	jp   z, L0654D3
	cp   $10
	jp   z, L06552A
L065485:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L0654CD
	ld   a, $9D
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0200
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $0603
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	jp   L0654CD
L0654A1:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0654CD
	ld   a, $9D
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0604
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	jp   L0654CD
L0654B7:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0654CD
	inc  hl
	ld   [hl], $FF
	ld   a, $9D
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0A08
	ld   a, $01
	call Play_Pl_SetMoveDamageNext
L0654CD:;J
	call OBJLstS_ApplyXSpeed
	jp   L065535
L0654D3:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L065514
	ld   a, $11
	call HomeCall_Sound_ReqPlayExId
	call MoveInputS_CheckMoveLHVer
	jp   c, L065505
	jp   nz, L0654F6
	ld   hl, $0500
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FD00
	call Play_OBJLstS_SetSpeedV
	jp   L065511
L0654F6:;J
	ld   hl, $0600
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FC80
	call Play_OBJLstS_SetSpeedV
	jp   L065511
L065505: db $21;X
L065506: db $00;X
L065507: db $07;X
L065508: db $CD;X
L065509: db $69;X
L06550A: db $35;X
L06550B: db $21;X
L06550C: db $00;X
L06550D: db $FC;X
L06550E: db $CD;X
L06550F: db $AD;X
L065510: db $35;X
L065511:;J
	jp   L065517
L065514:;J
	jp   L065517
L065517:;J
	ld   hl, $0060
	call L003614
	jp   nc, L065535
	ld   a, $10
	ld   h, $07
	call L002DEC
	jp   L065538
L06552A:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L065535
	call Play_Pl_EndMove
	jr   L065538
L065535:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L065538:;JR
	ret
L065539:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L0655CB
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L065563
	cp   $04
	jp   z, L065579
	cp   $08
	jp   z, L06558E
	cp   $0C
	jp   z, L0655B1
	cp   $10
	jp   z, L0655BD
L065560: db $C3;X
L065561: db $C8;X
L065562: db $55;X
L065563:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0655C8
	ld   a, $15
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0908
	ld   a, $23
	call Play_Pl_SetMoveDamageNext
	jp   L0655C8
L065579:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L065585
	ld   hl, $0400
	call Play_OBJLstS_MoveH_ByXFlipR
L065585:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0655C8
	jp   L0655C8
L06558E:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L0655A0
	call MoveInputS_CheckMoveLHVer
	jp   z, L0655A0
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
L0655A0:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0655C8
	ld   hl, $0908
	ld   a, $23
	call Play_Pl_SetMoveDamageNext
	jp   L0655C8
L0655B1:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0655C8
	inc  hl
	ld   [hl], $08
	jp   L0655C8
L0655BD:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0655C8
	call Play_Pl_EndMove
	jr   L0655CB
L0655C8:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L0655CB:;JR
	ret
L0655CC:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L0656B5
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L0655F8
	cp   $04
	jp   z, L0655FB
	cp   $08
	jp   z, L065621
	cp   $0C
	jp   z, L065681
	cp   $10
	jp   z, L065694
	cp   $14
	jp   z, L0656A7
L0655F8:;J
	jp   L0656B2
L0655FB:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L06560D
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
	ld   hl, rJOYP
	call Play_OBJLstS_MoveV
L06560D:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0656B2
	inc  hl
	ld   [hl], $FF
	ld   hl, $0808
	ld   a, $23
	call Play_Pl_SetMoveDamageNext
	jp   L0656B2
L065621:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L065669
	ld   a, $15
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0020
	add  hl, bc
	inc  hl
	res  7, [hl]
	call MoveInputS_CheckMoveLHVer
	jp   c, L06565A
	jp   nz, L06564B
	ld   hl, $0080
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FA00
	call Play_OBJLstS_SetSpeedV
	jp   L065666
L06564B:;J
	ld   hl, $0100
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $F900
	call Play_OBJLstS_SetSpeedV
	jp   L065666
L06565A: db $21;X
L06565B: db $00;X
L06565C: db $02;X
L06565D: db $CD;X
L06565E: db $69;X
L06565F: db $35;X
L065660: db $21;X
L065661: db $00;X
L065662: db $F8;X
L065663: db $CD;X
L065664: db $AD;X
L065665: db $35;X
L065666:;J
	jp   L065694
L065669:;J
	ld   a, $F8
	ld   h, $FF
	call L002E63
	call OBJLstS_IsFrameEnd
	jp   nc, L065694
	ld   hl, $0808
	ld   a, $23
	call Play_Pl_SetMoveDamageNext
	jp   L065694
L065681:;J
	ld   a, $FC
	ld   h, $FF
	call L002E63
	jp   nc, L065694
	ld   hl, $0040
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	jp   L065694
L065694:;J
	ld   hl, $0060
	call L003614
	jp   nc, L0656B2
	ld   a, $14
	ld   h, $08
	call L002DEC
	jp   L0656B5
L0656A7:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0656B2
	call Play_Pl_EndMove
	jr   L0656B5
L0656B2:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L0656B5:;JR
	ret
L0656B6:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L0657F2
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L0656F6
	cp   $04
	jp   z, L065702
	cp   $08
	jp   z, L065769
	cp   $0C
	jp   z, L065769
	cp   $10
	jp   z, L065769
	cp   $14
	jp   z, L065769
	cp   $18
	jp   z, L065777
	cp   $1C
	jp   z, L0657D1
	cp   $20
	jp   z, L0657E4
	cp   $24
	jp   z, L065799
L0656F6:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0657EF
	inc  hl
	ld   [hl], $02
	jp   L0657EF
L065702:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L065769
	ld   a, $9C
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0020
	add  hl, bc
	inc  hl
	res  7, [hl]
	ld   hl, $0045
	add  hl, bc
	bit  0, [hl]
	jp   nz, L065737
	bit  1, [hl]
	jp   nz, L06572B
	ld   hl, $0001
	add  hl, de
	bit  5, [hl]
	jp   z, L065737
L06572B:;J
	ld   hl, $0001
	add  hl, de
	bit  5, [hl]
	jp   z, L065743
	jp   L065747
L065737:;J
	ld   hl, $0001
	add  hl, de
	bit  5, [hl]
	jp   nz, L065743
	jp   L065747
L065743: db $7E;X
L065744: db $EE;X
L065745: db $20;X
L065746: db $77;X
L065747:;J
	ld   hl, $FA00
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $0050
	add  hl, bc
	ld   a, [hl]
	cp   $28
	jp   z, L065760
	ld   hl, $F880
	call Play_OBJLstS_SetSpeedV
	jp   L065766
L065760:;J
	ld   hl, $F900
	call Play_OBJLstS_SetSpeedV
L065766:;J
	jp   L0657D1
L065769:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0657D1
	ld   a, $08
	call HomeCall_Sound_ReqPlayExId
	jp   L0657D1
L065777:;J
	ld   hl, $001F
	add  hl, de
	ld   a, [hl]
	or   a
	jp   nz, L06578F
L065780: db $CD;X
L065781: db $D9;X
L065782: db $2D;X
L065783: db $D2;X
L065784: db $D1;X
L065785: db $57;X
L065786: db $21;X
L065787: db $13;X
L065788: db $00;X
L065789: db $19;X
L06578A: db $36;X
L06578B: db $04;X
L06578C: db $C3;X
L06578D: db $D1;X
L06578E: db $57;X
L06578F:;J
	ld   a, $24
	ld   h, $03
	call L002E49
	jp   L0657F2
L065799:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0657EF
	ld   hl, $0045
	add  hl, bc
	bit  5, [hl]
	jp   nz, L0657BB
	ld   hl, $0020
	add  hl, bc
	bit  7, [hl]
	jp   nz, L0657BB
L0657B1: db $3E;X
L0657B2: db $1C;X
L0657B3: db $26;X
L0657B4: db $FF;X
L0657B5: db $CD;X
L0657B6: db $49;X
L0657B7: db $2E;X
L0657B8: db $C3;X
L0657B9: db $F2;X
L0657BA: db $57;X
L0657BB:;J
	call MoveInputS_CheckMoveLHVer
	jp   nz, L0657C9
	ld   a, $5C
	call MoveInputS_SetSpecMove_StopSpeed
	jp   L0657F2
L0657C9:;J
	ld   a, $5E
	call MoveInputS_SetSpecMove_StopSpeed
	jp   L0657F2
L0657D1:;J
	ld   hl, $0060
	call L003614
	jp   nc, L0657EF
L0657DA: db $3E;X
L0657DB: db $20;X
L0657DC: db $26;X
L0657DD: db $07;X
L0657DE: db $CD;X
L0657DF: db $EC;X
L0657E0: db $2D;X
L0657E1: db $C3;X
L0657E2: db $F2;X
L0657E3: db $57;X
L0657E4: db $CD;X
L0657E5: db $D9;X
L0657E6: db $2D;X
L0657E7: db $D2;X
L0657E8: db $EF;X
L0657E9: db $57;X
L0657EA: db $CD;X
L0657EB: db $A2;X
L0657EC: db $2E;X
L0657ED: db $18;X
L0657EE: db $03;X
L0657EF:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L0657F2:;J
	ret
L0657F3:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L065881
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L065813
	cp   $04
	jp   z, L06581F
	cp   $08
	jp   z, L065873
L065810: db $C3;X
L065811: db $7E;X
L065812: db $58;X
L065813:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06587E
	inc  hl
	ld   [hl], $FF
	jp   L06587E
L06581F:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L065860
	ld   a, $11
	call HomeCall_Sound_ReqPlayExId
	call MoveInputS_CheckMoveLHVer
	jp   c, L065851
	jp   nz, L065842
	ld   hl, $0300
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $0200
	call Play_OBJLstS_SetSpeedV
	jp   L06585D
L065842:;J
	ld   hl, $0500
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $0180
	call Play_OBJLstS_SetSpeedV
	jp   L06585D
L065851: db $21;X
L065852: db $00;X
L065853: db $07;X
L065854: db $CD;X
L065855: db $69;X
L065856: db $35;X
L065857: db $21;X
L065858: db $00;X
L065859: db $00;X
L06585A: db $CD;X
L06585B: db $AD;X
L06585C: db $35;X
L06585D:;J
	jp   L065860
L065860:;J
	ld   hl, $0018
	call L003614
	jp   nc, L06587E
	ld   a, $08
	ld   h, $08
	call L002DEC
	jp   L065881
L065873:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06587E
	call Play_Pl_EndMove
	jr   L065881
L06587E:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L065881:;JR
	ret
L065882:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L065988
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L0658B3
	cp   $04
	jp   z, L065907
	cp   $08
	jp   z, L0658F1
	cp   $0C
	jp   z, L06590D
	cp   $10
	jp   z, L06593F
	cp   $14
	jp   z, L065950
	cp   $18
	jp   z, L06597A
L0658B3:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L0658CA
	ld   hl, $0021
	add  hl, bc
	res  7, [hl]
	ld   a, $9D
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0300
	call Play_OBJLstS_SetSpeedH_ByXFlipR
L0658CA:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L065907
	ld   hl, $0203
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	jp   L065907
L0658DB: db $CD;X
L0658DC: db $D9;X
L0658DD: db $2D;X
L0658DE: db $D2;X
L0658DF: db $07;X
L0658E0: db $59;X
L0658E1: db $3E;X
L0658E2: db $9D;X
L0658E3: db $CD;X
L0658E4: db $16;X
L0658E5: db $10;X
L0658E6: db $21;X
L0658E7: db $04;X
L0658E8: db $02;X
L0658E9: db $3E;X
L0658EA: db $10;X
L0658EB: db $CD;X
L0658EC: db $90;X
L0658ED: db $38;X
L0658EE: db $C3;X
L0658EF: db $07;X
L0658F0: db $59;X
L0658F1:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L065907
	ld   a, $9D
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0208
	ld   a, $12
	call Play_Pl_SetMoveDamageNext
	jp   L065907
L065907:;J
	call OBJLstS_ApplyXSpeed
	jp   L065985
L06590D:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L06592E
	ld   a, $15
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0020
	add  hl, bc
	inc  hl
	res  7, [hl]
	ld   hl, $0680
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FB00
	call Play_OBJLstS_SetSpeedV
	jp   L065967
L06592E:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L065967
L065934: db $21;X
L065935: db $08;X
L065936: db $02;X
L065937: db $3E;X
L065938: db $12;X
L065939: db $CD;X
L06593A: db $90;X
L06593B: db $38;X
L06593C: db $C3;X
L06593D: db $67;X
L06593E: db $59;X
L06593F:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L065967
	ld   hl, $0208
	ld   a, $12
	call Play_Pl_SetMoveDamageNext
	jp   L065967
L065950:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L065967
	ld   hl, $0013
	add  hl, de
	ld   [hl], $0C
	ld   hl, $0208
	ld   a, $12
	call Play_Pl_SetMoveDamageNext
	jp   L065967
L065967:;J
	ld   hl, $0060
	call L003614
	jp   nc, L065985
	ld   a, $18
	ld   h, $0F
	call L002DEC
	jp   L065988
L06597A:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L065985
	call Play_Pl_EndMove
	jr   L065988
L065985:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L065988:;JR
	ret
L065989:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L065ABF
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L0659CE
	cp   $04
	jp   z, L0659DF
	cp   $08
	jp   z, L0659CE
	cp   $0C
	jp   z, L0659DF
	cp   $10
	jp   z, L0659F0
	cp   $14
	jp   z, L065A44
	cp   $18
	jp   z, L065A2E
	cp   $1C
	jp   z, L065A4A
	cp   $20
	jp   z, L065A76
	cp   $24
	jp   z, L065A87
	cp   $28
	jp   z, L065AB1
L0659CE:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L065ABC
	ld   hl, $0203
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	jp   L065ABC
L0659DF:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L065ABC
	ld   hl, $0204
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	jp   L065ABC
L0659F0:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L065A07
	ld   hl, $0021
	add  hl, bc
	res  7, [hl]
	ld   a, $9D
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0300
	call Play_OBJLstS_SetSpeedH_ByXFlipR
L065A07:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L065A44
	ld   hl, $0203
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	jp   L065A44
L065A18: db $CD;X
L065A19: db $D9;X
L065A1A: db $2D;X
L065A1B: db $D2;X
L065A1C: db $44;X
L065A1D: db $5A;X
L065A1E: db $3E;X
L065A1F: db $9D;X
L065A20: db $CD;X
L065A21: db $16;X
L065A22: db $10;X
L065A23: db $21;X
L065A24: db $04;X
L065A25: db $02;X
L065A26: db $3E;X
L065A27: db $10;X
L065A28: db $CD;X
L065A29: db $90;X
L065A2A: db $38;X
L065A2B: db $C3;X
L065A2C: db $44;X
L065A2D: db $5A;X
L065A2E:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L065A44
	ld   a, $9D
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0208
	ld   a, $12
	call Play_Pl_SetMoveDamageNext
	jp   L065A44
L065A44:;J
	call OBJLstS_ApplyXSpeed
	jp   L065ABC
L065A4A:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L065A6B
	ld   a, $15
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0020
	add  hl, bc
	inc  hl
	res  7, [hl]
	ld   hl, $0680
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FB00
	call Play_OBJLstS_SetSpeedV
	jp   L065A9E
L065A6B:;J
	ld   hl, $0208
	ld   a, $92
	call Play_Pl_SetMoveDamage
	jp   L065A9E
L065A76:;J
	ld   hl, $0208
	ld   a, $92
	call Play_Pl_SetMoveDamage
	call OBJLstS_IsFrameEnd
	jp   nc, L065A9E
	jp   L065A9E
L065A87:;J
	ld   hl, $0208
	ld   a, $92
	call Play_Pl_SetMoveDamage
	call OBJLstS_IsFrameEnd
	jp   nc, L065A9E
	ld   hl, $0013
	add  hl, de
	ld   [hl], $1C
	jp   L065A9E
L065A9E:;J
	ld   hl, $0060
	call L003614
	jp   nc, L065ABC
	ld   a, $28
	ld   h, $12
	call L002DEC
	jp   L065ABF
L065AB1:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L065ABC
	call Play_Pl_EndMove
	jr   L065ABF
L065ABC:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L065ABF:;JR
	ret
L065AC0:;C
	ld   a, $09
	call HomeCall_Sound_ReqPlayExId
	push bc
	push de
	ld   hl, $0050
	add  hl, bc
	ld   a, [hl]
	cp   $28
	jp   z, L065AD5
	xor  a
	jp   L065AD6
L065AD5:;J
	scf
L065AD6:;J
	ld   hl, $0022
	push af
	add  hl, bc
	pop  af
	ld   a, [hl]
	push af
	call L0024F8
	ld   hl, $0020
	add  hl, de
	ld   [hl], $06
	inc  hl
	ld   [hl], $9E
	inc  hl
	ld   [hl], $52
	ld   hl, $0010
	add  hl, de
	ld   [hl], $01
	inc  hl
	ld   [hl], $AD
	inc  hl
	ld   [hl], $59
	inc  hl
	ld   [hl], $00
	ld   hl, $001B
	add  hl, de
	ld   [hl], $03
	inc  hl
	ld   [hl], $03
	ld   hl, $0027
	add  hl, de
	ld   [hl], $00
	call OBJLstS_Overlap
	ld   hl, $0800
	call Play_OBJLstS_MoveH_ByXFlipR
	pop  af
	jp   nc, L065B20
	bit  1, a
	jp   nz, L065B31
	jp   L065B25
L065B20:;J
	bit  1, a
	jp   nz, L065B2B
L065B25:;J
	ld   hl, $0100
	jp   L065B34
L065B2B:;J
	ld   hl, $0200
	jp   L065B34
L065B31:;J
	ld   hl, $0400
L065B34:;J
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
	mMvIn_ChkEasy MoveInit_Athena_ShiningCrystalBitAir, MoveInit_Athena_PhoenixArrow
	mMvIn_ChkGA Athena, .chkAirPunch, .chkAirKick
.chkAirPunch:
	mMvIn_ValidateSuper .chkAirPunchNoSuper
	; BFDB+P (air) -> Shining Crystal Bit
	mMvIn_ChkDir MoveInput_BFDB, MoveInit_Athena_ShiningCrystalBitAir
.chkAirPunchNoSuper:
	; FDF+P (air) -> Psycho Sword
	mMvIn_ChkDir MoveInput_FDF, MoveInit_Athena_PsychoSword
	; DB+P (air) -> Phoenix Arrow
	mMvIn_ChkDir MoveInput_DB, MoveInit_Athena_PhoenixArrow
	; End
	jp   MoveInputReader_Athena_NoMove
.chkAirKick:
	; DF+K (air) -> Psycho Teleport
	; [POI] With the autocharge cheat enabled, this move can be pulled off mid-air.
	;       Though since it wasn't designed for this, as soon as the move ends Athena snaps to the ground.
	mMvIn_ValidateDipAutoCharge MoveInputReader_Athena_NoMove
	mMvIn_ChkDir MoveInput_DF, MoveInit_Athena_PsychoTeleport
	; End
	jp   MoveInputReader_Athena_NoMove
	
.chkGround:
	;             SELECT + B                               SELECT + A
	mMvIn_ChkEasy MoveInit_Athena_ShiningCrystalBitGround, MoveInit_Athena_PsychoReflector
	mMvIn_ChkGA Athena, .chkPunch, .chkKick
.chkPunch:
	mMvIn_ValidateSuper .chkPunchNoSuper
	; BFDB+P -> Shining Crystal Bit
	mMvIn_ChkDir MoveInput_BFDB, MoveInit_Athena_ShiningCrystalBitGround
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
	mMvIn_ValidateProjActive Athena
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
; =============== MoveInit_Athena_ShiningCrystalBitGround ===============
MoveInit_Athena_ShiningCrystalBitGround:
	mMvIn_ValidateProjActive Athena
	mMvIn_ValidateProjVisible Athena
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetSD SHINING_CRYSTAL_BIT_GS, SHINING_CRYSTAL_BIT_GD
	call MoveInputS_SetSpecMove_StopSpeed
	call Play_Proj_CopyMoveDamageFromPl
	jp   MoveInputReader_Athena_SetMove
; =============== MoveInit_Athena_ShiningCrystalBitAir ===============
MoveInit_Athena_ShiningCrystalBitAir:
	mMvIn_ValidateProjActive Athena
	mMvIn_ValidateProjVisible Athena
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetSD SHINING_CRYSTAL_BIT_AS, SHINING_CRYSTAL_BIT_AD
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
L065CBF:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L065D0C
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L065CDC
	cp   $04
	jp   z, L065CE8
	cp   $08
	jp   z, L065CFD
L065CDC:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L065D09
	inc  hl
	ld   [hl], $10
	jp   L065D09
L065CE8:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L065CF1
	call L0662E8
L065CF1:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L065D09
	inc  hl
	ld   [hl], $03
	jp   L065D09
L065CFD:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L065D09
	call Play_Pl_EndMove
	jp   L065D0C
L065D09:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L065D0C:;J
	ret
L065D0D:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L065E22
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L065D41
	cp   $04
	jp   z, L065D4D
	cp   $08
	jp   z, L065D9C
	cp   $0C
	jp   z, L065DAD
	cp   $10
	jp   z, L065DEB
	cp   $14
	jp   z, L065DEB
	cp   $18
	jp   z, L065E14
L065D3E: db $C3;X
L065D3F: db $1F;X
L065D40: db $5E;X
L065D41:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L065E1F
	inc  hl
	ld   [hl], $00
	jp   L065E1F
L065D4D:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L065D8B
	ld   a, $11
	call HomeCall_Sound_ReqPlayExId
	call MoveInputS_CheckMoveLHVer
	jp   c, L065D7F
	jp   nz, L065D70
	ld   hl, $0300
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $0200
	call Play_OBJLstS_SetSpeedV
	jp   L065D8B
L065D70:;J
	ld   hl, $0500
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $0180
	call Play_OBJLstS_SetSpeedV
	jp   L065D8B
L065D7F:;J
	ld   hl, $0700
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $0000
	call Play_OBJLstS_SetSpeedV
L065D8B:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L065DC4
	ld   hl, $0103
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	jp   L065DC4
L065D9C:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L065DC4
	ld   hl, $0104
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	jp   L065DC4
L065DAD:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L065DC4
	ld   hl, $0103
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	ld   hl, $0013
	add  hl, de
	ld   [hl], $04
	jp   L065DC4
L065DC4:;J
	ld   hl, $0018
	call L003614
	jp   nc, L065E1F
	ld   hl, $0033
	add  hl, bc
	ld   a, [hl]
	cp   $4C
	jp   z, L065DE1
	ld   a, $10
	ld   h, $04
	call L002DEC
	jp   L065E22
L065DE1:;J
	ld   a, $18
	ld   h, $0C
	call L002DEC
	jp   L065E22
L065DEB:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L065DF4
	call OBJLstS_SyncXFlip
L065DF4:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L065E1F
	inc  hl
	ld   [hl], $10
	ld   hl, $0408
	ld   a, $00
	call Play_Pl_SetMoveDamageNext
	jp   L065E1F
L065E08: db $CD;X
L065E09: db $D9;X
L065E0A: db $2D;X
L065E0B: db $D2;X
L065E0C: db $1F;X
L065E0D: db $5E;X
L065E0E: db $23;X
L065E0F: db $36;X
L065E10: db $06;X
L065E11: db $C3;X
L065E12: db $1F;X
L065E13: db $5E;X
L065E14:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L065E1F
	call Play_Pl_EndMove
	jr   L065E22
L065E1F:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L065E22:;JR
	ret
L065E23:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L065F33
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L065E57
	cp   $04
	jp   z, L065E79
	cp   $08
	jp   z, L065ED0
	cp   $0C
	jp   z, L065EF6
	cp   $10
	jp   z, L065F01
	cp   $14
	jp   z, L065F18
	cp   $18
	jp   z, L065F24
L065E54: db $C3;X
L065E55: db $30;X
L065E56: db $5F;X
L065E57:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L065F30
	ld   hl, $0033
	add  hl, bc
	ld   a, [hl]
	cp   $52
	jp   z, L065E70
	ld   hl, $001C
	add  hl, de
	ld   [hl], $00
	jp   L065F30
L065E70:;J
	ld   hl, $001C
	add  hl, de
	ld   [hl], $FF
	jp   L065F30
L065E79:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L065EB5
	call MoveInputS_CheckMoveLHVer
	jp   c, L065EA6
	jp   nz, L065E97
	ld   hl, $0000
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $0000
	call Play_OBJLstS_SetSpeedV
	jp   L065EB2
L065E97:;J
	ld   hl, $0400
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FD00
	call Play_OBJLstS_SetSpeedV
	jp   L065EB2
L065EA6:;J
	ld   hl, $0600
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FC00
	call Play_OBJLstS_SetSpeedV
L065EB2:;J
	jp   L065EB8
L065EB5:;J
	jp   L065EB8
L065EB8:;J
	ld   hl, $0060
	call L003614
	jp   nc, L065F30
	ld   a, $08
	ld   h, $00
	call L002DEC
	ld   a, $19
	call HomeCall_Sound_ReqPlayExId
	jp   L065F33
L065ED0:;J
	ld   hl, $0108
	ld   a, $90
	call Play_Pl_SetMoveDamage
	call OBJLstS_IsFrameEnd
	jp   nc, L065F30
	call MoveInputS_CheckMoveLHVer
	jp   nz, L065EED
	ld   hl, $001C
	add  hl, de
	ld   [hl], $00
	jp   L065F30
L065EED:;J
	ld   hl, $001C
	add  hl, de
	ld   [hl], $03
	jp   L065F30
L065EF6:;J
	ld   hl, $0108
	ld   a, $90
	call Play_Pl_SetMoveDamage
	jp   L065F30
L065F01:;J
	ld   hl, $0108
	ld   a, $90
	call Play_Pl_SetMoveDamage
	call OBJLstS_IsFrameEnd
	jp   nc, L065F30
	ld   hl, $001C
	add  hl, de
	ld   [hl], $0A
	jp   L065F30
L065F18:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L065F30
	inc  hl
	ld   [hl], $08
	jp   L065F30
L065F24:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L065F30
	call Play_Pl_EndMove
	jp   L065F33
L065F30:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L065F33:;J
	ret
L065F34:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L065FDF
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L065F56
	cp   $04
	jp   z, L065F64
	cp   $08
	jp   z, L065F76
	cp   $0C
	jp   z, L065FBD
L065F56:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L065FDC
	ld   a, $11
	call HomeCall_Sound_ReqPlayExId
	jp   L065FDC
L065F64:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L065FDC
	inc  hl
	ld   [hl], $0C
	ld   hl, $0083
	add  hl, bc
	ld   [hl], $05
	jp   L065FDC
L065F76:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L065FA0
	call L066293
	call MoveInputS_CheckMoveLHVer
	jp   c, L065F9A
	jp   nz, L065F91
	ld   hl, $0480
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	jp   L065FA0
L065F91:;J
	ld   hl, $0600
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	jp   L065FA0
L065F9A:;J
	ld   hl, $0780
	call Play_OBJLstS_SetSpeedH_ByXFlipR
L065FA0:;J
	ld   hl, $0083
	add  hl, bc
	dec  [hl]
	jp   nz, L065FAE
	ld   hl, $0021
	add  hl, bc
	res  7, [hl]
L065FAE:;J
	call OBJLstS_ApplyXSpeed
	call OBJLstS_IsFrameEnd
	jp   nc, L065FDC
	inc  hl
	ld   [hl], $00
	jp   L065FDC
L065FBD:;J
	ld   hl, $0000
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	call OBJLstS_IsFrameEnd
	jp   nc, L065FDC
	ld   hl, $0005
	add  hl, de
	ld   a, [hl]
	cp   PL_FLOOR_POS
	jp   z, L065FD6
L065FD3: db $CD;X
L065FD4: db $93;X
L065FD5: db $62;X
L065FD6:;J
	call Play_Pl_EndMove
	jp   L065FDF
L065FDC:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L065FDF:;J
	ret
L065FE0:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L066292
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L06601B
	cp   $04
	jp   z, L066041
	cp   $08
	jp   z, L06607E
	cp   $0C
	jp   z, L06610A
	cp   $10
	jp   z, L066131
	cp   $14
	jp   z, L0661D8
	cp   $18
	jp   z, L06624A
	cp   $1C
	jp   z, L066271
	cp   $20
	jp   z, L066284
L06601B:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06628F
	inc  hl
	ld   [hl], $01
	ld   hl, $0083
	add  hl, bc
	ld   [hl], $0E
	inc  hl
	ld   [hl], $00
	call Task_PassControlFar
	call L06654D
	call Task_PassControlFar
	ld   a, $18
	call HomeCall_Sound_ReqPlayExId
	call Task_PassControlFar
	jp   L06628F
L066041:;J
	ld   hl, $0020
	add  hl, bc
	bit  7, [hl]
	jp   z, L06605D
L06604A: db $FA;X
L06604B: db $05;X
L06604C: db $C0;X
L06604D: db $E6;X
L06604E: db $7F;X
L06604F: db $C2;X
L066050: db $7B;X
L066051: db $60;X
L066052: db $FA;X
L066053: db $05;X
L066054: db $C0;X
L066055: db $CB;X
L066056: db $7F;X
L066057: db $CA;X
L066058: db $D9;X
L066059: db $60;X
L06605A: db $C3;X
L06605B: db $E2;X
L06605C: db $60;X
L06605D:;J
	call MoveInputS_CheckGAType
	jp   nc, L06607B
	jp   z, L066069
	jp   L06607B
L066069: db $21;X
L06606A: db $8C;X
L06606B: db $3D;X
L06606C: db $CD;X
L06606D: db $A8;X
L06606E: db $2C;X
L06606F: db $DA;X
L066070: db $D9;X
L066071: db $60;X
L066072: db $21;X
L066073: db $95;X
L066074: db $3D;X
L066075: db $CD;X
L066076: db $A8;X
L066077: db $2C;X
L066078: db $DA;X
L066079: db $E2;X
L06607A: db $60;X
L06607B:;J
	jp   L06628F
L06607E:;J
	ld   hl, $0020
	add  hl, bc
	bit  7, [hl]
	jp   z, L06609A
L066087: db $FA;X
L066088: db $05;X
L066089: db $C0;X
L06608A: db $E6;X
L06608B: db $7F;X
L06608C: db $C2;X
L06608D: db $B8;X
L06608E: db $60;X
L06608F: db $FA;X
L066090: db $05;X
L066091: db $C0;X
L066092: db $CB;X
L066093: db $7F;X
L066094: db $CA;X
L066095: db $D9;X
L066096: db $60;X
L066097: db $C3;X
L066098: db $E2;X
L066099: db $60;X
L06609A:;J
	call MoveInputS_CheckGAType
	jp   nc, L0660B8
	jp   z, L0660A6
	jp   L0660B8
L0660A6:;J
	mMvIn_ChkDir MoveInput_DF, L0660D9
	mMvIn_ChkDir MoveInput_DB, L0660E2
L0660B8:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06628F
	ld   hl, $0083
	add  hl, bc
	dec  [hl]
	jp   z, L06628F
	ld   hl, $0045
	add  hl, bc
	bit  4, [hl]
	jp   nz, L066104
	ld   a, $04
	ld   h, $01
	call L002E49
	jp   L066292
L0660D9: db $21;X
L0660DA: db $22;X
L0660DB: db $00;X
L0660DC: db $09;X
L0660DD: db $CB;X
L0660DE: db $8E;X
L0660DF: db $C3;X
L0660E0: db $E8;X
L0660E1: db $60;X
L0660E2:;J
	ld   hl, $0022
	add  hl, bc
	set  1, [hl]
	call Play_Pl_ClearJoyDirBuffer
	ld   a, $10
	ld   h, $01
	call L002E49
	call L0665B9
	ld   hl, $0083
	add  hl, bc
	ld   [hl], $00
	ld   hl, $F8E8
	call Play_StartSuperSparkle
	jp   L066292
L066104:;J
	call Task_PassControlFar
	jp   L06624A
L06610A:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06628F
	ld   hl, $0045
	add  hl, bc
	bit  5, [hl]
	jp   z, L066104
	ld   hl, $0022
	add  hl, bc
	res  0, [hl]
	call L0665B9
	ld   hl, $0083
	add  hl, bc
	ld   [hl], $00
	ld   hl, $F8E8
	call Play_StartSuperSparkle
	jp   L06628F
L066131:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06628F
	inc  hl
	ld   [hl], $28
	ld   hl, $0083
	add  hl, bc
	dec  [hl]
	jp   z, L06628F
	ld   hl, $0020
	add  hl, bc
	bit  7, [hl]
	jp   z, L066156
L06614B: db $FA;X
L06614C: db $05;X
L06614D: db $C0;X
L06614E: db $CB;X
L06614F: db $7F;X
L066150: db $C2;X
L066151: db $8F;X
L066152: db $62;X
L066153: db $C3;X
L066154: db $5F;X
L066155: db $61;X
L066156:;J
	ld   hl, $0045
	add  hl, bc
	bit  5, [hl]
	jp   z, L06628F
	ld   a, [wDipSwitch]
	bit  3, a
	jp   z, L066292
	ld   hl, $0020
	add  hl, bc
	bit  7, [hl]
	jp   z, L06617B
L066170: db $FA;X
L066171: db $05;X
L066172: db $C0;X
L066173: db $E6;X
L066174: db $0F;X
L066175: db $CA;X
L066176: db $84;X
L066177: db $61;X
L066178: db $C3;X
L066179: db $D5;X
L06617A: db $61;X
L06617B:;J
	mMvIn_ChkDirNot MoveInput_DFURD, L0661D5
L066184: db $21;X
L066185: db $84;X
L066186: db $00;X
L066187: db $09;X
L066188: db $7E;X
L066189: db $FE;X
L06618A: db $04;X
L06618B: db $CA;X
L06618C: db $D5;X
L06618D: db $61;X
L06618E: db $CD;X
L06618F: db $53;X
L066190: db $2D;X
L066191: db $21;X
L066192: db $E8;X
L066193: db $F8;X
L066194: db $CD;X
L066195: db $1A;X
L066196: db $38;X
L066197: db $21;X
L066198: db $83;X
L066199: db $00;X
L06619A: db $09;X
L06619B: db $36;X
L06619C: db $00;X
L06619D: db $23;X
L06619E: db $34;X
L06619F: db $7E;X
L0661A0: db $C5;X
L0661A1: db $D5;X
L0661A2: db $FE;X
L0661A3: db $01;X
L0661A4: db $CA;X
L0661A5: db $C3;X
L0661A6: db $61;X
L0661A7: db $FE;X
L0661A8: db $02;X
L0661A9: db $CA;X
L0661AA: db $BD;X
L0661AB: db $61;X
L0661AC: db $FE;X
L0661AD: db $03;X
L0661AE: db $CA;X
L0661AF: db $B7;X
L0661B0: db $61;X
L0661B1: db $01;X
L0661B2: db $6F;X
L0661B3: db $59;X
L0661B4: db $C3;X
L0661B5: db $C6;X
L0661B6: db $61;X
L0661B7: db $01;X
L0661B8: db $69;X
L0661B9: db $59;X
L0661BA: db $C3;X
L0661BB: db $C6;X
L0661BC: db $61;X
L0661BD: db $01;X
L0661BE: db $63;X
L0661BF: db $59;X
L0661C0: db $C3;X
L0661C1: db $C6;X
L0661C2: db $61;X
L0661C3: db $01;X
L0661C4: db $5D;X
L0661C5: db $59;X
L0661C6: db $21;X
L0661C7: db $80;X
L0661C8: db $00;X
L0661C9: db $19;X
L0661CA: db $E5;X
L0661CB: db $D1;X
L0661CC: db $21;X
L0661CD: db $11;X
L0661CE: db $00;X
L0661CF: db $19;X
L0661D0: db $71;X
L0661D1: db $23;X
L0661D2: db $70;X
L0661D3: db $D1;X
L0661D4: db $C1;X
L0661D5:;J
	jp   L066292
L0661D8:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L06623E
	ld   hl, $0084
	add  hl, bc
	ld   a, [hl]
	cp   $04
	jp   z, L06622B
	cp   $03
	jp   z, L06621E
	cp   $02
	jp   z, L066211
	cp   $01
	jp   z, L066204
	ld   a, $10
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $1408
	ld   a, $41
	jp   L066235
L066204: db $3E;X
L066205: db $10;X
L066206: db $CD;X
L066207: db $16;X
L066208: db $10;X
L066209: db $21;X
L06620A: db $08;X
L06620B: db $19;X
L06620C: db $3E;X
L06620D: db $41;X
L06620E: db $C3;X
L06620F: db $35;X
L066210: db $62;X
L066211: db $3E;X
L066212: db $16;X
L066213: db $CD;X
L066214: db $16;X
L066215: db $10;X
L066216: db $21;X
L066217: db $08;X
L066218: db $03;X
L066219: db $3E;X
L06621A: db $D0;X
L06621B: db $C3;X
L06621C: db $35;X
L06621D: db $62;X
L06621E: db $3E;X
L06621F: db $16;X
L066220: db $CD;X
L066221: db $16;X
L066222: db $10;X
L066223: db $21;X
L066224: db $08;X
L066225: db $03;X
L066226: db $3E;X
L066227: db $D0;X
L066228: db $C3;X
L066229: db $35;X
L06622A: db $62;X
L06622B: db $3E;X
L06622C: db $16;X
L06622D: db $CD;X
L06622E: db $16;X
L06622F: db $10;X
L066230: db $21;X
L066231: db $08;X
L066232: db $03;X
L066233: db $3E;X
L066234: db $D0;X
L066235:;J
	call Play_Pl_SetMoveDamageNext
	call Play_Proj_CopyMoveDamageFromPl
	call L066368
L06623E:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06628F
	inc  hl
	ld   [hl], $03
	jp   L06628F
L06624A:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06628F
	ld   hl, $0033
	add  hl, bc
	ld   a, [hl]
	cp   $68
	jp   z, L066264
	cp   $6A
	jp   z, L066264
	call Play_Pl_EndMove
	jr   L066292
L066264:;J
	ld   a, $1C
	ld   h, $FF
	call L002E49
	call L0665CC
	jp   L066292
L066271:;J
	ld   hl, $0060
	call L003614
	jp   nc, L06628F
	ld   a, $20
	ld   h, $03
	call L002DEC
	jp   L066292
L066284:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06628F
	call Play_Pl_EndMove
	jr   L066292
L06628F:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L066292:;JR
	ret
L066293:;C
	ld   a, $1D
	call HomeCall_Sound_ReqPlayExId
	push bc
	push de
	call MoveInputS_CanStartProjMove
	jp   nz, L0662E5
	call L0024F8
	ld   hl, $0020
	add  hl, de
	ld   [hl], $05
	inc  hl
	ld   [hl], $52
	inc  hl
	ld   [hl], $73
	ld   hl, $0010
	add  hl, de
	ld   [hl], $01
	inc  hl
	ld   [hl], $A3
	inc  hl
	ld   [hl], $59
	inc  hl
	ld   [hl], $00
	ld   hl, $001B
	add  hl, de
	ld   [hl], $00
	inc  hl
	ld   [hl], $00
	ld   hl, $0027
	add  hl, de
	ld   [hl], $00
	inc  hl
	ld   [hl], $0B
	call OBJLstS_Overlap
	ld   hl, $0000
	call Play_OBJLstS_MoveH_ByXFlipR
	ld   hl, $0000
	call Play_OBJLstS_MoveV
	ld   hl, $0000
	call Play_OBJLstS_SetSpeedH_ByXFlipR
L0662E5:
	pop  de
	pop  bc
	ret
L0662E8:;C
	ld   a, $16
	call HomeCall_Sound_ReqPlayExId
	push bc
	push de
	ld   hl, $0050
	add  hl, bc
	ld   a, [hl]
	cp   $28
	jp   z, L0662FD
	xor  a
	jp   L0662FE
L0662FD:;J
	scf
L0662FE:;J
	ld   hl, $0022
	push af
	add  hl, bc
	pop  af
	ld   a, [hl]
	push af
	call L0024F8
	ld   hl, $0020
	add  hl, de
	ld   [hl], $06
	inc  hl
	ld   [hl], $9E
	inc  hl
	ld   [hl], $52
	ld   hl, $0010
	add  hl, de
	ld   [hl], $01
	inc  hl
	ld   [hl], $45
	inc  hl
	ld   [hl], $59
	inc  hl
	ld   [hl], $00
	ld   hl, $001B
	add  hl, de
	ld   [hl], $00
	inc  hl
	ld   [hl], $00
	ld   hl, $0027
	add  hl, de
	ld   [hl], $00
	call OBJLstS_Overlap
	ld   hl, $1000
	call Play_OBJLstS_MoveH_ByXFlipR
	ld   hl, $FC00
	call Play_OBJLstS_MoveV
	pop  af
	jp   nc, L06634E
	bit  1, a
	jp   nz, L06635F
	jp   L066353
L06634E:;J
	bit  1, a
	jp   nz, L066359
L066353:;J
	ld   hl, $0100
	jp   L066362
L066359:;J
	ld   hl, $0200
	jp   L066362
L06635F:;J
	ld   hl, $0400
L066362:;J
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	pop  de
	pop  bc
	ret
L066368:;C
	push bc
	push de
	ld   hl, $0084
	add  hl, bc
	ld   a, [hl]
	push af
	call MoveInputS_CheckMoveLHVer
	jp   nz, L06637A
	xor  a
	jp   L06637B
L06637A:;J
	scf
L06637B:;J
	ld   hl, $0033
	push af
	add  hl, bc
	pop  af
	ld   a, [hl]
	push af
	ld   hl, $0084
	add  hl, bc
	ld   a, [hl]
	push af
	call L0024F8
	ld   hl, $0020
	add  hl, de
	ld   [hl], $06
	inc  hl
	ld   [hl], $77
	inc  hl
	ld   [hl], $64
	pop  af
	push bc
	cp   $00
	jp   z, L0663CE
L06639F: db $FE;X
L0663A0: db $01;X
L0663A1: db $CA;X
L0663A2: db $C6;X
L0663A3: db $63;X
L0663A4: db $FE;X
L0663A5: db $02;X
L0663A6: db $CA;X
L0663A7: db $BE;X
L0663A8: db $63;X
L0663A9: db $FE;X
L0663AA: db $03;X
L0663AB: db $CA;X
L0663AC: db $B6;X
L0663AD: db $63;X
L0663AE: db $01;X
L0663AF: db $9D;X
L0663B0: db $59;X
L0663B1: db $3E;X
L0663B2: db $04;X
L0663B3: db $C3;X
L0663B4: db $D3;X
L0663B5: db $63;X
L0663B6: db $01;X
L0663B7: db $97;X
L0663B8: db $59;X
L0663B9: db $3E;X
L0663BA: db $04;X
L0663BB: db $C3;X
L0663BC: db $D3;X
L0663BD: db $63;X
L0663BE: db $01;X
L0663BF: db $91;X
L0663C0: db $59;X
L0663C1: db $3E;X
L0663C2: db $04;X
L0663C3: db $C3;X
L0663C4: db $D3;X
L0663C5: db $63;X
L0663C6: db $01;X
L0663C7: db $87;X
L0663C8: db $59;X
L0663C9: db $3E;X
L0663CA: db $01;X
L0663CB: db $C3;X
L0663CC: db $D3;X
L0663CD: db $63;X
L0663CE:;J
	ld   bc, $5975
	ld   a, $01
	ld   hl, $0027
	add  hl, de
	ld   [hl], a
	ld   hl, $0010
	add  hl, de
	ld   [hl], $01
	inc  hl
	ld   [hl], c
	inc  hl
	ld   [hl], b
	inc  hl
	ld   [hl], $00
	pop  bc
	ld   hl, $001B
	add  hl, de
	ld   [hl], $00
	inc  hl
	ld   [hl], $00
	call OBJLstS_Overlap
	ld   hl, $1000
	call Play_OBJLstS_MoveH_ByXFlipR
	ld   hl, $F000
	call Play_OBJLstS_MoveV
	pop  af
	jp   nc, L06640F
	cp   $64
	jp   z, L066432
	cp   $66
	jp   z, L066432
	jp   L06645E
L06640F:;J
	cp   $64
	jp   z, L06641C
	cp   $66
	jp   z, L06641C
	jp   L066448
L06641C:;J
	pop  af
	ld   hl, $0500
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $0000
	call Play_OBJLstS_SetSpeedV
	ld   hl, $0028
	add  hl, de
	ld   [hl], $01
	jp   L066474
L066432:;J
	pop  af
	ld   hl, $0500
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $0100
	call Play_OBJLstS_SetSpeedV
	ld   hl, $0028
	add  hl, de
	ld   [hl], $02
	jp   L066474
L066448:;J
	pop  af
	ld   hl, $0500
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $0400
	call Play_OBJLstS_SetSpeedV
	ld   hl, $0028
	add  hl, de
	ld   [hl], $03
	jp   L066474
L06645E:;J
	pop  af
	ld   hl, $0500
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $0500
	call Play_OBJLstS_SetSpeedV
	ld   hl, $0028
	add  hl, de
	ld   [hl], $04
	jp   L066474
L066474:;J
	pop  de
	pop  bc
	ret
L066477:;I
	call L0028B2
	jp   c, L066549
	call OBJLstS_DoAnimTiming_Loop_by_DE
	ld   hl, $0028
	add  hl, de
	ld   a, [hl]
	cp   $02
	jp   z, L0664BD
	cp   $03
	jp   z, L0664F8
	cp   $04
	jp   z, L0664BD
	ld   hl, $0027
	add  hl, de
	ld   a, [hl]
	cp   $04
	jp   nz, L0664BA
L06649E: db $21;X
L06649F: db $26;X
L0664A0: db $00;X
L0664A1: db $19;X
L0664A2: db $7E;X
L0664A3: db $FE;X
L0664A4: db $00;X
L0664A5: db $CA;X
L0664A6: db $B1;X
L0664A7: db $64;X
L0664A8: db $21;X
L0664A9: db $80;X
L0664AA: db $00;X
L0664AB: db $CD;X
L0664AC: db $69;X
L0664AD: db $35;X
L0664AE: db $C3;X
L0664AF: db $48;X
L0664B0: db $65;X
L0664B1: db $21;X
L0664B2: db $00;X
L0664B3: db $03;X
L0664B4: db $CD;X
L0664B5: db $69;X
L0664B6: db $35;X
L0664B7: db $C3;X
L0664B8: db $48;X
L0664B9: db $65;X
L0664BA:;J
	jp   L066548
L0664BD:;J
	ld   hl, $0027
	add  hl, de
	ld   a, [hl]
	cp   $04
	jp   nz, L0664EF
L0664C7: db $21;X
L0664C8: db $26;X
L0664C9: db $00;X
L0664CA: db $19;X
L0664CB: db $7E;X
L0664CC: db $FE;X
L0664CD: db $00;X
L0664CE: db $CA;X
L0664CF: db $E0;X
L0664D0: db $64;X
L0664D1: db $21;X
L0664D2: db $80;X
L0664D3: db $00;X
L0664D4: db $CD;X
L0664D5: db $69;X
L0664D6: db $35;X
L0664D7: db $21;X
L0664D8: db $00;X
L0664D9: db $02;X
L0664DA: db $CD;X
L0664DB: db $72;X
L0664DC: db $36;X
L0664DD: db $C3;X
L0664DE: db $48;X
L0664DF: db $65;X
L0664E0: db $21;X
L0664E1: db $00;X
L0664E2: db $04;X
L0664E3: db $CD;X
L0664E4: db $69;X
L0664E5: db $35;X
L0664E6: db $21;X
L0664E7: db $A0;X
L0664E8: db $FF;X
L0664E9: db $CD;X
L0664EA: db $72;X
L0664EB: db $36;X
L0664EC: db $C3;X
L0664ED: db $48;X
L0664EE: db $65;X
L0664EF:;J
	ld   hl, $FFA0
	call L003672
	jp   L066548
L0664F8:;J
	ld   hl, $0027
	add  hl, de
	ld   a, [hl]
	cp   $04
	jp   nz, L06653C
L066502: db $21;X
L066503: db $26;X
L066504: db $00;X
L066505: db $19;X
L066506: db $7E;X
L066507: db $FE;X
L066508: db $00;X
L066509: db $CA;X
L06650A: db $24;X
L06650B: db $65;X
L06650C: db $21;X
L06650D: db $80;X
L06650E: db $00;X
L06650F: db $CD;X
L066510: db $69;X
L066511: db $35;X
L066512: db $21;X
L066513: db $00;X
L066514: db $FE;X
L066515: db $CD;X
L066516: db $AD;X
L066517: db $35;X
L066518: db $21;X
L066519: db $00;X
L06651A: db $00;X
L06651B: db $CD;X
L06651C: db $72;X
L06651D: db $36;X
L06651E: db $DA;X
L06651F: db $49;X
L066520: db $65;X
L066521: db $C3;X
L066522: db $48;X
L066523: db $65;X
L066524: db $21;X
L066525: db $00;X
L066526: db $03;X
L066527: db $CD;X
L066528: db $69;X
L066529: db $35;X
L06652A: db $21;X
L06652B: db $00;X
L06652C: db $02;X
L06652D: db $CD;X
L06652E: db $AD;X
L06652F: db $35;X
L066530: db $21;X
L066531: db $00;X
L066532: db $00;X
L066533: db $CD;X
L066534: db $72;X
L066535: db $36;X
L066536: db $DA;X
L066537: db $49;X
L066538: db $65;X
L066539: db $C3;X
L06653A: db $48;X
L06653B: db $65;X
L06653C:;J
	ld   hl, $0000
	call L003672
	jp   c, L066549
	jp   L066548
L066548:;J
	ret
L066549:;J
	call OBJLstS_Hide
	ret
L06654D:;C
	push bc
	push de
	call L0024F8
	ld   hl, $0020
	add  hl, de
	ld   [hl], $06
	inc  hl
	ld   [hl], $DF
	inc  hl
	ld   [hl], $65
	ld   hl, $0010
	add  hl, de
	ld   [hl], $01
	inc  hl
	ld   [hl], $57
	inc  hl
	ld   [hl], $59
	inc  hl
	ld   [hl], $00
	ld   hl, $001B
	add  hl, de
	ld   [hl], $00
	inc  hl
	ld   [hl], $00
	call OBJLstS_Overlap
	ld   hl, $0000
	call Play_OBJLstS_MoveH_ByXFlipR
	ld   hl, $F000
	call Play_OBJLstS_MoveV
	push bc
	ld   hl, $0003
	add  hl, de
	push hl
	pop  bc
	ld   hl, $0028
	add  hl, de
	ld   a, [bc]
	ldi  [hl], a
	inc  bc
	inc  bc
	ld   a, [bc]
	ld   [hl], a
	pop  bc
	ld   hl, $0027
	add  hl, de
	ld   [hl], $02
	xor  a
	ld   hl, $002A
	add  hl, de
	ld   [hl], $00
	inc  hl
	ld   [hl], $80
	inc  hl
	ldi  [hl], a
	ld   [hl], a
	ld   hl, $0030
	add  hl, de
	ld   [hl], $00
	ld   hl, $0031
	add  hl, de
	ld   [hl], $08
	pop  de
	pop  bc
	ret
L0665B9:;C
	push bc
	push de
	push de
	pop  bc
	ld   hl, $0080
	add  hl, bc
	push hl
	pop  de
	ld   hl, $0030
	add  hl, de
	ld   [hl], $01
	pop  de
	pop  bc
	ret
L0665CC:;C
	push bc
	push de
	push de
	pop  bc
	ld   hl, $0080
	add  hl, bc
	push hl
	pop  de
	ld   hl, $0030
	add  hl, de
	ld   [hl], $FF
	pop  de
	pop  bc
	ret
L0665DF:;I
	call L06679B
	ret  c
	ld   hl, $0020
	add  hl, bc
	bit  6, [hl]
	jp   z, L066600
	ld   hl, $0030
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L06662D
	cp   $01
	jp   z, L066688
	cp   $02
	jp   z, L066681
L066600:;J
	ld   hl, $002A
	add  hl, de
	ld   [hl], $00
	inc  hl
	ld   [hl], $40
	ld   hl, $0023
	add  hl, de
	xor  a
	ldi  [hl], a
	ldi  [hl], a
	ld   [hl], a
	ld   hl, $0020
	add  hl, de
	ld   [hl], $06
	inc  hl
	ld   [hl], $2A
	inc  hl
	ld   [hl], $67
	ld   hl, $002C
	add  hl, de
	ld   [hl], $04
	inc  hl
	ld   [hl], $05
	ld   hl, $0031
	add  hl, de
	ld   [hl], $0E
	ret
L06662D:;J
	ld   b, $00
	ld   c, $F0
	call L0667CF
	ld   hl, $002C
	add  hl, de
	ld   a, [hl]
	cp   $05
	jp   z, L06663F
	inc  [hl]
L06663F:;J
	ld   hl, $002A
	add  hl, de
	ld   a, [hl]
	add  a, $20
	ld   [hl], a
	ld   hl, $002C
	add  hl, de
	ld   b, [hl]
	call L0667BD
	ld   hl, $0028
	add  hl, de
	ld   a, [hl]
	add  b
	ld   hl, $0003
	add  hl, de
	ld   [hl], a
	ld   hl, $002D
	add  hl, de
	ld   a, [hl]
	cp   $06
	jp   z, L066665
	inc  [hl]
L066665:;J
	ld   hl, $002B
	add  hl, de
	ld   a, [hl]
	add  a, $22
	ld   [hl], a
	ld   hl, $002D
	add  hl, de
	ld   b, [hl]
	call L0667BD
	ld   hl, $0029
	add  hl, de
	ld   a, [hl]
	add  b
	ld   hl, $0005
	add  hl, de
	ld   [hl], a
	ret
L066681:;J
	ld   b, $08
	ld   c, $E8
	call L0667CF
L066688:;J
	ld   hl, $0032
	add  hl, de
	inc  [hl]
	ld   a, [hl]
	and  a, $07
	jp   nz, L0666C1
	ld   hl, $0031
	add  hl, de
	ld   a, [hl]
	or   a
	jp   z, L0666C1
	dec  [hl]
	jp   nz, L0666A6
	ld   hl, $0030
	add  hl, de
	ld   [hl], $02
L0666A6:;J
	ld   hl, $0001
	add  hl, de
	bit  5, [hl]
	jp   nz, L0666B7
L0666AF: db $21;X
L0666B0: db $28;X
L0666B1: db $00;X
L0666B2: db $19;X
L0666B3: db $34;X
L0666B4: db $C3;X
L0666B5: db $BC;X
L0666B6: db $66;X
L0666B7:;J
	ld   hl, $0028
	add  hl, de
	dec  [hl]
	ld   hl, $0029
	add  hl, de
	dec  [hl]
L0666C1:;J
	ld   hl, $002E
	add  hl, de
	inc  [hl]
	ld   a, [hl]
	and  a, $1F
	ld   b, a
	ld   hl, $002C
	add  hl, de
	ld   a, [hl]
	cp   $01
	jp   z, L0666DA
	ld   a, b
	or   a
	jp   nz, L0666DA
	dec  [hl]
L0666DA:;J
	ld   hl, $002A
	add  hl, de
	ld   a, [hl]
	add  a, $20
	ld   [hl], a
	ld   hl, $002C
	add  hl, de
	ld   b, [hl]
	call L0667BD
	ld   hl, $0028
	add  hl, de
	ld   a, [hl]
	add  b
	ld   hl, $0003
	add  hl, de
	ld   [hl], a
	ld   hl, $002F
	add  hl, de
	inc  [hl]
	ld   a, [hl]
	and  a, $20
	ld   b, a
	ld   hl, $002D
	add  hl, de
	ld   a, [hl]
	cp   $01
	jp   z, L06670E
	ld   a, b
	or   a
	jp   nz, L06670E
	dec  [hl]
L06670E:;J
	ld   hl, $002B
	add  hl, de
	ld   a, [hl]
	add  a, $1F
	ld   [hl], a
	ld   hl, $002D
	add  hl, de
	ld   b, [hl]
	call L0667BD
	ld   hl, $0029
	add  hl, de
	ld   a, [hl]
	add  b
	ld   hl, $0005
	add  hl, de
	ld   [hl], a
	ret
L06672A:;I
	call L06679B
	ret  c
	ld   hl, $0023
	add  hl, de
	xor  a
	ldi  [hl], a
	ldi  [hl], a
	ld   [hl], a
	ld   hl, $0031
	add  hl, de
	dec  [hl]
	jp   z, OBJLstS_Hide
	ld   hl, $002E
	add  hl, de
	inc  [hl]
	ld   a, [hl]
	and  a, $03
	ld   b, a
	ld   hl, $002C
	add  hl, de
	ld   a, b
	or   a
	jp   nz, L066751
	inc  [hl]
L066751:;J
	ld   hl, $002A
	add  hl, de
	ld   a, [hl]
	add  a, $20
	ld   [hl], a
	ld   hl, $002C
	add  hl, de
	ld   b, [hl]
	call L0667BD
	ld   hl, $0028
	add  hl, de
	ld   a, [hl]
	add  b
	ld   hl, $0003
	add  hl, de
	ld   [hl], a
	ld   hl, $002F
	add  hl, de
	inc  [hl]
	ld   a, [hl]
	and  a, $07
	ld   b, a
	ld   hl, $002D
	add  hl, de
	ld   a, b
	or   a
	jp   nz, L06677F
	inc  [hl]
L06677F:;J
	ld   hl, $002B
	add  hl, de
	ld   a, [hl]
	add  a, $20
	ld   [hl], a
	ld   hl, $002D
	add  hl, de
	ld   b, [hl]
	call L0667BD
	ld   hl, $0029
	add  hl, de
	ld   a, [hl]
	add  b
	ld   hl, $0005
	add  hl, de
	ld   [hl], a
	ret
L06679B:;C
	ld   hl, $002B
	add  hl, bc
	ld   a, [hl]
	cp   $01
	jp   z, L0667B0
	ld   a, [wPlayTimer]
	bit  0, a
	jp   z, L0667BB
	jp   L0667B8
L0667B0: db $FA;X
L0667B1: db $08;X
L0667B2: db $C0;X
L0667B3: db $CB;X
L0667B4: db $47;X
L0667B5: db $C2;X
L0667B6: db $BB;X
L0667B7: db $67;X
L0667B8:;J
	scf
	ccf
	ret
L0667BB:;J
	scf
	ret
L0667BD:;C
	push de
	push hl
	call L06680F
L0667C2:;J
	sla  l
	rl   h
	dec  b
	jp   nz, L0667C2
	push hl
	pop  bc
	pop  hl
	pop  de
	ret
L0667CF:;C
	push bc
	push de
	ld   hl, $0028
	add  hl, de
	push hl
	pop  bc
	push de
	ld   hl, $FF80
	add  hl, de
	ld   de, $0003
	add  hl, de
	pop  de
	ld   a, [hl]
	ld   [bc], a
	inc  hl
	inc  hl
	inc  bc
	ld   a, [hl]
	ld   [bc], a
	pop  de
	pop  bc
	ld   hl, $0001
	add  hl, de
	bit  5, [hl]
	jp   nz, L0667FD
	ld   hl, $0028
	add  hl, de
	ld   a, [hl]
	add  b
	ld   [hl], a
	jp   L066807
L0667FD:;J
	ld   hl, $0028
	add  hl, de
	ld   a, b
	cpl
	inc  a
	ld   b, [hl]
	add  b
	ld   [hl], a
L066807:;J
	ld   hl, $0029
	add  hl, de
	ld   a, [hl]
	add  c
	ld   [hl], a
	ret
L06680F:;C
	push bc
	ld   b, $00
	ld   c, a
	sla  c
	rl   b
	ld   hl, $683A
	add  hl, bc
	ld   c, [hl]
	inc  hl
	ld   b, [hl]
	sra  b
	rr   c
	sra  b
	rr   c
	sra  b
	rr   c
	sra  b
	rr   c
	sra  b
	rr   c
	sra  b
	rr   c
	push bc
	pop  hl
	pop  bc
	ret
L06683A: db $00
L06683B: db $00
L06683C: db $92
L06683D: db $01
L06683E: db $24
L06683F: db $03
L066840: db $B5
L066841: db $04
L066842: db $46
L066843: db $06
L066844: db $D6
L066845: db $07
L066846: db $64
L066847: db $09
L066848: db $F1
L066849: db $0A
L06684A: db $7C
L06684B: db $0C
L06684C: db $06
L06684D: db $0E
L06684E: db $8D
L06684F: db $0F
L066850: db $12
L066851: db $11
L066852: db $94
L066853: db $12
L066854: db $13
L066855: db $14
L066856: db $90
L066857: db $15
L066858: db $09
L066859: db $17
L06685A: db $7E
L06685B: db $18
L06685C: db $EF
L06685D: db $19
L06685E: db $5D
L06685F: db $1B
L066860: db $C6
L066861: db $1C
L066862: db $2B
L066863: db $1E
L066864: db $8C
L066865: db $1F
L066866: db $E7
L066867: db $20
L066868: db $3D
L066869: db $22
L06686A: db $8E
L06686B: db $23
L06686C: db $DA
L06686D: db $24
L06686E: db $20
L06686F: db $26
L066870: db $60
L066871: db $27
L066872: db $9A
L066873: db $28
L066874: db $CE
L066875: db $29
L066876: db $FB
L066877: db $2A
L066878: db $21
L066879: db $2C
L06687A: db $41
L06687B: db $2D
L06687C: db $5A
L06687D: db $2E
L06687E: db $6C
L06687F: db $2F
L066880: db $76
L066881: db $30
L066882: db $79
L066883: db $31
L066884: db $74
L066885: db $32
L066886: db $68
L066887: db $33
L066888: db $53
L066889: db $34
L06688A: db $37
L06688B: db $35
L06688C: db $12
L06688D: db $36
L06688E: db $E5
L06688F: db $36
L066890: db $AF
L066891: db $37
L066892: db $71
L066893: db $38
L066894: db $2B
L066895: db $39
L066896: db $DB
L066897: db $39
L066898: db $82
L066899: db $3A
L06689A: db $21
L06689B: db $3B
L06689C: db $B6
L06689D: db $3B
L06689E: db $42
L06689F: db $3C
L0668A0: db $C5
L0668A1: db $3C
L0668A2: db $3F
L0668A3: db $3D
L0668A4: db $AF
L0668A5: db $3D
L0668A6: db $15
L0668A7: db $3E
L0668A8: db $72
L0668A9: db $3E
L0668AA: db $C5
L0668AB: db $3E
L0668AC: db $0F
L0668AD: db $3F
L0668AE: db $4F
L0668AF: db $3F
L0668B0: db $85
L0668B1: db $3F
L0668B2: db $B1
L0668B3: db $3F
L0668B4: db $D4
L0668B5: db $3F
L0668B6: db $EC
L0668B7: db $3F
L0668B8: db $FB
L0668B9: db $3F
L0668BA: db $00
L0668BB: db $40
L0668BC: db $FB
L0668BD: db $3F
L0668BE: db $EC
L0668BF: db $3F
L0668C0: db $D4
L0668C1: db $3F
L0668C2: db $B1
L0668C3: db $3F
L0668C4: db $85
L0668C5: db $3F
L0668C6: db $4F
L0668C7: db $3F
L0668C8: db $0F
L0668C9: db $3F
L0668CA: db $C5
L0668CB: db $3E
L0668CC: db $72
L0668CD: db $3E
L0668CE: db $15
L0668CF: db $3E
L0668D0: db $AF
L0668D1: db $3D
L0668D2: db $3F
L0668D3: db $3D
L0668D4: db $C5
L0668D5: db $3C
L0668D6: db $42
L0668D7: db $3C
L0668D8: db $B6
L0668D9: db $3B
L0668DA: db $21
L0668DB: db $3B
L0668DC: db $82
L0668DD: db $3A
L0668DE: db $DB
L0668DF: db $39
L0668E0: db $2B
L0668E1: db $39
L0668E2: db $71
L0668E3: db $38
L0668E4: db $AF
L0668E5: db $37
L0668E6: db $E5
L0668E7: db $36
L0668E8: db $12
L0668E9: db $36
L0668EA: db $37
L0668EB: db $35
L0668EC: db $53
L0668ED: db $34
L0668EE: db $68
L0668EF: db $33
L0668F0: db $74
L0668F1: db $32
L0668F2: db $79
L0668F3: db $31
L0668F4: db $76
L0668F5: db $30
L0668F6: db $6C
L0668F7: db $2F
L0668F8: db $5A
L0668F9: db $2E
L0668FA: db $41
L0668FB: db $2D
L0668FC: db $21
L0668FD: db $2C
L0668FE: db $FB
L0668FF: db $2A
L066900: db $CE
L066901: db $29
L066902: db $9A
L066903: db $28
L066904: db $60
L066905: db $27
L066906: db $20
L066907: db $26
L066908: db $DA
L066909: db $24
L06690A: db $8E
L06690B: db $23
L06690C: db $3D
L06690D: db $22
L06690E: db $E7
L06690F: db $20
L066910: db $8C
L066911: db $1F
L066912: db $2B
L066913: db $1E
L066914: db $C6
L066915: db $1C
L066916: db $5D
L066917: db $1B
L066918: db $EF
L066919: db $19
L06691A: db $7E
L06691B: db $18
L06691C: db $09
L06691D: db $17
L06691E: db $90
L06691F: db $15
L066920: db $13
L066921: db $14
L066922: db $94
L066923: db $12
L066924: db $12
L066925: db $11
L066926: db $8D
L066927: db $0F
L066928: db $06
L066929: db $0E
L06692A: db $7C
L06692B: db $0C
L06692C: db $F1
L06692D: db $0A
L06692E: db $64
L06692F: db $09
L066930: db $D6
L066931: db $07
L066932: db $46
L066933: db $06
L066934: db $B5
L066935: db $04
L066936: db $24
L066937: db $03
L066938: db $92
L066939: db $01
L06693A: db $00
L06693B: db $00
L06693C: db $6E
L06693D: db $FE
L06693E: db $DC
L06693F: db $FC
L066940: db $4B
L066941: db $FB
L066942: db $BA
L066943: db $F9
L066944: db $2A
L066945: db $F8
L066946: db $9C
L066947: db $F6
L066948: db $0F
L066949: db $F5
L06694A: db $84
L06694B: db $F3
L06694C: db $FA
L06694D: db $F1
L06694E: db $73
L06694F: db $F0
L066950: db $EE
L066951: db $EE
L066952: db $6C
L066953: db $ED
L066954: db $ED
L066955: db $EB
L066956: db $70
L066957: db $EA
L066958: db $F8
L066959: db $E8
L06695A: db $82
L06695B: db $E7
L06695C: db $11
L06695D: db $E6
L06695E: db $A3
L06695F: db $E4
L066960: db $3A
L066961: db $E3
L066962: db $D5
L066963: db $E1
L066964: db $74
L066965: db $E0
L066966: db $19
L066967: db $DF
L066968: db $C3
L066969: db $DD
L06696A: db $72
L06696B: db $DC
L06696C: db $26
L06696D: db $DB
L06696E: db $E0
L06696F: db $D9
L066970: db $A0
L066971: db $D8
L066972: db $66
L066973: db $D7
L066974: db $32
L066975: db $D6
L066976: db $05
L066977: db $D5
L066978: db $DF
L066979: db $D3
L06697A: db $BF
L06697B: db $D2
L06697C: db $A6
L06697D: db $D1
L06697E: db $94
L06697F: db $D0
L066980: db $8A
L066981: db $CF
L066982: db $87
L066983: db $CE
L066984: db $8C
L066985: db $CD
L066986: db $98
L066987: db $CC
L066988: db $AD
L066989: db $CB
L06698A: db $C9
L06698B: db $CA
L06698C: db $EE
L06698D: db $C9
L06698E: db $1B
L06698F: db $C9
L066990: db $51
L066991: db $C8
L066992: db $8F
L066993: db $C7
L066994: db $D5
L066995: db $C6
L066996: db $25
L066997: db $C6
L066998: db $7E
L066999: db $C5
L06699A: db $DF
L06699B: db $C4
L06699C: db $4A
L06699D: db $C4
L06699E: db $BE
L06699F: db $C3
L0669A0: db $3B
L0669A1: db $C3
L0669A2: db $C2
L0669A3: db $C2
L0669A4: db $52
L0669A5: db $C2
L0669A6: db $EB
L0669A7: db $C1
L0669A8: db $8E
L0669A9: db $C1
L0669AA: db $3B
L0669AB: db $C1
L0669AC: db $F1
L0669AD: db $C0
L0669AE: db $B1
L0669AF: db $C0
L0669B0: db $7B
L0669B1: db $C0
L0669B2: db $4F
L0669B3: db $C0
L0669B4: db $2C
L0669B5: db $C0
L0669B6: db $14
L0669B7: db $C0
L0669B8: db $05
L0669B9: db $C0
L0669BA: db $00
L0669BB: db $C0
L0669BC: db $05
L0669BD: db $C0
L0669BE: db $14
L0669BF: db $C0
L0669C0: db $2C
L0669C1: db $C0
L0669C2: db $4F
L0669C3: db $C0
L0669C4: db $7B
L0669C5: db $C0
L0669C6: db $B1
L0669C7: db $C0
L0669C8: db $F1
L0669C9: db $C0
L0669CA: db $3B
L0669CB: db $C1
L0669CC: db $8E
L0669CD: db $C1
L0669CE: db $EB
L0669CF: db $C1
L0669D0: db $52
L0669D1: db $C2
L0669D2: db $C2
L0669D3: db $C2
L0669D4: db $3B
L0669D5: db $C3
L0669D6: db $BE
L0669D7: db $C3
L0669D8: db $4A
L0669D9: db $C4
L0669DA: db $DF
L0669DB: db $C4
L0669DC: db $7E
L0669DD: db $C5
L0669DE: db $25
L0669DF: db $C6
L0669E0: db $D5
L0669E1: db $C6
L0669E2: db $8F
L0669E3: db $C7
L0669E4: db $51
L0669E5: db $C8
L0669E6: db $1B
L0669E7: db $C9
L0669E8: db $EE
L0669E9: db $C9
L0669EA: db $C9
L0669EB: db $CA
L0669EC: db $AD
L0669ED: db $CB
L0669EE: db $98
L0669EF: db $CC
L0669F0: db $8C
L0669F1: db $CD
L0669F2: db $87
L0669F3: db $CE
L0669F4: db $8A
L0669F5: db $CF
L0669F6: db $94
L0669F7: db $D0
L0669F8: db $A6
L0669F9: db $D1
L0669FA: db $BF
L0669FB: db $D2
L0669FC: db $DF
L0669FD: db $D3
L0669FE: db $05
L0669FF: db $D5
L066A00: db $32
L066A01: db $D6
L066A02: db $66
L066A03: db $D7
L066A04: db $A0
L066A05: db $D8
L066A06: db $E0
L066A07: db $D9
L066A08: db $26
L066A09: db $DB
L066A0A: db $72
L066A0B: db $DC
L066A0C: db $C3
L066A0D: db $DD
L066A0E: db $19
L066A0F: db $DF
L066A10: db $74
L066A11: db $E0
L066A12: db $D5
L066A13: db $E1
L066A14: db $3A
L066A15: db $E3
L066A16: db $A3
L066A17: db $E4
L066A18: db $11
L066A19: db $E6
L066A1A: db $82
L066A1B: db $E7
L066A1C: db $F8
L066A1D: db $E8
L066A1E: db $70
L066A1F: db $EA
L066A20: db $ED
L066A21: db $EB
L066A22: db $6C
L066A23: db $ED
L066A24: db $EE
L066A25: db $EE
L066A26: db $73
L066A27: db $F0
L066A28: db $FA
L066A29: db $F1
L066A2A: db $84
L066A2B: db $F3
L066A2C: db $0F
L066A2D: db $F5
L066A2E: db $9C
L066A2F: db $F6
L066A30: db $2A
L066A31: db $F8
L066A32: db $BA
L066A33: db $F9
L066A34: db $4B
L066A35: db $FB
L066A36: db $DC
L066A37: db $FC
L066A38: db $6E
L066A39: db $FE
L066A3A:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L066A76
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L066A58
	ld   hl, $0039
	add  hl, bc
	cp   a, [hl]
	jp   z, L066A67
	jp   L066A73
L066A58:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L066A64
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
L066A64:;J
	jp   L066A73
L066A67:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L066A73
	call Play_Pl_EndMove
	jp   L066A76
L066A73:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L066A76:;J
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
	mMvIn_ValidateClose .chkPunchNoClose
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
	mMvIn_ValidateSuper .chkKickNoSuper
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
	
L066BA3:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L066C1D
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L066BC8
	cp   $04
	jp   z, L066BE8
	cp   $08
	jp   z, L066C03
	cp   $0C
	jp   z, L066C0F
L066BC5: db $C3;X
L066BC6: db $1A;X
L066BC7: db $6C;X
L066BC8:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L066BDA
	call MoveInputS_CheckMoveLHVer
	jp   z, L066BDA
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
L066BDA:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L066C1A
	ld   a, $1A
	call HomeCall_Sound_ReqPlayExId
	jp   L066C1A
L066BE8:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L066BFA
	call MoveInputS_CheckMoveLHVer
	jp   z, L066BFA
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
L066BFA:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L066C1A
	jp   L066C1A
L066C03:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L066C1A
	inc  hl
	ld   [hl], $06
	jp   L066C1A
L066C0F:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L066C1A
	call Play_Pl_EndMove
	jr   L066C1D
L066C1A:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L066C1D:;JR
	ret
L066C1E:;I
	call Play_Pl_CreateJoyMergedKeysLH
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L066CF9
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L066C50
	cp   $04
	jp   z, L066C62
	cp   $08
	jp   z, L066C8B
	cp   $0C
	jp   z, L066CEA
	cp   $10
	jp   z, L066CD5
	cp   $14
	jp   z, L066CEA
L066C4D: db $C3;X
L066C4E: db $F6;X
L066C4F: db $6C;X
L066C50:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L066CF6
	inc  hl
	ld   [hl], $05
	ld   hl, $0083
	add  hl, bc
	ld   [hl], $00
	jp   L066CF6
L066C62:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L066C88
	ld   a, $9D
	call HomeCall_Sound_ReqPlayExId
	call MoveInputS_CheckMoveLHVer
	jp   c, L066C82
	jp   nz, L066C7C
	ld   hl, $0500
	jp   L066C85
L066C7C:;J
	ld   hl, $0600
	jp   L066C85
L066C82:;J
	ld   hl, $0700
L066C85:;J
	call Play_OBJLstS_SetSpeedH_ByXFlipR
L066C88:;J
	jp   L066C9E
L066C8B:;J
	ld   hl, $0100
	call L0035D9
	jp   nc, L066C9E
	ld   a, $0C
	ld   h, $0A
	call L002E49
	jp   L066CF9
L066C9E:;J
	ld   hl, $0063
	add  hl, bc
	bit  1, [hl]
	jp   z, L066CAD
	ld   hl, $0083
	add  hl, bc
	ld   [hl], $01
L066CAD:;J
	ld   hl, $0083
	add  hl, bc
	bit  0, [hl]
	jp   z, L066CE4
	ld   hl, $0046
	add  hl, bc
	ld   a, [hl]
	bit  5, a
	jp   z, L066CE4
	ld   a, $10
	ld   h, $06
	call L002E49
	call OBJLstS_ApplyXSpeed
	ld   hl, $0408
	ld   a, $01
	call Play_Pl_SetMoveDamageNext
	jp   L066CF9
L066CD5:;J
	ld   hl, $0080
	call L0035D9
	call OBJLstS_IsFrameEnd
	jp   nc, L066CE4
	jp   L066CF6
L066CE4:;J
	call OBJLstS_ApplyXSpeed
	jp   L066CF6
L066CEA:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L066CF6
	call Play_Pl_EndMove
	jp   L066CF9
L066CF6:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L066CF9:;J
	ret
L066CFA:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L066DF5
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L066D26
	cp   $04
	jp   z, L066D43
	cp   $08
	jp   z, L066D63
	cp   $0C
	jp   z, L066DBF
	cp   $10
	jp   z, L066DD4
	cp   $14
	jp   z, L066DE7
L066D26:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L066D32
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
L066D32:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L066DF2
	ld   hl, $0404
	ld   a, $11
	call Play_Pl_SetMoveDamageNext
	jp   L066DF2
L066D43:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L066D4F
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
L066D4F:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L066DF2
	inc  hl
	ld   [hl], $FF
	ld   hl, $0403
	ld   a, $11
	call Play_Pl_SetMoveDamageNext
	jp   L066DF2
L066D63:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L066DAA
	ld   a, $12
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
	call MoveInputS_CheckMoveLHVer
	jp   c, L066D9B
	jp   nz, L066D8C
	ld   hl, $0300
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FB80
	call Play_OBJLstS_SetSpeedV
	jp   L066DA7
L066D8C:;J
	ld   hl, $0400
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FB00
	call Play_OBJLstS_SetSpeedV
	jp   L066DA7
L066D9B:;J
	ld   hl, $0500
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FA80
	call Play_OBJLstS_SetSpeedV
L066DA7:;J
	jp   L066DD4
L066DAA:;J
	ld   a, $FE
	ld   h, $FF
	call L002E63
	jp   nc, L066DD4
	ld   hl, $0403
	ld   a, $11
	call Play_Pl_SetMoveDamageNext
	jp   L066DD4
L066DBF:;J
	ld   a, $00
	ld   h, $FF
	call L002E63
	jp   nc, L066DD4
	ld   hl, $0403
	ld   a, $11
	call Play_Pl_SetMoveDamageNext
	jp   L066DD4
L066DD4:;J
	ld   hl, $0060
	call L003614
	jp   nc, L066DF2
	ld   a, $14
	ld   h, $06
	call L002DEC
	jp   L066DF5
L066DE7:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L066DF2
	call Play_Pl_EndMove
	jr   L066DF5
L066DF2:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L066DF5:;JR
	ret
L066DF6:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L066F17
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L066E31
	cp   $04
	jp   z, L066E4A
	cp   $08
	jp   z, L066E9E
	cp   $0C
	jp   z, L066E9E
	cp   $10
	jp   z, L066EBF
	cp   $14
	jp   z, L066EE0
	cp   $18
	jp   z, L066EE0
	cp   $1C
	jp   z, L066EF0
	cp   $20
	jp   z, L066F09
L066E31:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L066F14
	inc  hl
	ld   [hl], $00
	ld   a, $A8
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0208
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	jp   L066F14
L066E4A:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L066E93
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
	ld   hl, $0020
	add  hl, bc
	inc  hl
	res  7, [hl]
	call MoveInputS_CheckMoveLHVer
	jp   c, L066E84
	jp   nz, L066E75
	ld   hl, $0080
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FA00
	call Play_OBJLstS_SetSpeedV
	jp   L066E90
L066E75:;J
	ld   hl, $0100
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $F900
	call Play_OBJLstS_SetSpeedV
	jp   L066E90
L066E84:;J
	ld   hl, $01C0
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $F800
	call Play_OBJLstS_SetSpeedV
L066E90:;J
	jp   L066EF6
L066E93:;J
	ld   hl, $0208
	ld   a, $10
	call Play_Pl_SetMoveDamage
	jp   L066EF6
L066E9E:;J
	ld   hl, $0208
	ld   a, $10
	call Play_Pl_SetMoveDamage
	call OBJLstS_IsFrameEnd
	jp   nc, L066EF6
	ld   a, $FD
	ld   h, $FF
	call L002E63
	jp   nc, L066EF6
	ld   hl, $0013
	add  hl, de
	ld   [hl], $10
	jp   L066EF6
L066EBF:;J
	ld   hl, $0208
	ld   a, $10
	call Play_Pl_SetMoveDamage
	call OBJLstS_IsFrameEnd
	jp   nc, L066EF6
	ld   a, $FD
	ld   h, $FF
	call L002E63
	jp   c, L066EF6
	ld   hl, $0013
	add  hl, de
	ld   [hl], $04
	jp   L066EF6
L066EE0:;J
	ld   hl, $0040
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   a, $00
	ld   h, $FF
	call L002E63
	jp   L066EF6
L066EF0:;J
	ld   hl, $0040
	call Play_OBJLstS_SetSpeedH_ByXFlipR
L066EF6:;J
	ld   hl, $0060
	call L003614
	jp   nc, L066F14
	ld   a, $20
	ld   h, $08
	call L002DEC
	jp   L066F17
L066F09:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L066F14
	call Play_Pl_EndMove
	jr   L066F17
L066F14:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L066F17:;JR
	ret
L066F18:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L066FD3
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L066FD0
	cp   $04
	jp   z, L066F53
	cp   $08
	jp   z, L066F62
	cp   $0C
	jp   z, L066F78
	cp   $10
	jp   z, L066FD0
	cp   $14
	jp   z, L066F87
	cp   $18
	jp   z, L066F9D
	cp   $1C
	jp   z, L066FAC
	cp   $20
	jp   z, L066FC5
L066F53:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L066F5F
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
L066F5F:;J
	jp   L066FD0
L066F62:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L066FD0
	ld   hl, $0803
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	ld   a, $09
	call HomeCall_Sound_ReqPlayExId
	jp   L066FD0
L066F78:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L066F84
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
L066F84:;J
	jp   L066FD0
L066F87:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L066FD0
	ld   hl, $0804
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	ld   a, $09
	call HomeCall_Sound_ReqPlayExId
	jp   L066FD0
L066F9D:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L066FA9
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
L066FA9:;J
	jp   L066FD0
L066FAC:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L066FD0
	inc  hl
	ld   [hl], $03
	ld   hl, $0808
	ld   a, $11
	call Play_Pl_SetMoveDamageNext
	ld   a, $09
	call HomeCall_Sound_ReqPlayExId
	jp   L066FD0
L066FC5:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L066FD0
	call Play_Pl_EndMove
	jr   L066FD3
L066FD0:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L066FD3:;JR
	ret
L066FD4:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L0670B6
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L066FF9
	cp   $04
	jp   z, L06705D
	cp   $08
	jp   z, L06706C
	cp   $0C
	jp   z, L06706F
L066FF6: db $C3;X
L066FF7: db $B3;X
L066FF8: db $70;X
L066FF9:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L067037
	ld   a, $11
	call HomeCall_Sound_ReqPlayExId
	call MoveInputS_CheckMoveLHVer
	jp   c, L06702B
	jp   nz, L06701C
	ld   hl, $0300
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $0200
	call Play_OBJLstS_SetSpeedV
	jp   L067037
L06701C:;J
	ld   hl, $0500
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $0180
	call Play_OBJLstS_SetSpeedV
	jp   L067037
L06702B: db $21;X
L06702C: db $00;X
L06702D: db $07;X
L06702E: db $CD;X
L06702F: db $69;X
L067030: db $35;X
L067031: db $21;X
L067032: db $00;X
L067033: db $00;X
L067034: db $CD;X
L067035: db $AD;X
L067036: db $35;X
L067037:;J
	jp   L06703A
L06703A:;J
	ld   hl, $0018
	call L003614
	jp   nc, L0670B3
	call MoveInputS_CheckMoveLHVer
	jp   nz, L067053
	ld   a, $0C
	ld   h, $08
	call L002DEC
	jp   L0670B6
L067053:;J
	ld   a, $04
	ld   h, $00
	call L002DEC
	jp   L0670B6
L06705D:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L067069
	ld   hl, $0200
	call Play_OBJLstS_SetSpeedH_ByXFlipR
L067069:
	jp   L067072
L06706C:
	jp   L067072;X
L06706F:;J
	jp   L067072
L067072:;J
	ld   hl, $0033
	add  hl, bc
	ld   a, [hl]
	push af
	ld   hl, $0045
	add  hl, bc
	ld   a, [hl]
	bit  4, a
	jr   nz, L067091
	bit  5, a
	jr   nz, L067089
	pop  af
	jp   L0670A5
L067089:;R
	ld   a, $60
	call MoveInputS_SetSpecMove_StopSpeed
	jp   L067096
L067091:;R
	ld   a, $62
	call MoveInputS_SetSpecMove_StopSpeed
L067096:;J
	pop  af
	cp   $5C
	jp   z, L0670B6
	ld   hl, $0400
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	jp   L0670B6
L0670A5:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0670B0
	call Play_Pl_EndMove
	jr   L0670B6
L0670B0:;J
	call OBJLstS_ApplyXSpeed
L0670B3:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L0670B6:;JR
	ret
L0670B7:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L0670E5
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	ld   hl, $0039
	add  hl, bc
	cp   a, [hl]
	jp   z, L0670D6
	ld   hl, $0040
	call L0035D9
	jp   L0670E2
L0670D6:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0670E2
	call Play_Pl_EndMove
	jp   L0670E5
L0670E2:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L0670E5:;J
	ret
L0670E6:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L0671ED
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L067112
	cp   $04
	jp   z, L06712F
	cp   $08
	jp   z, L06714F
	cp   $0C
	jp   z, L067192
	cp   $10
	jp   z, L06719C
	cp   $14
	jp   z, L0671DF
L067112:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L06711E
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
L06711E:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0671EA
	ld   hl, $0208
	ld   a, $10
	call Play_Pl_SetMoveDamage
	jp   L0671EA
L06712F:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L06713B
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
L06713B:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0671EA
	inc  hl
	ld   [hl], $FF
	ld   hl, $0208
	ld   a, $10
	call Play_Pl_SetMoveDamage
	jp   L0671EA
L06714F:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L067188
	ld   a, $12
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
	ld   hl, $0033
	add  hl, bc
	ld   a, [hl]
	cp   $66
	jp   z, L067179
	ld   hl, $0500
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $F980
	call Play_OBJLstS_SetSpeedV
	jp   L0671BC
L067179:;J
	ld   hl, $0500
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FC40
	call Play_OBJLstS_SetSpeedV
	jp   L0671BC
L067188:;J
	ld   a, $FE
	ld   h, $FF
	call L002E63
	jp   L06719C
L067192:;J
	ld   a, $00
	ld   h, $FF
	call L002E63
	jp   L06719C
L06719C:;J
	ld   hl, $0033
	add  hl, bc
	ld   a, [hl]
	cp   $66
	jp   z, L0671B1
	ld   hl, $0208
	ld   a, $10
	call Play_Pl_SetMoveDamage
	jp   L0671BC
L0671B1:;J
	ld   hl, $0208
	ld   a, $90
	call Play_Pl_SetMoveDamage
	jp   L0671BC
L0671BC:;J
	ld   hl, $0033
	add  hl, bc
	ld   a, [hl]
	cp   $66
	jp   z, L0671CC
	ld   hl, $0060
	jp   L0671CF
L0671CC:;J
	ld   hl, $0030
L0671CF:;J
	call L003614
	jp   nc, L0671EA
	ld   a, $14
	ld   h, $12
	call L002DEC
	jp   L0671ED
L0671DF:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0671EA
	call Play_Pl_EndMove
	jr   L0671ED
L0671EA:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L0671ED:;JR
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
	mMvIn_ValidateSuper .chkPunchNoSuper
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
L0672DD:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L067329
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $04
	jp   z, L0672F8
	cp   $08
	jp   z, L067312
	jp   L067326
L0672F8:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L067326
	inc  hl
	push hl
	call MoveInputS_CheckMoveLHVer
	jp   nz, L06730C
	pop  hl
	ld   [hl], $0C
	jp   L067326
L06730C:;J
	pop  hl
	ld   [hl], $18
	jp   L067326
L067312:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L06731B
	call L0651E5
L06731B:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L067326
	call Play_Pl_EndMove
	jr   L067329
L067326:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L067329:;JR
	ret
L06732A:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L067445
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L067363
	cp   $04
	jp   z, L067386
	cp   $08
	jp   z, L0673D2
	cp   $0C
	jp   z, L0673F2
	cp   $10
	jp   z, L067412
	cp   $14
	jp   z, L06741E
	cp   $18
	jp   z, L06741E
	cp   $1C
	jp   z, L067427
L067360: db $C3;X
L067361: db $42;X
L067362: db $74;X
L067363:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L067442
	inc  hl
	ld   [hl], $00
	call MoveInputS_CheckMoveLHVer
	jp   c, L06737B
	jp   nz, L067378
	jp   L067442
L067378:;J
	jp   L067442
L06737B: db $21;X
L06737C: db $04;X
L06737D: db $04;X
L06737E: db $3E;X
L06737F: db $10;X
L067380: db $CD;X
L067381: db $90;X
L067382: db $38;X
L067383: db $C3;X
L067384: db $42;X
L067385: db $74;X
L067386:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L0673B2
	ld   a, $93
	call HomeCall_Sound_ReqPlayExId
	call MoveInputS_CheckMoveLHVer
	jp   c, L0673AC
	jp   nz, L0673A3
	ld   hl, $0400
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	jp   L0673B2
L0673A3:;J
	ld   hl, $0500
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	jp   L0673B2
L0673AC: db $21;X
L0673AD: db $00;X
L0673AE: db $06;X
L0673AF: db $CD;X
L0673B0: db $69;X
L0673B1: db $35;X
L0673B2:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L067436
	call MoveInputS_CheckMoveLHVer
	jp   c, L0673C7
	jp   nz, L0673C4
	jp   L067436
L0673C4:;J
	jp   L067436
L0673C7: db $21;X
L0673C8: db $03;X
L0673C9: db $04;X
L0673CA: db $3E;X
L0673CB: db $10;X
L0673CC: db $CD;X
L0673CD: db $90;X
L0673CE: db $38;X
L0673CF: db $C3;X
L0673D0: db $36;X
L0673D1: db $74;X
L0673D2:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L067436
	call MoveInputS_CheckMoveLHVer
	jp   c, L0673E7
	jp   nz, L0673E4
	jp   L067436
L0673E4:;J
	jp   L067436
L0673E7: db $21;X
L0673E8: db $04;X
L0673E9: db $04;X
L0673EA: db $3E;X
L0673EB: db $10;X
L0673EC: db $CD;X
L0673ED: db $90;X
L0673EE: db $38;X
L0673EF: db $C3;X
L0673F0: db $36;X
L0673F1: db $74;X
L0673F2:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L067436
	call MoveInputS_CheckMoveLHVer
	jp   c, L067407
	jp   nz, L067404
	jp   L067436
L067404:;J
	jp   L067436
L067407: db $21;X
L067408: db $08;X
L067409: db $04;X
L06740A: db $3E;X
L06740B: db $11;X
L06740C: db $CD;X
L06740D: db $90;X
L06740E: db $38;X
L06740F: db $C3;X
L067410: db $36;X
L067411: db $74;X
L067412:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L067436
	inc  hl
	ld   [hl], $03
	jp   L067436
L06741E:;J
	ld   hl, $0040
	call L0035D9
	jp   L067442
L067427:;J
	ld   hl, $0080
	call L0035D9
	call OBJLstS_IsFrameEnd
	jp   nc, L067442
	jp   L06743C
L067436:;J
	call OBJLstS_ApplyXSpeed
	jp   L067442
L06743C:;J
	call Play_Pl_EndMove
	jp   L067445
L067442:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L067445:;J
	ret
L067446:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L067547
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L06747F
	cp   $04
	jp   z, L0674A7
	cp   $08
	jp   z, L0674E1
	cp   $0C
	jp   z, L0674D3
	cp   $10
	jp   z, L0674EF
	cp   $14
	jp   z, L067506
	cp   $18
	jp   z, L06750F
	cp   $1C
	jp   z, L067529
L06747C: db $C3;X
L06747D: db $44;X
L06747E: db $75;X
L06747F:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L067544
	inc  hl
	ld   [hl], $00
	ld   hl, $0083
	add  hl, bc
	push hl
	call MoveInputS_CheckMoveLHVer
	jp   c, L0674A0
	jp   nz, L06749B
	ld   a, $01
	jp   L0674A2
L06749B:;J
	ld   a, $02
	jp   L0674A2
L0674A0: db $3E;X
L0674A1: db $03;X
L0674A2:;J
	pop  hl
	ld   [hl], a
	jp   L067544
L0674A7:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L0674D3
	ld   a, $93
	call HomeCall_Sound_ReqPlayExId
	call MoveInputS_CheckMoveLHVer
	jp   c, L0674CD
	jp   nz, L0674C4
	ld   hl, $0100
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	jp   L0674D3
L0674C4:;J
	ld   hl, $0200
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	jp   L0674D3
L0674CD: db $21;X
L0674CE: db $00;X
L0674CF: db $03;X
L0674D0: db $CD;X
L0674D1: db $69;X
L0674D2: db $35;X
L0674D3:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L067538
	ld   a, $93
	call HomeCall_Sound_ReqPlayExId
	jp   L0676A8
L0674E1:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L067538
	ld   a, $93
	call HomeCall_Sound_ReqPlayExId
	jp   L0676A2
L0674EF:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L067538
	ld   hl, $0083
	add  hl, bc
	dec  [hl]
	jp   z, L0676A2
	ld   hl, $0013
	add  hl, de
	ld   [hl], $00
	jp   L0676A2
L067506:;J
	ld   hl, $0040
	call L0035D9
	jp   L067544
L06750F:;J
	ld   hl, $0040
	call L0035D9
	call OBJLstS_IsFrameEnd
	jp   nc, L067544
	inc  hl
	ld   [hl], $1E
	ld   hl, $0408
	ld   a, $11
	call Play_Pl_SetMoveDamageNext
	jp   L067544
L067529:;J
	ld   hl, $0040
	call L0035D9
	call OBJLstS_IsFrameEnd
	jp   nc, L067544
	jp   L06753E
L067538:;J
	call OBJLstS_ApplyXSpeed
	jp   L067544
L06753E:;J
	call Play_Pl_EndMove
	jp   L067547
L067544:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L067547:;J
	ret
L067548:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L0675F0
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L06756D
	cp   $04
	jp   z, L0675AD
	cp   $08
	jp   z, L06759F
	cp   $0C
	jp   z, L0675BB
L06756A: db $C3;X
L06756B: db $ED;X
L06756C: db $75;X
L06756D:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L06759F
	call MoveInputS_CheckMoveLHVer
	jp   c, L067592
	jp   nz, L067587
L06757C: db $21;X
L06757D: db $00;X
L06757E: db $03;X
L06757F: db $CD;X
L067580: db $69;X
L067581: db $35;X
L067582: db $3E;X
L067583: db $01;X
L067584: db $C3;X
L067585: db $9A;X
L067586: db $75;X
L067587:;J
	ld   hl, $0400
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   a, $01
	jp   L06759A
L067592:;J
	ld   hl, $0500
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   a, $02
L06759A:;J
	ld   hl, $0083
	add  hl, bc
	ld   [hl], a
L06759F:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0675E7
	ld   a, $9D
	call HomeCall_Sound_ReqPlayExId
	jp   L0676A8
L0675AD:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0675E7
	ld   a, $9D
	call HomeCall_Sound_ReqPlayExId
	jp   L0676A2
L0675BB:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0675E7
	ld   hl, $0083
	add  hl, bc
	dec  [hl]
	jp   z, L0675D7
	ld   hl, $0013
	add  hl, de
	ld   [hl], $00
	ld   a, $9D
	call HomeCall_Sound_ReqPlayExId
	jp   L0676A2
L0675D7:;J
	ld   a, $54
	call MoveInputS_SetSpecMove_StopSpeed
	ld   hl, $0604
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
	jp   L0675F0
L0675E7:;J
	call OBJLstS_ApplyXSpeed
	jp   L0675ED
L0675ED:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L0675F0:;J
	ret
L0675F1:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L0676C8
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L06762A
	cp   $04
	jp   z, L06766F
	cp   $08
	jp   z, L067661
	cp   $0C
	jp   z, L06766F
	cp   $10
	jp   z, L067661
	cp   $14
	jp   z, L06766F
	cp   $18
	jp   z, L06767D
	cp   $1C
	jp   z, L0676B6
L067627: db $C3;X
L067628: db $C5;X
L067629: db $76;X
L06762A:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L067661
	ld   a, $93
	call HomeCall_Sound_ReqPlayExId
	call MoveInputS_CheckMoveLHVer
	jp   c, L067654
	jp   nz, L067649
	ld   hl, $0200
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   a, $01
	jp   L06765C
L067649:;J
	ld   hl, $0240
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   a, $02
	jp   L06765C
L067654: db $21;X
L067655: db $80;X
L067656: db $02;X
L067657: db $CD;X
L067658: db $69;X
L067659: db $35;X
L06765A: db $3E;X
L06765B: db $03;X
L06765C:;J
	ld   hl, $0083
	add  hl, bc
	ld   [hl], a
L067661:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0676B0
	ld   a, $93
	call HomeCall_Sound_ReqPlayExId
	jp   L0676A8
L06766F:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0676B0
	ld   a, $93
	call HomeCall_Sound_ReqPlayExId
	jp   L0676A2
L06767D:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0676B0
	ld   a, $93
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0083
	add  hl, bc
	dec  [hl]
	jp   z, L067699
	ld   hl, $0013
	add  hl, de
	ld   [hl], $00
	jp   L0676A8
L067699:;J
	ld   hl, $001C
	add  hl, de
	ld   [hl], $14
	jp   L0676C5
L0676A2:;J
	ld   hl, $0204
	jp   L0676AB
L0676A8:;J
	ld   hl, $0203
L0676AB:;J
	ld   a, $10
	call Play_Pl_SetMoveDamageNext
L0676B0:;J
	call OBJLstS_ApplyXSpeed
	jp   L0676C5
L0676B6:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L0676C5
	call Play_Pl_ClearJoyBtnBuffer
	call Play_Pl_EndMove
	jp   L0676C8
L0676C5:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L0676C8:;J
	ret
L0676C9:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L06770A
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $04
	jp   z, L0676E4
	cp   $08
	jp   z, L0676F0
	jp   L067707
L0676E4:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L067707
	inc  hl
	ld   [hl], $64
	jp   L067707
L0676F0:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L0676FC
	ld   hl, MBC1RomBank
	call L06770B
L0676FC:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L067707
	call Play_Pl_EndMove
	jr   L06770A
L067707:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L06770A:;JR
	ret
L06770B:;C
	ld   a, $14
	call HomeCall_Sound_ReqPlayExId
	push bc
	push de
	ld   hl, $0033
	add  hl, bc
	ld   a, [hl]
	push af
	call L0024F8
	ld   hl, $0020
	add  hl, de
	ld   [hl], $06
	inc  hl
	ld   [hl], $65
	inc  hl
	ld   [hl], $77
	ld   hl, $0010
	add  hl, de
	ld   [hl], $01
	inc  hl
	ld   [hl], $47
	inc  hl
	ld   [hl], $5A
	inc  hl
	ld   [hl], $00
	ld   hl, $001B
	add  hl, de
	ld   [hl], $03
	inc  hl
	ld   [hl], $03
	ld   hl, $0027
	add  hl, de
	ld   [hl], $02
	inc  hl
	pop  af
	cp   $64
	jp   nz, L067751
	ld   [hl], $28
	jp   L067753
L067751:;J
	ld   [hl], $50
L067753:;J
	call OBJLstS_Overlap
	ld   hl, MBC1RomBank
	call Play_OBJLstS_MoveH_ByXFlipR
	ld   hl, $0000
	call Play_OBJLstS_MoveV
	pop  de
	pop  bc
	ret
L067765:;I
	ld   hl, $0021
	add  hl, bc
	bit  4, [hl]
	jp   nz, L0677BC
	ld   hl, $0028
	add  hl, de
	dec  [hl]
	jp   z, L0677BC
	ld   a, [hl]
	cp   $46
	jp   z, L0677AC
	cp   $3C
	jp   z, L06779D
	cp   $32
	jp   z, L0677AC
	cp   $28
	jp   z, L06779D
	cp   $1E
	jp   z, L0677AC
	cp   $14
	jp   z, L06779D
	cp   $0A
	jp   z, L0677AC
	jp   L0677B8
L06779D:;J
	ld   hl, $0200
	call Play_OBJLstS_MoveH_ByXFlipR
	ld   hl, $0800
	call Play_OBJLstS_MoveV
	jp   L0677B8
L0677AC:;J
	ld   hl, $0200
	call Play_OBJLstS_MoveH_ByXFlipR
	ld   hl, $F800
	call Play_OBJLstS_MoveV
L0677B8:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
	ret
L0677BC:;J
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
	mMvIn_ValidateSuper .chkPunchNoSuper
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
	; Reset running jump because ???
	ld   hl, iPlInfo_RunningJump
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
L0678F8:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L067940
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L067918
	cp   $0C
	jp   z, L067926
	cp   $10
	jp   z, L067932
	jp   L06793D
L067918:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06793D
	ld   a, $A8
	call HomeCall_Sound_ReqPlayExId
	jp   L06793D
L067926:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06793D
	inc  hl
	ld   [hl], $1E
	jp   L06793D
L067932:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06793D
	call Play_Pl_EndMove
	jr   L067940
L06793D:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L067940:;JR
	ret
L067941:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L0679A2
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L067918
	cp   $0C
	jp   z, L067966
	cp   $18
	jp   z, L067988
	cp   $1C
	jp   z, L067994
	jp   L06799F
L067966:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L067972
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
L067972:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06799F
	ld   a, $A8
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0808
	ld   a, $01
	call Play_Pl_SetMoveDamageNext
	jp   L06799F
L067988:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06799F
	inc  hl
	ld   [hl], $1E
	jp   L06799F
L067994:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L06799F
	call Play_Pl_EndMove
	jr   L0679A2
L06799F:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L0679A2:;JR
	ret
L0679A3:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L067A87
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L0679C8
	cp   $04
	jp   z, L0679D4
	cp   $08
	jp   z, L067A33
	cp   $0C
	jp   z, L067A58
L0679C5: db $C3;X
L0679C6: db $84;X
L0679C7: db $7A;X
L0679C8:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L067A84
	inc  hl
	ld   [hl], $FF
	jp   L067A84
L0679D4:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L067A00
	ld   a, $93
	call HomeCall_Sound_ReqPlayExId
	call MoveInputS_CheckMoveLHVer
	jp   c, L0679FA
	jp   nz, L0679F1
	ld   hl, $0500
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	jp   L067A00
L0679F1:;J
	ld   hl, $0600
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	jp   L067A00
L0679FA:;J
	ld   hl, $0700
	call Play_OBJLstS_SetSpeedH_ByXFlipR
L067A00:;J
	ld   hl, $0063
	add  hl, bc
	bit  1, [hl]
	jp   z, L067A27
	ld   hl, $006E
	add  hl, bc
	bit  7, [hl]
	jp   nz, L067A27
	ld   hl, $0804
	ld   a, $01
	call Play_Pl_SetMoveDamageNext
	ld   a, $08
	ld   h, $05
	call L002E49
	call OBJLstS_ApplyXSpeed
	jp   L067A87
L067A27:;J
	ld   hl, $0080
	call L0035D9
	jp   nc, L067A84
	jp   L067A7E
L067A33:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L067A44
	ld   a, $93
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0500
	call Play_OBJLstS_SetSpeedH_ByXFlipR
L067A44:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L067A75
	inc  hl
	ld   [hl], $0A
	ld   hl, $0808
	ld   a, $01
	call Play_Pl_SetMoveDamageNext
	jp   L067A75
L067A58:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L067A69
	ld   a, $93
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0600
	call Play_OBJLstS_SetSpeedH_ByXFlipR
L067A69:;J
	ld   hl, $0080
	call L0035D9
	jp   nc, L067A84
	jp   L067A7E
L067A75:;J
	ld   hl, $0080
	call L0035D9
	jp   L067A84
L067A7E:;J
	call Play_Pl_EndMove
	jp   L067A87
L067A84:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L067A87:;J
	ret
L067A88:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L067B74
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L067AB9
	cp   $04
	jp   z, L067ACB
	cp   $08
	jp   z, L067AEB
	cp   $0C
	jp   z, L067B39
	cp   $10
	jp   z, L067B46
	cp   $14
	jp   z, L067B53
	cp   $18
	jp   z, L067B66
L067AB9:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L067AC8
	ld   hl, $0700
	call Play_OBJLstS_MoveH_ByXFlipR
	jp   L067B71
L067AC8:;J
	jp   L067B71
L067ACB:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L067AD7
	ld   hl, $0400
	call Play_OBJLstS_MoveH_ByXFlipR
L067AD7:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L067B71
	inc  hl
	ld   [hl], $FF
	ld   hl, $0808
	ld   a, $01
	call Play_Pl_SetMoveDamageNext
	jp   L067B71
L067AEB:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L067B2C
	ld   a, $A8
	call HomeCall_Sound_ReqPlayExId
	call MoveInputS_CheckMoveLHVer
	jp   c, L067B1D
	jp   nz, L067B0E
	ld   hl, $0100
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $FA00
	call Play_OBJLstS_SetSpeedV
	jp   L067B29
L067B0E:;J
	ld   hl, $0180
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $F980
	call Play_OBJLstS_SetSpeedV
	jp   L067B29
L067B1D:;J
	ld   hl, $0200
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $F980
	call Play_OBJLstS_SetSpeedV
L067B29:;J
	jp   L067B53
L067B2C:;J
	ld   a, $FA
	ld   h, $FF
	call L002E63
	jp   nc, L067B53
	jp   L067B53
L067B39:;J
	ld   a, $01
	ld   h, $FF
	call L002E63
	jp   nc, L067B53
	jp   L067B53
L067B46:;J
	ld   a, $02
	ld   h, $FF
	call L002E63
	jp   nc, L067B53
	jp   L067B53
L067B53:;J
	ld   hl, $0060
	call L003614
	jp   nc, L067B71
	ld   a, $18
	ld   h, $06
	call L002DEC
	jp   L067B74
L067B66:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L067B71
	call Play_Pl_EndMove
	jr   L067B74
L067B71:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L067B74:;JR
	ret
L067B75:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L067BD7
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L067B95
	cp   $04
	jp   z, L067BA1
	cp   $0C
	jp   z, L067BC9
	jp   L067BB6
L067B95:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L067BB6
	inc  hl
	ld   [hl], $0A
	jp   L067BB6
L067BA1:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L067BAA
	call L067D27
L067BAA:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L067BB6
	inc  hl
	ld   [hl], $FF
	jp   L067BB6
L067BB6:;J
	ld   hl, $0060
	call L003614
	jp   nc, L067BD4
	ld   a, $0C
	ld   h, $00
	call L002DEC
	jp   L067BD7
L067BC9:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L067BD4
	call Play_Pl_EndMove
	jr   L067BD7
L067BD4:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L067BD7:;JR
	ret
L067BD8:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L067CC0
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L067C02
	cp   $04
	jp   z, L067C59
	cp   $08
	jp   z, L067C62
	cp   $0C
	jp   z, L067C79
	cp   $10
	jp   z, L067C9C
L067BFF: db $C3;X
L067C00: db $BD;X
L067C01: db $7C;X
L067C02:;J
	ld   hl, $0022
	add  hl, bc
	bit  3, [hl]
	jp   z, L067C4D
	ld   hl, $0083
	add  hl, bc
	ld   a, [hl]
	or   a
	jp   nz, L067C2F
	call Play_Pl_TempPauseOtherAnim
	ld   a, $0A
	call HomeCall_Sound_ReqPlayExId
	ld   a, $01
	ld   [wPlayHitstopSet], a
	call Play_Pl_ShakeFor
	ld   a, $00
	ld   [wPlayHitstopSet], a
	ld   hl, $0083
	add  hl, bc
	ld   [hl], $01
L067C2F:;J
	call MoveInputS_TryStartCommandThrow_Unk_Coli05
	jp   nc, L067B71
	call Task_PassControlFar
	ld   a, $03
	ld   [wPlayPlThrowActId], a
	ld   hl, $0021
	add  hl, bc
	set  7, [hl]
	ld   a, $08
	ld   h, $08
	call L002E49
	jp   L067CC0
L067C4D:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L067CBD
	inc  hl
	ld   [hl], $0F
	jp   L067CBD
L067C59:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L067CBD
	jp   L067CB3
L067C62:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L067CBD
	ld   hl, $0612
	ld   a, $01
	call Play_Pl_SetMoveDamage
	ld   hl, $08D8
	call L003875
	jp   L067CBD
L067C79:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L067C90
	ld   hl, $0613
	ld   a, $01
	call Play_Pl_SetMoveDamage
	ld   hl, $18FC
	call L003875
	jp   L067CBD
L067C90:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L067CBD
	inc  hl
	ld   [hl], $14
	jp   L067CBD
L067C9C:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L067CAD
	ld   hl, $0A0C
	ld   a, $01
	call Play_Pl_SetMoveDamage
	jp   L067CBD
L067CAD:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L067CBD
L067CB3:;J
	call Play_Pl_EndMove
	ld   a, $00
	ld   [wPlayPlThrowActId], a
	jr   L067CC0
L067CBD:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
L067CC0:;JR
	ret
L067CC1:;I
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, L067D26
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L067CE1
	cp   $04
	jp   z, L067CED
	cp   $08
	jp   z, L067CF9
L067CDE: db $C3;X
L067CDF: db $23;X
L067CE0: db $7D;X
L067CE1:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L067D23
	inc  hl
	ld   [hl], $00
	jp   L067D23
L067CED:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L067D23
	inc  hl
	ld   [hl], $3C
	jp   L067D23
L067CF9:;J
	call OBJLstS_Unk_ChkStatusBit3
	jp   z, L067D18
	ld   hl, $0033
	add  hl, bc
	ld   a, [hl]
	cp   $66
	jp   z, L067D12
	ld   hl, $0000
	call L067DAD
	jp   L067D18
L067D12:;J
	ld   hl, $0000
	call L067DEF
L067D18:;J
	call OBJLstS_IsFrameEnd
	jp   nc, L067D23
	call Play_Pl_EndMove
	jr   L067D26
L067D23:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L067D26:;JR
	ret
L067D27:;C
	ld   a, $A8
	call HomeCall_Sound_ReqPlayExId
	push bc
	push de
	ld   hl, $0050
	add  hl, bc
	ld   a, [hl]
	cp   $28
	jp   z, L067D3C
	xor  a
	jp   L067D3D
L067D3C:;J
	scf
L067D3D:;J
	ld   hl, $0022
	push af
	add  hl, bc
	pop  af
	ld   a, [hl]
	push af
	call L0024F8
	ld   hl, $0020
	add  hl, de
	ld   [hl], $06
	inc  hl
	ld   [hl], $31
	inc  hl
	ld   [hl], $7E
	ld   hl, $0010
	add  hl, de
	ld   [hl], $01
	inc  hl
	ld   [hl], $13
	inc  hl
	ld   [hl], $5A
	inc  hl
	ld   [hl], $00
	ld   hl, $001B
	add  hl, de
	ld   [hl], $00
	inc  hl
	ld   [hl], $00
	ld   hl, $0027
	add  hl, de
	ld   [hl], $00
	call OBJLstS_Overlap
	ld   hl, $0800
	call Play_OBJLstS_MoveH_ByXFlipR
	ld   hl, $F000
	call Play_OBJLstS_MoveV
	pop  af
	jp   nc, L067D8D
	bit  1, a
	jp   nz, L067D9E
	jp   L067D92
L067D8D:;J
	bit  1, a
	jp   nz, L067D98
L067D92:;J
	ld   hl, $0100
	jp   L067DA1
L067D98:;J
	ld   hl, $0200
	jp   L067DA1
L067D9E: db $21;X
L067D9F: db $00;X
L067DA0: db $04;X
L067DA1:;J
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	ld   hl, $0200
	call Play_OBJLstS_SetSpeedV
	pop  de
	pop  bc
	ret
L067DAD:;C
	ld   a, $14
	call HomeCall_Sound_ReqPlayExId
	push bc
	push de
	push hl
	call L0024F8
	ld   hl, $0020
	add  hl, de
	ld   [hl], $06
	inc  hl
	ld   [hl], $48
	inc  hl
	ld   [hl], $7E
	ld   hl, $0010
	add  hl, de
	ld   [hl], $01
	inc  hl
	ld   [hl], $EF
	inc  hl
	ld   [hl], $59
	inc  hl
	ld   [hl], $00
	ld   hl, $001B
	add  hl, de
	ld   [hl], $00
	inc  hl
	ld   [hl], $00
	ld   hl, $0027
	add  hl, de
	ld   [hl], $02
	inc  hl
	ld   [hl], $3C
	call OBJLstS_Overlap
	pop  hl
	call Play_OBJLstS_MoveH_ByXFlipR
	pop  de
	pop  bc
	ret
L067DEF:;C
	ld   a, $14
	call HomeCall_Sound_ReqPlayExId
	push bc
	push de
	push hl
	call L0024F8
	ld   hl, $0020
	add  hl, de
	ld   [hl], $06
	inc  hl
	ld   [hl], $48
	inc  hl
	ld   [hl], $7E
	ld   hl, $0010
	add  hl, de
	ld   [hl], $01
	inc  hl
	ld   [hl], $01
	inc  hl
	ld   [hl], $5A
	inc  hl
	ld   [hl], $00
	ld   hl, $001B
	add  hl, de
	ld   [hl], $00
	inc  hl
	ld   [hl], $00
	ld   hl, $0027
	add  hl, de
	ld   [hl], $02
	inc  hl
	ld   [hl], $5A
	call OBJLstS_Overlap
	pop  hl
	call Play_OBJLstS_MoveH_ByXFlipR
	pop  de
	pop  bc
	ret
L067E31:;I
	call L0028B2
	jp   c, L067E44
	call OBJLstS_DoAnimTiming_Loop_by_DE
	ld   hl, $0000
	call L003672
	jp   c, L067E44
	ret
L067E44:;J
	call OBJLstS_Hide
	ret
L067E48:;I
	ld   hl, $0028
	add  hl, de
	dec  [hl]
	jp   z, L067E6E
	ld   a, [hl]
	cp   $08
	jp   c, L067E63
	cp   $10
	jp   c, L067E5E
	jp   L067E6A
L067E5E:;J
	ld   a, $01
	jp   L067E65
L067E63:;J
	ld   a, $02
L067E65:;J
	ld   hl, $001C
	add  hl, de
	ld   [hl], a
L067E6A:;J
	call OBJLstS_DoAnimTiming_Loop_by_DE
	ret
L067E6E:;J
	call OBJLstS_Hide
	ret
L067E72: db $0A;X
L067E73: db $03;X
L067E74: db $22;X
L067E75: db $C1;X
L067E76: db $21;X
L067E77: db $01;X
L067E78: db $00;X
L067E79: db $09;X
L067E7A: db $7E;X
L067E7B: db $21;X
L067E7C: db $01;X
L067E7D: db $00;X
L067E7E: db $19;X
L067E7F: db $77;X
L067E80: db $E1;X
L067E81: db $CD;X
L067E82: db $69;X
L067E83: db $35;X
L067E84: db $D1;X
L067E85: db $C1;X
L067E86: db $C9;X
L067E87: db $CD;X
L067E88: db $6F;X
L067E89: db $29;X
L067E8A: db $DA;X
L067E8B: db $9A;X
L067E8C: db $7E;X
L067E8D: db $CD;X
L067E8E: db $C6;X
L067E8F: db $2F;X
L067E90: db $21;X
L067E91: db $00;X
L067E92: db $00;X
L067E93: db $CD;X
L067E94: db $E4;X
L067E95: db $36;X
L067E96: db $DA;X
L067E97: db $9A;X
L067E98: db $7E;X
L067E99: db $C9;X
L067E9A: db $CD;X
L067E9B: db $0E;X
L067E9C: db $2A;X
L067E9D: db $C9;X
L067E9E: db $21;X
L067E9F: db $28;X
L067EA0: db $00;X
L067EA1: db $19;X
L067EA2: db $35;X
L067EA3: db $CA;X
L067EA4: db $C4;X
L067EA5: db $7E;X
L067EA6: db $7E;X
L067EA7: db $FE;X
L067EA8: db $08;X
L067EA9: db $DA;X
L067EAA: db $B9;X
L067EAB: db $7E;X
L067EAC: db $FE;X
L067EAD: db $10;X
L067EAE: db $DA;X
L067EAF: db $B4;X
L067EB0: db $7E;X
L067EB1: db $C3;X
L067EB2: db $C0;X
L067EB3: db $7E;X
L067EB4: db $3E;X
L067EB5: db $01;X
L067EB6: db $C3;X
L067EB7: db $BB;X
L067EB8: db $7E;X
L067EB9: db $3E;X
L067EBA: db $02;X
L067EBB: db $21;X
L067EBC: db $1C;X
L067EBD: db $00;X
L067EBE: db $19;X
L067EBF: db $77;X
L067EC0: db $CD;X
L067EC1: db $C6;X
L067EC2: db $2F;X
L067EC3: db $C9;X
L067EC4: db $CD;X
L067EC5: db $0E;X
L067EC6: db $2A;X
L067EC7: db $C9;X
L067EC8: db $EC;X
L067EC9: db $7F;X
L067ECA: db $CD;X
L067ECB: db $48;X
L067ECC: db $2A;X
L067ECD: db $D2;X
L067ECE: db $EC;X
L067ECF: db $7F;X
L067ED0: db $21;X
L067ED1: db $0B;X
L067ED2: db $06;X
L067ED3: db $3E;X
L067ED4: db $90;X
L067ED5: db $CD;X
L067ED6: db $8A;X
L067ED7: db $34;X
L067ED8: db $C3;X
L067ED9: db $EC;X
L067EDA: db $7F;X
L067EDB: db $CD;X
L067EDC: db $48;X
L067EDD: db $2A;X
L067EDE: db $D2;X
L067EDF: db $EC;X
L067EE0: db $7F;X
L067EE1: db $E5;X
L067EE2: db $21;X
L067EE3: db $82;X
L067EE4: db $00;X
L067EE5: db $09;X
L067EE6: db $7E;X
L067EE7: db $CB;X
L067EE8: db $27;X
L067EE9: db $E1;X
L067EEA: db $23;X
L067EEB: db $77;X
L067EEC: db $C3;X
L067EED: db $EC;X
L067EEE: db $7F;X
L067EEF: db $21;X
L067EF0: db $E8;X
L067EF1: db $F8;X
L067EF2: db $CD;X
L067EF3: db $73;X
L067EF4: db $34;X
L067EF5: db $C3;X
L067EF6: db $FE;X
L067EF7: db $7E;X
L067EF8: db $21;X
L067EF9: db $E8;X
L067EFA: db $08;X
L067EFB: db $CD;X
L067EFC: db $73;X
L067EFD: db $34;X
L067EFE: db $21;X
L067EFF: db $12;X
L067F00: db $06;X
L067F01: db $3E;X
L067F02: db $01;X
L067F03: db $CD;X
L067F04: db $8A;X
L067F05: db $34;X
L067F06: db $C3;X
L067F07: db $EC;X
L067F08: db $7F;X
L067F09: db $21;X
L067F0A: db $EC;X
L067F0B: db $F0;X
L067F0C: db $CD;X
L067F0D: db $73;X
L067F0E: db $34;X
L067F0F: db $C3;X
L067F10: db $18;X
L067F11: db $7F;X
L067F12: db $21;X
L067F13: db $EC;X
L067F14: db $10;X
L067F15: db $CD;X
L067F16: db $73;X
L067F17: db $34;X
L067F18: db $21;X
L067F19: db $13;X
L067F1A: db $06;X
L067F1B: db $3E;X
L067F1C: db $01;X
L067F1D: db $CD;X
L067F1E: db $8A;X
L067F1F: db $34;X
L067F20: db $C3;X
L067F21: db $EC;X
L067F22: db $7F;X
L067F23: db $CD;X
L067F24: db $48;X
L067F25: db $2A;X
L067F26: db $D2;X
L067F27: db $EC;X
L067F28: db $7F;X
L067F29: db $CD;X
L067F2A: db $3E;X
L067F2B: db $36;X
L067F2C: db $D2;X
L067F2D: db $EF;X
L067F2E: db $7F;X
L067F2F: db $CD;X
L067F30: db $FB;X
L067F31: db $03;X
L067F32: db $3E;X
L067F33: db $03;X
L067F34: db $EA;X
L067F35: db $6F;X
L067F36: db $C1;X
L067F37: db $C3;X
L067F38: db $EF;X
L067F39: db $7E;X
L067F3A: db $CD;X
L067F3B: db $48;X
L067F3C: db $2A;X
L067F3D: db $D2;X
L067F3E: db $EC;X
L067F3F: db $7F;X
L067F40: db $CD;X
L067F41: db $3E;X
L067F42: db $36;X
L067F43: db $D2;X
L067F44: db $EF;X
L067F45: db $7F;X
L067F46: db $CD;X
L067F47: db $FB;X
L067F48: db $03;X
L067F49: db $3E;X
L067F4A: db $03;X
L067F4B: db $EA;X
L067F4C: db $6F;X
L067F4D: db $C1;X
L067F4E: db $C3;X
L067F4F: db $F8;X
L067F50: db $7E;X
L067F51: db $CD;X
L067F52: db $48;X
L067F53: db $2A;X
L067F54: db $D2;X
L067F55: db $EC;X
L067F56: db $7F;X
L067F57: db $C3;X
L067F58: db $12;X
L067F59: db $7F;X
L067F5A: db $CD;X
L067F5B: db $48;X
L067F5C: db $2A;X
L067F5D: db $D2;X
L067F5E: db $EC;X
L067F5F: db $7F;X
L067F60: db $C3;X
L067F61: db $09;X
L067F62: db $7F;X
L067F63: db $CD;X
L067F64: db $48;X
L067F65: db $2A;X
L067F66: db $D2;X
L067F67: db $EC;X
L067F68: db $7F;X
L067F69: db $21;X
L067F6A: db $0B;X
L067F6B: db $06;X
L067F6C: db $3E;X
L067F6D: db $01;X
L067F6E: db $CD;X
L067F6F: db $8A;X
L067F70: db $34;X
L067F71: db $C3;X
L067F72: db $EC;X
L067F73: db $7F;X
L067F74: db $CD;X
L067F75: db $48;X
L067F76: db $2A;X
L067F77: db $D2;X
L067F78: db $EC;X
L067F79: db $7F;X
L067F7A: db $23;X
L067F7B: db $36;X
L067F7C: db $0A;X
L067F7D: db $21;X
L067F7E: db $0E;X
L067F7F: db $06;X
L067F80: db $3E;X
L067F81: db $01;X
L067F82: db $CD;X
L067F83: db $8A;X
L067F84: db $34;X
L067F85: db $C3;X
L067F86: db $EC;X
L067F87: db $7F;X
L067F88: db $CD;X
L067F89: db $48;X
L067F8A: db $2A;X
L067F8B: db $D2;X
L067F8C: db $EC;X
L067F8D: db $7F;X
L067F8E: db $23;X
L067F8F: db $35;X
L067F90: db $C3;X
L067F91: db $EC;X
L067F92: db $7F;X
L067F93: db $CD;X
L067F94: db $48;X
L067F95: db $2A;X
L067F96: db $D2;X
L067F97: db $EC;X
L067F98: db $7F;X
L067F99: db $23;X
L067F9A: db $35;X
L067F9B: db $E5;X
L067F9C: db $21;X
L067F9D: db $82;X
L067F9E: db $00;X
L067F9F: db $09;X
L067FA0: db $35;X
L067FA1: db $CA;X
L067FA2: db $AE;X
L067FA3: db $7F;X
L067FA4: db $E1;X
L067FA5: db $21;X
L067FA6: db $13;X
L067FA7: db $00;X
L067FA8: db $19;X
L067FA9: db $36;X
L067FAA: db $10;X
L067FAB: db $C3;X
L067FAC: db $EC;X
L067FAD: db $7F;X
L067FAE: db $E1;X
L067FAF: db $36;X
L067FB0: db $00;X
L067FB1: db $C3;X
L067FB2: db $EC;X
L067FB3: db $7F;X
L067FB4: db $C3;X
L067FB5: db $EC;X
L067FB6: db $7F;X
L067FB7: db $CD;X
L067FB8: db $48;X
L067FB9: db $2A;X
L067FBA: db $D2;X
L067FBB: db $EC;X
L067FBC: db $7F;X
L067FBD: db $23;X
L067FBE: db $36;X
L067FBF: db $6E;X
L067FC0: db $C3;X
L067FC1: db $EC;X
L067FC2: db $7F;X
L067FC3: db $CD;X
L067FC4: db $48;X
L067FC5: db $2A;X
L067FC6: db $D2;X
L067FC7: db $EC;X
L067FC8: db $7F;X
L067FC9: db $3E;X
L067FCA: db $00;X
L067FCB: db $EA;X
L067FCC: db $6F;X
L067FCD: db $C1;X
L067FCE: db $21;X
L067FCF: db $32;X
L067FD0: db $00;X
L067FD1: db $09;X
L067FD2: db $7E;X
L067FD3: db $FE;X
L067FD4: db $66;X
L067FD5: db $28;X
L067FD6: db $05;X
L067FD7: db $3E;X
L067FD8: db $4A;X
L067FD9: db $C3;X
L067FDA: db $DE;X
L067FDB: db $7F;X
L067FDC: db $3E;X
L067FDD: db $48;X
L067FDE: db $CD;X
L067FDF: db $BA;X
L067FE0: db $33;X
L067FE1: db $21;X
L067FE2: db $08;X
L067FE3: db $08;X
L067FE4: db $3E;X
L067FE5: db $83;X
L067FE6: db $CD;X
L067FE7: db $8A;X
L067FE8: db $34;X
L067FE9: db $C3;X
L067FEA: db $EF;X
L067FEB: db $7F;X
L067FEC: db $CD;X
L067FED: db $74;X
L067FEE: db $2B;X
L067FEF: db $C9;X
L067FF0: db $21;X
L067FF1: db $2B;X
L067FF2: db $00;X
L067FF3: db $09;X
L067FF4: db $7E;X
L067FF5: db $B7;X
L067FF6: db $C2;X
L067FF7: db $FF;X
L067FF8: db $7F;X
L067FF9: db $21;X
L067FFA: db $C1;X
L067FFB: db $D6;X
L067FFC: db $C3;X
L067FFD: db $02;X
L067FFE: db $80;X
L067FFF: db $21;X
