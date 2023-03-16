
OBJLstPtrTable_Daimon_Idle:
	dw OBJLstHdrA_Daimon_Idle0A, OBJLstHdrB_Daimon_Idle0B
	dw OBJLstHdrA_Daimon_Idle1A, OBJLstHdrB_Daimon_Idle0B
	dw OBJLstHdrA_Daimon_Idle2A, OBJLstHdrB_Daimon_Idle0B
	dw OBJLstHdrA_Daimon_Idle3A, OBJLstHdrB_Daimon_Idle0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_WalkF:
	dw OBJLstHdrA_Daimon_WalkF0A, OBJLstHdrB_Daimon_WalkF0B
	dw OBJLstHdrA_Daimon_WalkF1A, OBJLstHdrB_Daimon_WalkF1B
	dw OBJLstHdrA_Daimon_WalkF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_WalkF1A, OBJLstHdrB_Daimon_WalkF1B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_WalkB:
	dw OBJLstHdrA_Daimon_WalkF1A, OBJLstHdrB_Daimon_WalkF1B
	dw OBJLstHdrA_Daimon_WalkF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_WalkF1A, OBJLstHdrB_Daimon_WalkF1B
	dw OBJLstHdrA_Daimon_WalkF0A, OBJLstHdrB_Daimon_WalkF0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_Crouch:
	dw OBJLstHdrA_Daimon_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_JumpN:
	dw OBJLstHdrA_Daimon_Crouch0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_JumpN1A, OBJLstHdrB_Daimon_JumpN1B
	dw OBJLstHdrA_Daimon_JumpN1A, OBJLstHdrB_Daimon_JumpN1B
	dw OBJLstHdrA_Daimon_JumpN3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_JumpN3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_JumpN1A, OBJLstHdrB_Daimon_JumpN1B
	dw OBJLstHdrA_Daimon_JumpN1A, OBJLstHdrB_Daimon_JumpN1B
	dw OBJLstHdrA_Daimon_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_BlockG:
	dw OBJLstHdrA_Daimon_BlockG0A, OBJLstHdrB_Daimon_BlockG0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_BlockC:
	dw OBJLstHdrA_Daimon_BlockC0A, OBJLstHdrB_Daimon_BlockC0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_BlockA:
	dw OBJLstHdrA_Daimon_BlockG0A, OBJLstHdrB_Daimon_BlockA0B ;X
	dw OBJLstHdrA_Daimon_Crouch0, OBJLSTPTR_NONE ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_RunF:
	dw OBJLstHdrA_Daimon_RunF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_RunF1A, OBJLstHdrB_Daimon_WalkF1B
	dw OBJLstHdrA_Daimon_RunF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_RunF3A, OBJLstHdrB_Daimon_WalkF1B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_HopB:
	dw OBJLstHdrA_Daimon_HopB0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_HopB1A, OBJLstHdrB_Daimon_HopB1B
	dw OBJLstHdrA_Daimon_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_ChargeMeter:
	dw OBJLstHdrA_Daimon_ChargeMeter0A, OBJLstHdrB_Daimon_ChargeMeter0B
	dw OBJLstHdrA_Daimon_ChargeMeter1A, OBJLstHdrB_Daimon_ChargeMeter0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_Taunt:
	dw OBJLstHdrA_Daimon_Taunt0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_Taunt0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_HopB1A, OBJLstHdrB_Daimon_HopB1B
	dw OBJLstHdrA_Daimon_Taunt3A, OBJLstHdrB_Daimon_HopB1B
	dw OBJLstHdrA_Daimon_Taunt3A, OBJLstHdrB_Daimon_HopB1B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_WinA:
	dw OBJLstHdrA_Daimon_Taunt0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_Taunt0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_WinA2A, OBJLstHdrB_Daimon_HopB1B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_WinB:
	dw OBJLstHdrA_Daimon_WinB0A, OBJLstHdrB_Daimon_WinB0B
	dw OBJLstHdrA_Daimon_WinB1A, OBJLstHdrB_Daimon_WinB0B
	dw OBJLstHdrA_Daimon_WinB2A, OBJLstHdrB_Daimon_WinB0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_PunchL:
	dw OBJLstHdrA_Daimon_WalkF1A, OBJLstHdrB_Daimon_WalkF0B
	dw OBJLstHdrA_Daimon_PunchL1A, OBJLstHdrB_Daimon_WalkF0B
	dw OBJLstHdrA_Daimon_WalkF1A, OBJLstHdrB_Daimon_WalkF0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_PunchH:
	dw OBJLstHdrA_Daimon_PunchH0A, OBJLstHdrB_Daimon_PunchH0B
	dw OBJLstHdrA_Daimon_PunchH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_PunchH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_PunchH0A, OBJLstHdrB_Daimon_PunchH0B
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
	dw OBJLstHdrA_Daimon_PunchCL0A, OBJLstHdrB_Daimon_PunchCL0B
	dw OBJLstHdrA_Daimon_PunchCL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_PunchCL0A, OBJLstHdrB_Daimon_PunchCL0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_PunchCH:
	dw OBJLstHdrA_Daimon_PunchCL0A, OBJLstHdrB_Daimon_PunchCH0B
	dw OBJLstHdrA_Daimon_PunchCH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_PunchCH2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_PunchCL0A, OBJLstHdrB_Daimon_PunchCH0B ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_KickCL:
	dw OBJLstHdrA_Daimon_KickCL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_KickCL1A, OBJLstHdrB_Daimon_KickCL1B
	dw OBJLstHdrA_Daimon_KickCL0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_KickCH:
	dw OBJLstHdrA_Daimon_KickCL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_KickCH1A, OBJLstHdrB_Daimon_KickCL1B
	dw OBJLstHdrA_Daimon_KickCH1A, OBJLstHdrB_Daimon_KickCL1B
	dw OBJLstHdrA_Daimon_KickCH3, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_PunchA:
	dw OBJLstHdrA_Daimon_JumpN1A, OBJLstHdrB_Daimon_PunchA0B
	dw OBJLstHdrA_Daimon_PunchA1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_JumpN3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_JumpN1A, OBJLstHdrB_Daimon_JumpN1B ;X
	dw OBJLstHdrA_Daimon_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_KickA:
	dw OBJLstHdrA_Daimon_KickA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_KickA1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_JumpN3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_JumpN1A, OBJLstHdrB_Daimon_JumpN1B ;X
	dw OBJLstHdrA_Daimon_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_AttackA:
	dw OBJLstHdrA_Daimon_AttackA0A, OBJLstHdrB_Daimon_JumpN1B
	dw OBJLstHdrA_Daimon_AttackA1A, OBJLstHdrB_Daimon_AttackA1B
	dw OBJLstHdrA_Daimon_JumpN3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_JumpN1A, OBJLstHdrB_Daimon_JumpN1B ;X
	dw OBJLstHdrA_Daimon_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_AttackG:
	dw OBJLstHdrA_Daimon_PunchH0A, OBJLstHdrB_Daimon_PunchH0B
	dw OBJLstHdrA_Daimon_AttackG1A, OBJLstHdrB_Daimon_AttackG1B
	dw OBJLstHdrA_Daimon_AttackG1A, OBJLstHdrB_Daimon_AttackG1B
	dw OBJLstHdrA_Daimon_PunchL1A, OBJLstHdrB_Daimon_WalkF0B ;X
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
	dw OBJLstHdrA_Daimon_GuardBreakG0A, OBJLstHdrB_Daimon_GuardBreakG0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_Dizzy:
	dw OBJLstHdrA_Daimon_Idle0A, OBJLstHdrB_Daimon_Idle0B
	dw OBJLstHdrA_Daimon_GuardBreakG0A, OBJLstHdrB_Daimon_GuardBreakG0B
OBJLstPtrTable_Daimon_TimeOver:
	dw OBJLstHdrA_Daimon_HopB0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_Hitlow:
	dw OBJLstHdrA_Daimon_Hitlow0A, OBJLstHdrB_Daimon_Hitlow0B
	dw OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE;X

OBJLstPtrTable_Daimon_GuardBreakA:
	dw OBJLstHdrA_Daimon_GuardBreakG0A, OBJLstHdrB_Daimon_GuardBreakG0B ;X
	dw OBJLstHdrA_Daimon_Crouch0, OBJLSTPTR_NONE ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_BackjumpRecA:
	dw OBJLstHdrA_Daimon_GuardBreakG0A, OBJLstHdrB_Daimon_GuardBreakG0B
	dw OBJLstHdrA_Daimon_JumpN1A, OBJLstHdrB_Daimon_JumpN1B
	dw OBJLstHdrA_Daimon_JumpN1A, OBJLstHdrB_Daimon_JumpN1B
	dw OBJLstHdrA_Daimon_JumpN1A, OBJLstHdrB_Daimon_JumpN1B
	dw OBJLstHdrA_Daimon_JumpN1A, OBJLstHdrB_Daimon_JumpN1B
	dw OBJLstHdrA_Daimon_JumpN3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_DropMain:
	dw OBJLstHdrA_Daimon_GuardBreakG0A, OBJLstHdrB_Daimon_GuardBreakG0B
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
	dw OBJLstHdrA_Daimon_GuardBreakG0A, OBJLstHdrB_Daimon_GuardBreakG0B
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
	dw OBJLstHdrA_Daimon_JiraiShin1A, OBJLstHdrB_Daimon_HopB1B
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
	dw OBJLstHdrA_Daimon_WalkF1A, OBJLstHdrB_Daimon_WalkF1B
	dw OBJLstHdrA_Daimon_PunchL1A, OBJLstHdrB_Daimon_WalkF0B
	dw OBJLstHdrA_Daimon_PunchCH2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CHouOosotoGariL3A, OBJLstHdrB_Daimon_WalkF0B
	dw OBJLstHdrA_Daimon_CHouOosotoGariL4A, OBJLstHdrB_Daimon_CHouOosotoGariL4B
	dw OBJLstHdrA_Daimon_CHouOosotoGariL4A, OBJLstHdrB_Daimon_CHouOosotoGariL5B
	dw OBJLstHdrA_Daimon_CHouOosotoGariL6, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CHouOosotoGariL7, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_Taunt0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_CLoudTosser:
	dw OBJLstHdrA_Daimon_Crouch0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CLoudTosser1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CLoudTosser2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_Taunt0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CLoudTosser4A, OBJLstHdrB_Daimon_CLoudTosser4B
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
	dw OBJLstHdrA_Daimon_CLoudTosser4A, OBJLstHdrB_Daimon_CLoudTosser4B
	dw OBJLstHdrA_Daimon_CLoudTosser5, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CLoudTosser6, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CLoudTosser7, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CLoudTosser8, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_HeavenDropL:
	dw OBJLstHdrA_Daimon_HeavenDropL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_HeavenDropL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CLoudTosser4A, OBJLstHdrB_Daimon_CLoudTosser4B
	dw OBJLstHdrA_Daimon_HeavenDropL3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_HeavenDropL4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_HeavenDropL5A, OBJLstHdrB_Daimon_PunchH0B
	dw OBJLstHdrA_Daimon_HeavenDropL6, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_HeavenDropL7, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CLoudTosser2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_Taunt0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_HeavenHellDropS:
	dw OBJLstHdrA_Daimon_HeavenDropL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CHouOosotoGariL4A, OBJLstHdrB_Daimon_CHouOosotoGariL4B
	dw OBJLstHdrA_Daimon_CHouOosotoGariL4A, OBJLstHdrB_Daimon_CHouOosotoGariL5B
	dw OBJLstHdrA_Daimon_CHouOosotoGariL6, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_HeavenHellDropS4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_HeavenHellDropS5, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CLoudTosser4A, OBJLstHdrB_Daimon_CLoudTosser4B
	dw OBJLstHdrA_Daimon_CLoudTosser5, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CLoudTosser6, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_HeavenDropL4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_HeavenDropL5A, OBJLstHdrB_Daimon_PunchH0B
	dw OBJLstHdrA_Daimon_HeavenDropL6, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_HeavenDropL7, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_HeavenHellDropS5, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CLoudTosser4A, OBJLstHdrB_Daimon_CLoudTosser4B
	dw OBJLstHdrA_Daimon_CLoudTosser5, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CLoudTosser6, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CLoudTosser7, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_CLoudTosser8, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Daimon_ThrowG:
	dw OBJLstHdrA_Daimon_PunchL1A, OBJLstHdrB_Daimon_WalkF0B
	dw OBJLstHdrA_Daimon_HeavenDropL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_ThrowG2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Daimon_ThrowG3A, OBJLstHdrB_Daimon_ThrowG3B
	dw OBJLSTPTR_NONE
		
OBJLstHdrA_Daimon_Idle0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C4000 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrB_Daimon_Idle0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0C40C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$F3,$00 ; $00
	db $30,$FB,$02 ; $01
	db $30,$03,$04 ; $02
		
OBJLstHdrA_Daimon_Idle1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C4120 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrA_Daimon_Idle2A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C41E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrA_Daimon_Idle3A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C42A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrA_Daimon_WalkF0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C4360 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrB_Daimon_WalkF0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0C4420 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$F1,$00 ; $00
	db $30,$F9,$02 ; $01
	db $33,$01,$04 ; $02
		
OBJLstHdrA_Daimon_WalkF1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C4480 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_ThrowG3A.bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_ThrowG3A:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C4480 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrB_Daimon_WalkF1B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0C4500 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_Daimon_ThrowG3B.bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Daimon_ThrowG3B:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	dpr L0C4500 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C4540 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C4640 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_Unused_CrouchXFlip0.bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
;--
; [TCRF] Unreferenced X Flipped version of OBJLstHdrA_Daimon_Crouch0
OBJLstHdrA_Daimon_Unused_CrouchXFlip0: ;X
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C4640 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrA_Daimon_BlockG0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C48C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrA_Daimon_BlockC0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C48C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrB_Daimon_BlockG0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0C4940 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrB_Daimon_BlockC0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0C49E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $0B ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$EA,$00 ; $00
	db $30,$F2,$02 ; $01
	db $30,$FA,$04 ; $02
		
OBJLstHdrB_Daimon_BlockA0B: ;X
	db $00 ; iOBJLstHdrA_Flags
	dpr L0C4A40 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrA_Daimon_JumpN1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C4700 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrB_Daimon_JumpN1B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0C4780 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C4800 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrA_Daimon_ChargeMeter0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C6200 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrB_Daimon_ChargeMeter0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0C62C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrA_Daimon_ChargeMeter1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C6340 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C6B00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrA_Daimon_RunF1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C6C20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C6CC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrA_Daimon_RunF3A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C6DC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C6580 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_CLoudTosser8.bin ; iOBJLstHdrA_DataPtr
	db $09 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_CLoudTosser8:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C6580 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrA_Daimon_HopB1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C6640 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrB_Daimon_HopB1B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0C6700 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrA_Daimon_Taunt3A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C67A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrA_Daimon_WinA2A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C6860 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrA_Daimon_WinB0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C6920 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $05 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $18,$EB,$00 ; $00
	db $18,$F3,$02 ; $01
		
OBJLstHdrB_Daimon_WinB0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0C6960 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrA_Daimon_WinB1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C6A40 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $05 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $1A,$EB,$00 ; $00
	db $10,$F3,$02 ; $01
	db $20,$F3,$04 ; $02
		
OBJLstHdrA_Daimon_WinB2A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C6AA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $05 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $1B,$EB,$00 ; $00
	db $10,$F3,$02 ; $01
	db $20,$F3,$04 ; $02
		
OBJLstHdrA_Daimon_PunchL1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L0C4F60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_CHouOosotoGariL3A.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_CHouOosotoGariL3A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C4F60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrA_Daimon_PunchH0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C5020 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_HeavenDropL5A.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_CLoudTosser4A:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L0C5020 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_HeavenDropL5A.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_AttackA0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C5020 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_HeavenDropL5A.bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $05 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_HeavenDropL5A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L0C5020 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $18,$FC,$00 ; $00
	db $18,$04,$02 ; $01
	db $0C,$0B,$04 ; $02
		
OBJLstHdrB_Daimon_PunchH0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0C5080 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_Daimon_CLoudTosser4B.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Daimon_CLoudTosser4B:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	dpr L0C5080 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C5100 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C5200 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C5300 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C53E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C5500 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C5600 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrA_Daimon_PunchCL0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C56E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrB_Daimon_PunchCL0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0C57A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C57E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C58C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrB_Daimon_PunchCH0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0C59C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $28,$F3,$00 ; $00
	db $28,$EB,$02 ; $01
		
OBJLstHdrA_Daimon_KickCL1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_4C ; iOBJLstHdrA_HitboxId
	dpr L0C5A00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrB_Daimon_KickCL1B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0C5AA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C5B00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_KickA0.bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_KickA0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C5B00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrA_Daimon_KickCH1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_4C ; iOBJLstHdrA_HitboxId
	dpr L0C5BC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C5C80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_HeavenHellDropS5.bin ; iOBJLstHdrA_DataPtr
	db $FD ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_HeavenDropL4:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L0C5C80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_HeavenHellDropS5.bin ; iOBJLstHdrA_DataPtr
	db $FF ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_HeavenHellDropS5:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L0C5C80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrB_Daimon_PunchA0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0C5D60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C5DC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C5EA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrA_Daimon_AttackG1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_51 ; iOBJLstHdrA_HitboxId
	dpr L0C6400 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_AttackA1A.bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_AttackA1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L0C6400 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrB_Daimon_AttackG1B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0C64E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $28,$EB,$00 ; $00
	db $30,$F3,$02 ; $01
	db $38,$EB,$04 ; $02
		
