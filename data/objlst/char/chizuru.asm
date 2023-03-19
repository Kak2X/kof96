OBJLstPtrTable_Chizuru_Idle:
	dw OBJLstHdrA_Chizuru_Idle0_A, OBJLstHdrB_Chizuru_Idle0_B
	dw OBJLstHdrA_Chizuru_Idle1_A, OBJLstHdrB_Chizuru_Idle0_B
	dw OBJLstHdrA_Chizuru_Idle2_A, OBJLstHdrB_Chizuru_Idle0_B
	dw OBJLstHdrA_Chizuru_Idle1_A, OBJLstHdrB_Chizuru_Idle0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_WalkF:
	dw OBJLstHdrA_Chizuru_WalkF0_A, OBJLstHdrB_Chizuru_WalkF0_B
	dw OBJLstHdrA_Chizuru_WalkF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_WalkF2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_WalkB:
	dw OBJLstHdrA_Chizuru_WalkF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_WalkF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_WalkF0_A, OBJLstHdrB_Chizuru_WalkF0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_Crouch:
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_JumpN:
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_JumpN1_A, OBJLstHdrB_Chizuru_JumpN1_B
	dw OBJLstHdrA_Chizuru_JumpN1_A, OBJLstHdrB_Chizuru_JumpN2_B
	dw OBJLstHdrA_Chizuru_JumpN1_A, OBJLstHdrB_Chizuru_JumpN2_B
	dw OBJLstHdrA_Chizuru_JumpN1_A, OBJLstHdrB_Chizuru_JumpN2_B
	dw OBJLstHdrA_Chizuru_JumpN1_A, OBJLstHdrB_Chizuru_JumpN2_B
	dw OBJLstHdrA_Chizuru_JumpN1_A, OBJLstHdrB_Chizuru_JumpN1_B
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_JumpF:
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Chizuru_JumpN1_A, OBJLstHdrB_Chizuru_JumpN1_B
	dw OBJLstHdrA_Chizuru_JumpF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_JumpF3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_JumpF4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_JumpF5, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_JumpN1_A, OBJLstHdrB_Chizuru_JumpN1_B
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_JumpB:
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Chizuru_JumpN1_A, OBJLstHdrB_Chizuru_JumpN1_B
	dw OBJLstHdrA_Chizuru_JumpF5, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_JumpF4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_JumpF3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_JumpF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_JumpN1_A, OBJLstHdrB_Chizuru_JumpN1_B
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_BlockG:
	dw OBJLstHdrA_Chizuru_BlockG0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_BlockC:
	dw OBJLstHdrA_Chizuru_BlockC0_A, OBJLstHdrB_Chizuru_BlockC0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_BlockA:
	dw OBJLstHdrA_Chizuru_BlockA0_A, OBJLstHdrB_Chizuru_BlockA0_B ;X
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_GuardBreakG:
	dw OBJLstHdrA_Chizuru_GuardBreakG0_A, OBJLstHdrB_Chizuru_GuardBreakG0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_Dizzy:
	dw OBJLstHdrA_Chizuru_Idle0_A, OBJLstHdrB_Chizuru_Idle0_B
	dw OBJLstHdrA_Chizuru_GuardBreakG0_A, OBJLstHdrB_Chizuru_GuardBreakG0_B
OBJLstPtrTable_Chizuru_Hit1mid:
	dw OBJLstHdrA_Chizuru_Hit1mid2_A, OBJLstHdrB_Chizuru_GuardBreakG0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_Hitlow:
	dw OBJLstHdrA_Chizuru_Hitlow0, OBJLSTPTR_NONE ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_GuardBreakA:
	dw OBJLstHdrA_Chizuru_GuardBreakG0_A, OBJLstHdrB_Chizuru_GuardBreakG0_B ;X
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_BackjumpRecA:
	dw OBJLstHdrA_Chizuru_GuardBreakG0_A, OBJLstHdrB_Chizuru_GuardBreakG0_B
	dw OBJLstHdrA_Chizuru_JumpF5, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_JumpF4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_JumpF3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_JumpF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_JumpN1_A, OBJLstHdrB_Chizuru_JumpN1_B
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_DropMain:
	dw OBJLstHdrA_Chizuru_GuardBreakG0_A, OBJLstHdrB_Chizuru_GuardBreakG0_B
	dw OBJLstHdrA_Chizuru_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_DropMain2, OBJLSTPTR_NONE
OBJLstPtrTable_Chizuru_HitMultigs:
	dw OBJLstHdrA_Chizuru_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_DropMain2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_HitSwoopup:
	dw OBJLstHdrA_Chizuru_Hit1mid2_A, OBJLstHdrB_Chizuru_GuardBreakG0_B
	dw OBJLstHdrA_Chizuru_HitSwoopup1_A, OBJLstHdrB_Chizuru_HitSwoopup1_B
	dw OBJLstHdrA_Chizuru_HitSwoopup2_A, OBJLstHdrB_Chizuru_HitSwoopup2_B
