OBJLstPtrTable_Mai_Idle:
	dw OBJLstHdrA_Mai_Idle0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_Idle1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_Idle2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_Idle3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_Idle4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_Idle3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_Idle2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_Idle1, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_WalkF:
	dw OBJLstHdrA_Mai_WalkF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_WalkF1_A, OBJLstHdrB_Mai_WalkF1_B
	dw OBJLstHdrA_Mai_WalkF2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_WalkB:
	dw OBJLstHdrA_Mai_WalkF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_WalkF1_A, OBJLstHdrB_Mai_WalkF1_B
	dw OBJLstHdrA_Mai_WalkF0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_Crouch:
	dw OBJLstHdrA_Mai_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_JumpN:
	dw OBJLstHdrA_Mai_Crouch0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_JumpN2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_JumpN3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_JumpN4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_JumpN5, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_JumpB:
	dw OBJLstHdrA_Mai_Crouch0, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Mai_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_JumpN5, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_JumpN4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_JumpN3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_JumpN2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_BlockG:
	dw OBJLstHdrA_Mai_BlockG0_A, OBJLstHdrB_Mai_BlockG0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_BlockC:
	dw OBJLstHdrA_Mai_BlockC0_A, OBJLstHdrB_Mai_BlockC0_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_BlockA:
	dw OBJLstHdrA_Mai_BlockA0_A, OBJLstHdrB_Mai_BlockA0_B ;X
	dw OBJLstHdrA_Mai_Crouch0, OBJLSTPTR_NONE ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_RunF:
	dw OBJLstHdrA_Mai_RunF0_A, OBJLstHdrB_Mai_RunF0_B
	dw OBJLstHdrA_Mai_RunF1_A, OBJLstHdrB_Mai_RunF1_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_HopB:
	dw OBJLstHdrA_Mai_HopB0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_HopB0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_ChargeMeter:
	dw OBJLstHdrA_Mai_ChargeMeter0_A, OBJLstHdrB_Mai_ChargeMeter0_B
	dw OBJLstHdrA_Mai_ChargeMeter1_A, OBJLstHdrB_Mai_ChargeMeter0_B
	dw OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE;X

OBJLstPtrTable_Mai_Taunt:
	dw OBJLstHdrA_Mai_Taunt0_A, OBJLstHdrB_Mai_WalkF1_B
	dw OBJLstHdrA_Mai_Taunt1_A, OBJLstHdrB_Mai_Taunt1_B
	dw OBJLstHdrA_Mai_Taunt2_A, OBJLstHdrB_Mai_Taunt1_B
	dw OBJLstHdrA_Mai_Taunt1_A, OBJLstHdrB_Mai_Taunt1_B
	dw OBJLstHdrA_Mai_Taunt2_A, OBJLstHdrB_Mai_Taunt1_B
	dw OBJLstHdrA_Mai_Taunt1_A, OBJLstHdrB_Mai_Taunt1_B
	dw OBJLstHdrA_Mai_Taunt2_A, OBJLstHdrB_Mai_Taunt1_B
	dw OBJLstHdrA_Mai_Taunt1_A, OBJLstHdrB_Mai_Taunt1_B
	dw OBJLstHdrA_Mai_Taunt2_A, OBJLstHdrB_Mai_Taunt1_B
	dw OBJLstHdrA_Mai_Taunt1_A, OBJLstHdrB_Mai_Taunt1_B
	dw OBJLstHdrA_Mai_Taunt2_A, OBJLstHdrB_Mai_Taunt1_B
	dw OBJLstHdrA_Mai_Taunt11_A, OBJLstHdrB_Mai_Taunt1_B
	dw OBJLstHdrA_Mai_Taunt1_A, OBJLstHdrB_Mai_Taunt1_B
	dw OBJLstHdrA_Mai_Taunt0_A, OBJLstHdrB_Mai_WalkF1_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_Intro:
	dw OBJLstHdrA_Mai_Intro0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_Intro1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_Intro2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_Intro3_A, OBJLstHdrB_Mai_Intro3_B
	dw OBJLstHdrA_Mai_Intro4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_Intro5, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_Intro6, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_Intro7_A, OBJLstHdrB_Mai_Intro3_B
	dw OBJLstHdrA_Mai_Intro8, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_WinA:
	dw OBJLstHdrA_Mai_WinA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_WinA1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_WinA2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_WinA2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_WinA2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_WinA2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_WinA6, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_WinA7, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_WinB:
	dw OBJLstHdrA_Mai_WinB0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_WinB1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_WinB2_A, OBJLstHdrB_Mai_WinB2_B
	dw OBJLstHdrA_Mai_WinB3_A, OBJLstHdrB_Mai_WinB2_B
	dw OBJLstHdrA_Mai_WinB4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_WinB5_A, OBJLstHdrB_Mai_WinB5_B
	dw OBJLstHdrA_Mai_WinB6_A, OBJLstHdrB_Mai_WinB5_B
	dw OBJLstHdrA_Mai_WinB5_A, OBJLstHdrB_Mai_WinB5_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_PunchL:
	dw OBJLstHdrA_Mai_PunchL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_PunchL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_PunchL0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_PunchH:
	dw OBJLstHdrA_Mai_WinB0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_PunchH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_PunchH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_Intro8, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_KickL:
	dw OBJLstHdrA_Mai_HopB0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_KickL1_A, OBJLstHdrB_Mai_KickL1_B
	dw OBJLstHdrA_Mai_HopB0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_KickH:
	dw OBJLstHdrA_Mai_HopB0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_KickH1_A, OBJLstHdrB_Mai_KickL1_B
	dw OBJLstHdrA_Mai_KickH1_A, OBJLstHdrB_Mai_KickL1_B
	dw OBJLstHdrA_Mai_HopB0, OBJLSTPTR_NONE ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_PunchCL:
	dw OBJLstHdrA_Mai_PunchCL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_PunchCL1_A, OBJLstHdrB_Mai_PunchCL1_B
	dw OBJLstHdrA_Mai_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_PunchCH:
	dw OBJLstHdrA_Mai_PunchCH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_PunchCH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_PunchCH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_PunchCH0, OBJLSTPTR_NONE ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_KickCL:
	dw OBJLstHdrA_Mai_KickCL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_KickCL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_KickCL0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_KickCH:
	dw OBJLstHdrA_Mai_KickCH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_KickCH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_KickCH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_KickCH0, OBJLSTPTR_NONE ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_PunchA:
	dw OBJLstHdrA_Mai_PunchA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_PunchA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_KickA:
	dw OBJLstHdrA_Mai_KickA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_KickA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_JumpN1, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Mai_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_AttackA:
	dw OBJLstHdrA_Mai_AttackA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_AttackA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_JumpN1, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Mai_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_AttackG:
	dw OBJLstHdrA_Mai_WinA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_AttackG1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_AttackG1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_WinA1, OBJLSTPTR_NONE ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_RollF:
	dw OBJLstHdrA_Mai_RollF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_RollF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_RollF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_RollF3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_RollB:
	dw OBJLstHdrA_Mai_RollF3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_RollB1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_RollB1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_RollF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_GuardBreakG:
	dw OBJLstHdrA_Mai_GuardBreakG0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_Dizzy:
	dw OBJLstHdrA_Mai_Idle0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_GuardBreakG0, OBJLSTPTR_NONE
