
OBJLstPtrTable_Kyo_Idle:
	dw OBJLstHdrA_Kyo_Idle0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_Idle1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_Idle0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_Idle3, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_WalkF:
	dw OBJLstHdrA_Kyo_WalkF0_A, OBJLstHdrB_Kyo_WalkF0_B
	dw OBJLstHdrA_Kyo_WalkF0_A, OBJLstHdrB_Kyo_WalkF0_B
	dw OBJLstHdrA_Kyo_WalkF0_A, OBJLstHdrB_Kyo_WalkF0_B
	dw OBJLstHdrA_Kyo_WalkF0_A, OBJLstHdrB_Kyo_WalkF0_B
	dw OBJLstHdrA_Kyo_WalkF0_A, OBJLstHdrB_Kyo_WalkF4_B
	dw OBJLstHdrA_Kyo_Idle0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_WalkB:
	dw OBJLstHdrA_Kyo_Idle0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_WalkF0_A, OBJLstHdrB_Kyo_WalkF4_B
	dw OBJLstHdrA_Kyo_WalkF0_A, OBJLstHdrB_Kyo_WalkF4_B
	dw OBJLstHdrA_Kyo_WalkF0_A, OBJLstHdrB_Kyo_WalkF4_B
	dw OBJLstHdrA_Kyo_WalkF0_A, OBJLstHdrB_Kyo_WalkF4_B
	dw OBJLstHdrA_Kyo_WalkF0_A, OBJLstHdrB_Kyo_WalkF0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_Crouch:
	dw OBJLstHdrA_Kyo_Crouch0_A, OBJLstHdrB_Kyo_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_JumpN:
	dw OBJLstHdrA_Kyo_Crouch0_A, OBJLstHdrB_Kyo_Crouch0_B
	dw OBJLstHdrA_Kyo_JumpN1_A, OBJLstHdrB_Kyo_JumpN1_B
	dw OBJLstHdrA_Kyo_JumpN1_A, OBJLstHdrB_Kyo_JumpN1_B
	dw OBJLstHdrA_Kyo_JumpN1_A, OBJLstHdrB_Kyo_JumpN3_B
	dw OBJLstHdrA_Kyo_JumpN1_A, OBJLstHdrB_Kyo_JumpN3_B
	dw OBJLstHdrA_Kyo_JumpN1_A, OBJLstHdrB_Kyo_JumpN1_B
	dw OBJLstHdrA_Kyo_JumpN1_A, OBJLstHdrB_Kyo_JumpN1_B
	dw OBJLstHdrA_Kyo_Crouch0_A, OBJLstHdrB_Kyo_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_JumpF:
	dw OBJLstHdrA_Kyo_Crouch0_A, OBJLstHdrB_Kyo_Crouch0_B ;X
	dw OBJLstHdrA_Kyo_JumpN1_A, OBJLstHdrB_Kyo_JumpN1_B
	dw OBJLstHdrA_Kyo_JumpF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_JumpF3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_JumpF4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_JumpF5, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_JumpN1_A, OBJLstHdrB_Kyo_JumpN1_B
	dw OBJLstHdrA_Kyo_Crouch0_A, OBJLstHdrB_Kyo_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_JumpB:
	dw OBJLstHdrA_Kyo_Crouch0_A, OBJLstHdrB_Kyo_Crouch0_B ;X
	dw OBJLstHdrA_Kyo_JumpN1_A, OBJLstHdrB_Kyo_JumpN1_B
	dw OBJLstHdrA_Kyo_JumpF5, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_JumpF4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_JumpF3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_JumpF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_JumpN1_A, OBJLstHdrB_Kyo_JumpN1_B
	dw OBJLstHdrA_Kyo_Crouch0_A, OBJLstHdrB_Kyo_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_BlockG:
	dw OBJLstHdrA_Kyo_BlockG0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_BlockC:
	dw OBJLstHdrA_Kyo_BlockC0_A, OBJLstHdrB_Kyo_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_BlockA:
	dw OBJLstHdrA_Kyo_BlockA0_A, OBJLstHdrB_Kyo_BlockA0_B ;X
	dw OBJLstHdrA_Kyo_Crouch0_A, OBJLstHdrB_Kyo_Crouch0_B ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_RunF:
	dw OBJLstHdrA_Kyo_RunF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_RunF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_RunF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_RunF1, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_HopB:
	dw OBJLstHdrA_Kyo_HopB0_A, OBJLstHdrB_Kyo_HopB0_B
	dw OBJLstHdrA_Kyo_JumpN1_A, OBJLstHdrB_Kyo_JumpN1_B
	dw OBJLstHdrA_Kyo_Crouch0_A, OBJLstHdrB_Kyo_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_ChargeMeter:
	dw OBJLstHdrA_Kyo_ChargeMeter0_A, OBJLstHdrB_Kyo_ChargeMeter0_B
	dw OBJLstHdrA_Kyo_ChargeMeter1_A, OBJLstHdrB_Kyo_ChargeMeter0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_DemoIntro:
	dw OBJLstHdrA_Kyo_DemoIntro0_A, OBJLstHdrB_Kyo_DemoIntro0_B
	dw OBJLstHdrA_Kyo_DemoIntro1_A, OBJLstHdrB_Kyo_DemoIntro0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_Intro:
	dw OBJLstHdrA_Kyo_Intro0_A, OBJLstHdrB_Kyo_DemoIntro0_B
	dw OBJLstHdrA_Kyo_Intro1_A, OBJLstHdrB_Kyo_DemoIntro0_B
	dw OBJLstHdrA_Kyo_DemoIntro0_A, OBJLstHdrB_Kyo_DemoIntro0_B
	dw OBJLstHdrA_Kyo_DemoIntro1_A, OBJLstHdrB_Kyo_DemoIntro0_B
	dw OBJLstHdrA_Kyo_DemoIntro0_A, OBJLstHdrB_Kyo_DemoIntro0_B
	dw OBJLstHdrA_Kyo_Intro5, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_Idle0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_IntroSpec:
	dw OBJLstHdrA_Kyo_IntroSpec0_A, OBJLstHdrB_Kyo_IntroSpec0_B
	dw OBJLstHdrA_Kyo_IntroSpec1_A, OBJLstHdrB_Kyo_IntroSpec0_B
	dw OBJLstHdrA_Kyo_IntroSpec2_A, OBJLstHdrB_Kyo_IntroSpec0_B
	dw OBJLstHdrA_Kyo_Idle0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_Idle0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_Taunt:
	dw OBJLstHdrA_Kyo_Intro1_A, OBJLstHdrB_Kyo_DemoIntro0_B
	dw OBJLstHdrA_Kyo_Taunt1_A, OBJLstHdrB_Kyo_DemoIntro0_B
	dw OBJLstHdrA_Kyo_Intro1_A, OBJLstHdrB_Kyo_DemoIntro0_B
	dw OBJLstHdrA_Kyo_Taunt1_A, OBJLstHdrB_Kyo_DemoIntro0_B
	dw OBJLstHdrA_Kyo_Intro1_A, OBJLstHdrB_Kyo_DemoIntro0_B
	dw OBJLstHdrA_Kyo_Taunt1_A, OBJLstHdrB_Kyo_DemoIntro0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_WinA:
	dw OBJLstHdrA_Kyo_WinA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_WinA1_A, OBJLstHdrB_Kyo_WinA1_B
	dw OBJLstHdrA_Kyo_WinA2_A, OBJLstHdrB_Kyo_WinA1_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_WinB:
	dw OBJLstHdrA_Kyo_WinB0_A, OBJLstHdrB_Kyo_DemoIntro0_B
	dw OBJLstHdrA_Kyo_WinB1_A, OBJLstHdrB_Kyo_DemoIntro0_B
	dw OBJLstHdrA_Kyo_WinB2_A, OBJLstHdrB_Kyo_DemoIntro0_B
	dw OBJLstHdrA_Kyo_Intro1_A, OBJLstHdrB_Kyo_DemoIntro0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_PunchL:
	dw OBJLstHdrA_Kyo_PunchL0_A, OBJLstHdrB_Kyo_PunchL0_B
	dw OBJLstHdrA_Kyo_PunchL1_A, OBJLstHdrB_Kyo_PunchL0_B
	dw OBJLstHdrA_Kyo_PunchL0_A, OBJLstHdrB_Kyo_PunchL0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_PunchH:
	dw OBJLstHdrA_Kyo_PunchH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_PunchH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_PunchH2_A, OBJLstHdrB_Kyo_PunchH2_B
	dw OBJLstHdrA_Kyo_PunchL0_A, OBJLstHdrB_Kyo_PunchL0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_KickL:
	dw OBJLstHdrA_Kyo_PunchL0_A, OBJLstHdrB_Kyo_PunchL0_B
	dw OBJLstHdrA_Kyo_KickL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_PunchL0_A, OBJLstHdrB_Kyo_PunchL0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_KickH:
	dw OBJLstHdrA_Kyo_KickH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_KickH1_A, OBJLstHdrB_Kyo_KickH1_B
	dw OBJLstHdrA_Kyo_KickH2_A, OBJLstHdrB_Kyo_KickH2_B
	dw OBJLstHdrA_Kyo_JumpN1_A, OBJLstHdrB_Kyo_JumpN1_B
	dw OBJLstHdrA_Kyo_Crouch0_A, OBJLstHdrB_Kyo_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_PunchCL:
	dw OBJLstHdrA_Kyo_Crouch0_A, OBJLstHdrB_Kyo_Crouch0_B
	dw OBJLstHdrA_Kyo_PunchCL1_A, OBJLstHdrB_Kyo_Crouch0_B
	dw OBJLstHdrA_Kyo_Crouch0_A, OBJLstHdrB_Kyo_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_PunchCH:
	dw OBJLstHdrA_Kyo_PunchCH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_PunchCH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_PunchCH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_PunchCH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_Crouch0_A, OBJLstHdrB_Kyo_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_KickCL:
	dw OBJLstHdrA_Kyo_Crouch0_A, OBJLstHdrB_Kyo_Crouch0_B
	dw OBJLstHdrA_Kyo_KickCL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_Crouch0_A, OBJLstHdrB_Kyo_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_KickCH:
	dw OBJLstHdrA_Kyo_KickCH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_KickCH1_A, OBJLstHdrB_Kyo_KickCH1_B
	dw OBJLstHdrA_Kyo_KickCH2_A, OBJLstHdrB_Kyo_KickCH1_B
	dw OBJLstHdrA_Kyo_KickCH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_Crouch0_A, OBJLstHdrB_Kyo_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_PunchA:
	dw OBJLstHdrA_Kyo_PunchA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_PunchA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_JumpN1_A, OBJLstHdrB_Kyo_JumpN3_B
	dw OBJLstHdrA_Kyo_JumpN1_A, OBJLstHdrB_Kyo_JumpN1_B
	dw OBJLstHdrA_Kyo_Crouch0_A, OBJLstHdrB_Kyo_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_KickA:
	dw OBJLstHdrA_Kyo_KickA0_A, OBJLstHdrB_Kyo_KickH2_B
	dw OBJLstHdrA_Kyo_KickA0_A, OBJLstHdrB_Kyo_KickH2_B
	dw OBJLstHdrA_Kyo_JumpN1_A, OBJLstHdrB_Kyo_JumpN3_B
	dw OBJLstHdrA_Kyo_JumpN1_A, OBJLstHdrB_Kyo_JumpN1_B
	dw OBJLstHdrA_Kyo_Crouch0_A, OBJLstHdrB_Kyo_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_AttackA:
	dw OBJLstHdrA_Kyo_AttackA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_AttackA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_JumpN1_A, OBJLstHdrB_Kyo_JumpN3_B
	dw OBJLstHdrA_Kyo_JumpN1_A, OBJLstHdrB_Kyo_JumpN1_B
	dw OBJLstHdrA_Kyo_Crouch0_A, OBJLstHdrB_Kyo_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_AttackG:
	dw OBJLstHdrA_Kyo_AttackG0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_AttackG1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_AttackG2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_RollF:
	dw OBJLstHdrA_Kyo_RollF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_RollF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_RollF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_RollF3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_Crouch0_A, OBJLstHdrB_Kyo_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_RollB:
	dw OBJLstHdrA_Kyo_RollF3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_RollF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_RollF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_RollF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_Crouch0_A, OBJLstHdrB_Kyo_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_GuardBreakG:
	dw OBJLstHdrA_Kyo_GuardBreakG0_A, OBJLstHdrB_Kyo_HopB0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_Dizzy:
	dw OBJLstHdrA_Kyo_Idle0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_GuardBreakG0_A, OBJLstHdrB_Kyo_HopB0_B
OBJLstPtrTable_Kyo_TimeOver:
	dw OBJLstHdrA_Kyo_HopB0_A, OBJLstHdrB_Kyo_HopB0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_Hitlow:
	dw OBJLstHdrA_Kyo_Hitlow0_A, OBJLstHdrB_Kyo_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_GuardBreakA:
	dw OBJLstHdrA_Kyo_GuardBreakG0_A, OBJLstHdrB_Kyo_HopB0_B ;X
	dw OBJLstHdrA_Kyo_Crouch0_A, OBJLstHdrB_Kyo_Crouch0_B ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_BackjumpRecA:
	dw OBJLstHdrA_Kyo_GuardBreakG0_A, OBJLstHdrB_Kyo_HopB0_B
	dw OBJLstHdrA_Kyo_JumpF5, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_JumpF4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_JumpF3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_JumpF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_JumpN1_A, OBJLstHdrB_Kyo_JumpN1_B
	dw OBJLstHdrA_Kyo_Crouch0_A, OBJLstHdrB_Kyo_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_DropMain:
	dw OBJLstHdrA_Kyo_GuardBreakG0_A, OBJLstHdrB_Kyo_HopB0_B
	dw OBJLstHdrA_Kyo_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_DropMain2, OBJLSTPTR_NONE
OBJLstPtrTable_Kyo_HitMultigs:
	dw OBJLstHdrA_Kyo_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_DropMain2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_HitSwoopup:
	dw OBJLstHdrA_Kyo_HopB0_A, OBJLstHdrB_Kyo_HopB0_B
	dw OBJLstHdrA_Kyo_HitSwoopup1_A, OBJLstHdrB_Kyo_HitSwoopup1_B
	dw OBJLstHdrA_Kyo_HitSwoopup2_A, OBJLstHdrB_Kyo_HitSwoopup2_B
OBJLstPtrTable_Kyo_ThrowEndA:
	dw OBJLstHdrA_Kyo_ThrowEndA3_A, OBJLstHdrB_Kyo_ThrowEndA3_B
	dw OBJLstHdrA_Kyo_ThrowEndA3_A, OBJLstHdrB_Kyo_ThrowEndA3_B
	dw OBJLstHdrA_Kyo_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_DropMain2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_DropDbg:
	dw OBJLstHdrA_Kyo_HopB0_A, OBJLstHdrB_Kyo_HopB0_B
	dw OBJLstHdrA_Kyo_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_DropMain2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_ThrowRotL:
	dw OBJLstHdrA_Kyo_ThrowRotL0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_WakeUp:
	dw OBJLstHdrA_Kyo_Crouch0_A, OBJLstHdrB_Kyo_Crouch0_B
	dw OBJLstHdrA_Kyo_Crouch0_A, OBJLstHdrB_Kyo_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_AraKamiL:
	dw OBJLstHdrA_Kyo_AraKamiL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_AraKamiL1_A, OBJLstHdrB_Kyo_AraKamiL1_B
	dw OBJLstHdrA_Kyo_AraKamiL2_A, OBJLstHdrB_Kyo_AraKamiL1_B
	dw OBJLstHdrA_Kyo_AraKamiL3_A, OBJLstHdrB_Kyo_AraKamiL1_B
	dw OBJLstHdrA_Kyo_AraKamiL4_A, OBJLstHdrB_Kyo_AraKamiL4_B
	dw OBJLstHdrA_Kyo_AraKamiL5_A, OBJLstHdrB_Kyo_AraKamiL5_B
	dw OBJLstHdrA_Kyo_AraKamiL6_A, OBJLstHdrB_Kyo_AraKamiL5_B
	dw OBJLstHdrA_Kyo_AraKamiL7_A, OBJLstHdrB_Kyo_AraKamiL5_B
	dw OBJLstHdrA_Kyo_AraKamiL8_A, OBJLstHdrB_Kyo_AraKamiL8_B
	dw OBJLstHdrA_Kyo_AraKamiL9_A, OBJLstHdrB_Kyo_AraKamiL8_B
	dw OBJLstHdrA_Kyo_AraKamiL10_A, OBJLstHdrB_Kyo_AraKamiL8_B
	dw OBJLstHdrA_Kyo_AraKamiL11_A, OBJLstHdrB_Kyo_AraKamiL4_B
	dw OBJLstHdrA_Kyo_AraKamiL8_A, OBJLstHdrB_Kyo_AraKamiL8_B
	dw OBJLstHdrA_Kyo_AraKamiL9_A, OBJLstHdrB_Kyo_AraKamiL8_B
	dw OBJLstHdrA_Kyo_AraKamiL10_A, OBJLstHdrB_Kyo_AraKamiL8_B
	dw OBJLstHdrA_Kyo_AraKamiL11_A, OBJLstHdrB_Kyo_AraKamiL4_B
	dw OBJLstHdrA_Kyo_AraKamiL16, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_AraKamiL17_A, OBJLstHdrB_Kyo_AraKamiL17_B
	dw OBJLstHdrA_Kyo_AraKamiL18_A, OBJLstHdrB_Kyo_AraKamiL17_B
	dw OBJLstHdrA_Kyo_AraKamiL19_A, OBJLstHdrB_Kyo_AraKamiL17_B
	dw OBJLstHdrA_Kyo_KickH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_AraKamiL21, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_PunchL0_A, OBJLstHdrB_Kyo_PunchL0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_AraKamiH:
	dw OBJLstHdrA_Kyo_AraKamiH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_AraKamiH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_AraKamiH2_A, OBJLstHdrB_Kyo_AraKamiH2_B
	dw OBJLstHdrA_Kyo_AraKamiH3_A, OBJLstHdrB_Kyo_AraKamiH2_B
	dw OBJLstHdrA_Kyo_AraKamiH4_A, OBJLstHdrB_Kyo_AraKamiH4_B
	dw OBJLstHdrA_Kyo_AraKamiH5_A, OBJLstHdrB_Kyo_AraKamiH4_B
	dw OBJLstHdrA_Kyo_AraKamiH6_A, OBJLstHdrB_Kyo_AraKamiH4_B
	dw OBJLstHdrA_Kyo_AraKamiH7, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_AraKamiH8, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_KickH1_A, OBJLstHdrB_Kyo_KickH1_B
	dw OBJLstHdrA_Kyo_JumpN1_A, OBJLstHdrB_Kyo_JumpN1_B
	dw OBJLstHdrA_Kyo_Crouch0_A, OBJLstHdrB_Kyo_Crouch0_B
	dw OBJLstHdrA_Kyo_PunchL0_A, OBJLstHdrB_Kyo_PunchL0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_RedKickL:
	dw OBJLstHdrA_Kyo_Crouch0_A, OBJLstHdrB_Kyo_Crouch0_B
	dw OBJLstHdrA_Kyo_RedKickL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_RedKickL2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_RedKickL3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_RedKickL4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_Crouch0_A, OBJLstHdrB_Kyo_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_OniyakiL:
	dw OBJLstHdrA_Kyo_OniyakiL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_OniyakiL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_OniyakiL2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_OniyakiL3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_OniyakiL4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_JumpN1_A, OBJLstHdrB_Kyo_JumpN1_B
	dw OBJLstHdrA_Kyo_Crouch0_A, OBJLstHdrB_Kyo_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_KototsukiYouL:
	dw OBJLstHdrA_Kyo_KototsukiYouL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_RunF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_RunF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_RunF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_Idle3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_OniyakiL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_KototsukiYouL6, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_KaiL:
	dw OBJLstHdrA_Kyo_KaiL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_KaiL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_JumpN1_A, OBJLstHdrB_Kyo_JumpN1_B
	dw OBJLstHdrA_Kyo_KaiL3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_JumpN1_A, OBJLstHdrB_Kyo_JumpN1_B
	dw OBJLstHdrA_Kyo_Crouch0_A, OBJLstHdrB_Kyo_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_NueTumiL:
	dw OBJLstHdrA_Kyo_KaiL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_NueTumiL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_NueTumiL2_A, OBJLstHdrB_Kyo_NueTumiL2_B
	dw OBJLstHdrA_Kyo_NueTumiL3_A, OBJLstHdrB_Kyo_NueTumiL2_B
	dw OBJLstHdrA_Kyo_AraKamiL16, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_AraKamiL17_A, OBJLstHdrB_Kyo_AraKamiL17_B
	dw OBJLstHdrA_Kyo_AraKamiL18_A, OBJLstHdrB_Kyo_AraKamiL17_B
	dw OBJLstHdrA_Kyo_AraKamiL19_A, OBJLstHdrB_Kyo_AraKamiL17_B
	dw OBJLstHdrA_Kyo_AraKamiL8_A, OBJLstHdrB_Kyo_AraKamiL8_B
	dw OBJLstHdrA_Kyo_AraKamiL9_A, OBJLstHdrB_Kyo_AraKamiL8_B
	dw OBJLstHdrA_Kyo_AraKamiL10_A, OBJLstHdrB_Kyo_AraKamiL8_B
	dw OBJLstHdrA_Kyo_AraKamiL11_A, OBJLstHdrB_Kyo_AraKamiL4_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_UraOrochiNagiS:
	dw OBJLstHdrA_Kyo_UraOrochiNagiS0_A, OBJLstHdrB_Kyo_UraOrochiNagiS0_B
	dw OBJLstHdrA_Kyo_UraOrochiNagiS1_A, OBJLstHdrB_Kyo_UraOrochiNagiS0_B
	dw OBJLstHdrA_Kyo_UraOrochiNagiS0_A, OBJLstHdrB_Kyo_UraOrochiNagiS0_B
	dw OBJLstHdrA_Kyo_AttackG0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_UraOrochiNagiS4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_UraOrochiNagiS5, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_UraOrochiNagiS6, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_UraOrochiNagiS7, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_UraOrochiNagiD:
	dw OBJLstHdrA_Kyo_UraOrochiNagiD0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_UraOrochiNagiD1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_UraOrochiNagiD0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_AttackG0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_UraOrochiNagiS4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_UraOrochiNagiS5, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_UraOrochiNagiS6, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_UraOrochiNagiS7, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Kyo_ThrowG:
	dw OBJLstHdrA_Kyo_OniyakiL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_ThrowG1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Kyo_ThrowG2_A, OBJLstHdrB_Kyo_AraKamiL8_B
	dw OBJLstHdrA_Kyo_Idle0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		
OBJLstHdrA_Kyo_Idle0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B4000 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $20,$F4,$00 ; $00
	db $1C,$FC,$02 ; $01
	db $21,$04,$04 ; $02
	db $30,$F4,$06 ; $03
	db $2C,$FC,$08 ; $04
	db $32,$04,$0A ; $05
		
OBJLstHdrA_Kyo_Idle1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B40C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $20,$F4,$00 ; $00
	db $1C,$FC,$02 ; $01
	db $20,$04,$04 ; $02
	db $30,$F4,$06 ; $03
	db $2C,$FC,$08 ; $04
	db $34,$04,$0A ; $05
		
OBJLstHdrA_Kyo_Idle3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B4180 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $21,$F4,$00 ; $00
	db $1D,$FC,$02 ; $01
	db $25,$04,$04 ; $02
	db $31,$F4,$06 ; $03
	db $2D,$FC,$08 ; $04
	db $35,$04,$0A ; $05
		
OBJLstHdrA_Kyo_WalkF0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B4240 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$F3,$00 ; $00
	db $20,$FB,$02 ; $01
	db $1D,$FF,$04 ; $02
	db $10,$F7,$06 ; $03
		
OBJLstHdrB_Kyo_WalkF0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0B42C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $30,$F9,$00 ; $00
	db $30,$01,$02 ; $01
		
OBJLstHdrB_Kyo_WalkF4_B:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	dpr L0B42C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_Kyo_WalkF0_B.bin ; iOBJLstHdrA_DataPtr
	db $FF ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Kyo_Crouch0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B4300 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $28,$F1,$00 ; $00
	db $28,$F9,$02 ; $01
	db $28,$01,$04 ; $02
	db $18,$F9,$06 ; $03
		
OBJLstHdrB_Kyo_Crouch0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0B4380 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $38,$F5,$00 ; $00
	db $38,$FD,$02 ; $01
	db $3B,$05,$04 ; $02
		
OBJLstHdrA_Kyo_JumpN1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B43E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Kyo_KickH1_A.bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $FD ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Kyo_KickH1_A:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B43E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FD ; iOBJLstHdrA_XOffset
	db $FD ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $20,$F1,$00 ; $00
	db $20,$F9,$02 ; $01
	db $20,$01,$04 ; $02
		
OBJLstHdrB_Kyo_JumpN1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0B4440 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $FD ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$F4,$00 ; $00
	db $30,$FC,$02 ; $01
	db $40,$FC,$04 ; $02
		
OBJLstHdrB_Kyo_JumpN3_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0B44A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $FD ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $30,$F4,$00 ; $00
	db $30,$FC,$02 ; $01
		
OBJLstHdrB_Kyo_KickH1_B:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	dpr L0B44A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_Kyo_JumpN3_B.bin ; iOBJLstHdrA_DataPtr
	db $FD ; iOBJLstHdrA_XOffset
	db $FD ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Kyo_JumpF2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B44E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $0C ; iOBJLstHdrA_XOffset
	db $FD ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $27,$E8,$00 ; $00
	db $1F,$F0,$02 ; $01
	db $27,$F8,$04 ; $02
	db $2F,$F0,$06 ; $03
	db $37,$F8,$08 ; $04
		
