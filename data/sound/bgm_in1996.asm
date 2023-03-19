SndHeader_BGM_In1996:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_In1996_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_In1996_Ch2 ; Data ptr
	db $18 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_In1996_Ch3 ; Data ptr
	db $0C ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_In1996_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_BGM_In1996_Ch1:
	sndenv 7, SNDENV_DEC, 1
	sndenach SNDOUT_CH1R|SNDOUT_CH1L
	sndnr11 2, 0
	sndnote $00
	sndlen 56
.main:
	sndnote $00
	sndlen 7
	sndnote $24
	sndnote $29
	sndlen 14
	sndnote $27
	sndlen 7
	sndnote $29
	sndlen 14
	sndnote $29
	sndnote $24
	sndlen 7
	sndnote $29
	sndlen 14
	sndnote $27
	sndlen 7
	sndnote $29
	sndlen 21
	sndloopcnt $00, 3, .main
	sndenv 7, SNDENV_DEC, 7
	sndnr11 3, 0
	sndnote $00
	sndlen 7
	sndnote $11
	sndnote $00
	sndlen 14
	sndnote $11
	sndlen 7
	sndnote $11
	sndnote $00
	sndnote $0E
	sndlen 21
	sndnote $0E
	sndlen 14
	sndnote $11
	sndlen 7
	sndnote $11
	sndnote $00
	sndenv 7, SNDENV_INC, 0
	sndnote $22
	sndlen 21
	sndnote $24
	sndlen 56
	sndlenpre $07
	sndnote $00
	sndnote $27
	sndlen 14
	sndnote $24
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $27
	sndlen 21
	sndnote $29
	sndlen 35
	sndnote $00
	sndlen 7
	sndnote $29
	sndlen 28
	sndnote $30
	sndlen 21
	sndnote $2E
	sndlen 7
	sndlenpre $70
	sndnote $00
	sndlen 7
	sndnote $30
	sndnote $00
	sndlen 14
	sndnote $2E
	sndnote $30
	sndlen 7
	sndnote $33
	sndlen 84
	sndlenpre $03
	sndnote $00
	sndlen 4
	sndnote $35
	sndlen 7
	sndnote $30
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $35
	sndlen 10
	sndnote $00
	sndlen 4
	sndnote $33
	sndlen 14
	sndnote $00
	sndlen 7
	sndnote $35
	sndlen 28
	sndnote $00
	sndlen 7
	sndendch
SndData_BGM_In1996_Ch2:
	sndenv 6, SNDENV_INC, 0
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 1, 0
	sndnote $00
	sndlen 28
	sndnote $08
	sndlen 14
	sndnote $0A
	sndlen 7
	sndnote $0A
	sndlen 21
	sndnote $05
	sndlen 84
	sndnote $05
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $08
	sndlen 7
	sndlenpre $38
	sndnote $00
	sndlen 14
	sndnote $05
	sndnote $08
	sndnote $05
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $08
	sndlen 7
	sndlenpre $0E
	sndnote $0A
	sndlen 56
	sndnote $0A
	sndlen 14
	sndnote $08
	sndnote $0A
	sndnote $00
	sndlen 7
	sndnote $0C
	sndnote $00
	sndlen 14
	sndnote $0A
	sndlen 7
	sndnote $0C
	sndnote $00
	sndnote $0A
	sndlen 21
	sndnote $07
	sndlen 14
	sndnote $0A
	sndlen 7
	sndnote $0C
	sndnote $00
	sndnote $0C
	sndnotebase $F4
	sndlenpre $0E
	sndnote $05
	sndlen 56
	sndlenpre $0E
	sndnote $05
	sndlen 7
	sndnote $05
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $05
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $08
	sndlen 7
	sndlenpre $38
	sndnote $08
	sndlen 7
	sndnote $08
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $03
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $03
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $08
	sndlen 7
	sndnote $08
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $08
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $0A
	sndlen 7
	sndlenpre $38
	sndnote $11
	sndlen 7
	sndnote $05
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $11
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $0A
	sndlen 14
	sndnote $0A
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $08
	sndlen 7
	sndnote $0A
	sndnote $11
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $13
	sndlen 10
	sndnote $00
	sndlen 4
	sndnote $0C
	sndlen 7
	sndnote $07
	sndnote $07
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $08
	sndlen 7
	sndnote $0A
	sndlen 84
	sndnote $00
	sndlen 7
	sndnote $13
	sndnote $0C
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $13
	sndlen 14
	sndnote $11
	sndlen 14
	sndnote $00
	sndlen 7
	sndnote $11
	sndlen 28
	sndnote $00
	sndlen 7
	sndnotebase $0C
	sndendch