OBJLstPtrTable_Mai_TimeOver:
	dw OBJLstHdrA_Mai_TimeOver2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_Hitlow:
	dw OBJLstHdrA_Mai_Hitlow0, OBJLSTPTR_NONE ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_GuardBreakA:
	dw OBJLstHdrA_Mai_GuardBreakG0, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Mai_Crouch0, OBJLSTPTR_NONE ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_BackjumpRecA:
	dw OBJLstHdrA_Mai_GuardBreakG0, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Mai_JumpN5, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Mai_JumpN4, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Mai_JumpN3, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Mai_JumpN2, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Mai_JumpN1, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Mai_Crouch0, OBJLSTPTR_NONE ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_DropMain:
	dw OBJLstHdrA_Mai_GuardBreakG0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_DropMain2, OBJLSTPTR_NONE
OBJLstPtrTable_Mai_HitMultigs:
	dw OBJLstHdrA_Mai_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_DropMain2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_HitSwoopup:
	dw OBJLstHdrA_Mai_TimeOver2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_HitSwoopup1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_HitSwoopup2, OBJLSTPTR_NONE
OBJLstPtrTable_Mai_ThrowEndA:
	dw OBJLstHdrA_Mai_ThrowEndA3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_ThrowEndA3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_DropMain2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_DropDbg:
	dw OBJLstHdrA_Mai_TimeOver2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_DropMain2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_ThrowRotL:
	dw OBJLstHdrA_Mai_ThrowRotL0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_Wakeup:
	dw OBJLstHdrA_Mai_Crouch0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_KaCHoSenL:
	dw OBJLstHdrA_Mai_KaCHoSenL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_PunchL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_KaCHoSenL2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_KaCHoSenL3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_Intro8, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_CHijouMusasabiL:
	dw OBJLstHdrA_Mai_Crouch0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_JumpN2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_JumpN3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_JumpN4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_JumpN5, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_JumpN2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_JumpN1, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Mai_Crouch0, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Mai_JumpN2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_KuuchuuMusasabiL:
	dw OBJLstHdrA_Mai_JumpN2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_KuuchuuMusasabiL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_HissatsuShinobibachiL:
	dw OBJLstHdrA_Mai_RollF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_RollF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_RollF3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_HissatsuShinobibachiL3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_HissatsuShinobibachiL3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_Crouch0, OBJLSTPTR_NONE ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_HishoRyuEnJinL:
	dw OBJLstHdrA_Mai_Intro8, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_HishoRyuEnJinL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_HishoRyuEnJinL2_A, OBJLstHdrB_Mai_HishoRyuEnJinL2_B
	dw OBJLstHdrA_Mai_HishoRyuEnJinL3_A, OBJLstHdrB_Mai_HishoRyuEnJinL3_B
	dw OBJLstHdrA_Mai_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_RyuEnBuL:
	dw OBJLstHdrA_Mai_RyuEnBuL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_WinA1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_RyuEnBuL2_A, OBJLstHdrB_Mai_RyuEnBuL2_B
	dw OBJLstHdrA_Mai_RyuEnBuL3_A, OBJLstHdrB_Mai_RyuEnBuL3_B
	dw OBJLstHdrA_Mai_RyuEnBuL4_A, OBJLstHdrB_Mai_RyuEnBuL3_B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_CHoHissatsuShinobibachiS:
	dw OBJLstHdrA_Mai_RollF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_RollF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_RollF3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_CHoHissatsuShinobibachiS3_A, OBJLstHdrB_Mai_CHoHissatsuShinobibachiS3_B
	dw OBJLstHdrA_Mai_CHoHissatsuShinobibachiS4_A, OBJLstHdrB_Mai_CHoHissatsuShinobibachiS3_B
	dw OBJLstHdrA_Mai_CHoHissatsuShinobibachiS3_A, OBJLstHdrB_Mai_CHoHissatsuShinobibachiS3_B
	dw OBJLstHdrA_Mai_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_CHoHissatsuShinobibachiD:
	dw OBJLstHdrA_Mai_HishoRyuEnJinL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_CHoHissatsuShinobibachiD1_A, OBJLstHdrB_Mai_HishoRyuEnJinL2_B
	dw OBJLstHdrA_Mai_CHoHissatsuShinobibachiD2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_HopB0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_RollF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_RollF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_RollF3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_CHoHissatsuShinobibachiD7_A, OBJLstHdrB_Mai_CHoHissatsuShinobibachiS3_B
	dw OBJLstHdrA_Mai_CHoHissatsuShinobibachiD8_A, OBJLstHdrB_Mai_CHoHissatsuShinobibachiS3_B
	dw OBJLstHdrA_Mai_CHoHissatsuShinobibachiD7_A, OBJLstHdrB_Mai_CHoHissatsuShinobibachiS3_B
	dw OBJLstHdrA_Mai_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_ThrowG:
	dw OBJLstHdrA_Mai_ThrowG0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_ThrowG1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_ThrowG2_A, OBJLstHdrB_Mai_HishoRyuEnJinL2_B
	dw OBJLstHdrA_Mai_ThrowG3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_ThrowG4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mai_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mai_ThrowA:
	dw OBJLstHdrA_Mai_ThrowA0_A, OBJLstHdrB_Mai_BlockA0_B ;X
	dw OBJLstHdrA_Mai_ThrowA1, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Mai_ThrowA2, OBJLSTPTR_NONE ;X
	dw OBJLSTPTR_NONE
		
