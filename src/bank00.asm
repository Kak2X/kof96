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
Rst_FarDecompressLZSS:
	jp   FarDecompressLZSS
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
	jp   VBlankHandler
L000043: db $00;X
L000044: db $CD;X
L000045: db $66;X
L000046: db $2B;X
L000047: db $D2;X

; =============== LCDC/STAT INTERRUPT ===============
	jp   LCDCHandler
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
	jp   SerialHandler
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
	
; =============== FarDecompressLZSS ===============
; Decompresses the GFX on a different bank to the specified location in memory.
; IN
; - B: Bank number
; - DE: Ptr to decompression buffer
; - HL: Ptr to compressed graphics
FarDecompressLZSS:
	; Homecall-ish
	ldh  a, [hROMBank]
	push af
	ld   a, b
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	call DecompressLZSS
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

; =============== Bar Data ===============	
; Tile IDs used for bars that grow from right to left.
; Increasing and decreasing pick different ranges of bytes due to the different tile picked as "bar tip".
Play_Bar_TileIdTbl_RGrow:
	db $E0 ; Only used when decreasing as last value (completely empty)
	db $E8,$E9,$EA,$EB,$EC,$ED,$EE
	db $DF ; Only used when increasing as last value (completely filled)
; Tilemap offsets for each updatable tile of the bar (from least to most)
; Not necessarily used in its entirety.
; The offset used is usually calculated by doing BarValue/8.
Play_Bar_BGOffsetTbl_RGrow:
	db $08,$07,$06,$05,$04,$03,$02,$01,$00
	
; Like above, but for bars growing from left to right.
Play_Bar_TileIdTbl_LGrow:
	db $E0
	db $E1,$E2,$E3,$E4,$E5,$E6,$E7
	db $DF
Play_Bar_BGOffsetTbl_LGrow:
	db $00,$01,$02,$03,$04,$05,$06,$07,$08
; =============== Play_HUDTileIdTbl ===============
; Maps digits to tile IDs, relative to where GFXLZ_Play_HUD after it gets loaded to VRAM.
Play_HUDTileIdTbl:
	db $EF ; 0
	db $F0 ; 1
	db $F1 ; 2
	db $F2 ; 3
	db $F3 ; 4
	db $F4 ; 5
	db $F5 ; 6
	db $F6 ; 7
	db $F7 ; 8
	db $F8 ; 9
	
	; Tile IDs for pause text
L0000DB:
	db $D4
	db $D5

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
	ld   hl, hOAMDMA
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
	call Serial_Init
	
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
	
	; Set the main task, which will point to the custom module code.
	
	; Switch to the bank with the TAKARA logo display
	ld   a, BANK(Module_TakaraLogo)	; BANK $0A
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	
	; Have this as the first task
	ld   a, $01						; Task ID
	ld   bc, Module_TakaraLogo		; HL
	call Task_CreateAt
	
	jp   Task_GetNext
	
; =============== SGB_LoadBorder ===============
; Loads the SGB border for the game.
; IN
; - A: Border type
;      $01 -> Standard
;      $02 -> Alternate
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
		ld   a, BANK(SGBPacket_FreezeScreen) ; BANK $04
		ld   [MBC1RomBank], a
		ldh  [hROMBank], a
		
mSendPkg: MACRO
	ld   hl, \1
	call SGB_SendPackets
	ld   bc, $0004
	call SGB_DelayAfterPacketSendCustom
ENDM

		; Stop the screen on the TAKARA logo to prevent it from displaying the data sent to the SGB side through VRAM
		mSendPkg SGBPacket_FreezeScreen
		
		; Unknown byte sequence written to SNES RAM from 00:0810 to 00:0868.
		; Seems to match with what's already there, going by BSNES-plus with SGB2
		mSendPkg SGBPacket_Unknown_SNESWrite7
		mSendPkg SGBPacket_Unknown_SNESWrite6
		mSendPkg SGBPacket_Unknown_SNESWrite5
		mSendPkg SGBPacket_Unknown_SNESWrite4
		mSendPkg SGBPacket_Unknown_SNESWrite3
		mSendPkg SGBPacket_Unknown_SNESWrite2
		mSendPkg SGBPacket_Unknown_SNESWrite1
		mSendPkg SGBPacket_Unknown_SNESWrite0
		
		;-----------------------------------
		; FarCall into border loader, which also stops the LCD
		ld   b, BANK(SGB_SendBorderData) ; BANK $04
		ld   hl, SGB_SendBorderData
		rst  $08
		
		; Clear the tilemap and zero out the BG palette to actually hide the SGB transfer leftovers.
		; Why isn't this part of SGB_SendBorderData, which tries to do something similar with the GFX?
		call ClearBGMap
		xor  a
		ldh  [rBGP], a
		
		ld   a, LCDC_PRIORITY|LCDC_WTILEMAP|LCDC_ENABLE
		rst  $18				; Resume LCD
		;-----------------------------------
		
		call Task_SkipAllAndWaitVBlank
		ld   bc, $0078
		call SGB_DelayAfterPacketSendCustom
		
		; Resume the screen since we're done now
		mSendPkg SGBPacket_ResumeScreen
		
		call HomeCall_Sound_Init
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret

; =============== SGB_SendPackets ===============
; Sends one or more packets to the Super Game Boy.
; IN
; - HL: Ptr to packet structure (format: <number of packets><packet 0>[<packet 1>]...)
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

; =============== Task_GetNext ===============
; Executes the main task cycle.
; See also: Task_PassControl for the routine calling this.
Task_GetNext:
	ld   sp, $DC00					; Set the standard stack pointer for taskman
.reloop:
	; Always search for tasks starting from the first one.
	; Since they get marked after execution, this won't cause double exec.
	ld   hl, hTaskTbl				; HL = Ptr to start ot task table
	ld   de, TASK_SIZE				; DE = Size of a task struct
	ld   bc, $0301					; B = Number of tasks; C = Current Task ID
.nextTask:
	ld   a, [wMisc_C026]			; Mark this since we should unset this later
	set  MISCB_LAG_FRAME, a
	ld   [wMisc_C026], a
	
	ld   a, [wMisc_C025]			
	bit  MISCB_SERIAL_LAG, a			; Is everything frozen?
	jp   nz, .execCommon			; If so, skip executing all tasks
	
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
	
	; The stack ptr was saved after pushing all regs into the stack in Task_PassControl.
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
; =============== Task_PassControlCustom ===============
; Pauses the current task and gives back control to the task system.
;
; HOW IT WORKS
;
; The task system is used to execute custom subroutines/multiple main loops with separate stacks in a cycle, as well
; as shared code which must always run on any main loop, like the sound engine and OBJLst writer.
;
; There are three task slots and two different ways to execute subroutines:
; TASK_EXEC_NEW -> Used for init code, when the task pointer points to code.
; TASK_EXEC_TODO -> Used for loop code, when the task pointer points to a stack.
;
; *ANY* time the task system is run through Task_PassControl, current slot is overwritten with an entry used
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
; The VBLANK handler also re-enables every task marked as TASK_EXEC_DONE as TASK_EXEC_TODO, and the task table is iterated again.
; This WILL lead to the first task being executed again, which returns to the original state from before the task handler was
; called for the first time, and so on.
;
; IN
; - A: How many frames to pause the task after it's executed. If $01, it won't be paused.
Task_PassControlCustom:

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
	
	ldi  [hl], a		; Set pause timer
	
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
	jp   Task_GetNext

; =============== Task_PassControlFar ===============
; Wrapper for Task_PassControl_NoDelay which also saves the current bank number.
; Use when passing control from code in BANK $00 that needs a specific bank loaded.
Task_PassControlFar:
	ldh  a, [hROMBank]		; Save bank for when we're returning
	push af
	call Task_PassControl_NoDelay
	pop  af					; Restore bank
	ld   [MBC1RomBank], a	
	ldh  [hROMBank], a
	ret
	
; =============== Task_PassControl_* ===============
; Sets of wrappers to Task_PassControl with different pause timers.
Task_PassControl_NoDelay:
	ld   a, $01				; Delay for $01-1 frames before next exec
	jr   Task_PassControlCustom
; [TCRF] Unused.
Task_Unused_PassControl_Delay01: 
	ld   a, $02				; Delay for $02-1 frames before next exec
	jr   Task_PassControlCustom
Task_PassControl_Delay04:
	ld   a, $05				; ...
	jr   Task_PassControlCustom
Task_PassControl_Delay09:
	ld   a, $0A
	jr   Task_PassControlCustom
Task_PassControl_Delay1D:
	ld   a, $1E
	jr   Task_PassControlCustom
Task_PassControl_Delay3B:
	ld   a, $3C
	jr   Task_PassControlCustom
	
; =============== Task_RemoveCurAndPassControl ===============	
; Like Task_PassControl, except the current task is removed before passing control.
; Only used in ???????
Task_RemoveCurAndPassControl:
	di							; TODO: ?????
	call Task_IndexTaskAuto		; Index current task
	ld   [hl], TASK_EXEC_NONE	; Disable it
	jp   Task_GetNext
	
; =============== Task_IndexTaskAuto ===============
; Indexes the task struct of the currently executing task.
Task_IndexTaskAuto:
	ldh  a, [hCurTaskId]	; A = Index to current task
	
; =============== Task_IndexTask ===============
; Indexes the specified task struct by ID.
; IN
; - A: Index to task ID (must be between $01 and $03)
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
Task_SkipAllAndWaitVBlank:
	ld   a, $01
	ld   [wVBlankNotDone], a
	jp   Task_EndOfFrame
	
; =============== Task_Unused_SkipAllAndWaitVBlank_Copy ===============
; [TCRF] Unused? copy of the above.
Task_Unused_SkipAllAndWaitVBlank_Copy:
	ld   a, $01
	ld   [wVBlankNotDone], a
	jp   Task_EndOfFrame

; =============== Task_ExecCommon ===============
; Executes the common tasks before waiting for VBLANK.
Task_ExecCommon:

	; Mark frame as executed -- wait for the VBlank handler below
	ld   a, $01
	ld   [wVBlankNotDone], a
	
	; If game is frozen, skip over these ones too
	ld   a, [wMisc_C025]
	bit  MISCB_SERIAL_LAG, a			; Is it set?
	jp   nz, Task_EndOfFrame		; If so, skip
	
	call OBJLstS_WriteAll
	call SGB_SendSoundPacketAtFrameEnd
	call HomeCall_Sound_Do
	; Fall-through
	
; =============== Task_EndOfFrame ===============
Task_EndOfFrame:

	; Clear the lag frame marker since we made it in time.
	push hl
	ld   hl, wMisc_C026
	res  MISCB_LAG_FRAME, [hl]
	pop  hl
	
	; Wait in a loop until the VBlank handler triggers, which clears the flag
	; and marks all tasks for execution.
	; If we get here too late, the flag ends up not being cleared and we wait
	; for an extra frame.
	ei
	

	
.waitVBlank:
IF CPU_USAGE
	ld   a, [wVBlankNotDone]
	and  a
	ret  z
	halt
	jr   .waitVBlank		; In case something other than VBLANK occurred
ELSE
	ld   a, [wVBlankNotDone]
	or   a						; VBlank done yet?
	jp   nz, .waitVBlank		; If not, loop
	ret
ENDC



; =============== SetSectLYC ===============
; Enables section mode and and sets the scanline numbers for two of the three default screen sections.
; The first section always starts at $00 and is set during VBLANK,
; using hScrollY and hScrollX directly as its X/Y positions.
; IN
; - A: Scanline number the second section starts
; - B: Scanline number the third section starts
SetSectLYC:
	ld   [wScreenSect1LYC], a
	ld   a, b
	ld   [wScreenSect2LYC], a
	ld   a, [wMisc_C028]
	or   a, MISC_USE_SECT			
	ld   [wMisc_C028], a
	ret
	
; =============== DisableSectLYC ===============
; Disables section mode.
DisableSectLYC:
	push hl
		ld   hl, wMisc_C028
		res  MISCB_USE_SECT, [hl]
	pop  hl
	ret
	
; =============== LCDCHandler ===============
; Handles parallax effects and screen sections.
LCDCHandler:
	push af
		ld   a, [wMisc_C028]
		bit  MISCB_USE_SECT, a			; Are sections enabled?
		jp   nz, LCDCHandler_Sect		; If so, jump
		bit  MISCB_TITLE_SECT, a		; Are we in the title screen?
		jp   nz, LCDCHandler_Title		; If so, jump
	pop  af
	reti
; =============== LCDCHandler_Sect ===============
; Standard 3-section mode.
;
; The most important use for this is to draw the HUD during gameplay by enabling and disabling the WINDOW
; (alongside setting other things) at certain scanlines.
; This is additionally used in cutscenes to display the black borders.
LCDCHandler_Sect:
		
		; wLCDCSectId is either 0 (Section 1) or 1 (Section 2)
		; Reminder that Section 0 is set at VBlank, not here.
		
		ld   a, [wLCDCSectId]
		or   a						; SectId == 0?
		jp   nz, .sect3				; If not, jump
		
		;
		; Section 1 - Playfield
		;
	.sect2:
		; Wait in a loop before continuing, probably because HBlank time is short.
		; This should be using mWaitForNewHBlank to make it compatible with double speed mode.
		ld   a, $28
	.wait2:
		dec  a
		jp   nz, .wait2
		
		ldh  a, [hScreenSect1BGP]		; Set palette for section 1
		ldh  [rBGP], a
		; Disable the WINDOW
		ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_OBJSIZE|LCDC_WTILEMAP|LCDC_ENABLE
		ldh  [rLCDC], a					
		; Set next section ID
		ld   [wLCDCSectId], a			; It just needs to be != 0
		; Set next trigger
		ld   a, [wScreenSect2LYC]		; Set next trigger
		ldh  [rLYC], a
	pop  af
	reti
	
		;
		; Section 2 - HUD
		;
	.sect3:
		; Wait in a loop, shorter likely because there are less sprites here.
		ld   a, $0A
	.wait3:
		dec  a
		jp   nz, .wait3
		
		ldh  a, [hScreenSect2BGP]	; Set palette for section 2
		ldh  [rBGP], a
		; Enable the WINDOW
		; Due to how the WINDOW works, this resumes drawing from the point in the tilemap
		; we were when it got disabled. No need to touch the scroll registers.
		ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_OBJSIZE|LCDC_WENABLE|LCDC_WTILEMAP|LCDC_ENABLE
		ldh  [rLCDC], a
	pop  af
	reti
	
; =============== LCDCHandler_Title ===============
; Handles the scrolling clouds in the title screen.
;
; This is used at any point the title screen is displayed, even while the clouds are moving up.
LCDCHandler_Title:
		ld   a, [wLCDCSectId]
		or   a					; wLCDCSectId == 0?
		jp   z, .mode0			; If so, jump
		dec  a					; ...
		jp   z, .mode1
		dec  a					
		jp   z, .mode2
		dec  a
		jp   z, .mode3
		dec  a
		jp   z, .mode4
		dec  a
		jp   z, .mode5
		jp   .mode6
	
	;
	; Section 0: Prepare the parallax effect
	;
	.mode0:
		; Disable the WINDOW, since the clouds are in the main layer
		; (the WINDOW can't be used for this effect, so it's also the only way)
		
		; This continues using the hScrollX settings from VBlank
		
		ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_OBJSIZE|LCDC_WTILEMAP|LCDC_ENABLE
		ldh  [rLCDC], a
		ld   a, $01			; Next mode id
		ld   [wLCDCSectId], a
		ld   a, $73			; Next LYC trigger
		jp   .end
		
	;
	; Section 1-5: Parallax effect continued
	;
	.mode1:
		ld   a, $02					; Next mode id
		ld   [wLCDCSectId], a
		ldh  a, [hTitleParallax1X]	; Set parallax X pos
		ldh  [rSCX], a
		ld   a, $77				; Next LYC trigger
		jp   .end
	.mode2:
		ld   a, $03
		ld   [wLCDCSectId], a
		ldh  a, [hTitleParallax2X]
		ldh  [rSCX], a
		ld   a, $7B				; Next LYC trigger
		jp   .end
	.mode3:;J
		ld   a, $04
		ld   [wLCDCSectId], a
		ldh  a, [hTitleParallax3X]
		ldh  [rSCX], a
		ld   a, $7F				; Next LYC trigger
		jp   .end
	.mode4:
		ld   a, $05
		ld   [wLCDCSectId], a
		ldh  a, [hTitleParallax4X]
		ldh  [rSCX], a
		ld   a, $83				; Next LYC trigger
		jp   .end
	.mode5:
		ld   a, $06
		ld   [wLCDCSectId], a
		ldh  a, [hTitleParallax5X]
		ldh  [rSCX], a
		ld   a, $87
	.end:
	
		ldh  [rLYC], a
	pop  af
	reti
	;
	; Section 6: Restore the screen
	;
.mode6:

		; Wait, maybe because of the sprites?
		ld   a, $0A
	.wait:
		dec  a
		jp   nz, .wait
		
		; Enable the WINDOW
		ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_OBJSIZE|LCDC_WENABLE|LCDC_WTILEMAP|LCDC_ENABLE
		ldh  [rLCDC], a
		pop  af
		reti
		
; =============== VBlankHandler ===============
; Long VBLANK handler.
VBlankHandler:
	di	
	
	push af
	push bc
	push de
	push hl
	
	ldh  a, [hROMBank]
	push af
	;--
	
	ld   hl, wMisc_C025
	bit  MISCB_SERIAL_MODE, [hl]	; Is serial mode enabled?
	jp   z, VBlank_ChkCopyPlTiles	; If not, skip
.serialVS:
	res  MISCB_SERIAL_LAG, [hl]			; Default to an unfrozen game
	
	;
	; Peculiar logic for resetting the "transfer complete" flag.
	;
	; If wSerialInputMode isn't set, it means buffered serial input mode isn't enabled.
	; The only point we get here where this is ever the case is when ModeSelect_SerialHandler is being used,
	; as it doesn't treat serial input the standard way -- instead, it treats single received bytes as commands.
	;
	; For some reason, the mode select screen never resets wSerialTransferDone on the *master* side,
	; and instead relies on the VBlank handler to clear it. Which is what we're checking now.
	;
	ld   a, [wSerialInputMode]
	or   a							; Buffered serial input enabled?
	jp   z, .resetSerialDone		; If not, jump
	
	;
	; In buffered input mode, never reset wSerialTransferDone to the master.
	;
	bit  MISCB_SERIAL_SLAVE, [hl]	; Are we set as slave?
	jp   nz, .slaveDelayChk			; If so, jump
	jp   VBlank_ChkCopyPlTiles		; Otherwise, skip
.slaveDelayChk:
	;
	; Panic scenario.
	; If there are no more inputs currently left to process, it means the master
	; hasn't managed to send out a new byte yet.
	; In that case, force the slave to wait/freeze until other bytes come in, otherwise
	; the GBs would desync.
	;
	ld   a, [wSerialReceivedLeft]
	or   a									; Is the balance of received/processed inputs 0?
	jp   nz, .resetSerialDone				; If not, jump
	ld   hl, wMisc_C025						; Freeze game while waiting for serial
	set  MISCB_SERIAL_LAG, [hl]	
	
	; Lessen the effect of the lag by always setting the latest input to the head of the send buffer.
	; (with the index staying as-is)
	ld   a, START_TRANSFER_EXTERNAL_CLOCK		; Force start listening
	ldh  [rSC], a					
	ld   hl, wSerialLagCounter					; PauseTimer++
	inc  [hl]
	ld   hl, wSerialPendingJoyKeys2				; Poll for 2P inputs (since only 2P is slave)
	call JoyKeys_Get_Standard
	call JoyKeys_Serial_SetNextTransfer			; Save those into the send buffer
	jp   VBlank_ChkCopyPlTiles
.resetSerialDone:
	xor  a
	ld   [wSerialTransferDone], a
	
; =============== VBlank_ChkCopyPlTiles ===============
; Determines if the player graphics should be copied to VRAM.
VBlank_ChkCopyPlTiles:
	ld   a, [wMisc_C026]
	bit  MISCB_LAG_FRAME, a			; Is this a lag frame?
	jp   nz, VBlank_SetInitialSect	; If so, don't update player gfx
	ld   a, [wMisc_C025]
	bit  MISCB_SERIAL_LAG, a			; Is everything frozen?
	jp   nz, VBlank_SetInitialSect	; If so, also skip copying GFX
	ld   a, [wPaused]
	or   a							; Game is paused?
	jp   nz, VBlank_SetInitialSect	; If so, skip
	jp   VBlank_CopyPl1Tiles						

;--
; [TCRF] Unreferenced code.
L0005A1:
	ld   a, [wPlInfo_Pl1+iPlInfo_21]
	bit  4, a
	jp   nz, VBlank_CopyPl1Tiles
	ld   a, [wPlInfo_Pl1+iPlInfo_22Flags]
	bit  2, a
	jp   nz, VBlank_CopyPl1Tiles
	ld   a, [$C172]
	or   a
	jp   nz, VBlank_CopyPl1Tiles.end
;--

; =============== VBlank_CopyPl*Tiles ===============
; Set of subroutines for copying the player graphics across multiple frames during VBLANK.
;
; Each frame, at most 3 tiles get copied for each character.
; The player graphics are double buffered at two different VRAM slots.
;
; Note that the game always waits for a buffer to be filled before switching buffers
; and before continuing with the player animation/move. This also has the side effect
; that the amount of frames it takes to copy the graphics directly determines the anim speed.
;
; If the tiles were not being copied, the player would be stuck.

MAX_TILE_BUFFER_COPY EQU $03

; =============== mVBlank_CopyPlTiles ===============
; IN
; - 1: Ptr to wGFXBufInfo structure
mVBlank_CopyPlTiles: MACRO
	; TODO
ENDM

; =============== VBlank_CopyPl1Tiles ===============
; Copies the player 1 graphics to VRAM.
VBlank_CopyPl1Tiles:
	ld   a, [wGFXBufInfo_Pl1+iGFXBufInfo_TilesLeftA]
	or   a					; Any tiles left to transfer to buffer 0?
	jp   nz, .copyTo0		; If so, jump
	ld   a, [wGFXBufInfo_Pl1+iGFXBufInfo_TilesLeftB]
	or   a					; Any tiles left to transfer to buffer 1?
	jp   nz, .copyTo1		; If so, jump
	jp   .end				; If there's nothing, we're done
		
.copyTo0:
	;
	; Prepare the call to CopyTiles
	;

	; B = How many tiles to copy (+ update stat)
	ld   b, MAX_TILE_BUFFER_COPY	; B = MaxTiles
	cp   a, b						; TilesLeft >= MaxTiles?
	jp   nc, .notLast0				; If so, jump
	ld   b, a						; Otherwise, B = TilesLeft
									; Reaching this means this is the last set of tiles
.notLast0:
	sub  a, b							; TilesLeft -= TilesToCopy
	ld   [wGFXBufInfo_Pl1+iGFXBufInfo_TilesLeftA], a		; Update stat
	
	ld   a, [wGFXBufInfo_Pl1+iGFXBufInfo_DestPtr_Low]		; DE = Destination Ptr
	ld   e, a
	ld   a, [wGFXBufInfo_Pl1+iGFXBufInfo_DestPtr_High]
	ld   d, a
	ld   a, [wGFXBufInfo_Pl1+iGFXBufInfo_SrcPtrA_Low]		; HL = Source unc. gfx ptr
	ld   l, a
	ld   a, [wGFXBufInfo_Pl1+iGFXBufInfo_SrcPtrA_High]
	ld   h, a
	ld   a, [wGFXBufInfo_Pl1+iGFXBufInfo_BankA]				; A = Bank number the graphics are in
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	call CopyTiles
	; Save the updated stats back, to resume next time
	ld   a, e
	ld   [wGFXBufInfo_Pl1+iGFXBufInfo_DestPtr_Low], a
	ld   a, d
	ld   [wGFXBufInfo_Pl1+iGFXBufInfo_DestPtr_High], a
	ld   a, l
	ld   [wGFXBufInfo_Pl1+iGFXBufInfo_SrcPtrA_Low], a
	ld   a, h
	ld   [wGFXBufInfo_Pl1+iGFXBufInfo_SrcPtrA_High], a
	jp   .chkCopyEnd
	
.copyTo1:
	; Same thing as before, but with the other buffer
	ld   b, MAX_TILE_BUFFER_COPY
	cp   a, b
	jp   nc, .notLast1
	ld   b, a
.notLast1:
	sub  a, b
	ld   [wGFXBufInfo_Pl1+iGFXBufInfo_TilesLeftB], a
	ld   a, [wGFXBufInfo_Pl1+iGFXBufInfo_DestPtr_Low]
	ld   e, a
	ld   a, [wGFXBufInfo_Pl1+iGFXBufInfo_DestPtr_High]
	ld   d, a
	ld   a, [wGFXBufInfo_Pl1+iGFXBufInfo_SrcPtrB_Low]
	ld   l, a
	ld   a, [wGFXBufInfo_Pl1+iGFXBufInfo_SrcPtrB_High]
	ld   h, a
	ld   a, [wGFXBufInfo_Pl1+iGFXBufInfo_BankB]
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	call CopyTiles
	ld   a, e
	ld   [wGFXBufInfo_Pl1+iGFXBufInfo_DestPtr_Low], a
	ld   a, d
	ld   [wGFXBufInfo_Pl1+iGFXBufInfo_DestPtr_High], a
	ld   a, l
	ld   [wGFXBufInfo_Pl1+iGFXBufInfo_SrcPtrB_Low], a
	ld   a, h
	ld   [wGFXBufInfo_Pl1+iGFXBufInfo_SrcPtrB_High], a
	
.chkCopyEnd:

	; If there aren't any tiles left to copy in the buffer,
	; flag the copy as done so the game can actually decrement the frame timer.
	ld   a, [wGFXBufInfo_Pl1+iGFXBufInfo_TilesLeftA]
	or   a								; TilesLeft != 0?
	jp   nz, .end						; If so, skip
	ld   a, [wGFXBufInfo_Pl1+iGFXBufInfo_TilesLeftB]
	or   a								; TilesLeft != 0?
	jp   nz, .end						; If so, skip
	
.flagEnd:

	; Mark that the buffer operation is complete
	ld   hl, wOBJInfo_Pl1+iOBJInfo_Status
	res  OSTB_GFXLOAD, [hl]		; Buffer copied
	set  OSTB_BIT3, [hl]		; ??? does this do anything
	
	;--------
	; ??? Very likely in the middle of the Player actor, related to gameplay
	
	ld   hl, wPlInfo_Pl1+iPlInfo_22Flags
	bit  0, [hl]		; wPlInfo_Pl1+iPlInfo_22Flags bit 0 set?
	jp   nz, .move1		; If so, skip
	
	; Copy $D93D-$D93F to $D93A-$D93C and clear the former range
	; as long as they aren't 0 already.
	ld   hl, wPlInfo_Pl1+iPlInfo_3D		; HL = Source
	ld   de, wPlInfo_Pl1+iPlInfo_3A		; DE = Destination
	ld   a, [hl]
	or   a				; iPlInfo_3D == 0?
	jp   z, .move1		; If so, skip
	
.move0:
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
	
	;--------
.move1:
	
	; Copy over the unique identifier for the Set settings from iGFXBufInfo_SetKey to iGFXBufInfo_SetKeyOld.
	; This tells the wGFXBufInfo init code which settings were the last to be completely applied.
	ld   hl, wGFXBufInfo_Pl1+iGFXBufInfo_SetKey 		; HL = Source
	ld   de, wGFXBufInfo_Pl1+iGFXBufInfo_SetKeyOld 	; DE = Destination
	
REPT 5
	ldi  a, [hl]
	ld   [de], a
	inc  de
ENDR
	ld   a, [hl]
	ld   [de], a
	
	; Additionally, copy over the settings to the old set, to make sure this sprite gets displayed
	; when new graphics on this OBJInfo slot will load.
	ld   a, [wOBJInfo_Pl1+iOBJInfo_OBJLstFlags]
	ld   [wOBJInfo_Pl1+iOBJInfo_OBJLstFlagsOld], a
	ld   a, [wOBJInfo_Pl1+iOBJInfo_BankNum]
	ld   [wOBJInfo_Pl1+iOBJInfo_BankNumOld], a
	ld   a, [wOBJInfo_Pl1+iOBJInfo_OBJLstPtrTbl_Low]
	ld   [wOBJInfo_Pl1+iOBJInfo_OBJLstPtrTbl_LowOld], a
	ld   a, [wOBJInfo_Pl1+iOBJInfo_OBJLstPtrTbl_High]
	ld   [wOBJInfo_Pl1+iOBJInfo_OBJLstPtrTbl_HighOld], a
	ld   a, [wOBJInfo_Pl1+iOBJInfo_OBJLstPtrTblOffset]
	ld   [wOBJInfo_Pl1+iOBJInfo_OBJLstPtrTblOffsetOld], a
.end:
	jp   VBlank_CopyPl2Tiles
	
;--
; [TCRF] Unreferenced code
L0006A7:
	ld   a, [wPlInfo_Pl2+iPlInfo_21]
	bit  4, a
	jp   nz, VBlank_CopyPl2Tiles
	ld   a, [wPlInfo_Pl2+iPlInfo_22Flags]
	bit  2, a
	jp   nz, VBlank_CopyPl2Tiles
	ld   a, [$C172]
	or   a
	jp   nz, VBlank_CopyPl2Tiles.end
;--
; =============== VBlank_CopyPl2Tiles ===============
; Copies the player 2 graphics to VRAM.
VBlank_CopyPl2Tiles:
	ld   a, [wGFXBufInfo_Pl2+iGFXBufInfo_TilesLeftA]
	or   a
	jp   nz, .copyTo0
	ld   a, [wGFXBufInfo_Pl2+iGFXBufInfo_TilesLeftB]
	or   a
	jp   nz, .copyTo1
	jp   .end
.copyTo0:
	ld   b, MAX_TILE_BUFFER_COPY
	cp   a, b
	jp   nc, .notLast0
	ld   b, a
.notLast0:
	sub  a, b
	ld   [wGFXBufInfo_Pl2+iGFXBufInfo_TilesLeftA], a
	ld   a, [wGFXBufInfo_Pl2+iGFXBufInfo_DestPtr_Low]
	ld   e, a
	ld   a, [wGFXBufInfo_Pl2+iGFXBufInfo_DestPtr_High]
	ld   d, a
	ld   a, [wGFXBufInfo_Pl2+iGFXBufInfo_SrcPtrA_Low]
	ld   l, a
	ld   a, [wGFXBufInfo_Pl2+iGFXBufInfo_SrcPtrA_High]
	ld   h, a
	ld   a, [wGFXBufInfo_Pl2+iGFXBufInfo_BankA]
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	call CopyTiles
	ld   a, e
	ld   [wGFXBufInfo_Pl2+iGFXBufInfo_DestPtr_Low], a
	ld   a, d
	ld   [wGFXBufInfo_Pl2+iGFXBufInfo_DestPtr_High], a
	ld   a, l
	ld   [wGFXBufInfo_Pl2+iGFXBufInfo_SrcPtrA_Low], a
	ld   a, h
	ld   [wGFXBufInfo_Pl2+iGFXBufInfo_SrcPtrA_High], a
	jp   .chkCopyEnd
