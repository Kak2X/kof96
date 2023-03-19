OBJLstPtrTable_Daimon_Idle:
	dw OBJLstHdrA_Daimon_Idle0_A, OBJLstHdrB_Daimon_Idle0_B
	dw OBJLstHdrA_Daimon_Idle1_A, OBJLstHdrB_Daimon_Idle0_B
	dw OBJLstHdrA_Daimon_Idle2_A, OBJLstHdrB_Daimon_Idle0_B
	dw OBJLstHdrA_Daimon_Idle3_A, OBJLstHdrB_Daimon_Idle0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_WalkF:
	dw OBJLstHdrA_Daimon_WalkF0_A, OBJLstHdrB_Daimon_WalkF0_B
	dw OBJLstHdrA_Daimon_WalkF1_A, OBJLstHdrB_Daimon_WalkF1_B
	dw OBJLstHdrA_Daimon_WalkF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_WalkF1_A, OBJLstHdrB_Daimon_WalkF1_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_WalkB:
	dw OBJLstHdrA_Daimon_WalkF1_A, OBJLstHdrB_Daimon_WalkF1_B
	dw OBJLstHdrA_Daimon_WalkF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_WalkF1_A, OBJLstHdrB_Daimon_WalkF1_B
	dw OBJLstHdrA_Daimon_WalkF0_A, OBJLstHdrB_Daimon_WalkF0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_Crouch:
	dw OBJLstHdrA_Daimon_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_JumpN:
	dw OBJLstHdrA_Daimon_Crouch0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_JumpN1_A, OBJLstHdrB_Daimon_JumpN1_B
	dw OBJLstHdrA_Daimon_JumpN1_A, OBJLstHdrB_Daimon_JumpN1_B
	dw OBJLstHdrA_Daimon_JumpN3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_JumpN3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_JumpN1_A, OBJLstHdrB_Daimon_JumpN1_B
	dw OBJLstHdrA_Daimon_JumpN1_A, OBJLstHdrB_Daimon_JumpN1_B
	dw OBJLstHdrA_Daimon_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_BlockG:
	dw OBJLstHdrA_Daimon_BlockG0_A, OBJLstHdrB_Daimon_BlockG0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_BlockC:
	dw OBJLstHdrA_Daimon_BlockC0_A, OBJLstHdrB_Daimon_BlockC0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_BlockA:
	dw OBJLstHdrA_Daimon_BlockG0_A, OBJLstHdrB_Daimon_BlockA0_B ;X
	dw OBJLstHdrA_Daimon_Crouch0, OBJLSTPTR_NONE ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_RunF:
	dw OBJLstHdrA_Daimon_RunF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_RunF1_A, OBJLstHdrB_Daimon_WalkF1_B
	dw OBJLstHdrA_Daimon_RunF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_RunF3_A, OBJLstHdrB_Daimon_WalkF1_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_HopB:
	dw OBJLstHdrA_Daimon_HopB0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_HopB1_A, OBJLstHdrB_Daimon_HopB1_B
	dw OBJLstHdrA_Daimon_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_ChargeMeter:
	dw OBJLstHdrA_Daimon_ChargeMeter0_A, OBJLstHdrB_Daimon_ChargeMeter0_B
	dw OBJLstHdrA_Daimon_ChargeMeter1_A, OBJLstHdrB_Daimon_ChargeMeter0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_Taunt:
	dw OBJLstHdrA_Daimon_Taunt0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_Taunt0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_HopB1_A, OBJLstHdrB_Daimon_HopB1_B
	dw OBJLstHdrA_Daimon_Taunt3_A, OBJLstHdrB_Daimon_HopB1_B
	dw OBJLstHdrA_Daimon_Taunt3_A, OBJLstHdrB_Daimon_HopB1_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_WinA:
	dw OBJLstHdrA_Daimon_Taunt0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_Taunt0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_WinA2_A, OBJLstHdrB_Daimon_HopB1_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_WinB:
	dw OBJLstHdrA_Daimon_WinB0_A, OBJLstHdrB_Daimon_WinB0_B
	dw OBJLstHdrA_Daimon_WinB1_A, OBJLstHdrB_Daimon_WinB0_B
	dw OBJLstHdrA_Daimon_WinB2_A, OBJLstHdrB_Daimon_WinB0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_PunchL:
	dw OBJLstHdrA_Daimon_WalkF1_A, OBJLstHdrB_Daimon_WalkF0_B
	dw OBJLstHdrA_Daimon_PunchL1_A, OBJLstHdrB_Daimon_WalkF0_B
	dw OBJLstHdrA_Daimon_WalkF1_A, OBJLstHdrB_Daimon_WalkF0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_PunchH:
	dw OBJLstHdrA_Daimon_PunchH0_A, OBJLstHdrB_Daimon_PunchH0_B
	dw OBJLstHdrA_Daimon_PunchH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_PunchH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_PunchH0_A, OBJLstHdrB_Daimon_PunchH0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_KickL:
	dw OBJLstHdrA_Daimon_KickL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_KickL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_KickL0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_KickH:
	dw OBJLstHdrA_Daimon_KickL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_KickH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_KickH2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_KickL0, OBJLSTPTR_NONE ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_PunchCL:
	dw OBJLstHdrA_Daimon_PunchCL0_A, OBJLstHdrB_Daimon_PunchCL0_B
	dw OBJLstHdrA_Daimon_PunchCL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_PunchCL0_A, OBJLstHdrB_Daimon_PunchCL0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_PunchCH:
	dw OBJLstHdrA_Daimon_PunchCL0_A, OBJLstHdrB_Daimon_PunchCH0_B
	dw OBJLstHdrA_Daimon_PunchCH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_PunchCH2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_PunchCL0_A, OBJLstHdrB_Daimon_PunchCH0_B ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_KickCL:
	dw OBJLstHdrA_Daimon_KickCL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_KickCL1_A, OBJLstHdrB_Daimon_KickCL1_B
	dw OBJLstHdrA_Daimon_KickCL0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_KickCH:
	dw OBJLstHdrA_Daimon_KickCL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_KickCH1_A, OBJLstHdrB_Daimon_KickCL1_B
	dw OBJLstHdrA_Daimon_KickCH1_A, OBJLstHdrB_Daimon_KickCL1_B
	dw OBJLstHdrA_Daimon_KickCH3, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_PunchA:
	dw OBJLstHdrA_Daimon_JumpN1_A, OBJLstHdrB_Daimon_PunchA0_B
	dw OBJLstHdrA_Daimon_PunchA1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_JumpN3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_JumpN1_A, OBJLstHdrB_Daimon_JumpN1_B ;X
	dw OBJLstHdrA_Daimon_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_KickA:
	dw OBJLstHdrA_Daimon_KickA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_KickA1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_JumpN3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_JumpN1_A, OBJLstHdrB_Daimon_JumpN1_B ;X
	dw OBJLstHdrA_Daimon_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_AttackA:
	dw OBJLstHdrA_Daimon_AttackA0_A, OBJLstHdrB_Daimon_JumpN1_B
	dw OBJLstHdrA_Daimon_AttackA1_A, OBJLstHdrB_Daimon_AttackA1_B
	dw OBJLstHdrA_Daimon_JumpN3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_JumpN1_A, OBJLstHdrB_Daimon_JumpN1_B ;X
	dw OBJLstHdrA_Daimon_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_AttackG:
	dw OBJLstHdrA_Daimon_PunchH0_A, OBJLstHdrB_Daimon_PunchH0_B
	dw OBJLstHdrA_Daimon_AttackG1_A, OBJLstHdrB_Daimon_AttackG1_B
	dw OBJLstHdrA_Daimon_AttackG1_A, OBJLstHdrB_Daimon_AttackG1_B
	dw OBJLstHdrA_Daimon_PunchL1_A, OBJLstHdrB_Daimon_WalkF0_B ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_RollF:
	dw OBJLstHdrA_Daimon_Crouch0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_RollF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_RollF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_RollF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_RollB:
	dw OBJLstHdrA_Daimon_Crouch0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_RollF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_RollF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_RollF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_GuardBreakG:
	dw OBJLstHdrA_Daimon_GuardBreakG0_A, OBJLstHdrB_Daimon_GuardBreakG0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_Dizzy:
	dw OBJLstHdrA_Daimon_Idle0_A, OBJLstHdrB_Daimon_Idle0_B
	dw OBJLstHdrA_Daimon_GuardBreakG0_A, OBJLstHdrB_Daimon_GuardBreakG0_B
