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
PLB1 EQU 0 ; $01
PLB2 EQU 1 ; $02

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

STAGE_ID_HERO             EQU $00
STAGE_ID_FATALFURY        EQU $01
STAGE_ID_YAGAMI           EQU $02
STAGE_ID_BOSS             EQU $03
STAGE_ID_STADIUM_KAGURA   EQU $04
STAGE_ID_STADIUM_GOENITZ  EQU $05
STAGE_ID_STADIUM_EXTRA    EQU $06


; Special hardcoded stages for bosses or secrets.
; These are special indexes to wRoundSeqTbl that return CHAR_ID_* instead of CHARSEL_ID_*
STAGESEQ_KAGURA   EQU $0F
STAGESEQ_GOENITZ  EQU $10
STAGESEQ_BONUS    EQU $11
STAGESEQ_MRKARATE EQU $12

C_NL EQU $FF ; Newline character in strings

OBJ_OFFSET_X        EQU $08 ; Standard offset used when sprite positions are compared to the screen/scroll
OBJLSTPTR_NONE      EQU $FFFF ; Placeholder pointer that marks the lack of a secondary sprite mapping and the end separator
OBJLSTPTR_ENTRYSIZE EQU 4 ; Size of each OBJLstPtrTable entry (pair of OBJLstHdrA_* and OBJLstHdrB_* pointers)

; FLAGS
DIPB_EASY_MOVES       EQU 2 ; SELECT + A/B for easy super moves
DIPB_INFINITE_METER   EQU 3 ; POW Meter grows on its own + Unlimited super moves (TODO: rename to DIPB_AUTO_CHARGE)
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
; $C027
MISCB_PLAY_STOP       EQU 7 ; If set, the game stops processing input and the timer. Used on the intro and when a round ends.
; $C028
MISCB_USE_SECT        EQU 0 ; If set, the screen uses the three-section mode (SetSectLYC was called). Otherwise there's a single section governed by hScrollX and hScrollY.
MISCB_PL_RANGE_CHECK  EQU 1 ; Enables the player range enforcement, which is part of the sprite drawing routine.
                            ; Should only be used during gameplay, otherwise it could get in the way.
MISCB_TITLE_SECT      EQU 2 ; Allows parallax for the title screen

MISC_USE_SECT         EQU 1 << MISCB_USE_SECT
;--
; wPauseFlags
PFB_1P        EQU 0 ; Player 1 paused the game
PFB_2P        EQU 1 ; Player 2 paused the game


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
OSTB_PL      EQU 0 ; ??? If the sprite mapping doesn't use the GFX buffer (ie: projectiles), it instead marks the player who spawned it (PLB1 or PLB2).
OSTB_GFXBUF2 EQU 1 ; If set, the second GFX buffer is used for the *current* frame
OSTB_BIT3    EQU 3 ; 
OSTB_ANIMEND EQU 4 ; Animation has ended, repeat last frame indefinitely
OSTB_XFLIP   EQU 5 ; Horizontal flip
OSTB_YFLIP   EQU 6 ; Vertical flip
OSTB_VISIBLE EQU 7 ; If not set, the sprite mapping is hidden

OST_GFXLOAD EQU 1 << OSTB_GFXLOAD
OST_PL      EQU 1 << OSTB_PL
OST_GFXBUF2 EQU 1 << OSTB_GFXBUF2
OST_BIT3    EQU 1 << OSTB_BIT3
OST_ANIMEND EQU 1 << OSTB_ANIMEND
OST_XFLIP   EQU 1 << OSTB_XFLIP
OST_YFLIP   EQU 1 << OSTB_YFLIP
OST_VISIBLE EQU 1 << OSTB_VISIBLE

; Additional iOBJInfo_OBJLstFlags for internal purposes.
; These aren't related to the hardware flags.
SPRXB_BIT0 EQU 0
SPRXB_BIT1 EQU 1
SPRXB_OTHERPROJR EQU 2 ; If set, the other player's projectile is on the right
SPRXB_PLDIR_R EQU 3 ; If set, the player is internally facing right (nonvisual equivalent of the X flip flag)


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

