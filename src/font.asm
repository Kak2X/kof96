PUSHC

;
; JAPANESE FONT DEFINITION
;
; Bizzarro JIS X 0201-like with the lowercase latin characters sacrificed for katakana characters + some symbols,
; and with the katakana characters replaced by their hirigana equivalent.
;
; Should match what's mapped in TextPrinter_CharsetToTileTbl.
;
NEWCHARMAP jpn
	; Arrows
	CHARMAP "↑", $00
	CHARMAP "→", $01
	CHARMAP "↓", $02
	CHARMAP "←", $03

	; Normal ASCII
	CHARMAP " ", $20
	CHARMAP "!", $21
	CHARMAP "\"", $22
	CHARMAP "(", $28
	CHARMAP ")", $29
	CHARMAP "+", $2B
	CHARMAP ",", $2C
	CHARMAP "-", $2D
	CHARMAP ".", $2E
	CHARMAP "0", $30
	CHARMAP "1", $31
	CHARMAP "2", $32
	CHARMAP "3", $33
	CHARMAP "4", $34
	CHARMAP "5", $35
	CHARMAP "6", $36
	CHARMAP "7", $37
	CHARMAP "8", $38
	CHARMAP "9", $39
	CHARMAP "?", $3F
	CHARMAP "<r.>", $40 ; "r." from Mr.Karate
	CHARMAP "A", $41
	CHARMAP "B", $42
	CHARMAP "C", $43
	CHARMAP "D", $44
	CHARMAP "E", $45
	CHARMAP "F", $46
	CHARMAP "G", $47
	CHARMAP "H", $48
	CHARMAP "I", $49
	CHARMAP "J", $4A
	CHARMAP "K", $4B
	CHARMAP "L", $4C
	CHARMAP "M", $4D
	CHARMAP "N", $4E
	CHARMAP "O", $4F
	CHARMAP "P", $50
	CHARMAP "Q", $51
	CHARMAP "R", $52
	CHARMAP "S", $53
	CHARMAP "T", $54
	CHARMAP "U", $55
	CHARMAP "V", $56
	CHARMAP "W", $57
	CHARMAP "X", $58
	CHARMAP "Y", $59
	CHARMAP "Z", $5A
	CHARMAP "`", $60 ; Alternate '
	CHARMAP "a", $61
	CHARMAP "b", $62
	CHARMAP "c", $63
	CHARMAP "d", $64
	CHARMAP "e", $65
	CHARMAP "f", $66
	CHARMAP "g", $67
	CHARMAP "h", $68
	CHARMAP "i", $69
	CHARMAP "j", $6A
	CHARMAP "k", $6B
	CHARMAP "l", $6C
	CHARMAP "m", $6D
	CHARMAP "n", $6E
	CHARMAP "o", $6F
	CHARMAP "p", $70
	CHARMAP "q", $71
	CHARMAP "r", $72
	CHARMAP "s", $73
	CHARMAP "t", $74
	CHARMAP "u", $75
	CHARMAP "v", $76
	CHARMAP "w", $77
	CHARMAP "x", $78
	CHARMAP "y", $79
	CHARMAP "z", $7A

	; Katakana block
	CHARMAP "ッ", $61
	CHARMAP "ア", $62
	CHARMAP "オ", $63
	CHARMAP "カ", $64
	CHARMAP "コ", $65
	CHARMAP "シ", $66
	CHARMAP "チ", $67
	CHARMAP "テ", $68
	CHARMAP "ト", $69
	CHARMAP "ナ", $6A
	CHARMAP "ハ", $6B 
	CHARMAP "ヒ", $6C
	CHARMAP "フ", $6D
	CHARMAP "メ", $6E
	CHARMAP "ロ", $6F
	CHARMAP "ワ", $70
	CHARMAP "ン", $71
	CHARMAP "ホ", $72
	CHARMAP "タ", $73

	; JIS with hirigana
	CHARMAP "。", $A1
	CHARMAP "、", $A4
	CHARMAP "・", $A5
	CHARMAP "を", $A6
	CHARMAP "ぁ", $A7
	CHARMAP "ぃ", $A8
	CHARMAP "ゃ", $AC
	CHARMAP "ゅ", $AD
	CHARMAP "ょ", $AE 
	CHARMAP "っ", $AF 
	CHARMAP "ｰ", $B0
	CHARMAP "あ", $B1
	CHARMAP "い", $B2
	CHARMAP "う", $B3 
	CHARMAP "え", $B4
	CHARMAP "お", $B5
	CHARMAP "か", $B6
	CHARMAP "き", $B7
	CHARMAP "く", $B8 
	CHARMAP "け", $B9
	CHARMAP "こ", $BA
	CHARMAP "さ", $BB
	CHARMAP "し", $BC
	CHARMAP "す", $BD
	CHARMAP "せ", $BE
	CHARMAP "そ", $BF
	CHARMAP "た", $C0
	CHARMAP "ち", $C1
	CHARMAP "つ", $C2
	CHARMAP "て", $C3
	CHARMAP "と", $C4 
	CHARMAP "な", $C5
	CHARMAP "に", $C6
	CHARMAP "ぬ", $C7
	CHARMAP "ね", $C8
	CHARMAP "の", $C9
	CHARMAP "は", $CA
	CHARMAP "ひ", $CB
	CHARMAP "ふ", $CC
	CHARMAP "へ", $CD
	CHARMAP "ほ", $CE
	CHARMAP "ま", $CF
	CHARMAP "み", $D0
	CHARMAP "む", $D1
	CHARMAP "め", $D2
	CHARMAP "も", $D3
	CHARMAP "や", $D4
	CHARMAP "ゆ", $D5
	CHARMAP "よ", $D6
	CHARMAP "ら", $D7
	CHARMAP "リ", $D8 
	CHARMAP "る", $D9
	CHARMAP "れ", $DA
	CHARMAP "ろ", $DB
	CHARMAP "わ", $DC
	CHARMAP "ん", $DD
	CHARMAP "ﾞ", $DE
	CHARMAP "ﾟ", $DF