OBJLstPtrTable_Daimon_TimeOver:
	dw OBJLstHdrA_Daimon_HopB0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_Hitlow:
	dw OBJLstHdrA_Daimon_Hitlow0_A, OBJLstHdrB_Daimon_Hitlow0_B
	dw OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE;X

OBJLstPtrTable_Daimon_GuardBreakA:
	dw OBJLstHdrA_Daimon_GuardBreakG0_A, OBJLstHdrB_Daimon_GuardBreakG0_B ;X
	dw OBJLstHdrA_Daimon_Crouch0, OBJLSTPTR_NONE ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_BackjumpRecA:
	dw OBJLstHdrA_Daimon_GuardBreakG0_A, OBJLstHdrB_Daimon_GuardBreakG0_B
	dw OBJLstHdrA_Daimon_JumpN1_A, OBJLstHdrB_Daimon_JumpN1_B
	dw OBJLstHdrA_Daimon_JumpN1_A, OBJLstHdrB_Daimon_JumpN1_B
	dw OBJLstHdrA_Daimon_JumpN1_A, OBJLstHdrB_Daimon_JumpN1_B
	dw OBJLstHdrA_Daimon_JumpN1_A, OBJLstHdrB_Daimon_JumpN1_B
	dw OBJLstHdrA_Daimon_JumpN3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_DropMain:
	dw OBJLstHdrA_Daimon_GuardBreakG0_A, OBJLstHdrB_Daimon_GuardBreakG0_B
	dw OBJLstHdrA_Daimon_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_DropMain2, OBJLSTPTR_NONE
OBJLstPtrTable_Daimon_HitMultigs:
	dw OBJLstHdrA_Daimon_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_DropMain2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_HitSwoopup:
	dw OBJLstHdrA_Daimon_HopB0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_HitSwoopup1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_HitSwoopup2, OBJLSTPTR_NONE
