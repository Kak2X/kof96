
wDipSwitch EQU $C000 ; DIP-SWITCH options
wDifficulty EQU $C001
wMatchStartTime EQU $C002


wTimer EQU $C005 ; Global timer
w_Unknown_SomethingLCDC EQU $C006 ; Some marker for LCDC things
wVBlankNotDone EQU $C007 ; If != 0, the VBlank handler hasn't finished

wPaused EQU $C00E ; Game is paused
wOBJLstHeaderFlags EQU $C00F ; Raw flags value from the OBJLst header

wWorkOAMCurPtr_Low EQU $C010 ; Next OBJ will be written at this location
wWorkOAMCurPtr_High EQU $C011 ; 
; The status contain the actual *flags*, these are then initially cocpied here when drawing the sprites
wOBJLstUserFlags EQU $C012 ; User-controlled flags -- wOBJLstHeaderFlags is added on top of this.
wOBJLstUserFlagsSec EQU $C013 ; User-controlled flags -- iOBJ flags specific to the secondary sprite mapping pointer in the OBJLstPtrTable entry, if any


wOBJLstUserSetFlags EQU $C015 ; User-controlled X/Y flip flags -- set specific
; wOBJLstCurDispX = wOBJLstCurRelX + wOBJLstCurXOffset
wOBJLstCurRelX EQU $C016 ; Calculated relative position/origin of the sprite mapping
wOBJLstCurRelY EQU $C017 ; Calculated relative position/origin of the sprite mapping
wOBJLstCurDispX EQU $C018 ; Effective X position of the displayed sprite mapping, relative to the screen
wOBJLstCurDispY EQU $C019 ; Effective Y position of the displayed sprite mapping, relative to the screen
wOBJLstCurFlags EQU $C01A ; Calculated flags for the sprite mapping (merge of wOBJLstUserFlags and wOBJLstUserSetFlags)
wOBJLstCurXOffset EQU $C01B ; Offset added to wOBJLstCurRelX, and the result goes to wOBJLstCurDispX
wOBJLstCurYOffset EQU $C01C ; Offset added to wOBJLstCurRelX, and the result goes to wOBJLstCurDispY


wMisc_C025 EQU $C025 ; bitmask with multiple different purposes
wMisc_C026 EQU $C026
wMisc_C028 EQU $C028 ; appears to select a parallax type (how to divide the screen sections)

wIntroScene EQU $C029 ; Offset to scene ID in scene pointer table (some scenes have different parts)
wIntroCharScene EQU $C02A ; Offset to the subscene ID when animating player sprites

wSGBSendPacketAtFrameEnd EQU $C02B ; If set, there are SGB packets to send after all tasks are processed
wSGBSoundPacket EQU $C02C ; Data for the sound effect packet to be sent at the end of the frame.

wSerialIntPtr_Low EQU $C03C
wSerialIntPtr_High EQU $C03D
wSerialDataReceiveBuffer EQU $C03E
wSerialDataReceiveBuffer_End EQU $C0BE
wSerialDataSendBuffer EQU $C0BE
wSerialDataSendBuffer_End EQU $C13E
;????
; Two separate indexes, with Tail pointing at Head - 1
wSerialDataReceiveBufferIndex_Head EQU $C13E
wSerialDataReceiveBufferIndex_Tail EQU $C13F
wSerialDataSendBufferIndex_Head EQU $C140 ; Index of most recent buffer entry
wSerialDataSendBufferIndex_Tail EQU $C141 ; Index of last buffer entry - used for current player input in VS serial
wSerial_Unknown_SlaveRetransfer EQU $C142
wSerial_Unknown_0_IncDecMarker EQU $C143
wSerial_Unknown_1_IncDecMarker EQU $C144
wSerialPlId EQU $C145 ; $02 -> Player 1; $03 -> Player 2
wSerial_Unknown_Done EQU $C146 ; Marks if the serial handler was executed for the frame? otherwise waits
wSerialJoyLastKeys EQU $C147 ; Player 1 - Most recent New Joypad Input (when controlling P1)
wSerialJoyKeys EQU $C148 ; Player 1 - Joypad Input (when controlling P1)
wSerialJoyLastKeys2 EQU $C149 ; Player 2 - Most recent Joypad Input (when controlling P1)
wSerialJoyKeys2 EQU $C14A ; Player 2 - Joypad Input (when controlling P1)
wSerialInputEnabled EQU $C14B ; If set, controls are enabled during serial mode
wSGBBorderType EQU $C14C ; Current border type loaded 
wFontLoadBit1Col EQU $C14D ; 2pp color mapped to bit1 on 1bpp graphics
wFontLoadBit0Col EQU $C14E ; 2pp color mapped to bit0 on 1bpp graphics
wFontLoadTmpGFX EQU $C14F ; 2 bytes (size of a line)

