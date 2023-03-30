INCLUDE "data/objlst/char/daimon.asm"
INCLUDE "data/objlst/char/terry.asm"
INCLUDE "data/objlst/char/krauser.asm"
INCLUDE "data/objlst/char/mature.asm"

; =============== MoveInputReader_Krauser ===============
; Special move input checker for KRAUSER.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
; OUT
; - C flag: If set, a move was started
MoveInputReader_Krauser:
	mMvIn_Validate Krauser
.chkAir:
	jp   MoveInputReader_Krauser_NoMove
	
.chkGround:
	;             SELECT + B                   SELECT + A
	mMvIn_ChkEasy MoveInit_Krauser_KaiserWave, MoveInit_Krauser_KaiserKick
	mMvIn_ChkGA Krauser, .chkPunch, .chkKick
.chkPunch:
	; FDBF+P (close) -> Kaiser Suplex
	; "Not" check for this command throw, since it uses the same input as the next one.
	mMvIn_ChkDirNot MoveInput_FDBF, .chkPunchSuper
	mMvIn_JpIfStartCmdThrow_StdColi MoveInit_Krauser_KaiserSuplex ; Jump here on success
.chkPunchSuper:
	; FBDF+P -> Kaiser Wave
	mMvIn_ValSuper .chkPunchNoSuper
	mMvIn_ChkDir MoveInput_FBDF, MoveInit_Krauser_KaiserWave
.chkPunchNoSuper:
	; DB+P -> High Blitz Ball
	mMvIn_ChkDir MoveInput_DB, MoveInit_Krauser_HighBlitzBall
	jp   MoveInputReader_Krauser_NoMove
.chkKick:
	; FDF+K -> Kaiser Kick
	mMvIn_ChkDir MoveInput_FDF, MoveInit_Krauser_KaiserKick
	; BDF+K -> Kaiser Duel Sobat
	mMvIn_ChkDir MoveInput_BDF, MoveInit_Krauser_KaiserDuelSobat
	; DB+K -> Low Blitz Ball
	mMvIn_ChkDir MoveInput_DB, MoveInit_Krauser_LowBlitzBall
	; DF+K -> Leg Tomahawk
	mMvIn_ChkDir MoveInput_DF, MoveInit_Krauser_LegTomahawk
	jp   MoveInputReader_Krauser_NoMove
	
; =============== MoveInit_Krauser_HighBlitzBall ===============	
MoveInit_Krauser_HighBlitzBall:
	mMvIn_ValProjActive Krauser
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_KRAUSER_HIGH_BLITZ_BALL_L, MOVE_KRAUSER_HIGH_BLITZ_BALL_H
	call MoveInputS_SetSpecMove_StopSpeed
	call Play_Proj_CopyMoveDamageFromPl
	jp   MoveInputReader_Krauser_SetMove
; =============== MoveInit_Krauser_LowBlitzBall ===============	
MoveInit_Krauser_LowBlitzBall:
	mMvIn_ValProjActive Krauser
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_KRAUSER_LOW_BLITZ_BALL_L, MOVE_KRAUSER_LOW_BLITZ_BALL_H
	call MoveInputS_SetSpecMove_StopSpeed
	call Play_Proj_CopyMoveDamageFromPl
	jp   MoveInputReader_Krauser_SetMove
; =============== MoveInit_Krauser_LegTomahawk ===============	
MoveInit_Krauser_LegTomahawk:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_KRAUSER_LEG_TOMAHAWK_L, MOVE_KRAUSER_LEG_TOMAHAWK_H
	call MoveInputS_SetSpecMove_StopSpeed
	; [POI] There's a hidden heavy version with the powerup enabled.
	;       This version is invulnerable compared to the normal heavy.
	call MoveInputS_CheckMoveLHVer				; Recheck LH status
	jr   nc, MoveInputReader_Krauser_SetMove	; Did we start an hidden heavy? If not, return
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_INVULN, [hl]
	jp   MoveInputReader_Krauser_SetMove
