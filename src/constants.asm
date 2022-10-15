; Keys (as bit numbers)
KEYB_RIGHT       EQU 0
KEYB_LEFT        EQU 1
KEYB_UP          EQU 2
KEYB_DOWN        EQU 3
KEYB_A           EQU 4
KEYB_B           EQU 5
KEYB_SELECT      EQU 6
KEYB_START       EQU 7

; Keys (values)
KEY_NONE         EQU 0
KEY_RIGHT        EQU 1 << KEYB_RIGHT
KEY_LEFT         EQU 1 << KEYB_LEFT
KEY_UP           EQU 1 << KEYB_UP
KEY_DOWN         EQU 1 << KEYB_DOWN
KEY_A            EQU 1 << KEYB_A
KEY_B            EQU 1 << KEYB_B
KEY_SELECT       EQU 1 << KEYB_SELECT
KEY_START        EQU 1 << KEYB_START

DIFFICULTY_EASY		EQU $00
DIFFICULTY_NORMAL	EQU $01
DIFFICULTY_HARD		EQU $02

BORDER_NONE			EQU $00
BORDER_MAIN 		EQU $01
BORDER_ALTERNATE 	EQU $02

TIMER_INFINITE		EQU $FF

MODEB_TEAM    EQU 0
MODEB_VS      EQU 1
MODE_SINGLE1P EQU $00
MODE_TEAM1P   EQU $01
MODE_SINGLEVS EQU $02
MODE_TEAMVS   EQU $03

; TODO: Replace all other related constants with these
; Player IDs used across multiple variables
PL1 EQU $00		
PL2 EQU $01
PLB1 EQU 0
PLB2 EQU 1

ACTIVE_CTRL_PL1          EQU $00
ACTIVE_CTRL_PL2          EQU $01

LASTWIN_PL1 EQU 0
LASTWIN_PL2 EQU 1


; Character IDs
; [POI] These are grouped by team, not like it matters.
CHAR_ID_KYO      EQU $00
CHAR_ID_DAIMON   EQU $01
CHAR_ID_TERRY    EQU $02
CHAR_ID_ANDY     EQU $03
CHAR_ID_RYO      EQU $04
CHAR_ID_ROBERT   EQU $05
CHAR_ID_ATHENA   EQU $06
CHAR_ID_MAI      EQU $07
CHAR_ID_LEONA    EQU $08
CHAR_ID_GEESE    EQU $09
CHAR_ID_KRAUSER  EQU $0A
CHAR_ID_MRBIG    EQU $0B
CHAR_ID_IORI     EQU $0C
CHAR_ID_MATURE   EQU $0D
CHAR_ID_CHIZURU  EQU $0E
CHAR_ID_GOENITZ  EQU $0F
CHAR_ID_MRKARATE EQU $10
CHAR_ID_OIORI    EQU $11
CHAR_ID_OLEONA   EQU $12
CHAR_ID_KAGURA   EQU $13
CHAR_ID_NONE     EQU $FF

; Special hardcoded stages for bosses or secrets.
; These are special indexes to wRoundSeqTbl that return CHAR_ID_* instead of CHARSEL_ID_*
STAGE_KAGURA   EQU $0F
STAGE_GOENITZ  EQU $10
STAGE_BONUS    EQU $11
STAGE_MRKARATE EQU $12

C_NL EQU $FF ; Newline character in strings

OBJ_OFFSET_X        EQU $08 ; Standard offset used when sprite positions are compared to the screen/scroll
OBJLSTPTR_NONE      EQU $FFFF ; Placeholder pointer that marks the lack of a secondary sprite mapping and the end separator
OBJLSTPTR_ENTRYSIZE EQU 4 ; Size of each OBJLstPtrTable entry (pair of OBJLstHdrA_* and OBJLstHdrB_* pointers)

