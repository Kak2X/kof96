MoveAnimTbl_Marker:
; =============== MoveAnimTbl_* ===============
; OBJInfo and PlInfo settings for every move (not just specials).
; This primarily defines the move animations, which in turn define the frames, which have their own collision boxes.
;
; It's extremely important that the move animations assigned here are compatible with the respective move code
; as assigned in MoveCodePtrTbl_*.
; 
; This is due to what the move code can do with the sprite mapping ID:
; - The move may only end when a certain ID is reached.
;   If the animation has less frames, it may loop or freeze at the last frame,
;   causing a softlock if the other player doesn't hit the player out of it (guaranteed in case of the CPU).
; - The move ID may be set to an arbitrary value.
;   If that's past the end of the animation table, it will read a garbage sprite mapping
;   with a likely invalid tile count. As neither the GFX writer and sprite mapping writer
;   validate the tile count (in particular there's nothing to mark the number of free space
;   left in the OAM mirror), the game breaks.
;
; See also: Pl_SetNewMove
;
; FORMAT
; Each entry is 8 bytes:
; - 0: Bank number for the animation table (iOBJInfo_BankNum)
; - 1-2: Ptr to animation table (iOBJInfo_OBJLstPtrTbl)
; - 3: Sprite Mapping ID target, when this is reached something happens (usually checking if the move can end). (iPlInfo_OBJLstPtrTblOffsetMoveEnd)
; - 4: Animation speed. Higher values = slower animation (iOBJInfo_FrameLeft)
; - 5: Damage dealt to the opponent (iPlInfo_MoveDamageValNext)
; - 6: Hit Effect ID delivered to the opponent if hit by the move. (HITTYPE_*) (iPlInfo_MoveDamageHitTypeIdNext)
; - 7: Hit properties (how the opponent can block it, etc...) 
;      iPlInfo_Flags3 delivered to the opponent on hit (iPlInfo_MoveDamageFlags3Next)
;
; NOTES
; - Every character begins with a dummy row for move $00 (MOVE_SHARED_NONE).
;   This is never used and shouldn't be for obvious reasons.
; - Characters without a special intro have a duplicate of their normal intro.
; - [POI] Empty special/super move slots are filed with placeholder default entries.
;         All of these reuse the idle animation truncated to the first frame.
;         For special moves, these are set to deal no damage, while super moves do $14 lines.

mMvAnDef: MACRO
	dp \1
	db \2, \3, \4, \5, \6
ENDM



MoveAnimTbl_Kyo:
	db $4C, $00, $00, $00, $00, $00, $00, $00 ;X ; MOVE_SHARED_NONE
	mMvAnDef OBJLstPtrTable_Kyo_Idle, $0C, $06, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_IDLE
	mMvAnDef OBJLstPtrTable_Kyo_WalkF, $08, $01, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_WALK_F
	mMvAnDef OBJLstPtrTable_Kyo_WalkB, $08, $02, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_WALK_B
	mMvAnDef OBJLstPtrTable_Kyo_Crouch, $00, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_CROUCH
	mMvAnDef OBJLstPtrTable_Kyo_JumpN, $1C, $02, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_JUMP_N
	mMvAnDef OBJLstPtrTable_Kyo_JumpF, $1C, $02, $00, $00, $00 ;X ; BANK $07 ; MOVE_SHARED_JUMP_F
	mMvAnDef OBJLstPtrTable_Kyo_JumpB, $1C, $02, $00, $00, $00 ;X ; BANK $07 ; MOVE_SHARED_JUMP_B
	mMvAnDef OBJLstPtrTable_Kyo_BlockG, $00, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_BLOCK_G
	mMvAnDef OBJLstPtrTable_Kyo_BlockC, $00, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_BLOCK_C
	mMvAnDef OBJLstPtrTable_Kyo_BlockA, $00, $FF, $00, $00, $00 ;X ; BANK $07 ; MOVE_SHARED_BLOCK_A
	mMvAnDef OBJLstPtrTable_Kyo_RunF, $08, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_RUN_F
	mMvAnDef OBJLstPtrTable_Kyo_HopB, $08, $FF, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_HOP_B
	mMvAnDef OBJLstPtrTable_Kyo_ChargeMeter, $04, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_CHARGEMETER
	mMvAnDef OBJLstPtrTable_Kyo_Taunt, $14, $03, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_TAUNT
	mMvAnDef OBJLstPtrTable_Kyo_RollF, $10, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_ROLL_F
	mMvAnDef OBJLstPtrTable_Kyo_RollB, $10, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_ROLL_B
	mMvAnDef OBJLstPtrTable_Kyo_WakeUp, $04, $02, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_WAKEUP
	mMvAnDef OBJLstPtrTable_Kyo_Dizzy, $04, $0A, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_DIZZY
	mMvAnDef OBJLstPtrTable_Kyo_WinA, $08, $08, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_WIN_A
	mMvAnDef OBJLstPtrTable_Kyo_WinB, $0C, $08, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_WIN_B
	mMvAnDef OBJLstPtrTable_Kyo_TimeOver, $00, $01, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_LOST_TIMEOVER
	mMvAnDef OBJLstPtrTable_Kyo_Intro, $18, $08, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_INTRO
	mMvAnDef OBJLstPtrTable_Kyo_IntroSpec, $10, $08, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_INTRO_SPEC
	mMvAnDef OBJLstPtrTable_Kyo_PunchL, $08, $00, $04, HITTYPE_HIT_MID0, $00 ; BANK $07 ; MOVE_SHARED_PUNCH_L
	mMvAnDef OBJLstPtrTable_Kyo_PunchH, $0C, $01, $04, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $07 ; MOVE_SHARED_PUNCH_H
	mMvAnDef OBJLstPtrTable_Kyo_KickL, $08, $01, $08, HITTYPE_HIT_MID1, $00 ; BANK $07 ; MOVE_SHARED_KICK_L
	mMvAnDef OBJLstPtrTable_Kyo_KickH, $10, $02, $08, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $07 ; MOVE_SHARED_KICK_H
	mMvAnDef OBJLstPtrTable_Kyo_PunchCL, $08, $00, $03, HITTYPE_HIT_MID1, $00 ; BANK $07 ; MOVE_SHARED_PUNCH_CL
	mMvAnDef OBJLstPtrTable_Kyo_PunchCH, $10, $01, $03, HITTYPE_HIT_MID0, PF3_HEAVYHIT ; BANK $07 ; MOVE_SHARED_PUNCH_CH
	mMvAnDef OBJLstPtrTable_Kyo_KickCL, $08, $00, $06, HITTYPE_HIT_MID1, PF3_HITLOW ; BANK $07 ; MOVE_SHARED_KICK_CL
	mMvAnDef OBJLstPtrTable_Kyo_KickCH, $10, $02, $06, HITTYPE_DROP_CH, PF3_HITLOW ; BANK $07 ; MOVE_SHARED_KICK_CH
	mMvAnDef OBJLstPtrTable_Kyo_AttackG, $08, $03, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $07 ; MOVE_SHARED_ATTACK_G
	mMvAnDef OBJLstPtrTable_Kyo_PunchA, $10, $01, $05, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $07 ; MOVE_SHARED_PUNCH_A
	mMvAnDef OBJLstPtrTable_Kyo_KickA, $10, $01, $09, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $07 ; MOVE_SHARED_KICK_A
	mMvAnDef OBJLstPtrTable_Kyo_AttackA, $10, $01, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_OVERHEAD ; BANK $07 ; MOVE_SHARED_ATTACK_A
	mMvAnDef OBJLstPtrTable_Kyo_AraKamiL, $50, $00, $0A, HITTYPE_HIT_MID0, PF3_HEAVYHIT|PF3_FIRE ; BANK $07 ; MOVE_KYO_ARA_KAMI_L
	mMvAnDef OBJLstPtrTable_Kyo_AraKamiH, $2C, $00, $0A, HITTYPE_HIT_MID1, PF3_HEAVYHIT|PF3_FIRE ; BANK $07 ; MOVE_KYO_ARA_KAMI_H
	mMvAnDef OBJLstPtrTable_Kyo_OniyakiL, $14, $01, $09, HITTYPE_DROP_MAIN, $00 ; BANK $07 ; MOVE_KYO_ONIYAKI_L
	mMvAnDef OBJLstPtrTable_Kyo_OniyakiL, $14, $02, $09, HITTYPE_HIT_MID1, $00 ; BANK $07 ; MOVE_KYO_ONIYAKI_H
	mMvAnDef OBJLstPtrTable_Kyo_RedKickL, $20, $01, $04, HITTYPE_DROP_DB_A, $00 ; BANK $07 ; MOVE_KYO_RED_KICK_L
	mMvAnDef OBJLstPtrTable_Kyo_RedKickL, $20, $01, $04, HITTYPE_DROP_DB_A, PF3_HEAVYHIT ; BANK $07 ; MOVE_KYO_RED_KICK_H
	mMvAnDef OBJLstPtrTable_Kyo_KototsukiYouL, $18, $02, $09, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $07 ; MOVE_KYO_KOTOTSUKI_YOU_L
	mMvAnDef OBJLstPtrTable_Kyo_KototsukiYouL, $18, $04, $09, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $07 ; MOVE_KYO_KOTOTSUKI_YOU_H
	mMvAnDef OBJLstPtrTable_Kyo_KaiL, $14, $FF, $09, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $07 ; MOVE_KYO_KAI_L
	mMvAnDef OBJLstPtrTable_Kyo_KaiL, $14, $FF, $09, HITTYPE_DROP_MAIN, PF3_LASTHIT ; BANK $07 ; MOVE_KYO_KAI_H
	mMvAnDef OBJLstPtrTable_Kyo_NueTumiL, $00, $01, $07, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $07 ; MOVE_KYO_NUE_TUMI_L
	mMvAnDef OBJLstPtrTable_Kyo_NueTumiL, $00, $03, $07, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $07 ; MOVE_KYO_NUE_TUMI_H
	mMvAnDef OBJLstPtrTable_Kyo_Idle, $00, $02, $00, $00, $00 ;X ; BANK $07 ; MOVE_KYO_SPEC_6_L
	mMvAnDef OBJLstPtrTable_Kyo_Idle, $00, $02, $00, $00, $00 ;X ; BANK $07 ; MOVE_KYO_SPEC_6_H
	mMvAnDef OBJLstPtrTable_Kyo_UraOrochiNagiS, $18, $00, $18, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ; BANK $07 ; MOVE_KYO_URA_OROCHI_NAGI_S
	mMvAnDef OBJLstPtrTable_Kyo_UraOrochiNagiD, $18, $00, $01, HITTYPE_HIT_MID0, PF3_FIRE|PF3_LASTHIT ; BANK $07 ; MOVE_KYO_URA_OROCHI_NAGI_D
IF REV_VER_2 == 0
	mMvAnDef OBJLstPtrTable_Kyo_Idle, $18, $01, $14, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ;X ; BANK $07 ; MOVE_KYO_SUPER_1_S
ELSE
	mMvAnDef OBJLstPtrTable_Kyo_UraOrochiNagiD, $18, $00, $01, HITTYPE_HIT_MID0, PF3_FIRE|PF3_LASTHIT ; BANK $07 ; MOVE_KYO_URA_OROCHI_NAGI_E
ENDC
	mMvAnDef OBJLstPtrTable_Kyo_Idle, $18, $01, $14, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ;X ; BANK $07 ; MOVE_KYO_SUPER_1_D
	mMvAnDef OBJLstPtrTable_Kyo_ThrowG, $0C, $0A, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_THROW_G
	mMvAnDef OBJLstPtrTable_Kyo_Idle, $00, $00, $00, $00, $00 ;X ; BANK $07 ; MOVE_SHARED_THROW_A
	mMvAnDef OBJLstPtrTable_Kyo_BlockG, $00, $05, $00, $00, $00 ;X ; BANK $07 ; MOVE_SHARED_POST_BLOCKSTUN
	mMvAnDef OBJLstPtrTable_Kyo_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_GUARDBREAK_G
	mMvAnDef OBJLstPtrTable_Kyo_GuardBreakA, $04, $FF, $00, $00, $00 ;X ; BANK $07 ; MOVE_SHARED_GUARDBREAK_A
	mMvAnDef OBJLstPtrTable_Kyo_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_HIT0MID
	mMvAnDef OBJLstPtrTable_Kyo_TimeOver, $00, $05, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_HIT1MID
	mMvAnDef OBJLstPtrTable_Kyo_Hitlow, $00, $05, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_HITLOW
	mMvAnDef OBJLstPtrTable_Kyo_DropMain, $10, $05, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_DROP_MAIN
	mMvAnDef OBJLstPtrTable_Kyo_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_THROW_END_A
	mMvAnDef OBJLstPtrTable_Kyo_DropDbg, $00, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_DROP_DBG
	mMvAnDef OBJLstPtrTable_Kyo_HitSwoopup, $18, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_HIT_SWOOPUP
	mMvAnDef OBJLstPtrTable_Kyo_DropDbg, $08, $02, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_DROP_CH
	mMvAnDef OBJLstPtrTable_Kyo_BackjumpRecA, $18, $02, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_BACKJUMP_REC_A
	mMvAnDef OBJLstPtrTable_Kyo_GuardBreakG, $00, $14, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_HIT_MULTIMID0
	mMvAnDef OBJLstPtrTable_Kyo_TimeOver, $00, $14, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_HIT_MULTIMID1
	mMvAnDef OBJLstPtrTable_Kyo_HitMultigs, $04, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_HIT_MULTIGS
	mMvAnDef OBJLstPtrTable_Kyo_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_THROW_END_G
	mMvAnDef OBJLstPtrTable_Kyo_TimeOver, $00, $3C, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_THROW_START
	mMvAnDef OBJLstPtrTable_Kyo_TimeOver, $00, $3C, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_THROW_ROTU
	mMvAnDef OBJLstPtrTable_Kyo_ThrowRotL, $00, $3C, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_THROW_ROTL
	mMvAnDef OBJLstPtrTable_Kyo_ThrowEndA, $00, $3C, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_THROW_ROTD
	mMvAnDef OBJLstPtrTable_Kyo_HitMultigs, $00, $3C, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_THROW_ROTR
MoveAnimTbl_Daimon:
	db $4C, $00, $00, $00, $00, $00, $00, $00 ;X ; MOVE_SHARED_NONE
	mMvAnDef OBJLstPtrTable_Daimon_Idle, $0C, $02, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_IDLE
	mMvAnDef OBJLstPtrTable_Daimon_WalkF, $08, $01, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_WALK_F
	mMvAnDef OBJLstPtrTable_Daimon_WalkB, $08, $02, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_WALK_B
	mMvAnDef OBJLstPtrTable_Daimon_Crouch, $00, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_CROUCH
	mMvAnDef OBJLstPtrTable_Daimon_JumpN, $1C, $02, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_JUMP_N
	mMvAnDef OBJLstPtrTable_Daimon_JumpN, $1C, $02, $00, $00, $00 ;X ; BANK $09 ; MOVE_SHARED_JUMP_F
	mMvAnDef OBJLstPtrTable_Daimon_JumpN, $1C, $02, $00, $00, $00 ;X ; BANK $09 ; MOVE_SHARED_JUMP_B
	mMvAnDef OBJLstPtrTable_Daimon_BlockG, $00, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_BLOCK_G
	mMvAnDef OBJLstPtrTable_Daimon_BlockC, $00, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_BLOCK_C
	mMvAnDef OBJLstPtrTable_Daimon_BlockA, $00, $FF, $00, $00, $00 ;X ; BANK $09 ; MOVE_SHARED_BLOCK_A
	mMvAnDef OBJLstPtrTable_Daimon_RunF, $08, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_RUN_F
	mMvAnDef OBJLstPtrTable_Daimon_HopB, $08, $FF, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_HOP_B
	mMvAnDef OBJLstPtrTable_Daimon_ChargeMeter, $04, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_CHARGEMETER
	mMvAnDef OBJLstPtrTable_Daimon_Taunt, $10, $03, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_TAUNT
	mMvAnDef OBJLstPtrTable_Daimon_RollF, $0C, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_ROLL_F
	mMvAnDef OBJLstPtrTable_Daimon_RollB, $0C, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_ROLL_B
	mMvAnDef OBJLstPtrTable_Daimon_Wakeup, $04, $02, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_WAKEUP
	mMvAnDef OBJLstPtrTable_Daimon_Dizzy, $04, $0A, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_DIZZY
	mMvAnDef OBJLstPtrTable_Daimon_WinA, $08, $08, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_WIN_A
	mMvAnDef OBJLstPtrTable_Daimon_WinB, $08, $08, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_WIN_B
	mMvAnDef OBJLstPtrTable_Daimon_TimeOver, $00, $01, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_LOST_TIMEOVER
	mMvAnDef OBJLstPtrTable_Daimon_Taunt, $10, $08, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_INTRO
	mMvAnDef OBJLstPtrTable_Daimon_Taunt, $10, $08, $00, $00, $00 ;X ; BANK $09 ; MOVE_SHARED_INTRO_SPEC
	mMvAnDef OBJLstPtrTable_Daimon_PunchL, $08, $00, $04, HITTYPE_HIT_MID0, $00 ; BANK $09 ; MOVE_SHARED_PUNCH_L
	mMvAnDef OBJLstPtrTable_Daimon_PunchH, $0C, $01, $04, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $09 ; MOVE_SHARED_PUNCH_H
	mMvAnDef OBJLstPtrTable_Daimon_KickL, $08, $01, $08, HITTYPE_HIT_MID1, $00 ; BANK $09 ; MOVE_SHARED_KICK_L
	mMvAnDef OBJLstPtrTable_Daimon_KickH, $08, $02, $08, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $09 ; MOVE_SHARED_KICK_H
	mMvAnDef OBJLstPtrTable_Daimon_PunchCL, $08, $00, $03, HITTYPE_HIT_MID1, $00 ; BANK $09 ; MOVE_SHARED_PUNCH_CL
	mMvAnDef OBJLstPtrTable_Daimon_PunchCH, $08, $01, $03, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $09 ; MOVE_SHARED_PUNCH_CH
	mMvAnDef OBJLstPtrTable_Daimon_KickCL, $08, $00, $06, HITTYPE_HIT_MID1, PF3_HITLOW ; BANK $09 ; MOVE_SHARED_KICK_CL
	mMvAnDef OBJLstPtrTable_Daimon_KickCH, $0C, $02, $06, HITTYPE_DROP_CH, PF3_HEAVYHIT|PF3_HITLOW|PF3_LASTHIT ; BANK $09 ; MOVE_SHARED_KICK_CH
	mMvAnDef OBJLstPtrTable_Daimon_AttackG, $08, $03, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $09 ; MOVE_SHARED_ATTACK_G
	mMvAnDef OBJLstPtrTable_Daimon_PunchA, $10, $01, $05, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $09 ; MOVE_SHARED_PUNCH_A
	mMvAnDef OBJLstPtrTable_Daimon_KickA, $10, $01, $09, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $09 ; MOVE_SHARED_KICK_A
	mMvAnDef OBJLstPtrTable_Daimon_AttackA, $10, $01, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_OVERHEAD ; BANK $09 ; MOVE_SHARED_ATTACK_A
	mMvAnDef OBJLstPtrTable_Daimon_JiraiShin, $0C, $04, $0A, HITTYPE_DROP_CH, PF3_HITLOW|PF3_LIGHTHIT ; BANK $09 ; MOVE_DAIMON_JIRAI_SHIN
	mMvAnDef OBJLstPtrTable_Daimon_JiraiShin, $0C, $04, $0A, HITTYPE_DROP_CH, PF3_HITLOW|PF3_LIGHTHIT ; BANK $09 ; MOVE_DAIMON_JIRAI_SHIN_FAKE
	mMvAnDef OBJLstPtrTable_Daimon_CHouUkemiL, $14, $01, $00, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $09 ; MOVE_DAIMON_CHOU_UKEMI_L
	mMvAnDef OBJLstPtrTable_Daimon_CHouUkemiL, $14, $01, $00, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $09 ; MOVE_DAIMON_CHOU_UKEMI_H
	mMvAnDef OBJLstPtrTable_Daimon_CHouOosotoGariL, $20, $03, $04, HITTYPE_DROP_MAIN, PF3_LASTHIT|PF3_LIGHTHIT ; BANK $09 ; MOVE_DAIMON_CHOU_OOSOTO_GARI_L
	mMvAnDef OBJLstPtrTable_Daimon_CHouOosotoGariL, $20, $03, $04, HITTYPE_DROP_MAIN, PF3_LASTHIT|PF3_LIGHTHIT ; BANK $09 ; MOVE_DAIMON_CHOU_OOSOTO_GARI_H
	mMvAnDef OBJLstPtrTable_Daimon_CLoudTosser, $18, $03, $04, HITTYPE_DROP_MAIN, PF3_LASTHIT|PF3_LIGHTHIT ; BANK $09 ; MOVE_DAIMON_CLOUD_TOSSER
	mMvAnDef OBJLstPtrTable_Daimon_StumpThrow, $18, $03, $04, HITTYPE_DROP_MAIN, PF3_LASTHIT|PF3_LIGHTHIT ; BANK $09 ; MOVE_DAIMON_STUMP_THROW
	mMvAnDef OBJLstPtrTable_Daimon_HeavenDropL, $14, $0A, $00, HITTYPE_DROP_MAIN, PF3_LASTHIT ; BANK $09 ; MOVE_DAIMON_HEAVEN_DROP_L
	mMvAnDef OBJLstPtrTable_Daimon_HeavenDropL, $14, $0A, $00, HITTYPE_DROP_MAIN, PF3_LASTHIT ; BANK $09 ; MOVE_DAIMON_HEAVEN_DROP_H
	mMvAnDef OBJLstPtrTable_Daimon_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $09 ; MOVE_DAIMON_SPEC_5_L
	mMvAnDef OBJLstPtrTable_Daimon_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $09 ; MOVE_DAIMON_SPEC_5_H
	mMvAnDef OBJLstPtrTable_Daimon_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $09 ; MOVE_DAIMON_SPEC_6_L
	mMvAnDef OBJLstPtrTable_Daimon_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $09 ; MOVE_DAIMON_SPEC_6_H
	mMvAnDef OBJLstPtrTable_Daimon_HeavenHellDropS, $18, $0A, $00, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ; BANK $09 ; MOVE_DAIMON_HEAVEN_HELL_DROP_S
	mMvAnDef OBJLstPtrTable_Daimon_HeavenHellDropS, $18, $0A, $00, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ; BANK $09 ; MOVE_DAIMON_HEAVEN_HELL_DROP_D
	mMvAnDef OBJLstPtrTable_Daimon_HeavenHellDropS, $18, $01, $14, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ;X ; BANK $09 ; MOVE_DAIMON_SUPER_1_S
	mMvAnDef OBJLstPtrTable_Daimon_HeavenHellDropS, $18, $01, $14, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ;X ; BANK $09 ; MOVE_DAIMON_SUPER_1_D
	mMvAnDef OBJLstPtrTable_Daimon_ThrowG, $0C, $0A, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_THROW_G
	mMvAnDef OBJLstPtrTable_Daimon_Idle, $00, $00, $00, $00, $00 ;X ; BANK $09 ; MOVE_SHARED_THROW_A
	mMvAnDef OBJLstPtrTable_Daimon_BlockG, $00, $05, $00, $00, $00 ;X ; BANK $09 ; MOVE_SHARED_POST_BLOCKSTUN
	mMvAnDef OBJLstPtrTable_Daimon_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_GUARDBREAK_G
	mMvAnDef OBJLstPtrTable_Daimon_GuardBreakA, $04, $FF, $00, $00, $00 ;X ; BANK $09 ; MOVE_SHARED_GUARDBREAK_A
	mMvAnDef OBJLstPtrTable_Daimon_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_HIT0MID
	mMvAnDef OBJLstPtrTable_Daimon_TimeOver, $00, $05, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_HIT1MID
	mMvAnDef OBJLstPtrTable_Daimon_Hitlow, $00, $05, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_HITLOW
	mMvAnDef OBJLstPtrTable_Daimon_DropMain, $10, $05, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_DROP_MAIN
	mMvAnDef OBJLstPtrTable_Daimon_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_THROW_END_A
	mMvAnDef OBJLstPtrTable_Daimon_DropDbg, $00, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_DROP_DBG
	mMvAnDef OBJLstPtrTable_Daimon_HitSwoopup, $18, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_HIT_SWOOPUP
	mMvAnDef OBJLstPtrTable_Daimon_DropDbg, $08, $02, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_DROP_CH
	mMvAnDef OBJLstPtrTable_Daimon_BackjumpRecA, $18, $02, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_BACKJUMP_REC_A
	mMvAnDef OBJLstPtrTable_Daimon_GuardBreakG, $00, $14, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_HIT_MULTIMID0
	mMvAnDef OBJLstPtrTable_Daimon_TimeOver, $00, $14, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_HIT_MULTIMID1
	mMvAnDef OBJLstPtrTable_Daimon_HitMultigs, $04, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_HIT_MULTIGS
	mMvAnDef OBJLstPtrTable_Daimon_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_THROW_END_G
	mMvAnDef OBJLstPtrTable_Daimon_TimeOver, $00, $3C, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_THROW_START
	mMvAnDef OBJLstPtrTable_Daimon_TimeOver, $00, $3C, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_THROW_ROTU
	mMvAnDef OBJLstPtrTable_Daimon_ThrowRotL, $00, $3C, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_THROW_ROTL
	mMvAnDef OBJLstPtrTable_Daimon_ThrowEndA, $00, $3C, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_THROW_ROTD
	mMvAnDef OBJLstPtrTable_Daimon_HitMultigs, $00, $3C, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_THROW_ROTR
MoveAnimTbl_Terry:
	db $4C, $00, $00, $00, $00, $00, $00, $00 ;X ; MOVE_SHARED_NONE
	mMvAnDef OBJLstPtrTable_Terry_Idle, $0C, $06, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_IDLE
	mMvAnDef OBJLstPtrTable_Terry_WalkF, $08, $01, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_WALK_F
	mMvAnDef OBJLstPtrTable_Terry_WalkB, $08, $02, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_WALK_B
	mMvAnDef OBJLstPtrTable_Terry_Crouch, $00, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_CROUCH
	mMvAnDef OBJLstPtrTable_Terry_JumpN, $1C, $02, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_JUMP_N
	mMvAnDef OBJLstPtrTable_Terry_JumpN, $1C, $02, $00, $00, $00 ;X ; BANK $09 ; MOVE_SHARED_JUMP_F
	mMvAnDef OBJLstPtrTable_Terry_JumpN, $1C, $02, $00, $00, $00 ;X ; BANK $09 ; MOVE_SHARED_JUMP_B
	mMvAnDef OBJLstPtrTable_Terry_BlockG, $00, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_BLOCK_G
	mMvAnDef OBJLstPtrTable_Terry_BlockC, $00, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_BLOCK_C
	mMvAnDef OBJLstPtrTable_Terry_BlockA, $00, $FF, $00, $00, $00 ;X ; BANK $09 ; MOVE_SHARED_BLOCK_A
	mMvAnDef OBJLstPtrTable_Terry_RunF, $08, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_RUN_F
	mMvAnDef OBJLstPtrTable_Terry_HopB, $08, $FF, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_HOP_B
	mMvAnDef OBJLstPtrTable_Terry_ChargeMeter, $04, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_CHARGEMETER
	mMvAnDef OBJLstPtrTable_Terry_Taunt, $1C, $01, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_TAUNT
	mMvAnDef OBJLstPtrTable_Terry_RollF, $10, $01, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_ROLL_F
	mMvAnDef OBJLstPtrTable_Terry_RollB, $10, $01, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_ROLL_B
	mMvAnDef OBJLstPtrTable_Terry_Wakeup, $04, $02, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_WAKEUP
	mMvAnDef OBJLstPtrTable_Terry_Dizzy, $04, $0A, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_DIZZY
	mMvAnDef OBJLstPtrTable_Terry_WinA, $1C, $05, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_WIN_A
	mMvAnDef OBJLstPtrTable_Terry_WinB, $0C, $05, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_WIN_B
	mMvAnDef OBJLstPtrTable_Terry_TimeOver, $00, $01, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_LOST_TIMEOVER
	mMvAnDef OBJLstPtrTable_Terry_Taunt, $1C, $03, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_INTRO
	mMvAnDef OBJLstPtrTable_Terry_Taunt, $1C, $03, $00, $00, $00 ;X ; BANK $09 ; MOVE_SHARED_INTRO_SPEC
	mMvAnDef OBJLstPtrTable_Terry_PunchL, $08, $00, $04, HITTYPE_HIT_MID0, $00 ; BANK $09 ; MOVE_SHARED_PUNCH_L
	mMvAnDef OBJLstPtrTable_Terry_PunchH, $0C, $01, $04, HITTYPE_HIT_MID1, $00 ; BANK $09 ; MOVE_SHARED_PUNCH_H
	mMvAnDef OBJLstPtrTable_Terry_KickL, $08, $01, $08, HITTYPE_HIT_MID1, $00 ; BANK $09 ; MOVE_SHARED_KICK_L
	mMvAnDef OBJLstPtrTable_Terry_KickH, $08, $02, $08, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $09 ; MOVE_SHARED_KICK_H
	mMvAnDef OBJLstPtrTable_Terry_PunchCL, $08, $00, $03, HITTYPE_HIT_MID1, $00 ; BANK $09 ; MOVE_SHARED_PUNCH_CL
	mMvAnDef OBJLstPtrTable_Terry_PunchCH, $08, $01, $03, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $09 ; MOVE_SHARED_PUNCH_CH
	mMvAnDef OBJLstPtrTable_Terry_KickCL, $08, $00, $06, HITTYPE_HIT_MID1, PF3_HITLOW ; BANK $09 ; MOVE_SHARED_KICK_CL
	mMvAnDef OBJLstPtrTable_Terry_KickCH, $0C, $02, $06, HITTYPE_DROP_CH, PF3_HITLOW ; BANK $09 ; MOVE_SHARED_KICK_CH
	mMvAnDef OBJLstPtrTable_Terry_AttackG, $0C, $04, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $09 ; MOVE_SHARED_ATTACK_G
	mMvAnDef OBJLstPtrTable_Terry_PunchA, $10, $01, $05, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $09 ; MOVE_SHARED_PUNCH_A
	mMvAnDef OBJLstPtrTable_Terry_KickA, $10, $01, $09, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $09 ; MOVE_SHARED_KICK_A
	mMvAnDef OBJLstPtrTable_Terry_AttackA, $10, $01, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_OVERHEAD ; BANK $09 ; MOVE_SHARED_ATTACK_A
	mMvAnDef OBJLstPtrTable_Terry_PowerWaveL, $0C, $01, $0A, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_HALFSPEED ; BANK $09 ; MOVE_TERRY_POWER_WAVE_L
	mMvAnDef OBJLstPtrTable_Terry_PowerWaveL, $0C, $03, $0A, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_HALFSPEED ; BANK $09 ; MOVE_TERRY_POWER_WAVE_H
	mMvAnDef OBJLstPtrTable_Terry_BurnKnuckleL, $18, $01, $0A, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $09 ; MOVE_TERRY_BURN_KNUCKLE_L
	mMvAnDef OBJLstPtrTable_Terry_BurnKnuckleL, $18, $01, $0A, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $09 ; MOVE_TERRY_BURN_KNUCKLE_H
	mMvAnDef OBJLstPtrTable_Terry_CrackShotL, $10, $02, $04, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $09 ; MOVE_TERRY_CRACK_SHOT_L
	mMvAnDef OBJLstPtrTable_Terry_CrackShotL, $10, $01, $04, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $09 ; MOVE_TERRY_CRACK_SHOT_H
	mMvAnDef OBJLstPtrTable_Terry_RisingTackleL, $1C, $01, $09, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $09 ; MOVE_TERRY_RISING_TACKLE_L
	mMvAnDef OBJLstPtrTable_Terry_RisingTackleL, $1C, $02, $09, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $09 ; MOVE_TERRY_RISING_TACKLE_H
	mMvAnDef OBJLstPtrTable_Terry_PowerDunkL, $10, $01, $09, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $09 ; MOVE_TERRY_POWER_DUNK_L
	mMvAnDef OBJLstPtrTable_Terry_PowerDunkL, $10, $02, $09, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $09 ; MOVE_TERRY_POWER_DUNK_H
	mMvAnDef OBJLstPtrTable_Terry_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $09 ; MOVE_TERRY_SPEC_5_L
	mMvAnDef OBJLstPtrTable_Terry_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $09 ; MOVE_TERRY_SPEC_5_H
	mMvAnDef OBJLstPtrTable_Terry_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $09 ; MOVE_TERRY_SPEC_6_L
	mMvAnDef OBJLstPtrTable_Terry_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $09 ; MOVE_TERRY_SPEC_6_H
	mMvAnDef OBJLstPtrTable_Terry_PowerWaveL, $0C, $01, $14, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_HALFSPEED ; BANK $09 ; MOVE_TERRY_POWER_GEYSER_S
	mMvAnDef OBJLstPtrTable_Terry_PowerGeyserD, $0C, $01, $10, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_LASTHIT|PF3_HALFSPEED ; BANK $09 ; MOVE_TERRY_POWER_GEYSER_D
	mMvAnDef OBJLstPtrTable_Terry_PowerGeyserE, $0C, $14, $07, HITTYPE_DROP_MAIN, PF3_FIRE|PF3_LASTHIT|PF3_HALFSPEED|PF3_LIGHTHIT ;X ; BANK $09 ; MOVE_TERRY_POWER_GEYSER_E
	mMvAnDef OBJLstPtrTable_Terry_Idle, $0C, $01, $14, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ;X ; BANK $09 ; MOVE_TERRY_SUPER_1_D
	mMvAnDef OBJLstPtrTable_Terry_ThrowG, $08, $0A, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_THROW_G
	mMvAnDef OBJLstPtrTable_Terry_Idle, $00, $00, $00, $00, $00 ;X ; BANK $09 ; MOVE_SHARED_THROW_A
	mMvAnDef OBJLstPtrTable_Terry_BlockG, $00, $05, $00, $00, $00 ;X ; BANK $09 ; MOVE_SHARED_POST_BLOCKSTUN
	mMvAnDef OBJLstPtrTable_Terry_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_GUARDBREAK_G
	mMvAnDef OBJLstPtrTable_Terry_GuardBreakA, $04, $FF, $00, $00, $00 ;X ; BANK $09 ; MOVE_SHARED_GUARDBREAK_A
	mMvAnDef OBJLstPtrTable_Terry_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_HIT0MID
	mMvAnDef OBJLstPtrTable_Terry_TimeOver, $00, $05, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_HIT1MID
	mMvAnDef OBJLstPtrTable_Terry_Hitlow, $00, $05, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_HITLOW
	mMvAnDef OBJLstPtrTable_Terry_DropMain, $10, $05, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_DROP_MAIN
	mMvAnDef OBJLstPtrTable_Terry_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_THROW_END_A
	mMvAnDef OBJLstPtrTable_Terry_DropDbg, $00, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_DROP_DBG
	mMvAnDef OBJLstPtrTable_Terry_HitSwoopup, $18, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_HIT_SWOOPUP
	mMvAnDef OBJLstPtrTable_Terry_DropDbg, $08, $02, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_DROP_CH
	mMvAnDef OBJLstPtrTable_Terry_BackjumpRecA, $18, $02, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_BACKJUMP_REC_A
	mMvAnDef OBJLstPtrTable_Terry_GuardBreakG, $00, $14, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_HIT_MULTIMID0
	mMvAnDef OBJLstPtrTable_Terry_TimeOver, $00, $14, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_HIT_MULTIMID1
	mMvAnDef OBJLstPtrTable_Terry_HitMultigs, $04, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_HIT_MULTIGS
	mMvAnDef OBJLstPtrTable_Terry_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_THROW_END_G
	mMvAnDef OBJLstPtrTable_Terry_TimeOver, $00, $3C, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_THROW_START
	mMvAnDef OBJLstPtrTable_Terry_TimeOver, $00, $3C, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_THROW_ROTU
	mMvAnDef OBJLstPtrTable_Terry_ThrowRotL, $00, $3C, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_THROW_ROTL
	mMvAnDef OBJLstPtrTable_Terry_ThrowEndA, $00, $3C, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_THROW_ROTD
	mMvAnDef OBJLstPtrTable_Terry_HitMultigs, $00, $3C, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_THROW_ROTR
MoveAnimTbl_Andy:
	db $4C, $00, $00, $00, $00, $00, $00, $00 ;X ; MOVE_SHARED_NONE
	mMvAnDef OBJLstPtrTable_Andy_Idle, $0C, $0A, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_IDLE
	mMvAnDef OBJLstPtrTable_Andy_WalkF, $08, $01, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_WALK_F
	mMvAnDef OBJLstPtrTable_Andy_WalkB, $08, $02, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_WALK_B
	mMvAnDef OBJLstPtrTable_Andy_Crouch, $00, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_CROUCH
	mMvAnDef OBJLstPtrTable_Andy_JumpN, $1C, $02, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_JUMP_N
	mMvAnDef OBJLstPtrTable_Andy_JumpF, $1C, $02, $00, $00, $00 ;X ; BANK $08 ; MOVE_SHARED_JUMP_F
	mMvAnDef OBJLstPtrTable_Andy_JumpB, $1C, $02, $00, $00, $00 ;X ; BANK $08 ; MOVE_SHARED_JUMP_B
	mMvAnDef OBJLstPtrTable_Andy_BlockG, $00, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_BLOCK_G
	mMvAnDef OBJLstPtrTable_Andy_BlockC, $00, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_BLOCK_C
	mMvAnDef OBJLstPtrTable_Andy_BlockA, $00, $FF, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_BLOCK_A
	mMvAnDef OBJLstPtrTable_Andy_RunF, $08, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_RUN_F
	mMvAnDef OBJLstPtrTable_Andy_HopB, $08, $FF, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_HOP_B
	mMvAnDef OBJLstPtrTable_Andy_ChargeMeter, $04, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_CHARGEMETER
	mMvAnDef OBJLstPtrTable_Andy_Taunt, $18, $03, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_TAUNT
	mMvAnDef OBJLstPtrTable_Andy_RollF, $10, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_ROLL_F
	mMvAnDef OBJLstPtrTable_Andy_RollB, $10, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_ROLL_B
	mMvAnDef OBJLstPtrTable_Andy_Wakeup, $04, $02, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_WAKEUP
	mMvAnDef OBJLstPtrTable_Andy_Dizzy, $04, $0A, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_DIZZY
	mMvAnDef OBJLstPtrTable_Andy_WinA, $08, $08, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_WIN_A
	mMvAnDef OBJLstPtrTable_Andy_WinB, $04, $08, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_WIN_B
	mMvAnDef OBJLstPtrTable_Andy_TimeOver, $00, $01, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_LOST_TIMEOVER
	mMvAnDef OBJLstPtrTable_Andy_Taunt, $18, $08, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_INTRO
	mMvAnDef OBJLstPtrTable_Andy_Taunt, $18, $08, $00, $00, $00 ;X ; BANK $08 ; MOVE_SHARED_INTRO_SPEC
	mMvAnDef OBJLstPtrTable_Andy_PunchL, $08, $00, $04, HITTYPE_HIT_MID0, $00 ; BANK $08 ; MOVE_SHARED_PUNCH_L
	mMvAnDef OBJLstPtrTable_Andy_PunchH, $0C, $01, $04, HITTYPE_HIT_MID0, $00 ; BANK $08 ; MOVE_SHARED_PUNCH_H
	mMvAnDef OBJLstPtrTable_Andy_KickL, $08, $01, $08, HITTYPE_HIT_MID1, $00 ; BANK $08 ; MOVE_SHARED_KICK_L
	mMvAnDef OBJLstPtrTable_Andy_KickH, $0C, $02, $08, HITTYPE_HIT_MID0, $00 ; BANK $08 ; MOVE_SHARED_KICK_H
	mMvAnDef OBJLstPtrTable_Andy_PunchCL, $08, $00, $03, HITTYPE_HIT_MID1, $00 ; BANK $08 ; MOVE_SHARED_PUNCH_CL
	mMvAnDef OBJLstPtrTable_Andy_PunchCH, $10, $01, $03, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $08 ; MOVE_SHARED_PUNCH_CH
	mMvAnDef OBJLstPtrTable_Andy_KickCL, $08, $00, $06, HITTYPE_HIT_MID1, PF3_HITLOW ; BANK $08 ; MOVE_SHARED_KICK_CL
	mMvAnDef OBJLstPtrTable_Andy_KickCH, $10, $02, $06, HITTYPE_DROP_CH, PF3_HITLOW ; BANK $08 ; MOVE_SHARED_KICK_CH
	mMvAnDef OBJLstPtrTable_Andy_AttackG, $08, $03, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $08 ; MOVE_SHARED_ATTACK_G
	mMvAnDef OBJLstPtrTable_Andy_PunchA, $10, $01, $05, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $08 ; MOVE_SHARED_PUNCH_A
	mMvAnDef OBJLstPtrTable_Andy_KickA, $10, $01, $09, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $08 ; MOVE_SHARED_KICK_A
	mMvAnDef OBJLstPtrTable_Andy_AttackA, $10, $01, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_OVERHEAD ; BANK $08 ; MOVE_SHARED_ATTACK_A
	mMvAnDef OBJLstPtrTable_Andy_HiShoKenL, $0C, $01, $0A, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ; BANK $08 ; MOVE_ANDY_HI_SHO_KEN_L
	mMvAnDef OBJLstPtrTable_Andy_HiShoKenL, $0C, $03, $0A, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ; BANK $08 ; MOVE_ANDY_HI_SHO_KEN_H
	mMvAnDef OBJLstPtrTable_Andy_ZanEiKenL, $14, $01, $0A, HITTYPE_HIT_MID0, PF3_HEAVYHIT ; BANK $08 ; MOVE_ANDY_ZAN_EI_KEN_L
	mMvAnDef OBJLstPtrTable_Andy_ZanEiKenL, $14, $02, $0A, HITTYPE_HIT_MID0, PF3_HEAVYHIT ; BANK $08 ; MOVE_ANDY_ZAN_EI_KEN_H
	mMvAnDef OBJLstPtrTable_Andy_KuHaDanL, $20, $01, $04, HITTYPE_HIT_MID1, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $08 ; MOVE_ANDY_KU_HA_DAN_L
	mMvAnDef OBJLstPtrTable_Andy_KuHaDanL, $20, $01, $04, HITTYPE_HIT_MID1, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $08 ; MOVE_ANDY_KU_HA_DAN_H
	mMvAnDef OBJLstPtrTable_Andy_ShoRyuDanL, $18, $02, $09, HITTYPE_DROP_MAIN, PF3_LASTHIT ; BANK $08 ; MOVE_ANDY_SHO_RYU_DAN_L
	mMvAnDef OBJLstPtrTable_Andy_ShoRyuDanL, $18, $04, $09, HITTYPE_DROP_MAIN, PF3_LASTHIT ; BANK $08 ; MOVE_ANDY_SHO_RYU_DAN_H
	mMvAnDef OBJLstPtrTable_Andy_GekiHekiHaiSuiShoL, $10, $00, $0A, HITTYPE_HIT_MID1, PF3_HITLOW|PF3_OVERHEAD|PF3_LASTHIT ; BANK $08 ; MOVE_ANDY_GEKI_HEKI_HAI_SUI_SHO_L
	mMvAnDef OBJLstPtrTable_Andy_GekiHekiHaiSuiShoL, $10, $00, $0A, HITTYPE_HIT_MID1, PF3_HITLOW|PF3_OVERHEAD|PF3_LASTHIT ; BANK $08 ; MOVE_ANDY_GEKI_HEKI_HAI_SUI_SHO_H
	mMvAnDef OBJLstPtrTable_Andy_GeneiShiranuiL, $00, $FF, $00, $00, $00 ; BANK $08 ; MOVE_ANDY_GENEI_SHIRANUI_L
	mMvAnDef OBJLstPtrTable_Andy_GeneiShiranuiL, $00, $FF, $00, $00, $00 ; BANK $08 ; MOVE_ANDY_GENEI_SHIRANUI_H
	mMvAnDef OBJLstPtrTable_Andy_ShimoAgito, $08, $01, $0A, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $08 ; MOVE_ANDY_SHIMO_AGITO
	mMvAnDef OBJLstPtrTable_Andy_UwaAgito, $0C, $00, $0A, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $08 ; MOVE_ANDY_UWA_AGITO
	mMvAnDef OBJLstPtrTable_Andy_CHoReppaDanS, $18, $01, $14, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $08 ; MOVE_ANDY_CHO_REPPA_DAN_S
	mMvAnDef OBJLstPtrTable_Andy_CHoReppaDanD, $18, $01, $14, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE ; BANK $08 ; MOVE_ANDY_CHO_REPPA_DAN_D
	mMvAnDef OBJLstPtrTable_Andy_Idle, $18, $01, $14, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ;X ; BANK $08 ; MOVE_ANDY_SUPER_1_S
	mMvAnDef OBJLstPtrTable_Andy_Idle, $18, $01, $14, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ;X ; BANK $08 ; MOVE_ANDY_SUPER_1_D
	mMvAnDef OBJLstPtrTable_Andy_ThrowG, $14, $0A, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_THROW_G
	mMvAnDef OBJLstPtrTable_Andy_Idle, $00, $00, $00, $00, $00 ;X ; BANK $08 ; MOVE_SHARED_THROW_A
	mMvAnDef OBJLstPtrTable_Andy_BlockG, $00, $05, $00, $00, $00 ;X ; BANK $08 ; MOVE_SHARED_POST_BLOCKSTUN
	mMvAnDef OBJLstPtrTable_Andy_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_GUARDBREAK_G
	mMvAnDef OBJLstPtrTable_Andy_GuardBreakA, $04, $FF, $00, $00, $00 ;X ; BANK $08 ; MOVE_SHARED_GUARDBREAK_A
	mMvAnDef OBJLstPtrTable_Andy_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_HIT0MID
	mMvAnDef OBJLstPtrTable_Andy_TimeOver, $00, $05, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_HIT1MID
	mMvAnDef OBJLstPtrTable_Andy_Hitlow, $00, $05, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_HITLOW
	mMvAnDef OBJLstPtrTable_Andy_DropMain, $10, $05, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_DROP_MAIN
	mMvAnDef OBJLstPtrTable_Andy_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_THROW_END_A
	mMvAnDef OBJLstPtrTable_Andy_DropDbg, $00, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_DROP_DBG
	mMvAnDef OBJLstPtrTable_Andy_HitSwoopup, $18, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_HIT_SWOOPUP
	mMvAnDef OBJLstPtrTable_Andy_DropDbg, $08, $02, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_DROP_CH
	mMvAnDef OBJLstPtrTable_Andy_BackjumpRecA, $18, $02, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_BACKJUMP_REC_A
	mMvAnDef OBJLstPtrTable_Andy_GuardBreakG, $00, $14, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_HIT_MULTIMID0
	mMvAnDef OBJLstPtrTable_Andy_TimeOver, $00, $14, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_HIT_MULTIMID1
	mMvAnDef OBJLstPtrTable_Andy_HitMultigs, $04, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_HIT_MULTIGS
	mMvAnDef OBJLstPtrTable_Andy_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_THROW_END_G
	mMvAnDef OBJLstPtrTable_Andy_TimeOver, $00, $3C, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_THROW_START
	mMvAnDef OBJLstPtrTable_Andy_TimeOver, $00, $3C, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_THROW_ROTU
	mMvAnDef OBJLstPtrTable_Andy_ThrowRotL, $00, $3C, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_THROW_ROTL
	mMvAnDef OBJLstPtrTable_Andy_ThrowEndA, $00, $3C, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_THROW_ROTD
	mMvAnDef OBJLstPtrTable_Andy_HitMultigs, $00, $3C, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_THROW_ROTR
MoveAnimTbl_Ryo:
	db $4C, $00, $00, $00, $00, $00, $00, $00 ;X ; MOVE_SHARED_NONE
	mMvAnDef OBJLstPtrTable_Ryo_Idle, $18, $06, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_IDLE
	mMvAnDef OBJLstPtrTable_Ryo_WalkF, $0C, $02, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_WALK_F
	mMvAnDef OBJLstPtrTable_Ryo_WalkB, $0C, $03, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_WALK_B
	mMvAnDef OBJLstPtrTable_Ryo_Crouch, $00, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_CROUCH
	mMvAnDef OBJLstPtrTable_Ryo_JumpN, $1C, $02, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_JUMP_N
	mMvAnDef OBJLstPtrTable_Ryo_JumpF, $1C, $02, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_JUMP_F
	mMvAnDef OBJLstPtrTable_Ryo_JumpB, $1C, $02, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_JUMP_B
	mMvAnDef OBJLstPtrTable_Ryo_BlockG, $00, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_BLOCK_G
	mMvAnDef OBJLstPtrTable_Ryo_BlockC, $00, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_BLOCK_C
	mMvAnDef OBJLstPtrTable_Ryo_BlockA, $00, $FF, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_BLOCK_A
	mMvAnDef OBJLstPtrTable_Ryo_RunF, $08, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_RUN_F
	mMvAnDef OBJLstPtrTable_Ryo_HopB, $08, $FF, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_HOP_B
	mMvAnDef OBJLstPtrTable_Ryo_ChargeMeter, $04, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_CHARGEMETER
	mMvAnDef OBJLstPtrTable_Ryo_Taunt, $10, $01, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_TAUNT
	mMvAnDef OBJLstPtrTable_Ryo_RollF, $10, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_ROLL_F
	mMvAnDef OBJLstPtrTable_Ryo_RollB, $10, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_ROLL_B
	mMvAnDef OBJLstPtrTable_Ryo_Wakeup, $04, $02, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_WAKEUP
	mMvAnDef OBJLstPtrTable_Ryo_Dizzy, $04, $0A, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_DIZZY
	mMvAnDef OBJLstPtrTable_Ryo_WinA, $14, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_WIN_A
	mMvAnDef OBJLstPtrTable_Ryo_WinB, $28, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_WIN_B
	mMvAnDef OBJLstPtrTable_Ryo_TimeOver, $00, $01, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_LOST_TIMEOVER
	mMvAnDef OBJLstPtrTable_Ryo_Intro, $24, $01, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_INTRO
	mMvAnDef OBJLstPtrTable_Ryo_Intro, $24, $01, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_INTRO_SPEC
	mMvAnDef OBJLstPtrTable_Ryo_PunchL, $08, $00, $04, HITTYPE_HIT_MID0, $00 ; BANK $0A ; MOVE_SHARED_PUNCH_L
	mMvAnDef OBJLstPtrTable_Ryo_PunchH, $0C, $01, $04, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $0A ; MOVE_SHARED_PUNCH_H
	mMvAnDef OBJLstPtrTable_Ryo_KickL, $08, $01, $08, HITTYPE_HIT_MID1, $00 ; BANK $0A ; MOVE_SHARED_KICK_L
	mMvAnDef OBJLstPtrTable_Ryo_KickH, $0C, $02, $08, HITTYPE_HIT_MID0, $00 ; BANK $0A ; MOVE_SHARED_KICK_H
	mMvAnDef OBJLstPtrTable_Ryo_PunchCL, $08, $00, $03, HITTYPE_HIT_MID1, $00 ; BANK $0A ; MOVE_SHARED_PUNCH_CL
	mMvAnDef OBJLstPtrTable_Ryo_PunchCH, $0C, $01, $03, HITTYPE_HIT_MID1, $00 ; BANK $0A ; MOVE_SHARED_PUNCH_CH
	mMvAnDef OBJLstPtrTable_Ryo_KickCL, $08, $00, $06, HITTYPE_HIT_MID1, PF3_HITLOW ; BANK $0A ; MOVE_SHARED_KICK_CL
	mMvAnDef OBJLstPtrTable_Ryo_KickCH, $0C, $02, $06, HITTYPE_DROP_CH, PF3_HITLOW ; BANK $0A ; MOVE_SHARED_KICK_CH
	mMvAnDef OBJLstPtrTable_Ryo_AttackG, $0C, $01, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $0A ; MOVE_SHARED_ATTACK_G
	mMvAnDef OBJLstPtrTable_Ryo_PunchA, $10, $01, $05, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $0A ; MOVE_SHARED_PUNCH_A
	mMvAnDef OBJLstPtrTable_Ryo_KickA, $10, $01, $09, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $0A ; MOVE_SHARED_KICK_A
	mMvAnDef OBJLstPtrTable_Ryo_AttackA, $10, $01, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_OVERHEAD ; BANK $0A ; MOVE_SHARED_ATTACK_A
	mMvAnDef OBJLstPtrTable_Ryo_KoOuKenL, $08, $01, $0A, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_HALFSPEED ; BANK $0A ; MOVE_RYO_KO_OU_KEN_L
	mMvAnDef OBJLstPtrTable_Ryo_KoOuKenL, $08, $03, $0A, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_HALFSPEED ; BANK $0A ; MOVE_RYO_KO_OU_KEN_H
	mMvAnDef OBJLstPtrTable_Ryo_MouKoRaiJinGouL, $14, $01, $04, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $0A ; MOVE_RYO_MOU_KO_RAI_JIN_GOU_L
	mMvAnDef OBJLstPtrTable_Ryo_MouKoRaiJinGouL, $14, $04, $04, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $0A ; MOVE_RYO_MOU_KO_RAI_JIN_GOU_H
	mMvAnDef OBJLstPtrTable_Ryo_HienShippuKyakuL, $5C, $00, $04, HITTYPE_DROP_MAIN, PF3_LASTHIT ; BANK $0A ; MOVE_RYO_HIEN_SHIPPU_KYAKU_L
	mMvAnDef OBJLstPtrTable_Ryo_HienShippuKyakuL, $5C, $00, $04, HITTYPE_DROP_MAIN, PF3_LASTHIT ; BANK $0A ; MOVE_RYO_HIEN_SHIPPU_KYAKU_H
	mMvAnDef OBJLstPtrTable_Ryo_KoHouL, $18, $00, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $0A ; MOVE_RYO_KO_HOU_L
	mMvAnDef OBJLstPtrTable_Ryo_KoHouL, $18, $00, $06, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $0A ; MOVE_RYO_KO_HOU_H
	mMvAnDef OBJLstPtrTable_Ryo_KyokukenRyuRenbuKenL, $10, $01, $04, HITTYPE_HIT_MID1, PF3_HITLOW|PF3_OVERHEAD|PF3_LASTHIT ; BANK $0A ; MOVE_RYO_KYOKUKEN_RYU_RENBU_KEN_L
	mMvAnDef OBJLstPtrTable_Ryo_KyokukenRyuRenbuKenL, $10, $01, $04, HITTYPE_HIT_MID1, PF3_HITLOW|PF3_OVERHEAD|PF3_LASTHIT ; BANK $0A ; MOVE_RYO_KYOKUKEN_RYU_RENBU_KEN_H
	mMvAnDef OBJLstPtrTable_Ryo_KoHouEl, $18, $00, $02, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $0A ; MOVE_RYO_KO_HOU_EL
	mMvAnDef OBJLstPtrTable_Ryo_KoHouEl, $18, $00, $02, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $0A ; MOVE_RYO_KO_HOU_EH
	mMvAnDef OBJLstPtrTable_Ryo_Idle, $10, $01, $00, $00, $00 ;X ; BANK $0A ; MOVE_RYO_SPEC_6_L
	mMvAnDef OBJLstPtrTable_Ryo_Idle, $10, $01, $00, $00, $00 ;X ; BANK $0A ; MOVE_RYO_SPEC_6_H
	mMvAnDef OBJLstPtrTable_Ryo_RyuKoRanbuS, $44, $08, $01, HITTYPE_HIT_MULTI1, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $0A ; MOVE_RYO_RYU_KO_RANBU_S
	mMvAnDef OBJLstPtrTable_Ryo_RyuKoRanbuD, $44, $08, $01, HITTYPE_HIT_MULTI1, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $0A ; MOVE_RYO_RYU_KO_RANBU_D
	mMvAnDef OBJLstPtrTable_Ryo_HaohShokohKenS, $08, $01, $10, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_HALFSPEED ; BANK $0A ; MOVE_RYO_HAOH_SHOKOH_KEN_S
	mMvAnDef OBJLstPtrTable_Ryo_HaohShokohKenS, $08, $01, $14, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ; BANK $0A ; MOVE_RYO_HAOH_SHOKOH_KEN_D
	mMvAnDef OBJLstPtrTable_Ryo_ThrowG, $08, $0A, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_THROW_G
	mMvAnDef OBJLstPtrTable_Ryo_Idle, $00, $00, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_THROW_A
	mMvAnDef OBJLstPtrTable_Ryo_BlockG, $00, $05, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_POST_BLOCKSTUN
	mMvAnDef OBJLstPtrTable_Ryo_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_GUARDBREAK_G
	mMvAnDef OBJLstPtrTable_Ryo_GuardBreakA, $04, $FF, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_GUARDBREAK_A
	mMvAnDef OBJLstPtrTable_Ryo_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_HIT0MID
	mMvAnDef OBJLstPtrTable_Ryo_TimeOver, $00, $05, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_HIT1MID
	mMvAnDef OBJLstPtrTable_Ryo_Hitlow, $00, $05, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_HITLOW
	mMvAnDef OBJLstPtrTable_Ryo_DropMain, $10, $05, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_DROP_MAIN
	mMvAnDef OBJLstPtrTable_Ryo_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_THROW_END_A
	mMvAnDef OBJLstPtrTable_Ryo_DropDbg, $00, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_DROP_DBG
	mMvAnDef OBJLstPtrTable_Ryo_HitSwoopup, $18, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_HIT_SWOOPUP
	mMvAnDef OBJLstPtrTable_Ryo_DropDbg, $08, $02, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_DROP_CH
	mMvAnDef OBJLstPtrTable_Ryo_BackjumpRecA, $18, $02, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_BACKJUMP_REC_A
	mMvAnDef OBJLstPtrTable_Ryo_GuardBreakG, $00, $14, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_HIT_MULTIMID0
	mMvAnDef OBJLstPtrTable_Ryo_TimeOver, $00, $14, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_HIT_MULTIMID1
	mMvAnDef OBJLstPtrTable_Ryo_HitMultigs, $04, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_HIT_MULTIGS
	mMvAnDef OBJLstPtrTable_Ryo_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_THROW_END_G
	mMvAnDef OBJLstPtrTable_Ryo_TimeOver, $00, $3C, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_THROW_START
	mMvAnDef OBJLstPtrTable_Ryo_TimeOver, $00, $3C, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_THROW_ROTU
	mMvAnDef OBJLstPtrTable_Ryo_ThrowRotL, $00, $3C, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_THROW_ROTL
	mMvAnDef OBJLstPtrTable_Ryo_ThrowEndA, $00, $3C, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_THROW_ROTD
	mMvAnDef OBJLstPtrTable_Ryo_HitMultigs, $00, $3C, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_THROW_ROTR
MoveAnimTbl_Robert:
	db $4C, $00, $00, $00, $00, $00, $00, $00 ;X ; MOVE_SHARED_NONE
	mMvAnDef OBJLstPtrTable_Robert_Idle, $0C, $06, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_IDLE
	mMvAnDef OBJLstPtrTable_Robert_WalkF, $08, $01, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_WALK_F
	mMvAnDef OBJLstPtrTable_Robert_WalkB, $08, $02, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_WALK_B
	mMvAnDef OBJLstPtrTable_Robert_Crouch, $00, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_CROUCH
	mMvAnDef OBJLstPtrTable_Robert_JumpN, $1C, $02, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_JUMP_N
	mMvAnDef OBJLstPtrTable_Robert_JumpF, $1C, $02, $00, $00, $00 ;X ; BANK $07 ; MOVE_SHARED_JUMP_F
	mMvAnDef OBJLstPtrTable_Robert_JumpB, $1C, $02, $00, $00, $00 ;X ; BANK $07 ; MOVE_SHARED_JUMP_B
	mMvAnDef OBJLstPtrTable_Robert_BlockG, $00, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_BLOCK_G
	mMvAnDef OBJLstPtrTable_Robert_BlockC, $00, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_BLOCK_C
	mMvAnDef OBJLstPtrTable_Robert_BlockA, $00, $FF, $00, $00, $00 ;X ; BANK $07 ; MOVE_SHARED_BLOCK_A
	mMvAnDef OBJLstPtrTable_Robert_RunF, $0C, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_RUN_F
	mMvAnDef OBJLstPtrTable_Robert_HopB, $08, $FF, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_HOP_B
	mMvAnDef OBJLstPtrTable_Robert_ChargeMeter, $04, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_CHARGEMETER
	mMvAnDef OBJLstPtrTable_Robert_Taunt, $14, $03, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_TAUNT
	mMvAnDef OBJLstPtrTable_Robert_RollF, $10, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_ROLL_F
	mMvAnDef OBJLstPtrTable_Robert_RollB, $10, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_ROLL_B
	mMvAnDef OBJLstPtrTable_Robert_Wakeup, $04, $02, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_WAKEUP
	mMvAnDef OBJLstPtrTable_Robert_Dizzy, $04, $0A, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_DIZZY
	mMvAnDef OBJLstPtrTable_Robert_WinA, $18, $06, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_WIN_A
	mMvAnDef OBJLstPtrTable_Robert_WinB, $08, $0A, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_WIN_B
	mMvAnDef OBJLstPtrTable_Robert_TimeOver, $00, $01, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_LOST_TIMEOVER
	mMvAnDef OBJLstPtrTable_Robert_Intro, $1C, $05, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_INTRO
	mMvAnDef OBJLstPtrTable_Robert_Intro, $1C, $05, $00, $00, $00 ;X ; BANK $07 ; MOVE_SHARED_INTRO_SPEC
	mMvAnDef OBJLstPtrTable_Robert_PunchL, $08, $00, $04, HITTYPE_HIT_MID0, $00 ; BANK $07 ; MOVE_SHARED_PUNCH_L
	mMvAnDef OBJLstPtrTable_Robert_PunchH, $0C, $01, $04, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $07 ; MOVE_SHARED_PUNCH_H
	mMvAnDef OBJLstPtrTable_Robert_KickL, $08, $01, $08, HITTYPE_HIT_MID1, $00 ; BANK $07 ; MOVE_SHARED_KICK_L
	mMvAnDef OBJLstPtrTable_Robert_KickH, $0C, $02, $08, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $07 ; MOVE_SHARED_KICK_H
	mMvAnDef OBJLstPtrTable_Robert_PunchCL, $08, $00, $03, HITTYPE_HIT_MID1, $00 ; BANK $07 ; MOVE_SHARED_PUNCH_CL
	mMvAnDef OBJLstPtrTable_Robert_PunchCH, $0C, $01, $03, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $07 ; MOVE_SHARED_PUNCH_CH
	mMvAnDef OBJLstPtrTable_Robert_KickCL, $08, $00, $06, HITTYPE_HIT_MID1, PF3_HITLOW ; BANK $07 ; MOVE_SHARED_KICK_CL
	mMvAnDef OBJLstPtrTable_Robert_KickCH, $10, $02, $06, HITTYPE_DROP_CH, PF3_HITLOW ; BANK $07 ; MOVE_SHARED_KICK_CH
	mMvAnDef OBJLstPtrTable_Robert_AttackG, $10, $02, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $07 ; MOVE_SHARED_ATTACK_G
	mMvAnDef OBJLstPtrTable_Robert_PunchA, $10, $01, $05, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $07 ; MOVE_SHARED_PUNCH_A
	mMvAnDef OBJLstPtrTable_Robert_KickA, $10, $01, $09, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $07 ; MOVE_SHARED_KICK_A
	mMvAnDef OBJLstPtrTable_Robert_AttackA, $10, $01, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_OVERHEAD ; BANK $07 ; MOVE_SHARED_ATTACK_A
	mMvAnDef OBJLstPtrTable_Robert_RyuuGekiKenL, $28, $01, $0A, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_HALFSPEED ; BANK $07 ; MOVE_ROBERT_RYUU_GEKI_KEN_L
	mMvAnDef OBJLstPtrTable_Robert_RyuuGekiKenL, $28, $02, $0A, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_HALFSPEED ; BANK $07 ; MOVE_ROBERT_RYUU_GEKI_KEN_H
	mMvAnDef OBJLstPtrTable_Robert_HienShippuKyakuL, $18, $01, $04, HITTYPE_HIT_MID0, PF3_LASTHIT ; BANK $07 ; MOVE_ROBERT_HIEN_SHIPPU_KYAKU_L
	mMvAnDef OBJLstPtrTable_Robert_HienShippuKyakuL, $18, $03, $04, HITTYPE_HIT_MID0, PF3_LASTHIT ; BANK $07 ; MOVE_ROBERT_HIEN_SHIPPU_KYAKU_H
	mMvAnDef OBJLstPtrTable_Robert_HienRyuuShinKyaL, $20, $03, $08, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $07 ; MOVE_ROBERT_HIEN_RYUU_SHIN_KYA_L
	mMvAnDef OBJLstPtrTable_Robert_HienRyuuShinKyaL, $20, $01, $08, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $07 ; MOVE_ROBERT_HIEN_RYUU_SHIN_KYA_H
	mMvAnDef OBJLstPtrTable_Robert_RyuuGaL, $18, $00, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $07 ; MOVE_ROBERT_RYUU_GA_L
	mMvAnDef OBJLstPtrTable_Robert_RyuuGaL, $18, $00, $06, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $07 ; MOVE_ROBERT_RYUU_GA_H
	mMvAnDef OBJLstPtrTable_Robert_KyokugenRyuRanbuKyakuL, $10, $01, $04, HITTYPE_HIT_MID1, PF3_HITLOW|PF3_OVERHEAD|PF3_LASTHIT ; BANK $07 ; MOVE_ROBERT_KYOKUGEN_RYU_RANBU_KYAKU_L
	mMvAnDef OBJLstPtrTable_Robert_KyokugenRyuRanbuKyakuL, $10, $01, $04, HITTYPE_HIT_MID1, PF3_HITLOW|PF3_OVERHEAD|PF3_LASTHIT ; BANK $07 ; MOVE_ROBERT_KYOKUGEN_RYU_RANBU_KYAKU_H
	mMvAnDef OBJLstPtrTable_Robert_RyuuGaHiddenL, $18, $00, $02, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $07 ; MOVE_ROBERT_RYUU_GA_HIDDEN_L
	mMvAnDef OBJLstPtrTable_Robert_RyuuGaHiddenL, $18, $00, $02, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $07 ; MOVE_ROBERT_RYUU_GA_HIDDEN_H
	mMvAnDef OBJLstPtrTable_Robert_Idle, $00, $02, $0A, $00, $00 ;X ; BANK $07 ; MOVE_ROBERT_SPEC_6_L
	mMvAnDef OBJLstPtrTable_Robert_Idle, $00, $02, $0A, $00, $00 ;X ; BANK $07 ; MOVE_ROBERT_SPEC_6_H
	mMvAnDef OBJLstPtrTable_Robert_RyuKoRanbuS, $44, $08, $01, HITTYPE_HIT_MULTI1, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $07 ; MOVE_ROBERT_RYU_KO_RANBU_S
	mMvAnDef OBJLstPtrTable_Robert_RyuKoRanbuD, $44, $08, $01, HITTYPE_HIT_MULTI1, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $07 ; MOVE_ROBERT_RYU_KO_RANBU_D
	mMvAnDef OBJLstPtrTable_Robert_HaohShokohKenS, $08, $01, $10, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_HALFSPEED ; BANK $07 ; MOVE_ROBERT_HAOH_SHOKOH_KEN_S
	mMvAnDef OBJLstPtrTable_Robert_HaohShokohKenS, $08, $01, $14, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ; BANK $07 ; MOVE_ROBERT_HAOH_SHOKOH_KEN_D
	mMvAnDef OBJLstPtrTable_Robert_ThrowG, $14, $0A, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_THROW_G
	mMvAnDef OBJLstPtrTable_Robert_Idle, $00, $00, $00, $00, $00 ;X ; BANK $07 ; MOVE_SHARED_THROW_A
	mMvAnDef OBJLstPtrTable_Robert_BlockG, $00, $05, $00, $00, $00 ;X ; BANK $07 ; MOVE_SHARED_POST_BLOCKSTUN
	mMvAnDef OBJLstPtrTable_Robert_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_GUARDBREAK_G
	mMvAnDef OBJLstPtrTable_Robert_GuardBreakA, $04, $FF, $00, $00, $00 ;X ; BANK $07 ; MOVE_SHARED_GUARDBREAK_A
	mMvAnDef OBJLstPtrTable_Robert_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_HIT0MID
	mMvAnDef OBJLstPtrTable_Robert_TimeOver, $00, $05, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_HIT1MID
	mMvAnDef OBJLstPtrTable_Robert_Hitlow, $00, $05, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_HITLOW
	mMvAnDef OBJLstPtrTable_Robert_DropMain, $10, $05, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_DROP_MAIN
	mMvAnDef OBJLstPtrTable_Robert_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_THROW_END_A
	mMvAnDef OBJLstPtrTable_Robert_DropDbg, $00, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_DROP_DBG
	mMvAnDef OBJLstPtrTable_Robert_HitSwoopup, $18, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_HIT_SWOOPUP
	mMvAnDef OBJLstPtrTable_Robert_DropDbg, $08, $02, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_DROP_CH
	mMvAnDef OBJLstPtrTable_Robert_BackjumpRecA, $18, $02, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_BACKJUMP_REC_A
	mMvAnDef OBJLstPtrTable_Robert_GuardBreakG, $00, $14, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_HIT_MULTIMID0
	mMvAnDef OBJLstPtrTable_Robert_TimeOver, $00, $14, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_HIT_MULTIMID1
	mMvAnDef OBJLstPtrTable_Robert_HitMultigs, $04, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_HIT_MULTIGS
	mMvAnDef OBJLstPtrTable_Robert_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_THROW_END_G
	mMvAnDef OBJLstPtrTable_Robert_TimeOver, $00, $3C, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_THROW_START
	mMvAnDef OBJLstPtrTable_Robert_TimeOver, $00, $3C, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_THROW_ROTU
	mMvAnDef OBJLstPtrTable_Robert_ThrowRotL, $00, $3C, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_THROW_ROTL
	mMvAnDef OBJLstPtrTable_Robert_ThrowEndA, $00, $3C, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_THROW_ROTD
	mMvAnDef OBJLstPtrTable_Robert_HitMultigs, $00, $3C, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_THROW_ROTR
MoveAnimTbl_Athena:
	db $4C, $00, $00, $00, $00, $00, $00, $00 ;X ; MOVE_SHARED_NONE
	mMvAnDef OBJLstPtrTable_Athena_Idle, $0C, $02, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_IDLE
	mMvAnDef OBJLstPtrTable_Athena_WalkF, $08, $01, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_WALK_F
	mMvAnDef OBJLstPtrTable_Athena_WalkB, $08, $02, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_WALK_B
	mMvAnDef OBJLstPtrTable_Athena_Crouch, $00, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_CROUCH
	mMvAnDef OBJLstPtrTable_Athena_JumpN, $1C, $02, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_JUMP_N
	mMvAnDef OBJLstPtrTable_Athena_JumpF, $1C, $02, $00, $00, $00 ;X ; BANK $08 ; MOVE_SHARED_JUMP_F
	mMvAnDef OBJLstPtrTable_Athena_JumpB, $1C, $02, $00, $00, $00 ;X ; BANK $08 ; MOVE_SHARED_JUMP_B
	mMvAnDef OBJLstPtrTable_Athena_BlockG, $00, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_BLOCK_G
	mMvAnDef OBJLstPtrTable_Athena_BlockC, $00, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_BLOCK_C
	mMvAnDef OBJLstPtrTable_Athena_BlockA, $00, $FF, $00, $00, $00 ;X ; BANK $08 ; MOVE_SHARED_BLOCK_A
	mMvAnDef OBJLstPtrTable_Athena_RunF, $08, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_RUN_F
	mMvAnDef OBJLstPtrTable_Athena_HopB, $08, $FF, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_HOP_B
	mMvAnDef OBJLstPtrTable_Athena_ChargeMeter, $04, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_CHARGEMETER
	mMvAnDef OBJLstPtrTable_Athena_Taunt, $08, $04, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_TAUNT
	mMvAnDef OBJLstPtrTable_Athena_RollF, $10, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_ROLL_F
	mMvAnDef OBJLstPtrTable_Athena_RollB, $10, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_ROLL_B
	mMvAnDef OBJLstPtrTable_Athena_Wakeup, $04, $02, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_WAKEUP
	mMvAnDef OBJLstPtrTable_Athena_Dizzy, $04, $0A, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_DIZZY
	mMvAnDef OBJLstPtrTable_Athena_WinA, $18, $03, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_WIN_A
	mMvAnDef OBJLstPtrTable_Athena_WinB, $14, $03, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_WIN_B
	mMvAnDef OBJLstPtrTable_Athena_TimeOver, $00, $01, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_LOST_TIMEOVER
	mMvAnDef OBJLstPtrTable_Athena_Intro, $40, $3C, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_INTRO
	mMvAnDef OBJLstPtrTable_Athena_Intro, $40, $3C, $00, $00, $00 ;X ; BANK $08 ; MOVE_SHARED_INTRO_SPEC
	mMvAnDef OBJLstPtrTable_Athena_PunchL, $08, $00, $04, HITTYPE_HIT_MID0, $00 ; BANK $08 ; MOVE_SHARED_PUNCH_L
	mMvAnDef OBJLstPtrTable_Athena_PunchH, $08, $01, $04, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $08 ; MOVE_SHARED_PUNCH_H
	mMvAnDef OBJLstPtrTable_Athena_KickL, $08, $01, $08, HITTYPE_HIT_MID1, $00 ; BANK $08 ; MOVE_SHARED_KICK_L
	mMvAnDef OBJLstPtrTable_Athena_KickH, $08, $02, $08, HITTYPE_HIT_MID1, $00 ; BANK $08 ; MOVE_SHARED_KICK_H
	mMvAnDef OBJLstPtrTable_Athena_PunchCL, $08, $00, $03, HITTYPE_HIT_MID1, $00 ; BANK $08 ; MOVE_SHARED_PUNCH_CL
	mMvAnDef OBJLstPtrTable_Athena_PunchCH, $08, $01, $03, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $08 ; MOVE_SHARED_PUNCH_CH
	mMvAnDef OBJLstPtrTable_Athena_KickCL, $08, $00, $06, HITTYPE_HIT_MID1, PF3_HITLOW ; BANK $08 ; MOVE_SHARED_KICK_CL
	mMvAnDef OBJLstPtrTable_Athena_KickCH, $08, $02, $06, HITTYPE_DROP_CH, PF3_HITLOW ; BANK $08 ; MOVE_SHARED_KICK_CH
	mMvAnDef OBJLstPtrTable_Athena_AttackG, $08, $05, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $08 ; MOVE_SHARED_ATTACK_G
	mMvAnDef OBJLstPtrTable_Athena_PunchA, $10, $01, $05, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $08 ; MOVE_SHARED_PUNCH_A
	mMvAnDef OBJLstPtrTable_Athena_KickA, $10, $01, $09, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $08 ; MOVE_SHARED_KICK_A
	mMvAnDef OBJLstPtrTable_Athena_AttackA, $10, $01, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_OVERHEAD ; BANK $08 ; MOVE_SHARED_ATTACK_A
	mMvAnDef OBJLstPtrTable_Athena_PsychoBallL, $04, $01, $0A, HITTYPE_HIT_MID0, PF3_HEAVYHIT|PF3_HALFSPEED ; BANK $08 ; MOVE_ATHENA_PSYCHO_BALL_L
	mMvAnDef OBJLstPtrTable_Athena_PsychoBallL, $04, $03, $0A, HITTYPE_HIT_MID0, PF3_HEAVYHIT|PF3_HALFSPEED ; BANK $08 ; MOVE_ATHENA_PSYCHO_BALL_H
	mMvAnDef OBJLstPtrTable_Athena_PhoenixArrowL, $10, $01, $0A, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $08 ; MOVE_ATHENA_PHOENIX_ARROW_L
	mMvAnDef OBJLstPtrTable_Athena_PhoenixArrowL, $10, $01, $0A, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $08 ; MOVE_ATHENA_PHOENIX_ARROW_H
	mMvAnDef OBJLstPtrTable_Athena_PsychoReflectorL, $1C, $01, $04, HITTYPE_DROP_MAIN, PF3_LASTHIT|PF3_LIGHTHIT ; BANK $08 ; MOVE_ATHENA_PSYCHO_REFLECTOR_L
	mMvAnDef OBJLstPtrTable_Athena_PsychoReflectorL, $1C, $01, $04, HITTYPE_DROP_MAIN, PF3_LASTHIT|PF3_LIGHTHIT ; BANK $08 ; MOVE_ATHENA_PSYCHO_REFLECTOR_H
	mMvAnDef OBJLstPtrTable_Athena_PsychoSwordL, $10, $01, $09, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $08 ; MOVE_ATHENA_PSYCHO_SWORD_L
	mMvAnDef OBJLstPtrTable_Athena_PsychoSwordL, $10, $01, $09, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $08 ; MOVE_ATHENA_PSYCHO_SWORD_H
	mMvAnDef OBJLstPtrTable_Athena_PsychoTeleportL, $08, $01, $00, $00, $00 ; BANK $08 ; MOVE_ATHENA_PSYCHO_TELEPORT_L
	mMvAnDef OBJLstPtrTable_Athena_PsychoTeleportL, $08, $01, $00, $00, $00 ; BANK $08 ; MOVE_ATHENA_PSYCHO_TELEPORT_H
	mMvAnDef OBJLstPtrTable_Athena_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $08 ; MOVE_ATHENA_SPEC_5_L
	mMvAnDef OBJLstPtrTable_Athena_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $08 ; MOVE_ATHENA_SPEC_5_H
	mMvAnDef OBJLstPtrTable_Athena_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $08 ; MOVE_ATHENA_SPEC_6_L
	mMvAnDef OBJLstPtrTable_Athena_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $08 ; MOVE_ATHENA_SPEC_6_H
	mMvAnDef OBJLstPtrTable_Athena_ShiningCrystalBitGS, $14, $08, $14, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_HALFSPEED ; BANK $08 ; MOVE_ATHENA_SHINING_CRYSTAL_BIT_GS
	mMvAnDef OBJLstPtrTable_Athena_ShiningCrystalBitGD, $14, $08, $14, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_HALFSPEED|PF3_SUPERALT ; BANK $08 ; MOVE_ATHENA_SHINING_CRYSTAL_BIT_GD
	mMvAnDef OBJLstPtrTable_Athena_ShiningCrystalBitAS, $14, $08, $14, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_HALFSPEED ; BANK $08 ; MOVE_ATHENA_SHINING_CRYSTAL_BIT_AS
	mMvAnDef OBJLstPtrTable_Athena_ShiningCrystalBitAD, $14, $08, $14, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_HALFSPEED|PF3_SUPERALT ; BANK $08 ; MOVE_ATHENA_SHINING_CRYSTAL_BIT_AD
	mMvAnDef OBJLstPtrTable_Athena_ThrowG, $0C, $0A, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_THROW_G
	mMvAnDef OBJLstPtrTable_Athena_ThrowA, $0C, $0A, $00, $00, $00 ;X ; BANK $08 ; MOVE_SHARED_THROW_A
	mMvAnDef OBJLstPtrTable_Athena_BlockG, $00, $05, $00, $00, $00 ;X ; BANK $08 ; MOVE_SHARED_POST_BLOCKSTUN
	mMvAnDef OBJLstPtrTable_Athena_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_GUARDBREAK_G
	mMvAnDef OBJLstPtrTable_Athena_GuardBreakA, $04, $FF, $00, $00, $00 ;X ; BANK $08 ; MOVE_SHARED_GUARDBREAK_A
	mMvAnDef OBJLstPtrTable_Athena_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_HIT0MID
	mMvAnDef OBJLstPtrTable_Athena_TimeOver, $00, $05, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_HIT1MID
	mMvAnDef OBJLstPtrTable_Athena_Hitlow, $00, $05, $00, $00, $00 ;X ; BANK $08 ; MOVE_SHARED_HITLOW
	mMvAnDef OBJLstPtrTable_Athena_DropMain, $10, $05, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_DROP_MAIN
	mMvAnDef OBJLstPtrTable_Athena_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_THROW_END_A
	mMvAnDef OBJLstPtrTable_Athena_DropDbg, $00, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_DROP_DBG
	mMvAnDef OBJLstPtrTable_Athena_HitSwoopup, $18, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_HIT_SWOOPUP
	mMvAnDef OBJLstPtrTable_Athena_DropDbg, $08, $02, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_DROP_CH
	mMvAnDef OBJLstPtrTable_Athena_BackjumpRecA, $18, $02, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_BACKJUMP_REC_A
	mMvAnDef OBJLstPtrTable_Athena_GuardBreakG, $00, $14, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_HIT_MULTIMID0
	mMvAnDef OBJLstPtrTable_Athena_TimeOver, $00, $14, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_HIT_MULTIMID1
	mMvAnDef OBJLstPtrTable_Athena_HitMultigs, $04, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_HIT_MULTIGS
	mMvAnDef OBJLstPtrTable_Athena_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_THROW_END_G
	mMvAnDef OBJLstPtrTable_Athena_TimeOver, $00, $3C, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_THROW_START
	mMvAnDef OBJLstPtrTable_Athena_TimeOver, $00, $3C, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_THROW_ROTU
	mMvAnDef OBJLstPtrTable_Athena_ThrowRotL, $00, $3C, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_THROW_ROTL
	mMvAnDef OBJLstPtrTable_Athena_ThrowEndA, $00, $3C, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_THROW_ROTD
	mMvAnDef OBJLstPtrTable_Athena_HitMultigs, $00, $3C, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_THROW_ROTR
MoveAnimTbl_Mai:
	db $4C, $00, $00, $00, $00, $00, $00, $00 ;X ; MOVE_SHARED_NONE
	mMvAnDef OBJLstPtrTable_Mai_Idle, $1C, $04, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_IDLE
	mMvAnDef OBJLstPtrTable_Mai_WalkF, $08, $01, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_WALK_F
	mMvAnDef OBJLstPtrTable_Mai_WalkB, $08, $02, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_WALK_B
	mMvAnDef OBJLstPtrTable_Mai_Crouch, $00, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_CROUCH
	mMvAnDef OBJLstPtrTable_Mai_JumpN, $1C, $02, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_JUMP_N
	mMvAnDef OBJLstPtrTable_Mai_JumpN, $1C, $02, $00, $00, $00 ;X ; BANK $08 ; MOVE_SHARED_JUMP_F
	mMvAnDef OBJLstPtrTable_Mai_JumpB, $1C, $02, $00, $00, $00 ;X ; BANK $08 ; MOVE_SHARED_JUMP_B
	mMvAnDef OBJLstPtrTable_Mai_BlockG, $00, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_BLOCK_G
	mMvAnDef OBJLstPtrTable_Mai_BlockC, $00, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_BLOCK_C
	mMvAnDef OBJLstPtrTable_Mai_BlockA, $00, $FF, $00, $00, $00 ;X ; BANK $08 ; MOVE_SHARED_BLOCK_A
	mMvAnDef OBJLstPtrTable_Mai_RunF, $08, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_RUN_F
	mMvAnDef OBJLstPtrTable_Mai_HopB, $08, $FF, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_HOP_B
	mMvAnDef OBJLstPtrTable_Mai_ChargeMeter, $04, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_CHARGEMETER
	mMvAnDef OBJLstPtrTable_Mai_Taunt, $34, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_TAUNT
	mMvAnDef OBJLstPtrTable_Mai_RollF, $10, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_ROLL_F
	mMvAnDef OBJLstPtrTable_Mai_RollB, $10, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_ROLL_B
	mMvAnDef OBJLstPtrTable_Mai_Wakeup, $04, $02, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_WAKEUP
	mMvAnDef OBJLstPtrTable_Mai_Dizzy, $04, $0A, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_DIZZY
	mMvAnDef OBJLstPtrTable_Mai_WinA, $1C, $05, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_WIN_A
	mMvAnDef OBJLstPtrTable_Mai_WinB, $1C, $05, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_WIN_B
	mMvAnDef OBJLstPtrTable_Mai_TimeOver, $00, $01, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_LOST_TIMEOVER
	mMvAnDef OBJLstPtrTable_Mai_Intro, $20, $28, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_INTRO
	mMvAnDef OBJLstPtrTable_Mai_Intro, $20, $28, $00, $00, $00 ;X ; BANK $08 ; MOVE_SHARED_INTRO_SPEC
	mMvAnDef OBJLstPtrTable_Mai_PunchL, $08, $00, $04, HITTYPE_HIT_MID0, $00 ; BANK $08 ; MOVE_SHARED_PUNCH_L
	mMvAnDef OBJLstPtrTable_Mai_PunchH, $0C, $01, $04, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $08 ; MOVE_SHARED_PUNCH_H
	mMvAnDef OBJLstPtrTable_Mai_KickL, $08, $01, $08, HITTYPE_HIT_MID1, $00 ; BANK $08 ; MOVE_SHARED_KICK_L
	mMvAnDef OBJLstPtrTable_Mai_KickH, $08, $02, $08, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $08 ; MOVE_SHARED_KICK_H
	mMvAnDef OBJLstPtrTable_Mai_PunchCL, $08, $00, $03, HITTYPE_HIT_MID1, $00 ; BANK $08 ; MOVE_SHARED_PUNCH_CL
	mMvAnDef OBJLstPtrTable_Mai_PunchCH, $08, $01, $03, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $08 ; MOVE_SHARED_PUNCH_CH
	mMvAnDef OBJLstPtrTable_Mai_KickCL, $08, $00, $06, HITTYPE_HIT_MID1, PF3_HITLOW ; BANK $08 ; MOVE_SHARED_KICK_CL
	mMvAnDef OBJLstPtrTable_Mai_KickCH, $08, $02, $06, HITTYPE_DROP_CH, PF3_HITLOW ; BANK $08 ; MOVE_SHARED_KICK_CH
	mMvAnDef OBJLstPtrTable_Mai_AttackG, $08, $02, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $08 ; MOVE_SHARED_ATTACK_G
	mMvAnDef OBJLstPtrTable_Mai_PunchA, $10, $01, $05, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $08 ; MOVE_SHARED_PUNCH_A
	mMvAnDef OBJLstPtrTable_Mai_KickA, $10, $01, $09, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $08 ; MOVE_SHARED_KICK_A
	mMvAnDef OBJLstPtrTable_Mai_AttackA, $10, $01, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_OVERHEAD ; BANK $08 ; MOVE_SHARED_ATTACK_A
	mMvAnDef OBJLstPtrTable_Mai_KaCHoSenL, $10, $01, $0A, HITTYPE_HIT_MID0, PF3_HEAVYHIT|PF3_HALFSPEED ; BANK $08 ; MOVE_MAI_KA_CHO_SEN_L
	mMvAnDef OBJLstPtrTable_Mai_KaCHoSenL, $10, $03, $0A, HITTYPE_HIT_MID0, PF3_HEAVYHIT|PF3_HALFSPEED ; BANK $08 ; MOVE_MAI_KA_CHO_SEN_H
	mMvAnDef OBJLstPtrTable_Mai_HissatsuShinobibachiL, $10, $01, $0A, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $08 ; MOVE_MAI_HISSATSU_SHINOBIBACHI_L
	mMvAnDef OBJLstPtrTable_Mai_HissatsuShinobibachiL, $10, $03, $0A, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $08 ; MOVE_MAI_HISSATSU_SHINOBIBACHI_H
	mMvAnDef OBJLstPtrTable_Mai_RyuEnBuL, $10, $00, $04, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $08 ; MOVE_MAI_RYU_EN_BU_L
	mMvAnDef OBJLstPtrTable_Mai_RyuEnBuL, $10, $00, $04, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $08 ; MOVE_MAI_RYU_EN_BU_H
	mMvAnDef OBJLstPtrTable_Mai_HishoRyuEnJinL, $18, $00, $09, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $08 ; MOVE_MAI_HISHO_RYU_EN_JIN_L
	mMvAnDef OBJLstPtrTable_Mai_HishoRyuEnJinL, $18, $00, $09, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $08 ; MOVE_MAI_HISHO_RYU_EN_JIN_H
	mMvAnDef OBJLstPtrTable_Mai_CHijouMusasabiL, $28, $01, $09, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $08 ; MOVE_MAI_CHIJOU_MUSASABI_L
	mMvAnDef OBJLstPtrTable_Mai_CHijouMusasabiL, $28, $04, $09, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $08 ; MOVE_MAI_CHIJOU_MUSASABI_H
	mMvAnDef OBJLstPtrTable_Mai_KuuchuuMusasabiL, $08, $01, $09, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $08 ; MOVE_MAI_KUUCHUU_MUSASABI_L
	mMvAnDef OBJLstPtrTable_Mai_KuuchuuMusasabiL, $08, $04, $09, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $08 ; MOVE_MAI_KUUCHUU_MUSASABI_H
	mMvAnDef OBJLstPtrTable_Mai_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $08 ; MOVE_MAI_SPEC_6_L
	mMvAnDef OBJLstPtrTable_Mai_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $08 ; MOVE_MAI_SPEC_6_H
	mMvAnDef OBJLstPtrTable_Mai_CHoHissatsuShinobibachiS, $18, $00, $0A, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $08 ; MOVE_MAI_CHO_HISSATSU_SHINOBIBACHI_S
	mMvAnDef OBJLstPtrTable_Mai_CHoHissatsuShinobibachiD, $18, $00, $0A, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $08 ; MOVE_MAI_CHO_HISSATSU_SHINOBIBACHI_D
	mMvAnDef OBJLstPtrTable_Mai_Idle, $18, $02, $0A, HITTYPE_HIT_MID1, $00 ;X ; BANK $08 ; MOVE_MAI_SUPER_1_S
	mMvAnDef OBJLstPtrTable_Mai_Idle, $18, $02, $0A, HITTYPE_HIT_MID1, $00 ;X ; BANK $08 ; MOVE_MAI_SUPER_1_D
	mMvAnDef OBJLstPtrTable_Mai_ThrowG, $0C, $0A, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_THROW_G
	mMvAnDef OBJLstPtrTable_Mai_ThrowA, $08, $0A, $00, $00, $00 ;X ; BANK $08 ; MOVE_SHARED_THROW_A
	mMvAnDef OBJLstPtrTable_Mai_BlockG, $00, $05, $00, $00, $00 ;X ; BANK $08 ; MOVE_SHARED_POST_BLOCKSTUN
	mMvAnDef OBJLstPtrTable_Mai_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_GUARDBREAK_G
	mMvAnDef OBJLstPtrTable_Mai_GuardBreakA, $04, $FF, $00, $00, $00 ;X ; BANK $08 ; MOVE_SHARED_GUARDBREAK_A
	mMvAnDef OBJLstPtrTable_Mai_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_HIT0MID
	mMvAnDef OBJLstPtrTable_Mai_TimeOver, $00, $05, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_HIT1MID
	mMvAnDef OBJLstPtrTable_Mai_Hitlow, $00, $05, $00, $00, $00 ;X ; BANK $08 ; MOVE_SHARED_HITLOW
	mMvAnDef OBJLstPtrTable_Mai_DropMain, $10, $05, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_DROP_MAIN
	mMvAnDef OBJLstPtrTable_Mai_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_THROW_END_A
	mMvAnDef OBJLstPtrTable_Mai_DropDbg, $00, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_DROP_DBG
	mMvAnDef OBJLstPtrTable_Mai_HitSwoopup, $18, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_HIT_SWOOPUP
	mMvAnDef OBJLstPtrTable_Mai_DropDbg, $08, $02, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_DROP_CH
	mMvAnDef OBJLstPtrTable_Mai_BackjumpRecA, $18, $02, $00, $00, $00 ;X ; BANK $08 ; MOVE_SHARED_BACKJUMP_REC_A
	mMvAnDef OBJLstPtrTable_Mai_GuardBreakG, $00, $14, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_HIT_MULTIMID0
	mMvAnDef OBJLstPtrTable_Mai_TimeOver, $00, $14, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_HIT_MULTIMID1
	mMvAnDef OBJLstPtrTable_Mai_HitMultigs, $04, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_HIT_MULTIGS
	mMvAnDef OBJLstPtrTable_Mai_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_THROW_END_G
	mMvAnDef OBJLstPtrTable_Mai_TimeOver, $00, $3C, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_THROW_START
	mMvAnDef OBJLstPtrTable_Mai_TimeOver, $00, $3C, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_THROW_ROTU
	mMvAnDef OBJLstPtrTable_Mai_ThrowRotL, $00, $3C, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_THROW_ROTL
	mMvAnDef OBJLstPtrTable_Mai_ThrowEndA, $00, $3C, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_THROW_ROTD
	mMvAnDef OBJLstPtrTable_Mai_HitMultigs, $00, $3C, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_THROW_ROTR
MoveAnimTbl_Leona:
	db $4C, $00, $00, $00, $00, $00, $00, $00 ;X ; MOVE_SHARED_NONE
	mMvAnDef OBJLstPtrTable_Leona_Idle, $0C, $06, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_IDLE
	mMvAnDef OBJLstPtrTable_Leona_WalkF, $0C, $01, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_WALK_F
	mMvAnDef OBJLstPtrTable_Leona_WalkB, $0C, $02, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_WALK_B
	mMvAnDef OBJLstPtrTable_Leona_Crouch, $00, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_CROUCH
	mMvAnDef OBJLstPtrTable_Leona_JumpN, $1C, $02, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_JUMP_N
	mMvAnDef OBJLstPtrTable_Leona_JumpN, $1C, $02, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_JUMP_F
	mMvAnDef OBJLstPtrTable_Leona_JumpB, $1C, $02, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_JUMP_B
	mMvAnDef OBJLstPtrTable_Leona_BlockG, $00, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_BLOCK_G
	mMvAnDef OBJLstPtrTable_Leona_BlockC, $00, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_BLOCK_C
	mMvAnDef OBJLstPtrTable_Leona_BlockA, $00, $FF, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_BLOCK_A
	mMvAnDef OBJLstPtrTable_Leona_RunF, $0C, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_RUN_F
	mMvAnDef OBJLstPtrTable_Leona_HopB, $08, $FF, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_HOP_B
	mMvAnDef OBJLstPtrTable_Leona_ChargeMeter, $04, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_CHARGEMETER
	mMvAnDef OBJLstPtrTable_Leona_Taunt, $2C, $03, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_TAUNT
	mMvAnDef OBJLstPtrTable_Leona_RollF, $10, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_ROLL_F
	mMvAnDef OBJLstPtrTable_Leona_RollB, $10, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_ROLL_B
	mMvAnDef OBJLstPtrTable_Leona_Wakeup, $04, $02, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_WAKEUP
	mMvAnDef OBJLstPtrTable_Leona_Dizzy, $04, $0A, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_DIZZY
	mMvAnDef OBJLstPtrTable_Leona_WinA, $10, $08, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_WIN_A
	mMvAnDef OBJLstPtrTable_Leona_WinB, $08, $0A, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_WIN_B
	mMvAnDef OBJLstPtrTable_Leona_TimeOver, $00, $01, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_LOST_TIMEOVER
	mMvAnDef OBJLstPtrTable_Leona_Intro, $1C, $3C, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_INTRO
	mMvAnDef OBJLstPtrTable_Leona_Intro, $1C, $3C, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_INTRO_SPEC
	mMvAnDef OBJLstPtrTable_Leona_PunchL, $08, $00, $04, HITTYPE_HIT_MID0, $00 ; BANK $0A ; MOVE_SHARED_PUNCH_L
	mMvAnDef OBJLstPtrTable_Leona_PunchH, $0C, $01, $04, HITTYPE_HIT_MID0, $00 ; BANK $0A ; MOVE_SHARED_PUNCH_H
	mMvAnDef OBJLstPtrTable_Leona_KickL, $08, $01, $08, HITTYPE_HIT_MID1, PF3_HITLOW ; BANK $0A ; MOVE_SHARED_KICK_L
	mMvAnDef OBJLstPtrTable_Leona_KickH, $10, $02, $08, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $0A ; MOVE_SHARED_KICK_H
	mMvAnDef OBJLstPtrTable_Leona_PunchCL, $08, $00, $03, HITTYPE_HIT_MID1, $00 ; BANK $0A ; MOVE_SHARED_PUNCH_CL
	mMvAnDef OBJLstPtrTable_Leona_PunchCH, $0C, $01, $03, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $0A ; MOVE_SHARED_PUNCH_CH
	mMvAnDef OBJLstPtrTable_Leona_KickCL, $08, $00, $06, HITTYPE_HIT_MID1, PF3_HITLOW ; BANK $0A ; MOVE_SHARED_KICK_CL
	mMvAnDef OBJLstPtrTable_Leona_KickCH, $0C, $02, $06, HITTYPE_DROP_CH, PF3_HITLOW ; BANK $0A ; MOVE_SHARED_KICK_CH
	mMvAnDef OBJLstPtrTable_Leona_AttackG, $0C, $03, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $0A ; MOVE_SHARED_ATTACK_G
	mMvAnDef OBJLstPtrTable_Leona_PunchA, $10, $01, $05, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $0A ; MOVE_SHARED_PUNCH_A
	mMvAnDef OBJLstPtrTable_Leona_KickA, $10, $01, $09, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $0A ; MOVE_SHARED_KICK_A
	mMvAnDef OBJLstPtrTable_Leona_AttackA, $10, $01, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_OVERHEAD ; BANK $0A ; MOVE_SHARED_ATTACK_A
	mMvAnDef OBJLstPtrTable_Leona_BalticLauncherL, $14, $1E, $01, HITTYPE_DROP_MAIN, PF3_LASTHIT|PF3_LIGHTHIT ; BANK $0A ; MOVE_LEONA_BALTIC_LAUNCHER_L
	mMvAnDef OBJLstPtrTable_Leona_BalticLauncherH, $14, $10, $01, HITTYPE_DROP_MAIN, PF3_LASTHIT|PF3_LIGHTHIT ; BANK $0A ; MOVE_LEONA_BALTIC_LAUNCHER_H
	mMvAnDef OBJLstPtrTable_Leona_GrandSabreL, $14, $01, $0A, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $0A ; MOVE_LEONA_GRAND_SABRE_L
	mMvAnDef OBJLstPtrTable_Leona_GrandSabreL, $14, $01, $0A, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $0A ; MOVE_LEONA_GRAND_SABRE_H
	mMvAnDef OBJLstPtrTable_Leona_XCaliburL, $20, $01, $04, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $0A ; MOVE_LEONA_X_CALIBUR_L
	mMvAnDef OBJLstPtrTable_Leona_XCaliburL, $20, $01, $04, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $0A ; MOVE_LEONA_X_CALIBUR_H
	mMvAnDef OBJLstPtrTable_Leona_MoonSlasherL, $18, $02, $09, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $0A ; MOVE_LEONA_MOON_SLASHER_L
	mMvAnDef OBJLstPtrTable_Leona_MoonSlasherL, $18, $04, $09, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $0A ; MOVE_LEONA_MOON_SLASHER_H
	mMvAnDef OBJLstPtrTable_Leona_Idle, $14, $FF, $09, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_LASTHIT ;X ; BANK $0A ; MOVE_OLEONA_STORM_BRINGER_L
	mMvAnDef OBJLstPtrTable_Leona_Idle, $14, $FF, $09, HITTYPE_DROP_MAIN, PF3_LASTHIT ;X ; BANK $0A ; MOVE_OLEONA_STORM_BRINGER_H
	mMvAnDef OBJLstPtrTable_Leona_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $0A ; MOVE_LEONA_SPEC_5_L
	mMvAnDef OBJLstPtrTable_Leona_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $0A ; MOVE_LEONA_SPEC_5_H
	mMvAnDef OBJLstPtrTable_Leona_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $0A ; MOVE_LEONA_SPEC_6_L
	mMvAnDef OBJLstPtrTable_Leona_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $0A ; MOVE_LEONA_SPEC_6_H
	mMvAnDef OBJLstPtrTable_Leona_VSlasherS, $18, $01, $02, HITTYPE_DROP_MAIN, PF3_LASTHIT|PF3_LIGHTHIT ; BANK $0A ; MOVE_LEONA_V_SLASHER_S
	mMvAnDef OBJLstPtrTable_Leona_VSlasherS, $18, $01, $09, HITTYPE_DROP_MAIN, PF3_LASTHIT|PF3_HALFSPEED|PF3_LIGHTHIT ; BANK $0A ; MOVE_LEONA_V_SLASHER_D
	mMvAnDef OBJLstPtrTable_Leona_Idle, $18, $01, $14, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ;X ; BANK $0A ; MOVE_OLEONA_SUPER_MOON_SLASHER_S
	mMvAnDef OBJLstPtrTable_Leona_Idle, $18, $01, $14, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ;X ; BANK $0A ; MOVE_OLEONA_SUPER_MOON_SLASHER_D
	mMvAnDef OBJLstPtrTable_Leona_ThrowG, $14, $0A, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_THROW_G
	mMvAnDef OBJLstPtrTable_Leona_ThrowA, $00, $00, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_THROW_A
	mMvAnDef OBJLstPtrTable_Leona_BlockG, $00, $05, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_POST_BLOCKSTUN
	mMvAnDef OBJLstPtrTable_Leona_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_GUARDBREAK_G
	mMvAnDef OBJLstPtrTable_Leona_GuardBreakA, $04, $FF, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_GUARDBREAK_A
	mMvAnDef OBJLstPtrTable_Leona_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_HIT0MID
	mMvAnDef OBJLstPtrTable_Leona_TimeOver, $00, $05, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_HIT1MID
	mMvAnDef OBJLstPtrTable_Leona_Hitlow, $00, $05, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_HITLOW
	mMvAnDef OBJLstPtrTable_Leona_DropMain, $10, $05, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_DROP_MAIN
	mMvAnDef OBJLstPtrTable_Leona_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_THROW_END_A
	mMvAnDef OBJLstPtrTable_Leona_DropDbg, $00, $00, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_DROP_DBG
	mMvAnDef OBJLstPtrTable_Leona_HitSwoopup, $18, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_HIT_SWOOPUP
	mMvAnDef OBJLstPtrTable_Leona_DropDbg, $08, $02, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_DROP_CH
	mMvAnDef OBJLstPtrTable_Leona_BackjumpRecA, $18, $02, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_BACKJUMP_REC_A
	mMvAnDef OBJLstPtrTable_Leona_GuardBreakG, $00, $14, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_HIT_MULTIMID0
	mMvAnDef OBJLstPtrTable_Leona_TimeOver, $00, $14, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_HIT_MULTIMID1
	mMvAnDef OBJLstPtrTable_Leona_HitMultigs, $04, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_HIT_MULTIGS
	mMvAnDef OBJLstPtrTable_Leona_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_THROW_END_G
	mMvAnDef OBJLstPtrTable_Leona_TimeOver, $00, $3C, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_THROW_START
	mMvAnDef OBJLstPtrTable_Leona_TimeOver, $00, $3C, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_THROW_ROTU
	mMvAnDef OBJLstPtrTable_Leona_ThrowRotL, $00, $3C, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_THROW_ROTL
	mMvAnDef OBJLstPtrTable_Leona_ThrowEndA, $00, $3C, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_THROW_ROTD
	mMvAnDef OBJLstPtrTable_Leona_HitMultigs, $00, $3C, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_THROW_ROTR
MoveAnimTbl_OLeona:
	db $4C, $00, $00, $00, $00, $00, $00, $00 ;X ; MOVE_SHARED_NONE
	mMvAnDef OBJLstPtrTable_OLeona_Idle, $0C, $06, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_IDLE
	mMvAnDef OBJLstPtrTable_OLeona_WalkF, $0C, $01, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_WALK_F
	mMvAnDef OBJLstPtrTable_OLeona_WalkB, $0C, $02, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_WALK_B
	mMvAnDef OBJLstPtrTable_Leona_Crouch, $00, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_CROUCH
	mMvAnDef OBJLstPtrTable_Leona_JumpN, $1C, $02, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_JUMP_N
	mMvAnDef OBJLstPtrTable_Leona_JumpN, $1C, $02, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_JUMP_F
	mMvAnDef OBJLstPtrTable_Leona_JumpB, $1C, $02, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_JUMP_B
	mMvAnDef OBJLstPtrTable_Leona_BlockG, $00, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_BLOCK_G
	mMvAnDef OBJLstPtrTable_Leona_BlockC, $00, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_BLOCK_C
	mMvAnDef OBJLstPtrTable_Leona_BlockA, $00, $FF, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_BLOCK_A
	mMvAnDef OBJLstPtrTable_Leona_RunF, $0C, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_RUN_F
	mMvAnDef OBJLstPtrTable_Leona_HopB, $08, $FF, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_HOP_B
	mMvAnDef OBJLstPtrTable_OLeona_ChargeMeter, $04, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_CHARGEMETER
	mMvAnDef OBJLstPtrTable_OLeona_Taunt, $0C, $03, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_TAUNT
	mMvAnDef OBJLstPtrTable_Leona_RollF, $10, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_ROLL_F
	mMvAnDef OBJLstPtrTable_Leona_RollB, $10, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_ROLL_B
	mMvAnDef OBJLstPtrTable_Leona_Wakeup, $04, $02, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_WAKEUP
	mMvAnDef OBJLstPtrTable_Leona_Dizzy, $04, $0A, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_DIZZY
	mMvAnDef OBJLstPtrTable_OLeona_WinA, $14, $08, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_WIN_A
	mMvAnDef OBJLstPtrTable_OLeona_WinB, $1C, $05, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_WIN_B
	mMvAnDef OBJLstPtrTable_Leona_TimeOver, $00, $01, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_LOST_TIMEOVER
	mMvAnDef OBJLstPtrTable_OLeona_Intro, $10, $3C, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_INTRO
	mMvAnDef OBJLstPtrTable_OLeona_Intro, $10, $3C, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_INTRO_SPEC
	mMvAnDef OBJLstPtrTable_Leona_PunchL, $08, $00, $04, HITTYPE_HIT_MID0, $00 ; BANK $0A ; MOVE_SHARED_PUNCH_L
	mMvAnDef OBJLstPtrTable_Leona_PunchH, $0C, $01, $04, HITTYPE_HIT_MID0, $00 ; BANK $0A ; MOVE_SHARED_PUNCH_H
	mMvAnDef OBJLstPtrTable_Leona_KickL, $08, $01, $08, HITTYPE_HIT_MID1, PF3_HITLOW ; BANK $0A ; MOVE_SHARED_KICK_L
	mMvAnDef OBJLstPtrTable_Leona_KickH, $10, $02, $08, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $0A ; MOVE_SHARED_KICK_H
	mMvAnDef OBJLstPtrTable_Leona_PunchCL, $08, $00, $03, HITTYPE_HIT_MID1, $00 ; BANK $0A ; MOVE_SHARED_PUNCH_CL
	mMvAnDef OBJLstPtrTable_Leona_PunchCH, $0C, $01, $03, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $0A ; MOVE_SHARED_PUNCH_CH
	mMvAnDef OBJLstPtrTable_Leona_KickCL, $08, $00, $06, HITTYPE_HIT_MID1, PF3_HITLOW ; BANK $0A ; MOVE_SHARED_KICK_CL
	mMvAnDef OBJLstPtrTable_Leona_KickCH, $0C, $02, $06, HITTYPE_DROP_CH, PF3_HITLOW ; BANK $0A ; MOVE_SHARED_KICK_CH
	mMvAnDef OBJLstPtrTable_Leona_AttackG, $0C, $03, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $0A ; MOVE_SHARED_ATTACK_G
	mMvAnDef OBJLstPtrTable_Leona_PunchA, $10, $01, $05, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $0A ; MOVE_SHARED_PUNCH_A
	mMvAnDef OBJLstPtrTable_Leona_KickA, $10, $01, $09, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $0A ; MOVE_SHARED_KICK_A
	mMvAnDef OBJLstPtrTable_Leona_AttackA, $10, $01, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_OVERHEAD ; BANK $0A ; MOVE_SHARED_ATTACK_A
	mMvAnDef OBJLstPtrTable_Leona_BalticLauncherL, $14, $1E, $01, HITTYPE_DROP_MAIN, PF3_LASTHIT|PF3_LIGHTHIT ; BANK $0A ; MOVE_LEONA_BALTIC_LAUNCHER_L
	mMvAnDef OBJLstPtrTable_Leona_BalticLauncherH, $14, $10, $01, HITTYPE_DROP_MAIN, PF3_LASTHIT|PF3_LIGHTHIT ; BANK $0A ; MOVE_LEONA_BALTIC_LAUNCHER_H
	mMvAnDef OBJLstPtrTable_Leona_GrandSabreL, $14, $01, $0A, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $0A ; MOVE_LEONA_GRAND_SABRE_L
	mMvAnDef OBJLstPtrTable_Leona_GrandSabreL, $14, $01, $0A, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $0A ; MOVE_LEONA_GRAND_SABRE_H
	mMvAnDef OBJLstPtrTable_Leona_XCaliburL, $20, $01, $04, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $0A ; MOVE_LEONA_X_CALIBUR_L
	mMvAnDef OBJLstPtrTable_Leona_XCaliburL, $20, $01, $04, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $0A ; MOVE_LEONA_X_CALIBUR_H
	mMvAnDef OBJLstPtrTable_Leona_MoonSlasherL, $18, $02, $09, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $0A ; MOVE_LEONA_MOON_SLASHER_L
	mMvAnDef OBJLstPtrTable_Leona_MoonSlasherL, $18, $04, $09, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $0A ; MOVE_LEONA_MOON_SLASHER_H
	mMvAnDef OBJLstPtrTable_OLeona_StormBringerL, $14, $0A, $01, HITTYPE_HIT_MULTI1, PF3_LIGHTHIT ; BANK $0A ; MOVE_OLEONA_STORM_BRINGER_L
	mMvAnDef OBJLstPtrTable_OLeona_StormBringerL, $14, $0A, $01, HITTYPE_HIT_MULTI1, PF3_LIGHTHIT ; BANK $0A ; MOVE_OLEONA_STORM_BRINGER_H
	mMvAnDef OBJLstPtrTable_OLeona_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $0A ; MOVE_LEONA_SPEC_5_L
	mMvAnDef OBJLstPtrTable_OLeona_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $0A ; MOVE_LEONA_SPEC_5_H
	mMvAnDef OBJLstPtrTable_OLeona_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $0A ; MOVE_LEONA_SPEC_6_L
	mMvAnDef OBJLstPtrTable_OLeona_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $0A ; MOVE_LEONA_SPEC_6_H
	mMvAnDef OBJLstPtrTable_OLeona_LeonaVSlasherS, $18, $01, $02, HITTYPE_DROP_MAIN, PF3_LASTHIT|PF3_LIGHTHIT ; BANK $0A ; MOVE_LEONA_V_SLASHER_S
	mMvAnDef OBJLstPtrTable_OLeona_LeonaVSlasherS, $18, $01, $09, HITTYPE_DROP_MAIN, PF3_LASTHIT|PF3_HALFSPEED|PF3_LIGHTHIT ; BANK $0A ; MOVE_LEONA_V_SLASHER_D
	mMvAnDef OBJLstPtrTable_OLeona_SuperMoonSlasherS, $18, $01, $02, HITTYPE_HIT_MULTI1, PF3_HEAVYHIT ; BANK $0A ; MOVE_OLEONA_SUPER_MOON_SLASHER_S
	mMvAnDef OBJLstPtrTable_OLeona_SuperMoonSlasherS, $18, $01, $02, HITTYPE_HIT_MULTI1, PF3_HEAVYHIT ; BANK $0A ; MOVE_OLEONA_SUPER_MOON_SLASHER_D
	mMvAnDef OBJLstPtrTable_OLeona_ThrowG, $14, $0A, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_THROW_G
	mMvAnDef OBJLstPtrTable_Leona_ThrowA, $00, $00, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_THROW_A
	mMvAnDef OBJLstPtrTable_Leona_BlockG, $00, $05, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_POST_BLOCKSTUN
	mMvAnDef OBJLstPtrTable_Leona_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_GUARDBREAK_G
	mMvAnDef OBJLstPtrTable_Leona_GuardBreakA, $04, $FF, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_GUARDBREAK_A
	mMvAnDef OBJLstPtrTable_Leona_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_HIT0MID
	mMvAnDef OBJLstPtrTable_Leona_TimeOver, $00, $05, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_HIT1MID
	mMvAnDef OBJLstPtrTable_Leona_Hitlow, $00, $05, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_HITLOW
	mMvAnDef OBJLstPtrTable_Leona_DropMain, $10, $05, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_DROP_MAIN
	mMvAnDef OBJLstPtrTable_Leona_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_THROW_END_A
	mMvAnDef OBJLstPtrTable_Leona_DropDbg, $00, $00, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_DROP_DBG
	mMvAnDef OBJLstPtrTable_Leona_HitSwoopup, $18, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_HIT_SWOOPUP
	mMvAnDef OBJLstPtrTable_Leona_DropDbg, $08, $02, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_DROP_CH
	mMvAnDef OBJLstPtrTable_Leona_BackjumpRecA, $18, $02, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_BACKJUMP_REC_A
	mMvAnDef OBJLstPtrTable_Leona_GuardBreakG, $00, $14, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_HIT_MULTIMID0
	mMvAnDef OBJLstPtrTable_Leona_TimeOver, $00, $14, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_HIT_MULTIMID1
	mMvAnDef OBJLstPtrTable_Leona_HitMultigs, $04, $00, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_HIT_MULTIGS
	mMvAnDef OBJLstPtrTable_Leona_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_THROW_END_G
	mMvAnDef OBJLstPtrTable_Leona_TimeOver, $00, $3C, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_THROW_START
	mMvAnDef OBJLstPtrTable_Leona_TimeOver, $00, $3C, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_THROW_ROTU
	mMvAnDef OBJLstPtrTable_Leona_ThrowRotL, $00, $3C, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_THROW_ROTL
	mMvAnDef OBJLstPtrTable_Leona_ThrowEndA, $00, $3C, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_THROW_ROTD
	mMvAnDef OBJLstPtrTable_Leona_HitMultigs, $00, $3C, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_THROW_ROTR
MoveAnimTbl_Geese:
	db $4C, $00, $00, $00, $00, $00, $00, $00 ;X ; MOVE_SHARED_NONE
	mMvAnDef OBJLstPtrTable_Geese_Idle, $0C, $02, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_IDLE
	mMvAnDef OBJLstPtrTable_Geese_WalkF, $08, $01, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_WALK_F
	mMvAnDef OBJLstPtrTable_Geese_WalkB, $08, $02, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_WALK_B
	mMvAnDef OBJLstPtrTable_Geese_Crouch, $00, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_CROUCH
	mMvAnDef OBJLstPtrTable_Geese_JumpN, $1C, $02, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_JUMP_N
	mMvAnDef OBJLstPtrTable_Geese_JumpN, $1C, $02, $00, $00, $00 ;X ; BANK $07 ; MOVE_SHARED_JUMP_F
	mMvAnDef OBJLstPtrTable_Geese_JumpN, $1C, $02, $00, $00, $00 ;X ; BANK $07 ; MOVE_SHARED_JUMP_B
	mMvAnDef OBJLstPtrTable_Geese_BlockG, $00, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_BLOCK_G
	mMvAnDef OBJLstPtrTable_Geese_BlockC, $00, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_BLOCK_C
	mMvAnDef OBJLstPtrTable_Geese_BlockA, $00, $FF, $00, $00, $00 ;X ; BANK $07 ; MOVE_SHARED_BLOCK_A
	mMvAnDef OBJLstPtrTable_Geese_RunF, $08, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_RUN_F
	mMvAnDef OBJLstPtrTable_Geese_HopB, $08, $FF, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_HOP_B
	mMvAnDef OBJLstPtrTable_Geese_ChargeMeter, $04, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_CHARGEMETER
	mMvAnDef OBJLstPtrTable_Geese_Taunt, $14, $03, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_TAUNT
	mMvAnDef OBJLstPtrTable_Geese_RollF, $10, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_ROLL_F
	mMvAnDef OBJLstPtrTable_Geese_RollB, $10, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_ROLL_B
	mMvAnDef OBJLstPtrTable_Geese_Wakeup, $04, $02, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_WAKEUP
	mMvAnDef OBJLstPtrTable_Geese_Dizzy, $04, $0A, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_DIZZY
	mMvAnDef OBJLstPtrTable_Geese_WinA, $00, $08, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_WIN_A
	mMvAnDef OBJLstPtrTable_Geese_WinB, $10, $08, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_WIN_B
	mMvAnDef OBJLstPtrTable_Geese_TimeOver, $00, $01, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_LOST_TIMEOVER
	mMvAnDef OBJLstPtrTable_Geese_Intro, $14, $08, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_INTRO
	mMvAnDef OBJLstPtrTable_Geese_IntroSpec, $18, $08, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_INTRO_SPEC
	mMvAnDef OBJLstPtrTable_Geese_PunchL, $08, $00, $04, HITTYPE_HIT_MID0, $00 ; BANK $07 ; MOVE_SHARED_PUNCH_L
	mMvAnDef OBJLstPtrTable_Geese_PunchH, $0C, $01, $04, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $07 ; MOVE_SHARED_PUNCH_H
	mMvAnDef OBJLstPtrTable_Geese_KickL, $08, $01, $08, HITTYPE_HIT_MID1, $00 ; BANK $07 ; MOVE_SHARED_KICK_L
	mMvAnDef OBJLstPtrTable_Geese_KickH, $10, $02, $08, HITTYPE_HIT_MID1, $00 ; BANK $07 ; MOVE_SHARED_KICK_H
	mMvAnDef OBJLstPtrTable_Geese_PunchCL, $08, $00, $03, HITTYPE_HIT_MID1, $00 ; BANK $07 ; MOVE_SHARED_PUNCH_CL
	mMvAnDef OBJLstPtrTable_Geese_PunchCH, $0C, $01, $03, HITTYPE_HIT_MID1, $00 ; BANK $07 ; MOVE_SHARED_PUNCH_CH
	mMvAnDef OBJLstPtrTable_Geese_KickCL, $08, $00, $06, HITTYPE_HIT_MID1, PF3_HITLOW ; BANK $07 ; MOVE_SHARED_KICK_CL
	mMvAnDef OBJLstPtrTable_Geese_KickCH, $0C, $02, $06, HITTYPE_DROP_CH, PF3_HITLOW ; BANK $07 ; MOVE_SHARED_KICK_CH
	mMvAnDef OBJLstPtrTable_Geese_AttackG, $08, $03, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $07 ; MOVE_SHARED_ATTACK_G
	mMvAnDef OBJLstPtrTable_Geese_PunchA, $10, $01, $05, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $07 ; MOVE_SHARED_PUNCH_A
	mMvAnDef OBJLstPtrTable_Geese_KickA, $10, $01, $09, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $07 ; MOVE_SHARED_KICK_A
	mMvAnDef OBJLstPtrTable_Geese_AttackA, $10, $01, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_OVERHEAD ; BANK $07 ; MOVE_SHARED_ATTACK_A
	mMvAnDef OBJLstPtrTable_Geese_ReppukenL, $0C, $01, $0A, HITTYPE_HIT_MID0, PF3_HEAVYHIT ; BANK $07 ; MOVE_GEESE_REPPUKEN_L
	mMvAnDef OBJLstPtrTable_Geese_ReppukenH, $0C, $01, $0A, HITTYPE_HIT_MID0, PF3_HEAVYHIT|PF3_LASTHIT|PF3_HALFSPEED ; BANK $07 ; MOVE_GEESE_REPPUKEN_H
	mMvAnDef OBJLstPtrTable_Geese_JaEiKenL, $14, $01, $04, HITTYPE_HIT_MID0, PF3_LASTHIT ; BANK $07 ; MOVE_GEESE_JA_EI_KEN_L
	mMvAnDef OBJLstPtrTable_Geese_JaEiKenL, $14, $01, $04, HITTYPE_HIT_MID0, PF3_LASTHIT ; BANK $07 ; MOVE_GEESE_JA_EI_KEN_H
	mMvAnDef OBJLstPtrTable_Geese_HishouNichirinZanL, $20, $01, $04, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $07 ; MOVE_GEESE_HISHOU_NICHIRIN_ZAN_L
	mMvAnDef OBJLstPtrTable_Geese_HishouNichirinZanL, $20, $01, $04, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $07 ; MOVE_GEESE_HISHOU_NICHIRIN_ZAN_H
	mMvAnDef OBJLstPtrTable_Geese_ShippuKenL, $18, $01, $0A, HITTYPE_HIT_MID0, PF3_HEAVYHIT|PF3_HALFSPEED ; BANK $07 ; MOVE_GEESE_SHIPPU_KEN_L
	mMvAnDef OBJLstPtrTable_Geese_ShippuKenL, $18, $01, $0A, HITTYPE_HIT_MID0, PF3_HEAVYHIT|PF3_HALFSPEED ; BANK $07 ; MOVE_GEESE_SHIPPU_KEN_H
	mMvAnDef OBJLstPtrTable_Geese_AtemiNageL, $14, $10, $00, $00, $00 ; BANK $07 ; MOVE_GEESE_ATEMI_NAGE_L
	mMvAnDef OBJLstPtrTable_Geese_AtemiNageH, $14, $10, $00, $00, $00 ; BANK $07 ; MOVE_GEESE_ATEMI_NAGE_H
	mMvAnDef OBJLstPtrTable_Geese_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $07 ; MOVE_GEESE_SPEC_5_L
	mMvAnDef OBJLstPtrTable_Geese_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $07 ; MOVE_GEESE_SPEC_5_H
	mMvAnDef OBJLstPtrTable_Geese_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $07 ; MOVE_GEESE_SPEC_6_L
	mMvAnDef OBJLstPtrTable_Geese_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $07 ; MOVE_GEESE_SPEC_6_H
	mMvAnDef OBJLstPtrTable_Geese_RagingStormS, $18, $14, $14, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_HALFSPEED ; BANK $07 ; MOVE_GEESE_RAGING_STORM_S
	mMvAnDef OBJLstPtrTable_Geese_RagingStormS, $18, $14, $1C, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ; BANK $07 ; MOVE_GEESE_RAGING_STORM_D
	mMvAnDef OBJLstPtrTable_Geese_Idle, $18, $01, $14, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ;X ; BANK $07 ; MOVE_GEESE_SUPER_1_S
	mMvAnDef OBJLstPtrTable_Geese_Idle, $18, $01, $14, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ;X ; BANK $07 ; MOVE_GEESE_SUPER_1_D
	mMvAnDef OBJLstPtrTable_Geese_ThrowG, $14, $0A, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_THROW_G
	mMvAnDef OBJLstPtrTable_Geese_Idle, $00, $00, $00, $00, $00 ;X ; BANK $07 ; MOVE_SHARED_THROW_A
	mMvAnDef OBJLstPtrTable_Geese_BlockG, $00, $05, $00, $00, $00 ;X ; BANK $07 ; MOVE_SHARED_POST_BLOCKSTUN
	mMvAnDef OBJLstPtrTable_Geese_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_GUARDBREAK_G
	mMvAnDef OBJLstPtrTable_Geese_GuardBreakA, $04, $FF, $00, $00, $00 ;X ; BANK $07 ; MOVE_SHARED_GUARDBREAK_A
	mMvAnDef OBJLstPtrTable_Geese_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_HIT0MID
	mMvAnDef OBJLstPtrTable_Geese_TimeOver, $00, $05, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_HIT1MID
	mMvAnDef OBJLstPtrTable_Geese_Hitlow, $00, $05, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_HITLOW
	mMvAnDef OBJLstPtrTable_Geese_DropMain, $10, $05, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_DROP_MAIN
	mMvAnDef OBJLstPtrTable_Geese_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_THROW_END_A
	mMvAnDef OBJLstPtrTable_Geese_DropDbg, $00, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_DROP_DBG
	mMvAnDef OBJLstPtrTable_Geese_HitSwoopup, $18, $00, $00, $00, $00 ;X ; BANK $07 ; MOVE_SHARED_HIT_SWOOPUP
	mMvAnDef OBJLstPtrTable_Geese_DropDbg, $08, $02, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_DROP_CH
	mMvAnDef OBJLstPtrTable_Geese_BackjumpRecA, $18, $02, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_BACKJUMP_REC_A
	mMvAnDef OBJLstPtrTable_Geese_GuardBreakG, $00, $14, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_HIT_MULTIMID0
	mMvAnDef OBJLstPtrTable_Geese_TimeOver, $00, $14, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_HIT_MULTIMID1
	mMvAnDef OBJLstPtrTable_Geese_HitMultigs, $04, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_HIT_MULTIGS
	mMvAnDef OBJLstPtrTable_Geese_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_THROW_END_G
	mMvAnDef OBJLstPtrTable_Geese_TimeOver, $00, $3C, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_THROW_START
	mMvAnDef OBJLstPtrTable_Geese_TimeOver, $00, $3C, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_THROW_ROTU
	mMvAnDef OBJLstPtrTable_Geese_ThrowRotL, $00, $3C, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_THROW_ROTL
	mMvAnDef OBJLstPtrTable_Geese_ThrowEndA, $00, $3C, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_THROW_ROTD
	mMvAnDef OBJLstPtrTable_Geese_HitMultigs, $00, $3C, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_THROW_ROTR
MoveAnimTbl_Krauser:
	db $4C, $00, $00, $00, $00, $00, $00, $00 ;X ; MOVE_SHARED_NONE
	mMvAnDef OBJLstPtrTable_Krauser_Idle, $0C, $02, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_IDLE
	mMvAnDef OBJLstPtrTable_Krauser_WalkF, $08, $01, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_WALK_F
	mMvAnDef OBJLstPtrTable_Krauser_WalkF, $08, $02, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_WALK_B
	mMvAnDef OBJLstPtrTable_Krauser_Crouch, $00, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_CROUCH
	mMvAnDef OBJLstPtrTable_Krauser_JumpN, $1C, $02, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_JUMP_N
	mMvAnDef OBJLstPtrTable_Krauser_JumpN, $1C, $02, $00, $00, $00 ;X ; BANK $09 ; MOVE_SHARED_JUMP_F
	mMvAnDef OBJLstPtrTable_Krauser_JumpN, $1C, $02, $00, $00, $00 ;X ; BANK $09 ; MOVE_SHARED_JUMP_B
	mMvAnDef OBJLstPtrTable_Krauser_BlockG, $00, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_BLOCK_G
	mMvAnDef OBJLstPtrTable_Krauser_BlockC, $00, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_BLOCK_C
	mMvAnDef OBJLstPtrTable_Krauser_BlockA, $00, $FF, $00, $00, $00 ;X ; BANK $09 ; MOVE_SHARED_BLOCK_A
	mMvAnDef OBJLstPtrTable_Krauser_RunF, $08, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_RUN_F
	mMvAnDef OBJLstPtrTable_Krauser_HopB, $08, $FF, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_HOP_B
	mMvAnDef OBJLstPtrTable_Krauser_ChargeMeter, $04, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_CHARGEMETER
	mMvAnDef OBJLstPtrTable_Krauser_Taunt, $0C, $03, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_TAUNT
	mMvAnDef OBJLstPtrTable_Krauser_RollF, $10, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_ROLL_F
	mMvAnDef OBJLstPtrTable_Krauser_RollB, $10, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_ROLL_B
	mMvAnDef OBJLstPtrTable_Krauser_Wakeup, $04, $02, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_WAKEUP
	mMvAnDef OBJLstPtrTable_Krauser_Dizzy, $04, $0A, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_DIZZY
	mMvAnDef OBJLstPtrTable_Krauser_WinA, $0C, $08, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_WIN_A
	mMvAnDef OBJLstPtrTable_Krauser_WinB, $14, $08, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_WIN_B
	mMvAnDef OBJLstPtrTable_Krauser_TimeOver, $00, $01, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_LOST_TIMEOVER
	mMvAnDef OBJLstPtrTable_Krauser_Intro, $10, $3C, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_INTRO
	mMvAnDef OBJLstPtrTable_Krauser_Intro, $10, $3C, $00, $00, $00 ;X ; BANK $09 ; MOVE_SHARED_INTRO_SPEC
	mMvAnDef OBJLstPtrTable_Krauser_PunchL, $08, $00, $04, HITTYPE_HIT_MID0, $00 ; BANK $09 ; MOVE_SHARED_PUNCH_L
	mMvAnDef OBJLstPtrTable_Krauser_PunchH, $0C, $01, $04, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $09 ; MOVE_SHARED_PUNCH_H
	mMvAnDef OBJLstPtrTable_Krauser_KickL, $08, $01, $08, HITTYPE_HIT_MID1, $00 ; BANK $09 ; MOVE_SHARED_KICK_L
	mMvAnDef OBJLstPtrTable_Krauser_KickH, $0C, $02, $08, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $09 ; MOVE_SHARED_KICK_H
	mMvAnDef OBJLstPtrTable_Krauser_PunchCL, $08, $00, $03, HITTYPE_HIT_MID1, $00 ; BANK $09 ; MOVE_SHARED_PUNCH_CL
	mMvAnDef OBJLstPtrTable_Krauser_PunchCH, $0C, $01, $03, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $09 ; MOVE_SHARED_PUNCH_CH
	mMvAnDef OBJLstPtrTable_Krauser_KickCL, $08, $00, $06, HITTYPE_HIT_MID1, PF3_HITLOW ; BANK $09 ; MOVE_SHARED_KICK_CL
	mMvAnDef OBJLstPtrTable_Krauser_KickCH, $0C, $02, $06, HITTYPE_DROP_CH, PF3_HITLOW ; BANK $09 ; MOVE_SHARED_KICK_CH
	mMvAnDef OBJLstPtrTable_Krauser_AttackG, $10, $03, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $09 ; MOVE_SHARED_ATTACK_G
	mMvAnDef OBJLstPtrTable_Krauser_PunchA, $10, $01, $05, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $09 ; MOVE_SHARED_PUNCH_A
	mMvAnDef OBJLstPtrTable_Krauser_KickA, $10, $01, $09, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $09 ; MOVE_SHARED_KICK_A
	mMvAnDef OBJLstPtrTable_Krauser_AttackA, $10, $01, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_OVERHEAD ; BANK $09 ; MOVE_SHARED_ATTACK_A
	mMvAnDef OBJLstPtrTable_Krauser_HighBlitzBallL, $0C, $01, $0A, HITTYPE_HIT_MID0, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ; BANK $09 ; MOVE_KRAUSER_HIGH_BLITZ_BALL_L
	mMvAnDef OBJLstPtrTable_Krauser_HighBlitzBallL, $0C, $03, $0A, HITTYPE_HIT_MID0, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ; BANK $09 ; MOVE_KRAUSER_HIGH_BLITZ_BALL_H
	mMvAnDef OBJLstPtrTable_Krauser_LowBlitzBallL, $14, $01, $0A, HITTYPE_HIT_MID1, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ; BANK $09 ; MOVE_KRAUSER_LOW_BLITZ_BALL_L
	mMvAnDef OBJLstPtrTable_Krauser_LowBlitzBallL, $14, $03, $0A, HITTYPE_HIT_MID1, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ; BANK $09 ; MOVE_KRAUSER_LOW_BLITZ_BALL_H
	mMvAnDef OBJLstPtrTable_Krauser_LegTomahawkL, $20, $01, $08, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $09 ; MOVE_KRAUSER_LEG_TOMAHAWK_L
	mMvAnDef OBJLstPtrTable_Krauser_LegTomahawkL, $20, $02, $08, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $09 ; MOVE_KRAUSER_LEG_TOMAHAWK_H
	mMvAnDef OBJLstPtrTable_Krauser_KaiserKickL, $18, $01, $0A, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $09 ; MOVE_KRAUSER_KAISER_KICK_L
	mMvAnDef OBJLstPtrTable_Krauser_KaiserKickL, $18, $02, $0A, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $09 ; MOVE_KRAUSER_KAISER_KICK_H
	mMvAnDef OBJLstPtrTable_Krauser_KaiserDuelSobatL, $14, $FF, $09, HITTYPE_HIT_MID1, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $09 ; MOVE_KRAUSER_KAISER_DUEL_SOBAT_L
	mMvAnDef OBJLstPtrTable_Krauser_KaiserDuelSobatL, $14, $FF, $09, HITTYPE_HIT_MID1, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $09 ; MOVE_KRAUSER_KAISER_DUEL_SOBAT_H
	mMvAnDef OBJLstPtrTable_Krauser_KaiserSuplexL, $00, $05, $00, $00, $00 ; BANK $09 ; MOVE_KRAUSER_KAISER_SUPLEX_L
	mMvAnDef OBJLstPtrTable_Krauser_KaiserSuplexL, $00, $05, $00, $00, $00 ; BANK $09 ; MOVE_KRAUSER_KAISER_SUPLEX_H
	mMvAnDef OBJLstPtrTable_Krauser_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $09 ; MOVE_KRAUSER_SPEC_6_L
	mMvAnDef OBJLstPtrTable_Krauser_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $09 ; MOVE_KRAUSER_SPEC_6_H
	mMvAnDef OBJLstPtrTable_Krauser_KaiserWaveS, $18, $02, $14, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ; BANK $09 ; MOVE_KRAUSER_KAISER_WAVE_S
	mMvAnDef OBJLstPtrTable_Krauser_KaiserWaveS, $18, $03, $14, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ; BANK $09 ; MOVE_KRAUSER_KAISER_WAVE_D
	mMvAnDef OBJLstPtrTable_Krauser_Idle, $18, $01, $14, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ;X ; BANK $09 ; MOVE_KRAUSER_SUPER_1_S
	mMvAnDef OBJLstPtrTable_Krauser_Idle, $18, $01, $14, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ;X ; BANK $09 ; MOVE_KRAUSER_SUPER_1_D
	mMvAnDef OBJLstPtrTable_Krauser_ThrowG, $14, $0A, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_THROW_G
	mMvAnDef OBJLstPtrTable_Krauser_Idle, $00, $00, $00, $00, $00 ;X ; BANK $09 ; MOVE_SHARED_THROW_A
	mMvAnDef OBJLstPtrTable_Krauser_BlockG, $00, $05, $00, $00, $00 ;X ; BANK $09 ; MOVE_SHARED_POST_BLOCKSTUN
	mMvAnDef OBJLstPtrTable_Krauser_GuardBreakG, $00, $05, $00, $00, $00 ;X ; BANK $09 ; MOVE_SHARED_GUARDBREAK_G
	mMvAnDef OBJLstPtrTable_Krauser_GuardBreakA, $04, $FF, $00, $00, $00 ;X ; BANK $09 ; MOVE_SHARED_GUARDBREAK_A
	mMvAnDef OBJLstPtrTable_Krauser_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_HIT0MID
	mMvAnDef OBJLstPtrTable_Krauser_TimeOver, $00, $05, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_HIT1MID
	mMvAnDef OBJLstPtrTable_Krauser_Hitlow, $00, $05, $00, $00, $00 ;X ; BANK $09 ; MOVE_SHARED_HITLOW
	mMvAnDef OBJLstPtrTable_Krauser_DropMain, $10, $05, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_DROP_MAIN
	mMvAnDef OBJLstPtrTable_Krauser_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_THROW_END_A
	mMvAnDef OBJLstPtrTable_Krauser_DropDbg, $00, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_DROP_DBG
	mMvAnDef OBJLstPtrTable_Krauser_HitSwoopup, $18, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_HIT_SWOOPUP
	mMvAnDef OBJLstPtrTable_Krauser_DropDbg, $08, $02, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_DROP_CH
	mMvAnDef OBJLstPtrTable_Krauser_BackjumpRecA, $18, $02, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_BACKJUMP_REC_A
	mMvAnDef OBJLstPtrTable_Krauser_GuardBreakG, $00, $14, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_HIT_MULTIMID0
	mMvAnDef OBJLstPtrTable_Krauser_TimeOver, $00, $14, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_HIT_MULTIMID1
	mMvAnDef OBJLstPtrTable_Krauser_HitMultigs, $04, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_HIT_MULTIGS
	mMvAnDef OBJLstPtrTable_Krauser_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_THROW_END_G
	mMvAnDef OBJLstPtrTable_Krauser_TimeOver, $00, $3C, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_THROW_START
	mMvAnDef OBJLstPtrTable_Krauser_TimeOver, $00, $3C, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_THROW_ROTU
	mMvAnDef OBJLstPtrTable_Krauser_ThrowRotL, $00, $3C, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_THROW_ROTL
	mMvAnDef OBJLstPtrTable_Krauser_ThrowEndA, $00, $3C, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_THROW_ROTD
	mMvAnDef OBJLstPtrTable_Krauser_HitMultigs, $00, $3C, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_THROW_ROTR
MoveAnimTbl_MrBig:
	db $4C, $00, $00, $00, $00, $00, $00, $00 ;X ; MOVE_SHARED_NONE
	mMvAnDef OBJLstPtrTable_MrBig_Idle, $0C, $06, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_IDLE
	mMvAnDef OBJLstPtrTable_MrBig_WalkF, $0C, $01, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_WALK_F
	mMvAnDef OBJLstPtrTable_MrBig_WalkB, $0C, $02, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_WALK_B
	mMvAnDef OBJLstPtrTable_MrBig_Crouch, $00, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_CROUCH
	mMvAnDef OBJLstPtrTable_MrBig_JumpN, $1C, $02, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_JUMP_N
	mMvAnDef OBJLstPtrTable_MrBig_JumpN, $1C, $02, $00, $00, $00 ;X ; BANK $07 ; MOVE_SHARED_JUMP_F
	mMvAnDef OBJLstPtrTable_MrBig_JumpN, $1C, $02, $00, $00, $00 ;X ; BANK $07 ; MOVE_SHARED_JUMP_B
	mMvAnDef OBJLstPtrTable_MrBig_BlockG, $00, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_BLOCK_G
	mMvAnDef OBJLstPtrTable_MrBig_BlockC, $00, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_BLOCK_C
	mMvAnDef OBJLstPtrTable_MrBig_BlockA, $00, $FF, $00, $00, $00 ;X ; BANK $07 ; MOVE_SHARED_BLOCK_A
	mMvAnDef OBJLstPtrTable_MrBig_RunF, $0C, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_RUN_F
	mMvAnDef OBJLstPtrTable_MrBig_HopB, $08, $FF, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_HOP_B
	mMvAnDef OBJLstPtrTable_MrBig_ChargeMeter, $04, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_CHARGEMETER
	mMvAnDef OBJLstPtrTable_MrBig_Taunt, $04, $0A, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_TAUNT
	mMvAnDef OBJLstPtrTable_MrBig_RollF, $10, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_ROLL_F
	mMvAnDef OBJLstPtrTable_MrBig_RollB, $10, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_ROLL_B
	mMvAnDef OBJLstPtrTable_MrBig_Wakeup, $04, $02, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_WAKEUP
	mMvAnDef OBJLstPtrTable_MrBig_Dizzy, $04, $0A, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_DIZZY
	mMvAnDef OBJLstPtrTable_MrBig_WinA, $04, $10, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_WIN_A
	mMvAnDef OBJLstPtrTable_MrBig_WinB, $0C, $0A, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_WIN_B
	mMvAnDef OBJLstPtrTable_MrBig_TimeOver, $00, $01, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_LOST_TIMEOVER
	mMvAnDef OBJLstPtrTable_MrBig_Taunt, $04, $10, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_INTRO
	mMvAnDef OBJLstPtrTable_MrBig_Taunt, $04, $10, $00, $00, $00 ;X ; BANK $07 ; MOVE_SHARED_INTRO_SPEC
	mMvAnDef OBJLstPtrTable_MrBig_PunchL, $08, $00, $04, HITTYPE_HIT_MID0, $00 ; BANK $07 ; MOVE_SHARED_PUNCH_L
	mMvAnDef OBJLstPtrTable_MrBig_PunchH, $10, $01, $04, HITTYPE_HIT_MID0, $00 ; BANK $07 ; MOVE_SHARED_PUNCH_H
	mMvAnDef OBJLstPtrTable_MrBig_KickL, $08, $01, $08, HITTYPE_HIT_MID1, $00 ; BANK $07 ; MOVE_SHARED_KICK_L
	mMvAnDef OBJLstPtrTable_MrBig_KickH, $0C, $02, $08, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $07 ; MOVE_SHARED_KICK_H
	mMvAnDef OBJLstPtrTable_MrBig_PunchCL, $08, $00, $03, HITTYPE_HIT_MID1, $00 ; BANK $07 ; MOVE_SHARED_PUNCH_CL
	mMvAnDef OBJLstPtrTable_MrBig_PunchCH, $0C, $01, $03, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $07 ; MOVE_SHARED_PUNCH_CH
	mMvAnDef OBJLstPtrTable_MrBig_KickCL, $08, $00, $06, HITTYPE_HIT_MID1, PF3_HITLOW ; BANK $07 ; MOVE_SHARED_KICK_CL
	mMvAnDef OBJLstPtrTable_MrBig_KickCH, $0C, $02, $06, HITTYPE_DROP_CH, PF3_HITLOW ; BANK $07 ; MOVE_SHARED_KICK_CH
	mMvAnDef OBJLstPtrTable_MrBig_AttackG, $0C, $03, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $07 ; MOVE_SHARED_ATTACK_G
	mMvAnDef OBJLstPtrTable_MrBig_PunchA, $10, $01, $05, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $07 ; MOVE_SHARED_PUNCH_A
	mMvAnDef OBJLstPtrTable_MrBig_KickA, $10, $01, $09, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $07 ; MOVE_SHARED_KICK_A
	mMvAnDef OBJLstPtrTable_MrBig_AttackA, $10, $01, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_OVERHEAD ; BANK $07 ; MOVE_SHARED_ATTACK_A
	mMvAnDef OBJLstPtrTable_MrBig_GroundBlasterL, $0C, $01, $0A, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $07 ; MOVE_MRBIG_GROUND_BLASTER_L
	mMvAnDef OBJLstPtrTable_MrBig_GroundBlasterL, $0C, $03, $0A, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $07 ; MOVE_MRBIG_GROUND_BLASTER_H
	mMvAnDef OBJLstPtrTable_MrBig_CrossDivingL, $14, $01, $0A, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $07 ; MOVE_MRBIG_CROSS_DIVING_L
	mMvAnDef OBJLstPtrTable_MrBig_CrossDivingL, $14, $03, $0A, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $07 ; MOVE_MRBIG_CROSS_DIVING_H
	mMvAnDef OBJLstPtrTable_MrBig_SpinningLancerL, $20, $01, $04, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $07 ; MOVE_MRBIG_SPINNING_LANCER_L
	mMvAnDef OBJLstPtrTable_MrBig_SpinningLancerL, $20, $03, $04, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $07 ; MOVE_MRBIG_SPINNING_LANCER_H
	mMvAnDef OBJLstPtrTable_MrBig_CaliforniaRomanceL, $18, $02, $09, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $07 ; MOVE_MRBIG_CALIFORNIA_ROMANCE_L
	mMvAnDef OBJLstPtrTable_MrBig_CaliforniaRomanceH, $18, $00, $04, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $07 ; MOVE_MRBIG_CALIFORNIA_ROMANCE_H
	mMvAnDef OBJLstPtrTable_MrBig_DrumShotL, $14, $00, $04, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $07 ; MOVE_MRBIG_DRUM_SHOT_L
	mMvAnDef OBJLstPtrTable_MrBig_DrumShotL, $14, $00, $04, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $07 ; MOVE_MRBIG_DRUM_SHOT_H
	mMvAnDef OBJLstPtrTable_MrBig_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $07 ; MOVE_MRBIG_SPEC_5_L
	mMvAnDef OBJLstPtrTable_MrBig_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $07 ; MOVE_MRBIG_SPEC_5_H
	mMvAnDef OBJLstPtrTable_MrBig_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $07 ; MOVE_MRBIG_SPEC_6_L
	mMvAnDef OBJLstPtrTable_MrBig_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $07 ; MOVE_MRBIG_SPEC_6_H
	mMvAnDef OBJLstPtrTable_MrBig_BlasterWaveS, $18, $01, $02, HITTYPE_DROP_MAIN, PF3_LASTHIT|PF3_SUPERALT|PF3_LIGHTHIT ; BANK $07 ; MOVE_MRBIG_BLASTER_WAVE_S
	mMvAnDef OBJLstPtrTable_MrBig_BlasterWaveS, $18, $01, $02, HITTYPE_DROP_MAIN, PF3_LASTHIT|PF3_SUPERALT|PF3_LIGHTHIT ; BANK $07 ; MOVE_MRBIG_BLASTER_WAVE_D
	mMvAnDef OBJLstPtrTable_MrBig_Idle, $18, $01, $14, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ;X ; BANK $07 ; MOVE_MRBIG_SUPER_1_S
	mMvAnDef OBJLstPtrTable_MrBig_Idle, $18, $01, $14, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ;X ; BANK $07 ; MOVE_MRBIG_SUPER_1_D
	mMvAnDef OBJLstPtrTable_MrBig_ThrowG, $14, $0A, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_THROW_G
	mMvAnDef OBJLstPtrTable_MrBig_Idle, $00, $00, $00, $00, $00 ;X ; BANK $07 ; MOVE_SHARED_THROW_A
	mMvAnDef OBJLstPtrTable_MrBig_BlockG, $00, $05, $00, $00, $00 ;X ; BANK $07 ; MOVE_SHARED_POST_BLOCKSTUN
	mMvAnDef OBJLstPtrTable_MrBig_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_GUARDBREAK_G
	mMvAnDef OBJLstPtrTable_MrBig_GuardBreakA, $04, $FF, $00, $00, $00 ;X ; BANK $07 ; MOVE_SHARED_GUARDBREAK_A
	mMvAnDef OBJLstPtrTable_MrBig_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_HIT0MID
	mMvAnDef OBJLstPtrTable_MrBig_TimeOver, $00, $05, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_HIT1MID
	mMvAnDef OBJLstPtrTable_MrBig_Hitlow, $00, $05, $00, $00, $00 ;X ; BANK $07 ; MOVE_SHARED_HITLOW
	mMvAnDef OBJLstPtrTable_MrBig_DropMain, $10, $05, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_DROP_MAIN
	mMvAnDef OBJLstPtrTable_MrBig_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_THROW_END_A
	mMvAnDef OBJLstPtrTable_MrBig_DropDbg, $00, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_DROP_DBG
	mMvAnDef OBJLstPtrTable_MrBig_HitSwoopup, $18, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_HIT_SWOOPUP
	mMvAnDef OBJLstPtrTable_MrBig_DropDbg, $08, $02, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_DROP_CH
	mMvAnDef OBJLstPtrTable_MrBig_BackjumpRecA, $18, $02, $00, $00, $00 ;X ; BANK $07 ; MOVE_SHARED_BACKJUMP_REC_A
	mMvAnDef OBJLstPtrTable_MrBig_GuardBreakG, $00, $14, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_HIT_MULTIMID0
	mMvAnDef OBJLstPtrTable_MrBig_TimeOver, $00, $14, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_HIT_MULTIMID1
	mMvAnDef OBJLstPtrTable_MrBig_HitMultigs, $04, $00, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_HIT_MULTIGS
	mMvAnDef OBJLstPtrTable_MrBig_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_THROW_END_G
	mMvAnDef OBJLstPtrTable_MrBig_TimeOver, $00, $3C, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_THROW_START
	mMvAnDef OBJLstPtrTable_MrBig_TimeOver, $00, $3C, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_THROW_ROTU
	mMvAnDef OBJLstPtrTable_MrBig_ThrowRotL, $00, $3C, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_THROW_ROTL
	mMvAnDef OBJLstPtrTable_MrBig_ThrowEndA, $00, $3C, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_THROW_ROTD
	mMvAnDef OBJLstPtrTable_MrBig_HitMultigs, $00, $3C, $00, $00, $00 ; BANK $07 ; MOVE_SHARED_THROW_ROTR
MoveAnimTbl_Iori:
	db $4C, $00, $00, $00, $00, $00, $00, $00 ;X ; MOVE_SHARED_NONE
	mMvAnDef OBJLstPtrTable_Iori_Idle, $0C, $06, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_IDLE
	mMvAnDef OBJLstPtrTable_Iori_WalkF, $0C, $01, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_WALK_F
	mMvAnDef OBJLstPtrTable_Iori_WalkB, $0C, $02, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_WALK_B
	mMvAnDef OBJLstPtrTable_Iori_Crouch, $00, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_CROUCH
	mMvAnDef OBJLstPtrTable_Iori_JumpN, $1C, $02, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_JUMP_N
	mMvAnDef OBJLstPtrTable_Iori_JumpN, $1C, $02, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_JUMP_F
	mMvAnDef OBJLstPtrTable_Iori_JumpN, $1C, $02, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_JUMP_B
	mMvAnDef OBJLstPtrTable_Iori_BlockG, $00, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_BLOCK_G
	mMvAnDef OBJLstPtrTable_Iori_BlockC, $00, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_BLOCK_C
	mMvAnDef OBJLstPtrTable_Iori_BlockA, $00, $FF, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_BLOCK_A
	mMvAnDef OBJLstPtrTable_Iori_RunF, $08, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_RUN_F
	mMvAnDef OBJLstPtrTable_Iori_HopB, $08, $FF, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_HOP_B
	mMvAnDef OBJLstPtrTable_Iori_ChargeMeter, $04, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_CHARGEMETER
	mMvAnDef OBJLstPtrTable_Iori_Taunt, $08, $08, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_TAUNT
	mMvAnDef OBJLstPtrTable_Iori_RollF, $10, $02, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_ROLL_F
	mMvAnDef OBJLstPtrTable_Iori_RollB, $10, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_ROLL_B
	mMvAnDef OBJLstPtrTable_Iori_Wakeup, $04, $02, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_WAKEUP
	mMvAnDef OBJLstPtrTable_Iori_Dizzy, $04, $0A, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_DIZZY
	mMvAnDef OBJLstPtrTable_Iori_WinA, $50, $02, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_WIN_A
	mMvAnDef OBJLstPtrTable_Iori_WinB, $10, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_WIN_B
	mMvAnDef OBJLstPtrTable_Iori_TimeOver, $00, $09, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_LOST_TIMEOVER
	mMvAnDef OBJLstPtrTable_Iori_Intro, $0C, $3C, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_INTRO
	mMvAnDef OBJLstPtrTable_Iori_IntroSpec, $08, $3C, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_INTRO_SPEC
	mMvAnDef OBJLstPtrTable_Iori_PunchL, $08, $00, $04, HITTYPE_HIT_MID0, $00 ; BANK $05 ; MOVE_SHARED_PUNCH_L
	mMvAnDef OBJLstPtrTable_Iori_PunchH, $0C, $01, $04, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $05 ; MOVE_SHARED_PUNCH_H
	mMvAnDef OBJLstPtrTable_Iori_KickL, $08, $01, $08, HITTYPE_HIT_MID1, PF3_HITLOW ; BANK $05 ; MOVE_SHARED_KICK_L
	mMvAnDef OBJLstPtrTable_Iori_KickH, $0C, $02, $08, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $05 ; MOVE_SHARED_KICK_H
	mMvAnDef OBJLstPtrTable_Iori_PunchCL, $08, $00, $03, HITTYPE_HIT_MID1, $00 ; BANK $05 ; MOVE_SHARED_PUNCH_CL
	mMvAnDef OBJLstPtrTable_Iori_PunchCH, $0C, $01, $03, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $05 ; MOVE_SHARED_PUNCH_CH
	mMvAnDef OBJLstPtrTable_Iori_KickCL, $08, $00, $06, HITTYPE_HIT_MID1, PF3_HITLOW ; BANK $05 ; MOVE_SHARED_KICK_CL
	mMvAnDef OBJLstPtrTable_Iori_KickCH, $10, $04, $06, HITTYPE_DROP_CH, PF3_HITLOW ; BANK $05 ; MOVE_SHARED_KICK_CH
	mMvAnDef OBJLstPtrTable_Iori_AttackG, $08, $04, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $05 ; MOVE_SHARED_ATTACK_G
	mMvAnDef OBJLstPtrTable_Iori_PunchA, $10, $01, $05, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $05 ; MOVE_SHARED_PUNCH_A
	mMvAnDef OBJLstPtrTable_Iori_KickA, $10, $01, $09, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $05 ; MOVE_SHARED_KICK_A
	mMvAnDef OBJLstPtrTable_Iori_AttackA, $10, $01, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_OVERHEAD ; BANK $05 ; MOVE_SHARED_ATTACK_A
	mMvAnDef OBJLstPtrTable_Iori_YamiBaraiL, $10, $01, $0A, HITTYPE_HIT_MID0, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ; BANK $05 ; MOVE_IORI_YAMI_BARAI_L
	mMvAnDef OBJLstPtrTable_Iori_YamiBaraiL, $10, $03, $0A, HITTYPE_HIT_MID0, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ; BANK $05 ; MOVE_IORI_YAMI_BARAI_H
	mMvAnDef OBJLstPtrTable_Iori_OniYakiL, $14, $01, $09, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE ; BANK $05 ; MOVE_IORI_ONI_YAKI_L
	mMvAnDef OBJLstPtrTable_Iori_OniYakiL, $14, $02, $09, HITTYPE_HIT_MID1, $00 ; BANK $05 ; MOVE_IORI_ONI_YAKI_H
	mMvAnDef OBJLstPtrTable_Iori_AoiHanaL, $14, $01, $04, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $05 ; MOVE_IORI_AOI_HANA_L
	mMvAnDef OBJLstPtrTable_Iori_AoiHanaL, $14, $01, $04, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $05 ; MOVE_IORI_AOI_HANA_H
	mMvAnDef OBJLstPtrTable_Iori_KotoTsukiInL, $1C, $01, $09, HITTYPE_HIT_MID0, PF3_LASTHIT ; BANK $05 ; MOVE_IORI_KOTO_TSUKI_IN_L
	mMvAnDef OBJLstPtrTable_Iori_KotoTsukiInL, $1C, $01, $09, HITTYPE_HIT_MID0, PF3_LASTHIT ; BANK $05 ; MOVE_IORI_KOTO_TSUKI_IN_H
	mMvAnDef OBJLstPtrTable_Iori_ScumGaleL, $00, $04, $00, $00, $00 ;X ; BANK $05 ; MOVE_IORI_SCUM_GALE_L
	mMvAnDef OBJLstPtrTable_Iori_ScumGaleL, $00, $04, $00, $00, $00 ; BANK $05 ; MOVE_IORI_SCUM_GALE_H
	mMvAnDef OBJLstPtrTable_Iori_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $05 ; MOVE_IORI_SPEC_5_L
	mMvAnDef OBJLstPtrTable_Iori_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $05 ; MOVE_IORI_SPEC_5_H
	mMvAnDef OBJLstPtrTable_Iori_KinYaOtomeEscapeL, $00, $02, $01, HITTYPE_HIT_MULTIGS, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $05 ; MOVE_IORI_KIN_YA_OTOME_ESCAPE_L
	mMvAnDef OBJLstPtrTable_Iori_KinYaOtomeEscapeL, $00, $02, $01, HITTYPE_HIT_MULTIGS, PF3_HEAVYHIT|PF3_LASTHIT ;X ; BANK $05 ; MOVE_IORI_KIN_YA_OTOME_ESCAPE_H
	mMvAnDef OBJLstPtrTable_Iori_KinYaOtomeS, $48, $0C, $09, HITTYPE_HIT_MULTI0, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $05 ; MOVE_IORI_KIN_YA_OTOME_S
	mMvAnDef OBJLstPtrTable_Iori_KinYaOtomeD, $48, $0C, $09, HITTYPE_HIT_MULTI0, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $05 ; MOVE_IORI_KIN_YA_OTOME_D
	mMvAnDef OBJLstPtrTable_Iori_Idle, $48, $0C, $09, HITTYPE_HIT_MULTI0, PF3_HEAVYHIT|PF3_LASTHIT ;X ; BANK $05 ; MOVE_OIORI_KIN_YA_OTOME_S
	mMvAnDef OBJLstPtrTable_Iori_Idle, $48, $0C, $09, HITTYPE_HIT_MULTI0, PF3_HEAVYHIT|PF3_LASTHIT ;X ; BANK $05 ; MOVE_OIORI_KIN_YA_OTOME_D
	mMvAnDef OBJLstPtrTable_Iori_ThrowG, $0C, $0A, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_THROW_G
	mMvAnDef OBJLstPtrTable_Iori_Idle, $00, $00, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_THROW_A
	mMvAnDef OBJLstPtrTable_Iori_BlockG, $00, $05, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_POST_BLOCKSTUN
	mMvAnDef OBJLstPtrTable_Iori_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_GUARDBREAK_G
	mMvAnDef OBJLstPtrTable_Iori_GuardBreakA, $04, $FF, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_GUARDBREAK_A
	mMvAnDef OBJLstPtrTable_Iori_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_HIT0MID
	mMvAnDef OBJLstPtrTable_Iori_Hit1mid, $00, $05, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_HIT1MID
	mMvAnDef OBJLstPtrTable_Iori_Hitlow, $00, $05, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_HITLOW
	mMvAnDef OBJLstPtrTable_Iori_DropMain, $10, $05, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_DROP_MAIN
	mMvAnDef OBJLstPtrTable_Iori_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_THROW_END_A
	mMvAnDef OBJLstPtrTable_Iori_DropDbg, $00, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_DROP_DBG
	mMvAnDef OBJLstPtrTable_Iori_HitSwoopup, $18, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_HIT_SWOOPUP
	mMvAnDef OBJLstPtrTable_Iori_DropDbg, $08, $02, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_DROP_CH
	mMvAnDef OBJLstPtrTable_Iori_BackjumpRecA, $18, $02, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_BACKJUMP_REC_A
	mMvAnDef OBJLstPtrTable_Iori_GuardBreakG, $00, $14, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_HIT_MULTIMID0
	mMvAnDef OBJLstPtrTable_Iori_Hit1mid, $00, $14, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_HIT_MULTIMID1
	mMvAnDef OBJLstPtrTable_Iori_HitMultigs, $04, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_HIT_MULTIGS
	mMvAnDef OBJLstPtrTable_Iori_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_THROW_END_G
	mMvAnDef OBJLstPtrTable_Iori_Hit1mid, $00, $3C, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_THROW_START
	mMvAnDef OBJLstPtrTable_Iori_Hit1mid, $00, $3C, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_THROW_ROTU
	mMvAnDef OBJLstPtrTable_Iori_ThrowRotL, $00, $3C, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_THROW_ROTL
	mMvAnDef OBJLstPtrTable_Iori_ThrowEndA, $00, $3C, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_THROW_ROTD
	mMvAnDef OBJLstPtrTable_Iori_HitMultigs, $00, $3C, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_THROW_ROTR
MoveAnimTbl_Mature:
	db $4C, $00, $00, $00, $00, $00, $00, $00 ;X ; MOVE_SHARED_NONE
	mMvAnDef OBJLstPtrTable_Mature_Idle, $08, $06, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_IDLE
	mMvAnDef OBJLstPtrTable_Mature_WalkF, $10, $01, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_WALK_F
	mMvAnDef OBJLstPtrTable_Mature_WalkB, $10, $02, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_WALK_B
	mMvAnDef OBJLstPtrTable_Mature_Crouch, $00, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_CROUCH
	mMvAnDef OBJLstPtrTable_Mature_JumpN, $1C, $02, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_JUMP_N
	mMvAnDef OBJLstPtrTable_Mature_JumpN, $1C, $02, $00, $00, $00 ;X ; BANK $09 ; MOVE_SHARED_JUMP_F
	mMvAnDef OBJLstPtrTable_Mature_JumpN, $1C, $02, $00, $00, $00 ;X ; BANK $09 ; MOVE_SHARED_JUMP_B
	mMvAnDef OBJLstPtrTable_Mature_BlockG, $00, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_BLOCK_G
	mMvAnDef OBJLstPtrTable_Mature_BlockC, $00, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_BLOCK_C
	mMvAnDef OBJLstPtrTable_Mature_BlockA, $00, $FF, $00, $00, $00 ;X ; BANK $09 ; MOVE_SHARED_BLOCK_A
	mMvAnDef OBJLstPtrTable_Mature_RunF, $04, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_RUN_F
	mMvAnDef OBJLstPtrTable_Mature_HopB, $08, $FF, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_HOP_B
	mMvAnDef OBJLstPtrTable_Mature_ChargeMeter, $04, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_CHARGEMETER
	mMvAnDef OBJLstPtrTable_Mature_Taunt, $04, $10, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_TAUNT
	mMvAnDef OBJLstPtrTable_Mature_RollF, $10, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_ROLL_F
	mMvAnDef OBJLstPtrTable_Mature_RollB, $10, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_ROLL_B
	mMvAnDef OBJLstPtrTable_Mature_Wakeup, $04, $02, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_WAKEUP
	mMvAnDef OBJLstPtrTable_Mature_Dizzy, $04, $0A, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_DIZZY
	mMvAnDef OBJLstPtrTable_Mature_WinA, $04, $10, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_WIN_A
	mMvAnDef OBJLstPtrTable_Mature_WinB, $08, $10, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_WIN_B
	mMvAnDef OBJLstPtrTable_Mature_TimeOver, $00, $01, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_LOST_TIMEOVER
	mMvAnDef OBJLstPtrTable_Mature_Intro, $18, $08, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_INTRO
	mMvAnDef OBJLstPtrTable_Mature_Intro, $18, $08, $00, $00, $00 ;X ; BANK $09 ; MOVE_SHARED_INTRO_SPEC
	mMvAnDef OBJLstPtrTable_Mature_PunchL, $08, $00, $04, HITTYPE_HIT_MID0, $00 ; BANK $09 ; MOVE_SHARED_PUNCH_L
	mMvAnDef OBJLstPtrTable_Mature_PunchH, $0C, $01, $04, HITTYPE_HIT_MID0, $00 ; BANK $09 ; MOVE_SHARED_PUNCH_H
	mMvAnDef OBJLstPtrTable_Mature_KickL, $0C, $01, $04, HITTYPE_HIT_MID1, PF3_HITLOW ; BANK $09 ; MOVE_SHARED_KICK_L
	mMvAnDef OBJLstPtrTable_Mature_KickH, $0C, $02, $08, HITTYPE_HIT_MID1, $00 ; BANK $09 ; MOVE_SHARED_KICK_H
	mMvAnDef OBJLstPtrTable_Mature_PunchCL, $08, $00, $03, HITTYPE_HIT_MID1, $00 ; BANK $09 ; MOVE_SHARED_PUNCH_CL
	mMvAnDef OBJLstPtrTable_Mature_PunchCH, $0C, $01, $03, HITTYPE_DROP_CH, PF3_HITLOW ; BANK $09 ; MOVE_SHARED_PUNCH_CH
	mMvAnDef OBJLstPtrTable_Mature_KickCL, $08, $00, $06, HITTYPE_HIT_MID1, PF3_HITLOW ; BANK $09 ; MOVE_SHARED_KICK_CL
	mMvAnDef OBJLstPtrTable_Mature_KickCH, $0C, $02, $06, HITTYPE_HIT_MID0, $00 ; BANK $09 ; MOVE_SHARED_KICK_CH
	mMvAnDef OBJLstPtrTable_Mature_AttackG, $0C, $03, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $09 ; MOVE_SHARED_ATTACK_G
	mMvAnDef OBJLstPtrTable_Mature_PunchA, $10, $01, $05, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $09 ; MOVE_SHARED_PUNCH_A
	mMvAnDef OBJLstPtrTable_Mature_KickA, $10, $01, $09, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $09 ; MOVE_SHARED_KICK_A
	mMvAnDef OBJLstPtrTable_Mature_AttackA, $10, $01, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_OVERHEAD ; BANK $09 ; MOVE_SHARED_ATTACK_A
	mMvAnDef OBJLstPtrTable_Mature_DecideL, $0C, $01, $0A, HITTYPE_HIT_MULTI1, PF3_LASTHIT ; BANK $09 ; MOVE_MATURE_DECIDE_L
	mMvAnDef OBJLstPtrTable_Mature_DecideL, $0C, $03, $0A, HITTYPE_HIT_MULTI1, PF3_LASTHIT ; BANK $09 ; MOVE_MATURE_DECIDE_H
	mMvAnDef OBJLstPtrTable_Mature_MetalMassacreL, $14, $01, $0A, HITTYPE_HIT_MID1, PF3_LIGHTHIT ; BANK $09 ; MOVE_MATURE_METAL_MASSACRE_L
	mMvAnDef OBJLstPtrTable_Mature_MetalMassacreL, $14, $02, $0A, HITTYPE_HIT_MID1, PF3_LIGHTHIT ; BANK $09 ; MOVE_MATURE_METAL_MASSACRE_H
	mMvAnDef OBJLstPtrTable_Mature_DeathRowL, $20, $00, $04, HITTYPE_HIT_MID0, PF3_LIGHTHIT ; BANK $09 ; MOVE_MATURE_DEATH_ROW_L
	mMvAnDef OBJLstPtrTable_Mature_DeathRowL, $20, $00, $04, HITTYPE_HIT_MID0, PF3_LIGHTHIT ; BANK $09 ; MOVE_MATURE_DEATH_ROW_H
	mMvAnDef OBJLstPtrTable_Mature_DespairL, $18, $01, $09, HITTYPE_HIT_MID0, PF3_LASTHIT ; BANK $09 ; MOVE_MATURE_DESPAIR_L
	mMvAnDef OBJLstPtrTable_Mature_DespairL, $18, $02, $09, HITTYPE_HIT_MID0, PF3_HEAVYHIT ; BANK $09 ; MOVE_MATURE_DESPAIR_H
	mMvAnDef OBJLstPtrTable_Mature_Idle, $14, $FF, $09, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_LASTHIT ;X ; BANK $09 ; MOVE_MATURE_SPEC_4_L
	mMvAnDef OBJLstPtrTable_Mature_Idle, $14, $FF, $09, HITTYPE_DROP_MAIN, PF3_LASTHIT ;X ; BANK $09 ; MOVE_MATURE_SPEC_4_H
	mMvAnDef OBJLstPtrTable_Mature_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $09 ; MOVE_MATURE_SPEC_5_L
	mMvAnDef OBJLstPtrTable_Mature_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $09 ; MOVE_MATURE_SPEC_5_H
	mMvAnDef OBJLstPtrTable_Mature_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $09 ; MOVE_MATURE_SPEC_6_L
	mMvAnDef OBJLstPtrTable_Mature_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $09 ; MOVE_MATURE_SPEC_6_H
	mMvAnDef OBJLstPtrTable_Mature_HeavensGateS, $18, $01, $01, HITTYPE_HIT_MULTI1, PF3_HEAVYHIT ; BANK $09 ; MOVE_MATURE_HEAVENS_GATE_S
	mMvAnDef OBJLstPtrTable_Mature_HeavensGateS, $18, $04, $01, HITTYPE_HIT_MULTI1, PF3_HEAVYHIT ; BANK $09 ; MOVE_MATURE_HEAVENS_GATE_D
	mMvAnDef OBJLstPtrTable_Mature_Idle, $18, $01, $14, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ;X ; BANK $09 ; MOVE_MATURE_SUPER_1_S
	mMvAnDef OBJLstPtrTable_Mature_Idle, $18, $01, $14, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ;X ; BANK $09 ; MOVE_MATURE_SUPER_1_D
	mMvAnDef OBJLstPtrTable_Mature_ThrowG, $14, $0A, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_THROW_G
	mMvAnDef OBJLstPtrTable_Mature_Idle, $00, $00, $00, $00, $00 ;X ; BANK $09 ; MOVE_SHARED_THROW_A
	mMvAnDef OBJLstPtrTable_Mature_BlockG, $00, $05, $00, $00, $00 ;X ; BANK $09 ; MOVE_SHARED_POST_BLOCKSTUN
	mMvAnDef OBJLstPtrTable_Mature_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_GUARDBREAK_G
	mMvAnDef OBJLstPtrTable_Mature_GuardBreakA, $04, $FF, $00, $00, $00 ;X ; BANK $09 ; MOVE_SHARED_GUARDBREAK_A
	mMvAnDef OBJLstPtrTable_Mature_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_HIT0MID
	mMvAnDef OBJLstPtrTable_Mature_TimeOver, $00, $05, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_HIT1MID
	mMvAnDef OBJLstPtrTable_Mature_Hitlow, $00, $05, $00, $00, $00 ;X ; BANK $09 ; MOVE_SHARED_HITLOW
	mMvAnDef OBJLstPtrTable_Mature_DropMain, $10, $05, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_DROP_MAIN
	mMvAnDef OBJLstPtrTable_Mature_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_THROW_END_A
	mMvAnDef OBJLstPtrTable_Mature_DropDbg, $00, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_DROP_DBG
	mMvAnDef OBJLstPtrTable_Mature_HitSwoopup, $18, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_HIT_SWOOPUP
	mMvAnDef OBJLstPtrTable_Mature_DropDbg, $08, $02, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_DROP_CH
	mMvAnDef OBJLstPtrTable_Mature_BackjumpRecA, $18, $02, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_BACKJUMP_REC_A
	mMvAnDef OBJLstPtrTable_Mature_GuardBreakG, $00, $14, $00, $00, $00 ;X ; BANK $09 ; MOVE_SHARED_HIT_MULTIMID0
	mMvAnDef OBJLstPtrTable_Mature_TimeOver, $00, $14, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_HIT_MULTIMID1
	mMvAnDef OBJLstPtrTable_Mature_HitMultigs, $04, $00, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_HIT_MULTIGS
	mMvAnDef OBJLstPtrTable_Mature_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_THROW_END_G
	mMvAnDef OBJLstPtrTable_Mature_TimeOver, $00, $3C, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_THROW_START
	mMvAnDef OBJLstPtrTable_Mature_TimeOver, $00, $3C, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_THROW_ROTU
	mMvAnDef OBJLstPtrTable_Mature_ThrowRotL, $00, $3C, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_THROW_ROTL
	mMvAnDef OBJLstPtrTable_Mature_ThrowEndA, $00, $3C, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_THROW_ROTD
	mMvAnDef OBJLstPtrTable_Mature_HitMultigs, $00, $3C, $00, $00, $00 ; BANK $09 ; MOVE_SHARED_THROW_ROTR
MoveAnimTbl_Chizuru:
	db $4C, $00, $00, $00, $00, $00, $00, $00 ;X ; MOVE_SHARED_NONE
	mMvAnDef OBJLstPtrTable_Chizuru_Idle, $0C, $02, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_IDLE
	mMvAnDef OBJLstPtrTable_Chizuru_WalkF, $08, $01, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_WALK_F
	mMvAnDef OBJLstPtrTable_Chizuru_WalkB, $08, $02, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_WALK_B
	mMvAnDef OBJLstPtrTable_Chizuru_Crouch, $00, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_CROUCH
	mMvAnDef OBJLstPtrTable_Chizuru_JumpN, $1C, $02, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_JUMP_N
	mMvAnDef OBJLstPtrTable_Chizuru_JumpF, $1C, $02, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_JUMP_F
	mMvAnDef OBJLstPtrTable_Chizuru_JumpB, $1C, $02, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_JUMP_B
	mMvAnDef OBJLstPtrTable_Chizuru_BlockG, $00, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_BLOCK_G
	mMvAnDef OBJLstPtrTable_Chizuru_BlockC, $00, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_BLOCK_C
	mMvAnDef OBJLstPtrTable_Chizuru_BlockA, $00, $FF, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_BLOCK_A
	mMvAnDef OBJLstPtrTable_Chizuru_RunF, $08, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_RUN_F
	mMvAnDef OBJLstPtrTable_Chizuru_HopB, $08, $FF, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_HOP_B
	mMvAnDef OBJLstPtrTable_Chizuru_ChargeMeter, $04, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_CHARGEMETER
	mMvAnDef OBJLstPtrTable_Chizuru_Taunt, $2C, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_TAUNT
	mMvAnDef OBJLstPtrTable_Chizuru_RollF, $0C, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_ROLL_F
	mMvAnDef OBJLstPtrTable_Chizuru_RollB, $0C, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_ROLL_B
	mMvAnDef OBJLstPtrTable_Chizuru_Wakeup, $04, $02, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_WAKEUP
	mMvAnDef OBJLstPtrTable_Chizuru_Dizzy, $04, $0A, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_DIZZY
	mMvAnDef OBJLstPtrTable_Chizuru_WinA, $10, $06, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_WIN_A
	mMvAnDef OBJLstPtrTable_Chizuru_WinB, $04, $06, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_WIN_B
	mMvAnDef OBJLstPtrTable_Chizuru_TimeOver, $00, $01, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_LOST_TIMEOVER
	mMvAnDef OBJLstPtrTable_Chizuru_Taunt, $2C, $04, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_INTRO
	mMvAnDef OBJLstPtrTable_Chizuru_Taunt, $2C, $04, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_INTRO_SPEC
	mMvAnDef OBJLstPtrTable_Chizuru_PunchL, $08, $00, $04, HITTYPE_HIT_MID0, $00 ; BANK $05 ; MOVE_SHARED_PUNCH_L
	mMvAnDef OBJLstPtrTable_Chizuru_PunchH, $08, $01, $04, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $05 ; MOVE_SHARED_PUNCH_H
	mMvAnDef OBJLstPtrTable_Chizuru_KickL, $08, $01, $08, HITTYPE_HIT_MID1, $00 ; BANK $05 ; MOVE_SHARED_KICK_L
	mMvAnDef OBJLstPtrTable_Chizuru_KickH, $08, $02, $08, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $05 ; MOVE_SHARED_KICK_H
	mMvAnDef OBJLstPtrTable_Chizuru_PunchCL, $08, $00, $03, HITTYPE_HIT_MID1, $00 ; BANK $05 ; MOVE_SHARED_PUNCH_CL
	mMvAnDef OBJLstPtrTable_Chizuru_PunchCH, $08, $01, $03, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $05 ; MOVE_SHARED_PUNCH_CH
	mMvAnDef OBJLstPtrTable_Chizuru_KickCL, $08, $00, $06, HITTYPE_HIT_MID1, PF3_HITLOW ; BANK $05 ; MOVE_SHARED_KICK_CL
	mMvAnDef OBJLstPtrTable_Chizuru_KickCH, $10, $02, $06, HITTYPE_DROP_CH, PF3_HITLOW ; BANK $05 ; MOVE_SHARED_KICK_CH
	mMvAnDef OBJLstPtrTable_Chizuru_AttackG, $0C, $01, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $05 ; MOVE_SHARED_ATTACK_G
	mMvAnDef OBJLstPtrTable_Chizuru_PunchA, $10, $01, $05, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $05 ; MOVE_SHARED_PUNCH_A
	mMvAnDef OBJLstPtrTable_Chizuru_KickA, $10, $01, $09, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $05 ; MOVE_SHARED_KICK_A
	mMvAnDef OBJLstPtrTable_Chizuru_AttackA, $10, $01, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_OVERHEAD ; BANK $05 ; MOVE_SHARED_ATTACK_A
	mMvAnDef OBJLstPtrTable_Chizuru_TenjinKotowariL, $10, $01, $0A, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $05 ; MOVE_CHIZURU_TENJIN_KOTOWARI_L
	mMvAnDef OBJLstPtrTable_Chizuru_TenjinKotowariL, $10, $03, $0A, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $05 ; MOVE_CHIZURU_TENJIN_KOTOWARI_H
	mMvAnDef OBJLstPtrTable_Chizuru_ShinsokuNorotiHighL, $14, $00, $0A, HITTYPE_DROP_MAIN, PF3_LASTHIT ; BANK $05 ; MOVE_CHIZURU_SHINSOKU_NOROTI_HIGH_L
	mMvAnDef OBJLstPtrTable_Chizuru_ShinsokuNorotiHighL, $14, $02, $0A, HITTYPE_DROP_MAIN, PF3_LASTHIT ; BANK $05 ; MOVE_CHIZURU_SHINSOKU_NOROTI_HIGH_H
	mMvAnDef OBJLstPtrTable_Chizuru_ShinsokuNorotiLowL, $20, $01, $0A, HITTYPE_DROP_DB_A, PF3_LASTHIT ; BANK $05 ; MOVE_CHIZURU_SHINSOKU_NOROTI_LOW_L
	mMvAnDef OBJLstPtrTable_Chizuru_ShinsokuNorotiLowL, $20, $01, $0A, HITTYPE_DROP_DB_A, PF3_LASTHIT ; BANK $05 ; MOVE_CHIZURU_SHINSOKU_NOROTI_LOW_H
	mMvAnDef OBJLstPtrTable_Chizuru_TenZuiL, $1C, $FF, $09, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $05 ; MOVE_CHIZURU_TEN_ZUI_L
	mMvAnDef OBJLstPtrTable_Chizuru_TenZuiH, $1C, $02, $09, HITTYPE_DROP_DB_A, PF3_HEAVYHIT ; BANK $05 ; MOVE_CHIZURU_TEN_ZUI_H
	mMvAnDef OBJLstPtrTable_Chizuru_TamayuraShitsuneL, $00, $01, $09, HITTYPE_DROP_DB_A, PF3_HEAVYHIT ; BANK $05 ; MOVE_CHIZURU_TAMAYURA_SHITSUNE_L
	mMvAnDef OBJLstPtrTable_Chizuru_TamayuraShitsuneH, $00, $04, $09, HITTYPE_DROP_DB_A, PF3_HEAVYHIT ; BANK $05 ; MOVE_CHIZURU_TAMAYURA_SHITSUNE_H
	mMvAnDef OBJLstPtrTable_Chizuru_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $05 ; MOVE_CHIZURU_SPEC_5_L
	mMvAnDef OBJLstPtrTable_Chizuru_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $05 ; MOVE_CHIZURU_SPEC_5_H
	mMvAnDef OBJLstPtrTable_Chizuru_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $05 ; MOVE_CHIZURU_SPEC_6_L
	mMvAnDef OBJLstPtrTable_Chizuru_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $05 ; MOVE_CHIZURU_SPEC_6_H
	mMvAnDef OBJLstPtrTable_Chizuru_SanRaiFuiJinS, $00, $02, $0A, HITTYPE_HIT_MID1, PF3_HEAVYHIT|PF3_SUPERALT ; BANK $05 ; MOVE_CHIZURU_SAN_RAI_FUI_JIN_S
	mMvAnDef OBJLstPtrTable_Chizuru_SanRaiFuiJinS, $00, $02, $0A, HITTYPE_HIT_MID1, PF3_HEAVYHIT|PF3_SUPERALT ; BANK $05 ; MOVE_CHIZURU_SAN_RAI_FUI_JIN_D
	mMvAnDef OBJLstPtrTable_Chizuru_ReigiIshizueS, $40, $01, $03, HITTYPE_HIT_MID0, PF3_LASTHIT ; BANK $05 ; MOVE_CHIZURU_REIGI_ISHIZUE_S
	mMvAnDef OBJLstPtrTable_Chizuru_ReigiIshizueS, $40, $01, $01, HITTYPE_HIT_MID0, PF3_LASTHIT ; BANK $05 ; MOVE_CHIZURU_REIGI_ISHIZUE_D
	mMvAnDef OBJLstPtrTable_Chizuru_ThrowG, $18, $0A, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_THROW_G
	mMvAnDef OBJLstPtrTable_Chizuru_Idle, $00, $00, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_THROW_A
	mMvAnDef OBJLstPtrTable_Chizuru_BlockG, $00, $05, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_POST_BLOCKSTUN
	mMvAnDef OBJLstPtrTable_Chizuru_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_GUARDBREAK_G
	mMvAnDef OBJLstPtrTable_Chizuru_GuardBreakA, $04, $FF, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_GUARDBREAK_A
	mMvAnDef OBJLstPtrTable_Chizuru_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_HIT0MID
	mMvAnDef OBJLstPtrTable_Chizuru_Hit1mid, $00, $05, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_HIT1MID
	mMvAnDef OBJLstPtrTable_Chizuru_Hitlow, $00, $05, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_HITLOW
	mMvAnDef OBJLstPtrTable_Chizuru_DropMain, $10, $05, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_DROP_MAIN
	mMvAnDef OBJLstPtrTable_Chizuru_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_THROW_END_A
	mMvAnDef OBJLstPtrTable_Chizuru_DropDbg, $00, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_DROP_DBG
	mMvAnDef OBJLstPtrTable_Chizuru_HitSwoopup, $18, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_HIT_SWOOPUP
	mMvAnDef OBJLstPtrTable_Chizuru_DropDbg, $08, $02, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_DROP_CH
	mMvAnDef OBJLstPtrTable_Chizuru_BackjumpRecA, $18, $02, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_BACKJUMP_REC_A
	mMvAnDef OBJLstPtrTable_Chizuru_GuardBreakG, $00, $14, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_HIT_MULTIMID0
	mMvAnDef OBJLstPtrTable_Chizuru_Hit1mid, $00, $14, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_HIT_MULTIMID1
	mMvAnDef OBJLstPtrTable_Chizuru_HitMultigs, $04, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_HIT_MULTIGS
	mMvAnDef OBJLstPtrTable_Chizuru_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_THROW_END_G
	mMvAnDef OBJLstPtrTable_Chizuru_Hit1mid, $00, $3C, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_THROW_START
	mMvAnDef OBJLstPtrTable_Chizuru_Hit1mid, $00, $3C, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_THROW_ROTU
	mMvAnDef OBJLstPtrTable_Chizuru_ThrowRotL, $00, $3C, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_THROW_ROTL
	mMvAnDef OBJLstPtrTable_Chizuru_ThrowEndA, $00, $3C, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_THROW_ROTD
	mMvAnDef OBJLstPtrTable_Chizuru_HitMultigs, $00, $3C, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_THROW_ROTR
MoveAnimTbl_Kagura:
	db $4C, $00, $00, $00, $00, $00, $00, $00 ;X ; MOVE_SHARED_NONE
	mMvAnDef OBJLstPtrTable_Chizuru_Idle, $0C, $02, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_IDLE
	mMvAnDef OBJLstPtrTable_Chizuru_WalkF, $08, $01, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_WALK_F
	mMvAnDef OBJLstPtrTable_Chizuru_WalkB, $08, $02, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_WALK_B
	mMvAnDef OBJLstPtrTable_Chizuru_Crouch, $00, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_CROUCH
	mMvAnDef OBJLstPtrTable_Chizuru_JumpN, $1C, $02, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_JUMP_N
	mMvAnDef OBJLstPtrTable_Chizuru_JumpF, $1C, $02, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_JUMP_F
	mMvAnDef OBJLstPtrTable_Chizuru_JumpB, $1C, $02, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_JUMP_B
	mMvAnDef OBJLstPtrTable_Chizuru_BlockG, $00, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_BLOCK_G
	mMvAnDef OBJLstPtrTable_Chizuru_BlockC, $00, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_BLOCK_C
	mMvAnDef OBJLstPtrTable_Chizuru_BlockA, $00, $FF, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_BLOCK_A
	mMvAnDef OBJLstPtrTable_Chizuru_RunF, $08, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_RUN_F
	mMvAnDef OBJLstPtrTable_Chizuru_HopB, $08, $FF, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_HOP_B
	mMvAnDef OBJLstPtrTable_Chizuru_ChargeMeter, $04, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_CHARGEMETER
	mMvAnDef OBJLstPtrTable_Chizuru_Taunt, $2C, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_TAUNT
	mMvAnDef OBJLstPtrTable_Chizuru_RollF, $0C, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_ROLL_F
	mMvAnDef OBJLstPtrTable_Chizuru_RollB, $0C, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_ROLL_B
	mMvAnDef OBJLstPtrTable_Chizuru_Wakeup, $04, $02, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_WAKEUP
	mMvAnDef OBJLstPtrTable_Chizuru_Dizzy, $04, $0A, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_DIZZY
	mMvAnDef OBJLstPtrTable_Chizuru_WinA, $10, $06, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_WIN_A
	mMvAnDef OBJLstPtrTable_Kagura_WinB, $14, $06, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_WIN_B
	mMvAnDef OBJLstPtrTable_Chizuru_TimeOver, $00, $01, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_LOST_TIMEOVER
	mMvAnDef OBJLstPtrTable_Chizuru_Taunt, $2C, $03, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_INTRO
	mMvAnDef OBJLstPtrTable_Chizuru_Taunt, $2C, $03, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_INTRO_SPEC
	mMvAnDef OBJLstPtrTable_Chizuru_PunchL, $08, $00, $04, HITTYPE_HIT_MID0, $00 ; BANK $05 ; MOVE_SHARED_PUNCH_L
	mMvAnDef OBJLstPtrTable_Chizuru_PunchH, $08, $01, $04, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $05 ; MOVE_SHARED_PUNCH_H
	mMvAnDef OBJLstPtrTable_Chizuru_KickL, $08, $01, $08, HITTYPE_HIT_MID1, $00 ; BANK $05 ; MOVE_SHARED_KICK_L
	mMvAnDef OBJLstPtrTable_Kagura_KickH, $08, $02, $08, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $05 ; MOVE_SHARED_KICK_H
	mMvAnDef OBJLstPtrTable_Chizuru_PunchCL, $08, $00, $03, HITTYPE_HIT_MID1, $00 ; BANK $05 ; MOVE_SHARED_PUNCH_CL
	mMvAnDef OBJLstPtrTable_Chizuru_PunchCH, $08, $01, $03, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $05 ; MOVE_SHARED_PUNCH_CH
	mMvAnDef OBJLstPtrTable_Chizuru_KickCL, $08, $00, $06, HITTYPE_HIT_MID1, PF3_HITLOW ; BANK $05 ; MOVE_SHARED_KICK_CL
	mMvAnDef OBJLstPtrTable_Chizuru_KickCH, $10, $02, $06, HITTYPE_DROP_CH, PF3_HITLOW ; BANK $05 ; MOVE_SHARED_KICK_CH
	mMvAnDef OBJLstPtrTable_Chizuru_AttackG, $0C, $01, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $05 ; MOVE_SHARED_ATTACK_G
	mMvAnDef OBJLstPtrTable_Chizuru_PunchA, $10, $01, $05, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $05 ; MOVE_SHARED_PUNCH_A
	mMvAnDef OBJLstPtrTable_Chizuru_KickA, $10, $01, $09, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $05 ; MOVE_SHARED_KICK_A
	mMvAnDef OBJLstPtrTable_Chizuru_AttackA, $10, $01, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_OVERHEAD ; BANK $05 ; MOVE_SHARED_ATTACK_A
	mMvAnDef OBJLstPtrTable_Chizuru_TenjinKotowariL, $10, $01, $0A, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $05 ; MOVE_CHIZURU_TENJIN_KOTOWARI_L
	mMvAnDef OBJLstPtrTable_Chizuru_TenjinKotowariL, $10, $03, $0A, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $05 ; MOVE_CHIZURU_TENJIN_KOTOWARI_H
	mMvAnDef OBJLstPtrTable_Chizuru_ShinsokuNorotiHighL, $14, $00, $0A, HITTYPE_DROP_MAIN, PF3_LASTHIT ; BANK $05 ; MOVE_CHIZURU_SHINSOKU_NOROTI_HIGH_L
	mMvAnDef OBJLstPtrTable_Chizuru_ShinsokuNorotiHighL, $14, $02, $0A, HITTYPE_DROP_MAIN, PF3_LASTHIT ; BANK $05 ; MOVE_CHIZURU_SHINSOKU_NOROTI_HIGH_H
	mMvAnDef OBJLstPtrTable_Chizuru_ShinsokuNorotiLowL, $20, $01, $0A, HITTYPE_DROP_DB_A, PF3_LASTHIT ; BANK $05 ; MOVE_CHIZURU_SHINSOKU_NOROTI_LOW_L
	mMvAnDef OBJLstPtrTable_Chizuru_ShinsokuNorotiLowL, $20, $01, $0A, HITTYPE_DROP_DB_A, PF3_LASTHIT ; BANK $05 ; MOVE_CHIZURU_SHINSOKU_NOROTI_LOW_H
	mMvAnDef OBJLstPtrTable_Chizuru_TenZuiL, $1C, $FF, $09, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $05 ; MOVE_CHIZURU_TEN_ZUI_L
	mMvAnDef OBJLstPtrTable_Chizuru_TenZuiH, $1C, $02, $09, HITTYPE_DROP_DB_A, PF3_HEAVYHIT ; BANK $05 ; MOVE_CHIZURU_TEN_ZUI_H
	mMvAnDef OBJLstPtrTable_Chizuru_TamayuraShitsuneL, $00, $01, $09, HITTYPE_DROP_DB_A, PF3_HEAVYHIT ; BANK $05 ; MOVE_CHIZURU_TAMAYURA_SHITSUNE_L
	mMvAnDef OBJLstPtrTable_Chizuru_TamayuraShitsuneH, $00, $04, $09, HITTYPE_DROP_DB_A, PF3_HEAVYHIT ; BANK $05 ; MOVE_CHIZURU_TAMAYURA_SHITSUNE_H
	mMvAnDef OBJLstPtrTable_Chizuru_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $05 ; MOVE_CHIZURU_SPEC_5_L
	mMvAnDef OBJLstPtrTable_Chizuru_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $05 ; MOVE_CHIZURU_SPEC_5_H
	mMvAnDef OBJLstPtrTable_Chizuru_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $05 ; MOVE_CHIZURU_SPEC_6_L
	mMvAnDef OBJLstPtrTable_Chizuru_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $05 ; MOVE_CHIZURU_SPEC_6_H
	mMvAnDef OBJLstPtrTable_Chizuru_SanRaiFuiJinS, $00, $02, $0A, HITTYPE_HIT_MID1, PF3_HEAVYHIT|PF3_FIRE ; BANK $05 ; MOVE_CHIZURU_SAN_RAI_FUI_JIN_S
	mMvAnDef OBJLstPtrTable_Chizuru_SanRaiFuiJinS, $00, $02, $0A, HITTYPE_HIT_MID1, PF3_HEAVYHIT|PF3_FIRE ; BANK $05 ; MOVE_CHIZURU_SAN_RAI_FUI_JIN_D
	mMvAnDef OBJLstPtrTable_Chizuru_ReigiIshizueS, $40, $01, $03, HITTYPE_HIT_MID0, PF3_LASTHIT ; BANK $05 ; MOVE_CHIZURU_REIGI_ISHIZUE_S
	mMvAnDef OBJLstPtrTable_Chizuru_ReigiIshizueS, $40, $01, $01, HITTYPE_HIT_MID0, PF3_LASTHIT ; BANK $05 ; MOVE_CHIZURU_REIGI_ISHIZUE_D
	mMvAnDef OBJLstPtrTable_Chizuru_ThrowG, $18, $0A, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_THROW_G
	mMvAnDef OBJLstPtrTable_Chizuru_Idle, $00, $00, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_THROW_A
	mMvAnDef OBJLstPtrTable_Chizuru_BlockG, $00, $05, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_POST_BLOCKSTUN
	mMvAnDef OBJLstPtrTable_Chizuru_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_GUARDBREAK_G
	mMvAnDef OBJLstPtrTable_Chizuru_GuardBreakA, $04, $FF, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_GUARDBREAK_A
	mMvAnDef OBJLstPtrTable_Chizuru_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_HIT0MID
	mMvAnDef OBJLstPtrTable_Chizuru_Hit1mid, $00, $05, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_HIT1MID
	mMvAnDef OBJLstPtrTable_Chizuru_Hitlow, $00, $05, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_HITLOW
	mMvAnDef OBJLstPtrTable_Chizuru_DropMain, $10, $05, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_DROP_MAIN
	mMvAnDef OBJLstPtrTable_Chizuru_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_THROW_END_A
	mMvAnDef OBJLstPtrTable_Chizuru_DropDbg, $00, $00, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_DROP_DBG
	mMvAnDef OBJLstPtrTable_Chizuru_HitSwoopup, $18, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_HIT_SWOOPUP
	mMvAnDef OBJLstPtrTable_Chizuru_DropDbg, $08, $02, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_DROP_CH
	mMvAnDef OBJLstPtrTable_Chizuru_BackjumpRecA, $18, $02, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_BACKJUMP_REC_A
	mMvAnDef OBJLstPtrTable_Chizuru_GuardBreakG, $00, $14, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_HIT_MULTIMID0
	mMvAnDef OBJLstPtrTable_Chizuru_Hit1mid, $00, $14, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_HIT_MULTIMID1
	mMvAnDef OBJLstPtrTable_Chizuru_HitMultigs, $04, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_HIT_MULTIGS
	mMvAnDef OBJLstPtrTable_Chizuru_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_THROW_END_G
	mMvAnDef OBJLstPtrTable_Chizuru_Hit1mid, $00, $3C, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_THROW_START
	mMvAnDef OBJLstPtrTable_Chizuru_Hit1mid, $00, $3C, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_THROW_ROTU
	mMvAnDef OBJLstPtrTable_Chizuru_ThrowRotL, $00, $3C, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_THROW_ROTL
	mMvAnDef OBJLstPtrTable_Chizuru_ThrowEndA, $00, $3C, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_THROW_ROTD
	mMvAnDef OBJLstPtrTable_Chizuru_HitMultigs, $00, $3C, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_THROW_ROTR
MoveAnimTbl_Goenitz:
	db $4C, $00, $00, $00, $00, $00, $00, $00 ;X ; MOVE_SHARED_NONE
	mMvAnDef OBJLstPtrTable_Goenitz_Idle, $0C, $02, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_IDLE
	mMvAnDef OBJLstPtrTable_Goenitz_WalkF, $08, $01, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_WALK_F
	mMvAnDef OBJLstPtrTable_Goenitz_WalkB, $08, $02, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_WALK_B
	mMvAnDef OBJLstPtrTable_Goenitz_Crouch, $00, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_CROUCH
	mMvAnDef OBJLstPtrTable_Goenitz_JumpN, $1C, $02, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_JUMP_N
	mMvAnDef OBJLstPtrTable_Goenitz_JumpN, $1C, $02, $00, $00, $00 ;X ; BANK $08 ; MOVE_SHARED_JUMP_F
	mMvAnDef OBJLstPtrTable_Goenitz_JumpN, $1C, $02, $00, $00, $00 ;X ; BANK $08 ; MOVE_SHARED_JUMP_B
	mMvAnDef OBJLstPtrTable_Goenitz_BlockG, $00, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_BLOCK_G
	mMvAnDef OBJLstPtrTable_Goenitz_BlockC, $00, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_BLOCK_C
	mMvAnDef OBJLstPtrTable_Goenitz_BlockA, $00, $FF, $00, $00, $00 ;X ; BANK $08 ; MOVE_SHARED_BLOCK_A
	mMvAnDef OBJLstPtrTable_Goenitz_RunF, $08, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_RUN_F
	mMvAnDef OBJLstPtrTable_Goenitz_HopB, $08, $FF, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_HOP_B
	mMvAnDef OBJLstPtrTable_Goenitz_ChargeMeter, $04, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_CHARGEMETER
	mMvAnDef OBJLstPtrTable_Goenitz_Taunt, $0C, $03, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_TAUNT
	mMvAnDef OBJLstPtrTable_Goenitz_RollF, $10, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_ROLL_F
	mMvAnDef OBJLstPtrTable_Goenitz_RollB, $10, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_ROLL_B
	mMvAnDef OBJLstPtrTable_Goenitz_Wakeup, $04, $02, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_WAKEUP
	mMvAnDef OBJLstPtrTable_Goenitz_Dizzy, $04, $0A, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_DIZZY
	mMvAnDef OBJLstPtrTable_Goenitz_WinA, $0C, $08, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_WIN_A
	mMvAnDef OBJLstPtrTable_Goenitz_WinB, $10, $08, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_WIN_B
	mMvAnDef OBJLstPtrTable_Goenitz_TimeOver, $00, $01, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_LOST_TIMEOVER
	mMvAnDef OBJLstPtrTable_Goenitz_Intro, $10, $08, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_INTRO
	mMvAnDef OBJLstPtrTable_Goenitz_Intro, $10, $08, $00, $00, $00 ;X ; BANK $08 ; MOVE_SHARED_INTRO_SPEC
	mMvAnDef OBJLstPtrTable_Goenitz_PunchL, $08, $00, $04, HITTYPE_HIT_MID0, $00 ; BANK $08 ; MOVE_SHARED_PUNCH_L
	mMvAnDef OBJLstPtrTable_Goenitz_PunchH, $14, $01, $04, HITTYPE_HIT_MID0, $00 ; BANK $08 ; MOVE_SHARED_PUNCH_H
	mMvAnDef OBJLstPtrTable_Goenitz_KickL, $08, $01, $08, HITTYPE_HIT_MID1, $00 ; BANK $08 ; MOVE_SHARED_KICK_L
	mMvAnDef OBJLstPtrTable_Goenitz_KickH, $10, $02, $08, HITTYPE_HIT_MID0, $00 ; BANK $08 ; MOVE_SHARED_KICK_H
	mMvAnDef OBJLstPtrTable_Goenitz_PunchCL, $08, $00, $03, HITTYPE_HIT_MID1, $00 ; BANK $08 ; MOVE_SHARED_PUNCH_CL
	mMvAnDef OBJLstPtrTable_Goenitz_PunchCH, $08, $01, $03, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $08 ; MOVE_SHARED_PUNCH_CH
	mMvAnDef OBJLstPtrTable_Goenitz_KickCL, $08, $00, $06, HITTYPE_HIT_MID1, PF3_HITLOW ; BANK $08 ; MOVE_SHARED_KICK_CL
	mMvAnDef OBJLstPtrTable_Goenitz_KickCH, $0C, $02, $06, HITTYPE_DROP_CH, PF3_HITLOW ; BANK $08 ; MOVE_SHARED_KICK_CH
	mMvAnDef OBJLstPtrTable_Goenitz_AttackG, $08, $03, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $08 ; MOVE_SHARED_ATTACK_G
	mMvAnDef OBJLstPtrTable_Goenitz_PunchA, $10, $01, $05, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $08 ; MOVE_SHARED_PUNCH_A
	mMvAnDef OBJLstPtrTable_Goenitz_KickA, $10, $01, $09, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $08 ; MOVE_SHARED_KICK_A
	mMvAnDef OBJLstPtrTable_Goenitz_AttackA, $10, $01, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_OVERHEAD ; BANK $08 ; MOVE_SHARED_ATTACK_A
	mMvAnDef OBJLstPtrTable_Goenitz_Yonokaze1, $0C, $03, $0A, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_HALFSPEED ; BANK $08 ; MOVE_GOENITZ_YONOKAZE1
	mMvAnDef OBJLstPtrTable_Goenitz_Yonokaze1, $0C, $03, $0A, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_HALFSPEED ; BANK $08 ; MOVE_GOENITZ_YONOKAZE2
	mMvAnDef OBJLstPtrTable_Goenitz_Yonokaze1, $0C, $03, $0A, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_HALFSPEED ; BANK $08 ; MOVE_GOENITZ_YONOKAZE3
	mMvAnDef OBJLstPtrTable_Goenitz_Yonokaze1, $0C, $03, $0A, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_HALFSPEED ; BANK $08 ; MOVE_GOENITZ_YONOKAZE4
	mMvAnDef OBJLstPtrTable_Goenitz_HyougaL, $14, $01, $00, $00, $00 ; BANK $08 ; MOVE_GOENITZ_HYOUGA_L
	mMvAnDef OBJLstPtrTable_Goenitz_HyougaH, $14, $01, $00, $00, $00 ; BANK $08 ; MOVE_GOENITZ_HYOUGA_H
	mMvAnDef OBJLstPtrTable_Goenitz_WanpyouTokobuseL, $20, $01, $02, HITTYPE_HIT_MID1, PF3_LASTHIT|PF3_LIGHTHIT ; BANK $08 ; MOVE_GOENITZ_WANPYOU_TOKOBUSE_L
	mMvAnDef OBJLstPtrTable_Goenitz_WanpyouTokobuseH, $20, $01, $02, HITTYPE_HIT_MID0, PF3_LASTHIT|PF3_LIGHTHIT ; BANK $08 ; MOVE_GOENITZ_WANPYOU_TOKOBUSE_H
	mMvAnDef OBJLstPtrTable_Goenitz_YamidoukokuSl, $18, $05, $00, $00, $00 ; BANK $08 ; MOVE_GOENITZ_YAMIDOUKOKU_SL
	mMvAnDef OBJLstPtrTable_Goenitz_YamidoukokuSl, $18, $05, $00, $00, $00 ; BANK $08 ; MOVE_GOENITZ_YAMIDOUKOKU_SH
	mMvAnDef OBJLstPtrTable_Goenitz_ShinyaotomeThrowL, $00, $02, $0A, $00, $00 ; BANK $08 ; MOVE_GOENITZ_SHINYAOTOME_THROW_L
	mMvAnDef OBJLstPtrTable_Goenitz_ShinyaotomeThrowH, $00, $02, $0A, $00, $00 ; BANK $08 ; MOVE_GOENITZ_SHINYAOTOME_THROW_H
	mMvAnDef OBJLstPtrTable_Goenitz_ShinyaotomePart2L, $14, $00, $02, HITTYPE_HIT_MULTI0, PF3_LASTHIT ; BANK $08 ; MOVE_GOENITZ_SHINYAOTOME_PART2_L
	mMvAnDef OBJLstPtrTable_Goenitz_ShinyaotomePart2L, $14, $00, $02, HITTYPE_HIT_MULTI0, PF3_LASTHIT ; BANK $08 ; MOVE_GOENITZ_SHINYAOTOME_PART2_H
	mMvAnDef OBJLstPtrTable_Goenitz_ShinyaotomeMizuchiSl, $18, $01, $09, HITTYPE_HIT_MULTI1, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $08 ; MOVE_GOENITZ_SHINYAOTOME_MIZUCHI_SL
	mMvAnDef OBJLstPtrTable_Goenitz_ShinyaotomeMizuchiSh, $18, $01, $09, HITTYPE_HIT_MULTI0, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $08 ; MOVE_GOENITZ_SHINYAOTOME_MIZUCHI_SH
	mMvAnDef OBJLstPtrTable_Goenitz_ShinyaotomeJissoukokuDl, $18, $01, $09, HITTYPE_HIT_MULTI1, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $08 ; MOVE_GOENITZ_SHINYAOTOME_JISSOUKOKU_DL
	mMvAnDef OBJLstPtrTable_Goenitz_ShinyaotomeJissoukokuDh, $18, $01, $09, HITTYPE_HIT_MULTI0, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $08 ; MOVE_GOENITZ_SHINYAOTOME_JISSOUKOKU_DH
	mMvAnDef OBJLstPtrTable_Goenitz_ShinyaotomeThrowL, $14, $0A, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_THROW_G
	mMvAnDef OBJLstPtrTable_Goenitz_Idle, $00, $00, $00, $00, $00 ;X ; BANK $08 ; MOVE_SHARED_THROW_A
	mMvAnDef OBJLstPtrTable_Goenitz_BlockG, $00, $05, $00, $00, $00 ;X ; BANK $08 ; MOVE_SHARED_POST_BLOCKSTUN
	mMvAnDef OBJLstPtrTable_Goenitz_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_GUARDBREAK_G
	mMvAnDef OBJLstPtrTable_Goenitz_GuardBreakA, $04, $FF, $00, $00, $00 ;X ; BANK $08 ; MOVE_SHARED_GUARDBREAK_A
	mMvAnDef OBJLstPtrTable_Goenitz_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_HIT0MID
	mMvAnDef OBJLstPtrTable_Goenitz_TimeOver, $00, $05, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_HIT1MID
	mMvAnDef OBJLstPtrTable_Goenitz_Hitlow, $00, $05, $00, $00, $00 ;X ; BANK $08 ; MOVE_SHARED_HITLOW
	mMvAnDef OBJLstPtrTable_Goenitz_DropMain, $10, $05, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_DROP_MAIN
	mMvAnDef OBJLstPtrTable_Goenitz_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_THROW_END_A
	mMvAnDef OBJLstPtrTable_Goenitz_DropDbg, $00, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_DROP_DBG
	mMvAnDef OBJLstPtrTable_Goenitz_HitSwoopup, $18, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_HIT_SWOOPUP
	mMvAnDef OBJLstPtrTable_Goenitz_DropDbg, $08, $02, $00, $00, $00 ;X ; BANK $08 ; MOVE_SHARED_DROP_CH
	mMvAnDef OBJLstPtrTable_Goenitz_BackjumpRecA, $18, $02, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_BACKJUMP_REC_A
	mMvAnDef OBJLstPtrTable_Goenitz_GuardBreakG, $00, $14, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_HIT_MULTIMID0
	mMvAnDef OBJLstPtrTable_Goenitz_TimeOver, $00, $14, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_HIT_MULTIMID1
	mMvAnDef OBJLstPtrTable_Goenitz_HitMultigs, $04, $00, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_HIT_MULTIGS
	mMvAnDef OBJLstPtrTable_Goenitz_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_THROW_END_G
	mMvAnDef OBJLstPtrTable_Goenitz_TimeOver, $00, $3C, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_THROW_START
	mMvAnDef OBJLstPtrTable_Goenitz_TimeOver, $00, $3C, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_THROW_ROTU
	mMvAnDef OBJLstPtrTable_Goenitz_ThrowRotL, $00, $3C, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_THROW_ROTL
	mMvAnDef OBJLstPtrTable_Goenitz_ThrowEndA, $00, $3C, $00, $00, $00 ;X ; BANK $08 ; MOVE_SHARED_THROW_ROTD
	mMvAnDef OBJLstPtrTable_Goenitz_HitMultigs, $00, $3C, $00, $00, $00 ; BANK $08 ; MOVE_SHARED_THROW_ROTR
MoveAnimTbl_MrKarate:
	db $4C, $00, $00, $00, $00, $00, $00, $00 ;X ; MOVE_SHARED_NONE
	mMvAnDef OBJLstPtrTable_MrKarate_Idle, $0C, $02, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_IDLE
	mMvAnDef OBJLstPtrTable_MrKarate_WalkF, $08, $01, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_WALK_F
	mMvAnDef OBJLstPtrTable_MrKarate_WalkB, $08, $02, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_WALK_B
	mMvAnDef OBJLstPtrTable_MrKarate_Crouch, $00, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_CROUCH
	mMvAnDef OBJLstPtrTable_MrKarate_JumpN, $1C, $02, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_JUMP_N
	mMvAnDef OBJLstPtrTable_MrKarate_JumpF, $1C, $02, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_JUMP_F
	mMvAnDef OBJLstPtrTable_MrKarate_JumpB, $1C, $02, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_JUMP_B
	mMvAnDef OBJLstPtrTable_MrKarate_BlockG, $00, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_BLOCK_G
	mMvAnDef OBJLstPtrTable_MrKarate_BlockC, $00, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_BLOCK_C
	mMvAnDef OBJLstPtrTable_MrKarate_BlockA, $00, $FF, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_BLOCK_A
	mMvAnDef OBJLstPtrTable_MrKarate_RunF, $08, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_RUN_F
	mMvAnDef OBJLstPtrTable_MrKarate_HopB, $08, $FF, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_HOP_B
	mMvAnDef OBJLstPtrTable_MrKarate_ChargeMeter, $04, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_CHARGEMETER
	mMvAnDef OBJLstPtrTable_MrKarate_Taunt, $08, $03, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_TAUNT
	mMvAnDef OBJLstPtrTable_MrKarate_RollF, $10, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_ROLL_F
	mMvAnDef OBJLstPtrTable_MrKarate_RollB, $10, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_ROLL_B
	mMvAnDef OBJLstPtrTable_MrKarate_Wakeup, $04, $02, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_WAKEUP
	mMvAnDef OBJLstPtrTable_MrKarate_Dizzy, $04, $0A, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_DIZZY
	mMvAnDef OBJLstPtrTable_MrKarate_WinA, $28, $02, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_WIN_A
	mMvAnDef OBJLstPtrTable_MrKarate_WinA, $28, $02, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_WIN_B
	mMvAnDef OBJLstPtrTable_MrKarate_TimeOver, $00, $01, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_LOST_TIMEOVER
	mMvAnDef OBJLstPtrTable_MrKarate_Intro, $2C, $3C, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_INTRO
	mMvAnDef OBJLstPtrTable_MrKarate_Intro, $2C, $3C, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_INTRO_SPEC
	mMvAnDef OBJLstPtrTable_MrKarate_PunchL, $08, $00, $04, HITTYPE_HIT_MID0, $00 ; BANK $0A ; MOVE_SHARED_PUNCH_L
	mMvAnDef OBJLstPtrTable_MrKarate_PunchH, $0C, $01, $04, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $0A ; MOVE_SHARED_PUNCH_H
	mMvAnDef OBJLstPtrTable_MrKarate_KickL, $08, $01, $08, HITTYPE_HIT_MID1, $00 ; BANK $0A ; MOVE_SHARED_KICK_L
	mMvAnDef OBJLstPtrTable_MrKarate_KickH, $08, $02, $08, HITTYPE_HIT_MID0, $00 ; BANK $0A ; MOVE_SHARED_KICK_H
	mMvAnDef OBJLstPtrTable_MrKarate_PunchCL, $08, $00, $03, HITTYPE_HIT_MID1, $00 ; BANK $0A ; MOVE_SHARED_PUNCH_CL
	mMvAnDef OBJLstPtrTable_MrKarate_PunchCH, $0C, $01, $03, HITTYPE_HIT_MID1, $00 ; BANK $0A ; MOVE_SHARED_PUNCH_CH
	mMvAnDef OBJLstPtrTable_MrKarate_KickCL, $08, $00, $06, HITTYPE_HIT_MID1, PF3_HITLOW ; BANK $0A ; MOVE_SHARED_KICK_CL
	mMvAnDef OBJLstPtrTable_MrKarate_KickCH, $0C, $02, $06, HITTYPE_DROP_CH, PF3_HITLOW ; BANK $0A ; MOVE_SHARED_KICK_CH
	mMvAnDef OBJLstPtrTable_MrKarate_AttackG, $0C, $03, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $0A ; MOVE_SHARED_ATTACK_G
	mMvAnDef OBJLstPtrTable_MrKarate_PunchA, $10, $01, $05, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $0A ; MOVE_SHARED_PUNCH_A
	mMvAnDef OBJLstPtrTable_MrKarate_KickA, $10, $01, $09, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $0A ; MOVE_SHARED_KICK_A
	mMvAnDef OBJLstPtrTable_MrKarate_AttackA, $10, $01, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_OVERHEAD ; BANK $0A ; MOVE_SHARED_ATTACK_A
	mMvAnDef OBJLstPtrTable_MrKarate_KoOuKenL, $0C, $01, $0A, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_HALFSPEED ; BANK $0A ; MOVE_MRKARATE_KO_OU_KEN_L
	mMvAnDef OBJLstPtrTable_MrKarate_KoOuKenL, $0C, $03, $0A, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_HALFSPEED ; BANK $0A ; MOVE_MRKARATE_KO_OU_KEN_H
	mMvAnDef OBJLstPtrTable_MrKarate_ShouranKyakuL, $14, $01, $01, HITTYPE_HIT_MULTI1, PF3_LASTHIT ; BANK $0A ; MOVE_MRKARATE_SHOURAN_KYAKU_L
	mMvAnDef OBJLstPtrTable_MrKarate_ShouranKyakuL, $14, $02, $01, HITTYPE_HIT_MULTI1, PF3_LASTHIT ; BANK $0A ; MOVE_MRKARATE_SHOURAN_KYAKU_H
	mMvAnDef OBJLstPtrTable_MrKarate_HienShippuuKyakuL, $20, $01, $04, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $0A ; MOVE_MRKARATE_HIEN_SHIPPUU_KYAKU_L
	mMvAnDef OBJLstPtrTable_MrKarate_HienShippuuKyakuL, $20, $01, $04, HITTYPE_DROP_MAIN, PF3_LASTHIT ; BANK $0A ; MOVE_MRKARATE_HIEN_SHIPPUU_KYAKU_H
	mMvAnDef OBJLstPtrTable_MrKarate_ZenretsukenL, $18, $01, $01, HITTYPE_HIT_MULTI1, PF3_LASTHIT ; BANK $0A ; MOVE_MRKARATE_ZENRETSUKEN_L
	mMvAnDef OBJLstPtrTable_MrKarate_ZenretsukenL, $18, $01, $01, HITTYPE_HIT_MULTI1, PF3_LASTHIT ; BANK $0A ; MOVE_MRKARATE_ZENRETSUKEN_H
	mMvAnDef OBJLstPtrTable_MrKarate_KyokukenRyuRenbuKenL, $14, $01, $04, HITTYPE_HIT_MID1, PF3_HITLOW|PF3_OVERHEAD|PF3_LASTHIT ; BANK $0A ; MOVE_MRKARATE_KYOKUKEN_RYU_RENBU_KEN_L
	mMvAnDef OBJLstPtrTable_MrKarate_KyokukenRyuRenbuKenL, $14, $01, $04, HITTYPE_HIT_MID1, PF3_HITLOW|PF3_OVERHEAD|PF3_LASTHIT ; BANK $0A ; MOVE_MRKARATE_KYOKUKEN_RYU_RENBU_KEN_H
IF REV_VER_2 == 0
	mMvAnDef OBJLstPtrTable_MrKarate_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $0A ; MOVE_MRKARATE_KO_OU_KEN_UNUSED_EL
	mMvAnDef OBJLstPtrTable_MrKarate_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $0A ; MOVE_MRKARATE_KO_OU_KEN_UNUSED_EH
ELSE
	mMvAnDef OBJLstPtrTable_MrKarate_HopB, $18, $FF, $0C, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ;X ; BANK $0A ; MOVE_MRKARATE_SPEC_5_L
	mMvAnDef OBJLstPtrTable_MrKarate_HopB, $18, $FF, $0C, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ; BANK $0A ; MOVE_MRKARATE_RYUKO_RANBU_D3
ENDC
	mMvAnDef OBJLstPtrTable_MrKarate_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $0A ; MOVE_MRKARATE_SPEC_6_L
	mMvAnDef OBJLstPtrTable_MrKarate_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $0A ; MOVE_MRKARATE_SPEC_6_H
	mMvAnDef OBJLstPtrTable_MrKarate_RyukoRanbuS, $18, $01, $01, HITTYPE_HIT_MULTI1, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $0A ; MOVE_MRKARATE_RYUKO_RANBU_S
	mMvAnDef OBJLstPtrTable_MrKarate_RyukoRanbuUnusedD, $18, $01, $01, HITTYPE_HIT_MULTI1, PF3_HEAVYHIT|PF3_LASTHIT ;X ; BANK $0A ; MOVE_MRKARATE_RYUKO_RANBU_UNUSED_D
	mMvAnDef OBJLstPtrTable_MrKarate_HaohShoKohKenS, $18, $01, $10, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_HALFSPEED ; BANK $0A ; MOVE_MRKARATE_HAOH_SHO_KOH_KEN_S
	mMvAnDef OBJLstPtrTable_MrKarate_HaohShoKohKenS, $18, $01, $14, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ; BANK $0A ; MOVE_MRKARATE_HAOH_SHO_KOH_KEN_D
	mMvAnDef OBJLstPtrTable_MrKarate_ThrowG, $14, $0A, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_THROW_G
	mMvAnDef OBJLstPtrTable_MrKarate_Idle, $00, $00, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_THROW_A
	mMvAnDef OBJLstPtrTable_MrKarate_BlockG, $00, $05, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_POST_BLOCKSTUN
	mMvAnDef OBJLstPtrTable_MrKarate_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_GUARDBREAK_G
	mMvAnDef OBJLstPtrTable_MrKarate_GuardBreakA, $04, $FF, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_GUARDBREAK_A
	mMvAnDef OBJLstPtrTable_MrKarate_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_HIT0MID
	mMvAnDef OBJLstPtrTable_MrKarate_TimeOver, $00, $05, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_HIT1MID
	mMvAnDef OBJLstPtrTable_MrKarate_Hitlow, $00, $05, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_HITLOW
	mMvAnDef OBJLstPtrTable_MrKarate_DropMain, $10, $05, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_DROP_MAIN
	mMvAnDef OBJLstPtrTable_MrKarate_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_THROW_END_A
	mMvAnDef OBJLstPtrTable_MrKarate_DropDbg, $00, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_DROP_DBG
	mMvAnDef OBJLstPtrTable_MrKarate_HitSwoopup, $18, $00, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_HIT_SWOOPUP
	mMvAnDef OBJLstPtrTable_MrKarate_DropDbg, $08, $02, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_DROP_CH
	mMvAnDef OBJLstPtrTable_MrKarate_BackjumpRecA, $18, $02, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_BACKJUMP_REC_A
	mMvAnDef OBJLstPtrTable_MrKarate_GuardBreakG, $00, $14, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_HIT_MULTIMID0
	mMvAnDef OBJLstPtrTable_MrKarate_TimeOver, $00, $14, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_HIT_MULTIMID1
	mMvAnDef OBJLstPtrTable_MrKarate_HitMultigs, $04, $00, $00, $00, $00 ;X ; BANK $0A ; MOVE_SHARED_HIT_MULTIGS
	mMvAnDef OBJLstPtrTable_MrKarate_ThrowEndA, $0C, $FF, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_THROW_END_G
	mMvAnDef OBJLstPtrTable_MrKarate_TimeOver, $00, $3C, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_THROW_START
	mMvAnDef OBJLstPtrTable_MrKarate_TimeOver, $00, $3C, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_THROW_ROTU
	mMvAnDef OBJLstPtrTable_MrKarate_ThrowRotL, $00, $3C, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_THROW_ROTL
	mMvAnDef OBJLstPtrTable_MrKarate_ThrowEndA, $00, $3C, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_THROW_ROTD
	mMvAnDef OBJLstPtrTable_MrKarate_HitMultigs, $00, $3C, $00, $00, $00 ; BANK $0A ; MOVE_SHARED_THROW_ROTR
MoveAnimTbl_OIori:
	db $4C, $00, $00, $00, $00, $00, $00, $00 ;X ; MOVE_SHARED_NONE
	mMvAnDef OBJLstPtrTable_OIori_Idle, $0C, $06, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_IDLE
	mMvAnDef OBJLstPtrTable_Iori_WalkF, $0C, $01, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_WALK_F
	mMvAnDef OBJLstPtrTable_Iori_WalkB, $0C, $02, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_WALK_B
	mMvAnDef OBJLstPtrTable_Iori_Crouch, $00, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_CROUCH
	mMvAnDef OBJLstPtrTable_Iori_JumpN, $1C, $02, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_JUMP_N
	mMvAnDef OBJLstPtrTable_Iori_JumpN, $1C, $02, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_JUMP_F
	mMvAnDef OBJLstPtrTable_Iori_JumpN, $1C, $02, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_JUMP_B
	mMvAnDef OBJLstPtrTable_Iori_BlockG, $00, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_BLOCK_G
	mMvAnDef OBJLstPtrTable_Iori_BlockC, $00, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_BLOCK_C
	mMvAnDef OBJLstPtrTable_Iori_BlockA, $00, $FF, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_BLOCK_A
	mMvAnDef OBJLstPtrTable_Iori_RunF, $08, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_RUN_F
	mMvAnDef OBJLstPtrTable_Iori_HopB, $08, $FF, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_HOP_B
	mMvAnDef OBJLstPtrTable_OIori_ChargeMeter, $04, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_CHARGEMETER
	mMvAnDef OBJLstPtrTable_Iori_Taunt, $08, $08, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_TAUNT
	mMvAnDef OBJLstPtrTable_Iori_RollF, $10, $02, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_ROLL_F
	mMvAnDef OBJLstPtrTable_Iori_RollB, $10, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_ROLL_B
	mMvAnDef OBJLstPtrTable_Iori_Wakeup, $04, $02, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_WAKEUP
	mMvAnDef OBJLstPtrTable_Iori_Dizzy, $04, $0A, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_DIZZY
	mMvAnDef OBJLstPtrTable_Iori_WinA, $50, $02, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_WIN_A
	mMvAnDef OBJLstPtrTable_OIori_WinB, $10, $00, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_WIN_B
	mMvAnDef OBJLstPtrTable_Iori_TimeOver, $00, $09, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_LOST_TIMEOVER
	mMvAnDef OBJLstPtrTable_OIori_Intro, $1C, $3C, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_INTRO
	mMvAnDef OBJLstPtrTable_OIori_Intro, $1C, $3C, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_INTRO_SPEC
	mMvAnDef OBJLstPtrTable_Iori_PunchL, $08, $00, $04, HITTYPE_HIT_MID0, $00 ; BANK $05 ; MOVE_SHARED_PUNCH_L
	mMvAnDef OBJLstPtrTable_Iori_PunchH, $0C, $01, $04, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $05 ; MOVE_SHARED_PUNCH_H
	mMvAnDef OBJLstPtrTable_Iori_KickL, $08, $01, $08, HITTYPE_HIT_MID1, PF3_HITLOW ; BANK $05 ; MOVE_SHARED_KICK_L
	mMvAnDef OBJLstPtrTable_Iori_KickH, $0C, $02, $08, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $05 ; MOVE_SHARED_KICK_H
	mMvAnDef OBJLstPtrTable_Iori_PunchCL, $08, $00, $03, HITTYPE_HIT_MID1, $00 ; BANK $05 ; MOVE_SHARED_PUNCH_CL
	mMvAnDef OBJLstPtrTable_Iori_PunchCH, $0C, $01, $03, HITTYPE_HIT_MID1, PF3_HEAVYHIT ; BANK $05 ; MOVE_SHARED_PUNCH_CH
	mMvAnDef OBJLstPtrTable_Iori_KickCL, $08, $00, $06, HITTYPE_HIT_MID1, PF3_HITLOW ; BANK $05 ; MOVE_SHARED_KICK_CL
	mMvAnDef OBJLstPtrTable_Iori_KickCH, $10, $04, $06, HITTYPE_DROP_CH, PF3_HITLOW ; BANK $05 ; MOVE_SHARED_KICK_CH
	mMvAnDef OBJLstPtrTable_Iori_AttackG, $08, $04, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT ; BANK $05 ; MOVE_SHARED_ATTACK_G
	mMvAnDef OBJLstPtrTable_Iori_PunchA, $10, $01, $05, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $05 ; MOVE_SHARED_PUNCH_A
	mMvAnDef OBJLstPtrTable_Iori_KickA, $10, $01, $09, HITTYPE_HIT_MID0, PF3_OVERHEAD ; BANK $05 ; MOVE_SHARED_KICK_A
	mMvAnDef OBJLstPtrTable_Iori_AttackA, $10, $01, $06, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_OVERHEAD ; BANK $05 ; MOVE_SHARED_ATTACK_A
	mMvAnDef OBJLstPtrTable_Iori_YamiBaraiL, $10, $01, $0A, HITTYPE_HIT_MID0, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ; BANK $05 ; MOVE_IORI_YAMI_BARAI_L
	mMvAnDef OBJLstPtrTable_Iori_YamiBaraiL, $10, $03, $0A, HITTYPE_HIT_MID0, PF3_HEAVYHIT|PF3_FIRE|PF3_HALFSPEED ; BANK $05 ; MOVE_IORI_YAMI_BARAI_H
	mMvAnDef OBJLstPtrTable_OIori_IoriOniYakiL, $14, $01, $09, HITTYPE_HIT_MID1, PF3_HEAVYHIT|PF3_FIRE|PF3_LASTHIT ; BANK $05 ; MOVE_IORI_ONI_YAKI_L
	mMvAnDef OBJLstPtrTable_OIori_IoriOniYakiL, $14, $01, $09, HITTYPE_DROP_MAIN, PF3_HEAVYHIT|PF3_FIRE|PF3_LASTHIT ; BANK $05 ; MOVE_IORI_ONI_YAKI_H
	mMvAnDef OBJLstPtrTable_Iori_AoiHanaL, $14, $01, $04, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $05 ; MOVE_IORI_AOI_HANA_L
	mMvAnDef OBJLstPtrTable_Iori_AoiHanaL, $14, $01, $04, HITTYPE_HIT_MID1, PF3_LASTHIT ; BANK $05 ; MOVE_IORI_AOI_HANA_H
	mMvAnDef OBJLstPtrTable_OIori_IoriKotoTsukiInL, $1C, $01, $09, HITTYPE_HIT_MID0, PF3_LASTHIT ; BANK $05 ; MOVE_IORI_KOTO_TSUKI_IN_L
	mMvAnDef OBJLstPtrTable_OIori_IoriKotoTsukiInL, $1C, $01, $09, HITTYPE_HIT_MID0, PF3_LASTHIT ; BANK $05 ; MOVE_IORI_KOTO_TSUKI_IN_H
	mMvAnDef OBJLstPtrTable_Iori_ScumGaleL, $00, $04, $00, $00, $00 ;X ; BANK $05 ; MOVE_IORI_SCUM_GALE_L
	mMvAnDef OBJLstPtrTable_Iori_ScumGaleL, $00, $04, $00, $00, $00 ; BANK $05 ; MOVE_IORI_SCUM_GALE_H
	mMvAnDef OBJLstPtrTable_OIori_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $05 ; MOVE_IORI_SPEC_5_L
	mMvAnDef OBJLstPtrTable_OIori_Idle, $00, $02, $0A, HITTYPE_DUMMY, $00 ;X ; BANK $05 ; MOVE_IORI_SPEC_5_H
	mMvAnDef OBJLstPtrTable_Iori_KinYaOtomeEscapeL, $00, $02, $01, HITTYPE_HIT_MULTIGS, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $05 ; MOVE_IORI_KIN_YA_OTOME_ESCAPE_L
	mMvAnDef OBJLstPtrTable_Iori_KinYaOtomeEscapeL, $00, $02, $01, HITTYPE_HIT_MULTIGS, PF3_HEAVYHIT|PF3_LASTHIT ;X ; BANK $05 ; MOVE_IORI_KIN_YA_OTOME_ESCAPE_H
	mMvAnDef OBJLstPtrTable_Iori_KinYaOtomeS, $48, $0C, $09, HITTYPE_HIT_MULTI0, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $05 ; MOVE_IORI_KIN_YA_OTOME_S
	mMvAnDef OBJLstPtrTable_Iori_KinYaOtomeD, $48, $0C, $09, HITTYPE_HIT_MULTI0, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $05 ; MOVE_IORI_KIN_YA_OTOME_D
	mMvAnDef OBJLstPtrTable_OIori_KinYaOtomeS, $48, $0C, $09, HITTYPE_HIT_MULTI0, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $05 ; MOVE_OIORI_KIN_YA_OTOME_S
	mMvAnDef OBJLstPtrTable_OIori_KinYaOtomeS, $48, $0C, $09, HITTYPE_HIT_MULTI0, PF3_HEAVYHIT|PF3_LASTHIT ; BANK $05 ; MOVE_OIORI_KIN_YA_OTOME_D
	mMvAnDef OBJLstPtrTable_Iori_ThrowG, $0C, $0A, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_THROW_G
	mMvAnDef OBJLstPtrTable_OIori_Idle, $00, $00, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_THROW_A
	mMvAnDef OBJLstPtrTable_Iori_BlockG, $00, $05, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_POST_BLOCKSTUN
	mMvAnDef OBJLstPtrTable_Iori_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_GUARDBREAK_G
	mMvAnDef OBJLstPtrTable_Iori_GuardBreakA, $04, $FF, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_GUARDBREAK_A
	mMvAnDef OBJLstPtrTable_Iori_GuardBreakG, $00, $05, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_HIT0MID
	mMvAnDef OBJLstPtrTable_Iori_Hit1mid, $00, $05, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_HIT1MID
	mMvAnDef OBJLstPtrTable_Iori_Hitlow, $00, $05, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_HITLOW
	mMvAnDef OBJLstPtrTable_Iori_DropMain, $10, $05, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_DROP_MAIN
	mMvAnDef OBJLstPtrTable_Iori_ThrowEndA, $0C, $FF, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_THROW_END_A
	mMvAnDef OBJLstPtrTable_Iori_DropDbg, $00, $00, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_DROP_DBG
	mMvAnDef OBJLstPtrTable_Iori_HitSwoopup, $18, $00, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_HIT_SWOOPUP
	mMvAnDef OBJLstPtrTable_Iori_DropDbg, $08, $02, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_DROP_CH
	mMvAnDef OBJLstPtrTable_Iori_BackjumpRecA, $18, $02, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_BACKJUMP_REC_A
	mMvAnDef OBJLstPtrTable_Iori_GuardBreakG, $00, $14, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_HIT_MULTIMID0
	mMvAnDef OBJLstPtrTable_Iori_Hit1mid, $00, $14, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_HIT_MULTIMID1
	mMvAnDef OBJLstPtrTable_Iori_HitMultigs, $04, $00, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_HIT_MULTIGS
	mMvAnDef OBJLstPtrTable_Iori_ThrowEndA, $0C, $FF, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_THROW_END_G
	mMvAnDef OBJLstPtrTable_Iori_Hit1mid, $00, $3C, $00, $00, $00 ; BANK $05 ; MOVE_SHARED_THROW_START
	mMvAnDef OBJLstPtrTable_Iori_Hit1mid, $00, $3C, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_THROW_ROTU
	mMvAnDef OBJLstPtrTable_Iori_ThrowRotL, $00, $3C, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_THROW_ROTL
	mMvAnDef OBJLstPtrTable_Iori_ThrowEndA, $00, $3C, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_THROW_ROTD
	mMvAnDef OBJLstPtrTable_Iori_HitMultigs, $00, $3C, $00, $00, $00 ;X ; BANK $05 ; MOVE_SHARED_THROW_ROTR

; =============== MoveCodePtrTbl_* ===============
; Code pointers assigned to every move.
; These follow the groups mentioned in Play_DoPl.execMoveCode.
;
; NOTES
; - Characters with no air throws reuse MoveC_Base_Idle.
MoveCodePtrTbl_Shared_Base:
	dpr MoveC_Base_None ; BANK $02 ; MOVE_SHARED_NONE         
	dpr MoveC_Base_Idle ; BANK $02 ; MOVE_SHARED_IDLE         
	dpr MoveC_Base_WalkH ; BANK $02 ; MOVE_SHARED_WALK_F       
	dpr MoveC_Base_WalkH ; BANK $02 ; MOVE_SHARED_WALK_B       
	dpr MoveC_Base_NoAnim ; BANK $02 ; MOVE_SHARED_CROUCH       
	; Improper bank number defined for these
	dw MoveC_Base_Jump ; BANK $00 ; MOVE_SHARED_JUMP_N     
	db $02	
	dw MoveC_Base_Jump ; BANK $00 ; MOVE_SHARED_JUMP_F       
	db $02
	dw MoveC_Base_Jump ; BANK $00 ; MOVE_SHARED_JUMP_B
	db $02
	dpr MoveC_Base_NoAnim ; BANK $02 ; MOVE_SHARED_BLOCK_G      
	dpr MoveC_Base_NoAnim ; BANK $02 ; MOVE_SHARED_BLOCK_C      
	dpr MoveC_Base_BlockA ; BANK $02 ; MOVE_SHARED_BLOCK_A      
	dpr MoveC_Base_RunF ; BANK $02 ; MOVE_SHARED_RUN_F       
	dpr MoveC_Base_DashB ; BANK $02 ; MOVE_SHARED_HOP_B       
	dpr MoveC_Base_ChargeMeter ; BANK $02 ; MOVE_SHARED_CHARGEMETER  
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_TAUNT        
	dpr MoveC_Base_Roll ; BANK $02 ; MOVE_SHARED_ROLL_F       
	dpr MoveC_Base_Roll ; BANK $02 ; MOVE_SHARED_ROLL_B       
	dpr MoveC_Base_WakeUp ; BANK $02 ; MOVE_SHARED_WAKEUP       
	dpr MoveC_Base_Dizzy ; BANK $02 ; MOVE_SHARED_DIZZY        
	dpr MoveC_Base_RoundEnd ; BANK $02 ; MOVE_SHARED_WIN_A     
	dpr MoveC_Base_RoundEnd ; BANK $02 ; MOVE_SHARED_WIN_B      
	dpr MoveC_Base_RoundEnd ; BANK $02 ; MOVE_SHARED_LOST_TIMEOVER
	dpr MoveC_Base_RoundStart ; BANK $02 ; MOVE_SHARED_INTRO        
	dpr MoveC_Base_RoundStart ; BANK $02 ; MOVE_SHARED_INTRO_SPEC   
MoveCodePtrTbl_Shared_Hit:
	dpr MoveC_Hit_PostStunKnockback ; BANK $02 ; MOVE_SHARED_POST_BLOCKSTUN
	dpr MoveC_Hit_PostStunKnockback ; BANK $02 ; MOVE_SHARED_GUARDBREAK_G
	dpr MoveC_Hit_GuardBreakA ; BANK $02 ; MOVE_SHARED_GUARDBREAK_A
	dpr MoveC_Hit_PostStunKnockback ; BANK $02 ; MOVE_SHARED_HIT0MID
	dpr MoveC_Hit_PostStunKnockback ; BANK $02 ; MOVE_SHARED_HIT1MID
	dpr MoveC_Hit_PostStunKnockback ; BANK $02 ; MOVE_SHARED_HITLOW
	dpr MoveC_Hit_DropMain ; BANK $02 ; MOVE_SHARED_DROP_MAIN
	dpr MoveC_Hit_Throw_End ; BANK $02 ; MOVE_SHARED_THROW_END_A
	dpr MoveC_Hit_DropDBG ; BANK $02 ; MOVE_SHARED_DROP_DBG
	dpr MoveC_Hit_SwoopUp ; BANK $02 ; MOVE_SHARED_HIT_SWOOPUP
	dpr MoveC_Hit_DropCH ; BANK $02 ; MOVE_SHARED_DROP_CH
	dpr MoveC_Hit_BackJumpAirRec ; BANK $02 ; MOVE_SHARED_BACKJUMP_REC_A
	dpr MoveC_Hit_MultiMidKnockback ; BANK $02 ; MOVE_SHARED_HIT_MULTIMID0
	dpr MoveC_Hit_MultiMidKnockback ; BANK $02 ; MOVE_SHARED_HIT_MULTIMID1
	dpr MoveC_Hit_MultiMidGS ; BANK $02 ; MOVE_SHARED_HIT_MULTIGS
	dpr MoveC_Hit_Throw_End ; BANK $02 ; MOVE_SHARED_THROW_END_G
	dpr MoveC_Hit_Throw_Start ; BANK $02 ; MOVE_SHARED_THROW_START
	dpr MoveC_Hit_Throw_Rot ; BANK $02 ; MOVE_SHARED_THROW_ROTU
	dpr MoveC_Hit_Throw_Rot ; BANK $02 ; MOVE_SHARED_THROW_ROTL
	dpr MoveC_Hit_Throw_Rot ; BANK $02 ; MOVE_SHARED_THROW_ROTD
	dpr MoveC_Hit_Throw_Rot ; BANK $02 ; MOVE_SHARED_THROW_ROTR
MoveCodePtrTbl_Kyo:
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_L
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_PUNCH_H
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_KICK_L
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_KICK_H
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_CL
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_PUNCH_CH
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_KICK_CL
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_KICK_CH
	dpr MoveC_Base_AttackG_SF04M0040 ; BANK $06 ; MOVE_SHARED_ATTACK_G
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_PUNCH_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_KICK_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_ATTACK_A
	dpr MoveC_Kyo_AraKami ; BANK $06 ; MOVE_KYO_ARA_KAMI_L
	dpr MoveC_Kyo_DokuKami ; BANK $06 ; MOVE_KYO_ARA_KAMI_H
	dpr MoveC_Kyo_OniYaki ; BANK $06 ; MOVE_KYO_ONIYAKI_L
	dpr MoveC_Kyo_OniYaki ; BANK $06 ; MOVE_KYO_ONIYAKI_H
	dpr MoveC_Kyo_RedKick ; BANK $06 ; MOVE_KYO_RED_KICK_L
	dpr MoveC_Kyo_RedKick ; BANK $06 ; MOVE_KYO_RED_KICK_H
	dpr MoveC_Kyo_KototsukiYou ; BANK $06 ; MOVE_KYO_KOTOTSUKI_YOU_L
	dpr MoveC_Kyo_KototsukiYou ; BANK $06 ; MOVE_KYO_KOTOTSUKI_YOU_H
	dpr MoveC_Kyo_Kai ; BANK $06 ; MOVE_KYO_KAI_L
	dpr MoveC_Kyo_Kai ; BANK $06 ; MOVE_KYO_KAI_H
	dpr MoveC_Kyo_NueTumi ; BANK $06 ; MOVE_KYO_NUE_TUMI_L
	dpr MoveC_Kyo_NueTumi ; BANK $06 ; MOVE_KYO_NUE_TUMI_H
	dpr MoveC_Kyo_AraKami ;X ; BANK $06 ; MOVE_KYO_SPEC_6_L
	dpr MoveC_Kyo_AraKami ;X ; BANK $06 ; MOVE_KYO_SPEC_6_H
	dpr MoveC_Kyo_UraOrochiNagi ; BANK $06 ; MOVE_KYO_URA_OROCHI_NAGI_S
	dpr MoveC_Kyo_UraOrochiNagi ; BANK $06 ; MOVE_KYO_URA_OROCHI_NAGI_D
	dpr MoveC_Kyo_UraOrochiNagi ;X ; BANK $06 ; MOVE_KYO_SUPER_1_S
	dpr MoveC_Kyo_UraOrochiNagi ;X ; BANK $06 ; MOVE_KYO_SUPER_1_D
	dpr MoveC_Kyo_ThrowG ; BANK $02 ; MOVE_SHARED_THROW_G
	dpr MoveC_Base_Idle ;X ; BANK $02 ; MOVE_SHARED_THROW_A
MoveCodePtrTbl_Daimon:
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_L
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_PUNCH_H
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_KICK_L
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_KICK_H
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_CL
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_PUNCH_CH
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_KICK_CL
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_KICK_CH
	dpr MoveC_Base_AttackG_SF04M0040 ; BANK $06 ; MOVE_SHARED_ATTACK_G
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_PUNCH_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_KICK_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_ATTACK_A
	dpr MoveC_Daimon_JiraiShin ; BANK $05 ; MOVE_DAIMON_JIRAI_SHIN
	dpr MoveC_Daimon_JiraiShin ; BANK $05 ; MOVE_DAIMON_JIRAI_SHIN_FAKE
	dpr MoveC_Daimon_ChouUkemi ; BANK $05 ; MOVE_DAIMON_CHOU_UKEMI_L
	dpr MoveC_Daimon_ChouUkemi ; BANK $05 ; MOVE_DAIMON_CHOU_UKEMI_H
	dpr MoveC_Daimon_CmdThrow ; BANK $05 ; MOVE_DAIMON_CHOU_OOSOTO_GARI_L
	dpr MoveC_Daimon_CmdThrow ; BANK $05 ; MOVE_DAIMON_CHOU_OOSOTO_GARI_H
	dpr MoveC_Daimon_CmdThrow ; BANK $05 ; MOVE_DAIMON_CLOUD_TOSSER
	dpr MoveC_Daimon_CmdThrow ; BANK $05 ; MOVE_DAIMON_STUMP_THROW
	dpr MoveC_Daimon_HeavenDrop ; BANK $05 ; MOVE_DAIMON_HEAVEN_DROP_L
	dpr MoveC_Daimon_HeavenDrop ; BANK $05 ; MOVE_DAIMON_HEAVEN_DROP_H
	dpr MoveC_Daimon_JiraiShin ;X ; BANK $05 ; MOVE_DAIMON_SPEC_5_L
	dpr MoveC_Daimon_JiraiShin ;X ; BANK $05 ; MOVE_DAIMON_SPEC_5_H
	dpr MoveC_Daimon_JiraiShin ;X ; BANK $05 ; MOVE_DAIMON_SPEC_6_L
	dpr MoveC_Daimon_JiraiShin ;X ; BANK $05 ; MOVE_DAIMON_SPEC_6_H
	dpr MoveC_Daimon_HeavenHellDrop ; BANK $05 ; MOVE_DAIMON_HEAVEN_HELL_DROP_S
	dpr MoveC_Daimon_HeavenHellDrop ; BANK $05 ; MOVE_DAIMON_HEAVEN_HELL_DROP_D
	dpr MoveC_Daimon_HeavenHellDrop ;X ; BANK $05 ; MOVE_DAIMON_SUPER_1_S
	dpr MoveC_Daimon_HeavenHellDrop ;X ; BANK $05 ; MOVE_DAIMON_SUPER_1_D
	dpr MoveC_Daimon_ThrowG ; BANK $02 ; MOVE_SHARED_THROW_G
	dpr MoveC_Base_Idle ;X ; BANK $02 ; MOVE_SHARED_THROW_A
MoveCodePtrTbl_Andy:
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_L
	dpr MoveC_Base_NormH_2Hit_D06_A04 ; BANK $1C ; MOVE_SHARED_PUNCH_H
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_KICK_L
	dpr MoveC_Base_NormH_2Hit_D06_A04 ; BANK $1C ; MOVE_SHARED_KICK_H
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_CL
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_PUNCH_CH
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_KICK_CL
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_KICK_CH
	dpr MoveC_Base_AttackG_MF07 ; BANK $06 ; MOVE_SHARED_ATTACK_G
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_PUNCH_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_KICK_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_ATTACK_A
	dpr MoveC_Andy_HiShoKen ; BANK $06 ; MOVE_ANDY_HI_SHO_KEN_L
	dpr MoveC_Andy_HiShoKen ; BANK $06 ; MOVE_ANDY_HI_SHO_KEN_H
	dpr MoveC_Andy_ZanEiKen ; BANK $06 ; MOVE_ANDY_ZAN_EI_KEN_L
	dpr MoveC_Andy_ZanEiKen ; BANK $06 ; MOVE_ANDY_ZAN_EI_KEN_H
	dpr MoveC_Andy_KuHaDan ; BANK $06 ; MOVE_ANDY_KU_HA_DAN_L
	dpr MoveC_Andy_KuHaDan ; BANK $06 ; MOVE_ANDY_KU_HA_DAN_H
	dpr MoveC_Andy_ShoRyuDan ; BANK $06 ; MOVE_ANDY_SHO_RYU_DAN_L
	dpr MoveC_Andy_ShoRyuDan ; BANK $06 ; MOVE_ANDY_SHO_RYU_DAN_H
	dpr MoveC_Andy_GekiHekiHaiSuiSho ; BANK $06 ; MOVE_ANDY_GEKI_HEKI_HAI_SUI_SHO_L
	dpr MoveC_Andy_GekiHekiHaiSuiSho ; BANK $06 ; MOVE_ANDY_GEKI_HEKI_HAI_SUI_SHO_H
	dpr MoveC_Andy_GeneiShiranui ; BANK $06 ; MOVE_ANDY_GENEI_SHIRANUI_L
	dpr MoveC_Andy_GeneiShiranui ; BANK $06 ; MOVE_ANDY_GENEI_SHIRANUI_H
	dpr MoveC_Andy_GeneiShiranuiSubmove ; BANK $06 ; MOVE_ANDY_SHIMO_AGITO
	dpr MoveC_Andy_GeneiShiranuiSubmove ; BANK $06 ; MOVE_ANDY_UWA_AGITO
	dpr MoveC_Andy_ChoReppaDan ; BANK $06 ; MOVE_ANDY_CHO_REPPA_DAN_S
	dpr MoveC_Andy_ChoReppaDan ; BANK $06 ; MOVE_ANDY_CHO_REPPA_DAN_D
	dpr MoveC_Andy_ChoReppaDan ;X ; BANK $06 ; MOVE_ANDY_SUPER_1_S
	dpr MoveC_Andy_ChoReppaDan ;X ; BANK $06 ; MOVE_ANDY_SUPER_1_D
	dpr MoveC_Andy_ThrowG ; BANK $02 ; MOVE_SHARED_THROW_G
	dpr MoveC_Base_Idle ;X ; BANK $02 ; MOVE_SHARED_THROW_A
MoveCodePtrTbl_Robert:
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_L
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_PUNCH_H
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_KICK_L
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_KICK_H
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_CL
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_PUNCH_CH
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_KICK_CL
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_KICK_CH
	dpr MoveC_Base_AttackG_MF07 ; BANK $06 ; MOVE_SHARED_ATTACK_G
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_PUNCH_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_KICK_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_ATTACK_A
	dpr MoveC_Robert_RyuuGekiKen ; BANK $02 ; MOVE_ROBERT_RYUU_GEKI_KEN_L
	dpr MoveC_Robert_RyuuGekiKen ; BANK $02 ; MOVE_ROBERT_RYUU_GEKI_KEN_H
	dpr MoveC_Robert_HienShippuKyaku ; BANK $02 ; MOVE_ROBERT_HIEN_SHIPPU_KYAKU_L
	dpr MoveC_Robert_HienShippuKyaku ; BANK $02 ; MOVE_ROBERT_HIEN_SHIPPU_KYAKU_H
	dpr MoveC_Robert_HienRyuuShinKya ; BANK $02 ; MOVE_ROBERT_HIEN_RYUU_SHIN_KYA_L
	dpr MoveC_Robert_HienRyuuShinKya ; BANK $02 ; MOVE_ROBERT_HIEN_RYUU_SHIN_KYA_H
	dpr MoveC_Robert_RyuuGa ; BANK $02 ; MOVE_ROBERT_RYUU_GA_L
	dpr MoveC_Robert_RyuuGa ; BANK $02 ; MOVE_ROBERT_RYUU_GA_H
	dpr MoveC_Robert_KyokugenRyuRanbuKyaku ; BANK $02 ; MOVE_ROBERT_KYOKUGEN_RYU_RANBU_KYAKU_L
	dpr MoveC_Robert_KyokugenRyuRanbuKyaku ; BANK $02 ; MOVE_ROBERT_KYOKUGEN_RYU_RANBU_KYAKU_H
	dpr MoveC_Terry_RisingTackle ; BANK $02 ; MOVE_ROBERT_RYUU_GA_HIDDEN_L
	dpr MoveC_Terry_RisingTackle ; BANK $02 ; MOVE_ROBERT_RYUU_GA_HIDDEN_H
	dpr MoveC_Robert_RyuuGekiKen ;X ; BANK $02 ; MOVE_ROBERT_SPEC_6_L
	dpr MoveC_Robert_RyuuGekiKen ;X ; BANK $02 ; MOVE_ROBERT_SPEC_6_H
	dpr MoveC_Robert_RyuKoRanbuS ; BANK $02 ; MOVE_ROBERT_RYU_KO_RANBU_S
	dpr MoveC_Robert_RyuKoRanbuD ; BANK $02 ; MOVE_ROBERT_RYU_KO_RANBU_D
	dpr MoveC_Robert_HaohShokohKen ; BANK $02 ; MOVE_ROBERT_HAOH_SHOKOH_KEN_S
	dpr MoveC_Robert_HaohShokohKen ; BANK $02 ; MOVE_ROBERT_HAOH_SHOKOH_KEN_D
	dpr MoveC_Robert_ThrowG ; BANK $02 ; MOVE_SHARED_THROW_G
	dpr MoveC_Base_Idle ;X ; BANK $02 ; MOVE_SHARED_THROW_A
MoveCodePtrTbl_Leona:
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_L
	dpr MoveC_Base_NormH_2Hit_D06_A04 ; BANK $1C ; MOVE_SHARED_PUNCH_H
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_KICK_L
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_KICK_H
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_CL
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_PUNCH_CH
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_KICK_CL
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_KICK_CH
	dpr MoveC_Base_AttackG_MF07 ; BANK $06 ; MOVE_SHARED_ATTACK_G
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_PUNCH_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_KICK_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_ATTACK_A
	dpr MoveC_Leona_BalticLauncherL ; BANK $02 ; MOVE_LEONA_BALTIC_LAUNCHER_L
	dpr MoveC_Leona_BalticLauncherH ; BANK $02 ; MOVE_LEONA_BALTIC_LAUNCHER_H
	dpr MoveC_Leona_GrandSabre ; BANK $02 ; MOVE_LEONA_GRAND_SABRE_L
	dpr MoveC_Leona_GrandSabre ; BANK $02 ; MOVE_LEONA_GRAND_SABRE_H
	dpr MoveC_Leona_XCalibur ; BANK $02 ; MOVE_LEONA_X_CALIBUR_L
	dpr MoveC_Leona_XCalibur ; BANK $02 ; MOVE_LEONA_X_CALIBUR_H
	dpr MoveC_Leona_MoonSlasher ; BANK $02 ; MOVE_LEONA_MOON_SLASHER_L
	dpr MoveC_Leona_MoonSlasher ; BANK $02 ; MOVE_LEONA_MOON_SLASHER_H
	dpr MoveC_OLeona_StormBringer ; BANK $02 ; MOVE_OLEONA_STORM_BRINGER_L
	dpr MoveC_OLeona_StormBringer ; BANK $02 ; MOVE_OLEONA_STORM_BRINGER_H
	dpr MoveC_Leona_BalticLauncherL ;X ; BANK $02 ; MOVE_LEONA_SPEC_5_L
	dpr MoveC_Leona_BalticLauncherL ;X ; BANK $02 ; MOVE_LEONA_SPEC_5_H
	dpr MoveC_Leona_BalticLauncherL ;X ; BANK $02 ; MOVE_LEONA_SPEC_6_L
	dpr MoveC_Leona_BalticLauncherL ;X ; BANK $02 ; MOVE_LEONA_SPEC_6_H
	dpr MoveC_Leona_VSlasher ; BANK $02 ; MOVE_LEONA_V_SLASHER_S
	dpr MoveC_Leona_VSlasher ; BANK $02 ; MOVE_LEONA_V_SLASHER_D
	dpr MoveC_OLeona_SuperMoonSlasher ; BANK $02 ; MOVE_OLEONA_SUPER_MOON_SLASHER_S
	dpr MoveC_OLeona_SuperMoonSlasher ; BANK $02 ; MOVE_OLEONA_SUPER_MOON_SLASHER_D
	dpr MoveC_Leona_ThrowG ; BANK $02 ; MOVE_SHARED_THROW_G
	dpr MoveC_Base_ThrowA_DiagF ; BANK $02 ; MOVE_SHARED_THROW_A
MoveCodePtrTbl_Geese:
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_L
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_PUNCH_H
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_KICK_L
	dpr MoveC_Base_NormL_2Hit_D06_A03 ; BANK $1C ; MOVE_SHARED_KICK_H
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_CL
	dpr MoveC_Base_NormL_2Hit_D06_A03 ; BANK $1C ; MOVE_SHARED_PUNCH_CH
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_KICK_CL
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_KICK_CH
	dpr MoveC_Base_AttackG_MF07 ; BANK $06 ; MOVE_SHARED_ATTACK_G
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_PUNCH_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_KICK_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_ATTACK_A
	dpr MoveC_Geese_ReppukenL ; BANK $06 ; MOVE_GEESE_REPPUKEN_L
	dpr MoveC_Geese_ReppukenH ; BANK $06 ; MOVE_GEESE_REPPUKEN_H
	dpr MoveC_Geese_JaEiKen ; BANK $06 ; MOVE_GEESE_JA_EI_KEN_L
	dpr MoveC_Geese_JaEiKen ; BANK $06 ; MOVE_GEESE_JA_EI_KEN_H
	dpr MoveC_Geese_HishouNichirinZan ; BANK $06 ; MOVE_GEESE_HISHOU_NICHIRIN_ZAN_L
	dpr MoveC_Geese_HishouNichirinZan ; BANK $06 ; MOVE_GEESE_HISHOU_NICHIRIN_ZAN_H
	dpr MoveC_Geese_ShippuKen ; BANK $06 ; MOVE_GEESE_SHIPPU_KEN_L
	dpr MoveC_Geese_ShippuKen ; BANK $06 ; MOVE_GEESE_SHIPPU_KEN_H
	dpr MoveC_Geese_AtemiNage ; BANK $06 ; MOVE_GEESE_ATEMI_NAGE_L
	dpr MoveC_Geese_AtemiNage ; BANK $06 ; MOVE_GEESE_ATEMI_NAGE_H
	dpr MoveC_Geese_ReppukenL ;X ; BANK $06 ; MOVE_GEESE_SPEC_5_L
	dpr MoveC_Geese_ReppukenL ;X ; BANK $06 ; MOVE_GEESE_SPEC_5_H
	dpr MoveC_Geese_ReppukenL ;X ; BANK $06 ; MOVE_GEESE_SPEC_6_L
	dpr MoveC_Geese_ReppukenL ;X ; BANK $06 ; MOVE_GEESE_SPEC_6_H
	dpr MoveC_Geese_RagingStorm ; BANK $06 ; MOVE_GEESE_RAGING_STORM_S
	dpr MoveC_Geese_RagingStorm ; BANK $06 ; MOVE_GEESE_RAGING_STORM_D
	dpr MoveC_Geese_RagingStorm ;X ; BANK $06 ; MOVE_GEESE_SUPER_1_S
	dpr MoveC_Geese_RagingStorm ;X ; BANK $06 ; MOVE_GEESE_SUPER_1_D
	dpr MoveC_Geese_ThrowG ; BANK $09 ; MOVE_SHARED_THROW_G
	dpr MoveC_Base_Idle ;X ; BANK $02 ; MOVE_SHARED_THROW_A
MoveCodePtrTbl_Krauser:
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_L
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_PUNCH_H
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_KICK_L
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_KICK_H
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_CL
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_PUNCH_CH
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_KICK_CL
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_KICK_CH
	dpr MoveC_Base_AttackG_SF04M0040 ; BANK $06 ; MOVE_SHARED_ATTACK_G
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_PUNCH_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_KICK_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_ATTACK_A
	dpr MoveC_Krauser_BlitzBall ; BANK $09 ; MOVE_KRAUSER_HIGH_BLITZ_BALL_L
	dpr MoveC_Krauser_BlitzBall ; BANK $09 ; MOVE_KRAUSER_HIGH_BLITZ_BALL_H
	dpr MoveC_Krauser_BlitzBall ; BANK $09 ; MOVE_KRAUSER_LOW_BLITZ_BALL_L
	dpr MoveC_Krauser_BlitzBall ; BANK $09 ; MOVE_KRAUSER_LOW_BLITZ_BALL_H
	dpr MoveC_Krauser_LegTomahawk ; BANK $09 ; MOVE_KRAUSER_LEG_TOMAHAWK_L
	dpr MoveC_Krauser_LegTomahawk ; BANK $09 ; MOVE_KRAUSER_LEG_TOMAHAWK_H
	dpr MoveC_Krauser_KaiserKick ; BANK $09 ; MOVE_KRAUSER_KAISER_KICK_L
	dpr MoveC_Krauser_KaiserKick ; BANK $09 ; MOVE_KRAUSER_KAISER_KICK_H
	dpr MoveC_Krauser_KaiserDuelSobat ; BANK $09 ; MOVE_KRAUSER_KAISER_DUEL_SOBAT_L
	dpr MoveC_Krauser_KaiserDuelSobat ; BANK $09 ; MOVE_KRAUSER_KAISER_DUEL_SOBAT_H
	dpr MoveC_Krauser_KaiserSuplex ; BANK $09 ; MOVE_KRAUSER_KAISER_SUPLEX_L
	dpr MoveC_Krauser_KaiserSuplex ; BANK $09 ; MOVE_KRAUSER_KAISER_SUPLEX_H
	dpr MoveC_Krauser_BlitzBall ;X ; BANK $09 ; MOVE_KRAUSER_SPEC_6_L
	dpr MoveC_Krauser_BlitzBall ;X ; BANK $09 ; MOVE_KRAUSER_SPEC_6_H
	dpr MoveC_Krauser_KaiserWave ; BANK $09 ; MOVE_KRAUSER_KAISER_WAVE_S
	dpr MoveC_Krauser_KaiserWave ; BANK $09 ; MOVE_KRAUSER_KAISER_WAVE_D
	dpr MoveC_Krauser_KaiserWave ;X ; BANK $09 ; MOVE_KRAUSER_SUPER_1_S
	dpr MoveC_Krauser_KaiserWave ;X ; BANK $09 ; MOVE_KRAUSER_SUPER_1_D
	dpr MoveC_Krauser_ThrowG ; BANK $09 ; MOVE_SHARED_THROW_G
	dpr MoveC_Base_Idle ;X ; BANK $02 ; MOVE_SHARED_THROW_A
MoveCodePtrTbl_MrBig:
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_L
	dpr MoveC_MrBig_PunchH ; BANK $1C ; MOVE_SHARED_PUNCH_H
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_KICK_L
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_KICK_H
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_CL
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_PUNCH_CH
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_KICK_CL
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_KICK_CH
	dpr MoveC_Base_AttackG_SF04M0040 ; BANK $06 ; MOVE_SHARED_ATTACK_G
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_PUNCH_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_KICK_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_ATTACK_A
	dpr MoveC_MrBig_GroundBlaster ; BANK $06 ; MOVE_MRBIG_GROUND_BLASTER_L
	dpr MoveC_MrBig_GroundBlaster ; BANK $06 ; MOVE_MRBIG_GROUND_BLASTER_H
	dpr MoveC_MrBig_CrossDiving ; BANK $06 ; MOVE_MRBIG_CROSS_DIVING_L
	dpr MoveC_MrBig_CrossDiving ; BANK $06 ; MOVE_MRBIG_CROSS_DIVING_H
	dpr MoveC_MrBig_SpinningLancer ; BANK $06 ; MOVE_MRBIG_SPINNING_LANCER_L
	dpr MoveC_MrBig_SpinningLancer ; BANK $06 ; MOVE_MRBIG_SPINNING_LANCER_H
	dpr MoveC_Robert_RyuuGa ; BANK $02 ; MOVE_MRBIG_CALIFORNIA_ROMANCE_L
	dpr MoveC_MrBig_CaliforniaRomanceH ; BANK $06 ; MOVE_MRBIG_CALIFORNIA_ROMANCE_H
	dpr MoveC_MrBig_DrumShot ; BANK $06 ; MOVE_MRBIG_DRUM_SHOT_L
	dpr MoveC_MrBig_DrumShot ; BANK $06 ; MOVE_MRBIG_DRUM_SHOT_H
	dpr MoveC_MrBig_GroundBlaster ;X ; BANK $06 ; MOVE_MRBIG_SPEC_5_L
	dpr MoveC_MrBig_GroundBlaster ;X ; BANK $06 ; MOVE_MRBIG_SPEC_5_H
	dpr MoveC_MrBig_GroundBlaster ;X ; BANK $06 ; MOVE_MRBIG_SPEC_6_L
	dpr MoveC_MrBig_GroundBlaster ;X ; BANK $06 ; MOVE_MRBIG_SPEC_6_H
	dpr MoveC_MrBig_BlasterWave ; BANK $06 ; MOVE_MRBIG_BLASTER_WAVE_S
	dpr MoveC_MrBig_BlasterWave ; BANK $06 ; MOVE_MRBIG_BLASTER_WAVE_D
	dpr MoveC_MrBig_BlasterWave ;X ; BANK $06 ; MOVE_MRBIG_SUPER_1_S
	dpr MoveC_MrBig_BlasterWave ;X ; BANK $06 ; MOVE_MRBIG_SUPER_1_D
	dpr MoveC_MrBig_ThrowG ; BANK $09 ; MOVE_SHARED_THROW_G
	dpr MoveC_Base_Idle ;X ; BANK $02 ; MOVE_SHARED_THROW_A
MoveCodePtrTbl_Mature:
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_L
	dpr MoveC_Mature_PunchH ; BANK $1C ; MOVE_SHARED_PUNCH_H
	dpr MoveC_Base_NormL_2Hit_D06_A03 ; BANK $1C ; MOVE_SHARED_KICK_L
	dpr MoveC_Base_NormH_2Hit_D06_A04 ; BANK $1C ; MOVE_SHARED_KICK_H
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_CL
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_PUNCH_CH
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_KICK_CL
	dpr MoveC_Base_NormH_2Hit_D06_A04 ; BANK $1C ; MOVE_SHARED_KICK_CH
	dpr MoveC_Base_AttackG_MF07 ; BANK $06 ; MOVE_SHARED_ATTACK_G
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_PUNCH_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_KICK_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_ATTACK_A
	dpr MoveC_Mature_Decide ; BANK $05 ; MOVE_MATURE_DECIDE_L
	dpr MoveC_Mature_Decide ; BANK $05 ; MOVE_MATURE_DECIDE_H
	dpr MoveC_Mature_MetalMassacre ; BANK $05 ; MOVE_MATURE_METAL_MASSACRE_L
	dpr MoveC_Mature_MetalMassacre ; BANK $05 ; MOVE_MATURE_METAL_MASSACRE_H
	dpr MoveC_Mature_DeathRow ; BANK $05 ; MOVE_MATURE_DEATH_ROW_L
	dpr MoveC_Mature_DeathRow ; BANK $05 ; MOVE_MATURE_DEATH_ROW_H
	dpr MoveC_Mature_Despair ; BANK $05 ; MOVE_MATURE_DESPAIR_L
	dpr MoveC_Mature_Despair ; BANK $05 ; MOVE_MATURE_DESPAIR_H
	dpr MoveC_Mature_Decide ;X ; BANK $05 ; MOVE_MATURE_SPEC_4_L
	dpr MoveC_Mature_Decide ;X ; BANK $05 ; MOVE_MATURE_SPEC_4_H
	dpr MoveC_Mature_Decide ;X ; BANK $05 ; MOVE_MATURE_SPEC_5_L
	dpr MoveC_Mature_Decide ;X ; BANK $05 ; MOVE_MATURE_SPEC_5_H
	dpr MoveC_Mature_Decide ;X ; BANK $05 ; MOVE_MATURE_SPEC_6_L
	dpr MoveC_Mature_Decide ;X ; BANK $05 ; MOVE_MATURE_SPEC_6_H
	dpr MoveC_Mature_HeavensGate ; BANK $05 ; MOVE_MATURE_HEAVENS_GATE_S
	dpr MoveC_Mature_HeavensGate ; BANK $05 ; MOVE_MATURE_HEAVENS_GATE_D
	dpr MoveC_Mature_HeavensGate ;X ; BANK $05 ; MOVE_MATURE_SUPER_1_S
	dpr MoveC_Mature_HeavensGate ;X ; BANK $05 ; MOVE_MATURE_SUPER_1_D
	dpr MoveC_Mature_ThrowG ; BANK $09 ; MOVE_SHARED_THROW_G
	dpr MoveC_Base_Idle ;X ; BANK $02 ; MOVE_SHARED_THROW_A
MoveCodePtrTbl_Chizuru:
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_L
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_PUNCH_H
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_KICK_L
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_KICK_H
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_CL
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_PUNCH_CH
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_KICK_CL
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_KICK_CH
	dpr MoveC_Base_AttackG_SF04M0040 ; BANK $06 ; MOVE_SHARED_ATTACK_G
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_PUNCH_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_KICK_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_ATTACK_A
	dpr MoveC_Terry_RisingTackle ; BANK $02 ; MOVE_CHIZURU_TENJIN_KOTOWARI_L
	dpr MoveC_Terry_RisingTackle ; BANK $02 ; MOVE_CHIZURU_TENJIN_KOTOWARI_H
	dpr MoveC_Chizuru_ShinsokuNoroti ; BANK $05 ; MOVE_CHIZURU_SHINSOKU_NOROTI_HIGH_L
	dpr MoveC_Chizuru_ShinsokuNoroti ; BANK $05 ; MOVE_CHIZURU_SHINSOKU_NOROTI_HIGH_H
	dpr MoveC_Chizuru_ShinsokuNoroti ; BANK $05 ; MOVE_CHIZURU_SHINSOKU_NOROTI_LOW_L
	dpr MoveC_Chizuru_ShinsokuNoroti ; BANK $05 ; MOVE_CHIZURU_SHINSOKU_NOROTI_LOW_H
	dpr MoveC_Chizuru_TenZuiL ; BANK $05 ; MOVE_CHIZURU_TEN_ZUI_L
	dpr MoveC_Chizuru_TenZuiH ; BANK $05 ; MOVE_CHIZURU_TEN_ZUI_H
	dpr MoveC_Chizuru_TamayuraShitsuneL ; BANK $05 ; MOVE_CHIZURU_TAMAYURA_SHITSUNE_L
	dpr MoveC_Chizuru_TamayuraShitsuneH ; BANK $05 ; MOVE_CHIZURU_TAMAYURA_SHITSUNE_H
	dpr MoveC_Chizuru_ShinsokuNoroti ;X ; BANK $05 ; MOVE_CHIZURU_SPEC_5_L
	dpr MoveC_Chizuru_ShinsokuNoroti ;X ; BANK $05 ; MOVE_CHIZURU_SPEC_5_H
	dpr MoveC_Chizuru_ShinsokuNoroti ;X ; BANK $05 ; MOVE_CHIZURU_SPEC_6_L
	dpr MoveC_Chizuru_ShinsokuNoroti ;X ; BANK $05 ; MOVE_CHIZURU_SPEC_6_H
	dpr MoveC_Chizuru_SanRaiFuiJin ; BANK $05 ; MOVE_CHIZURU_SAN_RAI_FUI_JIN_S
	dpr MoveC_Chizuru_SanRaiFuiJin ; BANK $05 ; MOVE_CHIZURU_SAN_RAI_FUI_JIN_D
	dpr MoveC_Chizuru_ReijiIshizue ; BANK $05 ; MOVE_CHIZURU_REIGI_ISHIZUE_S
	dpr MoveC_Chizuru_ReijiIshizue ; BANK $05 ; MOVE_CHIZURU_REIGI_ISHIZUE_D
	dpr MoveC_Chizuru_ThrowG ; BANK $09 ; MOVE_SHARED_THROW_G
	dpr MoveC_Base_Idle ;X ; BANK $02 ; MOVE_SHARED_THROW_A
MoveCodePtrTbl_Goenitz:
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_L
	dpr MoveC_Goenitz_PunchH ; BANK $1C ; MOVE_SHARED_PUNCH_H
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_KICK_L
	dpr MoveC_Goenitz_KickH ; BANK $1C ; MOVE_SHARED_KICK_H
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_CL
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_PUNCH_CH
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_KICK_CL
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_KICK_CH
	dpr MoveC_Base_AttackG_SF04M0040 ; BANK $06 ; MOVE_SHARED_ATTACK_G
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_PUNCH_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_KICK_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_ATTACK_A
	dpr MoveC_Goenitz_Yonokaze ; BANK $0A ; MOVE_GOENITZ_YONOKAZE1
	dpr MoveC_Goenitz_Yonokaze ; BANK $0A ; MOVE_GOENITZ_YONOKAZE2
	dpr MoveC_Goenitz_Yonokaze ; BANK $0A ; MOVE_GOENITZ_YONOKAZE3
	dpr MoveC_Goenitz_Yonokaze ; BANK $0A ; MOVE_GOENITZ_YONOKAZE4
	dpr MoveC_Goenitz_HyougaL ; BANK $0A ; MOVE_GOENITZ_HYOUGA_L
	dpr MoveC_Goenitz_HyougaH ; BANK $0A ; MOVE_GOENITZ_HYOUGA_H
	dpr MoveC_Goenitz_WanpyouTokobuse ; BANK $0A ; MOVE_GOENITZ_WANPYOU_TOKOBUSE_L
	dpr MoveC_Goenitz_WanpyouTokobuse ; BANK $0A ; MOVE_GOENITZ_WANPYOU_TOKOBUSE_H
	dpr MoveC_Goenitz_Yamidoukoku ; BANK $0A ; MOVE_GOENITZ_YAMIDOUKOKU_SL
	dpr MoveC_Goenitz_Yamidoukoku ; BANK $0A ; MOVE_GOENITZ_YAMIDOUKOKU_SH
	dpr MoveC_Goenitz_ShinyaotomeThrowL ; BANK $0A ; MOVE_GOENITZ_SHINYAOTOME_THROW_L
	dpr MoveC_Goenitz_ShinyaotomeThrowH ; BANK $0A ; MOVE_GOENITZ_SHINYAOTOME_THROW_H
	dpr MoveC_Goenitz_ShinyaotomePart2 ; BANK $0A ; MOVE_GOENITZ_SHINYAOTOME_PART2_L
	dpr MoveC_Goenitz_ShinyaotomePart2 ; BANK $0A ; MOVE_GOENITZ_SHINYAOTOME_PART2_H
	dpr MoveC_Goenitz_ShinyaotomeMizuchiSL ; BANK $0A ; MOVE_GOENITZ_SHINYAOTOME_MIZUCHI_SL
	dpr MoveC_Goenitz_ShinyaotomeMizuchiSH ; BANK $0A ; MOVE_GOENITZ_SHINYAOTOME_MIZUCHI_SH
	dpr MoveC_Goenitz_ShinyaotomeJissoukokuDL ; BANK $0A ; MOVE_GOENITZ_SHINYAOTOME_JISSOUKOKU_DL
	dpr MoveC_Goenitz_ShinyaotomeJissoukokuDH ; BANK $0A ; MOVE_GOENITZ_SHINYAOTOME_JISSOUKOKU_DH
	dpr MoveC_Goenitz_ShinyaotomeThrowL ; BANK $0A ; MOVE_SHARED_THROW_G
	dpr MoveC_Base_Idle ;X ; BANK $02 ; MOVE_SHARED_THROW_A
MoveCodePtrTbl_MrKarate:
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_L
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_PUNCH_H
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_KICK_L
	dpr MoveC_Base_NormH_2Hit_D06_A04 ; BANK $1C ; MOVE_SHARED_KICK_H
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_CL
	dpr MoveC_Base_NormL_2Hit_D06_A03 ; BANK $1C ; MOVE_SHARED_PUNCH_CH
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_KICK_CL
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_KICK_CH
	dpr MoveC_Base_AttackG_SF04M0040 ; BANK $06 ; MOVE_SHARED_ATTACK_G
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_PUNCH_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_KICK_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_ATTACK_A
	dpr MoveC_MrKarate_KoOuKen ; BANK $02 ; MOVE_MRKARATE_KO_OU_KEN_L
	dpr MoveC_MrKarate_KoOuKen ; BANK $02 ; MOVE_MRKARATE_KO_OU_KEN_H
	dpr MoveC_MrKarate_ShouranKyaku ; BANK $02 ; MOVE_MRKARATE_SHOURAN_KYAKU_L
	dpr MoveC_MrKarate_ShouranKyaku ; BANK $02 ; MOVE_MRKARATE_SHOURAN_KYAKU_H
	dpr MoveC_MrKarate_HienShippuuKyaku ; BANK $02 ; MOVE_MRKARATE_HIEN_SHIPPUU_KYAKU_L
	dpr MoveC_MrKarate_HienShippuuKyaku ; BANK $02 ; MOVE_MRKARATE_HIEN_SHIPPUU_KYAKU_H
	dpr MoveC_MrKarate_Zenretsuken ; BANK $02 ; MOVE_MRKARATE_ZENRETSUKEN_L
	dpr MoveC_MrKarate_Zenretsuken ; BANK $02 ; MOVE_MRKARATE_ZENRETSUKEN_H
	dpr MoveC_Robert_KyokugenRyuRanbuKyaku ; BANK $02 ; MOVE_MRKARATE_KYOKUKEN_RYU_RENBU_KEN_L
	dpr MoveC_Robert_KyokugenRyuRanbuKyaku ; BANK $02 ; MOVE_MRKARATE_KYOKUKEN_RYU_RENBU_KEN_H
IF REV_VER_2 == 0
	dpr MoveC_Terry_RisingTackle ;X ; BANK $02 ; MOVE_MRKARATE_KO_OU_KEN_UNUSED_EL ; [TCRF] Would be an hidden version of Ko Ou Ken, likely cloned from Ryo's entry. Its respective animation is a placeholder one.
	dpr MoveC_Terry_RisingTackle ;X ; BANK $02 ; MOVE_MRKARATE_KO_OU_KEN_UNUSED_EH
	dpr MoveC_Ryo_KoOuKen ;X ; BANK $02 ; MOVE_MRKARATE_SPEC_6_L ; [POI] This placeholder entry is using the one for Ryo, hinting that at some point Mr. Karate didn't have its own code for KoOuKen.
	dpr MoveC_Ryo_KoOuKen ;X ; BANK $02 ; MOVE_MRKARATE_SPEC_6_H	
ELSE
	; The English version replaced this with the third part of the desperation super.
	dpr MoveC_MrKarate_RyukoRanbuD3 ;X ; BANK $02 ; MOVE_MRKARATE_SPEC_5_L
	dpr MoveC_MrKarate_RyukoRanbuD3 ; BANK $02 ; MOVE_MRKARATE_RYUKO_RANBU_D3
	; [TCRF] They updated the placeholder entry, but the move is still not used.
	dpr MoveC_MrKarate_KoOuKen ;X ; BANK $02 ; MOVE_MRKARATE_SPEC_6_L
	dpr MoveC_MrKarate_KoOuKen ;X ; BANK $02 ; MOVE_MRKARATE_SPEC_6_H	
ENDC

	dpr MoveC_MrKarate_RyukoRanbuS ; BANK $02 ; MOVE_MRKARATE_RYUKO_RANBU_S
IF REV_VER_2 == 0
	; [TCRF] Mr.Karate's desperation super is unused and broken in the Japanese version.
	dpr MoveC_MrKarate_Unused_RyukoRanbuD ;X ; BANK $02 ; MOVE_MRKARATE_RYUKO_RANBU_UNUSED_D
ELSE
	; In the English version, the code for MoveC_MrKarate_Unused_RyukoRanbuD got deleted.
	; The move ID itself is still unused, as MOVE_MRKARATE_RYUKO_RANBU_S is used for that.
	dpr MoveC_MrKarate_RyukoRanbuS ;X ; BANK $02 ; MOVE_MRKARATE_RYUKO_RANBU_UNUSED_D
ENDC
	dpr MoveC_Robert_HaohShokohKen ; BANK $02 ; MOVE_MRKARATE_HAOH_SHO_KOH_KEN_S
	dpr MoveC_Robert_HaohShokohKen ; BANK $02 ; MOVE_MRKARATE_HAOH_SHO_KOH_KEN_D
	dpr MoveC_Ryo_ThrowG ; BANK $02 ; MOVE_SHARED_THROW_G
	dpr MoveC_Base_Idle ;X ; BANK $02 ; MOVE_SHARED_THROW_A
MoveCodePtrTbl_Ryo:
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_L
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_PUNCH_H
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_KICK_L
	dpr MoveC_Base_NormH_2Hit_D06_A04 ; BANK $1C ; MOVE_SHARED_KICK_H
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_CL
	dpr MoveC_Base_NormL_2Hit_D06_A03 ; BANK $1C ; MOVE_SHARED_PUNCH_CH
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_KICK_CL
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_KICK_CH
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_ATTACK_G
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_PUNCH_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_KICK_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_ATTACK_A
	dpr MoveC_Ryo_KoOuKen ; BANK $02 ; MOVE_RYO_KO_OU_KEN_L
	dpr MoveC_Ryo_KoOuKen ; BANK $02 ; MOVE_RYO_KO_OU_KEN_H
	dpr MoveC_Ryo_MouKoRaiJinGou ; BANK $02 ; MOVE_RYO_MOU_KO_RAI_JIN_GOU_L
	dpr MoveC_Ryo_MouKoRaiJinGou ; BANK $02 ; MOVE_RYO_MOU_KO_RAI_JIN_GOU_H
	dpr MoveC_Ryo_HienShippuKyaku ; BANK $02 ; MOVE_RYO_HIEN_SHIPPU_KYAKU_L
	dpr MoveC_Ryo_HienShippuKyaku ; BANK $02 ; MOVE_RYO_HIEN_SHIPPU_KYAKU_H
	dpr MoveC_Robert_RyuuGa ; BANK $02 ; MOVE_RYO_KO_HOU_L
	dpr MoveC_Robert_RyuuGa ; BANK $02 ; MOVE_RYO_KO_HOU_H
	dpr MoveC_Robert_KyokugenRyuRanbuKyaku ; BANK $02 ; MOVE_RYO_KYOKUKEN_RYU_RENBU_KEN_L
	dpr MoveC_Robert_KyokugenRyuRanbuKyaku ; BANK $02 ; MOVE_RYO_KYOKUKEN_RYU_RENBU_KEN_H
	dpr MoveC_Terry_RisingTackle ; BANK $02 ; MOVE_RYO_KO_HOU_EL
	dpr MoveC_Terry_RisingTackle ; BANK $02 ; MOVE_RYO_KO_HOU_EH
	dpr MoveC_Ryo_KoOuKen ;X ; BANK $02 ; MOVE_RYO_SPEC_6_L
	dpr MoveC_Ryo_KoOuKen ;X ; BANK $02 ; MOVE_RYO_SPEC_6_H
	dpr MoveC_Ryo_RyuKoRanbuS ; BANK $02 ; MOVE_RYO_RYU_KO_RANBU_S
	dpr MoveC_Ryo_RyuKoRanbuD ; BANK $02 ; MOVE_RYO_RYU_KO_RANBU_D
	dpr MoveC_Robert_HaohShokohKen ; BANK $02 ; MOVE_RYO_HAOH_SHOKOH_KEN_S
	dpr MoveC_Robert_HaohShokohKen ; BANK $02 ; MOVE_RYO_HAOH_SHOKOH_KEN_D
	dpr MoveC_Ryo_ThrowG ; BANK $02 ; MOVE_SHARED_THROW_G
	dpr MoveC_Base_Idle ;X ; BANK $02 ; MOVE_SHARED_THROW_A
MoveCodePtrTbl_Terry:
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_L
	dpr MoveC_Base_NormL_2Hit_D06_A03 ; BANK $1C ; MOVE_SHARED_PUNCH_H
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_KICK_L
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_KICK_H
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_CL
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_PUNCH_CH
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_KICK_CL
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_KICK_CH
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_ATTACK_G
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_PUNCH_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_KICK_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_ATTACK_A
	dpr MoveC_Terry_PowerWave ; BANK $06 ; MOVE_TERRY_POWER_WAVE_L
	dpr MoveC_Terry_PowerWave ; BANK $06 ; MOVE_TERRY_POWER_WAVE_H
	dpr MoveC_Terry_BurnKnuckle ; BANK $06 ; MOVE_TERRY_BURN_KNUCKLE_L
	dpr MoveC_Terry_BurnKnuckle ; BANK $06 ; MOVE_TERRY_BURN_KNUCKLE_H
	dpr MoveC_Terry_CrackShot ; BANK $06 ; MOVE_TERRY_CRACK_SHOT_L
	dpr MoveC_Terry_CrackShot ; BANK $06 ; MOVE_TERRY_CRACK_SHOT_H
	dpr MoveC_Terry_RisingTackle ; BANK $02 ; MOVE_TERRY_RISING_TACKLE_L
	dpr MoveC_Terry_RisingTackle ; BANK $02 ; MOVE_TERRY_RISING_TACKLE_H
	dpr MoveC_Terry_PowerDunk ; BANK $06 ; MOVE_TERRY_POWER_DUNK_L
	dpr MoveC_Terry_PowerDunk ; BANK $06 ; MOVE_TERRY_POWER_DUNK_H
	dpr MoveC_Terry_PowerWave ;X ; BANK $06 ; MOVE_TERRY_SPEC_5_L
	dpr MoveC_Terry_PowerWave ;X ; BANK $06 ; MOVE_TERRY_SPEC_5_H
	dpr MoveC_Terry_PowerWave ;X ; BANK $06 ; MOVE_TERRY_SPEC_6_L
	dpr MoveC_Terry_PowerWave ;X ; BANK $06 ; MOVE_TERRY_SPEC_6_H
	dpr MoveC_Terry_PowerWave ; BANK $06 ; MOVE_TERRY_POWER_GEYSER_S
	dpr MoveC_Terry_PowerGeyserD ; BANK $06 ; MOVE_TERRY_POWER_GEYSER_D
	dpr MoveC_Terry_PowerGeyserE ; BANK $06 ; MOVE_TERRY_POWER_GEYSER_E
	dpr MoveC_Terry_PowerGeyserD ;X ; BANK $06 ; MOVE_TERRY_SUPER_1_D
	dpr MoveC_Terry_ThrowG ; BANK $02 ; MOVE_SHARED_THROW_G
	dpr MoveC_Base_Idle ;X ; BANK $02 ; MOVE_SHARED_THROW_A
MoveCodePtrTbl_Athena:
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_L
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_PUNCH_H
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_KICK_L
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_KICK_H
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_CL
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_PUNCH_CH
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_KICK_CL
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_KICK_CH
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_ATTACK_G
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_PUNCH_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_KICK_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_ATTACK_A
	dpr MoveC_Athena_PsychoBall ; BANK $06 ; MOVE_ATHENA_PSYCHO_BALL_L
	dpr MoveC_Athena_PsychoBall ; BANK $06 ; MOVE_ATHENA_PSYCHO_BALL_H
	dpr MoveC_Athena_PhoenixArrow ; BANK $06 ; MOVE_ATHENA_PHOENIX_ARROW_L
	dpr MoveC_Athena_PhoenixArrow ; BANK $06 ; MOVE_ATHENA_PHOENIX_ARROW_H
	dpr MoveC_Athena_PsychoReflector ; BANK $06 ; MOVE_ATHENA_PSYCHO_REFLECTOR_L
	dpr MoveC_Athena_PsychoReflector ; BANK $06 ; MOVE_ATHENA_PSYCHO_REFLECTOR_H
	dpr MoveC_Andy_ShoRyuDan ; BANK $06 ; MOVE_ATHENA_PSYCHO_SWORD_L
	dpr MoveC_Andy_ShoRyuDan ; BANK $06 ; MOVE_ATHENA_PSYCHO_SWORD_H
	dpr MoveC_Athena_PsychoTeleport ; BANK $06 ; MOVE_ATHENA_PSYCHO_TELEPORT_L
	dpr MoveC_Athena_PsychoTeleport ; BANK $06 ; MOVE_ATHENA_PSYCHO_TELEPORT_H
	dpr MoveC_Athena_PsychoBall ;X ; BANK $06 ; MOVE_ATHENA_SPEC_5_L
	dpr MoveC_Athena_PsychoBall ;X ; BANK $06 ; MOVE_ATHENA_SPEC_5_H
	dpr MoveC_Athena_PsychoBall ;X ; BANK $06 ; MOVE_ATHENA_SPEC_6_L
	dpr MoveC_Athena_PsychoBall ;X ; BANK $06 ; MOVE_ATHENA_SPEC_6_H
	dpr MoveC_Athena_ShCryst ; BANK $06 ; MOVE_ATHENA_SHINING_CRYSTAL_BIT_GS
	dpr MoveC_Athena_ShCryst ; BANK $06 ; MOVE_ATHENA_SHINING_CRYSTAL_BIT_GD
	dpr MoveC_Athena_ShCryst ; BANK $06 ; MOVE_ATHENA_SHINING_CRYSTAL_BIT_AS
	dpr MoveC_Athena_ShCryst ; BANK $06 ; MOVE_ATHENA_SHINING_CRYSTAL_BIT_AD
	dpr MoveC_Athena_ThrowG ; BANK $02 ; MOVE_SHARED_THROW_G
	dpr MoveC_Base_ThrowA_DiagF ; BANK $02 ; MOVE_SHARED_THROW_A
MoveCodePtrTbl_Mai:
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_L
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_PUNCH_H
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_KICK_L
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_KICK_H
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_CL
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_PUNCH_CH
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_KICK_CL
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_KICK_CH
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_ATTACK_G
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_PUNCH_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_KICK_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_ATTACK_A
	dpr MoveC_Mai_KaChoSen ; BANK $06 ; MOVE_MAI_KA_CHO_SEN_L
	dpr MoveC_Mai_KaChoSen ; BANK $06 ; MOVE_MAI_KA_CHO_SEN_H
	dpr MoveC_Mai_HissatsuShinobibachi ; BANK $06 ; MOVE_MAI_HISSATSU_SHINOBIBACHI_L
	dpr MoveC_Mai_HissatsuShinobibachi ; BANK $06 ; MOVE_MAI_HISSATSU_SHINOBIBACHI_H
	dpr MoveC_Mai_RyuEnBu ; BANK $06 ; MOVE_MAI_RYU_EN_BU_L
	dpr MoveC_Mai_RyuEnBu ; BANK $06 ; MOVE_MAI_RYU_EN_BU_H
	dpr MoveC_Mai_HishoRyuEnJin ; BANK $06 ; MOVE_MAI_HISHO_RYU_EN_JIN_L
	dpr MoveC_Mai_HishoRyuEnJin ; BANK $06 ; MOVE_MAI_HISHO_RYU_EN_JIN_H
	dpr MoveC_Mai_ChijouMusasabi ; BANK $06 ; MOVE_MAI_CHIJOU_MUSASABI_L
	dpr MoveC_Mai_ChijouMusasabi ; BANK $06 ; MOVE_MAI_CHIJOU_MUSASABI_H
	dpr MoveC_Mai_KuuchuuMusasabi ; BANK $06 ; MOVE_MAI_KUUCHUU_MUSASABI_L
	dpr MoveC_Mai_KuuchuuMusasabi ; BANK $06 ; MOVE_MAI_KUUCHUU_MUSASABI_H
	dpr MoveC_Mai_KaChoSen ;X ; BANK $06 ; MOVE_MAI_SPEC_6_L
	dpr MoveC_Mai_KaChoSen ;X ; BANK $06 ; MOVE_MAI_SPEC_6_H
	dpr MoveC_Mai_ChoHissatsuShinobibachiS ; BANK $06 ; MOVE_MAI_CHO_HISSATSU_SHINOBIBACHI_S
	dpr MoveC_Mai_ChoHissatsuShinobibachiD ; BANK $06 ; MOVE_MAI_CHO_HISSATSU_SHINOBIBACHI_D
	dpr MoveC_Mai_ChoHissatsuShinobibachiS ;X ; BANK $06 ; MOVE_MAI_SUPER_1_S
	dpr MoveC_Mai_ChoHissatsuShinobibachiD ;X ; BANK $06 ; MOVE_MAI_SUPER_1_D
	dpr MoveC_Mai_ThrowG ; BANK $02 ; MOVE_SHARED_THROW_G
	dpr MoveC_Base_ThrowA_DirD ; BANK $02 ; MOVE_SHARED_THROW_A
MoveCodePtrTbl_Iori:
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_L
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_PUNCH_H
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_KICK_L
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_KICK_H
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_PUNCH_CL
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_PUNCH_CH
	dpr MoveC_Base_NormL ; BANK $02 ; MOVE_SHARED_KICK_CL
	dpr MoveC_Base_NormH ; BANK $02 ; MOVE_SHARED_KICK_CH
	dpr MoveC_Base_AttackG_SF04M0040 ; BANK $06 ; MOVE_SHARED_ATTACK_G
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_PUNCH_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_KICK_A
	dpr MoveC_Base_NormA ; BANK $02 ; MOVE_SHARED_ATTACK_A
	dpr MoveC_Iori_YamiBarai ; BANK $05 ; MOVE_IORI_YAMI_BARAI_L
	dpr MoveC_Iori_YamiBarai ; BANK $05 ; MOVE_IORI_YAMI_BARAI_H
	dpr MoveC_Iori_OniYaki ; BANK $05 ; MOVE_IORI_ONI_YAKI_L
	dpr MoveC_Iori_OniYaki ; BANK $05 ; MOVE_IORI_ONI_YAKI_H
	dpr MoveC_Iori_AoiHana ; BANK $05 ; MOVE_IORI_AOI_HANA_L
	dpr MoveC_Iori_AoiHana ; BANK $05 ; MOVE_IORI_AOI_HANA_H
	dpr MoveC_Iori_KotoTsukiIn ; BANK $05 ; MOVE_IORI_KOTO_TSUKI_IN_L
	dpr MoveC_Iori_KotoTsukiIn ; BANK $05 ; MOVE_IORI_KOTO_TSUKI_IN_H
	dpr MoveC_Iori_ScumGale ; BANK $05 ; MOVE_IORI_SCUM_GALE_L
	dpr MoveC_Iori_ScumGale ; BANK $05 ; MOVE_IORI_SCUM_GALE_H
	dpr MoveC_Iori_YamiBarai ;X ; BANK $05 ; MOVE_IORI_SPEC_5_L
	dpr MoveC_Iori_YamiBarai ;X ; BANK $05 ; MOVE_IORI_SPEC_5_H
	dpr MoveC_Iori_KinYaOtomeEscapeD ; BANK $05 ; MOVE_IORI_KIN_YA_OTOME_ESCAPE_L
	dpr MoveC_Iori_KinYaOtomeEscapeD ;X ; BANK $05 ; MOVE_IORI_KIN_YA_OTOME_ESCAPE_H
	dpr MoveC_Iori_KinYaOtomeS ; BANK $05 ; MOVE_IORI_KIN_YA_OTOME_S
	dpr MoveC_Iori_KinYaOtomeD ; BANK $05 ; MOVE_IORI_KIN_YA_OTOME_D
	dpr MoveC_OIori_KinYaOtome ; BANK $05 ; MOVE_OIORI_KIN_YA_OTOME_S
	dpr MoveC_OIori_KinYaOtome ; BANK $05 ; MOVE_OIORI_KIN_YA_OTOME_D
	dpr MoveC_Iori_ThrowG ; BANK $09 ; MOVE_SHARED_THROW_G
	dpr MoveC_Base_Idle ;X ; BANK $02 ; MOVE_SHARED_THROW_A
	
; 
; =============== START OF SUBMODULE Play->CPU ===============
;

; =============== Play_CPU_Do ===============
; Handles inputs for CPU players.
;
; While this handles the move inputs, not everything is handled here.
; Some moves (in particular those that have submoves) have CPU-specific
; code to randomize how to handle them.
;
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
Play_CPU_Do:
IF NO_CPU_AI == 1
	ret
ELSE
	;
	; If iPlInfo_CPUWaitTimer is set, don't do anything until it elapses.
	; This is strictly to delay the next action by a bit, as the CPU doesn't use 
	; the MoveInput_* like the player does.
	;
	ld   hl, iPlInfo_CPUWaitTimer
	add  hl, bc
	ld   a, [hl]
	cp   $00			; WaitTimer == $00?
	jr   z, .resetInput	; If so, jump
	dec  a				; Otherwise, WaitTimer--
	ld   [hl], a
	ret					; and exit
.resetInput:
	;
	; Clear all joypad input fields
	;
	xor  a
	ld   hl, iPlInfo_JoyNewKeys
	add  hl, bc
	ldi  [hl], a	; iPlInfo_JoyNewKeys
	ldi  [hl], a	; iPlInfo_JoyKeys
	ldi  [hl], a	; iPlInfo_JoyNewKeysLH
	call Play_Pl_ClearJoyDirBuffer
	
	;
	; CPU AI LOGIC STARTS HERE
	;
	; First part here is reacting to what the player is doing.
	;
	
	; Handle separately what happens if there's an enemy projectile on screen
	ld   hl, iPlInfo_Flags0Other
	add  hl, bc
	bit  PF0B_PROJ, [hl]			; Does the opponent have an active fireball?
	jp   nz, Play_CPU_CheckProj		; If so, jump
	
	; Handle separately if the current or next frame from the opponent deal damage
	ld   hl, iPlInfo_MoveDamageValOther
	add  hl, bc
	ld   a, [hl]					; A = Cur Damage value
	ld   hl, iPlInfo_MoveDamageValNextOther
	add  hl, bc
	or   a, [hl]					; A |= Next damage value
	jp   nz, Play_CPU_BlockAttack_ByDifficulty				; A != 0? If so, jump
	
	; On HARD difficulty, several additional checks are made.
	; The only check that remains in this block on EASY/NORMAL difficulties
	; is the player distance one, which also activates closer to the opponent.
	ld   a, [wDifficulty]
	cp   DIFFICULTY_HARD		; Playing on HARD?
	jp   nz, .valNormEasy		; If not, jump
.valHard:
	;
	; HARD ONLY
	;
	
	; If the opponent is invulnerable, move/hop backwards
	ld   hl, iPlInfo_Flags1Other
	add  hl, bc
	bit  PF1B_INVULN, [hl]
	jp   nz, Play_CPU_SetJoyKeysB_HopRand
	
	; If we're in the post-blockstun knockback, randomize return input
	ld   hl, iPlInfo_MoveId
	add  hl, bc
	ld   a, [hl]
	cp   MOVE_SHARED_POST_BLOCKSTUN			; During knockback?
	jp   z, Play_CPU_OnBlockstunKnockback	; If so, jump
	
	; If we can cancel the current move into another, perform a random character-specific input
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	bit  PF1B_ALLOWHITCANCEL, [hl]
	jp   nz, Play_CPU_SetRandCharInput
	
	; If we're within $20px from the opponent, try to perform a random action
	ld   hl, iPlInfo_PlDistance
	add  hl, bc
	ld   a, [hl]
	cp   $20						; iPlInfo_PlDistance < $20?
	jp   c, Play_CPU_OnPlNear		; If so, jump
	
	;
	; Every alternating $40 frames, perform a random character-specific input.
	; Notably, this only happens here, with the HARD difficulty setting.
	; On NORMAL and EASY, the CPU will never attack when far away.
	;
	ld   a, [wTimer]
	bit  6, a
	jp   nz, Play_CPU_SetRandCharInput
	; Every alternating $80 frames that don't fall into the above check, try to jump forwards.
	; This gives a window of opportunity for the jump to happen.
	bit  7, a
	jp   nz, Play_CPU_SetJoyKeysJumpUF
	
	jp   .idle
.valNormEasy:
	;
	; NORMAL/EASY ONLY
	;
	
	; If we're within $1Apx from the opponent, try to perform a random action
	ld   hl, iPlInfo_PlDistance
	add  hl, bc
	ld   a, [hl]
	cp   $1A						; iPlInfo_PlDistance < $1A?
	jp   c, Play_CPU_OnPlNear		; If so, jump
	
.idle:

	;
	; IDLE MOVEMENT
	;
	; If we got here, there's nothing for the CPU to react to.
	;

	; Don't pick a new action until the next block until the timer elapses
	ld   hl, iPlInfo_CPUIdleTimer
	add  hl, bc
	ld   a, [hl]
	cp   $00				; iPlInfo_CPUIdleTimer == $00?
	jr   z, .setIdleMove	; If so, jump
	dec  a					; Otherwise, iPlInfo_CPUIdleTimer--
	ld   [hl], a
	jr   .execIdleMove		; and skip
.setIdleMove:

	;
	; Set the new length of the timer value.
	; This is always $16.
	;
	
	;--
	; [POI] What's this used for? A canceled attempt at randomizing the timer?
	call Rand	; A = Rand
	or   a, $07	; Set lower three bits
	;--
	ld   a, $0B
	ld   e, a
	add  a, e			; A = $0B * 2
	ld   hl, iPlInfo_CPUIdleTimer
	add  hl, bc			; Seek to delay
	ld   [hl], a		; Write it
	
	;
	; Randomize the action.
	;
	call Rand
	; ~15.5% chance -> Attempt to move backwards (moves forward anyway if too far away from the opponent)
	cp   $28
	jr   c, .chkSetMoveB
	; ~23.5% chance -> Attempt to pause (moves forward anyway if too far away from the opponent)
	cp   $64
	jr   c, .chkSetNoMove
	; ~10% chance -> Charge meter
	cp   $7D
	jr   c, .setChargeMove
	; ~51% chance -> Move forward
.setMoveF:
	; iPlInfo_CPUIdleMove = CMA_MOVEF
	xor  a	; CMA_MOVEF
	ld   hl, iPlInfo_CPUIdleMove
	add  hl, bc
	ld   [hl], a
	jr   .execIdleMove
.chkSetMoveB:
	; Move forward instead if too far away from the opponent
	ld   hl, iPlInfo_PlDistance
	add  hl, bc
	ld   a, [hl]
	cp   $5A			; iPlInfo_PlDistance >= $5A?
	jp   nc, .setMoveF	; If so, jump
	; iPlInfo_CPUIdleMove = CMA_MOVEB
	ld   a, CMA_MOVEB
	ld   hl, iPlInfo_CPUIdleMove
	add  hl, bc
	ld   [hl], a
	jr   .execIdleMove
.chkSetNoMove:
	; Move forward instead if too far away from the opponent
	ld   hl, iPlInfo_PlDistance
	add  hl, bc
	ld   a, [hl]
	cp   $55			; iPlInfo_PlDistance >= $55?
	jp   nc, .setMoveF	; If so, jump
	; iPlInfo_CPUIdleMove = CMA_NONE
	ld   a, CMA_NONE
	ld   hl, iPlInfo_CPUIdleMove
	add  hl, bc
	ld   [hl], a
	jr   .execIdleMove
.setChargeMove:
	; iPlInfo_CPUIdleMove = CMA_CHARGE
	ld   a, CMA_CHARGE
	ld   hl, iPlInfo_CPUIdleMove
	add  hl, bc
	ld   [hl], a
	jr   .execIdleMove
	
.execIdleMove:
	; Execute the currently set idle move input
	ld   hl, iPlInfo_CPUIdleMove
	add  hl, bc
	ld   a, [hl]
	cp   CMA_MOVEF
	jp   z, Play_CPU_SetJoyKeysF_RunRand
	cp   CMA_MOVEB
	jp   z, Play_CPU_SetJoyKeysB_HopRand
	cp   CMA_CHARGE
	jp   z, Play_CPU_SetJoyKeys_Charge
	ret
	
; =============== Play_CPU_SetJoyKeys_Charge ===============
; Makes the CPU charge meter. (A+B+Down)
Play_CPU_SetJoyKeys_Charge:

	; If we reached max power, abort this move early.
	ld   hl, iPlInfo_Pow
	add  hl, bc
	ld   a, [hl]		
	cp   PLAY_POW_MAX	; At max power?
	jr   z, .end		; If so, jump
	
	; Perform the charge input
	ld   a, KEY_B|KEY_A|KEY_DOWN
	ld   d, KEP_B_LIGHT|KEP_A_LIGHT
	jp   Play_CPU_SetJoyKeys
.end:
	; Reset the idle timer.
	; This will force to pick a new idle move next frame.
	xor  a
	ld   hl, iPlInfo_CPUIdleTimer
	add  hl, bc
	ld   [hl], a
	ret
; =============== Play_CPU_OnPlNear ===============
; Handles the logic when the opponent is near us.
;
; This needs to survive a gauntlet of difficulty-specific validations, which,
; if pass, make the CPU execute a random action.
Play_CPU_OnPlNear:

	;
	; The difficulty variable for this part only matters for non-boss stages.
	; The bosses and extra rounds have their own difficulty which is harder than hard.
	;

	; Depending on difficulty...
	ld   a, [wDifficulty]
	cp   DIFFICULTY_NORMAL
	jp   z, .norm
	cp   DIFFICULTY_HARD
	jp   z, .hard
.easy:
	; Check hardcoded stage difficulties
	ld   a, [wCharSeqId]
	cp   STAGESEQ_KAGURA	; Are we in a boss or extra stage?
	jp   nc, .hard			; If so, jump
	
	; Don't do anything for the next 10 frames
	ld   hl, iPlInfo_CPUWaitTimer
	add  hl, bc
	ld   a, $0A
	ld   [hl], a
	
	; ~39% chance of not doing anything
	call Rand
	cp   $64
	ret  c
	
	jp   .doAction
.norm:
	; Check hardcoded stage difficulties
	ld   a, [wCharSeqId]
	cp   STAGESEQ_GOENITZ	; Are we in the Goenitz or extra stages?
	jp   nc, .hardest		; If so, jump
	cp   STAGESEQ_KAGURA	; Are we in boss Kagura's stage?
	jp   nc, .hard			; If so, jump
	
	; Don't do anything for the next frame
	ld   hl, iPlInfo_CPUWaitTimer
	add  hl, bc
	ld   a, $01
	ld   [hl], a
	
	; ~8% chance of not doing anything
	call Rand
	cp   $14
	ret  c
	
	jp   .doAction
.hard:
	; Check hardcoded stage difficulties.
	; .hardest is like .hard, except it:
	; - respects POWERUP mode 
	; - allows hit cancel
	; - makes the CPU block/walk back if the opponent is invulnerable.
	
	; [POI] On POWERUP mode, HARD is perpetually HARDEST here
	ld   a, [wDipSwitch]
	bit  DIPB_POWERUP, a
	jp   nz, .hardest
	; [POI] The other STAGESEQ_KAGURA checks in .easy and .norm, instead of leading directly to .hardest, led here.
	;       What gives? Is it an error? Should have this been checking STAGESEQ_GOENITZ?
	ld   a, [wCharSeqId]
	cp   a, STAGESEQ_KAGURA	; Are we in a boss or extra stages?
	jp   nc, .hardest		; If so, jump
	; 50% chance to be in hardest mode
	ld   a, [wTimer]
	bit  7, a				; wTimer >= $80?
	jp   nz, .hardest		; If so, jump
	
	; If we're in the post-blockstun knockback, randomize return input (WITHOUT respecting POWERUP mode)
	ld   hl, iPlInfo_MoveId
	add  hl, bc
	ld   a, [hl]
	cp   MOVE_SHARED_POST_BLOCKSTUN		; During knockback?
	jp   z, Play_CPU_SetRandCharInput	; If so, jump
	
	; Allow the CPU to do something the next frame
	ld   hl, iPlInfo_CPUWaitTimer
	add  hl, bc
	ld   a, $00
	ld   [hl], a
	
	; ~4% chance of not doing anything
	; With the previous 50% chance to go to .hardest, which has a 0% rand chance, it makes it ~2%
	call Rand
	cp   a, $0A
	ret  c
	
	jp   .doAction
	;--
.hardest:
	; Attempt to special/super cancel if possible
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	bit  PF1B_ALLOWHITCANCEL, [hl]
	jp   nz, Play_CPU_SetRandCharInput
	
	; If we're in the post-blockstun knockback, randomize return input (respecting POWERUP mode)
	ld   hl, iPlInfo_MoveId
	add  hl, bc
	ld   a, [hl]
	cp   MOVE_SHARED_POST_BLOCKSTUN			; During knockback?
	jp   z, Play_CPU_OnBlockstunKnockback	; If so, jump
	
	; Allow the CPU to do something the next frame
	ld   hl, iPlInfo_CPUWaitTimer
	add  hl, bc
	ld   a, $00
	ld   [hl], a
	
	; If the opponent is invulnerable, try to walk back outside of the "near" range.
	ld   hl, iPlInfo_Flags1Other
	add  hl, bc
	bit  PF1B_INVULN, [hl]
	jp   nz, Play_CPU_BlockAttack_ByDifficulty
	
	; 0% chance of not doing anything.
	
.doAction:
	
	;
	; IDLE MODE (near player)
	;
	; There's nothing for the CPU to react to, so perform a random action.
	;
	
	call Rand
	; ~15.5% chance -> 25% chance of A+B attack
	cp   $28
	jp   c, Play_CPU_SetJoyKeysAtkG_C25
	; ~8%    chance -> 25% chance of heavy punch
	cp   $3C
	jp   c, Play_CPU_SetJoyKeysHP_C25
	; ~8%    chance -> 25% chance of light punch
	cp   $50
	jp   c, Play_CPU_SetJoyKeysLP_C25
	; ~8%    chance -> Heavy kick
	cp   $64
	jp   c, Play_CPU_SetJoyKeysHK
	; ~8%    chance -> Heavy punch
	cp   $78
	jp   c, Play_CPU_SetJoyKeysLK
	; ~8%    chance -> Random character-specific input
	cp   $8C
	jp   c, Play_CPU_SetRandCharInput
	; ~8%    chance -> Move/hop back
	cp   $A0
	jp   c, Play_CPU_SetJoyKeysB_HopRand
	; ~23.5% chance -> 50% chance of throw (or heavy punch while holding back)
	cp   $DC
	jp   c, Play_CPU_SetJoyKeysB_HP_C50
	; ~14%   chance -> Nothing
	ret

; =============== Play_CPU_OnBlockstunKnockback ===============
; Handles the logic when in the middle of knockback after blockstun.
; These attempt to set a character-specific input that may take effect 
; as soon as knockback ends if something else doesn't write to the key buffer.
Play_CPU_OnBlockstunKnockback:

	;
	; Without powerup mode active, fall back to Play_CPU_SetRandCharInput
	;
	ld   a, [wDipSwitch]
	bit  DIPB_POWERUP, a				; Is the powerup cheat enabled?
	jp   z, Play_CPU_SetRandCharInput	; If not, jump
	
.powerup:
	;
	; In powerup mode, continuously attempt to perform the inputs for either $01 or $07.
	; Note that while $01 is an input for a normal special, $07 is the slot reserved for the super move input.
	;
	ld   a, [wTimer]
	bit  1, a			; Every alternating $02 frames
	jp   nz, .super
.spec:
	bit  0, a			; Every other frame
	jp   nz, .specH
.specL:
	ld   a, $01	; Use move input $01
	scf
	ccf	; Use light version (#0)
	jp   Play_CPU_ApplyCharInput
.specH:
	ld   a, $01	; Use move input $01
	scf	; Use heavy version (#1)
	jp   Play_CPU_ApplyCharInput
.super:
	ld   a, [wTimer]
	bit  0, a			; Every other frame
	jp   nz, .superH
.superL:
	ld   a, $07	; Use super move input
	scf
	ccf	; Use light version (#0)
	jp   Play_CPU_ApplyCharInput
.superH:
	ld   a, $07	; Use super move input
	scf	; Use heavy version (#1)
	jp   Play_CPU_ApplyCharInput
	
	
; =============== Play_CPU_SetRandCharInput ===============
; Makes the CPU perform a random special move input / character-specific move input
; with random strength.
Play_CPU_SetRandCharInput:
	;
	; 62.5% chance of performing a light attack.
	;
	call Rand		; A = Rand
	cp   $A0		; A < $A0?
	jp   c, .light	; If so, jump
.heavy:
	call Rand	; Randomize moveinput id
	and  a, $07	; Force valid range ($00-$07)
	scf			; Use heavy version (#1)
	jp   Play_CPU_ApplyCharInput
.light:
	call Rand	; Randomize moveinput id
	and  a, $07	; Force valid range ($00-$07)
	scf
	ccf			; Use light version (#0)
	jp   Play_CPU_ApplyCharInput
	
; =============== Play_CPU_BlockAttack_ByDifficulty ===============
; Makes the opponent block the active attack (or, if we got here with no attack, to walk back away from the opponent), with difficulty-specific logic.
; - EASY and NORMAL have almost identical logic. They randomize between blocking mid and low
;   back depending on the global timer.
;   The difference between these are the bits that are checked to determine if the CPU should
;   do anything and which move should performed. 
;   - On EASY those are respectively bit 7 and 6.
;   - On NORMAL those are bit 6 and 5
;   This means on EASY, the CPU will not do anything for longer and alternate between block stances less.
; - HARD makes the CPU always do something. The action performed isn't randomized either.
;   See Play_CPU_BlockAttack for more info.
Play_CPU_BlockAttack_ByDifficulty:
	; Determine which difficulty we're in.
	ld   a, [wDifficulty]
	cp   DIFFICULTY_EASY	; On EASY difficulty?
	jp   z, .easy			; If so, jump
	cp   DIFFICULTY_NORMAL	; On NORMAL difficulty?
	jp   z, .norm			; If so, jump
.hard:
	jp   Play_CPU_BlockAttack	; Otherwise, we're on HARD
.easy:
	; Return every alternating $80 frames
	ld   a, [wTimer]
	bit  7, a
	ret  nz
	; Every $40 frames, alternate between crouch block and block
	bit  6, a
	jp   z, Play_CPU_SetJoyKeysDB
	jp   Play_CPU_SetJoyKeysB
.norm:
	; Return every alternating $40 frames
	ld   a, [wTimer]
	bit  6, a
	ret  nz
	; Every $20 frames, alternate between crouch block and block
	bit  5, a
	jp   z, Play_CPU_SetJoyKeysDB
	jp   Play_CPU_SetJoyKeysB
	
; =============== Play_CPU_BlockAttack_C15 ===============
; Performs actions depending on how the opponent's attack hits,
; with 15% chance of not doing anything.
Play_CPU_BlockAttack_C15:
	;
	; ~15.6% chance of not doing anything
	;
	call Rand	; A = Rand
	cp   $28	; A < $28?
	ret  c		; If so, return
	; Fall-through
	
; =============== Play_CPU_BlockAttack ===============
; Makes the opponent block or jump back the active attack.
; Performs actions depending on how the opponent's attack hits.
Play_CPU_BlockAttack:
	
	; Get the damage flags for the opponent's move
	ld   hl, iPlInfo_MoveDamageFlags3Other
	add  hl, bc
	ld   a, [hl]	; A = Cur flags
	ld   hl, iPlInfo_MoveDamageFlags3NextOther
	add  hl, bc
	or   a, [hl]	; A |= Next flags
	
	;
	; Move backwards/block when the attack doesn't hit low.
	; This means the CPU doesn't need to watch its feet and block low, so just block.
	;
	; If the opponent isn't attacking (ie: we got here through the PF1B_INVULN check),
	; walk back in an attempt to get out of the opponent's range.
	;
	bit  PF3B_HITLOW, a				; Does the attack hit low?
	jp   z, Play_CPU_SetJoyKeysB	; If not, jump
	
	;
	; If the attack hits low (but doesn't also hit mid), crouch block.
	;
	bit  PF3B_OVERHEAD, a			; Does the attack hit high?
	jp   z, Play_CPU_SetJoyKeysDB	; If not, jump
	
	;
	; Otherwise, this is an unblockable. Try to block it anyway.
	;
	jp   Play_CPU_SetJoyKeysB
	ret ; We never get here

; =============== Play_CPU_CheckProj ===============	
; Behaviour when an enemy projectile is active on-screen.
Play_CPU_CheckProj:
	;
	; On EASY difficulty, there's a 50% chance of not doing anything.
	;
	ld   a, [wDifficulty]
	cp   DIFFICULTY_EASY			; Playing on EASY?
	jp   nz, .chkAthenaCrystalBit	; If not, skip
	ld   a, [wTimer]
	cp   $80						; wTimer < $80?
	ret  c							; If so, return
	
.chkAthenaCrystalBit:
	;
	; Start spamming user moves if we're on HARD and attempting to hit the CPU 
	; with Athena's normal super.
	; Note the desperation version is unaffected.
	;
	
	ld   a, [wDifficulty]
	cp   DIFFICULTY_HARD				; Playing on HARD?
	jp   nz, .norm		; If not, skip
	
	ld   hl, iPlInfo_CharIdOther
	add  hl, bc
	ld   a, [hl]
	cp   CHAR_ID_ATHENA					; Opponent is Athena?
	jp   nz, .chkPowerupMode			; If not, skip
	
	ld   hl, iPlInfo_MoveIdOther
	add  hl, bc
	ld   a, [hl]
	cp   a, MOVE_ATHENA_SHINING_CRYSTAL_BIT_GS	; Opponent is doing a normal super?
	jp   z, Play_CPU_SetRandCharInputH			; If so, jump
	cp   a, MOVE_ATHENA_SHINING_CRYSTAL_BIT_AS	; ""
	jp   z, Play_CPU_SetRandCharInputH			; ""

.chkPowerupMode:

	;
	; Handle the projectile distance checks differently in powerup mode.
	;
	ld   a, [wDipSwitch]
	bit  DIPB_POWERUP, a	; Is the powerup cheat enabled?
	jp   z, .norm			; If not, jump
	
.powerup:	
	;
	; If we pressed any attack button in the last few frames but no attack started,
	; perform a crouching light punch.
	; Note that switching to a new move, most of the time, clears iPlInfo_JoyBufKeysLH.
	;
	ld   hl, iPlInfo_JoyBufKeysLH
	add  hl, bc
	ld   a, [hl]
	and  a, KEP_A_LIGHT|KEP_B_LIGHT|KEP_A_HEAVY|KEP_B_HEAVY	; Are we pressing any button already?
	jp   nz, Play_CPU_SetJoyKeysC_LP_C25					; If so, jump
	
	;
	; Check distance with enemy projectile.
	;
	ld   hl, iPlInfo_ProjDistance
	add  hl, bc
	ld   a, [hl]
	; Crouching light punch if distance >= $46
	cp   $46
	jp   nc, Play_CPU_SetJoyKeysC_LP_C25
	; Roll if distance in range $32-$45
	cp   $32			
	jp   nc, Play_CPU_StartRoll_D14_C20
	; Block or jump back if distance < $32
	jr   Play_CPU_BlockAttack
.norm:
	;
	; Check distance with enemy projectile.
	;
	ld   hl, iPlInfo_ProjDistance
	add  hl, bc
	ld   a, [hl]
	; Do a random character-specific input if distance >= $55
	cp   $55
	jp   nc, Play_CPU_SetRandCharInputH
	; Jump forward if distance in range $46-$54
	cp   $46
	jp   nc, Play_CPU_SetJoyKeysJumpUF
	; Roll if distance < $32
	cp   $32
	jp   c, Play_CPU_StartRoll_D14_C20
	; Block or jump back if distance in range $32-$45
	jp   Play_CPU_BlockAttack_C15
	
; =============== Play_CPU_StartRoll_D14_C20 ===============
; Makes the CPU perform a roll in a random direction.
; On EASY and NORMAL difficulties, there's a 20% chance of blocking the attack
; instead of starting a roll.
; On HARD, the roll always happens.
Play_CPU_StartRoll_D14_C20:
	ld   a, [wDifficulty]
	cp   DIFFICULTY_HARD	; Playing on HARD?
	jp   z, .end			; If so, skip
	; ~20% chance of jumping to Play_CPU_BlockAttack 
	call Rand
	cp   $32
	jp   c, Play_CPU_BlockAttack
.end:
	; Fall-through
; =============== Play_CPU_StartRoll_D14 ===============
; Makes the CPU perform a roll in a random direction.
; After doing this, the CPU will not press anything for 20 frames.
Play_CPU_StartRoll_D14:
	; Wait 20 frames before next time we execute AI code
	ld   hl, iPlInfo_CPUWaitTimer
	add  hl, bc
	ld   a, $14
	ld   [hl], a
	
	; Hold A+B+(50% chance between L and R)
	ld   a, [wTimer]
	bit  0, a			; wTimer % 2 != 0?
	jp   nz, .setL		; If so, jump
.setR:
	ld   a, KEY_A|KEY_B|KEY_RIGHT ; $31
	jp   .go
.setL:
	ld   a, KEY_A|KEY_B|KEY_LEFT ; $32
.go:
	ld   d, KEP_A_HEAVY|KEP_B_HEAVY
	jp   Play_CPU_SetJoyKeys
	
; =============== Play_CPU_SetJoyKeysJumpUF ===============
; Makes the CPU perform the input for a forward jump, "randomized" between a small hop and hyper jump.
; Note this will always be done regardless of whatever action we're in, so it could have
; different effects if we are in the middle of a special move.
Play_CPU_SetJoyKeysJumpUF:

	;
	; Every alternating 16 frames, try to perform a D+U input.
	; This triggers an hyper jump if done.
	;
	ld   a, [wTimer]
	bit  4, a					; (wTimer & $10) == 0?
	jp   z, .setJumpDir			; If so, skip
	ld   hl, MoveInput_DU_Fast
	call Play_CPU_ApplyMoveInputDir
	
.setJumpDir:

	;
	; Perform the forward jump input, which will get added to the buffer later
	; in the frame when Play_WriteKeysToBuffer gets executed.
	;
	
	; Determine which direction is for moving forward
	ld   hl, iOBJInfo_OBJLstFlags
	add  hl, de
	bit  SPRB_XFLIP, [hl]		; Are we facing right?
	jp   nz, .setJumpR			; If so, jump
.setJumpL:	
	ld   a, KEY_LEFT|KEY_UP		; UL is forward when facing left (2P side)
	ld   d, $00
	jp   Play_CPU_SetJoyKeys
.setJumpR:
	ld   a, KEY_RIGHT|KEY_UP	; UR is forward when facing right (1P side)
	ld   d, $00
	jp   Play_CPU_SetJoyKeys

; =============== Play_CPU_SetRandCharInputH ===============
; Makes the CPU perform a random heavy special move input / character-specific move input.
Play_CPU_SetRandCharInputH:
	call Rand	; Randomize moveinput id
	and  a, $07	; Force valid range ($00-$07)
	scf			; Use heavy version (#1)
	jp   Play_CPU_ApplyCharInput
	
; =============== Play_CPU_SetJoyKeysB_HP_C50 ===============
; Makes the CPU perform an heavy punch while holding back.
; There's 50% chance for this to happen.
; Because this is called when close to the opponent, the intention
; is to start a throw, but the player may not be on the ground / in 
; throw range, so it won't always happen.
Play_CPU_SetJoyKeysB_HP_C50:
	call Rand
	bit  0, a
	ret  z
	ld   hl, iOBJInfo_OBJLstFlags
	add  hl, de
	bit  SPRB_XFLIP, [hl]	; Are we visually facing right? (1P side)
	jp   nz, .moveL			; If so, jump
	ld   a, KEY_RIGHT		; On the 2P side, right is backwards
	ld   d, KEP_B_HEAVY
	jp   Play_CPU_SetJoyKeys
.moveL:
	ld   a, KEY_LEFT		; On the 1P side, left is backwards
	ld   d, KEP_B_HEAVY
	jp   Play_CPU_SetJoyKeys
	

; =============== Play_CPU_SetJoyKeys*_C75 ===============
; Sets of subroutines that makes the CPU perform a punch/kick input.
; These subroutines are affected by difficulty in the same way:
; - On EASY and NORMAL difficulties, there's a 75% chance of not moving.
; - On HARD difficulty, the CPU always moves.
	
; =============== Play_CPU_SetJoyKeysLP_C25 ===============
; Makes the CPU perform a standing light punch input.
Play_CPU_SetJoyKeysLP_C25:
	ld   a, [wDifficulty]
	cp   DIFFICULTY_HARD	; On HARD difficulty?
	jp   z, .setKeys		; If so, skip
	call Rand				; A = Rand
	bit  0, a				; bit0 set? (50%)
	ret  z					; If so, return
	bit  1, a				; bit1 set? (another 50%)
	ret  z					; If so, return
.setKeys:
	xor  a ; KEY_NONE
	ld   d, KEP_B_LIGHT
	jp   Play_CPU_SetJoyKeys
; =============== Play_CPU_SetJoyKeysAtkG_C25 ===============
; Makes the CPU perform a ground A+B attack.
Play_CPU_SetJoyKeysAtkG_C25:
	ld   a, [wDifficulty]
	cp   DIFFICULTY_HARD
	jp   z, .setKeys
	call Rand
	bit  0, a
	ret  z
	bit  1, a
	ret  z
.setKeys:
	ld   a, KEY_A|KEY_B
	ld   d, KEP_B_HEAVY|KEP_A_HEAVY
	jp   Play_CPU_SetJoyKeys
; =============== Play_CPU_SetJoyKeysHP_C25 ===============
; Makes the CPU perform a standing heavy punch input.
Play_CPU_SetJoyKeysHP_C25:
	ld   a, [wDifficulty]
	cp   DIFFICULTY_HARD
	jp   z, .setKeys
	call Rand
	bit  0, a
	ret  z
	bit  1, a
	ret  z
.setKeys:
	xor  a ; KEY_NONE
	ld   d, KEP_B_HEAVY
	jp   Play_CPU_SetJoyKeys
; =============== Play_CPU_SetJoyKeysC_LP_C25 ===============
; Makes the CPU perform a crouching light punch input.
Play_CPU_SetJoyKeysC_LP_C25:
	ld   a, [wDifficulty]
	cp   DIFFICULTY_HARD
	jp   z, .setKeys
	call Rand
	bit  0, a
	ret  z
	bit  1, a
	ret  z
.setKeys:
	ld   a, KEY_DOWN
	ld   d, KEP_B_LIGHT
	jp   Play_CPU_SetJoyKeys
; =============== Play_CPU_Unused_SetJoyKeysC_HP_C25 ===============
; [TCRF] Unreferenced code.
; Makes the CPU perform a crouching heavy punch input.
Play_CPU_Unused_SetJoyKeysC_HP_C25:
	ld   a, [wDifficulty]
	cp   DIFFICULTY_HARD
	jp   z, .setKeys
	call Rand
	bit  0, a
	ret  z
	bit  1, a
	ret  z
.setKeys:          
	ld   a, KEY_DOWN
	ld   d, KEP_B_HEAVY
	jp   Play_CPU_SetJoyKeys
	
; =============== Play_CPU_SetJoyKeysLK ===============
; Makes the CPU perform the light kick input.
Play_CPU_SetJoyKeysLK:
	xor  a ; KEY_NONE
	ld   d, KEP_A_LIGHT
	jp   Play_CPU_SetJoyKeys
	
; =============== Play_CPU_SetJoyKeysHK ===============
; Makes the CPU perform the heavy kick input.
Play_CPU_SetJoyKeysHK:
	xor  a ; KEY_NONE
	ld   d, KEP_A_HEAVY
	jp   Play_CPU_SetJoyKeys
	
; =============== Play_CPU_SetJoyKeysB_HopRand ===============
; Makes the CPU move back.
; On NORMAL and EASY difficulties, there's a 50% chance the CPU will hop backwards.
Play_CPU_SetJoyKeysB_HopRand:
	ld   a, [wDifficulty]
	cp   DIFFICULTY_HARD			; On hard difficulty?
	jp   z, Play_CPU_SetJoyKeysB	; If so, skip
	
	; Moving or hopping backwards? 50% chance of either.
	call Rand		; A = Rand
	bit  7, a		; A < $80?		
	jp   z, Play_CPU_SetJoyKeysB	; If so, jump
	
	; The hop input will be copied to the buffer.
	ld   hl, MoveInput_BB
	call Play_CPU_ApplyMoveInputDir
	; Fall-through
	
; =============== Play_CPU_SetJoyKeysB ===============
; Makes the CPU input back.
Play_CPU_SetJoyKeysB:
	ld   hl, iOBJInfo_OBJLstFlags
	add  hl, de
	bit  SPRB_XFLIP, [hl]	; Are we visually facing right? (1P side)
	jp   nz, .moveL			; If so, jump
.moveR:
	ld   a, KEY_RIGHT		; On the 2P side, right is backwards
	ld   d, $00
	jp   Play_CPU_SetJoyKeys
.moveL:
	ld   a, KEY_LEFT		; On the 1P side, left is backwards
	ld   d, $00
	jp   Play_CPU_SetJoyKeys
	
; =============== Play_CPU_SetJoyKeysDB ===============
; Makes the CPU input down back.
Play_CPU_SetJoyKeysDB:
	ld   hl, iOBJInfo_OBJLstFlags
	add  hl, de
	bit  SPRB_XFLIP, [hl]	; Are we visually facing right? (1P side)
	jp   nz, .moveUL		; If so, jump
.moveUR:
	ld   a, KEY_DOWN|KEY_RIGHT
	ld   d, $00
	jp   Play_CPU_SetJoyKeys
.moveUL:
	ld   a, KEY_DOWN|KEY_LEFT
	ld   d, $00
	jp   Play_CPU_SetJoyKeys
	
; =============== Play_CPU_SetJoyKeysF_RunRand ===============
; Makes the CPU move forward if it's not too close to the opponent.
; There's a 50% chance the CPU will run forwards.
Play_CPU_SetJoyKeysF_RunRand:

	; Don't do anything if we're too close to the opponent
	ld   hl, iPlInfo_PlDistance
	add  hl, bc
	ld   a, [hl]
	cp   $1A				; iPlInfo_PlDistance < $1A?
	ret  c					; If so, return
	
	; Moving or running forward? 50% chance of either.
	call Rand		; A = Rand
	bit  7, a		; A < $80?
	jp   z, Play_CPU_SetJoyKeysF	; If so, jump
.setRun:
	; The run input will be copied to the buffer.
	; Note that we don't return because we still need to make the CPU hold forward,
	; otherwise the run ends quickly.
	ld   hl, MoveInput_FF
	call Play_CPU_ApplyMoveInputDir
	; Fall-through
	
; =============== Play_CPU_SetJoyKeysF ===============
; Makes the CPU input forward.
Play_CPU_SetJoyKeysF:
	ld   hl, iOBJInfo_OBJLstFlags
	add  hl, de
	bit  SPRB_XFLIP, [hl]	; Are we visually facing right? (1P side)
	jp   nz, .moveR			; If so, jump
.moveL:
	ld   a, KEY_LEFT		; On the 2P side, left is forwards
	ld   d, $00
	jp   Play_CPU_SetJoyKeys
.moveR:
	ld   a, KEY_RIGHT		; On the 1P side, right is forwards
	ld   d, $00
	jp   Play_CPU_SetJoyKeys
	
; =============== Play_CPU_SetJoyKeys ===============
; Writes the "current" joypad keys values.
;
; Later in the frame, when Play_WriteKeysToBuffer gets executed, these inputs will
; be added to the buffer at iPlInfo_JoyDirBuffer & iPlInfo_JoyBtnBuffer.
;
; IN
; - A: Held keys (iPlInfo_JoyKeys)
; - D: Light/Heavy button info (iPlInfo_JoyNewKeysLH)
Play_CPU_SetJoyKeys:
	ld   hl, iPlInfo_JoyKeys
	add  hl, bc
	ldi  [hl], a	; Write A to iPlInfo_JoyKeys, seek to iPlInfo_JoyNewKeysLH
	ld   [hl], d	; Write D to iPlInfo_JoyNewKeysLH
	ret
	
; =============== Play_CPU_ApplyCharInput ===============
; Makes the CPU perform a character-specific move input.
;
; How this works:
;
; Each character is assigned a list of move inputs (CPU_MoveInputList_*).
; The table at CPU_MoveListPtrTable assigns one for every character.
;
; Each MoveInputList itself is a table of 8 entries with 4 bytes each:
; - 0-1: Ptr to a MoveInput_* (iCPUMoveListItem_MoveInputPtr) for the old keypresses
; - 2: Current LH button input #0 + MoveInput type flag (CMLB_BTN) (iCPUMoveListItem_LastLHKeyA)
; - 3: Current LH button input #1 (iCPUMoveListItem_LastLHKeyB)
;
; The combination of MoveInput and button allows to define standard motions like:
; -> DF+B
; With MoveInput_DF defining DF and iCPUMoveListItem_LastLHKey* being KEP_B_LIGHT.
;
; The MoveInput data doesn't necessarily have to point to a d-pad motion.
; If in the second byte, iCPUMoveListItem_LastLHKeyA, the flag CML_BTN is set, the
; MoveInput is treated as a button-based input (ie: pressing B 3 times).
; Since this has to be defined manually, it should be consistent with the MoveInput. 
;
; Regardless of that, iCPUMoveListItem_LastLHKey* will always be a punch or kick input
; in LH format (for iPlInfo_JoyNewKeysLH), with the CML_BTN flag stripped out.
;
; Notice that there are two possible inputs the game can choose.
; Which one is picked depends on the C flag passed to the subroutine, which is arbitrary
; for every point that calls this.
; In practice, the input lists are set so that #0 is always a light button, and #1 is always an heavy.
; This means the C flag effectively determines the strength of the move.
;
; IN
; - A: ID of the CPU_MoveInputList_* entry, should be a random value
; - C flag: If set, use LH input #1 (heavy button, iCPUMoveListItem_LastLHKeyB).
;           If clear, use #0 (light button, iCPUMoveListItem_LastLHKeyA)
Play_CPU_ApplyCharInput:

	;
	; Seek to the character-specific input list (CPU_MoveInputList_*)
	; HL = CPU_MoveListPtrTable[iPlInfo_CharId]
	;
	push af
		; A = CharId
		ld   hl, iPlInfo_CharId
		add  hl, bc
		ld   a, [hl]		
		; HL = Base char table
		ld   hl, CPU_MoveListPtrTable
		; Index the table (HL += A)
		add  a, l			; Index it
		jp   nc, .noovf		; Did we overflow? (never happens)
		inc  h 				
	.noovf:
		ld   l, a			; Save it back
		ld   e, [hl]		; Read out the ptr to DE
		inc  hl
		ld   d, [hl]
		push de				; Move it to HL
		pop  hl
	pop  af
	
	
	;
	; Seek to the <A>'th entry of the list and read out its bytes:
	; - DE: iCPUMoveListItem_MoveInputPtr
	; - A: iCPUMoveListItem_LastLHKeyA
	; - HL: Ptr to iCPUMoveListItem_LastLHKeyA
	;
	push af
		; As each entry is 4 bytes long, A = A * 4
		sla  a				; A = A * 4
		sla  a
		; Offset the move list table (HL += A)
		add  a, l			; Index HL by that
		jp   nc, .noovf2
		inc  h
	.noovf2:
		ld   l, a
		
		; HL now points to the start of the iCPUMoveListItem entry.
		; Read out its initial data.
		
		; [byte0-1] DE = iCPUMoveListItem_MoveInputPtr
		ld   e, [hl]
		inc  hl
		ld   d, [hl]
		inc  hl
		; [byte2] A = iCPUMoveListItem_LastLHKeyA
		;         For now, this is strictly used for the CML_BTN flag,
		;         which tells if this or the next value should be used as iPlInfo_JoyNewKeysLH
		ld   a, [hl]		; Read out byte2 to A
		
		push hl ; Save the ptr to iCPUMoveListItem_LastLHKeyA
		
			;
			; Determine what kind of MoveInput we're dealing with.
			; If A has CMLB_BTN set, treat the input as contining LH punch/kick buttons (.inptBtn)
			; Otherwise, treat it as containing d-pad keys (.inptDir).
			;
			; Note that the Play_CPU_ApplyMoveInput* subroutine called is the only difference
			; between .inptDir and .inptBtn.
			; Everything below that call is identical.
			;
	

			; Move this to HL for Play_CPU_ApplyMoveInput*
			push de			
			pop  hl
	
			bit  CMLB_BTN, a	; Is the flag set?
			jp   nz, .inptBtn	; If so, jump		
		.inptDir:
			
			;
			; Apply MoveInput to iPlInfo_JoyDirBuffer
			;
			call Play_CPU_ApplyMoveInputDir
			
			;
			; Determine which LH input to use for the button, then filter it and apply it.
			;
			
			; After the pop, HL will point to input #0.
			; If the C flag passed to the subroutine is set, increment HL once
			; to make it point to input #1.
		pop  hl				; HL = Ptr to iCPUMoveListItem_LastLHKeyA (#0)
	pop  af					; C flag = If set, use input #1
	jp   nc, .inptDir_setLH	; Is it set? If not, skip (use #0)
	inc  hl					; Otherwise, seek to #1 (iCPUMoveListItem_LastLHKeyB)
.inptDir_setLH:
	ld   a, [hl]			; Read LH input value
	and  a, $FF^CML_BTN		; Remove CML_BTN flag since it has another purpose
	ld   d, a				; D = LH Input
	ld   a, KEY_NONE		; A = Nothing
	jp   Play_CPU_SetJoyKeys
	
.inptBtn:
			call Play_CPU_ApplyMoveInputBtn
			; Rest is identical to above
		pop  hl
	pop  af
	jp   nc, .inptBtn_setLH
	inc  hl
.inptBtn_setLH:
	ld   a, [hl]
	and  a, $FF^CML_BTN			
	ld   d, a
	ld   a, KEY_NONE
	jp   Play_CPU_SetJoyKeys
	
; =============== Play_CPU_ApplyMoveInputBtn ===============
; Writes the "old" joypad keys values for buttons.
;
; This copies the inputs from a MoveInfo to the input buffer of A/B button keys.
; IN
; - HL: Ptr to a MoveInput structure containing only button inputs.
Play_CPU_ApplyMoveInputBtn:
	push bc
		push de
			; Move the ptr to DE
			push hl		; DE = HL
			pop  de
			
			;
			; The iMoveInputItem entries are stored from last to first for ease of checking when handling player inputs.
			; However, since we're replacing the input buffer with inputs from a MoveInput, we have to write
			; them in reverse.
			;
			
			;
			; Make iPlInfo_JoyBtnBufferOffset point to where the last MoveInput entry would be written.
			;
			
			; A = (iMoveInput_Length - 1) * 2
			ld   a, [de]	; A = iPlInfo_JoyBtnBufferOffset
			dec  a			; -1 since we want the last entry
			sla  a			; *2 since each iMoveInputItem is 2 bytes long
			; Set it as iPlInfo_JoyBtnBufferOffset
			ld   hl, iPlInfo_JoyBtnBufferOffset
			add  hl, bc
			ld   [hl], a
			
			; 
			; HL = Ptr to the newly set buffer location.
			;
			ld   hl, iPlInfo_JoyBtnBuffer
			add  hl, bc			; HL = Ptr to iPlInfo_JoyBtnBuffer
			add  a, l			; L += iPlInfo_JoyBtnBufferOffset
			ld   l, a
			
			;
			; A = iMoveInput_Length
			;
			ld   a, [de]		
			inc  de			; Seek to first iMoveInputItem_JoyKeys entry
			jp   Play_CPU_ApplyMoveInputCustom
; =============== Play_CPU_ApplyMoveInputDir ===============
; Writes the "old" joypad keys values for d-pad keys.
;
; Copies the inputs from a MoveInfo to the input buffer of directional keys.
; See also: Play_CPU_ApplyMoveInputBtn
; IN
; - HL: Ptr to a MoveInput structure containing only directional key inputs.
Play_CPU_ApplyMoveInputDir:
	push bc
		push de
			; DE = HL
			push hl
			pop  de
			; A = (iMoveInput_Length - 1) * 2
			ld   a, [de]
			dec  a
			sla  a
			; iPlInfo_JoyBtnBufferOffset = A
			ld   hl, iPlInfo_JoyDirBufferOffset
			add  hl, bc
			ld   [hl], a
			; HL = iPlInfo_JoyDirBuffer + A
			ld   hl, iPlInfo_JoyDirBuffer
			add  hl, bc
			add  a, l
			ld   l, a
			; A = iMoveInput_Length
			ld   a, [de]
			inc  de			; Seek to first iMoveInputItem_JoyKeys entry
			
			; Fall-through

		; =============== Play_CPU_ApplyMoveInputCustom ===============			
		; Copies inputs from a list of iMoveInputItem_* to the specified buffer.
		; The copy operation is done backwards, starting at HL and moving backwards,
		; and must point to an exact location so the last iMoveInputItem write aligns
		; to the first entry of the buffer.
		;
		; IN
		; - A: iMoveInput_Length
		; - DE: Ptr to first iMoveInputItem_JoyKeys (byte0) of MenuInput
		; - HL: Ptr to destination buffer (somewhere in iPlInfo_JoyBtnBuffer or iPlInfo_JoyDirBuffer)
		Play_CPU_ApplyMoveInputCustom:
			
			; For every iMoveInputItem entry...
			push af				; Save remaining count
			
				;
				; Copy the keypress bitmask to byte0 of the iPlInfo_Joy*Buffer entry
				;
				ld   a, [de]	; A = iMoveInputItem_JoyKeys
				ldi  [hl], a	; Copy it over to byte0, and seek to byte1
				
				;
				; Copy the max keypress length to byte1 of the of the iPlInfo_Joy*Buffer entry
				;
				inc  de			; Seek to iMoveInputItem_JoyMaskKeys
				inc  de			; Seek to iMoveInputItem_MinLength
				inc  de			; Seek to iMoveInputItem_MaxLength
				ld   a, [de]	; A = iMoveInputItem_MaxLength
				ld   [hl], a	; Copy it over to byte1
				
				;
				; Advance to next iMoveInputItem entry (source)
				; and go back to byte0 of the previous iPlInfo_Joy*Buffer entry (destination)
				;
				inc  de			; Seek to iMoveInputItem_JoyKeys of next entry
				
				dec  hl			; Seek back to byte0 of current iPlInfo_Joy*Buffer entry
				dec  hl			; Seek back to byte1 of previous iPlInfo_Joy*Buffer entry
				dec  hl			; and to byte0
				
			;
			; Are we done?
			;
			pop  af				; Restore remaining count
			dec  a				; Copied all bytes?
			jp   nz, Play_CPU_ApplyMoveInputCustom	; If not, loop
		pop  de
	pop  bc
	ret
	
; =============== CPU_MoveListPtrTable ===============
; Assigns to each character a list of move inputs they can perform.
; Notes:
; - Chizuru and Kagura are almost identical and reuse the same move list.
; - O.Iori and O.Leona have special moves that are unique to them, so they get their own lists.
; - Mr.Karate reuses the same move list as Ryo.
CPU_MoveListPtrTable:
	dw CPU_MoveInputList_Kyo ; CHAR_ID_KYO
	dw CPU_MoveInputList_Daimon ; CHAR_ID_DAIMON
	dw CPU_MoveInputList_Terry ; CHAR_ID_TERRY
	dw CPU_MoveInputList_Andy ; CHAR_ID_ANDY
	dw CPU_MoveInputList_Ryo ; CHAR_ID_RYO
	dw CPU_MoveInputList_Robert ; CHAR_ID_ROBERT
	dw CPU_MoveInputList_Athena ; CHAR_ID_ATHENA
	dw CPU_MoveInputList_Mai ; CHAR_ID_MAI
	dw CPU_MoveInputList_Leona ; CHAR_ID_LEONA
	dw CPU_MoveInputList_Geese ; CHAR_ID_GEESE
	dw CPU_MoveInputList_Krauser ; CHAR_ID_KRAUSER
	dw CPU_MoveInputList_MrBig ; CHAR_ID_MRBIG
	dw CPU_MoveInputList_Iori ; CHAR_ID_IORI
	dw CPU_MoveInputList_Mature ; CHAR_ID_MATURE
	dw CPU_MoveInputList_Chizuru ; CHAR_ID_CHIZURU
	dw CPU_MoveInputList_Goenitz ; CHAR_ID_GOENITZ
	dw CPU_MoveInputList_Ryo ; CHAR_ID_MRKARATE
	dw CPU_MoveInputList_OIori ; CHAR_ID_OIORI
	dw CPU_MoveInputList_OLeona ; CHAR_ID_OLEONA
	dw CPU_MoveInputList_Chizuru ; CHAR_ID_KAGURA

; =============== CPU_MoveInputList_* ===============
; List of character-specific move inputs.
; See also: Play_CPU_ApplyCharInput for more info.
CPU_MoveInputList_Kyo: 
	; DF+P -> 114 Shiki Ara Kami
	dw MoveInput_DF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; FDF+P -> 100 Shiki Oni Yaki
	dw MoveInput_FDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; BDB+K -> R.E.D. Kick
	dw MoveInput_BDB
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; FDB+K -> 212 Shiki Kototsuki You 
	dw MoveInput_FDB
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; DF+K -> 75 Shiki Kai
	dw MoveInput_DF
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; DB+P -> 910 Shiki Nue Tumi
	dw MoveInput_DB
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; FDF+P -> 100 Shiki Oni Yaki
	dw MoveInput_FDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DBDF+P -> Ura 108 Shiki Orochi Nagi
	dw MoveInput_DBDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY

CPU_MoveInputList_Daimon:
	; FDF+P -> Jirai Shin
	dw MoveInput_FDF
	db KEP_B_LIGHT
IF REV_VER_2 == 0
	db KEP_B_HEAVY
ELSE
	db KEP_B_LIGHT ; Changed to prevent the CPU from using Fake Jirai Shin
ENDC
	; DB+K -> Chou Ukemi
	dw MoveInput_DB
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; FDF+P -> Jirai Shin
	dw MoveInput_FDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; BDF+K -> Chou Oosoto Gari
	dw MoveInput_BDF
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; BDF+P -> Cloud Tosser / Stump Throw
	dw MoveInput_BDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; FDBF+P -> Heaven Drop
	dw MoveInput_FDBF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; BDF+P -> Cloud Tosser / Stump Throw
	dw MoveInput_BDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; FDBx2+P -> Heaven to Hell Drop
	dw MoveInput_FDBFDB
	db KEP_B_LIGHT
	db KEP_B_HEAVY

CPU_MoveInputList_Terry:
	; DF+P -> Power Wave
	dw MoveInput_DF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; FDF+P -> Rising Tackle
	dw MoveInput_FDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DB+P -> Burn Knuckle
	dw MoveInput_DB
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DB+K -> Crack Shot
	dw MoveInput_DB
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; FDF+K -> Power Dunk
	dw MoveInput_FDF
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; DB+P -> Burn Knuckle
	dw MoveInput_DB
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; FDF+K -> Power Dunk
	dw MoveInput_FDF
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; DBDF+P -> Power Geyser
	dw MoveInput_DBDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY

CPU_MoveInputList_Andy:
	; DB+P -> Hi Sho Ken
	dw MoveInput_DB
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; FDF+P -> Sho Ryu Dan
	dw MoveInput_FDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; BF+P -> Zan Ei Ken
	dw MoveInput_BF_Fast
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; BDF+K -> Ku Ha Dan 
	dw MoveInput_BDF
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; BDF+P (close) -> Geki Heki Hai Sui Sho
	dw MoveInput_BDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DF+K (air) -> Genei Shiranui
	dw MoveInput_DF
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; FDF+P -> Sho Ryu Dan
	dw MoveInput_FDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DBDF+K -> Cho Reppa Dan
	dw MoveInput_DBDF
	db KEP_A_LIGHT
	db KEP_A_HEAVY

CPU_MoveInputList_Ryo:
	; DF+P -> Ko Ou Ken 
	dw MoveInput_DF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; FDF+P -> Ko Hou
	dw MoveInput_FDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DB+P -> Mou Ko Rai Jin Gou
	dw MoveInput_DB
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DB+K -> Hien Shippu Kyaku
	dw MoveInput_DB
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; BDF+P (close) -> Kyokuken Ryu Renbu Ken
	dw MoveInput_BDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; ???
	dw MoveInput_FDF
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; FBDF+P -> Haoh Shokoh Ken 
	dw MoveInput_FBDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DFDB+P -> Ryu Ko Ranbu
	dw MoveInput_DFDB
	db KEP_B_LIGHT
	db KEP_B_HEAVY

CPU_MoveInputList_Robert:
	; DF+P -> Ryuu Geki Ken	
	dw MoveInput_DF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; FDF+P -> Ryuu Ga
	dw MoveInput_FDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; ???
	dw MoveInput_DB
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; FDB+K -> Hien Shippu Kyaku
	dw MoveInput_FDB
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; BDF+K -> Kyokugen Ryu Ranbu Kyaku
	dw MoveInput_BDF
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; ???
	dw MoveInput_FDF
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; FBDF+P -> Haoh Shokoh Ken 
	dw MoveInput_FBDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DFDB+P -> Ryu Ko Ranbu
	dw MoveInput_DFDB
	db KEP_B_LIGHT
	db KEP_B_HEAVY

CPU_MoveInputList_Athena:
	; DB+P -> Psycho Ball (ground) / Phoenix Arrow (air)
	dw MoveInput_DB
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; FDF+P -> Psycho Sword
	dw MoveInput_FDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DB+P -> Psycho Ball (ground) / Phoenix Arrow (air)
	dw MoveInput_DB
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; FDB+K -> Psycho Reflector
	dw MoveInput_FDB
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; DF+K -> Psycho Teleport
	dw MoveInput_DF
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; FDB+K -> Psycho Reflector
	dw MoveInput_FDB
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; DF+K -> Psycho Teleport
	dw MoveInput_DF
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; BFDB+P -> Shining Crystal Bit
	dw MoveInput_BFDB
	db KEP_B_LIGHT
	db KEP_B_HEAVY

CPU_MoveInputList_Mai:
	; DF+P -> Ka Cho Sen
	dw MoveInput_DF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; FDF+K -> Hisho Ryu En Jin
	dw MoveInput_FDF
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; BDF+K -> Hissatsu Shinobibachi
	dw MoveInput_BDF
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; DB+P -> Ryu En Bu (ground) / Kuuchuu Musasabi no Mai (air)
	dw MoveInput_DB
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; FDB+P -> Chijou Musasabi no Mai 
	dw MoveInput_FDB
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DB+P -> Ryu En Bu (ground) / Kuuchuu Musasabi no Mai (air)
	dw MoveInput_DB
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DB+P -> Ryu En Bu (ground) / Kuuchuu Musasabi no Mai (air)
	dw MoveInput_DB
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DBDF+K -> Cho Hissatsu Shinobibachi
	dw MoveInput_DBDF
	db KEP_A_LIGHT
	db KEP_A_HEAVY

CPU_MoveInputList_Leona:
	; DU+K -> X-Calibur
	dw MoveInput_DU_Slow
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; BF+K -> Grand Sabre
	dw MoveInput_BF_Slow
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; DU+P -> Moon Slasher
	dw MoveInput_DU_Slow
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; BF+P -> Baltic Launcher
	dw MoveInput_BF_Slow
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DU+K -> X-Calibur
	dw MoveInput_DU_Slow
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; DU+P -> Moon Slasher
	dw MoveInput_DU_Slow
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DFDB+P (air) -> V Slasher
	dw MoveInput_DFDB
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DFDB+P (air) -> V Slasher
	dw MoveInput_DFDB
	db KEP_B_LIGHT
	db KEP_B_HEAVY

CPU_MoveInputList_OLeona:
	; DU+K -> X-Calibur
	dw MoveInput_DU_Slow
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; FDB+P -> Storm Bringer
	dw MoveInput_FDB
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; BF+K -> Grand Sabre
	dw MoveInput_BF_Slow
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; DU+P -> Moon Slasher
	dw MoveInput_DU_Slow
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; BF+P -> Baltic Launcher
	dw MoveInput_BF_Slow
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DU+K -> X-Calibur
	dw MoveInput_DU_Slow
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; DFDB+P -> Super Moon Slasher (ground) / V Slasher (air)
	dw MoveInput_DFDB
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DFDB+P -> Super Moon Slasher (ground) / V Slasher (air)
	dw MoveInput_DFDB
	db KEP_B_LIGHT
	db KEP_B_HEAVY

CPU_MoveInputList_Geese:
	; DF+P -> Reppuken
	dw MoveInput_DF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; BDF+K -> Atemi Nage
	dw MoveInput_BDF
	db KEP_A_LIGHT
	db KEP_A_LIGHT
	; FDB+P -> Ja ei ken
	dw MoveInput_FDB
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; FDF+P -> Hishou Nichirin Zan
	dw MoveInput_FDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; BDF+K -> Atemi Nage
	dw MoveInput_BDF
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; DB+P (air) -> Shippu Ken
	dw MoveInput_DB
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DB+P (air) -> Shippu Ken
	dw MoveInput_DB
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; BFDBF+P -> Raging Storm
	dw MoveInput_BFDBF
	db KEP_B_LIGHT
	db KEP_B_HEAVY

CPU_MoveInputList_Krauser:
	; DB+P -> High Blitz Ball
	dw MoveInput_DB
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DF+K -> Leg Tomahawk
	dw MoveInput_DF
	db KEP_A_HEAVY
	db KEP_A_HEAVY
	; FDF+K -> Kaiser Kick
	dw MoveInput_FDF
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; BDF+K -> Kaiser Duel Sobat
	dw MoveInput_BDF
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; DF+K -> Leg Tomahawk
	dw MoveInput_DF
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; FDBF+P (close) -> Kaiser Suplex
	dw MoveInput_FDBF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DB+K -> Low Blitz Ball
	dw MoveInput_DB
	db KEP_A_LIGHT
	db KEP_A_HEAVY;X
	; FBDF+P -> Kaiser Wave
	dw MoveInput_FBDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY

CPU_MoveInputList_MrBig:
	; DF+P -> Ground Blaster
	dw MoveInput_DF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; FDF+P -> California Romance
	dw MoveInput_FDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; FDB+P -> Cross Divingz
	dw MoveInput_FDB
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; FDB+K -> Spinning Lancer
	dw MoveInput_FDB
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; DF+P -> Ground Blaster
	dw MoveInput_DF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; Px3 -> Crazy Drum Dram
	dw MoveInput_PPP
	db KEP_B_LIGHT|CML_BTN
	db KEP_B_HEAVY|CML_BTN
	; FDF+P -> California Romance
	dw MoveInput_FDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DFDF+P -> Blaster Wave
	dw MoveInput_DFDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY

CPU_MoveInputList_Iori:
	; DF+P -> 108 Shiki Yami-barai
	dw MoveInput_DF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; FDF+P -> 100 Shiki Oni Yaki
	dw MoveInput_FDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DB+P -> 127 Aoi Hana
	dw MoveInput_DB
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; FDB+K -> Shiki Koto Tsuki In
	dw MoveInput_FDB
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; BDF+P -> Scum Gale
	dw MoveInput_BDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; FDB+K -> Shiki Koto Tsuki In
	dw MoveInput_FDB
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; FDF+P -> 100 Shiki Oni Yaki
	dw MoveInput_FDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DBDF+P -> Kin 1201 Shiki Ya Otome
	dw MoveInput_DBDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY

CPU_MoveInputList_OIori:
	; DF+P -> 108 Shiki Yami-barai
	dw MoveInput_DF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; FDF+P -> 100 Shiki Oni Yaki
	dw MoveInput_FDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DB+P -> 127 Aoi Hana
	dw MoveInput_DB
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; FDB+K -> Shiki Koto Tsuki In
	dw MoveInput_FDB
	db KEP_A_LIGHT
	db KEP_A_HEAVY;X
	; BDF+P -> Scum Gale
	dw MoveInput_BDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DBDF+K -> Kin 1201 Shiki Ya Otome (Alt)
	dw MoveInput_DBDF
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; FDF+P -> 100 Shiki Oni Yaki
	dw MoveInput_FDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DBDF+P -> Kin 1201 Shiki Ya Otome
	dw MoveInput_DBDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY

CPU_MoveInputList_Mature:
	; DF+P -> Despair
	dw MoveInput_DF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DB+K -> Metal Massacre
	dw MoveInput_DB
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; BDF+P -> Decide
	dw MoveInput_BDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DB+P -> Death Row
	dw MoveInput_DB
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DF+P -> Despair
	dw MoveInput_DF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; BDF+P -> Decide
	dw MoveInput_BDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DB+P -> Death Row
	dw MoveInput_DB
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DBDF+K -> Heaven's Gate
	dw MoveInput_DBDF
	db KEP_A_LIGHT
	db KEP_A_HEAVY

CPU_MoveInputList_Chizuru:
	; BDF+P -> 108 Katsu Tamayura no Shitsune
	dw MoveInput_BDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; FDF+P -> 100 Katso Tenjin no Kotowari 
	dw MoveInput_FDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; FDB+P -> 212 Katsu Shinsoku no Noroti (High)
	dw MoveInput_FDB
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; FDB+K -> 212 Katsu Shinsoku no Noroti (Low)
	dw MoveInput_FDB
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; BDF+P -> 108 Katsu Tamayura no Shitsune
	dw MoveInput_BDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; FDF+P -> 100 Katso Tenjin no Kotowari 
	dw MoveInput_FDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DBDF+P -> Ichimen Ikatsu San Rai no Fui Jin 
	dw MoveInput_DBDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DBDB+K -> Ichimen 85 Katsu Reigi no Ishizue 
	dw MoveInput_DBDB
	db KEP_A_LIGHT
	db KEP_A_HEAVY

CPU_MoveInputList_Goenitz:
	; BDF+P -> Yonokaze (Near)
	dw MoveInput_BDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DBDF+P -> Shinyaotome Mizuchi / Shinyaotome Jissoukoku 
	dw MoveInput_DBDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; BDF+K -> Yonokaze (Far)
	dw MoveInput_BDF
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; BDF+P -> Yonokaze (Near)
	dw MoveInput_BDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DB+K -> Hyouga
	dw MoveInput_DB
	db KEP_A_LIGHT
	db KEP_A_HEAVY
	; DB+P -> Wanpyou Tokobuse
	dw MoveInput_DB
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; FDBx2+P -> Yamidoukoku (Other super move)
	dw MoveInput_FDBFDB
	db KEP_B_LIGHT
	db KEP_B_HEAVY
	; DBDF+P -> Shinyaotome Mizuchi / Shinyaotome Jissoukoku 
	dw MoveInput_DBDF
	db KEP_B_LIGHT
	db KEP_B_HEAVY
ENDC
; 
; =============== END OF SUBMODULE Play->CPU ===============
;

IF REV_LANG_EN == 1
TextC_CutsceneMrKarate0:
	db .end-.start
.start:
	db "Ha,ha,ha!", C_NL
	db "What have we here?", C_NL
	db "A battle! Watch out-", C_NL
	db " here comes", C_NL
	db "          Mr Karare!", C_NL
.end:
TextC_CutsceneMrKarate1:
	db .end-.start
.start:
	db "I`ve been watching", C_NL
	db " you fight", C_NL
	db "        all along.", C_NL
	db "Unbroken victory -", C_NL
	db "    most impressive.", C_NL
.end:
TextC_CutsceneMrKarate2:
	db .end-.start
.start:
	db "But there`s still a", C_NL
	db " lot for you learn!", C_NL
	db "It`s time for me to", C_NL
	db " give you some", C_NL
	db "   special training!", C_NL
.end:
ENDC

IF REV_VER_2 == 0	
; =============== END OF BANK ===============
; Junk area below.
	mIncJunk "L037E3B"
ELSE
	mIncJunk "L037F4A"
ENDC