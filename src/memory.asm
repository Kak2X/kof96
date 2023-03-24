
vGFXProjectile1P        EQU $8800
vGFXProjectile2P        EQU $8A60
vGFXSuperSparkle        EQU $8CC0


vBGHealthBar1P          EQU $9C20
vBGHealthBar1P_Last     EQU vBGHealthBar1P+$08

vBGRoundTime            EQU $9C29

vBGHealthBar2P          EQU $9C2B
vBGHealthBar2P_Last     EQU vBGHealthBar2P+$08

vBGPowBar1P_Left        EQU $9C83
vBGPowBar2P_Left        EQU $9C8C


wBGMaxPowBarRow         EQU $9CA0

; EQUs relative to the Japanese version
SECTION "Settings RAM", WRAM0[$C000]
wDipSwitch              :db ; EQU $C000 ; DIP-SWITCH options
wDifficulty             :db ; EQU $C001
wMatchStartTime         :db ; EQU $C002

SECTION "Main RAM", WRAM0[$C005]
wTimer                  :db ; EQU $C005 ; Global timer
wLCDCSectId             :db ; EQU $C006 ; Starts at $00 on every frame, incremented when LCDC hits (to determine the parallax sections)
wVBlankNotDone          :db ; EQU $C007 ; If != 0, the VBlank handler hasn't finished
wPlayTimer              :db ; EQU $C008 ; Timer that increments every frame of gameplay (but not when pausing or in the intro)
wRand                   :db ; EQU $C009 ; Last random value for the Rand function not using LY
wRandLY                 :db ; EQU $C00A ; Last random value for the Rand function using LY

ds $C00E-$C00B

wNoCopyGFXBuf           :db ; EQU $C00E ; If set, disables the GFX copy during VBlank
wOBJLstCurHeaderFlags   :db ; EQU $C00F ; Raw flags value from the OBJLst header
wWorkOAMCurPtr_Low      :db ; EQU $C010 ; Next OBJ will be written at this location
wWorkOAMCurPtr_High     :db ; EQU $C011 ; 
UNION
wOBJLstTmpROMFlags      :db ; EQU $C012 ; Calculated status flags for the sprite mapping
NEXTU
wOBJLstTmpStatusNew     :db ; EQU $C012 ; For OBJLstS_UpdateGFXBufInfo
ENDU
wOBJLstCurStatus        :db ; EQU $C013 ; Temporary copy of iOBJInfo_Status
wOBJLstTmpStatusOld     :db ; EQU $C014 ; For OBJLstS_UpdateGFXBufInfo


wOBJLstOrigFlags        :db ; EQU $C015 ; Original copy of the correct iOBJInfo_OBJLstFlags* field for the currently processed sprite mapping
; wOBJLstCurDispX = wOBJLstCurRelX + wOBJLstCurXOffset
wOBJLstCurRelX          :db ; EQU $C016 ; Calculated relative position/origin of the sprite mapping
wOBJLstCurRelY          :db ; EQU $C017 ; Calculated relative position/origin of the sprite mapping
wOBJLstCurDispX         :db ; EQU $C018 ; Effective X position of the displayed sprite mapping, relative to the screen
wOBJLstCurDispY         :db ; EQU $C019 ; Effective Y position of the displayed sprite mapping, relative to the screen
wOBJLstCurFlags         :db ; EQU $C01A ; Calculated flags for the sprite mapping (merge of wOBJLstCurFlags and wOBJLstOrigFlags)
wOBJLstCurXOffset       :db ; EQU $C01B ; Offset added to wOBJLstCurRelX, and the result goes to wOBJLstCurDispX
wOBJLstCurYOffset       :db ; EQU $C01C ; Offset added to wOBJLstCurRelX, and the result goes to wOBJLstCurDispY


ds $C025-$C01D

wMisc_C025              :db ; EQU $C025 ; Serial + SGB
wMisc_C026              :db ; EQU $C026 ; Task
wMisc_C027              :db ; EQU $C027 ; Gameplay
wMisc_C028              :db ; EQU $C028 ; Sect

UNION
wTitleMode              :db ; EQU $C029
NEXTU
wIntroScene             :db ; EQU $C029 ; Offset to scene ID in scene pointer table (some scenes have different parts)
ENDU
wIntroCharScene         :db ; EQU $C02A ; Offset to the subscene ID when animating player sprites



wSGBSendPacketAtFrameEnd    :db     ; EQU $C02B ; If set, there are SGB packets to send after all tasks are processed
wSGBSoundPacket             :ds $10 ; EQU $C02C ; Data for the sound effect packet to be sent at the end of the frame.

wSerialIntPtr_Low                  :db     ; EQU $C03C
wSerialIntPtr_High                 :db     ; EQU $C03D
wSerialDataReceiveBuffer           :ds $80 ; EQU $C03E
UNION
wSerialDataReceiveBuffer_End       :db     ; EQU $C0BE
NEXTU
wSerialDataSendBuffer              :ds $80 ; EQU $C0BE
ENDU
UNION
wSerialDataSendBuffer_End          :db     ; EQU $C13E
NEXTU
wSerialDataReceiveBufferIndex_Head :db     ; EQU $C13E
ENDU
wSerialDataReceiveBufferIndex_Tail :db     ; EQU $C13F
wSerialDataSendBufferIndex_Head    :db     ; EQU $C140 ; Index of most recent buffer entry
wSerialDataSendBufferIndex_Tail    :db     ; EQU $C141 ; Index of last buffer entry - used for current player input in VS serial
; These mark the balance for increasing the head/tail indexes
wSerialReceivedLeft                :db     ; EQU $C142 ; Number of received bytes wSerialDataReceiveBufferIndex_Tail is behind of. 
wSerialSentLeft                    :db     ; EQU $C143 ; Number of sent bytes wSerialDataReceiveBufferIndex_Tail is behind of.
wSerial_Unknown_Unused_C144        :db     ; EQU $C144
wSerialPlayerId                    :db     ; EQU $C145 ; Determines who is 1P/2P due to an implementation detail of how MODESELECT_SBCMD_* is sent.
wSerialTransferDone                :db     ; EQU $C146 ; Marks if the serial handler was executed for the frame? otherwise waits
wSerialPendingJoyKeys              :db     ; EQU $C147 ; Player 1 Only - Next inputs to send after receiving a byte
wSerialPendingJoyNewKeys           :db     ; EQU $C148
wSerialPendingJoyKeys2             :db     ; EQU $C149 ; Player 2 Only - Next inputs to send after receiving a byte
wSerialPendingJoyNewKeys2          :db     ; EQU $C14A ;
wSerialInputMode                   :db     ; EQU $C14B ; If set, controls are enabled during serial mode
wSGBBorderType                     :db     ; EQU $C14C ; Current border type loaded 
wFontLoadBit1Col                   :db     ; EQU $C14D ; 2pp color mapped to bit1 on 1bpp graphics
wFontLoadBit0Col                   :db     ; EQU $C14E ; 2pp color mapped to bit0 on 1bpp graphics
wFontLoadTmpGFX                    :ds 2   ; EQU $C14F ; 2 bytes (size of a line)

wTextPrintFlags             :db ; EQU $C151
wTextPrintFrameCodeBank     :db ; EQU $C152 ; Bank number of the custom code
wTextPrintFrameCodePtr_Low  :db ; EQU $C153 ; Ptr to the code itself
wTextPrintFrameCodePtr_High :db ; EQU $C154


