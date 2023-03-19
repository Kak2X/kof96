OBJLstPtrTable_Intro_Iori:
	dw OBJLstHdrA_Intro_Iori0, $FFFF
	dw OBJLstHdrA_Intro_Iori1, $FFFF
	dw $FFFF
		
OBJLstHdrA_Intro_Iori0:
	db OLF_NOBUF ; iOBJLstHdrA_Flags
	db $00 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $11 ; OBJ Count
	;    Y   X  ID+FLAG
	db $40,$21,$18 ; $00
	db $40,$29,$1A ; $01
	db $40,$31,$1C ; $02
	db $40,$39,$1E ; $03
	db $40,$41,$20 ; $04
	db $40,$49,$22 ; $05
	db $30,$29,$24 ; $06
	db $30,$31,$26 ; $07
	db $30,$39,$28 ; $08
	db $30,$41,$2A ; $09
	db $30,$49,$2C ; $0A
	db $20,$29,$2E ; $0B
	db $20,$31,$30 ; $0C
	db $20,$39,$32 ; $0D
	db $20,$41,$34 ; $0E
	db $20,$49,$36 ; $0F
	db $35,$51,$38 ; $10
		
OBJLstHdrA_Intro_Iori1:
	db OLF_NOBUF ; iOBJLstHdrA_Flags
	db $00 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $0C ; OBJ Count
	;    Y   X  ID+FLAG
	db $60,$21,$00 ; $00
	db $60,$29,$02 ; $01
	db $60,$31,$04 ; $02
	db $60,$39,$06 ; $03
	db $60,$41,$08 ; $04
	db $60,$49,$0A ; $05
	db $50,$21,$0C ; $06
	db $50,$29,$0E ; $07
	db $50,$31,$10 ; $08
	db $50,$39,$12 ; $09
	db $50,$41,$14 ; $0A
	db $50,$49,$16 ; $0B