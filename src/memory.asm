
wDipSwitch EQU $C000 ; DIP-SWITCH options
wDifficulty EQU $C001
wMatchStartTime EQU $C002


wTimer EQU $C005 ; Global timer
wLCDCSectId EQU $C006 ; Starts at $00 on every frame, incremented when LCDC hits (to determine the parallax sections)
wVBlankNotDone EQU $C007 ; If != 0, the VBlank handler hasn't finished

wPaused EQU $C00E ; Game is paused
wOBJLstHeaderFlags EQU $C00F ; Raw flags value from the OBJLst header

wWorkOAMCurPtr_Low EQU $C010 ; Next OBJ will be written at this location
wWorkOAMCurPtr_High EQU $C011 ; 
; The status contain the actual *flags*, these are then initially copied here when drawing the sprites
wOBJLstCurStatusEx0 EQU $C012 ; Set 0 - Effective status for currently processed sprite mapping
; ???? User-controlled flags -- wOBJLstHeaderFlags is added on top of this.
wOBJLstCurStatusEx1 EQU $C013 ; Set 1 - Effective status for currently processed sprite mapping 
; ???????? User-controlled flags -- iOBJ flags specific to the secondary sprite mapping pointer in the OBJLstPtrTable entry, if any

wOBJLstCurStatus EQU $C014 ; Global status copied here for processing in OBJLstS_Common_L000C5B
wOBJLstOrigStatusEx EQU $C015 ; Original copy of the correct iOBJInfo_StatusEx* field for the currently processed sprite mapping
; wOBJLstCurDispX = wOBJLstCurRelX + wOBJLstCurXOffset
wOBJLstCurRelX EQU $C016 ; Calculated relative position/origin of the sprite mapping
wOBJLstCurRelY EQU $C017 ; Calculated relative position/origin of the sprite mapping
wOBJLstCurDispX EQU $C018 ; Effective X position of the displayed sprite mapping, relative to the screen
wOBJLstCurDispY EQU $C019 ; Effective Y position of the displayed sprite mapping, relative to the screen
wOBJLstCurFlags EQU $C01A ; Calculated flags for the sprite mapping (merge of wOBJLstCurStatusEx0 and wOBJLstOrigStatusEx)
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


wIntroLoopOBJAnim EQU $C1B3 ; If set in the intro, sprite animations are set to loop
wUnknownTimer_C1B3 EQU $C1B3

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



hScrollY            EQU $FFE2 ; Y screen position
hScrollYSub         EQU $FFE3 ; Y screen subpixel position
hScrollX            EQU $FFE4 ; X screen position
hScrollXSub         EQU $FFE5 ; X screen subpixel position
hTitleParallax1X    EQU $FFE6 ; X screen position
hTitleParallax1XSub EQU $FFE7
hTitleParallax2X    EQU $FFE8
hTitleParallax2XSub EQU $FFE9
hTitleParallax3X    EQU $FFEA
hTitleParallax3XSub EQU $FFEB
hTitleParallax4X    EQU $FFEC
hTitleParallax4XSub EQU $FFED
hTitleParallax5X    EQU $FFEE
hTitleParallax5XSub EQU $FFEF

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
iGFXBufInfo_DestPtr_Low  EQU $00 ; Shared - VRAM destination ptr
iGFXBufInfo_DestPtr_High EQU $01	
iGFXBufInfo_SrcPtrA_Low  EQU $02 ; Set A - Source GFX ptr
iGFXBufInfo_SrcPtrA_High EQU $03
iGFXBufInfo_BankA        EQU $04 ; Set A - Source GFX bank
iGFXBufInfo_TilesLeftA   EQU $05 ; Set A - (8x8) Tiles remaining
iGFXBufInfo_SrcPtrB_Low  EQU $06 ; Set B - Source GFX ptr
iGFXBufInfo_SrcPtrB_High EQU $07
iGFXBufInfo_BankB        EQU $08 ; Set B - Source GFX bank
iGFXBufInfo_TilesLeftB   EQU $09 ; Set B - (8x8) Tiles remaining
iGFXBufInfo_SetKey      EQU $0A ; ??? 5 bytes. Current set "Id". Combination of Set A settings.
iGFXBufInfo_DoneSetKey  EQU $10 ; ??? 5 bytes. Last completed set "id".

