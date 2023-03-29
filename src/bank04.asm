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
	pkg SGB_PACKET_MLT_REQ, $01
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

SGBPacket_EnableMultiJoy_2Pl: 
	pkg SGB_PACKET_MLT_REQ, $01
	db $01 ; Enable multicontroller, two players
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

; [TCRF] Unreferenced SGB Packet
SGBPacket_Unused_EnableMultiJoy_4Pl:
	pkg SGB_PACKET_MLT_REQ, $01
	db $03 ; Enable multicontroller, four players
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

SGBPacket_SGB1BiosPatch7:
	pkg SGB_PACKET_DATA_SND, $01
	dw $085D ; SNES Destination - Ptr
	db $00 ; SNES Destination - Bank
	db $0B ; Write $0B bytes
	db $8C,$D0,$F4,$60,$00,$00,$00,$00,$00,$00,$00 ; Byte sequence
SGBPacket_SGB1BiosPatch6:
	pkg SGB_PACKET_DATA_SND, $01
	dw $0852 ; SNES Destination - Ptr
	db $00 ; SNES Destination - Bank
	db $0B ; Write $0B bytes
	db $A9,$E7,$9F,$01,$C0,$7E,$E8,$E8,$E8,$E8,$E0 ; Byte sequence
SGBPacket_SGB1BiosPatch5:
	pkg SGB_PACKET_DATA_SND, $01
	dw $0847 ; SNES Destination - Ptr
	db $00 ; SNES Destination - Bank
	db $0B ; Write $0B bytes
	db $C4,$D0,$16,$A5,$CB,$C9,$05,$D0,$10,$A2,$28 ; Byte sequence
SGBPacket_SGB1BiosPatch4:
	pkg SGB_PACKET_DATA_SND, $01
	dw $083C ; SNES Destination - Ptr
	db $00 ; SNES Destination - Bank
	db $0B ; Write $0B bytes
	db $F0,$12,$A5,$C9,$C9,$C8,$D0,$1C,$A5,$CA,$C9 ; Byte sequence
SGBPacket_SGB1BiosPatch3:
	pkg SGB_PACKET_DATA_SND, $01
	dw $0831 ; SNES Destination - Ptr
	db $00 ; SNES Destination - Bank
	db $0B ; Write $0B bytes
	db $0C,$A5,$CA,$C9,$7E,$D0,$06,$A5,$CB,$C9,$7E ; Byte sequence
SGBPacket_SGB1BiosPatch2:
	pkg SGB_PACKET_DATA_SND, $01
	dw $0826 ; SNES Destination - Ptr
	db $00 ; SNES Destination - Bank
	db $0B ; Write $0B bytes
	db $39,$CD,$48,$0C,$D0,$34,$A5,$C9,$C9,$80,$D0 ; Byte sequence
SGBPacket_SGB1BiosPatch1:
	pkg SGB_PACKET_DATA_SND, $01
	dw $081B ; SNES Destination - Ptr
	db $00 ; SNES Destination - Bank
	db $0B ; Write $0B bytes
	db $EA,$EA,$EA,$EA,$EA,$A9,$01,$CD,$4F,$0C,$D0 ; Byte sequence
SGBPacket_SGB1BiosPatch0:
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
	; Prepare the display for SGB packet transfer.
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
IF ENGLISH == 1
	dw SGBPacket_LagunaLogo_Pal01,      $0000,                      SGBPacket_Pat_AllPal0,    $0000
ENDC

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

IF ENGLISH == 0
; Black/White Takara logo
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
ELSE
; New Red/Black Takara logo
SGBPacket_TakaraLogo_Pal01:
	pkg SGB_PACKET_PAL01, $01
	dw $009C ; 0-0
	dw $0014 ; 0-1
	dw $000C ; 0-2WW
	dw $0000 ; 0-3
	dw $0000 ; 1-1
	dw $0000 ; 1-2
	dw $0000 ; 1-3
	db $00
	
