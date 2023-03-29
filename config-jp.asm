; Constants
NO_SGB_SOUND EQU 0 ; Forces DMG-only sound playback. For emulators which don't implement SGB sound.
CPU_USAGE    EQU 0 ; Uses different code for VBlank waiting to make the CPU Usage bar in BGB work
SKIP_JUNK    EQU 0 ; Removes padding areas
LABEL_JUNK   EQU 0 ; If SKIP_JUNK isn't set, labels the padding areas.
FIX_BUGS     EQU 0 ; Self explainatory
NO_CPU_AI    EQU 0 ; Disable CPU Opponent AI (but not the CPU-specific actions inside moves)
INF_TIMER    EQU 0 ; Default with infinite timer 
ENGLISH      EQU 0 ; 0 -> JPN, 1 -> EU

INCLUDE "main.asm"