OBJLstHdrA_Kyo_JumpF4:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B44E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Kyo_JumpF2.bin ; iOBJLstHdrA_DataPtr
	db $F4 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Kyo_RollF1:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B44E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Kyo_JumpF2.bin ; iOBJLstHdrA_DataPtr
	db $F4 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Kyo_JumpF3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B4580 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $08 ; iOBJLstHdrA_XOffset
	db $FC ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$F1,$00 ; $00
	db $20,$F9,$02 ; $01
	db $30,$F1,$04 ; $02
	db $30,$F9,$06 ; $03
		
OBJLstHdrA_Kyo_JumpF5:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B4580 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Kyo_JumpF3.bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Kyo_BlockG0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B4600 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $22,$FC,$00 ; $00
	db $22,$04,$02 ; $01
	db $39,$F4,$04 ; $02
	db $32,$FC,$06 ; $03
	db $32,$04,$08 ; $04
		
OBJLstHdrA_Kyo_BlockC0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B46A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $28,$F1,$00 ; $00
	db $28,$F9,$02 ; $01
	db $28,$01,$04 ; $02
	db $18,$F9,$06 ; $03
		
OBJLstHdrA_Kyo_BlockA0_A: ;X
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B46A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Kyo_BlockC0_A.bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $F8 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Kyo_BlockA0_B: ;X
	db $00 ; iOBJLstHdrA_Flags
	dpr L0B4720 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $07 ; iOBJLstHdrA_XOffset
	db $10 ; iOBJLstHdrA_YOffset
.bin: ;X
	db $03 ; OBJ Count
	;    Y   X  ID
	db $20,$F1,$00 ; $00
	db $20,$F9,$02 ; $01
	db $24,$01,$04 ; $02
		
OBJLstHdrA_Kyo_PunchL0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B4780 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $1F,$EF,$00 ; $00
	db $20,$F7,$02 ; $01
	db $20,$FF,$04 ; $02
		
OBJLstHdrB_Kyo_PunchL0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0B47E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $31,$F5,$00 ; $00
	db $30,$FD,$02 ; $01
	db $38,$05,$04 ; $02
		
OBJLstHdrA_Kyo_PunchL1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L0B4840 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $28,$E9,$00 ; $00
	db $1E,$F1,$02 ; $01
	db $20,$F9,$04 ; $02
	db $20,$01,$06 ; $03
		
OBJLstHdrA_Kyo_PunchH0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B48C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1F,$F6,$00 ; $00
	db $21,$FE,$02 ; $01
	db $27,$06,$04 ; $02
	db $30,$F6,$06 ; $03
	db $31,$FE,$08 ; $04
	db $37,$06,$0A ; $05
		
OBJLstHdrA_Kyo_PunchH1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B4980 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $23,$F2,$00 ; $00
	db $1E,$FA,$02 ; $01
	db $20,$02,$04 ; $02
	db $33,$F2,$06 ; $03
	db $2E,$FA,$08 ; $04
	db $32,$02,$0A ; $05
		
OBJLstHdrA_Kyo_PunchH2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L0B4A40 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $20,$ED,$00 ; $00
	db $20,$F5,$02 ; $01
	db $20,$FD,$04 ; $02
	db $10,$ED,$06 ; $03
	db $10,$F5,$08 ; $04
		
OBJLstHdrB_Kyo_PunchH2_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0B4AE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$F4,$00 ; $00
	db $30,$FC,$02 ; $01
	db $3B,$04,$04 ; $02
		
OBJLstHdrA_Kyo_KickL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_4A ; iOBJLstHdrA_HitboxId
	dpr L0B4B40 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $29,$E1,$00 ; $00
	db $20,$E9,$02 ; $01
	db $20,$F1,$04 ; $02
	db $15,$F9,$06 ; $03
	db $1F,$01,$08 ; $04
	db $30,$F3,$0A ; $05
	db $25,$F9,$0C ; $06
		
OBJLstHdrA_Kyo_KickH0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B4C20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1E,$F4,$00 ; $00
	db $1C,$FC,$02 ; $01
	db $1E,$04,$04 ; $02
	db $2E,$FA,$06 ; $03
	db $2C,$FC,$08 ; $04
	db $36,$F5,$0A ; $05
		
OBJLstHdrA_Kyo_RedKickL1:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B4C20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Kyo_KickH0.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Kyo_KickH2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L0B4CE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $28,$E9,$00 ; $00
	db $20,$F1,$02 ; $01
	db $20,$F9,$04 ; $02
	db $30,$F9,$06 ; $03
		
OBJLstHdrB_Kyo_KickH2_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0B4D60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $10,$F1,$00 ; $00
	db $10,$F9,$02 ; $01
	db $10,$01,$04 ; $02
	db $20,$01,$06 ; $03
	db $30,$01,$08 ; $04
		
OBJLstHdrA_Kyo_PunchCL1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L0B4E00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $23,$E7,$00 ; $00
	db $28,$EF,$02 ; $01
	db $28,$F7,$04 ; $02
	db $28,$FF,$06 ; $03
	db $18,$F7,$08 ; $04
		
OBJLstHdrA_Kyo_PunchCH0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B4EA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1D,$ED,$00 ; $00
	db $20,$F5,$02 ; $01
	db $20,$FD,$04 ; $02
	db $32,$EF,$06 ; $03
	db $30,$F7,$08 ; $04
	db $30,$FF,$0A ; $05
		
OBJLstHdrA_Kyo_PunchCH1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_4B ; iOBJLstHdrA_HitboxId
	dpr L0B4F60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $0C,$EA,$00 ; $00
	db $10,$F6,$02 ; $01
	db $18,$EE,$04 ; $02
	db $20,$F5,$06 ; $03
	db $20,$FD,$08 ; $04
	db $30,$F5,$0A ; $05
	db $30,$FD,$0C ; $06
		
OBJLstHdrA_Kyo_KickCL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_4C ; iOBJLstHdrA_HitboxId
	dpr L0B5040 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $25,$F0,$00 ; $00
	db $26,$F8,$02 ; $01
	db $2C,$00,$04 ; $02
	db $21,$E8,$06 ; $03
	db $36,$F8,$08 ; $04
	db $37,$F0,$0A ; $05
	db $3A,$E8,$0C ; $06
	db $3C,$00,$0E ; $07
		
OBJLstHdrA_Kyo_KickCH0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B5140 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $30,$F2,$00 ; $00
	db $28,$F7,$02 ; $01
	db $28,$FF,$04 ; $02
	db $38,$FA,$06 ; $03
	db $38,$02,$08 ; $04
		
OBJLstHdrA_Kyo_KickCH1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_4D ; iOBJLstHdrA_HitboxId
	dpr L0B51E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $32,$E9,$00 ; $00
	db $34,$E1,$02 ; $01
		
OBJLstHdrB_Kyo_KickCH1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0B5220 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $29,$EF,$00 ; $00
	db $28,$F7,$02 ; $01
	db $28,$FF,$04 ; $02
	db $38,$F7,$06 ; $03
	db $38,$FF,$08 ; $04
	db $3B,$07,$0A ; $05
		
OBJLstHdrA_Kyo_KickCH2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B52E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $32,$E9,$00 ; $00
	db $36,$E1,$02 ; $01
		
OBJLstHdrA_Kyo_PunchA0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L0B5320 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $06 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1F,$E9,$00 ; $00
	db $10,$F1,$02 ; $01
	db $18,$F9,$04 ; $02
	db $13,$01,$06 ; $03
	db $20,$F1,$08 ; $04
	db $28,$F9,$0A ; $05
	db $29,$01,$0C ; $06
		
OBJLstHdrA_Kyo_KickA0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L0B5400 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $08 ; iOBJLstHdrA_XOffset
	db $10 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $10,$E1,$00 ; $00
	db $18,$E9,$02 ; $01
	db $18,$F1,$04 ; $02
	db $28,$F1,$06 ; $03
		
OBJLstHdrA_Kyo_AttackG0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B5480 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1F,$F8,$00 ; $00
	db $1E,$00,$02 ; $01
	db $2F,$F8,$04 ; $02
	db $2E,$00,$06 ; $03
	db $3B,$F1,$08 ; $04
	db $3E,$00,$0A ; $05
		
OBJLstHdrA_Kyo_AttackG1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B5540 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1E,$F8,$00 ; $00
	db $1D,$00,$02 ; $01
	db $2E,$F8,$04 ; $02
	db $2D,$00,$06 ; $03
	db $3A,$F1,$08 ; $04
	db $3D,$00,$0A ; $05
		
OBJLstHdrA_Kyo_AttackA0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L0B5600 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $0C ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $10,$E7,$00 ; $00
	db $10,$EF,$02 ; $01
	db $10,$F9,$04 ; $02
	db $20,$E7,$06 ; $03
	db $20,$EF,$08 ; $04
	db $20,$F7,$0A ; $05
		
OBJLstHdrA_Kyo_RollF0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B5600 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Kyo_AttackA0.bin ; iOBJLstHdrA_DataPtr
	db $0C ; iOBJLstHdrA_XOffset
	db $10 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Kyo_ChargeMeter0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B59A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $0E ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $20,$E8,$00 ; $00
	db $20,$F0,$02 ; $01
	db $20,$F8,$04 ; $02
	db $10,$F0,$06 ; $03
	db $10,$F8,$08 ; $04
		
OBJLstHdrB_Kyo_ChargeMeter0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0B5A40 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $0E ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $34,$E0,$00 ; $00
	db $30,$E8,$02 ; $01
	db $30,$F0,$04 ; $02
	db $30,$F8,$06 ; $03
		
OBJLstHdrA_Kyo_ChargeMeter1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B5AC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $0E ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $20,$E8,$00 ; $00
	db $20,$F0,$02 ; $01
	db $20,$F8,$04 ; $02
	db $10,$F0,$06 ; $03
	db $10,$F8,$08 ; $04
		
OBJLstHdrA_Kyo_RunF0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B6780 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $21,$F1,$00 ; $00
	db $21,$F9,$02 ; $01
	db $21,$01,$04 ; $02
	db $31,$F4,$06 ; $03
	db $31,$FC,$08 ; $04
	db $35,$04,$0A ; $05
		
OBJLstHdrA_Kyo_RunF1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B6840 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $21,$F0,$00 ; $00
	db $21,$F8,$02 ; $01
	db $21,$00,$04 ; $02
	db $31,$F5,$06 ; $03
	db $31,$FD,$08 ; $04
		
OBJLstHdrA_Kyo_RunF2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B68E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $23,$F2,$00 ; $00
	db $1B,$FA,$02 ; $01
	db $20,$02,$04 ; $02
	db $33,$F2,$06 ; $03
	db $2B,$FA,$08 ; $04
	db $32,$02,$0A ; $05
		
OBJLstHdrA_Kyo_Intro0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B5B60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $20,$FA,$00 ; $00
	db $20,$02,$02 ; $01
	db $10,$01,$04 ; $02
		
OBJLstHdrB_Kyo_DemoIntro0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0B5BC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$F9,$00 ; $00
	db $30,$01,$02 ; $01
	db $3D,$F1,$04 ; $02
		
OBJLstHdrA_Kyo_Intro1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B5C20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$F5,$00 ; $00
	db $20,$FD,$02 ; $01
	db $20,$05,$04 ; $02
	db $10,$FD,$06 ; $03
		
OBJLstHdrA_Kyo_DemoIntro0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B5CA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $11,$F2,$00 ; $00
	db $19,$F6,$02 ; $01
	db $20,$FB,$04 ; $02
	db $20,$03,$06 ; $03
	db $10,$FE,$08 ; $04
		
OBJLstHdrA_Kyo_DemoIntro1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B5D40 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $11,$F1,$00 ; $00
	db $19,$F6,$02 ; $01
	db $20,$FB,$04 ; $02
	db $20,$03,$06 ; $03
	db $10,$FE,$08 ; $04
		
OBJLstHdrA_Kyo_Intro5:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B5DE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $21,$F9,$00 ; $00
	db $21,$01,$02 ; $01
	db $31,$F2,$04 ; $02
	db $31,$FA,$06 ; $03
	db $31,$02,$08 ; $04
		
OBJLstHdrA_Kyo_IntroSpec0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B5E80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $18,$F9,$00 ; $00
	db $18,$01,$02 ; $01
	db $28,$F8,$04 ; $02
	db $28,$00,$06 ; $03
		
OBJLstHdrB_Kyo_IntroSpec0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0B5F00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $38,$F9,$00 ; $00
	db $38,$01,$02 ; $01
	db $3D,$F1,$04 ; $02
		
OBJLstHdrA_Kyo_IntroSpec1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B5F60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $28,$F9,$00 ; $00
	db $28,$01,$02 ; $01
	db $18,$F9,$04 ; $02
	db $18,$01,$06 ; $03
		
OBJLstHdrA_Kyo_IntroSpec2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B5FE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $28,$F9,$00 ; $00
	db $28,$01,$02 ; $01
	db $18,$F9,$04 ; $02
	db $18,$01,$06 ; $03
		
OBJLstHdrA_Kyo_Taunt1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B6060 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$F9,$00 ; $00
	db $20,$01,$02 ; $01
	db $20,$09,$04 ; $02
	db $10,$01,$06 ; $03
		
OBJLstHdrA_Kyo_WinA0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B60E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1E,$FA,$00 ; $00
	db $1E,$02,$02 ; $01
	db $2E,$FA,$04 ; $02
	db $2E,$02,$06 ; $03
	db $3A,$F6,$08 ; $04
	db $3E,$02,$0A ; $05
		
OBJLstHdrA_Kyo_WinA1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B61A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $18,$F9,$00 ; $00
	db $18,$01,$02 ; $01
	db $10,$F1,$04 ; $02
	db $08,$F9,$06 ; $03
		
OBJLstHdrB_Kyo_WinA1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0B6220 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $28,$F9,$00 ; $00
	db $28,$01,$02 ; $01
	db $3D,$F1,$04 ; $02
	db $38,$F9,$06 ; $03
	db $38,$03,$08 ; $04
		
OBJLstHdrA_Kyo_WinA2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B62C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $15,$F6,$00 ; $00
	db $18,$F9,$02 ; $01
	db $18,$01,$04 ; $02
		
OBJLstHdrA_Kyo_WinB0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B6320 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $10,$F3,$00 ; $00
	db $20,$F3,$02 ; $01
	db $20,$FB,$04 ; $02
	db $20,$03,$06 ; $03
	db $10,$FF,$08 ; $04
		
OBJLstHdrA_Kyo_WinB1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B63C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $10,$F8,$00 ; $00
	db $20,$F8,$02 ; $01
	db $20,$00,$04 ; $02
	db $20,$08,$06 ; $03
	db $10,$00,$08 ; $04
		
OBJLstHdrA_Kyo_WinB2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B6460 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$F6,$00 ; $00
	db $20,$FE,$02 ; $01
	db $20,$06,$04 ; $02
	db $10,$FE,$06 ; $03
		
OBJLstHdrA_Kyo_OniyakiL0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B64E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $20,$F1,$00 ; $00
	db $20,$F9,$02 ; $01
	db $19,$01,$04 ; $02
	db $30,$F1,$06 ; $03
	db $30,$F9,$08 ; $04
	db $35,$01,$0A ; $05
	db $3E,$09,$0C ; $06
		
OBJLstHdrA_Kyo_AttackG2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L0B64E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Kyo_OniyakiL0.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Kyo_ThrowG1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B65C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $23,$ED,$00 ; $00
	db $23,$F5,$02 ; $01
	db $23,$FD,$04 ; $02
	db $33,$F2,$06 ; $03
	db $33,$FA,$08 ; $04
	db $34,$02,$0A ; $05
		
OBJLstHdrA_Kyo_OniyakiL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L0B65C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Kyo_ThrowG1.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Kyo_ThrowG2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L0B6680 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $05 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $28,$E1,$00 ; $00
	db $20,$E9,$02 ; $01
	db $30,$E9,$04 ; $02
		
OBJLstHdrB_Kyo_AraKamiL8_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0B66E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $05 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $23,$F1,$00 ; $00
	db $1E,$F9,$02 ; $01
	db $33,$F1,$04 ; $02
	db $31,$F9,$06 ; $03
	db $3A,$01,$08 ; $04
		
OBJLstHdrA_Kyo_HopB0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B56C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $20,$F1,$00 ; $00
	db $20,$F9,$02 ; $01
	db $20,$01,$04 ; $02
		
OBJLstHdrA_Kyo_ThrowEndA3_A:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B56C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Kyo_HopB0_A.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Kyo_HitSwoopup2_A:
	db OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B56C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Kyo_HopB0_A.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Kyo_HitSwoopup1_A:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B56C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Kyo_HopB0_A.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Kyo_GuardBreakG0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B5720 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $20,$F2,$00 ; $00
	db $20,$FA,$02 ; $01
	db $20,$02,$04 ; $02
		
OBJLstHdrB_Kyo_HopB0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0B5780 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$F9,$00 ; $00
	db $30,$01,$02 ; $01
	db $3B,$F1,$04 ; $02
		
OBJLstHdrB_Kyo_ThrowEndA3_B:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	dpr L0B5780 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_Kyo_HopB0_B.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Kyo_HitSwoopup2_B:
	db OLF_YFLIP ; iOBJLstHdrA_Flags
	dpr L0B5780 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_Kyo_HopB0_B.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Kyo_HitSwoopup1_B:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	dpr L0B5780 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_Kyo_HopB0_B.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Kyo_Hitlow0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B57E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $28,$F3,$00 ; $00
	db $28,$FB,$02 ; $01
	db $27,$01,$04 ; $02
		
OBJLstHdrA_Kyo_DropMain1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B5840 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $08 ; iOBJLstHdrA_XOffset
	db $0A ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $28,$E8,$00 ; $00
	db $25,$F0,$02 ; $01
	db $20,$F8,$04 ; $02
	db $2C,$00,$06 ; $03
	db $30,$F8,$08 ; $04
	db $28,$E0,$0A ; $05
		
OBJLstHdrA_Kyo_ThrowRotL0:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B5840 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Kyo_DropMain1.bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $09 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Kyo_DropMain2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B5900 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $0A ; iOBJLstHdrA_XOffset
	db $03 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $33,$E9,$00 ; $00
	db $34,$F1,$02 ; $01
	db $33,$F9,$04 ; $02
	db $34,$01,$06 ; $03
	db $39,$E1,$08 ; $04
		
OBJLstHdrA_Kyo_AraKamiL0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B69A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $1F,$F6,$00 ; $00
	db $19,$FE,$02 ; $01
	db $23,$06,$04 ; $02
	db $20,$0E,$06 ; $03
	db $33,$F6,$08 ; $04
	db $29,$FE,$0A ; $05
	db $33,$06,$0C ; $06
	db $3B,$0E,$0E ; $07
		
OBJLstHdrA_Kyo_AraKamiL1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_1F ; iOBJLstHdrA_HitboxId
	dpr L0B6AA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $0A ; OBJ Count
	;    Y   X  ID
	db $1C,$D5,$00 ; $00
	db $18,$DE,$02 ; $01
	db $18,$E6,$04 ; $02
	db $28,$DD,$06 ; $03
	db $28,$E5,$08 ; $04
	db $28,$ED,$0A ; $05
	db $28,$F5,$0C ; $06
	db $18,$EF,$0E ; $07
	db $18,$F7,$10 ; $08
	db $28,$FD,$12 ; $09
		
OBJLstHdrB_Kyo_AraKamiL1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0B6BE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $38,$F2,$00 ; $00
	db $38,$FA,$02 ; $01
	db $39,$02,$04 ; $02
		
OBJLstHdrA_Kyo_AraKamiL2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B6C40 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $23,$DE,$00 ; $00
	db $18,$E6,$02 ; $01
	db $18,$F2,$04 ; $02
	db $18,$FA,$06 ; $03
	db $28,$E5,$08 ; $04
	db $28,$ED,$0A ; $05
	db $28,$F5,$0C ; $06
	db $28,$FD,$0E ; $07
		
OBJLstHdrA_Kyo_AraKamiL3_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B6D40 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $18,$F1,$00 ; $00
	db $18,$F9,$02 ; $01
	db $28,$EE,$04 ; $02
	db $28,$F6,$06 ; $03
	db $28,$FE,$08 ; $04
		
OBJLstHdrA_Kyo_AraKamiL4_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_1F ; iOBJLstHdrA_HitboxId
	dpr L0B6DE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $22,$E2,$00 ; $00
	db $28,$E9,$02 ; $01
	db $29,$F1,$04 ; $02
	db $19,$F1,$06 ; $03
		
OBJLstHdrB_Kyo_AraKamiL4_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0B6E60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $24,$F9,$00 ; $00
	db $28,$01,$02 ; $01
	db $34,$F9,$04 ; $02
	db $38,$01,$06 ; $03
	db $3A,$09,$08 ; $04
		
OBJLstHdrA_Kyo_AraKamiL5_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B6F00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $1A,$D9,$00 ; $00
	db $10,$E1,$02 ; $01
	db $14,$E9,$04 ; $02
	db $20,$E1,$06 ; $03
	db $24,$E9,$08 ; $04
		
OBJLstHdrB_Kyo_AraKamiL5_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0B6FA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $19,$EF,$00 ; $00
	db $20,$F7,$02 ; $01
	db $29,$EF,$04 ; $02
	db $30,$F7,$06 ; $03
	db $22,$FF,$08 ; $04
	db $3A,$FF,$0A ; $05
		
OBJLstHdrA_Kyo_AraKamiL6_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B7060 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $1B,$DF,$00 ; $00
	db $19,$E9,$02 ; $01
	db $1F,$E4,$04 ; $02
		
OBJLstHdrA_Kyo_AraKamiL7_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B70C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $01 ; OBJ Count
	;    Y   X  ID
	db $18,$E9,$00 ; $00
		
OBJLstHdrA_Kyo_AraKamiL8_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_1F ; iOBJLstHdrA_HitboxId
	dpr L0B70E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F5 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $25,$E9,$00 ; $00
	db $18,$F1,$02 ; $01
	db $20,$F9,$04 ; $02
	db $28,$F1,$06 ; $03
	db $30,$F9,$08 ; $04
		
OBJLstHdrA_Kyo_AraKamiL9_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B7180 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F5 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $2E,$E1,$00 ; $00
	db $28,$E9,$02 ; $01
	db $20,$F1,$04 ; $02
	db $20,$F9,$06 ; $03
	db $38,$E9,$08 ; $04
	db $30,$F1,$0A ; $05
	db $30,$F9,$0C ; $06
		
OBJLstHdrA_Kyo_AraKamiL10_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B7260 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F5 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $30,$E7,$00 ; $00
	db $30,$EF,$02 ; $01
	db $24,$F2,$04 ; $02
	db $23,$F9,$06 ; $03
	db $20,$EA,$08 ; $04
	db $35,$F9,$0A ; $05
		
OBJLstHdrA_Kyo_AraKamiL11_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B7320 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F2 ; iOBJLstHdrA_XOffset
	db $FF ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $28,$F9,$00 ; $00
	db $18,$F9,$02 ; $01
		
OBJLstHdrA_Kyo_AraKamiL16:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B7360 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $28,$F2,$00 ; $00
	db $20,$FA,$02 ; $01
	db $20,$02,$04 ; $02
	db $30,$FA,$06 ; $03
	db $30,$02,$08 ; $04
	db $39,$0A,$0A ; $05
		
OBJLstHdrA_Kyo_AraKamiL17_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_1F ; iOBJLstHdrA_HitboxId
	dpr L0B7420 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $2F,$E8,$00 ; $00
	db $2D,$EE,$02 ; $01
	db $27,$F1,$04 ; $02
		
OBJLstHdrB_Kyo_AraKamiL17_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0B7480 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $25,$F9,$00 ; $00
	db $27,$01,$02 ; $01
	db $1E,$09,$04 ; $02
	db $35,$F9,$06 ; $03
	db $37,$01,$08 ; $04
	db $3A,$09,$0A ; $05
		
OBJLstHdrA_Kyo_AraKamiL18_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_1F ; iOBJLstHdrA_HitboxId
	dpr L0B7540 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $2D,$E1,$00 ; $00
	db $2C,$E9,$02 ; $01
	db $21,$F1,$04 ; $02
	db $3D,$E1,$06 ; $03
	db $3C,$E9,$08 ; $04
	db $31,$F1,$0A ; $05
		
OBJLstHdrA_Kyo_AraKamiL19_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B7600 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $27,$F6,$00 ; $00
	db $30,$EE,$02 ; $01
		
OBJLstHdrA_Kyo_AraKamiL21:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_1F ; iOBJLstHdrA_HitboxId
	dpr L0B7640 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $20,$E9,$00 ; $00
	db $22,$F1,$02 ; $01
	db $18,$F9,$04 ; $02
	db $1C,$01,$06 ; $03
	db $28,$F9,$08 ; $04
	db $2C,$01,$0A ; $05
	db $3C,$01,$0C ; $06
		
OBJLstHdrA_Kyo_AraKamiH0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B7720 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $22,$F6,$00 ; $00
	db $22,$FE,$02 ; $01
	db $1F,$06,$04 ; $02
	db $1B,$0E,$06 ; $03
	db $32,$F6,$08 ; $04
	db $32,$FE,$0A ; $05
	db $34,$06,$0C ; $06
	db $3A,$0E,$0E ; $07
		