; iOBJInfo_Proj_HitMode
PHM_NONE EQU $00
PHM_REMOVE EQU $01
PHM_REFLECT EQU $02


TASK_SIZE EQU $08

; Task types
TASK_EXEC_NONE EQU $00 ; No task here
TASK_EXEC_DONE EQU $01 ; Already executed this frame
TASK_EXEC_CUR  EQU $02 ; Currently executing
TASK_EXEC_TODO EQU $04 ; Not executed yet, but was executed previously already. Stack pointer type.
TASK_EXEC_NEW  EQU $08 ; Never executed before. Likely init code which will set a new task. Jump HL type.

PLINFO_SIZE EQU $100
; iPlInfo_Status flags
PSB_PROJ         EQU 0 ; If set, a projectile is active on-screen (ie: a new one can't be thrown)
PSB_SPECMOVE     EQU 1 ; If set, the player is performing a special move
PSB_AIR          EQU 2 ; If set, the player is in the air
PSB_FARHIT       EQU 3 ; If set, the player got hit without physical contact from the other player (ie: by a projectile)
PSB_PROJREM      EQU 4 ; If set, the player can currently remove projectiles with its hitbox
PSB_PROJREFLECT  EQU 5 ; If set, the player can currently reflect projectiles with its hitbox
PSB_SUPERMOVE    EQU 6 ; If set, the player is performing a super move
PSB_CPU          EQU 7 ; If set, the player is CPU-controlled (1P mode) or autopicks characters (VS mode)


PS_PROJ        EQU 1 << PSB_PROJ
PS_SPECMOVE    EQU 1 << PSB_SPECMOVE
PS_PROJREM     EQU 1 << PSB_PROJREM
PS_PROJREFLECT EQU 1 << PSB_PROJREFLECT
PS_SUPERMOVE   EQU 1 << PSB_SUPERMOVE
PS_CPU         EQU 1 << PSB_CPU



; iPlInfo_21Flags flags
PI21B_NOBASICINPUT   EQU 0 ; Prevents basic input from being handled. See also: BasicInput_ChkDDDDDDDDD
PI21B_XFLIPLOCK      EQU 1 ; Locks the direction the player is facing
PI21B_NOSPECSTART    EQU 2 ; If set, the current move can't be cancelled into a new special.
                           ; Primarily used to prevent starting new specials during certain non-special moves (rolling, taking damage, ...)+
                           ; though starting specials also sets this for consistency.
                           ; Overridden by PI21B_ALLOWHITCANCEL.
PI21B_GUARD          EQU 3 ; If set, the player is guarding, and will receive less damage on hit.
                           ; Primarily set when blocking, but some special moves set this as well to have the same effects as blocking when getting hit out of them.
PI21B_COMBORECV      EQU 4 ; If set, the player is on the receiving end of a damage string.
                           ; This is set when the player is attacked at least once (hit or blocked), and
                           ; resets on its own if not cancelling the attack into one that hits.
PI21B_CROUCH         EQU 5 ; If set, the player is crouching
PI21B_ALLOWHITCANCEL EQU 6 ; If set, it's possible to cancel the move into a new special, usually after hitting the opponent. This still needs to pass the special cancelling check,
PI21B_INVULN         EQU 7 ; If set, the player is completely invulnerable. 
						   ; This value isn't always checked during collision -- phyisical hurtbox collisions pass,
						   ; but they are blocked before they can deal damage.

; iPlInfo_22Flags flags
PI22B_MOVESTART      EQU 0 ; Marks that a new move has been set
PI22B_HEAVY          EQU 1 ; Used to distinguish between light/heavy when starting an attack ?????
PI22B_HITCOMBO       EQU 2 ; If set, the current move was combo'd from another.
PI22B_AUTOGUARDDONE  EQU 3 ; If set, the autoguard triggered on this frame
PI22B_AUTOGUARDLOW   EQU 4 ; If set, the move automatically blocks lows
PI22B_AUTOGUARDMID   EQU 5 ; If set, the move automatically blocks mids
PI22B_NOHURTBOX      EQU 6 ; If set, the player has no hurtbox (this separate from the collision box only here)
PI22B_NOCOLIBOX      EQU 7 ; If set, the player has no collision box


; Flags for iPlInfo_23Flags, related to the move we got attacked with
PI23B_SHAKELONG     EQU 0 ; Getting attacked shakes the player longer (doesn't cut the shake count in half)
PI23B_FLASH_B_SLOW  EQU 1 ; Getting hit causes the player to flash slowly
PI23B_HITMID        EQU 2 ; The attack hits medium (must block standing)
PI23B_HITLOW        EQU 3 ; The attack hits low (must block crouching)
PI23B_FLASH_B_FAST  EQU 6 ; Getting hit causes the player to flash fast
PI23B_SHAKEONCE     EQU 7 ; Getting attacked shakes the player once

; Flags for iPlInfo_JoyNewKeysLH in the upper nybble
; (low nybble is the same as KEYB_*)
KEPB_A_LIGHT EQU 4 ; A button pressed and released before 6 frames
KEPB_B_LIGHT EQU 5 ; B button pressed and released before 6 frames
KEPB_A_HEAVY EQU 6 ; A button held for 6 frames
KEPB_B_HEAVY EQU 7 ; B button held for 6 frames
KEP_A_LIGHT EQU 1 << KEPB_A_LIGHT
KEP_B_LIGHT EQU 1 << KEPB_B_LIGHT
KEP_A_HEAVY EQU 1 << KEPB_A_HEAVY
KEP_B_HEAVY EQU 1 << KEPB_B_HEAVY

; Flags for iPlInfo_ColiFlags
; One half is for our collision status, the other is for the opponent.

; TODO: RECV / SEND -> "" / OTHER
PCF_SENDPUSH    EQU 0 ; Player pushed another
PCF_SENDHIT     EQU 1 ; Player hit the other
PCF_SENDPROJHIT EQU 2 ; Player hit the other with a projectile
PCF_RECVPROJREM EQU 3 ; Player has its projectile removed/reflected by the other player
PCF_RECVPUSH    EQU 4 ; Player is being pushed
PCF_RECVHIT     EQU 5 ; Player is hit
PCF_RECVPROJHIT EQU 6 ; Player is by a projectile
PCF_SENDPROJREM EQU 7 ; Player removes/reflect the other player's projectile



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
SCT_TAUNT_A                EQU $02
SCT_TAUNT_B                EQU $03
SCT_TAUNT_C                EQU $04
SCT_TAUNT_D                EQU $05
SCT_CHARGEMETER                EQU $06
SCT_MAXPOWSTART       EQU $07
SCT_07                EQU $08
SCT_HEAVY                EQU $09
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
SCT_14                EQU $15
SCT_15                EQU $16
SCT_16                EQU $17
SCT_17                EQU $18
SCT_18                EQU $19
SCT_19                EQU $1A
SCT_THROW                EQU $1B
SCT_THROWTECH                EQU $1C
SCT_1C                EQU $1D

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

; ============================================================
; GAMEPLAY

MOVE_SHARED_NONE EQU $00
MOVE_SHARED_IDLE EQU $02 ; Stand
MOVE_SHARED_WALK_F EQU $04 ; Walk forward
MOVE_SHARED_WALK_B EQU $06 ; Walk back
MOVE_SHARED_CROUCH EQU $08 ; Crouch
MOVE_SHARED_JUMP_N EQU $0A ; Neutral jump
MOVE_SHARED_JUMP_F EQU $0C ; forward jump
MOVE_SHARED_JUMP_B EQU $0E ; Backwards jump
MOVE_SHARED_BLOCK_G EQU $10 ; Ground block / mid
MOVE_SHARED_BLOCK_C EQU $12 ; Crouch block / low
MOVE_SHARED_BLOCK_A EQU $14 ; Air block
MOVE_SHARED_DASH_F EQU $16 ; Run forward
MOVE_SHARED_DASH_B EQU $18 ; Hop back
MOVE_SHARED_CHARGEMETER EQU $1A ; Charge meter
MOVE_SHARED_TAUNT EQU $1C ; Taunt
MOVE_SHARED_ROLL_F EQU $1E ; Roll forward
MOVE_SHARED_ROLL_B EQU $20 ; Roll back
MOVE_SHARED_WAKEUP EQU $22 ; Get up
MOVE_SHARED_DIZZY EQU $24 ; Dizzy
MOVE_SHARED_WIN_NORM EQU $26
MOVE_SHARED_WIN_ALT EQU $28
MOVE_SHARED_LOST_TIMEOVER EQU $2A
MOVE_SHARED_INTRO EQU $2C
MOVE_SHARED_INTRO_SPEC EQU $2E

; Basic attacks
MOVE_SHARED_PUNCH_L EQU $30 ; Light punch
MOVE_SHARED_PUNCH_H EQU $32 ; Heavy punch
MOVE_SHARED_KICK_L EQU $34 ; Light kick
MOVE_SHARED_KICK_H EQU $36 ; Heavy kick
MOVE_SHARED_PUNCH_CL EQU $38 ; Crouch punch light
MOVE_SHARED_PUNCH_CH EQU $3A ; Crouch punch heavy
MOVE_SHARED_KICK_CL EQU $3C ; Crouch kick light
MOVE_SHARED_KICK_CH EQU $3E ; Crouch kick heavy
MOVE_SHARED_ATTACK_G EQU $40 ; Ground A + B 
MOVE_SHARED_PUNCH_A EQU $34 ; Air punch
MOVE_SHARED_KICK_A EQU $36 ; Air kick
MOVE_SHARED_ATTACK_A EQU $40 ; Air A + B

MOVE_SPECIAL_START EQU $64

MOVE_SHARED_THROW_6C EQU $6C
MOVE_SHARED_THROW_6E EQU $6E
MOVE_SHARED_THROWTECH_RECV EQU $72

; Character-specific
MOVE_KYO_SHIKI_ARA_KAMI_L EQU $48
MOVE_KYO_SHIKI_ARA_KAMI_H EQU $4A
MOVE_KYO_SHIKI_ONIYAKI_L  EQU $4C
MOVE_KYO_SHIKI_ONIYAKI_H  EQU $4E
MOVE_KYO_RED_KICK_L EQU $50
MOVE_KYO_RED_KICK_H EQU $52
MOVE_KYO_SHIKI_KOTOTSUKI_YOU_L EQU $54
MOVE_KYO_SHIKI_KOTOTSUKI_YOU_H EQU $56
MOVE_KYO_SHIKI_KAI_L EQU $58
MOVE_KYO_SHIKI_KAI_H EQU $5A
MOVE_KYO_SHIKI_NUE_TUMI_L EQU $5C
MOVE_KYO_SHIKI_NUE_TUMI_H EQU $5E
MOVE_KYO_URA_SHIKI_OROCHINAGI_S EQU $64 ; Super
MOVE_KYO_URA_SHIKI_OROCHINAGI_D EQU $66 ; Desperation super


MOVE_CHIZURU_64 EQU $64 ; Super
MOVE_CHIZURU_66 EQU $66 ; Desperation super

MOVE_FF EQU $FF


HITANIM_BLOCKED EQU $00 ; Nothing happens
HITANIM_GUARDBREAK_GROUND EQU $01
HITANIM_GUARDBREAK_AIR EQU $02
HITANIM_HIT0_MID EQU $03 ; Punch
HITANIM_HIT1_MID EQU $04 ; Kick... but some punches too
HITANIM_HIT_LOW EQU $05 ; Punched or kicked while crouching
HITANIM_DROP_SM EQU $06 ; Small drop
HITANIM_DROP_SM_REC EQU $07 ; Small drop with recovery (Air only?)
HITANIM_DROP_MD EQU $08 ; Standard drop without recovery

; Used by certain special moves
HITANIM_HIT_SPEC_09 EQU $09
HITANIM_HIT_SPEC_0A EQU $0A
HITANIM_HIT_SPEC_0B EQU $0B
HITANIM_DROP_SPEC_0C EQU $0C ; Air throw directly to ground?
HITANIM_DROP_SPEC_0C_GROUND EQU $0D ; Drop to ground with shake
HITANIM_DROP_SPEC_AIR_0E EQU $0E ; Jump up then drop to ground with shake (Air throw?)

HITANIM_DROP_SPEC_0F EQU $0F ; Large drop which causes the ground to shake. Used as end of the throw??
HITANIM_THROW_START EQU $10 ; Start of the throw anim
HITANIM_THROW_ROTU EQU $11 ; Throw rotation frame, head up
HITANIM_THROW_ROTL EQU $12 ; Throw rotation frame, head left
HITANIM_THROW_ROTD EQU $13 ; Throw rotation frame, head down
HITANIM_THROW_ROTR EQU $14 ; Throw rotation frame, head right

; wPlayPlThrowActId
PLAY_THROWACT_NONE EQU $00
PLAY_THROWACT_START EQU $01
PLAY_THROWACT_NEXT02 EQU $02
PLAY_THROWACT_NEXT03 EQU $03
PLAY_THROWACT_NEXT04 EQU $04

; wPlayPlThrowOpMode
PLAY_THROWOP_GROUND EQU $00 ; The throw works on players on the ground
PLAY_THROWOP_AIR EQU $01 ; The throw works on players in the air
PLAY_THROWOP_UNUSED_BOTH EQU $02 ; [TCRF] Unused, works on both.

; wPlayPlThrowDir
PLAY_THROWDIR_F EQU $00
PLAY_THROWDIR_B EQU $01

PLAY_HEALTH_CRITICAL EQU $18 ; Threshold for critical health (allow infinite super & desperation supers)
PL_FLOOR_POS EQU $88

PLAY_MAXMODE_NONE EQU $00
PLAY_MAXMODE_LENGTH1 EQU $01
PLAY_MAXMODE_LENGTH2 EQU $02
PLAY_MAXMODE_LENGTH3 EQU $03
PLAY_MAXMODE_LENGTH4 EQU $04
PLAY_MAXMODE_BASELENGTH EQU $04

PLAY_POW_EMPTY EQU $00
PLAY_POW_MAX EQU $28 ; Max value for normal POW bar


PLAY_MAXPOWFADE_NONE EQU $00
PLAY_MAXPOWFADE_IN EQU $01
PLAY_MAXPOWFADE_OUT EQU $FF


PLAY_PREROUND_OBJ_ROUNDX EQU $00
PLAY_PREROUND_OBJ_FINAL EQU $04
PLAY_PREROUND_OBJ_READY EQU $08
PLAY_PREROUND_OBJ_GO_SM EQU $0C
PLAY_PREROUND_OBJ_GO_LG EQU $10

PLAY_POSTROUND0_OBJ_KO       EQU $00
PLAY_POSTROUND0_OBJ_TIMEOVER EQU $04

PLAY_POSTROUND1_OBJ_DRAWGAME EQU $00
PLAY_POSTROUND1_OBJ_1PWON    EQU $04
PLAY_POSTROUND1_OBJ_2PWON    EQU $08
PLAY_POSTROUND1_OBJ_YOUWON   EQU $0C
PLAY_POSTROUND1_OBJ_YOULOST  EQU $10