wOBJScrollX                 :db ; EQU $C155 ; X position *subtracted* to every OBJ.
ds 1 ; Missing subpixel position
wOBJScrollY                 :db ; EQU $C157 ; Y position *subtracted* to every OBJ.
ds 1 ; Missing subpixel position
wScreenShakeY               :db ; EQU $C159 ; Y offset "subtracted" from hScrollY, for vertical screen shake effects. won't alter sprites.
; a supposed wScreenSect0LYC for the first section is fixed, and always starts at $00
wScreenSect1LYC             :db ; EQU $C15A ; Scanline number the second screen section starts. During gameplay, it's the playfield.
wScreenSect2LYC             :db ; EQU $C15B ; Scanline number the third screen section starts. During gameplay, it's the meter HUD
wBonusFightId               :db ; EQU $C15C ; If set, the ID of the special team. (BONUS_ID_*) These receive special endings and/or bonus matches.
; Temporary copy of the team char id table (iPlInfo_TeamCharId*) for the active player side.
; Character ID checks to determine wBonusFightId are made on this.
wSpecTeamActiveCharId0      :db ; EQU $C15D ; 1st team member ID 
wSpecTeamActiveCharId1      :db ; EQU $C15E ; 2nd team member ID 
wSpecTeamActiveCharId2      :db ; EQU $C15F ; 2nd team member ID 


wRoundFinal                 :db ; EQU $C160 ; If set, this is the "FINAL!!" round, displayed when all characters in both sides are marked as defeated (requires a draw)
wStageDraw                  :db ; EQU $C161 ; If set, forces the "DRAW" screen to appear in single mode when the stage ends. Single-mode specific.
wLastWinner                 :db ; EQU $C162 ; Marks using bits the player who won the last round.
wPlayMode                   :db ; EQU $C163 ; Single/Team 1P/VS
wRoundTotal                 :db ; EQU $C164 ; Total number of rounds played since the system was on. Never read back.
wJoyActivePl                :db ; EQU $C165 ; Determines the active SGB pad, generally for 1P modes.
wStageId                    :db ; EQU $C166 ; Stage ID. Determines music, backdrop and palette.
wRoundNum                   :db ; EQU $C167 ; Round number in a stage
ds 1
wRoundTime                  :db ; EQU $C169 ; Round timer
wRoundTimeSub               :db ; EQU $C16A ; Round subsecond timer

wPlayMaxPowScroll1P         :db ; EQU $C16B ; Scrolls on-screen or off-screen the 1P MAX Power bar
wPlayMaxPowScrollBGOffset1P :db ; EQU $C16C ; Tilemap offset, determines where the 1P MAX Power bar starts (special version of iPlInfo_MaxPowBGPtr)
wPlayMaxPowScrollTimer1P    :db ; EQU $C16D ; Countdown. When it elapses, the scroll animation ends
wPlayMaxPowScroll2P         :db ; EQU $C16E ; Scrolls on-screen or off-screen the 2P MAX Power bar
wPlayMaxPowScrollBGOffset2P :db ; EQU $C16F ; Tilemap offset, determines where the 2P MAX Power bar starts (special version of iPlInfo_MaxPowBGPtr)
wPlayMaxPowScrollTimer2P    :db ; EQU $C170 ; Countdown. When it elapses, the scroll animation ends
wPlayHitstopSet             :db ; EQU $C171 ; Requests hitstop for the next frame.
wPlayHitstop                :db ; EQU $C172 ; If set, hitstop is applied. Due to how tasks are carefully managed, this is only applied to 
wPlayPlThrowActId           :db ; EQU $C173 ; Act ID for a throw. This is global since two throws can't be active at once.
wPlayPlThrowOpMode          :db ; EQU $C174 ; PLAY_THROWOP_*
wPlayPlThrowDir             :db ; EQU $C175 ; Sets the throw's direction. (PLAY_THROWDIR_*)
;--
; Movement amounts set by Play_Pl_MoveRotThrown, used to move the opponent at fixed relative positions,
; mostly during the "rotation frames" before the throw arc starts.
; This avoids having to define the offsets in the sprite mapping itself.
wPlayPlThrowRotMoveH        :db ; EQU $C176 ; Relative X position
wPlayPlThrowRotMoveV        :db ; EQU $C177 ; Relative Y position
wPlayPlThrowRotSync         :db ; EQU $C178 ; If set, allows few moves in the "attacked" group to use the above two
;--
wPlayPlThrowTechTimer       :db ; EQU $C179 ; Countdown timer, window of opportunity for doing a throw tech.
wPlaySlowdownTimer          :db ; EQU $C17A ; Countdown timer. When it's > 0, slowdown is enabled during gameplay. When it reaches 0, the slowdown stops.
wPlaySlowdownSpeed          :db ; EQU $C17B ; Determines how much the game should slow down. Execution is 1 every (wPlaySlowdownSpeed) frames.
wStageBGP                   :db ; EQU $C17C ; Determines palette for playfield (used to handle screen flashing)
wPauseFlags                 :db ; EQU $C17D ; Contains flags the pause state
wUnused_ContinueUsed        :db ; EQU $C17E ; If set, a continue was used. Not read by anything.
wCharSeqId                  :db ; EQU $C17F ; "Stage sequence number". Index to the char sequence table, essentially the number of beat opponents after clearing a stage
wCharSeqTbl                 :ds $14 ; EQU $C180 ; "Stage sequence". Sequence of CPU opponents in order, containing initially CHARSEL_ID_* for normal rounds and CHAR_ID_* for bosses
wCharSelIdMapTbl            :ds $15 ; EQU $C194 ; Maps cursor locations in the char select screen (CHARSEL_ID_*) to actual character IDs (CHAR_ID_*)
                                      ; $15 bytes ($C194-$C1A8), this is updated when flipping a tile.



; Mode-specific block starting from $C1A9

UNION
;
; GENERAL
;
ds $C1C5-$C1A9
wSerialLagCounter           :db ; EQU $C1C5 ; Amount of frames the serial lags for the slave
wSerial_Unknown_Unused_C1C6 :db ; EQU $C1C6
wLZSS_CurCmdMask            :db ; EQU $C1C7
wLZSS_SplitNum              :db ; EQU $C1C8
wLZSS_SplitMask             :db ; EQU $C1C9
wLZSS_Buffer                :db ; EQU $C1CA

NEXTU
;
; TAKARA LOGO
;
ds $C1CA-$C1A9
wCheatGoenitzKeysLeft       :db ; EQU $C1CA ; Amount of times to press the button before cheat activates
wCheatAllCharKeysLeft       :db ; EQU $C1CB ; each for the 4 cheats
wCheat_Unused_KeysLeft      :db ; EQU $C1CC
wCheatEasyMovesKeysLeft     :db ; EQU $C1CD

NEXTU
;
; INTRO
;
ds $C1B3-$C1A9
wIntroLoopOBJAnim           :db ; EQU $C1B3 ; If set in the intro, sprite animations are set to loop

;
; TITLE / OPTIONS
;
wTitleMenuOptId             :db ; EQU $C1B4 ; Cursor location in title screen
wTitleMenuCursorXBak        :db ; EQU $C1B5 ; Backup location of cursor X position
wTitleMenuCursorYBak        :db ; EQU $C1B6 ; Backup location of cursor Y position
wTitleSubMenuOptId          :db ; EQU $C1B7 ; Cursor location for Game Select / Option menus
wOptionsSGBSndOptId         :db ; EQU $C1B8 ; Vertical cursor location in the SGB Sound Test
wOptionsBGMId               :db ; EQU $C1B9 ; ID of the selected music in the BGM Test
wOptionsSFXId               :db ; EQU $C1BA ; ID of the selected sound effect in the SFX Test
wOptionsMenuMode            :db ; EQU $C1BB ; $00 -> Normal, $02 -> SGB Sound Test
wTitleBlinkTimer            :db ; EQU $C1BC ; Increments in the title screen, determines when to hide or show blinking sprites
; These are ordered in the same way as OPTION_SITEM_*
wOptionsSGBSndIdA           :db ; EQU $C1BD ; Selected SGB Sound Id - Set A
wOptionsSGBSndBankA         :db ; EQU $C1BE ; Selected SGB Bank number Id - Set A
wOptionsSGBSndIdB           :db ; EQU $C1BF ; Selected SGB Sound Id - Set B
wOptionsSGBSndBankB         :db ; EQU $C1C0 ; Selected SGB Bank number Id - Set B
wOptionsSGBBase             EQU wOptionsSGBSndIdA
wTitleResetTimer_High       :db ; EQU $C1C1
wTitleResetTimer_Low        :db ; EQU $C1C2
wTitleParallaxBaseSpeed     :db ; EQU $C1C3 ; Extra cloud speed - Pixels
wTitleParallaxBaseSpeedSub  :db ; EQU $C1C4 ; Extra cloud speed - Subpixels
ds $C1CA-$C1C5
wOptionsSGBPacketSnd        :db ; EQU $C1CA ; Start of SGB packet used when selecting a song in the sound test
wOptionsSGBPacketSndIdA     :db ; EQU $C1CB ; Byte 1 determines Sound ID A
wOptionsSGBPacketSndIdB     :db ; EQU $C1CC ; Byte 2 determines Sound ID B
wOptionsSGBPacketSndBank    :db ; EQU $C1CD ; Byte 3 determines Sound Bank