.copyTo1:
	ld   b, MAX_TILE_BUFFER_COPY
	cp   a, b
	jp   nc, .notLast1
	ld   b, a
.notLast1:
	sub  a, b
	ld   [wGFXBufInfo_Pl2+iGFXBufInfo_TilesLeftB], a
	ld   a, [wGFXBufInfo_Pl2+iGFXBufInfo_DestPtr_Low]
	ld   e, a
	ld   a, [wGFXBufInfo_Pl2+iGFXBufInfo_DestPtr_High]
	ld   d, a
	ld   a, [wGFXBufInfo_Pl2+iGFXBufInfo_SrcPtrB_Low]
	ld   l, a
	ld   a, [wGFXBufInfo_Pl2+iGFXBufInfo_SrcPtrB_High]
	ld   h, a
	ld   a, [wGFXBufInfo_Pl2+iGFXBufInfo_BankB]
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	call CopyTiles
	ld   a, e
	ld   [wGFXBufInfo_Pl2+iGFXBufInfo_DestPtr_Low], a
	ld   a, d
	ld   [wGFXBufInfo_Pl2+iGFXBufInfo_DestPtr_High], a
	ld   a, l
	ld   [wGFXBufInfo_Pl2+iGFXBufInfo_SrcPtrB_Low], a
	ld   a, h
	ld   [wGFXBufInfo_Pl2+iGFXBufInfo_SrcPtrB_High], a
.chkCopyEnd:
	ld   a, [wGFXBufInfo_Pl2+iGFXBufInfo_TilesLeftA]
	or   a
	jp   nz, .end
	ld   a, [wGFXBufInfo_Pl2+iGFXBufInfo_TilesLeftB]
	or   a
	jp   nz, .end
.flagEnd:
	ld   hl, wOBJInfo_Pl2+iOBJInfo_Status
	res  OSTB_GFXLOAD, [hl]
	set  OSTB_BIT3, [hl]
	ld   hl, wPlInfo_Pl2+iPlInfo_22Flags
	bit  0, [hl]
	jp   nz, .move1
	
	ld   hl, wPlInfo_Pl2+iPlInfo_3D
	ld   de, wPlInfo_Pl2+iPlInfo_3A
	ld   a, [hl]
	or   a
	jp   z, .move1
.move0:
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
.move1:

	ld   hl, wGFXBufInfo_Pl2+iGFXBufInfo_SetKey
	ld   de, wGFXBufInfo_Pl2+iGFXBufInfo_SetKeyOld
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
	ld   a, [wOBJInfo_Pl2+iOBJInfo_OBJLstFlags]
	ld   [wOBJInfo_Pl2+iOBJInfo_OBJLstFlagsOld], a
	ld   a, [wOBJInfo_Pl2+iOBJInfo_BankNum]
	ld   [wOBJInfo_Pl2+iOBJInfo_BankNumOld], a
	ld   a, [wOBJInfo_Pl2+iOBJInfo_OBJLstPtrTbl_Low]
	ld   [wOBJInfo_Pl2+iOBJInfo_OBJLstPtrTbl_LowOld], a
	ld   a, [wOBJInfo_Pl2+iOBJInfo_OBJLstPtrTbl_High]
	ld   [wOBJInfo_Pl2+iOBJInfo_OBJLstPtrTbl_HighOld], a
	ld   a, [wOBJInfo_Pl2+iOBJInfo_OBJLstPtrTblOffset]
	ld   [wOBJInfo_Pl2+iOBJInfo_OBJLstPtrTblOffsetOld], a
.end:

; =============== VBlank_SetInitialSect ===============
; Initializes the topmost screen section (which starts at LY $00), which may
; or may not be the only one depending if sections are enabled.
VBlank_SetInitialSect:
	ld   a, [wMisc_C028]
	bit  MISCB_USE_SECT, a		; Using screen sections?
	jp   nz, .stdSect			; If so, jump
	bit  MISCB_TITLE_SECT, a	; In the title screen?
	jp   nz, .titleSect			; If so, jump
	jp   .singleSect			; Otherwise, we don't do anything special. Skip ahead.
	
.stdSect:
	;
	; Standard 3-section mode.
	;
	ldh  a, [rSTAT]
	and  a, STAT_LYC		; LYC enabled?
	jp   z, .noScanlineInt	; If not, ignore this
	
	; Enable all
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_OBJSIZE|LCDC_WENABLE|LCDC_WTILEMAP|LCDC_ENABLE
	ldh  [rLCDC], a
	
	ld   a, [wScreenSect1LYC]			; Set starting point for second section 
	ldh  [rLYC], a
	xor  a								; Reset wLCDCSectId
	ld   [wLCDCSectId], a
	ldh  a, [hScreenSect0BGP]			; Set palette for first section
	ldh  [rBGP], a
	
	; If we have a lag frame or game is frozen, don't update sprites.
	; Important for battle syncronization purposes, as sprites also determine
	; something ??? in the player actor info.
	ld   a, [wMisc_C026]
	bit  MISCB_LAG_FRAME, a				
	jp   nz, .stdSect_noDMA
	ld   a, [wMisc_C025]
	bit  MISCB_SERIAL_LAG, a
	jp   nz, .stdSect_noDMA
	call hOAMDMA
.stdSect_noDMA:
	jp   .setFirstSect			; Skip ahead
	
.titleSect:
	;
	; Title screen mode.
	; Like the single section mode, except there's a LYC trigger.
	;
	ldh  a, [rSTAT]
	and  a, STAT_LYC		; LYC enabled?
	jp   z, .noScanlineInt	; If not, ignore this
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_OBJSIZE|LCDC_WENABLE|LCDC_WTILEMAP|LCDC_ENABLE
	ldh  [rLCDC], a
	ld   a, $6F				; Line where the parallax effect starts
	ldh  [rLYC], a
	ld   a, $1B
	ldh  [rBGP], a
.noScanlineInt:
	;
	; LYC was disabled
	;
	xor  a
	ld   [wLCDCSectId], a
.singleSect:
	;
	; No sections
	;
	call hOAMDMA
	
.setFirstSect:
	;
	; Shared code for setting up the first section
	;
	ldh  a, [hScrollY]			; Set X and Y pos
	ldh  [rSCY], a
	ldh  a, [hScrollX]
	ldh  [rSCX], a
	
; =============== VBlank_LastPart ===============
VBlank_LastPart:
	
	; If the current or other GB is lagging, skip directly to the end.
	; This prevents unsetting wVBlankNotDone or reading new inputs.

	; This is especially important for serial syncronization purposes,
	; as we don't want to set new inputs if we're lagging or if the
	; other is lagging and not sending us inputs to reply with fast enough.
	ld   a, [wMisc_C026]
	bit  MISCB_LAG_FRAME, a		; Are we lagging?
	jp   nz, .end				; If so, skip
	ld   a, [wMisc_C025]
	bit  MISCB_SERIAL_LAG, a	; Did the other send at least one byte not yet processed?
	jp   nz, .end				; If not, skip
	
	call JoyKeys_Get			; Get player input
	ld   hl, wTimer				; GlobalTimer++
	inc  [hl]
	
	; Clear wVBlankNotDone. 
	; (why is this check even here -- it could be using "xor a" directly)
	ld   a, [wVBlankNotDone]
	or   a						; Status == 0?
	jr   z, .resetTasks			; If so, jump
	dec  a
	ld   [wVBlankNotDone], a
	
.resetTasks:

	;
	; Mark for execution all of the previously executed tasks with no pause timer
	;
	ld   hl, hTaskTbl		; HL = Start of task table
	ld   de, TASK_SIZE		; DE = Task size
	ld   b, $03				; B = Tasks left
.loop:
	bit  0, [hl]			; Type == TASK_EXEC_DONE?
	jp   z, .nextTask		; If not, skip
	
	inc  hl					; Seek to iTaskPauseTimer
	dec  [hl]				; PauseTimer--
	dec  hl					; Seek back
	
	jp   nz, .nextTask		; Is the PauseTimer != 0? If so, skip
	ld   [hl], TASK_EXEC_TODO	; Otherwise, mark it for execution
.nextTask:
	add  hl, de				; HL += TASK_SIZE
	dec  b					; All tasks checked?
	jp   nz, .loop			; If not, loop
.end:
	
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
	
	; Take the relative X position into account, since that's outside of iOBJInfo_X
	; B = -OBJScrollX
	ld   a, [wOBJScrollX]	; Invert as it simulates wScrollX behaviour
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
; Handles the values in the OBJInfo structure before writing the sprite mappings to the OAM mirror.
; IN
; - HL: Ptr to a wOBJInfo structure.
OBJLstS_DoOBJInfoSlot:

	; If the sprite is hidden, don't draw it to OAM
	ldi  a, [hl]				; Read iOBJInfo_Status
	bit  OSTB_VISIBLE, a		; Visibility flag set?
	ret  z						; If not, return
	
	ld   b, a						
	ld   [wOBJLstTmpROMFlags], a	
	ld   [wOBJLstCurStatus], a	; Copy iOBJInfo_Status here
	
	;
	; This game uses double buffering, meaning two sets of GFX buffers are used, as well as two copies of the sprite mapping info.
	; The GFX buffer to use is determined by the flag OST_GFXBUF2, and the buffers work as you'd expect by alternating between
	; buffer every other sprite mapping frame.
	; The two sprite mapping sets instead have a specific role:
	; - The first one (unnamed) always contains the info for the current/new sprite mapping,
	;   which MAY or MAY NOT be still loading GFX.
	; - The second one ("Old") contains a copy of the info for the last fully rendered sprite mapping
	;   which is ONLY used to display the old sprite mapping while the GFX in the first set are still being loaded.
	;
	; The global flag OST_GFXLOAD determines if the graphics for the first set are still being loaded.
	; If it is, the sprite mapping in the second set must be used. Also, since OST_GFXBUF2 always points to the new buffer,
	; that flag must be inverted before being used to make it point to the old buffer (see .chkBuf).
	;
		
	; 
	; If GFX are loading, use the old user-defined sprite mapping flags.
	; This value will not be changed again in this subroutine -- and will be later xor'd over with wOBJLstCurStatus.
	; 
	bit  OSTB_GFXLOAD, a		; GFX loading for new sprite mapping?
	jp   nz, .useOldStatus		; If so, jump
.useCurStatus:	
	ldi  a, [hl]				; Read iOBJInfo_OBJLstFlags	
	ld   [wOBJLstOrigFlags], a
	inc  hl						; Seek to iOBJInfo_X
	jp   .calcRelX
.useOldStatus:
	inc  hl
	ldi  a, [hl]				; Read iOBJInfo_OBJLstFlagsOld, seek to iOBJInfo_X
	ld   [wOBJLstOrigFlags], a

.calcRelX:
	;--
	;
	; Determine the relative X position of the sprite mapping.
	; RelX = AbsoluteX - BaseX + OBJ_OFFSET_X
	;
	; The wOBJScroll* values are "inverted", to simulate how scrolling the screen right would move the BG left.
	; So here, setting wOBJScrollX to 5 will move the sprites left by 5px.
	;
	; This is done this way to allow easy sync with the BG scrolling during gameplay -- as one of the
	; main purposes of these values is to move all sprites accordingly when the playfield scrolls.
	;

	; C = Sprite X position
	ld   c, [hl]				; Read iOBJInfo_X
	; A = -BaseX
	ld   a, [wOBJScrollX]
	cpl
	inc  a
	
	add  c						; A = XPos - BaseX
	add  a, OBJ_OFFSET_X		; A += OBJ_OFFSET_X
	
	; Seek to next entry (this has 2 bytes assigned?)
	inc  hl						; HL += 2
	inc  hl
	ld   [wOBJLstCurRelX], a	; Save the result here
	
	
.calcRelY:
	;--
	;
	; Determine the relative Y position of the sprite mapping.
	; RelY = AbsoluteY - BaseY
	;
	
	; C = Sprite Y position
	ld   c, [hl]				; Read iOBJInfo_Y
	; A = -BaseY
	ld   a, [wOBJScrollY]
	cpl
	inc  a
	
	add  c						; A = YPos - BaseY
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
	
.chkBuf:
	;
	; Pick the additional tileID offset depending on the current GFX buffer.
	; The two buffers are $20 tiles large, and if we're using the second one,
	; add $20 to the tileID.
	; 
	; Additionally, if GFX are still loading use the old buffer.
	;
	
	ld   a, b				; Read back status
	bit  OSTB_GFXLOAD, a	; GFX loading for new sprite mapping?
	jr   z, .noInvTileBit	; If not, skip
	xor  OST_GFXBUF2		; Otherwise, use old buffer
.noInvTileBit:

	
	bit  OSTB_GFXBUF2, a	; Are we using the second *GFX* buffer?
	jp   z, .noAdd20		; If not, skip
	ld   a, $20				; A = iOBJInfo_TileIDBase + $20
	add  c
	ld   c, a
.noAdd20:
	inc  hl
	inc  hl
	
	
	;--
	; If GFX are still loading display the old sprite mapping.
	;
	; Note that the sprite mapping offset (iOBJInfo_OBJLstPtrTblOffset*) is always a multiple of $04.
	; This is because each entry in the table has space for 2 sprite mapping pointers (parts A and B).
	;
;----------
	; $10 
	push bc
		bit  OSTB_GFXLOAD, b	; GFX loading for new sprite mapping?
		jr   nz, .useOldOBJLst	; If so, jump
		
	.useCurOBJLst:
		ldi  a, [hl]			; Read iOBJInfo_BankNum
		ld   [MBC1RomBank], a
		ldh  [hROMBank], a
		; $11
		ld   e, [hl]			; Read iOBJInfo_OBJLstPtrTbl_Low
		inc  hl
		; $12
		ld   d, [hl]			; Read iOBJInfo_OBJLstPtrTbl_High
		inc  hl
		; $13
		ld   c, [hl]			; Read iOBJInfo_OBJLstPtrTblOffset
		inc  hl
		
		; Skip to byte18
		inc  hl
		inc  hl
		inc  hl
		inc  hl
		; $18
		jr   .drawMainOBJ
	.useOldOBJLst:
		; Use the secondary set
		
		; Skip to byte14
		inc  hl
		inc  hl
		inc  hl
		inc  hl
		; $14
		ldi  a, [hl]			; Read iOBJInfo_BankNumOld
		ld   [MBC1RomBank], a
		ldh  [hROMBank], a
		; $15
		ld   e, [hl]			; Read iOBJInfo_OBJLstPtrTbl_LowOld
		inc  hl
		; $16
		ld   d, [hl]			; Read iOBJInfo_OBJLstPtrTbl_HighOld
		inc  hl
		; $17
		ld   c, [hl]			; Read iOBJInfo_OBJLstPtrTblOffsetOld
		inc  hl
		; $18
		
	.drawMainOBJ:

		; Switch HL and DE
		push de
		push hl
		pop  de
		pop  hl
		
		;
		; Index the sprite mapping table
		;
		
		; HL = Start of OBJLstPtrTable (animation/sprite mappings table)
		ld   b, $00		; BC = Index
		add  hl, bc		; Offset it
	pop  bc
;----------


	;
	; To build the full sprite, *up to* two different OBJLst are copied (marked as parts A and B).
	; The reasoning behind this is to save space by reusing half of the sprites for different frames,
	; with B usually being used for the legs and A for the upper part.
	;

	; The first sprite mapping is always defined
	push hl	
	call OBJLstS_DoOBJLstHeaderA
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
	
	jp   OBJLstS_DoOBJLstHeaderB
	
; =============== OBJLstS_DoOBJLstHeaderA ===============
; Parses out the header for the primary sprite mapping before writing it to the OAM mirror.
; IN
; - HL: Ptr to OBJLstPtrTable entry
; - DE: Ptr to actor/wOBJInfo struct byte18
; - C : Tile ID base
OBJLstS_DoOBJLstHeaderA:

	;--
	;
	; Read out to HL the pointer off the animation table.
	; This will point to the header of the actual sprite mapping (OBJLst).
	;
	push de
		; Read ptr to DE
		ld   e, [hl]	
		inc  hl
		ld   d, [hl]	
		; HL = DE
		push de			
		pop  hl
	pop  de
	;--
	
	; Now HL points to the start of a sprite mapping, at the header.
	
	;
	; BYTE 0 - Flags
	;
	
	; wOBJLstTmpROMFlags |= (iOBJLstHdrA_Flags & OLF_XFLIP|OLF_YFLIP)
	; Note that it's doing |=, so it's AND'ed over iOBJInfo_Status.
	
	; Get sprite mapping flags from ROM
	ldi  a, [hl]					; Read iOBJLstHdrA_Flags
	ld   [wOBJLstCurHeaderFlags], a	; Save source val for later
	
	; Add the current X/Y flip flags on top of the existing ones
	and  a, OLF_XFLIP|OLF_YFLIP		; B = iOBJLstHdrA_Flags & OLF_XFLIP|OLF_YFLIP
	ld   b, a
	ld   a, [wOBJLstTmpROMFlags]	; wOBJLstTmpROMFlags |= B
	or   b
	ld   [wOBJLstTmpROMFlags], a
	
	;
	; BYTE 1 - ???
	;
	
	; Copy over item1 to byte18
	ldi  a, [hl]	; Read iOBJLstHdrA_Byte1
	ld   [de], a	; Write to iOBJInfo_OBJLstByte1
	inc  de
	
	;
	; BYTE 2 - ???
	;
	
	; Copy over item2 to byte19
	ldi  a, [hl]	; Read iOBJLstHdrA_Byte2
	ld   [de], a	; Write to iOBJInfo_OBJLstByte2
	
	; $03
	inc  hl
	; $04
	inc  hl
	; $05
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
	ldi  a, [hl]				; Read iOBJLstHdrA_XOffset
	ld   [wOBJLstCurXOffset], a
	
	;
	; BYTE 9 - Y Offset
	;
	ld   a, [hl]				; Read iOBJLstHdrA_YOffset
	ld   [wOBJLstCurYOffset], a
	
	jp   OBJLstS_WriteToWorkOAM
	
; =============== OBJLstS_DoOBJLstHeaderB ===============
; Parses out the header for the secondary sprite mapping before writing it to the OAM mirror.
; Compared to the primary sprite mapping, this seems to use a different format for the header.
; IN
; - HL: Ptr to start of second OBJLst (at the header)
; - C : Tile ID base (always after the one from the primary header)
OBJLstS_DoOBJLstHeaderB:

	;
	; BYTE 0 - Flags
	;
	
	; wOBJLstTmpROMFlags = iOBJInfo_Status | (wOBJLstCurHeaderFlags & OLF_XFLIP|OLF_YFLIP)
	; The value of wOBJLstTmpROMFlags is contaminated with iOBJLstHdrA_Flags by the time we get here,
	; which is why it's using the untouched copy of iOBJInfo_Status in wOBJLstCurStatus.
	; 
	
	; Get sprite mapping flags from ROM
	ldi  a, [hl]					; Read iOBJLstHdrB_Flags
	ld   [wOBJLstCurHeaderFlags], a	; Save source val for later
	
	; Add the X/Y flip flags on top of the existing ones
	and  a, OLF_XFLIP|OLF_YFLIP		
	ld   b, a
	ld   a, [wOBJLstCurStatus]
	or   b
	ld   [wOBJLstTmpROMFlags], a
	
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
	; Calculate the effective flags value for the sprite mapping.
	; Merge the sprite mapping X/Y flip options from ROM with the hardware OBJ flags in iOBJInfo_OBJLstFlags
	;
	
	; B = Default flip flags for the sprite mapping from ROM*.
	;     *after some merging with iOBJInfo_Status.
	ld   a, [wOBJLstTmpROMFlags]		
	and  a, OLF_XFLIP|OLF_YFLIP
	ld   b, a
	
	; A = User-controlled OBJ flags from iOBJInfo_OBJLstFlags*
	ld   a, [wOBJLstOrigFlags]		
	and  a, SPR_OBP1|SPR_XFLIP|SPR_YFLIP|SPR_BGPRIORITY
	
	; Xor the flags over
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
	
	ld   a, [wOBJLstOrigFlags]
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

	ld   a, [wOBJLstCurHeaderFlags]
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
	
; =============== OBJLstS_DoAnimTiming_Initial ===============
; Initializes the current animation frame.
; Essentially sets up the arguments for OBJLstS_UpdateGFXBufInfo without doing anything else.
; IN
; - HL: Ptr to wOBJInfo struct
OBJLstS_DoAnimTiming_Initial:
	ldh  a, [hROMBank]					; Save current bank
	push af
		res  OSTB_BIT3, [hl]			; Reset OSTB_BIT3
		push hl
			; Switch to the bank number
			ld   de, iOBJInfo_BankNum
			add  hl, de					; Seek to iOBJInfo_BankNum
			ldi  a, [hl]				; Get bank num
			ld   [MBC1RomBank], a		; Go there
			ldh  [hROMBank], a			
			
			; Get args
			ld   e, [hl]				; DE = Ptr to OBJLstPtrTable
			inc  hl
			ld   d, [hl]
			inc  hl
			ld   c, [hl]				; BC = Offset
			ld   b, $00
			
			; Switch DE and HL
			push de
			push hl
			pop  de						; DE = iOBJInfo_OBJLstPtrTblOffset
			pop  hl						; HL = Ptr to OBJLstPtrTable
			
			add  hl, bc					; Index it
										; HL = OBJLstPtrTable entry to OBJLstHdrA_*
			jp   OBJLstS_UpdateGFXBufInfo

