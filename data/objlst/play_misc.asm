OBJLstPtrTable_CharCross:
	dw OBJLstHdrA_CharCross0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		
OBJLstPtrTable_TerryHat:
	dw OBJLstHdrA_TerryHat0, OBJLSTPTR_NONE
	dw OBJLstHdrA_TerryHat1, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		
OBJLstPtrTable_PreRoundText:
	dw OBJLstHdrA_PreRoundText0, OBJLSTPTR_NONE
	dw OBJLstHdrA_PreRoundText1, OBJLSTPTR_NONE
	dw OBJLstHdrA_PreRoundText2, OBJLSTPTR_NONE
	dw OBJLstHdrA_PreRoundText3, OBJLSTPTR_NONE
	dw OBJLstHdrA_PreRoundText4, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		
OBJLstPtrTable_PostRoundTextA:
	dw OBJLstHdrA_PostRoundTextA0, OBJLSTPTR_NONE
	dw OBJLstHdrA_PostRoundTextA1, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		
OBJLstPtrTable_PostRoundTextB:
	dw OBJLstHdrA_PostRoundTextB0, OBJLSTPTR_NONE
	dw OBJLstHdrA_PostRoundTextB1, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_PostRoundTextB2, OBJLSTPTR_NONE ;X
	dw OBJLstHdrA_PostRoundTextB3, OBJLSTPTR_NONE
	dw OBJLstHdrA_PostRoundTextB4, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		
OBJLstHdrA_CharCross0:
	db OLF_NOBUF ; iOBJLstHdrA_Flags
	db COLIBOX_00 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $F8,$F8,$00 ; $00
	db $F8,$00,$02 ; $01
		
OBJLstHdrA_TerryHat0:
	db OLF_NOBUF ; iOBJLstHdrA_Flags
	db COLIBOX_00 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $02 ; OBJ Count
	;    Y   X  ID
	db $3B,$FB,$04 ; $00
	db $34,$03,$06 ; $01
		
OBJLstHdrA_TerryHat1:
	db OLF_XFLIP|OLF_NOBUF ; iOBJLstHdrA_Flags
	db COLIBOX_00 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLstHdrA_TerryHat0.bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_PreRoundText0:
	db OLF_NOBUF ; iOBJLstHdrA_Flags
	db COLIBOX_00 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	db $00,$00,$00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $90 ; iOBJLstHdrA_XOffset
	db $18 ; iOBJLstHdrA_YOffset
.bin:
	db $0A ; OBJ Count
	;    Y   X  ID
	db $0E,$54,$38 ; $00
	db $0E,$5C,$3A ; $01
	db $0E,$64,$3C ; $02
	db $0E,$6C,$3E ; $03
	db $0E,$74,$40 ; $04
	db $0E,$7C,$42 ; $05
	db $10,$84,$44 ; $06
	db $10,$8C,$46 ; $07
	db $00,$84,$48 ; $08
	db $00,$8C,$4A ; $09
		
OBJLstHdrA_PreRoundText1:
	db OLF_NOBUF ; iOBJLstHdrA_Flags
	db COLIBOX_00 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	db $00,$00,$00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $A4 ; iOBJLstHdrA_XOffset
	db $D8 ; iOBJLstHdrA_YOffset
.bin:
	db $07 ; OBJ Count
	;    Y   X  ID
	db $4E,$44,$2A ; $00
	db $4E,$4C,$2C ; $01
	db $4E,$54,$2E ; $02
	db $4E,$5C,$30 ; $03
	db $4E,$64,$32 ; $04
	db $4E,$6C,$34 ; $05
	db $4E,$74,$36 ; $06
		
OBJLstHdrA_PreRoundText2:
	db OLF_NOBUF ; iOBJLstHdrA_Flags
	db COLIBOX_00 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	db $00,$00,$00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $D2 ; iOBJLstHdrA_XOffset
	db $18 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID
	db $0E,$1C,$00 ; $00
	db $0E,$24,$02 ; $01
	db $0E,$2C,$04 ; $02
	db $0E,$34,$06 ; $03
	db $0E,$3C,$08 ; $04
		
OBJLstHdrA_PreRoundText3:
	db OLF_NOBUF ; iOBJLstHdrA_Flags
	db COLIBOX_00 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	db $00,$00,$00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $CE ; iOBJLstHdrA_XOffset
	db $F8 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID
	db $2E,$24,$0A ; $00
	db $2E,$2C,$0C ; $01
	db $2E,$34,$0E ; $02
	db $2E,$3C,$10 ; $03
		
OBJLstHdrA_PreRoundText4:
	db OLF_NOBUF ; iOBJLstHdrA_Flags
	db COLIBOX_00 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	db $00,$00,$00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $C6 ; iOBJLstHdrA_XOffset
	db $DC ; iOBJLstHdrA_YOffset