; =============== MoveInit_Krauser_KaiserKick ===============	
MoveInit_Krauser_KaiserKick:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_KRAUSER_KAISER_KICK_L, MOVE_KRAUSER_KAISER_KICK_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Krauser_SetMove
; =============== MoveInit_Krauser_KaiserDuelSobat ===============	
MoveInit_Krauser_KaiserDuelSobat:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_KRAUSER_KAISER_DUEL_SOBAT_L, MOVE_KRAUSER_KAISER_DUEL_SOBAT_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_Krauser_SetMove
; =============== MoveInit_Krauser_KaiserSuplex ===============	
MoveInit_Krauser_KaiserSuplex:
	call Play_Pl_ClearJoyDirBuffer
	call Task_PassControlFar
	; Set the second "unthrowtechable" half of the grab mode, like for normal throws.
	ld   a, PLAY_THROWACT_NEXT03
	ld   [wPlayPlThrowActId], a
	mMvIn_GetLH MOVE_KRAUSER_KAISER_SUPLEX_L, MOVE_KRAUSER_KAISER_SUPLEX_H
	call MoveInputS_SetSpecMove_StopSpeed
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_INVULN, [hl]
	jp   MoveInputReader_Krauser_SetMove
; =============== MoveInit_Krauser_KaiserWave ===============	
MoveInit_Krauser_KaiserWave:
	mMvIn_ValProjActive Krauser
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetSD MOVE_KRAUSER_KAISER_WAVE_S, MOVE_KRAUSER_KAISER_WAVE_D
	call MoveInputS_SetSpecMove_StopSpeed
	call Play_Proj_CopyMoveDamageFromPl
	jp   MoveInputReader_Krauser_SetMove
; =============== MoveInputReader_Krauser_SetMove ===============
MoveInputReader_Krauser_SetMove:
	scf
	ret
; =============== MoveInputReader_Krauser_NoMove ===============
MoveInputReader_Krauser_NoMove:
	or   a
	ret

; =============== MoveC_Krauser_BlitzBall ===============
; Move code for Krauser's Blitz Ball, both low and high versions:
; - MOVE_KRAUSER_LOW_BLITZ_BALL_L
; - MOVE_KRAUSER_LOW_BLITZ_BALL_H
; - MOVE_KRAUSER_HIGH_BLITZ_BALL_L
; - MOVE_KRAUSER_HIGH_BLITZ_BALL_H
MoveC_Krauser_BlitzBall:
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
		; Different animation speed between light and heavy versions.
		inc  hl	; Seek to iOBJInfo_FrameTotal
		push hl
		mMvIn_ChkLH .obj1_setAnimSpeedH
	.obj1_setAnimSpeedL:
		pop  hl		; HL = Ptr to iOBJInfo_FrameTotal
		ld   [hl], $0C
		jp   .anim
	.obj1_setAnimSpeedH:
		pop  hl		; HL = Ptr to iOBJInfo_FrameTotal
		ld   [hl], $18
		jp   .anim
; --------------- frame #2 ---------------
.obj2:
	mMvC_ValFrameStart .chkEnd
		; Distinguish between low and high Blitz Ball.
		; The high version is $11px above the low one.
		ld   hl, iPlInfo_MoveId
		add  hl, bc
		ld   a, [hl]
		ld   hl, -$1100
		cp   MOVE_KRAUSER_HIGH_BLITZ_BALL_L	; Using high ver?
		jp   z, .obj2_initProj				; If so, jump
		cp   MOVE_KRAUSER_HIGH_BLITZ_BALL_H	; Using high ver?
		jp   z, .obj2_initProj				; If so, jump
		ld   hl, +$0000
	.obj2_initProj:
		call ProjInit_Krauser_BlitzBall
.chkEnd:
	mMvC_ValFrameEnd .anim
	call Play_Pl_EndMove
	jr   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Krauser_LegTomahawk ===============
; Move code for Krauser's Leg Tomahawk (MOVE_KRAUSER_LEG_TOMAHAWK_L, MOVE_KRAUSER_LEG_TOMAHAWK_H).
MoveC_Krauser_LegTomahawk:
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
.obj0:
	;--
	mMvC_ValFrameStart .obj0_cont
