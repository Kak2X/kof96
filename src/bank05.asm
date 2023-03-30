INCLUDE "data/objlst/char/iori.asm"
INCLUDE "data/objlst/char/chizuru.asm"

; =============== MoveInputReader_Iori ===============
; Special move input checker for IORI and OIORI.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
; OUT
; - C flag: If set, a move was started
MoveInputReader_Iori:
	mMvIn_Validate Iori
	
.chkAir:
	jp   MoveInputReader_Iori_NoMove
	
.chkGround:
	;             SELECT + B                SELECT + A
IF REV_VER_2 == 0
	mMvIn_ChkEasy MoveInit_Iori_KinYaOtome, MoveInit_Iori_KinYaOtomeEscapeD
ELSE
	mMvIn_ChkEasy MoveInit_Iori_KinYaOtome, MoveInit_Iori_ScumGale
ENDC
	mMvIn_ChkGA Iori, .chkPunch, .chkKick
.chkPunch:
	; DBDF+P -> Kin 1201 Shiki Ya Otome
	mMvIn_ValSuper .chkPunchNoSuper
	mMvIn_ChkDir MoveInput_DBDF, MoveInit_Iori_KinYaOtome
.chkPunchNoSuper:
	; FDF+P -> 100 Shiki Oni Yaki
	mMvIn_ChkDir MoveInput_FDF, MoveInit_Iori_OniYaki
	; BDF+P -> Scum Gale
	mMvIn_ChkDir MoveInput_BDF, MoveInit_Iori_ScumGale
	; DF+P -> 108 Shiki Yami-barai
	mMvIn_ChkDir MoveInput_DF, MoveInit_Iori_YamiBarai
	; DB+P -> 127 Aoi Hana
	mMvIn_ChkDir MoveInput_DB, MoveInit_Iori_AoiHana
	jp   MoveInputReader_Iori_NoMove
.chkKick:
	mMvIn_ValSkipWithChar CHAR_ID_IORI, .chkKickNoSuper
	; O.Iori only!
	;##
	; DBDF+K -> Kin 1201 Shiki Ya Otome (Alt)
	mMvIn_ValSuper .chkKickNoSuper
	mMvIn_ChkDir MoveInput_DBDF, MoveInit_OIori_KinYaOtome
	;##
.chkKickNoSuper:
	; FDB+K -> Shiki Koto Tsuki In
	mMvIn_ChkDir MoveInput_FDB, MoveInit_Iori_KotoTsukiIni
	jp   MoveInputReader_Iori_NoMove
; =============== MoveInit_Iori_YamiBarai ===============
MoveInit_Iori_YamiBarai:
	mMvIn_ValProjActive Iori
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_IORI_YAMI_BARAI_L, MOVE_IORI_YAMI_BARAI_H
	call MoveInputS_SetSpecMove_StopSpeed
	call Play_Proj_CopyMoveDamageFromPl
	jp   MoveInputReader_Iori_SetMove
; =============== MoveInit_Iori_OniYaki ===============
MoveInit_Iori_OniYaki:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_IORI_ONI_YAKI_L, MOVE_IORI_ONI_YAKI_H
	call MoveInputS_SetSpecMove_StopSpeed
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_INVULN, [hl]
	jp   MoveInputReader_Iori_SetMove
; =============== MoveInit_Iori_AoiHana ===============
MoveInit_Iori_AoiHana:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_IORI_AOI_HANA_L, MOVE_IORI_AOI_HANA_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Iori_SetMove
; =============== MoveInit_Iori_KotoTsukiIni ===============
MoveInit_Iori_KotoTsukiIni:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_IORI_KOTO_TSUKI_IN_L, MOVE_IORI_KOTO_TSUKI_IN_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Iori_SetMove
; =============== MoveInit_Iori_ScumGale ===============
MoveInit_Iori_ScumGale:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_ValStartCmdThrow_StdColi Iori
	mMvIn_GetLH MOVE_IORI_SCUM_GALE_L, MOVE_IORI_SCUM_GALE_H
	call MoveInputS_SetSpecMove_StopSpeed
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_INVULN, [hl]
	jp   MoveInputReader_Iori_SetMove
; =============== MoveInit_Iori_KinYaOtomeEscapeD ===============
; [POI] Part of MoveInit_Iori_KinYaOtomeD used as failsafe, that may be inaccessible by normal means.
;       No move also ever transitions to MOVE_IORI_KIN_YA_OTOME_ESCAPE_H.
MoveInit_Iori_KinYaOtomeEscapeD:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_IORI_KIN_YA_OTOME_ESCAPE_L, MOVE_IORI_KIN_YA_OTOME_ESCAPE_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Iori_SetMove
; =============== MoveInit_Iori_KinYaOtome ===============
MoveInit_Iori_KinYaOtome:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetSD MOVE_IORI_KIN_YA_OTOME_S, MOVE_IORI_KIN_YA_OTOME_D
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Iori_SetMove
; =============== MoveInit_OIori_KinYaOtome ===============
MoveInit_OIori_KinYaOtome:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetSD MOVE_OIORI_KIN_YA_OTOME_S, MOVE_OIORI_KIN_YA_OTOME_D
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Iori_SetMove
; =============== MoveInputReader_Iori_SetMove ===============
MoveInputReader_Iori_SetMove:
	scf
	ret
; =============== MoveInputReader_Iori_NoMove ===============
MoveInputReader_Iori_NoMove:
	or   a
	ret
	
; =============== MoveC_Iori_YamiBarai ===============
; Move code for Iori's 108 Shiki Yami Barai (MOVE_IORI_YAMI_BARAI_L, MOVE_IORI_YAMI_BARAI_H).
MoveC_Iori_YamiBarai:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	mMvC_ValFrameEnd .anim
		; Depending on the visible frame...
		ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
		add  hl, de
		ld   a, [hl]
		mMvC_ChkTarget .end
		cp   $02*OBJLSTPTR_ENTRYSIZE
		jp   z, .spawnProj
		jp   .anim
; --------------- frame #2 ---------------
.spawnProj:
	call ProjInit_Iori_YamiBarai
	jp   .anim
; --------------- common ---------------
.end:
	call Play_Pl_EndMove
	jr   .ret
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Iori_OniYaki ===============
; Move code for Iori's 100 Shiki Oni Yaki (MOVE_IORI_ONI_YAKI_L, MOVE_IORI_ONI_YAKI_H).
MoveC_Iori_OniYaki:

	; Orochi Iori has its own version with the opponent getting thrown directly on the ground.
	ld   hl, iPlInfo_CharId
	add  hl, bc
	ld   a, [hl]
	cp   CHAR_ID_OIORI				; Playing as Orochi Iori?
	jp   z, MoveC_OIori_OniYaki		; If so, jump
	
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
	; Move 4px forward
	mMvC_ValFrameStart .obj0_cont
		mMvC_SetMoveH +$0400
.obj0_cont:
	; 4 lines of damage at the end
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $04, HITTYPE_HIT_MID0, PF3_FIRE
		jp   .anim
; --------------- frame #1 ---------------
.obj1:
	; Move 8px forward
	mMvC_ValFrameStart .obj1_cont
		mMvC_SetMoveH +$0800
.obj1_cont:
	; 4 lines of damage at the end
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		mMvC_SetDamageNext $04, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE
		jp   .anim
; --------------- frame #2 ---------------
; Jump setup.
.obj2:
	mMvC_ValFrameStart .obj2_cont
		mMvC_PlaySound SFX_FIREHIT_A
		ld   hl, iPlInfo_Flags0
		add  hl, bc
		inc  hl	; Seek to iPlInfo_Flags1
		res  PF1B_INVULN, [hl]
		; Set jump settings depending on the move strength
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
	; Immediately switch to the next frame (YSpeed always > -$09)
	mMvC_NextFrameOnGtYSpeed -$09, ANIMSPEED_NONE
	jp   nc, .doGravity
		mMvC_SetDamageNext $04, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE
		jp   .doGravity
; --------------- frame #3 ---------------
.obj3:
	; Switch to #4 when YSpeed > -$02
	mMvC_NextFrameOnGtYSpeed -$02, ANIMSPEED_NONE
		mMvC_SetSpeedH +$0040
		jp   .doGravity
; --------------- frames #2-4 / common gravity check ---------------
.doGravity:
	; Switch to #5 when we touch the ground
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
	
; =============== MoveC_Iori_OniYaki ===============
; Move code for Orochi Iori's 100 Shiki Oni Yaki (MOVE_IORI_ONI_YAKI_L, MOVE_IORI_ONI_YAKI_H).
MoveC_OIori_OniYaki:
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
	; Move 4px forward
	mMvC_ValFrameStart .obj0_cont
		mMvC_SetMoveH +$0400
.obj0_cont:
	; 4 lines of damage at the end
	mMvC_ValFrameEnd .anim
		; Different hit flags compared to normal version
		mMvC_SetDamageNext $04, HITTYPE_HIT_MID0, PF3_FIRE|PF3_LASTHIT
		jp   .anim
; --------------- frame #1 ---------------
.obj1:
	; Move 8px forward
	mMvC_ValFrameStart .obj1_cont
		mMvC_SetMoveH +$0800
.obj1_cont:
	; 4 lines of damage at the end
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $01 ; No manual control, unlike normal version
		mMvC_SetDamageNext $04, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_LASTHIT
		jp   .anim
; --------------- frame #2 ---------------
; Jump setup.
.obj2:
	mMvC_ValFrameStart .obj2_cont
		mMvC_PlaySound SFX_FIREHIT_A
		ld   hl, iPlInfo_Flags0
		add  hl, bc
		inc  hl	; Seek to iPlInfo_Flags1
		res  PF1B_INVULN, [hl]
		; Set jump settings depending on the move strength.
		; These are move fowards further than the normal version.
		mMvIn_ChkLHE .obj2_setJumpH, .obj2_setJumpE
	.obj2_setJumpL: ; Light
		mMvC_SetSpeedH +$0100
		mMvC_SetSpeedV -$0600
		jp   .obj2_doGravity
	.obj2_setJumpH: ; Heavy
		mMvC_SetSpeedH +$0200
		mMvC_SetSpeedV -$0700
		jp   .obj2_doGravity
	.obj2_setJumpE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH +$0300
		mMvC_SetSpeedV -$0800
	.obj2_doGravity:
		jp   .doGravity
.obj2_cont:
	; Immediately switch to the next frame (YSpeed always > -$09)
	mMvC_NextFrameOnGtYSpeed -$09, ANIMSPEED_INSTANT
	; No damage dealt here, unlike the normal version.
	jp   nc, .doGravity
	jp   .doGravity
; --------------- frame #3 ---------------
; Launches the opponent on the ground, unique to this version.
.obj3:
	mMvC_ValFrameEnd .doGravity
		mMvC_SetDamageNext $04, HITTYPE_DROP_DB_A, PF3_HEAVYHIT|PF3_FIRE|PF3_LASTHIT
		jp   .doGravity
; --------------- frame #4 ---------------
.obj4:
	mMvC_ValFrameEnd .doGravity
		; Fall down very slightly forwards while landing from the jump here.
		; Also enable manual control to stay on #5 until touching the ground.
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		mMvC_SetSpeedH $0040
		jp   .doGravity
; --------------- frames #2-5 / common gravity check ---------------
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
	
; =============== MoveC_Iori_AoiHana ===============
; Move code for Iori's 127 Aoi Hana (MOVE_IORI_AOI_HANA_L, MOVE_IORI_AOI_HANA_H).
; Three-part dash that ends early in the second for the light version. 
MoveC_Iori_AoiHana:
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
; Forward dash #1.
.obj0:
	mMvC_ValFrameStart .obj0_cont
		mMvC_SetSpeedH +$0400
		mMvC_PlaySound SCT_LIGHT
.obj0_cont:
	jp   .moveH
; --------------- frame #1 ---------------
; Set damage for dash #2.
.obj1:
	mMvC_ValFrameEnd .moveH
	
		;
		; Set the damage for the next frame.
		;
		; The light version of the move enables manual control, preventing it from advancing from #2 to #3.
		; This means only the heavy version does the third part of the move (the small jump).
		;
		
		; Set damage for heavy version initially
		mMvC_SetDamageNext $08, HITTYPE_DROP_MAIN, PF3_LASTHIT
		
		ld   hl, iPlInfo_MoveId
		add  hl, bc
		ld   a, [hl]				
		cp   MOVE_IORI_AOI_HANA_H	; Using the heavy version?
		jp   z, .moveH				; If so, skip
	.obj1_setDamageL:
		; Otherwise, enable manual control
		ld   hl, iOBJInfo_FrameTotal
		add  hl, de
		ld   [hl], ANIMSPEED_NONE
		; And shake the opponent for longer
		mMvC_SetDamageNext $08, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_LASTHIT
		jp   .moveH
; --------------- frame #2 ---------------
; Forward dash #2.
.obj2:
	; Move 4px/frame forward
	mMvC_ValFrameStart .obj2_cont
		mMvC_SetSpeedH +$0400
		mMvC_PlaySound SCT_LIGHT
.obj2_cont:

	; If we aren't doing the heavy version, slow down at $00.50px/frame.
	; The move ends if when we stop moving.
	ld   hl, iPlInfo_MoveId
	add  hl, bc
	ld   a, [hl]
	cp   MOVE_IORI_AOI_HANA_H	; Using the heavy version?
	jp   z, .moveH				; If so, jump
	
	; This counts as our recovery for the light version, since it takes a bit to stop.
	mMvC_DoFrictionH +$0050
	jp   nc, .anim
		jp   .end
; --------------- frames #0-2 / common horizontal movement ---------------
.moveH:
	mMvC_DoFrictionH +$0050
	jp   .anim
; --------------- frame #3 ---------------
; Small jump start. Heavy version only.
.obj3:
	
	mMvC_ValFrameStart .obj3_cont
		; Set forward jump speed
		mMvC_SetSpeedH +$0200
		mMvC_SetSpeedV -$0200
		jp   .doGravity
.unused_obj3_playJumpSFX:
	; [TCRF] Unreferenced sound playback command.
	;        Likely used to be above the .doGravity call, since we're starting a jump after all.
	mMvC_PlaySound SFX_SUPERJUMP
.obj3_cont:
	; Deal 8 lines of damage and drop the opponent on the ground when switchcing to #4.
	; This pretty much ends the combo string, so it's better to perform the light version instead.
	mMvC_ValFrameEnd .doGravity
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		mMvC_SetDamageNext $08, HITTYPE_DROP_DB_A, PF3_HEAVYHIT
		jp   .doGravity
; --------------- frame #4 ---------------
; Small jump, mid-jump. Heavy version only.
.obj4:
	mMvC_ValFrameStart .doGravity
		mMvC_PlaySound SCT_LIGHT
		jp   .doGravity
; --------------- frames #3-4 / common gravity check ---------------
; Switch to #5 when touching the ground.
.doGravity:
	mMvC_ChkGravityHV $0030, .anim
		mMvC_SetLandFrame $05*OBJLSTPTR_ENTRYSIZE, $03
		jp   .ret
; --------------- frame #5 ---------------
; Recovery after the jump.
.chkEnd:
	mMvC_ValFrameEnd .anim
; --------------- common ---------------
.end:
	call Play_Pl_EndMove
	jr   .ret
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Iori_KotoTsukiIn ===============
; Move code for Iori's 212 Shiki Koto Tsuki In (MOVE_IORI_KOTO_TSUKI_IN_L, MOVE_IORI_KOTO_TSUKI_IN_H).
MoveC_Iori_KotoTsukiIn:
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
	jp   z, .chkEnd
	jp   .anim ; We never get here