NEXTU
;
; CHARACTER SELECT
;
wCharSelP1CursorPos         :db ; EQU $C1A9 ; Player 1 cursor position, CHARSEL_ID_*
wCharSelP2CursorPos         :db ; EQU $C1AA ; Player 2 cursor position, CHARSEL_ID_*
; Character ID selected for both players
wCharSelP1Char0             :db ; EQU $C1AB
wCharSelP1Char1             :db ; EQU $C1AC
wCharSelP1Char2             :db ; EQU $C1AD
wCharSelP2Char0             :db ; EQU $C1AE
wCharSelP2Char1             :db ; EQU $C1AF
wCharSelP2Char2             :db ; EQU $C1B0
wCharSelRandom1P            :db ; EQU $C1B1 ; Randomize team on 1P side
wCharSelRandom2P            :db ; EQU $C1B2 ; Randomize team on 2P side
wCharSelTeamFull            :db ; EQU $C1B3 ; Temporary value when adding characters, determines if more can be added
wCharSelP1CursorMode        :db ; EQU $C1B4
wCharSelP2CursorMode        :db ; EQU $C1B5
wCharSelCurPl               :db ; EQU $C1B6 ; Player num currently handled in the character select screen.
wCharSelRandomDelay1P       :db ; EQU $C1B7 ; Delay until the CPU autopicks the next character
wCharSelRandomDelay2P       :db ; EQU $C1B8 ; Delay until the CPU autopicks the next character

NEXTU
;
; ORDER SELECT
;
ds $C1B1-$C1A9
wOrdSelCPUDelay1P           :db ; EQU $C1B1 ; Delay between CPU picks
wOrdSelCPUDelay2P           :db ; EQU $C1B2 ; Delay between CPU picks
ds 1
wOrdSelP1CharsSelected      :db ; EQU $C1B4
wOrdSelP2CharsSelected      :db ; EQU $C1B5
wOrdSelCurPl                :db ; EQU $C1B6 ; Player num currently handled in the character select screen.
ds $C1CA-$C1B7
wOrdSelP1CursorPos          :db ; EQU $C1CA
wOrdSelP2CursorPos          :db ; EQU $C1CB
wOrdSelTmpP1CharId          :db ; EQU $C1CC ; Temporary value containing selected character ID
wOrdSelTmpP2CharId          :db ; EQU $C1CD
; The last number of these labels doesn't have the same meaning in these pairs.
; wOrdSelP*CharSel -> number of the character slot (ie: 0 is leftmost for 1P, rightmost for 2P)
; wOrdSelP*CharId -> team member order (ie: at 0 is the first picked character)
wOrdSelP1CharSel0           :db ; EQU $C1CE
wOrdSelP1CharId0            :db ; EQU $C1CF
wOrdSelP1CharSel1           :db ; EQU $C1D0
wOrdSelP1CharId1            :db ; EQU $C1D1
wOrdSelP1CharSel2           :db ; EQU $C1D2
wOrdSelP1CharId2            :db ; EQU $C1D3
wOrdSelP2CharSel0           :db ; EQU $C1D4
wOrdSelP2CharId0            :db ; EQU $C1D5
wOrdSelP2CharSel1           :db ; EQU $C1D6
wOrdSelP2CharId1            :db ; EQU $C1D7
wOrdSelP2CharSel2           :db ; EQU $C1D8
wOrdSelP2CharId2            :db ; EQU $C1D9
; Backup copies of the wOrdSelP*CursorPos, used by OrdSel_Ctrl_SelChar
wOrdSelP1CursorPosBak       :db ; EQU $C1DA
wOrdSelP2CursorPosBak       :db ; EQU $C1DB
NEXTU

;
; GAMEPLAY
;
ds $C1CA-$C1A9
wPlaySecIconBuffer          :db ; EQU $C1CA ; Buffer for drawing the overlapping secondary icons in team mode
wPlayCrossBuffer            EQU wPlaySecIconBuffer+$100
wPlayCrossMaskBuffer        EQU wPlaySecIconBuffer+$140

NEXTU
ds $C1CA-$C1A9
; Temporary variables used for collision box overlap checks between two boxes (marked as A and B)
wPlayTmpColiA_OBJLstFlags   :db ; EQU $C1CA ; Sprite mapping flags, to determine if it should be flipped
wPlayTmpColiB_OBJLstFlags   :db ; EQU $C1CB
ds $C1D4-$C1CC
wPlayTmpColiA_OriginH       :db ; EQU $C1D4 ; Left side of collision box, relative to player X pos (usually negative or 0)
wPlayTmpColiA_OriginV       :db ; EQU $C1D5 ; Top side of collision box, relative to player Y pos (usually negative or 0)
wPlayTmpColiA_RadH          :db ; EQU $C1D6 ; Collision box horizontal radius (extends to both sides of origin)
wPlayTmpColiA_RadV          :db ; EQU $C1D7 ; Collision box vertical radius (extends to both sides of origin)
wPlayTmpColiA               EQU wPlayTmpColiA_OriginH

; See above, but for other player
ds $C1DE-$C1D8
wPlayTmpColiB_OriginH       :db ; EQU $C1DE
wPlayTmpColiB_OriginV       :db ; EQU $C1DF
wPlayTmpColiB_RadH          :db ; EQU $C1E0
wPlayTmpColiB_RadV          :db ; EQU $C1E1
wPlayTmpColiB               EQU wPlayTmpColiB_OriginH

NEXTU
;
; WIN SCREEN / CUTSCENES
;
ds $C1B3-$C1A9
wWinPlInfoPtr_Low           :db ; EQU $C1B3 ; Ptr to the wPlInfo that won the stage (low byte)
wWinPlInfoPtr_High          :db ; EQU $C1B4 ; "" (high byte)
ds $C1CA-$C1B5
wCutMoveLargeChars          :db ; EQU $C1CA ; If enabled, the large Kagura and Goenitz cutscene characters will be moved
wCutFlashTimer              :db ; EQU $C1CB ; Timer that handles the palette flash effect during cutscenes.
wCutFlash2Timer             :db ; EQU $C1CC ; Timer that handles the secondary palette flash during the ending cutscene.

NEXTU
;
; CONTINUE
;
ds $C1B3-$C1A9
wWinContinueTimer           :db ; EQU $C1B3 ; Continue timer - seconds left
wWinContinueTimerSub        :db ; EQU $C1B4 ; Continue timer - frames left before decrementing second
ENDU


SECTION "Audio RAM", WRAM0[$D480]
;
; SOUND DRIVER
;
wSnd_Unk_Unused_D480        :db ; EQU $D480 ; $80 is always written here, but never read back
wSnd_Unused_ChUsed          :db ; EQU $D481 ; Appears to be a bitmask intended to mark the used sound channels, but it is only set properly in unreachable code.
wSndEnaChBGM                :db ; EQU $D482 ; Keeps track of the last rNR51 value used modified by a BGM SndInfo.
wSnd_Ch3StopLength          :db ; EQU $D483 ; This is set to rNR31 sometimes (see logic)
ds 1
wSndChProcLeft              :db ; EQU $D485 ; Number of remaining wBGMCh*Info/wSFXCh*Info structs to process