OBJLstHdrA_Kyo_AraKamiH1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_1F ; iOBJLstHdrA_HitboxId
	dpr L0B7820 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $0A ; OBJ Count
	;    Y   X  ID
	db $1C,$DA,$00 ; $00
	db $17,$E2,$02 ; $01
	db $17,$EA,$04 ; $02
	db $27,$DE,$06 ; $03
	db $27,$E6,$08 ; $04
	db $25,$EE,$0A ; $05
	db $20,$F6,$0C ; $06
	db $20,$FE,$0E ; $07
	db $30,$F8,$10 ; $08
	db $30,$00,$12 ; $09
		
OBJLstHdrA_Kyo_AraKamiH2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B7960 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $28,$DE,$00 ; $00
	db $2C,$E6,$02 ; $01
	db $1C,$DF,$04 ; $02
	db $1F,$E7,$06 ; $03
		
OBJLstHdrB_Kyo_AraKamiH2_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0B79E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $20,$F6,$00 ; $00
	db $20,$FE,$02 ; $01
	db $25,$F0,$04 ; $02
	db $30,$F8,$06 ; $03
	db $30,$00,$08 ; $04
		
OBJLstHdrA_Kyo_AraKamiH3_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B7A80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $20,$F6,$00 ; $00
	db $20,$FE,$02 ; $01
	db $26,$F0,$04 ; $02
	db $30,$F8,$06 ; $03
	db $30,$00,$08 ; $04
		
OBJLstHdrA_Kyo_AraKamiH4_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_1F ; iOBJLstHdrA_HitboxId
	dpr L0B7BC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1A,$F1,$00 ; $00
	db $2A,$F1,$02 ; $01
	db $3A,$F1,$04 ; $02
	db $22,$E1,$06 ; $03
	db $22,$E9,$08 ; $04
	db $32,$E9,$0A ; $05
		
OBJLstHdrB_Kyo_AraKamiH4_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0B7B20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $1C,$F9,$00 ; $00
	db $2C,$F9,$02 ; $01
	db $3C,$F9,$04 ; $02
	db $39,$01,$06 ; $03
	db $1E,$01,$08 ; $04
		
OBJLstHdrA_Kyo_AraKamiH5_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B7C80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $1F,$D9,$00 ; $00
	db $20,$E1,$02 ; $01
	db $23,$E9,$04 ; $02
	db $1C,$F1,$06 ; $03
	db $2C,$F1,$08 ; $04
	db $3C,$F1,$0A ; $05
	db $13,$E9,$0C ; $06
	db $10,$E0,$0E ; $07
		
OBJLstHdrA_Kyo_AraKamiH6_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B7D80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $1C,$F1,$00 ; $00
	db $2C,$F1,$02 ; $01
	db $3C,$F1,$04 ; $02
	db $1A,$E9,$06 ; $03
		
OBJLstHdrA_Kyo_AraKamiH7:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L0B7E00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $26,$F1,$00 ; $00
	db $36,$F1,$02 ; $01
	db $1D,$F9,$04 ; $02
	db $2D,$F9,$06 ; $03
	db $3D,$F9,$08 ; $04
	db $3B,$01,$0A ; $05
	db $18,$01,$0C ; $06
		
OBJLstHdrA_Kyo_AraKamiH8:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L0B7EE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $0F ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $0C,$E6,$00 ; $00
	db $0C,$EE,$02 ; $01
	db $11,$F6,$04 ; $02
	db $1C,$E6,$06 ; $03
	db $1C,$EE,$08 ; $04
	db $2C,$E9,$0A ; $05
	db $2C,$F1,$0C ; $06
		
OBJLstHdrA_Kyo_RedKickL2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L1B6DC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $07 ; iOBJLstHdrA_XOffset
	db $0C ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $10,$E8,$00 ; $00
	db $08,$F0,$02 ; $01
	db $08,$F8,$04 ; $02
	db $08,$00,$06 ; $03
	db $18,$F0,$08 ; $04
	db $18,$F8,$0A ; $05
	db $18,$00,$0C ; $06
		
OBJLstHdrA_Kyo_RollF2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1B6DC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Kyo_RedKickL2.bin ; iOBJLstHdrA_DataPtr
	db $07 ; iOBJLstHdrA_XOffset
	db $14 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Kyo_RedKickL3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L1B6EA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $09 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $0C,$F0,$00 ; $00
	db $0C,$F8,$02 ; $01
	db $1C,$EE,$04 ; $02
	db $1C,$F6,$06 ; $03
	db $2C,$F5,$08 ; $04
	db $25,$E6,$0A ; $05
	db $1C,$FE,$0C ; $06
		
OBJLstHdrA_Kyo_RollF3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1B6EA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Kyo_RedKickL3.bin ; iOBJLstHdrA_DataPtr
	db $09 ; iOBJLstHdrA_XOffset
	db $10 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Kyo_RedKickL4:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1C4000 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $0A ; iOBJLstHdrA_XOffset
	db $02 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $07,$F1,$00 ; $00
	db $20,$ED,$02 ; $01
	db $17,$F2,$04 ; $02
	db $17,$FA,$06 ; $03
	db $30,$ED,$08 ; $04
	db $27,$F5,$0A ; $05
		
OBJLstHdrA_Kyo_OniyakiL2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_20 ; iOBJLstHdrA_HitboxId
	dpr L1B6F80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $03 ; iOBJLstHdrA_YOffset
.bin:
	db $0A ; OBJ Count
	;    Y   X  ID
	db $18,$E6,$00 ; $00
	db $18,$EE,$02 ; $01
	db $18,$F6,$04 ; $02
	db $18,$FE,$06 ; $03
	db $12,$06,$08 ; $04
	db $28,$E7,$0A ; $05
	db $28,$EF,$0C ; $06
	db $28,$F7,$0E ; $07
	db $28,$FF,$10 ; $08
	db $38,$F7,$12 ; $09
		
OBJLstHdrA_Kyo_OniyakiL3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_21 ; iOBJLstHdrA_HitboxId
	dpr L1C40C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $0C ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $05,$E9,$00 ; $00
	db $0A,$F1,$02 ; $01
	db $0A,$F9,$04 ; $02
	db $0A,$01,$06 ; $03
	db $15,$E9,$08 ; $04
	db $1A,$F9,$0A ; $05
	db $1A,$01,$0C ; $06
	db $2A,$FC,$0E ; $07
	db $21,$F4,$10 ; $08
		
OBJLstHdrA_Kyo_OniyakiL4:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1C41E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $0A ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $15,$EF,$00 ; $00
	db $10,$F3,$02 ; $01
	db $0F,$FB,$04 ; $02
	db $0A,$03,$06 ; $03
	db $1F,$F9,$08 ; $04
	db $20,$FD,$0A ; $05
	db $2F,$F6,$0C ; $06
		
OBJLstHdrA_Kyo_KototsukiYouL0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1C42C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1D,$F2,$00 ; $00
	db $1F,$FA,$02 ; $01
	db $24,$02,$04 ; $02
	db $2F,$FA,$06 ; $03
	db $34,$02,$08 ; $04
	db $36,$F2,$0A ; $05
		
OBJLstHdrA_Kyo_KototsukiYouL6:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_20 ; iOBJLstHdrA_HitboxId
	dpr L1B70C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $11 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $18,$DC,$00 ; $00
	db $20,$E3,$02 ; $01
	db $1F,$EB,$04 ; $02
	db $30,$E3,$06 ; $03
	db $2F,$EB,$08 ; $04
	db $28,$F3,$0A ; $05
	db $39,$F3,$0C ; $06
		
OBJLstHdrA_Kyo_KaiL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L1B71A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $07 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1B,$E8,$00 ; $00
	db $20,$F0,$02 ; $01
	db $10,$F8,$04 ; $02
	db $10,$00,$06 ; $03
	db $20,$F8,$08 ; $04
	db $20,$00,$0A ; $05
	db $30,$F8,$0C ; $06
		
OBJLstHdrA_Kyo_KaiL3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L1B7280 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $13,$E9,$00 ; $00
	db $0C,$F1,$02 ; $01
	db $15,$F9,$04 ; $02
	db $19,$01,$06 ; $03
	db $1C,$F1,$08 ; $04
	db $25,$F9,$0A ; $05
	db $35,$FA,$0C ; $06
		
OBJLstHdrA_Kyo_KaiL0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1B7360 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $26,$F0,$00 ; $00
	db $26,$F8,$02 ; $01
	db $26,$00,$04 ; $02
	db $36,$F2,$06 ; $03
	db $36,$FA,$08 ; $04
	db $39,$02,$0A ; $05
		
OBJLstHdrA_Kyo_NueTumiL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1B7420 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1E,$E9,$00 ; $00
	db $21,$F1,$02 ; $01
	db $1D,$F9,$04 ; $02
	db $31,$F1,$06 ; $03
	db $2D,$F9,$08 ; $04
	db $37,$01,$0A ; $05
		
OBJLstHdrA_Kyo_NueTumiL2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_20 ; iOBJLstHdrA_HitboxId
	dpr L1B74E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $20,$E9,$00 ; $00
	db $20,$F1,$02 ; $01
	db $20,$F9,$04 ; $02
	db $10,$EA,$06 ; $03
	db $10,$F4,$08 ; $04
		
OBJLstHdrB_Kyo_NueTumiL2_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1B7580 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$F1,$00 ; $00
	db $30,$F9,$02 ; $01
	db $38,$01,$04 ; $02
		
OBJLstHdrA_Kyo_NueTumiL3_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1B75E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $1A,$EA,$00 ; $00
	db $20,$F2,$02 ; $01
	db $20,$FA,$04 ; $02
		
OBJLstHdrA_Kyo_UraOrochiNagiS0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1B7640 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $0A,$F1,$00 ; $00
	db $10,$F9,$02 ; $01
	db $1A,$F1,$04 ; $02
		
OBJLstHdrB_Kyo_UraOrochiNagiS0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1B76A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $20,$F9,$00 ; $00
	db $20,$01,$02 ; $01
	db $30,$F6,$04 ; $02
	db $30,$FE,$06 ; $03
	db $30,$06,$08 ; $04
		
OBJLstHdrA_Kyo_UraOrochiNagiS1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0B7FC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $0F,$F5,$00 ; $00
	db $1A,$F3,$02 ; $01
		
OBJLstHdrA_Kyo_UraOrochiNagiS4:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_16 ; iOBJLstHdrA_HitboxId
	dpr L1B7740 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $0C ; OBJ Count
	;    Y   X  ID
	db $27,$EA,$00 ; $00
	db $22,$F2,$02 ; $01
	db $1E,$FA,$04 ; $02
	db $19,$02,$06 ; $03
	db $10,$0A,$08 ; $04
	db $37,$EA,$0A ; $05
	db $2E,$FA,$0C ; $06
	db $29,$02,$0E ; $07
	db $20,$0A,$10 ; $08
	db $32,$F2,$12 ; $09
	db $39,$02,$14 ; $0A
	db $18,$12,$16 ; $0B
		
OBJLstHdrA_Kyo_UraOrochiNagiS5:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_16 ; iOBJLstHdrA_HitboxId
	dpr L1B78C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $0F ; OBJ Count
	;    Y   X  ID
	db $22,$E1,$00 ; $00
	db $21,$E9,$02 ; $01
	db $22,$F1,$04 ; $02
	db $21,$F9,$06 ; $03
	db $32,$E1,$08 ; $04
	db $31,$E9,$0A ; $05
	db $32,$F1,$0C ; $06
	db $31,$F9,$0E ; $07
	db $1D,$01,$10 ; $08
	db $13,$09,$12 ; $09
	db $2D,$01,$14 ; $0A
	db $23,$09,$16 ; $0B
	db $10,$11,$18 ; $0C
	db $20,$11,$1A ; $0D
	db $3D,$01,$1C ; $0E
		
OBJLstHdrA_Kyo_UraOrochiNagiS6:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_16 ; iOBJLstHdrA_HitboxId
	dpr L1B7AA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $0D ; OBJ Count
	;    Y   X  ID
	db $29,$E1,$00 ; $00
	db $26,$E9,$02 ; $01
	db $23,$F1,$04 ; $02
	db $1D,$F9,$06 ; $03
	db $1E,$01,$08 ; $04
	db $12,$09,$0A ; $05
	db $3A,$E1,$0C ; $06
	db $36,$E9,$0E ; $07
	db $33,$F1,$10 ; $08
	db $2D,$F9,$12 ; $09
	db $2E,$01,$14 ; $0A
	db $22,$09,$16 ; $0B
	db $3E,$01,$18 ; $0C
		
OBJLstHdrA_Kyo_UraOrochiNagiS7:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1B7C40 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $21,$F4,$00 ; $00
	db $21,$FC,$02 ; $01
	db $1B,$03,$04 ; $02
	db $31,$EF,$06 ; $03
	db $31,$F7,$08 ; $04
	db $2D,$FF,$0A ; $05
	db $3B,$03,$0C ; $06
		
OBJLstHdrA_Kyo_UraOrochiNagiD0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_22 ; iOBJLstHdrA_HitboxId
	dpr L1B7D20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $F8 ; iOBJLstHdrA_YOffset
.bin:
	db $0C ; OBJ Count
	;    Y   X  ID
	db $18,$F1,$00 ; $00
	db $1B,$F9,$02 ; $01
	db $1F,$01,$04 ; $02
	db $22,$09,$06 ; $03
	db $28,$F1,$08 ; $04
	db $2B,$F9,$0A ; $05
	db $2F,$01,$0C ; $06
	db $32,$09,$0E ; $07
	db $38,$F1,$10 ; $08
	db $3B,$F9,$12 ; $09
	db $3F,$01,$14 ; $0A
	db $42,$09,$16 ; $0B
		
OBJLstHdrA_Kyo_UraOrochiNagiD1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_22 ; iOBJLstHdrA_HitboxId
	dpr L1B7EA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $F8 ; iOBJLstHdrA_YOffset
.bin:
	db $0B ; OBJ Count
	;    Y   X  ID
	db $18,$F2,$00 ; $00
	db $18,$FA,$02 ; $01
	db $18,$02,$04 ; $02
	db $28,$F1,$06 ; $03
	db $28,$F9,$08 ; $04
	db $28,$01,$0A ; $05
	db $28,$09,$0C ; $06
	db $38,$F1,$0E ; $07
	db $38,$F9,$10 ; $08
	db $38,$01,$12 ; $09
	db $38,$09,$14 ; $0A
		

OBJLstPtrTable_Robert_Idle:
	dw OBJLstHdrA_Robert_Idle0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_Idle1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_Idle2_A, OBJLstHdrB_Robert_Idle2_B
	dw OBJLstHdrA_Robert_Idle1, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_WalkF:
	dw OBJLstHdrA_Robert_WalkF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_WalkF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_WalkF2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_WalkB:
	dw OBJLstHdrA_Robert_WalkF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_WalkF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_WalkF0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_Crouch:
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_JumpN:
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B
	dw OBJLstHdrA_Robert_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_JumpN3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_JumpN3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_JumpF:
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B ;X
	dw OBJLstHdrA_Robert_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_JumpF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_JumpF3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_JumpF4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_JumpF5, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_JumpB:
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B ;X
	dw OBJLstHdrA_Robert_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_JumpF5, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_JumpF4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_JumpF3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_JumpF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_BlockG:
	dw OBJLstHdrA_Robert_BlockG0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_BlockC:
	dw OBJLstHdrA_Robert_BlockC0_A, OBJLstHdrB_Robert_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_BlockA:
	dw OBJLstHdrA_Robert_BlockA0, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_RunF:
	dw OBJLstHdrA_Robert_RunF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_RunF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_RunF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_RunF1, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_HopB:
	dw OBJLstHdrA_Robert_HopB0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_HopB0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_ChargeMeter:
	dw OBJLstHdrA_Robert_ChargeMeter0_A, OBJLstHdrB_Robert_ChargeMeter0_B
	dw OBJLstHdrA_Robert_ChargeMeter1_A, OBJLstHdrB_Robert_ChargeMeter0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_Intro:
	dw OBJLstHdrA_Robert_Intro0_A, OBJLstHdrB_Robert_Intro0_B
	dw OBJLstHdrA_Robert_Intro1_A, OBJLstHdrB_Robert_Intro0_B
	dw OBJLstHdrA_Robert_Intro0_A, OBJLstHdrB_Robert_Intro0_B
	dw OBJLstHdrA_Robert_Intro1_A, OBJLstHdrB_Robert_Intro0_B
	dw OBJLstHdrA_Robert_Intro4_A, OBJLstHdrB_Robert_Intro0_B
	dw OBJLstHdrA_Robert_Intro5_A, OBJLstHdrB_Robert_Intro0_B
	dw OBJLstHdrA_Robert_Intro4_A, OBJLstHdrB_Robert_Intro0_B
	dw OBJLstHdrA_Robert_Intro5_A, OBJLstHdrB_Robert_Intro0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_Taunt:
	dw OBJLstHdrA_Robert_Taunt0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_Taunt1_A, OBJLstHdrB_Robert_Taunt1_B
	dw OBJLstHdrA_Robert_Taunt2_A, OBJLstHdrB_Robert_Taunt1_B
	dw OBJLstHdrA_Robert_Taunt1_A, OBJLstHdrB_Robert_Taunt1_B
	dw OBJLstHdrA_Robert_Taunt2_A, OBJLstHdrB_Robert_Taunt1_B
	dw OBJLstHdrA_Robert_Taunt0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_WinA:
	dw OBJLstHdrA_Robert_WinA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_WinA1_A, OBJLstHdrB_Robert_WinA1_B
	dw OBJLstHdrA_Robert_WinA2_A, OBJLstHdrB_Robert_WinA1_B
	dw OBJLstHdrA_Robert_WinA3_A, OBJLstHdrB_Robert_WinA1_B
	dw OBJLstHdrA_Robert_WinA2_A, OBJLstHdrB_Robert_WinA1_B
	dw OBJLstHdrA_Robert_WinA1_A, OBJLstHdrB_Robert_WinA1_B
	dw OBJLstHdrA_Robert_WinA6_A, OBJLstHdrB_Robert_WinA1_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_WinB:
	dw OBJLstHdrA_Robert_WinA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_WinA1_A, OBJLstHdrB_Robert_WinA1_B
	dw OBJLstHdrA_Robert_WinB2_A, OBJLstHdrB_Robert_WinA1_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_PunchL:
	dw OBJLstHdrA_Robert_PunchL0_A, OBJLstHdrB_Robert_PunchL0_B
	dw OBJLstHdrA_Robert_PunchL1_A, OBJLstHdrB_Robert_PunchL1_B
	dw OBJLstHdrA_Robert_PunchL0_A, OBJLstHdrB_Robert_PunchL0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_PunchH:
	dw OBJLstHdrA_Robert_PunchH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_PunchH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_PunchH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_PunchH0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_KickL:
	dw OBJLstHdrA_Robert_HopB0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_KickL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_HopB0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_KickH:
	dw OBJLstHdrA_Robert_KickH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_KickH1_A, OBJLstHdrB_Robert_KickH1_B
	dw OBJLstHdrA_Robert_KickH1_A, OBJLstHdrB_Robert_KickH1_B
	dw OBJLstHdrA_Robert_KickH3, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_PunchCL:
	dw OBJLstHdrA_Robert_PunchCL0_A, OBJLstHdrB_Robert_PunchCL0_B
	dw OBJLstHdrA_Robert_PunchCL1_A, OBJLstHdrB_Robert_PunchCL1_B
	dw OBJLstHdrA_Robert_PunchCL0_A, OBJLstHdrB_Robert_PunchCL0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_PunchCH:
	dw OBJLstHdrA_Robert_PunchCH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_PunchCH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_PunchCH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_PunchCH0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_KickCL:
	dw OBJLstHdrA_Robert_KickCL0_A, OBJLstHdrB_Robert_KickCL0_B
	dw OBJLstHdrA_Robert_KickCL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_KickCL0_A, OBJLstHdrB_Robert_KickCL0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_KickCH:
	dw OBJLstHdrA_Robert_KickCH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_KickCH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_KickCH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_KickCH3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_PunchA:
	dw OBJLstHdrA_Robert_PunchA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_PunchA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_JumpN3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_KickA:
	dw OBJLstHdrA_Robert_KickA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_KickA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_JumpN3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_AttackA:
	dw OBJLstHdrA_Robert_AttackA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_AttackA1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_JumpF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_AttackG:
	dw OBJLstHdrA_Robert_AttackG0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_AttackG1_A, OBJLstHdrB_Robert_AttackG1_B
	dw OBJLstHdrA_Robert_AttackG1_A, OBJLstHdrB_Robert_AttackG1_B
	dw OBJLstHdrA_Robert_AttackG3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_RollF:
	dw OBJLstHdrA_Robert_RollF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_RollF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_RollF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_RollF3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_RollB:
	dw OBJLstHdrA_Robert_RollF3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_RollF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_RollF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_RollF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_GuardBreakG:
	dw OBJLstHdrA_Robert_GuardBreakG0_A, OBJLstHdrB_Robert_GuardBreakG0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_Dizzy:
	dw OBJLstHdrA_Robert_Idle0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_GuardBreakG0_A, OBJLstHdrB_Robert_GuardBreakG0_B ;X
OBJLstPtrTable_Robert_TimeOver:
	dw OBJLstHdrA_Robert_TimeOver2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_Hitlow:
	dw OBJLstHdrA_Robert_Hitlow0_A, OBJLstHdrB_Robert_Hitlow0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_GuardBreakA:
	dw OBJLstHdrA_Robert_GuardBreakG0_A, OBJLstHdrB_Robert_GuardBreakG0_B ;X
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_BackjumpRecA:
	dw OBJLstHdrA_Robert_GuardBreakG0_A, OBJLstHdrB_Robert_GuardBreakG0_B
	dw OBJLstHdrA_Robert_JumpF5, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_JumpF4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_JumpF3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_JumpF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_DropMain:
	dw OBJLstHdrA_Robert_GuardBreakG0_A, OBJLstHdrB_Robert_GuardBreakG0_B
	dw OBJLstHdrA_Robert_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_DropMain2, OBJLSTPTR_NONE
OBJLstPtrTable_Robert_HitMultigs:
	dw OBJLstHdrA_Robert_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_DropMain2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_HitSwoopup:
	dw OBJLstHdrA_Robert_TimeOver2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_HitSwoopup1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_HitSwoopup2, OBJLSTPTR_NONE
OBJLstPtrTable_Robert_ThrowEndA:
	dw OBJLstHdrA_Robert_ThrowEndA3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_ThrowEndA3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_DropMain2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_DropDbg:
	dw OBJLstHdrA_Robert_TimeOver2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_DropMain2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_ThrowRotL:
	dw OBJLstHdrA_Robert_ThrowRotL0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_Wakeup:
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_RyuuGekiKenL:
	dw OBJLstHdrA_Robert_RyuuGekiKenL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_RyuuGekiKenL1_A, OBJLstHdrB_Robert_RyuuGekiKenL1_B
	dw OBJLstHdrA_Robert_RyuuGekiKenL2_A, OBJLstHdrB_Robert_RyuuGekiKenL1_B
	dw OBJLstHdrA_Robert_RyuuGekiKenL1_A, OBJLstHdrB_Robert_RyuuGekiKenL1_B
	dw OBJLstHdrA_Robert_RyuuGekiKenL2_A, OBJLstHdrB_Robert_RyuuGekiKenL1_B
	dw OBJLstHdrA_Robert_RyuuGekiKenL1_A, OBJLstHdrB_Robert_RyuuGekiKenL1_B
	dw OBJLstHdrA_Robert_RyuuGekiKenL2_A, OBJLstHdrB_Robert_RyuuGekiKenL1_B
	dw OBJLstHdrA_Robert_RyuuGekiKenL7_A, OBJLstHdrB_Robert_RyuuGekiKenL1_B
	dw OBJLstHdrA_Robert_RyuuGekiKenL8_A, OBJLstHdrB_Robert_RyuuGekiKenL1_B
	dw OBJLstHdrA_Robert_PunchL0_A, OBJLstHdrB_Robert_PunchL0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_HienShippuKyakuL:
	dw OBJLstHdrA_Robert_AttackG0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_AttackG1_A, OBJLstHdrB_Robert_AttackG1_B
	dw OBJLstHdrA_Robert_AttackG3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_HienShippuKyakuL3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_AttackG0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_AttackG1_A, OBJLstHdrB_Robert_AttackG1_B
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_HienRyuuShinKyaL:
	dw OBJLstHdrA_Robert_JumpN3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_KickA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B
	dw OBJLstHdrA_Robert_JumpN1, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Robert_JumpF5, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Robert_JumpF4, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Robert_JumpF3, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Robert_JumpF2, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Robert_JumpN1, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_RyuuGaL:
	dw OBJLstHdrA_Robert_PunchH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_PunchH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_RyuuGaL2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_RyuuGaL3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_RyuuGaHiddenL:
	dw OBJLstHdrA_Robert_PunchH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_RyuuGaL2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_RyuuGaHiddenL2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_RyuuGaHiddenL3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_RyuuGaL2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_RyuuGaL3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_KyokugenRyuRanbuKyakuL:
	dw OBJLstHdrA_Robert_KyokugenRyuRanbuKyakuL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_KickH3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_KyokugenRyuRanbuKyakuL2_A, OBJLstHdrB_Robert_KickH1_B
	dw OBJLstHdrA_Robert_KickH3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_KyokugenRyuRanbuKyakuL2_A, OBJLstHdrB_Robert_KickH1_B
	dw OBJLstHdrA_Robert_KyokugenRyuRanbuKyakuL5, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_KyokugenRyuRanbuKyakuL6, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_KyokugenRyuRanbuKyakuL5, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_RyuKoRanbuS:
	dw OBJLstHdrA_Robert_RyuKoRanbuS0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_RyuKoRanbuS1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_PunchL1_A, OBJLstHdrB_Robert_PunchL1_B
	dw OBJLstHdrA_Robert_PunchH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_PunchH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_PunchL1_A, OBJLstHdrB_Robert_PunchL1_B
	dw OBJLstHdrA_Robert_KickL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_KickH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_KyokugenRyuRanbuKyakuL2_A, OBJLstHdrB_Robert_KickH1_B
	dw OBJLstHdrA_Robert_AttackG0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_AttackG1_A, OBJLstHdrB_Robert_AttackG1_B
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B
	dw OBJLstHdrA_Robert_PunchCH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B
	dw OBJLstHdrA_Robert_KickL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_KickH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_KickH1_A, OBJLstHdrB_Robert_KickH1_B
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_RyuKoRanbuD:
	dw OBJLstHdrA_Robert_RyuKoRanbuS0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_RyuKoRanbuS1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_PunchL1_A, OBJLstHdrB_Robert_PunchL1_B
	dw OBJLstHdrA_Robert_PunchH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_PunchH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_PunchL1_A, OBJLstHdrB_Robert_PunchL1_B
	dw OBJLstHdrA_Robert_KickL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_KickH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_KyokugenRyuRanbuKyakuL2_A, OBJLstHdrB_Robert_KickH1_B
	dw OBJLstHdrA_Robert_AttackG0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_AttackG1_A, OBJLstHdrB_Robert_AttackG1_B
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B
	dw OBJLstHdrA_Robert_PunchCH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B
	dw OBJLstHdrA_Robert_KickL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_KickH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_KickH1_A, OBJLstHdrB_Robert_KickH1_B
	dw OBJLstHdrA_Robert_PunchL1_A, OBJLstHdrB_Robert_PunchL1_B
	dw OBJLstHdrA_Robert_KickL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_KickH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_KyokugenRyuRanbuKyakuL2_A, OBJLstHdrB_Robert_KickH1_B
	dw OBJLstHdrA_Robert_AttackG0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_AttackG1_A, OBJLstHdrB_Robert_AttackG1_B
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B
	dw OBJLstHdrA_Robert_PunchCH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B
	dw OBJLstHdrA_Robert_KickL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_KickH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_KickH1_A, OBJLstHdrB_Robert_KickH1_B
	dw OBJLstHdrA_Robert_PunchH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_PunchH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_RyuuGaL2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_RyuuGaL3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_HaohShokohKenS:
	dw OBJLstHdrA_Robert_RyuKoRanbuS0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_RyuuGekiKenL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_HaohShokohKenS2_A, OBJLstHdrB_Robert_HaohShokohKenS2_B
	dw OBJLstHdrA_Robert_HaohShokohKenS3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_PunchL0_A, OBJLstHdrB_Robert_PunchL0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Robert_ThrowG:
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B
	dw OBJLstHdrA_Robert_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_AttackA1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Robert_JumpF3, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Robert_JumpF2, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Robert_JumpN1, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Robert_Crouch0_A, OBJLstHdrB_Robert_Crouch0_B ;X
	dw OBJLSTPTR_NONE
		