OBJLstHdrA_Mai_Idle0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_Idle0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $20,$F4,$00 ; $00
	db $20,$FC,$02 ; $01
	db $20,$04,$04 ; $02
	db $30,$F4,$06 ; $03
	db $30,$FC,$08 ; $04
	db $30,$04,$0A ; $05
		
OBJLstHdrA_Mai_Idle1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_Idle1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $20,$F4,$00 ; $00
	db $20,$FC,$02 ; $01
	db $21,$04,$04 ; $02
	db $30,$F4,$06 ; $03
	db $30,$FC,$08 ; $04
	db $32,$04,$0A ; $05
		
OBJLstHdrA_Mai_Idle2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_Idle2 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $23,$F4,$00 ; $00
	db $20,$FC,$02 ; $01
	db $1D,$04,$04 ; $02
	db $33,$F4,$06 ; $03
	db $30,$FC,$08 ; $04
	db $32,$04,$0A ; $05
		
OBJLstHdrA_Mai_Idle3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_Idle3 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $24,$F4,$00 ; $00
	db $20,$FC,$02 ; $01
	db $1D,$04,$04 ; $02
	db $34,$F4,$06 ; $03
	db $30,$FC,$08 ; $04
	db $35,$04,$0A ; $05
		
OBJLstHdrA_Mai_Idle4:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_Idle4 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $25,$F4,$00 ; $00
	db $20,$FC,$02 ; $01
	db $1E,$04,$04 ; $02
	db $35,$F4,$06 ; $03
	db $30,$FC,$08 ; $04
	db $36,$04,$0A ; $05
		
OBJLstHdrA_Mai_WalkF0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_WalkF0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $31,$EF,$00 ; $00
	db $21,$F4,$02 ; $01
	db $20,$FC,$04 ; $02
	db $1F,$00,$06 ; $03
	db $30,$FB,$08 ; $04
	db $30,$03,$0A ; $05
		
OBJLstHdrA_Mai_WalkF1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_WalkF1_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$EC,$00 ; $00
	db $28,$F4,$02 ; $01
	db $20,$FC,$04 ; $02
		
OBJLstHdrB_Mai_WalkF1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Mai_WalkF1_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $18,$F4,$00 ; $00
	db $18,$FC,$02 ; $01
	db $20,$04,$04 ; $02
	db $30,$F5,$06 ; $03
	db $30,$FD,$08 ; $04
		
OBJLstHdrA_Mai_WalkF2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_WalkF2 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $33,$EC,$00 ; $00
	db $24,$F1,$02 ; $01
	db $1B,$F9,$04 ; $02
	db $20,$00,$06 ; $03
	db $2B,$F8,$08 ; $04
	db $30,$00,$0A ; $05
	db $3B,$F8,$0C ; $06
		
OBJLstHdrA_Mai_Crouch0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_Crouch0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $2B,$EF,$00 ; $00
	db $28,$F7,$02 ; $01
	db $2E,$FF,$04 ; $02
	db $3B,$EF,$06 ; $03
	db $38,$F7,$08 ; $04
	db $3E,$FF,$0A ; $05
		
OBJLstHdrA_Mai_BlockG0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_BlockG0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $08 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $20,$F4,$00 ; $00
	db $20,$FC,$02 ; $01
		
OBJLstHdrA_Mai_BlockC0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_BlockG0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mai_BlockG0_A.bin ; iOBJLstHdrA_DataPtr
	db $06 ; iOBJLstHdrA_XOffset
	db $04 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mai_BlockA0_A: ;X
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_BlockG0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mai_BlockG0_A.bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $FC ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mai_ThrowA0_A: ;X
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_BlockG0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mai_BlockG0_A.bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $FC ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Mai_BlockG0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Mai_BlockG0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $08 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $37,$EB,$00 ; $00
	db $30,$F3,$02 ; $01
	db $30,$FB,$04 ; $02
		
OBJLstHdrB_Mai_BlockC0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Mai_BlockC0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $06 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $3D,$EC,$00 ; $00
	db $34,$F4,$02 ; $01
	db $34,$FC,$04 ; $02
		
OBJLstHdrB_Mai_BlockA0_B: ;X
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Mai_BlockA0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $0C ; iOBJLstHdrA_YOffset
.bin: ;X
	db $03 ; OBJ Count
	;    Y   X  ID
	db $20,$FC,$00 ; $00
	db $20,$04,$02 ; $01
	db $20,$0C,$04 ; $02
		
OBJLstHdrA_Mai_JumpN1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_JumpN1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mai_ThrowA2.bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $01 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mai_ThrowA2: ;X
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_JumpN1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $01 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $19,$F3,$00 ; $00
	db $19,$FB,$02 ; $01
	db $29,$F3,$04 ; $02
	db $29,$FB,$06 ; $03
	db $39,$FB,$08 ; $04
		
OBJLstHdrA_Mai_JumpN2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_JumpN2 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $0C ; iOBJLstHdrA_XOffset
	db $18 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $10,$E1,$00 ; $00
	db $10,$E9,$02 ; $01
	db $10,$F1,$04 ; $02
	db $10,$F9,$06 ; $03
		
