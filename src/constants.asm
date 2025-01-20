; Keys (as bit numbers)
DEF KEYB_RIGHT       EQU 0
DEF KEYB_LEFT        EQU 1
DEF KEYB_UP          EQU 2
DEF KEYB_DOWN        EQU 3
DEF KEYB_A           EQU 4
DEF KEYB_B           EQU 5
DEF KEYB_SELECT      EQU 6
DEF KEYB_START       EQU 7

; Keys (values)
DEF KEY_NONE         EQU 0
DEF KEY_RIGHT        EQU 1 << KEYB_RIGHT
DEF KEY_LEFT         EQU 1 << KEYB_LEFT
DEF KEY_UP           EQU 1 << KEYB_UP
DEF KEY_DOWN         EQU 1 << KEYB_DOWN
DEF KEY_A            EQU 1 << KEYB_A
DEF KEY_B            EQU 1 << KEYB_B
DEF KEY_SELECT       EQU 1 << KEYB_SELECT
DEF KEY_START        EQU 1 << KEYB_START

; Flags for iPlInfo_JoyNewKeysLH in the upper nybble
; (low nybble is the same as KEYB_*)
DEF KEPB_A_LIGHT EQU 4 ; A button pressed and released before 6 frames
DEF KEPB_B_LIGHT EQU 5 ; B button pressed and released before 6 frames
DEF KEPB_A_HEAVY EQU 6 ; A button held for 6 frames
DEF KEPB_B_HEAVY EQU 7 ; B button held for 6 frames
DEF KEP_A_LIGHT EQU 1 << KEPB_A_LIGHT
DEF KEP_B_LIGHT EQU 1 << KEPB_B_LIGHT
DEF KEP_A_HEAVY EQU 1 << KEPB_A_HEAVY
DEF KEP_B_HEAVY EQU 1 << KEPB_B_HEAVY

DEF CMLB_BTN EQU 0 ; For iCPUMoveListItem_LastLHKeyA. 
                   ; If set, the MoveInput iCPUMoveListItem_MoveInputPtr points to contains button (LH) keys.
                   ; If clear, it contains directional keys.
DEF CML_BTN EQU 1 << CMLB_BTN

; CPU idle actions
DEF CMA_MOVEF  EQU $00 ; Move or run forwads
DEF CMA_MOVEB  EQU $01 ; Move or hop backwards
DEF CMA_CHARGE EQU $02 ; Charge meter
DEF CMA_NONE   EQU $FF ; Nothing. Player stands still.

DEF DIFFICULTY_EASY		EQU $00
DEF DIFFICULTY_NORMAL	EQU $01
DEF DIFFICULTY_HARD		EQU $02

DEF BORDER_NONE			EQU $00
DEF BORDER_MAIN 		EQU $01
DEF BORDER_ALTERNATE 	EQU $02

DEF TIMER_INFINITE		EQU $FF

DEF MODEB_TEAM    EQU 0
DEF MODEB_VS      EQU 1
DEF MODE_SINGLE1P EQU $00
DEF MODE_TEAM1P   EQU $01
DEF MODE_SINGLEVS EQU $02
DEF MODE_TEAMVS   EQU $03

; Player IDs used across multiple variables
DEF PL1  EQU $00		
DEF PL2  EQU $01
DEF PLB1 EQU 0 ; $01
DEF PLB2 EQU 1 ; $02

; Character IDs
; [POI] These are grouped by team, not like it matters.
DEF CHAR_ID_KYO      EQU $00
DEF CHAR_ID_DAIMON   EQU $02
DEF CHAR_ID_TERRY    EQU $04
DEF CHAR_ID_ANDY     EQU $06
DEF CHAR_ID_RYO      EQU $08
DEF CHAR_ID_ROBERT   EQU $0A
DEF CHAR_ID_ATHENA   EQU $0C
DEF CHAR_ID_MAI      EQU $0E
DEF CHAR_ID_LEONA    EQU $10
DEF CHAR_ID_GEESE    EQU $12
DEF CHAR_ID_KRAUSER  EQU $14
DEF CHAR_ID_MRBIG    EQU $16
DEF CHAR_ID_IORI     EQU $18
DEF CHAR_ID_MATURE   EQU $1A
DEF CHAR_ID_CHIZURU  EQU $1C
DEF CHAR_ID_GOENITZ  EQU $1E
DEF CHAR_ID_MRKARATE EQU $20
DEF CHAR_ID_OIORI    EQU $22
DEF CHAR_ID_OLEONA   EQU $24
DEF CHAR_ID_KAGURA   EQU $26
DEF CHAR_ID_NONE     EQU $FF

DEF STAGE_ID_HERO             EQU $00
DEF STAGE_ID_FATALFURY        EQU $01
DEF STAGE_ID_YAGAMI           EQU $02
DEF STAGE_ID_BOSS             EQU $03
DEF STAGE_ID_STADIUM_KAGURA   EQU $04
DEF STAGE_ID_STADIUM_GOENITZ  EQU $05
DEF STAGE_ID_STADIUM_EXTRA    EQU $06

; Special hardcoded stages for bosses or secrets.
; These are special indexes to wCharSeqTbl that return CHAR_ID_* instead of CHARSEL_ID_*
DEF STAGESEQ_KAGURA   EQU $0F
DEF STAGESEQ_GOENITZ  EQU $10
DEF STAGESEQ_BONUS    EQU $11
DEF STAGESEQ_MRKARATE EQU $12

; Special Teams
DEF TEAM_ID_SACTREAS  EQU $01 ; Iori, Kyo and Chizuru
DEF TEAM_ID_OLEONA    EQU $02 ; Leona, Iori, and Mature
DEF TEAM_ID_FFGEESE   EQU $03 ; Terry, Andy and Geese
DEF TEAM_ID_AOFMRBIG  EQU $04 ; Ryo, Robert and Mr.Big
DEF TEAM_ID_KTR       EQU $05 ; Kyo, Terry and Ryo
DEF TEAM_ID_BOSS      EQU $06 ; Geese, Krauser and Mr.Big
DEF TEAM_ID_NONE      EQU $FF

; Bonus Fight Type ID (wBonusFightId)
; Each of these has its own team character definitions.
DEF BONUS_ID_I_KC     EQU $00 ; Iori vs Kyo and Chizuru
DEF BONUS_ID_KC_I     EQU $01 ; ...
DEF BONUS_ID_L_IM     EQU $02
DEF BONUS_ID_IM_L     EQU $03
DEF BONUS_ID_TA_G     EQU $04
DEF BONUS_ID_G_TA     EQU $05
DEF BONUS_ID_RR_B     EQU $06
DEF BONUS_ID_B_RR     EQU $07
DEF BONUS_ID_K_TR     EQU $08
DEF BONUS_ID_T_KR     EQU $09
DEF BONUS_ID_R_KT     EQU $0A
DEF BONUS_ID_G_KB     EQU $0B
DEF BONUS_ID_K_GB     EQU $0C
DEF BONUS_ID_B_GK     EQU $0D
DEF BONUS_ID_NONE     EQU $FF

DEF C_NL EQU $FF ; Newline character in strings

DEF PLAY_BORDER_X       EQU $08 ; Threshold value for being treated as being on the wall.
DEF OBJLSTPTR_NONE      EQU $FFFF ; Placeholder pointer that marks the lack of a secondary sprite mapping and the end separator
DEF OBJLSTPTR_ENTRYSIZE EQU $04 ; Size of each OBJLstPtrTable entry (pair of OBJLstHdrA_* and OBJLstHdrB_* pointers)
DEF ANIMSPEED_INSTANT   EQU $00 ; Close enough
DEF ANIMSPEED_NONE      EQU $FF ; Slowest possible animation speed, set when we want manual control over the animation since it will always be done quicker than 255 frames.

; FLAGS
DEF DIPB_EASY_MOVES       EQU 2 ; SELECT + A/B for easy super moves
DEF DIPB_POWERUP          EQU 3 ; DIPB_POWERUP Powerup mode. POW Meter grows on its own + Unlimited super moves + move changes
DEF DIPB_SGB_SOUND_TEST   EQU 4 ; Adds SGB S.E TEST to the options menu
DEF DIPB_TEAM_DUPL        EQU 5 ; Allow duplicate characters in a team
DEF DIPB_UNLOCK_BOSS      EQU 6 ; Unlock Goenitz
DEF DIPB_UNLOCK_OTHER     EQU 7 ; Unlock everyone else (Mr Karate, Boss Kagura, Orochi Iori and Orochi Leona)

; $C025
DEF MISCB_SERIAL_LAG      EQU 3 ; If set, it freezes the game. Essentially a version of MISCB_LAG_FRAME for the other GB.
                                ; Used to force the slave to wait (and not read new player inputs) until the master sends new bytes.
DEF MISCB_SERIAL_SLAVE    EQU 5 ; If set, the GB is the slave (matches PL2), otherwise it's the master (PL1)
DEF MISCB_SERIAL_MODE     EQU 6 ; Marks a VS battle through serial cable. Not in SGB mode.
DEF MISCB_IS_SGB          EQU 7 ; Enables SGB features
; $C026
DEF MISCB_LAG_FRAME       EQU 3 ; Is set when the task cycler is called, and unset right before the VBlank wait loop.
; $C027
DEF MISCB_PLAY_STOP       EQU 7 ; If set, the game stops processing input and the timer. Used on the intro and when a round ends.
; $C028
DEF MISCB_USE_SECT        EQU 0 ; If set, the screen uses the three-section mode (SetSectLYC was called). Otherwise there's a single section governed by hScrollX and hScrollY.
DEF MISCB_PL_RANGE_CHECK  EQU 1 ; Enables the player range enforcement, which is part of the sprite drawing routine.
                                ; Should only be used during gameplay, otherwise it could get in the way.
DEF MISCB_TITLE_SECT      EQU 2 ; Allows parallax for the title screen

DEF MISC_USE_SECT         EQU 1 << MISCB_USE_SECT
;--


; TextPrinter_MultiFrame options
DEF TXTB_PLAYSFX   EQU 0 ; Play SFX when printing a character
DEF TXTB_ALLOWFAST EQU 1 ; Allows pressing A to speedup text printing, or START to enable instant text printing (TXCB_INSTANT)
DEF TXTB_ALLOWSKIP EQU 2 ; Allows pressing START to end prematurely the text printing. Overrides TXTB_ALLOWFAST.

DEF TXT_PLAYSFX   EQU 1 << TXTB_PLAYSFX  
DEF TXT_ALLOWFAST EQU 1 << TXTB_ALLOWFAST
DEF TXT_ALLOWSKIP EQU 1 << TXTB_ALLOWSKIP


DEF TXCB_INSTANT EQU 7 ; If set, instant text printing was enabled
DEF TXB_NONE EQU $FF ; No custom code when waiting idle
;--


DEF OBJINFO_SIZE     EQU $40 ; wOBJInfo size
DEF GFXBUF_TILECOUNT EQU $20 ; Number of tiles in a GFX buffer

