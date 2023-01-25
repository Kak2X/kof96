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
	ld   a, SND_ID_26		; A = Step SFX for Daimon
.playSFX:
	call HomeCall_Sound_ReqPlayExId	; Play that
	
.chkEnd:
	;
	; The player needs to hold forward to continue running.
	; Use Play_Pl_GetDirKeys_ByXFlipR to get d-pad keys relative to the 1P side.
	;
	call Play_Pl_CreateJoyMergedKeysLH	; Did we just press A or B?
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
	call Play_Pl_CreateJoyMergedKeysLH	; Pressed any new LH button?
	jp   nc, .chkAnim					; If not, skip
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
	ld   hl, iPlInfo_JoyMergedKeysLH
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
	; New move
	ld   a, MOVE_SHARED_DIZZY
	call Pl_Unk_SetNewMoveAndAnim_StopSpeed
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
; by mashing buttons ????
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
Play_Pl_DecDizzyTime:

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
; Custom code for moves used when the round ends (MOVE_SHARED_WIN_NORM, MOVE_SHARED_WIN_ALT, MOVE_SHARED_LOST_TIMEOVER).
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
	cp   MOVE_SHARED_WIN_ALT	; Using the second win anim?
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
	
	; HITANIM_DROP_SPEC_AIR_0E, HITANIM_DROP_SPEC_0F and the throw parts do not increment the combo counter.
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
	mMvC_ChkMaxPow L0246BC
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
	mMvC_SetSpeedV $0000
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
	mMvC_SetSpeedV $FC00
	jp   L024802
L0247F6:;J
	ld   hl, $0180
	call Play_OBJLstS_SetSpeedH_ByXDirL
	mMvC_SetSpeedV $FA00
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
	mMvC_SetSpeedV $0600
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
	mMvC_SetSpeedH $0900
	mMvC_SetSpeedV $FC00
	jp   L0248F9
L0248CF:;J
	mMvC_SetSpeedH $FD00
	mMvC_SetSpeedV $FC00
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
	mMvC_SetSpeedV $FC00
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
	mMvC_SetSpeedV $F900
	ld   hl, $0300
	jp   L024931
L024928:;R
	mMvC_SetSpeedV $F400
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
	call OBJLstS_ApplyGravityVAndMoveHV
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
	mMvC_SetSpeedV $FC00
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
	jp   HitAnim_ThrowRotCustom
HitAnim_ThrowRotL:;I
	ld   a, $94
	jp   HitAnim_ThrowRotCustom
HitAnim_ThrowRotD:;I
	ld   a, $96
	jp   HitAnim_ThrowRotCustom
HitAnim_ThrowRotR:;I
	ld   a, $98
	jp   HitAnim_ThrowRotCustom
HitAnim_ThrowRotCustom:;J
	call Pl_Unk_SetNewMoveAndAnim_ShakeScreenReset
	call L024AC1
	ld   a, [wPlayPlThrowRotMoveH]
	ld   h, a
	ld   l, $00
	call Play_OBJLstS_MoveH_ByOtherXFlipL
	ld   a, [wPlayPlThrowRotMoveV]
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
		; converge back at Play_Pl_SetHitAnim_ChkGuardBypass (but not before setting the PF0B_PROJHIT flag)
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
			jp   z, Play_Pl_SetHitAnim_RetClear	; If not, return
			
			;
			; Retrieve the move damage fields from the projectile.
			;
			ld   d, [hl]	; D = iOBJInfo_Play_DamageVal
			inc  hl
			ld   e, [hl]	; E = iOBJInfo_Play_DamageHitAnimId
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
			res  PF0B_PROJHIT, [hl]
			
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
			
			; This is the first of many whitelists where some moves can't be overriden at all.
			; HITANIM_HIT_SPEC_09, HITANIM_HIT_SPEC_0A and HITANIM_HIT_SPEC_0B in particular
			; tend to be used by special moves that hit multiple times for every hit
			; except the last one, thus preventing the opponent from escaping mid-move.
			;
			; [TCRF?] Even then, some moves actually have an "escape check" to perform an action if
			;         the opponent were to escape. Usually, the player will hop back, but Iori's 
			;         desperation super makes it transition to a completely unique move.
			;         Because of this blacklist, their effect becomes unreachable.
			;
			
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
			call Play_Pl_IsDizzyNext	; Are we supposed to get dizzy on this hit?
			jp   z, .noDizzy			; If not, jump
		.dizzy:
			; Handle the animation blacklist when getting hit "right before getting" dizzy.
			; When getting dizzy, the player will drop to the ground regardless of the hit animation,
			; by overriding whatever animation was set with HITANIM_DROP_MD (by reaching .useStdDrop).
			; However, the animations checked below can't be overridden.
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
			bit  PF0B_PROJHIT, [hl]	; Did we get hit by a projectile?
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
	mMvC_DoFrictionH $0040
	jp   nc, L02509C
	call Play_Pl_EndMove
L02509C:;J
	ret
L02509D:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L0250A0:;I
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded L0251F1
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
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
	mMvC_ValFrameEnd L025160
	mMvC_SetAnimSpeed ANIMSPEED_NONE
	jp   L025160
L0250DF:;J
	mMvC_ValFrameEnd L0251EE
	mMvC_SetAnimSpeed ANIMSPEED_NONE
	ld   hl, $0023
	add  hl, bc
	bit  0, [hl]
	jp   nz, L025100
	ld   hl, $0140
	call Play_OBJLstS_SetSpeedH_ByXDirL
	mMvC_SetSpeedV $FC00
	jp   L02510C
L025100:;J
	ld   hl, $0180
	call Play_OBJLstS_SetSpeedH_ByXDirL
	mMvC_SetSpeedV $FA00