OBJLstPtrTable_Daimon_ThrowEndA:
	dw OBJLstHdrA_Daimon_ThrowEndA3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_ThrowEndA3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_DropMain2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_DropDbg:
	dw OBJLstHdrA_Daimon_GuardBreakG0_A, OBJLstHdrB_Daimon_GuardBreakG0_B
	dw OBJLstHdrA_Daimon_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_DropMain2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_ThrowRotL:
	dw OBJLstHdrA_Daimon_ThrowRotL0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_Wakeup:
	dw OBJLstHdrA_Daimon_Crouch0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_JiraiShin:
	dw OBJLstHdrA_Daimon_Taunt0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_JiraiShin1_A, OBJLstHdrB_Daimon_HopB1_B
	dw OBJLstHdrA_Daimon_JiraiShin2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_Taunt0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_CHouUkemiL:
	dw OBJLstHdrA_Daimon_CHouUkemiL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CHouUkemiL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CHouUkemiL2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_CHouOosotoGariL:
	dw OBJLstHdrA_Daimon_WalkF1_A, OBJLstHdrB_Daimon_WalkF1_B
	dw OBJLstHdrA_Daimon_PunchL1_A, OBJLstHdrB_Daimon_WalkF0_B
	dw OBJLstHdrA_Daimon_PunchCH2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CHouOosotoGariL3_A, OBJLstHdrB_Daimon_WalkF0_B
	dw OBJLstHdrA_Daimon_CHouOosotoGariL4_A, OBJLstHdrB_Daimon_CHouOosotoGariL4_B
	dw OBJLstHdrA_Daimon_CHouOosotoGariL4_A, OBJLstHdrB_Daimon_CHouOosotoGariL5_B
	dw OBJLstHdrA_Daimon_CHouOosotoGariL6, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CHouOosotoGariL7, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_Taunt0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_CLoudTosser:
	dw OBJLstHdrA_Daimon_Crouch0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CLoudTosser1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CLoudTosser2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_Taunt0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CLoudTosser4_A, OBJLstHdrB_Daimon_CLoudTosser4_B
	dw OBJLstHdrA_Daimon_CLoudTosser5, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CLoudTosser6, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CLoudTosser7, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CLoudTosser8, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_StumpThrow:
	dw OBJLstHdrA_Daimon_StumpThrow0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_StumpThrow1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_PunchCH2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_Crouch0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CLoudTosser4_A, OBJLstHdrB_Daimon_CLoudTosser4_B
	dw OBJLstHdrA_Daimon_CLoudTosser5, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CLoudTosser6, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CLoudTosser7, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CLoudTosser8, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_HeavenDropL:
	dw OBJLstHdrA_Daimon_HeavenDropL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_HeavenDropL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CLoudTosser4_A, OBJLstHdrB_Daimon_CLoudTosser4_B
	dw OBJLstHdrA_Daimon_HeavenDropL3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_HeavenDropL4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_HeavenDropL5_A, OBJLstHdrB_Daimon_PunchH0_B
	dw OBJLstHdrA_Daimon_HeavenDropL6, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_HeavenDropL7, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CLoudTosser2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_Taunt0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_HeavenHellDropS:
	dw OBJLstHdrA_Daimon_HeavenDropL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CHouOosotoGariL4_A, OBJLstHdrB_Daimon_CHouOosotoGariL4_B
	dw OBJLstHdrA_Daimon_CHouOosotoGariL4_A, OBJLstHdrB_Daimon_CHouOosotoGariL5_B
	dw OBJLstHdrA_Daimon_CHouOosotoGariL6, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_HeavenHellDropS4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_HeavenHellDropS5, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CLoudTosser4_A, OBJLstHdrB_Daimon_CLoudTosser4_B
	dw OBJLstHdrA_Daimon_CLoudTosser5, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CLoudTosser6, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_HeavenDropL4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_HeavenDropL5_A, OBJLstHdrB_Daimon_PunchH0_B
	dw OBJLstHdrA_Daimon_HeavenDropL6, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_HeavenDropL7, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_HeavenHellDropS5, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CLoudTosser4_A, OBJLstHdrB_Daimon_CLoudTosser4_B
	dw OBJLstHdrA_Daimon_CLoudTosser5, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CLoudTosser6, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CLoudTosser7, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CLoudTosser8, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_ThrowG:
	dw OBJLstHdrA_Daimon_PunchL1_A, OBJLstHdrB_Daimon_WalkF0_B
	dw OBJLstHdrA_Daimon_HeavenDropL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_ThrowG2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_ThrowG3_A, OBJLstHdrB_Daimon_ThrowG3_B
	dw OBJLSTPTR_NONE
		
OBJLstHdrA_Daimon_Idle0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_Idle0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1D,$EB,$00 ; $00
	db $18,$F3,$02 ; $01
	db $20,$FB,$04 ; $02
	db $20,$03,$06 ; $03
	db $10,$FB,$08 ; $04
	db $10,$03,$0A ; $05
		
OBJLstHdrB_Daimon_Idle0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Daimon_Idle0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$F3,$00 ; $00
	db $30,$FB,$02 ; $01
	db $30,$03,$04 ; $02
		
OBJLstHdrA_Daimon_Idle1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_Idle1_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1C,$EB,$00 ; $00
	db $18,$F3,$02 ; $01
	db $10,$FB,$04 ; $02
	db $10,$03,$06 ; $03
	db $20,$FB,$08 ; $04
	db $20,$03,$0A ; $05
		
OBJLstHdrA_Daimon_Idle2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_Idle2_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1D,$EB,$00 ; $00
	db $18,$F3,$02 ; $01
	db $20,$FB,$04 ; $02
	db $20,$03,$06 ; $03
	db $10,$FB,$08 ; $04
	db $10,$03,$0A ; $05
		
OBJLstHdrA_Daimon_Idle3_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_Idle3_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1D,$EB,$00 ; $00
	db $17,$F3,$02 ; $01
	db $20,$FB,$04 ; $02
	db $20,$03,$06 ; $03
	db $10,$FB,$08 ; $04
	db $10,$03,$0A ; $05
		
OBJLstHdrA_Daimon_WalkF0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_WalkF0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1E,$E7,$00 ; $00
	db $1F,$EF,$02 ; $01
	db $20,$F7,$04 ; $02
	db $20,$FF,$06 ; $03
	db $0F,$EF,$08 ; $04
	db $10,$F7,$0A ; $05
		
OBJLstHdrB_Daimon_WalkF0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Daimon_WalkF0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$F1,$00 ; $00
	db $30,$F9,$02 ; $01
	db $33,$01,$04 ; $02
		
OBJLstHdrA_Daimon_WalkF1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_WalkF1_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_ThrowG3_A.bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_ThrowG3_A:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_WalkF1_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$F3,$00 ; $00
	db $20,$FB,$02 ; $01
	db $10,$F3,$04 ; $02
	db $10,$FB,$06 ; $03
		
OBJLstHdrB_Daimon_WalkF1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Daimon_WalkF1_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_Daimon_ThrowG3_B.bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Daimon_ThrowG3_B:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	dpr GFX_Char_Daimon_WalkF1_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $30,$F7,$00 ; $00
	db $30,$FF,$02 ; $01
		