OBJLstHdrA_Mai_JumpN4:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_JumpN2 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mai_JumpN2.bin ; iOBJLstHdrA_DataPtr
	db $F5 ; iOBJLstHdrA_XOffset
	db $E9 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mai_JumpN3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_JumpN3 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $1A ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $09,$F4,$00 ; $00
	db $09,$FC,$02 ; $01
	db $19,$F4,$04 ; $02
	db $19,$FC,$06 ; $03
		
OBJLstHdrA_Mai_JumpN5:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_JumpN3 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mai_JumpN3.bin ; iOBJLstHdrA_DataPtr
	db $FD ; iOBJLstHdrA_XOffset
	db $E3 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mai_ChargeMeter0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_ChargeMeter0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $28,$F3,$00 ; $00
	db $28,$FB,$02 ; $01
	db $28,$03,$04 ; $02
	db $18,$FB,$06 ; $03
	db $18,$03,$08 ; $04
		
OBJLstHdrB_Mai_ChargeMeter0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Mai_ChargeMeter0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $38,$F4,$00 ; $00
	db $38,$FC,$02 ; $01
	db $38,$04,$04 ; $02
		
OBJLstHdrA_Mai_ChargeMeter1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_ChargeMeter1_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $28,$F3,$00 ; $00
	db $28,$FB,$02 ; $01
	db $28,$03,$04 ; $02
	db $18,$FB,$06 ; $03
	db $18,$03,$08 ; $04
		
OBJLstHdrA_Mai_Taunt0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_Taunt0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $28,$FC,$00 ; $00
	db $20,$04,$02 ; $01
		
OBJLstHdrA_Mai_Taunt1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_Taunt1_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $20,$F4,$00 ; $00
	db $18,$FC,$02 ; $01
		
OBJLstHdrB_Mai_Taunt1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Mai_Taunt1_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $15,$02,$00 ; $00
	db $22,$0A,$02 ; $01
	db $28,$FC,$04 ; $02
	db $25,$04,$06 ; $03
	db $38,$FC,$08 ; $04
	db $35,$04,$0A ; $05
		
OBJLstHdrA_Mai_Taunt2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_Taunt2_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $20,$F4,$00 ; $00
	db $18,$FC,$02 ; $01
		
OBJLstHdrA_Mai_Taunt11_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_Taunt11_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $20,$F4,$00 ; $00
	db $18,$FC,$02 ; $01
		
OBJLstHdrA_Mai_WinA2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_WinA2 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $27,$F4,$00 ; $00
	db $22,$FC,$02 ; $01
	db $22,$04,$04 ; $02
	db $2A,$0C,$06 ; $03
	db $37,$F4,$08 ; $04
	db $32,$FC,$0A ; $05
	db $32,$04,$0C ; $06
	db $3D,$0C,$0E ; $07
		
OBJLstHdrA_Mai_WinA6:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_WinA6 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $1D,$FC,$00 ; $00
	db $16,$04,$02 ; $01
	db $16,$0C,$04 ; $02
	db $2D,$FC,$06 ; $03
	db $26,$04,$08 ; $04
	db $26,$0C,$0A ; $05
	db $3D,$FC,$0C ; $06
	db $36,$04,$0E ; $07
		
OBJLstHdrA_Mai_WinA7:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_WinA7 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $20,$F4,$00 ; $00
	db $15,$FC,$02 ; $01
	db $14,$04,$04 ; $02
	db $25,$FC,$06 ; $03
	db $24,$04,$08 ; $04
	db $30,$F5,$0A ; $05
	db $35,$FD,$0C ; $06
	db $1D,$0C,$0E ; $07
		
OBJLstHdrA_Mai_WinB1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_WinB1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $17,$E9,$00 ; $00
	db $1B,$F1,$02 ; $01
	db $1D,$F9,$04 ; $02
	db $2B,$F1,$06 ; $03
	db $2D,$F9,$08 ; $04
	db $2D,$01,$0A ; $05
	db $3B,$F6,$0C ; $06
		
OBJLstHdrA_Mai_WinB2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_WinB2_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $19,$EE,$00 ; $00
	db $08,$F4,$02 ; $01
	db $18,$F6,$04 ; $02
	db $28,$F4,$06 ; $03
	db $20,$FC,$08 ; $04
		
OBJLstHdrB_Mai_WinB2_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Mai_WinB2_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $38,$F4,$00 ; $00
	db $30,$FC,$02 ; $01
		
OBJLstHdrA_Mai_WinB3_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_WinB3_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $0B,$EF,$00 ; $00
	db $08,$F7,$02 ; $01
	db $1D,$F8,$04 ; $02
	db $1E,$F0,$06 ; $03
	db $2D,$F7,$08 ; $04
		
OBJLstHdrA_Mai_WinB4:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_WinB4 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1C,$F3,$00 ; $00
	db $29,$EF,$02 ; $01
	db $0C,$FB,$04 ; $02
	db $1C,$FB,$06 ; $03
	db $2C,$F7,$08 ; $04
	db $3C,$F6,$0A ; $05
		
OBJLstHdrA_Mai_WinB5_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_WinB5_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $28,$F4,$00 ; $00
	db $28,$FC,$02 ; $01
		
OBJLstHdrB_Mai_WinB5_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Mai_WinB5_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $18,$F4,$00 ; $00
	db $18,$FC,$02 ; $01
	db $1C,$04,$04 ; $02
	db $20,$0C,$06 ; $03
	db $2B,$F0,$08 ; $04
	db $30,$F8,$0A ; $05
		
OBJLstHdrA_Mai_WinB6_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_WinB6_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $28,$F4,$00 ; $00
	db $28,$FC,$02 ; $01
		
OBJLstHdrA_Mai_Intro0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_Intro0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $20,$FF,$00 ; $00
	db $1B,$07,$02 ; $01
	db $30,$FF,$04 ; $02
	db $2B,$07,$06 ; $03
	db $3B,$07,$08 ; $04
	db $21,$0F,$0A ; $05
	db $3C,$0F,$0C ; $06
		
OBJLstHdrA_Mai_Intro1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_Intro1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FB ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1F,$FC,$00 ; $00
	db $1D,$04,$02 ; $01
	db $2F,$FC,$04 ; $02
	db $2D,$04,$06 ; $03
	db $3F,$FC,$08 ; $04
	db $3D,$04,$0A ; $05
	db $3C,$0C,$0C ; $06
		