L02510C:;J
	mMvC_SetMoveV -$0100
	ld   hl, $0000
	call OBJLstS_ApplyGravityVAndMoveHV
	jp   L0251EE
L02511B:;J
	ld   hl, $0000
	add  hl, de
	bit  3, [hl]
	jp   z, L025160
	mMvC_SetMoveV -$0100
	jp   L025160
L02512D:;J
	mMvC_ValFrameEnd L0251EE
	mMvC_SetAnimSpeed ANIMSPEED_NONE
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
	mMvC_SetSpeedV $FD00
	jp   L0251CF
L02515D:;J
	jp   L0251CF
L025160:;J
	mMvC_ChkGravityHV $0060, L0251EE
	call Play_Pl_IsDizzyNext
	jp   nz, L02517E
	ld   hl, $004E
	add  hl, bc
	ld   a, [hl]
	or   a
	jp   z, L02517E
	call Play_Pl_AreBothBtnHeld
	jp   c, L025196
L02517E:;J
	mMvC_SetDropFrame $08, $05
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
	mMvC_ChkGravityHV $0060, L0251EE
	mMvC_SetDropFrame $10, $05
	jp   L0251F1
L0251E2:;J
	mMvC_ValFrameEnd L0251EE
	call L003CB3
	jp   L0251F1
L0251EE:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L0251F1:;J
	ret
L0251F2:;I
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded L0252CA
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
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
	mMvC_SetSpeedH $0300
L025242:;J
	jp   L02527F
L025245:;J
	call Play_Pl_DoGroundScreenShake
	mMvC_ValFrameEnd L0252C7
	mMvC_SetAnimSpeed ANIMSPEED_NONE
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
	mMvC_SetSpeedV $FD00
	jp   L0252A8
L02527C:;J
	jp   L0252A8
L02527F:;J
	mMvC_ChkGravityHV $0060, L0252C7
	mMvC_SetDropFrame $04, $09
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
	mMvC_ChkGravityHV $0060, L0252C7
	mMvC_SetDropFrame $0C, $05
	jp   L0252CA
L0252BB:;J
	mMvC_ValFrameEnd L0252C7
	call L003CB3
	jp   L0252CA
L0252C7:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L0252CA:;J
	ret
L0252CB:;I
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded L025326
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
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
	mMvC_ValFrameEnd L025323
	mMvC_SetAnimSpeed $05
	ld   a, $0E
	call HomeCall_Sound_ReqPlayExId
	jp   L025323
L0252FC:;J
	call Play_Pl_DoGroundScreenShake
	mMvC_ValFrameEnd L025323
	mMvC_SetAnimSpeed $10
	xor  a
	ld   [wScreenShakeY], a
	ld   hl, $0023
	add  hl, bc
	res  1, [hl]
	res  6, [hl]
	jp   L025323
L025317:;J
	mMvC_ValFrameEnd L025323
	call L003CB3
	jp   L025326
L025323:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L025326:;J
	ret
L025327:;I
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded L025495
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
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
	mMvC_ValFrameEnd L02541B
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
	mMvC_ValFrameEnd L025424
	ld   hl, $0013
	add  hl, de
	ld   [hl], $04
	jp   L025424
L0253DA:;J
	call Play_Pl_DoGroundScreenShake
	mMvC_ValFrameEnd L025492
	mMvC_SetAnimSpeed ANIMSPEED_NONE
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
	call OBJLstS_ApplyGravityVAndMoveHV
	jp   nc, L025492
	mMvC_SetDropFrame $10, $0B
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
	mMvC_ChkGravityHV $0060, L025492
	mMvC_SetDropFrame $18, $05
	jp   L025495
L025486:;J
	mMvC_ValFrameEnd L025492
	call L003CB3
	jp   L025495
L025492:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L025495:;J
	ret
L025496:;I
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded L0254EF
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
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
	mMvC_ValFrameEnd L0254C5
	mMvC_SetAnimSpeed ANIMSPEED_NONE
	jp   L0254C5
L0254C2:;J
	jp   L0254C5
L0254C5:;J
	mMvC_ChkGravityHV $0060, L0254EC
	mMvC_SetDropFrame $08, $05
	ld   hl, $0023
	add  hl, bc
	res  1, [hl]
	res  6, [hl]
	jp   L0254EF
L0254E0:;J
	mMvC_ValFrameEnd L0254EC
	call L003CB3
	jp   L0254EF
L0254EC:;J
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
L0254EF:;J
	ret
L0254F0:;I
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded L025576
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
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
	mMvC_ValFrameEnd L025555
	mMvC_SetAnimSpeed ANIMSPEED_NONE
	jp   L025555
L02552D:;J
	mMvC_NextFrameOnGtYSpeed $F9, $FF
	jp   L025555
L025537:;J
	mMvC_NextFrameOnGtYSpeed $FB, $FF
	jp   L025555
L025541:;J
	mMvC_NextFrameOnGtYSpeed $FF, $FF
	jp   L025555
L02554B:;J
	mMvC_NextFrameOnGtYSpeed $01, $FF
	jp   L025555
L025555:;J
	mMvC_ChkGravityHV $0060, L025573
	mMvC_SetLandFrame $18, $00
	jp   L025576
L025568:;J
	mMvC_ValFrameEnd L025573
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
	mMvC_ValLoaded L02561B
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
	mMvC_DoFrictionH $0040
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
	mMvC_ValLoaded L02564F
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L025637
	cp   $04
	jp   z, L025643
L025637:;J
	mMvC_ValFrameEnd L025650
	mMvC_SetAnimSpeed ANIMSPEED_NONE
	jp   L025650
