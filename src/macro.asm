
; =============== mWaitHBlankEnd ===============
; Waits for the current HBlank to finish, if we're in one.
mWaitForHBlankEnd: MACRO
.waitHBlankEnd_\@:
	ldh  a, [rSTAT]
	and  a, $03
	jp   z, .waitHBlankEnd_\@
ENDM
; =============== mWaitHBlank ===============
; Waits for the HBlank period.
mWaitForHBlank: MACRO
.waitHBlank_\@:
	ldh  a, [rSTAT]
	and  a, $03
	jp   nz, .waitHBlank_\@
ENDM
; =============== mWaitForNewHBlank ===============
; Waits for the start of a new HBlank period.
mWaitForNewHBlank: MACRO
	; If we're in HBlank already, wait for it to finish
	mWaitForHBlankEnd
	; Then wait for the HBlank proper
	mWaitForHBlank
ENDM

; =============== mWaitForVBlankOrHBlank ===============
; Waits for the VBlank or HBlank period.
mWaitForVBlankOrHBlank: MACRO
.waitVBlankOrHBlank_\@:
	ldh  a, [rSTAT]
	bit  1, a
	jp   nz, .waitVBlankOrHBlank_\@
ENDM

; =============== mWaitForVBlankOrHBlankFast ===============
; Waits for the VBlank or HBlank period.
mWaitForVBlankOrHBlankFast: MACRO
.waitVBlankOrHBlank_\@:
	ldh  a, [rSTAT]
	bit  1, a
	jr   nz, .waitVBlankOrHBlank_\@
ENDM

; =============== mBinDef ===============
; Generates an include for a binary *Def structure, where the data 
; is prepended with its length in bytes.
; IN
; - \1: Path to file to INCBIN
mBinDef: MACRO
	db (.end-.bin)	; Size of data
.bin:
	INCBIN \1		; Data itself
.end:
ENDM

; =============== mBinDef ===============
; Generates an include for junk padding data.
; IN
; - \1: Filename without extension
mIncJunk: MACRO

IF LABEL_JUNK == 1
Padding_\@:
ENDC
	IF SKIP_JUNK == 0
		IF REV_VER_2 == 0
			INCBIN STRCAT("padding/", \1, ".bin")
		ELSE
			INCBIN STRCAT("padding_en/", \1, ".bin")
		ENDC
	ENDC
ENDM

; =============== dp ===============
; Shorthand for far pointers in standard order.
dp: MACRO
	db BANK(\1)
	dw \1
ENDM
; =============== dpr ===============
; Shorthand for far pointers in reverse order.
dpr: MACRO
	dw \1
	db BANK(\1)
ENDM

; =============== pkg ===============
; Shorthand for the header of a (set of) SGB Packets
; IN
; - 1: Packet ID
; - 2: Number of packets
pkg: MACRO
	db (\1 * 8) | \2
ENDM

; =============== ads ===============
; Data set byte 2 for a SGB_PACKET_ATTR_BLK command.
; IN
; - 1: Palette ID (inside)
; - 2: Palette ID (border)
; - 3: Palette ID (outside)
ads: MACRO
	db (\1)|(\1 << 2)|(\1 << 4)
ENDM

; =============== mkhl ===============
; Generates a generic HL parameter.
; IN
; - 1: H
; - 2: L
; OUT
; - CHL: Calculated result
mkhl: MACRO
CHL = (LOW(\1) << 8)|LOW(\2)
ENDM

; =============== Special move list definition macros ===============
; For MoveInputReader_*
;
; However, some are also used by the move code itself.

; =============== mMvIn_Validate ===============
; Performs initial validation at the start of an input reader,
; and determines if we should go to the air or ground list.
; IN
; - 1: Char key
mMvIn_Validate: MACRO
	call MoveInputS_CanStartSpecialMove	; Can we start a new special/super?
	jp   c, MoveInputReader_\<1>_NoMove	; If not, return
	jp   z, .chkGround					; Are we on the ground? If so, jump
ENDM									; Otherwise, assume air


; =============== mMvIn_ChkEasy ===============
; Checks for move shortcuts (requires the easy moves cheat).
; IN
; - 1: Move key for SELECT + B
; - 2: Move key for SELECT + A
mMvIn_ChkEasy: MACRO
	call MoveInputS_CheckEasyMoveKeys
	jp   c, \1 ; SELECT + B pressed? If so, jump
	jp   z, \2 ; SELECT + A pressed? If so, jump
ENDM

; =============== mMvIn_ChkGA ===============
; Determines if the punch or kick move inputs should be checked.
; IN
; - 1: Char key
; - 2: Label to punch list
; - 3: Label to kick list
mMvIn_ChkGA: MACRO
	; Determine the attack type/strength.
	; This narrows down the list of special moves to check.
	call MoveInputS_CheckGAType
	jp   nc, MoveInputReader_\<1>_NoMove	; Was an attack button pressed? If not, return
	jp   z, \2	; Was the punch button pressed? If so, jump
	jp   nz, \3	; Was the kick button pressed? If so, jump
	jp   MoveInputReader_\<1>_NoMove ; We never get here
