; Constants
DEF NO_SGB_SOUND EQU 0 ; Forces DMG-only sound playback. For emulators which don't implement SGB sound.
DEF CPU_USAGE    EQU 0 ; Uses different code for VBlank waiting to make the CPU Usage bar in BGB work
DEF SKIP_JUNK    EQU 0 ; Removes padding areas
DEF LABEL_JUNK   EQU 0 ; If SKIP_JUNK isn't set, labels the padding areas.
DEF FIX_BUGS     EQU 0 ; Self explainatory
DEF OPTIMIZE     EQU 0 ; Additional optimizations
DEF NO_CPU_AI    EQU 0 ; Disable CPU Opponent AI (but not the CPU-specific actions inside moves)
DEF INF_TIMER    EQU 0 ; Default with infinite timer 
DEF AIRTHROW_CPU EQU 0 ; Enables the player to air-throw the CPU, which is arbitrarily disabled.
DEF DEFAULT_DIPS EQU $00 ; $E0 ; Default dip switch settings

DEF REV_VER_2    EQU 0 ; If set, use the second revision of the game.
DEF REV_TAUNT    EQU 0 ; If set, use the ridiculous taunt logic of the English version
DEF REV_LOGO_EN  EQU 0 ; Use Laguna logo and english-style copyright/logo changes.
DEF REV_LANG_EN  EQU 0 ; Use English text.

INCLUDE "main.asm"