.obj0_cont:
	;--
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		; [POI] Hidden heavy version of the move deals a hit on #2
		mMvIn_ChkLHE .obj0_noDamage, .obj0_setDamage
	.obj0_noDamage:
		jp   .anim
	.obj0_setDamage:
		mMvC_SetDamageNext $04, HITTYPE_HIT_MID1, PF3_HEAVYHIT|PF3_LASTHIT
		jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameStart .obj1_cont
		mMvC_PlaySound SCT_MOVEJUMP_B
		mMvIn_ChkLHE .setJumpH, .setJumpE
	.setJumpL: ; Light
		mMvC_SetSpeedH +$0300
		mMvC_SetSpeedV -$0400
		jp   .obj1_doGravity
	.setJumpH: ; Heavy
		mMvC_SetSpeedH +$0400
		mMvC_SetSpeedV -$0480
		jp   .obj1_doGravity
	.setJumpE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH +$0580
		mMvC_SetSpeedV -$0400
	.obj1_doGravity:
		jp   .doGravity
.obj1_cont:
	; Switch to #2 when YSpeed > -$06 (immediately) and then set its damage
	mMvC_NextFrameOnGtYSpeed -$06, ANIMSPEED_NONE
	jp   nc, .doGravity
		mMvC_SetDamageNext $08, HITTYPE_HIT_MID0, PF3_HEAVYHIT|PF3_LASTHIT
		jp   .doGravity
; --------------- frame #2 ---------------
.obj2:
	mMvC_NextFrameOnGtYSpeed -$02, ANIMSPEED_NONE
	jp   nc, .doGravity
		ld   hl, iPlInfo_Flags1
		add  hl, bc
		res  PF1B_INVULN, [hl]
		mMvC_SetDamageNext $08, HITTYPE_DROP_DB_A, PF3_LASTHIT
		jp   .doGravity
; --------------- frames #1-2 / common gravity check ---------------
.doGravity:
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $04*OBJLSTPTR_ENTRYSIZE, $06
		mMvC_SetDamageNext $08, HITTYPE_DROP_DB_A, PF3_HEAVYHIT
		jp   .ret
; --------------- frame #6 ---------------
.chkEnd:;J
	mMvC_ValFrameEnd .anim
	call Play_Pl_EndMove
	jr   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Krauser_KaiserKick ===============
; Move code for Krauser's Kaiser Kick (MOVE_KRAUSER_KAISER_KICK_L, MOVE_KRAUSER_KAISER_KICK_H).
MoveC_Krauser_KaiserKick:
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
.obj0_cont:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameStart .obj1_cont
		mMvC_PlaySound SCT_MOVEJUMP_B
		mMvIn_ChkLHE .setJumpH, .setJumpE
	.setJumpL: ; Light
		mMvC_SetSpeedH +$0400
		mMvC_SetSpeedV -$0380
		jp   .obj1_cont
	.setJumpH: ; Heavy
		mMvC_SetSpeedH +$0500
		mMvC_SetSpeedV -$0400
		jp   .obj1_cont
	.setJumpE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH +$0600
		mMvC_SetSpeedV -$0480
.obj1_cont:
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetFrame $02*OBJLSTPTR_ENTRYSIZE, $0A
		mMvC_PlaySound SFX_DROP
		jp   .ret
; --------------- frame #2 ---------------
; Performs a earthquake until the frame is over.
.obj2:
	call Play_Pl_DoGroundScreenShake
	mMvC_ValFrameEnd .anim
		xor  a
		ld   [wScreenShakeY], a
		jp   .anim
; --------------- frame #3 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Krauser_KaiserDuelSobat ===============
; Move code for Krauser's Kaiser Duel Sobat (MOVE_KRAUSER_KAISER_DUEL_SOBAT_L, MOVE_KRAUSER_KAISER_DUEL_SOBAT_H).
MoveC_Krauser_KaiserDuelSobat:
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
	jp   z, .chkEnd
	jp   .anim
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameStart .obj0_cont
		mMvC_PlaySound SCT_MOVEJUMP_B
		mMvIn_ChkLHE .setJumpH, .setJumpE
	.setJumpL: ; Light
		mMvC_SetSpeedH +$0400
		mMvC_SetSpeedV -$0300
		jp   .obj0_cont
	.setJumpH: ; Heavy
		mMvC_SetSpeedH +$0500
		mMvC_SetSpeedV -$0300
		jp   .obj0_cont
	.setJumpE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH +$0600
		mMvC_SetSpeedV -$0300
.obj0_cont:
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $01*OBJLSTPTR_ENTRYSIZE, $00
		jp   .ret