OBJLstHdrA_Daimon_WalkF2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_WalkF2 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $26,$EA,$00 ; $00
	db $20,$F2,$02 ; $01
	db $1E,$FA,$04 ; $02
	db $20,$02,$06 ; $03
	db $30,$F2,$08 ; $04
	db $2E,$FA,$0A ; $05
	db $37,$02,$0C ; $06
	db $10,$F5,$0E ; $07
		
OBJLstHdrA_Daimon_Crouch0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_Crouch0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_Unused_CrouchXFlip0.bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
;--
; [TCRF] Unreferenced X Flipped version of OBJLstHdrA_Daimon_Crouch0
OBJLstHdrA_Daimon_Unused_CrouchXFlip0: ;X
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_Crouch0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
;--
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $22,$FB,$00 ; $00
	db $23,$03,$02 ; $01
	db $32,$F3,$04 ; $02
	db $32,$FB,$06 ; $03
	db $33,$03,$08 ; $04
	db $3B,$0B,$0A ; $05
		
OBJLstHdrA_Daimon_BlockG0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_BlockG0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $08 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $19,$EB,$00 ; $00
	db $19,$F3,$02 ; $01
	db $11,$FB,$04 ; $02
	db $21,$FB,$06 ; $03
		
OBJLstHdrA_Daimon_BlockC0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_BlockG0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $0B ; iOBJLstHdrA_XOffset
	db $07 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $19,$EB,$00 ; $00
	db $19,$F3,$02 ; $01
	db $11,$FB,$04 ; $02
	db $21,$FB,$06 ; $03
		
OBJLstHdrB_Daimon_BlockG0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Daimon_BlockG0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $29,$F3,$00 ; $00
	db $29,$FB,$02 ; $01
	db $30,$03,$04 ; $02
	db $39,$F3,$06 ; $03
	db $39,$FB,$08 ; $04
		
OBJLstHdrB_Daimon_BlockC0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Daimon_BlockC0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $0B ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$EA,$00 ; $00
	db $30,$F2,$02 ; $01
	db $30,$FA,$04 ; $02
		
OBJLstHdrB_Daimon_BlockA0_B: ;X
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Daimon_BlockA0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $08 ; iOBJLstHdrA_XOffset
	db $F9 ; iOBJLstHdrA_YOffset
.bin: ;X
	db $05 ; OBJ Count
	;    Y   X  ID
	db $30,$EA,$00 ; $00
	db $30,$F2,$02 ; $01
	db $30,$FA,$04 ; $02
	db $40,$EA,$06 ; $03
	db $40,$F2,$08 ; $04
		
OBJLstHdrA_Daimon_JumpN1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_JumpN1_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $0C ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $10,$F3,$00 ; $00
	db $10,$FB,$02 ; $01
	db $10,$03,$04 ; $02
	db $00,$FB,$06 ; $03
		
OBJLstHdrB_Daimon_JumpN1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Daimon_JumpN1_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $0C ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$FB,$00 ; $00
	db $20,$03,$02 ; $01
	db $30,$FB,$04 ; $02
	db $30,$03,$06 ; $03
		
OBJLstHdrA_Daimon_JumpN3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_JumpN3 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $14 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $FA,$FB,$00 ; $00
	db $0A,$F6,$02 ; $01
	db $0A,$FE,$04 ; $02
	db $0F,$06,$06 ; $03
	db $1A,$F6,$08 ; $04
	db $1A,$FE,$0A ; $05
		
OBJLstHdrA_Daimon_ChargeMeter0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_ChargeMeter0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $28,$EB,$00 ; $00
	db $1E,$F3,$02 ; $01
	db $20,$FB,$04 ; $02
	db $20,$03,$06 ; $03
	db $27,$0B,$08 ; $04
	db $10,$FB,$0A ; $05
		
OBJLstHdrB_Daimon_ChargeMeter0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Daimon_ChargeMeter0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $32,$F5,$00 ; $00
	db $30,$FD,$02 ; $01
	db $30,$05,$04 ; $02
	db $3D,$0D,$06 ; $03
		
OBJLstHdrA_Daimon_ChargeMeter1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_ChargeMeter1_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $29,$EB,$00 ; $00
	db $1F,$F3,$02 ; $01
	db $20,$FB,$04 ; $02
	db $20,$03,$06 ; $03
	db $28,$0B,$08 ; $04
	db $10,$FB,$0A ; $05
		
OBJLstHdrA_Daimon_RunF0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_RunF0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $1A,$ED,$00 ; $00
	db $19,$F5,$02 ; $01
	db $1A,$FD,$04 ; $02
	db $1E,$05,$06 ; $03
	db $32,$ED,$08 ; $04
	db $29,$F5,$0A ; $05
	db $2A,$FD,$0C ; $06
	db $34,$05,$0E ; $07
	db $39,$F5,$10 ; $08
		
OBJLstHdrA_Daimon_RunF1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_RunF1_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $05 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $1E,$EB,$00 ; $00
	db $20,$F3,$02 ; $01
	db $20,$FB,$04 ; $02
	db $10,$F3,$06 ; $03
	db $10,$FB,$08 ; $04
		
OBJLstHdrA_Daimon_RunF2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_RunF2 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $1B,$EB,$00 ; $00
	db $19,$F3,$02 ; $01
	db $19,$FB,$04 ; $02
	db $1D,$03,$06 ; $03
	db $31,$EB,$08 ; $04
	db $29,$F3,$0A ; $05
	db $29,$FB,$0C ; $06
	db $33,$03,$0E ; $07
		
OBJLstHdrA_Daimon_RunF3_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_RunF3_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $06 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $1C,$EB,$00 ; $00
	db $20,$F3,$02 ; $01
	db $20,$FB,$04 ; $02
	db $10,$F3,$06 ; $03
	db $10,$FB,$08 ; $04
		
