SGBPacket_FreezeScreen:
	pkg SGB_PACKET_MASK_EN, $01
	db $01
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	
SGBPacket_ResumeScreen:
	pkg SGB_PACKET_MASK_EN, $01
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00

SGBPacket_DisableMultiJoy: 
	pkg SGB_PACKET_MLT_REG, $01
	db $00 ; No multicontroller
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00

SGBPacket_EnableMultiJoy_1Pl: 
	pkg SGB_PACKET_MLT_REG, $01
	db $01 ; Enable multicontroller, one player
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00

L044040: db $89;X
L044041: db $03;X
L044042: db $00;X
L044043: db $00;X
L044044: db $00;X
L044045: db $00;X
L044046: db $00;X
L044047: db $00;X
L044048: db $00;X
L044049: db $00;X
L04404A: db $00;X
L04404B: db $00;X
L04404C: db $00;X
L04404D: db $00;X
L04404E: db $00;X
L04404F: db $00;X

SGBPacket_Unknown_SNESWrite7:
	pkg SGB_PACKET_DATA_SND, $01
	dw $085D ; SNES Destination - Ptr
	db $00 ; SNES Destination - Bank
	db $0B ; Write $0B bytes
	db $8C,$D0,$F4,$60,$00,$00,$00,$00,$00,$00,$00 ; Byte sequence
SGBPacket_Unknown_SNESWrite6:
	pkg SGB_PACKET_DATA_SND, $01
	dw $0852 ; SNES Destination - Ptr
	db $00 ; SNES Destination - Bank
	db $0B ; Write $0B bytes
	db $A9,$E7,$9F,$01,$C0,$7E,$E8,$E8,$E8,$E8,$E0 ; Byte sequence
SGBPacket_Unknown_SNESWrite5:
	pkg SGB_PACKET_DATA_SND, $01
	dw $0847 ; SNES Destination - Ptr
	db $00 ; SNES Destination - Bank
	db $0B ; Write $0B bytes
	db $C4,$D0,$16,$A5,$CB,$C9,$05,$D0,$10,$A2,$28 ; Byte sequence
SGBPacket_Unknown_SNESWrite4:
	pkg SGB_PACKET_DATA_SND, $01
	dw $083C ; SNES Destination - Ptr
	db $00 ; SNES Destination - Bank
	db $0B ; Write $0B bytes
	db $F0,$12,$A5,$C9,$C9,$C8,$D0,$1C,$A5,$CA,$C9 ; Byte sequence
SGBPacket_Unknown_SNESWrite3:
	pkg SGB_PACKET_DATA_SND, $01
	dw $0831 ; SNES Destination - Ptr
	db $00 ; SNES Destination - Bank
	db $0B ; Write $0B bytes
	db $0C,$A5,$CA,$C9,$7E,$D0,$06,$A5,$CB,$C9,$7E ; Byte sequence
SGBPacket_Unknown_SNESWrite2:
	pkg SGB_PACKET_DATA_SND, $01
	dw $0826 ; SNES Destination - Ptr
	db $00 ; SNES Destination - Bank
	db $0B ; Write $0B bytes
	db $39,$CD,$48,$0C,$D0,$34,$A5,$C9,$C9,$80,$D0 ; Byte sequence
SGBPacket_Unknown_SNESWrite1:
	pkg SGB_PACKET_DATA_SND, $01
	dw $081B ; SNES Destination - Ptr
	db $00 ; SNES Destination - Bank
	db $0B ; Write $0B bytes
	db $EA,$EA,$EA,$EA,$EA,$A9,$01,$CD,$4F,$0C,$D0 ; Byte sequence
SGBPacket_Unknown_SNESWrite0:
	pkg SGB_PACKET_DATA_SND, $01
	dw $0810 ; SNES Destination - Ptr
	db $00 ; SNES Destination - Bank
	db $0B ; Write $0B bytes
	db $4C,$20,$08,$EA,$EA,$EA,$EA,$EA,$60,$EA,$EA ; Byte sequence

; =============== SGB_ApplyScreenPalSet ===============
; Applies the SGB palette and color attributes for screens.
; IN
; - DE: Screen Palette ID
SGB_ApplyScreenPalSet:
	;
	; ??? Prepare the display for SGB packet transfer.
	;
	ldh  a, [rIE]				; Save interrupt value
	push af
		xor  a					; Disable all interrupts
		ldh  [rIE], a
		push de
			; Black out screen
			ld   a, $FF			
			ldh  [rBGP], a
			ldh  [rOBP0], a
			ldh  [rOBP1], a
			; Wait for VBLANK
			; Enable LCD otherwise the LCD stop function will not wait for VBlank
			ldh  a, [rLCDC]		
			or   a, LCDC_ENABLE
			ldh  [rLCDC], a
			; Wait 4 ticks
			ld   bc, $0004
			call SGB_DelayAfterPacketSendCustom
			; Stop LCD + wait VBlanl
			rst  $10
		pop  de
		
		;
		; Index the packet ptr table with DE
		;
		ld   hl, .setTbl	; HL = Ptr to table start
		sla  e				; DE * 8 = Offset
		rl   d
		sla  e
		rl   d
		sla  e
		rl   d
		add  hl, de			; Seek to table entry
		
		;
		; Send out packet #1 (bytes 0-1)
		; Packet #1 is always present, and sets SGB palette entries 0 and 1.
		;
		ld   e, [hl]		; DE = Ptr to packet
		inc  hl
		ld   d, [hl]
		inc  hl
		push hl				
			push de			; HL = DE
			pop  hl
			call SGB_SendPackets
			ld   bc, $0004
			call SGB_DelayAfterPacketSendCustom
		pop  hl
		
		;
		; Send out packet #2 (bytes 2-3)
		;
		; Packet #2 is optional, and sets SGB palette entries 2 and 3.
		; If the ptr is null, skip it.
		ld   e, [hl]		; DE = Ptr to packet
		inc  hl
		ld   d, [hl]
		inc  hl
		ld   a, d			; DE == 0?
		or   e
		jp   z, .sendPak3	; If so, skip
		push hl
			push de			; HL = DE
			pop  hl
			call SGB_SendPackets
			ld   bc, $0004
			call SGB_DelayAfterPacketSendCustom
		pop  hl
		
	.sendPak3:
		;
		; Send out packet #3 (bytes 4-5)
		;
		; Packet #3 is always present, and sets color palette attributes.
		ld   e, [hl]
		inc  hl
		ld   d, [hl]
		inc  hl
		push hl
			push de
			pop  hl
			call SGB_SendPackets
			ld   bc, $0004
			call SGB_DelayAfterPacketSendCustom
		pop  hl
		
		
	pop  af
	ldh  [rIE], a
	ret 

; =============== .setTbl ===============
; Defines the screen palette sets
.setTbl:
	;; PAL01                            PAL23                       ATTR                      END
	dw SGBPacket_Intro_Pal01,           $0000,                      SGBPacket_Pat_AllPal0,    $0000
	dw SGBPacket_TakaraLogo_Pal01,      $0000,                      SGBPacket_Pat_AllPal0,    $0000
	dw SGBPacket_Title_Pal01,           SGBPacket_Title_Pal23,      SGBPacket_Title_Pat,      $0000
	dw SGBPacket_CharSelect_Pal01,      SGBPacket_CharSelect_Pal23, SGBPacket_CharSelect_Pat, $0000
	dw SGBPacket_OrderSelect_Pal01,     $0000,                      SGBPacket_Pat_AllPal0,    $0000
	dw SGBPacket_StageClear_Pal01,      $0000,                      SGBPacket_Pat_AllPal0,    $0000
	dw SGBPacket_Stage_Hero_Pal01,      SGBPacket_StageMeter_Pal23, SGBPacket_Stage_Pat,      $0000
	dw SGBPacket_Stage_FatalFury_Pal01, SGBPacket_StageMeter_Pal23, SGBPacket_Stage_Pat,      $0000
	dw SGBPacket_Stage_Yagami_Pal01,    SGBPacket_StageMeter_Pal23, SGBPacket_Stage_Pat,      $0000
	dw SGBPacket_Stage_Boss_Pal01,      SGBPacket_StageMeter_Pal23, SGBPacket_Stage_Pat,      $0000
	dw SGBPacket_Stage_Stadium_Pal01,   SGBPacket_StageMeter_Pal23, SGBPacket_Stage_Pat,      $0000
	
SGBPacket_Intro_Pal01: 
	pkg SGB_PACKET_PAL01, $01
	dw $7FFF ; 0-0
	dw $021C ; 0-1
	dw $109C ; 0-2
	dw $0000 ; 0-3
	dw $0000 ; 1-1
	dw $0000 ; 1-2
	dw $0000 ; 1-3
	db $00

SGBPacket_TakaraLogo_Pal01:
	pkg SGB_PACKET_PAL01, $01
	dw $7FFF ; 0-0
	dw $4210 ; 0-1
	dw $2108 ; 0-2
	dw $0000 ; 0-3
	dw $0000 ; 1-1
	dw $0000 ; 1-2
	dw $0000 ; 1-3
	db $00

SGBPacket_Title_Pal01:
	pkg SGB_PACKET_PAL01, $01
	dw $7BDE ; 0-0
	dw $02FC ; 0-1
	dw $0098 ; 0-2
	dw $1807 ; 0-3
	dw $7300 ; 1-1
	dw $6180 ; 1-2
	dw $1807 ; 1-3
	db $00
SGBPacket_Title_Pal23:
	pkg SGB_PACKET_PAL23, $01
	dw $7BDE ; 0-0
	dw $029C ; 2-1
	dw $6180 ; 2-2
	dw $1807 ; 2-3
	dw $0198 ; 3-1
	dw $0010 ; 3-2
	dw $1807 ; 3-3
	db $00
	
SGBPacket_CharSelect_Pal01:
	pkg SGB_PACKET_PAL01, $01
	dw $739C ; 0-0
	dw $129C ; 0-1
	dw $109C ; 0-2
	dw $1000 ; 0-3
	dw $129C ; 1-1
	dw $7080 ; 1-2
	dw $1000 ; 1-3
	db $00
SGBPacket_CharSelect_Pal23: 
	pkg SGB_PACKET_PAL23, $01
	dw $739C ; 0-0
	dw $129C ; 2-1
	dw $7180 ; 2-2
	dw $1000 ; 2-3
	dw $129C ; 3-1
	dw $5014 ; 3-2
	dw $1000 ; 3-3
	db $00

SGBPacket_OrderSelect_Pal01: 
	pkg SGB_PACKET_PAL01, $01
	dw $7FFF ; 0-0
	dw $1810 ; 0-1
	dw $021C ; 0-2
	dw $0000 ; 0-3
	dw $0000 ; 1-1
	dw $0000 ; 1-2
	dw $0000 ; 1-3
	db $00
	
SGBPacket_StageClear_Pal01: 
	pkg SGB_PACKET_PAL01, $01
	dw $739C ; 0-0
	dw $3200 ; 0-1
	dw $2180 ; 0-2
	dw $0000 ; 0-3
	dw $0000 ; 1-1
	dw $0000 ; 1-2
	dw $0000 ; 1-3
	db $00

; Stage palettes 2-3, shared on every stage, used for the super meter
SGBPacket_StageMeter_Pal23:
	pkg SGB_PACKET_PAL23, $01
	dw $6B9E ; 0-0
	dw $7E00 ; 2-1
	dw $3C00 ; 2-2
	dw $0000 ; 2-3
	dw $03FF ; 3-1
	dw $01EF ; 3-2
	dw $0000 ; 3-3
	db $00
	
; Stage-specific palettes 0-1
; [TCRF]/[BUG] SGBPacket_StageMeter_Pal23 is applied later than these, and overwrites the stage-specific color 0-0 to be always $6B9E.
;              This renders unused the other 0-0 colors, though they are all similar to each other.
;              To fix this, apply SGBPacket_StageMeter_Pal23 before these.
SGBPacket_Stage_Hero_Pal01: 
	pkg SGB_PACKET_PAL01, $01
	dw $6B9E ; 0-0
	dw $02FF ; 0-1
	dw $109C ; 0-2
	dw $0000 ; 0-3
	dw $2280 ; 1-1
	dw $5100 ; 1-2
	dw $0000 ; 1-3
	db $00
	
SGBPacket_Stage_FatalFury_Pal01: 
	pkg SGB_PACKET_PAL01, $01
	dw $739C ; 0-0
	dw $02FF ; 0-1
	dw $109C ; 0-2
	dw $0000 ; 0-3
	dw $229C ; 1-1
	dw $5014 ; 1-2
	dw $0000 ; 1-3
	db $00
	
SGBPacket_Stage_Yagami_Pal01: 
	pkg SGB_PACKET_PAL01, $01
	dw $739C ; 0-0
	dw $02FF ; 0-1
	dw $109C ; 0-2
	dw $0000 ; 0-3
	dw $4284 ; 1-1
	dw $5000 ; 1-2
	dw $0000 ; 1-3
	db $00
	
SGBPacket_Stage_Boss_Pal01: 
	pkg SGB_PACKET_PAL01, $01
	dw $635C ; 0-0
	dw $02FF ; 0-1
	dw $109C ; 0-2
	dw $0000 ; 0-3
	dw $4E44 ; 1-1
	dw $4C63 ; 1-2
	dw $0000 ; 1-3
	db $00
	
SGBPacket_Stage_Stadium_Pal01: 
	pkg SGB_PACKET_PAL01, $01
	dw $7BDE ; 0-0
	dw $02FF ; 0-1
	dw $109C ; 0-2
	dw $0000 ; 0-3
	dw $029C ; 1-1
	dw $1200 ; 1-2
	dw $0000 ; 1-3
	db $00

; Palette map which sets Pal01 to the entire screen
SGBPacket_Pat_AllPal0: 
	pkg SGB_PACKET_ATTR_BLK, $01
	db $01	; 1 Set
	;--
	db %00000011 ; Change inside/box border
	ads 0,0,0 ; Pals
	db $00 ; X1
	db $00 ; Y1
	db $13 ; X2
	db $11 ; Y2
	;--
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	
SGBPacket_CharSelect_Pat:
	pkg SGB_PACKET_ATTR_BLK, $02
	db $04	; 4 Sets
	;--
	; Base red palette
	db %00000011 ; Change inside/box border
	ads 0,0,0 ; Pals
	db $00 ; X1
	db $00 ; Y1
	db $13 ; X2
	db $11 ; Y2
	;--
	; Color Robert + Goenitz dark blue
	db %00000011 ; Change inside/box border
	ads 1,1,1 ; Pals
	db $0D ; X1
	db $03 ; Y1
	db $0F ; X2
	db $0B ; Y2
	;--
	; Color Leona blue
	db %00000011 ; Change inside/box border
	ads 2,2,2 ; Pals
	db $10 ; X1
	db $09 ; Y1
	db $12 ; X2
	db $0B ; Y2
	;--
	; Color Krauser purple
	db %00000011 ; Change inside/box border
	ads 3,3,3 ; Pals
	db $0D ; X1
	db $06 ; Y1
	db $0F ; X2
	db $08 ; Y2
	;--
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
; =============== START OF JUNK ===============
L0442A1: db $00;X
L0442A2: db $00;X
L0442A3: db $00;X
L0442A4: db $00;X
L0442A5: db $00;X
L0442A6: db $00;X
L0442A7: db $00;X
L0442A8: db $00;X
; =============== END OF JUNK ===============
SGBPacket_Title_Pat: 
	pkg SGB_PACKET_ATTR_BLK, $04
	db $09 ; 9 sets
	;--
	; Fill with red palette
	db %00000011 ; Change inside/box border
	ads 0,0,0 ; Pals
	db $00 ; X1
	db $00 ; Y1
	db $13 ; X2
	db $11 ; Y2
	;--
	; Brown clouds at the bottom
	db %00000011 ; Change inside/box border
	ads 3,3,0 ; Pals
	db $00 ; X1
	db $0E ; Y1
	db $13 ; X2
	db $11 ; Y2
	;--
	; Color blue the lower right section of 96
	db %00000011 ; Change inside/box border
	ads 1,1,1 ; Pals
	db $10 ; X1
	db $06 ; Y1
	db $13 ; X2
	db $0C ; Y2
	;--
	; Color blue the top section of 96
	db %00000010 ; Change box border
	ads 1,1,1 ; Pals
	db $0E ; X1
	db $04 ; Y1
	db $11 ; X2
	db $05 ; Y2
	;--
	; Color blue the middle of 96
	db %00000010 ; Change box border
	ads 1,1,1 ; Pals
	db $0F ; X1
	db $07 ; Y1
	db $0F ; X2
	db $0C ; Y2
	;--
	; Color blue the middle of 96
	db %00000010 ; Change box border
	ads 1,1,1 ; Pals
	db $0E ; X1
	db $07 ; Y1
	db $0E ; X2
	db $0A ; Y2
	;--
	; Color blue the lower left of 96
	db %00000010 ; Change box border
	ads 1,1,1 ; Pals
	db $0C ; X1
	db $09 ; Y1
	db $0D ; X2
	db $0A ; Y2
	;--
	; Color blue the lower left edge of 96
	db %00000010 ; Change box border
	ads 1,1,1 ; Pals
	db $0A ; X1
	db $0A ; Y1
	db $0B ; X2
	db $0A ; Y2
	;--
	; Set a special mixed palette to a single tile to get around palette limitations
	db %00000010 ; Change box border
	ads 2,2,2 ; Pals
	db $11 ; X1
	db $06 ; Y1
	db $11 ; X2
	db $06 ; Y2
	;--
	db $00;X
	db $00;X
	db $00;X
	db $00;X
	db $00;X
	db $00;X
	db $00;X
	db $00;X
; =============== START OF JUNK ===============
L0442E9: db $00;X
L0442EA: db $00;X
L0442EB: db $00;X
L0442EC: db $00;X
L0442ED: db $00;X
L0442EE: db $00;X
; =============== END OF JUNK ===============
SGBPacket_Stage_Pat:
	pkg SGB_PACKET_ATTR_BLK, $03
	db $06 ; 6 sets
	;--
	db %00000010 ; Change box border
	ads 0,0,0 ; Pals
	db $00 ; X1
	db $00 ; Y1
	db $13 ; X2
	db $00 ; Y2
	;--
	db %00000011 ; Change inside/box border
	ads 0,0,0 ; Pals
	db $00 ; X1
	db $01 ; Y1
	db $13 ; X2
	db $03 ; Y2
	;--
	db %00000010 ; Change box border
	ads 2,2,2 ; Pals
	db $05 ; X1
	db $03 ; Y1
	db $0E ; X2
	db $03 ; Y2
	;--
	db %00000011 ; Change inside/box border
	ads 1,1,1 ; Pals
	db $00 ; X1
	db $04 ; Y1
	db $13 ; X2
	db $0F ; Y2
	;--
	db %00000010 ; Change box border
	ads 3,3,3 ; Pals
	db $00 ; X1
	db $10 ; Y1
	db $13 ; X2
	db $10 ; Y2
	;--
	db %00000010 ; Change box border
	ads 2,2,2 ; Pals
	db $00 ; X1
	db $11 ; Y1
	db $13 ; X2
	db $11 ; Y2
	;--
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00

L04431F: db $00;X
L044320: db $00;X
L044321: db $21;X
L044322: db $01;X
L044323: db $03;X
L044324: db $15;X
L044325: db $07;X
L044326: db $03;X
L044327: db $0C;X
L044328: db $08;X
L044329: db $00;X
L04432A: db $00;X
L04432B: db $00;X
L04432C: db $00;X
L04432D: db $00;X
L04432E: db $00;X
L04432F: db $00;X
L044330: db $00;X
L044331: db $21;X
L044332: db $01;X
L044333: db $03;X
L044334: db $2A;X
L044335: db $01;X
L044336: db $03;X
L044337: db $06;X
L044338: db $08;X
L044339: db $00;X
L04433A: db $00;X
L04433B: db $00;X
L04433C: db $00;X
L04433D: db $00;X
L04433E: db $00;X
L04433F: db $00;X
L044340: db $00;X
L044341: db $21;X
L044342: db $01;X
L044343: db $03;X
L044344: db $3F;X
L044345: db $0D;X
L044346: db $03;X
L044347: db $12;X
L044348: db $08;X
L044349: db $00;X
L04434A: db $00;X
L04434B: db $00;X
L04434C: db $00;X
L04434D: db $00;X
L04434E: db $00;X
L04434F: db $00;X
L044350: db $00;X

; =============== SGB_SGB_SendBorderData ===============
SGB_SendBorderData:

	; The border tiles need to be sent to the SGB side through VRAM.
	; That leaves us with a $1000 byte buffer to store uncompressed data ($8800-$9800),
	; meaning that large chunks of graphics (like the 4bpp border tiles) are split in two LZSS archives.
	

	;
	; Transfer the first part of border tiles
	;
	ld   hl, GFXLZ_SGB_Border0
	ld   de, wLZSS_Buffer+$0A
	call DecompressLZSS
	ld   hl, wLZSS_Buffer+$0A
	ld   de, SGBPacket_CopyBorderTiles0
	call SGB_SendBlock4KB
	ld   bc, $0010
	call SGB_SendBorderData_WaitAfterSend
	
	;
	; Transfer the second part of border tiles
	;
	ld   hl, GFXLZ_SGB_Border1
	ld   de, wLZSS_Buffer+$0A
	call DecompressLZSS
	ld   hl, wLZSS_Buffer+$0A
	ld   de, SGBPacket_CopyBorderTiles1
	call SGB_SendBlock4KB
	ld   bc, $0010
	call SGB_SendBorderData_WaitAfterSend
	
	;
	; Transfer the border tilemap and proper palette.
	; This requires the uncompressed data to be stored this way:
	; - $0000-$06FF: Tilemap
	; - $0800-$087F: Palette data
	;
	
	; The tilemap is the always the same
	ld   hl, BGLZ_SGB_Border
	ld   de, wLZSS_Buffer+$0A 				; At $0000
	call DecompressLZSS
	
	; The palette changes depending on the border type,
	ld   a, [wSGBBorderType]
	cp   a, BORDER_MAIN			; Using the normal border?
	jp   z, .norm				; If so, jump
	cp   a, BORDER_ALTERNATE	; Using the alternate border?
	jp   z, .alt				; If so, jump
	; ... huh
.norm:
	ld   hl, SGBPalDef_Border_Normal	; HL = Ptr to $80 byte palette data
	jr   .copyBG
.alt:
	ld   hl, SGBPalDef_Border_Alt		; HL = Ptr to $80 byte palette data
.copyBG:
	; The first word of the SGBPalDef structure is the byte count, which is always $60 here.
	; Read it out to BC, and use it for SGB_SendBorderData_CopyBytes.
	ld   c, [hl]					
	inc  hl
	ld   b, [hl]					
	inc  hl
	; The data to copy over is right after the byte count
	ld   de, wLZSS_Buffer+$0A+$800 			; At $0800
	call SGB_SendBorderData_CopyBytes
	
	; Transfer everything in the buffer to the SGB
	ld   hl, wLZSS_Buffer+$0A
	ld   de, SGBPacket_CopyBorderTilemap	; PCT_TRN
	call SGB_SendBlock4KB					; Now send the data as normal
	
	ld   bc, $0010
	call SGB_SendBorderData_WaitAfterSend
	
	;
	; Attempt to erase the GFX area we've used for the transfers.
	; [BUG] Not only this is pointless, but it's done while the display is enabled,
	;       causing VRAM inaccessibility issues and so the tiles get striped.
	;       If you want to fix this for some reason, move "rst $10" above this loop.
	;
	ld   hl, $8800		; HL = Starting address
	ld   bc, $1000		; BC = Bytes left
	xor  a				; A = Clear with
.clrLoop:
	xor  a
	ldi  [hl], a		; Clear byte
	dec  bc
	ld   a, b
	or   c				; Are we done?
	jr   nz, .clrLoop	; If not, loop
	;-----------------------------------
	rst  $10			; Stop LCD
	ret
	
SGBPacket_CopyBorderTiles0:
	pkg SGB_PACKET_CHR_TRN, $01
	db $00 ; Transfer tiles $00-$7F
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
;--
L0443D8: db $00;X
L0443D9: db $00;X
;--
SGBPacket_CopyBorderTiles1:
	pkg SGB_PACKET_CHR_TRN, $01
	db $01  ; Transfer tiles $80-$FF
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
;--
L0443EA: db $00;X
L0443EB: db $00;X
;--
SGBPacket_CopyBorderTilemap:
	pkg SGB_PACKET_PCT_TRN, $01
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
;--
L0443FB: db $00;X
L0443FC: db $00;X
; =============== SGB_SendBlock4KB ===============
; Sends a 4KB block of uncompressed data to the SGB by transferring it through the screen.
;
; IN
; - HL: Ptr to uncompressed data
; - DE: Ptr to SGB packet which uses this transfer method
SGB_SendBlock4KB:
	di   
	push de						; Save SGB packet ptr
		;-----------------------------------
		rst  $10				; Stop LCD
		ld   a, $E4				; Required palette for screen tranfer
		ldh  [rBGP], a
		
		;
		; Copy the data to the VRAM tiles area
		;
		ld   de, $8800			; Start from 2nd tiles block
		ld   bc, $1000			; Overwrite blocks 2 and 3
		call SGB_SendBorderData_CopyBytes
		
		;
		; Generate a tilemap where every single tile is visible on-screen, in order,
		; starting from the top left corner.
		; The screen coords should be set to 0 when we get here.
		; 
		; The SNES has access to the rendered frame from its GFX area, so all it needs to do
		; is reading that as the sent data.
		; As a result, anything that isn't visible on screen isn't accessible by the SNES.
		; 
		
		ld   hl, $9800					; HL = Tilemap start
		ld   de, BG_TILECOUNT_H-$14		; DE = Bytes to seek to the start of the next row
		ld   a, $80						; A = Starting Tile ID (points to tile at $8800)
		ld   c, $0D						; C = Min number of rows required to draw all tiles
	.vLoop:
		ld   b, $14						; B = Visible tiles in a row
	.rowLoop:
		ldi  [hl], a			; Write Tile Id to tilemap, TilemapPtr++
		inc  a					; TileId++
		dec  b					; TilesLeft--
		jr   nz, .rowLoop		; Written the row? If not, loop
		add  hl, de				; Move down 1 tile, at the start of the next row
		dec  c					; RowsLeft--
		jr   nz, .vLoop			; Written all rows
		
		
		; Enable screen without OBJ or WINDOW 
		ld   a, LCDC_PRIORITY|LCDC_ENABLE
		ldh  [rLCDC], a
		; Make sure the SGB is ready
		ld   bc, $0005
		call SGB_SendBorderData_WaitAfterSend
		
	; Now that the screen is set up, execute the transfer
	pop  hl						; HL = SGB Packet ptr
	call SGB_SendPackets
	ld   bc, $0006
	call SGB_SendBorderData_WaitAfterSend
	
	; We're done
	ei   
	ret  
	