; iOBJInfo_Status bits
DEF OSTB_GFXLOAD    EQU 0 ; If set, the graphics are still being copied to the *opposite* buffer than the current one at OSTB_GFXBUF2
DEF OSTB_GFXBUF2    EQU 1 ; If set, the second GFX buffer is used for the *current* frame
DEF OSTB_GFXNEWLOAD EQU 3 ; If set, the graphics have just finished loading. Effectively valid for 1 frame only, since the animation routines resets it.
DEF OSTB_ANIMEND    EQU 4 ; Animation has ended, repeat last frame indefinitely
DEF OSTB_XFLIP      EQU 5 ; Horizontal flip
DEF OSTB_YFLIP      EQU 6 ; Vertical flip
DEF OSTB_VISIBLE    EQU 7 ; If not set, the sprite mapping is hidden

DEF OST_GFXLOAD     EQU 1 << OSTB_GFXLOAD
DEF OST_GFXBUF2     EQU 1 << OSTB_GFXBUF2
DEF OST_GFXNEWLOAD  EQU 1 << OSTB_GFXNEWLOAD
DEF OST_ANIMEND     EQU 1 << OSTB_ANIMEND
DEF OST_XFLIP       EQU 1 << OSTB_XFLIP
DEF OST_YFLIP       EQU 1 << OSTB_YFLIP
DEF OST_VISIBLE     EQU 1 << OSTB_VISIBLE

; Additional iOBJInfo_OBJLstFlags for internal purposes.
; These aren't related to the hardware flags.
DEF SPRXB_BIT0 EQU 0
DEF SPRXB_BIT1 EQU 1
DEF SPRXB_OTHERPROJR EQU 2 ; If set, the other player's projectile is on the right
DEF SPRXB_PLDIR_R EQU 3 ; If set, the player is internally facing right (nonvisual equivalent of the X flip flag)


; OBJLST / SPRITE MAPPINGS FLAGS from ROM
; These are almost the same as the iOBJInfo_OBJLstFlags* bits.
; iOBJLstHdrA_Flags / iOBJLstHdrB_Flags
DEF OLFB_USETILEFLAGS EQU 4 ; If set, in the OBJ data, the upper two bits of a tile ID count as X/Y flip flags
DEF OLFB_XFLIP        EQU 5 ; User-controlled
DEF OLFB_YFLIP        EQU 6
DEF OLFB_NOBUF        EQU 7 ; Sprite mapping doesn't use the buffer copy

DEF OLF_USETILEFLAGS EQU 1 << OLFB_USETILEFLAGS ; $10
DEF OLF_XFLIP        EQU 1 << OLFB_XFLIP ; $20
DEF OLF_YFLIP        EQU 1 << OLFB_YFLIP ; $40
DEF OLF_NOBUF        EQU 1 << OLFB_NOBUF

; Raw versions of the above from inside the ROM, which are shifted up before getting converted
DEF OLR_XFLIP EQU OLF_XFLIP << 1
DEF OLR_YFLIP EQU OLF_YFLIP << 1

; iOBJInfo_Play_HitMode
DEF PHM_NONE    EQU $00
DEF PHM_REMOVE  EQU $01
DEF PHM_REFLECT EQU $02


DEF TASK_SIZE EQU $08

; Task types
DEF TASK_EXEC_NONE EQU $00 ; No task here
DEF TASK_EXEC_DONE EQU $01 ; Already executed this frame
DEF TASK_EXEC_CUR  EQU $02 ; Currently executing
DEF TASK_EXEC_TODO EQU $04 ; Not executed yet, but was executed previously already. Stack pointer type.
DEF TASK_EXEC_NEW  EQU $08 ; Never executed before. Likely init code which will set a new task. Jump HL type.

DEF PLINFO_SIZE EQU $100

; Note that there isn't a single flag marking if we got hit and damaged.
; A combination of at least one of these is checked:
; PCFB_HIT -> opponent collided with our hitbox (the move can still whiff)
; PF1B_INVULN -> Invulnerability
; PF1B_HITRECV -> damage string, aka hit received (definitely no whiff)
; PF1B_GUARD -> blocked the hit
; Moves that manually check for collision tend to handle them like this, generally for
; attacks where the player moves forward until colliding with the player:
; - PCFB_HIT = 0 or PF1B_INVULN = 1 -> not hit yet
; - PF1B_HITRECV = 1 and PF1B_GUARD = 1 -> opponent blocked the attack (from last frame)
; - PF1B_HITRECV = 1 and PF1B_GUARD = 0 -> opponent got hit successfully (from last frame)