OBJLstPtrTable_Chizuru_ThrowEndA:
	dw OBJLstHdrA_Chizuru_ThrowEndA3_A, OBJLstHdrB_Chizuru_ThrowEndA3_B
	dw OBJLstHdrA_Chizuru_ThrowEndA3_A, OBJLstHdrB_Chizuru_ThrowEndA3_B
	dw OBJLstHdrA_Chizuru_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_DropMain2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_DropDbg:
	dw OBJLstHdrA_Chizuru_Hit1mid2_A, OBJLstHdrB_Chizuru_GuardBreakG0_B
	dw OBJLstHdrA_Chizuru_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_DropMain2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_ThrowRotL:
	dw OBJLstHdrA_Chizuru_ThrowRotL0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_Wakeup:
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_PunchL:
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_PunchL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_PunchL2_A, OBJLstHdrB_Chizuru_PunchL2_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_PunchH:
	dw OBJLstHdrA_Chizuru_PunchH0_A, OBJLstHdrB_Chizuru_PunchH0_B
	dw OBJLstHdrA_Chizuru_PunchH1_A, OBJLstHdrB_Chizuru_PunchH0_B
	dw OBJLstHdrA_Chizuru_PunchH1_A, OBJLstHdrB_Chizuru_PunchH0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_KickL:
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_KickL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_KickH:
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_KickH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kagura_KickH:
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kagura_KickH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_PunchCL:
	dw OBJLstHdrA_Chizuru_PunchCL0_A, OBJLstHdrB_Chizuru_PunchCL0_B
	dw OBJLstHdrA_Chizuru_PunchCL1_A, OBJLstHdrB_Chizuru_PunchCL0_B
	dw OBJLstHdrA_Chizuru_PunchCL0_A, OBJLstHdrB_Chizuru_PunchCL0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_PunchCH:
	dw OBJLstHdrA_Chizuru_PunchL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_PunchL2_A, OBJLstHdrB_Chizuru_PunchL2_B
	dw OBJLstHdrA_Chizuru_PunchL1, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_KickCL:
	dw OBJLstHdrA_Chizuru_KickCL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_KickCL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_KickCL0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_KickCH:
	dw OBJLstHdrA_Chizuru_KickCL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_KickCL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_KickCH2_A, OBJLstHdrB_Chizuru_KickCH2_B
	dw OBJLstHdrA_Chizuru_KickCL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_KickCL0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_PunchA:
	dw OBJLstHdrA_Chizuru_PunchA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_PunchA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_JumpN1_A, OBJLstHdrB_Chizuru_JumpN2_B
	dw OBJLstHdrA_Chizuru_JumpN1_A, OBJLstHdrB_Chizuru_JumpN1_B ;X
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_KickA:
	dw OBJLstHdrA_Chizuru_KickA0_A, OBJLstHdrB_Chizuru_KickA0_B
	dw OBJLstHdrA_Chizuru_KickA0_A, OBJLstHdrB_Chizuru_KickA0_B
	dw OBJLstHdrA_Chizuru_JumpN1_A, OBJLstHdrB_Chizuru_JumpN2_B
	dw OBJLstHdrA_Chizuru_JumpN1_A, OBJLstHdrB_Chizuru_JumpN1_B ;X
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_AttackG:
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_AttackG1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_AttackG2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_AttackA:
	dw OBJLstHdrA_Chizuru_AttackA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_AttackA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_JumpN1_A, OBJLstHdrB_Chizuru_JumpN2_B
	dw OBJLstHdrA_Chizuru_JumpN1_A, OBJLstHdrB_Chizuru_JumpN1_B ;X
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_RollF:
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_JumpF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_JumpF3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_JumpF4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_RollB:
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_JumpF4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_JumpF3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_JumpF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_ChargeMeter:
	dw OBJLstHdrA_Chizuru_ChargeMeter0_A, OBJLstHdrB_Chizuru_ChargeMeter0_B
	dw OBJLstHdrA_Chizuru_ChargeMeter1_A, OBJLstHdrB_Chizuru_ChargeMeter0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_RunF:
	dw OBJLstHdrA_Chizuru_RunF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_RunF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_RunF2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_HopB:
	dw OBJLstHdrA_Chizuru_Hit1mid2_A, OBJLstHdrB_Chizuru_GuardBreakG0_B
	dw OBJLstHdrA_Chizuru_JumpN1_A, OBJLstHdrB_Chizuru_JumpN1_B
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_Taunt:
	dw OBJLstHdrA_Chizuru_Taunt0_A, OBJLstHdrB_Chizuru_Taunt0_B
	dw OBJLstHdrA_Chizuru_Taunt1_A, OBJLstHdrB_Chizuru_Taunt0_B
	dw OBJLstHdrA_Chizuru_Taunt2_A, OBJLstHdrB_Chizuru_Taunt0_B
	dw OBJLstHdrA_Chizuru_Taunt1_A, OBJLstHdrB_Chizuru_Taunt0_B
	dw OBJLstHdrA_Chizuru_Taunt2_A, OBJLstHdrB_Chizuru_Taunt0_B
	dw OBJLstHdrA_Chizuru_Taunt1_A, OBJLstHdrB_Chizuru_Taunt0_B
	dw OBJLstHdrA_Chizuru_Taunt2_A, OBJLstHdrB_Chizuru_Taunt0_B
	dw OBJLstHdrA_Chizuru_Taunt1_A, OBJLstHdrB_Chizuru_Taunt0_B
	dw OBJLstHdrA_Chizuru_Taunt8_A, OBJLstHdrB_Chizuru_Taunt8_B
	dw OBJLstHdrA_Chizuru_Taunt9_A, OBJLstHdrB_Chizuru_Taunt8_B
	dw OBJLstHdrA_Chizuru_Taunt10_A, OBJLstHdrB_Chizuru_Taunt8_B
	dw OBJLstHdrA_Chizuru_Taunt8_A, OBJLstHdrB_Chizuru_Taunt8_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_WinA:
	dw OBJLstHdrA_Chizuru_WinA0_A, OBJLstHdrB_Chizuru_WinA0_B
	dw OBJLstHdrA_Chizuru_WinA1_A, OBJLstHdrB_Chizuru_WinA0_B
	dw OBJLstHdrA_Chizuru_WinA2_A, OBJLstHdrB_Chizuru_WinA0_B
	dw OBJLstHdrA_Chizuru_WinA3_A, OBJLstHdrB_Chizuru_WinA0_B
	dw OBJLstHdrA_Chizuru_WinA4, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_WinB:
	dw OBJLstHdrA_Chizuru_WinB0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_WinB1, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kagura_WinB:
	dw OBJLstHdrA_Kagura_WinB0_A, OBJLstHdrB_Kagura_WinB0_B
	dw OBJLstHdrA_Kagura_WinB1_A, OBJLstHdrB_Kagura_WinB0_B
	dw OBJLstHdrA_Kagura_WinB2_A, OBJLstHdrB_Kagura_WinB0_B
	dw OBJLstHdrA_Kagura_WinB3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kagura_WinB4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kagura_WinB5, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_TimeOver:
	dw OBJLstHdrA_Chizuru_Hit1mid2_A, OBJLstHdrB_Chizuru_GuardBreakG0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_TenjinKotowariL:
	dw OBJLstHdrA_Chizuru_TenjinKotowariL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_TenjinKotowariL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_TenjinKotowariL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_TenjinKotowariL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_TenjinKotowariL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_TenjinKotowariL5, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_JumpN1_A, OBJLstHdrB_Chizuru_JumpN1_B
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_ShinsokuNorotiHighL:
	dw OBJLstHdrA_Chizuru_RunF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_RunF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_RunF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_PunchL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_PunchL2_A, OBJLstHdrB_Chizuru_PunchL2_B
	dw OBJLstHdrA_Chizuru_ShinsokuNorotiHighL5_A, OBJLstHdrB_Chizuru_PunchL2_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_ShinsokuNorotiLowL:
	dw OBJLstHdrA_Chizuru_RunF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_RunF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_RunF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_ShinsokuNorotiLowL3_A, OBJLstHdrB_Chizuru_ShinsokuNorotiLowL3_B
	dw OBJLstHdrA_Chizuru_ShinsokuNorotiLowL4_A, OBJLstHdrB_Chizuru_ShinsokuNorotiLowL3_B
	dw OBJLstHdrA_Chizuru_ShinsokuNorotiLowL4_A, OBJLstHdrB_Chizuru_ShinsokuNorotiLowL3_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_TenZuiL:
	dw OBJLstHdrA_Chizuru_TenZuiL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_TenZuiL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_TenZuiH:
	dw OBJLstHdrA_Chizuru_TenZuiH0_A, OBJLstHdrB_Chizuru_ShinsokuNorotiLowL3_B
	dw OBJLstHdrA_Chizuru_TenZuiH1_A, OBJLstHdrB_Chizuru_TenZuiH1_B
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_TamayuraShitsuneH:
	dw OBJLstHdrA_Chizuru_TamayuraShitsuneH0_A, OBJLstHdrB_Chizuru_WalkF0_B
	dw OBJLstHdrA_Chizuru_TamayuraShitsuneH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_TamayuraShitsuneH2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_TamayuraShitsuneH0_A, OBJLstHdrB_Chizuru_WalkF0_B
