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
	; If the three topmost bits are set, treat the "command byte" as a command ID.
	;
	cp   %11100000						; A >= $E0?
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
	cp   $80				; A < $80? (MSB clear?)
	jp   c, .setLength	; If so, skip ahead a lot
	
	;------

	;
	; Otherwise, clear the MSB and treat it as a secondary index to a table of NR*3/NR*4 register data.
	; If the index is != 0, add the contents of iSndInfo_FreqDataIdBase to the index.
	;
	
	sub  a, $80				; Clear MSB
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
; This is also how pausing/unpausing is treated is the same way as BGM/SFX. Their music data simply contains
; a pause or unpause command. ???????
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
	and  a, $1F
	
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
	dw Sound_Cmd_PushDataPtr
	dw Sound_Cmd_PopDataPtr
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
	
; =============== Sound_Cmd_PushDataPtr ===============
; Saves the current data ptr, then sets a new one.
; Command data format:
; - 0: Sound data ptr (low byte)
; - 1: Sound data ptr (high byte)
Sound_Cmd_PushDataPtr:
	;
	; Read 2 bytes of sound data to BC, and increment the data ptr 
	;
	
	; HL = hSndInfoCurDataPtr
	ldh  a, [hSndInfoCurDataPtr_Low]
	ld   l, a
	ldh  a, [hSndInfoCurDataPtr_High]
	ld   h, a
	
	; Read out to BC
	; BC = *HL, hSndInfoCurDataPtr++
	ldi  a, [hl]
	ld   c, a
	ld   a, [hl] 						; Not ldi because Sound_IncDataPtr, so it won't be needed to do it on Sound_Cmd_PopDataPtr
	ld   b, a
	
	; Write back the incremented hSndInfoCurDataPtr
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
	
; =============== Sound_Cmd_PopDataPtr ===============
; Restores the data ptr previously saved in Sound_Cmd_PushDataPtr.
Sound_Cmd_PopDataPtr:
	; Read the stack index value to A
	ld   hl, iSndInfo_DataPtrStackIdx
	add  hl, de
	ld   a, [hl]
	
	; Use it to index the stack location with the data ptr
	ld   l, a
	ld   h, $00
	add  hl, de
	
	; Restore the data ptr
	; NOTE: What is stored at HL already accounts for Sound_IncDataPtr
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
	dw SndHeader_01;X
	dw SndHeader_01
	dw SndHeader_02
	dw SndHeader_03
	dw SndHeader_04
	dw SndHeader_05
	dw SndHeader_06
	dw SndHeader_07
	dw SndHeader_08
	dw SndHeader_09
	dw SndHeader_0A
	dw SndHeader_0B
	dw SndHeader_Pause
	dw SndHeader_Unpause
	dw SndHeader_0E
	dw SndHeader_0F
	dw SndHeader_10
	dw SndHeader_11
	dw SndHeader_12
	dw SndHeader_13
	dw SndHeader_14
	dw SndHeader_15
	dw SndHeader_16
	dw SndHeader_17
	dw SndHeader_18
	dw SndHeader_19
	dw SndHeader_1A
	dw SndHeader_1B
	dw SndHeader_1C
	dw SndHeader_1D
	dw SndHeader_1E
	dw SndHeader_1F
	dw Sound_StartNothing;X
	dw Sound_StartNothing;X
	dw Sound_StartNothing;X
	dw Sound_StartNothing;X
	dw Sound_StartNothing;X
	dw Sound_StartNothing;X
	dw SndHeader_26
	dw SndHeader_27
	dw SndHeader_28
	dw SndHeader_29
	dw SndHeader_2A
	dw SndHeader_2B
	dw SndHeader_2C
	dw SndHeader_2D
	dw SndHeader_2E
	dw SndHeader_2F
	dw SndHeader_30
	dw SndHeader_31
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

SndHeader_0E:
	db $01 ; Number of channels
.ch2:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_0E_Ch2 ; Data ptr
	db $0C ; Base freq/note id
	db $81 ; Unused
SndData_0E_Ch2:
	sndenv 12, SNDENV_DEC, 3
	sndenach SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
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
SndHeader_0F:
	db $01 ; Number of channels
.ch2:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_0F_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_0F_Ch2:
	sndenv 15, SNDENV_DEC, 2
	sndenach SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
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
SndHeader_10:
	db $01 ; Number of channels
.ch2:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_10_Ch2 ; Data ptr
	db $0C ; Base freq/note id
	db $81 ; Unused
SndData_10_Ch2:
	sndenv 6, SNDENV_INC, 2
	sndenach SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndnr21 0, 0
	sndpush $48FF ; L1F48FF
	sndnotebase $01
	sndpush $48FF ; L1F48FF
	sndnotebase $01
	sndpush $48FF ; L1F48FF
	sndnotebase $01
	sndpush $48FF ; L1F48FF
	sndnotebase $01
	sndpush $48FF ; L1F48FF
	sndnotebase $01
	sndpush $48FF ; L1F48FF
	sndnotebase $01
	sndpush $48FF ; L1F48FF
	sndnotebase $01
	sndpush $48FF ; L1F48FF
	sndnotebase $01
	sndpush $48FF ; L1F48FF
	sndnotebase $01
	sndpush $48FF ; L1F48FF
	sndnotebase $01
	sndpush $48FF ; L1F48FF
	sndnotebase $01
	sndpush $48FF ; L1F48FF
	sndnotebase $01
	sndpush $48FF ; L1F48FF
	sndendch
	sndnote $25
	sndlen 1
	sndnote $26
	sndnote $27
	sndnote $26
	sndloopcnt $00, $02, $48FF ; L1F48FF
	sndpop
SndHeader_11:
	db $03 ; Number of channels
.ch2:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_11_Ch2 ; Data ptr
	db $0C ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_11_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_11_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_11_Ch2:
	sndenv 9, SNDENV_DEC, 4
	sndenach SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
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
SndData_11_Ch3:
	sndenvch3 2
	sndendch
SndData_11_Ch4:
	sndenv 15, SNDENV_DEC, 2
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndch4 7, 0, 1
	sndch4 0, 0, 6
	sndendch
SndHeader_12:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_12_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_12_Ch4:
	sndenv 7, SNDENV_INC, 1
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndch4 3, 0, 7
	sndch4 0, 0, 1
	sndsetskip
	sndch4 3, 0, 6
	sndch4 0, 0, 1
	sndch4 3, 0, 5
	sndch4 0, 0, 1
	sndch4 3, 0, 4
	sndch4 0, 0, 1
	sndch4 3, 0, 3
	sndch4 0, 0, 1
	sndch4 3, 0, 2
	sndch4 0, 0, 1
	sndch4 3, 0, 1
	sndch4 0, 0, 1
	sndch4 3, 0, 0
	sndch4 0, 0, 1
	sndclrskip
	sndendch
SndHeader_13:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_13_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_13_Ch4:
	sndenv 3, SNDENV_INC, 1
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndch4 4, 0, 7
	sndch4 0, 0, 2
	sndsetskip
	sndch4 4, 0, 6
	sndch4 0, 0, 2
	sndch4 4, 0, 5
	sndch4 0, 0, 2
	sndch4 4, 0, 4
	sndch4 0, 0, 2
	sndch4 4, 0, 3
	sndch4 0, 0, 2
	sndch4 4, 0, 2
	sndch4 0, 0, 2
	sndch4 4, 0, 1
	sndch4 0, 0, 2
	sndch4 4, 0, 0
	sndch4 0, 0, 2
	sndclrskip
	sndendch
SndHeader_14:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_14_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_14_Ch4:
	sndenv 15, SNDENV_DEC, 7
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndch4 3, 0, 7
	sndch4 0, 0, 1
	sndch4 4, 0, 5
	sndch4 0, 0, 1
	sndch4 3, 0, 7
	sndch4 0, 0, 1
	sndsetskip
	sndch4 2, 0, 4
	sndch4 0, 0, 1
	sndch4 5, 0, 5
	sndch4 0, 0, 1
	sndendch
SndHeader_15:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_15_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_15_Ch4:
	sndenv 11, SNDENV_DEC, 7
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndch4 2, 0, 7
	sndch4 0, 0, 2
	sndch4 4, 0, 5
	sndch4 0, 0, 2
	sndch4 1, 0, 7
	sndch4 0, 0, 2
	sndsetskip
	sndch4 1, 0, 4
	sndch4 0, 0, 2
	sndch4 1, 0, 7
	sndch4 0, 0, 2
	sndclrskip
	sndendch
SndHeader_16:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_16_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_16_Ch4:
	sndenv 15, SNDENV_DEC, 2
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndch4 7, 0, 1
	sndch4 0, 0, 5
	sndch4 0, 0, 0
	sndch4 0, 0, 1
	sndch4 3, 0, 5
	sndch4 0, 0, 6
	sndendch
SndHeader_17:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_17_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_17_Ch4:
	sndenv 15, SNDENV_DEC, 2
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndch4 4, 0, 0
	sndch4 0, 0, 1
	sndsetskip
	sndch4 4, 0, 1
	sndch4 0, 0, 1
	sndch4 4, 0, 2
	sndch4 0, 0, 1
	sndch4 4, 0, 3
	sndch4 0, 0, 1
	sndch4 4, 0, 4
	sndch4 0, 0, 1
	sndch4 4, 0, 5
	sndch4 0, 0, 1
	sndch4 4, 0, 6
	sndch4 0, 0, 1
	sndch4 4, 0, 7
	sndch4 0, 0, 1
	sndclrskip
	sndch4 3, 0, 5
	sndch4 0, 0, 1
	sndsetskip
	sndch4 3, 0, 4
	sndch4 0, 0, 1
	sndch4 3, 0, 3
	sndch4 0, 0, 1
	sndch4 3, 0, 2
	sndch4 0, 0, 1
	sndch4 3, 0, 1
	sndch4 0, 0, 1
	sndch4 3, 0, 0
	sndendch
SndHeader_1A:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_1A_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_1A_Ch4:
	sndenv 15, SNDENV_DEC, 7
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndch4 4, 0, 5
	sndch4 0, 0, 2
	sndch4 2, 0, 7
	sndch4 0, 0, 3
	sndch4 3, 0, 5
	sndch4 0, 0, 2
	sndch4 2, 0, 7
	sndch4 0, 0, 2
	sndch4 3, 0, 4
	sndch4 0, 1, 0
	sndch4 7, 0, 1
	sndch4 0, 0, 2
	sndch4 5, 0, 4
	sndch4 0, 0, 2
	sndch4 4, 0, 7
	sndch4 0, 0, 2
	sndch4 6, 0, 4
	sndch4 0, 1, 2
	sndch4 7, 0, 1
	sndch4 6, 0, 4
	sndendch
SndHeader_1B:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_1B_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_1B_Ch4:
	sndenv 15, SNDENV_DEC, 3
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndch4 3, 0, 6
	sndch4 0, 0, 2
	sndch4 7, 0, 2
	sndch4 0, 0, 2
	sndch4 3, 0, 6
	sndch4 0, 0, 3
	sndch4 5, 0, 7
	sndch4 0, 1, 2
	sndendch
SndHeader_1C:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_1C_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_1C_Ch4:
	sndenv 2, SNDENV_INC, 1
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndch4 3, 0, 0
	sndch4 0, 0, 2
	sndsetskip
	sndch4 3, 0, 1
	sndch4 0, 0, 2
	sndch4 3, 0, 2
	sndch4 0, 0, 2
	sndch4 3, 0, 3
	sndch4 0, 0, 2
	sndch4 3, 0, 4
	sndch4 0, 0, 2
	sndch4 3, 0, 5
	sndch4 0, 0, 2
	sndch4 3, 0, 6
	sndch4 0, 0, 2
	sndch4 3, 0, 7
	sndch4 0, 0, 2
	sndch4 3, 0, 6
	sndch4 0, 0, 2
	sndch4 3, 0, 5
	sndch4 0, 0, 2
	sndch4 3, 0, 4
	sndch4 0, 0, 2
	sndch4 3, 0, 3
	sndch4 0, 0, 2
	sndch4 3, 0, 2
	sndch4 0, 0, 2
	sndch4 3, 0, 1
	sndch4 0, 0, 2
	sndch4 3, 0, 0
	sndch4 0, 0, 2
	sndendch