OBJLstHdrB_Daimon_AttackA1B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0C6540 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C5F80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C6040 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C6100 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C4C20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C4C20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_HopB0.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_HitSwoopup2:
	db OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C4C20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_HopB0.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_HitSwoopup1:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C4C20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_HopB0.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_GuardBreakG0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C4AE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrA_Daimon_Hitlow0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C4AE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_GuardBreakG0A.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Daimon_GuardBreakG0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0C4B80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrB_Daimon_Hitlow0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0C4D20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C4D80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C4D80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_DropMain1.bin ; iOBJLstHdrA_DataPtr
	db $05 ; iOBJLstHdrA_XOffset
	db $F2 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_DropMain2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C4EA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrA_Daimon_JiraiShin1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C6E60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C6F00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C6FE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C7120 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C7200 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrA_Daimon_CHouOosotoGariL4A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L0C7300 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrB_Daimon_CHouOosotoGariL4B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0C7380 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrB_Daimon_CHouOosotoGariL5B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0C7400 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C7460 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C7540 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_HeavenHellDropS4.bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_HeavenHellDropS4:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L0C7540 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C7620 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C7740 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_HeavenDropL6.bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_HeavenDropL6:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L0C7740 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C7860 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_HeavenDropL7.bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_HeavenDropL7:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L0C7860 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C7940 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Daimon_CLoudTosser7.bin ; iOBJLstHdrA_DataPtr
	db $07 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Daimon_CLoudTosser7:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0C7940 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C7A20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C7B20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C7C20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C7D20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	dpr L0C7E40 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		

OBJLstPtrTable_Terry_Idle:
	dw OBJLstHdrA_Terry_Idle0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_Idle1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_Idle2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_Idle1, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_WalkF:
	dw OBJLstHdrA_Terry_WalkF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_WalkF1A, OBJLstHdrB_Terry_WalkF1B
	dw OBJLstHdrA_Terry_Idle1, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_WalkB:
	dw OBJLstHdrA_Terry_Idle1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_WalkF1A, OBJLstHdrB_Terry_WalkF1B
	dw OBJLstHdrA_Terry_WalkF0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_Crouch:
	dw OBJLstHdrA_Terry_Crouch0A, OBJLstHdrB_Terry_Crouch0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_JumpN:
	dw OBJLstHdrA_Terry_Crouch0A, OBJLstHdrB_Terry_Crouch0B
	dw OBJLstHdrA_Terry_WalkF1A, OBJLstHdrB_Terry_WalkF1B
	dw OBJLstHdrA_Terry_WalkF1A, OBJLstHdrB_Terry_WalkF1B
	dw OBJLstHdrA_Terry_WalkF1A, OBJLstHdrB_Terry_JumpN3B
	dw OBJLstHdrA_Terry_WalkF1A, OBJLstHdrB_Terry_JumpN3B
	dw OBJLstHdrA_Terry_WalkF1A, OBJLstHdrB_Terry_WalkF1B
	dw OBJLstHdrA_Terry_WalkF1A, OBJLstHdrB_Terry_WalkF1B
	dw OBJLstHdrA_Terry_Crouch0A, OBJLstHdrB_Terry_Crouch0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_BlockG:
	dw OBJLstHdrA_Terry_BlockG0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_BlockC:
	dw OBJLstHdrA_Terry_BlockC0A, OBJLstHdrB_Terry_Crouch0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_BlockA:
	dw OBJLstHdrA_Terry_BlockA0A, OBJLstHdrB_Terry_BlockA0B ;X
	dw OBJLstHdrA_Terry_Crouch0A, OBJLstHdrB_Terry_Crouch0B ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_RunF:
	dw OBJLstHdrA_Terry_RunF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_RunF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_RunF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_RunF1, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_HopB:
	dw OBJLstHdrA_Terry_WalkF1A, OBJLstHdrB_Terry_WalkF1B
	dw OBJLstHdrA_Terry_WalkF1A, OBJLstHdrB_Terry_WalkF1B
	dw OBJLstHdrA_Terry_Crouch0A, OBJLstHdrB_Terry_Crouch0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_ChargeMeter:
	dw OBJLstHdrA_Terry_ChargeMeter0A, OBJLstHdrB_Terry_ChargeMeter0B
	dw OBJLstHdrA_Terry_ChargeMeter1A, OBJLstHdrB_Terry_ChargeMeter0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_Taunt:
	dw OBJLstHdrA_Terry_Taunt0A, OBJLstHdrB_Terry_Taunt0B
	dw OBJLstHdrA_Terry_Taunt1A, OBJLstHdrB_Terry_Taunt0B
	dw OBJLstHdrA_Terry_Taunt0A, OBJLstHdrB_Terry_Taunt0B
	dw OBJLstHdrA_Terry_Taunt1A, OBJLstHdrB_Terry_Taunt0B
	dw OBJLstHdrA_Terry_Taunt4A, OBJLstHdrB_Terry_Taunt4B
	dw OBJLstHdrA_Terry_Taunt5A, OBJLstHdrB_Terry_Taunt4B
	dw OBJLstHdrA_Terry_Taunt4A, OBJLstHdrB_Terry_Taunt4B
	dw OBJLstHdrA_Terry_Taunt5A, OBJLstHdrB_Terry_Taunt4B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_WinA:
	dw OBJLstHdrA_Terry_WinA0A, OBJLstHdrB_Terry_WinA0B
	dw OBJLstHdrA_Terry_WinA1A, OBJLstHdrB_Terry_WinA0B
	dw OBJLstHdrA_Terry_WinA2A, OBJLstHdrB_Terry_WinA2B
	dw OBJLstHdrA_Terry_WinA2A, OBJLstHdrB_Terry_WinA3B
	dw OBJLstHdrA_Terry_WinA2A, OBJLstHdrB_Terry_WinA2B
	dw OBJLstHdrA_Terry_WinA2A, OBJLstHdrB_Terry_WinA3B
	dw OBJLstHdrA_Terry_WinA1A, OBJLstHdrB_Terry_WinA0B
	dw OBJLstHdrA_Terry_WinA7, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_WinB:
	dw OBJLstHdrA_Terry_WinB0A, OBJLstHdrB_Terry_WinB0B
	dw OBJLstHdrA_Terry_WinB1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_WinB2A, OBJLstHdrB_Terry_WinB2B
	dw OBJLstHdrA_Terry_WinB3A, OBJLstHdrB_Terry_WinB2B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_PunchL:
	dw OBJLstHdrA_Terry_PunchL0A, OBJLstHdrB_Terry_PunchL0B
	dw OBJLstHdrA_Terry_PunchL1A, OBJLstHdrB_Terry_PunchL0B
	dw OBJLstHdrA_Terry_PunchL0A, OBJLstHdrB_Terry_PunchL0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_PunchH:
	dw OBJLstHdrA_Terry_PunchH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_PunchH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_PunchH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_PunchH0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_KickL:
	dw OBJLstHdrA_Terry_PunchL0A, OBJLstHdrB_Terry_PunchL0B
	dw OBJLstHdrA_Terry_KickL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_PunchL0A, OBJLstHdrB_Terry_PunchL0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_KickH:
	dw OBJLstHdrA_Terry_KickH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_KickH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_KickH0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_PunchCL:
	dw OBJLstHdrA_Terry_PunchCL0A, OBJLstHdrB_Terry_Crouch0B
	dw OBJLstHdrA_Terry_PunchCL1A, OBJLstHdrB_Terry_Crouch0B
	dw OBJLstHdrA_Terry_PunchCL0A, OBJLstHdrB_Terry_Crouch0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_PunchCH:
	dw OBJLstHdrA_Terry_PunchCL0A, OBJLstHdrB_Terry_Crouch0B
	dw OBJLstHdrA_Terry_PunchCH1A, OBJLstHdrB_Terry_Crouch0B
	dw OBJLstHdrA_Terry_PunchCL0A, OBJLstHdrB_Terry_Crouch0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_KickCL:
	dw OBJLstHdrA_Terry_Crouch0A, OBJLstHdrB_Terry_Crouch0B
	dw OBJLstHdrA_Terry_KickCL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_Crouch0A, OBJLstHdrB_Terry_Crouch0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_KickCH:
	dw OBJLstHdrA_Terry_KickCH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_KickCH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_KickCH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_KickCH0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_PunchA:
	dw OBJLstHdrA_Terry_PunchA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_PunchA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_WalkF1A, OBJLstHdrB_Terry_JumpN3B
	dw OBJLstHdrA_Terry_WalkF1A, OBJLstHdrB_Terry_WalkF1B
	dw OBJLstHdrA_Terry_Crouch0A, OBJLstHdrB_Terry_Crouch0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_KickA:
	dw OBJLstHdrA_Terry_KickA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_KickA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_WalkF1A, OBJLstHdrB_Terry_JumpN3B
	dw OBJLstHdrA_Terry_WalkF1A, OBJLstHdrB_Terry_WalkF1B
	dw OBJLstHdrA_Terry_Crouch0A, OBJLstHdrB_Terry_Crouch0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_AttackA:
	dw OBJLstHdrA_Terry_AttackA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_AttackA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_WalkF1A, OBJLstHdrB_Terry_JumpN3B
	dw OBJLstHdrA_Terry_WalkF1A, OBJLstHdrB_Terry_WalkF1B ;X
	dw OBJLstHdrA_Terry_Crouch0A, OBJLstHdrB_Terry_Crouch0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_AttackG:
	dw OBJLstHdrA_Terry_WinB0A, OBJLstHdrB_Terry_WinB0B
	dw OBJLstHdrA_Terry_AttackG1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_AttackG2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_AttackG1, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_RollF:
	dw OBJLstHdrA_Terry_RollF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_RollF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_RollF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_KickCH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_Crouch0A, OBJLstHdrB_Terry_Crouch0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_RollB:
	dw OBJLstHdrA_Terry_KickCH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_RollF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_RollF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_RollF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_Crouch0A, OBJLstHdrB_Terry_Crouch0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_GuardBreakG:
	dw OBJLstHdrA_Terry_GuardBreakG0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_Dizzy:
	dw OBJLstHdrA_Terry_Idle0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_GuardBreakG0, OBJLSTPTR_NONE
OBJLstPtrTable_Terry_TimeOver:
	dw OBJLstHdrA_Terry_TimeOver2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_Hitlow:
	dw OBJLstHdrA_Terry_Hitlow0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_GuardBreakA:
	dw OBJLstHdrA_Terry_GuardBreakG0, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Terry_Crouch0A, OBJLstHdrB_Terry_Crouch0B ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_BackjumpRecA:
	dw OBJLstHdrA_Terry_GuardBreakG0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_WalkF1A, OBJLstHdrB_Terry_JumpN3B
	dw OBJLstHdrA_Terry_WalkF1A, OBJLstHdrB_Terry_JumpN3B
	dw OBJLstHdrA_Terry_WalkF1A, OBJLstHdrB_Terry_JumpN3B
	dw OBJLstHdrA_Terry_WalkF1A, OBJLstHdrB_Terry_JumpN3B
	dw OBJLstHdrA_Terry_WalkF1A, OBJLstHdrB_Terry_WalkF1B
	dw OBJLstHdrA_Terry_Crouch0A, OBJLstHdrB_Terry_Crouch0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_DropMain:
	dw OBJLstHdrA_Terry_GuardBreakG0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_DropMain2, OBJLSTPTR_NONE
OBJLstPtrTable_Terry_HitMultigs:
	dw OBJLstHdrA_Terry_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_DropMain2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_HitSwoopup:
	dw OBJLstHdrA_Terry_TimeOver2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_HitSwoopup1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_HitSwoopup2, OBJLSTPTR_NONE
OBJLstPtrTable_Terry_ThrowEndA:
	dw OBJLstHdrA_Terry_ThrowEndA3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_ThrowEndA3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_DropMain2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_DropDbg:
	dw OBJLstHdrA_Terry_GuardBreakG0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_DropMain2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_ThrowRotL:
	dw OBJLstHdrA_Terry_ThrowRotL0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_Wakeup:
	dw OBJLstHdrA_Terry_Crouch0A, OBJLstHdrB_Terry_Crouch0B
	dw OBJLstHdrA_Terry_Crouch0A, OBJLstHdrB_Terry_Crouch0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_PowerWaveL:
	dw OBJLstHdrA_Terry_PowerWaveL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_PowerWaveL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_PowerWaveL2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_PowerWaveL2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_BurnKnuckleL:
	dw OBJLstHdrA_Terry_BlockG0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_BurnKnuckleL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_Crouch0A, OBJLstHdrB_Terry_Crouch0B
	dw OBJLstHdrA_Terry_BurnKnuckleL3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_BurnKnuckleL4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_BurnKnuckleL3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_Crouch0A, OBJLstHdrB_Terry_Crouch0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_CrackShotL:
	dw OBJLstHdrA_Terry_PowerWaveL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_CrackShotL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_CrackShotL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_CrackShotL3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_Crouch0A, OBJLstHdrB_Terry_Crouch0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_RisingTackleL:
	dw OBJLstHdrA_Terry_RollF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_RisingTackleL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_RisingTackleL2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_RisingTackleL3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_RisingTackleL4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_RisingTackleL5, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_WalkF1A, OBJLstHdrB_Terry_WalkF1B
	dw OBJLstHdrA_Terry_Crouch0A, OBJLstHdrB_Terry_Crouch0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_PowerDunkL:
	dw OBJLstHdrA_Terry_Crouch0A, OBJLstHdrB_Terry_Crouch0B
	dw OBJLstHdrA_Terry_PowerDunkL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_PowerDunkL2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_PowerDunkL3A, OBJLstHdrB_Terry_PowerDunkL3B
	dw OBJLstHdrA_Terry_PowerDunkL4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_PowerDunkL5A, OBJLstHdrB_Terry_PowerDunkL3B
	dw OBJLstHdrA_Terry_Crouch0A, OBJLstHdrB_Terry_Crouch0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_PowerGeyserD:
	dw OBJLstHdrA_Terry_PowerWaveL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_PowerWaveL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_PowerWaveL2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_PowerGeyserD3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_PowerGeyserD4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_PowerGeyserD5, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_PowerWaveL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_PowerWaveL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_PowerWaveL2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_PowerWaveL2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_PowerGeyserE:
	dw OBJLstHdrA_Terry_PowerWaveL0, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Terry_PowerWaveL1, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Terry_PowerGeyserE2, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Terry_PowerGeyserE2, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Terry_PowerGeyserE2, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Terry_PowerGeyserE2, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Terry_PowerGeyserE2, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Terry_PowerGeyserE2, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Terry_PowerGeyserE2, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Terry_PowerGeyserE2, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Terry_PowerGeyserE2, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Terry_PowerGeyserE2, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Terry_PowerGeyserE2, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Terry_PowerGeyserE2, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Terry_PowerGeyserE2, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Terry_PowerGeyserE2, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Terry_PowerGeyserE2, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Terry_PowerGeyserE2, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Terry_PowerGeyserE2, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Terry_PowerGeyserE2, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Terry_PowerGeyserE2, OBJLSTPTR_NONE ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Terry_ThrowG:
	dw OBJLstHdrA_Terry_ThrowG0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_ThrowG1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Terry_ThrowG0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		
OBJLstHdrA_Terry_Idle0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D4000 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $22,$F2,$00 ; $00
	db $21,$FA,$02 ; $01
	db $23,$02,$04 ; $02
	db $34,$F2,$06 ; $03
	db $31,$FA,$08 ; $04
	db $33,$02,$0A ; $05
		
OBJLstHdrA_Terry_Idle1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D40C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $20,$F2,$00 ; $00
	db $20,$FA,$02 ; $01
	db $21,$02,$04 ; $02
	db $34,$F2,$06 ; $03
	db $30,$FA,$08 ; $04
	db $31,$02,$0A ; $05
		
OBJLstHdrA_Terry_Idle2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D4180 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $21,$F2,$00 ; $00
	db $21,$FA,$02 ; $01
	db $21,$02,$04 ; $02
	db $36,$F2,$06 ; $03
	db $31,$FA,$08 ; $04
	db $31,$02,$0A ; $05
		
OBJLstHdrA_Terry_WalkF0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D4240 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $20,$F0,$00 ; $00
	db $20,$F8,$02 ; $01
	db $20,$00,$04 ; $02
	db $30,$F8,$06 ; $03
	db $30,$00,$08 ; $04
	db $10,$F8,$0A ; $05
		
OBJLstHdrA_Terry_WalkF1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D4300 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $03 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $18,$EF,$00 ; $00
	db $18,$F7,$02 ; $01
	db $18,$FF,$04 ; $02
		
OBJLstHdrA_Terry_WinB0A:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D4300 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Terry_WalkF1A.bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $03 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Terry_WalkF1B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0D4360 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $03 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $28,$EC,$00 ; $00
	db $28,$F4,$02 ; $01
	db $28,$FC,$04 ; $02
	db $38,$FC,$06 ; $03
		
OBJLstHdrB_Terry_WinB0B:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	dpr L0D4360 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_Terry_WalkF1B.bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $03 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Terry_Crouch0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D43E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $28,$F1,$00 ; $00
	db $28,$F9,$02 ; $01
	db $28,$01,$04 ; $02
	db $18,$F9,$06 ; $03
		
OBJLstHdrB_Terry_Crouch0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0D4460 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $38,$F6,$00 ; $00
	db $38,$FE,$02 ; $01
	db $39,$06,$04 ; $02
		
OBJLstHdrA_Terry_BlockG0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D4540 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $21,$F2,$00 ; $00
	db $20,$FA,$02 ; $01
	db $20,$02,$04 ; $02
	db $36,$F2,$06 ; $03
	db $30,$FA,$08 ; $04
	db $30,$02,$0A ; $05
		
OBJLstHdrA_Terry_BlockC0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D4600 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $28,$F6,$00 ; $00
	db $28,$FE,$02 ; $01
	db $28,$06,$04 ; $02
	db $18,$FE,$06 ; $03
		
OBJLstHdrA_Terry_BlockA0A: ;X
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D4600 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Terry_BlockC0A.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $F8 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Terry_BlockA0B: ;X
	db $00 ; iOBJLstHdrA_Flags
	dpr L0D4680 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $10 ; iOBJLstHdrA_YOffset
.bin: ;X
	db $03 ; OBJ Count
	;    Y   X  ID
	db $20,$F6,$00 ; $00
	db $20,$FE,$02 ; $01
	db $24,$06,$04 ; $02
		
OBJLstHdrB_Terry_JumpN3B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0D44C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $0B ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$EF,$00 ; $00
	db $20,$F7,$02 ; $01
	db $20,$FF,$04 ; $02
	db $30,$F7,$06 ; $03
		
