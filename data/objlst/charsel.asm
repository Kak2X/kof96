OBJLstPtrTable_CharSel_Cursor:
	dw OBJLstHdrA_CharSel_CursorPl1P, OBJLSTPTR_NONE
	dw OBJLstHdrA_CharSel_CursorPl1PWide, OBJLSTPTR_NONE
	dw OBJLstHdrA_CharSel_CursorPl2P, OBJLSTPTR_NONE
	dw OBJLstHdrA_CharSel_CursorPl2PWide, OBJLSTPTR_NONE
	dw OBJLstHdrA_CharSel_CursorCPU1P, OBJLSTPTR_NONE
	dw OBJLstHdrA_CharSel_CursorCPU1PWide, OBJLSTPTR_NONE
	dw OBJLstHdrA_CharSel_CursorCPU2P, OBJLSTPTR_NONE
	dw OBJLstHdrA_CharSel_CursorCPU2PWide, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		
OBJLstHdrA_CharSel_CursorPl1P:
	db OLF_USETILEFLAGS|OLF_NOBUF ; iOBJLstHdrA_Flags
	db $00 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID+FLAG
	db $28,$0B,$00 ; $00
	db $28,$13,$04 ; $01
	db $28,$08,$0C ; $02
	db $30,$18,$0C|OLR_XFLIP|OLR_YFLIP ; $03
		
OBJLstHdrA_CharSel_CursorPl1PWide:
	db OLF_USETILEFLAGS|OLF_NOBUF ; iOBJLstHdrA_Flags
	db $00 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID+FLAG
	db $28,$17,$00 ; $00
	db $28,$1F,$04 ; $01
	db $28,$08,$0C ; $02
	db $30,$30,$0C|OLR_XFLIP|OLR_YFLIP ; $03
		
OBJLstHdrA_CharSel_CursorPl2P:
	db OLF_USETILEFLAGS|OLF_NOBUF ; iOBJLstHdrA_Flags
	db $00 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID+FLAG
	db $38,$0C,$02 ; $00
	db $38,$14,$04 ; $01
	db $28,$18,$0C|OLR_XFLIP ; $02
	db $30,$08,$0C|OLR_YFLIP ; $03
		
OBJLstHdrA_CharSel_CursorPl2PWide:
	db OLF_USETILEFLAGS|OLF_NOBUF ; iOBJLstHdrA_Flags
	db $00 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $04 ; OBJ Count
	;    Y   X  ID+FLAG
	db $38,$18,$02 ; $00
	db $38,$20,$04 ; $01
	db $28,$30,$0C|OLR_XFLIP ; $02
	db $30,$08,$0C|OLR_YFLIP ; $03
	
OBJLstHdrA_CharSel_CursorCPU1P:
	db OLF_USETILEFLAGS|OLF_NOBUF ; iOBJLstHdrA_Flags
	db $00 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID+FLAG
	db $29,$08,$06 ; $00
	db $29,$10,$08 ; $01
	db $29,$18,$0A ; $02
	db $28,$08,$0C ; $03
	db $30,$18,$0C|OLR_XFLIP|OLR_YFLIP ; $04
		
OBJLstHdrA_CharSel_CursorCPU1PWide:
	db OLF_USETILEFLAGS|OLF_NOBUF ; iOBJLstHdrA_Flags
	db $00 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID+FLAG
	db $29,$14,$06 ; $00
	db $29,$1C,$08 ; $01
	db $29,$24,$0A ; $02
	db $28,$08,$0C ; $03
	db $30,$30,$0C|OLR_XFLIP|OLR_YFLIP ; $04
	
OBJLstHdrA_CharSel_CursorCPU2P:
	db OLF_USETILEFLAGS|OLF_NOBUF ; iOBJLstHdrA_Flags
	db $00 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID+FLAG
	db $37,$08,$06 ; $00
	db $37,$10,$08 ; $01
	db $37,$18,$0A ; $02
	db $28,$18,$0C|OLR_XFLIP ; $03
	db $30,$08,$0C|OLR_YFLIP ; $04
		