OBJLstPtrTable_Chizuru_TamayuraShitsuneL:
	dw OBJLstHdrA_Chizuru_ShinsokuNorotiHighL5_A, OBJLstHdrB_Chizuru_PunchL2_B
	dw OBJLstHdrA_Chizuru_TenZuiH0_A, OBJLstHdrB_Chizuru_ShinsokuNorotiLowL3_B
	dw OBJLstHdrA_Chizuru_TamayuraShitsuneL6_A, OBJLstHdrB_Chizuru_TenZuiH1_B
	dw OBJLstHdrA_Chizuru_TenZuiH1_A, OBJLstHdrB_Chizuru_TenZuiH1_B
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_SanRaiFuiJinS:
	dw OBJLstHdrA_Chizuru_TamayuraShitsuneH2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_SanRaiFuiJinS1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_SanRaiFuiJinS2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_SanRaiFuiJinS1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_SanRaiFuiJinS4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_ReigiIshizueS:
	dw OBJLstHdrA_Chizuru_Idle0_A, OBJLstHdrB_Chizuru_Idle0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Chizuru_ThrowG:
	dw OBJLstHdrA_Chizuru_ThrowG0_A, OBJLstHdrB_Chizuru_PunchL2_B
	dw OBJLstHdrA_Chizuru_ThrowG1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_ThrowG2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Chizuru_ThrowG0_A, OBJLstHdrB_Chizuru_PunchL2_B
	dw OBJLSTPTR_NONE
		
OBJLstHdrA_Chizuru_Idle0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_Idle0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$FB,$00 ; $00
	db $30,$FB,$02 ; $01
	db $21,$F3,$04 ; $02
	db $3E,$F3,$06 ; $03
		
OBJLstHdrB_Chizuru_Idle0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Chizuru_Idle0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $20,$03,$00 ; $00
	db $30,$03,$02 ; $01
		
OBJLstHdrA_Chizuru_Idle1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_Idle1_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$FB,$00 ; $00
	db $30,$FB,$02 ; $01
	db $22,$F3,$04 ; $02
	db $3E,$F3,$06 ; $03
		
OBJLstHdrA_Chizuru_Idle2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_Idle2_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$FB,$00 ; $00
	db $30,$FB,$02 ; $01
	db $23,$F3,$04 ; $02
	db $3E,$F3,$06 ; $03
		
