OBJLstPtrTable_Cutscene_Kagura:
	dw OBJLstHdrA_Cutscene_Kagura0, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		
OBJLstHdrA_Cutscene_Kagura0:
	db OLF_NOBUF ; iOBJLstHdrA_Flags
	db COLIBOX_00 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $14 ; OBJ Count
	;    Y   X  ID
	db $28,$15,$00 ; $00
	db $28,$1D,$02 ; $01
	db $28,$25,$04 ; $02
	db $28,$2D,$06 ; $03
	db $2D,$35,$08 ; $04
	db $0E,$05,$0A ; $05
	db $11,$0D,$0C ; $06
	db $18,$15,$0E ; $07
	db $18,$1D,$10 ; $08
	db $18,$25,$12 ; $09
	db $18,$2D,$14 ; $0A
	db $1D,$35,$16 ; $0B
	db $01,$0D,$18 ; $0C
	db $08,$15,$1A ; $0D
	db $08,$1D,$1C ; $0E
	db $08,$25,$1E ; $0F
	db $08,$2D,$20 ; $10
	db $F8,$15,$22 ; $11
	db $F8,$1D,$24 ; $12
	db $F8,$25,$26 ; $13