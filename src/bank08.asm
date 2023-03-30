INCLUDE "data/objlst/char/andy.asm"
INCLUDE "data/objlst/char/athena.asm"		
INCLUDE "data/objlst/char/mai.asm"
INCLUDE "data/objlst/char/goenitz.asm"

IF REV_LANG_EN == 1
TextC_Ending_KaguraGeneric0:
	db .end-.start
.start:
	db "Thank you all.", C_NL
	db "He is gone.", C_NL
.end:
TextC_Ending_KaguraGeneric1:
	db .end-.start
.start:
	db "But his followers", C_NL
	db " who lurk in the", C_NL
	db " shadows may draw", C_NL
	db " humanity into dark-", C_NL
	db " ness at any time.", C_NL
.end:
TextC_Ending_KaguraGeneric2:
	db .end-.start
.start:
	db "And it could be", C_NL
	db "             soon...", C_NL
	db "We shall meet again", C_NL
	db " then.", C_NL
.end:
TextC_CheatList:
	db .end-.start
.start:
	db C_NL
	db " Press the SELECT", C_NL
	db " button 3 times when", C_NL
	db " the TAKARA logo is", C_NL
	db " displayed to be", C_NL
	db " able to", C_NL
	db "    play as Goenitz.", C_NL
	db C_NL
	db C_NL
	db C_NL
	db C_NL
.end:
ENDC

IF REV_VER_2 == 0
; =============== END OF BANK ===============
; Junk area below.
	mIncJunk "L087EC8"
ELSE
	mIncJunk "L087FEF"
ENDC