OBJLstHdrA_Robert_Idle0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L104000 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $25,$F3,$00 ; $00
	db $20,$FB,$02 ; $01
	db $20,$03,$04 ; $02
	db $30,$FA,$06 ; $03
	db $30,$02,$08 ; $04
		
OBJLstHdrA_Robert_Idle1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1040A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $23,$F3,$00 ; $00
	db $20,$03,$02 ; $01
	db $2B,$FB,$04 ; $02
	db $30,$02,$06 ; $03
	db $1B,$FB,$08 ; $04
	db $3B,$F7,$0A ; $05
		
OBJLstHdrA_Robert_Idle2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L104160 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $20,$F9,$00 ; $00
	db $20,$01,$02 ; $01
	db $1C,$09,$04 ; $02
		
OBJLstHdrA_Robert_KickCL0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L104160 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Robert_Idle2_A.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Robert_Idle2_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1041C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $30,$F9,$00 ; $00
	db $30,$01,$02 ; $01
		
OBJLstHdrA_Robert_WalkF0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L104200 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $06 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1F,$F0,$00 ; $00
	db $1E,$F8,$02 ; $01
	db $1C,$00,$04 ; $02
	db $2F,$F0,$06 ; $03
	db $2E,$F8,$08 ; $04
	db $3E,$F8,$0A ; $05
		
OBJLstHdrA_Robert_WalkF1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1042C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $05 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $23,$EB,$00 ; $00
	db $20,$F3,$02 ; $01
	db $21,$FB,$04 ; $02
	db $30,$F3,$06 ; $03
	db $31,$FB,$08 ; $04
		
OBJLstHdrA_Robert_WalkF2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L104360 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $05 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $21,$EB,$00 ; $00
	db $19,$F3,$02 ; $01
	db $20,$FB,$04 ; $02
	db $29,$F3,$06 ; $03
	db $30,$FB,$08 ; $04
		
OBJLstHdrA_Robert_Crouch0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L104400 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $06 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $26,$EC,$00 ; $00
	db $28,$F4,$02 ; $01
	db $28,$FC,$04 ; $02
	db $18,$F4,$06 ; $03
		
OBJLstHdrB_Robert_Crouch0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L104480 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $06 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $38,$F3,$00 ; $00
	db $38,$FB,$02 ; $01
		
OBJLstHdrA_Robert_BlockG0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L104800 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $06 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $20,$F2,$00 ; $00
	db $20,$FA,$02 ; $01
	db $38,$EC,$04 ; $02
	db $30,$F4,$06 ; $03
	db $30,$FC,$08 ; $04
		
OBJLstHdrA_Robert_BlockC0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1048A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $06 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $28,$F3,$00 ; $00
	db $28,$FB,$02 ; $01
	db $18,$FB,$04 ; $02
		
OBJLstHdrA_Robert_BlockA0: ;X
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L104900 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $19 ; iOBJLstHdrA_YOffset
.bin: ;X
	db $05 ; OBJ Count
	;    Y   X  ID
	db $08,$EE,$00 ; $00
	db $08,$F6,$02 ; $01
	db $08,$FE,$04 ; $02
	db $18,$F6,$06 ; $03
	db $18,$FE,$08 ; $04
		
OBJLstHdrA_Robert_JumpN1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L104580 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $14,$EC,$00 ; $00
	db $18,$F4,$02 ; $01
	db $18,$FC,$04 ; $02
	db $28,$F4,$06 ; $03
	db $28,$FC,$08 ; $04
	db $38,$F4,$0A ; $05
	db $38,$FC,$0C ; $06
		
OBJLstHdrA_Robert_JumpN3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L104660 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $07 ; iOBJLstHdrA_XOffset
	db $18 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $09,$EC,$00 ; $00
	db $01,$F4,$02 ; $01
	db $02,$FC,$04 ; $02
	db $19,$EC,$06 ; $03
	db $11,$F4,$08 ; $04
	db $12,$FC,$0A ; $05
		
OBJLstHdrA_Robert_JumpF2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L104720 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $09 ; iOBJLstHdrA_XOffset
	db $19 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $0C,$EC,$00 ; $00
	db $0C,$F4,$02 ; $01
	db $0C,$FC,$04 ; $02
		
OBJLstHdrA_Robert_RollF1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L104720 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Robert_JumpF2.bin ; iOBJLstHdrA_DataPtr
	db $09 ; iOBJLstHdrA_XOffset
	db $22 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Robert_JumpF4:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L104720 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Robert_JumpF2.bin ; iOBJLstHdrA_DataPtr
	db $F7 ; iOBJLstHdrA_XOffset
	db $E1 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Robert_RollF3:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L104720 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Robert_JumpF2.bin ; iOBJLstHdrA_DataPtr
	db $F7 ; iOBJLstHdrA_XOffset
	db $EC ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Robert_JumpF3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L104780 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $08 ; iOBJLstHdrA_XOffset
	db $17 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $08,$F0,$00 ; $00
	db $08,$F8,$02 ; $01
	db $18,$F0,$04 ; $02
	db $18,$F8,$06 ; $03
		
OBJLstHdrA_Robert_RollF2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L104780 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Robert_JumpF3.bin ; iOBJLstHdrA_DataPtr
	db $08 ; iOBJLstHdrA_XOffset
	db $20 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Robert_JumpF5:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L104780 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Robert_JumpF3.bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $E2 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Robert_RyuKoRanbuS0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L105E80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FF ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1F,$F5,$00 ; $00
	db $1F,$FD,$02 ; $01
	db $20,$05,$04 ; $02
	db $34,$F5,$06 ; $03
	db $2F,$FD,$08 ; $04
	db $33,$05,$0A ; $05
		
OBJLstHdrA_Robert_ChargeMeter0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L105F40 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $28,$F4,$00 ; $00
	db $28,$FC,$02 ; $01
	db $28,$04,$04 ; $02
	db $28,$0C,$06 ; $03
	db $18,$FC,$08 ; $04
	db $18,$04,$0A ; $05
		
OBJLstHdrB_Robert_ChargeMeter0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L106000 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $38,$F7,$00 ; $00
	db $38,$FF,$02 ; $01
	db $38,$07,$04 ; $02
		
OBJLstHdrA_Robert_ChargeMeter1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L106060 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $28,$F3,$00 ; $00
	db $28,$FB,$02 ; $01
	db $28,$03,$04 ; $02
	db $24,$0B,$06 ; $03
	db $18,$FB,$08 ; $04
	db $18,$03,$0A ; $05
		
OBJLstHdrA_Robert_Taunt0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L106340 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1F,$F8,$00 ; $00
	db $1E,$00,$02 ; $01
	db $2F,$F8,$04 ; $02
	db $2E,$00,$06 ; $03
	db $1F,$08,$08 ; $04
	db $3F,$F8,$0A ; $05
	db $3E,$00,$0C ; $06
		
OBJLstHdrA_Robert_Taunt1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L106420 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $18,$F1,$00 ; $00
	db $18,$F9,$02 ; $01
	db $18,$01,$04 ; $02
		
OBJLstHdrB_Robert_Taunt1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L106480 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $28,$F4,$00 ; $00
	db $28,$FC,$02 ; $01
	db $28,$04,$04 ; $02
	db $38,$F7,$06 ; $03
	db $38,$FF,$08 ; $04
		
OBJLstHdrA_Robert_Taunt2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L106520 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $18,$F1,$00 ; $00
	db $18,$F9,$02 ; $01
	db $18,$01,$04 ; $02
		
OBJLstHdrA_Robert_WinA0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L106580 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1F,$F4,$00 ; $00
	db $1E,$FC,$02 ; $01
	db $25,$04,$04 ; $02
	db $2F,$F4,$06 ; $03
	db $2E,$FC,$08 ; $04
	db $3F,$F4,$0A ; $05
	db $3E,$FC,$0C ; $06
		
OBJLstHdrA_Robert_WinA1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L106660 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrB_Robert_WinA1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1066E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$F7,$00 ; $00
	db $30,$FF,$02 ; $01
	db $3E,$07,$04 ; $02
		
OBJLstHdrA_Robert_WinA2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L106740 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $20,$F4,$00 ; $00
	db $20,$FC,$02 ; $01
	db $24,$04,$04 ; $02
	db $18,$0C,$06 ; $03
	db $10,$FA,$08 ; $04
		
OBJLstHdrA_Robert_WinA3_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1067E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $20,$F4,$00 ; $00
	db $20,$FC,$02 ; $01
	db $24,$04,$04 ; $02
	db $18,$0C,$06 ; $03
	db $10,$F9,$08 ; $04
		
OBJLstHdrA_Robert_WinA6_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L106880 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$F4,$00 ; $00
	db $20,$FC,$02 ; $01
	db $20,$04,$04 ; $02
	db $10,$F9,$06 ; $03
		
OBJLstHdrA_Robert_WinB2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L106900 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$F2,$00 ; $00
	db $20,$FA,$02 ; $01
	db $1B,$02,$04 ; $02
	db $10,$FA,$06 ; $03
		
OBJLstHdrA_Robert_Intro0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L106120 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$FD,$00 ; $00
	db $20,$05,$02 ; $01
	db $10,$FD,$04 ; $02
	db $20,$F5,$06 ; $03
		
OBJLstHdrB_Robert_Intro0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1061A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $30,$FC,$00 ; $00
	db $30,$04,$02 ; $01
		
OBJLstHdrA_Robert_Intro1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1061E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$F5,$00 ; $00
	db $20,$FD,$02 ; $01
	db $20,$05,$04 ; $02
	db $10,$FD,$06 ; $03
		
OBJLstHdrA_Robert_Intro4_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L106260 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $20,$FA,$00 ; $00
	db $20,$02,$02 ; $01
	db $10,$FC,$04 ; $02
		
OBJLstHdrA_Robert_Intro5_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1062C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$FA,$00 ; $00
	db $20,$02,$02 ; $01
	db $10,$FC,$04 ; $02
	db $10,$08,$06 ; $03
		
OBJLstHdrA_Robert_PunchL1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L1049A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $1E,$F4,$00 ; $00
	db $18,$FC,$02 ; $01
	db $20,$04,$04 ; $02
	db $20,$0C,$06 ; $03
		
OBJLstHdrA_Robert_PunchCL1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L1049A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Robert_PunchL1_A.bin ; iOBJLstHdrA_DataPtr
	db $F7 ; iOBJLstHdrA_XOffset
	db $05 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Robert_PunchL1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L104A20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $28,$FC,$00 ; $00
	db $30,$04,$02 ; $01
	db $30,$0C,$04 ; $02
	db $38,$FC,$06 ; $03
		
OBJLstHdrA_Robert_PunchL0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L104AA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $18,$02,$00 ; $00
	db $20,$0A,$02 ; $01
		
OBJLstHdrA_Robert_PunchCL0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L104AA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Robert_PunchL0_A.bin ; iOBJLstHdrA_DataPtr
	db $F7 ; iOBJLstHdrA_XOffset
	db $06 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Robert_PunchL0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L104AE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $28,$FC,$00 ; $00
	db $28,$04,$02 ; $01
	db $30,$07,$04 ; $02
	db $38,$FF,$06 ; $03
		
OBJLstHdrA_Robert_PunchH0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L104B60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $2A,$EC,$00 ; $00
	db $24,$F4,$02 ; $01
	db $26,$FC,$04 ; $02
	db $34,$F4,$06 ; $03
	db $36,$FC,$08 ; $04
	db $3C,$04,$0A ; $05
		
OBJLstHdrA_Robert_PunchH1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L104C20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $29,$EC,$00 ; $00
	db $23,$F4,$02 ; $01
	db $25,$FC,$04 ; $02
	db $1E,$04,$06 ; $03
	db $33,$F4,$08 ; $04
	db $35,$FC,$0A ; $05
	db $3B,$04,$0C ; $06
		
OBJLstHdrA_Robert_KickL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_5C ; iOBJLstHdrA_HitboxId
	dpr L104D00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $33,$F4,$00 ; $00
	db $29,$FC,$02 ; $01
	db $21,$04,$04 ; $02
	db $12,$0C,$06 ; $03
	db $31,$04,$08 ; $04
	db $22,$0C,$0A ; $05
		
OBJLstHdrA_Robert_HopB0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L104DC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $23,$FC,$00 ; $00
	db $20,$04,$02 ; $01
	db $20,$0C,$04 ; $02
	db $33,$FC,$06 ; $03
	db $30,$04,$08 ; $04
		
OBJLstHdrA_Robert_KickH0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L104E60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1E,$FC,$00 ; $00
	db $20,$04,$02 ; $01
	db $1F,$0C,$04 ; $02
	db $32,$FC,$06 ; $03
	db $30,$04,$08 ; $04
	db $35,$0C,$0A ; $05
		
OBJLstHdrA_Robert_KickH1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_50 ; iOBJLstHdrA_HitboxId
	dpr L104F20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $31,$E4,$00 ; $00
	db $25,$EC,$02 ; $01
	db $24,$F4,$04 ; $02
	db $20,$FC,$06 ; $03
	db $20,$04,$08 ; $04
	db $10,$FC,$0A ; $05
		
OBJLstHdrA_Robert_AttackG1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L104F20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Robert_KickH1_A.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $03 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Robert_KickH1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L104FE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $30,$FC,$00 ; $00
	db $30,$04,$02 ; $01
		
OBJLstHdrA_Robert_KickH3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L105020 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $20,$FC,$00 ; $00
	db $1F,$04,$02 ; $01
	db $2A,$0C,$04 ; $02
	db $30,$FC,$06 ; $03
	db $2F,$04,$08 ; $04
		
OBJLstHdrB_Robert_PunchCL1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1050C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $2D,$F4,$00 ; $00
	db $2D,$FC,$02 ; $01
	db $35,$04,$04 ; $02
	db $3D,$F8,$06 ; $03
		
OBJLstHdrB_Robert_PunchCL0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L105140 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $2E,$F7,$00 ; $00
	db $2E,$FF,$02 ; $01
	db $36,$05,$04 ; $02
	db $3E,$F8,$06 ; $03
		
OBJLstHdrA_Robert_PunchCH0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1051C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $21,$EE,$00 ; $00
	db $22,$F6,$02 ; $01
	db $23,$FE,$04 ; $02
	db $24,$06,$06 ; $03
	db $34,$F6,$08 ; $04
	db $33,$FE,$0A ; $05
	db $35,$06,$0C ; $06
		
OBJLstHdrA_Robert_PunchCH1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_5D ; iOBJLstHdrA_HitboxId
	dpr L1052A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $10,$FC,$00 ; $00
	db $1A,$F4,$02 ; $01
	db $20,$03,$04 ; $02
	db $20,$FB,$06 ; $03
	db $30,$04,$08 ; $04
	db $30,$FC,$0A ; $05
	db $2A,$0B,$0C ; $06
		
OBJLstHdrA_Robert_KickCL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_56 ; iOBJLstHdrA_HitboxId
	dpr L105380 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $3A,$EC,$00 ; $00
	db $31,$F4,$02 ; $01
	db $2B,$FC,$04 ; $02
	db $2D,$04,$06 ; $03
	db $24,$0C,$08 ; $04
	db $3B,$FC,$0A ; $05
	db $3D,$04,$0C ; $06
		
OBJLstHdrB_Robert_KickCL0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L105460 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $3A,$F2,$00 ; $00
	db $38,$FA,$02 ; $01
	db $38,$02,$04 ; $02
		
OBJLstHdrA_Robert_KickCH0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1054C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $24,$F4,$00 ; $00
	db $25,$FC,$02 ; $01
	db $2A,$04,$04 ; $02
	db $34,$F4,$06 ; $03
	db $35,$FC,$08 ; $04
		
OBJLstHdrA_Robert_KickCH1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_5E ; iOBJLstHdrA_HitboxId
	dpr L105560 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $02 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $3A,$E4,$00 ; $00
	db $38,$EC,$02 ; $01
	db $29,$F4,$04 ; $02
	db $25,$FC,$06 ; $03
	db $24,$04,$08 ; $04
	db $39,$F4,$0A ; $05
	db $35,$FC,$0C ; $06
	db $34,$04,$0E ; $07
		
OBJLstHdrA_Robert_KickCH3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L105660 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $27,$F5,$00 ; $00
	db $27,$FD,$02 ; $01
	db $26,$05,$04 ; $02
	db $37,$F7,$06 ; $03
	db $37,$FF,$08 ; $04
		
OBJLstHdrA_Robert_PunchA0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L105700 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $18 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $13,$EC,$00 ; $00
	db $03,$F4,$02 ; $01
	db $03,$FC,$04 ; $02
	db $13,$F4,$06 ; $03
	db $13,$FC,$08 ; $04
	db $04,$04,$0A ; $05
		
OBJLstHdrA_Robert_KickA0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L1057C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $06 ; iOBJLstHdrA_XOffset
	db $06 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $17,$EB,$00 ; $00
	db $17,$F3,$02 ; $01
	db $13,$FB,$04 ; $02
	db $2D,$E7,$06 ; $03
	db $27,$EF,$08 ; $04
	db $23,$F7,$0A ; $05
	db $23,$FF,$0C ; $06
		
OBJLstHdrA_Robert_AttackG0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1058A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F6 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $21,$FE,$00 ; $00
	db $23,$06,$02 ; $01
	db $1C,$0E,$04 ; $02
	db $33,$06,$06 ; $03
	db $31,$0E,$08 ; $04
		
OBJLstHdrB_Robert_AttackG1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L105940 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $03 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $30,$FC,$00 ; $00
	db $30,$04,$02 ; $01
		
OBJLstHdrA_Robert_AttackG3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L105980 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $20,$F4,$00 ; $00
	db $20,$FC,$02 ; $01
	db $14,$04,$04 ; $02
	db $35,$EC,$06 ; $03
	db $30,$F4,$08 ; $04
	db $30,$FC,$0A ; $05
	db $24,$04,$0C ; $06
		
OBJLstHdrA_Robert_AttackA0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L105A60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $12 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $10,$E6,$00 ; $00
	db $1A,$EE,$02 ; $01
	db $12,$F6,$04 ; $02
	db $12,$FE,$06 ; $03
	db $15,$05,$08 ; $04
	db $02,$FE,$0A ; $05
		
OBJLstHdrA_Robert_RollF0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1044C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $29,$F3,$00 ; $00
	db $28,$FB,$02 ; $01
	db $27,$03,$04 ; $02
	db $22,$0B,$06 ; $03
	db $39,$F3,$08 ; $04
	db $38,$FB,$0A ; $05
		
OBJLstHdrA_Robert_TimeOver2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L105B20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1F,$F4,$00 ; $00
	db $21,$FC,$02 ; $01
	db $21,$04,$04 ; $02
	db $36,$F4,$06 ; $03
	db $31,$FC,$08 ; $04
	db $31,$04,$0A ; $05
		
OBJLstHdrA_Robert_HitSwoopup1:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L105B20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Robert_TimeOver2.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Robert_HitSwoopup2:
	db OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L105B20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Robert_TimeOver2.bin ; iOBJLstHdrA_DataPtr
	db $FB ; iOBJLstHdrA_XOffset
	db $02 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Robert_ThrowEndA3:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L105B20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Robert_TimeOver2.bin ; iOBJLstHdrA_DataPtr
	db $05 ; iOBJLstHdrA_XOffset
	db $02 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Robert_GuardBreakG0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L105BE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $07 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $20,$F1,$00 ; $00
	db $20,$F9,$02 ; $01
	db $20,$01,$04 ; $02
		
OBJLstHdrA_Robert_Hitlow0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L105BE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Robert_GuardBreakG0_A.bin ; iOBJLstHdrA_DataPtr
	db $08 ; iOBJLstHdrA_XOffset
	db $05 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Robert_GuardBreakG0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L105C40 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $07 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $32,$EE,$00 ; $00
	db $30,$F6,$02 ; $01
	db $30,$FE,$04 ; $02
		
OBJLstHdrB_Robert_Hitlow0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L105CA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $35,$F9,$00 ; $00
	db $35,$01,$02 ; $01
	db $35,$09,$04 ; $02
		
OBJLstHdrA_Robert_DropMain1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L105D00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $05 ; iOBJLstHdrA_XOffset
	db $22 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $09,$E9,$00 ; $00
	db $0B,$F1,$02 ; $01
	db $09,$F9,$04 ; $02
	db $0F,$01,$06 ; $03
	db $08,$09,$08 ; $04
	db $19,$F4,$0A ; $05
	db $19,$FC,$0C ; $06
		
OBJLstHdrA_Robert_ThrowRotL0:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L105D00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Robert_DropMain1.bin ; iOBJLstHdrA_DataPtr
	db $FD ; iOBJLstHdrA_XOffset
	db $EE ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Robert_DropMain2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L105DE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $09 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $31,$EC,$00 ; $00
	db $2B,$F4,$02 ; $01
	db $2D,$FC,$04 ; $02
	db $2E,$04,$06 ; $03
	db $2F,$0C,$08 ; $04
		
OBJLstHdrA_Robert_RunF0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L106A40 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $25,$F1,$00 ; $00
	db $24,$F9,$02 ; $01
	db $24,$01,$04 ; $02
	db $34,$F9,$06 ; $03
	db $34,$01,$08 ; $04
	db $34,$09,$0A ; $05
		
OBJLstHdrA_Robert_RunF1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L106B00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $21,$F2,$00 ; $00
	db $26,$FA,$02 ; $01
	db $27,$02,$04 ; $02
	db $36,$FA,$06 ; $03
	db $37,$02,$08 ; $04
		
OBJLstHdrA_Robert_KyokugenRyuRanbuKyakuL5:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L106B00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Robert_RunF1.bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Robert_RunF2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L106BA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $25,$F3,$00 ; $00
	db $1D,$FB,$02 ; $01
	db $26,$03,$04 ; $02
	db $2D,$FB,$06 ; $03
	db $36,$03,$08 ; $04
	db $35,$0B,$0A ; $05
		
OBJLstHdrA_Robert_AttackA1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L106980 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $05 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $20,$EC,$00 ; $00
	db $20,$F4,$02 ; $01
	db $20,$FC,$04 ; $02
	db $18,$04,$06 ; $03
	db $30,$FC,$08 ; $04
	db $28,$04,$0A ; $05
		
OBJLstHdrA_Robert_RyuuGekiKenL0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L106C60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $21,$F5,$00 ; $00
	db $22,$FD,$02 ; $01
	db $1F,$05,$04 ; $02
	db $1F,$0D,$06 ; $03
	db $1C,$15,$08 ; $04
	db $32,$FD,$0A ; $05
	db $2F,$05,$0C ; $06
	db $36,$0C,$0E ; $07
		
OBJLstHdrB_Robert_HaohShokohKenS2_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L106D60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $3A,$F9,$00 ; $00
	db $38,$01,$02 ; $01
	db $38,$09,$04 ; $02
		