wTextPrintFlags EQU $C151


wTextPrintFrameCodeBank EQU $C152 ; Bank number of the custom code
wTextPrintFrameCodePtr_Low EQU $C153 ; Ptr to the code itself
wTextPrintFrameCodePtr_High EQU $C154


wFieldScrollX EQU $C155 ; X Scroll coordinate of the viewport during gameplay 
wFieldScrollY EQU $C157 ; Y Scroll coordinate of the viewport during gameplay 

; a supposed wScreenSect0LYC for the first section is fixed, and always starts at $00
wScreenSect1LYC EQU $C15A ; Scanline number the second screen section starts. During gameplay, it's the playfield.
wScreenSect2LYC EQU $C15B ; Scanline number the third screen section starts. During gameplay, it's the meter HUD


wTitleResetTimer_High EQU $C1C1
wTitleResetTimer_Low EQU $C1C2
wSerial_Unknown_PausedFrameTimer EQU $C1C5 ; Amount of frames the game is paused, waiting for serial connection ???

wLZSS_CurCmdMask EQU $C1C7
wLZSS_SplitNum EQU $C1C8
wLZSS_SplitMask EQU $C1C9
wLZSS_Buffer EQU $C1CA
; Variables sitting on top of the buffer
wCheatGoenitzKeysLeft   EQU $C1CA ; Amount of times to press the button before cheat activates
wCheatAllCharKeysLeft   EQU $C1CB ; each for the 4 cheats
wCheat_Unused_KeysLeft  EQU $C1CC
wCheatEasyMovesKeysLeft EQU $C1CD



wSnd_Unk_Unused_D480 EQU $D480 ; $80 is always written here, but never read back
wSnd_Unused_ChUsed EQU $D481 ; Appears to be a bitmask intended to mark the used sound channels, but it is only set properly in unreachable code.
wSndEnaChBGM EQU $D482 ; Keeps track of the last rNR51 value used modified by a BGM SndInfo.
wSnd_Ch3StopLength EQU $D483 ; This is set to rNR31 sometimes (see logic)
wSndChProcLeft EQU $D485 ; Number of remaining wBGMCh*Info/wSFXCh*Info structs to process
; Channel playback status (separate lanes for BGM and SFX)
wBGMCh1Info EQU $D4A6
wBGMCh2Info EQU $D4C6
wBGMCh3Info EQU $D4E6
wBGMCh4Info EQU $D506
wSFXCh1Info EQU $D526
wSFXCh2Info EQU $D546
wSFXCh3Info EQU $D566
wSFXCh4Info EQU $D586

wSndIdReqTbl EQU $D5F8 ; Sound IDs to play are written here




; size: $40 (is this for an entire object, or does it contain the OBJLst directly?)
; Fixed sprite mappings ???

wOBJInfo0 EQU $D680
wOBJInfo_Pl1 EQU $D680
wOBJInfo1 EQU $D6C0
wOBJInfo_Pl2 EQU $D6C0
wOBJInfo2 EQU $D700
wOBJInfo3 EQU $D740
wOBJInfo4 EQU $D780
wOBJInfo5 EQU $D7C0
wOBJInfo6 EQU $D800
wOBJInfo7 EQU $D840
wOBJInfo8 EQU $D880

wGFXBufInfo_Pl1 EQU $D8C0
wGFXBufInfo_Pl2 EQU $D8E0


wWorkOAM EQU $DF00
wWorkOAM_End EQU $DFA0



hOAMDMA EQU $FF80 ; OAMDMA routine
hJoyKeys EQU $FF98 ; Player 1 - Joypad keys
hJoyNewKeys EQU $FF99 ; Player 1 - Newly pressed keys
hJoyKeys2 EQU $FFAB ; Player 2 - Joypad keys
hJoyNewKeys2 EQU $FFAC ; Player 2 - Newly pressed keys

