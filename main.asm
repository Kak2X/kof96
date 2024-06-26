;
; 熱闘 ザ・キング・オブ・ファイターズ ’９６
;
; THE KING OF FIGHTERS '96
;

; Sanity checks for unsupported options
IF !REV_VER_2 && !REV_TAUNT && !REV_TAUNT && !REV_LANG_EN
ELIF REV_VER_2 && REV_TAUNT && REV_TAUNT && REV_LANG_EN
ELIF SKIP_JUNK == 0
	FAIL "SKIP_JUNK must be 1 if not using a fully Japanese or English build."
ENDC

; Include the basics
INCLUDE "src/font.asm"
INCLUDE "src/hardware.asm"
INCLUDE "src/constants.asm"
INCLUDE "src/macro.asm"
INCLUDE "src/memory.asm"

; Pick ascii font
IF REV_LANG_EN
	SETCHARMAP eng
ELSE
	SETCHARMAP jpn
ENDC

; 
; BANK $00 - Task system, Sprite mapping (OBJLst) and animation handlers, gameplay code and many helper subroutines.
; 
SECTION "bank00", ROM0
INCLUDE "src/bank00.asm"

;
; BANK $01 - Main gameplay code, Gameplay GFX
; 
SECTION "bank01", ROMX, BANK[$01]
INCLUDE "src/bank01.asm"

;
; BANK $02 - Move code (base)
; 
SECTION "bank02", ROMX, BANK[$02]
INCLUDE "src/bank02.asm"

;
; BANK $03 - Move assignment tables for each character, assignments, CPU AI.
;
SECTION "bank03", ROMX, BANK[$03]
INCLUDE "src/bank03.asm"

; 
; BANK $04 - SGB Packets, SGB Packet handler, SGB Border GFX/tilemaps, Stage GFX/tilemaps.
;
SECTION "bank04", ROMX, BANK[$04]
INCLUDE "src/bank04.asm"

;
; BANK $05 - Sprite mappings, Move code
;
SECTION "bank05", ROMX, BANK[$05]
INCLUDE "src/bank05.asm"

;
; BANK $06 - Move code
;
SECTION "bank06", ROMX, BANK[$06]
INCLUDE "src/bank06.asm"

;
; BANK $07 - Sprite mappings
;
SECTION "bank07", ROMX, BANK[$07]
INCLUDE "src/bank07.asm"

;
; BANK $08 - Sprite mappings
;
SECTION "bank08", ROMX, BANK[$08]
INCLUDE "src/bank08.asm"

;
; BANK $09 - Sprite mappings, Move code
;
SECTION "bank09", ROMX, BANK[$09]
INCLUDE "src/bank09.asm"

;
; BANK $0A - TAKARA logo, Sprite mappings, Move code
;
SECTION "bank0A", ROMX, BANK[$0A]
INCLUDE "src/bank0A.asm"

;
; BANK $0B - Character GFX
;
SECTION "bank0B", ROMX, BANK[$0B]
INCLUDE "src/bank0B.asm"

;
; BANK $0C - Character GFX
;
SECTION "bank0C", ROMX, BANK[$0C]
INCLUDE "src/bank0C.asm"

;
; BANK $0D - Character GFX
;
SECTION "bank0D", ROMX, BANK[$0D]
INCLUDE "src/bank0D.asm"

;
; BANK $0E - Character GFX
;
SECTION "bank0E", ROMX, BANK[$0E]
INCLUDE "src/bank0E.asm"

;
; BANK $0F - Character GFX
;
SECTION "bank0F", ROMX, BANK[$0F]
INCLUDE "src/bank0F.asm"

;
; BANK $10 - Character GFX
;
SECTION "bank10", ROMX, BANK[$10]
INCLUDE "src/bank10.asm"

;
; BANK $11 - Character GFX
;
SECTION "bank11", ROMX, BANK[$11]
INCLUDE "src/bank11.asm"

;
; BANK $12 - Character GFX
;
SECTION "bank12", ROMX, BANK[$12]
INCLUDE "src/bank12.asm"

;
; BANK $13 - Character GFX
;
SECTION "bank13", ROMX, BANK[$13]
INCLUDE "src/bank13.asm"

;
; BANK $14 - Character GFX
;
SECTION "bank14", ROMX, BANK[$14]
INCLUDE "src/bank14.asm"

;
; BANK $15 - Character GFX
;
SECTION "bank15", ROMX, BANK[$15]
INCLUDE "src/bank15.asm"

;
; BANK $16 - Character GFX
;
SECTION "bank16", ROMX, BANK[$16]
INCLUDE "src/bank16.asm"

;
; BANK $17 - Character GFX
;
SECTION "bank17", ROMX, BANK[$17]
INCLUDE "src/bank17.asm"

;
; BANK $18 - Character GFX
;
SECTION "bank18", ROMX, BANK[$18]
INCLUDE "src/bank18.asm"

;
; BANK $19 - Character GFX
;
SECTION "bank19", ROMX, BANK[$19]
INCLUDE "src/bank19.asm"

;
; BANK $1A - Character GFX
;
SECTION "bank1A", ROMX, BANK[$1A]
INCLUDE "src/bank1A.asm"

;
; BANK $1B - Character GFX
;
SECTION "bank1B", ROMX, BANK[$1B]
INCLUDE "src/bank1B.asm"

;
; BANK $1C - Character GFX, Intro, Title screen (+ Options, Game Select), Move code, Text
;
SECTION "bank1C", ROMX, BANK[$1C]
INCLUDE "src/bank1C.asm"

;
; BANK $1D - HUD GFX/tilemaps, Win/Continue/Game Over Screen, Cutscenes, Text
;
SECTION "bank1D", ROMX, BANK[$1D]
INCLUDE "src/bank1D.asm"

;
; BANK $1E - Character Select, Order Select, Win Screen
;
SECTION "bank1E", ROMX, BANK[$1E]
INCLUDE "src/bank1E.asm"

;
; BANK $1F - Sound Driver, Tile Flip table, JIS X mapping table.
;
SECTION "bank1F", ROMX, BANK[$1F]
INCLUDE "src/bank1F.asm"