; =============== OBJLstS_DoAnimTiming_NoLoop ===============
; Handles the timing for the current animation for the specified OBJInfo.
; When the animation ends, the last frame is repeated indefinitely.
; IN
; - HL: Ptr to wOBJInfo struct		
OBJLstS_DoAnimTiming_NoLoop:
	ldh  a, [hROMBank]
	push af
		res  OSTB_BIT3, [hl]			; Reset OSTB_BIT3
			
		;
		; If the animation is marked as ended or GFX are still being copied to the other buffer,
		; don't even decrement the frame counter.
		;
		ld   a, [hl]
		and  a, OST_ANIMEND|OST_GFXLOAD		; Any of the two bits set?
		jp   nz, OBJLstS_CommonAnim_End		; If so, return immediately
		
		;
		; Continue showing the current animation frame until iOBJInfo_FrameLeft elapses.
		;
		push hl
			ld   de, iOBJInfo_FrameLeft		; Seek to anim timer iOBJInfo_FrameLeft
			add  hl, de
			ld   a, [hl]
			or   a							; Is it $00?
			jp   z, .setNextFrame			; If so, jump
			dec  a							; Otherwise, decrement the timer		
			ld   [hl], a					; And save it back
		pop  hl
		jp   OBJLstS_CommonAnim_End			; We're done for now
		
		.setNextFrame:
			;
			; Set the anim timer to the animation speed value.
			;
			inc  hl							; Seek to iOBJInfo_FrameTotal
			ldd  a, [hl]					; Read total frame length; seek back to iOBJInfo_FrameLeft
			ld   [hl], a					; Set it to the anim timer
		pop  hl
		
		;
		; Set the next sprite mapping in the list, according to the current OBJLstPtrTbl
		;
		push hl
			ld   de, iOBJInfo_BankNum		; Seek to bank number
			add  hl, de
			
			ldi  a, [hl]					; Read it
			ld   [MBC1RomBank], a			; Switch banks there
			ldh  [hROMBank], a
			
			; Gets args
			ld   e, [hl]				; DE = Ptr to OBJLstPtrTable
			inc  hl
			ld   d, [hl]
			inc  hl
			
			; Seek to the next entry in the table, and also save back the updated value
			ld   a, [hl]				; A = Offset + $04
			add  a, OBJLSTPTR_ENTRYSIZE
			ld   [hl], a
			ld   b, $00					; BC = New offset
			ld   c, a
			
			; Switch DE and HL
			push de
			push hl
			pop  de						; DE = iOBJInfo_OBJLstPtrTblOffset
			pop  hl						; HL = Ptr to OBJLstPtrTable
			
			;
			; Determine if the OBJLstHdrA_* pointer is "null" ($FFFF).
			; If it is, the animation has ended and should repeat the last frame indefinitely.
			; Otherwise, continue normally with the updated iOBJInfo_OBJLstPtrTblOffset.
			;
			push hl
				add  hl, bc				; Seek to current OBJLst ptr
				inc  hl					; Seek to high byte of ptr (since it can't happen to be $FF for valid pointers)
				ld   a, [hl]			; Read high byte of ptr
				cp   HIGH(OBJLSTPTR_NONE); Is it $FF?
				jp   nz, .nextOk		; If not, jump (this is a valid pointer)
			.finished:
				;------------------------
				; Otherwise, move back the offset
				ld   a, [de]			; iOBJInfo_OBJLstPtrTblOffset -= $04
				sub  a, OBJLSTPTR_ENTRYSIZE
				ld   [de], a
			pop  hl						
		pop  hl							; Restore ptr to start of OBJInfo
		
		; Update the OBJInfo status to mark the end of the animation
		ld   a, [hl]			
		or   a, OST_ANIMEND
		ld   [hl], a
		
		; We're done
		jp   OBJLstS_CommonAnim_End
		;------------------------
			.nextOk:
				dec  hl					; Seek back to the low byte of the OBJLst ptr		
			pop  de						; Pull out useless value to sync
			jp   OBJLstS_UpdateGFXBufInfo ; ...
			
; =============== OBJLstS_DoAnimTiming_Loop ===============
; Handles the timing for the current animation for the specified OBJInfo.
; When the animation ends, the animation loops back to the first frame.
;
; See also: OBJLstS_DoAnimTiming_NoLoop
;           Essentially identical except the section of code in .finished is different.
; IN
; - HL: Ptr to wOBJInfo struct				
OBJLstS_DoAnimTiming_Loop:
	ldh  a, [hROMBank]
	push af
		res  OSTB_BIT3, [hl]			; Reset OSTB_BIT3
			
		;
		; If the animation is marked as ended or GFX are still being copied to the other buffer,
		; don't even decrement the frame counter.
		;
		ld   a, [hl]
		and  a, OST_ANIMEND|OST_GFXLOAD		; Any of the two bits set?
		jp   nz, OBJLstS_CommonAnim_End				; If so, return immediately
		
		;
		; Continue showing the current animation frame until iOBJInfo_FrameLeft elapses.
		;
		push hl
			ld   de, iOBJInfo_FrameLeft		; Seek to anim timer iOBJInfo_FrameLeft
			add  hl, de
			ld   a, [hl]
			or   a							; Is it $00?
			jp   z, .setNextFrame			; If so, jump
			dec  a							; Otherwise, decrement the timer		
			ld   [hl], a					; And save it back
		pop  hl								; HL = Ptr to wOBJInfo
		jp   OBJLstS_CommonAnim_End					; We're done for now
		
		.setNextFrame:
			;
			; Set the anim timer to the animation speed value.
			;
			inc  hl							; Seek to iOBJInfo_FrameTotal
			ldd  a, [hl]					; Read total frame length; seek back to iOBJInfo_FrameLeft
			ld   [hl], a					; Set it to the anim timer
		pop  hl								; HL = Ptr to wOBJInfo
		
		;
		; Set the next sprite mapping in the list, according to the current OBJLstPtrTbl
		;
		push hl
			ld   de, iOBJInfo_BankNum		; Seek to bank number
			add  hl, de
			
			ldi  a, [hl]					; Read it
			ld   [MBC1RomBank], a			; Switch banks there
			ldh  [hROMBank], a
			
			; Gets args
			ld   e, [hl]				; DE = Ptr to OBJLstPtrTable
			inc  hl
			ld   d, [hl]
			inc  hl
			
			; Seek to the next entry in the table, and also save back the updated value
			ld   a, [hl]				; A = Offset + $04
			add  a, OBJLSTPTR_ENTRYSIZE
			ld   [hl], a
			ld   b, $00					; BC = New offset
			ld   c, a
			
			; Switch DE and HL
			push de
			push hl
			pop  de						; DE = iOBJInfo_OBJLstPtrTblOffset
			pop  hl						; HL = Ptr to OBJLstPtrTable entry
			
			;
			; Determine if the OBJLstHdrA_* pointer is "null" ($FFFF).
			; If it is, the animation has ended and should loop.
			; Otherwise, continue normally with the updated iOBJInfo_OBJLstPtrTblOffset.
			;
			push hl
				add  hl, bc				; Seek to current OBJLst ptr
				inc  hl					; Seek to high byte of ptr (since it can't happen to be $FF for valid pointers)
				ld   a, [hl]			; Read high byte of ptr
				cp   HIGH(OBJLSTPTR_NONE); Is it $FF?
				jp   nz, .nextOk		; If not, jump (this is a valid pointer)
			.finished:
			;------------------------
				; Otherwise, reset the offset
				xor  a
				ld   [de], a			; iOBJInfo_OBJLstPtrTblOffset = 0
			pop  hl						; HL = Ptr to OBJLstPtrTable entry
			jp   OBJLstS_UpdateGFXBufInfo
			;------------------------
			.nextOk:
				dec  hl					; Seek back to the low byte of the OBJLstHdrA_* ptr		
			pop  de						; Don't pop to hl, keep the OBJLstPtrTable entry 
			
; =============== OBJLstS_UpdateGFXBufInfo ===============
; Common code for setting up the initial state of new GFX buffer info.
;
; POP BEFORE RET: 2
; IN
; - HL: OBJLstPtrTable entry to OBJLstHdrA_*
; - (SP+2): Ptr to wOBJInfo struct
OBJLstS_UpdateGFXBufInfo:
		pop  bc				; BC = Ptr to wOBJInfo struct
		
		;
		; Seek to the first byte of OBJLstHdrA_*
		;
		
		; DE = Ptr to OBJLstHdrA_*
		ld   e, [hl]
		inc  hl
		ld   d, [hl]
		inc  hl				; To second ptr
		
		; Switch pointers
		push de
		push hl
		pop  de		; DE = OBJLstPtrTable entry to OBJLstHdrB_*
		pop  hl		; HL = Ptr to OBJLstHdrA_*
		
		;
		; If this sprite mapping doesn't use the GFX buffer system, we're done.
		;
		bit  OLFB_NOBUF, [hl]			; Is the flag set?
		jp   nz, OBJLstS_CommonAnim_End	; If so, return
		
	.useBuf:
		push bc
			
			;
			; Determine if the buffer should be switched or not.
			;
			; When following animations normally, we won't get here until the other GFX buffer is fully written to (OSTB_GFXLOAD clear).
			; In that case, switch the buffers and set back the OSTB_GFXLOAD flag, saving the result back.
			;
			; However, if we got here with an incomplete buffer, keep using it, so the new GFX will be written at its start.
			; 

			; Save the original iOBJInfo_Status value to a temp location.
			ld   a, [bc]
			ld   [wOBJLstTmpStatusOld], a
			
			bit  OSTB_GFXLOAD, a		; Is the buffer ready yet?
			jp   nz, .gfxNotDone		; If not, jump
		.gfxDone:
			xor  OST_GFXBUF2			; Use other buffer
			or   a, OST_GFXLOAD			; Set loading flag
			ld   [bc], a				; Save to iOBJInfo_Status
			
			; Also save to the temp copy we're checking against to determine the buffer's VRAM ptr
			ld   [wOBJLstTmpStatusNew], a	
			jp   .getArgs
		.gfxNotDone:
			; Nothing to change here, just copy it over.
			ld   [wOBJLstTmpStatusNew], a
			
			; Invert just in case we get to .identical (by interrupting moves in a certain way).
			; wOBJLstTmpStatusOld should always point to the opposite buffer of iOBJInfo_Status.
			xor  OST_GFXBUF2			
			ld   [wOBJLstTmpStatusOld], a	
		.getArgs:
			push de						; DE = OBJLstPtrTable entry to OBJLstHdrB_*
			
				;
				; Get the data off the wOBJInfo we need later for writing to the wGFXBufInfo
				;
			
				; DE = Ptr to start of wGFXBufInfo
				push hl
					ld   hl, iOBJInfo_BufInfoPtr_Low
					add  hl, bc						; Seek to iOBJInfo_BufInfoPtr_Low
					ld   e, [hl]					; Read low byte
					inc  hl
					ld   d, [hl]					; Read high byte
				pop  hl
				
				; Seek to iOBJLstHdrA_GFXPtr_Low
				inc  hl		; Seek to iOBJLstHdrA_Byte1
				inc  hl     ; ...
				inc  hl
				
				; BC = Ptr to location in VRAM for copying tiles
				push hl
					ld   hl, iOBJInfo_VRAMPtr_Low ; Seek to iOBJInfo_VRAMPtr_Low
					add  hl, bc
					ld   c, [hl]					; Read low byte
					inc  hl
					ld   b, [hl]					; Read high byte
				pop  hl
				
				
				;
				; If we're using the second buffer, make the VRAM location point $20 tiles ahead,
				; which is the size of a single buffer.
				;
				; NOTE: If we didn't finish copying the tiles to the previous buffer,
				;       the old buffer will be used.
				;
				ld   a, [wOBJLstTmpStatusNew]
				bit  OSTB_GFXBUF2, a				; Using the second buffer?
				jp   z, .setBufInfo					; If not, skip
			.buf2:
				; B += $02
				ld   a, HIGH(TILESIZE * GFXBUF_TILECOUNT)						; BC += $0200
				add  b
				ld   b, a
				
			.setBufInfo:
			
				;
				; Write the data to the current wGFXBufInfo structure.
				;
			
				
				; VRAM destination ptr
				ld   a, c		; A = iOBJInfo_VRAMPtr_Low
				ld   [de], a	; Write to iGFXBufInfo_DestPtr_Low
				inc  de			; Seek to iGFXBufInfo_DestPtr_High
				ld   a, b		; A = iOBJInfo_VRAMPtr_High
				ld   [de], a	; Write to iGFXBufInfo_DestPtr_High
				inc  de			; Seek to iGFXBufInfo_SrcPtrA_Low
				
				; Source GFX ptr - Set A
				; HL = Source (iOBJLstHdrA_GFXPtr_Low)
				; DE = Destination (iGFXBufInfo_SrcPtrA_Low)
				call OBJLstS_CopyFarPtr
				
				;--
				
				; BC = Ptr to OBJLst - Set A
				ld   c, [hl]	; C = iOBJLstHdrA_DataPtr_Low
				inc  hl
				ld   b, [hl]	; B = iOBJLstHdrA_DataPtr_High
				
				; Tiles remaining - Set A
				; Multiplied by 2 because OBJ are always 8x16 (so 2 tiles/OBJ)
				ld   a, [bc]	; A = iOBJLst_OBJCount
				add  a, a		; A *= 2
				ld   [de], a	; iGFXBufInfo_TilesLeftA = A
				
				inc  de			; Seek to iGFXBufInfo_SrcPtrB_Low
			pop  hl 			; HL = OBJLstPtrTable entry to OBJLstHdrB_*
			
			; Source GFX ptr - Set B
			; If high byte is $FF, there's no set B and we can skip this.
			ld   c, [hl]		; BC = Ptr to OBJLstHdrB_*
			inc  hl
			ld   b, [hl]
			ld   a, b
			cp   HIGH(OBJLSTPTR_NONE)	; B != $FF?
			jp   nz, .hasSetB			; If so, jump
			
		.noSetB:
			; Otherwise, null out the Set B info.
			xor  a
			ld   [de], a	; iGFXBufInfo_SrcPtrB_Low
			inc  de
			ld   [de], a	; iGFXBufInfo_SrcPtrB_High
			inc  de
			inc  de			; Ignore iGFXBufInfo_BankB, who cares
			ld   [de], a	; iGFXBufInfo_TilesLeftB
			inc  de			; Seek to iGFXBufInfo_SetKey
			jp   .chkMatches
			
		.hasSetB:
		
			; Source GFX ptr - Set B
			push bc
			pop  hl		; HL = iOBJLstHdrB_Flags
			inc  hl		; HL = Source (iOBJLstHdrB_GFXPtr_Low)
						; DE = Destination (iGFXBufInfo_SrcPtrB_Low)
			call OBJLstS_CopyFarPtr
			
			;--
			
			; BC = Ptr to OBJLst - Set B
			ld   c, [hl]	; C = iOBJLstHdrB_DataPtr_Low
			inc  hl
			ld   b, [hl]	; B = iOBJLstHdrB_DataPtr_High
			
			; Tiles remaining - Set B
			ld   a, [bc]	; A = iOBJLst_OBJCount
			add  a, a		; A *= 2
			ld   [de], a	; iGFXBufInfo_TilesLeftB = A
			inc  de			; Seek to iGFXBufInfo_SetKey
			
		;------------------	
		.chkMatches:
		
			;
			; Check if the buffer set settings we just wrote are identical to the last one we fully applied in VBlankHandler.
			; If this is the case, treat the new frame as a continuation of this one, which also means to keep using
			; the old buffer info (and so, the old buffer flag from wOBJLstTmpStatusOld).
			;
			; A side effect of this is that the new frame will animate much faster -- since normally the game has to
			; wait for the graphics to load before decrementing the frame timer, but here the graphics are already loaded.
			;
			; Otherwise the settings identifier at iGFXBufInfo_SetKey is updated and we're done. 
			;
			
			; BC = Ptr to start of wGFXBufInfo struct
			ld   hl, -(iGFXBufInfo_SetKey-iGFXBufInfo_DestPtr_Low)
			add  hl, de
			push hl
			pop  bc
			
			; DE = Ptr to iGFXBufInfo_SetKeyOld
			ld   hl, iGFXBufInfo_SetKeyOld
			add  hl, bc
			push hl
			pop  de
			
			; HL = Ptr to iGFXBufInfo_SrcPtrA_Low
			ld   hl, iGFXBufInfo_SrcPtrA_Low
			add  hl, bc
			
			; Check if these match:
			; - iGFXBufInfo_SrcPtrA_Low  with iGFXBufInfo_SetKeyOld
			; - iGFXBufInfo_SrcPtrA_High with iGFXBufInfo_SetKeyOld+1
			; - iGFXBufInfo_BankA        with iGFXBufInfo_SetKeyOld+2
			; If they don't take the jump
REPT 3
			ld   a, [de]		; A = CompInfo byte
			cp   a, [hl]		; Does it match the source Set A info?
			jp   nz, .different	; If not, jump
			inc  de				
			inc  hl
ENDR
			inc  hl				; Skip comparing iGFXBufInfo_TilesLeftA
			
			; Check if these match:
			; - iGFXBufInfo_SrcPtrB_Low  with iGFXBufInfo_SetKeyOld+3
			; - iGFXBufInfo_SrcPtrB_High with iGFXBufInfo_SetKeyOld+4
			; - iGFXBufInfo_BankB        with iGFXBufInfo_SetKeyOld+5
			; If they don't take the jump			
REPT 2
			ld   a, [de]		; A = CompInfo byte
			cp   a, [hl]		; Does it match the source Set A info?
			jp   nz, .different	; If not, jump
			inc  de
			inc  hl
ENDR
			ld   a, [de]		; A = iGFXBufInfo_SetKeyOld+5
			cp   a, [hl]		; Does it match with iGFXBufInfo_BankB?
			jp   nz, .different	; If not, jump
			
		.identical:
			; The new settings match the old settings.
			; There's no need to double buffer this.
			
			; Wipe them out for both sets (iGFXBufInfo_SrcPtrA_Low-iGFXBufInfo_TilesLeftB)
			ld   hl, iGFXBufInfo_SrcPtrA_Low
			add  hl, bc
			xor  a
REPT 8
			ldi  [hl], a
ENDR
		pop  bc			; BC = Ptr to wOBJInfo struct
		
		
		
		;
		; Act as if we were in VBLANK and just finished copying the GFX to a buffer.
		; Except that here both player wOBJInfo slots are handled instead of having two
		; different code paths.
		; See also: VBlank_CopyPl1Tiles.move1
		;
		
		
		; Reload old copy of iOBJInfo_Status with old OSTB_GFXBUF2 flag.
		ld   a, [wOBJLstTmpStatusOld]	; Get copy of iOBJInfo_Status
		res  OSTB_GFXLOAD, a			; Mark GFX as already loaded
		set  OSTB_BIT3, a			
		ld   [bc], a
		
		;
		; The buffer info is identical if we got here so there's no need to copy the set keys,
		; but the sprite mapping info in wOBJInfo could still be different.
		;
		
		; Copy over the current wOBJInfo slot info to the old one
		
		; Copy iOBJInfo_OBJLstFlags to iOBJInfo_OBJLstFlagsOld
		ld   hl, iOBJInfo_OBJLstFlags
		add  hl, bc
		ldi  a, [hl]
		ld   [hl], a
		
		; Copy iOBJInfo_BankNum-iOBJInfo_OBJLstPtrTblOffset to the old fields
		ld   hl, iOBJInfo_BankNum	; DE = iOBJInfo_BankNum
		add  hl, bc					
		push hl
		pop  de
		ld   hl, iOBJInfo_BankNumOld	; BC = iOBJInfo_BankNumOld
		add  hl, bc
REPT 4
		ld   a, [de]				; Read from current data
		ldi  [hl], a				; Write to old data
		inc  de						; 
ENDR
		jp   OBJLstS_CommonAnim_End
		
		.different:
			; BC = Ptr to iGFXBufInfo_DestPtr_Low
			
			;
			; Update the current settings identifier (iGFXBufInfo_SetKey) by copying over the untouched Set settings we just wrote.
			;
			
			ld   hl, iGFXBufInfo_SetKey	; DE = iGFXBufInfo_SetKey
			add  hl, bc
			push hl
			pop  de
			ld   hl, iGFXBufInfo_SrcPtrA_Low	; HL = iGFXBufInfo_SrcPtrA_Low
			add  hl, bc
			
			; iGFXBufInfo_SrcPtrA_Low  -> iGFXBufInfo_SetKey
			; iGFXBufInfo_SrcPtrA_High -> iGFXBufInfo_SetKey+1
			; iGFXBufInfo_BankA        -> iGFXBufInfo_SetKey+2
REPT 3
			ldi  a, [hl]
			ld   [de], a
			inc  de
ENDR
			inc  hl
			
			; iGFXBufInfo_SrcPtrB_Low  with iGFXBufInfo_SetKey+3
			; iGFXBufInfo_SrcPtrB_High with iGFXBufInfo_SetKey+4
			; iGFXBufInfo_BankB        with iGFXBufInfo_SetKey+5
REPT 2
			ldi  a, [hl]
			ld   [de], a
			inc  de
ENDR
			ld   a, [hl]
			ld   [de], a
		pop  bc
		
	OBJLstS_CommonAnim_End:
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret

; =============== OBJLstS_CopyFarPtr ===============
; Copies a "dp" far pointer.
; IN
; - HL: Source dp
; - DE: Destination dp
OBJLstS_CopyFarPtr:
REPT 3
	ldi  a, [hl]	; Read from HL
	ld   [de], a	; Copy to DL
	inc  de			; Next
ENDR
	ret

; =============== OBJLstS_InitFrom ===============
; Initializes an wOBJInfo structure.
; - HL: Ptr to start of wOBJInfo struct (destination)
; - DE: Ptr to wOBJInfo data (source)
OBJLstS_InitFrom:
	; Copy the first $1F bytes over, which are the main fields
	ld   b, iOBJInfo_RangeMoveAmount
.loopCp:
	ld   a, [de]				; Read from ROM
	inc  de						; SrcPtr++
	ldi  [hl], a				; Write to RAM, DestPtr++
	dec  b						; Copied all bytes?
	jr   nz, .loopCp			; If not, loop
	
	; Clear bytes $1F-$33
	ld   b, $14
	xor  a
.loopClr:
	ldi  [hl], a
	dec  b
	jr   nz, .loopClr
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
	
; =============== CopyBGToRectWithBase ===============
; Copies a partial tilemap to a location in VRAM,
; with tile IDs offset by the specified value.
; IN
; - DE: Ptr to uncompressed tilemap
; - HL: Destination Ptr in VRAM
; - B: Rect Width
; - C: Rect Height
; - A: Tile ID base offset
CopyBGToRectWithBase:
	push bc			; Save height
		push hl			; Save tilemap ptr
		
		.rowLoop:
			push bc			; Save width
				push af			; Save tile ID base
					push af
						ld   a, [de]	; B = Relative tile ID
						ld   b, a
					pop  af
					
					add  b			; A = tile ID base + relative tile ID
					inc  de			; Next tile in tilemap
					
					push af			
					mWaitForHBlank	; In case we're calling it in the middle of the frame
					pop  af
					
					ldi  [hl], a
				pop  af 		; Restore tile ID base
			pop  bc			; Restore width
			dec  b				; Printed all tiles in the row?
			jp   nz, .rowLoop	; If not, jump
			
		pop  hl					; Rewind ptr to initial X value
		ld   bc, BG_TILECOUNT_H	; Move down by 1 tile
		add  hl, bc
	pop  bc			; Restore height
	dec  c							; Printed all rows?
	jr   nz, CopyBGToRectWithBase	; If not, jump
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
	
; =============== FillBGRect ===============
; Draws a rectangle in the tilemap.
; IN
; - HL: Destination tilemap ptr (top left corner of rectangle)
; - B: Rect Width
; - C: Rect Height
; - D: Tile ID to use, generally a completely white or black tile
FillBGRect:
	ld   a, d					
.loopV:
	push bc
		push hl
		.loopH:
			push af				; Write the tile during HBlank
				mWaitForHBlank
			pop  af
			ldi  [hl], a
			dec  b				; Filled the row?
			jp   nz, .loopH		; If not, loop
		pop  hl					; Restore starting row position
		ld   bc, BG_TILECOUNT_H	; Move down 1 row
		add  hl, bc
	pop  bc
	dec  c				; Filled all rows?
	jr   nz, .loopV		; If not, loop
	ret
	
; =============== FillGFX / FillBGStripPair ===============
; Writes the specified number of tiles to the GFX area consting of the same line pattern repeated vertically.
; This is also reused to draw continuous strips in the tilemap alternating between two tile IDs.
;       
; IN (FillGFX)
; - DE: Ptr to GFX in VRAM
; - B: Number of tiles to overwrite
; - HL: 2bpp Line to repeat across the tiles.
;
; IN (FillBGStripPair)
; - DE: Destination tilemap ptr (top left corner of rectangle)
; - B: Width multiplier. Multiply by $10 for the effective width.
; - H: Tile ID 1 to use
; - L: Tile ID 2 to use
FillGFX:
FillBGStripPair:
	push bc
		; Write a full tile / Write $10 tiles horizontally
		ld   b, TILESIZE / 2
	.loopH:
		; Write tile H to DE
		mWaitForHBlank
		ld   a, h
		ld   [de], a
		inc  de	
		; Write tile L to DE
		mWaitForHBlank
		ld   a, l
		ld   [de], a
		inc  de
		
		dec  b				; Finished overwriting the tile? / Filled the $10 tile strip?
		jp   nz, .loopH		; If not, loop
	pop  bc
	dec  b						; Are we done repeating it?
	jp   nz, FillBGStripPair	; If not, loop
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

; =============== CopyTilesHBlank ===============
; Tile copy function during HBlank.
; IN
; - HL: Ptr to uncompressed GFX
; - DE: Ptr to destination in VRAM
; -  B: Number of tiles to copy
CopyTilesHBlank:;
	push bc
		ld   b, TILESIZE		; B = Bytes in tile
	.loop:
		mWaitForHBlank
		ldi  a, [hl]			; Read byte, SourcePtr++
		ld   [de], a			; Copy it over
		inc  de					; DestPtr++
		dec  b					; Copied all bytes in the tile?
		jp   nz, .loop			; If not, loop
	pop  bc
	dec  b						; Copied all tiles?
	jp   nz, CopyTilesHBlank	; If not, loop
	ret
	
L000E94: db $5E;X
L000E95: db $23;X
L000E96: db $56;X
L000E97: db $23;X
; =============== CopyTilesOver ===============
; Draws a transparent GFX on top of an existing one.
;
; IN
; - HL: Ptr to GFX to copy over
; - BC: Ptr to GFX with transparency mask
; - DE: Ptr to destination in VRAM.
CopyTilesOver:
	; The GFXDef structure starts with the number of tiles to process
	ld   a, [hl]			; A = Number of tiles
	inc  hl
	; Fall-through
; =============== CopyTilesOver_Custom ===============
; IN
; - HL: Ptr to GFX to copy over
; - BC: Ptr to GFX with transparency mask
; - DE: Ptr to destination in VRAM.
; - A: Number of tiles
CopyTilesOver_Custom:

	;
	; Apply the transparency mask.
	;
	; The transparency mask is simply a 2bpp GFX which marks with set/black pixels (0b11)
	; the portion of the original GFX to keep.
	;
	; Since all of these graphics are already in 2bpp format, there's no conversion
	; involved, just a straight AND operation to remove all of the bits not set in the mask.
	;
	push af
		push de
			push hl
				;--
				push bc				; HL = BC
				pop  hl
			.nextTile:
				push af				; Save tiles remaining
					ld   a, TILESIZE	; A = Bytes remaining in tile
				.tileLoop:
					push af				; Save bytes left
						
						ld   a, [de]	; Read GFX from VRAM
						and  a, [hl]	; Filter with mask
						ld   [de], a	; Save back
						inc  de			; Next byte in VRAM
						inc  hl			; Next byte in mask
					pop  af				; A = Bytes left
					dec  a				; Masked all bytes in the tile?
					jp   nz, .tileLoop	; If not, loop
				pop  af				; Restore tiles remaining
				dec  a				; Masked all tiles?
				jp   nz, .nextTile	; If not, loop
				;--
			pop  hl
		pop  de
	pop  af
	
	;
	; Apply the actual GFX now that the transparency mask cleared away pixels.
	; This is the same as the above, except this other graphic is OR'd over.
	;
	; The new GFX shouldn't have pixels in the transparent area.
	;
.nextOrTile:
	push af					; Save tiles remaining
		ld   a, TILESIZE		; A = Bytes remaining in tile
	.tileOrLoop:
		push af					; Save bytes left
			ld   a, [de]		; Read GFX from VRAM
			or   a, [hl]		; Merge with new graphic over
			ld   [de], a		; Save back
			inc  de				; Next byte in VRAM
			inc  hl				; Next byte in new GFX
		pop  af					; A = Bytes left
		dec  a					; Processed all bytes in the tile?
		jp   nz, .tileOrLoop	; If not, loop
	pop  af					; Restore tiles remaining
	dec  a					; Processed all tiles?
	jp   nz, .nextOrTile	; If not, loop
	ret
	
L000EC9: db $5E;X
L000ECA: db $23;X
L000ECB: db $56;X
L000ECC: db $23;X
L000ECD: db $46;X
L000ECE: db $23;X
; =============== CopyTilesHBlankFlipX ===============
; Copies graphics to VRAM and flips them horizontally.
;
; This doesn't change their order, so when incrementing tilemaps are used,
; a special subroutine for updating the tilemap may be needed.
;
; IN
; - HL: Ptr to source GFX in ROM
; - DE: Ptr to destination in VRAM
; - B: Number of tiles
CopyTilesHBlankFlipX:
	push bc	; Save TileCount
		ld   b, TILESIZE	; B = Bytes in a tile
	.loop:
		push bc				; Save B
			
			ld   b, $00		
			ld   c, [hl]		; BC = Source GFX
			inc  hl				; SrcPtr++
			call .flipX			; Flip it
			ld   a, b
			
			push af
			mWaitForHBlank
			pop  af
			
			ld   [de], a	; Write the byte to VRAM
			inc  de			; DestPtr++
		pop  bc				; Restore B
		dec  b				; Fully copied the tile?
		jp   nz, .loop		; If not, loop
	pop  bc	; Restore TileCount
	dec  b				; Copied all tiles?
	jp   nz, CopyTilesHBlankFlipX	; If not, loop
	ret
	
; =============== .flipX ===============
; Flips an half-plane (1bpp) line horizontally.
; IN
; - BC: Original GFX byte
; OUT
; - B: X flipped GFX byte
.flipX:
	ldh  a, [hROMBank]
	push af
		ld   a, BANK(GFXS_XFlipTbl) ; BANK $1F
		ld   [MBC1RomBank], a
		ldh  [hROMBank], a
		push hl
			ld   hl, GFXS_XFlipTbl	; HL = Start conversion table
			add  hl, bc				; Index it
			ld   b, [hl]			; B = Flipped line
		pop  hl
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret
; =============== DecompressLZSS ===============
; Decompresses data (usually GFX) to the specified location in memory.
; The compression used appears to be based off the public domain code "lzss.c".
;
; NOTE
;   Due to how the compression works, it may write some garbage padding bytes at the end.
;   Because the game decompresses to a buffer and then copies a fixed amount of tiles from
;   that buffer to VRAM, this isn't an issue normally.
;   Care must be taken if the middleman is cut out.
;
; IN
; - DE: Ptr to decompression buffer
; - HL: Ptr to compressed graphics
; OUT
; -  B: Number of uncompressed tiles written to the buffer.
;       Ignore if not decompressing GFX.
DecompressLZSS:
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
	
; =============== SGB_PrepareSoundPacketA ===============
; Sets up the SGB packet to play a sound ID from Set A.
; IN
; - H: Sound Effect A ID
; - L: Sound Effect Attributes
SGB_PrepareSoundPacketA:
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
		inc  hl							
		
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
	
; =============== SGB_PrepareSoundPacketB ===============
; Sets up the SGB packet to play a sound ID from Set B.
; See also: SGB_PrepareSoundPacketA
; IN
; - H: Sound Effect B ID
; - L: Sound Effect Attributes
SGB_PrepareSoundPacketB:
	ld   a, [wMisc_C025]
	bit  MISCB_IS_SGB, a	; In SGB mode?
	jp   z, .end			; If not, return
	push bc
	push de
		push hl				; BC = HL
		pop  bc
		

		; C = Attributes for Sound Effect B
		ld   a, $0F				
		and  c
		swap a				; Move the nybble from low to high (the low nybble is for Sound Effect A)
		ld   c, a
		
		;
		; byte0 - command id + packet count
		;
		; (already written in HomeCall_Sound_Init)
		
		
		
		;
		; byte1 - Sound Effect A (always $00)
		;
		ld   hl, wSGBSoundPacket+1		
		ld   [hl], $00
		inc  hl							
		
		;
		; byte2 - Sound Effect B
		;
		ld   [hl], b					; Write out		
		inc  hl
		
		;
		; byte3 - Attributes
		;
		; Preserve whatever is already there involving Sound Effect *A*.
		; Simply replace the *high* nybble with the updated attributes.
		ld   a, [hl]
		and  a, $0F				; Preserve A
		or   c					; Merge B
		ld   [hl], a
		
		; Request later packet transfer
		ld   a, $01
		ld   [wSGBSendPacketAtFrameEnd], a
	pop  de
	pop  bc
.end:
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
	
; =============== JoyKeys_Get ===============
; Gets the joypad input for the player.
JoyKeys_Get:
	ld   a, [wMisc_C025]
	bit  MISCB_IS_SGB, a			; Running in SGB mode?
	jp   nz, JoyKeys_Get_SGB		; If so, grab inputs for both players
	ld   hl, hJoyKeys				; For later
	ld   a, [wSerialPlayerId]
	and  a							; Playing in VS mode?
	jr   nz, JoyKeys_Get_Serial		; If so, jump
	
; =============== JoyKeys_Get_Standard ===============
; Gets the DMG joypad input for a player.
; IN
; - HL: Ptr to existing joypad input
JoyKeys_Get_Standard:
	; D = Keys not held
	ld   a, [hl]			
	cpl						
	ld   d, a					
	
	; Get the directional key status
	ld   a, HKEY_SEL_DPAD
	ldh  [rJOYP], a
	ldh  a, [rJOYP]			; Stabilize the inputs
	ldh  a, [rJOYP]
	and  a, $0F				; ----DULR | Only use the actual keypress values (stored in the lower nybble)
	ld   c, a				; Save to C
	
	; Reset (Not necessary?)
	ld   a, HKEY_SEL_BTN|HKEY_SEL_DPAD 
	ldh  [rJOYP], a
	
	; Get the button status
	ld   a, HKEY_SEL_BTN
	ldh  [rJOYP], a
	ldh  a, [rJOYP]		; Stabilize the inputs
	ldh  a, [rJOYP]
	ldh  a, [rJOYP]
	ldh  a, [rJOYP]
	ldh  a, [rJOYP]
	ldh  a, [rJOYP]
	and  a, $0F			; ----SCBA
	
	; Merge the nybbles and mungle them
	swap a				; Move to upper nybble
	or   a, c			; Merge with other: 
						; This creates this bitmask: SCBADULR
	cpl					; Reverse the bits as the hardware marks pressed keys as '0'. We need the opposite.
	
	; Save the result
	ldi  [hl], a		; Write it to hJoyKeys
	and  d				; hJoyNewKeys = hJoyKeys & D
	ld   [hl], a		; Write it to hJoyNewKeys
	; Reset
	ld   a, HKEY_SEL_BTN|HKEY_SEL_DPAD
	ldh  [rJOYP], a
	ret
	
; =============== JoyKeys_Get_Serial ===============
; Handles the joypad reader in serial mode.
;
; HOW IT WORKS
;
; Two buffers with looping indexes keep track of the player inputs 
; sent to the other player (current player) and those received through serial (other player);
;
; Input lifetime:
; - Frame 0, VBLANK
;  - Input is polled the standard way and stored in wSerialPendingJoyKeys*
;  - wSerialPendingJoyKeys is written to the head of the send buffer
;  - (Master Only) A transfer starts of what's currently currently in rSB (previous frame inputs).
;                  The slave is expected to have the same thing set in rSB when this happens.
; - Frame 0, INT
;  - The contents of rSB are stored to the head of the receive buffer.
;      Note how there's an inconsistency here:
;      - The head of the receive buffer has info for the other player's *previous* frame
;      - The head of the send buffer has info for this player's *current* frame.
;      This results in the tail index for the send buffer being set further back.
;  - The head of the send buffer (current input) is written to rSB
;  - The head index is increased
; - Frame 1, VBLANK
;  - (input for previous frame is processed)
; - Frame 1, INT
;  - Done like last time, now with the received input we need
; - Frame 2, VBLANK
;  - The value at the tail of the send buffer is copied to the current player's hJoyKeys*
;  - The value at the tail of the receive buffer is copied to the other player's hJoyKeys*
;  - Both tail indexes are increased
;
; Additionally, the head indexes always point to a free slot, so the tail indexes (used for active inputs) are at least offset by 1.
; As a result, the buffer indexes are set so that:
; - Send buffer tail is 2 values before the head
; - Receive buffer tail is 1 value before the head
;
; IN
; - A: Player ID
JoyKeys_Get_Serial:
	ld   c, a
		ld   a, [wSerialInputMode]
		and  a							; Do we allow input?
		ret  z							; If not, return
	ld   a, c
	
	; Depending on the player side, pick the correct current/remote addresses
	ld   de, hJoyKeys				; P1 Side - Current GB
	ld   hl, wSerialPendingJoyKeys 	; P1 Side - Other GB
	cp   a, SERIAL_PL1_ID			; Are we playing on the 1P side?
	jr   z, .go						; If so, jump
	ld   hl, wSerialPendingJoyKeys2	; P2 Side - Other GB
	ld   de, hJoyKeys2				; P2 Side - Current GB
.go:

	;
	; [Frame 2]
	; Get the active input for this GB.
	;

	; C = Keys not currently held on *this frame*
	ld   a, [de]			
	cpl						
	ld   c, a	
	
	; A = Held input at the tail value of the send buffer
	push de
		push hl
			; Get index to the buffer
			ld   a, [wSerialDataSendBufferIndex_Tail]
			ld   e, a									
			; Save back an incremented copy
			inc  a										; Index++
			and  a, $7F									; Size of buffer, cyles back
			ld   [wSerialDataSendBufferIndex_Tail], a	; Save the updated index
			
			; Index the buffer of sent inputs and read out its value.
			xor  a
			ld   d, a
			ld   hl, wSerialDataSendBuffer		; HL = Table
			add  hl, de							; Offset it
			ld   a, [hl]						; A = Buffer entry
			ld   [hl], $00						; Clear what was here
			
			; Decrement the counter/balance of remaining bytes to process.
			ld   hl, wSerialSentLeft
			dec  [hl]			
		pop  hl
	pop  de
	
	; Set hJoyKeys
	ld   [de], a
	inc  de		
	
	; Set hJoyNewKeys.
	; Unlike the normal joypad handler, this has the keys *RELEASED* in the last 2 frames set
	and  c					
	ld   [de], a
	
	;--
	
	;
	; [Frame 0] Poll for input to wSerialPendingJoyKeys*
	;
	call JoyKeys_Get_Standard
	
	; Part 2
	call JoyKeys_Serial_GetActiveOtherInput
	ret  
	
; =============== JoyKeys_Get_SGB ===============
; Gets input for both players through the SGB (through the joypad registers, that is).
; This is almost the same as JoyKeys_Get_Standard.
JoyKeys_Get_SGB:

	; Cycle to first controller, prepare for controller ID read
	ld   a, HKEY_SEL_BTN|HKEY_SEL_DPAD 
	ldh  [rJOYP], a
	
	ld   b, $02			; B = Joy count
.loop:
	; Pick the target address for storing the joypad info, depending on the controller ID.
	; On the first run, write PL1 info from hJoyKeys.
	; On the the second, write PL2 info from hJoyKeys2.
	
	ld   hl, hJoyKeys		
	ldh  a, [rJOYP]			; Read controller ID
	and  a, $01				; ID % 2 != 0? (will match != $*E)
	jr   nz, .go			; If so, jump (this is pad 1)
	ld   hl, hJoyKeys2		; Otherwise, this is pad 2
.go:

	; D = Keys not held
	ld   a, [hl]			
	cpl						
	ld   d, a					
	
	; Get the directional key status
	ld   a, HKEY_SEL_DPAD
	ldh  [rJOYP], a
	ldh  a, [rJOYP]			; Stabilize the inputs
	ldh  a, [rJOYP]
	and  a, $0F				; ----DULR | Only use the actual keypress values (stored in the lower nybble)
	ld   c, a				; Save to C
	
	; Reset (Not necessary?)
	ld   a, HKEY_SEL_BTN|HKEY_SEL_DPAD 
	ldh  [rJOYP], a
	
	; Get the button status
	ld   a, HKEY_SEL_BTN
	ldh  [rJOYP], a
	ldh  a, [rJOYP]		; Stabilize the inputs
	ldh  a, [rJOYP]
	ldh  a, [rJOYP]
	ldh  a, [rJOYP]
	ldh  a, [rJOYP]
	ldh  a, [rJOYP]
	and  a, $0F			; ----SCBA
	
	; Merge the nybbles and mungle them
	swap a				; Move to upper nybble
	or   a, c			; Merge with other: 
						; This creates this bitmask: SCBADULR
	cpl					; Reverse the bits as the hardware marks pressed keys as '0'. We need the opposite.
	
	; Save the result
	ldi  [hl], a		; Write it to hJoyKeys
	and  d				; hJoyNewKeys = hJoyKeys & D
	ld   [hl], a		; Write it to hJoyNewKeys
	
	; Reset + Cycle to next controller
	ld   a, HKEY_SEL_BTN|HKEY_SEL_DPAD
	ldh  [rJOYP], a
	
	dec  b				; JoyLeft--
	jp   nz, .loop	; All pads red? If not, loop
	ret
	
; =============== JoyKeys_DoCursorDelayTimer ===============
; Handles the cursor movement delay timers, used to determine when to move the cursor.
JoyKeys_DoCursorDelayTimer:
	ld   hl, hJoyKeys
	call .calcInfo
	ld   hl, hJoyKeys2
	call .calcInfo
	ret
	
; =============== .calcInfo ===============
; IN
; - HL: Ptr to hJoyKeys*
.calcInfo:
	ld   d, [hl]	; D = hJoyKeys
	
	; Seek to hJoyKeysDelayTbl
	inc  hl			
	inc  hl			
	inc  hl			
	
	; For each KEY_* value, calculate this information, going from MSB to bit 0.
	
	ld   e, $08		; E = Bits in byte
.nextPair:

	;
	; Each entry in the hJoyKeysDelayTbl array is 2 bytes large.
	;
	; 0 -> Marks if the KEY_* value is pressed.
	;      Separated in two nybbles, with the low one containing the current info
	;      and the high one info for the previous frame.
	;      Split like this to easily determine when we just started holding a key without juggling hJoyNewKeys.
	;
	; 1 -> Countdown timer.
	;      This is set to $11 when we start holding a key, then to $06 once it reaches $00.
	;      When it reaches $00, the upper nybble of byte0 is unmarked by setting the byte to $01,
	;      which tells Title_GetMenuInput to treat the input as held.
	;      

	ld   b, [hl]	; B = Marker (byte0)
	inc  hl			; 
	ld   c, [hl]	; C = Timer (byte1)
	dec  hl			; Seek back to byte0
	
	; Move the existing keypress marker to the upper nybble.
	; If what we had here was $01 and that gets shifted to the upper nybble, it will cause
	; Title_GetMenuInput to ignore the key unless it gets set to $01 by the time we exit this function.
	sla  b		; B << 4
	sla  b
	sla  b
	sla  b
	
	; Check if the current key was pressed.
	; If not, the lower nybble will be kept at 0, and next time we get here it will be pushed out.
	rlc  d			; Push KEY_* to carry
	jp   nc, .save	; Is the bit set? If not, jump
.press:
	set  0, b		; Mark the key as presssed
	
	; Check if we just started holding a key.
	; If not, A will be $11 when we get here.
	ld   a, b
	cp   $01			; Marker == $01? (just started)
	jp   nz, .decTimer	; If not, jump
.initTimer:
	; Set the initial delay to $11 frames.
	ld   c, $11			
	jp   .save
	
.decTimer:

	; Decrement the key timer.
	; If it reaches 0, reset it.
	dec  c				; Timer--
	jp   nz, .save		; Timer == 0? If not, jump
.resetTimerNext:
	; Set the delay to $06 frames
	ld   b, $01			; Treat input as held
	ld   c, $06
	;--
.save:
	ld   [hl], b		; Save back key marker
	inc  hl
	ld   [hl], c		; Save back timer
	inc  hl				; Seek to next entry in delay table
	dec  e				; Processed all bits?
	jp   nz, .nextPair	; If not, loop
	ret
; =============== Rand ===============
; Random generator without using cycles.
; OUT
; - A: Random number
Rand:
	; wRand += wTimer + (wRand * 5) + 1
	push bc
		ld   a, [wRand]		; A = wRand
		ld   b, a			; B = wRand
		sla  a				; A *= 4
		sla  a
		add  b				; A += B + 1
		inc  a
		ld   b, a			; B = A
		ld   a, [wTimer]	; A = wTimer + B
		add  b
		ld   [wRand], a		; wRand = A
	pop  bc
	ret
; =============== RandLY ===============
; Random generator using cycles.
; OUT
; - A: Random number
RandLY:
	; wRandLY += wTimer + (wRandLY * 5) + rLY + 1 
	push bc
		ld   a, [wRandLY]	; A = wRand
		ld   b, a			; B = wRand
		sla  a				; A *= 4
		sla  a
		add  b				; A += B + 1
		inc  a
		ld   b, a			; B = A
		ld   a, [wTimer]	; A = wTimer + B
		add  b	
		;--
		ld   b, a			; B = A
		ldh  a, [rLY]		; wRand = B + rLY 
		add  b
		;--
		ld   [wRandLY], a
	pop  bc
	ret
; =============== LoadGFX_1bppFont_Default ===============
; Loads the font GFX with default settings.
LoadGFX_1bppFont_Default:
	ldh  a, [hROMBank]
	push af
	ld   a, BANK(FontDef_Default) ; BANK $1D
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ld   hl, FontDef_Default
	call LoadGFX_1bppFont
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret
; =============== LoadGFX_Unused_1bppFontCustomCol ===============	
; Loads the font GFX with custom palette settings.
; [TCRF] Unused ???
; IN
; - D: Color to map to bit0
; - E: Color to map to bit1
L0011B5:
	ldh  a, [hROMBank]
	push af
	ld   a, BANK(FontDef_Default) ; BANK $1D
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ld   hl, FontDef_Default
	
	; Apply mapped colors
	ld   a, d
	ld   [wFontLoadBit0Col], a
	ld   a, e
	ld   [wFontLoadBit1Col], a
	
	; Read the header out
	
	; DE = Destination ptr in VRAM
	ld   e, [hl]
	inc  hl
	ld   d, [hl]
	inc  hl
	; B = Number of tiles to copy
	ld   b, [hl]
	inc  hl
	; Skip color map entries
	inc  hl
	inc  hl
	
	; Continue normally
	call LoadGFX_1bppFont.tileLoop
	
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret  
	
; =============== LoadGFX_Unused_1bppFontCustomAddr ===============
; Loads the font GFX at a custom location.
; [TCRF] Unused ???
; IN
; - DE: Destination ptr in VRAM
; -  B: Number of tiles to copy
L0011DC:
	ldh  a, [hROMBank]
	push af
	ld   a, BANK(FontDef_Default.col) ; BANK $1D
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ld   hl, FontDef_Default.col
	call LoadGFX_1bppFont.fromColDef
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret 

; =============== LoadGFX_1bppFont ===============
; Loads the font graphics depending on the specified settings.
;
; IN
; - HL: Ptr to font settings
LoadGFX_1bppFont:

	;
	; Before the font data there's a header with a few settings.
	; Some of the settings can be overridden by calling alternate wrappers to
	; this function (which don't seem to be used anyway...)
	;
	
	
	; Read the header out

	; DE = Destination ptr in VRAM
	; In practice always $9000
	ld   e, [hl]
	inc  hl
	ld   d, [hl]
	inc  hl
	; B = Number of tiles to copy
	; In practice always $80, which fills the $9000-$9800 area
	ld   b, [hl]
	inc  hl
.fromColDef:
	; wFontLoadBit0Col = bit0 color map
	ldi  a, [hl]		
	ld   [wFontLoadBit0Col], a
	; wFontLoadBit1Col = bit1 color map
	ldi  a, [hl]
	ld   [wFontLoadBit1Col], a
	
.tileLoop:
	;
	; The font graphics are stored in 1bbp inside the ROM.
	; Convert them to 2bpp with the specified color values.
	;
	
	push bc
		ld   b, TILE_V		; B = Number of lines in a tile
	.lineLoop:
		; Clear 2 byte buffer for a line of pixels, which is the smallest size
		; we can work with due to bit interleaving.
		xor  a
		ld   [wFontLoadTmpGFX], a
		ld   [wFontLoadTmpGFX+1], a
		push bc
			ldi  a, [hl]		; Read 1bpp color entry
			
			; For each bit, apply a 2bpp color.
			; Start from bit0 and move up by rotating the 1bpp entry right.
			; The rotation guarantees that the current processed bit is always at bit0 of A.
			;
			; There also a mask at C which gets shifted left, and is used to apply bits to the 2bpp entries.
			
			ld   b, $08			; B = Bits left
			ld   c, $01			; C = Mask to apply current bit
		.bitLoop:
		
			; Map the 1bpp color to a 2bpp color.
			; Depending on the lowest bit in the GFX byte, pick a different color value
			rrca							; Get lowest bit + rotate others right
			jr   c, .useCol1				; Was that bit set (C flag set)? If so, jump
			;--
		.useCol0:		
			push af							
				ld   a, [wFontLoadBit0Col]	; Map to wFontLoadBit0Col color
				call .mapCol
				jp   .colDone
				
		.useCol1:
			push af
				ld   a, [wFontLoadBit1Col]	; Map to wFontLoadBit1Col color
				call .mapCol
		.colDone:
			pop  af							
			;--
			
			rlc  c							; C << 1
			dec  b							; All bits processed?
			jr   nz, .bitLoop				; If not, loop
			
			; Write over the two temporary tiles
			mWaitForVBlankOrHBlank
			ld   a, [wFontLoadTmpGFX]
			ld   [de], a
			inc  de
			mWaitForVBlankOrHBlank
			ld   a, [wFontLoadTmpGFX+1]
			ld   [de], a
			inc  de
			
		pop  bc			
		dec  b				; Processed all lines in the tile?
		jr   nz, .lineLoop	; If not, loop
	pop  bc				
	dec  b					; Processed all tiles?
	jr   nz, .tileLoop		; If not, loop
	ret
	
; =============== .mapCol ===============
; Converts a 1bpp color value to a 2bpp color.
; IN
; - A: 2bpp COL_* value (0-3)
; - C: Bitmask with current bit to process in both bytes, never $00
.mapCol:
	; The 2 bits of the color index are split across two bytes.
	; Split them into those two bytes at the same bit number.
	
	; 0 | %00 | wFontLoadTmpGFX = 0, wFontLoadTmpGFX+1 = 0
	; 1 | %01 | wFontLoadTmpGFX = 1, wFontLoadTmpGFX+1 = 0
	; 2 | %10 | wFontLoadTmpGFX = 0, wFontLoadTmpGFX+1 = 1
	; 3 | %11 | wFontLoadTmpGFX = 1, wFontLoadTmpGFX+1 = 1

	; Put the low bit into the first byte.
	bit  0, a					; Is the low bit set?
	jr   z, .other				; If not, skip
	push af
	ld   a, [wFontLoadTmpGFX]	; Otherwise, apply bit
	or   a, c
	ld   [wFontLoadTmpGFX], a
	pop  af
.other:
	; Put the high bit into the second byte
	bit  1, a					; Is the high bit set?
	jr   z, .end				; If not, skip
	ld   a, [wFontLoadTmpGFX+1]	; Otherwise, apply bit
	or   a, c
	ld   [wFontLoadTmpGFX+1], a
.end:
	ret
	
; =============== TextPrinter_Instant ===============
; Instantly prints a string to the screen.
; Note that newlines aren't supported for string printed this way.
; IN
; - HL: Ptr to TextDef structure
TextPrinter_Instant:
	; DE = Tilemap ptr
	ld   e, [hl]
	inc  hl
	ld   d, [hl]
	inc  hl
; =============== TextPrinter_Instant_CustomPos ===============
; IN
; - HL: Ptr to string length field of TextDef structure
; - DE: Tilemap ptr (Destination)
TextPrinter_Instant_CustomPos:
	; B = String length
	ld   b, [hl]
	inc  hl
.loop:
	push bc
		ldi  a, [hl]			; A = Letter
		push hl
			; Convert letter to tile ID
			ld   hl, TextPrinter_CharsetToTileTbl	
			ld   c, a								; C = Letter
			call TextPrinter_GetTileIdFromLetter	; B = Tile ID
			
			; Write it out to the tilemap
			mWaitForVBlankOrHBlank
			ld   a, b
			ld   [de], a
			inc  de			; Move right in tilemap
		pop  hl
	pop  bc
	dec  b				; All letters printed?
	jr   nz, .loop		; If not, loop
	ret
	
; =============== TextPrinter_GetTileIdFromLetter ===============
; Converts the character text to the correct tile ID.
; Note that the latin alphabet are stored in their proper locations, though
; there's also a subset of Japanese characters.
; IN
; - HL: Ptr to conversion table
; - C: Letter from string
; OUT
; - B: Tile ID
TextPrinter_GetTileIdFromLetter:
	; B = TextPrinter_CharsetToTileTbl[C]
	ldh  a, [hROMBank]
	push af
	ld   a, BANK(TextPrinter_CharsetToTileTbl) ; BANK $1F
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ld   b, $00			; BC = C
	add  hl, bc
	ld   b, [hl]		; Read it out
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret
	
; =============== NumberPrinter_Instant ===============	
; Instantly prints an hex number to the screen.
; IN
; - A: Number in hex format
; - C: Tile ID offset ($00 for the standard font)
; - DE: Tilemap ptr
NumberPrinter_Instant:
	; Digit in the upper nybble first
	push af
		swap a
		and  a, $0F
		call .writeDigit
	pop  af
	; Then the lower one
	and  a, $0F
	call .writeDigit
	ret
	
; =============== .writeDigit ===============
; *DE = TextPrinter_DigitToTileTbl[A] + C
; IN
; - A: Digit (0-F)
; - C: Tile ID offset
; - DE: Tilemap ptr
.writeDigit:
	; Convert letter to tile ID using an alternate charmap
	push bc
		ld   hl, TextPrinter_DigitToTileTbl
		ld   c, a
		call TextPrinter_GetTileIdFromLetter
		ld   a, b
	pop  bc
	
	; Offset the tile ID if necessary.
	; ??? TODO VERIFY. This is necessary in case the normal 1bpp font isn't loaded,
	; with the numbers having different tile IDs.	
	add  c
	
	; Write it to the tilemap
	ld   b, a
	mWaitForVBlankOrHBlank
	ld   a, b
	ld   [de], a
	inc  de
	ret
	
; =============== TextPrinter_MultiFrameFar ===============
; Wrapper for TextPrinter_MultiFrame for printing text stored in an arbitrary bank.
; IN
; - HL: Ptr to TextDef structure
; - B: Bank number of TextDef structure
; - C: Delay between letter printing
; - A: Flags (TXTB_*)
TextPrinter_MultiFrameFar:
	push af						; Save all args
	push bc
	push de
	
	ld   [wTextPrintFlags], a	; Set flags
	ldh  a, [hROMBank]			; Save cur bank
	push af
	ld   a, b					; Switch to bank with TextDef
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	
	ld   e, [hl]				; DE = Tilemap ptr ptr
	inc  hl
	ld   d, [hl]
	inc  hl
	jp   TextPrinter_MultiFrame
	
; =============== TextPrinter_MultiFrameFarCustomPos ===============
; Wrapper for TextPrinter_MultiFrame for printing text stored in an arbitrary bank
; starting at a custom tilemap offset.
; IN
; - HL: Ptr to string length field of TextDef structure
; - B: Bank number of TextDef structure
; - C: Delay between letter printing
; - wTextPrintFlags: Option flags
TextPrinter_MultiFrameFarCustomPos:
	push af						; Save all args
	push bc
	push de
	ld   [wTextPrintFlags], a	; Set flags
	ldh  a, [hROMBank]			; Save cur bank
	push af
	ld   a, b					; Switch to bank with TextDef
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
; =============== TextPrinter_MultiFrame ===============
; Prints a string across multiple frames, taking exclusive control of the current task until it finishes.
;
; 4 stack values must be popped out to preserve the registers before returning.
;
; IN
; - HL: Ptr to string length field of TextDef structure
; - DE: Ptr to tilemap (Destination)
; - C: Delay between letter printing
; - wTextPrintFlags: Option flags
TextPrinter_MultiFrame:
	ld   a, c			; A = Delay
	ld   b, [hl]		; B = String length
	inc  hl				; Next byte
.loop:
	; In this first part inside the "push af", write a letter to the screen.
	; NOTE: Unless we're handling a newline, the printing should be done instantly,
	;       as the waiting only happens later (to allow the speedup controls to work)
	push af				; Save delay
		push bc
			ldi  a, [hl]		; Read letter from string
			cp   C_NL			; Is it the newline character?
			jr   z, .doNewline	; If so, jump
			
			push hl
			
				;
				; Write the character to the screen
				;
			
				; Convert letter to tile ID
				ld   hl, TextPrinter_CharsetToTileTbl
				ld   c, a
				call TextPrinter_GetTileIdFromLetter ; B = Tile ID
				
				; Write it out to the tilemap
				mWaitForVBlankOrHBlankFast	
				ld   a, b					
				ld   [de], a
				inc  de						; Move tilemap pos right
				
				;
				; Play the typewriter SGB sound if needed
				;
				ld   a, [wTextPrintFlags]
				bit  TXTB_PLAYSFX, a			; Is the bit set?
				jr   z, .sfxDone				; If not, skip
				
				; Use a different sound effect when printing the space character
				ld   a, b
				or   a							; TileID != 0?
				jr   nz, .sfxSpace				; If so, jump
			.sfxChar:
				ld   hl, (SGB_SND_A_SELECT_B << 8)|$02
				call SGB_PrepareSoundPacketA
				jr   .sfxDone
			.sfxSpace:
				ld   hl, (SGB_SND_A_PUNCH_B << 8)|$07
				call SGB_PrepareSoundPacketA
			.sfxDone:
				jr   .charPrinted
			;------
			;
			; Newline handler
			; Moves to the *start* of the next tilemap row.
			; The side effect of this is strings starting with at least 1 empty space.
			;
		.doNewline:
			push hl
			
				; DE += BG_TILECOUNT_H
				ld   hl, BG_TILECOUNT_H		
				add  hl, de
				push hl
				pop  de
				; Align to $20 boundary
				ld   a, e
				and  a, $FF^(BG_TILECOUNT_H-1)
				ld   e, a
				
				; Wait 6 frames before continuing
				call TextPrinter_ExecuteCustomCodeOnWait
				call Task_PassControl_NoDelay
				ld   b, $05
			.newlineWait:
				call TextPrinter_ExecuteCustomCodeOnWait
				call Task_PassControl_NoDelay
				dec  b
				jr   nz, .newlineWait
			;-------
		.charPrinted:
			pop  hl
		pop  bc
	pop  af				; Restore delay
	
	;
	; Handle speedup controls
	;
	
	; If we enabled the line skipping mode in the delay counter, that's it.
	; Instantly print text as fast as possible (but still delay for a bit when printing newlines).
	bit  TXCB_INSTANT, a		; Instant print enabled?
	jr   nz, .chkStringEnd		; If so, skip and immediately write the next char
	push af	
	
	.delayLoop:
		push af
			; There are three different ways to handle controls.
			
			ld   a, [wTextPrintFlags]
			bit  TXTB_ALLOWSKIP, a		; Is the flag set?
			jr   nz, .chkCtrlWithSkip	; If so, jump
			bit  TXTB_ALLOWFAST, a		; Is the flag set?
			jr   z, .actNone			; If not, jump
			
			; TXTB_ALLOWFAST mode
			; Pressing A in this mode will speed up the text printing.
			; It's also possible to press START to enable instant text mode.
		.chkCtrlFast:
			ldh  a, [hJoyNewKeys]
			bit  KEYB_START, a			; Pressed START?
			jr   nz, .actInstant		; If so, jump
			ldh  a, [hJoyKeys]
			bit  KEYB_A, a				; Holding A?
			jr   nz, .actSpeedup		; If so, jump
			; Check the same for controller 2
			ldh  a, [hJoyNewKeys2]
			bit  KEYB_START, a			
			jr   nz, .actInstant			
			ldh  a, [hJoyKeys2]
			bit  KEYB_A, a
			jr   nz, .actSpeedup
			jr   .actNone				; Otherwise, no action
		.chkCtrlWithSkip:
			; TXTB_ALLOWSKIP mode
			; Pressing START in this mode will mark the text printing as finished,
			; skipping the rest completely.
			ldh  a, [hJoyNewKeys]
			bit  KEYB_START, a			; Pressed START?
			jr   nz, .actAbort			; If so, jump
			; Check the same for controller 2
			ldh  a, [hJoyNewKeys2]
			bit  KEYB_START, a
			jr   nz, .actAbort
			jr   .actNone				; Otherwise, no action
			
		;
		; Action: Abort
		; Exit from here, marking the printing as finished
		;
		.actAbort:
		pop  af
	pop  af
	
	; Pull out the 4 stack values + restore bank
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	pop  de
	pop  bc
	pop  af
	scf			; C flag = 1, aborted
	ret
	;--
		;
		; Action: Instant text 
		; Enable instant text mode permanently
		;
		.actInstant:
		pop  af
	pop  af					; Extra pop to apply the changes permanently
	set  TXCB_INSTANT, a 	; here
	jr   .chkStringEnd
	;--
		;
		; Action: Speed up
		; Sets the text printing delay to 1 frame temporarily
		;
		.actSpeedup:
		pop  af
		ld   a, $01			; A = Frames to wait (temp copy)
		jr   .waitFrame
	;--	
		;
		; Action: None
		; ...well
		;
		.actNone:
		pop  af				; Restore delay counter
	;--	
	; Common wait between text printing
	.waitFrame:
		push af
			call TextPrinter_ExecuteCustomCodeOnWait
			call Task_PassControl_NoDelay
		pop  af				
		dec  a				; Waited all frames?
		jr   nz, .delayLoop	; If not, loop
	pop  af					; Restore original text speed
	
.chkStringEnd:
	dec  b					; Printed all letters?
	jp   nz, .loop			; If not, loop
	
	; Exit from here
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	pop  de
	pop  bc
	pop  af
	scf				; C flag = 0, not aborted
	ccf
	ret
	
; =============== TextPrinter_ExecuteCustomCodeOnWait ===============
; If enabled, executes custom code during the printing delay, before passing control to another task.
TextPrinter_ExecuteCustomCodeOnWait:
	push af
	push bc
	push de
	push hl
	;--
	ldh  a, [hROMBank]
	push af
	; Don't execute the code if the "no code" bank number is set
	ld   a, [wTextPrintFrameCodeBank]		; A = Bank num for code
	cp   TXB_NONE							; Is it set to $FF?
	jp   z, .noAction						; If so, jump
	
	; Jump there
	ld   [MBC1RomBank], a					; Switch to the bank
	ldh  [hROMBank], a
	ld   hl, wTextPrintFrameCodePtr_Low		; Read ptr to DE
	ld   e, [hl]
	inc  hl
	ld   d, [hl]
	push de									; Move it to HL
	pop  hl
	call .jpHL								; Jump there
	
.noAction:
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	;--
	pop  hl
	pop  de
	pop  bc
	pop  af
	ret
.jpHL:
	jp   hl
	
; =============== HomeCall_SGB_ApplyScreenPalSet ===============
HomeCall_SGB_ApplyScreenPalSet:
	ld   hl, wMisc_C025
	bit  MISCB_IS_SGB, [hl]		; Running under SGB?
	ret  z						; If not, return
	ldh  a, [hROMBank]
	push af
	ld   a, BANK(SGB_ApplyScreenPalSet) ; BANK $04
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	call SGB_ApplyScreenPalSet
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret  
	
; =============== Play_LoadStage ===============
; Loads the data for the stage/playfield.
Play_LoadStage:
	ldh  a, [hROMBank]
	push af
		
		; Blank out the line where the hit counters appear, in case the round ended while it was still there
		ld   hl, $9C65	; BG Ptr
		ld   b, $0A	; Rect Width
		ld   c, $01 ; Rect Height
		ld   d, $00 ; Tile ID
		call FillBGRect
		
		; Blank out the line with MAXIMUM at the bottom, for the same reason
		ld   hl, $9CA0
		ld   b, $14
		ld   c, $01
		ld   d, $00
		call FillBGRect
		
		; If this isn't the first round, we have everything already loaded/drawn.
		ld   a, [wRoundNum]
		or   a				; RoundNum > 0?
		jp   nz, .end		; If so, we're done
		
		;
		; Determine the stage to load.
		; In VS mode, the stage ID is already randomized at the stage select screen.
		;
		ld   a, [wPlayMode]
		bit  MODEB_VS, a	; Playing in VS mode?
		jp   nz, .load		; If so, jump
		
		;
		; In single mode, the stage is the one assigned to the first CPU opponent of the team.
		;
		
		; A = CPU opponent
		ld   a, [wJoyActivePl]
		or   a				; Playing on the 2P side?
		jp   nz, .pl2Active	; If so, jump
	.pl1Active:
		ld   hl, wPlInfo_Pl2+iPlInfo_CharId		; HL = Ptr to 2P CPU char id
		jp   .getIdx
	.pl2Active:
		ld   hl, wPlInfo_Pl1+iPlInfo_CharId		; HL = Ptr to 1p CPU char id
	.getIdx:
		ld   a, [hl]	; A = CharId * 2
		
		; Index the Char-to-Stage mapping table
		srl  a				; /2 to balance out the *2
		
		ld   hl, Play_CharStageMapTbl	; HL = Ptr to map tbl
		ld   d, $00			; DE = CharId
		ld   e, a
		add  hl, de			; Index it
		ld   a, [hl]		; A = StageId
		ld   [wStageId], a	; Save it
		
		;--
		; The extra round fighting against IORI' or LEONA' uses an hardcoded stage.
		; [POI] ??? This is pointless, as the correct entries are already set in Play_CharStageMapTbl.
		ld   a, [wRoundSeqId]
		cp   STAGESEQ_BONUS	; RoundId == STAGESEQ_BONUS?
		jp   nz, .load		; If not, skip
		ld   a, STAGE_ID_STADIUM_EXTRA
		ld   [wStageId], a
		jp   .load
		;--
	.load:
		
		;
		; Index the stage header off the table.
		;
		ld   a, [wStageId]				; BC = StageId * 8
		sla  a
		sla  a
		sla  a
		ld   b, $00
		ld   c, a
		ld   hl, Play_StageHeaderTbl	; HL = Start of header
		add  hl, bc						; Offset it
		
		;--
		
		;
		; bytes0-2 Stage GFX
		;
		
		; Switch to the bank with both the GFX and tilemap
		ldi  a, [hl]	; byte0
		ld   [MBC1RomBank], a
		ldh  [hROMBank], a
		
		; Read out the GFX ptr to BC
		ld   c, [hl]	; byte1
		inc  hl
		ld   b, [hl]	; byte2
		inc  hl
		push hl
			; Decompress the data to the third GFX block
			push bc
			pop  hl				
			ld   de, wLZSS_Buffer
			call DecompressLZSS
			ld   hl, wLZSS_Buffer
			ld   de, $9000
			call CopyTiles
		pop  hl
		
		;
		; bytes3-4 Stage tilemap
		;
		
		; Read out the BG ptr to DE
		ld   e, [hl]	; byte3
		inc  hl
		ld   d, [hl]	; byte4
		inc  hl
		push hl
			; Decompress the playfield tilemap
			push de
			pop  hl
			ld   de, wLZSS_Buffer
			call DecompressLZSS
			
			; The stage tilemaps are long, spanning the full $20 tiles of the hardware tilemap.
			; Note that they never get redrawn when scrolling, so those 20 tiles are all that's ever visible.
			ld   de, wLZSS_Buffer
			ld   hl, $9880			; 4 tiles below top
			ld   b, $20				; Width
			ld   c, $0C				; Height
			call CopyBGToRect
			
			; Fill with white tiles two rows above the tilemap, in case the playfield moves down too much.
			ld   hl, $9840
			ld   b, $20
			ld   c, $02
			ld   d, $01
			call FillBGRect
		pop  hl
		
		;
		; byte5 - SGB palette ID
		;
		ld   d, $00
		ld   e, [hl]		; byte5
		inc  hl				; Seek to byte6
		push hl
			call HomeCall_SGB_ApplyScreenPalSet
		pop  hl
		
		;
		; byte6 - BGM ID
		;
		ld   a, [hl]
		call HomeCall_Sound_ReqPlayExId_Stub
	.end:
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret
	
; =============== Play_StageHeaderTbl ===============
; Defines the stage headers:
; FORMAT:
; - 0   : Bank number for GFX and tilemap
; - 1-2 : Ptr to LZSS compressed GFX
; - 3-4 : Ptr to LZSS compressed tilemap
; - 5   : SGB screen layout ID
; - 6   : BGM ID
; - 7   : Padding for alignment to 8-byte boundary
Play_StageHeaderTbl:
	; STAGE 0
	db BANK(GFXLZ_Play_Stage_Hero) ; BANK $04
	dw GFXLZ_Play_Stage_Hero
	dw BGLZ_Play_Stage_Hero
	db SCRPAL_STAGE_HERO
	db BGM_ESAKA
	db $00
	
	; STAGE 1
	db BANK(GFXLZ_Play_Stage_FatalFury) ; BANK $04
	dw GFXLZ_Play_Stage_FatalFury
	dw BGLZ_Play_Stage_FatalFury
	db SCRPAL_STAGE_FATALFURY
	db BGM_BIGSHOT
	db $00
	
	; STAGE 2
	db BANK(GFXLZ_Play_Stage_Yagami) ; BANK $04
	dw GFXLZ_Play_Stage_Yagami
	dw BGLZ_Play_Stage_Yagami
	db SCRPAL_STAGE_YAGAMI
	db BGM_ARASHI
	db $00
	
	; STAGE 3
	db BANK(GFXLZ_Play_Stage_Boss) ; BANK $04
	dw GFXLZ_Play_Stage_Boss
	dw BGLZ_Play_Stage_Boss
	db SCRPAL_STAGE_BOSS
	db BGM_GEESE
	db $00

	; STAGE 4
	db BANK(GFXLZ_Play_Stage_Stadium) ; BANK $04
	dw GFXLZ_Play_Stage_Stadium
	dw BGLZ_Play_Stage_Stadium
	db SCRPAL_STAGE_STADIUM
	db BGM_FAIRY
	db $00
	
	; STAGE 5
	db BANK(GFXLZ_Play_Stage_Stadium) ; BANK $04
	dw GFXLZ_Play_Stage_Stadium
	dw BGLZ_Play_Stage_Stadium
	db SCRPAL_STAGE_STADIUM
	db BGM_TRASHHEAD
	db $00
	
	; STAGE 6
	db BANK(GFXLZ_Play_Stage_Stadium) ; BANK $04
	dw GFXLZ_Play_Stage_Stadium
	dw BGLZ_Play_Stage_Stadium
	db SCRPAL_STAGE_STADIUM
	db BGM_MRKARATE
	db $00
	
; =============== Play_CharStageMapTbl ===============
; Defines the stage associated with a character, used in single mode.
Play_CharStageMapTbl:
	db STAGE_ID_HERO ; CHAR_ID_KYO     
	db STAGE_ID_HERO ; CHAR_ID_DAIMON  
	db STAGE_ID_FATALFURY ; CHAR_ID_TERRY   
	db STAGE_ID_FATALFURY ; CHAR_ID_ANDY    
	db STAGE_ID_FATALFURY ; CHAR_ID_RYO     
	db STAGE_ID_FATALFURY ; CHAR_ID_ROBERT  
	db STAGE_ID_HERO ; CHAR_ID_ATHENA  
	db STAGE_ID_FATALFURY ; CHAR_ID_MAI     
	db STAGE_ID_YAGAMI ; CHAR_ID_LEONA   
	db STAGE_ID_BOSS ; CHAR_ID_GEESE   
	db STAGE_ID_BOSS ; CHAR_ID_KRAUSER 
	db STAGE_ID_BOSS ; CHAR_ID_MRBIG   
	db STAGE_ID_YAGAMI ; CHAR_ID_IORI    
	db STAGE_ID_YAGAMI ; CHAR_ID_MATURE  
	db STAGE_ID_HERO ; CHAR_ID_CHIZURU 
	db STAGE_ID_STADIUM_GOENITZ ; CHAR_ID_GOENITZ 
	db STAGE_ID_STADIUM_EXTRA ; CHAR_ID_MRKARATE
	db STAGE_ID_STADIUM_EXTRA ; CHAR_ID_OIORI   
	db STAGE_ID_STADIUM_EXTRA ; CHAR_ID_OLEONA  
	db STAGE_ID_STADIUM_KAGURA ; CHAR_ID_KAGURA  
	
; =============== Serial_DoHandshake ===============
; Performs an handshake between master and slave GBs.
; If it succeeds, the standard serial handlers (master/slave-specific) are set.
;
; For the handshake, the master sends out $43 and expects the slave to return $4C.
; Both the master and slave wait in a loop $600 times for a byte to be received, after which:
; - The master tries sending $43 again
; - The slave resets its "reply byte" and sets the listen flag again
; The same also happens if the received byte doesn't match what the master/slave is expecting.
;
; Every interrupt other than the serial one is disabled on both Game Boys while this happens,
; to give the handshake exclusive priority.
;
Serial_DoHandshake:
	ld   hl, wMisc_C025
	bit  MISCB_SERIAL_MODE, [hl]	; Are we in VS mode serial?
	ret  z							; If not, return
	;--
	
	;
	; Prepare system to give exclusive control to the handshake check.
	;
	
	di   
	; Set the serial handler used for this, which handles both master and slave.
	ld   a, LOW(SerialHandler_Handshake)
	ld   [wSerialIntPtr_Low], a
	ld   a, HIGH(SerialHandler_Handshake)
	ld   [wSerialIntPtr_High], a
	
	xor  a
	ldh  [rSB], a					; Remove sent values from queue
	ld   [wSerialInputMode], a	; Disable input processing just in case
	
	; Disable every interrupt except for serial, and discard any existing one.
	ldh  a, [rIE]
	push af				; Save rIE
		xor  a				; Stop all existing interrupts
		ldh  [rIF], a		
		ld   a, I_SERIAL	; Enable Serial interrupt only
		ldh  [rIE], a
		ei
	
	
		; Clear marker to prepare for transfer.
		xor  a							
		ld   [wSerialTransferDone], a
		
		ld   hl, wMisc_C025
		bit  MISCB_SERIAL_SLAVE, [hl]	; Are we set as slave?
		jp   nz, .slave						; If so, jump
	.master:
		;
		; MASTER
		; Sends $43 to slave and expects $4C back.
		;
		; [POI] There's a design flaw where if something goes wrong
		;       after the slave reads $43, the master will infinite loop.
		;
	
		; Wait for a bit before starting, to give time to the slave
		ld   bc, $0010
		call SGB_DelayAfterPacketSendCustom
		
		; Reset transfer flag
		xor  a
		ld   [wSerialTransferDone], a
	.trySendToSlave:
		; Perform Master->Slave transfer
		;--
		di   
		ld   a, $43								; Send $43 to slave
		ld   [wSerialDataSendBuffer], a
		ld   a, START_TRANSFER_INTERNAL_CLOCK	; Start transfer
		ldh  [rSC], a
		ei 
		;--
		; Wait $0600 times in a loop for a reply before retrying.
		; [POI] This is a point where the master can infinite loop,	as it's possible for the slave 
		;       to receive a byte but not send one back in time. This results in the slave continuing,
		;       but the master still waiting. There's no timeout here.
		ld   bc, $0600					; BC = Loop cycles before retry
	.waitSlaveReply:
		ld   a, [wSerialTransferDone]
		or   a							; Did we receive anything yet?
		jr   nz, .chkSlaveReply			; If so, jump
		dec  bc							; CyclesLeft--
		ld   a, b
		or   c							; CyclesLeft != 0?
		jp   nz, .waitSlaveReply		; If so, loop
		jp   .trySendToSlave			; Otherwise, try to send the byte again
		
	.chkSlaveReply:
		xor  a							; Reset transfer flag
		ld   [wSerialTransferDone], a
		ld   a, [wSerialDataReceiveBuffer]
		cp   a, $4C						; Did we receive $4C from the slave?
		jr   nz, .trySendToSlave		; If not, try to send the byte again
		jp   .handshakeOk				; Otherwise, we're done
		
	.slave:
		;
		; SLAVE
		; Waits to receive $43 from the master, then sends $4C back.
		;
		ld   a, $4C						; Set byte we're replying with
		ld   [wSerialDataSendBuffer], a
		ld   a, START_TRANSFER_EXTERNAL_CLOCK ; Start listening to master			
		ldh  [rSC], a
		ld   bc, $0600					; BC = Loop cycles before retry
	.waitMaster:
		ld   a, [wSerialTransferDone]
		or   a							; Did we receive anything yet?
		jr   nz, .chkMasterRecv			; If so, jump
		dec  bc							; CyclesLeft--
		ld   a, b
		or   c							; CyclesLeft != 0?
		jp   nz, .waitMaster			; If so, loop
		jp   .slave						; Otherwise, re-listen again
	.chkMasterRecv:
		xor  a							; Reset transfer flag
		ld   [wSerialTransferDone], a
		ld   a, [wSerialDataReceiveBuffer]
		cp   a, $43						; Did we receive $43 from the master?
		jr   nz, .slave					; If not, re-listen again
		; Otherwise, we're done.
		; Note that the master still has to check our response.
		
	.handshakeOk:
		;--
		di   
		
		;
		; Initialize and clear serial variables
		;
		
		; Clear entire buffer of received bytes
		xor  a
		ld   b, wSerialDataReceiveBuffer_End-wSerialDataReceiveBuffer ; B = Buffer length
		ld   hl, wSerialDataReceiveBuffer	; HL = Starting ptr
	.clrRecvBufLoop:
		ldi  [hl], a
		dec  b
		jp   nz, .clrRecvBufLoop
		
		; Clear entire buffer of sent bytes
		ld   b, wSerialDataSendBuffer_End-wSerialDataSendBuffer ; B = Buffer length
		ld   hl, wSerialDataSendBuffer		; HL = Starting ptr
	.clrSendBufLoop:
		ldi  [hl], a
		dec  b
		jp   nz, .clrSendBufLoop
		
		; Reset misc variables
		ld   [wTimer], a
		ldh  [rSB], a
		ldh  [hJoyKeys], a
		ldh  [hJoyKeys2], a
		ldh  [hJoyNewKeys], a
		ldh  [hJoyNewKeys2], a
		ld   [wSerialPendingJoyKeys], a
		ld   [wSerialPendingJoyKeys2], a
		ld   [wSerialPendingJoyNewKeys], a
		ld   [wSerialPendingJoyNewKeys2], a
		ld   [wSerialReceivedLeft], a
		ld   [wSerialSentLeft], a
		ld   [wSerial_Unknown_Unused_C144], a
		ld   [wSerialLagCounter], a
		ld   [wSerial_Unknown_Unused_C1C6], a
		
		; By default, listen to the other GB
		ld   a, START_TRANSFER_EXTERNAL_CLOCK
		ldh  [rSC], a
		; Enable input buffer processing since we're ready
		ld   a, $01
		ld   [wSerialInputMode], a
		
		; Set the proper interrupt target between master/slave
		ld   hl, wMisc_C025
		bit  MISCB_SERIAL_SLAVE, [hl]	; Are we a slave?
		jp   nz, .setSlaveInt				; If so, jump
	.setMasterInt:
		; Set master serial handler
		ld   a, LOW(SerialHandler_Master)
		ld   [wSerialIntPtr_Low], a
		ld   a, HIGH(SerialHandler_Master)
		ld   [wSerialIntPtr_High], a
		
		; Initialize head/tail buffer indexes 
		; See also: JoyKeys_Get_Serial
		
		; Receive buffer offset by 1
		ld   a, $01
		ld   [wSerialDataReceiveBufferIndex_Head], a
		ld   a, $00
		ld   [wSerialDataReceiveBufferIndex_Tail], a
		; Send buffer offset by 2
		ld   a, $02
		ld   [wSerialDataSendBufferIndex_Head], a
		ld   a, $00
		ld   [wSerialDataSendBufferIndex_Tail], a
		jp   .end
	.setSlaveInt:
		; Set slave serial handler
		ld   a, LOW(SerialHandler_Slave)
		ld   [wSerialIntPtr_Low], a
		ld   a, HIGH(SerialHandler_Slave)
		ld   [wSerialIntPtr_High], a
		; Initialize head/tail buffer indexes (same as master)
		ld   a, $01
		ld   [wSerialDataReceiveBufferIndex_Head], a
		ld   a, $00
		ld   [wSerialDataReceiveBufferIndex_Tail], a
		ld   a, $02
		ld   [wSerialDataSendBufferIndex_Head], a
		ld   a, $00
		ld   [wSerialDataSendBufferIndex_Tail], a
		call Serial_Unknown_WaitAfterSend
	.end:
		; End all existing interrupt requests
		xor  a
		ldh  [rIF], a
	; Restore original enabled interrupts
	pop  af			
	ldh  [rIE], a
	ret
; =============== Serial_UnkSend ===============	
; Sends a null byte $10 times to the other GB.
L00161A:
	; Clear transfer flag... if it's useful
	xor  a
	ld   [wSerialTransferDone], a
	ld   a, $10
.loop:
	push af
		;--
		; Send $00 to the other GB
		di   
		xor  a
		ld   [wSerialDataSendBuffer], a
		ldh  [rSB], a
		ld   a, START_TRANSFER_INTERNAL_CLOCK
		ldh  [rSC], a
		ei 
		;--
		call Serial_Unknown_WaitAfterSend
		;--
		; What's the point
		ld   a, [wSerialTransferDone]
		or   a
		jr   nz, .okThen
	.okThen:
		;--
	pop  af
	dec  a				; Sent it $10 times?
	jp   nz, .loop		; If not, loop
	ret  
	
; =============== JoyKeys_Serial_GetActiveOtherInput ===============
; Gets the active inputs for the other player in a serial match.
; Only called with input balance != 0.
JoyKeys_Serial_GetActiveOtherInput:
	; Only do this if we're accepting serial inputs and in VS mode
	ld   a, [wSerialInputMode]
	and  a						; Handshake completed yet?
	ret  z						; If not, return
	ld   a, [wSerialPlayerId]
	and  a						; Playing in serial mode?
	ret  z						; If not, return
	
	; Determine the player ID on the other side.
	; ie: if we're playing on the 1P side, get 2P's joypad inputs
	ld   hl, hJoyKeys		
	cp   a, SERIAL_PL1_ID	; Controlling 1P?
	jr   nz, .go			; If not, jump
	ld   hl, hJoyKeys2		
	
.go:

	;
	; [Frame 2]
	; Get the active input for the other GB.
	;
	
	; C = Keys not held on the other GB
	ld   a, [hl]			
	cpl  
	ld   c, a
	
	; A = Held input at the tail value of the send buffer
	; After getting the entry, increase the tail index but don't clear it (unlike JoyKeys_Get_Serial).
	push hl
	
		; Get index to the receive buffer tail
		ld   a, [wSerialDataReceiveBufferIndex_Tail]
		ld   e, a
		; Save back an incremented copy
		inc  a											; Index++
		and  a, $7F										; Size of buffer, cyles back
		ld   [wSerialDataReceiveBufferIndex_Tail], a	; Save the updated index
		
		; Index the buffer of read inputs and read out its value.
		xor  a
		ld   d, a							; Index the data
		ld   hl, wSerialDataReceiveBuffer
		add  hl, de
		ld   a, [hl]
		
		; Decrement number of remaining inputs to read.
		ld   hl, wSerialReceivedLeft
		dec  [hl]
	pop  hl
	
	; Set hJoyKeys
	ldi  [hl], a		; Write entry to hJoyKeys
	
	; Like in JoyKeys_Get_Serial, set to hJoyNewKeys the keys released since the point hJoyKeys was recorded
	and  c				; hJoyNewKeys = hJoyKeys & C
	ld   [hl], a		; Write entry to hJoyNewKeys
	
	;
	; [Frame 0]
	; Set the values to send *after* the *next* transfer completes.
	;
	; In theory it would have been more correct to put this in JoyKeys_Get_Serial.
	call JoyKeys_Serial_SetNextTransfer
	ret
	
; =============== JoyKeys_Serial_SetNextTransfer ===============
; Sets up the next values to send when the current transfer is finished.
; This also causes the master to start the transfer.
JoyKeys_Serial_SetNextTransfer: 
	ld   a, [wSerialPlayerId]
	cp   a, SERIAL_PL1_ID		; Are we player 1?
	jr   nz, .pl2				; If not, jump
.pl1:
	;
	; Write wSerialPendingJoyKeys (1P) to head send buffer entry.
	;
	ld   a, [wSerialDataSendBufferIndex_Head]	; DE = IndexTop for send buffer
	ld   e, a
	ld   d, $00
	ld   hl, wSerialDataSendBuffer				; HL = SendBuffer
	add  hl, de									; Index it
	
	ld   a, [wSerialPendingJoyKeys]				; A = Latest joypad keys	
	call JoyKeys_FixInvalidCombinations			; Fix it
	ld   [hl], a								; Write it out
	
	xor  a										; Reset key status
	ld   [wSerialPendingJoyKeys], a
	
	; Start transfering what's already set in rSB
	ld   a, START_TRANSFER_INTERNAL_CLOCK
	ldh  [rSC], a
	ret  
.pl2:
	;
	; Write wSerialPendingJoyKeys2 (2P) to head send buffer entry
	;
	ld   a, [wSerialDataSendBufferIndex_Head]	; DE = IndexTop for send buffer
	ld   e, a
	ld   d, $00
	ld   hl, wSerialDataSendBuffer				; HL = SendBuffer
	add  hl, de									; Index it
	
	ld   a, [wSerialPendingJoyKeys2]			; A = Latest joypad keys	
	call JoyKeys_FixInvalidCombinations			; Fix it
	ld   [hl], a								; Write it out
	
	xor  a										; Reset key status
	ld   [wSerialPendingJoyKeys2], a
	ret  
	
; =============== JoyKeys_FixInvalidCombinations ===============
; Removes keypresses for impossible button combinations.
; IN
; -  A: JoyNewKeys bitmask
JoyKeys_FixInvalidCombinations:

	; If we're holding L and R at the same time, remove R
	ld   b, a
	and  a, KEY_RIGHT|KEY_LEFT
	cp   a, KEY_RIGHT|KEY_LEFT
	jp   nz, .next
	res  KEYB_RIGHT, b
.next:
	; If we're holding U and D at the same time, remove U
	ld   a, b
	and  a, KEY_UP|KEY_DOWN
	cp   a, KEY_UP|KEY_DOWN
	jp   nz, .end
	res  KEYB_UP, b
.end:
	ld   a, b
	ret  

; =============== Serial_Init ===============
; Initializes serial.
Serial_Init:
	; Disabled by default
	xor  a
	ldh  [rSB], a
	ld   [wSerialInputMode], a
	ld   [wSerialDataReceiveBuffer], a
	ld   [wSerialPlayerId], a
	ld   [wSerialTransferDone], a
	ld   [wSerialDataSendBuffer], a
	; Set the initial serial mode handler.
	; The Mode Select screen is the first to enable it.
	ld   a, LOW(ModeSelect_SerialHandler)
	ld   [wSerialIntPtr_Low], a
	ld   a, HIGH(ModeSelect_SerialHandler)
	ld   [wSerialIntPtr_High], a
	ret
	
; =============== SerialHandler ===============	
; By default this isn't called.
; The handler is called when a byte is received by either the master or slave.
SerialHandler:
	push af
	push bc
	push de
	push hl
	call .main
	pop  hl
	pop  de
	pop  bc
	pop  af
	reti
.main:
	; Read out the code ptr
	ld   hl, wSerialIntPtr_Low
	ldi  a, [hl]
	ld   e, a
	ld   h, [hl]
	ld   l, e
	; Jump there
	jp   hl
	
; =============== ModeSelect_SerialHandler ===============
; Serial handler for Module_Title.
ModeSelect_SerialHandler:
	; This handler is used to make the game wait at ModeSelect_Serial_Wait
	; until both DMGs have sent a byte (MODESELECT_SBCMD_*) to each other.
	
	ldh  a, [rSB]						; Read byte from serial
	ld   [wSerialDataReceiveBuffer], a	; Copy it here
	
	; When a byte from serial is received, the transfer flag from rSC gets automatically unset
	; from both sides.
	;
	; In case of the master, that doesn't make a difference since when it starts a transfer
	; in ModeSelect_Serial_SendAndWait, the rSC value gets set to the proper value.
	;
	; That would be bad since with the slave though. If the master tries to send a byte while
	; the slave isn't listening (START_TRANSFER_EXTERNAL_CLOCK unset), ModeSelect_Serial_Wait will infinite loop.
	;
	; It's also important, at least when the ModeSelect main loop is still executing,
	; that the master doesn't get START_TRANSFER_EXTERNAL_CLOCK immediately set before the frame ends (see below).
	; Otherwise, because of how ModeSelect is programmed, the next frame it will treat the previously
	; sent MODESELECT_SBCMD_* value as what the *other* DMG sent, set itself as a slave,
	; and infinite loop in ModeSelect_Serial_Wait listening for a byte that will never be sent.
	;
	; This is only a problem here because the game treats the received data as something
	; other than joypad input.
	; 
	;
	; Therefore, if we are set as slave, immediately set START_TRANSFER_EXTERNAL_CLOCK to listen for the next byte.
	; Normally START_TRANSFER_EXTERNAL_CLOCK would be set at the start of the ModeSelect main loop,
	; but the serial send and receive functions take exclusive control.
	;


	; Dumb detection of master/slave since we can't use MISCB_SERIAL_SLAVE yet.
	; Because the master is expecting the slave to reply with MODESELECT_SBCMD_IDLE, we can
	; use it to determine on which side we are.
	;
	; Because rSB is "shared" across master/slave in a delayed way, eventually the master will read
	; its own values back, but it won't matter anymore by that point.
	cp   MODESELECT_SBCMD_IDLE			; Did we receive the idle command?
	jr   z, .master						; If so, jump
.slave:
	ld   a, START_TRANSFER_EXTERNAL_CLOCK	; Allow listening for next byte immediately
	ldh  [rSC], a
	ld   a, $01							; Allow exit from ModeSelect_Serial_Wait
	ld   [wSerialTransferDone], a
	ret
.master:
	; Stop listening for bytes
	ld   a, $01							; Allow exit from ModeSelect_Serial_Wait
	ld   [wSerialTransferDone], a
	ret  
	
; =============== SerialHandler_Handshake ===============
; Simple serial handler used when doing the handshake between master and slave,
; typically when a module is initializing.
SerialHandler_Handshake:

	; Handle Send/Receive (single byte, no buffer)
	ldh  a, [rSB]						; Read received byte from serial
	ld   [wSerialDataReceiveBuffer], a	; Save to receive buffer
	ld   a, [wSerialDataSendBuffer]		; Read from send buffer
	ldh  [rSB], a						; Send it out
	ld   a, $01							; Mark transfer as done since we're received the byte
	ld   [wSerialTransferDone], a
	
	; If we're set as slave, listen to the next received byte.
	ld   a, [wMisc_C025]
	bit  MISCB_SERIAL_SLAVE, a			; Are we set as slave?
	ret  z									; If not, return
	ld   a, START_TRANSFER_EXTERNAL_CLOCK	; Listen for new byte
	ldh  [rSC], a
	ret
	
; =============== SerialHandler_Master ===============
; Serial handler for buffered input mode.
SerialHandler_Master:
	call SerialHandler_HeadBufferSet
	; The master only starts a transfer when it gets to send more data in JoyKeys_Serial_SetNextTransfer
	ld   a, $01
	ld   [wSerialTransferDone], a
	ret  
; =============== SerialHandler_Slave ===============
; Serial handler for buffered input mode.
SerialHandler_Slave:
	call SerialHandler_HeadBufferSet
	; The slave always needs to listen to new transfers
	ld   a, START_TRANSFER_EXTERNAL_CLOCK
	ldh  [rSC], a
	ld   a, $01
	ld   [wSerialTransferDone], a
	ret 

; =============== SerialHandler_HeadBufferSet ===============
; Sets the next serial data to the top of the receive and send buffers.
SerialHandler_HeadBufferSet:

	;
	; Write the current byte from rSB to the head index of the receive buffer.
	; Increase the index as well, wrapping back to $00 when it reaches the end.
	;

	ld   a, [wSerialDataReceiveBufferIndex_Head]
	ld   e, a										; E = Copy of RecvHeadIdx for indexing
	inc  a											; Increase RecvHeadIdx
	and  a, $7F										; Wrap around to $00 if past the buffer
	ld   [wSerialDataReceiveBufferIndex_Head], a	; Save back the increased index
	
	ld   d, $00										; DE = RecvHeadIdx
	ld   hl, wSerialDataReceiveBuffer				; HL = RecvBuffer
	add  hl, de										; Index the receive buffer table
	ldh  a, [rSB]									; Read the received byte from the other GB
	ld   [hl], a									; Write it in the buffer
	
	ld   hl, wSerialReceivedLeft			; Mark that a byte was received
	inc  [hl]										
	
	;
	; Write the current byte from the head index of the send buffer to rSB.
	; Update its index the same way.
	;
	ld   a, [wSerialDataSendBufferIndex_Head]
	ld   e, a										; E = Copy of SentHeadIdx for indexing
	inc  a											; Increase SentHeadIdx
	and  a, $7F										; Wrap around to $00 if past the buffer
	ld   [wSerialDataSendBufferIndex_Head], a		; Save back the increased index
	
	ld   d, $00										; DE = SentHeadIdx
	ld   hl, wSerialDataSendBuffer					; HL = SentBuffer
	add  hl, de										; Index the send buffer table
	ld   a, [hl]									; Read the newest byte to send
	ldh  [rSB], a									; Send it out
	
	ld   hl, wSerialSentLeft				; Mark that a byte was sent
	inc  [hl]
	ret  
	
; =============== Serial_Unknown_WaitAfterSend ===============
; Waits for exactly <???> hardware cycles after finishing with ???.
Serial_Unknown_WaitAfterSend:
	ld   bc, $0600		; BC = Loop count
.loop:
	nop  				; Waste some cycles
	nop  
	dec  bc				; LoopCount--
	ld   a, b
	or   c				; LoopCount == 0?
	jp   nz, .loop		; If not, loop
	ret 
	
; =============== Unknown_Unused_4380Jump ===============
; ?????	
Unknown_Unused_4380Jump:
	jp   $4380
	
; =============== Pl_Unknown_InitBeforeStage ===============
; Initializes parts of the player struct outside gameplay for both players.
Pl_Unknown_InitBeforeStage:
	; Initialize the round number to -1.
	; At the start of a round, it always gets increased by 1.
	ld   a, -$01
	ld   [wRoundNum], a
	
	; Win streak and losses is stage-specific
	xor  a
	ld   [wPlInfo_Pl1+iPlInfo_RoundWinStreak], a
	ld   [wPlInfo_Pl2+iPlInfo_RoundWinStreak], a
	ld   [wPlInfo_Pl1+iPlInfo_TeamLossCount], a
	ld   [wPlInfo_Pl2+iPlInfo_TeamLossCount], a
	ld   [wPlInfo_Pl1+iPlInfo_SingleWinCount], a
	ld   [wPlInfo_Pl2+iPlInfo_SingleWinCount], a
	ld   [wPlInfo_Pl1+iPlInfo_HitComboRecvSet], a
	ld   [wPlInfo_Pl2+iPlInfo_HitComboRecvSet], a
	; ??? Set initial timer, used on the intro pose
	ld   a, $48
	ld   [wPlInfo_Pl1+iPlInfo_Health], a
	ld   [wPlInfo_Pl2+iPlInfo_Health], a
	ret
	
; =============== Module_Play ===============
; Initializes the module where actual gameplay takes place.
; Called by multiple places with jumps.
L00179D:
Module_Play:
	ld   sp, $DD00
	di
	; Load the bank with various init data
	ld   a, BANK(GFXLZ_Play_HUD) ; BANK $1D
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	;-----------------------------------
	rst  $10				; Stop LCD
	
	; Lock controls & timer since the intro plays first
	ld   hl, wMisc_C027
	set  MISCB_PLAY_STOP, [hl]
	
	; Prevent players from moving off-screen
	inc  hl ; Seek to wMisc_C028
	set  MISCB_PL_RANGE_CHECK, [hl]
	
	; The gameplay screen is divided into multiple sections:
	; - HUD at the top
	; - Playfield
	; - HUD at the bottom
	
	; Specify which scanline range the playfield uses, and enable sect mode.
	; Note that these values are slightly less than the intended ones... but the
	; LYC trigger code performs a dubious busy loop which delays it (see LCDCHandler_Sect).
	ld   a, $1E		; Starts in
	ld   b, $7F		; Ends in
	call SetSectLYC
	
	; Initialize global gameplay timer.
	; Set to $FF so that first frame of gameplay starts at 0.
	ld   a, $FF
	ld   [wPlayTimer], a
	
	; [TCRF] This is the only place this counter is used.
	ld   hl, wRoundTotal
	inc  [hl]
	
	; Reset DMG pal
	ld   a, $FF
	ldh  [rBGP], a
	ldh  [rOBP0], a
	ldh  [rOBP1], a
	ldh  [hScreenSect0BGP], a
	ldh  [hScreenSect1BGP], a
	ldh  [hScreenSect2BGP], a
	
	; Disable scanline interrupt for now
	xor  a
	ldh  [rSTAT], a
	
	; If this is the first round of the stage, clear out any leftovers
	; in the tilemap from the previous screen.
	;
	; Note that this is the *only* point checking the round number before getting incremented, so if the pre-stage 
	; defaults from Pl_Unknown_InitBeforeStage are still set, the round number will still be -1.
	ld   a, [wRoundNum]
	cp   -$01				; RoundNum == -1?
	jp   nz, .setPlayPos	; If not, skip
	call ClearBGMap
	call ClearWINDOWMap
	
.setPlayPos:
	; Start the round at the center of the playfield.
	; At the start of a round, it should be possible to scroll the screen to either direction.
	ld   a, (TILEMAP_H - SCREEN_H) / 2	; $30
	ldh  [hScrollX], a
	ld   [wOBJScrollX], a
	xor  a
	ldh  [hScrollY], a
	ld   a, $40
	ld   [wOBJScrollY], a
	
	; Completely clear both GFX buffers
	ld   hl, wGFXBufInfo_Pl1	; HL = Starting point
	ld   b, $40					; B = Bytes to clear
	xor  a						; A = Clear with
.bufClrLoop:
	ldi  [hl], a
	dec  b
	jp   nz, .bufClrLoop
	
	call ClearOBJInfo
	call Play_LoadPreRoundTextAndIncRound
	call Play_DrawHUDBaseAndInitTimer
	call Play_InitRound
	call Play_DrawHUDEmptyBars
	call Play_HUD_DrawCharNames
	call Play_DrawCharIcons
	call Play_LoadStage
	
	;
	; Decompress the full set of projectile graphics to the LZSS buffer.
	;
	; The needed graphics for the two characters will be copied to VRAM
	; only after the pre-round text despawns (otherwise there'd be a conflict).
	;
	ldh  a, [hROMBank]
	push af
		ld   a, BANK(GFXLZ_Projectiles) ; BANK $01
		ld   [MBC1RomBank], a
		ldh  [hROMBank], a
		ld   hl, GFXLZ_Projectiles
		ld   de, wLZSS_Buffer
		call DecompressLZSS
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	
	; Display the WINDOW at the top, as that's where the status bar is.
	xor  a
	ldh  [rWY], a
	ld   a, $07
	ldh  [rWX], a
	
	; Initialize serial connection
	call Serial_DoHandshake
	
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_OBJSIZE|LCDC_WENABLE|LCDC_WTILEMAP|LCDC_ENABLE
	rst  $18
	
	; Enable VBLANK & LYC interrupts
	ldh  a, [rSTAT]		; Enable scanline triggers
	or   a, STAT_LYC
	ldh  [rSTAT], a
	; [POI] Leftover value fron KOF95, which used a smaller HUD at the top. 
	;       This doesn't have any real effect as the screen is still black,
	;       and by the next frame it will get reset to what was previously set in SetSectLYC.
	ld   a, $16			
	ldh  [rLYC], a	
	ldh  a, [rIE]
	or   a, I_VBLANK|I_STAT
	ldh  [rIE], a
	
	; Create two separate tasks for handling players (animation only???)
	ld   a, $02
	ld   bc, L002458
	call Task_CreateAt
	
	ld   a, $03
	ld   bc, L002464
	call Task_CreateAt
	
	; Set intro move for characters that don't start in their idle anim
	call Play_Char_SetIntroAnimInstant
	ei
	
	; Pass control twice (??? to initialize the other tasks).
	call Task_PassControlFar
	call Task_PassControlFar
	
	;
	; In single mode, the bosses and extra stages play a sound effect
	; on the SGB side when a round starts.
	;
	ld   a, [wRoundSeqId]
	cp   STAGESEQ_KAGURA	; Is this the Chizuru boss stage?
	jp   z, .sndKagura		; If so, jump
	cp   STAGESEQ_GOENITZ	; Goenitz boss stage?
	jp   z, .sndGoenitz		; If so, jump
	cp   STAGESEQ_BONUS		; Orochi Iori/Leona extra stage?
	jp   z, .sndBonus		; If so, jump
	cp   STAGESEQ_MRKARATE	; Mr. Karate extra stage?
	jp   z, .sndMrKarate	; If so, jump
	jp   .noSnd				; Otherwise, it's a normal round
.sndKagura:
	; what?
	ld   hl, (SGB_SND_B_DUMMY << 8)|$00
	jr   .playSnd
.sndGoenitz:
	; Appropriately, play a wind SFX when the round starts on Goenitz
	ld   hl, (SGB_SND_B_WIND << 8)|$00
	jr   .playSnd
.sndBonus:
	; Also appropriate (if only the wrecked stadium tileset was included)
	ld   hl, (SGB_SND_B_EARTHQUAKE << 8)|$00
	jr   .playSnd
.sndMrKarate:
	; I guess
	ld   hl, (SGB_SND_B_WAVE << 8)|$00
	jr   .playSnd
.playSnd:
	call SGB_PrepareSoundPacketB
.noSnd:
	
	;
	; Wait $0A frames for the player graphics to load while the DMG palette is black
	;
	; The reason this is done like this is because the player graphics are copied at VBlank,
	; meaning the screen has to be enabled for them to be copied.
	;
	; fun fact: the GBC bootlegs neglect to set a completely black GBC palette before this point
	; so the aforemented glitched graphics do show up there in GBC mode.
	;
	ld   b, $0A
.waitLoad:
	call Task_PassControlFar
	dec  b
	jp   nz, .waitLoad
	
	; Show the screen by setting the real DMG palettes
	ld   a, $8C				; 1P palette
	ldh  [rOBP0], a
	ld   a, $4C				; 2P palette
	ldh  [rOBP1], a
	ld   a, $1B				; BG palette
	ld   [wStageBGP], a			
	ldh  [rBGP], a				; BG palette for all sections
	ldh  [hScreenSect0BGP], a
	ldh  [hScreenSect1BGP], a
	ldh  [hScreenSect2BGP], a
	
	; Set intro move for characters that start in their idle anim.
	call Play_Char_SetIntroAnimDelayed
	; Execute the main intro part
	call Play_DoPreRoundText
	; Load projectile graphics over
	call Play_LoadProjectileOBJInfo
	
	; Start the main gameplay loop
	ld   a, BANK(L016389) ; BANK $01
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	jp   L016389
	
; =============== Play_InitRound ===============
; Initializes the round variables, including both players.
Play_InitRound:

	; Load character-specific settings
	ld   bc, wPlInfo_Pl1
	ld   de, wOBJInfo_Pl1+iOBJInfo_Status
	call Play_LoadChar
	ld   bc, wPlInfo_Pl2
	ld   de, wOBJInfo_Pl2+iOBJInfo_Status
	call Play_LoadChar
	
	; Initialize other fields
	xor  a
	ld   [$C172], a
	ld   [$C173], a
	ld   [$C17A], a
	ld   [$C17B], a
	ld   [$C159], a
	ld   [wPlayMaxPowScroll1P], a
	ld   [wPlayMaxPowScroll2P], a
	
	; Set player numbers, mostly used so projectiles know from which players they come from
	xor  a ; PL1
	ld   [wPlInfo_Pl1+iPlInfo_PlId], a
	ld   a, PL2
	ld   [wPlInfo_Pl2+iPlInfo_PlId], a
	
	; Remove every status flag except for the CPU marker
	ld   a, [wPlInfo_Pl1+iPlInfo_Status]
	and  a, PS_CPU
	ld   [wPlInfo_Pl1+iPlInfo_Status], a
	ld   a, [wPlInfo_Pl2+iPlInfo_Status]
	and  a, PS_CPU
	ld   [wPlInfo_Pl2+iPlInfo_Status], a
	
	xor  a
	ld   [wPlInfo_Pl1+iPlInfo_21], a
	ld   [wPlInfo_Pl1+iPlInfo_22Flags], a
	ld   [wPlInfo_Pl1+iPlInfo_23], a
	ld   [wPlInfo_Pl2+iPlInfo_21], a
	ld   [wPlInfo_Pl2+iPlInfo_22Flags], a
	ld   [wPlInfo_Pl2+iPlInfo_23], a
	ld   [wPlInfo_Pl1+iPlInfo_MoveId], a
	ld   [wPlInfo_Pl2+iPlInfo_MoveId], a
	ld   [wPlInfo_Pl1+iPlInfo_IntroMoveId], a
	ld   [wPlInfo_Pl2+iPlInfo_IntroMoveId], a
	ld   [wPlInfo_Pl1+iPlInfo_63], a
	ld   [wPlInfo_Pl2+iPlInfo_63], a
	ld   [wPlInfo_Pl1+iPlInfo_64], a
	ld   [wPlInfo_Pl2+iPlInfo_64], a
	ld   [wPlInfo_Pl1+iPlInfo_59], a
	ld   [wPlInfo_Pl2+iPlInfo_59], a
	ld   [wPlInfo_Pl1+iPlInfo_58], a
	ld   [wPlInfo_Pl2+iPlInfo_58], a
	ld   [wPlInfo_Pl1+iPlInfo_HitComboRecvSet], a
	ld   [wPlInfo_Pl2+iPlInfo_HitComboRecvSet], a
	ld   [wPlInfo_Pl1+iPlInfo_60], a
	ld   [wPlInfo_Pl2+iPlInfo_60], a
	
	; ???
	ld   a, $FF
	ld   [wPlInfo_Pl1+iPlInfo_61], a
	ld   [wPlInfo_Pl2+iPlInfo_61], a
	
	; ???
	ld   a, $67
	ld   [wPlInfo_Pl1+iPlInfo_5A], a
	ld   [wPlInfo_Pl2+iPlInfo_5A], a
	ld   [wPlInfo_Pl1+iPlInfo_5B], a
	ld   [wPlInfo_Pl2+iPlInfo_5B], a
	ld   [wPlInfo_Pl1+iPlInfo_5C], a
	ld   [wPlInfo_Pl2+iPlInfo_5C], a
	ld   [wPlInfo_Pl1+iPlInfo_5D], a
	ld   [wPlInfo_Pl2+iPlInfo_5D], a
	
	; ??? Make a backup of the active character IDs
	ld   a, [wPlInfo_Pl1+iPlInfo_CharId]
	ld   [wPlInfo_Pl2+iPlInfo_Unk_CharIdCopy], a
	ld   a, [wPlInfo_Pl2+iPlInfo_CharId]
	ld   [wPlInfo_Pl1+iPlInfo_Unk_CharIdCopy], a
	
	;##
	
	;
	; Determine if this is the final round ("FINAL!!"), by checking if either:
	; - In single mode, we are on the 4th round
	; - In team mode, any team has all three members defeated.
	; 
	; In case of team mode, normally having all three characters defeated causes the game to show the win screen,
	; but if we're still trying to start a new round, it means the last normal round (3rd 1P char, vs 3rd 2P char)
	; ended in a draw.
	; Draws cause both characters to be marked as defeated, and in the special case both teams have three defeated
	; members, a final round starts.
	;
	
.chkFinalRound:
	xor  a
	ld   [wRoundFinal], a
	call IsInTeamMode			; Are we in team mode?
	jp   nc, .chkFinalSingle	; If not, jump
	
	;--
.chkLastWin1P:
	;
	; TODO: What's the point of setting the timer target? ???
	;       By the time it finishes incrementing, the pre-round text is still there.
	;
	; Logic for timer target values:
	; - $48: Losing player, or normal round in single mode
	; - $17: Final round
	;
	
	;
	; The last winner has the timer target set to $48.
	;
	ld   a, [wLastWinner]
	bit  PLB1, a			; Did 1P win the last round?
	jp   nz, .chkLastWin2P	; If so, skip
	ld   a, $48				; Otherwise, set timer
	ld   [wPlInfo_Pl1+iPlInfo_Health], a
.chkLastWin2P:
	ld   a, [wLastWinner]
	bit  PLB2, a			; Did 2P win the last round?
	jp   nz, .chkFinalTeam	; If so, skip
	ld   a, $48				; Otherwise, set timer
	ld   [wPlInfo_Pl2+iPlInfo_Health], a
	;--
.chkFinalTeam:
	
	;
	; If any team has 3 characters defeated, this is the final round.
	; ??? Note that it's not necessary to check both -- if the first team 
	; doesn't have 3 losses, the second one doesn't either.
	;
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamLossCount]
	cp   $03					; Is 1P's team defeated?
	jp   z, .setFinalRound		; If so, jump
	ld   a, [wPlInfo_Pl2+iPlInfo_TeamLossCount]
	cp   $03					; Is 2P's team defeated?
	jp   z, .setFinalRound		; If so, jump
	jp   .end
.chkFinalSingle:

	;
	; If we're on the 4th round, this is the final round
	;
	ld   a, [wRoundNum]
	cp   $03				; wRoundNum == $03? (4th)
	jp   nz, .setNormRound	; If not, jump
.setFinalRound:
	; Enable FINAL!! round
	ld   a, $01
	ld   [wRoundFinal], a
	; Set timer to $17 for both players
	ld   a, $17
	ld   [wPlInfo_Pl1+iPlInfo_Health], a
	ld   [wPlInfo_Pl2+iPlInfo_Health], a
	jp   .end
.setNormRound:
	; Set timer to $48 for both players
	ld   a, $48				
	ld   [wPlInfo_Pl1+iPlInfo_Health], a
	ld   [wPlInfo_Pl2+iPlInfo_Health], a
.end:
	;##
	
	
	; Init other things
	xor  a
	ld   [wPlInfo_Pl1+iPlInfo_HealthVisual], a
	ld   [wPlInfo_Pl2+iPlInfo_HealthVisual], a
	ld   [wPlInfo_Pl1+iPlInfo_Pow], a
	ld   [wPlInfo_Pl2+iPlInfo_Pow], a
	ld   [wPlInfo_Pl1+iPlInfo_PowVisual], a
	ld   [wPlInfo_Pl2+iPlInfo_PowVisual], a
	ld   [wPlInfo_Pl1+iPlInfo_52], a
	ld   [wPlInfo_Pl2+iPlInfo_52], a
	ld   [wPlInfo_Pl1+iPlInfo_MaxPow], a
	ld   [wPlInfo_Pl2+iPlInfo_MaxPow], a
	ld   [wPlInfo_Pl1+iPlInfo_MaxPowVisual], a
	ld   [wPlInfo_Pl2+iPlInfo_MaxPowVisual], a
	ld   [wPlInfo_Pl1+iPlInfo_MaxPowExtraLen], a
	ld   [wPlInfo_Pl2+iPlInfo_MaxPowExtraLen], a
	
	; Load default player sprite mappings.
	ld   hl, wOBJInfo_Pl1+iOBJInfo_Status
	ld   de, OBJInfoInit_Pl1
	call OBJLstS_InitFrom
	ld   hl, wOBJInfo_Pl2+iOBJInfo_Status
	ld   de, OBJInfoInit_Pl2
	call OBJLstS_InitFrom
	ret
; =============== Play_LoadChar ===============
; Loads the settings for the current character in the specfied player struct.
; IN
; - BC: Ptr to wPlInfo struct
Play_LoadChar:

	;
	; In team mode, update the current character ID based on how many team members lost already.
	; CharId = iPlInfo_TeamCharId0 + LossCount
	;
	; This isn't needed in single mode since the character ID already contains a copy of iPlInfo_TeamCharId0 there.
	;
	call IsInTeamMode		; In Team mode?
	jp   nc, .loadCharInfo	; If not, skip

	; A = Loss Count
	ld   hl, iPlInfo_TeamLossCount
	add  hl, bc						; Seek to loss count
	ld   a, [hl]
	
	; In case this is the final round, use the 3rd character
	cp   $03						; Did all three characters lose? (final round only)
	jp   nz, .seekToActive			; If not, skip
	ld   a, $02						; Otherwise, use third member
	
.seekToActive:
	; Index the player struct from iPlInfo_TeamCharId0, where the team member IDs are stored in order.
	ld   hl, iPlInfo_TeamCharId0	
	add  hl, bc						; Seek to first member
	; Offset to the active one
	add  a, l						; HL += A
	jp   nc, .noInc					; Just in case (this always jumps)
	inc  h 							; We never get here
.noInc:
	ld   l, a							
	ld   a, [hl]					; A = CharId from team def
.setActiveChar:
	; Set what we read out as current character
	ld   hl, iPlInfo_CharId
	add  hl, bc				; Seek to char ID
	ld   [hl], a			
	
.loadCharInfo:

	;
	; Load the character-specific settings into the player struct.
	;
	; These settings are stored into a table with $10 byte entries, ordered by character ID.
	; As CharId is already multiplied by 2, multiply the value by $08 to generate the table offset.
	;
	
	; HL = CharId * $08
	ld   hl, iPlInfo_CharId
	add  hl, bc			; Seek to CharId * 2
	ld   l, [hl]		; HL = CharId
	ld   h, $00
REPT 3
	sla  l				; HL <<= 3
	rl   h
ENDR

	; DE = Ptr to table entry
	ld   de, Play_CharHeaderTbl		; HL = Ptr to start of table
	add  hl, de						; Offset to entry
	push hl							; Move ptr to DE
	pop  de
	
	; Load the settings two bytes at a time.
	ld   hl, iPlInfo_Ptr24_Low	; byte0-1
	call .copyPtr
	ld   hl, iPlInfo_MovePtrTable_Low	; byte2-3
	call .copyPtr
	ld   hl, iPlInfo_Ptr28_Low	; byte4-5
	call .copyPtr
	ld   hl, iPlInfo_Ptr28_Bank	; byte6
	call .copyByte
	; [TCRF] The movement speed also comes from the table, but every character uses identical values.
	;        This oddity is also in KOF95, but the feature is unfinished there as that game uses hardcoded speed values instead.
	ld   hl, iPlInfo_SpeedX_Sub		; byte8-9
	call .copyPtr
	ld   hl, iPlInfo_BackSpeedX_Sub	; byteA-B
	call .copyPtr
	ld   hl, iPlInfo_JumpSpeed_Sub	; byteC-D
	call .copyPtr
	ld   hl, iPlInfo_Gravity_Sub	; byteE-F
	call .copyPtr
	ret
; =============== .copyPtr ===============
; Copies a word value from the header to the player struct.
;
; Note that words are stored in the player struct in *big-endian* format,
; while in the header they are stored as standard little-endian.
;
; For this reason, the player struct pointer initially points to the low byte,
; and then is decremented to point to the high byte.
;
; IN
; - DE: Ptr to table entry byte
; - BC: Ptr to low byte of wPlInfo field
; - HL: iPlInfo field
.copyPtr:
	add  hl, bc		; Seek to the specified field
	
	ld   a, [de]	; A = Low byte of ptr
	inc  de			; TablePtr++
	ldd  [hl], a	; Write it to player struct byte1; PlInfoPtr--
	
	ld   a, [de]	; A = High byte of ptr
	inc  de			; TablePtr++
	ld   [hl], a	; Write it to player struct byte0
	ret
	
; =============== .copyByte ===============
; Copies a byte from the header to the player struct.
; For alignment purposes (to avoid having to use a separate ptr table), the header pads
; out 1-byte entries to two bytes, so the second byte gets skipped over before returning.
; IN
; - DE: Ptr to table entry byte
; - BC: Ptr to base wPlInfo struct
; - HL: iPlInfo field
.copyByte:
	add  hl, bc		; Seek to the specified field
	ld   a, [de]	; Read byte from table
	inc  de			; TablePtr++
	ld   [hl], a	; Write it to player struct
	inc  de			; TablePtr++ (skip padding)
	ret

; =============== Play_CharHeaderTbl ===============
; Parent table with character-specific settings.
Play_CharHeaderTbl:
	; CHAR_ID_KYO
	dw L034000 ; iPlInfo_Ptr24
	dw L0370A7 ; iPlInfo_MovePtrTable 
	dp L064052 ; iPlInfo_Ptr28 | BANK $06
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_DAIMON
	dw L034268 ; iPlInfo_Ptr24
	dw L037107 ; iPlInfo_MovePtrTable 
	dp L0578A0 ; iPlInfo_Ptr28 | BANK $05
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_TERRY
	dw L0344D0 ; iPlInfo_Ptr24
	dw L037587 ; iPlInfo_MovePtrTable 
	dp L064CA4 ; iPlInfo_Ptr28 | BANK $06
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_ANDY
	dw L034738 ; iPlInfo_Ptr24
	dw L037167 ; iPlInfo_MovePtrTable 
	dp L066A77 ; iPlInfo_Ptr28 | BANK $06
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_RYO
	dw L0349A0 ; iPlInfo_Ptr24
	dw L037527 ; iPlInfo_MovePtrTable 
	dp L0257D7 ; iPlInfo_Ptr28 | BANK $02
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_ROBERT
	dw L034C08 ; iPlInfo_Ptr24
	dw L0371C7 ; iPlInfo_MovePtrTable 
	dp L025E5C ; iPlInfo_Ptr28 | BANK $02
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_ATHENA
	dw L034E70 ; iPlInfo_Ptr24
	dw L0375E7 ; iPlInfo_MovePtrTable 
	dp L065B3A ; iPlInfo_Ptr28 | BANK $06
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_MAI
	dw L0350D8 ; iPlInfo_Ptr24
	dw L037647 ; iPlInfo_MovePtrTable 
	dp L0652DF ; iPlInfo_Ptr28 | BANK $06
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_LEONA
	dw L035340 ; iPlInfo_Ptr24
	dw L037227 ; iPlInfo_MovePtrTable 
	dp L026846 ; iPlInfo_Ptr28 | BANK $02
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_GEESE
	dw L035810 ; iPlInfo_Ptr24
	dw L037287 ; iPlInfo_MovePtrTable 
	dp L0677C0 ; iPlInfo_Ptr28 | BANK $06
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_KRAUSER
	dw L035A78 ; iPlInfo_Ptr24
	dw L0372E7 ; iPlInfo_MovePtrTable 
	dp L0974E6 ; iPlInfo_Ptr28 | BANK $09
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_MRBIG
	dw L035CE0 ; iPlInfo_Ptr24
	dw L037347 ; iPlInfo_MovePtrTable 
	dp L0671EE ; iPlInfo_Ptr28 | BANK $06
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_IORI
	dw L035F48 ; iPlInfo_Ptr24
	dw L0376A7 ; iPlInfo_MovePtrTable 
	dp L055FF2 ; iPlInfo_Ptr28 | BANK $05
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_MATURE
	dw L0361B0 ; iPlInfo_Ptr24
	dw L0373A7 ; iPlInfo_MovePtrTable 
	dp L056C11 ; iPlInfo_Ptr28 | BANK $05
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_CHIZURU
	dw L036418 ; iPlInfo_Ptr24
	dw L037407 ; iPlInfo_MovePtrTable 
	dp L057362 ; iPlInfo_Ptr28 | BANK $05
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_GOENITZ
	dw L0368E8 ; iPlInfo_Ptr24
	dw L037467 ; iPlInfo_MovePtrTable 
	dp L0A7373 ; iPlInfo_Ptr28 | BANK $0A
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_MRKARATE
	dw L036B50 ; iPlInfo_Ptr24
	dw L0374C7 ; iPlInfo_MovePtrTable 
	dp L027163 ; iPlInfo_Ptr28 | BANK $02
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_OIORI
	dw L036DB8 ; iPlInfo_Ptr24
	dw L0376A7 ; iPlInfo_MovePtrTable 
	dp L055FF2 ; iPlInfo_Ptr28 | BANK $05
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_OLEONA
	dw L0355A8 ; iPlInfo_Ptr24
	dw L037227 ; iPlInfo_MovePtrTable 
	dp L026846 ; iPlInfo_Ptr28 | BANK $02
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_KAGURA
	dw L036680 ; iPlInfo_Ptr24
	dw L037407 ; iPlInfo_MovePtrTable 
	dp L057368 ; iPlInfo_Ptr28 | BANK $05
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
; =============== Play_LoadProjectileOBJInfo ===============
; Loads the OBJInfo for the projectile (including graphics).
; This expects an uncompressed copy of GFXLZ_Projectiles to be in the LZSS buffer,
; as the graphics are copied from there.
Play_LoadProjectileOBJInfo:
	call Task_PassControlFar
	
	ldh  a, [hROMBank]
	push af
		ld   a, BANK(OBJInfoInit_Projectile) ; BANK $01
		ld   [MBC1RomBank], a
		ldh  [hROMBank], a
		
		;
		; The sprite mappings for these don't use dynamic buffered graphics.
		; Instad, they are all loaded to VRAM at the start of the round, loading
		; over the pre-round text.
		;
		
		; Load 1P projectile graphics for current player to $8800
		ld   a, [wPlInfo_Pl1+iPlInfo_CharId]
		ld   de, $8800 ; Tile $00
		call Play_LoadProjectileGFXFromDef
		
		; Load 2P projectile graphics for current player to $8A60
		call Task_PassControlFar
		ld   a, [wPlInfo_Pl2+iPlInfo_CharId]
		ld   de, $8A60 ; Tile $A6
		call Play_LoadProjectileGFXFromDef
		call Task_PassControlFar
		
		; Load the super move sparkles at $8CC0.
		; This is its own separate uncompressed graphic.
		ld   hl, GFX_Play_SuperSparkle
		ld   de, $8CC0 ; Tile $CC
		ld   a, $04
		call Play_LoadProjectileOBJInfo_CopyGFX
		call Task_PassControlFar
		
		; Load all of the OBJInfo and assign their base tile IDs.
		; Those should be the same as the base GFX ptrs.
		ld   a, BANK(OBJInfoInit_Projectile) ; BANK $01
		ld   [MBC1RomBank], a
		ldh  [hROMBank], a
		
		; 1P projectile
		ld   hl, wOBJInfo_Pl1Projectile+iOBJInfo_Status
		ld   de, OBJInfoInit_Projectile
		call OBJLstS_InitFrom
		; Graphics were copied to $8800, leave default $80 as iOBJInfo_TileIDBase
		call Task_PassControlFar
		
		; 2P projectile
		ld   hl, wOBJInfo_Pl2Projectile+iOBJInfo_Status
		ld   de, OBJInfoInit_Projectile
		call OBJLstS_InitFrom
		ld   hl, wOBJInfo3+iOBJInfo_TileIDBase
		ld   [hl], $A6 ; Graphics were copied to $8A60
		call Task_PassControlFar
		
		; 1P Super Sparkle
		ld   hl, wOBJInfo_Pl1SuperSparkle+iOBJInfo_Status
		ld   de, OBJInfoInit_Projectile
		call OBJLstS_InitFrom
		ld   hl, wOBJInfo_Pl1SuperSparkle+iOBJInfo_TileIDBase
		ld   [hl], $CC ; Graphics were copied to $8CC0
		call Task_PassControlFar
		
		; 2P Super Sparkle
		ld   hl, wOBJInfo_Pl2SuperSparkle+iOBJInfo_Status
		ld   de, OBJInfoInit_Projectile
		call OBJLstS_InitFrom
		ld   hl, wOBJInfo_Pl2SuperSparkle+iOBJInfo_TileIDBase
		ld   [hl], $CC ; Graphics were copied to $8CC0
		call Task_PassControlFar
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret
	
; =============== Play_LoadProjectileGFXFromDef ===============
; Copies the projectile graphics from the LZSS buffer to VRAM.
; IN
; -  A: Character ID * 2
; - DE: Ptr to GFX destination in VRAM
Play_LoadProjectileGFXFromDef:

	;
	; Determine which tiles to copy from the buffer through the "ProjGFXDef" structure
	; for the current character.
	; Multiple tile ranges (relative to the buffer) can be defined in these, with
	; the GFX they point to being copied to VRAM.
	;

	; Index the ptr table for those ProjGFXDef structures by character id (*2).
	ld   hl, Play_ProjGFXDefPtrTbl
	add  a, l
	jp   nc, .noInc
	inc  h ; We never get here
.noInc:
	ld   l, a
	
	; Read out ProjGFXDef ptr to HL
	ld   c, [hl]
	inc  hl
	ld   b, [hl]
	push bc
	pop  hl
	
	; If the ptr is null, there's nothing to copy
	ld   a, h
	or   a, L
	jp   z, .ret
	
	; The first 2 tiles are always empty.
	push hl
		ld   hl, $0000
		ld   b, $02
		call FillGFX
		call Task_PassControlFar
	pop  hl
	
	;
	; Iterate over the ProjGFXDef structure and copy the graphics over.
	;
	ldi  a, [hl]		; A = Number of tile ranges ranges to copy
.rangeLoop:
	; For each range definition...
	push af
		ld   c, [hl]	; BC = Starting offset
		inc  hl
		ld   b, [hl]	
		inc  hl
		ldi  a, [hl]	; A = Tiles to copy
		push hl
			; Offset the LZSS buffer by BC
			ld   hl, wLZSS_Buffer
			add  hl, bc
			; Copy what HL points to to VRAM
			call Play_LoadProjectileOBJInfo_CopyGFX
		pop  hl
	pop  af
	dec  a
	jp   nz, .rangeLoop
	call Task_PassControlFar
.ret:
	ret
	
; =============== Play_LoadProjectileOBJInfo_CopyGFX ===============
; Copies the projectile/sparkle graphics during HBlank 2 tiles/frame.
; IN
; - A: Number of tiles to copy
; - HL: Ptr to source GFX
; - DE: Ptr to destination in VRAM
Play_LoadProjectileOBJInfo_CopyGFX:
	srl  a	; A = A / 2, since the loop copies 2 tiles at once.
	
.loopTiles:
	push af
	
		; Copt 2 tiles/frame ($20 bytes total)
		; This was probably chosen due to using 8x16 sprite size.
		ld   b, (TILESIZE*2)/4 ; $08
	.loop:

		; Copy over 4 bytes
	REPT 4
		di
		mWaitForVBlankOrHBlank
		ldi  a, [hl]
		ld   [de], a
		ei
		inc  de
	ENDR
		
		dec  b			; Copied the 2 tiles?
		jp   nz, .loop	; If not, loop
		
		; After copying the 2 tiles, wait for the next frame
		call Task_PassControlFar
	pop  af
	dec  a				; Copied all tiles?
	jp   nz, .loopTiles	; If not, loop
	call Task_PassControlFar
	ret
; =============== Play_ProjGFXDefPtrTbl ===============
; Maps characters to their tile range definitions for projectiles.
; All of these pointers point to BANK $01.
Play_ProjGFXDefPtrTbl:
	dw $0000   					; CHAR_ID_KYO     
	dw $0000  					; CHAR_ID_DAIMON  
	dw ProjGFXDef_Terry 		; CHAR_ID_TERRY   
	dw $0000   					; CHAR_ID_ANDY    
	dw ProjGFXDef_RyoRobert 	; CHAR_ID_RYO     
	dw ProjGFXDef_RyoRobert 	; CHAR_ID_ROBERT  
	dw ProjGFXDef_Athena 		; CHAR_ID_ATHENA  
	dw ProjGFXDef_Mai 			; CHAR_ID_MAI     
	dw ProjGFXDef_Leona			; CHAR_ID_LEONA   
	dw ProjGFXDef_Geese 		; CHAR_ID_GEESE   
	dw ProjGFXDef_Krauser 		; CHAR_ID_KRAUSER 
	dw ProjGFXDef_MrBig 		; CHAR_ID_MRBIG   
	dw ProjGFXDef_Iori 			; CHAR_ID_IORI    
	dw ProjGFXDef_Mature 		; CHAR_ID_MATURE  
	dw ProjGFXDef_ChizuruKagura ; CHAR_ID_CHIZURU 
	dw ProjGFXDef_Goenitz 		; CHAR_ID_GOENITZ 
	dw ProjGFXDef_MrKarate 		; CHAR_ID_MRKARATE
	dw ProjGFXDef_OIori 		; CHAR_ID_OIORI   
	dw ProjGFXDef_OLeona 		; CHAR_ID_OLEONA  
	dw ProjGFXDef_ChizuruKagura ; CHAR_ID_KAGURA  

; =============== Play_DrawHUDBaseAndInitTimer ===============
; Draws the base tilemap (without health bars) for the HUD in the upper section.
; If needed, it also loads the HUD graphics to VRAM.
Play_DrawHUDBaseAndInitTimer:
	; Initialize round timer from settings
	ld   a, [wMatchStartTime]
	ld   [wRoundTime], a
	
	;
	; GFX
	;
	
	; When the first round loads, also load the HUD graphics
	ld   a, [wRoundNum]
	or   a					; RoundNum == 0?
	jp   nz, .drawTimer		; If not, skip
	ld   hl, GFXLZ_Play_HUD
	ld   de, wLZSS_Buffer
	call DecompressLZSS
	ld   hl, wLZSS_Buffer
	ld   de, $8D00
	ld   b, $2C
	call CopyTiles
	
	;
	; TILEMAP
	;
.drawTimer:
	; If the timer is set to infinite, make it always display "99".
	ld   a, [wRoundTime]
	cp   TIMER_INFINITE		; Is it infinite?
	jp   nz, .setSubSec		; If not, jump
	; Temporarily change to "99" to make it draw that
	ld   a, $99
	ld   [wRoundTime], a
	call HomeCall_Play_DrawTime
	; Restore it to infinite so it won't get decremented
	ld   a, TIMER_INFINITE
	ld   [wRoundTime], a
	jp   .drawOther
.setSubSec:
	; Since the timer will decrements, initialize the subsecond timer to 60 frames.
	; This makes the timer tick down every second.
	ld   a, 60	; $3C
	ld   [wRoundTimeSub], a
	call HomeCall_Play_DrawTime
	
.drawOther:
	;
	; Write the other elements of the HUD, which is in the WINDOW
	;
	
	; "TIME" string
	ld   de, BG_Play_HUD_Time
	ld   hl, $9C09
	ld   b, $02			; Width
	ld   c, $01			; Height
	call CopyBGToRect
	
	;--
	
	; [TCRF] The left and right borders get all overwritten
	;        when the health bar contents are drawn to the tilemap.
	;        This is new to 96 -- these borders weren't drawn in 95.
	
	; 1P Health Bar - left border
	ld   de, BG_Play_HUD_HealthBarL
	ld   hl, $9C80
	ld   b, $01
	ld   c, $01
	call CopyBGToRect
	
	; 1P Health Bar - right border
	ld   de, BG_Play_HUD_HealthBarR
	ld   hl, $9C88
	ld   b, $01
	ld   c, $01
	call CopyBGToRect
	
	; 2P Health Bar - left border
	ld   de, BG_Play_HUD_HealthBarL
	ld   hl, $9C8B
	ld   b, $01
	ld   c, $01
	call CopyBGToRect
	
	; 2P Health Bar - right border
	ld   de, BG_Play_HUD_HealthBarR
	ld   hl, $9C93
	ld   b, $01
	ld   c, $01
	call CopyBGToRect
	
	;--
	
	; 1P Marker (tiles)
	ld   de, BG_Play_HUD_1PMarker
	ld   hl, $9C00
	ld   b, $02
	ld   c, $01
	call CopyBGToRect
	
	; 2P Marker (tiles)
	ld   de, BG_Play_HUD_2PMarker
	ld   hl, $9C12
	ld   b, $02
	ld   c, $01
	call CopyBGToRect
	
	;
	; Determine the graphics to copy for the player markers.
	; These are copied to the locations BG_Play_HUD_1PMarker and BG_Play_HUD_2PMarker expect them.
	;
.p1Draw:	
	ld   a, [wPlInfo_Pl1+iPlInfo_Status]
	bit  PSB_CPU, a		; Is 1P a CPU player?
	jp   nz, .p1CPU		; If so, jump
.p1Pl:
	; Copy 1P marker GFX
	ld   hl, GFX_Play_HUD_1PHuman
	ld   de, $8FC0
	call CopyTilesAutoNum
	jp   .p2Draw
.p1CPU:
	; Copy 1P CPU marker GFX
	ld   hl, GFX_Play_HUD_1PCPU
	ld   de, $8FC0
	call CopyTilesAutoNum
	
.p2Draw:
	ld   a, [wPlInfo_Pl2+iPlInfo_Status]
	bit  PSB_CPU, a		; Is 2P a CPU player?
	jp   nz, .p2CPU		; If so, jump
.p2Pl
	; Copy 2P marker GFX
	ld   hl, GFX_Play_HUD_2PHuman
	ld   de, $8FE0
	call CopyTilesAutoNum
	jp   .ret
.p2CPU:
	; Copy 1P CPU marker GFX
	ld   hl, GFX_Play_HUD_2PCPU
	ld   de, $8FE0
	call CopyTilesAutoNum
.ret:
	ret
	
; =============== Play_DrawCharIcons ===============
; Draws the character icons in the HUD.
Play_DrawCharIcons:
	;
	; Team mode and single mode handle the character icons and win markers differently.
	;
	call IsInTeamMode				; In team mode?
	jp   c, Play_DrawCharIcons_Team	; If so, jump
	; Fall-through
	
; =============== Play_DrawCharIcons_Single ===============
Play_DrawCharIcons_Single:
	;
	; In single mode, the player portraits are drawn normally, and to their
	; side there are boxes representing won rounds.
	;
	
	; Load GFX for round markers
	ld   hl, GFX_Play_HUD_SingleWinMarker
	ld   de, $9740
	ld   b, $02
	call CopyTiles
	
	
	;
	; PLAYER 1
	;
.s1P:
	; Draw 1P's character icon
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamCharId0]
	ld   de, $96C0
	ld   hl, $9C41
	ld   c, $6C
	call Char_DrawIconFlipX
	
	;
	; Determine what to draw in the box for the first round.
	;
	; Note that CopyByteIfSingleFinalRound is used, meaning that, on the final round,
	; none of the win markers show up.
	;
	; Which makes sense, considering who wins the round wins the stage.
	;
	ld   a, [wPlInfo_Pl1+iPlInfo_SingleWinCount]
	cp   $01			; WinCount < $01?
	jp   c, .noS1PWin1	; If so, draw the empty box
.okS1PWin1:
	ld   hl, $9C42		; Otherwise, draw the filled box
	ld   c, $74
	call CopyByteIfSingleFinalRound
	jp   .chkS1PWin2
.noS1PWin1:
	ld   hl, $9C42
	ld   c, $75
	call CopyByteIfSingleFinalRound
	
	;
	; Determine what to draw in the box for the second round.
	; Same CopyByteIfSingleFinalRound usage applies.
	; [TCRF] It's impossible to draw a filled second box here, as 2 wins end the round.
	;
.chkS1PWin2:
	ld   a, [wPlInfo_Pl1+iPlInfo_SingleWinCount]
	cp   $02			; WinCount < $02?
	jp   c, .noS1PWin2	; If so, draw the empty box
.unreachable_okS1PWin2:	
	ld   hl, $9C43		; Otherwise, draw the filled box
	ld   c, $74
	call CopyByteIfSingleFinalRound
	jp   .s2P
.noS1PWin2:
	ld   hl, $9C43
	ld   c, $75
	call CopyByteIfSingleFinalRound
	
	;
	; PLAYER 2
	;
.s2P:
	; Identical checks to the player 1 side.
	
	; Draw 2P's character icon
	ld   a, [wPlInfo_Pl2+iPlInfo_TeamCharId0]
	ld   de, $9700
	ld   hl, $9C52
	ld   c, $70
	call Char_DrawIcon
	
	
	ld   a, [wPlInfo_Pl2+iPlInfo_SingleWinCount]
	cp   $01			; WinCount < $01?
	jp   c, .noS2PWin1	; If so, draw the empty box
.okS2PWin1:
	ld   hl, $9C51
	ld   c, $74
	call CopyByteIfSingleFinalRound
	jp   .chkS2PWin2
.noS2PWin1:
	ld   hl, $9C51
	ld   c, $75
	call CopyByteIfSingleFinalRound
	
.chkS2PWin2:
	ld   a, [wPlInfo_Pl2+iPlInfo_SingleWinCount]
	cp   $02			; WinCount < $02?
	jp   c, .noS2PWin2	; If so, draw the empty box
	; [TCRF] For the same reason as 1P.
.unreachable_okS2PWin2:
	ld   hl, $9C50
	ld   c, $74
	call CopyByteIfSingleFinalRound
	jp   .s1P_ret
.noS2PWin2:
	ld   hl, $9C50
	ld   c, $75
	call CopyByteIfSingleFinalRound
.s1P_ret:
	jp   Play_DrawCharIcons_Ret
	
; =============== Play_DrawCharIcons_Team ===============
; Draws the character icons for a team.
; As team members are defeated, their icon is placed in the back and crossed out,
; with other icons moving in front. (purely visual effect, doesn't affect iPlInfo_TeamCharId* values)
Play_DrawCharIcons_Team:
	;
	; Draw normally the icon for the active character on the 1P side.
	;
	; To determine it, the game *could* have read out the value from iPlInfo_CharId,
	; which is guaranteed to be correct by now.
	; Instead, it's using the same logic from Play_LoadChar (which also set iPlInfo_CharId in the first place)
	;
	
	ld   hl, wPlInfo_Pl1+iPlInfo_TeamCharId0		; HL = Ptr to start of team
	; Avoid indexing out of bounds in the final round
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamLossCount]
	cp   $03										; Is this the "FINAL!!" round? (3 losses)
	jp   nz, .t1PActiveIdx							; If not, skip
	ld   a, $02										; Otherwise, use the 3rd team member
	
.t1PActiveIdx:
	; Offset the team ptr by the loss count
	; HL += A
	add  a, l
	jp   nc, .t1PNoIncH
	inc  h ; We never get here
.t1PNoIncH:
	ld   l, a			
	
	; Draw the icon
	ld   a, [hl]		; A = Active char ID
	ld   de, $96C0		; DE = GFX Destination
	ld   hl, $9C41		; HL = BG Destination
	ld   c, $6C			; C = Starting tile ID
	call Char_DrawIconFlipX
	
	;
	; The other two icons are drawn overlapped.
	;
	; The icons are initially drawn separately to a buffer.
	; If needed, crosses are drawn over to mark defeated team members.
	; After that is done, the two icons are merged over, flipped, and copied to VRAM.
	;
	; As the flipping happens later, the icon positions are treated like on the 2P side:
	; - the leftmost icon (wPlaySecIconBuffer) is displayed in the back
	; - the one on the right (wPlaySecIconBuffer+(4 * TILESIZE)) is displayed in front
	;
	
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamLossCount]
	cp   $00			; No losses yet?
	jp   z, .t1PLoss0	; If so, jump
	cp   $01			; 1 loss?
	jp   z, .t1PLoss1	; If so, jump
	jp   .t1PLoss2		; Otherwise, 2 losses (includes final round)
.t1PLoss0:
	; Draw 3rd team member icon on the back
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamCharId2]
	ld   de, wPlaySecIconBuffer
	call Char_DrawIconToTmpBuffer
	; Draw 2nd team member icon on the front
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamCharId1]
	ld   de, wPlaySecIconBuffer+(4 * TILESIZE)
	call Char_DrawIconToTmpBuffer
	jp   .t1PMerge