; =============== SGB_SendBorderData_CopyBytes ===============
; Generic loop for copying data.
; - HL: Ptr to source uncompressed data
; - DE: Ptr to destination
; - BC: Bytes to copy
SGB_SendBorderData_CopyBytes:
	ldi  a, [hl]		; Read from source, SrcPtr++
	ld   [de], a		; Copy to destination
	inc  de				; DestPtr++
	dec  bc				; BytesLeft--
	ld   a, b
	or   c				; Are we done?
	jr   nz, SGB_SendBorderData_CopyBytes	; If not, loop
	ret  
	
; =============== SGB_SendBorderData_WaitAfterSend ===============
; Waits for a multiple of $06D6 frames after a packet is sent.
; IN
; - BC: Wait multiplier
SGB_SendBorderData_WaitAfterSend:
	ld   de, $06D6			; DE = LoopsLeft
.wait:
	nop  					; Waste some cycles
	nop  
	nop  
	dec  de					; DE--
	ld   a, d
	or   e					; DE == 0?
	jr   nz, .wait			; If not, loop
	
	dec  bc					; BC--
	ld   a, b
	or   c					; BC == 0?
	jr   nz, SGB_SendBorderData_WaitAfterSend	; If not, loop
	ret
	
GFXLZ_SGB_Border0: INCBIN "data/gfx/sgb_border0.lzc"
GFXLZ_SGB_Border1: INCBIN "data/gfx/sgb_border1.lzc"
BGLZ_SGB_Border: INCBIN "data/bg/sgb_border.lzs"
SGBPalDef_Border_Normal:
	dw SGBPal_Border_Normal.end-SGBPal_Border_Normal ; $0060
SGBPal_Border_Normal:
	INCBIN "data/pal/sgb_border_normal.bin"
.end:
SGBPalDef_Border_Alt:
	dw SGBPal_Border_Alt.end-SGBPal_Border_Alt ; $0060
SGBPal_Border_Alt:
	INCBIN "data/pal/sgb_border_alt.bin"
.end:

L046318: db $74
L046319: db $40
L04631A: db $6E
L04631B: db $00
L04631C: db $07
L04631D: db $06
L04631E: db $FF
L04631F: db $07
L046320: db $07
L046321: db $03
L046322: db $80
L046323: db $35
L046324: db $E0
L046325: db $1F
L046326: db $0F
L046327: db $7C
L046328: db $0F
L046329: db $30
L04632A: db $EF
L04632B: db $09
L04632C: db $3D
L04632D: db $DF
L04632E: db $2F
L04632F: db $0B
L046330: db $7C
L046331: db $B0
L046332: db $0A
L046333: db $E5
L046334: db $1E
L046335: db $D5
L046336: db $FC
L046337: db $0A
L046338: db $23
L046339: db $08
L04633A: db $00
L04633B: db $08
L04633C: db $2A
L04633D: db $1A
L04633E: db $80
L04633F: db $07
L046340: db $F0
L046341: db $F9
L046342: db $F6
L046343: db $FB
L046344: db $F4
L046345: db $FC
L046346: db $E3
L046347: db $A0
L046348: db $6E
L046349: db $FE
L04634A: db $79
L04634B: db $F1
L04634C: db $8E
L04634D: db $81
L04634E: db $7E
L04634F: db $0F
L046350: db $81
L046351: db $28
L046352: db $E0
L046353: db $1F
L046354: db $83
L046355: db $7C
L046356: db $9F
L046357: db $60
L046358: db $B8
L046359: db $42
L04635A: db $03
L04635B: db $39
L04635C: db $8C
L04635D: db $73
L04635E: db $9C
L04635F: db $6F
L046360: db $09
L046361: db $7F
L046362: db $50
L046363: db $80
L046364: db $B8
L046365: db $0E
L046366: db $B9
L046367: db $19
L046368: db $E6
L046369: db $39
L04636A: db $DE
L04636B: db $B4
L04636C: db $09
L04636D: db $31
L04636E: db $08
L04636F: db $F9
L046370: db $FF
L046371: db $05
L046372: db $00
L046373: db $55
L046374: db $78
L046375: db $AA
L046376: db $00
L046377: db $10
L046378: db $29
L046379: db $3B
L04637A: db $BE
L04637B: db $41
L04637C: db $5F
L04637D: db $58
L04637E: db $AE
L04637F: db $18
L046380: db $4F
L046381: db $19
L046382: db $7D
L046383: db $97
L046384: db $6F
L046385: db $F0
L046386: db $B5
L046387: db $08
L046388: db $95
L046389: db $1A
L04638A: db $3F
L04638B: db $77
L04638C: db $A2
L04638D: db $DD
L04638E: db $1A
L04638F: db $AF
L046390: db $3F
L046391: db $22
L046392: db $22
L046393: db $88
L046394: db $62
L046395: db $3F
L046396: db $89
L046397: db $19
L046398: db $15
L046399: db $76
L04639A: db $BF
L04639B: db $6C
L04639C: db $08
L04639D: db $58
L04639E: db $08
L04639F: db $72
L0463A0: db $08
L0463A1: db $7A
L0463A2: db $66
L0463A3: db $08
L0463A4: db $6B
L0463A5: db $11
L0463A6: db $00
L0463A7: db $A8
L0463A8: db $08
L0463A9: db $9A
L0463AA: db $B5
L0463AB: db $0A
L0463AC: db $AA
L0463AD: db $3A
L0463AE: db $7D
L0463AF: db $88
L0463B0: db $08
L0463B1: db $BA
L0463B2: db $1A
L0463B3: db $59
L0463B4: db $BE
L0463B5: db $08
L0463B6: db $B8
L0463B7: db $7B
L0463B8: db $81
L0463B9: db $33
L0463BA: db $DD
L0463BB: db $A2
L0463BC: db $CA
L0463BD: db $BB
L0463BE: db $18
L0463BF: db $AA
L0463C0: db $55
L0463C1: db $18
L0463C2: db $01
L0463C3: db $08
L0463C4: db $FC
L0463C5: db $AB
L0463C6: db $08
L0463C7: db $8C
L0463C8: db $08
L0463C9: db $BC
L0463CA: db $1A
L0463CB: db $AC
L0463CC: db $1A
L0463CD: db $59
L0463CE: db $D1
L0463CF: db $FF
L0463D0: db $11
L0463D1: db $FE
L0463D2: db $08
L0463D3: db $02
L0463D4: db $AF
L0463D5: db $52
L0463D6: db $18
L0463D7: db $04
L0463D8: db $18
L0463D9: db $3F
L0463DA: db $CB
L0463DB: db $3E
L0463DC: db $C3
L0463DD: db $09
L0463DE: db $BE
L0463DF: db $43
L0463E0: db $D6
L0463E1: db $0D
L0463E2: db $78
L0463E3: db $FC
L0463E4: db $08
L0463E5: db $F0
L0463E6: db $0F
L0463E7: db $0C
L0463E8: db $00
L0463E9: db $EF
L0463EA: db $00
L0463EB: db $10
L0463EC: db $19
L0463ED: db $EE
L0463EE: db $10
L0463EF: db $0B
L0463F0: db $49
L0463F1: db $5B
L0463F2: db $C0
L0463F3: db $13
L0463F4: db $09
L0463F5: db $DA
L0463F6: db $25
L0463F7: db $D8
L0463F8: db $A7
L0463F9: db $C0
L0463FA: db $3F
L0463FB: db $90
L0463FC: db $63
L0463FD: db $9C
L0463FE: db $63
L0463FF: db $18
L046400: db $08
L046401: db $9E
L046402: db $6B
L046403: db $FE
L046404: db $7D
L046405: db $0B
L046406: db $08
L046407: db $18
L046408: db $48
L046409: db $0A
L04640A: db $79
L04640B: db $01
L04640C: db $40
L04640D: db $BE
L04640E: db $19
L04640F: db $EF
L046410: db $18
L046411: db $0B
L046412: db $49
L046413: db $5B
L046414: db $0A
L046415: db $14
L046416: db $AD
L046417: db $1A
L046418: db $50
L046419: db $1A
L04641A: db $44
L04641B: db $1A
L04641C: db $05
L04641D: db $07
L04641E: db $08
L04641F: db $65
L046420: db $57
L046421: db $1E
L046422: db $8A
L046423: db $DD
L046424: db $EE
L046425: db $10
L046426: db $CC
L046427: db $2F
L046428: db $82
L046429: db $00
L04642A: db $E0
L04642B: db $F0
L04642C: db $EF
L04642D: db $F3
L04642E: db $ED
L04642F: db $19
L046430: db $F7
L046431: db $13
L046432: db $08
L046433: db $B7
L046434: db $6B
L046435: db $08
L046436: db $6A
L046437: db $97
L046438: db $08
L046439: db $38
L04643A: db $19
L04643B: db $0A
L04643C: db $D7
L04643D: db $EA
L04643E: db $0F
L04643F: db $0B
L046440: db $55
L046441: db $AA
L046442: db $00
L046443: db $E9
L046444: db $10
L046445: db $1F
L046446: db $1B
L046447: db $57
L046448: db $10
L046449: db $AF
L04644A: db $52
L04644B: db $1F
L04644C: db $80
L04644D: db $1B
L04644E: db $F5
L04644F: db $0A
L046450: db $3E
L046451: db $C1
L046452: db $39
L046453: db $C6
L046454: db $3F
L046455: db $06
L046456: db $C0
L046457: db $B9
L046458: db $46
L046459: db $BF
L04645A: db $40
L04645B: db $1F
L04645C: db $08
L04645D: db $44
L04645E: db $CC
L04645F: db $0F
L046460: db $09
L046461: db $55
L046462: db $AA
L046463: db $00
L046464: db $10
L046465: db $FF
L046466: db $00
L046467: db $A8
L046468: db $0C
L046469: db $18
L04646A: db $08
L04646B: db $19
L04646C: db $29
L04646D: db $97
L04646E: db $6F
L04646F: db $F0
L046470: db $D5
L046471: db $08
L046472: db $7E
L046473: db $50
L046474: db $08
L046475: db $54
L046476: db $29
L046477: db $77
L046478: db $42
L046479: db $60
L04647A: db $DD
L04647B: db $1A
L04647C: db $39
L04647D: db $1E
L04647E: db $E1
L04647F: db $DB
L046480: db $ED
L046481: db $1A
L046482: db $A8
L046483: db $08
L046484: db $7B
L046485: db $1A
L046486: db $FB
L046487: db $08
L046488: db $FA
L046489: db $0D
L04648A: db $1B
L04648B: db $E6
L04648C: db $1A
L04648D: db $39
L04648E: db $59
L04648F: db $BE
L046490: db $43
L046491: db $0F
L046492: db $09
L046493: db $BF
L046494: db $54
L046495: db $42
L046496: db $08
L046497: db $40
L046498: db $0D
L046499: db $BD
L04649A: db $58
L04649B: db $BB
L04649C: db $46
L04649D: db $A1
L04649E: db $28
L04649F: db $44
L0464A0: db $0B
L0464A1: db $FE
L0464A2: db $01
L0464A3: db $D6
L0464A4: db $7D
L0464A5: db $19
L0464A6: db $0F
L0464A7: db $00
L0464A8: db $FF
L0464A9: db $14
L0464AA: db $EB
L0464AB: db $19
L0464AC: db $00
L0464AD: db $11
L0464AE: db $09
L0464AF: db $0D
L0464B0: db $3F
L0464B1: db $80
L0464B2: db $7F
L0464B3: db $55
L0464B4: db $20
L0464B5: db $10
L0464B6: db $C4
L0464B7: db $09
L0464B8: db $96
L0464B9: db $28
L0464BA: db $EE
L0464BB: db $BB
L0464BC: db $20
L0464BD: db $C0
L0464BE: db $68
L0464BF: db $50
L0464C0: db $F8
L0464C1: db $23
L0464C2: db $03
L0464C3: db $FC
L0464C4: db $48
L0464C5: db $FE
L0464C6: db $FD
L0464C7: db $46
L0464C8: db $09
L0464C9: db $79
L0464CA: db $58
L0464CB: db $B9
L0464CC: db $38
L0464CD: db $07
L0464CE: db $68
L0464CF: db $78
L0464D0: db $08
L0464D1: db $BF
L0464D2: db $6B
L0464D3: db $8E
L0464D4: db $80
L0464D5: db $0B
L0464D6: db $9F
L0464D7: db $68
L0464D8: db $19
L0464D9: db $48
L0464DA: db $38
L0464DB: db $9C
L0464DC: db $EF
L0464DD: db $08
L0464DE: db $69
L0464DF: db $08
L0464E0: db $00
L0464E1: db $08
L0464E2: db $14
L0464E3: db $1A
L0464E4: db $55
L0464E5: db $F3
L0464E6: db $89
L0464E7: db $0F
L0464E8: db $0D
L0464E9: db $88
L0464EA: db $C5
L0464EB: db $3A
L0464EC: db $0F
L0464ED: db $0B
L0464EE: db $F3
L0464EF: db $79
L0464F0: db $0F
L0464F1: db $0F
L0464F2: db $0E
L0464F3: db $6C
L0464F4: db $93
L0464F5: db $08
L0464F6: db $3B
L0464F7: db $26
L0464F8: db $F7
L0464F9: db $0A
L0464FA: db $08
L0464FB: db $EA
L0464FC: db $17
L0464FD: db $08
L0464FE: db $18
L0464FF: db $0B
L046500: db $82
L046501: db $18
L046502: db $E8
L046503: db $F0
L046504: db $EF
L046505: db $1F
L046506: db $E0
L046507: db $79
L046508: db $55
L046509: db $7F
L04650A: db $AA
L04650B: db $00
L04650C: db $10
L04650D: db $BA
L04650E: db $01
L04650F: db $18
L046510: db $22
L046511: db $FA
L046512: db $4A
L046513: db $57
L046514: db $70
L046515: db $AF
L046516: db $52
L046517: db $28
L046518: db $02
L046519: db $08
L04651A: db $FE
L04651B: db $92
L04651C: db $7F
L04651D: db $BF
L04651E: db $44
L04651F: db $0F
L046520: db $3F
L046521: db $C4
L046522: db $68
L046523: db $04
L046524: db $93
L046525: db $09
L046526: db $27
L046527: db $DC
L046528: db $19
L046529: db $8F
L04652A: db $74
L04652B: db $3F
L04652C: db $8A
L04652D: db $7B
L04652E: db $10
L04652F: db $08
L046530: db $C0
L046531: db $0A
L046532: db $29
L046533: db $00
L046534: db $0F
L046535: db $08
L046536: db $5F
L046537: db $30
L046538: db $08
L046539: db $78
L04653A: db $1A
L04653B: db $09
L04653C: db $4B
L04653D: db $0B
L04653E: db $03
L04653F: db $D7
L046540: db $4D
L046541: db $EB
L046542: db $20
L046543: db $08
L046544: db $F0
L046545: db $0A
L046546: db $29
L046547: db $5B
L046548: db $8B
L046549: db $0A
L04654A: db $7B
L04654B: db $ED
L04654C: db $1A
L04654D: db $08
L04654E: db $DB
L04654F: db $1A
L046550: db $3F
L046551: db $22
L046552: db $9F
L046553: db $60
L046554: db $98
L046555: db $0F
L046556: db $70
L046557: db $CF
L046558: db $18
L046559: db $E0
L04655A: db $82
L04655B: db $1A
L04655C: db $03
L04655D: db $FA
L04655E: db $05
L04655F: db $F9
L046560: db $46
L046561: db $28
L046562: db $00
L046563: db $88
L046564: db $08
L046565: db $83
L046566: db $76
L046567: db $99
L046568: db $18
L046569: db $38
L04656A: db $D6
L04656B: db $39
L04656C: db $84
L04656D: db $79
L04656E: db $F4
L04656F: db $1B
L046570: db $DB
L046571: db $24
L046572: db $7A
L046573: db $9F
L046574: db $B3
L046575: db $46
L046576: db $6C
L046577: db $18
L046578: db $60
L046579: db $E7
L04657A: db $5B
L04657B: db $18
L04657C: db $08
L04657D: db $E5
L04657E: db $B9
L04657F: db $08
L046580: db $DF
L046581: db $38
L046582: db $7A
L046583: db $00
L046584: db $80
L046585: db $7F
L046586: db $29
L046587: db $79
L046588: db $E0
L046589: db $A8
L04658A: db $B9
L04658B: db $60
L04658C: db $08
L04658D: db $BF
L04658E: db $40
L04658F: db $49
L046590: db $3F
L046591: db $55
L046592: db $AA
L046593: db $00
L046594: db $10
L046595: db $1B
L046596: db $C1
L046597: db $0B
L046598: db $17
L046599: db $BC
L04659A: db $F8
L04659B: db $5F
L04659C: db $18
L04659D: db $08
L04659E: db $1A
L04659F: db $F9
L0465A0: db $08
L0465A1: db $5D
L0465A2: db $93
L0465A3: db $D0
L0465A4: db $BE
L0465A5: db $49
L0465A6: db $1B
L0465A7: db $1C
L0465A8: db $EB
L0465A9: db $0B
L0465AA: db $C9
L0465AB: db $02
L0465AC: db $5B
L0465AD: db $BC
L0465AE: db $AD
L0465AF: db $5E
L0465B0: db $D7
L0465B1: db $6E
L0465B2: db $40
L0465B3: db $76
L0465B4: db $02
L0465B5: db $B5
L0465B6: db $7A
L0465B7: db $5A
L0465B8: db $BD
L0465B9: db $3C
L0465BA: db $C3
L0465BB: db $79
L0465BC: db $7F
L0465BD: db $94
L0465BE: db $D8
L0465BF: db $BF
L0465C0: db $55
L0465C1: db $18
L0465C2: db $95
L0465C3: db $18
L0465C4: db $4F
L0465C5: db $1F
L0465C6: db $47
L0465C7: db $EF
L0465C8: db $08
L0465C9: db $E8
L0465CA: db $1A
L0465CB: db $E7
L0465CC: db $79
L0465CD: db $60
L0465CE: db $78
L0465CF: db $CB
L0465D0: db $00
L0465D1: db $10
L0465D2: db $D5
L0465D3: db $2A
L0465D4: db $19
L0465D5: db $80
L0465D6: db $A0
L0465D7: db $0B
L0465D8: db $97
L0465D9: db $78
L0465DA: db $07
L0465DB: db $F6
L0465DC: db $B8
L0465DD: db $09
L0465DE: db $10
L0465DF: db $A9
L0465E0: db $08
L0465E1: db $05
L0465E2: db $51
L0465E3: db $EE
L0465E4: db $31
L0465E5: db $DF
L0465E6: db $60
L0465E7: db $28
L0465E8: db $40
L0465E9: db $49
L0465EA: db $04
L0465EB: db $FE
L0465EC: db $7D
L0465ED: db $03
L0465EE: db $FC
L0465EF: db $FD
L0465F0: db $10
L0465F1: db $C7
L0465F2: db $B8
L0465F3: db $8A
L0465F4: db $48
L0465F5: db $DB
L0465F6: db $5F
L0465F7: db $E6
L0465F8: db $18
L0465F9: db $25
L0465FA: db $79
L0465FB: db $3F
L0465FC: db $99
L0465FD: db $B0
L0465FE: db $E0
L0465FF: db $1F
L046600: db $48
L046601: db $10
L046602: db $F0
L046603: db $0F
L046604: db $48
L046605: db $00
L046606: db $6F
L046607: db $78
L046608: db $B7
L046609: db $7F
L04660A: db $D0
L04660B: db $D5
L04660C: db $2A
L04660D: db $EE
L04660E: db $54
L04660F: db $11
L046610: db $80
L046611: db $26
L046612: db $18
L046613: db $17
L046614: db $19
L046615: db $EA
L046616: db $15
L046617: db $C8
L046618: db $D9
L046619: db $09
L04661A: db $FB
L04661B: db $04
L04661C: db $18
L04661D: db $42
L04661E: db $FD
L04661F: db $06
L046620: db $88
L046621: db $28
L046622: db $4D
L046623: db $F6
L046624: db $0B
L046625: db $29
L046626: db $5B
L046627: db $AC
L046628: db $55
L046629: db $75
L04662A: db $AB
L04662B: db $C8
L04662C: db $10
L04662D: db $78
L04662E: db $14
L04662F: db $48
L046630: db $5A
L046631: db $18
L046632: db $81
L046633: db $08
L046634: db $BF
L046635: db $44
L046636: db $F7
L046637: db $29
L046638: db $A2
L046639: db $5D
L04663A: db $F9
L04663B: db $0F
L04663C: db $5F
L04663D: db $A0
L04663E: db $50
L04663F: db $AF
L046640: db $09
L046641: db $A0
L046642: db $08
L046643: db $80
L046644: db $D5
L046645: db $08
L046646: db $58
L046647: db $0F
L046648: db $58
L046649: db $B7
L04664A: db $18
L04664B: db $43
L04664C: db $08
L04664D: db $11
L04664E: db $28
L04664F: db $7C
L046650: db $AB
L046651: db $09
L046652: db $7D
L046653: db $83
L046654: db $FE
L046655: db $18
L046656: db $F0
L046657: db $48
L046658: db $09
L046659: db $28
L04665A: db $08
L04665B: db $01
L04665C: db $E5
L04665D: db $5B
L04665E: db $CB
L04665F: db $00
L046660: db $34
L046661: db $E8
L046662: db $97
L046663: db $D8
L046664: db $67
L046665: db $A8
L046666: db $D7
L046667: db $6D
L046668: db $00
L046669: db $92
L04666A: db $BD
L04666B: db $6A
L04666C: db $B7
L04666D: db $58
L04666E: db $AE
L04666F: db $53
L046670: db $25
L046671: db $04
L046672: db $DA
L046673: db $26
L046674: db $D9
L046675: db $6E
L046676: db $91
L046677: db $C8
L046678: db $0A
L046679: db $EF
L04667A: db $04
L04667B: db $99
L04667C: db $F6
L04667D: db $FB
L04667E: db $FD
L04667F: db $06
L046680: db $38
L046681: db $00
L046682: db $1F
L046683: db $06
L046684: db $E0
L046685: db $7E
L046686: db $81
L046687: db $9D
L046688: db $62
L046689: db $09
L04668A: db $60
L04668B: db $07
L04668C: db $29
L04668D: db $97
L04668E: db $6F
L04668F: db $68
L046690: db $8F
L046691: db $79
L046692: db $F0
L046693: db $0F
L046694: db $09
L046695: db $3F
L046696: db $6D
L046697: db $F7
L046698: db $F0
L046699: db $08
L04669A: db $48
L04669B: db $28
L04669C: db $08
L04669D: db $02
L04669E: db $00
L04669F: db $EE
L0466A0: db $5B
L0466A1: db $ED
L0466A2: db $56
L0466A3: db $FA
L0466A4: db $4D
L0466A5: db $F6
L0466A6: db $59
L0466A7: db $6A
L0466A8: db $EB
L0466A9: db $28
L0466AA: db $F8
L0466AB: db $45
L0466AC: db $5B
L0466AD: db $BA
L0466AE: db $D0
L0466AF: db $B6
L0466B0: db $C6
L0466B1: db $59
L0466B2: db $10
L0466B3: db $DB
L0466B4: db $65
L0466B5: db $AE
L0466B6: db $10
L0466B7: db $40
L0466B8: db $96
L0466B9: db $13
L0466BA: db $BB
L0466BB: db $6C
L0466BC: db $B5
L0466BD: db $88
L0466BE: db $FF
L0466BF: db $00
L0466C0: db $00
L0466C1: db $11
L0466C2: db $AD
L0466C3: db $08
L0466C4: db $55
L0466C5: db $08
L0466C6: db $AA
L0466C7: db $08
L0466C8: db $06
L0466C9: db $40
L0466CA: db $08
L0466CB: db $14
L0466CC: db $60
L0466CD: db $D0
L0466CE: db $2F
L0466CF: db $18
L0466D0: db $4F
L0466D1: db $08
L0466D2: db $4B
L0466D3: db $FD
L0466D4: db $98
L0466D5: db $08
L0466D6: db $EF
L0466D7: db $59
L0466D8: db $28
L0466D9: db $08
L0466DA: db $FE
L0466DB: db $21
L0466DC: db $D1
L0466DD: db $00
L0466DE: db $6E
L0466DF: db $B9
L0466E0: db $56
L0466E1: db $FA
L0466E2: db $15
L0466E3: db $BB
L0466E4: db $55
L0466E5: db $FB
L0466E6: db $94
L0466E7: db $18
L0466E8: db $7B
L0466E9: db $A5
L0466EA: db $18
L0466EB: db $94
L0466EC: db $78
L0466ED: db $19
L0466EE: db $35
L0466EF: db $46
L0466F0: db $DA
L0466F1: db $09
L0466F2: db $75
L0466F3: db $BA
L0466F4: db $E7
L0466F5: db $08
L0466F6: db $D8
L0466F7: db $C6
L0466F8: db $A8
L0466F9: db $08
L0466FA: db $87
L0466FB: db $08
L0466FC: db $07
L0466FD: db $78
L0466FE: db $81
L0466FF: db $CA
L046700: db $B7
L046701: db $08
L046702: db $BF
L046703: db $CF
L046704: db $EF
L046705: db $DC
L046706: db $38
L046707: db $DB
L046708: db $F7
L046709: db $1B
L04670A: db $A0
L04670B: db $68
L04670C: db $03
L04670D: db $09
L04670E: db $BE
L04670F: db $C3
L046710: db $CD
L046711: db $32
L046712: db $CE
L046713: db $15
L046714: db $B5
L046715: db $AE
L046716: db $55
L046717: db $88
L046718: db $D4
L046719: db $08
L04671A: db $D5
L04671B: db $28
L04671C: db $12
L04671D: db $D3
L04671E: db $ED
L04671F: db $16
L046720: db $D8
L046721: db $40
L046722: db $A8
L046723: db $C0
L046724: db $FC
L046725: db $5F
L046726: db $FB
L046727: db $00
L046728: db $1D
L046729: db $B8
L04672A: db $50
L04672B: db $30
L04672C: db $08
L04672D: db $E8
L04672E: db $40
L04672F: db $F1
L046730: db $08
L046731: db $F0
L046732: db $1A
L046733: db $40
L046734: db $71
L046735: db $01
L046736: db $07
L046737: db $07
L046738: db $02
L046739: db $06
L04673A: db $07
L04673B: db $0A
L04673C: db $01
L04673D: db $2C
L04673E: db $0C
L04673F: db $0D
L046740: db $00
L046741: db $0E
L046742: db $02
L046743: db $9F
L046744: db $02
L046745: db $03
L046746: db $91
L046747: db $2B
L046748: db $04
L046749: db $05
L04674A: db $2B
L04674B: db $08
L04674C: db $09
L04674D: db $0B
L04674E: db $01
L04674F: db $A2
L046750: db $FA
L046751: db $0F
L046752: db $02
L046753: db $10
L046754: db $11
L046755: db $13
L046756: db $78
L046757: db $16
L046758: db $55
L046759: db $17
L04675A: db $02
L04675B: db $1A
L04675C: db $E1
L04675D: db $1C
L04675E: db $10
L04675F: db $1B
L046760: db $00
L046761: db $A1
L046762: db $20
L046763: db $05
L046764: db $28
L046765: db $1E
L046766: db $12
L046767: db $14
L046768: db $22
L046769: db $FA
L04676A: db $5C
L04676B: db $26
L04676C: db $F8
L04676D: db $0E
L04676E: db $02
L04676F: db $58
L046770: db $61
L046771: db $15
L046772: db $18
L046773: db $BF
L046774: db $00
L046775: db $19
L046776: db $FA
L046777: db $C8
L046778: db $E1
L046779: db $D8
L04677A: db $11
L04677B: db $00
L04677C: db $41
L04677D: db $1D
L04677E: db $00
L04677F: db $1F
L046780: db $20
L046781: db $21
L046782: db $23
L046783: db $24
L046784: db $00
L046785: db $2E
L046786: db $25
L046787: db $27
L046788: db $F8
L046789: db $0F
L04678A: db $02
L04678B: db $58
L04678C: db $61
L04678D: db $28
L04678E: db $4C
L04678F: db $2A
L046790: db $00
L046791: db $2D
L046792: db $2E
L046793: db $07
L046794: db $02
L046795: db $33
L046796: db $34
L046797: db $0A
L046798: db $35
L046799: db $36
L04679A: db $32
L04679B: db $39
L04679C: db $08
L04679D: db $3C
L04679E: db $F8
L04679F: db $0E
L0467A0: db $C2
L0467A1: db $02
L0467A2: db $FA
L0467A3: db $29
L0467A4: db $2B
L0467A5: db $2C
L0467A6: db $2F
L0467A7: db $00
L0467A8: db $30
L0467A9: db $76
L0467AA: db $31
L0467AB: db $0A
L0467AC: db $98
L0467AD: db $0A
L0467AE: db $1D
L0467AF: db $00
L0467B0: db $10
L0467B1: db $0C
L0467B2: db $82
L0467B3: db $C8
L0467B4: db $37
L0467B5: db $38
L0467B6: db $3A
L0467B7: db $3B
L0467B8: db $27
L0467B9: db $28
L0467BA: db $0F
L0467BB: db $A2
L0467BC: db $02
L0467BD: db $34
L0467BE: db $00
L0467BF: db $35
L0467C0: db $36
L0467C1: db $41
L0467C2: db $00
L0467C3: db $43
L0467C4: db $64
L0467C5: db $44
L0467C6: db $19
L0467C7: db $07
L0467C8: db $45
L0467C9: db $46
L0467CA: db $F9
L0467CB: db $0E
L0467CC: db $4A
L0467CD: db $58
L0467CE: db $0B
L0467CF: db $20
L0467D0: db $3C
L0467D1: db $29
L0467D2: db $02
L0467D3: db $3D
L0467D4: db $3E
L0467D5: db $3F
L0467D6: db $1F
L0467D7: db $40
L0467D8: db $42
L0467D9: db $2E
L0467DA: db $20
L0467DB: db $11
L0467DC: db $08
L0467DD: db $3B
L0467DE: db $0B
L0467DF: db $1F
L0467E0: db $47
L0467E1: db $48
L0467E2: db $49
L0467E3: db $79
L0467E4: db $61
L0467E5: db $09
L0467E6: db $6B
L0467E7: db $40
L0467E8: db $03
L0467E9: db $4B
L0467EA: db $4C
L0467EB: db $4F
L0467EC: db $50
L0467ED: db $53
L0467EE: db $54
L0467EF: db $20
L0467F0: db $11
L0467F1: db $E3
L0467F2: db $08
L0467F3: db $3B
L0467F4: db $0B
L0467F5: db $56
L0467F6: db $57
L0467F7: db $5A
L0467F8: db $79
L0467F9: db $61
L0467FA: db $E0
L0467FB: db $09
L0467FC: db $6B
L0467FD: db $40
L0467FE: db $4D
L0467FF: db $4E
L046800: db $51
L046801: db $52
L046802: db $55
L046803: db $FC
L046804: db $00
L046805: db $20
L046806: db $11
L046807: db $00
L046808: db $3B
L046809: db $03
L04680A: db $58
L04680B: db $59
L04680C: db $7B
L04680D: db $5B
L04680E: db $79
L04680F: db $61
L046810: db $75
L046811: db $40
L046812: db $01
L046813: db $07
L046814: db $07
L046815: db $FF
L046816: db $07
L046817: db $07
L046818: db $07
L046819: db $07
L04681A: db $07
L04681B: db $07
L04681C: db $07
L04681D: db $07
L04681E: db $C0
L04681F: db $07
L046820: db $06
L046821: db $00
L046822: db $91
L046823: db $80
L046824: db $7B
L046825: db $00
L046826: db $03
L046827: db $03
L046828: db $03
L046829: db $02
L04682A: db $FF
L04682B: db $03
L04682C: db $03
L04682D: db $C7
L04682E: db $03
L04682F: db $03
L046830: db $83
L046831: db $EF
L046832: db $B3
L046833: db $07
L046834: db $07
L046835: db $07
L046836: db $AF
L046837: db $3C
L046838: db $F8
L046839: db $04
L04683A: db $FA
L04683B: db $07
L04683C: db $07
L04683D: db $07
L04683E: db $44
L04683F: db $56
L046840: db $30
L046841: db $06
L046842: db $B2
L046843: db $0E
L046844: db $31
L046845: db $77
L046846: db $7E
L046847: db $07
L046848: db $BA
L046849: db $06
L04684A: db $7F
L04684B: db $E3
L04684C: db $03
L04684D: db $02
L04684E: db $C0
L04684F: db $06
L046850: db $FC
L046851: db $BF
L046852: db $04
L046853: db $FE
L046854: db $2B
L046855: db $03
L046856: db $8F
L046857: db $07
L046858: db $07
L046859: db $07
L04685A: db $A8
L04685B: db $40
L04685C: db $0A
L04685D: db $04
L04685E: db $02
L04685F: db $14
L046860: db $52
L046861: db $C7
L046862: db $B8
L046863: db $00
L046864: db $9B
L046865: db $7C
L046866: db $D1
L046867: db $3E
L046868: db $E6
L046869: db $9F
L04686A: db $F6
L04686B: db $CF
L04686C: db $A0
L04686D: db $8A
L04686E: db $DF
L04686F: db $00
L046870: db $AF
L046871: db $8F
L046872: db $77
L046873: db $67
L046874: db $FB
L046875: db $26
L046876: db $2F
L046877: db $F7
L046878: db $38
L046879: db $6F
L04687A: db $7F
L04687B: db $08
L04687C: db $34
L04687D: db $FD
L04687E: db $A8
L04687F: db $04
L046880: db $FA
L046881: db $04
L046882: db $E0
L046883: db $04
L046884: db $80
L046885: db $D4
L046886: db $2B
L046887: db $F5
L046888: db $05
L046889: db $15
L04688A: db $26
L04688B: db $01
L04688C: db $FE
L04688D: db $04
L04688E: db $1C
L04688F: db $04
L046890: db $55
L046891: db $01
L046892: db $84
L046893: db $71
L046894: db $68
L046895: db $64
L046896: db $14
L046897: db $0E
L046898: db $04
L046899: db $76
L04689A: db $3F
L04689B: db $3E
L04689C: db $47
L04689D: db $05
L04689E: db $FC
L04689F: db $05
L0468A0: db $10
L0468A1: db $F9
L0468A2: db $E7
L0468A3: db $05
L0468A4: db $3B
L0468A5: db $00
L0468A6: db $00
L0468A7: db $C0
L0468A8: db $5C
L0468A9: db $00
L0468AA: db $08
L0468AB: db $07
L0468AC: db $60
L0468AD: db $DF
L0468AE: db $70
L0468AF: db $EF
L0468B0: db $F0
L0468B1: db $04
L0468B2: db $45
L0468B3: db $58
L0468B4: db $33
L0468B5: db $F3
L0468B6: db $FD
L0468B7: db $06
L0468B8: db $18
L0468B9: db $E7
L0468BA: db $FB
L0468BB: db $06
L0468BC: db $18
L0468BD: db $67
L0468BE: db $CF
L0468BF: db $6C
L0468C0: db $48
L0468C1: db $F8
L0468C2: db $F7
L0468C3: db $44
L0468C4: db $20
L0468C5: db $05
L0468C6: db $F5
L0468C7: db $B6
L0468C8: db $50
L0468C9: db $DF
L0468CA: db $04
L0468CB: db $8F
L0468CC: db $04
L0468CD: db $A8
L0468CE: db $04
L0468CF: db $16
L0468D0: db $22
L0468D1: db $77
L0468D2: db $AA
L0468D3: db $0D
L0468D4: db $7F
L0468D5: db $0C
L0468D6: db $04
L0468D7: db $A2
L0468D8: db $FF
L0468D9: db $1E
L0468DA: db $F6
L0468DB: db $00
L0468DC: db $09
L0468DD: db $07
L0468DE: db $07
L0468DF: db $04
L0468E0: db $B0
L0468E1: db $7C
L0468E2: db $2A
L0468E3: db $55
L0468E4: db $67
L0468E5: db $1D
L0468E6: db $6C
L0468E7: db $9C
L0468E8: db $78
L0468E9: db $AF
L0468EA: db $FD
L0468EB: db $6F
L0468EC: db $07
L0468ED: db $05
L0468EE: db $13
L0468EF: db $17
L0468F0: db $04
L0468F1: db $FE
L0468F2: db $04
L0468F3: db $74
L0468F4: db $7E
L0468F5: db $04
L0468F6: db $78
L0468F7: db $0E
L0468F8: db $67
L0468F9: db $04
L0468FA: db $43
L0468FB: db $E7
L0468FC: db $68
L0468FD: db $7C
L0468FE: db $0D
L0468FF: db $04
L046900: db $0F
L046901: db $04
L046902: db $03
L046903: db $97
L046904: db $79
L046905: db $96
L046906: db $04
L046907: db $7B
L046908: db $D7
L046909: db $04
L04690A: db $C7
L04690B: db $04
L04690C: db $28
L04690D: db $FB
L04690E: db $A0
L04690F: db $7D
L046910: db $F8
L046911: db $50
L046912: db $EC
L046913: db $D3
L046914: db $CE
L046915: db $B9
L046916: db $A7
L046917: db $85
L046918: db $E8
L046919: db $AD
L04691A: db $72
L04691B: db $DF
L04691C: db $A2
L04691D: db $34
L04691E: db $CA
L04691F: db $04
L046920: db $75
L046921: db $FA
L046922: db $04
L046923: db $40
L046924: db $04
L046925: db $C0
L046926: db $04
L046927: db $82
L046928: db $74
L046929: db $1E
L04692A: db $38
L04692B: db $E4
L04692C: db $3B
L04692D: db $7C
L04692E: db $0C
L04692F: db $1D
L046930: db $04
L046931: db $C2
L046932: db $41
L046933: db $3F
L046934: db $58
L046935: db $9F
L046936: db $EF
L046937: db $2F
L046938: db $F7
L046939: db $27
L04693A: db $A4
L04693B: db $3F
L04693C: db $8F
L04693D: db $77
L04693E: db $20
L04693F: db $18
L046940: db $34
L046941: db $28
L046942: db $04
L046943: db $03
L046944: db $53
L046945: db $07
L046946: db $04
L046947: db $83
L046948: db $7C
L046949: db $39
L04694A: db $67
L04694B: db $CC
L04694C: db $7C
L04694D: db $FD
L04694E: db $0C
L04694F: db $1D
L046950: db $04
L046951: db $10
L046952: db $C6
L046953: db $07
L046954: db $00
L046955: db $04
L046956: db $07
L046957: db $7F
L046958: db $96
L046959: db $69
L04695A: db $92
L04695B: db $6D
L04695C: db $1E
L04695D: db $03
L04695E: db $8F
L04695F: db $86
L046960: db $CC
L046961: db $CF
L046962: db $37
L046963: db $4F
L046964: db $B7
L046965: db $1E
L046966: db $5C
L046967: db $87
L046968: db $63
L046969: db $78
L04696A: db $05
L04696B: db $7F
L04696C: db $AA
L04696D: db $55
L04696E: db $80
L04696F: db $0C
L046970: db $1E
L046971: db $11
L046972: db $F6
L046973: db $0E
L046974: db $F5
L046975: db $04
L046976: db $F1
L046977: db $FE
L046978: db $05
L046979: db $04
L04697A: db $9E
L04697B: db $14
L04697C: db $4E
L04697D: db $B5
L04697E: db $25
L04697F: db $1D
L046980: db $99
L046981: db $05
L046982: db $E7
L046983: db $3F
L046984: db $9F
L046985: db $EF
L046986: db $04
L046987: db $87
L046988: db $7F
L046989: db $04
L04698A: db $48
L04698B: db $FB
L04698C: db $F8
L04698D: db $02
L04698E: db $24
L04698F: db $21
L046990: db $31
L046991: db $09
L046992: db $EB
L046993: db $7C
L046994: db $BB
L046995: db $11
L046996: db $74
L046997: db $FB
L046998: db $64
L046999: db $8C
L04699A: db $3C
L04699B: db $D7
L04699C: db $78
L04699D: db $04
L04699E: db $55
L04699F: db $68
L0469A0: db $14
L0469A1: db $58
L0469A2: db $2D
L0469A3: db $C6
L0469A4: db $48
L0469A5: db $D6
L0469A6: db $72
L0469A7: db $57
L0469A8: db $BE
L0469A9: db $04
L0469AA: db $B8
L0469AB: db $04
L0469AC: db $E9
L0469AD: db $04
L0469AE: db $6C
L0469AF: db $04
L0469B0: db $DB
L0469B1: db $DC
L0469B2: db $05
L0469B3: db $B2
L0469B4: db $08
L0469B5: db $D8
L0469B6: db $FC
L0469B7: db $F5
L0469B8: db $0C
L0469B9: db $3B
L0469BA: db $FA
L0469BB: db $AD
L0469BC: db $94
L0469BD: db $04
L0469BE: db $0C
L0469BF: db $0D
L0469C0: db $0C
L0469C1: db $04
L0469C2: db $33
L0469C3: db $BF
L0469C4: db $40
L0469C5: db $2C
L0469C6: db $04
L0469C7: db $B7
L0469C8: db $4F
L0469C9: db $A4
L0469CA: db $04
L0469CB: db $4B
L0469CC: db $B4
L0469CD: db $04
L0469CE: db $F5
L0469CF: db $4E
L0469D0: db $0D
L0469D1: db $F4
L0469D2: db $04
L0469D3: db $B2
L0469D4: db $D6
L0469D5: db $03
L0469D6: db $01
L0469D7: db $8F
L0469D8: db $A4
L0469D9: db $97
L0469DA: db $05
L0469DB: db $74
L0469DC: db $46
L0469DD: db $AD
L0469DE: db $0C
L0469DF: db $31
L0469E0: db $06
L0469E1: db $30
L0469E2: db $07
L0469E3: db $05
L0469E4: db $EE
L0469E5: db $24
L0469E6: db $40
L0469E7: db $6D
L0469E8: db $F5
L0469E9: db $06
L0469EA: db $DE
L0469EB: db $21
L0469EC: db $78
L0469ED: db $87
L0469EE: db $73
L0469EF: db $53
L0469F0: db $8C
L0469F1: db $1C
L0469F2: db $00
L0469F3: db $05
L0469F4: db $AA
L0469F5: db $55
L0469F6: db $00
L0469F7: db $08
L0469F8: db $EA
L0469F9: db $AB
L0469FA: db $03
L0469FB: db $02
L0469FC: db $0F
L0469FD: db $B4
L0469FE: db $47
L0469FF: db $06
L046A00: db $43
L046A01: db $04
L046A02: db $7F
L046A03: db $80
L046A04: db $7E
L046A05: db $91
L046A06: db $6E
L046A07: db $04
L046A08: db $77
L046A09: db $9C
L046A0A: db $04
L046A0B: db $EB
L046A0C: db $1C
L046A0D: db $F7
L046A0E: db $08
L046A0F: db $6B
L046A10: db $14
L046A11: db $5D
L046A12: db $E3
L046A13: db $11
L046A14: db $A3
L046A15: db $DD
L046A16: db $33
L046A17: db $04
L046A18: db $FE
L046A19: db $01
L046A1A: db $3E
L046A1B: db $0C
L046A1C: db $0D
L046A1D: db $EA
L046A1E: db $1D
L046A1F: db $95
L046A20: db $6A
L046A21: db $6D
L046A22: db $94
L046A23: db $FA
L046A24: db $04
L046A25: db $40
L046A26: db $E0
L046A27: db $04
L046A28: db $C6
L046A29: db $FD
L046A2A: db $82
L046A2B: db $EF
L046A2C: db $92
L046A2D: db $D7
L046A2E: db $7D
L046A2F: db $3A
L046A30: db $05
L046A31: db $3C
L046A32: db $1C
L046A33: db $E3
L046A34: db $01
L046A35: db $9E
L046A36: db $04
L046A37: db $47
L046A38: db $14
L046A39: db $11
L046A3A: db $00
L046A3B: db $AA
L046A3C: db $55
L046A3D: db $00
L046A3E: db $08
L046A3F: db $7E
L046A40: db $AA
L046A41: db $04
L046A42: db $DF
L046A43: db $04
L046A44: db $8F
L046A45: db $04
L046A46: db $07
L046A47: db $1D
L046A48: db $02
L046A49: db $15
L046A4A: db $AF
L046A4B: db $52
L046A4C: db $57
L046A4D: db $3D
L046A4E: db $AB
L046A4F: db $04
L046A50: db $83
L046A51: db $04
L046A52: db $09
L046A53: db $81
L046A54: db $E6
L046A55: db $BD
L046A56: db $7E
L046A57: db $0C
L046A58: db $EB
L046A59: db $3C
L046A5A: db $BC
L046A5B: db $6F
L046A5C: db $38
L046A5D: db $8D
L046A5E: db $99
L046A5F: db $E7
L046A60: db $04
L046A61: db $34
L046A62: db $04
L046A63: db $D9
L046A64: db $EC
L046A65: db $22
L046A66: db $08
L046A67: db $7C
L046A68: db $50
L046A69: db $BF
L046A6A: db $04
L046A6B: db $F2
L046A6C: db $F7
L046A6D: db $40
L046A6E: db $EA
L046A6F: db $4C
L046A70: db $DA
L046A71: db $C7
L046A72: db $BA
L046A73: db $85
L046A74: db $7A
L046A75: db $9F
L046A76: db $23
L046A77: db $62
L046A78: db $FD
L046A79: db $CC
L046A7A: db $FE
L046A7B: db $45
L046A7C: db $EE
L046A7D: db $50
L046A7E: db $07
L046A7F: db $E4
L046A80: db $07
L046A81: db $58
L046A82: db $0D
L046A83: db $11
L046A84: db $CE
L046A85: db $9D
L046A86: db $E0
L046A87: db $FC
L046A88: db $08
L046A89: db $C3
L046A8A: db $F9
L046A8B: db $A6
L046A8C: db $59
L046A8D: db $04
L046A8E: db $DB
L046A8F: db $67
L046A90: db $BB
L046A91: db $0D
L046A92: db $44
L046A93: db $B8
L046A94: db $47
L046A95: db $EC
L046A96: db $38
L046A97: db $34
L046A98: db $07
L046A99: db $00
L046A9A: db $50
L046A9B: db $FB
L046A9C: db $BC
L046A9D: db $1B
L046A9E: db $05
L046A9F: db $F4
L046AA0: db $EB
L046AA1: db $F5
L046AA2: db $0B
L046AA3: db $40
L046AA4: db $05
L046AA5: db $24
L046AA6: db $BF
L046AA7: db $40
L046AA8: db $DF
L046AA9: db $60
L046AAA: db $A3
L046AAB: db $5D
L046AAC: db $98
L046AAD: db $50
L046AAE: db $41
L046AAF: db $BE
L046AB0: db $80
L046AB1: db $0C
L046AB2: db $5C
L046AB3: db $96
L046AB4: db $69
L046AB5: db $C9
L046AB6: db $F4
L046AB7: db $1C
L046AB8: db $6C
L046AB9: db $B3
L046ABA: db $05
L046ABB: db $6E
L046ABC: db $B1
L046ABD: db $0D
L046ABE: db $35
L046ABF: db $6D
L046AC0: db $B2
L046AC1: db $27
L046AC2: db $05
L046AC3: db $00
L046AC4: db $58
L046AC5: db $03
L046AC6: db $C0
L046AC7: db $21
L046AC8: db $6F
L046AC9: db $90
L046ACA: db $17
L046ACB: db $1F
L046ACC: db $E0
L046ACD: db $7F
L046ACE: db $80
L046ACF: db $E4
L046AD0: db $01
L046AD1: db $F8
L046AD2: db $7A
L046AD3: db $85
L046AD4: db $5F
L046AD5: db $A0
L046AD6: db $BB
L046AD7: db $47
L046AD8: db $74
L046AD9: db $1C
L046ADA: db $9E
L046ADB: db $F3
L046ADC: db $0F
L046ADD: db $35
L046ADE: db $50
L046ADF: db $58
L046AE0: db $6A
L046AE1: db $95
L046AE2: db $00
L046AE3: db $AF
L046AE4: db $50
L046AE5: db $F5
L046AE6: db $0A
L046AE7: db $DE
L046AE8: db $E1
L046AE9: db $B7
L046AEA: db $78
L046AEB: db $34
L046AEC: db $CE
L046AED: db $F1
L046AEE: db $35
L046AEF: db $F4
L046AF0: db $01
L046AF1: db $35
L046AF2: db $F7
L046AF3: db $08
L046AF4: db $30
L046AF5: db $BD
L046AF6: db $42
L046AF7: db $24
L046AF8: db $04
L046AF9: db $E7
L046AFA: db $5A
L046AFB: db $76
L046AFC: db $AD
L046AFD: db $03
L046AFE: db $3E
L046AFF: db $C1
L046B00: db $2A
L046B01: db $DD
L046B02: db $BE
L046B03: db $5D
L046B04: db $08
L046B05: db $88
L046B06: db $A8
L046B07: db $3C
L046B08: db $4A
L046B09: db $45
L046B0A: db $B5
L046B0B: db $0C
L046B0C: db $63
L046B0D: db $9C
L046B0E: db $3D
L046B0F: db $25
L046B10: db $C2
L046B11: db $23
L046B12: db $A0
L046B13: db $4B
L046B14: db $B4
L046B15: db $7C
L046B16: db $1C
L046B17: db $DC
L046B18: db $5B
L046B19: db $94
L046B1A: db $54
L046B1B: db $55
L046B1C: db $0F
L046B1D: db $FD
L046B1E: db $C9
L046B1F: db $90
L046B20: db $B5
L046B21: db $09
L046B22: db $DB
L046B23: db $24
L046B24: db $DA
L046B25: db $25
L046B26: db $0D
L046B27: db $CB
L046B28: db $34
L046B29: db $ED
L046B2A: db $A1
L046B2B: db $D4
L046B2C: db $14
L046B2D: db $B0
L046B2E: db $A6
L046B2F: db $67
L046B30: db $98
L046B31: db $2F
L046B32: db $38
L046B33: db $B8
L046B34: db $14
L046B35: db $A2
L046B36: db $A0
L046B37: db $A9
L046B38: db $06
L046B39: db $EF
L046B3A: db $58
L046B3B: db $FA
L046B3C: db $1F
L046B3D: db $45
L046B3E: db $E2
L046B3F: db $1D
L046B40: db $1D
L046B41: db $9D
L046B42: db $6C
L046B43: db $84
L046B44: db $0C
L046B45: db $48
L046B46: db $A4
L046B47: db $0F
L046B48: db $BD
L046B49: db $66
L046B4A: db $8C
L046B4B: db $00
L046B4C: db $EE
L046B4D: db $31
L046B4E: db $30
L046B4F: db $6D
L046B50: db $B2
L046B51: db $0F
L046B52: db $74
L046B53: db $30
L046B54: db $EC
L046B55: db $33
L046B56: db $6C
L046B57: db $1C
L046B58: db $B3
L046B59: db $38
L046B5A: db $C7
L046B5B: db $40
L046B5C: db $49
L046B5D: db $04
L046B5E: db $C0
L046B5F: db $3F
L046B60: db $0B
L046B61: db $AE
L046B62: db $51
L046B63: db $EA
L046B64: db $55
L046B65: db $18
L046B66: db $44
L046B67: db $04
L046B68: db $0E
L046B69: db $E2
L046B6A: db $4D
L046B6B: db $07
L046B6C: db $8E
L046B6D: db $11
L046B6E: db $FD
L046B6F: db $02
L046B70: db $CC
L046B71: db $41
L046B72: db $87
L046B73: db $3D
L046B74: db $2A
L046B75: db $D5
L046B76: db $3E
L046B77: db $C1
L046B78: db $04
L046B79: db $0D
L046B7A: db $04
L046B7B: db $85
L046B7C: db $1D
L046B7D: db $7E
L046B7E: db $95
L046B7F: db $C9
L046B80: db $76
L046B81: db $B1
L046B82: db $01
L046B83: db $50
L046B84: db $2F
L046B85: db $57
L046B86: db $A8
L046B87: db $EC
L046B88: db $14
L046B89: db $1C
L046B8A: db $64
L046B8B: db $C4
L046B8C: db $AC
L046B8D: db $00
L046B8E: db $7D
L046B8F: db $A2
L046B90: db $DF
L046B91: db $3B
L046B92: db $3D
L046B93: db $C3
L046B94: db $C7
L046B95: db $38
L046B96: db $1A
L046B97: db $F5
L046B98: db $0A
L046B99: db $AA
L046B9A: db $2C
L046B9B: db $AC
L046B9C: db $C2
L046B9D: db $50
L046B9E: db $D7
L046B9F: db $22
L046BA0: db $DA
L046BA1: db $25
L046BA2: db $84
L046BA3: db $D1
L046BA4: db $6B
L046BA5: db $B4
L046BA6: db $DC
L046BA7: db $15
L046BA8: db $02
L046BA9: db $3F
L046BAA: db $C0
L046BAB: db $BD
L046BAC: db $52
L046BAD: db $35
L046BAE: db $CA
L046BAF: db $74
L046BB0: db $92
L046BB1: db $A2
L046BB2: db $1C
L046BB3: db $D0
L046BB4: db $78
L046BB5: db $C6
L046BB6: db $1F
L046BB7: db $E0
L046BB8: db $10
L046BB9: db $6F
L046BBA: db $01
L046BBB: db $F9
L046BBC: db $06
L046BBD: db $BE
L046BBE: db $51
L046BBF: db $BF
L046BC0: db $40
L046BC1: db $B8
L046BC2: db $D8
L046BC3: db $0D
L046BC4: db $F8
L046BC5: db $17
L046BC6: db $D8
L046BC7: db $67
L046BC8: db $F0
L046BC9: db $F8
L046BCA: db $7F
L046BCB: db $30
L046BCC: db $30
L046BCD: db $F7
L046BCE: db $5A
L046BCF: db $05
L046BD0: db $84
L046BD1: db $46
L046BD2: db $4A
L046BD3: db $B5
L046BD4: db $3E
L046BD5: db $01
L046BD6: db $C1
L046BD7: db $22
L046BD8: db $DD
L046BD9: db $2A
L046BDA: db $D5
L046BDB: db $18
L046BDC: db $E7
L046BDD: db $5C
L046BDE: db $18
L046BDF: db $07
L046BE0: db $E3
L046BE1: db $1C
L046BE2: db $0D
L046BE3: db $40
L046BE4: db $B9
L046BE5: db $9C
L046BE6: db $63
L046BE7: db $C0
L046BE8: db $B0
L046BE9: db $B8
L046BEA: db $00
L046BEB: db $FF
L046BEC: db $0E
L046BED: db $F5
L046BEE: db $CB
L046BEF: db $34
L046BF0: db $CA
L046BF1: db $64
L046BF2: db $08
L046BF3: db $97
L046BF4: db $68
L046BF5: db $F4
L046BF6: db $D7
L046BF7: db $A4
L046BF8: db $90
L046BF9: db $67
L046BFA: db $EF
L046BFB: db $CC
L046BFC: db $0C
L046BFD: db $A0
L046BFE: db $08
L046BFF: db $B0
L046C00: db $C8
L046C01: db $D0
L046C02: db $22
L046C03: db $30
L046C04: db $CF
L046C05: db $E4
L046C06: db $27
L046C07: db $03
L046C08: db $FC
L046C09: db $F0
L046C0A: db $9A
L046C0B: db $32
L046C0C: db $13
L046C0D: db $EC
L046C0E: db $C8
L046C0F: db $68
L046C10: db $FA
L046C11: db $25
L046C12: db $88
L046C13: db $AF
L046C14: db $BD
L046C15: db $04
L046C16: db $40
L046C17: db $90
L046C18: db $F8
L046C19: db $0D
L046C1A: db $04
L046C1B: db $BF
L046C1C: db $04
L046C1D: db $48
L046C1E: db $80
L046C1F: db $F8
L046C20: db $AA
L046C21: db $C0
L046C22: db $14
L046C23: db $4B
L046C24: db $B4
L046C25: db $F0
L046C26: db $04
L046C27: db $4F
L046C28: db $A6
L046C29: db $59
L046C2A: db $F1
L046C2B: db $2E
L046C2C: db $80
L046C2D: db $23
L046C2E: db $BE
L046C2F: db $F1
L046C30: db $38
L046C31: db $0C
L046C32: db $88
L046C33: db $0C
L046C34: db $49
L046C35: db $DF
L046C36: db $EA
L046C37: db $C0
L046C38: db $17
L046C39: db $05
L046C3A: db $5E
L046C3B: db $A5
L046C3C: db $6C
L046C3D: db $02
L046C3E: db $E0
L046C3F: db $A8
L046C40: db $0C
L046C41: db $84
L046C42: db $E8
L046C43: db $57
L046C44: db $A9
L046C45: db $39
L046C46: db $C6
L046C47: db $2C
L046C48: db $A1
L046C49: db $07
L046C4A: db $04
L046C4B: db $F8
L046C4C: db $7E
L046C4D: db $81
L046C4E: db $9F
L046C4F: db $60
L046C50: db $A5
L046C51: db $C3
L046C52: db $3C
L046C53: db $2F
L046C54: db $9D
L046C55: db $62
L046C56: db $4C
L046C57: db $78
L046C58: db $65
L046C59: db $3C
L046C5A: db $65
L046C5B: db $0C
L046C5C: db $2C
L046C5D: db $5F
L046C5E: db $A2
L046C5F: db $06
L046C60: db $A0
L046C61: db $05
L046C62: db $28
L046C63: db $0D
L046C64: db $FB
L046C65: db $C0
L046C66: db $04
L046C67: db $0F
L046C68: db $1A
L046C69: db $ED
L046C6A: db $5B
L046C6B: db $AD
L046C6C: db $1F
L046C6D: db $E0
L046C6E: db $E3
L046C6F: db $90
L046C70: db $98
L046C71: db $64
L046C72: db $00
L046C73: db $AA
L046C74: db $55
L046C75: db $0D
L046C76: db $07
L046C77: db $C5
L046C78: db $05
L046C79: db $13
L046C7A: db $B7
L046C7B: db $4F
L046C7C: db $F7
L046C7D: db $04
L046C7E: db $B4
L046C7F: db $0E
L046C80: db $92
L046C81: db $04
L046C82: db $0F
L046C83: db $F0
L046C84: db $04
L046C85: db $3F
L046C86: db $C0
L046C87: db $3D
L046C88: db $FD
L046C89: db $7D
L046C8A: db $03
L046C8B: db $08
L046C8C: db $05
L046C8D: db $B8
L046C8E: db $14
L046C8F: db $04
L046C90: db $0C
L046C91: db $04
L046C92: db $56
L046C93: db $AC
L046C94: db $C0
L046C95: db $AF
L046C96: db $04
L046C97: db $0E
L046C98: db $14
L046C99: db $2C
L046C9A: db $F8
L046C9B: db $3D
L046C9C: db $FE
L046C9D: db $F9
L046C9E: db $60
L046C9F: db $0C
L046CA0: db $15
L046CA1: db $05
L046CA2: db $07
L046CA3: db $25
L046CA4: db $49
L046CA5: db $01
L046CA6: db $7D
L046CA7: db $35
L046CA8: db $CA
L046CA9: db $A1
L046CAA: db $30
L046CAB: db $CF
L046CAC: db $88
L046CAD: db $01
L046CAE: db $FC
L046CAF: db $4C
L046CB0: db $B3
L046CB1: db $13
L046CB2: db $EC
L046CB3: db $CE
L046CB4: db $31
L046CB5: db $3D
L046CB6: db $17
L046CB7: db $5C
L046CB8: db $A3
L046CB9: db $F1
L046CBA: db $90
L046CBB: db $08
L046CBC: db $F0
L046CBD: db $45
L046CBE: db $75
L046CBF: db $98
L046CC0: db $15
L046CC1: db $56
L046CC2: db $A9
L046CC3: db $3D
L046CC4: db $05
L046CC5: db $1C
L046CC6: db $E3
L046CC7: db $06
L046CC8: db $9F
L046CC9: db $C4
L046CCA: db $D0
L046CCB: db $2F
L046CCC: db $85
L046CCD: db $2F
L046CCE: db $07
L046CCF: db $07
L046CD0: db $07
L046CD1: db $E1
L046CD2: db $07
L046CD3: db $07
L046CD4: db $9D
L046CD5: db $70
L046CD6: db $8F
L046CD7: db $0C
L046CD8: db $F3
L046CD9: db $1D
L046CDA: db $21
L046CDB: db $20
L046CDC: db $DF
L046CDD: db $37
L046CDE: db $33
L046CDF: db $CD
L046CE0: db $6B
L046CE1: db $95
L046CE2: db $AC
L046CE3: db $40
L046CE4: db $FD
L046CE5: db $F8
L046CE6: db $32
L046CE7: db $1F
L046CE8: db $EA
L046CE9: db $97
L046CEA: db $6A
L046CEB: db $6F
L046CEC: db $07
L046CED: db $94
L046CEE: db $0F
L046CEF: db $F4
L046CF0: db $AA
L046CF1: db $55
L046CF2: db $00
L046CF3: db $08
L046CF4: db $0D
L046CF5: db $F0
L046CF6: db $62
L046CF7: db $0B
L046CF8: db $08
L046CF9: db $2D
L046CFA: db $0E
L046CFB: db $F5
L046CFC: db $DD
L046CFD: db $2A
L046CFE: db $09
L046CFF: db $1E
L046D00: db $E9
L046D01: db $7F
L046D02: db $88
L046D03: db $2C
L046D04: db $57
L046D05: db $B8
L046D06: db $04
L046D07: db $90
L046D08: db $0C
L046D09: db $10
L046D0A: db $75
L046D0B: db $3C
L046D0C: db $C0
L046D0D: db $BF
L046D0E: db $CE
L046D0F: db $B1
L046D10: db $0C
L046D11: db $E3
L046D12: db $5C
L046D13: db $F8
L046D14: db $47
L046D15: db $C8
L046D16: db $54
L046D17: db $74
L046D18: db $AB
L046D19: db $11
L046D1A: db $FA
L046D1B: db $15
L046D1C: db $78
L046D1D: db $D0
L046D1E: db $BC
L046D1F: db $4B
L046D20: db $5D
L046D21: db $4C
L046D22: db $5B
L046D23: db $AE
L046D24: db $BD
L046D25: db $04
L046D26: db $04
L046D27: db $30
L046D28: db $07
L046D29: db $04
L046D2A: db $0C
L046D2B: db $41
L046D2C: db $01
L046D2D: db $88
L046D2E: db $A9
L046D2F: db $23
L046D30: db $DC
L046D31: db $98
L046D32: db $67
L046D33: db $18
L046D34: db $00
L046D35: db $FE
L046D36: db $D8
L046D37: db $27
L046D38: db $E4
L046D39: db $DB
L046D3A: db $20
L046D3B: db $DF
L046D3C: db $E0
L046D3D: db $20
L046D3E: db $1F
L046D3F: db $80
L046D40: db $E0
L046D41: db $00
L046D42: db $19
L046D43: db $40
L046D44: db $7D
L046D45: db $01
L046D46: db $07
L046D47: db $07
L046D48: db $07
L046D49: db $07
L046D4A: db $03
L046D4B: db $02
L046D4C: db $1A
L046D4D: db $78
L046D4E: db $03
L046D4F: db $67
L046D50: db $07
L046D51: db $CD
L046D52: db $D3
L046D53: db $06
L046D54: db $04
L046D55: db $05
L046D56: db $E1
L046D57: db $41
L046D58: db $FF
L046D59: db $02
L046D5A: db $0C
L046D5B: db $0D
L046D5C: db $10
L046D5D: db $11
L046D5E: db $05
L046D5F: db $75
L046D60: db $14
L046D61: db $C8
L046D62: db $D2
L046D63: db $01
L046D64: db $07
L046D65: db $08
L046D66: db $06
L046D67: db $38
L046D68: db $20
L046D69: db $08
L046D6A: db $09
L046D6B: db $EE
L046D6C: db $0A
L046D6D: db $0B
L046D6E: db $0E
L046D6F: db $0F
L046D70: db $12
L046D71: db $5E
L046D72: db $13
L046D73: db $05
L046D74: db $15
L046D75: db $C8
L046D76: db $D1
L046D77: db $FC
L046D78: db $11
L046D79: db $16
L046D7A: db $20
L046D7B: db $18
L046D7C: db $03
L046D7D: db $FD
L046D7E: db $1A
L046D7F: db $1B
L046D80: db $1E
L046D81: db $1F
L046D82: db $20
L046D83: db $6C
L046D84: db $21
L046D85: db $05
L046D86: db $38
L046D87: db $22
L046D88: db $FF
L046D89: db $10
L046D8A: db $17
L046D8B: db $19
L046D8C: db $9E
L046D8D: db $FE
L046D8E: db $1C
L046D8F: db $1D
L046D90: db $58
L046D91: db $48
L046D92: db $FF
L046D93: db $38
L046D94: db $23
L046D95: db $9E
L046D96: db $58
L046D97: db $24
L046D98: db $27
L046D99: db $E2
L046D9A: db $18
L046D9B: db $28
L046D9C: db $10
L046D9D: db $1A
L046D9E: db $4C
L046D9F: db $1B
L046DA0: db $FE
L046DA1: db $2F
L046DA2: db $30
L046DA3: db $FF
L046DA4: db $FB
L046DA5: db $25
L046DA6: db $26
L046DA7: db $1E
L046DA8: db $28
L046DA9: db $29
L046DAA: db $2A
L046DAB: db $21
L046DAC: db $00
L046DAD: db $10
L046DAE: db $20
L046DAF: db $2B
L046DB0: db $37
L046DB1: db $2C
L046DB2: db $2D
L046DB3: db $10
L046DB4: db $00
L046DB5: db $2E
L046DB6: db $11
L046DB7: db $70
L046DB8: db $80
L046DB9: db $CE
L046DBA: db $FB
L046DBB: db $28
L046DBC: db $31
L046DBD: db $32
L046DBE: db $18
L046DBF: db $11
L046DC0: db $38
L046DC1: db $33
L046DC2: db $05
L046DC3: db $34
L046DC4: db $35
L046DC5: db $38
L046DC6: db $39
L046DC7: db $3C
L046DC8: db $20
L046DC9: db $3F
L046DCA: db $00
L046DCB: db $44
L046DCC: db $40
L046DCD: db $20
L046DCE: db $42
L046DCF: db $43
L046DD0: db $46
L046DD1: db $58
L046DD2: db $47
L046DD3: db $48
L046DD4: db $66
L046DD5: db $4B
L046DD6: db $10
L046DD7: db $79
L046DD8: db $22
L046DD9: db $4E
L046DDA: db $F9
L046DDB: db $58
L046DDC: db $23
L046DDD: db $78
L046DDE: db $52
L046DDF: db $18
L046DE0: db $11
L046DE1: db $38
L046DE2: db $60
L046DE3: db $36
L046DE4: db $37
L046DE5: db $3A
L046DE6: db $08
L046DE7: db $3B
L046DE8: db $3D
L046DE9: db $3E
L046DEA: db $30
L046DEB: db $01
L046DEC: db $41
L046DED: db $44
L046DEE: db $45
L046DEF: db $C3
L046DF0: db $10
L046DF1: db $D8
L046DF2: db $49
L046DF3: db $4A
L046DF4: db $4C
L046DF5: db $4D
L046DF6: db $28
L046DF7: db $80
L046DF8: db $53
L046DF9: db $4F
L046DFA: db $A1
L046DFB: db $50
L046DFC: db $A0
L046DFD: db $51
L046DFE: db $53
L046DFF: db $18
L046E00: db $12
L046E01: db $85
L046E02: db $58
L046E03: db $54
L046E04: db $55
L046E05: db $58
L046E06: db $56
L046E07: db $09
L046E08: db $57
L046E09: db $08
L046E0A: db $E5
L046E0B: db $11
L046E0C: db $01
L046E0D: db $41
L046E0E: db $59
L046E0F: db $5A
L046E10: db $00
L046E11: db $5C
L046E12: db $6A
L046E13: db $FF
L046E14: db $A1
L046E15: db $9B
L046E16: db $7A
L046E17: db $34
L046E18: db $03
L046E19: db $38
L046E1A: db $F3
L046E1B: db $11
L046E1C: db $4F
L046E1D: db $5B
L046E1E: db $F9
L046E1F: db $5D
L046E20: db $5E
L046E21: db $43
L046E22: db $03
L046E23: db $32
L046E24: db $4E
L046E25: db $F0
L046E26: db $07
L046E27: db $07
L046E28: db $07
L046E29: db $02
L046E2A: db $78
L046E2B: db $80
L046E2C: db $7B
L046E2D: db $00
L046E2E: db $03
L046E2F: db $03
L046E30: db $03
L046E31: db $03
L046E32: db $FF
L046E33: db $07
L046E34: db $07
L046E35: db $EA
L046E36: db $07
L046E37: db $05
L046E38: db $0A
L046E39: db $50
L046E3A: db $0E
L046E3B: db $44
L046E3C: db $0E
L046E3D: db $10
L046E3E: db $A5
L046E3F: db $0E
L046E40: db $04
L046E41: db $4F
L046E42: db $F0
L046E43: db $0F
L046E44: db $04
L046E45: db $4F
L046E46: db $0F
L046E47: db $FF
L046E48: db $83
L046E49: db $3F
L046E4A: db $07
L046E4B: db $07
L046E4C: db $13
L046E4D: db $07
L046E4E: db $07
L046E4F: db $07
L046E50: db $E4
L046E51: db $07
L046E52: db $13
L046E53: db $07
L046E54: db $03
L046E55: db $FC
L046E56: db $05
L046E57: db $C7
L046E58: db $38
L046E59: db $03
L046E5A: db $CF
L046E5B: db $30
L046E5C: db $BB
L046E5D: db $44
L046E5E: db $A3
L046E5F: db $5C
L046E60: db $0D
L046E61: db $07
L046E62: db $F3
L046E63: db $1F
L046E64: db $05
L046E65: db $6F
L046E66: db $07
L046E67: db $0F
L046E68: db $F0
L046E69: db $1B
L046E6A: db $05
L046E6B: db $92
L046E6C: db $9F
L046E6D: db $07
L046E6E: db $F8
L046E6F: db $05
L046E70: db $0C
L046E71: db $F3
L046E72: db $45
L046E73: db $1C
L046E74: db $1E
L046E75: db $E3
L046E76: db $3D
L046E77: db $C3
L046E78: db $4F
L046E79: db $49
L046E7A: db $DD
L046E7B: db $0D
L046E7C: db $CD
L046E7D: db $28
L046E7E: db $33
L046E7F: db $DD
L046E80: db $04
L046E81: db $DC
L046E82: db $04
L046E83: db $BD
L046E84: db $42
L046E85: db $A1
L046E86: db $7F
L046E87: db $5E
L046E88: db $05
L046E89: db $17
L046E8A: db $17
L046E8B: db $0F
L046E8C: db $07
L046E8D: db $07
L046E8E: db $07
L046E8F: db $84
L046E90: db $05
L046E91: db $E1
L046E92: db $1E
L046E93: db $F6
L046E94: db $09
L046E95: db $C9
L046E96: db $67
L046E97: db $98
L046E98: db $00
L046E99: db $1F
L046E9A: db $E0
L046E9B: db $80
L046E9C: db $7F
L046E9D: db $3B
L046E9E: db $C4
L046E9F: db $FE
L046EA0: db $01
L046EA1: db $86
L046EA2: db $FF
L046EA3: db $F7
L046EA4: db $08
L046EA5: db $EB
L046EA6: db $1C
L046EA7: db $0D
L046EA8: db $21
L046EA9: db $5C
L046EAA: db $17
L046EAB: db $A3
L046EAC: db $6D
L046EAD: db $92
L046EAE: db $3E
L046EAF: db $05
L046EB0: db $0E
L046EB1: db $5C
L046EB2: db $4F
L046EB3: db $0C
L046EB4: db $17
L046EB5: db $E8
L046EB6: db $C3
L046EB7: db $3C
L046EB8: db $7F
L046EB9: db $07
L046EBA: db $EF
L046EBB: db $10
L046EBC: db $33
L046EBD: db $D7
L046EBE: db $38
L046EBF: db $38
L046EC0: db $40
L046EC1: db $C0
L046EC2: db $3F
L046EC3: db $B7
L046EC4: db $B7
L046EC5: db $80
L046EC6: db $49
L046EC7: db $18
L046EC8: db $E7
L046EC9: db $DA
L046ECA: db $25
L046ECB: db $5B
L046ECC: db $A4
L046ECD: db $07
L046ECE: db $01
L046ECF: db $F8
L046ED0: db $3D
L046ED1: db $C2
L046ED2: db $FD
L046ED3: db $02
L046ED4: db $BD
L046ED5: db $42
L046ED6: db $07
L046ED7: db $CC
L046ED8: db $07
L046ED9: db $7D
L046EDA: db $AB
L046EDB: db $54
L046EDC: db $0D
L046EDD: db $F8
L046EDE: db $FE
L046EDF: db $09
L046EE0: db $10
L046EE1: db $F6
L046EE2: db $1D
L046EE3: db $E2
L046EE4: db $07
L046EE5: db $7D
L046EE6: db $83
L046EE7: db $FC
L046EE8: db $03
L046EE9: db $CE
L046EEA: db $FF
L046EEB: db $8D
L046EEC: db $AA
L046EED: db $55
L046EEE: db $00
L046EEF: db $08
L046EF0: db $0D
L046EF1: db $CF
L046EF2: db $4F
L046EF3: db $30
L046EF4: db $37
L046EF5: db $EA
L046EF6: db $15
L046EF7: db $2F
L046EF8: db $0F
L046EF9: db $0F
L046EFA: db $0F
L046EFB: db $E0
L046EFC: db $0F
L046EFD: db $0F
L046EFE: db $6D
L046EFF: db $FB
L046F00: db $04
L046F01: db $57
L046F02: db $A8
L046F03: db $AB
L046F04: db $7E
L046F05: db $54
L046F06: db $0F
L046F07: db $0F
L046F08: db $0F
L046F09: db $0F
L046F0A: db $0F
L046F0B: db $0F
L046F0C: db $E1
L046F0D: db $01
L046F0E: db $1E
L046F0F: db $F3
L046F10: db $0E
L046F11: db $1B
L046F12: db $FC
L046F13: db $7F
L046F14: db $90
L046F15: db $0C
L046F16: db $00
L046F17: db $F6
L046F18: db $9B
L046F19: db $76
L046F1A: db $3B
L046F1B: db $C4
L046F1C: db $FE
L046F1D: db $01
L046F1E: db $75
L046F1F: db $60
L046F20: db $8A
L046F21: db $C0
L046F22: db $C8
L046F23: db $58
L046F24: db $A7
L046F25: db $E5
L046F26: db $1A
L046F27: db $A6
L046F28: db $50
L046F29: db $59
L046F2A: db $24
L046F2B: db $9A
L046F2C: db $0F
L046F2D: db $E0
L046F2E: db $1F
L046F2F: db $C8
L046F30: db $37
L046F31: db $A0
L046F32: db $6C
L046F33: db $E4
L046F34: db $05
L046F35: db $CA
L046F36: db $35
L046F37: db $61
L046F38: db $9E
L046F39: db $B9
L046F3A: db $38
L046F3B: db $46
L046F3C: db $64
L046F3D: db $90
L046F3E: db $4F
L046F3F: db $0F
L046F40: db $F7
L046F41: db $18
L046F42: db $D7
L046F43: db $78
L046F44: db $EF
L046F45: db $A5
L046F46: db $00
L046F47: db $08
L046F48: db $10
L046F49: db $10
L046F4A: db $57
L046F4B: db $B8
L046F4C: db $00
L046F4D: db $2F
L046F4E: db $D0
L046F4F: db $0F
L046F50: db $F0
L046F51: db $87
L046F52: db $7F
L046F53: db $B0
L046F54: db $4F
L046F55: db $90
L046F56: db $FD
L046F57: db $38
L046F58: db $C7
L046F59: db $5C
L046F5A: db $08
L046F5B: db $EA
L046F5C: db $1D
L046F5D: db $F4
L046F5E: db $60
L046F5F: db $0B
L046F60: db $38
L046F61: db $40
L046F62: db $E1
L046F63: db $FE
L046F64: db $0D
L046F65: db $F2
L046F66: db $DC
L046F67: db $00
L046F68: db $23
L046F69: db $1C
L046F6A: db $E3
L046F6B: db $07
L046F6C: db $F8
L046F6D: db $13
L046F6E: db $EC
L046F6F: db $7D
L046F70: db $22
L046F71: db $82
L046F72: db $FA
L046F73: db $4C
L046F74: db $D9
L046F75: db $3E
L046F76: db $C1
L046F77: db $44
L046F78: db $F1
L046F79: db $01
L046F7A: db $0E
L046F7B: db $39
L046F7C: db $CE
L046F7D: db $B9
L046F7E: db $4E
L046F7F: db $79
L046F80: db $8E
L046F81: db $0D
L046F82: db $19
L046F83: db $73
L046F84: db $9C
L046F85: db $F3
L046F86: db $68
L046F87: db $A4
L046F88: db $DB
L046F89: db $67
L046F8A: db $E4
L046F8B: db $03
L046F8C: db $EE
L046F8D: db $33
L046F8E: db $A6
L046F8F: db $59
L046F90: db $75
L046F91: db $9A
L046F92: db $0F
L046F93: db $34
L046F94: db $04
L046F95: db $18
L046F96: db $FF
L046F97: db $00
L046F98: db $7F
L046F99: db $A4
L046F9A: db $0D
L046F9B: db $43
L046F9C: db $BC
L046F9D: db $87
L046F9E: db $20
L046F9F: db $E7
L046FA0: db $A7
L046FA1: db $58
L046FA2: db $65
L046FA3: db $4F
L046FA4: db $0F
L046FA5: db $0F
L046FA6: db $C2
L046FA7: db $0F
L046FA8: db $7E
L046FA9: db $D7
L046FAA: db $2F
L046FAB: db $F0
L046FAC: db $8F
L046FAD: db $7D
L046FAE: db $6D
L046FAF: db $22
L046FB0: db $BA
L046FB1: db $FE
L046FB2: db $08
L046FB3: db $7D
L046FB4: db $82
L046FB5: db $6C
L046FB6: db $20
L046FB7: db $29
L046FB8: db $B1
L046FB9: db $18
L046FBA: db $92
L046FBB: db $1E
L046FBC: db $30
L046FBD: db $45
L046FBE: db $FB
L046FBF: db $5E
L046FC0: db $28
L046FC1: db $2A
L046FC2: db $BD
L046FC3: db $7E
L046FC4: db $08
L046FC5: db $FD
L046FC6: db $06
L046FC7: db $FA
L046FC8: db $F8
L046FC9: db $B7
L046FCA: db $AF
L046FCB: db $11
L046FCC: db $5B
L046FCD: db $88
L046FCE: db $70
L046FCF: db $07
L046FD0: db $07
L046FD1: db $07
L046FD2: db $05
L046FD3: db $3D
L046FD4: db $87
L046FD5: db $78
L046FD6: db $07
L046FD7: db $07
L046FD8: db $07
L046FD9: db $05
L046FDA: db $00
L046FDB: db $88
L046FDC: db $3F
L046FDD: db $55
L046FDE: db $AA
L046FDF: db $00
L046FE0: db $08
L046FE1: db $10
L046FE2: db $15
L046FE3: db $04
L046FE4: db $14
L046FE5: db $D7
L046FE6: db $27
L046FE7: db $08
L046FE8: db $60
L046FE9: db $14
L046FEA: db $06
L046FEB: db $04
L046FEC: db $90
L046FED: db $04
L046FEE: db $B4
L046FEF: db $55
L046FF0: db $31
L046FF1: db $0E
L046FF2: db $25
L046FF3: db $C0
L046FF4: db $04
L046FF5: db $0A
L046FF6: db $F5
L046FF7: db $22
L046FF8: db $5D
L046FF9: db $A2
L046FFA: db $55
L046FFB: db $FD
L046FFC: db $F2
L046FFD: db $5A
L046FFE: db $1C
L046FFF: db $B5
L047000: db $00
L047001: db $EA
L047002: db $5B
L047003: db $A4
L047004: db $BC
L047005: db $43
L047006: db $F0
L047007: db $0F
L047008: db $75
L047009: db $06
L04700A: db $8A
L04700B: db $FA
L04700C: db $05
L04700D: db $7F
L04700E: db $8F
L04700F: db $38
L047010: db $1C
L047011: db $7A
L047012: db $C0
L047013: db $F0
L047014: db $89
L047015: db $7C
L047016: db $83
L047017: db $DD
L047018: db $66
L047019: db $DB
L04701A: db $6C
L04701B: db $04
L04701C: db $B7
L04701D: db $48
L04701E: db $F6
L04701F: db $59
L047020: db $A6
L047021: db $04
L047022: db $F7
L047023: db $08
L047024: db $31
L047025: db $40
L047026: db $BF
L047027: db $00
L047028: db $08
L047029: db $B6
L04702A: db $6D
L04702B: db $92
L04702C: db $04
L04702D: db $EF
L04702E: db $5D
L04702F: db $4C
L047030: db $18
L047031: db $49
L047032: db $04
L047033: db $15
L047034: db $00
L047035: db $08
L047036: db $80
L047037: db $0D
L047038: db $DC
L047039: db $B3
L04703A: db $4F
L04703B: db $B0
L04703C: db $FE
L04703D: db $01
L04703E: db $6F
L04703F: db $3E
L047040: db $D8
L047041: db $27
L047042: db $04
L047043: db $2D
L047044: db $18
L047045: db $20
L047046: db $25
L047047: db $7D
L047048: db $08
L047049: db $82
L04704A: db $86
L04704B: db $79
L04704C: db $85
L04704D: db $E8
L04704E: db $F4
L04704F: db $7B
L047050: db $75
L047051: db $10
L047052: db $BB
L047053: db $2E
L047054: db $D9
L047055: db $2C
L047056: db $B2
L047057: db $B1
L047058: db $4E
L047059: db $56
L04705A: db $04
L04705B: db $AB
L04705C: db $AF
L04705D: db $50
L04705E: db $58
L04705F: db $A7
L047060: db $0C
L047061: db $53
L047062: db $35
L047063: db $04
L047064: db $CB
L047065: db $5B
L047066: db $A4
L047067: db $99
L047068: db $66
L047069: db $05
L04706A: db $57
L04706B: db $A8
L04706C: db $20
L04706D: db $ED
L04706E: db $12
L04706F: db $0C
L047070: db $A9
L047071: db $DD
L047072: db $A3
L047073: db $BA
L047074: db $45
L047075: db $08
L047076: db $9B
L047077: db $67
L047078: db $DF
L047079: db $A5
L04707A: db $65
L04707B: db $D5
L04707C: db $2A
L04707D: db $2F
L04707E: db $16
L04707F: db $D0
L047080: db $BF
L047081: db $40
L047082: db $24
L047083: db $A0
L047084: db $05
L047085: db $FC
L047086: db $C0
L047087: db $0A
L047088: db $8F
L047089: db $F0
L04708A: db $4F
L04708B: db $B0
L04708C: db $14
L04708D: db $00
L04708E: db $06
L04708F: db $04
L047090: db $09
L047091: db $F7
L047092: db $0C
L047093: db $EF
L047094: db $18
L047095: db $05
L047096: db $D7
L047097: db $38
L047098: db $6F
L047099: db $24
L04709A: db $AB
L04709B: db $5C
L04709C: db $3C
L04709D: db $1C
L04709E: db $EB
L04709F: db $04
L0470A0: db $D9
L0470A1: db $26
L0470A2: db $2E
L0470A3: db $88
L0470A4: db $77
L0470A5: db $C4
L0470A6: db $64
L0470A7: db $0D
L0470A8: db $75
L0470A9: db $94
L0470AA: db $70
L0470AB: db $38
L0470AC: db $E7
L0470AD: db $78
L0470AE: db $7C
L0470AF: db $04
L0470B0: db $74
L0470B1: db $30
L0470B2: db $07
L0470B3: db $FC
L0470B4: db $D8
L0470B5: db $B4
L0470B6: db $04
L0470B7: db $3F
L0470B8: db $04
L0470B9: db $B6
L0470BA: db $01
L0470BB: db $FD
L0470BC: db $03
L0470BD: db $B9
L0470BE: db $0E
L0470BF: db $02
L0470C0: db $0D
L0470C1: db $EF
L0470C2: db $05
L0470C3: db $7F
L0470C4: db $80
L0470C5: db $0C
L0470C6: db $F1
L0470C7: db $04
L0470C8: db $0E
L0470C9: db $25
L0470CA: db $0D
L0470CB: db $10
L0470CC: db $AF
L0470CD: db $50
L0470CE: db $19
L0470CF: db $09
L0470D0: db $55
L0470D1: db $AA
L0470D2: db $FE
L0470D3: db $41
L0470D4: db $1C
L0470D5: db $5B
L0470D6: db $AD
L0470D7: db $04
L0470D8: db $20
L0470D9: db $96
L0470DA: db $69
L0470DB: db $54
L0470DC: db $B6
L0470DD: db $B2
L0470DE: db $5F
L0470DF: db $E2
L0470E0: db $1D
L0470E1: db $D3
L0470E2: db $34
L0470E3: db $9C
L0470E4: db $E3
L0470E5: db $0C
L0470E6: db $EB
L0470E7: db $14
L0470E8: db $05
L0470E9: db $60
L0470EA: db $12
L0470EB: db $24
L0470EC: db $99
L0470ED: db $66
L0470EE: db $BF
L0470EF: db $CF
L0470F0: db $30
L0470F1: db $16
L0470F2: db $60
L0470F3: db $A1
L0470F4: db $04
L0470F5: db $70
L0470F6: db $2F
L0470F7: db $7D
L0470F8: db $A2
L0470F9: db $89
L0470FA: db $76
L0470FB: db $14
L0470FC: db $47
L0470FD: db $22
L0470FE: db $7C
L0470FF: db $1C
L047100: db $C9
L047101: db $36
L047102: db $07
L047103: db $24
L047104: db $7C
L047105: db $0D
L047106: db $18
L047107: db $E7
L047108: db $87
L047109: db $78
L04710A: db $07
L04710B: db $24
L04710C: db $28
L04710D: db $07
L04710E: db $4F
L04710F: db $D7
L047110: db $04
L047111: db $93
L047112: db $6C
L047113: db $96
L047114: db $0B
L047115: db $08
L047116: db $0F
L047117: db $E6
L047118: db $09
L047119: db $CF
L04711A: db $04
L04711B: db $FE
L04711C: db $01
L04711D: db $04
L04711E: db $15
L04711F: db $0D
L047120: db $1F
L047121: db $F6
L047122: db $FD
L047123: db $06
L047124: db $04
L047125: db $0E
L047126: db $5F
L047127: db $5F
L047128: db $87
L047129: db $9E
L04712A: db $0D
L04712B: db $AA
L04712C: db $55
L04712D: db $5F
L04712E: db $5F
L04712F: db $05
L047130: db $27
L047131: db $AF
L047132: db $4F
L047133: db $50
L047134: db $C3
L047135: db $0F
L047136: db $F0
L047137: db $7F
L047138: db $07
L047139: db $07
L04713A: db $07
L04713B: db $E4
L04713C: db $07
L04713D: db $BF
L04713E: db $BD
L04713F: db $81
L047140: db $7E
L047141: db $05
L047142: db $85
L047143: db $7A
L047144: db $D0
L047145: db $05
L047146: db $AC
L047147: db $4A
L047148: db $0D
L047149: db $87
L04714A: db $FB
L04714B: db $A7
L04714C: db $D9
L04714D: db $00
L04714E: db $A5
L04714F: db $5A
L047150: db $95
L047151: db $6A
L047152: db $93
L047153: db $6C
L047154: db $91
L047155: db $6E
L047156: db $83
L047157: db $20
L047158: db $36
L047159: db $F1
L04715A: db $0E
L04715B: db $E1
L04715C: db $1E
L04715D: db $05
L04715E: db $44
L04715F: db $7F
L047160: db $58
L047161: db $07
L047162: db $BF
L047163: db $BF
L047164: db $BD
L047165: db $45
L047166: db $15
L047167: db $65
L047168: db $E1
L047169: db $05
L04716A: db $3F
L04716B: db $3F
L04716C: db $DC
L04716D: db $A3
L04716E: db $5E
L04716F: db $A1
L047170: db $B8
L047171: db $B4
L047172: db $C0
L047173: db $5C
L047174: db $14
L047175: db $1C
L047176: db $23
L047177: db $05
L047178: db $5F
L047179: db $A2
L04717A: db $03
L04717B: db $9E
L04717C: db $63
L04717D: db $2C
L04717E: db $D3
L04717F: db $2A
L047180: db $D5
L047181: db $3D
L047182: db $0D
L047183: db $02
L047184: db $0C
L047185: db $F3
L047186: db $3E
L047187: db $D1
L047188: db $7D
L047189: db $8A
L04718A: db $84
L04718B: db $80
L04718C: db $71
L04718D: db $9D
L04718E: db $44
L04718F: db $05
L047190: db $1C
L047191: db $83
L047192: db $3D
L047193: db $C2
L047194: db $BF
L047195: db $9F
L047196: db $BF
L047197: db $D7
L047198: db $28
L047199: db $15
L04719A: db $06
L04719B: db $5C
L04719C: db $3F
L04719D: db $3F
L04719E: db $E0
L04719F: db $33
L0471A0: db $07
L0471A1: db $05
L0471A2: db $FC
L0471A3: db $03
L0471A4: db $FE
L0471A5: db $01
L0471A6: db $CF
L0471A7: db $04
L0471A8: db $30
L0471A9: db $DF
L0471AA: db $60
L0471AB: db $C1
L0471AC: db $7E
L0471AD: db $05
L0471AE: db $02
L0471AF: db $FD
L0471B0: db $90
L0471B1: db $07
L0471B2: db $04
L0471B3: db $FB
L0471B4: db $05
L0471B5: db $B7
L0471B6: db $48
L0471B7: db $7B
L0471B8: db $B4
L0471B9: db $F9
L0471BA: db $05
L0471BB: db $15
L0471BC: db $BF
L0471BD: db $BF
L0471BE: db $4F
L0471BF: db $5D
L0471C0: db $A2
L0471C1: db $1D
L0471C2: db $FE
L0471C3: db $3F
L0471C4: db $3F
L0471C5: db $1F
L0471C6: db $07
L0471C7: db $07
L0471C8: db $07
L0471C9: db $3F
L0471CA: db $70
L0471CB: db $0F
L0471CC: db $8F
L0471CD: db $71
L0471CE: db $FE
L0471CF: db $01
L0471D0: db $04
L0471D1: db $FD
L0471D2: db $05
L0471D3: db $AD
L0471D4: db $FC
L0471D5: db $4F
L0471D6: db $90
L0471D7: db $98
L0471D8: db $9F
L0471D9: db $6F
L0471DA: db $FF
L0471DB: db $08
L0471DC: db $F7
L0471DD: db $F0
L0471DE: db $3F
L0471DF: db $3F
L0471E0: db $3F
L0471E1: db $A1
L0471E2: db $BB
L0471E3: db $5C
L0471E4: db $9B
L0471E5: db $64
L0471E6: db $20
L0471E7: db $03
L0471E8: db $FC
L0471E9: db $BD
L0471EA: db $07
L0471EB: db $F8
L0471EC: db $0F
L0471ED: db $F0
L0471EE: db $1E
L0471EF: db $18
L0471F0: db $E1
L0471F1: db $B1
L0471F2: db $CF
L0471F3: db $18
L0471F4: db $20
L0471F5: db $F4
L0471F6: db $0B
L0471F7: db $EE
L0471F8: db $20
L0471F9: db $1D
L0471FA: db $77
L0471FB: db $08
L0471FC: db $ED
L0471FD: db $76
L0471FE: db $BA
L0471FF: db $75
L047200: db $5A
L047201: db $41
L047202: db $BD
L047203: db $20
L047204: db $E2
L047205: db $3B
L047206: db $C5
L047207: db $7B
L047208: db $85
L047209: db $18
L04720A: db $72
L04720B: db $42
L04720C: db $BF
L04720D: db $BF
L04720E: db $04
L04720F: db $5D
L047210: db $EC
L047211: db $B8
L047212: db $DA
L047213: db $1C
L047214: db $AD
L047215: db $B3
L047216: db $4C
L047217: db $3F
L047218: db $3F
L047219: db $D8
L04721A: db $C1
L04721B: db $1F
L04721C: db $93
L04721D: db $D4
L04721E: db $06
L04721F: db $F9
L047220: db $FC
L047221: db $FD
L047222: db $02
L047223: db $04
L047224: db $0C
L047225: db $72
L047226: db $FC
L047227: db $07
L047228: db $28
L047229: db $30
L04722A: db $FB
L04722B: db $25
L04722C: db $5C
L04722D: db $01
L04722E: db $A8
L04722F: db $30
L047230: db $22
L047231: db $0C
L047232: db $84
L047233: db $75
L047234: db $27
L047235: db $D8
L047236: db $A7
L047237: db $10
L047238: db $58
L047239: db $07
L04723A: db $F8
L04723B: db $05
L04723C: db $AF
L04723D: db $50
L04723E: db $5F
L04723F: db $A0
L047240: db $C0
L047241: db $BF
L047242: db $BF
L047243: db $DF
L047244: db $20
L047245: db $0F
L047246: db $F7
L047247: db $98
L047248: db $67
L047249: db $81
L04724A: db $CC
L04724B: db $E0
L04724C: db $3D
L04724D: db $E6
L04724E: db $CD
L04724F: db $F6
L047250: db $0D
L047251: db $07
L047252: db $87
L047253: db $04
L047254: db $8D
L047255: db $76
L047256: db $AD
L047257: db $56
L047258: db $05
L047259: db $C4
L04725A: db $DC
L04725B: db $FF
L04725C: db $25
L04725D: db $0D
L04725E: db $A5
L04725F: db $80
L047260: db $88
L047261: db $9D
L047262: db $07
L047263: db $07
L047264: db $80
L047265: db $07
L047266: db $1A
L047267: db $40
L047268: db $5B
L047269: db $01
L04726A: db $02
L04726B: db $04
L04726C: db $14
L04726D: db $01
L04726E: db $06
L04726F: db $23
L047270: db $03
L047271: db $49
L047272: db $08
L047273: db $48
L047274: db $0B
L047275: db $0D
L047276: db $06
L047277: db $02
L047278: db $03
L047279: db $D1
L04727A: db $BD
L04727B: db $18
L04727C: db $05
L04727D: db $11
L04727E: db $29
L04727F: db $00
L047280: db $10
L047281: db $07
L047282: db $11
L047283: db $CB
L047284: db $41
L047285: db $F2
L047286: db $09
L047287: db $0A
L047288: db $80
L047289: db $0C
L04728A: db $FF
L04728B: db $D9
L04728C: db $DF
L04728D: db $08
L04728E: db $02
L04728F: db $03
L047290: db $11
L047291: db $C9
L047292: db $00
L047293: db $F8
L047294: db $32
L047295: db $D1
L047296: db $70
L047297: db $18
L047298: db $12
L047299: db $10
L04729A: db $14
L04729B: db $15
L04729C: db $17
L04729D: db $FF
L04729E: db $9A
L04729F: db $00
L0472A0: db $0E
L0472A1: db $0F
L0472A2: db $70
L0472A3: db $00
L0472A4: db $10
L0472A5: db $20
L0472A6: db $11
L0472A7: db $FC
L0472A8: db $00
L0472A9: db $3A
L0472AA: db $F9
L0472AB: db $20
L0472AC: db $08
L0472AD: db $3A
L0472AE: db $0B
L0472AF: db $13
L0472B0: db $57
L0472B1: db $16
L0472B2: db $00
L0472B3: db $18
L0472B4: db $20
L0472B5: db $19
L0472B6: db $C8
L0472B7: db $09
L0472B8: db $13
L0472B9: db $05
L0472BA: db $1A
L0472BB: db $1B
L0472BC: db $1D
L0472BD: db $1E
L0472BE: db $1F
L0472BF: db $20
L0472C0: db $22
L0472C1: db $00
L0472C2: db $FB
L0472C3: db $3B
L0472C4: db $E8
L0472C5: db $20
L0472C6: db $08
L0472C7: db $3A
L0472C8: db $0C
L0472C9: db $FB
L0472CA: db $20
L0472CB: db $74
L0472CC: db $25
L0472CD: db $C8
L0472CE: db $09
L0472CF: db $13
L0472D0: db $1C
L0472D1: db $02
L0472D2: db $20
L0472D3: db $21
L0472D4: db $7C
L0472D5: db $23
L0472D6: db $33
L0472D7: db $00
L0472D8: db $E8
L0472D9: db $0A
L0472DA: db $01
L0472DB: db $0B
L0472DC: db $05
L0472DD: db $76
L0472DE: db $24
L0472DF: db $00
L0472E0: db $F9
L0472E1: db $C0
L0472E2: db $26
L0472E3: db $30
L0472E4: db $10
L0472E5: db $27
L0472E6: db $D0
L0472E7: db $10
L0472E8: db $19
L0472E9: db $28
L0472EA: db $00
L0472EB: db $2A
L0472EC: db $2B
L0472ED: db $2C
L0472EE: db $2D
L0472EF: db $7D
L0472F0: db $2E
L0472F1: db $31
L0472F2: db $3A
L0472F3: db $E8
L0472F4: db $18
L0472F5: db $09
L0472F6: db $38
L0472F7: db $08
L0472F8: db $1A
L0472F9: db $34
L0472FA: db $35
L0472FB: db $16
L0472FC: db $00
L0472FD: db $F8
L0472FE: db $0B
L0472FF: db $FF
L047300: db $29
L047301: db $85
L047302: db $04
L047303: db $2F
L047304: db $30
L047305: db $31
L047306: db $32
L047307: db $58
L047308: db $33
L047309: db $C9
L04730A: db $02
L04730B: db $36
L04730C: db $37
L04730D: db $39
L04730E: db $3A
L04730F: db $3B
L047310: db $3C
L047311: db $62
L047312: db $0C
L047313: db $F9
L047314: db $F9
L047315: db $60
L047316: db $F9
L047317: db $58
L047318: db $19
L047319: db $3D
L04731A: db $3E
L04731B: db $09
L04731C: db $00
L04731D: db $08
L04731E: db $41
L04731F: db $43
L047320: db $44
L047321: db $47
L047322: db $48
L047323: db $4B
L047324: db $4C
L047325: db $01
L047326: db $4F
L047327: db $50
L047328: db $53
L047329: db $54
L04732A: db $57
L04732B: db $58
L04732C: db $05
L04732D: db $00
L04732E: db $B2
L04732F: db $62
L047330: db $5A
L047331: db $BB
L047332: db $0B
L047333: db $3F
L047334: db $40
L047335: db $09
L047336: db $42
L047337: db $80
L047338: db $00
L047339: db $45
L04733A: db $46
L04733B: db $49
L04733C: db $4A
L04733D: db $4D
L04733E: db $4E
L04733F: db $51
L047340: db $0E
L047341: db $52
L047342: db $55
L047343: db $56
L047344: db $59
L047345: db $50
L047346: db $69
L047347: db $62
L047348: db $5B
L047349: db $DE
L04734A: db $BB
L04734B: db $0B
L04734C: db $5C
L04734D: db $07
L04734E: db $07
L04734F: db $07
L047350: db $06
L047351: db $01
L047352: db $FF
L047353: db $07
L047354: db $07
L047355: db $07
L047356: db $07
L047357: db $07
L047358: db $07
L047359: db $07
L04735A: db $06
L04735B: db $00;X
L04735C: db $79
L04735D: db $80
L04735E: db $7B
L04735F: db $00
L047360: db $03
L047361: db $03
L047362: db $03
L047363: db $02
L047364: db $FF
L047365: db $02
L047366: db $12
L047367: db $CC
L047368: db $09
L047369: db $06
L04736A: db $AA
L04736B: db $55
L04736C: db $00
L04736D: db $08
L04736E: db $EB
L04736F: db $7C
L047370: db $3F
L047371: db $F1
L047372: db $7E
L047373: db $0F
L047374: db $0F
L047375: db $0F
L047376: db $55
L047377: db $61
L047378: db $50
L047379: db $F8
L04737A: db $04
L04737B: db $5C
L04737C: db $8F
L04737D: db $B3
L04737E: db $96
L04737F: db $D5
L047380: db $7A
L047381: db $A3
L047382: db $C5
L047383: db $5C
L047384: db $3C
L047385: db $BA
L047386: db $E3
L047387: db $3C
L047388: db $BE
L047389: db $7F
L04738A: db $0D
L04738B: db $5E
L04738C: db $3F
L04738D: db $08
L04738E: db $5F
L04738F: db $04
L047390: db $0F
L047391: db $0F
L047392: db $0F
L047393: db $8B
L047394: db $1F
L047395: db $F4
L047396: db $45
L047397: db $FA
L047398: db $0F
L047399: db $0F
L04739A: db $0F
L04739B: db $D7
L04739C: db $01
L04739D: db $F2
L04739E: db $FD
L04739F: db $AC
L0473A0: db $EE
L0473A1: db $0F
L0473A2: db $FD
L0473A3: db $FE
L0473A4: db $05
L0473A5: db $0D
L0473A6: db $99
L0473A7: db $04
L0473A8: db $F1
L0473A9: db $0E
L0473AA: db $25
L0473AB: db $05
L0473AC: db $AF
L0473AD: db $50
L0473AE: db $5C
L0473AF: db $C3
L0473B0: db $49
L0473B1: db $14
L0473B2: db $C5
L0473B3: db $7A
L0473B4: db $A3
L0473B5: db $7C
L0473B6: db $0D
L0473B7: db $20
L0473B8: db $59
L0473B9: db $75
L0473BA: db $25
L0473BB: db $81
L0473BC: db $5C
L0473BD: db $B7
L0473BE: db $DD
L0473BF: db $22
L0473C0: db $54
L0473C1: db $7C
L0473C2: db $BB
L0473C3: db $07
L0473C4: db $05
L0473C5: db $24
L0473C6: db $92
L0473C7: db $D6
L0473C8: db $5F
L0473C9: db $5D
L0473CA: db $80
L0473CB: db $08
L0473CC: db $56
L0473CD: db $AD
L0473CE: db $6F
L0473CF: db $94
L0473D0: db $6A
L0473D1: db $97
L0473D2: db $DF
L0473D3: db $1A
L0473D4: db $E0
L0473D5: db $1C
L0473D6: db $EB
L0473D7: db $3D
L0473D8: db $5C
L0473D9: db $FA
L0473DA: db $69
L0473DB: db $6B
L0473DC: db $08
L0473DD: db $B5
L0473DE: db $F7
L0473DF: db $29
L0473E0: db $D5
L0473E1: db $2C
L0473E2: db $F9
L0473E3: db $07
L0473E4: db $38
L0473E5: db $6B
L0473E6: db $D7
L0473E7: db $81
L0473E8: db $01
L0473E9: db $F0
L0473EA: db $04
L0473EB: db $0F
L0473EC: db $09
L0473ED: db $A9
L0473EE: db $DF
L0473EF: db $04
L0473F0: db $60
L0473F1: db $05
L0473F2: db $60
L0473F3: db $A4
L0473F4: db $1F
L0473F5: db $07
L0473F6: db $07
L0473F7: db $86
L0473F8: db $07
L0473F9: db $D2
L0473FA: db $7D
L0473FB: db $A1
L0473FC: db $7E
L0473FD: db $0F
L0473FE: db $0C
L0473FF: db $3D
L047400: db $00
L047401: db $61
L047402: db $BE
L047403: db $FE
L047404: db $11
L047405: db $F5
L047406: db $4E
L047407: db $EE
L047408: db $5F
L047409: db $6F
L04740A: db $AE
L04740B: db $90
L04740C: db $F0
L04740D: db $6A
L04740E: db $66
L04740F: db $44
L047410: db $FC
L047411: db $04
L047412: db $90
L047413: db $0C
L047414: db $54
L047415: db $B1
L047416: db $0C
L047417: db $AF
L047418: db $7F
L047419: db $95
L04741A: db $6E
L04741B: db $41
L04741C: db $BF
L04741D: db $44
L04741E: db $96
L04741F: db $6D
L047420: db $CD
L047421: db $3E
L047422: db $57
L047423: db $18
L047424: db $1C
L047425: db $CB
L047426: db $3F
L047427: db $40
L047428: db $0C
L047429: db $84
L04742A: db $90
L04742B: db $A9
L04742C: db $76
L04742D: db $8A
L04742E: db $B8
L04742F: db $AA
L047430: db $69
L047431: db $B6
L047432: db $65
L047433: db $E9
L047434: db $24
L047435: db $D3
L047436: db $37
L047437: db $FD
L047438: db $02
L047439: db $04
L04743A: db $A5
L04743B: db $80
L04743C: db $84
L04743D: db $0C
L04743E: db $00
L04743F: db $FF
L047440: db $AC
L047441: db $0D
L047442: db $8C
L047443: db $E0
L047444: db $08
L047445: db $78
L047446: db $04
L047447: db $0D
L047448: db $9D
L047449: db $3D
L04744A: db $07
L04744B: db $F8
L04744C: db $00
L04744D: db $31
L04744E: db $04
L04744F: db $FA
L047450: db $08
L047451: db $46
L047452: db $47
L047453: db $18
L047454: db $8B
L047455: db $F4
L047456: db $45
L047457: db $18
L047458: db $05
L047459: db $83
L04745A: db $74
L04745B: db $FC
L04745C: db $0D
L04745D: db $25
L04745E: db $35
L04745F: db $8A
L047460: db $E8
L047461: db $77
L047462: db $88
L047463: db $34
L047464: db $AF
L047465: db $72
L047466: db $0C
L047467: db $2C
L047468: db $75
L047469: db $F4
L04746A: db $AD
L04746B: db $56
L04746C: db $EC
L04746D: db $95
L04746E: db $04
L04746F: db $FC
L047470: db $AB
L047471: db $04
L047472: db $0C
L047473: db $2A
L047474: db $81
L047475: db $B2
L047476: db $0C
L047477: db $B3
L047478: db $74
L047479: db $E8
L04747A: db $BF
L04747B: db $D1
L04747C: db $04
L04747D: db $DA
L04747E: db $1F
L04747F: db $BD
L047480: db $DD
L047481: db $BE
L047482: db $EC
L047483: db $5C
L047484: db $24
L047485: db $40
L047486: db $04
L047487: db $08
L047488: db $C0
L047489: db $D6
L04748A: db $2B
L04748B: db $4E
L04748C: db $48
L04748D: db $4F
L04748E: db $B0
L04748F: db $4C
L047490: db $42
L047491: db $B7
L047492: db $05
L047493: db $CC
L047494: db $37
L047495: db $0C
L047496: db $F7
L047497: db $70
L047498: db $07
L047499: db $81
L04749A: db $38
L04749B: db $D4
L04749C: db $32
L04749D: db $CD
L04749E: db $F2
L04749F: db $0D
L0474A0: db $52
L0474A1: db $C8
L0474A2: db $0E
L0474A3: db $B2
L0474A4: db $4D
L0474A5: db $53
L0474A6: db $AC
L0474A7: db $58
L0474A8: db $60
L0474A9: db $8C
L0474AA: db $A0
L0474AB: db $EB
L0474AC: db $45
L0474AD: db $90
L0474AE: db $00
L0474AF: db $8F
L0474B0: db $04
L0474B1: db $5E
L0474B2: db $C4
L0474B3: db $B8
L0474B4: db $E6
L0474B5: db $A8
L0474B6: db $E1
L0474B7: db $04
L0474B8: db $D7
L0474B9: db $7C
L0474BA: db $24
L0474BB: db $20
L0474BC: db $40
L0474BD: db $F9
L0474BE: db $4D
L0474BF: db $0F
L0474C0: db $0F
L0474C1: db $0F
L0474C2: db $40
L0474C3: db $01
L0474C4: db $FE
L0474C5: db $08
L0474C6: db $42
L0474C7: db $92
L0474C8: db $04
L0474C9: db $EE
L0474CA: db $57
L0474CB: db $D6
L0474CC: db $6F
L0474CD: db $1C
L0474CE: db $79
L0474CF: db $F7
L0474D0: db $04
L0474D1: db $2D
L0474D2: db $04
L0474D3: db $28
L0474D4: db $00
L0474D5: db $07
L0474D6: db $07
L0474D7: db $05
L0474D8: db $A2
L0474D9: db $3F
L0474DA: db $FA
L0474DB: db $FC
L0474DC: db $EC
L0474DD: db $1F
L0474DE: db $98
L0474DF: db $E4
L0474E0: db $39
L0474E1: db $AD
L0474E2: db $30
L0474E3: db $71
L0474E4: db $04
L0474E5: db $F1
L0474E6: db $14
L0474E7: db $04
L0474E8: db $0F
L0474E9: db $3D
L0474EA: db $80
L0474EB: db $CC
L0474EC: db $E0
L0474ED: db $9F
L0474EE: db $F0
L0474EF: db $CF
L0474F0: db $F8
L0474F1: db $C7
L0474F2: db $FC
L0474F3: db $57
L0474F4: db $C3
L0474F5: db $28
L0474F6: db $E3
L0474F7: db $0C
L0474F8: db $EF
L0474F9: db $24
L0474FA: db $8D
L0474FB: db $10
L0474FC: db $FF
L0474FD: db $7C
L0474FE: db $07
L0474FF: db $07
L047500: db $07
L047501: db $05
L047502: db $7C
L047503: db $94
L047504: db $04
L047505: db $00
L047506: db $47
L047507: db $AF
L047508: db $72
L047509: db $B2
L04750A: db $7D
L04750B: db $7A
L04750C: db $F5
L04750D: db $79
L04750E: db $7E
L04750F: db $F6
L047510: db $10
L047511: db $F0
L047512: db $30
L047513: db $80
L047514: db $00
L047515: db $48
L047516: db $FB
L047517: db $53
L047518: db $1C
L047519: db $14
L04751A: db $B8
L04751B: db $14
L04751C: db $78
L04751D: db $77
L04751E: db $CC
L04751F: db $C0
L047520: db $4C
L047521: db $71
L047522: db $04
L047523: db $F1
L047524: db $EE
L047525: db $04
L047526: db $24
L047527: db $80
L047528: db $3C
L047529: db $CA
L04752A: db $4D
L04752B: db $88
L04752C: db $DF
L04752D: db $BC
L04752E: db $04
L04752F: db $BA
L047530: db $06
L047531: db $B5
L047532: db $D6
L047533: db $24
L047534: db $04
L047535: db $E3
L047536: db $74
L047537: db $C3
L047538: db $40
L047539: db $1C
L04753A: db $2C
L04753B: db $87
L04753C: db $1C
L04753D: db $18
L04753E: db $C1
L04753F: db $7E
L047540: db $89
L047541: db $07
L047542: db $04
L047543: db $24
L047544: db $6F
L047545: db $00
L047546: db $79
L047547: db $0B
L047548: db $FD
L047549: db $B0
L04754A: db $07
L04754B: db $05
L04754C: db $F8
L04754D: db $04
L04754E: db $03
L04754F: db $F6
L047550: db $49
L047551: db $BE
L047552: db $4D
L047553: db $C0
L047554: db $40
L047555: db $9D
L047556: db $04
L047557: db $6A
L047558: db $E9
L047559: db $16
L04755A: db $C9
L04755B: db $36
L04755C: db $05
L04755D: db $8F
L04755E: db $70
L04755F: db $20
L047560: db $6F
L047561: db $B0
L047562: db $74
L047563: db $30
L047564: db $DB
L047565: db $24
L047566: db $A7
L047567: db $78
L047568: db $83
L047569: db $04
L04756A: db $5C
L04756B: db $BD
L04756C: db $7A
L04756D: db $99
L04756E: db $66
L04756F: db $B3
L047570: db $0B
L047571: db $EC
L047572: db $09
L047573: db $03
L047574: db $02
L047575: db $01
L047576: db $C8
L047577: db $04
L047578: db $FB
L047579: db $0D
L04757A: db $C8
L04757B: db $14
L04757C: db $04
L04757D: db $E3
L04757E: db $3E
L04757F: db $04
L047580: db $3C
L047581: db $F3
L047582: db $1C
L047583: db $24
L047584: db $DF
L047585: db $28
L047586: db $35
L047587: db $FC
L047588: db $03
L047589: db $05
L04758A: db $F8
L04758B: db $07
L04758C: db $81
L04758D: db $05
L04758E: db $F0
L04758F: db $0F
L047590: db $E0
L047591: db $1F
L047592: db $80
L047593: db $7F
L047594: db $A6
L047595: db $05
L047596: db $C3
L047597: db $7C
L047598: db $83
L047599: db $CF
L04759A: db $30
L04759B: db $14
L04759C: db $06
L04759D: db $6C
L04759E: db $95
L04759F: db $EC
L0475A0: db $EF
L0475A1: db $76
L0475A2: db $14
L0475A3: db $02
L0475A4: db $40
L0475A5: db $81
L0475A6: db $18
L0475A7: db $00
L0475A8: db $99
L0475A9: db $3F
L0475AA: db $D9
L0475AB: db $36
L0475AC: db $C9
L0475AD: db $7B
L0475AE: db $95
L0475AF: db $B8
L0475B0: db $40
L0475B1: db $57
L0475B2: db $20
L0475B3: db $67
L0475B4: db $90
L0475B5: db $6F
L0475B6: db $BE
L0475B7: db $41
L0475B8: db $5E
L0475B9: db $43
L0475BA: db $A1
L0475BB: db $0F
L0475BC: db $BD
L0475BD: db $42
L0475BE: db $5D
L0475BF: db $A2
L0475C0: db $0F
L0475C1: db $BE
L0475C2: db $E8
L0475C3: db $0B
L0475C4: db $0A
L0475C5: db $00
L0475C6: db $F1
L0475C7: db $04
L0475C8: db $E0
L0475C9: db $F9
L0475CA: db $E6
L0475CB: db $8D
L0475CC: db $0C
L0475CD: db $40
L0475CE: db $77
L0475CF: db $98
L0475D0: db $0C
L0475D1: db $05
L0475D2: db $80
L0475D3: db $BC
L0475D4: db $46
L0475D5: db $84
L0475D6: db $0C
L0475D7: db $04
L0475D8: db $DF
L0475D9: db $78
L0475DA: db $5D
L0475DB: db $20
L0475DC: db $7F
L0475DD: db $3F
L0475DE: db $C0
L0475DF: db $BF
L0475E0: db $48
L0475E1: db $04
L0475E2: db $15
L0475E3: db $07
L0475E4: db $05
L0475E5: db $3D
L0475E6: db $A1
L0475E7: db $11
L0475E8: db $67
L0475E9: db $74
L0475EA: db $3F
L0475EB: db $D8
L0475EC: db $37
L0475ED: db $C8
L0475EE: db $7C
L0475EF: db $00
L0475F0: db $94
L0475F1: db $B9
L0475F2: db $56
L0475F3: db $99
L0475F4: db $66
L0475F5: db $91
L0475F6: db $6E
L0475F7: db $81
L0475F8: db $01
L0475F9: db $7E
L0475FA: db $93
L0475FB: db $6D
L0475FC: db $FE
L0475FD: db $01
L0475FE: db $55
L0475FF: db $AA
L047600: db $07
L047601: db $EA
L047602: db $05
L047603: db $7D
L047604: db $A8
L047605: db $EB
L047606: db $04
L047607: db $E1
L047608: db $04
L047609: db $C9
L04760A: db $88
L04760B: db $94
L04760C: db $AD
L04760D: db $79
L04760E: db $A6
L04760F: db $58
L047610: db $DE
L047611: db $6B
L047612: db $DC
L047613: db $1E
L047614: db $61
L047615: db $9E
L047616: db $FD
L047617: db $70
L047618: db $07
L047619: db $07
L04761A: db $07
L04761B: db $F1
L04761C: db $99
L04761D: db $04
L04761E: db $0F
L04761F: db $F0
L047620: db $8D
L047621: db $05
L047622: db $F5
L047623: db $0A
L047624: db $B1
L047625: db $07
L047626: db $54
L047627: db $AB
L047628: db $A0
L047629: db $5F
L04762A: db $40
L04762B: db $A8
L04762C: db $2C
L04762D: db $03
L04762E: db $FE
L04762F: db $03
L047630: db $02
L047631: db $61
L047632: db $09
L047633: db $97
L047634: db $07
L047635: db $05
L047636: db $01
L047637: db $FF
L047638: db $04
L047639: db $A7
L04763A: db $07
L04763B: db $AD
L04763C: db $00
L04763D: db $08
L04763E: db $23
L04763F: db $07
L047640: db $FF
L047641: db $09
L047642: db $2D
L047643: db $3D
L047644: db $27
L047645: db $07
L047646: db $3E
L047647: db $94
L047648: db $B3
L047649: db $9F
L04764A: db $14
L04764B: db $FC
L04764C: db $02
L04764D: db $0D
L04764E: db $C1
L04764F: db $04
L047650: db $4B
L047651: db $20
L047652: db $10
L047653: db $22
L047654: db $F9
L047655: db $06
L047656: db $24
L047657: db $21
L047658: db $F7
L047659: db $0A
L04765A: db $E5
L04765B: db $00
L04765C: db $1E
L04765D: db $D7
L04765E: db $B8
L04765F: db $9D
L047660: db $62
L047661: db $AB
L047662: db $54
L047663: db $D6
L047664: db $00
L047665: db $29
L047666: db $F4
L047667: db $0B
L047668: db $79
L047669: db $96
L04766A: db $73
L04766B: db $8C
L04766C: db $27
L04766D: db $00
L04766E: db $D8
L04766F: db $4F
L047670: db $B0
L047671: db $B3
L047672: db $CC
L047673: db $24
L047674: db $DB
L047675: db $64
L047676: db $1B
L047677: db $9B
L047678: db $A4
L047679: db $5B
L04767A: db $05
L04767B: db $9C
L04767C: db $08
L04767D: db $AF
L04767E: db $06
L04767F: db $04
L047680: db $88
L047681: db $AF
L047682: db $50
L047683: db $FA
L047684: db $25
L047685: db $94
L047686: db $57
L047687: db $8A
L047688: db $57
L047689: db $77
L04768A: db $2D
L04768B: db $AA
L04768C: db $14
L04768D: db $FB
L04768E: db $B4
L04768F: db $4B
L047690: db $07
L047691: db $ED
L047692: db $7F
L047693: db $07
L047694: db $74
L047695: db $51
L047696: db $4D
L047697: db $7C
L047698: db $55
L047699: db $64
L04769A: db $F1
L04769B: db $04
L04769C: db $3F
L04769D: db $07
L04769E: db $04
L04769F: db $EE
L0476A0: db $95
L0476A1: db $6E
L0476A2: db $44
L0476A3: db $00
L0476A4: db $04
L0476A5: db $CE
L0476A6: db $35
L0476A7: db $D5
L0476A8: db $2A
L0476A9: db $D9
L0476AA: db $26
L0476AB: db $DE
L0476AC: db $43
L0476AD: db $29
L0476AE: db $30
L0476AF: db $15
L0476B0: db $FD
L0476B1: db $FE
L0476B2: db $01
L0476B3: db $04
L0476B4: db $55
L0476B5: db $1F
L0476B6: db $7F
L0476B7: db $80
L0476B8: db $6A
L0476B9: db $58
L0476BA: db $91
L0476BB: db $10
L0476BC: db $19
L0476BD: db $04
L0476BE: db $9F
L0476BF: db $09
L0476C0: db $F1
L0476C1: db $0E
L0476C2: db $BA
L0476C3: db $04
L0476C4: db $BF
L0476C5: db $07
L0476C6: db $04
L0476C7: db $F0
L0476C8: db $00
L0476C9: db $7D
L0476CA: db $89
L0476CB: db $11
L0476CC: db $AF
L0476CD: db $50
L0476CE: db $58
L0476CF: db $A7
L0476D0: db $0F
L0476D1: db $0F
L0476D2: db $F7
L0476D3: db $3F
L0476D4: db $C0
L0476D5: db $4F
L0476D6: db $52
L0476D7: db $01
L0476D8: db $17
L0476D9: db $C1
L0476DA: db $16
L0476DB: db $44
L0476DC: db $D9
L0476DD: db $1F
L0476DE: db $E0
L0476DF: db $3E
L0476E0: db $C1
L0476E1: db $1C
L0476E2: db $03
L0476E3: db $10
L0476E4: db $FC
L0476E5: db $03
L0476E6: db $F8
L0476E7: db $07
L0476E8: db $F0
L0476E9: db $80
L0476EA: db $28
L0476EB: db $FD
L0476EC: db $30
L0476ED: db $4F
L0476EE: db $F9
L0476EF: db $FD
L0476F0: db $EB
L0476F1: db $07
L0476F2: db $FD
L0476F3: db $F1
L0476F4: db $D0
L0476F5: db $04
L0476F6: db $1A
L0476F7: db $80
L0476F8: db $0D
L0476F9: db $15
L0476FA: db $EA
L0476FB: db $FA
L0476FC: db $E5
L0476FD: db $D0
L0476FE: db $95
L0476FF: db $04
L047700: db $FB
L047701: db $0D
L047702: db $A8
L047703: db $57
L047704: db $54
L047705: db $AB
L047706: db $FF
L047707: db $6F
L047708: db $07
L047709: db $BA
L04770A: db $0B
L04770B: db $06
L04770C: db $CD
L04770D: db $DD
L04770E: db $BF
L04770F: db $FF
L047710: db $BF
L047711: db $07
L047712: db $3F
L047713: db $23
L047714: db $07
L047715: db $07
L047716: db $07
L047717: db $BF
L047718: db $FF
L047719: db $03
L04771A: db $CF
L04771B: db $07
L04771C: db $8D
L04771D: db $BD
L04771E: db $07
L04771F: db $D7
L047720: db $3F
L047721: db $FF
L047722: db $05
L047723: db $CF
L047724: db $07
L047725: db $07
L047726: db $07
L047727: db $3D
L047728: db $8D
L047729: db $1F
L04772A: db $FF
L04772B: db $07
L04772C: db $07
L04772D: db $03
L04772E: db $03
L04772F: db $01
L047730: db $2E
L047731: db $42
L047732: db $EF
L047733: db $DF
L047734: db $07
L047735: db $07
L047736: db $01
L047737: db $04
L047738: db $53
L047739: db $03
L04773A: db $03
L04773B: db $03
L04773C: db $58
L04773D: db $0F
L04773E: db $04
L04773F: db $F0
L047740: db $09
L047741: db $96
L047742: db $57
L047743: db $A8
L047744: db $AA
L047745: db $64
L047746: db $55
L047747: db $00
L047748: db $08
L047749: db $0A
L04774A: db $F5
L04774B: db $85
L04774C: db $3B
L04774D: db $C4
L04774E: db $2F
L04774F: db $D5
L047750: db $BA
L047751: db $0C
L047752: db $C6
L047753: db $4F
L047754: db $09
L047755: db $44
L047756: db $04
L047757: db $F0
L047758: db $48
L047759: db $23
L04775A: db $07
L04775B: db $04
L04775C: db $03
L04775D: db $FC
L04775E: db $77
L04775F: db $8B
L047760: db $5C
L047761: db $EB
L047762: db $08
L047763: db $B9
L047764: db $04
L047765: db $2F
L047766: db $07
L047767: db $C0
L047768: db $3F
L047769: db $14
L04776A: db $EE
L04776B: db $D1
L04776C: db $D7
L04776D: db $08
L04776E: db $9D
L04776F: db $04
L047770: db $54
L047771: db $BB
L047772: db $0E
L047773: db $E7
L047774: db $58
L047775: db $59
L047776: db $A6
L047777: db $4B
L047778: db $BF
L047779: db $BD
L04777A: db $2A
L04777B: db $47
L04777C: db $DD
L04777D: db $3C
L04777E: db $1B
L04777F: db $9A
L047780: db $65
L047781: db $3F
L047782: db $3F
L047783: db $3D
L047784: db $FA
L047785: db $1D
L047786: db $14
L047787: db $10
L047788: db $00
L047789: db $08
L04778A: db $81
L04778B: db $42
L04778C: db $30
L04778D: db $F6
L04778E: db $53
L04778F: db $3F
L047790: db $3F
L047791: db $18
L047792: db $0C
L047793: db $37
L047794: db $06
L047795: db $80
L047796: db $7F
L047797: db $7F
L047798: db $17
L047799: db $07
L04779A: db $07
L04779B: db $7E
L04779C: db $03
L04779D: db $03
L04779E: db $03
L04779F: db $80
L0477A0: db $02
L0477A1: db $00
L0477A2: db $16
L0477A3: db $40
L0477A4: db $0A
L0477A5: db $01
L0477A6: db $02
L0477A7: db $05
L0477A8: db $06
L0477A9: db $10
L0477AA: db $08
L0477AB: db $19
L0477AC: db $0D
L0477AD: db $FC
L0477AE: db $40
L0477AF: db $00
L0477B0: db $2F
L0477B1: db $2F
L0477B2: db $CB
L0477B3: db $40
L0477B4: db $03
L0477B5: db $04
L0477B6: db $43
L0477B7: db $07
L0477B8: db $00
L0477B9: db $09
L0477BA: db $0A
L0477BB: db $0B
L0477BC: db $0C
L0477BD: db $10
L0477BE: db $02
L0477BF: db $F0
L0477C0: db $2F
L0477C1: db $2E
L0477C2: db $CB
L0477C3: db $F0
L0477C4: db $0E
L0477C5: db $0F
L0477C6: db $11
L0477C7: db $12
L0477C8: db $4F
L0477C9: db $15
L0477CA: db $28
L0477CB: db $18
L0477CC: db $19
L0477CD: db $10
L0477CE: db $02
L0477CF: db $2F
L0477D0: db $2E
L0477D1: db $E0
L0477D2: db $CB
L0477D3: db $F0
L0477D4: db $00
L0477D5: db $10
L0477D6: db $13
L0477D7: db $14
L0477D8: db $16
L0477D9: db $17
L0477DA: db $01
L0477DB: db $1A
L0477DC: db $1B
L0477DD: db $1C
L0477DE: db $1D
L0477DF: db $1E
L0477E0: db $1F
L0477E1: db $20
L0477E2: db $28
L0477E3: db $3D
L0477E4: db $21
L0477E5: db $22
L0477E6: db $81
L0477E7: db $29
L0477E8: db $10
L0477E9: db $5C
L0477EA: db $23
L0477EB: db $CB
L0477EC: db $88
L0477ED: db $71
L0477EE: db $02
L0477EF: db $05
L0477F0: db $06
L0477F1: db $10
L0477F2: db $24
L0477F3: db $26
L0477F4: db $27
L0477F5: db $19
L0477F6: db $29
L0477F7: db $2A
L0477F8: db $2C
L0477F9: db $18
L0477FA: db $28
L0477FB: db $2D
L0477FC: db $2F
L0477FD: db $28
L0477FE: db $7D
L0477FF: db $31
L047800: db $40
L047801: db $59
L047802: db $29
L047803: db $58
L047804: db $8A
L047805: db $33
L047806: db $CB
L047807: db $95
L047808: db $FD
L047809: db $25
L04780A: db $28
L04780B: db $09
L04780C: db $2B
L04780D: db $19
L04780E: db $2E
L04780F: db $29
L047810: db $3C
L047811: db $30
L047812: db $32
L047813: db $5B
L047814: db $0D
L047815: db $FF
L047816: db $29
L047817: db $34
L047818: db $36
L047819: db $00
L04781A: db $37
L04781B: db $3A
L04781C: db $3B
L04781D: db $0D
L04781E: db $3E
L04781F: db $41
L047820: db $42
L047821: db $44
L047822: db $40
L047823: db $45
L047824: db $00
L047825: db $48
L047826: db $4A
L047827: db $4B
L047828: db $01
L047829: db $08
L04782A: db $4D
L04782B: db $0C
L04782C: db $4E
L04782D: db $51
L04782E: db $52
L04782F: db $53
L047830: db $FF
L047831: db $29
L047832: db $35
L047833: db $38
L047834: db $02
L047835: db $39
L047836: db $3C
L047837: db $3D
L047838: db $3F
L047839: db $40
L04783A: db $43
L04783B: db $10
L04783C: db $46
L04783D: db $49
L04783E: db $47
L04783F: db $00
L047840: db $49
L047841: db $4C
L047842: db $02
L047843: db $4F
L047844: db $50
L047845: db $80
L047846: db $B9
L047847: db $90
L047848: db $54
L047849: db $FF
L04784A: db $29
L04784B: db $78
L04784C: db $56
L04784D: db $57
L04784E: db $10
L04784F: db $2F
L047850: db $5A
L047851: db $5B
L047852: db $0A
L047853: db $5C
L047854: db $42
L047855: db $04
L047856: db $3B
L047857: db $FC
L047858: db $4F
L047859: db $55
L04785A: db $04
L04785B: db $58
L04785C: db $59
L04785D: db $3D
L04785E: db $47
L04785F: db $3F
L047860: db $01
L047861: db $7F
L047862: db $5D
L047863: db $07
L047864: db $07
L047865: db $07
L047866: db $07
L047867: db $07
L047868: db $07
L047869: db $07
L04786A: db $F8
L04786B: db $07
L04786C: db $07
L04786D: db $07
L04786E: db $07
L04786F: db $06
L047870: db $8C
L047871: db $40
L047872: db $6F
L047873: db $00
L047874: db $07
L047875: db $06
L047876: db $FF
L047877: db $07
L047878: db $07
L047879: db $03
L04787A: db $B2
L04787B: db $E1
L04787C: db $0B
L04787D: db $24
L04787E: db $0E
L04787F: db $FB
L047880: db $B5
L047881: db $ED
L047882: db $5A
L047883: db $28
L047884: db $13
L047885: db $2C
L047886: db $F7
L047887: db $AB
L047888: db $7F
L047889: db $DF
L04788A: db $AD
L04788B: db $80
L04788C: db $79
L04788D: db $54
L04788E: db $34
L04788F: db $70
L047890: db $D5
L047891: db $18
L047892: db $02
L047893: db $C8
L047894: db $0D
L047895: db $9F
L047896: db $11
L047897: db $60
L047898: db $BF
L047899: db $57
L04789A: db $08
L04789B: db $48
L04789C: db $AF
L04789D: db $55
L04789E: db $58
L04789F: db $90
L0478A0: db $48
L0478A1: db $FE
L0478A2: db $05
L0478A3: db $38
L0478A4: db $40
L0478A5: db $6F
L0478A6: db $B0
L0478A7: db $F9
L0478A8: db $04
L0478A9: db $06
L0478AA: db $9D
L0478AB: db $EA
L0478AC: db $FD
L0478AD: db $12
L0478AE: db $70
L0478AF: db $AA
L0478B0: db $7F
L0478B1: db $D3
L0478B2: db $48
L0478B3: db $08
L0478B4: db $A0
L0478B5: db $98
L0478B6: db $00
L0478B7: db $DF
L0478B8: db $E8
L0478B9: db $0C
L0478BA: db $FD
L0478BB: db $B0
L0478BC: db $0D
L0478BD: db $79
L0478BE: db $0E
L0478BF: db $06
L0478C0: db $DB
L0478C1: db $D0
L0478C2: db $A8
L0478C3: db $3C
L0478C4: db $DA
L0478C5: db $65
L0478C6: db $09
L0478C7: db $29
L0478C8: db $5B
L0478C9: db $DB
L0478CA: db $80
L0478CB: db $7F
L0478CC: db $3C
L0478CD: db $96
L0478CE: db $69
L0478CF: db $09
L0478D0: db $29
L0478D1: db $5B
L0478D2: db $0B
L0478D3: db $01
L0478D4: db $FE
L0478D5: db $3D
L0478D6: db $D5
L0478D7: db $2A
L0478D8: db $09
L0478D9: db $29
L0478DA: db $7E
L0478DB: db $B8
L0478DC: db $C0
L0478DD: db $08
L0478DE: db $21
L0478DF: db $DF
L0478E0: db $60
L0478E1: db $09
L0478E2: db $DD
L0478E3: db $62
L0478E4: db $DA
L0478E5: db $65
L0478E6: db $19
L0478E7: db $E7
L0478E8: db $7A
L0478E9: db $15
L0478EA: db $08
L0478EB: db $55
L0478EC: db $AA
L0478ED: db $00
L0478EE: db $10
L0478EF: db $19
L0478F0: db $FC
L0478F1: db $9B
L0478F2: db $1F
L0478F3: db $1B
L0478F4: db $9B
L0478F5: db $1F
L0478F6: db $1B
L0478F7: db $FF
L0478F8: db $00
L0478F9: db $00
L0478FA: db $60
L0478FB: db $9F
L0478FC: db $B1
L0478FD: db $4E
L0478FE: db $59
L0478FF: db $A6
L047900: db $AD
L047901: db $52
L047902: db $08
L047903: db $56
L047904: db $A9
L047905: db $AB
L047906: db $54
L047907: db $79
L047908: db $EA
L047909: db $15
L04790A: db $7D
L04790B: db $15
L04790C: db $82
L04790D: db $EF
L04790E: db $10
L04790F: db $A8
L047910: db $C6
L047911: db $08
L047912: db $6C
L047913: db $08
L047914: db $04
L047915: db $38
L047916: db $5F
L047917: db $BC
L047918: db $FA
L047919: db $17
L04791A: db $99
L04791B: db $5E
L04791C: db $A1
L04791D: db $88
L04791E: db $48
L04791F: db $00
L047920: db $DF
L047921: db $3E
L047922: db $18
L047923: db $30
L047924: db $FE
L047925: db $3D
L047926: db $88
L047927: db $70
L047928: db $63
L047929: db $F9
L04792A: db $66
L04792B: db $59
L04792C: db $07
L04792D: db $F8
L04792E: db $0E
L04792F: db $00
L047930: db $F1
L047931: db $1D
L047932: db $E2
L047933: db $3A
L047934: db $C5
L047935: db $75
L047936: db $8A
L047937: db $EA
L047938: db $1D
L047939: db $15
L04793A: db $D5
L04793B: db $2A
L04793C: db $79
L04793D: db $08
L04793E: db $C0
L04793F: db $01
L047940: db $08
L047941: db $21
L047942: db $FD
L047943: db $06
L047944: db $09
L047945: db $5D
L047946: db $A6
L047947: db $BD
L047948: db $46
L047949: db $1F
L04794A: db $C0
L04794B: db $1F
L04794C: db $19
L04794D: db $1F
L04794E: db $E0
L04794F: db $38
L047950: db $C7
L047951: db $FF
L047952: db $07
L047953: db $A0
L047954: db $08
L047955: db $47
L047956: db $19
L047957: db $98
L047958: db $67
L047959: db $9F
L04795A: db $60
L04795B: db $FA
L04795C: db $83
L04795D: db $28
L04795E: db $F9
L04795F: db $06
L047960: db $1B
L047961: db $E4
L047962: db $DF
L047963: db $98
L047964: db $08
L047965: db $13
L047966: db $E2
L047967: db $DE
L047968: db $E1
L047969: db $39
L04796A: db $FB
L04796B: db $04
L04796C: db $88
L04796D: db $48
L04796E: db $1D
L04796F: db $5A
L047970: db $F7
L047971: db $AA
L047972: db $08
L047973: db $1D
L047974: db $D9
L047975: db $0A
L047976: db $1A
L047977: db $1D
L047978: db $95
L047979: db $EF
L04797A: db $9A
L04797B: db $08
L04797C: db $1D
L04797D: db $D9
L04797E: db $90
L04797F: db $1A
L047980: db $02
L047981: db $D1
L047982: db $AE
L047983: db $FB
L047984: db $14
L047985: db $FF
L047986: db $00
L047987: db $08
L047988: db $42
L047989: db $08
L04798A: db $F6
L04798B: db $09
L04798C: db $D3
L04798D: db $2C
L04798E: db $4B
L04798F: db $D5
L047990: db $7F
L047991: db $AA
L047992: db $FB
L047993: db $08
L047994: db $1D
L047995: db $59
L047996: db $B1
L047997: db $19
L047998: db $55
L047999: db $10
L04799A: db $58
L04799B: db $E0
L04799C: db $08
L04799D: db $1D
L04799E: db $7D
L04799F: db $10
L0479A0: db $EF
L0479A1: db $38
L0479A2: db $D7
L0479A3: db $F7
L0479A4: db $00
L0479A5: db $08
L0479A6: db $E7
L0479A7: db $5A
L0479A8: db $F6
L0479A9: db $09
L0479AA: db $99
L0479AB: db $66
L0479AC: db $B9
L0479AD: db $72
L0479AE: db $56
L0479AF: db $79
L0479B0: db $59
L0479B1: db $18
L0479B2: db $42
L0479B3: db $BD
L0479B4: db $48
L0479B5: db $DB
L0479B6: db $7C
L0479B7: db $24
L0479B8: db $28
L0479B9: db $88
L0479BA: db $99
L0479BB: db $39
L0479BC: db $79
L0479BD: db $81
L0479BE: db $7E
L0479BF: db $F6
L0479C0: db $28
L0479C1: db $08
L0479C2: db $19
L0479C3: db $39
L0479C4: db $EB
L0479C5: db $30
L0479C6: db $08
L0479C7: db $3C
L0479C8: db $52
L0479C9: db $6A
L0479CA: db $1A
L0479CB: db $55
L0479CC: db $50
L0479CD: db $E6
L0479CE: db $99
L0479CF: db $B9
L0479D0: db $C3
L0479D1: db $8F
L0479D2: db $10
L0479D3: db $FD
L0479D4: db $42
L0479D5: db $FB
L0479D6: db $58
L0479D7: db $10
L0479D8: db $28
L0479D9: db $B9
L0479DA: db $09
L0479DB: db $DA
L0479DC: db $65
L0479DD: db $DF
L0479DE: db $60
L0479DF: db $0A
L0479E0: db $7F
L0479E1: db $C0
L0479E2: db $0C
L0479E3: db $9C
L0479E4: db $79
L0479E5: db $AA
L0479E6: db $55
L0479E7: db $19
L0479E8: db $0A
L0479E9: db $00
L0479EA: db $18
L0479EB: db $E7
L0479EC: db $B2
L0479ED: db $08
L0479EE: db $F7
L0479EF: db $32
L0479F0: db $10
L0479F1: db $EF
L0479F2: db $19
L0479F3: db $A0
L0479F4: db $86
L0479F5: db $00
L0479F6: db $BF
L0479F7: db $44
L0479F8: db $5F
L0479F9: db $A4
L0479FA: db $BB
L0479FB: db $46
L0479FC: db $5D
L0479FD: db $A3
L0479FE: db $04
L0479FF: db $AF
L047A00: db $50
L047A01: db $57
L047A02: db $A8
L047A03: db $AB
L047A04: db $F8
L047A05: db $FD
L047A06: db $03
L047A07: db $24
L047A08: db $FB
L047A09: db $06
L047A0A: db $B8
L047A0B: db $F5
L047A0C: db $0B
L047A0D: db $30
L047A0E: db $0D
L047A0F: db $F6
L047A10: db $60
L047A11: db $04
L047A12: db $40
L047A13: db $38
L047A14: db $05
L047A15: db $B3
L047A16: db $CC
L047A17: db $DF
L047A18: db $60
L047A19: db $20
L047A1A: db $FE
L047A1B: db $21
L047A1C: db $60
L047A1D: db $22
L047A1E: db $DA
L047A1F: db $65
L047A20: db $BD
L047A21: db $C2
L047A22: db $66
L047A23: db $FA
L047A24: db $68
L047A25: db $B0
L047A26: db $0A
L047A27: db $AA
L047A28: db $F8
L047A29: db $98
L047A2A: db $00
L047A2B: db $17
L047A2C: db $BF
L047A2D: db $C0
L047A2E: db $7F
L047A2F: db $A0
L047A30: db $20
L047A31: db $30
L047A32: db $B0
L047A33: db $31
L047A34: db $55
L047A35: db $3F
L047A36: db $20
L047A37: db $40
L047A38: db $A8
L047A39: db $46
L047A3A: db $D8
L047A3B: db $06
L047A3C: db $0A
L047A3D: db $30
L047A3E: db $FE
L047A3F: db $01
L047A40: db $0C
L047A41: db $D9
L047A42: db $1A
L047A43: db $E7
L047A44: db $3A
L047A45: db $D7
L047A46: db $08
L047A47: db $FA
L047A48: db $07
L047A49: db $EA
L047A4A: db $57
L047A4B: db $19
L047A4C: db $9A
L047A4D: db $67
L047A4E: db $BA
L047A4F: db $89
L047A50: db $2A
L047A51: db $90
L047A52: db $EF
L047A53: db $98
L047A54: db $88
L047A55: db $97
L047A56: db $E8
L047A57: db $08
L047A58: db $80
L047A59: db $80
L047A5A: db $96
L047A5B: db $E9
L047A5C: db $91
L047A5D: db $EE
L047A5E: db $99
L047A5F: db $E6
L047A60: db $9F
L047A61: db $5C
L047A62: db $E0
L047A63: db $88
L047A64: db $F7
L047A65: db $99
L047A66: db $0F
L047A67: db $09
L047A68: db $AF
L047A69: db $50
L047A6A: db $F2
L047A6B: db $88
L047A6C: db $D8
L047A6D: db $AB
L047A6E: db $08
L047A6F: db $EC
L047A70: db $9D
L047A71: db $E8
L047A72: db $97
L047A73: db $CD
L047A74: db $18
L047A75: db $39
L047A76: db $FF
L047A77: db $04
L047A78: db $08
L047A79: db $01
L047A7A: db $00
L047A7B: db $0F
L047A7C: db $84
L047A7D: db $09
L047A7E: db $AA
L047A7F: db $55
L047A80: db $FB
L047A81: db $FC
L047A82: db $00
L047A83: db $03
L047A84: db $F9
L047A85: db $52
L047A86: db $06
L047A87: db $48
L047A88: db $01
L047A89: db $08
L047A8A: db $02
L047A8B: db $FD
L047A8C: db $38
L047A8D: db $FE
L047A8E: db $81
L047A8F: db $28
L047A90: db $9F
L047A91: db $60
L047A92: db $BF
L047A93: db $7F
L047A94: db $3F
L047A95: db $C0
L047A96: db $B9
L047A97: db $B8
L047A98: db $20
L047A99: db $80
L047A9A: db $18
L047A9B: db $0A
L047A9C: db $29
L047A9D: db $AC
L047A9E: db $53
L047A9F: db $FA
L047AA0: db $40
L047AA1: db $F7
L047AA2: db $08
L047AA3: db $07
L047AA4: db $BA
L047AA5: db $47
L047AA6: db $EA
L047AA7: db $77
L047AA8: db $AA
L047AA9: db $C8
L047AAA: db $08
L047AAB: db $39
L047AAC: db $DA
L047AAD: db $A7
L047AAE: db $98
L047AAF: db $90
L047AB0: db $9F
L047AB1: db $EF
L047AB2: db $B8
L047AB3: db $08
L047AB4: db $E0
L047AB5: db $0F
L047AB6: db $09
L047AB7: db $98
L047AB8: db $05
L047AB9: db $EB
L047ABA: db $BC
L047ABB: db $A6
L047ABC: db $08
L047ABD: db $3C
L047ABE: db $0B
L047ABF: db $EA
L047AC0: db $3D
L047AC1: db $3D
L047AC2: db $08
L047AC3: db $BD
L047AC4: db $C0
L047AC5: db $3E
L047AC6: db $0C
L047AC7: db $FE
L047AC8: db $01
L047AC9: db $F5
L047ACA: db $9A
L047ACB: db $F7
L047ACC: db $18
L047ACD: db $8D
L047ACE: db $0A
L047ACF: db $5A
L047AD0: db $F6
L047AD1: db $19
L047AD2: db $3C
L047AD3: db $09
L047AD4: db $DB
L047AD5: db $3E
L047AD6: db $80
L047AD7: db $0C
L047AD8: db $B6
L047AD9: db $59
L047ADA: db $C9
L047ADB: db $76
L047ADC: db $CB
L047ADD: db $74
L047ADE: db $CF
L047ADF: db $50
L047AE0: db $70
L047AE1: db $08
L047AE2: db $72
L047AE3: db $F8
L047AE4: db $09
L047AE5: db $D3
L047AE6: db $2C
L047AE7: db $FB
L047AE8: db $01
L047AE9: db $14
L047AEA: db $FF
L047AEB: db $00
L047AEC: db $BF
L047AED: db $40
L047AEE: db $7F
L047AEF: db $80
L047AF0: db $18
L047AF1: db $40
L047AF2: db $5F
L047AF3: db $18
L047AF4: db $9F
L047AF5: db $FE
L047AF6: db $0F
L047AF7: db $1F
L047AF8: db $E0
L047AF9: db $0E
L047AFA: db $55
L047AFB: db $F5
L047AFC: db $88
L047AFD: db $04
L047AFE: db $88
L047AFF: db $FC
L047B00: db $48
L047B01: db $01
L047B02: db $A9
L047B03: db $2D
L047B04: db $F9
L047B05: db $07
L047B06: db $19
L047B07: db $E3
L047B08: db $80
L047B09: db $19
L047B0A: db $87
L047B0B: db $C0
L047B0C: db $FC
L047B0D: db $19
L047B0E: db $08
L047B0F: db $01
L047B10: db $1F
L047B11: db $1A
L047B12: db $E9
L047B13: db $FD
L047B14: db $02
L047B15: db $42
L047B16: db $A6
L047B17: db $F0
L047B18: db $45
L047B19: db $FA
L047B1A: db $8F
L047B1B: db $F0
L047B1C: db $00
L047B1D: db $0F
L047B1E: db $82
L047B1F: db $08
L047B20: db $2F
L047B21: db $5F
L047B22: db $A0
L047B23: db $D9
L047B24: db $AE
L047B25: db $60
L047B26: db $0E
L047B27: db $C0
L047B28: db $09
L047B29: db $B0
L047B2A: db $4A
L047B2B: db $F6
L047B2C: db $09
L047B2D: db $D3
L047B2E: db $2C
L047B2F: db $FB
L047B30: db $51
L047B31: db $14
L047B32: db $38
L047B33: db $00
L047B34: db $08
L047B35: db $3F
L047B36: db $7F
L047B37: db $80
L047B38: db $29
L047B39: db $24
L047B3A: db $9F
L047B3B: db $E0
L047B3C: db $19
L047B3D: db $C7
L047B3E: db $F8
L047B3F: db $19
L047B40: db $F1
L047B41: db $FE
L047B42: db $B2
L047B43: db $48
L047B44: db $EF
L047B45: db $59
L047B46: db $09
L047B47: db $9E
L047B48: db $E1
L047B49: db $18
L047B4A: db $E4
L047B4B: db $93
L047B4C: db $09
L047B4D: db $9B
L047B4E: db $ED
L047B4F: db $70
L047B50: db $0B
L047B51: db $BB
L047B52: db $B0
L047B53: db $00
L047B54: db $21
L047B55: db $38
L047B56: db $70
L047B57: db $50
L047B58: db $BF
L047B59: db $C0
L047B5A: db $7B
L047B5B: db $94
L047B5C: db $68
L047B5D: db $15
L047B5E: db $74
L047B5F: db $3F
L047B60: db $C2
L047B61: db $40
L047B62: db $6A
L047B63: db $88
L047B64: db $FD
L047B65: db $00
L047B66: db $16
L047B67: db $03
L047B68: db $FF
L047B69: db $01
L047B6A: db $08
L047B6B: db $00
L047B6C: db $09
L047B6D: db $38
L047B6E: db $02
L047B6F: db $40
L047B70: db $FC
L047B71: db $E8
L047B72: db $AF
L047B73: db $54
L047B74: db $1F
L047B75: db $E3
L047B76: db $DF
L047B77: db $EC
L047B78: db $82
L047B79: db $58
L047B7A: db $AC
L047B7B: db $FB
L047B7C: db $04
L047B7D: db $DB
L047B7E: db $36
L047B7F: db $C8
L047B80: db $67
L047B81: db $80
L047B82: db $38
L047B83: db $D7
L047B84: db $FA
L047B85: db $87
L047B86: db $5A
L047B87: db $A7
L047B88: db $AA
L047B89: db $57
L047B8A: db $32
L047B8B: db $0A
L047B8C: db $F7
L047B8D: db $0F
L047B8E: db $09
L047B8F: db $9F
L047B90: db $E0
L047B91: db $08
L047B92: db $E4
L047B93: db $A1
L047B94: db $1E
L047B95: db $E1
L047B96: db $19
L047B97: db $94
L047B98: db $EB
L047B99: db $FF
L047B9A: db $00
L047B9B: db $08
L047B9C: db $AC
L047B9D: db $14
L047B9E: db $55
L047B9F: db $10
L047BA0: db $AA
L047BA1: db $29
L047BA2: db $02
L047BA3: db $35
L047BA4: db $CA
L047BA5: db $28
L047BA6: db $6A
L047BA7: db $D5
L047BA8: db $B0
L047BA9: db $5F
L047BAA: db $09
L047BAB: db $40
L047BAC: db $BF
L047BAD: db $80
L047BAE: db $40
L047BAF: db $7F
L047BB0: db $0B
L047BB1: db $7B
L047BB2: db $9D
L047BB3: db $A2
L047BB4: db $5D
L047BB5: db $29
L047BB6: db $D6
L047BB7: db $02
L047BB8: db $4B
L047BB9: db $B5
L047BBA: db $5A
L047BBB: db $A7
L047BBC: db $6E
L047BBD: db $95
L047BBE: db $60
L047BBF: db $A8
L047BC0: db $00
L047BC1: db $38
L047BC2: db $D7
L047BC3: db $78
L047BC4: db $87
L047BC5: db $DA
L047BC6: db $25
L047BC7: db $B2
L047BC8: db $CD
L047BC9: db $04
L047BCA: db $33
L047BCB: db $CC
L047BCC: db $27
L047BCD: db $D8
L047BCE: db $2E
L047BCF: db $58
L047BD0: db $DF
L047BD1: db $20
L047BD2: db $05
L047BD3: db $22
L047BD4: db $DD
L047BD5: db $FA
L047BD6: db $57
L047BD7: db $7A
L047BD8: db $C8
L047BD9: db $EA
L047BDA: db $18
L047BDB: db $0D
L047BDC: db $CA
L047BDD: db $B7
L047BDE: db $8A
L047BDF: db $77
L047BE0: db $19
L047BE1: db $58
L047BE2: db $07
L047BE3: db $29
L047BE4: db $43
L047BE5: db $95
L047BE6: db $60
L047BE7: db $9A
L047BE8: db $E5
L047BE9: db $90
L047BEA: db $EF
L047BEB: db $0F
L047BEC: db $09
L047BED: db $32
L047BEE: db $55
L047BEF: db $AA
L047BF0: db $00
L047BF1: db $10
L047BF2: db $00
L047BF3: db $FF
L047BF4: db $0D
L047BF5: db $03
L047BF6: db $08
L047BF7: db $FC
L047BF8: db $1F
L047BF9: db $E3
L047BFA: db $FE
L047BFB: db $10
L047BFC: db $F7
L047BFD: db $F8
L047BFE: db $39
L047BFF: db $0B
L047C00: db $C7
L047C01: db $CA
L047C02: db $3F
L047C03: db $57
L047C04: db $68
L047C05: db $BF
L047C06: db $08
L047C07: db $03
L047C08: db $02
L047C09: db $6B
L047C0A: db $BC
L047C0B: db $EA
L047C0C: db $3D
L047C0D: db $6A
L047C0E: db $BD
L047C0F: db $29
L047C10: db $6F
L047C11: db $00
L047C12: db $B1
L047C13: db $7F
L047C14: db $8F
L047C15: db $FB
L047C16: db $7C
L047C17: db $DD
L047C18: db $E2
L047C19: db $55
L047C1A: db $11
L047C1B: db $AA
L047C1C: db $87
L047C1D: db $78
L047C1E: db $48
L047C1F: db $80
L047C20: db $E7
L047C21: db $1F
L047C22: db $F2
L047C23: db $28
L047C24: db $3F
L047C25: db $FD
L047C26: db $08
L047C27: db $DE
L047C28: db $D8
L047C29: db $E5
L047C2A: db $1E
L047C2B: db $3B
L047C2C: db $1C
L047C2D: db $CD
L047C2E: db $5F
L047C2F: db $E3
L047C30: db $58
L047C31: db $07
L047C32: db $00
L047C33: db $6E
L047C34: db $9D
L047C35: db $2C
L047C36: db $D7
L047C37: db $AE
L047C38: db $20
L047C39: db $96
L047C3A: db $E0
L047C3B: db $30
L047C3C: db $AF
L047C3D: db $5D
L047C3E: db $82
L047C3F: db $38
L047C40: db $A9
L047C41: db $AB
L047C42: db $D6
L047C43: db $07
L047C44: db $F8
L047C45: db $58
L047C46: db $00
L047C47: db $89
L047C48: db $08
L047C49: db $C6
L047C4A: db $CE
L047C4B: db $3D
L047C4C: db $18
L047C4D: db $FB
L047C4E: db $FD
L047C4F: db $0A
L047C50: db $5A
L047C51: db $FE
L047C52: db $08
L047C53: db $EC
L047C54: db $08
L047C55: db $79
L047C56: db $6F
L047C57: db $18
L047C58: db $BC
L047C59: db $94
L047C5A: db $08
L047C5B: db $7F
L047C5C: db $80
L047C5D: db $68
L047C5E: db $7B
L047C5F: db $68
L047C60: db $53
L047C61: db $F7
L047C62: db $41
L047C63: db $BB
L047C64: db $68
L047C65: db $A3
L047C66: db $1A
L047C67: db $ED
L047C68: db $F5
L047C69: db $0E
L047C6A: db $28
L047C6B: db $44
L047C6C: db $F6
L047C6D: db $48
L047C6E: db $EB
L047C6F: db $EF
L047C70: db $DB
L047C71: db $28
L047C72: db $D5
L047C73: db $31
L047C74: db $75
L047C75: db $CE
L047C76: db $E0
L047C77: db $20
L047C78: db $38
L047C79: db $97
L047C7A: db $10
L047C7B: db $2F
L047C7C: db $08
L047C7D: db $A9
L047C7E: db $01
L047C7F: db $7F
L047C80: db $0A
L047C81: db $BF
L047C82: db $08
L047C83: db $1F
L047C84: db $0F
L047C85: db $49
L047C86: db $82
L047C87: db $90
L047C88: db $FB
L047C89: db $E7
L047C8A: db $35
L047C8B: db $DF
L047C8C: db $E5
L047C8D: db $48
L047C8E: db $F6
L047C8F: db $01
L047C90: db $AF
L047C91: db $FA
L047C92: db $57
L047C93: db $EC
L047C94: db $77
L047C95: db $D9
L047C96: db $26
L047C97: db $79
L047C98: db $EF
L047C99: db $C0
L047C9A: db $78
L047C9B: db $08
L047C9C: db $C0
L047C9D: db $80
L047C9E: db $D8
L047C9F: db $18
L047CA0: db $E9
L047CA1: db $C5
L047CA2: db $10
L047CA3: db $0A
L047CA4: db $EF
L047CA5: db $FE
L047CA6: db $11
L047CA7: db $08
L047CA8: db $FD
L047CA9: db $28
L047CAA: db $F8
L047CAB: db $10
L047CAC: db $08
L047CAD: db $01
L047CAE: db $19
L047CAF: db $38
L047CB0: db $F6
L047CB1: db $FB
L047CB2: db $C7
L047CB3: db $25
L047CB4: db $F8
L047CB5: db $E4
L047CB6: db $D0
L047CB7: db $F3
L047CB8: db $EC
L047CB9: db $48
L047CBA: db $E3
L047CBB: db $08
L047CBC: db $50
L047CBD: db $43
L047CBE: db $F0
L047CBF: db $D3
L047CC0: db $E0
L047CC1: db $A7
L047CC2: db $B0
L047CC3: db $4F
L047CC4: db $00
L047CC5: db $81
L047CC6: db $40
L047CC7: db $D5
L047CC8: db $2A
L047CC9: db $EA
L047CCA: db $15
L047CCB: db $FC
L047CCC: db $C3
L047CCD: db $30
L047CCE: db $7C
L047CCF: db $38
L047CD0: db $E9
L047CD1: db $08
L047CD2: db $30
L047CD3: db $98
L047CD4: db $08
L047CD5: db $7B
L047CD6: db $BC
L047CD7: db $62
L047CD8: db $6B
L047CD9: db $08
L047CDA: db $78
L047CDB: db $3D
L047CDC: db $6A
L047CDD: db $BD
L047CDE: db $19
L047CDF: db $FA
L047CE0: db $00
L047CE1: db $8D
L047CE2: db $FE
L047CE3: db $F1
L047CE4: db $DF
L047CE5: db $3E
L047CE6: db $BB
L047CE7: db $47
L047CE8: db $77
L047CE9: db $14
L047CEA: db $B9
L047CEB: db $EF
L047CEC: db $71
L047CED: db $C8
L047CEE: db $69
L047CEF: db $08
L047CF0: db $74
L047CF1: db $F7
L047CF2: db $48
L047CF3: db $B8
L047CF4: db $38
L047CF5: db $91
L047CF6: db $D4
L047CF7: db $E0
L047CF8: db $E0
L047CF9: db $1F
L047CFA: db $D7
L047CFB: db $4B
L047CFC: db $78
L047CFD: db $E8
L047CFE: db $BF
L047CFF: db $F5
L047D00: db $08
L047D01: db $BE
L047D02: db $D0
L047D03: db $88
L047D04: db $7E
L047D05: db $9F
L047D06: db $08
L047D07: db $28
L047D08: db $08
L047D09: db $00
L047D0A: db $70
L047D0B: db $08
L047D0C: db $55
L047D0D: db $6C
L047D0E: db $AA
L047D0F: db $00
L047D10: db $10
L047D11: db $00
L047D12: db $28
L047D13: db $0D
L047D14: db $C0
L047D15: db $3F
L047D16: db $14
L047D17: db $F8
L047D18: db $C7
L047D19: db $7F
L047D1A: db $10
L047D1B: db $EF
L047D1C: db $A0
L047D1D: db $5C
L047D1E: db $E3
L047D1F: db $16
L047D20: db $AB
L047D21: db $FC
L047D22: db $D5
L047D23: db $68
L047D24: db $FA
L047D25: db $F1
L047D26: db $02
L047D27: db $9F
L047D28: db $0C
L047D29: db $EA
L047D2A: db $9E
L047D2B: db $E1
L047D2C: db $90
L047D2D: db $90
L047D2E: db $0B
L047D2F: db $91
L047D30: db $EE
L047D31: db $80
L047D32: db $0B
L047D33: db $5B
L047D34: db $AC
L047D35: db $DE
L047D36: db $2D
L047D37: db $7C
L047D38: db $83
L047D39: db $82
L047D3A: db $48
L047D3B: db $7D
L047D3C: db $09
L047D3D: db $32
L047D3E: db $CD
L047D3F: db $09
L047D40: db $29
L047D41: db $D6
L047D42: db $7F
L047D43: db $01
L047D44: db $95
L047D45: db $BF
L047D46: db $54
L047D47: db $3F
L047D48: db $C2
L047D49: db $5F
L047D4A: db $B1
L047D4B: db $38
L047D4C: db $40
L047D4D: db $B7
L047D4E: db $08
L047D4F: db $81
L047D50: db $AF
L047D51: db $70
L047D52: db $FF
L047D53: db $40
L047D54: db $FD
L047D55: db $55
L047D56: db $5A
L047D57: db $18
L047D58: db $3C
L047D59: db $08
L047D5A: db $9E
L047D5B: db $08
L047D5C: db $AE
L047D5D: db $08
L047D5E: db $CA
L047D5F: db $98
L047D60: db $08
L047D61: db $F4
L047D62: db $7E
L047D63: db $88
L047D64: db $FE
L047D65: db $70
L047D66: db $16
L047D67: db $40
L047D68: db $7B
L047D69: db $01
L047D6A: db $07
L047D6B: db $07
L047D6C: db $07
L047D6D: db $06
L047D6E: db $02
L047D6F: db $07
L047D70: db $07
L047D71: db $C3
L047D72: db $07
L047D73: db $06
L047D74: db $03
L047D75: db $04
L047D76: db $07
L047D77: db $08
L047D78: db $00
L047D79: db $21
L047D7A: db $E5
L047D7B: db $10
L047D7C: db $2A
L047D7D: db $00
L047D7E: db $0C
L047D7F: db $0D
L047D80: db $04
L047D81: db $14
L047D82: db $64
L047D83: db $83
L047D84: db $C6
L047D85: db $05
L047D86: db $06
L047D87: db $09
L047D88: db $0A
L047D89: db $0B
L047D8A: db $21
L047D8B: db $18
L047D8C: db $E0
L047D8D: db $28
L047D8E: db $20
L047D8F: db $31
L047D90: db $0E
L047D91: db $0F
L047D92: db $10
L047D93: db $11
L047D94: db $12
L047D95: db $58
L047D96: db $13
L047D97: db $20
L047D98: db $15
L047D99: db $64
L047D9A: db $C6
L047D9B: db $16
L047D9C: db $17
L047D9D: db $1A
L047D9E: db $B7
L047D9F: db $00
L047DA0: db $1D
L047DA1: db $21
L047DA2: db $10
L047DA3: db $1E
L047DA4: db $08
L047DA5: db $31
L047DA6: db $F9
L047DA7: db $9F
L047DA8: db $00
L047DA9: db $23
L047DAA: db $25
L047DAB: db $19
L047DAC: db $F8
L047DAD: db $49
L047DAE: db $08
L047DAF: db $71
L047DB0: db $86
L047DB1: db $C6
L047DB2: db $18
L047DB3: db $19
L047DB4: db $1B
L047DB5: db $1C
L047DB6: db $00
L047DB7: db $22
L047DB8: db $1F
L047DB9: db $89
L047DBA: db $29
L047DBB: db $20
L047DBC: db $21
L047DBD: db $22
L047DBE: db $00
L047DBF: db $24
L047DC0: db $26
L047DC1: db $19
L047DC2: db $78
L047DC3: db $27
L047DC4: db $40
L047DC5: db $50
L047DC6: db $72
L047DC7: db $C6
L047DC8: db $28
L047DC9: db $29
L047DCA: db $1A
L047DCB: db $A9
L047DCC: db $00
L047DCD: db $1D
L047DCE: db $22
L047DCF: db $31
L047DD0: db $31
L047DD1: db $33
L047DD2: db $35
L047DD3: db $40
L047DD4: db $8F
L047DD5: db $08
L047DD6: db $36
L047DD7: db $39
L047DD8: db $3A
L047DD9: db $20
L047DDA: db $08
L047DDB: db $40
L047DDC: db $10
L047DDD: db $C0
L047DDE: db $72
L047DDF: db $C6
L047DE0: db $2A
L047DE1: db $2B
L047DE2: db $2C
L047DE3: db $2D
L047DE4: db $2E
L047DE5: db $2F
L047DE6: db $5A
L047DE7: db $30
L047DE8: db $20
L047DE9: db $32
L047DEA: db $08
L047DEB: db $00
L047DEC: db $34
L047DED: db $11
L047DEE: db $37
L047DEF: db $5C
L047DF0: db $38
L047DF1: db $00
L047DF2: db $3B
L047DF3: db $44
L047DF4: db $71
L047DF5: db $C0
L047DF6: db $3C
L047DF7: db $3D
L047DF8: db $30
L047DF9: db $3E
L047DFA: db $3F
L047DFB: db $20
L047DFC: db $C0
L047DFD: db $40
L047DFE: db $41
L047DFF: db $43
L047E00: db $44
L047E01: db $00
L047E02: db $45
L047E03: db $46
L047E04: db $47
L047E05: db $48
L047E06: db $4A
L047E07: db $4B
L047E08: db $4E
L047E09: db $4F
L047E0A: db $41
L047E0B: db $42
L047E0C: db $06
L047E0D: db $52
L047E0E: db $53
L047E0F: db $56
L047E10: db $57
L047E11: db $5A
L047E12: db $C0
L047E13: db $0E
L047E14: db $5C
L047E15: db $5D
L047E16: db $5E
L047E17: db $5F
L047E18: db $20
L047E19: db $C0
L047E1A: db $96
L047E1B: db $49
L047E1C: db $04
L047E1D: db $4C
L047E1E: db $4D
L047E1F: db $50
L047E20: db $51
L047E21: db $01
L047E22: db $06
L047E23: db $54
L047E24: db $55
L047E25: db $1F
L047E26: db $58
L047E27: db $59
L047E28: db $5B
L047E29: db $C6
L047E2A: db $9F
L047E2B: db $07
L047E2C: db $07
L047E2D: db $07
L047E2E: db $FF
L047E2F: db $07
L047E30: db $07
L047E31: db $07
L047E32: db $07
L047E33: db $07
L047E34: db $07
L047E35: db $07
L047E36: db $07
L047E37: db $00;X
L047E38: db $0D;X
L047E39: db $F6;X
L047E3A: db $0D;X
L047E3B: db $F6;X
L047E3C: db $8D;X
L047E3D: db $76;X
L047E3E: db $AD;X
L047E3F: db $56;X
L047E40: db $AD;X
L047E41: db $56;X
L047E42: db $FD;X
L047E43: db $06;X
L047E44: db $0D;X
L047E45: db $F6;X
L047E46: db $FD;X
L047E47: db $06;X
L047E48: db $AF;X
L047E49: db $50;X
L047E4A: db $55;X
L047E4B: db $AA;X
L047E4C: db $00;X
L047E4D: db $FF;X
L047E4E: db $00;X
L047E4F: db $FF;X
L047E50: db $00;X
L047E51: db $FF;X
L047E52: db $00;X
L047E53: db $FF;X
L047E54: db $00;X
L047E55: db $FF;X
L047E56: db $00;X
L047E57: db $FF;X
L047E58: db $00;X
L047E59: db $FF;X
L047E5A: db $01;X
L047E5B: db $01;X
L047E5C: db $01;X
L047E5D: db $01;X
L047E5E: db $04;X
L047E5F: db $01;X
L047E60: db $01;X
L047E61: db $04;X
L047E62: db $01;X
L047E63: db $01;X
L047E64: db $01;X
L047E65: db $01;X
L047E66: db $06;X
L047E67: db $01;X
L047E68: db $01;X
L047E69: db $01;X
L047E6A: db $01;X
L047E6B: db $01;X
L047E6C: db $01;X
L047E6D: db $01;X
L047E6E: db $01;X
L047E6F: db $08;X
L047E70: db $06;X
L047E71: db $0B;X
L047E72: db $0D;X
L047E73: db $0D;X
L047E74: db $0D;X
L047E75: db $0D;X
L047E76: db $0D;X
L047E77: db $0D;X
L047E78: db $0D;X
L047E79: db $0D;X
L047E7A: db $02;X
L047E7B: db $03;X
L047E7C: db $04;X
L047E7D: db $01;X
L047E7E: db $02;X
L047E7F: db $05;X
L047E80: db $01;X
L047E81: db $02;X
L047E82: db $04;X
L047E83: db $01;X
L047E84: db $01;X
L047E85: db $04;X
L047E86: db $07;X
L047E87: db $01;X
L047E88: db $04;X
L047E89: db $01;X
L047E8A: db $02;X
L047E8B: db $01;X
L047E8C: db $01;X
L047E8D: db $01;X
L047E8E: db $09;X
L047E8F: db $0A;X
L047E90: db $05;X
L047E91: db $0C;X
L047E92: db $0D;X
L047E93: db $0D;X
L047E94: db $0D;X
L047E95: db $0D;X
L047E96: db $0D;X
L047E97: db $0D;X
L047E98: db $0D;X
L047E99: db $0D;X
L047E9A: db $02;X
L047E9B: db $05;X
L047E9C: db $02;X
L047E9D: db $02;X
L047E9E: db $02;X
L047E9F: db $02;X
L047EA0: db $03;X
L047EA1: db $02;X
L047EA2: db $02;X
L047EA3: db $01;X
L047EA4: db $02;X
L047EA5: db $02;X
L047EA6: db $07;X
L047EA7: db $03;X
L047EA8: db $02;X
L047EA9: db $02;X
L047EAA: db $05;X
L047EAB: db $03;X
L047EAC: db $12;X
L047EAD: db $05;X
L047EAE: db $14;X
L047EAF: db $15;X
L047EB0: db $17;X
L047EB1: db $0C;X
L047EB2: db $0D;X
L047EB3: db $0D;X
L047EB4: db $0D;X
L047EB5: db $0D;X
L047EB6: db $0D;X
L047EB7: db $0D;X
L047EB8: db $0D;X
L047EB9: db $0D;X
L047EBA: db $0E;X
L047EBB: db $0F;X
L047EBC: db $05;X
L047EBD: db $05;X
L047EBE: db $10;X
L047EBF: db $0E;X
L047EC0: db $11;X
L047EC1: db $11;X
L047EC2: db $0E;X
L047EC3: db $0F;X
L047EC4: db $05;X
L047EC5: db $02;X
L047EC6: db $07;X
L047EC7: db $0E;X
L047EC8: db $07;X
L047EC9: db $11;X
L047ECA: db $0E;X
L047ECB: db $0F;X
L047ECC: db $0B;X
L047ECD: db $13;X
L047ECE: db $16;X
L047ECF: db $16;X
L047ED0: db $18;X
L047ED1: db $0B;X
L047ED2: db $19;X
L047ED3: db $0D;X
L047ED4: db $19;X
L047ED5: db $0D;X
L047ED6: db $0D;X
L047ED7: db $19;X
L047ED8: db $0D;X
L047ED9: db $0D;X
L047EDA: db $1A;X
L047EDB: db $1B;X
L047EDC: db $1D;X
L047EDD: db $1E;X
L047EDE: db $1F;X
L047EDF: db $1A;X
L047EE0: db $22;X
L047EE1: db $22;X
L047EE2: db $1A;X
L047EE3: db $1B;X
L047EE4: db $1D;X
L047EE5: db $1E;X
L047EE6: db $07;X
L047EE7: db $1A;X
L047EE8: db $07;X
L047EE9: db $22;X
L047EEA: db $1A;X
L047EEB: db $1B;X
L047EEC: db $0C;X
L047EED: db $13;X
L047EEE: db $16;X
L047EEF: db $16;X
L047EF0: db $18;X
L047EF1: db $0C;X
L047EF2: db $25;X
L047EF3: db $0D;X
L047EF4: db $25;X
L047EF5: db $0D;X
L047EF6: db $0D;X
L047EF7: db $25;X
L047EF8: db $0D;X
L047EF9: db $0D;X
L047EFA: db $1C;X
L047EFB: db $1C;X
L047EFC: db $1C;X
L047EFD: db $1C;X
L047EFE: db $20;X
L047EFF: db $21;X
L047F00: db $23;X
L047F01: db $1C;X
L047F02: db $1C;X
L047F03: db $1C;X
L047F04: db $1C;X
L047F05: db $1C;X
L047F06: db $07;X
L047F07: db $1C;X
L047F08: db $07;X
L047F09: db $1C;X
L047F0A: db $1C;X
L047F0B: db $1C;X
L047F0C: db $0B;X
L047F0D: db $05;X
L047F0E: db $24;X
L047F0F: db $24;X
L047F10: db $18;X
L047F11: db $0C;X
L047F12: db $0D;X
L047F13: db $26;X
L047F14: db $05;X
L047F15: db $0D;X
L047F16: db $27;X
L047F17: db $05;X
L047F18: db $05;X
L047F19: db $0D;X
L047F1A: db $28;X
L047F1B: db $28;X
L047F1C: db $2A;X
L047F1D: db $2B;X
L047F1E: db $2C;X
L047F1F: db $2D;X
L047F20: db $2E;X
L047F21: db $28;X
L047F22: db $28;X
L047F23: db $28;X
L047F24: db $2A;X
L047F25: db $2B;X
L047F26: db $07;X
L047F27: db $28;X
L047F28: db $07;X
L047F29: db $28;X
L047F2A: db $38;X
L047F2B: db $28;X
L047F2C: db $34;X
L047F2D: db $35;X
L047F2E: db $16;X
L047F2F: db $16;X
L047F30: db $18;X
L047F31: db $0B;X
L047F32: db $0D;X
L047F33: db $26;X
L047F34: db $05;X
L047F35: db $0D;X
L047F36: db $27;X
L047F37: db $05;X
L047F38: db $05;X
L047F39: db $0D;X
L047F3A: db $29;X
L047F3B: db $29;X
L047F3C: db $29;X
L047F3D: db $29;X
L047F3E: db $29;X
L047F3F: db $29;X
L047F40: db $2F;X
L047F41: db $30;X
L047F42: db $31;X
L047F43: db $32;X
L047F44: db $05;X
L047F45: db $33;X
L047F46: db $34;X
L047F47: db $35;X
L047F48: db $36;X
L047F49: db $37;X
L047F4A: db $39;X
L047F4B: db $3A;X
L047F4C: db $3B;X
L047F4D: db $3C;X
L047F4E: db $30;X
L047F4F: db $31;X
L047F50: db $32;X
L047F51: db $0C;X
L047F52: db $0D;X
L047F53: db $26;X
L047F54: db $35;X
L047F55: db $0D;X
L047F56: db $27;X
L047F57: db $3A;X
L047F58: db $35;X
L047F59: db $0D;X
L047F5A: db $3D;X
L047F5B: db $3E;X
L047F5C: db $3D;X
L047F5D: db $3E;X
L047F5E: db $08;X
L047F5F: db $41;X
L047F60: db $43;X
L047F61: db $44;X
L047F62: db $47;X
L047F63: db $48;X
L047F64: db $4B;X
L047F65: db $4C;X
L047F66: db $4F;X
L047F67: db $50;X
L047F68: db $53;X
L047F69: db $54;X
L047F6A: db $57;X
L047F6B: db $58;X
L047F6C: db $05;X
L047F6D: db $05;X
L047F6E: db $44;X
L047F6F: db $47;X
L047F70: db $48;X
L047F71: db $5A;X
L047F72: db $3D;X
L047F73: db $3E;X
L047F74: db $3D;X
L047F75: db $3E;X
L047F76: db $3D;X
L047F77: db $3E;X
L047F78: db $3D;X
L047F79: db $3E;X
L047F7A: db $3F;X
L047F7B: db $40;X
L047F7C: db $3F;X
L047F7D: db $40;X
L047F7E: db $42;X
L047F7F: db $42;X
L047F80: db $45;X
L047F81: db $46;X
L047F82: db $49;X
L047F83: db $4A;X
L047F84: db $4D;X
L047F85: db $4E;X
L047F86: db $51;X
L047F87: db $52;X
L047F88: db $55;X
L047F89: db $56;X
L047F8A: db $59;X
L047F8B: db $45;X
L047F8C: db $42;X
L047F8D: db $42;X
L047F8E: db $46;X
L047F8F: db $49;X
L047F90: db $4A;X
L047F91: db $5B;X
L047F92: db $3F;X
L047F93: db $40;X
L047F94: db $3F;X
L047F95: db $40;X
L047F96: db $3F;X
L047F97: db $40;X
L047F98: db $3F;X
L047F99: db $40;X
L047F9A: db $5C;X
L047F9B: db $5C;X
L047F9C: db $5C;X
L047F9D: db $5C;X
L047F9E: db $5C;X
L047F9F: db $5C;X
L047FA0: db $5C;X
L047FA1: db $5C;X
L047FA2: db $5C;X
L047FA3: db $5C;X
L047FA4: db $5C;X
L047FA5: db $5C;X
L047FA6: db $5C;X
L047FA7: db $5C;X
L047FA8: db $5C;X
L047FA9: db $5C;X
L047FAA: db $5C;X
L047FAB: db $5C;X
L047FAC: db $5C;X
L047FAD: db $5C;X
L047FAE: db $5C;X
L047FAF: db $5C;X
L047FB0: db $5C;X
L047FB1: db $5C;X
L047FB2: db $5C;X
L047FB3: db $5C;X
L047FB4: db $5C;X
L047FB5: db $5C;X
L047FB6: db $5C;X
L047FB7: db $5C;X
L047FB8: db $5C;X
L047FB9: db $5C;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
         db $01;X