; [TCRF] Flipped versions of OBJLstHdrB_Terry_JumpN3B.
OBJLstHdrB_Terry_Unused_JumpN3XFlipB: ;X
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	dpr L0D44C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_Terry_JumpN3B.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Terry_Unused_JumpN3YFlipB: ;X
	db OLF_YFLIP ; iOBJLstHdrA_Flags
	dpr L0D44C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_Terry_JumpN3B.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $F8 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Terry_Unused_JumpN3XYFlipB: ;X
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	dpr L0D44C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_Terry_JumpN3B.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $F8 ; iOBJLstHdrA_YOffset
	
OBJLstHdrA_Terry_ChargeMeter0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D5880 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $28,$F3,$00 ; $00
	db $28,$FB,$02 ; $01
	db $28,$03,$04 ; $02
	db $18,$F3,$06 ; $03
	db $18,$FB,$08 ; $04
	db $18,$03,$0A ; $05
		
OBJLstHdrB_Terry_ChargeMeter0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0D5940 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $38,$F4,$00 ; $00
	db $38,$FC,$02 ; $01
	db $38,$04,$04 ; $02
		
OBJLstHdrA_Terry_ChargeMeter1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D59A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
		
OBJLstHdrA_Terry_RunF1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D63A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $10,$F5,$00 ; $00
	db $19,$FD,$02 ; $01
	db $1B,$05,$04 ; $02
	db $20,$F5,$06 ; $03
	db $29,$FD,$08 ; $04
	db $2B,$05,$0A ; $05
		
OBJLstHdrA_Terry_RollF1:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D63A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Terry_RunF1.bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $FA ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Terry_RunF2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D6460 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $17,$EC,$00 ; $00
	db $17,$F4,$02 ; $01
	db $17,$FC,$04 ; $02
	db $17,$04,$06 ; $03
	db $27,$F2,$08 ; $04
	db $27,$FA,$0A ; $05
	db $27,$02,$0C ; $06
	db $27,$0A,$0E ; $07
		
OBJLstHdrA_Terry_Taunt0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D5680 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $20,$03,$00 ; $00
	db $20,$0B,$02 ; $01
	db $10,$09,$04 ; $02
		
OBJLstHdrB_Terry_Taunt0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0D56E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $30,$03,$00 ; $00
	db $30,$0B,$02 ; $01
		
OBJLstHdrA_Terry_Taunt1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D5720 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $20,$04,$00 ; $00
	db $20,$0C,$02 ; $01
	db $10,$09,$04 ; $02
		
OBJLstHdrA_Terry_Taunt4A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D5780 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $01 ; OBJ Count
	;    Y   X  ID
	db $23,$F7,$00 ; $00
		
OBJLstHdrB_Terry_Taunt4B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0D57A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $20,$FD,$00 ; $00
	db $20,$05,$02 ; $01
	db $22,$0D,$04 ; $02
	db $30,$FD,$06 ; $03
	db $30,$05,$08 ; $04
	db $38,$0D,$0A ; $05
		
OBJLstHdrA_Terry_Taunt5A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D5860 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $01 ; OBJ Count
	;    Y   X  ID
	db $22,$F7,$00 ; $00
		
OBJLstHdrA_Terry_WinA0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D5A60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$FF,$00 ; $00
	db $20,$07,$02 ; $01
	db $21,$0F,$04 ; $02
	db $10,$07,$06 ; $03
		
OBJLstHdrB_Terry_WinA0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0D5AE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $28,$F7,$00 ; $00
	db $30,$FF,$02 ; $01
	db $30,$07,$04 ; $02
	db $3D,$0F,$06 ; $03
		
OBJLstHdrA_Terry_WinA1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D5B60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $20,$FF,$00 ; $00
	db $20,$07,$02 ; $01
	db $20,$0F,$04 ; $02
	db $10,$03,$06 ; $03
	db $12,$10,$08 ; $04
		
OBJLstHdrA_Terry_WinA2A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D5C00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$FC,$00 ; $00
	db $20,$04,$02 ; $01
	db $18,$0C,$04 ; $02
	db $10,$04,$06 ; $03
		
OBJLstHdrB_Terry_WinA2B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0D5C80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $30,$FF,$00 ; $00
	db $28,$07,$02 ; $01
	db $28,$0F,$04 ; $02
	db $38,$07,$06 ; $03
	db $38,$0F,$08 ; $04
		
OBJLstHdrB_Terry_WinA3B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0D5D20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $30,$FE,$00 ; $00
	db $28,$06,$02 ; $01
	db $28,$0E,$04 ; $02
	db $38,$06,$06 ; $03
	db $3B,$0E,$08 ; $04
		
OBJLstHdrA_Terry_WinA7:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D5DC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $23,$FE,$00 ; $00
	db $23,$06,$02 ; $01
	db $1F,$0B,$04 ; $02
	db $37,$FC,$06 ; $03
	db $33,$04,$08 ; $04
	db $13,$03,$0A ; $05
		
OBJLstHdrA_Terry_WinB1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D5E80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1F,$F4,$00 ; $00
	db $21,$FC,$02 ; $01
	db $1F,$04,$04 ; $02
	db $33,$F4,$06 ; $03
	db $31,$FC,$08 ; $04
	db $31,$04,$0A ; $05
		
OBJLstHdrA_Terry_WinB2A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D5F40 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $20,$F6,$00 ; $00
	db $20,$FE,$02 ; $01
	db $20,$06,$04 ; $02
	db $10,$F6,$06 ; $03
	db $10,$FE,$08 ; $04
		
OBJLstHdrB_Terry_WinB2B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0D5FE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $32,$F3,$00 ; $00
	db $30,$FB,$02 ; $01
	db $30,$03,$04 ; $02
		
OBJLstHdrA_Terry_WinB3A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D6040 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $11,$EF,$00 ; $00
	db $1F,$F4,$02 ; $01
	db $20,$FC,$04 ; $02
	db $20,$04,$06 ; $03
	db $10,$00,$08 ; $04
		
OBJLstHdrA_Terry_PunchL0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D46E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $1E,$F0,$00 ; $00
	db $20,$F8,$02 ; $01
	db $20,$00,$04 ; $02
		
OBJLstHdrB_Terry_PunchL0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0D4740 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$F5,$00 ; $00
	db $30,$FD,$02 ; $01
	db $39,$05,$04 ; $02
		
OBJLstHdrA_Terry_PunchL1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L0D47A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $27,$E8,$00 ; $00
	db $1D,$F0,$02 ; $01
	db $20,$F8,$04 ; $02
	db $20,$00,$06 ; $03
		
OBJLstHdrA_Terry_PunchCL1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L0D47A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Terry_PunchL1A.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Terry_PunchH0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L0D4820 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
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
	db $38,$04,$0A ; $05
		
OBJLstHdrA_Terry_PunchH1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L0D48E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $25,$E9,$00 ; $00
	db $21,$F1,$02 ; $01
	db $21,$F9,$04 ; $02
	db $1D,$01,$06 ; $03
	db $33,$F1,$08 ; $04
	db $31,$F9,$0A ; $05
	db $35,$01,$0C ; $06
		
OBJLstHdrA_Terry_KickL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_50 ; iOBJLstHdrA_HitboxId
	dpr L0D49C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $23,$E1,$00 ; $00
	db $23,$E9,$02 ; $01
	db $23,$F1,$04 ; $02
	db $23,$F9,$06 ; $03
	db $13,$ED,$08 ; $04
	db $13,$F5,$0A ; $05
	db $13,$FD,$0C ; $06
	db $33,$F4,$0E ; $07
		
OBJLstHdrA_Terry_KickH0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D4AC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $20,$F7,$00 ; $00
	db $20,$FF,$02 ; $01
	db $20,$07,$04 ; $02
	db $30,$F7,$06 ; $03
	db $30,$FF,$08 ; $04
	db $10,$FF,$0A ; $05
		
OBJLstHdrA_Terry_KickH1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_51 ; iOBJLstHdrA_HitboxId
	dpr L0D4B80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $21,$E4,$00 ; $00
	db $21,$EC,$02 ; $01
	db $27,$F4,$04 ; $02
	db $21,$FC,$06 ; $03
	db $21,$04,$08 ; $04
	db $31,$FC,$0A ; $05
	db $31,$04,$0C ; $06
		
OBJLstHdrA_Terry_PunchCL0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D4C60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $28,$F1,$00 ; $00
	db $28,$F9,$02 ; $01
	db $28,$01,$04 ; $02
	db $18,$F9,$06 ; $03
		
OBJLstHdrA_Terry_PunchCH1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L0D4D80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $24,$E8,$00 ; $00
	db $28,$F0,$02 ; $01
	db $28,$F8,$04 ; $02
	db $28,$00,$06 ; $03
	db $18,$F8,$08 ; $04
		
OBJLstHdrA_Terry_KickCL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_52 ; iOBJLstHdrA_HitboxId
	dpr L0D4E20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $30,$E8,$00 ; $00
	db $2E,$F0,$02 ; $01
	db $26,$F8,$04 ; $02
	db $26,$00,$06 ; $03
	db $36,$F8,$08 ; $04
	db $36,$00,$0A ; $05
		
OBJLstHdrA_Terry_KickCH0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D4EE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $29,$EF,$00 ; $00
	db $27,$F7,$02 ; $01
	db $28,$FF,$04 ; $02
	db $39,$EF,$06 ; $03
	db $37,$F7,$08 ; $04
	db $38,$FF,$0A ; $05
	
; [TCRF] Horizontally flipped version of OBJLstHdrA_Terry_KickCH0.
OBJLstHdrA_Terry_Unused_KickCHXFlip0: ;X
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D4EE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Terry_KickCH0.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
	
OBJLstHdrA_Terry_KickCH1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_53 ; iOBJLstHdrA_HitboxId
	dpr L0D4FA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $30,$E1,$00 ; $00
	db $27,$E9,$02 ; $01
	db $2A,$F1,$04 ; $02
	db $2B,$F9,$06 ; $03
	db $2B,$01,$08 ; $04
	db $3A,$F1,$0A ; $05
	db $3B,$F9,$0C ; $06
	db $3B,$01,$0E ; $07
		
OBJLstHdrA_Terry_PunchA0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L0D50A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $05 ; iOBJLstHdrA_XOffset
	db $04 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $20,$E6,$00 ; $00
	db $18,$EE,$02 ; $01
	db $18,$F6,$04 ; $02
	db $19,$FE,$06 ; $03
	db $28,$EE,$08 ; $04
	db $28,$F6,$0A ; $05
	db $2B,$FE,$0C ; $06
		
OBJLstHdrA_Terry_KickA0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L0D5180 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $02 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $29,$ED,$00 ; $00
	db $14,$F5,$02 ; $01
	db $17,$FD,$04 ; $02
	db $18,$05,$06 ; $03
	db $1A,$0D,$08 ; $04
	db $24,$F5,$0A ; $05
	db $27,$FD,$0C ; $06
	db $28,$05,$0E ; $07
		
OBJLstHdrA_Terry_AttackG1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D60E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $20,$F9,$00 ; $00
	db $20,$01,$02 ; $01
	db $20,$09,$04 ; $02
	db $30,$F7,$06 ; $03
	db $30,$FF,$08 ; $04
	db $30,$07,$0A ; $05
		
OBJLstHdrA_Terry_AttackG2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_4A ; iOBJLstHdrA_HitboxId
	dpr L0D61A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FD ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $20,$F1,$00 ; $00
	db $20,$F9,$02 ; $01
	db $20,$01,$04 ; $02
	db $24,$08,$06 ; $03
	db $30,$E8,$08 ; $04
	db $30,$F0,$0A ; $05
	db $30,$F8,$0C ; $06
	db $30,$00,$0E ; $07
		
OBJLstHdrA_Terry_RunF0:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D61A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Terry_AttackG2.bin ; iOBJLstHdrA_DataPtr
	db $FD ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Terry_AttackA0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L0D62A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $04 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $2B,$F2,$00 ; $00
	db $28,$FA,$02 ; $01
	db $18,$02,$04 ; $02
	db $18,$0A,$06 ; $03
	db $0E,$12,$08 ; $04
	db $28,$02,$0A ; $05
	db $28,$0A,$0C ; $06
	db $1E,$12,$0E ; $07
		
OBJLstHdrA_Terry_ThrowG0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L0D6560 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $21,$F2,$00 ; $00
	db $21,$FA,$02 ; $01
	db $21,$02,$04 ; $02
	db $31,$F2,$06 ; $03
	db $31,$FA,$08 ; $04
	db $32,$02,$0A ; $05
		
OBJLstHdrA_Terry_ThrowG1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L0D6620 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1C,$F0,$00 ; $00
	db $20,$F8,$02 ; $01
	db $22,$00,$04 ; $02
	db $2C,$F0,$06 ; $03
	db $30,$F8,$08 ; $04
	db $32,$00,$0A ; $05
	db $3C,$F0,$0C ; $06
		
OBJLstHdrA_Terry_TimeOver2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D5280 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $24,$F3,$00 ; $00
	db $1C,$FB,$02 ; $01
	db $24,$03,$04 ; $02
	db $34,$F3,$06 ; $03
	db $2C,$FB,$08 ; $04
	db $34,$03,$0A ; $05
	db $2C,$EB,$0C ; $06
		
OBJLstHdrA_Terry_ThrowEndA3:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D5280 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Terry_TimeOver2.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Terry_HitSwoopup2:
	db OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D5280 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Terry_TimeOver2.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Terry_HitSwoopup1:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D5280 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Terry_TimeOver2.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Terry_GuardBreakG0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D5360 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $21,$F2,$00 ; $00
	db $1C,$FA,$02 ; $01
	db $21,$02,$04 ; $02
	db $36,$F3,$06 ; $03
	db $2C,$FA,$08 ; $04
	db $31,$02,$0A ; $05
	db $26,$EA,$0C ; $06
		
OBJLstHdrA_Terry_Hitlow0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D5440 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $32,$F0,$00 ; $00
	db $29,$F8,$02 ; $01
	db $27,$00,$04 ; $02
	db $39,$F8,$06 ; $03
	db $37,$00,$08 ; $04
	db $28,$08,$0A ; $05
		
OBJLstHdrA_Terry_DropMain1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D5500 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $11 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $21,$EE,$00 ; $00
	db $21,$F6,$02 ; $01
	db $19,$FE,$04 ; $02
	db $23,$06,$06 ; $03
	db $29,$FE,$08 ; $04
	db $2C,$E6,$0A ; $05
	db $13,$E7,$0C ; $06
		
OBJLstHdrA_Terry_ThrowRotL0:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D5500 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Terry_DropMain1.bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $02 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Terry_DropMain2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D55E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $02 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $34,$EE,$00 ; $00
	db $34,$F6,$02 ; $01
	db $33,$FE,$04 ; $02
	db $35,$06,$06 ; $03
	db $3B,$E6,$08 ; $04
		
OBJLstHdrA_Terry_PowerWaveL0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D6700 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1D,$F4,$00 ; $00
	db $1A,$FC,$02 ; $01
	db $20,$04,$04 ; $02
	db $2D,$F4,$06 ; $03
	db $2A,$FC,$08 ; $04
	db $30,$04,$0A ; $05
	db $3B,$F0,$0C ; $06
		
OBJLstHdrA_Terry_PowerGeyserD3:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D6700 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Terry_PowerWaveL0.bin ; iOBJLstHdrA_DataPtr
	db $FF ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Terry_PowerWaveL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D67E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $20,$F2,$00 ; $00
	db $1A,$FA,$02 ; $01
	db $20,$02,$04 ; $02
	db $1C,$0A,$06 ; $03
	db $30,$F2,$08 ; $04
	db $2A,$FA,$0A ; $05
	db $30,$02,$0C ; $06
	db $3D,$0A,$0E ; $07
		
OBJLstHdrA_Terry_PowerGeyserD4:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D67E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Terry_PowerWaveL1.bin ; iOBJLstHdrA_DataPtr
	db $FF ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Terry_PowerWaveL2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D68E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $28,$ED,$00 ; $00
	db $24,$F5,$02 ; $01
	db $25,$FD,$04 ; $02
	db $1C,$05,$06 ; $03
	db $38,$ED,$08 ; $04
	db $34,$F5,$0A ; $05
	db $35,$FD,$0C ; $06
	db $3A,$05,$0E ; $07
		
OBJLstHdrA_Terry_BurnKnuckleL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D69E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $1E,$F4,$00 ; $00
	db $1D,$FC,$02 ; $01
	db $1F,$04,$04 ; $02
	db $14,$09,$06 ; $03
	db $0E,$F3,$08 ; $04
	db $2D,$FC,$0A ; $05
	db $33,$04,$0C ; $06
	db $30,$F4,$0E ; $07
		
OBJLstHdrA_Terry_BurnKnuckleL3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_1D ; iOBJLstHdrA_HitboxId
	dpr L0D6AE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $02 ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $21,$E3,$00 ; $00
	db $19,$EB,$02 ; $01
	db $19,$F3,$04 ; $02
	db $20,$FB,$06 ; $03
	db $1F,$03,$08 ; $04
	db $29,$EB,$0A ; $05
	db $29,$F3,$0C ; $06
	db $30,$FB,$0E ; $07
	db $32,$03,$10 ; $08
		
OBJLstHdrA_Terry_BurnKnuckleL4:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_1D ; iOBJLstHdrA_HitboxId
	dpr L0D6C00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $02 ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $21,$E0,$00 ; $00
	db $12,$E8,$02 ; $01
	db $21,$F0,$04 ; $02
	db $21,$F8,$06 ; $03
	db $1F,$00,$08 ; $04
	db $22,$E8,$0A ; $05
	db $31,$F8,$0C ; $06
	db $2F,$00,$0E ; $07
	db $37,$08,$10 ; $08
		
OBJLstHdrA_Terry_CrackShotL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_25 ; iOBJLstHdrA_HitboxId
	dpr L0D6D20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $10,$F1,$00 ; $00
	db $10,$F9,$02 ; $01
	db $10,$01,$04 ; $02
	db $12,$09,$06 ; $03
	db $20,$ED,$08 ; $04
	db $20,$F5,$0A ; $05
	db $20,$FD,$0C ; $06
		