; Channel playback status (separate lanes for BGM and SFX)
ds $20
wBGMCh1Info                 :ds $20 ; EQU $D4A6
wBGMCh2Info                 :ds $20 ; EQU $D4C6
wBGMCh3Info                 :ds $20 ; EQU $D4E6
wBGMCh4Info                 :ds $20 ; EQU $D506
wSFXCh1Info                 :ds $20 ; EQU $D526
wSFXCh2Info                 :ds $20 ; EQU $D546
wSFXCh3Info                 :ds $20 ; EQU $D566
wSFXCh4Info                 :ds $20 ; EQU $D586

ds $D5F8-$D5A6
wSndIdReqTbl                :ds $08 ; EQU $D5F8 ; Sound IDs to play are written here


SECTION "OBJLst / Player RAM", WRAM0[$D680]
;
; SPRITE MAPPINGS
;
wOBJInfo0                   :ds $40 ; EQU $D680
wOBJInfo1                   :ds $40 ; EQU $D6C0
wOBJInfo2                   :ds $40 ; EQU $D700
wOBJInfo3                   :ds $40 ; EQU $D740
wOBJInfo4                   :ds $40 ; EQU $D780
wOBJInfo5                   :ds $40 ; EQU $D7C0
wOBJInfo6                   :ds $40 ; EQU $D800
wOBJInfo7                   :ds $40 ; EQU $D840
wOBJInfo8                   :ds $40 ; EQU $D880

; Special purpose mappings
; General
wOBJInfo_Pl1                EQU wOBJInfo0
wOBJInfo_Pl2                EQU wOBJInfo1

; Intro
wOBJInfo_IIoriH             EQU wOBJInfo2
wOBJInfo_IIoriL             EQU wOBJInfo3

; Title screen
wOBJInfo_CursorR            EQU wOBJInfo0
wOBJInfo_MenuText           EQU wOBJInfo1
wOBJInfo_SnkText            EQU wOBJInfo2
wOBJInfo_CursorU            EQU wOBJInfo3
; Character select
wOBJInfo_IoriFlip           EQU wOBJInfo2
wOBJInfo_LeonaFlip          EQU wOBJInfo3
wOBJInfo_ChizuruFlip        EQU wOBJInfo4
; Gameplay
wOBJInfo_RoundText          EQU wOBJInfo3 ; Pre-round text and post-round text
wOBJInfo_Pl1Cross           EQU wOBJInfo4
wOBJInfo_Pl2Cross           EQU wOBJInfo5
wOBJInfo_Pl1Projectile      EQU wOBJInfo2
wOBJInfo_Pl2Projectile      EQU wOBJInfo3
wOBJInfo_Pl1SuperSparkle    EQU wOBJInfo4
wOBJInfo_Pl2SuperSparkle    EQU wOBJInfo5
wOBJInfo_TerryHat           EQU wOBJInfo2
; Win Screen
wOBJInfo_Winner             EQU wOBJInfo_Pl1
; Cutscene
wOBJInfo_Kagura             EQU wOBJInfo_Pl1

wGFXBufInfo_Pl1             :ds $20 ; EQU $D8C0
wGFXBufInfo_Pl2             :ds $20 ; EQU $D8E0

wPlInfo_Pl1                 :ds $100 ; EQU $D900
wPlInfo_Pl2                 :ds $100 ; EQU $DA00

SECTION "OAM Mirror", WRAM0[$DF00]
wWorkOAM                    :ds OBJ_SIZE*OBJCOUNT_MAX ; EQU $DF00
wWorkOAM_End                EQU wWorkOAM+OBJ_SIZE*OBJCOUNT_MAX ; $DFA0


SECTION "HRAM", HRAM[$FF80]
;
; HIGH RAM
;
hOAMDMA                     :ds $18 ; EQU $FF80 ; OAMDMA routine
hJoyKeys                    :db     ; EQU $FF98 ; Player 1 - (Held) Joypad keys
hJoyNewKeys                 :db     ; EQU $FF99 ; Player 1 - Newly pressed keys
ds 1
hJoyKeysDelayTbl            :ds $10 ; EQU $FF9B ; Player 1 - Menu hold delay info ($10 bytes, 2 for each KEY_*)

hJoyKeys2                   :db     ; EQU $FFAB ; Player 2 - (Held) Joypad keys
hJoyNewKeys2                :db     ; EQU $FFAC ; Player 2 - Newly pressed keys
ds 1
hJoyKeys2DelayTbl           :ds $10 ; EQU $FFAE

ds 2
hTaskStats                  :db     ; EQU $FFC0 ; Global task system info
hCurTaskId                  :db     ; EQU $FFC1 ; Current task id ($01-$03)
ds 6
hTaskTbl                    :ds $03*TASK_SIZE ; EQU $FFC8 ; Task struct list

hROMBank                    :db     ; EQU $FFE0 ; Currently loaded ROM bank


ds 1
hScrollY                    :db ; EQU $FFE2 ; Y screen position
hScrollYSub                 :db ; EQU $FFE3 ; Y screen subpixel position
hScrollX                    :db ; EQU $FFE4 ; X screen position
hScrollXSub                 :db ; EQU $FFE5 ; X screen subpixel position
hTitleParallax1X            :db ; EQU $FFE6 ; X screen position
hTitleParallax1XSub         :db ; EQU $FFE7
hTitleParallax2X            :db ; EQU $FFE8
hTitleParallax2XSub         :db ; EQU $FFE9
hTitleParallax3X            :db ; EQU $FFEA
hTitleParallax3XSub         :db ; EQU $FFEB
hTitleParallax4X            :db ; EQU $FFEC
hTitleParallax4XSub         :db ; EQU $FFED
hTitleParallax5X            :db ; EQU $FFEE
hTitleParallax5XSub         :db ; EQU $FFEF

hScreenSect0BGP             :db ; EQU $FFF0 ; BG Palette for the first screen section
hScreenSect1BGP             :db ; EQU $FFF1 ; ...
hScreenSect2BGP             :db ; EQU $FFF2
ds 5
hSndInfoCurPtr_Low          :db ; EQU $FFF8 ; Ptr to Currently processed SNDInfo structure
hSndInfoCurPtr_High         :db ; EQU $FFF9 ; Ptr to Currently processed SNDInfo structure

hSndPlayCnt                 :db ; EQU $FFFA ; Sound Played Counter (bits3-0)
hSndPlaySetCnt              :db ; EQU $FFFB ; Sound Req Counter (bits3-0) (if != hSndPlaySetCnt, start a new track)
hSndInfoCurDataPtr_Low      :db ; EQU $FFFC ; Ptr to current sound channel data (initially copied from iSndInfo_DataPtr)
hSndInfoCurDataPtr_High     :db ; EQU $FFFD ; Ptr to current sound channel data (initially copied from iSndInfo_DataPtr)


;--------------------------
;
; STRUCTS
;

; Elements in hTaskTbl entry struct
iTaskType                   EQU $00 ; Task type (TASK_EXEC_*)
iTaskPauseTimer             EQU $01 ; Decrements every frame. If != 0, the task isn't marked in its TODO state.
iTaskPtr_Low                EQU $02 ; Code or stack pointer
iTaskPtr_High               EQU $03

; Elements in hJoyKeysDelayTbl entry struct
iKeyMenuHeld                EQU $00
iKeyMenuTimer               EQU $01

; Elements in wGFXBufInfo struct
; Set A -> Primary sprite mapping
; Set B -> Secondary sprite mapping, not always present
iGFXBufInfo_DestPtr_Low     EQU $00 ; Shared - VRAM destination ptr
iGFXBufInfo_DestPtr_High    EQU $01	
iGFXBufInfo_SrcPtrA_Low     EQU $02 ; Set A - Source GFX ptr
iGFXBufInfo_SrcPtrA_High    EQU $03
iGFXBufInfo_BankA           EQU $04 ; Set A - Source GFX bank
iGFXBufInfo_TilesLeftA      EQU $05 ; Set A - (8x8) Tiles remaining
iGFXBufInfo_SrcPtrB_Low     EQU $06 ; Set B - Source GFX ptr
iGFXBufInfo_SrcPtrB_High    EQU $07
iGFXBufInfo_BankB           EQU $08 ; Set B - Source GFX bank
iGFXBufInfo_TilesLeftB      EQU $09 ; Set B - (8x8) Tiles remaining
iGFXBufInfo_SetKey          EQU $0A ; 5 bytes. Current set "Id". Combination of Set A settings.
iGFXBufInfo_SetKeyView      EQU $10 ; 5 bytes. Last completed set "id".

