; Constants
NO_SGB_SOUND EQU 0 ; Forces DMG-only sound playback. For emulators which don't implement SGB sound.

; Include the basics
INCLUDE "src/hardware.asm"
INCLUDE "src/constants.asm"
INCLUDE "src/macro.asm"
INCLUDE "src/memory.asm"

; 
SECTION "bank00", ROM0
INCLUDE "src/bank00.asm"

; 
SECTION "bank01", ROMX, BANK[$01]
INCLUDE "src/bank01.asm"

; 
SECTION "bank02", ROMX, BANK[$02]
INCLUDE "src/bank02.asm"

; 
SECTION "bank03", ROMX, BANK[$03]
INCLUDE "src/bank03.asm"

; 
SECTION "bank04", ROMX, BANK[$04]
INCLUDE "src/bank04.asm"

; 
SECTION "bank05", ROMX, BANK[$05]
INCLUDE "src/bank05.asm"

; 
SECTION "bank06", ROMX, BANK[$06]
INCLUDE "src/bank06.asm"

; 
SECTION "bank07", ROMX, BANK[$07]
INCLUDE "src/bank07.asm"

; 
SECTION "bank08", ROMX, BANK[$08]
INCLUDE "src/bank08.asm"

; 
SECTION "bank09", ROMX, BANK[$09]
INCLUDE "src/bank09.asm"

; 
SECTION "bank0A", ROMX, BANK[$0A]
INCLUDE "src/bank0A.asm"

; 
SECTION "bank0B", ROMX, BANK[$0B]
INCLUDE "src/bank0B.asm"

; 
SECTION "bank0C", ROMX, BANK[$0C]
INCLUDE "src/bank0C.asm"

; 
SECTION "bank0D", ROMX, BANK[$0D]
INCLUDE "src/bank0D.asm"

; 
SECTION "bank0E", ROMX, BANK[$0E]
INCLUDE "src/bank0E.asm"

; 
SECTION "bank0F", ROMX, BANK[$0F]
INCLUDE "src/bank0F.asm"

; 
SECTION "bank10", ROMX, BANK[$10]
INCLUDE "src/bank10.asm"

; 
SECTION "bank11", ROMX, BANK[$11]
INCLUDE "src/bank11.asm"

; 
SECTION "bank12", ROMX, BANK[$12]
INCLUDE "src/bank12.asm"

; 
SECTION "bank13", ROMX, BANK[$13]
INCLUDE "src/bank13.asm"

; 
SECTION "bank14", ROMX, BANK[$14]
INCLUDE "src/bank14.asm"

; 
SECTION "bank15", ROMX, BANK[$15]
INCLUDE "src/bank15.asm"

; 
SECTION "bank16", ROMX, BANK[$16]
INCLUDE "src/bank16.asm"

; 
SECTION "bank17", ROMX, BANK[$17]
INCLUDE "src/bank17.asm"

; 
SECTION "bank18", ROMX, BANK[$18]
INCLUDE "src/bank18.asm"

; 
SECTION "bank19", ROMX, BANK[$19]
INCLUDE "src/bank19.asm"

; 
SECTION "bank1A", ROMX, BANK[$1A]
INCLUDE "src/bank1A.asm"

; 
SECTION "bank1B", ROMX, BANK[$1B]
INCLUDE "src/bank1B.asm"

; 
SECTION "bank1C", ROMX, BANK[$1C]
INCLUDE "src/bank1C.asm"

; 
SECTION "bank1D", ROMX, BANK[$1D]
INCLUDE "src/bank1D.asm"

; 
SECTION "bank1E", ROMX, BANK[$1E]
INCLUDE "src/bank1E.asm"

; 
SECTION "bank1F", ROMX, BANK[$1F]
INCLUDE "src/bank1F.asm"