OBJLstHdrA_Daimon_Taunt0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_Taunt0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_CLoudTosser8.bin ; iOBJLstHdrA_DataPtr
	db $09 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_CLoudTosser8:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_Taunt0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $21,$EA,$00 ; $00
	db $20,$F2,$02 ; $01
	db $20,$FA,$04 ; $02
	db $31,$EC,$06 ; $03
	db $30,$F4,$08 ; $04
	db $30,$FC,$0A ; $05
		
OBJLstHdrA_Daimon_HopB1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_HopB1_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $10,$EA,$00 ; $00
	db $18,$F1,$02 ; $01
	db $18,$F9,$04 ; $02
	db $16,$01,$06 ; $03
	db $08,$F8,$08 ; $04
	db $06,$02,$0A ; $05
		
OBJLstHdrB_Daimon_HopB1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Daimon_HopB1_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $28,$F3,$00 ; $00
	db $28,$FB,$02 ; $01
	db $38,$F3,$04 ; $02
	db $38,$FD,$06 ; $03
	db $3D,$05,$08 ; $04
		
OBJLstHdrA_Daimon_Taunt3_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_Taunt3_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $05 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $10,$E7,$00 ; $00
	db $18,$EE,$02 ; $01
	db $18,$F6,$04 ; $02
	db $16,$FE,$06 ; $03
	db $08,$F5,$08 ; $04
	db $06,$FF,$0A ; $05
		
OBJLstHdrA_Daimon_WinA2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_WinA2_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $09 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $0D,$E7,$00 ; $00
	db $18,$EF,$02 ; $01
	db $0D,$F7,$04 ; $02
	db $1D,$F7,$06 ; $03
	db $1D,$FF,$08 ; $04
	db $08,$EF,$0A ; $05
		
OBJLstHdrA_Daimon_WinB0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_WinB0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $05 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $18,$EB,$00 ; $00
	db $18,$F3,$02 ; $01
		
OBJLstHdrB_Daimon_WinB0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Daimon_WinB0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $05 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $10,$F5,$00 ; $00
	db $1F,$FB,$02 ; $01
	db $28,$F3,$04 ; $02
	db $30,$EB,$06 ; $03
	db $38,$F3,$08 ; $04
	db $2F,$FB,$0A ; $05
	db $3A,$01,$0C ; $06
		
OBJLstHdrA_Daimon_WinB1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_WinB1_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $05 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $1A,$EB,$00 ; $00
	db $10,$F3,$02 ; $01
	db $20,$F3,$04 ; $02
		
OBJLstHdrA_Daimon_WinB2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_WinB2_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $05 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $1B,$EB,$00 ; $00
	db $10,$F3,$02 ; $01
	db $20,$F3,$04 ; $02
		
OBJLstHdrA_Daimon_PunchL1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_PunchL1_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_CHouOosotoGariL3_A.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_CHouOosotoGariL3_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_PunchL1_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1F,$ED,$00 ; $00
	db $20,$F5,$02 ; $01
	db $20,$FD,$04 ; $02
	db $1D,$05,$06 ; $03
	db $10,$F5,$08 ; $04
	db $10,$FD,$0A ; $05
		
OBJLstHdrA_Daimon_PunchH0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_PunchH0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_HeavenDropL5_A.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_CLoudTosser4_A:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_PunchH0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_HeavenDropL5_A.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_AttackA0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_PunchH0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_HeavenDropL5_A.bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $05 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_HeavenDropL5_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_PunchH0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $18,$FC,$00 ; $00
	db $18,$04,$02 ; $01
	db $0C,$0B,$04 ; $02
		
OBJLstHdrB_Daimon_PunchH0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Daimon_PunchH0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_Daimon_CLoudTosser4_B.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Daimon_CLoudTosser4_B:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	dpr GFX_Char_Daimon_PunchH0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $28,$FC,$00 ; $00
	db $28,$04,$02 ; $01
	db $34,$F8,$04 ; $02
	db $38,$04,$06 ; $03
		
OBJLstHdrA_Daimon_PunchH1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_PunchH1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $20,$EB,$00 ; $00
	db $26,$F3,$02 ; $01
	db $19,$FA,$04 ; $02
	db $21,$02,$06 ; $03
	db $18,$0A,$08 ; $04
	db $36,$F4,$0A ; $05
	db $29,$FB,$0C ; $06
	db $31,$03,$0E ; $07
		
OBJLstHdrA_Daimon_KickL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_4E ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_KickL1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $19,$EC,$00 ; $00
	db $1B,$F4,$02 ; $01
	db $1E,$FC,$04 ; $02
	db $2B,$F4,$06 ; $03
	db $31,$E4,$08 ; $04
	db $29,$EC,$0A ; $05
	db $3B,$F4,$0C ; $06
	db $38,$DC,$0E ; $07
		
OBJLstHdrA_Daimon_KickL0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_KickL0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1B,$F4,$00 ; $00
	db $1B,$FC,$02 ; $01
	db $23,$04,$04 ; $02
	db $2B,$F4,$06 ; $03
	db $2B,$FC,$08 ; $04
	db $3B,$F4,$0A ; $05
	db $3B,$FC,$0C ; $06
		
OBJLstHdrA_Daimon_KickH1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_4F ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_KickH1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $1B,$E3,$00 ; $00
	db $11,$EB,$02 ; $01
	db $1B,$F3,$04 ; $02
	db $1B,$FB,$06 ; $03
	db $24,$EB,$08 ; $04
	db $2B,$F3,$0A ; $05
	db $2B,$FB,$0C ; $06
	db $28,$03,$0E ; $07
	db $3B,$F3,$10 ; $08
		
OBJLstHdrA_Daimon_KickH2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_KickH2 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $22,$E2,$00 ; $00
	db $22,$EA,$02 ; $01
	db $22,$F2,$04 ; $02
	db $22,$FA,$06 ; $03
	db $32,$E8,$08 ; $04
	db $32,$F2,$0A ; $05
	db $12,$F0,$0C ; $06
	db $12,$F8,$0E ; $07
		
