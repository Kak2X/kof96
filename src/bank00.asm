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
	
; =============== BG_Play_HUDHit ===============
; Tile IDs for the hit count.
BG_Play_HUDHit:
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
; Generally used for "paused" frames, where the game should stop animating
; sprites and playing music.
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
	bit  MISCB_SERIAL_LAG, a		; Is everything frozen?
	jp   nz, VBlank_SetInitialSect	; If so, also skip copying GFX
	ld   a, [wNoCopyGFXBuf]
	or   a							; Is the GFX copying outright disabled?
	jp   nz, VBlank_SetInitialSect	; If so, skip
	jp   VBlank_CopyPl1Tiles						

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
; Generates code to copy a player's graphics to VRAM.
; IN
; - 1: Ptr to wPlInfo structure
; - 2: Ptr to wOBJInfo structure
; - 3: Ptr to wGFXBufInfo structure
mVBlank_CopyPlTiles: MACRO
	ld   a, [\3+iGFXBufInfo_TilesLeftA]
	or   a					; Any tiles left to transfer to buffer 0?
	jp   nz, .copyTo0		; If so, jump
	ld   a, [\3+iGFXBufInfo_TilesLeftB]
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
	sub  a, b								; TilesLeft -= TilesToCopy
	ld   [\3+iGFXBufInfo_TilesLeftA], a		; Update stat
	
	ld   a, [\3+iGFXBufInfo_DestPtr_Low]	; DE = Destination Ptr
	ld   e, a
	ld   a, [\3+iGFXBufInfo_DestPtr_High]
	ld   d, a
	ld   a, [\3+iGFXBufInfo_SrcPtrA_Low]	; HL = Source unc. gfx ptr
	ld   l, a
	ld   a, [\3+iGFXBufInfo_SrcPtrA_High]
	ld   h, a
	ld   a, [\3+iGFXBufInfo_BankA]			; A = Bank number the graphics are in
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	call CopyTiles
	; Save the updated stats back, to resume next time
	ld   a, e
	ld   [\3+iGFXBufInfo_DestPtr_Low], a
	ld   a, d
	ld   [\3+iGFXBufInfo_DestPtr_High], a
	ld   a, l
	ld   [\3+iGFXBufInfo_SrcPtrA_Low], a
	ld   a, h
	ld   [\3+iGFXBufInfo_SrcPtrA_High], a
	jp   .chkCopyEnd
	
.copyTo1:
	; Same thing as before, but with the other buffer
	ld   b, MAX_TILE_BUFFER_COPY
	cp   a, b
	jp   nc, .notLast1
	ld   b, a
.notLast1:
	sub  a, b
	ld   [\3+iGFXBufInfo_TilesLeftB], a
	ld   a, [\3+iGFXBufInfo_DestPtr_Low]
	ld   e, a
	ld   a, [\3+iGFXBufInfo_DestPtr_High]
	ld   d, a
	ld   a, [\3+iGFXBufInfo_SrcPtrB_Low]
	ld   l, a
	ld   a, [\3+iGFXBufInfo_SrcPtrB_High]
	ld   h, a
	ld   a, [\3+iGFXBufInfo_BankB]
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	call CopyTiles
	ld   a, e
	ld   [\3+iGFXBufInfo_DestPtr_Low], a
	ld   a, d
	ld   [\3+iGFXBufInfo_DestPtr_High], a
	ld   a, l
	ld   [\3+iGFXBufInfo_SrcPtrB_Low], a
	ld   a, h
	ld   [\3+iGFXBufInfo_SrcPtrB_High], a
	
.chkCopyEnd:

	; If there aren't any tiles left to copy in the buffer,
	; flag the copy as done so the game can actually decrement the frame timer.
	ld   a, [\3+iGFXBufInfo_TilesLeftA]
	or   a								; TilesLeft != 0?
	jp   nz, .end						; If so, skip
	ld   a, [\3+iGFXBufInfo_TilesLeftB]
	or   a								; TilesLeft != 0?
	jp   nz, .end						; If so, skip
	
.flagEnd:

	; Mark that the buffer operation is complete
	ld   hl, \2+iOBJInfo_Status
	res  OSTB_GFXLOAD, [hl]		; Buffer copied
	set  OSTB_GFXNEWLOAD, [hl]	; It got loaded this frame (gets reset when calling animation func)
	
	;--------
	; 
	; Used in conjunction with Play_Pl_SetMoveDamageNext to update the move damage settings mid-move,
	; syncronized to when the visible frame updates.
	;
	; Note that this is *NOT* used to update the damage values when a new move starts.
	; That's instead handled by Play_Pl_IsMoveLoading, which if needed has to be called manually at the start
	; of a move (MoveC_*).
	; Why isn't this also handling the "new move" handler? Probably related to its special cases ???
	;
	ld   hl, \1+iPlInfo_Flags2
	bit  PF2B_MOVESTART, [hl]		; Was a move started?
	jp   nz, .copySetKey			; If so, skip
	
	;
	; Copy the set of pending fields to the current ones if we were told to, and clear the former range.
	;
	; As long as iPlInfo_MoveDamageValNext is != 0, it means there are new values to copy over.
	; Any time the pending move damage fields are copied to the current set they get cleared,
	; so if they are still 0 it means no new value was set.
	; 
	ld   hl, \1+iPlInfo_MoveDamageValNext	; HL = Source
	ld   de, \1+iPlInfo_MoveDamageVal		; DE = Destination
	ld   a, [hl]
	or   a				; iPlInfo_MoveDamageValNext == 0?
	jp   z, .copySetKey	; If so, skip
	
.copyMoveOpt:
	ld   [de], a	; Copy iPlInfo_MoveDamageValNext to iPlInfo_MoveDamageVal	
	ld   [hl], $00	; Clear iPlInfo_MoveDamageValNext
	inc  de			; SrcPtr++
	inc  hl			; DestPtr++
	
	ld   a, [hl]	; A = iPlInfo_MoveDamageHitAnimIdNext
	ld   [de], a	; Copy iPlInfo_MoveDamageHitAnimIdNext to iPlInfo_MoveDamageHitAnimId	
	ld   [hl], $00	; Clear iPlInfo_MoveDamageHitAnimIdNext
	inc  de			; SrcPtr++
	inc  hl			; DestPtr++
	
	ld   a, [hl]	; A = iPlInfo_MoveDamageFlags3Next
	ld   [de], a	; Copy iPlInfo_MoveDamageFlags3Next to iPlInfo_MoveDamageFlags3	
	ld   [hl], $00	; Clear iPlInfo_MoveDamageFlags3Next
	
	;--------
.copySetKey:
	
	;
	; Sync the sprite mapping settings and unique identifier from the current/pending to displayed fields.
	;
	
	; Set key.
	; This unique identifier tells the wGFXBufInfo init code which settings were the last to be completely applied.
	; There's a special case there if we're switching to a new sprite mapping that's the same as
	; the last one we've loaded (read: it will skip the loading part).
	;
	ld   hl, \3+iGFXBufInfo_SetKey 		; HL = Source
	ld   de, \3+iGFXBufInfo_SetKeyView 	; DE = Destination
	
REPT 5
	ldi  a, [hl]
	ld   [de], a
	inc  de
ENDR
	ld   a, [hl]
	ld   [de], a
	
	; Sprite mapping settings.
	; This isn't necessary for the routine to draw sprite mappings, since it stops using the "*View" fields
	; when the graphics finish loading.
	; However, it is important for the move code since it tends to execute specific code depending on
	; the sprite mapping ID that's currently *visible*.
	ld   a, [\2+iOBJInfo_OBJLstFlags]
	ld   [\2+iOBJInfo_OBJLstFlagsView], a
	ld   a, [\2+iOBJInfo_BankNum]
	ld   [\2+iOBJInfo_BankNumView], a
	ld   a, [\2+iOBJInfo_OBJLstPtrTbl_Low]
	ld   [\2+iOBJInfo_OBJLstPtrTbl_LowView], a
	ld   a, [\2+iOBJInfo_OBJLstPtrTbl_High]
	ld   [\2+iOBJInfo_OBJLstPtrTbl_HighView], a
	ld   a, [\2+iOBJInfo_OBJLstPtrTblOffset]
	ld   [\2+iOBJInfo_OBJLstPtrTblOffsetView], a
.end:
ENDM


;
; 1P
;
;--
; [TCRF] Unreferenced code.
VBlank_Unused_Pl1Checks:
	ld   a, [wPlInfo_Pl1+iPlInfo_Flags1]
	bit  PF1B_HITRECV, a
	jp   nz, VBlank_CopyPl1Tiles
	ld   a, [wPlInfo_Pl1+iPlInfo_Flags2]
	bit  PF2B_HITCOMBO, a
	jp   nz, VBlank_CopyPl1Tiles
	ld   a, [wPlayHitstop]
	or   a
	jp   nz, VBlank_CopyPl1Tiles.end
;--
VBlank_CopyPl1Tiles:
	mVBlank_CopyPlTiles wPlInfo_Pl1, wOBJInfo_Pl1, wGFXBufInfo_Pl1
	jp   VBlank_CopyPl2Tiles

;
; 2P
;
;--
; [TCRF] Unreferenced code
VBlank_Unused_Pl2Checks:
	ld   a, [wPlInfo_Pl2+iPlInfo_Flags1]
	bit  PF1B_HITRECV, a
	jp   nz, VBlank_CopyPl2Tiles
	ld   a, [wPlInfo_Pl2+iPlInfo_Flags2]
	bit  PF2B_HITCOMBO, a
	jp   nz, VBlank_CopyPl2Tiles
	ld   a, [wPlayHitstop]
	or   a
	jp   nz, VBlank_CopyPl2Tiles.end
;--
VBlank_CopyPl2Tiles:
	mVBlank_CopyPlTiles wPlInfo_Pl2, wOBJInfo_Pl2, wGFXBufInfo_Pl2

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
	ldi  a, [hl]				; Read iOBJInfo_OBJLstFlagsView, seek to iOBJInfo_X
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
	; The sprite mapping offset (iOBJInfo_OBJLstPtrTblOffset*) is always a multiple of $04,
	; because each entry in the table has space for 2 sprite mapping pointers (parts A and B).
	;
	; Note that, even though the Current set gets copied to the Old one, the check with
	; OSTB_GFXLOAD still needs to be made, as *NOT* all sprite mappings load their graphics dynamically.
	; Some of those that don't (and therefore, never have OSTB_GFXLOAD set), only have
	; the current set info specified, while having unusable garbage in the old set.
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
		ldi  a, [hl]			; Read iOBJInfo_BankNumView
		ld   [MBC1RomBank], a
		ldh  [hROMBank], a
		; $15
		ld   e, [hl]			; Read iOBJInfo_OBJLstPtrTbl_LowView
		inc  hl
		; $16
		ld   d, [hl]			; Read iOBJInfo_OBJLstPtrTbl_HighView
		inc  hl
		; $17
		ld   c, [hl]			; Read iOBJInfo_OBJLstPtrTblOffsetView
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
	; BYTE 1 - Collision Box ID
	;
	
	; Copy over item1 to byte18
	ldi  a, [hl]	; Read iOBJLstHdrA_ColiBoxId
	ld   [de], a	; Write to iOBJInfo_ColiBoxId
	inc  de
	
	;
	; BYTE 2 - Hitbox ID
	;
	
	; Copy over item2 to byte19
	ldi  a, [hl]	; Read iOBJLstHdrA_HitBoxId
	ld   [de], a	; Write to iOBJInfo_HitboxId
	
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
		res  OSTB_GFXNEWLOAD, [hl]		; Reset when processing
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
		res  OSTB_GFXNEWLOAD, [hl]			; Reset when processing
			
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
		res  OSTB_GFXNEWLOAD, [hl]			; Reset when processing
			
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
		pop  hl								; HL = Ptr to wOBJInfo
		jp   OBJLstS_CommonAnim_End			; We're done for now
		
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
				inc  hl		; Seek to iOBJLstHdrA_ColiBoxId
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
			
			; DE = Ptr to iGFXBufInfo_SetKeyView
			ld   hl, iGFXBufInfo_SetKeyView
			add  hl, bc
			push hl
			pop  de
			
			; HL = Ptr to iGFXBufInfo_SrcPtrA_Low
			ld   hl, iGFXBufInfo_SrcPtrA_Low
			add  hl, bc
			
			; Check if these match:
			; - iGFXBufInfo_SrcPtrA_Low  with iGFXBufInfo_SetKeyView
			; - iGFXBufInfo_SrcPtrA_High with iGFXBufInfo_SetKeyView+1
			; - iGFXBufInfo_BankA        with iGFXBufInfo_SetKeyView+2
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
			; - iGFXBufInfo_SrcPtrB_Low  with iGFXBufInfo_SetKeyView+3
			; - iGFXBufInfo_SrcPtrB_High with iGFXBufInfo_SetKeyView+4
			; - iGFXBufInfo_BankB        with iGFXBufInfo_SetKeyView+5
			; If they don't take the jump			
REPT 2
			ld   a, [de]		; A = CompInfo byte
			cp   a, [hl]		; Does it match the source Set A info?
			jp   nz, .different	; If not, jump
			inc  de
			inc  hl
ENDR
			ld   a, [de]		; A = iGFXBufInfo_SetKeyView+5
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
		set  OSTB_GFXNEWLOAD, a				
		ld   [bc], a
		
		;
		; The buffer info is identical if we got here so there's no need to copy the set keys,
		; but the sprite mapping info in wOBJInfo could still be different.
		;
		
		; Copy over the current wOBJInfo slot info to the old one
		
		; Copy iOBJInfo_OBJLstFlags to iOBJInfo_OBJLstFlagsView
		ld   hl, iOBJInfo_OBJLstFlags
		add  hl, bc
		ldi  a, [hl]
		ld   [hl], a
		
		; Copy iOBJInfo_BankNum-iOBJInfo_OBJLstPtrTblOffset to the old fields
		ld   hl, iOBJInfo_BankNum	; DE = iOBJInfo_BankNum
		add  hl, bc					
		push hl
		pop  de
		ld   hl, iOBJInfo_BankNumView	; BC = iOBJInfo_BankNumView
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
; Copies a "dpr" far pointer.
; IN
; - HL: Source dpr
; - DE: Destination dpr
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
	; Set initial health values.
	ld   a, PLAY_HEALTH_MAX
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
	
	; Create two separate tasks for handling player movement/animation.
	ld   a, $02
	ld   bc, Play_DoPl_1P
	call Task_CreateAt
	
	ld   a, $03
	ld   bc, Play_DoPl_2P
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
	ld   [wStageBGP], a			; No flash
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
	ld   a, BANK(Play_Main) ; BANK $01
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	jp   Play_Main
	
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
	ld   [wPlayHitstop], a
	ld   [wPlayPlThrowActId], a
	ld   [wPlaySlowdownTimer], a
	ld   [wPlaySlowdownSpeed], a
	ld   [wScreenShakeY], a
	ld   [wPlayMaxPowScroll1P], a
	ld   [wPlayMaxPowScroll2P], a
	
	; Set player numbers, mostly used so projectiles know from which players they come from
	xor  a ; PL1
	ld   [wPlInfo_Pl1+iPlInfo_PlId], a
	ld   a, PL2
	ld   [wPlInfo_Pl2+iPlInfo_PlId], a
	
	; Remove every status flag except for the CPU marker
	ld   a, [wPlInfo_Pl1+iPlInfo_Flags0]
	and  a, PF0_CPU
	ld   [wPlInfo_Pl1+iPlInfo_Flags0], a
	ld   a, [wPlInfo_Pl2+iPlInfo_Flags0]
	and  a, PF0_CPU
	ld   [wPlInfo_Pl2+iPlInfo_Flags0], a
	
	; Initialize other player fields
	xor  a
	ld   [wPlInfo_Pl1+iPlInfo_Flags1], a
	ld   [wPlInfo_Pl1+iPlInfo_Flags2], a
	ld   [wPlInfo_Pl1+iPlInfo_Flags3], a
	ld   [wPlInfo_Pl2+iPlInfo_Flags1], a
	ld   [wPlInfo_Pl2+iPlInfo_Flags2], a
	ld   [wPlInfo_Pl2+iPlInfo_Flags3], a
	ld   [wPlInfo_Pl1+iPlInfo_MoveId], a
	ld   [wPlInfo_Pl2+iPlInfo_MoveId], a
	ld   [wPlInfo_Pl1+iPlInfo_IntroMoveId], a
	ld   [wPlInfo_Pl2+iPlInfo_IntroMoveId], a
	ld   [wPlInfo_Pl1+iPlInfo_ColiFlags], a
	ld   [wPlInfo_Pl2+iPlInfo_ColiFlags], a
	ld   [wPlInfo_Pl1+iPlInfo_ColiBoxOverlapX], a
	ld   [wPlInfo_Pl2+iPlInfo_ColiBoxOverlapX], a
	ld   [wPlInfo_Pl1+iPlInfo_DizzyTimeLeft], a
	ld   [wPlInfo_Pl2+iPlInfo_DizzyTimeLeft], a
	ld   [wPlInfo_Pl1+iPlInfo_DizzyNext], a
	ld   [wPlInfo_Pl2+iPlInfo_DizzyNext], a
	ld   [wPlInfo_Pl1+iPlInfo_HitComboRecvSet], a
	ld   [wPlInfo_Pl2+iPlInfo_HitComboRecvSet], a
	ld   [wPlInfo_Pl1+iPlInfo_NoSpecialTimer], a
	ld   [wPlInfo_Pl2+iPlInfo_NoSpecialTimer], a
	ld   a, $FF
	ld   [wPlInfo_Pl1+iPlInfo_PlDistance], a
	ld   [wPlInfo_Pl2+iPlInfo_PlDistance], a
	
	; Initialize stun timers at their capped value.
	ld   a, $67
	ld   [wPlInfo_Pl1+iPlInfo_DizzyProg], a
	ld   [wPlInfo_Pl2+iPlInfo_DizzyProg], a
	ld   [wPlInfo_Pl1+iPlInfo_DizzyProgCap], a
	ld   [wPlInfo_Pl2+iPlInfo_DizzyProgCap], a
	ld   [wPlInfo_Pl1+iPlInfo_GuardBreakProg], a
	ld   [wPlInfo_Pl2+iPlInfo_GuardBreakProg], a
	ld   [wPlInfo_Pl1+iPlInfo_GuardBreakProgCap], a
	ld   [wPlInfo_Pl2+iPlInfo_GuardBreakProgCap], a
	
	; Give visibility to the other player's character id
	ld   a, [wPlInfo_Pl1+iPlInfo_CharId]
	ld   [wPlInfo_Pl2+iPlInfo_CharIdOther], a
	ld   a, [wPlInfo_Pl2+iPlInfo_CharId]
	ld   [wPlInfo_Pl1+iPlInfo_CharIdOther], a
	
	;##
	
	;
	; Determine two things here:
	; - How much health to assign to players
	; - If this is the final round ("FINAL!!")
	;
	; Both have different rules depending on which mode we're in (single or team).
	;
.chkHealth:
	xor  a
	ld   [wRoundFinal], a
	call IsInTeamMode			; Are we in team mode?
	jp   nc, .chkHealthSingle	; If not, jump
	
	;--
.chkHealthTeam:
	;
	; TEAM MODE - HEALTH SETUP
	;
	; At the end of a round, the winner got some health back.
	; Here, at the start of the round, the loser gets his health completely refilled.
	;
	; Note that, before the first round starts, the initial health values are set in Pl_Unknown_InitBeforeStage.
	; That's needed as wLastWinner doesn't get reset between stages.
	;
	
	; If 1P didn't win last round
	ld   a, [wLastWinner]
	bit  PLB1, a				; Did 1P win the last round?
	jp   nz, .chkLastWin2P		; If so, skip
	ld   a, PLAY_HEALTH_MAX		; Otherwise, reset 1P health
	ld   [wPlInfo_Pl1+iPlInfo_Health], a
.chkLastWin2P:
	ld   a, [wLastWinner]
	bit  PLB2, a				; Did 2P win the last round?
	jp   nz, .chkFinalTeam		; If so, skip
	ld   a, PLAY_HEALTH_MAX		; Otherwise, reset 2P health
	ld   [wPlInfo_Pl2+iPlInfo_Health], a
.chkFinalTeam:
	
	;
	; TEAM MODE - FINAL ROUND CHECK
	;
	; If any team has 3 characters defeated, this is the final round.
	;
	
	; Note that it's not necessary to check both -- if the first team 
	; doesn't have 3 losses, the second one doesn't either.
	;
	ld   a, [wPlInfo_Pl1+iPlInfo_TeamLossCount]
	cp   $03					; Is 1P's team defeated?
	jp   z, .setFinalRound		; If so, jump
	ld   a, [wPlInfo_Pl2+iPlInfo_TeamLossCount]
	cp   $03					; Is 2P's team defeated?
	jp   z, .setFinalRound		; If so, jump
	jp   .end
	
.chkHealthSingle:

	;
	; SINGLE MODE
	;
	; Rounds are isolated in single mode, so a FINAL!! round check is all that's needed.
	;
	; In Single mode, the final round is the 4th one.
	;
	ld   a, [wRoundNum]
	cp   $03				; wRoundNum == $03? (4th)
	jp   nz, .setNormRound	; If not, jump
	
.setFinalRound:
	; Enable FINAL!! round
	ld   a, $01
	ld   [wRoundFinal], a
	; Set low health meter for both players
	ld   a, $17
	ld   [wPlInfo_Pl1+iPlInfo_Health], a
	ld   [wPlInfo_Pl2+iPlInfo_Health], a
	jp   .end
.setNormRound:
	; Set max health for both players
	ld   a, PLAY_HEALTH_MAX			
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
	ld   [wPlInfo_Pl1+iPlInfo_MaxPowDecSpeed], a
	ld   [wPlInfo_Pl2+iPlInfo_MaxPowDecSpeed], a
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
	ld   hl, iPlInfo_MoveAnimTblPtr_Low	; byte0-1
	call .copyPtr
	ld   hl, iPlInfo_MoveCodePtrTbl_Low	; byte2-3
	call .copyPtr
	ld   hl, iPlInfo_MoveInputCodePtr_Low	; byte4-5
	call .copyPtr
	ld   hl, iPlInfo_MoveInputCodePtr_Bank	; byte6
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
	dw MoveAnimTbl_Kyo ; iPlInfo_MoveAnimTblPtr
	dw MoveCodePtrTbl_Kyo ; iPlInfo_MoveCodePtrTable 
	dpr MoveInputReader_Kyo ; iPlInfo_MoveInputCodePtr | BANK $06
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_DAIMON
	dw MoveAnimTbl_Daimon ; iPlInfo_MoveAnimTblPtr
	dw MoveCodePtrTbl_Daimon ; iPlInfo_MoveCodePtrTable 
	dpr MoveInputReader_Daimon ; iPlInfo_MoveInputCodePtr | BANK $05
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_TERRY
	dw MoveAnimTbl_Terry ; iPlInfo_MoveAnimTblPtr
	dw MoveCodePtrTbl_Terry ; iPlInfo_MoveCodePtrTable 
	dpr MoveInputReader_Terry ; iPlInfo_MoveInputCodePtr | BANK $06
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_ANDY
	dw MoveAnimTbl_Andy ; iPlInfo_MoveAnimTblPtr
	dw MoveCodePtrTbl_Andy ; iPlInfo_MoveCodePtrTable 
	dpr MoveInputReader_Andy ; iPlInfo_MoveInputCodePtr | BANK $06
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_RYO
	dw MoveAnimTbl_Ryo ; iPlInfo_MoveAnimTblPtr
	dw MoveCodePtrTbl_Ryo ; iPlInfo_MoveCodePtrTable 
	dpr MoveInputReader_Ryo ; iPlInfo_MoveInputCodePtr | BANK $02
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_ROBERT
	dw MoveAnimTbl_Robert ; iPlInfo_MoveAnimTblPtr
	dw MoveCodePtrTbl_Robert ; iPlInfo_MoveCodePtrTable 
	dpr MoveInputReader_Robert ; iPlInfo_MoveInputCodePtr | BANK $02
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_ATHENA
	dw MoveAnimTbl_Athena ; iPlInfo_MoveAnimTblPtr
	dw MoveCodePtrTbl_Athena ; iPlInfo_MoveCodePtrTable 
	dpr MoveInputReader_Athena ; iPlInfo_MoveInputCodePtr | BANK $06
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_MAI
	dw MoveAnimTbl_Mai ; iPlInfo_MoveAnimTblPtr
	dw MoveCodePtrTbl_Mai ; iPlInfo_MoveCodePtrTable 
	dpr MoveInputReader_Mai ; iPlInfo_MoveInputCodePtr | BANK $06
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_LEONA
	dw MoveAnimTbl_Leona ; iPlInfo_MoveAnimTblPtr
	dw MoveCodePtrTbl_Leona ; iPlInfo_MoveCodePtrTable 
	dpr MoveInputReader_Leona ; iPlInfo_MoveInputCodePtr | BANK $02
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_GEESE
	dw MoveAnimTbl_Geese ; iPlInfo_MoveAnimTblPtr
	dw MoveCodePtrTbl_Geese ; iPlInfo_MoveCodePtrTable 
	dpr MoveInputReader_Geese ; iPlInfo_MoveInputCodePtr | BANK $06
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_KRAUSER
	dw MoveAnimTbl_Krauser ; iPlInfo_MoveAnimTblPtr
	dw MoveCodePtrTbl_Krauser ; iPlInfo_MoveCodePtrTable 
	dpr MoveInputReader_Krauser ; iPlInfo_MoveInputCodePtr | BANK $09
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_MRBIG
	dw MoveAnimTbl_MrBig ; iPlInfo_MoveAnimTblPtr
	dw MoveCodePtrTbl_MrBig ; iPlInfo_MoveCodePtrTable 
	dpr MoveInputReader_MrBig ; iPlInfo_MoveInputCodePtr | BANK $06
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_IORI
	dw MoveAnimTbl_Iori ; iPlInfo_MoveAnimTblPtr
	dw MoveCodePtrTbl_Iori ; iPlInfo_MoveCodePtrTable 
	dpr MoveInputReader_Iori ; iPlInfo_MoveInputCodePtr | BANK $05
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_MATURE
	dw MoveAnimTbl_Mature ; iPlInfo_MoveAnimTblPtr
	dw MoveCodePtrTbl_Mature ; iPlInfo_MoveCodePtrTable 
	dpr MoveInputReader_Mature ; iPlInfo_MoveInputCodePtr | BANK $05
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_CHIZURU
	dw MoveAnimTbl_Chizuru ; iPlInfo_MoveAnimTblPtr
	dw MoveCodePtrTbl_Chizuru ; iPlInfo_MoveCodePtrTable 
	dpr MoveInputReader_Chizuru ; iPlInfo_MoveInputCodePtr | BANK $05
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_GOENITZ
	dw MoveAnimTbl_Goenitz ; iPlInfo_MoveAnimTblPtr
	dw MoveCodePtrTbl_Goenitz ; iPlInfo_MoveCodePtrTable 
	dpr MoveInputReader_Goenitz ; iPlInfo_MoveInputCodePtr | BANK $0A
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_MRKARATE
	dw MoveAnimTbl_MrKarate ; iPlInfo_MoveAnimTblPtr
	dw MoveCodePtrTbl_MrKarate ; iPlInfo_MoveCodePtrTable 
	dpr MoveInputReader_MrKarate ; iPlInfo_MoveInputCodePtr | BANK $02
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_OIORI
	dw MoveAnimTbl_OIori ; iPlInfo_MoveAnimTblPtr
	dw MoveCodePtrTbl_Iori ; iPlInfo_MoveCodePtrTable 
	dpr MoveInputReader_Iori ; iPlInfo_MoveInputCodePtr | BANK $05
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_OLEONA
	dw MoveAnimTbl_OLeona ; iPlInfo_MoveAnimTblPtr
	dw MoveCodePtrTbl_Leona ; iPlInfo_MoveCodePtrTable 
	dpr MoveInputReader_Leona ; iPlInfo_MoveInputCodePtr | BANK $02
	db $00 ; Padding
	dw +$0180 ; iPlInfo_SpeedX
	dw -$0100 ; iPlInfo_BackSpeedX
	dw -$0700 ; iPlInfo_JumpSpeed
	dw +$0060 ; iPlInfo_Gravity
	
	; CHAR_ID_KAGURA
	dw MoveAnimTbl_Kagura ; iPlInfo_MoveAnimTblPtr
	dw MoveCodePtrTbl_Chizuru ; iPlInfo_MoveCodePtrTable 
	dpr MoveInputReader_Kagura ; iPlInfo_MoveInputCodePtr | BANK $05
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
		; Instead, they are all loaded to VRAM at the start of the round, loading
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
	or   a, l
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
	ld   a, [wPlInfo_Pl1+iPlInfo_Flags0]
	bit  PF0B_CPU, a		; Is 1P a CPU player?
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
	ld   a, [wPlInfo_Pl2+iPlInfo_Flags0]
	bit  PF0B_CPU, a		; Is 2P a CPU player?
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
	; Note that CopyByteIfNotSingleFinalRound is used, meaning that, on the final round,
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
	call CopyByteIfNotSingleFinalRound
	jp   .chkS1PWin2
.noS1PWin1:
	ld   hl, $9C42
	ld   c, $75
	call CopyByteIfNotSingleFinalRound
	
	;
	; Determine what to draw in the box for the second round.
	; Same CopyByteIfNotSingleFinalRound usage applies.
	; [TCRF] It's impossible to draw a filled second box here, as 2 wins end the round.
	;
.chkS1PWin2:
	ld   a, [wPlInfo_Pl1+iPlInfo_SingleWinCount]
	cp   $02			; WinCount < $02?
	jp   c, .noS1PWin2	; If so, draw the empty box
.unreachable_okS1PWin2:	
	ld   hl, $9C43		; Otherwise, draw the filled box
	ld   c, $74
	call CopyByteIfNotSingleFinalRound
	jp   .s2P
.noS1PWin2:
	ld   hl, $9C43
	ld   c, $75
	call CopyByteIfNotSingleFinalRound
	
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
	call CopyByteIfNotSingleFinalRound
	jp   .chkS2PWin2
.noS2PWin1:
	ld   hl, $9C51
	ld   c, $75
	call CopyByteIfNotSingleFinalRound
	
.chkS2PWin2:
	ld   a, [wPlInfo_Pl2+iPlInfo_SingleWinCount]
	cp   $02			; WinCount < $02?
	jp   c, .noS2PWin2	; If so, draw the empty box
	; [TCRF] For the same reason as 1P.
.unreachable_okS2PWin2:
	ld   hl, $9C50
	ld   c, $74
	call CopyByteIfNotSingleFinalRound
	jp   .s1P_ret
.noS2PWin2:
	ld   hl, $9C50
	ld   c, $75
	call CopyByteIfNotSingleFinalRound
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
	
; =============== CopyByteIfNotSingleFinalRound ===============
; Copies the specified value to VRAM only if this is *NOT* the final round.
; IN
; - C: Value to write
; - HL: Destination ptr to VRAM
CopyByteIfNotSingleFinalRound:
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
		ld   de, OBJInfoInit_Play_RoundText
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
	cp   CHAR_ID_MAI				; Playing as Athena?
	jp   z, Play_Char_SetIntroAnim	; If so, jump
	cp   CHAR_ID_ATHENA				; ...
	jp   z, Play_Char_SetIntroAnim
	cp   CHAR_ID_LEONA
	jp   z, Play_Char_SetIntroAnim
	cp   CHAR_ID_OLEONA
	jp   z, Play_Char_SetIntroAnim
	cp   CHAR_ID_IORI
	jp   z, Play_Char_SetIntroAnim
	cp   CHAR_ID_OIORI
	jp   z, Play_Char_SetIntroAnim
	cp   CHAR_ID_KRAUSER
	jp   z, Play_Char_SetIntroAnim
	cp   CHAR_ID_MRKARATE
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
	cp   CHAR_ID_KYO		; Playing as Kyo?
	jr   z, .chkKyo			; If so, jump
	cp   CHAR_ID_IORI		; Playing as Iori?
	jr   z, .chkIori		; If so, jump
	cp   CHAR_ID_GEESE		; Playing as Geese?
	jr   z, .chkGeese		; If so, jump
	
	; Everyone else uses the normal intro animation.
	jr   .noSpec
.chkKyo:
	; If playing as Kyo and...
	ld   hl, iPlInfo_CharId
	add  hl, de
	ld   a, [hl]
	cp   CHAR_ID_IORI		; KYO vs IORI?
	jr   z, .isSpec			; If so, jump
	cp   CHAR_ID_OIORI		; KYO vs IORI'?
	jr   z, .isSpec			; If so, jump
	jr   .noSpec			; Otherwise, nothing here
.chkIori:
	; If playing as Iori and...
	ld   hl, iPlInfo_CharId
	add  hl, de
	ld   a, [hl]
	cp   CHAR_ID_KYO		; IORI vs KYO?
	jr   z, .isSpec			; If so, jump
	jr   .noSpec			; Otherwise, nothing here
.chkGeese:
	; If playing as Geese and...
	ld   hl, iPlInfo_CharId
	add  hl, de
	ld   a, [hl]
	cp   CHAR_ID_TERRY		; GEESE vs TERRY?
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
	cp   CHAR_ID_ATHENA
	jp   z, .ret
	cp   CHAR_ID_MAI
	jp   z, .ret
	cp   CHAR_ID_LEONA
	jp   z, .ret
	cp   CHAR_ID_OLEONA
	jp   z, .ret
	cp   CHAR_ID_IORI
	jp   z, .ret
	cp   CHAR_ID_OIORI
	jp   z, .ret
	cp   CHAR_ID_KRAUSER
	jp   z, .ret
	cp   CHAR_ID_MRKARATE
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
	db SPR_XFLIP ; iOBJInfo_OBJLstFlagsView
	db $60 ; iOBJInfo_X
	db $00 ; iOBJInfo_XSub
	db $88 ; iOBJInfo_Y
	db $00 ; iOBJInfo_YSub
	db $00 ; iOBJInfo_SpeedX
	db $00 ; iOBJInfo_SpeedXSub
	db $00 ; iOBJInfo_SpeedY
	db $00 ; iOBJInfo_SpeedYSub
	db $00 ; iOBJInfo_RelX (auto)
	db $00 ; iOBJInfo_RelY (auto)
	db $00 ; iOBJInfo_TileIDBase
	db LOW($8000) ; iOBJInfo_VRAMPtr_Low
	db HIGH($8000) ; iOBJInfo_VRAMPtr_High
	db BANK(OBJLstPtrTable_Terry_WinA) ; iOBJInfo_BankNum (BANK $09)
	db LOW(OBJLstPtrTable_Terry_WinA) ; iOBJInfo_OBJLstPtrTbl_Low
	db HIGH(OBJLstPtrTable_Terry_WinA) ; iOBJInfo_OBJLstPtrTbl_High
	db $00 ; iOBJInfo_OBJLstPtrTblOffset
	db BANK(OBJLstPtrTable_Terry_WinA) ; iOBJInfo_BankNumView (BANK $09)
	db LOW(OBJLstPtrTable_Terry_WinA) ; iOBJInfo_OBJLstPtrTbl_LowView
	db HIGH(OBJLstPtrTable_Terry_WinA) ; iOBJInfo_OBJLstPtrTbl_HighView
	db $00 ; iOBJInfo_OBJLstPtrTblOffset
	db $00 ; iOBJInfo_ColiBoxId (auto)
	db $00 ; iOBJInfo_HitboxId (auto)
	db $00 ; iOBJInfo_ForceHitboxId
	db $00 ; iOBJInfo_FrameLeft
	db $00 ; iOBJInfo_FrameTotal
	db LOW(wGFXBufInfo_Pl1) ; iOBJInfo_BufInfoPtr_Low
	db HIGH(wGFXBufInfo_Pl1) ; iOBJInfo_BufInfoPtr_High

OBJInfoInit_Pl2:
	db OST_VISIBLE ; iOBJInfo_Status
	db SPR_OBP1 ; iOBJInfo_OBJLstFlags
	db SPR_OBP1 ; iOBJInfo_OBJLstFlagsView
	db $A0 ; iOBJInfo_X
	db $00 ; iOBJInfo_XSub
	db $88 ; iOBJInfo_Y
	db $00 ; iOBJInfo_YSub
	db $00 ; iOBJInfo_SpeedX
	db $00 ; iOBJInfo_SpeedXSub
	db $00 ; iOBJInfo_SpeedY
	db $00 ; iOBJInfo_SpeedYSub
	db $00 ; iOBJInfo_RelX (auto)
	db $00 ; iOBJInfo_RelY (auto)
	db $40 ; iOBJInfo_TileIDBase
	db LOW($8400) ; iOBJInfo_VRAMPtr_Low
	db HIGH($8400) ; iOBJInfo_VRAMPtr_High
	db BANK(L084000) ; iOBJInfo_BankNum (BANK $08)
	db LOW(L084000) ; iOBJInfo_OBJLstPtrTbl_Low
	db HIGH(L084000) ; iOBJInfo_OBJLstPtrTbl_High
	db $00 ; iOBJInfo_OBJLstPtrTblOffset
	db BANK(L084000) ; iOBJInfo_BankNumView (BANK $08)
	db LOW(L084000) ; iOBJInfo_OBJLstPtrTbl_LowView
	db HIGH(L084000) ; iOBJInfo_OBJLstPtrTbl_HighView
	db $00 ; iOBJInfo_OBJLstPtrTblOffset
	db $00 ; iOBJInfo_ColiBoxId (auto)
	db $00 ; iOBJInfo_HitboxId (auto)
	db $00 ; iOBJInfo_ForceHitboxId
	db $00 ; iOBJInfo_FrameLeft
	db $00 ; iOBJInfo_FrameTotal
	db LOW(wGFXBufInfo_Pl2) ; iOBJInfo_BufInfoPtr_Low
	db HIGH(wGFXBufInfo_Pl2) ; iOBJInfo_BufInfoPtr_High
	
; =============== Play_DoPl_1P ===============
; Task for handling Player 1.
Play_DoPl_1P:
	; Set unique stack pointer for 1P handler
	ld   sp, $DE00
	ei
	; Set wPlInfo & wOBJInfo combination for 1P
	ld   bc, wPlInfo_Pl1
	ld   de, wOBJInfo_Pl1
	jr   Play_DoPl
	
; =============== Play_DoPl_2P ===============
; Task for handling Player 2.
Play_DoPl_2P:
	; Set unique stack pointer for 2P handler
	ld   sp, $DF00
	ei
	; Set wPlInfo & wOBJInfo combination for 12P
	ld   bc, wPlInfo_Pl2
	ld   de, wOBJInfo_Pl2
	