.t1PLoss1:
	; Keep the icons compacted.
	; If there's no third character, draw the dead member on the front.
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamCharId2]
	cp   CHAR_ID_NONE			; Is there a character in the third slot?
	jp   z, .t1PLoss1No3		; If not, jump
	
	; Draw 1st team member icon crossed out on the back
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamCharId0]
	ld   de, wPlaySecIconBuffer
	call Char_DrawCrossedIconToTmpBuffer1P
	; Draw 3rd team member icon on the front
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamCharId2]
	ld   de, wPlaySecIconBuffer+$40
	call Char_DrawIconToTmpBuffer
	jp   .t1PMerge
.t1PLoss1No3:
	; Draw 1st team member icon crossed out on the front
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamCharId0]
	ld   de, wPlaySecIconBuffer+$40
	call Char_DrawCrossedIconToTmpBuffer1P
	; Draw empty square to the back
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamCharId2]
	ld   de, wPlaySecIconBuffer
	call Char_DrawIconToTmpBuffer
	jp   .t1PMerge
.t1PLoss2:
	; We can only get here with a 3-character team, so no CHAR_ID_NONE check.
	
	; Draw 2nd team member icon crossed out on the back
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamCharId1]
	ld   de, wPlaySecIconBuffer
	call Char_DrawCrossedIconToTmpBuffer1P
	; Draw 1st team member icon crossed out on the front
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamCharId0]
	ld   de, wPlaySecIconBuffer+$40
	call Char_DrawCrossedIconToTmpBuffer1P