OBJLstHdrA_Terry_CrackShotL3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_26 ; iOBJLstHdrA_HitboxId
	dpr L0D6E00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $08 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $0D,$E5,$00 ; $00
	db $0D,$ED,$02 ; $01
	db $1A,$F5,$04 ; $02
	db $1D,$E5,$06 ; $03
	db $1D,$ED,$08 ; $04
	db $2A,$EE,$0A ; $05
	db $2A,$F6,$0C ; $06
	db $1E,$FD,$0E ; $07
		
OBJLstHdrA_Terry_RollF0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_27 ; iOBJLstHdrA_HitboxId
	dpr L0D6F00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $25,$ED,$00 ; $00
	db $25,$F5,$02 ; $01
	db $25,$FD,$04 ; $02
	db $25,$05,$06 ; $03
	db $35,$EE,$08 ; $04
	db $35,$F6,$0A ; $05
	db $35,$FE,$0C ; $06
		
OBJLstHdrA_Terry_RollF2:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D6F00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Terry_RollF0.bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $06 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Terry_RisingTackleL5:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D6F00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Terry_RollF0.bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Terry_RisingTackleL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_28 ; iOBJLstHdrA_HitboxId
	dpr L0D6FE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $0D ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $11,$F1,$00 ; $00
	db $0F,$F9,$02 ; $01
	db $24,$F1,$04 ; $02
	db $1F,$F9,$06 ; $03
	db $21,$01,$08 ; $04
	db $2F,$F9,$0A ; $05
		
OBJLstHdrA_Terry_RisingTackleL3:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_28 ; iOBJLstHdrA_HitboxId
	dpr L0D6FE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Terry_RisingTackleL1.bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $0D ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Terry_RisingTackleL2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_28 ; iOBJLstHdrA_HitboxId
	dpr L0D70A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $0D ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1D,$EC,$00 ; $00
	db $25,$F4,$02 ; $01
	db $0F,$FC,$04 ; $02
	db $11,$04,$06 ; $03
	db $1F,$FC,$08 ; $04
	db $24,$04,$0A ; $05
	db $2F,$FC,$0C ; $06
		
OBJLstHdrA_Terry_RisingTackleL4:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_28 ; iOBJLstHdrA_HitboxId
	dpr L0D70A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Terry_RisingTackleL2.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $0D ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Terry_PowerDunkL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L0D7180 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $09 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $15,$F3,$00 ; $00
	db $15,$FB,$02 ; $01
	db $18,$03,$04 ; $02
	db $25,$F9,$06 ; $03
	db $25,$01,$08 ; $04
	db $2E,$09,$0A ; $05
		
OBJLstHdrA_Terry_PowerDunkL2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D7240 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $10 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $14,$F0,$00 ; $00
	db $13,$F8,$02 ; $01
	db $13,$00,$04 ; $02
	db $09,$08,$06 ; $03
	db $23,$FD,$08 ; $04
	db $23,$05,$0A ; $05
	db $04,$F6,$0C ; $06
		
OBJLstHdrA_Terry_PowerDunkL3A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_1E ; iOBJLstHdrA_HitboxId
	dpr L0D7320 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $0E ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $18,$EF,$00 ; $00
	db $20,$F7,$02 ; $01
	db $20,$FF,$04 ; $02
	db $28,$EF,$06 ; $03
	db $30,$F7,$08 ; $04
	db $20,$E7,$0A ; $05
		
OBJLstHdrB_Terry_PowerDunkL3B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L0D73E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $0E ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $10,$F7,$00 ; $00
	db $10,$FF,$02 ; $01
	db $10,$07,$04 ; $02
	db $20,$07,$06 ; $03
	db $27,$0F,$08 ; $04
		
OBJLstHdrA_Terry_PowerDunkL4:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_1E ; iOBJLstHdrA_HitboxId
	dpr L0D7480 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $0E ; iOBJLstHdrA_YOffset
.bin:
	db $0C ; OBJ Count
	;    Y   X  ID
	db $26,$F1,$00 ; $00
	db $1F,$F9,$02 ; $01
	db $20,$01,$04 ; $02
	db $20,$09,$06 ; $03
	db $28,$11,$08 ; $04
	db $16,$F1,$0A ; $05
	db $0F,$F9,$0C ; $06
	db $10,$01,$0E ; $07
	db $10,$09,$10 ; $08
	db $0C,$10,$12 ; $09
	db $00,$00,$14 ; $0A
	db $00,$08,$16 ; $0B
		
OBJLstHdrA_Terry_PowerDunkL5A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_1E ; iOBJLstHdrA_HitboxId
	dpr L0D7600 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $06 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $2E,$E7,$00 ; $00
	db $28,$EF,$02 ; $01
	db $28,$F7,$04 ; $02
		
OBJLstHdrA_Terry_PowerGeyserD5:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D7660 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $18,$EF,$00 ; $00
	db $21,$F7,$02 ; $01
	db $1E,$FF,$04 ; $02
	db $1D,$07,$06 ; $03
	db $36,$EF,$08 ; $04
	db $31,$F7,$0A ; $05
	db $2E,$FF,$0C ; $06
	db $36,$05,$0E ; $07
		
OBJLstHdrA_Terry_PowerGeyserE2: ;X
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L0D7660 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Terry_PowerGeyserD5.bin ; iOBJLstHdrA_DataPtr
	db $FF ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		

OBJLstPtrTable_Krauser_Idle:
	dw OBJLstHdrA_Krauser_Idle0A, OBJLstHdrB_Krauser_Idle0B
	dw OBJLstHdrA_Krauser_Idle1A, OBJLstHdrB_Krauser_Idle0B
	dw OBJLstHdrA_Krauser_Idle2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_Idle1A, OBJLstHdrB_Krauser_Idle0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_WalkF:
	dw OBJLstHdrA_Krauser_WalkF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_WalkF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_WalkF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_Idle1A, OBJLstHdrB_Krauser_Idle0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_Crouch:
	dw OBJLstHdrA_Krauser_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_JumpN:
	dw OBJLstHdrA_Krauser_Crouch0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_JumpN3A, OBJLstHdrB_Krauser_JumpN3B
	dw OBJLstHdrA_Krauser_JumpN3A, OBJLstHdrB_Krauser_JumpN3B
	dw OBJLstHdrA_Krauser_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_BlockG:
	dw OBJLstHdrA_Krauser_BlockG0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_BlockC:
	dw OBJLstHdrA_Krauser_BlockC0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_BlockA:
	dw OBJLstHdrA_Krauser_BlockA0A, OBJLstHdrB_Krauser_JumpN3B ;X
	dw OBJLstHdrA_Krauser_Crouch0, OBJLSTPTR_NONE ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_RunF:
	dw OBJLstHdrA_Krauser_RunF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_RunF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_RunF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_RunF1, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_HopB:
	dw OBJLstHdrA_Krauser_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_ChargeMeter:
	dw OBJLstHdrA_Krauser_ChargeMeter0A, OBJLstHdrB_Krauser_ChargeMeter0B
	dw OBJLstHdrA_Krauser_ChargeMeter1A, OBJLstHdrB_Krauser_ChargeMeter0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_Taunt:
	dw OBJLstHdrA_Krauser_Taunt0A, OBJLstHdrB_Krauser_Taunt0B
	dw OBJLstHdrA_Krauser_Taunt1A, OBJLstHdrB_Krauser_Taunt0B
	dw OBJLstHdrA_Krauser_Taunt0A, OBJLstHdrB_Krauser_Taunt0B
	dw OBJLstHdrA_Krauser_Taunt3A, OBJLstHdrB_Krauser_Taunt0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_WinA:
	dw OBJLstHdrA_Krauser_WinA0A, OBJLstHdrB_Krauser_WinA0B
	dw OBJLstHdrA_Krauser_WinA1A, OBJLstHdrB_Krauser_WinA0B
	dw OBJLstHdrA_Krauser_WinA2A, OBJLstHdrB_Krauser_WinA0B
	dw OBJLstHdrA_Krauser_WinA3A, OBJLstHdrB_Krauser_WinA0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_WinB:
	dw OBJLstHdrA_Krauser_Taunt0A, OBJLstHdrB_Krauser_Taunt0B
	dw OBJLstHdrA_Krauser_Taunt1A, OBJLstHdrB_Krauser_Taunt0B
	dw OBJLstHdrA_Krauser_Taunt0A, OBJLstHdrB_Krauser_Taunt0B
	dw OBJLstHdrA_Krauser_Taunt3A, OBJLstHdrB_Krauser_Taunt0B
	dw OBJLstHdrA_Krauser_Taunt0A, OBJLstHdrB_Krauser_Taunt0B
	dw OBJLstHdrA_Krauser_WinB5A, OBJLstHdrB_Krauser_Taunt0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_Intro:
	dw OBJLstHdrA_Krauser_Intro0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_Intro1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_Intro2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_Intro3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_Intro4A, OBJLstHdrB_Krauser_ChargeMeter0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_PunchL:
	dw OBJLstHdrA_Krauser_PunchL0A, OBJLstHdrB_Krauser_PunchL0B
	dw OBJLstHdrA_Krauser_PunchL1A, OBJLstHdrB_Krauser_PunchL1B
	dw OBJLstHdrA_Krauser_PunchL2A, OBJLstHdrB_Krauser_PunchL1B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_PunchH:
	dw OBJLstHdrA_Krauser_PunchH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_PunchH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_PunchH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_PunchH0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_KickL:
	dw OBJLstHdrA_Krauser_KickL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_KickL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_KickL0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_KickH:
	dw OBJLstHdrA_Krauser_KickH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_KickH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_KickH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_KickH0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_PunchCL:
	dw OBJLstHdrA_Krauser_PunchCL0A, OBJLstHdrB_Krauser_PunchCL0B
	dw OBJLstHdrA_Krauser_PunchCL1A, OBJLstHdrB_Krauser_PunchCL0B
	dw OBJLstHdrA_Krauser_PunchCL0A, OBJLstHdrB_Krauser_PunchCL0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_PunchCH:
	dw OBJLstHdrA_Krauser_PunchCL0A, OBJLstHdrB_Krauser_PunchCL0B
	dw OBJLstHdrA_Krauser_PunchCH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_PunchCH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_PunchCL0A, OBJLstHdrB_Krauser_PunchCL0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_KickCL:
	dw OBJLstHdrA_Krauser_PunchCL0A, OBJLstHdrB_Krauser_PunchCL0B
	dw OBJLstHdrA_Krauser_KickCL1A, OBJLstHdrB_Krauser_KickCL1B
	dw OBJLstHdrA_Krauser_PunchCL0A, OBJLstHdrB_Krauser_PunchCL0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_KickCH:
	dw OBJLstHdrA_Krauser_PunchCL0A, OBJLstHdrB_Krauser_PunchCL0B
	dw OBJLstHdrA_Krauser_KickCL1A, OBJLstHdrB_Krauser_KickCL1B
	dw OBJLstHdrA_Krauser_KickCL1A, OBJLstHdrB_Krauser_KickCL1B
	dw OBJLstHdrA_Krauser_PunchCL0A, OBJLstHdrB_Krauser_PunchCL0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_PunchA:
	dw OBJLstHdrA_Krauser_PunchA0A, OBJLstHdrB_Krauser_PunchA0B
	dw OBJLstHdrA_Krauser_PunchA0A, OBJLstHdrB_Krauser_PunchA0B
	dw OBJLstHdrA_Krauser_JumpN3A, OBJLstHdrB_Krauser_JumpN3B
	dw OBJLstHdrA_Krauser_JumpN1, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Krauser_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_KickA:
	dw OBJLstHdrA_Krauser_KickA0A, OBJLstHdrB_Krauser_KickA0B
	dw OBJLstHdrA_Krauser_KickA0A, OBJLstHdrB_Krauser_KickA0B
	dw OBJLstHdrA_Krauser_JumpN3A, OBJLstHdrB_Krauser_JumpN3B
	dw OBJLstHdrA_Krauser_JumpN1, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Krauser_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_AttackA:
	dw OBJLstHdrA_Krauser_AttackA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_AttackA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_JumpN3A, OBJLstHdrB_Krauser_JumpN3B
	dw OBJLstHdrA_Krauser_JumpN1, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Krauser_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_AttackG:
	dw OBJLstHdrA_Krauser_KickH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_AttackG1A, OBJLstHdrB_Krauser_AttackG1B
	dw OBJLstHdrA_Krauser_AttackG1A, OBJLstHdrB_Krauser_AttackG2B
	dw OBJLstHdrA_Krauser_AttackG1A, OBJLstHdrB_Krauser_AttackG2B ;X
	dw OBJLstHdrA_Krauser_KickH0, OBJLSTPTR_NONE ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_RollF:
	dw OBJLstHdrA_Krauser_RollF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_RollF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_RollF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_RollF3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_RollB:
	dw OBJLstHdrA_Krauser_RollF3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_RollF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_RollF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_RollF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_GuardBreakG:
	dw OBJLstHdrA_Krauser_GuardBreakG0A, OBJLstHdrB_Krauser_GuardBreakG0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_Dizzy:
	dw OBJLstHdrA_Krauser_Idle0A, OBJLstHdrB_Krauser_Idle0B
	dw OBJLstHdrA_Krauser_GuardBreakG0A, OBJLstHdrB_Krauser_GuardBreakG0B ;X
OBJLstPtrTable_Krauser_TimeOver:
	dw OBJLstHdrA_Krauser_TimeOver2A, OBJLstHdrB_Krauser_GuardBreakG0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_Hitlow:
	dw OBJLstHdrA_Krauser_RollF3, OBJLSTPTR_NONE ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_GuardBreakA:
	dw OBJLstHdrA_Krauser_GuardBreakG0A, OBJLstHdrB_Krauser_GuardBreakG0B ;X
	dw OBJLstHdrA_Krauser_Crouch0, OBJLSTPTR_NONE ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_BackjumpRecA:
	dw OBJLstHdrA_Krauser_GuardBreakG0A, OBJLstHdrB_Krauser_GuardBreakG0B
	dw OBJLstHdrA_Krauser_JumpN3A, OBJLstHdrB_Krauser_JumpN3B
	dw OBJLstHdrA_Krauser_JumpN3A, OBJLstHdrB_Krauser_JumpN3B
	dw OBJLstHdrA_Krauser_JumpN3A, OBJLstHdrB_Krauser_JumpN3B
	dw OBJLstHdrA_Krauser_JumpN3A, OBJLstHdrB_Krauser_JumpN3B
	dw OBJLstHdrA_Krauser_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_DropMain:
	dw OBJLstHdrA_Krauser_GuardBreakG0A, OBJLstHdrB_Krauser_GuardBreakG0B
	dw OBJLstHdrA_Krauser_RollF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_DropMain2, OBJLSTPTR_NONE
OBJLstPtrTable_Krauser_HitMultigs:
	dw OBJLstHdrA_Krauser_RollF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_DropMain2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_HitSwoopup:
	dw OBJLstHdrA_Krauser_TimeOver2A, OBJLstHdrB_Krauser_GuardBreakG0B
	dw OBJLstHdrA_Krauser_HitSwoopup1A, OBJLstHdrB_Krauser_HitSwoopup1B
	dw OBJLstHdrA_Krauser_HitSwoopup2A, OBJLstHdrB_Krauser_HitSwoopup2B
OBJLstPtrTable_Krauser_ThrowEndA:
	dw OBJLstHdrA_Krauser_ThrowEndA3A, OBJLstHdrB_Krauser_ThrowEndA3B
	dw OBJLstHdrA_Krauser_ThrowEndA3A, OBJLstHdrB_Krauser_ThrowEndA3B
	dw OBJLstHdrA_Krauser_RollF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_DropMain2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_DropDbg:
	dw OBJLstHdrA_Krauser_TimeOver2A, OBJLstHdrB_Krauser_GuardBreakG0B
	dw OBJLstHdrA_Krauser_RollF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_DropMain2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_ThrowRotL:
	dw OBJLstHdrA_Krauser_ThrowRotL0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_Wakeup:
	dw OBJLstHdrA_Krauser_Crouch0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_ThrowG:
	dw OBJLstHdrA_Krauser_PunchL1A, OBJLstHdrB_Krauser_PunchL1B
	dw OBJLstHdrA_Krauser_ThrowG1A, OBJLstHdrB_Krauser_ChargeMeter0B
	dw OBJLstHdrA_Krauser_ThrowG2A, OBJLstHdrB_Krauser_ThrowG2B
	dw OBJLstHdrA_Krauser_ThrowG3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_ThrowG3, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_HighBlitzBallL:
	dw OBJLstHdrA_Krauser_HighBlitzBallL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_HighBlitzBallL1A, OBJLstHdrB_Krauser_PunchL0B
	dw OBJLstHdrA_Krauser_PunchL2A, OBJLstHdrB_Krauser_PunchL1B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_LowBlitzBallL:
	dw OBJLstHdrA_Krauser_HighBlitzBallL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_LowBlitzBallL1A, OBJLstHdrB_Krauser_PunchL1B
	dw OBJLstHdrA_Krauser_PunchL2A, OBJLstHdrB_Krauser_PunchL1B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_LegTomahawkL:
	dw OBJLstHdrA_Krauser_KickL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_LegTomahawkL1A, OBJLstHdrB_Krauser_LegTomahawkL1B
	dw OBJLstHdrA_Krauser_LegTomahawkL2A, OBJLstHdrB_Krauser_LegTomahawkL1B
	dw OBJLstHdrA_Krauser_LegTomahawkL3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_LegTomahawkL4A, OBJLstHdrB_Krauser_LegTomahawkL4B
	dw OBJLstHdrA_Krauser_LegTomahawkL5A, OBJLstHdrB_Krauser_LegTomahawkL4B
	dw OBJLstHdrA_Krauser_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_KaiserKickL:
	dw OBJLstHdrA_Krauser_KickH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_AttackA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_DropMain2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_KaiserDuelSobatL:
	dw OBJLstHdrA_Krauser_RunF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_KaiserDuelSobatL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_KickL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_KickL1, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_KaiserSuplexL:
	dw OBJLstHdrA_Krauser_KaiserSuplexL0A, OBJLstHdrB_Krauser_PunchL0B
	dw OBJLstHdrA_Krauser_KaiserSuplexL1A, OBJLstHdrB_Krauser_KaiserSuplexL1B
	dw OBJLstHdrA_Krauser_KaiserSuplexL2A, OBJLstHdrB_Krauser_KaiserSuplexL2B
	dw OBJLstHdrA_Krauser_KaiserSuplexL3A, OBJLstHdrB_Krauser_KaiserSuplexL3B
	dw OBJLstHdrA_Krauser_KaiserSuplexL4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_KaiserSuplexL5A, OBJLstHdrB_Krauser_KaiserSuplexL5B
	dw OBJLstHdrA_Krauser_KaiserSuplexL4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_KaiserSuplexL7, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_KaiserSuplexL8, OBJLSTPTR_NONE
	dw OBJLstHdrA_Krauser_KaiserSuplexL9, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Krauser_KaiserWaveS:
	dw OBJLstHdrA_Krauser_PunchL0A, OBJLstHdrB_Krauser_PunchL0B
	dw OBJLstHdrA_Krauser_KaiserWaveS1A, OBJLstHdrB_Krauser_ChargeMeter0B
	dw OBJLstHdrA_Krauser_KaiserWaveS2A, OBJLstHdrB_Krauser_ChargeMeter0B
	dw OBJLstHdrA_Krauser_KaiserWaveS3A, OBJLstHdrB_Krauser_KaiserWaveS3B
	dw OBJLstHdrA_Krauser_KaiserWaveS4A, OBJLstHdrB_Krauser_KaiserWaveS3B
	dw OBJLstHdrA_Krauser_PunchL0A, OBJLstHdrB_Krauser_PunchL0B
	dw OBJLSTPTR_NONE
		