ENDM

; =============== mMvIn_ValSuper ===============
; Guards against checking super move inputs if we can't start super moves.
; IN
; - 1: Label to skip the super move inputs
mMvIn_ValSuper: MACRO
	call MoveInputS_CanStartSuperMove	; Can we start a super?
	jp   c, \1							; If not, skip
ENDM

; =============== mMvIn_ValProjActive ===============
; Guards against starting moves that spawn projectiles if another
; projectile associated to the same player is still active.
; IN
; - 1: Char Key or Label to skip the input
mMvIn_ValProjActive: MACRO
	call MoveInputS_CanStartProjMove			; Can we start this move?
	IF DEF(MoveInputReader_\<1>_NoMove)
		jp   nz, MoveInputReader_\<1>_NoMove	; If not, skip
	ELSE
		jp   nz, \<1>							; If not, skip
	ENDC
ENDM

; =============== mMvIn_ValProjVisible ===============
; Guards against starting moves that spawn projectiles if another
; projectile associated to the same player is still *visible*.
; IN
; - 1: Char Key
mMvIn_ValProjVisible: MACRO
	; Seek to the status field of the projectile associated to this player.
	; This is always 2 slots after the one for the current player.
	ld   hl, (OBJINFO_SIZE * 2)+iOBJInfo_Status
	add  hl, de	
	; If the sprite mapping is visible, don't start the move
	bit  OSTB_VISIBLE, [hl]	
	jp   nz, MoveInputReader_\<1>_NoMove
ENDM

; =============== mMvIn_ValClose ===============
; Verifies that the move is performed close to the opponent.
; IN
; - 1: Label to skip the input
; - 2: [OPTIONAL] Player distance threshold. By default, it's $18
mMvIn_ValClose: MACRO
	; The move must be done within $18px of the other player
	ld   hl, iPlInfo_PlDistance
	add  hl, bc
	ld   a, [hl]
IF _NARG > 1
	cp   \2			; iPlInfo_PlDistance >= \2?
ELSE
	cp   $18		; iPlInfo_PlDistance >= $18?
ENDC
	jp   nc, \1		; If so, jump
	; If we got here, we can continue
ENDM

; =============== mMvIn_ValDipPowerup ===============
; Guards against checking move inputs if they require the powerup cheat
; IN
; - 1: Label to skip the move inputs
mMvIn_ValDipPowerup: MACRO
	ld   a, [wDipSwitch]
	bit  DIPB_POWERUP, a		; Is the cheat enabled?
	jp   z, \1					; If not, skip
ENDM

; =============== mMvIn_ValSkipWithChar ===============
; Prevents the move input from being checked when playing as the specified character.
; Used to prevent characters from starting moves exclusive to their alternate form,
; since both forms reuse the same MoveInputReader_* code (ie: Iori/O.Iori)
; IN
; - 1: Character ID that can't use the move
; - 1: Label to skip the move inputs
mMvIn_ValSkipWithChar: MACRO
	ld   hl, iPlInfo_CharId
	add  hl, bc
	ld   a, [hl]
	cp   \1		; Playing as this character?
	jp   z, \2	; If so, skip
ENDM

; =============== mMvIn_ValStartCmdThrow_StdColi ===============
; Verifies that the command throw grabbed the opponent successfully using standard throw range collision.
; This will take a few frames to complete.
; IN
; - 1: Char Key
mMvIn_ValStartCmdThrow_StdColi: MACRO
	; Throw validation / try to start it
	call MoveInputS_TryStartCommandThrow_StdColi	; Did the command throw grab the other player successfully?
	jp   nc, MoveInputReader_\<1>_NoMove			; If not, jump
	call Task_PassControlFar
	ld   a, PLAY_THROWACT_NEXT03					; Otherwise, the command throw is confirmed
	ld   [wPlayPlThrowActId], a
ENDM

; =============== mMvIn_ValStartCmdThrow_AllColi ===============
; Verifies that the command throw grabbed the opponent successfully using full-screen throw range collision.
; This will take a few frames to complete.
; IN
; - 1: Ptr to target if validation fails.
mMvIn_ValStartCmdThrow_AllColi: MACRO
	; Throw validation / try to start it
	call MoveInputS_TryStartCommandThrow_AllColi	; Did the command throw grab the other player successfully?
	jp   nc, \1										; If not, jump
	call Task_PassControlFar
	ld   a, PLAY_THROWACT_NEXT03					; Otherwise, the command throw is confirmed
	ld   [wPlayPlThrowActId], a
ENDM