SndHeader_1D:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_1D_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_1D_Ch4:
	sndenv 15, SNDENV_DEC, 7
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndch4 4, 0, 7
	sndch4 0, 0, 1
	sndch4 5, 0, 5
	sndch4 0, 0, 1
	sndch4 0, 0, 0
	sndch4 0, 0, 1
	sndch4 4, 0, 7
	sndch4 0, 0, 1
	sndsetskip
	sndch4 3, 0, 4
	sndch4 0, 0, 1
	sndch4 5, 0, 5
	sndch4 0, 0, 1
	sndendch
SndHeader_26:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_26_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_26_Ch4:
	sndenv 10, SNDENV_DEC, 1
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndch4 5, 0, 1
	sndch4 0, 0, 2
	sndch4 4, 0, 5
	sndch4 0, 0, 2
	sndch4 0, 0, 0
	sndch4 0, 0, 2
	sndch4 4, 0, 1
	sndch4 0, 0, 2
	sndch4 2, 0, 7
	sndch4 0, 0, 2
	sndch4 0, 1, 0
	sndch4 0, 0, 1
	sndch4 0, 0, 0
	sndch4 0, 0, 1
	sndendch
SndHeader_27:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_27_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_27_Ch4:
	sndenv 15, SNDENV_DEC, 2
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndch4 6, 0, 1
	sndch4 0, 0, 3
	sndch4 0, 0, 0
	sndch4 0, 0, 1
	sndch4 2, 0, 5
	sndch4 0, 0, 4
	sndendch
SndHeader_28:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_28_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_28_Ch4:
	sndenv 15, SNDENV_DEC, 7
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndch4 4, 0, 5
	sndch4 0, 0, 1
	sndsetskip
	sndch4 5, 0, 5
	sndch4 0, 0, 2
	sndch4 4, 0, 7
	sndch4 0, 0, 2
	sndch4 4, 0, 6
	sndch4 0, 0, 2
	sndch4 4, 0, 5
	sndch4 0, 0, 2
	sndch4 4, 0, 4
	sndch4 0, 0, 2
	sndch4 4, 0, 3
	sndch4 0, 0, 2
	sndch4 4, 0, 2
	sndch4 0, 0, 2
	sndch4 4, 0, 1
	sndch4 0, 0, 1
	sndch4 4, 0, 0
	sndch4 0, 0, 1
	sndclrskip
	sndenv 15, SNDENV_DEC, 2
	sndch4 3, 0, 2
	sndch4 1, 1, 6
	sndendch
SndHeader_29:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_29_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_29_Ch4:
	sndenv 3, SNDENV_INC, 3
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndch4 5, 0, 5
	sndch4 4, 0, 6
	sndendch
SndHeader_2A:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_2A_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_2A_Ch4:
	sndenv 10, SNDENV_INC, 1
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndch4 3, 0, 1
	sndch4 0, 0, 3
	sndsetskip
	sndch4 3, 0, 2
	sndch4 0, 0, 3
	sndch4 3, 0, 3
	sndch4 0, 0, 3
	sndch4 3, 0, 4
	sndch4 0, 0, 3
	sndch4 3, 0, 5
	sndch4 0, 0, 3
	sndch4 3, 0, 6
	sndch4 0, 0, 3
	sndch4 3, 0, 7
	sndch4 0, 0, 3
	sndch4 4, 0, 3
	sndch4 0, 0, 3
	sndch4 4, 0, 4
	sndch4 0, 0, 3
	sndch4 4, 0, 5
	sndch4 0, 0, 3
	sndch4 4, 0, 6
	sndch4 0, 0, 3
	sndch4 4, 0, 7
	sndch4 0, 0, 3
	sndclrskip
	sndendch
SndHeader_2B:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_2B_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_2B_Ch4:
	sndenv 10, SNDENV_INC, 1
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndch4 5, 0, 7
	sndch4 0, 0, 2
	sndsetskip
	sndch4 5, 0, 6
	sndch4 0, 0, 2
	sndch4 5, 0, 5
	sndch4 0, 0, 2
	sndch4 5, 0, 4
	sndch4 0, 0, 2
	sndch4 5, 0, 3
	sndch4 0, 0, 2
	sndch4 4, 0, 7
	sndch4 0, 0, 2
	sndch4 4, 0, 6
	sndch4 0, 0, 2
	sndch4 4, 0, 5
	sndch4 0, 0, 2
	sndch4 4, 0, 4
	sndch4 0, 0, 2
	sndch4 4, 0, 3
	sndch4 0, 0, 2
	sndch4 4, 0, 2
	sndch4 0, 0, 2
	sndch4 4, 0, 1
	sndch4 0, 0, 2
	sndclrskip
	sndenv 15, SNDENV_DEC, 1
	sndch4 2, 0, 7
	sndch4 0, 0, 1
	sndch4 2, 0, 6
	sndch4 0, 0, 1
	sndch4 2, 0, 5
	sndch4 0, 0, 1
	sndch4 2, 0, 4
	sndch4 0, 0, 1
	sndch4 2, 0, 3
	sndch4 0, 0, 1
	sndch4 2, 0, 2
	sndch4 0, 0, 1
	sndch4 2, 0, 1
	sndch4 0, 0, 1
	sndch4 2, 0, 0
	sndch4 0, 0, 1
	sndch4 2, 0, 1
	sndch4 0, 0, 1
	sndch4 2, 0, 2
	sndch4 0, 0, 1
	sndch4 2, 0, 3
	sndch4 0, 0, 1
	sndch4 2, 0, 4
	sndch4 0, 0, 1
	sndch4 2, 0, 5
	sndch4 0, 0, 1
	sndch4 2, 0, 6
	sndch4 0, 0, 1
	sndch4 2, 0, 7
	sndch4 0, 0, 1
	sndch4 3, 0, 1
	sndch4 0, 0, 1
	sndch4 3, 0, 2
	sndch4 0, 0, 1
	sndch4 3, 0, 3
	sndch4 0, 0, 1
	sndch4 3, 0, 4
	sndch4 0, 0, 1
	sndch4 3, 0, 5
	sndch4 0, 0, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 1
	sndch4 3, 0, 7
	sndch4 0, 0, 1
	sndendch
SndHeader_2C:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_2C_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_2C_Ch4:
	sndenv 15, SNDENV_DEC, 3
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndch4 7, 0, 1
	sndch4 0, 0, 2
	sndch4 5, 0, 4
	sndch4 0, 0, 2
	sndch4 3, 0, 4
	sndch4 0, 0, 2
	sndch4 5, 0, 4
	sndch4 0, 0, 2
	sndch4 3, 0, 4
	sndch4 0, 0, 5
	sndch4 7, 0, 1
	sndch4 1, 1, 6
	sndendch
SndHeader_2D:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_2D_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_2D_Ch4:
	sndenv 10, SNDENV_DEC, 7
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndch4 4, 0, 1
	sndch4 0, 0, 1
	sndsetskip
	sndch4 4, 0, 1
	sndch4 0, 0, 1
	sndch4 4, 0, 1
	sndch4 0, 0, 1
	sndch4 3, 1, 1
	sndch4 0, 0, 1
	sndch4 3, 1, 0
	sndch4 0, 0, 1
	sndch4 3, 0, 7
	sndch4 0, 0, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 1
	sndch4 3, 0, 5
	sndch4 0, 0, 1
	sndclrskip
	sndch4 4, 0, 1
	sndch4 0, 0, 1
	sndsetskip
	sndch4 4, 0, 1
	sndch4 0, 0, 1
	sndch4 4, 0, 1
	sndch4 0, 0, 1
	sndch4 3, 1, 1
	sndch4 0, 0, 1
	sndch4 3, 1, 0
	sndch4 0, 0, 1
	sndch4 3, 0, 7
	sndch4 0, 0, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 1
	sndch4 3, 0, 5
	sndch4 0, 0, 1
	sndclrskip
	sndloopcnt $00, $03, $4B64 ; L1F4B64
	sndendch
SndHeader_2E:
	db $01 ; Number of channels
.ch2:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_2E_Ch2 ; Data ptr
	db $06 ; Base freq/note id
	db $81 ; Unused
SndData_2E_Ch2:
	sndenv 0, SNDENV_INC, 7
	sndenach SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
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
	sndloop $4B99 ; L1F4B99 
SndHeader_2F:
	db $01 ; Number of channels
.ch2:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_2F_Ch2 ; Data ptr
	db $06 ; Base freq/note id
	db $81 ; Unused
SndData_2F_Ch2:
	sndendch
SndHeader_30:
	db $01 ; Number of channels
.ch2:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_30_Ch2 ; Data ptr
	db $0C ; Base freq/note id
	db $81 ; Unused
SndData_30_Ch2:
	sndenv 1, SNDENV_INC, 4
	sndenach SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndnr21 3, 0
	sndnote $2E
	sndlen 1
	sndsetskip
	sndnote $2F
	sndloopcnt $00, $1E, $4BC2 ; L1F4BC2
	sndendch
SndHeader_31:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_31_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_31_Ch4:
	sndenv 1, SNDENV_INC, 3
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndch4 2, 0, 7
	sndch4 0, 1, 2
	sndsetskip
	sndch4 2, 0, 6
	sndch4 0, 1, 2
	sndch4 2, 0, 5
	sndch4 0, 1, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndch4 2, 0, 3
	sndch4 0, 1, 2
	sndch4 2, 0, 2
	sndch4 0, 1, 2
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
	sndenach SNDOUT_CH1R|SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L
	sndnr11 2, 0
	sndenv 0, SNDENV_DEC, 0
	sndendch
SndData_PauseUnpause_Ch2:
	sndenach SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndnr21 2, 0
	sndenv 0, SNDENV_DEC, 0
	sndendch
SndData_PauseUnpause_Ch3:
	sndenach SNDOUT_CH4R|SNDOUT_CH2L|SNDOUT_CH3L
	sndenvch3 0
	sndendch
SndHeader_06:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_06_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_06_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_06_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_06_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_06_Ch1:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH1R|SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L
	sndnr11 3, 0
	sndpush $4C67 ; L1F4C67
	sndpush $4C78 ; L1F4C78
	sndpush $4C91 ; L1F4C91
	sndpush $4CA9 ; L1F4CA9
	sndpush $4C91 ; L1F4C91
	sndpush $4CBC ; L1F4CBC
	sndpush $4CD7 ; L1F4CD7
	sndpush $4D01 ; L1F4D01
	sndpush $4D11 ; L1F4D11
	sndpush $4D01 ; L1F4D01
	sndpush $4D1F ; L1F4D1F
	sndloop $4C46 ; L1F4C46 
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
	sndloopcnt $00, $02, $4C67 ; L1F4C67
	sndpop
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
	sndpop
	sndenv 7, SNDENV_INC, 0
	sndnote $23
	sndlen 30
	sndnote $22
	sndnote $1E
	sndlen 5
	sndnote $00
	sndnote $1C
	sndlen 40
	sndlenret $0A
	sndnote $1C
	sndnote $1E
	sndnote $20
	sndlen 20
	sndnote $1E
	sndlen 30
	sndnote $20
	sndnote $1C
	sndlen 20
	sndlenret $50
	sndpop
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
	sndlenret $1E
	sndnote $24
	sndnote $20
	sndlen 20
	sndlenret $50
	sndpop
	sndnote $1B
	sndlen 30
	sndnote $1C
	sndnote $1E
	sndlen 10
	sndnote $20
	sndlenret $14
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
	sndlenret $50
	sndpop
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
	sndlenret $0A
	sndpop
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
	sndpop
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
	sndlenret $50
	sndpop
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
	sndlenret $50
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
	sndlenret $50
	sndenv 1, SNDENV_DEC, 1
	sndnote $01
	sndlen 80
	sndlenret $50
	sndpop
SndData_06_Ch2:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndnr21 1, 0
	sndpush $4D60 ; L1F4D60
	sndpush $4D79 ; L1F4D79
	sndpush $4DB1 ; L1F4DB1
	sndloop $4D4E ; L1F4D4E 
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
	sndloopcnt $00, $0D, $4D60 ; L1F4D60
	sndpop
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
	sndpop
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
	sndloopcnt $00, $10, $4DB1 ; L1F4DB1
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
	sndpop
