
; =============== mWaitHBlankEnd ===============
; Waits for the current HBlank to finish, if we're in one.
mWaitForHBlankEnd: MACRO
.waitHBlankEnd_\@:
	ldh  a, [rSTAT]
	and  a, $03
	jp   z, .waitHBlankEnd_\@
ENDM
; =============== mWaitHBlank ===============
; Waits for the HBlank period.
mWaitForHBlank: MACRO
.waitHBlank_\@:
	ldh  a, [rSTAT]
	and  a, $03
	jp   nz, .waitHBlank_\@
ENDM
; =============== mWaitForNewHBlank ===============
; Waits for the start of a new HBlank period.
mWaitForNewHBlank: MACRO
	; If we're in HBlank already, wait for it to finish
	mWaitForHBlankEnd
	; Then wait for the HBlank proper
	mWaitForHBlank
ENDM

; =============== mWaitForVBlankOrHBlank ===============
; Waits for the VBlank or HBlank period.
mWaitForVBlankOrHBlank: MACRO
.waitVBlankOrHBlank_\@:
	ldh  a, [rSTAT]
	bit  1, a
	jp   nz, .waitVBlankOrHBlank_\@
ENDM

; =============== mWaitForVBlankOrHBlankFast ===============
; Waits for the VBlank or HBlank period.
mWaitForVBlankOrHBlankFast: MACRO
.waitVBlankOrHBlank_\@:
	ldh  a, [rSTAT]
	bit  1, a
	jr   nz, .waitVBlankOrHBlank_\@
ENDM

; =============== mBinDef ===============
; Generates an include for a binary *Def structure, where the data 
; is prepended with its length in bytes.
; IN
; - \1: Path to file to INCBIN
mBinDef: MACRO
	db (.end-.bin)	; Size of data
.bin:
	INCBIN \1		; Data itself
.end:
ENDM

; =============== dp ===============
; Shorthand for far pointers in standard order.
dp: MACRO
	db BANK(\1)
	dw \1
ENDM
; =============== dpr ===============
; Shorthand for far pointers in reverse order.
dpr: MACRO
	dw \1
	db BANK(\1)
ENDM

; =============== pkg ===============
; Shorthand for the header of a (set of) SGB Packets
; IN
; - 1: Packet ID
; - 2: Number of packets
pkg: MACRO
	db (\1 * 8) | \2
ENDM

; =============== ads ===============
; Data set byte 2 for a SGB_PACKET_ATTR_BLK command.
; IN
; - 1: Palette ID (inside)
; - 2: Palette ID (border)
; - 3: Palette ID (outside)
ads: MACRO
	db (\1)|(\1 << 2)|(\1 << 4)
ENDM

; =============== Sound driver macros ===============
; For command IDs, their code will be specified in a comment.

; =============== snderr ===============
; Dummy command which should never be called.
; Code: Sound_DecDataPtr
; IN
; - 1: Full command byte
snderr: MACRO
	db \1
ENDM

; =============== sndendch ===============
; Stops channel playback.
; Code: Sound_Cmd_EndCh
sndendch: MACRO
	db SNDCMD_BASE + $03
ENDM

; =============== sndenvch3 ===============
; Sets channel 3's volume. Channel 3 only.
; Code: Sound_Cmd_WriteToNRx2
; IN:
; - 1: Volume level
sndenvch3: MACRO
	ASSERT \1 <= %11, "Volume level too high"
	
	db SNDCMD_BASE + $04
	db (\1 << 5)
ENDM

; =============== sndenv ===============
; Sets volume/sweep info for channels 1-2-4. Channels 1-2-4 only.
; Code: Sound_Cmd_WriteToNRx2
; IN:
; - 1: Initial volume level
; - 2: Envelope direction (as a byte constant)
; - 3: Sweep
sndenv: MACRO
	ASSERT \1 <= %1111, "Volume level too high"
	ASSERT \2 == SNDENV_INC || \2 == SNDENV_DEC, "Invalid envelope direction value"
	ASSERT \3 <= %111, "Sweep level too high"
	
	db SNDCMD_BASE + $04
	db (\1 << 4)|(\2)|(\3)
ENDM

; =============== sndloop ===============
; Jumps to the specified target in the song data.
; Code: Sound_Cmd_JpFromLoop
; IN:
; - 1: Ptr to song data
sndloop: MACRO
	db SNDCMD_BASE + $05
	dw \1
ENDM

; =============== sndnotebase ===============
; Sets the base note id value.
; Code: Sound_Cmd_AddToBaseFreqId
; IN:
; - 1: Base note id
sndnotebase: MACRO
	db SNDCMD_BASE + $06
	db \1
ENDM

; =============== sndloopcnt ===============
; Jumps to the specified target the specified amount of times.
; After it loops the required amount of times, the command is ignored and the song continues.
; Code: Sound_Cmd_JpFromLoopByTimer
; IN:
; - 1: Timer ID (should be unique as to not overwrite other loops)
; - 2: Times to loop (Initial timer value)
; - 3: Ptr to song data
sndloopcnt: MACRO
	db SNDCMD_BASE + $07
	db \1, \2
	dw \3
ENDM

; =============== snd_UNUSED_nr10 ===============
; Sets rNR10 settings.
; Code: Sound_Cmd_Unused_WriteToNR10
; IN:
; - 1: Sweep time
; - 2: Sweep direction
; - 3: Number of sweep shifts
snd_UNUSED_nr10: MACRO
	ASSERT \1 <= %111, "Sweep time is too high"
	ASSERT \2 <= %1, "Sweep direction flag invalid"
	ASSERT \3 <= %111, "Too many sweep shifts"
	
	db SNDCMD_BASE + $08
	db (\1 << 4)|(\2 << 3)|(\3)