OBJLstHdrA_Robert_RyuuGekiKenL1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_2C ; iOBJLstHdrA_HitboxId
	dpr L106DC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1F,$E4,$00 ; $00
	db $1C,$EC,$02 ; $01
	db $1C,$F4,$04 ; $02
	db $2F,$E4,$06 ; $03
	db $2C,$EC,$08 ; $04
	db $2C,$F4,$0A ; $05
	db $20,$FC,$0C ; $06
		
OBJLstHdrB_Robert_RyuuGekiKenL1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L106EA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $18,$FC,$00 ; $00
	db $25,$04,$02 ; $01
	db $35,$04,$04 ; $02
	db $30,$FC,$06 ; $03
	db $38,$0C,$08 ; $04
		
OBJLstHdrA_Robert_RyuuGekiKenL2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_2C ; iOBJLstHdrA_HitboxId
	dpr L106F40 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $1A,$E4,$00 ; $00
	db $19,$EC,$02 ; $01
	db $18,$F4,$04 ; $02
	db $2A,$E4,$06 ; $03
	db $29,$EC,$08 ; $04
	db $28,$F4,$0A ; $05
	db $28,$FC,$0C ; $06
	db $39,$EC,$0E ; $07
		
OBJLstHdrA_Robert_RyuuGekiKenL7_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L107040 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $1A,$E5,$00 ; $00
	db $14,$ED,$02 ; $01
	db $1F,$F5,$04 ; $02
	db $2A,$E5,$06 ; $03
	db $24,$ED,$08 ; $04
	db $2F,$F5,$0A ; $05
	db $28,$FD,$0C ; $06
	db $34,$ED,$0E ; $07
		
OBJLstHdrA_Robert_RyuuGekiKenL8_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L107140 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $18,$E4,$00 ; $00
	db $18,$EC,$02 ; $01
	db $18,$F4,$04 ; $02
	db $28,$E4,$06 ; $03
	db $28,$EC,$08 ; $04
	db $28,$F4,$0A ; $05
	db $28,$FC,$0C ; $06
		
OBJLstHdrA_Robert_HienShippuKyakuL3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L107220 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $0A ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $2B,$E4,$00 ; $00
	db $1F,$EC,$02 ; $01
	db $1B,$F4,$04 ; $02
	db $18,$FC,$06 ; $03
	db $16,$04,$08 ; $04
	db $2B,$F4,$0A ; $05
	db $28,$FC,$0C ; $06
		
OBJLstHdrA_Robert_RyuuGaL2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_2D ; iOBJLstHdrA_HitboxId
	dpr L107300 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FF ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $08,$FD,$00 ; $00
	db $13,$FA,$02 ; $01
	db $18,$02,$04 ; $02
	db $18,$0A,$06 ; $03
	db $23,$FA,$08 ; $04
	db $28,$01,$0A ; $05
		
OBJLstHdrA_Robert_RyuuGaL3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1073C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $02 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $13,$F2,$00 ; $00
	db $1C,$FA,$02 ; $01
	db $17,$02,$04 ; $02
	db $23,$F5,$06 ; $03
	db $33,$F4,$08 ; $04
	db $2C,$FD,$0A ; $05
		
OBJLstHdrA_Robert_KyokugenRyuRanbuKyakuL0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L107480 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $1D,$F9,$00 ; $00
	db $1D,$01,$02 ; $01
	db $2D,$F8,$04 ; $02
	db $2D,$00,$06 ; $03
	db $3D,$01,$08 ; $04
		
OBJLstHdrA_Robert_KyokugenRyuRanbuKyakuL2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L107520 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $30,$EC,$00 ; $00
	db $24,$F4,$02 ; $01
	db $34,$F4,$04 ; $02
	db $20,$FC,$06 ; $03
	db $20,$04,$08 ; $04
	db $10,$FC,$0A ; $05
		
OBJLstHdrA_Robert_KyokugenRyuRanbuKyakuL6:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L1075E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1E,$E8,$00 ; $00
	db $29,$F0,$02 ; $01
	db $27,$F8,$04 ; $02
	db $24,$00,$06 ; $03
	db $37,$F8,$08 ; $04
	db $34,$00,$0A ; $05
	db $1F,$08,$0C ; $06
		
OBJLstHdrA_Robert_RyuKoRanbuS1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L1076C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $2A,$F1,$00 ; $00
	db $22,$F9,$02 ; $01
	db $22,$01,$04 ; $02
	db $1F,$09,$06 ; $03
	db $32,$F9,$08 ; $04
	db $32,$01,$0A ; $05
	db $36,$09,$0C ; $06
		
OBJLstHdrA_Robert_RyuuGaHiddenL3:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_2D ; iOBJLstHdrA_HitboxId
	dpr L1077A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1B,$F7,$00 ; $00
	db $10,$FF,$02 ; $01
	db $2B,$F7,$04 ; $02
	db $20,$FF,$06 ; $03
	db $30,$FF,$08 ; $04
	db $2A,$07,$0A ; $05
		
OBJLstHdrA_Robert_RyuuGaHiddenL2:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_2D ; iOBJLstHdrA_HitboxId
	dpr L107860 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $14,$F9,$00 ; $00
	db $11,$01,$02 ; $01
	db $24,$F9,$04 ; $02
	db $21,$01,$06 ; $03
	db $1A,$09,$08 ; $04
	db $31,$01,$0A ; $05
		
OBJLstHdrA_Robert_HaohShokohKenS2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L107920 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $23,$F7,$00 ; $00
	db $28,$FA,$02 ; $01
	db $28,$02,$04 ; $02
	db $18,$FF,$06 ; $03
		
OBJLstHdrA_Robert_HaohShokohKenS3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1079A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $18,$EB,$00 ; $00
	db $24,$F3,$02 ; $01
	db $23,$FB,$04 ; $02
	db $28,$EB,$06 ; $03
	db $34,$F3,$08 ; $04
	db $33,$FB,$0A ; $05
	db $37,$03,$0C ; $06
	db $17,$E3,$0E ; $07
		

OBJLstPtrTable_Geese_Idle:
	dw OBJLstHdrA_Geese_Idle0_A, OBJLstHdrB_Geese_Idle0_B
	dw OBJLstHdrA_Geese_Idle1_A, OBJLstHdrB_Geese_Idle0_B
	dw OBJLstHdrA_Geese_Idle2_A, OBJLstHdrB_Geese_Idle0_B
	dw OBJLstHdrA_Geese_Idle1_A, OBJLstHdrB_Geese_Idle0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_WalkF:
	dw OBJLstHdrA_Geese_WalkF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_WalkF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_WalkF2_A, OBJLstHdrB_Geese_WalkF2_B
	dw OBJLstHdrA_Geese_WalkF1, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_WalkB:
	dw OBJLstHdrA_Geese_WalkF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_WalkF2_A, OBJLstHdrB_Geese_WalkF2_B
	dw OBJLstHdrA_Geese_WalkF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_WalkF0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_Crouch:
	dw OBJLstHdrA_Geese_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_JumpN:
	dw OBJLstHdrA_Geese_Crouch0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_JumpN1_A, OBJLstHdrB_Geese_JumpN1_B
	dw OBJLstHdrA_Geese_JumpN1_A, OBJLstHdrB_Geese_JumpN1_B
	dw OBJLstHdrA_Geese_JumpN1_A, OBJLstHdrB_Geese_JumpN3_B
	dw OBJLstHdrA_Geese_JumpN1_A, OBJLstHdrB_Geese_JumpN3_B
	dw OBJLstHdrA_Geese_JumpN1_A, OBJLstHdrB_Geese_JumpN1_B
	dw OBJLstHdrA_Geese_JumpN1_A, OBJLstHdrB_Geese_JumpN1_B
	dw OBJLstHdrA_Geese_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_BlockG:
	dw OBJLstHdrA_Geese_BlockG0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_BlockC:
	dw OBJLstHdrA_Geese_BlockC0_A, OBJLstHdrB_Geese_BlockC0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_BlockA:
	dw OBJLstHdrA_Geese_BlockA0_A, OBJLstHdrB_Geese_BlockA0_B ;X
	dw OBJLstHdrA_Geese_Crouch0, OBJLSTPTR_NONE ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_RunF:
	dw OBJLstHdrA_Geese_RunF0_A, OBJLstHdrB_Geese_RunF0_B
	dw OBJLstHdrA_Geese_RunF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_RunF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_RunF1, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_HopB:
	dw OBJLstHdrA_Geese_JumpN1_A, OBJLstHdrB_Geese_JumpN1_B
	dw OBJLstHdrA_Geese_JumpN1_A, OBJLstHdrB_Geese_JumpN1_B
	dw OBJLstHdrA_Geese_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_ChargeMeter:
	dw OBJLstHdrA_Geese_ChargeMeter0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_ChargeMeter1, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_Taunt:
	dw OBJLstHdrA_Geese_Taunt0_A, OBJLstHdrB_Geese_Taunt0_B
	dw OBJLstHdrA_Geese_Taunt1_A, OBJLstHdrB_Geese_Taunt0_B
	dw OBJLstHdrA_Geese_Taunt0_A, OBJLstHdrB_Geese_Taunt0_B
	dw OBJLstHdrA_Geese_Taunt1_A, OBJLstHdrB_Geese_Taunt0_B
	dw OBJLstHdrA_Geese_Taunt0_A, OBJLstHdrB_Geese_Taunt0_B
	dw OBJLstHdrA_Geese_Taunt1_A, OBJLstHdrB_Geese_Taunt0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_Intro:
	dw OBJLstHdrA_Geese_Intro0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_Intro1_A, OBJLstHdrB_Geese_Taunt0_B
	dw OBJLstHdrA_Geese_Intro2_A, OBJLstHdrB_Geese_Taunt0_B
	dw OBJLstHdrA_Geese_Intro1_A, OBJLstHdrB_Geese_Taunt0_B
	dw OBJLstHdrA_Geese_Intro4_A, OBJLstHdrB_Geese_Taunt0_B
	dw OBJLstHdrA_Geese_Intro5_A, OBJLstHdrB_Geese_Taunt0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_IntroSpec:
	dw OBJLstHdrA_Geese_IntroSpec0_A, OBJLstHdrB_Geese_IntroSpec0_B
	dw OBJLstHdrA_Geese_IntroSpec1_A, OBJLstHdrB_Geese_IntroSpec0_B
	dw OBJLstHdrA_Geese_IntroSpec0_A, OBJLstHdrB_Geese_IntroSpec0_B
	dw OBJLstHdrA_Geese_IntroSpec1_A, OBJLstHdrB_Geese_IntroSpec0_B
	dw OBJLstHdrA_Geese_IntroSpec0_A, OBJLstHdrB_Geese_IntroSpec0_B
	dw OBJLstHdrA_Geese_IntroSpec1_A, OBJLstHdrB_Geese_IntroSpec0_B
	dw OBJLstHdrA_Geese_IntroSpec6_A, OBJLstHdrB_Geese_IntroSpec0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_WinA:
	dw OBJLstHdrA_Geese_IntroSpec0_A, OBJLstHdrB_Geese_IntroSpec0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_WinB:
	dw OBJLstHdrA_Geese_WinB0_A, OBJLstHdrB_Geese_WinB0_B
	dw OBJLstHdrA_Geese_WinB1_A, OBJLstHdrB_Geese_WinB1_B
	dw OBJLstHdrA_Geese_WinB2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_WinB3_A, OBJLstHdrB_Geese_WinB1_B
	dw OBJLstHdrA_Geese_WinB4_A, OBJLstHdrB_Geese_WinB1_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_PunchL:
	dw OBJLstHdrA_Geese_PunchL0_A, OBJLstHdrB_Geese_PunchL0_B
	dw OBJLstHdrA_Geese_PunchL1_A, OBJLstHdrB_Geese_PunchL0_B
	dw OBJLstHdrA_Geese_PunchL0_A, OBJLstHdrB_Geese_PunchL0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_PunchH:
	dw OBJLstHdrA_Geese_PunchH0_A, OBJLstHdrB_Geese_PunchH0_B
	dw OBJLstHdrA_Geese_PunchH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_PunchH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_PunchH0_A, OBJLstHdrB_Geese_PunchH0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_KickL:
	dw OBJLstHdrA_Geese_KickL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_KickL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_KickL0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_KickH:
	dw OBJLstHdrA_Geese_KickH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_KickH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_KickH2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_KickH2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_KickH4, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_PunchCL:
	dw OBJLstHdrA_Geese_PunchCL0_A, OBJLstHdrB_Geese_PunchCL0_B
	dw OBJLstHdrA_Geese_PunchCL1_A, OBJLstHdrB_Geese_PunchCL0_B
	dw OBJLstHdrA_Geese_PunchCL0_A, OBJLstHdrB_Geese_PunchCL0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_PunchCH:
	dw OBJLstHdrA_Geese_PunchCH0_A, OBJLstHdrB_Geese_PunchH0_B
	dw OBJLstHdrA_Geese_PunchCH1_A, OBJLstHdrB_Geese_PunchL0_B
	dw OBJLstHdrA_Geese_PunchCH1_A, OBJLstHdrB_Geese_PunchL0_B
	dw OBJLstHdrA_Geese_PunchL0_A, OBJLstHdrB_Geese_PunchH0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_KickCL:
	dw OBJLstHdrA_Geese_KickCL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_KickCL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_KickCL0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_KickCH:
	dw OBJLstHdrA_Geese_KickCH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_KickCH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_KickCH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_KickCH0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_KickA:
	dw OBJLstHdrA_Geese_KickA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_KickA1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_JumpN1_A, OBJLstHdrB_Geese_JumpN3_B
	dw OBJLstHdrA_Geese_JumpN1_A, OBJLstHdrB_Geese_JumpN1_B ;X
	dw OBJLstHdrA_Geese_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_PunchA:
	dw OBJLstHdrA_Geese_PunchA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_PunchA1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_JumpN1_A, OBJLstHdrB_Geese_JumpN3_B
	dw OBJLstHdrA_Geese_JumpN1_A, OBJLstHdrB_Geese_JumpN1_B ;X
	dw OBJLstHdrA_Geese_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_AttackA:
	dw OBJLstHdrA_Geese_AttackA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_AttackA1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_JumpN1_A, OBJLstHdrB_Geese_JumpN3_B
	dw OBJLstHdrA_Geese_JumpN1_A, OBJLstHdrB_Geese_JumpN1_B ;X
	dw OBJLstHdrA_Geese_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_AttackG:
	dw OBJLstHdrA_Geese_AttackG0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_AttackG1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_AttackG1, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_RollF:
	dw OBJLstHdrA_Geese_RollF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_RollF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_RollF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_KickCL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_RollB:
	dw OBJLstHdrA_Geese_KickCL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_RollF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_RollF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_RollF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_GuardBreakG:
	dw OBJLstHdrA_Geese_GuardBreakG0_A, OBJLstHdrB_Geese_GuardBreakG0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_Dizzy:
	dw OBJLstHdrA_Geese_Idle0_A, OBJLstHdrB_Geese_Idle0_B
	dw OBJLstHdrA_Geese_GuardBreakG0_A, OBJLstHdrB_Geese_GuardBreakG0_B
OBJLstPtrTable_Geese_TimeOver:
	dw OBJLstHdrA_Geese_WalkF2_A, OBJLstHdrB_Geese_PunchH0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_Hitlow:
	dw OBJLstHdrA_Geese_Hitlow0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_GuardBreakA:
	dw OBJLstHdrA_Geese_GuardBreakG0_A, OBJLstHdrB_Geese_GuardBreakG0_B ;X
	dw OBJLstHdrA_Geese_Crouch0, OBJLSTPTR_NONE ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_BackjumpRecA:
	dw OBJLstHdrA_Geese_GuardBreakG0_A, OBJLstHdrB_Geese_GuardBreakG0_B
	dw OBJLstHdrA_Geese_JumpN1_A, OBJLstHdrB_Geese_JumpN3_B
	dw OBJLstHdrA_Geese_JumpN1_A, OBJLstHdrB_Geese_JumpN3_B
	dw OBJLstHdrA_Geese_JumpN1_A, OBJLstHdrB_Geese_JumpN1_B
	dw OBJLstHdrA_Geese_JumpN1_A, OBJLstHdrB_Geese_JumpN1_B
	dw OBJLstHdrA_Geese_JumpN1_A, OBJLstHdrB_Geese_JumpN1_B
	dw OBJLstHdrA_Geese_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_DropMain:
	dw OBJLstHdrA_Geese_GuardBreakG0_A, OBJLstHdrB_Geese_GuardBreakG0_B
	dw OBJLstHdrA_Geese_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_DropMain2, OBJLSTPTR_NONE
OBJLstPtrTable_Geese_HitMultigs:
	dw OBJLstHdrA_Geese_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_DropMain2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_HitSwoopup:
	dw OBJLstHdrA_Geese_WalkF2_A, OBJLstHdrB_Geese_PunchH0_B ;X
	dw OBJLstHdrA_Geese_HitSwoopup1_A, OBJLstHdrB_Geese_HitSwoopup1_B ;X
	dw OBJLstHdrA_Geese_HitSwoopup2_A, OBJLstHdrB_Geese_HitSwoopup2_B ;X
OBJLstPtrTable_Geese_ThrowEndA:
	dw OBJLstHdrA_Geese_ThrowEndA3_A, OBJLstHdrB_Geese_ThrowEndA3_B
	dw OBJLstHdrA_Geese_ThrowEndA3_A, OBJLstHdrB_Geese_ThrowEndA3_B
	dw OBJLstHdrA_Geese_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_DropMain2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_DropDbg:
	dw OBJLstHdrA_Geese_WalkF2_A, OBJLstHdrB_Geese_PunchH0_B
	dw OBJLstHdrA_Geese_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_DropMain2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_ThrowRotL:
	dw OBJLstHdrA_Geese_ThrowRotL0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_Wakeup:
	dw OBJLstHdrA_Geese_Crouch0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_ReppukenL:
	dw OBJLstHdrA_Geese_ReppukenL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_ReppukenL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_ReppukenL2_A, OBJLstHdrB_Geese_ReppukenL2_B
	dw OBJLstHdrA_Geese_ReppukenL3_A, OBJLstHdrB_Geese_ReppukenL2_B
	dw OBJLstHdrA_Geese_ReppukenL4_A, OBJLstHdrB_Geese_ReppukenL2_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_ReppukenH:
	dw OBJLstHdrA_Geese_ReppukenL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_ReppukenL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_ReppukenL2_A, OBJLstHdrB_Geese_ReppukenL2_B
	dw OBJLstHdrA_Geese_ReppukenH3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_ReppukenH4_A, OBJLstHdrB_Geese_ReppukenH4_B
	dw OBJLstHdrA_Geese_ReppukenH5_A, OBJLstHdrB_Geese_ReppukenH4_B
	dw OBJLstHdrA_Geese_ReppukenH6_A, OBJLstHdrB_Geese_ReppukenH4_B
	dw OBJLstHdrA_Geese_ReppukenH7, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_JaEiKenL:
	dw OBJLstHdrA_Geese_PunchH0_A, OBJLstHdrB_Geese_PunchH0_B
	dw OBJLstHdrA_Geese_JaEiKenL1_A, OBJLstHdrB_Geese_RunF0_B
	dw OBJLstHdrA_Geese_JaEiKenL2_A, OBJLstHdrB_Geese_JaEiKenL2_B
	dw OBJLstHdrA_Geese_JaEiKenL3, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_HishouNichirinZanL:
	dw OBJLstHdrA_Geese_RunF0_A, OBJLstHdrB_Geese_RunF0_B
	dw OBJLstHdrA_Geese_HishouNichirinZanL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_HishouNichirinZanL2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_HishouNichirinZanL3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_HishouNichirinZanL4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_JumpN1_A, OBJLstHdrB_Geese_JumpN1_B
	dw OBJLstHdrA_Geese_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_ShippuKenL:
	dw OBJLstHdrA_Geese_ShippuKenL0_A, OBJLstHdrB_Geese_JumpN1_B
	dw OBJLstHdrA_Geese_ShippuKenL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_JumpN1_A, OBJLstHdrB_Geese_JumpN1_B
	dw OBJLstHdrA_Geese_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_AtemiNageL:
	dw OBJLstHdrA_Geese_AtemiNageL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_AtemiNageL1_A, OBJLstHdrB_Geese_AtemiNageL1_B
	dw OBJLstHdrA_Geese_AtemiNageL2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_AtemiNageL3_A, OBJLstHdrB_Geese_AtemiNageL3_B
	dw OBJLstHdrA_Geese_AtemiNageL4, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_AtemiNageH:
	dw OBJLstHdrA_Geese_AtemiNageH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_AtemiNageL1_A, OBJLstHdrB_Geese_AtemiNageL1_B
	dw OBJLstHdrA_Geese_AtemiNageL2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_AtemiNageL3_A, OBJLstHdrB_Geese_AtemiNageL3_B
	dw OBJLstHdrA_Geese_AtemiNageL4, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_RagingStormS:
	dw OBJLstHdrA_Geese_RagingStormS0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_RagingStormS1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_RagingStormS2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Geese_ThrowG:
	dw OBJLstHdrA_Geese_ThrowG0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_WinB0_A, OBJLstHdrB_Geese_WinB0_B
	dw OBJLstHdrA_Geese_WinB1_A, OBJLstHdrB_Geese_WinB1_B
	dw OBJLstHdrA_Geese_WinB2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Geese_WinB4_A, OBJLstHdrB_Geese_WinB1_B
	dw OBJLstHdrA_Geese_WinB3_A, OBJLstHdrB_Geese_WinB1_B
	dw OBJLstHdrA_Geese_ThrowG6, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		
OBJLstHdrA_Geese_Idle0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L144000 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $24,$F7,$00 ; $00
	db $28,$FF,$02 ; $01
	db $28,$07,$04 ; $02
	db $24,$0F,$06 ; $03
	db $18,$FF,$08 ; $04
	db $18,$07,$0A ; $05
		
OBJLstHdrB_Geese_Idle0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1440C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $38,$FC,$00 ; $00
	db $38,$04,$02 ; $01
	db $38,$0C,$04 ; $02
		
OBJLstHdrA_Geese_Idle1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L144120 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $22,$F7,$00 ; $00
	db $28,$FF,$02 ; $01
	db $28,$07,$04 ; $02
	db $22,$0F,$06 ; $03
	db $18,$FF,$08 ; $04
	db $18,$07,$0A ; $05
		
OBJLstHdrA_Geese_Idle2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1441E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $22,$F7,$00 ; $00
	db $28,$FF,$02 ; $01
	db $28,$07,$04 ; $02
	db $22,$0F,$06 ; $03
	db $18,$FF,$08 ; $04
	db $18,$07,$0A ; $05
		
OBJLstHdrA_Geese_WalkF0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1442A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $22,$F8,$00 ; $00
	db $1D,$00,$02 ; $01
	db $1D,$08,$04 ; $02
	db $1B,$10,$06 ; $03
	db $2D,$02,$08 ; $04
	db $39,$03,$0A ; $05
	db $3C,$0B,$0C ; $06
		
OBJLstHdrA_Geese_WalkF1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L144380 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $20,$F8,$00 ; $00
	db $1B,$00,$02 ; $01
	db $20,$02,$04 ; $02
	db $20,$0A,$06 ; $03
	db $30,$01,$08 ; $04
	db $30,$09,$0A ; $05
		
OBJLstHdrA_Geese_KickH4:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L144380 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Geese_WalkF1.bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Geese_WalkF2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L144440 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $1F,$F8,$00 ; $00
	db $20,$00,$02 ; $01
	db $20,$08,$04 ; $02
	db $10,$00,$06 ; $03
		
OBJLstHdrA_Geese_ThrowEndA3_A:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L144440 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Geese_WalkF2_A.bin ; iOBJLstHdrA_DataPtr
	db $07 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Geese_HitSwoopup1_A: ;X
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L144440 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Geese_WalkF2_A.bin ; iOBJLstHdrA_DataPtr
	db $06 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Geese_HitSwoopup2_A: ;X
	db OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L144440 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Geese_WalkF2_A.bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Geese_WalkF2_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1444C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$FC,$00 ; $00
	db $30,$04,$02 ; $01
	db $33,$0C,$04 ; $02
		
OBJLstHdrA_Geese_Crouch0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L144520 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $27,$FB,$00 ; $00
	db $27,$03,$02 ; $01
	db $22,$0B,$04 ; $02
	db $37,$FB,$06 ; $03
	db $37,$03,$08 ; $04
	db $33,$0B,$0A ; $05
		
OBJLstHdrA_Geese_BlockG0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L144740 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $24,$FC,$00 ; $00
	db $1F,$04,$02 ; $01
	db $25,$0C,$04 ; $02
	db $34,$FC,$06 ; $03
	db $2F,$04,$08 ; $04
	db $35,$0C,$0A ; $05
	db $3A,$F4,$0C ; $06
		
OBJLstHdrA_Geese_BlockC0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L144820 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $28,$FA,$00 ; $00
	db $28,$02,$02 ; $01
	db $28,$0A,$04 ; $02
	db $18,$02,$06 ; $03
		
OBJLstHdrA_Geese_BlockA0_A: ;X
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L144820 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Geese_BlockC0_A.bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $F8 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Geese_BlockC0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1448A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $38,$FB,$00 ; $00
	db $38,$03,$02 ; $01
	db $38,$0B,$04 ; $02
		
OBJLstHdrB_Geese_BlockA0_B: ;X
	db $00 ; iOBJLstHdrA_Flags
	dpr L144900 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $F8 ; iOBJLstHdrA_YOffset
.bin: ;X
	db $03 ; OBJ Count
	;    Y   X  ID
	db $38,$FB,$00 ; $00
	db $38,$03,$02 ; $01
	db $38,$0B,$04 ; $02
		