; Elements in the wOBJInfo struct
iOBJInfo_Status EQU $00 ; Both sets - OBJInfo flags
iOBJInfo_StatusEx0 EQU $01 ; ??? Set 0 - Extra OBJInfo flags (OR'd over)
iOBJInfo_StatusEx1 EQU $02 ; ??? Set 1 - Extra OBJInfo flags (OR'd over)
iOBJInfo_X EQU $03 ; X Position
iOBJInfo_XSub EQU $04 ; X Subpixel Position
iOBJInfo_Y EQU $05 ; Y Position
iOBJInfo_YSub EQU $06 ; Y Subpixel Position
iOBJInfo_SpeedX EQU $07 ; X speed - Added to iOBJInfo_X every frame
iOBJInfo_SpeedXSub EQU $08 ; X Subpixel speed - Added to iOBJInfo_XSub every frame
;iOBJInfo_SpeedY EQU $09 ; X speed
;iOBJInfo_SpeedYSub EQU $0A ; Y Subpixel speed
iOBJInfo_RelX EQU $0B ; Relative X Position (autogenerated)
iOBJInfo_RelY EQU $0C ; Relative Y Position (autogenerated)
iOBJInfo_TileIDBase EQU $0D ; Starting tile ID (all tile IDs in the OBJ list are relative to this)
iOBJInfo_VRAMPtr_Low EQU $0E ; VRAM GFX Pointer (low byte) - GFX is written to this address for buffer A, typically is $8000 or $8400
iOBJInfo_VRAMPtr_High EQU $0F ; VRAM GFX Pointer (high byte)
iOBJInfo_BankNum0 EQU $10 ; Set 0 - Bank number for OBJLstPtrTable (animation table)
iOBJInfo_OBJLstPtrTbl_Low0 EQU $11 ; Set 0 - Ptr to OBJLstPtrTable (low byte)
iOBJInfo_OBJLstPtrTbl_High0 EQU $12 ; Set 0 - Ptr to OBJLstPtrTable (high byte)
iOBJInfo_OBJLstPtrTblOffset0 EQU $13 ; Set 0 - Table offset (multiple of $04)
iOBJInfo_BankNum1 EQU $14 ; Set 1 - Bank number for OBJLstPtrTable (animation table)
iOBJInfo_OBJLstPtrTbl_Low1 EQU $15 ; Set 1 - Ptr to OBJLstPtrTable (low byte)
iOBJInfo_OBJLstPtrTbl_High1 EQU $16 ; Set 1 - Ptr to OBJLstPtrTable (high byte)
iOBJInfo_OBJLstPtrTblOffset1 EQU $17 ; Set 1 - Table offset (multiple of $04)
iOBJInfo_OBJLstByte1 EQU $18 ; iOBJLstHdrA_Byte1 is copied here during exec - skips something during gameplay
iOBJInfo_OBJLstByte2 EQU $19 ; iOBJLstHdrA_Byte2 is copied here during exec - skips something during gameplay
iOBJInfo_Unknown_1A EQU $1A
iOBJInfo_FrameLeft EQU $1B ; Number of frames left before switching to the next anim frame.
iOBJInfo_FrameTotal EQU $1C ; Animation speed. New frames will have iOBJInfo_FrameLeft set to this.
iOBJInfo_BufInfoPtr_Low EQU $1D ; GFX Buffer info struct pointer (low byte)
iOBJInfo_BufInfoPtr_High EQU $1E ; GFX Buffer info struct pointer (high byte)
iOBJInfo_RangeMoveAmount EQU $1F ; How many pixels the player is moved to keep him in range


; Sprite mapping fields.

; OBJLstPtrTable A entry elements
iOBJLstHdrA_Flags EQU $00
iOBJLstHdrA_Byte1 EQU $01 ; ??? - skips something during gameplay
iOBJLstHdrA_Byte2 EQU $02 ; ??? - skips something during gameplay
iOBJLstHdrA_GFXPtr_Low EQU $03 ; Ptr to uncompressed GFX (low byte) - will be copied to the GfxInfo
iOBJLstHdrA_GFXPtr_High EQU $04 ; Ptr to uncompressed GFX (high byte)
iOBJLstHdrA_GFXBank EQU $05 ; Bank num with GFX
iOBJLstHdrA_DataPtr_Low EQU $06 ; Ptr to iOBJLst (low byte)
iOBJLstHdrA_DataPtr_High EQU $07 ; Ptr to iOBJLst (high byte)
iOBJLstHdrA_XOffset EQU $08
iOBJLstHdrA_YOffset EQU $09

; OBJLstPtrTable B entry elements
iOBJLstHdrB_Flags EQU $00
iOBJLstHdrB_GFXPtr_Low EQU $01
iOBJLstHdrB_GFXPtr_High EQU $02
iOBJLstHdrB_GFXBank EQU $03
iOBJLstHdrB_DataPtr_Low EQU $04
iOBJLstHdrB_DataPtr_High EQU $05
iOBJLstHdrB_XOffset EQU $06
iOBJLstHdrB_YOffset EQU $07

; Actual OBJLst format
iOBJLst_OBJCount EQU $00
; List of OBJ in "compressed" format, right after iOBJLst_OBJCount
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