.t1PMerge:
	; Merge the icons GFX, copy them to VRAM and update the HUD tilemap
	ld   hl, $9C44	; BG target
	ld   de, $9740	; GFX target
	ld   c, $74		; Tile ID
	call Char_CopySecIconsToVRAM_1P
	
	
	;
	; Same thing for player 2.
	;
	
	;
	; Draw normally the icon for the active character on the 2P side.
	;
	ld   hl, wPlInfo_Pl2+iPlInfo_TeamCharId0		; HL = Ptr to start of team
	ld   a, [wPlInfo_Pl2+iPlInfo_TeamLossCount]
	cp   $03										; Is this the "FINAL!!" round? (3 losses)
	jp   nz, .t2PActiveIdx							; If not, skip
	ld   a, $02										; Otherwise, use the 3rd team member
.t2PActiveIdx:
	; Offset the team ptr by the loss count
	; HL += A
	add  a, l
	jp   nc, .t2PNoIncH
	inc  h ; We never get here
.t2PNoIncH:
	ld   l, a
	
	; Draw the icon
	ld   a, [hl]		; A = Active char ID
	ld   de, $9700		; DE = GFX Destination
	ld   hl, $9C52		; HL = BG Destination
	ld   c, $70			; C = Starting tile ID
	call Char_DrawIcon
	
	;
	; Draw the other two icons
	;
	ld   a, [wPlInfo_Pl2+iPlInfo_TeamLossCount]
	cp   $00			; No losses yet?
	jp   z, .t2PLoss0	; If so, jump
	cp   $01			; 1 loss?
	jp   z, .t2PLoss1	; If so, jump
	jp   .t2PLoss2		; Otherwise, 2 losses (includes final round)