SndData_06_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH4R|SNDOUT_CH2L|SNDOUT_CH3L
	sndwave $02
	sndch3len $19
	sndpush $4E0E ; L1F4E0E
	sndpush $4E36 ; L1F4E36
	sndpush $4E64 ; L1F4E64
	sndpush $4E36 ; L1F4E36
	sndpush $4E74 ; L1F4E74
	sndpush $4E86 ; L1F4E86
	sndnotebase $FC
	sndpush $4E86 ; L1F4E86
	sndnotebase $04
	sndpush $4E86 ; L1F4E86
	sndnotebase $FC
	sndpush $4E86 ; L1F4E86
	sndnotebase $04
	sndpush $4E96 ; L1F4E96
	sndloop $4DDD ; L1F4DDD 
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
	sndloopcnt $00, $0C, $4E0E ; L1F4E0E
	sndpop
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
	sndpop
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
	sndpop
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
	sndpop
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
	sndloopcnt $00, $04, $4E86 ; L1F4E86
	sndpop
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
	sndpop
SndData_06_Ch4:
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndpush $4EE2 ; L1F4EE2
	sndpush $4EF8 ; L1F4EF8
	sndpush $4EE2 ; L1F4EE2
	sndpush $4F11 ; L1F4F11
	sndpush $4EE2 ; L1F4EE2
	sndpush $4EF8 ; L1F4EF8
	sndpush $4EE2 ; L1F4EE2
	sndpush $4F11 ; L1F4F11
	sndpush $4EE2 ; L1F4EE2
	sndpush $4EF8 ; L1F4EF8
	sndpush $4EE2 ; L1F4EE2
	sndpush $4F2A ; L1F4F2A
	sndpush $4F45 ; L1F4F45
	sndpush $4FAF ; L1F4FAF
	sndpush $4F2A ; L1F4F2A
	sndpush $4FC9 ; L1F4FC9
	sndloop $4EAD ; L1F4EAD 
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndloopcnt $00, $07, $4EE2 ; L1F4EE2
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndpop
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 7
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndloopcnt $00, $07, $4F45 ; L1F4F45
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 5
	sndch4 2, 0, 6
	sndch4 0, 0, 5
	sndch4 2, 0, 6
	sndch4 0, 0, 5
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 5
	sndch4 1, 0, 0
	sndch4 0, 0, 5
	sndch4 1, 0, 0
	sndch4 0, 0, 5
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndloopcnt $00, $0F, $4FAF ; L1F4FAF
	sndpop
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndloopcnt $00, $04, $4FC9 ; L1F4FC9
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndpop
SndHeader_08:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_08_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_08_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_08_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_08_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_08_Ch1:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH1R|SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L
	sndnr11 3, 0
	sndpush $5017 ; L1F5017
	sndpush $5066 ; L1F5066
	sndpush $50DE ; L1F50DE
	sndpush $5134 ; L1F5134
	sndpush $515B ; L1F515B
	sndpush $5176 ; L1F5176
	sndloop $4FFC ; L1F4FFC 
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
	sndloopcnt $00, $02, $5017 ; L1F5017
	sndpop
	sndenv 6, SNDENV_INC, 0
	sndnr11 2, 0
	sndnote $16
	sndlen 30
	sndnote $22
	sndlen 80
	sndlenret $0A
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
	sndlenret $0A
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
	sndlenret $07
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
	sndlenret $28
	sndnote $00
	sndlen 20
	sndnote $25
	sndlen 10
	sndnote $29
	sndlen 20
	sndnote $27
	sndlen 20
	sndlenret $03
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
	sndpop
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
	sndloopcnt $00, $03, $50DE ; L1F50DE
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
	sndpop
	sndenv 6, SNDENV_INC, 0
	sndnr11 2, 0
	sndnote $16
	sndlen 30
	sndnote $22
	sndlen 80
	sndlenret $0A
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
	sndlenret $0A
	sndnote $13
	sndnote $16
	sndnote $19
	sndnote $1F
	sndlen 40
	sndpop
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
	sndpop
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
	sndpop
SndData_08_Ch2:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndnr21 3, 0
	sndpush $51B5 ; L1F51B5
	sndpush $51FF ; L1F51FF
	sndpush $5211 ; L1F5211
	sndpush $51FF ; L1F51FF
	sndpush $5223 ; L1F5223
	sndpush $51FF ; L1F51FF
	sndpush $5211 ; L1F5211
	sndpush $51FF ; L1F51FF
	sndpush $5235 ; L1F5235
	sndpush $5245 ; L1F5245
	sndpush $52D1 ; L1F52D1
	sndpush $532D ; L1F532D
	sndpush $5366 ; L1F5366
	sndloop $5185 ; L1F5185 
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
	sndloopcnt $00, $02, $51B5 ; L1F51B5
	sndpop
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
	sndpop
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
	sndpop
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
	sndpop
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
	sndpop
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
	sndpop
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
	sndpop
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
	sndpop
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
	sndpop
SndData_08_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH4R|SNDOUT_CH2L|SNDOUT_CH3L
	sndwave $04
	sndch3len $1E
	sndpush $539B ; L1F539B
	sndpush $53C6 ; L1F53C6
	sndpush $539B ; L1F539B
	sndpush $53D5 ; L1F53D5
	sndpush $53E6 ; L1F53E6
	sndpush $540E ; L1F540E
	sndpush $5485 ; L1F5485
	sndpush $54EB ; L1F54EB
	sndpush $5512 ; L1F5512
	sndloop $5375 ; L1F5375 
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
	sndpop
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
	sndpop
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
	sndpop
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
	sndloopcnt $00, $03, $53E6 ; L1F53E6
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
	sndpop
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
	sndpop
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
	sndpop
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
	sndlenret $0A
	sndnote $16
	sndlen 10
	sndnote $11
	sndnote $0D
	sndnote $0F
	sndlen 60
	sndlenret $0A
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
	sndpop
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
	sndpop
SndData_08_Ch4:
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndpush $5566 ; L1F5566
	sndpush $557A ; L1F557A
	sndpush $5566 ; L1F5566
	sndpush $559F ; L1F559F
	sndpush $55C8 ; L1F55C8
	sndpush $55E3 ; L1F55E3
	sndpush $55C8 ; L1F55C8
	sndpush $55F6 ; L1F55F6
	sndpush $55C8 ; L1F55C8
	sndpush $55E3 ; L1F55E3
	sndpush $55C8 ; L1F55C8
	sndpush $55F6 ; L1F55F6
	sndpush $560F ; L1F560F
	sndpush $562B ; L1F562B
	sndpush $560F ; L1F560F
	sndpush $5648 ; L1F5648
	sndpush $5566 ; L1F5566
	sndpush $557A ; L1F557A
	sndpush $5566 ; L1F5566
	sndpush $559F ; L1F559F
	sndpush $5671 ; L1F5671
	sndpush $56C2 ; L1F56C2
	sndloop $551F ; L1F551F 
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndloopcnt $00, $06, $5566 ; L1F5566
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 3
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 4
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 2
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndpop
	sndenv 1, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndpop
	sndenv 1, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 2
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 1, 0, 4
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 1, 0, 4
	sndloopcnt $00, $03, $560F ; L1F560F
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 3
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 3
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 5
	sndch4 1, 0, 0
	sndch4 0, 0, 5
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 2
	sndch4 0, 0, 5
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndloopcnt $00, $07, $5671 ; L1F5671
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndloopcnt $00, $03, $569A ; L1F569A
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 2
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 2
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 2
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 1, 2
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 1, 0, 4
	sndloopcnt $00, $07, $56C2 ; L1F56C2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 2
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 2
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 1, 2
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 1, 0, 4
	sndloopcnt $00, $03, $56E3 ; L1F56E3
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndloopcnt $00, $03, $5700 ; L1F5700
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 2
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 1, 0, 4
	sndpop
SndHeader_04:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_04_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_04_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_04_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_04_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_04_Ch1:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH1R|SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L
	sndnr11 3, 0
	sndnote $14
	sndlen 80
	sndenv 7, SNDENV_DEC, 7
	sndpush $5770 ; L1F5770
	sndpush $57B0 ; L1F57B0
	sndpush $57C1 ; L1F57C1
	sndpush $57C6 ; L1F57C6
	sndpush $57EC ; L1F57EC
	sndpush $5808 ; L1F5808
	sndpush $582E ; L1F582E
	sndpush $5856 ; L1F5856
	sndpush $586B ; L1F586B
	sndloop $5745 ; L1F5745 
	sndenv 7, SNDENV_DEC, 7 ;X
	sndnr11 3, 0 ;X
	sndnote $14 ;X
	sndlen 40 ;X
	sndnote $08 ;X
	sndlen 5 ;X
	sndnote $00 ;X
	sndnote $14 ;X
	sndlen 30 ;X
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
	sndpop
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
	sndpop
	sndenv 1, SNDENV_DEC, 1
	sndnote $01
	sndlen 60
	sndpop
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
	sndpop
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
	sndpop
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
	sndlenret $0A
	sndpop
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
	sndpop
	sndenv 7, SNDENV_INC, 0
	sndnote $27
	sndlen 60
	sndnote $00
	sndlen 10
	sndnote $2E
	sndlenret $3C
	sndnote $2A
	sndlen 10
	sndnote $2C
	sndlenret $3C
	sndnote $00
	sndlen 10
	sndnote $2E
	sndlen 30
	sndnote $2C
	sndlen 20
	sndpop
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
	sndpop
SndData_04_Ch2:
	sndenv 6, SNDENV_DEC, 2
	sndenach SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndnr21 2, 0
	sndpush $58B9 ; L1F58B9
	sndpush $58D4 ; L1F58D4
	sndpush $5947 ; L1F5947
	sndenv 5, SNDENV_INC, 0
	sndnote $14
	sndlen 10
	sndnote $19
	sndnote $1A
	sndpush $59BE ; L1F59BE
	sndpush $59DA ; L1F59DA
	sndpush $59BE ; L1F59BE
	sndpush $59E5 ; L1F59E5
	sndloop $589B ; L1F589B 
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
	sndloopcnt $00, $04, $58B9 ; L1F58B9
	sndpop
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
	sndpop
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
	sndlenret $0A
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
	sndlenret $0A
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
	sndpop
	sndnote $1B
	sndlen 40
	sndlenret $0A
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
	sndlenret $28
	sndnote $0B
	sndlen 10
	sndnote $0B
	sndlen 5
	sndnote $00
	sndnote $17
	sndlen 10
	sndpop
	sndnote $19
	sndlen 10
	sndlenret $28
	sndnote $16
	sndlen 13
	sndnote $12
	sndlen 14
	sndnote $12
	sndlen 13
	sndpop
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
	sndpop
SndData_04_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH4R|SNDOUT_CH2L|SNDOUT_CH3L
	sndwave $04
	sndch3len $01
	sndch3len $19
	sndnotebase $0C
	sndpush $5A1B ; L1F5A1B
	sndnotebase $F4
	sndpush $5A2F ; L1F5A2F
	sndpush $5A7E ; L1F5A7E
	sndpush $5A9C ; L1F5A9C
	sndpush $5AC8 ; L1F5AC8
	sndpush $5B06 ; L1F5B06
	sndpush $5AC8 ; L1F5AC8
	sndpush $5B1D ; L1F5B1D
	sndloop $59FA ; L1F59FA 
	sndnote $08
	sndlen 10
	sndloopcnt $00, $38, $5A1B ; L1F5A1B
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
	sndpop
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
	sndpop
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
	sndpop
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
	sndpop
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
	sndpop
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
	sndpop
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
	sndpop