OBJLstHdrA_Daimon_PunchCL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_PunchCL1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $21,$EC,$00 ; $00
	db $22,$F4,$02 ; $01
	db $23,$FC,$04 ; $02
	db $28,$04,$06 ; $03
	db $33,$F4,$08 ; $04
	db $33,$FC,$0A ; $05
	db $38,$04,$0C ; $06
		
OBJLstHdrA_Daimon_PunchCL0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_PunchCL0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $20,$FB,$00 ; $00
	db $25,$03,$02 ; $01
	db $30,$FB,$04 ; $02
	db $35,$03,$06 ; $03
	db $38,$F3,$08 ; $04
	db $18,$F3,$0A ; $05
		
OBJLstHdrB_Daimon_PunchCL0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Daimon_PunchCL0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $28,$F3,$00 ; $00
	db $28,$EB,$02 ; $01
		
OBJLstHdrA_Daimon_PunchCH2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_PunchCH2 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FF ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1D,$EB,$00 ; $00
	db $25,$F3,$02 ; $01
	db $26,$FB,$04 ; $02
	db $2D,$EB,$06 ; $03
	db $35,$F3,$08 ; $04
	db $36,$FB,$0A ; $05
	db $38,$03,$0C ; $06
		
OBJLstHdrA_Daimon_PunchCH1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_50 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_PunchCH1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $28,$E3,$00 ; $00
	db $28,$EB,$02 ; $01
	db $28,$F3,$04 ; $02
	db $35,$FB,$06 ; $03
	db $3A,$03,$08 ; $04
	db $38,$EB,$0A ; $05
	db $38,$F3,$0C ; $06
	db $18,$E3,$0E ; $07
		
OBJLstHdrB_Daimon_PunchCH0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Daimon_PunchCH0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $28,$F3,$00 ; $00
	db $28,$EB,$02 ; $01
		
OBJLstHdrA_Daimon_KickCL1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_4C ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_KickCL1_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $28,$F3,$00 ; $00
	db $20,$F6,$02 ; $01
	db $20,$FE,$04 ; $02
	db $29,$06,$06 ; $03
	db $30,$03,$08 ; $04
		
OBJLstHdrB_Daimon_KickCL1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Daimon_KickCL1_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $39,$EB,$00 ; $00
	db $38,$F3,$02 ; $01
	db $30,$FB,$04 ; $02
		
OBJLstHdrA_Daimon_KickCL0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_KickCL0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_KickA0.bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_KickA0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_KickCL0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $FA ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $22,$F3,$00 ; $00
	db $32,$F3,$02 ; $01
	db $22,$FB,$04 ; $02
	db $32,$FB,$06 ; $03
	db $25,$03,$08 ; $04
	db $35,$03,$0A ; $05
		
OBJLstHdrA_Daimon_KickCH1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_4C ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_KickCH1_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $18,$F4,$00 ; $00
	db $28,$F3,$02 ; $01
	db $20,$FB,$04 ; $02
	db $20,$03,$06 ; $03
	db $30,$03,$08 ; $04
	db $2C,$0B,$0A ; $05
		
OBJLstHdrA_Daimon_KickCH3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_KickCH3 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_HeavenHellDropS5.bin ; iOBJLstHdrA_DataPtr
	db $FD ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_HeavenDropL4:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_KickCH3 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_HeavenHellDropS5.bin ; iOBJLstHdrA_DataPtr
	db $FF ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_HeavenHellDropS5:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_KickCH3 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $28,$F3,$00 ; $00
	db $38,$F3,$02 ; $01
	db $20,$FB,$04 ; $02
	db $20,$03,$06 ; $03
	db $28,$0B,$08 ; $04
	db $30,$FB,$0A ; $05
	db $30,$03,$0C ; $06
		
OBJLstHdrB_Daimon_PunchA0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Daimon_PunchA0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $06 ; iOBJLstHdrA_XOffset
	db $14 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $18,$F6,$00 ; $00
	db $18,$FE,$02 ; $01
	db $1F,$06,$04 ; $02
		
OBJLstHdrA_Daimon_PunchA1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_PunchA1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $07 ; iOBJLstHdrA_XOffset
	db $19 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $19,$E3,$00 ; $00
	db $13,$EB,$02 ; $01
	db $08,$F3,$04 ; $02
	db $0C,$FB,$06 ; $03
	db $0A,$03,$08 ; $04
	db $23,$EB,$0A ; $05
	db $18,$F3,$0C ; $06
		
OBJLstHdrA_Daimon_KickA1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_KickA1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $05 ; iOBJLstHdrA_XOffset
	db $17 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1F,$E4,$00 ; $00
	db $16,$EC,$02 ; $01
	db $08,$F4,$04 ; $02
	db $08,$FC,$06 ; $03
	db $06,$04,$08 ; $04
	db $18,$F4,$0A ; $05
	db $18,$FC,$0C ; $06
		
OBJLstHdrA_Daimon_AttackG1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_51 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_AttackG1_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_AttackA1_A.bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_AttackA1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_AttackG1_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $06 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $20,$E3,$00 ; $00
	db $18,$EB,$02 ; $01
	db $20,$F3,$04 ; $02
	db $1D,$FB,$06 ; $03
	db $2D,$FB,$08 ; $04
	db $37,$03,$0A ; $05
	db $10,$F3,$0C ; $06
		
OBJLstHdrB_Daimon_AttackG1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Daimon_AttackG1_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $28,$EB,$00 ; $00
	db $30,$F3,$02 ; $01
	db $38,$EB,$04 ; $02
		
OBJLstHdrB_Daimon_AttackA1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Daimon_AttackA1_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $06 ; iOBJLstHdrA_XOffset
	db $10 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $18,$EB,$00 ; $00
	db $20,$F3,$02 ; $01
		