; FLAGS
DIPB_EASY_MOVES       EQU 2 ; SELECT + A/B for easy super moves
DIPB_INFINITE_METER   EQU 3 ; Unlimited super moves + Meter always grows
DIPB_SGB_SOUND_TEST   EQU 4 ; Adds SGB S.E TEST to the options menu
DIPB_TEAM_DUPL        EQU 5 ; Allow duplicate characters in a team
DIPB_UNLOCK_GOENITZ   EQU 6 ; Unlock Goenitz
DIPB_UNLOCK_OTHER     EQU 7 ; Unlock everyone else (Mr Karate, Boss Kagura, Orochi Iori and Orochi Leona)

; $C025
MISCB_SERIAL_LAG      EQU 3 ; If set, it freezes the game. Essentially a version of MISCB_LAG_FRAME for the other GB.
                            ; Used to force the slave to wait (and not read new player inputs) until the master sends new bytes.
MISCB_SERIAL_SLAVE    EQU 5 ; If set, the GB is the slave (matches PL2), otherwise it's the master (PL1)
MISCB_SERIAL_MODE     EQU 6 ; Marks a VS battle through serial cable. Not in SGB mode.
MISCB_IS_SGB          EQU 7 ; Enables SGB features
; $C026
MISCB_LAG_FRAME       EQU 3 ; Is set when the task cycler is called, and unset right before the VBlank wait loop.
; $C028
MISCB_USE_SECT        EQU 0 ; If set, the screen uses the three-section mode (SetSectLYC was called). Otherwise there's a single section governed by hScrollX and hScrollY.
MISCB_PL_RANGE_CHECK  EQU 1 ; Enables the player range enforcement, which is part of the sprite drawing routine.
                            ; Should only be used during gameplay, otherwise it could get in the way.
MISCB_TITLE_SECT      EQU 2 ; Allows parallax for the title screen

MISC_USE_SECT         EQU 1 << MISCB_USE_SECT
;--


; TextPrinter_MultiFrame options
TXTB_PLAYSFX   EQU 0 ; Play SFX when printing a character
TXTB_ALLOWFAST EQU 1 ; Allows pressing A to speedup text printing, or START to enable instant text printing (TXCB_INSTANT)
TXTB_ALLOWSKIP EQU 2 ; Allows pressing START to end prematurely the text printing. Overrides TXTB_ALLOWFAST.

TXT_PLAYSFX   EQU 1 << TXTB_PLAYSFX  
TXT_ALLOWFAST EQU 1 << TXTB_ALLOWFAST
TXT_ALLOWSKIP EQU 1 << TXTB_ALLOWSKIP


TXCB_INSTANT EQU 7 ; If set, instant text printing was enabled
TXB_NONE EQU $FF ; No custom code when waiting idle
;--


OBJINFO_SIZE EQU $40 ; wOBJInfo size
GFXBUF_TILECOUNT EQU $20 ; Number of tiles in a GFX buffer

; iOBJInfo_Status bits
OSTB_GFXLOAD EQU 0 ; If set, the graphics are still being copied to the *opposite* buffer than the current one at OSTB_GFXBUF2
OSTB_GFXBUF2 EQU 1 ; If set, the second GFX buffer is used for the *current* frame
OSTB_BIT3    EQU 3 ; 
OSTB_ANIMEND EQU 4 ; Animation has ended, repeat last frame indefinitely
OSTB_XFLIP   EQU 5 ; Horizontal flip
OSTB_YFLIP   EQU 6 ; Vertical flip
OSTB_VISIBLE EQU 7 ; If not set, the sprite mapping is hidden

OST_GFXLOAD EQU 1 << OSTB_GFXLOAD
OST_GFXBUF2 EQU 1 << OSTB_GFXBUF2
OST_BIT3    EQU 1 << OSTB_BIT3
OST_ANIMEND EQU 1 << OSTB_ANIMEND
OST_XFLIP   EQU 1 << OSTB_XFLIP
OST_YFLIP   EQU 1 << OSTB_YFLIP
OST_VISIBLE EQU 1 << OSTB_VISIBLE

; OBJLST / SPRITE MAPPINGS FLAGS from ROM
; These are almost the same as the iOBJInfo_OBJLstFlags* bits.
; item0