.t2PLoss0:
	; Draw 3rd team member icon on the back
	ld   a, [wPlInfo_Pl2+iPlInfo_TeamCharId2]
	ld   de, wPlaySecIconBuffer
	call Char_DrawIconToTmpBuffer
	; Draw 2nd team member icon on the front
	ld   a, [wPlInfo_Pl2+iPlInfo_TeamCharId1]
	ld   de, wPlaySecIconBuffer+$40
	call Char_DrawIconToTmpBuffer
	jp   .t2PMerge
.t2PLoss1:
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamCharId2]
	cp   CHAR_ID_NONE			; Is there a character in the third slot?
	jp   z, .t2PLoss1No3		; If not, jump
	
	; Draw 1st team member icon crossed out on the back
	ld   a, [wPlInfo_Pl2+iPlInfo_TeamCharId0]
	ld   de, wPlaySecIconBuffer
	call Char_DrawCrossedIconToTmpBuffer2P
	
	; Draw 3rd team member icon on the front
	ld   a, [wPlInfo_Pl2+iPlInfo_TeamCharId2]
	ld   de, wPlaySecIconBuffer+$40
	call Char_DrawIconToTmpBuffer
	jp   .t2PMerge
.t2PLoss1No3:
	; Draw 1st team member icon crossed out on the front
	ld   a, [wPlInfo_Pl2+iPlInfo_TeamCharId0]
	ld   de, wPlaySecIconBuffer+$40
	call Char_DrawCrossedIconToTmpBuffer2P
	; Draw empty square to the back
	ld   a, [wPlInfo_Pl2+iPlInfo_TeamCharId2]
	ld   de, wPlaySecIconBuffer
	call Char_DrawIconToTmpBuffer
	jp   .t2PMerge