; --------------- frame #2 ---------------
.obj2:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $10
		mMvC_SetDamageNext $04, HITTYPE_DROP_MAIN, PF3_HEAVYHIT
		jp   .anim
; --------------- frame #3 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Krauser_KaiserSuplex ===============
; Move code for Krauser's Kaiser Suplex (MOVE_KRAUSER_KAISER_SUPLEX_L, MOVE_KRAUSER_KAISER_SUPLEX_H).
; Command throw.
MoveC_Krauser_KaiserSuplex:
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
	cp   $09*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim ; We never get here
; --------------- frame #0 ---------------
; Rotation frame 1.
.obj0:
	mMvC_ValFrameStart .anim
		mMvC_SetDamage $06, HITTYPE_THROW_ROTU, PF3_HEAVYHIT
		mMvC_MoveThrowOp +$08, +$00
		jp   .anim
; --------------- frame #1 ---------------
; Rotation frame 2.
.obj1:
	mMvC_ValFrameStart .anim
		mMvC_SetDamage $06, HITTYPE_THROW_ROTU, PF3_HEAVYHIT
		mMvC_MoveThrowOp +$08, -$04
		jp   .anim
; --------------- frame #2 ---------------
; Rotation frame 3.
.obj2:
	mMvC_ValFrameStart .obj2_cont
		mMvC_SetDamage $06, HITTYPE_THROW_ROTR, PF3_HEAVYHIT
		mMvC_MoveThrowOp +$08, -$18
.obj2_cont:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		jp   .anim
; --------------- frame #3 ---------------
; Player jumps holding the opponent.
.obj3:
	mMvC_ValFrameStart .obj3_cont
		mMvC_PlaySound SCT_MOVEJUMP_B
		mMvC_SetSpeedH +$0400
		mMvC_SetSpeedV -$0400
		mMvC_SetDamage $06, HITTYPE_THROW_ROTR, PF3_HEAVYHIT
		mMvC_MoveThrowOp -$08, -$18 ; Move opponent back 8px, up $18px
		mMvC_MoveThrowOpSync
