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
SndData_0E_Ch2: db $E4
L1F485D: db $C3
L1F485E: db $E9
L1F485F: db $22
L1F4860: db $EE
L1F4861: db $C0
L1F4862: db $A2
L1F4863: db $02
L1F4864: db $A5
L1F4865: db $A9
L1F4866: db $AC
L1F4867: db $E4
L1F4868: db $73
L1F4869: db $A2
L1F486A: db $A5
L1F486B: db $A9
L1F486C: db $AC
L1F486D: db $E4
L1F486E: db $43
L1F486F: db $A2
L1F4870: db $A5
L1F4871: db $A9
L1F4872: db $AC
L1F4873: db $E4
L1F4874: db $23
L1F4875: db $A2
L1F4876: db $A5
L1F4877: db $A9
L1F4878: db $AC
L1F4879: db $E3
SndHeader_0F:
	db $01 ; Number of channels
.ch2:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_0F_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_0F_Ch2: db $E4
L1F4882: db $F2
L1F4883: db $E9
L1F4884: db $22
L1F4885: db $EE
L1F4886: db $C0
L1F4887: db $9D
L1F4888: db $02
L1F4889: db $A5
L1F488A: db $A0
L1F488B: db $A9
L1F488C: db $A5
L1F488D: db $AC
L1F488E: db $A9
L1F488F: db $B1
L1F4890: db $E4
L1F4891: db $92
L1F4892: db $9D
L1F4893: db $02
L1F4894: db $A5
L1F4895: db $A0
L1F4896: db $A9
L1F4897: db $A5
L1F4898: db $AC
L1F4899: db $A9
L1F489A: db $B1
L1F489B: db $E4
L1F489C: db $52
L1F489D: db $9D
L1F489E: db $02
L1F489F: db $A5
L1F48A0: db $A0
L1F48A1: db $A9
L1F48A2: db $A5
L1F48A3: db $AC
L1F48A4: db $A9
L1F48A5: db $B1
L1F48A6: db $E4
L1F48A7: db $22
L1F48A8: db $9D
L1F48A9: db $02
L1F48AA: db $A5
L1F48AB: db $A0
L1F48AC: db $A9
L1F48AD: db $A5
L1F48AE: db $AC
L1F48AF: db $A9
L1F48B0: db $B1
L1F48B1: db $E3
SndHeader_10:
	db $01 ; Number of channels
.ch2:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_10_Ch2 ; Data ptr
	db $0C ; Base freq/note id
	db $81 ; Unused
SndData_10_Ch2: db $E4
L1F48BA: db $6A
L1F48BB: db $E9
L1F48BC: db $22
L1F48BD: db $EE
L1F48BE: db $00
L1F48BF: db $EC
L1F48C0: db $FF
L1F48C1: db $48
L1F48C2: db $E6
L1F48C3: db $01
L1F48C4: db $EC
L1F48C5: db $FF
L1F48C6: db $48
L1F48C7: db $E6
L1F48C8: db $01
L1F48C9: db $EC
L1F48CA: db $FF
L1F48CB: db $48
L1F48CC: db $E6
L1F48CD: db $01
L1F48CE: db $EC
L1F48CF: db $FF
L1F48D0: db $48
L1F48D1: db $E6
L1F48D2: db $01
L1F48D3: db $EC
L1F48D4: db $FF
L1F48D5: db $48
L1F48D6: db $E6
L1F48D7: db $01
L1F48D8: db $EC
L1F48D9: db $FF
L1F48DA: db $48
L1F48DB: db $E6
L1F48DC: db $01
L1F48DD: db $EC
L1F48DE: db $FF
L1F48DF: db $48
L1F48E0: db $E6
L1F48E1: db $01
L1F48E2: db $EC
L1F48E3: db $FF
L1F48E4: db $48
L1F48E5: db $E6
L1F48E6: db $01
L1F48E7: db $EC
L1F48E8: db $FF
L1F48E9: db $48
L1F48EA: db $E6
L1F48EB: db $01
L1F48EC: db $EC
L1F48ED: db $FF
L1F48EE: db $48
L1F48EF: db $E6
L1F48F0: db $01
L1F48F1: db $EC
L1F48F2: db $FF
L1F48F3: db $48
L1F48F4: db $E6
L1F48F5: db $01
L1F48F6: db $EC
L1F48F7: db $FF
L1F48F8: db $48
L1F48F9: db $E6
L1F48FA: db $01
L1F48FB: db $EC
L1F48FC: db $FF
L1F48FD: db $48
L1F48FE: db $E3
L1F48FF: db $A5
L1F4900: db $01
L1F4901: db $A6
L1F4902: db $A7
L1F4903: db $A6
L1F4904: db $E7
L1F4905: db $00
L1F4906: db $02
L1F4907: db $FF
L1F4908: db $48
L1F4909: db $ED
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
SndData_11_Ch2: db $E4
L1F491E: db $94
L1F491F: db $E9
L1F4920: db $22
L1F4921: db $EE
L1F4922: db $40
L1F4923: db $80
L1F4924: db $06
L1F4925: db $A2
L1F4926: db $02
L1F4927: db $AE
L1F4928: db $06
L1F4929: db $E4
L1F492A: db $77
L1F492B: db $A2
L1F492C: db $01
L1F492D: db $AE
L1F492E: db $05
L1F492F: db $E4
L1F4930: db $57
L1F4931: db $A2
L1F4932: db $01
L1F4933: db $AE
L1F4934: db $05
L1F4935: db $E4
L1F4936: db $37
L1F4937: db $A2
L1F4938: db $01
L1F4939: db $AE
L1F493A: db $05
L1F493B: db $E4
L1F493C: db $27
L1F493D: db $A2
L1F493E: db $01
L1F493F: db $AE
L1F4940: db $1D
L1F4941: db $E3
SndData_11_Ch3: db $E4
L1F4943: db $40
L1F4944: db $E3
SndData_11_Ch4: db $E4
L1F4946: db $F2
L1F4947: db $E9
L1F4948: db $88
L1F4949: db $71
L1F494A: db $06
L1F494B: db $E3
SndHeader_12:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_12_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_12_Ch4: db $E4
L1F4954: db $79
L1F4955: db $E9
L1F4956: db $88
L1F4957: db $37
L1F4958: db $01
L1F4959: db $EF
L1F495A: db $36
L1F495B: db $01
L1F495C: db $35
L1F495D: db $01
L1F495E: db $34
L1F495F: db $01
L1F4960: db $33
L1F4961: db $01
L1F4962: db $32
L1F4963: db $01
L1F4964: db $31
L1F4965: db $01
L1F4966: db $30
L1F4967: db $01
L1F4968: db $F0
L1F4969: db $E3
SndHeader_13:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_13_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_13_Ch4: db $E4
L1F4972: db $39
L1F4973: db $E9
L1F4974: db $88
L1F4975: db $47
L1F4976: db $02
L1F4977: db $EF
L1F4978: db $46
L1F4979: db $02
L1F497A: db $45
L1F497B: db $02
L1F497C: db $44
L1F497D: db $02
L1F497E: db $43
L1F497F: db $02
L1F4980: db $42
L1F4981: db $02
L1F4982: db $41
L1F4983: db $02
L1F4984: db $40
L1F4985: db $02
L1F4986: db $F0
L1F4987: db $E3
SndHeader_14:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_14_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_14_Ch4: db $E4
L1F4990: db $F7
L1F4991: db $E9
L1F4992: db $88
L1F4993: db $37
L1F4994: db $01
L1F4995: db $45
L1F4996: db $01
L1F4997: db $37
L1F4998: db $01
L1F4999: db $EF
L1F499A: db $24
L1F499B: db $01
L1F499C: db $55
L1F499D: db $01
L1F499E: db $E3
SndHeader_15:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_15_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_15_Ch4: db $E4
L1F49A7: db $B7
L1F49A8: db $E9
L1F49A9: db $88
L1F49AA: db $27
L1F49AB: db $02
L1F49AC: db $45
L1F49AD: db $02
L1F49AE: db $17
L1F49AF: db $02
L1F49B0: db $EF
L1F49B1: db $14
L1F49B2: db $02
L1F49B3: db $17
L1F49B4: db $02
L1F49B5: db $F0
L1F49B6: db $E3
SndHeader_16:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_16_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_16_Ch4: db $E4
L1F49BF: db $F2
L1F49C0: db $E9
L1F49C1: db $88
L1F49C2: db $71
L1F49C3: db $05
L1F49C4: db $00
L1F49C5: db $01
L1F49C6: db $35
L1F49C7: db $06
L1F49C8: db $E3
SndHeader_17:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_17_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_17_Ch4: db $E4
L1F49D1: db $F2
L1F49D2: db $E9
L1F49D3: db $88
L1F49D4: db $40
L1F49D5: db $01
L1F49D6: db $EF
L1F49D7: db $41
L1F49D8: db $01
L1F49D9: db $42
L1F49DA: db $01
L1F49DB: db $43
L1F49DC: db $01
L1F49DD: db $44
L1F49DE: db $01
L1F49DF: db $45
L1F49E0: db $01
L1F49E1: db $46
L1F49E2: db $01
L1F49E3: db $47
L1F49E4: db $01
L1F49E5: db $F0
L1F49E6: db $35
L1F49E7: db $01
L1F49E8: db $EF
L1F49E9: db $34
L1F49EA: db $01
L1F49EB: db $33
L1F49EC: db $01
L1F49ED: db $32
L1F49EE: db $01
L1F49EF: db $31
L1F49F0: db $01
L1F49F1: db $30
L1F49F2: db $E3
SndHeader_1A:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_1A_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_1A_Ch4: db $E4
L1F49FB: db $F7
L1F49FC: db $E9
L1F49FD: db $88
L1F49FE: db $45
L1F49FF: db $02
L1F4A00: db $27
L1F4A01: db $03
L1F4A02: db $35
L1F4A03: db $02
L1F4A04: db $27
L1F4A05: db $02
L1F4A06: db $34
L1F4A07: db $08
L1F4A08: db $71
L1F4A09: db $02
L1F4A0A: db $54
L1F4A0B: db $02
L1F4A0C: db $47
L1F4A0D: db $02
L1F4A0E: db $64
L1F4A0F: db $0A
L1F4A10: db $71
L1F4A11: db $64
L1F4A12: db $E3
SndHeader_1B:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_1B_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_1B_Ch4: db $E4
L1F4A1B: db $F3
L1F4A1C: db $E9
L1F4A1D: db $88
L1F4A1E: db $36
L1F4A1F: db $02
L1F4A20: db $72
L1F4A21: db $02
L1F4A22: db $36
L1F4A23: db $03
L1F4A24: db $57
L1F4A25: db $0A
L1F4A26: db $E3
SndHeader_1C:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_1C_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_1C_Ch4: db $E4
L1F4A2F: db $29
L1F4A30: db $E9
L1F4A31: db $88
L1F4A32: db $30
L1F4A33: db $02
L1F4A34: db $EF
L1F4A35: db $31
L1F4A36: db $02
L1F4A37: db $32
L1F4A38: db $02
L1F4A39: db $33
L1F4A3A: db $02
L1F4A3B: db $34
L1F4A3C: db $02
L1F4A3D: db $35
L1F4A3E: db $02
L1F4A3F: db $36
L1F4A40: db $02
L1F4A41: db $37
L1F4A42: db $02
L1F4A43: db $36
L1F4A44: db $02
L1F4A45: db $35
L1F4A46: db $02
L1F4A47: db $34
L1F4A48: db $02
L1F4A49: db $33
L1F4A4A: db $02
L1F4A4B: db $32
L1F4A4C: db $02
L1F4A4D: db $31
L1F4A4E: db $02
L1F4A4F: db $30
L1F4A50: db $02
L1F4A51: db $E3
SndHeader_1D:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_1D_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_1D_Ch4: db $E4
L1F4A5A: db $F7
L1F4A5B: db $E9
L1F4A5C: db $88
L1F4A5D: db $47
L1F4A5E: db $01
L1F4A5F: db $55
L1F4A60: db $01
L1F4A61: db $00
L1F4A62: db $01
L1F4A63: db $47
L1F4A64: db $01
L1F4A65: db $EF
L1F4A66: db $34
L1F4A67: db $01
L1F4A68: db $55
L1F4A69: db $01
L1F4A6A: db $E3
SndHeader_26:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_26_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_26_Ch4: db $E4
L1F4A73: db $A1
L1F4A74: db $E9
L1F4A75: db $88
L1F4A76: db $51
L1F4A77: db $02
L1F4A78: db $45
L1F4A79: db $02
L1F4A7A: db $00
L1F4A7B: db $02
L1F4A7C: db $41
L1F4A7D: db $02
L1F4A7E: db $27
L1F4A7F: db $02
L1F4A80: db $08
L1F4A81: db $01
L1F4A82: db $00
L1F4A83: db $01
L1F4A84: db $E3
SndHeader_27:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_27_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_27_Ch4: db $E4
L1F4A8D: db $F2
L1F4A8E: db $E9
L1F4A8F: db $88
L1F4A90: db $61
L1F4A91: db $03
L1F4A92: db $00
L1F4A93: db $01
L1F4A94: db $25
L1F4A95: db $04
L1F4A96: db $E3
SndHeader_28:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_28_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_28_Ch4: db $E4
L1F4A9F: db $F7
L1F4AA0: db $E9
L1F4AA1: db $88
L1F4AA2: db $45
L1F4AA3: db $01
L1F4AA4: db $EF
L1F4AA5: db $55
L1F4AA6: db $02
L1F4AA7: db $47
L1F4AA8: db $02
L1F4AA9: db $46
L1F4AAA: db $02
L1F4AAB: db $45
L1F4AAC: db $02
L1F4AAD: db $44
L1F4AAE: db $02
L1F4AAF: db $43
L1F4AB0: db $02
L1F4AB1: db $42
L1F4AB2: db $02
L1F4AB3: db $41
L1F4AB4: db $01
L1F4AB5: db $40
L1F4AB6: db $01
L1F4AB7: db $F0
L1F4AB8: db $E4
L1F4AB9: db $F2
L1F4ABA: db $32
L1F4ABB: db $1E
L1F4ABC: db $E3
SndHeader_29:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_29_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_29_Ch4: db $E4
L1F4AC5: db $3B
L1F4AC6: db $E9
L1F4AC7: db $88
L1F4AC8: db $55
L1F4AC9: db $46
L1F4ACA: db $E3
SndHeader_2A:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_2A_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_2A_Ch4: db $E4
L1F4AD3: db $A9
L1F4AD4: db $E9
L1F4AD5: db $88
L1F4AD6: db $31
L1F4AD7: db $03
L1F4AD8: db $EF
L1F4AD9: db $32
L1F4ADA: db $03
L1F4ADB: db $33
L1F4ADC: db $03
L1F4ADD: db $34
L1F4ADE: db $03
L1F4ADF: db $35
L1F4AE0: db $03
L1F4AE1: db $36
L1F4AE2: db $03
L1F4AE3: db $37
L1F4AE4: db $03
L1F4AE5: db $43
L1F4AE6: db $03
L1F4AE7: db $44
L1F4AE8: db $03
L1F4AE9: db $45
L1F4AEA: db $03
L1F4AEB: db $46
L1F4AEC: db $03
L1F4AED: db $47
L1F4AEE: db $03
L1F4AEF: db $F0
L1F4AF0: db $E3
SndHeader_2B:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_2B_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_2B_Ch4: db $E4
L1F4AF9: db $A9
L1F4AFA: db $E9
L1F4AFB: db $88
L1F4AFC: db $57
L1F4AFD: db $02
L1F4AFE: db $EF
L1F4AFF: db $56
L1F4B00: db $02
L1F4B01: db $55
L1F4B02: db $02
L1F4B03: db $54
L1F4B04: db $02
L1F4B05: db $53
L1F4B06: db $02
L1F4B07: db $47
L1F4B08: db $02
L1F4B09: db $46
L1F4B0A: db $02
L1F4B0B: db $45
L1F4B0C: db $02
L1F4B0D: db $44
L1F4B0E: db $02
L1F4B0F: db $43
L1F4B10: db $02
L1F4B11: db $42
L1F4B12: db $02
L1F4B13: db $41
L1F4B14: db $02
L1F4B15: db $F0
L1F4B16: db $E4
L1F4B17: db $F1
L1F4B18: db $27
L1F4B19: db $01
L1F4B1A: db $26
L1F4B1B: db $01
L1F4B1C: db $25
L1F4B1D: db $01
L1F4B1E: db $24
L1F4B1F: db $01
L1F4B20: db $23
L1F4B21: db $01
L1F4B22: db $22
L1F4B23: db $01
L1F4B24: db $21
L1F4B25: db $01
L1F4B26: db $20
L1F4B27: db $01
L1F4B28: db $21
L1F4B29: db $01
L1F4B2A: db $22
L1F4B2B: db $01
L1F4B2C: db $23
L1F4B2D: db $01
L1F4B2E: db $24
L1F4B2F: db $01
L1F4B30: db $25
L1F4B31: db $01
L1F4B32: db $26
L1F4B33: db $01
L1F4B34: db $27
L1F4B35: db $01
L1F4B36: db $31
L1F4B37: db $01
L1F4B38: db $32
L1F4B39: db $01
L1F4B3A: db $33
L1F4B3B: db $01
L1F4B3C: db $34
L1F4B3D: db $01
L1F4B3E: db $35
L1F4B3F: db $01
L1F4B40: db $36
L1F4B41: db $01
L1F4B42: db $37
L1F4B43: db $01
L1F4B44: db $E3
SndHeader_2C:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_2C_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_2C_Ch4: db $E4
L1F4B4D: db $F3
L1F4B4E: db $E9
L1F4B4F: db $88
L1F4B50: db $71
L1F4B51: db $02
L1F4B52: db $54
L1F4B53: db $02
L1F4B54: db $34
L1F4B55: db $02
L1F4B56: db $54
L1F4B57: db $02
L1F4B58: db $34
L1F4B59: db $05
L1F4B5A: db $71
L1F4B5B: db $1E
L1F4B5C: db $E3
SndHeader_2D:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_2D_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_2D_Ch4: db $E4
L1F4B65: db $A7
L1F4B66: db $E9
L1F4B67: db $88
L1F4B68: db $41
L1F4B69: db $01
L1F4B6A: db $EF
L1F4B6B: db $41
L1F4B6C: db $01
L1F4B6D: db $41
L1F4B6E: db $01
L1F4B6F: db $39
L1F4B70: db $01
L1F4B71: db $38
L1F4B72: db $01
L1F4B73: db $37
L1F4B74: db $01
L1F4B75: db $36
L1F4B76: db $01
L1F4B77: db $35
L1F4B78: db $01
L1F4B79: db $F0
L1F4B7A: db $41
L1F4B7B: db $01
L1F4B7C: db $EF
L1F4B7D: db $41
L1F4B7E: db $01
L1F4B7F: db $41
L1F4B80: db $01
L1F4B81: db $39
L1F4B82: db $01
L1F4B83: db $38
L1F4B84: db $01
L1F4B85: db $37
L1F4B86: db $01
L1F4B87: db $36
L1F4B88: db $01
L1F4B89: db $35
L1F4B8A: db $01
L1F4B8B: db $F0
L1F4B8C: db $E7
L1F4B8D: db $00
L1F4B8E: db $03
L1F4B8F: db $64
L1F4B90: db $4B
L1F4B91: db $E3
SndHeader_2E:
	db $01 ; Number of channels
.ch2:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_2E_Ch2 ; Data ptr
	db $06 ; Base freq/note id
	db $81 ; Unused
SndData_2E_Ch2: db $E4
L1F4B9A: db $0F
L1F4B9B: db $E9
L1F4B9C: db $22
L1F4B9D: db $EE
L1F4B9E: db $C0
L1F4B9F: db $8F
L1F4BA0: db $01
L1F4BA1: db $EF
L1F4BA2: db $91
L1F4BA3: db $92
L1F4BA4: db $94
L1F4BA5: db $96
L1F4BA6: db $98
L1F4BA7: db $99
L1F4BA8: db $9B
L1F4BA9: db $9D
L1F4BAA: db $9E
L1F4BAB: db $A0
L1F4BAC: db $A2
L1F4BAD: db $A4
L1F4BAE: db $A5
L1F4BAF: db $A7
L1F4BB0: db $E5
L1F4BB1: db $99
L1F4BB2: db $4B
SndHeader_2F:
	db $01 ; Number of channels
.ch2:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_2F_Ch2 ; Data ptr
	db $06 ; Base freq/note id
	db $81 ; Unused
SndData_2F_Ch2: db $E3
SndHeader_30:
	db $01 ; Number of channels
.ch2:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_30_Ch2 ; Data ptr
	db $0C ; Base freq/note id
	db $81 ; Unused
SndData_30_Ch2: db $E4
L1F4BC3: db $1C
L1F4BC4: db $E9
L1F4BC5: db $22
L1F4BC6: db $EE
L1F4BC7: db $C0
L1F4BC8: db $AE
L1F4BC9: db $01
L1F4BCA: db $EF
L1F4BCB: db $AF
L1F4BCC: db $E7
L1F4BCD: db $00
L1F4BCE: db $1E
L1F4BCF: db $C2
L1F4BD0: db $4B
L1F4BD1: db $E3
SndHeader_31:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_31_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_31_Ch4: db $E4
L1F4BDA: db $1B
L1F4BDB: db $E9
L1F4BDC: db $88
L1F4BDD: db $27
L1F4BDE: db $0A
L1F4BDF: db $EF
L1F4BE0: db $26
L1F4BE1: db $0A
L1F4BE2: db $25
L1F4BE3: db $0A
L1F4BE4: db $24
L1F4BE5: db $0A
L1F4BE6: db $23
L1F4BE7: db $0A
L1F4BE8: db $22
L1F4BE9: db $0A
L1F4BEA: db $E3
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
SndData_PauseUnpause_Ch1: db $E9
L1F4C12: db $11
L1F4C13: db $EE
L1F4C14: db $80
L1F4C15: db $E4
L1F4C16: db $00
L1F4C17: db $E3
SndData_PauseUnpause_Ch2: db $E9
L1F4C19: db $22
L1F4C1A: db $EE
L1F4C1B: db $80
L1F4C1C: db $E4
L1F4C1D: db $00
L1F4C1E: db $E3
SndData_PauseUnpause_Ch3: db $E9
L1F4C20: db $44
L1F4C21: db $E4
L1F4C22: db $00
L1F4C23: db $E3
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
SndData_06_Ch1: db $E4
L1F4C3E: db $77
L1F4C3F: db $E9
L1F4C40: db $11
L1F4C41: db $EE
L1F4C42: db $C0
L1F4C43: db $EC
L1F4C44: db $67
L1F4C45: db $4C
L1F4C46: db $EC
L1F4C47: db $78
L1F4C48: db $4C
L1F4C49: db $EC
L1F4C4A: db $91
L1F4C4B: db $4C
L1F4C4C: db $EC
L1F4C4D: db $A9
L1F4C4E: db $4C
L1F4C4F: db $EC
L1F4C50: db $91
L1F4C51: db $4C
L1F4C52: db $EC
L1F4C53: db $BC
L1F4C54: db $4C
L1F4C55: db $EC
L1F4C56: db $D7
L1F4C57: db $4C
L1F4C58: db $EC
L1F4C59: db $01
L1F4C5A: db $4D
L1F4C5B: db $EC
L1F4C5C: db $11
L1F4C5D: db $4D
L1F4C5E: db $EC
L1F4C5F: db $01
L1F4C60: db $4D
L1F4C61: db $EC
L1F4C62: db $1F
L1F4C63: db $4D
L1F4C64: db $E5
L1F4C65: db $46
L1F4C66: db $4C
L1F4C67: db $94
L1F4C68: db $3C
L1F4C69: db $80
L1F4C6A: db $0A
L1F4C6B: db $94
L1F4C6C: db $80
L1F4C6D: db $94
L1F4C6E: db $94
L1F4C6F: db $14
L1F4C70: db $8D
L1F4C71: db $8F
L1F4C72: db $E7
L1F4C73: db $00
L1F4C74: db $02
L1F4C75: db $67
L1F4C76: db $4C
L1F4C77: db $ED
L1F4C78: db $E4
L1F4C79: db $77
L1F4C7A: db $94
L1F4C7B: db $3C
L1F4C7C: db $80
L1F4C7D: db $0A
L1F4C7E: db $94
L1F4C7F: db $80
L1F4C80: db $94
L1F4C81: db $94
L1F4C82: db $14
L1F4C83: db $8D
L1F4C84: db $8F
L1F4C85: db $94
L1F4C86: db $3C
L1F4C87: db $80
L1F4C88: db $0A
L1F4C89: db $97
L1F4C8A: db $80
L1F4C8B: db $97
L1F4C8C: db $97
L1F4C8D: db $14
L1F4C8E: db $99
L1F4C8F: db $9B
L1F4C90: db $ED
L1F4C91: db $E4
L1F4C92: db $78
L1F4C93: db $A3
L1F4C94: db $1E
L1F4C95: db $A2
L1F4C96: db $9E
L1F4C97: db $05
L1F4C98: db $80
L1F4C99: db $9C
L1F4C9A: db $28
L1F4C9B: db $FA
L1F4C9C: db $0A
L1F4C9D: db $9C
L1F4C9E: db $9E
L1F4C9F: db $A0
L1F4CA0: db $14
L1F4CA1: db $9E
L1F4CA2: db $1E
L1F4CA3: db $A0
L1F4CA4: db $9C
L1F4CA5: db $14
L1F4CA6: db $FA
L1F4CA7: db $50
L1F4CA8: db $ED
L1F4CA9: db $A3
L1F4CAA: db $1E
L1F4CAB: db $A2
L1F4CAC: db $9E
L1F4CAD: db $14
L1F4CAE: db $9C
L1F4CAF: db $1E
L1F4CB0: db $A2
L1F4CB1: db $9E
L1F4CB2: db $0A
L1F4CB3: db $A5
L1F4CB4: db $FA
L1F4CB5: db $1E
L1F4CB6: db $A4
L1F4CB7: db $A0
L1F4CB8: db $14
L1F4CB9: db $FA
L1F4CBA: db $50
L1F4CBB: db $ED
L1F4CBC: db $9B
L1F4CBD: db $1E
L1F4CBE: db $9C
L1F4CBF: db $9E
L1F4CC0: db $0A
L1F4CC1: db $A0
L1F4CC2: db $FA
L1F4CC3: db $14
L1F4CC4: db $80
L1F4CC5: db $A5
L1F4CC6: db $0D
L1F4CC7: db $A4
L1F4CC8: db $0E
L1F4CC9: db $A0
L1F4CCA: db $0D
L1F4CCB: db $A3
L1F4CCC: db $14
L1F4CCD: db $80
L1F4CCE: db $0A
L1F4CCF: db $A2
L1F4CD0: db $1E
L1F4CD1: db $9E
L1F4CD2: db $0A
L1F4CD3: db $A0
L1F4CD4: db $FA
L1F4CD5: db $50
L1F4CD6: db $ED
L1F4CD7: db $EE
L1F4CD8: db $80
L1F4CD9: db $95
L1F4CDA: db $3C
L1F4CDB: db $9C
L1F4CDC: db $14
L1F4CDD: db $9B
L1F4CDE: db $99
L1F4CDF: db $97
L1F4CE0: db $99
L1F4CE1: db $98
L1F4CE2: db $3C
L1F4CE3: db $A0
L1F4CE4: db $14
L1F4CE5: db $9E
L1F4CE6: db $9C
L1F4CE7: db $9B
L1F4CE8: db $99
L1F4CE9: db $9C
L1F4CEA: db $3C
L1F4CEB: db $9B
L1F4CEC: db $14
L1F4CED: db $9E
L1F4CEE: db $0D
L1F4CEF: db $A4
L1F4CF0: db $0E
L1F4CF1: db $A5
L1F4CF2: db $0D
L1F4CF3: db $A4
L1F4CF4: db $A1
L1F4CF5: db $0E
L1F4CF6: db $A0
L1F4CF7: db $0D
L1F4CF8: db $A4
L1F4CF9: db $50
L1F4CFA: db $A5
L1F4CFB: db $1E
L1F4CFC: db $A7
L1F4CFD: db $28
L1F4CFE: db $FA
L1F4CFF: db $0A
L1F4D00: db $ED
L1F4D01: db $EE
L1F4D02: db $C0
L1F4D03: db $99
L1F4D04: db $0D
L1F4D05: db $9C
L1F4D06: db $0E
L1F4D07: db $A0
L1F4D08: db $0D
L1F4D09: db $A2
L1F4D0A: db $A3
L1F4D0B: db $0E
L1F4D0C: db $A5
L1F4D0D: db $0D
L1F4D0E: db $A2
L1F4D0F: db $50
L1F4D10: db $ED
L1F4D11: db $A1
L1F4D12: db $0D
L1F4D13: db $9C
L1F4D14: db $0E
L1F4D15: db $9B
L1F4D16: db $0D
L1F4D17: db $99
L1F4D18: db $9B
L1F4D19: db $0E
L1F4D1A: db $A0
L1F4D1B: db $0D
L1F4D1C: db $FA
L1F4D1D: db $50
L1F4D1E: db $ED
L1F4D1F: db $A1
L1F4D20: db $0D
L1F4D21: db $A0
L1F4D22: db $0E
L1F4D23: db $A3
L1F4D24: db $0D
L1F4D25: db $A1
L1F4D26: db $A7
L1F4D27: db $0E
L1F4D28: db $A8
L1F4D29: db $0D
L1F4D2A: db $FA
L1F4D2B: db $50
L1F4D2C: db $A7
L1F4D2D: db $14
L1F4D2E: db $A0
L1F4D2F: db $05
L1F4D30: db $80
L1F4D31: db $A8
L1F4D32: db $14
L1F4D33: db $A1
L1F4D34: db $05
L1F4D35: db $80
L1F4D36: db $AA
L1F4D37: db $14
L1F4D38: db $AC
L1F4D39: db $0D
L1F4D3A: db $A8
L1F4D3B: db $0E
L1F4D3C: db $A7
L1F4D3D: db $0D
L1F4D3E: db $A5
L1F4D3F: db $A4
L1F4D40: db $0E
L1F4D41: db $A7
L1F4D42: db $0D
L1F4D43: db $A8
L1F4D44: db $50
L1F4D45: db $FA
L1F4D46: db $50
L1F4D47: db $E4
L1F4D48: db $11
L1F4D49: db $81
L1F4D4A: db $50
L1F4D4B: db $FA
L1F4D4C: db $50
L1F4D4D: db $ED
SndData_06_Ch2: db $E4
L1F4D4F: db $77
L1F4D50: db $E9
L1F4D51: db $22
L1F4D52: db $EE
L1F4D53: db $40
L1F4D54: db $EC
L1F4D55: db $60
L1F4D56: db $4D
L1F4D57: db $EC
L1F4D58: db $79
L1F4D59: db $4D
L1F4D5A: db $EC
L1F4D5B: db $B1
L1F4D5C: db $4D
L1F4D5D: db $E5
L1F4D5E: db $4E
L1F4D5F: db $4D
L1F4D60: db $8D
L1F4D61: db $14
L1F4D62: db $8F
L1F4D63: db $0A
L1F4D64: db $8D
L1F4D65: db $14
L1F4D66: db $8F
L1F4D67: db $0A
L1F4D68: db $8D
L1F4D69: db $14
L1F4D6A: db $8F
L1F4D6B: db $0A
L1F4D6C: db $8D
L1F4D6D: db $14
L1F4D6E: db $8F
L1F4D6F: db $0A
L1F4D70: db $90
L1F4D71: db $14
L1F4D72: db $92
L1F4D73: db $E7
L1F4D74: db $00
L1F4D75: db $0D
L1F4D76: db $60
L1F4D77: db $4D
L1F4D78: db $ED
L1F4D79: db $8C
L1F4D7A: db $14
L1F4D7B: db $8F
L1F4D7C: db $0A
L1F4D7D: db $8C
L1F4D7E: db $14
L1F4D7F: db $8F
L1F4D80: db $0A
L1F4D81: db $8C
L1F4D82: db $14
L1F4D83: db $8F
L1F4D84: db $0A
L1F4D85: db $8C
L1F4D86: db $14
L1F4D87: db $8F
L1F4D88: db $0A
L1F4D89: db $94
L1F4D8A: db $14
L1F4D8B: db $95
L1F4D8C: db $92
L1F4D8D: db $94
L1F4D8E: db $0A
L1F4D8F: db $92
L1F4D90: db $14
L1F4D91: db $94
L1F4D92: db $0A
L1F4D93: db $92
L1F4D94: db $14
L1F4D95: db $94
L1F4D96: db $0A
L1F4D97: db $92
L1F4D98: db $14
L1F4D99: db $94
L1F4D9A: db $0A
L1F4D9B: db $90
L1F4D9C: db $14
L1F4D9D: db $92
L1F4D9E: db $8C
L1F4D9F: db $8F
L1F4DA0: db $0A
L1F4DA1: db $8C
L1F4DA2: db $14
L1F4DA3: db $8F
L1F4DA4: db $0A
L1F4DA5: db $8C
L1F4DA6: db $14
L1F4DA7: db $8F
L1F4DA8: db $0A
L1F4DA9: db $8C
L1F4DAA: db $14
L1F4DAB: db $8F
L1F4DAC: db $0A
L1F4DAD: db $98
L1F4DAE: db $14
L1F4DAF: db $9B
L1F4DB0: db $ED
L1F4DB1: db $E4
L1F4DB2: db $62
L1F4DB3: db $EE
L1F4DB4: db $00
L1F4DB5: db $94
L1F4DB6: db $05
L1F4DB7: db $9C
L1F4DB8: db $99
L1F4DB9: db $94
L1F4DBA: db $9E
L1F4DBB: db $9C
L1F4DBC: db $94
L1F4DBD: db $9C
L1F4DBE: db $E7
L1F4DBF: db $00
L1F4DC0: db $10
L1F4DC1: db $B1
L1F4DC2: db $4D
L1F4DC3: db $E4
L1F4DC4: db $77
L1F4DC5: db $EE
L1F4DC6: db $40
L1F4DC7: db $98
L1F4DC8: db $14
L1F4DC9: db $8C
L1F4DCA: db $0A
L1F4DCB: db $99
L1F4DCC: db $14
L1F4DCD: db $8D
L1F4DCE: db $0A
L1F4DCF: db $98
L1F4DD0: db $14
L1F4DD1: db $8C
L1F4DD2: db $0D
L1F4DD3: db $99
L1F4DD4: db $0E
L1F4DD5: db $9E
L1F4DD6: db $0D
L1F4DD7: db $A0
L1F4DD8: db $A7
L1F4DD9: db $0E
L1F4DDA: db $AA
L1F4DDB: db $0D
L1F4DDC: db $ED
SndData_06_Ch3: db $E4
L1F4DDE: db $40
L1F4DDF: db $E9
L1F4DE0: db $44
L1F4DE1: db $F3
L1F4DE2: db $02
L1F4DE3: db $F5
L1F4DE4: db $19
L1F4DE5: db $EC
L1F4DE6: db $0E
L1F4DE7: db $4E
L1F4DE8: db $EC
L1F4DE9: db $36
L1F4DEA: db $4E
L1F4DEB: db $EC
L1F4DEC: db $64
L1F4DED: db $4E
L1F4DEE: db $EC
L1F4DEF: db $36
L1F4DF0: db $4E
L1F4DF1: db $EC
L1F4DF2: db $74
L1F4DF3: db $4E
L1F4DF4: db $EC
L1F4DF5: db $86
L1F4DF6: db $4E
L1F4DF7: db $E6
L1F4DF8: db $FC
L1F4DF9: db $EC
L1F4DFA: db $86
L1F4DFB: db $4E
L1F4DFC: db $E6
L1F4DFD: db $04
L1F4DFE: db $EC
L1F4DFF: db $86
L1F4E00: db $4E
L1F4E01: db $E6
L1F4E02: db $FC
L1F4E03: db $EC
L1F4E04: db $86
L1F4E05: db $4E
L1F4E06: db $E6
L1F4E07: db $04
L1F4E08: db $EC
L1F4E09: db $96
L1F4E0A: db $4E
L1F4E0B: db $E5
L1F4E0C: db $DD
L1F4E0D: db $4D
L1F4E0E: db $8D
L1F4E0F: db $0A
L1F4E10: db $8D
L1F4E11: db $05
L1F4E12: db $8D
L1F4E13: db $8D
L1F4E14: db $0A
L1F4E15: db $8D
L1F4E16: db $8D
L1F4E17: db $05
L1F4E18: db $8D
L1F4E19: db $8D
L1F4E1A: db $0A
L1F4E1B: db $8D
L1F4E1C: db $8D
L1F4E1D: db $05
L1F4E1E: db $8D
L1F4E1F: db $8D
L1F4E20: db $0A
L1F4E21: db $8D
L1F4E22: db $8D
L1F4E23: db $05
L1F4E24: db $8D
L1F4E25: db $8D
L1F4E26: db $0A
L1F4E27: db $89
L1F4E28: db $89
L1F4E29: db $05
L1F4E2A: db $89
L1F4E2B: db $8B
L1F4E2C: db $0A
L1F4E2D: db $8B
L1F4E2E: db $05
L1F4E2F: db $8B
L1F4E30: db $E7
L1F4E31: db $00
L1F4E32: db $0C
L1F4E33: db $0E
L1F4E34: db $4E
L1F4E35: db $ED
L1F4E36: db $89
L1F4E37: db $0A
L1F4E38: db $89
L1F4E39: db $05
L1F4E3A: db $89
L1F4E3B: db $89
L1F4E3C: db $0A
L1F4E3D: db $89
L1F4E3E: db $05
L1F4E3F: db $89
L1F4E40: db $89
L1F4E41: db $0A
L1F4E42: db $86
L1F4E43: db $88
L1F4E44: db $F5
L1F4E45: db $3C
L1F4E46: db $89
L1F4E47: db $14
L1F4E48: db $F5
L1F4E49: db $1E
L1F4E4A: db $86
L1F4E4B: db $0A
L1F4E4C: db $88
L1F4E4D: db $89
L1F4E4E: db $8B
L1F4E4F: db $89
L1F4E50: db $86
L1F4E51: db $81
L1F4E52: db $F5
L1F4E53: db $19
L1F4E54: db $88
L1F4E55: db $0A
L1F4E56: db $88
L1F4E57: db $05
L1F4E58: db $88
L1F4E59: db $94
L1F4E5A: db $0A
L1F4E5B: db $88
L1F4E5C: db $05
L1F4E5D: db $88
L1F4E5E: db $88
L1F4E5F: db $0A
L1F4E60: db $83
L1F4E61: db $88
L1F4E62: db $8D
L1F4E63: db $ED
L1F4E64: db $98
L1F4E65: db $0A
L1F4E66: db $A4
L1F4E67: db $94
L1F4E68: db $A0
L1F4E69: db $05
L1F4E6A: db $98
L1F4E6B: db $8F
L1F4E6C: db $0A
L1F4E6D: db $8F
L1F4E6E: db $8D
L1F4E6F: db $05
L1F4E70: db $8F
L1F4E71: db $90
L1F4E72: db $0A
L1F4E73: db $ED
L1F4E74: db $A7
L1F4E75: db $05
L1F4E76: db $A5
L1F4E77: db $A4
L1F4E78: db $A1
L1F4E79: db $A0
L1F4E7A: db $9E
L1F4E7B: db $9C
L1F4E7C: db $9B
L1F4E7D: db $99
L1F4E7E: db $98
L1F4E7F: db $99
L1F4E80: db $9B
L1F4E81: db $9C
L1F4E82: db $9E
L1F4E83: db $A0
L1F4E84: db $9A
L1F4E85: db $ED
L1F4E86: db $99
L1F4E87: db $05
L1F4E88: db $99
L1F4E89: db $99
L1F4E8A: db $99
L1F4E8B: db $A5
L1F4E8C: db $0A
L1F4E8D: db $99
L1F4E8E: db $05
L1F4E8F: db $99
L1F4E90: db $E7
L1F4E91: db $00
L1F4E92: db $04
L1F4E93: db $86
L1F4E94: db $4E
L1F4E95: db $ED
L1F4E96: db $F5
L1F4E97: db $1E
L1F4E98: db $94
L1F4E99: db $0A
L1F4E9A: db $94
L1F4E9B: db $88
L1F4E9C: db $95
L1F4E9D: db $95
L1F4E9E: db $89
L1F4E9F: db $94
L1F4EA0: db $94
L1F4EA1: db $88
L1F4EA2: db $0D
L1F4EA3: db $92
L1F4EA4: db $0E
L1F4EA5: db $94
L1F4EA6: db $0D
L1F4EA7: db $9B
L1F4EA8: db $98
L1F4EA9: db $0E
L1F4EAA: db $92
L1F4EAB: db $0D
L1F4EAC: db $ED
SndData_06_Ch4: db $E9
L1F4EAE: db $88
L1F4EAF: db $EC
L1F4EB0: db $E2
L1F4EB1: db $4E
L1F4EB2: db $EC
L1F4EB3: db $F8
L1F4EB4: db $4E
L1F4EB5: db $EC
L1F4EB6: db $E2
L1F4EB7: db $4E
L1F4EB8: db $EC
L1F4EB9: db $11
L1F4EBA: db $4F
L1F4EBB: db $EC
L1F4EBC: db $E2
L1F4EBD: db $4E
L1F4EBE: db $EC
L1F4EBF: db $F8
L1F4EC0: db $4E
L1F4EC1: db $EC
L1F4EC2: db $E2
L1F4EC3: db $4E
L1F4EC4: db $EC
L1F4EC5: db $11
L1F4EC6: db $4F
L1F4EC7: db $EC
L1F4EC8: db $E2
L1F4EC9: db $4E
L1F4ECA: db $EC
L1F4ECB: db $F8
L1F4ECC: db $4E
L1F4ECD: db $EC
L1F4ECE: db $E2
L1F4ECF: db $4E
L1F4ED0: db $EC
L1F4ED1: db $2A
L1F4ED2: db $4F
L1F4ED3: db $EC
L1F4ED4: db $45
L1F4ED5: db $4F
L1F4ED6: db $EC
L1F4ED7: db $AF
L1F4ED8: db $4F
L1F4ED9: db $EC
L1F4EDA: db $2A
L1F4EDB: db $4F
L1F4EDC: db $EC
L1F4EDD: db $C9
L1F4EDE: db $4F
L1F4EDF: db $E5
L1F4EE0: db $AD
L1F4EE1: db $4E
L1F4EE2: db $E4
L1F4EE3: db $61
L1F4EE4: db $36
L1F4EE5: db $0A
L1F4EE6: db $36
L1F4EE7: db $05
L1F4EE8: db $36
L1F4EE9: db $05
L1F4EEA: db $E4
L1F4EEB: db $62
L1F4EEC: db $24
L1F4EED: db $0F
L1F4EEE: db $E4
L1F4EEF: db $61
L1F4EF0: db $36
L1F4EF1: db $05
L1F4EF2: db $E7
L1F4EF3: db $00
L1F4EF4: db $07
L1F4EF5: db $E2
L1F4EF6: db $4E
L1F4EF7: db $ED
L1F4EF8: db $E4
L1F4EF9: db $61
L1F4EFA: db $36
L1F4EFB: db $05
L1F4EFC: db $E4
L1F4EFD: db $62
L1F4EFE: db $24
L1F4EFF: db $05
L1F4F00: db $E4
L1F4F01: db $61
L1F4F02: db $36
L1F4F03: db $05
L1F4F04: db $36
L1F4F05: db $05
L1F4F06: db $E4
L1F4F07: db $62
L1F4F08: db $24
L1F4F09: db $0A
L1F4F0A: db $24
L1F4F0B: db $05
L1F4F0C: db $E4
L1F4F0D: db $61
L1F4F0E: db $36
L1F4F0F: db $05
L1F4F10: db $ED
L1F4F11: db $E4
L1F4F12: db $61
L1F4F13: db $36
L1F4F14: db $05
L1F4F15: db $E4
L1F4F16: db $62
L1F4F17: db $24
L1F4F18: db $05
L1F4F19: db $E4
L1F4F1A: db $61
L1F4F1B: db $36
L1F4F1C: db $05
L1F4F1D: db $36
L1F4F1E: db $05
L1F4F1F: db $E4
L1F4F20: db $62
L1F4F21: db $24
L1F4F22: db $05
L1F4F23: db $24
L1F4F24: db $05
L1F4F25: db $24
L1F4F26: db $05
L1F4F27: db $24
L1F4F28: db $05
L1F4F29: db $ED
L1F4F2A: db $E4
L1F4F2B: db $62
L1F4F2C: db $24
L1F4F2D: db $05
L1F4F2E: db $E4
L1F4F2F: db $61
L1F4F30: db $36
L1F4F31: db $05
L1F4F32: db $E4
L1F4F33: db $62
L1F4F34: db $24
L1F4F35: db $05
L1F4F36: db $24
L1F4F37: db $05
L1F4F38: db $E4
L1F4F39: db $61
L1F4F3A: db $36
L1F4F3B: db $05
L1F4F3C: db $E4
L1F4F3D: db $62
L1F4F3E: db $24
L1F4F3F: db $05
L1F4F40: db $24
L1F4F41: db $05
L1F4F42: db $24
L1F4F43: db $05
L1F4F44: db $ED
L1F4F45: db $E4
L1F4F46: db $61
L1F4F47: db $36
L1F4F48: db $05
L1F4F49: db $E4
L1F4F4A: db $62
L1F4F4B: db $24
L1F4F4C: db $05
L1F4F4D: db $E4
L1F4F4E: db $53
L1F4F4F: db $11
L1F4F50: db $05
L1F4F51: db $E4
L1F4F52: db $61
L1F4F53: db $36
L1F4F54: db $05
L1F4F55: db $E4
L1F4F56: db $62
L1F4F57: db $24
L1F4F58: db $0A
L1F4F59: db $E4
L1F4F5A: db $53
L1F4F5B: db $11
L1F4F5C: db $05
L1F4F5D: db $E4
L1F4F5E: db $61
L1F4F5F: db $36
L1F4F60: db $0F
L1F4F61: db $E4
L1F4F62: db $53
L1F4F63: db $11
L1F4F64: db $05
L1F4F65: db $E4
L1F4F66: db $61
L1F4F67: db $36
L1F4F68: db $05
L1F4F69: db $E4
L1F4F6A: db $62
L1F4F6B: db $24
L1F4F6C: db $0A
L1F4F6D: db $E4
L1F4F6E: db $53
L1F4F6F: db $11
L1F4F70: db $05
L1F4F71: db $E4
L1F4F72: db $61
L1F4F73: db $36
L1F4F74: db $05
L1F4F75: db $E7
L1F4F76: db $00
L1F4F77: db $07
L1F4F78: db $45
L1F4F79: db $4F
L1F4F7A: db $E4
L1F4F7B: db $61
L1F4F7C: db $36
L1F4F7D: db $05
L1F4F7E: db $E4
L1F4F7F: db $62
L1F4F80: db $24
L1F4F81: db $05
L1F4F82: db $24
L1F4F83: db $05
L1F4F84: db $24
L1F4F85: db $05
L1F4F86: db $E4
L1F4F87: db $34
L1F4F88: db $26
L1F4F89: db $05
L1F4F8A: db $26
L1F4F8B: db $05
L1F4F8C: db $26
L1F4F8D: db $05
L1F4F8E: db $E4
L1F4F8F: db $44
L1F4F90: db $26
L1F4F91: db $05
L1F4F92: db $10
L1F4F93: db $05
L1F4F94: db $10
L1F4F95: db $05
L1F4F96: db $E4
L1F4F97: db $54
L1F4F98: db $26
L1F4F99: db $05
L1F4F9A: db $E4
L1F4F9B: db $61
L1F4F9C: db $36
L1F4F9D: db $05
L1F4F9E: db $E4
L1F4F9F: db $62
L1F4FA0: db $24
L1F4FA1: db $05
L1F4FA2: db $E4
L1F4FA3: db $61
L1F4FA4: db $36
L1F4FA5: db $05
L1F4FA6: db $E4
L1F4FA7: db $62
L1F4FA8: db $24
L1F4FA9: db $05
L1F4FAA: db $E4
L1F4FAB: db $61
L1F4FAC: db $36
L1F4FAD: db $05
L1F4FAE: db $ED
L1F4FAF: db $E4
L1F4FB0: db $61
L1F4FB1: db $36
L1F4FB2: db $05
L1F4FB3: db $36
L1F4FB4: db $05
L1F4FB5: db $36
L1F4FB6: db $05
L1F4FB7: db $36
L1F4FB8: db $05
L1F4FB9: db $E4
L1F4FBA: db $62
L1F4FBB: db $24
L1F4FBC: db $0A
L1F4FBD: db $E4
L1F4FBE: db $61
L1F4FBF: db $36
L1F4FC0: db $05
L1F4FC1: db $36
L1F4FC2: db $05
L1F4FC3: db $E7
L1F4FC4: db $00
L1F4FC5: db $0F
L1F4FC6: db $AF
L1F4FC7: db $4F
L1F4FC8: db $ED
L1F4FC9: db $E4
L1F4FCA: db $62
L1F4FCB: db $24
L1F4FCC: db $0A
L1F4FCD: db $E4
L1F4FCE: db $61
L1F4FCF: db $36
L1F4FD0: db $0A
L1F4FD1: db $36
L1F4FD2: db $0A
L1F4FD3: db $E7
L1F4FD4: db $00
L1F4FD5: db $04
L1F4FD6: db $C9
L1F4FD7: db $4F
L1F4FD8: db $E4
L1F4FD9: db $62
L1F4FDA: db $24
L1F4FDB: db $0A
L1F4FDC: db $24
L1F4FDD: db $0A
L1F4FDE: db $24
L1F4FDF: db $0A
L1F4FE0: db $24
L1F4FE1: db $0A
L1F4FE2: db $ED
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
SndData_08_Ch1: db $E4
L1F4FFD: db $77
L1F4FFE: db $E9
L1F4FFF: db $11
L1F5000: db $EE
L1F5001: db $C0
L1F5002: db $EC
L1F5003: db $17
L1F5004: db $50
L1F5005: db $EC
L1F5006: db $66
L1F5007: db $50
L1F5008: db $EC
L1F5009: db $DE
L1F500A: db $50
L1F500B: db $EC
L1F500C: db $34
L1F500D: db $51
L1F500E: db $EC
L1F500F: db $5B
L1F5010: db $51
L1F5011: db $EC
L1F5012: db $76
L1F5013: db $51
L1F5014: db $E5
L1F5015: db $FC
L1F5016: db $4F
L1F5017: db $E4
L1F5018: db $11
L1F5019: db $85
L1F501A: db $14
L1F501B: db $E4
L1F501C: db $77
L1F501D: db $9D
L1F501E: db $0A
L1F501F: db $E4
L1F5020: db $11
L1F5021: db $85
L1F5022: db $14
L1F5023: db $E4
L1F5024: db $77
L1F5025: db $9D
L1F5026: db $0A
L1F5027: db $9B
L1F5028: db $98
L1F5029: db $E4
L1F502A: db $11
L1F502B: db $83
L1F502C: db $14
L1F502D: db $E4
L1F502E: db $77
L1F502F: db $9B
L1F5030: db $0A
L1F5031: db $E4
L1F5032: db $11
L1F5033: db $83
L1F5034: db $14
L1F5035: db $E4
L1F5036: db $77
L1F5037: db $9B
L1F5038: db $0A
L1F5039: db $9B
L1F503A: db $96
L1F503B: db $E4
L1F503C: db $11
L1F503D: db $8A
L1F503E: db $14
L1F503F: db $E4
L1F5040: db $77
L1F5041: db $A2
L1F5042: db $0A
L1F5043: db $E4
L1F5044: db $11
L1F5045: db $8A
L1F5046: db $14
L1F5047: db $E4
L1F5048: db $77
L1F5049: db $A2
L1F504A: db $0A
L1F504B: db $E4
L1F504C: db $11
L1F504D: db $8A
L1F504E: db $14
L1F504F: db $E4
L1F5050: db $77
L1F5051: db $A2
L1F5052: db $0A
L1F5053: db $E4
L1F5054: db $11
L1F5055: db $8A
L1F5056: db $14
L1F5057: db $E4
L1F5058: db $77
L1F5059: db $A2
L1F505A: db $0A
L1F505B: db $80
L1F505C: db $A2
L1F505D: db $14
L1F505E: db $80
L1F505F: db $0A
L1F5060: db $E7
L1F5061: db $00
L1F5062: db $02
L1F5063: db $17
L1F5064: db $50
L1F5065: db $ED
L1F5066: db $E4
L1F5067: db $68
L1F5068: db $EE
L1F5069: db $80
L1F506A: db $96
L1F506B: db $1E
L1F506C: db $A2
L1F506D: db $50
L1F506E: db $FA
L1F506F: db $0A
L1F5070: db $A7
L1F5071: db $0A
L1F5072: db $A4
L1F5073: db $A0
L1F5074: db $9F
L1F5075: db $28
L1F5076: db $9B
L1F5077: db $1E
L1F5078: db $96
L1F5079: db $50
L1F507A: db $E4
L1F507B: db $11
L1F507C: db $8A
L1F507D: db $14
L1F507E: db $E4
L1F507F: db $68
L1F5080: db $96
L1F5081: db $1E
L1F5082: db $A2
L1F5083: db $50
L1F5084: db $FA
L1F5085: db $0A
L1F5086: db $80
L1F5087: db $A5
L1F5088: db $A4
L1F5089: db $A0
L1F508A: db $9F
L1F508B: db $A0
L1F508C: db $9F
L1F508D: db $9B
L1F508E: db $14
L1F508F: db $96
L1F5090: db $99
L1F5091: db $28
L1F5092: db $9B
L1F5093: db $07
L1F5094: db $99
L1F5095: db $06
L1F5096: db $9B
L1F5097: db $07
L1F5098: db $99
L1F5099: db $9B
L1F509A: db $06
L1F509B: db $99
L1F509C: db $07
L1F509D: db $9B
L1F509E: db $0A
L1F509F: db $99
L1F50A0: db $1E
L1F50A1: db $A0
L1F50A2: db $A2
L1F50A3: db $50
L1F50A4: db $80
L1F50A5: db $0A
L1F50A6: db $9F
L1F50A7: db $A2
L1F50A8: db $1E
L1F50A9: db $A5
L1F50AA: db $A9
L1F50AB: db $3C
L1F50AC: db $E4
L1F50AD: db $11
L1F50AE: db $85
L1F50AF: db $14
L1F50B0: db $FA
L1F50B1: db $07
L1F50B2: db $E4
L1F50B3: db $68
L1F50B4: db $A7
L1F50B5: db $06
L1F50B6: db $A9
L1F50B7: db $07
L1F50B8: db $AC
L1F50B9: db $1E
L1F50BA: db $B0
L1F50BB: db $A9
L1F50BC: db $A5
L1F50BD: db $14
L1F50BE: db $80
L1F50BF: db $0A
L1F50C0: db $A2
L1F50C1: db $14
L1F50C2: db $A7
L1F50C3: db $0A
L1F50C4: db $A5
L1F50C5: db $FA
L1F50C6: db $28
L1F50C7: db $80
L1F50C8: db $14
L1F50C9: db $A5
L1F50CA: db $0A
L1F50CB: db $A9
L1F50CC: db $14
L1F50CD: db $A7
L1F50CE: db $14
L1F50CF: db $FA
L1F50D0: db $03
L1F50D1: db $9D
L1F50D2: db $07
L1F50D3: db $9F
L1F50D4: db $06
L1F50D5: db $A2
L1F50D6: db $07
L1F50D7: db $A5
L1F50D8: db $A9
L1F50D9: db $06
L1F50DA: db $AC
L1F50DB: db $07
L1F50DC: db $B0
L1F50DD: db $ED
L1F50DE: db $E4
L1F50DF: db $77
L1F50E0: db $EE
L1F50E1: db $C0
L1F50E2: db $E4
L1F50E3: db $11
L1F50E4: db $85
L1F50E5: db $14
L1F50E6: db $E4
L1F50E7: db $77
L1F50E8: db $9D
L1F50E9: db $0A
L1F50EA: db $E4
L1F50EB: db $11
L1F50EC: db $85
L1F50ED: db $14
L1F50EE: db $E4
L1F50EF: db $77
L1F50F0: db $9D
L1F50F1: db $0A
L1F50F2: db $E4
L1F50F3: db $11
L1F50F4: db $85
L1F50F5: db $14
L1F50F6: db $E4
L1F50F7: db $77
L1F50F8: db $9D
L1F50F9: db $0A
L1F50FA: db $E4
L1F50FB: db $11
L1F50FC: db $85
L1F50FD: db $14
L1F50FE: db $E4
L1F50FF: db $77
L1F5100: db $9D
L1F5101: db $0A
L1F5102: db $E4
L1F5103: db $11
L1F5104: db $85
L1F5105: db $E4
L1F5106: db $77
L1F5107: db $9B
L1F5108: db $9B
L1F5109: db $9D
L1F510A: db $E7
L1F510B: db $00
L1F510C: db $03
L1F510D: db $DE
L1F510E: db $50
L1F510F: db $E4
L1F5110: db $11
L1F5111: db $85
L1F5112: db $14
L1F5113: db $E4
L1F5114: db $77
L1F5115: db $9D
L1F5116: db $0A
L1F5117: db $E4
L1F5118: db $11
L1F5119: db $85
L1F511A: db $14
L1F511B: db $E4
L1F511C: db $77
L1F511D: db $9B
L1F511E: db $0A
L1F511F: db $9B
L1F5120: db $9D
L1F5121: db $E4
L1F5122: db $11
L1F5123: db $85
L1F5124: db $14
L1F5125: db $E4
L1F5126: db $77
L1F5127: db $A0
L1F5128: db $0A
L1F5129: db $E4
L1F512A: db $11
L1F512B: db $85
L1F512C: db $14
L1F512D: db $E4
L1F512E: db $77
L1F512F: db $9B
L1F5130: db $0A
L1F5131: db $A2
L1F5132: db $9B
L1F5133: db $ED
L1F5134: db $E4
L1F5135: db $68
L1F5136: db $EE
L1F5137: db $80
L1F5138: db $96
L1F5139: db $1E
L1F513A: db $A2
L1F513B: db $50
L1F513C: db $FA
L1F513D: db $0A
L1F513E: db $A5
L1F513F: db $A4
L1F5140: db $A0
L1F5141: db $9F
L1F5142: db $28
L1F5143: db $9B
L1F5144: db $1E
L1F5145: db $96
L1F5146: db $28
L1F5147: db $80
L1F5148: db $0A
L1F5149: db $9B
L1F514A: db $14
L1F514B: db $99
L1F514C: db $94
L1F514D: db $0A
L1F514E: db $91
L1F514F: db $94
L1F5150: db $99
L1F5151: db $A0
L1F5152: db $28
L1F5153: db $FA
L1F5154: db $0A
L1F5155: db $93
L1F5156: db $96
L1F5157: db $99
L1F5158: db $9F
L1F5159: db $28
L1F515A: db $ED
L1F515B: db $9D
L1F515C: db $03
L1F515D: db $A0
L1F515E: db $04
L1F515F: db $A5
L1F5160: db $03
L1F5161: db $A7
L1F5162: db $1E
L1F5163: db $A5
L1F5164: db $80
L1F5165: db $14
L1F5166: db $A4
L1F5167: db $1E
L1F5168: db $A5
L1F5169: db $A7
L1F516A: db $14
L1F516B: db $A7
L1F516C: db $1E
L1F516D: db $A5
L1F516E: db $A9
L1F516F: db $14
L1F5170: db $A7
L1F5171: db $1E
L1F5172: db $A5
L1F5173: db $A4
L1F5174: db $14
L1F5175: db $ED
L1F5176: db $A4
L1F5177: db $1E
L1F5178: db $A2
L1F5179: db $28
L1F517A: db $A7
L1F517B: db $0A
L1F517C: db $A4
L1F517D: db $1E
L1F517E: db $A0
L1F517F: db $9D
L1F5180: db $14
L1F5181: db $9E
L1F5182: db $50
L1F5183: db $A0
L1F5184: db $ED
SndData_08_Ch2: db $E4
L1F5186: db $77
L1F5187: db $E9
L1F5188: db $22
L1F5189: db $EE
L1F518A: db $C0
L1F518B: db $EC
L1F518C: db $B5
L1F518D: db $51
L1F518E: db $EC
L1F518F: db $FF
L1F5190: db $51
L1F5191: db $EC
L1F5192: db $11
L1F5193: db $52
L1F5194: db $EC
L1F5195: db $FF
L1F5196: db $51
L1F5197: db $EC
L1F5198: db $23
L1F5199: db $52
L1F519A: db $EC
L1F519B: db $FF
L1F519C: db $51
L1F519D: db $EC
L1F519E: db $11
L1F519F: db $52
L1F51A0: db $EC
L1F51A1: db $FF
L1F51A2: db $51
L1F51A3: db $EC
L1F51A4: db $35
L1F51A5: db $52
L1F51A6: db $EC
L1F51A7: db $45
L1F51A8: db $52
L1F51A9: db $EC
L1F51AA: db $D1
L1F51AB: db $52
L1F51AC: db $EC
L1F51AD: db $2D
L1F51AE: db $53
L1F51AF: db $EC
L1F51B0: db $66
L1F51B1: db $53
L1F51B2: db $E5
L1F51B3: db $85
L1F51B4: db $51
L1F51B5: db $96
L1F51B6: db $05
L1F51B7: db $80
L1F51B8: db $96
L1F51B9: db $80
L1F51BA: db $A2
L1F51BB: db $0A
L1F51BC: db $96
L1F51BD: db $05
L1F51BE: db $80
L1F51BF: db $96
L1F51C0: db $80
L1F51C1: db $A2
L1F51C2: db $0A
L1F51C3: db $A0
L1F51C4: db $9D
L1F51C5: db $94
L1F51C6: db $05
L1F51C7: db $80
L1F51C8: db $94
L1F51C9: db $80
L1F51CA: db $A0
L1F51CB: db $0A
L1F51CC: db $94
L1F51CD: db $05
L1F51CE: db $80
L1F51CF: db $94
L1F51D0: db $80
L1F51D1: db $A0
L1F51D2: db $0A
L1F51D3: db $9F
L1F51D4: db $9B
L1F51D5: db $9B
L1F51D6: db $05
L1F51D7: db $80
L1F51D8: db $9B
L1F51D9: db $80
L1F51DA: db $A7
L1F51DB: db $0A
L1F51DC: db $9B
L1F51DD: db $05
L1F51DE: db $80
L1F51DF: db $9B
L1F51E0: db $80
L1F51E1: db $A7
L1F51E2: db $0A
L1F51E3: db $9B
L1F51E4: db $05
L1F51E5: db $80
L1F51E6: db $9B
L1F51E7: db $80
L1F51E8: db $A7
L1F51E9: db $0A
L1F51EA: db $9B
L1F51EB: db $05
L1F51EC: db $80
L1F51ED: db $9B
L1F51EE: db $80
L1F51EF: db $A7
L1F51F0: db $0A
L1F51F1: db $9B
L1F51F2: db $05
L1F51F3: db $80
L1F51F4: db $A7
L1F51F5: db $14
L1F51F6: db $9B
L1F51F7: db $05
L1F51F8: db $80
L1F51F9: db $E7
L1F51FA: db $00
L1F51FB: db $02
L1F51FC: db $B5
L1F51FD: db $51
L1F51FE: db $ED
L1F51FF: db $E4
L1F5200: db $65
L1F5201: db $A9
L1F5202: db $0A
L1F5203: db $A5
L1F5204: db $A4
L1F5205: db $A0
L1F5206: db $14
L1F5207: db $9D
L1F5208: db $99
L1F5209: db $96
L1F520A: db $9B
L1F520B: db $0A
L1F520C: db $98
L1F520D: db $94
L1F520E: db $8F
L1F520F: db $14
L1F5210: db $ED
L1F5211: db $96
L1F5212: db $0A
L1F5213: db $8F
L1F5214: db $93
L1F5215: db $96
L1F5216: db $9D
L1F5217: db $99
L1F5218: db $9D
L1F5219: db $A0
L1F521A: db $A5
L1F521B: db $9D
L1F521C: db $A0
L1F521D: db $A4
L1F521E: db $A7
L1F521F: db $AB
L1F5220: db $AE
L1F5221: db $A7
L1F5222: db $ED
L1F5223: db $8D
L1F5224: db $0A
L1F5225: db $93
L1F5226: db $96
L1F5227: db $91
L1F5228: db $1E
L1F5229: db $93
L1F522A: db $0A
L1F522B: db $99
L1F522C: db $9B
L1F522D: db $96
L1F522E: db $1E
L1F522F: db $9B
L1F5230: db $0A
L1F5231: db $9F
L1F5232: db $A2
L1F5233: db $9D
L1F5234: db $ED
L1F5235: db $8D
L1F5236: db $0A
L1F5237: db $93
L1F5238: db $96
L1F5239: db $91
L1F523A: db $1E
L1F523B: db $93
L1F523C: db $0A
L1F523D: db $99
L1F523E: db $9B
L1F523F: db $96
L1F5240: db $1E
L1F5241: db $9B
L1F5242: db $14
L1F5243: db $A4
L1F5244: db $ED
L1F5245: db $E4
L1F5246: db $77
L1F5247: db $96
L1F5248: db $05
L1F5249: db $80
L1F524A: db $96
L1F524B: db $80
L1F524C: db $A2
L1F524D: db $0A
L1F524E: db $96
L1F524F: db $05
L1F5250: db $80
L1F5251: db $96
L1F5252: db $80
L1F5253: db $A2
L1F5254: db $0A
L1F5255: db $96
L1F5256: db $05
L1F5257: db $80
L1F5258: db $96
L1F5259: db $80
L1F525A: db $A2
L1F525B: db $0A
L1F525C: db $96
L1F525D: db $05
L1F525E: db $80
L1F525F: db $96
L1F5260: db $80
L1F5261: db $A2
L1F5262: db $0A
L1F5263: db $96
L1F5264: db $05
L1F5265: db $80
L1F5266: db $9F
L1F5267: db $0A
L1F5268: db $A0
L1F5269: db $A2
L1F526A: db $94
L1F526B: db $05
L1F526C: db $80
L1F526D: db $94
L1F526E: db $80
L1F526F: db $A2
L1F5270: db $0A
L1F5271: db $94
L1F5272: db $05
L1F5273: db $80
L1F5274: db $94
L1F5275: db $80
L1F5276: db $A2
L1F5277: db $0A
L1F5278: db $94
L1F5279: db $05
L1F527A: db $80
L1F527B: db $94
L1F527C: db $80
L1F527D: db $A2
L1F527E: db $0A
L1F527F: db $94
L1F5280: db $05
L1F5281: db $80
L1F5282: db $94
L1F5283: db $80
L1F5284: db $A2
L1F5285: db $0A
L1F5286: db $94
L1F5287: db $05
L1F5288: db $80
L1F5289: db $9F
L1F528A: db $0A
L1F528B: db $A0
L1F528C: db $A2
L1F528D: db $93
L1F528E: db $05
L1F528F: db $80
L1F5290: db $93
L1F5291: db $80
L1F5292: db $A2
L1F5293: db $0A
L1F5294: db $93
L1F5295: db $05
L1F5296: db $80
L1F5297: db $93
L1F5298: db $80
L1F5299: db $A2
L1F529A: db $0A
L1F529B: db $93
L1F529C: db $05
L1F529D: db $80
L1F529E: db $93
L1F529F: db $80
L1F52A0: db $A2
L1F52A1: db $0A
L1F52A2: db $93
L1F52A3: db $05
L1F52A4: db $80
L1F52A5: db $93
L1F52A6: db $80
L1F52A7: db $A2
L1F52A8: db $0A
L1F52A9: db $93
L1F52AA: db $05
L1F52AB: db $80
L1F52AC: db $9F
L1F52AD: db $0A
L1F52AE: db $A0
L1F52AF: db $A2
L1F52B0: db $92
L1F52B1: db $05
L1F52B2: db $80
L1F52B3: db $92
L1F52B4: db $80
L1F52B5: db $A2
L1F52B6: db $0A
L1F52B7: db $92
L1F52B8: db $05
L1F52B9: db $80
L1F52BA: db $92
L1F52BB: db $80
L1F52BC: db $9E
L1F52BD: db $0A
L1F52BE: db $A0
L1F52BF: db $A2
L1F52C0: db $94
L1F52C1: db $05
L1F52C2: db $80
L1F52C3: db $94
L1F52C4: db $80
L1F52C5: db $9B
L1F52C6: db $0A
L1F52C7: db $94
L1F52C8: db $05
L1F52C9: db $80
L1F52CA: db $94
L1F52CB: db $80
L1F52CC: db $A0
L1F52CD: db $0A
L1F52CE: db $A7
L1F52CF: db $A0
L1F52D0: db $ED
L1F52D1: db $E4
L1F52D2: db $65
L1F52D3: db $A5
L1F52D4: db $0A
L1F52D5: db $AC
L1F52D6: db $A5
L1F52D7: db $05
L1F52D8: db $A5
L1F52D9: db $A9
L1F52DA: db $0A
L1F52DB: db $AC
L1F52DC: db $A5
L1F52DD: db $99
L1F52DE: db $A2
L1F52DF: db $91
L1F52E0: db $05
L1F52E1: db $91
L1F52E2: db $A0
L1F52E3: db $0A
L1F52E4: db $A5
L1F52E5: db $05
L1F52E6: db $A5
L1F52E7: db $99
L1F52E8: db $0A
L1F52E9: db $A0
L1F52EA: db $05
L1F52EB: db $A0
L1F52EC: db $9F
L1F52ED: db $0A
L1F52EE: db $A0
L1F52EF: db $A2
L1F52F0: db $A5
L1F52F1: db $0A
L1F52F2: db $AC
L1F52F3: db $A5
L1F52F4: db $05
L1F52F5: db $A5
L1F52F6: db $A9
L1F52F7: db $0A
L1F52F8: db $AC
L1F52F9: db $A5
L1F52FA: db $99
L1F52FB: db $A2
L1F52FC: db $92
L1F52FD: db $05
L1F52FE: db $92
L1F52FF: db $A2
L1F5300: db $0A
L1F5301: db $A5
L1F5302: db $05
L1F5303: db $A5
L1F5304: db $99
L1F5305: db $0A
L1F5306: db $A2
L1F5307: db $05
L1F5308: db $A2
L1F5309: db $9D
L1F530A: db $A2
L1F530B: db $9D
L1F530C: db $99
L1F530D: db $92
L1F530E: db $96
L1F530F: db $A5
L1F5310: db $0A
L1F5311: db $AC
L1F5312: db $A5
L1F5313: db $05
L1F5314: db $A5
L1F5315: db $A9
L1F5316: db $0A
L1F5317: db $AC
L1F5318: db $A5
L1F5319: db $99
L1F531A: db $A2
L1F531B: db $93
L1F531C: db $05
L1F531D: db $93
L1F531E: db $A0
L1F531F: db $0A
L1F5320: db $A5
L1F5321: db $05
L1F5322: db $A5
L1F5323: db $99
L1F5324: db $0A
L1F5325: db $A0
L1F5326: db $05
L1F5327: db $A0
L1F5328: db $9F
L1F5329: db $0A
L1F532A: db $A0
L1F532B: db $A2
L1F532C: db $ED
L1F532D: db $E4
L1F532E: db $65
L1F532F: db $E6
L1F5330: db $0C
L1F5331: db $92
L1F5332: db $0A
L1F5333: db $96
L1F5334: db $99
L1F5335: db $96
L1F5336: db $86
L1F5337: db $92
L1F5338: db $8D
L1F5339: db $99
L1F533A: db $91
L1F533B: db $94
L1F533C: db $99
L1F533D: db $94
L1F533E: db $85
L1F533F: db $91
L1F5340: db $8D
L1F5341: db $91
L1F5342: db $91
L1F5343: db $96
L1F5344: db $99
L1F5345: db $96
L1F5346: db $85
L1F5347: db $91
L1F5348: db $8D
L1F5349: db $96
L1F534A: db $93
L1F534B: db $96
L1F534C: db $99
L1F534D: db $96
L1F534E: db $87
L1F534F: db $93
L1F5350: db $8F
L1F5351: db $99
L1F5352: db $92
L1F5353: db $0A
L1F5354: db $96
L1F5355: db $99
L1F5356: db $96
L1F5357: db $86
L1F5358: db $92
L1F5359: db $8D
L1F535A: db $99
L1F535B: db $91
L1F535C: db $94
L1F535D: db $99
L1F535E: db $94
L1F535F: db $85
L1F5360: db $91
L1F5361: db $8D
L1F5362: db $91
L1F5363: db $E6
L1F5364: db $F4
L1F5365: db $ED
L1F5366: db $E4
L1F5367: db $67
L1F5368: db $A2
L1F5369: db $1E
L1F536A: db $AA
L1F536B: db $A9
L1F536C: db $14
L1F536D: db $A4
L1F536E: db $1E
L1F536F: db $AC
L1F5370: db $14
L1F5371: db $AA
L1F5372: db $A9
L1F5373: db $0A
L1F5374: db $ED
SndData_08_Ch3: db $E4
L1F5376: db $40
L1F5377: db $E9
L1F5378: db $44
L1F5379: db $F3
L1F537A: db $04
L1F537B: db $F5
L1F537C: db $1E
L1F537D: db $EC
L1F537E: db $9B
L1F537F: db $53
L1F5380: db $EC
L1F5381: db $C6
L1F5382: db $53
L1F5383: db $EC
L1F5384: db $9B
L1F5385: db $53
L1F5386: db $EC
L1F5387: db $D5
L1F5388: db $53
L1F5389: db $EC
L1F538A: db $E6
L1F538B: db $53
L1F538C: db $EC
L1F538D: db $0E
L1F538E: db $54
L1F538F: db $EC
L1F5390: db $85
L1F5391: db $54
L1F5392: db $EC
L1F5393: db $EB
L1F5394: db $54
L1F5395: db $EC
L1F5396: db $12
L1F5397: db $55
L1F5398: db $E5
L1F5399: db $75
L1F539A: db $53
L1F539B: db $94
L1F539C: db $05
L1F539D: db $96
L1F539E: db $96
L1F539F: db $0A
L1F53A0: db $96
L1F53A1: db $94
L1F53A2: db $05
L1F53A3: db $96
L1F53A4: db $96
L1F53A5: db $0A
L1F53A6: db $96
L1F53A7: db $96
L1F53A8: db $96
L1F53A9: db $93
L1F53AA: db $05
L1F53AB: db $94
L1F53AC: db $94
L1F53AD: db $0A
L1F53AE: db $94
L1F53AF: db $93
L1F53B0: db $05
L1F53B1: db $94
L1F53B2: db $94
L1F53B3: db $0A
L1F53B4: db $94
L1F53B5: db $94
L1F53B6: db $94
L1F53B7: db $92
L1F53B8: db $05
L1F53B9: db $93
L1F53BA: db $93
L1F53BB: db $0A
L1F53BC: db $93
L1F53BD: db $92
L1F53BE: db $05
L1F53BF: db $93
L1F53C0: db $93
L1F53C1: db $0A
L1F53C2: db $93
L1F53C3: db $93
L1F53C4: db $93
L1F53C5: db $ED
L1F53C6: db $99
L1F53C7: db $05
L1F53C8: db $9B
L1F53C9: db $9B
L1F53CA: db $0A
L1F53CB: db $9B
L1F53CC: db $99
L1F53CD: db $05
L1F53CE: db $9B
L1F53CF: db $9B
L1F53D0: db $0A
L1F53D1: db $9B
L1F53D2: db $9B
L1F53D3: db $9B
L1F53D4: db $ED
L1F53D5: db $99
L1F53D6: db $05
L1F53D7: db $9B
L1F53D8: db $9B
L1F53D9: db $0A
L1F53DA: db $9B
L1F53DB: db $F5
L1F53DC: db $3C
L1F53DD: db $99
L1F53DE: db $14
L1F53DF: db $F5
L1F53E0: db $1E
L1F53E1: db $93
L1F53E2: db $0A
L1F53E3: db $94
L1F53E4: db $95
L1F53E5: db $ED
L1F53E6: db $F5
L1F53E7: db $00
L1F53E8: db $96
L1F53E9: db $1E
L1F53EA: db $A2
L1F53EB: db $A0
L1F53EC: db $9B
L1F53ED: db $9D
L1F53EE: db $14
L1F53EF: db $99
L1F53F0: db $93
L1F53F1: db $1E
L1F53F2: db $9F
L1F53F3: db $9B
L1F53F4: db $99
L1F53F5: db $9B
L1F53F6: db $14
L1F53F7: db $94
L1F53F8: db $E7
L1F53F9: db $00
L1F53FA: db $03
L1F53FB: db $E6
L1F53FC: db $53
L1F53FD: db $96
L1F53FE: db $1E
L1F53FF: db $A2
L1F5400: db $A0
L1F5401: db $9B
L1F5402: db $9D
L1F5403: db $14
L1F5404: db $99
L1F5405: db $93
L1F5406: db $1E
L1F5407: db $9F
L1F5408: db $99
L1F5409: db $9E
L1F540A: db $92
L1F540B: db $14
L1F540C: db $94
L1F540D: db $ED
L1F540E: db $F5
L1F540F: db $1E
L1F5410: db $94
L1F5411: db $05
L1F5412: db $96
L1F5413: db $96
L1F5414: db $0A
L1F5415: db $96
L1F5416: db $94
L1F5417: db $05
L1F5418: db $96
L1F5419: db $96
L1F541A: db $0A
L1F541B: db $96
L1F541C: db $94
L1F541D: db $05
L1F541E: db $96
L1F541F: db $96
L1F5420: db $0A
L1F5421: db $96
L1F5422: db $95
L1F5423: db $05
L1F5424: db $96
L1F5425: db $96
L1F5426: db $0A
L1F5427: db $91
L1F5428: db $96
L1F5429: db $96
L1F542A: db $91
L1F542B: db $96
L1F542C: db $93
L1F542D: db $05
L1F542E: db $94
L1F542F: db $94
L1F5430: db $0A
L1F5431: db $94
L1F5432: db $93
L1F5433: db $05
L1F5434: db $94
L1F5435: db $94
L1F5436: db $0A
L1F5437: db $94
L1F5438: db $93
L1F5439: db $05
L1F543A: db $94
L1F543B: db $94
L1F543C: db $0A
L1F543D: db $94
L1F543E: db $93
L1F543F: db $05
L1F5440: db $94
L1F5441: db $94
L1F5442: db $0A
L1F5443: db $8F
L1F5444: db $94
L1F5445: db $94
L1F5446: db $8F
L1F5447: db $94
L1F5448: db $92
L1F5449: db $05
L1F544A: db $93
L1F544B: db $93
L1F544C: db $0A
L1F544D: db $93
L1F544E: db $92
L1F544F: db $05
L1F5450: db $93
L1F5451: db $93
L1F5452: db $0A
L1F5453: db $93
L1F5454: db $92
L1F5455: db $05
L1F5456: db $93
L1F5457: db $93
L1F5458: db $0A
L1F5459: db $93
L1F545A: db $92
L1F545B: db $05
L1F545C: db $93
L1F545D: db $93
L1F545E: db $0A
L1F545F: db $99
L1F5460: db $93
L1F5461: db $8F
L1F5462: db $96
L1F5463: db $8F
L1F5464: db $91
L1F5465: db $05
L1F5466: db $92
L1F5467: db $92
L1F5468: db $0A
L1F5469: db $92
L1F546A: db $91
L1F546B: db $05
L1F546C: db $92
L1F546D: db $92
L1F546E: db $0A
L1F546F: db $92
L1F5470: db $91
L1F5471: db $05
L1F5472: db $92
L1F5473: db $92
L1F5474: db $0A
L1F5475: db $93
L1F5476: db $05
L1F5477: db $94
L1F5478: db $94
L1F5479: db $0A
L1F547A: db $94
L1F547B: db $F5
L1F547C: db $3C
L1F547D: db $9B
L1F547E: db $14
L1F547F: db $99
L1F5480: db $94
L1F5481: db $0A
L1F5482: db $F5
L1F5483: db $1E
L1F5484: db $ED
L1F5485: db $94
L1F5486: db $05
L1F5487: db $96
L1F5488: db $96
L1F5489: db $0A
L1F548A: db $96
L1F548B: db $94
L1F548C: db $05
L1F548D: db $96
L1F548E: db $96
L1F548F: db $0A
L1F5490: db $96
L1F5491: db $94
L1F5492: db $05
L1F5493: db $96
L1F5494: db $96
L1F5495: db $0A
L1F5496: db $93
L1F5497: db $05
L1F5498: db $94
L1F5499: db $94
L1F549A: db $0A
L1F549B: db $94
L1F549C: db $93
L1F549D: db $05
L1F549E: db $94
L1F549F: db $94
L1F54A0: db $0A
L1F54A1: db $94
L1F54A2: db $93
L1F54A3: db $05
L1F54A4: db $94
L1F54A5: db $94
L1F54A6: db $0A
L1F54A7: db $92
L1F54A8: db $05
L1F54A9: db $93
L1F54AA: db $93
L1F54AB: db $0A
L1F54AC: db $93
L1F54AD: db $92
L1F54AE: db $05
L1F54AF: db $93
L1F54B0: db $93
L1F54B1: db $0A
L1F54B2: db $93
L1F54B3: db $92
L1F54B4: db $05
L1F54B5: db $93
L1F54B6: db $93
L1F54B7: db $0A
L1F54B8: db $91
L1F54B9: db $05
L1F54BA: db $92
L1F54BB: db $92
L1F54BC: db $0A
L1F54BD: db $92
L1F54BE: db $F5
L1F54BF: db $3C
L1F54C0: db $96
L1F54C1: db $14
L1F54C2: db $F5
L1F54C3: db $1E
L1F54C4: db $9B
L1F54C5: db $0A
L1F54C6: db $99
L1F54C7: db $91
L1F54C8: db $98
L1F54C9: db $05
L1F54CA: db $99
L1F54CB: db $99
L1F54CC: db $0A
L1F54CD: db $99
L1F54CE: db $98
L1F54CF: db $05
L1F54D0: db $99
L1F54D1: db $99
L1F54D2: db $0A
L1F54D3: db $99
L1F54D4: db $98
L1F54D5: db $05
L1F54D6: db $99
L1F54D7: db $99
L1F54D8: db $0A
L1F54D9: db $9A
L1F54DA: db $05
L1F54DB: db $9B
L1F54DC: db $9B
L1F54DD: db $0A
L1F54DE: db $9B
L1F54DF: db $9A
L1F54E0: db $05
L1F54E1: db $9B
L1F54E2: db $9B
L1F54E3: db $0A
L1F54E4: db $9B
L1F54E5: db $9A
L1F54E6: db $05
L1F54E7: db $9B
L1F54E8: db $9B
L1F54E9: db $0A
L1F54EA: db $ED
L1F54EB: db $F5
L1F54EC: db $00
L1F54ED: db $92
L1F54EE: db $1E
L1F54EF: db $96
L1F54F0: db $0A
L1F54F1: db $99
L1F54F2: db $9B
L1F54F3: db $92
L1F54F4: db $14
L1F54F5: db $91
L1F54F6: db $28
L1F54F7: db $91
L1F54F8: db $14
L1F54F9: db $94
L1F54FA: db $96
L1F54FB: db $28
L1F54FC: db $FA
L1F54FD: db $0A
L1F54FE: db $96
L1F54FF: db $0A
L1F5500: db $91
L1F5501: db $8D
L1F5502: db $8F
L1F5503: db $3C
L1F5504: db $FA
L1F5505: db $0A
L1F5506: db $8F
L1F5507: db $92
L1F5508: db $1E
L1F5509: db $99
L1F550A: db $92
L1F550B: db $14
L1F550C: db $91
L1F550D: db $1E
L1F550E: db $98
L1F550F: db $91
L1F5510: db $14
L1F5511: db $ED
L1F5512: db $92
L1F5513: db $1E
L1F5514: db $9E
L1F5515: db $99
L1F5516: db $14
L1F5517: db $94
L1F5518: db $1E
L1F5519: db $A0
L1F551A: db $9B
L1F551B: db $14
L1F551C: db $F5
L1F551D: db $1E
L1F551E: db $ED
SndData_08_Ch4: db $E9
L1F5520: db $88
L1F5521: db $EC
L1F5522: db $66
L1F5523: db $55
L1F5524: db $EC
L1F5525: db $7A
L1F5526: db $55
L1F5527: db $EC
L1F5528: db $66
L1F5529: db $55
L1F552A: db $EC
L1F552B: db $9F
L1F552C: db $55
L1F552D: db $EC
L1F552E: db $C8
L1F552F: db $55
L1F5530: db $EC
L1F5531: db $E3
L1F5532: db $55
L1F5533: db $EC
L1F5534: db $C8
L1F5535: db $55
L1F5536: db $EC
L1F5537: db $F6
L1F5538: db $55
L1F5539: db $EC
L1F553A: db $C8
L1F553B: db $55
L1F553C: db $EC
L1F553D: db $E3
L1F553E: db $55
L1F553F: db $EC
L1F5540: db $C8
L1F5541: db $55
L1F5542: db $EC
L1F5543: db $F6
L1F5544: db $55
L1F5545: db $EC
L1F5546: db $0F
L1F5547: db $56
L1F5548: db $EC
L1F5549: db $2B
L1F554A: db $56
L1F554B: db $EC
L1F554C: db $0F
L1F554D: db $56
L1F554E: db $EC
L1F554F: db $48
L1F5550: db $56
L1F5551: db $EC
L1F5552: db $66
L1F5553: db $55
L1F5554: db $EC
L1F5555: db $7A
L1F5556: db $55
L1F5557: db $EC
L1F5558: db $66
L1F5559: db $55
L1F555A: db $EC
L1F555B: db $9F
L1F555C: db $55
L1F555D: db $EC
L1F555E: db $71
L1F555F: db $56
L1F5560: db $EC
L1F5561: db $C2
L1F5562: db $56
L1F5563: db $E5
L1F5564: db $1F
L1F5565: db $55
L1F5566: db $E4
L1F5567: db $61
L1F5568: db $36
L1F5569: db $0A
L1F556A: db $36
L1F556B: db $0A
L1F556C: db $E4
L1F556D: db $62
L1F556E: db $24
L1F556F: db $0A
L1F5570: db $E4
L1F5571: db $61
L1F5572: db $36
L1F5573: db $0A
L1F5574: db $E7
L1F5575: db $00
L1F5576: db $06
L1F5577: db $66
L1F5578: db $55
L1F5579: db $ED
L1F557A: db $E4
L1F557B: db $61
L1F557C: db $36
L1F557D: db $0A
L1F557E: db $36
L1F557F: db $0A
L1F5580: db $E4
L1F5581: db $62
L1F5582: db $24
L1F5583: db $0A
L1F5584: db $E4
L1F5585: db $61
L1F5586: db $36
L1F5587: db $05
L1F5588: db $E4
L1F5589: db $62
L1F558A: db $24
L1F558B: db $05
L1F558C: db $E4
L1F558D: db $61
L1F558E: db $36
L1F558F: db $0A
L1F5590: db $36
L1F5591: db $0A
L1F5592: db $E4
L1F5593: db $62
L1F5594: db $24
L1F5595: db $0A
L1F5596: db $E4
L1F5597: db $61
L1F5598: db $36
L1F5599: db $05
L1F559A: db $E4
L1F559B: db $62
L1F559C: db $24
L1F559D: db $05
L1F559E: db $ED
L1F559F: db $E4
L1F55A0: db $61
L1F55A1: db $36
L1F55A2: db $05
L1F55A3: db $E4
L1F55A4: db $62
L1F55A5: db $24
L1F55A6: db $05
L1F55A7: db $E4
L1F55A8: db $61
L1F55A9: db $36
L1F55AA: db $05
L1F55AB: db $36
L1F55AC: db $05
L1F55AD: db $E4
L1F55AE: db $62
L1F55AF: db $24
L1F55B0: db $0A
L1F55B1: db $E4
L1F55B2: db $61
L1F55B3: db $36
L1F55B4: db $0A
L1F55B5: db $36
L1F55B6: db $0A
L1F55B7: db $36
L1F55B8: db $05
L1F55B9: db $36
L1F55BA: db $05
L1F55BB: db $E4
L1F55BC: db $62
L1F55BD: db $24
L1F55BE: db $02
L1F55BF: db $24
L1F55C0: db $03
L1F55C1: db $24
L1F55C2: db $05
L1F55C3: db $24
L1F55C4: db $05
L1F55C5: db $24
L1F55C6: db $05
L1F55C7: db $ED
L1F55C8: db $E4
L1F55C9: db $61
L1F55CA: db $36
L1F55CB: db $0A
L1F55CC: db $36
L1F55CD: db $0A
L1F55CE: db $E4
L1F55CF: db $53
L1F55D0: db $11
L1F55D1: db $0A
L1F55D2: db $E4
L1F55D3: db $62
L1F55D4: db $24
L1F55D5: db $14
L1F55D6: db $E4
L1F55D7: db $34
L1F55D8: db $26
L1F55D9: db $0A
L1F55DA: db $E4
L1F55DB: db $44
L1F55DC: db $26
L1F55DD: db $0A
L1F55DE: db $E4
L1F55DF: db $61
L1F55E0: db $36
L1F55E1: db $0A
L1F55E2: db $ED
L1F55E3: db $E4
L1F55E4: db $11
L1F55E5: db $21
L1F55E6: db $0A
L1F55E7: db $E4
L1F55E8: db $61
L1F55E9: db $36
L1F55EA: db $0A
L1F55EB: db $36
L1F55EC: db $14
L1F55ED: db $E4
L1F55EE: db $62
L1F55EF: db $24
L1F55F0: db $14
L1F55F1: db $E4
L1F55F2: db $61
L1F55F3: db $36
L1F55F4: db $14
L1F55F5: db $ED
L1F55F6: db $E4
L1F55F7: db $11
L1F55F8: db $21
L1F55F9: db $0A
L1F55FA: db $E4
L1F55FB: db $61
L1F55FC: db $36
L1F55FD: db $0A
L1F55FE: db $E4
L1F55FF: db $53
L1F5600: db $11
L1F5601: db $14
L1F5602: db $E4
L1F5603: db $62
L1F5604: db $24
L1F5605: db $0A
L1F5606: db $E4
L1F5607: db $44
L1F5608: db $26
L1F5609: db $0A
L1F560A: db $E4
L1F560B: db $54
L1F560C: db $26
L1F560D: db $14
L1F560E: db $ED
L1F560F: db $E4
L1F5610: db $61
L1F5611: db $36
L1F5612: db $0A
L1F5613: db $36
L1F5614: db $0A
L1F5615: db $E4
L1F5616: db $53
L1F5617: db $11
L1F5618: db $14
L1F5619: db $E4
L1F561A: db $62
L1F561B: db $24
L1F561C: db $0A
L1F561D: db $E4
L1F561E: db $61
L1F561F: db $36
L1F5620: db $0A
L1F5621: db $E4
L1F5622: db $53
L1F5623: db $11
L1F5624: db $14
L1F5625: db $E7
L1F5626: db $00
L1F5627: db $03
L1F5628: db $0F
L1F5629: db $56
L1F562A: db $ED
L1F562B: db $E4
L1F562C: db $61
L1F562D: db $36
L1F562E: db $0A
L1F562F: db $36
L1F5630: db $0A
L1F5631: db $E4
L1F5632: db $53
L1F5633: db $11
L1F5634: db $0A
L1F5635: db $E4
L1F5636: db $61
L1F5637: db $36
L1F5638: db $05
L1F5639: db $36
L1F563A: db $05
L1F563B: db $E4
L1F563C: db $62
L1F563D: db $24
L1F563E: db $0A
L1F563F: db $E4
L1F5640: db $53
L1F5641: db $11
L1F5642: db $14
L1F5643: db $E4
L1F5644: db $61
L1F5645: db $36
L1F5646: db $0A
L1F5647: db $ED
L1F5648: db $E4
L1F5649: db $61
L1F564A: db $36
L1F564B: db $0A
L1F564C: db $E4
L1F564D: db $62
L1F564E: db $24
L1F564F: db $0A
L1F5650: db $24
L1F5651: db $02
L1F5652: db $24
L1F5653: db $03
L1F5654: db $24
L1F5655: db $05
L1F5656: db $24
L1F5657: db $05
L1F5658: db $24
L1F5659: db $05
L1F565A: db $24
L1F565B: db $05
L1F565C: db $24
L1F565D: db $02
L1F565E: db $24
L1F565F: db $03
L1F5660: db $24
L1F5661: db $05
L1F5662: db $24
L1F5663: db $05
L1F5664: db $E4
L1F5665: db $44
L1F5666: db $26
L1F5667: db $05
L1F5668: db $10
L1F5669: db $05
L1F566A: db $E4
L1F566B: db $54
L1F566C: db $26
L1F566D: db $05
L1F566E: db $32
L1F566F: db $05
L1F5670: db $ED
L1F5671: db $E4
L1F5672: db $61
L1F5673: db $36
L1F5674: db $0A
L1F5675: db $36
L1F5676: db $05
L1F5677: db $36
L1F5678: db $05
L1F5679: db $E4
L1F567A: db $62
L1F567B: db $24
L1F567C: db $0A
L1F567D: db $E4
L1F567E: db $61
L1F567F: db $36
L1F5680: db $05
L1F5681: db $36
L1F5682: db $05
L1F5683: db $E7
L1F5684: db $00
L1F5685: db $07
L1F5686: db $71
L1F5687: db $56
L1F5688: db $E4
L1F5689: db $61
L1F568A: db $36
L1F568B: db $0A
L1F568C: db $36
L1F568D: db $05
L1F568E: db $36
L1F568F: db $05
L1F5690: db $E4
L1F5691: db $62
L1F5692: db $24
L1F5693: db $05
L1F5694: db $24
L1F5695: db $05
L1F5696: db $24
L1F5697: db $05
L1F5698: db $24
L1F5699: db $05
L1F569A: db $E4
L1F569B: db $61
L1F569C: db $36
L1F569D: db $0A
L1F569E: db $36
L1F569F: db $05
L1F56A0: db $36
L1F56A1: db $05
L1F56A2: db $E4
L1F56A3: db $62
L1F56A4: db $24
L1F56A5: db $0A
L1F56A6: db $E4
L1F56A7: db $61
L1F56A8: db $36
L1F56A9: db $05
L1F56AA: db $36
L1F56AB: db $05
L1F56AC: db $E7
L1F56AD: db $00
L1F56AE: db $03
L1F56AF: db $9A
L1F56B0: db $56
L1F56B1: db $E4
L1F56B2: db $61
L1F56B3: db $36
L1F56B4: db $0A
L1F56B5: db $E4
L1F56B6: db $34
L1F56B7: db $26
L1F56B8: db $0A
L1F56B9: db $E4
L1F56BA: db $44
L1F56BB: db $26
L1F56BC: db $0A
L1F56BD: db $E4
L1F56BE: db $54
L1F56BF: db $26
L1F56C0: db $0A
L1F56C1: db $ED
L1F56C2: db $E4
L1F56C3: db $61
L1F56C4: db $36
L1F56C5: db $0A
L1F56C6: db $E4
L1F56C7: db $31
L1F56C8: db $21
L1F56C9: db $0A
L1F56CA: db $E4
L1F56CB: db $53
L1F56CC: db $11
L1F56CD: db $14
L1F56CE: db $E7
L1F56CF: db $00
L1F56D0: db $07
L1F56D1: db $C2
L1F56D2: db $56
L1F56D3: db $E4
L1F56D4: db $62
L1F56D5: db $24
L1F56D6: db $0A
L1F56D7: db $E4
L1F56D8: db $34
L1F56D9: db $26
L1F56DA: db $0A
L1F56DB: db $E4
L1F56DC: db $44
L1F56DD: db $26
L1F56DE: db $0A
L1F56DF: db $E4
L1F56E0: db $54
L1F56E1: db $26
L1F56E2: db $0A
L1F56E3: db $E4
L1F56E4: db $61
L1F56E5: db $36
L1F56E6: db $0A
L1F56E7: db $E4
L1F56E8: db $31
L1F56E9: db $21
L1F56EA: db $0A
L1F56EB: db $E4
L1F56EC: db $53
L1F56ED: db $11
L1F56EE: db $14
L1F56EF: db $E7
L1F56F0: db $00
L1F56F1: db $03
L1F56F2: db $E3
L1F56F3: db $56
L1F56F4: db $E4
L1F56F5: db $62
L1F56F6: db $24
L1F56F7: db $0A
L1F56F8: db $24
L1F56F9: db $0A
L1F56FA: db $24
L1F56FB: db $0A
L1F56FC: db $E4
L1F56FD: db $61
L1F56FE: db $36
L1F56FF: db $0A
L1F5700: db $E4
L1F5701: db $62
L1F5702: db $24
L1F5703: db $0A
L1F5704: db $E4
L1F5705: db $61
L1F5706: db $36
L1F5707: db $14
L1F5708: db $E7
L1F5709: db $00
L1F570A: db $03
L1F570B: db $00
L1F570C: db $57
L1F570D: db $E4
L1F570E: db $62
L1F570F: db $24
L1F5710: db $0A
L1F5711: db $E4
L1F5712: db $61
L1F5713: db $36
L1F5714: db $0A
L1F5715: db $E4
L1F5716: db $62
L1F5717: db $24
L1F5718: db $0A
L1F5719: db $24
L1F571A: db $0A
L1F571B: db $E4
L1F571C: db $44
L1F571D: db $26
L1F571E: db $0A
L1F571F: db $E4
L1F5720: db $54
L1F5721: db $26
L1F5722: db $14
L1F5723: db $ED
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
SndData_04_Ch1: db $E4
L1F573E: db $77
L1F573F: db $E9
L1F5740: db $11
L1F5741: db $EE
L1F5742: db $C0
L1F5743: db $94
L1F5744: db $50
L1F5745: db $E4
L1F5746: db $77
L1F5747: db $EC
L1F5748: db $70
L1F5749: db $57
L1F574A: db $EC
L1F574B: db $B0
L1F574C: db $57
L1F574D: db $EC
L1F574E: db $C1
L1F574F: db $57
L1F5750: db $EC
L1F5751: db $C6
L1F5752: db $57
L1F5753: db $EC
L1F5754: db $EC
L1F5755: db $57
L1F5756: db $EC
L1F5757: db $08
L1F5758: db $58
L1F5759: db $EC
L1F575A: db $2E
L1F575B: db $58
L1F575C: db $EC
L1F575D: db $56
L1F575E: db $58
L1F575F: db $EC
L1F5760: db $6B
L1F5761: db $58
L1F5762: db $E5
L1F5763: db $45
L1F5764: db $57
L1F5765: db $E4;X
L1F5766: db $77;X
L1F5767: db $EE;X
L1F5768: db $C0;X
L1F5769: db $94;X
L1F576A: db $28;X
L1F576B: db $88;X
L1F576C: db $05;X
L1F576D: db $80;X
L1F576E: db $94;X
L1F576F: db $1E;X
L1F5770: db $94
L1F5771: db $0A
L1F5772: db $94
L1F5773: db $05
L1F5774: db $80
L1F5775: db $8B
L1F5776: db $80
L1F5777: db $92
L1F5778: db $0A
L1F5779: db $92
L1F577A: db $05
L1F577B: db $80
L1F577C: db $8B
L1F577D: db $80
L1F577E: db $94
L1F577F: db $0A
L1F5780: db $94
L1F5781: db $05
L1F5782: db $80
L1F5783: db $97
L1F5784: db $50
L1F5785: db $97
L1F5786: db $0A
L1F5787: db $97
L1F5788: db $05
L1F5789: db $80
L1F578A: db $8F
L1F578B: db $80
L1F578C: db $96
L1F578D: db $0A
L1F578E: db $96
L1F578F: db $05
L1F5790: db $80
L1F5791: db $8F
L1F5792: db $80
L1F5793: db $97
L1F5794: db $0A
L1F5795: db $97
L1F5796: db $05
L1F5797: db $80
L1F5798: db $99
L1F5799: db $50
L1F579A: db $99
L1F579B: db $0A
L1F579C: db $99
L1F579D: db $05
L1F579E: db $80
L1F579F: db $94
L1F57A0: db $80
L1F57A1: db $9B
L1F57A2: db $0A
L1F57A3: db $9B
L1F57A4: db $05
L1F57A5: db $80
L1F57A6: db $94
L1F57A7: db $80
L1F57A8: db $99
L1F57A9: db $0A
L1F57AA: db $99
L1F57AB: db $05
L1F57AC: db $80
L1F57AD: db $9B
L1F57AE: db $50
L1F57AF: db $ED
L1F57B0: db $96
L1F57B1: db $0A
L1F57B2: db $96
L1F57B3: db $05
L1F57B4: db $80
L1F57B5: db $8F
L1F57B6: db $80
L1F57B7: db $97
L1F57B8: db $0A
L1F57B9: db $97
L1F57BA: db $05
L1F57BB: db $80
L1F57BC: db $8F
L1F57BD: db $80
L1F57BE: db $99
L1F57BF: db $14
L1F57C0: db $ED
L1F57C1: db $E4
L1F57C2: db $11
L1F57C3: db $81
L1F57C4: db $3C
L1F57C5: db $ED
L1F57C6: db $E4
L1F57C7: db $78
L1F57C8: db $A0
L1F57C9: db $0A
L1F57CA: db $9B
L1F57CB: db $A2
L1F57CC: db $A3
L1F57CD: db $0D
L1F57CE: db $80
L1F57CF: db $07
L1F57D0: db $A5
L1F57D1: db $14
L1F57D2: db $A3
L1F57D3: db $0A
L1F57D4: db $9E
L1F57D5: db $A0
L1F57D6: db $1E
L1F57D7: db $E4
L1F57D8: db $11
L1F57D9: db $88
L1F57DA: db $28
L1F57DB: db $E4
L1F57DC: db $78
L1F57DD: db $A0
L1F57DE: db $0A
L1F57DF: db $9B
L1F57E0: db $A2
L1F57E1: db $A3
L1F57E2: db $0D
L1F57E3: db $80
L1F57E4: db $07
L1F57E5: db $A5
L1F57E6: db $14
L1F57E7: db $A3
L1F57E8: db $0A
L1F57E9: db $A2
L1F57EA: db $A0
L1F57EB: db $ED
L1F57EC: db $A3
L1F57ED: db $28
L1F57EE: db $80
L1F57EF: db $0A
L1F57F0: db $A3
L1F57F1: db $A2
L1F57F2: db $A3
L1F57F3: db $A2
L1F57F4: db $14
L1F57F5: db $80
L1F57F6: db $0A
L1F57F7: db $A5
L1F57F8: db $1E
L1F57F9: db $9E
L1F57FA: db $14
L1F57FB: db $A0
L1F57FC: db $1E
L1F57FD: db $E4
L1F57FE: db $11
L1F57FF: db $3C
L1F5800: db $8F
L1F5801: db $0A
L1F5802: db $8D
L1F5803: db $8F
L1F5804: db $92
L1F5805: db $8F
L1F5806: db $14
L1F5807: db $ED
L1F5808: db $E4
L1F5809: db $78
L1F580A: db $9D
L1F580B: db $02
L1F580C: db $9E
L1F580D: db $A0
L1F580E: db $A2
L1F580F: db $A3
L1F5810: db $A5
L1F5811: db $1E
L1F5812: db $80
L1F5813: db $0A
L1F5814: db $A5
L1F5815: db $A0
L1F5816: db $A3
L1F5817: db $A5
L1F5818: db $0D
L1F5819: db $80
L1F581A: db $07
L1F581B: db $A5
L1F581C: db $0A
L1F581D: db $A3
L1F581E: db $A5
L1F581F: db $A0
L1F5820: db $AA
L1F5821: db $14
L1F5822: db $80
L1F5823: db $0A
L1F5824: db $AA
L1F5825: db $A0
L1F5826: db $14
L1F5827: db $E4
L1F5828: db $11
L1F5829: db $88
L1F582A: db $28
L1F582B: db $FA
L1F582C: db $0A
L1F582D: db $ED
L1F582E: db $E4
L1F582F: db $11
L1F5830: db $88
L1F5831: db $28
L1F5832: db $E4
L1F5833: db $78
L1F5834: db $A0
L1F5835: db $14
L1F5836: db $A2
L1F5837: db $A3
L1F5838: db $28
L1F5839: db $80
L1F583A: db $0A
L1F583B: db $A0
L1F583C: db $A2
L1F583D: db $A3
L1F583E: db $A5
L1F583F: db $14
L1F5840: db $80
L1F5841: db $0A
L1F5842: db $A7
L1F5843: db $1E
L1F5844: db $AA
L1F5845: db $14
L1F5846: db $A9
L1F5847: db $1E
L1F5848: db $80
L1F5849: db $0A
L1F584A: db $A9
L1F584B: db $A7
L1F584C: db $A9
L1F584D: db $AC
L1F584E: db $1E
L1F584F: db $80
L1F5850: db $0A
L1F5851: db $A5
L1F5852: db $28
L1F5853: db $80
L1F5854: db $0A
L1F5855: db $ED
L1F5856: db $E4
L1F5857: db $78
L1F5858: db $A7
L1F5859: db $3C
L1F585A: db $80
L1F585B: db $0A
L1F585C: db $AE
L1F585D: db $FA
L1F585E: db $3C
L1F585F: db $AA
L1F5860: db $0A
L1F5861: db $AC
L1F5862: db $FA
L1F5863: db $3C
L1F5864: db $80
L1F5865: db $0A
L1F5866: db $AE
L1F5867: db $1E
L1F5868: db $AC
L1F5869: db $14
L1F586A: db $ED
L1F586B: db $AE
L1F586C: db $0D
L1F586D: db $AF
L1F586E: db $0E
L1F586F: db $B1
L1F5870: db $0D
L1F5871: db $B3
L1F5872: db $28
L1F5873: db $80
L1F5874: db $0A
L1F5875: db $B3
L1F5876: db $AA
L1F5877: db $AC
L1F5878: db $1E
L1F5879: db $AA
L1F587A: db $14
L1F587B: db $AC
L1F587C: db $0A
L1F587D: db $AA
L1F587E: db $A9
L1F587F: db $AA
L1F5880: db $1E
L1F5881: db $80
L1F5882: db $0A
L1F5883: db $AC
L1F5884: db $1E
L1F5885: db $A9
L1F5886: db $14
L1F5887: db $80
L1F5888: db $0A
L1F5889: db $AE
L1F588A: db $AF
L1F588B: db $B1
L1F588C: db $B6
L1F588D: db $0D
L1F588E: db $B5
L1F588F: db $0E
L1F5890: db $B1
L1F5891: db $0D
L1F5892: db $B3
L1F5893: db $50
L1F5894: db $ED
SndData_04_Ch2: db $E4
L1F5896: db $62
L1F5897: db $E9
L1F5898: db $22
L1F5899: db $EE
L1F589A: db $80
L1F589B: db $EC
L1F589C: db $B9
L1F589D: db $58
L1F589E: db $EC
L1F589F: db $D4
L1F58A0: db $58
L1F58A1: db $EC
L1F58A2: db $47
L1F58A3: db $59
L1F58A4: db $E4
L1F58A5: db $58
L1F58A6: db $94
L1F58A7: db $0A
L1F58A8: db $99
L1F58A9: db $9A
L1F58AA: db $EC
L1F58AB: db $BE
L1F58AC: db $59
L1F58AD: db $EC
L1F58AE: db $DA
L1F58AF: db $59
L1F58B0: db $EC
L1F58B1: db $BE
L1F58B2: db $59
L1F58B3: db $EC
L1F58B4: db $E5
L1F58B5: db $59
L1F58B6: db $E5
L1F58B7: db $9B
L1F58B8: db $58
L1F58B9: db $E4
L1F58BA: db $62
L1F58BB: db $EE
L1F58BC: db $80
L1F58BD: db $AC
L1F58BE: db $0A
L1F58BF: db $A7
L1F58C0: db $B3
L1F58C1: db $A7
L1F58C2: db $AF
L1F58C3: db $A7
L1F58C4: db $B1
L1F58C5: db $A7
L1F58C6: db $AF
L1F58C7: db $A7
L1F58C8: db $AE
L1F58C9: db $A7
L1F58CA: db $B1
L1F58CB: db $A7
L1F58CC: db $AE
L1F58CD: db $A7
L1F58CE: db $E7
L1F58CF: db $00
L1F58D0: db $04
L1F58D1: db $B9
L1F58D2: db $58
L1F58D3: db $ED
L1F58D4: db $E4
L1F58D5: db $67
L1F58D6: db $EE
L1F58D7: db $00
L1F58D8: db $92
L1F58D9: db $0A
L1F58DA: db $92
L1F58DB: db $05
L1F58DC: db $80
L1F58DD: db $8B
L1F58DE: db $80
L1F58DF: db $94
L1F58E0: db $1E
L1F58E1: db $94
L1F58E2: db $05
L1F58E3: db $80
L1F58E4: db $94
L1F58E5: db $80
L1F58E6: db $94
L1F58E7: db $0A
L1F58E8: db $94
L1F58E9: db $05
L1F58EA: db $80
L1F58EB: db $8B
L1F58EC: db $80
L1F58ED: db $94
L1F58EE: db $0A
L1F58EF: db $94
L1F58F0: db $05
L1F58F1: db $80
L1F58F2: db $94
L1F58F3: db $80
L1F58F4: db $8B
L1F58F5: db $0A
L1F58F6: db $94
L1F58F7: db $05
L1F58F8: db $80
L1F58F9: db $92
L1F58FA: db $0A
L1F58FB: db $92
L1F58FC: db $05
L1F58FD: db $80
L1F58FE: db $8B
L1F58FF: db $80
L1F5900: db $94
L1F5901: db $1E
L1F5902: db $94
L1F5903: db $05
L1F5904: db $80
L1F5905: db $94
L1F5906: db $80
L1F5907: db $94
L1F5908: db $0A
L1F5909: db $94
L1F590A: db $05
L1F590B: db $80
L1F590C: db $8B
L1F590D: db $80
L1F590E: db $94
L1F590F: db $0A
L1F5910: db $94
L1F5911: db $05
L1F5912: db $80
L1F5913: db $94
L1F5914: db $80
L1F5915: db $96
L1F5916: db $14
L1F5917: db $97
L1F5918: db $8F
L1F5919: db $05
L1F591A: db $80
L1F591B: db $97
L1F591C: db $0F
L1F591D: db $80
L1F591E: db $05
L1F591F: db $97
L1F5920: db $0A
L1F5921: db $8F
L1F5922: db $05
L1F5923: db $80
L1F5924: db $97
L1F5925: db $0A
L1F5926: db $92
L1F5927: db $14
L1F5928: db $86
L1F5929: db $05
L1F592A: db $80
L1F592B: db $92
L1F592C: db $1E
L1F592D: db $8D
L1F592E: db $14
L1F592F: db $94
L1F5930: db $0A
L1F5931: db $92
L1F5932: db $94
L1F5933: db $E4
L1F5934: db $11
L1F5935: db $88
L1F5936: db $14
L1F5937: db $E4
L1F5938: db $67
L1F5939: db $94
L1F593A: db $0A
L1F593B: db $92
L1F593C: db $94
L1F593D: db $80
L1F593E: db $A0
L1F593F: db $9E
L1F5940: db $A0
L1F5941: db $A3
L1F5942: db $A0
L1F5943: db $14
L1F5944: db $80
L1F5945: db $0A
L1F5946: db $ED
L1F5947: db $92
L1F5948: db $14
L1F5949: db $86
L1F594A: db $05
L1F594B: db $80
L1F594C: db $92
L1F594D: db $1E
L1F594E: db $86
L1F594F: db $05
L1F5950: db $80
L1F5951: db $92
L1F5952: db $0A
L1F5953: db $86
L1F5954: db $0A
L1F5955: db $92
L1F5956: db $86
L1F5957: db $05
L1F5958: db $80
L1F5959: db $86
L1F595A: db $80
L1F595B: db $92
L1F595C: db $0A
L1F595D: db $92
L1F595E: db $05
L1F595F: db $80
L1F5960: db $86
L1F5961: db $0A
L1F5962: db $93
L1F5963: db $92
L1F5964: db $0A
L1F5965: db $94
L1F5966: db $88
L1F5967: db $02
L1F5968: db $80
L1F5969: db $08
L1F596A: db $88
L1F596B: db $02
L1F596C: db $80
L1F596D: db $08
L1F596E: db $97
L1F596F: db $0A
L1F5970: db $94
L1F5971: db $88
L1F5972: db $02
L1F5973: db $80
L1F5974: db $08
L1F5975: db $92
L1F5976: db $0A
L1F5977: db $FA
L1F5978: db $0A
L1F5979: db $94
L1F597A: db $80
L1F597B: db $86
L1F597C: db $02
L1F597D: db $80
L1F597E: db $08
L1F597F: db $94
L1F5980: db $14
L1F5981: db $96
L1F5982: db $90
L1F5983: db $28
L1F5984: db $90
L1F5985: db $0A
L1F5986: db $8B
L1F5987: db $05
L1F5988: db $80
L1F5989: db $8B
L1F598A: db $80
L1F598B: db $90
L1F598C: db $0A
L1F598D: db $FA
L1F598E: db $0A
L1F598F: db $8B
L1F5990: db $05
L1F5991: db $80
L1F5992: db $8B
L1F5993: db $02
L1F5994: db $80
L1F5995: db $08
L1F5996: db $97
L1F5997: db $14
L1F5998: db $8B
L1F5999: db $0A
L1F599A: db $97
L1F599B: db $14
L1F599C: db $96
L1F599D: db $0A
L1F599E: db $E4
L1F599F: db $61
L1F59A0: db $8A
L1F59A1: db $05
L1F59A2: db $8A
L1F59A3: db $8A
L1F59A4: db $8A
L1F59A5: db $E4
L1F59A6: db $67
L1F59A7: db $96
L1F59A8: db $14
L1F59A9: db $8A
L1F59AA: db $02
L1F59AB: db $80
L1F59AC: db $08
L1F59AD: db $8A
L1F59AE: db $02
L1F59AF: db $80
L1F59B0: db $08
L1F59B1: db $99
L1F59B2: db $14
L1F59B3: db $8D
L1F59B4: db $02
L1F59B5: db $80
L1F59B6: db $08
L1F59B7: db $8D
L1F59B8: db $02
L1F59B9: db $80
L1F59BA: db $08
L1F59BB: db $99
L1F59BC: db $14
L1F59BD: db $ED
L1F59BE: db $9B
L1F59BF: db $28
L1F59C0: db $FA
L1F59C1: db $0A
L1F59C2: db $8F
L1F59C3: db $05
L1F59C4: db $80
L1F59C5: db $9B
L1F59C6: db $0A
L1F59C7: db $99
L1F59C8: db $3C
L1F59C9: db $8D
L1F59CA: db $02
L1F59CB: db $80
L1F59CC: db $08
L1F59CD: db $99
L1F59CE: db $0A
L1F59CF: db $97
L1F59D0: db $FA
L1F59D1: db $28
L1F59D2: db $8B
L1F59D3: db $0A
L1F59D4: db $8B
L1F59D5: db $05
L1F59D6: db $80
L1F59D7: db $97
L1F59D8: db $0A
L1F59D9: db $ED
L1F59DA: db $99
L1F59DB: db $0A
L1F59DC: db $FA
L1F59DD: db $28
L1F59DE: db $96
L1F59DF: db $0D
L1F59E0: db $92
L1F59E1: db $0E
L1F59E2: db $92
L1F59E3: db $0D
L1F59E4: db $ED
L1F59E5: db $99
L1F59E6: db $28
L1F59E7: db $8D
L1F59E8: db $02
L1F59E9: db $80
L1F59EA: db $08
L1F59EB: db $9E
L1F59EC: db $0A
L1F59ED: db $9B
L1F59EE: db $14
L1F59EF: db $99
L1F59F0: db $0A
L1F59F1: db $ED
SndData_04_Ch3: db $E4
L1F59F3: db $40
L1F59F4: db $E9
L1F59F5: db $44
L1F59F6: db $F3
L1F59F7: db $04
L1F59F8: db $F5
L1F59F9: db $01
L1F59FA: db $F5
L1F59FB: db $19
L1F59FC: db $E6
L1F59FD: db $0C
L1F59FE: db $EC
L1F59FF: db $1B
L1F5A00: db $5A
L1F5A01: db $E6
L1F5A02: db $F4
L1F5A03: db $EC
L1F5A04: db $2F
L1F5A05: db $5A
L1F5A06: db $EC
L1F5A07: db $7E
L1F5A08: db $5A
L1F5A09: db $EC
L1F5A0A: db $9C
L1F5A0B: db $5A
L1F5A0C: db $EC
L1F5A0D: db $C8
L1F5A0E: db $5A
L1F5A0F: db $EC
L1F5A10: db $06
L1F5A11: db $5B
L1F5A12: db $EC
L1F5A13: db $C8
L1F5A14: db $5A
L1F5A15: db $EC
L1F5A16: db $1D
L1F5A17: db $5B
L1F5A18: db $E5
L1F5A19: db $FA
L1F5A1A: db $59
L1F5A1B: db $88
L1F5A1C: db $0A
L1F5A1D: db $E7
L1F5A1E: db $00
L1F5A1F: db $38
L1F5A20: db $1B
L1F5A21: db $5A
L1F5A22: db $F5
L1F5A23: db $5A
L1F5A24: db $8A
L1F5A25: db $14
L1F5A26: db $83
L1F5A27: db $0A
L1F5A28: db $8B
L1F5A29: db $14
L1F5A2A: db $83
L1F5A2B: db $0A
L1F5A2C: db $8D
L1F5A2D: db $14
L1F5A2E: db $ED
L1F5A2F: db $F5
L1F5A30: db $3C
L1F5A31: db $86
L1F5A32: db $0A
L1F5A33: db $88
L1F5A34: db $14
L1F5A35: db $88
L1F5A36: db $1E
L1F5A37: db $88
L1F5A38: db $0A
L1F5A39: db $88
L1F5A3A: db $F5
L1F5A3B: db $1E
L1F5A3C: db $88
L1F5A3D: db $88
L1F5A3E: db $83
L1F5A3F: db $88
L1F5A40: db $88
L1F5A41: db $88
L1F5A42: db $8B
L1F5A43: db $86
L1F5A44: db $F5
L1F5A45: db $3C
L1F5A46: db $86
L1F5A47: db $0A
L1F5A48: db $86
L1F5A49: db $14
L1F5A4A: db $88
L1F5A4B: db $1E
L1F5A4C: db $88
L1F5A4D: db $0A
L1F5A4E: db $88
L1F5A4F: db $F5
L1F5A50: db $1E
L1F5A51: db $88
L1F5A52: db $88
L1F5A53: db $83
L1F5A54: db $88
L1F5A55: db $83
L1F5A56: db $88
L1F5A57: db $8A
L1F5A58: db $14
L1F5A59: db $8B
L1F5A5A: db $0A
L1F5A5B: db $8B
L1F5A5C: db $83
L1F5A5D: db $8B
L1F5A5E: db $8B
L1F5A5F: db $83
L1F5A60: db $8B
L1F5A61: db $86
L1F5A62: db $14
L1F5A63: db $86
L1F5A64: db $0A
L1F5A65: db $86
L1F5A66: db $86
L1F5A67: db $86
L1F5A68: db $85
L1F5A69: db $86
L1F5A6A: db $81
L1F5A6B: db $88
L1F5A6C: db $88
L1F5A6D: db $88
L1F5A6E: db $1E
L1F5A6F: db $88
L1F5A70: db $0A
L1F5A71: db $88
L1F5A72: db $88
L1F5A73: db $14
L1F5A74: db $F5
L1F5A75: db $3C
L1F5A76: db $94
L1F5A77: db $0A
L1F5A78: db $92
L1F5A79: db $94
L1F5A7A: db $97
L1F5A7B: db $94
L1F5A7C: db $1E
L1F5A7D: db $ED
L1F5A7E: db $F5
L1F5A7F: db $19
L1F5A80: db $92
L1F5A81: db $0A
L1F5A82: db $86
L1F5A83: db $86
L1F5A84: db $92
L1F5A85: db $86
L1F5A86: db $86
L1F5A87: db $86
L1F5A88: db $92
L1F5A89: db $86
L1F5A8A: db $86
L1F5A8B: db $92
L1F5A8C: db $86
L1F5A8D: db $86
L1F5A8E: db $85
L1F5A8F: db $86
L1F5A90: db $87
L1F5A91: db $F5
L1F5A92: db $3C
L1F5A93: db $99
L1F5A94: db $9B
L1F5A95: db $1E
L1F5A96: db $9E
L1F5A97: db $0A
L1F5A98: db $9B
L1F5A99: db $14
L1F5A9A: db $99
L1F5A9B: db $ED
L1F5A9C: db $9B
L1F5A9D: db $1E
L1F5A9E: db $94
L1F5A9F: db $14
L1F5AA0: db $96
L1F5AA1: db $F5
L1F5AA2: db $28
L1F5AA3: db $84
L1F5AA4: db $0A
L1F5AA5: db $84
L1F5AA6: db $8B
L1F5AA7: db $84
L1F5AA8: db $14
L1F5AA9: db $84
L1F5AAA: db $0A
L1F5AAB: db $88
L1F5AAC: db $84
L1F5AAD: db $14
L1F5AAE: db $84
L1F5AAF: db $0A
L1F5AB0: db $84
L1F5AB1: db $8B
L1F5AB2: db $14
L1F5AB3: db $86
L1F5AB4: db $0A
L1F5AB5: db $8B
L1F5AB6: db $86
L1F5AB7: db $8A
L1F5AB8: db $0A
L1F5AB9: db $8A
L1F5ABA: db $14
L1F5ABB: db $8A
L1F5ABC: db $85
L1F5ABD: db $0A
L1F5ABE: db $8A
L1F5ABF: db $8D
L1F5AC0: db $14
L1F5AC1: db $8D
L1F5AC2: db $8D
L1F5AC3: db $88
L1F5AC4: db $0A
L1F5AC5: db $8D
L1F5AC6: db $8E
L1F5AC7: db $ED
L1F5AC8: db $F5
L1F5AC9: db $14
L1F5ACA: db $8F
L1F5ACB: db $0A
L1F5ACC: db $8F
L1F5ACD: db $05
L1F5ACE: db $8F
L1F5ACF: db $8F
L1F5AD0: db $0A
L1F5AD1: db $8F
L1F5AD2: db $05
L1F5AD3: db $8F
L1F5AD4: db $8F
L1F5AD5: db $0A
L1F5AD6: db $8F
L1F5AD7: db $05
L1F5AD8: db $8F
L1F5AD9: db $8F
L1F5ADA: db $0A
L1F5ADB: db $F5
L1F5ADC: db $3C
L1F5ADD: db $8D
L1F5ADE: db $14
L1F5ADF: db $F5
L1F5AE0: db $14
L1F5AE1: db $8D
L1F5AE2: db $05
L1F5AE3: db $8D
L1F5AE4: db $8D
L1F5AE5: db $0A
L1F5AE6: db $8D
L1F5AE7: db $05
L1F5AE8: db $8D
L1F5AE9: db $8D
L1F5AEA: db $0A
L1F5AEB: db $8D
L1F5AEC: db $05
L1F5AED: db $8D
L1F5AEE: db $8D
L1F5AEF: db $0A
L1F5AF0: db $F5
L1F5AF1: db $3C
L1F5AF2: db $8B
L1F5AF3: db $14
L1F5AF4: db $F5
L1F5AF5: db $14
L1F5AF6: db $8B
L1F5AF7: db $05
L1F5AF8: db $8B
L1F5AF9: db $8B
L1F5AFA: db $0A
L1F5AFB: db $8B
L1F5AFC: db $05
L1F5AFD: db $8B
L1F5AFE: db $8B
L1F5AFF: db $0A
L1F5B00: db $8B
L1F5B01: db $05
L1F5B02: db $8B
L1F5B03: db $8B
L1F5B04: db $0A
L1F5B05: db $ED
L1F5B06: db $F5
L1F5B07: db $3C
L1F5B08: db $8D
L1F5B09: db $14
L1F5B0A: db $F5
L1F5B0B: db $14
L1F5B0C: db $8D
L1F5B0D: db $05
L1F5B0E: db $8D
L1F5B0F: db $8D
L1F5B10: db $0A
L1F5B11: db $8D
L1F5B12: db $05
L1F5B13: db $8D
L1F5B14: db $F5
L1F5B15: db $3C
L1F5B16: db $96
L1F5B17: db $0D
L1F5B18: db $86
L1F5B19: db $0E
L1F5B1A: db $86
L1F5B1B: db $0D
L1F5B1C: db $ED
L1F5B1D: db $F5
L1F5B1E: db $3C
L1F5B1F: db $8D
L1F5B20: db $14
L1F5B21: db $81
L1F5B22: db $0A
L1F5B23: db $8D
L1F5B24: db $8D
L1F5B25: db $8F
L1F5B26: db $8F
L1F5B27: db $14
L1F5B28: db $8D
L1F5B29: db $0A
L1F5B2A: db $F5
L1F5B2B: db $19
L1F5B2C: db $ED
SndData_04_Ch4: db $E9
L1F5B2E: db $88
L1F5B2F: db $EC
L1F5B30: db $50
L1F5B31: db $5B
L1F5B32: db $EC
L1F5B33: db $B4
L1F5B34: db $5B
L1F5B35: db $EC
L1F5B36: db $ED
L1F5B37: db $5B
L1F5B38: db $EC
L1F5B39: db $58
L1F5B3A: db $5C
L1F5B3B: db $EC
L1F5B3C: db $74
L1F5B3D: db $5C
L1F5B3E: db $EC
L1F5B3F: db $58
L1F5B40: db $5C
L1F5B41: db $EC
L1F5B42: db $A3
L1F5B43: db $5C
L1F5B44: db $EC
L1F5B45: db $DE
L1F5B46: db $5C
L1F5B47: db $EC
L1F5B48: db $02
L1F5B49: db $5D
L1F5B4A: db $EC
L1F5B4B: db $1F
L1F5B4C: db $5D
L1F5B4D: db $E5
L1F5B4E: db $2F
L1F5B4F: db $5B
L1F5B50: db $E4
L1F5B51: db $61
L1F5B52: db $36
L1F5B53: db $14
L1F5B54: db $E4
L1F5B55: db $62
L1F5B56: db $24
L1F5B57: db $14
L1F5B58: db $E4
L1F5B59: db $61
L1F5B5A: db $36
L1F5B5B: db $0A
L1F5B5C: db $36
L1F5B5D: db $0A
L1F5B5E: db $E4
L1F5B5F: db $62
L1F5B60: db $24
L1F5B61: db $14
L1F5B62: db $E4
L1F5B63: db $61
L1F5B64: db $36
L1F5B65: db $0A
L1F5B66: db $36
L1F5B67: db $0A
L1F5B68: db $E4
L1F5B69: db $62
L1F5B6A: db $24
L1F5B6B: db $0A
L1F5B6C: db $E4
L1F5B6D: db $61
L1F5B6E: db $36
L1F5B6F: db $14
L1F5B70: db $36
L1F5B71: db $0A
L1F5B72: db $E4
L1F5B73: db $62
L1F5B74: db $24
L1F5B75: db $14
L1F5B76: db $E7
L1F5B77: db $00
L1F5B78: db $03
L1F5B79: db $50
L1F5B7A: db $5B
L1F5B7B: db $E4
L1F5B7C: db $61
L1F5B7D: db $36
L1F5B7E: db $14
L1F5B7F: db $E4
L1F5B80: db $62
L1F5B81: db $24
L1F5B82: db $14
L1F5B83: db $E4
L1F5B84: db $61
L1F5B85: db $36
L1F5B86: db $0A
L1F5B87: db $36
L1F5B88: db $0A
L1F5B89: db $E4
L1F5B8A: db $62
L1F5B8B: db $24
L1F5B8C: db $14
L1F5B8D: db $E4
L1F5B8E: db $61
L1F5B8F: db $36
L1F5B90: db $0A
L1F5B91: db $36
L1F5B92: db $0A
L1F5B93: db $E4
L1F5B94: db $62
L1F5B95: db $24
L1F5B96: db $0A
L1F5B97: db $E4
L1F5B98: db $61
L1F5B99: db $36
L1F5B9A: db $05
L1F5B9B: db $E4
L1F5B9C: db $62
L1F5B9D: db $24
L1F5B9E: db $05
L1F5B9F: db $24
L1F5BA0: db $0A
L1F5BA1: db $24
L1F5BA2: db $0A
L1F5BA3: db $E4
L1F5BA4: db $44
L1F5BA5: db $26
L1F5BA6: db $03
L1F5BA7: db $E4
L1F5BA8: db $34
L1F5BA9: db $26
L1F5BAA: db $04
L1F5BAB: db $E4
L1F5BAC: db $54
L1F5BAD: db $26
L1F5BAE: db $03
L1F5BAF: db $E4
L1F5BB0: db $61
L1F5BB1: db $36
L1F5BB2: db $0A
L1F5BB3: db $ED
L1F5BB4: db $E4
L1F5BB5: db $62
L1F5BB6: db $24
L1F5BB7: db $0A
L1F5BB8: db $24
L1F5BB9: db $14
L1F5BBA: db $E4
L1F5BBB: db $61
L1F5BBC: db $36
L1F5BBD: db $1E
L1F5BBE: db $36
L1F5BBF: db $14
L1F5BC0: db $36
L1F5BC1: db $14
L1F5BC2: db $36
L1F5BC3: db $14
L1F5BC4: db $36
L1F5BC5: db $0A
L1F5BC6: db $E4
L1F5BC7: db $53
L1F5BC8: db $11
L1F5BC9: db $0A
L1F5BCA: db $E4
L1F5BCB: db $61
L1F5BCC: db $36
L1F5BCD: db $0A
L1F5BCE: db $E4
L1F5BCF: db $53
L1F5BD0: db $11
L1F5BD1: db $0A
L1F5BD2: db $E4
L1F5BD3: db $61
L1F5BD4: db $36
L1F5BD5: db $14
L1F5BD6: db $36
L1F5BD7: db $14
L1F5BD8: db $36
L1F5BD9: db $14
L1F5BDA: db $36
L1F5BDB: db $14
L1F5BDC: db $36
L1F5BDD: db $14
L1F5BDE: db $36
L1F5BDF: db $14
L1F5BE0: db $36
L1F5BE1: db $0A
L1F5BE2: db $E4
L1F5BE3: db $62
L1F5BE4: db $24
L1F5BE5: db $0A
L1F5BE6: db $24
L1F5BE7: db $0A
L1F5BE8: db $24
L1F5BE9: db $05
L1F5BEA: db $24
L1F5BEB: db $05
L1F5BEC: db $ED
L1F5BED: db $E4
L1F5BEE: db $61
L1F5BEF: db $36
L1F5BF0: db $14
L1F5BF1: db $E4
L1F5BF2: db $62
L1F5BF3: db $24
L1F5BF4: db $14
L1F5BF5: db $E4
L1F5BF6: db $61
L1F5BF7: db $36
L1F5BF8: db $0A
L1F5BF9: db $36
L1F5BFA: db $0A
L1F5BFB: db $E4
L1F5BFC: db $62
L1F5BFD: db $24
L1F5BFE: db $14
L1F5BFF: db $E4
L1F5C00: db $61
L1F5C01: db $36
L1F5C02: db $14
L1F5C03: db $E4
L1F5C04: db $62
L1F5C05: db $24
L1F5C06: db $14
L1F5C07: db $E4
L1F5C08: db $61
L1F5C09: db $36
L1F5C0A: db $0A
L1F5C0B: db $E4
L1F5C0C: db $62
L1F5C0D: db $24
L1F5C0E: db $0A
L1F5C0F: db $24
L1F5C10: db $0A
L1F5C11: db $E4
L1F5C12: db $44
L1F5C13: db $26
L1F5C14: db $05
L1F5C15: db $E4
L1F5C16: db $54
L1F5C17: db $26
L1F5C18: db $05
L1F5C19: db $E4
L1F5C1A: db $61
L1F5C1B: db $36
L1F5C1C: db $0A
L1F5C1D: db $36
L1F5C1E: db $0A
L1F5C1F: db $E4
L1F5C20: db $62
L1F5C21: db $24
L1F5C22: db $05
L1F5C23: db $24
L1F5C24: db $05
L1F5C25: db $E4
L1F5C26: db $61
L1F5C27: db $36
L1F5C28: db $03
L1F5C29: db $E4
L1F5C2A: db $62
L1F5C2B: db $24
L1F5C2C: db $04
L1F5C2D: db $24
L1F5C2E: db $03
L1F5C2F: db $24
L1F5C30: db $0A
L1F5C31: db $24
L1F5C32: db $0A
L1F5C33: db $E4
L1F5C34: db $61
L1F5C35: db $36
L1F5C36: db $0A
L1F5C37: db $E4
L1F5C38: db $62
L1F5C39: db $24
L1F5C3A: db $14
L1F5C3B: db $E4
L1F5C3C: db $61
L1F5C3D: db $36
L1F5C3E: db $05
L1F5C3F: db $36
L1F5C40: db $05
L1F5C41: db $E4
L1F5C42: db $62
L1F5C43: db $24
L1F5C44: db $0A
L1F5C45: db $E4
L1F5C46: db $61
L1F5C47: db $36
L1F5C48: db $05
L1F5C49: db $36
L1F5C4A: db $05
L1F5C4B: db $E4
L1F5C4C: db $62
L1F5C4D: db $24
L1F5C4E: db $0A
L1F5C4F: db $E4
L1F5C50: db $61
L1F5C51: db $36
L1F5C52: db $14
L1F5C53: db $E4
L1F5C54: db $62
L1F5C55: db $24
L1F5C56: db $0A
L1F5C57: db $ED
L1F5C58: db $E4
L1F5C59: db $61
L1F5C5A: db $36
L1F5C5B: db $14
L1F5C5C: db $E4
L1F5C5D: db $62
L1F5C5E: db $24
L1F5C5F: db $14
L1F5C60: db $E4
L1F5C61: db $61
L1F5C62: db $36
L1F5C63: db $0A
L1F5C64: db $36
L1F5C65: db $0A
L1F5C66: db $E4
L1F5C67: db $62
L1F5C68: db $24
L1F5C69: db $0A
L1F5C6A: db $E4
L1F5C6B: db $61
L1F5C6C: db $36
L1F5C6D: db $0A
L1F5C6E: db $E7
L1F5C6F: db $00
L1F5C70: db $02
L1F5C71: db $58
L1F5C72: db $5C
L1F5C73: db $ED
L1F5C74: db $E4
L1F5C75: db $61
L1F5C76: db $36
L1F5C77: db $0A
L1F5C78: db $36
L1F5C79: db $14
L1F5C7A: db $36
L1F5C7B: db $05
L1F5C7C: db $36
L1F5C7D: db $05
L1F5C7E: db $E4
L1F5C7F: db $62
L1F5C80: db $24
L1F5C81: db $14
L1F5C82: db $E4
L1F5C83: db $61
L1F5C84: db $36
L1F5C85: db $0A
L1F5C86: db $36
L1F5C87: db $14
L1F5C88: db $E4
L1F5C89: db $61
L1F5C8A: db $36
L1F5C8B: db $0A
L1F5C8C: db $36
L1F5C8D: db $0A
L1F5C8E: db $E4
L1F5C8F: db $62
L1F5C90: db $24
L1F5C91: db $0A
L1F5C92: db $E4
L1F5C93: db $61
L1F5C94: db $36
L1F5C95: db $0A
L1F5C96: db $E4
L1F5C97: db $62
L1F5C98: db $24
L1F5C99: db $0A
L1F5C9A: db $E4
L1F5C9B: db $44
L1F5C9C: db $26
L1F5C9D: db $0A
L1F5C9E: db $E4
L1F5C9F: db $54
L1F5CA0: db $26
L1F5CA1: db $0A
L1F5CA2: db $ED
L1F5CA3: db $E4
L1F5CA4: db $61
L1F5CA5: db $36
L1F5CA6: db $0A
L1F5CA7: db $36
L1F5CA8: db $05
L1F5CA9: db $36
L1F5CAA: db $0F
L1F5CAB: db $36
L1F5CAC: db $05
L1F5CAD: db $36
L1F5CAE: db $05
L1F5CAF: db $E4
L1F5CB0: db $62
L1F5CB1: db $24
L1F5CB2: db $0A
L1F5CB3: db $E4
L1F5CB4: db $61
L1F5CB5: db $36
L1F5CB6: db $05
L1F5CB7: db $36
L1F5CB8: db $05
L1F5CB9: db $E4
L1F5CBA: db $62
L1F5CBB: db $24
L1F5CBC: db $05
L1F5CBD: db $24
L1F5CBE: db $05
L1F5CBF: db $E4
L1F5CC0: db $61
L1F5CC1: db $36
L1F5CC2: db $14
L1F5CC3: db $E4
L1F5CC4: db $61
L1F5CC5: db $36
L1F5CC6: db $0A
L1F5CC7: db $36
L1F5CC8: db $0A
L1F5CC9: db $E4
L1F5CCA: db $62
L1F5CCB: db $24
L1F5CCC: db $0A
L1F5CCD: db $E4
L1F5CCE: db $61
L1F5CCF: db $36
L1F5CD0: db $0A
L1F5CD1: db $E4
L1F5CD2: db $62
L1F5CD3: db $24
L1F5CD4: db $0A
L1F5CD5: db $24
L1F5CD6: db $03
L1F5CD7: db $24
L1F5CD8: db $04
L1F5CD9: db $24
L1F5CDA: db $03
L1F5CDB: db $24
L1F5CDC: db $0A
L1F5CDD: db $ED
L1F5CDE: db $E4
L1F5CDF: db $61
L1F5CE0: db $36
L1F5CE1: db $0A
L1F5CE2: db $36
L1F5CE3: db $05
L1F5CE4: db $36
L1F5CE5: db $05
L1F5CE6: db $E4
L1F5CE7: db $62
L1F5CE8: db $24
L1F5CE9: db $0F
L1F5CEA: db $E4
L1F5CEB: db $61
L1F5CEC: db $36
L1F5CED: db $05
L1F5CEE: db $36
L1F5CEF: db $0A
L1F5CF0: db $36
L1F5CF1: db $05
L1F5CF2: db $36
L1F5CF3: db $05
L1F5CF4: db $E4
L1F5CF5: db $62
L1F5CF6: db $24
L1F5CF7: db $0F
L1F5CF8: db $E4
L1F5CF9: db $61
L1F5CFA: db $36
L1F5CFB: db $05
L1F5CFC: db $E7
L1F5CFD: db $00
L1F5CFE: db $03
L1F5CFF: db $DE
L1F5D00: db $5C
L1F5D01: db $ED
L1F5D02: db $E4
L1F5D03: db $61
L1F5D04: db $36
L1F5D05: db $0A
L1F5D06: db $36
L1F5D07: db $05
L1F5D08: db $36
L1F5D09: db $05
L1F5D0A: db $E4
L1F5D0B: db $62
L1F5D0C: db $24
L1F5D0D: db $0A
L1F5D0E: db $E4
L1F5D0F: db $61
L1F5D10: db $36
L1F5D11: db $05
L1F5D12: db $E4
L1F5D13: db $62
L1F5D14: db $24
L1F5D15: db $05
L1F5D16: db $24
L1F5D17: db $0D
L1F5D18: db $E4
L1F5D19: db $61
L1F5D1A: db $36
L1F5D1B: db $0E
L1F5D1C: db $36
L1F5D1D: db $0D
L1F5D1E: db $ED
L1F5D1F: db $E4
L1F5D20: db $61
L1F5D21: db $36
L1F5D22: db $0A
L1F5D23: db $36
L1F5D24: db $05
L1F5D25: db $36
L1F5D26: db $05
L1F5D27: db $E4
L1F5D28: db $62
L1F5D29: db $24
L1F5D2A: db $0F
L1F5D2B: db $E4
L1F5D2C: db $61
L1F5D2D: db $36
L1F5D2E: db $05
L1F5D2F: db $36
L1F5D30: db $0A
L1F5D31: db $36
L1F5D32: db $05
L1F5D33: db $36
L1F5D34: db $05
L1F5D35: db $E4
L1F5D36: db $62
L1F5D37: db $24
L1F5D38: db $0F
L1F5D39: db $E4
L1F5D3A: db $61
L1F5D3B: db $36
L1F5D3C: db $05
L1F5D3D: db $E7
L1F5D3E: db $00
L1F5D3F: db $02
L1F5D40: db $1F
L1F5D41: db $5D
L1F5D42: db $E4
L1F5D43: db $61
L1F5D44: db $36
L1F5D45: db $0A
L1F5D46: db $36
L1F5D47: db $05
L1F5D48: db $36
L1F5D49: db $05
L1F5D4A: db $E4
L1F5D4B: db $62
L1F5D4C: db $24
L1F5D4D: db $0A
L1F5D4E: db $E4
L1F5D4F: db $61
L1F5D50: db $36
L1F5D51: db $05
L1F5D52: db $36
L1F5D53: db $05
L1F5D54: db $36
L1F5D55: db $0A
L1F5D56: db $E4
L1F5D57: db $62
L1F5D58: db $24
L1F5D59: db $0A
L1F5D5A: db $E4
L1F5D5B: db $61
L1F5D5C: db $36
L1F5D5D: db $0A
L1F5D5E: db $36
L1F5D5F: db $14
L1F5D60: db $E4
L1F5D61: db $62
L1F5D62: db $24
L1F5D63: db $0A
L1F5D64: db $E4
L1F5D65: db $34
L1F5D66: db $26
L1F5D67: db $0A
L1F5D68: db $E4
L1F5D69: db $44
L1F5D6A: db $26
L1F5D6B: db $0A
L1F5D6C: db $E4
L1F5D6D: db $54
L1F5D6E: db $26
L1F5D6F: db $0A
L1F5D70: db $E4
L1F5D71: db $61
L1F5D72: db $36
L1F5D73: db $14
L1F5D74: db $E4
L1F5D75: db $62
L1F5D76: db $24
L1F5D77: db $0A
L1F5D78: db $ED
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
SndData_1F_Ch1: db $E4
L1F5D93: db $77
L1F5D94: db $E9
L1F5D95: db $11
L1F5D96: db $EE
L1F5D97: db $C0
L1F5D98: db $EC
L1F5D99: db $9E
L1F5D9A: db $5D
L1F5D9B: db $E5
L1F5D9C: db $92
L1F5D9D: db $5D
L1F5D9E: db $A2
L1F5D9F: db $0C
L1F5DA0: db $A2
L1F5DA1: db $94
L1F5DA2: db $03
L1F5DA3: db $80
L1F5DA4: db $94
L1F5DA5: db $06
L1F5DA6: db $94
L1F5DA7: db $03
L1F5DA8: db $80
L1F5DA9: db $94
L1F5DAA: db $06
L1F5DAB: db $A5
L1F5DAC: db $18
L1F5DAD: db $94
L1F5DAE: db $06
L1F5DAF: db $80
L1F5DB0: db $94
L1F5DB1: db $0C
L1F5DB2: db $A2
L1F5DB3: db $0C
L1F5DB4: db $A2
L1F5DB5: db $94
L1F5DB6: db $03
L1F5DB7: db $80
L1F5DB8: db $94
L1F5DB9: db $06
L1F5DBA: db $94
L1F5DBB: db $03
L1F5DBC: db $80
L1F5DBD: db $94
L1F5DBE: db $06
L1F5DBF: db $A6
L1F5DC0: db $18
L1F5DC1: db $94
L1F5DC2: db $06
L1F5DC3: db $80
L1F5DC4: db $94
L1F5DC5: db $0C
L1F5DC6: db $A2
L1F5DC7: db $0C
L1F5DC8: db $A2
L1F5DC9: db $94
L1F5DCA: db $03
L1F5DCB: db $80
L1F5DCC: db $94
L1F5DCD: db $06
L1F5DCE: db $94
L1F5DCF: db $03
L1F5DD0: db $80
L1F5DD1: db $94
L1F5DD2: db $06
L1F5DD3: db $A8
L1F5DD4: db $18
L1F5DD5: db $94
L1F5DD6: db $06
L1F5DD7: db $80
L1F5DD8: db $94
L1F5DD9: db $0C
L1F5DDA: db $A2
L1F5DDB: db $0C
L1F5DDC: db $A2
L1F5DDD: db $94
L1F5DDE: db $03
L1F5DDF: db $80
L1F5DE0: db $09
L1F5DE1: db $A9
L1F5DE2: db $18
L1F5DE3: db $94
L1F5DE4: db $06
L1F5DE5: db $80
L1F5DE6: db $AA
L1F5DE7: db $18
L1F5DE8: db $E7
L1F5DE9: db $00
L1F5DEA: db $02
L1F5DEB: db $9E
L1F5DEC: db $5D
L1F5DED: db $A0
L1F5DEE: db $0C
L1F5DEF: db $9F
L1F5DF0: db $9E
L1F5DF1: db $9F
L1F5DF2: db $9E
L1F5DF3: db $9D
L1F5DF4: db $9C
L1F5DF5: db $18
L1F5DF6: db $ED
SndData_1F_Ch2: db $E4
L1F5DF8: db $77
L1F5DF9: db $E9
L1F5DFA: db $22
L1F5DFB: db $EE
L1F5DFC: db $40
L1F5DFD: db $EC
L1F5DFE: db $9E
L1F5DFF: db $5D
L1F5E00: db $E5
L1F5E01: db $F7
L1F5E02: db $5D
SndData_1F_Ch3: db $E4
L1F5E04: db $40
L1F5E05: db $E9
L1F5E06: db $44
L1F5E07: db $F3
L1F5E08: db $02
L1F5E09: db $F5
L1F5E0A: db $5A
L1F5E0B: db $88
L1F5E0C: db $0C
L1F5E0D: db $88
L1F5E0E: db $18
L1F5E0F: db $88
L1F5E10: db $0C
L1F5E11: db $8B
L1F5E12: db $24
L1F5E13: db $88
L1F5E14: db $0C
L1F5E15: db $88
L1F5E16: db $0C
L1F5E17: db $88
L1F5E18: db $18
L1F5E19: db $88
L1F5E1A: db $0C
L1F5E1B: db $8C
L1F5E1C: db $24
L1F5E1D: db $88
L1F5E1E: db $0C
L1F5E1F: db $88
L1F5E20: db $0C
L1F5E21: db $88
L1F5E22: db $18
L1F5E23: db $88
L1F5E24: db $0C
L1F5E25: db $8E
L1F5E26: db $24
L1F5E27: db $88
L1F5E28: db $0C
L1F5E29: db $88
L1F5E2A: db $0C
L1F5E2B: db $88
L1F5E2C: db $88
L1F5E2D: db $8F
L1F5E2E: db $18
L1F5E2F: db $88
L1F5E30: db $0C
L1F5E31: db $90
L1F5E32: db $18
L1F5E33: db $E7
L1F5E34: db $00
L1F5E35: db $02
L1F5E36: db $03
L1F5E37: db $5E
L1F5E38: db $8F
L1F5E39: db $0C
L1F5E3A: db $8E
L1F5E3B: db $8D
L1F5E3C: db $8E
L1F5E3D: db $8D
L1F5E3E: db $8C
L1F5E3F: db $24
L1F5E40: db $E5
L1F5E41: db $03
L1F5E42: db $5E
SndData_1F_Ch4: db $E9
L1F5E44: db $88
L1F5E45: db $EC
L1F5E46: db $6C
L1F5E47: db $5E
L1F5E48: db $EC
L1F5E49: db $6C
L1F5E4A: db $5E
L1F5E4B: db $E4
L1F5E4C: db $54
L1F5E4D: db $26
L1F5E4E: db $0C
L1F5E4F: db $E4
L1F5E50: db $61
L1F5E51: db $36
L1F5E52: db $06
L1F5E53: db $E4
L1F5E54: db $62
L1F5E55: db $24
L1F5E56: db $06
L1F5E57: db $24
L1F5E58: db $0C
L1F5E59: db $E4
L1F5E5A: db $54
L1F5E5B: db $26
L1F5E5C: db $0C
L1F5E5D: db $E4
L1F5E5E: db $44
L1F5E5F: db $26
L1F5E60: db $0C
L1F5E61: db $E4
L1F5E62: db $54
L1F5E63: db $26
L1F5E64: db $0C
L1F5E65: db $E4
L1F5E66: db $61
L1F5E67: db $36
L1F5E68: db $18
L1F5E69: db $E5
L1F5E6A: db $43
L1F5E6B: db $5E
L1F5E6C: db $E4
L1F5E6D: db $61
L1F5E6E: db $36
L1F5E6F: db $0C
L1F5E70: db $36
L1F5E71: db $18
L1F5E72: db $36
L1F5E73: db $06
L1F5E74: db $36
L1F5E75: db $06
L1F5E76: db $E4
L1F5E77: db $62
L1F5E78: db $24
L1F5E79: db $24
L1F5E7A: db $E4
L1F5E7B: db $61
L1F5E7C: db $36
L1F5E7D: db $0C
L1F5E7E: db $E7
L1F5E7F: db $00
L1F5E80: db $03
L1F5E81: db $6C
L1F5E82: db $5E
L1F5E83: db $E4
L1F5E84: db $62
L1F5E85: db $24
L1F5E86: db $0C
L1F5E87: db $E4
L1F5E88: db $61
L1F5E89: db $36
L1F5E8A: db $0C
L1F5E8B: db $36
L1F5E8C: db $0C
L1F5E8D: db $E4
L1F5E8E: db $62
L1F5E8F: db $24
L1F5E90: db $0C
L1F5E91: db $E4
L1F5E92: db $61
L1F5E93: db $36
L1F5E94: db $0C
L1F5E95: db $36
L1F5E96: db $0C
L1F5E97: db $E4
L1F5E98: db $62
L1F5E99: db $24
L1F5E9A: db $0C
L1F5E9B: db $E4
L1F5E9C: db $61
L1F5E9D: db $36
L1F5E9E: db $0C
L1F5E9F: db $ED
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
SndData_1E_Ch1: db $E4
L1F5EBA: db $71
L1F5EBB: db $E9
L1F5EBC: db $11
L1F5EBD: db $EE
L1F5EBE: db $80
L1F5EBF: db $80
L1F5EC0: db $38
L1F5EC1: db $80
L1F5EC2: db $07
L1F5EC3: db $A4
L1F5EC4: db $A9
L1F5EC5: db $0E
L1F5EC6: db $A7
L1F5EC7: db $07
L1F5EC8: db $A9
L1F5EC9: db $0E
L1F5ECA: db $A9
L1F5ECB: db $A4
L1F5ECC: db $07
L1F5ECD: db $A9
L1F5ECE: db $0E
L1F5ECF: db $A7
L1F5ED0: db $07
L1F5ED1: db $A9
L1F5ED2: db $15
L1F5ED3: db $E7
L1F5ED4: db $00
L1F5ED5: db $03
L1F5ED6: db $C1
L1F5ED7: db $5E
L1F5ED8: db $E4
L1F5ED9: db $77
L1F5EDA: db $EE
L1F5EDB: db $C0
L1F5EDC: db $80
L1F5EDD: db $07
L1F5EDE: db $91
L1F5EDF: db $80
L1F5EE0: db $0E
L1F5EE1: db $91
L1F5EE2: db $07
L1F5EE3: db $91
L1F5EE4: db $80
L1F5EE5: db $8E
L1F5EE6: db $15
L1F5EE7: db $8E
L1F5EE8: db $0E
L1F5EE9: db $91
L1F5EEA: db $07
L1F5EEB: db $91
L1F5EEC: db $80
L1F5EED: db $E4
L1F5EEE: db $78
L1F5EEF: db $A2
L1F5EF0: db $15
L1F5EF1: db $A4
L1F5EF2: db $38
L1F5EF3: db $FA
L1F5EF4: db $07
L1F5EF5: db $80
L1F5EF6: db $A7
L1F5EF7: db $0E
L1F5EF8: db $A4
L1F5EF9: db $03
L1F5EFA: db $80
L1F5EFB: db $04
L1F5EFC: db $A7
L1F5EFD: db $15
L1F5EFE: db $A9
L1F5EFF: db $23
L1F5F00: db $80
L1F5F01: db $07
L1F5F02: db $A9
L1F5F03: db $1C
L1F5F04: db $B0
L1F5F05: db $15
L1F5F06: db $AE
L1F5F07: db $07
L1F5F08: db $FA
L1F5F09: db $70
L1F5F0A: db $80
L1F5F0B: db $07
L1F5F0C: db $B0
L1F5F0D: db $80
L1F5F0E: db $0E
L1F5F0F: db $AE
L1F5F10: db $B0
L1F5F11: db $07
L1F5F12: db $B3
L1F5F13: db $54
L1F5F14: db $FA
L1F5F15: db $03
L1F5F16: db $80
L1F5F17: db $04
L1F5F18: db $B5
L1F5F19: db $07
L1F5F1A: db $B0
L1F5F1B: db $03
L1F5F1C: db $80
L1F5F1D: db $04
L1F5F1E: db $B5
L1F5F1F: db $0A
L1F5F20: db $80
L1F5F21: db $04
L1F5F22: db $B3
L1F5F23: db $0E
L1F5F24: db $80
L1F5F25: db $07
L1F5F26: db $B5
L1F5F27: db $1C
L1F5F28: db $80
L1F5F29: db $07
L1F5F2A: db $E3
SndData_1E_Ch2: db $E4
L1F5F2C: db $68
L1F5F2D: db $E9
L1F5F2E: db $22
L1F5F2F: db $EE
L1F5F30: db $40
L1F5F31: db $80
L1F5F32: db $1C
L1F5F33: db $88
L1F5F34: db $0E
L1F5F35: db $8A
L1F5F36: db $07
L1F5F37: db $8A
L1F5F38: db $15
L1F5F39: db $85
L1F5F3A: db $54
L1F5F3B: db $85
L1F5F3C: db $03
L1F5F3D: db $80
L1F5F3E: db $04
L1F5F3F: db $88
L1F5F40: db $07
L1F5F41: db $FA
L1F5F42: db $38
L1F5F43: db $80
L1F5F44: db $0E
L1F5F45: db $85
L1F5F46: db $88
L1F5F47: db $85
L1F5F48: db $03
L1F5F49: db $80
L1F5F4A: db $04
L1F5F4B: db $88
L1F5F4C: db $07
L1F5F4D: db $FA
L1F5F4E: db $0E
L1F5F4F: db $8A
L1F5F50: db $38
L1F5F51: db $8A
L1F5F52: db $0E
L1F5F53: db $88
L1F5F54: db $8A
L1F5F55: db $80
L1F5F56: db $07
L1F5F57: db $8C
L1F5F58: db $80
L1F5F59: db $0E
L1F5F5A: db $8A
L1F5F5B: db $07
L1F5F5C: db $8C
L1F5F5D: db $80
L1F5F5E: db $8A
L1F5F5F: db $15
L1F5F60: db $87
L1F5F61: db $0E
L1F5F62: db $8A
L1F5F63: db $07
L1F5F64: db $8C
L1F5F65: db $80
L1F5F66: db $8C
L1F5F67: db $E6
L1F5F68: db $F4
L1F5F69: db $FA
L1F5F6A: db $0E
L1F5F6B: db $85
L1F5F6C: db $38
L1F5F6D: db $FA
L1F5F6E: db $0E
L1F5F6F: db $85
L1F5F70: db $07
L1F5F71: db $85
L1F5F72: db $03
L1F5F73: db $80
L1F5F74: db $04
L1F5F75: db $85
L1F5F76: db $03
L1F5F77: db $80
L1F5F78: db $04
L1F5F79: db $88
L1F5F7A: db $07
L1F5F7B: db $FA
L1F5F7C: db $38
L1F5F7D: db $88
L1F5F7E: db $07
L1F5F7F: db $88
L1F5F80: db $03
L1F5F81: db $80
L1F5F82: db $04
L1F5F83: db $83
L1F5F84: db $03
L1F5F85: db $80
L1F5F86: db $04
L1F5F87: db $83
L1F5F88: db $03
L1F5F89: db $80
L1F5F8A: db $04
L1F5F8B: db $88
L1F5F8C: db $07
L1F5F8D: db $88
L1F5F8E: db $03
L1F5F8F: db $80
L1F5F90: db $04
L1F5F91: db $88
L1F5F92: db $03
L1F5F93: db $80
L1F5F94: db $04
L1F5F95: db $8A
L1F5F96: db $07
L1F5F97: db $FA
L1F5F98: db $38
L1F5F99: db $91
L1F5F9A: db $07
L1F5F9B: db $85
L1F5F9C: db $03
L1F5F9D: db $80
L1F5F9E: db $04
L1F5F9F: db $91
L1F5FA0: db $03
L1F5FA1: db $80
L1F5FA2: db $04
L1F5FA3: db $8A
L1F5FA4: db $0E
L1F5FA5: db $8A
L1F5FA6: db $03
L1F5FA7: db $80
L1F5FA8: db $04
L1F5FA9: db $88
L1F5FAA: db $07
L1F5FAB: db $8A
L1F5FAC: db $91
L1F5FAD: db $03
L1F5FAE: db $80
L1F5FAF: db $04
L1F5FB0: db $93
L1F5FB1: db $0A
L1F5FB2: db $80
L1F5FB3: db $04
L1F5FB4: db $8C
L1F5FB5: db $07
L1F5FB6: db $87
L1F5FB7: db $87
L1F5FB8: db $03
L1F5FB9: db $80
L1F5FBA: db $04
L1F5FBB: db $88
L1F5FBC: db $07
L1F5FBD: db $8A
L1F5FBE: db $54
L1F5FBF: db $80
L1F5FC0: db $07
L1F5FC1: db $93
L1F5FC2: db $8C
L1F5FC3: db $03
L1F5FC4: db $80
L1F5FC5: db $04
L1F5FC6: db $93
L1F5FC7: db $0E
L1F5FC8: db $91
L1F5FC9: db $0E
L1F5FCA: db $80
L1F5FCB: db $07
L1F5FCC: db $91
L1F5FCD: db $1C
L1F5FCE: db $80
L1F5FCF: db $07
L1F5FD0: db $E6
L1F5FD1: db $0C
L1F5FD2: db $E3
SndData_1E_Ch3: db $E4
L1F5FD4: db $40
L1F5FD5: db $E9
L1F5FD6: db $44
L1F5FD7: db $F3
L1F5FD8: db $03
L1F5FD9: db $F5
L1F5FDA: db $1E
L1F5FDB: db $80
L1F5FDC: db $1C
L1F5FDD: db $88
L1F5FDE: db $07
L1F5FDF: db $81
L1F5FE0: db $96
L1F5FE1: db $F5
L1F5FE2: db $3C
L1F5FE3: db $8A
L1F5FE4: db $15
L1F5FE5: db $F5
L1F5FE6: db $1E
L1F5FE7: db $85
L1F5FE8: db $07
L1F5FE9: db $91
L1F5FEA: db $98
L1F5FEB: db $91
L1F5FEC: db $85
L1F5FED: db $8F
L1F5FEE: db $0E
L1F5FEF: db $8C
L1F5FF0: db $07
L1F5FF1: db $85
L1F5FF2: db $91
L1F5FF3: db $8C
L1F5FF4: db $84
L1F5FF5: db $85
L1F5FF6: db $F5
L1F5FF7: db $3C
L1F5FF8: db $88
L1F5FF9: db $15
L1F5FFA: db $F5
L1F5FFB: db $1E
L1F5FFC: db $85
L1F5FFD: db $07
L1F5FFE: db $88
L1F5FFF: db $94
L1F6000: db $8F
L1F6001: db $88
L1F6002: db $8C
L1F6003: db $0E
L1F6004: db $8F
L1F6005: db $07
L1F6006: db $88
L1F6007: db $94
L1F6008: db $88
L1F6009: db $0E
L1F600A: db $83
L1F600B: db $07
L1F600C: db $F5
L1F600D: db $3C
L1F600E: db $88
L1F600F: db $15
L1F6010: db $F5
L1F6011: db $1E
L1F6012: db $85
L1F6013: db $07
L1F6014: db $96
L1F6015: db $85
L1F6016: db $8A
L1F6017: db $91
L1F6018: db $8A
L1F6019: db $0E
L1F601A: db $96
L1F601B: db $07
L1F601C: db $91
L1F601D: db $0E
L1F601E: db $88
L1F601F: db $07
L1F6020: db $8F
L1F6021: db $85
L1F6022: db $0E
L1F6023: db $80
L1F6024: db $07
L1F6025: db $8F
L1F6026: db $15
L1F6027: db $8E
L1F6028: db $07
L1F6029: db $8F
L1F602A: db $0E
L1F602B: db $8E
L1F602C: db $15
L1F602D: db $8A
L1F602E: db $0E
L1F602F: db $8E
L1F6030: db $07
L1F6031: db $8F
L1F6032: db $0E
L1F6033: db $8C
L1F6034: db $0E
L1F6035: db $85
L1F6036: db $07
L1F6037: db $83
L1F6038: db $85
L1F6039: db $0E
L1F603A: db $91
L1F603B: db $07
L1F603C: db $8C
L1F603D: db $83
L1F603E: db $85
L1F603F: db $8C
L1F6040: db $83
L1F6041: db $85
L1F6042: db $8F
L1F6043: db $85
L1F6044: db $88
L1F6045: db $0E
L1F6046: db $94
L1F6047: db $07
L1F6048: db $93
L1F6049: db $85
L1F604A: db $88
L1F604B: db $88
L1F604C: db $8A
L1F604D: db $8F
L1F604E: db $0E
L1F604F: db $94
L1F6050: db $07
L1F6051: db $8D
L1F6052: db $93
L1F6053: db $88
L1F6054: db $85
L1F6055: db $88
L1F6056: db $8A
L1F6057: db $0E
L1F6058: db $96
L1F6059: db $07
L1F605A: db $94
L1F605B: db $91
L1F605C: db $8F
L1F605D: db $8A
L1F605E: db $85
L1F605F: db $8A
L1F6060: db $0E
L1F6061: db $91
L1F6062: db $07
L1F6063: db $8A
L1F6064: db $96
L1F6065: db $8A
L1F6066: db $94
L1F6067: db $96
L1F6068: db $9B
L1F6069: db $85
L1F606A: db $93
L1F606B: db $0E
L1F606C: db $8C
L1F606D: db $07
L1F606E: db $86
L1F606F: db $85
L1F6070: db $87
L1F6071: db $F5
L1F6072: db $00
L1F6073: db $8F
L1F6074: db $54
L1F6075: db $FA
L1F6076: db $07
L1F6077: db $F5
L1F6078: db $1E
L1F6079: db $93
L1F607A: db $07
L1F607B: db $8C
L1F607C: db $93
L1F607D: db $0E
L1F607E: db $85
L1F607F: db $15
L1F6080: db $85
L1F6081: db $23
L1F6082: db $E3
SndData_1E_Ch4: db $E9
L1F6084: db $88
L1F6085: db $EC
L1F6086: db $8C
L1F6087: db $60
L1F6088: db $EC
L1F6089: db $05
L1F608A: db $61
L1F608B: db $E3
L1F608C: db $E4
L1F608D: db $62
L1F608E: db $24
L1F608F: db $07
L1F6090: db $24
L1F6091: db $07
L1F6092: db $E4
L1F6093: db $61
L1F6094: db $36
L1F6095: db $07
L1F6096: db $E4
L1F6097: db $62
L1F6098: db $24
L1F6099: db $07
L1F609A: db $24
L1F609B: db $0E
L1F609C: db $24
L1F609D: db $07
L1F609E: db $E4
L1F609F: db $61
L1F60A0: db $36
L1F60A1: db $15
L1F60A2: db $36
L1F60A3: db $0E
L1F60A4: db $E4
L1F60A5: db $62
L1F60A6: db $24
L1F60A7: db $1C
L1F60A8: db $E4
L1F60A9: db $61
L1F60AA: db $36
L1F60AB: db $1C
L1F60AC: db $E4
L1F60AD: db $62
L1F60AE: db $24
L1F60AF: db $15
L1F60B0: db $E4
L1F60B1: db $61
L1F60B2: db $36
L1F60B3: db $15
L1F60B4: db $36
L1F60B5: db $0E
L1F60B6: db $E4
L1F60B7: db $62
L1F60B8: db $24
L1F60B9: db $1C
L1F60BA: db $E4
L1F60BB: db $61
L1F60BC: db $36
L1F60BD: db $0E
L1F60BE: db $36
L1F60BF: db $0E
L1F60C0: db $E4
L1F60C1: db $62
L1F60C2: db $24
L1F60C3: db $0E
L1F60C4: db $E4
L1F60C5: db $61
L1F60C6: db $36
L1F60C7: db $07
L1F60C8: db $E4
L1F60C9: db $62
L1F60CA: db $24
L1F60CB: db $15
L1F60CC: db $E4
L1F60CD: db $61
L1F60CE: db $36
L1F60CF: db $0E
L1F60D0: db $E4
L1F60D1: db $62
L1F60D2: db $24
L1F60D3: db $1C
L1F60D4: db $E4
L1F60D5: db $61
L1F60D6: db $36
L1F60D7: db $0E
L1F60D8: db $36
L1F60D9: db $0E
L1F60DA: db $E4
L1F60DB: db $62
L1F60DC: db $24
L1F60DD: db $0E
L1F60DE: db $E4
L1F60DF: db $61
L1F60E0: db $36
L1F60E1: db $15
L1F60E2: db $E4
L1F60E3: db $62
L1F60E4: db $24
L1F60E5: db $15
L1F60E6: db $E4
L1F60E7: db $34
L1F60E8: db $26
L1F60E9: db $07
L1F60EA: db $E4
L1F60EB: db $44
L1F60EC: db $26
L1F60ED: db $07
L1F60EE: db $E4
L1F60EF: db $54
L1F60F0: db $26
L1F60F1: db $07
L1F60F2: db $E4
L1F60F3: db $61
L1F60F4: db $36
L1F60F5: db $0E
L1F60F6: db $36
L1F60F7: db $07
L1F60F8: db $E4
L1F60F9: db $62
L1F60FA: db $24
L1F60FB: db $0E
L1F60FC: db $E4
L1F60FD: db $61
L1F60FE: db $36
L1F60FF: db $0E
L1F6100: db $E4
L1F6101: db $62
L1F6102: db $24
L1F6103: db $07
L1F6104: db $ED
L1F6105: db $E4
L1F6106: db $61
L1F6107: db $36
L1F6108: db $0E
L1F6109: db $36
L1F610A: db $07
L1F610B: db $E4
L1F610C: db $62
L1F610D: db $24
L1F610E: db $0E
L1F610F: db $E4
L1F6110: db $61
L1F6111: db $36
L1F6112: db $0E
L1F6113: db $E4
L1F6114: db $62
L1F6115: db $24
L1F6116: db $0E
L1F6117: db $E4
L1F6118: db $61
L1F6119: db $36
L1F611A: db $0E
L1F611B: db $E4
L1F611C: db $62
L1F611D: db $24
L1F611E: db $0E
L1F611F: db $E4
L1F6120: db $61
L1F6121: db $36
L1F6122: db $0E
L1F6123: db $E4
L1F6124: db $62
L1F6125: db $24
L1F6126: db $07
L1F6127: db $E7
L1F6128: db $00
L1F6129: db $02
L1F612A: db $05
L1F612B: db $61
L1F612C: db $E4
L1F612D: db $61
L1F612E: db $36
L1F612F: db $0E
L1F6130: db $36
L1F6131: db $07
L1F6132: db $E4
L1F6133: db $62
L1F6134: db $24
L1F6135: db $0E
L1F6136: db $E4
L1F6137: db $61
L1F6138: db $36
L1F6139: db $0E
L1F613A: db $E4
L1F613B: db $62
L1F613C: db $24
L1F613D: db $0E
L1F613E: db $E4
L1F613F: db $61
L1F6140: db $36
L1F6141: db $0E
L1F6142: db $36
L1F6143: db $07
L1F6144: db $E4
L1F6145: db $62
L1F6146: db $24
L1F6147: db $0E
L1F6148: db $E4
L1F6149: db $61
L1F614A: db $36
L1F614B: db $07
L1F614C: db $E4
L1F614D: db $62
L1F614E: db $24
L1F614F: db $07
L1F6150: db $24
L1F6151: db $07
L1F6152: db $E4
L1F6153: db $61
L1F6154: db $36
L1F6155: db $07
L1F6156: db $E4
L1F6157: db $62
L1F6158: db $24
L1F6159: db $15
L1F615A: db $E4
L1F615B: db $44
L1F615C: db $26
L1F615D: db $07
L1F615E: db $10
L1F615F: db $07
L1F6160: db $E4
L1F6161: db $54
L1F6162: db $26
L1F6163: db $07
L1F6164: db $E4
L1F6165: db $62
L1F6166: db $24
L1F6167: db $0E
L1F6168: db $E4
L1F6169: db $54
L1F616A: db $26
L1F616B: db $07
L1F616C: db $E4
L1F616D: db $34
L1F616E: db $26
L1F616F: db $07
L1F6170: db $26
L1F6171: db $07
L1F6172: db $E4
L1F6173: db $44
L1F6174: db $26
L1F6175: db $07
L1F6176: db $10
L1F6177: db $07
L1F6178: db $E4
L1F6179: db $54
L1F617A: db $26
L1F617B: db $07
L1F617C: db $32
L1F617D: db $07
L1F617E: db $E4
L1F617F: db $54
L1F6180: db $26
L1F6181: db $07
L1F6182: db $E4
L1F6183: db $44
L1F6184: db $26
L1F6185: db $03
L1F6186: db $10
L1F6187: db $04
L1F6188: db $E4
L1F6189: db $34
L1F618A: db $26
L1F618B: db $07
L1F618C: db $26
L1F618D: db $07
L1F618E: db $E4
L1F618F: db $62
L1F6190: db $24
L1F6191: db $07
L1F6192: db $E4
L1F6193: db $61
L1F6194: db $36
L1F6195: db $07
L1F6196: db $E4
L1F6197: db $62
L1F6198: db $24
L1F6199: db $07
L1F619A: db $E4
L1F619B: db $61
L1F619C: db $36
L1F619D: db $07
L1F619E: db $E4
L1F619F: db $62
L1F61A0: db $24
L1F61A1: db $07
L1F61A2: db $E4
L1F61A3: db $61
L1F61A4: db $36
L1F61A5: db $07
L1F61A6: db $36
L1F61A7: db $07
L1F61A8: db $E4
L1F61A9: db $62
L1F61AA: db $24
L1F61AB: db $23
L1F61AC: db $ED
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
SndData_19_Ch1: db $E4
L1F61C7: db $77
L1F61C8: db $E9
L1F61C9: db $11
L1F61CA: db $EE
L1F61CB: db $C0
L1F61CC: db $EC
L1F61CD: db $DE
L1F61CE: db $61
L1F61CF: db $EC
L1F61D0: db $FA
L1F61D1: db $61
L1F61D2: db $EC
L1F61D3: db $30
L1F61D4: db $62
L1F61D5: db $EC
L1F61D6: db $66
L1F61D7: db $62
L1F61D8: db $EC
L1F61D9: db $DE
L1F61DA: db $61
L1F61DB: db $E5
L1F61DC: db $CF
L1F61DD: db $61
L1F61DE: db $E4
L1F61DF: db $75
L1F61E0: db $EE
L1F61E1: db $C0
L1F61E2: db $A4
L1F61E3: db $14
L1F61E4: db $A0
L1F61E5: db $0A
L1F61E6: db $9D
L1F61E7: db $A7
L1F61E8: db $9D
L1F61E9: db $A9
L1F61EA: db $9D
L1F61EB: db $A4
L1F61EC: db $14
L1F61ED: db $A0
L1F61EE: db $0A
L1F61EF: db $9D
L1F61F0: db $A2
L1F61F1: db $9B
L1F61F2: db $9F
L1F61F3: db $96
L1F61F4: db $E7
L1F61F5: db $00
L1F61F6: db $02
L1F61F7: db $DE
L1F61F8: db $61
L1F61F9: db $ED
L1F61FA: db $A7
L1F61FB: db $14
L1F61FC: db $A2
L1F61FD: db $02
L1F61FE: db $80
L1F61FF: db $03
L1F6200: db $A2
L1F6201: db $05
L1F6202: db $AB
L1F6203: db $0A
L1F6204: db $A2
L1F6205: db $02
L1F6206: db $80
L1F6207: db $03
L1F6208: db $A2
L1F6209: db $05
L1F620A: db $A7
L1F620B: db $0A
L1F620C: db $A2
L1F620D: db $02
L1F620E: db $80
L1F620F: db $03
L1F6210: db $A2
L1F6211: db $05
L1F6212: db $9B
L1F6213: db $0A
L1F6214: db $A7
L1F6215: db $14
L1F6216: db $A2
L1F6217: db $02
L1F6218: db $80
L1F6219: db $03
L1F621A: db $A2
L1F621B: db $05
L1F621C: db $AB
L1F621D: db $0A
L1F621E: db $A2
L1F621F: db $02
L1F6220: db $80
L1F6221: db $03
L1F6222: db $A2
L1F6223: db $05
L1F6224: db $A7
L1F6225: db $A6
L1F6226: db $A5
L1F6227: db $A4
L1F6228: db $A3
L1F6229: db $A2
L1F622A: db $E7
L1F622B: db $00
L1F622C: db $04
L1F622D: db $FA
L1F622E: db $61
L1F622F: db $ED
L1F6230: db $E4
L1F6231: db $78
L1F6232: db $EE
L1F6233: db $80
L1F6234: db $A2
L1F6235: db $28
L1F6236: db $A4
L1F6237: db $1E
L1F6238: db $A0
L1F6239: db $9B
L1F623A: db $28
L1F623B: db $A2
L1F623C: db $0A
L1F623D: db $A4
L1F623E: db $A5
L1F623F: db $28
L1F6240: db $FA
L1F6241: db $0A
L1F6242: db $9B
L1F6243: db $A7
L1F6244: db $A5
L1F6245: db $A4
L1F6246: db $FA
L1F6247: db $28
L1F6248: db $FA
L1F6249: db $0A
L1F624A: db $A5
L1F624B: db $A7
L1F624C: db $A8
L1F624D: db $28
L1F624E: db $AA
L1F624F: db $1E
L1F6250: db $A8
L1F6251: db $0A
L1F6252: db $A7
L1F6253: db $80
L1F6254: db $A4
L1F6255: db $A0
L1F6256: db $9B
L1F6257: db $3C
L1F6258: db $E4
L1F6259: db $77
L1F625A: db $EE
L1F625B: db $C0
L1F625C: db $9B
L1F625D: db $05
L1F625E: db $80
L1F625F: db $9B
L1F6260: db $0A
L1F6261: db $9A
L1F6262: db $9B
L1F6263: db $9A
L1F6264: db $9B
L1F6265: db $ED
L1F6266: db $E4
L1F6267: db $78
L1F6268: db $EE
L1F6269: db $C0
L1F626A: db $A2
L1F626B: db $14
L1F626C: db $A1
L1F626D: db $0A
L1F626E: db $A2
L1F626F: db $A5
L1F6270: db $14
L1F6271: db $99
L1F6272: db $05
L1F6273: db $80
L1F6274: db $A4
L1F6275: db $0A
L1F6276: db $A7
L1F6277: db $1E
L1F6278: db $9B
L1F6279: db $05
L1F627A: db $80
L1F627B: db $A9
L1F627C: db $0A
L1F627D: db $80
L1F627E: db $AC
L1F627F: db $80
L1F6280: db $A9
L1F6281: db $50
L1F6282: db $A7
L1F6283: db $05
L1F6284: db $A9
L1F6285: db $A7
L1F6286: db $1E
L1F6287: db $A5
L1F6288: db $05
L1F6289: db $A7
L1F628A: db $A5
L1F628B: db $14
L1F628C: db $80
L1F628D: db $0A
L1F628E: db $A4
L1F628F: db $A5
L1F6290: db $A4
L1F6291: db $A0
L1F6292: db $9B
L1F6293: db $80
L1F6294: db $A4
L1F6295: db $1E
L1F6296: db $FA
L1F6297: db $50
L1F6298: db $E4
L1F6299: db $11
L1F629A: db $81
L1F629B: db $50
L1F629C: db $FA
L1F629D: db $3C
L1F629E: db $FA
L1F629F: db $0A
L1F62A0: db $E7
L1F62A1: db $00
L1F62A2: db $02
L1F62A3: db $66
L1F62A4: db $62
L1F62A5: db $ED
SndData_19_Ch2: db $E4
L1F62A7: db $67
L1F62A8: db $E9
L1F62A9: db $22
L1F62AA: db $EE
L1F62AB: db $40
L1F62AC: db $EC
L1F62AD: db $C7
L1F62AE: db $62
L1F62AF: db $EC
L1F62B0: db $DF
L1F62B1: db $62
L1F62B2: db $EC
L1F62B3: db $15
L1F62B4: db $63
L1F62B5: db $EC
L1F62B6: db $C7
L1F62B7: db $62
L1F62B8: db $EC
L1F62B9: db $C7
L1F62BA: db $62
L1F62BB: db $EC
L1F62BC: db $C7
L1F62BD: db $62
L1F62BE: db $EC
L1F62BF: db $C7
L1F62C0: db $62
L1F62C1: db $EC
L1F62C2: db $C7
L1F62C3: db $62
L1F62C4: db $E5
L1F62C5: db $AF
L1F62C6: db $62
L1F62C7: db $9D
L1F62C8: db $14
L1F62C9: db $99
L1F62CA: db $0A
L1F62CB: db $96
L1F62CC: db $A0
L1F62CD: db $96
L1F62CE: db $A2
L1F62CF: db $96
L1F62D0: db $9D
L1F62D1: db $14
L1F62D2: db $99
L1F62D3: db $0A
L1F62D4: db $96
L1F62D5: db $9B
L1F62D6: db $94
L1F62D7: db $98
L1F62D8: db $8F
L1F62D9: db $E7
L1F62DA: db $00
L1F62DB: db $02
L1F62DC: db $C7
L1F62DD: db $62
L1F62DE: db $ED
L1F62DF: db $A0
L1F62E0: db $14
L1F62E1: db $9B
L1F62E2: db $02
L1F62E3: db $80
L1F62E4: db $03
L1F62E5: db $9B
L1F62E6: db $05
L1F62E7: db $A4
L1F62E8: db $0A
L1F62E9: db $9B
L1F62EA: db $02
L1F62EB: db $80
L1F62EC: db $03
L1F62ED: db $9B
L1F62EE: db $05
L1F62EF: db $A0
L1F62F0: db $0A
L1F62F1: db $9B
L1F62F2: db $02
L1F62F3: db $80
L1F62F4: db $03
L1F62F5: db $9B
L1F62F6: db $05
L1F62F7: db $94
L1F62F8: db $0A
L1F62F9: db $A0
L1F62FA: db $14
L1F62FB: db $9B
L1F62FC: db $02
L1F62FD: db $80
L1F62FE: db $03
L1F62FF: db $9B
L1F6300: db $05
L1F6301: db $A4
L1F6302: db $0A
L1F6303: db $9B
L1F6304: db $02
L1F6305: db $80
L1F6306: db $03
L1F6307: db $9B
L1F6308: db $05
L1F6309: db $A0
L1F630A: db $9F
L1F630B: db $9E
L1F630C: db $9D
L1F630D: db $9C
L1F630E: db $9B
L1F630F: db $E7
L1F6310: db $00
L1F6311: db $04
L1F6312: db $DF
L1F6313: db $62
L1F6314: db $ED
L1F6315: db $E4
L1F6316: db $68
L1F6317: db $9D
L1F6318: db $0A
L1F6319: db $FA
L1F631A: db $28
L1F631B: db $9F
L1F631C: db $A0
L1F631D: db $A2
L1F631E: db $1E
L1F631F: db $A3
L1F6320: db $0A
L1F6321: db $FA
L1F6322: db $28
L1F6323: db $9C
L1F6324: db $A0
L1F6325: db $3C
L1F6326: db $A4
L1F6327: db $0A
L1F6328: db $A5
L1F6329: db $1E
L1F632A: db $A3
L1F632B: db $14
L1F632C: db $A1
L1F632D: db $9C
L1F632E: db $0A
L1F632F: db $A4
L1F6330: db $FA
L1F6331: db $50
L1F6332: db $E4
L1F6333: db $67
L1F6334: db $80
L1F6335: db $0A
L1F6336: db $A4
L1F6337: db $05
L1F6338: db $80
L1F6339: db $A4
L1F633A: db $0A
L1F633B: db $A3
L1F633C: db $A4
L1F633D: db $A3
L1F633E: db $A4
L1F633F: db $ED
SndData_19_Ch3: db $E4
L1F6341: db $40
L1F6342: db $E9
L1F6343: db $44
L1F6344: db $F3
L1F6345: db $04
L1F6346: db $F5
L1F6347: db $00
L1F6348: db $EC
L1F6349: db $5D
L1F634A: db $63
L1F634B: db $EC
L1F634C: db $79
L1F634D: db $63
L1F634E: db $EC
L1F634F: db $99
L1F6350: db $63
L1F6351: db $EC
L1F6352: db $E0
L1F6353: db $63
L1F6354: db $EC
L1F6355: db $05
L1F6356: db $64
L1F6357: db $EC
L1F6358: db $E0
L1F6359: db $63
L1F635A: db $E5
L1F635B: db $4B
L1F635C: db $63
L1F635D: db $96
L1F635E: db $0A
L1F635F: db $FA
L1F6360: db $3C
L1F6361: db $80
L1F6362: db $0A
L1F6363: db $99
L1F6364: db $1E
L1F6365: db $80
L1F6366: db $0A
L1F6367: db $91
L1F6368: db $80
L1F6369: db $94
L1F636A: db $80
L1F636B: db $96
L1F636C: db $FA
L1F636D: db $3C
L1F636E: db $80
L1F636F: db $0A
L1F6370: db $99
L1F6371: db $1E
L1F6372: db $80
L1F6373: db $0A
L1F6374: db $91
L1F6375: db $80
L1F6376: db $94
L1F6377: db $80
L1F6378: db $ED
L1F6379: db $F5
L1F637A: db $3C
L1F637B: db $96
L1F637C: db $14
L1F637D: db $F5
L1F637E: db $1E
L1F637F: db $93
L1F6380: db $0A
L1F6381: db $94
L1F6382: db $95
L1F6383: db $96
L1F6384: db $93
L1F6385: db $94
L1F6386: db $F5
L1F6387: db $3C
L1F6388: db $96
L1F6389: db $14
L1F638A: db $F5
L1F638B: db $1E
L1F638C: db $8F
L1F638D: db $0A
L1F638E: db $9B
L1F638F: db $8F
L1F6390: db $96
L1F6391: db $8F
L1F6392: db $94
L1F6393: db $E7
L1F6394: db $00
L1F6395: db $04
L1F6396: db $79
L1F6397: db $63
L1F6398: db $ED
L1F6399: db $F5
L1F639A: db $00
L1F639B: db $99
L1F639C: db $28
L1F639D: db $F5
L1F639E: db $1E
L1F639F: db $94
L1F63A0: db $0A
L1F63A1: db $99
L1F63A2: db $94
L1F63A3: db $99
L1F63A4: db $F5
L1F63A5: db $00
L1F63A6: db $98
L1F63A7: db $3C
L1F63A8: db $F5
L1F63A9: db $1E
L1F63AA: db $9A
L1F63AB: db $0A
L1F63AC: db $9B
L1F63AD: db $F5
L1F63AE: db $00
L1F63AF: db $9C
L1F63B0: db $28
L1F63B1: db $F5
L1F63B2: db $1E
L1F63B3: db $97
L1F63B4: db $0A
L1F63B5: db $9C
L1F63B6: db $97
L1F63B7: db $9C
L1F63B8: db $F5
L1F63B9: db $00
L1F63BA: db $9B
L1F63BB: db $3C
L1F63BC: db $F5
L1F63BD: db $1E
L1F63BE: db $9D
L1F63BF: db $0A
L1F63C0: db $9E
L1F63C1: db $F5
L1F63C2: db $00
L1F63C3: db $9F
L1F63C4: db $28
L1F63C5: db $F5
L1F63C6: db $1E
L1F63C7: db $9A
L1F63C8: db $0A
L1F63C9: db $9F
L1F63CA: db $9A
L1F63CB: db $9F
L1F63CC: db $F5
L1F63CD: db $3C
L1F63CE: db $A0
L1F63CF: db $14
L1F63D0: db $F5
L1F63D1: db $1E
L1F63D2: db $94
L1F63D3: db $0A
L1F63D4: db $E7
L1F63D5: db $00
L1F63D6: db $08
L1F63D7: db $D2
L1F63D8: db $63
L1F63D9: db $8F
L1F63DA: db $94
L1F63DB: db $93
L1F63DC: db $94
L1F63DD: db $93
L1F63DE: db $94
L1F63DF: db $ED
L1F63E0: db $F5
L1F63E1: db $3C
L1F63E2: db $96
L1F63E3: db $14
L1F63E4: db $F5
L1F63E5: db $1E
L1F63E6: db $96
L1F63E7: db $0A
L1F63E8: db $96
L1F63E9: db $96
L1F63EA: db $96
L1F63EB: db $96
L1F63EC: db $96
L1F63ED: db $F5
L1F63EE: db $3C
L1F63EF: db $99
L1F63F0: db $14
L1F63F1: db $F5
L1F63F2: db $1E
L1F63F3: db $99
L1F63F4: db $0A
L1F63F5: db $99
L1F63F6: db $F5
L1F63F7: db $3C
L1F63F8: db $91
L1F63F9: db $14
L1F63FA: db $F5
L1F63FB: db $1E
L1F63FC: db $8F
L1F63FD: db $0A
L1F63FE: db $94
L1F63FF: db $E7
L1F6400: db $00
L1F6401: db $04
L1F6402: db $E0
L1F6403: db $63
L1F6404: db $ED
L1F6405: db $F5
L1F6406: db $3C
L1F6407: db $92
L1F6408: db $14
L1F6409: db $F5
L1F640A: db $19
L1F640B: db $92
L1F640C: db $0A
L1F640D: db $92
L1F640E: db $92
L1F640F: db $92
L1F6410: db $92
L1F6411: db $92
L1F6412: db $92
L1F6413: db $92
L1F6414: db $92
L1F6415: db $92
L1F6416: db $92
L1F6417: db $8D
L1F6418: db $94
L1F6419: db $8D
L1F641A: db $E7
L1F641B: db $00
L1F641C: db $02
L1F641D: db $05
L1F641E: db $64
L1F641F: db $ED
SndData_19_Ch4: db $E9
L1F6421: db $88
L1F6422: db $EC
L1F6423: db $40
L1F6424: db $64
L1F6425: db $EC
L1F6426: db $C7
L1F6427: db $64
L1F6428: db $EC
L1F6429: db $F5
L1F642A: db $64
L1F642B: db $EC
L1F642C: db $20
L1F642D: db $65
L1F642E: db $EC
L1F642F: db $F5
L1F6430: db $64
L1F6431: db $EC
L1F6432: db $42
L1F6433: db $65
L1F6434: db $EC
L1F6435: db $42
L1F6436: db $65
L1F6437: db $EC
L1F6438: db $76
L1F6439: db $65
L1F643A: db $EC
L1F643B: db $F5
L1F643C: db $64
L1F643D: db $E5
L1F643E: db $25
L1F643F: db $64
L1F6440: db $E4
L1F6441: db $61
L1F6442: db $36
L1F6443: db $1E
L1F6444: db $E4
L1F6445: db $62
L1F6446: db $24
L1F6447: db $05
L1F6448: db $24
L1F6449: db $05
L1F644A: db $E4
L1F644B: db $61
L1F644C: db $36
L1F644D: db $05
L1F644E: db $36
L1F644F: db $05
L1F6450: db $E4
L1F6451: db $34
L1F6452: db $26
L1F6453: db $0A
L1F6454: db $E4
L1F6455: db $44
L1F6456: db $26
L1F6457: db $0A
L1F6458: db $E4
L1F6459: db $54
L1F645A: db $26
L1F645B: db $0A
L1F645C: db $E4
L1F645D: db $61
L1F645E: db $36
L1F645F: db $14
L1F6460: db $36
L1F6461: db $0A
L1F6462: db $E4
L1F6463: db $62
L1F6464: db $24
L1F6465: db $0A
L1F6466: db $E4
L1F6467: db $61
L1F6468: db $36
L1F6469: db $0A
L1F646A: db $E4
L1F646B: db $62
L1F646C: db $24
L1F646D: db $0A
L1F646E: db $E4
L1F646F: db $34
L1F6470: db $26
L1F6471: db $03
L1F6472: db $E4
L1F6473: db $44
L1F6474: db $26
L1F6475: db $04
L1F6476: db $E4
L1F6477: db $54
L1F6478: db $26
L1F6479: db $03
L1F647A: db $E4
L1F647B: db $61
L1F647C: db $36
L1F647D: db $0A
L1F647E: db $36
L1F647F: db $14
L1F6480: db $36
L1F6481: db $05
L1F6482: db $36
L1F6483: db $05
L1F6484: db $E4
L1F6485: db $62
L1F6486: db $24
L1F6487: db $05
L1F6488: db $24
L1F6489: db $05
L1F648A: db $E4
L1F648B: db $61
L1F648C: db $36
L1F648D: db $05
L1F648E: db $36
L1F648F: db $05
L1F6490: db $E4
L1F6491: db $62
L1F6492: db $24
L1F6493: db $05
L1F6494: db $24
L1F6495: db $05
L1F6496: db $24
L1F6497: db $03
L1F6498: db $24
L1F6499: db $04
L1F649A: db $24
L1F649B: db $03
L1F649C: db $24
L1F649D: db $05
L1F649E: db $24
L1F649F: db $05
L1F64A0: db $E4
L1F64A1: db $61
L1F64A2: db $36
L1F64A3: db $14
L1F64A4: db $36
L1F64A5: db $0A
L1F64A6: db $E4
L1F64A7: db $62
L1F64A8: db $24
L1F64A9: db $0A
L1F64AA: db $E4
L1F64AB: db $61
L1F64AC: db $36
L1F64AD: db $05
L1F64AE: db $36
L1F64AF: db $05
L1F64B0: db $E4
L1F64B1: db $54
L1F64B2: db $26
L1F64B3: db $05
L1F64B4: db $32
L1F64B5: db $05
L1F64B6: db $E4
L1F64B7: db $61
L1F64B8: db $36
L1F64B9: db $05
L1F64BA: db $E4
L1F64BB: db $62
L1F64BC: db $24
L1F64BD: db $05
L1F64BE: db $24
L1F64BF: db $05
L1F64C0: db $24
L1F64C1: db $05
L1F64C2: db $E4
L1F64C3: db $61
L1F64C4: db $36
L1F64C5: db $0A
L1F64C6: db $ED
L1F64C7: db $E4
L1F64C8: db $01
L1F64C9: db $24
L1F64CA: db $0A
L1F64CB: db $E4
L1F64CC: db $53
L1F64CD: db $11
L1F64CE: db $0A
L1F64CF: db $E4
L1F64D0: db $62
L1F64D1: db $24
L1F64D2: db $0A
L1F64D3: db $E4
L1F64D4: db $61
L1F64D5: db $36
L1F64D6: db $05
L1F64D7: db $E4
L1F64D8: db $62
L1F64D9: db $24
L1F64DA: db $05
L1F64DB: db $E4
L1F64DC: db $61
L1F64DD: db $36
L1F64DE: db $05
L1F64DF: db $E4
L1F64E0: db $62
L1F64E1: db $24
L1F64E2: db $05
L1F64E3: db $E4
L1F64E4: db $53
L1F64E5: db $11
L1F64E6: db $0A
L1F64E7: db $E4
L1F64E8: db $62
L1F64E9: db $24
L1F64EA: db $0A
L1F64EB: db $E4
L1F64EC: db $61
L1F64ED: db $36
L1F64EE: db $0A
L1F64EF: db $E7
L1F64F0: db $00
L1F64F1: db $07
L1F64F2: db $C7
L1F64F3: db $64
L1F64F4: db $ED
L1F64F5: db $E4
L1F64F6: db $01
L1F64F7: db $24
L1F64F8: db $0A
L1F64F9: db $E4
L1F64FA: db $61
L1F64FB: db $36
L1F64FC: db $0A
L1F64FD: db $E4
L1F64FE: db $62
L1F64FF: db $24
L1F6500: db $05
L1F6501: db $24
L1F6502: db $05
L1F6503: db $E4
L1F6504: db $61
L1F6505: db $36
L1F6506: db $05
L1F6507: db $36
L1F6508: db $05
L1F6509: db $E4
L1F650A: db $62
L1F650B: db $24
L1F650C: db $05
L1F650D: db $24
L1F650E: db $05
L1F650F: db $E4
L1F6510: db $34
L1F6511: db $26
L1F6512: db $05
L1F6513: db $26
L1F6514: db $05
L1F6515: db $E4
L1F6516: db $44
L1F6517: db $26
L1F6518: db $05
L1F6519: db $10
L1F651A: db $05
L1F651B: db $E4
L1F651C: db $61
L1F651D: db $36
L1F651E: db $0A
L1F651F: db $ED
L1F6520: db $E4
L1F6521: db $31
L1F6522: db $21
L1F6523: db $0A
L1F6524: db $E4
L1F6525: db $61
L1F6526: db $36
L1F6527: db $0A
L1F6528: db $E4
L1F6529: db $53
L1F652A: db $11
L1F652B: db $14
L1F652C: db $E4
L1F652D: db $62
L1F652E: db $24
L1F652F: db $0A
L1F6530: db $E4
L1F6531: db $31
L1F6532: db $21
L1F6533: db $0A
L1F6534: db $E4
L1F6535: db $53
L1F6536: db $11
L1F6537: db $0A
L1F6538: db $E4
L1F6539: db $61
L1F653A: db $36
L1F653B: db $0A
L1F653C: db $E7
L1F653D: db $00
L1F653E: db $06
L1F653F: db $20
L1F6540: db $65
L1F6541: db $ED
L1F6542: db $E4
L1F6543: db $01
L1F6544: db $24
L1F6545: db $0A
L1F6546: db $E4
L1F6547: db $61
L1F6548: db $36
L1F6549: db $0A
L1F654A: db $E4
L1F654B: db $62
L1F654C: db $24
L1F654D: db $14
L1F654E: db $E4
L1F654F: db $61
L1F6550: db $36
L1F6551: db $0A
L1F6552: db $36
L1F6553: db $0A
L1F6554: db $E4
L1F6555: db $62
L1F6556: db $24
L1F6557: db $0A
L1F6558: db $E4
L1F6559: db $61
L1F655A: db $36
L1F655B: db $14
L1F655C: db $36
L1F655D: db $0A
L1F655E: db $E4
L1F655F: db $62
L1F6560: db $24
L1F6561: db $0A
L1F6562: db $E4
L1F6563: db $61
L1F6564: db $36
L1F6565: db $14
L1F6566: db $36
L1F6567: db $0A
L1F6568: db $E4
L1F6569: db $62
L1F656A: db $24
L1F656B: db $0A
L1F656C: db $E4
L1F656D: db $61
L1F656E: db $36
L1F656F: db $0A
L1F6570: db $E7
L1F6571: db $00
L1F6572: db $04
L1F6573: db $42
L1F6574: db $65
L1F6575: db $ED
L1F6576: db $E4
L1F6577: db $01
L1F6578: db $24
L1F6579: db $0A
L1F657A: db $E4
L1F657B: db $61
L1F657C: db $36
L1F657D: db $0A
L1F657E: db $E4
L1F657F: db $62
L1F6580: db $24
L1F6581: db $14
L1F6582: db $E4
L1F6583: db $61
L1F6584: db $36
L1F6585: db $0A
L1F6586: db $36
L1F6587: db $0A
L1F6588: db $E4
L1F6589: db $62
L1F658A: db $24
L1F658B: db $0A
L1F658C: db $E4
L1F658D: db $61
L1F658E: db $36
L1F658F: db $14
L1F6590: db $36
L1F6591: db $0A
L1F6592: db $E4
L1F6593: db $62
L1F6594: db $24
L1F6595: db $0A
L1F6596: db $E4
L1F6597: db $61
L1F6598: db $36
L1F6599: db $14
L1F659A: db $36
L1F659B: db $0A
L1F659C: db $E4
L1F659D: db $62
L1F659E: db $24
L1F659F: db $0A
L1F65A0: db $E4
L1F65A1: db $61
L1F65A2: db $36
L1F65A3: db $0A
L1F65A4: db $E4
L1F65A5: db $01
L1F65A6: db $24
L1F65A7: db $0A
L1F65A8: db $E4
L1F65A9: db $61
L1F65AA: db $36
L1F65AB: db $0A
L1F65AC: db $E4
L1F65AD: db $62
L1F65AE: db $24
L1F65AF: db $0A
L1F65B0: db $E4
L1F65B1: db $61
L1F65B2: db $36
L1F65B3: db $05
L1F65B4: db $36
L1F65B5: db $05
L1F65B6: db $E4
L1F65B7: db $62
L1F65B8: db $24
L1F65B9: db $05
L1F65BA: db $24
L1F65BB: db $05
L1F65BC: db $24
L1F65BD: db $03
L1F65BE: db $24
L1F65BF: db $04
L1F65C0: db $24
L1F65C1: db $03
L1F65C2: db $24
L1F65C3: db $05
L1F65C4: db $24
L1F65C5: db $05
L1F65C6: db $E4
L1F65C7: db $61
L1F65C8: db $36
L1F65C9: db $05
L1F65CA: db $36
L1F65CB: db $05
L1F65CC: db $ED
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
SndData_03_Ch1: db $E4
L1F65E7: db $77
L1F65E8: db $E9
L1F65E9: db $11
L1F65EA: db $EE
L1F65EB: db $80
L1F65EC: db $E4
L1F65ED: db $77
L1F65EE: db $EE
L1F65EF: db $80
L1F65F0: db $EC
L1F65F1: db $FC
L1F65F2: db $65
L1F65F3: db $EC
L1F65F4: db $21
L1F65F5: db $66
L1F65F6: db $EC
L1F65F7: db $38
L1F65F8: db $66
L1F65F9: db $E5
L1F65FA: db $EC
L1F65FB: db $65
L1F65FC: db $A0
L1F65FD: db $10
L1F65FE: db $A5
L1F65FF: db $08
L1F6600: db $FA
L1F6601: db $48
L1F6602: db $A0
L1F6603: db $10
L1F6604: db $A3
L1F6605: db $08
L1F6606: db $FA
L1F6607: db $48
L1F6608: db $A0
L1F6609: db $10
L1F660A: db $9E
L1F660B: db $08
L1F660C: db $FA
L1F660D: db $48
L1F660E: db $A5
L1F660F: db $10
L1F6610: db $A7
L1F6611: db $30
L1F6612: db $A5
L1F6613: db $08
L1F6614: db $E4
L1F6615: db $11
L1F6616: db $81
L1F6617: db $18
L1F6618: db $E4
L1F6619: db $77
L1F661A: db $AA
L1F661B: db $10
L1F661C: db $A9
L1F661D: db $08
L1F661E: db $FA
L1F661F: db $28
L1F6620: db $ED
L1F6621: db $AC
L1F6622: db $08
L1F6623: db $E4
L1F6624: db $11
L1F6625: db $88
L1F6626: db $60
L1F6627: db $FA
L1F6628: db $10
L1F6629: db $E4
L1F662A: db $77
L1F662B: db $9B
L1F662C: db $08
L1F662D: db $A7
L1F662E: db $10
L1F662F: db $A5
L1F6630: db $08
L1F6631: db $FA
L1F6632: db $48
L1F6633: db $AA
L1F6634: db $10
L1F6635: db $AF
L1F6636: db $08
L1F6637: db $ED
L1F6638: db $E4
L1F6639: db $11
L1F663A: db $EE
L1F663B: db $C0
L1F663C: db $86
L1F663D: db $30
L1F663E: db $E4
L1F663F: db $78
L1F6640: db $9E
L1F6641: db $10
L1F6642: db $A0
L1F6643: db $9E
L1F6644: db $9D
L1F6645: db $60
L1F6646: db $FA
L1F6647: db $30
L1F6648: db $E4
L1F6649: db $11
L1F664A: db $85
L1F664B: db $28
L1F664C: db $E4
L1F664D: db $78
L1F664E: db $9D
L1F664F: db $08
L1F6650: db $9E
L1F6651: db $30
L1F6652: db $9B
L1F6653: db $28
L1F6654: db $A2
L1F6655: db $08
L1F6656: db $FA
L1F6657: db $48
L1F6658: db $E4
L1F6659: db $11
L1F665A: db $8A
L1F665B: db $18
L1F665C: db $E4
L1F665D: db $78
L1F665E: db $A3
L1F665F: db $20
L1F6660: db $80
L1F6661: db $08
L1F6662: db $A2
L1F6663: db $28
L1F6664: db $80
L1F6665: db $08
L1F6666: db $9E
L1F6667: db $FA
L1F6668: db $30
L1F6669: db $E4
L1F666A: db $11
L1F666B: db $86
L1F666C: db $18
L1F666D: db $E4
L1F666E: db $78
L1F666F: db $A2
L1F6670: db $10
L1F6671: db $A0
L1F6672: db $08
L1F6673: db $FA
L1F6674: db $60
L1F6675: db $E4
L1F6676: db $11
L1F6677: db $EE
L1F6678: db $80
L1F6679: db $88
L1F667A: db $10
L1F667B: db $E4
L1F667C: db $77
L1F667D: db $A9
L1F667E: db $08
L1F667F: db $AA
L1F6680: db $A9
L1F6681: db $A7
L1F6682: db $A5
L1F6683: db $28
L1F6684: db $A7
L1F6685: db $08
L1F6686: db $E4
L1F6687: db $11
L1F6688: db $83
L1F6689: db $30
L1F668A: db $E4
L1F668B: db $77
L1F668C: db $AE
L1F668D: db $10
L1F668E: db $E4
L1F668F: db $11
L1F6690: db $8A
L1F6691: db $18
L1F6692: db $E4
L1F6693: db $78
L1F6694: db $EE
L1F6695: db $C0
L1F6696: db $99
L1F6697: db $08
L1F6698: db $9B
L1F6699: db $20
L1F669A: db $E4
L1F669B: db $11
L1F669C: db $83
L1F669D: db $10
L1F669E: db $E4
L1F669F: db $78
L1F66A0: db $A2
L1F66A1: db $A0
L1F66A2: db $08
L1F66A3: db $9E
L1F66A4: db $10
L1F66A5: db $9D
L1F66A6: db $08
L1F66A7: db $FA
L1F66A8: db $30
L1F66A9: db $FA
L1F66AA: db $08
L1F66AB: db $E4
L1F66AC: db $11
L1F66AD: db $85
L1F66AE: db $10
L1F66AF: db $E4
L1F66B0: db $77
L1F66B1: db $EE
L1F66B2: db $80
L1F66B3: db $AA
L1F66B4: db $10
L1F66B5: db $A9
L1F66B6: db $18
L1F66B7: db $E4
L1F66B8: db $78
L1F66B9: db $EE
L1F66BA: db $C0
L1F66BB: db $9E
L1F66BC: db $08
L1F66BD: db $9D
L1F66BE: db $10
L1F66BF: db $9B
L1F66C0: db $08
L1F66C1: db $9D
L1F66C2: db $18
L1F66C3: db $99
L1F66C4: db $97
L1F66C5: db $30
L1F66C6: db $9E
L1F66C7: db $E4
L1F66C8: db $11
L1F66C9: db $EE
L1F66CA: db $80
L1F66CB: db $8B
L1F66CC: db $18
L1F66CD: db $E4
L1F66CE: db $73
L1F66CF: db $A3
L1F66D0: db $08
L1F66D1: db $A2
L1F66D2: db $A0
L1F66D3: db $A5
L1F66D4: db $10
L1F66D5: db $A0
L1F66D6: db $A2
L1F66D7: db $E4
L1F66D8: db $75
L1F66D9: db $9B
L1F66DA: db $FA
L1F66DB: db $48
L1F66DC: db $9D
L1F66DD: db $18
L1F66DE: db $FA
L1F66DF: db $48
L1F66E0: db $FA
L1F66E1: db $08
L1F66E2: db $9C
L1F66E3: db $10
L1F66E4: db $FA
L1F66E5: db $48
L1F66E6: db $9E
L1F66E7: db $18
L1F66E8: db $FA
L1F66E9: db $30
L1F66EA: db $FA
L1F66EB: db $08
L1F66EC: db $ED
SndData_03_Ch2: db $E4
L1F66EE: db $11
L1F66EF: db $E9
L1F66F0: db $22
L1F66F1: db $EE
L1F66F2: db $80
L1F66F3: db $E4
L1F66F4: db $11
L1F66F5: db $81
L1F66F6: db $18
L1F66F7: db $EC
L1F66F8: db $1E
L1F66F9: db $67
L1F66FA: db $EC
L1F66FB: db $4D
L1F66FC: db $67
L1F66FD: db $EC
L1F66FE: db $1E
L1F66FF: db $67
L1F6700: db $EC
L1F6701: db $5A
L1F6702: db $67
L1F6703: db $EC
L1F6704: db $5F
L1F6705: db $67
L1F6706: db $EC
L1F6707: db $74
L1F6708: db $67
L1F6709: db $EC
L1F670A: db $87
L1F670B: db $67
L1F670C: db $EC
L1F670D: db $9E
L1F670E: db $67
L1F670F: db $EC
L1F6710: db $9E
L1F6711: db $67
L1F6712: db $EC
L1F6713: db $B1
L1F6714: db $67
L1F6715: db $EC
L1F6716: db $9E
L1F6717: db $67
L1F6718: db $EC
L1F6719: db $C2
L1F671A: db $67
L1F671B: db $E5
L1F671C: db $F7
L1F671D: db $66
L1F671E: db $E4
L1F671F: db $54
L1F6720: db $9D
L1F6721: db $10
L1F6722: db $99
L1F6723: db $08
L1F6724: db $A0
L1F6725: db $10
L1F6726: db $9B
L1F6727: db $08
L1F6728: db $A3
L1F6729: db $10
L1F672A: db $99
L1F672B: db $08
L1F672C: db $A0
L1F672D: db $10
L1F672E: db $9B
L1F672F: db $18
L1F6730: db $97
L1F6731: db $08
L1F6732: db $A0
L1F6733: db $10
L1F6734: db $9D
L1F6735: db $08
L1F6736: db $A3
L1F6737: db $10
L1F6738: db $9B
L1F6739: db $08
L1F673A: db $97
L1F673B: db $99
L1F673C: db $96
L1F673D: db $18
L1F673E: db $92
L1F673F: db $08
L1F6740: db $99
L1F6741: db $10
L1F6742: db $96
L1F6743: db $08
L1F6744: db $9C
L1F6745: db $10
L1F6746: db $96
L1F6747: db $08
L1F6748: db $92
L1F6749: db $10
L1F674A: db $A1
L1F674B: db $18
L1F674C: db $ED
L1F674D: db $97
L1F674E: db $08
L1F674F: db $A1
L1F6750: db $10
L1F6751: db $9B
L1F6752: db $08
L1F6753: db $A0
L1F6754: db $10
L1F6755: db $9B
L1F6756: db $08
L1F6757: db $97
L1F6758: db $18
L1F6759: db $ED
L1F675A: db $FA
L1F675B: db $48
L1F675C: db $FA
L1F675D: db $08
L1F675E: db $ED
L1F675F: db $E4
L1F6760: db $42
L1F6761: db $AC
L1F6762: db $08
L1F6763: db $A5
L1F6764: db $A9
L1F6765: db $A5
L1F6766: db $B3
L1F6767: db $A5
L1F6768: db $A9
L1F6769: db $A5
L1F676A: db $AC
L1F676B: db $A5
L1F676C: db $B3
L1F676D: db $A9
L1F676E: db $E7
L1F676F: db $00
L1F6770: db $02
L1F6771: db $5F
L1F6772: db $67
L1F6773: db $ED
L1F6774: db $AA
L1F6775: db $08
L1F6776: db $A5
L1F6777: db $AE
L1F6778: db $A5
L1F6779: db $B1
L1F677A: db $A5
L1F677B: db $AA
L1F677C: db $A5
L1F677D: db $AE
L1F677E: db $A5
L1F677F: db $B1
L1F6780: db $A5
L1F6781: db $E7
L1F6782: db $00
L1F6783: db $02
L1F6784: db $74
L1F6785: db $67
L1F6786: db $ED
L1F6787: db $E4
L1F6788: db $57
L1F6789: db $9B
L1F678A: db $28
L1F678B: db $9D
L1F678C: db $30
L1F678D: db $A2
L1F678E: db $18
L1F678F: db $A0
L1F6790: db $08
L1F6791: db $9B
L1F6792: db $10
L1F6793: db $A5
L1F6794: db $20
L1F6795: db $A4
L1F6796: db $10
L1F6797: db $A3
L1F6798: db $08
L1F6799: db $FA
L1F679A: db $60
L1F679B: db $FA
L1F679C: db $60
L1F679D: db $ED
L1F679E: db $E4
L1F679F: db $42
L1F67A0: db $A0
L1F67A1: db $08
L1F67A2: db $9B
L1F67A3: db $04
L1F67A4: db $99
L1F67A5: db $A0
L1F67A6: db $08
L1F67A7: db $AA
L1F67A8: db $10
L1F67A9: db $9B
L1F67AA: db $08
L1F67AB: db $E7
L1F67AC: db $00
L1F67AD: db $02
L1F67AE: db $9E
L1F67AF: db $67
L1F67B0: db $ED
L1F67B1: db $A0
L1F67B2: db $08
L1F67B3: db $9D
L1F67B4: db $04
L1F67B5: db $9B
L1F67B6: db $A0
L1F67B7: db $08
L1F67B8: db $AA
L1F67B9: db $10
L1F67BA: db $9B
L1F67BB: db $08
L1F67BC: db $E7
L1F67BD: db $00
L1F67BE: db $04
L1F67BF: db $B1
L1F67C0: db $67
L1F67C1: db $ED
L1F67C2: db $E4
L1F67C3: db $11
L1F67C4: db $86
L1F67C5: db $18
L1F67C6: db $E4
L1F67C7: db $53
L1F67C8: db $9E
L1F67C9: db $08
L1F67CA: db $9D
L1F67CB: db $9B
L1F67CC: db $A0
L1F67CD: db $10
L1F67CE: db $9B
L1F67CF: db $9D
L1F67D0: db $E4
L1F67D1: db $55
L1F67D2: db $97
L1F67D3: db $10
L1F67D4: db $FA
L1F67D5: db $48
L1F67D6: db $99
L1F67D7: db $18
L1F67D8: db $FA
L1F67D9: db $48
L1F67DA: db $FA
L1F67DB: db $08
L1F67DC: db $99
L1F67DD: db $10
L1F67DE: db $FA
L1F67DF: db $48
L1F67E0: db $9B
L1F67E1: db $18
L1F67E2: db $FA
L1F67E3: db $48
L1F67E4: db $FA
L1F67E5: db $08
L1F67E6: db $ED
SndData_03_Ch3: db $E4
L1F67E8: db $00
L1F67E9: db $E9
L1F67EA: db $44
L1F67EB: db $F3
L1F67EC: db $02
L1F67ED: db $F5
L1F67EE: db $3C
L1F67EF: db $81
L1F67F0: db $18
L1F67F1: db $E4
L1F67F2: db $40
L1F67F3: db $EC
L1F67F4: db $05
L1F67F5: db $68
L1F67F6: db $EC
L1F67F7: db $2C
L1F67F8: db $68
L1F67F9: db $EC
L1F67FA: db $05
L1F67FB: db $68
L1F67FC: db $EC
L1F67FD: db $39
L1F67FE: db $68
L1F67FF: db $EC
L1F6800: db $3E
L1F6801: db $68
L1F6802: db $E5
L1F6803: db $F1
L1F6804: db $67
L1F6805: db $8D
L1F6806: db $10
L1F6807: db $8C
L1F6808: db $08
L1F6809: db $8D
L1F680A: db $18
L1F680B: db $85
L1F680C: db $10
L1F680D: db $88
L1F680E: db $08
L1F680F: db $8D
L1F6810: db $10
L1F6811: db $8B
L1F6812: db $18
L1F6813: db $8A
L1F6814: db $08
L1F6815: db $8B
L1F6816: db $18
L1F6817: db $8B
L1F6818: db $10
L1F6819: db $83
L1F681A: db $08
L1F681B: db $85
L1F681C: db $10
L1F681D: db $86
L1F681E: db $18
L1F681F: db $85
L1F6820: db $08
L1F6821: db $86
L1F6822: db $18
L1F6823: db $86
L1F6824: db $10
L1F6825: db $85
L1F6826: db $08
L1F6827: db $8A
L1F6828: db $10
L1F6829: db $8B
L1F682A: db $18
L1F682B: db $ED
L1F682C: db $8A
L1F682D: db $08
L1F682E: db $8B
L1F682F: db $10
L1F6830: db $86
L1F6831: db $08
L1F6832: db $8B
L1F6833: db $10
L1F6834: db $8A
L1F6835: db $08
L1F6836: db $8B
L1F6837: db $18
L1F6838: db $ED
L1F6839: db $FA
L1F683A: db $48
L1F683B: db $FA
L1F683C: db $08
L1F683D: db $ED
L1F683E: db $8A
L1F683F: db $18
L1F6840: db $8A
L1F6841: db $8A
L1F6842: db $10
L1F6843: db $85
L1F6844: db $08
L1F6845: db $8A
L1F6846: db $18
L1F6847: db $E7
L1F6848: db $00
L1F6849: db $02
L1F684A: db $3E
L1F684B: db $68
L1F684C: db $8B
L1F684D: db $18
L1F684E: db $8B
L1F684F: db $8B
L1F6850: db $10
L1F6851: db $86
L1F6852: db $08
L1F6853: db $8B
L1F6854: db $18
L1F6855: db $8B
L1F6856: db $18
L1F6857: db $8B
L1F6858: db $8B
L1F6859: db $10
L1F685A: db $86
L1F685B: db $08
L1F685C: db $8B
L1F685D: db $10
L1F685E: db $8B
L1F685F: db $08
L1F6860: db $88
L1F6861: db $10
L1F6862: db $87
L1F6863: db $08
L1F6864: db $88
L1F6865: db $10
L1F6866: db $8A
L1F6867: db $18
L1F6868: db $88
L1F6869: db $08
L1F686A: db $8A
L1F686B: db $10
L1F686C: db $8B
L1F686D: db $18
L1F686E: db $8A
L1F686F: db $08
L1F6870: db $8B
L1F6871: db $18
L1F6872: db $8C
L1F6873: db $10
L1F6874: db $86
L1F6875: db $08
L1F6876: db $8C
L1F6877: db $10
L1F6878: db $8D
L1F6879: db $18
L1F687A: db $8C
L1F687B: db $08
L1F687C: db $8D
L1F687D: db $18
L1F687E: db $8D
L1F687F: db $10
L1F6880: db $88
L1F6881: db $08
L1F6882: db $8A
L1F6883: db $10
L1F6884: db $8D
L1F6885: db $18
L1F6886: db $8C
L1F6887: db $08
L1F6888: db $8D
L1F6889: db $10
L1F688A: db $88
L1F688B: db $08
L1F688C: db $8D
L1F688D: db $88
L1F688E: db $8D
L1F688F: db $8C
L1F6890: db $10
L1F6891: db $8B
L1F6892: db $20
L1F6893: db $8B
L1F6894: db $18
L1F6895: db $8B
L1F6896: db $10
L1F6897: db $86
L1F6898: db $08
L1F6899: db $8B
L1F689A: db $18
L1F689B: db $8B
L1F689C: db $18
L1F689D: db $8B
L1F689E: db $8B
L1F689F: db $08
L1F68A0: db $86
L1F68A1: db $8B
L1F68A2: db $8C
L1F68A3: db $10
L1F68A4: db $8D
L1F68A5: db $20
L1F68A6: db $8D
L1F68A7: db $18
L1F68A8: db $8D
L1F68A9: db $10
L1F68AA: db $88
L1F68AB: db $08
L1F68AC: db $8D
L1F68AD: db $10
L1F68AE: db $88
L1F68AF: db $08
L1F68B0: db $8D
L1F68B1: db $18
L1F68B2: db $8D
L1F68B3: db $8D
L1F68B4: db $10
L1F68B5: db $88
L1F68B6: db $08
L1F68B7: db $8D
L1F68B8: db $10
L1F68B9: db $86
L1F68BA: db $08
L1F68BB: db $8B
L1F68BC: db $18
L1F68BD: db $8B
L1F68BE: db $10
L1F68BF: db $8A
L1F68C0: db $08
L1F68C1: db $8B
L1F68C2: db $10
L1F68C3: db $86
L1F68C4: db $08
L1F68C5: db $88
L1F68C6: db $10
L1F68C7: db $8B
L1F68C8: db $FA
L1F68C9: db $48
L1F68CA: db $FA
L1F68CB: db $10
L1F68CC: db $88
L1F68CD: db $FA
L1F68CE: db $48
L1F68CF: db $8A
L1F68D0: db $10
L1F68D1: db $FA
L1F68D2: db $48
L1F68D3: db $FA
L1F68D4: db $10
L1F68D5: db $89
L1F68D6: db $FA
L1F68D7: db $48
L1F68D8: db $8B
L1F68D9: db $10
L1F68DA: db $FA
L1F68DB: db $48
L1F68DC: db $FA
L1F68DD: db $08
L1F68DE: db $8D
L1F68DF: db $ED
SndData_03_Ch4: db $E9
L1F68E1: db $88
L1F68E2: db $E4
L1F68E3: db $31
L1F68E4: db $21
L1F68E5: db $18
L1F68E6: db $EC
L1F68E7: db $F8
L1F68E8: db $68
L1F68E9: db $EC
L1F68EA: db $38
L1F68EB: db $69
L1F68EC: db $EC
L1F68ED: db $38
L1F68EE: db $69
L1F68EF: db $EC
L1F68F0: db $62
L1F68F1: db $69
L1F68F2: db $EC
L1F68F3: db $E1
L1F68F4: db $69
L1F68F5: db $E5
L1F68F6: db $E6
L1F68F7: db $68
L1F68F8: db $E4
L1F68F9: db $61
L1F68FA: db $36
L1F68FB: db $10
L1F68FC: db $E4
L1F68FD: db $31
L1F68FE: db $21
L1F68FF: db $08
L1F6900: db $E4
L1F6901: db $62
L1F6902: db $24
L1F6903: db $10
L1F6904: db $E4
L1F6905: db $61
L1F6906: db $36
L1F6907: db $18
L1F6908: db $E4
L1F6909: db $31
L1F690A: db $21
L1F690B: db $08
L1F690C: db $E4
L1F690D: db $62
L1F690E: db $24
L1F690F: db $10
L1F6910: db $E4
L1F6911: db $61
L1F6912: db $36
L1F6913: db $08
L1F6914: db $E7
L1F6915: db $00
L1F6916: db $06
L1F6917: db $F8
L1F6918: db $68
L1F6919: db $E4
L1F691A: db $61
L1F691B: db $36
L1F691C: db $10
L1F691D: db $E4
L1F691E: db $31
L1F691F: db $21
L1F6920: db $08
L1F6921: db $E4
L1F6922: db $62
L1F6923: db $24
L1F6924: db $10
L1F6925: db $E4
L1F6926: db $61
L1F6927: db $36
L1F6928: db $18
L1F6929: db $E4
L1F692A: db $31
L1F692B: db $21
L1F692C: db $08
L1F692D: db $E4
L1F692E: db $62
L1F692F: db $24
L1F6930: db $10
L1F6931: db $E4
L1F6932: db $61
L1F6933: db $36
L1F6934: db $60
L1F6935: db $FA
L1F6936: db $08
L1F6937: db $ED
L1F6938: db $E4
L1F6939: db $61
L1F693A: db $36
L1F693B: db $10
L1F693C: db $E4
L1F693D: db $31
L1F693E: db $21
L1F693F: db $08
L1F6940: db $E4
L1F6941: db $62
L1F6942: db $24
L1F6943: db $10
L1F6944: db $E4
L1F6945: db $53
L1F6946: db $11
L1F6947: db $08
L1F6948: db $E7
L1F6949: db $00
L1F694A: db $03
L1F694B: db $38
L1F694C: db $69
L1F694D: db $E4
L1F694E: db $61
L1F694F: db $36
L1F6950: db $08
L1F6951: db $E4
L1F6952: db $62
L1F6953: db $24
L1F6954: db $08
L1F6955: db $E4
L1F6956: db $31
L1F6957: db $21
L1F6958: db $08
L1F6959: db $E4
L1F695A: db $62
L1F695B: db $24
L1F695C: db $10
L1F695D: db $E4
L1F695E: db $53
L1F695F: db $11
L1F6960: db $08
L1F6961: db $ED
L1F6962: db $E4
L1F6963: db $61
L1F6964: db $36
L1F6965: db $10
L1F6966: db $E4
L1F6967: db $53
L1F6968: db $11
L1F6969: db $08
L1F696A: db $E4
L1F696B: db $62
L1F696C: db $24
L1F696D: db $10
L1F696E: db $E4
L1F696F: db $61
L1F6970: db $36
L1F6971: db $18
L1F6972: db $E4
L1F6973: db $53
L1F6974: db $11
L1F6975: db $08
L1F6976: db $E4
L1F6977: db $62
L1F6978: db $24
L1F6979: db $10
L1F697A: db $E4
L1F697B: db $61
L1F697C: db $36
L1F697D: db $18
L1F697E: db $36
L1F697F: db $08
L1F6980: db $E4
L1F6981: db $34
L1F6982: db $26
L1F6983: db $08
L1F6984: db $E4
L1F6985: db $44
L1F6986: db $26
L1F6987: db $08
L1F6988: db $E4
L1F6989: db $54
L1F698A: db $26
L1F698B: db $08
L1F698C: db $E4
L1F698D: db $62
L1F698E: db $24
L1F698F: db $08
L1F6990: db $E4
L1F6991: db $61
L1F6992: db $36
L1F6993: db $08
L1F6994: db $E4
L1F6995: db $62
L1F6996: db $24
L1F6997: db $08
L1F6998: db $E4
L1F6999: db $61
L1F699A: db $36
L1F699B: db $10
L1F699C: db $36
L1F699D: db $18
L1F699E: db $E4
L1F699F: db $31
L1F69A0: db $21
L1F69A1: db $08
L1F69A2: db $E4
L1F69A3: db $62
L1F69A4: db $24
L1F69A5: db $10
L1F69A6: db $E4
L1F69A7: db $53
L1F69A8: db $11
L1F69A9: db $08
L1F69AA: db $E4
L1F69AB: db $61
L1F69AC: db $36
L1F69AD: db $08
L1F69AE: db $E4
L1F69AF: db $62
L1F69B0: db $24
L1F69B1: db $08
L1F69B2: db $E4
L1F69B3: db $31
L1F69B4: db $21
L1F69B5: db $08
L1F69B6: db $E4
L1F69B7: db $62
L1F69B8: db $24
L1F69B9: db $10
L1F69BA: db $E4
L1F69BB: db $61
L1F69BC: db $36
L1F69BD: db $18
L1F69BE: db $E4
L1F69BF: db $31
L1F69C0: db $21
L1F69C1: db $08
L1F69C2: db $E4
L1F69C3: db $62
L1F69C4: db $24
L1F69C5: db $10
L1F69C6: db $E4
L1F69C7: db $53
L1F69C8: db $11
L1F69C9: db $08
L1F69CA: db $E4
L1F69CB: db $61
L1F69CC: db $36
L1F69CD: db $08
L1F69CE: db $E4
L1F69CF: db $62
L1F69D0: db $24
L1F69D1: db $08
L1F69D2: db $E4
L1F69D3: db $31
L1F69D4: db $21
L1F69D5: db $08
L1F69D6: db $E4
L1F69D7: db $62
L1F69D8: db $24
L1F69D9: db $08
L1F69DA: db $24
L1F69DB: db $08
L1F69DC: db $E4
L1F69DD: db $61
L1F69DE: db $36
L1F69DF: db $08
L1F69E0: db $ED
L1F69E1: db $E4
L1F69E2: db $61
L1F69E3: db $36
L1F69E4: db $08
L1F69E5: db $E4
L1F69E6: db $31
L1F69E7: db $21
L1F69E8: db $08
L1F69E9: db $E4
L1F69EA: db $61
L1F69EB: db $36
L1F69EC: db $08
L1F69ED: db $E4
L1F69EE: db $62
L1F69EF: db $24
L1F69F0: db $08
L1F69F1: db $E4
L1F69F2: db $53
L1F69F3: db $11
L1F69F4: db $08
L1F69F5: db $E4
L1F69F6: db $61
L1F69F7: db $36
L1F69F8: db $08
L1F69F9: db $36
L1F69FA: db $08
L1F69FB: db $E4
L1F69FC: db $62
L1F69FD: db $24
L1F69FE: db $08
L1F69FF: db $E4
L1F6A00: db $61
L1F6A01: db $36
L1F6A02: db $08
L1F6A03: db $E4
L1F6A04: db $62
L1F6A05: db $24
L1F6A06: db $08
L1F6A07: db $E4
L1F6A08: db $31
L1F6A09: db $21
L1F6A0A: db $08
L1F6A0B: db $E4
L1F6A0C: db $53
L1F6A0D: db $11
L1F6A0E: db $08
L1F6A0F: db $E7
L1F6A10: db $00
L1F6A11: db $05
L1F6A12: db $E1
L1F6A13: db $69
L1F6A14: db $E4
L1F6A15: db $31
L1F6A16: db $21
L1F6A17: db $18
L1F6A18: db $E4
L1F6A19: db $62
L1F6A1A: db $24
L1F6A1B: db $08
L1F6A1C: db $24
L1F6A1D: db $08
L1F6A1E: db $24
L1F6A1F: db $08
L1F6A20: db $E4
L1F6A21: db $34
L1F6A22: db $26
L1F6A23: db $04
L1F6A24: db $26
L1F6A25: db $04
L1F6A26: db $E4
L1F6A27: db $61
L1F6A28: db $36
L1F6A29: db $08
L1F6A2A: db $E4
L1F6A2B: db $44
L1F6A2C: db $26
L1F6A2D: db $04
L1F6A2E: db $10
L1F6A2F: db $04
L1F6A30: db $E4
L1F6A31: db $61
L1F6A32: db $36
L1F6A33: db $08
L1F6A34: db $E4
L1F6A35: db $54
L1F6A36: db $26
L1F6A37: db $04
L1F6A38: db $32
L1F6A39: db $04
L1F6A3A: db $E4
L1F6A3B: db $61
L1F6A3C: db $36
L1F6A3D: db $08
L1F6A3E: db $36
L1F6A3F: db $28
L1F6A40: db $36
L1F6A41: db $08
L1F6A42: db $36
L1F6A43: db $08
L1F6A44: db $E4
L1F6A45: db $62
L1F6A46: db $24
L1F6A47: db $08
L1F6A48: db $24
L1F6A49: db $08
L1F6A4A: db $E4
L1F6A4B: db $44
L1F6A4C: db $26
L1F6A4D: db $10
L1F6A4E: db $E4
L1F6A4F: db $61
L1F6A50: db $36
L1F6A51: db $18
L1F6A52: db $E4
L1F6A53: db $62
L1F6A54: db $24
L1F6A55: db $08
L1F6A56: db $E4
L1F6A57: db $54
L1F6A58: db $26
L1F6A59: db $08
L1F6A5A: db $E4
L1F6A5B: db $62
L1F6A5C: db $24
L1F6A5D: db $08
L1F6A5E: db $24
L1F6A5F: db $08
L1F6A60: db $E4
L1F6A61: db $44
L1F6A62: db $26
L1F6A63: db $04
L1F6A64: db $10
L1F6A65: db $04
L1F6A66: db $10
L1F6A67: db $08
L1F6A68: db $10
L1F6A69: db $08
L1F6A6A: db $E4
L1F6A6B: db $34
L1F6A6C: db $26
L1F6A6D: db $04
L1F6A6E: db $26
L1F6A6F: db $04
L1F6A70: db $26
L1F6A71: db $08
L1F6A72: db $26
L1F6A73: db $08
L1F6A74: db $E4
L1F6A75: db $61
L1F6A76: db $36
L1F6A77: db $08
L1F6A78: db $E4
L1F6A79: db $62
L1F6A7A: db $24
L1F6A7B: db $08
L1F6A7C: db $24
L1F6A7D: db $08
L1F6A7E: db $24
L1F6A7F: db $08
L1F6A80: db $E4
L1F6A81: db $61
L1F6A82: db $36
L1F6A83: db $08
L1F6A84: db $36
L1F6A85: db $08
L1F6A86: db $E4
L1F6A87: db $62
L1F6A88: db $24
L1F6A89: db $08
L1F6A8A: db $E4
L1F6A8B: db $44
L1F6A8C: db $26
L1F6A8D: db $04
L1F6A8E: db $E4
L1F6A8F: db $34
L1F6A90: db $26
L1F6A91: db $04
L1F6A92: db $E4
L1F6A93: db $54
L1F6A94: db $26
L1F6A95: db $08
L1F6A96: db $E4
L1F6A97: db $61
L1F6A98: db $36
L1F6A99: db $08
L1F6A9A: db $36
L1F6A9B: db $08
L1F6A9C: db $E4
L1F6A9D: db $53
L1F6A9E: db $11
L1F6A9F: db $08
L1F6AA0: db $FA
L1F6AA1: db $30
L1F6AA2: db $E4
L1F6AA3: db $62
L1F6AA4: db $24
L1F6AA5: db $08
L1F6AA6: db $E4
L1F6AA7: db $61
L1F6AA8: db $36
L1F6AA9: db $10
L1F6AAA: db $E4
L1F6AAB: db $62
L1F6AAC: db $24
L1F6AAD: db $10
L1F6AAE: db $24
L1F6AAF: db $08
L1F6AB0: db $ED
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
SndData_18_Ch1: db $E4
L1F6ACB: db $77
L1F6ACC: db $E9
L1F6ACD: db $11
L1F6ACE: db $EE
L1F6ACF: db $80
L1F6AD0: db $EC
L1F6AD1: db $D9
L1F6AD2: db $6A
L1F6AD3: db $EC
L1F6AD4: db $08
L1F6AD5: db $6B
L1F6AD6: db $E5
L1F6AD7: db $CA
L1F6AD8: db $6A
L1F6AD9: db $E4
L1F6ADA: db $84
L1F6ADB: db $9E
L1F6ADC: db $0A
L1F6ADD: db $A0
L1F6ADE: db $A4
L1F6ADF: db $A9
L1F6AE0: db $9E
L1F6AE1: db $A0
L1F6AE2: db $A4
L1F6AE3: db $A9
L1F6AE4: db $E4
L1F6AE5: db $44
L1F6AE6: db $9E
L1F6AE7: db $A0
L1F6AE8: db $A4
L1F6AE9: db $A9
L1F6AEA: db $9E
L1F6AEB: db $A0
L1F6AEC: db $A4
L1F6AED: db $A9
L1F6AEE: db $E4
L1F6AEF: db $84
L1F6AF0: db $9F
L1F6AF1: db $A0
L1F6AF2: db $A4
L1F6AF3: db $A9
L1F6AF4: db $9F
L1F6AF5: db $A0
L1F6AF6: db $A4
L1F6AF7: db $A9
L1F6AF8: db $E4
L1F6AF9: db $44
L1F6AFA: db $9F
L1F6AFB: db $A0
L1F6AFC: db $A4
L1F6AFD: db $A9
L1F6AFE: db $9F
L1F6AFF: db $A0
L1F6B00: db $A4
L1F6B01: db $A9
L1F6B02: db $E7
L1F6B03: db $00
L1F6B04: db $04
L1F6B05: db $D9
L1F6B06: db $6A
L1F6B07: db $ED
L1F6B08: db $E4
L1F6B09: db $84
L1F6B0A: db $AA
L1F6B0B: db $0A
L1F6B0C: db $AE
L1F6B0D: db $B5
L1F6B0E: db $AA
L1F6B0F: db $AE
L1F6B10: db $B5
L1F6B11: db $E4
L1F6B12: db $44
L1F6B13: db $AA
L1F6B14: db $AE
L1F6B15: db $B5
L1F6B16: db $AA
L1F6B17: db $AE
L1F6B18: db $B5
L1F6B19: db $E4
L1F6B1A: db $27
L1F6B1B: db $AA
L1F6B1C: db $AE
L1F6B1D: db $B5
L1F6B1E: db $14
L1F6B1F: db $E4
L1F6B20: db $84
L1F6B21: db $A9
L1F6B22: db $0A
L1F6B23: db $AD
L1F6B24: db $B5
L1F6B25: db $A9
L1F6B26: db $AD
L1F6B27: db $B5
L1F6B28: db $E4
L1F6B29: db $44
L1F6B2A: db $A9
L1F6B2B: db $AD
L1F6B2C: db $B5
L1F6B2D: db $A9
L1F6B2E: db $AD
L1F6B2F: db $B5
L1F6B30: db $E4
L1F6B31: db $27
L1F6B32: db $A9
L1F6B33: db $AD
L1F6B34: db $B5
L1F6B35: db $14
L1F6B36: db $E7
L1F6B37: db $00
L1F6B38: db $03
L1F6B39: db $08
L1F6B3A: db $6B
L1F6B3B: db $E4
L1F6B3C: db $84
L1F6B3D: db $AA
L1F6B3E: db $0A
L1F6B3F: db $AE
L1F6B40: db $B5
L1F6B41: db $AA
L1F6B42: db $AE
L1F6B43: db $B5
L1F6B44: db $E4
L1F6B45: db $44
L1F6B46: db $AA
L1F6B47: db $AE
L1F6B48: db $B5
L1F6B49: db $AA
L1F6B4A: db $AE
L1F6B4B: db $B5
L1F6B4C: db $E4
L1F6B4D: db $27
L1F6B4E: db $AA
L1F6B4F: db $AE
L1F6B50: db $B5
L1F6B51: db $14
L1F6B52: db $E4
L1F6B53: db $84
L1F6B54: db $AC
L1F6B55: db $0A
L1F6B56: db $B0
L1F6B57: db $B8
L1F6B58: db $AC
L1F6B59: db $B0
L1F6B5A: db $B8
L1F6B5B: db $E4
L1F6B5C: db $44
L1F6B5D: db $AD
L1F6B5E: db $B0
L1F6B5F: db $B9
L1F6B60: db $AD
L1F6B61: db $B0
L1F6B62: db $B9
L1F6B63: db $E4
L1F6B64: db $27
L1F6B65: db $AD
L1F6B66: db $B0
L1F6B67: db $B9
L1F6B68: db $14
L1F6B69: db $ED
SndData_18_Ch2: db $E4
L1F6B6B: db $34
L1F6B6C: db $E9
L1F6B6D: db $22
L1F6B6E: db $EE
L1F6B6F: db $80
L1F6B70: db $80
L1F6B71: db $0F
L1F6B72: db $EC
L1F6B73: db $7B
L1F6B74: db $6B
L1F6B75: db $EC
L1F6B76: db $AA
L1F6B77: db $6B
L1F6B78: db $E5
L1F6B79: db $72
L1F6B7A: db $6B
L1F6B7B: db $E4
L1F6B7C: db $47
L1F6B7D: db $9E
L1F6B7E: db $0A
L1F6B7F: db $A0
L1F6B80: db $A4
L1F6B81: db $A9
L1F6B82: db $9E
L1F6B83: db $A0
L1F6B84: db $A4
L1F6B85: db $A9
L1F6B86: db $E4
L1F6B87: db $27
L1F6B88: db $9E
L1F6B89: db $A0
L1F6B8A: db $A4
L1F6B8B: db $A9
L1F6B8C: db $9E
L1F6B8D: db $A0
L1F6B8E: db $A4
L1F6B8F: db $A9
L1F6B90: db $E4
L1F6B91: db $47
L1F6B92: db $9F
L1F6B93: db $A0
L1F6B94: db $A4
L1F6B95: db $A9
L1F6B96: db $9F
L1F6B97: db $A0
L1F6B98: db $A4
L1F6B99: db $A9
L1F6B9A: db $E4
L1F6B9B: db $27
L1F6B9C: db $9F
L1F6B9D: db $A0
L1F6B9E: db $A4
L1F6B9F: db $A9
L1F6BA0: db $9F
L1F6BA1: db $A0
L1F6BA2: db $A4
L1F6BA3: db $A9
L1F6BA4: db $E7
L1F6BA5: db $00
L1F6BA6: db $04
L1F6BA7: db $7B
L1F6BA8: db $6B
L1F6BA9: db $ED
L1F6BAA: db $E4
L1F6BAB: db $47
L1F6BAC: db $AA
L1F6BAD: db $0A
L1F6BAE: db $AE
L1F6BAF: db $B5
L1F6BB0: db $AA
L1F6BB1: db $AE
L1F6BB2: db $B5
L1F6BB3: db $E4
L1F6BB4: db $27
L1F6BB5: db $AA
L1F6BB6: db $AE
L1F6BB7: db $B5
L1F6BB8: db $AA
L1F6BB9: db $AE
L1F6BBA: db $B5
L1F6BBB: db $E4
L1F6BBC: db $17
L1F6BBD: db $AA
L1F6BBE: db $AE
L1F6BBF: db $B5
L1F6BC0: db $14
L1F6BC1: db $E4
L1F6BC2: db $47
L1F6BC3: db $A9
L1F6BC4: db $0A
L1F6BC5: db $AD
L1F6BC6: db $B5
L1F6BC7: db $A9
L1F6BC8: db $AD
L1F6BC9: db $B5
L1F6BCA: db $E4
L1F6BCB: db $27
L1F6BCC: db $A9
L1F6BCD: db $AD
L1F6BCE: db $B5
L1F6BCF: db $A9
L1F6BD0: db $AD
L1F6BD1: db $B5
L1F6BD2: db $E4
L1F6BD3: db $17
L1F6BD4: db $A9
L1F6BD5: db $AD
L1F6BD6: db $B5
L1F6BD7: db $14
L1F6BD8: db $E7
L1F6BD9: db $00
L1F6BDA: db $03
L1F6BDB: db $AA
L1F6BDC: db $6B
L1F6BDD: db $E4
L1F6BDE: db $47
L1F6BDF: db $AA
L1F6BE0: db $0A
L1F6BE1: db $AE
L1F6BE2: db $B5
L1F6BE3: db $AA
L1F6BE4: db $AE
L1F6BE5: db $B5
L1F6BE6: db $E4
L1F6BE7: db $27
L1F6BE8: db $AA
L1F6BE9: db $AE
L1F6BEA: db $B5
L1F6BEB: db $AA
L1F6BEC: db $AE
L1F6BED: db $B5
L1F6BEE: db $E4
L1F6BEF: db $17
L1F6BF0: db $AA
L1F6BF1: db $AE
L1F6BF2: db $B5
L1F6BF3: db $14
L1F6BF4: db $E4
L1F6BF5: db $47
L1F6BF6: db $AC
L1F6BF7: db $0A
L1F6BF8: db $B0
L1F6BF9: db $B8
L1F6BFA: db $AC
L1F6BFB: db $B0
L1F6BFC: db $B8
L1F6BFD: db $E4
L1F6BFE: db $27
L1F6BFF: db $AD
L1F6C00: db $B0
L1F6C01: db $B9
L1F6C02: db $AD
L1F6C03: db $B0
L1F6C04: db $B9
L1F6C05: db $E4
L1F6C06: db $17
L1F6C07: db $AD
L1F6C08: db $B0
L1F6C09: db $B9
L1F6C0A: db $14
L1F6C0B: db $ED
SndData_18_Ch3: db $E4
L1F6C0D: db $40
L1F6C0E: db $E9
L1F6C0F: db $44
L1F6C10: db $F3
L1F6C11: db $02
L1F6C12: db $F5
L1F6C13: db $00
L1F6C14: db $EC
L1F6C15: db $1D
L1F6C16: db $6C
L1F6C17: db $EC
L1F6C18: db $31
L1F6C19: db $6C
L1F6C1A: db $E5
L1F6C1B: db $0C
L1F6C1C: db $6C
L1F6C1D: db $92
L1F6C1E: db $50
L1F6C1F: db $FA
L1F6C20: db $50
L1F6C21: db $F5
L1F6C22: db $14
L1F6C23: db $91
L1F6C24: db $0A
L1F6C25: db $F5
L1F6C26: db $00
L1F6C27: db $91
L1F6C28: db $78
L1F6C29: db $FA
L1F6C2A: db $1E
L1F6C2B: db $E7
L1F6C2C: db $00
L1F6C2D: db $04
L1F6C2E: db $1D
L1F6C2F: db $6C
L1F6C30: db $ED
L1F6C31: db $F5
L1F6C32: db $1E
L1F6C33: db $92
L1F6C34: db $1E
L1F6C35: db $F5
L1F6C36: db $00
L1F6C37: db $92
L1F6C38: db $78
L1F6C39: db $FA
L1F6C3A: db $0A
L1F6C3B: db $F5
L1F6C3C: db $1E
L1F6C3D: db $91
L1F6C3E: db $1E
L1F6C3F: db $F5
L1F6C40: db $00
L1F6C41: db $91
L1F6C42: db $78
L1F6C43: db $FA
L1F6C44: db $0A
L1F6C45: db $E7
L1F6C46: db $00
L1F6C47: db $03
L1F6C48: db $31
L1F6C49: db $6C
L1F6C4A: db $F5
L1F6C4B: db $1E
L1F6C4C: db $92
L1F6C4D: db $1E
L1F6C4E: db $F5
L1F6C4F: db $00
L1F6C50: db $92
L1F6C51: db $78
L1F6C52: db $FA
L1F6C53: db $0A
L1F6C54: db $F5
L1F6C55: db $1E
L1F6C56: db $94
L1F6C57: db $1E
L1F6C58: db $F5
L1F6C59: db $00
L1F6C5A: db $94
L1F6C5B: db $28
L1F6C5C: db $FA
L1F6C5D: db $0A
L1F6C5E: db $95
L1F6C5F: db $50
L1F6C60: db $ED
SndData_18_Ch4: db $E9
L1F6C62: db $88
L1F6C63: db $EC
L1F6C64: db $6F
L1F6C65: db $6C
L1F6C66: db $EC
L1F6C67: db $8E
L1F6C68: db $6C
L1F6C69: db $EC
L1F6C6A: db $CA
L1F6C6B: db $6C
L1F6C6C: db $E5
L1F6C6D: db $61
L1F6C6E: db $6C
L1F6C6F: db $E4
L1F6C70: db $61
L1F6C71: db $36
L1F6C72: db $50
L1F6C73: db $FA
L1F6C74: db $50
L1F6C75: db $36
L1F6C76: db $0A
L1F6C77: db $36
L1F6C78: db $78
L1F6C79: db $FA
L1F6C7A: db $1E
L1F6C7B: db $36
L1F6C7C: db $50
L1F6C7D: db $FA
L1F6C7E: db $50
L1F6C7F: db $36
L1F6C80: db $0A
L1F6C81: db $36
L1F6C82: db $50
L1F6C83: db $FA
L1F6C84: db $1E
L1F6C85: db $E4
L1F6C86: db $31
L1F6C87: db $21
L1F6C88: db $0A
L1F6C89: db $E4
L1F6C8A: db $53
L1F6C8B: db $11
L1F6C8C: db $1E
L1F6C8D: db $ED
L1F6C8E: db $E4
L1F6C8F: db $61
L1F6C90: db $36
L1F6C91: db $14
L1F6C92: db $E4
L1F6C93: db $31
L1F6C94: db $21
L1F6C95: db $14
L1F6C96: db $E4
L1F6C97: db $62
L1F6C98: db $24
L1F6C99: db $14
L1F6C9A: db $E4
L1F6C9B: db $31
L1F6C9C: db $21
L1F6C9D: db $28
L1F6C9E: db $21
L1F6C9F: db $14
L1F6CA0: db $E4
L1F6CA1: db $62
L1F6CA2: db $24
L1F6CA3: db $14
L1F6CA4: db $E4
L1F6CA5: db $31
L1F6CA6: db $21
L1F6CA7: db $14
L1F6CA8: db $E4
L1F6CA9: db $61
L1F6CAA: db $36
L1F6CAB: db $0A
L1F6CAC: db $36
L1F6CAD: db $0A
L1F6CAE: db $E4
L1F6CAF: db $31
L1F6CB0: db $21
L1F6CB1: db $14
L1F6CB2: db $E4
L1F6CB3: db $62
L1F6CB4: db $24
L1F6CB5: db $14
L1F6CB6: db $E4
L1F6CB7: db $31
L1F6CB8: db $21
L1F6CB9: db $28
L1F6CBA: db $21
L1F6CBB: db $14
L1F6CBC: db $E4
L1F6CBD: db $62
L1F6CBE: db $24
L1F6CBF: db $0A
L1F6CC0: db $E4
L1F6CC1: db $53
L1F6CC2: db $11
L1F6CC3: db $1E
L1F6CC4: db $E7
L1F6CC5: db $00
L1F6CC6: db $02
L1F6CC7: db $8E
L1F6CC8: db $6C
L1F6CC9: db $ED
L1F6CCA: db $E4
L1F6CCB: db $61
L1F6CCC: db $36
L1F6CCD: db $1E
L1F6CCE: db $36
L1F6CCF: db $78
L1F6CD0: db $FA
L1F6CD1: db $0A
L1F6CD2: db $E7
L1F6CD3: db $00
L1F6CD4: db $04
L1F6CD5: db $CA
L1F6CD6: db $6C
L1F6CD7: db $E4
L1F6CD8: db $61
L1F6CD9: db $36
L1F6CDA: db $0A
L1F6CDB: db $36
L1F6CDC: db $0A
L1F6CDD: db $E4
L1F6CDE: db $31
L1F6CDF: db $21
L1F6CE0: db $0A
L1F6CE1: db $E4
L1F6CE2: db $61
L1F6CE3: db $36
L1F6CE4: db $0A
L1F6CE5: db $E4
L1F6CE6: db $62
L1F6CE7: db $24
L1F6CE8: db $14
L1F6CE9: db $E4
L1F6CEA: db $53
L1F6CEB: db $11
L1F6CEC: db $0A
L1F6CED: db $E4
L1F6CEE: db $61
L1F6CEF: db $36
L1F6CF0: db $14
L1F6CF1: db $E4
L1F6CF2: db $31
L1F6CF3: db $21
L1F6CF4: db $0A
L1F6CF5: db $E4
L1F6CF6: db $61
L1F6CF7: db $36
L1F6CF8: db $14
L1F6CF9: db $E4
L1F6CFA: db $62
L1F6CFB: db $24
L1F6CFC: db $14
L1F6CFD: db $E4
L1F6CFE: db $53
L1F6CFF: db $11
L1F6D00: db $14
L1F6D01: db $E7
L1F6D02: db $00
L1F6D03: db $04
L1F6D04: db $D7
L1F6D05: db $6C
L1F6D06: db $ED
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
SndData_0B_Ch1: db $E4
L1F6D21: db $78
L1F6D22: db $E9
L1F6D23: db $11
L1F6D24: db $EE
L1F6D25: db $C0
L1F6D26: db $A7
L1F6D27: db $60
L1F6D28: db $FA
L1F6D29: db $08
L1F6D2A: db $80
L1F6D2B: db $A7
L1F6D2C: db $A7
L1F6D2D: db $A6
L1F6D2E: db $20
L1F6D2F: db $E4
L1F6D30: db $11
L1F6D31: db $82
L1F6D32: db $60
L1F6D33: db $E4
L1F6D34: db $78
L1F6D35: db $A7
L1F6D36: db $60
L1F6D37: db $FA
L1F6D38: db $08
L1F6D39: db $80
L1F6D3A: db $A7
L1F6D3B: db $A7
L1F6D3C: db $A9
L1F6D3D: db $20
L1F6D3E: db $E4
L1F6D3F: db $11
L1F6D40: db $82
L1F6D41: db $60
L1F6D42: db $E4
L1F6D43: db $78
L1F6D44: db $A7
L1F6D45: db $20
L1F6D46: db $A6
L1F6D47: db $10
L1F6D48: db $80
L1F6D49: db $A9
L1F6D4A: db $20
L1F6D4B: db $AA
L1F6D4C: db $10
L1F6D4D: db $80
L1F6D4E: db $AB
L1F6D4F: db $20
L1F6D50: db $AC
L1F6D51: db $10
L1F6D52: db $80
L1F6D53: db $AD
L1F6D54: db $40
L1F6D55: db $AE
L1F6D56: db $40
L1F6D57: db $FA
L1F6D58: db $40
L1F6D59: db $E4
L1F6D5A: db $11
L1F6D5B: db $85
L1F6D5C: db $30
L1F6D5D: db $E4
L1F6D5E: db $67
L1F6D5F: db $91
L1F6D60: db $08
L1F6D61: db $91
L1F6D62: db $91
L1F6D63: db $80
L1F6D64: db $91
L1F6D65: db $91
L1F6D66: db $91
L1F6D67: db $80
L1F6D68: db $91
L1F6D69: db $91
L1F6D6A: db $E5
L1F6D6B: db $20
L1F6D6C: db $6D
SndData_0B_Ch2: db $E4
L1F6D6E: db $58
L1F6D6F: db $E9
L1F6D70: db $22
L1F6D71: db $EE
L1F6D72: db $80
L1F6D73: db $96
L1F6D74: db $20
L1F6D75: db $94
L1F6D76: db $92
L1F6D77: db $96
L1F6D78: db $A0
L1F6D79: db $9A
L1F6D7A: db $9D
L1F6D7B: db $96
L1F6D7C: db $96
L1F6D7D: db $94
L1F6D7E: db $92
L1F6D7F: db $96
L1F6D80: db $A0
L1F6D81: db $9A
L1F6D82: db $9D
L1F6D83: db $A0
L1F6D84: db $9E
L1F6D85: db $9A
L1F6D86: db $10
L1F6D87: db $80
L1F6D88: db $A0
L1F6D89: db $20
L1F6D8A: db $9B
L1F6D8B: db $10
L1F6D8C: db $80
L1F6D8D: db $A2
L1F6D8E: db $20
L1F6D8F: db $9D
L1F6D90: db $10
L1F6D91: db $80
L1F6D92: db $A4
L1F6D93: db $40
L1F6D94: db $A9
L1F6D95: db $08
L1F6D96: db $AA
L1F6D97: db $A9
L1F6D98: db $A6
L1F6D99: db $A9
L1F6D9A: db $A3
L1F6D9B: db $A6
L1F6D9C: db $A0
L1F6D9D: db $A3
L1F6D9E: db $9D
L1F6D9F: db $A0
L1F6DA0: db $9B
L1F6DA1: db $9A
L1F6DA2: db $9D
L1F6DA3: db $A0
L1F6DA4: db $9A
L1F6DA5: db $96
L1F6DA6: db $A2
L1F6DA7: db $A0
L1F6DA8: db $9B
L1F6DA9: db $9E
L1F6DAA: db $9A
L1F6DAB: db $9B
L1F6DAC: db $97
L1F6DAD: db $9A
L1F6DAE: db $96
L1F6DAF: db $94
L1F6DB0: db $96
L1F6DB1: db $92
L1F6DB2: db $96
L1F6DB3: db $91
L1F6DB4: db $92
L1F6DB5: db $E5
L1F6DB6: db $6D
L1F6DB7: db $6D
SndData_0B_Ch3: db $E4
L1F6DB9: db $40
L1F6DBA: db $E9
L1F6DBB: db $44
L1F6DBC: db $F3
L1F6DBD: db $02
L1F6DBE: db $F5
L1F6DBF: db $19
L1F6DC0: db $EC
L1F6DC1: db $CF
L1F6DC2: db $6D
L1F6DC3: db $EC
L1F6DC4: db $E9
L1F6DC5: db $6D
L1F6DC6: db $EC
L1F6DC7: db $CF
L1F6DC8: db $6D
L1F6DC9: db $EC
L1F6DCA: db $F3
L1F6DCB: db $6D
L1F6DCC: db $E5
L1F6DCD: db $B8
L1F6DCE: db $6D
L1F6DCF: db $9B
L1F6DD0: db $08
L1F6DD1: db $96
L1F6DD2: db $9B
L1F6DD3: db $9D
L1F6DD4: db $9E
L1F6DD5: db $96
L1F6DD6: db $9E
L1F6DD7: db $9B
L1F6DD8: db $A2
L1F6DD9: db $9B
L1F6DDA: db $A0
L1F6DDB: db $9B
L1F6DDC: db $9E
L1F6DDD: db $9B
L1F6DDE: db $9A
L1F6DDF: db $9B
L1F6DE0: db $9D
L1F6DE1: db $96
L1F6DE2: db $9A
L1F6DE3: db $96
L1F6DE4: db $A0
L1F6DE5: db $96
L1F6DE6: db $9D
L1F6DE7: db $9E
L1F6DE8: db $ED
L1F6DE9: db $A6
L1F6DEA: db $08
L1F6DEB: db $9D
L1F6DEC: db $A3
L1F6DED: db $9D
L1F6DEE: db $A2
L1F6DEF: db $9D
L1F6DF0: db $9A
L1F6DF1: db $96
L1F6DF2: db $ED
L1F6DF3: db $A6
L1F6DF4: db $08
L1F6DF5: db $A7
L1F6DF6: db $A3
L1F6DF7: db $A6
L1F6DF8: db $A2
L1F6DF9: db $A3
L1F6DFA: db $A0
L1F6DFB: db $9A
L1F6DFC: db $A2
L1F6DFD: db $9E
L1F6DFE: db $9A
L1F6DFF: db $96
L1F6E00: db $A0
L1F6E01: db $9D
L1F6E02: db $9A
L1F6E03: db $94
L1F6E04: db $A3
L1F6E05: db $9D
L1F6E06: db $9A
L1F6E07: db $97
L1F6E08: db $A2
L1F6E09: db $9E
L1F6E0A: db $9B
L1F6E0B: db $96
L1F6E0C: db $A5
L1F6E0D: db $A2
L1F6E0E: db $9F
L1F6E0F: db $99
L1F6E10: db $A4
L1F6E11: db $A0
L1F6E12: db $9D
L1F6E13: db $98
L1F6E14: db $A7
L1F6E15: db $A4
L1F6E16: db $A1
L1F6E17: db $9B
L1F6E18: db $A4
L1F6E19: db $A1
L1F6E1A: db $9B
L1F6E1B: db $98
L1F6E1C: db $96
L1F6E1D: db $A2
L1F6E1E: db $A0
L1F6E1F: db $9B
L1F6E20: db $9D
L1F6E21: db $9A
L1F6E22: db $9B
L1F6E23: db $97
L1F6E24: db $9A
L1F6E25: db $96
L1F6E26: db $94
L1F6E27: db $96
L1F6E28: db $92
L1F6E29: db $96
L1F6E2A: db $91
L1F6E2B: db $92
L1F6E2C: db $96
L1F6E2D: db $40
L1F6E2E: db $FA
L1F6E2F: db $40
L1F6E30: db $ED
SndData_0B_Ch4: db $E9
L1F6E32: db $88
L1F6E33: db $EC
L1F6E34: db $39
L1F6E35: db $6E
L1F6E36: db $E5
L1F6E37: db $31
L1F6E38: db $6E
L1F6E39: db $E4
L1F6E3A: db $61
L1F6E3B: db $36
L1F6E3C: db $60
L1F6E3D: db $FA
L1F6E3E: db $10
L1F6E3F: db $36
L1F6E40: db $08
L1F6E41: db $36
L1F6E42: db $08
L1F6E43: db $E4
L1F6E44: db $54
L1F6E45: db $32
L1F6E46: db $30
L1F6E47: db $32
L1F6E48: db $08
L1F6E49: db $32
L1F6E4A: db $08
L1F6E4B: db $32
L1F6E4C: db $10
L1F6E4D: db $32
L1F6E4E: db $08
L1F6E4F: db $32
L1F6E50: db $08
L1F6E51: db $32
L1F6E52: db $10
L1F6E53: db $32
L1F6E54: db $08
L1F6E55: db $32
L1F6E56: db $08
L1F6E57: db $E7
L1F6E58: db $00
L1F6E59: db $02
L1F6E5A: db $39
L1F6E5B: db $6E
L1F6E5C: db $E4
L1F6E5D: db $44
L1F6E5E: db $32
L1F6E5F: db $30
L1F6E60: db $10
L1F6E61: db $08
L1F6E62: db $10
L1F6E63: db $08
L1F6E64: db $E7
L1F6E65: db $00
L1F6E66: db $04
L1F6E67: db $5C
L1F6E68: db $6E
L1F6E69: db $E4
L1F6E6A: db $61
L1F6E6B: db $36
L1F6E6C: db $60
L1F6E6D: db $FA
L1F6E6E: db $10
L1F6E6F: db $36
L1F6E70: db $08
L1F6E71: db $36
L1F6E72: db $08
L1F6E73: db $36
L1F6E74: db $30
L1F6E75: db $36
L1F6E76: db $08
L1F6E77: db $36
L1F6E78: db $08
L1F6E79: db $E4
L1F6E7A: db $54
L1F6E7B: db $32
L1F6E7C: db $10
L1F6E7D: db $E4
L1F6E7E: db $61
L1F6E7F: db $36
L1F6E80: db $10
L1F6E81: db $E4
L1F6E82: db $54
L1F6E83: db $32
L1F6E84: db $10
L1F6E85: db $E4
L1F6E86: db $61
L1F6E87: db $36
L1F6E88: db $10
L1F6E89: db $ED
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
SndData_0A_Ch1: db $E4
L1F6EA4: db $78
L1F6EA5: db $E9
L1F6EA6: db $11
L1F6EA7: db $EE
L1F6EA8: db $80
L1F6EA9: db $A7
L1F6EAA: db $30
L1F6EAB: db $A5
L1F6EAC: db $60
L1F6EAD: db $FA
L1F6EAE: db $18
L1F6EAF: db $80
L1F6EB0: db $A8
L1F6EB1: db $30
L1F6EB2: db $AA
L1F6EB3: db $60
L1F6EB4: db $FA
L1F6EB5: db $18
L1F6EB6: db $80
L1F6EB7: db $A7
L1F6EB8: db $30
L1F6EB9: db $A5
L1F6EBA: db $60
L1F6EBB: db $FA
L1F6EBC: db $18
L1F6EBD: db $80
L1F6EBE: db $A8
L1F6EBF: db $30
L1F6EC0: db $AA
L1F6EC1: db $60
L1F6EC2: db $AB
L1F6EC3: db $8B
L1F6EC4: db $0C
L1F6EC5: db $80
L1F6EC6: db $E5
L1F6EC7: db $C3
L1F6EC8: db $6E
SndData_0A_Ch2: db $E4
L1F6ECA: db $11
L1F6ECB: db $E9
L1F6ECC: db $22
L1F6ECD: db $EE
L1F6ECE: db $C0
L1F6ECF: db $81
L1F6ED0: db $30
L1F6ED1: db $E4
L1F6ED2: db $78
L1F6ED3: db $95
L1F6ED4: db $0C
L1F6ED5: db $99
L1F6ED6: db $9C
L1F6ED7: db $A0
L1F6ED8: db $30
L1F6ED9: db $FA
L1F6EDA: db $0C
L1F6EDB: db $FA
L1F6EDC: db $60
L1F6EDD: db $97
L1F6EDE: db $0C
L1F6EDF: db $99
L1F6EE0: db $9B
L1F6EE1: db $A0
L1F6EE2: db $30
L1F6EE3: db $FA
L1F6EE4: db $0C
L1F6EE5: db $FA
L1F6EE6: db $60
L1F6EE7: db $95
L1F6EE8: db $0C
L1F6EE9: db $99
L1F6EEA: db $9C
L1F6EEB: db $A0
L1F6EEC: db $30
L1F6EED: db $FA
L1F6EEE: db $0C
L1F6EEF: db $FA
L1F6EF0: db $60
L1F6EF1: db $97
L1F6EF2: db $0C
L1F6EF3: db $99
L1F6EF4: db $9B
L1F6EF5: db $A0
L1F6EF6: db $30
L1F6EF7: db $FA
L1F6EF8: db $0C
L1F6EF9: db $A1
L1F6EFA: db $60
L1F6EFB: db $8F
L1F6EFC: db $0C
L1F6EFD: db $80
L1F6EFE: db $E5
L1F6EFF: db $FB
L1F6F00: db $6E
SndData_0A_Ch3: db $E4
L1F6F02: db $40
L1F6F03: db $E9
L1F6F04: db $44
L1F6F05: db $F3
L1F6F06: db $02
L1F6F07: db $F5
L1F6F08: db $00
L1F6F09: db $8B
L1F6F0A: db $30
L1F6F0B: db $89
L1F6F0C: db $60
L1F6F0D: db $FA
L1F6F0E: db $60
L1F6F0F: db $8B
L1F6F10: db $60
L1F6F11: db $FA
L1F6F12: db $60
L1F6F13: db $89
L1F6F14: db $60
L1F6F15: db $FA
L1F6F16: db $60
L1F6F17: db $86
L1F6F18: db $60
L1F6F19: db $85
L1F6F1A: db $F5
L1F6F1B: db $32
L1F6F1C: db $81
L1F6F1D: db $18
L1F6F1E: db $E5
L1F6F1F: db $1C
L1F6F20: db $6F
SndData_0A_Ch4: db $E9
L1F6F22: db $88
L1F6F23: db $E4
L1F6F24: db $61
L1F6F25: db $36
L1F6F26: db $18
L1F6F27: db $36
L1F6F28: db $18
L1F6F29: db $EC
L1F6F2A: db $3B
L1F6F2B: db $6F
L1F6F2C: db $EC
L1F6F2D: db $69
L1F6F2E: db $6F
L1F6F2F: db $EC
L1F6F30: db $7A
L1F6F31: db $6F
L1F6F32: db $EC
L1F6F33: db $69
L1F6F34: db $6F
L1F6F35: db $EC
L1F6F36: db $8B
L1F6F37: db $6F
L1F6F38: db $E5
L1F6F39: db $2C
L1F6F3A: db $6F
L1F6F3B: db $E4
L1F6F3C: db $61
L1F6F3D: db $36
L1F6F3E: db $24
L1F6F3F: db $36
L1F6F40: db $06
L1F6F41: db $36
L1F6F42: db $06
L1F6F43: db $E4
L1F6F44: db $54
L1F6F45: db $26
L1F6F46: db $0C
L1F6F47: db $E4
L1F6F48: db $61
L1F6F49: db $36
L1F6F4A: db $0C
L1F6F4B: db $E4
L1F6F4C: db $54
L1F6F4D: db $26
L1F6F4E: db $0C
L1F6F4F: db $E4
L1F6F50: db $61
L1F6F51: db $36
L1F6F52: db $0C
L1F6F53: db $E4
L1F6F54: db $54
L1F6F55: db $26
L1F6F56: db $0C
L1F6F57: db $E4
L1F6F58: db $61
L1F6F59: db $36
L1F6F5A: db $0C
L1F6F5B: db $36
L1F6F5C: db $18
L1F6F5D: db $E4
L1F6F5E: db $54
L1F6F5F: db $26
L1F6F60: db $18
L1F6F61: db $32
L1F6F62: db $18
L1F6F63: db $E7
L1F6F64: db $00
L1F6F65: db $04
L1F6F66: db $3B
L1F6F67: db $6F
L1F6F68: db $ED
L1F6F69: db $E4
L1F6F6A: db $54
L1F6F6B: db $26
L1F6F6C: db $0C
L1F6F6D: db $E4
L1F6F6E: db $61
L1F6F6F: db $36
L1F6F70: db $3C
L1F6F71: db $E4
L1F6F72: db $54
L1F6F73: db $26
L1F6F74: db $0C
L1F6F75: db $E4
L1F6F76: db $61
L1F6F77: db $36
L1F6F78: db $0C
L1F6F79: db $ED
L1F6F7A: db $E4
L1F6F7B: db $61
L1F6F7C: db $36
L1F6F7D: db $06
L1F6F7E: db $36
L1F6F7F: db $06
L1F6F80: db $E4
L1F6F81: db $54
L1F6F82: db $26
L1F6F83: db $18
L1F6F84: db $E4
L1F6F85: db $53
L1F6F86: db $11
L1F6F87: db $24
L1F6F88: db $11
L1F6F89: db $18
L1F6F8A: db $ED
L1F6F8B: db $E4
L1F6F8C: db $61
L1F6F8D: db $36
L1F6F8E: db $06
L1F6F8F: db $36
L1F6F90: db $06
L1F6F91: db $E4
L1F6F92: db $54
L1F6F93: db $26
L1F6F94: db $18
L1F6F95: db $E4
L1F6F96: db $61
L1F6F97: db $36
L1F6F98: db $0C
L1F6F99: db $E4
L1F6F9A: db $54
L1F6F9B: db $26
L1F6F9C: db $0C
L1F6F9D: db $E4
L1F6F9E: db $61
L1F6F9F: db $36
L1F6FA0: db $0C
L1F6FA1: db $36
L1F6FA2: db $0C
L1F6FA3: db $E4
L1F6FA4: db $54
L1F6FA5: db $26
L1F6FA6: db $0C
L1F6FA7: db $ED
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
SndData_09_Ch1: db $E4
L1F6FC2: db $11
L1F6FC3: db $E9
L1F6FC4: db $11
L1F6FC5: db $EE
L1F6FC6: db $80
L1F6FC7: db $8A
L1F6FC8: db $0E
L1F6FC9: db $EC
L1F6FCA: db $DC
L1F6FCB: db $6F
L1F6FCC: db $EC
L1F6FCD: db $09
L1F6FCE: db $70
L1F6FCF: db $EC
L1F6FD0: db $39
L1F6FD1: db $70
L1F6FD2: db $E6
L1F6FD3: db $0C
L1F6FD4: db $EC
L1F6FD5: db $09
L1F6FD6: db $70
L1F6FD7: db $E6
L1F6FD8: db $F4
L1F6FD9: db $E5
L1F6FDA: db $C9
L1F6FDB: db $6F
L1F6FDC: db $E4
L1F6FDD: db $11
L1F6FDE: db $8A
L1F6FDF: db $1C
L1F6FE0: db $E4
L1F6FE1: db $68
L1F6FE2: db $9D
L1F6FE3: db $0E
L1F6FE4: db $A0
L1F6FE5: db $1C
L1F6FE6: db $9F
L1F6FE7: db $9D
L1F6FE8: db $07
L1F6FE9: db $9B
L1F6FEA: db $9D
L1F6FEB: db $54
L1F6FEC: db $80
L1F6FED: db $1C
L1F6FEE: db $9B
L1F6FEF: db $54
L1F6FF0: db $80
L1F6FF1: db $0E
L1F6FF2: db $99
L1F6FF3: db $07
L1F6FF4: db $98
L1F6FF5: db $99
L1F6FF6: db $54
L1F6FF7: db $80
L1F6FF8: db $2A
L1F6FF9: db $9D
L1F6FFA: db $0E
L1F6FFB: db $A2
L1F6FFC: db $A5
L1F6FFD: db $1C
L1F6FFE: db $A4
L1F6FFF: db $A2
L1F7000: db $07
L1F7001: db $A0
L1F7002: db $9F
L1F7003: db $70
L1F7004: db $FA
L1F7005: db $70
L1F7006: db $FA
L1F7007: db $70
L1F7008: db $ED
L1F7009: db $80
L1F700A: db $0E
L1F700B: db $99
L1F700C: db $96
L1F700D: db $99
L1F700E: db $98
L1F700F: db $07
L1F7010: db $80
L1F7011: db $91
L1F7012: db $1C
L1F7013: db $80
L1F7014: db $0E
L1F7015: db $80
L1F7016: db $0E
L1F7017: db $99
L1F7018: db $96
L1F7019: db $99
L1F701A: db $98
L1F701B: db $07
L1F701C: db $80
L1F701D: db $91
L1F701E: db $1C
L1F701F: db $80
L1F7020: db $0E
L1F7021: db $80
L1F7022: db $0E
L1F7023: db $99
L1F7024: db $96
L1F7025: db $99
L1F7026: db $98
L1F7027: db $91
L1F7028: db $9B
L1F7029: db $98
L1F702A: db $99
L1F702B: db $98
L1F702C: db $2A
L1F702D: db $96
L1F702E: db $0E
L1F702F: db $94
L1F7030: db $1C
L1F7031: db $80
L1F7032: db $0E
L1F7033: db $E7
L1F7034: db $00
L1F7035: db $02
L1F7036: db $09
L1F7037: db $70
L1F7038: db $ED
L1F7039: db $80
L1F703A: db $0E
L1F703B: db $AA
L1F703C: db $A7
L1F703D: db $AA
L1F703E: db $A9
L1F703F: db $07
L1F7040: db $80
L1F7041: db $A6
L1F7042: db $1C
L1F7043: db $80
L1F7044: db $0E
L1F7045: db $80
L1F7046: db $AA
L1F7047: db $A7
L1F7048: db $AA
L1F7049: db $A9
L1F704A: db $07
L1F704B: db $80
L1F704C: db $A6
L1F704D: db $1C
L1F704E: db $80
L1F704F: db $0E
L1F7050: db $80
L1F7051: db $AA
L1F7052: db $A7
L1F7053: db $AA
L1F7054: db $A9
L1F7055: db $A2
L1F7056: db $B1
L1F7057: db $AC
L1F7058: db $AF
L1F7059: db $AE
L1F705A: db $2A
L1F705B: db $AC
L1F705C: db $0E
L1F705D: db $AB
L1F705E: db $1C
L1F705F: db $80
L1F7060: db $0E
L1F7061: db $ED
SndData_09_Ch2: db $E4
L1F7063: db $78
L1F7064: db $E9
L1F7065: db $22
L1F7066: db $EE
L1F7067: db $C0
L1F7068: db $8D
L1F7069: db $07
L1F706A: db $8D
L1F706B: db $EC
L1F706C: db $83
L1F706D: db $70
L1F706E: db $EC
L1F706F: db $BA
L1F7070: db $70
L1F7071: db $E4
L1F7072: db $38
L1F7073: db $EE
L1F7074: db $80
L1F7075: db $80
L1F7076: db $0A
L1F7077: db $EC
L1F7078: db $09
L1F7079: db $70
L1F707A: db $EC
L1F707B: db $D7
L1F707C: db $70
L1F707D: db $EC
L1F707E: db $00
L1F707F: db $71
L1F7080: db $E5
L1F7081: db $6B
L1F7082: db $70
L1F7083: db $8D
L1F7084: db $54
L1F7085: db $FA
L1F7086: db $0E
L1F7087: db $8D
L1F7088: db $07
L1F7089: db $8D
L1F708A: db $8D
L1F708B: db $1C
L1F708C: db $8D
L1F708D: db $04
L1F708E: db $80
L1F708F: db $0A
L1F7090: db $A2
L1F7091: db $2A
L1F7092: db $8D
L1F7093: db $04
L1F7094: db $80
L1F7095: db $0A
L1F7096: db $8D
L1F7097: db $07
L1F7098: db $8D
L1F7099: db $8D
L1F709A: db $1C
L1F709B: db $8D
L1F709C: db $04
L1F709D: db $80
L1F709E: db $0A
L1F709F: db $A5
L1F70A0: db $2A
L1F70A1: db $8D
L1F70A2: db $04
L1F70A3: db $80
L1F70A4: db $0A
L1F70A5: db $8D
L1F70A6: db $07
L1F70A7: db $8D
L1F70A8: db $8D
L1F70A9: db $1C
L1F70AA: db $8D
L1F70AB: db $04
L1F70AC: db $80
L1F70AD: db $0A
L1F70AE: db $A7
L1F70AF: db $2A
L1F70B0: db $8D
L1F70B1: db $04
L1F70B2: db $80
L1F70B3: db $0A
L1F70B4: db $8D
L1F70B5: db $07
L1F70B6: db $8D
L1F70B7: db $8D
L1F70B8: db $70
L1F70B9: db $ED
L1F70BA: db $E4
L1F70BB: db $62
L1F70BC: db $9B
L1F70BD: db $05
L1F70BE: db $9F
L1F70BF: db $04
L1F70C0: db $A2
L1F70C1: db $05
L1F70C2: db $A5
L1F70C3: db $A7
L1F70C4: db $04
L1F70C5: db $A8
L1F70C6: db $05
L1F70C7: db $AB
L1F70C8: db $A8
L1F70C9: db $04
L1F70CA: db $A7
L1F70CB: db $05
L1F70CC: db $A5
L1F70CD: db $A2
L1F70CE: db $04
L1F70CF: db $9F
L1F70D0: db $05
L1F70D1: db $E7
L1F70D2: db $00
L1F70D3: db $06
L1F70D4: db $BA
L1F70D5: db $70
L1F70D6: db $ED
L1F70D7: db $80
L1F70D8: db $0E
L1F70D9: db $AA
L1F70DA: db $A7
L1F70DB: db $AA
L1F70DC: db $A9
L1F70DD: db $07
L1F70DE: db $80
L1F70DF: db $A6
L1F70E0: db $1C
L1F70E1: db $80
L1F70E2: db $0E
L1F70E3: db $80
L1F70E4: db $AA
L1F70E5: db $A7
L1F70E6: db $AA
L1F70E7: db $A9
L1F70E8: db $07
L1F70E9: db $80
L1F70EA: db $A6
L1F70EB: db $1C
L1F70EC: db $80
L1F70ED: db $0E
L1F70EE: db $80
L1F70EF: db $AA
L1F70F0: db $A7
L1F70F1: db $AA
L1F70F2: db $A9
L1F70F3: db $A2
L1F70F4: db $B1
L1F70F5: db $AC
L1F70F6: db $AF
L1F70F7: db $AE
L1F70F8: db $2A
L1F70F9: db $AC
L1F70FA: db $0E
L1F70FB: db $AB
L1F70FC: db $1C
L1F70FD: db $80
L1F70FE: db $04
L1F70FF: db $ED
L1F7100: db $E4
L1F7101: db $78
L1F7102: db $EE
L1F7103: db $C0
L1F7104: db $9D
L1F7105: db $54
L1F7106: db $FA
L1F7107: db $0E
L1F7108: db $9D
L1F7109: db $07
L1F710A: db $9D
L1F710B: db $9D
L1F710C: db $54
L1F710D: db $FA
L1F710E: db $0E
L1F710F: db $9D
L1F7110: db $07
L1F7111: db $9D
L1F7112: db $9E
L1F7113: db $54
L1F7114: db $FA
L1F7115: db $0E
L1F7116: db $9E
L1F7117: db $07
L1F7118: db $9E
L1F7119: db $A0
L1F711A: db $54
L1F711B: db $FA
L1F711C: db $0E
L1F711D: db $A0
L1F711E: db $07
L1F711F: db $A0
L1F7120: db $E7
L1F7121: db $00
L1F7122: db $02
L1F7123: db $00
L1F7124: db $71
L1F7125: db $ED
SndData_09_Ch3: db $E4
L1F7127: db $40
L1F7128: db $E9
L1F7129: db $44
L1F712A: db $F3
L1F712B: db $04
L1F712C: db $F5
L1F712D: db $19
L1F712E: db $96
L1F712F: db $07
L1F7130: db $96
L1F7131: db $EC
L1F7132: db $40
L1F7133: db $71
L1F7134: db $EC
L1F7135: db $82
L1F7136: db $71
L1F7137: db $EC
L1F7138: db $82
L1F7139: db $71
L1F713A: db $EC
L1F713B: db $8F
L1F713C: db $71
L1F713D: db $E5
L1F713E: db $31
L1F713F: db $71
L1F7140: db $F5
L1F7141: db $00
L1F7142: db $96
L1F7143: db $54
L1F7144: db $FA
L1F7145: db $0E
L1F7146: db $F5
L1F7147: db $19
L1F7148: db $96
L1F7149: db $07
L1F714A: db $96
L1F714B: db $F5
L1F714C: db $00
L1F714D: db $96
L1F714E: db $2A
L1F714F: db $A6
L1F7150: db $38
L1F7151: db $F5
L1F7152: db $19
L1F7153: db $96
L1F7154: db $07
L1F7155: db $96
L1F7156: db $F5
L1F7157: db $00
L1F7158: db $96
L1F7159: db $2A
L1F715A: db $96
L1F715B: db $1C
L1F715C: db $99
L1F715D: db $F5
L1F715E: db $19
L1F715F: db $96
L1F7160: db $07
L1F7161: db $96
L1F7162: db $F5
L1F7163: db $00
L1F7164: db $96
L1F7165: db $2A
L1F7166: db $96
L1F7167: db $1C
L1F7168: db $99
L1F7169: db $F5
L1F716A: db $19
L1F716B: db $94
L1F716C: db $07
L1F716D: db $95
L1F716E: db $F5
L1F716F: db $00
L1F7170: db $96
L1F7171: db $54
L1F7172: db $FA
L1F7173: db $0E
L1F7174: db $F5
L1F7175: db $19
L1F7176: db $96
L1F7177: db $07
L1F7178: db $96
L1F7179: db $F5
L1F717A: db $00
L1F717B: db $A7
L1F717C: db $70
L1F717D: db $FA
L1F717E: db $70
L1F717F: db $FA
L1F7180: db $70
L1F7181: db $ED
L1F7182: db $F5
L1F7183: db $32
L1F7184: db $96
L1F7185: db $1C
L1F7186: db $E7
L1F7187: db $00
L1F7188: db $0F
L1F7189: db $82
L1F718A: db $71
L1F718B: db $96
L1F718C: db $0E
L1F718D: db $91
L1F718E: db $ED
L1F718F: db $94
L1F7190: db $1C
L1F7191: db $94
L1F7192: db $94
L1F7193: db $94
L1F7194: db $94
L1F7195: db $94
L1F7196: db $94
L1F7197: db $94
L1F7198: db $0E
L1F7199: db $8F
L1F719A: db $F5
L1F719B: db $19
L1F719C: db $94
L1F719D: db $07
L1F719E: db $E7
L1F719F: db $00
L1F71A0: db $20
L1F71A1: db $9C
L1F71A2: db $71
L1F71A3: db $F5
L1F71A4: db $00
L1F71A5: db $96
L1F71A6: db $54
L1F71A7: db $FA
L1F71A8: db $0E
L1F71A9: db $F5
L1F71AA: db $19
L1F71AB: db $96
L1F71AC: db $07
L1F71AD: db $96
L1F71AE: db $E7
L1F71AF: db $00
L1F71B0: db $04
L1F71B1: db $A3
L1F71B2: db $71
L1F71B3: db $F5
L1F71B4: db $19
L1F71B5: db $96
L1F71B6: db $0E
L1F71B7: db $96
L1F71B8: db $07
L1F71B9: db $96
L1F71BA: db $F5
L1F71BB: db $00
L1F71BC: db $96
L1F71BD: db $2A
L1F71BE: db $F5
L1F71BF: db $19
L1F71C0: db $96
L1F71C1: db $07
L1F71C2: db $96
L1F71C3: db $96
L1F71C4: db $0E
L1F71C5: db $96
L1F71C6: db $07
L1F71C7: db $96
L1F71C8: db $E7
L1F71C9: db $00
L1F71CA: db $04
L1F71CB: db $B3
L1F71CC: db $71
L1F71CD: db $ED
SndData_09_Ch4: db $E9
L1F71CF: db $88
L1F71D0: db $E4
L1F71D1: db $54
L1F71D2: db $26
L1F71D3: db $07
L1F71D4: db $32
L1F71D5: db $07
L1F71D6: db $EC
L1F71D7: db $FE
L1F71D8: db $71
L1F71D9: db $EC
L1F71DA: db $1B
L1F71DB: db $72
L1F71DC: db $EC
L1F71DD: db $FE
L1F71DE: db $71
L1F71DF: db $EC
L1F71E0: db $3A
L1F71E1: db $72
L1F71E2: db $EC
L1F71E3: db $FE
L1F71E4: db $71
L1F71E5: db $E4
L1F71E6: db $61
L1F71E7: db $36
L1F71E8: db $1C
L1F71E9: db $36
L1F71EA: db $1C
L1F71EB: db $36
L1F71EC: db $1C
L1F71ED: db $36
L1F71EE: db $1C
L1F71EF: db $EC
L1F71F0: db $59
L1F71F1: db $72
L1F71F2: db $EC
L1F71F3: db $BE
L1F71F4: db $72
L1F71F5: db $EC
L1F71F6: db $59
L1F71F7: db $72
L1F71F8: db $EC
L1F71F9: db $D8
L1F71FA: db $72
L1F71FB: db $E5
L1F71FC: db $D6
L1F71FD: db $71
L1F71FE: db $E4
L1F71FF: db $61
L1F7200: db $36
L1F7201: db $0E
L1F7202: db $E4
L1F7203: db $31
L1F7204: db $21
L1F7205: db $0E
L1F7206: db $E4
L1F7207: db $62
L1F7208: db $24
L1F7209: db $0E
L1F720A: db $E4
L1F720B: db $31
L1F720C: db $21
L1F720D: db $1C
L1F720E: db $E4
L1F720F: db $61
L1F7210: db $36
L1F7211: db $0E
L1F7212: db $E4
L1F7213: db $62
L1F7214: db $24
L1F7215: db $0E
L1F7216: db $E4
L1F7217: db $53
L1F7218: db $11
L1F7219: db $0E
L1F721A: db $ED
L1F721B: db $E4
L1F721C: db $31
L1F721D: db $21
L1F721E: db $0E
L1F721F: db $E4
L1F7220: db $62
L1F7221: db $24
L1F7222: db $07
L1F7223: db $24
L1F7224: db $07
L1F7225: db $E4
L1F7226: db $61
L1F7227: db $36
L1F7228: db $2A
L1F7229: db $36
L1F722A: db $07
L1F722B: db $36
L1F722C: db $07
L1F722D: db $E4
L1F722E: db $44
L1F722F: db $26
L1F7230: db $07
L1F7231: db $10
L1F7232: db $07
L1F7233: db $E4
L1F7234: db $54
L1F7235: db $26
L1F7236: db $07
L1F7237: db $32
L1F7238: db $07
L1F7239: db $ED
L1F723A: db $E4
L1F723B: db $31
L1F723C: db $21
L1F723D: db $0E
L1F723E: db $E4
L1F723F: db $62
L1F7240: db $24
L1F7241: db $07
L1F7242: db $24
L1F7243: db $07
L1F7244: db $E4
L1F7245: db $61
L1F7246: db $36
L1F7247: db $1C
L1F7248: db $E4
L1F7249: db $31
L1F724A: db $21
L1F724B: db $0E
L1F724C: db $E4
L1F724D: db $61
L1F724E: db $36
L1F724F: db $0E
L1F7250: db $E4
L1F7251: db $62
L1F7252: db $24
L1F7253: db $0E
L1F7254: db $E4
L1F7255: db $61
L1F7256: db $36
L1F7257: db $0E
L1F7258: db $ED
L1F7259: db $E4
L1F725A: db $61
L1F725B: db $36
L1F725C: db $07
L1F725D: db $E4
L1F725E: db $22
L1F725F: db $24
L1F7260: db $07
L1F7261: db $24
L1F7262: db $07
L1F7263: db $24
L1F7264: db $07
L1F7265: db $E4
L1F7266: db $61
L1F7267: db $36
L1F7268: db $07
L1F7269: db $E4
L1F726A: db $22
L1F726B: db $24
L1F726C: db $07
L1F726D: db $24
L1F726E: db $07
L1F726F: db $E4
L1F7270: db $42
L1F7271: db $24
L1F7272: db $07
L1F7273: db $E4
L1F7274: db $61
L1F7275: db $36
L1F7276: db $07
L1F7277: db $E4
L1F7278: db $42
L1F7279: db $24
L1F727A: db $07
L1F727B: db $24
L1F727C: db $07
L1F727D: db $24
L1F727E: db $07
L1F727F: db $E4
L1F7280: db $61
L1F7281: db $36
L1F7282: db $07
L1F7283: db $E4
L1F7284: db $62
L1F7285: db $24
L1F7286: db $07
L1F7287: db $24
L1F7288: db $07
L1F7289: db $24
L1F728A: db $07
L1F728B: db $E4
L1F728C: db $62
L1F728D: db $24
L1F728E: db $0E
L1F728F: db $E4
L1F7290: db $44
L1F7291: db $26
L1F7292: db $0E
L1F7293: db $E4
L1F7294: db $62
L1F7295: db $24
L1F7296: db $07
L1F7297: db $24
L1F7298: db $07
L1F7299: db $E4
L1F729A: db $61
L1F729B: db $36
L1F729C: db $07
L1F729D: db $36
L1F729E: db $07
L1F729F: db $E4
L1F72A0: db $54
L1F72A1: db $26
L1F72A2: db $07
L1F72A3: db $32
L1F72A4: db $07
L1F72A5: db $E4
L1F72A6: db $61
L1F72A7: db $36
L1F72A8: db $07
L1F72A9: db $E4
L1F72AA: db $62
L1F72AB: db $24
L1F72AC: db $07
L1F72AD: db $24
L1F72AE: db $07
L1F72AF: db $24
L1F72B0: db $07
L1F72B1: db $E4
L1F72B2: db $44
L1F72B3: db $26
L1F72B4: db $05
L1F72B5: db $E4
L1F72B6: db $34
L1F72B7: db $26
L1F72B8: db $04
L1F72B9: db $E4
L1F72BA: db $54
L1F72BB: db $26
L1F72BC: db $05
L1F72BD: db $ED
L1F72BE: db $E4
L1F72BF: db $61
L1F72C0: db $36
L1F72C1: db $0E
L1F72C2: db $E4
L1F72C3: db $53
L1F72C4: db $11
L1F72C5: db $0E
L1F72C6: db $E4
L1F72C7: db $61
L1F72C8: db $36
L1F72C9: db $07
L1F72CA: db $E4
L1F72CB: db $31
L1F72CC: db $21
L1F72CD: db $07
L1F72CE: db $E4
L1F72CF: db $53
L1F72D0: db $11
L1F72D1: db $0E
L1F72D2: db $E7
L1F72D3: db $00
L1F72D4: db $14
L1F72D5: db $BE
L1F72D6: db $72
L1F72D7: db $ED
L1F72D8: db $E4
L1F72D9: db $61
L1F72DA: db $36
L1F72DB: db $0E
L1F72DC: db $E4
L1F72DD: db $53
L1F72DE: db $11
L1F72DF: db $0E
L1F72E0: db $E4
L1F72E1: db $62
L1F72E2: db $24
L1F72E3: db $07
L1F72E4: db $E4
L1F72E5: db $31
L1F72E6: db $21
L1F72E7: db $07
L1F72E8: db $E4
L1F72E9: db $53
L1F72EA: db $11
L1F72EB: db $1C
L1F72EC: db $E4
L1F72ED: db $61
L1F72EE: db $36
L1F72EF: db $0E
L1F72F0: db $E4
L1F72F1: db $62
L1F72F2: db $24
L1F72F3: db $07
L1F72F4: db $E4
L1F72F5: db $31
L1F72F6: db $21
L1F72F7: db $07
L1F72F8: db $E4
L1F72F9: db $53
L1F72FA: db $11
L1F72FB: db $0E
L1F72FC: db $E7
L1F72FD: db $00
L1F72FE: db $08
L1F72FF: db $D8
L1F7300: db $72
L1F7301: db $ED
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
SndData_07_Ch1: db $E4
L1F731C: db $72
L1F731D: db $E9
L1F731E: db $11
L1F731F: db $EE
L1F7320: db $80
L1F7321: db $EC
L1F7322: db $42
L1F7323: db $73
L1F7324: db $EC
L1F7325: db $56
L1F7326: db $73
L1F7327: db $EC
L1F7328: db $6A
L1F7329: db $73
L1F732A: db $EC
L1F732B: db $C5
L1F732C: db $73
L1F732D: db $EC
L1F732E: db $DE
L1F732F: db $73
L1F7330: db $EC
L1F7331: db $F9
L1F7332: db $73
L1F7333: db $EC
L1F7334: db $DE
L1F7335: db $73
L1F7336: db $EC
L1F7337: db $15
L1F7338: db $74
L1F7339: db $EC
L1F733A: db $30
L1F733B: db $74
L1F733C: db $EC
L1F733D: db $7D
L1F733E: db $74
L1F733F: db $E5
L1F7340: db $1B
L1F7341: db $73
L1F7342: db $9A
L1F7343: db $07
L1F7344: db $A0
L1F7345: db $9A
L1F7346: db $A0
L1F7347: db $0E
L1F7348: db $9A
L1F7349: db $07
L1F734A: db $9F
L1F734B: db $0E
L1F734C: db $96
L1F734D: db $07
L1F734E: db $9F
L1F734F: db $96
L1F7350: db $96
L1F7351: db $9F
L1F7352: db $9F
L1F7353: db $96
L1F7354: db $9B
L1F7355: db $ED
L1F7356: db $9A
L1F7357: db $07
L1F7358: db $A0
L1F7359: db $9A
L1F735A: db $A0
L1F735B: db $0E
L1F735C: db $9A
L1F735D: db $07
L1F735E: db $9F
L1F735F: db $0E
L1F7360: db $96
L1F7361: db $07
L1F7362: db $A2
L1F7363: db $A2
L1F7364: db $9D
L1F7365: db $A1
L1F7366: db $9D
L1F7367: db $9E
L1F7368: db $98
L1F7369: db $ED
L1F736A: db $E4
L1F736B: db $11
L1F736C: db $EE
L1F736D: db $C0
L1F736E: db $8A
L1F736F: db $1C
L1F7370: db $E4
L1F7371: db $78
L1F7372: db $96
L1F7373: db $07
L1F7374: db $99
L1F7375: db $9D
L1F7376: db $A0
L1F7377: db $80
L1F7378: db $0E
L1F7379: db $A2
L1F737A: db $1C
L1F737B: db $9D
L1F737C: db $07
L1F737D: db $80
L1F737E: db $9F
L1F737F: db $15
L1F7380: db $9B
L1F7381: db $07
L1F7382: db $80
L1F7383: db $0E
L1F7384: db $96
L1F7385: db $1C
L1F7386: db $9B
L1F7387: db $96
L1F7388: db $07
L1F7389: db $80
L1F738A: db $99
L1F738B: db $15
L1F738C: db $9B
L1F738D: db $07
L1F738E: db $E4
L1F738F: db $11
L1F7390: db $83
L1F7391: db $1C
L1F7392: db $FA
L1F7393: db $15
L1F7394: db $E4
L1F7395: db $78
L1F7396: db $92
L1F7397: db $0E
L1F7398: db $96
L1F7399: db $07
L1F739A: db $99
L1F739B: db $80
L1F739C: db $9B
L1F739D: db $15
L1F739E: db $99
L1F739F: db $07
L1F73A0: db $E4
L1F73A1: db $11
L1F73A2: db $81
L1F73A3: db $70
L1F73A4: db $E4
L1F73A5: db $78
L1F73A6: db $96
L1F73A7: db $07
L1F73A8: db $99
L1F73A9: db $9D
L1F73AA: db $A0
L1F73AB: db $80
L1F73AC: db $0E
L1F73AD: db $A2
L1F73AE: db $1C
L1F73AF: db $9D
L1F73B0: db $07
L1F73B1: db $80
L1F73B2: db $9F
L1F73B3: db $15
L1F73B4: db $9B
L1F73B5: db $07
L1F73B6: db $80
L1F73B7: db $0E
L1F73B8: db $96
L1F73B9: db $80
L1F73BA: db $9B
L1F73BB: db $96
L1F73BC: db $07
L1F73BD: db $9B
L1F73BE: db $80
L1F73BF: db $96
L1F73C0: db $9B
L1F73C1: db $15
L1F73C2: db $99
L1F73C3: db $0E
L1F73C4: db $ED
L1F73C5: db $E4
L1F73C6: db $11
L1F73C7: db $81
L1F73C8: db $07
L1F73C9: db $E4
L1F73CA: db $72
L1F73CB: db $EE
L1F73CC: db $80
L1F73CD: db $94
L1F73CE: db $15
L1F73CF: db $91
L1F73D0: db $95
L1F73D1: db $1C
L1F73D2: db $8F
L1F73D3: db $07
L1F73D4: db $91
L1F73D5: db $0E
L1F73D6: db $91
L1F73D7: db $15
L1F73D8: db $94
L1F73D9: db $96
L1F73DA: db $95
L1F73DB: db $0E
L1F73DC: db $94
L1F73DD: db $ED
L1F73DE: db $E4
L1F73DF: db $78
L1F73E0: db $EE
L1F73E1: db $C0
L1F73E2: db $9B
L1F73E3: db $15
L1F73E4: db $9D
L1F73E5: db $23
L1F73E6: db $80
L1F73E7: db $0E
L1F73E8: db $9B
L1F73E9: db $03
L1F73EA: db $9D
L1F73EB: db $04
L1F73EC: db $A0
L1F73ED: db $23
L1F73EE: db $FA
L1F73EF: db $1C
L1F73F0: db $80
L1F73F1: db $0E
L1F73F2: db $A0
L1F73F3: db $1C
L1F73F4: db $A2
L1F73F5: db $A0
L1F73F6: db $07
L1F73F7: db $80
L1F73F8: db $ED
L1F73F9: db $9F
L1F73FA: db $0E
L1F73FB: db $80
L1F73FC: db $07
L1F73FD: db $9B
L1F73FE: db $23
L1F73FF: db $80
L1F7400: db $15
L1F7401: db $93
L1F7402: db $0E
L1F7403: db $94
L1F7404: db $07
L1F7405: db $96
L1F7406: db $97
L1F7407: db $FA
L1F7408: db $15
L1F7409: db $96
L1F740A: db $92
L1F740B: db $0E
L1F740C: db $80
L1F740D: db $9B
L1F740E: db $80
L1F740F: db $07
L1F7410: db $9B
L1F7411: db $0E
L1F7412: db $91
L1F7413: db $07
L1F7414: db $ED
L1F7415: db $9F
L1F7416: db $0E
L1F7417: db $80
L1F7418: db $07
L1F7419: db $9B
L1F741A: db $23
L1F741B: db $80
L1F741C: db $15
L1F741D: db $9E
L1F741E: db $0E
L1F741F: db $A0
L1F7420: db $07
L1F7421: db $A2
L1F7422: db $A3
L1F7423: db $FA
L1F7424: db $15
L1F7425: db $A2
L1F7426: db $A1
L1F7427: db $9D
L1F7428: db $0A
L1F7429: db $80
L1F742A: db $0B
L1F742B: db $98
L1F742C: db $07
L1F742D: db $9B
L1F742E: db $15
L1F742F: db $ED
L1F7430: db $9D
L1F7431: db $38
L1F7432: db $80
L1F7433: db $0E
L1F7434: db $A0
L1F7435: db $80
L1F7436: db $07
L1F7437: db $9E
L1F7438: db $15
L1F7439: db $9D
L1F743A: db $1C
L1F743B: db $80
L1F743C: db $0E
L1F743D: db $98
L1F743E: db $1C
L1F743F: db $80
L1F7440: db $07
L1F7441: db $99
L1F7442: db $15
L1F7443: db $9B
L1F7444: db $0E
L1F7445: db $9B
L1F7446: db $9D
L1F7447: db $07
L1F7448: db $9D
L1F7449: db $1C
L1F744A: db $80
L1F744B: db $0E
L1F744C: db $94
L1F744D: db $02
L1F744E: db $A0
L1F744F: db $03
L1F7450: db $A1
L1F7451: db $02
L1F7452: db $A2
L1F7453: db $1C
L1F7454: db $96
L1F7455: db $0E
L1F7456: db $9B
L1F7457: db $8F
L1F7458: db $07
L1F7459: db $99
L1F745A: db $15
L1F745B: db $96
L1F745C: db $1C
L1F745D: db $80
L1F745E: db $0E
L1F745F: db $94
L1F7460: db $05
L1F7461: db $96
L1F7462: db $04
L1F7463: db $98
L1F7464: db $05
L1F7465: db $99
L1F7466: db $9B
L1F7467: db $04
L1F7468: db $9D
L1F7469: db $05
L1F746A: db $99
L1F746B: db $1C
L1F746C: db $80
L1F746D: db $0E
L1F746E: db $99
L1F746F: db $1C
L1F7470: db $9E
L1F7471: db $0E
L1F7472: db $96
L1F7473: db $1C
L1F7474: db $98
L1F7475: db $80
L1F7476: db $0E
L1F7477: db $9D
L1F7478: db $1C
L1F7479: db $9B
L1F747A: db $15
L1F747B: db $94
L1F747C: db $ED
L1F747D: db $99
L1F747E: db $0E
L1F747F: db $80
L1F7480: db $07
L1F7481: db $9B
L1F7482: db $23
L1F7483: db $80
L1F7484: db $07
L1F7485: db $9D
L1F7486: db $02
L1F7487: db $9E
L1F7488: db $03
L1F7489: db $9F
L1F748A: db $02
L1F748B: db $A0
L1F748C: db $23
L1F748D: db $80
L1F748E: db $07
L1F748F: db $A1
L1F7490: db $15
L1F7491: db $9D
L1F7492: db $07
L1F7493: db $80
L1F7494: db $0E
L1F7495: db $9B
L1F7496: db $15
L1F7497: db $98
L1F7498: db $0A
L1F7499: db $80
L1F749A: db $0B
L1F749B: db $98
L1F749C: db $07
L1F749D: db $9E
L1F749E: db $15
L1F749F: db $ED
SndData_07_Ch2: db $E4
L1F74A1: db $62
L1F74A2: db $E9
L1F74A3: db $22
L1F74A4: db $EE
L1F74A5: db $80
L1F74A6: db $EC
L1F74A7: db $D0
L1F74A8: db $74
L1F74A9: db $EC
L1F74AA: db $E4
L1F74AB: db $74
L1F74AC: db $EC
L1F74AD: db $F8
L1F74AE: db $74
L1F74AF: db $EC
L1F74B0: db $1A
L1F74B1: db $75
L1F74B2: db $EC
L1F74B3: db $F8
L1F74B4: db $74
L1F74B5: db $EC
L1F74B6: db $3C
L1F74B7: db $75
L1F74B8: db $EC
L1F74B9: db $60
L1F74BA: db $75
L1F74BB: db $EC
L1F74BC: db $78
L1F74BD: db $75
L1F74BE: db $EC
L1F74BF: db $60
L1F74C0: db $75
L1F74C1: db $EC
L1F74C2: db $9A
L1F74C3: db $75
L1F74C4: db $EC
L1F74C5: db $C9
L1F74C6: db $75
L1F74C7: db $EC
L1F74C8: db $D4
L1F74C9: db $75
L1F74CA: db $EC
L1F74CB: db $DF
L1F74CC: db $75
L1F74CD: db $E5
L1F74CE: db $A0
L1F74CF: db $74
L1F74D0: db $9D
L1F74D1: db $07
L1F74D2: db $A5
L1F74D3: db $9D
L1F74D4: db $A5
L1F74D5: db $0E
L1F74D6: db $9D
L1F74D7: db $07
L1F74D8: db $A5
L1F74D9: db $0E
L1F74DA: db $9B
L1F74DB: db $07
L1F74DC: db $A4
L1F74DD: db $9B
L1F74DE: db $9B
L1F74DF: db $A5
L1F74E0: db $A4
L1F74E1: db $9B
L1F74E2: db $9F
L1F74E3: db $ED
L1F74E4: db $9D
L1F74E5: db $07
L1F74E6: db $A5
L1F74E7: db $9D
L1F74E8: db $A5
L1F74E9: db $0E
L1F74EA: db $9D
L1F74EB: db $07
L1F74EC: db $A5
L1F74ED: db $0E
L1F74EE: db $9B
L1F74EF: db $07
L1F74F0: db $A7
L1F74F1: db $A6
L1F74F2: db $A2
L1F74F3: db $A5
L1F74F4: db $A1
L1F74F5: db $A3
L1F74F6: db $9D
L1F74F7: db $ED
L1F74F8: db $A5
L1F74F9: db $07
L1F74FA: db $A5
L1F74FB: db $99
L1F74FC: db $A5
L1F74FD: db $96
L1F74FE: db $A2
L1F74FF: db $99
L1F7500: db $A5
L1F7501: db $15
L1F7502: db $A7
L1F7503: db $07
L1F7504: db $A0
L1F7505: db $99
L1F7506: db $A5
L1F7507: db $99
L1F7508: db $A4
L1F7509: db $15
L1F750A: db $98
L1F750B: db $07
L1F750C: db $A4
L1F750D: db $98
L1F750E: db $A4
L1F750F: db $98
L1F7510: db $9D
L1F7511: db $15
L1F7512: db $91
L1F7513: db $07
L1F7514: db $9D
L1F7515: db $91
L1F7516: db $A4
L1F7517: db $98
L1F7518: db $9D
L1F7519: db $ED
L1F751A: db $A0
L1F751B: db $07
L1F751C: db $94
L1F751D: db $A0
L1F751E: db $A5
L1F751F: db $96
L1F7520: db $A2
L1F7521: db $99
L1F7522: db $A5
L1F7523: db $15
L1F7524: db $94
L1F7525: db $07
L1F7526: db $A0
L1F7527: db $99
L1F7528: db $A5
L1F7529: db $99
L1F752A: db $A1
L1F752B: db $15
L1F752C: db $95
L1F752D: db $07
L1F752E: db $A1
L1F752F: db $95
L1F7530: db $97
L1F7531: db $A1
L1F7532: db $A7
L1F7533: db $AC
L1F7534: db $A9
L1F7535: db $A0
L1F7536: db $9D
L1F7537: db $A8
L1F7538: db $9E
L1F7539: db $A3
L1F753A: db $A6
L1F753B: db $ED
L1F753C: db $8F
L1F753D: db $07
L1F753E: db $91
L1F753F: db $8A
L1F7540: db $91
L1F7541: db $8A
L1F7542: db $8A
L1F7543: db $99
L1F7544: db $0E
L1F7545: db $8A
L1F7546: db $07
L1F7547: db $96
L1F7548: db $8A
L1F7549: db $8A
L1F754A: db $9A
L1F754B: db $0E
L1F754C: db $88
L1F754D: db $07
L1F754E: db $88
L1F754F: db $94
L1F7550: db $96
L1F7551: db $8A
L1F7552: db $96
L1F7553: db $8A
L1F7554: db $8A
L1F7555: db $99
L1F7556: db $0E
L1F7557: db $8A
L1F7558: db $07
L1F7559: db $9B
L1F755A: db $8A
L1F755B: db $8A
L1F755C: db $9A
L1F755D: db $0E
L1F755E: db $99
L1F755F: db $ED
L1F7560: db $A0
L1F7561: db $07
L1F7562: db $99
L1F7563: db $A0
L1F7564: db $96
L1F7565: db $A0
L1F7566: db $99
L1F7567: db $0E
L1F7568: db $A0
L1F7569: db $96
L1F756A: db $07
L1F756B: db $A0
L1F756C: db $96
L1F756D: db $A0
L1F756E: db $96
L1F756F: db $0E
L1F7570: db $99
L1F7571: db $07
L1F7572: db $E7
L1F7573: db $00
L1F7574: db $02
L1F7575: db $60
L1F7576: db $75
L1F7577: db $ED
L1F7578: db $9F
L1F7579: db $07
L1F757A: db $98
L1F757B: db $9F
L1F757C: db $96
L1F757D: db $A6
L1F757E: db $A2
L1F757F: db $0E
L1F7580: db $9F
L1F7581: db $96
L1F7582: db $07
L1F7583: db $9F
L1F7584: db $96
L1F7585: db $9F
L1F7586: db $96
L1F7587: db $0E
L1F7588: db $A9
L1F7589: db $A5
L1F758A: db $07
L1F758B: db $A0
L1F758C: db $9B
L1F758D: db $97
L1F758E: db $96
L1F758F: db $92
L1F7590: db $97
L1F7591: db $9B
L1F7592: db $A0
L1F7593: db $A5
L1F7594: db $A2
L1F7595: db $A7
L1F7596: db $AC
L1F7597: db $AA
L1F7598: db $A7
L1F7599: db $ED
L1F759A: db $9F
L1F759B: db $07
L1F759C: db $98
L1F759D: db $9F
L1F759E: db $96
L1F759F: db $A6
L1F75A0: db $A2
L1F75A1: db $0E
L1F75A2: db $9F
L1F75A3: db $96
L1F75A4: db $07
L1F75A5: db $9F
L1F75A6: db $96
L1F75A7: db $9F
L1F75A8: db $93
L1F75A9: db $0E
L1F75AA: db $A7
L1F75AB: db $A5
L1F75AC: db $07
L1F75AD: db $A0
L1F75AE: db $9B
L1F75AF: db $97
L1F75B0: db $96
L1F75B1: db $92
L1F75B2: db $91
L1F75B3: db $9D
L1F75B4: db $05
L1F75B5: db $98
L1F75B6: db $04
L1F75B7: db $9D
L1F75B8: db $05
L1F75B9: db $A0
L1F75BA: db $9B
L1F75BB: db $04
L1F75BC: db $9E
L1F75BD: db $05
L1F75BE: db $A1
L1F75BF: db $9D
L1F75C0: db $04
L1F75C1: db $A1
L1F75C2: db $05
L1F75C3: db $A2
L1F75C4: db $A7
L1F75C5: db $04
L1F75C6: db $A9
L1F75C7: db $05
L1F75C8: db $ED
L1F75C9: db $AC
L1F75CA: db $07
L1F75CB: db $A0
L1F75CC: db $A7
L1F75CD: db $A0
L1F75CE: db $E7
L1F75CF: db $00
L1F75D0: db $0E
L1F75D1: db $C9
L1F75D2: db $75
L1F75D3: db $ED
L1F75D4: db $AC
L1F75D5: db $07
L1F75D6: db $A0
L1F75D7: db $A5
L1F75D8: db $A0
L1F75D9: db $E7
L1F75DA: db $00
L1F75DB: db $06
L1F75DC: db $D4
L1F75DD: db $75
L1F75DE: db $ED
L1F75DF: db $AC
L1F75E0: db $07
L1F75E1: db $A0
L1F75E2: db $A7
L1F75E3: db $A0
L1F75E4: db $E7
L1F75E5: db $00
L1F75E6: db $08
L1F75E7: db $DF
L1F75E8: db $75
L1F75E9: db $AA
L1F75EA: db $07
L1F75EB: db $9E
L1F75EC: db $A7
L1F75ED: db $9E
L1F75EE: db $A7
L1F75EF: db $9D
L1F75F0: db $A4
L1F75F1: db $A9
L1F75F2: db $AC
L1F75F3: db $A0
L1F75F4: db $AA
L1F75F5: db $A0
L1F75F6: db $A9
L1F75F7: db $9E
L1F75F8: db $A5
L1F75F9: db $9E
L1F75FA: db $ED
SndData_07_Ch3: db $E4
L1F75FC: db $40
L1F75FD: db $E9
L1F75FE: db $44
L1F75FF: db $F3
L1F7600: db $04
L1F7601: db $F5
L1F7602: db $32
L1F7603: db $EC
L1F7604: db $30
L1F7605: db $76
L1F7606: db $EC
L1F7607: db $44
L1F7608: db $76
L1F7609: db $EC
L1F760A: db $58
L1F760B: db $76
L1F760C: db $EC
L1F760D: db $78
L1F760E: db $76
L1F760F: db $EC
L1F7610: db $58
L1F7611: db $76
L1F7612: db $EC
L1F7613: db $96
L1F7614: db $76
L1F7615: db $EC
L1F7616: db $BA
L1F7617: db $76
L1F7618: db $EC
L1F7619: db $F4
L1F761A: db $76
L1F761B: db $EC
L1F761C: db $BA
L1F761D: db $76
L1F761E: db $EC
L1F761F: db $09
L1F7620: db $77
L1F7621: db $EC
L1F7622: db $19
L1F7623: db $77
L1F7624: db $EC
L1F7625: db $40
L1F7626: db $77
L1F7627: db $EC
L1F7628: db $19
L1F7629: db $77
L1F762A: db $EC
L1F762B: db $67
L1F762C: db $77
L1F762D: db $E5
L1F762E: db $FB
L1F762F: db $75
L1F7630: db $94
L1F7631: db $07
L1F7632: db $96
L1F7633: db $8F
L1F7634: db $96
L1F7635: db $0E
L1F7636: db $94
L1F7637: db $07
L1F7638: db $9B
L1F7639: db $0E
L1F763A: db $8F
L1F763B: db $07
L1F763C: db $93
L1F763D: db $0E
L1F763E: db $8F
L1F763F: db $07
L1F7640: db $9B
L1F7641: db $0E
L1F7642: db $99
L1F7643: db $ED
L1F7644: db $94
L1F7645: db $07
L1F7646: db $96
L1F7647: db $8F
L1F7648: db $96
L1F7649: db $0E
L1F764A: db $94
L1F764B: db $07
L1F764C: db $9B
L1F764D: db $0E
L1F764E: db $8F
L1F764F: db $07
L1F7650: db $9B
L1F7651: db $9A
L1F7652: db $96
L1F7653: db $99
L1F7654: db $95
L1F7655: db $97
L1F7656: db $91
L1F7657: db $ED
L1F7658: db $99
L1F7659: db $0E
L1F765A: db $96
L1F765B: db $07
L1F765C: db $A0
L1F765D: db $1C
L1F765E: db $9B
L1F765F: db $15
L1F7660: db $9B
L1F7661: db $0E
L1F7662: db $99
L1F7663: db $F5
L1F7664: db $00
L1F7665: db $A5
L1F7666: db $2A
L1F7667: db $F5
L1F7668: db $32
L1F7669: db $9D
L1F766A: db $07
L1F766B: db $A5
L1F766C: db $0E
L1F766D: db $A0
L1F766E: db $07
L1F766F: db $91
L1F7670: db $0E
L1F7671: db $9D
L1F7672: db $15
L1F7673: db $94
L1F7674: db $0E
L1F7675: db $91
L1F7676: db $07
L1F7677: db $ED
L1F7678: db $F5
L1F7679: db $00
L1F767A: db $9E
L1F767B: db $38
L1F767C: db $9B
L1F767D: db $15
L1F767E: db $F5
L1F767F: db $32
L1F7680: db $92
L1F7681: db $0E
L1F7682: db $92
L1F7683: db $07
L1F7684: db $94
L1F7685: db $F5
L1F7686: db $00
L1F7687: db $97
L1F7688: db $38
L1F7689: db $FA
L1F768A: db $07
L1F768B: db $F5
L1F768C: db $32
L1F768D: db $A0
L1F768E: db $9D
L1F768F: db $94
L1F7690: db $9D
L1F7691: db $9C
L1F7692: db $92
L1F7693: db $97
L1F7694: db $9A
L1F7695: db $ED
L1F7696: db $94
L1F7697: db $0E
L1F7698: db $91
L1F7699: db $07
L1F769A: db $96
L1F769B: db $15
L1F769C: db $99
L1F769D: db $0E
L1F769E: db $91
L1F769F: db $07
L1F76A0: db $96
L1F76A1: db $0E
L1F76A2: db $8E
L1F76A3: db $07
L1F76A4: db $9A
L1F76A5: db $1C
L1F76A6: db $94
L1F76A7: db $0E
L1F76A8: db $91
L1F76A9: db $07
L1F76AA: db $96
L1F76AB: db $0E
L1F76AC: db $91
L1F76AD: db $07
L1F76AE: db $99
L1F76AF: db $0E
L1F76B0: db $8F
L1F76B1: db $07
L1F76B2: db $9B
L1F76B3: db $0E
L1F76B4: db $8E
L1F76B5: db $07
L1F76B6: db $9A
L1F76B7: db $0E
L1F76B8: db $99
L1F76B9: db $ED
L1F76BA: db $96
L1F76BB: db $07
L1F76BC: db $95
L1F76BD: db $96
L1F76BE: db $9D
L1F76BF: db $0E
L1F76C0: db $96
L1F76C1: db $07
L1F76C2: db $96
L1F76C3: db $95
L1F76C4: db $96
L1F76C5: db $9D
L1F76C6: db $0E
L1F76C7: db $96
L1F76C8: db $07
L1F76C9: db $91
L1F76CA: db $96
L1F76CB: db $9D
L1F76CC: db $0E
L1F76CD: db $99
L1F76CE: db $07
L1F76CF: db $94
L1F76D0: db $99
L1F76D1: db $A0
L1F76D2: db $0E
L1F76D3: db $94
L1F76D4: db $07
L1F76D5: db $99
L1F76D6: db $94
L1F76D7: db $99
L1F76D8: db $A0
L1F76D9: db $0E
L1F76DA: db $94
L1F76DB: db $07
L1F76DC: db $94
L1F76DD: db $9B
L1F76DE: db $9D
L1F76DF: db $0E
L1F76E0: db $98
L1F76E1: db $07
L1F76E2: db $93
L1F76E3: db $98
L1F76E4: db $9F
L1F76E5: db $0E
L1F76E6: db $93
L1F76E7: db $07
L1F76E8: db $98
L1F76E9: db $93
L1F76EA: db $98
L1F76EB: db $9F
L1F76EC: db $0E
L1F76ED: db $93
L1F76EE: db $07
L1F76EF: db $93
L1F76F0: db $96
L1F76F1: db $9B
L1F76F2: db $0E
L1F76F3: db $ED
L1F76F4: db $97
L1F76F5: db $07
L1F76F6: db $92
L1F76F7: db $97
L1F76F8: db $9E
L1F76F9: db $0E
L1F76FA: db $92
L1F76FB: db $07
L1F76FC: db $A3
L1F76FD: db $0E
L1F76FE: db $97
L1F76FF: db $07
L1F7700: db $A2
L1F7701: db $0E
L1F7702: db $97
L1F7703: db $07
L1F7704: db $9E
L1F7705: db $A0
L1F7706: db $9B
L1F7707: db $92
L1F7708: db $ED
L1F7709: db $97
L1F770A: db $07
L1F770B: db $92
L1F770C: db $97
L1F770D: db $9E
L1F770E: db $0E
L1F770F: db $92
L1F7710: db $07
L1F7711: db $9B
L1F7712: db $9D
L1F7713: db $0E
L1F7714: db $98
L1F7715: db $91
L1F7716: db $95
L1F7717: db $15
L1F7718: db $ED
L1F7719: db $92
L1F771A: db $0E
L1F771B: db $8D
L1F771C: db $07
L1F771D: db $92
L1F771E: db $0E
L1F771F: db $8D
L1F7720: db $07
L1F7721: db $98
L1F7722: db $99
L1F7723: db $0E
L1F7724: db $8D
L1F7725: db $07
L1F7726: db $99
L1F7727: db $0E
L1F7728: db $8D
L1F7729: db $07
L1F772A: db $96
L1F772B: db $15
L1F772C: db $91
L1F772D: db $0E
L1F772E: db $8C
L1F772F: db $07
L1F7730: db $91
L1F7731: db $0E
L1F7732: db $8C
L1F7733: db $07
L1F7734: db $96
L1F7735: db $98
L1F7736: db $0E
L1F7737: db $8C
L1F7738: db $07
L1F7739: db $98
L1F773A: db $0E
L1F773B: db $8C
L1F773C: db $07
L1F773D: db $94
L1F773E: db $15
L1F773F: db $ED
L1F7740: db $96
L1F7741: db $0E
L1F7742: db $91
L1F7743: db $07
L1F7744: db $96
L1F7745: db $0E
L1F7746: db $91
L1F7747: db $07
L1F7748: db $9B
L1F7749: db $9D
L1F774A: db $0E
L1F774B: db $91
L1F774C: db $07
L1F774D: db $9D
L1F774E: db $0E
L1F774F: db $91
L1F7750: db $07
L1F7751: db $99
L1F7752: db $15
L1F7753: db $96
L1F7754: db $0E
L1F7755: db $91
L1F7756: db $07
L1F7757: db $96
L1F7758: db $0E
L1F7759: db $91
L1F775A: db $07
L1F775B: db $99
L1F775C: db $9B
L1F775D: db $0E
L1F775E: db $8F
L1F775F: db $07
L1F7760: db $9B
L1F7761: db $0E
L1F7762: db $8F
L1F7763: db $07
L1F7764: db $96
L1F7765: db $15
L1F7766: db $ED
L1F7767: db $9B
L1F7768: db $0E
L1F7769: db $8F
L1F776A: db $07
L1F776B: db $99
L1F776C: db $0E
L1F776D: db $8F
L1F776E: db $07
L1F776F: db $96
L1F7770: db $0E
L1F7771: db $8F
L1F7772: db $07
L1F7773: db $8F
L1F7774: db $9B
L1F7775: db $0E
L1F7776: db $8F
L1F7777: db $07
L1F7778: db $99
L1F7779: db $15
L1F777A: db $91
L1F777B: db $0E
L1F777C: db $8C
L1F777D: db $07
L1F777E: db $91
L1F777F: db $0E
L1F7780: db $8C
L1F7781: db $07
L1F7782: db $95
L1F7783: db $0E
L1F7784: db $8C
L1F7785: db $07
L1F7786: db $F5
L1F7787: db $00
L1F7788: db $98
L1F7789: db $15
L1F778A: db $9B
L1F778B: db $03
L1F778C: db $9D
L1F778D: db $04
L1F778E: db $9B
L1F778F: db $03
L1F7790: db $9D
L1F7791: db $04
L1F7792: db $9B
L1F7793: db $03
L1F7794: db $9D
L1F7795: db $04
L1F7796: db $9B
L1F7797: db $07
L1F7798: db $F5
L1F7799: db $32
L1F779A: db $ED
SndData_07_Ch4: db $E9
L1F779C: db $88
L1F779D: db $EC
L1F779E: db $B5
L1F779F: db $77
L1F77A0: db $EC
L1F77A1: db $D8
L1F77A2: db $77
L1F77A3: db $EC
L1F77A4: db $FB
L1F77A5: db $77
L1F77A6: db $EC
L1F77A7: db $2F
L1F77A8: db $78
L1F77A9: db $EC
L1F77AA: db $58
L1F77AB: db $78
L1F77AC: db $EC
L1F77AD: db $87
L1F77AE: db $78
L1F77AF: db $EC
L1F77B0: db $87
L1F77B1: db $78
L1F77B2: db $E5
L1F77B3: db $9B
L1F77B4: db $77
L1F77B5: db $E4
L1F77B6: db $61
L1F77B7: db $36
L1F77B8: db $07
L1F77B9: db $E4
L1F77BA: db $62
L1F77BB: db $24
L1F77BC: db $0E
L1F77BD: db $E4
L1F77BE: db $61
L1F77BF: db $36
L1F77C0: db $0E
L1F77C1: db $36
L1F77C2: db $07
L1F77C3: db $36
L1F77C4: db $0E
L1F77C5: db $E4
L1F77C6: db $62
L1F77C7: db $24
L1F77C8: db $07
L1F77C9: db $E4
L1F77CA: db $61
L1F77CB: db $36
L1F77CC: db $0E
L1F77CD: db $36
L1F77CE: db $07
L1F77CF: db $E4
L1F77D0: db $62
L1F77D1: db $24
L1F77D2: db $0E
L1F77D3: db $E4
L1F77D4: db $61
L1F77D5: db $36
L1F77D6: db $0E
L1F77D7: db $ED
L1F77D8: db $E4
L1F77D9: db $61
L1F77DA: db $36
L1F77DB: db $07
L1F77DC: db $E4
L1F77DD: db $62
L1F77DE: db $24
L1F77DF: db $0E
L1F77E0: db $E4
L1F77E1: db $61
L1F77E2: db $36
L1F77E3: db $0E
L1F77E4: db $36
L1F77E5: db $07
L1F77E6: db $36
L1F77E7: db $0E
L1F77E8: db $E4
L1F77E9: db $62
L1F77EA: db $24
L1F77EB: db $0E
L1F77EC: db $E4
L1F77ED: db $61
L1F77EE: db $36
L1F77EF: db $0E
L1F77F0: db $E4
L1F77F1: db $62
L1F77F2: db $24
L1F77F3: db $07
L1F77F4: db $E4
L1F77F5: db $61
L1F77F6: db $36
L1F77F7: db $0E
L1F77F8: db $36
L1F77F9: db $07
L1F77FA: db $ED
L1F77FB: db $E4
L1F77FC: db $61
L1F77FD: db $36
L1F77FE: db $07
L1F77FF: db $36
L1F7800: db $07
L1F7801: db $E4
L1F7802: db $31
L1F7803: db $21
L1F7804: db $0E
L1F7805: db $E4
L1F7806: db $62
L1F7807: db $24
L1F7808: db $0E
L1F7809: db $E4
L1F780A: db $31
L1F780B: db $21
L1F780C: db $07
L1F780D: db $E4
L1F780E: db $61
L1F780F: db $36
L1F7810: db $0E
L1F7811: db $E4
L1F7812: db $31
L1F7813: db $21
L1F7814: db $07
L1F7815: db $E4
L1F7816: db $61
L1F7817: db $36
L1F7818: db $07
L1F7819: db $E4
L1F781A: db $31
L1F781B: db $21
L1F781C: db $07
L1F781D: db $E4
L1F781E: db $62
L1F781F: db $24
L1F7820: db $0E
L1F7821: db $E4
L1F7822: db $31
L1F7823: db $21
L1F7824: db $07
L1F7825: db $E4
L1F7826: db $61
L1F7827: db $36
L1F7828: db $07
L1F7829: db $E7
L1F782A: db $00
L1F782B: db $06
L1F782C: db $FB
L1F782D: db $77
L1F782E: db $ED
L1F782F: db $E4
L1F7830: db $61
L1F7831: db $36
L1F7832: db $07
L1F7833: db $E4
L1F7834: db $62
L1F7835: db $24
L1F7836: db $0E
L1F7837: db $E4
L1F7838: db $61
L1F7839: db $36
L1F783A: db $07
L1F783B: db $E4
L1F783C: db $62
L1F783D: db $24
L1F783E: db $07
L1F783F: db $24
L1F7840: db $07
L1F7841: db $E4
L1F7842: db $61
L1F7843: db $36
L1F7844: db $15
L1F7845: db $E4
L1F7846: db $62
L1F7847: db $24
L1F7848: db $0E
L1F7849: db $E4
L1F784A: db $61
L1F784B: db $36
L1F784C: db $07
L1F784D: db $E4
L1F784E: db $62
L1F784F: db $24
L1F7850: db $07
L1F7851: db $E4
L1F7852: db $61
L1F7853: db $36
L1F7854: db $0E
L1F7855: db $36
L1F7856: db $07
L1F7857: db $ED
L1F7858: db $E4
L1F7859: db $61
L1F785A: db $36
L1F785B: db $07
L1F785C: db $E4
L1F785D: db $62
L1F785E: db $24
L1F785F: db $0E
L1F7860: db $E4
L1F7861: db $61
L1F7862: db $36
L1F7863: db $07
L1F7864: db $E4
L1F7865: db $62
L1F7866: db $24
L1F7867: db $07
L1F7868: db $24
L1F7869: db $07
L1F786A: db $E4
L1F786B: db $61
L1F786C: db $36
L1F786D: db $15
L1F786E: db $E4
L1F786F: db $62
L1F7870: db $24
L1F7871: db $0E
L1F7872: db $E4
L1F7873: db $61
L1F7874: db $36
L1F7875: db $07
L1F7876: db $E4
L1F7877: db $62
L1F7878: db $24
L1F7879: db $07
L1F787A: db $E4
L1F787B: db $61
L1F787C: db $36
L1F787D: db $07
L1F787E: db $E4
L1F787F: db $62
L1F7880: db $24
L1F7881: db $07
L1F7882: db $E4
L1F7883: db $61
L1F7884: db $36
L1F7885: db $07
L1F7886: db $ED
L1F7887: db $E4
L1F7888: db $61
L1F7889: db $36
L1F788A: db $0E
L1F788B: db $36
L1F788C: db $07
L1F788D: db $36
L1F788E: db $07
L1F788F: db $E4
L1F7890: db $62
L1F7891: db $24
L1F7892: db $0E
L1F7893: db $E4
L1F7894: db $61
L1F7895: db $36
L1F7896: db $07
L1F7897: db $36
L1F7898: db $0E
L1F7899: db $E4
L1F789A: db $62
L1F789B: db $24
L1F789C: db $0E
L1F789D: db $E4
L1F789E: db $61
L1F789F: db $36
L1F78A0: db $07
L1F78A1: db $E4
L1F78A2: db $62
L1F78A3: db $24
L1F78A4: db $0E
L1F78A5: db $E4
L1F78A6: db $61
L1F78A7: db $36
L1F78A8: db $0E
L1F78A9: db $E7
L1F78AA: db $00
L1F78AB: db $07
L1F78AC: db $87
L1F78AD: db $78
L1F78AE: db $E4
L1F78AF: db $61
L1F78B0: db $36
L1F78B1: db $07
L1F78B2: db $E4
L1F78B3: db $62
L1F78B4: db $24
L1F78B5: db $0E
L1F78B6: db $E4
L1F78B7: db $61
L1F78B8: db $36
L1F78B9: db $07
L1F78BA: db $E4
L1F78BB: db $62
L1F78BC: db $24
L1F78BD: db $07
L1F78BE: db $24
L1F78BF: db $07
L1F78C0: db $E4
L1F78C1: db $61
L1F78C2: db $36
L1F78C3: db $0E
L1F78C4: db $E4
L1F78C5: db $62
L1F78C6: db $24
L1F78C7: db $07
L1F78C8: db $E4
L1F78C9: db $61
L1F78CA: db $36
L1F78CB: db $0E
L1F78CC: db $E4
L1F78CD: db $62
L1F78CE: db $24
L1F78CF: db $07
L1F78D0: db $24
L1F78D1: db $07
L1F78D2: db $E4
L1F78D3: db $61
L1F78D4: db $36
L1F78D5: db $07
L1F78D6: db $E4
L1F78D7: db $44
L1F78D8: db $26
L1F78D9: db $07
L1F78DA: db $E4
L1F78DB: db $54
L1F78DC: db $26
L1F78DD: db $07
L1F78DE: db $ED
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
SndData_05_Ch1: db $E4
L1F78F9: db $77
L1F78FA: db $E9
L1F78FB: db $11
L1F78FC: db $EE
L1F78FD: db $80
L1F78FE: db $EC
L1F78FF: db $04
L1F7900: db $79
L1F7901: db $E5
L1F7902: db $FE
L1F7903: db $78
L1F7904: db $AA
L1F7905: db $3C
L1F7906: db $A9
L1F7907: db $50
L1F7908: db $FA
L1F7909: db $14
L1F790A: db $FA
L1F790B: db $78
L1F790C: db $FA
L1F790D: db $14
L1F790E: db $A7
L1F790F: db $0A
L1F7910: db $A9
L1F7911: db $AA
L1F7912: db $78
L1F7913: db $FA
L1F7914: db $14
L1F7915: db $A9
L1F7916: db $0A
L1F7917: db $A7
L1F7918: db $A9
L1F7919: db $14
L1F791A: db $A5
L1F791B: db $78
L1F791C: db $A7
L1F791D: db $0A
L1F791E: db $A9
L1F791F: db $AA
L1F7920: db $78
L1F7921: db $FA
L1F7922: db $14
L1F7923: db $AE
L1F7924: db $0A
L1F7925: db $B0
L1F7926: db $AC
L1F7927: db $50
L1F7928: db $FA
L1F7929: db $50
L1F792A: db $FA
L1F792B: db $78
L1F792C: db $A9
L1F792D: db $0D
L1F792E: db $AA
L1F792F: db $0E
L1F7930: db $AE
L1F7931: db $0D
L1F7932: db $AC
L1F7933: db $50
L1F7934: db $FA
L1F7935: db $50
L1F7936: db $FA
L1F7937: db $50
L1F7938: db $FA
L1F7939: db $50
L1F793A: db $AC
L1F793B: db $50
L1F793C: db $FA
L1F793D: db $14
L1F793E: db $A8
L1F793F: db $AA
L1F7940: db $AC
L1F7941: db $AC
L1F7942: db $50
L1F7943: db $AC
L1F7944: db $1E
L1F7945: db $AD
L1F7946: db $AF
L1F7947: db $14
L1F7948: db $AA
L1F7949: db $78
L1F794A: db $FA
L1F794B: db $14
L1F794C: db $A7
L1F794D: db $0A
L1F794E: db $A8
L1F794F: db $A7
L1F7950: db $50
L1F7951: db $FA
L1F7952: db $50
L1F7953: db $AC
L1F7954: db $50
L1F7955: db $FA
L1F7956: db $14
L1F7957: db $A8
L1F7958: db $AA
L1F7959: db $AC
L1F795A: db $AC
L1F795B: db $50
L1F795C: db $AF
L1F795D: db $1E
L1F795E: db $AD
L1F795F: db $AC
L1F7960: db $14
L1F7961: db $AA
L1F7962: db $50
L1F7963: db $FA
L1F7964: db $50
L1F7965: db $AF
L1F7966: db $78
L1F7967: db $FA
L1F7968: db $14
L1F7969: db $AE
L1F796A: db $0A
L1F796B: db $AF
L1F796C: db $AE
L1F796D: db $78
L1F796E: db $FA
L1F796F: db $14
L1F7970: db $AE
L1F7971: db $0A
L1F7972: db $AF
L1F7973: db $B1
L1F7974: db $50
L1F7975: db $FA
L1F7976: db $14
L1F7977: db $B1
L1F7978: db $AF
L1F7979: db $AE
L1F797A: db $AF
L1F797B: db $78
L1F797C: db $FA
L1F797D: db $14
L1F797E: db $AC
L1F797F: db $0A
L1F7980: db $AF
L1F7981: db $B4
L1F7982: db $78
L1F7983: db $FA
L1F7984: db $14
L1F7985: db $B4
L1F7986: db $B3
L1F7987: db $AF
L1F7988: db $78
L1F7989: db $B1
L1F798A: db $0A
L1F798B: db $B3
L1F798C: db $B1
L1F798D: db $14
L1F798E: db $AE
L1F798F: db $78
L1F7990: db $AF
L1F7991: db $0A
L1F7992: db $AE
L1F7993: db $AF
L1F7994: db $78
L1F7995: db $FA
L1F7996: db $14
L1F7997: db $AC
L1F7998: db $0A
L1F7999: db $AF
L1F799A: db $B4
L1F799B: db $50
L1F799C: db $FA
L1F799D: db $14
L1F799E: db $B4
L1F799F: db $B3
L1F79A0: db $B1
L1F79A1: db $AF
L1F79A2: db $50
L1F79A3: db $FA
L1F79A4: db $50
L1F79A5: db $FA
L1F79A6: db $50
L1F79A7: db $FA
L1F79A8: db $50
L1F79A9: db $ED
SndData_05_Ch2: db $E4
L1F79AB: db $11
L1F79AC: db $E9
L1F79AD: db $22
L1F79AE: db $EE
L1F79AF: db $80
L1F79B0: db $81
L1F79B1: db $0A
L1F79B2: db $FA
L1F79B3: db $05
L1F79B4: db $E4
L1F79B5: db $37
L1F79B6: db $EC
L1F79B7: db $04
L1F79B8: db $79
L1F79B9: db $E5
L1F79BA: db $B6
L1F79BB: db $79
SndData_05_Ch3: db $E4
L1F79BD: db $40
L1F79BE: db $E9
L1F79BF: db $44
L1F79C0: db $F3
L1F79C1: db $01
L1F79C2: db $F5
L1F79C3: db $00
L1F79C4: db $EC
L1F79C5: db $03
L1F79C6: db $7A
L1F79C7: db $EC
L1F79C8: db $12
L1F79C9: db $7A
L1F79CA: db $EC
L1F79CB: db $03
L1F79CC: db $7A
L1F79CD: db $99
L1F79CE: db $14
L1F79CF: db $A0
L1F79D0: db $A5
L1F79D1: db $A9
L1F79D2: db $A5
L1F79D3: db $A9
L1F79D4: db $A5
L1F79D5: db $A9
L1F79D6: db $EC
L1F79D7: db $34
L1F79D8: db $7A
L1F79D9: db $EC
L1F79DA: db $43
L1F79DB: db $7A
L1F79DC: db $EC
L1F79DD: db $34
L1F79DE: db $7A
L1F79DF: db $EC
L1F79E0: db $43
L1F79E1: db $7A
L1F79E2: db $99
L1F79E3: db $14
L1F79E4: db $9E
L1F79E5: db $A2
L1F79E6: db $A5
L1F79E7: db $A2
L1F79E8: db $A5
L1F79E9: db $A2
L1F79EA: db $A5
L1F79EB: db $99
L1F79EC: db $14
L1F79ED: db $9E
L1F79EE: db $A2
L1F79EF: db $A5
L1F79F0: db $A2
L1F79F1: db $A5
L1F79F2: db $A2
L1F79F3: db $A5
L1F79F4: db $EC
L1F79F5: db $34
L1F79F6: db $7A
L1F79F7: db $EC
L1F79F8: db $52
L1F79F9: db $7A
L1F79FA: db $EC
L1F79FB: db $34
L1F79FC: db $7A
L1F79FD: db $EC
L1F79FE: db $43
L1F79FF: db $7A
L1F7A00: db $E5
L1F7A01: db $BC
L1F7A02: db $79
L1F7A03: db $99
L1F7A04: db $14
L1F7A05: db $A0
L1F7A06: db $A5
L1F7A07: db $A9
L1F7A08: db $A5
L1F7A09: db $A9
L1F7A0A: db $A5
L1F7A0B: db $A9
L1F7A0C: db $E7
L1F7A0D: db $00
L1F7A0E: db $02
L1F7A0F: db $03
L1F7A10: db $7A
L1F7A11: db $ED
L1F7A12: db $99
L1F7A13: db $14
L1F7A14: db $9E
L1F7A15: db $A2
L1F7A16: db $A5
L1F7A17: db $A2
L1F7A18: db $A5
L1F7A19: db $A2
L1F7A1A: db $A5
L1F7A1B: db $99
L1F7A1C: db $14
L1F7A1D: db $A0
L1F7A1E: db $A5
L1F7A1F: db $A9
L1F7A20: db $A5
L1F7A21: db $A9
L1F7A22: db $A5
L1F7A23: db $A9
L1F7A24: db $E7
L1F7A25: db $00
L1F7A26: db $02
L1F7A27: db $12
L1F7A28: db $7A
L1F7A29: db $ED
L1F7A2A: db $98;X
L1F7A2B: db $14;X
L1F7A2C: db $A0;X
L1F7A2D: db $A4;X
L1F7A2E: db $A7;X
L1F7A2F: db $A4;X
L1F7A30: db $A7;X
L1F7A31: db $A4;X
L1F7A32: db $A7;X
L1F7A33: db $ED;X
L1F7A34: db $9C
L1F7A35: db $14
L1F7A36: db $A0
L1F7A37: db $A3
L1F7A38: db $A8
L1F7A39: db $A3
L1F7A3A: db $A8
L1F7A3B: db $A3
L1F7A3C: db $A8
L1F7A3D: db $E7
L1F7A3E: db $00
L1F7A3F: db $02
L1F7A40: db $34
L1F7A41: db $7A
L1F7A42: db $ED
L1F7A43: db $9B
L1F7A44: db $14
L1F7A45: db $9E
L1F7A46: db $A3
L1F7A47: db $A7
L1F7A48: db $A3
L1F7A49: db $A7
L1F7A4A: db $A3
L1F7A4B: db $A7
L1F7A4C: db $E7
L1F7A4D: db $00
L1F7A4E: db $02
L1F7A4F: db $43
L1F7A50: db $7A
L1F7A51: db $ED
L1F7A52: db $9B
L1F7A53: db $14
L1F7A54: db $9E
L1F7A55: db $A3
L1F7A56: db $A7
L1F7A57: db $A3
L1F7A58: db $A7
L1F7A59: db $A3
L1F7A5A: db $A7
L1F7A5B: db $99
L1F7A5C: db $9E
L1F7A5D: db $A2
L1F7A5E: db $A5
L1F7A5F: db $A2
L1F7A60: db $A5
L1F7A61: db $A2
L1F7A62: db $A5
L1F7A63: db $ED
SndData_05_Ch4: db $E9
L1F7A65: db $88
L1F7A66: db $EC
L1F7A67: db $6F
L1F7A68: db $7A
L1F7A69: db $EC
L1F7A6A: db $8B
L1F7A6B: db $7A
L1F7A6C: db $E5
L1F7A6D: db $69
L1F7A6E: db $7A
L1F7A6F: db $E4
L1F7A70: db $51
L1F7A71: db $21
L1F7A72: db $0A
L1F7A73: db $E4
L1F7A74: db $41
L1F7A75: db $21
L1F7A76: db $0A
L1F7A77: db $E4
L1F7A78: db $31
L1F7A79: db $21
L1F7A7A: db $0A
L1F7A7B: db $E4
L1F7A7C: db $21
L1F7A7D: db $21
L1F7A7E: db $50
L1F7A7F: db $FA
L1F7A80: db $0A
L1F7A81: db $E4
L1F7A82: db $53
L1F7A83: db $11
L1F7A84: db $28
L1F7A85: db $E7
L1F7A86: db $00
L1F7A87: db $09
L1F7A88: db $6F
L1F7A89: db $7A
L1F7A8A: db $ED
L1F7A8B: db $E4
L1F7A8C: db $61
L1F7A8D: db $36
L1F7A8E: db $0A
L1F7A8F: db $E4
L1F7A90: db $51
L1F7A91: db $21
L1F7A92: db $0A
L1F7A93: db $E4
L1F7A94: db $41
L1F7A95: db $21
L1F7A96: db $0A
L1F7A97: db $E4
L1F7A98: db $61
L1F7A99: db $36
L1F7A9A: db $0A
L1F7A9B: db $E4
L1F7A9C: db $41
L1F7A9D: db $36
L1F7A9E: db $1E
L1F7A9F: db $E4
L1F7AA0: db $41
L1F7AA1: db $36
L1F7AA2: db $0A
L1F7AA3: db $E4
L1F7AA4: db $21
L1F7AA5: db $36
L1F7AA6: db $1E
L1F7AA7: db $E4
L1F7AA8: db $21
L1F7AA9: db $36
L1F7AAA: db $0A
L1F7AAB: db $E4
L1F7AAC: db $53
L1F7AAD: db $11
L1F7AAE: db $28
L1F7AAF: db $ED
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
SndData_02_Ch1: db $E4
L1F7ACA: db $77
L1F7ACB: db $E9
L1F7ACC: db $11
L1F7ACD: db $EE
L1F7ACE: db $C0
L1F7ACF: db $8D
L1F7AD0: db $0E
L1F7AD1: db $81
L1F7AD2: db $03
L1F7AD3: db $80
L1F7AD4: db $04
L1F7AD5: db $8B
L1F7AD6: db $0E
L1F7AD7: db $8B
L1F7AD8: db $03
L1F7AD9: db $80
L1F7ADA: db $04
L1F7ADB: db $94
L1F7ADC: db $38
L1F7ADD: db $88
L1F7ADE: db $03
L1F7ADF: db $80
L1F7AE0: db $04
L1F7AE1: db $94
L1F7AE2: db $03
L1F7AE3: db $80
L1F7AE4: db $04
L1F7AE5: db $95
L1F7AE6: db $0E
L1F7AE7: db $89
L1F7AE8: db $03
L1F7AE9: db $80
L1F7AEA: db $04
L1F7AEB: db $94
L1F7AEC: db $15
L1F7AED: db $92
L1F7AEE: db $0E
L1F7AEF: db $95
L1F7AF0: db $0E
L1F7AF1: db $89
L1F7AF2: db $03
L1F7AF3: db $80
L1F7AF4: db $04
L1F7AF5: db $94
L1F7AF6: db $15
L1F7AF7: db $92
L1F7AF8: db $0E
L1F7AF9: db $8D
L1F7AFA: db $0E
L1F7AFB: db $8F
L1F7AFC: db $E3
SndData_02_Ch2: db $E4
L1F7AFE: db $67
L1F7AFF: db $E9
L1F7B00: db $22
L1F7B01: db $EE
L1F7B02: db $40
L1F7B03: db $94
L1F7B04: db $0E
L1F7B05: db $80
L1F7B06: db $07
L1F7B07: db $92
L1F7B08: db $0E
L1F7B09: db $80
L1F7B0A: db $07
L1F7B0B: db $99
L1F7B0C: db $1C
L1F7B0D: db $99
L1F7B0E: db $05
L1F7B0F: db $97
L1F7B10: db $04
L1F7B11: db $94
L1F7B12: db $05
L1F7B13: db $97
L1F7B14: db $94
L1F7B15: db $04
L1F7B16: db $92
L1F7B17: db $05
L1F7B18: db $94
L1F7B19: db $8F
L1F7B1A: db $04
L1F7B1B: db $8B
L1F7B1C: db $05
L1F7B1D: db $9A
L1F7B1E: db $0E
L1F7B1F: db $80
L1F7B20: db $07
L1F7B21: db $99
L1F7B22: db $15
L1F7B23: db $97
L1F7B24: db $0E
L1F7B25: db $9A
L1F7B26: db $80
L1F7B27: db $07
L1F7B28: db $99
L1F7B29: db $15
L1F7B2A: db $97
L1F7B2B: db $0E
L1F7B2C: db $92
L1F7B2D: db $94
L1F7B2E: db $E3
SndData_02_Ch3: db $E4
L1F7B30: db $40
L1F7B31: db $E9
L1F7B32: db $44
L1F7B33: db $F3
L1F7B34: db $04
L1F7B35: db $F5
L1F7B36: db $32
L1F7B37: db $94
L1F7B38: db $15
L1F7B39: db $92
L1F7B3A: db $8D
L1F7B3B: db $8D
L1F7B3C: db $07
L1F7B3D: db $8B
L1F7B3E: db $88
L1F7B3F: db $8B
L1F7B40: db $8D
L1F7B41: db $88
L1F7B42: db $94
L1F7B43: db $92
L1F7B44: db $0E
L1F7B45: db $92
L1F7B46: db $03
L1F7B47: db $80
L1F7B48: db $04
L1F7B49: db $94
L1F7B4A: db $15
L1F7B4B: db $95
L1F7B4C: db $0E
L1F7B4D: db $92
L1F7B4E: db $0E
L1F7B4F: db $92
L1F7B50: db $03
L1F7B51: db $80
L1F7B52: db $04
L1F7B53: db $94
L1F7B54: db $15
L1F7B55: db $95
L1F7B56: db $0E
L1F7B57: db $F5
L1F7B58: db $1E
L1F7B59: db $94
L1F7B5A: db $94
L1F7B5B: db $E3
SndData_02_Ch4: db $E9
L1F7B5D: db $88
L1F7B5E: db $E4
L1F7B5F: db $34
L1F7B60: db $26
L1F7B61: db $03
L1F7B62: db $E4
L1F7B63: db $44
L1F7B64: db $26
L1F7B65: db $04
L1F7B66: db $E4
L1F7B67: db $61
L1F7B68: db $36
L1F7B69: db $07
L1F7B6A: db $36
L1F7B6B: db $07
L1F7B6C: db $E4
L1F7B6D: db $44
L1F7B6E: db $26
L1F7B6F: db $03
L1F7B70: db $E4
L1F7B71: db $54
L1F7B72: db $26
L1F7B73: db $04
L1F7B74: db $E4
L1F7B75: db $61
L1F7B76: db $36
L1F7B77: db $07
L1F7B78: db $36
L1F7B79: db $07
L1F7B7A: db $E4
L1F7B7B: db $62
L1F7B7C: db $24
L1F7B7D: db $07
L1F7B7E: db $E4
L1F7B7F: db $61
L1F7B80: db $36
L1F7B81: db $0E
L1F7B82: db $36
L1F7B83: db $07
L1F7B84: db $E4
L1F7B85: db $62
L1F7B86: db $24
L1F7B87: db $05
L1F7B88: db $E4
L1F7B89: db $61
L1F7B8A: db $36
L1F7B8B: db $04
L1F7B8C: db $36
L1F7B8D: db $05
L1F7B8E: db $E4
L1F7B8F: db $62
L1F7B90: db $24
L1F7B91: db $05
L1F7B92: db $24
L1F7B93: db $04
L1F7B94: db $E4
L1F7B95: db $34
L1F7B96: db $26
L1F7B97: db $05
L1F7B98: db $E4
L1F7B99: db $34
L1F7B9A: db $26
L1F7B9B: db $05
L1F7B9C: db $E4
L1F7B9D: db $44
L1F7B9E: db $26
L1F7B9F: db $04
L1F7BA0: db $E4
L1F7BA1: db $54
L1F7BA2: db $26
L1F7BA3: db $05
L1F7BA4: db $E4
L1F7BA5: db $61
L1F7BA6: db $36
L1F7BA7: db $07
L1F7BA8: db $E4
L1F7BA9: db $62
L1F7BAA: db $24
L1F7BAB: db $07
L1F7BAC: db $24
L1F7BAD: db $07
L1F7BAE: db $E4
L1F7BAF: db $61
L1F7BB0: db $36
L1F7BB1: db $07
L1F7BB2: db $E4
L1F7BB3: db $62
L1F7BB4: db $24
L1F7BB5: db $07
L1F7BB6: db $24
L1F7BB7: db $07
L1F7BB8: db $E4
L1F7BB9: db $61
L1F7BBA: db $36
L1F7BBB: db $07
L1F7BBC: db $E4
L1F7BBD: db $62
L1F7BBE: db $24
L1F7BBF: db $07
L1F7BC0: db $E4
L1F7BC1: db $61
L1F7BC2: db $36
L1F7BC3: db $07
L1F7BC4: db $E4
L1F7BC5: db $62
L1F7BC6: db $24
L1F7BC7: db $0E
L1F7BC8: db $E4
L1F7BC9: db $61
L1F7BCA: db $36
L1F7BCB: db $07
L1F7BCC: db $E4
L1F7BCD: db $62
L1F7BCE: db $24
L1F7BCF: db $07
L1F7BD0: db $24
L1F7BD1: db $07
L1F7BD2: db $E4
L1F7BD3: db $61
L1F7BD4: db $36
L1F7BD5: db $07
L1F7BD6: db $36
L1F7BD7: db $07
L1F7BD8: db $E4
L1F7BD9: db $62
L1F7BDA: db $24
L1F7BDB: db $0E
L1F7BDC: db $24
L1F7BDD: db $0E
L1F7BDE: db $E3

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
SndData_01_Ch1: db $E4
L1F7BF9: db $11
L1F7BFA: db $E9
L1F7BFB: db $11
L1F7BFC: db $EE
L1F7BFD: db $C0
L1F7BFE: db $8A
L1F7BFF: db $30
L1F7C00: db $E4
L1F7C01: db $76
L1F7C02: db $EC
L1F7C03: db $11
L1F7C04: db $7C
L1F7C05: db $EC
L1F7C06: db $29
L1F7C07: db $7C
L1F7C08: db $EC
L1F7C09: db $11
L1F7C0A: db $7C
L1F7C0B: db $EC
L1F7C0C: db $30
L1F7C0D: db $7C
L1F7C0E: db $E5
L1F7C0F: db $02
L1F7C10: db $7C
L1F7C11: db $E4
L1F7C12: db $76
L1F7C13: db $8A
L1F7C14: db $0C
L1F7C15: db $E4
L1F7C16: db $11
L1F7C17: db $8A
L1F7C18: db $48
L1F7C19: db $E4
L1F7C1A: db $76
L1F7C1B: db $88
L1F7C1C: db $0C
L1F7C1D: db $8A
L1F7C1E: db $E4
L1F7C1F: db $11
L1F7C20: db $8A
L1F7C21: db $24
L1F7C22: db $E4
L1F7C23: db $76
L1F7C24: db $8D
L1F7C25: db $0C
L1F7C26: db $8A
L1F7C27: db $06
L1F7C28: db $ED
L1F7C29: db $8F
L1F7C2A: db $06
L1F7C2B: db $80
L1F7C2C: db $8D
L1F7C2D: db $88
L1F7C2E: db $0C
L1F7C2F: db $ED
L1F7C30: db $8F
L1F7C31: db $0C
L1F7C32: db $88
L1F7C33: db $06
L1F7C34: db $8F
L1F7C35: db $0C
L1F7C36: db $ED
SndData_01_Ch2: db $E4
L1F7C38: db $11
L1F7C39: db $E9
L1F7C3A: db $22
L1F7C3B: db $EE
L1F7C3C: db $80
L1F7C3D: db $8A
L1F7C3E: db $30
L1F7C3F: db $E4
L1F7C40: db $52
L1F7C41: db $EC
L1F7C42: db $4A
L1F7C43: db $7C
L1F7C44: db $EC
L1F7C45: db $5A
L1F7C46: db $7C
L1F7C47: db $E5
L1F7C48: db $41
L1F7C49: db $7C
L1F7C4A: db $AC
L1F7C4B: db $06
L1F7C4C: db $A7
L1F7C4D: db $B1
L1F7C4E: db $0C
L1F7C4F: db $AC
L1F7C50: db $06
L1F7C51: db $A7
L1F7C52: db $B1
L1F7C53: db $A7
L1F7C54: db $E7
L1F7C55: db $00
L1F7C56: db $03
L1F7C57: db $4A
L1F7C58: db $7C
L1F7C59: db $ED
L1F7C5A: db $AC
L1F7C5B: db $06
L1F7C5C: db $A7
L1F7C5D: db $B1
L1F7C5E: db $0C
L1F7C5F: db $AC
L1F7C60: db $06
L1F7C61: db $A7
L1F7C62: db $B1
L1F7C63: db $B3
L1F7C64: db $ED
SndData_01_Ch3: db $E4
L1F7C66: db $00
L1F7C67: db $E9
L1F7C68: db $44
L1F7C69: db $F3
L1F7C6A: db $04
L1F7C6B: db $F5
L1F7C6C: db $32
L1F7C6D: db $8A
L1F7C6E: db $30
L1F7C6F: db $E4
L1F7C70: db $40
L1F7C71: db $EC
L1F7C72: db $80
L1F7C73: db $7C
L1F7C74: db $EC
L1F7C75: db $96
L1F7C76: db $7C
L1F7C77: db $EC
L1F7C78: db $80
L1F7C79: db $7C
L1F7C7A: db $EC
L1F7C7B: db $A9
L1F7C7C: db $7C
L1F7C7D: db $E5
L1F7C7E: db $71
L1F7C7F: db $7C
L1F7C80: db $8A
L1F7C81: db $0C
L1F7C82: db $88
L1F7C83: db $06
L1F7C84: db $8A
L1F7C85: db $80
L1F7C86: db $8D
L1F7C87: db $88
L1F7C88: db $89
L1F7C89: db $8A
L1F7C8A: db $03
L1F7C8B: db $80
L1F7C8C: db $09
L1F7C8D: db $8F
L1F7C8E: db $0C
L1F7C8F: db $8D
L1F7C90: db $06
L1F7C91: db $8A
L1F7C92: db $0C
L1F7C93: db $88
L1F7C94: db $06
L1F7C95: db $ED
L1F7C96: db $8A
L1F7C97: db $0C
L1F7C98: db $88
L1F7C99: db $06
L1F7C9A: db $8A
L1F7C9B: db $80
L1F7C9C: db $8D
L1F7C9D: db $88
L1F7C9E: db $0C
L1F7C9F: db $83
L1F7CA0: db $06
L1F7CA1: db $88
L1F7CA2: db $8A
L1F7CA3: db $8F
L1F7CA4: db $80
L1F7CA5: db $8D
L1F7CA6: db $88
L1F7CA7: db $0C
L1F7CA8: db $ED
L1F7CA9: db $8A
L1F7CAA: db $0C
L1F7CAB: db $88
L1F7CAC: db $06
L1F7CAD: db $8A
L1F7CAE: db $80
L1F7CAF: db $8D
L1F7CB0: db $88
L1F7CB1: db $0C
L1F7CB2: db $8D
L1F7CB3: db $8A
L1F7CB4: db $06
L1F7CB5: db $8F
L1F7CB6: db $0C
L1F7CB7: db $88
L1F7CB8: db $06
L1F7CB9: db $8F
L1F7CBA: db $0C
L1F7CBB: db $ED
SndData_01_Ch4: db $E9
L1F7CBD: db $88
L1F7CBE: db $E4
L1F7CBF: db $61
L1F7CC0: db $36
L1F7CC1: db $06
L1F7CC2: db $E4
L1F7CC3: db $62
L1F7CC4: db $24
L1F7CC5: db $0C
L1F7CC6: db $24
L1F7CC7: db $06
L1F7CC8: db $24
L1F7CC9: db $0C
L1F7CCA: db $24
L1F7CCB: db $06
L1F7CCC: db $24
L1F7CCD: db $06
L1F7CCE: db $EC
L1F7CCF: db $D4
L1F7CD0: db $7C
L1F7CD1: db $E5
L1F7CD2: db $CE
L1F7CD3: db $7C
L1F7CD4: db $E4
L1F7CD5: db $61
L1F7CD6: db $36
L1F7CD7: db $0C
L1F7CD8: db $36
L1F7CD9: db $0C
L1F7CDA: db $E4
L1F7CDB: db $62
L1F7CDC: db $24
L1F7CDD: db $18
L1F7CDE: db $E4
L1F7CDF: db $61
L1F7CE0: db $36
L1F7CE1: db $0C
L1F7CE2: db $36
L1F7CE3: db $0C
L1F7CE4: db $E4
L1F7CE5: db $62
L1F7CE6: db $24
L1F7CE7: db $12
L1F7CE8: db $E4
L1F7CE9: db $61
L1F7CEA: db $36
L1F7CEB: db $06
L1F7CEC: db $36
L1F7CED: db $0C
L1F7CEE: db $36
L1F7CEF: db $0C
L1F7CF0: db $E4
L1F7CF1: db $62
L1F7CF2: db $24
L1F7CF3: db $12
L1F7CF4: db $24
L1F7CF5: db $06
L1F7CF6: db $E4
L1F7CF7: db $61
L1F7CF8: db $36
L1F7CF9: db $06
L1F7CFA: db $E4
L1F7CFB: db $62
L1F7CFC: db $24
L1F7CFD: db $06
L1F7CFE: db $E4
L1F7CFF: db $61
L1F7D00: db $36
L1F7D01: db $0C
L1F7D02: db $E4
L1F7D03: db $62
L1F7D04: db $24
L1F7D05: db $06
L1F7D06: db $E4
L1F7D07: db $61
L1F7D08: db $36
L1F7D09: db $0C
L1F7D0A: db $36
L1F7D0B: db $06
L1F7D0C: db $61
L1F7D0D: db $0C
L1F7D0E: db $36
L1F7D0F: db $0C
L1F7D10: db $E4
L1F7D11: db $62
L1F7D12: db $24
L1F7D13: db $18
L1F7D14: db $61
L1F7D15: db $0C
L1F7D16: db $36
L1F7D17: db $0C
L1F7D18: db $E4
L1F7D19: db $62
L1F7D1A: db $24
L1F7D1B: db $18
L1F7D1C: db $36
L1F7D1D: db $0C
L1F7D1E: db $36
L1F7D1F: db $0C
L1F7D20: db $E4
L1F7D21: db $62
L1F7D22: db $24
L1F7D23: db $12
L1F7D24: db $24
L1F7D25: db $06
L1F7D26: db $E4
L1F7D27: db $61
L1F7D28: db $36
L1F7D29: db $06
L1F7D2A: db $E4
L1F7D2B: db $62
L1F7D2C: db $24
L1F7D2D: db $06
L1F7D2E: db $E4
L1F7D2F: db $61
L1F7D30: db $36
L1F7D31: db $0C
L1F7D32: db $E4
L1F7D33: db $62
L1F7D34: db $24
L1F7D35: db $0C
L1F7D36: db $24
L1F7D37: db $06
L1F7D38: db $24
L1F7D39: db $06
L1F7D3A: db $ED
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
L1F7DDC: db $00
L1F7DDD: db $80
L1F7DDE: db $40
L1F7DDF: db $C0
L1F7DE0: db $20
L1F7DE1: db $A0
L1F7DE2: db $60
L1F7DE3: db $E0
L1F7DE4: db $10
L1F7DE5: db $90
L1F7DE6: db $50
L1F7DE7: db $D0
L1F7DE8: db $30
L1F7DE9: db $B0
L1F7DEA: db $70
L1F7DEB: db $F0
L1F7DEC: db $08
L1F7DED: db $88
L1F7DEE: db $48
L1F7DEF: db $C8
L1F7DF0: db $28
L1F7DF1: db $A8
L1F7DF2: db $68
L1F7DF3: db $E8
L1F7DF4: db $18
L1F7DF5: db $98
L1F7DF6: db $58
L1F7DF7: db $D8
L1F7DF8: db $38
L1F7DF9: db $B8
L1F7DFA: db $78
L1F7DFB: db $F8
L1F7DFC: db $04
L1F7DFD: db $84
L1F7DFE: db $44
L1F7DFF: db $C4
L1F7E00: db $24
L1F7E01: db $A4
L1F7E02: db $64
L1F7E03: db $E4
L1F7E04: db $14
L1F7E05: db $94
L1F7E06: db $54
L1F7E07: db $D4
L1F7E08: db $34
L1F7E09: db $B4
L1F7E0A: db $74
L1F7E0B: db $F4
L1F7E0C: db $0C
L1F7E0D: db $8C
L1F7E0E: db $4C
L1F7E0F: db $CC
L1F7E10: db $2C
L1F7E11: db $AC
L1F7E12: db $6C
L1F7E13: db $EC
L1F7E14: db $1C
L1F7E15: db $9C
L1F7E16: db $5C
L1F7E17: db $DC
L1F7E18: db $3C
L1F7E19: db $BC
L1F7E1A: db $7C
L1F7E1B: db $FC
L1F7E1C: db $02
L1F7E1D: db $82
L1F7E1E: db $42
L1F7E1F: db $C2
L1F7E20: db $22
L1F7E21: db $A2
L1F7E22: db $62
L1F7E23: db $E2
L1F7E24: db $12
L1F7E25: db $92
L1F7E26: db $52
L1F7E27: db $D2
L1F7E28: db $32
L1F7E29: db $B2
L1F7E2A: db $72
L1F7E2B: db $F2
L1F7E2C: db $0A
L1F7E2D: db $8A
L1F7E2E: db $4A
L1F7E2F: db $CA
L1F7E30: db $2A
L1F7E31: db $AA
L1F7E32: db $6A
L1F7E33: db $EA
L1F7E34: db $1A
L1F7E35: db $9A
L1F7E36: db $5A
L1F7E37: db $DA
L1F7E38: db $3A
L1F7E39: db $BA
L1F7E3A: db $7A
L1F7E3B: db $FA
L1F7E3C: db $06
L1F7E3D: db $86
L1F7E3E: db $46
L1F7E3F: db $C6
L1F7E40: db $26
L1F7E41: db $A6
L1F7E42: db $66
L1F7E43: db $E6
L1F7E44: db $16
L1F7E45: db $96
L1F7E46: db $56
L1F7E47: db $D6
L1F7E48: db $36
L1F7E49: db $B6
L1F7E4A: db $76
L1F7E4B: db $F6
L1F7E4C: db $0E
L1F7E4D: db $8E
L1F7E4E: db $4E
L1F7E4F: db $CE
L1F7E50: db $2E
L1F7E51: db $AE
L1F7E52: db $6E
L1F7E53: db $EE
L1F7E54: db $1E
L1F7E55: db $9E
L1F7E56: db $5E
L1F7E57: db $DE
L1F7E58: db $3E
L1F7E59: db $BE
L1F7E5A: db $7E
L1F7E5B: db $FE
L1F7E5C: db $01
L1F7E5D: db $81
L1F7E5E: db $41
L1F7E5F: db $C1
L1F7E60: db $21
L1F7E61: db $A1
L1F7E62: db $61
L1F7E63: db $E1
L1F7E64: db $11
L1F7E65: db $91
L1F7E66: db $51
L1F7E67: db $D1
L1F7E68: db $31
L1F7E69: db $B1
L1F7E6A: db $71
L1F7E6B: db $F1
L1F7E6C: db $09
L1F7E6D: db $89
L1F7E6E: db $49
L1F7E6F: db $C9
L1F7E70: db $29
L1F7E71: db $A9
L1F7E72: db $69
L1F7E73: db $E9
L1F7E74: db $19
L1F7E75: db $99
L1F7E76: db $59
L1F7E77: db $D9
L1F7E78: db $39
L1F7E79: db $B9
L1F7E7A: db $79
L1F7E7B: db $F9
L1F7E7C: db $05
L1F7E7D: db $85
L1F7E7E: db $45
L1F7E7F: db $C5
L1F7E80: db $25
L1F7E81: db $A5
L1F7E82: db $65
L1F7E83: db $E5
L1F7E84: db $15
L1F7E85: db $95
L1F7E86: db $55
L1F7E87: db $D5
L1F7E88: db $35
L1F7E89: db $B5
L1F7E8A: db $75
L1F7E8B: db $F5
L1F7E8C: db $0D
L1F7E8D: db $8D
L1F7E8E: db $4D
L1F7E8F: db $CD
L1F7E90: db $2D
L1F7E91: db $AD
L1F7E92: db $6D
L1F7E93: db $ED
L1F7E94: db $1D
L1F7E95: db $9D
L1F7E96: db $5D
L1F7E97: db $DD
L1F7E98: db $3D
L1F7E99: db $BD
L1F7E9A: db $7D
L1F7E9B: db $FD
L1F7E9C: db $03
L1F7E9D: db $83
L1F7E9E: db $43
L1F7E9F: db $C3
L1F7EA0: db $23
L1F7EA1: db $A3
L1F7EA2: db $63
L1F7EA3: db $E3
L1F7EA4: db $13
L1F7EA5: db $93
L1F7EA6: db $53
L1F7EA7: db $D3
L1F7EA8: db $33
L1F7EA9: db $B3
L1F7EAA: db $73
L1F7EAB: db $F3;X
L1F7EAC: db $0B
L1F7EAD: db $8B;X
L1F7EAE: db $4B
L1F7EAF: db $CB
L1F7EB0: db $2B
L1F7EB1: db $AB
L1F7EB2: db $6B
L1F7EB3: db $EB
L1F7EB4: db $1B
L1F7EB5: db $9B
L1F7EB6: db $5B
L1F7EB7: db $DB
L1F7EB8: db $3B
L1F7EB9: db $BB
L1F7EBA: db $7B
L1F7EBB: db $FB
L1F7EBC: db $07
L1F7EBD: db $87
L1F7EBE: db $47
L1F7EBF: db $C7
L1F7EC0: db $27
L1F7EC1: db $A7
L1F7EC2: db $67
L1F7EC3: db $E7
L1F7EC4: db $17
L1F7EC5: db $97
L1F7EC6: db $57
L1F7EC7: db $D7
L1F7EC8: db $37
L1F7EC9: db $B7
L1F7ECA: db $77
L1F7ECB: db $F7
L1F7ECC: db $0F
L1F7ECD: db $8F
L1F7ECE: db $4F
L1F7ECF: db $CF
L1F7ED0: db $2F
L1F7ED1: db $AF
L1F7ED2: db $6F
L1F7ED3: db $EF
L1F7ED4: db $1F
L1F7ED5: db $9F
L1F7ED6: db $5F
L1F7ED7: db $DF
L1F7ED8: db $3F
L1F7ED9: db $BF
L1F7EDA: db $7F
L1F7EDB: db $FF
L1F7EDC: db $30;X
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
L1F7FDC: db $1F
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