OBJLstHdrA_Krauser_Idle0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L154000 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $19,$EA,$00 ; $00
	db $1D,$F2,$02 ; $01
	db $20,$FA,$04 ; $02
	db $20,$02,$06 ; $03
	db $10,$FA,$08 ; $04
	db $10,$02,$0A ; $05
		
OBJLstHdrB_Krauser_Idle0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1540C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$F2,$00 ; $00
	db $30,$FA,$02 ; $01
	db $30,$02,$04 ; $02
		
OBJLstHdrA_Krauser_Idle1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L154120 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1D,$F2,$00 ; $00
	db $20,$FA,$02 ; $01
	db $20,$02,$04 ; $02
	db $10,$FA,$06 ; $03
	db $10,$02,$08 ; $04
	db $19,$EA,$0A ; $05
		
OBJLstHdrA_Krauser_Idle2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1541E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $1E,$EA,$00 ; $00
	db $1E,$F2,$02 ; $01
	db $20,$02,$04 ; $02
	db $30,$F5,$06 ; $03
	db $29,$FA,$08 ; $04
	db $30,$02,$0A ; $05
	db $19,$FA,$0C ; $06
	db $10,$02,$0E ; $07
		
OBJLstHdrA_Krauser_WalkF0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1542E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1C,$F2,$00 ; $00
	db $1A,$FA,$02 ; $01
	db $1C,$02,$04 ; $02
	db $2A,$FA,$06 ; $03
	db $2C,$02,$08 ; $04
	db $3A,$FF,$0A ; $05
	db $18,$EA,$0C ; $06
		
OBJLstHdrA_Krauser_WalkF1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1543C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $1B,$F3,$00 ; $00
	db $19,$FB,$02 ; $01
	db $1B,$03,$04 ; $02
	db $29,$FB,$06 ; $03
	db $2B,$03,$08 ; $04
	db $39,$FB,$0A ; $05
	db $3B,$03,$0C ; $06
	db $17,$EB,$0E ; $07
		
OBJLstHdrA_Krauser_Crouch0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1544C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Krauser_ThrowG3.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Krauser_ThrowG3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L1544C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $25,$F2,$00 ; $00
	db $23,$FA,$02 ; $01
	db $25,$02,$04 ; $02
	db $35,$F2,$06 ; $03
	db $33,$FA,$08 ; $04
	db $35,$02,$0A ; $05
	db $21,$EA,$0C ; $06
		
OBJLstHdrA_Krauser_KaiserSuplexL9:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1544C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Krauser_ThrowG3.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Krauser_JumpN1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1545A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $0E,$E8,$00 ; $00
	db $11,$F0,$02 ; $01
	db $0F,$F8,$04 ; $02
	db $11,$00,$06 ; $03
	db $1F,$F8,$08 ; $04
	db $21,$00,$0A ; $05
	db $2F,$FC,$0C ; $06
		
OBJLstHdrA_Krauser_KaiserSuplexL4:
	db OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L1545A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Krauser_JumpN1.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $F0 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Krauser_KaiserSuplexL8:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1545A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Krauser_JumpN1.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Krauser_JumpN3A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L154680 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $0B ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $0C,$E8,$00 ; $00
	db $0F,$F0,$02 ; $01
	db $10,$F8,$04 ; $02
	db $10,$00,$06 ; $03
	db $00,$F8,$08 ; $04
		
OBJLstHdrA_Krauser_KaiserSuplexL5A:
	db OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L154680 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Krauser_JumpN3A.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $EE ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Krauser_JumpN3B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L154720 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $0B ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$F6,$00 ; $00
	db $20,$FE,$02 ; $01
	db $30,$FE,$04 ; $02
	db $24,$EE,$06 ; $03
		
OBJLstHdrB_Krauser_KaiserSuplexL5B:
	db OLF_YFLIP ; iOBJLstHdrA_Flags
	dpr L154720 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_Krauser_JumpN3B.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $EE ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Krauser_BlockG0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1547A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1C,$F4,$00 ; $00
	db $1B,$FC,$02 ; $01
	db $1D,$04,$04 ; $02
	db $30,$F5,$06 ; $03
	db $2B,$FC,$08 ; $04
	db $2D,$04,$0A ; $05
	db $3D,$04,$0C ; $06
		
OBJLstHdrA_Krauser_BlockC0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L154880 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $24,$F5,$00 ; $00
	db $22,$FD,$02 ; $01
	db $25,$05,$04 ; $02
	db $34,$F5,$06 ; $03
	db $32,$FD,$08 ; $04
	db $35,$05,$0A ; $05
		
OBJLstHdrA_Krauser_BlockA0A: ;X
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L154940 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $0B ; iOBJLstHdrA_YOffset
.bin: ;X
	db $04 ; OBJ Count
	;    Y   X  ID
	db $0E,$F4,$00 ; $00
	db $10,$FC,$02 ; $01
	db $10,$04,$04 ; $02
	db $00,$FC,$06 ; $03
		
OBJLstHdrA_Krauser_RunF0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1549C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $18,$E4,$00 ; $00
	db $1E,$EC,$02 ; $01
	db $1E,$F4,$04 ; $02
	db $1B,$FB,$06 ; $03
	db $2E,$EC,$08 ; $04
	db $2E,$F4,$0A ; $05
	db $2B,$FC,$0C ; $06
	db $34,$04,$0E ; $07
		
OBJLstHdrA_Krauser_RunF1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L154AC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1C,$E5,$00 ; $00
	db $1D,$ED,$02 ; $01
	db $1E,$F3,$04 ; $02
	db $1F,$FB,$06 ; $03
	db $2E,$F6,$08 ; $04
	db $2F,$FE,$0A ; $05
	db $3E,$F8,$0C ; $06
		
OBJLstHdrA_Krauser_RunF2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L154BA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $1E,$E7,$00 ; $00
	db $1F,$EF,$02 ; $01
	db $17,$F7,$04 ; $02
	db $18,$FF,$06 ; $03
	db $37,$E7,$08 ; $04
	db $2F,$EF,$0A ; $05
	db $27,$F7,$0C ; $06
	db $29,$FF,$0E ; $07
	db $2E,$07,$10 ; $08
		
OBJLstHdrA_Krauser_ChargeMeter0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L154CC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $09 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $18,$ED,$00 ; $00
	db $18,$F5,$02 ; $01
	db $16,$FD,$04 ; $02
	db $08,$ED,$06 ; $03
	db $08,$F5,$08 ; $04
		
OBJLstHdrA_Krauser_ChargeMeter1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L154D60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $09 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $18,$ED,$00 ; $00
	db $18,$F5,$02 ; $01
	db $15,$FD,$04 ; $02
	db $08,$ED,$06 ; $03
	db $08,$F5,$08 ; $04
		
OBJLstHdrA_Krauser_Taunt0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L154E00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $09 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $19,$ED,$00 ; $00
	db $20,$F5,$02 ; $01
	db $20,$FD,$04 ; $02
	db $10,$F5,$06 ; $03
	db $10,$FD,$08 ; $04
		
OBJLstHdrB_Krauser_Taunt0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L154EA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $09 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$F2,$00 ; $00
	db $30,$FA,$02 ; $01
	db $3E,$EA,$04 ; $02
		
OBJLstHdrA_Krauser_Taunt1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L154F00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $09 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $20,$F4,$00 ; $00
	db $20,$FC,$02 ; $01
	db $10,$F4,$04 ; $02
	db $10,$FC,$06 ; $03
	db $1E,$EC,$08 ; $04
	db $0E,$EC,$0A ; $05
		
OBJLstHdrA_Krauser_Taunt3A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L154FC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $09 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $20,$F5,$00 ; $00
	db $20,$FD,$02 ; $01
	db $10,$F5,$04 ; $02
	db $10,$FD,$06 ; $03
	db $17,$ED,$08 ; $04
		
OBJLstHdrA_Krauser_WinA0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L155060 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $28,$FB,$00 ; $00
	db $18,$FB,$02 ; $01
	db $08,$FB,$04 ; $02
		
OBJLstHdrB_Krauser_WinA0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1550C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $16,$03,$00 ; $00
	db $26,$03,$02 ; $01
	db $36,$04,$04 ; $02
	db $1C,$0B,$06 ; $03
	db $38,$FA,$08 ; $04
	db $3E,$F2,$0A ; $05
		
OBJLstHdrA_Krauser_WinA1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L155180 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $28,$FB,$00 ; $00
	db $18,$FB,$02 ; $01
	db $08,$FB,$04 ; $02
		
OBJLstHdrA_Krauser_WinA2A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1551E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $28,$FB,$00 ; $00
	db $18,$FB,$02 ; $01
	db $08,$FB,$04 ; $02
	db $21,$F3,$06 ; $03
		
OBJLstHdrA_Krauser_WinA3A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L155260 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $28,$FB,$00 ; $00
	db $18,$FB,$02 ; $01
	db $08,$FB,$04 ; $02
	db $1D,$F3,$06 ; $03
		
OBJLstHdrA_Krauser_WinB5A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1552E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $09 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$F3,$00 ; $00
	db $20,$FB,$02 ; $01
	db $10,$F6,$04 ; $02
	db $16,$FE,$06 ; $03
		
OBJLstHdrA_Krauser_Intro0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L155360 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $09 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $17,$EE,$00 ; $00
	db $17,$F6,$02 ; $01
	db $1E,$FE,$04 ; $02
	db $27,$EE,$06 ; $03
	db $27,$F6,$08 ; $04
	db $2E,$FE,$0A ; $05
	db $37,$EE,$0C ; $06
	db $37,$F6,$0E ; $07
	db $3E,$FE,$10 ; $08
		
OBJLstHdrA_Krauser_Intro1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L155480 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $09 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $26,$EB,$00 ; $00
	db $24,$F3,$02 ; $01
	db $28,$FB,$04 ; $02
	db $36,$EB,$06 ; $03
	db $34,$F3,$08 ; $04
	db $38,$FB,$0A ; $05
	db $34,$03,$0C ; $06
		
OBJLstHdrA_Krauser_Intro2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L155560 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $09 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $0D ; OBJ Count
	;    Y   X  ID
	db $18,$EB,$00 ; $00
	db $16,$F3,$02 ; $01
	db $15,$FB,$04 ; $02
	db $15,$03,$06 ; $03
	db $28,$EB,$08 ; $04
	db $26,$F3,$0A ; $05
	db $25,$FB,$0C ; $06
	db $25,$03,$0E ; $07
	db $38,$EB,$10 ; $08
	db $36,$F3,$12 ; $09
	db $35,$FB,$14 ; $0A
	db $35,$03,$16 ; $0B
	db $17,$E3,$18 ; $0C
		
OBJLstHdrA_Krauser_Intro3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L155700 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $09 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $0D ; OBJ Count
	;    Y   X  ID
	db $1B,$E5,$00 ; $00
	db $18,$ED,$02 ; $01
	db $16,$F4,$04 ; $02
	db $18,$FB,$06 ; $03
	db $18,$03,$08 ; $04
	db $26,$F3,$0A ; $05
	db $29,$FB,$0C ; $06
	db $2F,$EB,$0E ; $07
	db $33,$03,$10 ; $08
	db $36,$F3,$12 ; $09
	db $39,$FB,$14 ; $0A
	db $0F,$06,$16 ; $0B
	db $3F,$EB,$18 ; $0C
		
OBJLstHdrA_Krauser_Intro4A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1558A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $09 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $18,$EB,$00 ; $00
	db $18,$F3,$02 ; $01
	db $18,$FB,$04 ; $02
	db $18,$03,$06 ; $03
	db $08,$F3,$08 ; $04
	db $17,$E3,$0A ; $05
		
OBJLstHdrA_Krauser_PunchL0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L155960 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Krauser_KaiserSuplexL1A.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Krauser_KaiserSuplexL0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L155960 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Krauser_KaiserSuplexL1A.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Krauser_KaiserSuplexL1A:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L155960 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $18,$F1,$00 ; $00
	db $20,$F9,$02 ; $01
	db $20,$01,$04 ; $02
	db $10,$F9,$06 ; $03
	db $10,$01,$08 ; $04
	db $1E,$09,$0A ; $05
		
OBJLstHdrB_Krauser_PunchL0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L155A20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_Krauser_KaiserSuplexL1B.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Krauser_KaiserSuplexL1B:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	dpr L155A20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$F3,$00 ; $00
	db $30,$FB,$02 ; $01
	db $30,$03,$04 ; $02
		
OBJLstHdrA_Krauser_PunchL1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L155A80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Krauser_KaiserSuplexL2A.bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Krauser_KaiserSuplexL2A:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L155A80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FF ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $2C,$E3,$00 ; $00
	db $28,$EB,$02 ; $01
	db $22,$F3,$04 ; $02
	db $18,$FA,$06 ; $03
	db $18,$02,$08 ; $04
	db $12,$F2,$0A ; $05
		
OBJLstHdrA_Krauser_LowBlitzBallL1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L155A80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Krauser_KaiserSuplexL2A.bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Krauser_PunchL1B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L155B40 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_Krauser_KaiserSuplexL2B.bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Krauser_KaiserSuplexL2B:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	dpr L155B40 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FF ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $30,$F1,$00 ; $00
	db $2B,$F4,$02 ; $01
	db $2B,$FC,$04 ; $02
	db $35,$03,$06 ; $03
	db $1B,$FB,$08 ; $04
		
OBJLstHdrA_Krauser_PunchL2A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L155BE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $18,$EB,$00 ; $00
	db $20,$F3,$02 ; $01
	db $18,$FB,$04 ; $02
	db $16,$03,$06 ; $03
	db $10,$F3,$08 ; $04
	db $28,$EB,$0A ; $05
		
OBJLstHdrA_Krauser_PunchH0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L155CA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $1B,$EF,$00 ; $00
	db $1D,$F7,$02 ; $01
	db $20,$FF,$04 ; $02
	db $30,$F0,$06 ; $03
	db $2D,$F7,$08 ; $04
	db $30,$FF,$0A ; $05
	db $30,$07,$0C ; $06
	db $20,$07,$0E ; $07
		
OBJLstHdrA_Krauser_PunchH1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_66 ; iOBJLstHdrA_HitboxId
	dpr L155DA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $1A,$DE,$00 ; $00
	db $1D,$E6,$02 ; $01
	db $1E,$EE,$04 ; $02
	db $21,$F6,$06 ; $03
	db $23,$FE,$08 ; $04
	db $31,$EE,$0A ; $05
	db $31,$F6,$0C ; $06
	db $33,$FE,$0E ; $07
	db $38,$06,$10 ; $08
		
OBJLstHdrA_Krauser_KickL0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L155EC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1F,$FA,$00 ; $00
	db $1B,$02,$02 ; $01
	db $19,$0A,$04 ; $02
	db $2C,$F2,$06 ; $03
	db $2F,$FA,$08 ; $04
	db $2B,$02,$0A ; $05
	db $3B,$02,$0C ; $06
		
OBJLstHdrA_Krauser_RollF1:
	db OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L155EC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Krauser_KickL0.bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $FC ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Krauser_KickL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_51 ; iOBJLstHdrA_HitboxId
	dpr L155FA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $2A,$E7,$00 ; $00
	db $21,$EF,$02 ; $01
	db $1E,$F7,$04 ; $02
	db $19,$FF,$06 ; $03
	db $11,$07,$08 ; $04
	db $29,$FF,$0A ; $05
	db $14,$0F,$0C ; $06
	db $21,$07,$0E ; $07
	db $39,$02,$10 ; $08
		
OBJLstHdrA_Krauser_KickH0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1560C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $16,$F1,$00 ; $00
	db $19,$F9,$02 ; $01
	db $19,$01,$04 ; $02
	db $1A,$09,$06 ; $03
	db $29,$F1,$08 ; $04
	db $29,$F9,$0A ; $05
	db $29,$01,$0C ; $06
	db $39,$FD,$0E ; $07
		
OBJLstHdrA_Krauser_KaiserDuelSobatL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L1560C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Krauser_KickH0.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Krauser_KickH1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_67 ; iOBJLstHdrA_HitboxId
	dpr L1561C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $10,$F7,$00 ; $00
	db $13,$FF,$02 ; $01
	db $1C,$07,$04 ; $02
	db $28,$E4,$06 ; $03
	db $27,$EC,$08 ; $04
	db $20,$F4,$0A ; $05
	db $20,$FC,$0C ; $06
	db $23,$04,$0E ; $07
	db $30,$FC,$10 ; $08
		
OBJLstHdrA_Krauser_PunchCL0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1562E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $28,$F3,$00 ; $00
	db $18,$F3,$02 ; $01
	db $24,$EB,$04 ; $02
		