; --------------- frame #0 ---------------
; Startup.
.obj0:
	mMvC_ValFrameEnd .chkNear
		mMvC_SetAnimSpeed $01
		jp   .chkNear
; --------------- frame #1 ---------------
; Run towards the opponent.
.obj1:
	mMvC_ValFrameStart .obj1_cont
		; Play step SFX at the start of this, as well as the other frames
		; for the run sequence.
		mMvC_PlaySound SFX_STEP
		; Set run speed
		mMvIn_ChkLHE .obj1_setDashH, .obj1_setDashE
	.obj1_setDashL: ; Light
		mMvC_SetSpeedH +$0400
		jp   .moveH
	.obj1_setDashH: ; Heavy
		mMvC_SetSpeedH +$0580
		jp   .moveH
	.obj1_setDashE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH +$0700
		jp   .moveH
.obj1_cont:
	jp   .chkNear
; --------------- frame #2 ---------------
; Run towards the opponent.
.obj2:
	mMvC_ValFrameStart .chkNear
		mMvC_PlaySound SFX_STEP
		jp   .chkNear
; --------------- frame #3 ---------------
; Run towards the opponent.
.obj3:
	mMvC_ValFrameStart .obj3_cont
		mMvC_PlaySound SFX_STEP
.obj3_cont:
	mMvC_ValFrameEnd .chkNear
		; Disable timing for #4
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		jp   .moveH
; --------------- frame #4 ---------------
; If we got here, we didn't get close enough to the opponent.
; Slow down at 1px/frame, and end the move when we stop moving.
.obj4:
	mMvC_DoFrictionH $0100
		jp   nc, .ret
		jp   .end
; --------------- frames #0-3 / player distance check ---------------
.chkNear:
	; Advances to #5 if we get near
	mMvIn_ValClose .moveH
		mMvC_SetFrame $05*OBJLSTPTR_ENTRYSIZE, $01
		call OBJLstS_ApplyXSpeed
		jp   .ret
; --------------- frames #0-4 / common run movement ---------------
.moveH:
	call OBJLstS_ApplyXSpeed
	jp   .anim
	
; --------------- frame #5 ---------------	
;
.obj5:
	; Slow down at 0.5px/frame while doing this
	mMvC_DoFrictionH $0080
	
	
	;
	; Don't continue to #6 until we collided with the opponent.
	;
	ld   hl, iPlInfo_ColiFlags
	add  hl, bc
	bit  PCF_HITOTHER, [hl]				; Did we reach?
	jp   z, .obj5_chkEnd				; If not, jump
	ld   hl, iPlInfo_Flags1Other
	add  hl, bc
	bit  PF1B_INVULN, [hl]				; Is the opponent invulnerable?
	jp   z, .obj5_setDamage				; If not, jump
.obj5_chkEnd:
	mMvC_ValFrameEnd .anim
		jp   .end
.obj5_setDamage:
	; Switch to #6
	mMvC_SetFrame $06*OBJLSTPTR_ENTRYSIZE, $02
	; Deal more damage the next frame.
	; The drop type and PF3_LASTHIT differ between Iori and O.Iori, but damage is the same.
	ld   hl, iPlInfo_CharId
	add  hl, bc
	ld   a, [hl]
	cp   CHAR_ID_OIORI				; Playing as IORI'?
	jp   z, .obj5_setDamageOIori	; If so, jump
.obj5_setDamageIori:
	mMvC_SetDamageNext $08, HITTYPE_DROP_DB_A, PF3_HEAVYHIT|PF3_FIRE
	jp   .ret
.obj5_setDamageOIori:
	mMvC_SetDamageNext $08, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_LASTHIT
	jp   .ret
; --------------- frame #6 ---------------
; Delay after the hit.
.obj6:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $0A
		jp   .anim
; --------------- frame #7 ---------------
; Recovery.
.chkEnd:
	mMvC_ValFrameEnd .anim
; --------------- common ---------------
.end:
	call Play_Pl_EndMove
	jp   .ret
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Iori_ScumGale ===============
; Move code for Iori's Scum Gale (MOVE_IORI_SCUM_GALE_L, MOVE_IORI_SCUM_GALE_H).
; Command throw.
MoveC_Iori_ScumGale:
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
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $06, HITTYPE_THROW_ROTU, PF3_HEAVYHIT
		mMvC_MoveThrowOp -$08, +$00 ; Move back 8px
		jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $06, HITTYPE_THROW_ROTU, PF3_HEAVYHIT|PF3_LASTHIT
		mMvC_MoveThrowOp +$04, +$00 ; Move fwd 4px
		jp   .anim
; --------------- frame #2 ---------------
.obj2:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI0, PF3_HEAVYHIT|PF3_LASTHIT
		jp   .anim
; --------------- frame #3 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		mMvC_EndThrow_Slow
		jp   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Iori_KinYaOtomeEscapeD ===============