; LAGUNA PROUDLY PRESENT
SGBPacket_LagunaLogo_Pal01: 
	pkg SGB_PACKET_PAL01, $01
	dw $739C ; 0-0
	dw $011C ; 0-1
	dw $7380 ; 0-2
	dw $0000 ; 0-3
	dw $0000 ; 1-1
	dw $0000 ; 1-2
	dw $0000 ; 1-3
	db $00
ENDC

IF ENGLISH == 0
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
ELSE
SGBPacket_Title_Pal01:
	pkg SGB_PACKET_PAL01, $01
	dw $6B5A ; 0-0
	dw $031F ; 0-1
	dw $001E ; 0-2
	dw $1807 ; 0-3
	dw $031F ; 1-1
	dw $0094 ; 1-2
	dw $1807 ; 1-3
	db $00
SGBPacket_Title_Pal23:
	pkg SGB_PACKET_PAL23, $01	
	dw $6F7A ; 0-0
	dw $031F ; 2-1
	dw $6252 ; 2-2
	dw $1807 ; 2-3
	dw $0198 ; 3-1
	dw $0010 ; 3-2
	dw $1807 ; 3-3
	db $00
ENDC
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

	mIncJunk "L0442A1"
	
IF ENGLISH == 0
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
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	
	mIncJunk "L0442E9"
ELSE
; The English version has its own title
SGBPacket_Title_Pat:
	pkg SGB_PACKET_ATTR_BLK, $02
	db $03 ; 3 sets
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
	ads 3,3,3 ; Pals
	db $00 ; X1
	db $0C ; Y1
	db $13 ; X2
	db $11 ; Y2
	;--
	; Color "Heat of Battle" with a browner palette
	db %00000010 ; Change box border
	ads 1,1,1 ; Pals
	db $09 ; X1
	db $08 ; Y1
	db $13 ; X2
	db $09 ; Y2
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
	db $00
	db $00
	mIncJunk "L0442E1"
ENDC
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

	mIncJunk "L04431F"

; [TCRF] Leftover packets for the Win Screen from KOF95.
;        In 95, the Win Screen displayed either large character pictures.
;
;        Three pictures can be displayed, one for each team member,
;        with every one using a different palette.

; Center Picture (Active Character)
SGBPacket_Unused_WinScrPic95C_Pat:
	pkg SGB_PACKET_ATTR_BLK, $01
	db $01 ; 1 set
	;--
	db %00000011 ; Change filled box with border
	ads 1,1,1 ; Pals
	db $07 ; X1
	db $03 ; Y1
	db $0C ; X2
	db $08 ; Y2
	;--
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00

; Left picture
SGBPacket_Unused_WinScrPic95L_Pat:
	pkg SGB_PACKET_ATTR_BLK, $01
	db $01 ; 1 set
	;--
	db %00000011 ; Change filled box with border
	ads 2,2,2 ; Pals
	db $01 ; X1
	db $03 ; Y1
	db $06 ; X2
	db $08 ; Y2
	;--
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	
; Right picture
SGBPacket_Unused_WinScrPic95R_Pat:
	pkg SGB_PACKET_ATTR_BLK, $01
	db $01 ; 1 set
	;--
	db %00000011 ; Change filled box with border
	ads 3,3,3 ; Pals
	db $0D ; X1
	db $03 ; Y1
	db $12 ; X2
	db $08 ; Y2
	;--
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00

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
	
IF FIX_BUGS == 0
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
ENDC
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
	mIncJunk "L0443D8"
	
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
	mIncJunk "L0443EA"
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
	mIncJunk "L0443FB"
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
	
IF ENGLISH == 0
GFXLZ_SGB_Border0: INCBIN "data/gfx/jp/sgb_border0.lzc"
GFXLZ_SGB_Border1: INCBIN "data/gfx/jp/sgb_border1.lzc"
BGLZ_SGB_Border: INCBIN "data/bg/jp/sgb_border.lzs"
SGBPalDef_Border_Normal:
	dw SGBPal_Border_Normal.end-SGBPal_Border_Normal ; $0060