OLFB_USETILEFLAGS EQU 4 ; If set, in the OBJ data, the upper two bits of a tile ID count as X/Y flip flags
OLFB_XFLIP        EQU 5 ; User-controlled
OLFB_YFLIP        EQU 6
OLFB_NOBUF        EQU 7 ; Sprite mapping doesn't use the buffer copy

OLF_USETILEFLAGS EQU 1 << OLFB_USETILEFLAGS ; $10
OLF_XFLIP        EQU 1 << OLFB_XFLIP ; $20
OLF_YFLIP        EQU 1 << OLFB_YFLIP ; $40
OLF_NOBUF        EQU 1 << OLFB_NOBUF

TASK_SIZE EQU $08

; Task types
TASK_EXEC_NONE EQU $00 ; No task here
TASK_EXEC_DONE EQU $01 ; Already executed this frame
TASK_EXEC_CUR  EQU $02 ; Currently executing
TASK_EXEC_TODO EQU $04 ; Not executed yet, but was executed previously already. Stack pointer type.
TASK_EXEC_NEW  EQU $08 ; Never executed before. Likely init code which will set a new task. Jump HL type.

; iPlInfo_Status flags
PSB_CPU        EQU 7 ; If set, the player is CPU-controlled (1P mode) or autopicks characters (VS mode)
PS_CPU         EQU 1 << PSB_CPU

SNDIDREQ_SIZE      EQU $08
SNDINFO_SIZE       EQU $20 ; Size of iSndInfo struct
SND_CH1_PTR        EQU LOW(rNR13)
SND_CH2_PTR        EQU LOW(rNR23)
SND_CH3_PTR        EQU LOW(rNR33)
SND_CH4_PTR        EQU LOW(rNR43)
SNDLEN_INFINITE    EQU $FF

; iSndInfo_Status
SISB_PAUSE         EQU 0 ; If set, iSndInfo processing is paused for that channel
SISB_SKIPNRx2      EQU 1 ; If set, rNR*2 won't be updated
SISB_USEDBYSFX     EQU 2 ; wBGMCh*Info only. If set, it marks that a sound effect is currently using the channel.
SISB_SFX           EQU 3 ; If set, the SndInfo is handled as a sound effect. If clear, it's a BGM.
SISB_UNK_UNUSED_6  EQU 6 ; ???
SISB_ENABLED       EQU 7 ; If set, iSndInfo processing is enabled for that channel

SIS_PAUSE          EQU 1 << SISB_PAUSE
SIS_SKIPNRx2       EQU 1 << SISB_SKIPNRx2    
SIS_USEDBYSFX      EQU 1 << SISB_USEDBYSFX   
SIS_SFX            EQU 1 << SISB_SFX         
SIS_UNK_UNUSED_6   EQU 1 << SISB_UNK_UNUSED_6
SIS_ENABLED        EQU 1 << SISB_ENABLED     

SNDCMD_BASE           EQU $E0
SNDNOTE_BASE          EQU $80

;--------------