; [POI] Move code for an alternate continuation of the desperation version of Iori's Kin 1201 Shiki Ya Otome (MOVE_IORI_KIN_YA_OTOME_ESCAPE_L, MOVE_IORI_KIN_YA_OTOME_ESCAPE_H).
;       This is only triggered if the opponent somehow escapes during the move (though it's also included in the move shortcuts)
MoveC_Iori_KinYaOtomeEscapeD:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .setSpeed1E
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .setSpeed28
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .flipX
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .setSpeed08
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .setSpeed10
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .setSpeed32
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .setSpeed24
	cp   $07*OBJLSTPTR_ENTRYSIZE
	jp   z, .resetFlipX
	cp   $08*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamageLine
	cp   $0A*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamageLine
	cp   $0C*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamageLine
	cp   $0E*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamageLine
	cp   $10*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamageLine
	cp   $12*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamageLine
	cp   $14*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamageLine
	cp   $16*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamageLine
	cp   $18*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamageLine
	cp   $1A*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamageDrop
	cp   $1B*OBJLSTPTR_ENTRYSIZE
	jp   z, .setAnimSpeed28_2
	cp   $1C*OBJLSTPTR_ENTRYSIZE
	jp   z, .setAnimSpeed06
	cp   $1D*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim
; --------------- frame #0 ---------------
.setSpeed1E:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $1E
		jp   .anim
; --------------- frame #1 ---------------
.setSpeed28:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $28
		jp   .anim
; --------------- frame #2 ---------------
.flipX:
	mMvC_ValFrameStart .setSpeed04
		; Horiziontally flip Iori, and save the original flags elsewhere
		ld   hl, iOBJInfo_OBJLstFlags
		add  hl, de
		ld   a, [hl]
		res  SPRB_XFLIP, [hl]
		inc  hl			; Seek to iOBJInfo_OBJLstFlagsView
		res  SPRB_XFLIP, [hl]
		ld   hl, iPlInfo_Iori_Mystery_OBJLstFlagsOrig
		add  hl, bc
		ld   [hl], a
.setSpeed04:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $04
		mMvC_PlaySound SCT_DIZZY
		jp   .anim
; --------------- frame #3 ---------------
.setSpeed08:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $08
		jp   .anim
; --------------- frame #4 ---------------
.setSpeed10:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $10
		jp   .anim
; --------------- frame #5 ---------------
.setSpeed32:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $32
		jp   .anim
; --------------- frame #6 ---------------
.setSpeed24:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $24
		jp   .anim
; --------------- frame #7 ---------------
.resetFlipX:
	mMvC_ValFrameStart .setSpeed00
		; Flip Iori back by restoring the original flags
		ld   hl, iPlInfo_Iori_Mystery_OBJLstFlagsOrig
		add  hl, bc
		ld   a, [hl]
		ld   hl, iOBJInfo_OBJLstFlags
		add  hl, de
		ldi  [hl], a	; Restore iOBJInfo_OBJLstFlags
		ld   [hl], a	; Restore iOBJInfo_OBJLstFlagsView
.setSpeed00:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_INSTANT
		jp   .anim
; --------------- even frames #8,A,C,E,10,12,14,16,18 ---------------
; Single punches that deal a single line of damage each.
.setDamageLine:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTIGS, $00
		jp   .anim
; --------------- frame #1A ---------------
; Finisher, opponent launched with a backwards jump.
.setDamageDrop:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $01, HITTYPE_DROP_MAIN, $00
		jp   .anim
; --------------- frame #1B ---------------
.setAnimSpeed28_2:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $28
		jp   .anim
; --------------- frame #1C ---------------
.setAnimSpeed06:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $06
		jp   .anim
; --------------- frame #1D ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jp   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Iori_KinYaOtomeS ===============
; Move code for the super version of Iori's Kin 1201 Shiki Ya Otome (MOVE_IORI_KIN_YA_OTOME_S).
MoveC_Iori_KinYaOtomeS:
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
	jp   z, .setDamage0
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage1
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage1
	cp   $07*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage1
	cp   $09*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage1
	cp   $0B*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage1
	cp   $0D*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage1
	cp   $0F*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage1
	cp   $10*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage1_chkOtherBlock
	cp   $11*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage1_chkOtherBlock
	cp   $12*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamageFinisher
	cp   $13*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	cp   $14*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .setDamage0_chkOtherBlock
; --------------- frame #0 ---------------
; Startup.
.obj0:
	mMvC_ValFrameStart .obj0_cont
		mMvC_PlaySound SCT_HEAVY
.obj0_cont:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $12
		jp   .anim
; --------------- frame #1 ---------------
; Run towards the opponent.
; We have $12 frames to hit the opponent, otherwise the move ends.
.obj1:
	mMvC_ValFrameStart .obj1_cont
		; Move forward 7px/frame at the start
		mMvC_SetSpeedH +$0700
		jp   .moveH
.obj1_cont:
	mMvC_ValFrameEnd .obj1_chkGuard
		jp   .end
.obj1_chkGuard:
IF REV_VER_2 == 0
	;
	; Continue moving forwards until we collided (last frame) with the opponent.
	; If the opponent blocked the hit, switch to #14. Otherwise, continue to #2.
	;
	ld   hl, iPlInfo_ColiFlags
	add  hl, bc
	bit  PCF_HITOTHER, [hl]				; Did we reach?
	jp   z, .obj1_chkGuard_noHit		; If not, skip
	ld   hl, iPlInfo_Flags1Other
	add  hl, bc
	bit  PF1B_INVULN, [hl]				; Is the opponent invulnerable?
	jp   nz, .obj1_chkGuard_noHit		; If so, skip
	bit  PF1B_HITRECV, [hl]				; Did the opponent get hit?
	jp   z, .obj1_chkGuard_noHit		; If not, skip	
	
	bit  PF1B_GUARD, [hl]				; Is the opponent blocking?
	jp   nz, .obj1_chkGuard_guard		; If so, jump
ELSE
	; Identical check, but calling the copy in BANK 0 to save space.
	mMvC_ValHit .obj1_chkGuard_noHit, .obj1_chkGuard_guard
ENDC
	.obj1_chkGuard_noGuard:
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI1, PF3_FIRE
		mMvC_SetFrame $02*OBJLSTPTR_ENTRYSIZE, $01
		jp   .ret
.obj1_chkGuard_noHit:
	jp   .moveH
.obj1_chkGuard_guard:
	mMvC_SetFrame $14*OBJLSTPTR_ENTRYSIZE, $0A
	jp   .ret
	
; --------------- odd frames #3,5,7,9,B,D,F - line damage + block check ---------------
.setDamage1:
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI1, PF3_FIRE
		jp   .chkOtherEscape
; --------------- frame #2 ---------------
.setDamage0:
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI0, PF3_FIRE
		jp   .anim
; --------------- even frames - line damage ---------------
.setDamage0_chkOtherBlock:
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI0, PF3_FIRE
		jp   .chkOtherEscape
; --------------- frames #10,11 - line damage + block check ---------------		
.setDamage1_chkOtherBlock:
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI1, $00
; --------------- common escape check ---------------
; Done at the start of about half of the frames.
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
; --------------- frame #12 ---------------
; Deals the big boy damage.
.setDamageFinisher:
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $10, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE
		jp   .anim
; --------------- common horizontal movement ---------------
.moveH:
	call OBJLstS_ApplyXSpeed
	jp   .anim
; --------------- frame #13,#14 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
; --------------- common ---------------
.end:
	call Play_Pl_EndMove
	jp   .ret
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret

; =============== MoveC_Iori_KinYaOtomeD ===============
; Move code for the desperation version of Iori's Kin 1201 Shiki Ya Otome (MOVE_IORI_KIN_YA_OTOME_D).
MoveC_Iori_KinYaOtomeD:
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
	jp   z, .setSpeed0A
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage05
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage05
	cp   $08*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage05
	cp   $0A*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage05
	cp   $0C*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage05
	cp   $0E*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage05
	cp   $10*OBJLSTPTR_ENTRYSIZE
	jp   z, .setSpeed0E
	cp   $11*OBJLSTPTR_ENTRYSIZE
	jp   z, .playDizzySFX
	cp   $12*OBJLSTPTR_ENTRYSIZE
	jp   z, .setSpeed0A
	cp   $14*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage05
	cp   $16*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage05
	cp   $19*OBJLSTPTR_ENTRYSIZE
	jp   z, .setLongDelay
	cp   $1A*OBJLSTPTR_ENTRYSIZE
	jp   z, .setSpeed02
	cp   $1B*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameStart .obj0_cont
		mMvC_PlaySound SCT_HEAVY
.obj0_cont:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $12
		jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameStart .obj1_cont
		mMvC_SetSpeedH $0700
		jp   .moveH
.obj1_cont:
	mMvC_ValFrameEnd .obj1_chkGuard
		jp   .end
.obj1_chkGuard:
IF REV_VER_2 == 0
	;
	; Continue moving forwards until we collided (last frame) with the opponent.
	; If the opponent blocked the hit, switch to #1B. Otherwise, continue to #2.
	;
	ld   hl, iPlInfo_ColiFlags
	add  hl, bc
	bit  PCF_HITOTHER, [hl]				; Did we reach?
	jp   z, .obj1_chkGuard_noHit		; If not, skip
	ld   hl, iPlInfo_Flags1Other
	add  hl, bc
	bit  PF1B_INVULN, [hl]				; Is the opponent invulnerable?
	jp   nz, .obj1_chkGuard_noHit		; If so, skip
	bit  PF1B_HITRECV, [hl]				; Did the opponent get hit?
	jp   z, .obj1_chkGuard_noHit		; If not, skip	
	
	bit  PF1B_GUARD, [hl]				; Is the opponent blocking?
	jp   nz, .obj1_chkGuard_guard		; If so, jump
ELSE
	; Identical check, but calling the copy in BANK 0 to save space.
	mMvC_ValHit .obj1_chkGuard_noHit, .obj1_chkGuard_guard
ENDC
	.obj1_chkGuard_noGuard:
		; Damage confirmed, switch to #2
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI1, PF3_FIRE
		mMvC_SetFrame $02*OBJLSTPTR_ENTRYSIZE, $01
		jp   .ret
.obj1_chkGuard_noHit:
	; Not hit yet, continue moving
	jp   .moveH
.obj1_chkGuard_guard:
	; Blocked, jump to #1B
	mMvC_SetFrame $1B*OBJLSTPTR_ENTRYSIZE, $0A
	jp   .ret
; --------------- frame #2 ---------------
.obj2:
	;
	; Force the opponent to face the same direction outsid of the first frame.
	;
	mMvC_ValFrameNotStart .obj2_setDamage
		jp   .anim
.obj2_setDamage:
	mMvC_SetDamageNext $01, HITTYPE_HIT_MULTIGS, $00
	;--
	; This is exactly the same as the code in Pl_CopyXFlipToOther.
	push de
		; D = SPR_XFLIP flag for current player
		ld   hl, iOBJInfo_OBJLstFlags
		add  hl, de
		ld   a, [hl]
		and  a, SPR_XFLIP
		ld   d, a
		
		; HL = Ptr to opponent's OBJLst flags
		ld   hl, iPlInfo_PlId
		add  hl, bc
		ld   a, [hl]		; A = iPlInfo_PlId
		or   a				; A != PL1?
		jp   nz, .pl2		; If so, jump
	.pl1:
		; 1P gets 2P's flags
		ld   hl, wOBJInfo_Pl2+iOBJInfo_OBJLstFlags
		jp   .sync
	.pl2:
		; 2P gets 1P's flags
		ld   hl, wOBJInfo_Pl1+iOBJInfo_OBJLstFlags
	.sync:
	
		; Replace the opponent's SPR_XFLIP flag with ours
		ld   a, [hl]			; A = Opponent's OBJLst flags
		and  a, $FF^SPR_XFLIP	; Remove SPR_XFLIP flag
		or   a, d				; Copy over ours
		ld   [hl], a			; Save back updated value
	pop  de
	;--
	jp   .anim
; --------------- frames #3,#12 ---------------
.setSpeed0A:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $0A
		jp   .anim
; --------------- frame #10 ---------------
.setSpeed0E:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $1E
		jp   .anim
; --------------- frame #11 ---------------
.playDizzySFX:
	mMvC_ValFrameEnd .anim
		mMvC_PlaySound SCT_DIZZY
		jp   .anim
; --------------- frames #4,6,8,A,C,E,14,16 ---------------
.setDamage05:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $05, HITTYPE_HIT_MULTIGS, $00
		jp   .chkOtherEscape
	.chkOtherEscape:
IF REV_VER_2 == 0
		;
		; [POI] If the opponent somehow isn't in one of the hit effects 
		;       this move sets, switch to an alternate version of the move.
		;       This can happen if the opponent gets hit by a previously thrown
		;       fireball in the middle of the move.		
		;
		ld   hl, iPlInfo_HitTypeIdOther
		add  hl, bc
		ld   a, [hl]
		cp   HITTYPE_HIT_MULTI0		; A == HITTYPE_HIT_MULTI0?
		jp   z, .anim				; If so, skip
		cp   HITTYPE_HIT_MULTI1		; A == HITTYPE_HIT_MULTI1?
		jp   z, .anim				; If so, skip
		cp   HITTYPE_HIT_MULTIGS	; A == HITTYPE_HIT_MULTIGS?
		jp   z, .anim				; If so, skip
ELSE
		mMvC_ValEscape .anim
ENDC
			call Play_Pl_EmptyPowOnSuperEnd
			ld   hl, iPlInfo_Flags0
			add  hl, bc
			res  PF0B_SPECMOVE, [hl]
			res  PF0B_SUPERMOVE, [hl]
			ld   a, MOVE_IORI_KIN_YA_OTOME_ESCAPE_L
			call Pl_SetMove_StopSpeed
			jp   .ret
; --------------- frame #19 ---------------
.setLongDelay:
	; The first time get here, set big boy damage
	mMvC_ValFrameNotStart .setDamageFinish
		; Set a long delay for the next frame (recovery)
		mMvC_ValFrameEnd .anim
			mMvC_SetAnimSpeed $3C
			jp   .anim
.setDamageFinish:
	mMvC_SetDamageNext $10, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE
	jp   .anim
; --------------- common horizontal movement ---------------
.moveH:
	call OBJLstS_ApplyXSpeed
	jp   .anim
; --------------- frame #1A ---------------
.setSpeed02:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $02
		jp   .anim
; --------------- frame #1B ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
; --------------- common ---------------
.end:
	call Play_Pl_EndMove
	jp   .ret
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_OIori_KinYaOtome ===============
; Move code for Orochi Iori's version of Kin 1201 Shiki Ya Otome (MOVE_OIORI_KIN_YA_OTOME_S, MOVE_OIORI_KIN_YA_OTOME_D).
MoveC_OIori_KinYaOtome:
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
	jp   z, .setDamage1
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage0
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage1
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkLoop0
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage1
	cp   $07*OBJLSTPTR_ENTRYSIZE
	jp   z, .startLoop1
	cp   $08*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage2
	cp   $09*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkLoop1
	cp   $0A*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage0_seq2
	cp   $0B*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage1_seq2
	cp   $0C*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage2_seq2
	cp   $0D*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage2_seq2
	cp   $0E*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	cp   $0F*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim ; We never get here
; --------------- frame #0 ---------------
; Startup.
.obj0:
	mMvC_ValFrameStart .obj0_cont
		mMvC_PlaySound SCT_HEAVY
.obj0_cont:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $14
		jp   .anim
; --------------- frame #1 ---------------
; Very fast forward dash.
.obj1:
	mMvC_ValFrameStart .obj1_cont
		mMvC_SetSpeedH +$0780
		jp   .moveH
.obj1_cont:
	; End the move if we didn't collide with the opponent by the end of the frame
	mMvC_ValFrameEnd .obj1_chkGuard
		jp   .end
.obj1_chkGuard:

IF REV_VER_2 == 0
	;
	; Continue moving forwards until we collided (last frame) with the opponent.
	; If the opponent blocked the hit, switch to #F. Otherwise, continue to #2.
	;
	ld   hl, iPlInfo_ColiFlags
	add  hl, bc
	bit  PCF_HITOTHER, [hl]				; Did we reach?
	jp   z, .obj1_chkGuard_noHit		; If not, skip
	ld   hl, iPlInfo_Flags1Other
	add  hl, bc
	bit  PF1B_INVULN, [hl]				; Is the opponent invulnerable?
	jp   nz, .obj1_chkGuard_noHit		; If so, skip
	bit  PF1B_HITRECV, [hl]				; Did the opponent get hit?
	jp   z, .obj1_chkGuard_noHit		; If not, skip	
	
	bit  PF1B_GUARD, [hl]				; Is the opponent blocking?
	jp   nz, .obj1_chkGuard_guard		; If so, jump
ELSE
	; Identical check, but calling the copy in BANK 0 to save space.
	mMvC_ValHit .obj1_chkGuard_noHit, .obj1_chkGuard_guard
ENDC
	.obj1_chkGuard_noGuard:
		; Damage confirmed, switch to #2
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI1, PF3_FIRE|PF3_LIGHTHIT
		mMvC_SetFrame $02*OBJLSTPTR_ENTRYSIZE, $00
		
		; Loop the damage frames (#2-#5) 4 times
		ld   hl, iPlInfo_OIori_KinYaOtome_LoopCount
		add  hl, bc
		ld   [hl], $04
		jp   .ret
.obj1_chkGuard_noHit:
	; Nothing hit yet, continue moving
	jp   .moveH
.obj1_chkGuard_guard:
	; Blocked, switch to #F, the recovery frame when the opponent blocked it
	mMvC_SetFrame $0F*OBJLSTPTR_ENTRYSIZE, $0A
	jp   .ret
	
; --------------- frames #2,#4,#6 ---------------
; Frame used during multiple damage loops/sequences.
.setDamage1:
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI1, PF3_FIRE
		jp   .chkOtherEscape
; --------------- frame #3 ---------------
; For damage loop 0.
.setDamage0:
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI0, PF3_FIRE
		jp   .chkOtherEscape
; --------------- frame #5 ---------------
; Loop back to #2 until the counter elapses
.chkLoop0:
	mMvC_ValFrameStart .anim
		ld   hl, iPlInfo_OIori_KinYaOtome_LoopCount
		add  hl, bc
		dec  [hl]
		jp   z, .chkLoop0_noLoop
		ld   hl, iOBJInfo_OBJLstPtrTblOffset
		add  hl, de
		ld   [hl], $01*OBJLSTPTR_ENTRYSIZE ; offset by -1
	.chkLoop0_noLoop:
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI0, PF3_FIRE
		jp   .chkOtherEscape
; --------------- frame #7 ---------------
.startLoop1:
	mMvC_ValFrameStart .anim
		; Loop the second set of damage frames (#8-9) 4 times
		ld   hl, iPlInfo_OIori_KinYaOtome_LoopCount
		add  hl, bc
		ld   [hl], $04
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTIGS, PF3_FIRE
		jp   .chkOtherEscape
; --------------- frame #8 ---------------
; For damage loop 1.
.setDamage2:
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTIGS, PF3_FIRE
		jp   .chkOtherEscape
; --------------- frame #9 ---------------
; Loop back to #8 until the counter elapses
.chkLoop1:
	mMvC_ValFrameStart .anim
		ld   hl, iPlInfo_OIori_KinYaOtome_LoopCount
		add  hl, bc
		dec  [hl]
		jp   z, .chkLoop1_noLoop
		ld   hl, iOBJInfo_OBJLstPtrTblOffset
		add  hl, de
		ld   [hl], $07*OBJLSTPTR_ENTRYSIZE ; offset by -1
	.chkLoop1_noLoop:
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTIGS, PF3_FIRE
		jp   .chkOtherEscape
; --------------- frame #A ---------------
; Damage sequence 2 (no loop). Hit 1.
.setDamage0_seq2:;J
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI0, PF3_LIGHTHIT
		jp   .chkOtherEscape
; --------------- frame #B ---------------
; Damage sequence 2 (no loop). Hit 2.
.setDamage1_seq2:
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI1, PF3_LIGHTHIT
		jp   .chkOtherEscape
; --------------- frames #C,#D ---------------
; Damage sequence 2 (no loop). Hits 3,4.
.setDamage2_seq2:
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE
		jp   .anim
	; --------------- common escape check ---------------
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
		cp   HITTYPE_HIT_MULTI0		; A == HITTYPE_HIT_MULTI0?
		jp   z, .anim				; If so, skip
		cp   HITTYPE_HIT_MULTI1		; A == HITTYPE_HIT_MULTI1?
		jp   z, .anim				; If so, skip
		cp   HITTYPE_HIT_MULTIGS	; A == HITTYPE_HIT_MULTIGS?
		jp   z, .anim				; If so, skip
ELSE
		mMvC_ValEscape .anim
ENDC
			; Otherwise, transition to hop
			ld   a, MOVE_SHARED_HOP_B
			call Pl_SetMove_StopSpeed
			jp   .ret
; --------------- common horizontal movement ---------------
.moveH:
	call OBJLstS_ApplyXSpeed
	jp   .anim
; --------------- frames #E,#F ---------------
; Recovery.
.chkEnd:
	mMvC_ValFrameEnd .anim
; --------------- common ---------------
.end:
	call Play_Pl_EndMove
	jp   .ret
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveInputReader_Mature ===============
; Special move input checker for MATURE.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
; OUT
; - C flag: If set, a move was started
MoveInputReader_Mature:
	mMvIn_Validate Mature
	
.chkAir:
	jp   MoveInputReader_Mature_NoMove
.chkGround:
	;             SELECT + B                   SELECT + A
	mMvIn_ChkEasy MoveInit_Mature_HeavensGate, MoveInit_Mature_Decide
	mMvIn_ChkGA Mature, .chkPunch, .chkKick
.chkPunch:
	; BDF+P -> Decide
	mMvIn_ChkDir MoveInput_BDF, MoveInit_Mature_Decide
	; DB+P -> Death Row
	mMvIn_ChkDir MoveInput_DB, MoveInit_Mature_DeathRow
	; DF+P -> Despair
	mMvIn_ChkDir MoveInput_DF, MoveInit_Mature_Despair
	jp   MoveInputReader_Mature_NoMove
.chkKick:
	; DBDF+K -> Heaven's Gate
	mMvIn_ValSuper .chkKickNoSuper
	mMvIn_ChkDir MoveInput_DBDF, MoveInit_Mature_HeavensGate
.chkKickNoSuper:
	; DB+K -> Metal Massacre
	mMvIn_ChkDir MoveInput_DB, MoveInit_Mature_MetalMassacre
	jp   MoveInputReader_Mature_NoMove
; =============== MoveInit_Mature_Decide ===============
MoveInit_Mature_Decide:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_MATURE_DECIDE_L, MOVE_MATURE_DECIDE_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Mature_SetMove
; =============== MoveInit_Mature_MetalMassacre ===============
MoveInit_Mature_MetalMassacre:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_MATURE_METAL_MASSACRE_L, MOVE_MATURE_METAL_MASSACRE_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Mature_SetMove
; =============== MoveInit_Mature_DeathRow ===============
MoveInit_Mature_DeathRow:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_MATURE_DEATH_ROW_L, MOVE_MATURE_DEATH_ROW_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Mature_SetMove
; =============== MoveInit_Mature_Despair ===============
MoveInit_Mature_Despair:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_MATURE_DESPAIR_L, MOVE_MATURE_DESPAIR_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Mature_SetMove
; =============== MoveInit_Mature_HeavensGate ===============
MoveInit_Mature_HeavensGate:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetSD MOVE_MATURE_HEAVENS_GATE_S, MOVE_MATURE_HEAVENS_GATE_D
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Mature_SetMove
; =============== MoveInputReader_Mature_SetMove ===============
MoveInputReader_Mature_SetMove:
	scf
	ret
; =============== MoveInputReader_Mature_NoMove ===============
MoveInputReader_Mature_NoMove:
	or   a
	ret
	
; =============== MoveC_Mature_Decide ===============
; Move code for Mature's Decide (MOVE_MATURE_DECIDE_L, MOVE_MATURE_DECIDE_H).
MoveC_Mature_Decide:
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
	cp   $07*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $06
		mMvC_PlaySound SCT_HEAVY
		jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameStart .obj1_cont
		mMvIn_ChkLHE .obj1_setDashH, .obj1_setDashE
	.obj1_setDashL: ; Light
		mMvC_SetSpeedH $0100
		jp   .obj1_cont
	.obj1_setDashH: ; Heavy
		mMvC_SetSpeedH $0300
		jp   .obj1_cont
	.obj1_setDashE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH $0500
.obj1_cont:
	mMvC_DoFrictionH $0040
	; If we didn't start the throw by the end of the frame, continue to #2
	; where the move end early.
	call .canStartThrow		; Was the throw started?
	jp   c, .ret			; If so, wait without doing anything
		mMvC_ValFrameEnd .anim
			mMvC_SetAnimSpeed $14
			jp   .anim
; --------------- frame #2 ---------------
; Early abort.
.obj2:
	mMvC_DoFrictionH $0040
	mMvC_ValFrameEnd .anim
		jp   .end
		
; =============== .canStartThrow ===============
; Start the command throw only if the opponent didn't block the hit.
; This works because the move is set to deal damage on contact, so after the first hit PF1B_HITRECV will be set.
;
; See also: Play_Pl_IsMoveHit
; OUT
; - C flag: If set, the throw was started
.canStartThrow:
	ld   hl, iPlInfo_ColiFlags
	add  hl, bc
	bit  PCF_HITOTHER, [hl]			; Did we reach?
	jp   z, .canStartThrow_no		; If not, skip (it whiffed)
	ld   hl, iPlInfo_Flags1Other
	add  hl, bc
	bit  PF1B_INVULN, [hl]			; Is the opponent invulnerable?
	jp   nz, .canStartThrow_no		; If so, skip
	bit  PF1B_HITRECV, [hl]			; Did the opponent get hit?
	jp   z, .canStartThrow_no		; If not, skip
	bit  PF1B_GUARD, [hl]			; Is the opponent blocking?
	jp   nz, .canStartThrow_no		; If so, skip
	
	; Otherwise, try to start the command throw.
	; Which should never fail if we got here.
.canStartThrow_yes:	
	mMvIn_ValStartCmdThrow_AllColi .canStartThrow_no
		; Switch to #3 once it's confirmed
		mMvC_SetFrame $03*OBJLSTPTR_ENTRYSIZE, $04
		scf		; C flag set
		ret
.canStartThrow_no:
	xor  a	; C flag clear
	ret
; =============== end of .canStartThrow ===============

; --------------- frame #3 ---------------
.obj3:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $04, HITTYPE_THROW_ROTL, PF3_HEAVYHIT
		mMvC_MoveThrowOp -$08, -$18 ; Move opponent back 8px, up $18px
		jp   .anim
; --------------- frame #4 ---------------
.obj4:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $04, HITTYPE_THROW_END, PF3_HEAVYHIT
		jp   .anim
; --------------- frame #7 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
; --------------- common ---------------
.end:
	ld   a, PLAY_THROWACT_NONE
	ld   [wPlayPlThrowActId], a
	call Play_Pl_EndMove
	jr   .ret
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Mature_MetalMassacre ===============
; Move code for Mature's Metal Massacre (MOVE_MATURE_METAL_MASSACRE_L, MOVE_MATURE_METAL_MASSACRE_H).
MoveC_Mature_MetalMassacre:
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
	cp   $07*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj7
	cp   $08*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .damageH40
; --------------- frame #0 ---------------
; Initial dash forward.
.obj0:
	mMvC_ValFrameStart .obj0_chkPlNear
		mMvIn_ChkLHE .obj0_setDashH, .obj0_setDashE
	.obj0_setDashL: ; Light
		mMvC_SetSpeedH $0500
		jp   .obj0_chkPlNear
	.obj0_setDashH: ; Heavy
		mMvC_SetSpeedH $0600
		jp   .obj0_chkPlNear
	.obj0_setDashE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH $0700
	.obj0_chkPlNear:
		jp   .chkPlNear
; --------------- frame #1 ---------------
; Initial dash forward.	
.obj1:
	mMvC_ValFrameStart .chkPlNear
		mMvC_PlaySound SFX_STEP
		jp   .chkPlNear
; --------------- frame #2 ---------------
; Initial dash forward.
.obj2:
	mMvC_ValFrameStart .obj2_cont
		mMvC_PlaySound SFX_STEP	
.obj2_cont:
	mMvC_ValFrameEnd .chkPlNear
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		jp   .moveH
; --------------- frame #3 ---------------
; Early abort.
.obj3:
	mMvC_DoFrictionH $0100
	jp   nc, .ret
	jp   .end
; --------------- frames #0-2 / common near check ---------------	
; Switch to #4 as soon as we get near the opponent.
; If by the end of #2 we don't, the animation switches to #3 and the move ends there.
.chkPlNear:
	mMvIn_ValClose .moveH, $30
		mMvC_SetFrame $10, $00
		call OBJLstS_ApplyXSpeed
		IF FIX_BUGS == 1
			jp   .ret
		ELSE
			jp   MoveC_Mature_Despair.ret
		ENDC
; --------------- common horz. movement ---------------	
.moveH:
	call OBJLstS_ApplyXSpeed
	jp   .anim
; --------------- frames #4-6 ---------------	
; We're close to the opponent now.
; Deal continuously 1 line of damage, slowing down in the process.
.damageH40:
	mMvC_SetDamage $01, HITTYPE_HIT_MID0, PF3_LIGHTHIT
	mMvC_DoFrictionH $0040
	jp   .anim
; --------------- frame #7 ---------------
; Like the previous one, but slowing down more.
.obj7:
	mMvC_SetDamage $01, HITTYPE_HIT_MID0, PF3_LIGHTHIT
	mMvC_DoFrictionH $0080
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $14
		jp   .anim
; --------------- frame #8 ---------------		
.chkEnd:
	mMvC_DoFrictionH $0080
	mMvC_ValFrameEnd .anim
; --------------- common ---------------	
.end:
	call Play_Pl_EndMove
	jp   .ret
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Mature_DeathRow ===============
; Move code for Mature's Death Row (MOVE_MATURE_DEATH_ROW_L, MOVE_MATURE_DEATH_ROW_H).
; This move can repeat up to three times by having repeated entries in the frame handler.
MoveC_Mature_DeathRow:
	call Play_Pl_AddToJoyBufKeysLH
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .initDash
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .hitA0
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .hitA1
	
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .initDash
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .hitB0
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .hitB1
	
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .initDash
	cp   $07*OBJLSTPTR_ENTRYSIZE
	jp   z, .hitC0
	cp   $08*OBJLSTPTR_ENTRYSIZE
	jp   z, .hitC1
	
	cp   $09*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEndEarly
	cp   $0A*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim ; We never get here
; --------------- frame #0 ---------------
.initDash:
	mMvC_ValFrameStart .initDash_cont
		mMvC_PlaySound SFX_FIREHIT_A
		call Play_Pl_ClearJoyDirBuffer
		call Play_Pl_ClearJoyBufKeysLH
		; Initialize this
		ld   hl, iPlInfo_Mature_DeathRow_Repeat
		add  hl, bc
		ld   [hl], $00
		; Set speed depending on move strength
		mMvIn_ChkLHE .initDash_setDashH, .initDash_setDashE
	.initDash_setDashL: ; Light
		mMvC_SetSpeedH $0300
		jp   .initDash_cont
	.initDash_setDashH: ; Heavy
		mMvC_SetSpeedH $0400
		jp   .initDash_cont
	.initDash_setDashE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH $0500
.initDash_cont:
	call .chkRepeatInput
	mMvC_DoFrictionH $0040
	jp   .anim
; --------------- frame #1 ---------------
.hitA0:
	mMvC_SetDamage $03, HITTYPE_HIT_MID0, PF3_LASTHIT|PF3_LIGHTHIT
	jp   .hit0_main
; --------------- frame #4 ---------------
.hitB0:
	mMvC_SetDamage $03, HITTYPE_HIT_MID1, PF3_LASTHIT|PF3_LIGHTHIT
	jp   .hit0_main
; --------------- frame #7 ---------------
.hitC0:
	mMvC_SetDamage $03, HITTYPE_DROP_MAIN, PF3_LASTHIT|PF3_LIGHTHIT
	jp   .hit0_main
; --------------- frame #1,4,7 / input repeat check ---------------
.hit0_main:
	call .chkRepeatInput
	; Move forward as always, slowing down
	mMvC_DoFrictionH $0040
	jp   .anim
	
; --------------- frame #2 ---------------
.hitA1:
	mMvC_SetDamage $01, HITTYPE_HIT_MID0, PF3_LIGHTHIT
	jp   .hit1_main
; --------------- frame #5 ---------------
.hitB1:
	mMvC_SetDamage $01, HITTYPE_HIT_MID1, PF3_LIGHTHIT
	jp   .hit1_main
; --------------- frame #8 ---------------
.hitC1:
	mMvC_SetDamage $01, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_LIGHTHIT
	jp   .hit1_main
; --------------- frame #2,5,8 / repeat done check ---------------	
.hit1_main:
	mMvC_DoFrictionH $0040
	IF FIX_BUGS == 1
		mMvC_ValFrameEnd .anim
	ELSE
		mMvC_ValFrameEnd MoveC_Mature_MetalMassacre.anim
	ENDC
		; If the move is allowed to continue animating to the next frame, it will "repeat". 
		; To do so, we must have performed the same DB+P input before this point.
		call .canMoveRepeat
		jp   nz, .anim
		
		; Depending on the visible frame...
		ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
		add  hl, de
		ld   a, [hl]
		cp   $06*OBJLSTPTR_ENTRYSIZE	; FrameId < $06?
		jp   c, .hit1_earlyAbort		; If so, jump
	.hit1_fullDone:
		mMvC_SetFrame $09*OBJLSTPTR_ENTRYSIZE, $0A
		jp   .ret
	.hit1_earlyAbort:
		mMvC_SetFrame $0A*OBJLSTPTR_ENTRYSIZE, $0A
		jp   .ret
	
; =============== .chkRepeatInput ===============
; Perform the input check to repeat the move, same as the one to get into MoveInit_Mature_DeathRow.
; DB+P -> Despair
.chkRepeatInput:
	; Return if the motion was done already
	ld   hl, iPlInfo_Mature_DeathRow_Repeat
	add  hl, bc
	bit  0, [hl]	; iPlInfo_Mature_DeathRow_Repeat != 0?
	ret  nz			; If so, return
	
	; Must press the punch button
	call MoveInputS_CheckPKTypeWithJoyBufKeysLH
	ret  nc	; Did we press a punch or kick btn? If not, return
	ret  nz	; Did we press a kick button? If so, return
	
	; Must perform DB motion
	ld   hl, MoveInput_DB
	call MoveInputS_ChkInputDir		; Did we do it?
	ret  nc							; If not, return
	
	; Otherwise, mark that the motion was done
	ld   hl, iPlInfo_Mature_DeathRow_Repeat
	add  hl, bc
	set  0, [hl]
	ret
	
; =============== .canMoveRepeat ===============
; Checks if the move can repeat.
; OUT
; - Z flag: If set, the move can't repeat
.canMoveRepeat:

	; The move doesn't repeat more than 3 times.
	; However, this could have just returned NZ since we do want to advance to #9 (see: .hit1_fullDone).
	; By returning Z instead, it needed special logic in .hit1_main to manually set the frame to #9
	; if we got here with the FrameId >= #6.
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $06*OBJLSTPTR_ENTRYSIZE		; FrameId < #6?	
	jp   c, .canMoveRepeat_chkPlType	; If so, jump
	xor  a								; Z flag set (no repeat)
	ret
.canMoveRepeat_chkPlType:
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	bit  PF0B_CPU, [hl]
	jp   z, .canMoveRepeat_human
.canMoveRepeat_cpu:
	; The CPU randomly chooses if to repeat the move or not.
	ld   a, [wTimer]
	bit  4, a			; CanRepeat = (wTimer & $10) != 0
	ret
.canMoveRepeat_human:
	; iPlInfo_Mature_DeathRow_Repeat must be set for the move to repeat.
	; See .chkRepeatInput
	ld   hl, iPlInfo_Mature_DeathRow_Repeat
	add  hl, bc
	bit  0, [hl]
	ret
; =============== end of move repeat checks ===============	

; --------------- frame #9 ---------------
.chkEndEarly:
	mMvC_DoFrictionH $0040
	mMvC_ValFrameEnd .anim
		jp   .end
; --------------- frame #A ---------------
.chkEnd:
	mMvC_DoFrictionH $0040
	mMvC_ValFrameEnd .anim
; --------------- common ---------------
.end:
	call Play_Pl_EndMove
	jp   .ret
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Mature_Despair ===============
; Move code for Mature's Despair (MOVE_MATURE_DESPAIR_L, MOVE_MATURE_DESPAIR_H).
MoveC_Mature_Despair:
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
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim
; --------------- frame #0 ---------------
; Startup.
.obj0:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		jp   .anim
; --------------- frame #1 ---------------	
; Jump setup.
.obj1:
	mMvC_ValFrameStart .obj1_cont
		mMvC_PlaySound SCT_MOVEJUMP_B
		mMvIn_ChkLHE .obj1_setJumpH, .obj1_setJumpE
	.obj1_setJumpL: ; Light
		mMvC_SetSpeedH +$0300
		mMvC_SetSpeedV -$0400
		jp   .obj1_doGravity
	.obj1_setJumpH: ; Heavy
		mMvC_SetSpeedH +$0400
		mMvC_SetSpeedV -$0480
		jp   .obj1_doGravity
	.obj1_setJumpE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH +$0580
		mMvC_SetSpeedV -$0400
	.obj1_doGravity:
		jp   .doGravity
.obj1_cont:
	; Immediate change, as the Y Speed will always be > -$06
	mMvC_NextFrameOnGtYSpeed -$06, ANIMSPEED_NONE
	jp   nc, .doGravity
	jp   .doGravity
; --------------- frame #2 ---------------	
; Jump, until the near peak of the jump.
.obj2:
	; [POI] The hidden heavy version deals multiple continuous hits.
	call MoveInputS_CheckMoveLHVer	; Is the the hidden heavy triggered?
	jp   nc, .obj2_waitNext			; If not, jump
.obj2_doDamageE:
	mMvC_SetDamage $02, HITTYPE_HIT_MID0, PF3_LASTHIT|PF3_LIGHTHIT
.obj2_waitNext:
	mMvC_NextFrameOnGtYSpeed -$01, ANIMSPEED_NONE
	jp   nc, .doGravity
	jp   .doGravity
; --------------- frame #1-3 / common gravity check ---------------
; Switches to #4 when touching the ground.
.doGravity:
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $04*OBJLSTPTR_ENTRYSIZE, $02
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
	
; =============== MoveC_Mature_HeavensGate ===============
; Move code for Mature's Heaven's Gate (MOVE_MATURE_HEAVENS_GATE_S, MOVE_MATURE_HEAVENS_GATE_D).
MoveC_Mature_HeavensGate:
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
; Startup.
.obj0:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $04
		jp   .anim
; --------------- frame #1 ---------------
; Initial run towards opponent.
.obj1:
	;--
	; Manual check for some reason instead of using mMvC_ValFrameStart
	ld   hl, iOBJInfo_Status
	add  hl, de
	bit  OSTB_GFXNEWLOAD, [hl]
	jp   z, .obj2
	;--
		mMvC_PlaySound SCT_MOVEJUMP_A
		; Set different movement speed depending on
		mMvIn_ChkLHE .obj1_setDashH, .obj1_setDashE
	.obj1_setDashL: ; Light
		mMvC_SetSpeedH $0500
		jp   .obj2
	.obj1_setDashH: ; Heavy
		mMvC_SetSpeedH $0600
		jp   .obj2
	.obj1_setDashE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH $0700
; --------------- frame #1-2 ---------------
; Initial run towards opponent.
.obj2:

	call .chkOtherHit
	jp   c, .ret				; Is the grab confirmed? If so, wait
	jp   z, .switchToBackHop	; Did the opponent block? If so, end it early and backhop away
	; Otherwise, continue moving
	jp   .moveH
; --------------- frame #3 ---------------
; Initial run towards opponent.
.obj3:
	call .chkOtherHit
	jp   c, .ret				; Is the grab confirmed? If so, wait
	jp   z, .switchToBackHop	; Did the opponent block? If so, end it early and backhop away
	
	; Otherwise, continue moving.
	; If by the end of the frame, we didn't confirm the grab (which switches to #4),
	; switch to #6 where the move will end.
	mMvC_ValFrameEnd .moveH
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		; Switch to the last frame (#6) to end the move if the C flag didn't get set by the end
		ld   hl, iOBJInfo_OBJLstPtrTblOffset
		add  hl, de
		ld   [hl], $05*OBJLSTPTR_ENTRYSIZE	; offset by -1
		jp   .moveH
		
; =============== .chkOtherHit ===============
; Checks if the opponent was successfully hit.
; See also: Play_Pl_IsMoveHit
; OUT
; - C flag: If set, the move hit successfully
; - Z flag: If set, the move got blocked
.chkOtherHit:

IF OPTIMIZE == 0
	;
	; If we didn't hit the opponent yet, return without doing anything.
	; 
	ld   hl, iPlInfo_ColiFlags
	add  hl, bc
	bit  PCF_HITOTHER, [hl]				; Did we reach?
	jp   z, .chkOtherHit_wait			; If not, skip
	ld   hl, iPlInfo_Flags1Other
	add  hl, bc
	bit  PF1B_INVULN, [hl]				; Is the opponent invulnerable?
	jp   nz, .chkOtherHit_wait			; If so, skip
	bit  PF1B_HITRECV, [hl]				; Did the opponent get hit?
	jp   z, .chkOtherHit_wait			; If not, skip	
	;
	; If the hit is blocked, skip directly to the end of the move,
	; where the player backhops away.
	;	
	bit  PF1B_GUARD, [hl]				; Is the opponent blocking?
	jp   nz, .chkOtherHit_blocked		; If so, jump
ELSE
	; Identical check, but calling the copy in BANK 0 to save space.
	mMvC_ValHit .chkOtherHit_wait, .chkOtherHit_blocked
ENDC
	.chkOtherHit_ok:
		;
		; The hit wasn't blocked, so switch to #4 to continue the attack.
		;
		mMvC_SetFrame $04*OBJLSTPTR_ENTRYSIZE, ANIMSPEED_NONE
		ld   a, PLAY_THROWACT_NEXT03
		ld   [wPlayPlThrowActId], a
		mMvC_SetDamageNext $01, HITTYPE_THROW_ROTU, PF3_HEAVYHIT
		mMvC_SetDamage $01, HITTYPE_THROW_ROTU, PF3_HEAVYHIT
		mMvC_MoveThrowOp -$08, +$00 ; Move back 8px
		mMvC_MoveThrowOpSync
		call OBJLstS_ApplyXSpeed
		scf			; C flag set
		ret
.chkOtherHit_blocked:
	xor  a		; Z flag set
	ret
.chkOtherHit_wait:
	ld   a, $01
	or   a		; Z flag clear
	ret
; =============== end of .chkOtherHit ===============			
	
; --------------- frame #4 ---------------	
; Runs forward holding the opponent until reaching the edge of the stage.
.obj4:

	;
	; If the opponent isn't in the intended HITTYPE_THROW_ROTU after 8 frames,
	; assume that something went wrong and hop back, ending the move.
	;
	
	;--
	ld   hl, iOBJInfo_Status
	add  hl, de
	bit  OSTB_GFXNEWLOAD, [hl]	; First time we get here?
	jp   nz, .obj4_chkEdge		; If so, skip (not needed, see below)
	;--
	
		; Skip the HITTYPE check for the first 8 frames.
		; We can do it this way since we know the initial value iOBJInfo_FrameLeft is set to,
		; and that decrements every frame.
		ld   hl, iOBJInfo_FrameLeft
		add  hl, de
		ld   a, [hl]
		cp   ANIMSPEED_NONE-$07		; iOBJInfo_FrameLeft >= $F8?
		jp   nc, .obj4_chkEdge		; If so, skip
		
		ld   hl, iPlInfo_HitTypeIdOther
		add  hl, bc
		ld   a, [hl]
		cp   HITTYPE_THROW_ROTU		; Opponent's HitType != HITTYPE_THROW_ROTU?
		jp   nz, .switchToBackHop	; If so, jump
.obj4_chkEdge:
	; Continuously spawn visual effects for the desperation versions
	call ProjInit_Mature_HeavensGateD
	
	;
	; Continue moving until either we or the opponent get near the edge of the stage.
	; When that happens, switch to #5 and spawn the skull projectile.
	;
	ld   hl, iPlInfo_OBJInfoXOther
	add  hl, bc
	ld   a, [hl]
	cp   $00+PLAY_BORDER_X		; Opponent on the left edge?	
	jp   z, .obj4_setDamage		; If so, jump
	cp   $100-PLAY_BORDER_X		; Opponent on the right edge?	
	jp   z, .obj4_setDamage		; If so, jump
	ld   hl, iOBJInfo_X
	add  hl, de
	ld   a, [hl]
	cp   $00+PLAY_BORDER_X		; Are we on the left edge?	
	jp   z, .obj4_setDamage		; If so, jump
	cp   $100-PLAY_BORDER_X		; Are we on the right edge?
	jp   z, .obj4_setDamage		; If so, jump
	; Otherwise, continue moving
	jp   .moveH
.obj4_setDamage:
	;
	; Switch to #5 and setup the damage dealt by the move.
	;
	mMvC_SetFrame $05*OBJLSTPTR_ENTRYSIZE, $08
	ld   hl, iPlInfo_MoveId
	add  hl, bc
	ld   a, [hl]
	cp   MOVE_MATURE_HEAVENS_GATE_D		; Using the desperation version?
	jp   z, .obj4_setDamageD			; If so, jump
.obj4_setDamageS:
	; This deals more damage since the projectile itself *doesn't*
	mMvC_SetDamageNext $14, HITTYPE_DROP_MAIN, PF3_HEAVYHIT
	jp   .ret
.obj4_setDamageD:
	; While the super desperation version does deal continuous damage, so the physical hit deals a bit less
	mMvC_SetDamageNext $0C, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_LASTHIT
	jp   .ret
	
; --------------- frame #5 ---------------
; Initial back movement and projectile setup.
; Last frame if everything went right.	
.obj5:
	; Set speed to dash backwards the first time we get here
	mMvC_ValFrameStart .obj5_cont
		mMvC_SetMoveH -$0700
.obj5_cont:
	mMvC_ValFrameEnd .anim
	
		; Initialize the projectile at the end of the frame.
		; They are essentially the same between super and desperation versions, other than the damage dealt.
		ld   hl, iPlInfo_MoveId
		add  hl, bc
		ld   a, [hl]
		cp   MOVE_MATURE_HEAVENS_GATE_D		; Using the desperation version?
		jp   z, .obj5_setProjDamageD		; If so, jump
	.obj5_setProjDamageS:
		; Super version deals no damage
		mkhl $00, HITTYPE_DROP_SWOOPUP
		ld   hl, CHL
		ld   a, PF3_HEAVYHIT
		jp   .obj5_initProj
	.obj5_setProjDamageD:
		; Desperation version deals 1 line of continuous damage
		mkhl $01, HITTYPE_DROP_SWOOPUP
		ld   hl, CHL
		ld   a, PF3_HEAVYHIT
	.obj5_initProj:
		; Set damage settings
		call Play_Pl_SetMoveDamageNext
		; Copy them over to the projectile
		call Play_Proj_CopyMoveDamageFromPl
		; And spawn said projectile
		call ProjInit_Mature_HeavensGateS
		; Finally, backhop and end the move.
		
; --------------- common backhop switch ---------------
; Switches to the backwards hop.
.switchToBackHop:
	ld   a, MOVE_SHARED_HOP_B
	call Pl_SetMove_StopSpeed
	ld   a, PLAY_THROWACT_NONE
	ld   [wPlayPlThrowActId], a
	jp   .ret
; --------------- common horizontal movement ---------------
.moveH:
	call OBJLstS_ApplyXSpeed
	jp   .anim
; --------------- frame #6 ---------------
; Slow down, and when we stop moving end the move.
; We get here only if the opponent wasn't hit.
.chkEnd:
	;--
	; It's a bit pointless to check this here.
	call .chkOtherHit			; Check this again
	jp   c, .ret				; Is the grab confirmed? If so, wait
	jp   z, .switchToBackHop	; Did the opponent block? If so, backhop away
	;--
	mMvC_DoFrictionH $0080
	jp   nc, .anim
		mMvC_EndThrow_Slow
		jr   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== ProjInit_Mature_HeavensGateS ===============
; Initializes the projectile for Mature's Heaven's Gate (normal).
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
ProjInit_Mature_HeavensGateS:
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
				ld   [hl], BANK(ProjC_NoMove)	; BANK $05 ; iOBJInfo_Play_CodeBank
				inc  hl
				ld   [hl], LOW(ProjC_NoMove)	; iOBJInfo_Play_CodePtr_Low
				inc  hl
				ld   [hl], HIGH(ProjC_NoMove)	; iOBJInfo_Play_CodePtr_High
				
				; Write sprite mapping ptr for this projectile.
				ld   hl, iOBJInfo_BankNum
				add  hl, de
				ld   [hl], BANK(OBJLstPtrTable_Proj_Mature_HeavensGateS)	; BANK $01 ; iOBJInfo_BankNum
				inc  hl
				ld   [hl], LOW(OBJLstPtrTable_Proj_Mature_HeavensGateS)		; iOBJInfo_OBJLstPtrTbl_Low
				inc  hl
				ld   [hl], HIGH(OBJLstPtrTable_Proj_Mature_HeavensGateS)	; iOBJInfo_OBJLstPtrTbl_High
				inc  hl
				ld   [hl], $00	; iOBJInfo_OBJLstPtrTblOffset

				; Set animation speed.
				ld   hl, iOBJInfo_FrameLeft
				add  hl, de
				ld   [hl], $01	; iOBJInfo_FrameLeft
				inc  hl
				ld   [hl], $01	; iOBJInfo_FrameTotal
				
				; Set priority value
				ld   hl, iOBJInfo_Play_Priority
				add  hl, de
				ld   [hl], PROJ_PRIORITY_NODESPAWN
				inc  hl
			pop  af
			
			; Set despawn timer
			ld   [hl], $32 ; iOBJInfo_Play_EnaTimer
			
			; Set initial position relative to the player's origin
			call OBJLstS_Overlap
			mMvC_SetMoveH +$0000
			mMvC_SetMoveV +$0000
		pop  de
	pop  bc
	ret
	
; =============== ProjInit_Mature_HeavensGateD ===============
; Initializes the special effect for Mature's Heaven's Gate (desperation).
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
ProjInit_Mature_HeavensGateD:
	
	; Only for the desperation version.
	ld   hl, iPlInfo_MoveId
	add  hl, bc
	ld   a, [hl]
	cp   MOVE_MATURE_HEAVENS_GATE_D
	ret  nz
	
	; Only if another projectile isn't already visible
	ld   hl, (OBJINFO_SIZE*2)+iOBJInfo_Status
	add  hl, de
	bit  OSTB_VISIBLE, [hl]
	ret  nz
	
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
				ld   [hl], BANK(ProjC_NoMove)	; BANK $05 ; iOBJInfo_Play_CodeBank
				inc  hl
				ld   [hl], LOW(ProjC_NoMove)	; iOBJInfo_Play_CodePtr_Low
				inc  hl
				ld   [hl], HIGH(ProjC_NoMove)	; iOBJInfo_Play_CodePtr_High
				
				; Write sprite mapping ptr for this projectile.
				ld   hl, iOBJInfo_BankNum
				add  hl, de
				ld   [hl], BANK(OBJLstPtrTable_Proj_Mature_HeavensGateD)	; BANK $01 ; iOBJInfo_BankNum
				inc  hl
				ld   [hl], LOW(OBJLstPtrTable_Proj_Mature_HeavensGateD)		; iOBJInfo_OBJLstPtrTbl_Low
				inc  hl
				ld   [hl], HIGH(OBJLstPtrTable_Proj_Mature_HeavensGateD)	; iOBJInfo_OBJLstPtrTbl_High
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
				ld   [hl], PROJ_PRIORITY_NODESPAWN
				inc  hl
			pop  af
			
			; Set despawn timer
			ld   [hl], $05 ; iOBJInfo_Play_EnaTimer
			
			; Set initial position relative to the player's origin
			call OBJLstS_Overlap
			mMvC_SetMoveH +$0000
			mMvC_SetMoveV +$0000
		pop  de
	pop  bc
	ret
	
; =============== ProjC_NoMove ===============
; Generic projectile code for those that don't move and *only* despawn after a certain amount of time.
; Getting hit by this won't make it disappear, so if it's set to deal damage it will deal it continuously.
ProjC_NoMove:
	; Handle despawn timer.
	ld   hl, iOBJInfo_Play_EnaTimer
	add  hl, de
	dec  [hl]
	jp   z, .despawn
	; Ok, display
	call OBJLstS_DoAnimTiming_Loop_by_DE
	ret
.despawn:
	call OBJLstS_Hide
	ret
	
; =============== MoveInputReader_Chizuru ===============
; Special move input checker for CHIZURU.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
; OUT
; - C flag: If set, a move was started
MoveInputReader_Chizuru:
	; Normal Chizuru can't use any specials if one of her projectiles is active on-screen.
	; This doesn't apply to the boss version "KAGURA".
	mMvIn_ValProjActive MoveInputReader_Chizuru_NoMove
; =============== MoveInputReader_Kagura ===============
MoveInputReader_Kagura:
	mMvIn_Validate Chizuru
	
.chkAir:
	jp   MoveInputReader_Chizuru_NoMove
	
.chkGround:
	;             SELECT + B                     SELECT + A
	mMvIn_ChkEasy MoveInit_Chizuru_ReigiIshizue, MoveInit_Chizuru_TenjinKotowari
	mMvIn_ChkGA Chizuru, .chkPunch, .chkKick
.chkPunch:
	; DBDF+P -> Ichimen Ikatsu San Rai no Fui Jin 
	mMvIn_ValSuper .chkPunchNoSuper
	mMvIn_ChkDir MoveInput_DBDF, MoveInit_Chizuru_SanRaiFuiJin
.chkPunchNoSuper:
	; FDF+P -> 100 Katso Tenjin no Kotowari 
	mMvIn_ChkDir MoveInput_FDF, MoveInit_Chizuru_TenjinKotowari
	; FDB+P -> 212 Katsu Shinsoku no Noroti (High)
	mMvIn_ChkDir MoveInput_FDB, MoveInit_Chizuru_ShinsokuNorotiHigh
	; BDF+P -> 108 Katsu Tamayura no Shitsune
	mMvIn_ChkDir MoveInput_BDF, MoveInit_Chizuru_TamayuraShitsune
	jp   MoveInputReader_Chizuru_NoMove
.chkKick:
	; DBDB+K -> Ichimen 85 Katsu Reigi no Ishizue 
	mMvIn_ValProjActive .chkKickNoSuper
	mMvIn_ValSuper .chkKickNoSuper
	mMvIn_ChkDir MoveInput_DBDB, MoveInit_Chizuru_ReigiIshizue 
.chkKickNoSuper:
	; FDB+K -> 212 Katsu Shinsoku no Noroti (Low)
	mMvIn_ChkDir MoveInput_FDB, MoveInit_Chizuru_ShinsokuNorotiLow
	jp   MoveInputReader_Chizuru_NoMove
	
; =============== MoveInit_Chizuru_TenjinKotowari ===============
MoveInit_Chizuru_TenjinKotowari:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_CHIZURU_TENJIN_KOTOWARI_L, MOVE_CHIZURU_TENJIN_KOTOWARI_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Chizuru_SetMove
; =============== MoveInit_Chizuru_ShinsokuNorotiHigh ===============
MoveInit_Chizuru_ShinsokuNorotiHigh:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_CHIZURU_SHINSOKU_NOROTI_HIGH_L, MOVE_CHIZURU_SHINSOKU_NOROTI_HIGH_H
	call MoveInputS_SetSpecMove_StopSpeed
	; When playing as the boss version, the move has no collision box (can be thrown but not hit)
	mMvIn_ValSkipWithChar CHAR_ID_CHIZURU, MoveInputReader_Chizuru_SetMove
	ld   hl, iPlInfo_Flags2
	add  hl, bc
	set  PF2B_NOCOLIBOX, [hl]
	jp   MoveInputReader_Chizuru_SetMove
; =============== MoveInit_Chizuru_ShinsokuNorotiLow ===============
MoveInit_Chizuru_ShinsokuNorotiLow:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_CHIZURU_SHINSOKU_NOROTI_LOW_L, MOVE_CHIZURU_SHINSOKU_NOROTI_LOW_H
	call MoveInputS_SetSpecMove_StopSpeed
	; When playing as the boss version, the move has no collision box (can be thrown but not hit)
	mMvIn_ValSkipWithChar CHAR_ID_CHIZURU, MoveInputReader_Chizuru_SetMove
	ld   hl, iPlInfo_Flags2
	add  hl, bc
	set  PF2B_NOCOLIBOX, [hl]
	jp   MoveInputReader_Chizuru_SetMove
; =============== MoveInit_Chizuru_TamayuraShitsune ===============
MoveInit_Chizuru_TamayuraShitsune:
	call Play_Pl_ClearJoyDirBuffer
	; The heavy version is also invulnerable
	call MoveInputS_CheckMoveLHVer
	jr   nz, .heavy
.light:
	ld   a, MOVE_CHIZURU_TAMAYURA_SHITSUNE_L
	call MoveInputS_SetSpecMove_StopSpeed
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	set  PF0B_PROJREFLECT, [hl]
	jp   MoveInputReader_Chizuru_SetMove
.heavy:
	ld   a, MOVE_CHIZURU_TAMAYURA_SHITSUNE_H
	call MoveInputS_SetSpecMove_StopSpeed
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	set  PF0B_PROJREFLECT, [hl]
	inc  hl
	set  PF1B_INVULN, [hl]
	jp   MoveInputReader_Chizuru_SetMove
	
; =============== MoveInit_Chizuru_SanRaiFuiJin ===============
; This is the super move that restricts use of specials for a short while.
MoveInit_Chizuru_SanRaiFuiJin:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetSD MOVE_CHIZURU_SAN_RAI_FUI_JIN_S, MOVE_CHIZURU_SAN_RAI_FUI_JIN_D
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Chizuru_SetMove
; =============== MoveInit_Chizuru_ReigiIshizue ===============
MoveInit_Chizuru_ReigiIshizue:
	mMvIn_ValProjActive Chizuru
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetSD MOVE_CHIZURU_REIGI_ISHIZUE_S, MOVE_CHIZURU_REIGI_ISHIZUE_D
	call MoveInputS_SetSpecMove_StopSpeed
	call Play_Proj_CopyMoveDamageFromPl
	jp   MoveInputReader_Chizuru_SetMove
; =============== MoveInputReader_Chizuru_SetMove ===============
MoveInputReader_Chizuru_SetMove:
	scf
	ret
; =============== MoveInputReader_Chizuru_NoMove ===============
MoveInputReader_Chizuru_NoMove:
	or   a
	ret
	
; =============== MoveC_Chizuru_ShinsokuNoroti ===============
; Move code for Chizuru's 212 Katsu Shinsoku no Noroti:
; - MOVE_CHIZURU_SHINSOKU_NOROTI_HIGH_L
; - MOVE_CHIZURU_SHINSOKU_NOROTI_HIGH_H
; - MOVE_CHIZURU_SHINSOKU_NOROTI_LOW_L
; - MOVE_CHIZURU_SHINSOKU_NOROTI_LOW_H
; This move can chain into 212 Katsu Shinsoku no Noroti Ten Zui (MOVE_CHIZURU_TEN_ZUI_L, MOVE_CHIZURU_TEN_ZUI_H)
MoveC_Chizuru_ShinsokuNoroti:
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
	jp   z, .obj3
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj4
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
; --------------- frame #0 ---------------
; Forward run.
.obj0:
	mMvC_ValFrameStart .obj0_cont
		call Play_Pl_ClearJoyBufKeysLH
		ld   hl, iPlInfo_Chizuru_ShinsokuNoroti_ChainedMove
		add  hl, bc
		ld   [hl], $00
		mMvIn_ChkLHE .obj0_setDashH, .obj0_setDashE
	.obj0_setDashL: ; Light
		mMvC_SetSpeedH +$0500
		jp   .obj0_cont
	.obj0_setDashH: ; Heavy
		mMvC_SetSpeedH +$0600
		jp   .obj0_cont
	.obj0_setDashE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH +$0700
.obj0_cont:
	; Skip the first part and switch to #3 directly if starting a chained move
	call .chkCM
	jp   z, .moveH
		mMvC_SetFrame $03*OBJLSTPTR_ENTRYSIZE, ANIMSPEED_INSTANT
		call OBJLstS_ApplyXSpeed
		jp   .ret
; --------------- frame #1 ---------------
; Forward run.
.obj1:
	; Skip the first part and switch to #3 directly if starting a chained move
	call .chkCM
	jp   z, .obj1_main
		mMvC_SetFrame $03*OBJLSTPTR_ENTRYSIZE, ANIMSPEED_INSTANT
		call OBJLstS_ApplyXSpeed
		jp   .ret
.obj1_main:
	; Play step SFX at the start of the frame
	mMvC_ValFrameStart .moveH
		mMvC_PlaySound SFX_STEP
		jp   .moveH
; --------------- frame #2 ---------------
; Forward run.
.obj2:
	; Skip the first part and switch to #3 directly if starting a chained move
	call .chkCM
	jp   z, .obj2_main
		mMvC_SetFrame $03*OBJLSTPTR_ENTRYSIZE, ANIMSPEED_INSTANT
		call OBJLstS_ApplyXSpeed
		jp   .ret
.obj2_main:
	mMvC_ValFrameStart .obj2_cont
		mMvC_PlaySound SFX_STEP
.obj2_cont:
	mMvC_ValFrameEnd .moveH
		mMvC_SetAnimSpeed ANIMSPEED_INSTANT
		jp   .moveH
	
; =============== .chkCM ===============
; Checks the input for starting a chained move, and updates the bitmask
; marking which move to chain into.
; OUT
; - Z flag: If set, no move was started
.chkCM:
	; Don't check this again if we already started a move.
	; The return value of NZ works for us.
	call .isCMSet
	ret  nz
	
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	bit  PF0B_CPU, [hl]				; Is this a CPU player?
	jp   z, .chkCm_chkInputHuman	; If not, jump
.chkCm_cpu:
	; The CPU randomly decides which move to chain into.
	
	; This uses the upper nybble of the timer, giving a $10 frame window where the
	; CPU may not chain into anything. It's much less likely than chaining though.
	; ChainedMove = (wTimer / $10) & $03
	ld   a, [wTimer]
	swap a
	and  a, $03
	ld   hl, iPlInfo_Chizuru_ShinsokuNoroti_ChainedMove
	add  hl, bc
	ld   [hl], a
	or   a			; Return ZFlag = ChainedMove == 0
	ret
.chkCm_chkInputHuman:
	; Human players need to perform the input DB+P/K to start 212 Katsu Shinsoku no Noroti Ten Zui.
	; Depending on the button pressed, start the light or hard versions.
	call MoveInputS_CheckPKTypeWithJoyBufKeysLH
	jp   nc, .chkCm_retZ		; Pressed any punch/kick button? If not, jump
	jp   nz, .chkCm_chkTenZuiH	; Pressed the kick button? If so start the hard version
.chkCm_chkTenZuiL:				; Otherwise, start the light one
	mMvIn_ChkDirNot MoveInput_DB, .chkCm_retZ
		; Input done
		call Play_Pl_ClearJoyDirBuffer
		; Flag that we're starting the move
		ld   hl, iPlInfo_Chizuru_ShinsokuNoroti_ChainedMove
		add  hl, bc
		set  PCMB_CHIZURU_TEN_ZUI_L, [hl]
		ret
.chkCm_chkTenZuiH:
	mMvIn_ChkDirNot MoveInput_DB, .chkCm_retZ
		; Input done
		call Play_Pl_ClearJoyDirBuffer
		; Flag that we're starting the move
		ld   hl, iPlInfo_Chizuru_ShinsokuNoroti_ChainedMove
		add  hl, bc
		set  PCMB_CHIZURU_TEN_ZUI_H, [hl]
		ret
.chkCm_retZ:
	xor  a	; Z flag set. Nothing started.
	ret
; =============== .isCMSet ===============
; Checks if a chained move was already started.
; OUT
; - A: iPlInfo_Chizuru_ShinsokuNoroti_ChainedMove
; - Z flag: If set, no move is started yet
.isCMSet:
	ld   hl, iPlInfo_Chizuru_ShinsokuNoroti_ChainedMove
	add  hl, bc
	ld   a, [hl]	; A = ChainedMoveMask
	or   a			; A != 0?
	ret
; =============== end of .chkCM ===============
	
; --------------- frame #3 ---------------
; Progressive slow down.
.obj3:
	mMvC_ValFrameStart .obj3_cont
		mMvC_PlaySound SCT_HEAVY
.obj3_cont:
	call .chkCM
	mMvC_DoFrictionH $0080
	jp   .anim
; --------------- frame #4 ---------------
; Progressive slow down + chained move start.
.obj4:
	call .chkCM
	mMvC_DoFrictionH $0080
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $14
		
		call .isCMSet					; A = ChainedMove
		jp   z, .anim					; A == 0? If so, skip
		bit  PCMB_CHIZURU_TEN_ZUI_L, a	; Light ver set?
		jp   nz, .switchToTenZuiL		; If so, jump
		bit  PCMB_CHIZURU_TEN_ZUI_H, a	; Hard ver set?
		jp   nz, .switchToTenZuiH		; If so, jump
		jp   .anim
	.switchToTenZuiL:
		ld   a, MOVE_CHIZURU_TEN_ZUI_L
		call MoveInputS_SetSpecMove_StopSpeed
		mMvC_SetDamageNext $02, HITTYPE_DROP_MAIN, PF3_HEAVYHIT
		jp   .ret
	.switchToTenZuiH:
		ld   a, MOVE_CHIZURU_TEN_ZUI_H
		call MoveInputS_SetSpecMove_StopSpeed
		mMvC_SetDamageNext $02, HITTYPE_DROP_DB_A, PF3_HEAVYHIT
		jp   .ret
; --------------- frame #5 ---------------
; Slow down. When the frame ends, the move ends.
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
	
; =============== MoveC_Chizuru_TenZuiL ===============
; Move code for the light version of Chizuru's 212 Katsu Shinsoku no Noroti Ten Zui (MOVE_CHIZURU_TEN_ZUI_L).
MoveC_Chizuru_TenZuiL:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj0
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .doGravity
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim ; We never get here
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameStart .obj0_cont
		mMvIn_ChkE .obj0_setJumpE
	.obj0_setJumpLH: ; Light / Heavy
		mMvC_SetSpeedH +$0100
		mMvC_SetSpeedV -$0400
		jp   .doGravity
	.obj0_setJumpE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH +$0200
		mMvC_SetSpeedV -$0400
		jp   .doGravity
.obj0_cont:
	mMvC_NextFrameOnGtYSpeed -$02, ANIMSPEED_NONE
	jp   nc, .doGravity
	jp   .doGravity
; --------------- frame #0-1 / common gravity check ---------------
.doGravity:
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $02*OBJLSTPTR_ENTRYSIZE, $05
		jp   .ret
; --------------- frame #2 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Chizuru_TenZuiH ===============
; Move code for the hard version of Chizuru's 212 Katsu Shinsoku no Noroti Ten Zui (MOVE_CHIZURU_TEN_ZUI_H).
MoveC_Chizuru_TenZuiH:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj2
	jp   .anim
; --------------- frame #2 ---------------
.obj2:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Chizuru_TamayuraShitsuneL ===============
; Move code for the light version of Chizuru's 108 Katsu Tamayura no Shitsune (MOVE_CHIZURU_TAMAYURA_SHITSUNE_L).	
MoveC_Chizuru_TamayuraShitsuneL:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj4
	jp   .anim
; --------------- [TCRF] Unreferenced frame code ---------------
; Would have played the attack SFX, likely somewhere between #0 and #3.
.unused0:
	mMvC_ValFrameStart .unused0_cont
		mMvC_PlaySound SCT_MOVEJUMP_A
.unused0_cont:
	jp   .anim
; --------------- frame #4 ---------------
.obj4:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Chizuru_TamayuraShitsuneH ===============
; Move code for the hard version of Chizuru's 108 Katsu Tamayura no Shitsune (MOVE_CHIZURU_TAMAYURA_SHITSUNE_H).
MoveC_Chizuru_TamayuraShitsuneH:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj0
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .moveH_stub
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .moveH_stub
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj3
	cp   $08*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameStart .moveH_stub
		mMvC_PlaySound SCT_HEAVY
		mMvIn_ChkE .obj0_setDashE
	.obj0_setDashLH: ; Light / Heavy
		mMvC_SetSpeedH $0080
		jp   .moveH_stub
	.obj0_setDashE:  ; [POI] Hidden Heavy
		mMvC_SetSpeedH $0100
		jp   .moveH_stub
; --------------- frame #0-2 ---------------
.moveH_stub:
	jp   .moveH
; --------------- frame #3 ---------------
.obj3:
	mMvC_ValFrameEnd .moveH
		ld   hl, iPlInfo_Flags1
		add  hl, bc
		res  PF1B_INVULN, [hl]
		mMvC_PlaySound SCT_MOVEJUMP_A
		jp   .anim
; --------------- common horz movement ---------------
.moveH:
	call OBJLstS_ApplyXSpeed
	jp   .anim
; --------------- frame #8 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Chizuru_SanRaiFuiJin ===============
; Move code for Chizuru's Ichimen Ikatsu San Rai no Fui Jin (MOVE_CHIZURU_SAN_RAI_FUI_JIN_S, MOVE_CHIZURU_SAN_RAI_FUI_JIN_D).
; This is the move where Chizuru pauses for a bit, then dashes forward.
; If the opponent is hit, he will flash and won't be able to start specials for a while.
MoveC_Chizuru_SanRaiFuiJin:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj3
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj4
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim
; --------------- frame #3 ---------------
.obj3:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $14
		jp   .anim
; --------------- frame #4 ---------------
.obj4:
	mMvC_ValFrameStart .obj4_cont
		mMvC_PlaySound SCT_HEAVY
		;--
		; [TCRF] This is not used elsewhere in this move
		ld   hl, iPlInfo_Chizuru_SanRaiFuiJin_83
		add  hl, bc
		ld   [hl], $00
		;--
		; Set the dash speed depending on move strength
		mMvIn_ChkLHE .obj4_setSpeedH, .obj4_setSpeedE
	.obj4_setSpeedL: ; Light
		mMvC_SetSpeedH $0400
		jp   .obj4_cont
	.obj4_setSpeedH: ; Heavy
		mMvC_SetSpeedH $0500
		jp   .obj4_cont
	.obj4_setSpeedE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH $0600
.obj4_cont:
	mMvC_DoFrictionH $0040
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $0A
		jp   .anim
; --------------- frame #5 ---------------
; Progressively slow down.
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
	
; =============== MoveC_Chizuru_ReijiIshizue ===============
; Move code for Chizuru's Ichimen 85 Katsu Reigi no Ishizue (MOVE_CHIZURU_REIGI_ISHIZUE_S, MOVE_CHIZURU_REIGI_ISHIZUE_D).
; Chizuru Clone projectile.
MoveC_Chizuru_ReijiIshizue:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj0
	jp   .anim ; We never get here
; --------------- frame #0 ---------------	
.obj0:
	; Spawn the projectile when starting the frame
	mMvC_ValFrameStart .chkEnd
		call ProjInit_Chizuru_ReigiIshizue
		mMvC_PlaySound SCT_HEAVY
.chkEnd:
	; End the move when the frame's over
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jp   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== ProjInit_Chizuru_ReigiIshizue ===============
; Initializes the projectile for Chizuru's Ichimen 85 Katsu Reigi no Ishizue.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
ProjInit_Chizuru_ReigiIshizue:
	mMvC_PlaySound SCT_PROJ_LG_B
	
	push bc
		push de
		
			; A = MoveId
			ld   hl, iPlInfo_MoveId
			add  hl, bc
			ld   a, [hl]
			push af	; Save MoveId
				call ProjInitS_InitAndGetOBJInfo
				
				; Set code pointer
				ld   hl, iOBJInfo_Play_CodeBank
				add  hl, de
				ld   [hl], BANK(ProjC_Chizuru_ReigiIshizue)	; BANK $05 ; iOBJInfo_Play_CodeBank
				inc  hl
				ld   [hl], LOW(ProjC_Chizuru_ReigiIshizue)	; iOBJInfo_Play_CodePtr_Low
				inc  hl
				ld   [hl], HIGH(ProjC_Chizuru_ReigiIshizue)	; iOBJInfo_Play_CodePtr_High
				
				; Write sprite mapping ptr for this projectile.
				ld   hl, iOBJInfo_BankNum
				add  hl, de
				ld   [hl], BANK(OBJLstPtrTable_Proj_Chizuru_ReigiIshizue)	; BANK $01 ; iOBJInfo_BankNum
				inc  hl
				ld   [hl], LOW(OBJLstPtrTable_Proj_Chizuru_ReigiIshizue)	; iOBJInfo_OBJLstPtrTbl_Low
				inc  hl
				ld   [hl], HIGH(OBJLstPtrTable_Proj_Chizuru_ReigiIshizue)	; iOBJInfo_OBJLstPtrTbl_High
				inc  hl
				ld   [hl], $00	; iOBJInfo_OBJLstPtrTblOffset
				
				; Set animation speed.
				ld   hl, iOBJInfo_FrameLeft
				add  hl, de
				ld   [hl], $06	; iOBJInfo_FrameLeft
				inc  hl
				ld   [hl], $06	; iOBJInfo_FrameTotal
				
				; Set priority value
				ld   hl, iOBJInfo_Play_Priority
				add  hl, de
				ld   [hl], PROJ_PRIORITY_NODESPAWN
				
				;
				; Determine how long to display it.
				;
				
				inc  hl	; Seek to iOBJInfo_Play_EnaTimer
				
			pop  af ; A = MoveId
			
			cp   MOVE_CHIZURU_REIGI_ISHIZUE_D	; Desperation move?
			jp   z, .timerD						; If so, jump
		.timerS:
			; The normal version has a despawn timer
			ld   [hl], $78
			jp   .setPos
		.timerD:
			; The desperation version doesn't despawn until it goes offscreen
			ld   [hl], $FF
		.setPos:
		
			; Start on top of player, and move forward at $00.80px/frame
			call OBJLstS_Overlap
			mMvC_SetSpeedH +$0080
		pop  de
	pop  bc
	ret
	
; =============== ProjC_Chizuru_ReigiIshizue ===============
; Projectile code for Chizuru's Ichimen 85 Katsu Reigi no Ishizue.
; This projectile is a walking Chizuru clone that deals continuous damage.
ProjC_Chizuru_ReigiIshizue:
	call ExOBJS_Play_ChkHitModeAndMoveH	; Move projectile
	jp   c, .despawn					; Did it go off-screen? If so, despawn
	
	; Projectile despawns on hit
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	bit  PF1B_HITRECV, [hl]				; Did we get hit?
	jp   nz, .despawn					; If so, despawn it
	
	; Decrement despawn timer only if it's not $FF (like the desperation super)
	ld   hl, iOBJInfo_Play_EnaTimer
	add  hl, de
	bit  7, [hl]		; Is the despawn timer $FF? (>= $80)
	jp   nz, .anim		; If so, don't decrement it
	dec  [hl]			; Otherwise, Timer--
	jp   z, .despawn	; Did it reach 0? If so, despawn it
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
	ret
.despawn:
	call OBJLstS_Hide
	ret
	
; =============== MoveInputReader_Daimon ===============
; Special move input checker for DAIMON.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
; OUT
; - C flag: If set, a move was started
MoveInputReader_Daimon:
	mMvIn_Validate Daimon
	
; AIR SPECIALS
.chkAir:
	jp   MoveInputReader_Daimon_NoMove
	
; GROUND SPECIALS
.chkGround:
	;             SELECT + B                      SELECT + A
	mMvIn_ChkEasy MoveInit_Daimon_HeavenHellDrop, MoveInit_Daimon_JiraiShin
	mMvIn_ChkGA Daimon, .chkPunch, .chkKick
	
.chkPunch:
	mMvIn_ValSuper .chkPunchNoSuper
	; FDBx2+P -> Heaven to Hell Drop
	mMvIn_ChkDir MoveInput_FDBFDB, MoveInit_Daimon_HeavenHellDrop
	
.chkPunchNoSuper:
	; FDBF+P -> Heaven Drop
	mMvIn_ChkDir MoveInput_FDBF, MoveInit_Daimon_HeavenDrop
	; FDF+P -> Jirai Shin
	mMvIn_ChkDir MoveInput_FDF, MoveInit_Daimon_JiraiShin
	; BDF+P -> Cloud Tosser / Stump Throw
	mMvIn_ChkDir MoveInput_BDF, MoveInit_Daimon_CloudTosser
	; End
	jp   MoveInputReader_Daimon_NoMove
.chkKick:
	; BDF+K -> Chou Oosoto Gari
	mMvIn_ChkDir MoveInput_BDF, MoveInit_Daimon_ChouOosotoGari
	; DB+K -> Chou Ukemi
	mMvIn_ChkDir MoveInput_DB, MoveInit_Daimon_ChouUkemi
	; End
	jp   MoveInputReader_Daimon_NoMove
	
; =============== MoveInit_Daimon_JiraiShin ===============
MoveInit_Daimon_JiraiShin:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_DAIMON_JIRAI_SHIN, MOVE_DAIMON_JIRAI_SHIN_FAKE
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Daimon_MoveSet
; =============== MoveInit_Daimon_ChouUkemi ===============
MoveInit_Daimon_ChouUkemi:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_DAIMON_CHOU_UKEMI_L, MOVE_DAIMON_CHOU_UKEMI_H
	call MoveInputS_SetSpecMove_StopSpeed
	; Command roll gets invulnerability
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_INVULN, [hl]
	jp   MoveInputReader_Daimon_MoveSet
; =============== MoveInit_Daimon_ChouOosotoGari ===============
MoveInit_Daimon_ChouOosotoGari:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_DAIMON_CHOU_OOSOTO_GARI_L, MOVE_DAIMON_CHOU_OOSOTO_GARI_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Daimon_MoveSet
; =============== MoveInit_Daimon_CloudTosser ===============
MoveInit_Daimon_CloudTosser:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_DAIMON_CLOUD_TOSSER, MOVE_DAIMON_STUMP_THROW
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Daimon_MoveSet
; =============== MoveInit_Daimon_HeavenDrop ===============
MoveInit_Daimon_HeavenDrop:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_ValStartCmdThrow_StdColi Daimon
	mMvIn_GetLH MOVE_DAIMON_HEAVEN_DROP_L, MOVE_DAIMON_HEAVEN_DROP_H
	call MoveInputS_SetSpecMove_StopSpeed
	; Command throw gets invulnerability when confirmed
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_INVULN, [hl]
	jp   MoveInputReader_Daimon_MoveSet
	
; =============== MoveInit_Daimon_HeavenHellDrop ===============
MoveInit_Daimon_HeavenHellDrop:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_ValStartCmdThrow_StdColi Daimon
	mMvIn_GetSD MOVE_DAIMON_HEAVEN_HELL_DROP_S, MOVE_DAIMON_HEAVEN_HELL_DROP_D
	call MoveInputS_SetSpecMove_StopSpeed
	; Command throw gets invulnerability when confirmed
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_INVULN, [hl]
	jp   MoveInputReader_Daimon_MoveSet
; =============== MoveInputReader_Daimon_MoveSet ===============
MoveInputReader_Daimon_MoveSet:
	scf
	ret
; =============== MoveInputReader_Daimon_NoMove ===============
MoveInputReader_Daimon_NoMove:
	or   a
	ret
	
; =============== MoveC_Daimon_JiraiShin ===============
; Move code for Daimon's Jirai Shin and its fake variant. (MOVE_DAIMON_JIRAI_SHIN, MOVE_DAIMON_JIRAI_SHIN_FAKE).
MoveC_Daimon_JiraiShin:
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
	mMvC_ValFrameEnd .anim
		mMvC_PlaySound SCT_HEAVY
		jp   .anim
; --------------- frame #1 ---------------	
.obj1:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $0A
		
		; The fake version ends early, before the actual attack starts
		ld   hl, iPlInfo_MoveId
		add  hl, bc
		ld   a, [hl]
		cp   MOVE_DAIMON_JIRAI_SHIN_FAKE	; iPlInfo_MoveId == MOVE_DAIMON_JIRAI_SHIN_FAKE
		jp   z, .end						; If so, we're done
		
		mMvC_PlaySound SCT_GROUNDHIT
		jp   .anim
; --------------- frame #2 ---------------	
.obj2:
	call Play_Pl_DoGroundScreenShake
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $10
		; Frame #3 uses an extremely long hitbox across the ground.
		; When the opponent gets hit, the screen shakes, so initialize this.
		xor  a
		ld   [wScreenShakeY], a
		jp   .anim
; --------------- frame #3 ---------------
; Attack frame. When it ends, the move's over.
.chkEnd:
	mMvC_ValFrameEnd .anim
; --------------- common ---------------	
.end:
	call Play_Pl_EndMove
	jr   .ret
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Daimon_ChouUkemi ===============
; Move code for Daimon's Chou Ukemi (MOVE_DAIMON_CHOU_UKEMI_L, MOVE_DAIMON_CHOU_UKEMI_H).	
; Command roll.
MoveC_Daimon_ChouUkemi:
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
	; At the start of the frame, set the forward movement speed
	mMvC_ValFrameStart .obj0_moveH
		mMvC_PlaySound SFX_HEAVY
		
		; Depending on the move strength...
		mMvIn_ChkLHE .obj0_setSpeedH, .obj0_setSpeedE
	.obj0_setSpeedL: ; Light
		mMvC_SetSpeedH +$0100
		jp   .obj0_moveH
	.obj0_setSpeedH: ; Heavy
		mMvC_SetSpeedH +$0200
		jp   .obj0_moveH
	.obj0_setSpeedE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH +$0300
.obj0_moveH:
	jp   .moveH
; --------------- frame #1 ---------------	
.obj1:
	mMvC_ValFrameEnd .moveH
		mMvC_SetAnimSpeed $04 ; Slow down anim (from $01)
		mMvC_PlaySound SFX_DROP
		jp   .moveH
; --------------- frame #1-2, common horz movement ---------------	
.moveH:
	call OBJLstS_ApplyXSpeed
	jp   .anim
; --------------- frame #2 ---------------	
.obj2:
	; Shake the ground for the duration of this frame
	call Play_Pl_DoGroundScreenShake
	
	; [POI] Incorrect target
IF FIX_BUGS == 1
	mMvC_ValFrameEnd .anim
ELSE
	mMvC_ValFrameEnd MoveC_Daimon_JiraiShin.anim
ENDC
		; When the frame is over...
		mMvC_SetAnimSpeed $02	; Speed up the anim
		xor  a					; Reset the screen Y offset
		ld   [wScreenShakeY], a
		
		; Allow chaining into another special during recovery (#3)
		ld   hl, iPlInfo_Flags0
		add  hl, bc
		res  PF0B_SPECMOVE, [hl]
		inc  hl			; Seek to iPlInfo_Flags1
		res  PF1B_NOSPECSTART, [hl]
		jp   .anim
; --------------- frame #3 ---------------	
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jp   .ret
; --------------- common ---------------	
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Daimon_CmdThrow ===============
; Move code for Daimon's command throws:
; - Chou Oosoto Gari (MOVE_DAIMON_CHOU_OOSOTO_GARI_L, MOVE_DAIMON_CHOU_OOSOTO_GARI_H)
; - Cloud Tosser (MOVE_DAIMON_CLOUD_TOSSER)
; - Stump Throw (MOVE_DAIMON_STUMP_THROW)
MoveC_Daimon_CmdThrow:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	
	; Startup
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj0
	
	; Throw test
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
	
	; Throw whiff
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj2
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	
	; Throw ok
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj4
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj5
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj6
	cp   $07*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj2
	cp   $08*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	
	jp   .anim ; We never get here
; --------------- frame #0 ---------------	
; Startup.
.obj0:
	jp   .anim
; --------------- frame #1 ---------------
; Tries to start the command throw.	
.obj1:
	; If the animation continues as normal (.obj1_anim), the throw hasn't grabbed the opponent yet.
	; If the validation must passes, the throw is confirmed, so we get moved to #4.
	
	; Opponent must be in throw range (overlapped with hitbox for throw range)
	ld   hl, iPlInfo_ColiFlags
	add  hl, bc
	bit  PCF_HITOTHER, [hl]
	jp   z, .obj1_anim
	
	ld   hl, iPlInfo_Flags1Other
	add  hl, bc
	; Opponent must not be invulnerable
	bit  PF1B_INVULN, [hl]
	jp   nz, .obj1_anim
	; Opponent must be hit
	bit  PF1B_HITRECV, [hl]
	jp   z, .obj1_anim
	; Opponent can't have blocked the hit
	bit  PF1B_GUARD, [hl]
	jp   nz, .obj1_anim
	
	; Try to start the command throw
	mMvIn_ValStartCmdThrow_AllColi .anim
	
		; We're invulnerable with the throw confirmed
		ld   hl, iPlInfo_Flags1
		add  hl, bc
		set  PF1B_INVULN, [hl]
		
		; Set info for next frame
		mMvC_SetFrame $04*OBJLSTPTR_ENTRYSIZE, $01
		mMvC_SetDamageNext $06, HITTYPE_THROW_ROTL, PF3_HEAVYHIT
		mMvC_MoveThrowOp -$10, -$18
		jp   .ret
.obj1_anim:
	jp   .anim
; --------------- frame #4 ---------------
; Rotation frame 1
.obj4:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $06, HITTYPE_THROW_ROTL, PF3_HEAVYHIT
		
		; For Cloud Tosser / Stump Throw
		mMvC_MoveThrowOp -$08, -$18 ; Move opponent back 8px, up $18px
		
		; Chou Oosoto Gari uses a different position and makes the opponent face the same direction as us
		ld   hl, iPlInfo_MoveId
		add  hl, bc
		ld   a, [hl]
		cp   MOVE_DAIMON_CLOUD_TOSSER	; MoveId >= MOVE_DAIMON_CLOUD_TOSSER?
		jp   nc, .anim					; If so, jump (not Chou Oosoto Gari)
		call Pl_CopyXFlipToOther
		mMvC_MoveThrowOp -$10, -$18
		jp   .anim
; --------------- frame #5 ---------------
; Rotation frame 2
.obj5:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $06, HITTYPE_THROW_ROTD, PF3_HEAVYHIT
		
		; Use different opponent position for Chou Oosoto Gari
		ld   hl, iPlInfo_MoveId
		add  hl, bc
		ld   a, [hl]
		cp   MOVE_DAIMON_CLOUD_TOSSER	; MoveId >= MOVE_DAIMON_CLOUD_TOSSER?
		jp   nc, .obj5_setPosCt			; If so, jump (not Chou Oosoto Gari)
	.obj5_setPosCog:
		mMvC_MoveThrowOp -$10, -$10
		jp   .anim
	.obj5_setPosCt:
		mMvC_MoveThrowOp +$10, -$08
		jp   .anim
; --------------- frame #6 ---------------
; Rotation frame 3, switch to damage at the end.
.obj6:
	mMvC_ValFrameEnd .anim
	
		; Set damage info when switching to #7.
		; Chou Oosoto Gari uses a different hit effect than the others.
		ld   hl, iPlInfo_MoveId
		add  hl, bc
		ld   a, [hl]
		cp   MOVE_DAIMON_CLOUD_TOSSER	; MoveId >= MOVE_DAIMON_CLOUD_TOSSER?
		jp   nc, .obj6_setDamageCt		; If so, jump (not Chou Oosoto Gari)
	.obj6_setDamageCog:
		mkhl $06, HITTYPE_DROP_DB_A
		ld   hl, CHL
		jp   .obj6_setDamage
	.obj6_setDamageCt:
		mkhl $06, HITTYPE_THROW_END
		ld   hl, CHL
	.obj6_setDamage:
		ld   a, $00 ; Flags
		call Play_Pl_SetMoveDamageNext
		jp   .anim
; --------------- frame #2,#7 ---------------
; Whiff for #2, Damage frame for #7.
.obj2:
	; When switching to #3 or #8, set $0A frames of delay to the recovery.
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $0A
		jp   .anim
; --------------- frames #3,#8 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		jp   .end
	.end:
		mMvC_EndThrow_Slow
		jp   .ret
; --------------- common ---------------	
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Daimon_HeavenDrop ===============
; Move code for Daimon's Heaven Drop (MOVE_DAIMON_HEAVEN_DROP_L, MOVE_DAIMON_HEAVEN_DROP_H).
; Command throw.
MoveC_Daimon_HeavenDrop:
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
	jp   z, .obj7
	cp   $09*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim ; We never get here
; --------------- frame #0 ---------------	
.obj0:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $06, HITTYPE_THROW_ROTL, PF3_HEAVYHIT
		mMvC_MoveThrowOp -$10, -$18
		jp   .anim
; --------------- frames #7-8 ---------------	
.obj7:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $05
		jp   .anim
; --------------- frame #1 ---------------	
.obj1:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $06, HITTYPE_THROW_ROTL, PF3_HEAVYHIT
		mMvC_MoveThrowOp +$08, -$20
		jp   .anim
; --------------- frame #2 ---------------	
.obj2:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $06, HITTYPE_HIT_MULTIGS, PF3_LASTHIT|PF3_LIGHTHIT
		jp   .anim
; --------------- frame #3 ---------------	
.obj3:
	mMvC_ValFrameEnd .anim
		mMvIn_ValStartCmdThrow_AllColi .ret
			jp   .anim
; --------------- frame #4 ---------------	
.obj4:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $06, HITTYPE_THROW_ROTL, PF3_HEAVYHIT
		mMvC_MoveThrowOp -$10, -$20
		jp   .anim
; --------------- frame #5 ---------------	
.obj5:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $06, HITTYPE_THROW_ROTL, PF3_HEAVYHIT
		mMvC_MoveThrowOp +$04, -$18
		jp   .anim
; --------------- frame #6 ---------------	
.obj6:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $1E
		mMvC_SetDamageNext $06, HITTYPE_DROP_SWOOPUP, PF3_HEAVYHIT
		jp   .anim
; --------------- frame #9 ---------------	
.chkEnd:
	mMvC_ValFrameEnd .anim
		mMvC_EndThrow_Slow
		jp   .ret
; --------------- common ---------------	
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Daimon_HeavenHellDrop ===============
; Move code for Daimon's Heaven to Hell Drop (MOVE_DAIMON_HEAVEN_HELL_DROP_S, MOVE_DAIMON_HEAVEN_HELL_DROP_D).	
; Command throw.
MoveC_Daimon_HeavenHellDrop:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .init
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .iGrabUF
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .iGrabF
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .iGrabDFDamage
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .iSetSpeed
	
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .lpGrabStartF
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .lpGrabU
	cp   $07*OBJLSTPTR_ENTRYSIZE
	jp   z, .lpGrabUB_setDamage
	cp   $08*OBJLSTPTR_ENTRYSIZE
	jp   z, .lpGrabB_decAnimSpeed
	cp   $09*OBJLSTPTR_ENTRYSIZE
	jp   z, .lpGrabStartB
	cp   $0A*OBJLSTPTR_ENTRYSIZE
	jp   z, .lpGrabU2
	cp   $0B*OBJLSTPTR_ENTRYSIZE
	jp   z, .lpGrabUB_setDamage
	cp   $0C*OBJLSTPTR_ENTRYSIZE
	jp   z, .lpChkLoop
	
	cp   $0D*OBJLSTPTR_ENTRYSIZE
	jp   z, .lpGrabStartF
	cp   $0E*OBJLSTPTR_ENTRYSIZE
	jp   z, .lpGrabU
	cp   $0F*OBJLSTPTR_ENTRYSIZE
	jp   z, .startThrow
	cp   $10*OBJLSTPTR_ENTRYSIZE
	jp   z, .throw1
	cp   $11*OBJLSTPTR_ENTRYSIZE
	jp   z, .throw2
	
	cp   $12*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	
	jp   .anim ; We never get here
	
; --------------- frame #0 ---------------
; Startup & initialization code.
.init:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $05
		mMvC_SetDamageNext $06, HITTYPE_THROW_ROTL, PF3_HEAVYHIT
		
		; 
		; This move animation is divided in five parts:
		; - Init (here)
		; - First hit in grab mode (#1-#4)
		; - Looping part for 2nd+ hit during grab mode (#5-#C)
		; - The throw itself (#C-#11)
		; - Transition to Jirai Shin for the earthquake effect (if applicable) (#12)
		;
		; How many times the second part is looped is determined by the timer in iPlInfo_Daimon_HeavenHellDrop_GrabLoopsLeft.
		; The looping part loops more times in the desperation version of the move, meaning the opponents receives more damage by the end.
		; Because the loop timer also directly influences the animation speed (Speed = Timer >> 1), having
		; it loop more means the desperation super starts with a slower animation speed.
		;
		
		
		; Initialize the aforemented loop timer
		ld   hl, iPlInfo_MoveId
		add  hl, bc
		ld   a, [hl]
		cp   MOVE_DAIMON_HEAVEN_HELL_DROP_D	; Is the current move the desperation super?
		jr   z, .init_setLoopCountD			; If so, jump
	.init_setLoopCountS:
		ld   a, $02				; Loop twice for normal super			
		jp   .init_setLoopCount
	.init_setLoopCountD:
		ld   a, $04				; Loop 4 times for desperation super
	.init_setLoopCount:
		ld   hl, iPlInfo_Daimon_HeavenHellDrop_GrabLoopsLeft
		add  hl, bc				; Seek to loop counter
		ld   [hl], a			; Save the new value
		
		; Make opponent face same direction as us
		call Pl_CopyXFlipToOther
		mMvC_MoveThrowOp -$08, -$10
		jp   .anim
; --------------- frame #1 ---------------
; Initial grab frame. Opponent up-front.
.iGrabUF:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $06, HITTYPE_THROW_ROTL, PF3_HEAVYHIT
		mMvC_MoveThrowOp -$0C, -$10
		jp   .anim
; --------------- frame #2 ---------------
; Initial grab frame. Opponent is in front.
.iGrabF:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $06, HITTYPE_THROW_ROTD, PF3_LASTHIT|PF3_LIGHTHIT
		mMvC_MoveThrowOp -$10, -$08
		jp   .anim
; --------------- frame #3 ---------------
; Initial grab frame. Opponent is in front and slightly below the middle.
.iGrabDFDamage:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $06, HITTYPE_HIT_MULTIGS, PF3_LASTHIT|PF3_LIGHTHIT
		jp   .anim
; --------------- frame #4 ---------------
; Initial grab frame. Opponent is on the ground forward.
;
; At the end of the frame, it initializes the animation speed for the looping portion:
; iOBJInfo_FrameTotal = LoopCounter * 2
; This will get decremented twice for every loop, appropriately.
.iSetSpeed:
	mMvC_ValFrameEnd .anim

		push hl	; Save HL
			ld   hl, iPlInfo_Daimon_HeavenHellDrop_GrabLoopsLeft
			add  hl, bc
			ld   a, [hl]	; A = Timer << 1
			sla  a
		pop  hl			; Restore ptr to iOBJInfo_FrameLeft
		inc  hl			; Seek to iOBJInfo_FrameTotal
		ld   [hl], a	; iOBJInfo_FrameTotal = A
		jp   .anim
; --------------- common move / damage instructions ---------------
.setRotL_XM08_YM18:
	mMvC_MoveThrowOp -$08, -$18 ; Move opponent back 8px, up $18px
	jp   .setRotL
.setRotL_XP08_YM18:
	mMvC_MoveThrowOp +$08, -$18
.setRotL:
	mMvC_SetDamageNext $06, HITTYPE_THROW_ROTL, PF3_HEAVYHIT
	jp   .anim
.setRotD_XM10YM14:
	mMvC_MoveThrowOp -$10, -$14
	jp   .setRotD
.setRotD_XP10YM14:
	mMvC_MoveThrowOp +$10, -$14
.setRotD:
	mMvC_SetDamageNext $06, HITTYPE_THROW_ROTD, PF3_HEAVYHIT
	jp   .anim
; --------------- frame #5,#D ---------------
; Grab loop - Daimon crouching starting the throw. Opponent is on the ground in front.
.lpGrabStartF:
	mMvC_ValFrameEnd .anim
		; Start the command throw again, since damaging the player using HITTYPE_HIT_MULTIGS internally ended the throw state.
		; As the opponent is near and "frozen", this should never fail.
		mMvIn_ValStartCmdThrow_AllColi .ret
			jp   .setRotL_XM08_YM18
; --------------- frame #9 ---------------
; Grab loop - Daimon crouching starting the throw. Opponent is on the ground behind.
.lpGrabStartB:
	mMvC_ValFrameEnd .anim
		; See #5
		mMvIn_ValStartCmdThrow_AllColi .ret
			jp   .setRotL_XP08_YM18
; --------------- frame #6,#E ---------------
; Grab loop. Opponent is above, coming from forward.
.lpGrabU:
	mMvC_ValFrameEnd .anim
		jp   .setRotD_XP10YM14
; --------------- frame #A ---------------
; Grab loop. Opponent is above, coming from behind.
.lpGrabU2:
	mMvC_ValFrameEnd .anim
		jp   .setRotD_XM10YM14
; --------------- frame #7,#B ---------------
; Grab loop. Opponent is diagonally up backwards..
.lpGrabUB_setDamage:
	; At the end of this, deal damage.
	; Doing this ends the throw state, so one of the frames after regrabs the opponent.
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $06, HITTYPE_HIT_MULTIGS, PF3_HEAVYHIT
		jp   .anim
; --------------- frame #F ---------------
; At the end of the frame, perform the long off-screen throw.
.startThrow:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $0A
		mMvC_SetDamageNext $06, HITTYPE_DROP_SWOOPUP, PF3_HEAVYHIT
		jp   .anim
; --------------- frame #8 ---------------
; Grab loop. Opponent is on the ground backwards.
.lpGrabB_decAnimSpeed:
	mMvC_ValFrameEnd .anim
		inc  hl	; Seek to iOBJInfo_FrameTotal
		dec  [hl]
		jp   .anim
; --------------- frame #C ---------------
; Grab loop. Opponent is on the ground forwards, like in #5.
; At the end of the frame, check if the looping portion should actually loop.
.lpChkLoop:
	mMvC_ValFrameEnd .anim
		; Increase animation speed again (after it was done on #8)
		inc  hl		; Seek to iOBJInfo_FrameTotal
		dec  [hl]	; iOBJInfo_FrameTotal--
		
		push hl
			; LoopCount--
			ld   hl, iPlInfo_Daimon_HeavenHellDrop_GrabLoopsLeft
			add  hl, bc
			dec  [hl]					; Did the loop counter elapse?
			jp   z, .lpChkLoop_noLoop	; If so, jump
		pop  hl	
		
		; Otherwise, loop back to #5.
		; Since .anim will increment the internal sprite mapping ID, this value must be set to #4.
		ld   hl, iOBJInfo_OBJLstPtrTblOffset
		add  hl, de
		ld   [hl], $04*OBJLSTPTR_ENTRYSIZE
		jp   .anim
		
		.lpChkLoop_noLoop:
		pop  hl
		; When the looping is over, continue normally to #D and animate as fast as possible.
		ld   [hl], ANIMSPEED_INSTANT
		jp   .anim
; --------------- frame #10 ---------------
; Throw frame. Nothing happens here.
.throw1:
	jp   .anim
; --------------- frame #11 ---------------
; Post-throw frame.
.throw2:
	mMvC_ValFrameEnd .anim
		; Set a really large delay for #12 before it starts the earthquake.
		; This is sync'd to how the opponent moves when thrown, so the earthquake happens
		; when the opponent is on the ground.
		mMvC_SetAnimSpeed $64
		jp   .anim
; --------------- frame #12 ---------------
; Last frame before the transition to Jirai Shin.
.chkEnd:
	mMvC_ValFrameEnd .anim
		; Transition to Jirai Shin when the move ends.
		; Only the desperation super actually transitions to the real one though.
		ld   a, PLAY_THROWACT_NONE
		ld   [wPlayPlThrowActId], a
		ld   hl, iPlInfo_MoveId
		add  hl, bc
		ld   a, [hl]
		cp   MOVE_DAIMON_HEAVEN_HELL_DROP_D	; Is the current move the desperation super?
		jr   z, .chkEnd_real				; If so, jump
	.chkEnd_fake:
		ld   a, MOVE_DAIMON_JIRAI_SHIN_FAKE
		jp   .chkEnd_setNextMove
	.chkEnd_real:
		ld   a, MOVE_DAIMON_JIRAI_SHIN
	.chkEnd_setNextMove:
		call MoveInputS_SetSpecMove_StopSpeed
		mMvC_SetDamageNext $08, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_LIGHTHIT
		jp   .ret
; --------------- common ---------------	
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
IF REV_LANG_EN == 1
TextC_CutsceneKagura0:
	db .end-.start
.start:
	db "Congratulations.", C_NL
	db "That was an", C_NL
	db " impressive match.", C_NL
.end:
TextC_CutsceneKagura1:
	db .end-.start
.start:
	db "My name is", C_NL
	db " Kagura Chizuru.", C_NL
	db "I am the organizer", C_NL
	db " of this tournament.", C_NL
.end:
TextC_CutsceneKagura2:
	db .end-.start
.start:
	db "I wished to see the", C_NL
	db " one who had", C_NL
	db " strength enough to", C_NL
	db "       defeat Rugal.", C_NL
.end:
TextC_CutsceneKagura3:
	db .end-.start
.start:
	db "And now I wish to", C_NL
	db " see your true", C_NL
	db "           strength.", C_NL
.end:
TextC_CutsceneKagura4:
	db .end-.start
.start:
	db "I shall be", C_NL
	db " disappointed if the", C_NL
	db " strength you", C_NL
	db " displayed during", C_NL
	db " the tournament is", C_NL
.end:
TextC_CutsceneKagura5:
	db .end-.start
.start:
	db " the limit of", C_NL
	db "      your powers...", C_NL
.end:
ENDC

; =============== END OF BANK ===============
; Junk area below, with partial copy of the code above.
IF REV_VER_2 == 0
	mIncJunk "L057ED2"
ELSE
	mIncJunk "L057FEE"
ENDC