; =============== mMvIn_JpIfStartCmdThrow_StdColi ===============
; Jumps to the specified location if the command throw grabbed the opponent successfully using standard throw range collision.
; IN
; - 1: Ptr to target
mMvIn_JpIfStartCmdThrow_StdColi: MACRO
	call MoveInputS_TryStartCommandThrow_StdColi	; Did we grab the opponent?
	jp   c, \1										; If so, jump
ENDM

; =============== mMvIn_ChkDir ===============
; Checks for a directional button-based move input.
; Almost every super move uses this.
; IN
; - 1: Ptr to MoveInput_*
; - 2: Ptr to MoveInit_* 
mMvIn_ChkDir: MACRO
	ld   hl, \1					; HL = Ptr to move input
	call MoveInputS_ChkInputDir	; Did we press it?
	jp   c, \2					; If so, jump
ENDM

; =============== mMvIn_ChkDirNot ===============
; Checks if we did *NOT* input the specified directional button-based move input.
; IN
; - 1: Ptr to MoveInput_*
; - 2: Label to skip to the next input
mMvIn_ChkDirNot: MACRO
	ld   hl, \1					; HL = Ptr to move input
	call MoveInputS_ChkInputDir	; Did we press it?
	jp   nc, \2					; If not, jump
ENDM

; =============== mMvIn_ChkDirStrict ===============
; Checks for a directional button-based move input that allows no input leeway.
; IN
; - 1: Ptr to MoveInput_*
; - 2: Ptr to MoveInit_* 
mMvIn_ChkDirStrict: MACRO
	ld   hl, \1							; HL = Ptr to move input
	call MoveInputS_ChkInputDirStrict	; Did we press it?
	jp   c, \2							; If so, jump
ENDM

; =============== mMvIn_ChkBtnStrict ===============
; Checks for a punch/kick button-based move input that allows no input leeway.
; IN
; - 1: Ptr to MoveInput_*
; - 2: Ptr to MoveInit_* 
mMvIn_ChkBtnStrict: MACRO
	ld   hl, \1							; HL = Ptr to move input
	call MoveInputS_ChkInputBtnStrict	; Did we press it?
	jp   c, \2							; If so, jump
ENDM

; =============== mMvIn_ChkL ===============
; Checks if the attack is a light.
; IN
; - 1: Ptr to code for the light version.
mMvIn_ChkL: MACRO
	call MoveInputS_CheckMoveLHVer
	jp   z, \1			; Is the light triggered? If so, jump
ENDM

; =============== mMvIn_ChkLH ===============
; Checks if the attack is a light or heavy.
; IN
; - 1: Ptr to code for the heavy version.
mMvIn_ChkLH: MACRO
	call MoveInputS_CheckMoveLHVer
	jp   nz, \1			; Is the heavy triggered? If so, jump
						; Otherwise, use the light
ENDM


; =============== mMvIn_GetLH ===============
; Gets a move ID depending on the attack being light or heavy.
; IN
; - 1: Move ID for Light
; - 2: Move ID for Heavy
; OUT
; - A: Move ID to use
mMvIn_GetLH: MACRO
	call MoveInputS_CheckMoveLHVer
	jr   nz, .heavy		; Heavy version? If so, jump
.light:
	ld   a, \1
	jp   .setMove
.heavy:
	ld   a, \2
.setMove:
ENDM

; =============== mMvIn_ChkLHE ===============
; Checks if the attack is a light, heavy, or hidden.
; IN
; - 1: Ptr to code for the heavy version.
; - 2: Ptr to code for the hidden version.
mMvIn_ChkLHE: MACRO
	call MoveInputS_CheckMoveLHVer
	jp   c, \2			; Is the the hidden heavy triggered? If so, jump
	jp   nz, \1			; Is the heavy triggered? If so, jump
						; Otherwise, use the light
ENDM

; =============== mMvIn_ChkE ===============
; Checks if the attack is a an hidden heavy.
; IN
; - 1: Ptr to code for the hidden version.
mMvIn_ChkE: MACRO
	call MoveInputS_CheckMoveLHVer
	jp   c, \1			; Is the the hidden heavy triggered? If so, jump
						; Otherwise, use the light/heavy
ENDM

; =============== mMvIn_ChkE ===============
; Checks if the attack is a not an hidden heavy.
; IN
; - 1: Ptr to code for the light/heavy version.
mMvIn_ChkNotE: MACRO
	call MoveInputS_CheckMoveLHVer
	jp   nc, \1			; Is the the hidden heavy triggered? If not, jump
ENDM

; =============== mMvIn_GetLHE ===============
; Gets a move ID depending on the attack being light, heavy, or hidden.
; IN
; - 1: Move ID for Light
; - 2: Move ID for Heavy
; - 3: Ptr to MoveInit_* code for the hidden version.
; OUT
; - A: Move ID to use (if not jumped to \3)
mMvIn_GetLHE: MACRO
	call MoveInputS_CheckMoveLHVer
	jr   c, \3			; Is the the hidden super triggered? If so, jump
	jr   nz, .heavy		; Is the heavy triggered? If so, jump
