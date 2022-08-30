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


DIPB_UNLOCK_GOENITZ   EQU 6 ; Unlock Goenitz
DIPB_UNLOCK_OTHER     EQU 7 ; Unlock everyone else (Mr Karate, Boss Kagura, Orochi Iori and Orochi Leona)


BORDER_NONE			EQU $00
BORDER_MAIN 		EQU $01
BORDER_ALTERNATE 	EQU $02

TIMER_INFINITE		EQU $FF


OBJ_OFFSET_X        EQU $08 ; Standard offset used when sprite positions are compared to the screen/scroll
OBJLSTPTR_NONE      EQU $FFFF ; Placeholder pointer that marks the lack of a secondary sprite mapping

; $C025
MISCB_PAUSE_TASKS EQU 3 ; Prevents tasks from executing
MISCB_IS_SGB EQU 7	; Enables SGB features
; $C026
MISCB_TASK_CTRL_CALLED EQU 3 ; If set, the task exec loop was entered
; $C028
MISCB_PL_RANGE_CHECK EQU 1 ; Enables the player range enforcement, which is part of the sprite drawing routine.
                           ; Should only be used during gameplay, otherwise it could get in the way.


; iOBJInfo_Status bits
OSTB_ALTSET  EQU 0 ; If set, uses an alternate set of values for user flags and sprite mapping pointer
OSTB_VISIBLE EQU 7 ; If not set, the sprite mapping is hidden



; OBJLST / SPRITE MAPPINGS FLAGS
; item0

OLFB_USETILEFLAGS EQU 4 ; If set, in the OBJ data, the upper two bits of a tile ID count as X/Y flip flags
OLFB_XFLIP        EQU 5 ; User-controlled
OLFB_YFLIP        EQU 6

OLF_USETILEFLAGS EQU 1 << OLFB_USETILEFLAGS ; $10
OLF_XFLIP        EQU 1 << OLFB_XFLIP ; $20
OLF_YFLIP        EQU 1 << OLFB_YFLIP ; $40



TASK_SIZE EQU $08

TASK_EXEC_NONE EQU $00 ; Task is skipped
TASK_EXEC_01 EQU $01 ; Disabled?
TASK_EXEC_CUR EQU $02 ; Task is being executed
; (no constant applicable? as long as != $08 and >= $04 to allow exec)
;TASK_EXEC_SP EQU  ; Task is executed by replacing the stack pointer to that code (so on 'ret' it gets executed)
TASK_EXEC_JP EQU $08 ; Task is executed by jumping to the specified code


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

SNDCMD_BASE        EQU $E0

SNDNOTE_BASE       EQU $80
SND_BASE           EQU $80
SND_NONE           EQU SND_BASE+$00
SND_ID_01          EQU SND_BASE+$01
SND_ID_02          EQU SND_BASE+$02
SND_ID_03          EQU SND_BASE+$03
SND_ID_04          EQU SND_BASE+$04
SND_ID_05          EQU SND_BASE+$05
SND_ID_06          EQU SND_BASE+$06
SND_ID_07          EQU SND_BASE+$07
SND_ID_08          EQU SND_BASE+$08
SND_ID_09          EQU SND_BASE+$09
SND_ID_0A          EQU SND_BASE+$0A
SND_ID_0B          EQU SND_BASE+$0B
SND_ID_PAUSE       EQU SND_BASE+$0C
SND_ID_UNPAUSE     EQU SND_BASE+$0D
SND_ID_0E          EQU SND_BASE+$0E
SND_ID_0F          EQU SND_BASE+$0F
SND_ID_10          EQU SND_BASE+$10
SND_ID_11          EQU SND_BASE+$11
SND_ID_12          EQU SND_BASE+$12
SND_ID_13          EQU SND_BASE+$13
SND_ID_14          EQU SND_BASE+$14
SND_ID_15          EQU SND_BASE+$15
SND_ID_16          EQU SND_BASE+$16
SND_ID_17          EQU SND_BASE+$17
SND_ID_18          EQU SND_BASE+$18
SND_ID_19          EQU SND_BASE+$19
SND_ID_1A          EQU SND_BASE+$1A
SND_ID_1B          EQU SND_BASE+$1B
SND_ID_1C          EQU SND_BASE+$1C
SND_ID_1D          EQU SND_BASE+$1D
SND_ID_1E          EQU SND_BASE+$1E
SND_ID_1F          EQU SND_BASE+$1F
;SND_ID_20          EQU SND_BASE+$20
;SND_ID_21          EQU SND_BASE+$21
;SND_ID_22          EQU SND_BASE+$22
;SND_ID_23          EQU SND_BASE+$23
;SND_ID_24          EQU SND_BASE+$24
;SND_ID_25          EQU SND_BASE+$25
SND_ID_26          EQU SND_BASE+$26
SND_ID_27          EQU SND_BASE+$27
SND_ID_28          EQU SND_BASE+$28
SND_ID_29          EQU SND_BASE+$29
SND_ID_2A          EQU SND_BASE+$2A
SND_ID_2B          EQU SND_BASE+$2B
SND_ID_2C          EQU SND_BASE+$2C
SND_ID_2D          EQU SND_BASE+$2D
SND_ID_2E          EQU SND_BASE+$2E
SND_ID_2F          EQU SND_BASE+$2F
SND_ID_30          EQU SND_BASE+$30
SND_ID_31          EQU SND_BASE+$31
;SND_ID_32          EQU SND_BASE+$32
;SND_ID_33          EQU SND_BASE+$33
SND_LAST_VALID     EQU SND_BASE+$45 ; Dunno why this late