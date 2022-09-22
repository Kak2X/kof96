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

DIPB_0 EQU 0
DIPB_1 EQU 1
DIPB_2 EQU 2
DIPB_3 EQU 3
DIPB_4 EQU 4
DIPB_5 EQU 5
DIPB_6 EQU 6
DIPB_7 EQU 7

DIFFICULTY_EASY		EQU $00
DIFFICULTY_NORMAL	EQU $01
DIFFICULTY_HARD		EQU $02


DIPB_EASY_MOVES       EQU 2 ; SELECT + A/B for easy super moves
DIPB_INFINITE_METER   EQU 3 ; Unlimited super moves + Meter always grows
DIPB_SGB_SOUND_TEST   EQU 4 ; Adds SGB S.E TEST to the options menu
DIPB_TEAM_DUPL        EQU 5 ; Allow duplicate characters in a team
DIPB_UNLOCK_GOENITZ   EQU 6 ; Unlock Goenitz
DIPB_UNLOCK_OTHER     EQU 7 ; Unlock everyone else (Mr Karate, Boss Kagura, Orochi Iori and Orochi Leona)


BORDER_NONE			EQU $00
BORDER_MAIN 		EQU $01
BORDER_ALTERNATE 	EQU $02

TIMER_INFINITE		EQU $FF

; Are these the same?
VS_SELECTED_THIS  EQU $02
VS_SELECTED_OTHER EQU $03
SERIAL_PL1_ID EQU $02
SERIAL_PL2_ID EQU $03

C_NL EQU $FF ; Newline character in strings

TILE_INTRO_WHITE EQU $00
TILE_INTRO_BLACK EQU $01

OBJ_OFFSET_X        EQU $08 ; Standard offset used when sprite positions are compared to the screen/scroll
OBJLSTPTR_NONE      EQU $FFFF ; Placeholder pointer that marks the lack of a secondary sprite mapping and the end separator


; FLAGS

; $C025
MISCB_FREEZE EQU 3 ; Prevents tasks and almost everything from executing, effectively freezing the game until it's unset. May be used to force sync in serial VS???
MISCB_SERIAL_PL2_SLAVE EQU 5 ; If set, the GB is the slave (matches PL2), otherwise it's the master (PL1)
MISCB_SERIAL_MODE EQU 6 ; Marks a VS battle through serial cable. Not in SGB mode.
MISCB_IS_SGB EQU 7	; Enables SGB features
; $C026
MISCB_LAG_FRAME EQU 3 ; Is set when the task cycler is called, and unset right before the VBlank wait loop.
; $C028
MISCB_USE_SECT EQU 0 ; If set, the screen uses the three-section mode (SetSectLYC was called). Otherwise there's a single section governed by hScrollX and hScrollY.
MISCB_PL_RANGE_CHECK EQU 1 ; Enables the player range enforcement, which is part of the sprite drawing routine.
                           ; Should only be used during gameplay, otherwise it could get in the way.
MISCB_TITLE_SECT EQU 2 ; Allows parallax for the title screen

MISC_USE_SECT EQU 1 << MISCB_USE_SECT
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

; iOBJInfo_StatusEx* bits from RAM
; Almost the same as iOBJInfo_Status, but not completely.
; Only the unique values will be listed.
OSXB_BGPRIORITY EQU 7 ; If set, the BG has priority over the sprite mapping
OSX_BGPRIORITY EQU 1 << OSXB_BGPRIORITY

; OBJLST / SPRITE MAPPINGS FLAGS from ROM
; These are almost the same as the iOBJInfo_StatusEx* bits.
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

; Intro Scene IDs (Intro_ExecScene)
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