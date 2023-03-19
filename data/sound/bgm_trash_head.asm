SndHeader_BGM_TrashHead:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_TrashHead_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_TrashHead_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_TrashHead_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_TrashHead_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_BGM_TrashHead_Ch1:
	sndenv 1, SNDENV_DEC, 1
	sndenach SNDOUT_CH1R|SNDOUT_CH1L
	sndnr11 2, 0
	sndnote $0A
	sndlen 14
.main:
	sndcall .call0
	sndcall .call1
	sndcall .call2
	sndnotebase $0C
	sndcall .call1
	sndnotebase $F4
	sndloop .main
.call0:
	sndenv 1, SNDENV_DEC, 1
	sndnote $0A
	sndlen 28
	sndenv 6, SNDENV_INC, 0
	sndnote $1D
	sndlen 14
	sndnote $20
	sndlen 28
	sndnote $1F
	sndnote $1D
	sndlen 7
	sndnote $1B
	sndnote $1D
	sndlen 84
	sndnote $00
	sndlen 28
	sndnote $1B
	sndlen 84
	sndnote $00
	sndlen 14
	sndnote $19
	sndlen 7
	sndnote $18
	sndnote $19
	sndlen 84
	sndnote $00
	sndlen 42
	sndnote $1D
	sndlen 14
	sndnote $22
	sndnote $25
	sndlen 28
	sndnote $24
	sndnote $22
	sndlen 7
	sndnote $20
	sndnote $1F
	sndlen 112
	sndlenpre $70
	sndlenpre $70
	sndret
.call1:
	sndnote $00
	sndlen 14
	sndnote $19
	sndnote $16
	sndnote $19
	sndnote $18
	sndlen 7
	sndnote $00
	sndnote $11
	sndlen 28
	sndnote $00
	sndlen 14
	sndnote $00
	sndlen 14
	sndnote $19
	sndnote $16
	sndnote $19
	sndnote $18
	sndlen 7
	sndnote $00
	sndnote $11
	sndlen 28
	sndnote $00
	sndlen 14
	sndnote $00
	sndlen 14
	sndnote $19
	sndnote $16
	sndnote $19
	sndnote $18
	sndnote $11
	sndnote $1B
	sndnote $18
	sndnote $19
	sndnote $18
	sndlen 42
	sndnote $16
	sndlen 14
	sndnote $14
	sndlen 28
	sndnote $00
	sndlen 14
	sndloopcnt $00, 2, .call1
	sndret
.call2:
	sndnote $00
	sndlen 14
	sndnote $2A
	sndnote $27
	sndnote $2A
	sndnote $29
	sndlen 7
	sndnote $00
	sndnote $26
	sndlen 28
	sndnote $00
	sndlen 14
	sndnote $00
	sndnote $2A
	sndnote $27
	sndnote $2A
	sndnote $29
	sndlen 7
	sndnote $00
	sndnote $26
	sndlen 28
	sndnote $00
	sndlen 14
	sndnote $00
	sndnote $2A
	sndnote $27
	sndnote $2A
	sndnote $29
	sndnote $22
	sndnote $31
	sndnote $2C
	sndnote $2F
	sndnote $2E
	sndlen 42
	sndnote $2C
	sndlen 14
	sndnote $2B
	sndlen 28
	sndnote $00
	sndlen 14
	sndret
SndData_BGM_TrashHead_Ch2:
	sndenv 7, SNDENV_INC, 0
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 3, 0
	sndnote $0D
	sndlen 7
	sndnote $0D
.main:
	sndcall .call0
	sndcall .call1
	sndenv 3, SNDENV_INC, 0
	sndnr21 2, 0
	sndnote $00
	sndlen 10
	sndcall SndData_BGM_TrashHead_Ch1.call1
	sndcall .call2
	sndcall .call3
	sndloop .main
.call0:
	sndnote $0D
	sndlen 84
	sndlenpre $0E
	sndnote $0D
	sndlen 7
	sndnote $0D
	sndnote $0D
	sndlen 28
	sndnote $0D
	sndlen 4
	sndnote $00
	sndlen 10
	sndnote $22
	sndlen 42
	sndnote $0D
	sndlen 4
	sndnote $00
	sndlen 10
	sndnote $0D
	sndlen 7
	sndnote $0D
	sndnote $0D
	sndlen 28
	sndnote $0D
	sndlen 4
	sndnote $00
	sndlen 10
	sndnote $25
	sndlen 42
	sndnote $0D
	sndlen 4
	sndnote $00
	sndlen 10
	sndnote $0D
	sndlen 7
	sndnote $0D
	sndnote $0D
	sndlen 28
	sndnote $0D
	sndlen 4
	sndnote $00
	sndlen 10
	sndnote $27
	sndlen 42
	sndnote $0D
	sndlen 4
	sndnote $00
	sndlen 10
	sndnote $0D
	sndlen 7
	sndnote $0D
	sndnote $0D
	sndlen 112
	sndret
.call1:
	sndenv 6, SNDENV_DEC, 2
	sndnote $1B
	sndlen 5
	sndnote $1F
	sndlen 4
	sndnote $22
	sndlen 5
	sndnote $25
	sndnote $27
	sndlen 4
	sndnote $28
	sndlen 5
	sndnote $2B
	sndnote $28
	sndlen 4
	sndnote $27
	sndlen 5
	sndnote $25
	sndnote $22
	sndlen 4
	sndnote $1F
	sndlen 5
	sndloopcnt $00, 6, .call1
	sndret