L025643:;J
	mMvC_ValFrameEnd L025650
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
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	bit  PF0B_CPU, [hl]
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
	ld   a, [wPlayPlThrowRot_Unk_AlwaysSync]
	or   a
	jp   z, L0257D4
	call L024AC1
	ld   a, [wPlayPlThrowRotMoveH]
	ld   h, a
	ld   l, $00
	call Play_OBJLstS_MoveH_ByOtherXFlipL
	ld   a, [wPlayPlThrowRotMoveV]
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
	
; =============== MoveC_MrKarate_KoOuKen ===============
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
		mMvC_PlaySound SCT_15
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
		mMvC_PlaySound SCT_ATTACKG
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
		mMvC_SetDamageNext $04, HITANIM_HIT1_MID, PF3_BIT4
		jp   .moveH_m40
; --------------- frame #2 ---------------
.obj2:
	mMvC_ValFrameEnd .moveH_m40
		mMvC_SetDamageNext $04, HITANIM_DROP_MD, PF3_BIT4
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
		mMvC_PlaySound SCT_ATTACKG
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
	mMvC_SetDamageNext $08, HITANIM_DROP_MD, PF3_SHAKELONG
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
	
; =============== MoveC_MrKarate_RyuKoRanbuS ===============
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
		mMvC_PlaySound SCT_ATTACKG
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
.obj1_chkGuard_noGuard:
	; Otherwise, continue to #2
	mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_0A, PF3_BIT4
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
; Alongside .objEven is used to alternate between hit animations constantly.
.objOdd:
	call OBJLstS_ApplyXSpeed
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_0A, PF3_BIT4
		jp   .chkOtherEscape
; --------------- frame #2 ---------------
; Initial frame before the odd/even switching.
; This sets the initial jump speed and doesn't check for block yet.
.obj2:
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_09, PF3_BIT4
		mMvC_SetSpeedH $0080
		jp   .anim
; --------------- frames #4,6,8,A,... ---------------
; Generic damage - even frames.
.objEven:
	call OBJLstS_ApplyXSpeed
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_09, PF3_BIT4
; --------------- common escape check ---------------
; Done at the start of about half of the frames.
	.chkOtherEscape:
		;
		; [TCRF] If the opponent somehow isn't in one of the hit animations 
		;        this move sets, hop back instead of continuing.
		;        This should never happen.
		;
		ld   hl, iPlInfo_HitAnimIdOther
		add  hl, bc
		ld   a, [hl]
		cp   HITANIM_HIT_SPEC_09	; A == HITANIM_HIT_SPEC_09?
		jp   z, .anim				; If so, skip
		cp   HITANIM_HIT_SPEC_0A	; A == HITANIM_HIT_SPEC_0A?
		jp   z, .anim				; If so, skip
		; Otherwise, transition to hop
		ld   a, MOVE_SHARED_HOP_B
		call Pl_Unk_SetNewMoveAndAnim_StopSpeed
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
		mMvC_SetDamageNext $06, HITANIM_DROP_MD, PF3_BIT4
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
		mMvC_PlaySound SCT_ATTACKG
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
.obj1_chkGuard_noGuard:
	; Otherwise, continue to #2
	mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_0A, PF3_BIT4
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
; Alongside .objEven is used to alternate between hit animations constantly.
.objOdd:
	call OBJLstS_ApplyXSpeed
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_0A, PF3_BIT4
		jp   .chkOtherEscape
; --------------- frame #2 ---------------
; Initial frame before the odd/even switching.
; This sets the initial jump speed and doesn't check for block yet.
.obj2:
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_09, PF3_BIT4
		mMvC_SetSpeedH $0080
		jp   .anim
; --------------- frames #4,6,8,A,... ---------------
; Generic damage - even frames.
.objEven:
	call OBJLstS_ApplyXSpeed
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_09, PF3_BIT4
; --------------- common escape check ---------------
; Done at the start of about half of the frames.
	.chkOtherEscape:
		;
		; [TCRF] If the opponent somehow isn't in one of the hit animations 
		;        this move sets, hop back instead of continuing.
		;        This should never happen.
		;
		ld   hl, iPlInfo_HitAnimIdOther
		add  hl, bc
		ld   a, [hl]
		cp   HITANIM_HIT_SPEC_09	; A == HITANIM_HIT_SPEC_09?
		jp   z, .anim				; If so, skip
		cp   HITANIM_HIT_SPEC_0A	; A == HITANIM_HIT_SPEC_0A?
		jp   z, .anim				; If so, skip
		; Otherwise, transition to hop
		ld   a, MOVE_SHARED_HOP_B
		call Pl_Unk_SetNewMoveAndAnim_StopSpeed
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
		mMvC_SetDamageNext $02, HITANIM_DROP_MD, PF3_BIT4
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
		mMvC_PlaySound SCT_15
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
		mMvC_PlaySound SCT_ATTACKG
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
		mMvC_SetDamageNext $04, HITANIM_HIT1_MID, PF3_BIT4
		mMvC_PlaySound SCT_ATTACKG
		jp   .doGravity
; --------------- frame #3 ---------------	
.obj3:
	jp   .doGravity