OBJLstHdrA_Mai_Intro2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_Intro2 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $20,$02,$00 ; $00
	db $20,$0A,$02 ; $01
	db $2D,$16,$04 ; $02
	db $30,$FE,$06 ; $03
	db $30,$06,$08 ; $04
	db $30,$0E,$0A ; $05
		
OBJLstHdrA_Mai_Intro3_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_Intro3_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $18,$FC,$00 ; $00
	db $18,$04,$02 ; $01
	db $10,$0C,$04 ; $02
	db $20,$0C,$06 ; $03
		
OBJLstHdrB_Mai_Intro3_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Mai_Intro3_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $21,$EC,$00 ; $00
	db $21,$F4,$02 ; $01
	db $28,$FC,$04 ; $02
	db $28,$04,$06 ; $03
	db $29,$14,$08 ; $04
	db $38,$FC,$0A ; $05
	db $38,$04,$0C ; $06
	db $30,$0C,$0E ; $07
	db $3D,$14,$10 ; $08
		
OBJLstHdrA_Mai_Intro4:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_Intro4 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F0 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $13,$04,$00 ; $00
	db $13,$0C,$02 ; $01
	db $20,$14,$04 ; $02
	db $23,$04,$06 ; $03
	db $23,$0C,$08 ; $04
	db $33,$04,$0A ; $05
	db $33,$0C,$0C ; $06
	db $30,$14,$0E ; $07
		
OBJLstHdrA_Mai_Intro6:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_Intro4 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mai_Intro4.bin ; iOBJLstHdrA_DataPtr
	db $10 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mai_Intro5:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_Intro5 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F0 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $2A,$FC,$00 ; $00
	db $15,$05,$02 ; $01
	db $20,$0C,$04 ; $02
	db $1A,$13,$06 ; $03
	db $0D,$14,$08 ; $04
	db $25,$04,$0A ; $05
	db $30,$09,$0C ; $06
	db $30,$11,$0E ; $07
		
OBJLstHdrA_Mai_Intro7_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_Intro7_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F0 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $18,$04,$00 ; $00
	db $18,$0C,$02 ; $01
	db $20,$14,$04 ; $02
		
OBJLstHdrA_Mai_PunchL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_51 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_PunchL1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $24,$E6,$00 ; $00
	db $2C,$EE,$02 ; $01
	db $26,$F6,$04 ; $02
	db $20,$FE,$06 ; $03
	db $36,$F6,$08 ; $04
	db $30,$FE,$0A ; $05
	db $34,$06,$0C ; $06
		
OBJLstHdrA_Mai_PunchL0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_PunchL0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $22,$FB,$00 ; $00
	db $22,$03,$02 ; $01
	db $32,$FB,$04 ; $02
	db $32,$03,$06 ; $03
	db $37,$0B,$08 ; $04
		
OBJLstHdrA_Mai_WinB0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_WinB0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $2A,$EC,$00 ; $00
	db $24,$F4,$02 ; $01
	db $21,$FC,$04 ; $02
	db $1F,$04,$06 ; $03
	db $34,$F4,$08 ; $04
	db $31,$FC,$0A ; $05
	db $33,$04,$0C ; $06
		
OBJLstHdrA_Mai_PunchH1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_5F ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_PunchH1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $18,$E8,$00 ; $00
	db $1E,$F0,$02 ; $01
	db $20,$F8,$04 ; $02
	db $21,$00,$06 ; $03
	db $39,$F0,$08 ; $04
	db $30,$F8,$0A ; $05
	db $31,$00,$0C ; $06
	db $34,$08,$0E ; $07
	db $1C,$08,$10 ; $08
		
OBJLstHdrA_Mai_Intro8:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_Intro8 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrA_Mai_KickL1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_60 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_KickL1_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $25,$EC,$00 ; $00
	db $25,$F4,$02 ; $01
	db $28,$FC,$04 ; $02
		
OBJLstHdrB_Mai_KickL1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Mai_KickL1_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $18,$FC,$00 ; $00
	db $18,$04,$02 ; $01
	db $28,$04,$04 ; $02
	db $28,$0C,$06 ; $03
	db $38,$FF,$08 ; $04
		
OBJLstHdrA_Mai_HopB0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_HopB0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $20,$F9,$00 ; $00
	db $1E,$01,$02 ; $01
	db $30,$F9,$04 ; $02
	db $2E,$01,$06 ; $03
	db $20,$09,$08 ; $04
	db $3E,$01,$0A ; $05
		
OBJLstHdrA_Mai_WinA1:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_HopB0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mai_HopB0.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mai_KickH1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_55 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_KickH1_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $29,$EC,$00 ; $00
	db $25,$F4,$02 ; $01
	db $28,$FC,$04 ; $02
		
OBJLstHdrA_Mai_PunchCL1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_5E ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_PunchCL1_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F0 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $30,$F4,$00 ; $00
	db $30,$FC,$02 ; $01
		
OBJLstHdrB_Mai_PunchCL1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Mai_PunchCL1_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F0 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $2B,$04,$00 ; $00
	db $28,$0C,$02 ; $01
	db $2D,$14,$04 ; $02
	db $3B,$04,$06 ; $03
	db $38,$0C,$08 ; $04
	db $3D,$14,$0A ; $05
		
OBJLstHdrB_Mai_RyuEnBuL2_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Mai_PunchCL1_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_Mai_PunchCL1_B.bin ; iOBJLstHdrA_DataPtr
	db $F0 ; iOBJLstHdrA_XOffset
	db $FC ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mai_PunchCL0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_PunchCL0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F0 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $2A,$04,$00 ; $00
	db $28,$0C,$02 ; $01
	db $31,$14,$04 ; $02
	db $39,$FC,$06 ; $03
	db $3A,$04,$08 ; $04
	db $38,$0C,$0A ; $05
		