.light:					; Otherwise, use the light
	ld   a, \1
	jp   .setMove
.heavy:
	ld   a, \2
.setMove:
ENDM

; =============== mMvIn_GetSD ===============
; Gets a move ID depending on the attack being normal super or a desperation super.
; IN
; - 1: Move ID for Super
; - 2: Move ID for Desperation Super
; OUT
; - A: Move ID to use
mMvIn_GetSD: MACRO
	call MoveInputS_CheckSuperDesperation
	jp   c, .desperation
.normal:
	ld   a, \1
	jp   .setMove
.desperation:
	ld   a, \2
.setMove:
ENDM

; =============== mMvIn_GetSDE ===============
; Gets a move ID depending on the attack being normal super, a desperation super, or an hidden desperation.
; IN
; - 1: Move ID for Super
; - 2: Move ID for Desperation Super
; - 3: Move ID for Hidden Desperation Super
; OUT
; - A: Move ID to use
mMvIn_GetSDE: MACRO
	call MoveInputS_CheckSuperDesperation
	jp   nc, .normal		; Was a super desperation *NOT* triggered? If so, jump
	jp   nz, .desperation	; Was the hidden desperation *NOT* triggered? If so, jump
	jp   .hidden			; Otherwise, jump
.normal:
	ld   a, \1
	jp   .setMove
.desperation:
	ld   a, \2
	jp   .setMove
.hidden:
	ld   a, \3
.setMove:
ENDM

; =============== mMvIn_JpSD ===============
; Jumps to a MoveInit_* target depending on the attack being normal super or a desperation super.
; IN
; - 1: Ptr to MoveInit_* for Super
; - 2: Ptr to MoveInit_* for Desperation Super
; OUT
; - A: Move ID to use
mMvIn_JpSD: MACRO
	call MoveInputS_CheckSuperDesperation
	jp   c, \2	; Was a super desperation triggered? If so, jump
	jp   \1 	; Otherwise, jump to the normal version
ENDM

; =============== Move code macros ===============
; Only For MoveC_*
;
; For all of these:
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
;

; =============== mMvC_SetMoveH ===============
; Moves the player horizontally, relative to the 1P side (negative values move backwards).
; IN
; - 1: Horizontal movement (pixels + subpixels)
mMvC_SetMoveH: MACRO
	ld   hl, \1
	call Play_OBJLstS_MoveH_ByXFlipR
ENDM

; =============== mMvC_SetMoveV ===============
; Moves the player vertically.
; IN
; - 1: Vertical movement (pixels + subpixels)
mMvC_SetMoveV: MACRO
	ld   hl, \1
	call Play_OBJLstS_MoveV
ENDM

; =============== mMvC_SetSpeedH ===============
; Sets the horizontal movement speed for (usually) the current player,
; relative to the 1P side (negative values move backwards).
; If something else was set to DE, that OBJInfo will get its speed set.
; IN
; - 1: Speed value (pixels + subpixels), as px/frame
mMvC_SetSpeedH: MACRO
	ld   hl, \1
	call Play_OBJLstS_SetSpeedH_ByXFlipR
ENDM

; =============== mMvC_SetSpeedHInt ===============
; Sets the horizontal movement speed for (usually) the current player,
; relative to the internal flip flag being for the *2P* side (negative values move forwards).
; Used to move relative to the opponent's position, since the internal
; flip flag is always updated.
; IN
; - 1: Speed value (pixels + subpixels), as px/frame
mMvC_SetSpeedHInt: MACRO
	ld   hl, \1
	call Play_OBJLstS_SetSpeedH_ByXDirL
ENDM

; =============== mMvC_SetSpeedV ===============
; Sets the vertical movement speed for (usually) the current player.
; If something else was set to DE, that OBJInfo will get its speed set.
; IN
; - 1: Player speed (pixels + subpixels), as px/frame
mMvC_SetSpeedV: MACRO
	ld   hl, \1
	call Play_OBJLstS_SetSpeedV
ENDM

; =============== mMvC_SetAnimSpeed ===============
; Sets the animation speed.
; Generally done before the animation advances internally. 
; IN
; - 1: Animation speed
; - HL: Ptr to iOBJInfo_FrameLeft. Done automatically when calling mMvC_ValFrameEnd.
; OUT
; - HL: Ptr to iOBJInfo_FrameTotal
mMvC_SetAnimSpeed: MACRO
	inc  hl			; Seek to iOBJInfo_FrameTotal
	ld   [hl], \1	; Set new anim speed
ENDM

; =============== mMvC_NextFrameOnGtYSpeed ===============
; Advances the animation if the YSpeed is > than the specified threshold.
; Used when manual control is enabled, so \2 is generally ANIMSPEED_NONE to continue the manual control.
; IN
; - 1: Y Speed threshold
; - 2: Animation speed for next frame
; OUT
; - C flag: If set, the request was successful.
mMvC_NextFrameOnGtYSpeed: MACRO
	ld   a, \1
	ld   h, \2
	call OBJLstS_ReqAnimOnGtYSpeed