; --------------- frame #4 ---------------	
.obj4:
	mMvC_ValFrameEnd .doGravity
		mMvC_SetDamageNext $04, HITANIM_HIT0_MID, PF3_BIT4
		mMvC_PlaySound SCT_ATTACKG
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
		mMvC_PlaySound SCT_ATTACKG
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
	bit  PF1B_GUARD, [hl]			; Is the opponent blocking?
	jp   z, .obj1_cont_doGravity	; If not, skip
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
		mMvC_PlaySound SND_ID_28
		mMvIn_ChkLHE .obj1_setHitH, .obj1_setHitE
	.obj1_setHitL: ; Light
		mMvC_SetDamageNext $06, HITANIM_DROP_MD, PF3_SHAKELONG
		jp   .anim
	.obj1_setHitH: ; Heavy
		mMvC_SetDamageNext $06, HITANIM_DROP_MD, PF3_SHAKELONG
		jp   .anim
	.obj1_setHitE: ; [POI] Hidden Heavy
		mMvC_SetDamageNext $06, HITANIM_DROP_MD, PF3_SHAKELONG|PF3_BIT4
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
; - ???
;
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
		mMvC_PlaySound SND_ID_28
		mMvC_SetDamageNext $02, HITANIM_DROP_MD, PF3_BIT4
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
	mMvC_SetDamage $02, HITANIM_DROP_MD, PF3_BIT4
	jp   .doGravity
	
; --------------- frames #2-3 ---------------
; Attack frames.	
.obj2:
	mMvC_SetDamage $02, HITANIM_DROP_MD, PF3_BIT4
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
	mMvC_SetDamage $02, HITANIM_DROP_MD, PF3_BIT4
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
; - ???
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
		mMvC_SetDamageNext $04, HITANIM_HIT0_MID, PF3_BIT4
		mMvC_PlaySound SCT_HEAVY
		jp   .anim
; --------------- frame #3 ---------------	
.obj3:
	mMvC_ValFrameStart .obj3_cont
		mMvC_SetMoveH $0200
.obj3_cont:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $04, HITANIM_HIT1_MID, PF3_BIT4
		mMvC_PlaySound SCT_HEAVY
		jp   .anim
; --------------- frame #5 ---------------	
.obj5:
	mMvC_ValFrameStart .obj5_cont
		mMvC_SetMoveH $0600
.obj5_cont:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $04, HITANIM_DROP_MD, PF3_SHAKELONG|PF3_BIT4
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
		mMvC_PlaySound SCT_ATTACKG
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
.obj1_chkGuard_noGuard:
	; Otherwise, continue to #2
	mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_0A, PF3_BIT4
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
; Alongside .objEven is used to alternate between hit animations constantly.
.objOdd:
	call OBJLstS_ApplyXSpeed
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_0A, PF3_BIT4
		jp   .chkOtherEscape
; --------------- frame #2 ---------------
; Initial frame before the odd/even switching.
; This sets the initial jump speed and doesn't check for block yet.
.obj2:
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_09, PF3_BIT4
		mMvC_SetSpeedH $0080
		jp   .anim
; --------------- frames #4,6,8,A,... ---------------
; Generic damage - even frames.
.objEven:
	call OBJLstS_ApplyXSpeed
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_09, PF3_BIT4
; --------------- common escape check ---------------
; Done at the start of about half of the frames.
	.chkOtherEscape:
		;
		; [TCRF] If the opponent somehow isn't in one of the hit animations 
		;        this move sets, hop back instead of continuing.
		;        This should never happen.
		;
		ld   hl, iPlInfo_HitAnimIdOther
		add  hl, bc
		ld   a, [hl]
		cp   HITANIM_HIT_SPEC_09	; A == HITANIM_HIT_SPEC_09?
		jp   z, .anim				; If so, skip
		cp   HITANIM_HIT_SPEC_0A	; A == HITANIM_HIT_SPEC_0A?
		jp   z, .anim				; If so, skip
		; Otherwise, transition to hop
		ld   a, MOVE_SHARED_HOP_B
		call Pl_Unk_SetNewMoveAndAnim_StopSpeed
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
		mMvC_SetDamageNext $06, HITANIM_DROP_MD, PF3_BIT4
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
		mMvC_PlaySound SCT_ATTACKG
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
.obj1_chkGuard_noGuard:
	; Otherwise, continue to #2
	mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_0A, PF3_BIT4
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
; Alongside .objEven is used to alternate between hit animations constantly.
.objOdd:
	call OBJLstS_ApplyXSpeed
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_0A, PF3_BIT4
		jp   .chkOtherEscape
; --------------- frame #2 ---------------
; Initial frame before the odd/even switching.
; This sets the initial jump speed and doesn't check for block yet.
.obj2:
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_09, PF3_BIT4
		mMvC_SetSpeedH $0080
		jp   .anim
; --------------- frames #4,6,8,A,... ---------------
; Generic damage - even frames.
.objEven:
	call OBJLstS_ApplyXSpeed
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_09, PF3_BIT4
; --------------- common escape check ---------------
; Done at the start of about half of the frames.
	.chkOtherEscape:
		;
		; [TCRF] If the opponent somehow isn't in one of the hit animations 
		;        this move sets, hop back instead of continuing.
		;        This should never happen.
		;
		ld   hl, iPlInfo_HitAnimIdOther
		add  hl, bc
		ld   a, [hl]
		cp   HITANIM_HIT_SPEC_09	; A == HITANIM_HIT_SPEC_09?
		jp   z, .anim				; If so, skip
		cp   HITANIM_HIT_SPEC_0A	; A == HITANIM_HIT_SPEC_0A?
		jp   z, .anim				; If so, skip
		; Otherwise, transition to hop
		ld   a, MOVE_SHARED_HOP_B
		call Pl_Unk_SetNewMoveAndAnim_StopSpeed
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
		mMvC_SetDamageNext $02, HITANIM_DROP_MD, PF3_BIT4
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
	mMvIn_ValidateClose .chkDistance_far, $20
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
	mMvC_SetDamageNext $08, HITANIM_DROP_MD, PF3_SHAKELONG
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
		mMvC_SetDamageNext $02, HITANIM_DROP_MD, PF3_FLASH_B_SLOW|PF3_BIT4|PF3_SHAKEONCE
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
	mMvC_SetDamage $02, HITANIM_DROP_MD, PF3_FLASH_B_SLOW|PF3_BIT4|PF3_SHAKEONCE
	jp   .doGravity
