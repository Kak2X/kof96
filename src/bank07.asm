INCLUDE "data/objlst/char/kyo.asm"		
INCLUDE "data/objlst/char/robert.asm"
INCLUDE "data/objlst/char/geese.asm"
INCLUDE "data/objlst/char/mrbig.asm"

IF REV_LANG_EN == 1
	mIncJunk "L077E43"
TextC_CutsceneMrKarateDefeat3:
	db .end-.start
.start:
	db "Ofcourse You`re not.", C_NL
.end:
TextC_CutsceneMrKarateDefeat4:
	db .end-.start
.start:
	db "It`s time for me", C_NL
	db "              to go.", C_NL
	db "But we shall meet", C_NL
	db "              Again!", C_NL
.end:
TextC_CutsceneMrKarateDefeat5:
	db .end-.start
.start:
	db "They would have", C_NL
	db " realized who I was", C_NL
	db " if I`d stayed any", C_NL
	db "           longer...", C_NL
.end:
TextC_CutsceneMrKarateDefeat6:
	db .end-.start
.start:
	db "I`ll fight in the", C_NL
	db " tournament next", C_NL
	db "               time.", C_NL
.end:
TextC_CutsceneMrKarateDefeat7:
	db .end-.start
.start:
	db "Press the SELECT", C_NL
	db " button 20 times", C_NL
	db " when the TAKARA", C_NL
	db " logo is displayed.", C_NL
.end:
TextC_CutsceneMrKarateDefeat8:
	db .end-.start
.start:
	db "Choose me at the", C_NL
	db " SELECT screen,then", C_NL
	db " battle your way to", C_NL
	db "            the top!", C_NL
.end:
ENDC

IF REV_VER_2 == 0
; =============== END OF BANK ===============
	mIncJunk "L077E43"
ELSE
	mIncJunk "L077FC5"
ENDC
	