ENDM

; =============== sndenach ===============
; Enables the specified sound channels, on top of the already enabled channels.
; Code: Sound_Cmd_SetChEna
; IN:
; - 1: Channels to enable. Only the same type should be enabled.
sndenach: MACRO
	db SNDCMD_BASE + $09
	db \1
ENDM

; =============== sndcall ===============
; Like calling a subroutine, but for the sound data ptr.
; Code: Sound_Cmd_Call
; IN:
; - 1: Ptr to song data
sndcall: MACRO
	db SNDCMD_BASE + $0C
	dw \1
ENDM

; =============== sndret ===============
; Like returning from a subroutine, but for the sound data ptr.
; Code: Sound_Cmd_Ret
; IN:
; - 1: Ptr to song data
sndret: MACRO
	db SNDCMD_BASE + $0D
ENDM

; =============== sndnr11 ===============
; Writes data to NR11. Channel 1 only.
; Code: Sound_Cmd_WriteToNRx1
; IN:
; - 1: Wave pattern duty
; - 2: Sound length
sndnr11: MACRO
	ASSERT \1 <= %11, "Pat duty too high"
	ASSERT \2 <= %111111, "Sound length too high"
	db SNDCMD_BASE + $0E
	db (\1 << 6)|\2
ENDM
; =============== sndnr21 ===============
; Writes data to NR21. Channel 2 only.
; Code: Sound_Cmd_WriteToNRx1
; IN:
; - 1: Wave pattern duty
; - 2: Sound length
sndnr21: MACRO
	sndnr11 \1, \2
ENDM

; =============== sndnr31 ===============
; Writes data to NR31. Channel 3 only.
; Code: Sound_Cmd_WriteToNRx1
; IN:
; - 1: Sound length
sndnr31: MACRO
	db SNDCMD_BASE + $0E
	db \1
ENDM

; =============== sndnr41 ===============
; Writes data to NR41. Channel 4 only.
; Code: Sound_Cmd_WriteToNRx1
; IN:
; - 1: Sound length
sndnr41: MACRO
	ASSERT \1 <= %111111, "Sound length too high"
	db SNDCMD_BASE + $0E
	db \1
ENDM

; =============== sndsetskip ===============
; Disables writes to NR*2 when syncing SndInfo -> Sound Regs.
; Code: Sound_Cmd_SetSkipNRx2
sndsetskip: MACRO
	db SNDCMD_BASE + $0F
ENDM

; =============== sndclrskip ===============
; Enables writes to NR*2 when syncing SndInfo -> Sound Regs.
; Code: Sound_Cmd_ClrSkipNRx2
sndclrskip: MACRO
	db SNDCMD_BASE + $10
ENDM

; =============== snd_UNUSED_setstat6 ===============
; Sets an unknown SndInfo status flag.
; Code: Sound_Cmd_Unknown_Unused_SetStat6
snd_UNUSED_setstat6: MACRO
	db SNDCMD_BASE + $11
ENDM

; =============== snd_UNUSED_clrstat6 ===============
; Clears an unknown SndInfo status flag.
; Code: Sound_Cmd_Unknown_Unused_ClrStat6
snd_UNUSED_clrstat6: MACRO
	db SNDCMD_BASE + $12
ENDM

; =============== sndwave ===============
; Writes a new set of wave data.
; Code: Sound_Cmd_SetWaveData
; IN:
; - 1: Wave set ID
sndwave: MACRO
	db SNDCMD_BASE + $13
	db \1
ENDM

; =============== snd_UNUSED_endchflag7F ===============
; Stops channel playback and updates an otherwise unused bitmask.
; Code: Sound_Cmd_Unused_EndChFlag7F
snd_UNUSED_endchflag7F: MACRO
	db SNDCMD_BASE + $14
ENDM

; =============== sndch3len ===============
; Sets a new length value for channel 3 and applies it immediately to NR31.
; Code: Sound_Cmd_SetCh3StopLength
; IN:
; - 1: Length value
sndch3len: MACRO
	db SNDCMD_BASE + $15
	db \1
ENDM

; =============== snd_UNUSED_endchflagBF ===============
; Stops channel playback and updates an otherwise unused bitmask.
; Code: Sound_Cmd_Unused_EndChFlagBF
snd_UNUSED_endchflagBF: MACRO
	db SNDCMD_BASE + $16
ENDM

; =============== sndlenpre ===============
; Sets a new channel length before the SndInfo -> Register sync.
; Code: Sound_Cmd_SetLength
; IN:
; - 1: Length value
sndlenpre: MACRO
	db SNDCMD_BASE + $1A
	db \1
ENDM

; =============== sndch4 ===============
; Writes frequency data to channel 4 (rNR43). Channel 4 only.
; Code: N/A
; IN:
; - 1: Frequency value
; - 2: Step width
; - 3: Freq. dividing ratio
sndch4: MACRO
	ASSERT \1 <= %1111, "Frequency too high"
	ASSERT \2 <= %1, "Width should be 0 or 1"
	ASSERT \3 <= %111, "Invalid ratio"
	db (\1 << 4)|(\2 << 3)|(\3)
ENDM

; =============== sndnote ===============
; Sets a note id. Channels 1-2-3 only.
; Code: N/A
; IN:
; - 1: Note ID
sndnote: MACRO
	db SNDNOTE_BASE+\1
ENDM

; =============== sndlen ===============
; Sets the target length after the SndInfo -> Register sync.
; Code: N/A
; IN:
; - 1: Length
sndlen: MACRO
	db \1
ENDM