; --------------- frame #5 ---------------	
.obj5:
	; [POI] Hidden heavy version hits again
	call MoveInputS_CheckMoveLHVer
	jp   c, .obj5_doDamageE	; Hidden heavy triggered? If so, jump
	jp   .obj5_cont			; Otherwise, skip it
.obj5_doDamageE:
	mMvC_SetDamage $02, HITANIM_DROP_MD, PF3_FLASH_B_SLOW|PF3_BIT4|PF3_SHAKEONCE
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
		mMvC_PlaySound SND_ID_28
		mMvC_ChkNotMaxPow .anim ; Jump to .anim if not at max power
			mMvC_SetDamageNext $08, HITANIM_DROP_MD, PF3_BIT4
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
			mMvC_SetDamageNext $08, HITANIM_DROP_MD, PF3_BIT4
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
		mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_09, PF3_FLASH_B_FAST|PF3_SHAKEONCE
		jp   .anim
; --------------- frame #1 ---------------
; Health restore loop.
.obj1:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_0A, PF3_FLASH_B_FAST|PF3_SHAKEONCE
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
	mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_09, PF3_FLASH_B_FAST|PF3_SHAKEONCE
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
		mMvC_SetDamageNext $14, HITANIM_DROP_MD, PF3_SHAKELONG|PF3_FLASH_B_SLOW
		jp   .anim
	.obj3_setDamageO:
		; As O.Leona, the projectile spawns a skull wall that actually deals continuous damage.
		
		; Prepare flags to copy
		mMvC_SetDamageNext $02, HITANIM_DROP_SPEC_AIR_0E, PF3_SHAKELONG|PF3_FLASH_B_SLOW
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
		mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_09, PF3_FLASH_B_FAST|PF3_SHAKEONCE
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
		mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_0A, PF3_FLASH_B_FAST|PF3_SHAKEONCE
		jp   .chkOtherEscape
; --------------- frame #5 ---------------
.obj5:
	call OBJLstS_ApplyXSpeed
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_09, PF3_FLASH_B_FAST|PF3_SHAKEONCE
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
		mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_09, PF3_FLASH_B_FAST|PF3_SHAKEONCE
		jp   .chkOtherEscape
	.obj6_noLoop:
		; Deal more damage for #7
		mMvC_SetDamageNext $0C, HITANIM_DROP_MD, PF3_SHAKELONG|PF3_FLASH_B_FAST
		; And enable manual control
		ld   hl, iOBJInfo_FrameTotal
		add  hl, de
		ld   [hl], ANIMSPEED_NONE
		jp   .anim
; --------------- frames #4-6 / common escape check ---------------
	.chkOtherEscape:
		;
		; [TCRF] If the opponent somehow isn't in one of the hit animations 
		;        this move sets, hop back instead of continuing.
		;        This should never happen.
		;
		ld   hl, iPlInfo_HitAnimIdOther
		add  hl, bc
		ld   a, [hl]
		cp   HITANIM_HIT_SPEC_09	; A == HITANIM_HIT_SPEC_09?
		jp   z, .anim				; If so, skip
		cp   HITANIM_HIT_SPEC_0A	; A == HITANIM_HIT_SPEC_0A?
		jp   z, .anim				; If so, skip
		; Otherwise, transition to hop
		ld   a, MOVE_SHARED_HOP_B
		call Pl_Unk_SetNewMoveAndAnim_StopSpeed
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
	mMvIn_ValidateSuper .chkPunchNoSuper
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
	jp   MoveInputReader_MrKarate_SetMove
; =============== MoveInit_MrKarate_KyokukenRyuRenbuKen ===============
MoveInit_MrKarate_KyokukenRyuRenbuKen:
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_ValidateClose MoveInputReader_MrKarate_NoMove
	mMvIn_GetLH MOVE_MRKARATE_KYOKUKEN_RYU_RENBU_KEN_L, MOVE_MRKARATE_KYOKUKEN_RYU_RENBU_KEN_H
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
	mMvC_SetDamage $01, HITANIM_DROP_MD, PF3_BIT4|PF3_SHAKEONCE
	mMvC_ValFrameEnd .anim
		mMvC_PlaySound SCT_15
		jp   .anim
; --------------- [TCRF] unused frame #2 ---------------
; This should have been assigned to #2 to make the recovery frame last more, but it isn't.
; Intentional quick change or bug?
.unused_obj2:
	mMvC_SetDamage $01, HITANIM_DROP_MD, PF3_BIT4
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
		mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_09, $00
		
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
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_0A, PF3_BIT4
		jp   .anim
; --------------- frame #4 ---------------
; Damage loop.
; Alternates between HITANIM_HIT_SPEC_09 and HITANIM_HIT_SPEC_0A to view different frames.
.obj4:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_09, PF3_BIT4
		jp   .anim
; --------------- frame #5 ---------------
; Damage loop.
.obj5:
	mMvC_ValFrameEnd .anim
	; Loop to #3 if the counter didn't expire yet.
	ld   hl, iPlInfo_MrKarate_ShouranKyaku_LoopCount
	add  hl, bc
	dec  [hl]
	jp   z, .obj5_noLoop
	mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_09, PF3_BIT4
	ld   hl, iOBJInfo_OBJLstPtrTblOffset
	add  hl, de
	ld   [hl], $02*OBJLSTPTR_ENTRYSIZE	; offset by -1
	jp   .anim