OBJLstHdrA_Mai_PunchCH0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_PunchCH0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F4 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $28,$FF,$00 ; $00
	db $26,$07,$02 ; $01
	db $1C,$0F,$04 ; $02
	db $38,$FF,$06 ; $03
	db $36,$07,$08 ; $04
	db $36,$0F,$0A ; $05
		
OBJLstHdrA_Mai_PunchCH1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_4E ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_PunchCH1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $EC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $2D,$FA,$00 ; $00
	db $2D,$02,$02 ; $01
	db $31,$0A,$04 ; $02
	db $37,$12,$06 ; $03
	db $3D,$FA,$08 ; $04
	db $3D,$02,$0A ; $05
		
OBJLstHdrA_Mai_KickCL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_56 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_KickCL1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F2 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $3B,$FC,$00 ; $00
	db $38,$04,$02 ; $01
	db $38,$0C,$04 ; $02
	db $30,$14,$06 ; $03
	db $28,$04,$08 ; $04
	db $28,$0C,$0A ; $05
		
OBJLstHdrA_Mai_KickCL0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_KickCL0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mai_ThrowA1.bin ; iOBJLstHdrA_DataPtr
	db $F2 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mai_ThrowA1: ;X
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_KickCL0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F2 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $28,$04,$00 ; $00
	db $28,$0C,$02 ; $01
	db $30,$14,$04 ; $02
	db $38,$04,$06 ; $03
	db $38,$0C,$08 ; $04
		
OBJLstHdrA_Mai_KickCH0:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_KickCL0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mai_ThrowA1.bin ; iOBJLstHdrA_DataPtr
	db $0E ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mai_KickCH1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_5E ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_KickCH1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $37,$F0,$00 ; $00
	db $36,$F8,$02 ; $01
	db $3A,$00,$04 ; $02
	db $38,$08,$06 ; $03
	db $2A,$00,$08 ; $04
	db $28,$08,$0A ; $05
	db $30,$10,$0C ; $06
		
OBJLstHdrA_Mai_PunchA0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_PunchA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $0E ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $19,$E2,$00 ; $00
	db $17,$EA,$02 ; $01
	db $13,$F2,$04 ; $02
	db $10,$FA,$06 ; $03
	db $1D,$02,$08 ; $04
	db $08,$02,$0A ; $05
	db $23,$F2,$0C ; $06
	db $20,$FA,$0E ; $07
		
OBJLstHdrA_Mai_KickA0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_KickA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $10 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $24,$EC,$00 ; $00
	db $11,$F4,$02 ; $01
	db $10,$FC,$04 ; $02
	db $10,$04,$06 ; $03
	db $0D,$0C,$08 ; $04
	db $21,$F4,$0A ; $05
	db $20,$FC,$0C ; $06
	db $20,$04,$0E ; $07
		
OBJLstHdrA_Mai_WinA0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_WinA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1D,$EF,$00 ; $00
	db $1E,$F7,$02 ; $01
	db $1D,$FF,$04 ; $02
	db $2E,$F7,$06 ; $03
	db $2D,$FF,$08 ; $04
	db $2A,$07,$0A ; $05
	db $3D,$F9,$0C ; $06
		
OBJLstHdrA_Mai_RyuEnBuL0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_WinA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mai_WinA0.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mai_AttackG1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_4A ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_AttackG1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $2C,$E4,$00 ; $00
	db $24,$EC,$02 ; $01
	db $21,$F4,$04 ; $02
	db $20,$FC,$06 ; $03
	db $23,$04,$08 ; $04
	db $31,$F4,$0A ; $05
	db $30,$FC,$0C ; $06
	db $33,$04,$0E ; $07
		
OBJLstHdrA_Mai_AttackA0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_AttackA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $08 ; iOBJLstHdrA_XOffset
	db $0E ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $24,$E7,$00 ; $00
	db $1F,$EF,$02 ; $01
	db $08,$F7,$04 ; $02
	db $06,$FF,$06 ; $03
	db $0E,$07,$08 ; $04
	db $0A,$0F,$0A ; $05
	db $18,$F7,$0C ; $06
	db $16,$FF,$0E ; $07
		
OBJLstHdrA_Mai_RollF0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_RollF0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $2A,$F4,$00 ; $00
	db $2F,$FC,$02 ; $01
	db $2C,$04,$04 ; $02
	db $2C,$0C,$06 ; $03
	db $2E,$14,$08 ; $04
	db $3A,$F4,$0A ; $05
	db $3C,$08,$0C ; $06
		
OBJLstHdrA_Mai_RollF3:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_RollF0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mai_RollF0.bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mai_RollF1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_RollF1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1F,$F4,$00 ; $00
	db $23,$FC,$02 ; $01
	db $1D,$04,$04 ; $02
	db $2F,$F4,$06 ; $03
	db $33,$FC,$08 ; $04
	db $32,$04,$0A ; $05
	db $3F,$F4,$0C ; $06
		
OBJLstHdrA_Mai_RollB1:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_RollF1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mai_RollF1.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mai_TimeOver2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_TimeOver2 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $23,$ED,$00 ; $00
	db $23,$F5,$02 ; $01
	db $2B,$FD,$04 ; $02
	db $33,$ED,$06 ; $03
	db $33,$F5,$08 ; $04
	db $3B,$FD,$0A ; $05
		
OBJLstHdrA_Mai_HitSwoopup1:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_TimeOver2 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mai_TimeOver2.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mai_HitSwoopup2:
	db OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_TimeOver2 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mai_TimeOver2.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mai_ThrowEndA3:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_TimeOver2 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mai_TimeOver2.bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $04 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mai_GuardBreakG0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_GuardBreakG0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $21,$FA,$00 ; $00
	db $20,$02,$02 ; $01
	db $21,$0A,$04 ; $02
	db $31,$FA,$06 ; $03
	db $30,$02,$08 ; $04
		
OBJLstHdrA_Mai_Hitlow0: ;X
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_Hitlow0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FB ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin: ;X
	db $06 ; OBJ Count
	;    Y   X  ID
	db $25,$FA,$00 ; $00
	db $27,$02,$02 ; $01
	db $2A,$0A,$04 ; $02
	db $3A,$FA,$06 ; $03
	db $37,$02,$08 ; $04
	db $3A,$0A,$0A ; $05
		
