; =============== RESET VECTOR $00 ===============
; Bankswitches to code in a different bank.
; Because this doesn't return, this is typically used to switch modes 
; -- the code which is jumped to resets the stack and sets up its own main loop.
; IN
; -  B: Bank number where the code is located
; - HL: Ptr to code to code to execute
; WIPES
; - A
FarJump:
	ld   a, b
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	jp   hl
;--
L000007: db $17;X

; =============== RESET VECTOR $08 ===============
Rst_FarCall:
	jp   FarCall
;--
L00000B: db $FE;X
L00000C: db $00;X
L00000D: db $CA;X
L00000E: db $22;X
L00000F: db $00;X

; =============== RESET VECTOR $10 ===============
Rst_StopLCDOperation:
	jp   StopLCDOperation
;--
L000013: db $33;X
L000014: db $00;X
L000015: db $FE;X
L000016: db $08;X
L000017: db $CA;X

; =============== RESET VECTOR $18 ===============
Rst_StartLCDOperation:
	jp   StartLCDOperation
;--
L00001B: db $14;X
L00001C: db $CA;X
L00001D: db $55;X
L00001E: db $00;X
L00001F: db $C3;X
; =============== RESET VECTOR $20 ===============
; Disables the SERIAL interrupt.
Rst_DisableSerialInt:
	ldh  a, [rIE]
	and  a, $FF^I_SERIAL
	ldh  [rIE], a
	ret  
;--
L000027: db $00;X
; =============== RESET VECTOR $28 ===============
; Enables the SERIAL interrupt.
Rst_EnableSerialInt:
	ldh  a, [rIE]
	or   a, I_SERIAL
	ldh  [rIE], a
	ret
;--
L00002F: db $35;X
; =============== RESET VECTOR $30 ===============
Rst_FarDecompressGFX:
	jp   FarDecompressGFX
;--
L000033: db $CD;X
L000034: db $66;X
L000035: db $2B;X
L000036: db $D2;X
L000037: db $64;X
; =============== RESET VECTOR $38 ===============
; Not used.
	ret
;--
L000039: db $21;X
L00003A: db $12;X
L00003B: db $06;X
L00003C: db $3E;X
L00003D: db $01;X
L00003E: db $CD;X
L00003F: db $7A;X
; =============== VBLANK INTERRUPT ===============
	jp   L000542
L000043: db $00;X
L000044: db $CD;X
L000045: db $66;X
L000046: db $2B;X
L000047: db $D2;X

; =============== LCDC/STAT INTERRUPT ===============
	jp   L000484
L00004B: db $0C;X
L00004C: db $06;X
L00004D: db $3E;X
L00004E: db $01;X
L00004F: db $CD;X
; =============== TIMER INTERRUPT ===============
; Not used.
	reti
L000051: db $35;X
L000052: db $C3;X
L000053: db $64;X
L000054: db $00;X
L000055: db $CD;X
L000056: db $66;X
L000057: db $2B;X
; =============== SERIAL INTERRUPT ===============
	jp   L0016DB
L00005B: db $D9;X
L00005C: db $2F;X
L00005D: db $2C;X
L00005E: db $AF;X
L00005F: db $EA;X
; =============== JOYPAD INTERRUPT ===============
; Not used.
	reti
	
; =============== FarCall / SubCall ===============
; This subroutine performs a bankswitch to the specified code and calls it.
; When the subroutine is done, the previous bank is restored.
;
; IN
; -  B: Bank number where the code is located
; - HL: Ptr to code to code to execute
; WIPES
; - A
FarCall:
	ldh  a, [hROMBank]			; Save the current bank number for later.
	push af
	ld   a, b					; Bankswitch to the new bank
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	call .exec					; Execute the code
	pop  af						; Restore the previous bank
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret
.exec:
	jp   hl
	
; =============== FarDecompressGFX ===============
; Decompresses the GFX on a different bank to the specified location in memory.
; IN
; - B: Bank number
; - DE: Ptr to decompression buffer
; - HL: Ptr to compressed graphics
FarDecompressGFX:
	; Homecall-ish
	ldh  a, [hROMBank]
	push af
	ld   a, b
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	call DecompressGFX
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret  

; =============== StopLCDOperation ===============
; Disables the screen output in a safe way.
;
; This will wait for VBlank before stopping the LCD.
StopLCDOperation:
	ldh  a, [rIE]			; Disable VBlank interrupt to prevent it from firing
	and  a, $FF^I_VBLANK
	ldh  [rIE], a
	
	; If the LCD is already disabled, we're done.
	ldh  a, [rLCDC]
	bit  LCDCB_ENABLE, a	; Is the display enabled?
	jp   z, .end			; If not, skip
	
	; Otherwise, wait in a loop until the scanline counter reaches what would be VBlank.
.wait:
	ldh  a, [rLY]			; Read scanline number
	cp   LY_VBLANK+1		; Is it 1 after the VBlank trigger?
	jr   nz, .wait			; If not, loop
	
	; Now we can safely disable the LCD
	ldh  a, [rLCDC]			
	and  a, $FF^LCDC_ENABLE
	ldh  [rLCDC], a
.end:
	ret
	
; =============== StartLCDOperation ===============
; Enables the screen output with the specified options.
; IN
; - A: LCDC options.
StartLCDOperation:
	or   a, LCDC_ENABLE				; Set new LCDC status
	ldh  [rLCDC], a
	ldh  a, [rIE]					; Enable VBLANK and Serial interrupts
	or   a, I_VBLANK|I_SERIAL
	ldh  [rIE], a
	ret

; =============== Tilemaps for the health/pow bars ===============	
L0000AD: db $E0
L0000AE: db $E8
L0000AF: db $E9
L0000B0: db $EA
L0000B1: db $EB
L0000B2: db $EC
L0000B3: db $ED
L0000B4: db $EE
L0000B5: db $DF
L0000B6: db $08
L0000B7: db $07
L0000B8: db $06
L0000B9: db $05
L0000BA: db $04
L0000BB: db $03
L0000BC: db $02
L0000BD: db $01
L0000BE: db $00
L0000BF: db $E0
L0000C0: db $E1
L0000C1: db $E2
L0000C2: db $E3
L0000C3: db $E4
L0000C4: db $E5
L0000C5: db $E6
L0000C6: db $E7
L0000C7: db $DF
L0000C8: db $00
L0000C9: db $01
L0000CA: db $02
L0000CB: db $03
L0000CC: db $04
L0000CD: db $05
L0000CE: db $06
L0000CF: db $07
L0000D0: db $08
L0000D1: db $EF
L0000D2: db $F0
L0000D3: db $F1
L0000D4: db $F2
L0000D5: db $F3
L0000D6: db $F4
L0000D7: db $F5
L0000D8: db $F6
L0000D9: db $F7
L0000DA: db $F8
L0000DB: db $D4
L0000DC: db $D5

L0000DD: db $CD;X
L0000DE: db $B3;X
L0000DF: db $34;X
L0000E0: db $CD;X
L0000E1: db $88;X
L0000E2: db $35;X
L0000E3: db $C3;X
L0000E4: db $53;X
L0000E5: db $01;X
L0000E6: db $CD;X
L0000E7: db $E0;X
L0000E8: db $2A;X
L0000E9: db $CD;X
L0000EA: db $74;X
L0000EB: db $34;X
L0000EC: db $20;X
L0000ED: db $05;X
L0000EE: db $3E;X
L0000EF: db $4C;X
L0000F0: db $C3;X
L0000F1: db $F5;X
L0000F2: db $00;X
L0000F3: db $3E;X
L0000F4: db $4E;X
L0000F5: db $CD;X
L0000F6: db $B3;X
L0000F7: db $34;X
L0000F8: db $C3;X
L0000F9: db $53;X
L0000FA: db $01;X
L0000FB: db $CD;X
L0000FC: db $E0;X
L0000FD: db $2A;X
L0000FE: db $CD;X
L0000FF: db $74;X

; =============== HW ENTRY POINT ===============
	nop
	jp   EntryPoint
	
; =============== GAME HEADER ===============
	; logo
	db   $CE,$ED,$66,$66,$CC,$0D,$00,$0B,$03,$73,$00,$83,$00,$0C,$00,$0D
	db   $00,$08,$11,$1F,$88,$89,$00,$0E,$DC,$CC,$6E,$E6,$DD,$DD,$D9,$99
	db   $BB,$BB,$67,$63,$6E,$0E,$EC,$CC,$DD,$DC,$99,$9F,$BB,$B9,$33,$3E
	db   "NETTOU KOF 96",$00,$00	; title
	db   $00			; DMG - classic gameboy
	db   $41,$37		; new license
	db   $03			; SGB flag: SGB capable
	db   $01			; cart type: MBC1
	db   $04			; ROM size: 512KiB
	db   $00			; RAM size: 0KiB
	db   $00			; destination code: Japanese
	db   $33			; old license: SGB capable
	db   $00			; mask ROM version number
	db   $C6			; header check
	db   $E1,$1B		; global check
	
	
; =============== EntryPoint ===============
EntryPoint:
	rst  $10				; Stop LCD
	di
	ld   sp, $DC00			; Setup stack
	ld   a, $0A				; Enable SRAM
	ld   [$0000], a
	ld   a, $01				; Initialize first bank
	ld   [MBC1RomBank], a
	
	;
	; Clear memory range $C000-$C35D
	;
	ld   hl, $C000		; HL = Initial address
	ld   de, $035E		; DE = Bytes to clear
	ld   b, $00			; B = Value to repeat
.clMem1:
	ld   a, b
	ldi  [hl], a
	dec  de
	ld   a, d
	or   a, e
	jr   nz, .clMem1
	
	;
	; Clear memory range $CC00-$DFFF
	;
	ld   hl, $CC00
	ld   de, $1400
	ld   b, $00
.clMem2:
	ld   a, b
	ldi  [hl], a
	dec  de
	ld   a, d
	or   a, e
	jr   nz, .clMem2
	
	
	;
	; Clear HRAM ($FF80-$FFFE)
	;
	ld   hl, $FF80
	ld   de, $007E
	ld   b, $00
.clMem3:
	ld   a, b
	ldi  [hl], a
	dec  de
	ld   a, d
	or   a, e
	jr   nz, .clMem3
	
	;
	; Copy the OAMDMA routine.
	;
	ld   c, LOW(hOAMDMA)	; C = Destination
	ld   b, (OAMDMACode.end-OAMDMACode) ; $11 B = Bytes to copy
	ld   hl, OAMDMACode		; HL = Source
.dccLoop:
	ldi  a, [hl]			; Read the byte
	ld   [c], a				; Copy it to $FF00 + C
	inc  c
	dec  b
	jr   nz, .dccLoop
	
	;
	; Misc init
	;
	call L0016BE
	
	;
	; Copy over the default settings
	;
	ld   hl, DefaultSettings						; HL = Source
	ld   de, wDipSwitch								; DE = Destination
	ld   bc, (DefaultSettings.end-DefaultSettings)	; BC = Bytes to copy
.dscLoop:
	ldi  a, [hl]
	ld   [de], a
	inc  de
	dec  bc
	ld   a, b
	or   a, c
	jr   nz, .dscLoop
	
	; Initialize screen
	ld   a, LCDC_ENABLE|LCDC_WTILEMAP				
	ldh  [rLCDC], a
	xor  a
	ldh  [rSCX], a
	ldh  [rSCY], a
	ldh  [rBGP], a
	ldh  [rOBP0], a
	ldh  [rOBP1], a
	ldh  [rIF], a
	ldh  [rSTAT], a
	
	; Initialize sound
	call HomeCall_Sound_Init
	
	; Detect if we're running under the SGB
	ASSERT(BANK(SGBPacket_EnableMultiJoy_1Pl) == BANK(SGBPacket_DisableMultiJoy))
	ld   a, BANK(SGBPacket_EnableMultiJoy_1Pl)
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	call IsSGBHardware				; Running under SGB?
	jr   c, .isSGB					; If so, jump
.isGB:
	ld   hl, wMisc_C025				; Unmark SGB mode
	res  MISCB_IS_SGB, [hl]
	jp   .switchToTakaraLogo
.isSGB:
	ld   hl, wMisc_C025				; Mark SGB mode
	set  MISCB_IS_SGB, [hl]
	ld   bc, $0078					; Wait $78 superticks
	call SGB_DelayAfterPacketSendCustom
	ld   hl, SGBPacket_EnableMultiJoy_1Pl	; Enable multiplayer
	call SGB_SendPackets
	ld   bc, $0004					; Wait $04 superticks
	call SGB_DelayAfterPacketSendCustom
	
.switchToTakaraLogo:
	ei
	
	; Set the system task, which will point to the custom module code.
	
	; Switch to the bank with the TAKARA logo display
	ld   a, BANK(Module_TakaraLogo)	; BANK $0A
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	
	; Have this as the first task
	ld   a, $01						; Task ID
	ld   bc, Module_TakaraLogo		; HL
	call Task_CreateAt
	
	jp   Task_DoCycle
	
; =============== SGB_LoadBorder ===============
; Loads the SGB border for the game.
; IN
; - A: Border type
;      $01 -> Standard
;      $02 -> Alternate
L000201:
SGB_LoadBorder:

	; If we aren't in SGB mode, return
	ld   hl, wMisc_C025
	bit  MISCB_IS_SGB, [hl]
	ret  z

	; Check if the border should be replaced.
	; Essentially:
	; - The first time this subroutine is called, the border will always be set.
	; - After that, the border will only ever be set once, when switching to the Alternate border.
	;   It is not allowed to load the Standard border once the Alternate one is loaded.
	
	ld   hl, wSGBBorderType
	cp   [hl]			; Read current (old) border id
	ret  c				; NewId < OldId? If so, return (prevents switching back to standard border)
	ret  z				; NewId == OldId? If so, return (prevents wasting time loading the same border)
	ld   [hl], a		; Write the border id we're loading
	
.checksOk:
	; Send away all of the packets for the border.
	di   
	ldh  a, [hROMBank]
	push af
		ld   a, BANK(L044000)
		ld   [MBC1RomBank], a
		ldh  [hROMBank], a
		ld   hl, L044000
		call SGB_SendPackets
		ld   bc, $0004
		call SGB_DelayAfterPacketSendCustom
		ld   hl, L044050
		call SGB_SendPackets
		ld   bc, $0004
		call SGB_DelayAfterPacketSendCustom
		ld   hl, L044060
		call SGB_SendPackets
		ld   bc, $0004
		call SGB_DelayAfterPacketSendCustom
		ld   hl, L044070
		call SGB_SendPackets
		ld   bc, $0004
		call SGB_DelayAfterPacketSendCustom
		ld   hl, L044080
		call SGB_SendPackets
		ld   bc, $0004
		call SGB_DelayAfterPacketSendCustom
		ld   hl, L044090
		call SGB_SendPackets
		ld   bc, $0004
		call SGB_DelayAfterPacketSendCustom
		ld   hl, L0440A0
		call SGB_SendPackets
		ld   bc, $0004
		call SGB_DelayAfterPacketSendCustom
		ld   hl, L0440B0
		call SGB_SendPackets
		ld   bc, $0004
		call SGB_DelayAfterPacketSendCustom
		ld   hl, L0440C0
		call SGB_SendPackets
		ld   bc, $0004
		call SGB_DelayAfterPacketSendCustom
		ld   b, $04
		ld   hl, $4351
		
		rst  $08
			call ClearBGMap
			xor  a
			ldh  [rBGP], a
			ld   a, $C1
		rst  $18
		
		call Task_SkipAllAndWaitVBlank
		ld   bc, $0078
		call SGB_DelayAfterPacketSendCustom
		ld   hl, L044010
		call SGB_SendPackets
		ld   bc, $0004
		call SGB_DelayAfterPacketSendCustom
		call HomeCall_Sound_Init
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret

; =============== SGB_SendPackets ===============
; Sends one or more packets to the Super Game Boy.
; IN
; - HL: Ptr to packet structure (format: <number of packets><packet 0>[<packet 1>]...)
L0002B3:
SGB_SendPackets:
	
	; The first byte marks the number of packets to send in the lower 3 bits.
	; These are stored one after the other in the ROM.
	ld   a, [hl]	; A = Number of packets
	and  a, $07		; SGB supports a max of 7 packets at once.
	ret  z			; If there are no packets, return
	
	
	ld   b, a		; B = Number of packets 
	
	; These packets are sent through the joypad register.
	ld   c, LOW(rJOYP)	; C = $FF00
	
.nextPacket:
	push bc				; Save for later
	
	; Send out the reset signal
	ld   a, SGB_BIT_RESET	; Reset
	ld   [c], a		
	ld   a, SGB_BIT_SEP		; Separator
	ld   [c], a
	
	; Send out the $10 bytes of the packet.
	; Each byte is sent out 1 bit at a time, from bit0 to bit7.
	ld   b, $10			; B = Remaining bytes to send out
.nextByte:
	ld   e, $08			; E = Remaining bits in the byte
	ldi  a, [hl]		; D = Byte to read
	ld   d, a
.nextBit:
	; Send out the bit.
	; If it's 0, send $20, otherwise send $10.
	; After a bit is sent out, a $30 is always sent.
	
	bit  0, d 			; Is the bit set?
	ld   a, SGB_BIT_1	; A = Value to send with bit set
	jr   nz, .sendBit	; If so, jump
.bitIs0:
	ld   a, SGB_BIT_0	; A = Value to send with bit cleared
.sendBit:
	ld   [c], a			; Send it out
	ld   a, SGB_BIT_SEP	; Send the separator
	ld   [c], a
	rr   d				; Rotate the next bit into bit0
	dec  e				; Sent all 8 bits?
	jr   nz, .nextBit	; If not, loop
	dec  b				; Sent all $10 bytes?
	jr   nz, .nextByte	; If not, loop
	
	ld   a, SGB_BIT_0	; Send last "stop" bit
	ld   [c], a
	ld   a, SGB_BIT_SEP
	ld   [c], a
	
	pop  bc			; Restore number of packets left
	
	dec  b			; All packets sent?
	ret  z			; If so, return
	
	call SGB_DelayAfterPacketSend
	jr   .nextPacket

; =============== SGB_DelayAfterPacketSend ===============
; Delays for a bit after sending a packet.
L0002E9:
SGB_DelayAfterPacketSend:
	ld   de, $1B58
.loop:
	nop
	nop
	nop
	dec  de
	ld   a, d
	or   a, e
	jr   nz, .loop
	ret
	
; =============== IsSGBHardware ===============
; Detects if the system is a Super Game Boy.
; OUT
; - Carry: If set, the system is a SGB.
IsSGBHardware:

	; Send out a MLT_REQ packet to select the SNES's second controller.
	; If the request succeeds (the first two bits in rJOYP are set), it means we're running under the SGB.
	ld   hl, SGBPacket_EnableMultiJoy_1Pl
	call SGB_SendPackets
	call SGB_DelayAfterPacketSend
	
	ldh  a, [rJOYP]		; Read the joypad status
	and  a, $03			
	cp   $03			; Is the second controller enabled?
	jr   nz, .isSGB		; If so, we're running under the SGB
	
	; ????? what is it sending?
	ld   a, SGB_BIT_0
	ldh  [rJOYP], a
	ldh  a, [rJOYP]
	ldh  a, [rJOYP]
	ld   a, SGB_BIT_SEP
	ldh  [rJOYP], a
	ld   a, SGB_BIT_1
	ldh  [rJOYP], a
	ldh  a, [rJOYP]
	ldh  a, [rJOYP]
	ldh  a, [rJOYP]
	ldh  a, [rJOYP]
	ldh  a, [rJOYP]
	ldh  a, [rJOYP]
	ld   a, SGB_BIT_SEP
	ldh  [rJOYP], a
	ldh  a, [rJOYP]
	ldh  a, [rJOYP]
	ldh  a, [rJOYP]
	ldh  a, [rJOYP]
	
	and  a, $03
	cp   $03			; Is the second controller enabled?
	jr   nz, .isSGB		; If so, we're running under the SGB
.noSGB:
	; Reselect back the first controller
	ld   hl, SGBPacket_DisableMultiJoy
	call SGB_SendPackets
	call SGB_DelayAfterPacketSend
	sub  a				; Return 0
	ret
.isSGB: 
	; Reselect back the first controller
	ld   hl, SGBPacket_DisableMultiJoy	
	call SGB_SendPackets
	call SGB_DelayAfterPacketSend
	scf  				; Return 1
	ret
	
; =============== SGB_DelayAfterPacketSendCustom ===============	
; Delays for the specified amount of times after sending a packet.
; IN
; - BC: Amount of times to wait $06D6 loops.
L00034A:
SGB_DelayAfterPacketSendCustom:
	; Total delay = BC * $06D6
	ld   de, $06D6
.loop:
	nop  
	nop  
	nop  
	dec  de
	ld   a, d
	or   e
	jr   nz, .loop
	dec  bc
	ld   a, b
	or   c
	jr   nz, SGB_DelayAfterPacketSendCustom
	ret  