OBJLstHdrA_CharSel_CursorCPU2PWide:
	db OLF_USETILEFLAGS|OLF_NOBUF ; iOBJLstHdrA_Flags
	db $00 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw .bin ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
.bin:
	db $05 ; OBJ Count
	;    Y   X  ID+FLAG
	db $37,$14,$06|$00 ; $00
	db $37,$1C,$08|$00 ; $01
	db $37,$24,$0A|$00 ; $02
	db $28,$30,$0C|OLR_XFLIP ; $03
	db $30,$08,$0C|OLR_YFLIP ; $04
		
OBJLstPtrTable_CharSel_Flip:
	dw OBJLstHdrA_CharSel_FlipP0, OBJLSTPTR_NONE
	dw OBJLstHdrA_CharSel_FlipP1, OBJLSTPTR_NONE
	dw OBJLstHdrA_CharSel_FlipP2, OBJLSTPTR_NONE
	dw OBJLstHdrA_CharSel_FlipP3, OBJLSTPTR_NONE
	dw OBJLstHdrA_CharSel_FlipP4, OBJLSTPTR_NONE
	dw OBJLstHdrA_CharSel_FlipP3, OBJLSTPTR_NONE
	dw OBJLstHdrA_CharSel_FlipP2, OBJLSTPTR_NONE
	dw OBJLstHdrA_CharSel_FlipP1, OBJLSTPTR_NONE
	dw OBJLSTPTR_NONE
		
OBJLstHdrA_CharSel_FlipP2:
	db OLF_NOBUF ; iOBJLstHdrA_Flags
	db $00 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLst_CharSel_Flip0 ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_CharSel_FlipP0:
	db OLF_NOBUF ; iOBJLstHdrA_Flags
	db $00 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLst_CharSel_Flip1 ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_CharSel_FlipP1:
	db OLF_NOBUF ; iOBJLstHdrA_Flags
	db $00 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLst_CharSel_Flip2 ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_CharSel_FlipP4:
	db OLF_NOBUF ; iOBJLstHdrA_Flags
	db $00 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLst_CharSel_Flip3 ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLstHdrA_CharSel_FlipP3:
	db OLF_NOBUF ; iOBJLstHdrA_Flags
	db $00 ; iOBJLstHdrA_ColiBoxId
	db $00 ; iOBJLstHdrA_HitboxId
	db $FF,$FF,$FF ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw OBJLst_CharSel_Flip4 ; iOBJLstHdrA_DataPtr
	db $00 ; iOBJLstHdrA_XOffset
	db $00 ; iOBJLstHdrA_YOffset
		
OBJLst_CharSel_Flip0:
	db $02 ; OBJ Count
	;    Y   X  ID+FLAG
	db $28,$13,$00 ; $00
	db $38,$13,$02 ; $01
		
OBJLst_CharSel_Flip1:
	db $04 ; OBJ Count
	;    Y   X  ID+FLAG
	db $28,$0C,$04 ; $00
	db $28,$14,$06 ; $01
	db $38,$0C,$08 ; $02
	db $38,$14,$0A ; $03
		
OBJLst_CharSel_Flip2:
	db $02 ; OBJ Count
	;    Y   X  ID+FLAG
	db $28,$10,$0C ; $00
	db $38,$10,$0E ; $01
		
OBJLst_CharSel_Flip3:
	db $04 ; OBJ Count
	;    Y   X  ID+FLAG
	db $28,$0C,$10 ; $00
	db $28,$14,$12 ; $01
	db $38,$0C,$14 ; $02
	db $38,$14,$16 ; $03
		
OBJLst_CharSel_Flip4:
	db $02 ; OBJ Count
	;    Y   X  ID+FLAG
	db $28,$10,$18 ; $00
	db $38,$10,$1A ; $01