ENDM

; =============== mMvC_SetLandFrame ===============
; Sets the animation frame used when landing on the ground (typically the last one).
; IN
; - 1: Sprite mapping ID
; - 2: Animation speed (iOBJInfo_FrameTotal)
; OUT
; - Z flag: If set, the new animation frame wasn't set
mMvC_SetLandFrame: MACRO
	ld   a, \1
	ld   h, \2
	call Play_Pl_SetJumpLandAnimFrame
ENDM

; =============== mMvC_SetDropFrame ===============
; Sets the animation frame used when dropping on the ground (after getting hit).
; IN
; - 1: Sprite mapping ID
; - 2: Animation speed (iOBJInfo_FrameTotal)
; OUT
; - Z flag: If set, the new animation frame wasn't set
mMvC_SetDropFrame: MACRO
	ld   a, \1
	ld   h, \2
	call Play_Pl_SetDropAnimFrame
ENDM

; =============== mMvC_SetFrame ===============
; Sets a custom animation frame.
; Calling this also calls the animation routine, so the changes get applied.
; This means that, if the frame is set and the move code executes code depending
; on the visible frame, it's possible to skip calling the animation function for
; the rest of that frame.
; IN
; - 1: Sprite mapping ID
; - 2: Animation speed (iOBJInfo_FrameTotal)
; OUT
; - Z flag: If set, the new animation frame wasn't set
mMvC_SetFrame: MACRO
	ld   a, \1
	ld   h, \2
	call Play_Pl_SetAnimFrame
ENDM

; =============== mMvC_SetDamageNext ===============
; Sets the pending move damage values, which get applied when the graphics for the next frame are loaded.
; These take effect on the opponent side if it gets successfully hit (not blocked).
; IN
; - 1: Damage dealt (iPlInfo_MoveDamageValNext)
; - 2: Hit effect (iPlInfo_MoveDamageHitTypeIdNext)
; - 3: Hit flags (iPlInfo_MoveDamageFlags3Next)
mMvC_SetDamageNext: MACRO
	mkhl \1, \2
	ld   hl, CHL	
	ld   a, \3
	call Play_Pl_SetMoveDamageNext
ENDM

; =============== mMvC_SetDamage ===============
; Sets the current move damage values, which take effect immediately.
; Generally used the first time logic for an animation frame is executed, for consistency (OBJLstS_IsFrameNewLoad).
; These take effect on the opponent side if it gets successfully hit (not blocked).
; IN
; - 1: Damage dealt (iPlInfo_MoveDamageVal)
; - 2: Hit effect (iPlInfo_MoveDamageHitTypeId)
; - 3: Hit flags (iPlInfo_MoveDamageFlags3)
mMvC_SetDamage: MACRO
	mkhl \1, \2
	ld   hl, CHL	
	ld   a, \3
	call Play_Pl_SetMoveDamage
ENDM

; =============== mMvC_PlaySound ===============
; Plays a sound effect.
; IN
; - 1: Sound ID
mMvC_PlaySound: MACRO
	ld   a, \1
	call HomeCall_Sound_ReqPlayExId
ENDM

; =============== mMvC_MoveThrowOp ===============
; Moves the grabbed opponent relative to the current location.
; This is only applied if the the player is set in a rotation frame (mMvC_SetDamage with HITTYPE_THROW_ROT*)
; IN
; - 1: Horz. Movement (relative to the 1P side, negative values move backwards)
; - 2: Vert. Movement
mMvC_MoveThrowOp: MACRO
	mkhl \1, \2
	ld   hl, CHL
	call Play_Pl_MoveRotThrown
ENDM

; =============== mMvC_MoveThrowSync ===============
; Always syncs the relative position set in mMvC_MoveThrowOp to be applied every frame of the HITTYPE_THROW_ROT*.
; Must be used if the player moves during the grab portion of the throw.
mMvC_MoveThrowOpSync: MACRO
	ld   a, $01
	ld   [wPlayPlThrowRotSync], a
ENDM

; =============== mMvC_ChkTarget ===============
; Executes the specified code when the target animation frame is reached.
; IN
; - 1: Ptr to where to jump
; - A: Current OBJLst ID (either internal or visible)
mMvC_ChkTarget: MACRO
	ld   hl, iPlInfo_OBJLstPtrTblOffsetMoveEnd
	add  hl, bc		; HL = Ptr to target OBJLst ID
	cp   a, [hl]	; Do they match?
	jp   z, \1		; If so, jump
ENDM

; =============== mMvC_ChkTarget_jr ===============
; Executes the specified code when the target animation frame is reached.
; IN
; - 1: Ptr to where to jump
; - A: Current OBJLst ID (either internal or visible)
mMvC_ChkTarget_jr: MACRO
	ld   hl, iPlInfo_OBJLstPtrTblOffsetMoveEnd
	add  hl, bc		; HL = Ptr to target OBJLst ID
	cp   a, [hl]	; Do they match?
	jr   z, \1		; If so, jump