SndData_04_Ch4:
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndpush $5B50 ; L1F5B50
	sndpush $5BB4 ; L1F5BB4
	sndpush $5BED ; L1F5BED
	sndpush $5C58 ; L1F5C58
	sndpush $5C74 ; L1F5C74
	sndpush $5C58 ; L1F5C58
	sndpush $5CA3 ; L1F5CA3
	sndpush $5CDE ; L1F5CDE
	sndpush $5D02 ; L1F5D02
	sndpush $5D1F ; L1F5D1F
	sndloop $5B2F ; L1F5B2F 
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 4
	sndloopcnt $00, $03, $5B50 ; L1F5B50
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 3
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 4
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 3
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndpop
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 1, 6
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 5
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 3
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 4
	sndch4 2, 0, 4
	sndch4 0, 0, 3
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndloopcnt $00, $02, $5C58 ; L1F5C58
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 2
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 2
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 1, 7
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 3
	sndch4 2, 0, 4
	sndch4 0, 0, 4
	sndch4 2, 0, 4
	sndch4 0, 0, 3
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndloopcnt $00, $03, $5CDE ; L1F5CDE
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 1, 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndch4 3, 0, 6
	sndch4 0, 1, 5
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndloopcnt $00, $02, $5D1F ; L1F5D1F
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 2
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 2
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndpop
SndHeader_1F:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_1F_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_1F_Ch2 ; Data ptr
	db $F9 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_1F_Ch3 ; Data ptr
	db $0C ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_1F_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_1F_Ch1:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH1R|SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L
	sndnr11 3, 0
	sndpush $5D9E ; L1F5D9E
	sndloop $5D92 ; L1F5D92 
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
	sndloopcnt $00, $02, $5D9E ; L1F5D9E
	sndnote $20
	sndlen 12
	sndnote $1F
	sndnote $1E
	sndnote $1F
	sndnote $1E
	sndnote $1D
	sndnote $1C
	sndlen 24
	sndpop
SndData_1F_Ch2:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndnr21 1, 0
	sndpush $5D9E ; L1F5D9E
	sndloop $5DF7 ; L1F5DF7 
SndData_1F_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH4R|SNDOUT_CH2L|SNDOUT_CH3L
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
	sndloopcnt $00, $02, $5E03 ; L1F5E03
	sndnote $0F
	sndlen 12
	sndnote $0E
	sndnote $0D
	sndnote $0E
	sndnote $0D
	sndnote $0C
	sndlen 36
	sndloop $5E03 ; L1F5E03 
SndData_1F_Ch4:
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndpush $5E6C ; L1F5E6C
	sndpush $5E6C ; L1F5E6C
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 6
	sndch4 2, 0, 4
	sndch4 0, 1, 4
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 4
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 4
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 1, 0
	sndloop $5E43 ; L1F5E43 
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 4
	sndch4 3, 0, 6
	sndch4 1, 1, 0
	sndch4 3, 0, 6
	sndch4 0, 0, 6
	sndch4 3, 0, 6
	sndch4 0, 0, 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 2, 0, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 4
	sndloopcnt $00, $03, $5E6C ; L1F5E6C
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 4
	sndch4 3, 0, 6
	sndch4 0, 1, 4
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 4
	sndch4 3, 0, 6
	sndch4 0, 1, 4
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 4
	sndpop
SndHeader_1E:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_1E_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_1E_Ch2 ; Data ptr
	db $18 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_1E_Ch3 ; Data ptr
	db $0C ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_1E_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_1E_Ch1:
	sndenv 7, SNDENV_DEC, 1
	sndenach SNDOUT_CH1R|SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L
	sndnr11 2, 0
	sndnote $00
	sndlen 56
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
	sndloopcnt $00, $03, $5EC1 ; L1F5EC1
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
	sndlenret $07
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
	sndlenret $70
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
	sndlenret $03
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
SndData_1E_Ch2:
	sndenv 6, SNDENV_INC, 0
	sndenach SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
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
	sndlenret $38
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
	sndlenret $0E
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
	sndlenret $0E
	sndnote $05
	sndlen 56
	sndlenret $0E
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
	sndlenret $38
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
	sndlenret $38
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
SndData_1E_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH4R|SNDOUT_CH2L|SNDOUT_CH3L
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
	sndlenret $07
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
SndData_1E_Ch4:
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndpush $608C ; L1F608C
	sndpush $6105 ; L1F6105
	sndendch
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndch4 2, 0, 4
	sndch4 0, 1, 6
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 1, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 1, 4
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 1, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 1, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 5
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 7
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 7
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndloopcnt $00, $02, $6105 ; L1F6105
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 5
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 7
	sndch4 1, 0, 0
	sndch4 0, 0, 7
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 6
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 7
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 7
	sndch4 2, 0, 6
	sndch4 0, 0, 7
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 7
	sndch4 1, 0, 0
	sndch4 0, 0, 7
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 7
	sndch4 3, 0, 2
	sndch4 0, 0, 7
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 7
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 3
	sndch4 1, 0, 0
	sndch4 0, 0, 4
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 7
	sndch4 2, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 2, 0, 3
	sndpop
SndHeader_19:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_19_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_19_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_19_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_19_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_19_Ch1:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH1R|SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L
	sndnr11 3, 0
	sndpush $61DE ; L1F61DE
	sndpush $61FA ; L1F61FA
	sndpush $6230 ; L1F6230
	sndpush $6266 ; L1F6266
	sndpush $61DE ; L1F61DE
	sndloop $61CF ; L1F61CF 
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
	sndloopcnt $00, $02, $61DE ; L1F61DE
	sndpop
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
	sndloopcnt $00, $04, $61FA ; L1F61FA
	sndpop
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
	sndlenret $0A
	sndnote $1B
	sndnote $27
	sndnote $25
	sndnote $24
	sndlenret $28
	sndlenret $0A
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
	sndpop
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
	sndlenret $50
	sndenv 1, SNDENV_DEC, 1
	sndnote $01
	sndlen 80
	sndlenret $3C
	sndlenret $0A
	sndloopcnt $00, $02, $6266 ; L1F6266
	sndpop
SndData_19_Ch2:
	sndenv 6, SNDENV_DEC, 7
	sndenach SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndnr21 1, 0
	sndpush $62C7 ; L1F62C7
	sndpush $62DF ; L1F62DF
	sndpush $6315 ; L1F6315
	sndpush $62C7 ; L1F62C7
	sndpush $62C7 ; L1F62C7
	sndpush $62C7 ; L1F62C7
	sndpush $62C7 ; L1F62C7
	sndpush $62C7 ; L1F62C7
	sndloop $62AF ; L1F62AF 
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
	sndloopcnt $00, $02, $62C7 ; L1F62C7
	sndpop
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
	sndloopcnt $00, $04, $62DF ; L1F62DF
	sndpop
	sndenv 6, SNDENV_INC, 0
	sndnote $1D
	sndlen 10
	sndlenret $28
	sndnote $1F
	sndnote $20
	sndnote $22
	sndlen 30
	sndnote $23
	sndlen 10
	sndlenret $28
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
	sndlenret $50
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
	sndpop
SndData_19_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH4R|SNDOUT_CH2L|SNDOUT_CH3L
	sndwave $04
	sndch3len $00
	sndpush $635D ; L1F635D
	sndpush $6379 ; L1F6379
	sndpush $6399 ; L1F6399
	sndpush $63E0 ; L1F63E0
	sndpush $6405 ; L1F6405
	sndpush $63E0 ; L1F63E0
	sndloop $634B ; L1F634B 
	sndnote $16
	sndlen 10
	sndlenret $3C
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
	sndlenret $3C
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
	sndpop
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
	sndloopcnt $00, $04, $6379 ; L1F6379
	sndpop
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
	sndnote $14
	sndlen 10
	sndloopcnt $00, $08, $63D2 ; L1F63D2
	sndnote $0F
	sndnote $14
	sndnote $13
	sndnote $14
	sndnote $13
	sndnote $14
	sndpop
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
	sndloopcnt $00, $04, $63E0 ; L1F63E0
	sndpop
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
	sndloopcnt $00, $02, $6405 ; L1F6405
	sndpop
SndData_19_Ch4:
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndpush $6440 ; L1F6440
	sndpush $64C7 ; L1F64C7
	sndpush $64F5 ; L1F64F5
	sndpush $6520 ; L1F6520
	sndpush $64F5 ; L1F64F5
	sndpush $6542 ; L1F6542
	sndpush $6542 ; L1F6542
	sndpush $6576 ; L1F6576
	sndpush $64F5 ; L1F64F5
	sndloop $6425 ; L1F6425 
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 1, 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 2
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 2
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 3
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 4
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 3
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 3
	sndch4 2, 0, 4
	sndch4 0, 0, 4
	sndch4 2, 0, 4
	sndch4 0, 0, 3
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 2
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndpop
	sndenv 0, SNDENV_DEC, 1
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndloopcnt $00, $07, $64C7 ; L1F64C7
	sndpop
	sndenv 0, SNDENV_DEC, 1
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 5
	sndch4 2, 0, 6
	sndch4 0, 0, 5
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 5
	sndch4 1, 0, 0
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndpop
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 1, 2
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndloopcnt $00, $06, $6520 ; L1F6520
	sndpop
	sndenv 0, SNDENV_DEC, 1
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndloopcnt $00, $04, $6542 ; L1F6542
	sndpop
	sndenv 0, SNDENV_DEC, 1
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 0, SNDENV_DEC, 1
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 3
	sndch4 2, 0, 4
	sndch4 0, 0, 4
	sndch4 2, 0, 4
	sndch4 0, 0, 3
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndpop
SndHeader_03:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_03_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_03_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_03_Ch3 ; Data ptr
	db $0C ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_03_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_03_Ch1:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH1R|SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L
	sndnr11 2, 0
	sndenv 7, SNDENV_DEC, 7
	sndnr11 2, 0
	sndpush $65FC ; L1F65FC
	sndpush $6621 ; L1F6621
	sndpush $6638 ; L1F6638
	sndloop $65EC ; L1F65EC 
	sndnote $20
	sndlen 16
	sndnote $25
	sndlen 8
	sndlenret $48
	sndnote $20
	sndlen 16
	sndnote $23
	sndlen 8
	sndlenret $48
	sndnote $20
	sndlen 16
	sndnote $1E
	sndlen 8
	sndlenret $48
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
	sndlenret $28
	sndpop
	sndnote $2C
	sndlen 8
	sndenv 1, SNDENV_DEC, 1
	sndnote $08
	sndlen 96
	sndlenret $10
	sndenv 7, SNDENV_DEC, 7
	sndnote $1B
	sndlen 8
	sndnote $27
	sndlen 16
	sndnote $25
	sndlen 8
	sndlenret $48
	sndnote $2A
	sndlen 16
	sndnote $2F
	sndlen 8
	sndpop
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
	sndlenret $30
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
	sndlenret $48
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
	sndlenret $30
	sndenv 1, SNDENV_DEC, 1
	sndnote $06
	sndlen 24
	sndenv 7, SNDENV_INC, 0
	sndnote $22
	sndlen 16
	sndnote $20
	sndlen 8
	sndlenret $60
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
	sndlenret $30
	sndlenret $08
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
	sndlenret $48
	sndnote $1D
	sndlen 24
	sndlenret $48
	sndlenret $08
	sndnote $1C
	sndlen 16
	sndlenret $48
	sndnote $1E
	sndlen 24
	sndlenret $30
	sndlenret $08
	sndpop
SndData_03_Ch2:
	sndenv 1, SNDENV_DEC, 1
	sndenach SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndnr21 2, 0
	sndenv 1, SNDENV_DEC, 1
	sndnote $01
	sndlen 24
	sndpush $671E ; L1F671E
	sndpush $674D ; L1F674D
	sndpush $671E ; L1F671E
	sndpush $675A ; L1F675A
	sndpush $675F ; L1F675F
	sndpush $6774 ; L1F6774
	sndpush $6787 ; L1F6787
	sndpush $679E ; L1F679E
	sndpush $679E ; L1F679E
	sndpush $67B1 ; L1F67B1
	sndpush $679E ; L1F679E
	sndpush $67C2 ; L1F67C2
	sndloop $66F7 ; L1F66F7 
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
	sndpop
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
	sndpop
	sndlenret $48
	sndlenret $08
	sndpop
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
	sndloopcnt $00, $02, $675F ; L1F675F
	sndpop
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
	sndloopcnt $00, $02, $6774 ; L1F6774
	sndpop
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
	sndlenret $60
	sndlenret $60
	sndpop
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
	sndloopcnt $00, $02, $679E ; L1F679E
	sndpop
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
	sndloopcnt $00, $04, $67B1 ; L1F67B1
	sndpop
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
	sndlenret $48
	sndnote $19
	sndlen 24
	sndlenret $48
	sndlenret $08
	sndnote $19
	sndlen 16
	sndlenret $48
	sndnote $1B
	sndlen 24
	sndlenret $48
	sndlenret $08
	sndpop