OBJLstHdrA_Geese_JumpN1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1445E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FB ; iOBJLstHdrA_XOffset
	db $01 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $12,$F3,$00 ; $00
	db $18,$FB,$02 ; $01
	db $18,$03,$04 ; $02
	db $15,$0B,$06 ; $03
		
OBJLstHdrB_Geese_JumpN1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L144660 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FB ; iOBJLstHdrA_XOffset
	db $01 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $28,$FC,$00 ; $00
	db $28,$04,$02 ; $01
	db $38,$04,$04 ; $02
		
OBJLstHdrB_Geese_JumpN3_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1446C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FB ; iOBJLstHdrA_XOffset
	db $01 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $28,$FC,$00 ; $00
	db $28,$04,$02 ; $01
	db $38,$FC,$04 ; $02
	db $38,$04,$06 ; $03
		
OBJLstHdrA_Geese_ChargeMeter0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L145D00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1F,$F9,$00 ; $00
	db $1F,$01,$02 ; $01
	db $1F,$09,$04 ; $02
	db $31,$FA,$06 ; $03
	db $2F,$02,$08 ; $04
	db $31,$0A,$0A ; $05
	db $3E,$F2,$0C ; $06
		
OBJLstHdrA_Geese_ChargeMeter1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L145DE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1F,$F9,$00 ; $00
	db $1F,$01,$02 ; $01
	db $1F,$09,$04 ; $02
	db $30,$FA,$06 ; $03
	db $2F,$02,$08 ; $04
	db $30,$0A,$0A ; $05
	db $3E,$F2,$0C ; $06
		
OBJLstHdrA_Geese_Taunt0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L146440 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $20,$F4,$00 ; $00
	db $28,$FC,$02 ; $01
	db $18,$FC,$04 ; $02
		
OBJLstHdrA_Geese_Taunt1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1464A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $28,$FC,$00 ; $00
	db $18,$FC,$02 ; $01
	db $1A,$F4,$04 ; $02
		
OBJLstHdrA_Geese_Intro0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L145EC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $24,$FC,$00 ; $00
	db $1C,$04,$02 ; $01
	db $23,$0C,$04 ; $02
	db $34,$FC,$06 ; $03
	db $2C,$04,$08 ; $04
	db $33,$0C,$0A ; $05
	db $3C,$04,$0C ; $06
		
OBJLstHdrA_Geese_Intro2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L145FA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $1B,$F4,$00 ; $00
	db $22,$FC,$02 ; $01
	db $32,$FC,$04 ; $02
		
OBJLstHdrB_Geese_Taunt0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L146000 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1C,$04,$00 ; $00
	db $23,$0C,$02 ; $01
	db $2C,$04,$04 ; $02
	db $38,$FC,$06 ; $03
	db $3C,$04,$08 ; $04
	db $33,$0C,$0A ; $05
	db $2B,$14,$0C ; $06
		
OBJLstHdrA_Geese_Intro1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1460E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $1A,$F4,$00 ; $00
	db $1F,$FC,$02 ; $01
	db $2F,$FC,$04 ; $02
		
OBJLstHdrA_Geese_Intro4_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L146140 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $20,$EC,$00 ; $00
	db $19,$F4,$02 ; $01
	db $18,$FC,$04 ; $02
	db $29,$F4,$06 ; $03
	db $28,$FC,$08 ; $04
		
OBJLstHdrA_Geese_Intro5_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1461E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $22,$F4,$00 ; $00
	db $21,$FC,$02 ; $01
	db $31,$FC,$04 ; $02
		
OBJLstHdrA_Geese_IntroSpec0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L146240 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$FD,$00 ; $00
	db $20,$05,$02 ; $01
	db $20,$0D,$04 ; $02
	db $10,$05,$06 ; $03
		
OBJLstHdrB_Geese_IntroSpec0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1462C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $31,$FC,$00 ; $00
	db $30,$04,$02 ; $01
	db $31,$0C,$04 ; $02
		
OBJLstHdrA_Geese_IntroSpec1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L146320 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$FD,$00 ; $00
	db $20,$05,$02 ; $01
	db $20,$0D,$04 ; $02
	db $10,$05,$06 ; $03
		
OBJLstHdrA_Geese_IntroSpec6_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1463A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $28,$FF,$00 ; $00
	db $28,$07,$02 ; $01
	db $18,$FF,$04 ; $02
	db $18,$07,$06 ; $03
	db $20,$0F,$08 ; $04
		
OBJLstHdrA_Geese_PunchL0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L144960 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$F8,$00 ; $00
	db $20,$00,$02 ; $01
	db $20,$08,$04 ; $02
	db $10,$01,$06 ; $03
		
OBJLstHdrA_Geese_PunchCH0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L144960 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Geese_PunchL0_A.bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Geese_PunchL0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1449E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$FB,$00 ; $00
	db $30,$03,$02 ; $01
	db $34,$0B,$04 ; $02
		
OBJLstHdrA_Geese_PunchL1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_62 ; iOBJLstHdrA_HitboxId
	dpr L144A40 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $16,$E8,$00 ; $00
	db $18,$F0,$02 ; $01
	db $20,$F8,$04 ; $02
	db $20,$00,$06 ; $03
	db $20,$08,$08 ; $04
	db $10,$00,$0A ; $05
		
OBJLstHdrA_Geese_PunchH0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L144B00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $1F,$F6,$00 ; $00
	db $20,$FE,$02 ; $01
	db $20,$06,$04 ; $02
	db $10,$FE,$06 ; $03
		
OBJLstHdrB_Geese_PunchH0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L144B80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$FC,$00 ; $00
	db $30,$04,$02 ; $01
	db $33,$0C,$04 ; $02
		
OBJLstHdrB_Geese_ThrowEndA3_B:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	dpr L144B80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_Geese_PunchH0_B.bin ; iOBJLstHdrA_DataPtr
	db $07 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Geese_HitSwoopup1_B: ;X
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	dpr L144B80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_Geese_PunchH0_B.bin ; iOBJLstHdrA_DataPtr
	db $07 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Geese_HitSwoopup2_B: ;X
	db OLF_YFLIP ; iOBJLstHdrA_Flags
	dpr L144B80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_Geese_PunchH0_B.bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Geese_PunchH1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L144BE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Geese_ThrowG0.bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Geese_ThrowG0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L144BE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1F,$F3,$00 ; $00
	db $1E,$FB,$02 ; $01
	db $23,$00,$04 ; $02
	db $2E,$F8,$06 ; $03
	db $33,$00,$08 ; $04
	db $35,$08,$0A ; $05
	db $3E,$F8,$0C ; $06
		
OBJLstHdrA_Geese_KickL0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L144CC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FB ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $22,$03,$00 ; $00
	db $1D,$0B,$02 ; $01
	db $24,$13,$04 ; $02
	db $23,$FB,$06 ; $03
	db $32,$02,$08 ; $04
	db $2D,$0A,$0A ; $05
	db $3D,$0A,$0C ; $06
		
OBJLstHdrA_Geese_KickL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_60 ; iOBJLstHdrA_HitboxId
	dpr L144DA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FB ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $26,$F6,$00 ; $00
	db $27,$FE,$02 ; $01
	db $21,$06,$04 ; $02
	db $1E,$0E,$06 ; $03
	db $21,$16,$08 ; $04
	db $31,$07,$0A ; $05
	db $2E,$0E,$0C ; $06
		
OBJLstHdrA_Geese_AttackA1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L144DA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Geese_KickL1.bin ; iOBJLstHdrA_DataPtr
	db $F4 ; iOBJLstHdrA_XOffset
	db $FE ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Geese_KickH0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L144E80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $2B,$F5,$00 ; $00
	db $1B,$FB,$02 ; $01
	db $1C,$03,$04 ; $02
	db $2B,$FD,$06 ; $03
	db $31,$03,$08 ; $04
	db $3B,$FB,$0A ; $05
		
OBJLstHdrA_Geese_AttackA0:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L144E80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Geese_KickH0.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $FD ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Geese_KickH1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_58 ; iOBJLstHdrA_HitboxId
	dpr L144F40 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $2D,$E4,$00 ; $00
	db $23,$EC,$02 ; $01
	db $2A,$F4,$04 ; $02
	db $1B,$FC,$06 ; $03
	db $1C,$04,$08 ; $04
	db $2B,$FC,$0A ; $05
	db $3B,$FC,$0C ; $06
	db $3A,$F4,$0E ; $07
		
OBJLstHdrA_Geese_KickH2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L145040 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1F,$F5,$00 ; $00
	db $1A,$02,$02 ; $01
	db $23,$0A,$04 ; $02
	db $20,$FB,$06 ; $03
	db $2A,$03,$08 ; $04
	db $30,$FB,$0A ; $05
	db $2E,$F3,$0C ; $06
		
OBJLstHdrA_Geese_PunchCL0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L145120 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $28,$FA,$00 ; $00
	db $28,$02,$02 ; $01
	db $28,$0A,$04 ; $02
	db $18,$02,$06 ; $03
		
OBJLstHdrB_Geese_PunchCL0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1451A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $38,$FB,$00 ; $00
	db $38,$03,$02 ; $01
	db $38,$0B,$04 ; $02
		
OBJLstHdrA_Geese_PunchCL1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L145200 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $20,$E9,$00 ; $00
	db $21,$F1,$02 ; $01
	db $25,$F9,$04 ; $02
	db $28,$01,$06 ; $03
	db $28,$09,$08 ; $04
	db $18,$01,$0A ; $05
		
OBJLstHdrA_Geese_PunchCH1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_63 ; iOBJLstHdrA_HitboxId
	dpr L1452C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $20,$FE,$00 ; $00
	db $20,$06,$02 ; $01
	db $18,$F6,$04 ; $02
	db $10,$FE,$06 ; $03
	db $10,$06,$08 ; $04
		
OBJLstHdrA_Geese_KickCL0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L145360 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FD ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $2B,$FA,$00 ; $00
	db $28,$02,$02 ; $01
	db $2C,$0A,$04 ; $02
	db $3B,$FA,$06 ; $03
	db $38,$02,$08 ; $04
	db $3C,$0A,$0A ; $05
	db $3E,$F2,$0C ; $06
		
OBJLstHdrA_Geese_KickCL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_64 ; iOBJLstHdrA_HitboxId
	dpr L145440 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $3B,$EB,$00 ; $00
	db $38,$F3,$02 ; $01
	db $27,$FB,$04 ; $02
	db $37,$FB,$06 ; $03
	db $37,$03,$08 ; $04
	db $27,$03,$0A ; $05
	db $2B,$0B,$0C ; $06
	db $3B,$0B,$0E ; $07
		
OBJLstHdrA_Geese_KickCH0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L145540 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $23,$FB,$00 ; $00
	db $23,$03,$02 ; $01
	db $33,$FA,$04 ; $02
	db $33,$02,$06 ; $03
	db $36,$0A,$08 ; $04
		
OBJLstHdrA_Geese_KickA0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L145540 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Geese_KickCH0.bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $F8 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Geese_KickCH1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_65 ; iOBJLstHdrA_HitboxId
	dpr L1455E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $34,$E4,$00 ; $00
	db $33,$EC,$02 ; $01
	db $28,$F4,$04 ; $02
	db $29,$FC,$06 ; $03
	db $25,$04,$08 ; $04
	db $38,$F4,$0A ; $05
	db $39,$FC,$0C ; $06
		
OBJLstHdrA_Geese_KickA1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L1455E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Geese_KickCH1.bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $F7 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Geese_PunchA0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1456C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $07 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $0F,$FB,$00 ; $00
	db $0D,$03,$02 ; $01
	db $1F,$FA,$04 ; $02
	db $1D,$02,$06 ; $03
	db $1D,$0A,$08 ; $04
	db $2D,$02,$0A ; $05
		
OBJLstHdrA_Geese_PunchA1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L145780 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $07 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1D,$EF,$00 ; $00
	db $14,$F7,$02 ; $01
	db $14,$FF,$04 ; $02
	db $0E,$07,$06 ; $03
	db $24,$F7,$08 ; $04
	db $24,$FF,$0A ; $05
	db $22,$07,$0C ; $06
		
OBJLstHdrA_Geese_AttackG0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L145860 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FB ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $2B,$00,$00 ; $00
	db $1B,$0A,$02 ; $01
	db $1F,$12,$04 ; $02
	db $21,$08,$06 ; $03
	db $2B,$0E,$08 ; $04
	db $31,$06,$0A ; $05
	db $3B,$0E,$0C ; $06
		
OBJLstHdrA_Geese_AttackG1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L145940 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FB ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $1F,$EC,$00 ; $00
	db $28,$F4,$02 ; $01
	db $21,$FC,$04 ; $02
	db $26,$04,$06 ; $03
	db $38,$F4,$08 ; $04
	db $31,$FC,$0A ; $05
	db $36,$04,$0C ; $06
	db $35,$0C,$0E ; $07
		
OBJLstHdrA_Geese_GuardBreakG0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L145A40 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$03,$00 ; $00
	db $20,$0B,$02 ; $01
	db $1D,$0E,$04 ; $02
	db $10,$06,$06 ; $03
		
OBJLstHdrB_Geese_GuardBreakG0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L145AC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $3C,$F9,$00 ; $00
	db $30,$01,$02 ; $01
	db $30,$09,$04 ; $02
		
OBJLstHdrA_Geese_Hitlow0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L145B20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $30,$FC,$00 ; $00
	db $20,$02,$02 ; $01
	db $20,$0A,$04 ; $02
	db $30,$04,$06 ; $03
	db $30,$0C,$08 ; $04
		
OBJLstHdrA_Geese_DropMain1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L145BC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $0A ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $2D,$EC,$00 ; $00
	db $29,$F4,$02 ; $01
	db $28,$FC,$04 ; $02
	db $2A,$04,$06 ; $03
	db $2D,$0C,$08 ; $04
		
; [TCRF] Unreferenced sprite mapping, identical to OBJLstHdrA_Geese_ThrowRotL0 except horizontally flipped.
OBJLstHdrA_Geese_Unused_ThrowRotR0:
	db OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L145BC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Geese_DropMain1.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset

OBJLstHdrA_Geese_ThrowRotL0:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L145BC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Geese_DropMain1.bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Geese_DropMain2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L145C60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $04 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $31,$EC,$00 ; $00
	db $32,$F4,$02 ; $01
	db $33,$FC,$04 ; $02
	db $32,$04,$06 ; $03
	db $34,$0C,$08 ; $04
		
OBJLstHdrA_Geese_RunF0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L146920 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $22,$F4,$00 ; $00
	db $28,$FC,$02 ; $01
	db $18,$FC,$04 ; $02
	db $20,$04,$06 ; $03
	db $1F,$0C,$08 ; $04
		
OBJLstHdrB_Geese_RunF0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1469C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $38,$FC,$00 ; $00
	db $30,$04,$02 ; $01
	db $30,$0C,$04 ; $02
	db $31,$14,$06 ; $03
		
OBJLstHdrA_Geese_RunF1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L146A40 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F6 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $23,$F7,$00 ; $00
	db $21,$FF,$02 ; $01
	db $22,$07,$04 ; $02
	db $32,$05,$06 ; $03
	db $1D,$0F,$08 ; $04
	db $32,$0D,$0A ; $05
		
OBJLstHdrA_Geese_RollF2:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L146A40 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Geese_RunF1.bin ; iOBJLstHdrA_DataPtr
	db $0A ; iOBJLstHdrA_XOffset
	db $03 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Geese_RunF2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L146B00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $22,$F6,$00 ; $00
	db $22,$FE,$02 ; $01
	db $1E,$06,$04 ; $02
	db $1F,$0E,$06 ; $03
	db $32,$FD,$08 ; $04
	db $2E,$05,$0A ; $05
	db $2E,$0D,$0C ; $06
	db $2F,$15,$0E ; $07
		
OBJLstHdrA_Geese_WinB0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L146500 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $20,$EE,$00 ; $00
	db $1E,$F6,$02 ; $01
	db $20,$FE,$04 ; $02
	db $20,$06,$06 ; $03
	db $14,$0E,$08 ; $04
	db $10,$FE,$0A ; $05
	db $10,$06,$0C ; $06
		
OBJLstHdrA_Geese_WinB1_A:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L146500 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Geese_WinB0_A.bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Geese_WinB0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1465E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$F8,$00 ; $00
	db $30,$00,$02 ; $01
	db $30,$08,$04 ; $02
		
OBJLstHdrB_Geese_WinB1_B:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	dpr L1465E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_Geese_WinB0_B.bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Geese_WinB2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L146640 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $18,$FC,$00 ; $00
	db $14,$04,$02 ; $01
	db $28,$FC,$04 ; $02
	db $24,$04,$06 ; $03
	db $34,$00,$08 ; $04
	db $34,$08,$0A ; $05
	db $38,$F8,$0C ; $06
		
OBJLstHdrA_Geese_WinB4_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L146720 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $1D,$F7,$00 ; $00
	db $20,$FF,$02 ; $01
	db $10,$FF,$04 ; $02
	db $20,$07,$06 ; $03
		
OBJLstHdrA_Geese_WinB3_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L1467A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$FC,$00 ; $00
	db $20,$04,$02 ; $01
	db $10,$FC,$04 ; $02
	db $10,$04,$06 ; $03
		
OBJLstHdrA_Geese_ThrowG6:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L146820 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $29,$F4,$00 ; $00
	db $1F,$FC,$02 ; $01
	db $1F,$04,$04 ; $02
	db $26,$0C,$06 ; $03
	db $2F,$FC,$08 ; $04
	db $2F,$04,$0A ; $05
	db $39,$F4,$0C ; $06
	db $36,$0C,$0E ; $07
		
OBJLstHdrA_Geese_ReppukenL0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L146C00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $20,$F8,$00 ; $00
	db $21,$00,$02 ; $01
	db $17,$08,$04 ; $02
	db $32,$FC,$06 ; $03
	db $27,$04,$08 ; $04
	db $37,$04,$0A ; $05
	db $3A,$0C,$0C ; $06
		
OBJLstHdrA_Geese_HishouNichirinZanL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L146C00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Geese_ReppukenL0.bin ; iOBJLstHdrA_DataPtr
	db $FD ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Geese_ReppukenL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L146CE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $20,$FA,$00 ; $00
	db $1A,$02,$02 ; $01
	db $17,$0A,$04 ; $02
	db $2E,$F2,$06 ; $03
	db $31,$FA,$08 ; $04
	db $2A,$02,$0A ; $05
	db $3A,$02,$0C ; $06
	db $31,$0A,$0E ; $07
		
OBJLstHdrA_Geese_ReppukenL2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_3D ; iOBJLstHdrA_HitboxId
	dpr L146DE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $1D,$EC,$00 ; $00
	db $10,$F4,$02 ; $01
	db $16,$FC,$04 ; $02
	db $1F,$E4,$06 ; $03
	db $2D,$EC,$08 ; $04
	db $20,$F4,$0A ; $05
	db $26,$FC,$0C ; $06
	db $30,$F4,$0E ; $07
	db $36,$FC,$10 ; $08
		
OBJLstHdrB_Geese_ReppukenL2_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L146F00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $13,$04,$00 ; $00
	db $23,$04,$02 ; $01
	db $33,$04,$04 ; $02
	db $25,$0C,$06 ; $03
	db $35,$0C,$08 ; $04
		
OBJLstHdrA_Geese_ReppukenL3_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L146FA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1E,$EC,$00 ; $00
	db $13,$F4,$02 ; $01
	db $18,$FC,$04 ; $02
	db $28,$FC,$06 ; $03
	db $38,$FC,$08 ; $04
	db $3A,$F4,$0A ; $05
		
OBJLstHdrA_Geese_ReppukenL4_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L147060 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $18,$FC,$00 ; $00
	db $28,$FC,$02 ; $01
	db $38,$FC,$04 ; $02
	db $3A,$F4,$06 ; $03
		
OBJLstHdrA_Geese_ReppukenH3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1470E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F2 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $22,$02,$00 ; $00
	db $19,$0A,$02 ; $01
	db $32,$02,$04 ; $02
	db $29,$0A,$06 ; $03
	db $39,$0A,$08 ; $04
	db $35,$12,$0A ; $05
		
OBJLstHdrA_Geese_ReppukenH4_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_3E ; iOBJLstHdrA_HitboxId
	dpr L1471A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F2 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $29,$EC,$00 ; $00
	db $28,$F4,$02 ; $01
	db $38,$F4,$04 ; $02
	db $20,$FC,$06 ; $03
	db $30,$FC,$08 ; $04
	db $18,$04,$0A ; $05
	db $28,$04,$0C ; $06
	db $38,$04,$0E ; $07
		
OBJLstHdrB_Geese_ReppukenH4_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1472A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F2 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $17,$0C,$00 ; $00
	db $27,$0C,$02 ; $01
	db $37,$0C,$04 ; $02
	db $27,$14,$06 ; $03
	db $38,$14,$08 ; $04
	db $0C,$14,$0A ; $05
		
OBJLstHdrA_Geese_ReppukenH5_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_3E ; iOBJLstHdrA_HitboxId
	dpr L147360 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F2 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $13,$EC,$00 ; $00
	db $08,$F4,$02 ; $01
	db $19,$E4,$04 ; $02
	db $23,$EC,$06 ; $03
	db $29,$E8,$08 ; $04
	db $18,$04,$0A ; $05
	db $28,$04,$0C ; $06
	db $38,$04,$0E ; $07
	db $38,$FC,$10 ; $08
		
OBJLstHdrA_Geese_ReppukenH6_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_3E ; iOBJLstHdrA_HitboxId
	dpr L147480 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F2 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $18,$E4,$00 ; $00
	db $18,$EC,$02 ; $01
	db $08,$EC,$04 ; $02
	db $10,$F4,$06 ; $03
	db $18,$04,$08 ; $04
	db $28,$04,$0A ; $05
	db $38,$04,$0C ; $06
	db $3A,$FC,$0E ; $07
		
OBJLstHdrA_Geese_ReppukenH7:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L147580 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Geese_AtemiNageL2.bin ; iOBJLstHdrA_DataPtr
	db $F2 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Geese_AtemiNageL2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L147580 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F2 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $17,$06,$00 ; $00
	db $17,$0E,$02 ; $01
	db $27,$03,$04 ; $02
	db $27,$0B,$06 ; $03
	db $37,$03,$08 ; $04
	db $37,$0B,$0A ; $05
	db $27,$13,$0C ; $06
	db $39,$13,$0E ; $07
		
OBJLstHdrA_Geese_JaEiKenL1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L147680 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $28,$FC,$00 ; $00
	db $21,$FA,$02 ; $01
	db $20,$02,$04 ; $02
	db $19,$0A,$06 ; $03
		
OBJLstHdrA_Geese_JaEiKenL2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L147700 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Geese_AtemiNageL3_A.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Geese_AtemiNageL3_A:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L147700 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $05 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $2C,$EC,$00 ; $00
	db $28,$F4,$02 ; $01
	db $18,$F4,$04 ; $02
	db $18,$FC,$06 ; $03
		
OBJLstHdrB_Geese_JaEiKenL2_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L147780 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_Geese_AtemiNageL3_B.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Geese_AtemiNageL1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L147780 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_Geese_AtemiNageL3_B.bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Geese_AtemiNageL3_B:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	dpr L147780 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $05 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $28,$FC,$00 ; $00
	db $21,$04,$02 ; $01
	db $38,$F8,$04 ; $02
	db $31,$00,$06 ; $03
	db $35,$08,$08 ; $04
		
OBJLstHdrA_Geese_JaEiKenL3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L147820 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $1A,$E4,$00 ; $00
	db $26,$EC,$02 ; $01
	db $20,$F4,$04 ; $02
	db $20,$FC,$06 ; $03
	db $26,$04,$08 ; $04
	db $30,$F4,$0A ; $05
	db $30,$FC,$0C ; $06
	db $36,$04,$0E ; $07
	db $3A,$0C,$10 ; $08
		
OBJLstHdrA_Geese_HishouNichirinZanL2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L147940 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F7 ; iOBJLstHdrA_XOffset
	db $02 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1A,$FD,$00 ; $00
	db $14,$05,$02 ; $01
	db $19,$0D,$04 ; $02
	db $24,$05,$06 ; $03
	db $29,$0D,$08 ; $04
	db $2E,$15,$0A ; $05
		
OBJLstHdrA_Geese_HishouNichirinZanL3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_3F ; iOBJLstHdrA_HitboxId
	dpr L147A00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FF ; iOBJLstHdrA_XOffset
	db $0B ; iOBJLstHdrA_YOffset
.bin:
	db $0B ; OBJ Count
	;    Y   X  ID
	db $0D,$E4,$00 ; $00
	db $17,$EC,$02 ; $01
	db $13,$F4,$04 ; $02
	db $13,$FC,$06 ; $03
	db $0D,$04,$08 ; $04
	db $1D,$E4,$0A ; $05
	db $27,$EC,$0C ; $06
	db $23,$F4,$0E ; $07
	db $23,$FC,$10 ; $08
	db $1D,$04,$12 ; $09
	db $20,$0C,$14 ; $0A
		
OBJLstHdrA_Geese_HishouNichirinZanL4:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L147B60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FF ; iOBJLstHdrA_XOffset
	db $0B ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $10,$F0,$00 ; $00
	db $13,$F8,$02 ; $01
	db $11,$00,$04 ; $02
	db $23,$F8,$06 ; $03
	db $21,$00,$08 ; $04
	db $20,$08,$0A ; $05
	db $05,$08,$0C ; $06
		
OBJLstHdrA_Geese_ShippuKenL0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L147C40 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FB ; iOBJLstHdrA_XOffset
	db $09 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $07,$F2,$00 ; $00
	db $0E,$FA,$02 ; $01
	db $10,$02,$04 ; $02
	db $0E,$0A,$06 ; $03
	db $07,$12,$08 ; $04
		