OBJLstHdrA_Daimon_RollF1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_RollF1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $3D,$F5,$00 ; $00
	db $35,$FD,$02 ; $01
	db $2D,$F5,$04 ; $02
	db $25,$FD,$06 ; $03
	db $1E,$05,$08 ; $04
	db $2E,$05,$0A ; $05
		
OBJLstHdrA_Daimon_RollF2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_RollF2 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $07 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $28,$E7,$00 ; $00
	db $29,$EF,$02 ; $01
	db $2C,$F7,$04 ; $02
	db $2F,$FF,$06 ; $03
	db $39,$EF,$08 ; $04
	db $3C,$F7,$0A ; $05
		
OBJLstHdrA_Daimon_ThrowG2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_ThrowG2 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $0D ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $18,$EB,$00 ; $00
	db $18,$F3,$02 ; $01
	db $20,$FB,$04 ; $02
	db $28,$EB,$06 ; $03
	db $28,$F3,$08 ; $04
	db $37,$E3,$0A ; $05
	db $38,$EB,$0C ; $06
	db $38,$F3,$0E ; $07
		
OBJLstHdrA_Daimon_HopB0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_HopB0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $23,$E8,$00 ; $00
	db $1B,$F0,$02 ; $01
	db $1C,$F8,$04 ; $02
	db $1C,$00,$06 ; $03
	db $33,$F2,$08 ; $04
	db $2C,$F8,$0A ; $05
	db $2C,$00,$0C ; $06
	db $3C,$00,$0E ; $07
		
OBJLstHdrA_Daimon_ThrowEndA3:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_HopB0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_HopB0.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_HitSwoopup2:
	db OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_HopB0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_HopB0.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_HitSwoopup1:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_HopB0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_HopB0.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_GuardBreakG0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_GuardBreakG0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $18,$F3,$00 ; $00
	db $18,$FB,$02 ; $01
	db $18,$03,$04 ; $02
	db $10,$0B,$06 ; $03
	db $20,$0B,$08 ; $04
		
OBJLstHdrA_Daimon_Hitlow0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_GuardBreakG0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_GuardBreakG0_A.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Daimon_GuardBreakG0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Daimon_GuardBreakG0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $28,$F3,$00 ; $00
	db $28,$FB,$02 ; $01
	db $28,$03,$04 ; $02
	db $38,$03,$06 ; $03
	db $38,$F6,$08 ; $04
		
OBJLstHdrB_Daimon_Hitlow0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Daimon_Hitlow0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$F4,$00 ; $00
	db $30,$FC,$02 ; $01
	db $30,$04,$04 ; $02
		
OBJLstHdrA_Daimon_DropMain1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_DropMain1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FF ; iOBJLstHdrA_XOffset
	db $21 ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $17,$EE,$00 ; $00
	db $13,$F6,$02 ; $01
	db $12,$FE,$04 ; $02
	db $07,$06,$06 ; $03
	db $03,$0E,$08 ; $04
	db $0E,$16,$0A ; $05
	db $17,$06,$0C ; $06
	db $13,$0E,$0E ; $07
	db $23,$F6,$10 ; $08
		
OBJLstHdrA_Daimon_ThrowRotL0:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_DropMain1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_DropMain1.bin ; iOBJLstHdrA_DataPtr
	db $05 ; iOBJLstHdrA_XOffset
	db $F2 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_DropMain2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_DropMain2 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $04 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $31,$EB,$00 ; $00
	db $33,$F3,$02 ; $01
	db $32,$FB,$04 ; $02
	db $32,$03,$06 ; $03
	db $31,$0B,$08 ; $04
	db $33,$13,$0A ; $05
		
OBJLstHdrA_Daimon_JiraiShin1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_JiraiShin1_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $08,$F4,$00 ; $00
	db $08,$FC,$02 ; $01
	db $11,$EC,$04 ; $02
	db $18,$F4,$06 ; $03
	db $18,$FC,$08 ; $04
		
OBJLstHdrA_Daimon_JiraiShin2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_0F ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_JiraiShin2 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $06 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $28,$EB,$00 ; $00
	db $28,$F3,$02 ; $01
	db $28,$FB,$04 ; $02
	db $38,$EB,$06 ; $03
	db $38,$F3,$08 ; $04
	db $38,$FB,$0A ; $05
	db $36,$03,$0C ; $06
		
OBJLstHdrA_Daimon_CHouUkemiL0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_CHouUkemiL0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $0B ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $0A ; OBJ Count
	;    Y   X  ID
	db $21,$E1,$00 ; $00
	db $11,$E4,$02 ; $01
	db $11,$EC,$04 ; $02
	db $21,$E9,$06 ; $03
	db $23,$F1,$08 ; $04
	db $23,$F9,$0A ; $05
	db $31,$E7,$0C ; $06
	db $33,$F6,$0E ; $07
	db $37,$FB,$10 ; $08
	db $28,$01,$12 ; $09
		
OBJLstHdrA_Daimon_CHouUkemiL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_CHouUkemiL1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $0B ; iOBJLstHdrA_XOffset
	db $01 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1F,$E5,$00 ; $00
	db $1F,$ED,$02 ; $01
	db $25,$F5,$04 ; $02
	db $2F,$E5,$06 ; $03
	db $2F,$ED,$08 ; $04
	db $35,$F5,$0A ; $05
	db $1E,$FD,$0C ; $06
		
OBJLstHdrA_Daimon_CHouUkemiL2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_CHouUkemiL2 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $0B ; iOBJLstHdrA_XOffset
	db $01 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $19,$E8,$00 ; $00
	db $20,$F0,$02 ; $01
	db $27,$F8,$04 ; $02
	db $30,$E0,$06 ; $03
	db $2F,$E8,$08 ; $04
	db $30,$F0,$0A ; $05
	db $37,$F8,$0C ; $06
	db $30,$00,$0E ; $07
		