OBJLstHdrA_Mai_DropMain1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_DropMain1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FD ; iOBJLstHdrA_XOffset
	db $15 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $20,$F2,$00 ; $00
	db $1F,$FA,$02 ; $01
	db $1A,$FC,$04 ; $02
	db $1D,$04,$06 ; $03
	db $21,$0C,$08 ; $04
		
OBJLstHdrA_Mai_ThrowRotL0:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_DropMain1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mai_DropMain1.bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $FE ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mai_DropMain2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_DropMain2 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F7 ; iOBJLstHdrA_XOffset
	db $02 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $38,$F4,$00 ; $00
	db $38,$FC,$02 ; $01
	db $35,$04,$04 ; $02
	db $33,$0C,$06 ; $03
	db $35,$14,$08 ; $04
		
OBJLstHdrA_Mai_RunF0_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_RunF0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $02 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $29,$EC,$00 ; $00
	db $20,$F4,$02 ; $01
	db $18,$FC,$04 ; $02
		
OBJLstHdrA_Mai_RunF1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_RunF0_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mai_RunF0_A.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $01 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Mai_RunF0_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Mai_RunF0_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $02 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $30,$F4,$00 ; $00
	db $28,$FC,$02 ; $01
	db $30,$04,$04 ; $02
	db $30,$0C,$06 ; $03
	db $38,$FC,$08 ; $04
		
OBJLstHdrB_Mai_RunF1_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Mai_RunF1_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $31,$F4,$00 ; $00
	db $29,$FC,$02 ; $01
	db $32,$04,$04 ; $02
	db $32,$0C,$06 ; $03
	db $39,$FC,$08 ; $04
		
OBJLstHdrA_Mai_ThrowG0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_ThrowG0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $28,$F4,$00 ; $00
	db $24,$FC,$02 ; $01
	db $21,$04,$04 ; $02
	db $38,$F4,$06 ; $03
	db $34,$FC,$08 ; $04
	db $34,$04,$0A ; $05
		
OBJLstHdrA_Mai_CHoHissatsuShinobibachiD2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_CHoHissatsuShinobibachiD2 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mai_ThrowG1.bin ; iOBJLstHdrA_DataPtr
	db $F0 ; iOBJLstHdrA_XOffset
	db $09 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mai_HishoRyuEnJinL3_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_34 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_CHoHissatsuShinobibachiD2 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mai_ThrowG1.bin ; iOBJLstHdrA_DataPtr
	db $F0 ; iOBJLstHdrA_XOffset
	db $09 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mai_ThrowG1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_CHoHissatsuShinobibachiD2 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F0 ; iOBJLstHdrA_XOffset
	db $09 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1B,$FC,$00 ; $00
	db $1B,$04,$02 ; $01
	db $1C,$0C,$04 ; $02
	db $07,$14,$06 ; $03
	db $16,$1C,$08 ; $04
	db $17,$14,$0A ; $05
	db $2B,$05,$0C ; $06
		
OBJLstHdrA_Mai_ThrowG3:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_CHoHissatsuShinobibachiD2 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mai_ThrowG1.bin ; iOBJLstHdrA_DataPtr
	db $11 ; iOBJLstHdrA_XOffset
	db $F0 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mai_CHoHissatsuShinobibachiD1_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_CHoHissatsuShinobibachiD1_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mai_ThrowG2_A.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $10 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mai_ThrowG2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_CHoHissatsuShinobibachiD1_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $10 ; iOBJLstHdrA_YOffset
.bin:
	db $01 ; OBJ Count
	;    Y   X  ID
	db $00,$F4,$00 ; $00
		
OBJLstHdrB_Mai_HishoRyuEnJinL2_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Mai_HishoRyuEnJinL2_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $10 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $18,$ED,$00 ; $00
	db $10,$F4,$02 ; $01
	db $0A,$FC,$04 ; $02
	db $12,$04,$06 ; $03
	db $20,$F5,$08 ; $04
	db $1A,$FC,$0A ; $05
	db $22,$04,$0C ; $06
		
OBJLstHdrA_Mai_ThrowG4:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_ThrowG4 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $20,$EC,$00 ; $00
	db $20,$F4,$02 ; $01
	db $29,$FC,$04 ; $02
	db $30,$EC,$06 ; $03
	db $30,$F4,$08 ; $04
	db $39,$FC,$0A ; $05
		
OBJLstHdrA_Mai_KaCHoSenL0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_KaCHoSenL0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $23,$04,$00 ; $00
	db $24,$0C,$02 ; $01
	db $23,$14,$04 ; $02
	db $37,$F5,$06 ; $03
	db $31,$FD,$08 ; $04
	db $33,$05,$0A ; $05
		
OBJLstHdrA_Mai_KaCHoSenL2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_KaCHoSenL2 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $25,$F6,$00 ; $00
	db $20,$FE,$02 ; $01
	db $1E,$06,$04 ; $02
	db $1D,$0E,$06 ; $03
	db $35,$F6,$08 ; $04
	db $30,$FE,$0A ; $05
	db $32,$06,$0C ; $06
		
OBJLstHdrA_Mai_KaCHoSenL3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_KaCHoSenL3 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FD ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1B,$F4,$00 ; $00
	db $21,$FC,$02 ; $01
	db $21,$04,$04 ; $02
	db $3D,$F4,$06 ; $03
	db $31,$FC,$08 ; $04
	db $31,$04,$0A ; $05
		
OBJLstHdrA_Mai_KuuchuuMusasabiL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_KuuchuuMusasabiL1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FD ; iOBJLstHdrA_XOffset
	db $14 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $19,$F4,$00 ; $00
	db $15,$FC,$02 ; $01
	db $13,$04,$04 ; $02
	db $0D,$06,$06 ; $03
	db $06,$0E,$08 ; $04
	db $05,$FA,$0A ; $05
		