OBJLstHdrB_Krauser_PunchCL0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L156340 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $22,$FB,$00 ; $00
	db $25,$03,$02 ; $01
	db $32,$FB,$04 ; $02
	db $35,$03,$06 ; $03
	db $20,$0B,$08 ; $04
	db $38,$F3,$0A ; $05
	db $3D,$EB,$0C ; $06
		
OBJLstHdrA_Krauser_PunchCL1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_57 ; iOBJLstHdrA_HitboxId
	dpr L156420 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $28,$F3,$00 ; $00
	db $18,$F3,$02 ; $01
	db $24,$EB,$04 ; $02
	db $1E,$E3,$06 ; $03
		
OBJLstHdrA_Krauser_PunchCH1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_50 ; iOBJLstHdrA_HitboxId
	dpr L1564A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $29,$DE,$00 ; $00
	db $1F,$E6,$02 ; $01
	db $1F,$EE,$04 ; $02
	db $22,$F6,$06 ; $03
	db $25,$FE,$08 ; $04
	db $30,$EE,$0A ; $05
	db $32,$F6,$0C ; $06
	db $35,$FE,$0E ; $07
	db $39,$06,$10 ; $08
		
OBJLstHdrA_Krauser_KickCL1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_52 ; iOBJLstHdrA_HitboxId
	dpr L1565C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $20,$F8,$00 ; $00
	db $20,$00,$02 ; $01
	db $20,$08,$04 ; $02
	db $20,$F0,$06 ; $03
	db $33,$F8,$08 ; $04
	db $35,$F0,$0A ; $05
	db $39,$E8,$0C ; $06
		
OBJLstHdrA_Krauser_KickA0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L1565C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Krauser_KickCL1A.bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $F8 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Krauser_KickCL1B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1566A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$FB,$00 ; $00
	db $30,$03,$02 ; $01
	db $30,$0B,$04 ; $02
		
OBJLstHdrA_Krauser_PunchA0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L156700 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $02 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $10,$E4,$00 ; $00
	db $1A,$EB,$02 ; $01
	db $1E,$F3,$04 ; $02
	db $1F,$FB,$06 ; $03
	db $0E,$F3,$08 ; $04
	db $0F,$FB,$0A ; $05
	db $10,$03,$0C ; $06
		
OBJLstHdrB_Krauser_PunchA0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1567E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $02 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $20,$03,$00 ; $00
	db $20,$0B,$02 ; $01
	db $20,$13,$04 ; $02
		
OBJLstHdrB_Krauser_KaiserSuplexL3B:
	db OLF_YFLIP ; iOBJLstHdrA_Flags
	dpr L1567E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_Krauser_PunchA0B.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $F8 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Krauser_KickA0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L156840 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $F8 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$FB,$00 ; $00
	db $30,$03,$02 ; $01
	db $30,$0B,$04 ; $02
		
OBJLstHdrA_Krauser_AttackG1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_68 ; iOBJLstHdrA_HitboxId
	dpr L1568A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $18,$06,$00 ; $00
	db $1C,$FE,$02 ; $01
	db $2C,$FE,$04 ; $02
	db $28,$06,$06 ; $03
	db $28,$0E,$08 ; $04
	db $2E,$F6,$0A ; $05
	db $33,$EE,$0C ; $06
	db $3C,$FE,$0E ; $07
		
OBJLstHdrB_Krauser_AttackG1B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1569A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $18,$0B,$00 ; $00
	db $18,$13,$02 ; $01
		
OBJLstHdrB_Krauser_AttackG2B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1569E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $18,$0B,$00 ; $00
	db $18,$13,$02 ; $01
		
OBJLstHdrA_Krauser_AttackA0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_40 ; iOBJLstHdrA_HitboxId
	dpr L156A20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $0C ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $1F,$E4,$00 ; $00
	db $1E,$EC,$02 ; $01
	db $1C,$F4,$04 ; $02
	db $1C,$FC,$06 ; $03
	db $13,$04,$08 ; $04
	db $12,$0C,$0A ; $05
	db $0B,$F4,$0C ; $06
	db $0C,$FC,$0E ; $07
	db $03,$04,$10 ; $08
		
OBJLstHdrA_Krauser_GuardBreakG0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L156B40 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $20,$F9,$00 ; $00
	db $20,$01,$02 ; $01
	db $1A,$F1,$04 ; $02
	db $1F,$09,$06 ; $03
	db $10,$F9,$08 ; $04
	db $10,$01,$0A ; $05
		
OBJLstHdrB_Krauser_GuardBreakG0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L156C00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_Krauser_HitSwoopup2B.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Krauser_HitSwoopup1B:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	dpr L156C00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_Krauser_HitSwoopup2B.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Krauser_HitSwoopup2B:
	db OLF_YFLIP ; iOBJLstHdrA_Flags
	dpr L156C00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$F2,$00 ; $00
	db $30,$FA,$02 ; $01
	db $30,$02,$04 ; $02
		
OBJLstHdrB_Krauser_ThrowEndA3B:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	dpr L156C00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_Krauser_HitSwoopup2B.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Krauser_TimeOver2A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L156C60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Krauser_HitSwoopup2A.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Krauser_HitSwoopup1A:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L156C60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Krauser_HitSwoopup2A.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Krauser_HitSwoopup2A:
	db OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L156C60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $20,$FB,$00 ; $00
	db $20,$03,$02 ; $01
	db $10,$FF,$04 ; $02
	db $1C,$F7,$06 ; $03
	db $1B,$EF,$08 ; $04
		
OBJLstHdrA_Krauser_ThrowEndA3A:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L156C60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Krauser_HitSwoopup2A.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Krauser_RollF3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L156D00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1C,$ED,$00 ; $00
	db $27,$F5,$02 ; $01
	db $22,$FD,$04 ; $02
	db $23,$05,$06 ; $03
	db $37,$F5,$08 ; $04
	db $32,$FD,$0A ; $05
	db $33,$05,$0C ; $06
		
OBJLstHdrA_Krauser_RollF2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L156DE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Krauser_KaiserSuplexL7.bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $09 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Krauser_KaiserSuplexL7:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L156DE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $1B,$EB,$00 ; $00
	db $24,$F3,$02 ; $01
	db $1E,$FC,$04 ; $02
	db $1E,$04,$06 ; $03
	db $2A,$09,$08 ; $04
	db $30,$EB,$0A ; $05
	db $34,$F3,$0C ; $06
	db $29,$FB,$0E ; $07
	db $2E,$01,$10 ; $08
		
OBJLstHdrA_Krauser_RollF0:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L156DE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Krauser_KaiserSuplexL7.bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $FE ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Krauser_ThrowRotL0:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L156DE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Krauser_KaiserSuplexL7.bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Krauser_DropMain2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L156F00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $01 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $32,$EC,$00 ; $00
	db $2D,$F4,$02 ; $01
	db $33,$FC,$04 ; $02
	db $33,$04,$06 ; $03
	db $2E,$0C,$08 ; $04
	db $3A,$E4,$0A ; $05
	db $3D,$F4,$0C ; $06
		
OBJLstHdrA_Krauser_ThrowG1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L156FE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $09 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $18,$EE,$00 ; $00
	db $18,$F6,$02 ; $01
	db $08,$EE,$04 ; $02
	db $08,$F6,$06 ; $03
	db $12,$FE,$08 ; $04
	db $FF,$FE,$0A ; $05
		
OBJLstHdrA_Krauser_ThrowG2A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L156FE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Krauser_ThrowG1A.bin ; iOBJLstHdrA_DataPtr
	db $09 ; iOBJLstHdrA_XOffset
	db $FF ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Krauser_ChargeMeter0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1570A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $09 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $28,$F1,$00 ; $00
	db $28,$F9,$02 ; $01
	db $38,$F1,$04 ; $02
	db $38,$F9,$06 ; $03
		
OBJLstHdrB_Krauser_ThrowG2B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L157120 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $09 ; iOBJLstHdrA_XOffset
	db $FF ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $28,$F1,$00 ; $00
	db $28,$F9,$02 ; $01
	db $38,$F1,$04 ; $02
	db $38,$F9,$06 ; $03
		
OBJLstHdrA_Krauser_HighBlitzBallL0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1571A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $03 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $1E,$F3,$00 ; $00
	db $1A,$F9,$02 ; $01
	db $1A,$01,$04 ; $02
	db $13,$09,$06 ; $03
	db $32,$EF,$08 ; $04
	db $2A,$F7,$0A ; $05
	db $2A,$FF,$0C ; $06
	db $30,$03,$0E ; $07
		
OBJLstHdrA_Krauser_HighBlitzBallL1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1572A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $18,$F1,$00 ; $00
	db $20,$F9,$02 ; $01
	db $20,$01,$04 ; $02
	db $10,$F9,$06 ; $03
	db $10,$01,$08 ; $04
	db $18,$09,$0A ; $05
		
OBJLstHdrA_Krauser_LegTomahawkL1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L157360 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $06 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $19,$EC,$00 ; $00
	db $1D,$F4,$02 ; $01
	db $1D,$FC,$04 ; $02
	db $18,$04,$06 ; $03
	db $0D,$F4,$08 ; $04
	db $0D,$FC,$0A ; $05
	db $08,$04,$0C ; $06
		
OBJLstHdrB_Krauser_LegTomahawkL1B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L157440 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $06 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $28,$03,$00 ; $00
	db $20,$0B,$02 ; $01
	db $30,$0B,$04 ; $02
	db $30,$13,$06 ; $03
		
OBJLstHdrA_Krauser_LegTomahawkL2A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L1574C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $06 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $18,$EB,$00 ; $00
	db $1D,$F3,$02 ; $01
	db $1D,$FB,$04 ; $02
	db $18,$03,$06 ; $03
	db $0D,$F3,$08 ; $04
	db $0D,$FB,$0A ; $05
	db $08,$EB,$0C ; $06
		
OBJLstHdrA_Krauser_LegTomahawkL3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L1575A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $05 ; iOBJLstHdrA_YOffset
.bin:
	db $0A ; OBJ Count
	;    Y   X  ID
	db $17,$ED,$00 ; $00
	db $17,$F5,$02 ; $01
	db $17,$FD,$04 ; $02
	db $17,$05,$06 ; $03
	db $26,$06,$08 ; $04
	db $2F,$E6,$0A ; $05
	db $27,$EE,$0C ; $06
	db $27,$F6,$0E ; $07
	db $27,$FE,$10 ; $08
	db $36,$06,$12 ; $09
		
OBJLstHdrA_Krauser_LegTomahawkL4A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L1576E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $0F ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $20,$EB,$00 ; $00
	db $20,$F3,$02 ; $01
	db $1B,$FB,$04 ; $02
		
OBJLstHdrB_Krauser_LegTomahawkL4B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L157740 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $0F ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $23,$E6,$00 ; $00
	db $33,$E6,$02 ; $01
	db $30,$EE,$04 ; $02
	db $30,$F6,$06 ; $03
	db $22,$DE,$08 ; $04
	db $39,$FE,$0A ; $05
		
OBJLstHdrA_Krauser_LegTomahawkL5A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L157800 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $0F ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $20,$EB,$00 ; $00
	db $20,$F3,$02 ; $01
	db $1B,$FB,$04 ; $02
		
OBJLstHdrA_Krauser_KaiserSuplexL3A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L157860 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $10 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $0B,$F3,$00 ; $00
	db $0E,$FB,$02 ; $01
	db $16,$03,$04 ; $02
	db $1B,$F3,$06 ; $03
	db $1E,$FB,$08 ; $04
	db $29,$03,$0A ; $05
	db $28,$0B,$0C ; $06
	db $0B,$EB,$0E ; $07
		
OBJLstHdrA_Krauser_KaiserWaveS1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L157960 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $18,$F4,$00 ; $00
	db $18,$FC,$02 ; $01
	db $17,$04,$04 ; $02
	db $13,$0C,$06 ; $03
	db $08,$FC,$08 ; $04
		
OBJLstHdrA_Krauser_KaiserWaveS2A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L157A00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $18,$F7,$00 ; $00
	db $18,$FF,$02 ; $01
	db $15,$07,$04 ; $02
	db $13,$0F,$06 ; $03
	db $08,$FD,$08 ; $04
		
OBJLstHdrA_Krauser_KaiserWaveS3A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L157AA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $18,$FB,$00 ; $00
	db $10,$03,$02 ; $01
		
OBJLstHdrB_Krauser_KaiserWaveS3B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L157AE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $19,$E3,$00 ; $00
	db $1E,$EB,$02 ; $01
	db $1B,$F3,$04 ; $02
	db $2E,$F2,$06 ; $03
	db $28,$FA,$08 ; $04
	db $28,$02,$0A ; $05
	db $38,$FB,$0C ; $06
	db $3E,$F1,$0E ; $07
	db $38,$03,$10 ; $08
		
OBJLstHdrA_Krauser_KaiserWaveS4A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L157C00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $01 ; OBJ Count
	;    Y   X  ID
	db $18,$FB,$00 ; $00
		

OBJLstPtrTable_Mature_Idle:
	dw OBJLstHdrA_Mature_Idle0A, OBJLstHdrB_Mature_Idle0B
	dw OBJLstHdrA_Mature_Idle1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_Idle2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_WalkF:
	dw OBJLstHdrA_Mature_WalkF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_WalkF1A, OBJLstHdrB_Mature_WalkF1B
	dw OBJLstHdrA_Mature_WalkF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_WalkF3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_WalkF1A, OBJLstHdrB_Mature_WalkF4B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_WalkB:
	dw OBJLstHdrA_Mature_WalkF1A, OBJLstHdrB_Mature_WalkF4B
	dw OBJLstHdrA_Mature_WalkF3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_WalkF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_WalkF1A, OBJLstHdrB_Mature_WalkF1B
	dw OBJLstHdrA_Mature_WalkF0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_Crouch:
	dw OBJLstHdrA_Mature_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_JumpN:
	dw OBJLstHdrA_Mature_Crouch0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_JumpN2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_JumpN3A, OBJLstHdrB_Mature_JumpN3B
	dw OBJLstHdrA_Mature_JumpN3A, OBJLstHdrB_Mature_JumpN3B
	dw OBJLstHdrA_Mature_JumpN2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_BlockG:
	dw OBJLstHdrA_Mature_BlockG0A, OBJLstHdrB_Mature_BlockG0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_BlockC:
	dw OBJLstHdrA_Mature_BlockC0A, OBJLstHdrB_Mature_BlockC0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_BlockA:
	dw OBJLstHdrA_Mature_BlockA0A, OBJLstHdrB_Mature_JumpN3B ;X
	dw OBJLstHdrA_Mature_Crouch0, OBJLSTPTR_NONE ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_RunF:
	dw OBJLstHdrA_Mature_RunF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_RunF1, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_HopB:
	dw OBJLstHdrA_Mature_HopB0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_HopB0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_ChargeMeter:
	dw OBJLstHdrA_Mature_ChargeMeter0A, OBJLstHdrB_Mature_Idle0B
	dw OBJLstHdrA_Mature_ChargeMeter1A, OBJLstHdrB_Mature_Idle0B
	dw OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE;X

OBJLstPtrTable_Mature_Taunt:
	dw OBJLstHdrA_Mature_Taunt0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_Taunt1, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_Intro:
	dw OBJLstHdrA_Mature_Intro0A, OBJLstHdrB_Mature_Intro0B
	dw OBJLstHdrA_Mature_Intro1A, OBJLstHdrB_Mature_Intro0B
	dw OBJLstHdrA_Mature_Intro2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_Intro1A, OBJLstHdrB_Mature_Intro0B
	dw OBJLstHdrA_Mature_Intro4A, OBJLstHdrB_Mature_Intro0B
	dw OBJLstHdrA_Mature_Intro0A, OBJLstHdrB_Mature_Intro0B
	dw OBJLstHdrA_Mature_WalkF0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_WinA:
	dw OBJLstHdrA_Mature_WalkF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_WinA1, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_WinB:
	dw OBJLstHdrA_Mature_WinB0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_WinB1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_WinB2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_PunchL:
	dw OBJLstHdrA_Mature_PunchL0A, OBJLstHdrB_Mature_PunchL0B
	dw OBJLstHdrA_Mature_PunchL1A, OBJLstHdrB_Mature_PunchL1B
	dw OBJLstHdrA_Mature_PunchL0A, OBJLstHdrB_Mature_PunchL0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_PunchH:
	dw OBJLstHdrA_Mature_PunchH0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_PunchH1A, OBJLstHdrB_Mature_PunchH1B
	dw OBJLstHdrA_Mature_PunchH2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_PunchH3A, OBJLstHdrB_Mature_PunchH3B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_KickL:
	dw OBJLstHdrA_Mature_KickL0A, OBJLstHdrB_Mature_KickL0B
	dw OBJLstHdrA_Mature_KickL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_KickL2A, OBJLstHdrB_Mature_KickL2B
	dw OBJLstHdrA_Mature_KickL1, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_KickH:
	dw OBJLstHdrA_Mature_Crouch0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_KickH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_KickH2A, OBJLstHdrB_Mature_KickH2B
	dw OBJLstHdrA_Mature_KickH3, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_PunchCL:
	dw OBJLstHdrA_Mature_PunchCL0A, OBJLstHdrB_Mature_PunchCL0B
	dw OBJLstHdrA_Mature_PunchCL1A, OBJLstHdrB_Mature_PunchCL1B
	dw OBJLstHdrA_Mature_PunchCL0A, OBJLstHdrB_Mature_PunchCL0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_PunchCH:
	dw OBJLstHdrA_Mature_Crouch0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_PunchCH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_PunchCH2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_KickCL:
	dw OBJLstHdrA_Mature_KickCL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_KickCL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_KickCL0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_KickCH:
	dw OBJLstHdrA_Mature_WalkF1A, OBJLstHdrB_Mature_WalkF4B
	dw OBJLstHdrA_Mature_KickCH1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_KickCH2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_WalkF1A, OBJLstHdrB_Mature_WalkF4B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_PunchA:
	dw OBJLstHdrA_Mature_PunchA0A, OBJLstHdrB_Mature_PunchA0B
	dw OBJLstHdrA_Mature_PunchA0A, OBJLstHdrB_Mature_PunchA0B
	dw OBJLstHdrA_Mature_JumpN2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_KickA:
	dw OBJLstHdrA_Mature_KickL0A, OBJLstHdrB_Mature_KickA0B
	dw OBJLstHdrA_Mature_KickL0A, OBJLstHdrB_Mature_KickA1B
	dw OBJLstHdrA_Mature_JumpN2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_JumpN1, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Mature_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_AttackA:
	dw OBJLstHdrA_Mature_AttackA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_AttackA1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_AttackA2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_JumpN1, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Mature_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_AttackG:
	dw OBJLstHdrA_Mature_AttackG0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_AttackG1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_AttackA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_WalkF0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_RollF:
	dw OBJLstHdrA_Mature_RollF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_RollF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_RollF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_RollF3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_RollB:
	dw OBJLstHdrA_Mature_RollF3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_RollF2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_RollF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_RollF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_GuardBreakG:
	dw OBJLstHdrA_Mature_GuardBreakG0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_Dizzy:
	dw OBJLstHdrA_Mature_Idle0A, OBJLstHdrB_Mature_Idle0B
	dw OBJLstHdrA_Mature_GuardBreakG0, OBJLSTPTR_NONE