; iPlInfo_Flags0 flags
DEF PF0B_PROJ           EQU 0 ; If set, a projectile is active on-screen (ie: a new one can't be thrown)
DEF PF0B_SPECMOVE       EQU 1 ; If set, the player is performing a special move
DEF PF0B_AIR            EQU 2 ; If set, the player is in the air
DEF PF0B_PROJHIT        EQU 3 ; If set, the player got hit by a projectile
DEF PF0B_PROJREM        EQU 4 ; If set, the player can currently remove projectiles with its hitbox
DEF PF0B_PROJREFLECT    EQU 5 ; If set, the player can currently reflect projectiles with its hitbox
DEF PF0B_SUPERMOVE      EQU 6 ; If set, the player is performing a super move
DEF PF0B_CPU            EQU 7 ; If set, the player is CPU-controlled (1P mode) or autopicks characters (VS mode)
DEF PF0_SPECMOVE        EQU 1 << PF0B_SPECMOVE
DEF PF0_PROJREM         EQU 1 << PF0B_PROJREM
DEF PF0_PROJREFLECT     EQU 1 << PF0B_PROJREFLECT
DEF PF0_SUPERMOVE       EQU 1 << PF0B_SUPERMOVE
DEF PF0_CPU             EQU 1 << PF0B_CPU

; iPlInfo_Flags1 flags
DEF PF1B_NOBASICINPUT   EQU 0 ; Prevents basic input from being handled. See also: BasicInput_ChkDDDDDDDDD
DEF PF1B_XFLIPLOCK      EQU 1 ; Locks the direction the player is facing
DEF PF1B_NOSPECSTART    EQU 2 ; If set, the current move can't be cancelled into a new special.
                              ; Primarily used to prevent starting new specials during certain non-special moves (rolling, taking damage, ...)+
                              ; though starting specials also sets this for consistency.
                              ; Overridden by PF1B_ALLOWHITCANCEL.
DEF PF1B_GUARD          EQU 3 ; If set, the player is guarding, and will receive less damage on hit.
                              ; Primarily set when blocking, but some special moves set this as well to have the same effects as blocking when getting hit out of them.
DEF PF1B_HITRECV        EQU 4 ; If set, the player is on the receiving end of a damage string.
                              ; This is set when the player is attacked at least once (hit or blocked), and
                              ; resets on its own if not cancelling the attack into one that hits.
DEF PF1B_CROUCH         EQU 5 ; If set, the player is crouching
DEF PF1B_ALLOWHITCANCEL EQU 6 ; If set, it's possible to cancel a move into a new special, set after hitting the opponent. This bypasses PF1B_NOSPECSTART.
DEF PF1B_INVULN         EQU 7 ; If set, the player is completely invulnerable. 
                              ; This value isn't always checked during collision -- phyisical hurtbox collisions pass,
                              ; but they are blocked before they can deal damage.
; iPlInfo_Flags2 flags
DEF PF2B_MOVESTART      EQU 0 ; Marks that a new move has been set
DEF PF2B_HEAVY          EQU 1 ; To distinguish between light/heavy when starting an attack
DEF PF2B_NODAMAGERATE   EQU 2 ; [TCRF] Leftover from 95. If set, it would disable the damage rate limit, which is ignored in this game.
DEF PF2B_AUTOGUARDDONE  EQU 3 ; If set, the autoguard triggered on this frame
DEF PF2B_AUTOGUARDMID   EQU 4 ; If set, the move automatically blocks lows
DEF PF2B_AUTOGUARDLOW   EQU 5 ; If set, the move automatically blocks mids
DEF PF2B_NOHURTBOX      EQU 6 ; If set, the player has no hurtbox (this separate from the collision box only here)
DEF PF2B_NOCOLIBOX      EQU 7 ; If set, the player has no collision box
; iPlInfo_Flags3, related to the move we got attacked with
DEF PF3B_HEAVYHIT       EQU 0 ; Used by "heavy" hits (not to be confused with heavy moves). Getting attacked shakes the player longer (doesn't cut the shake count in half).
DEF PF3B_FIRE           EQU 1 ; Used by firey hits. Getting hit causes the player to flash slowly.
DEF PF3B_HITLOW         EQU 2 ; The attack hits low (must block crouching)
DEF PF3B_OVERHEAD       EQU 3 ; The attack is an overhead (must block standing)
DEF PF3B_CONTHIT        EQU 4 ; For HitTypeC_Drop* only. If set, the combo string can continue (can juggle), otherwise the opponent is made invulnerable until wakeup.
DEF PF3B_HALFSPEED      EQU 5 ; Getting hit runs the game at half speed
DEF PF3B_SUPERALT       EQU 6 ; Used by a few super moves to make them use an alternate palette cycle.
DEF PF3B_LIGHTHIT       EQU 7 ; Used by "light" hits (not to be confused with light moves). Getting attacked shakes the player once.

DEF PF3_HEAVYHIT        EQU 1 << PF3B_HEAVYHIT   
DEF PF3_FIRE            EQU 1 << PF3B_FIRE
DEF PF3_HITLOW          EQU 1 << PF3B_HITLOW      
DEF PF3_OVERHEAD        EQU 1 << PF3B_OVERHEAD      
DEF PF3_CONTHIT         EQU 1 << PF3B_CONTHIT        
DEF PF3_HALFSPEED       EQU 1 << PF3B_HALFSPEED        
DEF PF3_SUPERALT        EQU 1 << PF3B_SUPERALT
DEF PF3_LIGHTHIT        EQU 1 << PF3B_LIGHTHIT   

; Flags for iPlInfo_ColiFlags
; One half is for our collision status, the other is for the opponent.

DEF PCFB_PUSHED       EQU 0 ; Player is being pushed 
DEF PCFB_HITOTHER     EQU 1 ; The other player got hit (hitbox collided, though it can't be used alone as the opponent may be invulnerable)
DEF PCFB_PROJHITOTHER EQU 2 ; The other player got hit by a projectile
DEF PCFB_PROJREMOTHER EQU 3 ; The other player removed/reflected a projectile
DEF PCFB_PUSHEDOTHER  EQU 4 ; The other player is being pushed
DEF PCFB_HIT          EQU 5 ; Player is hit by a physical attack (hitbox collided, though it can't be used alone as the player may be invulnerable)
DEF PCFB_PROJHIT      EQU 6 ; Player is by a projectile
DEF PCFB_PROJREM      EQU 7 ; Player removed/reflected a projectile

; Sound Driver

DEF SNDIDREQ_SIZE      EQU $08
DEF SNDINFO_SIZE       EQU $20 ; Size of iSndInfo struct
DEF SND_CH1_PTR        EQU LOW(rNR13)
DEF SND_CH2_PTR        EQU LOW(rNR23)
DEF SND_CH3_PTR        EQU LOW(rNR33)
DEF SND_CH4_PTR        EQU LOW(rNR43)
DEF SNDLEN_INFINITE    EQU $FF

; wSnd_Unused_SfxPriority
DEF SNPB_SFXMULTI         EQU 7 ; An high-priority multi-channel SFX is playing
DEF SNPB_SFX4             EQU 6 ; An high-priority SFX4 is playing
DEF SNP_SFXMULTI          EQU 1 << SNPB_SFXMULTI
DEF SNP_SFX4              EQU 1 << SNPB_SFX4

; iSndInfo_Status
DEF SISB_PAUSE            EQU 0 ; If set, iSndInfo processing is paused for that channel
DEF SISB_LOCKNRx2         EQU 1 ; If set, rNR*2 won't be updated
DEF SISB_USEDBYSFX        EQU 2 ; wBGMCh*Info only. If set, it marks that a sound effect is currently using the channel.
DEF SISB_SFX              EQU 3 ; If set, the SndInfo is handled as a sound effect. If clear, it's a BGM.
DEF SISB_VIBRATO          EQU 6 ; [TCRF] Unimplemented. In later versions, if set, vibrato is enabled for that channel.
DEF SISB_ENABLED          EQU 7 ; If set, iSndInfo processing is enabled for that channel

DEF SIS_PAUSE             EQU 1 << SISB_PAUSE
DEF SIS_LOCKNRx2          EQU 1 << SISB_LOCKNRx2    
DEF SIS_USEDBYSFX         EQU 1 << SISB_USEDBYSFX   
DEF SIS_SFX               EQU 1 << SISB_SFX         
DEF SIS_VIBRATO           EQU 1 << SISB_VIBRATO
DEF SIS_ENABLED           EQU 1 << SISB_ENABLED

DEF SNDCMD_FADEIN         EQU $10
DEF SNDCMD_FADEOUT        EQU $20
DEF SNDCMD_CH1VOL         EQU $30
DEF SNDCMD_CH2VOL         EQU $40
DEF SNDCMD_CH3VOL         EQU $50
DEF SNDCMD_CH4VOL         EQU $60
DEF SNDCMD_BASE           EQU $E0
DEF SNDNOTE_BASE          EQU $80

; Notes (note)
DEF C_                    EQU 0
DEF C#                    EQU 1
DEF D_                    EQU 2
DEF D#                    EQU 3
DEF E_                    EQU 4
DEF F_                    EQU 5
DEF F#                    EQU 6
DEF G_                    EQU 7
DEF G#                    EQU 8
DEF A_                    EQU 9
DEF A#                    EQU 10
DEF B_                    EQU 11

;--------------

; DMG Sound List
DEF SND_MUTE              EQU $00
DEF SND_BASE              EQU $80
DEF SND_NONE              EQU SND_BASE+$00
DEF BGM_CHARSELECT        EQU SND_BASE+$01
DEF BGM_STAGECLEAR        EQU SND_BASE+$02
DEF BGM_BIGSHOT           EQU SND_BASE+$03
DEF BGM_ESAKA             EQU SND_BASE+$04
DEF BGM_CREDITS           EQU SND_BASE+$05
DEF BGM_GEESE             EQU SND_BASE+$06
DEF BGM_ARASHI            EQU SND_BASE+$07
DEF BGM_KAGURA            EQU SND_BASE+$08
DEF BGM_GOENITZ           EQU SND_BASE+$09
DEF BGM_GOENITZCUTSCENE   EQU SND_BASE+$0A
DEF BGM_ENDING            EQU SND_BASE+$0B
DEF SNC_PAUSE             EQU SND_BASE+$0C
DEF SNC_UNPAUSE           EQU SND_BASE+$0D
DEF SFX_CURSORMOVE        EQU SND_BASE+$0E
DEF SFX_CHARSELECTED      EQU SND_BASE+$0F
DEF SFX_CHARGEMETER       EQU SND_BASE+$10
DEF SFX_SUPERMOVE         EQU SND_BASE+$11
DEF SFX_LIGHT             EQU SND_BASE+$12
DEF SFX_HEAVY             EQU SND_BASE+$13
DEF SFX_BLOCK             EQU SND_BASE+$14
DEF SFX_TAUNT             EQU SND_BASE+$15
DEF SFX_HIT               EQU SND_BASE+$16
DEF SFX_MULTIHIT          EQU SND_BASE+$17
DEF BGM_KAGURACUTSCENE    EQU SND_BASE+$18
DEF BGM_MRKARATE          EQU SND_BASE+$19
DEF SFX_GROUNDHIT         EQU SND_BASE+$1A
DEF SFX_DROP              EQU SND_BASE+$1B
DEF SFX_SUPERJUMP         EQU SND_BASE+$1C
DEF SFX_STEP              EQU SND_BASE+$1D
DEF BGM_INTRO             EQU SND_BASE+$1E
DEF BGM_MRKARATECUTSCENE  EQU SND_BASE+$1F
;DEF SND_ID_20            EQU SND_BASE+$20
;DEF SND_ID_21            EQU SND_BASE+$21
;DEF SND_ID_22            EQU SND_BASE+$22
;DEF SND_ID_23            EQU SND_BASE+$23
;DEF SND_ID_24            EQU SND_BASE+$24
;DEF SND_ID_25            EQU SND_BASE+$25
DEF SFX_STEP_HEAVY        EQU SND_BASE+$26
DEF SFX_GRAB              EQU SND_BASE+$27
DEF SFX_FIREHIT_A         EQU SND_BASE+$28
DEF SFX_FIREHIT_B         EQU SND_BASE+$29
DEF SFX_MOVEJUMP_A        EQU SND_BASE+$2A
DEF SFX_PROJ_SM           EQU SND_BASE+$2B
DEF SFX_MOVEJUMP_B        EQU SND_BASE+$2C
DEF SFX_REFLECT           EQU SND_BASE+$2D
DEF SFX_UNUSED_SIREN      EQU SND_BASE+$2E ; [TCRF] Not used by anything, only playable in the sound test.
DEF SFX_UNUSED_NULL       EQU SND_BASE+$2F ; [TCRF] Not used by anything, only playable in the sound test.
DEF SFX_PSYCTEL           EQU SND_BASE+$30
DEF SFX_GAMEOVER          EQU SND_BASE+$31
;DEF SND_ID_32            EQU SND_BASE+$32
;DEF SND_ID_33            EQU SND_BASE+$33
DEF SND_LAST_VALID        EQU SND_BASE+$45 ; Dunno why this late

; Sound Action List (offset by 1, since $00 is handled as SND_NONE) 
DEF SCT_DIZZY             EQU $01 ; Dizzy effect
DEF SCT_TAUNT_A           EQU $02 ; The four taunts sound the same on the DMG, but different on the SGB
DEF SCT_TAUNT_B           EQU $03 ; ""
DEF SCT_TAUNT_C           EQU $04 ; ""
DEF SCT_TAUNT_D           EQU $05 ; ""
DEF SCT_CHARGEMETER       EQU $06 ; Charging meter
DEF SCT_CHARGEFULL        EQU $07 ; Meter fully charged
DEF SCT_LIGHT             EQU $08 ; Generic light attack
DEF SCT_HEAVY             EQU $09 ; Generic heavy attack
DEF SCT_BLOCK             EQU $0A ; Blocking
DEF SCT_HIT               EQU $0B ; Generic hit
DEF SCT_MULTIHIT          EQU $0C ; In-between hits for move that hit multiple times
DEF SCT_AUTOBLOCK         EQU $0D ; Blocking during specials (autoguard)
DEF SCT_GROUNDHIT         EQU $0E ; Hitting the ground and rebounding off it
DEF SCT_REFLECT           EQU $0F ; Projectile reflected
DEF SCT_PROJ_SM           EQU $10 ; Medium Projectile thrown
DEF SCT_MOVEJUMP_A        EQU $11 ; Automatic jump as part of a special move
DEF SCT_MOVEJUMP_B        EQU $12 ; ""
DEF SCT_FIREHIT           EQU $13 ; Hit with PF3B_FIRE
DEF SCT_PROJ_LG_A         EQU $14 ; Large projectile spawned
DEF SCT_PHYSFIRE          EQU $15 ; Phyisical fire atttack
DEF SCT_PROJ_LG_B         EQU $16 ; Large projectile spawned
DEF SCT_UNUSED_16         EQU $17 ; Heavy attack #2
DEF SCT_SHCRYSTSPAWN      EQU $18 ; Shining Crystal Bit projectile spawned
DEF SCT_PSYCREFLAND       EQU $19 ; Landing from the jump during an heavy Psycho Reflector
DEF SCT_HISHOKEN          EQU $1A ; Andy's Hi Sho Ken move
DEF SCT_GRAB              EQU $1B ; Grab started
DEF SCT_BREAK             EQU $1C ; Guard break, throw tech
DEF SCT_PSYCTEL           EQU $1D ; Oval effect spawned during Athena's Psycho Teleport

; Screen Palette IDs, passed to SGB_ApplyScreenPalSet 
DEF SCRPAL_INTRO           EQU $00
DEF SCRPAL_TAKARALOGO      EQU $01
DEF SCRPAL_TITLE           EQU $02
DEF SCRPAL_CHARSELECT      EQU $03
DEF SCRPAL_ORDERSELECT     EQU $04
DEF SCRPAL_STAGECLEAR      EQU $05
DEF SCRPAL_STAGE_HERO      EQU $06
DEF SCRPAL_STAGE_FATALFURY EQU $07
DEF SCRPAL_STAGE_YAGAMI    EQU $08
DEF SCRPAL_STAGE_BOSS      EQU $09
DEF SCRPAL_STAGE_STADIUM   EQU $0A
IF REV_LOGO_EN == 1
DEF SCRPAL_LAGUNALOGO      EQU $0B
ENDC
;
; MODE IDs & CONSTANTS
;

; ============================================================
; INTRO

DEF GM_INTRO_TEXTPRINT       EQU $00
DEF GM_INTRO_CHAR            EQU $02
DEF GM_INTRO_IORIRISE        EQU $04
DEF GM_INTRO_IORIKYO         EQU $06

DEF INTRO_SCENE_INIT         EQU $00
DEF INTRO_SCENE_TERRY        EQU $02
DEF INTRO_SCENE_ANDY         EQU $04
DEF INTRO_SCENE_MAI          EQU $06
DEF INTRO_SCENE_ATHENA       EQU $08
DEF INTRO_SCENE_LEONA        EQU $0A
DEF INTRO_SCENE_ROBERT       EQU $0C
DEF INTRO_SCENE_RYO          EQU $0E
DEF INTRO_SCENE_MRKARATE     EQU $10
DEF INTRO_SCENE_MRBIG        EQU $12
DEF INTRO_SCENE_GEESE        EQU $14
DEF INTRO_SCENE_KRAUSER      EQU $16
DEF INTRO_SCENE_DAIMON       EQU $18
DEF INTRO_SCENE_MATURE       EQU $1A
DEF INTRO_SCENE_CHG_IORIRISE EQU $1C
DEF INTRO_SCENE_KYO          EQU $1E
DEF INTRO_SCENE_IORIKYOA     EQU $20
DEF INTRO_SCENE_IORIKYOB     EQU $22
DEF INTRO_SCENE_IORIKYOC     EQU $24
DEF INTRO_SCENE_CHG_IORIKYO  EQU $26

DEF TILE_INTRO_WHITE         EQU $00
DEF TILE_INTRO_BLACK         EQU $01

DEF INTRO_OBJ_IORIH          EQU $00
DEF INTRO_OBJ_IORIL          EQU $01

; ============================================================
; TITLE SCREEN / MENUS

DEF GM_TITLE_TITLE          EQU $00
DEF GM_TITLE_TITLEMENU      EQU $02 
DEF GM_TITLE_MODESELECT     EQU $04
DEF GM_TITLE_OPTIONS        EQU $06

; SHARED
DEF TITLE_OBJ_PUSHSTART     EQU $00
DEF TITLE_OBJ_MENU          EQU $01
DEF TITLE_OBJ_CURSOR_R      EQU $02
DEF TITLE_OBJ_SNKCOPYRIGHT  EQU $03
DEF TITLE_OBJ_CURSOR_U      EQU $04

; TITLE
DEF TITLE_RESET_TIMER       EQU (30 << 8) | 60 ; 30 seconds

; TITLEMENU
DEF TITLEMENU_TO_TITLE      EQU $00
DEF TITLEMENU_TO_MODESELECT EQU $01
DEF TITLEMENU_TO_OPTIONS    EQU $02

; MODESELECT
DEF MODESELECT_ACT_EXIT     EQU $00
DEF MODESELECT_ACT_SINGLE1P EQU MODE_SINGLE1P+1
DEF MODESELECT_ACT_TEAM1P   EQU MODE_TEAM1P+1
DEF MODESELECT_ACT_SINGLEVS EQU MODE_SINGLEVS+1
DEF MODESELECT_ACT_TEAMVS   EQU MODE_TEAMVS+1

; Mode IDs sent out through the serial
DEF MODESELECT_SBCMD_IDLE     EQU $02
DEF MODESELECT_SBCMD_SINGLEVS EQU MODESELECT_ACT_SINGLEVS
DEF MODESELECT_SBCMD_TEAMVS   EQU MODESELECT_ACT_TEAMVS

; Implementation detail leads to this
DEF SERIAL_PL1_ID             EQU MODESELECT_SBCMD_IDLE
; SERIAL_PL2_ID is not a constant, but any val != $00 && != $02

; OPTIONS

; Main options
DEF OPTION_ITEM_TIME        EQU $00
DEF OPTION_ITEM_LEVEL       EQU $01
DEF OPTION_ITEM_BGMTEST     EQU $02
DEF OPTION_ITEM_SFXTEST     EQU $03
DEF OPTION_ITEM_SGBSNDTEST  EQU $04
DEF OPTION_ITEM_EXIT        EQU $05

; SGB sound test options
DEF OPTION_SITEM_ID_A       EQU $00
DEF OPTION_SITEM_BANK_A     EQU $01
DEF OPTION_SITEM_ID_B       EQU $02
DEF OPTION_SITEM_BANK_B     EQU $03


DEF OPTIONS_ACT_EXIT EQU $00
DEF OPTIONS_ACT_L EQU $01
DEF OPTIONS_ACT_R EQU $02
DEF OPTIONS_ACT_A EQU $03
DEF OPTIONS_ACT_B EQU $04

DEF OPTIONS_SACT_EXIT    EQU $00
DEF OPTIONS_SACT_UP      EQU $01
DEF OPTIONS_SACT_DOWN    EQU $02
DEF OPTIONS_SACT_A       EQU $03
DEF OPTIONS_SACT_B       EQU $04
DEF OPTIONS_SACT_SUBEXIT EQU $05

DEF OPTIONS_TIMER_MIN EQU $10
DEF OPTIONS_TIMER_INC EQU $10
DEF OPTIONS_TIMER_MAX EQU $90

DEF OPTION_MENU_NORMAL  EQU $00
DEF OPTION_MENU_SGBTEST EQU $02

; ============================================================
; CHARACTER SELECT

; Portrait IDs
; These identify the blocks in the character select screen that the cursor can go over.
DEF CHARSEL_ID_KYO       EQU $00
DEF CHARSEL_ID_ANDY      EQU $01
DEF CHARSEL_ID_TERRY     EQU $02
DEF CHARSEL_ID_RYO       EQU $03
DEF CHARSEL_ID_ROBERT    EQU $04
DEF CHARSEL_ID_IORI      EQU $05
DEF CHARSEL_ID_DAIMON    EQU $06
DEF CHARSEL_ID_MAI       EQU $07
DEF CHARSEL_ID_GEESE     EQU $08
DEF CHARSEL_ID_MRBIG     EQU $09
DEF CHARSEL_ID_KRAUSER   EQU $0A
DEF CHARSEL_ID_MATURE    EQU $0B
DEF CHARSEL_ID_ATHENA    EQU $0C
DEF CHARSEL_ID_CHIZURU   EQU $0D
DEF CHARSEL_ID_MRKARATE0 EQU $0E ; 2 slots
DEF CHARSEL_ID_MRKARATE1 EQU $0F
DEF CHARSEL_ID_GOENITZ   EQU $10
DEF CHARSEL_ID_LEONA     EQU $11
; Extra entries not part of the slots
DEF CHARSEL_ID_SPEC_OIORI  EQU $12
DEF CHARSEL_ID_SPEC_OLEONA EQU $13
DEF CHARSEL_ID_SPEC_KAGURA EQU $14

DEF CHARSEL_POSFB_DEFEATED EQU 7
DEF CHARSEL_POSF_DEFEATED EQU 1 << CHARSEL_POSFB_DEFEATED

DEF CHARSEL_MODE_SELECT    EQU $00
DEF CHARSEL_MODE_READY     EQU $02
DEF CHARSEL_MODE_CONFIRMED EQU $04

DEF CHARSEL_1P EQU $00
DEF CHARSEL_2P EQU $01	

DEF CHARSEL_TEAM_REMAIN EQU $00
DEF CHARSEL_TEAM_FILLED EQU $FF

DEF CHARSEL_GRID_W    EQU $06
DEF CHARSEL_GRID_H    EQU $03
DEF CHARSEL_GRID_SIZE EQU CHARSEL_GRID_W * CHARSEL_GRID_H

DEF CHARSEL_OBJ_CURSOR1P        EQU $00
DEF CHARSEL_OBJ_CURSOR1PWIDE    EQU $04
DEF CHARSEL_OBJ_CURSOR2P        EQU $08
DEF CHARSEL_OBJ_CURSOR2PWIDE    EQU $0C
DEF CHARSEL_OBJ_CURSORCPU1P     EQU $10
DEF CHARSEL_OBJ_CURSORCPU1PWIDE EQU $14
DEF CHARSEL_OBJ_CURSORCPU2P     EQU $18
DEF CHARSEL_OBJ_CURSORCPU2PWIDE EQU $1C

DEF BG_CHARSEL_P1ICON0 EQU $99E1
DEF BG_CHARSEL_P1ICON1 EQU $99E3
DEF BG_CHARSEL_P1ICON2 EQU $99E5
DEF BG_CHARSEL_P2ICON0 EQU $99F1
DEF BG_CHARSEL_P2ICON1 EQU $99EF
DEF BG_CHARSEL_P2ICON2 EQU $99ED

DEF BG_CHARSEL_P1NAME  EQU $99A1 ; Left side
DEF BG_CHARSEL_P2NAME  EQU $99B2 ; Right side

; Blank boxes with numbers
DEF TILE_CHARSEL_ICONEMPTY1 EQU $EC
DEF TILE_CHARSEL_ICONEMPTY2 EQU $F0
DEF TILE_CHARSEL_ICONEMPTY3 EQU $F4

DEF TILE_CHARSEL_P1ICON0 EQU $F8
DEF TILE_CHARSEL_P1ICON1 EQU $1F
DEF TILE_CHARSEL_P1ICON2 EQU $23

DEF TILE_CHARSEL_P2ICON0 EQU $FC
DEF TILE_CHARSEL_P2ICON1 EQU $27
DEF TILE_CHARSEL_P2ICON2 EQU $2B

; ============================================================
; ORDER SELECT
DEF ORDSEL_SEL0 EQU $00
DEF ORDSEL_SEL1 EQU $01
DEF ORDSEL_SEL2 EQU $02
DEF ORDSEL_SELDONE EQU $03

; ============================================================
; GAMEPLAY

; Terminology:
; - F -> Forward
; - B -> Back
; - G -> Ground
; - C -> Crouch
; - A -> Air
; - L -> Light
; - H -> Heavy
; - E -> Extra (hidden attack, requires max power and DIPB_POWERUP)
;        Moves marked as EL are inaccessible if not associated to a move shortcut (SELECT + A/B) 
; - S -> Super
; - D -> Desperation Super

DEF MOVE_SHARED_NONE            EQU $00
DEF MOVE_SHARED_IDLE            EQU $02 ; Stand
DEF MOVE_SHARED_WALK_F          EQU $04 ; Walk forward
DEF MOVE_SHARED_WALK_B          EQU $06 ; Walk back
DEF MOVE_SHARED_CROUCH          EQU $08 ; Crouch
DEF MOVE_SHARED_JUMP_N          EQU $0A ; Neutral jump
DEF MOVE_SHARED_JUMP_F          EQU $0C ; forward jump
DEF MOVE_SHARED_JUMP_B          EQU $0E ; Backwards jump
DEF MOVE_SHARED_BLOCK_G         EQU $10 ; Ground block / mid
DEF MOVE_SHARED_BLOCK_C         EQU $12 ; Crouch block / low
DEF MOVE_SHARED_BLOCK_A         EQU $14 ; Air block
DEF MOVE_SHARED_RUN_F           EQU $16 ; Run forward
DEF MOVE_SHARED_HOP_B           EQU $18 ; Hop back
DEF MOVE_SHARED_CHARGEMETER     EQU $1A ; Charge meter
DEF MOVE_SHARED_TAUNT           EQU $1C ; Taunt
DEF MOVE_SHARED_ROLL_F          EQU $1E ; Roll forward
DEF MOVE_SHARED_ROLL_B          EQU $20 ; Roll back
DEF MOVE_SHARED_WAKEUP          EQU $22 ; Get up
DEF MOVE_SHARED_DIZZY           EQU $24 ; Dizzy
DEF MOVE_SHARED_WIN_A           EQU $26 ; Win (1st)
DEF MOVE_SHARED_WIN_B           EQU $28 ; Win (2nd+)
DEF MOVE_SHARED_LOST_TIMEOVER   EQU $2A ; Time over
DEF MOVE_SHARED_INTRO           EQU $2C ; Intro
DEF MOVE_SHARED_INTRO_SPEC      EQU $2E ; Special intro
; Basic attacks
DEF MOVE_SHARED_PUNCH_L         EQU $30 ; Light punch
DEF MOVE_SHARED_PUNCH_H         EQU $32 ; Heavy punch
DEF MOVE_SHARED_KICK_L          EQU $34 ; Light kick
DEF MOVE_SHARED_KICK_H          EQU $36 ; Heavy kick
DEF MOVE_SHARED_PUNCH_CL        EQU $38 ; Crouch punch light
DEF MOVE_SHARED_PUNCH_CH        EQU $3A ; Crouch punch heavy
DEF MOVE_SHARED_KICK_CL         EQU $3C ; Crouch kick light
DEF MOVE_SHARED_KICK_CH         EQU $3E ; Crouch kick heavy
DEF MOVE_SHARED_ATTACK_G        EQU $40 ; Ground A + B 
DEF MOVE_SHARED_PUNCH_A         EQU $42 ; Air punch
DEF MOVE_SHARED_KICK_A          EQU $44 ; Air kick
DEF MOVE_SHARED_ATTACK_A        EQU $46 ; Air A + B
; Specials (placeholders)
DEF MOVE_SPEC_0_L               EQU $48
DEF MOVE_SPEC_0_H               EQU $4A
DEF MOVE_SPEC_1_L               EQU $4C
DEF MOVE_SPEC_1_H               EQU $4E
DEF MOVE_SPEC_2_L               EQU $50
DEF MOVE_SPEC_2_H               EQU $52
DEF MOVE_SPEC_3_L               EQU $54
DEF MOVE_SPEC_3_H               EQU $56
DEF MOVE_SPEC_4_L               EQU $58
DEF MOVE_SPEC_4_H               EQU $5A
DEF MOVE_SPEC_5_L               EQU $5C
DEF MOVE_SPEC_5_H               EQU $5E
DEF MOVE_SPEC_6_L               EQU $60
DEF MOVE_SPEC_6_H               EQU $62
DEF MOVE_SUPER_START            EQU $64
DEF MOVE_SUPER_0_S              EQU $64
DEF MOVE_SUPER_0_D              EQU $66
DEF MOVE_SUPER_1_S              EQU $68
DEF MOVE_SUPER_1_D              EQU $6A
; Throws
DEF MOVE_SHARED_THROW_G         EQU $6C ; Ground throw
DEF MOVE_SHARED_THROW_A         EQU $6E ; Air throw
; Attacked
DEF MOVE_SHARED_POST_BLOCKSTUN  EQU $70 ; After blockstun knockback
DEF MOVE_SHARED_GUARDBREAK_G    EQU $72 ; Guard break - Ground
DEF MOVE_SHARED_GUARDBREAK_A    EQU $74 ; Guard break - Air
DEF MOVE_SHARED_HIT0MID         EQU $76 ; Mid Hit #0
DEF MOVE_SHARED_HIT1MID         EQU $78 ; Mid Hit #1
DEF MOVE_SHARED_HITLOW          EQU $7A ; Low Hit
DEF MOVE_SHARED_LAUNCH_UB       EQU $7C ; Up-Back launch/throw arc
DEF MOVE_SHARED_LAUNCH_DB_SHAKE EQU $7E ; Down-Back launch/throw arc, shake screen when hitting the ground
DEF MOVE_SHARED_GROUND_SHAKE    EQU $80 ; Player shakes while on the ground, ground version of MOVE_SHARED_LAUNCH_DB_SHAKE
DEF MOVE_SHARED_LAUNCH_SWOOPUP  EQU $82 ; Straight up launch/throw arc
DEF MOVE_SHARED_HIT_SWEEP       EQU $84 ; Hit by crouching heavy kick (fell off)
DEF MOVE_SHARED_LAUNCH_UB_REC   EQU $86 ; Up-Back launch with mid-air recovery.
DEF MOVE_SHARED_HIT_MULTIMID0   EQU $88 ; Multi-hit special move, pre-last hit #0
DEF MOVE_SHARED_HIT_MULTIMID1   EQU $8A ; Multi-hit special move, pre-last hit #1
DEF MOVE_SHARED_HIT_MULTIGS     EQU $8C ; Multi-hit special (super) move, pre-last hit to ground
DEF MOVE_SHARED_LAUNCH_UB_SHAKE EQU $8E ; Up-Back launch/throw arc, shake screen when hitting the ground
DEF MOVE_SHARED_GRAB_START      EQU $90 ; Throw seq #0 - throw tech check
DEF MOVE_SHARED_GRAB_ROTU       EQU $92 ; Throw seq #1 - Rotation frame
DEF MOVE_SHARED_GRAB_ROTL       EQU $94 ; Throw seq #1 - Rotation frame
DEF MOVE_SHARED_GRAB_ROTD       EQU $96 ; Throw seq #1 - Rotation frame
DEF MOVE_SHARED_GRAB_ROTR       EQU $98 ; Throw seq #1 - Rotation frame
DEF MOVE_TASK_REMOVE            EQU $FF ; Magic value - Kill current task

; Character-specific
DEF MOVE_KYO_ARA_KAMI_L                    EQU $48
DEF MOVE_KYO_ARA_KAMI_H                    EQU $4A
DEF MOVE_KYO_ONI_YAKI_L                    EQU $4C
DEF MOVE_KYO_ONI_YAKI_H                    EQU $4E
DEF MOVE_KYO_RED_KICK_L                    EQU $50
DEF MOVE_KYO_RED_KICK_H                    EQU $52
DEF MOVE_KYO_KOTOTSUKI_YOU_L               EQU $54
DEF MOVE_KYO_KOTOTSUKI_YOU_H               EQU $56
DEF MOVE_KYO_KAI_L                         EQU $58
DEF MOVE_KYO_KAI_H                         EQU $5A
DEF MOVE_KYO_NUE_TUMI_L                    EQU $5C
DEF MOVE_KYO_NUE_TUMI_H                    EQU $5E
DEF MOVE_KYO_SPEC_6_L                      EQU $60
DEF MOVE_KYO_SPEC_6_H                      EQU $62
DEF MOVE_KYO_URA_OROCHI_NAGI_S             EQU $64 ; Super
DEF MOVE_KYO_URA_OROCHI_NAGI_D             EQU $66 ; Desperation super
IF REV_VER_2
DEF MOVE_KYO_URA_OROCHI_NAGI_E             EQU $68 ; Hidden desperation super
ENDC
DEF MOVE_KYO_SUPER_1_S                     EQU $68
DEF MOVE_KYO_SUPER_1_D                     EQU $6A

DEF MOVE_DAIMON_JIRAI_SHIN                 EQU $48
DEF MOVE_DAIMON_JIRAI_SHIN_FAKE            EQU $4A
DEF MOVE_DAIMON_CHOU_UKEMI_L               EQU $4C
DEF MOVE_DAIMON_CHOU_UKEMI_H               EQU $4E
DEF MOVE_DAIMON_CHOU_OOSOTO_GARI_L         EQU $50
DEF MOVE_DAIMON_CHOU_OOSOTO_GARI_H         EQU $52
DEF MOVE_DAIMON_CLOUD_TOSSER               EQU $54
DEF MOVE_DAIMON_STUMP_THROW                EQU $56
DEF MOVE_DAIMON_HEAVEN_DROP_L              EQU $58
DEF MOVE_DAIMON_HEAVEN_DROP_H              EQU $5A
DEF MOVE_DAIMON_SPEC_5_L                   EQU $5C
DEF MOVE_DAIMON_SPEC_5_H                   EQU $5E
DEF MOVE_DAIMON_SPEC_6_L                   EQU $60
DEF MOVE_DAIMON_SPEC_6_H                   EQU $62
DEF MOVE_DAIMON_HEAVEN_HELL_DROP_S         EQU $64
DEF MOVE_DAIMON_HEAVEN_HELL_DROP_D         EQU $66
DEF MOVE_DAIMON_SUPER_1_S                  EQU $68
DEF MOVE_DAIMON_SUPER_1_D                  EQU $6A

DEF MOVE_TERRY_POWER_WAVE_L                EQU $48
DEF MOVE_TERRY_POWER_WAVE_H                EQU $4A
DEF MOVE_TERRY_BURN_KNUCKLE_L              EQU $4C
DEF MOVE_TERRY_BURN_KNUCKLE_H              EQU $4E
DEF MOVE_TERRY_CRACK_SHOT_L                EQU $50
DEF MOVE_TERRY_CRACK_SHOT_H                EQU $52
DEF MOVE_TERRY_RISING_TACKLE_L             EQU $54
DEF MOVE_TERRY_RISING_TACKLE_H             EQU $56
DEF MOVE_TERRY_POWER_DUNK_L                EQU $58
DEF MOVE_TERRY_POWER_DUNK_H                EQU $5A
DEF MOVE_TERRY_SPEC_5_L                    EQU $5C
DEF MOVE_TERRY_SPEC_5_H                    EQU $5E
DEF MOVE_TERRY_SPEC_6_L                    EQU $60
DEF MOVE_TERRY_SPEC_6_H                    EQU $62
DEF MOVE_TERRY_POWER_GEYSER_S              EQU $64
DEF MOVE_TERRY_POWER_GEYSER_D              EQU $66
DEF MOVE_TERRY_POWER_GEYSER_E              EQU $68
DEF MOVE_TERRY_SUPER_1_D                   EQU $6A

DEF MOVE_ANDY_HI_SHO_KEN_L                 EQU $48
DEF MOVE_ANDY_HI_SHO_KEN_H                 EQU $4A
DEF MOVE_ANDY_ZAN_EI_KEN_L                 EQU $4C
DEF MOVE_ANDY_ZAN_EI_KEN_H                 EQU $4E
DEF MOVE_ANDY_KU_HA_DAN_L                  EQU $50
DEF MOVE_ANDY_KU_HA_DAN_H                  EQU $52
DEF MOVE_ANDY_SHO_RYU_DAN_L                EQU $54
DEF MOVE_ANDY_SHO_RYU_DAN_H                EQU $56
DEF MOVE_ANDY_GEKI_HEKI_HAI_SUI_SHO_L      EQU $58
DEF MOVE_ANDY_GEKI_HEKI_HAI_SUI_SHO_H      EQU $5A
DEF MOVE_ANDY_GENEI_SHIRANUI_L             EQU $5C
DEF MOVE_ANDY_GENEI_SHIRANUI_H             EQU $5E
DEF MOVE_ANDY_SHIMO_AGITO                  EQU $60
DEF MOVE_ANDY_UWA_AGITO                    EQU $62
DEF MOVE_ANDY_CHO_REPPA_DAN_S              EQU $64
DEF MOVE_ANDY_CHO_REPPA_DAN_D              EQU $66
DEF MOVE_ANDY_SUPER_1_S                    EQU $68
DEF MOVE_ANDY_SUPER_1_D                    EQU $6A

DEF MOVE_RYO_KO_OU_KEN_L                   EQU $48
DEF MOVE_RYO_KO_OU_KEN_H                   EQU $4A
DEF MOVE_RYO_MOU_KO_RAI_JIN_GOU_L          EQU $4C
DEF MOVE_RYO_MOU_KO_RAI_JIN_GOU_H          EQU $4E
DEF MOVE_RYO_HIEN_SHIPPUU_KYAKU_L          EQU $50
DEF MOVE_RYO_HIEN_SHIPPUU_KYAKU_H          EQU $52
DEF MOVE_RYO_KO_HOU_L                      EQU $54
DEF MOVE_RYO_KO_HOU_H                      EQU $56
DEF MOVE_RYO_KYOKUKEN_RYU_RENBU_KEN_L      EQU $58
DEF MOVE_RYO_KYOKUKEN_RYU_RENBU_KEN_H      EQU $5A
DEF MOVE_RYO_KO_HOU_EL                     EQU $5C
DEF MOVE_RYO_KO_HOU_EH                     EQU $5E
DEF MOVE_RYO_SPEC_6_L                      EQU $60
DEF MOVE_RYO_SPEC_6_H                      EQU $62
DEF MOVE_RYO_RYU_KO_RANBU_S                EQU $64
DEF MOVE_RYO_RYU_KO_RANBU_D                EQU $66
DEF MOVE_RYO_HAOH_SHOUKOU_KEN_S             EQU $68
DEF MOVE_RYO_HAOH_SHOUKOU_KEN_D             EQU $6A

DEF MOVE_ROBERT_RYUU_GEKI_KEN_L            EQU $48
DEF MOVE_ROBERT_RYUU_GEKI_KEN_H            EQU $4A
DEF MOVE_ROBERT_HIEN_SHIPPU_KYAKU_L        EQU $4C
DEF MOVE_ROBERT_HIEN_SHIPPU_KYAKU_H        EQU $4E
DEF MOVE_ROBERT_HIEN_RYUU_SHIN_KYA_L       EQU $50
DEF MOVE_ROBERT_HIEN_RYUU_SHIN_KYA_H       EQU $52
DEF MOVE_ROBERT_RYUU_GA_L                  EQU $54
DEF MOVE_ROBERT_RYUU_GA_H                  EQU $56
DEF MOVE_ROBERT_KYOKUGEN_RYU_RANBU_KYAKU_L EQU $58
DEF MOVE_ROBERT_KYOKUGEN_RYU_RANBU_KYAKU_H EQU $5A
DEF MOVE_ROBERT_RYUU_GA_HIDDEN_L           EQU $5C
DEF MOVE_ROBERT_RYUU_GA_HIDDEN_H           EQU $5E
DEF MOVE_ROBERT_SPEC_6_L                   EQU $60
DEF MOVE_ROBERT_SPEC_6_H                   EQU $62
DEF MOVE_ROBERT_RYU_KO_RANBU_S             EQU $64
DEF MOVE_ROBERT_RYU_KO_RANBU_D             EQU $66
DEF MOVE_ROBERT_HAOH_SHOUKOU_KEN_S          EQU $68
DEF MOVE_ROBERT_HAOH_SHOUKOU_KEN_D          EQU $6A

DEF MOVE_ATHENA_PSYCHO_BALL_L              EQU $48
DEF MOVE_ATHENA_PSYCHO_BALL_H              EQU $4A
DEF MOVE_ATHENA_PHOENIX_ARROW_L            EQU $4C
DEF MOVE_ATHENA_PHOENIX_ARROW_H            EQU $4E
DEF MOVE_ATHENA_PSYCHO_REFLECTOR_L         EQU $50
DEF MOVE_ATHENA_PSYCHO_REFLECTOR_H         EQU $52
DEF MOVE_ATHENA_PSYCHO_SWORD_L             EQU $54
DEF MOVE_ATHENA_PSYCHO_SWORD_H             EQU $56
DEF MOVE_ATHENA_PSYCHO_TELEPORT_L          EQU $58
DEF MOVE_ATHENA_PSYCHO_TELEPORT_H          EQU $5A
DEF MOVE_ATHENA_SPEC_5_L                   EQU $5C
DEF MOVE_ATHENA_SPEC_5_H                   EQU $5E
DEF MOVE_ATHENA_SPEC_6_L                   EQU $60
DEF MOVE_ATHENA_SPEC_6_H                   EQU $62
DEF MOVE_ATHENA_SHINING_CRYSTAL_BIT_GS     EQU $64
DEF MOVE_ATHENA_SHINING_CRYSTAL_BIT_GD     EQU $66
DEF MOVE_ATHENA_SHINING_CRYSTAL_BIT_AS     EQU $68
DEF MOVE_ATHENA_SHINING_CRYSTAL_BIT_AD     EQU $6A

DEF MOVE_MAI_KA_CHO_SEN_L                  EQU $48
DEF MOVE_MAI_KA_CHO_SEN_H                  EQU $4A
DEF MOVE_MAI_HISSATSU_SHINOBIBACHI_L       EQU $4C
DEF MOVE_MAI_HISSATSU_SHINOBIBACHI_H       EQU $4E
DEF MOVE_MAI_RYU_EN_BU_L                   EQU $50
DEF MOVE_MAI_RYU_EN_BU_H                   EQU $52
DEF MOVE_MAI_HISHO_RYU_EN_JIN_L            EQU $54
DEF MOVE_MAI_HISHO_RYU_EN_JIN_H            EQU $56
DEF MOVE_MAI_CHIJOU_MUSASABI_L             EQU $58
DEF MOVE_MAI_CHIJOU_MUSASABI_H             EQU $5A
DEF MOVE_MAI_KUUCHUU_MUSASABI_L            EQU $5C
DEF MOVE_MAI_KUUCHUU_MUSASABI_H            EQU $5E
DEF MOVE_MAI_SPEC_6_L                      EQU $60
DEF MOVE_MAI_SPEC_6_H                      EQU $62
DEF MOVE_MAI_CHO_HISSATSU_SHINOBIBACHI_S   EQU $64
DEF MOVE_MAI_CHO_HISSATSU_SHINOBIBACHI_D   EQU $66
DEF MOVE_MAI_SUPER_1_S                     EQU $68
DEF MOVE_MAI_SUPER_1_D                     EQU $6A

DEF MOVE_LEONA_BALTIC_LAUNCHER_L           EQU $48
DEF MOVE_LEONA_BALTIC_LAUNCHER_H           EQU $4A
DEF MOVE_LEONA_GRAND_SABRE_L               EQU $4C
DEF MOVE_LEONA_GRAND_SABRE_H               EQU $4E
DEF MOVE_LEONA_X_CALIBUR_L                 EQU $50
DEF MOVE_LEONA_X_CALIBUR_H                 EQU $52
DEF MOVE_LEONA_MOON_SLASHER_L              EQU $54
DEF MOVE_LEONA_MOON_SLASHER_H              EQU $56
DEF MOVE_OLEONA_STORM_BRINGER_L            EQU $58
DEF MOVE_OLEONA_STORM_BRINGER_H            EQU $5A
DEF MOVE_LEONA_SPEC_5_L                    EQU $5C
DEF MOVE_LEONA_SPEC_5_H                    EQU $5E
DEF MOVE_LEONA_SPEC_6_L                    EQU $60
DEF MOVE_LEONA_SPEC_6_H                    EQU $62
DEF MOVE_LEONA_V_SLASHER_S                 EQU $64
DEF MOVE_LEONA_V_SLASHER_D                 EQU $66
DEF MOVE_OLEONA_SUPER_MOON_SLASHER_S       EQU $68
DEF MOVE_OLEONA_SUPER_MOON_SLASHER_D       EQU $6A

DEF MOVE_GEESE_REPPUKEN_L                  EQU $48
DEF MOVE_GEESE_REPPUKEN_H                  EQU $4A
DEF MOVE_GEESE_JA_EI_KEN_L                 EQU $4C
DEF MOVE_GEESE_JA_EI_KEN_H                 EQU $4E
DEF MOVE_GEESE_HISHOU_NICHIRIN_ZAN_L       EQU $50
DEF MOVE_GEESE_HISHOU_NICHIRIN_ZAN_H       EQU $52
DEF MOVE_GEESE_SHIPPU_KEN_L                EQU $54
DEF MOVE_GEESE_SHIPPU_KEN_H                EQU $56
DEF MOVE_GEESE_ATEMI_NAGE_L                EQU $58
DEF MOVE_GEESE_ATEMI_NAGE_H                EQU $5A
DEF MOVE_GEESE_SPEC_5_L                    EQU $5C
DEF MOVE_GEESE_SPEC_5_H                    EQU $5E
DEF MOVE_GEESE_SPEC_6_L                    EQU $60
DEF MOVE_GEESE_SPEC_6_H                    EQU $62
DEF MOVE_GEESE_RAGING_STORM_S              EQU $64
DEF MOVE_GEESE_RAGING_STORM_D              EQU $66
DEF MOVE_GEESE_SUPER_1_S                   EQU $68
DEF MOVE_GEESE_SUPER_1_D                   EQU $6A

DEF MOVE_KRAUSER_HIGH_BLITZ_BALL_L         EQU $48
DEF MOVE_KRAUSER_HIGH_BLITZ_BALL_H         EQU $4A
DEF MOVE_KRAUSER_LOW_BLITZ_BALL_L          EQU $4C
DEF MOVE_KRAUSER_LOW_BLITZ_BALL_H          EQU $4E
DEF MOVE_KRAUSER_LEG_TOMAHAWK_L            EQU $50
DEF MOVE_KRAUSER_LEG_TOMAHAWK_H            EQU $52
DEF MOVE_KRAUSER_KAISER_KICK_L             EQU $54
DEF MOVE_KRAUSER_KAISER_KICK_H             EQU $56
DEF MOVE_KRAUSER_KAISER_DUEL_SOBAT_L       EQU $58
DEF MOVE_KRAUSER_KAISER_DUEL_SOBAT_H       EQU $5A
DEF MOVE_KRAUSER_KAISER_SUPLEX_L           EQU $5C
DEF MOVE_KRAUSER_KAISER_SUPLEX_H           EQU $5E
DEF MOVE_KRAUSER_SPEC_6_L                  EQU $60
DEF MOVE_KRAUSER_SPEC_6_H                  EQU $62
DEF MOVE_KRAUSER_KAISER_WAVE_S             EQU $64
DEF MOVE_KRAUSER_KAISER_WAVE_D             EQU $66
DEF MOVE_KRAUSER_SUPER_1_S                 EQU $68
DEF MOVE_KRAUSER_SUPER_1_D                 EQU $6A

DEF MOVE_MRBIG_GROUND_BLASTER_L            EQU $48
DEF MOVE_MRBIG_GROUND_BLASTER_H            EQU $4A
DEF MOVE_MRBIG_CROSS_DIVING_L              EQU $4C
DEF MOVE_MRBIG_CROSS_DIVING_H              EQU $4E
DEF MOVE_MRBIG_SPINNING_LANCER_L           EQU $50
DEF MOVE_MRBIG_SPINNING_LANCER_H           EQU $52
DEF MOVE_MRBIG_CALIFORNIA_ROMANCE_L        EQU $54
DEF MOVE_MRBIG_CALIFORNIA_ROMANCE_H        EQU $56
DEF MOVE_MRBIG_DRUM_SHOT_L                 EQU $58
DEF MOVE_MRBIG_DRUM_SHOT_H                 EQU $5A
DEF MOVE_MRBIG_SPEC_5_L                    EQU $5C
DEF MOVE_MRBIG_SPEC_5_H                    EQU $5E
DEF MOVE_MRBIG_SPEC_6_L                    EQU $60
DEF MOVE_MRBIG_SPEC_6_H                    EQU $62
DEF MOVE_MRBIG_BLASTER_WAVE_S              EQU $64
DEF MOVE_MRBIG_BLASTER_WAVE_D              EQU $66
DEF MOVE_MRBIG_SUPER_1_S                   EQU $68
DEF MOVE_MRBIG_SUPER_1_D                   EQU $6A

DEF MOVE_IORI_YAMI_BARAI_L                 EQU $48
DEF MOVE_IORI_YAMI_BARAI_H                 EQU $4A
DEF MOVE_IORI_ONI_YAKI_L                   EQU $4C
DEF MOVE_IORI_ONI_YAKI_H                   EQU $4E
DEF MOVE_IORI_AOI_HANA_L                   EQU $50
DEF MOVE_IORI_AOI_HANA_H                   EQU $52
DEF MOVE_IORI_KOTO_TSUKI_IN_L              EQU $54
DEF MOVE_IORI_KOTO_TSUKI_IN_H              EQU $56
DEF MOVE_IORI_SCUM_GALE_L                  EQU $58
DEF MOVE_IORI_SCUM_GALE_H                  EQU $5A
DEF MOVE_IORI_SPEC_5_L                     EQU $5C
DEF MOVE_IORI_SPEC_5_H                     EQU $5E
DEF MOVE_IORI_KIN_YA_OTOME_ESCAPE_L        EQU $60
DEF MOVE_IORI_KIN_YA_OTOME_ESCAPE_H        EQU $62
DEF MOVE_IORI_KIN_YA_OTOME_S               EQU $64
DEF MOVE_IORI_KIN_YA_OTOME_D               EQU $66
DEF MOVE_OIORI_KIN_YA_OTOME_S              EQU $68
DEF MOVE_OIORI_KIN_YA_OTOME_D              EQU $6A

DEF MOVE_MATURE_DECIDE_L                   EQU $48
DEF MOVE_MATURE_DECIDE_H                   EQU $4A
DEF MOVE_MATURE_METAL_MASSACRE_L           EQU $4C
DEF MOVE_MATURE_METAL_MASSACRE_H           EQU $4E
DEF MOVE_MATURE_DEATH_ROW_L                EQU $50
DEF MOVE_MATURE_DEATH_ROW_H                EQU $52
DEF MOVE_MATURE_DESPAIR_L                  EQU $54
DEF MOVE_MATURE_DESPAIR_H                  EQU $56
DEF MOVE_MATURE_SPEC_4_L                   EQU $58
DEF MOVE_MATURE_SPEC_4_H                   EQU $5A
DEF MOVE_MATURE_SPEC_5_L                   EQU $5C
DEF MOVE_MATURE_SPEC_5_H                   EQU $5E
DEF MOVE_MATURE_SPEC_6_L                   EQU $60
DEF MOVE_MATURE_SPEC_6_H                   EQU $62
DEF MOVE_MATURE_HEAVENS_GATE_S             EQU $64
DEF MOVE_MATURE_HEAVENS_GATE_D             EQU $66
DEF MOVE_MATURE_SUPER_1_S                  EQU $68
DEF MOVE_MATURE_SUPER_1_D                  EQU $6A

DEF MOVE_CHIZURU_TENJIN_KOTOWARI_L         EQU $48
DEF MOVE_CHIZURU_TENJIN_KOTOWARI_H         EQU $4A
DEF MOVE_CHIZURU_SHINSOKU_NOROTI_HIGH_L    EQU $4C
DEF MOVE_CHIZURU_SHINSOKU_NOROTI_HIGH_H    EQU $4E
DEF MOVE_CHIZURU_SHINSOKU_NOROTI_LOW_L     EQU $50
DEF MOVE_CHIZURU_SHINSOKU_NOROTI_LOW_H     EQU $52
DEF MOVE_CHIZURU_TEN_ZUI_L                 EQU $54
DEF MOVE_CHIZURU_TEN_ZUI_H                 EQU $56
DEF MOVE_CHIZURU_TAMAYURA_SHITSUNE_L       EQU $58
DEF MOVE_CHIZURU_TAMAYURA_SHITSUNE_H       EQU $5A
DEF MOVE_CHIZURU_SPEC_5_L                  EQU $5C
DEF MOVE_CHIZURU_SPEC_5_H                  EQU $5E
DEF MOVE_CHIZURU_SPEC_6_L                  EQU $60
DEF MOVE_CHIZURU_SPEC_6_H                  EQU $62
DEF MOVE_CHIZURU_SAN_RAI_FUI_JIN_S         EQU $64
DEF MOVE_CHIZURU_SAN_RAI_FUI_JIN_D         EQU $66
DEF MOVE_CHIZURU_REIGI_ISHIZUE_S           EQU $68
DEF MOVE_CHIZURU_REIGI_ISHIZUE_D           EQU $6A

DEF MOVE_GOENITZ_YONOKAZE1                 EQU $48
DEF MOVE_GOENITZ_YONOKAZE2                 EQU $4A
DEF MOVE_GOENITZ_YONOKAZE3                 EQU $4C
DEF MOVE_GOENITZ_YONOKAZE4                 EQU $4E
DEF MOVE_GOENITZ_HYOUGA_L                  EQU $50
DEF MOVE_GOENITZ_HYOUGA_H                  EQU $52
DEF MOVE_GOENITZ_WANPYOU_TOKOBUSE_L        EQU $54
DEF MOVE_GOENITZ_WANPYOU_TOKOBUSE_H        EQU $56
DEF MOVE_GOENITZ_YAMIDOUKOKU_SL            EQU $58 ; Treated as a super...
DEF MOVE_GOENITZ_YAMIDOUKOKU_SH            EQU $5A ; Treated as a super...
DEF MOVE_GOENITZ_SHINYAOTOME_THROW_L       EQU $5C
DEF MOVE_GOENITZ_SHINYAOTOME_THROW_H       EQU $5E
DEF MOVE_GOENITZ_SHINYAOTOME_PART2_L       EQU $60
DEF MOVE_GOENITZ_SHINYAOTOME_PART2_H       EQU $62
DEF MOVE_GOENITZ_SHINYAOTOME_MIZUCHI_SL    EQU $64
DEF MOVE_GOENITZ_SHINYAOTOME_MIZUCHI_SH    EQU $66
DEF MOVE_GOENITZ_SHINYAOTOME_JISSOUKOKU_DL EQU $68
DEF MOVE_GOENITZ_SHINYAOTOME_JISSOUKOKU_DH EQU $6A

DEF MOVE_MRKARATE_KO_OU_KEN_L              EQU $48
DEF MOVE_MRKARATE_KO_OU_KEN_H              EQU $4A
DEF MOVE_MRKARATE_SHOURAN_KYAKU_L          EQU $4C
DEF MOVE_MRKARATE_SHOURAN_KYAKU_H          EQU $4E
DEF MOVE_MRKARATE_HIEN_SHIPPUU_KYAKU_L     EQU $50
DEF MOVE_MRKARATE_HIEN_SHIPPUU_KYAKU_H     EQU $52
DEF MOVE_MRKARATE_ZENRETSUKEN_L            EQU $54
DEF MOVE_MRKARATE_ZENRETSUKEN_H            EQU $56
DEF MOVE_MRKARATE_KYOKUKEN_RYU_RENBU_KEN_L EQU $58
DEF MOVE_MRKARATE_KYOKUKEN_RYU_RENBU_KEN_H EQU $5A
IF !REV_VER_2
DEF MOVE_MRKARATE_KO_OU_KEN_UNUSED_EL      EQU $5C ; [TCRF] Counterpart of MOVE_RYO_KO_HOU_EL that is incomplete.
DEF MOVE_MRKARATE_KO_OU_KEN_UNUSED_EH      EQU $5E
ELSE
DEF MOVE_MRKARATE_SPEC_5_L                 EQU $5C
DEF MOVE_MRKARATE_RYUKO_RANBU_D3           EQU $5E ; Third part of MOVE_MRKARATE_RYUKO_RANBU_S when handling the desperation super.
ENDC
DEF MOVE_MRKARATE_SPEC_6_L                 EQU $60
DEF MOVE_MRKARATE_SPEC_6_H                 EQU $62
DEF MOVE_MRKARATE_RYUKO_RANBU_S            EQU $64
DEF MOVE_MRKARATE_RYUKO_RANBU_UNUSED_D     EQU $66 ; [TCRF] Unused desperation super that doesn't work properly in the Japanese version
DEF MOVE_MRKARATE_HAOH_SHO_KOH_KEN_S       EQU $68
DEF MOVE_MRKARATE_HAOH_SHO_KOH_KEN_D       EQU $6A

DEF HITTYPE_BLOCKED              EQU $00 ; Nothing happens
DEF HITTYPE_GUARDBREAK_G         EQU $01 ; Guard Break, ground
DEF HITTYPE_GUARDBREAK_A         EQU $02 ; Guard Break, air
DEF HITTYPE_HIT_MID0             EQU $03 ; Standard hit #0
DEF HITTYPE_HIT_MID1             EQU $04 ; Standard hit #1
DEF HITTYPE_HIT_LOW              EQU $05 ; Punched or kicked while crouching
DEF HITTYPE_SWEEP                EQU $06 ; Hit by a crouching heavy kick
DEF HITTYPE_HIT_A                EQU $07 ; Hit by a normal while in the air
DEF HITTYPE_LAUNCH_HIGH_UB       EQU $08 ; High throw arc (relative to the opponent)
DEF HITTYPE_HIT_MULTI0           EQU $09 ; Mid-special move, chainable hit #0
DEF HITTYPE_HIT_MULTI1           EQU $0A ; Mid-special move, chainable hit #1
DEF HITTYPE_HIT_MULTIGS          EQU $0B ; Mid-super move, player pushed on the ground and frozen
DEF HITTYPE_LAUNCH_FAST_DB       EQU $0C ; Diagonal down throw arc the player to the ground with screen shake - from air
DEF HITTYPE_LAUNCH_FAST_DB_G     EQU $0D ; Hit (not throw) that sends the player to the ground with screen shake - from ground

IF !REV_VER_2
DEF HITTYPE_LAUNCH_SWOOPUP       EQU $0E ; Throw arc straight up, to off-screen
DEF HITTYPE_LAUNCH_MID_UB_NOSTUN EQU $0F ; Medium-far throw arc, without hitstun
DEF HITTYPE_GRAB_START           EQU $10 ; Start of the grab anim
DEF HITTYPE_GRAB_ROTU            EQU $11 ; Throw rotation frame, head up
DEF HITTYPE_GRAB_ROTL            EQU $12 ; Throw rotation frame, head left
DEF HITTYPE_GRAB_ROTD            EQU $13 ; Throw rotation frame, head down
DEF HITTYPE_GRAB_ROTR            EQU $14 ; Throw rotation frame, head right
ELSE
DEF HITTYPE_DIZZY                EQU $0E ; English-only, Manual dizzy. 
DEF HITTYPE_LAUNCH_SWOOPUP       EQU $0F ; Throw arc straight up, to off-screen
DEF HITTYPE_LAUNCH_MID_UB_NOSTUN EQU $10 ; Medium-far throw arc, without hitstun
DEF HITTYPE_GRAB_START           EQU $11 ; Start of the grab anim / throw sequence
DEF HITTYPE_GRAB_ROTU            EQU $12 ; Grab rotation frame, head up
DEF HITTYPE_GRAB_ROTL            EQU $13 ; Grab rotation frame, head left
DEF HITTYPE_GRAB_ROTD            EQU $14 ; Grab rotation frame, head down
DEF HITTYPE_GRAB_ROTR            EQU $15 ; Grab rotation frame, head right
ENDC

DEF HITTYPE_DUMMY                EQU $81 ; Placeholder used for empty slots in the special move entries


DEF COLIBOX_00 EQU $00 ; None
DEF COLIBOX_01 EQU $01
DEF COLIBOX_02 EQU $02
DEF COLIBOX_03 EQU $03
DEF COLIBOX_04 EQU $04 ; Throw range
DEF COLIBOX_05 EQU $05
DEF COLIBOX_07 EQU $07
DEF COLIBOX_08 EQU $08
DEF COLIBOX_0A EQU $0A
DEF COLIBOX_0B EQU $0B
DEF COLIBOX_0C EQU $0C
DEF COLIBOX_0D EQU $0D
DEF COLIBOX_0E EQU $0E
DEF COLIBOX_0F EQU $0F
DEF COLIBOX_10 EQU $10
DEF COLIBOX_11 EQU $11
DEF COLIBOX_12 EQU $12
DEF COLIBOX_13 EQU $13
DEF COLIBOX_14 EQU $14
DEF COLIBOX_15 EQU $15
DEF COLIBOX_16 EQU $16
DEF COLIBOX_17 EQU $17
DEF COLIBOX_18 EQU $18
DEF COLIBOX_19 EQU $19
DEF COLIBOX_1A EQU $1A
DEF COLIBOX_1B EQU $1B
DEF COLIBOX_1C EQU $1C
DEF COLIBOX_1D EQU $1D
DEF COLIBOX_1E EQU $1E
DEF COLIBOX_1F EQU $1F
DEF COLIBOX_20 EQU $20
DEF COLIBOX_21 EQU $21
DEF COLIBOX_22 EQU $22
DEF COLIBOX_23 EQU $23
DEF COLIBOX_24 EQU $24
DEF COLIBOX_25 EQU $25
DEF COLIBOX_26 EQU $26
DEF COLIBOX_27 EQU $27
DEF COLIBOX_28 EQU $28
DEF COLIBOX_29 EQU $29
DEF COLIBOX_2A EQU $2A
DEF COLIBOX_2B EQU $2B
DEF COLIBOX_2C EQU $2C
DEF COLIBOX_2D EQU $2D
DEF COLIBOX_2E EQU $2E
DEF COLIBOX_2F EQU $2F
DEF COLIBOX_30 EQU $30
DEF COLIBOX_31 EQU $31
DEF COLIBOX_32 EQU $32
DEF COLIBOX_33 EQU $33
DEF COLIBOX_34 EQU $34
DEF COLIBOX_35 EQU $35
DEF COLIBOX_36 EQU $36
DEF COLIBOX_37 EQU $37
DEF COLIBOX_38 EQU $38
DEF COLIBOX_39 EQU $39
DEF COLIBOX_3A EQU $3A
DEF COLIBOX_3B EQU $3B
DEF COLIBOX_3C EQU $3C
DEF COLIBOX_3D EQU $3D
DEF COLIBOX_3E EQU $3E
DEF COLIBOX_3F EQU $3F
DEF COLIBOX_40 EQU $40
DEF COLIBOX_41 EQU $41
DEF COLIBOX_42 EQU $42
DEF COLIBOX_43 EQU $43
DEF COLIBOX_44 EQU $44
DEF COLIBOX_45 EQU $45
DEF COLIBOX_46 EQU $46
DEF COLIBOX_47 EQU $47
DEF COLIBOX_48 EQU $48
DEF COLIBOX_49 EQU $49
DEF COLIBOX_4A EQU $4A
DEF COLIBOX_4B EQU $4B
DEF COLIBOX_4C EQU $4C
DEF COLIBOX_4D EQU $4D
DEF COLIBOX_4E EQU $4E
DEF COLIBOX_4F EQU $4F
DEF COLIBOX_50 EQU $50
DEF COLIBOX_51 EQU $51
DEF COLIBOX_52 EQU $52
DEF COLIBOX_53 EQU $53
DEF COLIBOX_54 EQU $54
DEF COLIBOX_55 EQU $55
DEF COLIBOX_56 EQU $56
DEF COLIBOX_57 EQU $57
DEF COLIBOX_58 EQU $58
DEF COLIBOX_59 EQU $59
DEF COLIBOX_5A EQU $5A
DEF COLIBOX_5B EQU $5B
DEF COLIBOX_5C EQU $5C
DEF COLIBOX_5D EQU $5D
DEF COLIBOX_5E EQU $5E
DEF COLIBOX_5F EQU $5F
DEF COLIBOX_60 EQU $60
DEF COLIBOX_61 EQU $61
DEF COLIBOX_62 EQU $62
DEF COLIBOX_63 EQU $63
DEF COLIBOX_64 EQU $64
DEF COLIBOX_65 EQU $65
DEF COLIBOX_66 EQU $66
DEF COLIBOX_67 EQU $67
DEF COLIBOX_68 EQU $68
DEF COLIBOX_69 EQU $69
DEF COLIBOX_6A EQU $6A
DEF COLIBOX_6B EQU $6B
DEF COLIBOX_6C EQU $6C
DEF COLIBOX_6D EQU $6D
DEF COLIBOX_6E EQU $6E
DEF COLIBOX_6F EQU $6F
DEF COLIBOX_70 EQU $70
DEF COLIBOX_71 EQU $71

DEF PROJ_PRIORITY_NODESPAWN EQU $03
DEF PROJ_PRIORITY_ALTSPEED EQU $04 ; Athena only

; wPlayPlThrowActId
DEF PLAY_THROWACT_NONE EQU $00
DEF PLAY_THROWACT_START EQU $01
DEF PLAY_THROWACT_NEXT02 EQU $02
DEF PLAY_THROWACT_NEXT03 EQU $03
DEF PLAY_THROWACT_NEXT04 EQU $04

; wPlayPlThrowOpMode
DEF PLAY_THROWOP_GROUND EQU $00 ; The throw works on players on the ground
DEF PLAY_THROWOP_AIR EQU $01 ; The throw works on players in the air
DEF PLAY_THROWOP_UNUSED_BOTH EQU $02 ; [TCRF] Unused, works on both.

; wPlayPlThrowDir
DEF PLAY_THROWDIR_F EQU $00
DEF PLAY_THROWDIR_B EQU $01

; iPlInfo_Kyo_AraKami_SubInputMask for MOVE_KYO_ARA_KAMI_H
DEF MSIB_K0S0_P    EQU 0 ; 401 Shiki Tumi Yomi - Light punch pressed
DEF MSIB_K0S0_DB   EQU 1 ; 401 Shiki Tumi Yomi - DB input performed
DEF MSIB_K0S1_P    EQU 2 ; 402 Shiki Batu Yomi - Light punch pressed

; iPlInfo_Chizuru_ShinsokuNoroti_ChainedMove
DEF PCMB_CHIZURU_TEN_ZUI_L EQU 0
DEF PCMB_CHIZURU_TEN_ZUI_H EQU 1

; iPlInfo_Athena_ShCryst_ProjSize
DEF PACT_SIZE_NORM EQU $00
DEF PACT_SIZE_01 EQU $01
DEF PACT_SIZE_02 EQU $02
DEF PACT_SIZE_03 EQU $03
DEF PACT_SIZE_04 EQU $04

; iOBJInfo_Proj_ShCrystThrow_TypeId
DEF PROJ_SHCRYST2_TYPE_GL EQU $01 ; Ground - light
DEF PROJ_SHCRYST2_TYPE_GH EQU $02 ; Ground - heavy
DEF PROJ_SHCRYST2_TYPE_AL EQU $03 ; Air - light
DEF PROJ_SHCRYST2_TYPE_AH EQU $04 ; Air - heavy

; iOBJInfo_Proj_ShCrystCharge_OrbitMode
DEF PROJ_SHCRYST_ORBITMODE_OVAL EQU $00 ; Phase 1 - Projectile orbits in an oval trajectory at constant speeed
DEF PROJ_SHCRYST_ORBITMODE_SLOW EQU $01 ; Phase 2 - Orbit slows down until it stops moving vertically
DEF PROJ_SHCRYST_ORBITMODE_HOLD EQU $02 ; Phase 2 - Only horizontal movement
DEF PROJ_SHCRYST_ORBITMODE_SPIRAL EQU $FF ; Projectile moves in a spiral motion, expanding outwards, when releasing it early before phase 2

; Base gameplay
DEF PL_FLOOR_POS EQU $88

DEF PLAY_HEALTH_CRITICAL EQU $18 ; Threshold for critical health (allow infinite super & desperation supers)
DEF PLAY_HEALTH_MAX EQU $48 ; Health cap


DEF PLAY_MAXMODE_NONE       EQU $00
DEF PLAY_MAXMODE_LENGTH1    EQU $01
DEF PLAY_MAXMODE_LENGTH2    EQU $02
DEF PLAY_MAXMODE_LENGTH3    EQU $03
DEF PLAY_MAXMODE_LENGTH4    EQU $04
DEF PLAY_MAXMODE_BASELENGTH EQU $04

DEF PLAY_POW_EMPTY       EQU $00
DEF PLAY_POW_MAX         EQU $28 ; Max value for normal POW bar

DEF PLAY_MAXPOWFADE_NONE EQU $00
DEF PLAY_MAXPOWFADE_IN   EQU $01
DEF PLAY_MAXPOWFADE_OUT  EQU $FF

DEF PLAY_TID_BAR_L      EQU $D2 ; Tile ID for left border of bars
DEF PLAY_TID_BAR_R      EQU $D3 ; Tile ID for right border of bars

DEF PLAY_TID_BAR_BASE   EQU $DF ; Tile ID base for bars
DEF PLAY_TID_BAR_EMPTY  EQU $E0 ; Tile ID for an empty bar
DEF PLAY_TID_BAR_FILLED EQU PLAY_TID_BAR_BASE ; Tile ID for a filled bar
DEF PLAY_TID_BAR_SIZE   EQU $08 ; Number of tile IDs for tile parts, mapping to the LGrow/RGrow

DEF PLAY_TID_BOX_FILL   EQU $74
DEF PLAY_TID_BOX_BLANK  EQU $75

DEF PLAY_OBJ_PREROUND_ROUNDX     EQU $00
DEF PLAY_OBJ_PREROUND_FINAL      EQU $04
DEF PLAY_OBJ_PREROUND_READY      EQU $08
DEF PLAY_OBJ_PREROUND_GO_SM      EQU $0C
DEF PLAY_OBJ_PREROUND_GO_LG      EQU $10

DEF PLAY_OBJ_POSTROUND0_KO       EQU $00
DEF PLAY_OBJ_POSTROUND0_TIMEOVER EQU $04

DEF PLAY_OBJ_POSTROUND1_DRAWGAME EQU $00
DEF PLAY_OBJ_POSTROUND1_1PWON    EQU $04
DEF PLAY_OBJ_POSTROUND1_2PWON    EQU $08
DEF PLAY_OBJ_POSTROUND1_YOUWON   EQU $0C
DEF PLAY_OBJ_POSTROUND1_YOULOST  EQU $10