SGBPal_Border_Normal:
	INCBIN "data/pal/jp/sgb_border_normal.bin"
.end:
SGBPalDef_Border_Alt:
	dw SGBPal_Border_Alt.end-SGBPal_Border_Alt ; $0060
SGBPal_Border_Alt:
	INCBIN "data/pal/jp/sgb_border_alt.bin"
.end:
ELSE
GFXLZ_SGB_Border0: INCBIN "data/gfx/en/sgb_border0.lzc"
GFXLZ_SGB_Border1: INCBIN "data/gfx/en/sgb_border1.lzc"
BGLZ_SGB_Border: INCBIN "data/bg/en/sgb_border.lzs"
SGBPalDef_Border_Normal:
	dw SGBPal_Border_Normal.end-SGBPal_Border_Normal ; $0040
SGBPal_Border_Normal:
	INCBIN "data/pal/en/sgb_border_normal.bin"
.end:
SGBPalDef_Border_Alt:
	dw SGBPal_Border_Alt.end-SGBPal_Border_Alt ; $0040
SGBPal_Border_Alt:
	INCBIN "data/pal/en/sgb_border_alt.bin"
.end:
ENDC

; This stage contains a sign saying "KOF96", so it got changed
GFXLZ_Play_Stage_Hero:
IF ENGLISH == 0
	INCBIN "data/gfx/jp/play_stage_hero.lzc"
ELSE
	INCBIN "data/gfx/en/play_stage_hero.lzc"
ENDC

BGLZ_Play_Stage_Hero: INCBIN "data/bg/play_stage_hero.lzs"
GFXLZ_Play_Stage_FatalFury: INCBIN "data/gfx/play_stage_fatalfury.lzc"
BGLZ_Play_Stage_FatalFury: INCBIN "data/bg/play_stage_fatalfury.lzs"
GFXLZ_Play_Stage_Yagami: INCBIN "data/gfx/play_stage_yagami.lzc"
BGLZ_Play_Stage_Yagami: INCBIN "data/bg/play_stage_yagami.lzs"

	mIncJunk "L04735B"
	
GFXLZ_Play_Stage_Boss: INCBIN "data/gfx/play_stage_boss.lzc"
BGLZ_Play_Stage_Boss: INCBIN "data/bg/play_stage_boss.lzs"
GFXLZ_Play_Stage_Stadium: INCBIN "data/gfx/play_stage_stadium.lzc"
BGLZ_Play_Stage_Stadium: INCBIN "data/bg/play_stage_stadium.lzs"

IF ENGLISH == 0
	; =============== END OF BANK ===============
	mIncJunk "L047E37"
