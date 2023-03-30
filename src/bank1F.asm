; =============== Sound_Do ===============
; Entry point of the main sound code.
; This is an improved version of the sound driver used in KOF95.
Sound_Do:
	; Check if there's anything new that we want to play
	call Sound_ChkNewSnd

	; Update the "SFX playing, mute BGM" flag for each channel
	ld   de, wSFXCh1Info
	ld   hl, wBGMCh1Info
	call Sound_MarkSFXChUse
	ld   de, wSFXCh2Info
	ld   hl, wBGMCh2Info
	call Sound_MarkSFXChUse
	ld   de, wSFXCh3Info
	ld   hl, wBGMCh3Info
	call Sound_MarkSFXChUse
	ld   de, wSFXCh4Info
	ld   hl, wBGMCh4Info
	call Sound_MarkSFXChUse

	;
	; Handle all of the sound channels.
	;
	ld   hl, wBGMCh1Info	; HL = Ptr to first SndInfo structure
	ld   a, $08			; Remaining SndInfo (4 channels, 2 sets (BGM + SFX))
	ld   [wSndChProcLeft], a
.loop:
	; Save a copy of the SndInfo ptr to RAM
	ld   a, l
	ldh  [hSndInfoCurPtr_Low], a
	ld   a, h
	ldh  [hSndInfoCurPtr_High], a

	push hl						; Save ptr to SndInfo
		ld   a, [hl]			; Read iSndInfo_Status
		bit  SISB_ENABLED, a	; Processing for the channel enabled?
		call nz, Sound_DoChSndInfo	; If so, call
		ld   hl, wSndChProcLeft ; SndInfoLeft--
		dec  [hl]				;
	pop  hl						; Restore SndInfo ptr

	; Seek to the next channel
	ld   de, SNDINFO_SIZE	; Ptr += SNDINFO_SIZE
	add  hl, de

	jr   nz, .loop			; If there are channels left to process, jump

	; Update the volume level timer
	ld   hl, wBGMCh1Info + iSndInfo_VolPredict
	ld   de, wBGMCh1Info + iSndInfo_RegNRx2Data
	call Sound_UpdateVolPredict
	ld   hl, wBGMCh2Info + iSndInfo_VolPredict
	ld   de, wBGMCh2Info + iSndInfo_RegNRx2Data
	call Sound_UpdateVolPredict
	ld   hl, wBGMCh4Info + iSndInfo_VolPredict
	ld   de, wBGMCh4Info + iSndInfo_RegNRx2Data
	jp   Sound_UpdateVolPredict

; =============== Sound_ChkNewSnd ===============
; Checks if we're trying to start a new BGM or SFX.
Sound_ChkNewSnd:


	; The first counter is updated every time a new music track is started,
	; while the second one is increased when the new music track is requested.
	; If these value don't match, we know that we should play a new music track.
	ld   hl, hSndPlayCnt
	ldi  a, [hl]		; Read request counter
	cp   a, [hl]		; Does it match the playback counter?
	jr   z, .noReq		; If so, there's nothing new to play

	dec  l			; Seek back to hSndPlayCnt


	; Increase the sound playback index/counter, looping it back to $00 if it would index past the end of the table
	; hSndPlayCnt = (hSndPlayCnt + 1) & $07
	ld   a, [hl]
	inc  a						; TblId++
	and  a, (SNDIDREQ_SIZE-1)	; Keep range
	ld   [hl], a				; Write it to hSndPlayCnt

	; To determine the ID of the music track to play, use the counter as index to the table at wSndIdReqTbl.
	; The value written there is treated as the BGM ID.

	; A = wSndIdReqTbl[hSndPlayCnt]
	add  a, LOW(wSndIdReqTbl)		; L = hSndPlayCnt + $F8
	ld   l, a
	ld   h, HIGH(wSndIdReqTbl)		; H = $D5
	ld   a, [hl]					; Read the sound ID



	; In the master sound list, the valid sounds have IDs >= $00 && < $46.
	; The entries written into the sound id request table have the MSB set, so the actual range check
	; is ID >= $80 && ID < $C6. Everything outside the range is rejected and stops all currently playing BGM/SFX.
	;
	; Only after the range check, these values are subtracted by $80 (SND_BASE).

	; Opcode read as "ld   bc, $803E"
	; This useless instruction prevents "ld   a, $80" from being executed.
	db   $01
.noReq:
	; When code executes this instruction, it prevents Sound_StopAll from being called and directly returns
	ld   a, SND_NONE
	;--

	; Range validation
	bit  7, a						; SndId < $80?
	jp   z, Sound_StopAll	; If so, jump
	cp   SND_LAST_VALID+1			; SndId >= $C6?
	jp   nc, Sound_StopAll	; If so, jump
	; Calculate the index to the next tables
	; DE = SndId - $80
	sub  a, SND_BASE				; Remove SND_BASE from the id
	ret  z							; Is it $00? (SND_NONE) If so, return
	ld   e, a
	xor  a
	ld   d, a

	;--
	;
	; 1: BC = Sound_SndHeaderPtrTable[DE*2]
	;

	; HL = Ptr table to song header
	ld   hl, Sound_SndHeaderPtrTable
	; Add index twice (each entry is 2 bytes)
	add  hl, de
	add  hl, de
	; Read out the ptr to BC
	ldi  a, [hl]
	ld   b, [hl]
	ld   c, a

	;--
	;
	; Get the code ptr for the init code for the sound.
	; 2: HL = Sound_SndStartActionPtrTable[DE*2]
	;

	; HL = Ptr table to code
	ld   hl, Sound_SndStartActionPtrTable
	; Add index twice (each entry is 2 bytes)
	add  hl, de
	add  hl, de
	; Read out the ptr to HL
	ldi  a, [hl]
	ld   h, [hl]
	ld   l, a

	; Jump there
	jp   hl

	; Sound command codes assignments. BGM always uses Sound_StartNewBGM, while sound effects pick it
	; depending on the sound channel(s) the SFX needs to be played on.
	; This is important because various subroutines pick a different base address for channel info,
	; and you can only move down from there.
	; (ie: when wSFXCh2Info is picked as base, the SFX can also use wSFXCh3Info and wSFXCh4Info, but not wSFXCh1Info)
	;
	; A few special commands are also here, like the Pause/Unpause one.
	; Unused entries in the all table point to the dummy Sound_StartNothing.
Sound_SndStartActionPtrTable:
	dw Sound_StartNothing;X		; $00
	dw Sound_StartNewBGM
	dw Sound_StartNewBGM
	dw Sound_StartNewBGM
	dw Sound_StartNewBGM
	dw Sound_StartNewBGM
	dw Sound_StartNewBGM
	dw Sound_StartNewBGM
	dw Sound_StartNewBGM		; $08
	dw Sound_StartNewBGM
	dw Sound_StartNewBGM
	dw Sound_StartNewBGM
	dw Sound_PauseAll
	dw Sound_UnpauseAll
	dw Sound_StartNewSFX234
	dw Sound_StartNewSFX234
	dw Sound_StartNewSFX234		; $10
	dw Sound_StartNewSFX234
	dw Sound_StartNewSFX4
	dw Sound_StartNewSFX4
	dw Sound_StartNewSFX4
	dw Sound_StartNewSFX4
	dw Sound_StartNewSFX4
	dw Sound_StartNewSFX4
	dw Sound_StartNewBGM		; $18
	dw Sound_StartNewBGM
	dw Sound_StartNewSFX4
	dw Sound_StartNewSFX4
	dw Sound_StartNewSFX4
	dw Sound_StartNewSFX4
	dw Sound_StartNewBGM
	dw Sound_StartNewBGM
	dw Sound_StartNothing;X		; $20
	dw Sound_StartNothing;X
	dw Sound_StartNothing;X
	dw Sound_StartNothing;X
	dw Sound_StartNothing;X
	dw Sound_StartNothing;X
	dw Sound_StartNewSFX4
	dw Sound_StartNewSFX4
	dw Sound_StartNewSFX4		; $28
	dw Sound_StartNewSFX4
	dw Sound_StartNewSFX4
	dw Sound_StartNewSFX4
	dw Sound_StartNewSFX4
	dw Sound_StartNewSFX4
	dw Sound_StartNewSFX234
	dw Sound_StartNewSFX234
	dw Sound_StartNewSFX234		; $30
	dw Sound_StartNewSFX4
	dw Sound_StartNothing;X
	dw Sound_StartNothing;X

; =============== Sound_StartNewBGM ===============
; Starts playback of a new BGM.
; IN
; - BC: Ptr to song data
Sound_StartNewBGM:
	xor  a
	ld   [wSnd_Unused_ChUsed], a
	push bc
	call Sound_StopAll
	pop  bc
	ld   de, wBGMCh1Info
	jp   Sound_InitSongFromHeader

; =============== Sound_PauseAll ===============
; Handles the sound pause command during gameplay.
Sound_PauseAll:
	; Pause everything except SFXCh1 and SFXCh2
	call Sound_PauseChPlayback
	; Kill SFXCh1 and SFXCh2 with a silent SFX (SndHeader_Pause) that overrides whatever's still playing.
	; This SFX doesn't play notes, all it does is set the sound length to 0, then end itself.
	; It also pretends to be a BGM, so that once it ends, so the game will mute the channel instead of attempting to resume the BGM.
	jr   Sound_StartNewSFX1234

; =============== Sound_UnpauseAll ===============
; Handles the sound unpause command during gameplay.
Sound_UnpauseAll:
	call Sound_UnpauseChPlayback
	; No purpose here.
	jr   Sound_StartNewSFX1234

; =============== Sound_PauseChPlayback ===============
; Pauses sound playback.
Sound_PauseChPlayback:
	; Disable all sound channels
	xor  a
	ldh  [rNR51], a
	; Pause music and sound effect channels (but not SFXCh1 and SFXCh2, for some reason)
	ld   hl, wBGMCh1Info
	set  SISB_PAUSE, [hl]
	ld   hl, wBGMCh2Info
	set  SISB_PAUSE, [hl]
	ld   hl, wBGMCh3Info
	set  SISB_PAUSE, [hl]
	ld   hl, wBGMCh4Info
	set  SISB_PAUSE, [hl]
	ld   hl, wSFXCh3Info
	set  SISB_PAUSE, [hl]
	ld   hl, wSFXCh4Info
	set  SISB_PAUSE, [hl]
	ret

; =============== Sound_UnpauseChPlayback ===============
Sound_UnpauseChPlayback:
	; [BUG] 'A' value is undefined garbage ($15), and this gets overwritten later on anyway.
	ldh  [rNR51], a
	; Resume music and sound effect channels
	ld   hl, wBGMCh1Info
	res  SISB_PAUSE, [hl]
	ld   hl, wBGMCh2Info
	res  SISB_PAUSE, [hl]
	ld   hl, wBGMCh3Info
	res  SISB_PAUSE, [hl]
	ld   hl, wBGMCh4Info
	res  SISB_PAUSE, [hl]
	ld   hl, wSFXCh3Info
	res  SISB_PAUSE, [hl]
	ld   hl, wSFXCh4Info
	res  SISB_PAUSE, [hl]
	ret

; =============== Sound_Unused_StartNewSFX1234WithStat ===============
; [TCRF] Unreferenced code.
Sound_Unused_StartNewSFX1234WithStat:
	ld   a, $80
	ld   [wSnd_Unused_ChUsed], a
	jr   Sound_StartNewSFX1234

; =============== Sound_Unused_StartNewSFX1234IfChNotUsed ===============
; [TCRF] Unreferenced code.
Sound_Unused_StartNewSFX1234IfChNotUsed:
	ld   a, [wSnd_Unused_ChUsed]
	bit  7, a
	jp   nz, Sound_StartNothing

; =============== Sound_StartNewSFX1234 ===============
; Starts playback for a multi-channel SFX (uses ch1-2-3-4)
Sound_StartNewSFX1234:
	xor  a
	ldh  [rNR10], a
	ld   de, wSFXCh1Info
	jr   Sound_InitSongFromHeader

; =============== Sound_Unused_StopSFXCh1 ===============
; [TCRF] Unreferenced code.
Sound_Unused_StopSFXCh1:
	xor  a
	ldh  [rNR10], a
	ld   [wSFXCh1Info], a
	call Sound_StopAll.initNR
	jr   Sound_StartNothing

; =============== Sound_Unused_StartNewSFX234WithStat ===============
; [TCRF] Unreferenced code.
Sound_Unused_StartNewSFX234WithStat:
	ld   a, [wSnd_Unused_ChUsed]
	or   a, $80
	ld   [wSnd_Unused_ChUsed], a
	jr   Sound_StartNewSFX234.initSong

