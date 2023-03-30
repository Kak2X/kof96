; =============== MoveC_Base_None ===============
; Temporary move used as default value when any move ends.
; If no new move is set the frame after the move ended, we get here. (ie: when defeating an opponent)
MoveC_Base_None:
	; [POI] Completely pointless code that does nothing.
	ld   hl, iPlInfo_IntroMoveId
	add  hl, bc
	ld   a, [hl]
	or   a
	jr   z, .ret
	jp   .ret
.unused: ; [TCRF] Unreferenced code
	call Play_Pl_EndMove
.ret:
	ret
	
; =============== MoveC_Base_Idle ===============
; Simple move code handler that doesn't allow box overlapping.
MoveC_Base_Idle:
	call Play_Pl_MoveByColiBoxOverlapX
	call OBJLstS_DoAnimTiming_Loop_by_DE
	ret
; =============== MoveC_Base_WalkH ===============
; Like MoveC_Base_Idle, but allowing horizontal movement.
; Used for walking horizontally.
MoveC_Base_WalkH:
	call Play_Pl_MoveByColiBoxOverlapX
	call OBJLstS_ApplyXSpeed
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
	
; =============== MoveC_Base_NoAnim ===============
; Like MoveC_Base_Idle, but without animating the player.
; Used when crouching or blocking, which don't animate the player.
MoveC_Base_NoAnim:
	call Play_Pl_MoveByColiBoxOverlapX
	ret
	
; =============== MoveC_Base_ChargeMeter ===============
; Custom code for charging meter (MOVE_BASE_CHARGEMETER).
MoveC_Base_ChargeMeter:
	call Play_Pl_MoveByColiBoxOverlapX	; Prevent box overlap
	mMvC_ValLoaded .ret						; If so, return
.main:

	;
	; Force the player to charge until visibly reaching the target animation frame.
	;
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]			; A = Sprite mapping ID
	mMvC_ChkTarget .chkEnd ; Did we reach the target ID? ; If so, jump
	; Otherwise, wait and continue animating
	jp   .anim
	
.chkEnd:

	;
	; Check if the charge is ending.
	;
	
	; Syncronize to end of anim frame
	mMvC_ValFrameEnd .anim
	
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
	jp   z, .anim		; If not, jump
.end:
	; If we got here, the charge is over
	call Play_Pl_EndMove
	jp   .ret
.anim:
	; Continue animating it, which means the anim can restart
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Base_RunF ===============
; Custom code for running forwards (MOVE_SHARED_RUN_F).
MoveC_Base_RunF:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	;
	; Play the step SFX once every couple of frames.
	; Which means, when about to increase the sprite mapping ID.
	;
.chkPlaySFX:	
	mMvC_ValFrameEnd .chkEnd

	; Only when starting frame #1
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE	; About to display #0?
	jp   z, .chkEnd					; If so, skip
	cp   $02*OBJLSTPTR_ENTRYSIZE	; About to display #2?
	jp   z, .chkEnd					; If so, skip

	; Daimon uses its own SFX when running.
	ld   hl, iPlInfo_CharId
	add  hl, bc
	ld   a, [hl]
	cp   CHAR_ID_DAIMON		; iPlInfo_CharId == CHAR_ID_DAIMON?
	jp   z, .daimon			; If so, jump
.norm:
	ld   a, SFX_STEP		; A = Default step SFX
	jp   .playSFX
.daimon:
	ld   a, SFX_STEP_HEAVY	; A = Step SFX for Daimon
.playSFX:
	call HomeCall_Sound_ReqPlayExId	; Play that
	
.chkEnd:
	;
	; The player needs to hold forward to continue running.
	; Use Play_Pl_GetDirKeys_ByXFlipR to get d-pad keys relative to the 1P side.
	;
	call Play_Pl_AddToJoyBufKeysLH		; Did we just press A or B?
	jp   c, .end						; If so, stop running
	call Play_Pl_GetDirKeys_ByXFlipR	; Holding any key in the d-pad?
	jp   nc, .end						; If not, stop running
	bit  KEYB_UP, a						; Starting a running jump?
	jp   nz, .end						; If so, stop running
	bit  KEYB_RIGHT, a					; Holding forward?
	jp   nz, .anim						; If so, continue running. 
.end:
	; We're done running
	call Play_Pl_EndMove
	
	;--
	; iPlInfo_MoveId is set back to MOVE_SHARED_RUN_F to potentially notify 
	; BasicInput_StartJump that we just ended running (a jump was input while running, causing the run to end).
	;
	; When we originally get here, basic inputs are disabled, so execution can't get to BasicInput_StartJump.
	; After calling Play_Pl_EndMove, that is no longer the case. If the next frame we're still holding up,
	; execution will reach BasicInput_StartJump.
	; Other than that, setting iPlInfo_MoveId to anything after calling Play_Pl_EndMove doesn't matter,
	; since the basic input handler will always set a new move ID.
	ld   hl, iPlInfo_MoveId
	add  hl, bc
	ld   a, MOVE_SHARED_RUN_F
	ld   [hl], a
	;--
	jr   .ret
.anim:
	; Continue running forward
	call OBJLstS_ApplyXSpeed
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Base_DashB ===============
; Custom code for dashing backwards (MOVE_SHARED_HOP_B).
MoveC_Base_DashB:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .initJump
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .moveDown
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .moveDown ; We never get here
	
; [TCRF] Unreferenced code to enable manual control.
;        Not needed, since the move animation for the dash already has that set.
.unused_setManualCtrl:
	ld   hl, iOBJInfo_FrameTotal
	add  hl, de
	ld   [hl], ANIMSPEED_NONE
	jp   .anim
	
;
; In practice:
; - The first time we get here, we initialize the jump speed
; - The second we request a switch to the next frame
; - From the third we do the same thing, waiting until the graphics are loaded.
;   Once they are, the second frame is set to skip directly to the gravity code.
;
; Gravity is always applied every time.
;
; --------------- frame #0 ---------------
.initJump:
	; Initialize the jump speed the first time we get here.
	; From the next, only perform the check to switch to the next frame.
	ld   hl, iOBJInfo_Status
	add  hl, de
	bit  OSTB_GFXNEWLOAD, [hl]	; Is this the first time we get here?
	jp   z, .waitUp				; If not, jump
.firstInit:
	; Set jump left 3px/frame
	mMvC_SetSpeedH -$0300				
	; Set jump up 3px/frame 
	mMvC_SetSpeedV -$0300
	; Already start applying gravity, which will cause OBJLstS_ReqAnimOnGtYSpeed to immediately
	; request a frame switch as we'll already be moving > -3px/frame.
	jp   .moveDown
.waitUp:
	mMvC_NextFrameOnGtYSpeed -$03, ANIMSPEED_NONE
	; Apply gravity
	jp   .moveDown
; --------------- common frames #0-1 ---------------
.moveDown:
	; Move down 0.6px/frame
	mMvC_ChkGravityHV $0060, .anim				; If not, jump
	; Otherwise, request the next frame to load as soon as possible
	mMvC_SetLandFrame $02*OBJLSTPTR_ENTRYSIZE, ANIMSPEED_INSTANT
	jp   .ret
; --------------- frame #2 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
	call Play_Pl_EndMove
	jr   .ret
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Base_NormA ===============
; Custom code for most air normals. Most characters use this for air punches, air kicks and air A+Bs.
MoveC_Base_NormA:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .move
	
	;
	; Moves using this have a timing sequence where the first frames have different anim speed values.
	; The game then stays on frame #3 until landing on the ground, where it will jump to the landing frame (#4).
	;
	; Since the first frames also execute code for #3, if the player lands on the ground even before
	; reaching frame #3, it will skip directly to #4.
	;
	
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
	jp   .move
	
; Update speed for every frame
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameEnd .move
	mMvC_SetAnimSpeed $12
	jp   .move
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameEnd .move
	mMvC_SetAnimSpeed $03
	jp   .move
; --------------- frame #2 ---------------
; Manual control for #3, as it ends only when touching the ground
.obj2:
	mMvC_ValFrameEnd .move
	mMvC_SetAnimSpeed ANIMSPEED_NONE
	jp   .move
; --------------- common frames #0-3 ---------------
.move:
	; Gradually decrease the vertical speed originally set by the jump move
	mMvC_ChkGravityHV $0060, .anim						; If not, jump
	
	; Otherwise, switch to the landing frame.
	
	; Like with the jump move, allow starting specials when landing
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	res  PF1B_NOSPECSTART, [hl]
	
	; Switch to #4 and stay there for the least possible time
	mMvC_SetLandFrame $04*OBJLSTPTR_ENTRYSIZE, ANIMSPEED_INSTANT
	jp   .ret
	
; --------------- frame #4 ---------------
; Wait for the animation to advance before ending the move.
.chkEnd:
	mMvC_ValFrameEnd .anim
	call Play_Pl_EndMove
	jr   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Base_BlockA ===============
; Custom code for air blocking (MOVE_SHARED_BLOCK_A).
; This move starts out with manual control.
MoveC_Base_BlockA:
	call Play_Pl_MoveByColiBoxOverlapX	; Prevent box overlap
	mMvC_ValLoaded .move						; If so, jump
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE	; Use the first frame in the air
	jp   z, .move
	cp   $01*OBJLSTPTR_ENTRYSIZE	; Use the second when landing
	jp   z, .landed
	jp   .move ; We never get here
	
; --------------- frame #0 ---------------
.move:
	; Continue jump arc
	mMvC_ChkGravityHV $0060, .anim				; Did we land? If not, jump
	
	; Switch to the next frame
	mMvC_SetLandFrame $01*OBJLSTPTR_ENTRYSIZE, ANIMSPEED_INSTANT
	
	; We're not guarding anymore once we land
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	res  PF1B_GUARD, [hl]
	jp   .ret

; --------------- frame #1 ---------------
.landed:
	mMvC_ValFrameEnd .anim
	call Play_Pl_EndMove
	jr   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:;
	ret
	
; =============== MoveC_Base_NormL ===============
; Generic move code used for most light normals.
MoveC_Base_NormL:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	;
	; If we're pressing/holding a new attack key, speed up
	; the rest of the animation as much as possible.
	; This is to allow "interrupting" the light attack with something else (another normal, or special).
	;
	; Something similar also happens in .obj1, except it
	; also makes the animation immediately jump to its last frame.
	;
	call Play_Pl_AddToJoyBufKeysLH	; Pressed any new LH button?
	jp   nc, .chkAnim				; If not, skip
	ld   hl, iOBJInfo_FrameLeft
	add  hl, de
	ld   [hl], $00
	mMvC_SetAnimSpeed ANIMSPEED_INSTANT
	
.chkAnim:
	;--
	; [POI] We already checked this
	mMvC_ValLoaded .ret
	;--
	
	; Depending on the visible sprite...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj0
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
; --------------- frames #2-(end) ---------------
.obj2x:
	mMvC_ChkTarget_jr .chkEnd
	jr   .anim
; --------------- frame #0 ---------------
; Play a SGB/DMG SFX when switching to #1.
.obj0:
	mMvC_ValFrameEnd .anim
	ld   a, SCT_LIGHT
	call HomeCall_Sound_ReqPlayExId
	jp   .anim
; --------------- frame #1 ---------------
; When switching to frame #2, check if we're pressing any punch/kick button.
; If so, make the animation immediately jump to its last frame.
.obj1:

	; If not switching yet, continue
	mMvC_ValFrameEnd .anim
	
	; If we aren't pressing a punch/kick button, continue
	ld   hl, iPlInfo_JoyBufKeysLH
	add  hl, bc
	ld   a, [hl]
	and  a, KEP_A_LIGHT|KEP_B_LIGHT|KEP_A_HEAVY|KEP_B_HEAVY
	jr   z, .anim
		
	; Speed up the rest of the anim as much as possible
	; and make the next frame start immediately.
	ld   hl, iOBJInfo_FrameLeft
	add  hl, de
	ld   [hl], $00
	mMvC_SetAnimSpeed ANIMSPEED_INSTANT
	
	; iOBJInfo_OBJLstPtrTblOffset = iPlInfo_OBJLstPtrTblOffsetMoveEnd - 4.
	; Because iOBJInfo_FrameLeft was just set to $00, the animation function
	; will advance iOBJInfo_OBJLstPtrTblOffset by 4, making it reach the target sprite.
	; Of course the graphics still have to load for .chkEnd to be reached.
	ld   hl, iPlInfo_OBJLstPtrTblOffsetMoveEnd
	add  hl, bc
	ld   a, [hl]						; A = iPlInfo_OBJLstPtrTblOffsetMoveEnd - 4
	sub  a, $01*OBJLSTPTR_ENTRYSIZE
	ld   hl, iOBJInfo_OBJLstPtrTblOffset
	add  hl, de							
	ld   [hl], a						; iOBJInfo_OBJLstPtrTblOffset = A
	jr   .anim
; --------------- common ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
	call Play_Pl_EndMove
	jr   .ret
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Base_NormH ===============
; Generic move code used for most heavy normals & taunting.
; Like MoveC_Base_Idle, except it ends the move (early) when the target frame is reached.
MoveC_Base_NormH:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Only check when the frame is about to switch, before the
	; graphics for the next one start loading.
	mMvC_ValFrameEnd .anim
	ld   hl, iOBJInfo_OBJLstPtrTblOffset
	add  hl, de			
	ld   a, [hl]							; A = Internal frame ID
	ld   hl, iPlInfo_OBJLstPtrTblOffsetMoveEnd
	add  hl, bc								; HP = Ptr to target frame ID
	cp   a, [hl]							; Do they match?
	jr   nz, .anim							; If not, jump
	; Otherwise, we're done
	call Play_Pl_EndMove
	jr   .ret
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
; =============== MoveC_Base_Roll ===============
; Custom code for rolling. (MOVE_SHARED_ROLL_F, MOVE_SHARED_ROLL_B)
MoveC_Base_Roll:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE	; Init
	jp   z, .obj0
	cp   $03*OBJLSTPTR_ENTRYSIZE	; Switch to recover
	jp   z, .obj3
	cp   $04*OBJLSTPTR_ENTRYSIZE	; Recovery/end
	jp   z, .obj4
	; Just continue moving in frames #1 & #2
	jp   .move
	
; --------------- frame #0 ---------------
.obj0:
	; Determine the roll direction/speed the first time we get here.
	; From the second time on, just continue moving.
	ld   hl, iOBJInfo_Status
	add  hl, de
	bit  OSTB_GFXNEWLOAD, [hl]	; First time?
	jp   z, .obj0_move			; If not, skip ahead
.chkDir:
	; Check roll direction depending on the move we're in
	ld   hl, iPlInfo_MoveId
	add  hl, bc
	ld   a, [hl]			
	cp   MOVE_SHARED_ROLL_F	; Rolling forwards?
	jp   z, .initRollF		; If so, jump
	cp   MOVE_SHARED_ROLL_B	; Rolling backwards?
	jp   z, .initRollB		; If so, jump
.initRollF:
	; Determine how much speed we're getting.
	; Normal rolls (iPlInfo_RunningJump == 0) move you at 2px/frame.
	; Guard cancel rolls (iPlInfo_RunningJump == 1) move you at 2.5px/frame.
	ld   hl, iPlInfo_RunningJump
	add  hl, bc
	ld   a, [hl]			; A = iPlInfo_RunningJump
	or   a					; A != 0?
	jp   nz, .initRollFGc	; If so, jump
.initRollFNorm:
	ld   hl, $0200 ; 2px/frame forward
	jp   .setInitialSpeed
.initRollFGc:
	ld   hl, $0280 ; 2.5px/frame forward
	jp   .setInitialSpeed
.initRollB:
	; Like with the forward roll, but with negative speed to move left (relative to the 1P side).
	ld   hl, iPlInfo_RunningJump
	add  hl, bc
	ld   a, [hl]
	or   a
	jp   nz, .initRollBGc
.initRollBNorm:
	ld   hl, -$0200 ; 2px/frame backwards
	jp   .setInitialSpeed
.initRollBGc: 
	ld   hl, -$0280 ; 2.5px/frame backwards
	jp   .setInitialSpeed
.setInitialSpeed:
	call Play_OBJLstS_SetSpeedH_ByXFlipR
.obj0_move:
	jp   .move
	
; --------------- frame #3 ---------------
; Switch to recovery.
.obj3:
	; Slow down the animation speed from 2 to 4 when about to recover from the roll.
	mMvC_ValFrameEnd .move
	mMvC_SetAnimSpeed $04
	jp   .move
	
; --------------- frame #4 ---------------
; Recovery.
.obj4:
	; The first time we get here determine 
	ld   hl, iOBJInfo_Status
	add  hl, de
	bit  OSTB_GFXNEWLOAD, [hl]	; First time?
	jp   z, .chkEnd				; If not, skip ahead
	
	; Since we're ending the roll,
	; reset different flags depending on its type
	ld   hl, iPlInfo_RunningJump
	add  hl, bc
	ld   a, [hl]
	or   a					; Did a guard cancel roll?
	jp   z, .obj4_noRunJump	; If not, jump
.obj4_runJump:
	; Guard cancel roll.
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	res  PF0B_SUPERMOVE, [hl]	; Stop flashing
	inc  hl						; Seek to iPlInfo_Flags1
	res  PF1B_NOSPECSTART, [hl]	; Allow starting specials again
	; Note this doesn't clear PF2B_NOHURTBOX or PF2B_NOCOLIBOX.
	; This makes the guard cancel roll invulnerable even during its recovery.
	jp   .resetHSpeed
.obj4_noRunJump:
	; While in a standard roll, the player can be hit out of that.
	ld   hl, iPlInfo_Flags2
	add  hl, bc
	res  PF2B_NOHURTBOX, [hl]
	res  PF2B_NOCOLIBOX, [hl]
.resetHSpeed:
	; Stop horizontal movement
	mMvC_SetSpeedH $0000
.chkEnd:
	; Wait for the sprite mapping ID to advance before ending the move
	mMvC_ValFrameEnd .anim
	call Play_Pl_EndMove
	jr   .ret
	
; --------------- common ---------------
.move:
	call OBJLstS_ApplyXSpeed
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Base_RoundStart ===============
; Custom code for moves used when the round starts (MOVE_SHARED_INTRO, MOVE_SHARED_INTRO_SPEC).
MoveC_Base_RoundStart:
	; MAI has her own timing sequence
	ld   hl, iPlInfo_CharId
	add  hl, bc
	ld   a, [hl]
	cp   CHAR_ID_MAI
	jp   z, MoveC_Base_RoundStart_Mai

	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible sprite...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de		
	ld   a, [hl]	; A = Visible sprite mapping ID
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .initAnimSpeed
	
; --------------- frames #1-(end) ---------------	
	; Check if we can end the move when the target ID is reached
	mMvC_ChkTarget .chkEnd
	jp   .anim		; Otherwise, just animate normally
	
; --------------- frame #0 ---------------
.initAnimSpeed:
	; Set the animation speed when about to switch to frame #1
	mMvC_ValFrameEnd .anim
	
	; These characters use speed $02 from the second frame.
	; Everyone else keeps their existing speed settings.
	ld   hl, iPlInfo_CharId
	add  hl, bc
	ld   a, [hl]
	cp   CHAR_ID_ATHENA
	jp   z, .spdFast
	cp   CHAR_ID_LEONA
	jp   z, .spdFast
	cp   CHAR_ID_OLEONA
	jp   z, .spdFast
	cp   CHAR_ID_IORI
	jp   z, .spdFast
	cp   CHAR_ID_OIORI
	jp   z, .spdFast
	cp   CHAR_ID_KRAUSER
	jp   z, .spdFast
	cp   CHAR_ID_MRKARATE
	jp   z, .spdFast
	jp   .anim
.spdFast:
	ld   a, $02		; A = Anim speed
	jp   .setSpeed
; [TCRF] Unreferenced speed setting.
.unused_spdSlow:
	ld   a, $03		; A = Anim speed
.setSpeed:
	ld   hl, iOBJInfo_FrameTotal
	add  hl, de
	ld   [hl], a	; Save it
	jp   .anim
; --------------- end ---------------	
.chkEnd:
	; End the move when the animation advances
	mMvC_ValFrameEnd .anim
	call Play_Pl_EndMove
	jr   .ret
; --------------- common ---------------	
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Base_RoundStart_Mai ===============
; Mai's intro animation changes speed several times,
; which isn't handled by the normal move code.
MoveC_Base_RoundStart_Mai:
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
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj6
	cp   $07*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj7
.cmpTarget:
	; Check if we can end the move when the target ID is reached
	mMvC_ChkTarget .chkEnd
	jp   .anim		; Otherwise, just animate normally
; --------------- main ---------------	
.obj0:
	mMvC_ValFrameEnd .anim
	mMvC_SetAnimSpeed $1E
	jp   .anim
.obj1:
	mMvC_ValFrameEnd .anim
	mMvC_SetAnimSpeed $14
	jp   .anim
.obj2:
	mMvC_ValFrameEnd .anim
	mMvC_SetAnimSpeed ANIMSPEED_INSTANT
	jp   .anim
.obj6:
	mMvC_ValFrameEnd .anim
	mMvC_SetAnimSpeed $28
	jp   .anim
.obj7:
	mMvC_ValFrameEnd .anim
	mMvC_SetAnimSpeed $0A
	jp   .anim
; --------------- end ---------------	
.chkEnd:
	; End the move when the animation advances
	mMvC_ValFrameEnd .anim
	call Play_Pl_EndMove
	jr   .ret
; --------------- common ---------------	
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Base_WakeUp ===============
; Custom code for waking up (MOVE_SHARED_WAKEUP).
MoveC_Base_WakeUp:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; The move ends at the end of the second frame
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $01*OBJLSTPTR_ENTRYSIZE	; OBJLstId == 1?
	jp   z, .chkEnd					; If so, jump
	
; --------------- frame #0 ---------------
.obj0:
	ld   hl, iOBJInfo_Status
	add  hl, de
	bit  OSTB_GFXNEWLOAD, [hl]	; First time we get here?
	jp   z, .notFirst			; If not, skip
	; Allow cancelling wakeup into special
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	res  PF1B_NOSPECSTART, [hl]
.notFirst:
	jp   .anim
; --------------- frame #1 ---------------	
.chkEnd:
	; Special version of mMvC_EndMoveOnInternalFrameEnd here
	mMvC_ValFrameEnd .anim 		; About to advance the anim? If not, skip to .anim
	call MoveC_Base_WakeUp_End	; Otherwise, end the move
	jp   .ret					; And return
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
; =============== MoveC_Base_WakeUp_End ===============
; Ends the wake up animation, handling the switch to the dizzy state if needed.
MoveC_Base_WakeUp_End:
	call Play_Pl_IsDizzyNext	; Are we supposed to get dizzy when waking up?
	jp   z, .noDizzy			; If not, just end the wakeup move
.dizzy:							; Otherwise, setup dizzy move

	; Every time we get dizzy, increase its timer cap by 8.
	; This means the opponent needs to deal more damage to dizzy us again.
	; Also reset the dizzy progression timer to its cap.
	ld   hl, iPlInfo_DizzyProgCap
	add  hl, bc			; HL = Ptr to iPlInfo_DizzyProgCap
	ld   a, [hl]		; A = iPlInfo_DizzyProgCap + 8
	add  a, $08
	jp   nc, .setCap	; Did we overflow? If not, skip
	ld   a, $FF			; Otherwise, cap the timer at $FF, just in case (this can never happen though)
.setCap:
	ldd  [hl], a		; Save back updated cap, seek to iPlInfo_DizzyProg
	ldd  [hl], a		; Reset the dizzy timer as well, seek to iPlInfo_DizzyTimeLeft
	
	
	; Reset the countdown timer for exiting the dizzy state to $FF
	ld   a, $FF
	ldd  [hl], a		; iPlInfo_DizzyTimeLeft = 0, seel tp iPlInfo_Dizzy
	; Don't dizzy on the next drop to ground
	ld   [hl], $00		; iPlInfo_DizzyNext = 0
	
	; We can be throw immediately in the dizzy state
	ld   hl, iPlInfo_NoThrowTimer
	add  hl, bc
	ld   [hl], $00
	
	; Clear various flags
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	res  PF0B_AIR, [hl] ; Grounded while dizzy
	res  PF0B_PROJHIT, [hl] ; Remove the three projectile flags
	res  PF0B_PROJREM, [hl]
	res  PF0B_PROJREFLECT, [hl]
	inc  hl		; Seek to iPlInfo_Flags1
	set  PF1B_NOSPECSTART, [hl] ; Can't cancel dizzies into specials (and since the dizzy state is a move, can't start normals either)
	res  PF1B_HITRECV, [hl] ; Damage string ended
	res  PF1B_ALLOWHITCANCEL, [hl] ; Disable override
	res  PF1B_INVULN, [hl] ; Not invulnerable

IF REV_VER_2 == 1
	; Disable the forced dizzy as soon as we get up.
	; This works because these dizzies are used by moves that automatically knock down.
	ld   hl, iPlInfo_ForceDizzy
	add  hl, bc
	ld   [hl], $00
ENDC
	
	; New move
	ld   a, MOVE_SHARED_DIZZY
	call Pl_SetMove_StopSpeed
	ret
.noDizzy:
	call Play_Pl_EndMove
	ret
	
; =============== MoveC_Base_Dizzy ===============
; Custom code for the dizzy state (MOVE_SHARED_DIZZY).
MoveC_Base_Dizzy:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Decrement the dizzy countdown
	call Play_Pl_DecDizzyTime
	
	; End the move when the dizzy countdown timer elapses
	ld   hl, iPlInfo_DizzyTimeLeft
	add  hl, bc
	ld   a, [hl]
	or   a			; iPlInfo_DizzyTimeLeft == 0?
	jp   z, .end	; If so, jump

	; Play a SFX every time the animation internally switches to the next frame
	mMvC_ValFrameEnd .anim
	ld   a, SCT_DIZZY
	call HomeCall_Sound_ReqPlayExId
	jp   .anim
.end:
	call Play_Pl_EndMove
	jr   .ret
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== Play_Pl_DecDizzyTime ===============
; Decrements the dizzy countdown timer.
; This slowly decrements on its own, but it's possible to speed it up
; by mashing buttons.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
Play_Pl_DecDizzyTime:

IF REV_VER_2 == 1
	; If we're being forced into the dizzy state, there's no escape
	ld   hl, iPlInfo_ForceDizzy
	add  hl, bc
	ld   a, [hl]
	or   a			; iPlInfo_ForceDizzy != 0?
	ret  nz			; If so, return
ENDC

	; On time over, the dizzy state ends abruptly
	ld   a, [wRoundTime]
	or   a				; Is there time left?
	jp   nz, .chkCpu	; If so, jump
	; Otherwise, clear the countdown, which will end the move (see above)
	xor  a				
	ld   hl, iPlInfo_DizzyTimeLeft
	add  hl, bc
	ld   [hl], a		; iPlInfo_DizzyTimeLeft = 0
	jp   .ret
	
; --------------- start cpu check ---------------		
.chkCpu:
	; The CPU has its own logic for decrementing the countdown
	ld   hl, iPlInfo_Flags0
	add  hl, bc			; Seek to iPlInfo_Flags0
	bit  PF0B_CPU, [hl]	; Is this player a CPU?
	jp   z, .isHuman	; If not, jump
; --------------- .isCpu ---------------	
.isCpu:
	; The higher the difficulty is, the faster the CPU "mashes" buttons.
	;
	; Essentially, the game treats the CPU has having pressed a button when (wTimer & Mask != 0).
	; The logic is the same across all difficulties, but the mask isn't.
	; When the mask has more bits set, it increases the chance of decreasing
	; the dizzy countdown timer by 8 (.decTimerFast) instead of just 1 (.decTimerSlow).
	ld   a, [wDifficulty]
	cp   DIFFICULTY_EASY
	jp   z, .easy
	cp   DIFFICULTY_NORMAL
	jp   z, .normal
.hard:
	; On HARD, it's like NORMAL, except it's much more likely for the dizzy
	; to last 31 ($1F) frames since the bits for the upper nybble are all set.
	ld   a, [wTimer]
	and  a, $F0				; wTimer & $F0 != 0?
	jp   nz, .decTimerFast	; If so, jump
	jp   .decTimerSlow
.normal:
	; On NORMAL, dizzies may last anywhere between 31 ($1F) and 45 ($2D) frames.
	ld   a, [wTimer]
	and  a, $30				; wTimer & $30 != 0?
	jp   nz, .decTimerFast	; If so, jump
	jp   .decTimerSlow
.easy:
	; On EASY, the CPU doesn't mash buttons, since the result will always be 0.
	; The dizzy will last the full 4.2 or so seconds ($FF frames).
	ld   a, [wTimer]
	and  a, $00				; wTimer & $00 != 0?
	jp   nz, .decTimerFast	; If so, jump (impossible)
	jp   .decTimerSlow
; --------------- .isHuman ---------------	
.isHuman:
	; When the player is human-controlled, this is all under the player's control.
	; Any time a new key is pressed, the timer decrements by 8.
	; Otherwise, it's just by 1.
	ld   hl, iPlInfo_JoyNewKeys
	add  hl, bc
	ld   a, [hl]			; A = Newly pressed keys
	and  a, $FF^KEY_START	; Pressed anything except START?
	jp   nz, .decTimerFast	; If so, jump
	
; --------------- end cpu check ---------------	

.decTimerSlow:
	; On its own, decrement the timer once
	ld   hl, iPlInfo_DizzyTimeLeft
	add  hl, bc
	dec  [hl]	; iPlInfo_DizzyTimeLeft--
	;--
	; [POI] Not applicable, since we're using dec [hl] here
	jp   nc, .copypaste
	xor  a ; We never get here
.copypaste:
	;--
	jp   .ret
	
.decTimerFast:
	; Decrement the countdown by 8
	ld   hl, iPlInfo_DizzyTimeLeft
	add  hl, bc
	ld   a, [hl]		; A = iPlInfo_DizzyTimeLeft
	sub  a, $08			; A -= 8
	jp   nc, .saveTimer	; Did we underflow?
	xor  a				; If so, force it back to 0
.saveTimer:
	ld   [hl], a		; Save it back
.ret:
	ret
	
; =============== MoveC_Base_RoundEnd ===============
; Custom code for moves used when the round ends (MOVE_SHARED_WIN_A, MOVE_SHARED_WIN_B, MOVE_SHARED_LOST_TIMEOVER).
MoveC_Base_RoundEnd:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Ignore if not switching frames
	mMvC_ValFrameEnd .anim
	
	; Continue animating until we reach the target frame
	ld   hl, iOBJInfo_OBJLstPtrTblOffset
	add  hl, de
	ld   a, [hl]
	ld   hl, iPlInfo_OBJLstPtrTblOffsetMoveEnd
	add  hl, bc
	cp   a, [hl]
	jr   nz, .anim
	
	;
	; Terry's second win animation involves him throwing his hat.
	; Spawn the hat before killing the player task, if appropriate.
	;
	ld   hl, iPlInfo_MoveId
	add  hl, bc
	ld   a, [hl]
	cp   MOVE_SHARED_WIN_B	; Using the second win anim?
	jr   nz, .killTask			; If not, return
	ld   hl, iPlInfo_CharId
	add  hl, bc
	ld   a, [hl]
	cp   CHAR_ID_TERRY			; Playing as Terry?
	jr   nz, .killTask			; If not, jump
	
	call Play_SpawnTerryHat		; All OK, spawn the hat
.killTask:
	; End the move as normal, and kill its task.
	; This prevents the player from animating any further.
	call Play_Pl_EndMove
	call Task_RemoveCurAndPassControl
	jr   .ret ; We never get here, since the player task got destroyed
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== Play_SpawnTerryHat ===============
; Spawns Terry's hat for his second win animation.
; IN
; - DE: Ptr to the player wOBJInfo
Play_SpawnTerryHat:
	push bc
		push de
		
			; The hat is spawned relative to the player's location through OBJLstS_Overlap.
			; That subroutine wants the source (player wOBJInfo) to BC.
			push de
			pop  bc
			
			; DE = Ptr to wOBJInfo_TerryHat
			ld   de, wOBJInfo_TerryHat
			
			; Display the sprite
			ld   hl, iOBJInfo_Status
			add  hl, de
			ld   [hl], OST_VISIBLE
			
			; Use $80 as fixed tile ID base.
			; The hat tiles use IDs $84-$87 (represented as $04 & $06) in the sprite mapping.
			ld   hl, iOBJInfo_TileIDBase
			add  hl, de
			ld   [hl], $80
			
			; Set the code ptr for handling its animation
			ld   hl, iOBJInfo_Play_CodeBank
			add  hl, de	; Seek to iOBJInfo_Play_CodeBank
			ld   [hl], BANK(ExOBJ_TerryHat) ; BANK $02
			inc  hl	; Seek to iOBJInfo_Play_CodePtr_Low
			ld   [hl], LOW(ExOBJ_TerryHat)
			inc  hl	; Seek to iOBJInfo_Play_CodePtr_Low
			ld   [hl], HIGH(ExOBJ_TerryHat)
			
			; Set animation table
			ld   hl, iOBJInfo_BankNum
			add  hl, de
			ld   [hl], BANK(OBJLstPtrTable_TerryHat) ; BANK $01
			inc  hl	; Seek to iOBJInfo_OBJLstPtrTbl_Low
			ld   [hl], LOW(OBJLstPtrTable_TerryHat)
			inc  hl	; Seek to iOBJInfo_OBJLstPtrTbl_High
			ld   [hl], HIGH(OBJLstPtrTable_TerryHat)
			inc  hl	; Seek to iOBJInfo_OBJLstPtrTblOffset
			ld   [hl], $00	; Start from first sprite
			
			; Animate every 8 frames
			ld   hl, iOBJInfo_FrameLeft
			add  hl, de
			ld   [hl], $08
			inc  hl	; Seek to iOBJInfo_FrameTotal
			ld   [hl], $08
			
			; Set the hat's position relative to the player:
			; - $10px right
			; - $30px above
			call OBJLstS_Overlap		; Move on top of player
			ld   hl, +$1000				; Move $10px forward
			call Play_OBJLstS_MoveH_ByXFlipR
			ld   hl, -$3000				; Move $30px up
			call Play_OBJLstS_MoveV
			
			; Set throw speed arc:
			; - $10px forward
			; - $03px up
			ld   hl, +$0100
			call Play_OBJLstS_SetSpeedH_ByXFlipR
			ld   hl, -$0300
			call Play_OBJLstS_SetSpeedV
		pop  de
	pop  bc
	ret
	
; =============== ExOBJ_TerryHat ===============
; Animation code for Terry's hat.
; IN
; - DE: Ptr to wOBJInfo_TerryHat
ExOBJ_TerryHat:
	; Move horizontally
	call ExOBJS_Play_ChkHitModeAndMoveH
	; Move vertically
	mMvC_ChkGravityV $0030, .onFloor					; If so, jump
	; Continue spinning in the air
	call OBJLstS_DoAnimTiming_Loop_by_DE
	ret
.onFloor:
	; Stop movement and animation on the ground
	mMvC_SetSpeedH $0000
	mMvC_SetSpeedV $0000
	ret
	
