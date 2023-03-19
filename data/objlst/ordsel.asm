OBJLstPtrTable_OrdSel_VS:
	dw OBJLstHdrA_OrdSel_VS, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		
OBJLstPtrTable_OrdSel_Cursor:
	dw OBJLstHdrA_OrdSel_Cursor, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		
OBJLstHdrA_OrdSel_VS:
	db OLF_NOBUF ; iOBJLstHdrA_Flags
	db $00 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $0B ; OBJ Count
	;    Y   X  ID+FLAG
	db $07,$03,$00 ; $00
	db $07,$0B,$02 ; $01
	db $07,$13,$04 ; $02
	db $07,$1B,$06 ; $03
	db $07,$23,$08 ; $04
	db $07,$2B,$0A ; $05
	db $17,$0B,$0C ; $06
	db $17,$13,$0E ; $07
	db $17,$1B,$10 ; $08
	db $17,$23,$12 ; $09
	db $17,$2B,$14 ; $0A
		
OBJLstHdrA_OrdSel_Cursor:
	db OLF_NOBUF ; iOBJLstHdrA_Flags
	db $00 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $03 ; OBJ Count
	;    Y   X  ID+FLAG
	db $0C,$08,$16 ; $00
	db $0C,$00,$18 ; $01
	db $0C,$10,$1A ; $02