hTaskStats EQU $FFC0 ; Global task system info
hCurTaskId EQU $FFC1 ; $01-$03 ?
hTaskTbl EQU $FFC8 ; Task struct list


hROMBank EQU $FFE0 ; Currently loaded ROM bank



hScrollY EQU $FFE2 ; Y screen position
hScrollX EQU $FFE4 ; X screen position

hScreenSect0BGP EQU $FFF0 ; BG Palette for the first screen section
hScreenSect1BGP EQU $FFF1 ; ...
hScreenSect2BGP EQU $FFF2
hSndInfoCurPtr_Low EQU $FFF8 ; Ptr to Currently processed SNDInfo structure
hSndInfoCurPtr_High EQU $FFF9 ; Ptr to Currently processed SNDInfo structure


hSndPlayCnt EQU $FFFA ; Sound Played Counter (bits3-0)
hSndPlaySetCnt EQU $FFFB ; Sound Req Counter (bits3-0) (if != hSndPlaySetCnt, start a new track)
hSndInfoCurDataPtr_Low EQU $FFFC ; Ptr to current sound channel data (initially copied from iSndInfo_DataPtr)
hSndInfoCurDataPtr_High EQU $FFFD ; Ptr to current sound channel data (initially copied from iSndInfo_DataPtr)


;--------------------------

; Elements in hTaskTbl entry struct
iTaskType EQU $00 ; Task type (TASK_EXEC_*)
iTaskPauseTimer EQU $01 ; Decrements every frame. If != 0, the task isn't marked in its TODO state.
iTaskPtr_Low EQU $02 ; Code or stack pointer
iTaskPtr_High EQU $03

; Elements in wGFXBufInfo struct
iGFXBufInfo_DestPtr_Low EQU $00		; Shared across buffers
iGFXBufInfo_DestPtr_High EQU $01
iGFXBufInfo_SrcPtr0_Low EQU $02
iGFXBufInfo_SrcPtr0_High EQU $03
iGFXBufInfo_Bank0 EQU $04
iGFXBufInfo_TilesLeft0 EQU $05
iGFXBufInfo_SrcPtr1_Low EQU $06
iGFXBufInfo_SrcPtr1_High EQU $07
iGFXBufInfo_Bank1 EQU $08
iGFXBufInfo_TilesLeft1 EQU $09
iGFXBufInfo_LastInfo EQU $0A ;
iGFXBufInfo_CompInfo EQU $10

; Elements in the wOBJInfo struct
iOBJInfo_Status EQU $00 ; Generic flags
iOBJInfo_UserFlags0 EQU $01 ; Set 0 - User-controlled sprite mapping flags
iOBJInfo_UserFlags1 EQU $02 ; Set 1 - User-controlled sprite mapping flags
iOBJInfo_X EQU $03 ; X Position
iOBJInfo_Y EQU $05 ; Y Position
iOBJInfo_RelX EQU $0B ; Relative X Position (autogenerated)
iOBJInfo_RelY EQU $0C ; Relative Y Position (autogenerated)
iOBJInfo_TileIDBase EQU $0D ; Starting tile ID (all tile IDs in the OBJ list are relative to this)
iOBJInfo_BankNum0 EQU $10 ; Set 0 - Bank number for sprite mapping table (animation table)
iOBJInfo_OBJLstPtrTbl_Low0 EQU $11 ; Set 0 - Ptr to OBJLstPtrTable (low byte)
iOBJInfo_OBJLstPtrTbl_High0 EQU $12 ; Set 0 - Ptr to OBJLstPtrTable (high byte)
iOBJInfo_OBJLstPtrTblOffset0 EQU $13 ; Set 0 - Table offset (multiple of $04)
iOBJInfo_BankNum1 EQU $14 ; Set 1 - Bank number for sprite mapping table (animation table)
iOBJInfo_OBJLstPtrTbl_Low1 EQU $15 ; Set 1 - Ptr to OBJLstPtrTable (low byte)
iOBJInfo_OBJLstPtrTbl_High1 EQU $16 ; Set 1 - Ptr to OBJLstPtrTable (high byte)
iOBJInfo_OBJLstPtrTblOffset1 EQU $17 ; Set 1 - Table offset (multiple of $04)

iOBJInfo_RangeMoveAmount EQU $1F 	; How many pixels the player is moved to keep him in range