ENDM

; =============== mMvC_ChkGravityV ===============
; Handles gravity.
; The player is moved only vertically until the ground is reached.
; IN
; - 1: Gravity value
; - 2: Where to jump if we *touched* ground
mMvC_ChkGravityV: MACRO
	ld   hl, \1
	call OBJLstS_ApplyGravityVAndMoveV
	jp   c, \2
ENDM

; =============== mMvC_ChkGravityHV ===============
; Handles gravity.
; The player is moved both horizontally and vertically until the ground is reached.
; IN
; - 1: Gravity value
; - 2: Where to jump if we did *not* touch ground yet
mMvC_ChkGravityHV: MACRO
	ld   hl, \1
	call OBJLstS_ApplyGravityVAndMoveHV
	jp   nc, \2
ENDM

; =============== mMvC_DoGravityV ===============
; Handles gravity and moves the OBJInfo vertically.
; IN
; - 1: Gravity value
mMvC_DoGravityV: MACRO
	ld   hl, \1
	call OBJLstS_ApplyGravityVAndMoveV
ENDM

; =============== mMvC_DoGravityHV ===============
; Handles gravity and moves the OBJInfo horizontally and vertically.
; IN
; - 1: Gravity value
mMvC_DoGravityHV: MACRO
	ld   hl, \1
	call OBJLstS_ApplyGravityVAndMoveHV
ENDM


; =============== mMvC_DoFrictionH ===============
; Handles friction and moves the player horizontally.
; IN
; - 1: Friction value
; OUT
; - C: If set, the h speed was 0 already
mMvC_DoFrictionH: MACRO
	ld   hl, \1
	call OBJLstS_ApplyFrictionHAndMoveH
ENDM

; =============== mMvC_ChkMaxPow ===============
; Executes the specified code when the player is at max power.
; IN
; - 1: Where to jump if we're at max power
mMvC_ChkMaxPow: MACRO
	ld   hl, iPlInfo_Pow
	add  hl, bc
	ld   a, [hl]		; A = Pow
	cp   PLAY_POW_MAX	; Pow == MAX?
	jp   z, \1			; If so, jump
ENDM

; =============== mMvC_ChkNotMaxPow ===============
; Executes the specified code when the player is *NOT* at max power.
; IN
; - 1: Where to jump if we're not at max power
mMvC_ChkNotMaxPow: MACRO
	ld   hl, iPlInfo_Pow
	add  hl, bc
	ld   a, [hl]		; A = Pow
	cp   PLAY_POW_MAX	; Pow != MAX?
	jp   nz, \1			; If so, jump
ENDM


; =============== mMvC_ValHit ===============
; Executes code below only if the opponent got hit in the damage string.
; IN
; - 1: Ptr to code for not hitting yet
; - 2: Ptr to code for the opponent blocking the attack
mMvC_ValHit: MACRO
	call Play_Pl_IsMoveHit	; Perform check
	jp   nc, \1	; Did the opponent get hit yet? If not, jump
	jp   nz, \2 ; Did the opponent block it? If so, jump
ENDM

; =============== mMvC_ValLoaded ===============
; Executes the code below only if the graphics for the first animation frame finished loading.
; This prevents problems when displaying frames from the previous move animation.
; IN
; - 1: Where to jump if validation fails
mMvC_ValLoaded: MACRO
	call Play_Pl_IsMoveLoading
	jp   c, \1
ENDM

; =============== mMvC_ValFrameStart ===============
; Executes the code below only when the graphics for the frame have just finished loading
; (animation frame visible for the first time).
; When code for a move is executed depending on the visible frame, it's used to execute
; code once, only the first time we get there.
; IN
; - 1: Where to jump if validation fails
mMvC_ValFrameStart: MACRO
	call OBJLstS_IsFrameNewLoad
	jp   z, \1
ENDM

; =============== mMvC_ValFrameStartFast ===============
; Simpler version of mMvC_ValFrameStart.
; IN
; - 1: Where to jump if validation fails
mMvC_ValFrameStartFast: MACRO
	ld   hl, iOBJInfo_Status
	add  hl, de					; Seek to iOBJInfo_Status
	bit  OSTB_GFXNEWLOAD, [hl]	; Have the graphics for the frame just finished loading?
	jp   z, \1					; If not, jump
ENDM

; =============== mMvC_ValFrameNotStart ===============
; Opposite of mMvC_ValFrameStart.
; IN
; - 1: Where to jump if validation fails
mMvC_ValFrameNotStart: MACRO
	call OBJLstS_IsFrameNewLoad
	jp   nz, \1
ENDM