.bin:
	db $0C ; OBJ Count
	;    Y   X  ID
	db $4E,$24,$12 ; $00
	db $4E,$2C,$14 ; $01
	db $4E,$34,$16 ; $02
	db $4E,$3C,$18 ; $03
	db $4E,$44,$1A ; $04
	db $4E,$4C,$1C ; $05
	db $3E,$24,$1E ; $06
	db $3E,$2C,$20 ; $07
	db $3E,$34,$22 ; $08
	db $3E,$3C,$24 ; $09
	db $3E,$44,$26 ; $0A
	db $3E,$4C,$28 ; $0B
		
OBJLstHdrA_PostRoundTextA0:
	db OLF_NOBUF ; iOBJLstHdrA_Flags
	db COLIBOX_00 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	db $00,$00,$00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $8B ; iOBJLstHdrA_XOffset
	db $02 ; iOBJLstHdrA_YOffset
.bin:
	db $0A ; OBJ Count
	;    Y   X  ID
	db $26,$60,$1A ; $00
	db $26,$68,$1C ; $01
	db $26,$70,$1E ; $02
	db $26,$78,$20 ; $03
	db $26,$80,$22 ; $04
	db $26,$88,$24 ; $05
	db $16,$63,$26 ; $06
	db $16,$6B,$28 ; $07
	db $16,$7B,$2A ; $08
	db $16,$83,$2C ; $09
		
OBJLstHdrA_PostRoundTextA1:
	db OLF_NOBUF ; iOBJLstHdrA_Flags
	db COLIBOX_00 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	db $00,$00,$00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $D8 ; iOBJLstHdrA_XOffset
	db $20 ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $06,$08,$08 ; $00
	db $06,$10,$0A ; $01
	db $06,$18,$0C ; $02
	db $06,$20,$0E ; $03
	db $06,$28,$10 ; $04
	db $06,$30,$12 ; $05
	db $06,$38,$14 ; $06
	db $06,$40,$16 ; $07
	db $03,$48,$18 ; $08
		
OBJLstHdrA_PostRoundTextB0:
	db OLF_NOBUF ; iOBJLstHdrA_Flags
	db COLIBOX_00 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	db $00,$00,$00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $C5 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $26,$18,$08 ; $00
	db $26,$20,$0A ; $01
	db $26,$28,$0C ; $02
	db $26,$30,$0E ; $03
	db $26,$38,$10 ; $04
	db $26,$40,$12 ; $05
	db $26,$48,$14 ; $06
	db $26,$50,$16 ; $07
	db $26,$58,$18 ; $08
		
OBJLstHdrA_PostRoundTextB3:
	db OLF_NOBUF ; iOBJLstHdrA_Flags
	db COLIBOX_00 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	db $00,$00,$00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $81 ; iOBJLstHdrA_XOffset
	db $E0 ; iOBJLstHdrA_YOffset
.bin:
	db $08 ; OBJ Count
	;    Y   X  ID
	db $46,$60,$2C ; $00
	db $46,$68,$2E ; $01
	db $46,$70,$30 ; $02
	db $45,$78,$32 ; $03
	db $46,$81,$1A ; $04
	db $46,$89,$1C ; $05
	db $46,$91,$1E ; $06
	db $46,$99,$20 ; $07
		
OBJLstHdrA_PostRoundTextB4:
	db OLF_NOBUF ; iOBJLstHdrA_Flags
	db COLIBOX_00 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	db $00,$00,$00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $81 ; iOBJLstHdrA_XOffset
	db $E0 ; iOBJLstHdrA_YOffset
.bin:
	db $09 ; OBJ Count
	;    Y   X  ID
	db $46,$60,$2C ; $00
	db $46,$68,$2E ; $01
	db $46,$70,$30 ; $02
	db $45,$78,$32 ; $03
	db $46,$80,$22 ; $04
	db $46,$88,$24 ; $05
	db $46,$90,$26 ; $06
	db $46,$98,$28 ; $07
	db $40,$A0,$2A ; $08
		
OBJLstHdrA_PostRoundTextB1: ;X
	db OLF_NOBUF ; iOBJLstHdrA_Flags
	db COLIBOX_00 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	db $00,$00,$00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $75 ; iOBJLstHdrA_XOffset
	db $E0 ; iOBJLstHdrA_YOffset
.bin: ;X
	db $06 ; OBJ Count
	;    Y   X  ID
	db $46,$74,$34 ; $00
	db $46,$7C,$36 ; $01
	db $46,$85,$1A ; $02
	db $46,$8D,$1C ; $03
	db $46,$95,$1E ; $04
	db $46,$9D,$20 ; $05
		
OBJLstHdrA_PostRoundTextB2: ;X
	db OLF_NOBUF ; iOBJLstHdrA_Flags
	db COLIBOX_00 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	db $00,$00,$00 ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $77 ; iOBJLstHdrA_XOffset
	db $E0 ; iOBJLstHdrA_YOffset
.bin: ;X
	db $07 ; OBJ Count
	;    Y   X  ID
	db $46,$70,$38 ; $00
	db $46,$78,$3A ; $01
	db $43,$80,$3C ; $02
	db $46,$85,$1A ; $03
	db $46,$8D,$1C ; $04
	db $46,$95,$1E ; $05
	db $46,$9D,$20 ; $06