.obj3_cont:
	; Switch to next frame as soon as the speed decrements once (it's -$04 at first)
	mMvC_NextFrameOnGtYSpeed -$04, ANIMSPEED_NONE
	jp   nc, .doGravityDamage
	jp   .doGravityDamage
; --------------- frame #4 ---------------
; Second part of the jump, changing rotation frame.
; This lasts until .doGravityDamage switches us to #5.
.obj4:
	mMvC_ValFrameStart .obj4_cont
		mMvC_SetDamage $06, HITTYPE_THROW_ROTD, PF3_HEAVYHIT
		mMvC_MoveThrowOp -$10, -$04
		mMvC_MoveThrowOpSync
.obj4_cont:
	jp   .doGravityDamage
; --------------- frame #5 ---------------
; Deal large amounts of damage once, releasing the opponent with HITTYPE_DROP_DB_A.
.obj5:
	mMvC_SetDamage $0A, HITTYPE_DROP_DB_A, PF3_HEAVYHIT
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		jp   .anim
; --------------- frame #6 ---------------
; Start backjump when the throw ends.
.obj6:
	mMvC_ValFrameStart .obj6_cont
		mMvC_SetSpeedH -$0280
		mMvC_SetSpeedV -$0400
.obj6_cont:
	mMvC_NextFrameOnGtYSpeed -$06, ANIMSPEED_NONE
	jp   nc, .doGravity
	jp   .doGravity
; --------------- frame #7 ---------------
; Backjump until peak.
.obj7:
	mMvC_NextFrameOnGtYSpeed +$00, ANIMSPEED_NONE
	jp   nc, .doGravity
	jp   .doGravity
; --------------- frame #8 ---------------
; Handles rest of backjump until we land.
.obj8:
	jp   .doGravity
; --------------- frames #3-4 / gravity check with damage on land ---------------
.doGravityDamage:
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $05*OBJLSTPTR_ENTRYSIZE, $03
		mMvC_SetDamageNext $0A, HITTYPE_DROP_DB_A, PF3_HEAVYHIT
		jp   .ret
; --------------- frames #6-8 / gravity check ---------------
.doGravity:
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $09*OBJLSTPTR_ENTRYSIZE, $06
		jp   .ret
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
	
; =============== MoveC_Krauser_KaiserWave ===============
; Move code for Krauser's Kaiser Wave (MOVE_KRAUSER_KAISER_WAVE_S, MOVE_KRAUSER_KAISER_WAVE_D).
MoveC_Krauser_KaiserWave:
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
	mMvC_ValFrameStart .obj3_cont
		ld   hl, $2000
		call ProjInit_Krauser_KaiserWave
.obj3_cont:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $0A
		jp   .anim
; --------------- frame #4 ---------------
.obj4:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $02
		jp   .anim
; --------------- frame #5 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== ProjInit_Krauser_BlitzBall ===============
; Initializes the projectile for Krauser's Blitz Ball (both low and high)
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
; - HL: Vertical offset, relative to the player's origin.
;       This is what distinguishes the low and high versions.
ProjInit_Krauser_BlitzBall:
	push bc
		push de
			push hl	; Save vertical offset
	
				mMvC_PlaySound SCT_PHYSFIRE
	
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
					ld   [hl], LOW(ProjC_Horz)		; iOBJInfo_Play_CodePtr_Low
					inc  hl
					ld   [hl], HIGH(ProjC_Horz)	; iOBJInfo_Play_CodePtr_High
					
					; Write sprite mapping ptr for this projectile.
					ld   hl, iOBJInfo_BankNum
					add  hl, de
					ld   [hl], BANK(OBJLstPtrTable_Proj_Krauser_BlitzBall)	; BANK $01 ; iOBJInfo_BankNum
					inc  hl
					ld   [hl], LOW(OBJLstPtrTable_Proj_Krauser_BlitzBall)	; iOBJInfo_OBJLstPtrTbl_Low
					inc  hl
					ld   [hl], HIGH(OBJLstPtrTable_Proj_Krauser_BlitzBall)	; iOBJInfo_OBJLstPtrTbl_High
					inc  hl
					ld   [hl], $00	; iOBJInfo_OBJLstPtrTblOffset

					; Set animation speed.
					ld   hl, iOBJInfo_FrameLeft
					add  hl, de
					ld   [hl], $05	; iOBJInfo_FrameLeft
					inc  hl
					ld   [hl], $05	; iOBJInfo_FrameTotal
					
					; Set priority value
					ld   hl, iOBJInfo_Play_Priority
					add  hl, de
					ld   [hl], $00
					
					; Set initial position relative to the player's origin
					call OBJLstS_Overlap
					
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
				
			; Adjust the vertical position of the projectile
			pop  hl 				; HL = Y Offset
			call Play_OBJLstS_MoveV	; Move it vertically by that
			
			; Also, move the projectile $10px forward
			mMvC_SetMoveH +$1000	
		pop  de
	pop  bc
	ret
	
; =============== ProjInit_Krauser_KaiserWave ===============
; Initializes the projectile for Krauser's Kaiser Wave.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
ProjInit_Krauser_KaiserWave:
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
			push af
				; A = MoveId
				ld   hl, iPlInfo_MoveId
				add  hl, bc
				ld   a, [hl]
				
				; DE = Ptr to wOBJInfo_Pl*Projectile
				push af
					call ProjInitS_InitAndGetOBJInfo
				pop  af
				
				; Write sprite mapping ptr and priority for this projectile.
				; This is different between super and desperation.
				cp   MOVE_KRAUSER_KAISER_WAVE_D	; Using the desperation version?
				jp   z, .objLstD				; If so, jump
			.objLstS:
				
				; Write sprite mapping ptr for this projectile.
				ld   hl, iOBJInfo_BankNum
				add  hl, de
				ld   [hl], BANK(OBJLstPtrTable_Proj_Krauser_KaiserWaveS)	; BANK $01 ; iOBJInfo_BankNum
				inc  hl
				ld   [hl], LOW(OBJLstPtrTable_Proj_Krauser_KaiserWaveS)		; iOBJInfo_OBJLstPtrTbl_Low
				inc  hl
				ld   [hl], HIGH(OBJLstPtrTable_Proj_Krauser_KaiserWaveS)	; iOBJInfo_OBJLstPtrTbl_High
				inc  hl
				ld   [hl], $00	; iOBJInfo_OBJLstPtrTblOffset
				
				; Set priority value
				ld   hl, iOBJInfo_Play_Priority
				add  hl, de
				ld   [hl], $02
				
				jp   .setCodePtr
				
			.objLstD:
				; Write sprite mapping ptr for this projectile.
				ld   hl, iOBJInfo_BankNum
				add  hl, de
				ld   [hl], BANK(OBJLstPtrTable_Proj_Krauser_KaiserWaveD)	; BANK $01 ; iOBJInfo_BankNum
				inc  hl
				ld   [hl], LOW(OBJLstPtrTable_Proj_Krauser_KaiserWaveD)		; iOBJInfo_OBJLstPtrTbl_Low
				inc  hl
				ld   [hl], HIGH(OBJLstPtrTable_Proj_Krauser_KaiserWaveD)	; iOBJInfo_OBJLstPtrTbl_High
				inc  hl
				ld   [hl], $00	; iOBJInfo_OBJLstPtrTblOffset
				
				; Set priority value
				ld   hl, iOBJInfo_Play_Priority
				add  hl, de
				ld   [hl], $04
				
			.setCodePtr:
				; Set code pointer
				ld   hl, iOBJInfo_Play_CodeBank
				add  hl, de
				ld   [hl], BANK(ProjC_Horz)	; BANK $06 ; iOBJInfo_Play_CodeBank
				inc  hl
				ld   [hl], LOW(ProjC_Horz)		; iOBJInfo_Play_CodePtr_Low
				inc  hl
				ld   [hl], HIGH(ProjC_Horz)	; iOBJInfo_Play_CodePtr_High
				
				; Set animation speed.
				ld   hl, iOBJInfo_FrameLeft
				add  hl, de
				ld   [hl], $00	; iOBJInfo_FrameLeft
				inc  hl
				ld   [hl], ANIMSPEED_INSTANT	; iOBJInfo_FrameTotal
				
				; Set initial position relative to the player's origin
				call OBJLstS_Overlap
				mMvC_SetMoveH +$1000
				mMvC_SetMoveV -$0800
				
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
			ld   hl, +$0180
			jp   .setSpeed
		.fldHeavy:
			ld   hl, +$0300
			jp   .setSpeed
		.fldHeavyMaxPow:
			ld   hl, +$0500
		.setSpeed:
			call Play_OBJLstS_SetSpeedH_ByXFlipR
		pop  de
	pop  bc
	ret
	
; =============== MoveC_Geese_ThrowG ===============
; Move code for Geese's throw (MOVE_SHARED_THROW_G).
MoveC_Geese_ThrowG:
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
	jp   z, .setDamage
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim
; --------------- frame #0 ---------------
; Set rot frame when switching to #1
.obj0:
	mMvC_ValFrameEnd .anim
	mMvC_SetDamage $06, HITTYPE_THROW_ROTL, PF3_HEAVYHIT
	mMvC_MoveThrowOp -$04, -$20 ; 4px left, $20px up
	jp   .anim
; --------------- frame #1 ---------------
; Set rot frame when switching to #2
.obj1:
	mMvC_ValFrameEnd .anim
	mMvC_SetDamage $06, HITTYPE_THROW_ROTL, PF3_HEAVYHIT
	mMvC_MoveThrowOp $04, -$20 ; 4px right (reset), $20px up
	jp   .anim
; --------------- frame #2 ---------------
; Deal damage when switching to #3
; (between #3-6 Geese arms move)
.setDamage:
	mMvC_ValFrameEnd .anim
	mMvC_SetDamageNext $06, HITTYPE_THROW_END, PF3_HEAVYHIT
	jp   .anim
; --------------- frame #6 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
	mMvC_EndThrow
	jr   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Krauser_ThrowG ===============
; Move code for Krauser's throw (MOVE_SHARED_THROW_G).
MoveC_Krauser_ThrowG:
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
	jp   z, .setDamage1
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage2
	jp   .anim ; We never get here
; --------------- frame #0 ---------------
.obj0:
	; Set rotation frame when switching to #1
	mMvC_ValFrameEnd .anim
	mMvC_SetDamage $06, HITTYPE_THROW_ROTL, PF3_HEAVYHIT
	mMvC_MoveThrowOp +$04, -$20

	jp   .anim
; --------------- frame #1 ---------------
.obj1:
	; Set rotation frame when switching to #2
	mMvC_ValFrameEnd .anim
	mMvC_SetDamage $06, HITTYPE_THROW_ROTL, PF3_HEAVYHIT
	mMvC_MoveThrowOp +$04, -$21

	jp   .anim
; --------------- frame #2 ---------------
.obj2:
	; Set rotation frame when switching to #3
	mMvC_ValFrameEnd .anim
	mMvC_SetDamage $06, HITTYPE_THROW_ROTD, PF3_HEAVYHIT
	mMvC_MoveThrowOp -$10, -$01

	jp   .anim
; --------------- frame #3 ---------------
.setDamage1:
	mMvC_ValFrameEnd .anim
	;--
	; [POI] This does nothing because Krauser's animation uses the same sprite mappings for #3 and #4.
	;       The pending damage values are copied in VBlank when GFX are loaded, when but the GFX loading 
	;       is skipped they neglect to copy over the move damage fields.
	;       Because of this, the logic for #4 manually updates the *current* move damage fields
	;       as soon as possible.
	mMvC_SetDamageNext $06, HITTYPE_DROP_DB_A, PF3_HEAVYHIT
	;--	
	
	jp   .anim
; --------------- frame #4 ---------------
.setDamage2:
	; The first time we get here, damage the opponent
	mMvC_ValFrameStart .chkEnd
	mMvC_SetDamage $06, HITTYPE_DROP_DB_A, PF3_HEAVYHIT
.chkEnd:
	; End the move when switching to #4
	mMvC_ValFrameEnd .anim
	mMvC_EndThrow
	jr   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_MrBig_ThrowG ===============
; Move code for Mr.Big's throw (MOVE_SHARED_THROW_G).
MoveC_MrBig_ThrowG:
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .rotU
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .rotL
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage
	jp   .anim ; We never get here
; --------------- frame #0 ---------------
.rotU:
	mMvC_ValFrameStart .obj0_anim
	
	mMvC_SetDamage $06, HITTYPE_THROW_ROTU, PF3_HEAVYHIT
	
	mMvC_MoveThrowOp -$10, -$10

.obj0_anim:
	jp   .anim
; --------------- frame #1 ---------------
.rotL:
	mMvC_ValFrameStart .obj1_anim
	
	mMvC_SetDamage $06, HITTYPE_THROW_ROTL, PF3_HEAVYHIT
	
	mMvC_MoveThrowOp +$04, -$20

.obj1_anim:
	jp   .anim
; --------------- frame #2 ---------------
.setDamage:
	mMvC_ValFrameStart .chkEnd
	
	mMvC_SetDamage $06, HITTYPE_THROW_END, PF3_HEAVYHIT
	
	mMvC_MoveThrowOp +$04, -$20

.chkEnd:
	mMvC_ValFrameEnd .anim
	mMvC_EndThrow
	jr   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Iori_ThrowG ===============
; Move code for Iori's throw (MOVE_SHARED_THROW_G).
MoveC_Iori_ThrowG:
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
; --------------- frame #0,#2 ---------------
	jp   .anim
; --------------- frame #1 ---------------
; When switching to #2, deal damage.
.setDamage:
	mMvC_ValFrameEnd .anim
	mMvC_SetDamageNext $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT
	jp   .anim
; --------------- frame #3 ---------------
; When attempting to switch to #4, end the move.
.chkEnd:
	mMvC_ValFrameEnd .anim
	mMvC_EndThrow
	jr   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Mature_ThrowG ===============
; Move code for Mature's throw (MOVE_SHARED_THROW_G).
MoveC_Mature_ThrowG:
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
	jp   z, .setDamage
	jp   .anim ; We never get here
; --------------- frame #0 ---------------
.rotU1:
	mMvC_ValFrameStart .rotU1_anim
	mMvC_SetDamage $06, HITTYPE_THROW_ROTU, PF3_HEAVYHIT
	mMvC_MoveThrowOp -$08, +$00
.rotU1_anim:
	jp   .anim
; --------------- frame #1 ---------------
.rotU2:
	mMvC_ValFrameStart .rotU2_anim
	mMvC_SetDamage $06, HITTYPE_THROW_ROTU, PF3_HEAVYHIT
	mMvC_MoveThrowOp +$04, +$00
.rotU2_anim:
	jp   .anim
; --------------- frame #2 ---------------
.setDamage:
	mMvC_ValFrameStart .chkEnd
	mMvC_SetDamage $06, HITTYPE_HIT_MULTI0, PF3_HEAVYHIT
.chkEnd:
	mMvC_ValFrameEnd .anim
	mMvC_EndThrow
	jr   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Chizuru_ThrowG ===============
; Move code for Chizuru's throw (MOVE_SHARED_THROW_G).
MoveC_Chizuru_ThrowG:
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .rotL
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .rotD
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .rotR
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage
	jp   .anim ; We never get here
; --------------- frame #0 ---------------
.rotL:
	mMvC_ValFrameStart .rotL_anim
	mMvC_SetDamage $06, HITTYPE_THROW_ROTL, PF3_HEAVYHIT
	mMvC_MoveThrowOp -$08, -$10
.rotL_anim:
	jp   .anim
; --------------- frame #1 ---------------
.rotD:
	mMvC_ValFrameStart .rotD_anim
	mMvC_SetDamage $06, HITTYPE_THROW_ROTD, PF3_HEAVYHIT
	mMvC_MoveThrowOp -$08, +$00
.rotD_anim:
	jp   .anim
; --------------- frame #2 ---------------
.rotR:
	mMvC_ValFrameStart .rotR_anim
	mMvC_SetDamage $06, HITTYPE_THROW_ROTR, PF3_HEAVYHIT
	mMvC_MoveThrowOp -$08, -$10
.rotR_anim:
	jp   .anim
; --------------- frame #3 ---------------
.setDamage:
	mMvC_ValFrameStart .chkEnd
	mMvC_SetDamage $06, HITTYPE_THROW_END, PF3_HEAVYHIT
.chkEnd:
	mMvC_ValFrameEnd .anim
	mMvC_EndThrow
	jr   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret

; =============== MoveC_Unused_ThrowG ===============	
; [TCRF] Unreferenced move code for a ground throw.
;        This is likely the original code Goenitz's ground throw, since he reuses MoveC_Goenitz_ShinyaotomeThrowL.
MoveC_Unused_ThrowG:
	call Play_Pl_IsMoveLoading
	jp   c, .ret
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .rotL
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .wait
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim
; --------------- frame #0 ---------------
.rotL:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $06, HITTYPE_THROW_ROTL, PF3_HEAVYHIT
		jp   .anim
; --------------- frame #1 ---------------
.setDamage:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamage $06, HITTYPE_THROW_END, PF3_HEAVYHIT
		jp   .anim
; --------------- frame #2 ---------------
.wait:
	mMvC_ValFrameEnd .anim
		jp   .anim
; --------------- frame #3 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		mMvC_EndThrow
		jr   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret  
	
IF REV_LANG_EN == 1
TextC_CutsceneGoenitz0E:
	db .end-.start
.start:
	db "So we meet at last.", C_NL
.end:
TextC_CutsceneGoenitz0F:
	db .end-.start
.start:
	db "Who are you?", C_NL
.end:
TextC_CutsceneGoenitz10:
	db .end-.start
.start:
	db "My name is Goenitz.", C_NL
.end:
TextC_CutsceneGoenitz11:
	db .end-.start
.start:
	db "I have watched your", C_NL
	db " progress with great", C_NL
	db " interest.", C_NL
	db " But it", C_NL
	db "      all ends here.", C_NL
.end:
TextC_CutsceneGoenitz12:
	db .end-.start
.start:
	db "I`ll let you decide.", C_NL
.end:
TextC_CutsceneGoenitz13:
	db .end-.start
.start:
	db "Would you rather", C_NL
	db " give up now, or", C_NL
	db " fight a hopeless", C_NL
	db " battle?", C_NL
.end:
TextC_CutsceneGoenitz14:
	db .end-.start
.start:
	db "Either way you`re", C_NL
	db " going to die!", C_NL
.end:
TextC_CutsceneGoenitz15:
	db .end-.start
.start:
	db "It`s not over yet,", C_NL
	db " Goenitz!", C_NL
	db "We`re going to", C_NL
	db "     fight and WIN!!", C_NL
.end:
ENDC

IF REV_VER_2 == 0
; =============== END OF BANK ===============
; Junk area below.
	mIncJunk "L097EA8"
ELSE
	mIncJunk "L097FEA"
ENDC