SndData_03_Ch3:
	sndenvch3 0
	sndenach SNDOUT_CH4R|SNDOUT_CH2L|SNDOUT_CH3L
	sndwave $02
	sndch3len $3C
	sndnote $01
	sndlen 24
	sndenvch3 2
	sndpush $6805 ; L1F6805
	sndpush $682C ; L1F682C
	sndpush $6805 ; L1F6805
	sndpush $6839 ; L1F6839
	sndpush $683E ; L1F683E
	sndloop $67F1 ; L1F67F1 
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
	sndpop
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
	sndpop
	sndlenret $48
	sndlenret $08
	sndpop
	sndnote $0A
	sndlen 24
	sndnote $0A
	sndnote $0A
	sndlen 16
	sndnote $05
	sndlen 8
	sndnote $0A
	sndlen 24
	sndloopcnt $00, $02, $683E ; L1F683E
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
	sndlenret $48
	sndlenret $10
	sndnote $08
	sndlenret $48
	sndnote $0A
	sndlen 16
	sndlenret $48
	sndlenret $10
	sndnote $09
	sndlenret $48
	sndnote $0B
	sndlen 16
	sndlenret $48
	sndlenret $08
	sndnote $0D
	sndpop
SndData_03_Ch4:
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 1, 1, 0
	sndpush $68F8 ; L1F68F8
	sndpush $6938 ; L1F6938
	sndpush $6938 ; L1F6938
	sndpush $6962 ; L1F6962
	sndpush $69E1 ; L1F69E1
	sndloop $68E6 ; L1F68E6 
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 0
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 0
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 1, 0
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 0
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 0
	sndloopcnt $00, $06, $68F8 ; L1F68F8
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 0
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 0
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 1, 0
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 0
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 6, 0, 0
	sndlenret $08
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 0
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 0
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 0, 1, 0
	sndloopcnt $00, $03, $6938 ; L1F6938
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 0
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 0
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 0, 1, 0
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 0
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 0
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 1, 0
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 0
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 1, 0
	sndch4 3, 0, 6
	sndch4 0, 1, 0
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 0
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 0
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 0
	sndch4 3, 0, 6
	sndch4 1, 1, 0
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 0
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 0
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 0
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 1, 0
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 0
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 0
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 0
	sndch4 2, 0, 4
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 0
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 0
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 0
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 0
	sndch4 3, 0, 6
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 0
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 1, 0
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 0, 1, 0
	sndloopcnt $00, $05, $69E1 ; L1F69E1
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 1, 1, 0
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 0
	sndch4 2, 0, 4
	sndch4 0, 1, 0
	sndch4 2, 0, 4
	sndch4 0, 1, 0
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 0
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 4
	sndch4 1, 0, 0
	sndch4 0, 0, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 0
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 4
	sndch4 3, 0, 2
	sndch4 0, 0, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 0
	sndch4 3, 0, 6
	sndch4 2, 1, 0
	sndch4 3, 0, 6
	sndch4 0, 1, 0
	sndch4 3, 0, 6
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 0
	sndch4 2, 0, 4
	sndch4 0, 1, 0
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 1, 0, 0
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 1, 0
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 0
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 0
	sndch4 2, 0, 4
	sndch4 0, 1, 0
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 4
	sndch4 1, 0, 0
	sndch4 0, 0, 4
	sndch4 1, 0, 0
	sndch4 0, 1, 0
	sndch4 1, 0, 0
	sndch4 0, 1, 0
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 0
	sndch4 2, 0, 6
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 0
	sndch4 2, 0, 4
	sndch4 0, 1, 0
	sndch4 2, 0, 4
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 0
	sndch4 3, 0, 6
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 0
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 4
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 4
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 0
	sndch4 3, 0, 6
	sndch4 0, 1, 0
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 0, 1, 0
	sndlenret $30
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 0
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 0
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 0
	sndch4 2, 0, 4
	sndch4 0, 1, 0
	sndpop
SndHeader_18:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_18_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_18_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_18_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_18_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_18_Ch1:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH1R|SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L
	sndnr11 2, 0
	sndpush $6AD9 ; L1F6AD9
	sndpush $6B08 ; L1F6B08
	sndloop $6ACA ; L1F6ACA 
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
	sndloopcnt $00, $04, $6AD9 ; L1F6AD9
	sndpop
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
	sndloopcnt $00, $03, $6B08 ; L1F6B08
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
	sndpop
SndData_18_Ch2:
	sndenv 3, SNDENV_DEC, 4
	sndenach SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndnr21 2, 0
	sndnote $00
	sndlen 15
	sndpush $6B7B ; L1F6B7B
	sndpush $6BAA ; L1F6BAA
	sndloop $6B72 ; L1F6B72 
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
	sndloopcnt $00, $04, $6B7B ; L1F6B7B
	sndpop
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
	sndloopcnt $00, $03, $6BAA ; L1F6BAA
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
	sndpop
SndData_18_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH4R|SNDOUT_CH2L|SNDOUT_CH3L
	sndwave $02
	sndch3len $00
	sndpush $6C1D ; L1F6C1D
	sndpush $6C31 ; L1F6C31
	sndloop $6C0C ; L1F6C0C 
	sndnote $12
	sndlen 80
	sndlenret $50
	sndch3len $14
	sndnote $11
	sndlen 10
	sndch3len $00
	sndnote $11
	sndlen 120
	sndlenret $1E
	sndloopcnt $00, $04, $6C1D ; L1F6C1D
	sndpop
	sndch3len $1E
	sndnote $12
	sndlen 30
	sndch3len $00
	sndnote $12
	sndlen 120
	sndlenret $0A
	sndch3len $1E
	sndnote $11
	sndlen 30
	sndch3len $00
	sndnote $11
	sndlen 120
	sndlenret $0A
	sndloopcnt $00, $03, $6C31 ; L1F6C31
	sndch3len $1E
	sndnote $12
	sndlen 30
	sndch3len $00
	sndnote $12
	sndlen 120
	sndlenret $0A
	sndch3len $1E
	sndnote $14
	sndlen 30
	sndch3len $00
	sndnote $14
	sndlen 40
	sndlenret $0A
	sndnote $15
	sndlen 80
	sndpop
SndData_18_Ch4:
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndpush $6C6F ; L1F6C6F
	sndpush $6C8E ; L1F6C8E
	sndpush $6CCA ; L1F6CCA
	sndloop $6C61 ; L1F6C61 
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 5, 0, 0
	sndlenret $50
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 7, 1, 0
	sndlenret $1E
	sndch4 3, 0, 6
	sndch4 5, 0, 0
	sndlenret $50
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 5, 0, 0
	sndlenret $1E
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 1, 2
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 1, 1, 6
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 4
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 2, 1, 0
	sndch4 2, 0, 1
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 4
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 4
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 2, 1, 0
	sndch4 2, 0, 1
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 2
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 1, 1, 6
	sndloopcnt $00, $02, $6C8E ; L1F6C8E
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 1, 6
	sndch4 3, 0, 6
	sndch4 7, 1, 0
	sndlenret $0A
	sndloopcnt $00, $04, $6CCA ; L1F6CCA
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 4
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 4
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 4
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 1, 0, 4
	sndloopcnt $00, $04, $6CD7 ; L1F6CD7
	sndpop
SndHeader_0B:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_0B_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_0B_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_0B_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_0B_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_0B_Ch1:
	sndenv 7, SNDENV_INC, 0
	sndenach SNDOUT_CH1R|SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L
	sndnr11 3, 0
	sndnote $27
	sndlen 96
	sndlenret $08
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
	sndlenret $08
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
	sndlenret $40
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
	sndloop $6D20 ; L1F6D20 
SndData_0B_Ch2:
	sndenv 5, SNDENV_INC, 0
	sndenach SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
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
	sndloop $6D6D ; L1F6D6D 
SndData_0B_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH4R|SNDOUT_CH2L|SNDOUT_CH3L
	sndwave $02
	sndch3len $19
	sndpush $6DCF ; L1F6DCF
	sndpush $6DE9 ; L1F6DE9
	sndpush $6DCF ; L1F6DCF
	sndpush $6DF3 ; L1F6DF3
	sndloop $6DB8 ; L1F6DB8 
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
	sndpop
	sndnote $26
	sndlen 8
	sndnote $1D
	sndnote $23
	sndnote $1D
	sndnote $22
	sndnote $1D
	sndnote $1A
	sndnote $16
	sndpop
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
	sndlenret $40
	sndpop
SndData_0B_Ch4:
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndpush $6E39 ; L1F6E39
	sndloop $6E31 ; L1F6E31 
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 6, 0, 0
	sndlenret $10
	sndch4 3, 0, 6
	sndch4 0, 1, 0
	sndch4 3, 0, 6
	sndch4 0, 1, 0
	sndenv 5, SNDENV_DEC, 4
	sndch4 3, 0, 2
	sndch4 3, 0, 0
	sndch4 3, 0, 2
	sndch4 0, 1, 0
	sndch4 3, 0, 2
	sndch4 0, 1, 0
	sndch4 3, 0, 2
	sndch4 1, 0, 0
	sndch4 3, 0, 2
	sndch4 0, 1, 0
	sndch4 3, 0, 2
	sndch4 0, 1, 0
	sndch4 3, 0, 2
	sndch4 1, 0, 0
	sndch4 3, 0, 2
	sndch4 0, 1, 0
	sndch4 3, 0, 2
	sndch4 0, 1, 0
	sndloopcnt $00, $02, $6E39 ; L1F6E39
	sndenv 4, SNDENV_DEC, 4
	sndch4 3, 0, 2
	sndch4 3, 0, 0
	sndch4 1, 0, 0
	sndch4 0, 1, 0
	sndch4 1, 0, 0
	sndch4 0, 1, 0
	sndloopcnt $00, $04, $6E5C ; L1F6E5C
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 6, 0, 0
	sndlenret $10
	sndch4 3, 0, 6
	sndch4 0, 1, 0
	sndch4 3, 0, 6
	sndch4 0, 1, 0
	sndch4 3, 0, 6
	sndch4 3, 0, 0
	sndch4 3, 0, 6
	sndch4 0, 1, 0
	sndch4 3, 0, 6
	sndch4 0, 1, 0
	sndenv 5, SNDENV_DEC, 4
	sndch4 3, 0, 2
	sndch4 1, 0, 0
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 0
	sndenv 5, SNDENV_DEC, 4
	sndch4 3, 0, 2
	sndch4 1, 0, 0
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 0
	sndpop
SndHeader_0A:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_0A_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_0A_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_0A_Ch3 ; Data ptr
	db $0C ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_0A_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_0A_Ch1:
	sndenv 7, SNDENV_INC, 0
	sndenach SNDOUT_CH1R|SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L
	sndnr11 2, 0
	sndnote $27
	sndlen 48
	sndnote $25
	sndlen 96
	sndlenret $18
	sndnote $00
	sndnote $28
	sndlen 48
	sndnote $2A
	sndlen 96
	sndlenret $18
	sndnote $00
	sndnote $27
	sndlen 48
	sndnote $25
	sndlen 96
	sndlenret $18
	sndnote $00
	sndnote $28
	sndlen 48
	sndnote $2A
	sndlen 96
	sndnote $2B
	sndnote $0B
	sndlen 12
	sndnote $00
	sndloop $6EC3 ; L1F6EC3 
SndData_0A_Ch2:
	sndenv 1, SNDENV_DEC, 1
	sndenach SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
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
	sndlenret $0C
	sndlenret $60
	sndnote $17
	sndlen 12
	sndnote $19
	sndnote $1B
	sndnote $20
	sndlen 48
	sndlenret $0C
	sndlenret $60
	sndnote $15
	sndlen 12
	sndnote $19
	sndnote $1C
	sndnote $20
	sndlen 48
	sndlenret $0C
	sndlenret $60
	sndnote $17
	sndlen 12
	sndnote $19
	sndnote $1B
	sndnote $20
	sndlen 48
	sndlenret $0C
	sndnote $21
	sndlen 96
	sndnote $0F
	sndlen 12
	sndnote $00
	sndloop $6EFB ; L1F6EFB 