; =============== Play_DoPl ===============
; Common task code for handling a player.
; Mostly to run the move code.
; IN
; - BC: Ptr to wPlInfo structure
; - DE: Ptr to respective wOBJInfo structure
Play_DoPl:
	ld   a, $02 ; BANK $02
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
.mainLoop:
	; Preserve the parameters across calls, allowing this to be generic
	push bc
		push de
			call .go
		pop  de
	pop  bc
	call Task_PassControlFar
	jp   .mainLoop
	
.go:
	; Create base inputs
	call Play_Pl_CreateJoyKeysLH
	; Apply opponent-induced effects (push speed, hitstop)
	call Play_Pl_ChkHitStop				; Did we start a new move from here?
	jp   c, .execMoveCode				; If so, jump
	; Perform the special input reader check (character-specific)
	call Play_Pl_ExecSpecMoveInputCode	; Did we start a new special/super?
	jp   c, .chkHit						; If so, skip checking for normal movement
	; Perform the standard input reader for basic moves
	call Play_Pl_DoBasicMoveInput		; Check normal moves
.chkHit:
	call HomeCall_Play_Pl_DoHit			; Handle attacks that collided with us

.execMoveCode:
	;
	; Execute the code for the currently set move.
	; The move code primarily is used to perform actions when the move animation
	; reaches a certain point. This can be anything from updating the player's movement speed,
	; spawning a projectile, etc...
	; Some moves also transition to a different move depending on the logic, sometimes at the beginning.
	; This is how, for example, neutral jumps set by Play_Pl_DoBasicMoveInput can turn into forward jumps.
	;
	; The same move code can be reused for multiple moves across multiple characters,
	; so labeling them can be tricky.
	;
	push de
	
		; All of the move ptr tables are in BANK $03
		ld   a, BANK(MoveCodePtrTbl_Shared_Base) ; BANK $03
		ld   [MBC1RomBank], a
		ldh  [hROMBank], a
		
		; Read out to DE the move pointer table for the current player.
		; This will only be used for the character-specific moves (.grp01),
		; as other groups will replace DE with an hardcoded value.
		ld   hl, iPlInfo_MoveCodePtrTbl_High
		add  hl, bc		
		ld   d, [hl]
		inc  hl
		ld   e, [hl]
		push de
		
			;
			; The move IDs are grouped in three different "ranges".
			; 
			; - Standard moves ($00-$2E)
			;   (ie: idle, walking, crouch, win anims, ...)
			;   These are shared with every character (every player uses the same move code).
			; - Attacks ($30-$6E)
			;   Both normals, specials and supers.
			;   These are character-specific, but move codes may be reused between characters
			;   for similar moves.
			; - Attacked ($70-$98) ??? Autojump arcs ($70-$98)
			;   These are used when getting attacked (hit, thrown, ...)
			;   Shared with every character.
			;
			; These groups vary across games on this engine.
			; This grouping saves space and is new to 96 -- 95 had no such grouping, every move
			; pointer table was character-specific and defined all of the moves.
			;
			ld   hl, iPlInfo_MoveId
			add  hl, bc
			ld   a, [hl]		; A = Move ID (*2)

			cp   $70			; MoveId >= $70?
			jp   nc, .grp02		; If so, jump
			cp   $30			; MoveId >= $30?
			jp   nc, .grp01		; If so, jump
			
		.grp00:
		; Use fixed move table MoveCodePtrTbl_Shared_Base
		pop  de				; Pop out useless value
		ld   de, MoveCodePtrTbl_Shared_Base	; Set fixed ptr
		push de				; Put it back in the stack
			jp   .getMovePtr
			
		.grp02:
		; Use fixed move table MoveCodePtrTbl_Shared_Hit
		pop  de
		ld   de, MoveCodePtrTbl_Shared_Hit
		push de
			; Subtract the base index for this group
			sub  a, $70
			jp   .getMovePtr
		.grp01:
			; Subtract the base index for this group
			sub  a, $30
			jp   .getMovePtr
	.getMovePtr:
			; Index the current move entry from the move ptr table.
			; As each entry is 3 bytes long and move IDs are multiplied by 2 already
			; (like character IDs), generate the table offset like this:
			; DE = A + (A/2)
			ld   h, $00		; HL = A
			ld   l, a
			srl  a			; L += A / 2
			add  a, l
			ld   l, a
		pop  de
		; Add the offset
		add  hl, de
		
		; Read the table entry
		
		; DE = Move code ptr (bytes0-1)
		ld   e, [hl]
		inc  hl
		ld   d, [hl]
		inc  hl
		; A = Bank number (byte2)
		ld   a, [hl]
		ld   [MBC1RomBank], a	; Switch bank
		ldh  [hROMBank], a
		push de
		pop  hl					; Move ptr to HL
	pop  de						; Restore ptr to wOBJInfo
	
	;
	; Every move code (Move_*) uses these parameters:
	; IN
	; - BC: Ptr to wPlInfo structure
	; - DE: Ptr to respective wOBJInfo structure
	jp   hl
	
; =============== HomeCall_L037707 ===============	
L0024E4:;C
	ldh  a, [hROMBank]
	push af
	ld   a, BANK(L037707) ; BANK $03
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	call L037707
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret
	
; =============== ProjInitS_InitAndGetOBJInfo ===============
; Gets the projectile's wOBJInfo for the current player and initializes its common properties.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
; OUT
; - DE: Ptr to projectile wOBJInfo (wOBJInfo_Pl*Projectile)
; WIPES
; - BC
ProjInitS_InitAndGetOBJInfo:
	;
	; A = Player marker (for the tile ID check)
	;
	ld   hl, iPlInfo_PlId
	add  hl, bc
	ld   a, [hl]
	
	;
	; Seek to the wOBJInfo for the current player's projectile.
	; This will either be  Ptr to wOBJInfo_Pl1Projectile or  Ptr to wOBJInfo_Pl2Projectile.
	; Save its ptr to DE and HL.
	;
	push de			; BC = Ptr to player wOBJInfo
	pop  bc
	ld   hl, (OBJINFO_SIZE*2)+iOBJInfo_Status
	add  hl, bc		; Seek to 2 slots after
	push hl
	pop  de			; Copy it to DE
	
	;
	; Show the projectile
	;
	ld   [hl], OST_VISIBLE
	
	;
	; Set the tile ID base for the projectile depending on the player we're playing as.
	; The values must be consistent with that's written in Play_LoadProjectileOBJInfo
	;
	or   a				; iPlInfo_PlId != PL1?
	jp   nz, .tileId2P	; If so, jump
.tileId1P:
	ld   hl, iOBJInfo_TileIDBase
	add  hl, de		; Seek to iOBJInfo_TileIDBase
	ld   [hl], $80	; Graphics from $8800
	jp   .ret
.tileId2P:
	ld   hl, iOBJInfo_TileIDBase
	add  hl, de		; Seek to iOBJInfo_TileIDBase
	ld   [hl], $A6	; Graphics from $8A60
.ret:
	ret
	
; =============== OBJLstS_Overlap ===============
; Moves an wBJInfo to exactly overlap another one.
; This copies the coordinates and OBJLstFlags from the source (BC) to destination (DE).
;
; IN
; - DE: Ptr to the wOBJInfo structure to be moved
; - BC: Ptr to target wOBJInfo structure (the "other" one)
OBJLstS_Overlap:
	push bc
		;
		; Set up source and destination pointers
		;
		
		; BC = Ptr to source iOBJInfo_X
		ld   hl, iOBJInfo_X
		add  hl, bc			; HL = BC + iOBJInfo_X
		push hl
		pop  bc				; Move back to BC
		
		; DE = Ptr to destination iOBJInfo_X
		ld   hl, iOBJInfo_X
		add  hl, de			; HL = DE + iOBJInfo_X
		
		;
		; Copy the next 4 bytes over (iOBJInfo_X-iOBJInfo_YSub)
		;
REPT 4
		ld   a, [bc]	; A = Source byte
		inc  bc			; SrcPtr++
		ldi  [hl], a	; Write to dest; DestPtr++
ENDR
	pop  bc
	
	;
	; Copy over the byte with sprite mapping flags
	;
	
	; A = Source iOBJInfo_OBJLstFlags
	ld   hl, iOBJInfo_OBJLstFlags
	add  hl, bc
	ld   a, [hl]
	; HL = Ptr to dest iOBJInfo_OBJLstFlags
	ld   hl, iOBJInfo_OBJLstFlags
	add  hl, de
	; Write it over
	ld   [hl], a
	ret

; =============== ProjInit_Leona_BalticLauncher ===============
; Initializes the projectile for Leona's Baltic Launcher.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo	
ProjInit_Leona_BalticLauncher:
	mMvC_PlaySound SCT_15
	push bc
		push de
			; --------------- common projectile init code ---------------
			
			;
			; C flag = If set, we're at max power
			;
			ld   hl, iPlInfo_Pow
			add  hl, bc
			ld   a, [hl]		; A = Pow meter
			cp   PLAY_POW_MAX	; Are we at max power?
			jp   z, .initMaxPow	; If so, jump
			xor  a				; C flag clear
			jp   .getFlags2
		.initMaxPow:
			scf					; C flag set
		.getFlags2:
			;
			; A = iPlInfo_Flags2
			;
			ld   hl, iPlInfo_Flags2
			push af				; Preserve C flag for this
				add  hl, bc		; Seek to iPlInfo_Flags2
			pop  af
			ld   a, [hl]		; Read out to A
			
			push af ; Save A & C flag
				
				call ProjInitS_InitAndGetOBJInfo	; DE = Ptr to wOBJInfo_Pl*Projectile
				
				; Set code pointer
				ld   hl, iOBJInfo_Play_CodeBank
				add  hl, de
				ld   [hl], BANK(ProjC_Leona_BalticLauncher)	; BANK $02 ; iOBJInfo_Play_CodeBank
				inc  hl
				ld   [hl], LOW(ProjC_Leona_BalticLauncher)	; iOBJInfo_Play_CodePtr_Low
				inc  hl
				ld   [hl], HIGH(ProjC_Leona_BalticLauncher)	; iOBJInfo_Play_CodePtr_High

				; Write sprite mapping ptr for this projectile.
				ld   hl, iOBJInfo_BankNum
				add  hl, de
				ld   [hl], BANK(OBJLstPtrTable_Leona_BalticLauncher)	; BANK $01 ; iOBJInfo_BankNum
				inc  hl
				ld   [hl], LOW(OBJLstPtrTable_Leona_BalticLauncher)		; iOBJInfo_OBJLstPtrTbl_Low
				inc  hl
				ld   [hl], HIGH(OBJLstPtrTable_Leona_BalticLauncher)	; iOBJInfo_OBJLstPtrTbl_High
				inc  hl
				ld   [hl], $00	; iOBJInfo_OBJLstPtrTblOffset
				
				; Set animation speed.
				ld   hl, iOBJInfo_FrameLeft
				add  hl, de
				ld   [hl], $01	; iOBJInfo_FrameLeft
				inc  hl
				ld   [hl], $01	; iOBJInfo_FrameTotal
				
				; Set priority value
				ld   hl, iOBJInfo_Play_Priority
				add  hl, de
				ld   [hl], $00
				
				; Set initial position relative to the player's origin
				call OBJLstS_Overlap
				mMvC_SetMoveH +$1000
				mMvC_SetMoveV -$0800
				
			;
			; Determine projectile properties depending on Max POW / LH attack type.
			; Projectiles spawned by heavy attacks travel faster and longer.
			;	
			pop  af						; Restore A & C flag
			jp   nc, .fldNoMaxPow		; Are we at max power? If not, jump
		.fldMaxPow:	
			bit  PF2B_HEAVY, a			; Was this an heavy attack?
			jp   nz, .fldHeavyMaxPow	; If so, jump
			jp   .fldLight
		.fldNoMaxPow:
			bit  PF2B_HEAVY, a			; Was this an heavy attack?
			jp   nz, .fldHeavy			; If so, jump
			
		.fldLight:
			ld   hl, iOBJInfo_Play_EnaTimer
			add  hl, de
			ld   [hl], $1E ; Frames before despawn
			ld   hl, $0000 ; H Speed (no movement)
			jp   .setSpeed
		.fldHeavy:
			ld   hl, iOBJInfo_Play_EnaTimer
			add  hl, de
			ld   [hl], $23 ; Frames before despawn
			ld   hl, $0100 ; H Speed (1px/frame)
			jp   .setSpeed
		.fldHeavyMaxPow:
			ld   hl, iOBJInfo_Play_EnaTimer
			add  hl, de
			ld   [hl], $28 ; Frames before despawn
			ld   hl, $0200 ; H Speed (1px/frame)
		.setSpeed:
			call Play_OBJLstS_SetSpeedH_ByXFlipR
		pop  de
	pop  bc
	ret
	
; =============== ProjInit_Leona_VSlasher ===============
; Initializes the projectile for Leona's V Slasher.
; This has a fixed position and disappears after 1 second.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
ProjInit_Leona_VSlasher:
	push bc
		push de
			; A = CharId
			ld   hl, iPlInfo_CharId
			add  hl, bc
			ld   a, [hl]
			
			push af	; Save CharId
				push af	; Save CharId
					; A = MoveId
					ld   hl, iPlInfo_MoveId
					add  hl, bc
					ld   a, [hl]
					push af	; Save MoveId
					
						; DE = Ptr to wOBJInfo_Pl*Projectile
						call ProjInitS_InitAndGetOBJInfo
						
						; Set code pointer
						ld   hl, iOBJInfo_Play_CodeBank
						add  hl, de
						ld   [hl], BANK(ProjC_NoMove)	; BANK $05 ; iOBJInfo_Play_CodeBank
						inc  hl
						ld   [hl], LOW(ProjC_NoMove)	; iOBJInfo_Play_CodePtr_Low
						inc  hl
						ld   [hl], HIGH(ProjC_NoMove)	; iOBJInfo_Play_CodePtr_High
						
					;--
					;
					; Write sprite mapping ptr for this projectile.
					;
					; The super and desperation versions of the move use different sprite mappings.
					; When playing as O.Leona, another different set of sprite mappings is used.
					;
					pop  af	; A = MoveId
					cp   MOVE_LEONA_V_SLASHER_D		; Using the desperation super version?
					jp   z, .objLstD				; If so, jump
				.objLstS:
				
				pop  af	; A = CharId
				cp   CHAR_ID_LEONA		; Playing as normal LEONA?
				jp   nz, .objLstO		; If not, jump
				
				; Super -> Normal V
				ld   hl, iOBJInfo_BankNum
				add  hl, de
				ld   [hl], BANK(OBJLstPtrTable_Proj_Leona_VSlasherS)	; BANK $01 ; iOBJInfo_BankNum
				inc  hl
				ld   [hl], LOW(OBJLstPtrTable_Proj_Leona_VSlasherS)		; iOBJInfo_OBJLstPtrTbl_Low
				inc  hl
				ld   [hl], HIGH(OBJLstPtrTable_Proj_Leona_VSlasherS)	; iOBJInfo_OBJLstPtrTbl_High
				inc  hl
				ld   [hl], $00	; iOBJInfo_OBJLstPtrTblOffset
				
				jp   .setAnimSpeed
				
				.objLstD:
				pop  af
				cp   CHAR_ID_LEONA		; Playing as normal LEONA?
				jp   nz, .objLstO		; If not, jump
				
				; Desperation -> Large V
				ld   hl, iOBJInfo_BankNum
				add  hl, de
				ld   [hl], BANK(OBJLstPtrTable_Proj_Leona_VSlasherD)	; BANK $01 ; iOBJInfo_BankNum
				inc  hl
				ld   [hl], LOW(OBJLstPtrTable_Proj_Leona_VSlasherD)		; iOBJInfo_OBJLstPtrTbl_Low
				inc  hl
				ld   [hl], HIGH(OBJLstPtrTable_Proj_Leona_VSlasherD)	; iOBJInfo_OBJLstPtrTbl_High
				inc  hl
				ld   [hl], $00	; iOBJInfo_OBJLstPtrTblOffset
				
				jp   .setAnimSpeed
				
			.objLstO:
				; Orochi -> Skull wall
				
				ld   hl, iOBJInfo_BankNum
				add  hl, de
				ld   [hl], BANK(OBJLstPtrTable_Proj_OLeona_VSlasher)	; BANK $01 ; iOBJInfo_BankNum
				inc  hl
				ld   [hl], LOW(OBJLstPtrTable_Proj_OLeona_VSlasher)		; iOBJInfo_OBJLstPtrTbl_Low
				inc  hl
				ld   [hl], HIGH(OBJLstPtrTable_Proj_OLeona_VSlasher)	; iOBJInfo_OBJLstPtrTbl_High
				inc  hl
				ld   [hl], $00	; iOBJInfo_OBJLstPtrTblOffset
				
				; This also plays a SFX
				mMvC_PlaySound SND_ID_28
				jp   .setAnimSpeed
				;--
			.setAnimSpeed:
			
				; Set animation speed.
				ld   hl, iOBJInfo_FrameLeft
				add  hl, de
				ld   [hl], $00	; iOBJInfo_FrameLeft
				inc  hl
				ld   [hl], ANIMSPEED_INSTANT	; iOBJInfo_FrameTotal
				
				; Set priority and despawn timer
				ld   hl, iOBJInfo_Play_Priority
				add  hl, de
				ld   [hl], $00	; iOBJInfo_Play_Priority
				inc  hl
				ld   [hl], 60	; iOBJInfo_Play_EnaTimer
				
				; Set initial position relative to the player's origin
				call OBJLstS_Overlap
				
			pop  af ; A = CharId
			cp   CHAR_ID_LEONA
			jp   nz, .moveOLeona
		.moveLeona:
			; When playing as LEONA, the projectile is diagonally down.
			mMvC_SetMoveH +$1000
			mMvC_SetMoveV -$0800
			jp   .end
		.moveOLeona:
			; When playing as O.Leona, the projectile is aligned to the ground.
			; This is because it's a full-height skull wall.
			mMvC_SetMoveH +$1000
			ld   hl, iOBJInfo_Y
			add  hl, de
			ld   [hl], PL_FLOOR_POS
		.end:
		pop  de
	pop  bc
	ret
	
; =============== ProjInit_MrKarate_KoOuKen ===============
; Initializes the projectile for Mr.Karate's Ko Ou Ken.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
ProjInit_MrKarate_KoOuKen:
	mMvC_PlaySound SND_ID_28
	
	push bc
		push de
		
			; --------------- common projectile init code ---------------
			
			;
			; C flag = If set, we're at max power
			;
			ld   hl, iPlInfo_Pow
			add  hl, bc
			ld   a, [hl]		; A = Pow meter
			cp   PLAY_POW_MAX	; Are we at max power?
			jp   z, .initMaxPow	; If so, jump
			xor  a				; C flag clear
			jp   .getFlags2
		.initMaxPow:
			scf					; C flag set
		.getFlags2:
			;
			; A = iPlInfo_Flags2
			;
			ld   hl, iPlInfo_Flags2
			push af				; Preserve C flag for this
				add  hl, bc		; Seek to iPlInfo_Flags2
			pop  af
			ld   a, [hl]		; Read out to A
			
			push af ; Save A & C flag
				
				call ProjInitS_InitAndGetOBJInfo	; DE = Ptr to wOBJInfo_Pl*Projectile
				
				; --------------- main ---------------
				
				; Write sprite mapping ptr for this projectile.
				ld   hl, iOBJInfo_BankNum
				add  hl, de
				ld   [hl], BANK(OBJLstPtrTable_Proj_MrKarate_KoOuKen)	; BANK $01 ; iOBJInfo_BankNum
				inc  hl
				ld   [hl], LOW(OBJLstPtrTable_Proj_MrKarate_KoOuKen)	; iOBJInfo_OBJLstPtrTbl_Low
				inc  hl
				ld   [hl], HIGH(OBJLstPtrTable_Proj_MrKarate_KoOuKen)	; iOBJInfo_OBJLstPtrTbl_High
				inc  hl
				ld   [hl], $00	; iOBJInfo_OBJLstPtrTblOffset
				
				; Set priority value
				ld   hl, iOBJInfo_Play_Priority
				add  hl, de
				ld   [hl], $00
			
				; Set code pointer
				ld   hl, iOBJInfo_Play_CodeBank
				add  hl, de
				ld   [hl], BANK(ProjC_Horz)	; BANK $06 ; iOBJInfo_Play_CodeBank
				inc  hl
				ld   [hl], LOW(ProjC_Horz)	; iOBJInfo_Play_CodePtr_Low
				inc  hl
				ld   [hl], HIGH(ProjC_Horz)	; iOBJInfo_Play_CodePtr_High
				
				; Set animation speed.
				ld   hl, iOBJInfo_FrameLeft
				add  hl, de
				ld   [hl], $00	; iOBJInfo_FrameLeft
				inc  hl
				ld   [hl], ANIMSPEED_INSTANT	; iOBJInfo_FrameTotal
				
				; Set initial position relative to the player's origin
				call OBJLstS_Overlap
				mMvC_SetMoveH +$1C00
				mMvC_SetMoveV -$0400
				
			;
			; Determine projectile horizontal speed.
			;
		
			pop  af	; Restore A & C flag
			jp   nc, .spdMaxPow			; Are we at max power? If not, jump
			bit  PF2B_HEAVY, a			; Was this an heavy attack?
			jp   nz, .spdHeavy			; If so, jump
			jp   .spdLight
		.spdMaxPow:
			bit  PF2B_HEAVY, a			; Was this an heavy attack?
			jp   nz, .spdHeavyMaxPow	; If so, jump
		.spdLight:
			ld   hl, +$0180
			jp   .setSpeed
		.spdHeavyMaxPow:
			ld   hl, +$0300
			jp   .setSpeed
		.spdHeavy:
			ld   hl, +$0500
		.setSpeed:
			call Play_OBJLstS_SetSpeedH_ByXFlipR
			
		pop  de
	pop  bc
	ret
	
; =============== ProjInit_HaohShokohKenS ===============
; Initializes the large projectile for the super version of Haoh Shokoh Ken.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
ProjInit_HaohShokohKenS:
	mMvC_PlaySound SCT_15
	push bc
		push de
		
			; --------------- common projectile init code ---------------
			
			;
			; C flag = If set, we're at max power
			;
			ld   hl, iPlInfo_Pow
			add  hl, bc
			ld   a, [hl]		; A = Pow meter
			cp   PLAY_POW_MAX	; Are we at max power?
			jp   z, .initMaxPow	; If so, jump
			xor  a				; C flag clear
			jp   .getFlags2
		.initMaxPow:
			scf					; C flag set
		.getFlags2:
			;
			; A = iPlInfo_Flags2
			;
			ld   hl, iPlInfo_Flags2
			push af				; Preserve C flag for this
				add  hl, bc		; Seek to iPlInfo_Flags2
			pop  af
			ld   a, [hl]		; Read out to A
			
			push af ; Save A & C
				
				call ProjInitS_InitAndGetOBJInfo	; DE = Ptr to wOBJInfo_Pl*Projectile
				
				; --------------- main ---------------
				
				; Write sprite mapping ptr for this projectile.
				ld   hl, iOBJInfo_BankNum
				add  hl, de
				ld   [hl], BANK(OBJLstPtrTable_Proj_HaohShokohKenS)	; BANK $01 ; iOBJInfo_BankNum
				inc  hl
				ld   [hl], LOW(OBJLstPtrTable_Proj_HaohShokohKenS)	; iOBJInfo_OBJLstPtrTbl_Low
				inc  hl
				ld   [hl], HIGH(OBJLstPtrTable_Proj_HaohShokohKenS)	; iOBJInfo_OBJLstPtrTbl_High
				inc  hl
				ld   [hl], $00	; iOBJInfo_OBJLstPtrTblOffset
				
				; Set priority value
				ld   hl, iOBJInfo_Play_Priority
				add  hl, de
				ld   [hl], $01
				
				jp   ProjInit_HaohShokohKenD.initShared
	
; =============== ProjInit_HaohShokohKenD ===============
; Initializes the large projectile for the super desperation version of Haoh Shokoh Ken.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
ProjInit_HaohShokohKenD:
	mMvC_PlaySound SCT_13
	
	push bc
		push de
		
			; --------------- common projectile init code ---------------
			
			;
			; C flag = If set, we're at max power
			;
			ld   hl, iPlInfo_Pow
			add  hl, bc
			ld   a, [hl]		; A = Pow meter
			cp   PLAY_POW_MAX	; Are we at max power?
			jp   z, .initMaxPow	; If so, jump
			xor  a				; C flag clear
			jp   .getFlags2
		.initMaxPow:
			scf					; C flag set
		.getFlags2:
			;
			; A = iPlInfo_Flags2
			;
			ld   hl, iPlInfo_Flags2
			push af				; Preserve C flag for this
				add  hl, bc		; Seek to iPlInfo_Flags2
			pop  af
			ld   a, [hl]		; Read out to A
			
			push af ; Save A & C flag
				
				call ProjInitS_InitAndGetOBJInfo	; DE = Ptr to wOBJInfo_Pl*Projectile
				
				; --------------- main ---------------
				
				; Write sprite mapping ptr for this projectile.
				ld   hl, iOBJInfo_BankNum
				add  hl, de
				ld   [hl], BANK(OBJLstPtrTable_Proj_HaohShokohKenD)	; BANK $01 ; iOBJInfo_BankNum
				inc  hl
				ld   [hl], LOW(OBJLstPtrTable_Proj_HaohShokohKenD)	; iOBJInfo_OBJLstPtrTbl_Low
				inc  hl
				ld   [hl], HIGH(OBJLstPtrTable_Proj_HaohShokohKenD)	; iOBJInfo_OBJLstPtrTbl_High
				inc  hl
				ld   [hl], $00	; iOBJInfo_OBJLstPtrTblOffset
				
				; Set priority value
				ld   hl, iOBJInfo_Play_Priority
				add  hl, de
				ld   [hl], $02

				; Common code between S and D init
			.initShared:
			
				; Set code pointer
				ld   hl, iOBJInfo_Play_CodeBank
				add  hl, de
				ld   [hl], BANK(ProjC_Horz)	; BANK $06 ; iOBJInfo_Play_CodeBank
				inc  hl
				ld   [hl], LOW(ProjC_Horz)	; iOBJInfo_Play_CodePtr_Low
				inc  hl
				ld   [hl], HIGH(ProjC_Horz)	; iOBJInfo_Play_CodePtr_High
				
				; Set animation speed.
				; Since these don't use the GFX buffer, using ANIMSPEED_INSTANT will animate the projectile every frame.
				ld   hl, iOBJInfo_FrameLeft
				add  hl, de
				ld   [hl], $00	; iOBJInfo_FrameLeft
				inc  hl
				ld   [hl], ANIMSPEED_INSTANT	; iOBJInfo_FrameTotal
				
				; Set initial position
				call OBJLstS_Overlap 	; Relative to the player's origin
				mMvC_SetMoveH +$1000	; $10px forward
				mMvC_SetMoveV -$0800	; $08px above
				
			;
			; Determine projectile horizontal speed.
			; There are different settings for light, heavy and heavy at max power.
			;
		
			pop  af	; Restore A & C flag
			jp   nc, .spdMaxPow			; Are we at max power? If not, jump
			bit  PF2B_HEAVY, a			; Was this an heavy attack?
			jp   nz, .spdHeavy			; If so, jump
			jp   .spdLight
		.spdMaxPow:
			bit  PF2B_HEAVY, a			; Was this an heavy attack?
			jp   nz, .spdHeavyMaxPow	; If so, jump
		.spdLight:
			ld   hl, +$0180
			jp   .setSpeed
		.spdHeavyMaxPow:
			ld   hl, +$0300
			jp   .setSpeed
		.spdHeavy:
			ld   hl, +$0500
		.setSpeed:
			call Play_OBJLstS_SetSpeedH_ByXFlipR
			
		pop  de
	pop  bc
	ret
	
; =============== ProjInit_Iori_YamiBarai ===============
; Initializes the projectile for Iori's 108 Shiki Yami Barai.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
ProjInit_Iori_YamiBarai:
	mMvC_PlaySound SCT_15
	
	push bc
		push de
		
			; --------------- common projectile init code ---------------
			
			;
			; C flag = If set, we're at max power
			;
			ld   hl, iPlInfo_Pow
			add  hl, bc
			ld   a, [hl]		; A = Pow meter
			cp   PLAY_POW_MAX	; Are we at max power?
			jp   z, .initMaxPow	; If so, jump
			xor  a				; C flag clear
			jp   .getFlags2
		.initMaxPow:
			scf					; C flag set
		.getFlags2:
			;
			; A = iPlInfo_Flags2
			;
			ld   hl, iPlInfo_Flags2
			push af				; Preserve C flag for this
				add  hl, bc		; Seek to iPlInfo_Flags2
			pop  af
			ld   a, [hl]		; Read out to A
			
			push af ; Save A & C flag
				
				call ProjInitS_InitAndGetOBJInfo	; DE = Ptr to wOBJInfo_Pl*Projectile
				
				; --------------- main ---------------
			
				; Set code pointer
				ld   hl, iOBJInfo_Play_CodeBank
				add  hl, de
				ld   [hl], BANK(ProjC_Horz)	; BANK $06 ; iOBJInfo_Play_CodeBank
				inc  hl
				ld   [hl], LOW(ProjC_Horz)	; iOBJInfo_Play_CodePtr_Low
				inc  hl
				ld   [hl], HIGH(ProjC_Horz)	; iOBJInfo_Play_CodePtr_High
				
				; Write sprite mapping ptr for this projectile.
				ld   hl, iOBJInfo_BankNum
				add  hl, de
				ld   [hl], BANK(OBJLstPtrTable_Proj_Iori_YamiBarai)	; BANK $01 ; iOBJInfo_BankNum
				inc  hl
				ld   [hl], LOW(OBJLstPtrTable_Proj_Iori_YamiBarai)	; iOBJInfo_OBJLstPtrTbl_Low
				inc  hl
				ld   [hl], HIGH(OBJLstPtrTable_Proj_Iori_YamiBarai)	; iOBJInfo_OBJLstPtrTbl_High
				inc  hl
				ld   [hl], $00	; iOBJInfo_OBJLstPtrTblOffset

				
				; Set animation speed.
				ld   hl, iOBJInfo_FrameLeft
				add  hl, de
				ld   [hl], $00	; iOBJInfo_FrameLeft
				inc  hl
				ld   [hl], ANIMSPEED_INSTANT	; iOBJInfo_FrameTotal
				
				; Set priority value
				ld   hl, iOBJInfo_Play_Priority
				add  hl, de
				ld   [hl], $00
				
				; Set initial position relative to the player's origin
				call OBJLstS_Overlap
				mMvC_SetMoveH +$0800
				
			;
			; Determine projectile horizontal speed.
			;
		
			pop  af	; Restore A & C flag
			jp   nc, .fldMaxPow			; Are we at max power? If not, jump
			bit  PF2B_HEAVY, a			; Was this an heavy attack?
			jp   nz, .fldHeavy			; If so, jump
			jp   .fldLight
		.fldMaxPow:
			bit  PF2B_HEAVY, a			; Was this an heavy attack?
			jp   nz, .fldHeavyMaxPow	; If so, jump
		.fldLight:
			ld   hl, +$0100
			jp   .setSpeed
		.fldHeavyMaxPow:
			ld   hl, +$0200
			jp   .setSpeed
		.fldHeavy:
			ld   hl, +$0400
		.setSpeed:
			call Play_OBJLstS_SetSpeedH_ByXFlipR
			
		pop  de
	pop  bc
	ret
; =============== Pl_CopyXFlipToOther ===============
; Makes the opponent visually face the same direction as the current player.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
Pl_CopyXFlipToOther:
	push de
		; D = SPR_XFLIP flag for current player
		ld   hl, iOBJInfo_OBJLstFlags
		add  hl, de
		ld   a, [hl]
		and  a, SPR_XFLIP
		ld   d, a
		
		; HL = Ptr to opponent's OBJLst flags
		ld   hl, iPlInfo_PlId
		add  hl, bc
		ld   a, [hl]		; A = iPlInfo_PlId
		or   a				; A != PL1?
		jp   nz, .pl2		; If so, jump
	.pl1:
		; 1P gets 2P's flags
		ld   hl, wOBJInfo_Pl2+iOBJInfo_OBJLstFlags
		jp   .sync
	.pl2:
		; 2P gets 1P's flags
		ld   hl, wOBJInfo_Pl1+iOBJInfo_OBJLstFlags
	.sync:
	
		; Replace the opponent's SPR_XFLIP flag with ours
		ld   a, [hl]			; A = Opponent's OBJLst flags
		and  a, $FF^SPR_XFLIP	; Remove SPR_XFLIP flag
		or   a, d				; Copy over ours
		ld   [hl], a			; Save back updated value
	pop  de
	ret
	
; =============== Pl_SetNewMove ===============
; Shared code for updating the wPlInfo when starting a new move.
; IN
; - A: Move ID
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
Pl_SetNewMove:
	push bc
		push de
			; Set that we started a new move
			ld   hl, iPlInfo_Flags2
			add  hl, bc
			set  PF2B_MOVESTART, [hl]
			
			; Set the new move ID
			ld   hl, iPlInfo_MoveId
			add  hl, bc
			ld   [hl], a
			
			; Blank out iPlInfo_JoyMergedKeysLH in case it was used to check for inputs
			ld   hl, iPlInfo_JoyMergedKeysLH
			add  hl, bc
			ld   [hl], $00
			
			;
			; Update the wOBJInfo fields depending on the move we selected.
			;
			; This will index iPlInfo_MoveAnimTblPtr by MoveId, and copy the valuses
			; from there to the wOBJInfo and wPlInfo.
			;
			; Most importantly, the sprite mapping pointer gets updated among these.
			;
			
			;--
			;
			; HL = Ptr to move animation table ptr
			;
			ld   hl, iPlInfo_MoveAnimTblPtr_High
			add  hl, bc					
			push hl	; Save HL
			
				; BC = Starting destination for wPlInfo fields
				ld   hl, iPlInfo_OBJLstPtrTblOffsetMoveEnd		
				add  hl, bc				
				push hl
				pop  bc
				
				; DE = Starting destination for wOBJInfo fields
				ld   hl, iOBJInfo_BankNum	
				add  hl, de
				push hl
				pop  de
			pop  hl
			
			push de ; Restore HL
			
				;
				; Switch to BANK $03, as all move animation tables are stored there.
				; [POI] Unsafe ROM bank switch, will break if VBLANK triggers here.
				;
				push af
					ld   a, BANK(MoveAnimTbl_Marker) ; BANK $03
					ld   [MBC1RomBank], a
				pop  af
			
				;
				; DE = Ptr to start of the move animation table for this player.
				;
				ld   d, [hl]	; D = iPlInfo_MoveAnimTblPtr_High
				inc  hl
				ld   e, [hl]	; E = iPlInfo_MoveAnimTblPtr_Low
				
				;
				; Generate the offset to the table entry from the Move Id.
				;
				; Each entry in the table is 8 bytes long.
				; Considering MoveId is already multiplied by 2 for easy indexing,
				; this means we have to multiply it by 4.
				;
				ld   h, $00
				ld   l, a		; HL = MoveId (*2)
				add  hl, hl		; * 2
				add  hl, hl		; * 2
				
				; HL = Ptr to table entry
				add  hl, de		
			pop  de
			
			; Copy the data over
			
			; byte0 -> iOBJInfo_BankNum
			ldi  a, [hl]
			ld   [de], a
			inc  de
			
			; byte1 -> iOBJInfo_OBJLstPtrTbl_Low
			ldi  a, [hl]
			ld   [de], a
			inc  de
			
			; byte2 -> iOBJInfo_OBJLstPtrTbl_High
			ldi  a, [hl]
			ld   [de], a
			inc  de
			
			; byte3 -> iPlInfo_OBJLstPtrTblOffsetMoveEnd
			ldi  a, [hl]
			ld   [bc], a	
			inc  bc			; Seek to iPlInfo_MoveDamageVal
			
			; Always reset the animation from the beginning
			xor  a
			ld   [de], a	; iOBJInfo_OBJLstPtrTblOffset = 0
			inc  de			; Seek to iOBJInfo_BankNumView
			
			; Seek the wOBJInfo destination ptr (DE) to iOBJInfo_FrameLeft.
			; As we're currently on iOBJInfo_BankNumView...
			push hl
				ld   hl, iOBJInfo_FrameLeft-iOBJInfo_BankNumView
				add  hl, de		; HL = DE + 7
				push hl
				pop  de			; DE = HL
			pop  hl
			
			
			; Initialize animation speed
			
			; byte4 -> iOBJInfo_FrameLeft
			ldi  a, [hl]
			ld   [de], a
			inc  de
			
			; byte4 -> iOBJInfo_FrameTotal
			ld   [de], a
			
			
			; Prepare the damage-related fields for the new move.
			; While the graphics for the first sprite mapping in the animation load, prevent the visible
			; one ("Old Set"), from dealing further damage to avoid inconsistencies.
			; The move code (MoveC_*) may decide to manually call Play_Pl_IsMoveLoading to check
			; and copy over the pending damage fields to the visible set when it's ready.
			
			; Clear current damage fields
			xor  a
			ld   [bc], a	; iPlInfo_MoveDamageVal
			inc  bc
			ld   [bc], a	; iPlInfo_MoveDamageHitAnimId
			inc  bc
			ld   [bc], a	; iPlInfo_MoveDamageFlags3
			inc  bc
			
			; Set pending damage fields
	
			; byte5 -> iPlInfo_MoveDamageValNext
			ldi  a, [hl]
			ld   [bc], a
			inc  bc
			
			; byte6 -> iPlInfo_MoveDamageHitAnimIdNext
			ldi  a, [hl]
			ld   [bc], a
			inc  bc
			
			; byte7 -> iPlInfo_MoveDamageFlags3Next
			ld   a, [hl]
			ld   [bc], a
			
			; Restore original ROM bank
			ldh  a, [hROMBank]
			ld   [MBC1RomBank], a
		pop  de
	pop  bc
	ret
	