.t2PLoss2:
	; Draw 2nd team member icon crossed out on the back
	ld   a, [wPlInfo_Pl2+iPlInfo_TeamCharId1]
	ld   de, wPlaySecIconBuffer
	call Char_DrawCrossedIconToTmpBuffer2P
	; Draw 1st team member icon crossed out on the front
	ld   a, [wPlInfo_Pl2+iPlInfo_TeamCharId0]
	ld   de, wPlaySecIconBuffer+$40
	call Char_DrawCrossedIconToTmpBuffer2P
.t2PMerge:
	; Merge the icons GFX, copy them to VRAM and update the HUD tilemap
	ld   hl, $9C4F
	ld   de, $97A0
	ld   c, $7A
	call Char_CopySecIconsToVRAM_2P
	; Fall-through
Play_DrawCharIcons_Ret:
	ret
	
; =============== IsInTeamMode ===============
; OUT
; - C flag: If set, Team mode is enabled
IsInTeamMode:
	ld   a, [wPlayMode]
	bit  MODEB_TEAM, a	; Playing in Team mode?
	jp   z, .no			; If not, jump
	bit  MODEB_VS, a	; Playing in VS mode?
	jp   nz, .yes		; If so, jump
	jp   .yes
.no:
	scf
	ccf		; C = 0
	ret
.yes:
	scf		; C = 1
	ret
	
; =============== CopyByteIfSingleFinalRound ===============
; Copies the specified value to VRAM only if this is the final round.
; IN
; - C: Value to write
; - HL: Destination ptr to VRAM
CopyByteIfSingleFinalRound:
	; The check this uses is only applicable to Single mode.
	ld   a, [wRoundNum]
	cp   $03				; wRoundNum == 3? (4th round, the "final!!" round in single mode)
	jp   z, .ret			; If so, return
	mWaitForVBlankOrHBlank
	ld   a, c				; Otherwise, write C to HL
	ldi  [hl], a			
.ret:
	ret
	
; =============== Char_DrawIconFlipX ===============
; Draws a 16x16 icon for a character flipped horizontally.
; This is used to draw icons on the P1 side, which face right.
; IN	
; - DE: Ptr to GFX ptr in VRAM
; - HL: Ptr to top-*right* corner of the icon in the tilemap
; - C: Tile number DE points to
; - A: Character ID * 2
;      Multiplied by 2 for convenience when dealing with ptr tables.
Char_DrawIconFlipX:

	push bc
	
		;
		; Generate offset to GFX_Char_Icons.
		; Each "entry" in the table contains 4 tiles ($40 bytes), and the entries
		; are ordered by character ID.
		;
		; Because A is already multiplied by 2 already when calling this function,
		; BC = A * $20
		ld   b, $00
		ld   c, a		; BC = A
REPT 5
		sla  c		 	; << 1  5 times
		rl   b
ENDR
		;--
		; Switch to the bank with icons
		ldh  a, [hROMBank]
		push af
			ld   a, BANK(GFX_Char_Icons) ; BANK $1D
			ld   [MBC1RomBank], a
			ldh  [hROMBank], a
			push hl
				; Offset the GFX table to the location of the needed icon
				ld   hl, GFX_Char_Icons	
				add  hl, bc			; HL = GFX_Char_Icons[BC]
				
				; Copy the next 4 tiles to VRAM flipped horizontally, from *HL to *DE
				ld   b, $04			; B = 4
				call CopyTilesHBlankFlipX	; Copy the tiles over
			pop  hl
		pop  af
		ld   [MBC1RomBank], a
		ldh  [hROMBank], a
	pop  bc
	
	;
	; Update the tilemap to point to the newly copied tiles.
	;
	; As a side effect of the icon GFX being horizontally flipped but still keeping
	; their tile order, now tiles are stored top to bottom, then *right* to *left*.
	;
	; To account for it, a special subroutine is used which updates the tilemap
	; in that order, using incrementing tile IDs as needed.
	; 
	ld   a, c		; A = Initial tile ID for top-right corner
	ld   b, $02		; B = Width in tiles, Icons are 2 tiles large
	call CreateRectIncXFlip_2H ; R to L tilemap set func, 2 tiles high
	ret
	
; =============== Char_DrawIcon ===============
; Draws a 16x16 icon for a character.
; This is used to draw icons on the P2 side, which face left.
; See also: Char_DrawIconFlipX
; IN	
; - DE: Ptr to GFX ptr in VRAM
; - HL: Ptr to top-left corner of the icon in the tilemap
; - C: Tile number DE points to
; - A: Character ID * 2
;      Multiplied by 2 for convenience when dealing with ptr tables.
Char_DrawIcon:
	push bc
	
		; BC = Offset to GFX_Char_Icons.
		ld   b, $00
		ld   c, a		; BC = A
REPT 5
		sla  c		 	; << 1  5 times
		rl   b
ENDR

		; Switch to the bank with icons
		ldh  a, [hROMBank]
		push af
			ld   a, BANK(GFX_Char_Icons) ; BANK $1D
			ld   [MBC1RomBank], a
			ldh  [hROMBank], a
			push hl
				; HL = GFX_Char_Icons[BC]
				ld   hl, GFX_Char_Icons	
				add  hl, bc			
				
				; Copy the next 4 tiles to VRAM from *HL to *DE
				ld   b, $04				; B = Tile count
				call CopyTilesHBlank	
			pop  hl
		pop  af
		ld   [MBC1RomBank], a
		ldh  [hROMBank], a
	pop  bc
	
	; Update the tilemap to point to the newly copied tiles.
	ld   a, c		; A = Initial tile ID for top-right corner
	ld   b, $02		; B = Width in tiles, Icons are 2 tiles large
	call CreateRectInc_2H 	; L to R tilemap set func, 2 tiles high
	ret
	
; =============== Char_DrawCrossedIconToTmpBuffer1P ===============
; Draws a character icon to a temporary buffer of $40 bytes, and then draws a cross over it.
; Player 1 side only.
; IN
; -  A: Character ID (* 2)
; - DE: Ptr to temporary buffer for the icon
Char_DrawCrossedIconToTmpBuffer1P:
	; Draw the normal character icon to a temp buffer
	push de
		call Char_DrawIconToTmpBuffer
	pop  de
	
	;
	; The cross is a bit special since, unlike the main icon, it shouldn't be flipped on the 1P side.
	;
	; The icon however hasn't been flipped yet, so if we were to write the cross normally,
	; the cross would be flipped horizontally too later on.
	;
	; To balance it out, flip the cross here so later on it will be flipped back to normal.
	;
	ldh  a, [hROMBank]
	push af
		ld   a, BANK(GFX_Play_HUD_Cross) ; BANK $1D
		ld   [MBC1RomBank], a
		ldh  [hROMBank], a
		
		; Copy + flip the cross data to a separate buffer away from DE
		push de
			ld   hl, GFX_Play_HUD_Cross
			ld   de, wPlayCrossBuffer
			ld   b, $04
			call CopyTilesHBlankFlipX
			ld   hl, GFX_Play_HUD_Cross_Mask
			ld   de, wPlayCrossMaskBuffer
			ld   b, $04
			call CopyTilesHBlankFlipX
		pop  de
		
		;
		; Flipping the graphics has the side effect of rearranging their "column" order. (see CreateRectInc_2H)
		;
		; As the icons aren't being flipped yet, we have to rearrange back the cross graphics
		; by copying them column by column (2 tiles at a time).
		;
		
		; Tiles on the right first
		ld   hl, wPlayCrossBuffer+$20
		ld   bc, wPlayCrossMaskBuffer+$20
		ld   a, $02
		call CopyTilesOver_Custom
		
		; Then the left side
		ld   hl, wPlayCrossBuffer
		ld   bc, wPlayCrossMaskBuffer
		ld   a, $02
		call CopyTilesOver_Custom
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret
	
; =============== Char_DrawCrossedIconToTmpBuffer2P ===============
; Draws a character icon to a temporary buffer of $40 bytes, and then draws a cross over it.
; Player 2 side only.
; IN
; -  A: Character ID (* 2)
; - DE: Ptr to temporary buffer for the icon
Char_DrawCrossedIconToTmpBuffer2P:
	; Draw the normal character icon to a temp buffer
	push de
		call Char_DrawIconToTmpBuffer
	pop  de
	
	; Draw a cross over it.
	; 2P icons aren't flipped, so nothing special here.
	ldh  a, [hROMBank]
	push af
		ld   a, BANK(GFX_Play_HUD_Cross) ; BANK $1D
		ld   [MBC1RomBank], a
		ldh  [hROMBank], a
		
		ld   hl, GFX_Play_HUD_Cross			; HL = Main cross GFX
		ld   bc, GFX_Play_HUD_Cross_Mask	; DE = Transparency mask
		ld   a, 4*TILESIZE					; A = Tiles to copy
		call CopyTilesOver_Custom
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret
	
; =============== Char_DrawIconToTmpBuffer ===============
; Draws a character icon to a temporary buffer of $40 bytes (4 tiles).
; This is to copy the full 16x16 icons of inactive team members before
; they get merged/cropped together.
; IN
; -  A: Character ID (* 2)
; - DE: Ptr to temporary buffer for the icon
Char_DrawIconToTmpBuffer:

	;
	; If there's no team member defined, draw 4 black tiles to the buffer.
	;
	cp   CHAR_ID_NONE	; Were we given a real character ID?
	jp   nz, .charOk	; If so, jump
	push bc
		ld   b, 4*TILESIZE	; B = Bytes to clear
		xor  a				; A = Clear with
	.ncLoop:
		ld   [de], a		
		inc  de
		dec  b				; Overwrote all 4 tiles?
		jp   nz, .ncLoop	; If not, loop
	pop  bc
	ret
	
.charOk:
	;
	; Otherwise, perform a straight copy of the character icon to the buffer.
	; Do it like Char_DrawIcon, except that the GFX isn't being copied to VRAM.
	;
	push bc
		; BC = Offset to GFX_Char_Icons.
		ld   b, $00
		ld   c, a		; BC = A
REPT 5
		sla  c		 	; << 1  5 times
		rl   b
ENDR

		; Switch to the bank with icons
		ldh  a, [hROMBank]
		push af
			ld   a, BANK(GFX_Char_Icons) ; BANK $1D
			ld   [MBC1RomBank], a
			ldh  [hROMBank], a
			push hl
				; HL = GFX_Char_Icons[BC]
				ld   hl, GFX_Char_Icons	
				add  hl, bc			
				
				;##
				; This is the part different from Char_DrawIcon
				;
				; Copy the next 4 tiles to the buffer from *HL to *DE
				ld   b, 4*TILESIZE	; B = Bytes to copy ($40)
			.loop:
				ldi  a, [hl]		; Read from ROM, SrcPtr++
				ld   [de], a		; Write to WRAM
				inc  de				; DestPtr++
				dec  b				; Copied all bytes?
				jp   nz, .loop		; If not, loop
				;##
			pop  hl
		pop  af
		ld   [MBC1RomBank], a
		ldh  [hROMBank], a
	pop  bc
	ret
	
; =============== Char_CopySecIconsToVRAM_1P ===============
; Merges and copies the character icons for team members "on the back" to VRAM.
; IN
; - HL: Destination ptr for the tilemap in VRAM (top-right corner)
; - DE: Destination ptr for the graphics in VRAM
; - C: Starting tile ID
Char_CopySecIconsToVRAM_1P:
	; Generate the merged graphic to wPlaySecIconBuffer
	call Char_MergeSecIcons
	
	; Copy the 6 tiles to VRAM
	push hl
		ld   hl, wPlaySecIconBuffer
		ld   b, $06
		call CopyTilesHBlankFlipX
	pop  hl
	
	; Generate the 3x2 tilemap to VRAM
	ld   a, c		; A = Tile ID
	ld   b, $03		; B = Rect Width
	call CreateRectIncXFlip_2H
	ret
	
; =============== Char_CopySecIconsToVRAM_2P ===============
; Version of Char_CopySecIconsToVRAM_1P for Player 2.
; IN
; - HL: Destination ptr for the tilemap in VRAM (top-left corner)
; - DE: Destination ptr for the graphics in VRAM
; - C: Starting tile ID
Char_CopySecIconsToVRAM_2P:
	; Generate the merged graphic to wPlaySecIconBuffer
	call Char_MergeSecIcons
	
	; Copy the 6 tiles to VRAM
	push hl
		ld   hl, wPlaySecIconBuffer
		ld   b, $06
		call CopyTilesHBlank
	pop  hl
	
	; Generate the 3x2 tilemap to VRAM
	ld   a, c		; A = Tile ID
	ld   b, $03		; B = Rect Width
	call CreateRectInc_2H
	ret
	