OBJLstHdrA_Chizuru_WalkF0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_WalkF0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $21,$F0,$00 ; $00
	db $1F,$F8,$02 ; $01
	db $18,$00,$04 ; $02
	db $28,$FC,$06 ; $03
	db $28,$04,$08 ; $04
		
OBJLstHdrB_Chizuru_WalkF0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Chizuru_WalkF0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $38,$F7,$00 ; $00
	db $38,$FF,$02 ; $01
		
OBJLstHdrA_Chizuru_WalkF1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_WalkF1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $23,$F0,$00 ; $00
	db $20,$F8,$02 ; $01
	db $20,$00,$04 ; $02
	db $30,$FB,$06 ; $03
	db $2F,$03,$08 ; $04
	db $10,$FB,$0A ; $05
		
OBJLstHdrA_Chizuru_WalkF2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_WalkF2 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $20,$EF,$00 ; $00
	db $1F,$F7,$02 ; $01
	db $1F,$FF,$04 ; $02
	db $2F,$FB,$06 ; $03
	db $2F,$03,$08 ; $04
	db $3F,$FB,$0A ; $05
		
OBJLstHdrA_Chizuru_Crouch0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_Crouch0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Chizuru_ThrowG2.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Chizuru_ThrowG2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_Crouch0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $27,$FA,$00 ; $00
	db $27,$02,$02 ; $01
	db $37,$FA,$04 ; $02
	db $37,$02,$06 ; $03
	db $28,$F2,$08 ; $04
	db $3E,$F2,$0A ; $05
		
OBJLstHdrA_Chizuru_JumpN1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_JumpN1_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $18,$F3,$00 ; $00
	db $18,$FB,$02 ; $01
	db $18,$03,$04 ; $02
	db $18,$0B,$06 ; $03
		
OBJLstHdrB_Chizuru_JumpN1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Chizuru_JumpN1_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $28,$F6,$00 ; $00
	db $28,$FE,$02 ; $01
	db $28,$06,$04 ; $02
	db $38,$FE,$06 ; $03
		
OBJLstHdrB_Chizuru_JumpN2_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Chizuru_JumpN2_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $28,$F8,$00 ; $00
	db $28,$00,$02 ; $01
	db $28,$08,$04 ; $02
	db $38,$00,$06 ; $03
		
OBJLstHdrA_Chizuru_JumpF3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_JumpF3 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Chizuru_KickH1.bin ; iOBJLstHdrA_DataPtr
	db $08 ; iOBJLstHdrA_XOffset
	db $04 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Chizuru_JumpF5:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_JumpF3 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Chizuru_KickH1.bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $F6 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Chizuru_KickH1:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_JumpF3 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $F6 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $10,$F0,$00 ; $00
	db $20,$F3,$02 ; $01
	db $20,$FB,$04 ; $02
	db $28,$03,$06 ; $03
	db $30,$F3,$08 ; $04
	db $30,$FB,$0A ; $05
		
OBJLstHdrA_Chizuru_JumpF4:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_JumpF4 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Kagura_KickH1.bin ; iOBJLstHdrA_DataPtr
	db $06 ; iOBJLstHdrA_XOffset
	db $04 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Chizuru_JumpF2:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_JumpF4 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Kagura_KickH1.bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $F8 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Kagura_KickH1:
	db OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_14 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_JumpF4 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $F8 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $28,$E8,$00 ; $00
	db $28,$F0,$02 ; $01
	db $20,$F8,$04 ; $02
	db $28,$00,$06 ; $03
	db $10,$F8,$08 ; $04
	db $18,$00,$0A ; $05
	db $20,$08,$0C ; $06
		
OBJLstHdrA_Chizuru_BlockG0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_BlockG0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $20,$FC,$00 ; $00
	db $20,$04,$02 ; $01
	db $30,$FC,$04 ; $02
	db $30,$04,$06 ; $03
	db $3D,$F4,$08 ; $04
		
OBJLstHdrA_Chizuru_BlockC0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_BlockC0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Chizuru_BlockA0_A.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Chizuru_BlockA0_A: ;X
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_BlockC0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $F6 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $28,$FB,$00 ; $00
	db $28,$03,$02 ; $01
	db $18,$FE,$04 ; $02
		
OBJLstHdrB_Chizuru_BlockC0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Chizuru_BlockC0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_Chizuru_BlockA0_B.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Chizuru_BlockA0_B: ;X
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Chizuru_BlockC0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $F6 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $38,$FA,$00 ; $00
	db $38,$02,$02 ; $01
	db $3E,$F2,$04 ; $02
		
OBJLstHdrA_Chizuru_GuardBreakG0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_GuardBreakG0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FF ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$FA,$00 ; $00
	db $20,$02,$02 ; $01
	db $20,$0A,$04 ; $02
	db $19,$F2,$06 ; $03
		
OBJLstHdrB_Chizuru_GuardBreakG0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Chizuru_GuardBreakG0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FF ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $32,$F9,$00 ; $00
	db $30,$01,$02 ; $01
	db $30,$09,$04 ; $02
		
OBJLstHdrB_Chizuru_ThrowEndA3_B:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	dpr GFX_Char_Chizuru_GuardBreakG0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_Chizuru_GuardBreakG0_B.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $04 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Chizuru_HitSwoopup2_B:
	db OLF_YFLIP ; iOBJLstHdrA_Flags
	dpr GFX_Char_Chizuru_GuardBreakG0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_Chizuru_GuardBreakG0_B.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $04 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Chizuru_HitSwoopup1_B:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	dpr GFX_Char_Chizuru_GuardBreakG0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_Chizuru_GuardBreakG0_B.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Chizuru_Hit1mid2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_Hit1mid2_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FF ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$FB,$00 ; $00
	db $20,$03,$02 ; $01
	db $20,$0B,$04 ; $02
	db $20,$F3,$06 ; $03
		