; =============== ExOBJS_Play_ChkHitModeAndMoveH ===============
; Moves the specified projectile horizontally and handles its hit mode.
; IN
; - DE: Ptr to wOBJInfo
; OUT
; - C flag; If set, the OBJInfo can be despawned
ExOBJS_Play_ChkHitModeAndMoveH:

	;
	; If the sprite goes past the edges of the screen, it can be despawned.
	;
	ld   hl, iOBJInfo_RelX
	add  hl, de
	ld   a, [hl]
	cp   OBJ_OFFSET_X+$00		; A < 0?
	jp   c, .retSet				; If so, jump
	cp   OBJ_OFFSET_X+SCREEN_H	; A >= screen width?
	jp   nc, .retSet			; If so, jump
	
	;
	; Handle sprite hit modes, applicable to projectiles only.
	; These are related to the collision detection against the opponent.
	;
	ld   hl, iOBJInfo_Play_HitMode
	add  hl, de
	ld   a, [hl]
	cp   PHM_REMOVE		; Did it get removed? (ie: projectile hit the target)
	jp   z, .chkRemove	; If so, jump
	cp   PHM_REFLECT	; Did it get reflected?
	jp   z, .chkReflect	; If so, jump
	
	; Otherwise, just move the sprite horizontally
.move:
	call OBJLstS_ApplyXSpeed
.retClear:
	xor  a	; C flag clear
	ret
	
.chkRemove:
	; Despawn the projectiles only if it has its priority value < $03.
	; Undespawnable projectiles that deal continuous damage or those for special effects use this value.
	ld   hl, iOBJInfo_Play_Priority
	add  hl, de
	ld   a, [hl]
	cp   PROJ_PRIORITY_NODESPAWN		; iOBJInfo_Play_Priority >= $03?
	jp   nc, .move	; If so, jump
.retSet:
	scf		; C flag set
	ret
.chkReflect:
	; 
	; Reflecting projectiles moves their OBJInfo to the opponent's slot,
	; effectively turning it into the opponent's projectile.
	;
	; This is due to several hardcoded assumptions with the projectile slots.
	; For example, wOBJInfo_Pl1Projectile is always "owned" by 1P can only ever hit wOBJInfo_Pl2
	; and wOBJInfo_Pl2Projectile is always 2P's can only ever hit wOBJInfo_Pl1,
	; so if 2P were to reflect 1P's projectile, the only way to make it work
	; would be to move wOBJInfo_Pl1Projectile over to wOBJInfo_Pl2Projectile
	; and changing some of its fields.
	;
	
	; Detect which projectile slot got reflected, depending on the wOBJInfo address.
	ld   a, e
	cp   a, LOW(wOBJInfo_Pl2Projectile)	; Are we 2P's projectile?
	jp   z, .reflect2P					; If so, jump
.reflect1P:
	; 
	; 2P reflected 1P's projectile.
	;
	
	; Don't reflect the projectile if there's 2P's projectile is visible.
	; Otherwise the one on screen would visibly disappear.
	; ??? In that case, the projectile will just be removed instead, since when
	; reflecting or removing projetiles, PCF_PROJREM is always set.
	ld   hl, wOBJInfo_Pl2Projectile+iOBJInfo_Status	; HL = Ptr to target projectile
	bit  OSTB_VISIBLE, [hl]		; Is 2P's projectile already visible?
	jp   nz, .retClear			; If so, ignore
	
	; Reflect it
	call Play_Proj_Reflect
	
	; Hide 1P's projectile
	ld   hl, wOBJInfo_Pl1Projectile+iOBJInfo_Status
	res  OSTB_VISIBLE, [hl]
	; And disable its hitbox
	ld   hl, wOBJInfo_Pl1Projectile+iOBJInfo_HitboxId
	ld   [hl], COLIBOX_00
	jp   .retClear
.reflect2P:
	; 
	; 1P reflected 2P's projectile.
	;
	
	; Don't reflect if 1P's slot is already used
	ld   hl, wOBJInfo_Pl1Projectile+iOBJInfo_Status	; HL = Ptr to target projectile
	bit  OSTB_VISIBLE, [hl]
	jp   nz, .retClear
	
	; Reflect it
	call Play_Proj_Reflect
	
	; Hide 2P's projectile
	ld   hl, wOBJInfo_Pl2Projectile+iOBJInfo_Status
	res  OSTB_VISIBLE, [hl]
	; And disable its hitbox
	ld   hl, wOBJInfo_Pl2Projectile+iOBJInfo_HitboxId
	ld   [hl], COLIBOX_00
	jp   .retClear
	
; =============== Play_Proj_Reflect ===============
; Reflects a projectile.
; See .chkReflect from the subroutine above.
; IN
; - DE: Ptr to source wOBJInfo (projectile that got reflected)
; - HL: Ptr to destination wOBJInfo (whereto copy it over)
Play_Proj_Reflect:
	push bc
		push de
		
			;
			; Copy the full wOBJInfo to the opponent's slot
			;
			push hl
				ld   b, OBJINFO_SIZE	; B = Bytes to copy
			.cpLoop:
				ld   a, [de]			
				ldi  [hl], a			
				inc  de
				dec  b					; Are we done?
				jp   nz, .cpLoop		; If not, loop
			pop  bc	; BC = Ptr to destination slot
			
			; Reset its hit mode, so it won't try to reflect it again
			ld   hl, iOBJInfo_Play_HitMode
			add  hl, bc
			ld   [hl], PHM_NONE
			
			; Flip it horizontally and switch its palette (1P & 2P have different palettes)
			ld   hl, iOBJInfo_OBJLstFlags
			add  hl, bc
			ld   a, [hl]
			xor  a, SPR_OBP1|SPR_XFLIP
			ld   [hl], a
			
			;
			; Invert its horizontal speed to make it return back.
			;
			push de
				ld   hl, iOBJInfo_SpeedX
				add  hl, bc		
				ld   d, [hl]	; D = iOBJInfo_SpeedX
				inc  hl
				ld   e, [hl]	; E = iOBJInfo_SpeedXSub
				ld   a, d		; Invert high byte
				cpl  
				ld   d, a
				ld   a, e		; Invert low byte	
				cpl  
				ld   e, a
				inc  e			; Account for bitflip
				jp   nz, .saveSpd
				inc  d
			.saveSpd:
				ld   [hl], e	; Save it back
				dec  hl
				ld   [hl], d
			pop  de
			
			; Play SGB/DMG SFX
			ld   a, SCT_REFLECT
			call HomeCall_Sound_ReqPlayExId
		pop  de
	pop  bc
	ret
	
; =============== OBJLstS_Hide ===============
; Hides/disables the specified sprite mapping.
; IN
; - DE: Ptr to wOBJInfo
OBJLstS_Hide:
	xor  a			
	ld   hl, iOBJInfo_Status
	add  hl, de		; Seek to status flags
	ld   [hl], a	; Erase them to hide the sprite mapping
	ret
	
; =============== MoveC_Base_Jump ===============
; Move code handler for all jump types.
;
; This move is one of the many that takes manual control of its animation timing.
; In this case, it's done because there are several ways to influence the jump,
; so rather than wasting space with different animations, the frames advance only
; when the player's Y Speed becomes > some value.
;
; To do this, the game checks which frame of the animation we're on (iOBJInfo_OBJLstPtrTblOffsetView)
; and jumps to the appropriate ".obj*". Each of these defines its own target
; speed to check, calling OBJLstS_ReqAnimOnGtYSpeed to request advancing the animation once.
MoveC_Base_Jump:
	call Play_Pl_MoveByColiBoxOverlapX
	call Play_Pl_CreateJoyMergedKeysLH
	mMvC_ValLoaded .ret
	
	; Moves use iOBJInfo_OBJLstPtrTblOffsetView to always execute code relevant to the visible frame.
	; This has the nice result of OSTB_GFXNEWLOAD being only set the very first time we
	; execute the code for any given .onOBJ*, allowing an easy way to execute code code once.
	;
	; For the same reason, OBJLstS_IsInternalFrameAboutToEnd can't be used to determine if we're about
	; to switch frames since it goes off the *internal* frame ID.	
	
	; Don't allow executing normals when displaying the first and last frame.
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $00*OBJLSTPTR_ENTRYSIZE	; OBJLstId == 0?		
	jp   z, .obj0_init				; If so, jump
	cp   $07*OBJLSTPTR_ENTRYSIZE	; OBJLstId == 7?
	jp   z, .obj7_landed			; If so, jump
	
	;
	; Move Input Reader
	;
	
	; If we've landed, skip this
	ld   hl, iOBJInfo_Y
	add  hl, de
	ld   a, [hl]
	cp   PL_FLOOR_POS	; iOBJInfo_Y == PL_FLOOR_POS?
	jr   z, .chkAct		; If so, skip
	
	; Check if we're starting normals in the middle of the jump
	ld   hl, iPlInfo_JoyMergedKeysLH
	add  hl, bc
	; Normals (air)
	bit  KEPB_A_LIGHT, [hl]	; Light kick?
	jp   nz, .startAirKick	; If so, jump
	bit  KEPB_B_LIGHT, [hl]	; Light punch?
	jp   nz, .startAirPunch	; If so, jump
	bit  KEPB_A_HEAVY, [hl]	; Heavy kick?
	jp   nz, .startAirKick	; If so, jump
	bit  KEPB_B_HEAVY, [hl]	; Heavy punch?
	jp   nz, .startAirPunch	; If so, jump
	
	; Otherwise, skip ahead
	jp   .chkAct

;	
; [TCRF] Unreferenced code to start an air block.
;        This code is essentially equivalent to BasicInput_ChkAirBlock, except
;        that there's no input check for holding back.
;
;        If this code were used, any attack while doing neutral or backwards
;        jumps would try to be automatically blocked.
;
;        Note that air blocking is new to 96. Neither this nor BasicInput_ChkAirBlock
;        existed in that game.
;
.unused_chkAirBlock:
    ; Can't air block when jumping forwards
	ld   hl, iPlInfo_MoveId
	add  hl, bc
	ld   a, [hl]
	cp   a, MOVE_SHARED_JUMP_F
	jp   z, .chkAct
	
	; Projectiles can only be blocked in the air.
	; So as long as the opponent's projectile is active, try to air block it.
	ld   hl, iPlInfo_Flags0Other
	add  hl, bc
	bit  PF0B_PROJ, [hl]			; Does the other player have an active projectile?
	jp   nz, .unused_startAirBlock	; If so, jump
		
	; Ground-based attacks can't be blocked in the air.
	ld   hl, iPlInfo_MoveDamageValOther
	add  hl, bc
	ld   a, [hl]
	or   a							; Is the other player performing an attack?
	jp   z, .chkAct					; If not, skip ahead
	
	ld   hl, iPlInfo_OBJInfoYOther
	add  hl, bc
	ld   a, [hl]		
	cp   PL_FLOOR_POS				; Is the other player on the floor?
	jp   z, .chkAct					; If so, skip ahead
	jp   .unused_startAirBlock
	
.chkAct:
	
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1_setJumpType
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj2_air
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj3_air
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj4_air
	cp   $05*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj5_air
	cp   $06*OBJLSTPTR_ENTRYSIZE
	jp   z, .chkWallJump
	jp   .move ; We never get here

;
; Air-based attack/guard moves.
; These don't have light/heavy variations.
;

; [TCRF] Unused code to start an air block, equivalent to BasicInput_StartAirBlock
.unused_startAirBlock:
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	set  PF1B_GUARD, [hl]			
	ld   a, MOVE_SHARED_BLOCK_A
	call Pl_Unk_SetNewMoveAndAnim
	jp   .move
	
; Starts the A+B air attack.
.startAirAttack:
	ld   a, SCT_HEAVY
	call HomeCall_Sound_ReqPlayExId
	ld   a, MOVE_SHARED_ATTACK_A
	call Pl_Unk_SetNewMoveAndAnim
	jp   .move
	
; Starts an air punch.
.startAirPunch:
	; If A+B are held, start that attack instead
	call Play_Pl_AreBothBtnHeld
	jp   c, .startAirAttack
	; New move
	ld   a, SCT_LIGHT
	call HomeCall_Sound_ReqPlayExId
	ld   a, MOVE_SHARED_PUNCH_A
	call Pl_Unk_SetNewMoveAndAnim
	jp   .move
	
;
; Starts an air kick.
;
.startAirKick:
	; If A+B are held, start that attack instead
	call Play_Pl_AreBothBtnHeld
	jp   c, .startAirAttack
	; New move
	ld   a, SCT_HEAVY
	call HomeCall_Sound_ReqPlayExId
	ld   a, MOVE_SHARED_KICK_A
	call Pl_Unk_SetNewMoveAndAnim
	jp   .move

; --------------- frame #0 ---------------	
; Preparing to jump.
;
; Get manual control of the animation timing as soon as the internal frame
; is about to change (iOBJInfo_FrameLeft == 0, as checked by OBJLstS_IsInternalFrameAboutToEnd).
; Since the graphics for the new frame have to load, this will still be called a few times after that.
.obj0_init:
	mMvC_ValFrameEnd .anim
	mMvC_SetAnimSpeed ANIMSPEED_NONE
	jp   .anim

; --------------- frame #1 ---------------	
; Starting the jump, and determines its "type".
;
; Jump "types" don't really exist though.
; What actually happens is that, through a series of checks that mostly depend
; on player input, the vertical and horizontal speed are updated, then the movement physics do the rest.
; 
.obj1_setJumpType:
	
	; Set the jump settings only the first time we get here.
	; Every time after, jump to .obj1_chkEnd to check if we're done.
	ld   hl, iOBJInfo_Status
	add  hl, de
	bit  OSTB_GFXNEWLOAD, [hl]
	jp   z, .obj1_chkEnd
	
.chkSettings:
	; We're in the air now
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	set  PF0B_AIR, [hl]
	
	;
	; JUMP DIRECTION
	;
	
	; Decide the jump direction depending on the input we were holding right before starting the jump move.
	ld   hl, iPlInfo_JoyKeysPreJump
	add  hl, bc
	bit  KEYB_LEFT, [hl]	; Did we hold left?
	jr   nz, .chkJumpL		; If so, jump
	bit  KEYB_RIGHT, [hl]	; Did we hold right?	
	jr   nz, .chkJumpR		; If so, jump
	
	; Otherwise, it's neutral, and we can skip ahead.
	; The movement speed and move ID (MOVE_SHARED_JUMP_N) we currently have set
	; are already correct, as it's not possible to do fast neutral jumps.
	jp   .neutral			
	;--
.chkJumpL:
	;
	; HORIZONTAL JUMP SPEED
	; By default the horizontal speed is read from a player-specific constant in iPlInfo_SpeedX.
	; With running jumps or when jumping while crouching, that speed is doubled.
	;
	
	; Running jumps give hyper hops
	ld   hl, iPlInfo_RunningJump
	add  hl, bc
	ld   a, [hl]
	or   a
	jp   nz, .fastL
	
	; Otherwise, check for the standard move input.
	; DU + L -> Hyper hop
	mMvIn_ChkDir MoveInput_DU_Fast, .fastL
	
.normalL:
	; HL = iPlInfo_SpeedX
	ld   hl, iPlInfo_SpeedX
	call Pl_GetWord
	jr   .invSpeedL
.fastL:
	; Play SFX for it
	ld   a, SFX_SUPERJUMP
	call HomeCall_Sound_ReqPlayExId
	; HL = iPlInfo_SpeedX * 2
	ld   hl, iPlInfo_SpeedX
	call Pl_GetWord
	sla  l
	rl   h
	
.invSpeedL:
	; Since we're moving left, SpeedX = -SpeedX
	ld   a, h	; Invert high byte
	cpl
	ld   h, a
	ld   a, l	; Invert low byte
	cpl
	ld   l, a
	inc  l		; HL++ to account for bitflip
	jp   nz, .setSpeedL
	inc  h		
.setSpeedL:
	; Set the jump speed
	call Play_OBJLstS_SetSpeedH
	
	; Pick the appropriate jump move depending on the direction we're facing.
	ld   a, MOVE_SHARED_JUMP_B		; A = Default with backwards jump
	ld   hl, iOBJInfo_OBJLstFlags
	add  hl, de						; Seek to flags
	bit  OSTB_XFLIP, [hl]			; Are we visually facing left (1P side)?
	jr   nz, .setDiagJump				; If so, jump (L is backwards on 1P side)
	ld   a, MOVE_SHARED_JUMP_F		; While it's forwards on 2P side
	jp   .setDiagJump
	;--
.chkJumpR:
	; Just like .chkJumpL, except without inverting the jump speed
	; and with move IDs the other way around.
	ld   hl, iPlInfo_RunningJump
	add  hl, bc
	ld   a, [hl]
	or   a
	jp   nz, .fastR
	mMvIn_ChkDir MoveInput_DU_Fast, .fastR
.normalR:
	ld   hl, iPlInfo_SpeedX
	call Pl_GetWord
	jr   .setSpeedR
.fastR:
	ld   a, SFX_SUPERJUMP
	call HomeCall_Sound_ReqPlayExId
	ld   hl, iPlInfo_SpeedX
	call Pl_GetWord
	sla  l
	rl   h
.setSpeedR:
	call Play_OBJLstS_SetSpeedH
	ld   a, MOVE_SHARED_JUMP_F
	ld   hl, iOBJInfo_OBJLstFlags
	add  hl, de
	bit  OSTB_XFLIP, [hl]
	jr   nz, .setDiagJump
	ld   a, MOVE_SHARED_JUMP_B
	;--
.setDiagJump:

	;
	; Update the move ID
	;
	ld   hl, iPlInfo_MoveId
	add  hl, bc
	ld   [hl], a
	
	;
	; Update the ptr for this animation, reading it from the MoveAnimTbl_* similarly to Pl_SetNewMove.
	;
	push de
		; DE = Ptr to destination iOBJInfo_OBJLstPtrTbl_Low
		ld   hl, iOBJInfo_OBJLstPtrTbl_Low
		add  hl, de
		push hl
		pop  de
		
		push de
			;
			; Switch to BANK $03, as all move animation tables are stored there.
			; [POI] Unsafe ROM bank switch, will break if VBLANK triggers here.
			;
			push af
				ld   a, BANK(MoveAnimTbl_Marker) ; BANK $03
				ld   [MBC1RomBank], a
			pop  af
			
			;
			; DE = Ptr to start of the move animation table for this player.
			;
			ld   hl, iPlInfo_MoveAnimTblPtr_High
			add  hl, bc
			ld   d, [hl]	; D = iPlInfo_MoveAnimTblPtr_High
			inc  hl
			ld   e, [hl]	; E = iPlInfo_MoveAnimTblPtr_Low
			
			;
			; Generate the offset to the table entry from the Move Id.
			;
			; Each entry in the table is 8 bytes long.
			; Considering MoveId is already multiplied by 2 for easy indexing,
			; this means we have to multiply it by 4.
			;
			ld   h, $00
			ld   l, a		; HL = MoveId (*2)
			add  hl, hl		; * 2
			add  hl, hl		; * 2
			
			; HL = Ptr to table entry
			add  hl, de		
		pop  de
		
		;
		; Update both sets of iOBJInfo_OBJLstPtrTbl.
		;
		
		; Since the bank number iOBJInfo_BankNum isn't updated, it means
		; the sprite mappings for the three jump moves must be in the same bank.
		; In practice, all sprite mappings for any given character are stored in the same bank anyway.
		
		; byte0 -> (skipped)
		inc  hl		; Seek to byte1 
		
		; byte1 -> iOBJInfo_OBJLstPtrTbl_Low
		ldi  a, [hl]
		ld   [de], a
		inc  de		; Seek to iOBJInfo_OBJLstPtrTbl_High
		
		; byte1 -> iOBJInfo_OBJLstPtrTbl_LowView
		inc  de		; Seek to iOBJInfo_OBJLstPtrTblOffset
		inc  de		; ...iOBJInfo_BankNumView
		inc  de		; ...iOBJInfo_OBJLstPtrTbl_LowView
		ld   [de], a
		dec  de		; and back
		dec  de
		dec  de
		
		; byte2 -> iOBJInfo_OBJLstPtrTbl_High
		ldi  a, [hl]
		ld   [de], a
		inc  de		; Seek to iOBJInfo_OBJLstPtrTblOffset
		inc  de		; ...iOBJInfo_BankNumView
		inc  de		; ...iOBJInfo_OBJLstPtrTbl_LowView
		inc  de		; ...iOBJInfo_OBJLstPtrTbl_HighView
		ld   [de], a
		
		; Restore original bank number
		ldh  a, [hROMBank]
		ld   [MBC1RomBank], a
	pop  de
	
.neutral:

	;
	; VERTICAL JUMP SPEED
	;
	; By default, the initial vertical speed is the same as iPlInfo_JumpSpeed.
	; If we've stopped holding UP by the time we got here, we performed a hop.
	; With hops, VSpeed = iPlInfo_JumpSpeed / 0.75
	;
	
	ld   hl, iPlInfo_JoyKeys
	add  hl, bc
	ld   a, [hl]				; A = Currently held keys
	ld   hl, iPlInfo_JumpSpeed	; HL = Default VSpeed
	call Pl_GetWord
	bit  KEYB_UP, a				; Are we still pressing UP?
	jr   nz, .setSpeedV			; If so, skip
	; Otherwise, HL /= 0.75
	sra  h			; HL /= 2
	rr   l
	push de
		push hl		; DE = HL
		pop  de
		sra  d		; DE /= 2
		rr   e
		add  hl, de	; HL += DE
	pop  de
.setSpeedV:
	call Play_OBJLstS_SetSpeedV
	jp   .move
.obj1_chkEnd:
	; Advance to frame#2 when reaching YSpeed > -7
	mMvC_NextFrameOnGtYSpeed -$07, ANIMSPEED_NONE
	jp   .chkWallJump

; --------------- frames #2-5 ---------------	
; Advance to the next frame when reaching the targets.
.obj2_air:
	mMvC_NextFrameOnGtYSpeed -$05, ANIMSPEED_NONE
	jp   .chkWallJump
.obj3_air:
	mMvC_NextFrameOnGtYSpeed -$03, ANIMSPEED_NONE
	jp   .chkWallJump
.obj4_air:
	mMvC_NextFrameOnGtYSpeed -$01, ANIMSPEED_NONE
	jp   .chkWallJump
.obj5_air:
	mMvC_NextFrameOnGtYSpeed +$01, ANIMSPEED_NONE
	jp   .chkWallJump

; --------------- common frames #2-6 ---------------	
; Handle the wall jump.
;
; This is allowed for any of the sprite mappings used when we're in the air (#2-6)
.chkWallJump:
	call Play_Pl_ChkWallJumpInput	; Did we start a wall jump?
	jp   nc, .move					; If not, jump
	; Otherwise, return immediately to avoid moving/animating the player.
	; This is because when a wall jump starts it starts a new jump move,
	; so don't touch anything about it.
	jp   .ret
	
; --------------- common frames #1-6 ---------------
; Move the player in the air, applying gravity.
.move:
	; Move the player in the air
	ld   hl, iPlInfo_Gravity				; HL = Ptr to gravity
	call Pl_GetWord							; Read it out to HL
	call OBJLstS_ApplyGravityVAndMoveHV		; Apply it
	jp   nc, .anim			; Did we touch the ground? If not, skip
	; Otherwise, switch to the landing act.
	; During this time, starting specials is allowed, making it
	; possible to start an input while jumping, and end it when landing.
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	res  PF1B_NOSPECSTART, [hl]			; Allow starting specials when landing
	; Switch to the landing phase.
	mMvC_SetLandFrame $07*OBJLSTPTR_ENTRYSIZE, ANIMSPEED_INSTANT
	jp   .ret
	
; --------------- frame #7 ---------------
; Landing frame
;
; Just waits for the frame to end before ending the move.
.obj7_landed:
	mMvC_ValFrameEnd .anim				; Is the frame about to finish? ; If not, continue				
	call Play_Pl_EndMove				; Otherwise, we're done
	jr   .ret
; --------------- common ---------------	
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== Pl_GetWord ===============
; Reads out a word value from the player struct.
; IN
; - BC: Ptr to wPlInfo structure
; - HL: Index to 16bit number field (ie: iPlInfo_BackSpeedX)
; OUT
; - HL: Indexed value
Pl_GetWord:
	push de				; Save OBJInfo ptr
		add  hl, bc		; Seek to the iPlInfo field
		ld   d, [hl]	; Read out word value to DE
		inc  hl
		ld   e, [hl]
		push de			; Move it to HL
		pop  hl			
	pop  de				; Restore OBJInfo ptr
	ret
	
; =============== Play_Pl_ChkWallJumpInput ===============
; Handles the input for performing a wall jump.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
; OUT
; - C flag: If set, a new jump was started
Play_Pl_ChkWallJumpInput:

	; Only Mai and Athena can wall jump.
	; The bootleg 97 neglected to change this, so characters that could double
	; jump in 95 lost that ability.
	ld   hl, iPlInfo_CharId
	add  hl, bc
	ld   a, [hl]
	cp   CHAR_ID_MAI		; Playing as Mai?
	jp   z, .chkEdge		; If so, jump
	cp   CHAR_ID_ATHENA		; ...
	jp   z, .chkEdge
	jp   .retClear			; Otherwise, return
	
.chkEdge:
	; The player must be on the edge of the screen.
	; If iOBJInfo_RangeMoveAmount
	ld   hl, iOBJInfo_RangeMoveAmount
	add  hl, de
	ld   a, [hl]
	or   a				; RangeMoveAmount == 0?
	jp   z, .retClear	; If so, return
	
	; Check if we held the direction towards the wall.
	; This changes depending the side of the screen, and RangeMoveAmount can be used to determine it.
	; If RangeMoveAmount < 0, it means we got pushed to the left when hugging the right border.
	bit  7, a			; RangeMoveAmount < 0?
	jp   nz, .chkRWall	; If so, jump
.chkLWall:
	; Must hold right if we're on the left wall
	ld   hl, iPlInfo_JoyKeys
	add  hl, bc
	bit  KEYB_RIGHT, [hl]
	jp   z, .retClear
	
	; OK - Jump can start
	
	; The jump should move us to the right
	ld   hl, iPlInfo_JoyKeysPreJump
	add  hl, bc
	set  KEYB_RIGHT, [hl]
	res  KEYB_LEFT, [hl]
	jp   .turn
.chkRWall:
	; Must hold left if we're on the left wall
	ld   hl, iPlInfo_JoyKeys
	add  hl, bc
	bit  KEYB_LEFT, [hl]
	jp   z, .retClear
	
	; OK - Jump can start
	
	; The jump should move us to the left
	ld   hl, iPlInfo_JoyKeysPreJump
	add  hl, bc
	set  KEYB_LEFT, [hl]
	res  KEYB_RIGHT, [hl]
	jp   .turn
.retClear:
	scf
	ccf		; C flag cleared
	ret
	
.turn:
	; Flip the player sprite horizontally to jump the other way
	ld   hl, iOBJInfo_OBJLstFlags
	add  hl, de
	bit  SPRXB_PLDIR_R, [hl]	; Internally facing right?
	jp   z, .turnR				; If not, jump
.turnL:
	set  SPRB_XFLIP, [hl]	; Face left
	jp   .jumpOk
.turnR:
	res  SPRB_XFLIP, [hl]	; Face right
.jumpOk:
	; Restart the jump sequence by starting a new one.
	ld   a, MOVE_SHARED_JUMP_N
	call Pl_SetMove_StopSpeed
	scf		; C flag set
	ret
	
; =============== Play_ExecExOBJCode ===============
; Executes the custom code for the four extra sprite mappings at slots 2-6.
; These are for the two projectiles and sparkle effects on super moves.
Play_ExecExOBJCode:
	; The bank num will jump all over the place when doing this
	ldh  a, [hROMBank]
	push af
		
		ld   bc, wPlInfo_Pl1							; BC = Ptr to starting player
		ld   de, wOBJInfo_Pl1Projectile+iOBJInfo_Status	; DE = Ptr to respective OBJInfo
		ld   a, $04										; A = Number of loops
	.loop:
		push af
			; If the sprite mapping isn't visible, ignore this
			ld   a, [de]		; Seek to status
			and  a, OST_VISIBLE	; Is the visibility flag set?
			jp   z, .nextObj	; If not, skip
		.ok:
			; Read out the code pointer.
			; All of these expect the code pointer to be at the same location.
			ASSERT(iOBJInfo_Play_CodePtr_Low == iOBJInfo_Play_CodePtr_Low)
			
			xor  a
			; Read out ptr to HL
			ld   hl, iOBJInfo_Play_CodePtr_Low	
			add  hl, de			; Seek to code ptr
			push bc
				ld   c, [hl]	; C = iOBJInfo_Play_CodePtr_Low 
				inc  hl
				ld   b, [hl]	; B = iOBJInfo_Play_CodePtr_High
				push bc
				pop  hl			; Move to HL
			pop  bc
			; Execute it if isn't null
			or   a, l			; Low byte != 0?
			jp   nz, .exec		; If so, execute it
			or   a, h			; High byte != 0?
			jp   nz, .exec		; If so, execute it
			; Otherwise, it's a null pointer.
			; Ignore it and move on.
			
		.nextObj:
			; Seek to the next OBJInfo
			; DE += OBJINFO_SIZE
			ld   hl, OBJINFO_SIZE
			add  hl, de
			push hl
			pop  de
			; Seek to the next PlInfo.
			; BC += PLINFO_SIZE
			; Note this makes the wPlInfo ptr go out of range when moving to wOBJInfo_Pl1SuperSparkle (into a nonexisting wPlInfo_Pl3 at $DB00).
			; The code that gets executed for the super sparkle offsets it anyway to seek back to the actual wPlInfo
			; associated with the sparkle.
			ld   hl, PLINFO_SIZE
			add  hl, bc
			push hl
			pop  bc
			
		pop  af			; Restore left count
		dec  a			; Processed all OBJInfo?
		jp   nz, .loop	; If not, loop
.end:
	; Restore bank num
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret
	.exec:
		push bc			; Save wPlInfo
			push de		; Save wOBJInfo
				call .farJump
			pop  de
		pop  bc
		jp   .nextObj
; =============== .farJump ===============
; Jumps to the specified code at bank iOBJInfo_Play_CodeBank
; IN
; - HL: Code ptr
; - DE: Ptr to wOBJInfo
.farJump:
	push hl		; Save code ptr
		ld   hl, iOBJInfo_Play_CodeBank
		add  hl, de		; Seek to bank num
		ld   a, [hl]	; Set it as current one
		ld   [MBC1RomBank], a
		ldh  [hROMBank], a
	pop  hl		; Restore code ptr
	jp   hl		; Execute it
	ret ; We never get here
	