; Elements in the primary OBJLst header/definition struct
iOBJLstHdr_Flags EQU $00
iOBJLstHdr_DataPtr_Low EQU $06 ; Ptr to iOBJLst_OBJCount
iOBJLstHdr_DataPtr_High EQU $07
iOBJLstHdr_XOffset EQU $08
iOBJLstHdr_YOffset EQU $09

; Elements in the secondary OBJLst header/definition struct
iOBJLstHdrSec_Flags EQU $00
iOBJLstHdrSec_DataPtr_Low EQU $04 ; Ptr to iOBJLst_OBJCount
iOBJLstHdrSec_DataPtr_High EQU $05
iOBJLstHdrSec_XOffset EQU $06
iOBJLstHdrSec_YOffset EQU $07


; Elements in the OBJLst "secondary header" struct
iOBJLst_OBJCount EQU $00
; Actual elements, right after iOBJLst_OBJCount
iOBJ_Y EQU $00
iOBJ_X EQU $01
iOBJ_TileIDAndFlags EQU $02

; Sound channel data header (ROM)
; =============== SONG FORMAT ===============
iSndHeader_NumChannels EQU $00 ; Number of channels (array of iSndChHeader structs comes next)
iSndChHeader_Status EQU $00 ; Matches iSndInfo_Status and so on
iSndChHeader_RegPtr EQU $01
iSndChHeader_DataPtr_Low EQU $02
iSndChHeader_DataPtr_High EQU $03
iSndChHeader_FreqDataIdBase EQU $04
iSndChHeader_Unused5 EQU $05

; Sound channel info (RAM)
iSndInfo_Status EQU $00 ; SndInfo status bitmask
iSndInfo_RegPtr EQU $01 ; Determines sound channel. Always points to rNR*3, and is never changed after being set.
iSndInfo_DataPtr_Low EQU $02 ; Pointer to song data (low byte)
iSndInfo_DataPtr_High EQU $03 ; Pointer to song data (high byte)
iSndInfo_FreqDataIdBase EQU $04 ; Base index/note id to Sound_FreqDataTbl for indexes > 0
iSndInfo_Unused05 EQU $05 ; Unused. Always $81 unless audio is interrupted.
iSndInfo_DataPtrStackIdx EQU $06 ; Stack index for data pointers saved and restored by Sound_Cmd_Call and Sound_Cmd_Ret. Initialized to $20 (end of SndInfo) and decremented on pushes.
iSndInfo_LengthTarget EQU $07 ; Handles delays -- the current sound register settings are kept until it matches iSndInfo_LengthTarget Set by song data.
iSndInfo_LengthTimer EQU $08 ; Increases every time a SndInfo isn't paused/disabled. Once it reaches iSndInfo_LengthTarget it resets.
iSndInfo_Unknown_Unused_9 EQU $09 ; ??? unused ?
iSndInfo_RegNRx1Data EQU $0A ; Last value written to rNR*1 | $FF00+(iSndInfo_RegPtr-2). Only written by Command IDs -- this isn't updated by the standard Sound_UpdateCustomRegs.
iSndInfo_Unknown_Unused_NR10Data EQU $0B ; ??? Last value written to NR10 by the (unused?) sound command
iSndInfo_VolPredict EQU $0C ; "Volume timer" which predicts the effective volume level (due to sweeps) at any given frame, used when restoring BGM playback. Low nybble is the timer, upper nybble is the predicted volume.
iSndInfo_RegNRx2Data EQU $0D ; Last value written to rNR*2 | $FF00+(iSndInfo_RegPtr-1)
iSndInfo_RegNRx3Data EQU $0E  ; Last value written to rNR*3 | $FF00+(iSndInfo_RegPtr)
iSndInfo_RegNRx4Data EQU $0F  ; Last value written to rNR*4 | $FF00+(iSndInfo_RegPtr+1)
iSndInfo_ChEnaMask EQU $10 ; Default rNR51 bitmask, used when a sound channel is enabled
iSndInfo_WaveSetId EQU $11 ; Id of last wave set loaded
iSndInfo_LoopTimerTbl EQU $12 ; Table with timers counting down, used to determine how many times to "jump" the data pointer elsewhere before continuing.
iSndInfo_End EQU $20 ; Pointer stack moving up