; =============== Sound_StartNewSFX234 ===============
; Starts playback for a multi-channel SFX (uses ch2-3-4)
Sound_StartNewSFX234:
	; [TCRF] Bit never set
	ld   a, [wSnd_Unused_ChUsed]
	bit  7, a							; Is the channel used?
	jp   nz, Sound_StartNothing			; If so, jump (don't start SFX)
.initSong:
	ld   de, wSFXCh2Info
	jr   Sound_InitSongFromHeader

; =============== Sound_Unused_InitSongFromHeaderToCh3 ===============
; [TCRF] Unreferenced code.
Sound_Unused_InitSongFromHeaderToCh3:
	ld   de, wSFXCh3Info
	jr   Sound_InitSongFromHeader

; =============== Sound_Unused_StartNewSFX4WithStat ===============
; [TCRF] Unreferenced code.
Sound_Unused_StartNewSFX4WithStat:
	ld   a, [wSnd_Unused_ChUsed]
	or   a, $40
	ld   [wSnd_Unused_ChUsed], a
	jr   Sound_StartNewSFX4.initSong

; =============== Sound_StartNewSFX4 ===============
; Starts playback for a channel-4 only SFX (SFX4).
Sound_StartNewSFX4:
	; [TCRF] Bit never set
	ld   a, [wSnd_Unused_ChUsed]
	bit  6, a							; Is the channel used?
	jp   nz, Sound_StartNothing			; If so, jump (don't start SFX)
.initSong:
	ld   de, wSFXCh4Info
	jr   Sound_InitSongFromHeader


; =============== Sound_InitSongFromHeader ===============
; Copies song data from its header to multiple SndInfo.
; IN
; - BC: Ptr to sound header data
; - DE: Ptr to the initial SndInfo (destination)
Sound_InitSongFromHeader:
	; HL = BC
	ld   l, c
	ld   h, b

	; A sound can take up multiple channels -- and channel info is stored into a $20 byte struct.
	; The first byte from the sound header marks how many channels ($20 byte blocks) need to be initialized.

	; B = Channels used
	ldi  a, [hl]
	ld   b, a
.chLoop:
	;
	; Copy over next 6 bytes
	; These map directly to the first six bytes of the SndInfo structure.
	;
REPT 6
	ldi  a, [hl]	; Read byte
	ld   [de], a	; Copy it over
	inc  de
ENDR

	;
	; Then initialize other fields
	;

	; Point data "stack index" to the very end of the SndInfo structure
	ld   a, iSndInfo_End
	ld   [de], a			; Write to iSndInfo_DataPtrStackIdx
	inc  de

	; Set the lowest possible length target to handle new sound commands as soon as possible.
	ld   a, $01
	ld   [de], a			; Write to iSndInfo_LengthTarget
	inc  de

	;
	; Clear rest of the SndInfo ($18 bytes)
	;
	xor  a
	ld   c, SNDINFO_SIZE-iSndInfo_LengthTimer	; C = Bytes left
.clrLoop:
	ld   [de], a		; Clear
	inc  de
	dec  c				; Cleared all bytes?
	jr   nz, .clrLoop	; If not, loop

	dec  b				; Finished all loops?
	jr   nz, .chLoop	; If not, jump

	; Fall-through
Sound_StartNothing:
	; [TCRF] Some kind of marker?
	ld   a, $80
	ld   [wSnd_Unk_Unused_D480], a
	ret

; =============== Sound_DoChSndInfo ===============
; IN
; - HL: Ptr to start of the current sound channel info (iSndInfo_Status)
Sound_DoChSndInfo:
	; If the sound channel is paused, return immediately
	bit  SISB_PAUSE, a
	ret  nz

	;------------
	;
	; HANDLE LENGTH.
	; Until the length timer reaches the target, return immediately to avoid updating the sound register settings.
	; When the values match, later on the timer is reset and a new length will be set.
	;

	; Seek to the timer
	ld   bc, iSndInfo_LengthTimer
	add  hl, bc

	; Timer++
	ld   a, [hl]
	inc  a
	ldd  [hl], a	; iSndInfo_LengthTimer++, seek back to iSndInfo_LengthTarget

	; If it doesn't match the target, return
	cp   a, [hl]	; iSndInfo_LengthTarget == iSndInfo_LengthTimer?
	ret  nz			; If not, return

	;------------

	; DE = Channel header ptr
	; (would have been like doing DE = HL at the start of the function).
	; This value is the base for SndInfo indexing and won't be changed again.
	ldh  a, [hSndInfoCurPtr_Low]
	ld   e, a
	ldh  a, [hSndInfoCurPtr_High]
	ld   d, a

	; Copy the data ptr field from the SndInfo to HRAM
	; Seek to the channel data ptr
	ld   hl, iSndInfo_DataPtr_Low
	add  hl, de
	; Save the ptr here
	ldi  a, [hl]
	ldh  [hSndInfoCurDataPtr_Low], a
	ld   a, [hl]
	ldh  [hSndInfoCurDataPtr_High], a

; =============== Sound_DoChSndInfo_Loop ===============
Sound_DoChSndInfo_Loop:

	;
	; HL = Song data ptr
	;
	ldh  a, [hSndInfoCurDataPtr_Low]
	ld   l, a
	ldh  a, [hSndInfoCurDataPtr_High]
	ld   h, a

	;
	; Read out a "command byte" from the data.
	; This can be either register data, a sound length, an index to frequency data or a command ID.
	;
	; If this is a command ID, most of the time, after the command is processed, a new "command byte" will
	; be immediately processed.
	;
	; If it's not a command ID or a sound length, the next data byte can optionally be a new sound length value
	; (which, again, will get applied immediately on the same frame).
	;
	ld   a, [hl]						; A = Data value

	;
	; Point to the next data byte.
	; Later on we may be checking the new data byte.
	; hSndInfoCurDataPtr++
	;
	ld   hl, hSndInfoCurDataPtr_Low
	inc  [hl]							; Increase low byte
	jr   nz, .chkIsCmd					; Overflowed to 0? If not, skip
	inc  l								; Seek to high byte
	inc  [hl]							; Increase high byte
.chkIsCmd:

	;
	; If the value is higher than $E0, treat the "command byte" as a command ID.
	;
	cp   SNDCMD_BASE					; A >= $E0?
	jp   nc, Sound_DoCommandId			; If so, jump

.notCmd:
	;--
	;
	; Check which channel iSndInfo_RegPtr is pointing to.
	;
	; Sound channel 4 is handled in a different way compared to the others since it does not have frequency
	; options at NR43 and NR44, meaning it should never use Sound_FreqDataTbl.
	;
	; Checking if the 5th bit is set is enough (range >= $FF20 && < $FF40).
	;

	; Seek to the sound register ptr
	ld   hl, iSndInfo_RegPtr
	add  hl, de
	bit  5, [hl]			; ptr >= $FF20?
	jr   z, .isCh123		; If not, jump

.isCh4:
	; If we're here, we're pointing to channel 4.
;--
	; Write A to the data for iSndInfo_RegPtr (NR43)
	ld   hl, iSndInfo_RegNRx3Data
	add  hl, de
	ldi  [hl], a
	; Write $00 to the data for iSndInfo_RegPtr+1 (NR44)
	xor  a
	ld   [hl], a

	; Perform the register update
	jr   .updateRegs
;--
.isCh123:

	;
	; If the value is < $80, directly treat it as the new target length
	; and don't update the registers.
	;
	cp   SNDNOTE_BASE	; A < $80? (MSB clear?)
	jp   c, .setLength	; If so, skip ahead a lot

	;------

	;
	; Otherwise, clear the MSB and treat it as a secondary index to a table of NR*3/NR*4 register data.
	; If the index is != 0, add the contents of iSndInfo_FreqDataIdBase to the index.
	;

	sub  a, SNDNOTE_BASE	; Clear MSB
	jr   z, .readRegData	; If the index is $00, don't add anything else
	ld   hl, iSndInfo_FreqDataIdBase
	add  hl, de				; Seek to iSndInfo_FreqDataIdBase
	add  a, [hl]			; A += *iSndInfo_FreqDataIdBase

.readRegData:

	;
	; Index the table of register data.
	; HL = Sound_FreqDataTbl[A * 2]
	;

	; offset table with 2 byte entries
	ld   hl, Sound_FreqDataTbl	; HL = Tbl
	ld   c, a				; BC = A
	ld   b, $00
	add  hl, bc			; HL += BC * 2
	add  hl, bc

	; Read the entries from the table in ROM
	ld   c, [hl]		; Read out iSndInfo_RegNRx3Data
	inc  hl
	ld   b, [hl]		; Read out iSndInfo_RegNRx4Data

	; and write them over to the Frequency SndInfo in RAM
	ld   hl, iSndInfo_RegNRx3Data
	add  hl, de
	ld   [hl], c		; Save iSndInfo_RegNRx3Data
	inc  hl
	ld   [hl], b		; Save iSndInfo_RegNRx4Data
	;------

.updateRegs:

	;--
	;
	; This part does the direct updates to the sound register sets, now that everything
	; has been set (through command IDs and/or note ids) in the SndInfo fields.
	;
	; Since the registers "are in HRAM" all of the pointers pass through C and the data is written through "ld [c], a" instructions.
	; Depending on the status flags, more or less data will be written in sequence.
	;

	ld   a, [de]			; Read iSndInfo_Status

	;
	; If a SFX is marked as currently playing for the channel, skip updating the sound registers.
	; This can only jump if the current handled SndInfo set is for a BGM.
	;
	bit  SISB_USEDBYSFX, a		; Is the bit set?
	jr   nz, .chkNewLength		; If so, skip ahead
;##
	;
	; Set the 'z' flag for a later check.
	; If set, we won't be updating rNR*2 (C-1).
	;

	bit  SISB_SKIPNRx2, a			; ### Is the bit set?...

	;
	; Read out the current 1-byte register pointer from iSndInfo_RegPtr to C.
	;

	ld   hl, iSndInfo_RegPtr		; Seek to iSndInfo_RegPtr
	add  hl, de
	ld   a, [hl]					; Read out the ptr
	ld   c, a						; Store it to C for $FF00+C access

	; Check if we're skipping NR*2
	jr   nz, .updateNRx3			; ### ...if so, skip

.updateNRx2:

	;
	; Update NR*2 with the contents of iSndInfo_RegNRx2Data
	;

	dec  c				; C--

	ld   hl, iSndInfo_RegNRx2Data	; Seek to iSndInfo_RegNRx2Data
	add  hl, de

	ld   a, [hl]		; Read out iSndInfo_RegNRx2Data
	ld   [c], a			; Write to sound register

	inc  c				; C++

.updateNRx3:

	;
	; Update NR*3 with the contents of iSndInfo_RegNRx3Data
	;

	ld   hl, iSndInfo_RegNRx3Data	; Seek to iSndInfo_RegNRx3Data
	add  hl, de
	ldi  a, [hl]	; Read iSndInfo_RegNRx3Data, seek to iSndInfo_RegNRx4Data
	ld   [c], a		; Write to sound register
	inc  c			; Next register

.updateNRx4:
	;
	; Update NR*4 with the contents of iSndInfo_RegNRx4Data
	;
	ld   a, [hl]	; Read out iSndInfo_RegNRx4Data
	ld   [c], a		; Write to sound register
;##

.chkNewLength:

	;
	; HL = Song data ptr
	;
	ldh  a, [hSndInfoCurDataPtr_Low]
	ld   l, a
	ldh  a, [hSndInfoCurDataPtr_High]
	ld   h, a


	;
	; NOTE: At the start of the loop, we incremented the data byte.
	;
	; After passing through the custom register update, an additional byte
	; may be used to specify a new length target.
	;

	;
	; If the (new) data byte is < $80, treat it as a new length target.
	; Otherwise, ignore it completely.
	;

	ld   a, [hl]			; Read data byte
	cp   $80				; A >= $80?
	jr   nc, .saveDataPtr	; If so, skip

	;
	; hSndInfoCurDataPtr++
	;
	ld   hl, hSndInfoCurDataPtr_Low
	inc  [hl]				; LowByte++
	jr   nz, .setLength		; If no overflow, skip
	inc  l
	inc  [hl]				; HighByte++

	;------
.setLength:

	; Write the updated length value to iSndInfo_LengthTarget
	ld   hl, iSndInfo_LengthTarget
	add  hl, de
	ld   [hl], a
	;------

.saveDataPtr:

	;
	; Save back the updated data pointer from HRAM back to the SndInfo
	;
	ld   hl, iSndInfo_DataPtr_Low
	add  hl, de							; HL = Data ptr in SndInfo
	ldh  a, [hSndInfoCurDataPtr_Low]	; Save low byte to SndInfo
	ldi  [hl], a
	ldh  a, [hSndInfoCurDataPtr_High]	; Save high byte to SndInfo
	ld   [hl], a

	;
	; Reset the length timer
	;
	ld   hl, iSndInfo_LengthTimer
	add  hl, de
	xor  a
	ld   [hl], a

	;
	; Reset the volume prediction timer
	;
	ld   hl, iSndInfo_VolPredict
	add  hl, de			; Seek to iSndInfo_VolPredict
	ld   a, [hl]		; Read the byte
	and  a, $F0			; Remove low nybble
	ld   [hl], a		; Write it back

	;---------------------------

	; [POI] It's not possible to get here with the flag SISB_USEDBYSFX set.
	;       If somehow we got here, return immediately
	ld   a, [de]					; Read iSndInfo_Status
	bit  SISB_USEDBYSFX, a			; Is a sound effect playing on the channel?
	jp   nz, Sound_DoChSndInfo_End	; If so, return (jumps to ret)

	;---------------------------

	;
	; If both frequency bytes are zero, mute the sound channel.
	;
.chkMuteMode:
	ld   hl, iSndInfo_RegNRx3Data
	add  hl, de					;
	ldi  a, [hl]				; iSndInfo_RegNRx3Data != 0
	or   a, [hl]				; || iSndInfo_RegNRx4Data != 0?
	jr   nz, .chkReinit			; If so, skip ahead

.chkMuteCh:

	; Depending on the currently modified channel, decide which channel to mute.
	;
	; This is done by checking at the register ptr, which doubles as channel marker.
	; It will only ever point to the 4th register (rNR*3) of any given sound channel, thankfully.

	ld   hl, iSndInfo_RegPtr
	add  hl, de

	; If we were changing the frequency of any of these channels, jump
	ld   a, [hl]
	cp   SND_CH1_PTR
	jr   z, .muteCh1
	cp   SND_CH2_PTR
	jr   z, .muteCh2
	cp   SND_CH3_PTR
	jr   z, .muteCh3
.muteCh4:
	ldh  a, [rNR51]
	and  a, %01110111
	jr   .muteEnd
.muteCh3:
	xor  a				; ch3 has also its own mute register
	ldh  [rNR30], a
	ldh  a, [rNR51]
	and  a, %10111011
	jr   .muteEnd
.muteCh2:
	ldh  a, [rNR51]
	and  a, %11011101
	jr   .muteEnd
.muteCh1:
	ldh  a, [rNR51]
	and  a, %11101110
.muteEnd:
	ldh  [rNR51], a
	jp   Sound_DoChSndInfo_End
	;---------------------------

.chkReinit:
	; If we skipped the NR*2 update (volume + ...), return immediately
	ld   a, [de]
	bit  SISB_SKIPNRx2, a
	jp   nz, Sound_DoChSndInfo_End

	;
	; Determine which sound channel has to be re-initialized (rNR51 status + extra registers).
	;
	; The default status when enabling a sound channel is stored at iSndInfo_ChEnaMask,
	; so seek to that for later.
	;
	ld   hl, iSndInfo_ChEnaMask
	add  hl, de

	; Seek BC to iSndInfo_RegPtr
	ld   bc, iSndInfo_RegPtr
	ldh  a, [hSndInfoCurPtr_Low]	; LowByte += 1
	add  c
	ld   c, a
	ldh  a, [hSndInfoCurPtr_High]	; HighByte += (Carry)
	adc  b
	ld   b, a

	; Read iSndInfo_RegPtr to A for the upcoming check
	ld   a, [bc]
	; C = A+1 for later
	; Increased by 1 since the high byte of the frequency is what contains extra flags
	ld   c, a
	inc  c

	; Depending on the source address enable the correct sound registers
	cp   SND_CH1_PTR	; A == SND_CH1_PTR? Handling channel 1?
	jr   z, .setCh1Ena	; If so, jump
	cp   SND_CH2_PTR	; Handling channel 2?
	jr   z, .setCh2Ena	; If so, jump
	cp   SND_CH4_PTR	; Handling channel 4?
	jr   z, .setCh4Ena	; If so, jump
.setCh3Ena:
	; Clear and re-enable channel 3
	xor  a ; SNDCH3_OFF
	ldh  [rNR30], a
	ld   a, SNDCH3_ON
	ldh  [rNR30], a

	; Get the bits to OR over rNR51 from the initial sound output status
	; A = iSndInfo_ChEnaMask & $44
	ld   a, [hl]		; Read iSndInfo_ChEnaMask
	and  a, %01000100	; Filter away bits for the other channel numbers
	jr   .setChEna
.setCh4Ena:
	ld   a, [hl]
	and  a, %10001000
	jr   .setChEna
.setCh2Ena:
	ld   a, [hl]
	and  a, %00100010
	jr   .setChEna
.setCh1Ena:
	ld   a, [hl]
	and  a, %00010001

.setChEna:
	; OR the bits from before with rNR51 to re-enable (if needed) the sound channel playback
	ld   b, a
	ldh  a, [rNR51]
	or   b
	ldh  [rNR51], a

	;-----------

.chkCh3EndType:
	;
	; Determine how we want to handle the end of channel playback when the length in ch3 expires.
	; If the checks all pass, wSnd_Ch3StopLength is used as channel length (after which, the channel mutes itself).
	;

	; Not applicable if we aren't editing ch3
	ld   hl, iSndInfo_RegPtr
	add  hl, de					; Seek to register ptr
	ld   a, [hl]				; Read it
	cp   SND_CH3_PTR			; Does it point to ch3?
	jr   nz, .noStop			; If not, jump

	; If we're processing a sound effect, jump
	ld   a, [de]				; Read iOBJInfo_Status
	bit  SISB_SFX, a			; Is the bit set?
	jr   nz, .noStop			; If so, jump

	; If the target length is marked as "none" ($FF), jump
	ld   a, [wSnd_Ch3StopLength]
	cp   SNDLEN_INFINITE
	jr   z, .noStop

.ch3StopOnEnd:
	; Set the new ch3 length
	ldh  [rNR31], a

	; Restart the channel playback
	ld   hl, iSndInfo_RegNRx4Data
	add  hl, de
	ld   a, [hl]
	set  SNDCHFB_RESTART, a			; Restart channel
	or   a, SNDCHF_LENSTOP			; Stop channel playback when length expires
	ld   [c], a

	jr   Sound_DoChSndInfo_End
.noStop:
	; Restart the sound channel playback
	ld   hl, iSndInfo_RegNRx4Data
	add  hl, de
	ld   a, [hl]
	set  SNDCHFB_RESTART, a			; Restart channel
	ld   [c], a
Sound_DoChSndInfo_End:
	ret

; =============== Sound_DoCommandId ===============
; Handles the specified command ID, which mostly involves different ways of writing out data to the SndInfo.
; IN
; - A: Command ID (+ $E0)
; - DE: SndInfo base ptr
Sound_DoCommandId:

	; After the function in the jump table executes, increment the data ptr
	; *AND* return to the normal custom data update loop.
	; Make the next 'ret' instruction jump to Sound_IncDataPtr
	ld   hl, Sound_IncDataPtr
	push hl

	;
	; Index the command fetch ptr table.
	;

	; Get rid of the upper three bits of the command id (essentially subtracting $E0).
	; The resulting value is perfectly in range of the command table at Sound_CmdPtrTbl.
	and  a, $1F				; A -= SNDCMD_BASE

	ld   hl, Sound_CmdPtrTbl; HL = Ptr table
	ld   c, a				; BC = A * 2
	ld   b, $00
	add  hl, bc
	add  hl, bc
	ldi  a, [hl]			; Read out the ptr to HL
	ld   h, [hl]
	ld   l, a
	jp   hl					; Jump there

; =============== Sound_IncDataPtr ===============
; Increases the word value at hSndInfoCurDataPtr, then returns to the loop.
Sound_IncDataPtr:
	ld   hl, hSndInfoCurDataPtr_Low
	inc  [hl]						; hSndInfoCurDataPtr_Low++
	jp   nz, Sound_DoChSndInfo_Loop	; If low byte == 0, jump
	inc  hl							; Seek to hSndInfoCurDataPtr_High
	inc  [hl]						; Increase high byte
	jp   Sound_DoChSndInfo_Loop

Sound_CmdPtrTbl:
	dw Sound_DecDataPtr;X					; $00
	dw Sound_DecDataPtr;X
	dw Sound_DecDataPtr;X
	dw Sound_Cmd_EndCh
	dw Sound_Cmd_WriteToNRx2
	dw Sound_Cmd_JpFromLoop
	dw Sound_Cmd_AddToBaseFreqId
	dw Sound_Cmd_JpFromLoopByTimer
	dw Sound_Cmd_Unused_WriteToNR10;X		; $08
	dw Sound_Cmd_SetChEna
	dw Sound_DecDataPtr;X
	dw Sound_DecDataPtr;X
	dw Sound_Cmd_Call
	dw Sound_Cmd_Ret
	dw Sound_Cmd_WriteToNRx1
	dw Sound_Cmd_SetSkipNRx2
	dw Sound_Cmd_ClrSkipNRx2					; $10
	dw Sound_Cmd_Unknown_Unused_SetStat6;X
	dw Sound_Cmd_Unknown_Unused_ClrStat6;X
	dw Sound_Cmd_SetWaveData
	dw Sound_Cmd_Unused_EndChFlag7F;X
	dw Sound_Cmd_SetCh3StopLength
	dw Sound_Cmd_Unused_EndChFlagBF;X
	dw Sound_DecDataPtr;X
	dw Sound_DecDataPtr;X					; $18
	dw Sound_DecDataPtr;X
	dw Sound_Cmd_SetLength
	dw Sound_DecDataPtr;X
	dw Sound_DecDataPtr;X
	dw Sound_DecDataPtr;X
	dw Sound_DecDataPtr;X
	dw Sound_DecDataPtr;X					; $1F
.end:

; =============== Sound_DecDataPtr ===============
; Decrements the data ptr by 1.
; If called once, it balances out the Sound_IncDataPtr that's always called after Sound_DoCommandId is executed.
Sound_DecDataPtr:
	; hSndInfoCurDataPtr--
	ld   hl, hSndInfoCurDataPtr_Low
	ld   a, [hl]			; Subtract low byte
	sub  a, $01
	ldi  [hl], a			; Save val
	ret  nc					; Underflowed? If not, return
	dec  [hl]				; Subtract high byte (we never get here)
	ret

; =============== Sound_Cmd_SetCh3StopLength ===============
; Sets a new length value for channel 3 (wSnd_Ch3StopLength), and applies it immediately.
; Command data format:
; - 0: New length value
Sound_Cmd_SetCh3StopLength:
	; Read a value off the data ptr.
	; wSnd_Ch3StopLength = ^(*hSndInfoCurDataPtr)
	ldh  a, [hSndInfoCurDataPtr_Low]	; Read out to HL
	ld   l, a
	ldh  a, [hSndInfoCurDataPtr_High]
	ld   h, a
	ld   a, [hl]						; Read value off current data ptr
	cpl									; Invert the bits
	ld   [wSnd_Ch3StopLength], a		; Write it

	; If the length isn't "none" ($FF), write the value to the register immediately.
	; This also means other attempts to write wSnd_Ch3StopLength need to be guarded by a $FF check.
	cp   SNDLEN_INFINITE
	ret  z
	ldh  [rNR31], a
	ret

; =============== Sound_Cmd_AddToBaseFreqId ===============
; Increases the base frequency index by the read amount.
; Command data format:
; - 0: Frequency id offset
Sound_Cmd_AddToBaseFreqId:
	; Read a value off the data ptr.
	ldh  a, [hSndInfoCurDataPtr_Low]
	ld   l, a
	ldh  a, [hSndInfoCurDataPtr_High]
	ld   h, a
	ld   a, [hl]

	; Add the value to iSndInfo_FreqDataIdBase
	ld   hl, iSndInfo_FreqDataIdBase
	add  hl, de				; Seek to the value
	add  a, [hl]			; A += iSndInfo_FreqDataIdBase
	ld   [hl], a			; Save it back
	ret

; =============== Sound_Cmd_Unknown_Unused_SetStat6 ===============
; [TCRF] Unused subroutine.
;        Sets otherwise unused SndInfo field.
Sound_Cmd_Unknown_Unused_SetStat6:
	; Set status flag 6
	ld   a, [de]
	set  SISB_UNUSED_6, a
	ld   [de], a

	; Write $00 to byte9
	ld   hl, iSndInfo_Unknown_Unused_9
	add  hl, de
	ld   [hl], $00

	; Don't increase data ptr
	jp   Sound_DecDataPtr

; =============== Sound_Cmd_Unknown_Unused_ClrStat6 ===============
; [TCRF] Unused subroutine.
;        Clears otherwise unused SndInfo field.
Sound_Cmd_Unknown_Unused_ClrStat6:
	; Clear status flag 6
	ld   a, [de]
	res  SISB_UNUSED_6, a
	ld   [de], a

	; Don't increase data ptr
	jp   Sound_DecDataPtr

; =============== Sound_Cmd_ClrSkipNRx2 ===============
; Clears disable flag for NR*2 writes
Sound_Cmd_ClrSkipNRx2:
	ld   a, [de]
	res  SISB_SKIPNRx2, a
	ld   [de], a

	jp   Sound_DecDataPtr

; =============== Sound_Cmd_SetSkipNRx2 ===============
; Sets disable flag for NR*2 writes
Sound_Cmd_SetSkipNRx2:
	ld   a, [de]
	set  SISB_SKIPNRx2, a
	ld   [de], a
	jp   Sound_DecDataPtr

; =============== Sound_Cmd_SetLength ===============
; Sets a new channel length target, which also resets the timer.
; This doesn't return to the sync loop, unlike the other way to set the length.
; Command data format:
; - 0: Length target
Sound_Cmd_SetLength:

	; Do not return to Sound_IncDataPtr
	pop  hl

	;
	; The current data byte is a length target.
	; Write it over.
	;
	ldh  a, [hSndInfoCurDataPtr_Low]	; HL = Data ptr
	ld   l, a
	ldh  a, [hSndInfoCurDataPtr_High]
	ld   h, a

	ld   a, [hl]						; Read length target
	ld   hl, iSndInfo_LengthTarget
	add  hl, de							; Seek to iSndInfo_LengthTarget
	ld   [hl], a						; Write the value there

	;
	; Increment the data ptr
	;
	ld   hl, hSndInfoCurDataPtr_Low
	inc  [hl]							; LowByte++
	jr   nz, .noHi						; Overflowed? If not, jump
	inc  l								; Seek to hSndInfoCurDataPtr_High
	inc  [hl]							; HighByte++
.noHi:

	;
	; Save back the updated value to the SndInfo
	;
	ld   hl, iSndInfo_DataPtr_Low
	add  hl, de							; Seek to iSndInfo_DataPtr_Low
	ldh  a, [hSndInfoCurDataPtr_Low]	; Write hSndInfoCurDataPtr there
	ldi  [hl], a
	ldh  a, [hSndInfoCurDataPtr_High]
	ld   [hl], a

	;
	; Reset the length timer.
	;
	ld   hl, iSndInfo_LengthTimer
	add  hl, de
	ld   [hl], $00

	; ret
	jp   Sound_DoChSndInfo_End

; =============== Sound_Cmd_SetChEna ===============
; Sets a new "enabled channels" bitmask. The read value should only affect a single channel.
;
; Command data format:
; - 0: Sound channels to enable
Sound_Cmd_SetChEna:

	; C = Enabled channels
	ldh  a, [rNR51]
	ld   c, a
	; HL = Data ptr
	ldh  a, [hSndInfoCurDataPtr_Low]
	ld   l, a
	ldh  a, [hSndInfoCurDataPtr_High]
	ld   h, a

	;--
	; Merge the enabled channels with the existing settings
	;
	; If the enabled channels are the same on both the left and right side,
	; which appears to ALWAYS be the case, the operation is essentially rNR51 |= (data byte).
	;
	; When they aren't, the operation makes no sense.
	ld   a, [hl]	; B = Enabled channels
	ld   b, a
	swap a			; Switch left/right sides
	cpl				; Mark disabled channels with 1
	and  a, c		; A = (A & C) | B
	or   b
	;--

	; Set the updated NR51 value
	ld   hl, iSndInfo_ChEnaMask
	add  hl, de
	ld   [hl], a
	ldh  [rNR51], a

	; If we did this in the context of a BGM, copy the NR51 value to another address
	ld   hl, iSndInfo_Status
	add  hl, de
	bit  SISB_SFX, [hl]		; Is the bit set?
	ret  nz					; If so, return
	ld   [wSndEnaChBGM], a
	ret

; =============== Sound_Cmd_WriteToNRx2 ===============
; Writes the current sound channel data to NR*2, and updates the additional SndInfo fields.
; Should only be used by BGM.
;
; Command data format:
; - 0: Sound register data
Sound_Cmd_WriteToNRx2:

	;--
	; SOUND REG PTR
	;
	; First read the location we have to write to
	;

	; Seek to iSndInfo_RegPtr
	ld   hl, iSndInfo_RegPtr
	add  hl, de

	; Read the ptr to NR*2
	ld   a, [hl]		; A = NR*3
	dec  a
	ld   c, a

	;--
	; SOUND REG VALUE
	;
	; Then read the value we will be writing.
	; This will be written to multiple locations.
	;

	; Dereference value at hSndInfoCurDataPtr and...
	ldh  a, [hSndInfoCurDataPtr_Low]
	ld   l, a
	ldh  a, [hSndInfoCurDataPtr_High]
	ld   h, a
	ld   a, [hl]

	; -> write it to iSndInfo_RegNRx2Data
	;    (since we decremented C before, that's the correct place)
	ld   hl, iSndInfo_RegNRx2Data
	add  hl, de
	ld   [hl], a

	; -> write it to the aforemented sound register if possible
	call Sound_WriteToReg

	; -> write it to iSndInfo_VolPredict, with the low nybble cleared
	;    (since we have set a new volume value, the prediction should restart)
	and  a, $F0									; Erase timer nybble
	ld   hl, iSndInfo_VolPredict
	add  hl, de
	ld   [hl], a
	ret

; =============== Sound_Cmd_WriteToNRx1 ===============
; Writes the current sound channel data to NR*1, and updates the additional SndInfo fields.
; Should only be used by BGM.
;
; Command data format:
; - 0: Sound register data
Sound_Cmd_WriteToNRx1:

	; Seek to iSndInfo_RegPtr
	ld   hl, iSndInfo_RegPtr
	add  hl, de

	; Read the sound register ptr - 2 to C
	ld   a, [hl]
	sub  a, $02
	ld   c, a

	; Dereference value at hSndInfoCurDataPtr and...
	ldh  a, [hSndInfoCurDataPtr_Low]
	ld   l, a
	ldh  a, [hSndInfoCurDataPtr_High]
	ld   h, a
	ld   a, [hl]

	; -> write it to iSndInfo_RegNRx1Data
	ld   hl, iSndInfo_RegNRx1Data
	add  hl, de
	ld   [hl], a

	; -> write it to the aforemented sound register if possible
	jp   Sound_WriteToReg

; =============== Sound_Cmd_Unused_WriteToNR10 ===============
; [TCRF] Unused command.
; Writes the current sound channel data to rNR10 and updates the bookkeeping value.
;
; Command data format:
; - 0: Sound channel data for NR10
Sound_Cmd_Unused_WriteToNR10:

	; Read sound channel data value to A
	ldh  a, [hSndInfoCurDataPtr_Low]
	ld   l, a
	ldh  a, [hSndInfoCurDataPtr_High]
	ld   h, a
	ld   a, [hl]

	; Update the bookkeeping value
	ld   hl, iSndInfo_Unknown_Unused_NR10Data
	add  hl, de
	ld   [hl], a

	; Write to the sound register if possible
	ld   c, LOW(rNR10)
	jp   Sound_WriteToReg

; =============== Sound_Cmd_JpFromLoopByTimer ===============
; Loops the sound channel a certain amount of times.
; Depending on the loop timer table index in data byte 0, bytes 1-2 may be set as the new hSndInfoCurDataPtr.
;
; Command data format:
; - 0: Loop timer ID
; - 1: Initial timer value (used when the existing timer is 0)
; - 2: Dest. Sound data ptr (low byte)
; - 3: Dest. Sound data ptr (high byte)
;
; This command is a superset of what's used by Sound_Cmd_JpFromLoop, so the game can seek to byte2
; and then jump directly to Sound_Cmd_JpFromLoop.
Sound_Cmd_JpFromLoopByTimer:

	; The first byte is the index to the table at iSndInfo_LoopTimerTbl
	; After indexing the value, that gets decremented. If it's already 0 the next data byte is treated as new table value.

	; byte0 - Read the timer ID to C
	ldh  a, [hSndInfoCurDataPtr_Low]
	ld   l, a
	ldh  a, [hSndInfoCurDataPtr_High]
	ld   h, a
	ld   c, [hl]

	; Increment hSndInfoCurDataPtr for later
	inc  hl
	ld   a, l
	ldh  [hSndInfoCurDataPtr_Low], a
	ld   a, h
	ldh  [hSndInfoCurDataPtr_High], a

	;--
	; Seek to iSndInfo_LoopTimerTbl[C]

	; BC = iSndInfo_LoopTimerTbl + C
	ld   a, c
	add  a, iSndInfo_LoopTimerTbl
	ld   b, $00
	ld   c, a

	; HL = SndInfo + BC
	ld   hl, $0000
	add  hl, bc
	add  hl, de
	;--

	; Determine if an existing looping point was already set.
	ld   a, [hl]			; Read loop timer
	or   a					; Is it 0?
	jr   nz, .contLoop		; If not, jump
.firstLoop:
	; If the loop timer is 0, this is the first time we reached this looping point.
	; Set the initial loop timer and loop the song (set the data ptr to what's specified).

	; BC = Ptr to sound channel data (second value)
	ldh  a, [hSndInfoCurDataPtr_Low]
	ld   c, a
	ldh  a, [hSndInfoCurDataPtr_High]
	ld   b, a

	; Write the second data value to the table entry
	ld   a, [bc]
	ld   [hl], a

	; hSndInfoCurDataPtr++
	inc  bc
	ld   a, c
	ldh  [hSndInfoCurDataPtr_Low], a
	ld   a, b
	ldh  [hSndInfoCurDataPtr_High], a

	dec  [hl]							; Decrement loop timer
	jp   nz, Sound_Cmd_JpFromLoop	; Is it 0 now? If not, jump
	;--
	; [TCRF] Seemingly unreachable failsafe code, in case the loop timer was 1.
	; hSndInfoCurDataPtr++
	inc  bc
	ld   a, c
	ldh  [hSndInfoCurDataPtr_Low], a
	ld   a, b
	ldh  [hSndInfoCurDataPtr_High], a
	ret
	;--
.contLoop:
	; If the loop timer isn't 0, it's been already initialized.

	; Skip initial timer value
	; hSndInfoCurDataPtr++
	ldh  a, [hSndInfoCurDataPtr_Low]
	add  a, $01
	ldh  [hSndInfoCurDataPtr_Low], a
	ldh  a, [hSndInfoCurDataPtr_High]
	adc  a, $00
	ldh  [hSndInfoCurDataPtr_High], a

	dec  [hl]							; Decrement loop timer
	jr   nz, Sound_Cmd_JpFromLoop	; Is it 0 now? If not, jump

	; Otherwise, the looping is over. Seek past the end of the data for this command.
	; While there are two bytes to to seek past, we're only incrementing by 1 due to Sound_IncDataPtr being called automatically at the end.
	ldh  a, [hSndInfoCurDataPtr_Low]
	add  a, $01
	ldh  [hSndInfoCurDataPtr_Low], a
	ldh  a, [hSndInfoCurDataPtr_High]
	adc  a, $00
	ldh  [hSndInfoCurDataPtr_High], a
	ret

; =============== Sound_Cmd_JpFromLoop ===============
; If called directly as a sound command, this will always loop the sound channel without loop limit.

; The next two data bytes will be treated as new hSndInfoCurDataPtr.
; Command data format:
; - 0: Sound data ptr (low byte)
; - 1: Sound data ptr (high byte)
Sound_Cmd_JpFromLoop:
	; HL = hSndInfoCurDataPtr_Low
	ldh  a, [hSndInfoCurDataPtr_Low]
	ld   l, a
	ldh  a, [hSndInfoCurDataPtr_High]
	ld   h, a

	; BC = *hSndInfoCurDataPtr_Low - 1
	; -1 to balance out the automatic call to Sound_IncDataPtr when the subroutine returns.
	ldi  a, [hl]
	ld   c, a
	ld   a, [hl]
	ld   b, a
	dec  bc

	; Write it back
	ld   a, c
	ldh  [hSndInfoCurDataPtr_Low], a
	ld   a, b
	ldh  [hSndInfoCurDataPtr_High], a
	ret

; =============== Sound_Cmd_Call ===============
; Saves the current data ptr, then sets a new one.
; This is handled like code calling a subroutine.
; Command data format:
; - 0: Sound data ptr (low byte)
; - 1: Sound data ptr (high byte)
Sound_Cmd_Call:
	;
	; Read 2 bytes of sound data to BC, and increment the data ptr
	;

	; HL = hSndInfoCurDataPtr
	ldh  a, [hSndInfoCurDataPtr_Low]
	ld   l, a
	ldh  a, [hSndInfoCurDataPtr_High]
	ld   h, a

	; Read out the word value (jump target) to BC
	ldi  a, [hl]						; hSndInfoCurDataPtr++
	ld   c, a
	ld   a, [hl] 						; Not ldi because Sound_IncDataPtr, so it won't be needed to do it on Sound_Cmd_Ret
	ld   b, a

	; For now write back the original incremented hSndInfoCurDataPtr, which is what will be written to the "stack".
	ld   a, l
	ldh  [hSndInfoCurDataPtr_Low], a
	ld   a, h
	ldh  [hSndInfoCurDataPtr_High], a

	;
	; Save the current sound data pointer in a stack-like way.
	;
	push bc
		; Seek to the stack index value
		ld   hl, iSndInfo_DataPtrStackIdx
		add  hl, de

		; Decrement the stack index twice, since we're writing a pointer (2 bytes).
		; Also, read it out to A, but since we'll be writing the data ptr to the "stack" with ldd,
		; the value in A will only be decremented by one.
		; (could have also used ldi, it isn't any slower)
		dec  [hl]
		ld   a, [hl]
		dec  [hl]

		; HL = A
		ld   l, a
		ld   h, $00

		; Index the stack location (at the second byte of the word entry)
		add  hl, de

		; Write the second byte first
		ldh  a, [hSndInfoCurDataPtr_High]
		ldd  [hl], a						; HL--
		; Then the first byte
		ldh  a, [hSndInfoCurDataPtr_Low]
		ld   [hl], a
	pop  bc

	; Replace the current data ptr with BC-1 (to account for Sound_IncDataPtr)
	dec  bc
	ld   a, c
	ldh  [hSndInfoCurDataPtr_Low], a
	ld   a, b
	ldh  [hSndInfoCurDataPtr_High], a
	ret

; =============== Sound_Cmd_Ret ===============
; Restores the data ptr previously saved in Sound_Cmd_Call.
; This acts like code returning from a subroutine.
Sound_Cmd_Ret:
	; Read the stack index value to A
	ld   hl, iSndInfo_DataPtrStackIdx
	add  hl, de
	ld   a, [hl]

	; Use it to index the stack location with the data ptr
	ld   l, a
	ld   h, $00
	add  hl, de

	; Restore the data ptr
	; NOTE: What is stored at HL already accounts for Sound_IncDataPtr.
	ldi  a, [hl]
	ldh  [hSndInfoCurDataPtr_Low], a
	ld   a, [hl]
	ldh  [hSndInfoCurDataPtr_High], a

	; Increment the stack index twice
	ld   hl, iSndInfo_DataPtrStackIdx
	add  hl, de
	inc  [hl]
	inc  [hl]
	ret

; =============== Sound_Cmd_SetWaveData ===============
; Writes a complete set of wave data. This will disable ch3 playback.
;
; Command data format:
; - 0: Wave set id
Sound_Cmd_SetWaveData:

	; Ignore if the sound channel is used by a SFX
	ld   a, [de]
	bit  SISB_USEDBYSFX, a
	ret  nz

	; Disable wave ch
	xor  a
	ldh  [rNR30], a

	; Read wave set id from data
	ldh  a, [hSndInfoCurDataPtr_Low]
	ld   l, a
	ldh  a, [hSndInfoCurDataPtr_High]
	ld   h, a
	ld   a, [hl]

	; Write it to the SndInfo
	ld   hl, iSndInfo_WaveSetId
	add  hl, de
	ld   [hl], a

	; Index the ptr table with wave sets
	ld   hl, Sound_WaveSetPtrTable
	call Sound_IndexPtrTable				; HL = Wave table entry ptr

	; Replace the current wave data
	ld   c, LOW(rWave)						; C = Ptr to start of wave ram
	ld   b, rWave_End-rWave					; B = Bytes to copy
.loop:
	ldi  a, [hl]							; Read from wave set
	ld   [c], a								; Write it to the wave reg
	inc  c									; Ptr++
	dec  b									; Copied all bytes?
	jr   nz, .loop							; If not, loop
	ret

; =============== Sound_SetWaveDataCustom ===============
; Writes a complete set of wave data. This will disable ch3 playback.
;
; IN
; - HL: Ptr to a wave set id
Sound_SetWaveDataCustom:
	; Disable wave ch
	ld   a, $00
	ldh  [rNR30], a

	; Index the ptr table with wave sets
	ld   a, [hl]
	ld   hl, Sound_WaveSetPtrTable
	call Sound_IndexPtrTable				; HL = Wave table entry ptr

	; Replace the current wave data
	ld   c, LOW(rWave)						; C = Ptr to start of wave ram
	ld   b, rWave_End-rWave					; B = Bytes to copy
.loop:
	ldi  a, [hl]							; Read from wave set
	ld   [c], a								; Write it to the wave reg
	inc  c									; Ptr++
	dec  b									; Copied all bytes?
	jr   nz, .loop							; If not, loop
	ret

; =============== Sound_Cmd_Unused_EndChFlagBF ===============
; [TCRF] Unused command.
Sound_Cmd_Unused_EndChFlagBF:
	ld   a, [wSnd_Unused_ChUsed]
	and  a, $BF
	ld   [wSnd_Unused_ChUsed], a
	jr   Sound_Cmd_EndCh

; =============== Sound_Cmd_Unused_EndChFlag7F ===============
; [TCRF] Unused command.
Sound_Cmd_Unused_EndChFlag7F:
	ld   a, [wSnd_Unused_ChUsed]
	and  a, $7F
	ld   [wSnd_Unused_ChUsed], a

; =============== Sound_Cmd_EndCh ===============
; Called to permanently stop channel playback (ie: the song/sfx ended and didn't loop).
; This either stops the sound channel or resumes playback of the BGM.
Sound_Cmd_EndCh:

	; Mute the sound channel if there isn't a SFX playing on here, for good measure.
	; This isn't really needed.
	call Sound_SilenceCh

	; HL = SndInfo base
	ldh  a, [hSndInfoCurPtr_Low]
	ld   l, a
	ldh  a, [hSndInfoCurPtr_High]
	ld   h, a

	;
	; Check if a BGM is currently playing.
	; Checking if wBGMCh1Info is enabled should be enough, given it's the main channel and every song defines/enables it.
	; If nothing is playing (BGM just ended, or SFX ended with no music), only mute the channel and disable this SndInfo.
	;
	ld   a, [wBGMCh1Info]
	bit  SISB_ENABLED, a		; Is playback enabled for ch1?
	jr   z, .stopCh				; If not, skip to the end

.bgmPlaying:

	ld   a, [hl]
	bit  SISB_SFX, a		; Is this a SFX?
	jr   nz, .isSFX			; If so, jump

.isBGM:
	; If this is a BGM SndInfo, completely disable this SndInfo (but don't mute the channel)
	xor  a				; Erase the status flags
	ld   [hl], a

	; Prevent Sound_IncDataPtr from being executed
	pop  hl
	ret

.isSFX:
	; If this is a SFX SndInfo, reapply the BGM SndInfo to the sound registers.

	; Disable this SndInfo
	xor  a
	ld   [hl], a

	; Seek to the NR*1 info of the BGM SndInfo of the current channel.
	; The SFX SndInfo are right after the ones for the BGM, which is why we move back.
	ld   bc, -(SNDINFO_SIZE * 4) + iSndInfo_RegNRx1Data
	add  hl, bc
	push hl
		; Seek to RegPtr of SFX SndInfo
		ld   hl, iSndInfo_RegPtr
		add  hl, de
		ld   a, [hl]
	pop  hl

	; Read it out to C (-1)
	ld   c, a
	dec  c


.ch1ExtraClr:
	;
	; If we're processing ch1, clear NR10.
	; We must clear it manually since that register can't be reached otherwise.
	;
	cp   SND_CH1_PTR		; Processing ch1?
	jr   nz, .ch3SkipChk	; If not, skip
	ld   a, $08				; Otherwise, clear ch1 reg
	ldh  [rNR10], a
.ch3SkipChk:

	;
	; If we're processing ch3, skip updating rNR31 and *don't* handle iSndInfo_VolPredict.
	; This is because ch3 doesn't go through the volume prediction system in Sound_UpdateVolPredict,
	; so it'd be useless.
	;

	cp   SND_CH3_PTR		; Processing ch3?
	jr   nz, .cpAll			; If not, jump

	; A = iSndInfo_RegNRx2Data
	inc  hl			; Seek to iSndInfo_Unknown_Unused_NR10Data
	inc  hl			; Seek to iSndInfo_VolPredict
	inc  hl			; Seek to iSndInfo_RegNRx2Data
	ldi  a, [hl] 	; Read it

	jr   .cpNRx2

.cpAll:
	; Now copy over all of the BGM SndInfo to the registers.

	;
	; NR*1
	;
	dec  c				; Decrease C again since HL is pointing to iSndInfo_RegNRx1Data

	; Write the value of the BGM iSndInfo_RegNRx1Data to NR*1
	ldi  a, [hl]		; Seek to iSndInfo_Unknown_Unused_NR10Data
	ld   [c], a

	;
	; NR*2
	;

	;
	; Merge the volume settings from iSndInfo_VolPredict with the existing
	; low byte of iSndInfo_RegNRx2Data.
	;

	inc  hl				; Seek to BGM iSndInfo_VolPredict
	inc  c				; seek to NR*2
	; B = BGM Volume info
	ldi  a, [hl]
	and  a, $F0				; Only in the upper nybble
	ld   b, a
	; A = BGM iSndInfo_RegNRx2Data
	ldi  a, [hl]
	and  a, $0F				; Get rid of its volume info
	add  b					; Merge it with the one from iSndInfo_VolPredict
.cpNRx2:
	ld   [c], a				; Write it to NR*2


	;
	; NR*3
	;
	inc  c
	ldi  a, [hl]			; Seek to NR*4 too
	ld   [c], a

	;
	; NR*4
	;
	inc  c
	push hl
		; A = RegPtr of SFX SndInfo
		ld   hl, iSndInfo_RegPtr
		add  hl, de
		ld   a, [hl]
	pop  hl

	; Ch3 is stopped in a different way
	cp   SND_CH3_PTR	; Processing ch3?
	jr   z, .stopCh3	; If so, jump

	; Write BGM iSndInfo_RegNRx4Data to NR*4, and restart the tone
	ldi  a, [hl]
	or   a, SNDCHF_RESTART
	ld   [c], a

	; Restore the "enabled channels" register from the BGM-only copy
	ld   a, [wSndEnaChBGM]
	ldh  [rNR51], a

.stopCh:

	;
	; Mutes and stops the sound channel.
	;

	;--
	; Write $00 to the sound register NR*2 to silence it.
	; This is also done in Sound_SilenceCh, but it's repeated here just in case Sound_SilenceCh doesn't mute playback?)
	ld   hl, iSndInfo_RegPtr
	add  hl, de

	ld   a, [hl]			; C = iSndInfo_RegPtr-1
	dec  a
	ld   c, a
	xor  a					; A = $00
	ld   [c], a				; Write it to C
	;--

	;
	; Write $00 to the status byte of the current SndInfo.
	; This outright stops its playback.
	;

	; HL = SndInfo base
	ldh  a, [hSndInfoCurPtr_Low]
	ld   l, a
	ldh  a, [hSndInfoCurPtr_High]
	ld   h, a

	xor  a
	ld   [hl], a

	; Prevent Sound_IncDataPtr from being executed, since we disabled the channel playback
	pop  hl
	ret

.stopCh3:
	;--
	;
	; Make ch3 stop when its length expires.
	; [POI] Weirdly organized code. The first two lines are pointless,
	;       as is the useless $FF check.
	;

	ld   a, [wSnd_Ch3StopLength]
	or   a
	;--
	ldi  a, [hl]			; Read from iSndInfo_RegNRx4Data, seek to iSndInfo_ChEnaMask
	cp   $FF
	jr   z, .isFF
	or   a, SNDCHF_LENSTOP	; Set kill flag
.isFF:
	ld   [c], a				; Write to rNR34

	;
	; Restore the BGM wave set
	;
	inc  hl					; Seek to iSndInfo_WaveSetId
	call Sound_SetWaveDataCustom

	; Prevent Sound_IncDataPtr from being executed
	pop  hl
	ret

; =============== Sound_UpdateVolPredict ===============
; Updates the volume prediction value.
;
; Every frame, the timer in the low nybble of iSndInfo_VolPredict ticks up from $00 until
; it matches the low nybble of iSndInfo_RegNRx2Data (essentially the amount of envelope sweeps + dir flag).
;
; Once the timer/sweep count matches, the predicted volume level is decreased with a decreasing envelope sweep,
; or increased with an increasing one.
;
; IN
; - HL: Ptr to iSndInfo_VolPredict field
; - DE: Ptr to iSndInfo_RegNRx2Data field
Sound_UpdateVolPredict:
	inc  [hl]			; iSndInfo_VolPredict++

	; If the timers don't match yet, return
	ld   a, [hl]		; C = iSndInfo_VolPredict & $0F
	and  a, $0F
	ld   c, a
	ld   a, [de]		; A = iSndInfo_RegNRx2Data & $0F
	and  a, $0F
	cp   a, c			; A != C?
	ret  nz				; If so, return

	; Either increase or decrease the volume depending on the envelope direction
	bit  SNDENVB_INC, a	; Is bit 3 set?
	jr   z, .dec		; If not, decrease the volume
.inc:
	; Reset the timer and increase the volume by 1
	ld   a, [hl]		; A = (iSndInfo_VolPredict & $F0) + $10
	and  a, $F0
	add  a, $10
	ret  c				; If we overflowed, return
	ld   [hl], a		; Save it to iSndInfo_VolPredict
	ret
.dec:
	; Reset the timer and decrease the volume by 1
	ld   a, [hl]		; A = (iSndInfo_VolPredict & $F0)
	and  a, $F0
	ret  z				; If it's already 0, return
	sub  a, $10			; A -= $10
	ld   [hl], a		; Save it to iSndInfo_VolPredict
	ret

; =============== Sound_SilenceCh ===============
; Writes $00 to the sound register NR*2, which silences the volume the sound channel (but doesn't disable it).
; This checks if the sound channel is being used by a sound effect, and if so, doesn't perform the write.
; IN
; - DE: SndInfo base ptr. Should be a wBGMCh*Info structure.
Sound_SilenceCh:
	; Seek to iSndInfo_RegPtr and read out its value
	; C = Destination register (RegPtr - 1)
	ld   hl, iSndInfo_RegPtr
	add  hl, de
	ld   a, [hl]
	dec  a
	ld   c, a

	; A = Value to write
	xor  a

	; Seek to SndInfo status
	ld   hl, iSndInfo_Status
	add  hl, de

	bit  SISB_USEDBYSFX, [hl]	; Is the sound channel being used by a sound effect?
	ret  nz						; If so, return
	ld   [c], a					; Otherwise, write the $00 value to the register
	ret

; =============== Sound_WriteToReg ===============
; Writes a value to the specified sound register.
; This checks if the sound channel is being used by a sound effect, and if so, doesn't perform the write.
; IN
; - A: Data to write to the sound register
; - C: Ptr to sound register
; - DE: SndInfo base ptr. Should be a wBGMCh*Info structure.
Sound_WriteToReg:
	; Seek to SndInfo status
	ld   hl, iSndInfo_Status
	add  hl, de

	bit  SISB_USEDBYSFX, [hl]	; Is the sound channel being used a sound effect?
	ret  nz						; If so, return
	ld   [c], a					; Otherwise, write the value to the register
	ret
; =============== Sound_MarkSFXChUse ===============
; Registers to the BGM Channel Info if a sound effect is currently using that channel.
; This sets/unsets the flag to mute BGM playback for the channel, in order to not cut off the sound effect.
; IN
; - DE: Ptr to SFX Channel Info (iSndInfo)
; - HL: Ptr to BGM Channel Info (iSndInfo)
Sound_MarkSFXChUse:
	; If the channel is being currently used
	ld   a, [de]		; Read iSndInfo_Status
	or   a				; Is a sound effect playing here?
	jr   z, .clrSFXPlay	; If not, jump
.setSFXPlay:
	set  SISB_USEDBYSFX, [hl]		; Mark as used
	ret
.clrSFXPlay:
	res  SISB_USEDBYSFX, [hl]		; Mark as free
	ret

; =============== Sound_IndexPtrTable ===============
; Indexes a pointer table.
;
; IN
; - HL: Ptr to ptr table
; -  A: Index (starting at $01)
; OUT
; - HL: Indexed value
Sound_IndexPtrTable:
	; Offset the table
	; BC = A - 1
	dec  a
	ld   c, a
	ld   b, $00
	; HL += BC * 2
	add  hl, bc
	add  hl, bc
	; Read out ptr to HL
	ldi  a, [hl]
	ld   h, [hl]
	ld   l, a
	ret

; =============== Sound_Init ===============
; Initializes the sound driver.
Sound_Init:
	; Enable sound hardware
	ld   a, SNDCTRL_ON
	ldh  [rNR52], a

	;
	; Clear channel registers.
	; This zeroes out addresses in the list at Sound_ChRegAddrTable.
	;
	ld   hl, Sound_ChRegAddrTable		; HL = Start of table
	ld   b, (Sound_ChRegAddrTable.end-Sound_ChRegAddrTable)	; B = Bytes to overwrite (table size)
	xor  a								; A = Value copied
.loop:
	ld   c, [hl]		; Read the ptr to C
	ld   [c], a			; Write $00 to $FF00+C
	inc  hl				; Ptr++
	dec  b				; Copied all bytes?
	jr   nz, .loop		; If not, loop

; =============== Sound_StopAll ===============
; Reloads the sound driver, which stops any currently playing song.
Sound_StopAll:
	;
	; Clear the entire memory range used by the sound driver (wBGMCh1Info-$D5C5)
	;
	ld   hl, wBGMCh1Info		; HL = Initial addr
	xor  a				; A = $00
	ld   c, $09			; BC = ($09*$20)
.loopH:
	ld   b, $20
.loopL:
	ldi  [hl], a		; Clear byte
	dec  b				; B == 0?
	jr   nz, .loopL		; If not, loop
	dec  c				; C == 0?
	jr   nz, .loopH		; If not, loop

	;
	; Initialize other regs
	;
	ld   a, %1110111	; Set max volume for both left/right speakers
	ldh  [rNR50], a

	xor  a
	ld   [wSnd_Unused_ChUsed], a
.initNR:
	ld   a, $08			; Use downwards sweep for ch1 (standard)
	ldh  [rNR10], a
	xor  a
	ldh  [rNR30], a		; Stop Ch3
	ldh  [rNR51], a		; Silence all channels

	ld   a, $80
	ld   [wSnd_Unk_Unused_D480], a
	ret

; =============== Sound_Unused_InitCh1Regs ===============
; [TCRF] Unreferenced code.
Sound_Unused_InitCh1Regs:
	ld   a, $FF
	ldh  [rNR51], a
	ld   a, $80
	ldh  [rNR11], a
	ld   a, $F7
	ldh  [rNR12], a
	ld   a, $D6
	ldh  [rNR13], a
	ld   a, $86
	ldh  [rNR14], a
	ret

; =============== Sound_Unused_InitCh2Regs ===============
; [TCRF] Unreferenced code.
Sound_Unused_InitCh2Regs:
	ld   a, $F7
	ldh  [rNR22], a
	ld   a, $14
	ldh  [rNR23], a
	ld   a, $87
	ldh  [rNR24], a
	ret

; =============== Sound_ChRegAddrTable ===============
; List of memory adddresses cleared by Sound_Init.
Sound_ChRegAddrTable:
	db LOW(rNR10)
	db LOW(rNR11)
	db LOW(rNR12)
	db LOW(rNR13)
	db LOW(rNR14)
	db LOW(rNR21)
	db LOW(rNR22)
	db LOW(rNR23)
	db LOW(rNR24)
	db LOW(rNR30)
	db LOW(rNR31)
	db LOW(rNR32)
	db LOW(rNR33)
	db LOW(rNR34)
	db LOW(rNR41)
	db LOW(rNR42)
	db LOW(rNR43)
	db LOW(rNR44)
.end:

; =============== Sound_SndHeaderPtrTable ===============
; Table of sound headers, ordered by ID.
; Each of the valid ones follows the format as specified in iSndHeader_*
;
; Unused entries in the table mostly point to code, which is in no way a valid header.
Sound_SndHeaderPtrTable:
	dw SndHeader_BGM_Roulette;X         ; SND_NONE
	dw SndHeader_BGM_Roulette           ; BGM_ROULETTE
	dw SndHeader_BGM_StageClear         ; BGM_STAGECLEAR
	dw SndHeader_BGM_BigShot            ; BGM_BIGSHOT
	dw SndHeader_BGM_Esaka              ; BGM_ESAKA
	dw SndHeader_BGM_RisingRed          ; BGM_RISINGRED
	dw SndHeader_BGM_Geese              ; BGM_GEESE
	dw SndHeader_BGM_Arashi             ; BGM_ARASHI
	dw SndHeader_BGM_Fairy              ; BGM_FAIRY
	dw SndHeader_BGM_TrashHead          ; BGM_TRASHHEAD
	dw SndHeader_BGM_Wind               ; BGM_WIND
	dw SndHeader_BGM_ToTheSky           ; BGM_TOTHESKY
	dw SndHeader_Pause                  ; SNC_PAUSE
	dw SndHeader_Unpause                ; SNC_UNPAUSE
	dw SndHeader_SFX_CursorMove         ; SFX_CURSORMOVE
	dw SndHeader_SFX_CharSelected       ; SFX_CHARSELECTED
	dw SndHeader_SFX_ChargeMeter        ; SFX_CHARGEMETER
	dw SndHeader_SFX_SuperMove          ; SFX_SUPERMOVE
	dw SndHeader_SFX_Light              ; SFX_LIGHT
	dw SndHeader_SFX_Heavy              ; SFX_HEAVY
	dw SndHeader_SFX_Block              ; SFX_BLOCK
	dw SndHeader_SFX_Taunt              ; SFX_TAUNT
	dw SndHeader_SFX_Hit                ; SFX_HIT
	dw SndHeader_SFX_MultiHit           ; SFX_MULTIHIT
	dw SndHeader_BGM_Protector          ; BGM_PROTECTOR
	dw SndHeader_BGM_MrKarate           ; BGM_MRKARATE
	dw SndHeader_SFX_GroundHit          ; SFX_GROUNDHIT
	dw SndHeader_SFX_Drop               ; SFX_DROP
	dw SndHeader_SFX_SuperJump          ; SFX_SUPERJUMP
	dw SndHeader_SFX_Step               ; SFX_STEP
	dw SndHeader_BGM_In1996             ; BGM_IN1996
	dw SndHeader_BGM_MrKarateCutscene   ; BGM_MRKARATECUTSCENE
	dw Sound_StartNothing;X             ; #SND_ID_20
	dw Sound_StartNothing;X             ; #SND_ID_21
	dw Sound_StartNothing;X             ; #SND_ID_22
	dw Sound_StartNothing;X             ; #SND_ID_23
	dw Sound_StartNothing;X             ; #SND_ID_24
	dw Sound_StartNothing;X             ; #SND_ID_25
	dw SndHeader_SFX_StepHeavy          ; SFX_STEP_HEAVY
	dw SndHeader_SFX_Grab               ; SFX_GRAB
	dw SndHeader_SFX_FireHitA           ; SFX_FIREHIT_A
	dw SndHeader_SFX_FireHitB           ; SFX_FIREHIT_B
	dw SndHeader_SFX_MoveJumpA          ; SFX_MOVEJUMP_A
	dw SndHeader_SFX_ProjSm             ; SFX_PROJ_SM
	dw SndHeader_SFX_MoveJumpB          ; SFX_MOVEJUMP_B
	dw SndHeader_SFX_Reflect            ; SFX_REFLECT
	dw SndHeader_SFX_Unused_Siren       ; SFX_UNUSED_SIREN
	dw SndHeader_SFX_Unused_Null        ; SFX_UNUSED_NULL
	dw SndHeader_SFX_PsychoTeleport     ; SFX_PSYCTEL
	dw SndHeader_SFX_GameOver           ; SFX_GAMEOVER
	dw Sound_StartNothing;X             ; #SND_ID_32
	dw Sound_StartNothing;X             ; #SND_ID_33

; =============== Sound_FreqDataTbl ===============
; Table with pairs of frequency values for the frequency registers (sound channels 1-2-3).
; Essentially these are "musical notes" ordered from lowest to highest.
Sound_FreqDataTbl:
	dw $0000
	dw $002C
	dw $009C
	dw $0106
	dw $016B
	dw $01C9
	dw $0223
	dw $0277
	dw $02C7
	dw $0312
	dw $0358
	dw $039B
	dw $03DA
	dw $0416
	dw $044E
	dw $0483
	dw $04B5
	dw $04E5
	dw $0511
	dw $053C
	dw $0563
	dw $0589
	dw $05AC
	dw $05CE
	dw $05ED
	dw $060B
	dw $0628
	dw $0642
	dw $065B
	dw $0672
	dw $0689
	dw $069E
	dw $06B2
	dw $06C4
	dw $06D6
	dw $06E7
	dw $06F7
	dw $0705
	dw $0714
	dw $0721
	dw $072D
	dw $0739
	dw $0744
	dw $074F
	dw $0759
	dw $0762
	dw $076B
	dw $0773
	dw $077B
	dw $0783
	dw $078A
	dw $0790
	dw $0797
	dw $079D
	dw $07A2
	dw $07A7
	dw $07AC
	dw $07B1
	dw $07B6
	dw $07BA
	dw $07BE
	dw $07C1
	dw $07C5
	dw $07C8
	; [TCRF] Rest is unused.
	dw $07CB;X
	dw $07CE;X
	dw $07D1;X
	dw $07D4;X
	dw $07D6;X
	dw $07D9;X
	dw $07DB;X
	dw $07DD;X
	dw $07DF;X
	dw $07E1;X


; =============== Sound_WaveSetPtrTable ===============
; Sets of Wave data for channel 3, copied directly to the rWave registers.
; [TCRF] More than half of the sets are unused!
Sound_WaveSetPtrTable:
	dw Sound_WaveSet0
	dw Sound_WaveSet1
	dw Sound_WaveSet2
	dw Sound_WaveSet3
	dw Sound_WaveSet_Unused_4
	dw Sound_WaveSet_Unused_5
	dw Sound_WaveSet_Unused_6
	dw Sound_WaveSet_Unused_7
	dw Sound_WaveSet_Unused_8
	dw Sound_WaveSet_Unused_9

Sound_WaveSet0: db $01,$23,$45,$67,$89,$AB,$CD,$EF,$ED,$CB,$A9,$87,$65,$43,$21,$00
Sound_WaveSet1: db $FF,$EE,$DD,$CC,$BB,$AA,$99,$88,$77,$66,$55,$44,$33,$22,$11,$00
Sound_WaveSet2: db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00
Sound_WaveSet3: db $FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
Sound_WaveSet_Unused_4: db $02,$46,$89,$AB,$CC,$DD,$EE,$FF,$FE,$ED,$DD,$CC,$BA,$98,$64,$31
Sound_WaveSet_Unused_5: db $CF,$AF,$30,$12,$21,$01,$7F,$C2,$EA,$07,$FC,$62,$12,$5B,$FB,$12
Sound_WaveSet_Unused_6: db $86,$33,$22,$11,$00,$0B,$EF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$EE
Sound_WaveSet_Unused_7: db $87,$76,$65,$54,$43,$32,$21,$10,$0F,$FE,$ED,$DC,$CB,$BA,$A9,$98
Sound_WaveSet_Unused_8: db $18,$F2,$68,$4E,$18,$76,$1A,$4C,$85,$43,$2E,$DC,$FF,$12,$84,$48
Sound_WaveSet_Unused_9: db $CC,$6B,$93,$77,$28,$BA,$6E,$35,$51,$C3,$9C,$ED,$B8,$2B,$29,$E2

INCLUDE "data/sound/sfx_cursor_move.asm"
INCLUDE "data/sound/sfx_char_selected.asm"
INCLUDE "data/sound/sfx_charge_meter.asm"
INCLUDE "data/sound/sfx_super_move.asm"
INCLUDE "data/sound/sfx_light.asm"
INCLUDE "data/sound/sfx_heavy.asm"
INCLUDE "data/sound/sfx_block.asm"
INCLUDE "data/sound/sfx_taunt.asm"
INCLUDE "data/sound/sfx_hit.asm"
INCLUDE "data/sound/sfx_multi_hit.asm"
INCLUDE "data/sound/sfx_ground_hit.asm"
INCLUDE "data/sound/sfx_drop.asm"
INCLUDE "data/sound/sfx_super_jump.asm"
INCLUDE "data/sound/sfx_step.asm"
INCLUDE "data/sound/sfx_step_heavy.asm"
INCLUDE "data/sound/sfx_grab.asm"
INCLUDE "data/sound/sfx_fire_hit_a.asm"
INCLUDE "data/sound/sfx_fire_hit_b.asm"
INCLUDE "data/sound/sfx_move_jump_a.asm"
INCLUDE "data/sound/sfx_proj_sm.asm"
INCLUDE "data/sound/sfx_move_jump_b.asm"
INCLUDE "data/sound/sfx_reflect.asm"
INCLUDE "data/sound/sfx_unused_siren.asm"
INCLUDE "data/sound/sfx_unused_null.asm"
INCLUDE "data/sound/sfx_psycho_teleport.asm"
INCLUDE "data/sound/sfx_game_over.asm"
INCLUDE "data/sound/cmd_pause_unpause.asm"
INCLUDE "data/sound/bgm_geese.asm"
INCLUDE "data/sound/bgm_fairy.asm"
INCLUDE "data/sound/bgm_esaka.asm"
INCLUDE "data/sound/bgm_mr_karate_cutscene.asm"
INCLUDE "data/sound/bgm_in1996.asm"
INCLUDE "data/sound/bgm_mr_karate.asm"
INCLUDE "data/sound/bgm_big_shot.asm"
INCLUDE "data/sound/bgm_protector.asm"
INCLUDE "data/sound/bgm_to_the_sky.asm"
INCLUDE "data/sound/bgm_wind.asm"
INCLUDE "data/sound/bgm_trash_head.asm"
INCLUDE "data/sound/bgm_arashi.asm"
INCLUDE "data/sound/bgm_rising_red.asm"
INCLUDE "data/sound/bgm_stage_clear.asm"
INCLUDE "data/sound/bgm_roulette.asm"

; =============== Sound_ReqPlayId ===============
; Requests playback for a new sound ID.
; IN
; - D: Sound ID to play
Sound_ReqPlayId:

	; Increment request counter
	ldh  a, [hSndPlaySetCnt]	; E = hSndPlaySetCnt+1 % 8
	inc  a
	and  a, $07
	ld   e, a					; Save val

	; Use request counter as index to wSndIdReqTbl
	; and write the Sound ID there
	add  a, LOW(wSndIdReqTbl)	; HL = wSndIdReqTbl + A
	ld   l, a
	ld   h, HIGH(wSndIdReqTbl)
	ld   [hl], d				; Write ID there

	; Save request counter
	ld   a, e					; Restore val
	ldh  [hSndPlaySetCnt], a
	ret
	mIncJunk "L1F7D4B"

; =============== Sound_ReqPlayExId ===============
; Requests playback for the sound associated with the specified action.
; Some may be played on the SGB side if possible.
; IN:
; - A: Action ID or DMG Sound ID
Sound_ReqPlayExId:
	; Check for special DMG-only cases
	bit  7, a			; A >= SND_BASE ($80)?
	jp   nz, .dmgPlay	; If so, this is a DMG sound ID. Always handle it on the DMG side.
	or   a				; A == $00?
	jp   z, .dmgPlay	; If so, it's a stop command. Handle it on the DMG side.

	ld   b, a			; Save for later in case of SGB mode

	; Offset the table entry
	dec  a					; Offset by 1
	ld   hl, Sound_ActTbl	; HL = Base table ptr
	ld   d, $00				; DE = A * 3 (table entry size)
	ld   e, a
	sla  a
	add  a, e
	ld   e, a
	add  hl, de				; HL = Start of table entry


	; Determine which of the 3 bytes to pick and what to do with it
	ld   a, [wMisc_C025]
	bit  MISCB_IS_SGB, a	; SGB hardware?
IF NO_SGB_SOUND
	jp   .dmg
ELSE
	jp   z, .dmg			; If not, jump
ENDC
.sgb:
	; On the SGB side use bytes 1-2 as a 16bit word
	ld   a, b				; A = Action ID
	inc  hl
	ld   d, [hl]			; D = Sound Effect ID
	inc  hl
	ld   e, [hl]			; E = Sound Effect Attributes
	push de
	pop  hl					; HL = DE

	; With action $01, randomize the SFX pitch.
	cp   a, $01				; Action ID == $01?
	jp   nz, .sgbPlay		; If not, jump
.act01spec:
	; Pitch -> random; Volume -> max
	ld   a, [wTimer]		; L = (wTimer & $03)
	and  a, $03
	ld   l, a
.sgbPlay:
	call SGB_PrepareSoundPacketA
	ret
.dmg:
	; On the DMG side use byte0 as sound ID
	ld   a, [hl]			; A = DMG sound ID
.dmgPlay:
	call HomeCall_Sound_ReqPlayId
	ret
; =============== Sound_ActTbl ===============
; Table of actions, which map to both a DMG and SGB sound.
; Format:
; - 0: DMG Sound ID
; - 1: SGB Sound ID (Set A)
; - 2: SGB Sound Attributes (Set A)
Sound_ActTbl:
.act00: db SFX_DROP,         SGB_SND_A_LASER_SM,   $00            ; SCT_DIZZY
.act01: db SFX_TAUNT,        SGB_SND_A_FASTJUMP,   $00            ; SCT_TAUNT_A
.act02: db SFX_TAUNT,        SGB_SND_A_FASTJUMP,   $01            ; SCT_TAUNT_B
.act03: db SFX_TAUNT,        SGB_SND_A_FASTJUMP,   $02            ; SCT_TAUNT_C
.act04: db SFX_TAUNT,        SGB_SND_A_FASTJUMP,   $03            ; SCT_TAUNT_D
.act05: db SFX_CHARGEMETER,  SGB_SND_A_FADEIN,     $03            ; SCT_CHARGEMETER
.act06: db SFX_CHARSELECTED, SGB_SND_A_GLASSBREAK, $03            ; SCT_CHARGEFULL
.act07: db SFX_LIGHT,        SGB_SND_A_ATTACK_B,   $03            ; SCT_LIGHT
.act08: db SFX_HEAVY,        SGB_SND_A_ATTACK_B,   $02            ; SCT_HEAVY
.act09: db SFX_BLOCK,        SGB_SND_A_GATE,       $03            ; SCT_BLOCK
.act0A: db SFX_HIT,          SGB_SND_A_PUNCH_A,    $03            ; SCT_HIT
.act0B: db SFX_MULTIHIT,     SGB_SND_A_ATTACK_A,   $03            ; SCT_MULTIHIT
.act0C: db SFX_BLOCK,        SGB_SND_A_WINOPEN,    $03            ; SCT_AUTOBLOCK
.act0D: db SFX_GROUNDHIT,    SGB_SND_A_PUNCH_B,    $01            ; SCT_GROUNDHIT
.act0E: db SFX_REFLECT,      SGB_SND_A_WATERFALL,  $03            ; SCT_REFLECT
.act0F: db SFX_PROJ_SM,      SGB_SND_A_SWORDSWING, $03            ; SCT_PROJ_SM
.act10: db SFX_MOVEJUMP_A,   SGB_SND_A_ATTACK_B,   $01            ; SCT_MOVEJUMP_A
.act11: db SFX_MOVEJUMP_B,   SGB_SND_A_ATTACK_B,   $01            ; SCT_MOVEJUMP_B
.act12: db SFX_FIREHIT_B,    SGB_SND_A_PUNCH_A,    $01            ; SCT_FIREHIT
.act13: db SFX_FIREHIT_B,    SGB_SND_A_PUNCH_A,    $00            ; SCT_PROJ_LG_A
.act14: db SFX_FIREHIT_B,    SGB_SND_A_FIRE,       $02            ; SCT_PHYSFIRE
.act15: db SFX_FIREHIT_B,    SGB_SND_A_FIRE,       $03|($01 << 2) ; SCT_PROJ_LG_B
.act16: db SFX_HEAVY,        SGB_SND_A_SWORDSWING, $02            ; SCT_UNUSED_16 [TCRF]
.act17: db SFX_PROJ_SM,      SGB_SND_A_JETSTART,   $01            ; SCT_SHCRYSTSPAWN
.act18: db SFX_PROJ_SM,      SGB_SND_A_PICTFLOAT,  $03            ; SCT_PSYCREFLAND
.act19: db SFX_REFLECT,      SGB_SND_A_JETPROJ_B,  $03            ; SCT_HISHOKEN
.act1A: db SFX_GRAB,         SGB_SND_A_SELECT_B,   $03            ; SCT_GRAB
.act1B: db SFX_TAUNT,        SGB_SND_A_PUNCH_B,    $03            ; SCT_BREAK
IF REV_VER_2 == 0
.act1C: db SFX_PSYCTEL,      SGB_SND_A_SELECT_C,   $03            ; SCT_PSYCTEL
ELSE
.act1C: db SFX_FIREHIT_A,    SGB_SND_A_SELECT_C,   $03            ; SCT_PSYCTEL
ENDC
; =============== GFXS_XFlipTbl ===============
; Conversion table for CopyTilesHBlankFlipX.flipX.
; This maps every possible byte (an half-plane 1bpp line) of a GFX to its flipped version.
GFXS_XFlipTbl:
	db $00,$80,$40,$C0,$20,$A0,$60,$E0,$10,$90,$50,$D0,$30,$B0,$70,$F0 ; $00
	db $08,$88,$48,$C8,$28,$A8,$68,$E8,$18,$98,$58,$D8,$38,$B8,$78,$F8 ; $10
	db $04,$84,$44,$C4,$24,$A4,$64,$E4,$14,$94,$54,$D4,$34,$B4,$74,$F4 ; $20
	db $0C,$8C,$4C,$CC,$2C,$AC,$6C,$EC,$1C,$9C,$5C,$DC,$3C,$BC,$7C,$FC ; $30
	db $02,$82,$42,$C2,$22,$A2,$62,$E2,$12,$92,$52,$D2,$32,$B2,$72,$F2 ; $40
	db $0A,$8A,$4A,$CA,$2A,$AA,$6A,$EA,$1A,$9A,$5A,$DA,$3A,$BA,$7A,$FA ; $50
	db $06,$86,$46,$C6,$26,$A6,$66,$E6,$16,$96,$56,$D6,$36,$B6,$76,$F6 ; $60
	db $0E,$8E,$4E,$CE,$2E,$AE,$6E,$EE,$1E,$9E,$5E,$DE,$3E,$BE,$7E,$FE ; $70
	db $01,$81,$41,$C1,$21,$A1,$61,$E1,$11,$91,$51,$D1,$31,$B1,$71,$F1 ; $80
	db $09,$89,$49,$C9,$29,$A9,$69,$E9,$19,$99,$59,$D9,$39,$B9,$79,$F9 ; $90
	db $05,$85,$45,$C5,$25,$A5,$65,$E5,$15,$95,$55,$D5,$35,$B5,$75,$F5 ; $A0
	db $0D,$8D,$4D,$CD,$2D,$AD,$6D,$ED,$1D,$9D,$5D,$DD,$3D,$BD,$7D,$FD ; $B0
	db $03,$83,$43,$C3,$23,$A3,$63,$E3,$13,$93,$53,$D3,$33,$B3,$73,$F3 ; $C0
	db $0B,$8B,$4B,$CB,$2B,$AB,$6B,$EB,$1B,$9B,$5B,$DB,$3B,$BB,$7B,$FB ; $D0
	db $07,$87,$47,$C7,$27,$A7,$67,$E7,$17,$97,$57,$D7,$37,$B7,$77,$F7 ; $E0
	db $0F,$8F,$4F,$CF,$2F,$AF,$6F,$EF,$1F,$9F,$5F,$DF,$3F,$BF,$7F,$FF ; $F0

; =============== TextPrinter_CharsetToTileTbl ===============
; Maps the 8-bit character set used for strings in the ROM to tile IDs.
; The tile IDs correspond to the standard 1bpp font (FontDef_Default).
;
; Every possible character is accounted for, though most point to $00, the blank space.
; The table is also mostly unchanged between Japanese and English versions, because of
; the Katakana characters being placed in the lowercase ASCII slots.
; There are still entries for the Hirigana characters, unchanged from the Japanese version,
; but they won't display correctly since the font GFX got truncated.
TextPrinter_CharsetToTileTbl:
; [TCRF] These arrows are leftovers from KOF95, which told you the move inputs
;        of the unlockable characters
;          ; $ID ;U ;JP ;EN ; NOTES
IF REV_LANG_EN == 0
	db $30 ; $00 ;X ; ↑ ; ↓
	db $31 ; $01 ;X ; → ; ←
	db $32 ; $02 ;X ; ↓ 
	db $33 ; $03 ;X ; ← 
ELSE
	; $30 and $31 got overwritten by ( and )
	db $32 ; $00 ;X ; ↑ ; ↓
	db $33 ; $01 ;X ; → ; ←
	db $00 ; $02 ;X ; ↓ 
	db $00 ; $03 ;X ; ← 
ENDC
	db $00 ; $04 ;X ;
	db $00 ; $05 ;X ;
	db $00 ; $06 ;X ;
	db $00 ; $07 ;X ;
	db $00 ; $08 ;X ;
	db $00 ; $09 ;X ;
	db $00 ; $0A ;X ;
	db $00 ; $0B ;X ;
	db $00 ; $0C ;X ;
	db $00 ; $0D ;X ;
	db $00 ; $0E ;X ;
	db $00 ; $0F ;X ;
	db $00 ; $10 ;X ;
	db $00 ; $11 ;X ;
	db $00 ; $12 ;X ;
	db $00 ; $13 ;X ;
	db $00 ; $14 ;X ;
	db $00 ; $15 ;X ;
	db $00 ; $16 ;X ;
	db $00 ; $17 ;X ;
	db $00 ; $18 ;X ;
	db $00 ; $19 ;X ;
	db $00 ; $1A ;X ;
	db $00 ; $1B ;X ;
	db $00 ; $1C ;X ;
	db $00 ; $1D ;X ;
	db $00 ; $1E ;X ;
	db $00 ; $1F ;X ;
	db $00 ; $20    ; (space)
	db $2B ; $21    ; ! ; !
	db $2E ; $22 ;X ; " ; "
	db $00 ; $23 ;X ;
	db $00 ; $24 ;X ;
	db $00 ; $25 ;X ;
	db $00 ; $26 ;X ;
	db $1E ; $27 ;X ; '	; '
IF REV_LANG_EN == 0
	db $00 ; $28 ;X ;  	; (
	db $00 ; $29 ;X ;  	; )
ELSE
	db $30 ; $28 ;X ;  	; (
	db $31 ; $29 ;X ;  	; )
ENDC
	db $00 ; $2A ;X ;
	db $2F ; $2B ;X ; + ; +
	db $2D ; $2C    ; , ; ,
	db $29 ; $2D    ; - ; -
	db $1D ; $2E    ; . ; .
	db $00 ; $2F ;X ;
	db $1F ; $30    ; 0 ; 0
	db $20 ; $31    ; 1 ; 1
	db $21 ; $32    ; 2 ; 2
	db $22 ; $33    ; 3 ; 3
	db $23 ; $34 ;X ; 4 ; 4
	db $24 ; $35 ;X ; 5 ; 5
	db $25 ; $36 ;X ; 6 ; 6
	db $26 ; $37 ;X ; 7 ; 7
	db $27 ; $38    ; 8 ; 8
	db $28 ; $39    ; 9 ; 9
	db $2A ; $3A ;X ; : ; :
	db $00 ; $3B ;X ;
	db $00 ; $3C ;X ;
	db $00 ; $3D ;X ;
	db $00 ; $3E ;X ;
	db $2C ; $3F    ; ? ; ? 
	db $1C ; $40    ; r.; r.
	db $02 ; $41    ; A ; A
	db $03 ; $42    ; B ; B
	db $04 ; $43    ; C ; C
	db $05 ; $44    ; D ; D
	db $06 ; $45    ; E ; E
	db $07 ; $46    ; F ; F
	db $08 ; $47    ; G ; G
	db $09 ; $48    ; H ; H
	db $0A ; $49    ; I ; I
	db $0B ; $4A    ; J ; J
	db $0C ; $4B    ; K ; K
	db $0D ; $4C    ; L ; L
	db $0E ; $4D    ; M ; M
	db $0F ; $4E    ; N ; N
	db $10 ; $4F    ; O ; O
	db $11 ; $50    ; P ; P
	db $12 ; $51 ;X ; Q ; Q
	db $13 ; $52    ; R ; R
	db $14 ; $53    ; S ; S
	db $15 ; $54    ; T ; T
	db $16 ; $55    ; U ; U
	db $17 ; $56    ; V ; V
	db $18 ; $57    ; W ; W
	db $19 ; $58    ; X ; X
	db $1A ; $59    ; Y ; Y
	db $1B ; $5A    ; Z ; Z
	db $00 ; $5B ;X ;
	db $00 ; $5C ;X ;
	db $00 ; $5D ;X ;
	db $00 ; $5E ;X ;
	db $00 ; $5F ;X ;
	db $1E ; $60    ; `	; ` ; Points to same tile as '
	db $34 ; $61 ;X ; ッ	; a
	db $35 ; $62 ;X ; ア	; b
	db $36 ; $63    ; オ	; c
	db $37 ; $64 ;X ; カ	; d
	db $38 ; $65    ; コ	; e
	db $39 ; $66 ;X ; シ	; f
	db $3A ; $67    ; チ	; g
	db $3B ; $68 ;X ; テ	; h
	db $3C ; $69    ; ト	; i
	db $3D ; $6A    ; ナ	; j
	db $3E ; $6B ;X ; ハ	; k
	db $3F ; $6C    ; ヒ	; l
	db $40 ; $6D ;X ; フ	; m
	db $41 ; $6E    ; メ	; n
	db $42 ; $6F    ; ロ	; o
	db $43 ; $70 ;X ; ワ	; p
	db $44 ; $71    ; ン	; q
	db $45 ; $72    ; ホ	; r
	db $46 ; $73    ; タ	; s
	db $47 ; $74 ;X ; 。	; t ; Duplicate in JP
	db $48 ; $75 ;X ; 、	; u ; Duplicate in JP
	db $49 ; $76 ;X ; ゜	; v ; Duplicate in JP
	db $4A ; $77 ;X ; ﾞ	; w ; Duplicate in JP
	db $4B ; $78 ;X ; ・	; x ; Duplicate in JP
	db $4C ; $79 ;X ; を	; y ; Duplicate in JP
	db $4D ; $7A ;X ; ぁ	; z ; Duplicate in JP
	db $00 ; $7B ;X ;
	db $00 ; $7C ;X ;
	db $00 ; $7D ;X ;
	db $00 ; $7E ;X ;
	db $00 ; $7F ;X ;
	db $00 ; $80 ;X ;
	db $00 ; $81 ;X ;
	db $00 ; $82 ;X ;
	db $00 ; $83 ;X ;
	db $00 ; $84 ;X ;
	db $00 ; $85 ;X ;
	db $00 ; $86 ;X ;
	db $00 ; $87 ;X ;
	db $00 ; $88 ;X ;
	db $00 ; $89 ;X ;
	db $00 ; $8A ;X ;
	db $00 ; $8B ;X ;
	db $00 ; $8C ;X ;
	db $00 ; $8D ;X ;
	db $00 ; $8E ;X ;
	db $00 ; $8F ;X ;
	db $00 ; $90 ;X ;
	db $00 ; $91 ;X ;
	db $00 ; $92 ;X ;
	db $00 ; $93 ;X ;
	db $00 ; $94 ;X ;
	db $00 ; $95 ;X ;
	db $00 ; $96 ;X ;
	db $00 ; $97 ;X ;
	db $00 ; $98 ;X ;
	db $00 ; $99 ;X ;
	db $00 ; $9A ;X ;
	db $00 ; $9B ;X ;
	db $00 ; $9C ;X ;
	db $00 ; $9D ;X ;
	db $00 ; $9E ;X ;
	db $00 ; $9F ;X ;
	db $00 ; $A0 ;X ;
	db $47 ; $A1    ; 。
	db $00 ; $A2 ;X ;
	db $00 ; $A3 ;X ;
	db $48 ; $A4    ; 、
	db $4B ; $A5    ; ・
	db $4C ; $A6    ; を
	db $4D ; $A7 ;X ; ぁ
	db $4E ; $A8    ; ぃ
	db $00 ; $A9 ;X ;
	db $00 ; $AA ;X ;
	db $00 ; $AB ;X ;
	db $4F ; $AC    ; ゃ
	db $50 ; $AD    ; ゅ
	db $51 ; $AE    ; ょ
	db $52 ; $AF    ; っ 
	db $29 ; $B0    ; ｰ	;   ; Reuses "-" symbol to save space
	db $53 ; $B1    ; あ
	db $54 ; $B2    ; い
	db $55 ; $B3    ; う
	db $56 ; $B4    ; え
	db $57 ; $B5    ; お
	db $58 ; $B6    ; か
	db $59 ; $B7    ; き
	db $5A ; $B8    ; く
	db $5B ; $B9    ; け
	db $5C ; $BA    ; こ
	db $5D ; $BB    ; さ
	db $5E ; $BC    ; し
	db $5F ; $BD    ; す
	db $60 ; $BE    ; せ
	db $61 ; $BF    ; そ
	db $62 ; $C0    ; た
	db $63 ; $C1    ; ち
	db $64 ; $C2    ; つ
	db $65 ; $C3    ; て
	db $66 ; $C4    ; と
	db $67 ; $C5    ; な
	db $68 ; $C6    ; に
	db $69 ; $C7    ; ぬ
	db $6A ; $C8    ; ね
	db $6B ; $C9    ; の
	db $6C ; $CA    ; は
	db $6D ; $CB    ; ひ
	db $6E ; $CC    ; ふ
	db $6F ; $CD    ; へ
	db $70 ; $CE    ; ほ
	db $71 ; $CF    ; ま
	db $72 ; $D0    ; み
	db $73 ; $D1    ; む
	db $74 ; $D2    ; め
	db $75 ; $D3    ; も
	db $76 ; $D4    ; や
	db $77 ; $D5    ; ゆ
	db $78 ; $D6    ; よ
	db $79 ; $D7    ; ら
	db $7A ; $D8    ; リ
	db $7B ; $D9    ; る
	db $7C ; $DA    ; れ
	db $7D ; $DB    ; ろ
	db $7E ; $DC    ; わ
	db $7F ; $DD    ; ん
	db $4A ; $DE    ; ﾞ
	db $49 ; $DF    ; ﾟ
	db $00 ; $E0 ;X ;
	db $00 ; $E1 ;X ;
	db $00 ; $E2 ;X ;
	db $00 ; $E3 ;X ;
	db $00 ; $E4 ;X ;
	db $00 ; $E5 ;X ;
	db $00 ; $E6 ;X ;
	db $00 ; $E7 ;X ;
	db $00 ; $E8 ;X ;
	db $00 ; $E9 ;X ;
	db $00 ; $EA ;X ;
	db $00 ; $EB ;X ;
	db $00 ; $EC ;X ;
	db $00 ; $ED ;X ;
	db $00 ; $EE ;X ;
	db $00 ; $EF ;X ;
	db $00 ; $F0 ;X ;
	db $00 ; $F1 ;X ;
	db $00 ; $F2 ;X ;
	db $00 ; $F3 ;X ;
	db $00 ; $F4 ;X ;
	db $00 ; $F5 ;X ;
	db $00 ; $F6 ;X ;
	db $00 ; $F7 ;X ;
	db $00 ; $F8 ;X ;
	db $00 ; $F9 ;X ;
	db $00 ; $FA ;X ;
	db $00 ; $FB ;X ;
	db $00 ; $FC ;X ;
	db $00 ; $FD ;X ;
	db $00 ; $FE ;X ;
	db $00 ; $FF ;X ;
; =============== TextPrinter_DigitToTileTbl ===============
; Maps the number digits to tile IDs.
; The tile IDs correspond to the standard 1bpp font (FontDef_Default).
TextPrinter_DigitToTileTbl:
	db $1F
	db $20
	db $21
	db $22
	db $23
	db $24
	db $25
	db $26
	db $27
	db $28
	db $02
	db $03
	db $04
	db $05
	db $06
	db $07
; =============== END OF BANK ===============
; Null padding below.
	mIncJunk "L1F7FEC"