.obj5_noLoop:
	; If it expired, hyper jump back
	ld   a, MOVE_SHARED_HIT_86
	call Pl_Unk_SetNewMoveAndAnim_StopSpeed
	mMvC_SetSpeedH -$0300
	mMvC_SetSpeedV -$0500
	jp   .ret
; --------------- frame #6 ---------------
; Recovery, only if the move didn't hit/got blocked.
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
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
		mMvC_PlaySound SCT_ATTACKG
		
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
		mMvC_SetDamageNext $08, HITANIM_DROP_MD, PF3_SHAKELONG|PF3_BIT4
		jp   .doGravity
; --------------- frame #4 ---------------
.obj4:
	mMvC_ValFrameEnd .doGravity
		mMvC_SetAnimSpeed ANIMSPEED_NONE
		mMvC_SetDamageNext $08, HITANIM_DROP_SPEC_0C, PF3_SHAKELONG|PF3_BIT4
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
MoveC_MrKarate_Zenretsuken:;I
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
	mMvC_SetDamage $01, HITANIM_HIT_SPEC_09, PF3_BIT4|PF3_SHAKEONCE
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed ANIMSPEED_INSTANT
		mMvC_PlaySound SND_ID_28
		ld   hl, iPlInfo_MrKarate_Zenretsuken_LoopCount
		add  hl, bc
		ld   [hl], $04
		jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_SetDamage $01, HITANIM_HIT_SPEC_0A, PF3_BIT4|PF3_SHAKEONCE
	jp   .anim
; --------------- frame #2 ---------------
.obj2:
	mMvC_SetDamage $01, HITANIM_HIT_SPEC_09, PF3_BIT4|PF3_SHAKEONCE
	mMvC_ValFrameEnd .anim
		mMvC_PlaySound SND_ID_28
		
		; Loop to #1 until the timer elapses
		ld   hl, iPlInfo_MrKarate_Zenretsuken_LoopCount
		add  hl, bc
		dec  [hl]
		jp   z, .obj2_noLoop
	.obj2_loop:
		mMvC_SetDamage $01, HITANIM_HIT_SPEC_09, PF3_BIT4
		ld   hl, iOBJInfo_OBJLstPtrTblOffset
		add  hl, de
		ld   [hl], $00*OBJLSTPTR_ENTRYSIZE ; offset by -1
		jp   .anim
	.obj2_noLoop:
		mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_0A, PF3_BIT4
		jp   .anim
; --------------- frame #3 ---------------
.obj3:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_09, PF3_BIT4
		jp   .anim
; --------------- frame #4 ---------------
.obj4:
	mMvC_ValFrameEnd .anim
		mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_0A, PF3_BIT4
		jp   .anim
; --------------- frame #5 ---------------
.obj5:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $1E
		mMvC_PlaySound SND_ID_28
		mMvC_SetDamageNext $01, HITANIM_DROP_MD, PF3_SHAKELONG|PF3_BIT4
		jp   .anim
; --------------- frame #6 ---------------
.obj6:
	mMvC_ValFrameEnd .anim
		mMvC_SetAnimSpeed $08
		jp   .anim
; --------------- frame #7 ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
		call Play_Pl_EndMove
		jr   .ret
; --------------- common ---------------
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
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
		mMvC_PlaySound SCT_ATTACKG
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
.obj1_chkGuard_noGuard:
	; Otherwise, continue to #2
	mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_0A, PF3_BIT4
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
; Alongside .objEven is used to alternate between hit animations constantly.
.objOdd:
	call OBJLstS_ApplyXSpeed
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_0A, PF3_BIT4
		jp   .chkOtherEscape
; --------------- frame #2 ---------------
; Initial frame before the odd/even switching.
; This sets the initial jump speed and doesn't check for block yet.
.obj2:
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_09, PF3_BIT4
		mMvC_SetSpeedH $0080
		jp   .anim
; --------------- frames #4,6,8,A,... ---------------
; Generic damage - even frames.
.objEven:
	call OBJLstS_ApplyXSpeed
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_09, PF3_BIT4
; --------------- common escape check ---------------
; Done at the start of about half of the frames.
	.chkOtherEscape:
		;
		; [TCRF] If the opponent somehow isn't in one of the hit animations 
		;        this move sets, hop back instead of continuing.
		;        This should never happen.
		;
		ld   hl, iPlInfo_HitAnimIdOther
		add  hl, bc
		ld   a, [hl]
		cp   HITANIM_HIT_SPEC_09	; A == HITANIM_HIT_SPEC_09?
		jp   z, .anim				; If so, skip
		cp   HITANIM_HIT_SPEC_0A	; A == HITANIM_HIT_SPEC_0A?
		jp   z, .anim				; If so, skip
		; Otherwise, transition to hop
		ld   a, MOVE_SHARED_HOP_B
		call Pl_Unk_SetNewMoveAndAnim_StopSpeed
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
		mMvC_SetDamageNext $06, HITANIM_DROP_MD, PF3_BIT4
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
	
; =============== MoveC_MrKarate_Unused_RyukoRanbuD ===============
; [TCRF] Unused desperation version of Mr.Karate's Ryuko Ranbu (MOVE_MRKARATE_RYUKO_RANBU_UNUSED_D).
; Almost identical to MoveC_Ryo_RyuKoRanbuD.
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
		mMvC_PlaySound SCT_ATTACKG
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
.obj1_chkGuard_noGuard:
	; Otherwise, continue to #2
	mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_0A, PF3_BIT4
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
; Alongside .objEven is used to alternate between hit animations constantly.
.objOdd:
	call OBJLstS_ApplyXSpeed
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_0A, PF3_BIT4
		jp   .chkOtherEscape