; =============== OAMDMA ROUTINE ===============
; Copied in HRAM during init (don't use this directly).
OAMDMACode: 
	; Wait for VBlank before continuing
	ldh  a, [rSTAT]
	bit  ST_VBLANK, a		; Are we in VBlank yet?
	jp   nz, hOAMDMA		; If not, loop
	
	ld   a, HIGH(wWorkOAM)	; Start DMA copy from WorkOAM ($DF00) to OAM
	ldh  [rDMA], a
	ld   a, $28				; Wait $28 ticks
.wait:
	dec  a
	jr   nz, .wait
	ret 
.end:
; =============== DEFAULT SETTINGS ===============
DefaultSettings:
	db $00 ; Dip Switch: None
	db DIFFICULTY_NORMAL ; Difficulty: Normal
	db $90 ; Timer: 90 secs
.end:

; =============== START OF TASK MANAGER ===============

; =============== Task_DoCycle ===============
; Executes the main task cycle.
; See also: Task_ExecRun for the routine calling this.
L00036F:
Task_DoCycle:
	ld   sp, $DC00					; Set the standard stack pointer for taskman
.reloop:
	; Always search for tasks starting from the first one.
	; Since they get marked after execution, this won't cause double exec.
	ld   hl, hTaskTbl				; HL = Ptr to start ot task table
	ld   de, TASK_SIZE				; DE = Size of a task struct
	ld   bc, $0301					; B = Number of tasks; C = Current Task ID
.nextTask:
	ld   a, [wMisc_C026]			; Mark that the task exec loop was called
	set  MISCB_TASK_CTRL_CALLED, a
	ld   [wMisc_C026], a
	
	ld   a, [wMisc_C025]			
	bit  MISCB_PAUSE_TASKS, a		; Are tasks globally disabled?
	jp   nz, .execCommon			; If so, skip directly to the common code
	
	; If we can execute the task (marked as TASK_EXEC_TODO or TASK_EXEC_NEW), then do it
	ld   a, [hl]
	cp   TASK_EXEC_TODO				; taskType >= $04?
	jp   nc, .exec					; If so, execute it
	
	; Seek to the next task struct
	add  hl, de						; TaskPtr += sizeof(Task)
	inc  c							; TaskID++
	dec  b							; TasksLeft--; Any tasks left?
	jp   nz, .nextTask				; If so, loop.
.execCommon:
	; After all task are executed, run the common code and re-enable tasks
	call Task_ExecCommon
	; Recycle through them all
	jp   .reloop
	
.exec:
	ld   a, c						; Save the current task ID for later comparison
	ldh  [hCurTaskId], a			; Mark it as current task. This has an effect when the code we're executing calls the taskman back.
	
	ld   a, [hl]					; Read the task type

	ld   [hl], TASK_EXEC_CUR 		; Mark the task as executing
	inc  hl
	ld   [hl], $00
	inc  hl
	
	ld   e, [hl]					; Read out the task/stack ptr
	inc  hl
	ld   d, [hl]
	
	push de							; HL = DE
	pop  hl
	
	cp   TASK_EXEC_NEW				; Is this a new task?
	jp   nz, .oldTask				; If not, jump
.newTask:
	jp   hl							; Otherwise jump to (presumably) the task's init code
.oldTask:

	; Restore the state from when this task was created.
	ld   sp, hl						; Restore the stack pointer
	
	; The stack ptr was saved after pushing all regs into the stack in Task_ExecRun.
	; Pop them all out to restore the original state and return safely.
	pop  af
	pop  bc
	pop  de
	pop  hl
	
	ret

; =============== Task_CreateAt ===============
; Writes a new task at the specified ID.
; IN
; - A = Task ID ($01 - $03)
; - BC = Ptr to init code of the task / module entry point
L0003B8:
Task_CreateAt:
	di
	push af
	push bc
	push de
	push hl
	call Task_IndexTask
	ld   [hl], TASK_EXEC_NEW
	inc  hl
	ld   [hl], $00
	inc  hl
	ld   [hl], c
	inc  hl
	ld   [hl], b
	pop  hl
	pop  de
	pop  bc
	pop  af
	ei
	ret
; =============== Task_RemoveAt ===============
; Removes the task at the specified ID.
; IN
; - A = Task ID
L0003CF:
Task_RemoveAt:
	di
	push af
	push bc
	push de
	push hl
	call Task_IndexTask
	ld   [hl], TASK_EXEC_NONE
	inc  hl
	ld   [hl], $00
	pop  hl
	pop  de
	pop  bc
	pop  af
	ei
	ret
; =============== Task_ExecRun ===============
; Pauses the current task and gives back control to the task system.
;
; HOW IT WORKS
;
; The task system is used to execute custom subroutines/multiple main loops with separate stacks in a cycle, as well
; as shared code which must always run on any main loop, like the sound engine and OBJLst writer.
;
; There are four task slots and two different ways to execute subroutines:
; TASK_EXEC_NEW -> Used for init code, when a task code pointer should change.
; TASK_EXEC_TODO -> Used for loop code, which typically doesn't change across loops.
;
; *ANY* time the task system is run through Task_ExecRun, current slot is overwritten with an entry used
; to restore the original registers/SP, and is set to execute after all of the next slots + the common code is executed.
; This is important to allow cycling the same subroutine pointers if they aren't explicitly changed.
;
; Then the task table is iterated from the beginning until it finds an entry which can be executed.
; If one is found, the task is marked as being executed, the current slot is set to that, and the code is run. 
; This prevents the task from being executed again.
;
; To continue the cycle, the code which is called must manually call this subroutine again (or one of its stubs).
; 
; The same thing is done as before, until the entire task table is iterated. The common code which also waits for VBLANK
; is executed when that happens.
;
; The VBLANK handler also re-enables every task (??? marked as TASK_EXEC_DONE) as a TASK_EXEC_TODO, and the task table is iterated again.
; This WILL lead to the first task being executed again, which returns to the original state from before the task handler was
; called for the first time, and so on.
;
; IN
; - A = Set as byte1 of the task struct ???
L0003E2:
Task_ExecRun:

	; By calling this subroutine, we have to set the current stack location as a task, which
	; will replace the current one. Most of the time it does nothing but mark the task as executed,
	; but this also does replace the init task (TASK_EXEC_NEW) with the one for the main loop.

	
	;
	; Save all the status of all registers to the stack.
	;
	push hl
	push de
	push bc
	push af
	
	;
	; Replace current task with a new one (for the main loop) marked as executed.
	;
	push af
		call Task_IndexTaskAuto		; Get ptr for current task
		ld   [hl], TASK_EXEC_DONE	; Set it as type $01
		inc  hl
	pop  af
	
	ldi  [hl], a		; ???? Set the unknown value at byte1
	
	;
	; Copy SP to DE, then write it to the iTaskCodePtr fields.
	;
	push hl
		ld   hl, sp+$02	; +$02 since we just pushed hl, which moved the stack down by $02
		push hl
		pop  de
	pop  hl
	ld   [hl], e	; Write it out
	inc  hl
	ld   [hl], d
	
	; The task has been set, now execute the next ones with IDs higher than the current one
	jp   Task_DoCycle

; =============== Task_ExecRunFar_B01 ===============
; Wrapper for Task_ExecRun_B01 which also saves the current bank number.
; Use when executing tasks across different banks.
Task_ExecRunFar_B01:
	ldh  a, [hROMBank]		; Save bank for when we're returning
	push af
	call Task_ExecRun_B01
	pop  af					; Restore bank
	ld   [MBC1RomBank], a	
	ldh  [hROMBank], a
	ret
	
; =============== Task_ExecRun_* ===============
; Sets of wrappers to Task_ExecRun which set a different byte1.
Task_ExecRun_B01:
	ld   a, $01
	jr   Task_ExecRun
; [TCRF] Unused.
Task_Unused_ExecRun_B02: 
	ld   a, $02
	jr   Task_ExecRun
Task_ExecRun_B05:
	ld   a, $05
	jr   Task_ExecRun
Task_ExecRun_B0A:
	ld   a, $0A
	jr   Task_ExecRun
Task_ExecRun_B1E:
	ld   a, $1E
	jr   Task_ExecRun
Task_ExecRun_B3C:;
	ld   a, $3C
	jr   Task_ExecRun
	
; =============== Task_RemoveCurAndExecRun ===============	
; Similar to Task_ExecRun, except the current task is removed instead of marked as executed.
; As a result, the subroutine is much shorter.
; Only used in ???????
Task_RemoveCurAndExecRun:
	di							; TODO: ?????
	call Task_IndexTaskAuto		; Index current task
	ld   [hl], TASK_EXEC_NONE	; Disable it
	jp   Task_DoCycle
	
; =============== Task_IndexTaskAuto ===============
; Indexes the task struct of the currently executing (???) task.
L000429:
Task_IndexTaskAuto:
	ldh  a, [hCurTaskId]	; A = Index to current task ???
	
; =============== Task_IndexTask ===============
; Indexes the specified task struct by ID.
; IN
; - A: Index to task ID (must be between $01 and ???)
; OUT
; - HL: Ptr to task struct
Task_IndexTask:
	; -$08 is due to the side effect of the first task ID starting at $01, and not $00.
	; ie: The task with ID $01 should point to the first entry of hTaskTbl, not at the second entry (and so on).
	ld   hl, hTaskTbl-$08	; HL = Start of task table - $08
	rlca			; Index = A * 8 (size of task info)
	rlca
	rlca
	ld   e, a
	ld   d, $00
	add  hl, de		; Seek to the entry
	ret
	
; =============== Task_SkipAllAndWaitVBlank ===============
; Waits for VBlank without executing any of the tasks or common code.
L000436:
Task_SkipAllAndWaitVBlank:
	ld   a, $01
	ld   [wVBlankNotDone], a
	jp   Task_EndOfFrame
	
; =============== Task_Unused_SkipAllAndWaitVBlank_Copy ===============
; [TCRF] Unused? copy of the above.
L00043E:
Task_Unused_SkipAllAndWaitVBlank_Copy:
	ld   a, $01
	ld   [wVBlankNotDone], a
	jp   Task_EndOfFrame

; =============== Task_ExecCommon ===============
; Executes the common tasks before waiting for VBLANK.
L000446:
Task_ExecCommon:

	; Mark frame as executed -- wait for the VBlank handler below
	ld   a, $01
	ld   [wVBlankNotDone], a
	
	; If tasks are disabled, skip over these ones too
	ld   a, [wMisc_C025]
	bit  MISCB_PAUSE_TASKS, a		; Tasks disabled?
	jp   nz, Task_EndOfFrame		; If so, skip
	
	call OBJLstS_WriteAll
	call SGB_SendSoundPacketAtFrameEnd
	call HomeCall_Sound_Do
	; Fall-through
	
; =============== Task_EndOfFrame ===============
L00045C:
Task_EndOfFrame:

	; Clear the "Task exec loop executed" marker
	push hl
	ld   hl, wMisc_C026
	res  MISCB_TASK_CTRL_CALLED, [hl]
	pop  hl
	
	; Wait in a loop until the VBlank handler triggers, which clears the flag
	; and marks all tasks for execution
	ei
.waitVBlank:
	ld   a, [wVBlankNotDone]
	or   a						; VBlank done yet?
	jp   nz, .waitVBlank		; If not, loop
	ret
	

L00046C:;C
	ld   [$C15A], a
	ld   a, b
	ld   [$C15B], a
	ld   a, [wMisc_C028]
	or   a, $01
	ld   [wMisc_C028], a
	ret
L00047C:;C
	push hl
	ld   hl, wMisc_C028
	res  0, [hl]
	pop  hl
	ret
L000484:;J
	push af
	ld   a, [wMisc_C028]
	bit  0, a
	jp   nz, L000494
	bit  2, a
	jp   nz, L0004C3
	pop  af
	reti
L000494:;J
	ld   a, [$C006]
	or   a
	jp   nz, L0004B3
	ld   a, $28
L00049D:;J
	dec  a
	jp   nz, L00049D
	ldh  a, [$FFF1]
	ldh  [rBGP], a
	ld   a, $C7
	ldh  [rLCDC], a
	ld   [$C006], a
	ld   a, [$C15B]
	ldh  [rLYC], a
	pop  af
	reti
L0004B3:;J
	ld   a, $0A
L0004B5:;J
	dec  a
	jp   nz, L0004B5
	ldh  a, [$FFF2]
	ldh  [rBGP], a
	ld   a, $E7
	ldh  [rLCDC], a
	pop  af
	reti
L0004C3:;J
	ld   a, [$C006]
	or   a
	jp   z, L0004E1
	dec  a
	jp   z, L0004EF
	dec  a
	jp   z, L0004FD
	dec  a
	jp   z, L00050B
	dec  a
	jp   z, L000519
	dec  a
	jp   z, L000527
	jp   L000536
L0004E1:;J
	ld   a, $C7
	ldh  [rLCDC], a
	ld   a, $01
	ld   [$C006], a
	ld   a, $73
	jp   L000532
L0004EF:;J
	ld   a, $02
	ld   [$C006], a
	ldh  a, [$FFE6]
	ldh  [rSCX], a
	ld   a, $77
	jp   L000532
L0004FD:;J
	ld   a, $03
	ld   [$C006], a
	ldh  a, [$FFE8]
	ldh  [rSCX], a
	ld   a, $7B
	jp   L000532
L00050B:;J
	ld   a, $04
	ld   [$C006], a
	ldh  a, [$FFEA]
	ldh  [rSCX], a
	ld   a, $7F
	jp   L000532
L000519:;J
	ld   a, $05
	ld   [$C006], a
	ldh  a, [$FFEC]
	ldh  [rSCX], a
	ld   a, $83
	jp   L000532
L000527:;J
	ld   a, $06
	ld   [$C006], a
	ldh  a, [$FFEE]
	ldh  [rSCX], a
	ld   a, $87
L000532:;J
	ldh  [rLYC], a
	pop  af
	reti
L000536:;J
	ld   a, $0A
L000538:;J
	dec  a
	jp   nz, L000538
	ld   a, $E7
	ldh  [rLCDC], a
	pop  af
	reti
L000542:;J
	di
	push af
	push bc
	push de
	push hl
	ldh  a, [hROMBank]
	push af
	ld   hl, wMisc_C025
	bit  6, [hl]
	jp   z, L000587
	res  3, [hl]
	ld   a, [$C14B]
	or   a
	jp   z, L000583
L00055B: db $CB;X
L00055C: db $6E;X
L00055D: db $C2;X
L00055E: db $63;X
L00055F: db $05;X
L000560: db $C3;X
L000561: db $87;X
L000562: db $05;X
L000563: db $FA;X
L000564: db $42;X
L000565: db $C1;X
L000566: db $B7;X
L000567: db $C2;X
L000568: db $83;X
L000569: db $05;X
L00056A: db $21;X
L00056B: db $25;X
L00056C: db $C0;X
L00056D: db $CB;X
L00056E: db $DE;X
L00056F: db $3E;X
L000570: db $80;X
L000571: db $E0;X
L000572: db $02;X
L000573: db $21;X
L000574: db $C5;X
L000575: db $C1;X
L000576: db $34;X
L000577: db $21;X
L000578: db $49;X
L000579: db $C1;X
L00057A: db $CD;X
L00057B: db $78;X
L00057C: db $10;X
L00057D: db $CD;X
L00057E: db $71;X
L00057F: db $16;X
L000580: db $C3;X
L000581: db $87;X
L000582: db $05;X
L000583:;J
	xor  a
	ld   [$C146], a
L000587:;J
	ld   a, [wMisc_C026]
	bit  3, a
	jp   nz, L0007AA
	ld   a, [wMisc_C025]
	bit  3, a
	jp   nz, L0007AA
	ld   a, [$C00E]
	or   a
	jp   nz, L0007AA
	jp   L0005B8
L0005A1: db $FA;X
L0005A2: db $21;X
L0005A3: db $D9;X
L0005A4: db $CB;X
L0005A5: db $67;X
L0005A6: db $C2;X
L0005A7: db $B8;X
L0005A8: db $05;X
L0005A9: db $FA;X
L0005AA: db $22;X
L0005AB: db $D9;X
L0005AC: db $CB;X
L0005AD: db $57;X
L0005AE: db $C2;X
L0005AF: db $B8;X
L0005B0: db $05;X
L0005B1: db $FA;X
L0005B2: db $72;X
L0005B3: db $C1;X
L0005B4: db $B7;X
L0005B5: db $C2;X
L0005B6: db $A4;X
L0005B7: db $06;X
L0005B8:;J
	ld   a, [$D8C5]
	or   a
	jp   nz, L0005C9
	ld   a, [$D8C9]
	or   a
	jp   nz, L000602
	jp   L0006A4
L0005C9:;J
	ld   b, $03
	cp   a, b
	jp   nc, L0005D0
	ld   b, a
L0005D0:;J
	sub  a, b
	ld   [$D8C5], a
	ld   a, [$D8C0]
	ld   e, a
	ld   a, [$D8C1]
	ld   d, a
	ld   a, [$D8C2]
	ld   l, a
	ld   a, [$D8C3]
	ld   h, a
	ld   a, [$D8C4]
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	call CopyTiles
	ld   a, e
	ld   [$D8C0], a
	ld   a, d
	ld   [$D8C1], a
	ld   a, l
	ld   [$D8C2], a
	ld   a, h
	ld   [$D8C3], a
	jp   L000638
L000602:;J
	ld   b, $03
	cp   a, b
	jp   nc, L000609
	ld   b, a
L000609:;J
	sub  a, b
	ld   [$D8C9], a
	ld   a, [$D8C0]
	ld   e, a
	ld   a, [$D8C1]
	ld   d, a
	ld   a, [$D8C6]
	ld   l, a
	ld   a, [$D8C7]
	ld   h, a
	ld   a, [$D8C8]
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	call CopyTiles
	ld   a, e
	ld   [$D8C0], a
	ld   a, d
	ld   [$D8C1], a
	ld   a, l
	ld   [$D8C6], a
	ld   a, h
	ld   [$D8C7], a
L000638:;J
	ld   a, [$D8C5]
	or   a
	jp   nz, L0006A4
	ld   a, [$D8C9]
	or   a
	jp   nz, L0006A4
	ld   hl, wOBJInfo_Pl1+iOBJInfo_Status
	res  0, [hl]
	set  3, [hl]
	ld   hl, $D922
	bit  0, [hl]
	jp   nz, L00066F
	ld   hl, $D93D
	ld   de, $D93A
	ld   a, [hl]
	or   a
	jp   z, L00066F
	ld   [de], a
	ld   [hl], $00
	inc  de
	inc  hl
	ld   a, [hl]
	ld   [de], a
	ld   [hl], $00
	inc  de
	inc  hl
	ld   a, [hl]
	ld   [de], a
	ld   [hl], $00
L00066F:;J
	ld   hl, $D8CA
	ld   de, $D8D0
	ldi  a, [hl]
	ld   [de], a
	inc  de
	ldi  a, [hl]
	ld   [de], a
	inc  de
	ldi  a, [hl]
	ld   [de], a
	inc  de
	ldi  a, [hl]
	ld   [de], a
	inc  de
	ldi  a, [hl]
	ld   [de], a
	inc  de
	ld   a, [hl]
	ld   [de], a
	ld   a, [$D681]
	ld   [$D682], a
	ld   a, [$D690]
	ld   [$D694], a
	ld   a, [$D691]
	ld   [$D695], a
	ld   a, [$D692]
	ld   [$D696], a
	ld   a, [$D693]
	ld   [$D697], a
L0006A4:;J
	jp   L0006BE
L0006A7: db $FA;X
L0006A8: db $21;X
L0006A9: db $DA;X
L0006AA: db $CB;X
L0006AB: db $67;X
L0006AC: db $C2;X
L0006AD: db $BE;X
L0006AE: db $06;X
L0006AF: db $FA;X
L0006B0: db $22;X
L0006B1: db $DA;X
L0006B2: db $CB;X
L0006B3: db $57;X
L0006B4: db $C2;X
L0006B5: db $BE;X
L0006B6: db $06;X
L0006B7: db $FA;X
L0006B8: db $72;X
L0006B9: db $C1;X
L0006BA: db $B7;X
L0006BB: db $C2;X
L0006BC: db $AA;X
L0006BD: db $07;X
L0006BE:;J
	ld   a, [$D8E5]
	or   a
	jp   nz, L0006CF
	ld   a, [$D8E9]
	or   a
	jp   nz, L000708
	jp   L0007AA
L0006CF:;J
	ld   b, $03
	cp   a, b
	jp   nc, L0006D6
	ld   b, a
L0006D6:;J
	sub  a, b
	ld   [$D8E5], a
	ld   a, [$D8E0]
	ld   e, a
	ld   a, [$D8E1]
	ld   d, a
	ld   a, [$D8E2]
	ld   l, a
	ld   a, [$D8E3]
	ld   h, a
	ld   a, [$D8E4]
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	call CopyTiles
	ld   a, e
	ld   [$D8E0], a
	ld   a, d
	ld   [$D8E1], a
	ld   a, l
	ld   [$D8E2], a
	ld   a, h
	ld   [$D8E3], a
	jp   L00073E
L000708:;J
	ld   b, $03
	cp   a, b
	jp   nc, L00070F
	ld   b, a
L00070F:;J
	sub  a, b
	ld   [$D8E9], a
	ld   a, [$D8E0]
	ld   e, a
	ld   a, [$D8E1]
	ld   d, a
	ld   a, [$D8E6]
	ld   l, a
	ld   a, [$D8E7]
	ld   h, a
	ld   a, [$D8E8]
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	call CopyTiles
	ld   a, e
	ld   [$D8E0], a
	ld   a, d
	ld   [$D8E1], a
	ld   a, l
	ld   [$D8E6], a
	ld   a, h
	ld   [$D8E7], a
L00073E:;J
	ld   a, [$D8E5]
	or   a
	jp   nz, L0007AA
	ld   a, [$D8E9]
	or   a
	jp   nz, L0007AA
	ld   hl, wOBJInfo_Pl2+iOBJInfo_Status
	res  0, [hl]
	set  3, [hl]
	ld   hl, $DA22
	bit  0, [hl]
	jp   nz, L000775
	ld   hl, $DA3D
	ld   de, $DA3A
	ld   a, [hl]
	or   a
	jp   z, L000775
	ld   [de], a
	ld   [hl], $00
	inc  de
	inc  hl
	ld   a, [hl]
	ld   [de], a
	ld   [hl], $00
	inc  de
	inc  hl
	ld   a, [hl]
	ld   [de], a
	ld   [hl], $00
L000775:;J
	ld   hl, $D8EA
	ld   de, $D8F0
	ldi  a, [hl]
	ld   [de], a
	inc  de
	ldi  a, [hl]
	ld   [de], a
	inc  de
	ldi  a, [hl]
	ld   [de], a
	inc  de
	ldi  a, [hl]
	ld   [de], a
	inc  de
	ldi  a, [hl]
	ld   [de], a
	inc  de
	ld   a, [hl]
	ld   [de], a
	ld   a, [$D6C1]
	ld   [$D6C2], a
	ld   a, [$D6D0]
	ld   [$D6D4], a
	ld   a, [$D6D1]
	ld   [$D6D5], a
	ld   a, [$D6D2]
	ld   [$D6D6], a
	ld   a, [$D6D3]
	ld   [$D6D7], a
L0007AA:;J
	ld   a, [wMisc_C028]
	bit  0, a
	jp   nz, L0007BA
	bit  2, a
	jp   nz, L0007E8
	jp   L0007FF
L0007BA:;J
	ldh  a, [rSTAT]
	and  a, $40
	jp   z, L0007FB
	ld   a, $E7
	ldh  [rLCDC], a
	ld   a, [$C15A]
	ldh  [rLYC], a
	xor  a
	ld   [$C006], a
	ldh  a, [$FFF0]
	ldh  [rBGP], a
	ld   a, [wMisc_C026]
	bit  3, a
	jp   nz, L0007E5
	ld   a, [wMisc_C025]
	bit  3, a
	jp   nz, L0007E5
	call $FF80
L0007E5:;J
	jp   L000802
L0007E8:;J
	ldh  a, [rSTAT]
	and  a, $40
	jp   z, L0007FB
	ld   a, $E7
	ldh  [rLCDC], a
	ld   a, $6F
	ldh  [rLYC], a
	ld   a, $1B
	ldh  [rBGP], a
L0007FB:;J
	xor  a
	ld   [$C006], a
L0007FF:;J
	call $FF80
L000802:;J
	ldh  a, [hScrollY]
	ldh  [rSCY], a
	ldh  a, [hScrollX]
	ldh  [rSCX], a
	ld   a, [wMisc_C026]
	bit  3, a
	jp   nz, L000845
	ld   a, [wMisc_C025]
	bit  3, a
	jp   nz, L000845
	call L001067
	ld   hl, wTimer
	inc  [hl]
	
	; If the "VBlank finished" flag is already $00, it means the code took too long to execute
	; and didn't set in time wVBlankNotDone to $01.
	; If the code later sets wVBlankNotDone to $01 it will have to wait an extra lag frame.
	; (why is this check even here -- it could be using "xor a" directly)
	ld   a, [wVBlankNotDone]
	or   a						; Status == 0?
	jr   z, L00082B				; If so, jump
	dec  a
	ld   [wVBlankNotDone], a
L00082B:

	ld   hl, hTaskTbl
	ld   de, TASK_SIZE
	ld   b, $03
L000833:;J
	bit  0, [hl]
	jp   z, L000840
	inc  hl
	dec  [hl]
	dec  hl
	jp   nz, L000840
	ld   [hl], $04
L000840:;J
	add  hl, de
	dec  b
	jp   nz, L000833
L000845:;J
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	pop  hl
	pop  de
	pop  bc
	pop  af
	reti
	
; =============== OBJLstS_WriteAll ===============
; Handles the sprites.
OBJLstS_WriteAll:
	push af
	push bc
	push de
	push hl
	
	; Save the current ROM bank since we'll be bankswitching for sprite mappings
	ldh  a, [hROMBank]
	push af
	
	; Initialize the pointer to the start of WorkOAM
	ld   a, LOW(wWorkOAM)
	ld   [wWorkOAMCurPtr_Low], a
	ld   a, HIGH(wWorkOAM)
	ld   [wWorkOAMCurPtr_High], a
	
	; If we're outside of gameplay, the priority checks and especially the player range enforcement should not be done.
	ld   a, [wMisc_C028]
	bit  MISCB_PL_RANGE_CHECK, a	; Is the bit set (checks enabled)?
	jp   z, .noGameplay				; If not, jump
	
.inGameplay:
	;
	; Switch player draw order every frame.
	; (so players flicker instead of being erased by the OBJ limit)
	;
	ld   a, [wTimer]
	bit  0, a						; wTimer % 2 != 0?
	jp   nz, .pl2Priority			; If so, jump
	
.pl1Priority:
	call Pl1_KeepInScreenRange
	call Pl2_KeepInScreenRange
	ld   hl, wOBJInfo2
	call OBJLstS_DoOBJInfoSlot
	ld   hl, wOBJInfo3
	call OBJLstS_DoOBJInfoSlot
	ld   hl, wOBJInfo_Pl1
	call OBJLstS_DoOBJInfoSlot
	ld   hl, wOBJInfo_Pl2
	call OBJLstS_DoOBJInfoSlot
	ld   hl, wOBJInfo4
	call OBJLstS_DoOBJInfoSlot
	ld   hl, wOBJInfo5
	call OBJLstS_DoOBJInfoSlot
	jp   .finalizeOAM
.pl2Priority:
	call Pl2_KeepInScreenRange
	call Pl1_KeepInScreenRange
	ld   hl, wOBJInfo3
	call OBJLstS_DoOBJInfoSlot
	ld   hl, wOBJInfo2
	call OBJLstS_DoOBJInfoSlot
	ld   hl, wOBJInfo_Pl2
	call OBJLstS_DoOBJInfoSlot
	ld   hl, wOBJInfo_Pl1
	call OBJLstS_DoOBJInfoSlot
	ld   hl, wOBJInfo5
	call OBJLstS_DoOBJInfoSlot
	ld   hl, wOBJInfo4
	call OBJLstS_DoOBJInfoSlot
.finalizeOAM:

	;
	; Clear the rest of the OAM entries, to avoid keeping unused OBJ from the previous frame.
	;
	
	ld   a, [wWorkOAMCurPtr_Low]	; HL = Current location of the OBJ writer	
	ld   l, a
	ld   a, [wWorkOAMCurPtr_High]
	ld   h, a
	ld   a, LOW(wWorkOAM_End)		; A = End of WorkOAM
.clrLoop:
	cp   l							; wWorkOAM_End < HL?
	jp   c, .end					; If so, jump
	ld   [hl], $00					; Clear first byte, which hides the sprite
	inc  hl							; HL += 4 (next entry)
	inc  hl
	inc  hl
	inc  hl
	jp   .clrLoop
	
.end:
	; Restore the previous bank
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	
	pop  hl
	pop  de
	pop  bc
	pop  af
	ret
	
.noGameplay:
	ld   hl, wOBJInfo0
	call OBJLstS_DoOBJInfoSlot
	ld   hl, wOBJInfo1
	call OBJLstS_DoOBJInfoSlot
	ld   hl, wOBJInfo2
	call OBJLstS_DoOBJInfoSlot
	ld   hl, wOBJInfo3
	call OBJLstS_DoOBJInfoSlot
	ld   hl, wOBJInfo4
	call OBJLstS_DoOBJInfoSlot
	ld   hl, wOBJInfo5
	call OBJLstS_DoOBJInfoSlot
	ld   hl, wOBJInfo6
	call OBJLstS_DoOBJInfoSlot
	ld   hl, wOBJInfo7
	call OBJLstS_DoOBJInfoSlot
	ld   hl, wOBJInfo8
	call OBJLstS_DoOBJInfoSlot
	jp   .finalizeOAM

; =============== mPL_KeepInScreenRange ===============
; Generates code to keep a player in the viewport's range.
; The viewport range is considered to be the area between $10-$A0 (+$08)
; IN
; - 1: Ptr to start of OBJInfo
mPL_KeepInScreenRange: MACRO
	; Ignore if the player isn't visible
	ld   a, [\1+iOBJInfo_Status]
	bit  OSTB_VISIBLE, a	; Visibility flag set?
	ret  z					; If not, return
	
	xor  a					; Clear movement amount
	ld   [\1+iOBJInfo_RangeMoveAmount], a
	
	;
	; Determine the distance between the player position and the viewport's (left) position.
	; If the distance is too small (player near the left border of the screen) or too large (near the right border),
	; forcefully try to keep it in range.
	;
	; An extra $08 is added to the result to account for the player's origin being at the center of the sprite,
	; compared to the screen origin being at the left corner of the screen.
	; TODO: VERIFY
	;
	
	; B = -ScrollX
	ld   a, [wFieldScrollX]
	cpl
	inc  a
	ld   b, a
	
	; Diff = PlayerX - ScrollX + $08
	ld   a, [\1+iOBJInfo_X]
	add  b				; -= ScrollX
	add  a, OBJ_OFFSET_X	; + $08
	
	cp   $10				; Diff < $10?
	jp   c, .forceRangeL	; If so, jump
	cp   SCREEN_H			; Diff >= $A0?
	jp   nc, .forceRangeR	; If so, jump
	ret						; Otherwise, nothing to do
	
.forceRangeL:
	; Determine how many pixels the player is off-screen.
	; MoveAmount = -(Diff - $10)
	sub  a, $10			; Subtract $10 to determine how many off-screen pixels
	cpl					; (Diff - $10) will be always negative, so force it back to positive
	inc  a
	ld   [\1+iOBJInfo_RangeMoveAmount], a		; Save it here
	ld   b, a
	
	; PlayerX += MoveAmount
	ld   a, [\1+iOBJInfo_X]
	add  b			; Add that positive value here to force it to the left border
	ld   [\1+iOBJInfo_X], a
	ret
	
.forceRangeR:
	; Determine how many pixels the player is off-screen.
	; MoveAmount = -(Diff - $A0)
	sub  a, SCREEN_H	; Subtract $A0 to determine how many off-screen pixels
	cpl					; (Diff - $A0) will always be positive, so force the value to negative
	inc  a
	ld   [\1+iOBJInfo_RangeMoveAmount], a		; Save it here
	ld   b, a
	
	; PlayerX -= MoveAmount
	ld   a, [\1+iOBJInfo_X]
	add  b			; Add that negative value here to force it to the right border
	ld   [\1+iOBJInfo_X], a
	ret
ENDM

; =============== Pl1_KeepInScreenRange ===============
; Keeps Player 1 in the viewport's range.
Pl1_KeepInScreenRange: mPL_KeepInScreenRange wOBJInfo_Pl1
; =============== Pl2_KeepInScreenRange ===============
; Keeps Player 2 in the viewport's range.
Pl2_KeepInScreenRange: mPL_KeepInScreenRange wOBJInfo_Pl2

; =============== OBJLstS_DoOBJInfoSlot ===============
; Handles the values in the OBJInfo structure before writing the sprite mapping to the OAM mirror.
; IN
; - HL: Ptr to a wOBJInfo structure.
OBJLstS_DoOBJInfoSlot:

	; If the sprite is hidden, don't draw it to OAM
	ldi  a, [hl]				; Read iOBJInfo_Status
	bit  OSTB_VISIBLE, a		; Visibility flag set?
	ret  z						; If not, return
	
	; Copy over the user-controlled flags to the two user-controlled flags used by sprite mappings.
	; These are or'd over.
	ld   b, a					; B = A
	ld   [wOBJLstUserFlags], a		; Primary ptr
	ld   [wOBJLstUserFlagsSec], a	; Secondary ptr
	
	;--
	;
	; Depending on bit0 of iOBJInfo_Status, also use a *different* set of user-controlled flags over a different byte.
	; Later on, this same bit is also used to pick an alternate sprite mappings/animation pointer.
	;
	; These are xor'd over.
	bit  OSTB_ALTSET, a			; Is the bit set?
	jp   nz, .useUserSet1		; If so, jump
	
.useUserSet0:	
	ldi  a, [hl]				; Read iOBJInfo_UserFlags0	
	ld   [wOBJLstUserSetFlags], a
	inc  hl
	jp   .calcRelX
.useUserSet1:
	inc  hl
	ldi  a, [hl]				; Read iOBJInfo_UserFlags1
	ld   [wOBJLstUserSetFlags], a

.calcRelX:
	;--
	;
	; Determine the relative X position of the sprite.
	; RelX = AbsoluteX - ScrollX + OBJ_OFFSET_X
	;

	; C = Sprite X position
	ld   c, [hl]				; Read iOBJInfo_X
	; A = -ScrollX
	ld   a, [wFieldScrollX]
	cpl
	inc  a
	
	add  c					; XPos - ScrollX
	add  a, OBJ_OFFSET_X		; + OBJ_OFFSET_X
	
	; Seek to next entry (this has 2 bytes assigned?)
	inc  hl						; HL += 2
	inc  hl
	ld   [wOBJLstCurRelX], a		; Save the result here
	
	
.calcRelY:
	;--
	;
	; Determine the relative Y position of the sprite.
	; RelY = AbsoluteY - ScrollY
	;
	
	; C = Sprite Y position
	ld   c, [hl]				; Read iOBJInfo_Y
	; A = -ScrollY
	ld   a, [wFieldScrollY]
	cpl
	inc  a
	
	add  c					; YPos - ScrollY
	; Seek to next entry (this has 2 bytes assigned?)
	inc  hl						; HL += 2
	inc  hl
	ld   [wOBJLstCurRelY], a
	
.setRelPos:
	;--
	;
	; Save the relative positions to the sprite info
	;
	; $07
	inc  hl					; HL += 4
	inc  hl
	inc  hl
	inc  hl
	
	; $0B
	ld   a, [wOBJLstCurRelX]
	ldi  [hl], a			; Save to iOBJInfo_RelX
	; $0C
	ld   a, [wOBJLstCurRelY]
	ldi  [hl], a			; Save to iOBJInfo_RelY
	

	;--
	;
	; Get the base tile ID number for the sprite mapping and store it to C.
	; All sprites in the sprite mapping have the tileID number relative to this,
	; since the graphics can be potentially loaded at any position in VRAM.
	;
	
	ld   c, [hl]			; Read iOBJInfo_TileIDBase
	inc  hl
	
	; ??? There's some weird logic with the tile id base.
	; If the tile ID base has bit1 set, $20 will be added to the tile ID.
	; If OSTB_ALTSET is set, however, said bit1 is inverted first.
	
	; Note that OBJ graphics are copied in "chunks" that start at a $20 tile boundary.
	
	
	; If OSTB_ALTSET is set, invert bit1
	ld   a, b				; Read back status
	bit  OSTB_ALTSET, a		; bit0 set?
	jr   z, .noInvTileBit	; If not, skip
	xor  $02				; Invert bit1
.noInvTileBit:
	; If bit1 is set, add $20 tiles (two rows of GFX) to the base tileID
	bit  1, a				; Is bit1 set?
	jp   z, .noAdd20		; If so, skip
	ld   a, $20				; C += $20
	add  c
	ld   c, a
.noAdd20:;J
	inc  hl
	inc  hl
	
	
	;--
	;
	; Depending on Status->bit0, use a different set of sprite mappings.
	;
	
	;
	; Note that the sprite mapping offset (iOBJInfo_OBJLstPtrTblOffset*) is always a multiple of $04.
	; This is because each entry in the table has space for 2 sprite mapping pointers.
	;
;----------
	; $10 
	push bc
	bit  OSTB_ALTSET, b		; bit0 set?
	jr   nz, .usePtrSet1	; If so, jump
	
.usePtrSet0:
	ldi  a, [hl]			; Read iOBJInfo_BankNum0
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	; $11
	ld   e, [hl]			; Read iOBJInfo_OBJLstPtrTbl_Low0
	inc  hl
	; $12
	ld   d, [hl]			; Read iOBJInfo_OBJLstPtrTbl_High0
	inc  hl
	; $13
	ld   c, [hl]			; Read iOBJInfo_OBJLstPtrTblOffset0
	inc  hl
	
	; Skip to byte18
	inc  hl
	inc  hl
	inc  hl
	inc  hl
	; $18
	jr   .drawMainOBJ
.usePtrSet1:
	; Use the secondary set
	
	; Skip to byte14
	inc  hl
	inc  hl
	inc  hl
	inc  hl
	; $14
	ldi  a, [hl]			; Read iOBJInfo_BankNum1
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	; $15
	ld   e, [hl]			; Read iOBJInfo_OBJLstPtrTbl_Low1
	inc  hl
	; $16
	ld   d, [hl]			; Read iOBJInfo_OBJLstPtrTbl_High1
	inc  hl
	; $17
	ld   c, [hl]			; Read iOBJInfo_OBJLstPtrTblOffset1
	inc  hl
	; $18
	
.drawMainOBJ:

	; Switch HL and DE
	push de
	push hl
	pop  de
	pop  hl
	
	; Index the sprite mapping table
	
	; HL = Start of OBJLstPtrTable (animation/sprite mappings table)
	ld   b, $00		; BC = Index
	add  hl, bc		; Offset it
	pop  bc
;----------

	push hl	
	call OBJLstS_DoOBJLstHeader
	pop  hl
	
.chkDrawSecOBJ:
	;
	; Try to draw the secondary sprite mapping, if it's defined.
	; If it isn't defined, its pointer in the animation table will be set to $FFFF.
	;
	
	; Seek to the next sprite mapping pointer.
	inc  hl
	inc  hl
	; Read it out to DE
	ld   e, [hl]
	inc  hl
	ld   a, [hl]
	
	cp   HIGH(OBJLSTPTR_NONE) ; Is the high byte $FF? ($FFFF)
	ret  z                    ; If so, there's nothing else to draw
	ld   d, a
	
	; HL = DE
	push de
	pop  hl
	
	jp   OBJLstS_DoOBJLstHeaderSec
	
; =============== OBJLstS_DoOBJLstHeader ===============
; Parses out the header for the primary sprite mapping before writing it to the OAM mirror.
; IN
; - HL: Ptr to OBJLstPtrTable entry
; - DE: Ptr to actor struct byte18
; - C : Tile ID base
OBJLstS_DoOBJLstHeader:

	;--
	;
	; Read out to HL the pointer off the animation table.
	; This will point to the header of the actual sprite mapping (OBJLst).
	;
	push de			; Save DE
	; Read ptr to DE
	ld   e, [hl]	
	inc  hl
	ld   d, [hl]	
	; HL = DE
	push de			
	pop  hl
	
	pop  de			; Restore DE
	;--
	
	; Now HL points to the start of a sprite mapping, at the header.
	
	;
	; BYTE 0 - Flags
	;
	
	; Save the raw flags value
	ldi  a, [hl]					; Read iOBJLstHdr_Flags
	ld   [wOBJLstHeaderFlags], a	; 
	
	; Add the X/Y flip flags on top of the existing ones
	and  a, OLF_XFLIP|OLF_YFLIP		
	ld   b, a
	ld   a, [wOBJLstUserFlags]
	or   b
	ld   [wOBJLstUserFlags], a
	
	
	; Are these for the second sprite mapping???
	;
	; BYTE 1 - ???
	;
	
	; Copy over item1 to byte18
	ldi  a, [hl]		
	ld   [de], a
	inc  de
	
	;
	; BYTE 2 - ???
	;
	
	; Copy over item2 to byte19
	ldi  a, [hl]		
	ld   [de], a
	inc  hl
	inc  hl
	inc  hl
	
	;
	; BYTE 6-7 - Sprite data pointer (iOBJLst_OBJCount)
	;
	
	; Save it to DE for OBJLstS_WriteToWorkOAM
	ld   e, [hl]
	inc  hl
	ld   d, [hl]
	inc  hl
	
	;
	; BYTE 8 - X Offset
	;
	ldi  a, [hl]				; Read iOBJLstHdr_XOffset
	ld   [wOBJLstCurXOffset], a
	
	;
	; BYTE 9 - Y Offset
	;
	ld   a, [hl]				; Read iOBJLstHdr_YOffset
	ld   [wOBJLstCurYOffset], a
	
	jp   OBJLstS_WriteToWorkOAM
	
; =============== OBJLstS_DoOBJLstHeaderSec ===============
; Parses out the header for the secondary sprite mapping before writing it to the OAM mirror.
; Compared to the primary sprite mapping, this seems to use a different format for the header.
; IN
; - HL: Ptr to start of second OBJLst (at the header)
; - C : Tile ID base (always after the one from the primary header)
OBJLstS_DoOBJLstHeaderSec:;J

	;
	; BYTE 0 - Flags
	;
	
	; Save the raw flags value
	ldi  a, [hl]					; Read iOBJLstHdrSec_Flags
	ld   [wOBJLstHeaderFlags], a	; 
	
	; Add the X/Y flip flags on top of the existing ones
	and  a, OLF_XFLIP|OLF_YFLIP		
	ld   b, a
	ld   a, [wOBJLstUserFlagsSec]
	or   b
	ld   [wOBJLstUserFlags], a
	
	; $01
	inc  hl
	; $02
	inc  hl
	; $03
	inc  hl
	
	;
	; BYTE 4-5 - Sprite data pointer (iOBJLst_OBJCount)
	;
	; DE = Ptr at item4-5
	ld   e, [hl]
	inc  hl
	ld   d, [hl]
	inc  hl
	
	;
	; BYTE 6 - X Offset
	;
	ldi  a, [hl]
	ld   [wOBJLstCurXOffset], a
	
	;
	; BYTE 7 - Y Offset
	;
	ld   a, [hl]
	ld   [wOBJLstCurYOffset], a
	
; =============== OBJLstS_WriteToWorkOAM ===============
; IN
; - DE: Ptr to OBJLst data
; -  C: Tile ID base
OBJLstS_WriteToWorkOAM:

	; Move over the actual OBJ list from DE to HL
	; HL = Ptr to start of OBJLst (tile count, then table of "OBJ")
	push de
	pop  hl
	
	;
	; Read the cursor position for writing to OAM
	;
	ld   a, [wWorkOAMCurPtr_Low]	; DE = OAMPtr
	ld   e, a
	ld   a, [wWorkOAMCurPtr_High]
	ld   d, a
	
	;--
	;
	; Calculate the effective flags value for the sprite mapping..
	; Merge the sprite mapping (Default) X/Y flip options with the user-controlled flip options
	;
	
	; B = Default flip flags for the sprite mapping
	ld   a, [wOBJLstUserFlags]		
	and  a, OLF_XFLIP|OLF_YFLIP
	ld   b, a
	
	; A = High nybble of the user-controlled flags
	ld   a, [wOBJLstUserSetFlags]		
	and  a, $F0
	
	; Merge the flags over
	xor  b			
	ld   [wOBJLstCurFlags], a
	
	;--
	;
	; Depending on the X/Y flipping combinations, offset the sprite mappings in a particular way,
	;
	
	and  a, OLF_XFLIP|OLF_YFLIP		; Filter X/Y flip options
	cp   OLF_XFLIP					; Flipped horizontally?
	jp   z, OBJLstS_Draw_XFlip		; If so, jump
	cp   OLF_YFLIP					; Flipped vertically?
	jp   z, OBJLstS_Draw_YFlip		; If so, jump
	cp   OLF_XFLIP|OLF_YFLIP		; Flipped horizontally + vertically?
	jp   z, OBJLstS_Draw_XYFlip		; If so, jump
									; Otherwise, no flipping
	
; =============== OBJLstS_Draw_*Flip ===============
; Set of subroutines to draw the individual sprites of a sprite mapping to WorkOAM.
; These are almost identical to each other -- the only differences involve the offsetting of the X/Y positions
; to account for the sprite mapping flipping.
;
; IN
; - HL: Ptr to OBJLst data
; -  C: Tile ID base

; =============== OBJLstS_Draw_NoFlip ===============
; XOffset: Normal
; YOffset: Normal
OBJLstS_Draw_NoFlip:

	; First, calculate the effective origin of the sprite mapping (DispX/DispY)
	; All of the single sprites will be relative to this position.
	call OBJLstS_CalcDispCoords
	
	; Read the first byte of the OBJLst, which marks how many 8x16 sprites the sprite mapping contains.
	; After that the rest is a table of 3 byte structs:
	; - 0: XPos
	; - 1: YPos
	; - 2: TileID [+ Flags]
	
	; B = Number of OBJ left
	; DE = WorkOAM Target
	; HL = Source OBJ list
	ld   b, [hl]	; Read iOBJLst_OBJCount
	inc  hl
	push bc			; Save total count for later
.loop:
	; The actual array of OBJ data follows
	
	push bc			; Save remaining count
	
	; Byte0: OBJYPos + wOBJLstCurDispY
	ld   b, [hl]				; Read out relative Y pos
	inc  hl						; SrcPtr++
	ld   a, [wOBJLstCurDispY]	; Read Y origin
	add  b						; Add them together
	ld   [de], a				; Write it out
	inc  de						; OAMPtr++
	
	; Byte1: OBJXPos + wOBJLstCurDispX
	ld   b, [hl]				; Read out relative X pos
	inc  hl						; SrcPtr++
	ld   a, [wOBJLstCurDispX]	; Read X origin
	add  b						; Add them together
	ld   [de], a				; Write it out
	inc  de						; OAMPtr++
	
	; Write over the tile ID and flags
	call OBJLstS_Draw_WriteCommon
	
	pop  bc				; Restore remaining count
	dec  b				; OBJLeft == 0?
	jr   nz, .loop		; If not, loop
	pop  bc				; Restore total OBJ count
	jp   OBJLstS_UpdateOAMPos		; Add it over to the stats
	
; =============== OBJLstS_Draw_XFlip ===============
; XOffset: -$08
; YOffset: Normal
OBJLstS_Draw_XFlip:
	call OBJLstS_CalcDispCoords
	ld   b, [hl]
	inc  hl
	push bc
.loop:
	push bc
	; Byte0: OBJYPos + wOBJLstCurDispY
	ld   b, [hl]
	inc  hl
	ld   a, [wOBJLstCurDispY]
	add  b
	ld   [de], a
	inc  de
	
	; Byte1: OBJXPos - wOBJLstCurDispX - $08
	ldi  a, [hl]				; Read out relative X pos
	cpl							; Invert bits (A = -A-1)
	sub  a, $07					; A -= 7
	ld   b, a
	ld   a, [wOBJLstCurDispX]
	add  b
	ld   [de], a
	inc  de
	
	; Write over the tile ID and flags
	call OBJLstS_Draw_WriteCommon
	
	pop  bc
	dec  b
	jr   nz, .loop
	pop  bc
	jp   OBJLstS_UpdateOAMPos
	
; =============== OBJLstS_Draw_YFlip ===============
; XOffset: Normal
; YOffset: -$50
OBJLstS_Draw_YFlip:
	call OBJLstS_CalcDispCoords
	ld   b, [hl]
	inc  hl
	push bc
.loop:
	push bc
	; Byte0: OBJYPos - wOBJLstCurDispY - $50
	; $50 seems to be picked for being high enough
	ldi  a, [hl]
	cpl
	sub  a, $AF
	ld   b, a
	ld   a, [wOBJLstCurDispY]
	add  b
	ld   [de], a
	inc  de
	
	; Byte1: OBJXPos + wOBJLstCurDispX
	ld   b, [hl]
	inc  hl
	ld   a, [wOBJLstCurDispX]
	add  b
	ld   [de], a
	inc  de
	
	; Write over the tile ID and flags
	call OBJLstS_Draw_WriteCommon
	
	pop  bc
	dec  b
	jr   nz, .loop
	pop  bc
	jp   OBJLstS_UpdateOAMPos
; =============== OBJLstS_Draw_YFlip ===============
; XOffset: -$08
; YOffset: -$50
OBJLstS_Draw_XYFlip:
	call OBJLstS_CalcDispCoords
	ld   b, [hl]
	inc  hl
	push bc
.loop:
	push bc
	
	; Byte0: OBJYPos - wOBJLstCurDispY - $50
	ldi  a, [hl]
	cpl
	sub  a, $AF
	ld   b, a
	ld   a, [wOBJLstCurDispY]
	add  b
	ld   [de], a
	inc  de
	
	; Byte1: OBJXPos - wOBJLstCurDispX - $08
	ldi  a, [hl]
	cpl
	sub  a, $07
	ld   b, a
	ld   a, [wOBJLstCurDispX]
	add  b
	ld   [de], a
	inc  de
	
	; Write over the tile ID and flags
	call OBJLstS_Draw_WriteCommon
	
	pop  bc
	dec  b
	jr   nz, .loop
	pop  bc
	
; =============== OBJLstS_UpdateOAMPos ===============
OBJLstS_UpdateOAMPos:
	; Save new WorkOAM position
	ld   a, e						
	ld   [wWorkOAMCurPtr_Low], a
	ld   a, d
	ld   [wWorkOAMCurPtr_High], a
	
	; Update the tile ID base, in case there's a secondary sprite mapping at this slot.
	; C += B*2 (*2 since we're in 8x16 tile mode)
	ld   a, c	
	add  b
	add  b
	ld   c, a
	ret
	
; =============== OBJLstS_CalcDispCoords ===============
; Calculates the "final" origin coordinates for the sprite mapping.
;
; WIPES
; - B
OBJLstS_CalcDispCoords:


	;
	; Calculate the effective Y location of the sprite mapping on-screen.
	;
	
	; wOBJLstCurDispY = wOBJLstCurRelY + wOBJLstCurYOffset
	ld   a, [wOBJLstCurYOffset]
	ld   b, a
	
	ld   a, [wOBJLstCurRelY]
	add  b
	ld   [wOBJLstCurDispY], a
	
	;
	; Calculate the effective X location of the sprite mapping on-screen.
	; Unlike with the Y location, here flipping the sprite horizontally inverts the X offset.
	;
	
	ld   a, [wOBJLstUserSetFlags]
	and  a, OLF_XFLIP			; Is the X flip flag set?
	jp   nz, .invXOff			; If so, jump
.normXOff:
	ld   a, [wOBJLstCurXOffset]	; B = wOBJLstCurXOffset
	jp   .setX
.invXOff:;J
	ld   a, [wOBJLstCurXOffset] ; B = -wOBJLstCurXOffset
	cpl
	inc  a
.setX:
	; wOBJLstCurDispX = wOBJLstCurRelX + B
	ld   b, a					
	ld   a, [wOBJLstCurRelX]
	add  b
	ld   [wOBJLstCurDispX], a
	ret
	
; =============== OBJLstS_Draw_WriteCommon ===============
; IN
; - DE: WorkOAM Target
; - HL: Ptr to the "tileID+Flags" byte of the source OBJ list
; -  C: Tile ID base
OBJLstS_Draw_WriteCommon:

	; The third byte of the OBJ data contains the relative tile ID and optionally some tile-specific flags.
	; Not every sprite mapping makes use of them though -- it depends on a flag in the sprite mapping header.

	ld   a, [wOBJLstHeaderFlags]
	bit  OLFB_USETILEFLAGS, a		; Are tile-specific flags enabled for this sprite mapping?
	jp   nz, .withFlag				; If so, jump
	
.noFlag:
	;--
	; The upper two bits of the byte are part of the tileID.
	; Nothing special to do.

	; byte2 = OBJTileId + TileIDBase
	ldi  a, [hl]				; Read Tile ID
	add  c
	ld   [de], a
	inc  de
	;--
	; byte3 = wOBJLstCurFlags
	ld   a, [wOBJLstCurFlags]
	ld   [de], a				
	inc  de
	
	jp   .end
.withFlag:
	;--
	; The upper two bits of the byte contain flags.
	; These must be removed from the tile ID.
	
	ldi  a, [hl]				; Read Tile ID
	push af
	; byte2 = (OBJTileId & $3F) + TileIDBase
	and  a, $3F					; Remove upper two bits
	add  c						; Add tile ID base
	ld   [de], a
	inc  de
	pop  af
	
	;--
	; byte3 = wOBJLstCurFlags ^ (OBJTileId >> 1)
	; >> 1 because these are shifted by that amount from the proper values of OLFB_XFLIP and OLFB_YFLIP
	and  a, $C0						; Filter the upper two bits
	srl  a							; Shift flag bits to correct location
	ld   b, a						; B = Tile-specific flags
	ld   a, [wOBJLstCurFlags]		; A = Calculated flags
	xor  b							; Merge the flags
	ld   [de], a					; Save the result
	inc  de
.end:
	ret
	
L000B9E:;JC
	ldh  a, [hROMBank]
	push af
	res  3, [hl]
	push hl
	ld   de, $0010
	add  hl, de
	ldi  a, [hl]
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ld   e, [hl]
	inc  hl
	ld   d, [hl]
	inc  hl
	ld   c, [hl]
	ld   b, $00
	push de
	push hl
	pop  de
	pop  hl
	add  hl, bc
	jp   L000C5B
L000BBD:;JC
	ldh  a, [hROMBank]
	push af
	res  3, [hl]
	ld   a, [hl]
	and  a, $11
	jp   nz, L000D65
	push hl
	ld   de, $001B
	add  hl, de
	ld   a, [hl]
	or   a
	jp   z, L000BD8
	dec  a
	ld   [hl], a
	pop  hl
	jp   L000D65
L000BD8:;J
	inc  hl
	ldd  a, [hl]
	ld   [hl], a
	pop  hl
	push hl
	ld   de, $0010
	add  hl, de
	ldi  a, [hl]
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ld   e, [hl]
	inc  hl
	ld   d, [hl]
	inc  hl
	ld   a, [hl]
	add  a, $04
	ld   [hl], a
	ld   b, $00
	ld   c, a
	push de
	push hl
	pop  de
	pop  hl
	push hl
	add  hl, bc
	inc  hl
	ld   a, [hl]
	cp   $FF
	jp   nz, L000C0C
	ld   a, [de]
	sub  a, $04
	ld   [de], a
	pop  hl
	pop  hl
	ld   a, [hl]
	or   a, $10
	ld   [hl], a
	jp   L000D65
L000C0C:;J
	dec  hl
	pop  de
	jp   L000C5B
L000C11:;C
	ldh  a, [hROMBank]
	push af
	res  3, [hl]
	ld   a, [hl]
	and  a, $11
	jp   nz, L000D65
	push hl
	ld   de, $001B
	add  hl, de
	ld   a, [hl]
	or   a
	jp   z, L000C2C
	dec  a
	ld   [hl], a
	pop  hl
	jp   L000D65
L000C2C:;J
	inc  hl
	ldd  a, [hl]
	ld   [hl], a
	pop  hl
	push hl
	ld   de, $0010
	add  hl, de
	ldi  a, [hl]
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ld   e, [hl]
	inc  hl
	ld   d, [hl]
	inc  hl
	ld   a, [hl]
	add  a, $04
	ld   [hl], a
	ld   b, $00
	ld   c, a
	push de
	push hl
	pop  de
	pop  hl
	push hl
	add  hl, bc
	inc  hl
	ld   a, [hl]
	cp   $FF
	jp   nz, L000C59
	xor  a
	ld   [de], a
	pop  hl
	jp   L000C5B
L000C59:;J
	dec  hl
	pop  de
L000C5B:;J
	pop  bc
	ld   e, [hl]
	inc  hl
	ld   d, [hl]
	inc  hl
	push de
	push hl
	pop  de
	pop  hl
	bit  7, [hl]
	jp   nz, L000D65
	push bc
	ld   a, [bc]
	ld   [$C014], a
	bit  0, a
	jp   nz, L000C7E
	xor  $02
	or   a, $01
	ld   [bc], a
	ld   [wOBJLstUserFlags], a
	jp   L000C86
L000C7E:;J
	ld   [wOBJLstUserFlags], a
	xor  $02
	ld   [$C014], a
L000C86:;J
	push de
	push hl
	ld   hl, $001D
	add  hl, bc
	ld   e, [hl]
	inc  hl
	ld   d, [hl]
	pop  hl
	inc  hl
	inc  hl
	inc  hl
	push hl
	ld   hl, $000E
	add  hl, bc
	ld   c, [hl]
	inc  hl
	ld   b, [hl]
	pop  hl
	ld   a, [wOBJLstUserFlags]
	bit  1, a
	jp   z, L000CA8
	ld   a, $02
	add  b
	ld   b, a
L000CA8:;J
	ld   a, c
	ld   [de], a
	inc  de
	ld   a, b
	ld   [de], a
	inc  de
	call L000D6C
	ld   c, [hl]
	inc  hl
	ld   b, [hl]
	ld   a, [bc]
	add  a, a
	ld   [de], a
	inc  de
	pop  hl
	ld   c, [hl]
	inc  hl
	ld   b, [hl]
	ld   a, b
	cp   $FF
	jp   nz, L000CCD
	xor  a
	ld   [de], a
	inc  de
	ld   [de], a
	inc  de
	inc  de
	ld   [de], a
	inc  de
	jp   L000CDA
L000CCD:;J
	push bc
	pop  hl
	inc  hl
	call L000D6C
	ld   c, [hl]
	inc  hl
	ld   b, [hl]
	ld   a, [bc]
	add  a, a
	ld   [de], a
	inc  de
L000CDA:;J
	ld   hl, $FFF6
	add  hl, de
	push hl
	pop  bc
	ld   hl, $0010
	add  hl, bc
	push hl
	pop  de
	ld   hl, $0002
	add  hl, bc
	ld   a, [de]
	cp   a, [hl]
	jp   nz, L000D48
	inc  de
	inc  hl
	ld   a, [de]
	cp   a, [hl]
	jp   nz, L000D48
	inc  de
	inc  hl
	ld   a, [de]
	cp   a, [hl]
	jp   nz, L000D48
	inc  de
	inc  hl
	inc  hl
	ld   a, [de]
	cp   a, [hl]
	jp   nz, L000D48
	inc  de
	inc  hl
	ld   a, [de]
	cp   a, [hl]
	jp   nz, L000D48
	inc  de
	inc  hl
	ld   a, [de]
	cp   a, [hl]
	jp   nz, L000D48
	ld   hl, $0002
	add  hl, bc
	xor  a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	pop  bc
	ld   a, [$C014]
	res  0, a
	set  3, a
	ld   [bc], a
	ld   hl, $0001
	add  hl, bc
	ldi  a, [hl]
	ld   [hl], a
	ld   hl, $0010
	add  hl, bc
	push hl
	pop  de
	ld   hl, $0014
	add  hl, bc
	ld   a, [de]
	ldi  [hl], a
	inc  de
	ld   a, [de]
	ldi  [hl], a
	inc  de
	ld   a, [de]
	ldi  [hl], a
	inc  de
	ld   a, [de]
	ldi  [hl], a
	inc  de
	jp   L000D65
L000D48:;J
	ld   hl, $000A
	add  hl, bc
	push hl
	pop  de
	ld   hl, $0002
	add  hl, bc
	ldi  a, [hl]
	ld   [de], a
	inc  de
	ldi  a, [hl]
	ld   [de], a
	inc  de
	ldi  a, [hl]
	ld   [de], a
	inc  de
	inc  hl
	ldi  a, [hl]
	ld   [de], a
	inc  de
	ldi  a, [hl]
	ld   [de], a
	inc  de
	ld   a, [hl]
	ld   [de], a
	pop  bc
L000D65:;J
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret
L000D6C:;C
	ldi  a, [hl]
	ld   [de], a
	inc  de
	ldi  a, [hl]
	ld   [de], a
	inc  de
	ldi  a, [hl]
	ld   [de], a
	inc  de
	ret
L000D76:;C
	ld   b, $1F
L000D78:;R
	ld   a, [de]
	inc  de
	ldi  [hl], a
	dec  b
	jr   nz, L000D78
	ld   b, $14
	xor  a
L000D81:;R
	ldi  [hl], a
	dec  b
	jr   nz, L000D81
	ret
	
; =============== ClearOBJInfo ===============
; Zeroes out all of the nine wOBJInfo structures.
ClearOBJInfo:
	ld   hl, wOBJInfo0			; HL = Initial addr
	ld   de, OBJINFO_SIZE * 9	; DE = Bytes to clear
	ld   b, $00					; B = Overwrite with
.loop:
	ld   a, b					; Write $00
	ldi  [hl], a
	dec  de						; BytesLeft--
	ld   a, d
	or   a, e					; BytesLeft == 0?
	jr   nz, .loop				; If not, loop
	ret

; =============== Clear*Map ===============
; Sets of subroutines for clearing tilemaps.

; =============== ClearBGMap ===============
ClearBGMap:
	ld   hl, BGMap_Begin			; HL = Tilemap Ptr
	ld   d, $00						; D  = Write $00
	jp   ClearTilemapCustom
; =============== ClearWINDOWMap ===============
ClearWINDOWMap:
	ld   hl, WINDOWMap_Begin		; HL = Tilemap Ptr
	ld   d, $00						; D  = Write $00
	jp   ClearTilemapCustom
; =============== ClearBGMapCustom ===============	
; IN
; - D: Value to set
ClearBGMapCustom:
	ld   hl, BGMap_Begin			; HL = Tilemap Ptr
	jp   ClearTilemapCustom
; =============== ClearWINDOWMapCustom ===============
; IN
; - D: Value to set
ClearWINDOWMapCustom:
	ld   hl, WINDOWMap_Begin		; HL = Tilemap Ptr

; =============== ClearWINDOWMapCustom ===============
; IN
; - HL: Tilemap ptr
; -  D: Value to set	
ClearTilemapCustom:
	ld   bc, $0400					; BC = Bytes to clear
	
; =============== MemSetOnHBlank ===============
; Fills a memory range during HBlank.
; Use for clearing VRAM.
; IN
; - HL: Starting address
; - BC: Bytes to overwrite
; -  D: Value to be set
MemSetOnHBlank:
	mWaitForHBlank		
	ld   a, d			; Write D to HL 
	ldi  [hl], a		; HL++
	dec  bc				; BytesLeft--
	ld   a, b			; BC == 0?
	or   a, c
	jp   nz, MemSetOnHBlank	; If not, loop
	ret
	
L000DC2:;JCR
	push bc
	push hl
L000DC4:;J
	push bc
	push af
	push af
	ld   a, [de]
	ld   b, a
	pop  af
	add  b
	inc  de
	push af
L000DCD:;J
	mWaitForHBlank
	pop  af
	ldi  [hl], a
	pop  af
	pop  bc
	dec  b
	jp   nz, L000DC4
	pop  hl
	ld   bc, $0020
	add  hl, bc
	pop  bc
	dec  c
	jr   nz, L000DC2
	ret
; =============== CopyBGToRect ===============
; Copies a partial tilemap to a location in VRAM.
; IN
; - DE: Ptr to uncompressed tilemap
; - HL: Destination Ptr in VRAM
; - B: Rect Width
; - C: Rect Height
CopyBGToRect:
	push bc						; Save rect dimensions
		push hl					; Save main destination ptr since we're moving down later
.loop:	
			mWaitForHBlank		; Since we're copying to VRAM
			
			ld   a, [de]		; Copy the tile over
			ldi  [hl], a		
			inc  de				; Dest++, Src++
			dec  b				; Copied the entire row?
			jp   nz, .loop		; If not, jump
		pop  hl					; Restore dest ptr
		ld   bc, BG_TILECOUNT_H	; Move down 1 tile
		add  hl, bc
	pop  bc						; Restore rect dimensions
	dec  c						; HeightLeft--
	jr   nz, CopyBGToRect		; Copied all rows? If not, jump
	ret
L000E00:;C
	ld   a, d
L000E01:;R
	push bc
	push hl
L000E03:;J
	push af
L000E04:;J
	mWaitForHBlank
	pop  af
	ldi  [hl], a
	dec  b
	jp   nz, L000E03
	pop  hl
	ld   bc, $0020
	add  hl, bc
	pop  bc
	dec  c
	jr   nz, L000E01
	ret
L000E1B:;JC
	push bc
	ld   b, $08
L000E1E:;J
	mWaitForHBlank
	ld   a, h
	ld   [de], a
	inc  de
L000E28:;J
	mWaitForHBlank
	ld   a, l
	ld   [de], a
	inc  de
	dec  b
	jp   nz, L000E1E
	pop  bc
	dec  b
	jp   nz, L000E1B
	ret
	
; =============== CopyTilesAuto ===============
; Is this used?
L000E3C: ;X
CopyTilesAuto:
	ld   e, [hl]	; Read destination ptr
	inc  hl
	ld   d, [hl]
	inc  hl

; =============== CopyTilesAutoNum ===============
; Tile copy function.
;
; IN
; - HL: Ptr to the number of tiles to copy, followed by uncompressed GFX.
; - DE: Ptr to destination in VRAM
CopyTilesAutoNum:
	ld   b, [hl]	; Read number of tiles to copy
	inc  hl			; DestPtr++
	
; =============== CopyTiles ===============
; Tile copy function.
; Could be used for other purposes maybe.
;
; IN
; - HL: Ptr to uncompressed GFX
; - DE: Ptr to destination in VRAM
; -  B: Number of tiles to copy
CopyTiles:
	; Copy a single tile ($10 bytes) at a tune
REPT TILESIZE
	ldi  a, [hl]		; Read byte, SourcePtr++
	ld   [de], a		; Copy it over
	inc  de				; DestPtr++
ENDR
	dec  b				; Have we copied all tiles?
	jp   nz, CopyTiles	; If not, loop
	ret
	
L000E77: db $5E;X
L000E78: db $23;X
L000E79: db $56;X
L000E7A: db $23;X
L000E7B: db $46;X
L000E7C: db $23;X
L000E7D:;JC
	push bc
	ld   b, $10
L000E80:;J
	mWaitForHBlank
	ldi  a, [hl]
	ld   [de], a
	inc  de
	dec  b
	jp   nz, L000E80
	pop  bc
	dec  b
	jp   nz, L000E7D
	ret
L000E94: db $5E;X
L000E95: db $23;X
L000E96: db $56;X
L000E97: db $23;X
L000E98:;C
	ld   a, [hl]
	inc  hl
L000E9A:;C
	push af
	push de
	push hl
	push bc
	pop  hl
L000E9F:;J
	push af
	ld   a, $10
L000EA2:;J
	push af
	ld   a, [de]
	and  a, [hl]
	ld   [de], a
	inc  de
	inc  hl
	pop  af
	dec  a
	jp   nz, L000EA2
	pop  af
	dec  a
	jp   nz, L000E9F
	pop  hl
	pop  de
	pop  af
L000EB5:;J
	push af
	ld   a, $10
L000EB8:;J
	push af
	ld   a, [de]
	or   a, [hl]
	ld   [de], a
	inc  de
	inc  hl
	pop  af
	dec  a
	jp   nz, L000EB8
	pop  af
	dec  a
	jp   nz, L000EB5
	ret
L000EC9: db $5E;X
L000ECA: db $23;X
L000ECB: db $56;X
L000ECC: db $23;X
L000ECD: db $46;X
L000ECE: db $23;X
L000ECF:;JC
	push bc
	ld   b, $10
L000ED2:;J
	push bc
	ld   b, $00
	ld   c, [hl]
	inc  hl
	call L000EF1
	ld   a, b
	push af
L000EDC:;J
	mWaitForHBlank
	pop  af
	ld   [de], a
	inc  de
	pop  bc
	dec  b
	jp   nz, L000ED2
	pop  bc
	dec  b
	jp   nz, L000ECF
	ret
L000EF1:;C
	ldh  a, [hROMBank]
	push af
	ld   a, $1F
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	push hl
	ld   hl, $7DDC
	add  hl, bc
	ld   b, [hl]
	pop  hl
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret
; =============== DecompressGFX ===============
; Decompresses the GFX to the specified location in memory.
; The compression used appears to be based off the public domain code "lzss.c".
; IN
; - DE: Ptr to decompression buffer
; - HL: Ptr to compressed graphics
; OUT
; -  B: Number of uncompressed tiles written to the buffer.
DecompressGFX:
	push de		; Save DE for the very end

	;-------------------
	; HEADER PARSING
	;-------------------
	;
	; The header is two bytes long, and contains this info:
	; LLLLLLLL-SSHHHHHH
	; - L -> Number of command bytes (Low Byte)
	; - H -> Number of command bytes (High Byte)
	; - S -> Bits before split point.
	;
	; Because the compressed data can't be larger than a single bank ($4000), the two upper bits of byte1 get reused.
	
	; The number of command bytes will be strictly stored in BC, after filtering out the other bits.
	;
	; The number of bits before the "split point" is used for the variable bitmasks in the compressed data.
	; The value will be stored to wLZSS_SplitNum (used as counter for shifting right the values above the bits)
	; and a generated bitmask based on it in wLZSS_SplitMask (used to filter out bits above the split point).
	; 
		
		
.readHeader:
		; Fill the registers with the two bytes
		ld   c, [hl]	; Read byte0
		inc  hl			; HL++
		ldi  a, [hl]	; Read byte1
		ld   b, a		; 

.readDataLength:
		;
		; NUMBER OF BITMASKS / COMMAND BYTES
		;
		; Filter away the bits from byte1 that aren't part of length
		res  7, b		; Clear bit 7
		res  6, b		; Clear bit 6
		inc  bc			; BC++
		
.getSplitNum:
		;
		; SPLIT POINT (number of bits)
		;
		
		; Rotate the two bits left to shift them down from bit7-6 to bit 1-0.
		rlca			
		rlca				; << 2
		and  a, $03			; Clear out all other bits
		
		
		; For some reason, the source value is "inverted". Why is it like this?
		; wLZSS_SplitNum = $04 - A
		sub  a, $04					; will become negative
		cpl							; Invert sign
		inc  a						; ""
		ld   [wLZSS_SplitNum], a	; Store the result here
		;--

		;
		; SPLIT POINT (bitmask)
		;
		
		; Convert the above number to a bitmask with that amount of bits set.
		; ie: a bitcount of $02 will give 0b00000011
		;     a bitcount of $01 will give 0b00000001
		;     etc...
		
		; To do that, perform this operation:
		; Mask = (1 << wLZSS_SplitNum) - 1;
		; And save the result to wLZSS_SplitMask.
.getSplitMask:

		push bc
			ld   b, a				; B = wLZSS_SplitNum (times to shift)
			ld   a, $01				; A = Initial bit value
.smLoop:
			sla  a					; A = A << 1
			dec  b					; Are we done yet?
			jp   nz, .smLoop		; If not, loop
			dec  a					; Set the previous bits to 1
			ld   [wLZSS_SplitMask], a
		pop  bc


		;-------------------
		; MAIN DECOMPRESSION LOOP
		;-------------------
		;

.nextCmd:
		push bc					; Save remaining length for later

		
			; Read the command bitmask.
			;
			; Instead of using an explicit number to mark how many bytes to copy, this goes off using bitmasks.
			; Using bitshifts to the left, bits are processed one by one from the MSB to bit0.
			; 
			; This also means $08 commands can be processed with a single byte.
			
			
			ldi  a, [hl]				; Read command bitmask
			ld   [wLZSS_CurCmdMask], a	; Save it here

			
			ld   b, $08					; B = Bits left in the command byte
.loopCmdMask:
			ld   a, [wLZSS_CurCmdMask]	; Read bitmask
			add  a, a					; Shift every bit to the left, and read off MSB to the carry flag
			ld   [wLZSS_CurCmdMask], a
			jp   c, .startDecomp		; Is that carry bit set? If so, perform the dictionary copy
										; Otherwise, directly copy the next byte to the destination.
.rawCopy:	
			ldi  a, [hl]				; Read the byte, SrcPtr++
			ld   [de], a				; Copy it over
			inc  de						; DestPtr++
			
			dec  b						; All 8 commands in the byte processed?
			jp   nz, .loopCmdMask		; If not, loop
			
			jp   .chkEnd				; Otherwise, check if we copied all of the bytes

.startDecomp:
		
			push bc						; Save number of bits left for later

				;
				; The next byte read from the source data is a variable bitmask.
				;
				; This contains both:
				; - An offset relative to the decompressed buffer + 1 (higher bits)
				; - The amount of bytes to copy - 1 (lower bits)
				;
				
				; The bit where the "split" happens depends on a value in the header that was previously stored to wLZSS_SplitNum/wLZSS_SplitMask.
				;
				; To get the effective offset to BC, shift right the byte wLZSS_SplitNum times and invert the bits of the resulting value.
				; To get the amount of bytes to copy, read the bitmask filter from wLZSS_SplitMask and apply it to the byte.
				; 
				
				; Read the bitmask
				ldi  a, [hl]		
				push af				

					;--
					; BYTE OFFSET
					
					; B = Base amount of shifts
					push af
						ld   a, [wLZSS_SplitNum]
						ld   b, a			
					pop  af
					
					; Shift A right by that amount, then convert the number to negative.
					; Note that the original value has the bits inverted, so it is off by one (ie: an offset of $00 would point to -1).
					; C = -(A >> B)-1
.rsLoop:
					srl  a				; A = A >> 1
					dec  b				; Are we done?
					jp   nz, .rsLoop	; If not, loop
					
					cpl					; Convert to negative (-1)
					ld   c, a			; C = -A-1

					;--
					; BYTE COUNT
					ld   a, [wLZSS_SplitMask]	; B = Mask for byte count bits
					ld   b, a
					
				pop  af				; Restore bitmask

				
				and  b				; Filter away the upper bits
				inc  a				; Because a byte count of $00 is nonsensical, potentially save a bit by adding implicitly 1.
				
				; Set the high byte for the negative offset
				ld   b, HIGH(-$01)

				;--
				;
				; Dictionary copy loop.
				;
				; HL -> Destination and source buffer (originally in DE)
				; BC -> Fixed negative offset to seek the source data
				; A  -> Number of bytes to copy (due to filtering it will be small)
				;
				; The source data is read from (HL - BC), and the destination is HL.
				; HL increases over time, while BC stays the same.
			
				push hl		; Save SourcePtr
				
								
					; Move the destination buffer to HL
					push de
					pop  hl

.dictCopyLoop:
					push af						; Save BytesLeft
						push hl					; Save DestPtr
							add  hl, bc			; Seek back to to the match (DestPtr -= Offset)
							ld   a, [hl]		; Read the byte
						pop  hl					; Restore DestPtr
						ldi  [hl], a			; Copy the byte over, DestPtr++
					pop  af						; Restore BytesLeft
					dec  a						; Copied all bytes? 
					jp   nz, .dictCopyLoop		; If not, loop

					; Move the destination buffer back to DE
					push hl
					pop  de

				pop  hl				; Restore SourcePtr
				;--
			pop  bc					; Restore number of remaining bits in the command.
			
			
			dec  b					; All 8 commands in the byte processed?
			jp   nz, .loopCmdMask	; If not, loop

.chkEnd:
		;
		; Check if we've processed all command bytes
		;
		pop  bc				; Restore remaining commands count
		dec  bc				; CommandsLeft--

		ld   a, b
		or   a, c			; CommandsLeft == 0?
		jp   nz, .nextCmd	; If so, jump
							; Otherwise, we're done.
						

	;--
	;
	; DETERMINE UNCOMPRESSED TILE COUNT
	;
	;
	; The subroutine that copies graphics needs this number to know how many tiles need to be copied.
	; Note that this isn't always used, and at times a custom value is passed to that subroutine.
	
.calcUncSize:
	; Restore the ptr to the start of the destination buffer (which was "push de"'d at the very start) to *BC*.
	; This keeps the current position of the destination buffer to DE.
	; Then, to determine how many bytes were written, those values can be simply subtracted.
	pop  bc				
	
	push de
		; HL = DE (Current buffer pos)
		push de
		pop  hl

		; There's no "sub hl, bc" opcode, so invert BC instead.
		;#
		; BC = -BC
		ld   a, b		; Invert high byte
		cpl
		ld   b, a
		ld   a, c		; Invert high byte
		cpl
		ld   c, a
		inc  bc			; +1 cpl account
		;#
		
		add  hl, bc
		;--
		
.calcUncTiles:	
		; Divide the size by $10 (TILE_SIZE) to get the tile count.
		; B = HL / $10 (aka: B = HL >> 4)
		push hl
		
			; High byte: move the lower nybble to the upper nybble
			; (with a dubious lack of filtering with "and a, $F0")
			swap h			; H = SWAP(H)
			
			; Low byte: move the upper nybble to the lower nybble
			ld   a, l		; A = SWAP(L)
			swap a
			and  a, $0F		; Remove upper nybble.
			
			; Merge the two nybbles together and save the result to B.
			or   a, h		
			ld   b, a
		pop  hl
	pop  de

	ret
	
; =============== HomeCall_Sound_ReqPlayId ===============
; IN
; - A: Sound ID to play
HomeCall_Sound_ReqPlayId:
	push de
	push hl
		ld   d, a					; Set arg
		ldh  a, [hROMBank]
		push af
			ld   a, BANK(Sound_ReqPlayId)
			ld   [MBC1RomBank], a
			ldh  [hROMBank], a
			ld   a, d				; Not necessary, Sound_ReqPlayId takes D
			call Sound_ReqPlayId
		pop  af
		ld   [MBC1RomBank], a
		ldh  [hROMBank], a
	pop  hl
	pop  de
	ret
	
; =============== HomeCall_Sound_ReqPlayExId_Stub ===============
; IN
; - A: Action ID or DMG Sound ID
HomeCall_Sound_ReqPlayExId_Stub:
	jp   HomeCall_Sound_ReqPlayExId

; =============== SGB_SendSoundPacketAtFrameEnd ===============
; Sends the specified SGB sound packet previously written to RAM.
SGB_SendSoundPacketAtFrameEnd:
	; If there aren't any packets to send, return early
	ld   a, [wSGBSendPacketAtFrameEnd]
	or   a				; wSGBSendPacketAtFrameEnd == 0?
	ret  z				; If so, return
	
	; Don't do it too close to VBlank
	ldh  a, [rLY]
	cp   a, $76			; rLY >= $76?
	ret  nc				; If so, return
	
	; Send the packet containing the sound ID that was written at wSGBSoundPacket
	ld   hl, wSGBSoundPacket
	call SGB_SendPackets
	
	; Clear marker
	xor  a
	ld   [wSGBSendPacketAtFrameEnd], a
	ret
	
; =============== SGB_PrepareSoundPacket ===============
; Sets up the SGB packet to play a sound ID.
; IN
; - H: Sound Effect (A) ID
; - L: Sound Effect Attributes
SGB_PrepareSoundPacket:
	ld   a, [wMisc_C025]
	bit  MISCB_IS_SGB, a	; In SGB mode?
	jp   z, .end			; If not, return
	push bc
	push de
		push hl				; BC = HL
		pop  bc
		
		; There are 4 bytes in a sound packet, the rest are $00.
		; 1 08 SOUND    41.10.00.03 00.00.00.00 00.00.00.00 00.00.00.00
		
		; C = Attributes for Sound Effect A
		ld   a, $0F			; Filter away the upper nybble (which is for Sound Effect B)			
		and  c
		ld   c, a
		
		;
		; byte0 - command id + packet count
		;
		; (already written in HomeCall_Sound_Init)
		
		
		
		;
		; byte1 - Sound Effect A
		;
		ld   hl, wSGBSoundPacket+1		; Write out
		ld   [hl], b						
		inc  hl							; Seek to attrib.
		
		;
		; byte2 - Sound Effect B (always $00)
		;
		ld   [hl], $00						
		inc  hl
		
		;
		; byte3 - Attributes
		;
		; Preserve whatever is already there involving Sound Effect B.
		; Simply replace the lower nybble with the updated attributes.
		ld   a, [hl]
		and  a, $F0				; Preserve B
		or   c					; Merge A
		ld   [hl], a
		
		; Request later packet transfer
		ld   a, $01
		ld   [wSGBSendPacketAtFrameEnd], a
	pop  de
	pop  bc
.end:
	ret
	
L000FEF:;C
	ld   a, [wMisc_C025]
	bit  7, a
	jp   z, L001015
L000FF7: db $C5;X
L000FF8: db $D5;X
L000FF9: db $E5;X
L000FFA: db $C1;X
L000FFB: db $3E;X
L000FFC: db $0F;X
L000FFD: db $A1;X
L000FFE: db $CB;X
L000FFF: db $37;X
L001000: db $4F;X
L001001: db $21;X
L001002: db $2D;X
L001003: db $C0;X
L001004: db $36;X
L001005: db $00;X
L001006: db $23;X
L001007: db $70;X
L001008: db $23;X
L001009: db $7E;X
L00100A: db $E6;X
L00100B: db $0F;X
L00100C: db $B1;X
L00100D: db $77;X
L00100E: db $3E;X
L00100F: db $01;X
L001010: db $EA;X
L001011: db $2B;X
L001012: db $C0;X
L001013: db $D1;X
L001014: db $C1;X
L001015:;J
	ret
; =============== HomeCall_Sound_ReqPlayExId ===============
; IN
; - A: Action ID or DMG Sound ID
HomeCall_Sound_ReqPlayExId:
	push hl
	push de
	push bc
		ld   d, a					; Save
		ldh  a, [hROMBank]
		push af
			ld   a, BANK(Sound_ReqPlayExId)
			ld   [MBC1RomBank], a
			ldh  [hROMBank], a
			ld   a, d				; Restore
			call Sound_ReqPlayExId
		pop  af
		ld   [MBC1RomBank], a
		ldh  [hROMBank], a
	pop  bc
	pop  de
	pop  hl
	ret
	
; =============== HomeCall_Sound_Init ===============
HomeCall_Sound_Init:
	; Set command id for the fixed sound packet location (SGB_SendSoundPacketAtFrameEnd).
	; This will never be changed again.
	ld   a, (SGB_PACKET_SOUND * 8) | $01 	; Sound packet, 1 command
	ld   [wSGBSoundPacket], a
	
	ldh  a, [hROMBank]
	push af
	ld   a, BANK(Sound_Init) ; BANK $1F
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	call Sound_Init
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret
	
; =============== HomeCall_Sound_Do ===============
HomeCall_Sound_Do:
	push af
	push bc
	push de
	push hl
	ldh  a, [hROMBank]
	push af
	ld   a, BANK(Sound_Do) ; BANK $1F
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	call Sound_Do
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	pop  hl
	pop  de
	pop  bc
	pop  af
	ret
	
L001067:;C
	ld   a, [wMisc_C025]
	bit  7, a
	jp   nz, L0010E8
	ld   hl, $FF98
	ld   a, [$C145]
	and  a, a
	jr   nz, L0010A8
	ld   a, [hl]
	cpl
	ld   d, a
	ld   a, $20
	ldh  [rJOYP], a
	ldh  a, [rJOYP]
	ldh  a, [rJOYP]
	and  a, $0F
	ld   c, a
	ld   a, $30
	ldh  [rJOYP], a
	ld   a, $10
	ldh  [rJOYP], a
	ldh  a, [rJOYP]
	ldh  a, [rJOYP]
	ldh  a, [rJOYP]
	ldh  a, [rJOYP]
	ldh  a, [rJOYP]
	ldh  a, [rJOYP]
	and  a, $0F
	swap a
	or   a, c
	cpl
	ldi  [hl], a
	and  a, d
	ld   [hl], a
	ld   a, $30
	ldh  [rJOYP], a
	ret
L0010A8: db $4F;X
L0010A9: db $FA;X
L0010AA: db $4B;X
L0010AB: db $C1;X
L0010AC: db $A7;X
L0010AD: db $C8;X
L0010AE: db $79;X
L0010AF: db $11;X
L0010B0: db $98;X
L0010B1: db $FF;X
L0010B2: db $21;X
L0010B3: db $47;X
L0010B4: db $C1;X
L0010B5: db $FE;X
L0010B6: db $02;X
L0010B7: db $28;X
L0010B8: db $06;X
L0010B9: db $21;X
L0010BA: db $49;X
L0010BB: db $C1;X
L0010BC: db $11;X
L0010BD: db $AB;X
L0010BE: db $FF;X
L0010BF: db $1A;X
L0010C0: db $2F;X
L0010C1: db $4F;X
L0010C2: db $D5;X
L0010C3: db $E5;X
L0010C4: db $FA;X
L0010C5: db $41;X
L0010C6: db $C1;X
L0010C7: db $5F;X
L0010C8: db $3C;X
L0010C9: db $E6;X
L0010CA: db $7F;X
L0010CB: db $EA;X
L0010CC: db $41;X
L0010CD: db $C1;X
L0010CE: db $AF;X
L0010CF: db $57;X
L0010D0: db $21;X
L0010D1: db $BE;X
L0010D2: db $C0;X
L0010D3: db $19;X
L0010D4: db $7E;X
L0010D5: db $36;X
L0010D6: db $00;X
L0010D7: db $21;X
L0010D8: db $43;X
L0010D9: db $C1;X
L0010DA: db $35;X
L0010DB: db $E1;X
L0010DC: db $D1;X
L0010DD: db $12;X
L0010DE: db $13;X
L0010DF: db $A1;X
L0010E0: db $12;X
L0010E1: db $CD;X
L0010E2: db $78;X
L0010E3: db $10;X
L0010E4: db $CD;X
L0010E5: db $3C;X
L0010E6: db $16;X
L0010E7: db $C9;X
L0010E8: db $3E;X
L0010E9: db $30;X
L0010EA: db $E0;X
L0010EB: db $00;X
L0010EC: db $06;X
L0010ED: db $02;X
L0010EE: db $21;X
L0010EF: db $98;X
L0010F0: db $FF;X
L0010F1: db $F0;X
L0010F2: db $00;X
L0010F3: db $E6;X
L0010F4: db $01;X
L0010F5: db $20;X
L0010F6: db $03;X
L0010F7: db $21;X
L0010F8: db $AB;X
L0010F9: db $FF;X
L0010FA: db $7E;X
L0010FB: db $2F;X
L0010FC: db $57;X
L0010FD: db $3E;X
L0010FE: db $20;X
L0010FF: db $E0;X
L001100: db $00;X
L001101: db $F0;X
L001102: db $00;X
L001103: db $F0;X
L001104: db $00;X
L001105: db $E6;X
L001106: db $0F;X
L001107: db $4F;X
L001108: db $3E;X
L001109: db $30;X
L00110A: db $E0;X
L00110B: db $00;X
L00110C: db $3E;X
L00110D: db $10;X
L00110E: db $E0;X
L00110F: db $00;X
L001110: db $F0;X
L001111: db $00;X
L001112: db $F0;X
L001113: db $00;X
L001114: db $F0;X
L001115: db $00;X
L001116: db $F0;X
L001117: db $00;X
L001118: db $F0;X
L001119: db $00;X
L00111A: db $F0;X
L00111B: db $00;X
L00111C: db $E6;X
L00111D: db $0F;X
L00111E: db $CB;X
L00111F: db $37;X
L001120: db $B1;X
L001121: db $2F;X
L001122: db $22;X
L001123: db $A2;X
L001124: db $77;X
L001125: db $3E;X
L001126: db $30;X
L001127: db $E0;X
L001128: db $00;X
L001129: db $05;X
L00112A: db $C2;X
L00112B: db $EE;X
L00112C: db $10;X
L00112D: db $C9;X
L00112E:;C
	ld   hl, $FF98
	call L00113B
	ld   hl, $FFAB
	call L00113B
	ret
L00113B:;C
	ld   d, [hl]
	inc  hl
	inc  hl
	inc  hl
	ld   e, $08
L001141:;J
	ld   b, [hl]
	inc  hl
	ld   c, [hl]
	dec  hl
	sla  b
	sla  b
	sla  b
	sla  b
	rlc  d
	jp   nc, L001167
	set  0, b
	ld   a, b
	cp   $01
	jp   nz, L00115F
	ld   c, $11
	jp   L001167
L00115F:;J
	dec  c
	jp   nz, L001167
	ld   b, $01
	ld   c, $06
L001167:;J
	ld   [hl], b
	inc  hl
	ld   [hl], c
	inc  hl
	dec  e
	jp   nz, L001141
	ret
L001170:;C
	push bc
	ld   a, [$C009]
	ld   b, a
	sla  a
	sla  a
	add  b
	inc  a
	ld   b, a
	ld   a, [wTimer]
	add  b
	ld   [$C009], a
	pop  bc
	ret
L001185:;C
	push bc
	ld   a, [$C00A]
	ld   b, a
	sla  a
	sla  a
	add  b
	inc  a
	ld   b, a
	ld   a, [wTimer]
	add  b
	ld   b, a
	ldh  a, [rLY]
	add  b
	ld   [$C00A], a
	pop  bc
	ret
L00119E:;C
	ldh  a, [hROMBank]
	push af
	ld   a, $1D
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ld   hl, $4C9A
	call L0011F3
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret
L0011B5: db $F0;X
L0011B6: db $E0;X
L0011B7: db $F5;X
L0011B8: db $3E;X
L0011B9: db $1D;X
L0011BA: db $EA;X
L0011BB: db $00;X
L0011BC: db $20;X
L0011BD: db $E0;X
L0011BE: db $E0;X
L0011BF: db $21;X
L0011C0: db $9A;X
L0011C1: db $4C;X
L0011C2: db $7A;X
L0011C3: db $EA;X
L0011C4: db $4E;X
L0011C5: db $C1;X
L0011C6: db $7B;X
L0011C7: db $EA;X
L0011C8: db $4D;X
L0011C9: db $C1;X
L0011CA: db $5E;X
L0011CB: db $23;X
L0011CC: db $56;X
L0011CD: db $23;X
L0011CE: db $46;X
L0011CF: db $23;X
L0011D0: db $23;X
L0011D1: db $23;X
L0011D2: db $CD;X
L0011D3: db $01;X
L0011D4: db $12;X
L0011D5: db $F1;X
L0011D6: db $EA;X
L0011D7: db $00;X
L0011D8: db $20;X
L0011D9: db $E0;X
L0011DA: db $E0;X
L0011DB: db $C9;X
L0011DC: db $F0;X
L0011DD: db $E0;X
L0011DE: db $F5;X
L0011DF: db $3E;X
L0011E0: db $1D;X
L0011E1: db $EA;X
L0011E2: db $00;X
L0011E3: db $20;X
L0011E4: db $E0;X
L0011E5: db $E0;X
L0011E6: db $21;X
L0011E7: db $9D;X
L0011E8: db $4C;X
L0011E9: db $CD;X
L0011EA: db $F9;X
L0011EB: db $11;X
L0011EC: db $F1;X
L0011ED: db $EA;X
L0011EE: db $00;X
L0011EF: db $20;X
L0011F0: db $E0;X
L0011F1: db $E0;X
L0011F2: db $C9;X
L0011F3:;C
	ld   e, [hl]
	inc  hl
	ld   d, [hl]
	inc  hl
	ld   b, [hl]
	inc  hl
	ldi  a, [hl]
	ld   [$C14E], a
	ldi  a, [hl]
	ld   [$C14D], a
L001201:;R
	push bc
	ld   b, $08
L001204:;R
	xor  a
	ld   [$C14F], a
	ld   [$C150], a
	push bc
	ldi  a, [hl]
	ld   b, $08
	ld   c, $01
L001211:;R
	rrca
	jr   c, L00121E
	push af
	ld   a, [$C14E]
	call L00124C
	jp   L001225
L00121E:;R
	push af
	ld   a, [$C14D]
	call L00124C
L001225:;J
	pop  af
	rlc  c
	dec  b
	jr   nz, L001211
L00122B:;J
	ldh  a, [rSTAT]
	bit  1, a
	jp   nz, L00122B
	ld   a, [$C14F]
	ld   [de], a
	inc  de
L001237:;J
	ldh  a, [rSTAT]
	bit  1, a
	jp   nz, L001237
	ld   a, [$C150]
	ld   [de], a
	inc  de
	pop  bc
	dec  b
	jr   nz, L001204
	pop  bc
	dec  b
	jr   nz, L001201
	ret
L00124C:;C
	bit  0, a
	jr   z, L001259
	push af
	ld   a, [$C14F]
	or   a, c
	ld   [$C14F], a
	pop  af
L001259:;R
	bit  1, a
	jr   z, L001264
	ld   a, [$C150]
	or   a, c
	ld   [$C150], a
L001264:;R
	ret
L001265:;C
	ld   e, [hl]
	inc  hl
	ld   d, [hl]
	inc  hl
L001269:;C
	ld   b, [hl]
	inc  hl
L00126B:;R
	push bc
	ldi  a, [hl]
	push hl
	ld   hl, $7EDC
	ld   c, a
	call L001285
L001275:;J
	ldh  a, [rSTAT]
	bit  1, a
	jp   nz, L001275
	ld   a, b
	ld   [de], a
	inc  de
	pop  hl
	pop  bc
	dec  b
	jr   nz, L00126B
	ret
L001285:;C
	ldh  a, [hROMBank]
	push af
	ld   a, $1F
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ld   b, $00
	add  hl, bc
	ld   b, [hl]
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret
L00129A:;C
	push af
	swap a
	and  a, $0F
	call L0012A9
	pop  af
	and  a, $0F
	call L0012A9
	ret
L0012A9:;C
	push bc
	ld   hl, $7FDC
	ld   c, a
	call L001285
	ld   a, b
	pop  bc
	add  c
	ld   b, a
L0012B5:;J
	ldh  a, [rSTAT]
	bit  1, a
	jp   nz, L0012B5
	ld   a, b
	ld   [de], a
	inc  de
	ret
L0012C0:;C
	push af
	push bc
	push de
	ld   [$C151], a
	ldh  a, [hROMBank]
	push af
	ld   a, b
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ld   e, [hl]
	inc  hl
	ld   d, [hl]
	inc  hl
	jp   L0012E5
L0012D6:;JC
	push af
	push bc
	push de
	ld   [$C151], a
	ldh  a, [hROMBank]
	push af
	ld   a, b
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
L0012E5:;J
	ld   a, c
	ld   b, [hl]
	inc  hl
L0012E8:;J
	push af
	push bc
	ldi  a, [hl]
	cp   $FF
	jr   z, L00131B
	push hl
	ld   hl, $7EDC
	ld   c, a
	call L001285
L0012F7:;R
	ldh  a, [rSTAT]
	bit  1, a
	jr   nz, L0012F7
	ld   a, b
	ld   [de], a
	inc  de
	ld   a, [$C151]
	bit  0, a
	jr   z, L001319
	ld   a, b
	or   a
	jr   nz, L001313
	ld   hl, $0702
	call SGB_PrepareSoundPacket
	jr   L001319
L001313:;R
	ld   hl, $1207
	call SGB_PrepareSoundPacket
L001319:;R
	jr   L001337
L00131B:;R
	push hl
	ld   hl, $0020
	add  hl, de
	push hl
	pop  de
	ld   a, e
	and  a, $E0
	ld   e, a
	call L0013A8
	call Task_ExecRun_B01
	ld   b, $05
L00132E:;R
	call L0013A8
	call Task_ExecRun_B01
	dec  b
	jr   nz, L00132E
L001337:;R
	pop  hl
	pop  bc
	pop  af
	bit  7, a
	jr   nz, L001398
	push af
L00133F:;R
	push af
	ld   a, [$C151]
	bit  2, a
	jr   nz, L001365
	bit  1, a
	jr   z, L00138B
	ldh  a, [$FF99]
	bit  7, a
	jr   nz, L001380
	ldh  a, [$FF98]
	bit  4, a
	jr   nz, L001386
	ldh  a, [$FFAC]
	bit  7, a
	jr   nz, L001380
	ldh  a, [$FFAB]
	bit  4, a
	jr   nz, L001386
	jr   L00138B
L001365:;R
	ldh  a, [$FF99]
	bit  7, a
	jr   nz, L001373
	ldh  a, [$FFAC]
	bit  7, a
	jr   nz, L001373
	jr   L00138B
L001373:;R
	pop  af
	pop  af
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	pop  de
	pop  bc
	pop  af
	scf
	ret
L001380:;R
	pop  af
	pop  af
	set  7, a
	jr   L001398
L001386:;R
	pop  af
	ld   a, $01
	jr   L00138C
L00138B:;R
	pop  af
L00138C:;R
	push af
	call L0013A8
	call Task_ExecRun_B01
	pop  af
	dec  a
	jr   nz, L00133F
	pop  af
L001398:;R
	dec  b
	jp   nz, L0012E8
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	pop  de
	pop  bc
	pop  af
	scf
	ccf
	ret
L0013A8:;C
	push af
	push bc
	push de
	push hl
	ldh  a, [hROMBank]
	push af
	ld   a, [$C152]
	cp   $FF
	jp   z, L0013C7
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ld   hl, $C153
	ld   e, [hl]
	inc  hl
	ld   d, [hl]
	push de
	pop  hl
	call L0013D2
L0013C7:;J
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	pop  hl
	pop  de
	pop  bc
	pop  af
	ret
L0013D2:;C
	jp   hl
	
; =============== HomeCall_SGB_ApplyScreenPalSet ===============
HomeCall_SGB_ApplyScreenPalSet:
	ld   hl, wMisc_C025
	bit  MISCB_IS_SGB, [hl]		; Running under SGB?
	ret  z						; If not, return
	ldh  a, [hROMBank]
	push af
	ld   a, BANK(SGB_ApplyScreenPalSet)
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	call SGB_ApplyScreenPalSet
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret  
	
L0013ED:;C
	ldh  a, [hROMBank]
	push af
	ld   hl, $9C65
	ld   b, $0A
	ld   c, $01
	ld   d, $00
	call L000E00
	ld   hl, $9CA0
	ld   b, $14
	ld   c, $01
	ld   d, $00
	call L000E00
	ld   a, [$C167]
	or   a
	jp   nz, L0014A6
	ld   a, [$C163]
	bit  1, a
	jp   nz, L001445
	ld   a, [$C165]
	or   a
	jp   nz, L001424
	ld   hl, $DA2C
	jp   L001427
L001424: db $21;X
L001425: db $2C;X
L001426: db $D9;X
L001427:;J
	ld   a, [hl]
	srl  a
	ld   hl, $14E5
	ld   d, $00
	ld   e, a
	add  hl, de
	ld   a, [hl]
	ld   [$C166], a
	ld   a, [$C17F]
	cp   $11
	jp   nz, L001445
	ld   a, $06
	ld   [$C166], a
	jp   L001445
L001445:;J
	ld   a, [$C166]
	sla  a
	sla  a
	sla  a
	ld   b, $00
	ld   c, a
	ld   hl, $14AD
	add  hl, bc
	ldi  a, [hl]
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ld   c, [hl]
	inc  hl
	ld   b, [hl]
	inc  hl
	push hl
	push bc
	pop  hl
	ld   de, wLZSS_Buffer
	call DecompressGFX
	ld   hl, wLZSS_Buffer
	ld   de, $9000
	call CopyTiles
	pop  hl
	ld   e, [hl]
	inc  hl
	ld   d, [hl]
	inc  hl
	push hl
	push de
	pop  hl
	ld   de, wLZSS_Buffer
	call DecompressGFX
	ld   de, wLZSS_Buffer
	ld   hl, $9880
	ld   b, $20
	ld   c, $0C
	call CopyBGToRect
	ld   hl, $9840
	ld   b, $20
	ld   c, $02
	ld   d, $01
	call L000E00
	pop  hl
	ld   d, $00
	ld   e, [hl]
	inc  hl
	push hl
	call HomeCall_SGB_ApplyScreenPalSet
	pop  hl
	ld   a, [hl]
	call HomeCall_Sound_ReqPlayExId_Stub
L0014A6:;J
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret
L0014AD: db $04
L0014AE: db $18
L0014AF: db $63
L0014B0: db $32
L0014B1: db $67
L0014B2: db $06
L0014B3: db $84
L0014B4: db $00;X
L0014B5: db $04
L0014B6: db $22
L0014B7: db $68
L0014B8: db $42
L0014B9: db $6D
L0014BA: db $07
L0014BB: db $83
L0014BC: db $00;X
L0014BD: db $04
L0014BE: db $2A
L0014BF: db $6E
L0014C0: db $66
L0014C1: db $72
L0014C2: db $08
L0014C3: db $87
L0014C4: db $00;X
L0014C5: db $04
L0014C6: db $5C
L0014C7: db $73
L0014C8: db $A2
L0014C9: db $77
L0014CA: db $09
L0014CB: db $86
L0014CC: db $00;X
L0014CD: db $04
L0014CE: db $70
L0014CF: db $78
L0014D0: db $66
L0014D1: db $7D
L0014D2: db $0A
L0014D3: db $88
L0014D4: db $00;X
L0014D5: db $04
L0014D6: db $70
L0014D7: db $78
L0014D8: db $66
L0014D9: db $7D
L0014DA: db $0A
L0014DB: db $89
L0014DC: db $00;X
L0014DD: db $04
L0014DE: db $70
L0014DF: db $78
L0014E0: db $66
L0014E1: db $7D
L0014E2: db $0A
L0014E3: db $99
L0014E4: db $00;X
L0014E5: db $00
L0014E6: db $00
L0014E7: db $01
L0014E8: db $01
L0014E9: db $01
L0014EA: db $01
L0014EB: db $00
L0014EC: db $01
L0014ED: db $02
L0014EE: db $03
L0014EF: db $03
L0014F0: db $03
L0014F1: db $02
L0014F2: db $02
L0014F3: db $00
L0014F4: db $05
L0014F5: db $06
L0014F6: db $06
L0014F7: db $06
L0014F8: db $04
L0014F9:;C
	ld   hl, wMisc_C025
	bit  6, [hl]
	ret  z
L0014FF: db $F3;X
L001500: db $3E;X
L001501: db $08;X
L001502: db $EA;X
L001503: db $3C;X
L001504: db $C0;X
L001505: db $3E;X
L001506: db $17;X
L001507: db $EA;X
L001508: db $3D;X
L001509: db $C0;X
L00150A: db $AF;X
L00150B: db $E0;X
L00150C: db $01;X
L00150D: db $EA;X
L00150E: db $4B;X
L00150F: db $C1;X
L001510: db $F0;X
L001511: db $FF;X
L001512: db $F5;X
L001513: db $AF;X
L001514: db $E0;X
L001515: db $0F;X
L001516: db $3E;X
L001517: db $08;X
L001518: db $E0;X
L001519: db $FF;X
L00151A: db $FB;X
L00151B: db $AF;X
L00151C: db $EA;X
L00151D: db $46;X
L00151E: db $C1;X
L00151F: db $21;X
L001520: db $25;X
L001521: db $C0;X
L001522: db $CB;X
L001523: db $6E;X
L001524: db $C2;X
L001525: db $5C;X
L001526: db $15;X
L001527: db $01;X
L001528: db $10;X
L001529: db $00;X
L00152A: db $CD;X
L00152B: db $4A;X
L00152C: db $03;X
L00152D: db $AF;X
L00152E: db $EA;X
L00152F: db $46;X
L001530: db $C1;X
L001531: db $F3;X
L001532: db $3E;X
L001533: db $43;X
L001534: db $EA;X
L001535: db $BE;X
L001536: db $C0;X
L001537: db $3E;X
L001538: db $81;X
L001539: db $E0;X
L00153A: db $02;X
L00153B: db $FB;X
L00153C: db $01;X
L00153D: db $00;X
L00153E: db $06;X
L00153F: db $FA;X
L001540: db $46;X
L001541: db $C1;X
L001542: db $B7;X
L001543: db $20;X
L001544: db $09;X
L001545: db $0B;X
L001546: db $78;X
L001547: db $B1;X
L001548: db $C2;X
L001549: db $3F;X
L00154A: db $15;X
L00154B: db $C3;X
L00154C: db $31;X
L00154D: db $15;X
L00154E: db $AF;X
L00154F: db $EA;X
L001550: db $46;X
L001551: db $C1;X
L001552: db $FA;X
L001553: db $3E;X
L001554: db $C0;X
L001555: db $FE;X
L001556: db $4C;X
L001557: db $20;X
L001558: db $D8;X
L001559: db $C3;X
L00155A: db $82;X
L00155B: db $15;X
L00155C: db $3E;X
L00155D: db $4C;X
L00155E: db $EA;X
L00155F: db $BE;X
L001560: db $C0;X
L001561: db $3E;X
L001562: db $80;X
L001563: db $E0;X
L001564: db $02;X
L001565: db $01;X
L001566: db $00;X
L001567: db $06;X
L001568: db $FA;X
L001569: db $46;X
L00156A: db $C1;X
L00156B: db $B7;X
L00156C: db $20;X
L00156D: db $09;X
L00156E: db $0B;X
L00156F: db $78;X
L001570: db $B1;X
L001571: db $C2;X
L001572: db $68;X
L001573: db $15;X
L001574: db $C3;X
L001575: db $5C;X
L001576: db $15;X
L001577: db $AF;X
L001578: db $EA;X
L001579: db $46;X
L00157A: db $C1;X
L00157B: db $FA;X
L00157C: db $3E;X
L00157D: db $C0;X
L00157E: db $FE;X
L00157F: db $43;X
L001580: db $20;X
L001581: db $DA;X
L001582: db $F3;X
L001583: db $AF;X
L001584: db $06;X
L001585: db $80;X
L001586: db $21;X
L001587: db $3E;X
L001588: db $C0;X
L001589: db $22;X
L00158A: db $05;X
L00158B: db $C2;X
L00158C: db $89;X
L00158D: db $15;X
L00158E: db $06;X
L00158F: db $80;X
L001590: db $21;X
L001591: db $BE;X
L001592: db $C0;X
L001593: db $22;X
L001594: db $05;X
L001595: db $C2;X
L001596: db $93;X
L001597: db $15;X
L001598: db $EA;X
L001599: db $05;X
L00159A: db $C0;X
L00159B: db $E0;X
L00159C: db $01;X
L00159D: db $E0;X
L00159E: db $98;X
L00159F: db $E0;X
L0015A0: db $AB;X
L0015A1: db $E0;X
L0015A2: db $99;X
L0015A3: db $E0;X
L0015A4: db $AC;X
L0015A5: db $EA;X
L0015A6: db $47;X
L0015A7: db $C1;X
L0015A8: db $EA;X
L0015A9: db $49;X
L0015AA: db $C1;X
L0015AB: db $EA;X
L0015AC: db $48;X
L0015AD: db $C1;X
L0015AE: db $EA;X
L0015AF: db $4A;X
L0015B0: db $C1;X
L0015B1: db $EA;X
L0015B2: db $42;X
L0015B3: db $C1;X
L0015B4: db $EA;X
L0015B5: db $43;X
L0015B6: db $C1;X
L0015B7: db $EA;X
L0015B8: db $44;X
L0015B9: db $C1;X
L0015BA: db $EA;X
L0015BB: db $C5;X
L0015BC: db $C1;X
L0015BD: db $EA;X
L0015BE: db $C6;X
L0015BF: db $C1;X
L0015C0: db $3E;X
L0015C1: db $80;X
L0015C2: db $E0;X
L0015C3: db $02;X
L0015C4: db $3E;X
L0015C5: db $01;X
L0015C6: db $EA;X
L0015C7: db $4B;X
L0015C8: db $C1;X
L0015C9: db $21;X
L0015CA: db $25;X
L0015CB: db $C0;X
L0015CC: db $CB;X
L0015CD: db $6E;X
L0015CE: db $C2;X
L0015CF: db $F2;X
L0015D0: db $15;X
L0015D1: db $3E;X
L0015D2: db $22;X
L0015D3: db $EA;X
L0015D4: db $3C;X
L0015D5: db $C0;X
L0015D6: db $3E;X
L0015D7: db $17;X
L0015D8: db $EA;X
L0015D9: db $3D;X
L0015DA: db $C0;X
L0015DB: db $3E;X
L0015DC: db $01;X
L0015DD: db $EA;X
L0015DE: db $3E;X
L0015DF: db $C1;X
L0015E0: db $3E;X
L0015E1: db $00;X
L0015E2: db $EA;X
L0015E3: db $3F;X
L0015E4: db $C1;X
L0015E5: db $3E;X
L0015E6: db $02;X
L0015E7: db $EA;X
L0015E8: db $40;X
L0015E9: db $C1;X
L0015EA: db $3E;X
L0015EB: db $00;X
L0015EC: db $EA;X
L0015ED: db $41;X
L0015EE: db $C1;X
L0015EF: db $C3;X
L0015F0: db $13;X
L0015F1: db $16;X
L0015F2: db $3E;X
L0015F3: db $2B;X
L0015F4: db $EA;X
L0015F5: db $3C;X
L0015F6: db $C0;X
L0015F7: db $3E;X
L0015F8: db $17;X
L0015F9: db $EA;X
L0015FA: db $3D;X
L0015FB: db $C0;X
L0015FC: db $3E;X
L0015FD: db $01;X
L0015FE: db $EA;X
L0015FF: db $3E;X
L001600: db $C1;X
L001601: db $3E;X
L001602: db $00;X
L001603: db $EA;X
L001604: db $3F;X
L001605: db $C1;X
L001606: db $3E;X
L001607: db $02;X
L001608: db $EA;X
L001609: db $40;X
L00160A: db $C1;X
L00160B: db $3E;X
L00160C: db $00;X
L00160D: db $EA;X
L00160E: db $41;X
L00160F: db $C1;X
L001610: db $CD;X
L001611: db $67;X
L001612: db $17;X
L001613: db $AF;X
L001614: db $E0;X
L001615: db $0F;X
L001616: db $F1;X
L001617: db $E0;X
L001618: db $FF;X
L001619: db $C9;X
L00161A: db $AF;X
L00161B: db $EA;X
L00161C: db $46;X
L00161D: db $C1;X
L00161E: db $3E;X
L00161F: db $10;X
L001620: db $F5;X
L001621: db $F3;X
L001622: db $AF;X
L001623: db $EA;X
L001624: db $BE;X
L001625: db $C0;X
L001626: db $E0;X
L001627: db $01;X
L001628: db $3E;X
L001629: db $81;X
L00162A: db $E0;X
L00162B: db $02;X
L00162C: db $FB;X
L00162D: db $CD;X
L00162E: db $67;X
L00162F: db $17;X
L001630: db $FA;X
L001631: db $46;X
L001632: db $C1;X
L001633: db $B7;X
L001634: db $20;X
L001635: db $00;X
L001636: db $F1;X
L001637: db $3D;X
L001638: db $C2;X
L001639: db $20;X
L00163A: db $16;X
L00163B: db $C9;X
L00163C: db $FA;X
L00163D: db $4B;X
L00163E: db $C1;X
L00163F: db $A7;X
L001640: db $C8;X
L001641: db $FA;X
L001642: db $45;X
L001643: db $C1;X
L001644: db $A7;X
L001645: db $C8;X
L001646: db $21;X
L001647: db $98;X
L001648: db $FF;X
L001649: db $FE;X
L00164A: db $02;X
L00164B: db $20;X
L00164C: db $03;X
L00164D: db $21;X
L00164E: db $AB;X
L00164F: db $FF;X
L001650: db $7E;X
L001651: db $2F;X
L001652: db $4F;X
L001653: db $E5;X
L001654: db $FA;X
L001655: db $3F;X
L001656: db $C1;X
L001657: db $5F;X
L001658: db $3C;X
L001659: db $E6;X
L00165A: db $7F;X
L00165B: db $EA;X
L00165C: db $3F;X
L00165D: db $C1;X
L00165E: db $AF;X
L00165F: db $57;X
L001660: db $21;X
L001661: db $3E;X
L001662: db $C0;X
L001663: db $19;X
L001664: db $7E;X
L001665: db $21;X
L001666: db $42;X
L001667: db $C1;X
L001668: db $35;X
L001669: db $E1;X
L00166A: db $22;X
L00166B: db $A1;X
L00166C: db $77;X
L00166D: db $CD;X
L00166E: db $71;X
L00166F: db $16;X
L001670: db $C9;X
L001671: db $FA;X
L001672: db $45;X
L001673: db $C1;X
L001674: db $FE;X
L001675: db $02;X
L001676: db $20;X
L001677: db $1A;X
L001678: db $FA;X
L001679: db $40;X
L00167A: db $C1;X
L00167B: db $5F;X
L00167C: db $16;X
L00167D: db $00;X
L00167E: db $21;X
L00167F: db $BE;X
L001680: db $C0;X
L001681: db $19;X
L001682: db $FA;X
L001683: db $47;X
L001684: db $C1;X
L001685: db $CD;X
L001686: db $A8;X
L001687: db $16;X
L001688: db $77;X
L001689: db $AF;X
L00168A: db $EA;X
L00168B: db $47;X
L00168C: db $C1;X
L00168D: db $3E;X
L00168E: db $81;X
L00168F: db $E0;X
L001690: db $02;X
L001691: db $C9;X
L001692: db $FA;X
L001693: db $40;X
L001694: db $C1;X
L001695: db $5F;X
L001696: db $16;X
L001697: db $00;X
L001698: db $21;X
L001699: db $BE;X
L00169A: db $C0;X
L00169B: db $19;X
L00169C: db $FA;X
L00169D: db $49;X
L00169E: db $C1;X
L00169F: db $CD;X
L0016A0: db $A8;X
L0016A1: db $16;X
L0016A2: db $77;X
L0016A3: db $AF;X
L0016A4: db $EA;X
L0016A5: db $49;X
L0016A6: db $C1;X
L0016A7: db $C9;X
L0016A8: db $47;X
L0016A9: db $E6;X
L0016AA: db $03;X
L0016AB: db $FE;X
L0016AC: db $03;X
L0016AD: db $C2;X
L0016AE: db $B2;X
L0016AF: db $16;X
L0016B0: db $CB;X
L0016B1: db $80;X
L0016B2: db $78;X
L0016B3: db $E6;X
L0016B4: db $0C;X
L0016B5: db $FE;X
L0016B6: db $0C;X
L0016B7: db $C2;X
L0016B8: db $BC;X
L0016B9: db $16;X
L0016BA: db $CB;X
L0016BB: db $90;X
L0016BC: db $78;X
L0016BD: db $C9;X

; =============== L0016BE ===============
; Initialize serial?
L0016BE:
	xor  a
	ldh  [rSB], a
	ld   [$C14B], a
	ld   [$C03E], a
	ld   [$C145], a
	ld   [$C146], a
	ld   [$C0BE], a
	ld   a, $EF
	ld   [$C03C], a
	ld   a, $16
	ld   [$C03D], a
	ret
	
L0016DB:;J
	push af
	push bc
	push de
	push hl
	call L0016E7
	pop  hl
	pop  de
	pop  bc
	pop  af
	reti
L0016E7:;C
	ld   hl, $C03C
	ldi  a, [hl]
	ld   e, a
	ld   h, [hl]
	ld   l, e
	jp   hl
L0016EF:;I
	ldh  a, [rSB]
	ld   [$C03E], a
	cp   $02
	jr   z, L001702
	ld   a, $80
	ldh  [rSC], a
	ld   a, $01
	ld   [$C146], a
	ret
L001702: db $3E;X
L001703: db $01;X
L001704: db $EA;X
L001705: db $46;X
L001706: db $C1;X
L001707: db $C9;X
L001708: db $F0;X
L001709: db $01;X
L00170A: db $EA;X
L00170B: db $3E;X
L00170C: db $C0;X
L00170D: db $FA;X
L00170E: db $BE;X
L00170F: db $C0;X
L001710: db $E0;X
L001711: db $01;X
L001712: db $3E;X
L001713: db $01;X
L001714: db $EA;X
L001715: db $46;X
L001716: db $C1;X
L001717: db $FA;X
L001718: db $25;X
L001719: db $C0;X
L00171A: db $CB;X
L00171B: db $6F;X
L00171C: db $C8;X
L00171D: db $3E;X
L00171E: db $80;X
L00171F: db $E0;X
L001720: db $02;X
L001721: db $C9;X
L001722: db $CD;X
L001723: db $38;X
L001724: db $17;X
L001725: db $3E;X
L001726: db $01;X
L001727: db $EA;X
L001728: db $46;X
L001729: db $C1;X
L00172A: db $C9;X
L00172B: db $CD;X
L00172C: db $38;X
L00172D: db $17;X
L00172E: db $3E;X
L00172F: db $80;X
L001730: db $E0;X
L001731: db $02;X
L001732: db $3E;X
L001733: db $01;X
L001734: db $EA;X
L001735: db $46;X
L001736: db $C1;X
L001737: db $C9;X
L001738: db $FA;X
L001739: db $3E;X
L00173A: db $C1;X
L00173B: db $5F;X
L00173C: db $3C;X
L00173D: db $E6;X
L00173E: db $7F;X
L00173F: db $EA;X
L001740: db $3E;X
L001741: db $C1;X
L001742: db $16;X
L001743: db $00;X
L001744: db $21;X
L001745: db $3E;X
L001746: db $C0;X
L001747: db $19;X
L001748: db $F0;X
L001749: db $01;X
L00174A: db $77;X
L00174B: db $21;X
L00174C: db $42;X
L00174D: db $C1;X
L00174E: db $34;X
L00174F: db $FA;X
L001750: db $40;X
L001751: db $C1;X
L001752: db $5F;X
L001753: db $3C;X
L001754: db $E6;X
L001755: db $7F;X
L001756: db $EA;X
L001757: db $40;X
L001758: db $C1;X
L001759: db $16;X
L00175A: db $00;X
L00175B: db $21;X
L00175C: db $BE;X
L00175D: db $C0;X
L00175E: db $19;X
L00175F: db $7E;X
L001760: db $E0;X
L001761: db $01;X
L001762: db $21;X
L001763: db $43;X
L001764: db $C1;X
L001765: db $34;X
L001766: db $C9;X
L001767: db $01;X
L001768: db $00;X
L001769: db $06;X
L00176A: db $00;X
L00176B: db $00;X
L00176C: db $0B;X
L00176D: db $78;X
L00176E: db $B1;X
L00176F: db $C2;X
L001770: db $6A;X
L001771: db $17;X
L001772: db $C9;X
L001773: db $C3;X
L001774: db $80;X
L001775: db $43;X
L001776:;C
	ld   a, $FF
	ld   [$C167], a
	xor  a
	ld   [$D931], a
	ld   [$DA31], a
	ld   [$D92D], a
	ld   [$DA2D], a
	ld   [$D936], a
	ld   [$DA36], a
	ld   [$D937], a
	ld   [$DA37], a
	ld   a, $48
	ld   [$D94E], a
	ld   [$DA4E], a
	ret
L00179D:;J
	ld   sp, $DD00
	di
	ld   a, $1D
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	rst  $10
	ld   hl, $C027
	set  7, [hl]
	inc  hl
	set  1, [hl]
	ld   a, $1E
	ld   b, $7F
	call L00046C
	ld   a, $FF
	ld   [$C008], a
	ld   hl, $C164
	inc  [hl]
	ld   a, $FF
	ldh  [rBGP], a
	ldh  [rOBP0], a
	ldh  [rOBP1], a
	ldh  [$FFF0], a
	ldh  [$FFF1], a
	ldh  [$FFF2], a
	xor  a
	ldh  [rSTAT], a
	ld   a, [$C167]
	cp   $FF
	jp   nz, L0017E0
	call ClearBGMap
	call ClearWINDOWMap
L0017E0:;J
	ld   a, $30
	ldh  [hScrollX], a
	ld   [wFieldScrollX], a
	xor  a
	ldh  [hScrollY], a
	ld   a, $40
	ld   [wFieldScrollY], a
	ld   hl, $D8C0
	ld   b, $40
	xor  a
L0017F5:;J
	ldi  [hl], a
	dec  b
	jp   nz, L0017F5
	call ClearOBJInfo
	call L002264
	call L001CEB
	call L0018C4
	call L002233
	call L002152
	call L001DC2
	call L0013ED
	ldh  a, [hROMBank]
	push af
	ld   a, $01
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ld   hl, $4AF8
	ld   de, wLZSS_Buffer
	call DecompressGFX
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	xor  a
	ldh  [rWY], a
	ld   a, $07
	ldh  [rWX], a
	call L0014F9
	ld   a, $E7
	rst  $18
	ldh  a, [rSTAT]
	or   a, $40
	ldh  [rSTAT], a
	ld   a, $16
	ldh  [rLYC], a
	ldh  a, [rIE]
	or   a, $03
	ldh  [rIE], a
	ld   a, $02
	ld   bc, $2458
	call Task_CreateAt
	ld   a, $03
	ld   bc, $2464
	call Task_CreateAt
	call L00231E
	ei
	call Task_ExecRunFar_B01
	call Task_ExecRunFar_B01
	ld   a, [$C17F]
	cp   $0F
	jp   z, L00187C
	cp   $10
	jp   z, L001881
	cp   $11
	jp   z, L001886
	cp   $12
	jp   z, L00188B
	jp   L001893
L00187C:;J
	ld   hl, $0000
	jr   L001890
L001881:;J
	ld   hl, $0400
	jr   L001890
L001886:;J
	ld   hl, $0900
	jr   L001890
L00188B:;J
	ld   hl, $0B00
	jr   L001890
L001890:;R
	call L000FEF
L001893:;J
	ld   b, $0A
L001895:;J
	call Task_ExecRunFar_B01
	dec  b
	jp   nz, L001895
	ld   a, $8C
	ldh  [rOBP0], a
	ld   a, $4C
	ldh  [rOBP1], a
	ld   a, $1B
	ld   [$C17C], a
	ldh  [rBGP], a
	ldh  [$FFF0], a
	ldh  [$FFF1], a
	ldh  [$FFF2], a
	call L0023A3
	call L0022C1
	call L001BC5
	ld   a, $01
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	jp   $6389
L0018C4:;C
	ld   bc, $D900
	ld   de, wOBJInfo_Pl1+iOBJInfo_Status
	call L001A0B
	ld   bc, $DA00
	ld   de, wOBJInfo_Pl2+iOBJInfo_Status
	call L001A0B
	xor  a
	ld   [$C172], a
	ld   [$C173], a
	ld   [$C17A], a
	ld   [$C17B], a
	ld   [$C159], a
	ld   [$C16B], a
	ld   [$C16E], a
	xor  a
	ld   [$D92B], a
	ld   a, $01
	ld   [$DA2B], a
	ld   a, [$D920]
	and  a, $80
	ld   [$D920], a
	ld   a, [$DA20]
	and  a, $80
	ld   [$DA20], a
	xor  a
	ld   [$D921], a
	ld   [$D922], a
	ld   [$D923], a
	ld   [$DA21], a
	ld   [$DA22], a
	ld   [$DA23], a
	ld   [$D933], a
	ld   [$DA33], a
	ld   [$D935], a
	ld   [$DA35], a
	ld   [$D963], a
	ld   [$DA63], a
	ld   [$D964], a
	ld   [$DA64], a
	ld   [$D959], a
	ld   [$DA59], a
	ld   [$D958], a
	ld   [$DA58], a
	ld   [$D937], a
	ld   [$DA37], a
	ld   [$D960], a
	ld   [$DA60], a
	ld   a, $FF
	ld   [$D961], a
	ld   [$DA61], a
	ld   a, $67
	ld   [$D95A], a
	ld   [$DA5A], a
	ld   [$D95B], a
	ld   [$DA5B], a
	ld   [$D95C], a
	ld   [$DA5C], a
	ld   [$D95D], a
	ld   [$DA5D], a
	ld   a, [$D92C]
	ld   [$DA71], a
	ld   a, [$DA2C]
	ld   [$D971], a
	xor  a
	ld   [$C160], a
	call L001F85
	jp   nc, L0019AD
	ld   a, [$C162]
	bit  0, a
	jp   nz, L00198D
	ld   a, $48
	ld   [$D94E], a
L00198D:;J
	ld   a, [$C162]
	bit  1, a
	jp   nz, L00199A
	ld   a, $48
	ld   [$DA4E], a
L00199A:;J
	ld   a, [$D92D]
	cp   $03
	jp   z, L0019B5
	ld   a, [$DA2D]
	cp   $03
	jp   z, L0019B5
	jp   L0019CD
L0019AD:;J
	ld   a, [$C167]
	cp   $03
	jp   nz, L0019C5
L0019B5:;J
	ld   a, $01
	ld   [$C160], a
	ld   a, $17
	ld   [$D94E], a
	ld   [$DA4E], a
	jp   L0019CD
L0019C5:;J
	ld   a, $48
	ld   [$D94E], a
	ld   [$DA4E], a
L0019CD:;J
	xor  a
	ld   [$D94F], a
	ld   [$DA4F], a
	ld   [$D950], a
	ld   [$DA50], a
	ld   [$D951], a
	ld   [$DA51], a
	ld   [$D952], a
	ld   [$DA52], a
	ld   [$D953], a
	ld   [$DA53], a
	ld   [$D954], a
	ld   [$DA54], a
	ld   [$D955], a
	ld   [$DA55], a
	ld   hl, wOBJInfo_Pl1+iOBJInfo_Status
	ld   de, $241A
	call L000D76
	ld   hl, wOBJInfo_Pl2+iOBJInfo_Status
	ld   de, $2439
	call L000D76
	ret
L001A0B:;C
	call L001F85
	jp   nc, L001A2D
	ld   hl, $002D
	add  hl, bc
	ld   a, [hl]
	cp   $03
	jp   nz, L001A1D
	ld   a, $02
L001A1D:;J
	ld   hl, $002E
	add  hl, bc
	add  a, L
	jp   nc, L001A26
L001A25: db $24;X
L001A26:;J
	ld   l, a
	ld   a, [hl]
	ld   hl, $002C
	add  hl, bc
	ld   [hl], a
L001A2D:;J
	ld   hl, $002C
	add  hl, bc
	ld   l, [hl]
	ld   h, $00
	sla  l
	rl   h
	sla  l
	rl   h
	sla  l
	rl   h
	ld   de, $1A85
	add  hl, de
	push hl
	pop  de
	ld   hl, $0025
	call L001A77
	ld   hl, $0027
	call L001A77
	ld   hl, $0029
	call L001A77
	ld   hl, $002A
	call L001A7F
	ld   hl, $0066
	call L001A77
	ld   hl, $0068
	call L001A77
	ld   hl, $006A
	call L001A77
	ld   hl, $006C
	call L001A77
	ret
L001A77:;C
	add  hl, bc
	ld   a, [de]
	inc  de
	ldd  [hl], a
	ld   a, [de]
	inc  de
	ld   [hl], a
	ret
L001A7F:;C
	add  hl, bc
	ld   a, [de]
	inc  de
	ld   [hl], a
	inc  de
	ret
L001A85: db $00
L001A86: db $40
L001A87: db $A7
L001A88: db $70
L001A89: db $52
L001A8A: db $40
L001A8B: db $06
L001A8C: db $00;X
L001A8D: db $80
L001A8E: db $01
L001A8F: db $00
L001A90: db $FF
L001A91: db $00
L001A92: db $F9
L001A93: db $60
L001A94: db $00
L001A95: db $68
L001A96: db $42
L001A97: db $07
L001A98: db $71
L001A99: db $A0
L001A9A: db $78
L001A9B: db $05
L001A9C: db $00;X
L001A9D: db $80
L001A9E: db $01
L001A9F: db $00
L001AA0: db $FF
L001AA1: db $00
L001AA2: db $F9
L001AA3: db $60
L001AA4: db $00
L001AA5: db $D0
L001AA6: db $44
L001AA7: db $87
L001AA8: db $75
L001AA9: db $A4
L001AAA: db $4C
L001AAB: db $06
L001AAC: db $00;X
L001AAD: db $80
L001AAE: db $01
L001AAF: db $00
L001AB0: db $FF
L001AB1: db $00
L001AB2: db $F9
L001AB3: db $60
L001AB4: db $00
L001AB5: db $38
L001AB6: db $47
L001AB7: db $67
L001AB8: db $71
L001AB9: db $77
L001ABA: db $6A
L001ABB: db $06
L001ABC: db $00;X
L001ABD: db $80
L001ABE: db $01
L001ABF: db $00
L001AC0: db $FF
L001AC1: db $00
L001AC2: db $F9
L001AC3: db $60
L001AC4: db $00
L001AC5: db $A0
L001AC6: db $49
L001AC7: db $27
L001AC8: db $75
L001AC9: db $D7
L001ACA: db $57
L001ACB: db $02
L001ACC: db $00;X
L001ACD: db $80
L001ACE: db $01
L001ACF: db $00
L001AD0: db $FF
L001AD1: db $00
L001AD2: db $F9
L001AD3: db $60
L001AD4: db $00
L001AD5: db $08
L001AD6: db $4C
L001AD7: db $C7
L001AD8: db $71
L001AD9: db $5C
L001ADA: db $5E
L001ADB: db $02
L001ADC: db $00;X
L001ADD: db $80
L001ADE: db $01
L001ADF: db $00
L001AE0: db $FF
L001AE1: db $00
L001AE2: db $F9
L001AE3: db $60
L001AE4: db $00
L001AE5: db $70
L001AE6: db $4E
L001AE7: db $E7
L001AE8: db $75
L001AE9: db $3A
L001AEA: db $5B
L001AEB: db $06
L001AEC: db $00;X
L001AED: db $80
L001AEE: db $01
L001AEF: db $00
L001AF0: db $FF
L001AF1: db $00
L001AF2: db $F9
L001AF3: db $60
L001AF4: db $00
L001AF5: db $D8
L001AF6: db $50
L001AF7: db $47
L001AF8: db $76
L001AF9: db $DF
L001AFA: db $52
L001AFB: db $06
L001AFC: db $00;X
L001AFD: db $80
L001AFE: db $01
L001AFF: db $00
L001B00: db $FF
L001B01: db $00
L001B02: db $F9
L001B03: db $60
L001B04: db $00
L001B05: db $40
L001B06: db $53
L001B07: db $27
L001B08: db $72
L001B09: db $46
L001B0A: db $68
L001B0B: db $02
L001B0C: db $00;X
L001B0D: db $80
L001B0E: db $01
L001B0F: db $00
L001B10: db $FF
L001B11: db $00
L001B12: db $F9
L001B13: db $60
L001B14: db $00
L001B15: db $10
L001B16: db $58
L001B17: db $87
L001B18: db $72
L001B19: db $C0
L001B1A: db $77
L001B1B: db $06
L001B1C: db $00;X
L001B1D: db $80
L001B1E: db $01
L001B1F: db $00
L001B20: db $FF
L001B21: db $00
L001B22: db $F9
L001B23: db $60
L001B24: db $00
L001B25: db $78
L001B26: db $5A
L001B27: db $E7
L001B28: db $72
L001B29: db $E6
L001B2A: db $74
L001B2B: db $09
L001B2C: db $00;X
L001B2D: db $80
L001B2E: db $01
L001B2F: db $00
L001B30: db $FF
L001B31: db $00
L001B32: db $F9
L001B33: db $60
L001B34: db $00
L001B35: db $E0
L001B36: db $5C
L001B37: db $47
L001B38: db $73
L001B39: db $EE
L001B3A: db $71
L001B3B: db $06
L001B3C: db $00;X
L001B3D: db $80
L001B3E: db $01
L001B3F: db $00
L001B40: db $FF
L001B41: db $00
L001B42: db $F9
L001B43: db $60
L001B44: db $00
L001B45: db $48
L001B46: db $5F
L001B47: db $A7
L001B48: db $76
L001B49: db $F2
L001B4A: db $5F
L001B4B: db $05
L001B4C: db $00;X
L001B4D: db $80
L001B4E: db $01
L001B4F: db $00
L001B50: db $FF
L001B51: db $00
L001B52: db $F9
L001B53: db $60
L001B54: db $00
L001B55: db $B0
L001B56: db $61
L001B57: db $A7
L001B58: db $73
L001B59: db $11
L001B5A: db $6C
L001B5B: db $05
L001B5C: db $00;X
L001B5D: db $80
L001B5E: db $01
L001B5F: db $00
L001B60: db $FF
L001B61: db $00
L001B62: db $F9
L001B63: db $60
L001B64: db $00
L001B65: db $18
L001B66: db $64
L001B67: db $07
L001B68: db $74
L001B69: db $62
L001B6A: db $73
L001B6B: db $05
L001B6C: db $00;X
L001B6D: db $80
L001B6E: db $01
L001B6F: db $00
L001B70: db $FF
L001B71: db $00
L001B72: db $F9
L001B73: db $60
L001B74: db $00
L001B75: db $E8
L001B76: db $68
L001B77: db $67
L001B78: db $74
L001B79: db $73
L001B7A: db $73
L001B7B: db $0A
L001B7C: db $00;X
L001B7D: db $80
L001B7E: db $01
L001B7F: db $00
L001B80: db $FF
L001B81: db $00
L001B82: db $F9
L001B83: db $60
L001B84: db $00
L001B85: db $50
L001B86: db $6B
L001B87: db $C7
L001B88: db $74
L001B89: db $63
L001B8A: db $71
L001B8B: db $02
L001B8C: db $00;X
L001B8D: db $80
L001B8E: db $01
L001B8F: db $00
L001B90: db $FF
L001B91: db $00
L001B92: db $F9
L001B93: db $60
L001B94: db $00
L001B95: db $B8
L001B96: db $6D
L001B97: db $A7
L001B98: db $76
L001B99: db $F2
L001B9A: db $5F
L001B9B: db $05
L001B9C: db $00;X
L001B9D: db $80
L001B9E: db $01
L001B9F: db $00
L001BA0: db $FF
L001BA1: db $00
L001BA2: db $F9
L001BA3: db $60
L001BA4: db $00
L001BA5: db $A8
L001BA6: db $55
L001BA7: db $27
L001BA8: db $72
L001BA9: db $46
L001BAA: db $68
L001BAB: db $02
L001BAC: db $00;X
L001BAD: db $80
L001BAE: db $01
L001BAF: db $00
L001BB0: db $FF
L001BB1: db $00
L001BB2: db $F9
L001BB3: db $60
L001BB4: db $00
L001BB5: db $80
L001BB6: db $66
L001BB7: db $07
L001BB8: db $74
L001BB9: db $68
L001BBA: db $73
L001BBB: db $05
L001BBC: db $00;X
L001BBD: db $80
L001BBE: db $01
L001BBF: db $00
L001BC0: db $FF
L001BC1: db $00
L001BC2: db $F9
L001BC3: db $60
L001BC4: db $00
L001BC5:;C
	call Task_ExecRunFar_B01
	ldh  a, [hROMBank]
	push af
	ld   a, $01
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ld   a, [$D92C]
	ld   de, $8800
	call L001C45
	call Task_ExecRunFar_B01
	ld   a, [$DA2C]
	ld   de, $8A60
	call L001C45
	call Task_ExecRunFar_B01
	ld   hl, $57E4
	ld   de, $8CC0
	ld   a, $04
	call L001C7E
	call Task_ExecRunFar_B01
	ld   a, $01
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ld   hl, wOBJInfo2+iOBJInfo_Status
	ld   de, $636A
	call L000D76
	call Task_ExecRunFar_B01
	ld   hl, wOBJInfo3+iOBJInfo_Status
	ld   de, $636A
	call L000D76
	ld   hl, $D74D
	ld   [hl], $A6
	call Task_ExecRunFar_B01
	ld   hl, wOBJInfo4+iOBJInfo_Status
	ld   de, $636A
	call L000D76
	ld   hl, $D78D
	ld   [hl], $CC
	call Task_ExecRunFar_B01
	ld   hl, wOBJInfo5+iOBJInfo_Status
	ld   de, $636A
	call L000D76
	ld   hl, $D7CD
	ld   [hl], $CC
	call Task_ExecRunFar_B01
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret
L001C45:;C
	ld   hl, $1CC3
	add  a, L
	jp   nc, L001C4D
L001C4C: db $24;X
L001C4D:;J
	ld   l, a
	ld   c, [hl]
	inc  hl
	ld   b, [hl]
	push bc
	pop  hl
	ld   a, h
	or   a, L
	jp   z, L001C7D
	push hl
	ld   hl, $0000
	ld   b, $02
	call L000E1B
	call Task_ExecRunFar_B01
	pop  hl
	ldi  a, [hl]
L001C66:;J
	push af
	ld   c, [hl]
	inc  hl
	ld   b, [hl]
	inc  hl
	ldi  a, [hl]
	push hl
	ld   hl, wLZSS_Buffer
	add  hl, bc
	call L001C7E
	pop  hl
	pop  af
	dec  a
	jp   nz, L001C66
	call Task_ExecRunFar_B01
L001C7D:;J
	ret
L001C7E:;C
	srl  a
L001C80:;J
	push af
	ld   b, $08
L001C83:;J
	di
L001C84:;J
	ldh  a, [rSTAT]
	bit  1, a
	jp   nz, L001C84
	ldi  a, [hl]
	ld   [de], a
	ei
	inc  de
	di
L001C90:;J
	ldh  a, [rSTAT]
	bit  1, a
	jp   nz, L001C90
	ldi  a, [hl]
	ld   [de], a
	ei
	inc  de
	di
L001C9C:;J
	ldh  a, [rSTAT]
	bit  1, a
	jp   nz, L001C9C
	ldi  a, [hl]
	ld   [de], a
	ei
	inc  de
	di
L001CA8:;J
	ldh  a, [rSTAT]
	bit  1, a
	jp   nz, L001CA8
	ldi  a, [hl]
	ld   [de], a
	ei
	inc  de
	dec  b
	jp   nz, L001C83
	call Task_ExecRunFar_B01
	pop  af
	dec  a
	jp   nz, L001C80
	call Task_ExecRunFar_B01
	ret
L001CC3: db $00
L001CC4: db $00
L001CC5: db $00
L001CC6: db $00
L001CC7: db $24
L001CC8: db $58
L001CC9: db $00
L001CCA: db $00
L001CCB: db $28
L001CCC: db $58
L001CCD: db $28
L001CCE: db $58
L001CCF: db $36
L001CD0: db $58
L001CD1: db $3A
L001CD2: db $58
L001CD3: db $3E
L001CD4: db $58
L001CD5: db $42
L001CD6: db $58
L001CD7: db $46
L001CD8: db $58
L001CD9: db $4A
L001CDA: db $58
L001CDB: db $51
L001CDC: db $58
L001CDD: db $55
L001CDE: db $58
L001CDF: db $59
L001CE0: db $58
L001CE1: db $5D
L001CE2: db $58
L001CE3: db $2F
L001CE4: db $58
L001CE5: db $61
L001CE6: db $58
L001CE7: db $65
L001CE8: db $58
L001CE9: db $59
L001CEA: db $58
L001CEB:;C
	ld   a, [wMatchStartTime]
	ld   [$C169], a
	ld   a, [$C167]
	or   a
	jp   nz, L001D0C
	ld   hl, $4A52
	ld   de, wLZSS_Buffer
	call DecompressGFX
	ld   hl, wLZSS_Buffer
	ld   de, $8D00
	ld   b, $2C
	call CopyTiles
L001D0C:;J
	ld   a, [$C169]
	cp   $FF
	jp   nz, L001D24
	ld   a, $99
	ld   [$C169], a
	call L002406
	ld   a, $FF
	ld   [$C169], a
	jp   L001D2C
L001D24:;J
	ld   a, $3C
	ld   [$C16A], a
	call L002406
L001D2C:;J
	ld   de, $4BDE
	ld   hl, $9C09
	ld   b, $02
	ld   c, $01
	call CopyBGToRect
	ld   de, $4BE0
	ld   hl, $9C80
	ld   b, $01
	ld   c, $01
	call CopyBGToRect
	ld   de, $4BE1
	ld   hl, $9C88
	ld   b, $01
	ld   c, $01
	call CopyBGToRect
	ld   de, $4BE0
	ld   hl, $9C8B
	ld   b, $01
	ld   c, $01
	call CopyBGToRect
	ld   de, $4BE1
	ld   hl, $9C93
	ld   b, $01
	ld   c, $01
	call CopyBGToRect
	ld   de, $4BF6
	ld   hl, WINDOWMap_Begin
	ld   b, $02
	ld   c, $01
	call CopyBGToRect
	ld   de, $4BF8
	ld   hl, $9C12
	ld   b, $02
	ld   c, $01
	call CopyBGToRect
	ld   a, [$D920]
	bit  7, a
	jp   nz, L001D9B
	ld   hl, $4000
	ld   de, $8FC0
	call CopyTilesAutoNum
	jp   L001DA4
L001D9B:;J
	ld   hl, $4042
	ld   de, $8FC0
	call CopyTilesAutoNum
L001DA4:;J
	ld   a, [$DA20]
	bit  7, a
	jp   nz, L001DB8
L001DAC: db $21;X
L001DAD: db $21;X
L001DAE: db $40;X
L001DAF: db $11;X
L001DB0: db $E0;X
L001DB1: db $8F;X
L001DB2: db $CD;X
L001DB3: db $40;X
L001DB4: db $0E;X
L001DB5: db $C3;X
L001DB6: db $C1;X
L001DB7: db $1D;X
L001DB8:;J
	ld   hl, $4063
	ld   de, $8FE0
	call CopyTilesAutoNum
	ret
L001DC2:;C
	call L001F85
	jp   c, L001E5E
	ld   hl, $4BFA
	ld   de, $9740
	ld   b, $02
	call CopyTiles
	ld   a, [$D92E]
	ld   de, $96C0
	ld   hl, $9C41
	ld   c, $6C
	call L001FAC
	ld   a, [$D936]
	cp   $01
	jp   c, L001DF4
	ld   hl, $9C42
	ld   c, $74
	call L001F9A
	jp   L001DFC
L001DF4:;J
	ld   hl, $9C42
	ld   c, $75
	call L001F9A
L001DFC:;J
	ld   a, [$D936]
	cp   $02
	jp   c, L001E0F
L001E04: db $21;X
L001E05: db $43;X
L001E06: db $9C;X
L001E07: db $0E;X
L001E08: db $74;X
L001E09: db $CD;X
L001E0A: db $9A;X
L001E0B: db $1F;X
L001E0C: db $C3;X
L001E0D: db $17;X
L001E0E: db $1E;X
L001E0F:;J
	ld   hl, $9C43
	ld   c, $75
	call L001F9A
	ld   a, [$DA2E]
	ld   de, $9700
	ld   hl, $9C52
	ld   c, $70
	call L001FE7
	ld   a, [$DA36]
	cp   $01
	jp   c, L001E38
	ld   hl, $9C51
	ld   c, $74
	call L001F9A
	jp   L001E40
L001E38:;J
	ld   hl, $9C51
	ld   c, $75
	call L001F9A
L001E40:;J
	ld   a, [$DA36]
	cp   $02
	jp   c, L001E53
L001E48: db $21;X
L001E49: db $50;X
L001E4A: db $9C;X
L001E4B: db $0E;X
L001E4C: db $74;X
L001E4D: db $CD;X
L001E4E: db $9A;X
L001E4F: db $1F;X
L001E50: db $C3;X
L001E51: db $5B;X
L001E52: db $1E;X
L001E53:;J
	ld   hl, $9C50
	ld   c, $75
	call L001F9A
	jp   L001F84
L001E5E:;J
	ld   hl, $D92E
	ld   a, [$D92D]
	cp   $03
	jp   nz, L001E6B
	ld   a, $02
L001E6B:;J
	add  a, L
	jp   nc, L001E70
L001E6F: db $24;X
L001E70:;J
	ld   l, a
	ld   a, [hl]
	ld   de, $96C0
	ld   hl, $9C41
	ld   c, $6C
	call L001FAC
	ld   a, [$D92D]
	cp   $00
	jp   z, L001E8D
	cp   $01
	jp   z, L001EA2
	jp   L001ED4
L001E8D:;J
	ld   a, [$D930]
	ld   de, wLZSS_Buffer
	call L002087
	ld   a, [$D92F]
	ld   de, $C20A
	call L002087
	jp   L001EE6
L001EA2:;J
	ld   a, [$D930]
	cp   $FF
	jp   z, L001EBF
	ld   a, [$D92E]
	ld   de, wLZSS_Buffer
	call L002022
	ld   a, [$D930]
	ld   de, $C20A
	call L002087
	jp   L001EE6
L001EBF: db $FA;X
L001EC0: db $2E;X
L001EC1: db $D9;X
L001EC2: db $11;X
L001EC3: db $0A;X
L001EC4: db $C2;X
L001EC5: db $CD;X
L001EC6: db $22;X
L001EC7: db $20;X
L001EC8: db $FA;X
L001EC9: db $30;X
L001ECA: db $D9;X
L001ECB: db $11;X
L001ECC: db $CA;X
L001ECD: db $C1;X
L001ECE: db $CD;X
L001ECF: db $87;X
L001ED0: db $20;X
L001ED1: db $C3;X
L001ED2: db $E6;X
L001ED3: db $1E;X
L001ED4:;J
	ld   a, [$D92F]
	ld   de, wLZSS_Buffer
	call L002022
	ld   a, [$D92E]
	ld   de, $C20A
	call L002022
L001EE6:;J
	ld   hl, $9C44
	ld   de, $9740
	ld   c, $74
	call L0020D1
	ld   hl, $DA2E
	ld   a, [$DA2D]
	cp   $03
	jp   nz, L001EFE
	ld   a, $02
L001EFE:;J
	add  a, L
	jp   nc, L001F03
L001F02: db $24;X
L001F03:;J
	ld   l, a
	ld   a, [hl]
	ld   de, $9700
	ld   hl, $9C52
	ld   c, $70
	call L001FE7
	ld   a, [$DA2D]
	cp   $00
	jp   z, L001F20
	cp   $01
	jp   z, L001F35
	jp   L001F67
L001F20:;J
	ld   a, [$DA30]
	ld   de, wLZSS_Buffer
	call L002087
	ld   a, [$DA2F]
	ld   de, $C20A
	call L002087
	jp   L001F79
L001F35:;J
	ld   a, [$D930]
	cp   $FF
	jp   z, L001F52
	ld   a, [$DA2E]
	ld   de, wLZSS_Buffer
	call L002066
	ld   a, [$DA30]
	ld   de, $C20A
	call L002087
	jp   L001F79
L001F52:;J
	ld   a, [$DA2E]
	ld   de, $C20A
	call L002066
	ld   a, [$DA30]
	ld   de, wLZSS_Buffer
	call L002087
	jp   L001F79
L001F67:;J
	ld   a, [$DA2F]
	ld   de, wLZSS_Buffer
	call L002066
	ld   a, [$DA2E]
	ld   de, $C20A
	call L002066
L001F79:;J
	ld   hl, $9C4F
	ld   de, $97A0
	ld   c, $7A
	call L0020E5
L001F84:;J
	ret
L001F85:;C
	ld   a, [$C163]
	bit  0, a
	jp   z, L001F95
	bit  1, a
	jp   nz, L001F98
	jp   L001F98
L001F95:;J
	scf
	ccf
	ret
L001F98:;J
	scf
	ret
L001F9A:;C
	ld   a, [$C167]
	cp   $03
	jp   z, L001FAB
L001FA2:;J
	ldh  a, [rSTAT]
	bit  1, a
	jp   nz, L001FA2
	ld   a, c
	ldi  [hl], a
L001FAB:;J
	ret
L001FAC:;C
	push bc
	ld   b, $00
	ld   c, a
	sla  c
	rl   b
	sla  c
	rl   b
	sla  c
	rl   b
	sla  c
	rl   b
	sla  c
	rl   b
	ldh  a, [hROMBank]
	push af
	ld   a, $1D
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	push hl
	ld   hl, $4552
	add  hl, bc
	ld   b, $04
	call L000ECF
	pop  hl
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	pop  bc
	ld   a, c
	ld   b, $02
	call L00211E
	ret
L001FE7:;C
	push bc
	ld   b, $00
	ld   c, a
	sla  c
	rl   b
	sla  c
	rl   b
	sla  c
	rl   b
	sla  c
	rl   b
	sla  c
	rl   b
	ldh  a, [hROMBank]
	push af
	ld   a, $1D
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	push hl
	ld   hl, $4552
	add  hl, bc
	ld   b, $04
	call L000E7D
	pop  hl
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	pop  bc
	ld   a, c
	ld   b, $02
	call L002138
	ret
L002022:;C
	push de
	call L002087
	pop  de
	ldh  a, [hROMBank]
	push af
	ld   a, $1D
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	push de
	ld   hl, $4C1A
	ld   de, $C2CA
	ld   b, $04
	call L000ECF
	ld   hl, $4C5A
	ld   de, $C30A
	ld   b, $04
	call L000ECF
	pop  de
	ld   hl, $C2EA
	ld   bc, $C32A
	ld   a, $02
	call L000E9A
	ld   hl, $C2CA
	ld   bc, $C30A
	ld   a, $02
	call L000E9A
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret
L002066:;C
	push de
	call L002087
	pop  de
	ldh  a, [hROMBank]
	push af
	ld   a, $1D
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ld   hl, $4C1A
	ld   bc, $4C5A
	ld   a, $40
	call L000E9A
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret
L002087:;C
	cp   $FF
	jp   nz, L002098
	push bc
	ld   b, $40
	xor  a
L002090:;J
	ld   [de], a
	inc  de
	dec  b
	jp   nz, L002090
	pop  bc
	ret
L002098:;J
	push bc
	ld   b, $00
	ld   c, a
	sla  c
	rl   b
	sla  c
	rl   b
	sla  c
	rl   b
	sla  c
	rl   b
	sla  c
	rl   b
	ldh  a, [hROMBank]
	push af
	ld   a, $1D
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	push hl
	ld   hl, $4552
	add  hl, bc
	ld   b, $40
L0020C1:;J
	ldi  a, [hl]
	ld   [de], a
	inc  de
	dec  b
	jp   nz, L0020C1
	pop  hl
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	pop  bc
	ret
L0020D1:;C
	call L0020F9
	push hl
	ld   hl, wLZSS_Buffer
	ld   b, $06
	call L000ECF
	pop  hl
	ld   a, c
	ld   b, $03
	call L00211E
	ret
L0020E5:;C
	call L0020F9
	push hl
	ld   hl, wLZSS_Buffer
	ld   b, $06
	call L000E7D
	pop  hl
	ld   a, c
	ld   b, $03
	call L002138
	ret
L0020F9:;C
	push bc
	push de
	push hl
	ld   hl, $C1EA
	ld   de, $C20A
	ld   b, $40
L002104:;J
	ld   a, [hl]
	and  a, $F0
	ld   c, a
	ld   a, [de]
	and  a, $F0
	swap a
	or   a, c
	ldi  [hl], a
	ld   a, [de]
	and  a, $0F
	swap a
	ld   [de], a
	inc  de
	dec  b
	jp   nz, L002104
	pop  hl
	pop  de
	pop  bc
	ret
L00211E:;JC
	push af
L00211F:;J
	ldh  a, [rSTAT]
	bit  1, a
	jp   nz, L00211F
	pop  af
	ld   [hl], a
	inc  a
	ld   de, $0020
	add  hl, de
	ldd  [hl], a
	inc  a
	ld   de, hROMBank
	add  hl, de
	dec  b
	jp   nz, L00211E
	ret
L002138:;JC
	push af
L002139:;J
	ldh  a, [rSTAT]
	bit  1, a
	jp   nz, L002139
	pop  af
	ld   [hl], a
	inc  a
	ld   de, $0020
	add  hl, de
	ldi  [hl], a
	inc  a
	ld   de, hROMBank
	add  hl, de
	dec  b
	jp   nz, L002138
	ret
L002152:;C
	ld   hl, $0000
	ld   b, $06
	ld   de, $9600
	call L000E1B
	ld   hl, $0000
	ld   b, $06
	ld   de, $9660
	call L000E1B
	ld   hl, $4084
	ld   de, wLZSS_Buffer
	call DecompressGFX
	ld   a, [$D92C]
	call L00217E
	ld   a, [$DA2C]
	call L0021B3
	ret
L00217E:;C
	ld   b, $00
	ld   c, a
	ld   hl, $220B
	add  hl, bc
	ld   e, [hl]
	inc  hl
	ld   d, [hl]
	push de
	pop  hl
	ld   b, [hl]
	inc  hl
	ld   a, $06
	sub  a, b
	ld   de, $9600
	push hl
	sla  a
	sla  a
	sla  a
	sla  a
	ld   h, $00
	ld   l, a
	add  hl, de
	push hl
	pop  de
	pop  hl
	call L0021D5
	ld   de, $21FB
	ld   hl, $9C02
	ld   b, $06
	ld   c, $01
	call CopyBGToRect
	ret
L0021B3:;C
	ld   b, $00
	ld   c, a
	ld   hl, $220B
	add  hl, bc
	ld   e, [hl]
	inc  hl
	ld   d, [hl]
	push de
	pop  hl
	ldi  a, [hl]
	ld   b, a
	ld   de, $9660
	call L0021D5
	ld   de, $2203
	ld   hl, $9C0C
	ld   b, $06
	ld   c, $01
	call CopyBGToRect
	ret
L0021D5:;JC
	push bc
	ldi  a, [hl]
	ld   b, $00
	ld   c, a
	sla  c
	rl   b
	sla  c
	rl   b
	sla  c
	rl   b
	sla  c
	rl   b
	push hl
	ld   hl, wLZSS_Buffer
	add  hl, bc
	ld   b, $01
	call CopyTiles
	pop  hl
	pop  bc
	dec  b
	jp   nz, L0021D5
	ret
L0021FB: db $60
L0021FC: db $61
L0021FD: db $62
L0021FE: db $63
L0021FF: db $64
L002200: db $65
L002201: db $66;X
L002202: db $67;X
L002203: db $66
L002204: db $67
L002205: db $68
L002206: db $69
L002207: db $6A
L002208: db $6B
L002209: db $6C;X
L00220A: db $6D;X
L00220B: db $D8
L00220C: db $44
L00220D: db $DC
L00220E: db $44
L00220F: db $E3
L002210: db $44
L002211: db $E9
L002212: db $44
L002213: db $EE
L002214: db $44
L002215: db $F2
L002216: db $44
L002217: db $F9
L002218: db $44
L002219: db $00
L00221A: db $45
L00221B: db $04
L00221C: db $45
L00221D: db $0A
L00221E: db $45
L00221F: db $10
L002220: db $45
L002221: db $17
L002222: db $45
L002223: db $1D
L002224: db $45
L002225: db $22
L002226: db $45
L002227: db $29
L002228: db $45
L002229: db $30
L00222A: db $45
L00222B: db $37
L00222C: db $45
L00222D: db $3E
L00222E: db $45
L00222F: db $44
L002230: db $45
L002231: db $4B
L002232: db $45
L002233:;C
	ld   de, $225B
	ld   hl, $9C20
	ld   b, $09
	ld   c, $01
	call CopyBGToRect
	ld   de, $225B
	ld   hl, $9C2B
	ld   b, $09
	ld   c, $01
	call CopyBGToRect
	ld   de, $4BE2
	ld   hl, $9C80
	ld   b, $14
	ld   c, $01
	call CopyBGToRect
	ret
L00225B: db $E0
L00225C: db $E0
L00225D: db $E0
L00225E: db $E0
L00225F: db $E0
L002260: db $E0
L002261: db $E0
L002262: db $E0
L002263: db $E0
L002264:;C
	ldh  a, [hROMBank]
	push af
	ld   a, $01
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ld   a, [$C167]
	inc  a
	ld   [$C167], a
	ld   hl, $4000
	ld   de, wLZSS_Buffer
	call DecompressGFX
	ld   hl, wLZSS_Buffer
	ld   de, $8800
	ld   b, $44
	call CopyTiles
	ld   a, [$C167]
	sla  a
	sla  a
	sla  a
	ld   d, $00
	ld   e, a
	sla  e
	rl   d
	sla  e
	rl   d
	sla  e
	rl   d
	sla  e
	rl   d
	ld   hl, $C60A
	add  hl, de
	ld   de, $8C40
	ld   b, $08
	call CopyTiles
	ld   hl, wOBJInfo3+iOBJInfo_Status
	ld   de, $48C3
	call L000D76
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret
L0022C1:;C
	ld   hl, wOBJInfo3+iOBJInfo_Status
	ld   [hl], $80
	ld   a, [$C160]
	cp   $01
	jp   z, L0022D3
	ld   a, $00
	jp   L0022D5
L0022D3:;J
	ld   a, $04
L0022D5:;J
	ld   hl, $D753
	ld   [hl], a
	ld   b, $78
	call L0022FC
	ld   [hl], $08
	ld   b, $3C
	call L0022FC
	ld   [hl], $0C
	ld   b, $08
	call L0022FC
	ld   [hl], $10
	ld   b, $3C
	call L0022FC
	ld   hl, wOBJInfo3+iOBJInfo_Status
	ld   [hl], $00
	call Task_ExecRunFar_B01
	ret
L0022FC:;C
	push hl
L0022FD:;J
	push bc
	ldh  a, [hROMBank]
	push af
	ld   a, $01
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	call $75BB
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	call L0023EC
	call Task_ExecRunFar_B01
	pop  bc
	dec  b
	jp   nz, L0022FD
	pop  hl
	ret
L00231E:;C
	ld   bc, $D900
	ld   de, $DA00
	call L002331
	ld   bc, $DA00
	ld   de, $D900
	call L002331
	ret
L002331:;C
	ld   hl, $002C
	add  hl, bc
	ld   a, [hl]
	cp   $0E
	jp   z, L00235F
	cp   $0C
	jp   z, L00235F
	cp   $10
	jp   z, L00235F
	cp   $24
	jp   z, L00235F
	cp   $18
	jp   z, L00235F
	cp   $22
	jp   z, L00235F
	cp   $14
	jp   z, L00235F
	cp   $20
	jp   z, L00235F
	ret
L00235F:;J
	ld   hl, $002C
	add  hl, bc
	ld   a, [hl]
	cp   $00
	jr   z, L002372
	cp   $18
	jr   z, L002381
	cp   $12
	jr   z, L00238C
	jr   L002397
L002372:;R
	ld   hl, $002C
	add  hl, de
	ld   a, [hl]
	cp   $18
	jr   z, L00239B
	cp   $22
	jr   z, L00239B
	jr   L002397
L002381:;R
	ld   hl, $002C
	add  hl, de
	ld   a, [hl]
	cp   $00
	jr   z, L00239B
	jr   L002397
L00238C:;R
	ld   hl, $002C
	add  hl, de
	ld   a, [hl]
	cp   $04
	jr   z, L00239B
	jr   L002397
L002397:;R
	ld   a, $2C
	jr   L00239D
L00239B:;R
	ld   a, $2E
L00239D:;R
	ld   hl, $0035
	add  hl, bc
	ld   [hl], a
	ret
L0023A3:;C
	ld   b, $3C
	call L0022FC
	ld   bc, $D900
	ld   de, $DA00
	call L0023BB
	ld   bc, $DA00
	ld   de, $D900
	call L0023BB
	ret
L0023BB:;C
	ld   hl, $002C
	add  hl, bc
	ld   a, [hl]
	cp   $0C
	jp   z, L0023EB
	cp   $0E
	jp   z, L0023EB
	cp   $10
	jp   z, L0023EB
	cp   $24
	jp   z, L0023EB
	cp   $18
	jp   z, L0023EB
	cp   $22
	jp   z, L0023EB
	cp   $14
	jp   z, L0023EB
	cp   $20
	jp   z, L0023EB
	jp   L00235F
L0023EB:;J
	ret
L0023EC:;C
	ldh  a, [hROMBank]
	push af
	ld   a, $01
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	call $76B4
	call $78E1
	call $7D80
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret
L002406:;C
	ldh  a, [hROMBank]
	push af
	ld   a, $01
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	call $7DEA
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret
L00241A: db $80
L00241B: db $20
L00241C: db $20
L00241D: db $60
L00241E: db $00
L00241F: db $88
L002420: db $00
L002421: db $00
L002422: db $00
L002423: db $00
L002424: db $00
L002425: db $00
L002426: db $00
L002427: db $00
L002428: db $00
L002429: db $80
L00242A: db $09
L00242B: db $AE
L00242C: db $4E
L00242D: db $00
L00242E: db $09
L00242F: db $AE
L002430: db $4E
L002431: db $00
L002432: db $00
L002433: db $00
L002434: db $00
L002435: db $00
L002436: db $00
L002437: db $C0
L002438: db $D8
L002439: db $80
L00243A: db $10
L00243B: db $10
L00243C: db $A0
L00243D: db $00
L00243E: db $88
L00243F: db $00
L002440: db $00
L002441: db $00
L002442: db $00
L002443: db $00
L002444: db $00
L002445: db $00
L002446: db $40
L002447: db $00
L002448: db $84
L002449: db $08
L00244A: db $00
L00244B: db $40
L00244C: db $00
L00244D: db $08
L00244E: db $00
L00244F: db $40
L002450: db $00
L002451: db $00
L002452: db $00
L002453: db $00
L002454: db $00
L002455: db $00
L002456: db $E0
L002457: db $D8
L002458:;I
	ld   sp, $DE00
	ei
	ld   bc, $D900
	ld   de, wOBJInfo_Pl1+iOBJInfo_Status
	jr   L00246E
L002464:;I
	ld   sp, $DF00
	ei
	ld   bc, $DA00
	ld   de, wOBJInfo_Pl2+iOBJInfo_Status
L00246E:;R
	ld   a, $02
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
L002475:;J
	push bc
	push de
	call L002482
	pop  de
	pop  bc
	call Task_ExecRunFar_B01
	jp   L002475
L002482:;C
	call L002D75
	call L003A99
	jp   c, L002497
	call L002F1F
	jp   c, L002494
	call L002F4B
L002494:;J
	call L003CE7
L002497:;J
	push de
	ld   a, $03
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ld   hl, $0026
	add  hl, bc
	ld   d, [hl]
	inc  hl
	ld   e, [hl]
	push de
	ld   hl, $0033
	add  hl, bc
	ld   a, [hl]
	cp   $70
	jp   nc, L0024BE
	cp   $30
	jp   nc, L0024C8
	pop  de
	ld   de, $7020
	push de
	jp   L0024CD
L0024BE:;J
	pop  de
	ld   de, $7068
	push de
	sub  a, $70
	jp   L0024CD
L0024C8:;J
	sub  a, $30
	jp   L0024CD
L0024CD:;J
	ld   h, $00
	ld   l, a
	srl  a
	add  a, L
	ld   l, a
	pop  de
	add  hl, de
	ld   e, [hl]
	inc  hl
	ld   d, [hl]
	inc  hl
	ld   a, [hl]
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	push de
	pop  hl
	pop  de
	jp   hl
L0024E4:;C
	ldh  a, [hROMBank]
	push af
	ld   a, $03
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	call $7707
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret
L0024F8:;C
	ld   hl, $002B
	add  hl, bc
	ld   a, [hl]
	push de
	pop  bc
	ld   hl, $0080
	add  hl, bc
	push hl
	pop  de
	ld   [hl], $80
	or   a
	jp   nz, L002514
	ld   hl, $000D
	add  hl, de
	ld   [hl], $80
	jp   L00251A
L002514:;J
	ld   hl, $000D
	add  hl, de
	ld   [hl], $A6
L00251A:;J
	ret
L00251B:;C
	push bc
	ld   hl, $0003
	add  hl, bc
	push hl
	pop  bc
	ld   hl, $0003
	add  hl, de
	ld   a, [bc]
	inc  bc
	ldi  [hl], a
	ld   a, [bc]
	inc  bc
	ldi  [hl], a
	ld   a, [bc]
	inc  bc
	ldi  [hl], a
	ld   a, [bc]
	inc  bc
	ldi  [hl], a
	pop  bc
	ld   hl, $0001
	add  hl, bc
	ld   a, [hl]
	ld   hl, $0001
	add  hl, de
	ld   [hl], a
	ret
L00253E:;C
	ld   a, $16
	call HomeCall_Sound_ReqPlayExId
	push bc
	push de
	ld   hl, $0050
	add  hl, bc
	ld   a, [hl]
	cp   $28
	jp   z, L002553
	xor  a
	jp   L002554
L002553:;J
	scf
L002554:;J
	ld   hl, $0022
	push af
	add  hl, bc
	pop  af
	ld   a, [hl]
	push af
	call L0024F8
	ld   hl, $0020
	add  hl, de
	ld   [hl], $02
	inc  hl
	ld   [hl], $47
	inc  hl
	ld   [hl], $71
	ld   hl, $0010
	add  hl, de
	ld   [hl], $01
	inc  hl
	ld   [hl], $D3
	inc  hl
	ld   [hl], $59
	inc  hl
	ld   [hl], $00
	ld   hl, $001B
	add  hl, de
	ld   [hl], $01
	inc  hl
	ld   [hl], $01
	ld   hl, $0027
	add  hl, de
	ld   [hl], $00
	call L00251B
	ld   hl, $1000
	call L0034F7
	ld   hl, $F800
	call L0034DD
	pop  af
	jp   nc, L0025A4
	bit  1, a
	jp   nz, L0025C1
	jp   L0025A9
L0025A4:;J
	bit  1, a
	jp   nz, L0025B5
L0025A9:;J
	ld   hl, $0028
	add  hl, de
	ld   [hl], $1E
	ld   hl, $0000
	jp   L0025CA
L0025B5:;J
	ld   hl, $0028
	add  hl, de
	ld   [hl], $23
	ld   hl, $0100
	jp   L0025CA
L0025C1:;J
	ld   hl, $0028
	add  hl, de
	ld   [hl], $28
	ld   hl, $0200
L0025CA:;J
	call L003569
	pop  de
	pop  bc
	ret
L0025D0:;C
	push bc
	push de
	ld   hl, $002C
	add  hl, bc
	ld   a, [hl]
	push af
	push af
	ld   hl, $0033
	add  hl, bc
	ld   a, [hl]
	push af
	call L0024F8
	ld   hl, $0020
	add  hl, de
	ld   [hl], $05
	inc  hl
	ld   [hl], $52
	inc  hl
	ld   [hl], $73
	pop  af
	cp   $66
	jp   z, L00260C
	pop  af
	cp   $10
	jp   nz, L002624
	ld   hl, $0010
	add  hl, de
	ld   [hl], $01
	inc  hl
	ld   [hl], $BF
	inc  hl
	ld   [hl], $59
	inc  hl
	ld   [hl], $00
	jp   L00263B
L00260C:;J
	pop  af
	cp   $10
	jp   nz, L002624
	ld   hl, $0010
	add  hl, de
	ld   [hl], $01
	inc  hl
	ld   [hl], $C9
	inc  hl
	ld   [hl], $59
	inc  hl
	ld   [hl], $00
	jp   L00263B
L002624:;J
	ld   hl, $0010
	add  hl, de
	ld   [hl], $01
	inc  hl
	ld   [hl], $DD
	inc  hl
	ld   [hl], $59
	inc  hl
	ld   [hl], $00
	ld   a, $A8
	call HomeCall_Sound_ReqPlayExId
	jp   L00263B
L00263B:;J
	ld   hl, $001B
	add  hl, de
	ld   [hl], $00
	inc  hl
	ld   [hl], $00
	ld   hl, $0027
	add  hl, de
	ld   [hl], $00
	inc  hl
	ld   [hl], $3C
	call L00251B
	pop  af
	cp   $10
	jp   nz, L002665
	ld   hl, $1000
	call L0034F7
	ld   hl, $F800
	call L0034DD
	jp   L002671
L002665:;J
	ld   hl, $1000
	call L0034F7
	ld   hl, $0005
	add  hl, de
	ld   [hl], $88
L002671:;J
	pop  de
	pop  bc
	ret
L002674:;C
	ld   a, $A8
	call HomeCall_Sound_ReqPlayExId
	push bc
	push de
	ld   hl, $0050
	add  hl, bc
	ld   a, [hl]
	cp   $28
	jp   z, L002689
	xor  a
	jp   L00268A
L002689:;J
	scf
L00268A:;J
	ld   hl, $0022
	push af
	add  hl, bc
	pop  af
	ld   a, [hl]
	push af
	call L0024F8
	ld   hl, $0010
	add  hl, de
	ld   [hl], $01
	inc  hl
	ld   [hl], $3B
	inc  hl
	ld   [hl], $59
	inc  hl
	ld   [hl], $00
	ld   hl, $0027
	add  hl, de
	ld   [hl], $00
	ld   hl, $0020
	add  hl, de
	ld   [hl], $06
	inc  hl
	ld   [hl], $9E
	inc  hl
	ld   [hl], $52
	ld   hl, $001B
	add  hl, de
	ld   [hl], $00
	inc  hl
	ld   [hl], $00
	call L00251B
	ld   hl, $1C00
	call L0034F7
	ld   hl, $FC00
	call L0034DD
	pop  af
	jp   nc, L0026DA
	bit  1, a
	jp   nz, L0026EB
	jp   L0026DF
L0026DA:;J
	bit  1, a
	jp   nz, L0026E5
L0026DF:;J
	ld   hl, $0180
	jp   L0026EE
L0026E5:;J
	ld   hl, $0300
	jp   L0026EE
L0026EB:;J
	ld   hl, $0500
L0026EE:;J
	call L003569
	pop  de
	pop  bc
	ret
L0026F4:;C
	ld   a, $16
	call HomeCall_Sound_ReqPlayExId
	push bc
	push de
	ld   hl, $0050
	add  hl, bc
	ld   a, [hl]
	cp   $28
	jp   z, L002709
	xor  a
	jp   L00270A
L002709:;J
	scf
L00270A:;J
	ld   hl, $0022
	push af
	add  hl, bc
	pop  af
	ld   a, [hl]
	push af
	call L0024F8
	ld   hl, $0010
	add  hl, de
	ld   [hl], $01
	inc  hl
	ld   [hl], $17
	inc  hl
	ld   [hl], $59
	inc  hl
	ld   [hl], $00
	ld   hl, $0027
	add  hl, de
	ld   [hl], $01
	jp   L002763
L00272D:;C
	ld   a, $14
	call HomeCall_Sound_ReqPlayExId
	push bc
	push de
	ld   hl, $0050
	add  hl, bc
	ld   a, [hl]
	cp   $28
	jp   z, L002742
L00273E: db $AF;X
L00273F: db $C3;X
L002740: db $43;X
L002741: db $27;X
L002742:;J
	scf
	ld   hl, $0022
	push af
	add  hl, bc
	pop  af
	ld   a, [hl]
	push af
	call L0024F8
	ld   hl, $0010
	add  hl, de
	ld   [hl], $01
	inc  hl
	ld   [hl], $29
	inc  hl
	ld   [hl], $59
	inc  hl
	ld   [hl], $00
	ld   hl, $0027
	add  hl, de
	ld   [hl], $02
L002763:;J
	ld   hl, $0020
	add  hl, de
	ld   [hl], $06
	inc  hl
	ld   [hl], $9E
	inc  hl
	ld   [hl], $52
	ld   hl, $001B
	add  hl, de
	ld   [hl], $00
	inc  hl
	ld   [hl], $00
	call L00251B
	ld   hl, $1000
	call L0034F7
	ld   hl, $F800
	call L0034DD
	pop  af
	jp   nc, L002793
	bit  1, a
	jp   nz, L0027A4
	jp   L002798
L002793:;J
	bit  1, a
	jp   nz, L00279E
L002798:;J
	ld   hl, $0180
	jp   L0027A7
L00279E:;J
	ld   hl, $0300
	jp   L0027A7
L0027A4:;J
	ld   hl, $0500
L0027A7:;J
	call L003569
	pop  de
	pop  bc
	ret
L0027AD:;C
	ld   a, $16
	call HomeCall_Sound_ReqPlayExId
	push bc
	push de
	ld   hl, $0050
	add  hl, bc
	ld   a, [hl]
	cp   $28
	jp   z, L0027C2
	xor  a
	jp   L0027C3
L0027C2:;J
	scf
L0027C3:;J
	ld   hl, $0022
	push af
	add  hl, bc
	pop  af
	ld   a, [hl]
	push af
	call L0024F8
	ld   hl, $0020
	add  hl, de
	ld   [hl], $06
	inc  hl
	ld   [hl], $9E
	inc  hl
	ld   [hl], $52
	ld   hl, $0010
	add  hl, de
	ld   [hl], $01
	inc  hl
	ld   [hl], $05
	inc  hl
	ld   [hl], $59
	inc  hl
	ld   [hl], $00
	ld   hl, $001B
	add  hl, de
	ld   [hl], $00
	inc  hl
	ld   [hl], $00
	ld   hl, $0027
	add  hl, de
	ld   [hl], $00
	call L00251B
	ld   hl, $0800
	call L0034F7
	pop  af
	jp   nc, L00280D
	bit  1, a
	jp   nz, L00281E
	jp   L002812
L00280D:;J
	bit  1, a
	jp   nz, L002818
L002812:;J
	ld   hl, $0100
	jp   L002821
L002818:;J
	ld   hl, $0200
	jp   L002821
L00281E:;J
	ld   hl, $0400
L002821:;J
	call L003569
	pop  de
	pop  bc
	ret
L002827:;C
	push de
	ld   hl, $0001
	add  hl, de
	ld   a, [hl]
	and  a, $20
	ld   d, a
	ld   hl, $002B
	add  hl, bc
	ld   a, [hl]
	or   a
	jp   nz, L00283F
	ld   hl, $D6C1
	jp   L002842
L00283F:;J
	ld   hl, $D681
L002842:;J
	ld   a, [hl]
	and  a, $DF
	or   a, d
	ld   [hl], a
	pop  de
	ret
L002849:;C
	push bc
	push de
	ld   hl, $0022
	add  hl, bc
	set  0, [hl]
	ld   hl, $0033
	add  hl, bc
	ld   [hl], a
	ld   hl, $0049
	add  hl, bc
	ld   [hl], $00
	ld   hl, $0024
	add  hl, bc
	push hl
	ld   hl, $0039
	add  hl, bc
	push hl
	pop  bc
	ld   hl, $0010
	add  hl, de
	push hl
	pop  de
	pop  hl
	push de
	push af
	ld   a, $03
	ld   [MBC1RomBank], a
	pop  af
	ld   d, [hl]
	inc  hl
	ld   e, [hl]
	ld   h, $00
	ld   l, a
	add  hl, hl
	add  hl, hl
	add  hl, de
	pop  de
	ldi  a, [hl]
	ld   [de], a
	inc  de
	ldi  a, [hl]
	ld   [de], a
	inc  de
	ldi  a, [hl]
	ld   [de], a
	inc  de
	ldi  a, [hl]
	ld   [bc], a
	inc  bc
	xor  a
	ld   [de], a
	inc  de
	push hl
	ld   hl, $0007
	add  hl, de
	push hl
	pop  de
	pop  hl
	ldi  a, [hl]
	ld   [de], a
	inc  de
	ld   [de], a
	xor  a
	ld   [bc], a
	inc  bc
	ld   [bc], a
	inc  bc
	ld   [bc], a
	inc  bc
	ldi  a, [hl]
	ld   [bc], a
	inc  bc
	ldi  a, [hl]
	ld   [bc], a
	inc  bc
	ld   a, [hl]
	ld   [bc], a
	ldh  a, [hROMBank]
	ld   [MBC1RomBank], a
	pop  de
	pop  bc
	ret
L0028B2:;C
	ld   hl, $000B
	add  hl, de
	ld   a, [hl]
	cp   $08
	jp   c, L0028DF
	cp   $A8
	jp   nc, L0028DF
	ld   hl, $0026
	add  hl, de
	ld   a, [hl]
	cp   $01
	jp   z, L0028D5
	cp   $02
	jp   z, L0028E1
L0028D0:;J
	call L0035B9
	xor  a
	ret
L0028D5:;J
	ld   hl, $0027
	add  hl, de
	ld   a, [hl]
	cp   $03
	jp   nc, L0028D0
L0028DF:;J
	scf
	ret
L0028E1: db $7B;X
L0028E2: db $FE;X
L0028E3: db $40;X
L0028E4: db $CA;X
L0028E5: db $FF;X
L0028E6: db $28;X
L0028E7: db $21;X
L0028E8: db $40;X
L0028E9: db $D7;X
L0028EA: db $CB;X
L0028EB: db $7E;X
L0028EC: db $C2;X
L0028ED: db $D3;X
L0028EE: db $28;X
L0028EF: db $CD;X
L0028F0: db $17;X
L0028F1: db $29;X
L0028F2: db $21;X
L0028F3: db $00;X
L0028F4: db $D7;X
L0028F5: db $CB;X
L0028F6: db $BE;X
L0028F7: db $21;X
L0028F8: db $19;X
L0028F9: db $D7;X
L0028FA: db $36;X
L0028FB: db $00;X
L0028FC: db $C3;X
L0028FD: db $D3;X
L0028FE: db $28;X
L0028FF: db $21;X
L002900: db $00;X
L002901: db $D7;X
L002902: db $CB;X
L002903: db $7E;X
L002904: db $C2;X
L002905: db $D3;X
L002906: db $28;X
L002907: db $CD;X
L002908: db $17;X
L002909: db $29;X
L00290A: db $21;X
L00290B: db $40;X
L00290C: db $D7;X
L00290D: db $CB;X
L00290E: db $BE;X
L00290F: db $21;X
L002910: db $59;X
L002911: db $D7;X
L002912: db $36;X
L002913: db $00;X
L002914: db $C3;X
L002915: db $D3;X
L002916: db $28;X
L002917: db $C5;X
L002918: db $D5;X
L002919: db $E5;X
L00291A: db $06;X
L00291B: db $40;X
L00291C: db $1A;X
L00291D: db $22;X
L00291E: db $13;X
L00291F: db $05;X
L002920: db $C2;X
L002921: db $1C;X
L002922: db $29;X
L002923: db $C1;X
L002924: db $21;X
L002925: db $26;X
L002926: db $00;X
L002927: db $09;X
L002928: db $36;X
L002929: db $00;X
L00292A: db $21;X
L00292B: db $01;X
L00292C: db $00;X
L00292D: db $09;X
L00292E: db $7E;X
L00292F: db $EE;X
L002930: db $30;X
L002931: db $77;X
L002932: db $D5;X
L002933: db $21;X
L002934: db $07;X
L002935: db $00;X
L002936: db $09;X
L002937: db $56;X
L002938: db $23;X
L002939: db $5E;X
L00293A: db $7A;X
L00293B: db $2F;X
L00293C: db $57;X
L00293D: db $7B;X
L00293E: db $2F;X
L00293F: db $5F;X
L002940: db $1C;X
L002941: db $C2;X
L002942: db $45;X
L002943: db $29;X
L002944: db $14;X
L002945: db $73;X
L002946: db $2B;X
L002947: db $72;X
L002948: db $D1;X
L002949: db $3E;X
L00294A: db $0F;X
L00294B: db $CD;X
L00294C: db $16;X
L00294D: db $10;X
L00294E: db $D1;X
L00294F: db $C1;X
L002950: db $C9;X
L002951:;JC
	xor  a
	ld   hl, $0000
	add  hl, de
	ld   [hl], a
	ret
L002958:;I
	call L00347B
	call L002D8C
	call L0038B3
	jp   c, L002B90
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $00
	jp   z, L002A27
	cp   $1C
	jp   z, L002B82
	ld   hl, $0005
	add  hl, de
	ld   a, [hl]
	cp   $88
	jr   z, L0029C0
	ld   hl, $0049
	add  hl, bc
	bit  4, [hl]
	jp   nz, L002A14
	bit  5, [hl]
	jp   nz, L002A01
	bit  6, [hl]
	jp   nz, L002A14
	bit  7, [hl]
	jp   nz, L002A01
	jp   L0029C0
L002997: db $21;X
L002998: db $33;X
L002999: db $00;X
L00299A: db $09;X
L00299B: db $7E;X
L00299C: db $FE;X
L00299D: db $0C;X
L00299E: db $CA;X
L00299F: db $C0;X
L0029A0: db $29;X
L0029A1: db $21;X
L0029A2: db $6D;X
L0029A3: db $00;X
L0029A4: db $09;X
L0029A5: db $CB;X
L0029A6: db $46;X
L0029A7: db $C2;X
L0029A8: db $E6;X
L0029A9: db $29;X
L0029AA: db $21;X
L0029AB: db $74;X
L0029AC: db $00;X
L0029AD: db $09;X
L0029AE: db $7E;X
L0029AF: db $B7;X
L0029B0: db $CA;X
L0029B1: db $C0;X
L0029B2: db $29;X
L0029B3: db $21;X
L0029B4: db $81;X
L0029B5: db $00;X
L0029B6: db $09;X
L0029B7: db $7E;X
L0029B8: db $FE;X
L0029B9: db $88;X
L0029BA: db $CA;X
L0029BB: db $C0;X
L0029BC: db $29;X
L0029BD: db $C3;X
L0029BE: db $E6;X
L0029BF: db $29;X
L0029C0:;JR
	ld   hl, $0017
	add  hl, de
	ld   a, [hl]
	cp   $04
	jp   z, L002A33
	cp   $08
	jp   z, L002B35
	cp   $0C
	jp   z, L002B3F
	cp   $10
	jp   z, L002B49
	cp   $14
	jp   z, L002B53
	cp   $18
	jp   z, L002B5D
L0029E3: db $C3;X
L0029E4: db $66;X
L0029E5: db $2B;X
L0029E6: db $21;X
L0029E7: db $21;X
L0029E8: db $00;X
L0029E9: db $09;X
L0029EA: db $CB;X
L0029EB: db $DE;X
L0029EC: db $3E;X
L0029ED: db $14;X
L0029EE: db $CD;X
L0029EF: db $44;X
L0029F0: db $34;X
L0029F1: db $C3;X
L0029F2: db $66;X
L0029F3: db $2B;X
L0029F4:;J
	ld   a, $09
	call HomeCall_Sound_ReqPlayExId
	ld   a, $46
	call L003444
	jp   L002B66
L002A01:;J
	call L002D9F
	jp   c, L0029F4
	ld   a, $08
	call HomeCall_Sound_ReqPlayExId
	ld   a, $42
	call L003444
	jp   L002B66
L002A14:;J
	call L002D9F
	jp   c, L0029F4
	ld   a, $09
	call HomeCall_Sound_ReqPlayExId
	ld   a, $44
	call L003444
	jp   L002B66
L002A27:;J
	call L002DD9
	jp   nc, L002B8D
	inc  hl
	ld   [hl], $FF
	jp   L002B8D
L002A33:;J
	ld   hl, $0000
	add  hl, de
	bit  3, [hl]
	jp   z, L002B2B
	ld   hl, $0020
	add  hl, bc
	set  2, [hl]
	ld   hl, $0047
	add  hl, bc
	bit  1, [hl]
	jr   nz, L002A51
	bit  0, [hl]
	jr   nz, L002A97
	jp   L002B09
L002A51:;R
	ld   hl, $0083
	add  hl, bc
	ld   a, [hl]
	or   a
	jp   nz, L002A6B
	ld   hl, $3EEB
	call L002CA8
	jp   c, L002A6B
	ld   hl, $0065
	call L002B91
	jr   L002A7A
L002A6B:;J
	ld   a, $9C
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0065
	call L002B91
	sla  l
	rl   h
L002A7A:;R
	ld   a, h
	cpl
	ld   h, a
	ld   a, l
	cpl
	ld   l, a
	inc  l
	jp   nz, L002A85
	inc  h
L002A85:;J
	call L0035A1
	ld   a, $0E
	ld   hl, $0001
	add  hl, de
	bit  5, [hl]
	jr   nz, L002ACF
	ld   a, $0C
	jp   L002ACF
L002A97:;R
	ld   hl, $0083
	add  hl, bc
	ld   a, [hl]
	or   a
	jp   nz, L002AB1
	ld   hl, $3EEB
	call L002CA8
	jp   c, L002AB1
	ld   hl, $0065
	call L002B91
	jr   L002AC0
L002AB1:;J
	ld   a, $9C
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0065
	call L002B91
	sla  l
	rl   h
L002AC0:;R
	call L0035A1
	ld   a, $0C
	ld   hl, $0001
	add  hl, de
	bit  5, [hl]
	jr   nz, L002ACF
	ld   a, $0E
L002ACF:;JR
	ld   hl, $0033
	add  hl, bc
	ld   [hl], a
	push de
	ld   hl, $0011
	add  hl, de
	push hl
	pop  de
	push de
	push af
	ld   a, $03
	ld   [MBC1RomBank], a
	pop  af
	ld   hl, $0024
	add  hl, bc
	ld   d, [hl]
	inc  hl
	ld   e, [hl]
	ld   h, $00
	ld   l, a
	add  hl, hl
	add  hl, hl
	add  hl, de
	pop  de
	inc  hl
	ldi  a, [hl]
	ld   [de], a
	inc  de
	inc  de
	inc  de
	inc  de
	ld   [de], a
	dec  de
	dec  de
	dec  de
	ldi  a, [hl]
	ld   [de], a
	inc  de
	inc  de
	inc  de
	inc  de
	ld   [de], a
	ldh  a, [hROMBank]
	ld   [MBC1RomBank], a
	pop  de
L002B09:;J
	ld   hl, $0045
	add  hl, bc
	ld   a, [hl]
	ld   hl, $0069
	call L002B91
	bit  2, a
	jr   nz, L002B25
	sra  h
	rr   l
	push de
	push hl
	pop  de
	sra  d
	rr   e
	add  hl, de
	pop  de
L002B25:;R
	call L0035AD
	jp   L002B66
L002B2B:;J
	ld   a, $F9
	ld   h, $FF
	call L002E63
	jp   L002B5D
L002B35:;J
	ld   a, $FB
	ld   h, $FF
	call L002E63
	jp   L002B5D
L002B3F:;J
	ld   a, $FD
	ld   h, $FF
	call L002E63
	jp   L002B5D
L002B49:;J
	ld   a, $FF
	ld   h, $FF
	call L002E63
	jp   L002B5D
L002B53:;J
	ld   a, $01
	ld   h, $FF
	call L002E63
	jp   L002B5D
L002B5D:;J
	call L002B9A
	jp   nc, L002B66
	jp   L002B90
L002B66:;J
	ld   hl, $006B
	call L002B91
	call L003614
	jp   nc, L002B8D
	ld   hl, $0021
	add  hl, bc
	res  2, [hl]
	ld   a, $1C
	ld   h, $00
	call L002DEC
	jp   L002B90
L002B82:;J
	call L002DD9
	jp   nc, L002B8D
	call L002EA2
	jr   L002B90
L002B8D:;J
	jp   L002F0B
L002B90:;JR
	ret
L002B91:;C
	push de
	add  hl, bc
	ld   d, [hl]
	inc  hl
	ld   e, [hl]
	push de
	pop  hl
	pop  de
	ret
L002B9A:;C
	ld   hl, $002C
	add  hl, bc
	ld   a, [hl]
	cp   $0E
	jp   z, L002BAC
	cp   $0C
	jp   z, L002BAC
	jp   L002BE2
L002BAC:;J
	ld   hl, $001F
	add  hl, de
	ld   a, [hl]
	or   a
	jp   z, L002BE2
	bit  7, a
	jp   nz, L002BCE
	ld   hl, $0045
	add  hl, bc
	bit  0, [hl]
	jp   z, L002BE2
	ld   hl, $0047
	add  hl, bc
	set  0, [hl]
	res  1, [hl]
	jp   L002BE5
L002BCE:;J
	ld   hl, $0045
	add  hl, bc
	bit  1, [hl]
	jp   z, L002BE2
	ld   hl, $0047
	add  hl, bc
	set  1, [hl]
	res  0, [hl]
	jp   L002BE5
L002BE2:;J
	scf
	ccf
	ret
L002BE5:;J
	ld   hl, $0001
	add  hl, de
	bit  3, [hl]
	jp   z, L002BF3
	set  5, [hl]
	jp   L002BF5
L002BF3:;J
	res  5, [hl]
L002BF5:;J
	ld   a, $0A
	call L00341B
	scf
	ret
L002BFC:;C
	ldh  a, [hROMBank]
	push af
	ld   bc, $D900
	ld   de, wOBJInfo2+iOBJInfo_Status
	ld   a, $04
L002C07:;J
	push af
	ld   a, [de]
	and  a, $80
	jp   z, L002C22
	xor  a
	ld   hl, $0021
	add  hl, de
	push bc
	ld   c, [hl]
	inc  hl
	ld   b, [hl]
	push bc
	pop  hl
	pop  bc
	or   a, L
	jp   nz, L002C3A
	or   a, h
	jp   nz, L002C3A
L002C22:;J
	ld   hl, $0040
	add  hl, de
	push hl
	pop  de
	ld   hl, $0100
	add  hl, bc
	push hl
	pop  bc
	pop  af
	dec  a
	jp   nz, L002C07
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret
L002C3A:;J
	push bc
	push de
	call L002C44
	pop  de
	pop  bc
	jp   L002C22
L002C44:;C
	push hl
	ld   hl, $0020
	add  hl, de
	ld   a, [hl]
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	pop  hl
	jp   hl
L002C51: db $C9;X
L002C52:;C
	push bc
	push de
	push hl
	ld   hl, $004D
	add  hl, bc
	ld   a, [hl]
	ld   hl, $0000
	add  hl, bc
	or   a, L
	ld   l, a
	jp   L002C71
L002C63:;C
	push bc
	push de
	push hl
	ld   hl, $004C
	add  hl, bc
	ld   a, [hl]
	ld   hl, $0010
	add  hl, bc
	or   a, L
	ld   l, a
L002C71:;J
	push hl
	pop  de
	pop  hl
	ldi  a, [hl]
	ld   b, a
L002C76:;J
	ld   a, [de]
	ld   c, [hl]
	inc  hl
	and  a, [hl]
	cp   a, c
	jp   nz, L002CA4
	inc  de
	ld   a, [de]
	inc  hl
	cp   a, [hl]
	jp   c, L002CA4
	inc  hl
	cp   a, [hl]
	jp   z, L002C8D
	jp   nc, L002CA4
L002C8D:;J
	inc  hl
	ld   a, e
	dec  a
	dec  a
	dec  a
	and  a, $0F
	push af
	ld   a, $F0
	and  a, e
	ld   e, a
	pop  af
	or   a, e
	ld   e, a
	dec  b
	jp   nz, L002C76
	scf
	pop  de
	pop  bc
	ret
L002CA4:;J
	xor  a
	pop  de
	pop  bc
	ret
L002CA8:;C
	push bc
	push de
	push hl
	ld   hl, $004C
	add  hl, bc
	ld   a, [hl]
	ld   hl, $0010
	add  hl, bc
	or   a, L
	ld   l, a
	push hl
	pop  de
	pop  hl
	ldi  a, [hl]
	ld   b, a
	ld   c, $10
	ld   a, [de]
	or   a
	jp   nz, L002CDA
	inc  de
	ld   a, [de]
	cp   $0F
	jp   nc, L002D4F
	dec  c
	ld   a, e
	dec  a
	dec  a
	dec  a
	and  a, $0F
	push af
	ld   a, $F0
	and  a, e
	ld   e, a
	pop  af
	or   a, e
	ld   e, a
	ld   a, [de]
	dec  c
L002CDA:;J
	push bc
	ld   c, [hl]
	inc  hl
	and  a, [hl]
	cp   a, c
	pop  bc
	jp   z, L002D25
	jp   L002D4F
L002CE6:;J
	ld   a, [de]
	or   a
	jp   nz, L002D07
	inc  de
	ld   a, [de]
	cp   $05
	jp   nc, L002D4F
	dec  c
	jp   z, L002D4F
	ld   a, e
	dec  a
	dec  a
	dec  a
	and  a, $0F
	push af
	ld   a, $F0
	and  a, e
	ld   e, a
	pop  af
	or   a, e
	ld   e, a
	jp   L002CE6
L002D07:;J
	push bc
	ld   c, [hl]
	inc  hl
	and  a, [hl]
	cp   a, c
	pop  bc
	jp   z, L002D25
	dec  hl
	dec  c
	jp   z, L002D4F
	ld   a, e
	dec  a
	dec  a
	and  a, $0F
	push af
	ld   a, $F0
	and  a, e
	ld   e, a
	pop  af
	or   a, e
	ld   e, a
	jp   L002CE6
L002D25:;J
	inc  de
	ld   a, [de]
	inc  hl
	cp   a, [hl]
	jp   c, L002D4F
	inc  hl
	cp   a, [hl]
	jp   z, L002D34
	jp   nc, L002D4F
L002D34:;J
	inc  hl
	dec  c
	jp   z, L002D4F
	ld   a, e
	dec  a
	dec  a
	dec  a
	and  a, $0F
	push af
	ld   a, $F0
	and  a, e
	ld   e, a
	pop  af
	or   a, e
	ld   e, a
	dec  b
	jp   nz, L002CE6
	scf
	pop  de
	pop  bc
	ret
L002D4F:;J
	xor  a
	pop  de
	pop  bc
	ret
L002D53:;C
	push hl
	push bc
	xor  a
	ld   hl, $0010
	add  hl, bc
	ld   b, $10
L002D5C:;J
	ldi  [hl], a
	dec  b
	jp   nz, L002D5C
	pop  bc
	pop  hl
	ret
L002D64:;C
	push hl
	push bc
	xor  a
	ld   hl, $0000
	add  hl, bc
	ld   b, $10
L002D6D:;J
	ldi  [hl], a
	dec  b
	jp   nz, L002D6D
	pop  bc
	pop  hl
	ret
L002D75:;C
	ld   hl, $0045
	add  hl, bc
	push bc
	ldi  a, [hl]
	and  a, $0F
	ld   b, a
	ldi  a, [hl]
	inc  hl
	inc  hl
	or   a, [hl]
	and  a, $F0
	or   b
	pop  bc
	ld   hl, $0043
	add  hl, bc
	ld   [hl], a
	ret
L002D8C:;C
	ld   hl, $0046
	add  hl, bc
	ld   a, [hl]
	and  a, $F0
	jr   z, L002D9D
	ld   hl, $0049
	add  hl, bc
	or   a, [hl]
	ld   [hl], a
	scf
	ret
L002D9D:;R
	or   a
	ret
L002D9F:;C
	ld   hl, $0045
	add  hl, bc
	ld   l, [hl]
	bit  4, L
	jp   z, L002DAE
	bit  5, L
	jp   nz, L002DB0
L002DAE:;J
	or   a
	ret
L002DB0:;J
	scf
	ret
L002DB2:;C
	ld   hl, $0045
	add  hl, bc
	ld   a, [hl]
	and  a, $0F
	jp   z, L002DC9
	ld   hl, $0001
	add  hl, de
	bit  5, [hl]
	jp   nz, L002DC7
	xor  $03
L002DC7:;J
	scf
	ret
L002DC9:;J
	or   a
	ret
L002DCB:;C
	ld   hl, $0000
	add  hl, de
	bit  0, [hl]
	ret
L002DD2:;C
	ld   hl, $0000
	add  hl, de
	bit  3, [hl]
	ret
L002DD9:;C
	call L002DCB
	jp   nz, L002DEA
	ld   hl, $001B
	add  hl, de
	ld   a, [hl]
	or   a
	jp   nz, L002DEA
	scf
	ret
L002DEA:;J
	xor  a
	ret
L002DEC:;C
	push bc
	ld   b, h
	ld   hl, $0013
	add  hl, de
	cp   a, [hl]
	jp   z, L002E18
	ld   [hl], a
	ld   hl, $001B
	add  hl, de
	ld   [hl], b
	inc  hl
	ld   [hl], b
	call L002F15
	ld   hl, $002C
	add  hl, bc
	ld   a, [hl]
	cp   $02
	jp   z, L002E10
	ld   a, $9D
	jp   L002E12
L002E10: db $3E;X
L002E11: db $A6;X
L002E12:;J
	call HomeCall_Sound_ReqPlayExId
	ld   a, $01
	or   a
L002E18:;J
	pop  bc
	ret
L002E1A:;C
	push bc
	ld   b, h
	ld   hl, $0013
	add  hl, de
	cp   a, [hl]
	jp   z, L002E47
	ld   [hl], a
	ld   hl, $001B
	add  hl, de
	ld   [hl], b
	inc  hl
	ld   [hl], b
	call L002F15
	pop  bc
	call L003CAC
	jp   nz, L002E3E
	ld   a, $9B
	call HomeCall_Sound_ReqPlayExId
	jp   L002E43
L002E3E:;J
	ld   a, $01
	call HomeCall_Sound_ReqPlayExId
L002E43:;J
	ld   a, $01
	or   a
	ret
L002E47:;J
	pop  bc
	ret
L002E49:;C
	push bc
	ld   b, h
	ld   hl, $0013
	add  hl, de
	cp   a, [hl]
	jp   z, L002E61
	ld   [hl], a
	ld   hl, $001B
	add  hl, de
	ld   [hl], b
	inc  hl
	ld   [hl], b
	call L002F15
	ld   a, $01
	or   a
L002E61:;J
	pop  bc
	ret
L002E63:;C
	push bc
	ld   b, h
	add  a, $40
	push af
	ld   hl, $0009
	add  hl, de
	ld   a, [hl]
	add  a, $40
	ld   c, a
	pop  af
	cp   a, c
	jp   c, L002E78
	jp   L002E89
L002E78:;J
	call L002DCB
	jp   nz, L002E89
	ld   hl, $001B
	add  hl, de
	ld   [hl], $00
	inc  hl
	ld   [hl], b
	scf
	pop  bc
	ret
L002E89:;J
	or   a
	pop  bc
	ret
L002E8C:;C
	ld   hl, $0020
	add  hl, bc
	bit  6, [hl]
	jp   z, L002EA1
	ld   hl, $0050
	add  hl, bc
	ld   a, [hl]
	cp   $28
	jp   nz, L002EA1
	ld   [hl], $00
L002EA1:;J
	ret
L002EA2:;C
	call L002E8C
	xor  a
	ld   hl, $0005
	add  hl, de
	ld   [hl], $88
	inc  hl
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ld   [hl], a
	ld   hl, $0020
	add  hl, bc
	ld   a, [hl]
	and  a, $42
	jp   z, L002EC4
	push hl
	ld   hl, $0049
	add  hl, bc
	ld   [hl], $00
	pop  hl
L002EC4:;J
	res  1, [hl]
	res  2, [hl]
	res  3, [hl]
	res  4, [hl]
	res  5, [hl]
	res  6, [hl]
	inc  hl
	res  0, [hl]
	res  1, [hl]
	res  2, [hl]
	res  4, [hl]
	res  6, [hl]
	res  7, [hl]
	inc  hl
	res  2, [hl]
	res  3, [hl]
	res  4, [hl]
	res  5, [hl]
	res  6, [hl]
	res  7, [hl]
	inc  hl
	ld   [hl], $00
	ld   hl, $0033
	add  hl, bc
	ld   [hl], $00
	ld   hl, $0035
	add  hl, bc
	ld   [hl], $00
	ret
L002EFA:;C
	ld   hl, $0001
	add  hl, de
	bit  3, [hl]
	jp   z, L002F08
	set  5, [hl]
	jp   L002F0A
L002F08:;J
	res  5, [hl]
L002F0A:;J
	ret
L002F0B:;JC
	push bc
	push de
	push de
	pop  hl
	call L000C11
	pop  de
	pop  bc
	ret
L002F15:;C
	push bc
	push de
	push de
	pop  hl
	call L000B9E
	pop  de
	pop  bc
	ret
L002F1F:;C
	ldh  a, [hROMBank]
	push af
	call L002F38
	jp   c, L002F30
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	xor  a
	ret
L002F30:;J
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	scf
	ret
L002F38:;C
	ld   hl, $0028
	add  hl, bc
	push de
	ld   d, [hl]
	inc  hl
	ld   e, [hl]
	inc  hl
	ld   a, [hl]
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	push de
	pop  hl
	pop  de
	jp   hl
L002F4B:;C
	push bc
	push de
	call L00390D
	jp   nc, L002F5D
	cp   $00
	jp   z, L00339A
L002F58: db $FE;X
L002F59: db $01;X
L002F5A: db $CA;X
L002F5B: db $F3;X
L002F5C: db $33;X
L002F5D:;J
	ld   hl, $0043
	add  hl, bc
	ld   a, [hl]
	bit  1, a
	jp   nz, L002F6F
	bit  0, a
	jp   nz, L002F7B
	jp   L002FBC
L002F6F:;J
	ld   hl, $0001
	add  hl, de
	bit  5, [hl]
	jp   nz, L002F84
	jp   L002FBC
L002F7B:;J
	ld   hl, $0001
	add  hl, de
	bit  5, [hl]
	jp   nz, L002FBC
L002F84:;J
	ld   hl, $0033
	add  hl, bc
	ld   a, [hl]
	cp   $0A
	jp   z, L002F96
	cp   $0E
	jp   z, L002F96
	jp   L002FBC
L002F96:;J
	ld   hl, $0005
	add  hl, de
	ld   a, [hl]
	cp   $88
	jp   z, L002FBC
	ld   hl, $006D
	add  hl, bc
	bit  0, [hl]
	jp   nz, L00317F
	ld   hl, $0074
	add  hl, bc
	ld   a, [hl]
	or   a
	jp   z, L002FBC
	ld   hl, $0081
	add  hl, bc
	ld   a, [hl]
	cp   $88
	jp   nz, L00317F
L002FBC:;J
	ld   hl, $0021
	add  hl, bc
	bit  0, [hl]
	jp   nz, L003418
	ld   hl, $0035
	add  hl, bc
	ld   a, [hl]
	or   a
	jp   nz, L003386
	ld   hl, $0043
	add  hl, bc
	ld   a, [hl]
	bit  2, a
	jp   nz, L003125
	bit  3, a
	jp   nz, L003040
	bit  4, a
	jp   nz, L0031F7
	bit  5, a
	jp   nz, L0031B2
	bit  6, a
	jp   nz, L00320D
	bit  7, a
	jp   nz, L0031C8
	bit  1, a
	jp   nz, L003007
	bit  0, a
	jp   nz, L003013
	ld   hl, $0044
	add  hl, bc
	bit  6, [hl]
	jp   nz, L00334A
	jp   L0030BC
L003007:;J
	ld   hl, $0001
	add  hl, de
	bit  5, [hl]
	jp   nz, L00301C
	jp   L0030D6
L003013:;J
	ld   hl, $0001
	add  hl, de
	bit  5, [hl]
	jp   nz, L0030D6
L00301C:;J
	ld   hl, $0021
	add  hl, bc
	res  5, [hl]
	ld   hl, $3EC9
	call L002C63
	jp   c, L003333
	ld   hl, $006D
	add  hl, bc
	bit  0, [hl]
	jp   nz, L00315A
	ld   hl, $0074
	add  hl, bc
	ld   a, [hl]
	or   a
	jp   nz, L00315A
	jp   L003102
L003040:;J
	ld   hl, $0050
	add  hl, bc
	push af
	ld   a, $28
	cp   a, [hl]
	jp   z, L003055
	pop  af
	call L002D9F
	jp   c, L003197
	jp   L003056
L003055:;J
	pop  af
L003056:;J
	ld   hl, $0021
	add  hl, bc
	set  5, [hl]
	bit  4, a
	jp   nz, L003285
	bit  5, a
	jp   nz, L00323C
	bit  6, a
	jp   nz, L003299
	bit  7, a
	jp   nz, L00325E
	bit  1, a
	jp   nz, L00307D
	bit  0, a
	jp   nz, L003089
	jp   L0030A4
L00307D:;J
	ld   hl, $0001
	add  hl, de
	bit  5, [hl]
	jp   nz, L003092
	jp   L0030A4
L003089:;J
	ld   hl, $0001
	add  hl, de
	bit  5, [hl]
	jp   nz, L0030A4
L003092:;J
	ld   hl, $006D
	add  hl, bc
	bit  0, [hl]
	jp   nz, L00315A
	ld   hl, $0074
	add  hl, bc
	ld   a, [hl]
	or   a
	jp   nz, L00315A
L0030A4:;J
	ld   hl, $0033
	add  hl, bc
	ld   a, [hl]
	cp   $08
	jp   z, L003418
	ld   hl, $0021
	add  hl, bc
	res  3, [hl]
	ld   a, $08
	call L00341B
	jp   L003418
L0030BC:;J
	ld   hl, $0033
	add  hl, bc
	ld   a, [hl]
	cp   $02
	jp   z, L003418
	ld   hl, $0021
	add  hl, bc
	res  3, [hl]
	res  5, [hl]
	ld   a, $02
	call L00341B
	jp   L003418
L0030D6:;J
	ld   hl, $3EDA
	call L002C63
	jp   c, L00330F
	ld   hl, $0033
	add  hl, bc
	ld   a, [hl]
	cp   $04
	jp   z, L003418
	ld   hl, $0021
	add  hl, bc
	res  3, [hl]
	res  5, [hl]
	ld   a, $04
	call L00341B
	ld   hl, $0065
	call L002B91
	call L003569
	jp   L003418
L003102:;J
	ld   hl, $0033
	add  hl, bc
	ld   a, [hl]
	cp   $06
	jp   z, L003418
	ld   hl, $0021
	add  hl, bc
	res  3, [hl]
	res  5, [hl]
	ld   a, $06
	call L00341B
	ld   hl, $0067
	call L002B91
	call L003569
	jp   L003418
L003125:;J
	ld   hl, $0083
	add  hl, bc
	ld   [hl], $00
	ld   hl, $0033
	add  hl, bc
	ld   a, [hl]
	cp   $16
	jp   nz, L00313B
	ld   hl, $0083
	add  hl, bc
	ld   [hl], $01
L00313B:;J
	ld   hl, $0045
	add  hl, bc
	push de
	ldi  a, [hl]
	ld   d, [hl]
	inc  hl
	ldi  [hl], a
	ld   [hl], d
	pop  de
	ld   hl, $0021
	add  hl, bc
	res  3, [hl]
	res  5, [hl]
	set  0, [hl]
	set  1, [hl]
	ld   a, $0A
	call L00341B
	jp   L003418
L00315A:;J
	ld   hl, $0033
	add  hl, bc
	ld   a, [hl]
	ld   hl, $0021
	add  hl, bc
	bit  5, [hl]
	jr   nz, L003170
	cp   $10
	jp   z, L003418
	ld   a, $10
	jr   L003177
L003170:;R
	cp   $12
	jp   z, L003418
	ld   a, $12
L003177:;R
	set  3, [hl]
	call L00341B
	jp   L003418
L00317F:;J
	ld   hl, $0033
	add  hl, bc
	ld   a, [hl]
	cp   $14
	jp   z, L003418
	ld   a, $14
	ld   hl, $0021
	add  hl, bc
	set  3, [hl]
	call L003444
	jp   L003418
L003197:;J
	ld   a, $06
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0021
	add  hl, bc
	res  3, [hl]
	res  5, [hl]
	set  0, [hl]
	set  1, [hl]
	set  2, [hl]
	ld   a, $1A
	call L00341B
	jp   L003418
L0031B2:;J
	ld   hl, $0021
	add  hl, bc
	res  3, [hl]
	res  5, [hl]
	set  0, [hl]
	set  1, [hl]
	set  2, [hl]
	ld   a, $30
	call L003431
	jp   L003418
L0031C8:;J
	call L002D9F
	jp   nc, L0031DC
	call L002DB2
	jp   nc, L0032F4
	bit  0, a
	jp   nz, L0032B2
	jp   L0032D3
L0031DC:;J
	ld   a, $09
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0021
	add  hl, bc
	res  3, [hl]
	res  5, [hl]
	set  0, [hl]
	set  1, [hl]
	set  2, [hl]
	ld   a, $32
	call L003431
	jp   L003418
L0031F7:;J
	ld   hl, $0021
	add  hl, bc
	res  3, [hl]
	res  5, [hl]
	set  0, [hl]
	set  1, [hl]
	set  2, [hl]
	ld   a, $34
	call L003431
	jp   L003418
L00320D:;J
	call L002D9F
	jp   nc, L003221
	call L002DB2
	jp   nc, L0032F4
	bit  0, a
	jp   nz, L0032B2
	jp   L0032D3
L003221:;J
	ld   a, $09
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0021
	add  hl, bc
	res  3, [hl]
	res  5, [hl]
	set  0, [hl]
	set  1, [hl]
	set  2, [hl]
	ld   a, $36
	call L003431
	jp   L003418
L00323C:;J
	ld   a, [wDipSwitch]
	bit  3, a
	jp   z, L00324A
	ld   hl, $0020
	add  hl, bc
	set  5, [hl]
L00324A:;J
	ld   hl, $0021
	add  hl, bc
	res  3, [hl]
	set  0, [hl]
	set  1, [hl]
	set  2, [hl]
	ld   a, $38
	call L003431
	jp   L003418
L00325E:;J
	ld   a, $09
	call HomeCall_Sound_ReqPlayExId
	ld   a, [wDipSwitch]
	bit  3, a
	jp   z, L003271
	ld   hl, $0020
	add  hl, bc
	set  4, [hl]
L003271:;J
	ld   hl, $0021
	add  hl, bc
	res  3, [hl]
	set  0, [hl]
	set  1, [hl]
	set  2, [hl]
	ld   a, $3A
	call L003431
	jp   L003418
L003285:;J
	ld   hl, $0021
	add  hl, bc
	res  3, [hl]
	set  0, [hl]
	set  1, [hl]
	set  2, [hl]
	ld   a, $3C
	call L003431
	jp   L003418
L003299:;J
	ld   a, $09
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0021
	add  hl, bc
	res  3, [hl]
	set  0, [hl]
	set  1, [hl]
	set  2, [hl]
	ld   a, $3E
	call L003431
	jp   L003418
L0032B2:;J
	ld   hl, $0083
	add  hl, bc
	ld   [hl], $00
	ld   hl, $0021
	add  hl, bc
	res  3, [hl]
	res  5, [hl]
	set  0, [hl]
	set  1, [hl]
	set  2, [hl]
	inc  hl
	set  6, [hl]
	set  7, [hl]
	ld   a, $1E
	call L00341B
	jp   L003418
L0032D3:;J
	ld   hl, $0083
	add  hl, bc
	ld   [hl], $00
	ld   hl, $0021
	add  hl, bc
	res  3, [hl]
	res  5, [hl]
	set  0, [hl]
	set  1, [hl]
	set  2, [hl]
	inc  hl
	set  6, [hl]
	set  7, [hl]
	ld   a, $20
	call L00341B
	jp   L003418
L0032F4:;J
	ld   a, $09
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0021
	add  hl, bc
	res  3, [hl]
	res  5, [hl]
	set  0, [hl]
	set  1, [hl]
	set  2, [hl]
	ld   a, $40
	call L00341B
	jp   L003418
L00330F:;J
	call L002D53
	ld   hl, $0021
	add  hl, bc
	res  3, [hl]
	res  5, [hl]
	set  0, [hl]
	set  1, [hl]
	ld   a, $16
	call L00341B
	ld   hl, $0065
	call L002B91
	sla  l
	rl   h
	call L003569
	jp   L003418
L003333:;J
	call L002D53
	ld   hl, $0021
	add  hl, bc
	res  3, [hl]
	res  5, [hl]
	set  0, [hl]
	set  1, [hl]
	ld   a, $18
	call L00341B
	jp   L003418
L00334A:;J
	ld   hl, $002C
	add  hl, bc
	ld   a, [hl]
	srl  a
	push de
	ld   hl, $3372
	ld   d, $00
	ld   e, a
	add  hl, de
	pop  de
	ld   a, [hl]
	call HomeCall_Sound_ReqPlayExId
	ld   hl, $0021
	add  hl, bc
	res  3, [hl]
	res  5, [hl]
	set  0, [hl]
	set  1, [hl]
	ld   a, $1C
	call L00341B
	jp   L003418
L003372: db $03
L003373: db $02
L003374: db $03
L003375: db $03
L003376: db $03
L003377: db $03
L003378: db $05
L003379: db $05
L00337A: db $04
L00337B: db $02
L00337C: db $02
L00337D: db $02
L00337E: db $03
L00337F: db $05
L003380: db $05
L003381: db $02
L003382: db $02
L003383: db $02
L003384: db $04
L003385: db $04
L003386:;J
	ld   hl, $0021
	add  hl, bc
	res  3, [hl]
	res  5, [hl]
	set  0, [hl]
	set  1, [hl]
	set  2, [hl]
	call L00341B
	jp   L003418
L00339A:;J
	ld   hl, $0021
	add  hl, bc
	res  3, [hl]
	res  5, [hl]
	set  0, [hl]
	res  1, [hl]
	set  1, [hl]
	set  2, [hl]
	set  7, [hl]
	ld   a, $6C
	call L00341B
	call Task_ExecRunFar_B01
	ld   a, $03
	ld   [$C173], a
	call L00386A
L0033BC:;J
	ld   a, [$C173]
	cp   $04
	jp   z, L0033CF
	cp   $03
	jp   nz, L0033D7
	call Task_ExecRunFar_B01
	jp   L0033BC
L0033CF:;J
	ld   a, $03
	ld   [$C173], a
	jp   L003418
L0033D7:;J
	ld   a, $1C
	call HomeCall_Sound_ReqPlayExId
	ld   a, $72
	call L003451
	ld   a, $F0
	ld   [$C17C], a
	ld   hl, $0021
	add  hl, bc
	res  7, [hl]
	inc  hl
	inc  hl
	set  0, [hl]
	jp   L003418
L0033F3: db $21;X
L0033F4: db $21;X
L0033F5: db $00;X
L0033F6: db $09;X
L0033F7: db $CB;X
L0033F8: db $9E;X
L0033F9: db $CB;X
L0033FA: db $AE;X
L0033FB: db $CB;X
L0033FC: db $C6;X
L0033FD: db $CB;X
L0033FE: db $8E;X
L0033FF: db $CB;X
L003400: db $CE;X
L003401: db $CB;X
L003402: db $D6;X
L003403: db $CB;X
L003404: db $FE;X
L003405: db $3E;X
L003406: db $6E;X
L003407: db $CD;X
L003408: db $1B;X
L003409: db $34;X
L00340A: db $CD;X
L00340B: db $FB;X
L00340C: db $03;X
L00340D: db $3E;X
L00340E: db $03;X
L00340F: db $EA;X
L003410: db $73;X
L003411: db $C1;X
L003412: db $CD;X
L003413: db $6A;X
L003414: db $38;X
L003415: db $C3;X
L003416: db $18;X
L003417: db $34;X
L003418:;J
	pop  de
	pop  bc
	ret
L00341B:;C
	push bc
	push de
	call L002849
	ld   hl, $0007
	add  hl, de
	xor  a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ld   [hl], a
	push de
	pop  hl
	call L000B9E
	pop  de
	pop  bc
	ret
L003431:;C
	push bc
	push de
	call L002849
	ld   hl, $0046
	add  hl, bc
	ld   [hl], $00
	push de
	pop  hl
	call L000B9E
	pop  de
	pop  bc
	ret
L003444:;C
	push bc
	push de
	call L002849
	push de
	pop  hl
	call L000B9E
	pop  de
	pop  bc
	ret
L003451:;C
	push bc
	push de
	call L002849
	ld   hl, $0007
	add  hl, de
	xor  a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ld   [hl], a
	push de
	pop  hl
	call L000B9E
	pop  de
	pop  bc
	ld   hl, $C159
	ld   [hl], $00
	ld   hl, $003A
	add  hl, bc
	xor  a
	ldi  [hl], a
	ldi  [hl], a
	ld   [hl], a
	ld   hl, $003D
	add  hl, bc
	ldi  [hl], a
	ldi  [hl], a
	ld   [hl], a
	ret
L00347B:;C
	ld   a, [$C173]
	or   a
	ret  nz
	push bc
	ld   hl, $0064
	add  hl, bc
	ld   a, [hl]
	cp   $00
	jr   z, L0034A4
	ld   hl, $0001
	add  hl, de
	ld   b, [hl]
	ld   h, a
	ld   l, $00
	bit  3, b
	jr   z, L00349D
	ld   a, h
	cpl
	ld   h, a
	ld   a, l
	cpl
	ld   l, a
	inc  hl
L00349D:;R
	sra  h
	rr   l
	call L0034A6
L0034A4:;R
	pop  bc
	ret
L0034A6:;C
	push bc
	push de
	push hl
	pop  bc
	ld   hl, $0003
	add  hl, de
	push hl
	pop  de
	push de
	ld   a, [de]
	ld   h, a
	inc  de
	ld   a, [de]
	ld   l, a
	bit  7, b
	jp   nz, L0034C5
	add  hl, bc
	jp   nc, L0034D4
	ld   hl, rJOYP
	jp   L0034D4
L0034C5:;J
	ld   a, h
	add  hl, bc
	push af
	ld   a, b
	cpl
	inc  a
	ld   b, a
	pop  af
	sub  a, b
	jp   nc, L0034D4
	ld   hl, $0000
L0034D4:;J
	pop  de
	ld   a, h
	ld   [de], a
	inc  de
	ld   a, l
	ld   [de], a
	pop  de
	pop  bc
	ret
L0034DD:;C
	push bc
	push de
	push hl
	pop  bc
	ld   hl, $0005
	add  hl, de
	push hl
	pop  de
	push de
	ld   a, [de]
	ld   h, a
	inc  de
	ld   a, [de]
	ld   l, a
	add  hl, bc
	pop  de
	ld   a, h
	ld   [de], a
	inc  de
	ld   a, l
	ld   [de], a
	pop  de
	pop  bc
	ret
L0034F7:;C
	push bc
	push de
	push hl
	pop  bc
	ld   hl, $0001
	add  hl, de
	bit  5, [hl]
	jp   nz, L00350B
	ld   a, b
	cpl
	ld   b, a
	ld   a, c
	cpl
	ld   c, a
	inc  bc
L00350B:;J
	push bc
	pop  hl
	call L0034A6
	pop  de
	pop  bc
	ret
L003513:;C
	push bc
	push de
	push hl
	pop  bc
	ld   hl, $0001
	add  hl, de
	bit  3, [hl]
	jp   nz, L003527
	ld   a, b
	cpl
	ld   b, a
	ld   a, c
	cpl
	ld   c, a
	inc  bc
L003527:;J
	push bc
	pop  hl
	call L0034A6
	pop  de
	pop  bc
	ret
L00352F:;C
	push bc
	push de
	push hl
	pop  de
	ld   hl, $007F
	add  hl, bc
	bit  5, [hl]
	jp   z, L003543
	ld   a, d
	cpl
	ld   d, a
	ld   a, e
	cpl
	ld   e, a
	inc  de
L003543:;J
	push de
	pop  hl
	pop  de
	push de
	call L0034A6
	pop  de
	pop  bc
	ret
L00354D:;C
	push bc
	push de
	push hl
	pop  bc
	ld   hl, $0001
	add  hl, de
	bit  2, [hl]
	jp   nz, L003561
	ld   a, b
	cpl
	ld   b, a
	ld   a, c
	cpl
	ld   c, a
	inc  bc
L003561:;J
	push bc
	pop  hl
	call L0034A6
	pop  de
	pop  bc
	ret
L003569:;C
	push bc
	push hl
	pop  bc
	ld   hl, $0001
	add  hl, de
	bit  5, [hl]
	jp   nz, L00357C
	ld   a, b
	cpl
	ld   b, a
	ld   a, c
	cpl
	ld   c, a
	inc  bc
L00357C:;J
	ld   hl, $0007
	add  hl, de
	ld   [hl], b
	inc  hl
	ld   [hl], c
	pop  bc
	ret
L003585:;C
	push bc
	push hl
	pop  bc
	ld   hl, $0001
	add  hl, de
	bit  3, [hl]
	jp   z, L003598
	ld   a, b
	cpl
	ld   b, a
	ld   a, c
	cpl
	ld   c, a
	inc  bc
L003598:;J
	ld   hl, $0007
	add  hl, de
	ld   [hl], b
	inc  hl
	ld   [hl], c
	pop  bc
	ret
L0035A1:;C
	push bc
	push hl
	pop  bc
	ld   hl, $0007
	add  hl, de
	ld   [hl], b
	inc  hl
	ld   [hl], c
	pop  bc
	ret
L0035AD:;C
	push bc
	push hl
	pop  bc
	ld   hl, $0009
	add  hl, de
	ld   [hl], b
	inc  hl
	ld   [hl], c
	pop  bc
	ret
L0035B9:;C
	push bc
	push de
	ld   hl, $0003
	add  hl, de
	push hl
	pop  de
	push de
	ld   a, [de]
	ld   h, a
	inc  de
	ld   a, [de]
	ld   l, a
	inc  de
	inc  de
	inc  de
	ld   a, [de]
	ld   b, a
	inc  de
	ld   a, [de]
	ld   c, a
	add  hl, bc
	pop  de
	ld   a, h
	ld   [de], a
	inc  de
	ld   a, l
	ld   [de], a
	pop  de
	pop  bc
	ret
L0035D9:;C
	push bc
	push de
	push hl
	pop  bc
	ld   hl, $0007
	add  hl, de
	ld   a, [hl]
	or   a
	jp   z, L003602
	bit  7, a
	jp   nz, L0035F2
	ld   a, b
	cpl
	ld   b, a
	ld   a, c
	cpl
	ld   c, a
	inc  bc
L0035F2:;J
	push hl
	ld   d, [hl]
	inc  hl
	ld   e, [hl]
	push de
	pop  hl
	add  hl, bc
	push hl
	pop  de
	pop  hl
	ld   [hl], d
	inc  hl
	ld   [hl], e
	jp   L00360D
L003602:;J
	pop  de
	pop  bc
	ld   hl, $0007
	add  hl, de
	xor  a
	ldi  [hl], a
	ld   [hl], a
	scf
	ret
L00360D:;J
	pop  de
	pop  bc
	call L0035B9
	or   a
	ret
L003614:;C
	push bc
	push hl
	pop  bc
	push de
	ld   hl, $0009
	add  hl, de
	push hl
	pop  de
	push de
	ld   a, [de]
	ld   h, a
	inc  de
	ld   a, [de]
	ld   l, a
	add  hl, bc
	pop  de
	push de
	ld   a, h
	ld   [de], a
	inc  de
	ld   a, l
	ld   [de], a
	pop  de
	push hl
	dec  de
	dec  de
	dec  de
	dec  de
	push de
	ld   a, [de]
	ld   b, a
	inc  de
	ld   a, [de]
	ld   c, a
	add  hl, bc
	pop  de
	ld   a, h
	ld   [de], a
	inc  de
	ld   a, l
	ld   [de], a
	pop  hl
	bit  7, h
	jp   z, L003653
	dec  de
	ld   a, [de]
	cp   $88
	jp   c, L00366B
	xor  a
	ld   [de], a
	inc  de
	ld   [de], a
	jp   L00366B
L003653:;J
	dec  de
	ld   a, [de]
	cp   $88
	jp   c, L00366B
	pop  de
	pop  bc
	ld   hl, $0005
	add  hl, de
	ld   [hl], $88
	inc  hl
	xor  a
	ldi  [hl], a
	inc  hl
	inc  hl
	ldi  [hl], a
	ldi  [hl], a
	scf
	ret
L00366B:;J
	pop  de
	pop  bc
	call L0035B9
	xor  a
	ret
L003672:;C
	push bc
	push hl
	pop  bc
	push de
	ld   hl, $0009
	add  hl, de
	push hl
	pop  de
	push de
	ld   a, [de]
	ld   h, a
	inc  de
	ld   a, [de]
	ld   l, a
	add  hl, bc
	pop  de
	push de
	ld   a, h
	ld   [de], a
	inc  de
	ld   a, l
	ld   [de], a
	pop  de
	push hl
	dec  de
	dec  de
	dec  de
	dec  de
	push de
	ld   a, [de]
	ld   b, a
	inc  de
	ld   a, [de]
	ld   c, a
	add  hl, bc
	pop  de
	ld   a, h
	ld   [de], a
	inc  de
	ld   a, l
	ld   [de], a
	pop  hl
	bit  7, h
	jp   z, L0036B1
	dec  de
	ld   a, [de]
	cp   $88
	jp   c, L0036C7
	xor  a
	ld   [de], a
	inc  de
	ld   [de], a
	jp   L0036C7
L0036B1:;J
	dec  de
	ld   a, [de]
	cp   $88
	jp   c, L0036C7
	pop  de
	pop  bc
	ld   hl, $0005
	add  hl, de
	ld   [hl], $88
	inc  hl
	xor  a
	ldi  [hl], a
	inc  hl
	inc  hl
	scf
	ret
L0036C7:;J
	pop  de
	pop  bc
	xor  a
	ret
L0036CB:;C
	ld   hl, $0060
	add  hl, bc
	ld   a, [hl]
	or   a
	jp   nz, L003723
	ld   hl, $0020
	add  hl, bc
	bit  1, [hl]
	jp   nz, L003723
	ld   hl, $0021
	add  hl, bc
	bit  3, [hl]
	jp   nz, L0036F1
	bit  4, [hl]
	jp   nz, L003723
	call L003CAC
	jp   nz, L003723
L0036F1:;J
	ld   hl, $0033
	add  hl, bc
	ld   a, [hl]
	cp   $6C
	jp   z, L003723
	cp   $6E
	jp   z, L003723
	ld   hl, $0021
	add  hl, bc
	bit  6, [hl]
	jp   nz, L00370E
	bit  2, [hl]
	jp   nz, L003723
L00370E:;J
	xor  a
	ld   hl, $0005
	add  hl, de
	ld   a, [hl]
	cp   $88
	jp   z, L00371E
	ld   a, $01
	jp   L00371F
L00371E:;J
	xor  a
L00371F:;J
	or   a
	scf
	ccf
	ret
L003723:;J
	scf
	ret
L003725:;C
	ld   a, [wDipSwitch]
	bit  3, a
	jp   nz, L003741
	ld   hl, $0050
	add  hl, bc
	ld   a, [hl]
	cp   $28
	jp   z, L003741
	ld   hl, $004E
	add  hl, bc
	ld   a, [hl]
	cp   $18
	jp   nc, L003743
L003741:;J
	xor  a
	ret
L003743:;J
	scf
	ret
L003745:;C
	ld   hl, $0063
	add  hl, bc
	bit  1, [hl]
	jp   z, L003760
	ld   hl, $006E
	add  hl, bc
	bit  7, [hl]
	jp   nz, L003760
	bit  4, [hl]
	jp   z, L003760
	bit  3, [hl]
	scf
	ret
L003760:;J
	scf
	ccf
	ret
L003763:;C
	ld   hl, $0020
	add  hl, bc
	bit  0, [hl]
	ret
L00376A:;C
	ld   a, [wDipSwitch]
	bit  3, a
	jp   z, L00377C
	ld   hl, $0050
	add  hl, bc
	ld   a, [hl]
	cp   $28
	jp   z, L003785
L00377C:;J
	ld   hl, $0022
	add  hl, bc
	bit  1, [hl]
	scf
	ccf
	ret
L003785:;J
	ld   hl, $0022
	add  hl, bc
	bit  1, [hl]
	jp   z, L00377C
	scf
	ret
L003790:;C
	ld   a, [wDipSwitch]
	bit  3, a
	jp   z, L0037AF
	ld   hl, $0050
	add  hl, bc
	ld   a, [hl]
	cp   $28
	jp   nz, L0037C6
	ld   hl, $004E
	add  hl, bc
	ld   a, [hl]
	cp   $18
	jp   nc, L0037C8
	jp   L0037CD
L0037AF:;J
	ld   hl, $0050
	add  hl, bc
	ld   a, [hl]
	cp   $28
	jp   nz, L0037C6
	ld   hl, $004E
	add  hl, bc
	ld   a, [hl]
	cp   $18
	jp   nc, L0037C6
L0037C3: db $C3;X
L0037C4: db $C8;X
L0037C5: db $37;X
L0037C6:;J
	xor  a
	ret
L0037C8:;J
	ld   a, $01
	or   a
	scf
	ret
L0037CD:;J
	xor  a
	scf
	ret
L0037D0:;C
	call L002EFA
	ld   hl, $0020
	add  hl, bc
	cp   $64
	jp   c, L0037E8
	set  6, [hl]
	push af
	push hl
	ld   hl, $0000
	call L00381A
	pop  hl
	pop  af
L0037E8:;J
	set  1, [hl]
	inc  hl
	set  0, [hl]
	set  1, [hl]
	set  2, [hl]
	res  3, [hl]
	res  5, [hl]
	res  7, [hl]
	inc  hl
	res  6, [hl]
	res  7, [hl]
	push hl
	call L00341B
	pop  hl
	dec  hl
	bit  6, [hl]
	jp   z, L003819
	inc  hl
	set  2, [hl]
	ld   hl, $001B
	add  hl, de
	ld   a, [hl]
	bit  7, a
	jp   nz, L003819
	ld   [hl], $00
	inc  hl
	ld   [hl], $00
L003819:;J
	ret
L00381A:;C
	ld   a, $91
	call HomeCall_Sound_ReqPlayExId
	push bc
	push de
	push hl
	push de
	pop  bc
	ld   hl, $0100
	add  hl, bc
	push hl
	pop  de
	ld   [hl], $80
	ld   hl, $0020
	add  hl, de
	ld   [hl], $02
	inc  hl
	ld   [hl], $D7
	inc  hl
	ld   [hl], $45
	ld   hl, $0010
	add  hl, de
	ld   [hl], $01
	inc  hl
	ld   [hl], $6F
	inc  hl
	ld   [hl], $58
	inc  hl
	ld   [hl], $00
	ld   hl, $001B
	add  hl, de
	ld   [hl], $00
	inc  hl
	ld   [hl], $00
	ld   hl, $0028
	add  hl, de
	ld   [hl], $14
	call L00251B
	pop  hl
	push hl
	ld   l, $00
	call L0034F7
	pop  hl
	ld   h, L
	ld   l, $00
	call L0034DD
	pop  de
	pop  bc
	ret
L00386A:;C
	ld   a, $FF
	ld   [$C17C], a
	ld   a, $1B
	call HomeCall_Sound_ReqPlayExId
	ret
L003875:;C
	ld   a, h
	ld   [$C176], a
	ld   a, l
	ld   [$C177], a
	xor  a
	ld   [$C178], a
	ret
L003882:;C
	push de
	push hl
	pop  de
	ld   hl, $003A
	add  hl, bc
	ld   [hl], d
	inc  hl
	ld   [hl], e
	inc  hl
	ld   [hl], a
	pop  de
	ret
L003890:;C
	push de
	push hl
	pop  de
	ld   hl, $003D
	add  hl, bc
	ld   [hl], d
	inc  hl
	ld   [hl], e
	inc  hl
	ld   [hl], a
	pop  de
	ret
L00389E:;C
	push bc
	ld   hl, $003D
	add  hl, bc
	push hl
	pop  bc
	ld   hl, $00A3
	add  hl, de
	ld   a, [bc]
	inc  bc
	ldi  [hl], a
	ld   a, [bc]
	inc  bc
	ldi  [hl], a
	ld   a, [bc]
	ld   [hl], a
	pop  bc
	ret
L0038B3:;C
	push de
	push bc
	ld   hl, $0010
	add  hl, de
	ld   b, [hl]
	inc  hl
	ld   c, [hl]
	inc  hl
	ld   d, [hl]
	inc  hl
	inc  hl
	ldi  a, [hl]
	cp   a, b
	jr   nz, L003909
	ldi  a, [hl]
	cp   a, c
	jr   nz, L003909
	ldi  a, [hl]
	cp   a, d
	jr   nz, L003909
	pop  bc
	pop  de
	ld   hl, $0022
	add  hl, bc
	bit  0, [hl]
	jr   z, L003907
	ld   hl, $0000
	add  hl, de
	bit  0, [hl]
	jp   nz, L00390B
	ld   hl, $0022
	add  hl, bc
	res  0, [hl]
	ld   hl, $003D
	add  hl, bc
	ld   a, [hl]
	or   a
	jp   z, L003907
	push de
	push hl
	ld   hl, $003A
	add  hl, bc
	push hl
	pop  de
	pop  hl
	ld   [de], a
	ld   [hl], $00
	inc  de
	inc  hl
	ld   a, [hl]
	ld   [de], a
	ld   [hl], $00
	inc  de
	inc  hl
	ld   a, [hl]
	ld   [de], a
	ld   [hl], $00
	pop  de
L003907:;JR
	or   a
	ret
L003909:;R
	pop  bc
	pop  de
L00390B:;J
	scf
	ret
L00390D:;C
	ld   a, [$C173]
	cp   $00
	jp   nz, L003A26
	ld   hl, $007A
	add  hl, bc
	ld   a, [hl]
	or   a
	jp   nz, L003A26
	call L002D9F
	jp   c, L003A26
	call L002DB2
	jp   nc, L003A26
	push de
	ld   d, $C0
	ld   hl, $0045
	add  hl, bc
	ld   a, [hl]
	and  a, $03
	jp   z, L00395C
	ld   e, a
	inc  hl
	ld   a, [hl]
	and  a, d
	jp   z, L00395C
	pop  de
	bit  6, a
	jp   nz, L00394B
	xor  a
	ld   [$C175], a
	jp   L003950
L00394B:;J
	ld   a, $01
	ld   [$C175], a
L003950:;J
	ld   hl, $0020
	add  hl, bc
	bit  2, [hl]
	jp   nz, L003974
	jp   L003960
L00395C:;J
	pop  de
	jp   L003A26
L003960:;J
	inc  hl
	bit  0, [hl]
	jp   nz, L003A22
	bit  5, [hl]
	jp   nz, L003A22
	xor  a
	ld   [$C174], a
	ld   a, $04
	jp   L0039AE
L003974:;J
	ld   hl, $0033
	add  hl, bc
	ld   a, [hl]
	cp   $0A
	jp   z, L00398B
	cp   $0C
	jp   z, L00398B
	cp   $0E
	jp   z, L00398B
	jp   L003A22
L00398B:;J
	ld   hl, $002C
	add  hl, bc
	ld   a, [hl]
	cp   $0C
	jp   z, L0039A7
	cp   $0E
	jp   z, L0039A7
	cp   $10
	jp   z, L0039A7
	cp   $24
	jp   z, L0039A7
	jp   L003A22
L0039A7:;J
	ld   a, $01
	ld   [$C174], a
	ld   a, $04
L0039AE:;J
	ld   hl, $001A
	add  hl, de
	ld   [hl], a
	ld   a, $01
	ld   [$C173], a
	ld   hl, $003A
	add  hl, bc
	ld   a, $0C
	ld   [hl], a
	inc  hl
	ld   a, $10
	ld   [hl], a
	ld   hl, $0045
	add  hl, bc
	ldi  a, [hl]
	push af
	ld   a, [hl]
	push af
	push hl
	call Task_ExecRunFar_B01
	ld   hl, $001A
	add  hl, de
	xor  a
	ld   [hl], a
	call Task_ExecRunFar_B01
	pop  hl
	pop  af
	ldd  [hl], a
	pop  af
	ld   [hl], a
	ld   a, [$C173]
	cp   $02
	jp   nz, L003A22
	ld   a, [$C174]
	or   a
	jp   nz, L0039F4
	ld   hl, $002C
	add  hl, bc
	ld   a, [hl]
	jp   L0039FC
L0039F4: db $FA;X
L0039F5: db $75;X
L0039F6: db $C1;X
L0039F7: db $EE;X
L0039F8: db $01;X
L0039F9: db $EA;X
L0039FA: db $75;X
L0039FB: db $C1;X
L0039FC:;J
	ld   a, [$C175]
	or   a
	jp   z, L003A1B
	push bc
	ld   a, [$D6C3]
	ld   b, a
	ld   a, [$D683]
	ld   [$D6C3], a
	ld   a, b
	ld   [$D683], a
	pop  bc
	ld   hl, $0001
	add  hl, de
	ld   a, [hl]
	xor  $20
	ld   [hl], a
L003A1B:;J
	ld   a, [$C174]
	scf
	jp   L003A27
L003A22:;J
	xor  a
	ld   [$C173], a
L003A26:;J
	xor  a
L003A27:;J
	ret
L003A28:;C
	ld   a, [$C173]
	cp   $00
	jp   nz, L003A94
	xor  a
	ld   [$C175], a
	ld   a, $02
	ld   [$C174], a
	ld   a, $05
	jp   L003A59
L003A3E:;C
	ld   a, [$C173]
	cp   $00
	jp   nz, L003A94
	ld   hl, $007A
	add  hl, bc
	ld   a, [hl]
	or   a
	jp   nz, L003A94
	xor  a
	ld   [$C175], a
	xor  a
	ld   [$C174], a
	ld   a, $04
L003A59:;J
	ld   hl, $001A
	add  hl, de
	ld   [hl], a
	ld   a, $01
	ld   [$C173], a
	ld   hl, $003A
	add  hl, bc
	ld   a, $0C
	ld   [hl], a
	inc  hl
	ld   a, $10
	ld   [hl], a
	ld   hl, $0045
	add  hl, bc
	ldi  a, [hl]
	push af
	ld   a, [hl]
	push af
	push hl
	call Task_ExecRunFar_B01
	ld   hl, $001A
	add  hl, de
	xor  a
	ld   [hl], a
	call Task_ExecRunFar_B01
	pop  hl
	pop  af
	ldd  [hl], a
	pop  af
	ld   [hl], a
	ld   a, [$C173]
	cp   $02
	jp   nz, L003A94
	scf
	jp   L003A98
L003A94:;J
	xor  a
	ld   [$C173], a
L003A98:;J
	ret
L003A99:;C
	ld   hl, $007E
	add  hl, bc
	xor  a
	ld   [hl], a
	ld   hl, $007D
	add  hl, bc
	ld   a, [hl]
	or   a
	jp   z, L003AAE
	ld   h, a
	ld   l, $00
	call L0034A6
L003AAE:;J
	ld   a, [$C172]
	or   a
	jp   z, L003AD1
L003AB5:;J
	call L002D8C
	call L002D75
	call L002F1F
	jp   c, L003AD3
	call L003CE7
	jp   c, L003AD3
	call Task_ExecRunFar_B01
	ld   a, [$C172]
	or   a
	jp   nz, L003AB5
L003AD1:;J
	xor  a
	ret
L003AD3:;J
	ret
L003AD4:;C
	ld   hl, $0020
	add  hl, bc
	bit  3, [hl]
	jp   nz, L003AE7
	ld   hl, $001F
	add  hl, de
	ld   a, [hl]
	ld   hl, $007E
	add  hl, bc
	ld   [hl], a
L003AE7:;J
	ret
L003AE8:;JC
	ld   hl, $0020
	add  hl, bc
	bit  3, [hl]
	jp   nz, L003AFB
	ld   a, $01
	ld   [$C171], a
	ld   hl, $007C
	add  hl, bc
	ld   [hl], a
L003AFB:;J
	ld   hl, $0021
	add  hl, bc
	ld   a, [hl]
	push af
	set  7, [hl]
	call L003B42
	call L003B15
	pop  af
	ld   hl, $0021
	add  hl, bc
	ld   [hl], a
	ld   a, $00
	ld   [$C171], a
	ret
L003B15:;C
	push bc
	ld   b, a
	ld   hl, $0001
	add  hl, de
	ld   c, [hl]
	ld   hl, $0003
	add  hl, de
	bit  5, c
	jp   z, L003B34
L003B25:;J
	dec  [hl]
	call Task_ExecRunFar_B01
	inc  [hl]
	call Task_ExecRunFar_B01
	dec  b
	jp   nz, L003B25
	jp   L003B40
L003B34:;J
	inc  [hl]
	call Task_ExecRunFar_B01
	dec  [hl]
	call Task_ExecRunFar_B01
	dec  b
	jp   nz, L003B34
L003B40:;J
	pop  bc
	ret
L003B42:;C
	ld   hl, $0020
	add  hl, bc
	bit  3, [hl]
	jp   nz, L003B50
	ld   a, $0A
	jp   L003B52
L003B50:;J
	ld   a, $08
L003B52:;J
	ld   hl, $0023
	add  hl, bc
	bit  7, [hl]
	jp   nz, L003B65
	bit  0, [hl]
	jp   nz, L003B67
	srl  a
	jp   L003B67
L003B65:;J
	ld   a, $01
L003B67:;J
	ld   hl, $004E
	add  hl, bc
	push af
	ld   a, [hl]
	or   a
	jp   nz, L003B7E
	pop  af
	sla  a
	cp   $0B
	jp   c, L003B7F
	ld   a, $0B
	jp   L003B7F
L003B7E:;J
	pop  af
L003B7F:;J
	ret
L003B80:;C
	ld   a, $01
	ld   [$C171], a
	ld   hl, $007C
	add  hl, bc
	ld   [hl], a
	ld   hl, $0021
	add  hl, bc
	ld   a, [hl]
	push af
	set  7, [hl]
	ld   a, $01
	call L003B15
	pop  af
	ld   hl, $0021
	add  hl, bc
	ld   [hl], a
	ld   a, $00
	ld   [$C171], a
	ret
L003BA3:;C
	ld   hl, $0050
	add  hl, bc
	ld   a, [hl]
	cp   $28
	jp   nz, L003AE8
	ld   hl, $0020
	add  hl, bc
	bit  3, [hl]
	jp   nz, L003BC0
	ld   a, $01
	ld   [$C171], a
	ld   hl, $007C
	add  hl, bc
	ld   [hl], a
L003BC0:;J
	ld   hl, $0021
	add  hl, bc
	ld   a, [hl]
	push af
	set  7, [hl]
	call L003B42
	ld   hl, $0003
	add  hl, de
L003BCF:;J
	push af
	inc  [hl]
	inc  [hl]
	call Task_ExecRunFar_B01
	push hl
	call L002D75
	call L003C18
	jp   c, L003C0E
	call L002F1F
	jp   c, L003C0E
	pop  hl
	dec  [hl]
	dec  [hl]
	call Task_ExecRunFar_B01
	push hl
	call L002D75
	call L003C18
	jp   c, L003C0E
	call L002F1F
	jp   c, L003C0E
	pop  hl
	pop  af
	dec  a
	jp   nz, L003BCF
	pop  af
	ld   hl, $0021
	add  hl, bc
	ld   [hl], a
	ld   a, $00
	ld   [$C171], a
	xor  a
	ret
L003C0E:;J
	pop  hl
	pop  af
	pop  af
	ld   a, $00
	ld   [$C171], a
	scf
	ret
L003C18:;C
	ld   hl, $0005
	add  hl, de
	ldi  a, [hl]
	cp   $88
	jp   nz, L003C6B
	ld   a, [hl]
	or   a
	jp   nz, L003C6B
	call L002D9F
	jp   nc, L003C6B
	ld   hl, $0083
	add  hl, bc
	ld   [hl], $01
	ld   hl, $0020
	add  hl, bc
	set  6, [hl]
	inc  hl
	res  3, [hl]
	res  5, [hl]
	set  0, [hl]
	set  1, [hl]
	set  2, [hl]
	inc  hl
	set  6, [hl]
	set  7, [hl]
	inc  hl
	res  1, [hl]
	res  6, [hl]
	call L002DB2
	jp   nc, L003C61
	bit  3, a
	jp   nz, L003C5C
	jp   L003C61
L003C5C: db $3E;X
L003C5D: db $20;X
L003C5E: db $C3;X
L003C5F: db $66;X
L003C60: db $3C;X
L003C61:;J
	ld   a, $1E
	jp   L003C66
L003C66:;J
	call L00341B
	scf
	ret
L003C6B:;J
	xor  a
	ret
L003C6D:;C
	call L002DCB
	jp   nz, L003C7D
	ld   hl, $001B
	add  hl, de
	ld   a, [hl]
	and  a, $0F
	jp   nz, L003C8B
L003C7D:;J
	ld   hl, $C159
	ld   [hl], $00
	ld   hl, $0005
	add  hl, de
	ld   [hl], $88
	jp   L003CAB
L003C8B:;J
	ld   hl, $C159
	bit  1, a
	jp   nz, L003CA0
	ld   [hl], $00
	ld   hl, $0005
	add  hl, de
	cpl
	inc  a
	add  a, [hl]
	ld   [hl], a
	jp   L003CAB
L003CA0:;J
	push af
	cpl
	inc  a
	ld   [hl], a
	pop  af
	ld   hl, $0005
	add  hl, de
	ld   [hl], $88
L003CAB:;J
	ret
L003CAC:;C
	ld   hl, $0058
	add  hl, bc
	ld   a, [hl]
	or   a
	ret
L003CB3:;C
	call L002E8C
	ld   hl, $004E
	add  hl, bc
	ld   a, [hl]
	or   a
	jp   nz, L003CC8
	ld   hl, $0033
	add  hl, bc
	ld   [hl], $00
	jp   L003CE6
L003CC8:;J
	ld   hl, $005E
	add  hl, bc
	ld   [hl], $1E
	ld   hl, $0020
	add  hl, bc
	res  2, [hl]
	res  3, [hl]
	res  4, [hl]
	res  5, [hl]
	inc  hl
	res  4, [hl]
	res  6, [hl]
	set  7, [hl]
	ld   a, $22
	call L00341B
L003CE6:;J
	ret
L003CE7:;C
	ldh  a, [hROMBank]
	push af
	ld   a, $02
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	call $45F3
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret
L003CFB:;C
	ld   hl, $0043
	add  hl, bc
	ld   a, [hl]
	ld   hl, $0022
	add  hl, bc
	bit  4, a
	jr   nz, L003D17
	bit  5, a
	jr   nz, L003D22
	bit  6, a
	jr   nz, L003D1C
	bit  7, a
	jr   nz, L003D27
	scf
	ccf
	ret
L003D17:;R
	res  1, [hl]
	jp   L003D1E
L003D1C:;R
	set  1, [hl]
L003D1E:;J
	xor  a
	inc  a
	scf
	ret
L003D22:;R
	res  1, [hl]
	jp   L003D29
L003D27:;R
	set  1, [hl]
L003D29:;J
	xor  a
	scf
	ret
L003D2C:;C
	ld   hl, $0049
	add  hl, bc
	ld   [hl], $00
	ret
L003D33:;C
	ld   hl, $0049
	add  hl, bc
	ld   a, [hl]
	bit  4, a
	jr   nz, L003D4B
	bit  5, a
	jr   nz, L003D4F
	bit  6, a
	jr   nz, L003D4B
	bit  7, a
	jr   nz, L003D4F
	scf
	ccf
	ret
L003D4B:;R
	xor  a
	inc  a
	scf
	ret
L003D4F:;R
	xor  a
	scf
	ret
L003D52:;C
	ld   a, [wDipSwitch]
	bit  2, a
	jp   z, L003D6E
	ld   hl, $0045
	add  hl, bc
	ld   a, [hl]
	and  a, $60
	cp   $60
	jp   z, L003D71
	ld   a, [hl]
	and  a, $50
	cp   $50
	jp   z, L003D75
L003D6E:;J
	xor  a
	inc  a
	ret
L003D71:;J
	xor  a
	inc  a
	scf
	ret
L003D75:;J
	xor  a
	ret
L003D77:;C
	ld   hl, $002B
	add  hl, bc
	ld   a, [hl]
	or   a
	jp   nz, L003D86
	ld   hl, $D6DB
	jp   L003D89
L003D86:;J
	ld   hl, $D69B
L003D89:;J
	ld   [hl], $FF
	ret
L003D8C: db $02
L003D8D: db $02
L003D8E: db $02
L003D8F: db $01
L003D90: db $14
L003D91: db $08
L003D92: db $08
L003D93: db $01
L003D94: db $FF
L003D95: db $02
L003D96: db $01
L003D97: db $01
L003D98: db $01
L003D99: db $14
L003D9A: db $08
L003D9B: db $08
L003D9C: db $01
L003D9D: db $FF
L003D9E: db $02
L003D9F: db $01
L003DA0: db $01
L003DA1: db $01
L003DA2: db $14
L003DA3: db $08
L003DA4: db $08
L003DA5: db $01
L003DA6: db $FF
L003DA7: db $02
L003DA8: db $04
L003DA9: db $04
L003DAA: db $01
L003DAB: db $14
L003DAC: db $08
L003DAD: db $08
L003DAE: db $02
L003DAF: db $FF
L003DB0: db $04
L003DB1: db $02
L003DB2: db $02
L003DB3: db $01
L003DB4: db $14
L003DB5: db $08
L003DB6: db $08
L003DB7: db $01
L003DB8: db $0A
L003DB9: db $01
L003DBA: db $01
L003DBB: db $01
L003DBC: db $0A
L003DBD: db $08
L003DBE: db $08
L003DBF: db $01
L003DC0: db $FF
L003DC1: db $04
L003DC2: db $01
L003DC3: db $01
L003DC4: db $01
L003DC5: db $14
L003DC6: db $08
L003DC7: db $08
L003DC8: db $01
L003DC9: db $0A
L003DCA: db $01
L003DCB: db $01
L003DCC: db $01
L003DCD: db $0A
L003DCE: db $08
L003DCF: db $08
L003DD0: db $01
L003DD1: db $FF
L003DD2: db $04
L003DD3: db $02
L003DD4: db $02
L003DD5: db $01
L003DD6: db $14
L003DD7: db $08
L003DD8: db $08
L003DD9: db $01
L003DDA: db $0A
L003DDB: db $02
L003DDC: db $02
L003DDD: db $01
L003DDE: db $0A
L003DDF: db $08
L003DE0: db $08
L003DE1: db $01
L003DE2: db $FF
L003DE3: db $04
L003DE4: db $01
L003DE5: db $01
L003DE6: db $01
L003DE7: db $14
L003DE8: db $08
L003DE9: db $08
L003DEA: db $01
L003DEB: db $0A
L003DEC: db $02
L003DED: db $02
L003DEE: db $01
L003DEF: db $0A
L003DF0: db $08
L003DF1: db $08
L003DF2: db $01
L003DF3: db $FF
L003DF4: db $05
L003DF5: db $08
L003DF6: db $08
L003DF7: db $01
L003DF8: db $14
L003DF9: db $01
L003DFA: db $01
L003DFB: db $01;X
L003DFC: db $0A;X
L003DFD: db $04;X
L003DFE: db $04;X
L003DFF: db $01;X
L003E00: db $0A;X
L003E01: db $02;X
L003E02: db $02;X
L003E03: db $01;X
L003E04: db $0A;X
L003E05: db $08;X
L003E06: db $08;X
L003E07: db $01;X
L003E08: db $FF;X
L003E09: db $03
L003E0A: db $01
L003E0B: db $01
L003E0C: db $01
L003E0D: db $14
L003E0E: db $08
L003E0F: db $08
L003E10: db $01
L003E11: db $0A
L003E12: db $02
L003E13: db $02
L003E14: db $01
L003E15: db $FF
L003E16: db $04
L003E17: db $02
L003E18: db $02
L003E19: db $01
L003E1A: db $14
L003E1B: db $08
L003E1C: db $08
L003E1D: db $01
L003E1E: db $0A
L003E1F: db $01
L003E20: db $01
L003E21: db $01
L003E22: db $0A
L003E23: db $02
L003E24: db $02
L003E25: db $01
L003E26: db $FF
L003E27: db $03
L003E28: db $02
L003E29: db $02
L003E2A: db $01
L003E2B: db $14
L003E2C: db $08
L003E2D: db $08
L003E2E: db $01
L003E2F: db $0A
L003E30: db $02
L003E31: db $02
L003E32: db $01
L003E33: db $FF
L003E34: db $04
L003E35: db $02
L003E36: db $02
L003E37: db $01
L003E38: db $14
L003E39: db $01
L003E3A: db $01
L003E3B: db $01
L003E3C: db $0A
L003E3D: db $08
L003E3E: db $08
L003E3F: db $01
L003E40: db $0A
L003E41: db $02
L003E42: db $02
L003E43: db $01
L003E44: db $FF
L003E45: db $06
L003E46: db $01
L003E47: db $01
L003E48: db $01
L003E49: db $0A
L003E4A: db $08
L003E4B: db $08
L003E4C: db $01
L003E4D: db $0A
L003E4E: db $02
L003E4F: db $02
L003E50: db $01
L003E51: db $0A
L003E52: db $01
L003E53: db $01
L003E54: db $01
L003E55: db $0A
L003E56: db $08
L003E57: db $08
L003E58: db $01
L003E59: db $0A
L003E5A: db $02
L003E5B: db $02
L003E5C: db $01
L003E5D: db $FF
L003E5E: db $02
L003E5F: db $02
L003E60: db $02
L003E61: db $01
L003E62: db $14
L003E63: db $01
L003E64: db $01
L003E65: db $02
L003E66: db $FF
L003E67: db $02
L003E68: db $02
L003E69: db $02
L003E6A: db $01
L003E6B: db $14
L003E6C: db $01
L003E6D: db $01
L003E6E: db $01
L003E6F: db $FF
L003E70: db $03
L003E71: db $02
L003E72: db $02
L003E73: db $01
L003E74: db $14
L003E75: db $08
L003E76: db $08
L003E77: db $01
L003E78: db $0A
L003E79: db $01
L003E7A: db $01
L003E7B: db $01
L003E7C: db $FF
L003E7D: db $04
L003E7E: db $01
L003E7F: db $01
L003E80: db $01
L003E81: db $14
L003E82: db $08
L003E83: db $08
L003E84: db $01
L003E85: db $0A
L003E86: db $02
L003E87: db $02
L003E88: db $01
L003E89: db $0A
L003E8A: db $01
L003E8B: db $01
L003E8C: db $01
L003E8D: db $FF
L003E8E: db $03
L003E8F: db $01
L003E90: db $01
L003E91: db $01
L003E92: db $14
L003E93: db $08
L003E94: db $08
L003E95: db $01
L003E96: db $0A
L003E97: db $01
L003E98: db $01
L003E99: db $01
L003E9A: db $FF
L003E9B: db $05
L003E9C: db $02
L003E9D: db $02
L003E9E: db $01
L003E9F: db $14
L003EA0: db $01
L003EA1: db $01
L003EA2: db $01
L003EA3: db $0A
L003EA4: db $08
L003EA5: db $08
L003EA6: db $01
L003EA7: db $0A
L003EA8: db $02
L003EA9: db $02
L003EAA: db $01
L003EAB: db $0A
L003EAC: db $01
L003EAD: db $01
L003EAE: db $01
L003EAF: db $FF
L003EB0: db $06
L003EB1: db $20
L003EB2: db $20
L003EB3: db $01
L003EB4: db $08
L003EB5: db $00
L003EB6: db $20
L003EB7: db $01
L003EB8: db $08
L003EB9: db $20
L003EBA: db $20
L003EBB: db $01
L003EBC: db $08
L003EBD: db $00
L003EBE: db $20
L003EBF: db $01
L003EC0: db $08
L003EC1: db $20
L003EC2: db $20
L003EC3: db $01
L003EC4: db $08
L003EC5: db $00
L003EC6: db $20
L003EC7: db $01
L003EC8: db $08
L003EC9: db $04
L003ECA: db $01
L003ECB: db $0F
L003ECC: db $01
L003ECD: db $08
L003ECE: db $00
L003ECF: db $0F
L003ED0: db $01
L003ED1: db $08
L003ED2: db $01
L003ED3: db $0F
L003ED4: db $01
L003ED5: db $08
L003ED6: db $00
L003ED7: db $0F
L003ED8: db $01
L003ED9: db $FF
L003EDA: db $04
L003EDB: db $02
L003EDC: db $0F
L003EDD: db $01
L003EDE: db $08
L003EDF: db $00
L003EE0: db $0F
L003EE1: db $01
L003EE2: db $08
L003EE3: db $02
L003EE4: db $0F
L003EE5: db $01
L003EE6: db $08
L003EE7: db $00
L003EE8: db $0F
L003EE9: db $01
L003EEA: db $FF
L003EEB: db $02
L003EEC: db $04
L003EED: db $04
L003EEE: db $01
L003EEF: db $14
L003EF0: db $08
L003EF1: db $08
L003EF2: db $01
L003EF3: db $FF
L003EF4: db $20;X
L003EF5: db $01;X
L003EF6: db $08;X
L003EF7: db $20;X
L003EF8: db $20;X
L003EF9: db $01;X
L003EFA: db $08;X
L003EFB: db $00;X
L003EFC: db $20;X
L003EFD: db $01;X
L003EFE: db $08;X
L003EFF: db $04;X
L003F00: db $01;X
L003F01: db $0F;X
L003F02: db $01;X
L003F03: db $08;X
L003F04: db $00;X
L003F05: db $0F;X
L003F06: db $01;X
L003F07: db $08;X
L003F08: db $01;X
L003F09: db $0F;X
L003F0A: db $01;X
L003F0B: db $08;X
L003F0C: db $00;X
L003F0D: db $0F;X
L003F0E: db $01;X
L003F0F: db $FF;X
L003F10: db $04;X
L003F11: db $02;X
L003F12: db $0F;X
L003F13: db $01;X
L003F14: db $08;X
L003F15: db $00;X
L003F16: db $0F;X
L003F17: db $01;X
L003F18: db $08;X
L003F19: db $02;X
L003F1A: db $0F;X
L003F1B: db $01;X
L003F1C: db $08;X
L003F1D: db $00;X
L003F1E: db $0F;X
L003F1F: db $01;X
L003F20: db $FF;X
L003F21: db $02;X
L003F22: db $04;X
L003F23: db $04;X
L003F24: db $01;X
L003F25: db $14;X
L003F26: db $08;X
L003F27: db $08;X
L003F28: db $01;X
L003F29: db $FF;X
L003F2A: db $04;X
L003F2B: db $02;X
L003F2C: db $0F;X
L003F2D: db $01;X
L003F2E: db $08;X
L003F2F: db $00;X
L003F30: db $0F;X
L003F31: db $01;X
L003F32: db $08;X
L003F33: db $02;X
L003F34: db $0F;X
L003F35: db $01;X
L003F36: db $08;X
L003F37: db $00;X
L003F38: db $0F;X
L003F39: db $01;X
L003F3A: db $FF;X
L003F3B: db $02;X
L003F3C: db $04;X
L003F3D: db $04;X
L003F3E: db $01;X
L003F3F: db $14;X
L003F40: db $08;X
L003F41: db $08;X
L003F42: db $01;X
L003F43: db $FF;X
L003F44: db $C6;X
L003F45: db $CB;X
L003F46: db $CE;X
L003F47: db $CB;X
L003F48: db $D6;X
L003F49: db $3E;X
L003F4A: db $32;X
L003F4B: db $CD;X
L003F4C: db $8B;X
L003F4D: db $41;X
L003F4E: db $C3;X
L003F4F: db $72;X
L003F50: db $41;X
L003F51: db $21;X
L003F52: db $21;X
L003F53: db $00;X
L003F54: db $09;X
L003F55: db $CB;X
L003F56: db $9E;X
L003F57: db $CB;X
L003F58: db $AE;X
L003F59: db $CB;X
L003F5A: db $C6;X
L003F5B: db $CB;X
L003F5C: db $CE;X
L003F5D: db $CB;X
L003F5E: db $D6;X
L003F5F: db $3E;X
L003F60: db $34;X
L003F61: db $CD;X
L003F62: db $8B;X
L003F63: db $41;X
L003F64: db $C3;X
L003F65: db $72;X
L003F66: db $41;X
L003F67: db $CD;X
L003F68: db $F9;X
L003F69: db $3A;X
L003F6A: db $D2;X
L003F6B: db $7B;X
L003F6C: db $3F;X
L003F6D: db $CD;X
L003F6E: db $0C;X
L003F6F: db $3B;X
L003F70: db $D2;X
L003F71: db $4E;X
L003F72: db $40;X
L003F73: db $CB;X
L003F74: db $47;X
L003F75: db $C2;X
L003F76: db $0C;X
L003F77: db $40;X
L003F78: db $C3;X
L003F79: db $2D;X
L003F7A: db $40;X
L003F7B: db $3E;X
L003F7C: db $09;X
L003F7D: db $CD;X
L003F7E: db $2A;X
L003F7F: db $10;X
L003F80: db $21;X
L003F81: db $21;X
L003F82: db $00;X
L003F83: db $09;X
L003F84: db $CB;X
L003F85: db $9E;X
L003F86: db $CB;X
L003F87: db $AE;X
L003F88: db $CB;X
L003F89: db $C6;X
L003F8A: db $CB;X
L003F8B: db $CE;X
L003F8C: db $CB;X
L003F8D: db $D6;X
L003F8E: db $3E;X
L003F8F: db $36;X
L003F90: db $CD;X
L003F91: db $8B;X
L003F92: db $41;X
L003F93: db $C3;X
L003F94: db $72;X
L003F95: db $41;X
L003F96: db $FA;X
L003F97: db $00;X
L003F98: db $C0;X
L003F99: db $CB;X
L003F9A: db $57;X
L003F9B: db $CA;X
L003F9C: db $A4;X
L003F9D: db $3F;X
L003F9E: db $21;X
L003F9F: db $20;X
L003FA0: db $00;X
L003FA1: db $09;X
L003FA2: db $CB;X
L003FA3: db $EE;X
L003FA4: db $21;X
L003FA5: db $21;X
L003FA6: db $00;X
L003FA7: db $09;X
L003FA8: db $CB;X
L003FA9: db $9E;X
L003FAA: db $CB;X
L003FAB: db $C6;X
L003FAC: db $CB;X
L003FAD: db $CE;X
L003FAE: db $CB;X
L003FAF: db $D6;X
L003FB0: db $3E;X
L003FB1: db $38;X
L003FB2: db $CD;X
L003FB3: db $8B;X
L003FB4: db $41;X
L003FB5: db $C3;X
L003FB6: db $72;X
L003FB7: db $41;X
L003FB8: db $3E;X
L003FB9: db $09;X
L003FBA: db $CD;X
L003FBB: db $2A;X
L003FBC: db $10;X
L003FBD: db $FA;X
L003FBE: db $00;X
L003FBF: db $C0;X
L003FC0: db $CB;X
L003FC1: db $57;X
L003FC2: db $CA;X
L003FC3: db $CB;X
L003FC4: db $3F;X
L003FC5: db $21;X
L003FC6: db $20;X
L003FC7: db $00;X
L003FC8: db $09;X
L003FC9: db $CB;X
L003FCA: db $E6;X
L003FCB: db $21;X
L003FCC: db $21;X
L003FCD: db $00;X
L003FCE: db $09;X
L003FCF: db $CB;X
L003FD0: db $9E;X
L003FD1: db $CB;X
L003FD2: db $C6;X
L003FD3: db $CB;X
L003FD4: db $CE;X
L003FD5: db $CB;X
L003FD6: db $D6;X
L003FD7: db $3E;X
L003FD8: db $3A;X
L003FD9: db $CD;X
L003FDA: db $8B;X
L003FDB: db $41;X
L003FDC: db $C3;X
L003FDD: db $72;X
L003FDE: db $41;X
L003FDF: db $21;X
L003FE0: db $21;X
L003FE1: db $00;X
L003FE2: db $09;X
L003FE3: db $CB;X
L003FE4: db $9E;X
L003FE5: db $CB;X
L003FE6: db $C6;X
L003FE7: db $CB;X
L003FE8: db $CE;X
L003FE9: db $CB;X
L003FEA: db $D6;X
L003FEB: db $3E;X
L003FEC: db $3C;X
L003FED: db $CD;X
L003FEE: db $8B;X
L003FEF: db $41;X
L003FF0: db $C3;X
L003FF1: db $72;X
L003FF2: db $41;X
L003FF3: db $3E;X
L003FF4: db $09;X
L003FF5: db $CD;X
L003FF6: db $2A;X
L003FF7: db $10;X
L003FF8: db $21;X
L003FF9: db $21;X
L003FFA: db $00;X
L003FFB: db $09;X
L003FFC: db $CB;X
L003FFD: db $9E;X
L003FFE: db $CB;X
L003FFF: db $C6;X