OBJLstHdrA_Mai_HissatsuShinobibachiL3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_HissatsuShinobibachiL3 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1E,$EE,$00 ; $00
	db $1B,$F6,$02 ; $01
	db $1E,$FE,$04 ; $02
	db $24,$06,$06 ; $03
	db $2B,$F6,$08 ; $04
	db $2E,$FE,$0A ; $05
	db $2A,$07,$0C ; $06
		
OBJLstHdrA_Mai_HishoRyuEnJinL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_HishoRyuEnJinL1 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $26,$F4,$00 ; $00
	db $23,$FC,$02 ; $01
	db $23,$04,$04 ; $02
	db $25,$0C,$06 ; $03
	db $32,$14,$08 ; $04
	db $33,$FC,$0A ; $05
	db $33,$04,$0C ; $06
	db $35,$0C,$0E ; $07
		
OBJLstHdrA_Mai_HishoRyuEnJinL2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_34 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_HishoRyuEnJinL2_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F0 ; iOBJLstHdrA_XOffset
	db $10 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $05,$EC,$00 ; $00
	db $FD,$F4,$02 ; $01
	db $08,$FC,$04 ; $02
	db $00,$04,$06 ; $03
	db $15,$EC,$08 ; $04
	db $0D,$F4,$0A ; $05
	db $1D,$F4,$0C ; $06
		
OBJLstHdrB_Mai_HishoRyuEnJinL3_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Mai_HishoRyuEnJinL3_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F0 ; iOBJLstHdrA_XOffset
	db $09 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $11,$F1,$00 ; $00
	db $0A,$F3,$02 ; $01
	db $03,$FB,$04 ; $02
	db $FD,$03,$06 ; $03
		
OBJLstHdrA_Mai_RyuEnBuL2_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_33 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_RyuEnBuL2_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F0 ; iOBJLstHdrA_XOffset
	db $04 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $2B,$EC,$00 ; $00
	db $25,$F4,$02 ; $01
	db $2C,$FC,$04 ; $02
	db $35,$F4,$06 ; $03
		
OBJLstHdrA_Mai_RyuEnBuL3_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_33 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_RyuEnBuL3_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $1D,$EC,$00 ; $00
	db $21,$F4,$02 ; $01
	db $1C,$FC,$04 ; $02
	db $18,$04,$06 ; $03
	db $2D,$EC,$08 ; $04
	db $31,$F4,$0A ; $05
	db $2C,$FC,$0C ; $06
	db $3C,$FC,$0E ; $07
		
OBJLstHdrB_Mai_RyuEnBuL3_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Mai_RyuEnBuL3_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $28,$04,$00 ; $00
	db $28,$0C,$02 ; $01
	db $38,$04,$04 ; $02
	db $38,$0C,$06 ; $03
		
OBJLstHdrA_Mai_RyuEnBuL4_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_RyuEnBuL4_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $2A,$EC,$00 ; $00
	db $2C,$F4,$02 ; $01
	db $21,$FD,$04 ; $02
	db $18,$05,$06 ; $03
	db $32,$FC,$08 ; $04
		
OBJLstHdrA_Mai_CHoHissatsuShinobibachiS3_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_35 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_CHoHissatsuShinobibachiS3_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $10 ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $16,$F4,$00 ; $00
	db $08,$FB,$02 ; $01
	db $08,$03,$04 ; $02
	db $08,$0B,$06 ; $03
	db $08,$13,$08 ; $04
	db $18,$FC,$0A ; $05
	db $18,$04,$0C ; $06
	db $18,$0C,$0E ; $07
	db $18,$14,$10 ; $08
		
OBJLstHdrB_Mai_CHoHissatsuShinobibachiS3_B:
	db $00 ; iOBJLstHdrA_Flags
	dpr GFX_Char_Mai_CHoHissatsuShinobibachiS3_B ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $10 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $28,$00,$00 ; $00
	db $28,$08,$02 ; $01
	db $2A,$10,$04 ; $02
		
OBJLstHdrA_Mai_CHoHissatsuShinobibachiS4_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_35 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_CHoHissatsuShinobibachiS4_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $10 ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $16,$EB,$00 ; $00
	db $08,$F3,$02 ; $01
	db $08,$FB,$04 ; $02
	db $08,$03,$06 ; $03
	db $08,$0B,$08 ; $04
	db $18,$F3,$0A ; $05
	db $18,$FB,$0C ; $06
	db $18,$03,$0E ; $07
	db $18,$0B,$10 ; $08
		
OBJLstHdrA_Mai_CHoHissatsuShinobibachiD7_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_36 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_CHoHissatsuShinobibachiD7_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F7 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
.bin:
	db $0D ; OBJ Count
	;    Y   X  ID
	db $11,$EC,$00 ; $00
	db $21,$EC,$02 ; $01
	db $14,$F4,$04 ; $02
	db $24,$F4,$06 ; $03
	db $10,$FC,$08 ; $04
	db $10,$04,$0A ; $05
	db $10,$0C,$0C ; $06
	db $20,$FC,$0E ; $07
	db $20,$04,$10 ; $08
	db $20,$0C,$12 ; $09
	db $20,$14,$14 ; $0A
	db $01,$EC,$16 ; $0B
	db $04,$F4,$18 ; $0C
		
OBJLstHdrA_Mai_CHoHissatsuShinobibachiD8_A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_36 ; iOBJLstHdrA_HitboxId
	dpr GFX_Char_Mai_CHoHissatsuShinobibachiD8_A ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F7 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
.bin:
	db $0C ; OBJ Count
	;    Y   X  ID
	db $1C,$EC,$00 ; $00
	db $10,$F4,$02 ; $01
	db $20,$F4,$04 ; $02
	db $10,$FC,$06 ; $03
	db $20,$FC,$08 ; $04
	db $10,$04,$0A ; $05
	db $20,$04,$0C ; $06
	db $10,$0C,$0E ; $07
	db $20,$0C,$10 ; $08
	db $20,$14,$12 ; $09
	db $0C,$EC,$14 ; $0A
	db $FA,$EC,$16 ; $0B