OBJLstHdrA_Geese_ShippuKenL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L147CE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FD ; iOBJLstHdrA_XOffset
	db $07 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $15,$F8,$00 ; $00
	db $14,$00,$02 ; $01
	db $15,$08,$04 ; $02
	db $2B,$F1,$06 ; $03
	db $25,$F9,$08 ; $04
	db $24,$01,$0A ; $05
		
OBJLstHdrA_Geese_RollF1:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L147CE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Geese_ShippuKenL1.bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $FA ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Geese_AtemiNageL0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L147DA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $1B,$FB,$00 ; $00
	db $1C,$03,$02 ; $01
	db $1E,$0B,$04 ; $02
	db $33,$FB,$06 ; $03
	db $2C,$03,$08 ; $04
	db $2E,$0B,$0A ; $05
	db $23,$13,$0C ; $06
	db $3C,$03,$0E ; $07
	db $3E,$0B,$10 ; $08
		
OBJLstHdrA_Geese_AtemiNageL1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L147EC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $23,$EC,$00 ; $00
	db $20,$F4,$02 ; $01
	db $18,$FC,$04 ; $02
	db $32,$F4,$06 ; $03
		
OBJLstHdrA_Geese_AtemiNageL4:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L147F40 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1F,$FB,$00 ; $00
	db $23,$03,$02 ; $01
	db $29,$0B,$04 ; $02
	db $33,$FB,$06 ; $03
	db $33,$03,$08 ; $04
	db $39,$0B,$0A ; $05
		
OBJLstHdrA_Geese_RollF0:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L147F40 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Geese_AtemiNageL4.bin ; iOBJLstHdrA_DataPtr
	db $06 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Geese_AtemiNageH0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0F7AE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FB ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $22,$F8,$00 ; $00
	db $1D,$00,$02 ; $01
	db $1F,$08,$04 ; $02
	db $1C,$10,$06 ; $03
	db $33,$FA,$08 ; $04
	db $2D,$00,$0A ; $05
	db $2F,$02,$0C ; $06
	db $31,$0A,$0E ; $07
		
OBJLstHdrA_Geese_RagingStormS0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0F7BE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $16,$00,$00 ; $00
	db $16,$08,$02 ; $01
	db $26,$00,$04 ; $02
	db $26,$08,$06 ; $03
	db $36,$00,$08 ; $04
	db $36,$08,$0A ; $05
	db $37,$F8,$0C ; $06
		
OBJLstHdrA_Geese_RagingStormS1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0F7CC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1B,$F4,$00 ; $00
	db $24,$FC,$02 ; $01
	db $24,$04,$04 ; $02
	db $1B,$0C,$06 ; $03
	db $34,$FC,$08 ; $04
	db $34,$04,$0A ; $05
	db $36,$0C,$0C ; $06
		
OBJLstHdrA_Geese_RagingStormS2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0F7DA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $30,$F9,$00 ; $00
	db $30,$01,$02 ; $01
	db $30,$09,$04 ; $02
	db $20,$FC,$06 ; $03
	db $20,$04,$08 ; $04
		

OBJLstPtrTable_MrBig_Idle:
	dw OBJLstHdrA_MrBig_Idle0_A, OBJLstHdrB_MrBig_Idle0_B
	dw OBJLstHdrA_MrBig_Idle1_A, OBJLstHdrB_MrBig_Idle1_B
	dw OBJLstHdrA_MrBig_Idle2_A, OBJLstHdrB_MrBig_Idle2_B
	dw OBJLstHdrA_MrBig_Idle1_A, OBJLstHdrB_MrBig_Idle1_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_WalkF:
	dw OBJLstHdrA_MrBig_WalkF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_WalkF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_WalkF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_WalkF1, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_WalkB:
	dw OBJLstHdrA_MrBig_WalkF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_WalkF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_WalkF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_WalkF0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_Crouch:
	dw OBJLstHdrA_MrBig_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_JumpN:
	dw OBJLstHdrA_MrBig_Crouch0, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_JumpN3, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_JumpN3, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_BlockG:
	dw OBJLstHdrA_MrBig_BlockG0_A, OBJLstHdrB_MrBig_BlockG0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_BlockC:
	dw OBJLstHdrA_MrBig_BlockC0_A, OBJLstHdrB_MrBig_BlockC0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_BlockA:
	dw OBJLstHdrA_MrBig_BlockG0_A, OBJLstHdrB_MrBig_BlockA0_B ;X
	dw OBJLstHdrA_MrBig_Crouch0, OBJLSTPTR_NONE ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_RunF:
	dw OBJLstHdrA_MrBig_RunF0_A, OBJLstHdrB_MrBig_RunF0_B
	dw OBJLstHdrA_MrBig_RunF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_RunF2_A, OBJLstHdrB_MrBig_RunF0_B
	dw OBJLstHdrA_MrBig_RunF1, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_HopB:
	dw OBJLstHdrA_MrBig_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_ChargeMeter:
	dw OBJLstHdrA_MrBig_ChargeMeter0_A, OBJLstHdrB_MrBig_ChargeMeter0_B
	dw OBJLstHdrA_MrBig_ChargeMeter1_A, OBJLstHdrB_MrBig_ChargeMeter0_B
	dw OBJLSTPTR_NONE
		
L0770AB: db $FF;X
L0770AC: db $FF;X

OBJLstPtrTable_MrBig_Taunt:
	dw OBJLstHdrA_MrBig_Taunt0_A, OBJLstHdrB_MrBig_Taunt0_B
	dw OBJLstHdrA_MrBig_Taunt1_A, OBJLstHdrB_MrBig_Taunt0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_WinA:
	dw OBJLstHdrA_MrBig_WinA0_A, OBJLstHdrB_MrBig_WinA0_B
	dw OBJLstHdrA_MrBig_WinA1_A, OBJLstHdrB_MrBig_WinA1_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_WinB:
	dw OBJLstHdrA_MrBig_WinB0_A, OBJLstHdrB_MrBig_WinB0_B
	dw OBJLstHdrA_MrBig_WinB1_A, OBJLstHdrB_MrBig_WinB0_B
	dw OBJLstHdrA_MrBig_WinB0_A, OBJLstHdrB_MrBig_WinB0_B
	dw OBJLstHdrA_MrBig_WinB1_A, OBJLstHdrB_MrBig_WinB0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_PunchL:
	dw OBJLstHdrA_MrBig_WinA0_A, OBJLstHdrB_MrBig_WinA0_B
	dw OBJLstHdrA_MrBig_PunchL1_A, OBJLstHdrB_MrBig_PunchL1_B
	dw OBJLstHdrA_MrBig_WinA0_A, OBJLstHdrB_MrBig_WinA0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_PunchH:
	dw OBJLstHdrA_MrBig_PunchH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_PunchH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_PunchH2_A, OBJLstHdrB_MrBig_PunchH2_B
	dw OBJLstHdrA_MrBig_PunchL1_A, OBJLstHdrB_MrBig_PunchH3_B
	dw OBJLstHdrA_MrBig_WalkF1, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_KickL:
	dw OBJLstHdrA_MrBig_KickL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_KickL1_A, OBJLstHdrB_MrBig_KickL1_B
	dw OBJLstHdrA_MrBig_KickL0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_KickH:
	dw OBJLstHdrA_MrBig_KickH0_A, OBJLstHdrB_MrBig_KickH0_B
	dw OBJLstHdrA_MrBig_KickH1_A, OBJLstHdrB_MrBig_KickH1_B
	dw OBJLstHdrA_MrBig_KickH1_A, OBJLstHdrB_MrBig_KickH1_B
	dw OBJLstHdrA_MrBig_KickH0_A, OBJLstHdrB_MrBig_KickH0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_PunchCL:
	dw OBJLstHdrA_MrBig_PunchCL0_A, OBJLstHdrB_MrBig_PunchCL0_B
	dw OBJLstHdrA_MrBig_PunchCL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_PunchCL0_A, OBJLstHdrB_MrBig_PunchCL0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_PunchCH:
	dw OBJLstHdrA_MrBig_PunchCH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_PunchCH1_A, OBJLstHdrB_MrBig_PunchCH1_B
	dw OBJLstHdrA_MrBig_PunchCH2_A, OBJLstHdrB_MrBig_PunchCH1_B
	dw OBJLstHdrA_MrBig_PunchCL0_A, OBJLstHdrB_MrBig_PunchCL0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_KickCL:
	dw OBJLstHdrA_MrBig_KickCL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_KickCL1_A, OBJLstHdrB_MrBig_KickCL1_B
	dw OBJLstHdrA_MrBig_KickCL0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_KickCH:
	dw OBJLstHdrA_MrBig_KickCH0_A, OBJLstHdrB_MrBig_KickCH0_B
	dw OBJLstHdrA_MrBig_KickCH1_A, OBJLstHdrB_MrBig_KickCH1_B
	dw OBJLstHdrA_MrBig_KickCH1_A, OBJLstHdrB_MrBig_KickCH1_B
	dw OBJLstHdrA_MrBig_KickCH0_A, OBJLstHdrB_MrBig_KickCH0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_PunchA:
	dw OBJLstHdrA_MrBig_PunchA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_PunchA1, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_JumpN1, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_MrBig_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_KickA:
	dw OBJLstHdrA_MrBig_KickA0_A, OBJLstHdrB_MrBig_KickA0_B
	dw OBJLstHdrA_MrBig_KickA0_A, OBJLstHdrB_MrBig_KickA0_B
	dw OBJLstHdrA_MrBig_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_JumpN1, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_MrBig_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_AttackA:
	dw OBJLstHdrA_MrBig_JumpN3, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_AttackA1, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_JumpN1, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_MrBig_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_AttackG:
	dw OBJLstHdrA_MrBig_AttackG0_A, OBJLstHdrB_MrBig_AttackG0_B
	dw OBJLstHdrA_MrBig_AttackG1_A, OBJLstHdrB_MrBig_AttackG1_B
	dw OBJLstHdrA_MrBig_AttackG2, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_ChargeMeter0_A, OBJLstHdrB_MrBig_ChargeMeter0_B ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_RollF:
	dw OBJLstHdrA_MrBig_RollF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_RollF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_RollF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_RollF3, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_RollB:
	dw OBJLstHdrA_MrBig_RollF3, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_RollF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_RollF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_RollF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_GuardBreakG:
	dw OBJLstHdrA_MrBig_GuardBreakG0_A, OBJLstHdrB_MrBig_GuardBreakG0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_Dizzy:
	dw OBJLstHdrA_MrBig_Idle0_A, OBJLstHdrB_MrBig_Idle0_B
	dw OBJLstHdrA_MrBig_GuardBreakG0_A, OBJLstHdrB_MrBig_GuardBreakG0_B
OBJLstPtrTable_MrBig_TimeOver:
	dw OBJLstHdrA_MrBig_TimeOver2_A, OBJLstHdrB_MrBig_Idle1_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_Hitlow:
	dw OBJLstHdrA_MrBig_Hitlow0_A, OBJLstHdrB_MrBig_Hitlow0_B ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_GuardBreakA:
	dw OBJLstHdrA_MrBig_GuardBreakG0_A, OBJLstHdrB_MrBig_GuardBreakG0_B ;X
	dw OBJLstHdrA_MrBig_Crouch0, OBJLSTPTR_NONE ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_BackjumpRecA:
	dw OBJLstHdrA_MrBig_GuardBreakG0_A, OBJLstHdrB_MrBig_GuardBreakG0_B ;X
	dw OBJLstHdrA_MrBig_JumpN3, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_MrBig_JumpN3, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_MrBig_JumpN1, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_MrBig_JumpN1, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_MrBig_JumpN1, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_MrBig_Crouch0, OBJLSTPTR_NONE ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_DropMain:
	dw OBJLstHdrA_MrBig_GuardBreakG0_A, OBJLstHdrB_MrBig_GuardBreakG0_B
	dw OBJLstHdrA_MrBig_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_DropMain2, OBJLSTPTR_NONE
OBJLstPtrTable_MrBig_HitMultigs:
	dw OBJLstHdrA_MrBig_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_DropMain2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_HitSwoopup:
	dw OBJLstHdrA_MrBig_TimeOver2_A, OBJLstHdrB_MrBig_Idle1_B
	dw OBJLstHdrA_MrBig_HitSwoopup1_A, OBJLstHdrB_MrBig_HitSwoopup1_B
	dw OBJLstHdrA_MrBig_HitSwoopup2_A, OBJLstHdrB_MrBig_HitSwoopup2_B
OBJLstPtrTable_MrBig_ThrowEndA:
	dw OBJLstHdrA_MrBig_ThrowEndA3_A, OBJLstHdrB_MrBig_ThrowEndA3_B
	dw OBJLstHdrA_MrBig_ThrowEndA3_A, OBJLstHdrB_MrBig_ThrowEndA3_B
	dw OBJLstHdrA_MrBig_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_DropMain2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_DropDbg:
	dw OBJLstHdrA_MrBig_TimeOver2_A, OBJLstHdrB_MrBig_Idle1_B
	dw OBJLstHdrA_MrBig_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_DropMain2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_ThrowRotL:
	dw OBJLstHdrA_MrBig_ThrowRotL0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_Wakeup:
	dw OBJLstHdrA_MrBig_Crouch0, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_GroundBlasterL:
	dw OBJLstHdrA_MrBig_ChargeMeter0_A, OBJLstHdrB_MrBig_ChargeMeter0_B
	dw OBJLstHdrA_MrBig_AttackG1_A, OBJLstHdrB_MrBig_AttackG1_B
	dw OBJLstHdrA_MrBig_GroundBlasterL2_A, OBJLstHdrB_MrBig_GroundBlasterL2_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_CrossDivingL:
	dw OBJLstHdrA_MrBig_ChargeMeter0_A, OBJLstHdrB_MrBig_ChargeMeter0_B
	dw OBJLstHdrA_MrBig_CrossDivingL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_CrossDivingL2, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_CrossDivingL3, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_CrossDivingL4, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_RollF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_RollF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_SpinningLancerL:
	dw OBJLstHdrA_MrBig_ChargeMeter0_A, OBJLstHdrB_MrBig_ChargeMeter0_B
	dw OBJLstHdrA_MrBig_SpinningLancerL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_SpinningLancerL2, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_SpinningLancerL3, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_SpinningLancerL4, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_AttackG0_A, OBJLstHdrB_MrBig_AttackG0_B
	dw OBJLstHdrA_MrBig_SpinningLancerL6_A, OBJLstHdrB_MrBig_AttackG1_B
	dw OBJLstHdrA_MrBig_AttackG2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_CaliforniaRomanceH:
	dw OBJLstHdrA_MrBig_CaliforniaRomanceH0_A, OBJLstHdrB_MrBig_CaliforniaRomanceH0_B
	dw OBJLstHdrA_MrBig_CaliforniaRomanceH1_A, OBJLstHdrB_MrBig_CaliforniaRomanceH1_B
	dw OBJLstHdrA_MrBig_CaliforniaRomanceH0_A, OBJLstHdrB_MrBig_CaliforniaRomanceH0_B
	dw OBJLstHdrA_MrBig_CaliforniaRomanceH0_A, OBJLstHdrB_MrBig_CaliforniaRomanceH0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_CaliforniaRomanceL:
	dw OBJLstHdrA_MrBig_SpinningLancerL6_A, OBJLstHdrB_MrBig_AttackG1_B
	dw OBJLstHdrA_MrBig_SpinningLancerL6_A, OBJLstHdrB_MrBig_AttackG1_B
	dw OBJLstHdrA_MrBig_CaliforniaRomanceL2, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_CaliforniaRomanceL3, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_CaliforniaRomanceL4, OBJLSTPTR_NONE
	dw OBJLstHdrA_MrBig_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_DrumShotL:
	dw OBJLstHdrA_MrBig_DrumShotL0_A, OBJLstHdrB_MrBig_DrumShotL0_B
	dw OBJLstHdrA_MrBig_DrumShotL1_A, OBJLstHdrB_MrBig_DrumShotL0_B
	dw OBJLstHdrA_MrBig_DrumShotL2_A, OBJLstHdrB_MrBig_DrumShotL0_B
	dw OBJLstHdrA_MrBig_DrumShotL0_A, OBJLstHdrB_MrBig_DrumShotL0_B
	dw OBJLstHdrA_MrBig_DrumShotL4_A, OBJLstHdrB_MrBig_DrumShotL0_B
	dw OBJLstHdrA_MrBig_DrumShotL2_A, OBJLstHdrB_MrBig_DrumShotL0_B
	dw OBJLstHdrA_MrBig_DrumShotL0_A, OBJLstHdrB_MrBig_DrumShotL0_B
	dw OBJLstHdrA_MrBig_ChargeMeter0_A, OBJLstHdrB_MrBig_ChargeMeter0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_BlasterWaveS:
	dw OBJLstHdrA_MrBig_BlasterWaveS0_A, OBJLstHdrB_MrBig_ChargeMeter0_B
	dw OBJLstHdrA_MrBig_BlasterWaveS1_A, OBJLstHdrB_MrBig_AttackG1_B
	dw OBJLstHdrA_MrBig_BlasterWaveS2_A, OBJLstHdrB_MrBig_GroundBlasterL2_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_MrBig_ThrowG:
	dw OBJLstHdrA_MrBig_ThrowG0_A, OBJLstHdrB_MrBig_Taunt0_B
	dw OBJLstHdrA_MrBig_ThrowG1_A, OBJLstHdrB_MrBig_Taunt0_B
	dw OBJLstHdrA_MrBig_ThrowG2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		
OBJLstHdrA_MrBig_Idle0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L164000 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $28,$F4,$00 ; $00
	db $28,$FC,$02 ; $01
	db $28,$04,$04 ; $02
	db $18,$F4,$06 ; $03
	db $18,$FC,$08 ; $04
	db $18,$04,$0A ; $05
		
OBJLstHdrB_MrBig_Idle0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1640C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F7 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $38,$FC,$00 ; $00
	db $38,$04,$02 ; $01
	db $38,$0C,$04 ; $02
		
OBJLstHdrB_MrBig_WinA1_B:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	dpr L1640C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_MrBig_Idle0_B.bin ; iOBJLstHdrA_DataPtr
	db $09 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_MrBig_Idle1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L164120 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $28,$F4,$00 ; $00
	db $28,$FC,$02 ; $01
	db $28,$04,$04 ; $02
	db $18,$F4,$06 ; $03
	db $18,$FC,$08 ; $04
	db $18,$04,$0A ; $05
		
OBJLstHdrB_MrBig_Idle1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1641E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $38,$F4,$00 ; $00
	db $38,$FC,$02 ; $01
	db $38,$04,$04 ; $02
		
OBJLstHdrB_MrBig_HitSwoopup1_B:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	dpr L1641E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_MrBig_Idle1_B.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_MrBig_HitSwoopup2_B:
	db OLF_YFLIP ; iOBJLstHdrA_Flags
	dpr L1641E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_MrBig_Idle1_B.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_MrBig_ThrowEndA3_B:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	dpr L1641E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_MrBig_Idle1_B.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_MrBig_Idle2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L164240 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $28,$F4,$00 ; $00
	db $28,$FC,$02 ; $01
	db $28,$04,$04 ; $02
	db $18,$F4,$06 ; $03
	db $18,$FC,$08 ; $04
	db $18,$04,$0A ; $05
		
OBJLstHdrB_MrBig_Idle2_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L164300 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $38,$F4,$00 ; $00
	db $38,$FC,$02 ; $01
	db $38,$04,$04 ; $02
		
OBJLstHdrA_MrBig_WalkF0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L164360 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $18,$EC,$00 ; $00
	db $1B,$F4,$02 ; $01
	db $1B,$FC,$04 ; $02
	db $24,$04,$06 ; $03
	db $2B,$F4,$08 ; $04
	db $2B,$FC,$0A ; $05
	db $36,$F0,$0C ; $06
	db $3B,$FE,$0E ; $07
		
OBJLstHdrA_MrBig_WalkF1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L164460 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1B,$F1,$00 ; $00
	db $1B,$F9,$02 ; $01
	db $23,$FB,$04 ; $02
	db $2B,$F3,$06 ; $03
	db $33,$FB,$08 ; $04
	db $3B,$F3,$0A ; $05
		
OBJLstHdrA_MrBig_WalkF2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L164520 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $25,$EB,$00 ; $00
	db $1B,$F3,$02 ; $01
	db $1B,$FB,$04 ; $02
	db $2B,$F3,$06 ; $03
	db $2B,$FB,$08 ; $04
	db $3B,$F2,$0A ; $05
	db $3B,$FE,$0C ; $06
	db $1D,$E3,$0E ; $07
		
OBJLstHdrA_MrBig_Crouch0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L164620 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $25,$F3,$00 ; $00
	db $23,$FB,$02 ; $01
	db $24,$03,$04 ; $02
	db $35,$F3,$06 ; $03
	db $33,$FB,$08 ; $04
	db $34,$03,$0A ; $05
		
OBJLstHdrA_MrBig_BlockG0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L164A80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $20,$F4,$00 ; $00
	db $20,$FC,$02 ; $01
	db $20,$04,$04 ; $02
	db $10,$F4,$06 ; $03
	db $10,$FC,$08 ; $04
		
OBJLstHdrA_MrBig_BlockC0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L164A80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_MrBig_BlockG0_A.bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $05 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_MrBig_BlockG0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L164B20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$F4,$00 ; $00
	db $30,$FC,$02 ; $01
	db $30,$04,$04 ; $02
		
OBJLstHdrB_MrBig_BlockC0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L164B80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FD ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $35,$F9,$00 ; $00
	db $35,$01,$02 ; $01
	db $35,$09,$04 ; $02
		
OBJLstHdrB_MrBig_BlockA0_B: ;X
	db $00 ; iOBJLstHdrA_Flags
	dpr L164BE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $0B ; iOBJLstHdrA_YOffset
.bin: ;X
	db $03 ; OBJ Count
	;    Y   X  ID
	db $25,$FC,$00 ; $00
	db $25,$04,$02 ; $01
	db $28,$0C,$04 ; $02
		
OBJLstHdrA_MrBig_JumpN1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1648C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $10,$F4,$00 ; $00
	db $0E,$FC,$02 ; $01
	db $0F,$04,$04 ; $02
	db $20,$F4,$06 ; $03
	db $1E,$FC,$08 ; $04
	db $1F,$04,$0A ; $05
	db $2E,$FC,$0C ; $06
	db $2F,$04,$0E ; $07
		
OBJLstHdrA_MrBig_CaliforniaRomanceL4:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1648C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_MrBig_JumpN1.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_MrBig_JumpN3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1649C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $12 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $0A,$F4,$00 ; $00
	db $09,$FC,$02 ; $01
	db $08,$04,$04 ; $02
	db $1A,$F4,$06 ; $03
	db $19,$FC,$08 ; $04
	db $18,$04,$0A ; $05
		
OBJLstHdrA_MrBig_ChargeMeter0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L166700 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $28,$F4,$00 ; $00
	db $21,$FC,$02 ; $01
	db $20,$04,$04 ; $02
	db $31,$FC,$06 ; $03
		
OBJLstHdrB_MrBig_ChargeMeter0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L166780 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $38,$F4,$00 ; $00
	db $30,$04,$02 ; $01
	db $36,$0C,$04 ; $02
	db $1B,$0C,$06 ; $03
	db $10,$04,$08 ; $04
		
OBJLstHdrA_MrBig_ChargeMeter1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L166820 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $06 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $20,$EC,$00 ; $00
	db $20,$F4,$02 ; $01
	db $20,$FC,$04 ; $02
	db $30,$EC,$06 ; $03
	db $30,$F4,$08 ; $04
		
OBJLstHdrA_MrBig_Taunt0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1668C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1B,$F1,$00 ; $00
	db $20,$F9,$02 ; $01
	db $20,$01,$04 ; $02
	db $1A,$09,$06 ; $03
	db $10,$F9,$08 ; $04
	db $10,$01,$0A ; $05
		
OBJLstHdrB_MrBig_Taunt0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L166980 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$FA,$00 ; $00
	db $30,$02,$02 ; $01
	db $3D,$0A,$04 ; $02
		
OBJLstHdrB_MrBig_WinB0_B:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	dpr L166980 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$FA,$00 ; $00
	db $30,$02,$02 ; $01
	db $3D,$0A,$04 ; $02
		
OBJLstHdrA_MrBig_Taunt1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1669E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $22,$EC,$00 ; $00
	db $20,$F4,$02 ; $01
	db $20,$FC,$04 ; $02
	db $20,$04,$06 ; $03
	db $21,$0C,$08 ; $04
	db $10,$FC,$0A ; $05
	db $10,$04,$0C ; $06
		
OBJLstHdrA_MrBig_WinA1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L166AC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $28,$F1,$00 ; $00
	db $28,$F9,$02 ; $01
	db $28,$01,$04 ; $02
	db $28,$09,$06 ; $03
	db $18,$F9,$08 ; $04
	db $18,$01,$0A ; $05
	db $18,$09,$0C ; $06
	db $08,$09,$0E ; $07
		
OBJLstHdrA_MrBig_WinB0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L166BC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FD ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $28,$FD,$00 ; $00
	db $28,$05,$02 ; $01
	db $18,$FC,$04 ; $02
	db $18,$04,$06 ; $03
	db $18,$0C,$08 ; $04
	db $17,$14,$0A ; $05
	db $28,$0D,$0C ; $06
		
OBJLstHdrA_MrBig_WinB1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L166CA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FD ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $29,$FE,$00 ; $00
	db $28,$06,$02 ; $01
	db $1A,$FC,$04 ; $02
	db $19,$04,$06 ; $03
	db $18,$0C,$08 ; $04
	db $24,$0E,$0A ; $05
		