; =============== mMvC_ValFrameEnd ===============
; Executes the code below only if the internal sprite mapping ID is about to change.
; For code to be executed once, near the end of the animation frame.
; IN
; - 1: Where to jump if validation fails
; OUT
; - HL: Ptr to iOBJInfo_FrameLeft
mMvC_ValFrameEnd: MACRO
	call OBJLstS_IsInternalFrameAboutToEnd
	jp   nc, \1
ENDM

; =============== mMvC_ValEscape ===============
; Executes the code below only if the opponent escaped from a multi-hit special move.
; English version only.
; IN
; - 1: Where to jump if validation fails
mMvC_ValEscape: MACRO
	call Play_Pl_IsMoveEscape
	jp   nc, \1
ENDM

; =============== mMvC_EndThrow ===============
; Ends a throw move.
mMvC_EndThrow: MACRO
	call Play_Pl_EndMove
	xor  a ; PLAY_THROWACT_NONE
	ld   [wPlayPlThrowActId], a
ENDM

; =============== mMvC_EndThrow_Slow ===============
; Ends a throw move. Do not use.
mMvC_EndThrow_Slow: MACRO
	call Play_Pl_EndMove
	ld   a, PLAY_THROWACT_NONE
	ld   [wPlayPlThrowActId], a
ENDM

; =============== Sound driver macros ===============
; For command IDs, their code will be specified in a comment.

; =============== snderr ===============
; Dummy command which should never be called.
; Code: Sound_DecDataPtr
; IN
; - 1: Full command byte
snderr: MACRO
	db \1
ENDM

; =============== sndendch ===============
; Stops channel playback.
; Code: Sound_Cmd_EndCh
sndendch: MACRO
	db SNDCMD_BASE + $03
ENDM

; =============== sndenvch3 ===============
; Sets channel 3's volume. Channel 3 only.
; Code: Sound_Cmd_WriteToNRx2
; IN:
; - 1: Volume level
sndenvch3: MACRO
	ASSERT \1 <= %11, "Volume level too high"
	
	db SNDCMD_BASE + $04
	db (\1 << 5)
ENDM

; =============== sndenv ===============
; Sets volume/sweep info for channels 1-2-4. Channels 1-2-4 only.
; Code: Sound_Cmd_WriteToNRx2
; IN:
; - 1: Initial volume level
; - 2: Envelope direction (as a byte constant)
; - 3: Sweep
sndenv: MACRO
	ASSERT \1 <= %1111, "Volume level too high"
	ASSERT \2 == SNDENV_INC || \2 == SNDENV_DEC, "Invalid envelope direction value"
	ASSERT \3 <= %111, "Sweep level too high"
	
	db SNDCMD_BASE + $04
	db (\1 << 4)|(\2)|(\3)
ENDM

; =============== sndloop ===============
; Jumps to the specified target in the song data.
; Code: Sound_Cmd_JpFromLoop
; IN:
; - 1: Ptr to song data
sndloop: MACRO
	db SNDCMD_BASE + $05
	dw \1
ENDM

; =============== sndnotebase ===============
; Sets the base note id value.
; Code: Sound_Cmd_AddToBaseFreqId
; IN:
; - 1: Base note id
sndnotebase: MACRO
	db SNDCMD_BASE + $06
	db \1
ENDM

; =============== sndloopcnt ===============
; Jumps to the specified target the specified amount of times.
; After it loops the required amount of times, the command is ignored and the song continues.
; Code: Sound_Cmd_JpFromLoopByTimer
; IN:
; - 1: Timer ID (should be unique as to not overwrite other loops)
; - 2: Times to loop (Initial timer value)
; - 3: Ptr to song data
sndloopcnt: MACRO
	db SNDCMD_BASE + $07
	db \1, \2
	dw \3
ENDM

; =============== snd_UNUSED_nr10 ===============
; Sets rNR10 settings.
; Code: Sound_Cmd_Unused_WriteToNR10
; IN:
; - 1: Sweep time
; - 2: Sweep direction
; - 3: Number of sweep shifts
snd_UNUSED_nr10: MACRO
	ASSERT \1 <= %111, "Sweep time is too high"
	ASSERT \2 <= %1, "Sweep direction flag invalid"
	ASSERT \3 <= %111, "Too many sweep shifts"
	
	db SNDCMD_BASE + $08
	db (\1 << 4)|(\2 << 3)|(\3)
ENDM

; =============== sndenach ===============
; Enables the specified sound channels, on top of the already enabled channels.
; Code: Sound_Cmd_SetChEna
; IN:
; - 1: Channels to enable. Only the same type should be enabled.
sndenach: MACRO
	db SNDCMD_BASE + $09
	db \1
ENDM

; =============== sndcall ===============
; Like calling a subroutine, but for the sound data ptr.
; Code: Sound_Cmd_Call
; IN:
; - 1: Ptr to song data
sndcall: MACRO
	db SNDCMD_BASE + $0C
	dw \1
ENDM