; --------------- frame #2 ---------------
; Initial frame before the odd/even switching.
; This sets the initial jump speed and doesn't check for block yet.
.obj2:
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_09, PF3_BIT4
		mMvC_SetSpeedH $0080
		jp   .anim
; --------------- frames #4,6,8,A,... ---------------
; Generic damage - even frames.
.objEven:
	call OBJLstS_ApplyXSpeed
	mMvC_ValFrameStart .anim
		mMvC_SetDamageNext $01, HITANIM_HIT_SPEC_09, PF3_BIT4
; --------------- common escape check ---------------
; Done at the start of about half of the frames.
	.chkOtherEscape:
		;
		; [TCRF] If the opponent somehow isn't in one of the hit animations 
		;        this move sets, hop back instead of continuing.
		;        This should never happen.
		;
		ld   hl, iPlInfo_HitAnimIdOther
		add  hl, bc
		ld   a, [hl]
		cp   HITANIM_HIT_SPEC_09	; A == HITANIM_HIT_SPEC_09?
		jp   z, .anim				; If so, skip
		cp   HITANIM_HIT_SPEC_0A	; A == HITANIM_HIT_SPEC_0A?
		jp   z, .anim				; If so, skip
		; Otherwise, transition to hop
		ld   a, MOVE_SHARED_HOP_B
		call Pl_Unk_SetNewMoveAndAnim_StopSpeed
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
		mMvC_SetDamageNext $02, HITANIM_DROP_MD, PF3_BIT4
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
	mMvC_SetDamageNext $06, HITANIM_DROP_MD, PF3_SHAKELONG ; 6 lines of damage on hit, make opponent drop on ground
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
	mMvC_SetDamage $06, HITANIM_THROW_ROTU, PF3_SHAKELONG ; Damage ignored in this hitanim
	mMvC_MoveThrowOp -$08, $00	; Move left 8px
.rotU_anim:
	jp   .anim
; --------------- frame #1 ---------------
; Set L rotation frame to opponent the first time we get here.
.rotL:
	mMvC_ValFrameStart .rotL_anim
	mMvC_SetDamage $06, HITANIM_THROW_ROTL, PF3_SHAKELONG ; Damage ignored in this hitanim
	mMvC_MoveThrowOp +$08, -$08	; Move right 8px (reset), up 8px
.rotL_anim:
	jp   .anim
; --------------- frame #2 ---------------
; Deal damage the first time we get here.
.hit:
	mMvC_ValFrameStart .obj2_anim
	mMvC_SetDamage $06, HITANIM_DROP_SPEC_0C, PF3_SHAKELONG
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
	
	mMvC_SetDamageNext $06, HITANIM_DROP_MD, PF3_SHAKELONG
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
	mMvC_SetDamage $06, HITANIM_THROW_ROTL, PF3_SHAKELONG
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
	ld   a, SCT_11
	call HomeCall_Sound_ReqPlayExId
	
	; Start neutral jump
	mMvC_SetSpeedH $0000	; No h movement
	mMvC_SetSpeedV -$0600	; 6px/frame up
	
	; Set new rotation frame
	mMvC_SetDamage $06, HITANIM_THROW_ROTR, PF3_SHAKELONG
	; Move opponent left 2px, up 10px
	mMvC_MoveThrowOp -$02, -$10

	; Allow the move code for getting damaged to set this once.
	ld   a, $01
	ld   [wPlayPlThrowRot_Unk_AlwaysSync], a
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
	mMvC_SetDamage $06, HITANIM_THROW_ROTR, PF3_SHAKELONG
	; Move opponent left 2px
	mMvC_MoveThrowOp -$02, +$00

	jp   .anim
; --------------- frame #3 ---------------
.obj3:
	; The first time we get here...
	mMvC_ValFrameStart .anim
	; Set new rotation frame
	mMvC_SetDamage $06, HITANIM_THROW_ROTR, PF3_SHAKELONG
	; Move opponent left 2px
	mMvC_MoveThrowOp -$02, +$00

	jp   .anim
; --------------- frame #4 ---------------
.obj4:
	; The first time we get here, damage the player
	mMvC_ValFrameStart .chkEnd
	mMvC_SetDamage $06, HITANIM_DROP_MD, PF3_SHAKELONG
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
	mMvC_SetDamage $06, HITANIM_THROW_ROTU, PF3_SHAKELONG
	mMvC_MoveThrowOp -$08, +$00
	jp   .anim
; --------------- frame #1 ---------------
.rotL:
	mMvC_ValFrameStart .anim
	mMvC_SetDamage $06, HITANIM_THROW_ROTL, PF3_SHAKELONG
	mMvC_MoveThrowOp +$01, -$10
	jp   .anim
; --------------- frame #2 ---------------
.setDamage:
	mMvC_ValFrameStart .anim
	mMvC_SetDamage $06, HITANIM_DROP_SPEC_0F, PF3_SHAKELONG
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
	mMvC_SetDamageNext $06, HITANIM_DROP_MD, PF3_SHAKELONG
	jp   .anim
; --------------- frame #2 ---------------
; When switching to #3, make Robert jump back.
.chkEnd:
	mMvC_ValFrameEnd .anim
	; Set a new move to do the jump.
	ld   a, MOVE_SHARED_HIT_86
	call Pl_Unk_SetNewMoveAndAnim_StopSpeed
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
	mMvC_SetDamage $06, HITANIM_THROW_ROTL, PF3_SHAKELONG
	mMvC_MoveThrowOp +$01, -$08
	jp   .anim
; --------------- frame #2 ---------------
.rotD:
	mMvC_ValFrameStart .anim
	mMvC_SetDamage $06, HITANIM_THROW_ROTD, PF3_SHAKELONG
	mMvC_MoveThrowOp -$02, -$08
	jp   .anim