SndData_0A_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH4R|SNDOUT_CH2L|SNDOUT_CH3L
	sndwave $02
	sndch3len $00
	sndnote $0B
	sndlen 48
	sndnote $09
	sndlen 96
	sndlenret $60
	sndnote $0B
	sndlen 96
	sndlenret $60
	sndnote $09
	sndlen 96
	sndlenret $60
	sndnote $06
	sndlen 96
	sndnote $05
	sndch3len $32
	sndnote $01
	sndlen 24
	sndloop $6F1C ; L1F6F1C 
SndData_0A_Ch4:
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 1, 0
	sndch4 3, 0, 6
	sndch4 1, 1, 0
	sndpush $6F3B ; L1F6F3B
	sndpush $6F69 ; L1F6F69
	sndpush $6F7A ; L1F6F7A
	sndpush $6F69 ; L1F6F69
	sndpush $6F8B ; L1F6F8B
	sndloop $6F2C ; L1F6F2C 
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 2, 0, 4
	sndch4 3, 0, 6
	sndch4 0, 0, 6
	sndch4 3, 0, 6
	sndch4 0, 0, 6
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 4
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 4
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 4
	sndch4 3, 0, 6
	sndch4 1, 1, 0
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 1, 1, 0
	sndch4 3, 0, 2
	sndch4 1, 1, 0
	sndloopcnt $00, $04, $6F3B ; L1F6F3B
	sndpop
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 3, 1, 4
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 4
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 6
	sndch4 3, 0, 6
	sndch4 0, 0, 6
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 1, 1, 0
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 2, 0, 4
	sndch4 1, 0, 1
	sndch4 1, 1, 0
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 6
	sndch4 3, 0, 6
	sndch4 0, 0, 6
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 1, 1, 0
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 4
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 4
	sndch4 3, 0, 6
	sndch4 0, 1, 4
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 4
	sndpop
SndHeader_09:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_09_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_09_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_09_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_09_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_09_Ch1:
	sndenv 1, SNDENV_DEC, 1
	sndenach SNDOUT_CH1R|SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L
	sndnr11 2, 0
	sndnote $0A
	sndlen 14
	sndpush $6FDC ; L1F6FDC
	sndpush $7009 ; L1F7009
	sndpush $7039 ; L1F7039
	sndnotebase $0C
	sndpush $7009 ; L1F7009
	sndnotebase $F4
	sndloop $6FC9 ; L1F6FC9 
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
	sndlenret $70
	sndlenret $70
	sndpop
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
	sndloopcnt $00, $02, $7009 ; L1F7009
	sndpop
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
	sndpop
SndData_09_Ch2:
	sndenv 7, SNDENV_INC, 0
	sndenach SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndnr21 3, 0
	sndnote $0D
	sndlen 7
	sndnote $0D
	sndpush $7083 ; L1F7083
	sndpush $70BA ; L1F70BA
	sndenv 3, SNDENV_INC, 0
	sndnr21 2, 0
	sndnote $00
	sndlen 10
	sndpush $7009 ; L1F7009
	sndpush $70D7 ; L1F70D7
	sndpush $7100 ; L1F7100
	sndloop $706B ; L1F706B 
	sndnote $0D
	sndlen 84
	sndlenret $0E
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
	sndpop
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
	sndloopcnt $00, $06, $70BA ; L1F70BA
	sndpop
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
	sndpop
	sndenv 7, SNDENV_INC, 0
	sndnr21 3, 0
	sndnote $1D
	sndlen 84
	sndlenret $0E
	sndnote $1D
	sndlen 7
	sndnote $1D
	sndnote $1D
	sndlen 84
	sndlenret $0E
	sndnote $1D
	sndlen 7
	sndnote $1D
	sndnote $1E
	sndlen 84
	sndlenret $0E
	sndnote $1E
	sndlen 7
	sndnote $1E
	sndnote $20
	sndlen 84
	sndlenret $0E
	sndnote $20
	sndlen 7
	sndnote $20
	sndloopcnt $00, $02, $7100 ; L1F7100
	sndpop
SndData_09_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH4R|SNDOUT_CH2L|SNDOUT_CH3L
	sndwave $04
	sndch3len $19
	sndnote $16
	sndlen 7
	sndnote $16
	sndpush $7140 ; L1F7140
	sndpush $7182 ; L1F7182
	sndpush $7182 ; L1F7182
	sndpush $718F ; L1F718F
	sndloop $7131 ; L1F7131 
	sndch3len $00
	sndnote $16
	sndlen 84
	sndlenret $0E
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
	sndlenret $0E
	sndch3len $19
	sndnote $16
	sndlen 7
	sndnote $16
	sndch3len $00
	sndnote $27
	sndlen 112
	sndlenret $70
	sndlenret $70
	sndpop
	sndch3len $32
	sndnote $16
	sndlen 28
	sndloopcnt $00, $0F, $7182 ; L1F7182
	sndnote $16
	sndlen 14
	sndnote $11
	sndpop
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
	sndnote $14
	sndlen 7
	sndloopcnt $00, $20, $719C ; L1F719C
	sndch3len $00
	sndnote $16
	sndlen 84
	sndlenret $0E
	sndch3len $19
	sndnote $16
	sndlen 7
	sndnote $16
	sndloopcnt $00, $04, $71A3 ; L1F71A3
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
	sndloopcnt $00, $04, $71B3 ; L1F71B3
	sndpop
SndData_09_Ch4:
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 7
	sndch4 3, 0, 2
	sndch4 0, 0, 7
	sndpush $71FE ; L1F71FE
	sndpush $721B ; L1F721B
	sndpush $71FE ; L1F71FE
	sndpush $723A ; L1F723A
	sndpush $71FE ; L1F71FE
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 1, 4
	sndch4 3, 0, 6
	sndch4 1, 1, 4
	sndch4 3, 0, 6
	sndch4 1, 1, 4
	sndch4 3, 0, 6
	sndch4 1, 1, 4
	sndpush $7259 ; L1F7259
	sndpush $72BE ; L1F72BE
	sndpush $7259 ; L1F7259
	sndpush $72D8 ; L1F72D8
	sndloop $71D6 ; L1F71D6 
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 6
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 1, 1, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 6
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 0, 1, 6
	sndpop
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 2, 1, 2
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 7
	sndch4 1, 0, 0
	sndch4 0, 0, 7
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 7
	sndch4 3, 0, 2
	sndch4 0, 0, 7
	sndpop
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 1, 4
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 2, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 2, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndenv 4, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 4, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 6
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 7
	sndch4 3, 0, 2
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 5
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 4
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 5
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 0, 7
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 0, 1, 6
	sndloopcnt $00, $14, $72BE ; L1F72BE
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 0, 7
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 1, 1, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 0, 7
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 0, 1, 6
	sndloopcnt $00, $08, $72D8 ; L1F72D8
	sndpop
SndHeader_07:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_07_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_07_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_07_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_07_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_07_Ch1:
	sndenv 7, SNDENV_DEC, 2
	sndenach SNDOUT_CH1R|SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L
	sndnr11 2, 0
	sndpush $7342 ; L1F7342
	sndpush $7356 ; L1F7356
	sndpush $736A ; L1F736A
	sndpush $73C5 ; L1F73C5
	sndpush $73DE ; L1F73DE
	sndpush $73F9 ; L1F73F9
	sndpush $73DE ; L1F73DE
	sndpush $7415 ; L1F7415
	sndpush $7430 ; L1F7430
	sndpush $747D ; L1F747D
	sndloop $731B ; L1F731B 
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
	sndpop
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
	sndpop
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
	sndlenret $15
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
	sndpop
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
	sndpop
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
	sndlenret $1C
	sndnote $00
	sndlen 14
	sndnote $20
	sndlen 28
	sndnote $22
	sndnote $20
	sndlen 7
	sndnote $00
	sndpop
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
	sndlenret $15
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
	sndpop
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
	sndlenret $15
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
	sndpop
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
	sndpop
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
	sndpop
SndData_07_Ch2:
	sndenv 6, SNDENV_DEC, 2
	sndenach SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndnr21 2, 0
	sndpush $74D0 ; L1F74D0
	sndpush $74E4 ; L1F74E4
	sndpush $74F8 ; L1F74F8
	sndpush $751A ; L1F751A
	sndpush $74F8 ; L1F74F8
	sndpush $753C ; L1F753C
	sndpush $7560 ; L1F7560
	sndpush $7578 ; L1F7578
	sndpush $7560 ; L1F7560
	sndpush $759A ; L1F759A
	sndpush $75C9 ; L1F75C9
	sndpush $75D4 ; L1F75D4
	sndpush $75DF ; L1F75DF
	sndloop $74A0 ; L1F74A0 
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
	sndpop
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
	sndpop
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
	sndpop
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
	sndpop
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
	sndpop
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
	sndloopcnt $00, $02, $7560 ; L1F7560
	sndpop
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
	sndpop
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
	sndpop
	sndnote $2C
	sndlen 7
	sndnote $20
	sndnote $27
	sndnote $20
	sndloopcnt $00, $0E, $75C9 ; L1F75C9
	sndpop
	sndnote $2C
	sndlen 7
	sndnote $20
	sndnote $25
	sndnote $20
	sndloopcnt $00, $06, $75D4 ; L1F75D4
	sndpop
	sndnote $2C
	sndlen 7
	sndnote $20
	sndnote $27
	sndnote $20
	sndloopcnt $00, $08, $75DF ; L1F75DF
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
	sndpop
SndData_07_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH4R|SNDOUT_CH2L|SNDOUT_CH3L
	sndwave $04
	sndch3len $32
	sndpush $7630 ; L1F7630
	sndpush $7644 ; L1F7644
	sndpush $7658 ; L1F7658
	sndpush $7678 ; L1F7678
	sndpush $7658 ; L1F7658
	sndpush $7696 ; L1F7696
	sndpush $76BA ; L1F76BA
	sndpush $76F4 ; L1F76F4
	sndpush $76BA ; L1F76BA
	sndpush $7709 ; L1F7709
	sndpush $7719 ; L1F7719
	sndpush $7740 ; L1F7740
	sndpush $7719 ; L1F7719
	sndpush $7767 ; L1F7767
	sndloop $75FB ; L1F75FB 
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
	sndpop
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
	sndpop
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
	sndpop
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
	sndlenret $07
	sndch3len $32
	sndnote $20
	sndnote $1D
	sndnote $14
	sndnote $1D
	sndnote $1C
	sndnote $12
	sndnote $17
	sndnote $1A
	sndpop
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
	sndpop
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
	sndpop
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
	sndpop
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
	sndpop
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
	sndpop
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
	sndpop
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
	sndpop
SndData_07_Ch4:
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndpush $77B5 ; L1F77B5
	sndpush $77D8 ; L1F77D8
	sndpush $77FB ; L1F77FB
	sndpush $782F ; L1F782F
	sndpush $7858 ; L1F7858
	sndpush $7887 ; L1F7887
	sndpush $7887 ; L1F7887
	sndloop $779B ; L1F779B 
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 6
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 6
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndloopcnt $00, $06, $77FB ; L1F77FB
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndloopcnt $00, $07, $7887 ; L1F7887
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 7
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 7
	sndpop
