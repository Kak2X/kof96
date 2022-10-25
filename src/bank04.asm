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

GFXLZ_Play_Stage_Hero: INCBIN "data/gfx/play_stage_hero.lzc"
BGLZ_Play_Stage_Hero: INCBIN "data/bg/play_stage_hero.lzs"
GFXLZ_Play_Stage_FatalFury: INCBIN "data/gfx/play_stage_fatalfury.lzc"
BGLZ_Play_Stage_FatalFury: INCBIN "data/bg/play_stage_fatalfury.lzs"
GFXLZ_Play_Stage_Yagami: INCBIN "data/gfx/play_stage_yagami.lzc"
BGLZ_Play_Stage_Yagami: INCBIN "data/bg/play_stage_yagami.lzs"
;L04735B: ; Junk padding byte, not used
	db $00
GFXLZ_Play_Stage_Boss: INCBIN "data/gfx/play_stage_boss.lzc"
BGLZ_Play_Stage_Boss: INCBIN "data/bg/play_stage_boss.lzs"
GFXLZ_Play_Stage_Stadium: INCBIN "data/gfx/play_stage_stadium.lzc"
BGLZ_Play_Stage_Stadium: INCBIN "data/bg/play_stage_stadium.lzs"

; =============== END OF BANK ===============
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