; =============== sndret ===============
; Like returning from a subroutine, but for the sound data ptr.
; Code: Sound_Cmd_Ret
; IN:
; - 1: Ptr to song data
sndret: MACRO
	db SNDCMD_BASE + $0D
ENDM

; =============== sndnr11 ===============
; Writes data to NR11. Channel 1 only.
; Code: Sound_Cmd_WriteToNRx1
; IN:
; - 1: Wave pattern duty
; - 2: Sound length
sndnr11: MACRO
	ASSERT \1 <= %11, "Pat duty too high"
	ASSERT \2 <= %111111, "Sound length too high"
	db SNDCMD_BASE + $0E
	db (\1 << 6)|\2
ENDM
; =============== sndnr21 ===============
; Writes data to NR21. Channel 2 only.
; Code: Sound_Cmd_WriteToNRx1
; IN:
; - 1: Wave pattern duty
; - 2: Sound length
sndnr21: MACRO
	sndnr11 \1, \2
ENDM

; =============== sndnr31 ===============
; Writes data to NR31. Channel 3 only.
; Code: Sound_Cmd_WriteToNRx1
; IN:
; - 1: Sound length
sndnr31: MACRO
	db SNDCMD_BASE + $0E
	db \1
ENDM

; =============== sndnr41 ===============
; Writes data to NR41. Channel 4 only.
; Code: Sound_Cmd_WriteToNRx1
; IN:
; - 1: Sound length
sndnr41: MACRO
	ASSERT \1 <= %111111, "Sound length too high"
	db SNDCMD_BASE + $0E
	db \1
ENDM

; =============== sndsetskip ===============
; Disables writes to NR*2 when syncing SndInfo -> Sound Regs.
; Code: Sound_Cmd_SetSkipNRx2
sndsetskip: MACRO
	db SNDCMD_BASE + $0F
ENDM

; =============== sndclrskip ===============
; Enables writes to NR*2 when syncing SndInfo -> Sound Regs.
; Code: Sound_Cmd_ClrSkipNRx2
sndclrskip: MACRO
	db SNDCMD_BASE + $10
ENDM

; =============== snd_UNUSED_setstat6 ===============
; Sets an unknown SndInfo status flag.
; Code: Sound_Cmd_Unknown_Unused_SetStat6
snd_UNUSED_setstat6: MACRO
	db SNDCMD_BASE + $11
ENDM

; =============== snd_UNUSED_clrstat6 ===============
; Clears an unknown SndInfo status flag.
; Code: Sound_Cmd_Unknown_Unused_ClrStat6
snd_UNUSED_clrstat6: MACRO
	db SNDCMD_BASE + $12
ENDM

; =============== sndwave ===============
; Writes a new set of wave data.
; Code: Sound_Cmd_SetWaveData
; IN:
; - 1: Wave set ID
sndwave: MACRO
	db SNDCMD_BASE + $13
	db \1
ENDM

; =============== snd_UNUSED_endchflag7F ===============
; Stops channel playback and updates an otherwise unused bitmask.
; Code: Sound_Cmd_Unused_EndChFlag7F
snd_UNUSED_endchflag7F: MACRO
	db SNDCMD_BASE + $14
ENDM

; =============== sndch3len ===============
; Sets a new length value for channel 3 and applies it immediately to NR31.
; Code: Sound_Cmd_SetCh3StopLength
; IN:
; - 1: Length value
sndch3len: MACRO
	db SNDCMD_BASE + $15
	db \1
ENDM

; =============== snd_UNUSED_endchflagBF ===============
; Stops channel playback and updates an otherwise unused bitmask.
; Code: Sound_Cmd_Unused_EndChFlagBF
snd_UNUSED_endchflagBF: MACRO
	db SNDCMD_BASE + $16
ENDM

; =============== sndlenpre ===============
; Sets a new channel length before the SndInfo -> Register sync.
; Code: Sound_Cmd_SetLength
; IN:
; - 1: Length value
sndlenpre: MACRO
	db SNDCMD_BASE + $1A
	db \1
ENDM

; =============== sndch4 ===============
; Writes frequency data to channel 4 (rNR43). Channel 4 only.
; Code: N/A
; IN:
; - 1: Frequency value
; - 2: Step width
; - 3: Freq. dividing ratio
sndch4: MACRO
	ASSERT \1 <= %1111, "Frequency too high"
	ASSERT \2 <= %1, "Width should be 0 or 1"
	ASSERT \3 <= %111, "Invalid ratio"
	db (\1 << 4)|(\2 << 3)|(\3)
ENDM

; =============== sndnote ===============
; Sets a note id. Channels 1-2-3 only.
; Code: N/A
; IN:
; - 1: Note ID
sndnote: MACRO
	db SNDNOTE_BASE+\1
ENDM

; =============== sndlen ===============
; Sets the target length after the SndInfo -> Register sync.
; Code: N/A
; IN:
; - 1: Length
sndlen: MACRO
	db \1
ENDM