; =============== Char_MergeSecIcons ===============
; Merges the two icons for secondary team players.
; This is accomplished by moving the tile graphics to the left by 4px.
;
; How this works, visually (with pairs representing a tile):
; AA BB -> AB B# 
;
; Meaning that, on repeated loops:
; AA BB CC DD -> AB B# CC DD
; AB B# CC DD -> AB BC C# DD
; AB BC C# DD -> AB BC CD D#
;
;
; NOTE: The graphics are treated here like in the 2P side, where the icon on the left
;       is the one in the "back" (for the 3rd team member). This is only flipped outside.
;
Char_MergeSecIcons:
	push bc
	push de
	push hl
	;--
	
	;
	; To shift nybbles of graphics across tiles, we must know which tile is on the left, and which one is on the right.
	; Because these graphics are fed into CreateRectInc_2H or one of its variations, the icon GFX
	; are consistently ordered top-to-bottom first, then left-to-right (and never right-to-left as they haven't been flipped yet).
	;
	; As the icons are 2 tiles high, for any tile N, tile N+2 is what will be displayed on its right in the tilemap.
	; Get pointers to both of these tiles.
	;
	
	; Tile on the left - Middle part of the 3rd team member icon
	ld   hl, wPlaySecIconBuffer+(2*TILESIZE)				; HL = IconL
	; Tile on the right - Starting part of the 2nd team member icon.
	; This one starting on a new icon is what prevents the final graphic from looking cut off.
	ld   de, wPlaySecIconBuffer+(2*TILESIZE)+(2*TILESIZE)	; DE = IconR
	
	; Only 4 of the 6 tiles need to be changed.
	; The first two (left border of the 3rd icon on the unflipped 2P side) can be kept as-is.
	ld   b, 4*TILESIZE			; B = Bytes to process (4 tiles)
.loop:

	;
	; Shift the tile graphics left by 4px for both IconL and IconR.
	;
	
	;
	; Copy the left half of IconR to the right half of IconL.
	; The left half of IconL remains unchanged, which allows this operation
	; to be repeated in a loop.
	;
	
	; C = Left half of IconL
	ld   a, [hl]	; C = IconL & $F0
	and  a, $F0
	ld   c, a
	; A = Left half of IconR moved right
	ld   a, [de]	; A = (IconR >> 4)
	and  a, $F0
	swap a
	; Merge the two halves 
	or   a, c
	; Write it to IconL
	ldi  [hl], a	; IconPtrL++
	
	;
	; Move the right half of IconR to the left half.
	; The right part is replaced by blank space.
	;
	
	; A = Right half of IconR moved left
	ld   a, [de]	; A = IconR << 4
	and  a, $0F
	swap a
	; Save it back
	ld   [de], a
	inc  de			; IconPtrR++
	
	dec  b			; Processed all bytes?
	jp   nz, .loop	; If not, loop
	
	;--
	pop  hl
	pop  de
	pop  bc
	ret
; =============== CreateRectIncXFlip_2H ===============
; Creates a 2 tile high rectangle, drawn top to bottom, right to left
; with incrementing tile IDs.
; Used when the source graphics are flipped horizontally.
; IN
; - HL: Ptr to tilemap location in VRAM
; - A: Initial Tile ID
; - B: Rectangle width
CreateRectIncXFlip_2H:
	push af
	mWaitForVBlankOrHBlank
	pop  af
	
	ld   [hl], a					; Write TileID at the top
	inc  a							; TileID++
	ld   de, BG_TILECOUNT_H			; Move down 1 tile
	add  hl, de
	ldd  [hl], a					; Write TileID at the bottom, move left 1 tile
	inc  a							; TileID++
	ld   de, -BG_TILECOUNT_H		; Move up 1 tile
	add  hl, de
	dec  b							; WidthLeft--
	jp   nz, CreateRectIncXFlip_2H	; Drawn all columns? If not, loop
	ret
	
; =============== CreateRectInc_2H ===============
; Creates a 2 tile high rectangle, drawn top to bottom, left to right
; with incrementing tile IDs.
; Used when the source graphics aren't flipped.
; IN
; - HL: Ptr to tilemap location in VRAM
; - A: Initial Tile ID
; - B: Rectangle width
CreateRectInc_2H:

	push af
	mWaitForVBlankOrHBlank
	pop  af
	
	ld   [hl], a					; Write TileID at the top
	inc  a							; TileID++
	ld   de, BG_TILECOUNT_H			; Move down 1 tile
	add  hl, de
	ldi  [hl], a					; Write TileID at the bottom, move right 1 tile
	inc  a							; TileID++
	ld   de, -BG_TILECOUNT_H		; Move up 1 tile
	add  hl, de
	dec  b							; WidthLeft--
	jp   nz, CreateRectInc_2H	; Drawn all columns? If not, loop
	ret
	
; =============== Play_HUD_DrawCharNames ===============
; Draws the character names to the HUD.
;
; The names use special text graphics unique to each character,
; which are copied to 6-tile buffers in VRAM (one for each player).
;
; This is handled similarly to the character graphics in the order select screen,
; where there's a compressed block of graphics that is only copied partially to VRAM.
;
Play_HUD_DrawCharNames:

	; Clear out both VRAM GFX buffers with black tiles
	ld   hl, $0000 ; Black line
	ld   b, $06
	ld   de, $9600	; 1P buffer
	call FillGFX
	
	ld   hl, $0000 ; Black line
	ld   b, $06
	ld   de, $9660 ; 2P buffer
	call FillGFX
	
	; Decompress all of the names into a buffer in WRAM
	ld   hl, GFXLZ_Play_HUD_CharNames
	ld   de, wLZSS_Buffer
	call DecompressLZSS
	
	; Copy the needed GFX from said buffer into the VRAM buffers.
	ld   a, [wPlInfo_Pl1+iPlInfo_CharId]
	call Play_HUD_Draw1PCharName
	ld   a, [wPlInfo_Pl2+iPlInfo_CharId]
	call Play_HUD_Draw2PCharName
	ret
	
; =============== Play_HUD_Draw1PCharName ===============
; Draws the character name on the 1P side.
; IN
; - A: Character ID * 2
Play_HUD_Draw1PCharName:

	;
	; HL = Ptr to character name text entry 
	;      (name length + tile IDs relative to GFXLZ_Play_HUD_CharNames).
	;
	
	; Seek to ptr table entry
	ld   b, $00							; BC = CharId * 2
	ld   c, a
	ld   hl, Play_HUD_CharNamesPtrTable ; HL = Ptr table with BGX tilemaps
	add  hl, bc							; Seek to entry
	; Read out the ptr to DE
	ld   e, [hl]	
	inc  hl
	ld   d, [hl]
	; And move it to HL
	push de
	pop  hl
	
	;--
	;
	; The 1P side has the character name aligned to the right.
	;
	; With names being 6 tiles long, this results into a padding at the start of (6 - NameLength) tiles.
	; To account for it, the destination ptr is offset by that amount:
	;   DestPtr = $9600 + (PadCount * TILESIZE)
	;
	; This will leave the skipped tiles black, as the buffer was blanked out before getting here.
	;
	
	ld   b, [hl]		; B = Name length
	inc  hl				; HL = Ptr to "BGX" tilemap
	
	ld   a, $06			; A = Pad tile count (6 - B)
	sub  a, b			
	ld   de, $9600		; DE = Ptr to start of VRAM destination buffer
	
	; Seek the VRAM dest buffer past the padding.
	; DE += A * $10 (TILESIZE)
	push hl		; Save "tilemap" ptr
REPT 4				
		sla  a			; A << 4
ENDR
		ld   h, $00		; HL = A
		ld   l, a
		add  hl, de		; HL += DE
		
		push hl			; Move to DE
		pop  de
	pop  hl		; Restore "tilemap" ptr
	;--
	
	; Copy the GFX to VRAM, according to the "BGX" tilemap HL points to.
	call Play_HUD_CopyCharNameGFX
	
	; Copy the standard tilemap for 1P names
	ld   de, BG_Play_HUD_CharName1P
	ld   hl, $9C02
	ld   b, $06
	ld   c, $01
	call CopyBGToRect
	ret
	
; =============== Play_HUD_Draw2PCharName ===============
; Draws the character name on the 2P side.
; See also: Play_HUD_Draw1PCharName
Play_HUD_Draw2PCharName:

	;
	; HL = Ptr to character name text entry 
	;      (name length + tile IDs relative to GFXLZ_Play_HUD_CharNames).
	;
	
	; Seek to ptr table entry
	ld   b, $00							; BC = CharId * 2
	ld   c, a
	ld   hl, Play_HUD_CharNamesPtrTable ; HL = Ptr table with BGX tilemaps
	add  hl, bc							; Seek to entry
	; Read out the ptr to DE
	ld   e, [hl]	
	inc  hl
	ld   d, [hl]
	; And move it to HL
	push de
	pop  hl
	
	;--
	ldi  a, [hl]		; Read name length; HL = Ptr to "BGX" tilemap
	ld   b, a			; B = Name length
	
	; Copy the GFX to VRAM, according to the "BGX" tilemap HL points to.
	; The 2P side has the character name aligned to the left, so no special handling is needed.
	ld   de, $9660
	call Play_HUD_CopyCharNameGFX
	
	; Copy the standard tilemap for 2P names
	ld   de, BG_Play_HUD_CharName2P
	ld   hl, $9C0C
	ld   b, $06
	ld   c, $01
	call CopyBGToRect
	ret
	
; =============== Play_HUD_CopyCharNameGFX ===============
; Copies the tile graphics for the character name to VRAM.
;
; IN
; - DE: VRAM GFX destination ptr
; - HL: Ptr to source "tilemap", with tile IDs relative to the start of the LZSS Buffer.
; -  B: Number of tiles to copy
Play_HUD_CopyCharNameGFX:
	; Copy 1 tile at a time
	push bc		; Save length
	
		; A = Tile ID
		ldi  a, [hl]
		; Multiply the tile ID by TILESIZE.
		; BC = A * $10
		ld   b, $00
		ld   c, a
	REPT 4			
		sla  c
		rl   b
	ENDR
	
		push hl
			; Seek to the tile to copy
			ld   hl, wLZSS_Buffer
			add  hl, bc
			; And copy it over to VRAM
			ld   b, $01
			call CopyTiles
		pop  hl
	pop  bc		; Restore length
	dec  b								; Copied all tiles?
	jp   nz, Play_HUD_CopyCharNameGFX	; If not, loop
	ret
	
BG_Play_HUD_CharName1P: INCBIN "data/bg/play_hud_charname1p.bin"
; [TCRF] KOF95 leftover, where the name used to be 8 tiles long
BG_Play_HUD_CharName1P_Unused_Extra: INCBIN "data/bg/play_hud_charname1p_unused_extra.bin"
BG_Play_HUD_CharName2P: INCBIN "data/bg/play_hud_charname2p.bin"
BG_Play_HUD_CharName2P_Unused_Extra: INCBIN "data/bg/play_hud_charname2p_unused_extra.bin"
Play_HUD_CharNamesPtrTable:
	dw BGXDef_Play_HUD_CharName_Kyo ; CHAR_ID_KYO     
	dw BGXDef_Play_HUD_CharName_Daimon ; CHAR_ID_DAIMON  
	dw BGXDef_Play_HUD_CharName_Terry ; CHAR_ID_TERRY   
	dw BGXDef_Play_HUD_CharName_Andy ; CHAR_ID_ANDY    
	dw BGXDef_Play_HUD_CharName_Ryo ; CHAR_ID_RYO     
	dw BGXDef_Play_HUD_CharName_Robert ; CHAR_ID_ROBERT  
	dw BGXDef_Play_HUD_CharName_Athena ; CHAR_ID_ATHENA  
	dw BGXDef_Play_HUD_CharName_Mai ; CHAR_ID_MAI     
	dw BGXDef_Play_HUD_CharName_Leona ; CHAR_ID_LEONA   
	dw BGXDef_Play_HUD_CharName_Geese ; CHAR_ID_GEESE   
	dw BGXDef_Play_HUD_CharName_Krauser ; CHAR_ID_KRAUSER 
	dw BGXDef_Play_HUD_CharName_MrBig ; CHAR_ID_MRBIG   
	dw BGXDef_Play_HUD_CharName_Iori ; CHAR_ID_IORI    
	dw BGXDef_Play_HUD_CharName_Mature ; CHAR_ID_MATURE  
	dw BGXDef_Play_HUD_CharName_Chizuru ; CHAR_ID_CHIZURU 
	dw BGXDef_Play_HUD_CharName_Goenitz ; CHAR_ID_GOENITZ 
	dw BGXDef_Play_HUD_CharName_MrKarate ; CHAR_ID_MRKARATE
	dw BGXDef_Play_HUD_CharName_OIori ; CHAR_ID_OIORI   
	dw BGXDef_Play_HUD_CharName_OLeona ; CHAR_ID_OLEONA  
	dw BGXDef_Play_HUD_CharName_Kagura ; CHAR_ID_KAGURA   

; =============== Play_DrawHUDEmptyBars ===============
; Draws the tilemaps for all empty bars in the HUD.
Play_DrawHUDEmptyBars:

	; 1P Health bar
	ld   de, BG_Play_HUD_BlankHealthBar
	ld   hl, $9C20
	ld   b, $09
	ld   c, $01
	call CopyBGToRect
	
	; 2P Health bar
	ld   de, BG_Play_HUD_BlankHealthBar
	ld   hl, $9C2B
	ld   b, $09
	ld   c, $01
	call CopyBGToRect
	
	; Power meter bars (entire line, including POW text)
	ld   de, BG_Play_HUD_BlankPowBar
	ld   hl, $9C80
	ld   b, $14
	ld   c, $01
	call CopyBGToRect
	ret
	
BG_Play_HUD_BlankHealthBar: INCBIN "data/bg/play_hud_blankhealthbar.bin"

; =============== Play_LoadPreRoundTextAndIncRound ===============
; Loads the initial sprite mapping + all graphics for the pre-round text (ie: ROUND 1, READY, GO).
Play_LoadPreRoundTextAndIncRound:
	ldh  a, [hROMBank]
	push af
		ld   a, BANK(GFXLZ_Play_PreRoundText) ; BANK $01
		ld   [MBC1RomBank], a
		ldh  [hROMBank], a
		
		; RoundNum++
		ld   a, [wRoundNum]
		inc  a
		ld   [wRoundNum], a
		
		;
		; Load shared graphics
		;
		
		; Load to a buffer the complete set of graphics for the pre-round text
		ld   hl, GFXLZ_Play_PreRoundText
		ld   de, wLZSS_Buffer
		call DecompressLZSS
		
		; Copy everything except for the round numbers to VRAM, which are the
		; very last thing in the graphics block.
		ld   hl, wLZSS_Buffer	; Start from the beginning
		ld   de, $8800			; Destination
		ld   b, $44				; Copy first $44 tiles
		call CopyTiles
		
		
		;
		; Load one round number graphic
		;
		; Every number is made of 8 unique tiles.
		; With TILESIZE being $10, that makes $80 bytes in total.
		; As the graphics for the numbers are stored in order, we can treat that part of the 
		; uncompressed data as a table of $80 byte entries.
		;

		; Generate the index
		; DE = RoundNum * $80
		ld   a, [wRoundNum]
		sla  a			; << 3
		sla  a
		sla  a
		ld   d, $00
		ld   e, a
	REPT 4				; << 4
		sla  e
		rl   d
	ENDR
	
		;; ld   a, [wRoundNum]
		;; ld   d, a
		;; ld   e, $00
		;; sra  d
		;; rr   e
	
		; HL = Ptr to number GFX needed
		ld   hl, wLZSS_Buffer+$0440	; HL = Ptr to start of number GFX in uncompressed buffer
		add  hl, de					; Offset it
		; Copy it to VRAM
		ld   de, $8C40				
		ld   b, $08
		call CopyTiles
		
		;
		; Load the sprite mapping
		;
		ld   hl, wOBJInfo3+iOBJInfo_Status
		ld   de, OBJInfoInit_Play_PreRoundText
		call OBJLstS_InitFrom
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret
	
; =============== Play_DoPreRoundText ===============
; Handles the pre-round text display while the characters continue their intro animations.
; The same wOBJInfo is used with different sprite mappings for the text.
Play_DoPreRoundText:
	; Display the sprite mapping
	ld   hl, wOBJInfo_RoundText+iOBJInfo_Status
	ld   [hl], OST_VISIBLE
	
	; These mappings are displayed in sequence.
	; The game does nothing else other than animate the sprites.
	
	; "ROUND *" or "FINAL!!"
	ld   a, [wRoundFinal]
	cp   $01			; Is this the final round?
	jp   z, .final		; If so, use "FINAL!!"
.roundX:
	ld   a, PLAY_PREROUND_OBJ_ROUNDX			; Otherwise, use "ROUND *"
	jp   .setRoundTxt
.final:
	ld   a, PLAY_PREROUND_OBJ_FINAL
.setRoundTxt:
	ld   hl, wOBJInfo_RoundText+iOBJInfo_OBJLstPtrTblOffset ; Seek to sprite mapping ID
	ld   [hl], a	
	ld   b, $78			; Display for $78 frames
	call Play_DoIntro
	
	; "READY"
	ld   [hl], PLAY_PREROUND_OBJ_READY
	ld   b, $3C
	call Play_DoIntro
	
	; "GO!!" (small)
	ld   [hl], PLAY_PREROUND_OBJ_GO_SM
	ld   b, $08
	call Play_DoIntro
	
	; "GO!!" (large)
	ld   [hl], PLAY_PREROUND_OBJ_GO_LG
	ld   b, $3C
	call Play_DoIntro
	
	; Hide the sprite mapping.
	ld   hl, wOBJInfo_RoundText+iOBJInfo_Status
	ld   [hl], $00
	call Task_PassControlFar
	ret
	
; =============== Play_DoIntro ===============
; Executes the intro code for the specified amount of frames.
; IN
; - B: Number of frames
Play_DoIntro:
	push hl
	.loop:
		push bc
			; Animate the pre-round text
			ldh  a, [hROMBank]
			push af
				ld   a, BANK(Play_AnimTextPal) ; BANK $01
				ld   [MBC1RomBank], a
				ldh  [hROMBank], a
				call Play_AnimTextPal
			pop  af
			ld   [MBC1RomBank], a
			ldh  [hROMBank], a
			
			; Exec shared subs
			call Play_Intro_Shared
			
			; Wait frame end
			call Task_PassControlFar
		pop  bc
		dec  b
		jp   nz, .loop
	pop  hl
	ret
; =============== Play_Char_SetIntroAnimInstant ===============
; Sets the intro animation for characters where it should begin immediately.
;
; Other characters (like Kyo), first spend 1 second in the normal idle
; pose before starting the intro animation.
; That is instead handled by Play_Char_SetIntroAnimDelayed (separate since the screen isn't fully setup yet).
Play_Char_SetIntroAnimInstant:
	; Try to set 1P's intro move
	ld   bc, wPlInfo_Pl1	
	ld   de, wPlInfo_Pl2
	call .chk
	; Try to set 2P's intro move
	ld   bc, wPlInfo_Pl2
	ld   de, wPlInfo_Pl1
	call .chk
	ret
; =============== .chk ===============
; IN
; - BC: wPlInfo for currently handled player
; - DE: wPlInfo for other player
.chk:
	;
	; All of these characters start their intro animation immediately.
	; 
	ld   hl, iPlInfo_CharId
	add  hl, bc
	ld   a, [hl]					; A = Current
	cp   CHAR_ID_MAI*2				; Playing as Athena?
	jp   z, Play_Char_SetIntroAnim	; If so, jump
	cp   CHAR_ID_ATHENA*2			; ...
	jp   z, Play_Char_SetIntroAnim
	cp   CHAR_ID_LEONA*2
	jp   z, Play_Char_SetIntroAnim
	cp   CHAR_ID_OLEONA*2
	jp   z, Play_Char_SetIntroAnim
	cp   CHAR_ID_IORI*2
	jp   z, Play_Char_SetIntroAnim
	cp   CHAR_ID_OIORI*2
	jp   z, Play_Char_SetIntroAnim
	cp   CHAR_ID_KRAUSER*2
	jp   z, Play_Char_SetIntroAnim
	cp   CHAR_ID_MRKARATE*2
	jp   z, Play_Char_SetIntroAnim
	
	; Otherwise, don't set the anim yet.
	ret
	
; =============== Play_Char_SetIntroAnim ===============
; Sets the intro animation for the player passed throguh BC.
; What's passed through DE is only used for comparison purposes.
; IN
; - BC: wPlInfo for currently handled player
; - DE: wPlInfo for other player
Play_Char_SetIntroAnim:

	;
	; The listed characters have special intro animations when fighting specific characters:
	; - Kyo when fighting Iori (normal or Orochi)
	; - Iori (normal only) when fighting Kyo
	; - Geese when fighting Terry
	;

	ld   hl, iPlInfo_CharId
	add  hl, bc
	ld   a, [hl]
	cp   CHAR_ID_KYO*2		; Playing as Kyo?
	jr   z, .chkKyo			; If so, jump
	cp   CHAR_ID_IORI*2		; Playing as Iori?
	jr   z, .chkIori		; If so, jump
	cp   CHAR_ID_GEESE*2	; Playing as Geese?
	jr   z, .chkGeese		; If so, jump
	
	; Everyone else uses the normal intro animation.
	jr   .noSpec
.chkKyo:
	; If playing as Kyo and...
	ld   hl, iPlInfo_CharId
	add  hl, de
	ld   a, [hl]
	cp   CHAR_ID_IORI*2		; KYO vs IORI?
	jr   z, .isSpec			; If so, jump
	cp   CHAR_ID_OIORI*2	; KYO vs IORI'?
	jr   z, .isSpec			; If so, jump
	jr   .noSpec			; Otherwise, nothing here
.chkIori:
	; If playing as Iori and...
	ld   hl, iPlInfo_CharId
	add  hl, de
	ld   a, [hl]
	cp   CHAR_ID_KYO*2		; IORI vs KYO?
	jr   z, .isSpec			; If so, jump
	jr   .noSpec			; Otherwise, nothing here
.chkGeese:
	; If playing as Geese and...
	ld   hl, iPlInfo_CharId
	add  hl, de
	ld   a, [hl]
	cp   CHAR_ID_TERRY*2	; GEESE vs TERRY?
	jr   z, .isSpec
	jr   .noSpec
.noSpec:
	ld   a, MOVE_SHARED_INTRO		; A = MoveId for Intro
	jr   .save
.isSpec:
	ld   a, MOVE_SHARED_INTRO_SPEC	; A = MoveId for Intro
.save:
	ld   hl, iPlInfo_IntroMoveId
	add  hl, bc						; Seek to iPlInfo_IntroMoveId
	ld   [hl], a					; Write it there
	ret
	
; =============== Play_Char_SetIntroAnimDelayed ===============
; Sets the intro animation for characters that initially start out in their idle anim.
; See also: Play_Char_SetIntroAnimInstant. 

Play_Char_SetIntroAnimDelayed:
	; Wait a second in the idle pose before the intro
	ld   b, 60
	call Play_DoIntro
	
	; Try to set 1P's intro move
	ld   bc, wPlInfo_Pl1
	ld   de, wPlInfo_Pl2
	call .chk
	; Try to set 2P's intro move
	ld   bc, wPlInfo_Pl2
	ld   de, wPlInfo_Pl1
	call .chk
	ret
	
; =============== .chk ===============
; IN
; - BC: wPlInfo for currently handled player
; - DE: wPlInfo for other player
.chk:
	ld   hl, iPlInfo_CharId
	add  hl, bc
	ld   a, [hl]			; A = CharId
	
	; For all of these characters, we have already set the intro move in Play_Char_SetIntroAnimInstant,
	; so leave the move value intact.
	cp   CHAR_ID_ATHENA*2
	jp   z, .ret
	cp   CHAR_ID_MAI*2
	jp   z, .ret
	cp   CHAR_ID_LEONA*2
	jp   z, .ret
	cp   CHAR_ID_OLEONA*2
	jp   z, .ret
	cp   CHAR_ID_IORI*2
	jp   z, .ret
	cp   CHAR_ID_OIORI*2
	jp   z, .ret
	cp   CHAR_ID_KRAUSER*2
	jp   z, .ret
	cp   CHAR_ID_MRKARATE*2
	jp   z, .ret
	
	; Ok, can set the move ID
	jp   Play_Char_SetIntroAnim
.ret:
	ret
	
; =============== Play_Intro_Shared ===============
; Executes the subroutines called by the intro that are part of the main gameplay code.
Play_Intro_Shared:
	ldh  a, [hROMBank]
	push af
	ld   a, BANK(Play_UpdateHealthBars) ; BANK $01 
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	call Play_UpdateHealthBars
	call Play_UpdatePowBars
	call Play_DoTime
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret
; =============== HomeCall_Play_DrawTime ===============
HomeCall_Play_DrawTime:
	ldh  a, [hROMBank]
	push af
	ld   a, BANK(Play_DrawTime) ; BANK $01
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	call Play_DrawTime
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret
	
OBJInfoInit_Pl1:
	db OST_VISIBLE ; iOBJInfo_Status
	db SPR_XFLIP ; iOBJInfo_OBJLstFlags
	db SPR_XFLIP ; iOBJInfo_OBJLstFlagsOld
	db $60 ; iOBJInfo_X
	db $00 ; iOBJInfo_XSub
	db $88 ; iOBJInfo_Y
	db $00 ; iOBJInfo_YSub
	db $00 ; iOBJInfo_SpeedX
	db $00 ; iOBJInfo_SpeedXSub
	db $00 ; iOBJInfo_Unknown_09
	db $00 ; iOBJInfo_Unknown_0A
	db $00 ; iOBJInfo_RelX (auto)
	db $00 ; iOBJInfo_RelY (auto)
	db $00 ; iOBJInfo_TileIDBase
	db LOW($8000) ; iOBJInfo_VRAMPtr_Low
	db HIGH($8000) ; iOBJInfo_VRAMPtr_High
	db BANK(OBJLstPtrTable_Terry_WinA) ; iOBJInfo_BankNum (BANK $09)
	db LOW(OBJLstPtrTable_Terry_WinA) ; iOBJInfo_OBJLstPtrTbl_Low
	db HIGH(OBJLstPtrTable_Terry_WinA) ; iOBJInfo_OBJLstPtrTbl_High
	db $00 ; iOBJInfo_OBJLstPtrTblOffset
	db BANK(OBJLstPtrTable_Terry_WinA) ; iOBJInfo_BankNumOld (BANK $09)
	db LOW(OBJLstPtrTable_Terry_WinA) ; iOBJInfo_OBJLstPtrTbl_LowOld
	db HIGH(OBJLstPtrTable_Terry_WinA) ; iOBJInfo_OBJLstPtrTbl_HighOld
	db $00 ; iOBJInfo_OBJLstPtrTblOffset
	db $00 ; iOBJInfo_OBJLstByte1 (auto)
	db $00 ; iOBJInfo_OBJLstByte2 (auto)
	db $00 ; iOBJInfo_Unknown_1A
	db $00 ; iOBJInfo_FrameLeft
	db $00 ; iOBJInfo_FrameTotal
	db LOW(wGFXBufInfo_Pl1) ; iOBJInfo_BufInfoPtr_Low
	db HIGH(wGFXBufInfo_Pl1) ; iOBJInfo_BufInfoPtr_High

OBJInfoInit_Pl2:
	db OST_VISIBLE ; iOBJInfo_Status
	db SPR_OBP1 ; iOBJInfo_OBJLstFlags
	db SPR_OBP1 ; iOBJInfo_OBJLstFlagsOld
	db $A0 ; iOBJInfo_X
	db $00 ; iOBJInfo_XSub
	db $88 ; iOBJInfo_Y
	db $00 ; iOBJInfo_YSub
	db $00 ; iOBJInfo_SpeedX
	db $00 ; iOBJInfo_SpeedXSub
	db $00 ; iOBJInfo_Unknown_09
	db $00 ; iOBJInfo_Unknown_0A
	db $00 ; iOBJInfo_RelX (auto)
	db $00 ; iOBJInfo_RelY (auto)
	db $40 ; iOBJInfo_TileIDBase
	db LOW($8400) ; iOBJInfo_VRAMPtr_Low
	db HIGH($8400) ; iOBJInfo_VRAMPtr_High
	db BANK(L084000) ; iOBJInfo_BankNum (BANK $08)
	db LOW(L084000) ; iOBJInfo_OBJLstPtrTbl_Low
	db HIGH(L084000) ; iOBJInfo_OBJLstPtrTbl_High
	db $00 ; iOBJInfo_OBJLstPtrTblOffset
	db BANK(L084000) ; iOBJInfo_BankNumOld (BANK $08)
	db LOW(L084000) ; iOBJInfo_OBJLstPtrTbl_LowOld
	db HIGH(L084000) ; iOBJInfo_OBJLstPtrTbl_HighOld
	db $00 ; iOBJInfo_OBJLstPtrTblOffset
	db $00 ; iOBJInfo_OBJLstByte1 (auto)
	db $00 ; iOBJInfo_OBJLstByte2 (auto)
	db $00 ; iOBJInfo_Unknown_1A
	db $00 ; iOBJInfo_FrameLeft
	db $00 ; iOBJInfo_FrameTotal
	db LOW(wGFXBufInfo_Pl2) ; iOBJInfo_BufInfoPtr_Low
	db HIGH(wGFXBufInfo_Pl2) ; iOBJInfo_BufInfoPtr_High
	
L002458:;I
	ld   sp, $DE00
	ei
	ld   bc, wPlInfo_Pl1
	ld   de, wOBJInfo_Pl1+iOBJInfo_Status
	jr   L00246E
L002464:;I
	ld   sp, $DF00
	ei
	ld   bc, wPlInfo_Pl2
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
	call Task_PassControlFar
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
	add  a, l
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
	ld   hl, wOBJInfo_Pl2+iOBJInfo_OBJLstFlags
	jp   L002842
L00283F:;J
	ld   hl, wOBJInfo_Pl1+iOBJInfo_OBJLstFlags
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
	call OBJLstS_ApplyXSpeed
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
	ld   bc, wPlInfo_Pl1
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
	call OBJLstS_DoAnimTiming_Loop
	pop  de
	pop  bc
	ret
L002F15:;C
	push bc
	push de
	push de
	pop  hl
	call OBJLstS_DoAnimTiming_Initial
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
	call Task_PassControlFar
	ld   a, $03
	ld   [$C173], a
	call L00386A
L0033BC:;J
	ld   a, [$C173]
	cp   $04
	jp   z, L0033CF
	cp   $03
	jp   nz, L0033D7
	call Task_PassControlFar
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
	ld   [wStageBGP], a
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
	call OBJLstS_DoAnimTiming_Initial
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
	call OBJLstS_DoAnimTiming_Initial
	pop  de
	pop  bc
	ret
L003444:;C
	push bc
	push de
	call L002849
	push de
	pop  hl
	call OBJLstS_DoAnimTiming_Initial
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
	call OBJLstS_DoAnimTiming_Initial
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
; =============== OBJLstS_ApplyXSpeed ===============
; Moves the sprite horizontally as specified in iOBJInfo_SpeedX and iOBJInfo_SpeedXSub.
; iOBJInfo_X += iOBJInfo_SpeedX
;
; IN
; - HL: Ptr to wOBJInfo
OBJLstS_ApplyXSpeed:
	push bc
		push de
			
			; DE = Ptr to iOBJInfo_X
			ld   hl, iOBJInfo_X
			add  hl, de				; Seek to X position
			push hl
			pop  de
			
			push de
				; H = X position
				ld   a, [de]
				ld   h, a
				inc  de				; iOBJInfo_XSub
				; L = X subpixel position
				ld   a, [de]
				ld   l, a
				
				inc  de				; iOBJInfo_Y
				inc  de				; iOBJInfo_YSub
				inc  de				; iOBJInfo_SpeedX
				
				; B = H speed
				ld   a, [de]
				ld   b, a
				inc  de				; iOBJInfo_SpeedXSub
				; C = H subpixel speed
				ld   a, [de]
				ld   c, a
				
				; Add the speed values to the X position
				add  hl, bc
			pop  de
			
			; Write the updated result to X & XSub
			ld   a, h		; Write iOBJInfo_X
			ld   [de], a
			inc  de
			ld   a, l		; Write iOBJInfo_XSub
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
	call OBJLstS_ApplyXSpeed
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
	call OBJLstS_ApplyXSpeed
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
	ld   [wStageBGP], a
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
	call Task_PassControlFar
	ld   hl, $001A
	add  hl, de
	xor  a
	ld   [hl], a
	call Task_PassControlFar
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
	ld   a, [wOBJInfo_Pl2+iOBJInfo_X]
	ld   b, a
	ld   a, [wOBJInfo_Pl1+iOBJInfo_X]
	ld   [wOBJInfo_Pl2+iOBJInfo_X], a
	ld   a, b
	ld   [wOBJInfo_Pl1+iOBJInfo_X], a
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
	call Task_PassControlFar
	ld   hl, $001A
	add  hl, de
	xor  a
	ld   [hl], a
	call Task_PassControlFar
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
	call Task_PassControlFar
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
	call Task_PassControlFar
	inc  [hl]
	call Task_PassControlFar
	dec  b
	jp   nz, L003B25
	jp   L003B40
L003B34:;J
	inc  [hl]
	call Task_PassControlFar
	dec  [hl]
	call Task_PassControlFar
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
	call Task_PassControlFar
	push hl
	call L002D75
	call L003C18
	jp   c, L003C0E
	call L002F1F
	jp   c, L003C0E
	pop  hl
	dec  [hl]
	dec  [hl]
	call Task_PassControlFar
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