; Some of the fields that have the "View" suffix also have a field without it.
; They are used to help with double buffering, and are completely unrelated to the "Set A" and "Set B" of wGFXBufInfo.
;
; ie:
; - iOBJInfo_OBJLstFlags: Flags for the *internal* current sprite mapping.
;                         When loading new graphics, this is treated as the pending value.
; - iOBJInfo_OBJLstFlagsView: Flags for the *visible* current sprite mapping.
;                             When a sprite mapping uses the GFX buffer system, this is guaranteed to always
;                             match what's visible on screen, even if the internal value is what gets used.
;
; The "View" fields however are only used when graphics are loading on the pending buffer, so they
; are referred to as the "Old" set. This is for compatibility with sprite mappings that don't load
; dynamic graphics -- because of how the data/system was set up, those don't have valid entries in the "Old" set.
; As those don't load graphics, they'll always use the internal fields.
iOBJInfo_Status                    EQU $00 ; Both sets - OBJInfo flags + X/Y OBJLst flip flags (OR'd over ROM flags)
iOBJInfo_OBJLstFlags               EQU $01 ; Current - HW OBJ flags used for the entire OBJLst (XOR'd over ROM flags after above)
iOBJInfo_OBJLstFlagsView           EQU $02 ; Old - See above
iOBJInfo_X                         EQU $03 ; X Position
iOBJInfo_XSub                      EQU $04 ; X Subpixel Position
iOBJInfo_Y                         EQU $05 ; Y Position
iOBJInfo_YSub                      EQU $06 ; Y Subpixel Position
iOBJInfo_SpeedX                    EQU $07 ; X speed - Added to iOBJInfo_X every frame
iOBJInfo_SpeedXSub                 EQU $08 ; X Subpixel speed - Added to iOBJInfo_XSub every frame
iOBJInfo_SpeedY                    EQU $09 ; Y speed
iOBJInfo_SpeedYSub                 EQU $0A ; Y Subpixel speed 
iOBJInfo_RelX                      EQU $0B ; Relative X Position (autogenerated)
iOBJInfo_RelY                      EQU $0C ; Relative Y Position (autogenerated)
iOBJInfo_TileIDBase                EQU $0D ; Starting tile ID (all tile IDs in the OBJ list are relative to this)
iOBJInfo_VRAMPtr_Low               EQU $0E ; VRAM GFX Pointer (low byte) - GFX is written to this address for buffer A, typically is $8000 or $8400
iOBJInfo_VRAMPtr_High              EQU $0F ; VRAM GFX Pointer (high byte)
iOBJInfo_BankNum                   EQU $10 ; Current - Bank number for OBJLstPtrTable (animation table)
iOBJInfo_OBJLstPtrTbl_Low          EQU $11 ; Current - Ptr to OBJLstPtrTable (low byte)
iOBJInfo_OBJLstPtrTbl_High         EQU $12 ; Current - Ptr to OBJLstPtrTable (high byte)
iOBJInfo_OBJLstPtrTblOffset        EQU $13 ; Current - Table offset (multiple of $04)
iOBJInfo_BankNumView               EQU $14 ; Old - Bank number for OBJLstPtrTable (animation table)
iOBJInfo_OBJLstPtrTbl_LowView      EQU $15 ; Old - Ptr to OBJLstPtrTable (low byte)
iOBJInfo_OBJLstPtrTbl_HighView     EQU $16 ; Old - Ptr to OBJLstPtrTable (high byte)
iOBJInfo_OBJLstPtrTblOffsetView    EQU $17 ; Old - Table offset (multiple of $04)
iOBJInfo_ColiBoxId                 EQU $18 ; Hurtbox/Collision box ID (copied from iOBJLstHdrA_ColiBoxId)
iOBJInfo_HitboxId                  EQU $19 ; Hitbox ID (copied from iOBJLstHdrA_HitBoxId)
iOBJInfo_ForceHitboxId             EQU $1A ; If set, overrides the specified Hitbox ID (ignores iOBJInfo_HitboxId and the flags disabling the hitbox). Not for unblockables, as the guard check is still made. Used for temporary throw hitboxes. 
iOBJInfo_FrameLeft                 EQU $1B ; Number of frames left before switching to the next anim frame.
iOBJInfo_FrameTotal                EQU $1C ; Animation speed. New frames will have iOBJInfo_FrameLeft set to this.
iOBJInfo_BufInfoPtr_Low            EQU $1D ; GFX Buffer info struct pointer (low byte)
iOBJInfo_BufInfoPtr_High           EQU $1E ; GFX Buffer info struct pointer (high byte)
iOBJInfo_RangeMoveAmount           EQU $1F ; How many pixels the player is moved to keep him in range
iOBJInfo_Custom                    EQU $20 ; $20 bytes of free space

; Things going into said free space:
iOBJInfo_CharSel_CursorOBJId       EQU iOBJInfo_Custom+$07 ; iOBJInfo_OBJLstPtrTblOffset used for normal portraits
iOBJInfo_CharSel_CursorWideOBJId   EQU iOBJInfo_Custom+$08 ; iOBJInfo_OBJLstPtrTblOffset used for the wide portrait
iOBJInfo_CharSel_FlipOBJInfoOffset EQU iOBJInfo_Custom+$09 ; Seems related to the tile flip

iOBJInfo_CharSelFlip_PortraitId    EQU iOBJInfo_Custom+$07
iOBJInfo_CharSelFlip_BaseTileId    EQU iOBJInfo_Custom+$08
iOBJInfo_CharSelFlip_OBJIdTarget   EQU iOBJInfo_Custom+$09

; Default custom values used by multiple ExOBJ, mostly by projectiles.
; Some of these, in practice, are *only* used by those, like the damage flags.
iOBJInfo_Play_CodeBank             EQU iOBJInfo_Custom+$00 ; Bank number for the CodePtr
iOBJInfo_Play_CodePtr_Low          EQU iOBJInfo_Custom+$01 ; Custom code for ExOBJ (low byte)
iOBJInfo_Play_CodePtr_High         EQU iOBJInfo_Custom+$02 ; Custom code for ExOBJ (high byte)
iOBJInfo_Play_DamageVal            EQU iOBJInfo_Custom+$03 ; Damage given the ExOBJ hits the opponent.
iOBJInfo_Play_DamageHitTypeId      EQU iOBJInfo_Custom+$04 ; Animation playing when the projectile hits the opponent (HITTYPE_*)
iOBJInfo_Play_DamageFlags3         EQU iOBJInfo_Custom+$05 ; Damage flags applied when the opponent gets hit (they get copied to iPlInfo_Flags3)
iOBJInfo_Play_HitMode              EQU iOBJInfo_Custom+$06 ; If set, marks what happens when the projectile hits a target
iOBJInfo_Play_Priority             EQU iOBJInfo_Custom+$07 ; Higher priority projectiles erase others
iOBJInfo_Play_EnaTimer             EQU iOBJInfo_Custom+$08 ; Visibility timer. When it elapses, the ExOBJ disappears.
;--
; For Athena's Shining Crystal Bit (before throw)
iOBJInfo_Proj_ShCrystCharge_OrigX           EQU iOBJInfo_Custom+$08 ; X Origin for the projectile. The small spheres are positioned relative to this.
iOBJInfo_Proj_ShCrystCharge_OrigY           EQU iOBJInfo_Custom+$09 ; Y Origin for the projectile.
iOBJInfo_Proj_ShCrystCharge_XPosId          EQU iOBJInfo_Custom+$0A ; Coords table index for X position
iOBJInfo_Proj_ShCrystCharge_YPosId          EQU iOBJInfo_Custom+$0B ; Coords table index for Y position
iOBJInfo_Proj_ShCrystCharge_XPosMul         EQU iOBJInfo_Custom+$0C ; Exponential multiplier for X position
iOBJInfo_Proj_ShCrystCharge_YPosMul         EQU iOBJInfo_Custom+$0D ; Exponential multiplier for Y position
iOBJInfo_Proj_ShCrystCharge_XPosMulUpdTimer EQU iOBJInfo_Custom+$0E ; Timer for incrementing/decrementing XPosMul
iOBJInfo_Proj_ShCrystCharge_YPosMulUpdTimer EQU iOBJInfo_Custom+$0F ; Timer for incrementing/decrementing YPosMul
iOBJInfo_Proj_ShCrystCharge_OrbitMode       EQU iOBJInfo_Custom+$10 ; Projectile movement mode
iOBJInfo_Proj_ShCrystCharge_OrigMoveLeft    EQU iOBJInfo_Custom+$11 ; Origin UB movements left. When it elapses, we switch to Hold mode.
iOBJInfo_Proj_ShCrystCharge_DespawnTimer    EQU iOBJInfo_Custom+$11 ; In spiral mode
iOBJInfo_Proj_ShCrystCharge_OrigMoveTimer   EQU iOBJInfo_Custom+$12 ; Incrementing timer to time the origin movements.
; For Athena's Shining Crystal Bit (after throw, so a standard proj)
iOBJInfo_Proj_ShCrystThrow_TypeId           EQU iOBJInfo_Custom+$08 ; ID of the LH/SD combination
; For Goenitz's Wanpyou Tokobuse
iOBJInfo_Proj_WanToko_OrigX                 EQU iOBJInfo_Custom+$09 ; X Origin for the projectile. The small spheres are positioned relative to this.
iOBJInfo_Proj_WanToko_OrigY                 EQU iOBJInfo_Custom+$0A ; Y Origin for the projectile.
iOBJInfo_Proj_WanToko_MoveSpeed             EQU iOBJInfo_Custom+$0B ; Base movement speed for a single projectile frame (0-3) 

; Sprite mapping fields.

; OBJLstPtrTable A entry elements
iOBJLstHdrA_Flags                  EQU $00
iOBJLstHdrA_ColiBoxId              EQU $01 ; Hurtbox ID
iOBJLstHdrA_HitBoxId               EQU $02 ; Hitbox ID
iOBJLstHdrA_GFXPtr_Low             EQU $03 ; Ptr to uncompressed GFX (low byte) - will be copied to the GfxInfo
iOBJLstHdrA_GFXPtr_High            EQU $04 ; Ptr to uncompressed GFX (high byte)
iOBJLstHdrA_GFXBank                EQU $05 ; Bank num with GFX
iOBJLstHdrA_DataPtr_Low            EQU $06 ; Ptr to iOBJLst (low byte)
iOBJLstHdrA_DataPtr_High           EQU $07 ; Ptr to iOBJLst (high byte)
iOBJLstHdrA_XOffset                EQU $08
iOBJLstHdrA_YOffset                EQU $09

; OBJLstPtrTable B entry elements
iOBJLstHdrB_Flags                  EQU $00
iOBJLstHdrB_GFXPtr_Low             EQU $01
iOBJLstHdrB_GFXPtr_High            EQU $02
iOBJLstHdrB_GFXBank                EQU $03
iOBJLstHdrB_DataPtr_Low            EQU $04
iOBJLstHdrB_DataPtr_High           EQU $05
iOBJLstHdrB_XOffset                EQU $06
iOBJLstHdrB_YOffset                EQU $07

; Actual OBJLst format
iOBJLst_OBJCount                   EQU $00
; List of OBJ in "compressed" format, right after iOBJLst_OBJCount
iOBJ_Y                             EQU $00
iOBJ_X                             EQU $01
iOBJ_TileIDAndFlags                EQU $02

; Player struct (wPlInfo) format

; Tables with 8 entries of 2 byte each (KEY_* + length)
; These are the locations move input is checked from.
; [TODO] Rough/Incomplete graph, should be visual
;                                        o---------------------------------------o
;                                        |                                       |
; (joy reader) -> hJoyKeys    -> iPlInfo_JoyKeys    -> iPlInfo_Joy*Buffer   2    v
;              -> hJoyNewKeys -> iPlInfo_JoyNewKeys -> iPlInfo_JoyNewKeysLH -> iPlInfo_JoyKeysLH
;                                                              | 1               ^
;                                                              v                 |
;                                                      iPlInfo_JoyBufKeysLH -----o
iPlInfo_JoyBtnBuffer               EQU $00 ; A/B buttons
iPlInfo_JoyDirBuffer               EQU $10 ; Directional keys
iPlInfo_Flags0                     EQU $20 ; Player flags (byte 0)
iPlInfo_Flags1                     EQU $21 ; Player flags (byte 1)
iPlInfo_Flags2                     EQU $22 ; Player flags (byte 2)
iPlInfo_Flags3                     EQU $23 ; Player flags (byte 3 - related to damage)
;-- 
; from master tbl
;
iPlInfo_MoveAnimTblPtr_High        EQU $24 ; Ptr to move anim data ptr table (high byte) [BANK $03]
iPlInfo_MoveAnimTblPtr_Low         EQU $25 ; Ptr to move anim data ptr table (low byte) [BANK $03]
iPlInfo_MoveCodePtrTbl_High        EQU $26 ; Ptr to move code ptr table (high byte) [BANK $03]
iPlInfo_MoveCodePtrTbl_Low         EQU $27 ; Ptr to move code ptr table (low byte) [BANK $03]
iPlInfo_MoveInputCodePtr_High      EQU $28 ; Ptr to special move reader code (high byte)
iPlInfo_MoveInputCodePtr_Low       EQU $29 ; Ptr to special move reader code (low byte)
iPlInfo_MoveInputCodePtr_Bank      EQU $2A ; Bank num for special move reader code
;--
iPlInfo_PlId                       EQU $2B ; Player number (PL1 or PL2), fixed per side
iPlInfo_CharId                     EQU $2C ; Character ID
iPlInfo_TeamLossCount              EQU $2D ; Team Mode - Loss count. If it reaches 3 the stage ends.
iPlInfo_TeamCharId0                EQU $2E ; 1st team member ID (*2)
iPlInfo_TeamCharId1                EQU $2F ; 2nd team member ID (*2)
iPlInfo_TeamCharId2                EQU $30 ; 3rd team member ID (*2)
iPlInfo_RoundWinStreak             EQU $31 ; Number of consecutive wins in a stage (determines win pose)

iPlInfo_MoveId                     EQU $33 ; ID of the current move. (multiplied by 2)
iPlInfo_HitTypeId                  EQU $34 ; ID of the currently playing hit effect. (HITTYPE_*)
iPlInfo_IntroMoveId                EQU $35 ; Intro/outro move ID. When set, iPlInfo_MoveId should be set to the same value.
iPlInfo_SingleWinCount             EQU $36 ; Single mode - Win count. If it reaches 2 the stage ends.
iPlInfo_HitComboRecvSet            EQU $37 ; Sets the combo count of received hits (shown on the other player side)
iPlInfo_HitComboRecv               EQU $38 ; Copy of the above
iPlInfo_OBJLstPtrTblOffsetMoveEnd  EQU $39 ; iOBJInfo_OBJLstPtrTblOffset must match this for the move to end. 
                                           ; Must be less or equal to the animation/OBJLstPtrTable's length.
                                           ; This is mostly to reuse truncated animations.
; Move damage fields - current
iPlInfo_MoveDamageVal              EQU $3A ; Damage given when hitting the opponent directly
iPlInfo_MoveDamageHitTypeId        EQU $3B ; Animation playing when getting hit (HITTYPE_*)
iPlInfo_MoveDamageFlags3           EQU $3C ; Source damage flags applied when getting hit (they get copied to iPlInfo_Flags3)
; Move damage fields - pending (for currently loading frame)
iPlInfo_MoveDamageValNext          EQU $3D
iPlInfo_MoveDamageHitTypeIdNext    EQU $3E
iPlInfo_MoveDamageFlags3Next       EQU $3F

iPlInfo_JoyKeysLH                  EQU $43 ; Held directional keys + *New* A/B light/heavy info + Cumulative A/B light heavy info. Used for the standard punch/kick check when starting moves (both normal and specials).
iPlInfo_JoyNewKeys                 EQU $44 ; Newly pressed joypad keys. Copied directly from hJoyNewKeys,
iPlInfo_JoyKeys                    EQU $45 ; Held joypad Keys. Copied directly from hJoyKeys.
iPlInfo_JoyNewKeysLH               EQU $46 ; Newly pressed directional keys + new A/B light/heavy info
iPlInfo_JoyKeysPreJump             EQU $47 ; Backup of iPlInfo_JoyKeys set before jumping
iPlInfo_JoyNewKeysLHPreJump        EQU $48 ; Backup of iPlInfo_JoyNewKeysLH set before jumping
iPlInfo_JoyBufKeysLH               EQU $49 ; Holds a buffer of the current and previous A/B light/heavy info. This field is essentially a manual version of "iPlInfo_JoyKeys" for LH info, which normally isn't saved in iPlInfo_JoyKeysLH.
iPlInfo_JoyHeavyCountA             EQU $4A ; Counter to detect light/heavy punches, result saved to iPlInfo_JoyNewKeysLH
iPlInfo_JoyHeavyCountB             EQU $4B ; Counter to detect light/heavy kicks, result saved to iPlInfo_JoyNewKeysLH.
iPlInfo_JoyDirBufferOffset         EQU $4C ; Current offset to iPlInfo_JoyDirBuffer
iPlInfo_JoyBtnBufferOffset         EQU $4D ; Current offset to iPlInfo_JoyBtnBuffer
iPlInfo_Health                     EQU $4E ; Player health
iPlInfo_HealthVisual               EQU $4F ; Player health as it appears on the health bar
iPlInfo_Pow                        EQU $50 ; POW meter
iPlInfo_PowVisual                  EQU $51 ; POW meter as it appears on the POW bar
iPlInfo_MaxPowDecSpeed             EQU $52 ; Determines how fast the MAX Power meter decrements. If $00, the bar is immediately wiped out.
iPlInfo_MaxPow                     EQU $53 ; MAX Power meter
iPlInfo_MaxPowVisual               EQU $54 ; MAX Power meter as it appears on screen
iPlInfo_MaxPowExtraLen             EQU $55 ; Determines the extra length of the MAX Power meter. If $00, it's not enabled. If > 0, the bar will have length (value)+4, so its min length is 5.
iPlInfo_MaxPowBGPtr_High           EQU $56 ; Ptr to the leftmost tile of MAX Power meter. *NOT* used when scrolling it on/offscreen. (high byte)
iPlInfo_MaxPowBGPtr_Low            EQU $57 ; Ptr to the leftmost tile of MAX Power meter. *NOT* used when scrolling it on/offscreen. (low byte)
iPlInfo_DizzyNext                  EQU $58 ; If set, the player get knocked down on the next hit and becomes dizzy.
iPlInfo_DizzyTimeLeft              EQU $59 ; Countdown timer with number of frames before the player snaps out of the dizzy state.
;--
; Stun timers
iPlInfo_DizzyProg                  EQU $5A ; Dizzy progression timer. It increments on its own, and getting hit by an attack subtracts a value from here. When it reaches 0, the player drops to the ground and becomes dizzy.
iPlInfo_DizzyProgCap               EQU $5B ; Caps iPlInfo_DizzyProg to this value. As a result, the higher it is, the more hits it takes to dizzy.
iPlInfo_GuardBreakProg             EQU $5C ; Guard break progression timer. It increments on its own, and blocking subtracts a value from here. When it reaches 0, guard temporarily breaks.
iPlInfo_GuardBreakProgCap          EQU $5D ; Caps iPlInfo_GuardBreakProg to this value. As a result, the higher it is, the more hits it takes to guard break.
;--
iPlInfo_NoThrowTimer               EQU $5E ; Wake up timer set when a player drops on the ground. Prevents getting thrown.
iPlInfo_Unused_ThrowKeyTimer       EQU $5F ; [TCRF] Countdown timer related to throws, but non-functional.
iPlInfo_NoSpecialTimer             EQU $60 ; Until it elapses, the player flashes and can only use normals
iPlInfo_PlDistance                 EQU $61 ; Distance between players (the same across players)
iPlInfo_ProjDistance               EQU $62 ; Distance between player and the other player's projectile
iPlInfo_ColiFlags                  EQU $63 ; Collision flags for Set A
iPlInfo_ColiBoxOverlapX            EQU $64 ; How much the collision boxes of the two players overlap, in px. Positive value, always identical between the two players. 
;--
; from master tbl

; Word value must be positive
iPlInfo_SpeedX                     EQU $65 ; Horizontal movement speed when moving forwards or jumping (pixels)
iPlInfo_SpeedX_Sub                 EQU $66 ; Horizontal movement speed when moving forwards or jumping (subpixels)

; Word value must be negative
iPlInfo_BackSpeedX                 EQU $67 ; Horizontal movement speed when moving backwards. (pixels)
iPlInfo_BackSpeedX_Sub             EQU $68 ; Horizontal movement speed when moving backwards (subpixels)

; Word value must be negative
iPlInfo_JumpSpeed                  EQU $69 ; Vertical speed when starting a jump (pixels).
iPlInfo_JumpSpeed_Sub              EQU $6A ; Vertical speed when starting a jump (subpixels).

; Word value must be positive
iPlInfo_Gravity                    EQU $6B ; Gravity applied when jumping (pixels).
iPlInfo_Gravity_Sub                EQU $6C ; Gravity applied when jumping (subpixels).
;--
; All of those marked as "Other" are copied of data from the other player.
; Additionally, those marked as "OBJInfo" come from the respective wOBJInfo struct.
iPlInfo_Flags0Other                EQU $6D
iPlInfo_Flags1Other                EQU $6E
iPlInfo_Flags2Other                EQU $6F
iPlInfo_Flags3Other                EQU $70
iPlInfo_CharIdOther                EQU $71 ; Copy of iPlInfo_CharId
iPlInfo_MoveIdOther                EQU $72
iPlInfo_HitTypeIdOther             EQU $73
iPlInfo_MoveDamageValOther         EQU $74
iPlInfo_MoveDamageHitTypeIdOther   EQU $75
iPlInfo_MoveDamageFlags3Other      EQU $76
iPlInfo_MoveDamageValNextOther     EQU $77
iPlInfo_MoveDamageHitTypeIdNextOther EQU $78
iPlInfo_MoveDamageFlags3NextOther  EQU $79
iPlInfo_NoThrowTimerOther          EQU $7A
iPlInfo_Unused_ThrowKeyTimerOther  EQU $7B
iPlInfo_PhysHitRecv                EQU $7C ; If set, marks that we've been directly hit by the other player (ie: not from a projectile)
iPlInfo_PushSpeedHRecv             EQU $7D ; Copied from the other player's iPlInfo_PushSpeedHReq.
iPlInfo_PushSpeedHReq              EQU $7E ; Horizontal push speed used for multiple purposes. ie: after receiving a hit when cornered. This is given to the other player to make him move out of the way.
iPlInfo_OBJInfoFlagsOther          EQU $7F ; Copy of iOBJInfo_OBJLstFlags
iPlInfo_OBJInfoXOther              EQU $80 ; Copy of iOBJInfo_X
iPlInfo_OBJInfoYOther              EQU $81 ; Copy of iOBJInfo_Y
iPlInfo_PowOther                   EQU $82
; Custom, move-specific
iPlInfo_RunningJump                         EQU $83 ; If set, the last jump was started during a forward run (move MOVE_SHARED_RUN_F)
iPlInfo_Kyo_AraKami_SubInputMask            EQU $83 ; Flags which inputs were performed for the submoves
iPlInfo_Kyo_NueTumi_AutoguardShakeDone      EQU $83 ; Marks if the powerup hitstop was done. Seems pointless.
iPlInfo_Kyo_UraOrochiNagi_ChargeTimer       EQU $83 ; Animation loop limit when charging the move.
iPlInfo_Daimon_HeavenHellDrop_GrabLoopsLeft EQU $83 ; How many 180 grab loops are performed
iPlInfo_Andy_ZanEiKen_OtherHit              EQU $83 ; Marks if the opponent got hit.
iPlInfo_OLeona_StormBringer_LoopTimer       EQU $83 ; Hit loop
iPlInfo_OLeona_SuperMoonSlasher_LoopTimer   EQU $83 ; Hit loop
iPlInfo_Geese_AtemiNage_AutoguardShakeDone  EQU $83 ; Marks if the powerup hitstop was done.
iPlInfo_MrBig_SpinningLancer_LoopTimer      EQU $83 ; Movement loop
iPlInfo_MrBig_CaliforniaRomance_LoopTimer   EQU $83 ; Movement loop
iPlInfo_MrBig_DrumShot_LoopTimer            EQU $83 ; Movement loop
iPlInfo_Mature_DeathRow_Repeat              EQU $83 ; If set, the move can repeat
iPlInfo_Chizuru_ShinsokuNoroti_ChainedMove  EQU $83 ; Bitmask with the chained move to start
iPlInfo_Chizuru_SanRaiFuiJin_83             EQU $83 ; Not used
iPlInfo_Goenitz_Hyouga_InvulnTimer          EQU $83 ; When this elapses, the player isn't invulnerable anymore
iPlInfo_Goenitz_Shinyaotome_LoopTimer       EQU $83 ; Attack loop for all supers
iPlInfo_Goenitz_Jissoukoku_InvulnTimer      EQU $83 ; When this elapses, the player isn't invulnerable anymore
iPlInfo_MrKarate_ShouranKyaku_LoopCount     EQU $83
iPlInfo_MrKarate_Zenretsuken_LoopCount      EQU $83
iPlInfo_Terry_PowerGeyserE_LastXPos         EQU $83 ; Last random X position generated for a projectile
iPlInfo_Athena_PsychoTeleport_InvulnTimer   EQU $83 ; When this elapses, the player isn't invulnerable anymore
iPlInfo_Athena_ShCryst_LoopTimer            EQU $83 ; Phase 1 loop timer
iPlInfo_Athena_ShCryst_ReleaseTimer         EQU $83 ; Phase 2 release timer
iPlInfo_Athena_ShCryst_ProjSize             EQU $84 ; Projectile size, increases with more 360s ($00-$04)
iPlInfo_Iori_Mystery_OBJLstFlagsOrig        EQU $83 ; Untouched copy of iOBJInfo_OBJLstFlags to restore later
iPlInfo_OIori_KinYaOtome_LoopCount          EQU $83
iPlInfo_Ryo_HienShippuKyaku_Unused_83       EQU $83 ; Nonexisting
iPlInfo_Hit_SwoopUp_OkSpeedY                EQU $83
; CPU block
iPlInfo_CPUIdleTimer               EQU $86 ; Delays picking a new idle move. Until it elapses, the existing iPlInfo_CPUIdleMove is valid.
iPlInfo_CPUIdleMove                EQU $87 ; ID of the idle movement mode. (CMA_*)
iPlInfo_CPUWaitTimer               EQU $89 ; Delays CPU input logic until it elapses

; D-Pad Move input (MoveInput_*)
; Format: <iMoveInput_Length>[<iMoveInputItem*> last, <iMoveInputItem*> last-1, ...]		
iMoveInput_Length                  EQU $00 ; Number of iMoveInputItem structures following this
iMoveInputItem_JoyKeys             EQU $01 ; Keys to press (JOY_*)
iMoveInputItem_JoyMaskKeys         EQU $02 ; Only these keys are checked from the input buffer
iMoveInputItem_MinLength           EQU $03 ; The key must be held >= this value
iMoveInputItem_MaxLength           EQU $04 ; The key must be held <= this value

iCPUMoveListItem_MoveInputPtr_Low  EQU $00 ; Ptr to any MoveInput_* structure, low byte
iCPUMoveListItem_MoveInputPtr_High EQU $01 ; Ptr to any MoveInput_* structure, high byte
iCPUMoveListItem_LastLHKeyA        EQU $02 ; iPlInfo_JoyNewKeysLH value, choice #0
iCPUMoveListItem_LastLHKeyB        EQU $03 ; iPlInfo_JoyNewKeysLH value, choice #1

; Sound channel data header (ROM)
; =============== SONG FORMAT ===============
iSndHeader_NumChannels             EQU $00 ; Number of channels (array of iSndChHeader structs comes next)
iSndChHeader_Status                EQU $00 ; Matches iSndInfo_Status and so on
iSndChHeader_RegPtr                EQU $01
iSndChHeader_DataPtr_Low           EQU $02
iSndChHeader_DataPtr_High          EQU $03
iSndChHeader_FreqDataIdBase        EQU $04
iSndChHeader_Unused5               EQU $05

; Sound channel info (RAM)
iSndInfo_Status                    EQU $00 ; SndInfo status bitmask
iSndInfo_RegPtr                    EQU $01 ; Determines sound channel. Always points to rNR*3, and is never changed after being set.
iSndInfo_DataPtr_Low               EQU $02 ; Pointer to song data (low byte)
iSndInfo_DataPtr_High              EQU $03 ; Pointer to song data (high byte)
iSndInfo_FreqDataIdBase            EQU $04 ; Base index/note id to Sound_FreqDataTbl for indexes > 0
iSndInfo_Unused05                  EQU $05 ; Unused. Always $81 unless audio is interrupted.
iSndInfo_DataPtrStackIdx           EQU $06 ; Stack index for data pointers saved and restored by Sound_Cmd_Call and Sound_Cmd_Ret. Initialized to $20 (end of SndInfo) and decremented on pushes.
iSndInfo_LengthTarget              EQU $07 ; Handles delays -- the current sound register settings are kept until it matches iSndInfo_LengthTarget Set by song data.
iSndInfo_LengthTimer               EQU $08 ; Increases every time a SndInfo isn't paused/disabled. Once it reaches iSndInfo_LengthTarget it resets.
iSndInfo_Unknown_Unused_9          EQU $09 ; Used only by the unused sound command Sound_Cmd_Unknown_Unused_SetStat6.
iSndInfo_RegNRx1Data               EQU $0A ; Last value written to rNR*1 | $FF00+(iSndInfo_RegPtr-2). Only written by Command IDs -- this isn't updated by the standard Sound_UpdateCustomRegs.
iSndInfo_Unknown_Unused_NR10Data   EQU $0B ; Last value written to NR10 by the unused sound command Sound_Cmd_Unused_WriteToNR10.
iSndInfo_VolPredict                EQU $0C ; "Volume timer" which predicts the effective volume level (due to sweeps) at any given frame, used when restoring BGM playback. Low nybble is the timer, upper nybble is the predicted volume.
iSndInfo_RegNRx2Data               EQU $0D ; Last value written to rNR*2 | $FF00+(iSndInfo_RegPtr-1)
iSndInfo_RegNRx3Data               EQU $0E  ; Last value written to rNR*3 | $FF00+(iSndInfo_RegPtr)
iSndInfo_RegNRx4Data               EQU $0F  ; Last value written to rNR*4 | $FF00+(iSndInfo_RegPtr+1)
iSndInfo_ChEnaMask                 EQU $10 ; Default rNR51 bitmask, used when a sound channel is enabled
iSndInfo_WaveSetId                 EQU $11 ; Id of last wave set loaded
iSndInfo_LoopTimerTbl              EQU $12 ; Table with timers counting down, used to determine how many times to "jump" the data pointer elsewhere before continuing.
iSndInfo_End                       EQU $20 ; Pointer stack moving up