; DMG Sound List
SND_MUTE              EQU $00
SND_BASE              EQU $80
SND_NONE              EQU SND_BASE+$00
BGM_ROULETTE          EQU SND_BASE+$01
BGM_STAGECLEAR        EQU SND_BASE+$02
BGM_BIGSHOT           EQU SND_BASE+$03
BGM_ESAKA             EQU SND_BASE+$04
BGM_RISINGRED         EQU SND_BASE+$05
BGM_GEESE             EQU SND_BASE+$06
BGM_ARASHI            EQU SND_BASE+$07
BGM_FAIRY             EQU SND_BASE+$08
BGM_TRASHHEAD         EQU SND_BASE+$09
BGM_WIND              EQU SND_BASE+$0A
BGM_TOTHESKY          EQU SND_BASE+$0B
SNC_PAUSE             EQU SND_BASE+$0C
SNC_UNPAUSE           EQU SND_BASE+$0D
SFX_CHARCURSORMOVE    EQU SND_BASE+$0E
SFX_CHARSELECTED      EQU SND_BASE+$0F
SFX_METERCHARGE       EQU SND_BASE+$10
SFX_SUPERMOVE         EQU SND_BASE+$11
SFX_LIGHT             EQU SND_BASE+$12
SFX_HEAVY             EQU SND_BASE+$13
SND_ID_14             EQU SND_BASE+$14
SFX_TAUNT             EQU SND_BASE+$15
SFX_HIT               EQU SND_BASE+$16
SND_ID_17             EQU SND_BASE+$17
BGM_PROTECTOR         EQU SND_BASE+$18
BGM_MRKARATE          EQU SND_BASE+$19
SND_ID_1A             EQU SND_BASE+$1A
SFX_DROP              EQU SND_BASE+$1B
SFX_SUPERJUMP         EQU SND_BASE+$1C
SFX_STEP              EQU SND_BASE+$1D
BGM_IN1996            EQU SND_BASE+$1E
BGM_MRKARATECUTSCENE  EQU SND_BASE+$1F
;SND_ID_20            EQU SND_BASE+$20
;SND_ID_21            EQU SND_BASE+$21
;SND_ID_22            EQU SND_BASE+$22
;SND_ID_23            EQU SND_BASE+$23
;SND_ID_24            EQU SND_BASE+$24
;SND_ID_25            EQU SND_BASE+$25
SND_ID_26             EQU SND_BASE+$26
SFX_GRABSTART         EQU SND_BASE+$27
SND_ID_28             EQU SND_BASE+$28
SND_ID_29             EQU SND_BASE+$29
SND_ID_2A             EQU SND_BASE+$2A
SND_ID_2B             EQU SND_BASE+$2B
SND_ID_2C             EQU SND_BASE+$2C
SND_ID_2D             EQU SND_BASE+$2D
SND_ID_2E             EQU SND_BASE+$2E
SND_ID_2F             EQU SND_BASE+$2F
SND_ID_30             EQU SND_BASE+$30
SFX_GAMEOVER          EQU SND_BASE+$31
;SND_ID_32            EQU SND_BASE+$32
;SND_ID_33            EQU SND_BASE+$33
SND_LAST_VALID        EQU SND_BASE+$45 ; Dunno why this late

; Sound Action List (offset by 1, since $00 is handled as SND_NONE) 
SCT_00                EQU $01
SCT_01                EQU $02
SCT_02                EQU $03
SCT_03                EQU $04
SCT_04                EQU $05
SCT_05                EQU $06
SCT_06                EQU $07
SCT_07                EQU $08
SCT_08                EQU $09
SCT_09                EQU $0A
SCT_0A                EQU $0B
SCT_0B                EQU $0C
SCT_0C                EQU $0D
SCT_0D                EQU $0E
SCT_0E                EQU $0F
SCT_0F                EQU $10
SCT_10                EQU $11
SCT_11                EQU $12
SCT_12                EQU $13
SCT_13                EQU $14

; Screen Palette IDs, passed to SGB_ApplyScreenPalSet 
SCRPAL_INTRO EQU $00
SCRPAL_TAKARALOGO EQU $01
SCRPAL_TITLE EQU $02
SCRPAL_CHARSELECT EQU $03
SCRPAL_ORDERSELECT EQU $04
SCRPAL_STAGECLEAR EQU $05
SCRPAL_STAGE_HERO EQU $06
SCRPAL_STAGE_FATALFURY EQU $07
SCRPAL_STAGE_YAGAMI EQU $08
SCRPAL_STAGE_BOSS EQU $09
SCRPAL_STAGE_STADIUM EQU $0A

;
; MODE IDs & CONSTANTS
;

; ============================================================
; INTRO

; TODO: GM_INTRO_TEXTPRINT...
ISC_TEXTPRINT       EQU $00
ISC_CHAR            EQU $02
ISC_IORIRISE        EQU $04
ISC_IORIKYO         EQU $06