ELSE
; TODO: TextC_ structures
L047AA5: db $00
TextC_CutsceneMrKarateDefeat0: db $48 ; M
L047AA7: db $48
L047AA8: db $6D
L047AA9: db $6D
L047AAA: db $2E
L047AAB: db $2E
L047AAC: db $2E
L047AAD: db $20
L047AAE: db $50
L047AAF: db $72
L047AB0: db $65
L047AB1: db $74
L047AB2: db $74
L047AB3: db $79
L047AB4: db $20
L047AB5: db $67
L047AB6: db $6F
L047AB7: db $6F
L047AB8: db $64
L047AB9: db $2E
L047ABA: db $FF
L047ABB: db $59
L047ABC: db $6F
L047ABD: db $75
L047ABE: db $60
L047ABF: db $76
L047AC0: db $65
L047AC1: db $20
L047AC2: db $67
L047AC3: db $6F
L047AC4: db $74
L047AC5: db $20
L047AC6: db $73
L047AC7: db $74
L047AC8: db $72
L047AC9: db $6F
L047ACA: db $6E
L047ACB: db $67
L047ACC: db $65
L047ACD: db $72
L047ACE: db $FF
L047ACF: db $20
L047AD0: db $73
L047AD1: db $69
L047AD2: db $6E
L047AD3: db $63
L047AD4: db $65
L047AD5: db $20
L047AD6: db $74
L047AD7: db $68
L047AD8: db $65
L047AD9: db $FF
L047ADA: db $20
L047ADB: db $20
L047ADC: db $20
L047ADD: db $20
L047ADE: db $20
L047ADF: db $20
L047AE0: db $20
L047AE1: db $74
L047AE2: db $6F
L047AE3: db $75
L047AE4: db $72
L047AE5: db $6E
L047AE6: db $61
L047AE7: db $6D
L047AE8: db $65
L047AE9: db $6E
L047AEA: db $74
L047AEB: db $2E
L047AEC: db $2E
L047AED: db $2E
L047AEE: db $FF
TextC_CutsceneMrKarateDefeat1: db $22
L047AF0: db $54
L047AF1: db $68
L047AF2: db $65
L047AF3: db $20
L047AF4: db $6C
L047AF5: db $61
L047AF6: db $73
L047AF7: db $74
L047AF8: db $20
L047AF9: db $74
L047AFA: db $6F
L047AFB: db $75
L047AFC: db $72 ; M
L047AFD: db $6E
L047AFE: db $61 ; M
L047AFF: db $6D
L047B00: db $65 ; M
L047B01: db $6E
L047B02: db $74
L047B03: db $3F
L047B04: db $FF
L047B05: db $53
L047B06: db $6F
L047B07: db $20
L047B08: db $79
L047B09: db $6F
L047B0A: db $75
L047B0B: db $60
L047B0C: db $72
L047B0D: db $65
L047B0E: db $2E
L047B0F: db $2E
L047B10: db $2E
L047B11: db $FF
TextC_CutsceneMrKarateDefeat2: db $4E
L047B13: db $4E
L047B14: db $6F
L047B15: db $21
L047B16: db $20
L047B17: db $41
L047B18: db $62
L047B19: db $73
L047B1A: db $6F
L047B1B: db $6C
L047B1C: db $75
L047B1D: db $74 ; M
L047B1E: db $65
L047B1F: db $6C
L047B20: db $79
L047B21: db $20
L047B22: db $6E
L047B23: db $6F
L047B24: db $74
L047B25: db $21
L047B26: db $FF
L047B27: db $49
L047B28: db $20
L047B29: db $61
L047B2A: db $6D ; M
L047B2B: db $20
L047B2C: db $74
L047B2D: db $68
L047B2E: db $65
L047B2F: db $20
L047B30: db $6C
L047B31: db $65
L047B32: db $67
L047B33: db $65
L047B34: db $6E
L047B35: db $64
L047B36: db $61
L047B37: db $72
L047B38: db $79
L047B39: db $FF
L047B3A: db $20 ; M
L047B3B: db $20
L047B3C: db $66
L047B3D: db $69
L047B3E: db $67
L047B3F: db $68
L047B40: db $74
L047B41: db $65
L047B42: db $72
L047B43: db $2C
L047B44: db $4D ; M
L047B45: db $72
L047B46: db $20
L047B47: db $4B
L047B48: db $61
L047B49: db $72
L047B4A: db $61
L047B4B: db $74 ; M
L047B4C: db $65
L047B4D: db $2E
L047B4E: db $FF
L047B4F: db $49
L047B50: db $20
L047B51: db $61
L047B52: db $6D
L047B53: db $20
L047B54: db $6E
L047B55: db $6F
L047B56: db $74 ; M
L047B57: db $20
L047B58: db $54
L047B59: db $61
L047B5A: db $6B
L047B5B: db $75
L047B5C: db $6D ; M
L047B5D: db $61
L047B5E: db $21
L047B5F: db $21
L047B60: db $FF
; =============== END OF BANK ===============
	mIncJunk "L047B60"
ENDC