; --------------- frame #3 ---------------
.rotR:
	mMvC_ValFrameStart .anim
	mMvC_SetDamage $06, HITANIM_THROW_ROTR, PF3_SHAKELONG
	mMvC_MoveThrowOp +$01, -$08
	jp   .anim
; --------------- frame #4 ---------------
.rotU:
	mMvC_ValFrameStart .anim
	mMvC_SetDamage $06, HITANIM_THROW_ROTU, PF3_SHAKELONG
	mMvC_MoveThrowOp -$02, -$08
	jp   .anim
; --------------- frame #5 ---------------
.setDamage:
	mMvC_ValFrameStart .anim
	mMvC_SetDamage $06, HITANIM_DROP_SPEC_0F, PF3_SHAKELONG
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
	mMvC_SetDamage $06, HITANIM_THROW_ROTL, PF3_SHAKELONG
	mMvC_MoveThrowOp -$08, -$08 ; 8px left, 8px up
	jp   .anim
; --------------- frame #1 ---------------
.obj1:
	; The first time we get here...
	mMvC_ValFrameStart .anim
	mMvC_SetDamage $06, HITANIM_THROW_ROTD, PF3_SHAKELONG
	mMvC_MoveThrowOp -$08, -$08 ; 8px left, 8px up
	jp   .anim
; --------------- frame #2 ---------------
.obj2:
	; The first time we get here...
	mMvC_ValFrameStart .obj2_setManCtrl
	
	; Throw opponent forward, diagonally down + damage for 6 lines
	mMvC_SetDamage $06, HITANIM_DROP_SPEC_0C, PF3_SHAKELONG
	
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
	mMvC_SetDamage $06, HITANIM_THROW_ROTU, PF3_SHAKELONG
	; Move thrown player left 8px
	mMvC_MoveThrowOp -$08, +$00
	jp   .anim
; --------------- frame #1 ---------------
.obj1:
	mMvC_ValFrameStart .anim
	; Move player left 8px
	mMvC_SetMoveH -$0800
	; Set rotation frame again to apply Play_Pl_MoveRotThrown
	mMvC_SetDamage $06, HITANIM_THROW_ROTU, PF3_SHAKELONG
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
	mMvC_SetDamage $06, HITANIM_THROW_ROTU, PF3_SHAKELONG
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
	mMvC_SetDamage $06, HITANIM_THROW_ROTU, PF3_SHAKELONG
	; Move opponent right $10px (reset)
	mMvC_MoveThrowOp +$10, +$00
	jp   .anim
; --------------- frame #4 ---------------
.setDamage:
	mMvC_ValFrameStart .anim
	mMvC_SetMoveH $0000 ; [POI] Useless
	mMvC_SetDamage $06, HITANIM_DROP_SPEC_0F, PF3_SHAKELONG
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
	mMvC_SetDamage $06, HITANIM_THROW_ROTR, PF3_SHAKELONG
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
	ld   a, SCT_11
	call HomeCall_Sound_ReqPlayExId
	
	; (nothing)
	mMvC_SetSpeedH $0000
	; Move player 1px up
	mMvC_SetSpeedV -$0100
	
	; Move opponent left 2px, up 1px
	mMvC_SetDamage $06, HITANIM_THROW_ROTR, PF3_SHAKELONG ; Same as before, to enable Play_Pl_MoveRotThrown
	mMvC_MoveThrowOp -$02, -$01
	
	; Enable move to use moverot values for ???
	ld   a, $01
	ld   [wPlayPlThrowRot_Unk_AlwaysSync], a
.obj1_move:
	jp   .uhok
.uhok:
	; Move down $00.60px/frame until we touch the ground.
	; Switch to the landing frame when that happens.
	mMvC_ChkGravityHV $0060, .anim						; If not, jump
	
	; Once the ground is touched, switch to #2
	mMvC_SetLandFrame $02*OBJLSTPTR_ENTRYSIZE, $02
	
	; Move opponent left 2px, up 1px
	mMvC_SetDamage $06, HITANIM_THROW_ROTR, PF3_SHAKELONG ; Same as before, to enable Play_Pl_MoveRotThrown
	mMvC_MoveThrowOp -$02, -$01
	
	;--
	; Not necessary, already done by Play_Pl_MoveRotThrown
	ld   a, $00
	ld   [wPlayPlThrowRot_Unk_AlwaysSync], a
	;--
	jp   .ret
; --------------- frame #2 ---------------
.obj2:
	; The first time we get here, make the throw deal damage
	mMvC_ValFrameStart .chkEnd
	mMvC_SetDamage $06, HITANIM_DROP_SPEC_0C, PF3_SHAKELONG
.chkEnd:
	; Start backjump when switching to #3.
	
	; [POI] copy/pasting won here too
IF FIX_BUGS == 1
	mMvC_ValFrameEnd .anim
ELSE
	mMvC_ValFrameEnd MoveC_Mai_ThrowG.anim
ENDC
	ld   a, MOVE_SHARED_HIT_86
	call Pl_Unk_SetNewMoveAndAnim_StopSpeed
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
	mMvC_SetDamageNext $06, HITANIM_DROP_MD, PF3_SHAKELONG
	jp   .anim
; --------------- frame #1 ---------------
.obj1:
	jp   .anim ; huh ok
; --------------- frame #2 ---------------
; Start backjump when switching to #3.
.chkEnd:
	mMvC_ValFrameEnd .anim
	ld   a, MOVE_SHARED_HIT_86
	call Pl_Unk_SetNewMoveAndAnim_StopSpeed
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
	
; =============== END OF BANK ===============
; Junk area below.
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