ISCC_INIT           EQU $00
ISCC_TERRY          EQU $02
ISCC_ANDY           EQU $04
ISCC_MAI            EQU $06
ISCC_ATHENA         EQU $08
ISCC_LEONA          EQU $0A
ISCC_ROBERT         EQU $0C
ISCC_RYO            EQU $0E
ISCC_MRKARATE       EQU $10
ISCC_MRBIG          EQU $12
ISCC_GEESE          EQU $14
ISCC_KRAUSER        EQU $16
ISCC_DAIMON         EQU $18
ISCC_MATURE         EQU $1A
ISCC_CHG_IORIRISE   EQU $1C
ISCC_KYO            EQU $1E
ISCC_IORIKYOA       EQU $20
ISCC_IORIKYOB       EQU $22
ISCC_IORIKYOC       EQU $24
ISCC_CHG_IORIKYO    EQU $26

TILE_INTRO_WHITE    EQU $00
TILE_INTRO_BLACK    EQU $01

; ============================================================
; TITLE SCREEN / MENUS

GM_TITLE_TITLE          EQU $00
GM_TITLE_TITLEMENU      EQU $02 
GM_TITLE_MODESELECT     EQU $04
GM_TITLE_OPTIONS        EQU $06

; SHARED
TITLE_OBJ_PUSHSTART     EQU $00
TITLE_OBJ_MENU          EQU $01
TITLE_OBJ_CURSOR_R      EQU $02
TITLE_OBJ_SNKCOPYRIGHT  EQU $03
TITLE_OBJ_CURSOR_U      EQU $04

; TITLE
TITLE_RESET_TIMER       EQU (30 * $100) | 60 ; 30 seconds

; TITLEMENU
TITLEMENU_TO_TITLE      EQU $00
TITLEMENU_TO_MODESELECT EQU $01
TITLEMENU_TO_OPTIONS    EQU $02

; MODESELECT
MODESELECT_ACT_EXIT     EQU $00
MODESELECT_ACT_SINGLE1P EQU MODE_SINGLE1P+1
MODESELECT_ACT_TEAM1P   EQU MODE_TEAM1P+1
MODESELECT_ACT_SINGLEVS EQU MODE_SINGLEVS+1
MODESELECT_ACT_TEAMVS   EQU MODE_TEAMVS+1

; Mode IDs sent out through the serial
MODESELECT_SBCMD_IDLE     EQU $02
MODESELECT_SBCMD_SINGLEVS EQU MODESELECT_ACT_SINGLEVS
MODESELECT_SBCMD_TEAMVS   EQU MODESELECT_ACT_TEAMVS

; Implementation detail leads to this
SERIAL_PL1_ID             EQU MODESELECT_SBCMD_IDLE
; SERIAL_PL2_ID is not a constant, but any val != $00 && != $02

; OPTIONS

; Main options
OPTION_ITEM_TIME        EQU $00
OPTION_ITEM_LEVEL       EQU $01
OPTION_ITEM_BGMTEST     EQU $02
OPTION_ITEM_SFXTEST     EQU $03
OPTION_ITEM_SGBSNDTEST  EQU $04
OPTION_ITEM_EXIT        EQU $05

; SGB sound test options
OPTION_SITEM_ID_A       EQU $00
OPTION_SITEM_BANK_A     EQU $01
OPTION_SITEM_ID_B       EQU $02
OPTION_SITEM_BANK_B     EQU $03


OPTIONS_ACT_EXIT EQU $00
OPTIONS_ACT_L EQU $01
OPTIONS_ACT_R EQU $02
OPTIONS_ACT_A EQU $03
OPTIONS_ACT_B EQU $04

OPTIONS_SACT_EXIT    EQU $00
OPTIONS_SACT_UP      EQU $01
OPTIONS_SACT_DOWN    EQU $02
OPTIONS_SACT_A       EQU $03
OPTIONS_SACT_B       EQU $04
OPTIONS_SACT_SUBEXIT EQU $05

OPTIONS_TIMER_MIN EQU $10
OPTIONS_TIMER_INC EQU $10
OPTIONS_TIMER_MAX EQU $90