OBJLstPtrTable_Mature_TimeOver:
	dw OBJLstHdrA_Mature_TimeOver2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_Hitlow:
	dw OBJLstHdrA_Mature_Hitlow0, OBJLSTPTR_NONE ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_GuardBreakA:
	dw OBJLstHdrA_Mature_GuardBreakG0, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_Mature_Crouch0, OBJLSTPTR_NONE ;X
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_BackjumpRecA:
	dw OBJLstHdrA_Mature_GuardBreakG0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_JumpN3A, OBJLstHdrB_Mature_JumpN3B
	dw OBJLstHdrA_Mature_JumpN2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_JumpN3A, OBJLstHdrB_Mature_JumpN3B
	dw OBJLstHdrA_Mature_JumpN2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_JumpN1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_DropMain:
	dw OBJLstHdrA_Mature_GuardBreakG0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_DropMain2, OBJLSTPTR_NONE
OBJLstPtrTable_Mature_HitMultigs:
	dw OBJLstHdrA_Mature_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_DropMain2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_HitSwoopup:
	dw OBJLstHdrA_Mature_TimeOver2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_AttackG0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_HitSwoopup2, OBJLSTPTR_NONE
OBJLstPtrTable_Mature_ThrowEndA:
	dw OBJLstHdrA_Mature_ThrowEndA3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_ThrowEndA3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_DropMain2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_DropDbg:
	dw OBJLstHdrA_Mature_TimeOver2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_DropMain1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_DropMain2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_ThrowRotL:
	dw OBJLstHdrA_Mature_ThrowRotL0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_Wakeup:
	dw OBJLstHdrA_Mature_Crouch0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_DecideL:
	dw OBJLstHdrA_Mature_PunchH2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_DecideL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_DecideL2A, OBJLstHdrB_Mature_PunchH3B
	dw OBJLstHdrA_Mature_DecideL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_DecideL4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_DecideL5A, OBJLstHdrB_Mature_DecideL5B
	dw OBJLstHdrA_Mature_DecideL6A, OBJLstHdrB_Mature_DecideL5B
	dw OBJLstHdrA_Mature_DecideL7, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_MetalMassacreL:
	dw OBJLstHdrA_Mature_RunF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_RunF1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_RunF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_WalkF0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_PunchH2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_MetalMassacreL5A, OBJLstHdrB_Mature_PunchH3B
	dw OBJLstHdrA_Mature_MetalMassacreL6A, OBJLstHdrB_Mature_PunchH3B
	dw OBJLstHdrA_Mature_MetalMassacreL5A, OBJLstHdrB_Mature_PunchH3B
	dw OBJLstHdrA_Mature_DecideL2A, OBJLstHdrB_Mature_PunchH3B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_DeathRowL:
	dw OBJLstHdrA_Mature_DeathRowL0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_DeathRowL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_DeathRowL2A, OBJLstHdrB_Mature_DeathRowL2B
	dw OBJLstHdrA_Mature_DecideL2A, OBJLstHdrB_Mature_PunchH3B
	dw OBJLstHdrA_Mature_DeathRowL4A, OBJLstHdrB_Mature_PunchH1B
	dw OBJLstHdrA_Mature_DeathRowL5A, OBJLstHdrB_Mature_PunchH1B
	dw OBJLstHdrA_Mature_PunchH2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_MetalMassacreL5A, OBJLstHdrB_Mature_PunchH3B
	dw OBJLstHdrA_Mature_MetalMassacreL6A, OBJLstHdrB_Mature_PunchH3B
	dw OBJLstHdrA_Mature_DecideL2A, OBJLstHdrB_Mature_PunchH3B
	dw OBJLstHdrA_Mature_PunchL0A, OBJLstHdrB_Mature_PunchL0B
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_DespairL:
	dw OBJLstHdrA_Mature_Crouch0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_DespairL1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_DespairL2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_DespairL3A, OBJLstHdrB_Mature_KickH2B
	dw OBJLstHdrA_Mature_KickH3, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_DespairL5, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_Crouch0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_HeavensGateS:
	dw OBJLstHdrA_Mature_HeavensGateS0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_HeavensGateS1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_HeavensGateS2, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_HeavensGateS1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_HeavensGateS4, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_HeavensGateS5, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_WalkF0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		

OBJLstPtrTable_Mature_ThrowG:
	dw OBJLstHdrA_Mature_ThrowG0, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_ThrowG1, OBJLSTPTR_NONE
	dw OBJLstHdrA_Mature_ThrowG2, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		
OBJLstHdrA_Mature_Idle0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L184000 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $20,$F3,$00 ; $00
	db $28,$FB,$02 ; $01
	db $28,$03,$04 ; $02
	db $18,$FB,$06 ; $03
	db $18,$03,$08 ; $04
		
OBJLstHdrB_Mature_Idle0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1840A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $38,$F4,$00 ; $00
	db $38,$FC,$02 ; $01
	db $38,$04,$04 ; $02
		
OBJLstHdrA_Mature_Idle1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L184100 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $2A,$F4,$00 ; $00
	db $22,$FC,$02 ; $01
	db $23,$04,$04 ; $02
	db $32,$FC,$06 ; $03
	db $33,$04,$08 ; $04
	db $3C,$F4,$0A ; $05
		
OBJLstHdrA_Mature_Idle2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1841C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $28,$F4,$00 ; $00
	db $21,$FC,$02 ; $01
	db $22,$04,$04 ; $02
	db $31,$FC,$06 ; $03
	db $32,$04,$08 ; $04
	db $3B,$F4,$0A ; $05
		
OBJLstHdrA_Mature_WalkF0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L184280 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $1F,$F4,$00 ; $00
	db $20,$FC,$02 ; $01
	db $2F,$F4,$04 ; $02
	db $30,$FC,$06 ; $03
	db $3F,$F4,$08 ; $04
		
OBJLstHdrA_Mature_DecideL7:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L184280 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mature_WalkF0.bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mature_WalkF1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L184320 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $20,$F4,$00 ; $00
	db $20,$FC,$02 ; $01
	db $10,$F4,$04 ; $02
		
OBJLstHdrB_Mature_WalkF1B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L184380 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $30,$F4,$00 ; $00
	db $30,$FC,$02 ; $01
		
OBJLstHdrA_Mature_WalkF2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1843C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $1F,$F4,$00 ; $00
	db $20,$FC,$02 ; $01
	db $2F,$F4,$04 ; $02
	db $30,$FC,$06 ; $03
	db $3E,$EE,$08 ; $04
		
OBJLstHdrA_Mature_WalkF3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L184460 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $1E,$F4,$00 ; $00
	db $20,$F9,$02 ; $01
	db $30,$F4,$04 ; $02
	db $30,$FC,$06 ; $03
		
OBJLstHdrB_Mature_WalkF4B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1844E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $30,$F4,$00 ; $00
	db $30,$FC,$02 ; $01
		
OBJLstHdrA_Mature_Crouch0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L184520 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $26,$FC,$00 ; $00
	db $27,$04,$02 ; $01
	db $36,$FC,$04 ; $02
	db $37,$04,$06 ; $03
	db $37,$0C,$08 ; $04
		
OBJLstHdrA_Mature_BlockG0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1849C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $20,$FE,$00 ; $00
	db $20,$06,$02 ; $01
		
OBJLstHdrA_Mature_BlockC0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1849C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mature_BlockG0A.bin ; iOBJLstHdrA_DataPtr
	db $FD ; iOBJLstHdrA_XOffset
	db $03 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Mature_BlockG0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L184A00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $3C,$F4,$00 ; $00
	db $30,$FC,$02 ; $01
	db $30,$04,$04 ; $02
		
OBJLstHdrB_Mature_BlockC0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L184A60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $3B,$F4,$00 ; $00
	db $30,$FC,$02 ; $01
	db $30,$04,$04 ; $02
		
OBJLstHdrA_Mature_BlockA0A: ;X
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L184AC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FB ; iOBJLstHdrA_XOffset
	db $14 ; iOBJLstHdrA_YOffset
.bin: ;X
	db $03 ; OBJ Count
	;    Y   X  ID
	db $08,$F4,$00 ; $00
	db $00,$FC,$02 ; $01
	db $10,$FC,$04 ; $02
		
OBJLstHdrA_Mature_JumpN1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L184740 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $06 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $20,$F4,$00 ; $00
	db $19,$FC,$02 ; $01
	db $18,$04,$04 ; $02
	db $29,$FC,$06 ; $03
	db $28,$04,$08 ; $04
	db $22,$0C,$0A ; $05
	db $38,$04,$0C ; $06
		
OBJLstHdrA_Mature_JumpN2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L184820 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $0B ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $0C,$FB,$00 ; $00
	db $0C,$03,$02 ; $01
	db $1C,$FC,$04 ; $02
	db $1C,$04,$06 ; $03
	db $2C,$FC,$08 ; $04
	db $2C,$04,$0A ; $05
		
OBJLstHdrA_Mature_JumpN3A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1848E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FB ; iOBJLstHdrA_XOffset
	db $14 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $00,$FC,$00 ; $00
	db $0E,$F4,$02 ; $01
	db $10,$FC,$04 ; $02
		
OBJLstHdrB_Mature_JumpN3B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L184940 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FB ; iOBJLstHdrA_XOffset
	db $14 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $20,$FC,$00 ; $00
	db $09,$04,$02 ; $01
	db $19,$04,$04 ; $02
	db $12,$0C,$06 ; $03
		
OBJLstHdrA_Mature_ChargeMeter0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1861A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $28,$FC,$00 ; $00
	db $28,$04,$02 ; $01
	db $18,$FC,$04 ; $02
	db $18,$04,$06 ; $03
		
OBJLstHdrA_Mature_ChargeMeter1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L186220 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $28,$FC,$00 ; $00
	db $28,$04,$02 ; $01
	db $18,$FC,$04 ; $02
	db $18,$04,$06 ; $03
		
OBJLstHdrA_Mature_Taunt0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1864E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1C,$00,$00 ; $00
	db $1C,$08,$02 ; $01
	db $25,$F9,$04 ; $02
	db $2C,$01,$06 ; $03
	db $2C,$09,$08 ; $04
	db $35,$00,$0A ; $05
		
OBJLstHdrA_Mature_Taunt1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1865A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $1E,$FC,$00 ; $00
	db $1D,$04,$02 ; $01
	db $2D,$F4,$04 ; $02
	db $2E,$FC,$06 ; $03
	db $2D,$04,$08 ; $04
	db $2A,$0C,$0A ; $05
	db $3D,$01,$0C ; $06
		
OBJLstHdrA_Mature_WinA1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L186680 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $1F,$FC,$00 ; $00
	db $1E,$04,$02 ; $01
	db $2F,$FC,$04 ; $02
	db $2E,$04,$06 ; $03
	db $3E,$00,$08 ; $04
		
OBJLstHdrA_Mature_WinB0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L186720 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1E,$F6,$00 ; $00
	db $1E,$FE,$02 ; $01
	db $20,$04,$04 ; $02
	db $2E,$FC,$06 ; $03
	db $30,$04,$08 ; $04
	db $3E,$FA,$0A ; $05
		
OBJLstHdrA_Mature_WinB1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1867E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FF ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $20,$FA,$00 ; $00
	db $1E,$02,$02 ; $01
	db $30,$FA,$04 ; $02
	db $2E,$02,$06 ; $03
	db $3E,$02,$08 ; $04
		
OBJLstHdrA_Mature_WinB2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L186880 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $01 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $1F,$FC,$00 ; $00
	db $1E,$04,$02 ; $01
	db $2F,$FC,$04 ; $02
	db $2E,$04,$06 ; $03
	db $3E,$00,$08 ; $04
		
OBJLstHdrA_Mature_Intro0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1862A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $27,$EC,$00 ; $00
	db $28,$F4,$02 ; $01
	db $28,$FC,$04 ; $02
		
OBJLstHdrB_Mature_Intro0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L186300 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $18,$FC,$00 ; $00
	db $20,$04,$02 ; $01
	db $39,$F4,$04 ; $02
	db $30,$FC,$06 ; $03
	db $30,$04,$08 ; $04
		
OBJLstHdrA_Mature_Intro1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1863A0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $20,$F4,$00 ; $00
	db $28,$FC,$02 ; $01
		
OBJLstHdrA_Mature_Intro2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1863E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $20,$FA,$00 ; $00
	db $20,$02,$02 ; $01
	db $3D,$F2,$04 ; $02
	db $30,$FA,$06 ; $03
	db $30,$02,$08 ; $04
		
OBJLstHdrA_Mature_Intro4A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L186480 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $27,$EC,$00 ; $00
	db $28,$F4,$02 ; $01
	db $28,$FC,$04 ; $02
		
OBJLstHdrA_Mature_PunchL1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L184B20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $27,$EC,$00 ; $00
	db $1C,$F4,$02 ; $01
	db $20,$FC,$04 ; $02
	db $20,$04,$06 ; $03
	db $10,$FC,$08 ; $04
		
OBJLstHdrA_Mature_PunchCL1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L184B20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mature_PunchL1A.bin ; iOBJLstHdrA_DataPtr
	db $FB ; iOBJLstHdrA_XOffset
	db $06 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mature_DecideL6A:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L184B20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mature_PunchL1A.bin ; iOBJLstHdrA_DataPtr
	db $08 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Mature_PunchL1B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L184BC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $30,$00,$00 ; $00
	db $30,$08,$02 ; $01
		
OBJLstHdrB_Mature_DecideL5B:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	dpr L184BC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrB_Mature_PunchL1B.bin ; iOBJLstHdrA_DataPtr
	db $08 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mature_PunchL0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L184C00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $20,$FD,$00 ; $00
	db $20,$05,$02 ; $01
	db $1F,$0D,$04 ; $02
		
OBJLstHdrA_Mature_PunchCL0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L184C00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mature_PunchL0A.bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $06 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Mature_PunchL0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L184C60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$FC,$00 ; $00
	db $30,$04,$02 ; $01
	db $37,$0C,$04 ; $02
		
OBJLstHdrA_Mature_PunchH0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L184CC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mature_ThrowG1.bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mature_ThrowG1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L184CC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1C,$03,$00 ; $00
	db $16,$0B,$02 ; $01
	db $26,$0B,$04 ; $02
	db $2C,$03,$06 ; $03
	db $36,$0B,$08 ; $04
	db $3C,$03,$0A ; $05
		
OBJLstHdrA_Mature_DecideL4:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L184CC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mature_ThrowG1.bin ; iOBJLstHdrA_DataPtr
	db $08 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrB_Mature_DeathRowL2B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L184CC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mature_ThrowG1.bin ; iOBJLstHdrA_DataPtr
	db $F7 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mature_PunchH1A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L184D80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F6 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $2A,$F4,$00 ; $00
	db $30,$FC,$02 ; $01
	db $20,$FB,$04 ; $02
	db $20,$03,$06 ; $03
		
OBJLstHdrB_Mature_PunchH1B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L184E00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F6 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $30,$04,$00 ; $00
	db $37,$0C,$02 ; $01
	db $3E,$14,$04 ; $02
		
OBJLstHdrA_Mature_PunchH2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L184E60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FD ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $22,$FC,$00 ; $00
	db $22,$04,$02 ; $01
	db $37,$F4,$04 ; $02
	db $32,$FC,$06 ; $03
	db $32,$04,$08 ; $04
	db $3A,$0C,$0A ; $05
		
OBJLstHdrA_Mature_PunchH3A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L184F20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mature_PunchA0A.bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mature_DecideL2A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L184F20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mature_PunchA0A.bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mature_PunchA0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L184F20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FF ; iOBJLstHdrA_XOffset
	db $F5 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $28,$F3,$00 ; $00
	db $28,$FB,$02 ; $01
	db $28,$03,$04 ; $02
	db $18,$FB,$06 ; $03
	db $18,$03,$08 ; $04
		
OBJLstHdrB_Mature_PunchH3B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L184FC0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FA ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $38,$FB,$00 ; $00
	db $38,$03,$02 ; $01
	db $38,$0B,$04 ; $02
		
OBJLstHdrA_Mature_KickL0A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_6C ; iOBJLstHdrA_HitboxId
	dpr L185020 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $30,$F4,$00 ; $00
	db $28,$FC,$02 ; $01
	db $20,$04,$04 ; $02
	db $18,$FC,$06 ; $03
	db $10,$04,$08 ; $04
		
OBJLstHdrB_Mature_KickL0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1850C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $38,$FC,$00 ; $00
	db $30,$04,$02 ; $01
		
OBJLstHdrA_Mature_KickL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L185100 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1D,$FF,$00 ; $00
	db $1D,$07,$02 ; $01
	db $2D,$FF,$04 ; $02
	db $2D,$07,$06 ; $03
	db $25,$F7,$08 ; $04
	db $3D,$07,$0A ; $05
		
