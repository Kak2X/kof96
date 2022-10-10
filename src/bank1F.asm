; =============== Sound_Do ===============
; Entry point of the main sound code.
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
	xor  a							; ???
	ld   [wSnd_Unused_ChUsed], a
	push bc
	call Sound_StopAll
	pop  bc
	ld   de, wBGMCh1Info
	jp   Sound_InitSongFromHeader
	
; =============== Sound_PauseAll ===============
; Handles the sound pause command during gameplay.
Sound_PauseAll:
	call Sound_PauseChPlayback
	; Kill any remaining sound effect channels (???)
	jr   Sound_StartNewSFX1234
	
; =============== Sound_UnpauseAll ===============
; Handles the sound unpause command during gameplay.
Sound_UnpauseAll:
	call Sound_UnpauseChPlayback
	; Kill any remaining sound effect channels (???)
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
	
; =============== Sound_StartNewSFX1234IfChNotUsed ===============
; [TCRF] Unreferenced code.
Sound_StartNewSFX1234IfChNotUsed:
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
	; [TCRF?] Bit never set
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
	; [TCRF?] Bit never set
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
	ld   a, $80			; ???
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
	; [POI] Unreachable?
	dec  [hl]				; Subtract high byte
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
; [TCRF] Unused subroutine ???
;        Writes to otherwise unused SndInfo field.
Sound_Cmd_Unknown_Unused_SetStat6:
	; Set status flag 6
	ld   a, [de]
	set  SISB_UNK_UNUSED_6, a
	ld   [de], a
	
	; Write $00 to byte9
	ld   hl, iSndInfo_Unknown_Unused_9
	add  hl, de
	ld   [hl], $00
	
	; Don't increase data ptr
	jp   Sound_DecDataPtr
	
; =============== Sound_Cmd_Unknown_Unused_ClrStat6 ===============
; [TCRF] Unused subroutine ???
Sound_Cmd_Unknown_Unused_ClrStat6:
	; Clear status flag 6
	ld   a, [de]
	res  SISB_UNK_UNUSED_6, a
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
; [TCRF] Unused ???
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
	call Sound_IndexPtrTable				; HL = ??? Ptr
	
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
	call Sound_IndexPtrTable
	
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
; [TCRF] Unused?
Sound_Cmd_Unused_EndChFlagBF:
	ld   a, [wSnd_Unused_ChUsed]
	and  a, $BF
	ld   [wSnd_Unused_ChUsed], a
	jr   Sound_Cmd_EndCh
	
; =============== Sound_Cmd_Unused_EndChFlag7F ===============
; [TCRF] Unused?
Sound_Cmd_Unused_EndChFlag7F:
	ld   a, [wSnd_Unused_ChUsed]
	and  a, $7F
	ld   [wSnd_Unused_ChUsed], a
	