OPTION_MENU_NORMAL  EQU $00
OPTION_MENU_SGBTEST EQU $02

; ============================================================
; CHARACTER SELECT

; Portrait IDs
; These identify the blocks in the character select screen that the cursor can go over.
CHARSEL_ID_KYO       EQU $00
CHARSEL_ID_ANDY      EQU $01
CHARSEL_ID_TERRY     EQU $02
CHARSEL_ID_RYO       EQU $03
CHARSEL_ID_ROBERT    EQU $04
CHARSEL_ID_IORI      EQU $05
CHARSEL_ID_DAIMON    EQU $06
CHARSEL_ID_MAI       EQU $07
CHARSEL_ID_GEESE     EQU $08
CHARSEL_ID_MRBIG     EQU $09
CHARSEL_ID_KRAUSER   EQU $0A
CHARSEL_ID_MATURE    EQU $0B
CHARSEL_ID_ATHENA    EQU $0C
CHARSEL_ID_CHIZURU   EQU $0D
CHARSEL_ID_MRKARATE0 EQU $0E ; 2 slots
CHARSEL_ID_MRKARATE1 EQU $0F
CHARSEL_ID_GOENITZ   EQU $10
CHARSEL_ID_LEONA     EQU $11
; Extra entries not part of the slots
CHARSEL_ID_SPEC_OIORI  EQU $12
CHARSEL_ID_SPEC_OLEONA EQU $13
CHARSEL_ID_SPEC_KAGURA EQU $14

CHARSEL_POSFB_BOSS EQU 7
CHARSEL_POSF_BOSS EQU 1 << CHARSEL_POSFB_BOSS

CHARSEL_MODE_SELECT    EQU $00
CHARSEL_MODE_READY     EQU $02
CHARSEL_MODE_CONFIRMED EQU $04

CHARSEL_1P EQU $00
CHARSEL_2P EQU $01	

CHARSEL_TEAM_REMAIN EQU $00
CHARSEL_TEAM_FILLED EQU $FF

CHARSEL_GRID_W    EQU $06
CHARSEL_GRID_H    EQU $03
CHARSEL_GRID_SIZE EQU CHARSEL_GRID_W * CHARSEL_GRID_H

CHARSEL_OBJ_CURSOR1P        EQU $00
CHARSEL_OBJ_CURSOR1PWIDE    EQU $04
CHARSEL_OBJ_CURSOR2P        EQU $08
CHARSEL_OBJ_CURSOR2PWIDE    EQU $0C
CHARSEL_OBJ_CURSORCPU1P     EQU $10
CHARSEL_OBJ_CURSORCPU1PWIDE EQU $14
CHARSEL_OBJ_CURSORCPU2P     EQU $18
CHARSEL_OBJ_CURSORCPU2PWIDE EQU $1C

BG_CHARSEL_P1ICON0 EQU $99E1
BG_CHARSEL_P1ICON1 EQU $99E3
BG_CHARSEL_P1ICON2 EQU $99E5
BG_CHARSEL_P2ICON0 EQU $99F1
BG_CHARSEL_P2ICON1 EQU $99EF
BG_CHARSEL_P2ICON2 EQU $99ED

; Blank boxes with numbers
TILE_CHARSEL_ICONEMPTY1 EQU $EC
TILE_CHARSEL_ICONEMPTY2 EQU $F0
TILE_CHARSEL_ICONEMPTY3 EQU $F4

TILE_CHARSEL_P1ICON0 EQU $F8
TILE_CHARSEL_P1ICON1 EQU $1F
TILE_CHARSEL_P1ICON2 EQU $23

TILE_CHARSEL_P2ICON0 EQU $FC
TILE_CHARSEL_P2ICON1 EQU $27
TILE_CHARSEL_P2ICON2 EQU $2B

; ============================================================
; ORDER SELECT
ORDSEL_SEL0 EQU $00
ORDSEL_SEL1 EQU $01
ORDSEL_SEL2 EQU $02
ORDSEL_SELDONE EQU $03