OBJLstHdrA_Mature_KickL2A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_55 ; iOBJLstHdrA_HitboxId
	dpr L1851C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $26,$F2,$00 ; $00
	db $28,$FA,$02 ; $01
	db $28,$02,$04 ; $02
	db $18,$FB,$06 ; $03
	db $18,$03,$08 ; $04
	db $1D,$0A,$0A ; $05
		
OBJLstHdrB_Mature_KickL2B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L185280 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $38,$FC,$00 ; $00
	db $30,$04,$02 ; $01
		
OBJLstHdrA_Mature_KickH1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L1852C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $29,$EC,$00 ; $00
	db $2B,$F4,$02 ; $01
	db $2C,$FC,$04 ; $02
	db $31,$04,$06 ; $03
	db $31,$0C,$08 ; $04
		
OBJLstHdrA_Mature_KickH2A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L185360 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $2B,$EC,$00 ; $00
	db $2A,$F4,$02 ; $01
	db $3A,$F4,$04 ; $02
		
OBJLstHdrB_Mature_KickH2B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L1853C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $2A,$FC,$00 ; $00
	db $32,$04,$02 ; $01
	db $3B,$0C,$04 ; $02
	db $3A,$FC,$06 ; $03
		
OBJLstHdrA_Mature_KickH3:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L185440 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $2D,$F4,$00 ; $00
	db $2D,$FC,$02 ; $01
	db $30,$09,$04 ; $02
	db $3D,$F9,$06 ; $03
	db $3D,$01,$08 ; $04
	db $3B,$11,$0A ; $05
	db $2D,$04,$0C ; $06
		
OBJLstHdrB_Mature_PunchCL1B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L185520 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $36,$F9,$00 ; $00
	db $36,$01,$02 ; $01
	db $3C,$09,$04 ; $02
		
OBJLstHdrB_Mature_PunchCL0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L185580 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $36,$F8,$00 ; $00
	db $36,$00,$02 ; $01
	db $3C,$08,$04 ; $02
		
OBJLstHdrA_Mature_PunchCH1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_4D ; iOBJLstHdrA_HitboxId
	dpr L1855E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $30,$E8,$00 ; $00
	db $2D,$F0,$02 ; $01
	db $2E,$F8,$04 ; $02
	db $30,$00,$06 ; $03
	db $3A,$08,$08 ; $04
	db $3E,$F8,$0A ; $05
	db $3E,$F0,$0C ; $06
		
OBJLstHdrA_Mature_PunchCH2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1856C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $27,$EC,$00 ; $00
	db $27,$F4,$02 ; $01
	db $37,$FE,$04 ; $02
	db $3B,$06,$06 ; $03
	db $37,$EE,$08 ; $04
	db $37,$F6,$0A ; $05
		
OBJLstHdrA_Mature_KickCL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_4C ; iOBJLstHdrA_HitboxId
	dpr L185780 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $3C,$EC,$00 ; $00
	db $38,$F4,$02 ; $01
	db $34,$FC,$04 ; $02
	db $2D,$04,$06 ; $03
	db $2E,$0C,$08 ; $04
	db $3D,$04,$0A ; $05
	db $3E,$0C,$0C ; $06
		
OBJLstHdrA_Mature_KickCL0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L185860 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mature_DespairL5.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mature_DespairL5:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L185860 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $3C,$EF,$00 ; $00
	db $34,$F7,$02 ; $01
	db $29,$FC,$04 ; $02
	db $2A,$04,$06 ; $03
	db $39,$FF,$08 ; $04
		
OBJLstHdrA_Mature_KickCH1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_6D ; iOBJLstHdrA_HitboxId
	dpr L185900 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1C,$F4,$00 ; $00
	db $1A,$FC,$02 ; $01
	db $23,$04,$04 ; $02
	db $2C,$F4,$06 ; $03
	db $2A,$FC,$08 ; $04
	db $3A,$FC,$0A ; $05
		
OBJLstHdrA_Mature_KickCH2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_4A ; iOBJLstHdrA_HitboxId
	dpr L1859C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F5 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $31,$EE,$00 ; $00
	db $2C,$F6,$02 ; $01
	db $1F,$FE,$04 ; $02
	db $20,$06,$06 ; $03
	db $23,$0E,$08 ; $04
	db $2F,$FE,$0A ; $05
	db $30,$06,$0C ; $06
		
OBJLstHdrB_Mature_PunchA0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L185AA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FF ; iOBJLstHdrA_XOffset
	db $05 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $28,$FA,$00 ; $00
	db $28,$02,$02 ; $01
	db $28,$0A,$04 ; $02
		
OBJLstHdrB_Mature_KickA0B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L185B00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $10 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $28,$FC,$00 ; $00
	db $20,$04,$02 ; $01
	db $24,$0C,$04 ; $02
		
OBJLstHdrB_Mature_KickA1B:
	db $00 ; iOBJLstHdrA_Flags
	dpr L185B60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $28,$01,$00 ; $00
	db $28,$09,$02 ; $01
		
OBJLstHdrA_Mature_AttackG1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_6E ; iOBJLstHdrA_HitboxId
	dpr L185BA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $25,$E4,$00 ; $00
	db $27,$EC,$02 ; $01
	db $2A,$F4,$04 ; $02
	db $2C,$FC,$06 ; $03
	db $2F,$04,$08 ; $04
	db $3A,$F4,$0A ; $05
	db $3C,$FC,$0C ; $06
		
OBJLstHdrA_Mature_AttackA0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L185C80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $2D,$EC,$00 ; $00
	db $27,$F4,$02 ; $01
	db $27,$FC,$04 ; $02
	db $25,$04,$06 ; $03
	db $37,$F4,$08 ; $04
	db $37,$FC,$0A ; $05
		
OBJLstHdrA_Mature_DespairL1:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L185C80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mature_AttackA0.bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mature_AttackA2:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L185C80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mature_AttackA0.bin ; iOBJLstHdrA_DataPtr
	db $FB ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mature_AttackA1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L185D40 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $18,$F4,$00 ; $00
	db $10,$FC,$02 ; $01
	db $14,$04,$04 ; $02
	db $28,$F4,$06 ; $03
	db $20,$FC,$08 ; $04
	db $24,$04,$0A ; $05
	db $30,$FC,$0C ; $06
		
OBJLstHdrA_Mature_RollF1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1845C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F4 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $27,$FC,$00 ; $00
	db $27,$04,$02 ; $01
	db $2B,$0C,$04 ; $02
	db $32,$14,$06 ; $03
	db $37,$FE,$08 ; $04
	db $37,$08,$0A ; $05
		
OBJLstHdrA_Mature_RollF3:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1845C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mature_RollF1.bin ; iOBJLstHdrA_DataPtr
	db $0C ; iOBJLstHdrA_XOffset
	db $0B ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mature_RollF2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L184680 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $25,$F4,$00 ; $00
	db $24,$FC,$02 ; $01
	db $28,$04,$04 ; $02
	db $35,$F4,$06 ; $03
	db $34,$FC,$08 ; $04
	db $38,$04,$0A ; $05
		
OBJLstHdrA_Mature_RollF0:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L184680 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mature_RollF2.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $05 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mature_TimeOver2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L185E20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $27,$F4,$00 ; $00
	db $24,$FC,$02 ; $01
	db $25,$04,$04 ; $02
	db $34,$FC,$06 ; $03
	db $35,$04,$08 ; $04
	db $3C,$F4,$0A ; $05
		
OBJLstHdrA_Mature_AttackG0:
	db OLF_XFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L185E20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mature_TimeOver2.bin ; iOBJLstHdrA_DataPtr
	db $04 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mature_HitSwoopup2:
	db OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L185E20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mature_TimeOver2.bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $05 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mature_ThrowEndA3:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L185E20 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mature_TimeOver2.bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $05 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mature_GuardBreakG0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L185EE0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FE ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $29,$F5,$00 ; $00
	db $24,$FD,$02 ; $01
	db $22,$05,$04 ; $02
	db $39,$F5,$06 ; $03
	db $34,$FD,$08 ; $04
	db $32,$05,$0A ; $05
		
OBJLstHdrA_Mature_Hitlow0: ;X
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L185FA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin: ;X
	db $06 ; OBJ Count
	;    Y   X  ID
	db $3C,$F6,$00 ; $00
	db $31,$FE,$02 ; $01
	db $26,$06,$04 ; $02
	db $26,$0E,$06 ; $03
	db $36,$06,$08 ; $04
	db $36,$0E,$0A ; $05
		
OBJLstHdrA_Mature_DropMain1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L186060 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $02 ; iOBJLstHdrA_XOffset
	db $23 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $10,$EC,$00 ; $00
	db $10,$F4,$02 ; $01
	db $10,$FC,$04 ; $02
	db $11,$04,$06 ; $03
	db $14,$0C,$08 ; $04
		
OBJLstHdrA_Mature_ThrowRotL0:
	db OLF_XFLIP|OLF_YFLIP ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L186060 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mature_DropMain1.bin ; iOBJLstHdrA_DataPtr
	db $FF ; iOBJLstHdrA_XOffset
	db $EF ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mature_DropMain2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L186100 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F9 ; iOBJLstHdrA_XOffset
	db $02 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $39,$F3,$00 ; $00
	db $35,$FB,$02 ; $01
	db $35,$03,$04 ; $02
	db $2F,$0B,$06 ; $03
	db $37,$13,$08 ; $04
		
OBJLstHdrA_Mature_RunF0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L186AA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mature_HeavensGateS1.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mature_HeavensGateS1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L186AA0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $26,$EC,$00 ; $00
	db $26,$F4,$02 ; $01
	db $25,$FC,$04 ; $02
	db $28,$04,$06 ; $03
	db $35,$FC,$08 ; $04
	db $38,$04,$0A ; $05
	db $32,$0C,$0C ; $06
		
OBJLstHdrA_Mature_RunF1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L186B80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mature_HeavensGateS2.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mature_HeavensGateS2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_02 ; iOBJLstHdrA_HitboxId
	dpr L186B80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $24,$EC,$00 ; $00
	db $24,$F4,$02 ; $01
	db $23,$FC,$04 ; $02
	db $26,$04,$06 ; $03
	db $34,$F4,$08 ; $04
	db $33,$FC,$0A ; $05
	db $36,$04,$0C ; $06
	db $30,$0C,$0E ; $07
		
OBJLstHdrA_Mature_ThrowG0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L186920 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $1A,$EC,$00 ; $00
	db $1E,$F4,$02 ; $01
	db $1E,$FC,$04 ; $02
	db $2E,$F8,$06 ; $03
	db $31,$F3,$08 ; $04
	db $34,$00,$0A ; $05
		
OBJLstHdrA_Mature_ThrowG2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L1869E0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $20,$FB,$00 ; $00
	db $20,$03,$02 ; $01
	db $3B,$F3,$04 ; $02
	db $30,$FB,$06 ; $03
	db $30,$03,$08 ; $04
	db $2F,$0B,$0A ; $05
		
OBJLstHdrA_Mature_DecideL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_44 ; iOBJLstHdrA_HitboxId
	dpr L186C80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $31,$E4,$00 ; $00
	db $24,$EC,$02 ; $01
	db $24,$F4,$04 ; $02
	db $25,$FC,$06 ; $03
	db $2D,$04,$08 ; $04
	db $34,$F4,$0A ; $05
	db $35,$FC,$0C ; $06
	db $3D,$04,$0E ; $07
		
OBJLstHdrA_Mature_DecideL5A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L186D80 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $08 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $20,$F4,$00 ; $00
	db $20,$FC,$02 ; $01
	db $20,$04,$04 ; $02
	db $1B,$0C,$06 ; $03
	db $10,$FC,$08 ; $04
	db $10,$04,$0A ; $05
		
OBJLstHdrA_Mature_MetalMassacreL5A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_45 ; iOBJLstHdrA_HitboxId
	dpr L186E40 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F2 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $20,$EC,$00 ; $00
	db $20,$F4,$02 ; $01
	db $20,$FC,$04 ; $02
	db $20,$04,$06 ; $03
	db $20,$0C,$08 ; $04
	db $10,$F4,$0A ; $05
	db $10,$FC,$0C ; $06
	db $10,$04,$0E ; $07
	db $10,$0C,$10 ; $08
		
OBJLstHdrA_Mature_MetalMassacreL6A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_45 ; iOBJLstHdrA_HitboxId
	dpr L186F60 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F2 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $20,$EC,$00 ; $00
	db $20,$F4,$02 ; $01
	db $20,$FC,$04 ; $02
	db $20,$04,$06 ; $03
	db $20,$0C,$08 ; $04
	db $10,$04,$0A ; $05
	db $10,$0C,$0C ; $06
		
OBJLstHdrA_Mature_DeathRowL0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L187040 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_Mature_HeavensGateS4.bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_Mature_HeavensGateS4:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L187040 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $28,$F4,$00 ; $00
	db $29,$FC,$02 ; $01
	db $2D,$04,$04 ; $02
	db $2E,$0C,$06 ; $03
	db $3A,$F4,$08 ; $04
	db $39,$FC,$0A ; $05
	db $3D,$04,$0C ; $06
	db $3E,$0C,$0E ; $07
		
OBJLstHdrA_Mature_DeathRowL1:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_46 ; iOBJLstHdrA_HitboxId
	dpr L187140 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F8 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $0C ; OBJ Count
	;    Y   X  ID
	db $12,$EB,$00 ; $00
	db $12,$F3,$02 ; $01
	db $18,$FB,$04 ; $02
	db $12,$03,$06 ; $03
	db $08,$0B,$08 ; $04
	db $22,$EC,$0A ; $05
	db $29,$F3,$0C ; $06
	db $28,$FB,$0E ; $07
	db $22,$03,$10 ; $08
	db $32,$03,$12 ; $09
	db $38,$0B,$14 ; $0A
	db $38,$FB,$16 ; $0B
		
OBJLstHdrA_Mature_DeathRowL2A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_46 ; iOBJLstHdrA_HitboxId
	dpr L1872C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F7 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $19,$EC,$00 ; $00
	db $18,$F4,$02 ; $01
	db $18,$FC,$04 ; $02
		
OBJLstHdrA_Mature_DeathRowL4A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_47 ; iOBJLstHdrA_HitboxId
	dpr L187360 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F6 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $2D,$EC,$00 ; $00
	db $29,$F4,$02 ; $01
	db $25,$FC,$04 ; $02
	db $20,$04,$06 ; $03
	db $3D,$EC,$08 ; $04
	db $39,$F4,$0A ; $05
	db $35,$FC,$0C ; $06
		
OBJLstHdrA_Mature_DeathRowL5A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_47 ; iOBJLstHdrA_HitboxId
	dpr L187440 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F6 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $06 ; OBJ Count
	;    Y   X  ID
	db $30,$EC,$00 ; $00
	db $30,$F4,$02 ; $01
	db $30,$FC,$04 ; $02
	db $20,$F2,$06 ; $03
	db $20,$FA,$08 ; $04
	db $20,$02,$0A ; $05
		
OBJLstHdrA_Mature_DespairL2:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_48 ; iOBJLstHdrA_HitboxId
	dpr L187500 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $FC ; iOBJLstHdrA_XOffset
	db $0C ; iOBJLstHdrA_YOffset
.bin:
	db $0B ; OBJ Count
	;    Y   X  ID
	db $11,$EC,$00 ; $00
	db $07,$F2,$02 ; $01
	db $21,$EC,$04 ; $02
	db $17,$F4,$06 ; $03
	db $1B,$FC,$08 ; $04
	db $18,$04,$0A ; $05
	db $18,$0C,$0C ; $06
	db $27,$F4,$0E ; $07
	db $2B,$FC,$10 ; $08
	db $28,$04,$12 ; $09
	db $28,$0C,$14 ; $0A
		
OBJLstHdrA_Mature_DespairL3A:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L187660 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $08 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID
	db $22,$EC,$00 ; $00
	db $22,$F4,$02 ; $01
	db $32,$F4,$04 ; $02
		
OBJLstHdrA_Mature_HeavensGateS0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L1876C0 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $F4 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $25,$04,$00 ; $00
	db $25,$0C,$02 ; $01
	db $35,$00,$04 ; $02
	db $35,$08,$06 ; $03
	db $3B,$10,$08 ; $04
		
OBJLstHdrA_Mature_HeavensGateS5:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db COLIBOX_05 ; iOBJLstHdrA_HitboxId
	dpr L187760 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $23,$E4,$00 ; $00
	db $1C,$EC,$02 ; $01
	db $24,$F4,$04 ; $02
	db $24,$FC,$06 ; $03
	db $34,$F2,$08 ; $04
	db $34,$FA,$0A ; $05
	db $31,$02,$0C ; $06
		
OBJLstHdrA_Mature_HopB0:
	db $00 ; iOBJLstHdrA_Flags
	db COLIBOX_01 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	dpr L187840 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $25,$F0,$00 ; $00
	db $20,$F8,$02 ; $01
	db $20,$00,$04 ; $02
	db $21,$08,$06 ; $03
	db $35,$F0,$08 ; $04
	db $30,$F8,$0A ; $05
	db $30,$00,$0C ; $06

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
	mMvIn_ValidateSuper .chkPunchNoSuper
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
	mMvIn_ValidateProjActive Krauser
	call Play_Pl_ClearJoyDirBuffer
	mMvIn_GetLH MOVE_KRAUSER_HIGH_BLITZ_BALL_L, MOVE_KRAUSER_HIGH_BLITZ_BALL_H
	call MoveInputS_SetSpecMove_StopSpeed
	call Play_Proj_CopyMoveDamageFromPl
	jp   MoveInputReader_Krauser_SetMove
; =============== MoveInit_Krauser_LowBlitzBall ===============	
MoveInit_Krauser_LowBlitzBall:
	mMvIn_ValidateProjActive Krauser
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
	mMvIn_ValidateProjActive Krauser
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
		mMvC_PlaySound SCT_11
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
		mMvC_PlaySound SCT_11
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
		mMvC_PlaySound SCT_11
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
		mMvC_PlaySound SCT_11
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
	
				mMvC_PlaySound SCT_14
	
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
	mMvC_PlaySound SCT_15
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
; =============== END OF BANK ===============
; Junk area below.
	mIncJunk "L097E48"