OBJLstHdrA_Daimon_CHouOosotoGariL4_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_CHouOosotoGariL4_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $1B,$03,$00 ; $00
	db $1A,$0B,$02 ; $01
	db $2B,$03,$04 ; $02
	db $3B,$07,$06 ; $03
		
OBJLstHdrB_Daimon_CHouOosotoGariL4_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Daimon_CHouOosotoGariL4_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $1C,$FB,$00 ; $00
	db $2C,$FB,$02 ; $01
	db $23,$F3,$04 ; $02
	db $33,$F3,$06 ; $03
		
OBJLstHdrB_Daimon_CHouOosotoGariL5_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Daimon_CHouOosotoGariL5_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $1C,$FB,$00 ; $00
	db $2C,$FB,$02 ; $01
	db $1E,$F3,$04 ; $02
		
OBJLstHdrA_Daimon_CHouOosotoGariL6:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_CHouOosotoGariL6 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $10,$FA,$00 ; $00
	db $2B,$F4,$02 ; $01
	db $20,$FC,$04 ; $02
	db $27,$04,$06 ; $03
	db $3B,$F4,$08 ; $04
	db $30,$FC,$0A ; $05
	db $37,$04,$0C ; $06
		
OBJLstHdrA_Daimon_CHouOosotoGariL7:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_CHouOosotoGariL7 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_HeavenHellDropS4.bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_HeavenHellDropS4:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_CHouOosotoGariL7 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $2D,$EC,$00 ; $00
	db $19,$F4,$02 ; $01
	db $18,$FC,$04 ; $02
	db $26,$04,$06 ; $03
	db $29,$F4,$08 ; $04
	db $28,$FC,$0A ; $05
	db $36,$04,$0C ; $06
		
OBJLstHdrA_Daimon_CLoudTosser1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_23 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_CLoudTosser1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $08 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $0E,$E6,$00 ; $00
	db $16,$ED,$02 ; $01
	db $16,$F5,$04 ; $02
	db $26,$EF,$06 ; $03
	db $21,$F7,$08 ; $04
	db $1E,$FF,$0A ; $05
	db $35,$E7,$0C ; $06
	db $36,$EF,$0E ; $07
	db $31,$F7,$10 ; $08
		
OBJLstHdrA_Daimon_CLoudTosser5:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_CLoudTosser5 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_HeavenDropL6.bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_HeavenDropL6:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_CLoudTosser5 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $1D,$EB,$00 ; $00
	db $19,$F3,$02 ; $01
	db $17,$FB,$04 ; $02
	db $16,$03,$06 ; $03
	db $29,$F3,$08 ; $04
	db $27,$FB,$0A ; $05
	db $2F,$03,$0C ; $06
	db $38,$EB,$0E ; $07
	db $39,$F3,$10 ; $08
		
OBJLstHdrA_Daimon_CLoudTosser6:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_CLoudTosser6 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_HeavenDropL7.bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_HeavenDropL7:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_CLoudTosser6 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $35,$F2,$00 ; $00
	db $2B,$FA,$02 ; $01
	db $28,$02,$04 ; $02
	db $1D,$0A,$06 ; $03
	db $38,$02,$08 ; $04
	db $2D,$0A,$0A ; $05
	db $2A,$12,$0C ; $06
		
OBJLstHdrA_Daimon_CLoudTosser2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_CLoudTosser2 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_CLoudTosser7.bin ; iOBJLstHdrA_DataPtr
	db $07 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_CLoudTosser7:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_CLoudTosser2 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1E,$ED,$00 ; $00
	db $1D,$F5,$02 ; $01
	db $27,$FD,$04 ; $02
	db $31,$ED,$06 ; $03
	db $2D,$F5,$08 ; $04
	db $37,$FD,$0A ; $05
	db $3B,$05,$0C ; $06
		
OBJLstHdrA_Daimon_StumpThrow0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_StumpThrow0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $0E ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $11,$E3,$00 ; $00
	db $11,$EB,$02 ; $01
	db $21,$E5,$04 ; $02
	db $21,$ED,$06 ; $03
	db $31,$E3,$08 ; $04
	db $31,$EB,$0A ; $05
	db $31,$F3,$0C ; $06
	db $37,$FB,$0E ; $07
		
OBJLstHdrA_Daimon_StumpThrow1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_24 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_StumpThrow1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $0C ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $22,$E3,$00 ; $00
	db $22,$EB,$02 ; $01
	db $1B,$F3,$04 ; $02
	db $2E,$DB,$06 ; $03
	db $32,$E3,$08 ; $04
	db $32,$EB,$0A ; $05
	db $2D,$F3,$0C ; $06
	db $37,$FB,$0E ; $07
		
OBJLstHdrA_Daimon_HeavenDropL0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_HeavenDropL0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $1C,$E9,$00 ; $00
	db $20,$F1,$02 ; $01
	db $18,$F9,$04 ; $02
	db $20,$01,$06 ; $03
	db $31,$F1,$08 ; $04
	db $28,$F9,$0A ; $05
	db $30,$01,$0C ; $06
	db $3D,$E9,$0E ; $07
		
OBJLstHdrA_Daimon_HeavenDropL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_HeavenDropL1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $19,$F3,$00 ; $00
	db $0A,$FB,$02 ; $01
	db $18,$03,$04 ; $02
	db $29,$F3,$06 ; $03
	db $1A,$FB,$08 ; $04
	db $2C,$03,$0A ; $05
	db $39,$F3,$0C ; $06
	db $2A,$FB,$0E ; $07
	db $3C,$03,$10 ; $08
		
OBJLstHdrA_Daimon_HeavenDropL3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Daimon_HeavenDropL3 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $27,$F6,$00 ; $00
	db $27,$FE,$02 ; $01
	db $1F,$06,$04 ; $02
	db $27,$0E,$06 ; $03
	db $37,$F6,$08 ; $04
	db $37,$FE,$0A ; $05
	db $2F,$06,$0C ; $06
	db $3A,$0E,$0E ; $07