OBJLstHdrA_Chizuru_ThrowEndA3_A:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_Hit1mid2_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Chizuru_Hit1mid2_A.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $04 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Chizuru_HitSwoopup2_A:
	db OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_Hit1mid2_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Chizuru_Hit1mid2_A.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $04 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Chizuru_HitSwoopup1_A:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_Hit1mid2_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Chizuru_Hit1mid2_A.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Chizuru_Hitlow0: ;X
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_Hitlow0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin: ;X
	db $05 ; OBJ Count
	;    Y   X  ID
	db $28,$FB,$00 ; $00
	db $28,$03,$02 ; $01
	db $38,$FB,$04 ; $02
	db $38,$03,$06 ; $03
	db $30,$F3,$08 ; $04
		
OBJLstHdrA_Chizuru_DropMain1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_DropMain1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $09 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $28,$F2,$00 ; $00
	db $28,$FA,$02 ; $01
	db $28,$02,$04 ; $02
	db $30,$0A,$06 ; $03
	db $38,$02,$08 ; $04
		
OBJLstHdrA_Chizuru_DropMain2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_DropMain2 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FD ; iOBJLstHdrA_XOffset
	db $03 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $32,$F3,$00 ; $00
	db $32,$FB,$02 ; $01
	db $32,$03,$04 ; $02
	db $32,$0B,$06 ; $03
		
OBJLstHdrA_Chizuru_ThrowRotL0:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_DropMain2 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Chizuru_DropMain2.bin ; iOBJLstHdrA_DataPtr
	db $05 ; iOBJLstHdrA_XOffset
	db $12 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Chizuru_PunchL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_PunchL1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Chizuru_ThrowG1.bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Chizuru_ThrowG1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_PunchL1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $23,$F3,$00 ; $00
	db $20,$FB,$02 ; $01
	db $1B,$03,$04 ; $02
	db $30,$FB,$06 ; $03
	db $2B,$03,$08 ; $04
	db $37,$0B,$0A ; $05
		
OBJLstHdrA_Chizuru_PunchL2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_PunchL2_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Chizuru_ThrowG0_A.bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Chizuru_ThrowG0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_PunchL2_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $17,$F8,$00 ; $00
	db $20,$04,$02 ; $01
	db $1B,$00,$04 ; $02
	db $19,$08,$06 ; $03
		
OBJLstHdrB_Chizuru_PunchL2_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Chizuru_PunchL2_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$01,$00 ; $00
	db $30,$09,$02 ; $01
	db $3B,$F9,$04 ; $02
		
OBJLstHdrA_Chizuru_PunchH0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_PunchH0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $20,$F3,$00 ; $00
	db $20,$FB,$02 ; $01
	db $20,$03,$04 ; $02
	db $20,$0B,$06 ; $03
	db $30,$0B,$08 ; $04
	db $10,$03,$0A ; $05
		
OBJLstHdrB_Chizuru_PunchH0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Chizuru_PunchH0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $30,$03,$00 ; $00
	db $3D,$FB,$02 ; $01
		
OBJLstHdrA_Chizuru_PunchH1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_PunchH1_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $18,$F3,$00 ; $00
	db $1A,$FB,$02 ; $01
	db $20,$03,$04 ; $02
	db $20,$0B,$06 ; $03
	db $30,$0B,$08 ; $04
	db $10,$03,$0A ; $05
		
OBJLstHdrA_Chizuru_KickL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_KickL1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $18,$F9,$00 ; $00
	db $18,$01,$02 ; $01
	db $20,$09,$04 ; $02
	db $20,$11,$06 ; $03
	db $30,$F1,$08 ; $04
	db $28,$F9,$0A ; $05
	db $28,$01,$0C ; $06
	db $30,$09,$0E ; $07
		
OBJLstHdrA_Chizuru_PunchCL0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_PunchCL0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $22,$F3,$00 ; $00
	db $2A,$FB,$02 ; $01
	db $3A,$FB,$04 ; $02
		
OBJLstHdrB_Chizuru_PunchCL0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Chizuru_PunchCL0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $27,$03,$00 ; $00
	db $2B,$0B,$02 ; $01
	db $37,$03,$04 ; $02
	db $3B,$0B,$06 ; $03
		
OBJLstHdrA_Chizuru_PunchCL1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_PunchCL1_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $29,$FB,$00 ; $00
	db $39,$FB,$02 ; $01
	db $25,$F3,$04 ; $02
		
OBJLstHdrA_Chizuru_KickCL0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_KickCL0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $27,$01,$00 ; $00
	db $27,$09,$02 ; $01
	db $37,$01,$04 ; $02
	db $37,$09,$06 ; $03
	db $2E,$F9,$08 ; $04
	db $3E,$F9,$0A ; $05
		
OBJLstHdrA_Chizuru_KickCL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_4C ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_KickCL1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $2B,$FB,$00 ; $00
	db $2A,$03,$02 ; $01
	db $2E,$0B,$04 ; $02
	db $3B,$FB,$06 ; $03
	db $3A,$03,$08 ; $04
	db $3E,$0B,$0A ; $05
	db $30,$F3,$0C ; $06
		