SndData_BGM_In1996_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH3R|SNDOUT_CH3L
	sndwave $03
	sndch3len $1E
	sndnote $00
	sndlen 28
	sndnote $08
	sndlen 7
	sndnote $01
	sndnote $16
	sndch3len $3C
	sndnote $0A
	sndlen 21
	sndch3len $1E
	sndnote $05
	sndlen 7
	sndnote $11
	sndnote $18
	sndnote $11
	sndnote $05
	sndnote $0F
	sndlen 14
	sndnote $0C
	sndlen 7
	sndnote $05
	sndnote $11
	sndnote $0C
	sndnote $04
	sndnote $05
	sndch3len $3C
	sndnote $08
	sndlen 21
	sndch3len $1E
	sndnote $05
	sndlen 7
	sndnote $08
	sndnote $14
	sndnote $0F
	sndnote $08
	sndnote $0C
	sndlen 14
	sndnote $0F
	sndlen 7
	sndnote $08
	sndnote $14
	sndnote $08
	sndlen 14
	sndnote $03
	sndlen 7
	sndch3len $3C
	sndnote $08
	sndlen 21
	sndch3len $1E
	sndnote $05
	sndlen 7
	sndnote $16
	sndnote $05
	sndnote $0A
	sndnote $11
	sndnote $0A
	sndlen 14
	sndnote $16
	sndlen 7
	sndnote $11
	sndlen 14
	sndnote $08
	sndlen 7
	sndnote $0F
	sndnote $05
	sndlen 14
	sndnote $00
	sndlen 7
	sndnote $0F
	sndlen 21
	sndnote $0E
	sndlen 7
	sndnote $0F
	sndlen 14
	sndnote $0E
	sndlen 21
	sndnote $0A
	sndlen 14
	sndnote $0E
	sndlen 7
	sndnote $0F
	sndlen 14
	sndnote $0C
	sndlen 14
	sndnote $05
	sndlen 7
	sndnote $03
	sndnote $05
	sndlen 14
	sndnote $11
	sndlen 7
	sndnote $0C
	sndnote $03
	sndnote $05
	sndnote $0C
	sndnote $03
	sndnote $05
	sndnote $0F
	sndnote $05
	sndnote $08
	sndlen 14
	sndnote $14
	sndlen 7
	sndnote $13
	sndnote $05
	sndnote $08
	sndnote $08
	sndnote $0A
	sndnote $0F
	sndlen 14
	sndnote $14
	sndlen 7
	sndnote $0D
	sndnote $13
	sndnote $08
	sndnote $05
	sndnote $08
	sndnote $0A
	sndlen 14
	sndnote $16
	sndlen 7
	sndnote $14
	sndnote $11
	sndnote $0F
	sndnote $0A
	sndnote $05
	sndnote $0A
	sndlen 14
	sndnote $11
	sndlen 7
	sndnote $0A
	sndnote $16
	sndnote $0A
	sndnote $14
	sndnote $16
	sndnote $1B
	sndnote $05
	sndnote $13
	sndlen 14
	sndnote $0C
	sndlen 7
	sndnote $06
	sndnote $05
	sndnote $07
	sndch3len $00
	sndnote $0F
	sndlen 84
	sndlenpre $07
	sndch3len $1E
	sndnote $13
	sndlen 7
	sndnote $0C
	sndnote $13
	sndlen 14
	sndnote $05
	sndlen 21
	sndnote $05
	sndlen 35
	sndendch
SndData_BGM_In1996_Ch4:
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndcall .call0
	sndcall .call1
	sndendch
.call0:
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 14
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 21
	sndch4 3, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 28
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 28
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 21
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 21
	sndch4 3, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 28
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndch4 3, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 21
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 28
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndch4 3, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 21
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 21
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 7
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 7
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndret
.call1:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndloopcnt $00, 2, .call1
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 21
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 7
	sndch4 1, 0, 0
	sndlen 7
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 7
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 7
	sndch4 2, 0, 6
	sndlen 7
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 7
	sndch4 1, 0, 0
	sndlen 7
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 7
	sndch4 3, 0, 2
	sndlen 7
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 7
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 3
	sndch4 1, 0, 0
	sndlen 4
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 7
	sndch4 2, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 35
	sndret