; =============== ExOBJ_SuperSparkle ===============
; Animation code for the sparkle effect shown at the start of a move.
; IN
; - DE: Ptr to wOBJInfo_Pl*SuperSparkle
; - BC: Ptr to wPlInfo*+$200
ExOBJ_SuperSparkle:

	;
	; Continue animating the sparkle until the timer reaches 0.
	; As this is set to $14 by default, that's how long the sparkle plays.
	;
	; While the sparkle is active, the player is invulnerable.
	; This helps pulling off supers without getting immediately damaged,
	; especially if a guard cancel was performed.
	;
	
	ld   hl, iOBJInfo_Play_EnaTimer
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
;           Only used by Play_Pl_ChkHitstop, and it makes hitstop end early.
Play_Pl_DoHit:

	; For all intents and purposes Play_Pl_DoHit is a direct continuation of Play_Pl_SetHitType.
	; Set up everything, update counters, damage player, (...) if it's applicable.
	; A = HitEffect ID * 2
	call Play_Pl_SetHitType	; Did the opponent's attack make contact?
	jp   nc, .noHit			; If not, jump
	
	;
	; We got hit, so handle the hit effect (HitTypeC_*).
	;
	; This is move-like code executed once, when we get hit. Each type of hit has its own code.
	; Typically it handles the hitstun/blockstun effect (player shaking), hit sound effects, flashing and knockback speed (a backjump, usually).
	; If hitstun is actviated, the code takes exclusive control of the player task while it is active.
	;
	; They also switch to another, actual move to handle the "next"/"post-hitstun" part of the hit
	; so that it won't take exclusive control.
	; This move is almost always part of the third group of moves (MoveC_Hit_*).
	;
	; Before getting there, first perform some common tasks:
	;
	
	; Empty the pow meter in case we got hit out of a super
	push af
		call Play_Pl_EmptyPowOnSuperEnd
	pop  af
	
	; HITTYPE_DROP_SWOOPUP, HITTYPE_THROW_END and the throw parts do not increment the combo counter.
	cp   (HITTYPE_THROW_END-1)*2	; HitTypeId >= $0E?
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
	; If we didn't block the hit, we definitely got hit out of a special or super move.
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
	set  PF1B_HITRECV, [hl]
	
	;
	; Prevent cancelling out of hitstun.
	; (though there's a special override in PF1B_ALLOWHITCANCEL)
	;
	cp   HITTYPE_BLOCKED			; Are we in the blockstun anim?
	jp   z, .execCode				; If so, skip
	set  PF1B_NOSPECSTART, [hl]		; Otherwise, we got hit. Prevent specials from starting.
.execCode:
	;
	; Execute the code for the currently set Hit effect/type.
	;
	
	push bc
		; Index Play_HitTypePtrTable by HitTypeId
		ld   hl, Play_HitTypePtrTable	; HL = Ptr to start of table
		ld   b, $00		; BC = HitTypeId (* 2)
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
	; The opponent's attack whiffed.
	; If the opponent isn't in a damage string anymore, reset/hide the combo counter.
	;
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	bit  PF1B_HITRECV, [hl]				; Are we in a damage string?
	jp   nz, .end						; If so, skip
	ld   hl, iPlInfo_HitComboRecvSet	; Otherwise, reset hit counter
	add  hl, bc
	ld   [hl], $00
.end:
	xor  a	; C flag clear
	ret
	
Play_HitTypePtrTable:
	dw HitTypeC_Blocked
	dw HitTypeC_GuardBreakGround
	dw HitTypeC_GuardBreakAir
	dw HitTypeC_HitMid0
	dw HitTypeC_HitMid1
	dw HitTypeC_HitLow
	dw HitTypeC_DropCH
	dw HitTypeC_DropA
	dw HitTypeC_DropMain
	dw HitTypeC_Hit_Multi0
	dw HitTypeC_Hit_Multi1
	dw HitTypeC_Hit_MultiGS
	dw HitTypeC_Drop_DB_A
	dw HitTypeC_Drop_DB_G
IF REV_VER_2 == 1
	dw HitTypeC_Dizzy
ENDC
	dw HitTypeC_SwoopUp
	dw HitTypeC_Throw_End
	dw HitTypeC_ThrowStart
	dw HitTypeC_ThrowRotU
	dw HitTypeC_ThrowRotL
	dw HitTypeC_ThrowRotD
	dw HitTypeC_ThrowRotR

; =============== HitTypeC_Blocked ===============
; ID: HITTYPE_BLOCKED
;
; Hit effect used when blocking, called for every blocked hit.
; OUT
; - C: If set, hitstop should end early (if applicable)
HitTypeC_Blocked:
	;
	; Play a SGB/DMG SFX
	;
	; There's also a special sound if we're blocking during a special or super (autoblock).
	;
	ld   a, SCT_AUTOBLOCK		; A = SFX ID for special block
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	bit  PF0B_SPECMOVE, [hl]	; Doing a special move?
	jp   nz, .playSFX			; If so, jump
	bit  PF0B_SUPERMOVE, [hl]	; Doing a super move?
	jp   nz, .playSFX			; If so, jump
	ld   a, SCT_BLOCK			; A = SFX ID for normal block
.playSFX:
	call HomeCall_Sound_ReqPlayExId
	
	;
	; Set up the player variables before starting blockstun.
	;	
	
	; Confirm that we're blocking
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_GUARD, [hl]
	
	; Blocking a move prevents it from using its flashing effects, if any
	ld   hl, iPlInfo_Flags3
	add  hl, bc
	res  PF3B_FIRE, [hl]
	res  PF3B_SUPERALT, [hl]
	
	
	; Reset the frame timer to 5, which is used for timing the knockback (MOVE_SHARED_POST_BLOCKSTUN).
	; Reinitializing this while the knockback is being already executed effectively
	; extends the amount of time we stay in the knockback state.
	; (This won't be decremented until we get there because blockstun doesn't animate the player.)
	ld   hl, iOBJInfo_FrameLeft
	add  hl, de
	ld   [hl], $05
	
	; Can't guard cancel if not at MAX Power.
	; This isn't necessary though since the blockstun handler won't allow guard
	; danceling anyway without MAX power.
	ld   hl, iPlInfo_Pow
	add  hl, bc
	ld   a, [hl]				; A = Pow
	cp   PLAY_POW_MAX			; Are we at max power?
	jp   z, .doBlockStun		; If so, skip
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_NOSPECSTART, [hl]	; Otherwise, prevent starting specials while blocking
	
.doBlockStun:
	;
	; Perform the blockstun effect, and handle what happens once it ends.
	; Blockstun lasts until it either ends normally (nc) or we guard canceled (c).
	;
	call Play_Pl_DoBlockstun		; Did we start a move out of blockstun?
	jp   c, .retMoveStart			; If so, jump
	
	;
	; Considerably slow down if we aren't in the middle of the knockback move (read: still executing MOVE_SHARED_BLOCK_*).
	; Knockback affects the player's speed, so we don't want to mess with that.
	; In the case of ground blocking, we set up the knockback.
	;
	; This works because this subroutine is called for any blocked hit, but it
	; does *NOT* set the block move, as that's handled by the basic input handler.
	; That handler is only executed if there isn't a move in progress already.
	; Since we're setting MOVE_SHARED_POST_BLOCKSTUN if we're in one of the block moves,
	; it prevents executing the handler until knockback ends. If we hit the opponent quickly
	; enough, we'll be getting here with MOVE_SHARED_POST_BLOCKSTUN set, which falls down to .retMoveStart.
	;
	; Air blocking doesn't set a different move, so any hit slows down our descent.
	;
	call Play_Pl_MoveByColiBoxOverlapX
	ld   hl, iPlInfo_MoveId
	add  hl, bc					; HL = Ptr to iPlInfo_MoveId
	ld   a, [hl]				; A = MoveId
	
	; Ground blocks transition to MOVE_SHARED_POST_BLOCKSTUN
	cp   MOVE_SHARED_BLOCK_G	; Doing the neutral block?
	jp   z, .blockGround		; If so, jump
	cp   MOVE_SHARED_BLOCK_C	; Doing the crouch block?
	jp   z, .blockGround		; If so, jump
	; while air blocks continue as-is
	cp   MOVE_SHARED_BLOCK_A	; Doing the air block?
	jp   z, .blockGeneric		; If so, jump
	
	; We were on the ground and executed the slowdown logic already.
	; Skip to the end (with .retMoveStart).
	jp   .retMoveStart
	
.blockGround:
	; Directly switch to post ground blockstun move
	ld   [hl], MOVE_SHARED_POST_BLOCKSTUN
	jp   .retNoStart
.blockGeneric:
	; Delay the block as much as possible.
	; Especially important for air blocking, where we have to land on the ground first.
	ld   hl, iOBJInfo_FrameLeft
	add  hl, de
	ld   [hl], ANIMSPEED_NONE
	
	; Set the initial speed at $00.80px/frame forwards
	ld   hl, $0080
	call Play_OBJLstS_SetSpeedH_ByXDirL
	
	; Blocking an attack resets the vertical speed as long as we're moving down
	ld   hl, iOBJInfo_SpeedY
	add  hl, de
	ld   a, [hl]			; A = SpeedY
	bit  7, a				; SpeedY < 0? (MSB set, moving up)
	jp   nz, .retNoStart	; If so, skip
	ld   hl, $0000			; Otherwise, reset the vertical speed
	call Play_OBJLstS_SetSpeedV
	jp   .retNoStart
.retNoStart:
	scf		; C flag set
	ret
.retMoveStart:
	scf
	ccf		; C flag clear
	ret
	
; =============== HitTypeC_GuardBreakGround ===============
; ID: HITTYPE_GUARDBREAK_G
;
; Hit effet used when the player's guard breaks on the ground.
; OUT
; - C flag: Always clear (never end hitstop early)
HitTypeC_GuardBreakGround:

	; Stop the player from flashing
	ld   hl, iPlInfo_Flags3
	add  hl, bc
	res  PF3B_FIRE, [hl]
	res  PF3B_SUPERALT, [hl]
	
	; Play standard X break sound
	ld   a, SCT_BREAK
	call HomeCall_Sound_ReqPlayExId
	
	; Switch to the guard break move (also used on the receiving end of a throw tech)
	ld   a, MOVE_SHARED_GUARDBREAK_G
	call Pl_SetMove_ShakeScreenReset
	
	; Run gameplay at half speed for $0F frames, if possible
	ld   a, $0F
	call MoveS_ChkHalfSpeedHit
	
	; Flash the stage palette
	ld   a, $00
	ld   [wStageBGP], a
	
	; Perform hitstun effect
	call Play_Pl_DoHitstun
	
	; Don't allow overlapping collision boxes
	call Play_Pl_MoveByColiBoxOverlapX
	
	; [POI] When guard breaks at MAX Power, the POW bar empties itself.
	ld   hl, iPlInfo_Pow
	add  hl, bc
	ld   a, [hl]			; A = Pow
	cp   PLAY_POW_MAX		; Are we at max power?
	jp   nz, .retClear		; If not, skip
	ld   [hl], $00			; Otherwise, Pow = 0
.retClear:
	scf
	ret
	
; =============== HitTypeC_GuardBreakAir ===============
; ID: HITTYPE_GUARDBREAK_A
;
; Hit logic used when the player's guard breaks in the air.
; See also: HitTypeC_GuardBreakGround
;           Parts inside ## are different compared to that.
; OUT
; - C flag: Always clear (never end hitstop early)
HitTypeC_GuardBreakAir:
	; Stop the player from flashing
	ld   hl, iPlInfo_Flags3
	add  hl, bc
	res  PF3B_FIRE, [hl]
	res  PF3B_SUPERALT, [hl]
	
	; Play standard X break sound
	ld   a, SCT_BREAK
	call HomeCall_Sound_ReqPlayExId
	
	;##
	; Switch to the air guard break move
	ld   a, MOVE_SHARED_GUARDBREAK_A
	call Pl_SetMove_ShakeScreenReset
	
	; (No half speed)
	;##
	
	; Flash the stage palette
	ld   a, $00
	ld   [wStageBGP], a
	
	; Perform hitstun effect
	call Play_Pl_DoHitstun
	
	; Don't allow overlapping collision boxes
	call Play_Pl_MoveByColiBoxOverlapX
	
	;##
	; Move back at 0.5px/frame
	ld   hl, $0080
	call Play_OBJLstS_SetSpeedH_ByXDirL
	
	; Reset the vertical speed as long as we're moving down
	ld   hl, iOBJInfo_SpeedY
	add  hl, de
	ld   a, [hl]			; A = SpeedY
	bit  7, a				; SpeedY < 0? (MSB set, moving up)
	jp   nz, .chkEmptyPow	; If so, skip
	ld   hl, $0000			; Otherwise, reset the vertical speed
	call Play_OBJLstS_SetSpeedV
	;##
	
.chkEmptyPow:	
	; [POI] When guard breaks at MAX Power, the POW bar empties itself.
	ld   hl, iPlInfo_Pow
	add  hl, bc
	ld   a, [hl]			; A = Pow
	cp   PLAY_POW_MAX		; Are we at max power?
	jp   nz, .retClear		; If not, skip
	ld   [hl], $00			; Otherwise, Pow = 0
.retClear:
	scf
	ret
	
; =============== HitTypeC_HitGeneric group ===============
; These next few ones that call HitTypeC_HitGeneric are basically the same hit type,
; a generic hit that can be used by any type of move (normals, specials, supers).
; Even though they set different move IDs, they point to the same code.
;
; The only difference between these is the animation associated to the move, most
; obvious for MOVE_SHARED_HITLOW which has the player getting hit while crouching.
	
; =============== HitTypeC_HitMid0 ===============
; ID: HITTYPE_HIT_MID0
;
; Hit logic used for generic mid hit #0.
; OUT
; - C flag: Always set (ends hitstop)
HitTypeC_HitMid0:
	ld   a, MOVE_SHARED_HIT0MID
	jp   HitTypeC_HitGeneric
; =============== HitTypeC_HitMid1 ===============
; ID: HITTYPE_HIT_MID1
;
; Hit logic used for generic mid hit #1.
; OUT
; - C flag: Always set (ends hitstop)
HitTypeC_HitMid1:
	ld   a, MOVE_SHARED_HIT1MID
	jp   HitTypeC_HitGeneric
; =============== HitTypeC_HitLow ===============
; ID: HITTYPE_HIT_LOW
;
; Hit logic used for generic low hit.
; OUT
; - C flag: Always set (ends hitstop)
HitTypeC_HitLow:
	ld   a, MOVE_SHARED_HITLOW
	; Fall-through
; =============== HitTypeC_HitGeneric ===============
; Hit logic used for generic mid hit #0.
; IN
; - A: Move ID to set
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
; OUT
; - C flag: Always set (ends hitstop)	
HitTypeC_HitGeneric:

	; Play hit sound effect (normal or fire)
	push af	; Save MoveID
		call MoveS_PlayHitSFX

	; Switch to new move
	pop  af	; Restore MoveID
	call Pl_SetMove_ShakeScreenReset
	
	; Run gameplay at half speed for the next $0F frames, if applicable.
	; This will at least cover part of the hitstun effect.
	ld   a, $0F
	call MoveS_ChkHalfSpeedHit
	
	; Flash playfield if the hit came off a super move
	call Play_Pl_FlashPlayfieldOnSuperHit
	
	; Do the hitstun effect for multiple frames
	call Play_Pl_DoHitstun
	
	;
	; After the hitstun finishes
	;
	call Play_Pl_MoveByColiBoxOverlapX
	scf	; Return set
	ret
	
; =============== HitTypeC_DropMain ===============
; ID: HITTYPE_DROP_MAIN
;
; Hit effect that causes the player to drop on the ground.
; This is the standard generic drop that can be used by any move.
;
; Features:
; - Can optionally end a damage string
; - Gameplay runs at half speed for $1E frames
; - Supports super move playfield flashing
; - After hitstun ends, the player may optionally gets knock back with a backjump.
;   If the hit is considered "light", the player just falls (handled like the backjump, but with no vertical height)
; - Backjump height is high
; - The player can roll cancel when landing from the jump
; - Player can't recover mid-air
; - Can be used in the air or on the ground
; - Can be used when the player gets KO'd
; OUT
; - C flag: Always set (ends hitstop)
HitTypeC_DropMain:

	;
	; Invulnerability check.
	;
	; If the hit has PF3B_LASTHIT set, this will be the last one for the combo string.
	; This is accomplished by making the player invulnerable during the drop, preventing
	; further hits until waking up.
	; Additionally, also treat it as the end of a combo string if we got hit out of a special move.
	;
	
	; Special move check
	ld   hl, iPlInfo_Flags0
	add  hl, bc					; Seek to iPlInfo_Flags0
	bit  PF0B_SPECMOVE, [hl]	; Did we get hit while doing a special?
	jp   z, .chkDead			; If not, skip
	inc  hl						; Seek to iPlInfo_Flags1
	inc  hl						; Seek to iPlInfo_Flags2
	inc  hl						; Seek to iPlInfo_Flags3
	set  PF3B_HEAVYHIT, [hl]	; Shake longer (heavy hit)
	set  PF3B_LASTHIT, [hl]		; End the damage string (will trigger invulnerability shortly after)
	
.chkDead:
	; Ignore this if the player is already dead
	ld   hl, iPlInfo_Health
	add  hl, bc
	ld   a, [hl]				; A = Player Health
	ld   hl, iPlInfo_Flags0
	add  hl, bc					; HL = Ptr to iPlInfo_Flags0
	or   a						; iPlInfo_Health == 0?
	jp   z, .main				; If so, skip
	
	; Seek to damage flags
	inc  hl					; Seek to iPlInfo_Flags1
	inc  hl					; Seek to iPlInfo_Flags2
	inc  hl					; Seek to iPlInfo_Flags3
	
	; Enable invulnerability if the flag is set
	bit  PF3B_LASTHIT, [hl]	; Is the flag set?
	jp   nz, .main			; If so, skip
	dec  hl					; Seek back to iPlInfo_Flags2
	dec  hl					; Seek back to iPlInfo_Flags1
	set  PF1B_INVULN, [hl]	; Enable invulnerability
.main:
	;
	; Main hitstun part.
	;
	call MoveS_PlayHitSFX
	
	; Switch to default backjump move
	ld   a, MOVE_SHARED_DROP_MAIN
	call Pl_SetMove_ShakeScreenReset
	
	; Run gameplay at half speed for the next $1E frames, if applicable
	ld   a, $1E
	call MoveS_ChkHalfSpeedHit
	
	; Flash playfield if applicable
	call Play_Pl_FlashPlayfieldOnSuperHit
	
	; Do it
	call Play_Pl_DoHitstun
	
	; Once the hitstun is over, prevent the collision boxes from overlapping
	call Play_Pl_MoveByColiBoxOverlapX
	
	;
	; This knockback effect causes the player to optionally drop with a back jump.
	; Set the initial jump settings.
	;
	ld   hl, iPlInfo_Flags3
	add  hl, bc
	bit  PF3B_LIGHTHIT, [hl]	; Is this a light hit?
	jp   nz, .retSet			; If so, don't alter speed settings.
								; This will cause the player to just drop on the ground directly down.
								
	bit  PF3B_HEAVYHIT, [hl]	; Is this a heavy hit?
	jp   nz, .setJumpH			; If so, use higher jump speed
.setJumpN:
	; Normal hit
	ld   hl, +$0140				; 1.25px/frame back
	call Play_OBJLstS_SetSpeedH_ByXDirL
	ld   hl, -$0400				; 4px/frame up
	call Play_OBJLstS_SetSpeedV
	jp   .retSet
.setJumpH:
	; Heavy hit
	ld   hl, +$0180				; 1.5px/frame back
	call Play_OBJLstS_SetSpeedH_ByXDirL
	ld   hl, -$0600				; 6px/frame up
	call Play_OBJLstS_SetSpeedV
.retSet:
	scf	; C flag set
	ret
	
; =============== HitTypeC_Drop_DB_A ===============
; ID: HITTYPE_DROP_DB_A
;
; Hit effect that knocks the player on the ground from the air.
; Uses the same continuation code as the air throw, but this hit
; effect is *not* meant for them, as throws are handled in HITTYPE_THROW_END.
;
; Features:
; - Can optionally end a damage string
; - Supports super move playfield flashing
; - Normal hitstun time
; - Can only be used in the air
; - After hitstun ends, the player always gets thrown diagonally down backwards
; OUT
; - C flag: Always set (ends hitstop)
HitTypeC_Drop_DB_A:
	;
	; Invulnerability check.
	;
	; If the hit has PF3B_LASTHIT set, this will be the last one for the combo string.
	;
	
	; Ignore this if the player is already dead
	ld   hl, iPlInfo_Health
	add  hl, bc
	ld   a, [hl]				; A = Player Health
	ld   hl, iPlInfo_Flags0
	add  hl, bc					; HL = Ptr to iPlInfo_Flags0
	or   a						; iPlInfo_Health == 0?
	jp   z, .main				; If so, skip
	
	; Seek to damage flags
	inc  hl					; Seek to iPlInfo_Flags1
	inc  hl					; Seek to iPlInfo_Flags2
	inc  hl					; Seek to iPlInfo_Flags3
	
	; Enable invulnerability if the flag is set
	bit  PF3B_LASTHIT, [hl]	; Is the flag set?
	jp   nz, .main			; If so, skip
	dec  hl					; Seek back to iPlInfo_Flags2
	dec  hl					; Seek back to iPlInfo_Flags1
	set  PF1B_INVULN, [hl]	; Enable invulnerability
.main:
	; Play hit SFX, with fire support
	call MoveS_PlayHitSFX
	
	; This is like an air throw, so set this as continuation code
	ld   a, MOVE_SHARED_THROW_END_A
	call Pl_SetMove_ShakeScreenReset
	
	; Flash playfield if applicable
	call Play_Pl_FlashPlayfieldOnSuperHit
	
	; Do it
	call Play_Pl_DoHitstun
	
	; Once the hitstun is over, prevent the collision boxes from overlapping
	call Play_Pl_MoveByColiBoxOverlapX
	
	;
	; This knockback effect causes the player to drop diagonally down.
	;
	ld   hl, iPlInfo_Flags3
	add  hl, bc
	bit  PF3B_HEAVYHIT, [hl]	; Is this a heavy hit?
	jp   nz, .setJumpH			; If so, use higher jump speed
.setJumpL:
	ld   hl, +$0500				; 5px/frame back
	jp   .setJump
.setJumpH:
	ld   hl, +$0600				; 6px/frame back
.setJump:
	call Play_OBJLstS_SetSpeedH_ByXDirL
	
	ld   hl, $0600				; 6px/frame up
	call Play_OBJLstS_SetSpeedV

	scf	; C flag set
	ret
	
; =============== HitTypeC_Drop_DB_G ===============
; ID: HITTYPE_DROP_DB_G
;
; Hit effect that knocks the player on the ground, shaking it.
;
; Special move drop (Ground)
; Features:
; - Can optionally end a damage string
; - Supports super move playfield flashing
; - Very short hitstun time
; - Can only be used on the ground
; - After hitstun ends, the ground shakes.
; OUT
; - C flag: Always set (ends hitstop)
HitTypeC_Drop_DB_G:
	;
	; Invulnerability check.
	;
	; If the hit has PF3B_LASTHIT set, this will be the last one for the combo string.
	; This doesn't check if we died beforehand.
	;
	ld   hl, iPlInfo_Flags3
	add  hl, bc
	bit  PF3B_LASTHIT, [hl]	; Is the flag set?
	jp   nz, .main			; If so, skip
	dec  hl					; Seek back to iPlInfo_Flags2
	dec  hl					; Seek back to iPlInfo_Flags1
	set  PF1B_INVULN, [hl]	; Enable invulnerability
.main:
	; Play SFX, with fire effect if needed
	call MoveS_PlayHitSFX
	
	; Set the continuation for the hit, which is used after hitstun ends.
	; This shakes the ground.
	ld   a, MOVE_SHARED_DROP_DBG
	call Pl_SetMove_ShakeScreenReset
	
	; Flash playfield if applicable
	call Play_Pl_FlashPlayfieldOnSuperHit
	
	; Do the standard hitstun effect
	call Play_Pl_DoHitstunOnce
	
	; Once the hitstun is over, prevent the collision boxes from overlapping
	call Play_Pl_MoveByColiBoxOverlapX
	
	scf	; C flag set
	ret

IF REV_VER_2 == 1	
; =============== HitTypeC_Dizzy ===============
; ID: HITTYPE_DIZZY
;
; Hit effect for moves that manually deliver forced dizzies after hitstun.
; These are dizzies that the player can't escape from until he gets knocked down.
;
; Because of this, it's only used for special sequences by special moves that 
; guarantee that the player does get knocked down at the end, ending the dizzy state. 
HitTypeC_Dizzy:

	; Don't dizzy on the next drop to ground
	ld   hl, iPlInfo_DizzyNext
	add  hl, bc
	ld   [hl], $00
	; Reset the countdown timer for exiting the dizzy state to $FF
	ld   hl, iPlInfo_DizzyTimeLeft
	add  hl, bc
	ld   [hl], $FF
	
	; Mark that we're in the middle of the forced dizzy state.
	; This prevents the player from being able to escape.
	ld   hl, iPlInfo_ForceDizzy
	add  hl, bc
	ld   [hl], $01
	
	; Set the continuation for the hit, which is used after hitstun ends.
	; This is the standard dizzy effect.
	ld   a, MOVE_SHARED_DIZZY
	call Pl_SetMove_ShakeScreenReset
	
	; Flash playfield if applicable
	call Play_Pl_FlashPlayfieldOnSuperHit
	
	; Do it
	call Play_Pl_DoHitstun
	; Once the hitstun is over, prevent the collision boxes from overlapping
	call Play_Pl_MoveByColiBoxOverlapX
	scf  
	ret  
ENDC

; =============== HitTypeC_Throw_End ===============
; ID: HITTYPE_THROW_END
;
; Used as the last part of throws (including command throws).
;
; When a throw animation ends, it delivers a last hit with this type.
; This is where the player gets knocked back with a large backwards jump, away from the opponent,
; with the playfield shaking when touching the ground.
; Unlike others, there's no hitstun here since the jump should start immediately.
HitTypeC_Throw_End:
	;
	; Invulnerability check.
	;
	; If the hit has PF3B_LASTHIT set, this will be the last one for the combo string.
	;
	
	; Ignore this if the player is already dead
	ld   hl, iPlInfo_Health
	add  hl, bc
	ld   a, [hl]				; A = Player Health
	ld   hl, iPlInfo_Flags0
	add  hl, bc					; HL = Ptr to iPlInfo_Flags0
	or   a						; iPlInfo_Health == 0?
	jp   z, .main				; If so, skip
	
	; Seek to damage flags
	inc  hl					; Seek to iPlInfo_Flags1
	inc  hl					; Seek to iPlInfo_Flags2
	inc  hl					; Seek to iPlInfo_Flags3
	
	; Enable invulnerability if the flag is set
	bit  PF3B_LASTHIT, [hl]	; Is the flag set?
	jp   nz, .main			; If so, skip
	dec  hl					; Seek back to iPlInfo_Flags2
	dec  hl					; Seek back to iPlInfo_Flags1
	set  PF1B_INVULN, [hl]	; Enable invulnerability
.main:

	; Remove the physical damage source next frame.
	ld   hl, iPlInfo_PhysHitRecv
	add  hl, bc
	ld   [hl], $01
	
	; Switch to throw animation
	ld   a, MOVE_SHARED_THROW_END_G
	call Pl_SetMove_ShakeScreenReset
	
	;
	; Throw the player by updating its speed settings.
	;
	; Almost every move that uses this hits uses standard logic similar to other hit effects,
	; with the player being thrown away from the opponent with a jump arc, relative to his X 
	; position (using Play_OBJLstS_SetSpeedH_ByXDirL).
	;
	; However:
	; - Mai's ground throw throws the player forward from *behind*.
	;   This can't be done with Play_OBJLstS_SetSpeedH_ByXDirL, as the player would just
	;   move backwards.
	;   Because of the direction the player is facing, to move forwards he has to move back (-3px/frame).
	; - Mature's command throw (Decide) does the same thing, and throws the opponent at
	;   a very fast horizontal speed.
	;   It still looks like a forward throw, but that's only because the move animation
	;   was made to look like she's turning, while the actual sprite mapping flip flag
	;   is locked until the move ends as always.
	; 
	ld   hl, iPlInfo_CharIdOther
	add  hl, bc
	ld   a, [hl]
	cp   CHAR_ID_MATURE			; Opponent is Mature?
	jp   z, .chkMatureMove		; If so, jump
	cp   CHAR_ID_MAI			; Opponent is Mai?
	jp   z, .chkMaiMove			; If so, jump
	jp   .default				; Otherwise, use the default
.chkMatureMove:
	ld   hl, iPlInfo_MoveIdOther
	add  hl, bc
	ld   a, [hl]
	cp   MOVE_MATURE_DECIDE_L	; Using Decide?
	jp   z, .matureDecide		; If so, jump
	cp   MOVE_MATURE_DECIDE_H	; Using Decide?
	jp   z, .matureDecide		; If so, jump
	jp   .default				; Otherwise, use the default (we never get here)
.chkMaiMove:
	ld   hl, iPlInfo_MoveIdOther
	add  hl, bc
	ld   a, [hl]
	cp   MOVE_SHARED_THROW_G	; Doing Mai's ground throw?
	jp   z, .maiThrow			; If so, jump
	jp   .default				; Otherwise, use the default (we never get here)
.matureDecide:
	mMvC_SetSpeedH +$0900		; 9px/frame forward
	mMvC_SetSpeedV -$0400		; 4px/frame up (standard)
	jp   .retSet
.maiThrow:
	mMvC_SetSpeedH -$0300		; 3px/frame backwards
	mMvC_SetSpeedV -$0400		; 4px/frame up (standard)
	jp   .retSet
	
.default:
	;
	; Default knockback for most characters/moves.
	;
	; This is pretty much the same as many other knockback jumps.
	; This knockback effect causes the player to drop with a back jump, away from the opponent.
	; Set the initial jump settings.
	;
	ld   hl, iPlInfo_Flags3
	add  hl, bc							
	bit  PF3B_HEAVYHIT, [hl]	; Is this a heavy hit?
	jp   nz, .setJumpH			; If so, use higher jump speed
.setJumpN:
	; Normal hit
	ld   hl, +$0200				; 2px/frame back
	jp   .setJump
.setJumpH:
	; Heavy hit
	ld   hl, +$0300				; 3px/frame back
.setJump:
	call Play_OBJLstS_SetSpeedH_ByXDirL
	mMvC_SetSpeedV -$0400		; 4px/frame up
	
.retSet:
	scf	; C flag set
	ret
	
; =============== HitTypeC_SwoopUp ===============
; ID: HITTYPE_DROP_SWOOPUP
;
; This is used by hits that end up causing the player to move really high up, to off-screen above.
;
; There are two different kinds of hit types in this one:
; - Projectile-based. Used by Mature, O.Leona and Goenitz when they spawn a very tall projectile
;   that covers the entire playfield's height. The projectile hits the player and they get moved 
;   towards its center, then off-screen above.
;   These projectile hit multiple times, which will progressively decrease the gravity.
; - Physical throw. Used by Daimon for two of his command throws, that launch the opponent really high up.
;
; Their effect is the same, as they both set the move MOVE_SHARED_HIT_SWOOPUP: the player keeps moving up. It then starts falling down.
; As a side note, Daimon's super move animations are aligned to hit the player with a full width
; ground hitbox when the opponent hits the ground.
HitTypeC_SwoopUp:
	; There's special code for getting hit by Daimon
	ld   hl, iPlInfo_CharIdOther
	add  hl, bc
	ld   a, [hl]
	cp   CHAR_ID_DAIMON			; Did we get hit by Daimon?
	jp   nz, HitTypeC_SwoopUp_ToProj	; If not, jump
	
	
; =============== HitTypeC_SwoopUp_Daimon ===============
; Command throw version for Daimon.
HitTypeC_SwoopUp_Daimon:

	; Set continuation
	ld   a, MOVE_SHARED_HIT_SWOOPUP
	call Pl_SetMove_ShakeScreenReset
	
	; Push opponent in case we are cornered
	call Play_Pl_GiveKnockbackCornered
	
	; Make player invulnerable while this happens
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_INVULN, [hl]
	
	; The special and super move versions set a different throw speed.
	ld   hl, iPlInfo_MoveIdOther
	add  hl, bc
	ld   a, [hl]
	cp   MOVE_DAIMON_HEAVEN_HELL_DROP_S	; MoveId >= (super)?
	jr   nc, .setJumpS					; If so, jump
.setJumpN:
	; Special (Heaven Drop)
	mMvC_SetSpeedV -$0700	; 7px/frame up
	ld   hl, +$0300			; 3px/frame forward
	jp   .setJump
.setJumpS:
	; Super (Heaven to Hell Drop)
	; Used for the part where the player gets thrown up in the air, before causing the earthquake
	mMvC_SetSpeedV -$0C00	; 12px/frame up, very high up
	ld   hl, +$0200			; 2px/frame forward
.setJump:
	call Play_OBJLstS_SetSpeedH_ByXFlipR
	jp   HitTypeC_SwoopUp_RetSet	
	
; =============== HitTypeC_SwoopUp_ToProj ===============
; Projectile version for other characters.
HitTypeC_SwoopUp_ToProj:

	;--
	;
	; [POI] Pointless Invulnerability check, since we're always setting PF1B_INVULN later.
	;
	
	; Ignore this if the player is already dead
	ld   hl, iPlInfo_Health
	add  hl, bc
	ld   a, [hl]				; A = Player Health
	ld   hl, iPlInfo_Flags0
	add  hl, bc					; HL = Ptr to iPlInfo_Flags0
	or   a						; iPlInfo_Health == 0?
	jp   z, .main				; If so, skip
	
	; Seek to damage flags
	inc  hl					; Seek to iPlInfo_Flags1
	inc  hl					; Seek to iPlInfo_Flags2
	inc  hl					; Seek to iPlInfo_Flags3
	
	; Enable invulnerability if the flag is set
	bit  PF3B_LASTHIT, [hl]	; Is the flag set?
	jp   nz, .main			; If so, skip
	dec  hl					; Seek back to iPlInfo_Flags2
	dec  hl					; Seek back to iPlInfo_Flags1
	set  PF1B_INVULN, [hl]	; Enable invulnerability
.main:
	;--

	; Make player invulnerable for a short while to avoid receiving hits every frame.
	; MOVE_SHARED_HIT_SWOOPUP will reset this for us after a while.
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_INVULN, [hl]
	
	; Set continuation code
	ld   a, MOVE_SHARED_HIT_SWOOPUP
	call Pl_SetMove_ShakeScreenReset
	
	; Prevent overlapping with player
	call Play_Pl_MoveByColiBoxOverlapX
	
	
	;
	; Handle movement.
	;
	
	; Move 1.5px towards the enemy projectile (the "wall")
	; As the projectile hits multiple times, the player will move horizontally back and forth.
	ld   hl, +$0180
	call Play_OBJLstS_MoveH_ByOtherProjOnR
	
	; Reset the horizontal speed.
	;--
	; [POI] This check is pointless, both conditions are the same.
	ld   hl, iPlInfo_Flags3
	add  hl, bc
	bit  PF3B_HEAVYHIT, [hl]
	jp   nz, .setSpeedH
.setSpeedN:
	ld   hl, +$0000
	jp   .setSpeed
.setSpeedH:
	;--
	ld   hl, +$0000
.setSpeed:
	call Play_OBJLstS_SetSpeedH_ByXDirL
	; Subtract 2 to the current vertical speed, and move the player with the updated speed settings.
	; As the projectile hits multiple times, the player will progressively move quicker upwards.
	ld   hl, -$0200
	call OBJLstS_ApplyGravityVAndMoveHV
	; Fall-through
	
HitTypeC_SwoopUp_RetSet:
	scf
	ret
	
; =============== HitTypeC_DropCH ===============
; ID: HITTYPE_DROP_CH
;
; Hit effect that causes the player to drop on the ground with a low jump.
; Exclusively used by crouching heavy kicks and Daimon's Jirai Shin.
;
; Features:
; - Can optionally end a damage string
; - After hitstun ends, the player always gets knocked back with a backjump
; - Backjump height is high and can vary slightly depending on the hit strength
; - Player can't recover mid-air
; - Can be used in the air or on the ground
; OUT
; - C flag: Always set (ends hitstop)
HitTypeC_DropCH:
	
	;
	; If the hit has PF3B_LASTHIT set, this will be the last one for the combo string.
	; This is accomplished by making the player invulnerable during the drop, preventing
	; further hits until waking up.
	;
	
	; Ignore this if the player is already dead (in theory)...
	; [BUG?] Seems like a broken version of the check that works in HitTypeC_DropMain.
	ld   hl, iPlInfo_Flags0
	add  hl, bc				; Seek to iPlInfo_Flags0
	or   a					; Are we dead?
	jp   z, .main			; If not, skip
	
	; Seek to damage flags
	inc  hl					; Seek to iPlInfo_Flags1
	inc  hl					; Seek to iPlInfo_Flags2
	inc  hl					; Seek to iPlInfo_Flags3
	
	; Enable invulnerability if the flag is set
	bit  PF3B_LASTHIT, [hl]	; Is the flag set?
	jp   nz, .main			; If so, skip
	dec  hl					; Seek back to iPlInfo_Flags2
	dec  hl					; Seek back to iPlInfo_Flags1
	set  PF1B_INVULN, [hl]	; Enable invulnerability
	
.main:
	;
	; Main hitstun part.
	;
	call MoveS_PlayHitSFX
	ld   a, MOVE_SHARED_DROP_CH
	call Pl_SetMove_ShakeScreenReset
	call Play_Pl_DoHitstun
	
	; Once the hitstun is over, prevent the collision boxes from overlapping
	call Play_Pl_MoveByColiBoxOverlapX
	
	
	;
	; This knockback effect causes the player to drop with a back jump.
	;
	
	; Move 1.5px/frame backwards
	ld   hl, $0180
	call Play_OBJLstS_SetSpeedH_ByXDirL
	
	; Move up either at 3px/frame or 4px/frame depending on the hit strength.
	ld   hl, iPlInfo_Flags3
	add  hl, bc
	bit  PF3B_HEAVYHIT, [hl]	; Is this an heavy hit?
	jp   nz, .setSpeedH			; If so, jump
.setSpeedN:
	ld   hl, -$0300				; 3px/frame up for light hits
	jp   .setSpeed
.setSpeedH:
	ld   hl, -$0400				; 4px/frame up for light hits
.setSpeed:
	call Play_OBJLstS_SetSpeedV	; Start the jump!
	
	scf	; C flag set
	ret
	
; =============== HitTypeC_DropA ===============
; ID: HITTYPE_DROP_A
;
; Hit effect for getting hit by a normal in the air.
; No move explicitly sets this.
; 
; Features:
; - Only makes sense to use in the air
; - Always ends a damage string
; - After hitstun ends, the player always gets knocked back with a backjump
; - Backjump height is high and doesn't vary
; - Player recovers in the air
; OUT
; - C flag: Always set (ends hitstop)
HitTypeC_DropA:
	; Unlike HitTypeC_DropCH, the player is *always* invulnerable with this hit type,
	; likely to avoid juggles, essentially treating it as if PF3B_LASTHIT was always set.
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	inc  hl	; Seek to iPlInfo_Flags1
	set  PF1B_INVULN, [hl]
	
.main:
	;
	; Main hitstun part.
	;
	call MoveS_PlayHitSFX
	ld   a, MOVE_SHARED_BACKJUMP_REC_A
	call Pl_SetMove_ShakeScreenReset
	call Play_Pl_DoHitstun
	
	; Once the hitstun is over, prevent the collision boxes from overlapping
	call Play_Pl_MoveByColiBoxOverlapX
	
	; Move 1.5px/frame backwards
	; [POI] Useless check, as the same value gets used.
	ld   hl, iPlInfo_Flags3
	add  hl, bc
	bit  PF3B_HEAVYHIT, [hl]
	jp   nz, .setSpeedH
.setSpeedL:
	ld   hl, $0180
	jp   .setSpeed
.setSpeedH:
	ld   hl, $0180
.setSpeed:
	call Play_OBJLstS_SetSpeedH_ByXDirL
	
	; Move 4px/frame up
	ld   hl, -$0400
	call Play_OBJLstS_SetSpeedV
	
	scf	; C flag set
	ret
	
; =============== MoveS_PlayHitSFX ===============
; Plays a generic SFX for the player getting hit.
; IN
; - BC: Ptr to wPlInfo
MoveS_PlayHitSFX:
	; The sound effect used is different for "firey" moves (those with PF3B_FIRE set).
	ld   hl, iPlInfo_Flags3
	add  hl, bc						; Seek to iPlInfo_Flags3
	bit  PF3B_FIRE, [hl]	; Is this a firey move?
	jp   nz, .slowFlash				; If so, jump
.noFlash:
	ld   a, SCT_HIT					; A = SFX ID for normal hits
	jp   .playSFX
.slowFlash:
	ld   a, SCT_FIREHIT					; A = SFX ID for firey hits
.playSFX:
	call HomeCall_Sound_ReqPlayExId
	ret

; =============== HitTypeC_Hit_Multi* ===============	
; Hit types used by special moves that hit multiple times, for hits outside of the last one.
; Moves tend to alternate hits betweeen this and HitTypeC_Hit_Multi1.
;
; Some super moves may also use HitTypeC_Hit_MultiGS, which pushes the player on the ground
; and forces them there.
;
; Specifically made to prevent the opponent from getting out of the damage string,
; though it's not impossible with a well timed projectile.
;
; =============== HitTypeC_Hit_Multi0 ===============
; ID: HITTYPE_HIT_MULTI0
; OUT
; - C flag: Always set (ends hitstop)
HitTypeC_Hit_Multi0:
	ld   a, MOVE_SHARED_HIT_MULTIMID0
	jp   HitTypeC_Hit_Multi1.main
; =============== HitTypeC_Hit_Multi1 ===============
; ID: HITTYPE_HIT_MULTI1
; OUT
; - C flag: Always set (ends hitstop)
HitTypeC_Hit_Multi1:
	ld   a, MOVE_SHARED_HIT_MULTIMID1
	; Fall-through
	
; =============== .main ===============
; - Hitstun lasts very little
; - Player gets stuck and placed in front of the opponent.
; - Supports super move playfield flashing
; - Ground-only
; IN
; - A: Move ID
; OUT
; - C flag: Always set (ends hitstop)
.main:
	; Play SGB/DMG drop SFX
	push af
		ld   a, SCT_MULTIHIT
		call HomeCall_Sound_ReqPlayExId
	pop  af
	; Switch to move A
	call Pl_SetMove_ShakeScreenReset
	
	; Force position to be in front of opponent
	call HitTypeS_MovePlToOpFront
	
	; Some super moves use this (notably Iori's)
	call Play_Pl_FlashPlayfieldOnSuperHit
	
	; Hitstun time is very short since hits should come quickly
	call Play_Pl_DoHitstunOnce
	
	; Push opponent if we're cornered
	call Play_Pl_GiveKnockbackCornered
	
	scf	; C flag set
	ret
	
; =============== HitTypeC_Hit_MultiGS ===============
; ID: HITTYPE_HIT_MULTIGS
;
; OUT
; - C flag: Always set (ends hitstop)	
HitTypeC_Hit_MultiGS:
	ld   a, MOVE_SHARED_HIT_MULTIGS
	; Play SGB/DMG drop SFX
	push af
		ld   a, SCT_MULTIHIT
		call HomeCall_Sound_ReqPlayExId
	; Set move
	pop  af
	call Pl_SetMove_ShakeScreenReset
	
	; Snap to the ground
	ld   hl, iOBJInfo_Y
	add  hl, de
	ld   [hl], PL_FLOOR_POS
	
	; Move to same X position as opponent
	call HitTypeS_SyncPlXFromOtherX
	
	; Determine how much we're moving backwards.
	; [POI] Normally we move $10px back, but getting hit by Daimon moves us twice as far.
	ld   hl, iPlInfo_CharIdOther
	add  hl, bc
	ld   a, [hl]			; A = Opponent CharId
	cp   CHAR_ID_DAIMON		; CharId == CHAR_ID_DAIMON?
	jp   z, .moveH_Daimon	; If so, jump
.moveH_Norm:				; Otherwise, use the normal speed
	ld   hl, -$1000			; Move $10px back
	jp   .moveH
.moveH_Daimon:
	ld   hl, -$2000			; Move $20px back
.moveH:
	call Play_OBJLstS_MoveH_ByXDirR
	
	; Flash playfield if applicable
	call Play_Pl_FlashPlayfieldOnSuperHit
	
	; Small hitstun period
	call Play_Pl_DoHitstunOnce
	
	; Push opponent if we're cornered
	call Play_Pl_GiveKnockbackCornered
	
	scf	; C flag set
	ret
; =============== HitTypeS_MovePlToOpFront ===============
; Forces the player to be placed in front of the opponent, on the ground.
; This is meant to be used by "intermediate" hits for special moves that hit
; multiple times, so that the player won't manage to escape.
;
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
HitTypeS_MovePlToOpFront:

	;##
	;
	; [TCRF] This whole part is unnecessary.
	;
	; There's a separate, code path for getting hit by Ryo's Hien Shippu Kyaku.
	; This does the same thing as the normal code path, except byte $83 (iPlInfo_Ryo_HienShippuKyaku_Unused_83)
	; from the opponent's wPlInfo gets subtracted to the vertical position.
	; It suggests the move would have hit multiple times in the air, using byte $83 to keep track of where to offset the player.
	; 
	; However, not only does the move not use byte $83, meaning it wouldn't act any different than the normal code path,
	; but it also uses HitTypes that never call this subroutine anyway.
	;

	; Perform the character check
	ld   hl, iPlInfo_CharIdOther
	add  hl, bc
	ld   a, [hl]
	cp   CHAR_ID_RYO					; Playing as RYO?
	jp   z, .chkRyoMove					; If so, jump
	jp   .norm							; Otherwise, skip
.chkRyoMove:
	; Perform the move check
	ld   hl, iPlInfo_MoveIdOther
	add  hl, bc
	ld   a, [hl]
	cp   MOVE_RYO_HIEN_SHIPPU_KYAKU_L	; Performing light version of Hien Shippu Kyaku?
	jp   z, .unused_ryo					; If so, jump
	cp   MOVE_RYO_HIEN_SHIPPU_KYAKU_H	; Performing heavy version of Hien Shippu Kyaku?
	jp   z, .unused_ryo					; If so, jump
	jp   .norm							; Otherwise, skip
.unused_ryo:
	;--
	;
	; RYO CASE
	;

	; Y Position -> Snap to the ground, but offset by the opponent's iPlInfo_Ryo_HienShippuKyaku_Unused_83
	; iOBJInfo_Y = PL_FLOOR_POS - (opponent's)iPlInfo_Ryo_HienShippuKyaku_Unused_83
	
	; Determine which player we're playing as, and read to A the opponent's iPlInfo_Ryo_HienShippuKyaku_Unused_83
	ld   hl, iPlInfo_PlId
	add  hl, bc
	bit  0, [hl]		; iPlInfo_PlId != PL1?
	jp   nz, .ryo_pl2	; If so, jump
.ryo_pl1:
	ld   a, [wPlInfo_Pl2+iPlInfo_Ryo_HienShippuKyaku_Unused_83]	; Use 2P's value when we're 1P
	jp   .ryo_setY
.ryo_pl2:
	ld   a, [wPlInfo_Pl1+iPlInfo_Ryo_HienShippuKyaku_Unused_83]	; Use 1P's value when we're 2P
.ryo_setY:
	; A = -A for subtraction
	cpl  				
	inc  a
	; Add the base floor position
	add  PL_FLOOR_POS
	; Save the result to iOBJInfo_Y
	ld   hl, iOBJInfo_Y
	add  hl, de		; Seek to Y position
	ld   [hl], a	; Save A here
	
	; X Position -> $18px in front of the opponent (like in .norm)
	call HitTypeS_SyncPlXFromOtherX	; Sync to opponent X
	ld   hl, -$1800 				; Move back $18px
	call Play_OBJLstS_MoveH_ByXDirR
	jp   .ret
.norm:
	;##

	;
	; STANDARD CASE
	;

	; Y Position -> Snap to the ground
	ld   hl, iOBJInfo_Y
	add  hl, de
	ld   [hl], PL_FLOOR_POS
	
	; X Position -> $18px in front of the opponent
	call HitTypeS_SyncPlXFromOtherX	; Sync to opponent X
	ld   hl, -$1800 				; Move back $18px
	call Play_OBJLstS_MoveH_ByXDirR
.ret:
	ret
	
; =============== HitTypeS_SyncPlXFromOtherX ===============
; Makes the player use the same X pixel position as the opponent.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
HitTypeS_SyncPlXFromOtherX:
	push bc
		; BC = Ptr to opponent's X Position
		ld   hl, iPlInfo_OBJInfoXOther
		add  hl, bc
		push hl
		pop  bc
		
		; HL = Ptr to player X Position
		ld   hl, iOBJInfo_X
		add  hl, de
		
		; Copy iPlInfo_OBJInfoXOther to iOBJInfo_X
		ld   a, [bc]
		inc  bc			; Not needed
		ldi  [hl], a
	pop  bc
	ret
; =============== HitTypeS_SyncPlPosFromOtherPos ===============
; Makes the player use the same X and Y positions as the opponent.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
HitTypeS_SyncPlPosFromOtherPos:
	push bc
		; BC = Ptr to opponent's X Position
		ld   hl, iPlInfo_OBJInfoXOther
		add  hl, bc
		push hl
		pop  bc
		
		; HL = Ptr to player X Position
		ld   hl, iOBJInfo_X
		add  hl, de
		
		; Copy iPlInfo_OBJInfoXOther to iOBJInfo_X
		ld   a, [bc]
		inc  bc			; Seek to iPlInfo_OBJInfoYOther	
		ldi  [hl], a	; Save value, seek to iOBJInfo_XSub
		inc  hl			; Seek to iOBJInfo_Y
		
		; Copy iPlInfo_OBJInfoYOther to iOBJInfo_Y
		ld   a, [bc]
		ld   [hl], a
	pop  bc
	ret
	
; =============== HitTypeC_ThrowStart ===============
; ID: HITTYPE_THROW_START
;
; This hit effect handles the second part of getting thrown, after the opponent's throw request was accepted,
; and ends when the opponent gets into the second part of the throw (BasicInput_StartGroundThrow or BasicInput_StartAirThrow).
;
; We get here when the initial validation in Play_Pl_SetHitType.chkThrow passes, meaning we were in throw range
; and in the appropriate state.
;
; What this part does is set up delays and player flags, then increment wPlayPlThrowActId to PLAY_THROWACT_NEXT02
; and wait in a loop, passing control to the opponent's task.
; Said task resumes executing from Play_Pl_ChkThrowInput.tryStart, where it validates that wPlayPlThrowActId was
; set to PLAY_THROWACT_NEXT02. If it isn't, the throw action is set to PLAY_THROWACT_NONE and ends, which also
; causes us to jump to .retClear once we get execution again.
; If instead his validation passes, he will get to BasicInput_StartGroundThrow or BasicInput_StartAirThrow
; and set wPlayPlThrowActId to PLAY_THROWACT_NEXT03, which is the value we're waiting for.
;
; OUT
; - C flag: If set, the throw continued successfully
HitTypeC_ThrowStart:	

	; Not applicable if we're getting thrown
	ld   a, [wPlayPlThrowActId]
	cp   PLAY_THROWACT_START		; wPlayPlThrowActId == PLAY_THROWACT_START?
	jp   nz, .retClear				; If not, jump
	
	; [TCRF] Require 15 button presses to do something... but nothing checks for this.
	ld   hl, iPlInfo_Unused_ThrowKeyTimer
	add  hl, bc
	ld   [hl], $0F
	
	; We're not invulnerable during throws, since the opponent uses hurtboxes to
	; continue the throw sequence.
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	res  PF1B_INVULN, [hl]
	; Can't switch direction since it wouldn't make sense
	res  PF1B_XFLIPLOCK, [hl]
	
	; Set the continuation code, which handles throw tech after the HitType ends
	ld   a, MOVE_SHARED_THROW_START
	call Pl_SetMove_ShakeScreenReset
	
	; Switch to the next part of the throw sequence.
	; This signals 
	ld   a, PLAY_THROWACT_NEXT02
	ld   [wPlayPlThrowActId], a
	
	;
	; Wait until the opponent task sets a new value for wPlayPlThrowActId.
	;
.waitCont:
	call Task_PassControlFar		; Pass out to opponent task
	ld   a, [wPlayPlThrowActId]
	cp   PLAY_THROWACT_NONE			; Did he reset the value to PLAY_THROWACT_NONE?
	jp   z, .retClear				; If so, the throw is aborted
	cp   PLAY_THROWACT_NEXT03		; Did he set it to PLAY_THROWACT_NEXT03 yet?
	jp   nz, .waitCont				; If not, loop
	
	;
	; If we got here, the opponent got into the second part of the throw.
	; Prepare for the continuation code to start.
	;
	
	; $14 frame window to perform a throw tech
	ld   a, $14
	ld   [wPlayPlThrowTechTimer], a
	
IF REV_VER_2 == 1
	; In case we tech the throw, there's an 80 frame window where we can't be thrown again
	ld   hl, iPlInfo_NoThrowTimer
	add  hl, bc
	ld   [hl], $50
ENDC
	
	; Play throw SGB/DMG SFX
	ld   a, SCT_GRAB
	call HomeCall_Sound_ReqPlayExId
	
	; Face the opponent and lock the direction again
	call OBJLstS_SyncXFlip
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_XFLIPLOCK, [hl]
	
	; Freeze the player while doing MOVE_SHARED_THROW_START.
	ld   hl, iOBJInfo_FrameLeft
	add  hl, de
	ld   [hl], ANIMSPEED_NONE
	inc  hl
	ld   [hl], ANIMSPEED_NONE
	
	; Reposition 16px in front of the opponent.
	; Because we're facing the opponent, moving backwards places us there.
	call HitTypeS_SyncPlXFromOtherX	; over opponent X
	ld   hl, -$1000					; move back $10px
	call Play_OBJLstS_MoveH_ByXDirR
	
	; Remove throw range hitbox next frame
	ld   hl, iPlInfo_PhysHitRecv
	add  hl, bc
	ld   [hl], $01
	
	; Prevent collision box overlapping
	call Play_Pl_MoveByColiBoxOverlapX
	; and push the opponent if we couldn't
	call Play_Pl_GiveKnockbackCornered
	
	; C flag set - throw continued
	scf
	ret
.retClear:
	; C flag clear - throw aborted
	xor  a
	ret


; =============== HitTypeC_ThrowRot* ===============
; These hit effects are for the "rotation frames", which can be requested by the opponent's
; move code after the grab is fully confirmed and before the actual throw happens.
;
; Typically set up by something like:
;	mMvC_SetDamage xxx, HITTYPE_THROW_ROT*, PF3_HEAVYHIT
;	mMvC_MoveThrowOp yy, zz
;
; These are supposed to be instant, so they just reposition the player
; and switch to the main move MOVE_SHARED_THROW_ROT*.
;
; OUT
; - C flag: Always set
	
; =============== HitTypeC_ThrowRotU ===============
; ID: HITTYPE_THROW_ROTU
HitTypeC_ThrowRotU:
	ld   a, MOVE_SHARED_THROW_ROTU
	jp   HitTypeC_ThrowRotCustom
; =============== HitTypeC_ThrowRotL ===============
; ID: HITTYPE_THROW_ROTL
HitTypeC_ThrowRotL:
	ld   a, MOVE_SHARED_THROW_ROTL
	jp   HitTypeC_ThrowRotCustom
; =============== HitTypeC_ThrowRotD ===============
; ID: HITTYPE_THROW_ROTD
HitTypeC_ThrowRotD:
	ld   a, MOVE_SHARED_THROW_ROTD
	jp   HitTypeC_ThrowRotCustom
; =============== HitTypeC_ThrowRotR ===============
; ID: HITTYPE_THROW_ROTR
HitTypeC_ThrowRotR:
	ld   a, MOVE_SHARED_THROW_ROTR
	jp   HitTypeC_ThrowRotCustom
; =============== HitTypeC_ThrowRotCustom ===============
; IN
; - A: Move ID
HitTypeC_ThrowRotCustom:
	; Set continuation code.
	; Every MOVE_SHARED_THROW_ROT* points to the same move code, it's only
	; the animation assigned to it that varies.
	call Pl_SetMove_ShakeScreenReset
	
	; Reposition relative to the opponent, based on whatever the opponent specified in Play_Pl_MoveRotThrown.
	call HitTypeS_SyncPlPosFromOtherPos		; Move over opponent
	; The position is relative to the opponent facing left, meaning it's more or less equivalent
	; to the standard "player facing right" relative positioning.
	ld   a, [wPlayPlThrowRotMoveH]			; Move forward by wPlayPlThrowRotMoveH
	ld   h, a								
	ld   l, $00
	call Play_OBJLstS_MoveH_ByOtherXFlipL
	ld   a, [wPlayPlThrowRotMoveV]			; Move down by wPlayPlThrowRotMoveV
	ld   h, a
	ld   l, $00
	call Play_OBJLstS_MoveV
	; Remove throw rotation range hitbox next frame
	ld   hl, iPlInfo_PhysHitRecv
	add  hl, bc
	ld   [hl], $01
	; Push the opponent if we couldn't fully reposition (ie: attempted to move off-screen)
	call Play_Pl_GiveKnockbackCornered
	
	scf	; C flag set
	ret
	
; =============== Play_Pl_SetHitType ===============
; Handles the player status and damage-related fields when getting hit.
; This does a lot of setup for Play_Pl_DoHit to do the final adjustments
; and execute the HitType code.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
; OUT
; - A: Hit effect ID that was set, * 2 (HITTYPE_*)
; - C flag: If set, we got hit or blocked the attack. The return value in A can be used.
;           If cleared, the hit didn't have any effect.
Play_Pl_SetHitType:
	push bc
		push de
		
		;--------------------------------
		;
		; Update the airborne flag on the player status,
		; since it's used later on when validating hit effects.
		; (As some hit effects are switched when in the air or on the ground)
		;
		Play_Pl_SetHitTypeC_SetAirFlag:
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
		; converge back at Play_Pl_SetHitTypeC_ChkBlock (but not before setting the PF0B_PROJHIT flag)
		; when it comes to applying the damage and hit effect.
		;
		Play_Pl_SetHitTypeC_ChkHitType:		
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
			jp   Play_Pl_SetHitType_RetClear
			
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
			jp   nz, Play_Pl_SetHitType_RetClear	; If not, return
			
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
			
			jp   Play_Pl_SetHitType_RetClear	; We never get here
			
		.getProjDamage:
		
			;
			; Seek to the move damage fields from the opponent's projectile.
			;
			ld   hl, iPlInfo_PlId
			add  hl, bc							; Seek to iPlInfo_PlId
			bit  0, [hl]						; iPlInfo_PlId == PL2? ($01)
			jp   nz, .useProj1P					; If so, use 1P's projectile damage value
		.useProj2P:							
			ld   hl, wOBJInfo_Pl2Projectile+iOBJInfo_Play_DamageVal		 
			jp   .chkProjDamage
		.useProj1P:
			ld   hl, wOBJInfo_Pl1Projectile+iOBJInfo_Play_DamageVal		
		.chkProjDamage:
			; 
			; Just like the PF1B_INVULN check, this was checked beforehand in the box check code.
			; This is structured like the code checking iPlInfo_MoveDamageValOther in .phys,
			; but the damage check in there has a real purpose.
			;
			ld   a, [hl]
			or   a								; Is there damage assigned to the projectile?
			jp   z, Play_Pl_SetHitType_RetClear	; If not, return
			
			;
			; Retrieve the move damage fields from the projectile.
			;
			ld   d, [hl]	; D = iOBJInfo_Play_DamageVal
			inc  hl
			ld   e, [hl]	; E = iOBJInfo_Play_DamageHitTypeId
			inc  hl
			ld   a, [hl]	; A = iOBJInfo_Play_DamageFlags3
			
			; Set that we were hit by a projectile
			ld   hl, iPlInfo_Flags0
			add  hl, bc							; Seek to iPlInfo_Flags0
			set  PF0B_PROJHIT, [hl]
			
			inc  hl								; Seek to iPlInfo_Flags1
			inc  hl								; Seek to iPlInfo_Flags2
			; Projectiles bypass autoguard
			res  PF2B_AUTOGUARDMID, [hl]
			res  PF2B_AUTOGUARDLOW, [hl]
			; Since it should be possible to combo off a projectile hit, restore collision boxes.
			res  PF2B_NOHURTBOX, [hl]
			res  PF2B_NOCOLIBOX, [hl]
			
			; Apply the opponent's iOBJInfo_Play_DamageFlags3
			inc  hl								; Seek to iPlInfo_Flags3
			ld   [hl], a						; Copy iOBJInfo_Play_DamageFlags3 there
			
			; There's nothing else to check here, skip to the shared code
			jp   Play_Pl_SetHitTypeC_ChkBlock
			
			
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
			jp   z, Play_Pl_SetHitType_RetClear	; If not, return
			
			;
			; Make sure the opponent can damage the player.
			;
			; We're checking this because of what the game does to prevent a move from dealing
			; damage for multiple continuous frames.
			; 
			; To ensure that, the main task at Play_DoMisc_ResetDamage blanks the damage field
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
			jp   z, Play_Pl_SetHitType_RetClear	; If so, return
			
			;
			; Retrieve the move damage fields from the other player.
			;
			ld   d, [hl]				; D = iPlInfo_MoveDamageValOther
			inc  hl
			ld   e, [hl]				; E = iPlInfo_MoveDamageHitTypeIdOther
			inc  hl
			ld   a, [hl]				; A = iPlInfo_MoveDamageFlags3Other
			
			; Set that we weren't hit by a projectile
			ld   hl, iPlInfo_Flags0
			add  hl, bc					; Seek to iPlInfo_Flags0
			res  PF0B_PROJHIT, [hl]
			
			inc  hl						; Seek to iPlInfo_Flags1
			inc  hl						; Seek to iPlInfo_Flags2
			
			; Restore collision boxes to allow combo hits.
			res  PF2B_NOHURTBOX, [hl]
			res  PF2B_NOCOLIBOX, [hl]
			
			; Copy the opponent's iPlInfo_MoveDamageFlags3Other to our iPlInfo_Flags3 value
			inc  hl						; Seek to iPlInfo_Flags3
			ld   [hl], a				
			
			ld   a, e		; A = HitTypeId
			
			;
			; Perform extra validation before registering that we got damaged.
			;
			; First determine what type of damage move (set hit effect ID) this was, as set by the move code.
			; The hit effect IDs are grouped in a specific order:
			; - All standard hit/drop effects (including the end of a throw) use IDs < $10
			; - ID $10 is used when starting a throw
			; - IDs > $10 are the rotation frames used for the "next" parts of a throw.
			;         Each character decides how to cycle between them.
			;
			; All of the validation to check if we can be grabbed happens at the start of the throw (HITTYPE_THROW_START).
			; If the throw was already started (HitTypeId >= $10) then we're definitely allowed to continue it.
			; (as long as we don't get throw tech, but that's handled elsewhere).
			;
			; The throws are also special since they never cause damage directly (read: as long as HitTypeId >= $10),
			; so when they are confirmed (.setThrowFlags) they just set some flags to force the throw state and jump 
			; directly to the end, skipping the damage evaluator. After returning, the HitTypeC for the throw will
			; then be executed, continuing the throw sequence.
			; The actual damage only happens the when the code for the throw sets HitTypeId < $10, which makes
			; it count as a normal hit.
			;
			cp   HITTYPE_THROW_START	; HitTypeId == $10?
			jp   z, .chkThrow			; If so, jump
			cp   HITTYPE_THROW_START	; HitTypeId >= $10?
			jp   nc, .setThrowFlags		; If so, jump
			; Otherwise, iPlInfo_MoveDamageHitTypeIdOther < $10, meaning it's a generic hit.
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
			jp   nz, Play_Pl_SetHitType_RetClear	; If not, return
			
			;
			; If we got thrown by a special move (command throw), always allow the throw to continue.
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
			jp   nz, Play_Pl_SetHitType_RetClear	; If so, return
			jp   .setThrowFlags			; Otherwise, jump
			
		.chkThrowForGround:
		
			;
			; We must be on the ground for the throw to start.
			;
			ld   hl, iPlInfo_Flags0
			add  hl, bc					
			bit  PF0B_AIR, [hl]						; Are we in the air?
			jp   nz, Play_Pl_SetHitType_RetClear	; If so, return
			
			;
			; Standard invulnerability check.
			;
			inc  hl									; Seek to iPlInfo_Flags1
			bit  PF1B_INVULN, [hl]					; Are we invulnerable?
			jp   nz, Play_Pl_SetHitType_RetClear	; If so, return
			
			; OK
			jp   .setThrowFlags
			
		.chkThrowForAir:
		
			;
			; We must be in the air for the throw to start.
			;
			ld   hl, iPlInfo_Flags0
			add  hl, bc							; Seek to iPlInfo_Flags0
			bit  PF0B_AIR, [hl]					; Are we in the air?
			jp   z, Play_Pl_SetHitType_RetClear	; If not, return
			
			;
			; [POI] The CPU can't be thrown in the air.
			;
			bit  PF0B_CPU, [hl]						; Are we a CPU player?
			jp   nz, Play_Pl_SetHitType_RetClear	; If so, return
			
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
			; Just set the updated hit effect ID from E and return.
			; After returning, the updated hit effect code will be executed:
			; - The first time we get here, it will be for HITTYPE_THROW_START, which executes HitTypeC_ThrowStart.
			;   That will handle the next part of the throw, from PLAY_THROWACT_START to PLAY_THROWACT_NEXT03.
			; - The next times are as part of the rotation frames, which is past the point throw tech is allowed.
			jp   Play_Pl_SetHitTypeC_SetHitTypeId
			
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
			res  PF3B_FIRE, [hl]
			res  PF3B_SUPERALT, [hl]
			; Exit hit state
			jp   Play_Pl_SetHitType_RetClear
			;--
			
		.chkAutoguard:
			;
			; Special moves can be set to either block lows or highs automatically 
			; with the autoguard flags.
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
			jp   Play_Pl_SetHitTypeC_ChkBlock	; Skip to the common block
			
		.onAutoguardMid:
			; If the attack hits low, we got hit
			ld   hl, iPlInfo_Flags3
			add  hl, bc									
			bit  PF3B_HITLOW, [hl]
			jp   nz, Play_Pl_SetHitTypeC_BlockBypass
			
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
			jp   nz, Play_Pl_SetHitTypeC_BlockBypass
			
		.chkSpecial:
			; Autoguarding lows only works against normals in general.
			ld   hl, iPlInfo_Flags0Other
			add  hl, bc
			ld   a, [hl]
			and  a, PF0_SUPERMOVE|PF0_SPECMOVE			; Did we get hit by a special move?
			jp   nz, Play_Pl_SetHitTypeC_BlockBypass		; If so, jump
		.autoguardOk:
			
			ld   hl, iPlInfo_Flags2
			add  hl, bc				; Seek to iPlInfo_Flags2
			
			; Flag that we guarded it this way
			set  PF2B_AUTOGUARDDONE, [hl]
			inc  hl					; Seek to iPlInfo_Flags3
			; Stop flashing
			res  PF3B_FIRE, [hl]
			res  PF3B_SUPERALT, [hl]
			jp   Play_Pl_SetHitType_RetClear
			;###
			
		;--------------------------------
		;
		; SHARED - Block Check.
		;
		Play_Pl_SetHitTypeC_ChkBlock:
			;
			; If we're blocking, determine if the attack was properly blocked.
			; If not, the guard is removed and we take full damage.
			; ie: blocking overheads while crouching
			;
			; Moves can be set to either require blocking low (PF3B_HITLOW) or to be overheads (PF3B_OVERHEAD).
			; Most moves don't set either flag, meaning they can be blocked in both ways.
			; The few unblockables have both PF3B_OVERHEAD and PF3B_HITLOW set at the same time.
			;
			; By default, special moves clear PF1B_GUARD, but a few moves set it.
			; The same exact logic applies when performing a special with PF1B_GUARD set.
			;
			ld   hl, iPlInfo_Flags1
			add  hl, bc									
			bit  PF1B_GUARD, [hl]					; Were we blocking the attack?
			jp   z, Play_Pl_SetHitTypeC_ApplyDamage	; If not, skip ahead
			bit  PF1B_CROUCH, [hl]					; Did we block low?
			jp   z, .onBlockMid						; If not, jump
		.onBlockLow:
			ld   hl, iPlInfo_Flags3
			add  hl, bc								; Seek to iPlInfo_Flags3
			bit  PF3B_OVERHEAD, [hl]				; Is this an overhead?
			jp   nz, Play_Pl_SetHitTypeC_BlockBypass	; If so, we got hit
			jp   Play_Pl_SetHitTypeC_Blocked			; Otherwise, we blocked it
		.onBlockMid:
			ld   hl, iPlInfo_Flags3
			add  hl, bc								; Seek to iPlInfo_Flags3
			bit  PF3B_HITLOW, [hl]					; Does the attack require blocking low?
			jp   nz, Play_Pl_SetHitTypeC_BlockBypass	; If so, we got hit
			jp   Play_Pl_SetHitTypeC_Blocked			; Otherwise, we blocked it
			
		Play_Pl_SetHitTypeC_Blocked:
			; Since we blocked the attack, remove the hit effect
			; so we can continue blocking.
			ld   e, $00
			jp   Play_Pl_SetHitTypeC_ApplyDamage
			
		Play_Pl_SetHitTypeC_BlockBypass:
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
		Play_Pl_SetHitTypeC_ApplyDamage:
			
			; Play_Pl_ApplyDamageToStats recalculates the values in DE, so save/restore it
			push de
				call Play_Pl_ApplyDamageToStats
			pop  de
			
		;--------------------------------
		;
		; SHARED - Set Hit Effect
		;
		Play_Pl_SetHitTypeC_SetHitType:
			;
			; Second pass to validate the effect to use when getting hit,
			; as it may get replaced with something else depending on the player status flags.
			; After this last series of checks in made, save it to iPlInfo_HitTypeId.
			;
			ld   a, e						; A = HitTypeId
			
			;
			; This is the first of many whitelists where some moves can't be overriden at all.
			; HITTYPE_HIT_MULTI0, HITTYPE_HIT_MULTI1 and HITTYPE_HIT_MULTIGS in particular
			; tend to be used by special moves that hit multiple times for every hit
			; except the last one, thus preventing the opponent from escaping mid-move.
			; (though it can still happen if a projectile hits at the right time, see the .chkOtherEscape in many moves)
			;
			
			; These type IDs can always be used
			cp   HITTYPE_HIT_MULTI0						; E == $09?
			jp   z, Play_Pl_SetHitTypeC_SetHitTypeId	; If so, jump
			cp   HITTYPE_HIT_MULTI1						; ...
			jp   z, Play_Pl_SetHitTypeC_SetHitTypeId
			cp   HITTYPE_HIT_MULTIGS
			jp   z, Play_Pl_SetHitTypeC_SetHitTypeId
			cp   HITTYPE_DROP_MAIN
			jp   z, Play_Pl_SetHitTypeC_SetHitTypeId
			cp   HITTYPE_DROP_SWOOPUP
			jp   z, Play_Pl_SetHitTypeC_SetHitTypeId
IF REV_VER_2 == 1
			cp   HITTYPE_DIZZY						
			jp   z, Play_Pl_SetHitTypeC_SetHitTypeId
ENDC
		.chkDead:
			;
			; Getting KO'd restricts the number of allowed hit effects, as the player
			; has to visibily drop to the ground, something not all HitTypes do.
			;
			ld   hl, iPlInfo_Health
			add  hl, bc
			ld   a, [hl]
			or   a						; Do we have any health left?
			jp   nz, .notDead			; If so, jump
			
			ld   hl, iPlInfo_Flags1
			add  hl, bc					; Seek to our iPlInfo_Flags1
			res  PF1B_GUARD, [hl]		; Disable blocking
			
			; E = HitTypeId (Opponent)
			ld   hl, iPlInfo_MoveDamageHitTypeIdOther
			add  hl, bc					
			ld   a, [hl]				
			ld   e, a
			
			; There are different allowed HitTypes depending on whether we got
			; killed by a hit or a throw.
			ld   a, [wPlayPlThrowActId]
			or   a						; Did we get thrown?
			jp   nz, .deadThrown		; If so, jump
		.deadHit:
			; Getting KO'd by a normal always sets HITTYPE_DROP_MAIN.
			; For specials there's a whitelist.
			ld   hl, iPlInfo_Flags0Other
			add  hl, bc					; Seek to opponent's status
			bit  PF0B_SPECMOVE, [hl]	; Did we get killed by a special move?
			jp   nz, .deadSpecHit		; If so, jump
			jp   .useStdDrop			; Otherwise, use HITTYPE_DROP_MAIN
		.deadThrown:
			; There are three allowed effects when getting KO's by a throw.
			; Otherwise, default to HITTYPE_DROP_MAIN.
			ld   a, e
			cp   HITTYPE_DROP_DB_A		; HitTypeId == $0C?
			jp   z, .useDrop0C			; If so, jump
			cp   HITTYPE_THROW_END		; ...
			jp   z, Play_Pl_SetHitTypeC_SetHitTypeId
			cp   a, HITTYPE_DROP_SWOOPUP
			jp   z, Play_Pl_SetHitTypeC_SetHitTypeId
			jp   .useStdDrop
		.deadSpecHit:
			; Whitelist of allowed hit effects when getting KO'd by a hit.
			; Otherwise, default to HITTYPE_DROP_MAIN.
			ld   a, e
			cp   HITTYPE_HIT_MULTI0
			jp   z, Play_Pl_SetHitTypeC_SetHitTypeId
			cp   HITTYPE_HIT_MULTI1
			jp   z, Play_Pl_SetHitTypeC_SetHitTypeId
			cp   HITTYPE_HIT_MULTIGS
			jp   z, Play_Pl_SetHitTypeC_SetHitTypeId
			cp   HITTYPE_DROP_DB_A
			jp   z, .useDrop0C
			cp   HITTYPE_THROW_END
			jp   z, Play_Pl_SetHitTypeC_SetHitTypeId
			cp   HITTYPE_DROP_SWOOPUP
			jp   z, Play_Pl_SetHitTypeC_SetHitTypeId
			jp   .useStdDrop
			
		.notDead:
			ld   a, e
			
			; If we blocked the hit, determine if guard broke as that uses its own types.
			; Note that HITTYPE_BLOCKED got set previously by the subroutine, overriding
			; whatever the attack set when blocking it successfully.
			cp   HITTYPE_BLOCKED		; Did we block the hit?
			jp   nz, .noBlock			; If not, jump
			call Play_Pl_DoGuardBreak	; Did our guard break?
			jp   z, .useGuardBreak		; If so, jump
			jp   Play_Pl_SetHitTypeC_SetHitTypeId	; Otherwise, confirm HITTYPE_BLOCKED
			
		.noBlock:
			call Play_Pl_IsDizzyNext	; Are we supposed to get dizzy on this hit?
			jp   z, .noDizzy			; If not, jump
		.dizzy:
			; Handle the type blacklist when getting hit "right before getting" dizzy.
			; When getting dizzy, the player will drop to the ground regardless of the hit effect,
			; by overriding whatever effect was set with HITTYPE_DROP_MAIN (by reaching .useStdDrop).
			; However, the effects checked below can't be overridden.
			ld   a, e
			cp   HITTYPE_HIT_MULTI0
			jp   z, Play_Pl_SetHitTypeC_SetHitTypeId
			cp   HITTYPE_HIT_MULTI1
			jp   z, Play_Pl_SetHitTypeC_SetHitTypeId
			cp   HITTYPE_HIT_MULTIGS
			jp   z, Play_Pl_SetHitTypeC_SetHitTypeId
			cp   HITTYPE_DROP_DB_A
			jp   z, .useDrop0C
			cp   HITTYPE_THROW_END
			jp   z, Play_Pl_SetHitTypeC_SetHitTypeId
			cp   HITTYPE_DROP_SWOOPUP
			jp   z, Play_Pl_SetHitTypeC_SetHitTypeId
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
			; HITTYPE_DROP_SWOOPUP is always allowed when getting hit in the air
			; (alongside HITTYPE_DROP_DB_A and HITTYPE_THROW_END...)
			cp   HITTYPE_DROP_SWOOPUP
			jp   z, Play_Pl_SetHitTypeC_SetHitTypeId
			
			;
			; When getting hit by a normal in the air, the player recovers before touching the ground.
			; Otherwise, it's an hard drop.
			;
			bit  PF0B_PROJHIT, [hl]	; Did we get hit by a projectile?
			jp   nz, .airSpec		; If so, jump
			ld   hl, iPlInfo_Flags0Other
			add  hl, bc				
			bit  PF0B_SPECMOVE, [hl]	; Did we get hit by a special move?
			jp   nz, .airSpec		; If so, jump
		.airNorm:
			;--
			; [POI] This is the same between .noAirNoSpec and .noAirSpec.
			;       It could have been moved before the PF0B_PROJHIT check.
			cp   HITTYPE_DROP_DB_A
			jp   z, .useDrop0C
			cp   HITTYPE_THROW_END
			jp   z, Play_Pl_SetHitTypeC_SetHitTypeId
			;--
			jp   .useHitAirRec		; Use HITTYPE_DROP_A
		.airSpec:
			;--
			; [POI] See above
			cp   HITTYPE_DROP_DB_A
			jp   z, .useDrop0C
			cp   HITTYPE_THROW_END
			jp   z, Play_Pl_SetHitTypeC_SetHitTypeId
			;--
			jp   .useStdDrop		; Use HITTYPE_DROP_MAIN
			;##
			
		.noAir:
			;
			; This is the only part that doesn't define default values.
			; When getting hit on the ground without getting dizzy or blocking,
			; every HitType value is valid as long as it doesn't get replaced
			; by the crouching checks.
			;
			bit  PF0B_PROJHIT, [hl]	; Did we get hit by a projectile?
			jp   nz, .noAirSpec		; If so, jump
			ld   hl, iPlInfo_Flags0Other
			add  hl, bc				
			bit  PF0B_SPECMOVE, [hl]	; Did we get hit by a special move?
			jp   nz, .noAirSpec		; If so, jump
		.noAirNorm:
			; HITTYPE_DROP_CH is always allowed
			cp   HITTYPE_DROP_CH
			jp   z, Play_Pl_SetHitTypeC_SetHitTypeId
			
			; If we got hit by a normal while crouching, force use HITTYPE_HIT_LOW
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			bit  PF1B_CROUCH, [hl]		; Are we crouching?
			jp   nz, .useHitLow			; If so, jump
			
			; Otherwise, use the existing value
			;
			; Of course, this assumes that normals will never set hit types
			; they aren't intended to use, like HITTYPE_DROP_DB_A.
			jp   Play_Pl_SetHitTypeC_SetHitTypeId
		.noAirSpec:
			; No special behaviour when hit by a special move, other
			; than the standard special case for HITTYPE_DROP_DB_A
			; that's also everywhere else.
			cp   HITTYPE_DROP_DB_A
			jp   z, .useDrop0C
			jp   Play_Pl_SetHitTypeC_SetHitTypeId
			;##
			
		.useDrop0C:
			; If we're not in the air, replace HITTYPE_DROP_DB_A with its ground version,
			; which is a shortened version without the downwards movement.
			ld   hl, iPlInfo_Flags0
			add  hl, bc
			bit  PF0B_AIR, [hl]						; Are we in the air?
			jp   nz, Play_Pl_SetHitTypeC_SetHitTypeId			; If so, confirm the air ver
			ld   e, HITTYPE_DROP_DB_G		; Otherwise, replace it with the ground ver
			jp   Play_Pl_SetHitTypeC_SetHitTypeId
			
		.useGuardBreak:
			; Like .useDrop0C, but for the guard break.
			ld   hl, iPlInfo_Flags0
			add  hl, bc						
			bit  PF0B_AIR, [hl]				; Are we in the air?
			jp   z, .useGuardBreakGround	; If not, jump
		.useGuardBreakAir:
			ld   e, HITTYPE_GUARDBREAK_A
			jp   Play_Pl_SetHitTypeC_SetHitTypeId
		.useGuardBreakGround:
			ld   e, HITTYPE_GUARDBREAK_G
			jp   Play_Pl_SetHitTypeC_SetHitTypeId
			
		;--
		; [TCRF] Unreferenced code to force the standard hit effects
		.unused_useHit03:
			ld   e, HITTYPE_HIT_MID0
			jp   Play_Pl_SetHitTypeC_SetHitTypeId
		.unused_useHit04:
			ld   e, HITTYPE_HIT_MID1
			jp   Play_Pl_SetHitTypeC_SetHitTypeId
		;--
		
		.useStdDrop:
			ld   e, HITTYPE_DROP_MAIN
			jp   Play_Pl_SetHitTypeC_SetHitTypeId
		.useHitAirRec:
			ld   e, HITTYPE_DROP_A
			jp   Play_Pl_SetHitTypeC_SetHitTypeId
		.useHitLow:
			ld   e, HITTYPE_HIT_LOW
			jp   Play_Pl_SetHitTypeC_SetHitTypeId
			
		Play_Pl_SetHitTypeC_SetHitTypeId:
			; Save the updated hit effect ID.
			; iPlInfo_HitTypeId = E
			ld   a, e			; A = E
			ld   hl, iPlInfo_HitTypeId
			add  hl, bc			; Seek to iPlInfo_HitTypeId
			ld   [hl], a		; Write it over
			
			; Return the same value to A, except multiplied by 2.
			; A = E * 2
			sla  a
			scf		; C flag set
		pop  de
	pop  bc
	ret
		Play_Pl_SetHitType_RetClear:
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
	bit  PF0B_PROJHIT, [hl]		; Did we get hit by a projectile?
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
	; Determine which wOBJInfo_Pl*Projectile struct to use, and use iOBJInfo_Play_DamageVal from there.
	ld   hl, iPlInfo_PlId
	add  hl, bc					; Seek to iPlInfo_PlId
	bit  0, [hl]				; wPlInfo_Pl == 2P?
	jp   nz, .use1P				; If so, 1P is the opponent. Use 1P's projectile's damage
.use2P:							; Otherwise, use 2P's one
	ld   hl, wOBJInfo_Pl2Projectile+iOBJInfo_Play_DamageVal		 
	jp   .getDamageProj
.use1P:
	ld   hl, wOBJInfo_Pl1Projectile+iOBJInfo_Play_DamageVal		
.getDamageProj:
	ld   d, [hl]				; D = iOBJInfo_Play_DamageVal
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
	bit  PF0B_PROJHIT, [hl]	; Were we hit by a projectile?
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
	cp   CHAR_ID_CHIZURU	; Playing as normal Chizuru?
	jp   z, .chkMove		; If so, jump
	cp   CHAR_ID_KAGURA		; Playing as boss Chizuru?
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
; See also: Play_DoMisc_IncDizzyTimer
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
		add  hl, bc					; Seek to iPlInfo_Flags1
		bit  PF1B_GUARD, [hl]		; Is the flag set?
		jp   nz, .chkGuard			; If so, jump
		
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
		bit  PF1B_HITRECV, [hl]		; Is this the first hit of the damage string? (damage string mode not yet set)
		jp   z, .noGuard_chkOther	; If so, skip
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
		bit  PF0B_PROJHIT, [hl]	; Were we hit by a projectile? (special move)
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
		push hl						; Request dizzy on hit
			ld   hl, iPlInfo_DizzyNext
			add  hl, bc
			ld   [hl], $01
		pop  hl
	.saveDizzyPenalty:
		ld   [hl], a
		jp   .ret
		
	.chkGuard:
		ld   a, d	; Not necessary
		
		;
		; Special moves can enable autoblocking when they set PF1B_GUARD.
		; However, probably because the player isn't explicitly blocking in that case,
		; when the guard triggers no penalty is subtracted to the stun timer.
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
		bit  PF1B_HITRECV, [hl]		; Is this the first hit of the damage string? (damage string mode not yet set)
		jp   z, .guard_chkOther		; If so, skip
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
		bit  PF0B_PROJHIT, [hl]
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
	; This will keep the Z flag cleared, preventing the guard break HitType from being set.
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
	
; =============== MoveS_ChkHalfSpeedHit ===============
; Runs the game at half speed for the specified amount of frames if the move allows for it.
; IN
; - A: How many frames to perform the effect
; - BC: Ptr to wPlInfo
MoveS_ChkHalfSpeedHit:

	push af	; Save frame count
	
		;
		; Validate that we can actually start slowdown mode
		;
		
		; Not applicable when dead, as getting killed already sets its own slowdown. don't interfere
		ld   hl, iPlInfo_Health
		add  hl, bc
		ld   a, [hl]
		or   a			; iPlInfo_Health == 0?
		jp   z, .ret	; If so, jump
		
		; Only do it if the move we got hit with has the slowdown flag set.
		ld   hl, iPlInfo_Flags3
		add  hl, bc
		bit  PF3B_HALFSPEED, [hl]	; Is the move tagged with halfspeed?
		jp   nz, .setSlowdown		; If so, jump
		jp   .ret					; Otherwise, don't do anything
		
	.setSlowdown:
		;
		; All OK. Initialize that mode
		;
	pop  af							; Slow down for A frames
	ld   [wPlaySlowdownTimer], a
	ld   a, $01						; Run gameplay every other frame
	ld   [wPlaySlowdownSpeed], a
	ret
	.ret:
		;
		; Validation failed.
		;
	pop  af
	ret
	
IF REV_VER_2 == 0
; =============== Play_Pl_Unused_DecThrowKeyTimer ===============
; [TCRF] Weird unreferenced code that decrements a counter related to throws
;        when any of these conditions pass:
;        - Time Over
;        - Died
;        - Pressed any button
; The counter itself is set to $08 by HitTypeC_ThrowStart and read by nothing else,
; except for giving it visibility to the opponent.
; IN
; - BC: Ptr to wPlInfo
Play_Pl_Unused_DecThrowKeyTimer:
	; If we time over'd, decrement the counter
	ld   a, [wRoundTime]
	or   a					; wRoundTime == 0?
	jp   z, .decTimer		; If so, jump
	
	; If we have no health, decrement the counter
	ld   hl, iPlInfo_Health
	add  hl, bc
	ld   a, [hl]
	or   a					; iPlInfo_Health == 0?
	jp   z, .decTimer		; If so, jump
	
	; If we pressed any button, decrement the counter
	ld   hl, iPlInfo_JoyNewKeys
	add  hl, bc
	ld   a, [hl]
	and  a, $FF^KEY_START	; Pressed any key other than START?
	jp   z, .ret			; If not, return
	
.decTimer:
	; iPlInfo_Unused_ThrowKeyTimer = MAX(iPlInfo_Unused_ThrowKeyTimer - 1, 0)
	ld   hl, iPlInfo_Unused_ThrowKeyTimer
	add  hl, bc				; HL = Ptr to iPlInfo_Unused_ThrowKeyTimer
	ld   a, [hl]			; A = iPlInfo_Unused_ThrowKeyTimer - 1
	sub  a, $01
	jp   nc, .save			; Did we underflow? If not, jump
	xor  a					; Otherwise, A = 0
.save:
	ld   [hl], a
.ret:
	ret
ENDC
	
; =============== Play_Pl_FlashPlayfieldOnSuperHit ===============
; Flashes the playfield if the player got hit by a super move.
; IN
; - BC: Ptr to wPlInfo
Play_Pl_FlashPlayfieldOnSuperHit:
	; Note this is only called when getting hit.
	ld   hl, iPlInfo_Flags0Other
	add  hl, bc
	bit  PF0B_SUPERMOVE, [hl]	; Is the opponent performing a super move?
	jp   z, .ret				; If not, return
	ld   a, $00					; Otherwise, start the flashing (playfield becomes black)
	ld   [wStageBGP], a
.ret:
	ret
	
; =============== MoveC_Hit_PostStunKnockback ===============
; Move handler for ground knockback.
;
; Because this only displays one single animation frame, it has different timing logic from other moves.
; Instead of going off the animation timer (iOBJInfo_OBJLstPtrTblOffsetView), this goes
; off the frame timer (iOBJInfo_FrameLeft) which ticks down.
; Because of this, .anim is only used to decrement iOBJInfo_FrameLeft.
;
; Handler for:
; - MOVE_SHARED_POST_BLOCKSTUN
; - MOVE_SHARED_GUARDBREAK_G
; - MOVE_SHARED_HIT0MID
; - MOVE_SHARED_HIT1MID
; - MOVE_SHARED_HITLOW
MoveC_Hit_PostStunKnockback:
	; Deliver knockback to the opponent, if needed
	call Play_Pl_GiveKnockbackCornered
	; No collision box overlapping allowed
	call Play_Pl_MoveByColiBoxOverlapX
	
	; Equivalent to mMvC_ValLoaded for a single frame
	call OBJLstS_IsGFXLoadDone
	jp   nz, .anim
	
	; Depending on the how many frames are left...
	ld   hl, iOBJInfo_FrameLeft
	add  hl, de
	ld   a, [hl]
	cp   $00			; iOBJInfo_FrameLeft == $00? (last frame)
	jp   z, .chkEnd		; If so, jump
	cp   $01			; iOBJInfo_FrameLeft != $01?
	jp   nz, .anim		; If so, jump (iOBJInfo_FrameLeft--)
	
; --------------- second to last subframe ---------------
.setKnockbackSpeed:
	; Manually reset back iOBJInfo_FrameLeft to $00, since we're not calling .anim (even though we could have if we really wanted).
	ld   [hl], $00
	
	; Setup the knockback speed, depending on how long we have shaken.
	;
	; The direction here is relative to the internal flip flag, since it's
	; not affected by the visual PF1B_XFLIPLOCK (see Play_CalcPlDistanceAndXFlip)
	; and we always want to move away from the opponent.
	;
	; For some reason, this is relative to the player facing *left* (2P side),
	; so moving to the right moves the player back.
	
	ld   hl, iPlInfo_Flags3
	add  hl, bc
	bit  PF3B_HEAVYHIT, [hl]	; Was this an heavy hit?
	jp   nz, .setSpeedFast		; If so, jump
.setSpeedNorm:
	ld   hl, $0280				; Otherwise HL = $02.80px/frame (short)
	jp   .setSpeed
.setSpeedFast:
	ld   hl, $0400				; HL = $04px/frame (long)
.setSpeed:
	call Play_OBJLstS_SetSpeedH_ByXDirL
	jp   .ret
; --------------- last subframe ---------------
.chkEnd:
	; Slow down at $00.40px/frame, and end the move when we stop moving.
	; This doesn't call .anim, preventing iOBJInfo_FrameLeft from resetting back to iOBJInfo_FrameTotal.
	mMvC_DoFrictionH $0040
	jp   nc, .ret
	call Play_Pl_EndMove
; --------------- common ---------------
.ret:
	ret
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
	
; =============== MoveC_Hit_DropMain ===============
; Continuation code for the standard drop without mid-air recovery, for HitTypeC_DropMain. (MOVE_SHARED_DROP_MAIN)
; This one also triggers a rebound, and allows roll canceling.
MoveC_Hit_DropMain:
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
	; Do specific actions depending on the hit type
	ld   hl, iPlInfo_Flags3
	add  hl, bc
	bit  PF3B_LIGHTHIT, [hl]	; Is this a light hit?
	jp   nz, .obj0_hitL			; If so, jump
	
.obj0_hitN:
	; If this is a normal hit, don't do anything special yet.
	; Treat it as startup.
	mMvC_ValFrameEnd .doGravity_chkRoll
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		jp   .doGravity_chkRoll
.obj0_hitL:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		; Setup the jump speed depending on the hit status
		ld   hl, iPlInfo_Flags3
		add  hl, bc
		bit  PF3B_HEAVYHIT, [hl]	; Is this a heavy hit?
		jp   nz, .obj0_setJumpH		; If so, jump
	.obj0_setJumpN:
		mMvC_SetSpeedHInt +$0140	; 1.25px/frame away from the opponent
		mMvC_SetSpeedV -$0400 		; 4px/frame up 
		jp   .obj0_move
	.obj0_setJumpH:
		mMvC_SetSpeedHInt +$0180	; 1.5px/frame away from the opponent
		mMvC_SetSpeedV -$0600 		; 6px/frame up
	.obj0_move:
		mMvC_SetMoveV -$0100		; Move 1px backwards
		mMvC_DoGravityHV $0000		; Move by the set speed without altering it
		jp   .anim
; --------------- frame #1 ---------------
.obj1:
	; Move 1px backwards at the start of the frame
	mMvC_ValFrameStartFast .doGravity_chkRoll
		mMvC_SetMoveV -$0100
		jp   .doGravity_chkRoll
; --------------- frame #2 ---------------
; Pre-rebound frame.
.obj2:
	; Set manual control for #3
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		jp   .anim
; --------------- frame #3 ---------------
; Rebounding off the ground.
.obj3:
	; At the start of the frame, set the jump speed for the rebound.
	mMvC_ValFrameStartFast .obj3_cont
		
		;--
		;
		; Cut in half the horizontal speed.
		; iOBJInfo_SpeedX /= 2
		;
		push bc
			ld   hl, iOBJInfo_SpeedX
			add  hl, de		; Seek to iOBJInfo_SpeedX
			ld   b, [hl]	; B = iOBJInfo_SpeedX
			inc  hl			; Seek to iOBJInfo_SpeedXSub
			ld   c, [hl]	; C = iOBJInfo_SpeedXSub
			push bc			; Move to HL
			pop  hl
		pop  bc
		sra  h				; HL >> 1
		rr   l
		call Play_OBJLstS_SetSpeedH	; Set the horizontal speed to that
		;--
		mMvC_SetSpeedV -$0300	; 3px/frame up
		jp   .doGravity_noRoll
.obj3_cont:
	jp   .doGravity_noRoll
; --------------- frames #0-1 / common gravity check with roll cancel support ---------------	
; Roll input validation.
;
; When we touch the ground, allow roll cancelling when holding A+B (with optionally L or R).
; This works as long as the hit didn't KO or get us dizzy.
;
; If the validation succeeds by the time, we switch to the appropriate roll input.
; Otherwise, we continue to #2, where the player rebounds from the ground.
.doGravity_chkRoll:
	mMvC_ChkGravityHV $0060, .anim
	
		; Can't be dizzy
		call Play_Pl_IsDizzyNext	; About to get dizzy?
		jp   nz, .noRoll			; If so, skip
		; Can't be dead
		ld   hl, iPlInfo_Health
		add  hl, bc
		ld   a, [hl]
		or   a						; Did we get KO'd?
		jp   z, .noRoll				; If so, skip
		; Key check
		call Play_Pl_AreBothBtnHeld	; Did we press A+B?
		jp   c, .roll				; If so, jump
	.noRoll:
	
		; We didn't roll.
		; Use frame #2 when bouncing off the ground.
		mMvC_SetDropFrame $02*OBJLSTPTR_ENTRYSIZE, $05
		
		; Can't be hit until we get up
		ld   hl, iPlInfo_Flags1
		add  hl, bc
		set  PF1B_INVULN, [hl]
		
		; Stop flashing
		ld   hl, iPlInfo_Flags3
		add  hl, bc
		res  PF3B_FIRE, [hl]
		res  PF3B_SUPERALT, [hl]
		jp   .ret
		
	.roll:
	
		;
		; Part very similar to relevant code in Play_Pl_ChkGuardCancelRoll,
		; except this isn't treated as a super move, has more sensical key checks,
		; and jumps coming out of the roll won't be hyper jumps.
		;
			
		; Don't hyper jump out of the roll
		ld   hl, iPlInfo_RunningJump
		add  hl, bc			
		ld   [hl], $00
		
		ld   hl, iPlInfo_Flags1
		add  hl, bc						; Seek to iPlInfo_Flags1
		res  PF1B_GUARD, [hl] 			; Can't block when rolling (we are invulnerable instead)
		res  PF1B_CROUCH, [hl] 			; As rolling starts from crouching, remove the crouch flag
		set  PF1B_NOBASICINPUT, [hl] 	; Don't override with normal movement
		set  PF1B_XFLIPLOCK, [hl] 		; Lock player direction during the roll
		set  PF1B_NOSPECSTART, [hl] 	; Don't allow cancelling the roll into a special
		
		inc  hl				; Seek to iPlInfo_Flags2
		
		; Make player completely invulnerable while rolling.
		; Disabling both hurtbox and hitbox causes every attack collision check to be ignored.
		set  PF2B_NOHURTBOX, [hl]
		set  PF2B_NOCOLIBOX, [hl]
		
		inc  hl				; Seek to iPlInfo_Flags3
		; Remove these flash bits to let PF0B_SUPERMOVE handle the flashing
		res  PF3B_FIRE, [hl]
		res  PF3B_SUPERALT, [hl]
		
		;
		; Determine if player should roll forwards or backwards depending on the held directional keys.
		;
		call Play_Pl_GetDirKeys_ByXFlipR	; Check d-pad keys, relative to 1P side (so left moves back)
		jp   nc, .setRollBack				; Were any keys held? If not, default to back
		
		; Holding back activates the back roll
		bit  KEYB_RIGHT, a			; Holding forward?
		jp   nz, .setRollFront		; If so, roll forward
	.setRollBack:
		ld   a, MOVE_SHARED_ROLL_B
		jp   .doGravity_setRoll
	.setRollFront:
		ld   a, MOVE_SHARED_ROLL_F
		jp   .doGravity_setRoll
	.doGravity_setRoll:
		; Switch to the new move
		call Pl_SetMove_StopSpeed
		jp   .ret
; --------------- frame #3, common gravity check ---------------	
.doGravity_noRoll:
	; When touching the ground after the rebound, play the drop SFX and switch to #4
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetDropFrame $04*OBJLSTPTR_ENTRYSIZE, $05
		jp   .ret
; --------------- frame #4 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_StartWakeUp
		jp   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Hit_Throw_End ===============
; Move code used for the last part of the throw animation.
; Similar to the code used in MoveC_Hit_DropMain.
; Used to handle the actual jump arc for:
; - Air throws, down drop "throw" (MOVE_SHARED_THROW_END_A)
; - Ground throws (MOVE_SHARED_THROW_END_G)
MoveC_Hit_Throw_End:
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
	;
	; Getting thrown by Mature's Decide moves horizontally at 3px/frame
	; if we aren't moving upwards.
	; Do nothing but handle gravity otherwise.
	;
	ld   hl, iPlInfo_CharIdOther
	add  hl, bc
	ld   a, [hl]
	cp   CHAR_ID_MATURE				; Opponent is Mature?
	jp   nz, .obj0_doGravity		; If not, skip
.obj0_chkMatureMove:
	ld   hl, iPlInfo_MoveIdOther
	add  hl, bc
	ld   a, [hl]
	cp   MOVE_MATURE_DECIDE_L		; Hit by Decide?
	jp   z, .obj0_chkSpeed			; If so, jump
	cp   MOVE_MATURE_DECIDE_H		; Hit by Decide?
	jp   z, .obj0_chkSpeed			; If so, jump
	jp   .obj0_doGravity			; Otherwise, skip
.obj0_chkSpeed:
	ld   hl, iOBJInfo_SpeedY
	add  hl, de
	bit  7, [hl]					; iOBJInfo_SpeedY < 0? (MSB set)
	jp   nz, .doGravity_preRebound	; If so, jump
	mMvC_SetSpeedH $0300			
.obj0_doGravity:
	jp   .doGravity_preRebound
; --------------- frame #1 ---------------
; Frame when hitting the ground.
.obj1:
	; Shake the screen when the ground is hit
	call Play_Pl_DoGroundScreenShake
	mMvC_ValFrameEnd .anim
		; Set manual control for #2
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		; Stop shaking when we leave the ground
		xor  a
		ld   [wScreenShakeY], a
		jp   .anim
; --------------- frame #2 ---------------
; Rebounding off the ground. Identical to version in MoveC_Hit_DropMain.
.obj2:
	; At the start of the frame, set the jump speed for the rebound.
	mMvC_ValFrameStartFast .obj2_cont
		;--
		;
		; Cut in half the horizontal speed.
		; iOBJInfo_SpeedX /= 2
		;
		push bc
			ld   hl, iOBJInfo_SpeedX
			add  hl, de		; Seek to iOBJInfo_SpeedX
			ld   b, [hl]	; B = iOBJInfo_SpeedX
			inc  hl			; Seek to iOBJInfo_SpeedXSub
			ld   c, [hl]	; C = iOBJInfo_SpeedXSub
			push bc			; Move to HL
			pop  hl
		pop  bc
		sra  h				; HL >> 1
		rr   l
		call Play_OBJLstS_SetSpeedH	; Set the horizontal speed to that
		;--
		mMvC_SetSpeedV -$0300	; 3px/frame up
		jp   .doGravity_afterRebound
.obj2_cont:;J
	jp   .doGravity_afterRebound
; --------------- frame #0 / common gravity check ---------------
; Before hitting the ground the first time...
.doGravity_preRebound:
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetDropFrame $01*OBJLSTPTR_ENTRYSIZE, $09
		jp   z, .ret
		
		; End the damage string when touching the ground
		ld   hl, iPlInfo_Flags1
		add  hl, bc
		set  PF1B_INVULN, [hl]
	
		ld   a, SCT_GROUNDHIT
		call HomeCall_Sound_ReqPlayExId
		
		; Stop flashing as well
		ld   hl, iPlInfo_Flags3
		add  hl, bc
		res  PF3B_FIRE, [hl]
		res  PF3B_SUPERALT, [hl]
		jp   .ret
; --------------- frame #2 / common gravity check ---------------
; After we rebounded once...
.doGravity_afterRebound:
	; Handle gravity
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetDropFrame $03*OBJLSTPTR_ENTRYSIZE, $05
		jp   .ret
; --------------- frame #3 ---------------
.chkEnd:
	; Wake up at the end of the frame
	mMvC_ValFrameEnd .anim
		call Play_Pl_StartWakeUp
		jp   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Hit_DropDBG ===============
; Continuation code for HitTypeC_Drop_DB_G. (HITTYPE_DROP_DB_G)
; This is a generic move that just handles the ground shake effect,
; as the player is already on the ground and doesn't move.
; Handler for:
; - MOVE_SHARED_DROP_DBG
MoveC_Hit_DropDBG:
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
	jp   .anim ; We never get here
; --------------- frame #0 ---------------
.obj0:
	; Show #1 for 5 frames (+ load)
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $05
		mMvC_PlaySound SCT_GROUNDHIT
		jp   .anim
; --------------- frame #1 ---------------
.obj1:
	; Perform an earthquake effect while this frame is active.
	; This shakes the player on the ground.
	call Play_Pl_DoGroundScreenShake
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $10
		; Stop the earthquake effect
		xor  a
		ld   [wScreenShakeY], a
		; Stop flashing the opponent as well
		ld   hl, iPlInfo_Flags3
		add  hl, bc
		res  PF3B_FIRE, [hl]
		res  PF3B_SUPERALT, [hl]
		jp   .anim
; --------------- frame #2 ---------------
.chkEnd:
	; Wake up at the end of the frame.
	mMvC_ValFrameEnd .anim
		call Play_Pl_StartWakeUp
		jp   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Hit_SwoopUp ===============
; Continuation code for hits that launch the player upwards. (MOVE_SHARED_HIT_SWOOPUP)
; This handles both the projectile and throw versions.
;
; The projectile version is a bit special with the way it handles the invulnerability flag.
; There are two phases for this move, the moving up and moving down parts.
; The player, during this move, overlaps a tall projectile that would hit every frame, which 
; also decreases the gravity by 2px/frame and restarts the move. 
; To avoid that it, both the hit effect and this move make sure the player is invulnerable 
; until we move into the frames meant for moving down (even when still moving up).
; If the projectile is still active, this will deal a new hit the next frame, implicitly looping back to #0.
;
; Note that the throw version, used by Daimon, doesn't do this.
; It's a simple throw, and so it consistently avoids touching the invulnerability flag
; until we start moving down.
;
MoveC_Hit_SwoopUp:
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
; Upwards movement - frame #0.
.obj0:
	; Apply $00.30px/frame gravity while moving up.
	ld   hl, iOBJInfo_SpeedY
	add  hl, de
	ld   a, [hl]
	bit  7, a				; SpeedY < 0? (MSB set)
	jp   nz, .doGravity0030	; If so, jump
.obj0_onDown:	
	; Immediately switch to #2 and apply $00.60px/frame gravity if we start moving down.
	ld   hl, iOBJInfo_OBJLstPtrTblOffset
	add  hl, de
	ld   [hl], $02*OBJLSTPTR_ENTRYSIZE
	jp   .doGravity0060
; --------------- frame #1 ---------------
; Upwards movement - frame #1.
.obj1:
	ld   hl, iOBJInfo_SpeedY
	add  hl, de
	ld   a, [hl]
	bit  7, a				; SpeedY < 0? (MSB set)
	jp   nz, .obj1_onUp		; If so, jump
.obj1_onDown:
	; Immediately switch to #2 and apply $00.60px/frame gravity if we start moving down.
	; Like with #0.
	ld   hl, iOBJInfo_OBJLstPtrTblOffset
	add  hl, de
	ld   [hl], $02*OBJLSTPTR_ENTRYSIZE
	jp   .doGravity0060
.obj1_onUp:
	mMvC_ValFrameEnd .doGravity0030
		; The non-projectile (Daimon) version consistently avoids touching PF1B_INVULN.
		ld   hl, iPlInfo_CharIdOther
		add  hl, bc
		ld   a, [hl]
		cp   CHAR_ID_DAIMON		; Opponent is Daimon?
		jp   nz, .obj1_onUpProj	; If not, skip
	.obj1_onUpDaimon:
		; Play SFX
		ld   a, SCT_LIGHT
		call HomeCall_Sound_ReqPlayExId
		jp   .obj1_switchToChkEnd
	.obj1_onUpProj:
		; Allow next hit to happen.
		; If the projectile is still active, this will reset the move and continue the upwards movement.
		ld   hl, iPlInfo_Flags1
		add  hl, bc
		res  PF1B_INVULN, [hl]
	.obj1_switchToChkEnd:
		ld   hl, iOBJInfo_OBJLstPtrTblOffset
		add  hl, de
		ld   [hl], $06*OBJLSTPTR_ENTRYSIZE
		jp   .doGravity0030
; --------------- frame #2 ---------------
; Downwards movement - loop frame #0.
.obj2:
	; For Daimon's command throw, disable invulnerability with the higher gravity.
	ld   hl, iPlInfo_CharIdOther
	add  hl, bc
	ld   a, [hl]
	cp   CHAR_ID_DAIMON		; Opponent is Daimon?
	jp   nz, .doGravity0060	; If not, skip
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	res  PF1B_INVULN, [hl]	; Otherwise, disable invuln first
	jp   .doGravity0060
; --------------- frame #3 ---------------
; Downwards movement - loop frame #1.
.obj3:
	; For Daimon's command throw, disable invulnerability with the higher gravity.
	ld   hl, iPlInfo_CharIdOther
	add  hl, bc
	ld   a, [hl]
	cp   CHAR_ID_DAIMON		; Opponent is Daimon?
	jp   nz, .obj3_chkLoop		; If not, skip
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	res  PF1B_INVULN, [hl]	; Otherwise, disable invuln first
.obj3_chkLoop:
	; Loop back to #2 if we haven't touched the ground by the time this frame ended
	mMvC_ValFrameEnd .doGravity0060
		ld   hl, iOBJInfo_OBJLstPtrTblOffset
		add  hl, de
		ld   [hl], $01*OBJLSTPTR_ENTRYSIZE ; offset by -1
		jp   .doGravity0060
; --------------- frame #4 ---------------
; Ground touched - screen shake effect, speed reset.
.obj4:
	call Play_Pl_DoGroundScreenShake
	mMvC_ValFrameEnd .anim
		; Get manual control for #5.
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		jp   .anim
; --------------- frame #5 ---------------
; Rebounding off the ground.
.obj5:
	; At the start of the frame, set the jump speed for the rebound.
	; This is like what MoveC_Hit_DropMain does.
	mMvC_ValFrameStartFast .obj5_cont
	
		;--
		;
		; Cut in half the horizontal speed.
		; iOBJInfo_SpeedX /= 2
		;
		push bc
			ld   hl, iOBJInfo_SpeedX
			add  hl, de		; Seek to iOBJInfo_SpeedX
			ld   b, [hl]	; B = iOBJInfo_SpeedX
			inc  hl			; Seek to iOBJInfo_SpeedXSub
			ld   c, [hl]	; C = iOBJInfo_SpeedXSub
			push bc			; Move to HL
			pop  hl
		pop  bc
		sra  h				; HL >> 1
		rr   l
		call Play_OBJLstS_SetSpeedH	; Set the horizontal speed to that
		;--
		
		;
		; Unlike MoveC_Hit_DropMain, this doesn't use a fixed vertical speed.
		; The new vertical speed is calculated from:
		; iOBJInfo_SpeedY = -(OkSpeedY/2) - $04
		;
		; Use iPlInfo_Hit_SwoopUp_OkSpeedY since that's the last valid speed value
		; from before touching the ground.
		ld   hl, iPlInfo_Hit_SwoopUp_OkSpeedY
		add  hl, bc
		ld   a, [hl]	; A = Orig Y Speed
		sra  a			; Cut it in half
		add  a, $04		; Add 4
		cpl				; Invert it from positive to negative, since we're moving up
		inc  a
		ld   h, a		; Set that as number of pixels
		ld   l, $FF		; and $FF as subpixels
		call Play_OBJLstS_SetSpeedV
		
		jp   .doGravityToChkEnd
.obj5_cont:
	jp   .doGravityToChkEnd
	
; -------------------------------------------------------------------
; --------------- frames #0-3 / common gravity checks ---------------	
; -------------------------------------------------------------------
; Two different entry points to the gravity function are used, depending on
; the direction we're moving vertically.
;
; - $00.30px/frame gravity is applied when moving up.
; - $00.60px/frame gravity is applied when moving down.
;   This also makes the player invulnerable for projectile-based hits. (read: not hit by Daimon)
;

; --------------- .doGravity0030 ---------------
; Applies gravity at $00.30px/frame.
.doGravity0030:
	;--
	; [TCRF] It looks like this originally applied a significant amount of negative gravity.
	;        This would have made the upwards movement much faster... but it also the breaks downwards movement,
	ld   hl, -$0200		
	;--
	ld   hl, +$0030		; HL = $00.30px/frame gravity
	jp   .doGravityByHL
; --------------- .doGravity0060 ---------------
; Applies gravity at $00.60px/frame.
.doGravity0060:
	; Really make sure the player is invulnerable if we're doing the projectile version
	ld   hl, iPlInfo_CharIdOther
	add  hl, bc
	ld   a, [hl]
	cp   CHAR_ID_DAIMON			; iPlInfo_CharIdOther == CHAR_ID_DAIMON?
	jp   z, .doGravity0060_main	; If so, skip
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_INVULN, [hl]		; Otherwise, enable invuln
.doGravity0060_main:
	ld   hl, $0060				; HL = $00.60px/frame gravity
	; Fall-through
	
; --------------- .doGravityByHL ---------------
; Handles gravity and moves the player.
; IN
; - HL: Gravity to apply
.doGravityByHL:

	;
	; Always save a copy of the current Y Speed.
	; This is because iOBJInfo_SpeedY gets erased when touching the ground (#4), 
	; and in #5 we need to rebound at a speed relative to it.
	;
	push hl
		ld   hl, iOBJInfo_SpeedY
		add  hl, de
		ld   a, [hl]		; A = Y Speed		
		ld   hl, iPlInfo_Hit_SwoopUp_OkSpeedY
		add  hl, bc			; Seek to backup field
		ld   [hl], a		; Copy it there
	pop  hl
	
	;
	; Apply HL gravity and move in both directions.
	; In case of the projectile version of the hit, our H Speed will be 0.
	;
	; When touching the ground, switch to #4.
	;
	call OBJLstS_ApplyGravityVAndMoveHV	; Did we touch the ground?
	jp   nc, .anim						; If not, jump
		mMvC_SetDropFrame $04*OBJLSTPTR_ENTRYSIZE, $0B	; Attempt to set the next frame
		jp   z, .ret									; Did it work? If not (ie: already set it before), return
		
			; Play a sound effect for hitting the ground
			ld   a, SCT_GROUNDHIT
			call HomeCall_Sound_ReqPlayExId
			
			; If we got hit by Daimon, do not turn invulnerability back on.
			; This is because his super move hits the player with an earthquake effect
			; the moment the opponent touches the ground.
			ld   hl, iPlInfo_CharIdOther
			add  hl, bc
			ld   a, [hl]						; A = Opponent CharId
			cp   CHAR_ID_DAIMON					; A == CHAR_ID_DAIMON?
			jp   z, .doGravityByHL_stopFlash	; If so, skip
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			set  PF1B_INVULN, [hl]				; Otherwise, turn invulnerability on to end the damage string
		.doGravityByHL_stopFlash:
			; Stop flashing the opponent as well
			ld   hl, iPlInfo_Flags3
			add  hl, bc
			res  PF3B_FIRE, [hl]
			res  PF3B_SUPERALT, [hl]
			jp   .ret
; --------------- frame #5 / gravity check ---------------
.doGravityToChkEnd:
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetDropFrame $06*OBJLSTPTR_ENTRYSIZE, $05
		jp   .ret
; --------------- frame #6 ---------------
; Wake up when the frame ends.
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_StartWakeUp
		jp   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Hit_DropCH ===============
; Continuation code for HitTypeC_DropCH, for use with crouching heavy kicks. (MOVE_SHARED_DROP_CH)
; This causes the player to be knocked back with a jump, with settings previously
; set in HitTypeC_DropCH.
; Shouldn't be used on player death even though it's "compatible" with it.
; OUT
; - C flag: Always set (ends hitstop)
MoveC_Hit_DropCH:
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
	jp   .anim ; We never get here
; --------------- frame #0 ---------------
.obj0:
	; Get manual control for #1
	mMvC_ValFrameEnd .doGravity
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		jp   .doGravity
; --------------- frame #1 ---------------
.obj1:
	jp   .doGravity
; --------------- common gravity check ---------------
.doGravity:
	; Switch to #2 when landing on the ground
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetDropFrame $02*OBJLSTPTR_ENTRYSIZE, $05
		; Stop flashing
		ld   hl, iPlInfo_Flags3
		add  hl, bc
		res  PF3B_FIRE, [hl]
		res  PF3B_SUPERALT, [hl]
		jp   .ret
; --------------- frame #2 ---------------
.chkEnd:
	; The knockback ends when the frame ends
	mMvC_ValFrameEnd .anim
		call Play_Pl_StartWakeUp
		jp   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Hit_BackJumpAirRec ===============
; Move code for a generic backjump with air recovery.
; 
; This is used for:
; - The continuation code for getting hit by a normal in the air by HitTypeC_DropA (MOVE_SHARED_BACKJUMP_REC_A)
; - The backjump for several special moves that can transition to this
;
; Since the player recovers mid-air, it can't be used with player death.
MoveC_Hit_BackJumpAirRec:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .setManCtrl
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .waitM07
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .waitM05
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .waitM01
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .waitP01
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .doGravity
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
; --------------- frame #0 ---------------
; Set manual control at the end of the frame.
.setManCtrl:
	mMvC_ValFrameEnd .doGravity
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		jp   .doGravity
; --------------- frame #1 ---------------
; Wait for YSpeed > -$07 before continuing to #2.
.waitM07:
	mMvC_NextFrameOnGtYSpeed -$07, ANIMSPEED_NONE
	jp   .doGravity
; --------------- frame #2 ---------------
.waitM05:
	mMvC_NextFrameOnGtYSpeed -$05, ANIMSPEED_NONE
	jp   .doGravity
; --------------- frame #3 ---------------
.waitM01:
	mMvC_NextFrameOnGtYSpeed -$01, ANIMSPEED_NONE
	jp   .doGravity
; --------------- frame #4 ---------------
.waitP01:
	mMvC_NextFrameOnGtYSpeed +$01, ANIMSPEED_NONE
	jp   .doGravity
; --------------- frames #0-5 / common gravity check ---------------
.doGravity:
	; Switch to #6 when touching the ground
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $06*OBJLSTPTR_ENTRYSIZE, ANIMSPEED_INSTANT
		jp   .ret
; --------------- frame #6 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Hit_GuardBreakA ===============
; Move code for guard breaking in the air (MOVE_SHARED_GUARDBREAK_A).
MoveC_Hit_GuardBreakA:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   a, $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj0
	cp   a, $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
; --------------- frame #0 ---------------
.obj0:
	; Slow down at $00.60px/frame.
	; When we touch the ground, switch to #1.
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $01*OBJLSTPTR_ENTRYSIZE, ANIMSPEED_INSTANT
		jp   .ret
; --------------- frame #1 ---------------
.chkEnd:
	; Move ends when the frame ends
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Hit_MultiMidKnockback ===============
; Continuation code for hits in the middle of a ground-based special move that hits multiple times (HITTYPE_HIT_MULTI0, HITTYPE_HIT_MULTI1)
;
; In practice, this is identical to MoveC_Hit_PostStunKnockback except that the player drops on the ground at the end.
; (there are more differences, but they are either unreachable or useless)
;
; Like that move, it uses the frame timer since the player doesn't animate.
;
; Handler for: 
; - MOVE_SHARED_HIT_MULTIMID0
; - MOVE_SHARED_HIT_MULTIMID1.
MoveC_Hit_MultiMidKnockback:
	; Deliver knockback to the opponent, if needed
	call Play_Pl_GiveKnockbackCornered
	; This shouldn't be needed
	mMvC_ValLoaded .ret
	; Equivalent to mMvC_ValLoaded for a single frame
	call OBJLstS_IsGFXLoadDone
	jp   nz, .anim
	
	; Depending on the how many frames are left...
	ld   hl, iOBJInfo_FrameLeft
	add  hl, de
	ld   a, [hl]
	cp   $00					; iOBJInfo_FrameLeft == $00? (last frame)
	jp   z, .chkEnd				; If so, jump
	cp   $01					; iOBJInfo_FrameLeft == $01?
	jp   z, .setKnockbackSpeed	; If so, jump
	; Otherwise, tick down iOBJInfo_FrameLeft
	jp   .anim
; --------------- second to last subframe ---------------
.setKnockbackSpeed:
	; Manually reset back iOBJInfo_FrameLeft to $00, since we're not calling .anim (even though we could have if we really wanted).
	ld   [hl], $00
	
	; Setup the knockback speed, depending on how long we have shaken.
	;
	; The direction here is relative to the internal flip flag, since it's
	; not affected by the visual PF1B_XFLIPLOCK (see Play_CalcPlDistanceAndXFlip)
	; and we always want to move away from the opponent.
	;
	; For some reason, this is relative to the player facing *left* (2P side),
	; so moving to the right moves the player back.
	
	ld   hl, iPlInfo_Flags3
	add  hl, bc
	bit  PF3B_HEAVYHIT, [hl]	; Was this an heavy hit?
	jp   nz, .setSpeedFast		; If so, jump
.setSpeedNorm:
	ld   hl, $0280				; Otherwise HL = $02.80px/frame (short)
	jp   .setSpeed
.setSpeedFast:
	ld   hl, $0400				; HL = $04px/frame (long)
.setSpeed:
	call Play_OBJLstS_SetSpeedH_ByXDirL
	
	; If we're on the ground, we can proceed to .chkEnd from the next frame
	; to first handle the knockback, and only drop on the ground when we stop moving.
	
	; [TCRF] If we're in the air though, drop down immediately using the just set speed settings.
	;        This will never jump since all moves that use this call HitTypeS_MovePlToOpFront to force
	;        the attacked player to be on the ground. 
	ld   hl, iOBJInfo_Y
	add  hl, de
	ld   a, [hl]			; A = Y Pos
	cp   PL_FLOOR_POS		; A == PL_FLOOR_POS?
	jp   nz, .switchToDrop	; If not, jump
	
	jp   .ret
; --------------- last subframe ---------------
.chkEnd:
	; Slow down at $00.40px/frame, and switch to the drop move when we stop moving.
	; This doesn't call .anim, preventing iOBJInfo_FrameLeft from resetting back to iOBJInfo_FrameTotal.
	mMvC_DoFrictionH $0040
	jp   nc, .ret
		;--
		; [TCRF] Useless code, does nothing.
		ld   hl, iPlInfo_Health
		add  hl, bc
		ld   a, [hl]
		or   a					; No health left?
		jp   z, .switchToDrop	; If so, jump
		ld   hl, iPlInfo_CharIdOther
		add  hl, bc
		ld   a, [hl]			; A = Opponent CharId
		jp   .switchToDrop
		;--
.switchToDrop:
	ld   a, MOVE_SHARED_DROP_MAIN
	call Pl_SetMove_StopSpeed
	jp   .ret
; --------------- [TCRF] Unreferenced code ---------------
.unused_end:
	call Play_Pl_EndMove
.ret:
	ret
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
	
; =============== MoveC_Hit_MultiMidGS ===============
; Continuation code for HitTypeC_Hit_MultiGS (HITTYPE_HIT_MULTIGS).
;
; Handles the hit effect for hits that push/freeze the player on the ground.
; This can happen when getting hit in the middle of a ground-based super move
; that hits multiple times (HitTypeC_MultiHit_MidG*).
;
; This does nothing but animate the player (2 frames in total), giving ample time for 
; the opponent to deliver another hit as part of the super.
; Because of it, HITTYPE_HIT_MULTIGS should absolutely not be used as the last hit for a super
; move, otherwise the player gets stuck for a few seconds.
;
; Handler for:
; - MOVE_SHARED_HIT_MULTIGS.
MoveC_Hit_MultiMidGS:
	call Play_Pl_GiveKnockbackCornered
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .setManCtrl
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
; --------------- frame #0 ---------------
.setManCtrl:
	; When switching to #1, get manual control to give plenty of time for the next hit to come.
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		jp   .anim
; --------------- frame #1 ---------------
.chkEnd:
	; During normal operation, this should just wait until the opponent hits
	; us again, which starts a new move ID.
	; It should never get to Play_Pl_StartWakeUp, but...
	mMvC_ValFrameEnd .anim
		; [TCRF] ...there's a failsafe in case the next hit never comes.
		call Play_Pl_StartWakeUp
		jp   .ret
.ret:
	ret
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE

; =============== MoveC_Hit_Throw_Start ===============
; Continuation code for HitTypeC_ThrowStart (HITTYPE_THROW_START).
; 
; This handles the third part of the throw for the thrown side, which is the throw tech.
; While this happens, the opponent is either waiting in BasicInput_StartGroundThrow.loop, or
; just in the middle of performing an Air Throw or command throw.
;
; Since this move doesn't animate, it performs tasks based on the frame timer.
;
; Handler for:
; - MOVE_SHARED_THROW_START
MoveC_Hit_Throw_Start:

	; Only ground throws can be throw tech'd (leading to the wait in BasicInput_StartGroundThrow on the opponent side).
	; Everything else doesn't wait and the opponent immediately starts the throw move.
	ld   hl, iPlInfo_MoveIdOther
	add  hl, bc
	ld   a, [hl]
	cp   MOVE_SHARED_THROW_G	; iPlInfo_MoveIdOther == MOVE_SHARED_THROW_G?
	jp   nz, .chkFrame			; If not, jump
	
	; Decrement the timer for the window of opportunity.
	; If it reaches 0, the throw is confirmed.
	ld   hl, wPlayPlThrowTechTimer
	ld   a, [hl]
	or   a					; Timer == 0 already?
	jp   z, .throwConfirm	; If so, jump
	dec  [hl]				; Timer--
	jp   z, .throwConfirm	; Timer == 0? If so, jump
	
	
	;
	; Perform the input check.
	;
	; To throw tech, a player must press A or B during the window of opportunity.
	; Depending on the button pressed and its light/heavy status, the "grabbed" state is
	; canceled into a normal.
	;
	; If nothing is pressed by the time the window ends, the throw continues. 
	;
	
	
	; The CPU can't press buttons though.
	; Instead, it treats the global timer as the input, with some extra rules
	; depending on the difficulty level.
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	bit  PF0B_CPU, [hl]		; Are we a CPU?
	jp   z, .techPl			; If not, skip
.techCPU:
	
	;
	; CPU Rules:
	; - On EASY, the CPU can always be thrown.
	; - On NORMAL, there's (up to) 50% chance to throw the CPU.
	; - On HARD, it's impossible to throw it.
	;
	
	ld   a, [wDifficulty]
	cp   DIFFICULTY_EASY	; Playing on easy?
	jp   z, .ret			; If so, return (never throw tech)
	cp   DIFFICULTY_NORMAL	; Playing on normal?
	jp   z, .techCPU_normal	; If so, jump
	; Otherwise, we're playing on hard
.techCPU_hard:
	;
	; On HARD, treat the timer value directly as input.
	; Because there's a $14 frame window of opportunity and the global timer increments
	; every frame, the throw tech will eventually always happen, making it impossible to throw the CPU.
	;
	ld   a, [wTimer]		; A = Timer
	and  a, $F0				; Not necessary
	jp   .tech_chkInput
.techCPU_normal:
	;
	; On NORMAL, treat the gameplay timer as input, with 50% chance
	; of returning immediately.
	;
	
	; 50% chance we return immediately
	ld   a, [wTimer]
	and  a, $80				; Timer % $80 != 0?
	jp   z, .ret			; If so, return (no throw tech, for now)
	; Use wPlayTimer instead, possibly to randomize the result a bit more.
	; This does mean pausing can affect the result, though it'd be annoying to set up. 
	ld   a, [wPlayTimer]	; A = PlayTimer
	and  a, $F0				; Not necessary
	jp   .tech_chkInput
.techPl:
	; Human players directly use iPlInfo_JoyNewKeysLH.
	ld   hl, iPlInfo_JoyNewKeysLH
	add  hl, bc
	ld   a, [hl]
	
.tech_chkInput:
	; Depending on the input pressed, choose a move to transition.
	bit  KEPB_A_LIGHT, a	; Pressed light A?
	jp   nz, .tech_lk		; If so, start a light kick.
	bit  KEPB_B_LIGHT, a	; ...
	jp   nz, .tech_lp
	bit  KEPB_A_HEAVY, a
	jp   nz, .tech_hk
	bit  KEPB_B_HEAVY, a
	jp   nz, .tech_hp
	; If no button was pressed, return.
	; Next frame to perform the check again until the timer elapses.
	jp   .ret
.tech_lp:
	ld   a, MOVE_SHARED_PUNCH_L
	jp   .tech_setMove
.tech_hp:
	ld   a, MOVE_SHARED_PUNCH_H
	jp   .tech_setMove
.tech_lk:
	ld   a, MOVE_SHARED_KICK_L
	jp   .tech_setMove
.tech_hk:
	ld   a, MOVE_SHARED_KICK_H
.tech_setMove:
	
	; Remove throw range hitbox next frame
	ld   hl, iPlInfo_PhysHitRecv
	add  hl, bc
	ld   [hl], $01
	
	; Set standard attack flags (see BasicInput_StartLightPunch)
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	res  PF1B_GUARD, [hl]
	res  PF1B_CROUCH, [hl]
	set  PF1B_NOBASICINPUT, [hl]
	set  PF1B_XFLIPLOCK, [hl]
	set  PF1B_NOSPECSTART, [hl]
	
	; Switch to the normal
	call Pl_SetMove_ShakeScreenReset
	
	; Animate the normals as fast as possible
	ld   hl, iOBJInfo_FrameLeft
	add  hl, de
	ld   [hl], ANIMSPEED_INSTANT
	inc  hl
	ld   [hl], ANIMSPEED_INSTANT
	
	; Enable invulnerability on this
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_INVULN, [hl]
	
	; The throw is canceled.
	; This tells BasicInput_StartGroundThrow to start MOVE_SHARED_GUARDBREAK_G.
	ld   a, PLAY_THROWACT_NONE
	ld   [wPlayPlThrowActId], a
	ld   a, $00
	ld   [wPlayPlThrowTechTimer], a
	jp   .ret
.throwConfirm:
	; The throw was confirmed.
	; This tells BasicInput_StartGroundThrow to start MOVE_SHARED_THROW_G (and reset it back to PLAY_THROWACT_NEXT03).
	ld   a, PLAY_THROWACT_NEXT04
	ld   [wPlayPlThrowActId], a
	;--
	
.chkFrame:
	; We get here when the throw is (auto)confirmed.
	;
	; [POI] iOBJInfo_FrameLeft is originally set to ANIMSPEED_NONE, so normally it should never reach 1 or 0.
	;       In case it does though, there a failsafe to drop the player, using identical code to MoveC_Hit_MultiMidKnockback.
	
	; Depending on the how many frames are left...
	ld   hl, iOBJInfo_FrameLeft
	add  hl, de
	ld   a, [hl]
	cp   $00					; iOBJInfo_FrameLeft == $00? (last frame)
	jp   z, .chkEnd				; If so, jump
	cp   $01					; iOBJInfo_FrameLeft == $01?
	jp   z, .setKnockbackSpeed	; If so, jump
	; Otherwise, tick down iOBJInfo_FrameLeft
	jp   .anim
; --------------- second to last subframe ---------------
.setKnockbackSpeed:
	; Manually reset back iOBJInfo_FrameLeft to $00
	ld   [hl], $00
	
	;
	; Setup the knockback speed, depending on how long we have shaken.
	;
	ld   hl, iPlInfo_Flags3
	add  hl, bc
	bit  PF3B_HEAVYHIT, [hl]	; Was this an heavy hit?
	jp   nz, .setSpeedFast		; If so, jump
.setSpeedNorm:
	ld   hl, $0280				; Otherwise HL = $02.80px/frame (short)
	jp   .setSpeed
.setSpeedFast:
	ld   hl, $0400				; HL = $04px/frame (long)
.setSpeed:
	call Play_OBJLstS_SetSpeedH_ByXDirL
	
	; If we're on the ground, we can proceed to .chkEnd from the next frame
	; to first handle the knockback, and only drop on the ground when we stop moving.
	
	; If we're in the air though, drop down immediately using the just set speed settings.
	; Unlike the version in MoveC_Hit_MultiMidKnockback, this in theory could jump since
	; it doesn't force the player to be on the ground... but in practice it's impossible for air throws to fail.
	ld   hl, iOBJInfo_Y
	add  hl, de
	ld   a, [hl]			; A = Y Pos
	cp   PL_FLOOR_POS		; A == PL_FLOOR_POS?
	jp   nz, .switchToDrop	; If not, jump
	
	jp   .ret
; --------------- last subframe ---------------
.chkEnd:
	; Slow down at $00.40px/frame, and switch to the drop move when we stop moving.
	; This doesn't call .anim, preventing iOBJInfo_FrameLeft from resetting back to iOBJInfo_FrameTotal.
	mMvC_DoFrictionH $0040
	jp   nc, .ret
		;--
		; [TCRF] Useless code, does nothing.
		ld   hl, iPlInfo_Health
		add  hl, bc
		ld   a, [hl]
		or   a					; No health left?
		jp   z, .switchToDrop	; If so, jump
		ld   hl, iPlInfo_CharIdOther
		add  hl, bc
		ld   a, [hl]			; A = Opponent CharId
		jp   .switchToDrop
		;--
.switchToDrop:
	ld   a, MOVE_SHARED_DROP_MAIN
	call Pl_SetMove_StopSpeed
	jp   .ret
; --------------- [TCRF] Unreferenced code ---------------
.unused_end:
	call Play_Pl_EndMove
; --------------- common ---------------
.ret:
	ret
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
	
; =============== MoveC_Hit_Throw_Rot ===============
; Continuation code for HitTypeC_ThrowRot*, the rotation frames (HITTYPE_THROW_ROT*).
;
; In practice, only used to sync the player's position with the opponent's, if enabled.
;
; Handler for:
; - MOVE_SHARED_THROW_ROTU
; - MOVE_SHARED_THROW_ROTL
; - MOVE_SHARED_THROW_ROTD
; - MOVE_SHARED_THROW_ROTR
MoveC_Hit_Throw_Rot:
	; Deliver knockback to the opponent, if needed
	call Play_Pl_GiveKnockbackCornered
	; Equivalent to mMvC_ValLoaded for a single frame
	call OBJLstS_IsGFXLoadDone
	jp   nz, .chkContMove
	
	; [POI] iOBJInfo_FrameLeft is initially set at ANIMSPEED_NONE when we get here.
	;       It should never elapse, but in case it does, depending on the how many frames are left...
	ld   hl, iOBJInfo_FrameLeft
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, .chkEnd
	cp   $01
	jp   z, .setKnockbackSpeed
.chkContMove:
	;
	; If enabled, reposition the player every frame like HitTypeC_ThrowRotCustom did once.
	;
	ld   a, [wPlayPlThrowRotSync]
	or   a									; Sync enabled?
	jp   z, .anim							; If not, skip
	call HitTypeS_SyncPlPosFromOtherPos		; Move over opponent
	; The position is relative to the opponent facing left, meaning it's more or less equivalent
	; to the standard "player facing right" relative positioning.
	ld   a, [wPlayPlThrowRotMoveH]			; Move forward by wPlayPlThrowRotMoveH
	ld   h, a								
	ld   l, $00
	call Play_OBJLstS_MoveH_ByOtherXFlipL
	ld   a, [wPlayPlThrowRotMoveV]			; Move down by wPlayPlThrowRotMoveV
	ld   h, a
	ld   l, $00
	call Play_OBJLstS_MoveV
	jp   .anim
	

; --------------- second to last subframe ---------------
;
; Fallback similar to the one in MoveC_Hit_MultiMidKnockback.
;
.setKnockbackSpeed:
	; Manually reset back iOBJInfo_FrameLeft to $00, since we're not calling .anim (even though we could have if we really wanted).
	ld   [hl], $00
	
	; Setup the knockback speed, depending on how long we have shaken.
	ld   hl, iPlInfo_Flags3
	add  hl, bc
	bit  PF3B_HEAVYHIT, [hl]	; Was this an heavy hit?
	jp   nz, .setSpeedFast		; If so, jump
.setSpeedNorm:
	ld   hl, $0280				; Otherwise HL = $02.80px/frame (short)
	jp   .setSpeed
.setSpeedFast:
	ld   hl, $0400				; HL = $04px/frame (long)
.setSpeed:
	call Play_OBJLstS_SetSpeedH_ByXDirL
	
	; If we're on the ground, we can proceed to .chkEnd from the next frame
	; to first handle the knockback, and only drop on the ground when we stop moving.
	; If we're in the air though, drop down immediately using the just set speed settings.
	ld   hl, iOBJInfo_Y
	add  hl, de
	ld   a, [hl]			; A = Y Pos
	cp   PL_FLOOR_POS		; A == PL_FLOOR_POS?
	jp   nz, .switchToDrop	; If not, jump
	
	jp   .ret
; --------------- last subframe ---------------
.chkEnd:
	; Slow down at $00.40px/frame, and switch to the drop move when we stop moving.
	; This doesn't call .anim, preventing iOBJInfo_FrameLeft from resetting back to iOBJInfo_FrameTotal.
	mMvC_DoFrictionH $0040
	jp   nc, .ret
		; If we died, just end the move.
		; Hopefully we are on the ground when this happens.
		ld   hl, iPlInfo_Health
		add  hl, bc
		ld   a, [hl]
		or   a				; No health left?
		jp   nz, .end		; If so, jump
.switchToDrop:
	ld   a, MOVE_SHARED_DROP_MAIN
	call Pl_SetMove_StopSpeed
	jp   .ret
; --------------- common ---------------
.end:
	call Play_Pl_EndMove
.ret:
	ret
.anim:
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
	mMvIn_ValSuper .chkPunchNoSuper
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
	; [POI] Hidden heavy version with the powerup cheat.
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
	mMvIn_ValClose MoveInputReader_Ryo_NoMove
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
	mMvIn_ValProjActive Ryo
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
	
; =============== MoveC_Ryo_KoOuKen ===============
; Move code for Ryo's Ko-Ou Ken (MOVE_RYO_KO_OU_KEN_L, MOVE_RYO_KO_OU_KEN_H).	
MoveC_Ryo_KoOuKen:
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
		; Light version moves forward 7px
		call MoveInputS_CheckMoveLHVer
		jp   z, .obj1_cont		; Is the heavy triggered? If not, jump
		mMvC_SetMoveH $0700
.obj1_cont:
	mMvC_ValFrameEnd .anim
		mMvC_PlaySound SCT_PROJ_LG_B
		jp   .anim
; --------------- frame #2 ---------------
; Nothing!
.obj2:	
	mMvC_ValFrameStart .obj2_cont
		call MoveInputS_CheckMoveLHVer
		jp   z, .obj2_cont		; Is the heavy triggered? If not, jump
.obj2_cont:
	mMvC_ValFrameEnd .anim
		jp   .anim
; --------------- frame #4 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jp   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Ryo_MouKoRaiJinGou ===============
; Move code for Ryo's Mou Ko Rai Jin Gou (MOVE_RYO_MOU_KO_RAI_JIN_GOU_L, MOVE_RYO_MOU_KO_RAI_JIN_GOU_H).	
MoveC_Ryo_MouKoRaiJinGou:
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
	jp   .anim ; We never get here
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $02
		jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameStart .obj1_cont
		mMvC_PlaySound SCT_MOVEJUMP_A
		ld   hl, iPlInfo_Flags1
		add  hl, bc
		res  PF1B_INVULN, [hl]
		res  PF1B_GUARD, [hl]
		; Pick dash speed depending on move strength
		mMvIn_ChkLHE .obj1_setDashH, .obj1_setDashE
	.obj1_setDashL: ; Light
		mMvC_SetSpeedH $0400
		jp   .moveH_m40
	.obj1_setDashH: ; Heavy
		mMvC_SetSpeedH $0500
		jp   .moveH_m40
	.obj1_setDashE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH $0600
		jp   .moveH_m40
.obj1_cont:
	mMvC_ValFrameEnd .moveH_m40
		mMvC_SetDamageNext $04, HITTYPE_HIT_MID1, PF3_LASTHIT
		jp   .moveH_m40
; --------------- frame #2 ---------------
.obj2:
	mMvC_ValFrameEnd .moveH_m40
		mMvC_SetDamageNext $04, HITTYPE_DROP_MAIN, PF3_LASTHIT
		jp   .moveH_m40
; --------------- frame #3 ---------------
.obj3:
	mMvC_ValFrameEnd .moveH_m40
		mMvC_SetAnimSpeed $08
		jp   .moveH_m40
; --------------- frames #1-3 / common horizontal movement + slow down ---------------
.moveH_m40:
	mMvC_DoFrictionH $0040
	jp   .anim
; --------------- frame #4 ---------------
.obj4:
	mMvC_DoFrictionH $0080
	jp   .anim
; --------------- frame #5 ---------------
.chkEnd:
	mMvC_DoFrictionH $0080
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Ryo_HienShippuKyaku ===============
; Move code for Ryo's Hien Shippu Kyaku  (MOVE_RYO_HIEN_SHIPPU_KYAKU_L, MOVE_RYO_HIEN_SHIPPU_KYAKU_H).
MoveC_Ryo_HienShippuKyaku:
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
	jp   z, .doGravity
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj3
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .doGravity
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .doGravity ; We never get here
; --------------- frame #0 ---------------	
.obj0:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $03
		jp   .anim
; --------------- frame #1 ---------------	
.obj1:
	mMvC_ValFrameStart .obj1_cont
		mMvC_PlaySound SCT_MOVEJUMP_A
		mMvIn_ChkLHE .obj1_setJumpH, .obj1_setJumpE
	.obj1_setJumpL: ; Light
		mMvC_SetSpeedH $0300
		mMvC_SetSpeedV -$0200
		jp   .doGravity
	.obj1_setJumpH: ; Heavy
		mMvC_SetSpeedH $0400
		mMvC_SetSpeedV -$0280
		jp   .doGravity
	.obj1_setJumpE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH $0500
		mMvC_SetSpeedV -$0300
		jp   .doGravity
.obj1_cont:
	mMvC_ValFrameEnd .doGravity
		
		; Set a different move speed between heavy and light.
		; The light version in particular sets ANIMSPEED_NONE.
		; This prevents the light move from using frame #3 where extra damage is dealt.
		
		inc  hl	; Seek to iOBJInfo_FrameTotal
		push hl
			ld   hl, iPlInfo_MoveId
			add  hl, bc
			ld   a, [hl]
			cp   MOVE_RYO_HIEN_SHIPPU_KYAKU_H	; Using the heavy version?
			jp   z, .obj1_setNextH				; If so, jump
		.obj1_setNextL:
		pop  hl
		ld   [hl], ANIMSPEED_NONE
		jp   .doGravity
		.obj1_setNextH:
		pop  hl
		ld   [hl], $03
		jp   .doGravity
; --------------- frame #3 ---------------	
.obj3:
	mMvC_ValFrameEnd .doGravity
	mMvC_SetAnimSpeed ANIMSPEED_NONE
	mMvC_SetDamageNext $08, HITTYPE_DROP_MAIN, PF3_HEAVYHIT
	jp   .doGravity
; --------------- common gravity check ---------------	
.doGravity:
	mMvC_ChkGravityHV $0030, .anim
		mMvC_SetLandFrame $05*OBJLSTPTR_ENTRYSIZE, $05
		jp   .ret
; --------------- frame #5 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jp   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Ryo_RyuKoRanbuS ===============
; Move code for the normal version of Ryo's Ryu Ko Ranbu (MOVE_RYO_RYU_KO_RANBU_S).
MoveC_Ryo_RyuKoRanbuS:
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
	jp   z, .objOdd
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $07*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $09*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $0B*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $0D*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $0F*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $10*OBJLSTPTR_ENTRYSIZE
	jp   z, .startKoHou
	cp   $11*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $13*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $15*OBJLSTPTR_ENTRYSIZE
	jp   z, .startKoHou
	cp   $16*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .objEven
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameStart .obj0_getManCtrl
	; Nothing
.obj0_getManCtrl:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameStart .obj1_chkGuard
		mMvC_PlaySound SCT_MOVEJUMP_A
		; Set different jump speed depending on light / heavy version.
		mMvIn_ChkLH .obj1_setJumpH
	.obj1_setJumpL:
		mMvC_SetSpeedH +$05FF
		mMvC_SetSpeedV -$0200
		jp   .doGravity
	.obj1_setJumpH:
		mMvC_SetSpeedH +$06FF
		mMvC_SetSpeedV -$0280
		jp   .doGravity
.obj1_chkGuard:

IF REV_VER_2 == 0
	;
	; Continue the jump until hitting the opponent.
	;
	ld   hl, iPlInfo_ColiFlags
	add  hl, bc
	bit  PCF_HITOTHER, [hl]				; Did we reach?
	jp   z, .obj1_chkGuard_doGravity	; If not, skip
	ld   hl, iPlInfo_Flags1Other
	add  hl, bc
	bit  PF1B_INVULN, [hl]				; Is the opponent invulnerable?
	jp   nz, .obj1_chkGuard_doGravity	; If so, skip
	bit  PF1B_HITRECV, [hl]				; Did the opponent get hit?
	jp   z, .obj1_chkGuard_doGravity	; If not, skip	
	
	bit  PF1B_GUARD, [hl]				; Is the opponent blocking?
	jp   nz, .obj1_chkGuard_guard		; If so, jump
ELSE
	; Identical check, but calling the copy in BANK 0 to save space.
	mMvC_ValHit .obj1_chkGuard_doGravity, .obj1_chkGuard_guard
ENDC
	.obj1_chkGuard_noGuard:
		; Otherwise, continue to #2
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI1, PF3_LASTHIT
		mMvC_SetFrame $02*OBJLSTPTR_ENTRYSIZE, $01
		mMvC_SetSpeedH $0000
		; Force player on the ground
		ld   hl, iOBJInfo_Y
		add  hl, de
		ld   [hl], PL_FLOOR_POS
		jp   .ret
.obj1_chkGuard_guard:
	; If the opponent blocked the hit, slow down considerably.
	; This will still moves us back for overlapping with the opponent.
	mMvC_SetSpeedH $0100
.obj1_chkGuard_doGravity:
	jp   .doGravity
; --------------- frames #3,5,7,9... ---------------
; Generic damage - odd frames.
; Alongside .objEven is used to alternate between hit effects constantly.
.objOdd:
	call OBJLstS_ApplyXSpeed
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI1, PF3_LASTHIT
		jp   .chkOtherEscape
; --------------- frame #2 ---------------
; Initial frame before the odd/even switching.
; This sets the initial jump speed and doesn't check for block yet.
.obj2:
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI0, PF3_LASTHIT
		mMvC_SetSpeedH $0080
		jp   .anim
; --------------- frames #4,6,8,A,... ---------------
; Generic damage - even frames.
.objEven:
	call OBJLstS_ApplyXSpeed
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI0, PF3_LASTHIT
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
			; Otherwise, transition to hop
			ld   a, MOVE_SHARED_HOP_B
			call Pl_SetMove_StopSpeed
			jp   .ret
; --------------- frame #15 ---------------
; Transitions to Ko Hou at the end of the frame.	
.startKoHou:
	mMvC_ValFrameEnd .anim
		mMvIn_ChkLH .startKoHouH
	.startKoHouL:
		ld   a, MOVE_RYO_KO_HOU_L
		jp   .startKoHou_setMove
	.startKoHouH:
		ld   a, MOVE_RYO_KO_HOU_H
	.startKoHou_setMove:
		call MoveInputS_SetSpecMove_StopSpeed
		mMvC_SetDamageNext $06, HITTYPE_DROP_MAIN, PF3_LASTHIT
		jp   .ret
; --------------- common gravity check ---------------	
.doGravity:
	mMvC_ChkGravityHV $0030, .anim
		mMvC_SetLandFrame $16*OBJLSTPTR_ENTRYSIZE, $07
		jp   .ret
; --------------- frame #16 ---------------
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
	
; =============== MoveC_Ryo_RyuKoRanbuD ===============
; Move code for the desperation version of Ryo's Ryu Ko Ranbu (MOVE_RYO_RYU_KO_RANBU_D).
MoveC_Ryo_RyuKoRanbuD:
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
	jp   z, .objOdd
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $07*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $09*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $0B*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $0D*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $0F*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $11*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $13*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $15*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $17*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $19*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $1B*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $1D*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $1F*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $21*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $23*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $25*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $26*OBJLSTPTR_ENTRYSIZE
	jp   z, .startKoHou
	cp   $27*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $29*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $2B*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $2C*OBJLSTPTR_ENTRYSIZE
	jp   z, .startKoHou
	cp   $2D*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .objEven
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameStart .obj1_chkGuard
		mMvC_PlaySound SCT_MOVEJUMP_A
		; Set different jump speed depending on light / heavy version.
		mMvIn_ChkLH .obj1_setJumpH
	.obj1_setJumpL:
		mMvC_SetSpeedH +$05FF
		mMvC_SetSpeedV -$0200
		jp   .doGravity
	.obj1_setJumpH:
		mMvC_SetSpeedH +$06FF
		mMvC_SetSpeedV -$0280
		jp   .doGravity
.obj1_chkGuard:
IF REV_VER_2 == 0
	;
	; Continue the jump until hitting the opponent.
	;
	ld   hl, iPlInfo_ColiFlags
	add  hl, bc
	bit  PCF_HITOTHER, [hl]				; Did we reach?
	jp   z, .obj1_chkGuard_doGravity	; If not, skip
	ld   hl, iPlInfo_Flags1Other
	add  hl, bc
	bit  PF1B_INVULN, [hl]				; Is the opponent invulnerable?
	jp   nz, .obj1_chkGuard_doGravity	; If so, skip
	bit  PF1B_HITRECV, [hl]				; Did the opponent get hit?
	jp   z, .obj1_chkGuard_doGravity	; If not, skip	
	
	bit  PF1B_GUARD, [hl]				; Is the opponent blocking?
	jp   nz, .obj1_chkGuard_guard		; If so, jump
ELSE
	; Identical check, but calling the copy in BANK 0 to save space.
	mMvC_ValHit .obj1_chkGuard_doGravity, .obj1_chkGuard_guard
ENDC
	.obj1_chkGuard_noGuard:
		; Otherwise, continue to #2
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI1, PF3_LASTHIT
		mMvC_SetFrame $02*OBJLSTPTR_ENTRYSIZE, $01
		mMvC_SetSpeedH $0000
		; Force player on the ground
		ld   hl, iOBJInfo_Y
		add  hl, de
		ld   [hl], PL_FLOOR_POS
		jp   .ret
.obj1_chkGuard_guard:
	; If the opponent blocked the hit, slow down considerably.
	; This will still moves us back for overlapping with the opponent.
	mMvC_SetSpeedH $0100
.obj1_chkGuard_doGravity:
	jp   .doGravity
; --------------- frames #3,5,7,9... ---------------
; Generic damage - odd frames.
; Alongside .objEven is used to alternate between hit effects constantly.
.objOdd:
	call OBJLstS_ApplyXSpeed
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI1, PF3_LASTHIT
		jp   .chkOtherEscape
; --------------- frame #2 ---------------
; Initial frame before the odd/even switching.
; This sets the initial jump speed and doesn't check for block yet.
.obj2:
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI0, PF3_LASTHIT
		mMvC_SetSpeedH $0080
		jp   .anim
; --------------- frames #4,6,8,A,... ---------------
; Generic damage - even frames.
.objEven:
	call OBJLstS_ApplyXSpeed
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI0, PF3_LASTHIT
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
			; Otherwise, transition to hop
			ld   a, MOVE_SHARED_HOP_B
			call Pl_SetMove_StopSpeed
			jp   .ret
		
; --------------- frame #2C ---------------
; Transitions to an hidden version of Ko Ou Ken at the end of the frame.
.startKoHou:
	mMvC_ValFrameEnd .anim
		mMvIn_ChkLH .startKoHouH
	.startKoHouL:
		ld   a, MOVE_RYO_KO_HOU_EL
		jp   .startKoHou_setMove
	.startKoHouH:
		ld   a, MOVE_RYO_KO_HOU_EH
	.startKoHou_setMove:
		call MoveInputS_SetSpecMove_StopSpeed
		mMvC_SetDamageNext $02, HITTYPE_DROP_MAIN, PF3_LASTHIT
		jp   .ret
; --------------- common gravity check ---------------	
.doGravity:
	mMvC_ChkGravityHV $0030, .anim
		mMvC_SetLandFrame $2D*OBJLSTPTR_ENTRYSIZE, $07
		jp   .ret
; --------------- frame #2D ---------------
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
	mMvIn_ValSuper .chkPunchNoSuper
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
	; [POI] Move has an hidden version.
	;       Compared to the normal one, it acts like Rising Tackle.
	mMvIn_GetLHE MOVE_ROBERT_RYUU_GA_L, MOVE_ROBERT_RYUU_GA_H, MoveInit_Robert_RyuuGa_Hidden
	call MoveInputS_SetSpecMove_StopSpeed
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_INVULN, [hl]
	jp   MoveInputReader_Robert_SetMove
; =============== MoveInit_Robert_KyokugenRyuRanbuKyaku ===============
MoveInit_Robert_KyokugenRyuRanbuKyaku:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_ValClose MoveInputReader_Robert_NoMove
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
	mMvIn_ValProjActive Robert
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
	
; =============== MoveC_Robert_RyuuGekiKen ===============
; Move code for Robert's Ryuu Geki Ken (MOVE_ROBERT_RYUU_GEKI_KEN_L, MOVE_ROBERT_RYUU_GEKI_KEN_H).
MoveC_Robert_RyuuGekiKen:
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
	cp   $09*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim
; --------------- frame #1 ---------------	
.obj1:
	mMvC_ValFrameStart .obj1_cont
		; The light version moves the player 7px forward
		call MoveInputS_CheckMoveLHVer
		jp   z, .obj1_cont
		mMvC_SetMoveH +$0700
.obj1_cont:
	mMvC_ValFrameEnd .anim
		mMvC_PlaySound SCT_PROJ_LG_B
		jp   .anim
; --------------- frame #2 ---------------	
.obj2:
	mMvC_ValFrameStart .obj2_cont
		; The light version moves the player 7px forward
		call MoveInputS_CheckMoveLHVer
		jp   z, .obj2_cont
		mMvC_SetMoveH +$0700
.obj2_cont:
	mMvC_ValFrameEnd .anim
	jp   .anim
; --------------- frame #9 ---------------	
.chkEnd:
	mMvC_ValFrameEnd .anim
	call Play_Pl_EndMove
	jp   .ret
; --------------- common ---------------	
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Robert_HienShippuKyaku ===============
; Move code for Robert's Hien Shippu Kyaku  (MOVE_ROBERT_HIEN_SHIPPU_KYAKU_L, MOVE_ROBERT_HIEN_SHIPPU_KYAKU_H).
MoveC_Robert_HienShippuKyaku:
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
; --------------- frame #0 ---------------	
.obj0:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_INSTANT
		jp   .anim
; --------------- frame #1 ---------------	
.obj1:
	mMvC_ValFrameStart .obj1_cont
		mMvC_PlaySound SCT_MOVEJUMP_A
		mMvIn_ChkLHE .obj1_setJumpH, .obj1_setJumpE
	.obj1_setJumpL: ; Light
		mMvC_SetSpeedH +$0300
		mMvC_SetSpeedV -$0180
		jp   .obj1_cont
	.obj1_setJumpH: ; Heavy
		mMvC_SetSpeedH $0400
		mMvC_SetSpeedV -$0200
		jp   .obj1_cont
	.obj1_setJumpE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH +$0500
		mMvC_SetSpeedV -$0240
.obj1_cont:
	jp   .doGravity
; --------------- frame #2 ---------------	
.obj2:
	mMvC_ValFrameEnd .doGravity
		mMvC_SetDamageNext $04, HITTYPE_HIT_MID1, PF3_LASTHIT
		mMvC_PlaySound SCT_MOVEJUMP_A
		jp   .doGravity
; --------------- frame #3 ---------------	
.obj3:
	jp   .doGravity
; --------------- frame #4 ---------------	
.obj4:
	mMvC_ValFrameEnd .doGravity
		mMvC_SetDamageNext $04, HITTYPE_HIT_MID0, PF3_LASTHIT
		mMvC_PlaySound SCT_MOVEJUMP_A
		jp   .doGravity
; --------------- frame #5 ---------------	
.obj5:
	mMvC_ValFrameEnd .doGravity
		; Loop back to #2 if we didn't touch the ground yet
		ld   hl, iOBJInfo_OBJLstPtrTblOffset
		add  hl, de
		ld   [hl], $01*OBJLSTPTR_ENTRYSIZE ; offset by -1
		jp   .doGravity
; --------------- common gravity check ---------------	
.doGravity:
	; Only advance to #6 when touching the ground
	mMvC_ChkGravityHV $0018, .anim
		mMvC_SetLandFrame $06*OBJLSTPTR_ENTRYSIZE, $08
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
	
; =============== MoveC_Robert_HienRyuuShinKya ===============
; Move code for Robert's Hien Ryuu Shin Kya (MOVE_ROBERT_HIEN_RYUU_SHIN_KYA_L, MOVE_ROBERT_HIEN_RYUU_SHIN_KYA_H).
MoveC_Robert_HienRyuuShinKya:
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_IsMoveLoading
	jp   c, .ret
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   a, $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj0
	cp   a, $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
	cp   a, $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	cp   a, $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj3
	cp   a, $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj4
	cp   a, $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj5
	cp   a, $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj6
	cp   a, $07*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj7
	cp   a, $08*OBJLSTPTR_ENTRYSIZE
	jp   z, .doGravityHit
	cp   a, $09*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim ; We never get here
; --------------- frame #0 ---------------	
.obj0:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		jp   .anim
; --------------- frame #1 ---------------	
.obj1:
	mMvC_ValFrameStart .obj1_cont
		mMvC_PlaySound SCT_MOVEJUMP_A
		mMvIn_ChkLHE .obj1_setArcH, .obj1_setArcE
	.obj1_setArcL: ; Light
		mMvC_SetSpeedH +$0300
		mMvC_SetSpeedV +$0200
		jp   .obj1_doGravity
	.obj1_setArcH: ; Heavy
		mMvC_SetSpeedH +$0500
		mMvC_SetSpeedV +$0180
		jp   .obj1_doGravity
	.obj1_setArcE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH +$0700
		mMvC_SetSpeedV +$0000
	.obj1_doGravity:
		jp   .doGravity
.obj1_cont:

IF REV_VER_2 == 0
	;
	; If the opponent blocks the attack, do an hyper jump backwards.
	;
	ld   hl, iPlInfo_ColiFlags
	add  hl, bc
	bit  PCF_HITOTHER, [hl]			; Did we reach?
	jp   z, .obj1_cont_doGravity	; If not, skip
	ld   hl, iPlInfo_Flags1Other
	add  hl, bc
	bit  PF1B_INVULN, [hl]			; Is the opponent invulnerable?
	jp   nz, .obj1_cont_doGravity	; If so, skip
	bit  PF1B_HITRECV, [hl]			; Did the opponent get hit?
	jp   z, .obj1_cont_doGravity	; If not, skip
	; (shortcut, usually this is a nz check)
	bit  PF1B_GUARD, [hl]			; Is the opponent blocking?
	jp   z, .obj1_cont_doGravity	; If not, skip
ELSE
	; Identical check, but calling the copy in BANK 0 to save space.
	; However, because it's using the standard check, the shortcut is no longer
	; there and the jump is structured differently.
	mMvC_ValHit .obj1_cont_doGravity, .obj1_cont_onBlock
	jp   .obj1_cont_doGravity
ENDC
.obj1_cont_onBlock:
	mMvC_SetFrame $03*OBJLSTPTR_ENTRYSIZE, ANIMSPEED_NONE
	mMvC_SetSpeedH +$0000
	mMvC_SetSpeedV +$0000
.obj1_cont_doGravity:
	jp   .doGravity
; --------------- common gravity ---------------	
.doGravity:
	; Move down relatively slow, and switch to #2 when we land.
	ld   hl, $0018
	call OBJLstS_ApplyGravityVAndMoveHV
	jp   nc, .anim
		mMvC_SetLandFrame $02*OBJLSTPTR_ENTRYSIZE, $08
		jp   .ret
; --------------- backjump - frame #3 ---------------	
.obj3:
	; Set initial jump speed the first time we get here
	mMvC_ValFrameStart .obj3_cont
		mMvC_SetSpeedH -$0300
		mMvC_SetSpeedV -$0600
.obj3_cont: 
	mMvC_NextFrameOnGtYSpeed -$08, ANIMSPEED_NONE
	jp   .doGravityHit
; --------------- backjump - frame #4 ---------------	
.obj4:
	mMvC_NextFrameOnGtYSpeed -$05, ANIMSPEED_NONE
	jp   .doGravityHit
; --------------- backjump - frame #5 ---------------	
.obj5:
	mMvC_NextFrameOnGtYSpeed -$03, ANIMSPEED_NONE
	jp   .doGravityHit
; --------------- backjump - frame #6 ---------------	
.obj6:
	mMvC_NextFrameOnGtYSpeed -$01, ANIMSPEED_NONE
	jp   .doGravityHit
; --------------- backjump - frame #7 ---------------	
.obj7: 
	mMvC_NextFrameOnGtYSpeed +$00, ANIMSPEED_NONE
	jp   .doGravityHit
; --------------- common gravity after block ---------------	
.doGravityHit:
	; Move down faster with the hyper jump.
	; Switch to #9 when we land.
	ld   hl, $0060
	call OBJLstS_ApplyGravityVAndMoveHV
	jp   nc, .anim
		mMvC_SetLandFrame $09*OBJLSTPTR_ENTRYSIZE, $04
		jp   .ret
; --------------- frame #9 ---------------	
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------	
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Robert_RyuuGa ===============
; Move code for Robert's Ryuu Ga (MOVE_ROBERT_RYUU_GA_L, MOVE_ROBERT_RYUU_GA_H).
MoveC_Robert_RyuuGa:
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
	jp   z, .chkEnd
; --------------- frame #1 ---------------	
.obj1:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		mMvC_PlaySound SFX_FIREHIT_A
		mMvIn_ChkLHE .obj1_setHitH, .obj1_setHitE
	.obj1_setHitL: ; Light
		mMvC_SetDamageNext $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT
		jp   .anim
	.obj1_setHitH: ; Heavy
		mMvC_SetDamageNext $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT
		jp   .anim
	.obj1_setHitE: ; [POI] Hidden Heavy
		mMvC_SetDamageNext $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_LASTHIT
		jp   .anim
; --------------- frame #1 ---------------	
.obj2:
	mMvC_ValFrameStart .obj2_cont
		mMvC_SetMoveH $0700
		ld   hl, iPlInfo_Flags0
		add  hl, bc
		inc  hl	; Seek to iPlInfo_Flags1
		res  PF1B_INVULN, [hl]
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
	mMvC_NextFrameOnGtYSpeed -$06, ANIMSPEED_NONE
	; No difference
	jp   nc, .doGravity
	jp   .doGravity
; --------------- frame #3 ---------------	
.obj3:
	mMvC_SetSpeedH $0040
	mMvC_NextFrameOnGtYSpeed +$01, ANIMSPEED_NONE
	jp   .doGravity
; --------------- frame #4 ---------------	
.obj4:
	mMvC_SetSpeedH $0040
; --------------- frame #1-4 / common gravity ---------------	
.doGravity:
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $05*OBJLSTPTR_ENTRYSIZE, $03
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
	
; =============== MoveC_Terry_RisingTackle ===============
; Move code for several Rising Tackle-like moves:
; - Hidden version of Robert's Ryuu Ga (MOVE_ROBERT_RYUU_GA_HIDDEN_L, MOVE_ROBERT_RYUU_GA_HIDDEN_H)
; - Chizuru's 100 Katso Tenjin no Kotowari (MOVE_CHIZURU_TENJIN_KOTOWARI_L, MOVE_CHIZURU_TENJIN_KOTOWARI_H)
; - Hidden version of Ryo's Ko Ou Ken (MOVE_RYO_KO_HOU_EL, MOVE_RYO_KO_HOU_EH)
; - Hidden version of Mr. Karate's Ko Ou Ken (MOVE_MRKARATE_KO_OU_KEN_UNUSED_EL, MOVE_MRKARATE_KO_OU_KEN_UNUSED_EH)
; - Terry's Rising Tackle (MOVE_TERRY_RISING_TACKLE_L, MOVE_TERRY_RISING_TACKLE_H)
; This version of Rising Tackle deals continuous low damage.
MoveC_Terry_RisingTackle:
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
	jp   z, .obj6
	cp   $07*OBJLSTPTR_ENTRYSIZE
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
		res  PF1B_GUARD, [hl]
		mMvIn_ChkLHE .setJumpH, .setJumpE
	.setJumpL: ; Light
		mMvC_SetSpeedH +$0080
		mMvC_SetSpeedV -$0600
		jp   .obj1_doGravity
	.setJumpH: ; Heavy
		mMvC_SetSpeedH +$0100
		mMvC_SetSpeedV -$0700
		jp   .obj1_doGravity
	.setJumpE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH +$01C0
		mMvC_SetSpeedV -$0800
	.obj1_doGravity:
		jp   .doGravity
.obj1_cont:
	; Continuous damage
	mMvC_SetDamage $02, HITTYPE_DROP_MAIN, PF3_LASTHIT
	jp   .doGravity
	
; --------------- frames #2-3 ---------------
; Attack frames.	
.obj2:
	mMvC_SetDamage $02, HITTYPE_DROP_MAIN, PF3_LASTHIT
	mMvC_ValFrameEnd .doGravity
		; Skip to #5 if YSpeed > -$03
		mMvC_NextFrameOnGtYSpeed -$03, ANIMSPEED_NONE
		jp   nc, .doGravity
		ld   hl, iOBJInfo_OBJLstPtrTblOffset
		add  hl, de
		ld   [hl], $04*OBJLSTPTR_ENTRYSIZE ; offset by -1
		jp   .doGravity
; --------------- frame #4 ---------------
; Attack frames with loop check.
.obj4:
	mMvC_SetDamage $02, HITTYPE_DROP_MAIN, PF3_LASTHIT
	mMvC_ValFrameEnd .doGravity
		; Continue looping to #2 until YSpeed > -$03
		mMvC_NextFrameOnGtYSpeed -$03, ANIMSPEED_NONE	; YSpeed > -$03?
		jp   nc, .obj4_loop								; If not, loop
		; Otherwise, proceed to #5
		jp   .doGravity
	.obj4_loop:
		ld   hl, iOBJInfo_OBJLstPtrTblOffset
		add  hl, de
		ld   [hl], $01*OBJLSTPTR_ENTRYSIZE ; offset by -1
		jp   .doGravity
; --------------- frame #5 ---------------	
; Jump arc peak.
.obj5:
	mMvC_SetSpeedH $0040
	mMvC_NextFrameOnGtYSpeed +$00, ANIMSPEED_NONE
	jp   .doGravity
; --------------- frame #6 ---------------
; Downwards movement.
.obj6:
	mMvC_SetSpeedH $0040
; --------------- common gravity check ---------------
.doGravity:
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $07*OBJLSTPTR_ENTRYSIZE, $08
		jp   .ret
; --------------- frame #7 ---------------	
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Robert_KyokugenRyuRanbuKyaku ===============
; Move code for Ryo's Kyokuken Ryu Renbu Ken and similar moves from other AOF characters:
; - Robert's Kyokugen Ryu Ranbu Kyaku (MOVE_ROBERT_KYOKUGEN_RYU_RANBU_KYAKU_L, MOVE_ROBERT_KYOKUGEN_RYU_RANBU_KYAKU_H)
; - Ryo's Kyokuken Ryu Renbu Ken (MOVE_RYO_KYOKUKEN_RYU_RENBU_KEN_L, MOVE_RYO_KYOKUKEN_RYU_RENBU_KEN_H)
; - Mr. Karate's Kyokuken Ryu Renbu Ken (MOVE_MRKARATE_KYOKUKEN_RYU_RENBU_KEN_L, MOVE_MRKARATE_KYOKUKEN_RYU_RENBU_KEN_H)
MoveC_Robert_KyokugenRyuRanbuKyaku:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj3
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj5
	cp   $07*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim
; --------------- frame #1 ---------------	
.obj1:
	mMvC_ValFrameStart .obj1_cont
		mMvC_SetMoveH $0400
.obj1_cont:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $04, HITTYPE_HIT_MID0, PF3_LASTHIT
		mMvC_PlaySound SCT_HEAVY
		jp   .anim
; --------------- frame #3 ---------------	
.obj3:
	mMvC_ValFrameStart .obj3_cont
		mMvC_SetMoveH $0200
.obj3_cont:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $04, HITTYPE_HIT_MID1, PF3_LASTHIT
		mMvC_PlaySound SCT_HEAVY
		jp   .anim
; --------------- frame #5 ---------------	
.obj5:
	mMvC_ValFrameStart .obj5_cont
		mMvC_SetMoveH $0600
.obj5_cont:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $04, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_LASTHIT
		mMvC_PlaySound SCT_HEAVY
		jp   .anim
; --------------- frame #7 ---------------	
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------	
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Robert_RyuKoRanbuS ===============
; Move code for the normal super version of Robert's Ryu Ko Ranbu. (MOVE_ROBERT_RYU_KO_RANBU_S)
MoveC_Robert_RyuKoRanbuS:
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
	jp   z, .objOdd
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $07*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $09*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $0B*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $0D*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $0F*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $10*OBJLSTPTR_ENTRYSIZE
	jp   z, .startRyuuGa
	cp   $11*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .objEven
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameStart .obj0_getManCtrl
	; Nothing
.obj0_getManCtrl:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameStart .obj1_chkGuard
		mMvC_PlaySound SCT_MOVEJUMP_A
		; Set different jump speed depending on light / heavy version.
		mMvIn_ChkLH .obj1_setJumpH
	.obj1_setJumpL:
		mMvC_SetSpeedH +$05FF
		mMvC_SetSpeedV -$0200
		jp   .doGravity
	.obj1_setJumpH:
		mMvC_SetSpeedH +$06FF
		mMvC_SetSpeedV -$0280
		jp   .doGravity
.obj1_chkGuard:
IF REV_VER_2 == 0
	;
	; Continue the jump until hitting the opponent.
	;
	ld   hl, iPlInfo_ColiFlags
	add  hl, bc
	bit  PCF_HITOTHER, [hl]				; Did we reach?
	jp   z, .obj1_chkGuard_doGravity	; If not, skip
	ld   hl, iPlInfo_Flags1Other
	add  hl, bc
	bit  PF1B_INVULN, [hl]				; Is the opponent invulnerable?
	jp   nz, .obj1_chkGuard_doGravity	; If so, skip
	bit  PF1B_HITRECV, [hl]				; Did the opponent get hit?
	jp   z, .obj1_chkGuard_doGravity	; If not, skip	
	
	bit  PF1B_GUARD, [hl]				; Is the opponent blocking?
	jp   nz, .obj1_chkGuard_guard		; If so, jump
ELSE
	; Identical check, but calling the copy in BANK 0 to save space.
	mMvC_ValHit .obj1_chkGuard_doGravity, .obj1_chkGuard_guard
ENDC
	.obj1_chkGuard_noGuard:
		; Otherwise, continue to #2
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI1, PF3_LASTHIT
		mMvC_SetFrame $02*OBJLSTPTR_ENTRYSIZE, $01
		mMvC_SetSpeedH $0000
		; Force player on the ground
		ld   hl, iOBJInfo_Y
		add  hl, de
		ld   [hl], PL_FLOOR_POS
		jp   .ret
.obj1_chkGuard_guard:
	; If the opponent blocked the hit, slow down considerably.
	; This will still moves us back for overlapping with the opponent.
	mMvC_SetSpeedH $0100
.obj1_chkGuard_doGravity:
	jp   .doGravity
; --------------- frames #3,5,7,9... ---------------
; Generic damage - odd frames.
; Alongside .objEven is used to alternate between hit effects constantly.
.objOdd:
	call OBJLstS_ApplyXSpeed
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI1, PF3_LASTHIT
		jp   .chkOtherEscape
; --------------- frame #2 ---------------
; Initial frame before the odd/even switching.
; This sets the initial jump speed and doesn't check for block yet.
.obj2:
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI0, PF3_LASTHIT
		mMvC_SetSpeedH $0080
		jp   .anim
; --------------- frames #4,6,8,A,... ---------------
; Generic damage - even frames.
.objEven:
	call OBJLstS_ApplyXSpeed
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI0, PF3_LASTHIT
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
			; Otherwise, transition to hop
			ld   a, MOVE_SHARED_HOP_B
			call Pl_SetMove_StopSpeed
			jp   .ret
; --------------- frame #10 ---------------
; Transitions to Ryuu Ga at the end of the frame.	
.startRyuuGa:
	mMvC_ValFrameEnd .anim
		mMvIn_ChkLH .startRyuuGaH
	.startRyuuGaL:
		ld   a, MOVE_ROBERT_RYUU_GA_L
		jp   .startRyuuGa_setMove
	.startRyuuGaH:
		ld   a, MOVE_ROBERT_RYUU_GA_H
	.startRyuuGa_setMove:
		call MoveInputS_SetSpecMove_StopSpeed
		mMvC_SetDamageNext $06, HITTYPE_DROP_MAIN, PF3_LASTHIT
		jp   .ret
; --------------- common gravity check ---------------	
.doGravity:
	mMvC_ChkGravityHV $0030, .anim
		mMvC_SetLandFrame $11*OBJLSTPTR_ENTRYSIZE, $07
		jp   .ret
; --------------- frame #11 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jp   .ret
; --------------- common ---------------	
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Robert_RyuKoRanbuD ===============
; Move code for the desperation super version of Robert's Ryu Ko Ranbu. (MOVE_ROBERT_RYU_KO_RANBU_D)
; This is like the normal one, except longer, transitions to the hidden version of Ryuu Ga and dealing
; less damage on that transition (for consistency, since the hidden version deals continuous damage).
MoveC_Robert_RyuKoRanbuD:
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
	jp   z, .objOdd
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $07*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $09*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $0B*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $0D*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $0F*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $11*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $13*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $15*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $17*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $19*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $1B*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $1D*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $1F*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $20*OBJLSTPTR_ENTRYSIZE
	jp   z, .startRyuuGa
	cp   $21*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .objEven
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameStart .obj0_getManCtrl
	; Nothing
.obj0_getManCtrl:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameStart .obj1_chkGuard
		mMvC_PlaySound SCT_MOVEJUMP_A
		; Set different jump speed depending on light / heavy version.
		mMvIn_ChkLH .obj1_setJumpH
	.obj1_setJumpL:
		mMvC_SetSpeedH +$05FF
		mMvC_SetSpeedV -$0200
		jp   .doGravity
	.obj1_setJumpH:
		mMvC_SetSpeedH +$06FF
		mMvC_SetSpeedV -$0280
		jp   .doGravity
.obj1_chkGuard:
IF REV_VER_2 == 0
	;
	; Continue the jump until hitting the opponent.
	;
	ld   hl, iPlInfo_ColiFlags
	add  hl, bc
	bit  PCF_HITOTHER, [hl]				; Did we reach?
	jp   z, .obj1_chkGuard_doGravity	; If not, skip
	ld   hl, iPlInfo_Flags1Other
	add  hl, bc
	bit  PF1B_INVULN, [hl]				; Is the opponent invulnerable?
	jp   nz, .obj1_chkGuard_doGravity	; If so, skip
	bit  PF1B_HITRECV, [hl]				; Did the opponent get hit?
	jp   z, .obj1_chkGuard_doGravity	; If not, skip	
	
	bit  PF1B_GUARD, [hl]				; Is the opponent blocking?
	jp   nz, .obj1_chkGuard_guard		; If so, jump
ELSE
	; Identical check, but calling the copy in BANK 0 to save space.
	mMvC_ValHit .obj1_chkGuard_doGravity, .obj1_chkGuard_guard
ENDC
	.obj1_chkGuard_noGuard:
		; Otherwise, continue to #2
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI1, PF3_LASTHIT
		mMvC_SetFrame $02*OBJLSTPTR_ENTRYSIZE, $01
		mMvC_SetSpeedH $0000
		; Force player on the ground
		ld   hl, iOBJInfo_Y
		add  hl, de
		ld   [hl], PL_FLOOR_POS
		jp   .ret
.obj1_chkGuard_guard:
	; If the opponent blocked the hit, slow down considerably.
	; This will still moves us back for overlapping with the opponent.
	mMvC_SetSpeedH $0100
.obj1_chkGuard_doGravity:
	jp   .doGravity
; --------------- frames #3,5,7,9... ---------------
; Generic damage - odd frames.
; Alongside .objEven is used to alternate between hit effects constantly.
.objOdd:
	call OBJLstS_ApplyXSpeed
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI1, PF3_LASTHIT
		jp   .chkOtherEscape
; --------------- frame #2 ---------------
; Initial frame before the odd/even switching.
; This sets the initial jump speed and doesn't check for block yet.
.obj2:
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI0, PF3_LASTHIT
		mMvC_SetSpeedH $0080
		jp   .anim
; --------------- frames #4,6,8,A,... ---------------
; Generic damage - even frames.
.objEven:
	call OBJLstS_ApplyXSpeed
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI0, PF3_LASTHIT
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
			; Otherwise, transition to hop
			ld   a, MOVE_SHARED_HOP_B
			call Pl_SetMove_StopSpeed
			jp   .ret
; --------------- frame #10 ---------------
; Transitions to Ryuu Ga at the end of the frame.	
.startRyuuGa:
	mMvC_ValFrameEnd .anim
		mMvIn_ChkLH .startRyuuGaH
	.startRyuuGaL:
		ld   a, MOVE_ROBERT_RYUU_GA_HIDDEN_L
		jp   .startRyuuGa_setMove
	.startRyuuGaH:
		ld   a, MOVE_ROBERT_RYUU_GA_HIDDEN_H
	.startRyuuGa_setMove:
		call MoveInputS_SetSpecMove_StopSpeed
		; ##
		mMvC_SetDamageNext $02, HITTYPE_DROP_MAIN, PF3_LASTHIT
		; ##
		jp   .ret
; --------------- common gravity check ---------------	
.doGravity:
	mMvC_ChkGravityHV $0030, .anim
		mMvC_SetLandFrame $21*OBJLSTPTR_ENTRYSIZE, $07
		jp   .ret
; --------------- frame #21 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jp   .ret
; --------------- common ---------------	
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Robert_HaohShokohKen ===============
; Move code for Haoh Shokoh Ken for these characters:
; - Robert (MOVE_ROBERT_HAOH_SHOKOH_KEN_S, MOVE_ROBERT_HAOH_SHOKOH_KEN_D)
; - Ryo (MOVE_RYO_HAOH_SHOKOH_KEN_S, MOVE_RYO_HAOH_SHOKOH_KEN_D)
; - Mr.Karate (MOVE_MRKARATE_HAOH_SHOKOH_KEN_S, MOVE_MRKARATE_HAOH_SHOKOH_KEN_D)
;
; These must have the same IDs across chars, since there's a super desperation check by move ID. 
MoveC_Robert_HaohShokohKen:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj2
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj3
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim
; --------------- frame #2 ---------------	
.obj2:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $1E
		jp   .anim
; --------------- frame #3 ---------------	
.obj3:
	mMvC_ValFrameStart .obj3_cont
		; Spawn a large projectile
		ld   hl, iPlInfo_MoveId
		add  hl, bc
		ld   a, [hl]
		cp   MOVE_ROBERT_HAOH_SHOKOH_KEN_D	; Using the desperation version?
		jp   z, .obj3_spawnProjD			; If so, jump
	.obj3_spawnProjS:
		call ProjInit_HaohShokohKenS
		jp   .obj3_cont
	.obj3_spawnProjD:
		call ProjInit_HaohShokohKenD
.obj3_cont:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $04
		jp   .anim
; --------------- frame #4 ---------------	
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jp   .ret
; --------------- common ---------------	
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
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
	mMvIn_ValSuper .chkAirPunchNoSuper
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
	mMvIn_ValSuper .chkPunchNoSuper
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
	mMvIn_ValStartCmdThrow_StdColi Leona
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
	
; =============== MoveC_Leona_BalticLauncherL ===============
; Move code for the light version of Leona's Baltic Launcher (MOVE_LEONA_BALTIC_LAUNCHER_L).	
MoveC_Leona_BalticLauncherL:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj0
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim
; --------------- frame #0 ---------------	
.obj0:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_INSTANT
		jp   .anim
; --------------- frame #2 ---------------	
.obj1:
	mMvC_ValFrameStart .obj1_cont
		call ProjInit_Leona_BalticLauncher
		; [BUG] With ANIMSPEED_INSTANT, mMvC_ValFrameEnd should be also run the same frame.
		;       It doesn't make any difference here though, since we'd be setting the same speed.
		IF FIX_BUGS == 0
			jp   .anim
		ENDC
.obj1_cont:
	mMvC_ValFrameEnd .anim
		;--
		; [TCRF] Unreachable code.
		mMvC_SetAnimSpeed ANIMSPEED_INSTANT
		jp   .anim
		;--
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
	
; =============== MoveC_Leona_BalticLauncherH ===============
; Move code for the hard version of Leona's Baltic Launcher (MOVE_LEONA_BALTIC_LAUNCHER_H).	
MoveC_Leona_BalticLauncherH:
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
	jp   z, .doGravity
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim ; We never get here
; --------------- frame #0 ---------------	
.obj0:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		jp   .anim
; --------------- frame #1 ---------------	
.obj1:
	mMvC_ValFrameStart .obj1_cont
		; Spawn projectile
		call ProjInit_Leona_BalticLauncher
		; Set different movement speed at max power
		mMvC_ChkMaxPow .obj1_setJumpMax
	.obj1_setJump:
		mMvC_SetSpeedH +$0100
		mMvC_SetSpeedV -$0400
		jp   .doGravity
	.obj1_setJumpMax:
		mMvC_SetSpeedH +$0200
		mMvC_SetSpeedV -$0400
		jp   .doGravity
.obj1_cont:
	mMvC_NextFrameOnGtYSpeed -$02, ANIMSPEED_NONE
	jp   nc, .doGravity
	jp   .doGravity
; --------------- frame #1-2 / common gravity check ---------------	
.doGravity:
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $03*OBJLSTPTR_ENTRYSIZE, $08
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
	
; =============== MoveC_Leona_GrandSabre ===============
; Move code for Leona's Grand Sabre (MOVE_LEONA_GRAND_SABRE_L, MOVE_LEONA_GRAND_SABRE_H).
; Contains this submove:
; - Gliding Buster	
MoveC_Leona_GrandSabre:
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
	jp   z, .obj2
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj5
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj6
	cp   $07*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj6
	cp   $08*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj6
	cp   $09*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj9
	cp   $0A*OBJLSTPTR_ENTRYSIZE
	jp   z, .objA
	cp   $0B*OBJLSTPTR_ENTRYSIZE
	jp   z, .objB
	cp   $0C*OBJLSTPTR_ENTRYSIZE
	jp   z, .objC
	cp   $0D*OBJLSTPTR_ENTRYSIZE
	jp   z, .objD
	cp   $0E*OBJLSTPTR_ENTRYSIZE
	jp   z, .doGravity
	cp   $0F*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim ; We never get here
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameEnd .chkDistance
		mMvC_SetAnimSpeed $01
		jp   .chkDistance
; --------------- frame #1 ---------------
; Starts the forwards run (until we get close to the opponent)
.obj1:
	mMvC_ValFrameStart .obj1_cont
		mMvC_PlaySound SFX_STEP
		; Set different run speed depending on move strength
		mMvIn_ChkLHE .setRunH, .setRunE
	.setRunL: ; Light
		mMvC_SetSpeedH +$0400
		jp   .chkDistance_far
	.setRunH: ; Heavy
		mMvC_SetSpeedH +$0500
		jp   .chkDistance_far
	.setRunE: ; [POI] Hidden Heavy
		mMvC_SetSpeedH +$0600
		jp   .chkDistance_far
.obj1_cont:
	jp   .chkDistance
; --------------- frame #2-4 ---------------
; Play step SFX when done.
.obj2:
	mMvC_ValFrameStart .chkDistance
		mMvC_PlaySound SFX_STEP
		jp   .chkDistance
; --------------- [TCRF] Unreferenced frame ---------------	
; Going by this being placed between #4 and #5, it likely was intended to
; get manual control to avoid #5 automatically switching to #6 if we didn't slow down in time.
; It wasn't needed because #5 doesn't animate the player (anymore).
.obj_unused:
	mMvC_ValFrameStart .obj_unused_cont
		mMvC_PlaySound SFX_STEP
.obj_unused_cont:
	mMvC_ValFrameEnd .chkDistance
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		jp   .chkDistance_far
; --------------- frame #5 ---------------
.obj5:
	; Progressively slow down at 1px/frame. When we stop moving, end the move.
	mMvC_DoFrictionH $0100
	jp   nc, .ret
	jp   .end
; --------------- frames #0-5 / common distance check ---------------
.chkDistance:
	; Getting close to the opponent switches to #6.
	; If we don't, #5 makes sure to end the move before it automatically switches to #6.
	mMvIn_ValClose .chkDistance_far, $20
		mMvC_SetFrame $06*OBJLSTPTR_ENTRYSIZE, $01
		call OBJLstS_ApplyXSpeed
		jp   .ret
.chkDistance_far:
	call OBJLstS_ApplyXSpeed
	jp   .anim
; --------------- frame #6-8 ---------------
; Slow down.
.obj6:
	mMvC_DoFrictionH $0080
	jp   .chkGlidingBuster
; --------------- frame #9 ---------------
; Didn't hti the opponent in time.
; End the move when the frame ends.
.obj9:
	mMvC_DoFrictionH $0080
	mMvC_ValFrameEnd .anim
		jp   .end
; --------------- frames #6-9 / common submove check ---------------
; Attempts to start Gliding Buster.
.chkGlidingBuster:

	; If we didn't hit the opponent, continue animating.
	; If this is allowed to animate, we'll eventually get into #9, which ends the move early.
	ld   hl, iPlInfo_ColiFlags
	add  hl, bc
	bit  PCF_HITOTHER, [hl]	; Did the opponent get hit?
	jp   z, .anim			; If not, jump
	ld   hl, iPlInfo_Flags1Other
	add  hl, bc
	bit  PF1B_INVULN, [hl]	; Is the opponent invulnerable?
	jp   nz, .anim			; If so, jump
	
	; Input required:
	; K
	call MoveInputS_CheckGAType
	jp   nc, .anim	; Was an attack button pressed? If not, jump
	jp   z, .anim	; Was the punch button pressed? If so, jump
	mMvC_SetDamageNext $08, HITTYPE_DROP_MAIN, PF3_HEAVYHIT
	mMvC_SetFrame $0A*OBJLSTPTR_ENTRYSIZE, ANIMSPEED_NONE
	jp   .ret
; --------------- Gliding Buster - frame #A ---------------
; Initialize jump settings.
.objA:
	mMvC_ValFrameStart .objA_cont
		mMvC_ChkMaxPow .objA_setJumpMax
	.objA_setJump:
		mMvC_SetSpeedH +$0100
		mMvC_SetSpeedV -$0500
		jp   .doGravity
	.objA_setJumpMax:
		mMvC_SetSpeedH +$0200
		mMvC_SetSpeedV -$0580
		jp   .doGravity
.objA_cont:
	mMvC_NextFrameOnGtYSpeed -$04, ANIMSPEED_NONE
	jp   .doGravity
; --------------- Gliding Buster - frame #B ---------------
.objB:
	mMvC_NextFrameOnGtYSpeed -$02, ANIMSPEED_NONE
	jp   .doGravity
; --------------- Gliding Buster - frame #C ---------------
.objC:
	mMvC_NextFrameOnGtYSpeed -$01, ANIMSPEED_NONE
	jp   .doGravity
; --------------- Gliding Buster - frame #D ---------------
.objD:
	mMvC_NextFrameOnGtYSpeed +$00, ANIMSPEED_NONE
	jp   .doGravity
; --------------- Gliding Buster - frames #A-E / common gravity check ---------------
; Switch to #F when we land on the ground.
.doGravity:
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $0F*OBJLSTPTR_ENTRYSIZE, $08
		jp   .ret
; --------------- Gliding Buster - frame #F ---------------
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
	
; =============== MoveC_Leona_XCalibur ===============
; Move code for Leona's X Calibur (MOVE_LEONA_X_CALIBUR_L, MOVE_LEONA_X_CALIBUR_H).
MoveC_Leona_XCalibur:
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
; --------------- frame #0 ---------------	
.obj0:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		
		; [POI] Hidden heavy version hits again
		call MoveInputS_CheckMoveLHVer
		jp   c, .obj0_doDamageE	; Hidden heavy triggered? If so, jump
		jp   .obj0_anim			; Otherwise, skip it
	.obj0_doDamageE:
		mMvC_SetDamageNext $02, HITTYPE_DROP_MAIN, PF3_FIRE|PF3_LASTHIT|PF3_LIGHTHIT
	.obj0_anim:
		jp   .anim
; --------------- frame #1 ---------------	
.obj1:
	mMvC_ValFrameStart .obj1_cont
		mMvC_SetSpeedV -$0700
		
		; Calculate horizontal speed.
		; The closer we are to the opponent, the slower the movement is.
		ld   hl, iPlInfo_PlDistance
		add  hl, bc
		ld   a, [hl]			; A = Distance with opponent
		ld   h, $26		
		cp   a, h				; Distance >= $26?
		jp   nc, .obj1_farSpeed	; If so, jump
	.obj1_nearSpeed:
		; Near opponent.
		; SpeedH = (Distance * 4) / $100
		sla  a		; A = Distance * 4
		sla  a
		ld   l, a	; Set that as subpixel (/ $100)
		ld   h, $00	; $00 pixels
		jp   .obj1_setSpeed
	.obj1_farSpeed:
		; Far from the opponent.
		; SpeedH = (Distance / $20) + (Distance / $20 / $100)
		srl  a		; A = Distance / $20
		srl  a
		srl  a
		srl  a
		srl  a
		ld   h, a	; Set that as pixels
		ld   l, a	; and subpixels too (/ $100)
	.obj1_setSpeed:
		call Play_OBJLstS_SetSpeedH_ByXFlipR
		jp   .doGravity
.obj1_cont:
	mMvC_NextFrameOnGtYSpeed -$0A, ANIMSPEED_NONE
	jp   .doGravity
; --------------- frame #2 ---------------	
.obj2:
	mMvC_NextFrameOnGtYSpeed -$06, ANIMSPEED_NONE
	jp   .doGravity
; --------------- frame #3 ---------------	
.obj3:
	mMvC_NextFrameOnGtYSpeed -$03, ANIMSPEED_INSTANT
	jp   .doGravity
; --------------- frame #4 ---------------	
.obj4:
	; [POI] Hidden heavy version hits again
	call MoveInputS_CheckMoveLHVer
	jp   c, .obj4_doDamageE	; Hidden heavy triggered? If so, jump
	jp   .doGravity			; Otherwise, skip it
.obj4_doDamageE:
	mMvC_SetDamage $02, HITTYPE_DROP_MAIN, PF3_FIRE|PF3_LASTHIT|PF3_LIGHTHIT
	jp   .doGravity
; --------------- frame #5 ---------------	
.obj5:
	; [POI] Hidden heavy version hits again
	call MoveInputS_CheckMoveLHVer
	jp   c, .obj5_doDamageE	; Hidden heavy triggered? If so, jump
	jp   .obj5_cont			; Otherwise, skip it
.obj5_doDamageE:
	mMvC_SetDamage $02, HITTYPE_DROP_MAIN, PF3_FIRE|PF3_LASTHIT|PF3_LIGHTHIT
.obj5_cont:
	mMvC_ValFrameEnd .doGravity
		; Loop back to #4 if we didn't touch the ground yet
		ld   hl, iOBJInfo_OBJLstPtrTblOffset
		add  hl, de
		ld   [hl], $03*OBJLSTPTR_ENTRYSIZE ; offset by -1
		jp   .doGravity
		
; --------------- frames #1-5 / common gravity check ---------------	
.doGravity:
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $06*OBJLSTPTR_ENTRYSIZE, $02
		jp   .ret
; --------------- frame #6 ---------------	
.obj6:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $0A
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
	
; =============== MoveC_Leona_MoonSlasher ===============
; Move code for Leona's Moon Slasher (MOVE_LEONA_MOON_SLASHER_L, MOVE_LEONA_MOON_SLASHER_H).
MoveC_Leona_MoonSlasher:
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
	mMvC_ValFrameEnd .anim
		; If we're at max power, deal extra damage
		mMvC_SetAnimSpeed ANIMSPEED_INSTANT
		mMvC_PlaySound SFX_FIREHIT_A
		mMvC_ChkNotMaxPow .anim ; Jump to .anim if not at max power
			mMvC_SetDamageNext $08, HITTYPE_DROP_MAIN, PF3_LASTHIT
			jp   .anim
; --------------- frame #1 ---------------	
.obj1:
	mMvC_ValFrameStart .obj1_cont
		mMvC_SetMoveH +$0400
.obj1_cont:
	jp   .damageNotMaxPow
; --------------- frame #2 ---------------	
.obj2:
	mMvC_ValFrameStart .damageNotMaxPow
		mMvC_SetMoveH +$0400
; --------------- frmes #1-2 / extra damage check ---------------	
.damageNotMaxPow:
	; If we're at max power, deal extra damage
	mMvC_ValFrameEnd .anim
		mMvC_ChkNotMaxPow .anim ; Jump to .anim if not at max power
			mMvC_SetDamageNext $08, HITTYPE_DROP_MAIN, PF3_LASTHIT
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
	
; =============== MoveC_OLeona_StormBringer ===============
; Move code for Orochi Leona's Storm Bringer (MOVE_OLEONA_STORM_BRINGER_L, MOVE_OLEONA_STORM_BRINGER_H).
; This can't be used with normal Leona since she doesn't have an animation assigned for this, and the
; input is ignored anyway.
MoveC_OLeona_StormBringer:
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
	jp   z, .obj3
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim ; We never get here
; --------------- frame #0 ---------------
; Init.
.obj0:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $01
		; Restore $08 lines of health over timer.
		; During the looping part, the health restored is half of the damage dealt.
		ld   hl, iPlInfo_OLeona_StormBringer_LoopTimer
		add  hl, bc
		ld   [hl], $08
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI0, PF3_SUPERALT|PF3_LIGHTHIT
		jp   .anim
; --------------- frame #1 ---------------
; Health restore loop.
.obj1:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI1, PF3_SUPERALT|PF3_LIGHTHIT
		jp   .restoreHealth
; --------------- frame #2 ---------------
; Health restore loop.
.obj2:
	mMvC_ValFrameEnd .anim
	; As long as the loop timer doesn't get to 0, gain health
	ld   hl, iPlInfo_OLeona_StormBringer_LoopTimer
	add  hl, bc
	dec  [hl]					; LoopTimer--
	jp   z, .obj2_setAnimSpeed	; Did it reach $00? If so, jump
	
	; If we get here, we can loop back to #1
	ld   hl, iOBJInfo_OBJLstPtrTblOffset
	add  hl, de
	ld   [hl], $00*OBJLSTPTR_ENTRYSIZE
	mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI0, PF3_SUPERALT|PF3_LIGHTHIT
	jp   .restoreHealth
.obj2_setAnimSpeed:
	; Set animation speed to $0A before switching to #3
	ld   hl, iOBJInfo_FrameTotal
	add  hl, de
	ld   [hl], $0A	
	jp   .anim
; --------------- frames #1-2 / common health restore ---------------
.restoreHealth:
	; Restores health line by line until we reach the cap
	ld   hl, iPlInfo_Health
	add  hl, bc
	ld   a, [hl]				; A = Health
	cp   PLAY_HEALTH_MAX		; Health == $48?
	jp   z, .restoreHealth_anim	; If so, don't increment it anymore
	inc  [hl]					; Otherwise, Health++
.restoreHealth_anim:
	jp   .anim
; --------------- frames #3-4 ---------------
.obj3:
	mMvC_ValFrameEnd .anim
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
	
; =============== MoveC_Leona_VSlasher ===============
; Move code for Leona's V Slasher (MOVE_LEONA_V_SLASHER_S, MOVE_LEONA_V_SLASHER_D).
MoveC_Leona_VSlasher:
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
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		jp   .anim
; --------------- frame #1 ---------------
.obj1:
	; Dive diagonally down forward.
	mMvC_ValFrameStart .obj1_cont
		mMvIn_ChkLH .obj1_setDiveH
	.obj1_setDiveL: ; Light
		mMvC_SetSpeedH +$0400
		mMvC_SetSpeedV +$0400
		jp   .obj1_doGravity
	.obj1_setDiveH: ; Heavy
		mMvC_SetSpeedH +$0600
		mMvC_SetSpeedV +$0400
		jp   .obj1_doGravity
.obj1_cont:
	; If we successfully hit the opponent through a combo hit, directly switch to #2.
	mMvC_ValHit .obj1_doGravity, .obj1_doGravity
		mMvC_SetFrame $02*OBJLSTPTR_ENTRYSIZE, ANIMSPEED_NONE
		call Play_Pl_TempPauseOtherAnim
		jp   .ret
; --------------- frame #2 ---------------
; Projectile confirmed, waiting to get below/same Y pos as the opponent.
.obj2:
	jp   .obj2_chkOtherU
; --------------- frame #3 ---------------
; Pre-projectile spawn, damage setup.
.obj3:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE	
		
		; Damage is handled differently between Leona and O.Leona.
		ld   hl, iPlInfo_CharId
		add  hl, bc
		ld   a, [hl]
		cp   CHAR_ID_LEONA			; Playing as normal Leona?
		jp   nz, .obj3_setDamageO	; If not, jump
	.obj3_setDamageNorm:
		; As normal Leona, deliver hit dealing $14 lines of damage the next frame.
		; The "V" projectile deals no damage and is a purely visual effect here.
		mMvC_SetDamageNext $14, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE
		jp   .anim
	.obj3_setDamageO:
		; As O.Leona, the projectile spawns a skull wall that actually deals continuous damage.
		
		; Prepare flags to copy
		mMvC_SetDamageNext $02, HITTYPE_DROP_SWOOPUP, PF3_HEAVYHIT|PF3_FIRE
		; Copy them over to the projectile
		call Play_Proj_CopyMoveDamageFromPl
		jp   .anim
; --------------- frame #4 ---------------
; Jump in air dealing damage, projectile spawn.
.obj4:
	mMvC_ValFrameStart .obj4_cont
		; Initialize the special effect
		call ProjInit_Leona_VSlasher
		
		; Set jump
		mMvIn_ChkLH .obj4_setJumpH
	.obj4_setJumpL:
		mMvC_SetSpeedH +$0300
		mMvC_SetSpeedV -$0500
		jp   .obj5
	.obj4_setJumpH:
		mMvC_SetSpeedH +$0400
		mMvC_SetSpeedV -$0500
		jp   .obj5
.obj4_cont:
	mMvC_NextFrameOnGtYSpeed -$02, ANIMSPEED_NONE
	jp   .obj5
; --------------- frame #1 - gravity check ---------------
.obj1_doGravity:
	; If we touched the ground in #1, perform the same check as .obj1_cont, except:
	; - If it passes, we switch to #3
	; - If it fails, the move ends by switching to #6
	mMvC_ChkGravityHV $0000, .anim
		mMvC_ValHit .obj1_endMove, .obj1_endMove
	.obj1_startOk:
		mMvC_SetLandFrame $03*OBJLSTPTR_ENTRYSIZE, $02
		call Play_Pl_TempPauseOtherAnim
		jp   .ret
		;--
	.obj1_endMove:
		mMvC_SetLandFrame $06*OBJLSTPTR_ENTRYSIZE, $02
		jp   .ret
; --------------- frame #2 - positon check ---------------
; Because of how the projectile spawns, wait until we have the same Y position or are
; below the opponent before continuing to #3.
; Do the same when touching the ground, though it isn't necessary since it's not like 
; the other player can get below that.
.obj2_chkOtherU:
	ld   hl, iOBJInfo_Y
	add  hl, de
	ld   a, [hl]			; A = Pl. Y Pos
	ld   hl, iPlInfo_OBJInfoYOther
	add  hl, bc				; HL = Ptr to opponent Y Pos
	cp   a, [hl]			; PlY > OtherY? (are we below the opponent?)	
	jp   nc, .obj2_setNext	; If so, jump
	mMvC_ChkGravityHV $0000, .anim
	.obj2_setNext:
		mMvC_SetLandFrame $03*OBJLSTPTR_ENTRYSIZE, $02
		jp   .ret
; --------------- frame #5 ---------------
.obj5:
	mMvC_DoFrictionH $0040
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $06*OBJLSTPTR_ENTRYSIZE, $02
		jp   .ret
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
	
; =============== MoveC_OLeona_SuperMoonSlasher ===============
; Move code for Orochi Leona's Super Moon Slasher (MOVE_OLEONA_SUPER_MOON_SLASHER_S, MOVE_OLEONA_SUPER_MOON_SLASHER_D).
MoveC_OLeona_SuperMoonSlasher:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
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
	jp   z, .obj9
	cp   $0A*OBJLSTPTR_ENTRYSIZE
	jp   z, .objA
	cp   $0B*OBJLSTPTR_ENTRYSIZE
	jp   z, .doGravity
	cp   $0C*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim
; --------------- frame #2 ---------------
.obj2:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $10
		; Do the initial damage loop 8 times
		ld   hl, iPlInfo_OLeona_SuperMoonSlasher_LoopTimer
		add  hl, bc
		ld   [hl], $08
		jp   .anim
; --------------- frame #3 ---------------
.obj3:
	mMvC_ValFrameStart .obj3_cont
		ld   hl, iPlInfo_Flags1
		add  hl, bc
		res  PF1B_INVULN, [hl]
		mMvC_SetSpeedH $0700
.obj3_cont:
	; If the move didn't hit successfully by the end of #3, end it
	mMvC_ValHit .obj3_whiff, .obj3_blocked
	.obj3_hit:
		; Otherwise, continue to #4
		mMvC_SetFrame $04*OBJLSTPTR_ENTRYSIZE, $00
		mMvC_SetSpeedH $0080
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI0, PF3_SUPERALT|PF3_LIGHTHIT
		jp   .ret
.obj3_blocked:
	mMvC_SetSpeedH $0000
.obj3_whiff:
	mMvC_ValFrameEnd .moveH
		jp   .end
; --------------- frame #4 ---------------
.obj4:
	call OBJLstS_ApplyXSpeed
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI1, PF3_SUPERALT|PF3_LIGHTHIT
		jp   .chkOtherEscape
; --------------- frame #5 ---------------
.obj5:
	call OBJLstS_ApplyXSpeed
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI0, PF3_SUPERALT|PF3_LIGHTHIT
		jp   .chkOtherEscape
; --------------- frame #6 ---------------
.obj6:
	call OBJLstS_ApplyXSpeed
	mMvC_ValFrameEnd .anim
		; Until the loop timer elapses, loop to #4 and deal one line of damage
		ld   hl, iPlInfo_OLeona_SuperMoonSlasher_LoopTimer
		add  hl, bc
		dec  [hl]				; LoopTimer--
		jp   z, .obj6_noLoop	; Did it reach 0? If so, jump
	.obj6_loop:
		; Loop to #4
		ld   hl, iOBJInfo_OBJLstPtrTblOffset
		add  hl, de
		ld   [hl], $03*OBJLSTPTR_ENTRYSIZE ; offset by -1
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI0, PF3_SUPERALT|PF3_LIGHTHIT
		jp   .chkOtherEscape
	.obj6_noLoop:
		; Deal more damage for #7
		mMvC_SetDamageNext $0C, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_SUPERALT
		; And enable manual control
		ld   hl, iOBJInfo_FrameTotal
		add  hl, de
		ld   [hl], ANIMSPEED_NONE
		jp   .anim
; --------------- frames #4-6 / common escape check ---------------
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
			; Otherwise, transition to hop
			ld   a, MOVE_SHARED_HOP_B
			call Pl_SetMove_StopSpeed
			jp   .ret
; --------------- frame #7 ---------------
.obj7:
	mMvC_ValFrameStart .obj7_cont
		mMvC_SetSpeedH -$0300
		mMvC_SetSpeedV -$0580
		jp   .doGravity
.obj7_cont:
	mMvC_NextFrameOnGtYSpeed -$04, ANIMSPEED_NONE
	jp   .doGravity
; --------------- frame #8 ---------------
.obj8:
	mMvC_NextFrameOnGtYSpeed -$02, ANIMSPEED_NONE
	jp   .doGravity
; --------------- frame #9 ---------------
.obj9:
	mMvC_NextFrameOnGtYSpeed -$01, ANIMSPEED_NONE
	jp   .doGravity
; --------------- frame #A ---------------
.objA:
	mMvC_NextFrameOnGtYSpeed +$00, ANIMSPEED_NONE
	jp   .doGravity
; --------------- frame #7-B / common gravity check ---------------
.doGravity:
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $0C*OBJLSTPTR_ENTRYSIZE, $08
		jp   .ret
; --------------- frame #C ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		jp   .end
; --------------- common ---------------
.moveH:
	call OBJLstS_ApplyXSpeed
	jp   .anim
; --------------- [TCRF] Unreferenced frame ---------------
.unused_moveHAndChkEnd:
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
	
; =============== ProjC_Leona_BalticLauncher ===============
; Projectile code for Leona's Baltic Launcher.
ProjC_Leona_BalticLauncher:

	; Handle the despawn timer
	ld   hl, iOBJInfo_Play_EnaTimer
	add  hl, de
	dec  [hl]			; DespawnTimer--
	jp   z, .despawn	; Did it reach 0? If so, jump
	
	; This disappears early if we get hit
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	bit  PF1B_HITRECV, [hl]
	jp   nz, .despawn
	
	call ExOBJS_Play_ChkHitModeAndMoveH
	call OBJLstS_DoAnimTiming_Loop_by_DE
	ret
.despawn:
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
	mMvIn_ValSuper .chkPunchNoSuper
	; DFDB+P -> Ryuko Ranbu
	mMvIn_ChkDir MoveInput_DFDB, MoveInit_MrKarate_RyukoRanbu
	; FBDF+P -> Haoh Sho Koh Ken
	mMvIn_ChkDir MoveInput_FBDF, MoveInit_MrKarate_HaohShoKohKen
.chkPunchNoSuper:
	; FDB+P -> Zenretsuken
	mMvIn_ChkDir MoveInput_FDB, MoveInit_MrKarate_Zenretsuken
	; BDF+P (close) -> Kyokuken Ryu Renbu Ken
	mMvIn_ChkDir MoveInput_BDF, MoveInit_MrKarate_KyokukenRyuRenbuKen
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
	; [BUG] Not checking if a projectile is already on screen.
	;       Spawning a "second" one will cause the first to be "deleted".
	;       (or rather, it replaces the on-screen projectile)
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_MRKARATE_KO_OU_KEN_L, MOVE_MRKARATE_KO_OU_KEN_H
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
IF REV_VER_2 == 1
	; This can only be enabled by the desperation super
	ld   hl, iPlInfo_MrKarate_RyukoRanbuD
	add  hl, bc
	ld   [hl], $00
ENDC
	jp   MoveInputReader_MrKarate_SetMove
; =============== MoveInit_MrKarate_KyokukenRyuRenbuKen ===============
MoveInit_MrKarate_KyokukenRyuRenbuKen:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_ValClose MoveInputReader_MrKarate_NoMove
	mMvIn_GetLH MOVE_MRKARATE_KYOKUKEN_RYU_RENBU_KEN_L, MOVE_MRKARATE_KYOKUKEN_RYU_RENBU_KEN_H
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_MrKarate_SetMove
; =============== MoveInit_MrKarate_RyukoRanbu ===============
MoveInit_MrKarate_RyukoRanbu:
	call Play_Pl_ClearJoyDirBuffer
IF REV_VER_2 == 0
	; [TCRF] Suspicious use of mMvIn_GetSD.
	;        Very likely that that a reference to MOVE_MRKARATE_RYUKO_RANBU_UNUSED_D got
	;        quickly patched out since it didn't work properly.
	mMvIn_GetSD MOVE_MRKARATE_RYUKO_RANBU_S, MOVE_MRKARATE_RYUKO_RANBU_S
	call MoveInputS_SetSpecMove_StopSpeed
ELSE
	; [POI] Still no MOVE_MRKARATE_RYUKO_RANBU_UNUSED_D, but the desperation version is properly implemented now.
	; The super move itself doesn't use iPlInfo_MrKarate_RyukoRanbuD, but it *is* used by MOVE_MRKARATE_ZENRETSUKEN_*,
	; which the super move does transition to.
	; So, everything guarded by a iPlInfo_MrKarate_RyukoRanbuD check is specific to the desperation super.
	call MoveInputS_CheckSuperDesperation
	jp   nc, .normal		; Was a super desperation *NOT* triggered? If so, jump
	jp   nz, .desperation	; Was the hidden desperation *NOT* triggered? If so, jump
	jp   .hidden			; Otherwise, jump
.normal:
	; Normal super
	ld   hl, iPlInfo_MrKarate_RyukoRanbuD
	add  hl, bc
	ld   [hl], $00
	ld   a, MOVE_MRKARATE_RYUKO_RANBU_S
	jp   .setMove
.desperation:
	; Desperation super
	ld   hl, iPlInfo_MrKarate_RyukoRanbuD
	add  hl, bc
	ld   [hl], $01
	ld   a, MOVE_MRKARATE_RYUKO_RANBU_S
.setMove:
	call MoveInputS_SetSpecMove_StopSpeed
	jp   MoveInputReader_MrKarate_SetMove
.hidden:
	; Hidden desperation super
	ld   hl, iPlInfo_MrKarate_RyukoRanbuD
	add  hl, bc
	ld   [hl], $01
	ld   a, MOVE_MRKARATE_RYUKO_RANBU_S
	call MoveInputS_SetSpecMove_StopSpeed
ENDC
	jp   MoveInputReader_MrKarate_SetMove
; =============== MoveInit_MrKarate_HaohShoKohKen ===============
MoveInit_MrKarate_HaohShoKohKen:
	mMvIn_ValProjActive MrKarate
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
	
; =============== MoveC_MrKarate_KoOuKen ===============
; Move code for Mr.Karate's Ko-Ou Ken (MOVE_MRKARATE_KO_OU_KEN_L, MOVE_MRKARATE_KO_OU_KEN_H).
MoveC_MrKarate_KoOuKen:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj3
	jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_SetDamage $01, HITTYPE_DROP_MAIN, PF3_LASTHIT|PF3_LIGHTHIT
	mMvC_ValFrameEnd .anim
		mMvC_PlaySound SCT_PROJ_LG_B
		jp   .anim
; --------------- [TCRF] unused frame #2 ---------------
; This should have been assigned to #2 to make the recovery frame last more, but it isn't.
; Intentional quick change or bug?
.unused_obj2:
	mMvC_SetDamage $01, HITTYPE_DROP_MAIN, PF3_LASTHIT
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $14
		jp   .anim
; --------------- frame #3 ---------------
.obj3:
	mMvC_ValFrameStart .chkEnd
		call ProjInit_MrKarate_KoOuKen
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jp   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_MrKarate_ShouranKyaku ===============
; Move code for Mr.Karate's Shouran Kyaku (MOVE_MRKARATE_SHOURAN_KYAKU_L, MOVE_MRKARATE_SHOURAN_KYAKU_H).
MoveC_MrKarate_ShouranKyaku:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj0
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj0
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj0
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj3
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj4
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj5
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim ; We never get here
; --------------- frame #0-2 ---------------
; Initial forward run.
.obj0:
	mMvC_ValFrameStart .obj0_cont
		mMvC_PlaySound SFX_STEP
		; Pick a run speed depending on the move strength
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
	; Switch to #3 when hitting the opponent
	mMvC_ValHit .obj0_noHit, .obj0_blocked
		mMvC_SetFrame $03*OBJLSTPTR_ENTRYSIZE, $00
		; Set initial for damage loop
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI0, $00
		
		; Repeat the damage loop 3 times
		ld   hl, iPlInfo_MrKarate_ShouranKyaku_LoopCount
		add  hl, bc
		ld   [hl], $03
		jp   .ret
.obj0_blocked:
	mMvC_SetSpeedH +$0000
.obj0_noHit:
	; Continue moving horizontally
	call OBJLstS_ApplyXSpeed
	; Switch directly to #6 if we didn't hit the opponent by the end of #2
	mMvC_ValFrameEnd .anim
		ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
		add  hl, de
		ld   a, [hl]
		cp   $02*OBJLSTPTR_ENTRYSIZE	; FrameId == #2?
		jp   nz, .anim				; If not, skip
		mMvC_SetFrame $06*OBJLSTPTR_ENTRYSIZE, $0A
		jp   .ret
; --------------- frame #3 ---------------
; Damage loop.
.obj3:
	mMvC_ValFrameEnd .chkEscape
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI1, PF3_LASTHIT
		jp   .chkEscape
; --------------- frame #4 ---------------
; Damage loop.
; Alternates between HITTYPE_HIT_MULTI0 and HITTYPE_HIT_MULTI1 to view different frames.
.obj4:
	mMvC_ValFrameEnd .chkEscape
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI0, PF3_LASTHIT
		jp   .chkEscape
; --------------- frame #5 ---------------
; Damage loop.
.obj5:
	mMvC_ValFrameEnd .chkEscape
	; Loop to #3 if the counter didn't expire yet.
	ld   hl, iPlInfo_MrKarate_ShouranKyaku_LoopCount
	add  hl, bc
	dec  [hl]
	jp   z, .obj5_noLoop
	mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI0, PF3_LASTHIT
	ld   hl, iOBJInfo_OBJLstPtrTblOffset
	add  hl, de
	ld   [hl], $02*OBJLSTPTR_ENTRYSIZE	; offset by -1
	jp   .chkEscape
.obj5_noLoop:
	; If it expired, hyper jump back
	ld   a, MOVE_SHARED_BACKJUMP_REC_A
	call Pl_SetMove_StopSpeed
	mMvC_SetSpeedH -$0300
	mMvC_SetSpeedV -$0500
	jp   .ret
	


IF REV_VER_2 == 1
; --------------- frames #3-#5 / common escape check ---------------
; If the opponent somehow escaped, hop back as usual.
.chkEscape:
	mMvC_ValEscape .anim
		ld   a, MOVE_SHARED_HOP_B
		call Pl_SetMove_StopSpeed
		jp   .ret
ENDC
		
; --------------- frame #6 ---------------
; Recovery, only if the move didn't hit/got blocked.
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
IF REV_VER_2 == 0
.chkEscape: ; dummy
ENDC
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_MrKarate_HienShippuuKyaku ===============
; Move code for Mr.Karate's Hien Shippuu Kyaku (MOVE_MRKARATE_HIEN_SHIPPUU_KYAKU_L, MOVE_MRKARATE_HIEN_SHIPPUU_KYAKU_H).
MoveC_MrKarate_HienShippuuKyaku:
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
	jp   z, .doGravity
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj3
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj4
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .doGravity
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .doGravity ; We never get here
; --------------- frame #0 ---------------	
.obj0:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $03
		jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameStart .obj1_cont
		mMvC_PlaySound SCT_MOVEJUMP_A
		
		; Set forward jump settings
		ld   hl, iPlInfo_MoveId
		add  hl, bc
		ld   a, [hl]
		cp   MOVE_MRKARATE_HIEN_SHIPPUU_KYAKU_H	; Doing the heavy version?
		jp   z, .obj1_setJumpH					; If so, jump
	.obj1_setJumpL: ; Light
		mMvC_SetSpeedH +$0300
		mMvC_SetSpeedV -$0200
		jp   .doGravity
	.obj1_setJumpH:
		; Special settings at max power here
		mMvC_ChkMaxPow .obj1_setJumpMaxPowH
	.obj1_setJumpNormH: ; Heavy
		mMvC_SetSpeedH +$0400
		mMvC_SetSpeedV -$0280
		jp   .doGravity
	.obj1_setJumpMaxPowH: ; Heavy, Max POW
		mMvC_SetSpeedH +$0500
		mMvC_SetSpeedV -$0300
		jp   .doGravity
.obj1_cont:
	mMvC_ValFrameEnd .doGravity
	
		; Set a different move speed between heavy and light.
		; The light version in particular sets ANIMSPEED_NONE.
		; This prevents the light move from using frames #3-4 where extra damage is dealt.
		inc  hl	; Seek to iOBJInfo_FrameTotal
		push hl
			ld   hl, iPlInfo_MoveId
			add  hl, bc
			ld   a, [hl]
			cp   MOVE_MRKARATE_HIEN_SHIPPUU_KYAKU_H	; Using the heavy version?
			jp   z, .obj1_setNextH					; If so, jump
		.obj1_setNextL:
		pop  hl
		ld   [hl], ANIMSPEED_NONE
		jp   .doGravity
		.obj1_setNextH:
		pop  hl
		ld   [hl], ANIMSPEED_INSTANT
		jp   .doGravity
; --------------- frame #3 ---------------
.obj3:
	mMvC_ValFrameEnd .doGravity
		mMvC_SetAnimSpeed ANIMSPEED_INSTANT
		mMvC_SetDamageNext $08, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_LASTHIT
		jp   .doGravity
; --------------- frame #4 ---------------
.obj4:
	mMvC_ValFrameEnd .doGravity
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		mMvC_SetDamageNext $08, HITTYPE_DROP_DB_A, PF3_HEAVYHIT|PF3_LASTHIT
		jp   .doGravity
; --------------- common gravity check ---------------	
.doGravity:
	mMvC_ChkGravityHV $0030, .anim
		mMvC_SetLandFrame $06*OBJLSTPTR_ENTRYSIZE, $01
		jp   .ret
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
	
; =============== MoveC_MrKarate_Zenretsuken ===============
; Move code for Mr.Karate's Zenretsuken (MOVE_MRKARATE_ZENRETSUKEN_L, MOVE_MRKARATE_ZENRETSUKEN_H).
MoveC_MrKarate_Zenretsuken:
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
	cp   $08*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim
; --------------- frame #0 ---------------
.obj0:
	mMvC_SetDamage $01, HITTYPE_HIT_MULTI0, PF3_LASTHIT|PF3_LIGHTHIT
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_INSTANT
		mMvC_PlaySound SFX_FIREHIT_A
		ld   hl, iPlInfo_MrKarate_Zenretsuken_LoopCount
		add  hl, bc
		ld   [hl], $04
		jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_SetDamage $01, HITTYPE_HIT_MULTI1, PF3_LASTHIT|PF3_LIGHTHIT
	jp   .anim
; --------------- frame #2 ---------------
.obj2:
	mMvC_SetDamage $01, HITTYPE_HIT_MULTI0, PF3_LASTHIT|PF3_LIGHTHIT
	mMvC_ValFrameEnd .anim
		mMvC_PlaySound SFX_FIREHIT_A
		
		; Loop to #1 until the timer elapses
		ld   hl, iPlInfo_MrKarate_Zenretsuken_LoopCount
		add  hl, bc
		dec  [hl]
		jp   z, .obj2_noLoop
	.obj2_loop:
		mMvC_SetDamage $01, HITTYPE_HIT_MULTI0, PF3_LASTHIT
		ld   hl, iOBJInfo_OBJLstPtrTblOffset
		add  hl, de
		ld   [hl], $00*OBJLSTPTR_ENTRYSIZE ; offset by -1
		jp   .anim
	.obj2_noLoop:
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI1, PF3_LASTHIT
		jp   .anim
; --------------- frame #3 ---------------
.obj3:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI0, PF3_LASTHIT
		jp   .anim
; --------------- frame #4 ---------------
.obj4:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI1, PF3_LASTHIT
		jp   .anim
; --------------- frame #5 ---------------
.obj5:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $1E
		mMvC_PlaySound SFX_FIREHIT_A
		mMvC_SetDamageNext $01, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_LASTHIT
IF REV_VER_2 == 1
		; [POI] If we got here from the desperation version of Ryuko Ranbu, force the opponent into an infinite dizzy.
		;       This is in preparation of transitioning to MOVE_MRKARATE_RYUKO_RANBU_D3 (see .chkEnd),
		;       to give enough time for Mr.Karate to jump back, then fire a large projectile.
		ld   hl, iPlInfo_MrKarate_RyukoRanbuD
		add  hl, bc
		ld   a, [hl]
		or   a			; Desperation mode?
		jr   z, .anim	; If not, skip
			ld   hl, iOBJInfo_FrameTotal	; Set animation speed to $01
			add  hl, de
			ld   [hl], $01
			; Trigger dizzy
			mMvC_SetDamageNext $01, HITTYPE_DIZZY, PF3_HEAVYHIT|PF3_LASTHIT
ENDC
		jp   .anim
; --------------- frame #6 ---------------
.obj6:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $08
		jp   .anim
; --------------- frame #7 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
IF REV_VER_2 == 1
		; [POI] The desperation super of the move transitions to a hop, then fires the large projectile.
		ld   hl, iPlInfo_MrKarate_RyukoRanbuD
		add  hl, bc
		ld   a, [hl]
		or   a			; Desperation mode?
		jr   z, .end	; If not, skip (always jumps)
			ld   a, MOVE_MRKARATE_RYUKO_RANBU_D3
			call MoveInputS_SetSpecMove_StopSpeed
			; Copy move damage settings to projectile, since MOVE_MRKARATE_RYUKO_RANBU_D3
			; starts MOVE_MRKARATE_HAOH_SHO_KOH_KEN_D, which requires the projectile damage to be init'd.
			call Play_Proj_CopyMoveDamageFromPl
			jr   .ret
	.end:
ENDC
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
IF REV_VER_2 == 1
; =============== MoveC_MrKarate_RyukoRanbuD3 ===============
; Move code for third part of the desperation version of Haoh Sho Koh Ken. (MOVE_MRKARATE_SPEC_5_L, MOVE_MRKARATE_RYUKO_RANBU_D3)
; This triggers a long back hop, long enough to reach the edge of the screen, then transitions to MOVE_MRKARATE_HAOH_SHO_KOH_KEN_D.
; While this happens the other player is forced into a dizzy state.
MoveC_MrKarate_RyukoRanbuD3:
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
	jp   .doGravity
	
; [TCRF] Unreferenced code to enable manual control.
.unused_setManualCtrl:
	ld   hl, iOBJInfo_FrameTotal
	add  hl, de
	ld   [hl], ANIMSPEED_NONE
	jp   .anim
; --------------- frame #0 ---------------
.obj0:
	; Set initial backjump speed
	mMvC_ValFrameStartFast .obj0_cont
		mMvC_SetSpeedH -$0600
		mMvC_SetSpeedV -$0300
		jp   .doGravity
.obj0_cont:
	; Switch to #1 when Y Speed > -$03
	mMvC_NextFrameOnGtYSpeed -$03, ANIMSPEED_NONE
	jp   .doGravity
; --------------- frames #0-1 / common gravity check ---------------
.doGravity:
	; Move down at $00.60px/frame, switching to #2 when touching the ground
	mMvC_ChkGravityHV $0060, .anim
		mMvC_SetLandFrame $02*OBJLSTPTR_ENTRYSIZE, ANIMSPEED_INSTANT
		jp   .ret
; --------------- frame #2 ---------------
.chkEnd:
	; Switch to the fourth part of the move when the frame ends.
	; This move will spawn a large projectile, hitting the opponent out of the endless dizzy state.
	mMvC_ValFrameEnd .anim
		ld   a, MOVE_MRKARATE_HAOH_SHO_KOH_KEN_D
		call MoveInputS_SetSpecMove_StopSpeed
		jr   .ret
; --------------- common ---------------
.anim:
	call OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
ENDC
	
; =============== MoveC_MrKarate_RyukoRanbuS ===============
; Move code for Mr.Karate's Ryuko Ranbu (MOVE_MRKARATE_RYUKO_RANBU_S).
; Almost identical to MoveC_Kyo_RyuKoRanbuS.
MoveC_MrKarate_RyukoRanbuS:
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
	jp   z, .objOdd
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $07*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $09*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $0B*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $0D*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $0F*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $11*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $13*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $14*OBJLSTPTR_ENTRYSIZE
	jp   z, .startZenretsuken
	cp   $16*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .objEven
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameStart .obj0_getManCtrl
	; Nothing
.obj0_getManCtrl:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameStart .obj1_chkGuard
		mMvC_PlaySound SCT_MOVEJUMP_A
		; Set different jump speed depending on light / heavy version.
		mMvIn_ChkLH .obj1_setJumpH
	.obj1_setJumpL:
		mMvC_SetSpeedH +$05FF
		mMvC_SetSpeedV -$0200
		jp   .doGravity
	.obj1_setJumpH:
		mMvC_SetSpeedH +$06FF
		mMvC_SetSpeedV -$0280
		jp   .doGravity
.obj1_chkGuard:
IF REV_VER_2 == 0
	;
	; Continue the jump until hitting the opponent.
	;
	ld   hl, iPlInfo_ColiFlags
	add  hl, bc
	bit  PCF_HITOTHER, [hl]				; Did we reach?
	jp   z, .obj1_chkGuard_doGravity	; If not, skip
	ld   hl, iPlInfo_Flags1Other
	add  hl, bc
	bit  PF1B_INVULN, [hl]				; Is the opponent invulnerable?
	jp   nz, .obj1_chkGuard_doGravity	; If so, skip
	bit  PF1B_HITRECV, [hl]				; Did the opponent get hit?
	jp   z, .obj1_chkGuard_doGravity	; If not, skip	
	
	bit  PF1B_GUARD, [hl]				; Is the opponent blocking?
	jp   nz, .obj1_chkGuard_guard		; If so, jump
ELSE
	; Identical check, but calling the copy in BANK 0 to save space.
	mMvC_ValHit .obj1_chkGuard_doGravity, .obj1_chkGuard_guard
ENDC
	.obj1_chkGuard_noGuard:
		; Otherwise, continue to #2
IF REV_VER_2 == 0
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI1, PF3_LASTHIT
ELSE
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI1, PF3_LASTHIT|PF3_LIGHTHIT
ENDC
		mMvC_SetFrame $02*OBJLSTPTR_ENTRYSIZE, $01
		mMvC_SetSpeedH $0000
		; Force player on the ground
		ld   hl, iOBJInfo_Y
		add  hl, de
		ld   [hl], PL_FLOOR_POS
		jp   .ret
.obj1_chkGuard_guard:
	; If the opponent blocked the hit, slow down considerably.
	; This will still moves us back for overlapping with the opponent.
	mMvC_SetSpeedH $0100
.obj1_chkGuard_doGravity:
	jp   .doGravity
; --------------- frames #3,5,7,9... ---------------
; Generic damage - odd frames.
; Alongside .objEven is used to alternate between hit effects constantly.
.objOdd:
	call OBJLstS_ApplyXSpeed
	mMvC_ValFrameStart .anim
IF REV_VER_2 == 0
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI1, PF3_LASTHIT
ELSE
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI1, PF3_LASTHIT|PF3_LIGHTHIT
ENDC
		jp   .chkOtherEscape
; --------------- frame #2 ---------------
; Initial frame before the odd/even switching.
; This sets the initial jump speed and doesn't check for block yet.
.obj2:
	mMvC_ValFrameStart .anim
IF REV_VER_2 == 0
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI0, PF3_LASTHIT
ELSE
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI0, PF3_LASTHIT|PF3_LIGHTHIT
ENDC
		mMvC_SetSpeedH $0080
		jp   .anim
; --------------- frames #4,6,8,A,... ---------------
; Generic damage - even frames.
.objEven:
	call OBJLstS_ApplyXSpeed
	mMvC_ValFrameStart .anim
IF REV_VER_2 == 0
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI0, PF3_LASTHIT
ELSE
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI0, PF3_LASTHIT|PF3_LIGHTHIT
ENDC
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
			; Otherwise, transition to hop
			ld   a, MOVE_SHARED_HOP_B
			call Pl_SetMove_StopSpeed
			jp   .ret
; --------------- frame #14 ---------------
; Transitions to Zenretsuken at the end of the frame.	
.startZenretsuken:
	mMvC_ValFrameEnd .anim
		mMvIn_ChkLH .startZenretsukenH
	.startZenretsukenL:
		ld   a, MOVE_MRKARATE_ZENRETSUKEN_L
		jp   .startZenretsuken_setMove
	.startZenretsukenH:
		ld   a, MOVE_MRKARATE_ZENRETSUKEN_H
	.startZenretsuken_setMove:
		call MoveInputS_SetSpecMove_StopSpeed
IF REV_VER_2 == 0
		mMvC_SetDamageNext $06, HITTYPE_DROP_MAIN, PF3_LASTHIT
ELSE
		mMvC_SetDamageNext $01, HITTYPE_DROP_MAIN, PF3_LASTHIT|PF3_LIGHTHIT
ENDC
		jp   .ret
; --------------- common gravity check ---------------	
.doGravity:
	mMvC_ChkGravityHV $0030, .anim
		jp   .end
		; [TCRF] Unreferenced leftover from MoveC_Kyo_RyuKoRanbuS, except modified to point
		;        to the proper last frame for this move.
		mMvC_SetLandFrame $16*OBJLSTPTR_ENTRYSIZE, $07
		jp   .ret
; --------------- frame #15 ---------------
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
	
IF REV_VER_2 == 0
; =============== MoveC_MrKarate_Unused_RyukoRanbuD ===============
; [TCRF] Unused desperation version of Mr.Karate's Ryuko Ranbu (MOVE_MRKARATE_RYUKO_RANBU_UNUSED_D).
; Almost identical to MoveC_Ryo_RyuKoRanbuD.
; This is completely gone in the English version.
MoveC_MrKarate_Unused_RyukoRanbuD:
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
	jp   z, .objOdd
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $07*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $09*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $0B*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $0D*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $0F*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $11*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $13*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $15*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $17*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $19*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $1B*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $1D*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $1F*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $21*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $23*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $25*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $27*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $29*OBJLSTPTR_ENTRYSIZE
	jp   z, .objOdd
	cp   $2C*OBJLSTPTR_ENTRYSIZE
	jp   z, .startZenretsuken
	cp   $2D*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .objEven
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameStart .obj1_chkGuard
		mMvC_PlaySound SCT_MOVEJUMP_A
		; Set different jump speed depending on light / heavy version.
		mMvIn_ChkLH .obj1_setJumpH
	.obj1_setJumpL:
		mMvC_SetSpeedH +$05FF
		mMvC_SetSpeedV -$0200
		jp   .doGravity
	.obj1_setJumpH:
		mMvC_SetSpeedH +$06FF
		mMvC_SetSpeedV -$0280
		jp   .doGravity
.obj1_chkGuard:
IF REV_VER_2 == 0
	;
	; Continue the jump until hitting the opponent.
	;
	ld   hl, iPlInfo_ColiFlags
	add  hl, bc
	bit  PCF_HITOTHER, [hl]				; Did we reach?
	jp   z, .obj1_chkGuard_doGravity	; If not, skip
	ld   hl, iPlInfo_Flags1Other
	add  hl, bc
	bit  PF1B_INVULN, [hl]				; Is the opponent invulnerable?
	jp   nz, .obj1_chkGuard_doGravity	; If so, skip
	bit  PF1B_HITRECV, [hl]				; Did the opponent get hit?
	jp   z, .obj1_chkGuard_doGravity	; If not, skip	
	
	bit  PF1B_GUARD, [hl]				; Is the opponent blocking?
	jp   nz, .obj1_chkGuard_guard		; If so, jump
ELSE
	; Identical check, but calling the copy in BANK 0 to save space.
	mMvC_ValHit .obj1_chkGuard_doGravity, .obj1_chkGuard_guard
ENDC
	.obj1_chkGuard_noGuard:
		; Otherwise, continue to #2
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI1, PF3_LASTHIT
		mMvC_SetFrame $02*OBJLSTPTR_ENTRYSIZE, $01
		mMvC_SetSpeedH $0000
		; Force player on the ground
		ld   hl, iOBJInfo_Y
		add  hl, de
		ld   [hl], PL_FLOOR_POS
		jp   .ret
.obj1_chkGuard_guard:
	; If the opponent blocked the hit, slow down considerably.
	; This will still moves us back for overlapping with the opponent.
	mMvC_SetSpeedH $0100
.obj1_chkGuard_doGravity:
	jp   .doGravity
; --------------- frames #3,5,7,9... ---------------
; Generic damage - odd frames.
; Alongside .objEven is used to alternate between hit effects constantly.
.objOdd:
	call OBJLstS_ApplyXSpeed
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI1, PF3_LASTHIT
		jp   .chkOtherEscape
; --------------- frame #2 ---------------
; Initial frame before the odd/even switching.
; This sets the initial jump speed and doesn't check for block yet.
.obj2:
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI0, PF3_LASTHIT
		mMvC_SetSpeedH $0080
		jp   .anim
; --------------- frames #4,6,8,A,... ---------------
; Generic damage - even frames.
.objEven:
	call OBJLstS_ApplyXSpeed
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITTYPE_HIT_MULTI0, PF3_LASTHIT
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
			; Otherwise, transition to hop
			ld   a, MOVE_SHARED_HOP_B
			call Pl_SetMove_StopSpeed
			jp   .ret
		
; --------------- frame #2C ---------------
; Transitions to what would have been hidden version of Ko Ou Ken at the end of the frame.
; This points to a move with the proper code, but dummy animation (so it wouldn't work properly).
.startZenretsuken:
	mMvC_ValFrameEnd .anim
		mMvIn_ChkLH .startZenretsukenH
	.startZenretsukenL:
		ld   a, MOVE_MRKARATE_KO_OU_KEN_UNUSED_EL
		jp   .startZenretsuken_setMove
	.startZenretsukenH:
		ld   a, MOVE_MRKARATE_KO_OU_KEN_UNUSED_EH
	.startZenretsuken_setMove:
		call MoveInputS_SetSpecMove_StopSpeed
		mMvC_SetDamageNext $02, HITTYPE_DROP_MAIN, PF3_LASTHIT
		jp   .ret
; --------------- common gravity check ---------------	
.doGravity:
	mMvC_ChkGravityHV $0030, .anim
		jp   .end
		; [TCRF] Unreferenced leftover from MoveC_Kyo_RyuKoRanbuD
		mMvC_SetLandFrame $2D*OBJLSTPTR_ENTRYSIZE, $07
		jp   .ret
; --------------- frame #2D ---------------
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
ENDC

; =============== MoveC_*_ThrowG ===============
; Move code for ground throws, character-specific.
;
; These are only executed when the throw is *confirmed*, with wPlayPlThrowActId
; being initially set to PLAY_THROWACT_NEXT03 as done by BasicInput_StartGroundThrow.
;
; As the opponent is "stuck" in the grab mode waiting to get hit, it's important
; to deal damage to him at some point before he gets automatically unstuck (ANIMSPEED_NONE isn't infinite).
; Hits caused by throws should deal more damage and cause the opponent to drop to the ground.

; =============== MoveC_Kyo_ThrowG ===============
; Move code for Kyo's throw (MOVE_SHARED_THROW_G).
MoveC_Kyo_ThrowG:
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
; --------------- frame #0,#1-(end) ---------------
	mMvC_ChkTarget .chkEnd
	jp   .anim
; --------------- frame #1 ---------------
; When visually switching to #2, hit the opponent.
.obj1:
	mMvC_ValFrameEnd .anim ; About to advance the anim? If not, skip to .anim
	mMvC_SetDamageNext $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; 6 lines of damage on hit, make opponent drop on ground
	jp   .anim
; --------------- common ---------------
.chkEnd:
	; Wait for the animation to advance before ending the move
	mMvC_ValFrameEnd .anim
	call Play_Pl_EndMove
	; And when it does, also reset the throw sequence
	xor  a
	ld   [wPlayPlThrowActId], a
	jr   .ret
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Daimon_ThrowG ===============
; Move code for Daimon's throw (MOVE_SHARED_THROW_G).	
MoveC_Daimon_ThrowG:
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
	jp   z, .hit
; --------------- frame #3-(end) ---------------
	mMvC_ChkTarget .chkEnd
	jp   .anim
; --------------- frame #0 ---------------
; Set U rotation frame to opponent the first time we get here.
.rotU:
	mMvC_ValFrameStart .rotU_anim
	mMvC_SetDamage $06, HITTYPE_THROW_ROTU, PF3_HEAVYHIT ; Damage ignored in this hitanim
	mMvC_MoveThrowOp -$08, $00	; Move left 8px
.rotU_anim:
	jp   .anim
; --------------- frame #1 ---------------
; Set L rotation frame to opponent the first time we get here.
.rotL:
	mMvC_ValFrameStart .rotL_anim
	mMvC_SetDamage $06, HITTYPE_THROW_ROTL, PF3_HEAVYHIT ; Damage ignored in this hitanim
	mMvC_MoveThrowOp +$08, -$08	; Move right 8px (reset), up 8px
.rotL_anim:
	jp   .anim
; --------------- frame #2 ---------------
; Deal damage the first time we get here.
.hit:
	mMvC_ValFrameStart .obj2_anim
	mMvC_SetDamage $06, HITTYPE_DROP_DB_A, PF3_HEAVYHIT
.obj2_anim:
	jp   .anim
; --------------- common ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
	mMvC_EndThrow
	jr   .ret
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Terry_ThrowG ===============
; Move code for Terry's throw (MOVE_SHARED_THROW_G).
MoveC_Terry_ThrowG:
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage
; --------------- frames #1-(end) ---------------
	mMvC_ChkTarget .chkEnd
	jp   .anim
; --------------- frame #0 ---------------
.setDamage:
	; When switching to #1, deal damage to the opponent
	mMvC_ValFrameEnd .anim
	
	mMvC_SetDamageNext $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT
	jp   .anim
; --------------- common ---------------
.chkEnd:
	; End the move when the anim advances
	mMvC_ValFrameEnd .anim
	mMvC_EndThrow
	jr   .ret
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
; =============== MoveC_Andy_ThrowG ===============
; Move code for Andy's throw (MOVE_SHARED_THROW_G).
MoveC_Andy_ThrowG:
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
	; The first time we get here...
	mMvC_ValFrameStart .obj0_waitManCtrl
	
	; Set damage rotation frame
	mMvC_SetDamage $06, HITTYPE_THROW_ROTL, PF3_HEAVYHIT
	; Move opponent left 2px, up 20px
	mMvC_MoveThrowOp -$02, -$20

	
.obj0_waitManCtrl:
	; [POI] This accidentally points to the .anim from another move code.
	;       It does the same thing at least.
IF FIX_BUGS == 1 
	mMvC_ValFrameEnd .anim
	mMvC_SetAnimSpeed ANIMSPEED_INSTANT
	jp   .anim
ELSE
	mMvC_ValFrameEnd MoveC_Terry_ThrowG.anim
	; The above macro set HL = Ptr to iOBJInfo_FrameLeft
	mMvC_SetAnimSpeed ANIMSPEED_NONE
	jp   .anim
ENDC

	
; --------------- frame #1 ---------------
.obj1:
	; The first time we get here, init the jump settings.
	; From the second time, skip to the gravity code.
	mMvC_ValFrameStart .obj1_move
	
	; Play SGB/DMG SFX
	ld   a, SCT_MOVEJUMP_B
	call HomeCall_Sound_ReqPlayExId
	
	; Start neutral jump
	mMvC_SetSpeedH $0000	; No h movement
	mMvC_SetSpeedV -$0600	; 6px/frame up
	
	; Set new rotation frame
	mMvC_SetDamage $06, HITTYPE_THROW_ROTR, PF3_HEAVYHIT
	; Move opponent left 2px, up 10px
	mMvC_MoveThrowOp -$02, -$10
	mMvC_MoveThrowOpSync
.obj1_move:
	jp   .uhok
.uhok:
	; Fall to the ground at $00.60px/frame
	mMvC_ChkGravityHV $0060, .anim
	; Once we touched the ground, switch to the next frame
	mMvC_SetLandFrame $02*OBJLSTPTR_ENTRYSIZE, $0A
	jp   .ret
	
; --------------- frame #2 ---------------
.obj2:
	; The first time we get here...
	mMvC_ValFrameStart .anim
	; Set new rotation frame
	mMvC_SetDamage $06, HITTYPE_THROW_ROTR, PF3_HEAVYHIT
	; Move opponent left 2px
	mMvC_MoveThrowOp -$02, +$00

	jp   .anim
; --------------- frame #3 ---------------
.obj3:
	; The first time we get here...
	mMvC_ValFrameStart .anim
	; Set new rotation frame
	mMvC_SetDamage $06, HITTYPE_THROW_ROTR, PF3_HEAVYHIT
	; Move opponent left 2px
	mMvC_MoveThrowOp -$02, +$00

	jp   .anim
; --------------- frame #4 ---------------
.obj4:
	; The first time we get here, damage the player
	mMvC_ValFrameStart .chkEnd
	mMvC_SetDamage $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT
.chkEnd:
	; End the move when the anim advances
	mMvC_ValFrameEnd .anim
	mMvC_EndThrow_Slow
	jp   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Ryo_ThrowG ===============
; Move code for Ryo's and Mr.Karate's throw (MOVE_SHARED_THROW_G).
MoveC_Ryo_ThrowG:
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
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim ; We never get here
; --------------- frame #0 ---------------
.rotU:
	mMvC_ValFrameStart .anim
	mMvC_SetDamage $06, HITTYPE_THROW_ROTU, PF3_HEAVYHIT
	mMvC_MoveThrowOp -$08, +$00
	jp   .anim
; --------------- frame #1 ---------------
.rotL:
	mMvC_ValFrameStart .anim
	mMvC_SetDamage $06, HITTYPE_THROW_ROTL, PF3_HEAVYHIT
	mMvC_MoveThrowOp +$01, -$10
	jp   .anim
; --------------- frame #2 ---------------
.setDamage:
	mMvC_ValFrameStart .anim
	mMvC_SetDamage $06, HITTYPE_THROW_END, PF3_HEAVYHIT
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
	
; =============== MoveC_Robert_ThrowG ===============
; Move code for Robert's throw (MOVE_SHARED_THROW_G).
MoveC_Robert_ThrowG:
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim
; --------------- frame #1 ---------------
; Damages the player when switching to #2.
.setDamage:
	mMvC_ValFrameEnd .anim
	mMvC_SetDamageNext $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT
	jp   .anim
; --------------- frame #2 ---------------
; When switching to #3, make Robert jump back.
.chkEnd:
	mMvC_ValFrameEnd .anim
	; Set a new move to do the jump.
	ld   a, MOVE_SHARED_BACKJUMP_REC_A
	call Pl_SetMove_StopSpeed
	; Initialize jump settings
	mMvC_SetSpeedH -$0300	; 3px/frame backwards
	mMvC_SetSpeedV -$0500	; 5px/frame up
	; End throw
	xor  a
	ld   [wPlayPlThrowActId], a
	jr   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Athena_ThrowG ===============
; Move code for Athena's throw (MOVE_SHARED_THROW_G).	
MoveC_Athena_ThrowG:
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .rotL
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .rotD
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .rotR
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .rotU
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
; --------------- frame #0 ---------------
	jp   .anim
; --------------- frame #1 ---------------
.rotL:
	mMvC_ValFrameStart .anim
	mMvC_SetDamage $06, HITTYPE_THROW_ROTL, PF3_HEAVYHIT
	mMvC_MoveThrowOp +$01, -$08
	jp   .anim
; --------------- frame #2 ---------------
.rotD:
	mMvC_ValFrameStart .anim
	mMvC_SetDamage $06, HITTYPE_THROW_ROTD, PF3_HEAVYHIT
	mMvC_MoveThrowOp -$02, -$08
	jp   .anim
; --------------- frame #3 ---------------
.rotR:
	mMvC_ValFrameStart .anim
	mMvC_SetDamage $06, HITTYPE_THROW_ROTR, PF3_HEAVYHIT
	mMvC_MoveThrowOp +$01, -$08
	jp   .anim
; --------------- frame #4 ---------------
.rotU:
	mMvC_ValFrameStart .anim
	mMvC_SetDamage $06, HITTYPE_THROW_ROTU, PF3_HEAVYHIT
	mMvC_MoveThrowOp -$02, -$08
	jp   .anim
; --------------- frame #5 ---------------
.setDamage:
	mMvC_ValFrameStart .anim
	mMvC_SetDamage $06, HITTYPE_THROW_END, PF3_HEAVYHIT
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
	
; =============== MoveC_Base_ThrowA_DiagF ===============
; Move code for air throws that launch the opponent forwards, diagonally down.
; Used for Leona and Athena's air throws (MOVE_SHARED_THROW_A).
MoveC_Base_ThrowA_DiagF:
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
	jp   .anim
; --------------- frame #0 ---------------
.obj0:
	; The first time we get here...
	mMvC_ValFrameStart .anim
	mMvC_SetDamage $06, HITTYPE_THROW_ROTL, PF3_HEAVYHIT
	mMvC_MoveThrowOp -$08, -$08 ; 8px left, 8px up
	jp   .anim
; --------------- frame #1 ---------------
.obj1:
	; The first time we get here...
	mMvC_ValFrameStart .anim
	mMvC_SetDamage $06, HITTYPE_THROW_ROTD, PF3_HEAVYHIT
	mMvC_MoveThrowOp -$08, -$08 ; 8px left, 8px up
	jp   .anim
; --------------- frame #2 ---------------
.obj2:
	; The first time we get here...
	mMvC_ValFrameStart .obj2_setManCtrl
	
	; Throw opponent forward, diagonally down + damage for 6 lines
	mMvC_SetDamage $06, HITTYPE_DROP_DB_A, PF3_HEAVYHIT
	
	; Move us 2px back, 2px up
	mMvC_SetSpeedH -$0200
	mMvC_SetSpeedV -$0200
.obj2_setManCtrl:
	; When about to advance to #3, get manual ctrl
	mMvC_ValFrameEnd .obj3
	mMvC_SetAnimSpeed ANIMSPEED_NONE
	jp   .obj3
; --------------- frame #2-3 ---------------
.obj3:
	; If at any point while #2 or #3 are displayed, the player touches the ground,
	; switch directly to the landing sprite.
	mMvC_ChkGravityHV $0060, .anim		; If not, skip
	mMvC_SetLandFrame $04*OBJLSTPTR_ENTRYSIZE, $04
	jp   .ret
; --------------- frame #4 ---------------
.chkEnd:
	; End the move when trying to switch to #5
	mMvC_ValFrameEnd .anim
	mMvC_EndThrow
	jr   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Mai_ThrowG ===============
; Move code for Mai's throw (MOVE_SHARED_THROW_G).
MoveC_Mai_ThrowG:
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
	jp   z, .setDamage
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim ; We never get here
; --------------- frame #0 ---------------
.obj0:
	mMvC_ValFrameStart .anim
	; [POI] Useless
	mMvC_SetMoveH $0000
	; Set rotation frame
	mMvC_SetDamage $06, HITTYPE_THROW_ROTU, PF3_HEAVYHIT
	; Move thrown player left 8px
	mMvC_MoveThrowOp -$08, +$00
	jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameStart .anim
	; Move player left 8px
	mMvC_SetMoveH -$0800
	; Set rotation frame again to apply Play_Pl_MoveRotThrown
	mMvC_SetDamage $06, HITTYPE_THROW_ROTU, PF3_HEAVYHIT
	; Move opponent left $10px
	mMvC_MoveThrowOp -$10, +$00
	jp   .anim
; --------------- frame #2 ---------------
.obj2:
	mMvC_ValFrameStart .anim
	; Move player left $10px
	mMvC_SetMoveH $1000
	;--
	; [POI] Not needed
	; Set rotation frame again to apply Play_Pl_MoveRotThrown
	mMvC_SetDamage $06, HITTYPE_THROW_ROTU, PF3_HEAVYHIT
	; (nothing)
	mMvC_MoveThrowOp +$00, +$00
	;--
	jp   .anim
; --------------- frame #3 ---------------
.obj3:
	mMvC_ValFrameStart .anim
	; Move player right $08px
	mMvC_SetMoveH $0800
	; Set rotation frame again to apply Play_Pl_MoveRotThrown
	mMvC_SetDamage $06, HITTYPE_THROW_ROTU, PF3_HEAVYHIT
	; Move opponent right $10px (reset)
	mMvC_MoveThrowOp +$10, +$00
	jp   .anim
; --------------- frame #4 ---------------
.setDamage:
	mMvC_ValFrameStart .anim
	mMvC_SetMoveH $0000 ; [POI] Useless
	mMvC_SetDamage $06, HITTYPE_THROW_END, PF3_HEAVYHIT
	jp   .anim
; --------------- frame #5 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
	mMvC_EndThrow
	jr   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Base_ThrowA_DirD ===============
; Move code for air throws that launch the opponent straight down.
; Used for Mai's air throw (MOVE_SHARED_THROW_A).
MoveC_Base_ThrowA_DirD:
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
	; The first time we get here...
	mMvC_ValFrameStart .obj0_setManCtrl
	
	; Set damage rotation frame
	mMvC_SetDamage $06, HITTYPE_THROW_ROTR, PF3_HEAVYHIT
	; Move opponent left 2px, up 1px
	mMvC_MoveThrowOp -$02, -$01

	
.obj0_setManCtrl:
	; When switching to #1, get manual control of the animation
	; [POI] copy/pasting wins
IF FIX_BUGS == 1
	mMvC_ValFrameEnd .anim
	mMvC_SetAnimSpeed ANIMSPEED_NONE
	jp   .anim
ELSE
	mMvC_ValFrameEnd MoveC_Mai_ThrowG.anim
	mMvC_SetAnimSpeed ANIMSPEED_NONE
	jp   MoveC_Andy_ThrowG.anim
ENDC
; --------------- frame #1 ---------------
.obj1:
	; The first time we get here...
	mMvC_ValFrameStart .obj1_move
	
	; Play SGB/DMG SFX
	ld   a, SCT_MOVEJUMP_B
	call HomeCall_Sound_ReqPlayExId
	
	; (nothing)
	mMvC_SetSpeedH $0000
	; Move player 1px up
	mMvC_SetSpeedV -$0100
	
	; Move opponent left 2px, up 1px
	mMvC_SetDamage $06, HITTYPE_THROW_ROTR, PF3_HEAVYHIT ; Same as before, to enable Play_Pl_MoveRotThrown
	mMvC_MoveThrowOp -$02, -$01
	mMvC_MoveThrowOpSync
.obj1_move:
	jp   .uhok
.uhok:
	; Move down $00.60px/frame until we touch the ground.
	; Switch to the landing frame when that happens.
	mMvC_ChkGravityHV $0060, .anim						; If not, jump
	
	; Once the ground is touched, switch to #2
	mMvC_SetLandFrame $02*OBJLSTPTR_ENTRYSIZE, $02
	
	; Move opponent left 2px, up 1px
	mMvC_SetDamage $06, HITTYPE_THROW_ROTR, PF3_HEAVYHIT ; Same as before, to enable Play_Pl_MoveRotThrown
	mMvC_MoveThrowOp -$02, -$01
	
	;--
	; Not necessary, already done by Play_Pl_MoveRotThrown
	ld   a, $00
	ld   [wPlayPlThrowRotSync], a
	;--
	jp   .ret
; --------------- frame #2 ---------------
.obj2:
	; The first time we get here, make the throw deal damage
	mMvC_ValFrameStart .chkEnd
	mMvC_SetDamage $06, HITTYPE_DROP_DB_A, PF3_HEAVYHIT
.chkEnd:
	; Start backjump when switching to #3.
	
	; [POI] copy/pasting won here too
IF FIX_BUGS == 1
	mMvC_ValFrameEnd .anim
ELSE
	mMvC_ValFrameEnd MoveC_Mai_ThrowG.anim
ENDC
	ld   a, MOVE_SHARED_BACKJUMP_REC_A
	call Pl_SetMove_StopSpeed
	mMvC_SetSpeedH -$0300 ; 3px/frame back
	mMvC_SetSpeedV -$0500 ; 5px/frame up
	xor  a ; PLAY_THROWACT_NONE
	ld   [wPlayPlThrowActId], a
	jp   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret  

; =============== MoveC_Leona_ThrowG ===============
; Move code for Leona's throw (MOVE_SHARED_THROW_G).
MoveC_Leona_ThrowG:
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .setDamage
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkEnd
	jp   .anim ; We never get here
; --------------- frame #0 ---------------
; Damage player when switching to #1.
.setDamage:
	mMvC_ValFrameEnd .anim
	mMvC_SetDamageNext $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT
	jp   .anim
; --------------- frame #1 ---------------
.obj1:
	jp   .anim ; huh ok
; --------------- frame #2 ---------------
; Start backjump when switching to #3.
.chkEnd:
	mMvC_ValFrameEnd .anim
	ld   a, MOVE_SHARED_BACKJUMP_REC_A
	call Pl_SetMove_StopSpeed
	mMvC_SetSpeedH -$0300 ; 3px/frame back
	mMvC_SetSpeedV -$0500 ; 5px/frame up
	xor  a ; PLAY_THROWACT_NONE
	ld   [wPlayPlThrowActId], a
	jp   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
IF REV_LANG_EN == 1

; This was in Bank $1C in the Japanese version

; =============== MoveC_Base_NormL_2Hit_D06_A03 ===============
; Generic move code used for light normals that hit twice.
; See also: MoveC_Base_NormH_2Hit_D06_A04
MoveC_Base_NormL_2Hit_D06_A03:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]		; A = OBJLst ID
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj0
; --------------- frame #1-(end) ---------------
	mMvC_ChkTarget .chkEnd
	jp   .anim
; --------------- frame #0 ---------------
; When visually switching to #1, use new damage info.
.obj0:
	mMvC_ValFrameEnd .anim ; About to advance the anim? If not, skip to .anim
	; Otherwise, request new damage fields to apply when visually switching frames
	mMvC_SetDamageNext $06, HITTYPE_HIT_MID0, PF3_HEAVYHIT
	jp   .anim
; --------------- common ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
	call Play_Pl_EndMove
	jr   .ret
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Base_NormH_2Hit_D06_A04 ===============
; Generic move code used for heavy normals that hit twice.
MoveC_Base_NormH_2Hit_D06_A04:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]		; A = OBJLst ID
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
; --------------- frame #0,2-(end) ---------------
	mMvC_ChkTarget .chkEnd
	jp   .anim
; --------------- frame #1 ---------------
; When visually switching to #2, use new damage info.
; Doing this allows the move to hit twice, since hitting the opponent removes
; the damage value for the move, to avoid multiple hits.
; So, if we hit the opponent before the the new damage gets applied (ie: pretty much always)
; the move will hit twice.
.obj1:
	mMvC_ValFrameEnd .anim ; About to advance the anim? If not, skip to .anim
	; Otherwise, request new damage fields to apply when visually switching frames
	mMvC_SetDamageNext $06, HITTYPE_HIT_MID1, PF3_HEAVYHIT
	jp   .anim
; --------------- common ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
	call Play_Pl_EndMove
	jr   .ret
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_MrBig_PunchH ===============
; Move code used for Mr.Big's heavy punch. 
; This is like MoveC_Base_NormH_2Hit_D06_A04, except the player moves
; forward 7px at the start of #0 and #1.
MoveC_MrBig_PunchH:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]		; A = OBJLst ID
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj0
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
; --------------- frame #2-(end) ---------------
	mMvC_ChkTarget .chkEnd
	jp   .anim
; --------------- frame #0 ---------------
; The first time we get here, move 7px forward.
.obj0:
	mMvC_ValFrameStart .anim					; If not, jump
	mMvC_SetMoveH $0700
	jp   .anim
; --------------- frame #1 ---------------
.obj1:
	;
	; The first time we get here, move 7px forward.
	;
	mMvC_ValFrameStart .obj1_chkAdv			; If not, jump
	mMvC_SetMoveH $0700
.obj1_chkAdv:
	;
	; When visually switching to #2, use new damage info.
	;
	mMvC_ValFrameEnd .anim ; About to advance the anim? If not, skip to .anim
	; Otherwise, request new damage fields to apply when visually switching frames
	mMvC_SetDamageNext $06, HITTYPE_HIT_MID1, PF3_HEAVYHIT
	jp   .anim
; --------------- common ---------------	
.chkEnd:
	mMvC_ValFrameEnd .anim
	call Play_Pl_EndMove
	jr   .ret
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Mature_PunchH ===============
; Move code used for Mature's heavy punch, this is almost the same
; as the one for Mr.Big's heavy punch, except for the logic of #0 being moved to #3,
; and different code to account for it.
;
; See also: MoveC_MrBig_PunchH
MoveC_Mature_PunchH:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj3
	
; --------------- frame #0,#2 ---------------
	; [POI] Could have been just "jp .anim". We get to .chkEnd anyway in #3
	mMvC_ChkTarget .chkEnd
	jp   .anim
; --------------- frame #3 ---------------
; The first time we get here, move 7px forward.
; When attempting to visually switch to #4, end the move instead.
.obj3:
	mMvC_ValFrameStart .obj3_chkAdv		; If not, jump
	mMvC_SetMoveH $0700				; Otherwise move forward
.obj3_chkAdv:
	;--
	; [POI] This is pointless, as .chkEnd checks it anyway.
	mMvC_ValFrameEnd .anim
	;--
	jp   .chkEnd
; --------------- frame #1 ---------------
.obj1:
	;
	; The first time we get here, move 7px forward.
	;
	mMvC_ValFrameStart .obj1_chkAdv
	mMvC_SetMoveH $0700
.obj1_chkAdv:
	;
	; When visually switching to #2, use new damage info.
	;
	mMvC_ValFrameEnd .anim ; About to advance the anim? If not, skip to .anim
	; Otherwise, request new damage fields to apply when visually switching frames
	mMvC_SetDamageNext $06, HITTYPE_HIT_MID1, PF3_HEAVYHIT
	jp   .anim
; --------------- common ---------------	
.chkEnd:
	mMvC_ValFrameEnd .anim
	call Play_Pl_EndMove
	jr   .ret
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Goenitz_PunchH ===============
; Move code used for Goenitz's heavy punch, which hits 3 times.
;
; This is like Mature's heavy punch except for the extra hit on #4.
;
; See also: MoveC_Mature_PunchH	
MoveC_Goenitz_PunchH:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj3
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj4
; --------------- frame #0,#2,#5-(end) ---------------
	mMvC_ChkTarget .chkEnd
	jp   .anim
; --------------- frame #1 ---------------
.obj1:
	; The first time we get here, move 7px forward.
	mMvC_ValFrameStart .obj1_chkAdv
	mMvC_SetMoveH $0700
.obj1_chkAdv:
	; When visually switching to #2, use new damage info.
	mMvC_ValFrameEnd .anim ; About to advance the anim? If not, skip to .anim
	; Otherwise, request new damage fields to apply when visually switching frames
	mMvC_SetDamageNext $06, HITTYPE_HIT_MID1, $00
	jp   .anim
; --------------- frame #3 ---------------
.obj3:
	; The first time we get here, move 7px forward.
	mMvC_ValFrameStart .obj3_chkAdv
	mMvC_SetMoveH $0700
.obj3_chkAdv:
	; When visually switching to #2, use new damage info.
	mMvC_ValFrameEnd .anim ; About to advance the anim? If not, skip to .anim
	; Otherwise, request new damage fields to apply when visually switching frames
	mMvC_SetDamageNext $06, HITTYPE_HIT_MID0, PF3_HEAVYHIT
	jp   .anim
; --------------- frame #4 ---------------
.obj4:
	; The first time we get here, move 7px forward.
	mMvC_ValFrameStart .anim
	mMvC_SetMoveH $0700
	jp   .anim
; --------------- common ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
	call Play_Pl_EndMove
	jr   .ret
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Goenitz_PunchH ===============
; Move code used for Goenitz's heavy kick, which hits 2 times.	
MoveC_Goenitz_KickH:
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
; --------------- frame #0,#3-(end) ---------------
	mMvC_ChkTarget .chkEnd
	jp   .anim
; --------------- frame #1 ---------------
.obj1:
	; The first time we get here, move 7px forward.
	mMvC_ValFrameStart .anim
	mMvC_SetMoveH $0700
	jp   .anim
; --------------- frame #2 ---------------
.obj2:
	; The first time we get here, move 7px forward.
	mMvC_ValFrameStart .obj2_chkAdv
	mMvC_SetMoveH $0700
.obj2_chkAdv:
	mMvC_ValFrameEnd .anim ; About to advance the anim? If not, skip to .anim
	; Otherwise, request new damage fields to apply when visually switching frames
	mMvC_SetDamageNext $06, HITTYPE_HIT_MID1, PF3_HEAVYHIT
	jp   .anim
; --------------- common ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
	call Play_Pl_EndMove
	jr   .ret
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
ENDC

; =============== END OF BANK ===============
; Junk area below.
; Contains duplicate move code.
IF REV_VER_2 == 0
	mIncJunk "L027EBF"
ELSE
	mIncJunk "L027F70"
ENDC