; =============== MoveInputS_ChkInputBtnStrict ===============
; Handler for button input reading that provides no leeway.
; (ie: unlike MoveInputS_ChkInputDir, blank inputs in the buffer aren't skipped)
; See also: MoveInputS_ChkInputDir
; IN
; - BC: Ptr to wPlInfo structure
; - DE: Ptr to respective wOBJInfo structure
; - HL: Ptr to button move input list. (MoveInput_*)
; OUT
; - C flag: If set, the move input was triggered
MoveInputS_ChkInputBtnStrict:
	push bc
		push de
			push hl
				; A = Button Buffer Offset ($00-$0F)
				ld   hl, iPlInfo_JoyBtnBufferOffset
				add  hl, bc
				ld   a, [hl]
				
				; HL = Ptr to start of Button Buffer
				ld   hl, iPlInfo_JoyBtnBuffer
				add  hl, bc
				
				; Offset it by OR'ing the low nybble over
				or   a, l
				ld   l, a
				
				jp   MoveInputS_ChkInputStrict
				
; =============== MoveInputS_ChkInputDirStrict ===============
; Alternate handler for d-pad input reading that provides no leeway.
; (ie: unlike MoveInputS_ChkInputDir, blank inputs in the buffer aren't skipped)
; See also: MoveInputS_ChkInputDir
; IN
; - BC: Ptr to wPlInfo structure
; - DE: Ptr to respective wOBJInfo structure
; - HL: Ptr to d-pad move input list. (MoveInput_*)
; OUT
; - C flag: If set, the move input was triggered
MoveInputS_ChkInputDirStrict:
	push bc
		push de
			push hl
				; A = D-Pad Buffer Offset ($00-$0F)
				ld   hl, iPlInfo_JoyDirBufferOffset
				add  hl, bc
				ld   a, [hl]
				
				; HL = Ptr to start of D-Pad Buffer
				ld   hl, iPlInfo_JoyDirBuffer
				add  hl, bc
				; Offset it by OR'ing the low nybble over
				or   a, l
				ld   l, a
				;--
				; Fall-through
				
; =============== MoveInputS_ChkInputStrict ===============				
; IN
; - BC: Ptr to wPlInfo structure
; - DE: Ptr to respective wOBJInfo structure
; - HL: Ptr to d-pad move input list. (MoveInput_*)
; OUT
; - C flag: If set, the move input was triggered
MoveInputS_ChkInputStrict:
				; Save result to DE
				push hl
				pop  de
			pop  hl
			
			;
			; B = Number of separate inputs (iMoveInputItem_*) to check 
			;
			ldi  a, [hl]
			ld   b, a		; B = iMoveInput_Length
			
			; As there's no skipping of blank inputs, the loop is much simpler
			; and doesn't attempt to detect if we ran out of input buffer.
		.chkKeyVal:
			;
			; KEY CHECK
			;
			; The input in the current buffer entry must match the one from the move
			ld   a, [de]	; A = Held d-pad keys (KeyValue)
			ld   c, [hl]	; C = Required d-pad keys (iMoveInputItem_JoyKeys)
			inc  hl
			and  a, [hl]	; A = A & iMoveInputItem_JoyMaskKeys
			
			; Check for an exact match between filtered input and required keypress
			cp   a, c		; A == C?
			jp   nz, .retNg
			
		.chkKeyLen:
			;
			; HELD TIMER CHECK
			;
			; The input must be held for a range of frames
			inc  de			; Seek to buffer KeyTimer
			ld   a, [de]	; A = KeyTimer
			
			; KeyTimer must be >= MinLength
			inc  hl			; Seek to iMoveInputItem_MinLength
			cp   a, [hl]	; KeyTimer < iMoveInputItem_MinLength?
			jp   c, .retNg	; If so, return
			
			; KeyTimer must be <= MaxLength
			inc  hl			; Seek to iMoveInputItem_MaxLength
			cp   a, [hl]	
			jp   z, .chkEnd	; KeyTimer == iMoveInput_MaxKeyLen? If so, continue
			jp   nc, .retNg	; KeyTimer >= iMoveInput_MaxKeyLen? If so, return
				
		.chkEnd:
			;
			; Check if this is the end of the move input.
			; If it isn't, prepare to check for the next input
			; by seeking to the next iMoveInputItem and to the previous buffer entry.
			;
			
			; Seek to iMoveInputItem_JoyKeys of the next MoveInputItem
			inc  hl
			
			; Seek back to the previous buffer entry.
			; As each entry is 2 bytes long, decrement the buffer ptr (DE) by 2 + 1 
			; (as we're currently on the second byte of the current entry)
			; and making sure to wrap the offset from $00 to $0E if needed.
			ld   a, e
			dec  a		; DE -= 3
			dec  a
			dec  a
			; Force valid range, wrapping back from $00 to $0E if needed
			and  a, $0F
			
			; Apply the new offset to DE.
			push af
				; Get rid of low nybble in E
				ld   a, $F0	; E |= $F0
				and  a, e
				ld   e, a
			pop  af
			; And merge the new nybble over.
			or   a, e
			ld   e, a
			;--
			; DE now points at the start of the previous entry
			
			dec  b				; Did we process all iMoveInputItem?
			jp   nz, .chkKeyVal	; If not, loop
			
		.retOk:
			scf	; Set carry
		pop  de
	pop  bc
	ret
		.retNg:
			xor  a ; Clear carry
		pop  de
	pop  bc
	ret
	
; =============== MoveInputS_ChkInputDir ===============
; Checks if the directional keys for a move input were pressed correctly in order.
; Most moves use this subroutine to check for d-pad input.
;
; This boils down to checking a list of inputs in order.
;
; The input lists in ROM are stored in backwards order (from last to first input), which simplifies the handling 
; of the joypad buffer -- as we can directly start checking from the latest buffer entry and move down from there.
;
; Each input "item" checks:
; - If the required keys were held
; - How long they were held (must be between the checked range)
;
; Blank inputs in the buffer are skipped if they last less than a certain value.
;
; NOTE: The MoveInput* structs have the keys relative to a player facing left (on the 2P side).
;       On the 1P side, the inputs are flipped as needed before writing them to iPlInfo_JoyDirBuffer.
;
; IN
; - BC: Ptr to wPlInfo structure
; - DE: Ptr to respective wOBJInfo structure
; - HL: Ptr to d-pad move input list. (MoveInput_*)
; OUT
; - C flag: If set, the move input was triggered
MoveInputS_ChkInputDir:
	push bc
		push de
		
			;
			; DE = Ptr to current D-Pad buffer offset entry
			;
			push hl
				; A = D-Pad Buffer Offset ($00-$0F)
				ld   hl, iPlInfo_JoyDirBufferOffset
				add  hl, bc
				ld   a, [hl]
				
				; HL = Ptr to start of D-Pad Buffer
				ld   hl, iPlInfo_JoyDirBuffer
				add  hl, bc
				; Offset it by OR'ing the low nybble over
				or   a, l
				ld   l, a
				; Save result to DE
				push hl
				pop  de
			pop  hl
			
			;
			; B = Number of separate inputs (iMoveInputItem_*) to check 
			;
			ldi  a, [hl]
			ld   b, a
			
			;
			; Keep a count of the remaining buffer size before we "underflow"
			; from the 8th (earliest) entry to the 1st one (lestest).
			;
			; This value can decrease when checking for moves that require
			; a sequence of inputs (ie: DP motion) or when ignoring a bad input.
			; If this reaches 0 and the move isn't complete, we return immediately
			; and the move won't start.
			;
			
			; [BUG] This value is intended to decrement twice every time we seek back to the previous iPlInfo_JoyDirBuffer entry.
			;       It should keep a count of the remaining buffer size to avoid looping multiple times.
			;		Problem is, most of the time this is decremented *once*.
			ld   c, $10			; Size of buffer
			
			;--
			;
			; GET LATEST INPUT
			;
			; This rule (or its minor variation at .tryUseKeyNext) is used to determine the initial buffer entry to use.
			; The latest possible iPlInfo_JoyDirBuffer entry is used, unless no keys were pressed.
			; If no keys were pressed for more than $0E frames, we return immediately, otherwise
			; we use the previous buffer entry.
			;
			; The variation in .tryUseKeyNext, used for inputs checked after this one, instead returns when no keys
			; are pressed for more than $04 frames.
			;
		.tryUseLatestKey:
			; Attempt to use the latest D-Pad entry if present.
			ld   a, [de]		; A = Held d-pad keys
			or   a				; Were any keys held?
			jp   nz, .chkKeyValInitial	; If so, skip
			
			; If we didn't press any keys on the d-pad for $0F frames or more, return.
			inc  de				; Seek to key length
			ld   a, [de]		; A = Key length
			cp   $0F			; A >= $0F?
			jp   nc, .retNg		; If so, return
			
			; Otherwise, seek back to the previous buffer entry.
			; As each entry is 2 bytes long, this requires:
			; - Decreasing the bytes left (C) by 2
			; - Decreasing the buffer ptr (DE) by 2 + 1 (as we're currently on the second byte of the current entry)
			;   and making sure to wrap the offset from $00 to $0E if needed.
			
			; This is the only time C is decremented correctly.
			; Even then, there's one "dec c" at the start and one at the end.
			
			dec  c				; Decrease buffer size remaining (1/2)
			; Decrease buffer offset by 3
			ld   a, e			; A = Key offset
			dec  a				; -= 1, seek back to first byte of current entry
			dec  a				; -= 2, seek to the start of the previous entry
			dec  a				
			; Force valid range, wrapping back from $00 to $0E if needed
			and  a, $0F			
			
			; Apply the new offset to DE, the d-pad buffer ptr.
			; This replaces the low nybble of E with the value currently in A,
			; which works due to the buffer size ($10 bytes) and its alignment.
			push af
				; Get rid of low nybble in E
				ld   a, $F0	; E |= $F0
				and  a, e
				ld   e, a
			pop  af
			; And merge the new nybble over.
			or   a, e
			ld   e, a
			
			; A = Buffer entry from previous frame
			ld   a, [de]
			dec  c				; Decrease buffer size remaining (2/2)
			;--
			
		.chkKeyValInitial:
		
			;
			; KEY CHECK (INITIAL)
			;
			; This initial input check verifies if the input from the buffer matches the last d-pad input for the move,
			; therefore checking the first KEY_* bitmask in the MoveInput_* data.
			;
			; A very similar check is used in .chkKeyValNext for the other inputs.
			;
		
			push bc
				; C = Required d-pad keys
				ld   c, [hl]	; C = iMoveInputItem_JoyKeys
				inc  hl
				
				;
				; Filter away inputs excluded from the check.
				; The second byte ("include filter") dictates which inputs from the buffer can be compared
				; with the required keys.
				;
				; [POI] In 96, this is almost always the same as the required keypress,
				;       meaning it's equivalent of doing "and c".
				;       This allows fat-fingering half/quarter-circles, since you don't have to 
				;       press the exact key (ie: RIGHT can be successfully input by DOWN+RIGHT).
				;       But it wasn't always the case! In 95, the code for this is identical,
				;       but the filter wouldn't remove all of the extra keypresses.
				;       This meant that, usually, if the game required pressing RIGHT, it wouldn't
				;       accept DOWN+RIGHT, making them trickier to perform.
				;
				and  a, [hl]	; A = A & iMoveInputItem_JoyMaskKeys
				
				; Check for an exact match between filtered input and required keypress
				cp   a, c		; A == C?
			pop  bc
			jp   z, .chkKeyLen		; If so, jump
			
			; Unlike .chkKeyValNext, if the last input isn't correct, return immediately.
			jp   .retNg
			
		.tryUseKeyNext:
			;
			; GET NEXT INPUT
			;
			; See also .tryUseLatestKey
			
			; Attempt to use the current D-Pad entry if there's something here.
			; (as we've just decremented it)
			ld   a, [de]
			or   a
			jp   nz, .chkKeyValNext
			
			;--
			
			; If we didn't press any keys on the d-pad for *$05* frames or more, return.
			inc  de
			ld   a, [de]
			cp   $05
			jp   nc, .retNg
			
			; If we ran out of buffer, return
			dec  c				; [BUG] Should be "dec c" twice
			jp   z, .retNg
			
			; Otherwise, seek back to the previous buffer entry.
			; Decrease buffer offset by 3
			ld   a, e
			dec  a
			dec  a
			dec  a
			; Force valid range, wrapping back from $00 to $0E if needed
			and  a, $0F
			
			; Replace low nybble of DE with it
			push af
				; Get rid of low nybble in E
				ld   a, $F0	; E |= $F0
				and  a, e
				ld   e, a
			pop  af
			or   a, e	; Merge the new nybble over.
			ld   e, a
			;--
			; DE now points at the start of the previous entry
			
			jp   .tryUseKeyNext
			
		.chkKeyValNext:
			;
			; KEY CHECK (NEXT)
			;
			; This verifies if the input (KeyValue) from the buffer matches the d-pad input for the move.
			; The difference here compared to .chkKeyValInitial is that, if the input doesn't match,
			; the previous buffer entry is always checked, until the buffer runs out.
			;
			; See also: .chkKeyValInitial
			
			push bc
				; C = Required d-pad keys
				ld   c, [hl]	; C = iMoveInputItem_JoyKeys
				inc  hl			; Seek to iMoveInputItem_JoyMaskKeys (byte1)
				
				; Filter away inputs excluded from the check.
				; [POI] Same note applies here.
				and  a, [hl]	; A = A & iMoveInputItem_JoyMaskKeys
				
				; Check for an exact match between filtered input and required keypress
				cp   a, c		; A == C?
			pop  bc
			jp   z, .chkKeyLen	; If so, jump
			
			;--
			;
			; Otherwise, decrease the buffer offset by 2, and move back the
			; iMoveInfo offset to the start of the entry.
			; See also: .chkEnd
			;
			
			dec  hl				; Seek back to iMoveInputItem_JoyKeys (byte0)
			dec  c				; [BUG] Should be "dec c" twice
			jp   z, .retNg
			
			; Seek to previous input buffer entry.
			; As we're currently on the first byte of the current entry, decrease it by 2.
			ld   a, e
			dec  a
			dec  a
			; Force valid range, wrapping back from $00 to $0E if needed
			and  a, $0F
			
			; Replace low nybble of DE with it
			push af
				; Get rid of low nybble in E
				ld   a, $F0	; E |= $F0
				and  a, e
				ld   e, a
			pop  af
			or   a, e	; Merge the new nybble over.
			ld   e, a
			;--
			
			jp   .tryUseKeyNext
		.chkKeyLen:
			
			;
			; HELD TIMER CHECK
			;
			; Each input in a move can be held for a specific range of frames.
			; If it's outside this range, return.
			;
			; Note that moves tend to have the initial input (meaning the last one we check)
			; with the upper limit set as $FF.
			; This means that, assuming the move starts by pressing RIGHT, we could hold that
			; button for an indefinite amount of time before continuing with the input.
			;
			inc  de			; Seek to buffer KeyTimer
			ld   a, [de]	; A = KeyTimer
			
			; KeyTimer must be >= MinLength
			inc  hl			; Seek to iMoveInputItem_MinLength
			cp   a, [hl]	; KeyTimer < iMoveInputItem_MinLength?
			jp   c, .retNg	; If so, return
			
			; KeyTimer must be <= MaxLength
			inc  hl			; Seek to iMoveInputItem_MaxLength
			cp   a, [hl]	
			jp   z, .chkEnd	; KeyTimer == iMoveInput_MaxKeyLen? If so, continue
			jp   nc, .retNg	; KeyTimer >= iMoveInput_MaxKeyLen? If so, return
							
		.chkEnd:
			
			;
			; Check if this is the end of the input.
			; Like last time, seek from the current entry to the previous one while
			; we're currently on the second byte of the entry (requiring to seek back 3 bytes).
			;
			; For reference, the first time we get here, the current buffer entry may point
			; to the latest one.
			;
		
			; Seek to iMoveInputItem_JoyKeys of the next MoveInputItem
			inc  hl			
			
			
			; Seek back to the previous buffer entry, exactly like last time
			dec  c			; [BUG] Should be "dec c" twice
			jp   z, .retNg	; End of buffer? If so, return
			
			; Seek to previous input buffer entry.
			ld   a, e
			dec  a		; A = E - 3
			dec  a
			dec  a
			; Force valid range, wrapping back from $00 to $0E if needed
			and  a, $0F
			
			; Replace low nybble of DE with it
			push af
				; Get rid of low nybble in E
				ld   a, $F0	; E |= $F0
				and  a, e
				ld   e, a
			pop  af
			or   a, e	; Merge the new nybble over.
			ld   e, a
			;--
			; DE now points at the start of the previous entry
			
			dec  b					; Did we process all iMoveInputItem?
			jp   nz, .tryUseKeyNext	; If not, loop
		.retOk:
			scf ; Set carry
		pop  de
	pop  bc
	ret
		.retNg:
			xor  a ; Clear carry
		pop  de
	pop  bc
	ret
	
; =============== Play_Pl_ClearJoyDirBuffer ===============
; Clears the d-pad input buffer for the specified player.
; Meant to be used after successfully completing a move input.
; IN
; - BC: Ptr to wPlInfo structure
Play_Pl_ClearJoyDirBuffer:
	push hl
		push bc
			; Fill the $10 bytes of iPlInfo_JoyDirBuffer with $00
			xor  a			; A = Overwrite with
			ld   hl, iPlInfo_JoyDirBuffer
			add  hl, bc		; Seek to d-pad buffer
			ld   b, $10		; B = Bytes to clear
		.loop:
			ldi  [hl], a	; Write
			dec  b			; Finished filling it?
			jp   nz, .loop	; If not, loop
		pop  bc
	pop  hl
	ret
	
; =============== Play_Pl_ClearJoyBtnBuffer ===============
; Clears the button input buffer for the specified player.
; Meant to be used after successfully completing a move input that uses MoveInputS_ChkInputBtnStrict.
; (so, not many)
; IN
; - BC: Ptr to wPlInfo structure
Play_Pl_ClearJoyBtnBuffer:
	push hl
		push bc
			; Fill the $10 bytes of iPlInfo_JoyBtnBuffer with $00
			xor  a			; A = Overwrite with
			ld   hl, iPlInfo_JoyBtnBuffer
			add  hl, bc		; Seek to d-pad buffer
			ld   b, $10		; B = Bytes to clear
		.loop:
			ldi  [hl], a	; Write
			dec  b			; Finished filling it?
			jp   nz, .loop	; If not, loop
		pop  bc
	pop  hl
	ret
	
; =============== Play_Pl_CreateJoyKeysLH ===============
; Generates the field iPlInfo_JoyKeysLH for the specified player.
; This merges the held directional keys from iPlInfo_JoyKeys with the light/heavy flags.
;
; The value generated is the main one used by the input readers to detect if a punch/kick button
; was pressed, so it should be run before those.
; 
; IN
; - BC: Ptr to wPlInfo structure
Play_Pl_CreateJoyKeysLH:
	; Seek to iPlInfo_JoyKeys
	ld   hl, iPlInfo_JoyKeys
	add  hl, bc			
	push bc
		; B = Currently held D-Pad keys
		ldi  a, [hl]	
		and  a, KEY_RIGHT|KEY_LEFT|KEY_UP|KEY_DOWN
		ld   b, a
		; A = Light/Heavy button info (mix of current and ???? set)
		;    (iPlInfo_JoyNewKeysLH | iPlInfo_JoyMergedKeysLH) & $F0
		ldi  a, [hl]	; A = iPlInfo_JoyNewKeysLH
		inc  hl			; Seek to iPlInfo_JoyNewKeysLHPreJump
		inc  hl			; Seek to iPlInfo_JoyMergedKeysLH
		or   a, [hl]	
		and  a, KEP_A_LIGHT|KEP_B_LIGHT|KEP_A_HEAVY|KEP_B_HEAVY ; Filter valid LK bits
		or   b ; Merge both variables
	pop  bc
	; Store the result to iPlInfo_JoyKeysLH
	ld   hl, iPlInfo_JoyKeysLH
	add  hl, bc
	ld   [hl], a
	ret
	
; =============== Play_Pl_CreateJoyMergedKeysLH ===============
; Merges the current light/heavy flags to iPlInfo_JoyMergedKeysLH.
; This is only called when a move uses iPlInfo_JoyMergedKeysLH to 
; check inputs. TODO: Purpose over iPlInfo_JoyNewKeysLH directly ???
; IN
; - BC: Ptr to wPlInfo structure
; OUT
; - C flag: If set, iPlInfo_JoyMergedKeysLH was updated
Play_Pl_CreateJoyMergedKeysLH:
	; Read flags
	ld   hl, iPlInfo_JoyNewKeysLH
	add  hl, bc		; Seek to iPlInfo_JoyNewKeysLH
	ld   a, [hl]	; A = iPlInfo_JoyNewKeysLH
	; If the updated flags are blank, keep the old ones 
	and  a, KEP_A_LIGHT|KEP_B_LIGHT|KEP_A_HEAVY|KEP_B_HEAVY ; Filter valid LH bits
	jr   z, .retClear
.update:
	; Otherwise, OR them over
	; iPlInfo_JoyMergedKeysLH
	ld   hl, iPlInfo_JoyMergedKeysLH
	add  hl, bc		
	or   a, [hl]	; A |= iPlInfo_JoyMergedKeysLH
	ld   [hl], a	; Save it there
.retSet:
	scf				 
	ret
.retClear:
	or   a
	ret
	
; =============== Play_Pl_AreBothBtnHeld ===============
; Checks if we're holding both the punch and kick buttons at the same time.
; IN
; - BC: Ptr to wPlInfo structure
; OUT
; - C flag: If set, we're holding A and B
Play_Pl_AreBothBtnHeld:
	ld   hl, iPlInfo_JoyKeys
	add  hl, bc			; Seek to iPlInfo_JoyKeys
	ld   l, [hl]		; L = Currently held keys
	bit  KEYB_A, l		; Are we holding A?
	jp   z, .retClear	; If not, jump
	; We're holding A
	bit  KEYB_B, l		; Are we also holding B?
	jp   nz, .retSet	; If so, jump (success)
	; If not, return 0
.retClear:
	or   a	; Clear carry
	ret
.retSet:
	scf		; Set carry
	ret
	
; =============== Play_Pl_GetDirKeys_ByXFlipR ===============
; Gets the d-pad keys we're holding, relative to the current player *visually* facing right.
; This means L/R are inverted on the 2P side.
; IN
; - BC: Ptr to wPlInfo structure
; - DE: Ptr to respective wOBJInfo structure
; OUT
; - A: Held directions (KEY_*)
; - C flag: If set, we're holding at least a directional button
Play_Pl_GetDirKeys_ByXFlipR:
	ld   hl, iPlInfo_JoyKeys
	add  hl, bc		; Seek to iPlInfo_JoyKeys
	
	;
	; A = D-Pad Direction keys
	;
	ld   a, [hl]
	and  a, KEY_RIGHT|KEY_LEFT|KEY_UP|KEY_DOWN		; Filter out non d-pad keys
	jp   z, .retClear								; Holding any of them? If not, return
	
	;
	; Invert the left/right inputs if we're visually facing left.
	; This is because the returned keys are used with manual move input checks 
	; (the ones that don't use MoveInput_* structs) but should still be affected by switching sides.
	; 
	ld   hl, iOBJInfo_OBJLstFlags
	add  hl, de
	bit  SPRB_XFLIP, [hl]	; Is the player facing right?
	jp   nz, .retSet		; If so, skip
	xor  KEY_RIGHT|KEY_LEFT	; Otherwise, invert L/R inputs
.retSet:
	scf		; Set carry
	ret
.retClear:
	or   a	; Clear carry
	ret
	
; =============== OBJLST ANIMATION HELPERS ===============
	
; =============== OBJLstS_IsGFXLoadDone ===============
; Determines if the graphics for the specified wOBJInfo have finished loading.
; IN
; - DE: Ptr to wOBJInfo 
; OUT
; - Z flag: If set, the graphics have loaded
OBJLstS_IsGFXLoadDone:
	ld   hl, iOBJInfo_Status
	add  hl, de
	bit  OSTB_GFXLOAD, [hl]	; Is the flag set?
	ret
	
; =============== OBJLstS_IsFrameNewLoad ===============
; Determines if the graphics for the sprite mapping have just finished loading
; at the end of the previous frame during VBlank.
; IN
; - DE: Ptr to wOBJInfo
; OUT
; - Z flag: If set, the graphics have newly loaded
OBJLstS_IsFrameNewLoad:
	ld   hl, iOBJInfo_Status
	add  hl, de
	bit  OSTB_GFXNEWLOAD, [hl]	; Is the flag set?
	ret
	
; =============== OBJLstS_IsInternalFrameAboutToEnd ===============
; Determines if the current sprite mapping ID is about to be updated later on this frame.
;
; The purpose of this is to syncronize certain actions in the move code, like spawning projectiles
; or checking if the move should autorestart, to the animation *internally* switching between
; frames when the move code manually calls OBJLstS_DoAnimTiming_Loop*.
;
; *Internally* emphasized, as the graphics for the new frame of course have to load,
; making the last frame visually linger for a bit.
;
; IN
; - DE: Ptr to wOBJInfo
; OUT
; - HL: Ptr to iOBJInfo_FrameLeft
;       Code actually relies on this.
; - C flag: If set, the animation frame will change by the end of the frame
OBJLstS_IsInternalFrameAboutToEnd:
	; If the GFX aren't fully loaded yet, the animation can't continue
	call OBJLstS_IsGFXLoadDone
	jp   nz, .retClear
	
	; Otherwise, the frame switches when iOBJInfo_FrameLeft reaches 0. 
	ld   hl, iOBJInfo_FrameLeft
	add  hl, de
	ld   a, [hl]		; A = iOBJInfo_FrameLeft
	or   a				; A != 0?
	jp   nz, .retClear	; If so, jump
.retSet:
	scf		; Set carry (ending)
	ret
.retClear:
	xor  a	; Clear carry (not ending)
	ret
	
; =============== Play_Pl_SetJumpLandAnimFrame ===============
; Sets the animation frame/SFX for landing on the ground.
; This is meant to be used when landing on the ground during an air move.
; IN
; - A: OBJLst Id
; - H: Animation speed (iOBJInfo_FrameTotal)
; - DE: Ptr to wOBJInfo
; OUT
; - Z flag: If set, the new animation frame wasn't set
Play_Pl_SetJumpLandAnimFrame:
	push bc
		ld   b, h		; B = Animation speed
		
		; Only do this if we're requesting a different animation frame
		ld   hl, iOBJInfo_OBJLstPtrTblOffset
		add  hl, de		; Seek to OBJLstId
		cp   a, [hl]	; A == OBJLstId?
		jp   z, .end	; If so, return
		
		; Otherwise, write the new sprite mapping
		ld   [hl], a
		
		; Reset the animation speed to the specified value
		ld   hl, iOBJInfo_FrameLeft
		add  hl, de		; Seek iOBJInfo_FrameLeft
		ld   [hl], b	; Frames remaining before change
		inc  hl			; Seek to iOBJInfo_FrameTotal
		ld   [hl], b	; Total count when switching frames
		
		; Apply the changes
		call OBJLstS_DoAnimTiming_Initial_by_DE
		
		;
		; Play a sound effect whenever we land on the ground.
		; Daimon is supposed to use a special one, but...
		; [BUG] ...BC isn't properly restored so it reads a garbage value instead of the CharId.
		;       This ends up making the code unreachable.
		;
IF FIX_BUGS == 1
		; The code after this, including HomeCall_Sound_ReqPlayExId, doesn't touch BC,
		; but there's a check above inside the push...
	pop  bc
	push bc
ENDC
		ld   hl, iPlInfo_CharId
		add  hl, bc		
		ld   a, [hl]			; A = CharId
		cp   CHAR_ID_DAIMON 	; Playing as DAIMON?
		jp   z, .unused_daimon	; If so, jump
	.norm:
		ld   a, SFX_STEP		; A = Normal step SFX ID
		jp   .playSFX
	.unused_daimon:
		ld   a, SND_ID_26		; A = Step SFX ID for DAIMON
	.playSFX:
		call HomeCall_Sound_ReqPlayExId
		
		; Return NZ
		ld   a, $01
		or   a		
	.end:
	pop  bc
	ret
	
; =============== Play_Pl_SetDropAnimFrame ===============
; Sets the animation/SFX for dropping on the ground.
; See also: Play_Pl_SetJumpLandAnimFrame
; IN
; - A: OBJLst Id
; - H: Animation speed (iOBJInfo_FrameTotal)
; - DE: Ptr to wOBJInfo
; OUT
; - Z flag: If set, the new animation frame wasn't set
Play_Pl_SetDropAnimFrame:
	push bc
		ld   b, h		; B = Animation speed
		
		; Only do this if we're requesting a different animation frame
		ld   hl, iOBJInfo_OBJLstPtrTblOffset
		add  hl, de		; Seek to OBJLstId
		cp   a, [hl]	; A == OBJLstId?
		jp   z, .retZ	; If so, return
		
		; Otherwise, write the new sprite mapping
		ld   [hl], a
		
		; Reset the animation speed to the specified value
		ld   hl, iOBJInfo_FrameLeft
		add  hl, de		; Seek iOBJInfo_FrameLeft
		ld   [hl], b	; Frames remaining before change
		inc  hl			; Seek to iOBJInfo_FrameTotal
		ld   [hl], b	; Total count when switching frames
		
		; Apply the changes
		call OBJLstS_DoAnimTiming_Initial_by_DE
	pop  bc
	call Play_Pl_IsDizzyNext
	jp   nz, .playDizzySFX
	
.playNormSFX:
	ld   a, SFX_DROP
	call HomeCall_Sound_ReqPlayExId
	jp   .retNz
.playDizzySFX:
	ld   a, SCT_DIZZY
	call HomeCall_Sound_ReqPlayExId
.retNz:
	ld   a, $01
	or   a
	ret
.retZ:
	pop  bc
	ret
	
; =============== Play_Pl_SetAnimFrame ===============
; Sets a custom sprite mapping ID for the current animation.
; See also: Play_Pl_SetJumpLandAnimFrame
; IN
; - A: OBJLst Id
; - H: Animation speed (iOBJInfo_FrameTotal)
; - DE: Ptr to wOBJInfo
; OUT
; - Z flag: If set, the new animation frame wasn't set
Play_Pl_SetAnimFrame:
	push bc
		ld   b, h		; B = Animation speed
		
		; Only do this if we're requesting a different animation frame
		ld   hl, iOBJInfo_OBJLstPtrTblOffset
		add  hl, de		; Seek to OBJLstId
		cp   a, [hl]	; A == OBJLstId?
		jp   z, .end	; If so, return
		
		; Otherwise, write the new sprite mapping
		ld   [hl], a
		
		; Reset the animation speed to the specified value
		ld   hl, iOBJInfo_FrameLeft
		add  hl, de		; Seek iOBJInfo_FrameLeft
		ld   [hl], b	; Frames remaining before change
		inc  hl			; Seek to iOBJInfo_FrameTotal
		ld   [hl], b	; Total count when switching frames
		
		; Apply the changes
		call OBJLstS_DoAnimTiming_Initial_by_DE
		
		; Return NZ
		ld   a, $01
		or   a
	.end:
	pop  bc
	ret
	
; =============== OBJLstS_ReqAnimOnGtYSpeed ===============
; Requests a switch to the next animation frame when passing the Y speed threshold.
;
; This also sets a new animation speed (iOBJInfo_FrameTotal), but since this is mostly used
; to have manual control of the animation during jump-like moves, it almost always gets set
; to ANIMSPEED_NONE.
;
; It may also be set to ANIMSPEED_INSTANT or some other value when
; ending manual control of the animation.
; 
; For an example, the basic jumps use this subroutine, meaning the animation
; switches to the next sprite mapping (+$04) only when the player reaches a specific Y speed.
; The sprite mapping ID itself determines the "submode"/"act" of the jump, where
; each one is set to have own threshold before switching.
;
; IN
; - A: Y Speed Threshold
; - H: Animation speed to set
; - DE: Ptr to wOBJInfo
; OUT
; - C flag: If set, the request was successful.
;           That means calling the animation routine will switch to the next sprite mapping ID in the animation.
OBJLstS_ReqAnimOnGtYSpeed:
	push bc
		; Save this for later
		ld   b, h		; B = AnimSpeed
		
		;
		; The current Y Speed must be larger than the threshold.
		;
		
		; Add $40 to both of them to avoid unintented results with the
		; unsigned comparison on signed values that tend to be close to 0.
		DEF PADVAL = $40
		add  a, PADVAL	; A = YSpeedNew + Pad
		push af
			; C = YSpeedCur + Pad
			ld   hl, iOBJInfo_SpeedY
			add  hl, de
			ld   a, [hl]
			add  a, PADVAL
			ld   c, a
		pop  af
		
		cp   a, c			; YSpeedCur > YSpeedNew?
		jp   c, .chkChange	; If so, jump
		jp   .retClear		; Otherwise, return
		
	.chkChange:
		; As a side effect of the move code going off the visible frame, this will get called multiple times
		; even after we successfully request the frame to advance.
		; Avoid accidentally erasing iOBJInfo_FrameLeft on next calls to this while the same frame is visible.
		call OBJLstS_IsGFXLoadDone	; Have the frame graphics loaded?
		jp   nz, .retClear			; If not, return
		
		; Set iOBJInfo_FrameLeft to 0 to force advance the animation once
		ld   hl, iOBJInfo_FrameLeft
		add  hl, de
		ld   [hl], $00	; iOBJInfo_FrameLeft = 0
		; Set the new animation speed
		inc  hl
		ld   [hl], b	; iOBJInfo_FrameTotal = B
	.retSet:
		scf		; C flag set
	pop  bc
	ret
	.retClear:
		or   a	; C flag clear
	pop  bc
	ret
	
; =============== Play_Pl_EmptyPowOnSuperEnd ===============
; Called at the end of most moves to empty the POW meter when a super move finishes.
; IN
; - BC: Ptr to wPlInfo structure
Play_Pl_EmptyPowOnSuperEnd:

	; Super move required
	ld   hl, iPlInfo_Flags0
	add  hl, bc					; Seek to iPlInfo_Flags0
	bit  PF0B_SUPERMOVE, [hl]	; Were we just doing a super move?
	jp   z, .ret				; If not, return
	
	; Max meter required
	; It's very possible to have the MAX Power meter run out during
	; the super move, which is why we must check this.
	ld   hl, iPlInfo_Pow
	add  hl, bc					; Seek to iPlInfo_Pow
	ld   a, [hl]
	cp   PLAY_POW_MAX			; Are we at max power?
	jp   nz, .ret				; If not, return
	
	; All ok, empty the POW meter
	ld   [hl], $00				
.ret:
	ret
	
; =============== Play_Pl_EndMove ===============
; Handles what happens when any move with fixed length ends.
; Note this needs to be manually called by the move code.
; IN
; - BC: Ptr to wPlInfo structure
; - DE: Ptr to respective wOBJInfo structure
Play_Pl_EndMove:
	; In case we ended a super move
	call Play_Pl_EmptyPowOnSuperEnd
	xor  a
	
	; Force align player to floor
	ld   hl, iOBJInfo_Y
	add  hl, de
	ld   [hl], PL_FLOOR_POS
	inc  hl
	ldi  [hl], a	; Clear Y subpixels
	
	; Reset speed
	ldi  [hl], a	; iOBJInfo_SpeedX
	ldi  [hl], a	; iOBJInfo_SpeedXSub
	ldi  [hl], a	; iOBJInfo_SpeedY
	ld   [hl], a	; iOBJInfo_SpeedYSub
	
	; If we were performing a special move, clear iPlInfo_JoyMergedKeysLH
	; This causes ???
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	ld   a, [hl]		; A = Flags
	and  a, PF0_SUPERMOVE|PF0_SPECMOVE	; Doing a special or super?
	jp   z, .clearFlags						; If not, skip
	push hl
		ld   hl, iPlInfo_JoyMergedKeysLH
		add  hl, bc
		ld   [hl], $00
	pop  hl
	
.clearFlags:
	; Reset everything from the flags except:
	; - PF0B_PROJ: It's independent from the player
	; - PF0B_CPU: Fixed
	; - PF1B_GUARD: Preserve to avoid "holes" in the guard when changing moves.
	; - PF1B_CROUCH: In case we ended crouch-based attacks
	; - PF2B_MOVESTART: ???
	; - PF2B_HEAVY: ???
	res  PF0B_SPECMOVE, [hl]
	res  PF0B_AIR, [hl]
	res  PF0B_PROJHIT, [hl]
	res  PF0B_PROJREM, [hl]
	res  PF0B_PROJREFLECT, [hl]
	res  PF0B_SUPERMOVE, [hl]
	inc  hl	; Seek to iPlInfo_Flags1
	res  PF1B_NOBASICINPUT, [hl] ; Since we're resetting to MOVE_SHARED_NONE
	res  PF1B_XFLIPLOCK, [hl]
	res  PF1B_NOSPECSTART, [hl]
	res  PF1B_HITRECV, [hl]
	res  PF1B_ALLOWHITCANCEL, [hl]
	res  PF1B_INVULN, [hl]
	inc  hl	; Seek to iPlInfo_Flags2
	res  PF2B_HITCOMBO, [hl]
	res  PF2B_AUTOGUARDDONE, [hl]
	res  PF2B_AUTOGUARDMID, [hl]
	res  PF2B_AUTOGUARDLOW, [hl]
	res  PF2B_NOHURTBOX, [hl]
	res  PF2B_NOCOLIBOX, [hl]
	
	; Clear damage flags
	inc  hl	; Seek to iPlInfo_Flags3
	ld   [hl], $00
	
	; Reset the current move to MOVE_SHARED_NONE.
	; In practice, since PF1B_NOBASICINPUT just got cleared, the basic move handler
	; will replace it with something else (ie: MOVE_SHARED_IDLE).
	; Of course this won't happen at the end of the match, where the player tasks get removed
	; right after this returns.
	ld   hl, iPlInfo_MoveId
	add  hl, bc
	ld   [hl], MOVE_SHARED_NONE
	; In case the intro/outro move ended, reset this too.
	ld   hl, iPlInfo_IntroMoveId
	add  hl, bc
	ld   [hl], MOVE_SHARED_NONE
	ret
	
; =============== OBJLstS_SyncXFlip ===============
; Syncronizes the sprite's visual X direction with the internal one.
; IN
; - DE: Ptr to wOBJInfo structure
OBJLstS_SyncXFlip:
	ld   hl, iOBJInfo_OBJLstFlags
	add  hl, de					; Seek to flags
	bit  SPRXB_PLDIR_R, [hl]	; Is the sprite mapping internally flipped?
	jp   z, .noFlip				; If not, jump
.flip:
	set  SPRB_XFLIP, [hl]		; Flip the sprite
	jp   .ret
.noFlip:
	res  SPRB_XFLIP, [hl]		; Visually unflip the sprite
.ret:
	ret
	
; =============== OBJLstS_DoAnimTiming_Loop_by_DE ===============
; Handles the timing for the current animation for the specified OBJInfo.
; Wrapper for OBJLstS_DoAnimTiming_Loop.
; IN
; - DE: Ptr to wOBJInfo struct
OBJLstS_DoAnimTiming_Loop_by_DE:
	push bc
		push de
			push de	; HL = DE
			pop  hl
			call OBJLstS_DoAnimTiming_Loop
		pop  de
	pop  bc
	ret
	
; =============== OBJLstS_DoAnimTiming_Initial_by_DE ===============
; Initializes the current animation frame.
; Wrapper for OBJLstS_DoAnimTiming_Initial.
; IN
; - DE: Ptr to wOBJInfo struct
OBJLstS_DoAnimTiming_Initial_by_DE:
	push bc
		push de
			push de	; HL = DE
			pop  hl
			call OBJLstS_DoAnimTiming_Initial
		pop  de
	pop  bc
	ret
; =============== Play_Pl_ExecSpecMoveInputCode ===============
; Executes the character-specific special move input reader code, as defined in iPlInfo_MoveInputCodePtr.
; IN
; - BC: Ptr to wPlInfo structure
; - DE: Ptr to respective wOBJInfo structure
; OUT
; - C flag: If set, a move was started
Play_Pl_ExecSpecMoveInputCode:
	
	ldh  a, [hROMBank]	; Save current bank
	push af
		call .exec		; Run the code. Was a new move started?
		jp   c, .retSet	; If so, jump
.retClear:
	pop  af
	ld   [MBC1RomBank], a	; Restore bank
	ldh  [hROMBank], a
	xor  a	; Clear carry
	ret
.retSet:
	pop  af
	ld   [MBC1RomBank], a	; Restore bank
	ldh  [hROMBank], a
	scf		; Set carry
	ret
.exec:
	; Run the code for it
	ld   hl, iPlInfo_MoveInputCodePtr_High
	add  hl, bc			
	push de
		; DE = Code ptr
		ld   d, [hl]	; iPlInfo_MoveInputCodePtr_High
		inc  hl			 
		ld   e, [hl]	; iPlInfo_MoveInputCodePtr_Low
		
		; Switch to the bank for it
		inc  hl			
		ld   a, [hl]			; iPlInfo_MoveInputCodePtr_Bank
		ld   [MBC1RomBank], a
		ldh  [hROMBank], a
		
		push de			; Move code ptr to HL
		pop  hl
	pop  de
	
	;
	; Every input reader code (MoveInputS_*) uses these parameters:
	; IN
	; - BC: Ptr to wPlInfo structure
	; - DE: Ptr to respective wOBJInfo structure
	; OUT
	; - C flag: If set, a move was started
	jp   hl				; Execute it
	
; =============== Play_Pl_DoBasicMoveInput ===============
; Handles basic player movement, basic attacks, and setting moves
; when getting attacked.
; This updates player flags and can set a MOVE_SHARED_* move.
; IN
; - BC: Ptr to wPlInfo structure
; - DE: Ptr to respective wOBJInfo structure
Play_Pl_DoBasicMoveInput:
	push bc
		push de
		
		;
		; Handle starting throws
		;
		BasicInput_ChkThrowStart:

			call Play_Pl_ChkThrowInput			; Started a throw?		
			jp   nc, .end						; If not, jump
			cp   PLAY_THROWOP_GROUND			; Ground throw?
			jp   z, BasicInput_StartGroundThrow	; If so, jump
			cp   PLAY_THROWOP_AIR				; Air throw?
			jp   z, BasicInput_StartAirThrow	; If so, jump
			; PLAY_THROWOP_UNUSED_BOTH not handled as a throw, it's for command throws only.
		.end:
		
		;
		; Handle air block input.
		; This is performed by holding back when doing neutral or backwards jumps.
		;
		; This is new to 96, originally it went straight to BasicInput_ChkBaseInput.
		;
		BasicInput_ChkAirBlock:
		
			; Check if we're moving backwards.
			; Moving backwards uses different keys depending on the side we're in.
			
			; Determine which key we're pressing first.
			ld   hl, iPlInfo_JoyKeysLH
			add  hl, bc
			ld   a, [hl]			; A = Absolute held inputs
			bit  KEYB_LEFT, a		; Moving left?
			jp   nz, .chkMoveL		; If so, jump
			bit  KEYB_RIGHT, a		; Moving right?
			jp   nz, .chkMoveR		; If so, jump
			jp   .end				; Otherwise, skip ahead
		.chkMoveL:
			; Left is backwards on the 1P side
			ld   hl, iOBJInfo_OBJLstFlags
			add  hl, de
			bit  SPRB_XFLIP, [hl]	; Facing right / 1P side? (so L -> backward)
			jp   nz, .chkJumpMove	; If so, jump
			jp   .end				; Otherwise, skip ahead
		.chkMoveR:
			; Right is backwards on the 2P side
			ld   hl, iOBJInfo_OBJLstFlags
			add  hl, de
			bit  SPRB_XFLIP, [hl]	; Facing right / 1P side? (so R -> forward)
			jp   nz, .end			; If so, skip ahead
			
		.chkJumpMove:
			; We must be doing a neutral or backwards jump.
			ld   hl, iPlInfo_MoveId
			add  hl, bc				
			ld   a, [hl]			
			cp   MOVE_SHARED_JUMP_N	; Doing a neutral jump?
			jp   z, .chkAir			; If so, jump
			cp   MOVE_SHARED_JUMP_B	; Doing a backwards jump?
			jp   z, .chkAir			; If so, jump
			jp   .end				; Otherwise, skip ahead
			
		.chkAir:
			; Air blocking of course only works in the air
			ld   hl, iOBJInfo_Y
			add  hl, de
			ld   a, [hl]
			cp   PL_FLOOR_POS	; iOBJInfo_Y == PL_FLOOR_POS?
			jp   z, .end		; If so, skip ahead
			
			; Projectiles can only be blocked in the air.
			; So as long as the opponent's projectile is active, try to air block it.
			ld   hl, iPlInfo_Flags0Other
			add  hl, bc
			bit  PF0B_PROJ, [hl]					; Does the other player have an active projectile?
			jp   nz, BasicInput_StartAirBlock	; If so, jump
			
			; Ground-based attacks can't be blocked in the air.
			ld   hl, iPlInfo_MoveDamageValOther
			add  hl, bc
			ld   a, [hl]
			or   a				; Is the other player performing an attack?
			jp   z, .end		; If not, skip ahead
			
			ld   hl, iPlInfo_OBJInfoYOther
			add  hl, bc
			ld   a, [hl]		
			cp   PL_FLOOR_POS				; Is the other player on the floor?
			jp   nz, BasicInput_StartAirBlock	; If not, jump
		.end:
		
		BasicInput_ChkBaseInput:
			; If basic input is disabled, return.
			;
			; This is important to prevent moves from being interrupted by
			; the basic movement actions.
			; ie: normally, the game returns to the idle move when nothing is pressed,
			;     but that shouldn't happen while performing another move.
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			bit  PF1B_NOBASICINPUT, [hl]
			jp   nz, BasicInput_End
			
			; If an intro/outro animation is playing, which is straight up a MoveId 
			; overriding whatever we're doing, display that.
			ld   hl, iPlInfo_IntroMoveId
			add  hl, bc
			ld   a, [hl]
			or   a
			jp   nz, BasicInput_StartIntroMove
			
			;
			; Main input reader
			;
			
			ld   hl, iPlInfo_JoyKeysLH
			add  hl, bc
			ld   a, [hl]
			; Note: jumpkicks are handled by the jump move code, not here.
			bit  KEYB_UP, a					; Holding up?
			jp   nz, BasicInput_StartJump	; If so, jump
			bit  KEYB_DOWN, a			; Holding down?
			jp   nz, BasicInput_ChkDown	; If so, jump
			; Normals (ground only)
			bit  KEPB_A_LIGHT, a				; Light kick?
			jp   nz, BasicInput_StartLightKick	; If so, jump
			bit  KEPB_B_LIGHT, a				; Light punch?
			jp   nz, BasicInput_StartLightPunch	; If so, jump
			bit  KEPB_A_HEAVY, a				; Heavy kick?
			jp   nz, BasicInput_ChkHeavyA	; If so, jump
			bit  KEPB_B_HEAVY, a				; Heavy punch?
			jp   nz, BasicInput_ChkHeavyB	; If so, jump
			; Horizontal movement
			bit  KEYB_LEFT, a	; Holding left?
			jp   nz, .chkWalkL	; If so, jump
			bit  KEYB_RIGHT, a	; Holding right?
			jp   nz, .chkWalkR	; If so, jump
			
			; Taunt
			ld   hl, iPlInfo_JoyNewKeys
			add  hl, bc
			bit  KEYB_SELECT, [hl]			; Did we press SELECT?
			jp   nz, BasicInput_ChkTaunt	; If so, jump
			
			jp   BasicInput_StartIdle
			
			; Determine if we're walking forwards or backwards
		.chkWalkL:
			; Left is backwards on the 1P side
			ld   hl, iOBJInfo_OBJLstFlags
			add  hl, de
			bit  SPRB_XFLIP, [hl]				; Facing right / 1P side? (so L -> backward)
			jp   nz, BasicInput_ChkWalkBack		; If so, jump
			jp   BasicInput_ChkWalkForward			; Otherwise, skip ahead
		.chkWalkR:
			; Right is backwards on the 2P side
			ld   hl, iOBJInfo_OBJLstFlags
			add  hl, de
			bit  SPRB_XFLIP, [hl]				; Facing right / 1P side? (so R -> forward)
			jp   nz, BasicInput_ChkWalkForward		; If so, skip ahead
			
		;
		; Checks for moves triggered by walking backwards
		;
		BasicInput_ChkWalkBack:
			; Walking back cancels the crouching state
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			res  PF1B_CROUCH, [hl]
			
			; B+B -> Hop Back
			mMvIn_ChkDirStrict MoveInput_BB, BasicInput_StartHopBack
			
			; If the other player is attacking, attempting to walk backwards will block instead.
			ld   hl, iPlInfo_Flags0Other
			add  hl, bc
			bit  PF0B_PROJ, [hl]					; Is the other player throwing a projectile?
			jp   nz, BasicInput_StartGroundBlock	; If so, jump	
			ld   hl, iPlInfo_MoveDamageValOther
			add  hl, bc
			ld   a, [hl]
			or   a									; Is the other player performing an attack?
			jp   nz, BasicInput_StartGroundBlock	; If so, jump
			
			; Otherwise, just walk back
			jp   BasicInput_StartWalkBack
			
		;
		; Checks for moves triggered when holding down.
		;
		BasicInput_ChkDown:
		
			;
			; D+PK -> Charge POW meter
			;
			
			; Ignore if fully charged
			ld   hl, iPlInfo_Pow
			add  hl, bc
			push af
				ld   a, PLAY_POW_MAX
				cp   a, [hl]			; Are we at max power?
				jp   z, .noCharge		; If so, skip
			pop  af
			; Check for A+B input
			call Play_Pl_AreBothBtnHeld			; Holding A+B?
			jp   c, BasicInput_StartChargeMeter	; If so, jump
			jp   .chkNormals
			.noCharge:
			pop  af
			
		.chkNormals:
			; For everything else, holding down means crouching
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			set  PF1B_CROUCH, [hl]
			
			; Check normals
			bit  KEPB_A_LIGHT, a
			jp   nz, BasicInput_StartCrouchLightKick
			bit  KEPB_B_LIGHT, a
			jp   nz, BasicInput_StartCrouchLightPunch
			bit  KEPB_A_HEAVY, a
			jp   nz, BasicInput_StartCrouchHeavyKick
			bit  KEPB_B_HEAVY, a
			jp   nz, BasicInput_StartCrouchHeavyPunch
			
			; Check crouch block
			bit  KEYB_LEFT, a	
			jp   nz, .chkL
			bit  KEYB_RIGHT, a
			jp   nz, .chkR
			
			; D -> Idle crouching
			jp   BasicInput_StartCrouchIdle
			
			
			;
			; Determine if we're holding forwards or backwards, depending on the side we're in.
			;
		.chkL:
			; Left is backwards on the 1P side
			ld   hl, iOBJInfo_OBJLstFlags
			add  hl, de
			bit  SPRB_XFLIP, [hl]				; Facing right / 1P side? (so L -> backward)
			jp   nz, BasicInput_ChkCrouchBack	; If so, jump
			
			; In 95, this used to jump to somewhere different, as for a few characters,
			; moving forwards while crouching allowed you to crouch walk.
			; That code is gone in this game, so instead we jump to the idle code for crouching.
			jp   BasicInput_StartCrouchIdle			; Otherwise, skip ahead
		.chkR:
			; Right is backwards on the 2P side
			ld   hl, iOBJInfo_OBJLstFlags
			add  hl, de
			bit  SPRB_XFLIP, [hl]				; Facing right / 1P side? (so R -> forward)
			jp   nz, BasicInput_StartCrouchIdle					; If so, skip ahead
												; Otherwise, we're holding back
		;
		; Checks for blocking while crouching
		;								
		BasicInput_ChkCrouchBack:
			; We can only block if the other player is attacking.
			; Otherwise, fall-through into the idle crouch code.
			ld   hl, iPlInfo_Flags0Other
			add  hl, bc
			bit  PF0B_PROJ, [hl]						; Is there an enemy projectile?
			jp   nz, BasicInput_StartGroundBlock	; If so, block
			
			ld   hl, iPlInfo_MoveDamageValOther
			add  hl, bc
			ld   a, [hl]
			or   a									; Is the other player attacking?
			jp   nz, BasicInput_StartGroundBlock	; If so, block
			
		;
		; Starts the crouch idle move.
		;		
		BasicInput_StartCrouchIdle:
			; Don't start crouching if we're already doing so
			ld   hl, iPlInfo_MoveId
			add  hl, bc
			ld   a, [hl]
			cp   MOVE_SHARED_CROUCH		; iPlInfo_MoveId == MOVE_SHARED_CROUCH
			jp   z, BasicInput_End		; If so, return
			
			; Set flags
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			res  PF1B_GUARD, [hl]		; Don't guard
										; PF1B_CROUCH got already set before
			; New move
			ld   a, MOVE_SHARED_CROUCH
			call Pl_SetMove_StopSpeed
			jp   BasicInput_End
			
		;
		; Starts the standing idle move.
		;
		BasicInput_StartIdle:
			; Don't start idling if we're already doing so
			ld   hl, iPlInfo_MoveId
			add  hl, bc
			ld   a, [hl]
			cp   MOVE_SHARED_IDLE
			jp   z, BasicInput_End
			
			; Set flags
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			res  PF1B_GUARD, [hl]
			res  PF1B_CROUCH, [hl]
			
			; New move
			ld   a, MOVE_SHARED_IDLE
			call Pl_SetMove_StopSpeed
			
			jp   BasicInput_End

		;
		; Checks for moves triggered by pressing forwards.
		;
		BasicInput_ChkWalkForward:
			; F+F -> Run forwards
			mMvIn_ChkDirStrict MoveInput_FF, BasicInput_StartRun
			; Fall-through
			
		;
		; Starts walking forwards.
		;
		BasicInput_StartForward:
			; Don't start if we're doing it already
			ld   hl, iPlInfo_MoveId
			add  hl, bc
			ld   a, [hl]				; A = MoveId	
			cp   MOVE_SHARED_WALK_F		; MoveId == forwards walking?
			jp   z, BasicInput_End		; If so, return
			
			; Update flags
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			res  PF1B_GUARD, [hl]		; Only set when switching to the actual block move
			res  PF1B_CROUCH, [hl]		; Walking is not crouching
			
			; New move
			ld   a, MOVE_SHARED_WALK_F
			call Pl_SetMove_StopSpeed
			
			; Apply continuous movement speed since we just nuked it
			ld   hl, iPlInfo_SpeedX					; HL = Offset to walk speed for this char
			call Pl_GetWord							; HL = Word value at iPlInfo_SpeedX
			call Play_OBJLstS_SetSpeedH_ByXFlipR	; Move horizontally by that
			jp   BasicInput_End
			
		;
		; Starts walking backwards.
		;
		BasicInput_StartWalkBack:
			; Don't start if we're doing it already
			ld   hl, iPlInfo_MoveId
			add  hl, bc
			ld   a, [hl]				; A = MoveId	
			cp   MOVE_SHARED_WALK_B		; MoveId == backwards walking?
			jp   z, BasicInput_End		; If so, return
			
			; Update flags
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			res  PF1B_GUARD, [hl]		; Only set when switching to the actual block move
			res  PF1B_CROUCH, [hl]		; Walking is not crouching
			
			; New move
			ld   a, MOVE_SHARED_WALK_B
			call Pl_SetMove_StopSpeed
			
			; Apply continuous movement speed since we just nuked it
			ld   hl, iPlInfo_BackSpeedX				; HL = Offset to backwalk speed for this char
			call Pl_GetWord							; HL = Word value at iPlInfo_BackSpeedX
			call Play_OBJLstS_SetSpeedH_ByXFlipR	; Move horizontally by that
			jp   BasicInput_End
			
		;
		; Starts any kind of jump.
		;
		BasicInput_StartJump:
		
			;
			; Update the running jump flag.
			; While the resulting jump is the same as a forward hyper jump from crouching (see .chkJumpR),
			; this being a separate variables allows special moves to distinguish between the two.
			;
			ld   hl, iPlInfo_RunningJump
			add  hl, bc
			ld   [hl], $00				; iPlInfo_RunningJump = 0
			
			; MoveC_Base_RunF sets iPlInfo_MoveId to MOVE_SHARED_RUN_F when we stop running.
			; If we got here, it's because we stopped running by pressing the jump button during a run.
			ld   hl, iPlInfo_MoveId
			add  hl, bc
			ld   a, [hl]
			cp   MOVE_SHARED_RUN_F		; iPlInfo_MoveId == forward dash?
			jp   nz, .start				; If not, skip
			
			ld   hl, iPlInfo_RunningJump
			add  hl, bc
			ld   [hl], $01
			
		.start:
			; Backup the joypad info from before the jump to here.
			; It will be used during the jump when deciding which direction/speed to use.
			ld   hl, iPlInfo_JoyKeys
			add  hl, bc			; Seek to iPlInfo_JoyKeys
			push de
				ldi  a, [hl]	; A = iPlInfo_JoyKeys
				ld   d, [hl]	; D = iPlInfo_JoyNewKeysLH
				inc  hl			; Seek to iPlInfo_JoyKeysPreJump
				ldi  [hl], a	; iPlInfo_JoyKeysPreJump = iPlInfo_JoyKeys
				ld   [hl], d	; iPlInfo_JoyNewKeysLHPreJump = iPlInfo_JoyNewKeysLH
			pop  de
			
			; Set standard flags except PF1B_NOSPECSTART, otherwise we
			; couldn't start air specials.
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			res  PF1B_GUARD, [hl]
			res  PF1B_CROUCH, [hl]
			set  PF1B_NOBASICINPUT, [hl]
			set  PF1B_XFLIPLOCK, [hl]
			
			; Always start a neutral jump by default.
			; The code for it will then detect if it should switch to
			; either the backwards or forwards jumps.
			ld   a, MOVE_SHARED_JUMP_N
			call Pl_SetMove_StopSpeed
			jp   BasicInput_End
			
		;
		; Starts a ground block if we weren't performing one already.
		;
		BasicInput_StartGroundBlock:
			; Check if we're doing low/crouch or mid/standing block
			ld   hl, iPlInfo_MoveId
			add  hl, bc
			ld   a, [hl]				; A = MoveId
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			bit  PF1B_CROUCH, [hl]		; Are we crouching?
			jr   nz, .crouch			; If so, jump
		.stand:
			cp   MOVE_SHARED_BLOCK_G	; Are we mid blocking already?
			jp   z, BasicInput_End		; If so, return
			ld   a, MOVE_SHARED_BLOCK_G	; Otherwise, start the mid block
			jr   .start
		.crouch:
			cp   MOVE_SHARED_BLOCK_C	; Are we low blocking already?
			jp   z, BasicInput_End		; If so, return
			ld   a, MOVE_SHARED_BLOCK_C	; Otherwise, start the low block
		.start:
			; Set the block flag and switch to the appropriate move.
			; For obvious reasons, this is done before execution gets to HomeCall_Play_Pl_DoHit.
			set  PF1B_GUARD, [hl]		; Do the block
			call Pl_SetMove_StopSpeed
			jp   BasicInput_End
			
		;
		; Starts air blocking.
		;
		BasicInput_StartAirBlock:
			; If we're already air blocking, return
			ld   hl, iPlInfo_MoveId
			add  hl, bc
			ld   a, [hl]
			cp   MOVE_SHARED_BLOCK_A	; In the air block move?
			jp   z, BasicInput_End		; If so, return
			
			; Otherwise, switch to it
			ld   a, MOVE_SHARED_BLOCK_A	; A = Move to start
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			set  PF1B_GUARD, [hl]			; Guard against attacks
			call Pl_Unk_SetNewMoveAndAnim	; Switch to move A
			jp   BasicInput_End
			
		;
		; Starts charging meter.
		;
		BasicInput_StartChargeMeter:
			; Play SGB/DMG SFX
			ld   a, SCT_CHARGEMETER
			call HomeCall_Sound_ReqPlayExId
			
			; Set standard flags
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			res  PF1B_GUARD, [hl]			; Player is vulnerable
			res  PF1B_CROUCH, [hl]			; and standing
			set  PF1B_NOBASICINPUT, [hl]	; Not cancellable by movement
			set  PF1B_XFLIPLOCK, [hl]		; Doesn't turn if opponent jumps over
			set  PF1B_NOSPECSTART, [hl]		; Not cancellable by specials
			
			; New move
			ld   a, MOVE_SHARED_CHARGEMETER
			call Pl_SetMove_StopSpeed
			jp   BasicInput_End
			
		;
		; Starts a standing light punch.
		;
		BasicInput_StartLightPunch:
			; Set flags
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			res  PF1B_GUARD, [hl]	; Normals not guarded
			res  PF1B_CROUCH, [hl]	; From standing
			set  PF1B_NOBASICINPUT, [hl] 
			set  PF1B_XFLIPLOCK, [hl]
			; Normals can't be cancelled into specials.
			; They can only be cancelled when hitting the opponent (PF1B_ALLOWHITCANCEL)
			set  PF1B_NOSPECSTART, [hl] ; Can't cancel into special
			
			; New move
			ld   a, MOVE_SHARED_PUNCH_L
			call Pl_SetMove_ResetNewKeysLH
			jp   BasicInput_End
			
		;
		; Checks for input requiring an heavy punch.
		;
		BasicInput_ChkHeavyB:
			call Play_Pl_AreBothBtnHeld				; Holding A+B?
			jp   nc, BasicInput_StartHeavyPunch		; If not, skip
			
			; PK -> Heavy Attack
			call Play_Pl_GetDirKeys_ByXFlipR		; Holding any d-pad key?
			jp   nc, BasicInput_StartHeavyAttack	; If not, jump
			; These are relative to the 1P side, so...
			; F+PK -> Roll forwards 
			bit  KEYB_RIGHT, a						; Holding forwards?
			jp   nz, BasicInput_StartRollForward	; If so, jump
			; B+PK -> Roll backwards 
			jp   BasicInput_StartRollBackward		; Otherwise, assume holding backwards
			
		;
		; Starts a standing heavy punch.
		;
		BasicInput_StartHeavyPunch:
			; Play SGB/DMG SFX
			ld   a, SCT_HEAVY
			call HomeCall_Sound_ReqPlayExId
			
			; Set standard attack flags
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			res  PF1B_GUARD, [hl]
			res  PF1B_CROUCH, [hl]
			set  PF1B_NOBASICINPUT, [hl]
			set  PF1B_XFLIPLOCK, [hl]
			set  PF1B_NOSPECSTART, [hl]
			
			; New move
			ld   a, MOVE_SHARED_PUNCH_H
			call Pl_SetMove_ResetNewKeysLH
			jp   BasicInput_End
			
		;
		; Starts a standing light kick.
		;	
		BasicInput_StartLightKick:
			; Set standard attack flags
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			res  PF1B_GUARD, [hl]
			res  PF1B_CROUCH, [hl]
			set  PF1B_NOBASICINPUT, [hl]
			set  PF1B_XFLIPLOCK, [hl]
			set  PF1B_NOSPECSTART, [hl]
			
			; New move
			ld   a, MOVE_SHARED_KICK_L
			call Pl_SetMove_ResetNewKeysLH
			jp   BasicInput_End
			
		;
		; Checks for input requiring an heavy kick.
		; See also: BasicInput_ChkHeavyB
		;
		BasicInput_ChkHeavyA:
			call Play_Pl_AreBothBtnHeld				; Holding A+B?
			jp   nc, BasicInput_StartHeavyKick		; If not, skip
			
			; PK -> Heavy Attack
			call Play_Pl_GetDirKeys_ByXFlipR		; Holding any d-pad key?
			jp   nc, BasicInput_StartHeavyAttack	; If not, jump
			; These are relative to the 1P side, so...
			; F+PK -> Roll forwards 
			bit  KEYB_RIGHT, a						; Holding forwards?
			jp   nz, BasicInput_StartRollForward	; If so, jump
			; B+PK -> Roll backwards 
			jp   BasicInput_StartRollBackward		; Otherwise, assume holding backwards
			
		;
		; Starts a standing heavy kick.
		;
		BasicInput_StartHeavyKick:
			; Play SGB/DMG SFX
			ld   a, SCT_HEAVY
			call HomeCall_Sound_ReqPlayExId
			
			; Set standard attack flags
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			res  PF1B_GUARD, [hl]
			res  PF1B_CROUCH, [hl]
			set  PF1B_NOBASICINPUT, [hl]
			set  PF1B_XFLIPLOCK, [hl]
			set  PF1B_NOSPECSTART, [hl]
			
			; New move
			ld   a, MOVE_SHARED_KICK_H
			call Pl_SetMove_ResetNewKeysLH
			jp   BasicInput_End
			
		;
		; Starts a crouching light punch.
		;
		BasicInput_StartCrouchLightPunch:
			; [POI] If the autocharge cheat is enabled, crouching lps reflect projectiles.
			ld   a, [wDipSwitch]
			bit  DIPB_AUTO_CHARGE, a	; Is the cheat set?
			jp   z, .go					; If not, skip
			ld   hl, iPlInfo_Flags0
			add  hl, bc					; Otherwise, make it reflect projectiles
			set  PF0B_PROJREFLECT, [hl]
		.go:
			; Set standard crouching attack flags.
			; Same as normal, except without resetting PF1B_CROUCH.
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			res  PF1B_GUARD, [hl]
			set  PF1B_NOBASICINPUT, [hl]
			set  PF1B_XFLIPLOCK, [hl]
			set  PF1B_NOSPECSTART, [hl]
			
			; New move
			ld   a, MOVE_SHARED_PUNCH_CL
			call Pl_SetMove_ResetNewKeysLH
			jp   BasicInput_End
			
		;
		; Starts a crouching heavy punch.
		;
		BasicInput_StartCrouchHeavyPunch:
			; Play SGB/DMG SFX
			ld   a, SCT_HEAVY
			call HomeCall_Sound_ReqPlayExId
			
			; [POI] If the autocharge cheat is enabled, crouching hps erase projectiles.
			ld   a, [wDipSwitch]
			bit  DIPB_AUTO_CHARGE, a	; Is the cheat set?
			jp   z, .go					; If not, skip
			ld   hl, iPlInfo_Flags0
			add  hl, bc					; Otherwise, make it delete projectiles
			set  PF0B_PROJREM, [hl]
		.go:
		
			; Set standard crouching attack flags.
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			res  PF1B_GUARD, [hl]
			set  PF1B_NOBASICINPUT, [hl]
			set  PF1B_XFLIPLOCK, [hl]
			set  PF1B_NOSPECSTART, [hl]
			
			; New move
			ld   a, MOVE_SHARED_PUNCH_CH
			call Pl_SetMove_ResetNewKeysLH
			jp   BasicInput_End
			
		;
		; Starts a crouching light kick.
		;
		BasicInput_StartCrouchLightKick:
			; Set standard crouching attack flags.
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			res  PF1B_GUARD, [hl]
			set  PF1B_NOBASICINPUT, [hl]
			set  PF1B_XFLIPLOCK, [hl]
			set  PF1B_NOSPECSTART, [hl]
			; New move
			ld   a, MOVE_SHARED_KICK_CL
			call Pl_SetMove_ResetNewKeysLH
			jp   BasicInput_End
			
		;
		; Starts a crouching heavy kick.
		;
		BasicInput_StartCrouchHeavyKick:
			; Play SGB/DMG SFX
			ld   a, SCT_HEAVY
			call HomeCall_Sound_ReqPlayExId
			
			; Set standard crouching attack flags.
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			res  PF1B_GUARD, [hl]
			set  PF1B_NOBASICINPUT, [hl]
			set  PF1B_XFLIPLOCK, [hl]
			set  PF1B_NOSPECSTART, [hl]
			
			; New move
			ld   a, MOVE_SHARED_KICK_CH
			call Pl_SetMove_ResetNewKeysLH
			jp   BasicInput_End
			
		;
		; Starts a forwards roll.
		;
		BasicInput_StartRollForward:
			; Can't hyper jump out of a normal roll
			ld   hl, iPlInfo_RunningJump
			add  hl, bc
			ld   [hl], $00
			
			; Set standard flags
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			res  PF1B_GUARD, [hl]
			res  PF1B_CROUCH, [hl]
			set  PF1B_NOBASICINPUT, [hl]
			set  PF1B_XFLIPLOCK, [hl]
			set  PF1B_NOSPECSTART, [hl]
			
			; Rolling is invulnerable to everything except throws (ie: moves that use iOBJInfo_ForceHitboxId)
			inc  hl	; Seek to iPlInfo_Flags2
			set  PF2B_NOHURTBOX, [hl]
			set  PF2B_NOCOLIBOX, [hl]
			
			; New move
			ld   a, MOVE_SHARED_ROLL_F
			call Pl_SetMove_StopSpeed
			jp   BasicInput_End
			
		;
		; Starts a backwards roll.
		;
		BasicInput_StartRollBackward:
			; Can't hyper jump out of a normal roll
			ld   hl, iPlInfo_RunningJump
			add  hl, bc
			ld   [hl], $00
			
			; Set standard flags
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			res  PF1B_GUARD, [hl]
			res  PF1B_CROUCH, [hl]
			set  PF1B_NOBASICINPUT, [hl]
			set  PF1B_XFLIPLOCK, [hl]
			set  PF1B_NOSPECSTART, [hl]
			
			; Rolling is invulnerable to everything except throws (ie: moves that use iOBJInfo_ForceHitboxId)
			inc  hl	; Seek to iPlInfo_Flags2
			set  PF2B_NOHURTBOX, [hl]
			set  PF2B_NOCOLIBOX, [hl]
			
			; New move
			ld   a, MOVE_SHARED_ROLL_B
			call Pl_SetMove_StopSpeed
			jp   BasicInput_End
			
		;
		; Starts a standing "heavy attack" (the A+B one)
		;
		BasicInput_StartHeavyAttack:
			; Play SGB/DMG SFX
			ld   a, SCT_HEAVY
			call HomeCall_Sound_ReqPlayExId
			
			; Set standard attack flags
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			res  PF1B_GUARD, [hl]
			res  PF1B_CROUCH, [hl]
			set  PF1B_NOBASICINPUT, [hl]
			set  PF1B_XFLIPLOCK, [hl]
			set  PF1B_NOSPECSTART, [hl]
			
			; New move
			ld   a, MOVE_SHARED_ATTACK_G
			call Pl_SetMove_StopSpeed
			jp   BasicInput_End
			
		;
		; Starts a forwards run (dash forwards).
		;
		BasicInput_StartRun:
			; It's possible to cancel the run into a special move, so...
			
			; Clear input buffer so only newly pressed inputs count
			; for starting a special in the middle of the run.
			call Play_Pl_ClearJoyDirBuffer
			
			; Set standard flags except for PF1B_NOSPECSTART
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			res  PF1B_GUARD, [hl]
			res  PF1B_CROUCH, [hl]
			set  PF1B_NOBASICINPUT, [hl]
			set  PF1B_XFLIPLOCK, [hl]
			
			; New move
			ld   a, MOVE_SHARED_RUN_F
			call Pl_SetMove_StopSpeed
			
			; Set continuous running speed
			ld   hl, iPlInfo_SpeedX					; HL = Offset to walk speed for this char
			call Pl_GetWord							; HL = Word value at iPlInfo_SpeedX
			sla  l									; Run speed is double the walk speed
			rl   h
			call Play_OBJLstS_SetSpeedH_ByXFlipR	; Move horizontally by that
			jp   BasicInput_End
			
		;
		; Starts a backwards hop (dash backwards).
		;
		BasicInput_StartHopBack:
			; Like with the forwards run
			call Play_Pl_ClearJoyDirBuffer
			
			; Standard flags except for PF1B_NOSPECSTART, as it's possible
			; to cancel the run into a special move.
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			res  PF1B_GUARD, [hl]
			res  PF1B_CROUCH, [hl]
			set  PF1B_NOBASICINPUT, [hl]
			set  PF1B_XFLIPLOCK, [hl]
			
			; New move
			ld   a, MOVE_SHARED_HOP_B
			call Pl_SetMove_StopSpeed
			jp   BasicInput_End
			
		;
		; Starts a taunt, which reduces meter.
		;
		BasicInput_ChkTaunt:
			; Play SGB/DMG SFX.
			; Each character defines its own sound effect for the move.
			; Some bootlegs with more characters don't change this list,
			; causing an invalid command to be played (which kills the music until a new one starts).
			ld   hl, iPlInfo_CharId
			add  hl, bc
			ld   a, [hl]	; A = CharId*2
			srl  a			; /2 since it's a byte table
			push de
				ld   hl, .sndActTbl	; HL = Ptr to SCT table
				ld   d, $00			; DE = Index
				ld   e, a
				add  hl, de			; Index the table
			pop  de
			ld   a, [hl]			; A = Sound command ID
			call HomeCall_Sound_ReqPlayExId
			
			; Set standard flags except for PF1B_NOSPECSTART.
			; It's possible to cancel it into a special, though unlike other
			; versions the meter stops decreasing once that's done.
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			res  PF1B_GUARD, [hl]
			res  PF1B_CROUCH, [hl]
			set  PF1B_NOBASICINPUT, [hl]
			set  PF1B_XFLIPLOCK, [hl]
			
			; New move
			ld   a, MOVE_SHARED_TAUNT
			call Pl_SetMove_StopSpeed
			jp   BasicInput_End
		.sndActTbl:
			db SCT_TAUNT_B ; CHAR_ID_KYO     
			db SCT_TAUNT_A ; CHAR_ID_DAIMON  
			db SCT_TAUNT_B ; CHAR_ID_TERRY   
			db SCT_TAUNT_B ; CHAR_ID_ANDY    
			db SCT_TAUNT_B ; CHAR_ID_RYO     
			db SCT_TAUNT_B ; CHAR_ID_ROBERT  
			db SCT_TAUNT_D ; CHAR_ID_ATHENA  
			db SCT_TAUNT_D ; CHAR_ID_MAI     
			db SCT_TAUNT_C ; CHAR_ID_LEONA   
			db SCT_TAUNT_A ; CHAR_ID_GEESE   
			db SCT_TAUNT_A ; CHAR_ID_KRAUSER 
			db SCT_TAUNT_A ; CHAR_ID_MRBIG   
			db SCT_TAUNT_B ; CHAR_ID_IORI    
			db SCT_TAUNT_D ; CHAR_ID_MATURE  
			db SCT_TAUNT_D ; CHAR_ID_CHIZURU 
			db SCT_TAUNT_A ; CHAR_ID_GOENITZ 
			db SCT_TAUNT_A ; CHAR_ID_MRKARATE
			db SCT_TAUNT_A ; CHAR_ID_OIORI   
			db SCT_TAUNT_C ; CHAR_ID_OLEONA  
			db SCT_TAUNT_C ; CHAR_ID_KAGURA  
			
		;
		; Starts the intro/outro move to be executed/displayed over whatever
		; we would normally display (the idle animation).
		; IN
		; - A: iPlInfo_IntroMoveId
		;
		BasicInput_StartIntroMove:
			; Set standard flags
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			res  PF1B_GUARD, [hl]
			res  PF1B_CROUCH, [hl]
			set  PF1B_NOBASICINPUT, [hl]
			set  PF1B_XFLIPLOCK, [hl]
			set  PF1B_NOSPECSTART, [hl]
			
			; New move
			call Pl_SetMove_StopSpeed
			jp   BasicInput_End
			
		;
		; Handles the second part of a ground throw (PLAY_THROWACT_NEXT02 & PLAY_THROWACT_NEXT03),
		; when the opponent gets grabbed and before he starts rotating (PLAY_THROWACT_NEXT04).
		; The opponent can throw tech during this mode.
		;
		BasicInput_StartGroundThrow:
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			; Set standard flags
			res  PF1B_GUARD, [hl]
			res  PF1B_CROUCH, [hl]
			set  PF1B_NOBASICINPUT, [hl]
			res  PF1B_XFLIPLOCK, [hl]	; What
			set  PF1B_XFLIPLOCK, [hl]
			set  PF1B_NOSPECSTART, [hl]
			; Completely invulnerable while throwing
			set  PF1B_INVULN, [hl]
			
			; New move
			ld   a, MOVE_SHARED_THROW_G
			call Pl_SetMove_StopSpeed
			; Wait 1 frame
			call Task_PassControlFar
			; Switch to the next part of the throw.
			ld   a, PLAY_THROWACT_NEXT03
			ld   [wPlayPlThrowActId], a
			; Show effects
			call Play_StartThrowEffect
			
		.loop:
			;
			; Wait in this loop until the grab naturally ends, or if we get throw tech'd.
			;
			
			; If we got into PLAY_THROWACT_NEXT04, the grab was confirmed.
			; The opponent won't be able to cancel this anymore.
			ld   a, [wPlayPlThrowActId]
			cp   PLAY_THROWACT_NEXT04	; Did we proceed to the next part?
			jp   z, .throwOk			; If so, jump
			; If it's in anything other than PLAY_THROWACT_NEXT03, we got throw tech'd.
			cp   PLAY_THROWACT_NEXT03	; Did we get throw 
			jp   nz, .throwFail
			
			; We're still on PLAY_THROWACT_NEXT03, continue looping
			call Task_PassControlFar
			jp   .loop
		.throwOk:
			; Return to this to double the length of the "grab" portion of the throw.
			; Visually, it looks as if it's possible to throw tech for half the time
			; the grab mode is visible.
			ld   a, PLAY_THROWACT_NEXT03
			ld   [wPlayPlThrowActId], a
			jp   BasicInput_End
		.throwFail:
			; Play the SFX
			ld   a, SCT_BREAK
			call HomeCall_Sound_ReqPlayExId
			; We're on the receiving end of the throw tech.
			; It should also reset the screen shake in case the throw was going to do one.
			ld   a, MOVE_SHARED_GUARDBREAK_G
			call Pl_SetMove_ShakeScreenReset
			; Flash the playfield (slightly differently) to signal that the throw got aborted
			ld   a, $F0
			ld   [wStageBGP], a
			; We're not invulnerable anymore as the throw got aborted
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			res  PF1B_INVULN, [hl]
			; Shake more before getting pushed back by the throw tech
			inc  hl ; Seek to iPlInfo_Flags2
			inc  hl ; Seek to iPlInfo_Flags3
			set  PF3B_SHAKELONG, [hl]
			jp   BasicInput_End
			
		;
		; Handles the second part of an air throw.
		;
		BasicInput_StartAirThrow:
			;
			; Air throws are much simpler.
			; They are immediately effective: the opponent rotates and there's no grab mode,
			; so the opponent can't throw tech them.
			; That's probably why the CPU can't be thrown with them.
			;
			ld   hl, iPlInfo_Flags1
			add  hl, bc
			; Set standard flags
			res  PF1B_GUARD, [hl]
			res  PF1B_CROUCH, [hl]
			set  PF1B_NOBASICINPUT, [hl]
			res  PF1B_XFLIPLOCK, [hl]	; What
			set  PF1B_XFLIPLOCK, [hl]
			set  PF1B_NOSPECSTART, [hl]
			; Completely invulnerable while throwing
			set  PF1B_INVULN, [hl]
			
			; New move
			ld   a, MOVE_SHARED_THROW_A
			call Pl_SetMove_StopSpeed
			; Wait 1 frame
			call Task_PassControlFar
			; Switch to the next part of the throw.
			ld   a, PLAY_THROWACT_NEXT03
			ld   [wPlayPlThrowActId], a
			; Show effects
			call Play_StartThrowEffect
			jp   BasicInput_End
			
		BasicInput_End:
		pop  de
	pop  bc
	ret
	
; =============== Pl_SetMove_* ===============
; Set of subroutines that start a new move, initialize its animation, and optionally cause a specific effect.
; Moves use one of these rather than directly calling Pl_SetNewMove.

; =============== Pl_SetMove_StopSpeed ===============
; Starts a new move and initializes its animation.
; This is for continuous moves that kill the player momentum when used (ie: most of them).
; IN
; - A: Move ID
; - BC: Ptr to wPlInfo structure
; - DE: Ptr to respective wOBJInfo structure
Pl_SetMove_StopSpeed:
	push bc
		push de
			call Pl_SetNewMove
			
			; Reset player speed when starting the move
			ld   hl, iOBJInfo_SpeedX
			add  hl, de		; Seek to iOBJInfo_SpeedX
			xor  a			; Clear...
			ldi  [hl], a	; ...iOBJInfo_SpeedX
			ldi  [hl], a	; ...iOBJInfo_SpeedXSub
			ldi  [hl], a	; ...iOBJInfo_SpeedY
			ld   [hl], a	; ...iOBJInfo_SpeedYSub
			
			; Set up initial GFX buffer info settings for the animation
			push de
			pop  hl
			call OBJLstS_DoAnimTiming_Initial
		pop  de
	pop  bc
	ret
	
; =============== Pl_SetMove_ResetNewKeysLH ===============
; Starts a new move and initializes its animation.
; This is used for starting basic moves (BasicInput_ChkBaseInput) that depend on the light/heavy status.
;
; These basic inputs don't kill the player's momentum, but do unmark any other newly pressed key,
; in case we're starting a move that calls Play_Pl_CreateJoyMergedKeysLH to do something 
; (ie: start chained move, end the move early, ...)
;
; IN
; - A: Move ID
; - BC: Ptr to wPlInfo structure
; - DE: Ptr to respective wOBJInfo structure
Pl_SetMove_ResetNewKeysLH:
	push bc
		push de
			call Pl_SetNewMove
			
			; Reset iPlInfo_JoyNewKeysLH
			ld   hl, iPlInfo_JoyNewKeysLH
			add  hl, bc
			ld   [hl], $00
			
			; Set up initial GFX buffer info settings for the animation
			push de
			pop  hl
			call OBJLstS_DoAnimTiming_Initial
		pop  de
	pop  bc
	ret
	
; =============== Pl_Unk_SetNewMoveAndAnim ===============	
; Starts a new move and initializes its animation.
; This has no special effect.
; IN
; - A: Move ID
; - BC: Ptr to wPlInfo structure
; - DE: Ptr to respective wOBJInfo structure
Pl_Unk_SetNewMoveAndAnim:
	push bc
		push de
			call Pl_SetNewMove
			
			; Set up initial GFX buffer info settings for the animation
			push de
			pop  hl
			call OBJLstS_DoAnimTiming_Initial
		pop  de
	pop  bc
	ret
	
; =============== Pl_SetMove_ShakeScreenReset ===============
; Starts a new move and initializes its animation.
; This one resets the earthquake effect and all move damage fields (in case they were used alongside the former).
; This is done because move that use this do an earthquake effect themselves.
; IN
; - A: Move ID
; - BC: Ptr to wPlInfo structure
; - DE: Ptr to respective wOBJInfo structure
Pl_SetMove_ShakeScreenReset:
	push bc
		push de
			call Pl_SetNewMove
			
			; Reset player speed when starting the move
			ld   hl, iOBJInfo_SpeedX
			add  hl, de		; Seek to iOBJInfo_SpeedX
			xor  a			; Clear...
			ldi  [hl], a	; ...iOBJInfo_SpeedX
			ldi  [hl], a	; ...iOBJInfo_SpeedXSub
			ldi  [hl], a	; ...iOBJInfo_SpeedY
			ld   [hl], a	; ...iOBJInfo_SpeedYSub
			
			; Set up initial GFX buffer info settings for the animation
			push de
			pop  hl
			call OBJLstS_DoAnimTiming_Initial
		pop  de
	pop  bc
	
	; Reset screen shake effect
	ld   hl, wScreenShakeY
	ld   [hl], $00
	
	; Reset all move damage fields that were just set by Pl_SetNewMove
	ld   hl, iPlInfo_MoveDamageVal
	add  hl, bc
	xor  a			; Clear...
	ldi  [hl], a	; ...iPlInfo_MoveDamageVal		
	ldi  [hl], a	; ...iPlInfo_MoveDamageHitAnimId	
	ld   [hl], a	; ...iPlInfo_MoveDamageFlags3	
	ld   hl, iPlInfo_MoveDamageValNext
	add  hl, bc
	ldi  [hl], a	; ...iPlInfo_MoveDamageValNext		
	ldi  [hl], a	; ...iPlInfo_MoveDamageHitAnimIdNext	
	ld   [hl], a	; ...iPlInfo_MoveDamageFlags3Next	
	ret
	
	
; =============== Play_Pl_MoveByColiBoxOverlapX ===============	
; Pushes the player backwards when the collision box overlaps with the opponent's.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
Play_Pl_MoveByColiBoxOverlapX:
	; If we're being thrown, ignore this
	ld   a, [wPlayPlThrowActId]
	or   a
	ret  nz
	
	; When the main task processed the collision boxes earlier this frame,
	; it set iPlInfo_ColiBoxOverlapX with the amount we're inside the opponent.
	
	; We get pushed backwards by half that amount.
	; This means the movement gradually slows down over time as we get moved out further.
	
	push bc
		; A = Overlap amount
		ld   hl, iPlInfo_ColiBoxOverlapX
		add  hl, bc
		ld   a, [hl]
		; If there's no overlap, return
		cp   $00
		jr   z, .end
		
		; The overlap amount is an absolute (positive) number.
		; That would cause us to move right -- and if we are facing left (2P side), that's correct.
		; If we're facing right however (1P side) we want to be pushed left instead.
		;
		; So, if we're facing left invert the number.
		
		ld   hl, iOBJInfo_OBJLstFlags
		add  hl, de
		ld   b, [hl]		; B = iOBJInfo_OBJLstFlags
		ld   h, a			; HL = iPlInfo_ColiBoxOverlapX
		ld   l, $00
		bit  SPRXB_PLDIR_R, b	; Is the player internally facing right?
		jr   z, .move			; If not, skip
		; Otherwise, invert HL
		ld   a, h	; H = -H
		cpl
		ld   h, a
		ld   a, l	; L = -L
		cpl
		ld   l, a
		inc  hl		; Account for bitflip
	.move:
		sra  h		; HL = HL / 2
		rr   l
		call Play_OBJLstS_MoveH
	.end:
	pop  bc
	ret
	
; =============== Play_OBJLstS_Move* ===============
; Set of movement routines used by the move code.
; There are also a few wrappers to the horizontal movement one that invert
; the movement amount depending on a condition.
	
; =============== Play_OBJLstS_MoveH ===============
; Moves the sprite mapping horizontally by the specified amount.
; - DE: Ptr to wOBJInfo structure
; - HL: Movement amount (pixels + subpixels), can be negative
Play_OBJLstS_MoveH:
	push bc
		push de
			; BC = Movement amount
			push hl
			pop  bc
			
			; DE = Ptr to player X pos
			ld   hl, iOBJInfo_X
			add  hl, de
			push hl
			pop  de
			
			push de				; Save X pos ptr
			
				; H = iOBJInfo_X
				ld   a, [de]
				ld   h, a
				inc  de
				; L = iOBJInfo_XSub
				ld   a, [de]
				ld   l, a
				
				;
				; Determine if we're moving left or right, as there are different cap checks between sides.
				; 
				bit  7, b			; MSB of high byte set? (BC < 0?)
				jp   nz, .moveL		; If so, jump
			.moveR:
				; BC > 0
				; XPos = MIN(XPos + BC, $FF00)
				; The largest allowed value is at $FF pixels, $00 subpixels.
				add  hl, bc			; HL += BC
				jp   nc, .saveX		; Did it overflow? If not, jump
				ld   hl, $FF00		; Otherwise, cap to $FF00
				jp   .saveX
			.moveL:
				; BC < 0
				; XPos = MAX(XPos + BC, $0000)		
				
				ld   a, h		; Save original iOBJInfo_X for underflow check
				
				; Move the OBJ left by BC
				add  hl, bc		; HL +-= BC
				
				; The above instruction doesn't trigger the carry flag like we'd like since we're
				; using it to subtract words.
				; So we have to check for the underflow manually:
				; If the original iOBJInfo_X value is less than the X movement amount, then
				; we underflowed and should cap at $0000.
				
				push af			; Save orig iOBJInfo_X
					; Force the negative movement speed to positive
					ld   a, b	; XMove = -B
					cpl
					inc  a
					ld   b, a
				pop  af			; A = orig iOBJInfo_X
				sub  a, b		; iOBJInfo_X >= XMoveAbs?
				jp   nc, .saveX	; If so, skip (no underflow)
				ld   hl, $0000	; Otherwise, cap to $0000
				
			.saveX:
			
			; Save back the updated X position
			pop  de			; DE = Ptr to iOBJInfo_X
			ld   a, h		
			ld   [de], a	; Save pixel count
			inc  de			; Seek to iOBJInfo_XSub
			ld   a, l		
			ld   [de], a	; Save subpixel count
		pop  de
	pop  bc
	ret
	
; =============== Play_OBJLstS_MoveV ===============
; Moves the sprite mapping vertically by the specified amount.
; - DE: Ptr to wOBJInfo structure
; - HL: Movement amount (pixels + subpixels), can be negative
Play_OBJLstS_MoveV:
	; This is similar to Play_OBJLstS_MoveH, except it performs no underflow/overflow checks at all.
	
	push bc
		push de
			; BC = Movement amount
			push hl
			pop  bc
			
			; DE = Ptr to player Y pos
			ld   hl, iOBJInfo_Y
			add  hl, de
			push hl
			pop  de
			
			push de				; Save Y pos ptr
			
				; H = iOBJInfo_Y
				ld   a, [de]
				ld   h, a
				inc  de
				; L = iOBJInfo_YSub
				ld   a, [de]
				ld   l, a
				
				; YPos += YMove
				add  hl, bc
				
			; Save back the updated Y position
			pop  de				; DE = Ptr to iOBJInfo_Y
			
			ld   a, h
			ld   [de], a		; Save pixel count
			inc  de				; Seek to iOBJInfo_YSub
			ld   a, l
			ld   [de], a		; Save subpixel count
		pop  de
	pop  bc
	ret
	
; =============== Play_OBJLstS_MoveH_ByXFlipR ===============
; Moves the specified sprite mapping horizontally, relative to the current player *visually* facing right.
; If we're visually facing left, the movement amount is inverted.
; Most moves use this for horizontal movement.
; IN
; - DE: Ptr to wOBJInfo structure
; - HL: Movement amount (pixels + subpixels), can be negative
Play_OBJLstS_MoveH_ByXFlipR:
	push bc
		push de
			; BC = Movement amount
			push hl	
			pop  bc
			
			; Invert movement when facing left.
			; Unlike the sprite display which uses the left-facing sprites as base value (SPRB_XFLIP clear),
			; movement amounts use the right-facing sprites as base (SPRB_XFLIP set).
			; (ie: if a move makes us move right, we'll go right when facing right)
			; This is also the case for similar subroutines using related flags, like Play_OBJLstS_MoveH_ByXDirR.
			ld   hl, iOBJInfo_OBJLstFlags
			add  hl, de				; Seek to iOBJInfo_OBJLstFlags
			bit  SPRB_XFLIP, [hl]	; Is the XFlip flag set? (visually facing right)
			jp   nz, .moveH			; If so, jump
			
			; Otherwise, BC = -BC
			ld   a, b	; Invert high byte
			cpl
			ld   b, a
			ld   a, c	; Invert low byte
			cpl
			ld   c, a
			inc  bc		; Account for cpl
		.moveH:
		
			; HL = Updated movement amount
			push bc
			pop  hl
			
			; Perform the movement
			call Play_OBJLstS_MoveH
		pop  de
	pop  bc
	ret
	
; =============== Play_OBJLstS_MoveH_ByXDirR ===============
; Moves the specified sprite mapping horizontally, relative to the current player *internally* facing right.
; See also: Play_OBJLstS_MoveH_ByXFlipR
; IN
; - DE: Ptr to wOBJInfo structure
; - HL: Movement amount (pixels + subpixels), can be negative
Play_OBJLstS_MoveH_ByXDirR:
	push bc
		push de
			; BC = Movement amount
			push hl	
			pop  bc
			
			; Invert movement when internally facing left.
			ld   hl, iOBJInfo_OBJLstFlags
			add  hl, de					; Seek to iOBJInfo_OBJLstFlags
			bit  SPRXB_PLDIR_R, [hl]	; Is the R direction flag set? (internally facing right)
			jp   nz, .moveH				; If so, jump
			
			; Otherwise, BC = -BC
			ld   a, b	; Invert high byte
			cpl
			ld   b, a
			ld   a, c	; Invert low byte
			cpl
			ld   c, a
			inc  bc		; Account for cpl
		.moveH:
		
			; HL = Updated movement amount
			push bc
			pop  hl
			
			; Perform the movement
			call Play_OBJLstS_MoveH
		pop  de
	pop  bc
	ret
	
; =============== Play_OBJLstS_MoveH_ByOtherXFlipL ===============
; Moves the specified sprite mapping horizontally, relative to the *other* player *visually* facing left.
; See also: Play_OBJLstS_MoveH_ByXFlipR
; IN
; - BC: Ptr to wPlInfo structure
; - DE: Ptr to respective wOBJInfo structure
; - HL: Movement amount (pixels + subpixels), can be negative
Play_OBJLstS_MoveH_ByOtherXFlipL:
	push bc
		push de
			; DE = Movement amount
			push hl
			pop  de
			
			; Since the other player is on the other side, the flag check is inverted.
			
			; Invert the movement speed when the other player faces right.
			ld   hl, iPlInfo_OBJInfoFlagsOther
			add  hl, bc				; Seek to iOBJInfo_OBJLstFlags for the other user
			bit  SPRB_XFLIP, [hl]	; Is the XFlip flag cleared? (other player visually faces left)
			jp   z, .moveH			; If so, jump
			
			; Otherwise, DE = -DE
			ld   a, d
			cpl
			ld   d, a
			ld   a, e
			cpl
			ld   e, a
			inc  de
		.moveH:
			; HL = Updated movement amount
			push de
			pop  hl
		pop  de
		
		push de
			call Play_OBJLstS_MoveH
		pop  de
	pop  bc
	ret
	
; =============== Play_OBJLstS_MoveH_ByOtherProjOnR ===============
; Moves the specified sprite mapping horizontally, relative to an enemy projectile being on the right.
; See also: Play_OBJLstS_MoveH_ByXFlipR
; IN
; - BC: Ptr to wPlInfo structure
; - DE: Ptr to respective wOBJInfo structure
; - HL: Movement amount (pixels + subpixels), can be negative
Play_OBJLstS_MoveH_ByOtherProjOnR:
	push bc
		push de
			; BC = Movement amount
			push hl
			pop  bc
			
			; Invert the movement speed when the enemy projectile is on the left
			ld   hl, iOBJInfo_OBJLstFlags
			add  hl, de					; Seek to iOBJInfo_OBJLstFlags
			bit  SPRXB_OTHERPROJR, [hl]	; Is the flag set? (Is an enemy projectile on the right?)
			jp   nz, .moveH				; If so, jump
			
			; Otherwise, BC = -BC
			ld   a, b
			cpl
			ld   b, a
			ld   a, c
			cpl
			ld   c, a
			inc  bc
		.moveH:
			; HL = Updated movement amount
			push bc
			pop  hl
			
			call Play_OBJLstS_MoveH
		pop  de
	pop  bc
	ret
	
; =============== Play_OBJLstS_SetSpeed* ===============
; Counterparts of Play_OBJLstS_Move* that, instead of moving the player immediately once,
; they only write to the speed field in the OBJInfo, resulting in continuous speed across frames.
; These subroutines follow the same set of rules when it comes to inverting the movement speed.


; =============== Play_OBJLstS_SetSpeedH_ByXFlipR ===============
; Sets the horizontal movement speed for the specified sprite mapping, relative to the current player *visually* facing right.
; Most moves use this in their code.
; IN
; - DE: Ptr to wOBJInfo structure
; - HL: Movement speed (pixels + subpixels), can be negative
Play_OBJLstS_SetSpeedH_ByXFlipR:
	push bc
	
		; Handle movement amount exactly like in Play_OBJLstS_MoveH_ByXFlipR
	
		; BC = Speed
		push hl
		pop  bc
		
		; Invert the speed when visually facing left.
		ld   hl, iOBJInfo_OBJLstFlags
		add  hl, de				; Seek to iOBJInfo_OBJLstFlags
		bit  SPRB_XFLIP, [hl]	; Is the XFlip flag set? (visually facing right)
		jp   nz, .setSpd		; If so, jump
		
		; Otherwise, BC = -BC
		ld   a, b
		cpl
		ld   b, a
		ld   a, c
		cpl
		ld   c, a
		inc  bc
		
	.setSpd:
		; Save updated speed value
		ld   hl, iOBJInfo_SpeedX
		add  hl, de		; Seek to X speed
		ld   [hl], b	; Write iOBJInfo_SpeedX
		inc  hl			; Seek to X subpixel speed
		ld   [hl], c	; Write iOBJInfo_SpeedXSub
	pop  bc
	ret
	
; =============== Play_OBJLstS_SetSpeedH_ByXDirL ===============
; Sets the horizontal movement speed for the specified sprite mapping, relative to the current player *internally* facing *left*.
; There's no reason to have inconsistencies with the other SetSpeedH routines but oh well.
; See also: Play_OBJLstS_SetSpeedH_ByXFlipR
; IN
; - DE: Ptr to wOBJInfo structure
; - HL: Movement speed (pixels + subpixels), can be negative
Play_OBJLstS_SetSpeedH_ByXDirL:
	push bc
		; BC = Speed
		push hl
		pop  bc
		
		; Invert the speed when internally facing right
		ld   hl, iOBJInfo_OBJLstFlags
		add  hl, de					; Seek to iOBJInfo_OBJLstFlags
		bit  SPRXB_PLDIR_R, [hl]	; Is the R direction flag *clear*? (internally facing left)
		jp   z, .setSpd				; If so, jump
		
		; Otherwise, BC = -BC
		ld   a, b
		cpl
		ld   b, a
		ld   a, c
		cpl
		ld   c, a
		inc  bc
		
	.setSpd:
		; Save updated speed value
		ld   hl, iOBJInfo_SpeedX
		add  hl, de
		ld   [hl], b
		inc  hl
		ld   [hl], c
	pop  bc
	ret
	
; =============== Play_OBJLstS_SetSpeedH ===============
; Sets the horizontal movement speed as-is for the specified sprite mapping.
; IN
; - DE: Ptr to wOBJInfo structure
; - HL: Movement speed (pixels + subpixels), can be negative
Play_OBJLstS_SetSpeedH:
	push bc
		; BC = Speed
		push hl
		pop  bc
		; Seek to iOBJInfo_SpeedX
		ld   hl, iOBJInfo_SpeedX
		add  hl, de
		; Replace it
		ld   [hl], b
		inc  hl
		ld   [hl], c
	pop  bc
	ret
; =============== Play_OBJLstS_SetSpeedV ===============
; Sets the vertical movement speed as-is for the specified sprite mapping.
; IN
; - DE: Ptr to wOBJInfo structure
; - HL: Movement speed (pixels + subpixels), can be negative
Play_OBJLstS_SetSpeedV:
	push bc
		; BC = Speed
		push hl
		pop  bc
		; Seek to iOBJInfo_SpeedY
		ld   hl, iOBJInfo_SpeedY
		add  hl, de
		; Replace it
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

; =============== OBJLstS_ApplyFrictionHAndMoveH ===============
; Moves the sprite horizontally while under the effect of horizontal friction.
;
; Friction is just a fixed value that gets either added 
; or subtracted to the player's speed, depending on the direction he's moving.
;
; This causes the horizontal speed to gradually reach 0.
;
; It's very similar to the subroutines for applying vertical gravity, and it follows
; the same structure, but those are "uncapped" and only end when touching the ground.
;
; IN
; - HL: Friction value, always positive.
; - DE: Ptr to wOBJInfo
; OUT
; - C flag: If set, our horz. speed was 0 already.
;           As long as we get here with iOBJInfo_SpeedX > 0, this will be cleared.
OBJLstS_ApplyFrictionHAndMoveH:
	push bc
		push de
		
			; BC = Friction value
			push hl
			pop  bc
			
			;
			; If our speed is already 0, we don't need to do anything.
			;
			ld   hl, iOBJInfo_SpeedX
			add  hl, de
			ld   a, [hl]		; A = iOBJInfo_SpeedX
			or   a				; SpeedX == 0?
			jp   z, .moveEnd	; If so, return
			
			;
			; If our speed is positive (we're moving right), invert the friction
			; from positive to negative, otherwise we'd be increasing the speed.
			;
			bit  7, a			; SpeedX < 0? (MSB set)
			jp   nz, .saveSpeed	; If so, skip
			; Otherwise, BC = -BC
			ld   a, b			; Invert high byte
			cpl
			ld   b, a
			ld   a, c			; Invert low byte
			cpl
			ld   c, a
			inc  bc				; Account for bitflip
			
		.saveSpeed:
		
			;
			; Update the horizontal movement speed.
			;
			push hl	; Save ptr to iOBJInfo_SpeedX
				; DE = X Speed
				ld   d, [hl]	; D = iOBJInfo_SpeedX
				inc  hl
				ld   e, [hl]	; E = iOBJInfo_SpeedXSub
				
				; Add the friction over to reduce it
				; DE += Friction
				push de			; HL = DE
				pop  hl
				add  hl, bc		; HL += BC
				push hl			; DE = HL
				pop  de
			pop  hl	; Restore ptr to iOBJInfo_SpeedX
			
			; Write back the updated speed
			ld   [hl], d	; iOBJInfo_SpeedX = D
			inc  hl
			ld   [hl], e	; iOBJInfo_SpeedXSub = E
			jp   .moveOk
			
		.moveEnd:
		pop  de
	pop  bc
	
	; Force reset pixel and subpixel speed values
	ld   hl, iOBJInfo_SpeedX
	add  hl, de
	xor  a
	ldi  [hl], a	; iOBJInfo_SpeedX = 0
	ld   [hl], a	; iOBJInfo_SpeedXSub = 0
	scf				; C flag set
	ret
		.moveOk:
		pop  de
	pop  bc
	; Move horizontally with the recently updated speed value
	call OBJLstS_ApplyXSpeed
	or   a			; C flag clear
	ret
	
; =============== OBJLstS_ApplyGravityVAndMoveHV ===============
; Moves the sprite horizontally and vertically while under the effect of vertical gravity.
;
; Gravity is just a fixed value that gets added to the player's speed.
; This causes the speed to gradually increase, making it go from negative (moving up)
; to positive (moving down), and since the speed dictates how much the player moves,
; the player will move slower at the peak of the jump.
;
; IN
; - HL: Gravity value
; - DE: Ptr to wOBJInfo
; OUT
; - C flag: If set, we touched the ground.
OBJLstS_ApplyGravityVAndMoveHV:
	push bc
		; BC = Gravity value
		push hl
		pop  bc
		
		push de
		
			;
			; Update the vertical movement speed.
			;
		
			; DE = HL = Ptr to Y speed
			ld   hl, iOBJInfo_SpeedY
			add  hl, de
			push hl
			pop  de
			
			; HL = SpeedY + Gravity
			push de
				ld   a, [de]	; H = iOBJInfo_SpeedY
				ld   h, a
				inc  de
				ld   a, [de]	; L = iOBJInfo_SpeedYSub
				ld   l, a
				add  hl, bc		; += Gravity
			pop  de
			
			; Write back the updated speed
			push de
				ld   a, h		; iOBJInfo_SpeedY = H
				ld   [de], a
				inc  de
				ld   a, l		; iOBJInfo_SpeedYSub = L
				ld   [de], a
			pop  de
			
			;
			; Apply the newly updated speed to the player's Y position.
			;
			
			push hl	; Save Y Speed
				; DE = Ptr to Y Position
				dec  de		; iOBJInfo_SpeedXSub
				dec  de		; iOBJInfo_SpeedX
				dec  de		; iOBJInfo_YSub
				dec  de		; iOBJInfo_Y
				
				; Y += SpeedY
				push de
					ld   a, [de]	; B = iOBJInfo_Y
					ld   b, a
					inc  de
					ld   a, [de]	; C = iOBJInfo_YSub
					ld   c, a
					add  hl, bc		; += SpeedY
				pop  de
				
				; Write back the updated Y position
				ld   a, h		; iOBJInfo_Y = H
				ld   [de], a
				inc  de			; Seek to iOBJInfo_YSub
				ld   a, l		; iOBJInfo_YSub = L
				ld   [de], a
			pop  hl	; Restore Y Speed
			
			;
			; Validate the new Y position.
			; We always want to be above the ground, and not underflow it.
			;
			
			bit  7, h				; MSB set? (YSpeed < 0)
			jp   z, .chkMoveDown	; If not, jump
		.chkMoveUp:
			; 
			; When moving up, prevent underflowing the Y position.
			; If it did, snap it back to the topmost position.
			;
			; For some reason, this is done by comparing it with PL_FLOOR_POS, which works
			; because we're always above the ground until we underflow it.
			;
			dec  de				; Seek back to iOBJInfo_Y
			ld   a, [de]
			cp   PL_FLOOR_POS	; iOBJInfo_Y < $88?
			jp   c, .moveOk		; If so, jump (we're above the ground)
			; Otherwise, force it back to $0000
			xor  a
			ld   [de], a		; iOBJInfo_Y = 0
			inc  de
			ld   [de], a		; iOBJInfo_YSub = 0
			jp   .moveOk
		.chkMoveDown:
			;
			; When moving down, prevent moving below the floor.
			; If we are, snap back to it and signal that we've touched the ground.
			;
			dec  de
			ld   a, [de]
			cp   PL_FLOOR_POS	; iOBJInfo_Y < $88?
			jp   c, .moveOk		; If so, jump (we're above the ground)
			
		.jumpEnd:
		pop  de
	pop  bc
	; Otherwise, force the player to be on the ground
	ld   hl, iOBJInfo_Y
	add  hl, de
	ld   [hl], PL_FLOOR_POS	; iOBJInfo_Y = $88
	inc  hl
	xor  a			; iOBJInfo_YSub = 0
	ldi  [hl], a
	; And reset the Y speed
	inc  hl
	inc  hl
	ldi  [hl], a	; iOBJInfo_SpeedY = 0
	ldi  [hl], a	; iOBJInfo_SpeedYSub = 0
	scf			; C flag set
	ret
	
		.moveOk:
		pop  de
	pop  bc
	; Move horizontally as well
	call OBJLstS_ApplyXSpeed
	xor  a		; C flag clear
	ret
	
; =============== OBJLstS_ApplyGravityVAndMoveV ===============
; Moves the sprite vertically while under the effect of vertical gravity.
;
; Exactly like OBJLstS_ApplyGravityVAndMoveHV, but without moving horizontally.
; 
; IN
; - HL: Gravity value
; - DE: Ptr to wOBJInfo
; OUT
; - C flag: If set, we touched the ground.
OBJLstS_ApplyGravityVAndMoveV:
	push bc
		; BC = Gravity value
		push hl
		pop  bc
		
		push de
		
			;
			; Update the vertical movement speed.
			;
		
			; DE = HL = Ptr to Y speed
			ld   hl, iOBJInfo_SpeedY
			add  hl, de
			push hl
			pop  de
			
			; HL = SpeedY + Gravity
			push de
				ld   a, [de]	; H = iOBJInfo_SpeedY
				ld   h, a
				inc  de
				ld   a, [de]	; L = iOBJInfo_SpeedYSub
				ld   l, a
				add  hl, bc		; += Gravity
			pop  de
			
			; Write back the updated speed
			push de
				ld   a, h		; iOBJInfo_SpeedY = H
				ld   [de], a
				inc  de
				ld   a, l		; iOBJInfo_SpeedYSub = L
				ld   [de], a
			pop  de
			
			;
			; Apply the newly updated speed to the player's Y position.
			;
			
			push hl	; Save Y Speed
				; DE = Ptr to Y Position
				dec  de		; iOBJInfo_SpeedXSub
				dec  de		; iOBJInfo_SpeedX
				dec  de		; iOBJInfo_YSub
				dec  de		; iOBJInfo_Y
				
				; Y += SpeedY
				push de
					ld   a, [de]	; B = iOBJInfo_Y
					ld   b, a
					inc  de
					ld   a, [de]	; C = iOBJInfo_YSub
					ld   c, a
					add  hl, bc		; += SpeedY
				pop  de
				
				; Write back the updated Y position
				ld   a, h		; iOBJInfo_Y = H
				ld   [de], a
				inc  de			; Seek to iOBJInfo_YSub
				ld   a, l		; iOBJInfo_YSub = L
				ld   [de], a
			pop  hl	; Restore Y Speed
			
			;
			; Validate the new Y position.
			; We always want to be above the ground, and not underflow it.
			;
			
			bit  7, h				; MSB set? (YSpeed < 0)
			jp   z, .chkMoveDown	; If not, jump
		.chkMoveUp:
			; 
			; When moving up, prevent underflowing the Y position.
			; If it did, snap it back to the topmost position.
			;
			; For some reason, this is done by comparing it with PL_FLOOR_POS, which works
			; because we're always above the ground until we underflow it.
			;
			dec  de				; Seek back to iOBJInfo_Y
			ld   a, [de]
			cp   PL_FLOOR_POS	; iOBJInfo_Y < $88?
			jp   c, .moveOk		; If so, jump (we're above the ground)
			; Otherwise, force it back to $0000
			xor  a
			ld   [de], a		; iOBJInfo_Y = 0
			inc  de
			ld   [de], a		; iOBJInfo_YSub = 0
			jp   .moveOk
		.chkMoveDown:
			;
			; When moving down, prevent moving below the floor.
			; If we are, snap back to it and signal that we've touched the ground.
			;
			dec  de
			ld   a, [de]
			cp   PL_FLOOR_POS	; iOBJInfo_Y < $88?
			jp   c, .moveOk		; If so, jump (we're above the ground)
			
		.jumpEnd:
		pop  de
	pop  bc
	; Otherwise, force the player to be on the ground
	ld   hl, iOBJInfo_Y
	add  hl, de
	ld   [hl], PL_FLOOR_POS	; iOBJInfo_Y = $88
	inc  hl
	xor  a			; iOBJInfo_YSub = 0
	ldi  [hl], a
	; [POI] And reset the Y speed (if they didn't delete the lines to do so...)
	inc  hl
	inc  hl
	scf			; C flag set
	ret
	
		.moveOk:
		pop  de
	pop  bc
	xor  a		; C flag clear
	ret
; =============== MoveInputS_CanStartSpecialMove ===============
; Validates if it's possible to perform a new special move.
; This also returns if we're on the ground.
; IN
; - BC: Ptr to wPlInfo structure
; - DE: Ptr to respective wOBJInfo structure
; OUT
; - C flag: If set, validation failed
; - Z flag: If set, we're on the ground (only if validation passed)
MoveInputS_CanStartSpecialMove:
	
	;
	; If we got hit by Chizuru's super, we can only use normals.
	;
	ld   hl, iPlInfo_NoSpecialTimer
	add  hl, bc			; Seek to iPlInfo_NoSpecialTimer
	ld   a, [hl]
	or   a				; FlashSpeedTimer != 0?
	jp   nz, .retNoMove	; If so, return
	
	;
	; If a special move is being executed already (PF0_SPECMOVE set), don't allow executing a new one
	;
	ld   hl, iPlInfo_Flags0
	add  hl, bc				; Seek to iPlInfo_Flags0
	bit  PF0B_SPECMOVE, [hl]	; Is the bit set?
	jp   nz, .retNoMove		; If so, return
	
	
	ld   hl, iPlInfo_Flags1
	add  hl, bc				; Seek to iPlInfo_Flags1	
	
	;
	; If the player is about to get dizzy or is in a damage string, no special moves can be input...
	; ...except when blocking, as it's possible to cancel blockstun.
	; Note that all of the guard cancel validation already happened
	; by the time we get here.
	;
	bit  PF1B_GUARD, [hl]		; Is the player blocking? (checked here since PF1B_HITRECV also applies when blocking)
	jp   nz, .chkMoveId			; If so, jump
	bit  PF1B_HITRECV, [hl]		; Are we in a damage string?
	jp   nz, .retNoMove			; If so, return
	call Play_Pl_IsDizzyNext	; Is the player about to get dizzy?
	jp   nz, .retNoMove			; If so, return
	
.chkMoveId:
	
	;
	; Can't cancel throws into specials.
	;
	ld   hl, iPlInfo_MoveId
	add  hl, bc
	ld   a, [hl]
	cp   MOVE_SHARED_THROW_G
	jp   z, .retNoMove
	cp   MOVE_SHARED_THROW_A
	jp   z, .retNoMove
	
	;
	; Can't cancel if we've been explicitly denied that.
	;
	ld   hl, iPlInfo_Flags1
	add  hl, bc						; Seek to iPlInfo_Flags1
	bit  PF1B_ALLOWHITCANCEL, [hl]		; Can we combo off the previous hit?
	jp   nz, .moveOk				; If so, jump (skip check)
	bit  PF1B_NOSPECSTART, [hl]	; Are we allowed to cancel the move into the special?
	jp   nz, .retNoMove				; If not, return
	
.moveOk:

	;
	; If we got here, the validation passed.
	; Determine if we're in the air or not, which is used by the code
	; calling this.
	;
	xor  a					; Reset flag
	ld   hl, iOBJInfo_Y
	add  hl, de				
	ld   a, [hl]			; A = Y pos
	cp   PL_FLOOR_POS		; Are we at ground level? (A == $88)
	jp   z, .retOkGround	; If so, jump
.retOkAir:
	ld   a, $01	; A = 1 (on air)
	jp   .retOk
.retOkGround:
	xor  a		; A = 0 (on ground)
.retOk:
	or   a		; Update Z flag
	scf
	ccf			; Clear carry
	ret
.retNoMove:
	scf			; Set carry
	ret
	
; =============== MoveInputS_CanStartSuperMove ===============
; Validates if it's possible to perform a new super move.
; This doesn't distinguish between super or desperation supers.
; IN
; - BC: Ptr to wPlInfo structure
; - DE: Ptr to respective wOBJInfo structure
; OUT
; - C flag: If set, we can't start a super
MoveInputS_CanStartSuperMove:
	
	; With the meter autocharge cheat, you have infinite supers
	ld   a, [wDipSwitch]
	bit  DIPB_AUTO_CHARGE, a	; Is the flag set?
	jp   nz, .retOk				; If so, return clear
	
	; If the POW bar is at the maximum value, we can start a super
	ld   hl, iPlInfo_Pow
	add  hl, bc
	ld   a, [hl]		
	cp   PLAY_POW_MAX			; iPlInfo_Pow == $28?
	jp   z, .retOk				; If so, jump
	
	; When health reaches critical level (< $18), we can always start a super
	ld   hl, iPlInfo_Health
	add  hl, bc
	ld   a, [hl]
	cp   PLAY_HEALTH_CRITICAL	; iPlInfo_Health >= $18?
	jp   nc, .retNg				; If so, we can't start a super
.retOk:							; Otherwise, we can
	xor  a	; Clear carry
	ret
.retNg:
	scf		; Set carry
	ret
	
; =============== Play_Pl_IsMoveHit ===============
; Determines if we successfully hit the opponent in the damage string already.
; Used for moves that perform certain failsafe actions when the attack whiffs or gets blocked.
; Some do this check manually without calling this, or have slightly different logic.
; IN
; - BC: Ptr to wPlInfo structure
; OUT
; - C flag: If set, the attack didn't hit the opponent yet
; - Z flag: If set, the opponent didn't block it (only valid if C is also set)
Play_Pl_IsMoveHit:
	;
	; Verify that we did a combo move that didn't whiff first.
	;
	ld   hl, iPlInfo_ColiFlags
	add  hl, bc
	bit  PCF_HITOTHER, [hl]			; Did we collide with the opponent yet?
	jp   z, .retClear				; If not, skip
	ld   hl, iPlInfo_Flags1Other
	add  hl, bc
	bit  PF1B_INVULN, [hl]			; Is the opponent invulnerable?
	jp   nz, .retClear				; If so, skip
	bit  PF1B_HITRECV, [hl]			; Did we hit the opponent in the damage string so far?
	jp   z, .retClear				; If not, skip
	
.retSet:
	; C flag confirmed.
	bit  PF1B_GUARD, [hl]			; Is the opponent blocking? (if not, Z flag set)
	scf		; C flag set
	ret
.retClear:
	scf
	ccf		; C flag clear
	ret
	
; =============== MoveInputS_CanStartProjMove ===============
; Determines if it's possible to start a special move that throws a projectile.
; IN
; - BC: Ptr to wPlInfo structure
; OUT
; - Z flag: If set, we can start the move
MoveInputS_CanStartProjMove:
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	bit  PF0B_PROJ, [hl]	; Is the projectile for this player still active?
	ret						; (if so, don't start the move)
	
; =============== MoveInputS_CheckMoveLHVer ===============
; Determines if the heavy version of the move should be started.
;
; This is used after successfully performing an input for a move and before
; setting the Move ID, as the Light and Heavy versions of the same move
; use separate Move IDs.
;
; IN
; - BC: Ptr to wPlInfo structure
; OUT
; - C flag: If set, the "hidden heavy" version can be used.
;           This is an heavy attack done at Max Power *WHEN* the meter autocharge cheat is enabled.
; - Z flag: If set, the attack is heavy
MoveInputS_CheckMoveLHVer:

	;
	; Perform the two initial checks for the cheated heavy attack
	;
	ld   a, [wDipSwitch]
	bit  DIPB_AUTO_CHARGE, a	; Is the cheat set?
	jp   z, .chkNorm			; If not, jump
	
	ld   hl, iPlInfo_Pow
	add  hl, bc
	ld   a, [hl]
	cp   PLAY_POW_MAX			; At max power?
	jp   z, .chkHidden			; If so, jump
	
.chkNorm:
	;
	; Perform the heavy flag check, as previously set by MoveInputS_CheckGAType.
	; The updated result in the Z flag will be our return value.
	;
	ld   hl, iPlInfo_Flags2
	add  hl, bc					; Seek to flags
	bit  PF2B_HEAVY, [hl]		; Update Z flag
	scf
	ccf							; Clear carry
	ret
.chkHidden:
	
	;
	; Don't allow "hidden light" attacks (even though they exist...),
	; so fall back to the normal check if we're not doing an heavy.
	;
	ld   hl, iPlInfo_Flags2
	add  hl, bc
	bit  PF2B_HEAVY, [hl]	; Heavy bit set?
	jp   z, .chkNorm		; If not, jump
	scf						; Set carry
	ret
	
; =============== MoveInputS_CheckSuperDesperation ===============
; Determines if the desperation version of the super move should be used.
;
; This is used after successfully performing an input for a super move,
; and is the super move equivalent to the light/heavy check on MoveInputS_CheckMoveLHVer.
;
; IN
; - BC: Ptr to wPlInfo structure
; OUT
; - C flag: If set, the desperation super is active
; - Z flag: If set, the hidden desperation super is active, if present (only applicable if C is also set)
MoveInputS_CheckSuperDesperation:

	;
	; Dsperation supers are triggered by pulling off a super at max meter with low health.
	;
	; When the meter autocharge cheat is enabled, only max meter is required.
	; [POI] If the low health requirement is still met, an hidden desperation is triggered,
	;       though only one super move (L064D82) actually checks for it.
	;       There is no way to trigger it without the cheat.
	;

	;
	; The rules are slightly different if the meter autocharge cheat is enabled.
	;
	ld   a, [wDipSwitch]
	bit  DIPB_AUTO_CHARGE, a	; Is the cheat set?
	jp   z, .chkNormal			; If not, jump
	
.chkCheat:
	; Desperation supers require max meter as usual.
	; This is the only requirement with the cheat enabled.
	ld   hl, iPlInfo_Pow
	add  hl, bc
	ld   a, [hl]
	cp   PLAY_POW_MAX			; Pow != MAX?
	jp   nz, .retNorm			; If so, use normal super

	; If we got here, there's a guaranteed desperation super.
	; Getting into critical health anyway enables an hidden desperation super.
	ld   hl, iPlInfo_Health
	add  hl, bc
	ld   a, [hl]
	cp   PLAY_HEALTH_CRITICAL	; Health >= CRITICAL?
	jp   nc, .retDesp			; If so, use desperation
	
	jp   .retDespHidden			; Otherwise, use hidden desperation
	
.chkNormal:
	
	; Desperation supers require max meter.
	ld   hl, iPlInfo_Pow
	add  hl, bc
	ld   a, [hl]
	cp   PLAY_POW_MAX			; Pow != MAX?
	jp   nz, .retNorm			; If so, use normal super
	
	; Desperation supers require critical health.
	ld   hl, iPlInfo_Health
	add  hl, bc
	ld   a, [hl]
	cp   PLAY_HEALTH_CRITICAL	; Health >= CRITICAL?
	jp   nc, .retNorm			; If so, use normal super
	
	; Requirements ok
	jp   .retDesp
	
.retNorm:
	xor  a		; Z flag set, (C flag unusable)
	ret
.retDesp:
	ld   a, $01
	or   a		; Z flag clear
	scf			; C flag set
	ret
.retDespHidden:
	xor  a		; Z flag set
	scf			; C flag set
	ret
; =============== MoveInputS_SetSpecMove_StopSpeed ===============
; Makes the specified player start a new special or super move.
; Most special moves use this subroutine to start them, and as a result
; of using Pl_SetMove_StopSpeed, they cancel the player's momentum. 
; IN
; - A: Move ID
; - BC: Ptr to wPlInfo structure
; - DE: Ptr to respective wOBJInfo structure
MoveInputS_SetSpecMove_StopSpeed:
	; Force syncronize the player's direction before starting the move
	call OBJLstS_SyncXFlip
	
	; HL = Ptr to status flag
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	
	;
	; If we're starting a super move, set its respective flag and
	; display the super sparkle.
	;
	; This will affect moves $64-$6A.
	;
	; Note that moves higher than $6A do not get set through this subroutine,
	; so it's safe to check < $64.
	cp   MOVE_SUPER_START		; MoveId < $64?
	jp   c, .setFlags			; If so, skip
	set  PF0B_SUPERMOVE, [hl]
	push af
		push hl
			ld   hl, $0000
			call Play_StartSuperSparkle
		pop  hl
	pop  af
	
.setFlags:
	;
	; Set all of the default flags for starting a move.
	;
	
	; iPlInfo_Flags0
	; Mark that a special move is in progress.
	set  PF0B_SPECMOVE, [hl]
	
	inc  hl			; Seek to iPlInfo_Flags1
	set  PF1B_NOBASICINPUT, [hl] 	; Special moves can't be cancelled by normal movement
	set  PF1B_XFLIPLOCK, [hl] 		; Lock the player's direction until the move is over
	set  PF1B_NOSPECSTART, [hl] 	; For consistency (PF0B_SPECMOVE takes care of this already)
	res  PF1B_GUARD, [hl]			; Receive full damage by default if hit out of the special
	res  PF1B_CROUCH, [hl]			; Remove crouch flag in case we performed the move while crouching
	res  PF1B_INVULN, [hl] 			; Disable invulnerability in case we got here from guard cancels
	
	;
	; Remove any temporary invuln. effect on player
	;
	inc  hl			; Seek to iPlInfo_Flags2
	res  PF2B_NOHURTBOX, [hl]
	res  PF2B_NOCOLIBOX, [hl]
	
	;
	; Actually start the move, stopping the player momentum
	;
	push hl
		call Pl_SetMove_StopSpeed
	pop  hl
	
	;
	; When starting a new special off another hit, flag that we're doing a combo
	; and animate it much faster by removing the delay.
	;
	; This means the move animation will only wait for the player graphics to load
	; before switching to the next frame.
	;
	dec  hl							; Seek to iPlInfo_Flags1
	bit  PF1B_ALLOWHITCANCEL, [hl]	; Did we combo the move off a previous hit?
	jp   z, .ret					; If not, return
	; Set that we started a combo'd move
	inc  hl						
	set  PF2B_HITCOMBO, [hl]
	; Note that Pl_SetMove_StopSpeed set us a new FrameLeft/FrameTotal value.
	; In case of moves that expect manual control by having set ANIMSPEED_NONE ($FF) initially, don't remove the delay.
	ld   hl, iOBJInfo_FrameLeft
	add  hl, de		; Seek to iOBJInfo_FrameLeft
	ld   a, [hl]
	bit  7, a		; iOBJInfo_FrameLeft > $7F? (MSB set)
	jp   nz, .ret	; If so, return
	ld   [hl], $00	; Otherwise, reset it
	inc  hl			
	ld   [hl], $00	; and reset iOBJInfo_FrameTotal
.ret:
	ret
	
; =============== Play_StartSuperSparkle ===============
; Starts the super sparkle animation over the specified sprite mapping.
; Meant for special or super moves only.
; IN
; - A: Move ID
; - DE: Ptr to wOBJInfo structure
; - H: X Offset
; - L: Y Offset
Play_StartSuperSparkle:
	; Play SFX associated with the sparkle effect
	ld   a, SFX_SUPERMOVE
	call HomeCall_Sound_ReqPlayExId
	
	push bc
		push de
			push hl
	
				; BC = Ptr to wOBJInfo_Pl*
				push de	
				pop  bc
				
				;--
				;
				; DE = Ptr to the sparkle wOBJInfo.
				;
				; Because they are organized in a specific order, this is always $100 bytes (4 OBJInfo) after the
				; wOBJInfo for the current player.
				; This results in:
				; wOBJInfo_Pl1 + $100 = wOBJInfo_Pl1SuperSparkle
				; wOBJInfo_Pl2 + $100 = wOBJInfo_Pl2SuperSparkle
				;
				ld   hl, OBJINFO_SIZE*4 ; HL = BC + $100
				add  hl, bc
				
				push hl	; DE = HL
				pop  de
				;--
				;
				; Set up all fields.
				;
				
				; Display the sparkle
				ld   [hl], OST_VISIBLE
				
				; Set the code pointer
				ld   hl, iOBJInfo_Play_CodeBank
				add  hl, de
				ld   [hl], BANK(ExOBJ_SuperSparkle) ; BANK $02
				inc  hl			
				ld   [hl], LOW(ExOBJ_SuperSparkle)	
				inc  hl			
				ld   [hl], HIGH(ExOBJ_SuperSparkle)
				
				; Set sprite mapping
				ld   hl, iOBJInfo_BankNum
				add  hl, de
				ld   [hl], BANK(OBJLstPtrTable_SuperSparkle)	; BANK $01
				inc  hl
				ld   [hl], LOW(OBJLstPtrTable_SuperSparkle)
				inc  hl
				ld   [hl], HIGH(OBJLstPtrTable_SuperSparkle)

				; Start anim from the beginning
				inc  hl			
				ld   [hl], $00	; iOBJInfo_OBJLstPtrTblOffset = 0
				
				; ??? Display each animation frame for a single frame each
				ld   hl, iOBJInfo_FrameLeft
				add  hl, de
				ld   [hl], $00
				inc  hl
				ld   [hl], $00
				
				; Display for $14 frames
				ld   hl, iOBJInfo_Play_EnaTimer
				add  hl, de
				ld   [hl], $14
				
				; Display sparkle over the player.
				; This will stay this original position, even if the player moves after.
				
				; BC = Source (wOBJInfo_Pl*)
				; DE = Destination (wOBJInfo_Pl*SuperSparkle)
				call OBJLstS_Overlap
			pop  hl
			
			;--
			; [POI] Offset the vertical and horizontal positions of the sprite mapping.
			;       This is normally 0 by default, but there are manual calls to this
			;       with HL != 0.
			
			; XPos += H
			push hl
				ld   l, $00 ; 0 subpixels, H pixels
				call Play_OBJLstS_MoveH_ByXFlipR
			pop  hl
			
			; YPos += L
			ld   h, l	; L pixels
			ld   l, $00 ; 0 subpixels
			call Play_OBJLstS_MoveV
			;--
		pop  de
	pop  bc
	ret
; =============== Play_StartThrowEffect ===============
; Sets the visual/audio effects triggered when throwing someone.
Play_StartThrowEffect:
	; Flash the playfield's palette
	ld   a, $FF
	ld   [wStageBGP], a
	; Play SFX
	ld   a, SCT_THROW
	call HomeCall_Sound_ReqPlayExId
	ret
	
; =============== Play_Pl_MoveRotThrown ===============
; Moves the position of the thrown opponent during its rotation frames, relative to the *other* player *visually* facing left (2P side).
; This is expected to be applied only once, and generally requires a call to Play_Pl_SetMoveDamage
; setting a rotation frame to work properly (those are only valid for 1 frame, so "repeated" calls with the same rot may be needed)
; IN
; - H: Horizontal movement
; - L: Vertical position
Play_Pl_MoveRotThrown:
	ld   a, h
	ld   [wPlayPlThrowRotMoveH], a
	ld   a, l
	ld   [wPlayPlThrowRotMoveV], a
	; By default, perform the movment only once.
	; However, once isn't enough if the player moves in the middle of the throw,
	; as the opponent needs to be sync'd to the updated position.
	; Moves that need so manually set this value (mMvC_MoveThrowSync)
	xor  a
	ld   [wPlayPlThrowRotSync], a
	ret
	
; =============== Play_Pl_SetMoveDamage ===============
; Instantly changes the damage values, without waiting for the next frame to display.
; This is meant to be used to update the damage mid-animation, not when the move starts
; as that's handled by Pl_SetNewMove.
; IN
; - H: Damage amount
; - L: Hit animation ID (HITANIM_*)
; - A: Damage flags
; - BC: Ptr to wPlInfo
Play_Pl_SetMoveDamage:
	push de
		; DE = HL
		push hl
		pop  de
		; BC = Ptr to start of current move damage info
		ld   hl, iPlInfo_MoveDamageVal
		add  hl, bc
		; Copy the data over
		ld   [hl], d	; iPlInfo_MoveDamageVal = D
		inc  hl
		ld   [hl], e	; iPlInfo_MoveDamageHitAnimId = E
		inc  hl
		ld   [hl], a	; iPlInfo_MoveDamageFlags3 = A
	pop  de
	ret
	
; =============== Play_Pl_SetMoveDamageNext ===============
; Updates the pending damage values, which get applied when the next frame is displayed.
; This works in conjunction with the VBlank Handler, since that's what copies the
; iPlInfo_MoveDamage*Next fields to iPlInfo_MoveDamage*.
;
; Because iPlInfo_MoveDamageValNext gets cleared when it gets applied, and the VBlank Handler
; detects if there's any pending value by checking iPlInfo_MoveDamageValNext != 0, the
; amount of damage specified *MUST* be > 0.
; To erase the damage, either call Play_Pl_SetMoveDamage manually or wait for
; a new move to be set, since Pl_SetNewMove zeroes out all damage-related fields
; in preparation of the move code setting new ones through Play_Pl_IsMoveLoading.
;
; This is meant to be used to update the damage mid-animation, not when the move starts
; as that's handled by Pl_SetNewMove.
;
; This is one of the two subroutines used to update the damage mid-animation,
; and by using this one VBlankHandler will apply the changes.
; IN
; - H: Damage amount
; - L: Hit animation ID (HITANIM_*)
; - A: Damage flags
; - BC: Ptr to wPlInfo
Play_Pl_SetMoveDamageNext:
	push de
		; DE = HL
		push hl
		pop  de
		; BC = Ptr to start of pending move damage info
		ld   hl, iPlInfo_MoveDamageValNext
		add  hl, bc
		; Copy the data over
		ld   [hl], d	; iPlInfo_MoveDamageValNext = D
		inc  hl
		ld   [hl], e	; iPlInfo_MoveDamageHitAnimIdNext = E
		inc  hl
		ld   [hl], a	; iPlInfo_MoveDamageFlags3Next = A
	pop  de
	ret
	
; =============== Play_Proj_CopyMoveDamageFromPl ===============
; Copies the pending move damage fields from the current player over to its respective projectile.
; Typically called after mMvC_SetDamageNext.
;
; This is called for moves where the projectile is what deals damage --
; which includes actual projectiles and special effects that are animated independently from the player (see: Power Geyser).
;
; This is needed because the game only copies the damage info from MoveAnimTbl_* to
; the player when starting a new move, even when it's meant for projectiles.
; Moves that call this use animation frames/sprite mappings for the player that don't
; have an hitbox set, preventing the same damage from being also dealt physically.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
Play_Proj_CopyMoveDamageFromPl:
	push bc
		; Copy over the three bytes.
		; This works because the move damage fields are stored contiguously
		; in the same order between player and projectile info.
		
		; BC = Ptr to source
		ld   hl, iPlInfo_MoveDamageValNext
		add  hl, bc
		push hl
		pop  bc
		
		; DE = Ptr to destination
		; The OBJInfo for the projectile is always 2 slots ahead
		; of one used by its respective player.
		ld   hl, (OBJINFO_SIZE*2)+iOBJInfo_Play_DamageVal
		add  hl, de
		
		; Copy the data over
		ld   a, [bc]	; Read iPlInfo_MoveDamageValNext
		inc  bc
		ldi  [hl], a	; Copy to iOBJInfo_Play_DamageVal
		ld   a, [bc]	; Read iPlInfo_MoveDamageHitAnimIdNext
		inc  bc
		ldi  [hl], a	; Copy to iOBJInfo_Play_DamageHitAnimId
		ld   a, [bc]	; Read iPlInfo_MoveDamageFlags3Next
		ld   [hl], a	; Copy to iOBJInfo_Play_DamageFlags3
	pop  bc
	ret
	
; =============== Play_Pl_IsMoveLoading ===============
; Checks if the move is "ready", which is when move-specific code is allowed to run (as checked manually in many MoveC_*).
;
; This also has the secondary purpose of updating the move damage field as soon as the move
; is detected to be ready. It will only happen once, the first frame the move is ready.
;
; See also: VBlankHandler, which does the same thing only if a move *wasn't* started this frame.
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
; OUT
; - C flag: If set, move isn't ready yet.
Play_Pl_IsMoveLoading:

	;--
	;
	; Verify that the visible and pending sprite mapping table pointers are identical.
	; If they aren't, the move isn't ready, since it means the move animation 
	; was recently changed (ie: new move) but the graphics for them haven't been 
	; fully loaded yet.
	;
	; This is the equivalent of checking (PF2B_MOVESTART && !OSTB_GFXLOAD),
	; so why wasn't it done that way?
	;
	push de
		push bc
			ld   hl, iOBJInfo_BankNum
			add  hl, de
			ld   b, [hl]		; B = iOBJInfo_BankNum
			inc  hl
			ld   c, [hl]		; C = iOBJInfo_OBJLstPtrTbl_Low
			inc  hl
			ld   d, [hl]		; D = iOBJInfo_OBJLstPtrTbl_High
			inc  hl				; Seek to iOBJInfo_OBJLstPtrTblOffset
			inc  hl				; Seek to iOBJInfo_BankNumView
			ldi  a, [hl]	
			cp   a, b			; iOBJInfo_BankNumView == iOBJInfo_BankNum?
			jr   nz, .retNotReadyPop	; If not, return
			ldi  a, [hl]
			cp   a, c			; iOBJInfo_OBJLstPtrTbl_LowView == iOBJInfo_OBJLstPtrTbl_Low?
			jr   nz, .retNotReadyPop	; If not, return
			ldi  a, [hl]
			cp   a, d			; iOBJInfo_OBJLstPtrTbl_HighView == iOBJInfo_OBJLstPtrTbl_High?
			jr   nz, .retNotReadyPop	; If not, return
		pop  bc
	pop  de
	;--
	
	; If we didn't start a new move and the above check passed, then it means we're ready
	; but we shouldn't update the move damage info since we've already done it.
	ld   hl, iPlInfo_Flags2
	add  hl, bc
	bit  PF2B_MOVESTART, [hl]
	jr   z, .retReady
	
	; If the graphics are loading and all previous validations passed, it means the first
	; frame is still loading, therefore the move isn't ready yet.
	ld   hl, iOBJInfo_Status
	add  hl, de
	bit  OSTB_GFXLOAD, [hl]
	jp   nz, .retNotReady
	
	;--
	
	; If we got here, the first frame has just loaded, so we can update the move damage fields
	; as long as they've been set.
	;
	; The previous validation is all there because the move damage fields come from the MoveAnimTbl table,
	; meaning they are associated with a specific move animation.
	; As the animation won't start until the graphics for the first frame are loaded,
	; (it will wait on the last visible frame), wait for that first before copying the
	; fields over from their pending slots.
	; This avoids having the old frame visible with the new damage settings applied.
	
	;--
	
	; Unmark that we're starting a new move.
	; This allows the VBlank Handler to perform mid-move damage changes between frames,
	; and cuts off getting here another time until another move is started.
	ld   hl, iPlInfo_Flags2
	add  hl, bc
	res  PF2B_MOVESTART, [hl]
	
	;
	; Copy the set of pending fields to the current ones, and clear the former range.
	;
	; This avoids updating the move damage when set to 0, as there's no point to update
	; the fields when damage was already initialized to 0 when we went though Pl_SetNewMove.
	;
	
	; HL = Source
	ld   hl, iPlInfo_MoveDamageValNext
	add  hl, bc			
	ld   a, [hl]		; A = iPlInfo_MoveDamageValNext
	or   a				; iPlInfo_MoveDamageValNext == 0?
	jp   z, .retReady	; If so, skip
	
	;
	; Copy over the pending move damage info to the current one.
	;
	push de
		; DE = Destination
		push hl
			ld   hl, iPlInfo_MoveDamageVal
			add  hl, bc
			push hl
			pop  de
		pop  hl
		
		ld   [de], a	; Copy iPlInfo_MoveDamageValNext to iPlInfo_MoveDamageVal	
		ld   [hl], $00	; Clear iPlInfo_MoveDamageValNext
		inc  de			; SrcPtr++
		inc  hl			; DestPtr++
		
		ld   a, [hl]	; A = iPlInfo_MoveDamageHitAnimIdNext
		ld   [de], a	; Copy iPlInfo_MoveDamageHitAnimIdNext to iPlInfo_MoveDamageHitAnimId	
		ld   [hl], $00	; Clear iPlInfo_MoveDamageHitAnimIdNext
		inc  de			; SrcPtr++
		inc  hl			; DestPtr++
		
		ld   a, [hl]	; A = iPlInfo_MoveDamageFlags3Next
		ld   [de], a	; Copy iPlInfo_MoveDamageFlags3Next to iPlInfo_MoveDamageFlags3	
		ld   [hl], $00	; Clear iPlInfo_MoveDamageFlags3Next
	pop  de
.retReady:
	or   a	; C flag clear
	ret
		.retNotReadyPop:
		pop  bc
	pop  de
.retNotReady:
	scf		; C flag set
	ret
	
; =============== Play_Pl_ChkThrowInput ===============
; Handles the input for throwing the opponent.
; IN
; - BC: Ptr to wPlInfo structure
; - DE: Ptr to respective wOBJInfo structure
; OUT
; - A: wPlayPlThrowOpMode value, if a throw was started
; - C flag: If set, a throw was started
Play_Pl_ChkThrowInput:

	;--
	;
	; Validate if we can start the throw to begin with
	;
	
	; Not applicable if we're getting thrown
	ld   a, [wPlayPlThrowActId]
	cp   PLAY_THROWACT_NONE		; ThrowActId == 0?
	jp   nz, .retClear			; If not, return
	
	; Not applicable when the opponent is waking up
	ld   hl, iPlInfo_NoThrowTimerOther
	add  hl, bc
	ld   a, [hl]
	or   a						; iPlInfo_NoThrowTimerOther > 0?
	jp   nz, .retClear			; If so, return
	
	;
	; Check for the throw input.
	; HP/HK + L/R
	;
	call Play_Pl_AreBothBtnHeld	; Holding A *and* B?
	jp   c, .retClear			; If so, return
	call Play_Pl_GetDirKeys_ByXFlipR	; Holding any directional key?
	jp   nc, .retClear			; If not, return
	
	push de
		ld   d, KEP_A_HEAVY|KEP_B_HEAVY	; D = Filter for LH
		ld   hl, iPlInfo_JoyKeys
		add  hl, bc
		
		; Must be holding Left or Right
		; E = iPlInfo_JoyKeys & (KEY_RIGHT|KEY_LEFT)
		ld   a, [hl]		
		and  a, KEY_RIGHT|KEY_LEFT ; Filter L/R keys
		jp   z, .noPk		; Any of them held? If not, return
		ld   e, a			; E = A
		
		; Must be an heavy attack
		; A = iPlInfo_JoyNewKeysLH & (KEP_A_HEAVY|KEP_B_HEAVY)
		inc  hl				; Seek to iPlInfo_JoyNewKeysLH
		ld   a, [hl]		
		and  a, d			; Filter out non-heavy flags
		jp   z, .noPk		; Any heavy done? If not, return
	pop  de
	;--
	
	; Success.
	; We started the throw successfully, now determine its type.
	
	; Determine the throw's direction.
	; Pressing B/Punch throws the opponent forwards.
	; Pressing A/Kick, makes the players switch sides before throwing forwards (backwards throw in practice).
	bit  KEPB_A_HEAVY, a	; Pressed A?
	jp   nz, .setThrowBack	; If so, jump	
.setThrowFwd:	
	xor  a ; PLAY_THROWDIR_F
	ld   [wPlayPlThrowDir], a
	jp   .chkAir
.setThrowBack:
	ld   a, PLAY_THROWDIR_B
	ld   [wPlayPlThrowDir], a
.chkAir:

	; Determine if we're in the air or not
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	bit  PF0B_AIR, [hl]	; Are we in the air?
	jp   nz, .air	; If so, jump
	jp   .ground
	
	.noPk:
	pop  de
	jp   .retClear
	
.ground:

	; When crouching or performing moves not allowing basic movement, throwing will be ignored.
	inc  hl							; Seek to iPlInfo_Flags1
	bit  PF1B_NOBASICINPUT, [hl]	; Is basic input denied?
	jp   nz, .noThrow				; If so, return
	bit  PF1B_CROUCH, [hl] 		; Crouching?
	jp   nz, .noThrow				; If so, return
	
.groundOk:
	
	; Set ground throw type
	xor  a ; PLAY_THROWOP_GROUND
	ld   [wPlayPlThrowOpMode], a
	; Set temporary hitbox $04, overriding whatever hitbox is set by the visible frame.
	ld   a, $04
	jp   .tryStart
	
.air:
	; Only when performing a jump move
	ld   hl, iPlInfo_MoveId
	add  hl, bc			; Seek to iPlInfo_MoveId
	ld   a, [hl]
	cp   MOVE_SHARED_JUMP_N
	jp   z, .airChkChar
	cp   MOVE_SHARED_JUMP_F
	jp   z, .airChkChar
	cp   MOVE_SHARED_JUMP_B
	jp   z, .airChkChar
	jp   .noThrow
.airChkChar:
	; Only Athena, Mai and Leona can do air throws
	ld   hl, iPlInfo_CharId
	add  hl, bc
	ld   a, [hl]
	cp   CHAR_ID_ATHENA		; Playing as ATHENA?
	jp   z, .airOk			; If so, jump
	cp   CHAR_ID_MAI		; ...
	jp   z, .airOk
	cp   CHAR_ID_LEONA
	jp   z, .airOk
	cp   CHAR_ID_OLEONA
	jp   z, .airOk
	jp   .noThrow			; Otherwise, return
.airOk:
	; Set air throw type
	ld   a, PLAY_THROWOP_AIR
	ld   [wPlayPlThrowOpMode], a
	; Set temporary hitbox $04, same as ground throws.
	; [POI] Was this once different?
	ld   a, $04
	;--
	
.tryStart:

	;
	; Setup the throw, and see the opponent's response.
	;

	; Write the temporary hitbox, used to determine throw range.
	; This will be active for exactly one frame (see below).
	ld   hl, iOBJInfo_ForceHitboxId
	add  hl, de
	ld   [hl], a
	
	; Start the throw sequence, mandatory to let the other player know we're ready.
	ld   a, PLAY_THROWACT_START
	ld   [wPlayPlThrowActId], a
	
	; All throws do $0C lines of damage.
	; The damage is dealt when the opponent gets thrown at the *end*.
	; Meaning that if it gets aborted early, no damage is dealt.
	; Note that, in the MoveAnimTbl_* entries, the damage fields are all $00 anyway.
	ld   hl, iPlInfo_MoveDamageVal
	add  hl, bc
	ld   a, $0C						; 12 lines of damage
	ld   [hl], a
	
	; If the grab occurres, the opponent will use hit animation HITANIM_THROW_START
	inc  hl							; Seek to iPlInfo_MoveDamageHitAnimId
	ld   a, HITANIM_THROW_START
	ld   [hl], a					; Save value
	
	; Pass control once with the throw hitbox enabled (+ an extra one to disable it)
	; and determine if the opponent got grabbed successfully (in range + passed validation).
	;
	; If it went all right, the opponent should have gone through Play_Pl_SetHitAnim.chkThrow
	; (which required us to set wPlayPlThrowActId to PLAY_THROWACT_START first), which will
	; cause in the second frame ???????? to update wPlayPlThrowActId to PLAY_THROWACT_NEXT02.
	
	; Preserve iPlInfo_JoyKeys and iPlInfo_JoyNewKeys while this happens
	ld   hl, iPlInfo_JoyKeys
	add  hl, bc
	ldi  a, [hl]	
	push af				; Save iPlInfo_JoyKeys
		ld   a, [hl]	
		push af			; Save iPlInfo_JoyNewKeys
			push hl
				;--
				; Pass control, activating the temporary throw hitbox
				call Task_PassControlFar
				
				; Disable the throw hitbox and save changes again
				ld   hl, iOBJInfo_ForceHitboxId
				add  hl, de
				xor  a
				ld   [hl], a
				call Task_PassControlFar
				;--
			pop  hl
		pop  af
		ldd  [hl], a	; Restore iPlInfo_JoyNewKeys
	pop  af
	ld   [hl], a	; Restore iPlInfo_JoyKeys
	
	; If the opponent didn't get grabbed, return
	ld   a, [wPlayPlThrowActId]
	cp   PLAY_THROWACT_NEXT02		; On the second part of the throw?
	jp   nz, .noThrow				; If not, return
	
	;
	; Determine if the throw direction gets inverted
	;
	
	; Non-ground throws always get inverted
	ld   a, [wPlayPlThrowOpMode]
	or   a							; wPlayPlThrowOpMode != PLAY_THROWOP_GROUND?
	jp   nz, .invThrow				; If so, jump
	;--
	; [POI] In 95, there was a list of character ID checks that would jump to .invThrow.
	;       It appears wPlayPlThrowDir had a different purpose there though, and it's not applicable anymore.
	ld   hl, iPlInfo_CharId
	add  hl, bc
	ld   a, [hl]
	;--
	; No inversion
	jp   .chkDir
.invThrow:
	ld   a, [wPlayPlThrowDir]
	xor  a, $01					; Switch PLAY_THROWDIR_F / PLAY_THROWDIR_B
	ld   [wPlayPlThrowDir], a
	
.chkDir:
	
	; If the opponent is being thrown "backwards", first switch the player's positions
	; before starting the normal throw.
	ld   a, [wPlayPlThrowDir]
	or   a 					; wPlayPlThrowDir == PLAY_THROWOP_GROUND
	jp   z, .retSet			; If so, skip
	; Switch X positions
	push bc
		ld   a, [wOBJInfo_Pl2+iOBJInfo_X]
		ld   b, a							; B = 2P X
		ld   a, [wOBJInfo_Pl1+iOBJInfo_X]	; A = 1P X
		ld   [wOBJInfo_Pl2+iOBJInfo_X], a	; 2P X = A
		ld   a, b							; 1P X = B
		ld   [wOBJInfo_Pl1+iOBJInfo_X], a
	pop  bc
	; Invert direction for current player only. It doesn't matter to the opponent.
	ld   hl, iOBJInfo_OBJLstFlags
	add  hl, de
	ld   a, [hl]
	xor  SPR_XFLIP
	ld   [hl], a
.retSet:
	ld   a, [wPlayPlThrowOpMode]
	scf		; Set carry flag
	jp   .ret
.noThrow:
	xor  a
	ld   [wPlayPlThrowActId], a
.retClear:
	xor  a	; Clear carry flag
.ret:
	ret
	
; =============== MoveInputS_TryStartCommandThrow_Unk_Coli05 ===============
; Attempts to start a command throw that:
; - Uses collision box $05 as throw range
;
; This is the command grab equivalent to Play_Pl_ChkThrowInput, except
; that input was checked beforehand as it depends on the special move.
;
; Just like Play_Pl_ChkThrowInput, this performs some validation, then tries grab the opponent.
;
; See also: Play_Pl_ChkThrowInput
;
; IN
; - BC: Ptr to wPlInfo structure
; - DE: Ptr to respective wOBJInfo structure
; OUT
; - C: If set, the command throw can start
MoveInputS_TryStartCommandThrow_Unk_Coli05:
	; If a throw is already in progress, return
	ld   a, [wPlayPlThrowActId]
	cp   PLAY_THROWACT_NONE
	jp   nz, MoveInputS_TryStartCommandThrow.noThrow
	
	; Throw forward
	xor  a ; PLAY_THROWDIR_F
	ld   [wPlayPlThrowDir], a
	; [POI] Doesn't matter. This is ignored for command throws
	ld   a, PLAY_THROWOP_UNUSED_BOTH
	ld   [wPlayPlThrowOpMode], a
	
	; Use hitbox $05
	ld   a, $05
	jp   MoveInputS_TryStartCommandThrow
	
; =============== MoveInputS_TryStartCommandThrow_Unk_Coli04 ===============
; Attempts to start a command throw that:
; - Uses collision box $04 as throw range
; - Can't be done if the opponent is getting up
;
; See also: MoveInputS_TryStartCommandThrow_Coli05
;
; IN
; - BC: Ptr to wPlInfo structure
; - DE: Ptr to respective wOBJInfo structure
; OUT
; - C: If set, the command throw can start
MoveInputS_TryStartCommandThrow_Unk_Coli04:
	; If a throw is in progress, return
	ld   a, [wPlayPlThrowActId]
	cp   PLAY_THROWACT_NONE								; ThrowActId != NONE?
	jp   nz, MoveInputS_TryStartCommandThrow.noThrow	; If so, jump
	
	; If the opponent is waking up, return
	ld   hl, iPlInfo_NoThrowTimerOther
	add  hl, bc
	ld   a, [hl]
	or   a												; iPlInfo_NoThrowTimerOther != 0?
	jp   nz, MoveInputS_TryStartCommandThrow.noThrow	; If so, return
	
	; Throw forward
	xor  a ; PLAY_THROWDIR_F
	ld   [wPlayPlThrowDir], a
	; [POI] Doesn't matter. This is ignored for command throws
	xor  a ; PLAY_THROWOP_GROUND
	ld   [wPlayPlThrowOpMode], a
	
	; Use hitbox $04
	ld   a, $04
	; Fall-through
	
; =============== MoveInputS_TryStartCommandThrow ===============
; Attempts to starts a command throw.
; The code for this is identical to Play_Pl_ChkThrowInput.tryStart.
; IN
; - A: Collision box ID for throw range
; - BC: Ptr to wPlInfo structure
; - DE: Ptr to respective wOBJInfo structure
; OUT
; - C: If set, the command throw can start
MoveInputS_TryStartCommandThrow:
	
	;
	; Setup the throw, and see the opponent's response.
	;

	; Write the temporary hitbox, used to determine throw range.
	; This will be active for exactly one frame (see below).
	ld   hl, iOBJInfo_ForceHitboxId
	add  hl, de
	ld   [hl], a
	
	; Start the throw sequence, mandatory to let the other player know we're ready.
	ld   a, PLAY_THROWACT_START
	ld   [wPlayPlThrowActId], a
	
	; All command throws do $0C lines of damage, like normal throws.
	; The damage is taken when the opponent gets thrown at the *end*.
	; Meaning that if it gets aborted early, no damage is dealt.
	; Note that, in the MoveAnimTbl_* entries, the damage fields are all $00 anyway.
	ld   hl, iPlInfo_MoveDamageVal
	add  hl, bc
	ld   a, $0C						; 12 lines of damage
	ld   [hl], a
	
	; If the grab occurres, the opponent will use hit animation HITANIM_THROW_START
	inc  hl							; Seek to iPlInfo_MoveDamageHitAnimId
	ld   a, HITANIM_THROW_START
	ld   [hl], a					; Save value
	
	; Pass control once with the throw hitbox enabled (+ an extra one to disable it)
	; and determine if the opponent got grabbed successfully (in range + passed validation).
	;
	; If it went all right, the opponent should have gone through Play_Pl_SetHitAnim.chkThrow
	; (which required us to set wPlayPlThrowActId to PLAY_THROWACT_START first), which will
	; cause in the second frame ???????? to update wPlayPlThrowActId to PLAY_THROWACT_NEXT02.
	
	; Preserve iPlInfo_JoyKeys and iPlInfo_JoyNewKeys while this happens
	ld   hl, iPlInfo_JoyKeys
	add  hl, bc
	ldi  a, [hl]	
	push af				; Save iPlInfo_JoyKeys
		ld   a, [hl]	
		push af			; Save iPlInfo_JoyNewKeys
			push hl
				;--
				; Pass control, activating the temporary throw hitbox
				call Task_PassControlFar
				
				; Disable the throw hitbox and save changes again
				ld   hl, iOBJInfo_ForceHitboxId
				add  hl, de
				xor  a
				ld   [hl], a
				call Task_PassControlFar
				;--
			pop  hl
		pop  af
		ldd  [hl], a	; Restore iPlInfo_JoyNewKeys
	pop  af
	ld   [hl], a	; Restore iPlInfo_JoyKeys
	
	; If the opponent didn't get grabbed, return
	ld   a, [wPlayPlThrowActId]
	cp   PLAY_THROWACT_NEXT02		; On the second part of the throw?
	jp   nz, .noThrow				; If not, return
	
	;##
	
	; The move can start
	scf			; C flag set
	jp   .ret
.noThrow:
	; Can't start move
	; Also force the current throw to end
	xor  a
	ld   [wPlayPlThrowActId], a
.ret:
	ret
; =============== Play_Pl_ChkHitStop ===============
; Applies hitstop if enabled, as well as other effects induced by the other player.
;
; IN:
; - BC: Ptr to wPlInfo structure
; - DE: Ptr to respective wOBJInfo structure
; OUT
; - C: If set, a new move was started (and interrupted hitstop early)
Play_Pl_ChkHitStop:
	
	;
	; Handle the horizontal push speed we received from the other player.
	; Note that if we get into the hitstop loop, the movement gets delayed until
	; the hitstop ends.
	;

	; By default, don't push the other player.
	; The move code will take care of setting this as needed.
	ld   hl, iPlInfo_PushSpeedHReq
	add  hl, bc
	xor  a
	ld   [hl], a
	
	;
	; If the other player requested us to move out of the way (ie: after a hit when cornered)
	; do that accordingly.
	;
	ld   hl, iPlInfo_PushSpeedHRecv
	add  hl, bc
	ld   a, [hl]		; A = Received horz. push speed
	or   a				; PushSpeed == 0?
	jp   z, .chkHitstop	; If so, skip
	; Otherwise, push horizontally by iPlInfo_PushSpeedHRecv
	ld   h, a			; H = iPlInfo_PushSpeedHRecv
	ld   l, $00
	call Play_OBJLstS_MoveH
	
.chkHitstop:

	;
	; If hitstop is enabled, we get "frozen" until either:
	; - Hitstop naturally ends (see below)
	; - Getting guard cancelled
	; - "Canceling" hitstop to another special move.
	;   This also increases the combo counter in the opponent's Play_Pl_DoHit,
	;   as the other player task won't manage to execute it at least once before getting hit again.
	;   Note that Play_Pl_DoHit is part of the primary main loop (executed every frame) for player tasks
	;   since it's what handles getting hit, but on the frame that happens it will execute the hit
	;   animation code, which ends up calling hitstun/blockstun routines that take exclusive control,
	;   meaning Play_Pl_DoHit won't be executed for a number of frames.
	;
	; We also don't change the hitstop flag directly -- this is done ONLY by the other player task when it gets hit.
	; Specifically, the aforemented hitstuns/blockstun subroutines enable hitstop for the entire 
	; duration of their shake effect (ie: see Play_Pl_DoBlockstun). Since they take exclusive control, only the
	; player who attacked can get here while hitstop is enabled.
	;
	ld   a, [wPlayHitstop]
	or   a				; Is hitstop enabled?
	jp   z, .noStart	; If not, return
.loop:
	; Generate the light/heavy button info
	call Play_Pl_CreateJoyMergedKeysLH
	call Play_Pl_CreateJoyKeysLH
	
	; Check for special move inputs (character-specific)
	call Play_Pl_ExecSpecMoveInputCode	; Was a special move started?
	jp   c, .moveSet				; If so, return
	; Guard cancel variant
	; If we get attacked, Play_Pl_DoHit will call an HitAnimC_* and take exclusive control for a bit.
	; In case of blocking, we can start a new special move (or a roll) when guard canceling.
	call HomeCall_Play_Pl_DoHit		; Did we get attacked and guard cancelled?
	jp   c, .moveSet				; If so, return
	
	call Task_PassControlFar
	
	; If still locked, loop
	ld   a, [wPlayHitstop]
	or   a					; Is hitstop still enabled?
	jp   nz, .loop			; If so, loop
.noStart:
	xor  a	; C flag was clear
	ret
.moveSet:
	ret		; C flag was set
	
; =============== Play_Pl_GiveKnockbackCornered ===============
; Pushes the other player away when hit while cornered.
;
; This replaces any existing pushback from overlapping collision boxes, and it's what
; causes players to get pushed away when hitting a cornered opponent.
;
; The reasoning behind this is that the game tries to push players away
; by a certain distance when recovering from an attack.
; Normally, the player that gets hit receives a knockback, but if cornered,
; this subroutine gives that knockback to the other player.
;
; IN:
; - BC: Ptr to wPlInfo for the player who got hit
; - DE: Ptr to respective wOBJInfo structure
Play_Pl_GiveKnockbackCornered:
	
	;
	; Knockback transfer isn't applicable if we got hit by a projectile,
	; as the player could be anywhere on the screen.
	;
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	bit  PF0B_PROJHIT, [hl]		; Is the flag set?
	jp   nz, .ret				; If so, return
	
	; Copy iOBJInfo_RangeMoveAmount to iPlInfo_PushSpeedHReq.
	;
	; iOBJInfo_RangeMoveAmount is set when the knockback attempts to move us off-screen.
	; The game doesn't want that, so we get pushed back to the visible screen range, and 
	; how much we were moved is saved to iOBJInfo_RangeMoveAmount.
	; That is essentially the knockback we would have received in the frame, and as we can't move
	; any further, we instead push the other player by that amount.
	ld   hl, iOBJInfo_RangeMoveAmount
	add  hl, de						; Seek to iOBJInfo_RangeMoveAmount
	ld   a, [hl]					; A = iOBJInfo_RangeMoveAmount
	ld   hl, iPlInfo_PushSpeedHReq
	add  hl, bc						; Seek to iPlInfo_PushSpeedHReq
	ld   [hl], a					; iPlInfo_PushSpeedHReq = A
.ret:
	ret
	
; =============== Play_Pl_DoHitstun ===============
; Generic hitstun handler that doesn't allow guard cancels.
;
; Handles the effect for the player shaking when coming in contact with an hit.
; This can happen both when blocking the attack or getting hit.
;
; IN
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo structure
; OUT
; - C flag: Always clear, as there's no guard cancel. 
;           Return value required by Play_Pl_DoBlockstun jumping to here.
Play_Pl_DoHitstun:

	;
	; If we haven't been hit by a projectile, mark that we received a physical hit
	; and enable hitstop to the opponent.
	;
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	bit  PF0B_PROJHIT, [hl]			; Did we get hit by a projectile?
	jp   nz, .go					; If so, skip
	; Enable opponent hitstop next frame
	ld   a, $01								
	ld   [wPlayHitstopSet], a
	; Remove the physical damage source next frame.
	ld   hl, iPlInfo_PhysHitRecv
	add  hl, bc
	ld   [hl], a
	
.go:

	;
	; Shake the player by 1px for the required amount of frames.
	; While this happens, the player is completely blocked and input is ignored.
	;

	; Save iPlInfo_Flags1 value
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	ld   a, [hl]
	push af
		;--
		; Can't be hit during blockstun
		set  PF1B_INVULN, [hl]
		
		call Play_Pl_GetShakeCount	; Determine for how many frames to do the effect
		call Play_Pl_ShakeFor		; Do it
		;--
	pop  af
	; Restore iPlInfo_Flags1 and disable opponent hitstop
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	ld   [hl], a
	ld   a, $00
	ld   [wPlayHitstopSet], a
	ret
	
; =============== Play_Pl_ShakeFor ===============
; Shakes the player sprite by 1px for the specified amount of frames,
; by moving back and forth the sprite horizontally.
;
; This takes control for the entire duration of the normal blockstun.
; As this ignores player input, it should't be used when the player
; is allowed to guard cancel.
; 
; IN:
; - A: Number of frames (*2) the effect is performed
; - DE: Ptr to wOBJInfo for the player
Play_Pl_ShakeFor:
	push bc
		;
		; Set up the variables
		;
		ld   b, a			; B = Loop count
		ld   hl, iOBJInfo_OBJLstFlags
		add  hl, de
		ld   c, [hl]		; C = Flags
		ld   hl, iOBJInfo_X
		add  hl, de			; HL = Ptr to iOBJInfo_X
		
		;
		; Even though it doesn't really matter (it's 2 pixels of difference at most), 
		; the shake effect is done slightly differently depending on the direction the player is facing.
		;
		bit  SPRB_XFLIP, c	; Is the player visually facing right (1P side)?
		jp   z, .shakeR		; If not, jump
	.shakeL:
		; 
		; If the player is facing left (2P side, no SPRB_XFLIP),
		; move the sprite 1px to the left, then move it back.
		;
		dec  [hl]					; Move left 1px
		call Task_PassControlFar	; Wait next frame
		inc  [hl]					; Move right 1px
		call Task_PassControlFar	; Wait next frame
		dec  b						; Are we done?
		jp   nz, .shakeL			; If not, loop
		jp   .end					; Otherwise, we're done
	.shakeR:
		; 
		; If the player is facing right (1P side, with SPRB_XFLIP),
		; move the sprite 1px to the right, then move it back.
		;
		inc  [hl]					; Move right 1px
		call Task_PassControlFar	; Wait next frame
		dec  [hl]					; Move left 1px
		call Task_PassControlFar	; Wait next frame
		dec  b						; Are we done?
		jp   nz, .shakeR			; If not, loop
									; Otherwise, we're done
	.end:
	pop  bc
	ret
; =============== Play_Pl_GetShakeCount ===============
; Determines how many times to shake the player after receiving/blocking an hit.
; IN:
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo structure
; OUT
; - A: How many times to perform the effect.
;      Multiply it by 2 to get the number of frames the shake lasts.
Play_Pl_GetShakeCount:

	;
	; By default, shake the player 8 times.
	; If we didn't get hit by a projectile, add 2 more.
	;
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	bit  PF0B_PROJHIT, [hl]	; Did we get hit by a projectile?
	jp   nz, .base08		; If so, jump
.base0A:
	ld   a, $08+$02			; ShakeCnt = $0A
	jp   .chkDamageFlags
.base08:
	ld   a, $08				; ShakeCnt = $08
	
	
.chkDamageFlags:
	;
	; The shake count can be affected by the move we got attacked with.
	;
	
	ld   hl, iPlInfo_Flags3
	add  hl, bc
	
	; Some moves shake the player once
	bit  PF3B_SHAKEONCE, [hl]	; Is the bit set?
	jp   nz, .shakeOnce			; If so, jump
	
	; If this isn't set as a long shake, cut in half the shake count
	bit  PF3B_SHAKELONG, [hl]	; Is the bit set?
	jp   nz, .chkHealth			; If so, jump
.shakeHalf:
	srl  a						; ShakeCnt = ShakeCnt / 2				
	jp   .chkHealth
.shakeOnce:
	ld   a, $01					; ShakeCnt = 1
	
	
.chkHealth:
	;
	; If the player has health left, multiply the result by 2 and cap it at $0B.
	;
	; Otherwise, we return immediately with the existing value of A.
	; This is to cut in half the duration of the shake effect when a player is defeated, possibly
	; to balance out how the game runs at half speed there. Meaning that, visually, they last as exactly as long.
	;
	
	; Only if the player has some health left.
	ld   hl, iPlInfo_Health
	add  hl, bc
	push af
		ld   a, [hl]
		or   a				; Health == 0?
		jp   nz, .noChange	; If so, return
	pop  af
	
	; Multiply shake count by 2, capping it at $0B
	sla  a					; A *= 2
	cp   $0B				; A < $0B?
	jp   c, .ret			; If so, jump
	ld   a, $0B				; Otherwise, cap at $0B
	; We're done
	jp   .ret
.noChange:
	pop  af
.ret:
	ret
	
; =============== Play_Pl_DoHitstunOnce ===============
; Performs the normal hit shake effect once, for two frames.
; For physical hits only.
; IN:
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo structure
Play_Pl_DoHitstunOnce:
	; Always enable hitstop to the opponent while this happens,
	; since this is only called for physical hits.
	ld   a, $01
	ld   [wPlayHitstopSet], a
	
	; Mark that the other player attempted to hit us with a physical move,
	; to remove the damage source next frame.
	ld   hl, iPlInfo_PhysHitRecv
	add  hl, bc
	ld   [hl], a
	
	;
	; Shake the player for 2 frames.
	;
	
	; Save flags
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	ld   a, [hl]
	push af
		; Can't be hit while this happens, as usual for blockstun
		set  PF1B_INVULN, [hl]
		; Perform effect
		ld   a, $01				; 1(*2) frames
		call Play_Pl_ShakeFor
	pop  af
	; Restore flags
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	ld   [hl], a
	
	; Disable opponent hitstop next frame
	ld   a, $00
	ld   [wPlayHitstopSet], a
	ret
	
; =============== Play_Pl_DoBlockstun ===============
; Main handler for blockstun.
; IN:
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo structure
; OUT:
; - C flag: If set, blockstun ended early as a new move was started
;           (ie: guard cancel happened)
Play_Pl_DoBlockstun:
	
	;
	; If not at max power, reuse the normal hitstun handler.
	;
	ld   hl, iPlInfo_Pow
	add  hl, bc
	ld   a, [hl]
	cp   PLAY_POW_MAX			; iPlInfo_Pow != $28?
	jp   nz, Play_Pl_DoHitstun	; If so, jump
	
	;
	; At max power, both players shakes more visibly during blockstun.
	; It's also possible to guard cancel by performing a roll or inputing a special move.
	;
	
	;
	; If we haven't been hit by a projectile, mark that we received a physical hit
	; and enable hitstop to the opponent from the next frame.
	;
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	bit  PF0B_PROJHIT, [hl]				; Did we get hit by a projectile?
	jp   nz, .setFlags1					; If so, skip
	; Enable (opponent) hitstop next frame
	ld   a, $01								
	ld   [wPlayHitstopSet], a
	; Remove the physical damage source next frame.
	ld   hl, iPlInfo_PhysHitRecv
	add  hl, bc
	ld   [hl], a							
	
.setFlags1:
	; Save flags
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	ld   a, [hl]
	push af
		; Can't be hit during blockstun
		set  PF1B_INVULN, [hl]
		
		; A = Shake count
		call Play_Pl_GetShakeCount		
		
		;
		; Shake 2px at a time A times.
		; This will take A*2 frames.
		;
		; While that happens, check if the player has performed a guard cancel,
		; and if so, break out of the loop.
		;
				
		; HL = Ptr to player X position
		ld   hl, iOBJInfo_X
		add  hl, de
	.loop:
		push af
			; Move left 2px
			inc  [hl]
			inc  [hl]
			call Task_PassControlFar
			
			; Check for input
			push hl
				; Generate the light/heavy button info
				call Play_Pl_CreateJoyKeysLH
				call Play_Pl_ChkGuardCancelRoll		; Did we roll out of guard?
				jp   c, .endEarly					; If so, return (we started a move)
				call Play_Pl_ExecSpecMoveInputCode	; Performed any special move input?
				jp   c, .endEarly					; If so, return (guard cancel to move)
			pop  hl
			
			; Move right 2px
			dec  [hl]
			dec  [hl]
			call Task_PassControlFar
			
			; Check for inputs like before
			push hl
				call Play_Pl_CreateJoyKeysLH
				call Play_Pl_ChkGuardCancelRoll
				jp   c, .endEarly
				call Play_Pl_ExecSpecMoveInputCode
				jp   c, .endEarly
			pop  hl
		pop  af
		dec  a			; Done this all times?
		jp   nz, .loop	; If not, loop
.endNorm:
	; Restore flags
	pop  af
	ld   hl, iPlInfo_Flags1
	add  hl, bc
	ld   [hl], a
	; Disable opponent hitstop next frame
	ld   a, $00
	ld   [wPlayHitstopSet], a
	xor  a		; C flag clear
	ret
			.endEarly:
			; Restore regs
			pop  hl
		pop  af
	pop  af
	; Note that the flags aren't restored, as starting a new move
	; set new values for many fields, including iPlInfo_Flags1.
	
	; Disable opponent hitstop next frame
	ld   a, $00
	ld   [wPlayHitstopSet], a
	scf			; C flag set
	ret
	
; =============== Play_Pl_ChkGuardCancelRoll ===============
; Checks if the player can roll out of blockstun and is performing the input for it.
;
; Note that this is not used as a general move check for rolls,
; as that's handled by the basic input handler.
; IN:
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
; OUT:
; - C flag: If set, the player started rolling
Play_Pl_ChkGuardCancelRoll:

	;
	; Rolls require the player to be exactly on the ground.
	;

	; Don't allow in the air
	ld   hl, iOBJInfo_Y
	add  hl, de
	ldi  a, [hl]		; A = iOBJInfo_Y, Seek to iOBJInfo_YSub
	cp   PL_FLOOR_POS	; iOBJInfo_Y != $88?
	jp   nz, .retClear	; If so, jump
	
	; Must be exactly aligned to the ground, even at subpixel level
	ld   a, [hl]
	or   a				; iOBJInfo_YSub != 0?
	jp   nz, .retClear	; If so, jump
	
	;
	; And they require holding both buttons at the same timeù
	;
	call Play_Pl_AreBothBtnHeld		; Holding A and B?
	jp   nc, .retClear				; If not, return
	
	;
	; If we got here, the roll is guaranteed.
	; Set a bunch of flags.
	;
	
	
	; Holding UP when the guard cancel roll ends should trigger an hyper jump.
	ld   hl, iPlInfo_RunningJump
	add  hl, bc			
	ld   [hl], $01
	
	
	ld   hl, iPlInfo_Flags0
	add  hl, bc			; Seek to iPlInfo_Flags0
	
	; Pretend that the guard cancel roll is a super move.
	; This has two effects:
	; - The player flashes while rolling
	; - Any normal fireball coming in contact with the player gets erased
	set  PF0B_SUPERMOVE, [hl]
	
	inc  hl							; Seek to iPlInfo_Flags1
	res  PF1B_GUARD, [hl] 			; Can't block when rolling (we are invulnerable instead)
	res  PF1B_CROUCH, [hl] 			; As rolling starts from crouching, remove the crouch flag
	set  PF1B_NOBASICINPUT, [hl] 	; Don't override with normal movement
	set  PF1B_XFLIPLOCK, [hl] 		; Lock player direction during the roll
	set  PF1B_NOSPECSTART, [hl] 	; Don't allow cancelling the roll into a special
	
	inc  hl				; Seek to iPlInfo_Flags2
	
	; Make player completely invulnerable while rolling.
	; Disabling both hurtbox and hitbox causes every attack collision check to be ignored.
	set  PF2B_NOHURTBOX, [hl]
	set  PF2B_NOCOLIBOX, [hl]
	
	inc  hl				; Seek to iPlInfo_Flags3
	; Remove these flash bits to let PF0B_SUPERMOVE handle the flashing
	res  PF3B_FLASH_B_SLOW, [hl]
	res  PF3B_FLASH_B_FAST, [hl]
	
	;
	; Determine if player should roll forwards or backwards depending on the held directional keys.
	;
	; Either due to a bug or because the player is likely to be holding back during blockstun,
	; that button *isn't* checked for activating the back roll.
	;
	; Instead, holding DOWN activates the back roll.
	; Not holding any key on the d-pad instead defaults it to a forward roll.
	;
	call Play_Pl_GetDirKeys_ByXFlipR	; Check d-pad keys
	jp   nc, .setRollFront		; Were any keys held? If not, default to front
	
	; [POI/BUG?] Holding *DOWN* activates the back roll
	bit  KEYB_DOWN, a			; Holding down?
	jp   nz, .setRollBack		; If so, back roll
	jp   .setRollFront			; Otherwise, front roll
.setRollBack:
	ld   a, MOVE_SHARED_ROLL_B
	jp   .retSet
.setRollFront:
	ld   a, MOVE_SHARED_ROLL_F
	jp   .retSet
.retSet:
	; Switch to the new move
	call Pl_SetMove_StopSpeed
	scf		; C flag set
	ret
.retClear:
	xor  a	; C flag clear
	ret
	
; =============== Play_Pl_DoGroundScreenShake ===============
; Shakes the playfield vertically based on the specified OBJInfo animation timer.
; The shaken player MUST be on the ground to use this, while
; the other player is left unchanged and can be anywhere.
;
; This is mostly used to make an hitstun'd player and the screen shake when
; being thrown on the ground by certain super moves (ie: Daimon's super throw).
;
; IN:
; - DE: Ptr to wOBJInfo for player
Play_Pl_DoGroundScreenShake:

	;
	; Don't do anything other than forcing the player at ground level if
	; the player graphics (for the next frame) are being copied to VRAM.
	; Otherwise there would be an issue with the way the earthquake effect
	; is disabled (guarded by a mMvC_ValFrameEnd).
	;
	call OBJLstS_IsGFXLoadDone	; Loading finished?
	jp   nz, .resetGround		; If not, skip
	
	;
	; The shake effect uses a gradual offset that fades out over time:
	; Offset = -(iOBJInfo_FrameLeft % $10)
	;
	; When the offset is decremented from 0, it returns to $0F.
	;
	; Alternating between every 2 frames, said offset gets added to one value,
	; and the other gets reset to default.
	; 
	
	; When (iOBJInfo_FrameLeft % $10) becomes 0, both values are essentially reset to default.
	; Continue to .resetGround to save time and make sure both values are reset properly.
	ld   hl, iOBJInfo_FrameLeft
	add  hl, de
	ld   a, [hl]		; A = iOBJInfo_FrameLeft
	and  a, $0F			; FrameLeft & $0F == 0?
	jp   nz, .setShake	; If not, jump
	
.resetGround:
	; Reset the Y screen offset at normal levels
	ld   hl, wScreenShakeY
	ld   [hl], $00		; wScreenShakeY = 0
	
	; Reset player vertical position to ground
	ld   hl, iOBJInfo_Y
	add  hl, de
	ld   [hl], PL_FLOOR_POS		; iOBJInfo_Y = $88
	jp   .ret
.setShake:

	;
	; This will be called for at most $0F frames continuously.
	; Alternate between offsetting/resetting wScreenShakeY and iOBJInfo_Y every 2 frames,
	;
	ld   hl, wScreenShakeY		; HL = iOBJInfo_FrameLeft
	bit  1, a					; iOBJInfo_FrameLeft & $02 != 0?
	jp   nz, .setShakeScrn		; If so, jump
	
.setShakeOBJ:
	; Reset the screen scroll offset
	; wScreenShakeY = $00
	ld   [hl], $00		
	
	; Move player sprite up by A
	; iOBJInfo_Y -= A
	ld   hl, iOBJInfo_Y
	add  hl, de		; HL = Ptr to iOBJInfo_Y
	cpl				; A = -A
	inc  a
	add  a, [hl]	; A += iOBJInfo_Y
	ld   [hl], a	; Save it back
	jp   .ret
	
.setShakeScrn:
	
	; Scroll screen up by A
	; wScreenShakeY = -A
	push af
		cpl				; A = -A
		inc  a
		ld   [hl], a	; wScreenShakeY = A
	pop  af
	
	; Reset player sprite to ground
	ld   hl, iOBJInfo_Y
	add  hl, de
	ld   [hl], PL_FLOOR_POS
.ret:
	ret
	
; =============== Play_Pl_IsDizzyNext ===============
; Determines if the specified player was requested to get dizzy.
; IN
; - BC: Ptr to wPlInfo
; OUT
; - Z flag: If set, the player isn't dizzy
Play_Pl_IsDizzyNext:
	; Z = iPlInfo_DizzyNext == 0
	ld   hl, iPlInfo_DizzyNext
	add  hl, bc		
	ld   a, [hl]	; A = iPlInfo_DizzyNext
	or   a			; A != 0?
	ret
	
; =============== Play_Pl_StartWakeUp ===============
; Initializes the wake up move, meant to be used after a player falls on the ground
; (see: HitAnimC_Drop* and MoveC_Hit_Drop*).
;
; If the player has no health left (what hit the player killed him), he will instead
; stay on the ground forever, by setting MOVE_SHARED_NONE.
;
; IN:
; - BC: Ptr to wPlInfo
; - DE: Ptr to respective wOBJInfo
Play_Pl_StartWakeUp:
	; Empty Max POW is possible
	call Play_Pl_EmptyPowOnSuperEnd
	
	;
	; If the player has no health, stop player movement/animations by setting MOVE_SHARED_NONE.
	; This is also important for Play_LoadPostRoundText0, since the game waits for both characters
	; to be in either this or the idle move before showing the KO text.
	;
	ld   hl, iPlInfo_Health
	add  hl, bc
	ld   a, [hl]
	or   a				; Health != 0?
	jp   nz, .alive		; If so, jump
.setDead:
	; Otherwise, stop player movement / animations.
	; The move ID won't be changed anymore from here.
	ld   hl, iPlInfo_MoveId
	add  hl, bc
	ld   [hl], MOVE_SHARED_NONE		; iPlInfo_MoveId = 0
	jp   .ret
	
.alive:
	; Can't be thrown for $1E frames from here.
	; This covers waking up and a few frames after.
	ld   hl, iPlInfo_NoThrowTimer
	add  hl, bc
	ld   [hl], $1E
	
	; Update flags
	ld   hl, iPlInfo_Flags0
	add  hl, bc
	; Player is on the ground if rolling
	res  PF0B_AIR, [hl]
	
	; Reset this for the next time we get hit
	res  PF0B_PROJHIT, [hl]
	; On the ground we can't attack indirectly
	res  PF0B_PROJREM, [hl]
	res  PF0B_PROJREFLECT, [hl]
	
	inc  hl							; Seek to iPlInfo_Flags1
	res  PF1B_HITRECV, [hl] 		; Falling to the ground ends the opponent's combo
	res  PF1B_ALLOWHITCANCEL, [hl] ; For next time
	; The player can't be hit on the ground
	set  PF1B_INVULN, [hl]
	
	; Set move for getting up
	ld   a, MOVE_SHARED_WAKEUP
	call Pl_SetMove_StopSpeed
.ret:
	ret
	
; =============== HomeCall_Play_Pl_DoHit ===============
; This used to be here in BANK $00 in KOF95.
HomeCall_Play_Pl_DoHit:
	ldh  a, [hROMBank]
	push af
	ld   a, BANK(Play_Pl_DoHit) ; BANK $02
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	call Play_Pl_DoHit
	pop  af
	ld   [MBC1RomBank], a
	ldh  [hROMBank], a
	ret
; =============== MoveInputS_CheckGAType ===============
; Determines the type of attack triggered by the buttons.
; IN
; - BC: Ptr to wPlInfo structure
; OUT
; - C flag: If set, the punch or kick button was registered as being pressed.
; - Z flag: If set, a punch was registered. Otherwise, it's a kick.
; - iPlInfo_Flags2: If PF2B_HEAVY is set, an heavy was registered. Otherwise, it's a light.
;                    This will be used when determining if the light or heavy move should start,
;                    see MoveInputS_CheckMoveLHVer
MoveInputS_CheckGAType:
	; A = Held keys
	ld   hl, iPlInfo_JoyKeysLH
	add  hl, bc
	ld   a, [hl]		
	
	; HL = Ptr to flags
	ld   hl, iPlInfo_Flags2
	add  hl, bc			
	
	; Determine the combination of returned flags based on the light/heavy info.
	bit  KEPB_A_LIGHT, a	; Light kick?
	jr   nz, .lk			
	bit  KEPB_B_LIGHT, a	; Light punch?
	jr   nz, .lp
	bit  KEPB_A_HEAVY, a	; Heavy kick?
	jr   nz, .hk
	bit  KEPB_B_HEAVY, a	; Heavy punch?
	jr   nz, .hp
.none:
	scf
	ccf		; Clear carry
	ret
	
.lk:
	res  PF2B_HEAVY, [hl]	; Not an heavy
	jp   .k
.hk:
	set  PF2B_HEAVY, [hl]	; Is heavy
.k:
	xor  a
	inc  a	; Clear zero
	scf		; Set carry
	ret
	
.lp:
	res  PF2B_HEAVY, [hl]	; Not an heavy
	jp   .p
.hp:
	set  PF2B_HEAVY, [hl]	; Is heavy
.p:
	xor  a	; Set zero
	scf		; Set carry
	ret
	
; =============== Play_Pl_ClearJoyMergedKeysLH ===============
; Blank out iPlInfo_JoyMergedKeysLH for the specified player.
; IN
; - BC: Ptr to wPlInfo structure
Play_Pl_ClearJoyMergedKeysLH:
	ld   hl, iPlInfo_JoyMergedKeysLH
	add  hl, bc
	ld   [hl], $00
	ret
	
; =============== MoveInputS_CheckPKTypeWithMergedLH ===============
; Simplified version of MoveInputS_CheckGAType that only determines if the attack
; triggered by the buttons is a light or a heavy.
; This also uses iPlInfo_JoyMergedKeysLH instead of iPlInfo_JoyKeysLH.
; IN
; - BC: Ptr to wPlInfo structure
; OUT
; - C flag: If set, the punch or kick button was registered as being pressed.
; - Z flag: If set, a punch was registered. Otherwise, it's a kick.
MoveInputS_CheckPKTypeWithMergedLH:
	; A = Held keys
	ld   hl, iPlInfo_JoyMergedKeysLH
	add  hl, bc
	ld   a, [hl]
	
	; Determine the combination if it's a punch or kick
	bit  KEPB_A_LIGHT, a	; Light kick?
	jr   nz, .k
	bit  KEPB_B_LIGHT, a	; Light punch?
	jr   nz, .p
	bit  KEPB_A_HEAVY, a	; Heavy kick?
	jr   nz, .k
	bit  KEPB_B_HEAVY, a	; Heavy punch?
	jr   nz, .p
.none:
	scf
	ccf		; Clear carry
	ret
.k:
	xor  a
	inc  a	; Clear zero
	scf		; Set carry
	ret
.p:
	xor  a	; Set zero
	scf		; Set carry
	ret
	
; =============== MoveInputS_CheckEasyMoveKeys ===============
; Checks if the player is holding a button combination used for the "Easy Moves" cheat.
; These combinations are activated by holding exactly either:
; - SELECT + A
; - SELECT + B
; And any character is assigned a move for each.
;
; IN
; - BC: Ptr to wPlInfo structure
; OUT
; - Z flag: If set, SELECT + A was pressed
; - C flag: If set, SELECT + B was pressed
MoveInputS_CheckEasyMoveKeys:
	; Only if the cheat is enabled
	ld   a, [wDipSwitch]
	bit  DIPB_EASY_MOVES, a
	jp   z, .none
	
	; Determine which key combination are holding
	ld   hl, iPlInfo_JoyKeys
	add  hl, bc					
	
	; SELECT + B
	ld   a, [hl]				; A = Held player keys
	and  a, KEY_SELECT|KEY_B	; Filter the required keys
	cp   KEY_SELECT|KEY_B		; Are we holding exactly SELECT+B (and nothing else)?
	jp   z, .selectB			; If so, jump
	
	; SELECT + A
	ld   a, [hl]				; A = Held player keys
	and  a, KEY_SELECT|KEY_A	; Filter the required keys
	cp   KEY_SELECT|KEY_A		; Are we holding exactly SELECT+A (and nothing else)?
	jp   z, .selectA			; If so, jump
.none:							; Otherwise, there's nothing here
	xor  a	; C flag clear, Z flag clear
	inc  a
	ret
.selectB:
	xor  a	; C flag set, Z flag clear
	inc  a
	scf
	ret
.selectA:;J
	xor  a	; C flag clear, Z flag set
	ret
	
; =============== Play_Pl_TempPauseOtherAnim ===============
; Temporarily pauses the opponent's animation by setting its iOBJInfo_FrameLeft to $FF.
;
; ??? Meant when the hitting the other player in a way that freezes it, like with counters.
;
; Though this iOBJInfo_FrameLeft should never elapse as another animation should interrupt it,
; because it can, it prevents possible softlocks if a move were to break and not unfreeze the opponent.
;
; IN
; - BC: Ptr to wPlInfo structure
Play_Pl_TempPauseOtherAnim:
	ld   hl, iPlInfo_PlId
	add  hl, bc
	ld   a, [hl]
	or   a			; iPlInfo_PlId == PL1
	jp   nz, .pl2	; If not, jump
.pl1:
	ld   hl, wOBJInfo_Pl2+iOBJInfo_FrameLeft
	jp   .clear
.pl2:
	ld   hl, wOBJInfo_Pl1+iOBJInfo_FrameLeft
.clear:
	ld   [hl], $FF
	ret
	
; Remember that these inputs are relative to the 2P side!

; Down  -> D
; Up    -> U
; Left  -> F(front)
; Right -> B(ack)
; A     -> K(ick)
; B     -> P(unch)
; None  -> N
;
;

MoveInput_DF:
	db $02         ; Number of inputs
.i2:
	db KEY_LEFT    ; Key
	db KEY_LEFT    ; Include
	db $01         ; Min len
	db $14         ; Max len
.i1:
	db KEY_DOWN    ; Key
	db KEY_DOWN    ; Include
	db $01         ; Min len
	db $FF         ; Max len
	
MoveInput_DB:
	db $02         ; Number of inputs
.i2:
	db KEY_RIGHT   ; Key
	db KEY_RIGHT   ; Include
	db $01         ; Min len
	db $14         ; Max len
.i1:
	db KEY_DOWN    ; Key
	db KEY_DOWN    ; Include
	db $01         ; Min len
	db $FF         ; Max len
	
; (identical to MoveInput_DB)
MoveInput_DB_Copy:
	db $02         ; Number of inputs
.i2:
	db KEY_RIGHT   ; Key
	db KEY_RIGHT   ; Include
	db $01         ; Min len
	db $14         ; Max len
.i1:
	db KEY_DOWN    ; Key
	db KEY_DOWN    ; Include
	db $01         ; Min len
	db $FF         ; Max len
	
MoveInput_DU_Slow:
	db $02         ; Number of inputs
.i2:
	db KEY_UP      ; Key
	db KEY_UP      ; Include
	db $01         ; Min len
	db $14         ; Max len
.i1:
	db KEY_DOWN    ; Key
	db KEY_DOWN    ; Include
	db $02         ; Min len
	db $FF         ; Max len

MoveInput_DBDF:
	db $04         ; Number of inputs
.i4:
	db KEY_LEFT    ; Key
	db KEY_LEFT    ; Include
	db $01         ; Min len
	db $14         ; Max len
.i3:
	db KEY_DOWN    ; Key
	db KEY_DOWN    ; Include
	db $01         ; Min len
	db $0A         ; Max len
.i2:
	db KEY_RIGHT   ; Key
	db KEY_RIGHT   ; Include
	db $01         ; Min len
	db $0A         ; Max len
.i1:
	db KEY_DOWN    ; Key
	db KEY_DOWN    ; Include
	db $01         ; Min len
	db $FF         ; Max len

MoveInput_DBDB:
	db $04         ; Number of inputs
.i4:
	db KEY_RIGHT   ; Key
	db KEY_RIGHT   ; Include
	db $01         ; Min len
	db $14         ; Max len
.i3:
	db KEY_DOWN    ; Key
	db KEY_DOWN    ; Include
	db $01         ; Min len
	db $0A         ; Max len
.i2:
	db KEY_RIGHT   ; Key
	db KEY_RIGHT   ; Include
	db $01         ; Min len
	db $0A         ; Max len
.i1:
	db KEY_DOWN    ; Key
	db KEY_DOWN    ; Include
	db $01         ; Min len
	db $FF         ; Max len
	
MoveInput_DFDF:
	db $04         ; Number of inputs
.i4:
	db KEY_LEFT    ; Key
	db KEY_LEFT    ; Include
	db $01         ; Min len
	db $14         ; Max len
.i3:
	db KEY_DOWN    ; Key
	db KEY_DOWN    ; Include
	db $01         ; Min len
	db $0A         ; Max len
.i2:
	db KEY_LEFT    ; Key
	db KEY_LEFT    ; Include
	db $01         ; Min len
	db $0A         ; Max len
.i1:
	db KEY_DOWN    ; Key
	db KEY_DOWN    ; Include
	db $01         ; Min len
	db $FF         ; Max len
	
MoveInput_DFDB:
	db $04         ; Number of inputs
.i4:
	db KEY_RIGHT   ; Key
	db KEY_RIGHT   ; Include
	db $01         ; Min len
	db $14         ; Max len
.i3:
	db KEY_DOWN    ; Key
	db KEY_DOWN    ; Include
	db $01         ; Min len
	db $0A         ; Max len
.i2:
	db KEY_LEFT    ; Key
	db KEY_LEFT    ; Include
	db $01         ; Min len
	db $0A         ; Max len
.i1:
	db KEY_DOWN    ; Key
	db KEY_DOWN    ; Include
	db $01         ; Min len
	db $FF         ; Max len
	
MoveInput_DFUBD:
	db $05         ; Number of inputs
.i5:
	db KEY_DOWN    ; Key
	db KEY_DOWN    ; Include
	db $01         ; Min len
	db $14         ; Max len
.i4:
	db KEY_RIGHT   ; Key
	db KEY_RIGHT   ; Include
	db $01         ; Min len
	db $0A         ; Max len
.i3:
	db KEY_UP      ; Key
	db KEY_UP      ; Include
	db $01         ; Min len
	db $0A         ; Max len
.i2:
	db KEY_LEFT    ; Key
	db KEY_LEFT    ; Include
	db $01         ; Min len
	db $0A         ; Max len
.i1:
	db KEY_DOWN    ; Key
	db KEY_DOWN    ; Include
	db $01         ; Min len
	db $FF         ; Max len
	
MoveInput_FDB:
	db $03         ; Number of inputs
.i3:
	db KEY_RIGHT   ; Key
	db KEY_RIGHT   ; Include
	db $01         ; Min len
	db $14         ; Max len
.i2:
	db KEY_DOWN    ; Key
	db KEY_DOWN    ; Include
	db $01         ; Min len
	db $0A         ; Max len
.i1:
	db KEY_LEFT    ; Key
	db KEY_LEFT    ; Include
	db $01         ; Min len
	db $FF         ; Max len
	
MoveInput_FBDF:
	db $04         ; Number of inputs
.i4:
	db KEY_LEFT    ; Key
	db KEY_LEFT    ; Include
	db $01         ; Min len
	db $14         ; Max len
.i3:
	db KEY_DOWN    ; Key
	db KEY_DOWN    ; Include
	db $01         ; Min len
	db $0A         ; Max len
.i2:
	db KEY_RIGHT   ; Key
	db KEY_RIGHT   ; Include
	db $01         ; Min len
	db $0A         ; Max len
.i1:
	db KEY_LEFT    ; Key
	db KEY_LEFT    ; Include
	db $01         ; Min len
	db $FF         ; Max len
	
MoveInput_FDF:
	db $03         ; Number of inputs
.i3:
	db KEY_LEFT    ; Key
	db KEY_LEFT    ; Include
	db $01         ; Min len
	db $14         ; Max len
.i2:
	db KEY_DOWN    ; Key
	db KEY_DOWN    ; Include
	db $01         ; Min len
	db $0A         ; Max len
.i1:
	db KEY_LEFT    ; Key
	db KEY_LEFT    ; Include
	db $01         ; Min len
	db $FF         ; Max len
	
MoveInput_FDBF:
	db $04         ; Number of inputs
.i4:
	db KEY_LEFT    ; Key
	db KEY_LEFT    ; Include
	db $01         ; Min len
	db $14         ; Max len
.i3:
	db KEY_RIGHT   ; Key
	db KEY_RIGHT   ; Include
	db $01         ; Min len
	db $0A         ; Max len
.i2:
	db KEY_DOWN    ; Key
	db KEY_DOWN    ; Include
	db $01         ; Min len
	db $0A         ; Max len
.i1:
	db KEY_LEFT    ; Key
	db KEY_LEFT    ; Include
	db $01         ; Min len
	db $FF         ; Max len
	
MoveInput_FDBFDB:
	db $06         ; Number of inputs
.i6:
	db KEY_RIGHT   ; Key
	db KEY_RIGHT   ; Include
	db $01         ; Min len
	db $0A         ; Max len
.i5:
	db KEY_DOWN    ; Key
	db KEY_DOWN    ; Include
	db $01         ; Min len
	db $0A         ; Max len
.i4:
	db KEY_LEFT    ; Key
	db KEY_LEFT    ; Include
	db $01         ; Min len
	db $0A         ; Max len
.i3:
	db KEY_RIGHT   ; Key
	db KEY_RIGHT   ; Include
	db $01         ; Min len
	db $0A         ; Max len
.i2:
	db KEY_DOWN    ; Key
	db KEY_DOWN    ; Include
	db $01         ; Min len
	db $0A         ; Max len
.i1:
	db KEY_LEFT    ; Key
	db KEY_LEFT    ; Include
	db $01         ; Min len
	db $FF         ; Max len
	
MoveInput_BF_Slow:
	db $02         ; Number of inputs
.i2:
	db KEY_LEFT    ; Key
	db KEY_LEFT    ; Include
	db $01         ; Min len
	db $14         ; Max len
.i1:
	db KEY_RIGHT   ; Key
	db KEY_RIGHT   ; Include
	db $02         ; Min len
	db $FF         ; Max len
	
MoveInput_BF_Fast:
	db $02         ; Number of inputs
.i2:
	db KEY_LEFT    ; Key
	db KEY_LEFT    ; Include
	db $01         ; Min len
	db $14         ; Max len
.i1:
	db KEY_RIGHT   ; Key
	db KEY_RIGHT   ; Include
	db $01         ; Min len
	db $FF         ; Max len
	
MoveInput_BDF:
	db $03         ; Number of inputs
.i3:
	db KEY_LEFT    ; Key
	db KEY_LEFT    ; Include
	db $01         ; Min len
	db $14         ; Max len
.i2:
	db KEY_DOWN    ; Key
	db KEY_DOWN    ; Include
	db $01         ; Min len
	db $0A         ; Max len
.i1:
	db KEY_RIGHT   ; Key
	db KEY_RIGHT   ; Include
	db $01         ; Min len
	db $FF         ; Max len
	
MoveInput_BFDB:
	db $04         ; Number of inputs
.i4:
	db KEY_RIGHT   ; Key
	db KEY_RIGHT   ; Include
	db $01         ; Min len
	db $14         ; Max len
.i3:
	db KEY_DOWN    ; Key
	db KEY_DOWN    ; Include
	db $01         ; Min len
	db $0A         ; Max len
.i2:
	db KEY_LEFT    ; Key
	db KEY_LEFT    ; Include
	db $01         ; Min len
	db $0A         ; Max len
.i1:
	db KEY_RIGHT   ; Key
	db KEY_RIGHT   ; Include
	db $01         ; Min len
	db $FF         ; Max len
	
MoveInput_BDB:
	db $03         ; Number of inputs
.i3:
	db KEY_RIGHT   ; Key
	db KEY_RIGHT   ; Include
	db $01         ; Min len
	db $14         ; Max len
.i2:
	db KEY_DOWN    ; Key
	db KEY_DOWN    ; Include
	db $01         ; Min len
	db $0A         ; Max len
.i1:
	db KEY_RIGHT   ; Key
	db KEY_RIGHT   ; Include
	db $01         ; Min len
	db $FF         ; Max len
	
MoveInput_BFDBF:
	db $05         ; Number of inputs
.i5:
	db KEY_LEFT    ; Key
	db KEY_LEFT    ; Include
	db $01         ; Min len
	db $14         ; Max len
.i4:
	db KEY_RIGHT   ; Key
	db KEY_RIGHT   ; Include
	db $01         ; Min len
	db $0A         ; Max len
.i3:
	db KEY_DOWN    ; Key
	db KEY_DOWN    ; Include
	db $01         ; Min len
	db $0A         ; Max len
.i2:
	db KEY_LEFT    ; Key
	db KEY_LEFT    ; Include
	db $01         ; Min len
	db $0A         ; Max len
.i1:
	db KEY_RIGHT   ; Key
	db KEY_RIGHT   ; Include
	db $01         ; Min len
	db $FF         ; Max len
	
MoveInput_PPP:
	db $06         ; Number of inputs
.i6:
	db KEY_B       ; Key
	db KEY_B       ; Include
	db $01         ; Min len
	db $08         ; Max len
.i5:
	db KEY_NONE    ; Key
	db KEY_B       ; Include
	db $01         ; Min len
	db $08         ; Max len
.i4:
	db KEY_B       ; Key
	db KEY_B       ; Include
	db $01         ; Min len
	db $08        ; Max len
.i3:
	db KEY_NONE    ; Key
	db KEY_B       ; Include
	db $01         ; Min len
	db $08         ; Max len
.i2:
	db KEY_B       ; Key
	db KEY_B       ; Include
	db $01         ; Min len
	db $08         ; Max len
.i1:
	db KEY_NONE    ; Key
	db KEY_B       ; Include
	db $01         ; Min len
	db $08         ; Max len
	
MoveInput_BB:
	db $04         ; Number of inputs
.i4:
	db KEY_RIGHT   ; Key
	db KEY_RIGHT|KEY_LEFT|KEY_UP|KEY_DOWN ; Include
	db $01         ; Min len
	db $08         ; Max len
.i3:
	db KEY_NONE    ; Key
	db KEY_RIGHT|KEY_LEFT|KEY_UP|KEY_DOWN ; Include
	db $01         ; Min len
	db $08         ; Max len
.i2:
	db KEY_RIGHT   ; Key
	db KEY_RIGHT|KEY_LEFT|KEY_UP|KEY_DOWN ; Include
	db $01         ; Min len
	db $08         ; Max len
.i1:
	db KEY_NONE    ; Key
	db KEY_RIGHT|KEY_LEFT|KEY_UP|KEY_DOWN ; Include
	db $01         ; Min len
	db $FF         ; Max len
	
MoveInput_FF:
	db $04         ; Number of inputs
.i4:
	db KEY_LEFT    ; Key
	db KEY_RIGHT|KEY_LEFT|KEY_UP|KEY_DOWN ; Include
	db $01         ; Min len
	db $08         ; Max len
.i3:
	db KEY_NONE    ; Key
	db KEY_RIGHT|KEY_LEFT|KEY_UP|KEY_DOWN ; Include
	db $01         ; Min len
	db $08         ; Max len
.i2:
	db KEY_LEFT    ; Key
	db KEY_RIGHT|KEY_LEFT|KEY_UP|KEY_DOWN ; Include
	db $01         ; Min len
	db $08         ; Max len
.i1:
	db KEY_NONE    ; Key
	db KEY_RIGHT|KEY_LEFT|KEY_UP|KEY_DOWN ; Include
	db $01         ; Min len
	db $FF         ; Max len
	
MoveInput_DU_Fast:
	db $02         ; Number of inputs
.i2:
	db KEY_UP      ; Key
	db KEY_UP      ; Include
	db $01         ; Min len
	db $14         ; Max len
.i1:
	db KEY_DOWN    ; Key
	db KEY_DOWN    ; Include
	db $01         ; Min len
	db $FF         ; Max len
; =============== END OF BANK ===============
; Junk area below.
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