OBJLstHdrA_Chizuru_KickCH2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_5E ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_KickCH2_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Chizuru_KickA0_A.bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Chizuru_KickA0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_KickCH2_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $F5 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $20,$FE,$00 ; $00
	db $20,$06,$02 ; $01
	db $30,$FB,$04 ; $02
	db $3A,$F3,$06 ; $03
	db $3E,$EB,$08 ; $04
		
OBJLstHdrB_Chizuru_KickCH2_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Chizuru_KickCH2_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $30,$03,$00 ; $00
	db $35,$0B,$02 ; $01
		
OBJLstHdrA_Chizuru_PunchA0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_PunchA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $05 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $28,$E7,$00 ; $00
	db $20,$EF,$02 ; $01
	db $18,$F7,$04 ; $02
	db $16,$FF,$06 ; $03
	db $10,$07,$08 ; $04
	db $28,$F7,$0A ; $05
	db $26,$FF,$0C ; $06
	db $10,$EF,$0E ; $07
		
OBJLstHdrB_Chizuru_KickA0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Chizuru_KickA0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $05 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $20,$03,$00 ; $00
	db $26,$0B,$02 ; $01
		
OBJLstHdrA_Chizuru_AttackG1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_51 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_AttackG1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $18,$F4,$00 ; $00
	db $18,$FC,$02 ; $01
	db $2A,$E6,$04 ; $02
	db $2A,$EE,$06 ; $03
	db $28,$F6,$08 ; $04
	db $28,$FE,$0A ; $05
	db $18,$04,$0C ; $06
	db $38,$F6,$0E ; $07
		
OBJLstHdrA_Chizuru_AttackG2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_AttackG2 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $1B,$EF,$00 ; $00
	db $22,$F7,$02 ; $01
	db $23,$FF,$04 ; $02
	db $20,$07,$06 ; $03
	db $19,$E7,$08 ; $04
	db $32,$F7,$0A ; $05
	db $2F,$EF,$0C ; $06
	db $30,$E7,$0E ; $07
		
OBJLstHdrA_Chizuru_AttackA0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_AttackA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $04 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $2C,$EB,$00 ; $00
	db $28,$F3,$02 ; $01
	db $18,$FB,$04 ; $02
	db $28,$FB,$06 ; $03
	db $09,$03,$08 ; $04
	db $19,$03,$0A ; $05
	db $09,$0B,$0C ; $06
	db $19,$0B,$0E ; $07
		
OBJLstHdrA_Chizuru_ChargeMeter0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_ChargeMeter0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $28,$F3,$00 ; $00
	db $28,$FB,$02 ; $01
	db $28,$03,$04 ; $02
	db $18,$FE,$06 ; $03
	db $18,$F6,$08 ; $04
		
OBJLstHdrB_Chizuru_ChargeMeter0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Chizuru_ChargeMeter0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $38,$F8,$00 ; $00
	db $38,$00,$02 ; $01
		
OBJLstHdrA_Chizuru_ChargeMeter1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_ChargeMeter1_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $28,$F5,$00 ; $00
	db $28,$FD,$02 ; $01
	db $28,$05,$04 ; $02
	db $18,$F5,$06 ; $03
	db $18,$FD,$08 ; $04
		
OBJLstHdrA_Chizuru_RunF0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_RunF0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $1C,$F3,$00 ; $00
	db $1C,$FB,$02 ; $01
	db $14,$03,$04 ; $02
	db $14,$0B,$06 ; $03
	db $2C,$F3,$08 ; $04
	db $2C,$FB,$0A ; $05
	db $24,$03,$0C ; $06
	db $2C,$0B,$0E ; $07
		
OBJLstHdrA_Chizuru_RunF1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_RunF1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $1C,$F3,$00 ; $00
	db $1C,$FB,$02 ; $01
	db $1C,$03,$04 ; $02
	db $2C,$FB,$06 ; $03
	db $2C,$03,$08 ; $04
		
OBJLstHdrA_Chizuru_RunF2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_RunF2 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1B,$F7,$00 ; $00
	db $1B,$FF,$02 ; $01
	db $1B,$07,$04 ; $02
	db $2B,$FC,$06 ; $03
	db $2B,$04,$08 ; $04
	db $2D,$0C,$0A ; $05
		
OBJLstHdrA_Chizuru_Taunt0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_Taunt0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $28,$FB,$00 ; $00
	db $18,$FB,$02 ; $01
	db $15,$F3,$04 ; $02
	db $25,$F3,$06 ; $03
		
OBJLstHdrB_Chizuru_Taunt0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Chizuru_Taunt0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $20,$03,$00 ; $00
	db $30,$02,$02 ; $01
	db $38,$F7,$04 ; $02
		
OBJLstHdrA_Chizuru_Taunt1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_Taunt1_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $28,$FB,$00 ; $00
	db $18,$FB,$02 ; $01
	db $22,$F3,$04 ; $02
		
OBJLstHdrA_Chizuru_Taunt2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_Taunt2_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $18,$FB,$00 ; $00
	db $28,$FB,$02 ; $01
	db $22,$F3,$04 ; $02
		
OBJLstHdrA_Chizuru_Taunt8_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_Taunt8_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$F3,$00 ; $00
	db $20,$FB,$02 ; $01
	db $20,$03,$04 ; $02
	db $10,$FB,$06 ; $03
		
OBJLstHdrB_Chizuru_Taunt8_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Chizuru_Taunt8_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $30,$F8,$00 ; $00
	db $30,$00,$02 ; $01
		