OBJLstHdrA_MrBig_PunchL1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_66 ; iOBJLstHdrA_HitboxId
	dpr L164C40 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F6 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $18,$EC,$00 ; $00
	db $19,$F4,$02 ; $01
	db $20,$FC,$04 ; $02
	db $20,$04,$06 ; $03
	db $20,$0C,$08 ; $04
	db $10,$0C,$0A ; $05
		
OBJLstHdrB_MrBig_PunchL1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L164D00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F6 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$FF,$00 ; $00
	db $30,$07,$02 ; $01
	db $37,$0F,$04 ; $02
		
OBJLstHdrA_MrBig_WinA0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L164D60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $1A,$F3,$00 ; $00
	db $20,$FB,$02 ; $01
	db $20,$03,$04 ; $02
	db $20,$0B,$06 ; $03
	db $10,$03,$08 ; $04
		
OBJLstHdrA_MrBig_PunchH2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L164D60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_MrBig_WinA0_A.bin ; iOBJLstHdrA_DataPtr
	db $F6 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_MrBig_PunchCL0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L164D60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_MrBig_WinA0_A.bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $05 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_MrBig_WinA0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L164E00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$FC,$00 ; $00
	db $30,$04,$02 ; $01
	db $30,$0C,$04 ; $02
		
OBJLstHdrA_MrBig_PunchH0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L164E60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F4 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $16,$01,$00 ; $00
	db $1D,$09,$02 ; $01
	db $1A,$11,$04 ; $02
	db $12,$19,$06 ; $03
	db $26,$01,$08 ; $04
	db $2D,$09,$0A ; $05
	db $33,$11,$0C ; $06
	db $3A,$05,$0E ; $07
		
OBJLstHdrA_MrBig_PunchH1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_69 ; iOBJLstHdrA_HitboxId
	dpr L164F60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FF ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $1D,$E4,$00 ; $00
	db $20,$EC,$02 ; $01
	db $20,$F4,$04 ; $02
	db $20,$FC,$06 ; $03
	db $22,$04,$08 ; $04
	db $30,$F4,$0A ; $05
	db $30,$FC,$0C ; $06
	db $32,$04,$0E ; $07
	db $33,$0C,$10 ; $08
		
OBJLstHdrB_MrBig_PunchH2_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L165080 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $30,$F4,$00 ; $00
	db $30,$FC,$02 ; $01
	db $30,$04,$04 ; $02
	db $32,$0C,$06 ; $03
		
OBJLstHdrB_MrBig_PunchH3_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L165100 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $30,$F7,$00 ; $00
	db $30,$FF,$02 ; $01
	db $30,$07,$04 ; $02
	db $3D,$EF,$06 ; $03
		
OBJLstHdrA_MrBig_KickL1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_55 ; iOBJLstHdrA_HitboxId
	dpr L165180 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1C,$EF,$00 ; $00
	db $1F,$F7,$02 ; $01
	db $20,$FF,$04 ; $02
	db $20,$07,$06 ; $03
	db $10,$07,$08 ; $04
	db $18,$0F,$0A ; $05
	db $10,$FF,$0C ; $06
		
OBJLstHdrA_MrBig_KickA0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L165180 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_MrBig_KickL1_A.bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_MrBig_KickL1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L165260 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $30,$FC,$00 ; $00
	db $30,$04,$02 ; $01
		
OBJLstHdrA_MrBig_KickL0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1652A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1C,$F4,$00 ; $00
	db $16,$FC,$02 ; $01
	db $1C,$04,$04 ; $02
	db $2E,$F8,$06 ; $03
	db $26,$FC,$08 ; $04
	db $2C,$04,$0A ; $05
	db $3C,$04,$0C ; $06
		
OBJLstHdrB_MrBig_KickH0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L165380 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F0 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $25,$FD,$00 ; $00
	db $20,$05,$02 ; $01
	db $2C,$0C,$04 ; $02
	db $30,$04,$06 ; $03
		
OBJLstHdrB_MrBig_KickH1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L165400 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $EE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $27,$EC,$00 ; $00
	db $1F,$F4,$02 ; $01
	db $27,$FC,$04 ; $02
	db $2A,$04,$06 ; $03
	db $2D,$0C,$08 ; $04
	db $3A,$04,$0A ; $05
		
OBJLstHdrA_MrBig_PunchCL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_50 ; iOBJLstHdrA_HitboxId
	dpr L1654C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $21,$EA,$00 ; $00
	db $2A,$F2,$02 ; $01
	db $25,$FA,$04 ; $02
	db $26,$02,$06 ; $03
	db $35,$FA,$08 ; $04
	db $36,$02,$0A ; $05
	db $39,$0A,$0C ; $06
	db $3C,$12,$0E ; $07
		
OBJLstHdrB_MrBig_PunchCL0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1655C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $35,$FC,$00 ; $00
	db $35,$04,$02 ; $01
	db $35,$0C,$04 ; $02
		
OBJLstHdrA_MrBig_PunchCH0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L165620 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $29,$FB,$00 ; $00
	db $23,$03,$02 ; $01
	db $21,$0B,$04 ; $02
	db $21,$13,$06 ; $03
	db $39,$FB,$08 ; $04
	db $33,$03,$0A ; $05
	db $31,$0B,$0C ; $06
		
OBJLstHdrA_MrBig_PunchCH1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L165700 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $28,$F4,$00 ; $00
	db $18,$F4,$02 ; $01
	db $20,$FC,$04 ; $02
	db $20,$04,$06 ; $03
	db $20,$0C,$08 ; $04
	db $10,$FC,$0A ; $05
	db $10,$04,$0C ; $06
	db $10,$0C,$0E ; $07
		
OBJLstHdrB_MrBig_PunchCH1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L165800 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $38,$F4,$00 ; $00
	db $30,$FC,$02 ; $01
	db $30,$04,$04 ; $02
	db $30,$0C,$06 ; $03
		
OBJLstHdrA_MrBig_PunchCH2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L165880 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$00,$00 ; $00
	db $20,$08,$02 ; $01
	db $1D,$10,$04 ; $02
	db $28,$F8,$06 ; $03
		
OBJLstHdrA_MrBig_KickCL1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_4C ; iOBJLstHdrA_HitboxId
	dpr L165900 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $20,$F4,$00 ; $00
	db $20,$FC,$02 ; $01
	db $20,$04,$04 ; $02
	db $20,$0C,$06 ; $03
	db $30,$04,$08 ; $04
		
OBJLstHdrB_MrBig_KickCL1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1659A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $38,$EC,$00 ; $00
	db $30,$F4,$02 ; $01
	db $30,$FC,$04 ; $02
		
OBJLstHdrA_MrBig_KickCL0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L165A00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $28,$F4,$00 ; $00
	db $24,$FC,$02 ; $01
	db $24,$04,$04 ; $02
	db $20,$0C,$06 ; $03
	db $38,$F4,$08 ; $04
	db $34,$FC,$0A ; $05
	db $34,$04,$0C ; $06
		
OBJLstHdrA_MrBig_KickCH0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L165AE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F6 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $1C,$F5,$00 ; $00
	db $20,$FD,$02 ; $01
	db $20,$05,$04 ; $02
	db $30,$05,$06 ; $03
		
OBJLstHdrA_MrBig_KickH0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L165AE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_MrBig_KickCH0_A.bin ; iOBJLstHdrA_DataPtr
	db $F1 ; iOBJLstHdrA_XOffset
	db $F5 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_MrBig_KickCH0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L165B60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F6 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$FC,$00 ; $00
	db $30,$04,$02 ; $01
	db $38,$0C,$04 ; $02
		
OBJLstHdrA_MrBig_KickCH1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_6A ; iOBJLstHdrA_HitboxId
	dpr L165BC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F5 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$F3,$00 ; $00
	db $28,$FB,$02 ; $01
	db $28,$03,$04 ; $02
	db $18,$FC,$06 ; $03
		
OBJLstHdrA_MrBig_KickH1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_58 ; iOBJLstHdrA_HitboxId
	dpr L165BC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_MrBig_KickCH1_A.bin ; iOBJLstHdrA_DataPtr
	db $F6 ; iOBJLstHdrA_XOffset
	db $F5 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_MrBig_KickCH1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L165C40 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F5 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $38,$EC,$00 ; $00
	db $30,$F4,$02 ; $01
	db $38,$FC,$04 ; $02
	db $38,$04,$06 ; $03
		
OBJLstHdrA_MrBig_PunchA1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L165CC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $06 ; iOBJLstHdrA_XOffset
	db $11 ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $1D,$E1,$00 ; $00
	db $14,$E9,$02 ; $01
	db $0D,$F1,$04 ; $02
	db $0A,$F9,$06 ; $03
	db $0A,$01,$08 ; $04
	db $1D,$F1,$0A ; $05
	db $1A,$F9,$0C ; $06
	db $1A,$01,$0E ; $07
	db $2A,$F9,$10 ; $08
		
OBJLstHdrA_MrBig_PunchA0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L165DE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $15 ; iOBJLstHdrA_YOffset
.bin:
	db $0A ; OBJ Count
	;    Y   X  ID
	db $04,$EC,$00 ; $00
	db $05,$F4,$02 ; $01
	db $0A,$FC,$04 ; $02
	db $08,$04,$06 ; $03
	db $08,$0C,$08 ; $04
	db $14,$EC,$0A ; $05
	db $15,$F4,$0C ; $06
	db $1A,$FC,$0E ; $07
	db $18,$04,$10 ; $08
	db $1A,$0C,$12 ; $09
		
OBJLstHdrB_MrBig_KickA0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L165F20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $28,$01,$00 ; $00
	db $28,$09,$02 ; $01
		
OBJLstHdrA_MrBig_AttackG0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L165F60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $EF ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $28,$04,$00 ; $00
	db $28,$0C,$02 ; $01
	db $28,$14,$04 ; $02
	db $1D,$1C,$06 ; $03
	db $0D,$1C,$08 ; $04
	db $FD,$1C,$0A ; $05
	db $18,$0C,$0C ; $06
	db $18,$14,$0E ; $07
	db $18,$04,$10 ; $08
		
OBJLstHdrB_MrBig_AttackG0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L166080 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $EF ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $38,$06,$00 ; $00
	db $38,$0E,$02 ; $01
	db $38,$16,$04 ; $02
		
OBJLstHdrB_MrBig_DrumShotL0_B:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	dpr L166080 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_MrBig_AttackG0_B.bin ; iOBJLstHdrA_DataPtr
	db $11 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_MrBig_AttackG2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_43 ; iOBJLstHdrA_HitboxId
	dpr L1660E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F3 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $0B ; OBJ Count
	;    Y   X  ID
	db $26,$E8,$00 ; $00
	db $2C,$F0,$02 ; $01
	db $1F,$F8,$04 ; $02
	db $1F,$00,$06 ; $03
	db $1B,$08,$08 ; $04
	db $1B,$10,$0A ; $05
	db $16,$18,$0C ; $06
	db $32,$00,$0E ; $07
	db $2B,$08,$10 ; $08
	db $2B,$10,$12 ; $09
	db $35,$14,$14 ; $0A
		
OBJLstHdrA_MrBig_AttackA1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L166240 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $05 ; iOBJLstHdrA_XOffset
	db $11 ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $0C,$EC,$00 ; $00
	db $08,$F4,$02 ; $01
	db $08,$FC,$04 ; $02
	db $0C,$04,$06 ; $03
	db $1C,$EC,$08 ; $04
	db $18,$F4,$0A ; $05
	db $18,$FC,$0C ; $06
	db $1C,$04,$0E ; $07
	db $2C,$EC,$10 ; $08
		
OBJLstHdrA_MrBig_RollF1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1646E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $28,$F4,$00 ; $00
	db $25,$FC,$02 ; $01
	db $25,$04,$04 ; $02
	db $23,$0C,$06 ; $03
	db $38,$F4,$08 ; $04
	db $35,$FC,$0A ; $05
	db $35,$04,$0C ; $06
		
OBJLstHdrA_MrBig_RollF3:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1646E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_MrBig_RollF1.bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_MrBig_RollF2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1647C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $2C,$EC,$00 ; $00
	db $2A,$F4,$02 ; $01
	db $24,$FC,$04 ; $02
	db $2B,$04,$06 ; $03
	db $3C,$EC,$08 ; $04
	db $3A,$F4,$0A ; $05
	db $34,$FC,$0C ; $06
	db $3B,$04,$0E ; $07
		
OBJLstHdrA_MrBig_RollF0:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1647C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_MrBig_RollF2.bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $04 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_MrBig_TimeOver2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L166360 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $24,$F0,$00 ; $00
	db $28,$F6,$02 ; $01
	db $28,$FE,$04 ; $02
	db $18,$F8,$06 ; $03
	db $1D,$00,$08 ; $04
		
OBJLstHdrA_MrBig_HitSwoopup1_A:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L166360 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_MrBig_TimeOver2_A.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_MrBig_HitSwoopup2_A:
	db OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L166360 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_MrBig_TimeOver2_A.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_MrBig_ThrowEndA3_A:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L166360 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_MrBig_TimeOver2_A.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_MrBig_GuardBreakG0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L166400 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $20,$F0,$00 ; $00
	db $20,$F8,$02 ; $01
	db $20,$00,$04 ; $02
	db $20,$08,$06 ; $03
	db $10,$00,$08 ; $04
		
OBJLstHdrA_MrBig_Hitlow0_A: ;X
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L166400 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_MrBig_GuardBreakG0_A.bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $05 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_MrBig_GuardBreakG0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1664A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$F0,$00 ; $00
	db $30,$F8,$02 ; $01
	db $30,$00,$04 ; $02
		
OBJLstHdrB_MrBig_Hitlow0_B: ;X
	db $00 ; iOBJLstHdrA_Flags
	dpr L166500 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $09 ; iOBJLstHdrA_YOffset
.bin: ;X
	db $03 ; OBJ Count
	;    Y   X  ID
	db $2C,$F1,$00 ; $00
	db $2C,$F9,$02 ; $01
	db $2C,$01,$04 ; $02
		
OBJLstHdrA_MrBig_DropMain1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L166560 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FB ; iOBJLstHdrA_XOffset
	db $13 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $14,$F4,$00 ; $00
	db $14,$FC,$02 ; $01
	db $14,$04,$04 ; $02
	db $14,$0C,$06 ; $03
	db $19,$14,$08 ; $04
	db $24,$FC,$0A ; $05
	db $24,$04,$0C ; $06
	db $24,$0C,$0E ; $07
		
OBJLstHdrA_MrBig_ThrowRotL0:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L166560 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_MrBig_DropMain1.bin ; iOBJLstHdrA_DataPtr
	db $07 ; iOBJLstHdrA_XOffset
	db $FB ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_MrBig_DropMain2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L166660 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $35,$F4,$00 ; $00
	db $33,$FC,$02 ; $01
	db $34,$04,$04 ; $02
	db $33,$0C,$06 ; $03
	db $35,$14,$08 ; $04
		
OBJLstHdrA_MrBig_RunF0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L166F80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $28,$F4,$00 ; $00
	db $28,$FC,$02 ; $01
	db $28,$04,$04 ; $02
	db $1F,$0C,$06 ; $03
	db $1E,$EC,$08 ; $04
	db $18,$F4,$0A ; $05
	db $18,$FC,$0C ; $06
	db $18,$04,$0E ; $07
		
OBJLstHdrB_MrBig_RunF0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L167080 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $38,$F4,$00 ; $00
	db $38,$FC,$02 ; $01
	db $38,$04,$04 ; $02
	db $30,$0C,$06 ; $03
		
OBJLstHdrA_MrBig_RunF1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L167100 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $13,$F5,$00 ; $00
	db $21,$FD,$02 ; $01
	db $24,$05,$04 ; $02
	db $2A,$0D,$06 ; $03
	db $23,$F5,$08 ; $04
	db $31,$FD,$0A ; $05
	db $34,$05,$0C ; $06
		
OBJLstHdrA_MrBig_RunF2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1671E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $28,$EC,$00 ; $00
	db $28,$F4,$02 ; $01
	db $28,$FC,$04 ; $02
	db $28,$04,$06 ; $03
	db $1F,$0C,$08 ; $04
	db $18,$F4,$0A ; $05
	db $18,$FC,$0C ; $06
	db $18,$04,$0E ; $07
		
OBJLstHdrA_MrBig_ThrowG0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L166D60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $15,$F1,$00 ; $00
	db $20,$FA,$02 ; $01
	db $20,$02,$04 ; $02
	db $14,$F9,$06 ; $03
	db $10,$01,$08 ; $04
		
OBJLstHdrA_MrBig_ThrowG1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L166E00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $20,$F7,$00 ; $00
	db $20,$FF,$02 ; $01
	db $1E,$07,$04 ; $02
	db $17,$0F,$06 ; $03
	db $10,$FF,$08 ; $04
		
OBJLstHdrA_MrBig_ThrowG2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L166EA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $13,$FA,$00 ; $00
	db $14,$02,$02 ; $01
	db $23,$FA,$04 ; $02
	db $24,$02,$06 ; $03
	db $33,$FA,$08 ; $04
	db $34,$02,$0A ; $05
	db $3B,$0A,$0C ; $06
		
OBJLstHdrA_MrBig_AttackG1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1672E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FD ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1C,$EC,$00 ; $00
	db $20,$F4,$02 ; $01
	db $20,$FC,$04 ; $02
	db $20,$04,$06 ; $03
	db $20,$0C,$08 ; $04
	db $1B,$14,$0A ; $05
		
OBJLstHdrA_MrBig_SpinningLancerL6_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L1672E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_MrBig_AttackG1_A.bin ; iOBJLstHdrA_DataPtr
	db $FD ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_MrBig_AttackG1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1673A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FD ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $36,$F1,$00 ; $00
	db $30,$F9,$02 ; $01
	db $30,$01,$04 ; $02
	db $30,$09,$06 ; $03
		
OBJLstHdrA_MrBig_GroundBlasterL2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L167420 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $20,$EC,$00 ; $00
	db $28,$F4,$02 ; $01
	db $28,$FC,$04 ; $02
	db $28,$04,$06 ; $03
	db $18,$F4,$08 ; $04
	db $18,$FC,$0A ; $05
		
OBJLstHdrB_MrBig_GroundBlasterL2_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1674E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $38,$F4,$00 ; $00
	db $38,$FC,$02 ; $01
	db $38,$04,$04 ; $02
		
OBJLstHdrA_MrBig_CrossDivingL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_41 ; iOBJLstHdrA_HitboxId
	dpr L167540 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $07 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $26,$E4,$00 ; $00
	db $22,$EC,$02 ; $01
	db $22,$F4,$04 ; $02
	db $24,$FC,$06 ; $03
	db $23,$04,$08 ; $04
	db $1D,$0C,$0A ; $05
	db $1B,$14,$0C ; $06
		
OBJLstHdrA_MrBig_CrossDivingL3:
	db OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_41 ; iOBJLstHdrA_HitboxId
	dpr L167540 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_MrBig_CrossDivingL1.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $FA ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_MrBig_CrossDivingL2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_41 ; iOBJLstHdrA_HitboxId
	dpr L167620 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $20,$E4,$00 ; $00
	db $20,$EC,$02 ; $01
	db $20,$F4,$04 ; $02
	db $20,$FC,$06 ; $03
	db $20,$04,$08 ; $04
	db $1D,$0C,$0A ; $05
	db $24,$14,$0C ; $06
		
OBJLstHdrA_MrBig_CrossDivingL4:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_41 ; iOBJLstHdrA_HitboxId
	dpr L167700 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $20,$E4,$00 ; $00
	db $20,$EC,$02 ; $01
	db $20,$F4,$04 ; $02
	db $20,$FC,$06 ; $03
	db $20,$04,$08 ; $04
	db $24,$0C,$0A ; $05
	db $1B,$14,$0C ; $06
		
OBJLstHdrA_MrBig_SpinningLancerL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_42 ; iOBJLstHdrA_HitboxId
	dpr L1677E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $0A ; OBJ Count
	;    Y   X  ID
	db $20,$EC,$00 ; $00
	db $1A,$F4,$02 ; $01
	db $18,$FC,$04 ; $02
	db $1F,$04,$06 ; $03
	db $20,$0C,$08 ; $04
	db $14,$14,$0A ; $05
	db $2A,$F4,$0C ; $06
	db $28,$FC,$0E ; $07
	db $2F,$04,$10 ; $08
	db $38,$FC,$12 ; $09
		
OBJLstHdrA_MrBig_SpinningLancerL2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_42 ; iOBJLstHdrA_HitboxId
	dpr L167920 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $21,$E9,$00 ; $00
	db $17,$F1,$02 ; $01
	db $19,$F9,$04 ; $02
	db $19,$01,$06 ; $03
	db $29,$F4,$08 ; $04
	db $29,$FC,$0A ; $05
	db $29,$04,$0C ; $06
	db $39,$FB,$0E ; $07
		
OBJLstHdrA_MrBig_SpinningLancerL4:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_42 ; iOBJLstHdrA_HitboxId
	dpr L167920 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_MrBig_SpinningLancerL2.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_MrBig_SpinningLancerL3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_42 ; iOBJLstHdrA_HitboxId
	dpr L167A20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $0A ; OBJ Count
	;    Y   X  ID
	db $13,$E4,$00 ; $00
	db $16,$EC,$02 ; $01
	db $20,$F4,$04 ; $02
	db $18,$FC,$06 ; $03
	db $18,$04,$08 ; $04
	db $20,$0C,$0A ; $05
	db $28,$FC,$0C ; $06
	db $28,$04,$0E ; $07
	db $38,$00,$10 ; $08
	db $30,$0C,$12 ; $09
		
OBJLstHdrA_MrBig_CaliforniaRomanceH0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L167B60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F6 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $21,$F4,$00 ; $00
	db $20,$FC,$02 ; $01
	db $20,$04,$04 ; $02
	db $28,$0C,$06 ; $03
	db $33,$14,$08 ; $04
		
OBJLstHdrA_MrBig_CaliforniaRomanceH1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L167B60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_MrBig_CaliforniaRomanceH0_A.bin ; iOBJLstHdrA_DataPtr
	db $F5 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_MrBig_CaliforniaRomanceH0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L167C00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F6 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$FC,$00 ; $00
	db $30,$04,$02 ; $01
	db $38,$0C,$04 ; $02
		
OBJLstHdrB_MrBig_CaliforniaRomanceH1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L167C60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F5 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$FC,$00 ; $00
	db $30,$04,$02 ; $01
	db $38,$0C,$04 ; $02
		
OBJLstHdrA_MrBig_CaliforniaRomanceL2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_2D ; iOBJLstHdrA_HitboxId
	dpr L167CC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_MrBig_CaliforniaRomanceL3.bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_MrBig_CaliforniaRomanceL3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L167CC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $0D,$F4,$00 ; $00
	db $10,$FC,$02 ; $01
	db $1D,$F4,$04 ; $02
	db $20,$FC,$06 ; $03
	db $28,$04,$08 ; $04
	db $2D,$F4,$0A ; $05
	db $30,$FC,$0C ; $06
	db $18,$04,$0E ; $07
		
OBJLstHdrA_MrBig_DrumShotL0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L167DC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F7 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $28,$FC,$00 ; $00
	db $28,$04,$02 ; $01
	db $28,$0C,$04 ; $02
	db $18,$F4,$06 ; $03
	db $18,$FC,$08 ; $04
	db $18,$04,$0A ; $05
		
OBJLstHdrA_MrBig_DrumShotL1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L167E80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F7 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $22,$EC,$00 ; $00
	db $28,$F4,$02 ; $01
	db $28,$FC,$04 ; $02
	db $28,$04,$06 ; $03
	db $28,$0C,$08 ; $04
	db $18,$F3,$0A ; $05
	db $18,$FB,$0C ; $06
	db $18,$03,$0E ; $07
		
OBJLstHdrA_MrBig_DrumShotL2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L157C20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F7 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $28,$F9,$00 ; $00
	db $28,$01,$02 ; $01
	db $28,$09,$04 ; $02
	db $18,$01,$06 ; $03
	db $18,$09,$08 ; $04
	db $18,$11,$0A ; $05
		
OBJLstHdrA_MrBig_DrumShotL4_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L157CE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $28,$F4,$00 ; $00
	db $28,$FC,$02 ; $01
	db $28,$04,$04 ; $02
	db $26,$0C,$06 ; $03
	db $18,$F4,$08 ; $04
	db $18,$FC,$0A ; $05
	db $18,$04,$0C ; $06
		
OBJLstHdrA_MrBig_BlasterWaveS0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L157DC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $28,$04,$00 ; $00
	db $2D,$FC,$02 ; $01
	db $18,$04,$04 ; $02
	db $18,$0C,$06 ; $03
	db $1D,$FC,$08 ; $04
	db $28,$F4,$0A ; $05
	db $22,$EE,$0C ; $06
		
OBJLstHdrA_MrBig_BlasterWaveS1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L167F80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FF ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$F4,$00 ; $00
	db $20,$FC,$02 ; $01
	db $20,$04,$04 ; $02
	db $20,$0C,$06 ; $03
		
OBJLstHdrA_MrBig_BlasterWaveS2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L157EA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F5 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $26,$EB,$00 ; $00
	db $25,$F3,$02 ; $01
	db $28,$FB,$04 ; $02
	db $28,$03,$06 ; $03
	db $28,$0B,$08 ; $04
	db $16,$EB,$0A ; $05
	db $18,$FB,$0C ; $06
	db $18,$03,$0E ; $07
; =============== END OF BANK ===============		
	mIncJunk "L077E43"