.call2:
	sndnote $00
	sndlen 14
	sndnote $2A
	sndnote $27
	sndnote $2A
	sndnote $29
	sndlen 7
	sndnote $00
	sndnote $26
	sndlen 28
	sndnote $00
	sndlen 14
	sndnote $00
	sndnote $2A
	sndnote $27
	sndnote $2A
	sndnote $29
	sndlen 7
	sndnote $00
	sndnote $26
	sndlen 28
	sndnote $00
	sndlen 14
	sndnote $00
	sndnote $2A
	sndnote $27
	sndnote $2A
	sndnote $29
	sndnote $22
	sndnote $31
	sndnote $2C
	sndnote $2F
	sndnote $2E
	sndlen 42
	sndnote $2C
	sndlen 14
	sndnote $2B
	sndlen 28
	sndnote $00
	sndlen 4
	sndret
.call3:
	sndenv 7, SNDENV_INC, 0
	sndnr21 3, 0
	sndnote $1D
	sndlen 84
	sndlenpre $0E
	sndnote $1D
	sndlen 7
	sndnote $1D
	sndnote $1D
	sndlen 84
	sndlenpre $0E
	sndnote $1D
	sndlen 7
	sndnote $1D
	sndnote $1E
	sndlen 84
	sndlenpre $0E
	sndnote $1E
	sndlen 7
	sndnote $1E
	sndnote $20
	sndlen 84
	sndlenpre $0E
	sndnote $20
	sndlen 7
	sndnote $20
	sndloopcnt $00, 2, .call3
	sndret
SndData_BGM_TrashHead_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH3R|SNDOUT_CH3L
	sndwave $04
	sndch3len $19
	sndnote $16
	sndlen 7
	sndnote $16
.main:
	sndcall .call0
	sndcall .call1
	sndcall .call1
	sndcall .call2
	sndloop .main
.call0:
	sndch3len $00
	sndnote $16
	sndlen 84
	sndlenpre $0E
	sndch3len $19
	sndnote $16
	sndlen 7
	sndnote $16
	sndch3len $00
	sndnote $16
	sndlen 42
	sndnote $26
	sndlen 56
	sndch3len $19
	sndnote $16
	sndlen 7
	sndnote $16
	sndch3len $00
	sndnote $16
	sndlen 42
	sndnote $16
	sndlen 28
	sndnote $19
	sndch3len $19
	sndnote $16
	sndlen 7
	sndnote $16
	sndch3len $00
	sndnote $16
	sndlen 42
	sndnote $16
	sndlen 28
	sndnote $19
	sndch3len $19
	sndnote $14
	sndlen 7
	sndnote $15
	sndch3len $00
	sndnote $16
	sndlen 84
	sndlenpre $0E
	sndch3len $19
	sndnote $16
	sndlen 7
	sndnote $16
	sndch3len $00
	sndnote $27
	sndlen 112
	sndlenpre $70
	sndlenpre $70
	sndret
.call1:
	sndch3len $32
	sndnote $16
	sndlen 28
	sndloopcnt $00, 15, .call1
	sndnote $16
	sndlen 14
	sndnote $11
	sndret
.call2:
	sndnote $14
	sndlen 28
	sndnote $14
	sndnote $14
	sndnote $14
	sndnote $14
	sndnote $14
	sndnote $14
	sndnote $14
	sndlen 14
	sndnote $0F
	sndch3len $19
.call2b:
	sndnote $14
	sndlen 7
	sndloopcnt $00, 32, .call2b
.call2c:
	sndch3len $00
	sndnote $16
	sndlen 84
	sndlenpre $0E
	sndch3len $19
	sndnote $16
	sndlen 7
	sndnote $16
	sndloopcnt $00, 4, .call2c
.call2d:
	sndch3len $19
	sndnote $16
	sndlen 14
	sndnote $16
	sndlen 7
	sndnote $16
	sndch3len $00
	sndnote $16
	sndlen 42
	sndch3len $19
	sndnote $16
	sndlen 7
	sndnote $16
	sndnote $16
	sndlen 14
	sndnote $16
	sndlen 7
	sndnote $16
	sndloopcnt $00, 4, .call2d
	sndret
SndData_BGM_TrashHead_Ch4:
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 7
	sndch4 3, 0, 2
	sndlen 7
.main:
	sndcall .call0
	sndcall .call1
	sndcall .call0
	sndcall .call2
	sndcall .call0
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 28
	sndch4 3, 0, 6
	sndlen 28
	sndch4 3, 0, 6
	sndlen 28
	sndch4 3, 0, 6
	sndlen 28
	sndcall .call3
	sndcall .call4
	sndcall .call3
	sndcall .call5
	sndloop .main
.call0:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 28
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 14
	sndret
.call1:
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 42
	sndch4 3, 0, 6
	sndlen 7
	sndch4 3, 0, 6
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
	sndret
.call2:
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 28
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
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
	sndret
.call3:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 2, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 2, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 7
	sndenv 4, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 4, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
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
	sndlen 7
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndch4 3, 0, 6
	sndlen 7
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 7
	sndch4 3, 0, 2
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 7
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 5
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 4
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 5
	sndret
.call4:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 7
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 14
	sndloopcnt $00, 20, .call4
	sndret
.call5:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 7
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 28
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 7
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 14
	sndloopcnt $00, 8, .call5
	sndret