SndHeader_05:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_05_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_05_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_05_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_05_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_05_Ch1:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH1R|SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L
	sndnr11 2, 0
	sndpush $7904 ; L1F7904
	sndloop $78FE ; L1F78FE 
	sndnote $2A
	sndlen 60
	sndnote $29
	sndlen 80
	sndlenret $14
	sndlenret $78
	sndlenret $14
	sndnote $27
	sndlen 10
	sndnote $29
	sndnote $2A
	sndlen 120
	sndlenret $14
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
	sndlenret $14
	sndnote $2E
	sndlen 10
	sndnote $30
	sndnote $2C
	sndlen 80
	sndlenret $50
	sndlenret $78
	sndnote $29
	sndlen 13
	sndnote $2A
	sndlen 14
	sndnote $2E
	sndlen 13
	sndnote $2C
	sndlen 80
	sndlenret $50
	sndlenret $50
	sndlenret $50
	sndnote $2C
	sndlen 80
	sndlenret $14
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
	sndlenret $14
	sndnote $27
	sndlen 10
	sndnote $28
	sndnote $27
	sndlen 80
	sndlenret $50
	sndnote $2C
	sndlen 80
	sndlenret $14
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
	sndlenret $50
	sndnote $2F
	sndlen 120
	sndlenret $14
	sndnote $2E
	sndlen 10
	sndnote $2F
	sndnote $2E
	sndlen 120
	sndlenret $14
	sndnote $2E
	sndlen 10
	sndnote $2F
	sndnote $31
	sndlen 80
	sndlenret $14
	sndnote $31
	sndnote $2F
	sndnote $2E
	sndnote $2F
	sndlen 120
	sndlenret $14
	sndnote $2C
	sndlen 10
	sndnote $2F
	sndnote $34
	sndlen 120
	sndlenret $14
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
	sndlenret $14
	sndnote $2C
	sndlen 10
	sndnote $2F
	sndnote $34
	sndlen 80
	sndlenret $14
	sndnote $34
	sndnote $33
	sndnote $31
	sndnote $2F
	sndlen 80
	sndlenret $50
	sndlenret $50
	sndlenret $50
	sndpop
SndData_05_Ch2:
	sndenv 1, SNDENV_DEC, 1
	sndenach SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndnr21 2, 0
	sndnote $01
	sndlen 10
	sndlenret $05
	sndenv 3, SNDENV_DEC, 7
	sndpush $7904 ; L1F7904
	sndloop $79B6 ; L1F79B6 
SndData_05_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH4R|SNDOUT_CH2L|SNDOUT_CH3L
	sndwave $01
	sndch3len $00
	sndpush $7A03 ; L1F7A03
	sndpush $7A12 ; L1F7A12
	sndpush $7A03 ; L1F7A03
	sndnote $19
	sndlen 20
	sndnote $20
	sndnote $25
	sndnote $29
	sndnote $25
	sndnote $29
	sndnote $25
	sndnote $29
	sndpush $7A34 ; L1F7A34
	sndpush $7A43 ; L1F7A43
	sndpush $7A34 ; L1F7A34
	sndpush $7A43 ; L1F7A43
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
	sndpush $7A34 ; L1F7A34
	sndpush $7A52 ; L1F7A52
	sndpush $7A34 ; L1F7A34
	sndpush $7A43 ; L1F7A43
	sndloop $79BC ; L1F79BC 
	sndnote $19
	sndlen 20
	sndnote $20
	sndnote $25
	sndnote $29
	sndnote $25
	sndnote $29
	sndnote $25
	sndnote $29
	sndloopcnt $00, $02, $7A03 ; L1F7A03
	sndpop
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
	sndloopcnt $00, $02, $7A12 ; L1F7A12
	sndpop
	sndnote $18 ;X
	sndlen 20 ;X
	sndnote $20 ;X
	sndnote $24 ;X
	sndnote $27 ;X
	sndnote $24 ;X
	sndnote $27 ;X
	sndnote $24 ;X
	sndnote $27 ;X
	sndpop ;X
	sndnote $1C
	sndlen 20
	sndnote $20
	sndnote $23
	sndnote $28
	sndnote $23
	sndnote $28
	sndnote $23
	sndnote $28
	sndloopcnt $00, $02, $7A34 ; L1F7A34
	sndpop
	sndnote $1B
	sndlen 20
	sndnote $1E
	sndnote $23
	sndnote $27
	sndnote $23
	sndnote $27
	sndnote $23
	sndnote $27
	sndloopcnt $00, $02, $7A43 ; L1F7A43
	sndpop
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
	sndpop
SndData_05_Ch4:
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndpush $7A6F ; L1F7A6F
	sndpush $7A8B ; L1F7A8B
	sndloop $7A69 ; L1F7A69 
	sndenv 5, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 1, 2
	sndenv 4, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 1, 2
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 1, 2
	sndenv 2, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 5, 0, 0
	sndlenret $0A
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 2, 1, 0
	sndloopcnt $00, $09, $7A6F ; L1F7A6F
	sndpop
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 5, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 1, 2
	sndenv 4, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndch4 0, 1, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 4, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 1, 6
	sndenv 4, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 2, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 1, 1, 6
	sndenv 2, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 2
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndch4 2, 1, 0
	sndpop
SndHeader_02:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_02_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_02_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_02_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_02_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_02_Ch1:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH1R|SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L
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
SndData_02_Ch2:
	sndenv 6, SNDENV_DEC, 7
	sndenach SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
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
SndData_02_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH4R|SNDOUT_CH2L|SNDOUT_CH3L
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
SndData_02_Ch4:
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 3
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 3
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 6
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 4
	sndch4 3, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 5
	sndch4 2, 0, 4
	sndch4 0, 0, 4
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 5
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 5
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 4
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndch4 0, 0, 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndch4 2, 0, 4
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndch4 3, 0, 6
	sndch4 0, 0, 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 6
	sndch4 2, 0, 4
	sndch4 0, 1, 6
	sndendch

SndHeader_01:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_01_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR; Sound channel ptr
	dw SndData_01_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_01_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR; Sound channel ptr
	dw SndData_01_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_01_Ch1:
	sndenv 1, SNDENV_DEC, 1
	sndenach SNDOUT_CH1R|SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L
	sndnr11 3, 0
	sndnote $0A
	sndlen 48
	sndenv 7, SNDENV_DEC, 6
	sndpush $7C11 ; L1F7C11
	sndpush $7C29 ; L1F7C29
	sndpush $7C11 ; L1F7C11
	sndpush $7C30 ; L1F7C30
	sndloop $7C02 ; L1F7C02 
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
	sndpop
	sndnote $0F
	sndlen 6
	sndnote $00
	sndnote $0D
	sndnote $08
	sndlen 12
	sndpop
	sndnote $0F
	sndlen 12
	sndnote $08
	sndlen 6
	sndnote $0F
	sndlen 12
	sndpop
SndData_01_Ch2:
	sndenv 1, SNDENV_DEC, 1
	sndenach SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndnr21 2, 0
	sndnote $0A
	sndlen 48
	sndenv 5, SNDENV_DEC, 2
	sndpush $7C4A ; L1F7C4A
	sndpush $7C5A ; L1F7C5A
	sndloop $7C41 ; L1F7C41 
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
	sndloopcnt $00, $03, $7C4A ; L1F7C4A
	sndpop
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
	sndpop
SndData_01_Ch3:
	sndenvch3 0
	sndenach SNDOUT_CH4R|SNDOUT_CH2L|SNDOUT_CH3L
	sndwave $04
	sndch3len $32
	sndnote $0A
	sndlen 48
	sndenvch3 2
	sndpush $7C80 ; L1F7C80
	sndpush $7C96 ; L1F7C96
	sndpush $7C80 ; L1F7C80
	sndpush $7CA9 ; L1F7CA9
	sndloop $7C71 ; L1F7C71 
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
	sndpop
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
	sndpop
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
	sndpop
SndData_01_Ch4:
	sndenach SNDOUT_CH2R|SNDOUT_CH3R|SNDOUT_CH1L|SNDOUT_CH2L
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 4
	sndch4 2, 0, 4
	sndch4 0, 0, 6
	sndch4 2, 0, 4
	sndch4 0, 1, 4
	sndch4 2, 0, 4
	sndch4 0, 0, 6
	sndch4 2, 0, 4
	sndch4 0, 0, 6
	sndpush $7CD4 ; L1F7CD4
	sndloop $7CCE ; L1F7CCE 
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 4
	sndch4 3, 0, 6
	sndch4 0, 1, 4
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 1, 0
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 4
	sndch4 3, 0, 6
	sndch4 0, 1, 4
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 2
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 6
	sndch4 3, 0, 6
	sndch4 0, 1, 4
	sndch4 3, 0, 6
	sndch4 0, 1, 4
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 4
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 4
	sndch4 3, 0, 6
	sndch4 0, 0, 6
	sndch4 6, 0, 1
	sndch4 0, 1, 4
	sndch4 3, 0, 6
	sndch4 0, 1, 4
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 1, 0
	sndch4 6, 0, 1
	sndch4 0, 1, 4
	sndch4 3, 0, 6
	sndch4 0, 1, 4
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 1, 0
	sndch4 3, 0, 6
	sndch4 0, 1, 4
	sndch4 3, 0, 6
	sndch4 0, 1, 4
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 1, 0, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 0, 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 0, 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndch4 0, 1, 4
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndch4 0, 1, 4
	sndch4 2, 0, 4
	sndch4 0, 0, 6
	sndch4 2, 0, 4
	sndch4 0, 0, 6
	sndpop
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
	snderr $1F ;X
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
	
IF NO_SGB_SOUND	
	; Space intentionally left blank
ELSE
	; Determine which of the 3 bytes to pick and what to do with it
	ld   a, [wMisc_C025]
	bit  MISCB_IS_SGB, a	; SGB hardware?
	jp   z, .dmg			; If not, jump

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
ENDC	
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
.act00: db SND_ID_1B, SGB_SND_A_LASER_SM, $00
.act01: db SND_ID_15, SGB_SND_A_FASTJUMP, $00
.act02: db SND_ID_15, SGB_SND_A_FASTJUMP, $01
.act03: db SND_ID_15, SGB_SND_A_FASTJUMP, $02
.act04: db SND_ID_15, SGB_SND_A_FASTJUMP, $03
.act05: db SND_ID_10, SGB_SND_A_FADEIN, $03
.act06: db SND_ID_0F, SGB_SND_A_GLASSBREAK, $03
.act07: db SND_ID_12, SGB_SND_A_ATTACK_B, $03
.act08: db SND_ID_13, SGB_SND_A_ATTACK_B, $02
.act09: db SND_ID_14, SGB_SND_A_GATE, $03
.act0A: db SND_ID_16, SGB_SND_A_PUNCH_A, $03
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
.act16: db SND_ID_13, SGB_SND_A_SWORDSWING, $02 ; [TCRF] Unused?
.act17: db SND_ID_2B, SGB_SND_A_JETSTART, $01
.act18: db SND_ID_2B, SGB_SND_A_PICTFLOAT, $03
.act19: db SND_ID_2D, SGB_SND_A_JETPROJ_B, $03
.act1A: db SND_ID_27, SGB_SND_A_SELECT_B, $03
.act1B: db SND_ID_15, SGB_SND_A_PUNCH_B, $03
.act1C: db SND_ID_30, SGB_SND_A_SELECT_C, $03