OBJLstHdrA_Chizuru_Taunt9_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_Taunt9_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$F3,$00 ; $00
	db $20,$FB,$02 ; $01
	db $20,$03,$04 ; $02
	db $10,$FB,$06 ; $03
		
OBJLstHdrA_Chizuru_Taunt10_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_Taunt10_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$F3,$00 ; $00
	db $20,$FB,$02 ; $01
	db $20,$03,$04 ; $02
	db $10,$FB,$06 ; $03
		
OBJLstHdrA_Chizuru_WinA0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_WinA0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $20,$FC,$00 ; $00
	db $19,$F7,$02 ; $01
	db $1D,$FF,$04 ; $02
		
OBJLstHdrB_Chizuru_WinA0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Chizuru_WinA0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $30,$FE,$00 ; $00
	db $30,$F6,$02 ; $01
		
OBJLstHdrA_Chizuru_WinA1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_WinA1_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $20,$FC,$00 ; $00
	db $1F,$04,$02 ; $01
	db $12,$FA,$04 ; $02
		
OBJLstHdrA_Chizuru_WinA2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_WinA2_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$FC,$00 ; $00
	db $1F,$04,$02 ; $01
	db $10,$FD,$04 ; $02
	db $09,$05,$06 ; $03
		
OBJLstHdrA_Chizuru_WinA3_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_WinA3_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $20,$F9,$00 ; $00
	db $20,$01,$02 ; $01
	db $10,$FE,$04 ; $02
		
OBJLstHdrA_Chizuru_WinA4:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_WinA4 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $22,$02,$00 ; $00
	db $22,$FA,$02 ; $01
	db $32,$F6,$04 ; $02
	db $32,$FE,$06 ; $03
	db $12,$02,$08 ; $04
	db $1D,$F2,$0A ; $05
		
OBJLstHdrA_Chizuru_WinB0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_WinB0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F2 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $20,$06,$00 ; $00
	db $20,$0E,$02 ; $01
	db $30,$06,$04 ; $02
	db $30,$0E,$06 ; $03
	db $10,$0A,$08 ; $04
		
OBJLstHdrA_Chizuru_WinB1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_WinB1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F2 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$03,$00 ; $00
	db $25,$0B,$02 ; $01
	db $30,$07,$04 ; $02
	db $15,$0A,$06 ; $03
		
OBJLstHdrA_Kagura_WinB0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Kagura_WinB0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$03,$00 ; $00
	db $20,$0B,$02 ; $01
	db $20,$13,$04 ; $02
	db $10,$03,$06 ; $03
		
OBJLstHdrB_Kagura_WinB0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Kagura_WinB0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $22,$FB,$00 ; $00
	db $30,$03,$02 ; $01
	db $30,$0B,$04 ; $02
	db $1F,$F3,$06 ; $03
	db $3D,$FB,$08 ; $04
		
OBJLstHdrA_Kagura_WinB1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Kagura_WinB1_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$03,$00 ; $00
	db $20,$0B,$02 ; $01
	db $20,$13,$04 ; $02
	db $10,$03,$06 ; $03
		
OBJLstHdrA_Kagura_WinB2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Kagura_WinB2_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$03,$00 ; $00
	db $20,$0B,$02 ; $01
	db $20,$13,$04 ; $02
	db $10,$03,$06 ; $03
		
OBJLstHdrA_Kagura_WinB3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Kagura_WinB3 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $22,$FA,$00 ; $00
	db $1F,$02,$02 ; $01
	db $21,$0A,$04 ; $02
	db $24,$12,$06 ; $03
	db $2F,$02,$08 ; $04
	db $31,$0A,$0A ; $05
	db $3E,$FD,$0C ; $06
		
OBJLstHdrA_Kagura_WinB4:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Kagura_WinB4 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $1F,$FE,$00 ; $00
	db $1F,$06,$02 ; $01
	db $2F,$00,$04 ; $02
	db $2F,$08,$06 ; $03
	db $3F,$00,$08 ; $04
		
OBJLstHdrA_Kagura_WinB5:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Kagura_WinB5 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $14,$FE,$00 ; $00
	db $20,$04,$02 ; $01
	db $24,$FC,$04 ; $02
	db $30,$FF,$06 ; $03
	db $30,$07,$08 ; $04
		
OBJLstHdrA_Chizuru_TenjinKotowariL0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_TenjinKotowariL0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $23,$F5,$00 ; $00
	db $20,$FD,$02 ; $01
	db $1E,$00,$04 ; $02
	db $33,$F5,$06 ; $03
	db $30,$FD,$08 ; $04
	db $3A,$05,$0A ; $05
	db $2E,$ED,$0C ; $06
		
OBJLstHdrA_Chizuru_TenjinKotowariL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_49 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_TenjinKotowariL1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $06 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $19,$E9,$00 ; $00
	db $1B,$F1,$02 ; $01
	db $1C,$F9,$04 ; $02
	db $1E,$01,$06 ; $03
	db $2B,$F1,$08 ; $04
	db $2C,$F9,$0A ; $05
	db $3B,$F8,$0C ; $06
	db $10,$E1,$0E ; $07
		
OBJLstHdrA_Chizuru_TenjinKotowariL5:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_TenjinKotowariL5 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $08 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $13,$F1,$00 ; $00
	db $13,$F9,$02 ; $01
	db $0E,$01,$04 ; $02
	db $21,$E9,$06 ; $03
	db $23,$F1,$08 ; $04
	db $23,$F9,$0A ; $05
	db $33,$F3,$0C ; $06
		