; =============== Sound_Cmd_EndCh ===============
; Called to permanently stop channel playback (ie: the song/sfx ended and didn't loop).
; This either stops the sound channel
Sound_Cmd_EndCh:
	
	; This may not happen when handling BGM SndInfo.
	call Sound_SilenceCh
	
	; HL = SndInfo base
	ldh  a, [hSndInfoCurPtr_Low]
	ld   l, a
	ldh  a, [hSndInfoCurPtr_High]
	ld   h, a
	
	;
	; Check if a BGM is currently playing.
	; If not, just mute the channel and disable this SndInfo. 
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
	; (just like Sound_SilenceCh. ??? is this here just in case Sound_SilenceCh doesn't mute playback?)
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
	
	ld   a, $80			; ???
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
	dw SndHeader_BGM_Roulette;X
	dw SndHeader_BGM_Roulette
	dw SndHeader_BGM_StageClear
	dw SndHeader_BGM_BigShot
	dw SndHeader_BGM_Esaka
	dw SndHeader_BGM_RisingRed
	dw SndHeader_BGM_Geese
	dw SndHeader_BGM_Arashi
	dw SndHeader_BGM_Fairy
	dw SndHeader_BGM_TrashHead
	dw SndHeader_BGM_Wind
	dw SndHeader_BGM_ToTheSky
	dw SndHeader_Pause
	dw SndHeader_Unpause
	dw SndHeader_SFX_CharCursorMove
	dw SndHeader_SFX_CharSelected
	dw SndHeader_SFX_MeterCharge
	dw SndHeader_SFX_SuperMove
	dw SndHeader_SFX_Light
	dw SndHeader_SFX_Heavy
	dw SndHeader_SFX_Unknown_Block
	dw SndHeader_SFX_Taunt
	dw SndHeader_SFX_Hit
	dw SndHeader_SFX_Unknown_Hit1
	dw SndHeader_BGM_Protector
	dw SndHeader_BGM_MrKarate
	dw SndHeader_SFX_Unknown_SuperFireHit
	dw SndHeader_SFX_Drop
	dw SndHeader_SFX_SuperJump
	dw SndHeader_SFX_Step
	dw SndHeader_BGM_In1996
	dw SndHeader_BGM_MrKarateCutscene
	dw Sound_StartNothing;X
	dw Sound_StartNothing;X
	dw Sound_StartNothing;X
	dw Sound_StartNothing;X
	dw Sound_StartNothing;X
	dw Sound_StartNothing;X
	dw SndHeader_SFX_Unknown_Hit2
	dw SndHeader_SFX_GrabStart
	dw SndHeader_SFX_Unknown_Fire2
	dw SndHeader_SFX_FireSmall
	dw SndHeader_SFX_Unknown_Fire4
	dw SndHeader_SFX_FireLarge
	dw SndHeader_SFX_Unknown_Fire3
	dw SndHeader_SFX_Unknown_Wind
	dw SndHeader_SFX_Unknown_Alarm
	dw SndHeader_SFX_Unknown_Null
	dw SndHeader_SFX_Unknown_SpecialMove
	dw SndHeader_SFX_GameOver
	dw Sound_StartNothing;X
	dw Sound_StartNothing;X

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

SndHeader_SFX_CharCursorMove:
	db $01 ; Number of channels
.ch2:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_SFX_CharCursorMove_Ch2 ; Data ptr
	db $0C ; Base freq/note id
	db $81 ; Unused
SndData_SFX_CharCursorMove_Ch2:
	sndenv 12, SNDENV_DEC, 3
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 3, 0
	sndnote $22
	sndlen 2
	sndnote $25
	sndnote $29
	sndnote $2C
	sndenv 7, SNDENV_DEC, 3
	sndnote $22
	sndnote $25
	sndnote $29
	sndnote $2C
	sndenv 4, SNDENV_DEC, 3
	sndnote $22
	sndnote $25
	sndnote $29
	sndnote $2C
	sndenv 2, SNDENV_DEC, 3
	sndnote $22
	sndnote $25
	sndnote $29
	sndnote $2C
	sndendch
SndHeader_SFX_CharSelected:
	db $01 ; Number of channels
.ch2:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_SFX_CharSelected_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_CharSelected_Ch2:
	sndenv 15, SNDENV_DEC, 2
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 3, 0
	sndnote $1D
	sndlen 2
	sndnote $25
	sndnote $20
	sndnote $29
	sndnote $25
	sndnote $2C
	sndnote $29
	sndnote $31
	sndenv 9, SNDENV_DEC, 2
	sndnote $1D
	sndlen 2
	sndnote $25
	sndnote $20
	sndnote $29
	sndnote $25
	sndnote $2C
	sndnote $29
	sndnote $31
	sndenv 5, SNDENV_DEC, 2
	sndnote $1D
	sndlen 2
	sndnote $25
	sndnote $20
	sndnote $29
	sndnote $25
	sndnote $2C
	sndnote $29
	sndnote $31
	sndenv 2, SNDENV_DEC, 2
	sndnote $1D
	sndlen 2
	sndnote $25
	sndnote $20
	sndnote $29
	sndnote $25
	sndnote $2C
	sndnote $29
	sndnote $31
	sndendch
SndHeader_SFX_MeterCharge:
	db $01 ; Number of channels
.ch2:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_SFX_MeterCharge_Ch2 ; Data ptr
	db $0C ; Base freq/note id
	db $81 ; Unused
SndData_SFX_MeterCharge_Ch2:
	sndenv 6, SNDENV_INC, 2
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 0, 0
	sndcall .playSet
	sndnotebase $01
	sndcall .playSet
	sndnotebase $01
	sndcall .playSet
	sndnotebase $01
	sndcall .playSet
	sndnotebase $01
	sndcall .playSet
	sndnotebase $01
	sndcall .playSet
	sndnotebase $01
	sndcall .playSet
	sndnotebase $01
	sndcall .playSet
	sndnotebase $01
	sndcall .playSet
	sndnotebase $01
	sndcall .playSet
	sndnotebase $01
	sndcall .playSet
	sndnotebase $01
	sndcall .playSet
	sndnotebase $01
	sndcall .playSet
	sndendch
.playSet:
	sndnote $25
	sndlen 1
	sndnote $26
	sndnote $27
	sndnote $26
	sndloopcnt $00, 2, .playSet
	sndret
SndHeader_SFX_SuperMove:
	db $03 ; Number of channels
.ch2:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_SFX_SuperMove_Ch2 ; Data ptr
	db $0C ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_SFX_SuperMove_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_SuperMove_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_SuperMove_Ch2:
	sndenv 9, SNDENV_DEC, 4
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 1, 0
	sndnote $00
	sndlen 6
	sndnote $22
	sndlen 2
	sndnote $2E
	sndlen 6
	sndenv 7, SNDENV_DEC, 7
	sndnote $22
	sndlen 1
	sndnote $2E
	sndlen 5
	sndenv 5, SNDENV_DEC, 7
	sndnote $22
	sndlen 1
	sndnote $2E
	sndlen 5
	sndenv 3, SNDENV_DEC, 7
	sndnote $22
	sndlen 1
	sndnote $2E
	sndlen 5
	sndenv 2, SNDENV_DEC, 7
	sndnote $22
	sndlen 1
	sndnote $2E
	sndlen 29
	sndendch
SndData_SFX_SuperMove_Ch3:
	sndenvch3 2
	sndendch
SndData_SFX_SuperMove_Ch4:
	sndenv 15, SNDENV_DEC, 2
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndch4 7, 0, 1
	sndlen 6
	sndendch
SndHeader_SFX_Light:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_Light_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_Light_Ch4:
	sndenv 7, SNDENV_INC, 1
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndch4 3, 0, 7
	sndlen 1
	sndsetskip
	sndch4 3, 0, 6
	sndlen 1
	sndch4 3, 0, 5
	sndlen 1
	sndch4 3, 0, 4
	sndlen 1
	sndch4 3, 0, 3
	sndlen 1
	sndch4 3, 0, 2
	sndlen 1
	sndch4 3, 0, 1
	sndlen 1
	sndch4 3, 0, 0
	sndlen 1
	sndclrskip
	sndendch
SndHeader_SFX_Heavy:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_Heavy_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_Heavy_Ch4:
	sndenv 3, SNDENV_INC, 1
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndch4 4, 0, 7
	sndlen 2
	sndsetskip
	sndch4 4, 0, 6
	sndlen 2
	sndch4 4, 0, 5
	sndlen 2
	sndch4 4, 0, 4
	sndlen 2
	sndch4 4, 0, 3
	sndlen 2
	sndch4 4, 0, 2
	sndlen 2
	sndch4 4, 0, 1
	sndlen 2
	sndch4 4, 0, 0
	sndlen 2
	sndclrskip
	sndendch
SndHeader_SFX_Unknown_Block:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_Unknown_Block_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_Unknown_Block_Ch4:
	sndenv 15, SNDENV_DEC, 7
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndch4 3, 0, 7
	sndlen 1
	sndch4 4, 0, 5
	sndlen 1
	sndch4 3, 0, 7
	sndlen 1
	sndsetskip
	sndch4 2, 0, 4
	sndlen 1
	sndch4 5, 0, 5
	sndlen 1
	sndendch
SndHeader_SFX_Taunt:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_Taunt_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_Taunt_Ch4:
	sndenv 11, SNDENV_DEC, 7
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndch4 2, 0, 7
	sndlen 2
	sndch4 4, 0, 5
	sndlen 2
	sndch4 1, 0, 7
	sndlen 2
	sndsetskip
	sndch4 1, 0, 4
	sndlen 2
	sndch4 1, 0, 7
	sndlen 2
	sndclrskip
	sndendch
SndHeader_SFX_Hit:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_Hit_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_Hit_Ch4:
	sndenv 15, SNDENV_DEC, 2
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndch4 7, 0, 1
	sndlen 5
	sndch4 0, 0, 0
	sndlen 1
	sndch4 3, 0, 5
	sndlen 6
	sndendch
SndHeader_SFX_Unknown_Hit1:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_Unknown_Hit1_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_Unknown_Hit1_Ch4:
	sndenv 15, SNDENV_DEC, 2
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndch4 4, 0, 0
	sndlen 1
	sndsetskip
	sndch4 4, 0, 1
	sndlen 1
	sndch4 4, 0, 2
	sndlen 1
	sndch4 4, 0, 3
	sndlen 1
	sndch4 4, 0, 4
	sndlen 1
	sndch4 4, 0, 5
	sndlen 1
	sndch4 4, 0, 6
	sndlen 1
	sndch4 4, 0, 7
	sndlen 1
	sndclrskip
	sndch4 3, 0, 5
	sndlen 1
	sndsetskip
	sndch4 3, 0, 4
	sndlen 1
	sndch4 3, 0, 3
	sndlen 1
	sndch4 3, 0, 2
	sndlen 1
	sndch4 3, 0, 1
	sndlen 1
	sndch4 3, 0, 0
	sndendch
SndHeader_SFX_Unknown_SuperFireHit:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_Unknown_SuperFireHit_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_Unknown_SuperFireHit_Ch4:
	sndenv 15, SNDENV_DEC, 7
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndch4 4, 0, 5
	sndlen 2
	sndch4 2, 0, 7
	sndlen 3
	sndch4 3, 0, 5
	sndlen 2
	sndch4 2, 0, 7
	sndlen 2
	sndch4 3, 0, 4
	sndlen 8
	sndch4 7, 0, 1
	sndlen 2
	sndch4 5, 0, 4
	sndlen 2
	sndch4 4, 0, 7
	sndlen 2
	sndch4 6, 0, 4
	sndlen 10
	sndch4 7, 0, 1
	sndlen 100
	sndendch
SndHeader_SFX_Drop:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_Drop_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_Drop_Ch4:
	sndenv 15, SNDENV_DEC, 3
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndch4 3, 0, 6
	sndlen 2
	sndch4 7, 0, 2
	sndlen 2
	sndch4 3, 0, 6
	sndlen 3
	sndch4 5, 0, 7
	sndlen 10
	sndendch
SndHeader_SFX_SuperJump:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_SuperJump_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_SuperJump_Ch4:
	sndenv 2, SNDENV_INC, 1
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndch4 3, 0, 0
	sndlen 2
	sndsetskip
	sndch4 3, 0, 1
	sndlen 2
	sndch4 3, 0, 2
	sndlen 2
	sndch4 3, 0, 3
	sndlen 2
	sndch4 3, 0, 4
	sndlen 2
	sndch4 3, 0, 5
	sndlen 2
	sndch4 3, 0, 6
	sndlen 2
	sndch4 3, 0, 7
	sndlen 2
	sndch4 3, 0, 6
	sndlen 2
	sndch4 3, 0, 5
	sndlen 2
	sndch4 3, 0, 4
	sndlen 2
	sndch4 3, 0, 3
	sndlen 2
	sndch4 3, 0, 2
	sndlen 2
	sndch4 3, 0, 1
	sndlen 2
	sndch4 3, 0, 0
	sndlen 2
	sndendch
SndHeader_SFX_Step:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_Step_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_Step_Ch4:
	sndenv 15, SNDENV_DEC, 7
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndch4 4, 0, 7
	sndlen 1
	sndch4 5, 0, 5
	sndlen 1
	sndch4 0, 0, 0
	sndlen 1
	sndch4 4, 0, 7
	sndlen 1
	sndsetskip
	sndch4 3, 0, 4
	sndlen 1
	sndch4 5, 0, 5
	sndlen 1
	sndendch
SndHeader_SFX_Unknown_Hit2:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_Unknown_Hit2_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_Unknown_Hit2_Ch4:
	sndenv 10, SNDENV_DEC, 1
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndch4 5, 0, 1
	sndlen 2
	sndch4 4, 0, 5
	sndlen 2
	sndch4 0, 0, 0
	sndlen 2
	sndch4 4, 0, 1
	sndlen 2
	sndch4 2, 0, 7
	sndlen 2
	sndch4 0, 1, 0
	sndlen 1
	sndch4 0, 0, 0
	sndlen 1
	sndendch
SndHeader_SFX_GrabStart:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_GrabStart_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_GrabStart_Ch4:
	sndenv 15, SNDENV_DEC, 2
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndch4 6, 0, 1
	sndlen 3
	sndch4 0, 0, 0
	sndlen 1
	sndch4 2, 0, 5
	sndlen 4
	sndendch
SndHeader_SFX_Unknown_Fire2:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_Unknown_Fire2_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_Unknown_Fire2_Ch4:
	sndenv 15, SNDENV_DEC, 7
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndch4 4, 0, 5
	sndlen 1
	sndsetskip
	sndch4 5, 0, 5
	sndlen 2
	sndch4 4, 0, 7
	sndlen 2
	sndch4 4, 0, 6
	sndlen 2
	sndch4 4, 0, 5
	sndlen 2
	sndch4 4, 0, 4
	sndlen 2
	sndch4 4, 0, 3
	sndlen 2
	sndch4 4, 0, 2
	sndlen 2
	sndch4 4, 0, 1
	sndlen 1
	sndch4 4, 0, 0
	sndlen 1
	sndclrskip
	sndenv 15, SNDENV_DEC, 2
	sndch4 3, 0, 2
	sndlen 30
	sndendch
SndHeader_SFX_FireSmall:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_FireSmall_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_FireSmall_Ch4:
	sndenv 3, SNDENV_INC, 3
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndch4 5, 0, 5
	sndlen 70
	sndendch
SndHeader_SFX_Unknown_Fire4:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_Unknown_Fire4_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_Unknown_Fire4_Ch4:
	sndenv 10, SNDENV_INC, 1
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndch4 3, 0, 1
	sndlen 3
	sndsetskip
	sndch4 3, 0, 2
	sndlen 3
	sndch4 3, 0, 3
	sndlen 3
	sndch4 3, 0, 4
	sndlen 3
	sndch4 3, 0, 5
	sndlen 3
	sndch4 3, 0, 6
	sndlen 3
	sndch4 3, 0, 7
	sndlen 3
	sndch4 4, 0, 3
	sndlen 3
	sndch4 4, 0, 4
	sndlen 3
	sndch4 4, 0, 5
	sndlen 3
	sndch4 4, 0, 6
	sndlen 3
	sndch4 4, 0, 7
	sndlen 3
	sndclrskip
	sndendch
SndHeader_SFX_FireLarge:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_FireLarge_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_FireLarge_Ch4:
	sndenv 10, SNDENV_INC, 1
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndch4 5, 0, 7
	sndlen 2
	sndsetskip
	sndch4 5, 0, 6
	sndlen 2
	sndch4 5, 0, 5
	sndlen 2
	sndch4 5, 0, 4
	sndlen 2
	sndch4 5, 0, 3
	sndlen 2
	sndch4 4, 0, 7
	sndlen 2
	sndch4 4, 0, 6
	sndlen 2
	sndch4 4, 0, 5
	sndlen 2
	sndch4 4, 0, 4
	sndlen 2
	sndch4 4, 0, 3
	sndlen 2
	sndch4 4, 0, 2
	sndlen 2
	sndch4 4, 0, 1
	sndlen 2
	sndclrskip
	sndenv 15, SNDENV_DEC, 1
	sndch4 2, 0, 7
	sndlen 1
	sndch4 2, 0, 6
	sndlen 1
	sndch4 2, 0, 5
	sndlen 1
	sndch4 2, 0, 4
	sndlen 1
	sndch4 2, 0, 3
	sndlen 1
	sndch4 2, 0, 2
	sndlen 1
	sndch4 2, 0, 1
	sndlen 1
	sndch4 2, 0, 0
	sndlen 1
	sndch4 2, 0, 1
	sndlen 1
	sndch4 2, 0, 2
	sndlen 1
	sndch4 2, 0, 3
	sndlen 1
	sndch4 2, 0, 4
	sndlen 1
	sndch4 2, 0, 5
	sndlen 1
	sndch4 2, 0, 6
	sndlen 1
	sndch4 2, 0, 7
	sndlen 1
	sndch4 3, 0, 1
	sndlen 1
	sndch4 3, 0, 2
	sndlen 1
	sndch4 3, 0, 3
	sndlen 1
	sndch4 3, 0, 4
	sndlen 1
	sndch4 3, 0, 5
	sndlen 1
	sndch4 3, 0, 6
	sndlen 1
	sndch4 3, 0, 7
	sndlen 1
	sndendch
SndHeader_SFX_Unknown_Fire3:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_Unknown_Fire3_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_Unknown_Fire3_Ch4:
	sndenv 15, SNDENV_DEC, 3
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndch4 7, 0, 1
	sndlen 2
	sndch4 5, 0, 4
	sndlen 2
	sndch4 3, 0, 4
	sndlen 2
	sndch4 5, 0, 4
	sndlen 2
	sndch4 3, 0, 4
	sndlen 5
	sndch4 7, 0, 1
	sndlen 30
	sndendch
SndHeader_SFX_Unknown_Wind:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_Unknown_Wind_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_Unknown_Wind_Ch4:
	sndenv 10, SNDENV_DEC, 7
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndch4 4, 0, 1
	sndlen 1
	sndsetskip
	sndch4 4, 0, 1
	sndlen 1
	sndch4 4, 0, 1
	sndlen 1
	sndch4 3, 1, 1
	sndlen 1
	sndch4 3, 1, 0
	sndlen 1
	sndch4 3, 0, 7
	sndlen 1
	sndch4 3, 0, 6
	sndlen 1
	sndch4 3, 0, 5
	sndlen 1
	sndclrskip
	sndch4 4, 0, 1
	sndlen 1
	sndsetskip
	sndch4 4, 0, 1
	sndlen 1
	sndch4 4, 0, 1
	sndlen 1
	sndch4 3, 1, 1
	sndlen 1
	sndch4 3, 1, 0
	sndlen 1
	sndch4 3, 0, 7
	sndlen 1
	sndch4 3, 0, 6
	sndlen 1
	sndch4 3, 0, 5
	sndlen 1
	sndclrskip
	sndloopcnt $00, 3, SndData_SFX_Unknown_Wind_Ch4
	sndendch
SndHeader_SFX_Unknown_Alarm:
	db $01 ; Number of channels
.ch2:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_SFX_Unknown_Alarm_Ch2 ; Data ptr
	db $06 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_Unknown_Alarm_Ch2:
	sndenv 0, SNDENV_INC, 7
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 3, 0
	sndnote $0F
	sndlen 1
	sndsetskip
	sndnote $11
	sndnote $12
	sndnote $14
	sndnote $16
	sndnote $18
	sndnote $19
	sndnote $1B
	sndnote $1D
	sndnote $1E
	sndnote $20
	sndnote $22
	sndnote $24
	sndnote $25
	sndnote $27
	sndloop SndData_SFX_Unknown_Alarm_Ch2
SndHeader_SFX_Unknown_Null:
	db $01 ; Number of channels
.ch2:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_SFX_Unknown_Null_Ch2 ; Data ptr
	db $06 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_Unknown_Null_Ch2:
	sndendch
SndHeader_SFX_Unknown_SpecialMove:
	db $01 ; Number of channels
.ch2:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_SFX_Unknown_SpecialMove_Ch2 ; Data ptr
	db $0C ; Base freq/note id
	db $81 ; Unused
SndData_SFX_Unknown_SpecialMove_Ch2:
	sndenv 1, SNDENV_INC, 4
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 3, 0
	sndnote $2E
	sndlen 1
	sndsetskip
	sndnote $2F
	sndloopcnt $00, 30, SndData_SFX_Unknown_SpecialMove_Ch2
	sndendch
SndHeader_SFX_GameOver:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_GameOver_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_GameOver_Ch4:
	sndenv 1, SNDENV_INC, 3
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndch4 2, 0, 7
	sndlen 10
	sndsetskip
	sndch4 2, 0, 6
	sndlen 10
	sndch4 2, 0, 5
	sndlen 10
	sndch4 2, 0, 4
	sndlen 10
	sndch4 2, 0, 3
	sndlen 10
	sndch4 2, 0, 2
	sndlen 10
	sndendch
SndHeader_Pause:
	db $03 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_PauseUnpause_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_PauseUnpause_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_PauseUnpause_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
	
SndHeader_Unpause:
	db $03 ; Number of channels
.ch1:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_PauseUnpause_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_PauseUnpause_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_PauseUnpause_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_PauseUnpause_Ch1:
	sndenach SNDOUT_CH1R|SNDOUT_CH1L
	sndnr11 2, 0
	sndenv 0, SNDENV_DEC, 0
	sndendch
SndData_PauseUnpause_Ch2:
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 2, 0
	sndenv 0, SNDENV_DEC, 0
	sndendch
SndData_PauseUnpause_Ch3:
	sndenach SNDOUT_CH3R|SNDOUT_CH3L
	sndenvch3 0
	sndendch
SndHeader_BGM_Geese:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_Geese_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_Geese_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_Geese_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_Geese_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_BGM_Geese_Ch1:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH1R|SNDOUT_CH1L
	sndnr11 3, 0
	sndcall .intro
.main:
	sndcall .call1
	sndcall .call2
	sndcall .call3
	sndcall .call2
	sndcall .call4
	sndcall .call5
	sndcall .call6
	sndcall .call7
	sndcall .call6
	sndcall .call8
	sndloop .main
.intro:
	sndnote $14
	sndlen 60
	sndnote $00
	sndlen 10
	sndnote $14
	sndnote $00
	sndnote $14
	sndnote $14
	sndlen 20
	sndnote $0D
	sndnote $0F
	sndloopcnt $00, 2, .intro
	sndret
.call1:
	sndenv 7, SNDENV_DEC, 7
	sndnote $14
	sndlen 60
	sndnote $00
	sndlen 10
	sndnote $14
	sndnote $00
	sndnote $14
	sndnote $14
	sndlen 20
	sndnote $0D
	sndnote $0F
	sndnote $14
	sndlen 60
	sndnote $00
	sndlen 10
	sndnote $17
	sndnote $00
	sndnote $17
	sndnote $17
	sndlen 20
	sndnote $19
	sndnote $1B
	sndret
.call2:
	sndenv 7, SNDENV_INC, 0
	sndnote $23
	sndlen 30
	sndnote $22
	sndnote $1E
	sndlen 5
	sndnote $00
	sndnote $1C
	sndlen 40
	sndlenpre $0A
	sndnote $1C
	sndnote $1E
	sndnote $20
	sndlen 20
	sndnote $1E
	sndlen 30
	sndnote $20
	sndnote $1C
	sndlen 20
	sndlenpre $50
	sndret
.call3:
	sndnote $23
	sndlen 30
	sndnote $22
	sndnote $1E
	sndlen 20
	sndnote $1C
	sndlen 30
	sndnote $22
	sndnote $1E
	sndlen 10
	sndnote $25
	sndlenpre $1E
	sndnote $24
	sndnote $20
	sndlen 20
	sndlenpre $50
	sndret
.call4:
	sndnote $1B
	sndlen 30
	sndnote $1C
	sndnote $1E
	sndlen 10
	sndnote $20
	sndlenpre $14
	sndnote $00
	sndnote $25
	sndlen 13
	sndnote $24
	sndlen 14
	sndnote $20
	sndlen 13
	sndnote $23
	sndlen 20
	sndnote $00
	sndlen 10
	sndnote $22
	sndlen 30
	sndnote $1E
	sndlen 10
	sndnote $20
	sndlenpre $50
	sndret
.call5:
	sndnr11 2, 0
	sndnote $15
	sndlen 60
	sndnote $1C
	sndlen 20
	sndnote $1B
	sndnote $19
	sndnote $17
	sndnote $19
	sndnote $18
	sndlen 60
	sndnote $20
	sndlen 20
	sndnote $1E
	sndnote $1C
	sndnote $1B
	sndnote $19
	sndnote $1C
	sndlen 60
	sndnote $1B
	sndlen 20
	sndnote $1E
	sndlen 13
	sndnote $24
	sndlen 14
	sndnote $25
	sndlen 13
	sndnote $24
	sndnote $21
	sndlen 14
	sndnote $20
	sndlen 13
	sndnote $24
	sndlen 80
	sndnote $25
	sndlen 30
	sndnote $27
	sndlen 40
	sndlenpre $0A
	sndret
.call6:
	sndnr11 3, 0
	sndnote $19
	sndlen 13
	sndnote $1C
	sndlen 14
	sndnote $20
	sndlen 13
	sndnote $22
	sndnote $23
	sndlen 14
	sndnote $25
	sndlen 13
	sndnote $22
	sndlen 80
	sndret
.call7:
	sndnote $21
	sndlen 13
	sndnote $1C
	sndlen 14
	sndnote $1B
	sndlen 13
	sndnote $19
	sndnote $1B
	sndlen 14
	sndnote $20
	sndlen 13
	sndlenpre $50
	sndret
.call8:
	sndnote $21
	sndlen 13
	sndnote $20
	sndlen 14
	sndnote $23
	sndlen 13
	sndnote $21
	sndnote $27
	sndlen 14
	sndnote $28
	sndlen 13
	sndlenpre $50
	sndnote $27
	sndlen 20
	sndnote $20
	sndlen 5
	sndnote $00
	sndnote $28
	sndlen 20
	sndnote $21
	sndlen 5
	sndnote $00
	sndnote $2A
	sndlen 20
	sndnote $2C
	sndlen 13
	sndnote $28
	sndlen 14
	sndnote $27
	sndlen 13
	sndnote $25
	sndnote $24
	sndlen 14
	sndnote $27
	sndlen 13
	sndnote $28
	sndlen 80
	sndlenpre $50
	sndenv 1, SNDENV_DEC, 1
	sndnote $01
	sndlen 80
	sndlenpre $50
	sndret
SndData_BGM_Geese_Ch2:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 1, 0
	sndcall .call0
	sndcall .call1
	sndcall .call2
	sndloop SndData_BGM_Geese_Ch2
.call0:
	sndnote $0D
	sndlen 20
	sndnote $0F
	sndlen 10
	sndnote $0D
	sndlen 20
	sndnote $0F
	sndlen 10
	sndnote $0D
	sndlen 20
	sndnote $0F
	sndlen 10
	sndnote $0D
	sndlen 20
	sndnote $0F
	sndlen 10
	sndnote $10
	sndlen 20
	sndnote $12
	sndloopcnt $00, 13, .call0
	sndret
.call1:
	sndnote $0C
	sndlen 20
	sndnote $0F
	sndlen 10
	sndnote $0C
	sndlen 20
	sndnote $0F
	sndlen 10
	sndnote $0C
	sndlen 20
	sndnote $0F
	sndlen 10
	sndnote $0C
	sndlen 20
	sndnote $0F
	sndlen 10
	sndnote $14
	sndlen 20
	sndnote $15
	sndnote $12
	sndnote $14
	sndlen 10
	sndnote $12
	sndlen 20
	sndnote $14
	sndlen 10
	sndnote $12
	sndlen 20
	sndnote $14
	sndlen 10
	sndnote $12
	sndlen 20
	sndnote $14
	sndlen 10
	sndnote $10
	sndlen 20
	sndnote $12
	sndnote $0C
	sndnote $0F
	sndlen 10
	sndnote $0C
	sndlen 20
	sndnote $0F
	sndlen 10
	sndnote $0C
	sndlen 20
	sndnote $0F
	sndlen 10
	sndnote $0C
	sndlen 20
	sndnote $0F
	sndlen 10
	sndnote $18
	sndlen 20
	sndnote $1B
	sndret
.call2:
	sndenv 6, SNDENV_DEC, 2
	sndnr21 0, 0
	sndnote $14
	sndlen 5
	sndnote $1C
	sndnote $19
	sndnote $14
	sndnote $1E
	sndnote $1C
	sndnote $14
	sndnote $1C
	sndloopcnt $00, 16, .call2
	sndenv 7, SNDENV_DEC, 7
	sndnr21 1, 0
	sndnote $18
	sndlen 20
	sndnote $0C
	sndlen 10
	sndnote $19
	sndlen 20
	sndnote $0D
	sndlen 10
	sndnote $18
	sndlen 20
	sndnote $0C
	sndlen 13
	sndnote $19
	sndlen 14
	sndnote $1E
	sndlen 13
	sndnote $20
	sndnote $27
	sndlen 14
	sndnote $2A
	sndlen 13
	sndret
SndData_BGM_Geese_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH3R|SNDOUT_CH3L
	sndwave $02
	sndch3len $19
	sndcall .call0
	sndcall .call1
	sndcall .call2
	sndcall .call1
	sndcall .call3
	sndcall .call4
	sndnotebase $FC
	sndcall .call4
	sndnotebase $04
	sndcall .call4
	sndnotebase $FC
	sndcall .call4
	sndnotebase $04
	sndcall .call5
	sndloop SndData_BGM_Geese_Ch3
.call0:
	sndnote $0D
	sndlen 10
	sndnote $0D
	sndlen 5
	sndnote $0D
	sndnote $0D
	sndlen 10
	sndnote $0D
	sndnote $0D
	sndlen 5
	sndnote $0D
	sndnote $0D
	sndlen 10
	sndnote $0D
	sndnote $0D
	sndlen 5
	sndnote $0D
	sndnote $0D
	sndlen 10
	sndnote $0D
	sndnote $0D
	sndlen 5
	sndnote $0D
	sndnote $0D
	sndlen 10
	sndnote $09
	sndnote $09
	sndlen 5
	sndnote $09
	sndnote $0B
	sndlen 10
	sndnote $0B
	sndlen 5
	sndnote $0B
	sndloopcnt $00, 12, .call0
	sndret
.call1:
	sndnote $09
	sndlen 10
	sndnote $09
	sndlen 5
	sndnote $09
	sndnote $09
	sndlen 10
	sndnote $09
	sndlen 5
	sndnote $09
	sndnote $09
	sndlen 10
	sndnote $06
	sndnote $08
	sndch3len $3C
	sndnote $09
	sndlen 20
	sndch3len $1E
	sndnote $06
	sndlen 10
	sndnote $08
	sndnote $09
	sndnote $0B
	sndnote $09
	sndnote $06
	sndnote $01
	sndch3len $19
	sndnote $08
	sndlen 10
	sndnote $08
	sndlen 5
	sndnote $08
	sndnote $14
	sndlen 10
	sndnote $08
	sndlen 5
	sndnote $08
	sndnote $08
	sndlen 10
	sndnote $03
	sndnote $08
	sndnote $0D
	sndret
.call2:
	sndnote $18
	sndlen 10
	sndnote $24
	sndnote $14
	sndnote $20
	sndlen 5
	sndnote $18
	sndnote $0F
	sndlen 10
	sndnote $0F
	sndnote $0D
	sndlen 5
	sndnote $0F
	sndnote $10
	sndlen 10
	sndret
.call3:
	sndnote $27
	sndlen 5
	sndnote $25
	sndnote $24
	sndnote $21
	sndnote $20
	sndnote $1E
	sndnote $1C
	sndnote $1B
	sndnote $19
	sndnote $18
	sndnote $19
	sndnote $1B
	sndnote $1C
	sndnote $1E
	sndnote $20
	sndnote $1A
	sndret
.call4:
	sndnote $19
	sndlen 5
	sndnote $19
	sndnote $19
	sndnote $19
	sndnote $25
	sndlen 10
	sndnote $19
	sndlen 5
	sndnote $19
	sndloopcnt $00, 4, .call4
	sndret
.call5:
	sndch3len $1E
	sndnote $14
	sndlen 10
	sndnote $14
	sndnote $08
	sndnote $15
	sndnote $15
	sndnote $09
	sndnote $14
	sndnote $14
	sndnote $08
	sndlen 13
	sndnote $12
	sndlen 14
	sndnote $14
	sndlen 13
	sndnote $1B
	sndnote $18
	sndlen 14
	sndnote $12
	sndlen 13
	sndret
SndData_BGM_Geese_Ch4:
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndcall .call0
	sndcall .call1
	sndcall .call0
	sndcall .call2
	sndcall .call0
	sndcall .call1
	sndcall .call0
	sndcall .call2
	sndcall .call0
	sndcall .call1
	sndcall .call0
	sndcall .call3
	sndcall .call4
	sndcall .call5
	sndcall .call3
	sndcall .call6
	sndloop SndData_BGM_Geese_Ch4
.call0:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 15
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndloopcnt $00, 7, .call0
	sndret
.call1:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndch4 2, 0, 4
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndret
.call2:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndret
.call3:
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndret
.call4:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 15
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndloopcnt $00, 7, .call4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 5
	sndch4 2, 0, 6
	sndlen 5
	sndch4 2, 0, 6
	sndlen 5
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 5
	sndch4 1, 0, 0
	sndlen 5
	sndch4 1, 0, 0
	sndlen 5
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndret
.call5:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndloopcnt $00, 15, .call5
	sndret
.call6:
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 10
	sndloopcnt $00, 4, .call6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndch4 2, 0, 4
	sndlen 10
	sndch4 2, 0, 4
	sndlen 10
	sndch4 2, 0, 4
	sndlen 10
	sndret
SndHeader_BGM_Fairy:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_Fairy_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_Fairy_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_Fairy_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_Fairy_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_BGM_Fairy_Ch1:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH1R|SNDOUT_CH1L
	sndnr11 3, 0
	sndcall .call0
	sndcall .call1
	sndcall .call2
	sndcall .call3
	sndcall .call4
	sndcall .call5
	sndloop SndData_BGM_Fairy_Ch1
.call0:
	sndenv 1, SNDENV_DEC, 1
	sndnote $05
	sndlen 20
	sndenv 7, SNDENV_DEC, 7
	sndnote $1D
	sndlen 10
	sndenv 1, SNDENV_DEC, 1
	sndnote $05
	sndlen 20
	sndenv 7, SNDENV_DEC, 7
	sndnote $1D
	sndlen 10
	sndnote $1B
	sndnote $18
	sndenv 1, SNDENV_DEC, 1
	sndnote $03
	sndlen 20
	sndenv 7, SNDENV_DEC, 7
	sndnote $1B
	sndlen 10
	sndenv 1, SNDENV_DEC, 1
	sndnote $03
	sndlen 20
	sndenv 7, SNDENV_DEC, 7
	sndnote $1B
	sndlen 10
	sndnote $1B
	sndnote $16
	sndenv 1, SNDENV_DEC, 1
	sndnote $0A
	sndlen 20
	sndenv 7, SNDENV_DEC, 7
	sndnote $22
	sndlen 10
	sndenv 1, SNDENV_DEC, 1
	sndnote $0A
	sndlen 20
	sndenv 7, SNDENV_DEC, 7
	sndnote $22
	sndlen 10
	sndenv 1, SNDENV_DEC, 1
	sndnote $0A
	sndlen 20
	sndenv 7, SNDENV_DEC, 7
	sndnote $22
	sndlen 10
	sndenv 1, SNDENV_DEC, 1
	sndnote $0A
	sndlen 20
	sndenv 7, SNDENV_DEC, 7
	sndnote $22
	sndlen 10
	sndnote $00
	sndnote $22
	sndlen 20
	sndnote $00
	sndlen 10
	sndloopcnt $00, 2, .call0
	sndret
.call1:
	sndenv 6, SNDENV_INC, 0
	sndnr11 2, 0
	sndnote $16
	sndlen 30
	sndnote $22
	sndlen 80
	sndlenpre $0A
	sndnote $27
	sndlen 10
	sndnote $24
	sndnote $20
	sndnote $1F
	sndlen 40
	sndnote $1B
	sndlen 30
	sndnote $16
	sndlen 80
	sndenv 1, SNDENV_DEC, 1
	sndnote $0A
	sndlen 20
	sndenv 6, SNDENV_INC, 0
	sndnote $16
	sndlen 30
	sndnote $22
	sndlen 80
	sndlenpre $0A
	sndnote $00
	sndnote $25
	sndnote $24
	sndnote $20
	sndnote $1F
	sndnote $20
	sndnote $1F
	sndnote $1B
	sndlen 20
	sndnote $16
	sndnote $19
	sndlen 40
	sndnote $1B
	sndlen 7
	sndnote $19
	sndlen 6
	sndnote $1B
	sndlen 7
	sndnote $19
	sndnote $1B
	sndlen 6
	sndnote $19
	sndlen 7
	sndnote $1B
	sndlen 10
	sndnote $19
	sndlen 30
	sndnote $20
	sndnote $22
	sndlen 80
	sndnote $00
	sndlen 10
	sndnote $1F
	sndnote $22
	sndlen 30
	sndnote $25
	sndnote $29
	sndlen 60
	sndenv 1, SNDENV_DEC, 1
	sndnote $05
	sndlen 20
	sndlenpre $07
	sndenv 6, SNDENV_INC, 0
	sndnote $27
	sndlen 6
	sndnote $29
	sndlen 7
	sndnote $2C
	sndlen 30
	sndnote $30
	sndnote $29
	sndnote $25
	sndlen 20
	sndnote $00
	sndlen 10
	sndnote $22
	sndlen 20
	sndnote $27
	sndlen 10
	sndnote $25
	sndlenpre $28
	sndnote $00
	sndlen 20
	sndnote $25
	sndlen 10
	sndnote $29
	sndlen 20
	sndnote $27
	sndlen 20
	sndlenpre $03
	sndnote $1D
	sndlen 7
	sndnote $1F
	sndlen 6
	sndnote $22
	sndlen 7
	sndnote $25
	sndnote $29
	sndlen 6
	sndnote $2C
	sndlen 7
	sndnote $30
	sndret
.call2:
	sndenv 7, SNDENV_DEC, 7
	sndnr11 3, 0
	sndenv 1, SNDENV_DEC, 1
	sndnote $05
	sndlen 20
	sndenv 7, SNDENV_DEC, 7
	sndnote $1D
	sndlen 10
	sndenv 1, SNDENV_DEC, 1
	sndnote $05
	sndlen 20
	sndenv 7, SNDENV_DEC, 7
	sndnote $1D
	sndlen 10
	sndenv 1, SNDENV_DEC, 1
	sndnote $05
	sndlen 20
	sndenv 7, SNDENV_DEC, 7
	sndnote $1D
	sndlen 10
	sndenv 1, SNDENV_DEC, 1
	sndnote $05
	sndlen 20
	sndenv 7, SNDENV_DEC, 7
	sndnote $1D
	sndlen 10
	sndenv 1, SNDENV_DEC, 1
	sndnote $05
	sndenv 7, SNDENV_DEC, 7
	sndnote $1B
	sndnote $1B
	sndnote $1D
	sndloopcnt $00, 3, .call2
	sndenv 1, SNDENV_DEC, 1
	sndnote $05
	sndlen 20
	sndenv 7, SNDENV_DEC, 7
	sndnote $1D
	sndlen 10
	sndenv 1, SNDENV_DEC, 1
	sndnote $05
	sndlen 20
	sndenv 7, SNDENV_DEC, 7
	sndnote $1B
	sndlen 10
	sndnote $1B
	sndnote $1D
	sndenv 1, SNDENV_DEC, 1
	sndnote $05
	sndlen 20
	sndenv 7, SNDENV_DEC, 7
	sndnote $20
	sndlen 10
	sndenv 1, SNDENV_DEC, 1
	sndnote $05
	sndlen 20
	sndenv 7, SNDENV_DEC, 7
	sndnote $1B
	sndlen 10
	sndnote $22
	sndnote $1B
	sndret
.call3:
	sndenv 6, SNDENV_INC, 0
	sndnr11 2, 0
	sndnote $16
	sndlen 30
	sndnote $22
	sndlen 80
	sndlenpre $0A
	sndnote $25
	sndnote $24
	sndnote $20
	sndnote $1F
	sndlen 40
	sndnote $1B
	sndlen 30
	sndnote $16
	sndlen 40
	sndnote $00
	sndlen 10
	sndnote $1B
	sndlen 20
	sndnote $19
	sndnote $14
	sndlen 10
	sndnote $11
	sndnote $14
	sndnote $19
	sndnote $20
	sndlen 40
	sndlenpre $0A
	sndnote $13
	sndnote $16
	sndnote $19
	sndnote $1F
	sndlen 40
	sndret
.call4:
	sndnote $1D
	sndlen 3
	sndnote $20
	sndlen 4
	sndnote $25
	sndlen 3
	sndnote $27
	sndlen 30
	sndnote $25
	sndnote $00
	sndlen 20
	sndnote $24
	sndlen 30
	sndnote $25
	sndnote $27
	sndlen 20
	sndnote $27
	sndlen 30
	sndnote $25
	sndnote $29
	sndlen 20
	sndnote $27
	sndlen 30
	sndnote $25
	sndnote $24
	sndlen 20
	sndret
.call5:
	sndnote $24
	sndlen 30
	sndnote $22
	sndlen 40
	sndnote $27
	sndlen 10
	sndnote $24
	sndlen 30
	sndnote $20
	sndnote $1D
	sndlen 20
	sndnote $1E
	sndlen 80
	sndnote $20
	sndret
SndData_BGM_Fairy_Ch2:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 3, 0
	sndcall .call0
	sndcall .call1
	sndcall .call2
	sndcall .call1
	sndcall .call3
	sndcall .call1
	sndcall .call2
	sndcall .call1
	sndcall .call4
	sndcall .call5
	sndcall .call6
	sndcall .call7
	sndcall .call8
	sndloop SndData_BGM_Fairy_Ch2
.call0:
	sndnote $16
	sndlen 5
	sndnote $00
	sndnote $16
	sndnote $00
	sndnote $22
	sndlen 10
	sndnote $16
	sndlen 5
	sndnote $00
	sndnote $16
	sndnote $00
	sndnote $22
	sndlen 10
	sndnote $20
	sndnote $1D
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $14
	sndnote $00
	sndnote $20
	sndlen 10
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $14
	sndnote $00
	sndnote $20
	sndlen 10
	sndnote $1F
	sndnote $1B
	sndnote $1B
	sndlen 5
	sndnote $00
	sndnote $1B
	sndnote $00
	sndnote $27
	sndlen 10
	sndnote $1B
	sndlen 5
	sndnote $00
	sndnote $1B
	sndnote $00
	sndnote $27
	sndlen 10
	sndnote $1B
	sndlen 5
	sndnote $00
	sndnote $1B
	sndnote $00
	sndnote $27
	sndlen 10
	sndnote $1B
	sndlen 5
	sndnote $00
	sndnote $1B
	sndnote $00
	sndnote $27
	sndlen 10
	sndnote $1B
	sndlen 5
	sndnote $00
	sndnote $27
	sndlen 20
	sndnote $1B
	sndlen 5
	sndnote $00
	sndloopcnt $00, 2, .call0
	sndret
.call1:
	sndenv 6, SNDENV_DEC, 5
	sndnote $29
	sndlen 10
	sndnote $25
	sndnote $24
	sndnote $20
	sndlen 20
	sndnote $1D
	sndnote $19
	sndnote $16
	sndnote $1B
	sndlen 10
	sndnote $18
	sndnote $14
	sndnote $0F
	sndlen 20
	sndret
.call2:
	sndnote $16
	sndlen 10
	sndnote $0F
	sndnote $13
	sndnote $16
	sndnote $1D
	sndnote $19
	sndnote $1D
	sndnote $20
	sndnote $25
	sndnote $1D
	sndnote $20
	sndnote $24
	sndnote $27
	sndnote $2B
	sndnote $2E
	sndnote $27
	sndret
.call3:
	sndnote $0D
	sndlen 10
	sndnote $13
	sndnote $16
	sndnote $11
	sndlen 30
	sndnote $13
	sndlen 10
	sndnote $19
	sndnote $1B
	sndnote $16
	sndlen 30
	sndnote $1B
	sndlen 10
	sndnote $1F
	sndnote $22
	sndnote $1D
	sndret
.call4:
	sndnote $0D
	sndlen 10
	sndnote $13
	sndnote $16
	sndnote $11
	sndlen 30
	sndnote $13
	sndlen 10
	sndnote $19
	sndnote $1B
	sndnote $16
	sndlen 30
	sndnote $1B
	sndlen 20
	sndnote $24
	sndret
.call5:
	sndenv 7, SNDENV_DEC, 7
	sndnote $16
	sndlen 5
	sndnote $00
	sndnote $16
	sndnote $00
	sndnote $22
	sndlen 10
	sndnote $16
	sndlen 5
	sndnote $00
	sndnote $16
	sndnote $00
	sndnote $22
	sndlen 10
	sndnote $16
	sndlen 5
	sndnote $00
	sndnote $16
	sndnote $00
	sndnote $22
	sndlen 10
	sndnote $16
	sndlen 5
	sndnote $00
	sndnote $16
	sndnote $00
	sndnote $22
	sndlen 10
	sndnote $16
	sndlen 5
	sndnote $00
	sndnote $1F
	sndlen 10
	sndnote $20
	sndnote $22
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $14
	sndnote $00
	sndnote $22
	sndlen 10
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $14
	sndnote $00
	sndnote $22
	sndlen 10
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $14
	sndnote $00
	sndnote $22
	sndlen 10
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $14
	sndnote $00
	sndnote $22
	sndlen 10
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $1F
	sndlen 10
	sndnote $20
	sndnote $22
	sndnote $13
	sndlen 5
	sndnote $00
	sndnote $13
	sndnote $00
	sndnote $22
	sndlen 10
	sndnote $13
	sndlen 5
	sndnote $00
	sndnote $13
	sndnote $00
	sndnote $22
	sndlen 10
	sndnote $13
	sndlen 5
	sndnote $00
	sndnote $13
	sndnote $00
	sndnote $22
	sndlen 10
	sndnote $13
	sndlen 5
	sndnote $00
	sndnote $13
	sndnote $00
	sndnote $22
	sndlen 10
	sndnote $13
	sndlen 5
	sndnote $00
	sndnote $1F
	sndlen 10
	sndnote $20
	sndnote $22
	sndnote $12
	sndlen 5
	sndnote $00
	sndnote $12
	sndnote $00
	sndnote $22
	sndlen 10
	sndnote $12
	sndlen 5
	sndnote $00
	sndnote $12
	sndnote $00
	sndnote $1E
	sndlen 10
	sndnote $20
	sndnote $22
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $14
	sndnote $00
	sndnote $1B
	sndlen 10
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $14
	sndnote $00
	sndnote $20
	sndlen 10
	sndnote $27
	sndnote $20
	sndret
.call6:
	sndenv 6, SNDENV_DEC, 5
	sndnote $25
	sndlen 10
	sndnote $2C
	sndnote $25
	sndlen 5
	sndnote $25
	sndnote $29
	sndlen 10
	sndnote $2C
	sndnote $25
	sndnote $19
	sndnote $22
	sndnote $11
	sndlen 5
	sndnote $11
	sndnote $20
	sndlen 10
	sndnote $25
	sndlen 5
	sndnote $25
	sndnote $19
	sndlen 10
	sndnote $20
	sndlen 5
	sndnote $20
	sndnote $1F
	sndlen 10
	sndnote $20
	sndnote $22
	sndnote $25
	sndlen 10
	sndnote $2C
	sndnote $25
	sndlen 5
	sndnote $25
	sndnote $29
	sndlen 10
	sndnote $2C
	sndnote $25
	sndnote $19
	sndnote $22
	sndnote $12
	sndlen 5
	sndnote $12
	sndnote $22
	sndlen 10
	sndnote $25
	sndlen 5
	sndnote $25
	sndnote $19
	sndlen 10
	sndnote $22
	sndlen 5
	sndnote $22
	sndnote $1D
	sndnote $22
	sndnote $1D
	sndnote $19
	sndnote $12
	sndnote $16
	sndnote $25
	sndlen 10
	sndnote $2C
	sndnote $25
	sndlen 5
	sndnote $25
	sndnote $29
	sndlen 10
	sndnote $2C
	sndnote $25
	sndnote $19
	sndnote $22
	sndnote $13
	sndlen 5
	sndnote $13
	sndnote $20
	sndlen 10
	sndnote $25
	sndlen 5
	sndnote $25
	sndnote $19
	sndlen 10
	sndnote $20
	sndlen 5
	sndnote $20
	sndnote $1F
	sndlen 10
	sndnote $20
	sndnote $22
	sndret
.call7:
	sndenv 6, SNDENV_DEC, 5
	sndnotebase $0C
	sndnote $12
	sndlen 10
	sndnote $16
	sndnote $19
	sndnote $16
	sndnote $06
	sndnote $12
	sndnote $0D
	sndnote $19
	sndnote $11
	sndnote $14
	sndnote $19
	sndnote $14
	sndnote $05
	sndnote $11
	sndnote $0D
	sndnote $11
	sndnote $11
	sndnote $16
	sndnote $19
	sndnote $16
	sndnote $05
	sndnote $11
	sndnote $0D
	sndnote $16
	sndnote $13
	sndnote $16
	sndnote $19
	sndnote $16
	sndnote $07
	sndnote $13
	sndnote $0F
	sndnote $19
	sndnote $12
	sndlen 10
	sndnote $16
	sndnote $19
	sndnote $16
	sndnote $06
	sndnote $12
	sndnote $0D
	sndnote $19
	sndnote $11
	sndnote $14
	sndnote $19
	sndnote $14
	sndnote $05
	sndnote $11
	sndnote $0D
	sndnote $11
	sndnotebase $F4
	sndret
.call8:
	sndenv 6, SNDENV_DEC, 7
	sndnote $22
	sndlen 30
	sndnote $2A
	sndnote $29
	sndlen 20
	sndnote $24
	sndlen 30
	sndnote $2C
	sndlen 20
	sndnote $2A
	sndnote $29
	sndlen 10
	sndret
SndData_BGM_Fairy_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH3R|SNDOUT_CH3L
	sndwave $04
	sndch3len $1E
	sndcall .call0
	sndcall .call1
	sndcall .call0
	sndcall .call2
	sndcall .call3
	sndcall .call4
	sndcall .call5
	sndcall .call6
	sndcall .call7
	sndloop SndData_BGM_Fairy_Ch3
.call0:
	sndnote $14
	sndlen 5
	sndnote $16
	sndnote $16
	sndlen 10
	sndnote $16
	sndnote $14
	sndlen 5
	sndnote $16
	sndnote $16
	sndlen 10
	sndnote $16
	sndnote $16
	sndnote $16
	sndnote $13
	sndlen 5
	sndnote $14
	sndnote $14
	sndlen 10
	sndnote $14
	sndnote $13
	sndlen 5
	sndnote $14
	sndnote $14
	sndlen 10
	sndnote $14
	sndnote $14
	sndnote $14
	sndnote $12
	sndlen 5
	sndnote $13
	sndnote $13
	sndlen 10
	sndnote $13
	sndnote $12
	sndlen 5
	sndnote $13
	sndnote $13
	sndlen 10
	sndnote $13
	sndnote $13
	sndnote $13
	sndret
.call1:
	sndnote $19
	sndlen 5
	sndnote $1B
	sndnote $1B
	sndlen 10
	sndnote $1B
	sndnote $19
	sndlen 5
	sndnote $1B
	sndnote $1B
	sndlen 10
	sndnote $1B
	sndnote $1B
	sndnote $1B
	sndret
.call2:
	sndnote $19
	sndlen 5
	sndnote $1B
	sndnote $1B
	sndlen 10
	sndnote $1B
	sndch3len $3C
	sndnote $19
	sndlen 20
	sndch3len $1E
	sndnote $13
	sndlen 10
	sndnote $14
	sndnote $15
	sndret
.call3:
	sndch3len $00
	sndnote $16
	sndlen 30
	sndnote $22
	sndnote $20
	sndnote $1B
	sndnote $1D
	sndlen 20
	sndnote $19
	sndnote $13
	sndlen 30
	sndnote $1F
	sndnote $1B
	sndnote $19
	sndnote $1B
	sndlen 20
	sndnote $14
	sndloopcnt $00, 3, .call3
	sndnote $16
	sndlen 30
	sndnote $22
	sndnote $20
	sndnote $1B
	sndnote $1D
	sndlen 20
	sndnote $19
	sndnote $13
	sndlen 30
	sndnote $1F
	sndnote $19
	sndnote $1E
	sndnote $12
	sndlen 20
	sndnote $14
	sndret
.call4:
	sndch3len $1E
	sndnote $14
	sndlen 5
	sndnote $16
	sndnote $16
	sndlen 10
	sndnote $16
	sndnote $14
	sndlen 5
	sndnote $16
	sndnote $16
	sndlen 10
	sndnote $16
	sndnote $14
	sndlen 5
	sndnote $16
	sndnote $16
	sndlen 10
	sndnote $16
	sndnote $15
	sndlen 5
	sndnote $16
	sndnote $16
	sndlen 10
	sndnote $11
	sndnote $16
	sndnote $16
	sndnote $11
	sndnote $16
	sndnote $13
	sndlen 5
	sndnote $14
	sndnote $14
	sndlen 10
	sndnote $14
	sndnote $13
	sndlen 5
	sndnote $14
	sndnote $14
	sndlen 10
	sndnote $14
	sndnote $13
	sndlen 5
	sndnote $14
	sndnote $14
	sndlen 10
	sndnote $14
	sndnote $13
	sndlen 5
	sndnote $14
	sndnote $14
	sndlen 10
	sndnote $0F
	sndnote $14
	sndnote $14
	sndnote $0F
	sndnote $14
	sndnote $12
	sndlen 5
	sndnote $13
	sndnote $13
	sndlen 10
	sndnote $13
	sndnote $12
	sndlen 5
	sndnote $13
	sndnote $13
	sndlen 10
	sndnote $13
	sndnote $12
	sndlen 5
	sndnote $13
	sndnote $13
	sndlen 10
	sndnote $13
	sndnote $12
	sndlen 5
	sndnote $13
	sndnote $13
	sndlen 10
	sndnote $19
	sndnote $13
	sndnote $0F
	sndnote $16
	sndnote $0F
	sndnote $11
	sndlen 5
	sndnote $12
	sndnote $12
	sndlen 10
	sndnote $12
	sndnote $11
	sndlen 5
	sndnote $12
	sndnote $12
	sndlen 10
	sndnote $12
	sndnote $11
	sndlen 5
	sndnote $12
	sndnote $12
	sndlen 10
	sndnote $13
	sndlen 5
	sndnote $14
	sndnote $14
	sndlen 10
	sndnote $14
	sndch3len $3C
	sndnote $1B
	sndlen 20
	sndnote $19
	sndnote $14
	sndlen 10
	sndch3len $1E
	sndret
.call5:
	sndnote $14
	sndlen 5
	sndnote $16
	sndnote $16
	sndlen 10
	sndnote $16
	sndnote $14
	sndlen 5
	sndnote $16
	sndnote $16
	sndlen 10
	sndnote $16
	sndnote $14
	sndlen 5
	sndnote $16
	sndnote $16
	sndlen 10
	sndnote $13
	sndlen 5
	sndnote $14
	sndnote $14
	sndlen 10
	sndnote $14
	sndnote $13
	sndlen 5
	sndnote $14
	sndnote $14
	sndlen 10
	sndnote $14
	sndnote $13
	sndlen 5
	sndnote $14
	sndnote $14
	sndlen 10
	sndnote $12
	sndlen 5
	sndnote $13
	sndnote $13
	sndlen 10
	sndnote $13
	sndnote $12
	sndlen 5
	sndnote $13
	sndnote $13
	sndlen 10
	sndnote $13
	sndnote $12
	sndlen 5
	sndnote $13
	sndnote $13
	sndlen 10
	sndnote $11
	sndlen 5
	sndnote $12
	sndnote $12
	sndlen 10
	sndnote $12
	sndch3len $3C
	sndnote $16
	sndlen 20
	sndch3len $1E
	sndnote $1B
	sndlen 10
	sndnote $19
	sndnote $11
	sndnote $18
	sndlen 5
	sndnote $19
	sndnote $19
	sndlen 10
	sndnote $19
	sndnote $18
	sndlen 5
	sndnote $19
	sndnote $19
	sndlen 10
	sndnote $19
	sndnote $18
	sndlen 5
	sndnote $19
	sndnote $19
	sndlen 10
	sndnote $1A
	sndlen 5
	sndnote $1B
	sndnote $1B
	sndlen 10
	sndnote $1B
	sndnote $1A
	sndlen 5
	sndnote $1B
	sndnote $1B
	sndlen 10
	sndnote $1B
	sndnote $1A
	sndlen 5
	sndnote $1B
	sndnote $1B
	sndlen 10
	sndret
.call6:
	sndch3len $00
	sndnote $12
	sndlen 30
	sndnote $16
	sndlen 10
	sndnote $19
	sndnote $1B
	sndnote $12
	sndlen 20
	sndnote $11
	sndlen 40
	sndnote $11
	sndlen 20
	sndnote $14
	sndnote $16
	sndlen 40
	sndlenpre $0A
	sndnote $16
	sndlen 10
	sndnote $11
	sndnote $0D
	sndnote $0F
	sndlen 60
	sndlenpre $0A
	sndnote $0F
	sndnote $12
	sndlen 30
	sndnote $19
	sndnote $12
	sndlen 20
	sndnote $11
	sndlen 30
	sndnote $18
	sndnote $11
	sndlen 20
	sndret
.call7:
	sndnote $12
	sndlen 30
	sndnote $1E
	sndnote $19
	sndlen 20
	sndnote $14
	sndlen 30
	sndnote $20
	sndnote $1B
	sndlen 20
	sndch3len $1E
	sndret
SndData_BGM_Fairy_Ch4:
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndcall .call0
	sndcall .call1
	sndcall .call0
	sndcall .call2
	sndcall .call3
	sndcall .call4
	sndcall .call3
	sndcall .call5
	sndcall .call3
	sndcall .call4
	sndcall .call3
	sndcall .call5
	sndcall .call6
	sndcall .call7
	sndcall .call6
	sndcall .call8
	sndcall .call0
	sndcall .call1
	sndcall .call0
	sndcall .call2
	sndcall .call9
	sndcall .call10
	sndloop SndData_BGM_Fairy_Ch4
.call0:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndloopcnt $00, 6, .call0
	sndret
.call1:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndret
.call2:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 2
	sndch4 2, 0, 4
	sndlen 3
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndret
.call3:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 20
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 10
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndret
.call4:
	sndenv 1, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 20
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 20
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndret
.call5:
	sndenv 1, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 20
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 10
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 20
	sndret
.call6:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 20
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 20
	sndloopcnt $00, 3, .call6
	sndret
.call7:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 20
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndret
.call8:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndch4 2, 0, 4
	sndlen 2
	sndch4 2, 0, 4
	sndlen 3
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 2
	sndch4 2, 0, 4
	sndlen 3
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 5
	sndch4 1, 0, 0
	sndlen 5
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 5
	sndch4 3, 0, 2
	sndlen 5
	sndret
.call9:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndloopcnt $00, 7, .call9
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
.call9b:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndloopcnt $00, 3, .call9b
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 10
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 10
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 10
	sndret
.call10:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 20
	sndloopcnt $00, 7, .call10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 10
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 10
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 10
.call10b:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 20
	sndloopcnt $00, 3, .call10b
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndch4 2, 0, 4
	sndlen 10
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
.call10c:
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndloopcnt $00, 3, .call10c
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndch4 2, 0, 4
	sndlen 10
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 10
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 20
	sndret
SndHeader_BGM_Esaka:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_Esaka_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_Esaka_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_Esaka_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_Esaka_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_BGM_Esaka_Ch1:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH1R|SNDOUT_CH1L
	sndnr11 3, 0
	sndnote $14
	sndlen 80
.main:
	sndenv 7, SNDENV_DEC, 7
	sndcall .call0
	sndcall .call1
	sndcall .call2
	sndcall .call3
	sndcall .call4
	sndcall .call5
	sndcall .call6
	sndcall .call7
	sndcall .call8
	sndloop .main
	;--
	; [TCRF] Unreferenced song section
	sndenv 7, SNDENV_DEC, 7 ;X
	sndnr11 3, 0 ;X
	sndnote $14 ;X
	sndlen 40 ;X
	sndnote $08 ;X
	sndlen 5 ;X
	sndnote $00 ;X
	sndnote $14 ;X
	sndlen 30 ;X
	;--
.call0:
	sndnote $14
	sndlen 10
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $0B
	sndnote $00
	sndnote $12
	sndlen 10
	sndnote $12
	sndlen 5
	sndnote $00
	sndnote $0B
	sndnote $00
	sndnote $14
	sndlen 10
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $17
	sndlen 80
	sndnote $17
	sndlen 10
	sndnote $17
	sndlen 5
	sndnote $00
	sndnote $0F
	sndnote $00
	sndnote $16
	sndlen 10
	sndnote $16
	sndlen 5
	sndnote $00
	sndnote $0F
	sndnote $00
	sndnote $17
	sndlen 10
	sndnote $17
	sndlen 5
	sndnote $00
	sndnote $19
	sndlen 80
	sndnote $19
	sndlen 10
	sndnote $19
	sndlen 5
	sndnote $00
	sndnote $14
	sndnote $00
	sndnote $1B
	sndlen 10
	sndnote $1B
	sndlen 5
	sndnote $00
	sndnote $14
	sndnote $00
	sndnote $19
	sndlen 10
	sndnote $19
	sndlen 5
	sndnote $00
	sndnote $1B
	sndlen 80
	sndret
.call1:
	sndnote $16
	sndlen 10
	sndnote $16
	sndlen 5
	sndnote $00
	sndnote $0F
	sndnote $00
	sndnote $17
	sndlen 10
	sndnote $17
	sndlen 5
	sndnote $00
	sndnote $0F
	sndnote $00
	sndnote $19
	sndlen 20
	sndret
.call2:
	sndenv 1, SNDENV_DEC, 1
	sndnote $01
	sndlen 60
	sndret
.call3:
	sndenv 7, SNDENV_INC, 0
	sndnote $20
	sndlen 10
	sndnote $1B
	sndnote $22
	sndnote $23
	sndlen 13
	sndnote $00
	sndlen 7
	sndnote $25
	sndlen 20
	sndnote $23
	sndlen 10
	sndnote $1E
	sndnote $20
	sndlen 30
	sndenv 1, SNDENV_DEC, 1
	sndnote $08
	sndlen 40
	sndenv 7, SNDENV_INC, 0
	sndnote $20
	sndlen 10
	sndnote $1B
	sndnote $22
	sndnote $23
	sndlen 13
	sndnote $00
	sndlen 7
	sndnote $25
	sndlen 20
	sndnote $23
	sndlen 10
	sndnote $22
	sndnote $20
	sndret
.call4:
	sndnote $23
	sndlen 40
	sndnote $00
	sndlen 10
	sndnote $23
	sndnote $22
	sndnote $23
	sndnote $22
	sndlen 20
	sndnote $00
	sndlen 10
	sndnote $25
	sndlen 30
	sndnote $1E
	sndlen 20
	sndnote $20
	sndlen 30
	sndenv 1, SNDENV_DEC, 1
	sndlen 60
	sndnote $0F
	sndlen 10
	sndnote $0D
	sndnote $0F
	sndnote $12
	sndnote $0F
	sndlen 20
	sndret
.call5:
	sndenv 7, SNDENV_INC, 0
	sndnote $1D
	sndlen 2
	sndnote $1E
	sndnote $20
	sndnote $22
	sndnote $23
	sndnote $25
	sndlen 30
	sndnote $00
	sndlen 10
	sndnote $25
	sndnote $20
	sndnote $23
	sndnote $25
	sndlen 13
	sndnote $00
	sndlen 7
	sndnote $25
	sndlen 10
	sndnote $23
	sndnote $25
	sndnote $20
	sndnote $2A
	sndlen 20
	sndnote $00
	sndlen 10
	sndnote $2A
	sndnote $20
	sndlen 20
	sndenv 1, SNDENV_DEC, 1
	sndnote $08
	sndlen 40
	sndlenpre $0A
	sndret
.call6:
	sndenv 1, SNDENV_DEC, 1
	sndnote $08
	sndlen 40
	sndenv 7, SNDENV_INC, 0
	sndnote $20
	sndlen 20
	sndnote $22
	sndnote $23
	sndlen 40
	sndnote $00
	sndlen 10
	sndnote $20
	sndnote $22
	sndnote $23
	sndnote $25
	sndlen 20
	sndnote $00
	sndlen 10
	sndnote $27
	sndlen 30
	sndnote $2A
	sndlen 20
	sndnote $29
	sndlen 30
	sndnote $00
	sndlen 10
	sndnote $29
	sndnote $27
	sndnote $29
	sndnote $2C
	sndlen 30
	sndnote $00
	sndlen 10
	sndnote $25
	sndlen 40
	sndnote $00
	sndlen 10
	sndret
.call7:
	sndenv 7, SNDENV_INC, 0
	sndnote $27
	sndlen 60
	sndnote $00
	sndlen 10
	sndnote $2E
	sndlenpre $3C
	sndnote $2A
	sndlen 10
	sndnote $2C
	sndlenpre $3C
	sndnote $00
	sndlen 10
	sndnote $2E
	sndlen 30
	sndnote $2C
	sndlen 20
	sndret
.call8:
	sndnote $2E
	sndlen 13
	sndnote $2F
	sndlen 14
	sndnote $31
	sndlen 13
	sndnote $33
	sndlen 40
	sndnote $00
	sndlen 10
	sndnote $33
	sndnote $2A
	sndnote $2C
	sndlen 30
	sndnote $2A
	sndlen 20
	sndnote $2C
	sndlen 10
	sndnote $2A
	sndnote $29
	sndnote $2A
	sndlen 30
	sndnote $00
	sndlen 10
	sndnote $2C
	sndlen 30
	sndnote $29
	sndlen 20
	sndnote $00
	sndlen 10
	sndnote $2E
	sndnote $2F
	sndnote $31
	sndnote $36
	sndlen 13
	sndnote $35
	sndlen 14
	sndnote $31
	sndlen 13
	sndnote $33
	sndlen 80
	sndret
SndData_BGM_Esaka_Ch2:
	sndenv 6, SNDENV_DEC, 2
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 2, 0
.main:
	sndcall .call0
	sndcall .call1
	sndcall .call2
	sndenv 5, SNDENV_INC, 0
	sndnote $14
	sndlen 10
	sndnote $19
	sndnote $1A
	sndcall .call3
	sndcall .call4
	sndcall .call3
	sndcall .call5
	sndloop .main
.call0:
	sndenv 6, SNDENV_DEC, 2
	sndnr21 2, 0
	sndnote $2C
	sndlen 10
	sndnote $27
	sndnote $33
	sndnote $27
	sndnote $2F
	sndnote $27
	sndnote $31
	sndnote $27
	sndnote $2F
	sndnote $27
	sndnote $2E
	sndnote $27
	sndnote $31
	sndnote $27
	sndnote $2E
	sndnote $27
	sndloopcnt $00, 4, .call0
	sndret
.call1:
	sndenv 6, SNDENV_DEC, 7
	sndnr21 0, 0
	sndnote $12
	sndlen 10
	sndnote $12
	sndlen 5
	sndnote $00
	sndnote $0B
	sndnote $00
	sndnote $14
	sndlen 30
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $14
	sndnote $00
	sndnote $14
	sndlen 10
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $0B
	sndnote $00
	sndnote $14
	sndlen 10
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $14
	sndnote $00
	sndnote $0B
	sndlen 10
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $12
	sndlen 10
	sndnote $12
	sndlen 5
	sndnote $00
	sndnote $0B
	sndnote $00
	sndnote $14
	sndlen 30
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $14
	sndnote $00
	sndnote $14
	sndlen 10
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $0B
	sndnote $00
	sndnote $14
	sndlen 10
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $14
	sndnote $00
	sndnote $16
	sndlen 20
	sndnote $17
	sndnote $0F
	sndlen 5
	sndnote $00
	sndnote $17
	sndlen 15
	sndnote $00
	sndlen 5
	sndnote $17
	sndlen 10
	sndnote $0F
	sndlen 5
	sndnote $00
	sndnote $17
	sndlen 10
	sndnote $12
	sndlen 20
	sndnote $06
	sndlen 5
	sndnote $00
	sndnote $12
	sndlen 30
	sndnote $0D
	sndlen 20
	sndnote $14
	sndlen 10
	sndnote $12
	sndnote $14
	sndenv 1, SNDENV_DEC, 1
	sndnote $08
	sndlen 20
	sndenv 6, SNDENV_DEC, 7
	sndnote $14
	sndlen 10
	sndnote $12
	sndnote $14
	sndnote $00
	sndnote $20
	sndnote $1E
	sndnote $20
	sndnote $23
	sndnote $20
	sndlen 20
	sndnote $00
	sndlen 10
	sndret
.call2:
	sndnote $12
	sndlen 20
	sndnote $06
	sndlen 5
	sndnote $00
	sndnote $12
	sndlen 30
	sndnote $06
	sndlen 5
	sndnote $00
	sndnote $12
	sndlen 10
	sndnote $06
	sndlen 10
	sndnote $12
	sndnote $06
	sndlen 5
	sndnote $00
	sndnote $06
	sndnote $00
	sndnote $12
	sndlen 10
	sndnote $12
	sndlen 5
	sndnote $00
	sndnote $06
	sndlen 10
	sndnote $13
	sndnote $12
	sndlen 10
	sndnote $14
	sndnote $08
	sndlen 2
	sndnote $00
	sndlen 8
	sndnote $08
	sndlen 2
	sndnote $00
	sndlen 8
	sndnote $17
	sndlen 10
	sndnote $14
	sndnote $08
	sndlen 2
	sndnote $00
	sndlen 8
	sndnote $12
	sndlen 10
	sndlenpre $0A
	sndnote $14
	sndnote $00
	sndnote $06
	sndlen 2
	sndnote $00
	sndlen 8
	sndnote $14
	sndlen 20
	sndnote $16
	sndnote $10
	sndlen 40
	sndnote $10
	sndlen 10
	sndnote $0B
	sndlen 5
	sndnote $00
	sndnote $0B
	sndnote $00
	sndnote $10
	sndlen 10
	sndlenpre $0A
	sndnote $0B
	sndlen 5
	sndnote $00
	sndnote $0B
	sndlen 2
	sndnote $00
	sndlen 8
	sndnote $17
	sndlen 20
	sndnote $0B
	sndlen 10
	sndnote $17
	sndlen 20
	sndnote $16
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndnote $0A
	sndlen 5
	sndnote $0A
	sndnote $0A
	sndnote $0A
	sndenv 6, SNDENV_DEC, 7
	sndnote $16
	sndlen 20
	sndnote $0A
	sndlen 2
	sndnote $00
	sndlen 8
	sndnote $0A
	sndlen 2
	sndnote $00
	sndlen 8
	sndnote $19
	sndlen 20
	sndnote $0D
	sndlen 2
	sndnote $00
	sndlen 8
	sndnote $0D
	sndlen 2
	sndnote $00
	sndlen 8
	sndnote $19
	sndlen 20
	sndret
.call3:
	sndnote $1B
	sndlen 40
	sndlenpre $0A
	sndnote $0F
	sndlen 5
	sndnote $00
	sndnote $1B
	sndlen 10
	sndnote $19
	sndlen 60
	sndnote $0D
	sndlen 2
	sndnote $00
	sndlen 8
	sndnote $19
	sndlen 10
	sndnote $17
	sndlenpre $28
	sndnote $0B
	sndlen 10
	sndnote $0B
	sndlen 5
	sndnote $00
	sndnote $17
	sndlen 10
	sndret
.call4:
	sndnote $19
	sndlen 10
	sndlenpre $28
	sndnote $16
	sndlen 13
	sndnote $12
	sndlen 14
	sndnote $12
	sndlen 13
	sndret
.call5:
	sndnote $19
	sndlen 40
	sndnote $0D
	sndlen 2
	sndnote $00
	sndlen 8
	sndnote $1E
	sndlen 10
	sndnote $1B
	sndlen 20
	sndnote $19
	sndlen 10
	sndret
SndData_BGM_Esaka_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH3R|SNDOUT_CH3L
	sndwave $04
	sndch3len $01
.main:
	sndch3len $19
	sndnotebase $0C
	sndcall .call0
	sndnotebase $F4
	sndcall .call1
	sndcall .call2
	sndcall .call3
	sndcall .call4
	sndcall .call5
	sndcall .call4
	sndcall .call6
	sndloop .main
.call0:
	sndnote $08
	sndlen 10
	sndloopcnt $00, 56, .call0
	sndch3len $5A
	sndnote $0A
	sndlen 20
	sndnote $03
	sndlen 10
	sndnote $0B
	sndlen 20
	sndnote $03
	sndlen 10
	sndnote $0D
	sndlen 20
	sndret
.call1:
	sndch3len $3C
	sndnote $06
	sndlen 10
	sndnote $08
	sndlen 20
	sndnote $08
	sndlen 30
	sndnote $08
	sndlen 10
	sndnote $08
	sndch3len $1E
	sndnote $08
	sndnote $08
	sndnote $03
	sndnote $08
	sndnote $08
	sndnote $08
	sndnote $0B
	sndnote $06
	sndch3len $3C
	sndnote $06
	sndlen 10
	sndnote $06
	sndlen 20
	sndnote $08
	sndlen 30
	sndnote $08
	sndlen 10
	sndnote $08
	sndch3len $1E
	sndnote $08
	sndnote $08
	sndnote $03
	sndnote $08
	sndnote $03
	sndnote $08
	sndnote $0A
	sndlen 20
	sndnote $0B
	sndlen 10
	sndnote $0B
	sndnote $03
	sndnote $0B
	sndnote $0B
	sndnote $03
	sndnote $0B
	sndnote $06
	sndlen 20
	sndnote $06
	sndlen 10
	sndnote $06
	sndnote $06
	sndnote $06
	sndnote $05
	sndnote $06
	sndnote $01
	sndnote $08
	sndnote $08
	sndnote $08
	sndlen 30
	sndnote $08
	sndlen 10
	sndnote $08
	sndnote $08
	sndlen 20
	sndch3len $3C
	sndnote $14
	sndlen 10
	sndnote $12
	sndnote $14
	sndnote $17
	sndnote $14
	sndlen 30
	sndret
.call2:
	sndch3len $19
	sndnote $12
	sndlen 10
	sndnote $06
	sndnote $06
	sndnote $12
	sndnote $06
	sndnote $06
	sndnote $06
	sndnote $12
	sndnote $06
	sndnote $06
	sndnote $12
	sndnote $06
	sndnote $06
	sndnote $05
	sndnote $06
	sndnote $07
	sndch3len $3C
	sndnote $19
	sndnote $1B
	sndlen 30
	sndnote $1E
	sndlen 10
	sndnote $1B
	sndlen 20
	sndnote $19
	sndret
.call3:
	sndnote $1B
	sndlen 30
	sndnote $14
	sndlen 20
	sndnote $16
	sndch3len $28
	sndnote $04
	sndlen 10
	sndnote $04
	sndnote $0B
	sndnote $04
	sndlen 20
	sndnote $04
	sndlen 10
	sndnote $08
	sndnote $04
	sndlen 20
	sndnote $04
	sndlen 10
	sndnote $04
	sndnote $0B
	sndlen 20
	sndnote $06
	sndlen 10
	sndnote $0B
	sndnote $06
	sndnote $0A
	sndlen 10
	sndnote $0A
	sndlen 20
	sndnote $0A
	sndnote $05
	sndlen 10
	sndnote $0A
	sndnote $0D
	sndlen 20
	sndnote $0D
	sndnote $0D
	sndnote $08
	sndlen 10
	sndnote $0D
	sndnote $0E
	sndret
.call4:
	sndch3len $14
	sndnote $0F
	sndlen 10
	sndnote $0F
	sndlen 5
	sndnote $0F
	sndnote $0F
	sndlen 10
	sndnote $0F
	sndlen 5
	sndnote $0F
	sndnote $0F
	sndlen 10
	sndnote $0F
	sndlen 5
	sndnote $0F
	sndnote $0F
	sndlen 10
	sndch3len $3C
	sndnote $0D
	sndlen 20
	sndch3len $14
	sndnote $0D
	sndlen 5
	sndnote $0D
	sndnote $0D
	sndlen 10
	sndnote $0D
	sndlen 5
	sndnote $0D
	sndnote $0D
	sndlen 10
	sndnote $0D
	sndlen 5
	sndnote $0D
	sndnote $0D
	sndlen 10
	sndch3len $3C
	sndnote $0B
	sndlen 20
	sndch3len $14
	sndnote $0B
	sndlen 5
	sndnote $0B
	sndnote $0B
	sndlen 10
	sndnote $0B
	sndlen 5
	sndnote $0B
	sndnote $0B
	sndlen 10
	sndnote $0B
	sndlen 5
	sndnote $0B
	sndnote $0B
	sndlen 10
	sndret
.call5:
	sndch3len $3C
	sndnote $0D
	sndlen 20
	sndch3len $14
	sndnote $0D
	sndlen 5
	sndnote $0D
	sndnote $0D
	sndlen 10
	sndnote $0D
	sndlen 5
	sndnote $0D
	sndch3len $3C
	sndnote $16
	sndlen 13
	sndnote $06
	sndlen 14
	sndnote $06
	sndlen 13
	sndret
.call6:
	sndch3len $3C
	sndnote $0D
	sndlen 20
	sndnote $01
	sndlen 10
	sndnote $0D
	sndnote $0D
	sndnote $0F
	sndnote $0F
	sndlen 20
	sndnote $0D
	sndlen 10
	sndch3len $19
	sndret
SndData_BGM_Esaka_Ch4:
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
.main:
	sndcall .call0
	sndcall .call1
	sndcall .call2
	sndcall .call3
	sndcall .call4
	sndcall .call3
	sndcall .call5
	sndcall .call6
	sndcall .call7
	sndcall .call8
	sndloop .main
.call0:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 20
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 20
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 20
	sndloopcnt $00, 3, .call0
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 20
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 20
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 10
	sndch4 2, 0, 4
	sndlen 10
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 3
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 4
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 3
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndret
.call1:
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndch4 2, 0, 4
	sndlen 20
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 30
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndch4 2, 0, 4
	sndlen 10
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndret
.call2:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 20
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 20
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 20
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndch4 2, 0, 4
	sndlen 10
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 5
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 3
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 4
	sndch4 2, 0, 4
	sndlen 3
	sndch4 2, 0, 4
	sndlen 10
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 20
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndret
.call3:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 20
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndloopcnt $00, 2, .call3
	sndret
.call4:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 20
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 20
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 10
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 10
	sndret
.call5:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 15
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndch4 2, 0, 4
	sndlen 3
	sndch4 2, 0, 4
	sndlen 4
	sndch4 2, 0, 4
	sndlen 3
	sndch4 2, 0, 4
	sndlen 10
	sndret
.call6:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 15
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 15
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndloopcnt $00, 3, .call6
	sndret
.call7:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 13
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndch4 3, 0, 6
	sndlen 13
	sndret
.call8:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 15
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 15
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndloopcnt $00, 2, .call8
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 20
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 10
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 10
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndret
SndHeader_BGM_MrKarateCutscene:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_MrKarateCutscene_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_MrKarateCutscene_Ch2 ; Data ptr
	db $F9 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_MrKarateCutscene_Ch3 ; Data ptr
	db $0C ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_MrKarateCutscene_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_BGM_MrKarateCutscene_Ch1:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH1R|SNDOUT_CH1L
	sndnr11 3, 0
	sndcall .call0
	sndloop SndData_BGM_MrKarateCutscene_Ch1
.call0:
	sndnote $22
	sndlen 12
	sndnote $22
	sndnote $14
	sndlen 3
	sndnote $00
	sndnote $14
	sndlen 6
	sndnote $14
	sndlen 3
	sndnote $00
	sndnote $14
	sndlen 6
	sndnote $25
	sndlen 24
	sndnote $14
	sndlen 6
	sndnote $00
	sndnote $14
	sndlen 12
	sndnote $22
	sndlen 12
	sndnote $22
	sndnote $14
	sndlen 3
	sndnote $00
	sndnote $14
	sndlen 6
	sndnote $14
	sndlen 3
	sndnote $00
	sndnote $14
	sndlen 6
	sndnote $26
	sndlen 24
	sndnote $14
	sndlen 6
	sndnote $00
	sndnote $14
	sndlen 12
	sndnote $22
	sndlen 12
	sndnote $22
	sndnote $14
	sndlen 3
	sndnote $00
	sndnote $14
	sndlen 6
	sndnote $14
	sndlen 3
	sndnote $00
	sndnote $14
	sndlen 6
	sndnote $28
	sndlen 24
	sndnote $14
	sndlen 6
	sndnote $00
	sndnote $14
	sndlen 12
	sndnote $22
	sndlen 12
	sndnote $22
	sndnote $14
	sndlen 3
	sndnote $00
	sndlen 9
	sndnote $29
	sndlen 24
	sndnote $14
	sndlen 6
	sndnote $00
	sndnote $2A
	sndlen 24
	sndloopcnt $00, 2, .call0
	sndnote $20
	sndlen 12
	sndnote $1F
	sndnote $1E
	sndnote $1F
	sndnote $1E
	sndnote $1D
	sndnote $1C
	sndlen 24
	sndret
SndData_BGM_MrKarateCutscene_Ch2:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 1, 0
	sndcall SndData_BGM_MrKarateCutscene_Ch1.call0
	sndloop SndData_BGM_MrKarateCutscene_Ch2
SndData_BGM_MrKarateCutscene_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH3R|SNDOUT_CH3L
	sndwave $02
	sndch3len $5A
	sndnote $08
	sndlen 12
	sndnote $08
	sndlen 24
	sndnote $08
	sndlen 12
	sndnote $0B
	sndlen 36
	sndnote $08
	sndlen 12
	sndnote $08
	sndlen 12
	sndnote $08
	sndlen 24
	sndnote $08
	sndlen 12
	sndnote $0C
	sndlen 36
	sndnote $08
	sndlen 12
	sndnote $08
	sndlen 12
	sndnote $08
	sndlen 24
	sndnote $08
	sndlen 12
	sndnote $0E
	sndlen 36
	sndnote $08
	sndlen 12
	sndnote $08
	sndlen 12
	sndnote $08
	sndnote $08
	sndnote $0F
	sndlen 24
	sndnote $08
	sndlen 12
	sndnote $10
	sndlen 24
	sndloopcnt $00, 2, SndData_BGM_MrKarateCutscene_Ch3
	sndnote $0F
	sndlen 12
	sndnote $0E
	sndnote $0D
	sndnote $0E
	sndnote $0D
	sndnote $0C
	sndlen 36
	sndloop SndData_BGM_MrKarateCutscene_Ch3
SndData_BGM_MrKarateCutscene_Ch4:
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndcall .call0
	sndcall .call0
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 6
	sndch4 2, 0, 4
	sndlen 12
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 12
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 12
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 24
	sndloop SndData_BGM_MrKarateCutscene_Ch4
.call0:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 12
	sndch4 3, 0, 6
	sndlen 24
	sndch4 3, 0, 6
	sndlen 6
	sndch4 3, 0, 6
	sndlen 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 36
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 12
	sndloopcnt $00, 3, .call0
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 12
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 12
	sndch4 3, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 12
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 12
	sndch4 3, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 12
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 12
	sndret
SndHeader_BGM_In1996:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_In1996_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_In1996_Ch2 ; Data ptr
	db $18 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_In1996_Ch3 ; Data ptr
	db $0C ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_In1996_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_BGM_In1996_Ch1:
	sndenv 7, SNDENV_DEC, 1
	sndenach SNDOUT_CH1R|SNDOUT_CH1L
	sndnr11 2, 0
	sndnote $00
	sndlen 56
.main:
	sndnote $00
	sndlen 7
	sndnote $24
	sndnote $29
	sndlen 14
	sndnote $27
	sndlen 7
	sndnote $29
	sndlen 14
	sndnote $29
	sndnote $24
	sndlen 7
	sndnote $29
	sndlen 14
	sndnote $27
	sndlen 7
	sndnote $29
	sndlen 21
	sndloopcnt $00, 3, .main
	sndenv 7, SNDENV_DEC, 7
	sndnr11 3, 0
	sndnote $00
	sndlen 7
	sndnote $11
	sndnote $00
	sndlen 14
	sndnote $11
	sndlen 7
	sndnote $11
	sndnote $00
	sndnote $0E
	sndlen 21
	sndnote $0E
	sndlen 14
	sndnote $11
	sndlen 7
	sndnote $11
	sndnote $00
	sndenv 7, SNDENV_INC, 0
	sndnote $22
	sndlen 21
	sndnote $24
	sndlen 56
	sndlenpre $07
	sndnote $00
	sndnote $27
	sndlen 14
	sndnote $24
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $27
	sndlen 21
	sndnote $29
	sndlen 35
	sndnote $00
	sndlen 7
	sndnote $29
	sndlen 28
	sndnote $30
	sndlen 21
	sndnote $2E
	sndlen 7
	sndlenpre $70
	sndnote $00
	sndlen 7
	sndnote $30
	sndnote $00
	sndlen 14
	sndnote $2E
	sndnote $30
	sndlen 7
	sndnote $33
	sndlen 84
	sndlenpre $03
	sndnote $00
	sndlen 4
	sndnote $35
	sndlen 7
	sndnote $30
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $35
	sndlen 10
	sndnote $00
	sndlen 4
	sndnote $33
	sndlen 14
	sndnote $00
	sndlen 7
	sndnote $35
	sndlen 28
	sndnote $00
	sndlen 7
	sndendch
SndData_BGM_In1996_Ch2:
	sndenv 6, SNDENV_INC, 0
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 1, 0
	sndnote $00
	sndlen 28
	sndnote $08
	sndlen 14
	sndnote $0A
	sndlen 7
	sndnote $0A
	sndlen 21
	sndnote $05
	sndlen 84
	sndnote $05
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $08
	sndlen 7
	sndlenpre $38
	sndnote $00
	sndlen 14
	sndnote $05
	sndnote $08
	sndnote $05
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $08
	sndlen 7
	sndlenpre $0E
	sndnote $0A
	sndlen 56
	sndnote $0A
	sndlen 14
	sndnote $08
	sndnote $0A
	sndnote $00
	sndlen 7
	sndnote $0C
	sndnote $00
	sndlen 14
	sndnote $0A
	sndlen 7
	sndnote $0C
	sndnote $00
	sndnote $0A
	sndlen 21
	sndnote $07
	sndlen 14
	sndnote $0A
	sndlen 7
	sndnote $0C
	sndnote $00
	sndnote $0C
	sndnotebase $F4
	sndlenpre $0E
	sndnote $05
	sndlen 56
	sndlenpre $0E
	sndnote $05
	sndlen 7
	sndnote $05
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $05
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $08
	sndlen 7
	sndlenpre $38
	sndnote $08
	sndlen 7
	sndnote $08
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $03
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $03
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $08
	sndlen 7
	sndnote $08
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $08
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $0A
	sndlen 7
	sndlenpre $38
	sndnote $11
	sndlen 7
	sndnote $05
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $11
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $0A
	sndlen 14
	sndnote $0A
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $08
	sndlen 7
	sndnote $0A
	sndnote $11
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $13
	sndlen 10
	sndnote $00
	sndlen 4
	sndnote $0C
	sndlen 7
	sndnote $07
	sndnote $07
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $08
	sndlen 7
	sndnote $0A
	sndlen 84
	sndnote $00
	sndlen 7
	sndnote $13
	sndnote $0C
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $13
	sndlen 14
	sndnote $11
	sndlen 14
	sndnote $00
	sndlen 7
	sndnote $11
	sndlen 28
	sndnote $00
	sndlen 7
	sndnotebase $0C
	sndendch
SndData_BGM_In1996_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH3R|SNDOUT_CH3L
	sndwave $03
	sndch3len $1E
	sndnote $00
	sndlen 28
	sndnote $08
	sndlen 7
	sndnote $01
	sndnote $16
	sndch3len $3C
	sndnote $0A
	sndlen 21
	sndch3len $1E
	sndnote $05
	sndlen 7
	sndnote $11
	sndnote $18
	sndnote $11
	sndnote $05
	sndnote $0F
	sndlen 14
	sndnote $0C
	sndlen 7
	sndnote $05
	sndnote $11
	sndnote $0C
	sndnote $04
	sndnote $05
	sndch3len $3C
	sndnote $08
	sndlen 21
	sndch3len $1E
	sndnote $05
	sndlen 7
	sndnote $08
	sndnote $14
	sndnote $0F
	sndnote $08
	sndnote $0C
	sndlen 14
	sndnote $0F
	sndlen 7
	sndnote $08
	sndnote $14
	sndnote $08
	sndlen 14
	sndnote $03
	sndlen 7
	sndch3len $3C
	sndnote $08
	sndlen 21
	sndch3len $1E
	sndnote $05
	sndlen 7
	sndnote $16
	sndnote $05
	sndnote $0A
	sndnote $11
	sndnote $0A
	sndlen 14
	sndnote $16
	sndlen 7
	sndnote $11
	sndlen 14
	sndnote $08
	sndlen 7
	sndnote $0F
	sndnote $05
	sndlen 14
	sndnote $00
	sndlen 7
	sndnote $0F
	sndlen 21
	sndnote $0E
	sndlen 7
	sndnote $0F
	sndlen 14
	sndnote $0E
	sndlen 21
	sndnote $0A
	sndlen 14
	sndnote $0E
	sndlen 7
	sndnote $0F
	sndlen 14
	sndnote $0C
	sndlen 14
	sndnote $05
	sndlen 7
	sndnote $03
	sndnote $05
	sndlen 14
	sndnote $11
	sndlen 7
	sndnote $0C
	sndnote $03
	sndnote $05
	sndnote $0C
	sndnote $03
	sndnote $05
	sndnote $0F
	sndnote $05
	sndnote $08
	sndlen 14
	sndnote $14
	sndlen 7
	sndnote $13
	sndnote $05
	sndnote $08
	sndnote $08
	sndnote $0A
	sndnote $0F
	sndlen 14
	sndnote $14
	sndlen 7
	sndnote $0D
	sndnote $13
	sndnote $08
	sndnote $05
	sndnote $08
	sndnote $0A
	sndlen 14
	sndnote $16
	sndlen 7
	sndnote $14
	sndnote $11
	sndnote $0F
	sndnote $0A
	sndnote $05
	sndnote $0A
	sndlen 14
	sndnote $11
	sndlen 7
	sndnote $0A
	sndnote $16
	sndnote $0A
	sndnote $14
	sndnote $16
	sndnote $1B
	sndnote $05
	sndnote $13
	sndlen 14
	sndnote $0C
	sndlen 7
	sndnote $06
	sndnote $05
	sndnote $07
	sndch3len $00
	sndnote $0F
	sndlen 84
	sndlenpre $07
	sndch3len $1E
	sndnote $13
	sndlen 7
	sndnote $0C
	sndnote $13
	sndlen 14
	sndnote $05
	sndlen 21
	sndnote $05
	sndlen 35
	sndendch
SndData_BGM_In1996_Ch4:
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndcall .call0
	sndcall .call1
	sndendch
.call0:
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 14
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 21
	sndch4 3, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 28
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 28
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 21
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 21
	sndch4 3, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 28
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndch4 3, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 21
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 28
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndch4 3, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 21
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 21
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 7
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 7
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndret
.call1:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndloopcnt $00, 2, .call1
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 21
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 7
	sndch4 1, 0, 0
	sndlen 7
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 7
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 7
	sndch4 2, 0, 6
	sndlen 7
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 7
	sndch4 1, 0, 0
	sndlen 7
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 7
	sndch4 3, 0, 2
	sndlen 7
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 7
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 3
	sndch4 1, 0, 0
	sndlen 4
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 7
	sndch4 2, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 35
	sndret
SndHeader_BGM_MrKarate:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_MrKarate_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_MrKarate_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_MrKarate_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_MrKarate_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_BGM_MrKarate_Ch1:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH1R|SNDOUT_CH1L
	sndnr11 3, 0
	sndcall .call0
.main:
	sndcall .call1
	sndcall .call2
	sndcall .call3
	sndcall .call0
	sndloop .main
.call0:
	sndenv 7, SNDENV_DEC, 5
	sndnr11 3, 0
	sndnote $24
	sndlen 20
	sndnote $20
	sndlen 10
	sndnote $1D
	sndnote $27
	sndnote $1D
	sndnote $29
	sndnote $1D
	sndnote $24
	sndlen 20
	sndnote $20
	sndlen 10
	sndnote $1D
	sndnote $22
	sndnote $1B
	sndnote $1F
	sndnote $16
	sndloopcnt $00, 2, .call0
	sndret
.call1:
	sndnote $27
	sndlen 20
	sndnote $22
	sndlen 2
	sndnote $00
	sndlen 3
	sndnote $22
	sndlen 5
	sndnote $2B
	sndlen 10
	sndnote $22
	sndlen 2
	sndnote $00
	sndlen 3
	sndnote $22
	sndlen 5
	sndnote $27
	sndlen 10
	sndnote $22
	sndlen 2
	sndnote $00
	sndlen 3
	sndnote $22
	sndlen 5
	sndnote $1B
	sndlen 10
	sndnote $27
	sndlen 20
	sndnote $22
	sndlen 2
	sndnote $00
	sndlen 3
	sndnote $22
	sndlen 5
	sndnote $2B
	sndlen 10
	sndnote $22
	sndlen 2
	sndnote $00
	sndlen 3
	sndnote $22
	sndlen 5
	sndnote $27
	sndnote $26
	sndnote $25
	sndnote $24
	sndnote $23
	sndnote $22
	sndloopcnt $00, 4, .call1
	sndret
.call2:
	sndenv 7, SNDENV_INC, 0
	sndnr11 2, 0
	sndnote $22
	sndlen 40
	sndnote $24
	sndlen 30
	sndnote $20
	sndnote $1B
	sndlen 40
	sndnote $22
	sndlen 10
	sndnote $24
	sndnote $25
	sndlen 40
	sndlenpre $0A
	sndnote $1B
	sndnote $27
	sndnote $25
	sndnote $24
	sndlenpre $28
	sndlenpre $0A
	sndnote $25
	sndnote $27
	sndnote $28
	sndlen 40
	sndnote $2A
	sndlen 30
	sndnote $28
	sndlen 10
	sndnote $27
	sndnote $00
	sndnote $24
	sndnote $20
	sndnote $1B
	sndlen 60
	sndenv 7, SNDENV_DEC, 7
	sndnr11 3, 0
	sndnote $1B
	sndlen 5
	sndnote $00
	sndnote $1B
	sndlen 10
	sndnote $1A
	sndnote $1B
	sndnote $1A
	sndnote $1B
	sndret
.call3:
	sndenv 7, SNDENV_INC, 0
	sndnr11 3, 0
	sndnote $22
	sndlen 20
	sndnote $21
	sndlen 10
	sndnote $22
	sndnote $25
	sndlen 20
	sndnote $19
	sndlen 5
	sndnote $00
	sndnote $24
	sndlen 10
	sndnote $27
	sndlen 30
	sndnote $1B
	sndlen 5
	sndnote $00
	sndnote $29
	sndlen 10
	sndnote $00
	sndnote $2C
	sndnote $00
	sndnote $29
	sndlen 80
	sndnote $27
	sndlen 5
	sndnote $29
	sndnote $27
	sndlen 30
	sndnote $25
	sndlen 5
	sndnote $27
	sndnote $25
	sndlen 20
	sndnote $00
	sndlen 10
	sndnote $24
	sndnote $25
	sndnote $24
	sndnote $20
	sndnote $1B
	sndnote $00
	sndnote $24
	sndlen 30
	sndlenpre $50
	sndenv 1, SNDENV_DEC, 1
	sndnote $01
	sndlen 80
	sndlenpre $3C
	sndlenpre $0A
	sndloopcnt $00, 2, .call3
	sndret
SndData_BGM_MrKarate_Ch2:
	sndenv 6, SNDENV_DEC, 7
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 1, 0
	sndcall .call0
.main:
	sndcall .call1
	sndcall .call2
	sndcall .call0
	sndcall .call0
	sndcall .call0
	sndcall .call0
	sndcall .call0
	sndloop .main
.call0:
	sndnote $1D
	sndlen 20
	sndnote $19
	sndlen 10
	sndnote $16
	sndnote $20
	sndnote $16
	sndnote $22
	sndnote $16
	sndnote $1D
	sndlen 20
	sndnote $19
	sndlen 10
	sndnote $16
	sndnote $1B
	sndnote $14
	sndnote $18
	sndnote $0F
	sndloopcnt $00, 2, .call0
	sndret
.call1:
	sndnote $20
	sndlen 20
	sndnote $1B
	sndlen 2
	sndnote $00
	sndlen 3
	sndnote $1B
	sndlen 5
	sndnote $24
	sndlen 10
	sndnote $1B
	sndlen 2
	sndnote $00
	sndlen 3
	sndnote $1B
	sndlen 5
	sndnote $20
	sndlen 10
	sndnote $1B
	sndlen 2
	sndnote $00
	sndlen 3
	sndnote $1B
	sndlen 5
	sndnote $14
	sndlen 10
	sndnote $20
	sndlen 20
	sndnote $1B
	sndlen 2
	sndnote $00
	sndlen 3
	sndnote $1B
	sndlen 5
	sndnote $24
	sndlen 10
	sndnote $1B
	sndlen 2
	sndnote $00
	sndlen 3
	sndnote $1B
	sndlen 5
	sndnote $20
	sndnote $1F
	sndnote $1E
	sndnote $1D
	sndnote $1C
	sndnote $1B
	sndloopcnt $00, 4, .call1
	sndret
.call2:
	sndenv 6, SNDENV_INC, 0
	sndnote $1D
	sndlen 10
	sndlenpre $28
	sndnote $1F
	sndnote $20
	sndnote $22
	sndlen 30
	sndnote $23
	sndlen 10
	sndlenpre $28
	sndnote $1C
	sndnote $20
	sndlen 60
	sndnote $24
	sndlen 10
	sndnote $25
	sndlen 30
	sndnote $23
	sndlen 20
	sndnote $21
	sndnote $1C
	sndlen 10
	sndnote $24
	sndlenpre $50
	sndenv 6, SNDENV_DEC, 7
	sndnote $00
	sndlen 10
	sndnote $24
	sndlen 5
	sndnote $00
	sndnote $24
	sndlen 10
	sndnote $23
	sndnote $24
	sndnote $23
	sndnote $24
	sndret
SndData_BGM_MrKarate_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH3R|SNDOUT_CH3L
	sndwave $04
	sndch3len $00
	sndcall .call0
.main:
	sndcall .call1
	sndcall .call2
	sndcall .call3
	sndcall .call4
	sndcall .call3
	sndloop .main
.call0:
	sndnote $16
	sndlen 10
	sndlenpre $3C
	sndnote $00
	sndlen 10
	sndnote $19
	sndlen 30
	sndnote $00
	sndlen 10
	sndnote $11
	sndnote $00
	sndnote $14
	sndnote $00
	sndnote $16
	sndlenpre $3C
	sndnote $00
	sndlen 10
	sndnote $19
	sndlen 30
	sndnote $00
	sndlen 10
	sndnote $11
	sndnote $00
	sndnote $14
	sndnote $00
	sndret
.call1:
	sndch3len $3C
	sndnote $16
	sndlen 20
	sndch3len $1E
	sndnote $13
	sndlen 10
	sndnote $14
	sndnote $15
	sndnote $16
	sndnote $13
	sndnote $14
	sndch3len $3C
	sndnote $16
	sndlen 20
	sndch3len $1E
	sndnote $0F
	sndlen 10
	sndnote $1B
	sndnote $0F
	sndnote $16
	sndnote $0F
	sndnote $14
	sndloopcnt $00, 4, .call1
	sndret
.call2:
	sndch3len $00
	sndnote $19
	sndlen 40
	sndch3len $1E
	sndnote $14
	sndlen 10
	sndnote $19
	sndnote $14
	sndnote $19
	sndch3len $00
	sndnote $18
	sndlen 60
	sndch3len $1E
	sndnote $1A
	sndlen 10
	sndnote $1B
	sndch3len $00
	sndnote $1C
	sndlen 40
	sndch3len $1E
	sndnote $17
	sndlen 10
	sndnote $1C
	sndnote $17
	sndnote $1C
	sndch3len $00
	sndnote $1B
	sndlen 60
	sndch3len $1E
	sndnote $1D
	sndlen 10
	sndnote $1E
	sndch3len $00
	sndnote $1F
	sndlen 40
	sndch3len $1E
	sndnote $1A
	sndlen 10
	sndnote $1F
	sndnote $1A
	sndnote $1F
	sndch3len $3C
	sndnote $20
	sndlen 20
	sndch3len $1E
.call2b:
	sndnote $14
	sndlen 10
	sndloopcnt $00, 8, .call2b
	sndnote $0F
	sndnote $14
	sndnote $13
	sndnote $14
	sndnote $13
	sndnote $14
	sndret
.call3:
	sndch3len $3C
	sndnote $16
	sndlen 20
	sndch3len $1E
	sndnote $16
	sndlen 10
	sndnote $16
	sndnote $16
	sndnote $16
	sndnote $16
	sndnote $16
	sndch3len $3C
	sndnote $19
	sndlen 20
	sndch3len $1E
	sndnote $19
	sndlen 10
	sndnote $19
	sndch3len $3C
	sndnote $11
	sndlen 20
	sndch3len $1E
	sndnote $0F
	sndlen 10
	sndnote $14
	sndloopcnt $00, 4, .call3
	sndret
.call4:
	sndch3len $3C
	sndnote $12
	sndlen 20
	sndch3len $19
	sndnote $12
	sndlen 10
	sndnote $12
	sndnote $12
	sndnote $12
	sndnote $12
	sndnote $12
	sndnote $12
	sndnote $12
	sndnote $12
	sndnote $12
	sndnote $12
	sndnote $0D
	sndnote $14
	sndnote $0D
	sndloopcnt $00, 2, .call4
	sndret
SndData_BGM_MrKarate_Ch4:
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndcall .call0
.main:
	sndcall .call1
	sndcall .call2
	sndcall .call3
	sndcall .call2
	sndcall .call4
	sndcall .call4
	sndcall .call5
	sndcall .call2
	sndloop .main
.call0:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 30
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 10
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 10
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 3
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 4
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 3
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 3
	sndch4 2, 0, 4
	sndlen 4
	sndch4 2, 0, 4
	sndlen 3
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 5
	sndch4 3, 0, 2
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndret
.call1:
	sndenv 0, SNDENV_DEC, 1
	sndch4 2, 0, 4
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndloopcnt $00, 7, .call1
	sndret
.call2:
	sndenv 0, SNDENV_DEC, 1
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 5
	sndch4 2, 0, 6
	sndlen 5
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 5
	sndch4 1, 0, 0
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndret
.call3:
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 20
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndloopcnt $00, 6, .call3
	sndret
.call4:
	sndenv 0, SNDENV_DEC, 1
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 20
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndloopcnt $00, 4, .call4
	sndret
.call5:
	sndenv 0, SNDENV_DEC, 1
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 20
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 0, SNDENV_DEC, 1
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 3
	sndch4 2, 0, 4
	sndlen 4
	sndch4 2, 0, 4
	sndlen 3
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndret
SndHeader_BGM_BigShot:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_BigShot_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_BigShot_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_BigShot_Ch3 ; Data ptr
	db $0C ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_BigShot_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_BGM_BigShot_Ch1:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH1R|SNDOUT_CH1L
	sndnr11 2, 0
.main:
	sndenv 7, SNDENV_DEC, 7
	sndnr11 2, 0
	sndcall .call0
	sndcall .call1
	sndcall .call2
	sndloop .main
.call0:
	sndnote $20
	sndlen 16
	sndnote $25
	sndlen 8
	sndlenpre $48
	sndnote $20
	sndlen 16
	sndnote $23
	sndlen 8
	sndlenpre $48
	sndnote $20
	sndlen 16
	sndnote $1E
	sndlen 8
	sndlenpre $48
	sndnote $25
	sndlen 16
	sndnote $27
	sndlen 48
	sndnote $25
	sndlen 8
	sndenv 1, SNDENV_DEC, 1
	sndnote $01
	sndlen 24
	sndenv 7, SNDENV_DEC, 7
	sndnote $2A
	sndlen 16
	sndnote $29
	sndlen 8
	sndlenpre $28
	sndret
.call1:
	sndnote $2C
	sndlen 8
	sndenv 1, SNDENV_DEC, 1
	sndnote $08
	sndlen 96
	sndlenpre $10
	sndenv 7, SNDENV_DEC, 7
	sndnote $1B
	sndlen 8
	sndnote $27
	sndlen 16
	sndnote $25
	sndlen 8
	sndlenpre $48
	sndnote $2A
	sndlen 16
	sndnote $2F
	sndlen 8
	sndret
.call2:
	sndenv 1, SNDENV_DEC, 1
	sndnr11 3, 0
	sndnote $06
	sndlen 48
	sndenv 7, SNDENV_INC, 0
	sndnote $1E
	sndlen 16
	sndnote $20
	sndnote $1E
	sndnote $1D
	sndlen 96
	sndlenpre $30
	sndenv 1, SNDENV_DEC, 1
	sndnote $05
	sndlen 40
	sndenv 7, SNDENV_INC, 0
	sndnote $1D
	sndlen 8
	sndnote $1E
	sndlen 48
	sndnote $1B
	sndlen 40
	sndnote $22
	sndlen 8
	sndlenpre $48
	sndenv 1, SNDENV_DEC, 1
	sndnote $0A
	sndlen 24
	sndenv 7, SNDENV_INC, 0
	sndnote $23
	sndlen 32
	sndnote $00
	sndlen 8
	sndnote $22
	sndlen 40
	sndnote $00
	sndlen 8
	sndnote $1E
	sndlenpre $30
	sndenv 1, SNDENV_DEC, 1
	sndnote $06
	sndlen 24
	sndenv 7, SNDENV_INC, 0
	sndnote $22
	sndlen 16
	sndnote $20
	sndlen 8
	sndlenpre $60
	sndenv 1, SNDENV_DEC, 1
	sndnr11 2, 0
	sndnote $08
	sndlen 16
	sndenv 7, SNDENV_DEC, 7
	sndnote $29
	sndlen 8
	sndnote $2A
	sndnote $29
	sndnote $27
	sndnote $25
	sndlen 40
	sndnote $27
	sndlen 8
	sndenv 1, SNDENV_DEC, 1
	sndnote $03
	sndlen 48
	sndenv 7, SNDENV_DEC, 7
	sndnote $2E
	sndlen 16
	sndenv 1, SNDENV_DEC, 1
	sndnote $0A
	sndlen 24
	sndenv 7, SNDENV_INC, 0
	sndnr11 3, 0
	sndnote $19
	sndlen 8
	sndnote $1B
	sndlen 32
	sndenv 1, SNDENV_DEC, 1
	sndnote $03
	sndlen 16
	sndenv 7, SNDENV_INC, 0
	sndnote $22
	sndnote $20
	sndlen 8
	sndnote $1E
	sndlen 16
	sndnote $1D
	sndlen 8
	sndlenpre $30
	sndlenpre $08
	sndenv 1, SNDENV_DEC, 1
	sndnote $05
	sndlen 16
	sndenv 7, SNDENV_DEC, 7
	sndnr11 2, 0
	sndnote $2A
	sndlen 16
	sndnote $29
	sndlen 24
	sndenv 7, SNDENV_INC, 0
	sndnr11 3, 0
	sndnote $1E
	sndlen 8
	sndnote $1D
	sndlen 16
	sndnote $1B
	sndlen 8
	sndnote $1D
	sndlen 24
	sndnote $19
	sndnote $17
	sndlen 48
	sndnote $1E
	sndenv 1, SNDENV_DEC, 1
	sndnr11 2, 0
	sndnote $0B
	sndlen 24
	sndenv 7, SNDENV_DEC, 3
	sndnote $23
	sndlen 8
	sndnote $22
	sndnote $20
	sndnote $25
	sndlen 16
	sndnote $20
	sndnote $22
	sndenv 7, SNDENV_DEC, 5
	sndnote $1B
	sndlenpre $48
	sndnote $1D
	sndlen 24
	sndlenpre $48
	sndlenpre $08
	sndnote $1C
	sndlen 16
	sndlenpre $48
	sndnote $1E
	sndlen 24
	sndlenpre $30
	sndlenpre $08
	sndret
SndData_BGM_BigShot_Ch2:
	sndenv 1, SNDENV_DEC, 1
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 2, 0
	sndenv 1, SNDENV_DEC, 1
	sndnote $01
	sndlen 24
.main:
	sndcall .call0
	sndcall .call1
	sndcall .call0
	sndcall .call2
	sndcall .call3
	sndcall .call4
	sndcall .call5
	sndcall .call6
	sndcall .call6
	sndcall .call7
	sndcall .call6
	sndcall .call8
	sndloop .main
.call0:
	sndenv 5, SNDENV_DEC, 4
	sndnote $1D
	sndlen 16
	sndnote $19
	sndlen 8
	sndnote $20
	sndlen 16
	sndnote $1B
	sndlen 8
	sndnote $23
	sndlen 16
	sndnote $19
	sndlen 8
	sndnote $20
	sndlen 16
	sndnote $1B
	sndlen 24
	sndnote $17
	sndlen 8
	sndnote $20
	sndlen 16
	sndnote $1D
	sndlen 8
	sndnote $23
	sndlen 16
	sndnote $1B
	sndlen 8
	sndnote $17
	sndnote $19
	sndnote $16
	sndlen 24
	sndnote $12
	sndlen 8
	sndnote $19
	sndlen 16
	sndnote $16
	sndlen 8
	sndnote $1C
	sndlen 16
	sndnote $16
	sndlen 8
	sndnote $12
	sndlen 16
	sndnote $21
	sndlen 24
	sndret
.call1:
	sndnote $17
	sndlen 8
	sndnote $21
	sndlen 16
	sndnote $1B
	sndlen 8
	sndnote $20
	sndlen 16
	sndnote $1B
	sndlen 8
	sndnote $17
	sndlen 24
	sndret
.call2:
	sndlenpre $48
	sndlenpre $08
	sndret
.call3:
	sndenv 4, SNDENV_DEC, 2
	sndnote $2C
	sndlen 8
	sndnote $25
	sndnote $29
	sndnote $25
	sndnote $33
	sndnote $25
	sndnote $29
	sndnote $25
	sndnote $2C
	sndnote $25
	sndnote $33
	sndnote $29
	sndloopcnt $00, 2, .call3
	sndret
.call4:
	sndnote $2A
	sndlen 8
	sndnote $25
	sndnote $2E
	sndnote $25
	sndnote $31
	sndnote $25
	sndnote $2A
	sndnote $25
	sndnote $2E
	sndnote $25
	sndnote $31
	sndnote $25
	sndloopcnt $00, 2, .call4
	sndret
.call5:
	sndenv 5, SNDENV_DEC, 7
	sndnote $1B
	sndlen 40
	sndnote $1D
	sndlen 48
	sndnote $22
	sndlen 24
	sndnote $20
	sndlen 8
	sndnote $1B
	sndlen 16
	sndnote $25
	sndlen 32
	sndnote $24
	sndlen 16
	sndnote $23
	sndlen 8
	sndlenpre $60
	sndlenpre $60
	sndret
.call6:
	sndenv 4, SNDENV_DEC, 2
	sndnote $20
	sndlen 8
	sndnote $1B
	sndlen 4
	sndnote $19
	sndnote $20
	sndlen 8
	sndnote $2A
	sndlen 16
	sndnote $1B
	sndlen 8
	sndloopcnt $00, 2, .call6
	sndret
.call7:
	sndnote $20
	sndlen 8
	sndnote $1D
	sndlen 4
	sndnote $1B
	sndnote $20
	sndlen 8
	sndnote $2A
	sndlen 16
	sndnote $1B
	sndlen 8
	sndloopcnt $00, 4, .call7
	sndret
.call8:
	sndenv 1, SNDENV_DEC, 1
	sndnote $06
	sndlen 24
	sndenv 5, SNDENV_DEC, 3
	sndnote $1E
	sndlen 8
	sndnote $1D
	sndnote $1B
	sndnote $20
	sndlen 16
	sndnote $1B
	sndnote $1D
	sndenv 5, SNDENV_DEC, 5
	sndnote $17
	sndlen 16
	sndlenpre $48
	sndnote $19
	sndlen 24
	sndlenpre $48
	sndlenpre $08
	sndnote $19
	sndlen 16
	sndlenpre $48
	sndnote $1B
	sndlen 24
	sndlenpre $48
	sndlenpre $08
	sndret
SndData_BGM_BigShot_Ch3:
	sndenvch3 0
	sndenach SNDOUT_CH3R|SNDOUT_CH3L
	sndwave $02
	sndch3len $3C
	sndnote $01
	sndlen 24
.main:
	sndenvch3 2
	sndcall .call0
	sndcall .call1
	sndcall .call0
	sndcall .call2
	sndcall .call3
	sndloop .main
.call0:
	sndnote $0D
	sndlen 16
	sndnote $0C
	sndlen 8
	sndnote $0D
	sndlen 24
	sndnote $05
	sndlen 16
	sndnote $08
	sndlen 8
	sndnote $0D
	sndlen 16
	sndnote $0B
	sndlen 24
	sndnote $0A
	sndlen 8
	sndnote $0B
	sndlen 24
	sndnote $0B
	sndlen 16
	sndnote $03
	sndlen 8
	sndnote $05
	sndlen 16
	sndnote $06
	sndlen 24
	sndnote $05
	sndlen 8
	sndnote $06
	sndlen 24
	sndnote $06
	sndlen 16
	sndnote $05
	sndlen 8
	sndnote $0A
	sndlen 16
	sndnote $0B
	sndlen 24
	sndret
.call1:
	sndnote $0A
	sndlen 8
	sndnote $0B
	sndlen 16
	sndnote $06
	sndlen 8
	sndnote $0B
	sndlen 16
	sndnote $0A
	sndlen 8
	sndnote $0B
	sndlen 24
	sndret
.call2:
	sndlenpre $48
	sndlenpre $08
	sndret
.call3:
	sndnote $0A
	sndlen 24
	sndnote $0A
	sndnote $0A
	sndlen 16
	sndnote $05
	sndlen 8
	sndnote $0A
	sndlen 24
	sndloopcnt $00, 2, .call3
	sndnote $0B
	sndlen 24
	sndnote $0B
	sndnote $0B
	sndlen 16
	sndnote $06
	sndlen 8
	sndnote $0B
	sndlen 24
	sndnote $0B
	sndlen 24
	sndnote $0B
	sndnote $0B
	sndlen 16
	sndnote $06
	sndlen 8
	sndnote $0B
	sndlen 16
	sndnote $0B
	sndlen 8
	sndnote $08
	sndlen 16
	sndnote $07
	sndlen 8
	sndnote $08
	sndlen 16
	sndnote $0A
	sndlen 24
	sndnote $08
	sndlen 8
	sndnote $0A
	sndlen 16
	sndnote $0B
	sndlen 24
	sndnote $0A
	sndlen 8
	sndnote $0B
	sndlen 24
	sndnote $0C
	sndlen 16
	sndnote $06
	sndlen 8
	sndnote $0C
	sndlen 16
	sndnote $0D
	sndlen 24
	sndnote $0C
	sndlen 8
	sndnote $0D
	sndlen 24
	sndnote $0D
	sndlen 16
	sndnote $08
	sndlen 8
	sndnote $0A
	sndlen 16
	sndnote $0D
	sndlen 24
	sndnote $0C
	sndlen 8
	sndnote $0D
	sndlen 16
	sndnote $08
	sndlen 8
	sndnote $0D
	sndnote $08
	sndnote $0D
	sndnote $0C
	sndlen 16
	sndnote $0B
	sndlen 32
	sndnote $0B
	sndlen 24
	sndnote $0B
	sndlen 16
	sndnote $06
	sndlen 8
	sndnote $0B
	sndlen 24
	sndnote $0B
	sndlen 24
	sndnote $0B
	sndnote $0B
	sndlen 8
	sndnote $06
	sndnote $0B
	sndnote $0C
	sndlen 16
	sndnote $0D
	sndlen 32
	sndnote $0D
	sndlen 24
	sndnote $0D
	sndlen 16
	sndnote $08
	sndlen 8
	sndnote $0D
	sndlen 16
	sndnote $08
	sndlen 8
	sndnote $0D
	sndlen 24
	sndnote $0D
	sndnote $0D
	sndlen 16
	sndnote $08
	sndlen 8
	sndnote $0D
	sndlen 16
	sndnote $06
	sndlen 8
	sndnote $0B
	sndlen 24
	sndnote $0B
	sndlen 16
	sndnote $0A
	sndlen 8
	sndnote $0B
	sndlen 16
	sndnote $06
	sndlen 8
	sndnote $08
	sndlen 16
	sndnote $0B
	sndlenpre $48
	sndlenpre $10
	sndnote $08
	sndlenpre $48
	sndnote $0A
	sndlen 16
	sndlenpre $48
	sndlenpre $10
	sndnote $09
	sndlenpre $48
	sndnote $0B
	sndlen 16
	sndlenpre $48
	sndlenpre $08
	sndnote $0D
	sndret
SndData_BGM_BigShot_Ch4:
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 24
.main:
	sndcall .call0
	sndcall .call1
	sndcall .call1
	sndcall .call2
	sndcall .call3
	sndloop .main
.call0:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 16
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 16
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 24
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 16
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 8
	sndloopcnt $00, 6, .call0
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 16
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 16
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 24
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 16
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 96
	sndlenpre $08
	sndret
.call1:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 16
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 16
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 8
	sndloopcnt $00, 3, .call1
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 8
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 16
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 8
	sndret
.call2:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 16
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 16
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 24
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 16
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 24
	sndch4 3, 0, 6
	sndlen 8
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 8
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 8
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 8
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 8
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 16
	sndch4 3, 0, 6
	sndlen 24
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 16
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 8
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 8
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 16
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 24
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 16
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 8
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 8
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 8
	sndch4 2, 0, 4
	sndlen 8
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 8
	sndret
.call3:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 8
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 8
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 8
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 8
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 8
	sndch4 3, 0, 6
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 8
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 8
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 8
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 8
	sndloopcnt $00, 5, .call3
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 24
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 8
	sndch4 2, 0, 4
	sndlen 8
	sndch4 2, 0, 4
	sndlen 8
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 4
	sndch4 2, 0, 6
	sndlen 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 8
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 4
	sndch4 1, 0, 0
	sndlen 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 8
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 4
	sndch4 3, 0, 2
	sndlen 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 8
	sndch4 3, 0, 6
	sndlen 40
	sndch4 3, 0, 6
	sndlen 8
	sndch4 3, 0, 6
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 8
	sndch4 2, 0, 4
	sndlen 8
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 16
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 24
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 8
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 8
	sndch4 2, 0, 4
	sndlen 8
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 4
	sndch4 1, 0, 0
	sndlen 4
	sndch4 1, 0, 0
	sndlen 8
	sndch4 1, 0, 0
	sndlen 8
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 4
	sndch4 2, 0, 6
	sndlen 4
	sndch4 2, 0, 6
	sndlen 8
	sndch4 2, 0, 6
	sndlen 8
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 8
	sndch4 2, 0, 4
	sndlen 8
	sndch4 2, 0, 4
	sndlen 8
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 8
	sndch4 3, 0, 6
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 8
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 4
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 4
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 8
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 8
	sndch4 3, 0, 6
	sndlen 8
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 8
	sndlenpre $30
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 8
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 16
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 16
	sndch4 2, 0, 4
	sndlen 8
	sndret
SndHeader_BGM_Protector:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_Protector_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_Protector_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_Protector_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_Protector_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_BGM_Protector_Ch1:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH1R|SNDOUT_CH1L
	sndnr11 2, 0
	sndcall .call0
	sndcall .call1
	sndloop SndData_BGM_Protector_Ch1
.call0:
	sndenv 8, SNDENV_DEC, 4
	sndnote $1E
	sndlen 10
	sndnote $20
	sndnote $24
	sndnote $29
	sndnote $1E
	sndnote $20
	sndnote $24
	sndnote $29
	sndenv 4, SNDENV_DEC, 4
	sndnote $1E
	sndnote $20
	sndnote $24
	sndnote $29
	sndnote $1E
	sndnote $20
	sndnote $24
	sndnote $29
	sndenv 8, SNDENV_DEC, 4
	sndnote $1F
	sndnote $20
	sndnote $24
	sndnote $29
	sndnote $1F
	sndnote $20
	sndnote $24
	sndnote $29
	sndenv 4, SNDENV_DEC, 4
	sndnote $1F
	sndnote $20
	sndnote $24
	sndnote $29
	sndnote $1F
	sndnote $20
	sndnote $24
	sndnote $29
	sndloopcnt $00, 4, .call0
	sndret
.call1:
	sndenv 8, SNDENV_DEC, 4
	sndnote $2A
	sndlen 10
	sndnote $2E
	sndnote $35
	sndnote $2A
	sndnote $2E
	sndnote $35
	sndenv 4, SNDENV_DEC, 4
	sndnote $2A
	sndnote $2E
	sndnote $35
	sndnote $2A
	sndnote $2E
	sndnote $35
	sndenv 2, SNDENV_DEC, 7
	sndnote $2A
	sndnote $2E
	sndnote $35
	sndlen 20
	sndenv 8, SNDENV_DEC, 4
	sndnote $29
	sndlen 10
	sndnote $2D
	sndnote $35
	sndnote $29
	sndnote $2D
	sndnote $35
	sndenv 4, SNDENV_DEC, 4
	sndnote $29
	sndnote $2D
	sndnote $35
	sndnote $29
	sndnote $2D
	sndnote $35
	sndenv 2, SNDENV_DEC, 7
	sndnote $29
	sndnote $2D
	sndnote $35
	sndlen 20
	sndloopcnt $00, 3, .call1
	sndenv 8, SNDENV_DEC, 4
	sndnote $2A
	sndlen 10
	sndnote $2E
	sndnote $35
	sndnote $2A
	sndnote $2E
	sndnote $35
	sndenv 4, SNDENV_DEC, 4
	sndnote $2A
	sndnote $2E
	sndnote $35
	sndnote $2A
	sndnote $2E
	sndnote $35
	sndenv 2, SNDENV_DEC, 7
	sndnote $2A
	sndnote $2E
	sndnote $35
	sndlen 20
	sndenv 8, SNDENV_DEC, 4
	sndnote $2C
	sndlen 10
	sndnote $30
	sndnote $38
	sndnote $2C
	sndnote $30
	sndnote $38
	sndenv 4, SNDENV_DEC, 4
	sndnote $2D
	sndnote $30
	sndnote $39
	sndnote $2D
	sndnote $30
	sndnote $39
	sndenv 2, SNDENV_DEC, 7
	sndnote $2D
	sndnote $30
	sndnote $39
	sndlen 20
	sndret
SndData_BGM_Protector_Ch2:
	sndenv 3, SNDENV_DEC, 4
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 2, 0
	sndnote $00
	sndlen 15
.main:
	sndcall .call0
	sndcall .call1
	sndloop .main
.call0:
	sndenv 4, SNDENV_DEC, 7
	sndnote $1E
	sndlen 10
	sndnote $20
	sndnote $24
	sndnote $29
	sndnote $1E
	sndnote $20
	sndnote $24
	sndnote $29
	sndenv 2, SNDENV_DEC, 7
	sndnote $1E
	sndnote $20
	sndnote $24
	sndnote $29
	sndnote $1E
	sndnote $20
	sndnote $24
	sndnote $29
	sndenv 4, SNDENV_DEC, 7
	sndnote $1F
	sndnote $20
	sndnote $24
	sndnote $29
	sndnote $1F
	sndnote $20
	sndnote $24
	sndnote $29
	sndenv 2, SNDENV_DEC, 7
	sndnote $1F
	sndnote $20
	sndnote $24
	sndnote $29
	sndnote $1F
	sndnote $20
	sndnote $24
	sndnote $29
	sndloopcnt $00, 4, .call0
	sndret
.call1:
	sndenv 4, SNDENV_DEC, 7
	sndnote $2A
	sndlen 10
	sndnote $2E
	sndnote $35
	sndnote $2A
	sndnote $2E
	sndnote $35
	sndenv 2, SNDENV_DEC, 7
	sndnote $2A
	sndnote $2E
	sndnote $35
	sndnote $2A
	sndnote $2E
	sndnote $35
	sndenv 1, SNDENV_DEC, 7
	sndnote $2A
	sndnote $2E
	sndnote $35
	sndlen 20
	sndenv 4, SNDENV_DEC, 7
	sndnote $29
	sndlen 10
	sndnote $2D
	sndnote $35
	sndnote $29
	sndnote $2D
	sndnote $35
	sndenv 2, SNDENV_DEC, 7
	sndnote $29
	sndnote $2D
	sndnote $35
	sndnote $29
	sndnote $2D
	sndnote $35
	sndenv 1, SNDENV_DEC, 7
	sndnote $29
	sndnote $2D
	sndnote $35
	sndlen 20
	sndloopcnt $00, 3, .call1
	sndenv 4, SNDENV_DEC, 7
	sndnote $2A
	sndlen 10
	sndnote $2E
	sndnote $35
	sndnote $2A
	sndnote $2E
	sndnote $35
	sndenv 2, SNDENV_DEC, 7
	sndnote $2A
	sndnote $2E
	sndnote $35
	sndnote $2A
	sndnote $2E
	sndnote $35
	sndenv 1, SNDENV_DEC, 7
	sndnote $2A
	sndnote $2E
	sndnote $35
	sndlen 20
	sndenv 4, SNDENV_DEC, 7
	sndnote $2C
	sndlen 10
	sndnote $30
	sndnote $38
	sndnote $2C
	sndnote $30
	sndnote $38
	sndenv 2, SNDENV_DEC, 7
	sndnote $2D
	sndnote $30
	sndnote $39
	sndnote $2D
	sndnote $30
	sndnote $39
	sndenv 1, SNDENV_DEC, 7
	sndnote $2D
	sndnote $30
	sndnote $39
	sndlen 20
	sndret
SndData_BGM_Protector_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH3R|SNDOUT_CH3L
	sndwave $02
	sndch3len $00
	sndcall .call0
	sndcall .call1
	sndloop SndData_BGM_Protector_Ch3
.call0:
	sndnote $12
	sndlen 80
	sndlenpre $50
	sndch3len $14
	sndnote $11
	sndlen 10
	sndch3len $00
	sndnote $11
	sndlen 120
	sndlenpre $1E
	sndloopcnt $00, 4, .call0
	sndret
.call1:
	sndch3len $1E
	sndnote $12
	sndlen 30
	sndch3len $00
	sndnote $12
	sndlen 120
	sndlenpre $0A
	sndch3len $1E
	sndnote $11
	sndlen 30
	sndch3len $00
	sndnote $11
	sndlen 120
	sndlenpre $0A
	sndloopcnt $00, 3, .call1
	sndch3len $1E
	sndnote $12
	sndlen 30
	sndch3len $00
	sndnote $12
	sndlen 120
	sndlenpre $0A
	sndch3len $1E
	sndnote $14
	sndlen 30
	sndch3len $00
	sndnote $14
	sndlen 40
	sndlenpre $0A
	sndnote $15
	sndlen 80
	sndret
SndData_BGM_Protector_Ch4:
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndcall .call0
	sndcall .call1
	sndcall .call2
	sndloop SndData_BGM_Protector_Ch4
.call0:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 80
	sndlenpre $50
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 120
	sndlenpre $1E
	sndch4 3, 0, 6
	sndlen 80
	sndlenpre $50
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 80
	sndlenpre $1E
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 30
	sndret
.call1:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 20
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 20
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 40
	sndch4 2, 0, 1
	sndlen 20
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 20
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 20
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 10
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 20
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 20
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 40
	sndch4 2, 0, 1
	sndlen 20
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 30
	sndloopcnt $00, 2, .call1
	sndret
.call2:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 30
	sndch4 3, 0, 6
	sndlen 120
	sndlenpre $0A
	sndloopcnt $00, 4, .call2
.call2b:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 10
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 20
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 20
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 20
	sndloopcnt $00, 4, .call2b
	sndret
SndHeader_BGM_ToTheSky:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_ToTheSky_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_ToTheSky_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_ToTheSky_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_ToTheSky_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_BGM_ToTheSky_Ch1:
	sndenv 7, SNDENV_INC, 0
	sndenach SNDOUT_CH1R|SNDOUT_CH1L
	sndnr11 3, 0
	sndnote $27
	sndlen 96
	sndlenpre $08
	sndnote $00
	sndnote $27
	sndnote $27
	sndnote $26
	sndlen 32
	sndenv 1, SNDENV_DEC, 1
	sndnote $02
	sndlen 96
	sndenv 7, SNDENV_INC, 0
	sndnote $27
	sndlen 96
	sndlenpre $08
	sndnote $00
	sndnote $27
	sndnote $27
	sndnote $29
	sndlen 32
	sndenv 1, SNDENV_DEC, 1
	sndnote $02
	sndlen 96
	sndenv 7, SNDENV_INC, 0
	sndnote $27
	sndlen 32
	sndnote $26
	sndlen 16
	sndnote $00
	sndnote $29
	sndlen 32
	sndnote $2A
	sndlen 16
	sndnote $00
	sndnote $2B
	sndlen 32
	sndnote $2C
	sndlen 16
	sndnote $00
	sndnote $2D
	sndlen 64
	sndnote $2E
	sndlen 64
	sndlenpre $40
	sndenv 1, SNDENV_DEC, 1
	sndnote $05
	sndlen 48
	sndenv 6, SNDENV_DEC, 7
	sndnote $11
	sndlen 8
	sndnote $11
	sndnote $11
	sndnote $00
	sndnote $11
	sndnote $11
	sndnote $11
	sndnote $00
	sndnote $11
	sndnote $11
	sndloop SndData_BGM_ToTheSky_Ch1
SndData_BGM_ToTheSky_Ch2:
	sndenv 5, SNDENV_INC, 0
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 2, 0
	sndnote $16
	sndlen 32
	sndnote $14
	sndnote $12
	sndnote $16
	sndnote $20
	sndnote $1A
	sndnote $1D
	sndnote $16
	sndnote $16
	sndnote $14
	sndnote $12
	sndnote $16
	sndnote $20
	sndnote $1A
	sndnote $1D
	sndnote $20
	sndnote $1E
	sndnote $1A
	sndlen 16
	sndnote $00
	sndnote $20
	sndlen 32
	sndnote $1B
	sndlen 16
	sndnote $00
	sndnote $22
	sndlen 32
	sndnote $1D
	sndlen 16
	sndnote $00
	sndnote $24
	sndlen 64
	sndnote $29
	sndlen 8
	sndnote $2A
	sndnote $29
	sndnote $26
	sndnote $29
	sndnote $23
	sndnote $26
	sndnote $20
	sndnote $23
	sndnote $1D
	sndnote $20
	sndnote $1B
	sndnote $1A
	sndnote $1D
	sndnote $20
	sndnote $1A
	sndnote $16
	sndnote $22
	sndnote $20
	sndnote $1B
	sndnote $1E
	sndnote $1A
	sndnote $1B
	sndnote $17
	sndnote $1A
	sndnote $16
	sndnote $14
	sndnote $16
	sndnote $12
	sndnote $16
	sndnote $11
	sndnote $12
	sndloop SndData_BGM_ToTheSky_Ch2
SndData_BGM_ToTheSky_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH3R|SNDOUT_CH3L
	sndwave $02
	sndch3len $19
	sndcall .call0
	sndcall .call1
	sndcall .call0
	sndcall .call2
	sndloop SndData_BGM_ToTheSky_Ch3
.call0:
	sndnote $1B
	sndlen 8
	sndnote $16
	sndnote $1B
	sndnote $1D
	sndnote $1E
	sndnote $16
	sndnote $1E
	sndnote $1B
	sndnote $22
	sndnote $1B
	sndnote $20
	sndnote $1B
	sndnote $1E
	sndnote $1B
	sndnote $1A
	sndnote $1B
	sndnote $1D
	sndnote $16
	sndnote $1A
	sndnote $16
	sndnote $20
	sndnote $16
	sndnote $1D
	sndnote $1E
	sndret
.call1:
	sndnote $26
	sndlen 8
	sndnote $1D
	sndnote $23
	sndnote $1D
	sndnote $22
	sndnote $1D
	sndnote $1A
	sndnote $16
	sndret
.call2:
	sndnote $26
	sndlen 8
	sndnote $27
	sndnote $23
	sndnote $26
	sndnote $22
	sndnote $23
	sndnote $20
	sndnote $1A
	sndnote $22
	sndnote $1E
	sndnote $1A
	sndnote $16
	sndnote $20
	sndnote $1D
	sndnote $1A
	sndnote $14
	sndnote $23
	sndnote $1D
	sndnote $1A
	sndnote $17
	sndnote $22
	sndnote $1E
	sndnote $1B
	sndnote $16
	sndnote $25
	sndnote $22
	sndnote $1F
	sndnote $19
	sndnote $24
	sndnote $20
	sndnote $1D
	sndnote $18
	sndnote $27
	sndnote $24
	sndnote $21
	sndnote $1B
	sndnote $24
	sndnote $21
	sndnote $1B
	sndnote $18
	sndnote $16
	sndnote $22
	sndnote $20
	sndnote $1B
	sndnote $1D
	sndnote $1A
	sndnote $1B
	sndnote $17
	sndnote $1A
	sndnote $16
	sndnote $14
	sndnote $16
	sndnote $12
	sndnote $16
	sndnote $11
	sndnote $12
	sndnote $16
	sndlen 64
	sndlenpre $40
	sndret
SndData_BGM_ToTheSky_Ch4:
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndcall .call0
	sndloop SndData_BGM_ToTheSky_Ch4
.call0:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 96
	sndlenpre $10
	sndch4 3, 0, 6
	sndlen 8
	sndch4 3, 0, 6
	sndlen 8
	sndenv 5, SNDENV_DEC, 4
	sndch4 3, 0, 2
	sndlen 48
	sndch4 3, 0, 2
	sndlen 8
	sndch4 3, 0, 2
	sndlen 8
	sndch4 3, 0, 2
	sndlen 16
	sndch4 3, 0, 2
	sndlen 8
	sndch4 3, 0, 2
	sndlen 8
	sndch4 3, 0, 2
	sndlen 16
	sndch4 3, 0, 2
	sndlen 8
	sndch4 3, 0, 2
	sndlen 8
	sndloopcnt $00, 2, .call0
.call0b:
	sndenv 4, SNDENV_DEC, 4
	sndch4 3, 0, 2
	sndlen 48
	sndch4 1, 0, 0
	sndlen 8
	sndch4 1, 0, 0
	sndlen 8
	sndloopcnt $00, 4, .call0b
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 96
	sndlenpre $10
	sndch4 3, 0, 6
	sndlen 8
	sndch4 3, 0, 6
	sndlen 8
	sndch4 3, 0, 6
	sndlen 48
	sndch4 3, 0, 6
	sndlen 8
	sndch4 3, 0, 6
	sndlen 8
	sndenv 5, SNDENV_DEC, 4
	sndch4 3, 0, 2
	sndlen 16
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 16
	sndenv 5, SNDENV_DEC, 4
	sndch4 3, 0, 2
	sndlen 16
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 16
	sndret
SndHeader_BGM_Wind:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_Wind_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_Wind_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_Wind_Ch3 ; Data ptr
	db $0C ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_Wind_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_BGM_Wind_Ch1:
	sndenv 7, SNDENV_INC, 0
	sndenach SNDOUT_CH1R|SNDOUT_CH1L
	sndnr11 2, 0
	sndnote $27
	sndlen 48
	sndnote $25
	sndlen 96
	sndlenpre $18
	sndnote $00
	sndnote $28
	sndlen 48
	sndnote $2A
	sndlen 96
	sndlenpre $18
	sndnote $00
	sndnote $27
	sndlen 48
	sndnote $25
	sndlen 96
	sndlenpre $18
	sndnote $00
	sndnote $28
	sndlen 48
	sndnote $2A
	sndlen 96
	sndnote $2B
.main:
	sndnote $0B
	sndlen 12
	sndnote $00
	sndloop .main
SndData_BGM_Wind_Ch2:
	sndenv 1, SNDENV_DEC, 1
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 3, 0
	sndnote $01
	sndlen 48
	sndenv 7, SNDENV_INC, 0
	sndnote $15
	sndlen 12
	sndnote $19
	sndnote $1C
	sndnote $20
	sndlen 48
	sndlenpre $0C
	sndlenpre $60
	sndnote $17
	sndlen 12
	sndnote $19
	sndnote $1B
	sndnote $20
	sndlen 48
	sndlenpre $0C
	sndlenpre $60
	sndnote $15
	sndlen 12
	sndnote $19
	sndnote $1C
	sndnote $20
	sndlen 48
	sndlenpre $0C
	sndlenpre $60
	sndnote $17
	sndlen 12
	sndnote $19
	sndnote $1B
	sndnote $20
	sndlen 48
	sndlenpre $0C
	sndnote $21
	sndlen 96
.main:
	sndnote $0F
	sndlen 12
	sndnote $00
	sndloop .main
SndData_BGM_Wind_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH3R|SNDOUT_CH3L
	sndwave $02
	sndch3len $00
	sndnote $0B
	sndlen 48
	sndnote $09
	sndlen 96
	sndlenpre $60
	sndnote $0B
	sndlen 96
	sndlenpre $60
	sndnote $09
	sndlen 96
	sndlenpre $60
	sndnote $06
	sndlen 96
	sndnote $05
	sndch3len $32
.main:
	sndnote $01
	sndlen 24
	sndloop .main
SndData_BGM_Wind_Ch4:
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 24
	sndch4 3, 0, 6
	sndlen 24
	sndcall .intro
.main:
	sndcall .call1
	sndcall .call2
	sndcall .call1
	sndcall .call3
	sndloop .main
.intro:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 36
	sndch4 3, 0, 6
	sndlen 6
	sndch4 3, 0, 6
	sndlen 6
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 12
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 12
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 12
	sndch4 3, 0, 6
	sndlen 24
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 24
	sndch4 3, 0, 2
	sndlen 24
	sndloopcnt $00, 4, .intro
	sndret
.call1:
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 60
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 12
	sndret
.call2:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 6
	sndch4 3, 0, 6
	sndlen 6
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 24
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 36
	sndch4 1, 0, 1
	sndlen 24
	sndret
.call3:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 6
	sndch4 3, 0, 6
	sndlen 6
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 24
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 12
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 12
	sndch4 3, 0, 6
	sndlen 12
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 12
	sndret
SndHeader_BGM_TrashHead:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_TrashHead_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_TrashHead_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_TrashHead_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_TrashHead_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_BGM_TrashHead_Ch1:
	sndenv 1, SNDENV_DEC, 1
	sndenach SNDOUT_CH1R|SNDOUT_CH1L
	sndnr11 2, 0
	sndnote $0A
	sndlen 14
.main:
	sndcall .call0
	sndcall .call1
	sndcall .call2
	sndnotebase $0C
	sndcall .call1
	sndnotebase $F4
	sndloop .main
.call0:
	sndenv 1, SNDENV_DEC, 1
	sndnote $0A
	sndlen 28
	sndenv 6, SNDENV_INC, 0
	sndnote $1D
	sndlen 14
	sndnote $20
	sndlen 28
	sndnote $1F
	sndnote $1D
	sndlen 7
	sndnote $1B
	sndnote $1D
	sndlen 84
	sndnote $00
	sndlen 28
	sndnote $1B
	sndlen 84
	sndnote $00
	sndlen 14
	sndnote $19
	sndlen 7
	sndnote $18
	sndnote $19
	sndlen 84
	sndnote $00
	sndlen 42
	sndnote $1D
	sndlen 14
	sndnote $22
	sndnote $25
	sndlen 28
	sndnote $24
	sndnote $22
	sndlen 7
	sndnote $20
	sndnote $1F
	sndlen 112
	sndlenpre $70
	sndlenpre $70
	sndret
.call1:
	sndnote $00
	sndlen 14
	sndnote $19
	sndnote $16
	sndnote $19
	sndnote $18
	sndlen 7
	sndnote $00
	sndnote $11
	sndlen 28
	sndnote $00
	sndlen 14
	sndnote $00
	sndlen 14
	sndnote $19
	sndnote $16
	sndnote $19
	sndnote $18
	sndlen 7
	sndnote $00
	sndnote $11
	sndlen 28
	sndnote $00
	sndlen 14
	sndnote $00
	sndlen 14
	sndnote $19
	sndnote $16
	sndnote $19
	sndnote $18
	sndnote $11
	sndnote $1B
	sndnote $18
	sndnote $19
	sndnote $18
	sndlen 42
	sndnote $16
	sndlen 14
	sndnote $14
	sndlen 28
	sndnote $00
	sndlen 14
	sndloopcnt $00, 2, .call1
	sndret
.call2:
	sndnote $00
	sndlen 14
	sndnote $2A
	sndnote $27
	sndnote $2A
	sndnote $29
	sndlen 7
	sndnote $00
	sndnote $26
	sndlen 28
	sndnote $00
	sndlen 14
	sndnote $00
	sndnote $2A
	sndnote $27
	sndnote $2A
	sndnote $29
	sndlen 7
	sndnote $00
	sndnote $26
	sndlen 28
	sndnote $00
	sndlen 14
	sndnote $00
	sndnote $2A
	sndnote $27
	sndnote $2A
	sndnote $29
	sndnote $22
	sndnote $31
	sndnote $2C
	sndnote $2F
	sndnote $2E
	sndlen 42
	sndnote $2C
	sndlen 14
	sndnote $2B
	sndlen 28
	sndnote $00
	sndlen 14
	sndret
SndData_BGM_TrashHead_Ch2:
	sndenv 7, SNDENV_INC, 0
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 3, 0
	sndnote $0D
	sndlen 7
	sndnote $0D
.main:
	sndcall .call0
	sndcall .call1
	sndenv 3, SNDENV_INC, 0
	sndnr21 2, 0
	sndnote $00
	sndlen 10
	sndcall SndData_BGM_TrashHead_Ch1.call1
	sndcall .call2
	sndcall .call3
	sndloop .main
.call0:
	sndnote $0D
	sndlen 84
	sndlenpre $0E
	sndnote $0D
	sndlen 7
	sndnote $0D
	sndnote $0D
	sndlen 28
	sndnote $0D
	sndlen 4
	sndnote $00
	sndlen 10
	sndnote $22
	sndlen 42
	sndnote $0D
	sndlen 4
	sndnote $00
	sndlen 10
	sndnote $0D
	sndlen 7
	sndnote $0D
	sndnote $0D
	sndlen 28
	sndnote $0D
	sndlen 4
	sndnote $00
	sndlen 10
	sndnote $25
	sndlen 42
	sndnote $0D
	sndlen 4
	sndnote $00
	sndlen 10
	sndnote $0D
	sndlen 7
	sndnote $0D
	sndnote $0D
	sndlen 28
	sndnote $0D
	sndlen 4
	sndnote $00
	sndlen 10
	sndnote $27
	sndlen 42
	sndnote $0D
	sndlen 4
	sndnote $00
	sndlen 10
	sndnote $0D
	sndlen 7
	sndnote $0D
	sndnote $0D
	sndlen 112
	sndret
.call1:
	sndenv 6, SNDENV_DEC, 2
	sndnote $1B
	sndlen 5
	sndnote $1F
	sndlen 4
	sndnote $22
	sndlen 5
	sndnote $25
	sndnote $27
	sndlen 4
	sndnote $28
	sndlen 5
	sndnote $2B
	sndnote $28
	sndlen 4
	sndnote $27
	sndlen 5
	sndnote $25
	sndnote $22
	sndlen 4
	sndnote $1F
	sndlen 5
	sndloopcnt $00, 6, .call1
	sndret
.call2:
	sndnote $00
	sndlen 14
	sndnote $2A
	sndnote $27
	sndnote $2A
	sndnote $29
	sndlen 7
	sndnote $00
	sndnote $26
	sndlen 28
	sndnote $00
	sndlen 14
	sndnote $00
	sndnote $2A
	sndnote $27
	sndnote $2A
	sndnote $29
	sndlen 7
	sndnote $00
	sndnote $26
	sndlen 28
	sndnote $00
	sndlen 14
	sndnote $00
	sndnote $2A
	sndnote $27
	sndnote $2A
	sndnote $29
	sndnote $22
	sndnote $31
	sndnote $2C
	sndnote $2F
	sndnote $2E
	sndlen 42
	sndnote $2C
	sndlen 14
	sndnote $2B
	sndlen 28
	sndnote $00
	sndlen 4
	sndret
.call3:
	sndenv 7, SNDENV_INC, 0
	sndnr21 3, 0
	sndnote $1D
	sndlen 84
	sndlenpre $0E
	sndnote $1D
	sndlen 7
	sndnote $1D
	sndnote $1D
	sndlen 84
	sndlenpre $0E
	sndnote $1D
	sndlen 7
	sndnote $1D
	sndnote $1E
	sndlen 84
	sndlenpre $0E
	sndnote $1E
	sndlen 7
	sndnote $1E
	sndnote $20
	sndlen 84
	sndlenpre $0E
	sndnote $20
	sndlen 7
	sndnote $20
	sndloopcnt $00, 2, .call3
	sndret
SndData_BGM_TrashHead_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH3R|SNDOUT_CH3L
	sndwave $04
	sndch3len $19
	sndnote $16
	sndlen 7
	sndnote $16
.main:
	sndcall .call0
	sndcall .call1
	sndcall .call1
	sndcall .call2
	sndloop .main
.call0:
	sndch3len $00
	sndnote $16
	sndlen 84
	sndlenpre $0E
	sndch3len $19
	sndnote $16
	sndlen 7
	sndnote $16
	sndch3len $00
	sndnote $16
	sndlen 42
	sndnote $26
	sndlen 56
	sndch3len $19
	sndnote $16
	sndlen 7
	sndnote $16
	sndch3len $00
	sndnote $16
	sndlen 42
	sndnote $16
	sndlen 28
	sndnote $19
	sndch3len $19
	sndnote $16
	sndlen 7
	sndnote $16
	sndch3len $00
	sndnote $16
	sndlen 42
	sndnote $16
	sndlen 28
	sndnote $19
	sndch3len $19
	sndnote $14
	sndlen 7
	sndnote $15
	sndch3len $00
	sndnote $16
	sndlen 84
	sndlenpre $0E
	sndch3len $19
	sndnote $16
	sndlen 7
	sndnote $16
	sndch3len $00
	sndnote $27
	sndlen 112
	sndlenpre $70
	sndlenpre $70
	sndret
.call1:
	sndch3len $32
	sndnote $16
	sndlen 28
	sndloopcnt $00, 15, .call1
	sndnote $16
	sndlen 14
	sndnote $11
	sndret
.call2:
	sndnote $14
	sndlen 28
	sndnote $14
	sndnote $14
	sndnote $14
	sndnote $14
	sndnote $14
	sndnote $14
	sndnote $14
	sndlen 14
	sndnote $0F
	sndch3len $19
.call2b:
	sndnote $14
	sndlen 7
	sndloopcnt $00, 32, .call2b
.call2c:
	sndch3len $00
	sndnote $16
	sndlen 84
	sndlenpre $0E
	sndch3len $19
	sndnote $16
	sndlen 7
	sndnote $16
	sndloopcnt $00, 4, .call2c
.call2d:
	sndch3len $19
	sndnote $16
	sndlen 14
	sndnote $16
	sndlen 7
	sndnote $16
	sndch3len $00
	sndnote $16
	sndlen 42
	sndch3len $19
	sndnote $16
	sndlen 7
	sndnote $16
	sndnote $16
	sndlen 14
	sndnote $16
	sndlen 7
	sndnote $16
	sndloopcnt $00, 4, .call2d
	sndret
SndData_BGM_TrashHead_Ch4:
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 7
	sndch4 3, 0, 2
	sndlen 7
.main:
	sndcall .call0
	sndcall .call1
	sndcall .call0
	sndcall .call2
	sndcall .call0
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 28
	sndch4 3, 0, 6
	sndlen 28
	sndch4 3, 0, 6
	sndlen 28
	sndch4 3, 0, 6
	sndlen 28
	sndcall .call3
	sndcall .call4
	sndcall .call3
	sndcall .call5
	sndloop .main
.call0:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 28
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 14
	sndret
.call1:
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 42
	sndch4 3, 0, 6
	sndlen 7
	sndch4 3, 0, 6
	sndlen 7
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 7
	sndch4 1, 0, 0
	sndlen 7
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 7
	sndch4 3, 0, 2
	sndlen 7
	sndret
.call2:
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 28
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndret
.call3:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 2, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 2, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 7
	sndenv 4, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 4, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndch4 3, 0, 6
	sndlen 7
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 7
	sndch4 3, 0, 2
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 7
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 5
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 4
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 5
	sndret
.call4:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 7
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 14
	sndloopcnt $00, 20, .call4
	sndret
.call5:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 7
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 28
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 7
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 14
	sndloopcnt $00, 8, .call5
	sndret
SndHeader_BGM_Arashi:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_Arashi_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_Arashi_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_Arashi_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_Arashi_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_BGM_Arashi_Ch1:
	sndenv 7, SNDENV_DEC, 2
	sndenach SNDOUT_CH1R|SNDOUT_CH1L
	sndnr11 2, 0
	sndcall .call0
	sndcall .call1
	sndcall .call2
	sndcall .call3
	sndcall .call4
	sndcall .call5
	sndcall .call4
	sndcall .call6
	sndcall .call7
	sndcall .call8
	sndloop SndData_BGM_Arashi_Ch1
.call0:
	sndnote $1A
	sndlen 7
	sndnote $20
	sndnote $1A
	sndnote $20
	sndlen 14
	sndnote $1A
	sndlen 7
	sndnote $1F
	sndlen 14
	sndnote $16
	sndlen 7
	sndnote $1F
	sndnote $16
	sndnote $16
	sndnote $1F
	sndnote $1F
	sndnote $16
	sndnote $1B
	sndret
.call1:
	sndnote $1A
	sndlen 7
	sndnote $20
	sndnote $1A
	sndnote $20
	sndlen 14
	sndnote $1A
	sndlen 7
	sndnote $1F
	sndlen 14
	sndnote $16
	sndlen 7
	sndnote $22
	sndnote $22
	sndnote $1D
	sndnote $21
	sndnote $1D
	sndnote $1E
	sndnote $18
	sndret
.call2:
	sndenv 1, SNDENV_DEC, 1
	sndnr11 3, 0
	sndnote $0A
	sndlen 28
	sndenv 7, SNDENV_INC, 0
	sndnote $16
	sndlen 7
	sndnote $19
	sndnote $1D
	sndnote $20
	sndnote $00
	sndlen 14
	sndnote $22
	sndlen 28
	sndnote $1D
	sndlen 7
	sndnote $00
	sndnote $1F
	sndlen 21
	sndnote $1B
	sndlen 7
	sndnote $00
	sndlen 14
	sndnote $16
	sndlen 28
	sndnote $1B
	sndnote $16
	sndlen 7
	sndnote $00
	sndnote $19
	sndlen 21
	sndnote $1B
	sndlen 7
	sndenv 1, SNDENV_DEC, 1
	sndnote $03
	sndlen 28
	sndlenpre $15
	sndenv 7, SNDENV_INC, 0
	sndnote $12
	sndlen 14
	sndnote $16
	sndlen 7
	sndnote $19
	sndnote $00
	sndnote $1B
	sndlen 21
	sndnote $19
	sndlen 7
	sndenv 1, SNDENV_DEC, 1
	sndnote $01
	sndlen 112
	sndenv 7, SNDENV_INC, 0
	sndnote $16
	sndlen 7
	sndnote $19
	sndnote $1D
	sndnote $20
	sndnote $00
	sndlen 14
	sndnote $22
	sndlen 28
	sndnote $1D
	sndlen 7
	sndnote $00
	sndnote $1F
	sndlen 21
	sndnote $1B
	sndlen 7
	sndnote $00
	sndlen 14
	sndnote $16
	sndnote $00
	sndnote $1B
	sndnote $16
	sndlen 7
	sndnote $1B
	sndnote $00
	sndnote $16
	sndnote $1B
	sndlen 21
	sndnote $19
	sndlen 14
	sndret
.call3:
	sndenv 1, SNDENV_DEC, 1
	sndnote $01
	sndlen 7
	sndenv 7, SNDENV_DEC, 2
	sndnr11 2, 0
	sndnote $14
	sndlen 21
	sndnote $11
	sndnote $15
	sndlen 28
	sndnote $0F
	sndlen 7
	sndnote $11
	sndlen 14
	sndnote $11
	sndlen 21
	sndnote $14
	sndnote $16
	sndnote $15
	sndlen 14
	sndnote $14
	sndret
.call4:
	sndenv 7, SNDENV_INC, 0
	sndnr11 3, 0
	sndnote $1B
	sndlen 21
	sndnote $1D
	sndlen 35
	sndnote $00
	sndlen 14
	sndnote $1B
	sndlen 3
	sndnote $1D
	sndlen 4
	sndnote $20
	sndlen 35
	sndlenpre $1C
	sndnote $00
	sndlen 14
	sndnote $20
	sndlen 28
	sndnote $22
	sndnote $20
	sndlen 7
	sndnote $00
	sndret
.call5:
	sndnote $1F
	sndlen 14
	sndnote $00
	sndlen 7
	sndnote $1B
	sndlen 35
	sndnote $00
	sndlen 21
	sndnote $13
	sndlen 14
	sndnote $14
	sndlen 7
	sndnote $16
	sndnote $17
	sndlenpre $15
	sndnote $16
	sndnote $12
	sndlen 14
	sndnote $00
	sndnote $1B
	sndnote $00
	sndlen 7
	sndnote $1B
	sndlen 14
	sndnote $11
	sndlen 7
	sndret
.call6:
	sndnote $1F
	sndlen 14
	sndnote $00
	sndlen 7
	sndnote $1B
	sndlen 35
	sndnote $00
	sndlen 21
	sndnote $1E
	sndlen 14
	sndnote $20
	sndlen 7
	sndnote $22
	sndnote $23
	sndlenpre $15
	sndnote $22
	sndnote $21
	sndnote $1D
	sndlen 10
	sndnote $00
	sndlen 11
	sndnote $18
	sndlen 7
	sndnote $1B
	sndlen 21
	sndret
.call7:
	sndnote $1D
	sndlen 56
	sndnote $00
	sndlen 14
	sndnote $20
	sndnote $00
	sndlen 7
	sndnote $1E
	sndlen 21
	sndnote $1D
	sndlen 28
	sndnote $00
	sndlen 14
	sndnote $18
	sndlen 28
	sndnote $00
	sndlen 7
	sndnote $19
	sndlen 21
	sndnote $1B
	sndlen 14
	sndnote $1B
	sndnote $1D
	sndlen 7
	sndnote $1D
	sndlen 28
	sndnote $00
	sndlen 14
	sndnote $14
	sndlen 2
	sndnote $20
	sndlen 3
	sndnote $21
	sndlen 2
	sndnote $22
	sndlen 28
	sndnote $16
	sndlen 14
	sndnote $1B
	sndnote $0F
	sndlen 7
	sndnote $19
	sndlen 21
	sndnote $16
	sndlen 28
	sndnote $00
	sndlen 14
	sndnote $14
	sndlen 5
	sndnote $16
	sndlen 4
	sndnote $18
	sndlen 5
	sndnote $19
	sndnote $1B
	sndlen 4
	sndnote $1D
	sndlen 5
	sndnote $19
	sndlen 28
	sndnote $00
	sndlen 14
	sndnote $19
	sndlen 28
	sndnote $1E
	sndlen 14
	sndnote $16
	sndlen 28
	sndnote $18
	sndnote $00
	sndlen 14
	sndnote $1D
	sndlen 28
	sndnote $1B
	sndlen 21
	sndnote $14
	sndret
.call8:
	sndnote $19
	sndlen 14
	sndnote $00
	sndlen 7
	sndnote $1B
	sndlen 35
	sndnote $00
	sndlen 7
	sndnote $1D
	sndlen 2
	sndnote $1E
	sndlen 3
	sndnote $1F
	sndlen 2
	sndnote $20
	sndlen 35
	sndnote $00
	sndlen 7
	sndnote $21
	sndlen 21
	sndnote $1D
	sndlen 7
	sndnote $00
	sndlen 14
	sndnote $1B
	sndlen 21
	sndnote $18
	sndlen 10
	sndnote $00
	sndlen 11
	sndnote $18
	sndlen 7
	sndnote $1E
	sndlen 21
	sndret
SndData_BGM_Arashi_Ch2:
	sndenv 6, SNDENV_DEC, 2
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 2, 0
	sndcall .call0
	sndcall .call1
	sndcall .call2
	sndcall .call3
	sndcall .call2
	sndcall .call4
	sndcall .call5
	sndcall .call6
	sndcall .call5
	sndcall .call7
	sndcall .call8
	sndcall .call9
	sndcall .call10
	sndloop SndData_BGM_Arashi_Ch2
.call0:
	sndnote $1D
	sndlen 7
	sndnote $25
	sndnote $1D
	sndnote $25
	sndlen 14
	sndnote $1D
	sndlen 7
	sndnote $25
	sndlen 14
	sndnote $1B
	sndlen 7
	sndnote $24
	sndnote $1B
	sndnote $1B
	sndnote $25
	sndnote $24
	sndnote $1B
	sndnote $1F
	sndret
.call1:
	sndnote $1D
	sndlen 7
	sndnote $25
	sndnote $1D
	sndnote $25
	sndlen 14
	sndnote $1D
	sndlen 7
	sndnote $25
	sndlen 14
	sndnote $1B
	sndlen 7
	sndnote $27
	sndnote $26
	sndnote $22
	sndnote $25
	sndnote $21
	sndnote $23
	sndnote $1D
	sndret
.call2:
	sndnote $25
	sndlen 7
	sndnote $25
	sndnote $19
	sndnote $25
	sndnote $16
	sndnote $22
	sndnote $19
	sndnote $25
	sndlen 21
	sndnote $27
	sndlen 7
	sndnote $20
	sndnote $19
	sndnote $25
	sndnote $19
	sndnote $24
	sndlen 21
	sndnote $18
	sndlen 7
	sndnote $24
	sndnote $18
	sndnote $24
	sndnote $18
	sndnote $1D
	sndlen 21
	sndnote $11
	sndlen 7
	sndnote $1D
	sndnote $11
	sndnote $24
	sndnote $18
	sndnote $1D
	sndret
.call3:
	sndnote $20
	sndlen 7
	sndnote $14
	sndnote $20
	sndnote $25
	sndnote $16
	sndnote $22
	sndnote $19
	sndnote $25
	sndlen 21
	sndnote $14
	sndlen 7
	sndnote $20
	sndnote $19
	sndnote $25
	sndnote $19
	sndnote $21
	sndlen 21
	sndnote $15
	sndlen 7
	sndnote $21
	sndnote $15
	sndnote $17
	sndnote $21
	sndnote $27
	sndnote $2C
	sndnote $29
	sndnote $20
	sndnote $1D
	sndnote $28
	sndnote $1E
	sndnote $23
	sndnote $26
	sndret
.call4:
	sndnote $0F
	sndlen 7
	sndnote $11
	sndnote $0A
	sndnote $11
	sndnote $0A
	sndnote $0A
	sndnote $19
	sndlen 14
	sndnote $0A
	sndlen 7
	sndnote $16
	sndnote $0A
	sndnote $0A
	sndnote $1A
	sndlen 14
	sndnote $08
	sndlen 7
	sndnote $08
	sndnote $14
	sndnote $16
	sndnote $0A
	sndnote $16
	sndnote $0A
	sndnote $0A
	sndnote $19
	sndlen 14
	sndnote $0A
	sndlen 7
	sndnote $1B
	sndnote $0A
	sndnote $0A
	sndnote $1A
	sndlen 14
	sndnote $19
	sndret
.call5:
	sndnote $20
	sndlen 7
	sndnote $19
	sndnote $20
	sndnote $16
	sndnote $20
	sndnote $19
	sndlen 14
	sndnote $20
	sndnote $16
	sndlen 7
	sndnote $20
	sndnote $16
	sndnote $20
	sndnote $16
	sndlen 14
	sndnote $19
	sndlen 7
	sndloopcnt $00, 2, .call5
	sndret
.call6:
	sndnote $1F
	sndlen 7
	sndnote $18
	sndnote $1F
	sndnote $16
	sndnote $26
	sndnote $22
	sndlen 14
	sndnote $1F
	sndnote $16
	sndlen 7
	sndnote $1F
	sndnote $16
	sndnote $1F
	sndnote $16
	sndlen 14
	sndnote $29
	sndnote $25
	sndlen 7
	sndnote $20
	sndnote $1B
	sndnote $17
	sndnote $16
	sndnote $12
	sndnote $17
	sndnote $1B
	sndnote $20
	sndnote $25
	sndnote $22
	sndnote $27
	sndnote $2C
	sndnote $2A
	sndnote $27
	sndret
.call7:
	sndnote $1F
	sndlen 7
	sndnote $18
	sndnote $1F
	sndnote $16
	sndnote $26
	sndnote $22
	sndlen 14
	sndnote $1F
	sndnote $16
	sndlen 7
	sndnote $1F
	sndnote $16
	sndnote $1F
	sndnote $13
	sndlen 14
	sndnote $27
	sndnote $25
	sndlen 7
	sndnote $20
	sndnote $1B
	sndnote $17
	sndnote $16
	sndnote $12
	sndnote $11
	sndnote $1D
	sndlen 5
	sndnote $18
	sndlen 4
	sndnote $1D
	sndlen 5
	sndnote $20
	sndnote $1B
	sndlen 4
	sndnote $1E
	sndlen 5
	sndnote $21
	sndnote $1D
	sndlen 4
	sndnote $21
	sndlen 5
	sndnote $22
	sndnote $27
	sndlen 4
	sndnote $29
	sndlen 5
	sndret
.call8:
	sndnote $2C
	sndlen 7
	sndnote $20
	sndnote $27
	sndnote $20
	sndloopcnt $00, 14, .call8
	sndret
.call9:
	sndnote $2C
	sndlen 7
	sndnote $20
	sndnote $25
	sndnote $20
	sndloopcnt $00, 6, .call9
	sndret
.call10:
	sndnote $2C
	sndlen 7
	sndnote $20
	sndnote $27
	sndnote $20
	sndloopcnt $00, 8, .call10
	sndnote $2A
	sndlen 7
	sndnote $1E
	sndnote $27
	sndnote $1E
	sndnote $27
	sndnote $1D
	sndnote $24
	sndnote $29
	sndnote $2C
	sndnote $20
	sndnote $2A
	sndnote $20
	sndnote $29
	sndnote $1E
	sndnote $25
	sndnote $1E
	sndret
SndData_BGM_Arashi_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH3R|SNDOUT_CH3L
	sndwave $04
	sndch3len $32
	sndcall .call0
	sndcall .call1
	sndcall .call2
	sndcall .call3
	sndcall .call2
	sndcall .call4
	sndcall .call5
	sndcall .call6
	sndcall .call5
	sndcall .call7
	sndcall .call8
	sndcall .call9
	sndcall .call8
	sndcall .call10
	sndloop SndData_BGM_Arashi_Ch3
.call0:
	sndnote $14
	sndlen 7
	sndnote $16
	sndnote $0F
	sndnote $16
	sndlen 14
	sndnote $14
	sndlen 7
	sndnote $1B
	sndlen 14
	sndnote $0F
	sndlen 7
	sndnote $13
	sndlen 14
	sndnote $0F
	sndlen 7
	sndnote $1B
	sndlen 14
	sndnote $19
	sndret
.call1:
	sndnote $14
	sndlen 7
	sndnote $16
	sndnote $0F
	sndnote $16
	sndlen 14
	sndnote $14
	sndlen 7
	sndnote $1B
	sndlen 14
	sndnote $0F
	sndlen 7
	sndnote $1B
	sndnote $1A
	sndnote $16
	sndnote $19
	sndnote $15
	sndnote $17
	sndnote $11
	sndret
.call2:
	sndnote $19
	sndlen 14
	sndnote $16
	sndlen 7
	sndnote $20
	sndlen 28
	sndnote $1B
	sndlen 21
	sndnote $1B
	sndlen 14
	sndnote $19
	sndch3len $00
	sndnote $25
	sndlen 42
	sndch3len $32
	sndnote $1D
	sndlen 7
	sndnote $25
	sndlen 14
	sndnote $20
	sndlen 7
	sndnote $11
	sndlen 14
	sndnote $1D
	sndlen 21
	sndnote $14
	sndlen 14
	sndnote $11
	sndlen 7
	sndret
.call3:
	sndch3len $00
	sndnote $1E
	sndlen 56
	sndnote $1B
	sndlen 21
	sndch3len $32
	sndnote $12
	sndlen 14
	sndnote $12
	sndlen 7
	sndnote $14
	sndch3len $00
	sndnote $17
	sndlen 56
	sndlenpre $07
	sndch3len $32
	sndnote $20
	sndnote $1D
	sndnote $14
	sndnote $1D
	sndnote $1C
	sndnote $12
	sndnote $17
	sndnote $1A
	sndret
.call4:
	sndnote $14
	sndlen 14
	sndnote $11
	sndlen 7
	sndnote $16
	sndlen 21
	sndnote $19
	sndlen 14
	sndnote $11
	sndlen 7
	sndnote $16
	sndlen 14
	sndnote $0E
	sndlen 7
	sndnote $1A
	sndlen 28
	sndnote $14
	sndlen 14
	sndnote $11
	sndlen 7
	sndnote $16
	sndlen 14
	sndnote $11
	sndlen 7
	sndnote $19
	sndlen 14
	sndnote $0F
	sndlen 7
	sndnote $1B
	sndlen 14
	sndnote $0E
	sndlen 7
	sndnote $1A
	sndlen 14
	sndnote $19
	sndret
.call5:
	sndnote $16
	sndlen 7
	sndnote $15
	sndnote $16
	sndnote $1D
	sndlen 14
	sndnote $16
	sndlen 7
	sndnote $16
	sndnote $15
	sndnote $16
	sndnote $1D
	sndlen 14
	sndnote $16
	sndlen 7
	sndnote $11
	sndnote $16
	sndnote $1D
	sndlen 14
	sndnote $19
	sndlen 7
	sndnote $14
	sndnote $19
	sndnote $20
	sndlen 14
	sndnote $14
	sndlen 7
	sndnote $19
	sndnote $14
	sndnote $19
	sndnote $20
	sndlen 14
	sndnote $14
	sndlen 7
	sndnote $14
	sndnote $1B
	sndnote $1D
	sndlen 14
	sndnote $18
	sndlen 7
	sndnote $13
	sndnote $18
	sndnote $1F
	sndlen 14
	sndnote $13
	sndlen 7
	sndnote $18
	sndnote $13
	sndnote $18
	sndnote $1F
	sndlen 14
	sndnote $13
	sndlen 7
	sndnote $13
	sndnote $16
	sndnote $1B
	sndlen 14
	sndret
.call6:
	sndnote $17
	sndlen 7
	sndnote $12
	sndnote $17
	sndnote $1E
	sndlen 14
	sndnote $12
	sndlen 7
	sndnote $23
	sndlen 14
	sndnote $17
	sndlen 7
	sndnote $22
	sndlen 14
	sndnote $17
	sndlen 7
	sndnote $1E
	sndnote $20
	sndnote $1B
	sndnote $12
	sndret
.call7:
	sndnote $17
	sndlen 7
	sndnote $12
	sndnote $17
	sndnote $1E
	sndlen 14
	sndnote $12
	sndlen 7
	sndnote $1B
	sndnote $1D
	sndlen 14
	sndnote $18
	sndnote $11
	sndnote $15
	sndlen 21
	sndret
.call8:
	sndnote $12
	sndlen 14
	sndnote $0D
	sndlen 7
	sndnote $12
	sndlen 14
	sndnote $0D
	sndlen 7
	sndnote $18
	sndnote $19
	sndlen 14
	sndnote $0D
	sndlen 7
	sndnote $19
	sndlen 14
	sndnote $0D
	sndlen 7
	sndnote $16
	sndlen 21
	sndnote $11
	sndlen 14
	sndnote $0C
	sndlen 7
	sndnote $11
	sndlen 14
	sndnote $0C
	sndlen 7
	sndnote $16
	sndnote $18
	sndlen 14
	sndnote $0C
	sndlen 7
	sndnote $18
	sndlen 14
	sndnote $0C
	sndlen 7
	sndnote $14
	sndlen 21
	sndret
.call9:
	sndnote $16
	sndlen 14
	sndnote $11
	sndlen 7
	sndnote $16
	sndlen 14
	sndnote $11
	sndlen 7
	sndnote $1B
	sndnote $1D
	sndlen 14
	sndnote $11
	sndlen 7
	sndnote $1D
	sndlen 14
	sndnote $11
	sndlen 7
	sndnote $19
	sndlen 21
	sndnote $16
	sndlen 14
	sndnote $11
	sndlen 7
	sndnote $16
	sndlen 14
	sndnote $11
	sndlen 7
	sndnote $19
	sndnote $1B
	sndlen 14
	sndnote $0F
	sndlen 7
	sndnote $1B
	sndlen 14
	sndnote $0F
	sndlen 7
	sndnote $16
	sndlen 21
	sndret
.call10:
	sndnote $1B
	sndlen 14
	sndnote $0F
	sndlen 7
	sndnote $19
	sndlen 14
	sndnote $0F
	sndlen 7
	sndnote $16
	sndlen 14
	sndnote $0F
	sndlen 7
	sndnote $0F
	sndnote $1B
	sndlen 14
	sndnote $0F
	sndlen 7
	sndnote $19
	sndlen 21
	sndnote $11
	sndlen 14
	sndnote $0C
	sndlen 7
	sndnote $11
	sndlen 14
	sndnote $0C
	sndlen 7
	sndnote $15
	sndlen 14
	sndnote $0C
	sndlen 7
	sndch3len $00
	sndnote $18
	sndlen 21
	sndnote $1B
	sndlen 3
	sndnote $1D
	sndlen 4
	sndnote $1B
	sndlen 3
	sndnote $1D
	sndlen 4
	sndnote $1B
	sndlen 3
	sndnote $1D
	sndlen 4
	sndnote $1B
	sndlen 7
	sndch3len $32
	sndret
SndData_BGM_Arashi_Ch4:
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndcall .call0
	sndcall .call1
	sndcall .call2
	sndcall .call3
	sndcall .call4
	sndcall .call5
	sndcall .call5
	sndloop SndData_BGM_Arashi_Ch4
.call0:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndch4 3, 0, 6
	sndlen 7
	sndch4 3, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndret
.call1:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndch4 3, 0, 6
	sndlen 7
	sndch4 3, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndch4 3, 0, 6
	sndlen 7
	sndret
.call2:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndch4 3, 0, 6
	sndlen 7
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndloopcnt $00, 6, .call2
	sndret
.call3:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 21
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndch4 3, 0, 6
	sndlen 7
	sndret
.call4:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 21
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndret
.call5:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndch4 3, 0, 6
	sndlen 7
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndch4 3, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndloopcnt $00, 7, .call5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 7
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 7
	sndret
SndHeader_BGM_RisingRed:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_RisingRed_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_RisingRed_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_RisingRed_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_RisingRed_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_BGM_RisingRed_Ch1:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH1R|SNDOUT_CH1L
	sndnr11 2, 0
.main:
	sndcall .call0
	sndloop .main
.call0:
	sndnote $2A
	sndlen 60
	sndnote $29
	sndlen 80
	sndlenpre $14
	sndlenpre $78
	sndlenpre $14
	sndnote $27
	sndlen 10
	sndnote $29
	sndnote $2A
	sndlen 120
	sndlenpre $14
	sndnote $29
	sndlen 10
	sndnote $27
	sndnote $29
	sndlen 20
	sndnote $25
	sndlen 120
	sndnote $27
	sndlen 10
	sndnote $29
	sndnote $2A
	sndlen 120
	sndlenpre $14
	sndnote $2E
	sndlen 10
	sndnote $30
	sndnote $2C
	sndlen 80
	sndlenpre $50
	sndlenpre $78
	sndnote $29
	sndlen 13
	sndnote $2A
	sndlen 14
	sndnote $2E
	sndlen 13
	sndnote $2C
	sndlen 80
	sndlenpre $50
	sndlenpre $50
	sndlenpre $50
	sndnote $2C
	sndlen 80
	sndlenpre $14
	sndnote $28
	sndnote $2A
	sndnote $2C
	sndnote $2C
	sndlen 80
	sndnote $2C
	sndlen 30
	sndnote $2D
	sndnote $2F
	sndlen 20
	sndnote $2A
	sndlen 120
	sndlenpre $14
	sndnote $27
	sndlen 10
	sndnote $28
	sndnote $27
	sndlen 80
	sndlenpre $50
	sndnote $2C
	sndlen 80
	sndlenpre $14
	sndnote $28
	sndnote $2A
	sndnote $2C
	sndnote $2C
	sndlen 80
	sndnote $2F
	sndlen 30
	sndnote $2D
	sndnote $2C
	sndlen 20
	sndnote $2A
	sndlen 80
	sndlenpre $50
	sndnote $2F
	sndlen 120
	sndlenpre $14
	sndnote $2E
	sndlen 10
	sndnote $2F
	sndnote $2E
	sndlen 120
	sndlenpre $14
	sndnote $2E
	sndlen 10
	sndnote $2F
	sndnote $31
	sndlen 80
	sndlenpre $14
	sndnote $31
	sndnote $2F
	sndnote $2E
	sndnote $2F
	sndlen 120
	sndlenpre $14
	sndnote $2C
	sndlen 10
	sndnote $2F
	sndnote $34
	sndlen 120
	sndlenpre $14
	sndnote $34
	sndnote $33
	sndnote $2F
	sndlen 120
	sndnote $31
	sndlen 10
	sndnote $33
	sndnote $31
	sndlen 20
	sndnote $2E
	sndlen 120
	sndnote $2F
	sndlen 10
	sndnote $2E
	sndnote $2F
	sndlen 120
	sndlenpre $14
	sndnote $2C
	sndlen 10
	sndnote $2F
	sndnote $34
	sndlen 80
	sndlenpre $14
	sndnote $34
	sndnote $33
	sndnote $31
	sndnote $2F
	sndlen 80
	sndlenpre $50
	sndlenpre $50
	sndlenpre $50
	sndret
SndData_BGM_RisingRed_Ch2:
	sndenv 1, SNDENV_DEC, 1
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 2, 0
	sndnote $01
	sndlen 10
	sndlenpre $05
	sndenv 3, SNDENV_DEC, 7
.main:
	sndcall SndData_BGM_RisingRed_Ch1.call0
	sndloop .main
SndData_BGM_RisingRed_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH3R|SNDOUT_CH3L
	sndwave $01
	sndch3len $00
	sndcall .call0
	sndcall .call1
	sndcall .call0
	sndnote $19
	sndlen 20
	sndnote $20
	sndnote $25
	sndnote $29
	sndnote $25
	sndnote $29
	sndnote $25
	sndnote $29
	sndcall .call2
	sndcall .call3
	sndcall .call2
	sndcall .call3
	sndnote $19
	sndlen 20
	sndnote $1E
	sndnote $22
	sndnote $25
	sndnote $22
	sndnote $25
	sndnote $22
	sndnote $25
	sndnote $19
	sndlen 20
	sndnote $1E
	sndnote $22
	sndnote $25
	sndnote $22
	sndnote $25
	sndnote $22
	sndnote $25
	sndcall .call2
	sndcall .call4
	sndcall .call2
	sndcall .call3
	sndloop SndData_BGM_RisingRed_Ch3
.call0:
	sndnote $19
	sndlen 20
	sndnote $20
	sndnote $25
	sndnote $29
	sndnote $25
	sndnote $29
	sndnote $25
	sndnote $29
	sndloopcnt $00, 2, .call0
	sndret
.call1:
	sndnote $19
	sndlen 20
	sndnote $1E
	sndnote $22
	sndnote $25
	sndnote $22
	sndnote $25
	sndnote $22
	sndnote $25
	sndnote $19
	sndlen 20
	sndnote $20
	sndnote $25
	sndnote $29
	sndnote $25
	sndnote $29
	sndnote $25
	sndnote $29
	sndloopcnt $00, 2, .call1
	sndret
	;--
	; [TCRF] Unreferenced song section
	sndnote $18 ;X
	sndlen 20 ;X
	sndnote $20 ;X
	sndnote $24 ;X
	sndnote $27 ;X
	sndnote $24 ;X
	sndnote $27 ;X
	sndnote $24 ;X
	sndnote $27 ;X
	sndret ;X
	;--
.call2:
	sndnote $1C
	sndlen 20
	sndnote $20
	sndnote $23
	sndnote $28
	sndnote $23
	sndnote $28
	sndnote $23
	sndnote $28
	sndloopcnt $00, 2, .call2
	sndret
.call3:
	sndnote $1B
	sndlen 20
	sndnote $1E
	sndnote $23
	sndnote $27
	sndnote $23
	sndnote $27
	sndnote $23
	sndnote $27
	sndloopcnt $00, 2, .call3
	sndret
.call4:
	sndnote $1B
	sndlen 20
	sndnote $1E
	sndnote $23
	sndnote $27
	sndnote $23
	sndnote $27
	sndnote $23
	sndnote $27
	sndnote $19
	sndnote $1E
	sndnote $22
	sndnote $25
	sndnote $22
	sndnote $25
	sndnote $22
	sndnote $25
	sndret
SndData_BGM_RisingRed_Ch4:
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndcall .call0
.main:
	sndcall .call1
	sndloop .main
.call0:
	sndenv 5, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 10
	sndenv 4, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 10
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 10
	sndenv 2, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 80
	sndlenpre $0A
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 40
	sndloopcnt $00, 9, .call0
	sndret
.call1:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 5, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 10
	sndenv 4, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 4, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 30
	sndenv 4, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 2, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 30
	sndenv 2, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 40
	sndret
SndHeader_BGM_StageClear:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_StageClear_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_StageClear_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_StageClear_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_StageClear_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_BGM_StageClear_Ch1:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH1R|SNDOUT_CH1L
	sndnr11 3, 0
	sndnote $0D
	sndlen 14
	sndnote $01
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $0B
	sndlen 14
	sndnote $0B
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $14
	sndlen 56
	sndnote $08
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $14
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $15
	sndlen 14
	sndnote $09
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $14
	sndlen 21
	sndnote $12
	sndlen 14
	sndnote $15
	sndlen 14
	sndnote $09
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $14
	sndlen 21
	sndnote $12
	sndlen 14
	sndnote $0D
	sndlen 14
	sndnote $0F
	sndendch
SndData_BGM_StageClear_Ch2:
	sndenv 6, SNDENV_DEC, 7
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 1, 0
	sndnote $14
	sndlen 14
	sndnote $00
	sndlen 7
	sndnote $12
	sndlen 14
	sndnote $00
	sndlen 7
	sndnote $19
	sndlen 28
	sndnote $19
	sndlen 5
	sndnote $17
	sndlen 4
	sndnote $14
	sndlen 5
	sndnote $17
	sndnote $14
	sndlen 4
	sndnote $12
	sndlen 5
	sndnote $14
	sndnote $0F
	sndlen 4
	sndnote $0B
	sndlen 5
	sndnote $1A
	sndlen 14
	sndnote $00
	sndlen 7
	sndnote $19
	sndlen 21
	sndnote $17
	sndlen 14
	sndnote $1A
	sndnote $00
	sndlen 7
	sndnote $19
	sndlen 21
	sndnote $17
	sndlen 14
	sndnote $12
	sndnote $14
	sndendch
SndData_BGM_StageClear_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH3R|SNDOUT_CH3L
	sndwave $04
	sndch3len $32
	sndnote $14
	sndlen 21
	sndnote $12
	sndnote $0D
	sndnote $0D
	sndlen 7
	sndnote $0B
	sndnote $08
	sndnote $0B
	sndnote $0D
	sndnote $08
	sndnote $14
	sndnote $12
	sndlen 14
	sndnote $12
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $14
	sndlen 21
	sndnote $15
	sndlen 14
	sndnote $12
	sndlen 14
	sndnote $12
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $14
	sndlen 21
	sndnote $15
	sndlen 14
	sndch3len $1E
	sndnote $14
	sndnote $14
	sndendch
SndData_BGM_StageClear_Ch4:
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 3
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndch4 3, 0, 6
	sndlen 7
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 3
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 4
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 4
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 5
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 5
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 4
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndch4 2, 0, 4
	sndlen 14
	sndendch

SndHeader_BGM_Roulette:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_Roulette_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR; Sound channel ptr
	dw SndData_BGM_Roulette_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_Roulette_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR; Sound channel ptr
	dw SndData_BGM_Roulette_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_BGM_Roulette_Ch1:
	sndenv 1, SNDENV_DEC, 1
	sndenach SNDOUT_CH1R|SNDOUT_CH1L
	sndnr11 3, 0
	sndnote $0A
	sndlen 48
	sndenv 7, SNDENV_DEC, 6
.main:
	sndcall .call0
	sndcall .call1
	sndcall .call0
	sndcall .call2
	sndloop .main
.call0:
	sndenv 7, SNDENV_DEC, 6
	sndnote $0A
	sndlen 12
	sndenv 1, SNDENV_DEC, 1
	sndnote $0A
	sndlen 72
	sndenv 7, SNDENV_DEC, 6
	sndnote $08
	sndlen 12
	sndnote $0A
	sndenv 1, SNDENV_DEC, 1
	sndnote $0A
	sndlen 36
	sndenv 7, SNDENV_DEC, 6
	sndnote $0D
	sndlen 12
	sndnote $0A
	sndlen 6
	sndret
.call1:
	sndnote $0F
	sndlen 6
	sndnote $00
	sndnote $0D
	sndnote $08
	sndlen 12
	sndret
.call2:
	sndnote $0F
	sndlen 12
	sndnote $08
	sndlen 6
	sndnote $0F
	sndlen 12
	sndret
SndData_BGM_Roulette_Ch2:
	sndenv 1, SNDENV_DEC, 1
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 2, 0
	sndnote $0A
	sndlen 48
	sndenv 5, SNDENV_DEC, 2
.main:
	sndcall .call0
	sndcall .call1
	sndloop .main
.call0:
	sndnote $2C
	sndlen 6
	sndnote $27
	sndnote $31
	sndlen 12
	sndnote $2C
	sndlen 6
	sndnote $27
	sndnote $31
	sndnote $27
	sndloopcnt $00, 3, .call0
	sndret
.call1:
	sndnote $2C
	sndlen 6
	sndnote $27
	sndnote $31
	sndlen 12
	sndnote $2C
	sndlen 6
	sndnote $27
	sndnote $31
	sndnote $33
	sndret
SndData_BGM_Roulette_Ch3:
	sndenvch3 0
	sndenach SNDOUT_CH3R|SNDOUT_CH3L
	sndwave $04
	sndch3len $32
	sndnote $0A
	sndlen 48
	sndenvch3 2
.main:
	sndcall .call0
	sndcall .call1
	sndcall .call0
	sndcall .call2
	sndloop .main
.call0:
	sndnote $0A
	sndlen 12
	sndnote $08
	sndlen 6
	sndnote $0A
	sndnote $00
	sndnote $0D
	sndnote $08
	sndnote $09
	sndnote $0A
	sndlen 3
	sndnote $00
	sndlen 9
	sndnote $0F
	sndlen 12
	sndnote $0D
	sndlen 6
	sndnote $0A
	sndlen 12
	sndnote $08
	sndlen 6
	sndret
.call1:
	sndnote $0A
	sndlen 12
	sndnote $08
	sndlen 6
	sndnote $0A
	sndnote $00
	sndnote $0D
	sndnote $08
	sndlen 12
	sndnote $03
	sndlen 6
	sndnote $08
	sndnote $0A
	sndnote $0F
	sndnote $00
	sndnote $0D
	sndnote $08
	sndlen 12
	sndret
.call2:
	sndnote $0A
	sndlen 12
	sndnote $08
	sndlen 6
	sndnote $0A
	sndnote $00
	sndnote $0D
	sndnote $08
	sndlen 12
	sndnote $0D
	sndnote $0A
	sndlen 6
	sndnote $0F
	sndlen 12
	sndnote $08
	sndlen 6
	sndnote $0F
	sndlen 12
	sndret
SndData_BGM_Roulette_Ch4:
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 12
	sndch4 2, 0, 4
	sndlen 6
	sndch4 2, 0, 4
	sndlen 12
	sndch4 2, 0, 4
	sndlen 6
	sndch4 2, 0, 4
	sndlen 6
.main:
	sndcall .call0
	sndloop .main
.call0:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 12
	sndch4 3, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 24
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 12
	sndch4 3, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 18
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 6
	sndch4 3, 0, 6
	sndlen 12
	sndch4 3, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 18
	sndch4 2, 0, 4
	sndlen 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 12
	sndch4 3, 0, 6
	sndlen 6
	sndch4 6, 0, 1
	sndlen 12
	sndch4 3, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 24
	sndch4 6, 0, 1
	sndlen 12
	sndch4 3, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 24
	sndch4 3, 0, 6
	sndlen 12
	sndch4 3, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 18
	sndch4 2, 0, 4
	sndlen 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 12
	sndch4 2, 0, 4
	sndlen 6
	sndch4 2, 0, 4
	sndlen 6
	sndret
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
; =============== L1F7D4B ===============
L1F7D4B: db $FF;X
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
	call SGB_PrepareSoundPacket
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
.act00: db SFX_DROP, SGB_SND_A_LASER_SM, $00
.act01: db SFX_TAUNT, SGB_SND_A_FASTJUMP, $00
.act02: db SFX_TAUNT, SGB_SND_A_FASTJUMP, $01
.act03: db SFX_TAUNT, SGB_SND_A_FASTJUMP, $02
.act04: db SFX_TAUNT, SGB_SND_A_FASTJUMP, $03
.act05: db SFX_METERCHARGE, SGB_SND_A_FADEIN, $03
.act06: db SFX_CHARSELECTED, SGB_SND_A_GLASSBREAK, $03
.act07: db SFX_LIGHT, SGB_SND_A_ATTACK_B, $03
.act08: db SFX_HEAVY, SGB_SND_A_ATTACK_B, $02
.act09: db SND_ID_14, SGB_SND_A_GATE, $03
.act0A: db SFX_HIT, SGB_SND_A_PUNCH_A, $03
.act0B: db SND_ID_17, SGB_SND_A_ATTACK_A, $03
.act0C: db SND_ID_14, SGB_SND_A_WINOPEN, $03
.act0D: db SND_ID_1A, SGB_SND_A_PUNCH_B, $01
.act0E: db SND_ID_2D, SGB_SND_A_WATERFALL, $03 ; [TCRF] Unused?
.act0F: db SND_ID_2B, SGB_SND_A_SWORDSWING, $03
.act10: db SND_ID_2A, SGB_SND_A_ATTACK_B, $01
.act11: db SND_ID_2C, SGB_SND_A_ATTACK_B, $01
.act12: db SND_ID_29, SGB_SND_A_PUNCH_A, $01
.act13: db SND_ID_29, SGB_SND_A_PUNCH_A, $00
.act14: db SND_ID_29, SGB_SND_A_FIRE, $02
.act15: db SND_ID_29, SGB_SND_A_FIRE, ($01 << 2)|$03
.act16: db SFX_HEAVY, SGB_SND_A_SWORDSWING, $02 ; [TCRF] Unused?
.act17: db SND_ID_2B, SGB_SND_A_JETSTART, $01
.act18: db SND_ID_2B, SGB_SND_A_PICTFLOAT, $03
.act19: db SND_ID_2D, SGB_SND_A_JETPROJ_B, $03
.act1A: db SFX_GRABSTART, SGB_SND_A_SELECT_B, $03
.act1B: db SFX_TAUNT, SGB_SND_A_PUNCH_B, $03
.act1C: db SND_ID_30, SGB_SND_A_SELECT_C, $03

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
; Maps the character set used for strings in the ROM (based on ASCII) to tile IDs. 
; The tile IDs correspond to the standard 1bpp font (FontDef_Default). 
TextPrinter_CharsetToTileTbl: db $30;X
L1F7EDD: db $31;X
L1F7EDE: db $32;X
L1F7EDF: db $33;X
L1F7EE0: db $00;X
L1F7EE1: db $00;X
L1F7EE2: db $00;X
L1F7EE3: db $00;X
L1F7EE4: db $00;X
L1F7EE5: db $00;X
L1F7EE6: db $00;X
L1F7EE7: db $00;X
L1F7EE8: db $00;X
L1F7EE9: db $00;X
L1F7EEA: db $00;X
L1F7EEB: db $00;X
L1F7EEC: db $00;X
L1F7EED: db $00;X
L1F7EEE: db $00;X
L1F7EEF: db $00;X
L1F7EF0: db $00;X
L1F7EF1: db $00;X
L1F7EF2: db $00;X
L1F7EF3: db $00;X
L1F7EF4: db $00;X
L1F7EF5: db $00;X
L1F7EF6: db $00;X
L1F7EF7: db $00;X
L1F7EF8: db $00;X
L1F7EF9: db $00;X
L1F7EFA: db $00;X
L1F7EFB: db $00;X
L1F7EFC: db $00
L1F7EFD: db $2B
L1F7EFE: db $2E;X
L1F7EFF: db $00;X
L1F7F00: db $00;X
L1F7F01: db $00;X
L1F7F02: db $00;X
L1F7F03: db $1E;X
L1F7F04: db $00;X
L1F7F05: db $00;X
L1F7F06: db $00;X
L1F7F07: db $2F;X
L1F7F08: db $2D
L1F7F09: db $29
L1F7F0A: db $1D
L1F7F0B: db $00;X
L1F7F0C: db $1F
L1F7F0D: db $20
L1F7F0E: db $21
L1F7F0F: db $22
L1F7F10: db $23;X
L1F7F11: db $24;X
L1F7F12: db $25;X
L1F7F13: db $26;X
L1F7F14: db $27
L1F7F15: db $28
L1F7F16: db $2A;X
L1F7F17: db $00;X
L1F7F18: db $00;X
L1F7F19: db $00;X
L1F7F1A: db $00;X
L1F7F1B: db $2C
L1F7F1C: db $1C
L1F7F1D: db $02
L1F7F1E: db $03
L1F7F1F: db $04
L1F7F20: db $05
L1F7F21: db $06
L1F7F22: db $07
L1F7F23: db $08
L1F7F24: db $09
L1F7F25: db $0A
L1F7F26: db $0B
L1F7F27: db $0C
L1F7F28: db $0D
L1F7F29: db $0E
L1F7F2A: db $0F
L1F7F2B: db $10
L1F7F2C: db $11
L1F7F2D: db $12;X
L1F7F2E: db $13
L1F7F2F: db $14
L1F7F30: db $15
L1F7F31: db $16
L1F7F32: db $17
L1F7F33: db $18
L1F7F34: db $19
L1F7F35: db $1A
L1F7F36: db $1B
L1F7F37: db $00;X
L1F7F38: db $00;X
L1F7F39: db $00;X
L1F7F3A: db $00;X
L1F7F3B: db $00;X
L1F7F3C: db $1E
L1F7F3D: db $34;X
L1F7F3E: db $35;X
L1F7F3F: db $36
L1F7F40: db $37;X
L1F7F41: db $38
L1F7F42: db $39;X
L1F7F43: db $3A
L1F7F44: db $3B;X
L1F7F45: db $3C
L1F7F46: db $3D
L1F7F47: db $3E;X
L1F7F48: db $3F
L1F7F49: db $40;X
L1F7F4A: db $41
L1F7F4B: db $42
L1F7F4C: db $43;X
L1F7F4D: db $44
L1F7F4E: db $45
L1F7F4F: db $46
L1F7F50: db $47;X
L1F7F51: db $48;X
L1F7F52: db $49;X
L1F7F53: db $4A;X
L1F7F54: db $4B;X
L1F7F55: db $4C;X
L1F7F56: db $4D;X
L1F7F57: db $00;X
L1F7F58: db $00;X
L1F7F59: db $00;X
L1F7F5A: db $00;X
L1F7F5B: db $00;X
L1F7F5C: db $00;X
L1F7F5D: db $00;X
L1F7F5E: db $00;X
L1F7F5F: db $00;X
L1F7F60: db $00;X
L1F7F61: db $00;X
L1F7F62: db $00;X
L1F7F63: db $00;X
L1F7F64: db $00;X
L1F7F65: db $00;X
L1F7F66: db $00;X
L1F7F67: db $00;X
L1F7F68: db $00;X
L1F7F69: db $00;X
L1F7F6A: db $00;X
L1F7F6B: db $00;X
L1F7F6C: db $00;X
L1F7F6D: db $00;X
L1F7F6E: db $00;X
L1F7F6F: db $00;X
L1F7F70: db $00;X
L1F7F71: db $00;X
L1F7F72: db $00;X
L1F7F73: db $00;X
L1F7F74: db $00;X
L1F7F75: db $00;X
L1F7F76: db $00;X
L1F7F77: db $00;X
L1F7F78: db $00;X
L1F7F79: db $00;X
L1F7F7A: db $00;X
L1F7F7B: db $00;X
L1F7F7C: db $00;X
L1F7F7D: db $47
L1F7F7E: db $00;X
L1F7F7F: db $00;X
L1F7F80: db $48
L1F7F81: db $4B
L1F7F82: db $4C
L1F7F83: db $4D;X
L1F7F84: db $4E
L1F7F85: db $00;X
L1F7F86: db $00;X
L1F7F87: db $00;X
L1F7F88: db $4F
L1F7F89: db $50
L1F7F8A: db $51
L1F7F8B: db $52
L1F7F8C: db $29
L1F7F8D: db $53
L1F7F8E: db $54
L1F7F8F: db $55
L1F7F90: db $56
L1F7F91: db $57
L1F7F92: db $58
L1F7F93: db $59
L1F7F94: db $5A
L1F7F95: db $5B
L1F7F96: db $5C
L1F7F97: db $5D
L1F7F98: db $5E
L1F7F99: db $5F
L1F7F9A: db $60
L1F7F9B: db $61
L1F7F9C: db $62
L1F7F9D: db $63
L1F7F9E: db $64
L1F7F9F: db $65
L1F7FA0: db $66
L1F7FA1: db $67
L1F7FA2: db $68
L1F7FA3: db $69
L1F7FA4: db $6A
L1F7FA5: db $6B
L1F7FA6: db $6C
L1F7FA7: db $6D
L1F7FA8: db $6E
L1F7FA9: db $6F
L1F7FAA: db $70
L1F7FAB: db $71
L1F7FAC: db $72
L1F7FAD: db $73
L1F7FAE: db $74
L1F7FAF: db $75
L1F7FB0: db $76
L1F7FB1: db $77
L1F7FB2: db $78
L1F7FB3: db $79
L1F7FB4: db $7A
L1F7FB5: db $7B
L1F7FB6: db $7C
L1F7FB7: db $7D
L1F7FB8: db $7E
L1F7FB9: db $7F
L1F7FBA: db $4A
L1F7FBB: db $49
L1F7FBC: db $00;X
L1F7FBD: db $00;X
L1F7FBE: db $00;X
L1F7FBF: db $00;X
L1F7FC0: db $00;X
L1F7FC1: db $00;X
L1F7FC2: db $00;X
L1F7FC3: db $00;X
L1F7FC4: db $00;X
L1F7FC5: db $00;X
L1F7FC6: db $00;X
L1F7FC7: db $00;X
L1F7FC8: db $00;X
L1F7FC9: db $00;X
L1F7FCA: db $00;X
L1F7FCB: db $00;X
L1F7FCC: db $00;X
L1F7FCD: db $00;X
L1F7FCE: db $00;X
L1F7FCF: db $00;X
L1F7FD0: db $00;X
L1F7FD1: db $00;X
L1F7FD2: db $00;X
L1F7FD3: db $00;X
L1F7FD4: db $00;X
L1F7FD5: db $00;X
L1F7FD6: db $00;X
L1F7FD7: db $00;X
L1F7FD8: db $00;X
L1F7FD9: db $00;X
L1F7FDA: db $00;X
L1F7FDB: db $00;X
; =============== TextPrinter_DigitToTileTbl ===============
; Maps the number digits to tile IDs.
; The tile IDs correspond to the standard 1bpp font (FontDef_Default). 
TextPrinter_DigitToTileTbl: db $1F
L1F7FDD: db $20
L1F7FDE: db $21
L1F7FDF: db $22
L1F7FE0: db $23
L1F7FE1: db $24
L1F7FE2: db $25
L1F7FE3: db $26
L1F7FE4: db $27
L1F7FE5: db $28
L1F7FE6: db $02
L1F7FE7: db $03
L1F7FE8: db $04
L1F7FE9: db $05
L1F7FEA: db $06
L1F7FEB: db $07