; =============== END OF BANK? ===============
	sndch4 0, 0, 0
	sndch4 8, 0, 0
	sndch4 4, 0, 0
	sndch4 12, 0, 0
	sndch4 2, 0, 0
	sndch4 10, 0, 0
	sndch4 6, 0, 0
	snderr $00
	sndch4 1, 0, 0
	sndch4 9, 0, 0
	sndch4 5, 0, 0
	sndch4 13, 0, 0
	sndch4 3, 0, 0
	sndch4 11, 0, 0
	sndch4 7, 0, 0
	sndclrskip
	sndch4 0, 1, 0
	sndch4 8, 1, 0
	sndch4 4, 1, 0
	sndch4 12, 1, 0
	sndch4 2, 1, 0
	sndch4 10, 1, 0
	sndch4 6, 1, 0
	snd_UNUSED_nr10 1, 1, 0
	sndch4 9, 1, 0
	sndch4 5, 1, 0
	sndch4 13, 1, 0
	sndch4 3, 1, 0
	sndch4 11, 1, 0
	sndch4 7, 1, 0
	snderr $18
	sndch4 0, 0, 4
	sndch4 8, 0, 4
	sndch4 4, 0, 4
	sndch4 12, 0, 4
	sndch4 2, 0, 4
	sndch4 10, 0, 4
	sndch4 6, 0, 4
	sndenv 1, SNDENV_DEC, 4
	sndch4 9, 0, 4
	sndch4 5, 0, 4
	sndch4 13, 0, 4
	sndch4 3, 0, 4
	sndch4 11, 0, 4
	sndch4 7, 0, 4
	snd_UNUSED_endchflag7F
	sndch4 0, 1, 4
	sndch4 8, 1, 4
	sndch4 4, 1, 4
	sndch4 12, 1, 4
	sndch4 2, 1, 4
	sndch4 10, 1, 4
	sndch4 6, 1, 4
	sndpush $9C1C ; L1F9C1C
	sndch4 5, 1, 4
	sndch4 13, 1, 4
	sndch4 3, 1, 4
	sndch4 11, 1, 4
	sndch4 7, 1, 4
	snderr $1C
	sndch4 0, 0, 2
	sndch4 8, 0, 2
	sndch4 4, 0, 2
	sndch4 12, 0, 2
	sndch4 2, 0, 2
	sndch4 10, 0, 2
	sndch4 6, 0, 2
	snderr $02
	sndch4 1, 0, 2
	sndch4 9, 0, 2
	sndch4 5, 0, 2
	sndch4 13, 0, 2
	sndch4 3, 0, 2
	sndch4 11, 0, 2
	sndch4 7, 0, 2
	snd_UNUSED_clrstat6
	sndch4 0, 1, 2
	sndch4 8, 1, 2
	sndch4 4, 1, 2
	sndch4 12, 1, 2
	sndch4 2, 1, 2
	sndch4 10, 1, 2
	sndch4 6, 1, 2
	snderr $0A
	sndch4 1, 1, 2
	sndch4 9, 1, 2
	sndch4 5, 1, 2
	sndch4 13, 1, 2
	sndch4 3, 1, 2
	sndch4 11, 1, 2
	sndch4 7, 1, 2
	sndlenret $06
	sndch4 8, 0, 6
	sndch4 4, 0, 6
	sndch4 12, 0, 6
	sndch4 2, 0, 6
	sndch4 10, 0, 6
	sndch4 6, 0, 6
	sndnotebase $16
	sndch4 9, 0, 6
	sndch4 5, 0, 6
	sndch4 13, 0, 6
	sndch4 3, 0, 6
	sndch4 11, 0, 6
	sndch4 7, 0, 6
	snd_UNUSED_endchflagBF
	sndch4 0, 1, 6
	sndch4 8, 1, 6
	sndch4 4, 1, 6
	sndch4 12, 1, 6
	sndch4 2, 1, 6
	sndch4 10, 1, 6
	sndch4 6, 1, 6
	sndnr41 30
	sndch4 9, 1, 6
	sndch4 5, 1, 6
	sndch4 13, 1, 6
	sndch4 3, 1, 6
	sndch4 11, 1, 6
	sndch4 7, 1, 6
	snderr $1E
	sndch4 0, 0, 1
	sndch4 8, 0, 1
	sndch4 4, 0, 1
	sndch4 12, 0, 1
	sndch4 2, 0, 1
	sndch4 10, 0, 1
	sndch4 6, 0, 1
	snderr $01
	sndch4 1, 0, 1
	sndch4 9, 0, 1
	sndch4 5, 0, 1
	sndch4 13, 0, 1
	sndch4 3, 0, 1
	sndch4 11, 0, 1
	sndch4 7, 0, 1
	snd_UNUSED_setstat6
	sndch4 0, 1, 1
	sndch4 8, 1, 1
	sndch4 4, 1, 1
	sndch4 12, 1, 1
	sndch4 2, 1, 1
	sndch4 10, 1, 1
	sndch4 6, 1, 1
	sndenach SNDOUT_CH1R|SNDOUT_CH3R|SNDOUT_CH2L
	sndch4 9, 1, 1
	sndch4 5, 1, 1
	sndch4 13, 1, 1
	sndch4 3, 1, 1
	sndch4 11, 1, 1
	sndch4 7, 1, 1
	snderr $19
	sndch4 0, 0, 5
	sndch4 8, 0, 5
	sndch4 4, 0, 5
	sndch4 12, 0, 5
	sndch4 2, 0, 5
	sndch4 10, 0, 5
	sndch4 6, 0, 5
	sndloop $9515 ; L1F9515 
	sndch4 5, 0, 5
	sndch4 13, 0, 5
	sndch4 3, 0, 5
	sndch4 11, 0, 5
	sndch4 7, 0, 5
	sndch3len $0D
	sndch4 8, 1, 5
	sndch4 4, 1, 5
	sndch4 12, 1, 5
	sndch4 2, 1, 5
	sndch4 10, 1, 5
	sndch4 6, 1, 5
	sndpop
	sndch4 1, 1, 5
	sndch4 9, 1, 5
	sndch4 5, 1, 5
	sndch4 13, 1, 5
	sndch4 3, 1, 5
	sndch4 11, 1, 5
	sndch4 7, 1, 5
	snderr $1D
	sndch4 0, 0, 3
	sndch4 8, 0, 3
	sndch4 4, 0, 3
	sndch4 12, 0, 3
	sndch4 2, 0, 3
	sndch4 10, 0, 3
	sndch4 6, 0, 3
	sndendch
	sndch4 1, 0, 3
	sndch4 9, 0, 3
	sndch4 5, 0, 3
	sndch4 13, 0, 3
	sndch4 3, 0, 3
	sndch4 11, 0, 3
	sndch4 7, 0, 3
	sndwave $0B ;X
	sndch4 8, 1, 3 ;X
	sndch4 4, 1, 3
	sndch4 12, 1, 3
	sndch4 2, 1, 3
	sndch4 10, 1, 3
	sndch4 6, 1, 3
	snderr $0B
	sndch4 1, 1, 3
	sndch4 9, 1, 3
	sndch4 5, 1, 3
	sndch4 13, 1, 3
	sndch4 3, 1, 3
	sndch4 11, 1, 3
	sndch4 7, 1, 3
	snderr $1B
	sndch4 0, 0, 7
	sndch4 8, 0, 7
	sndch4 4, 0, 7
	sndch4 12, 0, 7
	sndch4 2, 0, 7
	sndch4 10, 0, 7
	sndch4 6, 0, 7
	sndloopcnt $17, $97, $D757 ; L1FD757
	sndch4 3, 0, 7
	sndch4 11, 0, 7
	sndch4 7, 0, 7
	snderr $17
	sndch4 0, 1, 7
	sndch4 8, 1, 7
	sndch4 4, 1, 7
	sndch4 12, 1, 7
	sndch4 2, 1, 7
	sndch4 10, 1, 7
	sndch4 6, 1, 7
	sndsetskip
	sndch4 1, 1, 7
	sndch4 9, 1, 7
	sndch4 5, 1, 7
	sndch4 13, 1, 7
	sndch4 3, 1, 7
	sndch4 11, 1, 7
	sndch4 7, 1, 7
	snderr $1F
	sndch4 3, 0, 0 ;X
	sndch4 3, 0, 1 ;X
	sndch4 3, 0, 2 ;X
	sndch4 3, 0, 3 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0
	sndch4 2, 1, 3
	sndch4 2, 1, 6 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 1, 1, 6 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 2, 1, 7 ;X
	sndch4 2, 1, 5
	sndch4 2, 1, 1
	sndch4 1, 1, 5
	sndch4 0, 0, 0 ;X
	sndch4 1, 1, 7
	sndch4 2, 0, 0
	sndch4 2, 0, 1
	sndch4 2, 0, 2
	sndch4 2, 0, 3 ;X
	sndch4 2, 0, 4 ;X
	sndch4 2, 0, 5 ;X
	sndch4 2, 0, 6 ;X
	sndch4 2, 0, 7
	sndch4 2, 1, 0
	sndch4 2, 1, 2 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 2, 1, 4
	sndch4 1, 1, 4
	sndch4 0, 0, 2
	sndch4 0, 0, 3
	sndch4 0, 0, 4
	sndch4 0, 0, 5
	sndch4 0, 0, 6
	sndch4 0, 0, 7
	sndch4 0, 1, 0
	sndch4 0, 1, 1
	sndch4 0, 1, 2
	sndch4 0, 1, 3
	sndch4 0, 1, 4
	sndch4 0, 1, 5
	sndch4 0, 1, 6
	sndch4 0, 1, 7
	sndch4 1, 0, 0
	sndch4 1, 0, 1
	sndch4 1, 0, 2 ;X
	sndch4 1, 0, 3
	sndch4 1, 0, 4
	sndch4 1, 0, 5
	sndch4 1, 0, 6
	sndch4 1, 0, 7
	sndch4 1, 1, 0
	sndch4 1, 1, 1
	sndch4 1, 1, 2
	sndch4 1, 1, 3
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 1, 1, 6
	sndch4 3, 0, 4 ;X
	sndch4 3, 0, 5 ;X
	sndch4 3, 0, 6
	sndch4 3, 0, 7 ;X
	sndch4 3, 1, 0
	sndch4 3, 1, 1 ;X
	sndch4 3, 1, 2
	sndch4 3, 1, 3 ;X
	sndch4 3, 1, 4
	sndch4 3, 1, 5
	sndch4 3, 1, 6 ;X
	sndch4 3, 1, 7
	sndch4 4, 0, 0 ;X
	sndch4 4, 0, 1
	sndch4 4, 0, 2
	sndch4 4, 0, 3 ;X
	sndch4 4, 0, 4
	sndch4 4, 0, 5
	sndch4 4, 0, 6
	sndch4 4, 0, 7 ;X
	sndch4 4, 1, 0 ;X
	sndch4 4, 1, 1 ;X
	sndch4 4, 1, 2 ;X
	sndch4 4, 1, 3 ;X
	sndch4 4, 1, 4 ;X
	sndch4 4, 1, 5 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 4, 0, 7
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 4, 1, 0
	sndch4 4, 1, 3
	sndch4 4, 1, 4
	sndch4 4, 1, 5 ;X
	sndch4 4, 1, 6
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 4, 1, 7
	sndch4 5, 0, 0
	sndch4 5, 0, 1
	sndch4 5, 0, 2
	sndch4 2, 1, 1
	sndch4 5, 0, 3
	sndch4 5, 0, 4
	sndch4 5, 0, 5
	sndch4 5, 0, 6
	sndch4 5, 0, 7
	sndch4 5, 1, 0
	sndch4 5, 1, 1
	sndch4 5, 1, 2
	sndch4 5, 1, 3
	sndch4 5, 1, 4
	sndch4 5, 1, 5
	sndch4 5, 1, 6
	sndch4 5, 1, 7
	sndch4 6, 0, 0
	sndch4 6, 0, 1
	sndch4 6, 0, 2
	sndch4 6, 0, 3
	sndch4 6, 0, 4
	sndch4 6, 0, 5
	sndch4 6, 0, 6
	sndch4 6, 0, 7
	sndch4 6, 1, 0
	sndch4 6, 1, 1
	sndch4 6, 1, 2
	sndch4 6, 1, 3
	sndch4 6, 1, 4
	sndch4 6, 1, 5
	sndch4 6, 1, 6
	sndch4 6, 1, 7
	sndch4 7, 0, 0
	sndch4 7, 0, 1
	sndch4 7, 0, 2
	sndch4 7, 0, 3
	sndch4 7, 0, 4
	sndch4 7, 0, 5
	sndch4 7, 0, 6
	sndch4 7, 0, 7
	sndch4 7, 1, 0
	sndch4 7, 1, 1
	sndch4 7, 1, 2
	sndch4 7, 1, 3
	sndch4 7, 1, 4
	sndch4 7, 1, 5
	sndch4 7, 1, 6
	sndch4 7, 1, 7
	sndch4 4, 1, 2
	sndch4 4, 1, 1
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 0, 0, 0 ;X
	sndch4 1, 1, 7
	sndch4 2, 0, 0
	sndch4 2, 0, 1
	sndch4 2, 0, 2
	sndch4 2, 0, 3
	sndch4 2, 0, 4
	sndch4 2, 0, 5
	sndch4 2, 0, 6
	sndch4 2, 0, 7
	sndch4 2, 1, 0
	sndch4 0, 0, 2
	sndch4 0, 0, 3
	sndch4 0, 0, 4
	sndch4 0, 0, 5
	sndch4 0, 0, 6
	sndch4 0, 0, 7