OBJLstHdrA_Chizuru_ShinsokuNorotiHighL5_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_ShinsokuNorotiHighL5_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$03,$00 ; $00
	db $20,$0B,$02 ; $01
	db $18,$FB,$04 ; $02
	db $10,$02,$06 ; $03
		
OBJLstHdrA_Chizuru_ShinsokuNorotiLowL3_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_ShinsokuNorotiLowL3_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FD ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $28,$F0,$00 ; $00
	db $28,$F8,$02 ; $01
	db $28,$00,$04 ; $02
	db $23,$08,$06 ; $03
	db $24,$E8,$08 ; $04
	db $18,$F8,$0A ; $05
		
OBJLstHdrB_Chizuru_ShinsokuNorotiLowL3_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Chizuru_ShinsokuNorotiLowL3_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FD ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $3D,$F1,$00 ; $00
	db $38,$F9,$02 ; $01
	db $38,$01,$04 ; $02
	db $3A,$09,$06 ; $03
		
OBJLstHdrA_Chizuru_ShinsokuNorotiLowL4_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_ShinsokuNorotiLowL4_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FD ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $1F,$F5,$00 ; $00
	db $28,$F9,$02 ; $01
	db $28,$01,$04 ; $02
	db $22,$09,$06 ; $03
	db $18,$FF,$08 ; $04
		
OBJLstHdrA_Chizuru_TenZuiL0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_TenZuiL0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $05 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $17,$EB,$00 ; $00
	db $18,$F3,$02 ; $01
	db $18,$FB,$04 ; $02
	db $18,$03,$06 ; $03
	db $15,$0B,$08 ; $04
	db $28,$FB,$0A ; $05
	db $28,$03,$0C ; $06
		
OBJLstHdrA_Chizuru_TenZuiL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_TenZuiL1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $05 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $17,$FB,$00 ; $00
	db $14,$03,$02 ; $01
	db $18,$0B,$04 ; $02
	db $27,$FB,$06 ; $03
	db $24,$03,$08 ; $04
	db $34,$FE,$0A ; $05
		
OBJLstHdrA_Chizuru_TenZuiH0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_TenZuiH0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F5 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $28,$01,$00 ; $00
	db $28,$09,$02 ; $01
	db $23,$0E,$04 ; $02
	db $1E,$FF,$06 ; $03
	db $1C,$F7,$08 ; $04
		
OBJLstHdrA_Chizuru_TenZuiH1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_TenZuiH1_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F5 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $28,$FB,$00 ; $00
	db $38,$FB,$02 ; $01
	db $30,$F3,$04 ; $02
		
OBJLstHdrB_Chizuru_TenZuiH1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Chizuru_TenZuiH1_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F5 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $27,$03,$00 ; $00
	db $37,$03,$02 ; $01
	db $20,$0B,$04 ; $02
	db $30,$0B,$06 ; $03
	db $3C,$13,$08 ; $04
	db $1A,$13,$0A ; $05
		
OBJLstHdrA_Chizuru_TamayuraShitsuneL6_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_14 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_TamayuraShitsuneL6_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FD ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $2C,$EB,$00 ; $00
	db $1C,$EB,$02 ; $01
	db $14,$F3,$04 ; $02
	db $29,$F3,$06 ; $03
	db $26,$E3,$08 ; $04
	db $39,$F3,$0A ; $05
		
OBJLstHdrA_Chizuru_TamayuraShitsuneH0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_TamayuraShitsuneH0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $28,$F8,$00 ; $00
	db $28,$00,$02 ; $01
	db $25,$F0,$04 ; $02
	db $18,$F8,$06 ; $03
	db $18,$00,$08 ; $04
	db $18,$E8,$0A ; $05
	db $22,$08,$0C ; $06
		
OBJLstHdrA_Chizuru_TamayuraShitsuneH1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_TamayuraShitsuneH1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Chizuru_TamayuraShitsuneH2.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Chizuru_TamayuraShitsuneH2:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_TamayuraShitsuneH1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $18,$F3,$00 ; $00
	db $19,$FB,$02 ; $01
	db $21,$03,$04 ; $02
	db $29,$FB,$06 ; $03
	db $31,$03,$08 ; $04
	db $39,$FB,$0A ; $05
		
OBJLstHdrA_Chizuru_SanRaiFuiJinS1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_SanRaiFuiJinS1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FB ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $29,$F8,$00 ; $00
	db $27,$00,$02 ; $01
	db $29,$08,$04 ; $02
	db $20,$10,$06 ; $03
	db $3D,$F8,$08 ; $04
	db $37,$00,$0A ; $05
	db $39,$08,$0C ; $06
	db $3A,$10,$0E ; $07
	db $22,$F0,$10 ; $08
		
OBJLstHdrA_Chizuru_SanRaiFuiJinS2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_SanRaiFuiJinS2 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FB ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $27,$04,$00 ; $00
	db $27,$0C,$02 ; $01
	db $2B,$14,$04 ; $02
	db $24,$1C,$06 ; $03
	db $37,$04,$08 ; $04
	db $37,$0C,$0A ; $05
	db $3B,$14,$0C ; $06
	db $31,$FC,$0E ; $07
		
OBJLstHdrA_Chizuru_SanRaiFuiJinS4:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Chizuru_SanRaiFuiJinS4 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $27,$E6,$00 ; $00
	db $26,$EE,$02 ; $01
	db $25,$F6,$04 ; $02
	db $2C,$FD,$06 ; $03
	db $2D,$05,$08 ; $04
	db $35,$F5,$0A ; $05
	db $3B,$0B,$0C ; $06