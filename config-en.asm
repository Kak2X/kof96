; Constants
NO_SGB_SOUND EQU 0 ; Forces DMG-only sound playback. For emulators which don't implement SGB sound.
CPU_USAGE    EQU 0 ; Uses different code for VBlank waiting to make the CPU Usage bar in BGB work
SKIP_JUNK    EQU 0 ; Removes padding areas
LABEL_JUNK   EQU 0 ; If SKIP_JUNK isn't set, labels the padding areas.
FIX_BUGS     EQU 0 ; Self explainatory
OPTIMIZE     EQU 0 ; Additional optimizations
NO_CPU_AI    EQU 0 ; Disable CPU Opponent AI (but not the CPU-specific actions inside moves)
INF_TIMER    EQU 0 ; Default with infinite timer 

REV_VER_2    EQU 1 ; If set, use the second revision of the game.
REV_TAUNT    EQU 1 ; If set, use the ridiculous taunt logic of the English version
REV_LOGO_EN  EQU 1 ; Use Laguna logo and english-style copyright/logo changes.
REV_LANG_EN  EQU 1 ; Use English text.

INCLUDE "main.asm"