;
; ENGLISH FONT DEFINITION
;
; It's just ASCII, with a few characters replaced with special ones.
;
; Should match what's mapped in TextPrinter_CharsetToTileTbl.
;
NEWCHARMAP eng
	; Arrows
	CHARMAP "↓", $00
	CHARMAP "←", $01
	
	; Normal ASCII
	CHARMAP " ", $20
	CHARMAP "!", $21
	CHARMAP "\"", $22
	CHARMAP "(", $28
	CHARMAP ")", $29
	CHARMAP "+", $2B
	CHARMAP ",", $2C
	CHARMAP "-", $2D
	CHARMAP ".", $2E
	CHARMAP "0", $30
	CHARMAP "1", $31
	CHARMAP "2", $32
	CHARMAP "3", $33
	CHARMAP "4", $34
	CHARMAP "5", $35
	CHARMAP "6", $36
	CHARMAP "7", $37
	CHARMAP "8", $38
	CHARMAP "9", $39
	CHARMAP "?", $3F
	CHARMAP "<r.>", $40 ; "r." from Mr.Karate
	CHARMAP "A", $41
	CHARMAP "B", $42
	CHARMAP "C", $43
	CHARMAP "D", $44
	CHARMAP "E", $45
	CHARMAP "F", $46
	CHARMAP "G", $47
	CHARMAP "H", $48
	CHARMAP "I", $49
	CHARMAP "J", $4A
	CHARMAP "K", $4B
	CHARMAP "L", $4C
	CHARMAP "M", $4D
	CHARMAP "N", $4E
	CHARMAP "O", $4F
	CHARMAP "P", $50
	CHARMAP "Q", $51
	CHARMAP "R", $52
	CHARMAP "S", $53
	CHARMAP "T", $54
	CHARMAP "U", $55
	CHARMAP "V", $56
	CHARMAP "W", $57
	CHARMAP "X", $58
	CHARMAP "Y", $59
	CHARMAP "Z", $5A
	CHARMAP "`", $60 ; Alternate '
	CHARMAP "a", $61
	CHARMAP "b", $62
	CHARMAP "c", $63
	CHARMAP "d", $64
	CHARMAP "e", $65
	CHARMAP "f", $66
	CHARMAP "g", $67
	CHARMAP "h", $68
	CHARMAP "i", $69
	CHARMAP "j", $6A
	CHARMAP "k", $6B
	CHARMAP "l", $6C
	CHARMAP "m", $6D
	CHARMAP "n", $6E
	CHARMAP "o", $6F
	CHARMAP "p", $70
	CHARMAP "q", $71
	CHARMAP "r", $72
	CHARMAP "s", $73
	CHARMAP "t", $74
	CHARMAP "u", $75
	CHARMAP "v", $76
	CHARMAP "w", $77
	CHARMAP "x", $78
	CHARMAP "y", $79
	CHARMAP "z", $7A
POPC