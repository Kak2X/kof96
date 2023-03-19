SndHeader_BGM_ToTheSky:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_ToTheSky_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_ToTheSky_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_ToTheSky_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_ToTheSky_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_BGM_ToTheSky_Ch1:
	sndenv 7, SNDENV_INC, 0
	sndenach SNDOUT_CH1R|SNDOUT_CH1L
	sndnr11 3, 0
	sndnote $27
	sndlen 96
	sndlenpre $08
	sndnote $00
	sndnote $27
	sndnote $27
	sndnote $26
	sndlen 32
	sndenv 1, SNDENV_DEC, 1
	sndnote $02
	sndlen 96
	sndenv 7, SNDENV_INC, 0
	sndnote $27
	sndlen 96
	sndlenpre $08
	sndnote $00
	sndnote $27
	sndnote $27
	sndnote $29
	sndlen 32
	sndenv 1, SNDENV_DEC, 1
	sndnote $02
	sndlen 96
	sndenv 7, SNDENV_INC, 0
	sndnote $27
	sndlen 32
	sndnote $26
	sndlen 16
	sndnote $00
	sndnote $29
	sndlen 32
	sndnote $2A
	sndlen 16
	sndnote $00
	sndnote $2B
	sndlen 32
	sndnote $2C
	sndlen 16
	sndnote $00
	sndnote $2D
	sndlen 64
	sndnote $2E
	sndlen 64
	sndlenpre $40
	sndenv 1, SNDENV_DEC, 1
	sndnote $05
	sndlen 48
	sndenv 6, SNDENV_DEC, 7
	sndnote $11
	sndlen 8
	sndnote $11
	sndnote $11
	sndnote $00
	sndnote $11
	sndnote $11
	sndnote $11
	sndnote $00
	sndnote $11
	sndnote $11
	sndloop SndData_BGM_ToTheSky_Ch1
SndData_BGM_ToTheSky_Ch2:
	sndenv 5, SNDENV_INC, 0
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 2, 0
	sndnote $16
	sndlen 32
	sndnote $14
	sndnote $12
	sndnote $16
	sndnote $20
	sndnote $1A
	sndnote $1D
	sndnote $16
	sndnote $16
	sndnote $14
	sndnote $12
	sndnote $16
	sndnote $20
	sndnote $1A
	sndnote $1D
	sndnote $20
	sndnote $1E
	sndnote $1A
	sndlen 16
	sndnote $00
	sndnote $20
	sndlen 32
	sndnote $1B
	sndlen 16
	sndnote $00
	sndnote $22
	sndlen 32
	sndnote $1D
	sndlen 16
	sndnote $00
	sndnote $24
	sndlen 64
	sndnote $29
	sndlen 8
	sndnote $2A
	sndnote $29
	sndnote $26
	sndnote $29
	sndnote $23
	sndnote $26
	sndnote $20
	sndnote $23
	sndnote $1D
	sndnote $20
	sndnote $1B
	sndnote $1A
	sndnote $1D
	sndnote $20
	sndnote $1A
	sndnote $16
	sndnote $22
	sndnote $20
	sndnote $1B
	sndnote $1E
	sndnote $1A
	sndnote $1B
	sndnote $17
	sndnote $1A
	sndnote $16
	sndnote $14
	sndnote $16
	sndnote $12
	sndnote $16
	sndnote $11
	sndnote $12
	sndloop SndData_BGM_ToTheSky_Ch2
SndData_BGM_ToTheSky_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH3R|SNDOUT_CH3L
	sndwave $02
	sndch3len $19
	sndcall .call0
	sndcall .call1
	sndcall .call0
	sndcall .call2
	sndloop SndData_BGM_ToTheSky_Ch3
.call0:
	sndnote $1B
	sndlen 8
	sndnote $16
	sndnote $1B
	sndnote $1D
	sndnote $1E
	sndnote $16
	sndnote $1E
	sndnote $1B
	sndnote $22
	sndnote $1B
	sndnote $20
	sndnote $1B
	sndnote $1E
	sndnote $1B
	sndnote $1A
	sndnote $1B
	sndnote $1D
	sndnote $16
	sndnote $1A
	sndnote $16
	sndnote $20
	sndnote $16
	sndnote $1D
	sndnote $1E
	sndret
.call1:
	sndnote $26
	sndlen 8
	sndnote $1D
	sndnote $23
	sndnote $1D
	sndnote $22
	sndnote $1D
	sndnote $1A
	sndnote $16
	sndret
.call2:
	sndnote $26
	sndlen 8
	sndnote $27
	sndnote $23
	sndnote $26
	sndnote $22
	sndnote $23
	sndnote $20
	sndnote $1A
	sndnote $22
	sndnote $1E
	sndnote $1A
	sndnote $16
	sndnote $20
	sndnote $1D
	sndnote $1A
	sndnote $14
	sndnote $23
	sndnote $1D
	sndnote $1A
	sndnote $17
	sndnote $22
	sndnote $1E
	sndnote $1B
	sndnote $16
	sndnote $25
	sndnote $22
	sndnote $1F
	sndnote $19
	sndnote $24
	sndnote $20
	sndnote $1D
	sndnote $18
	sndnote $27
	sndnote $24
	sndnote $21
	sndnote $1B
	sndnote $24
	sndnote $21
	sndnote $1B
	sndnote $18
	sndnote $16
	sndnote $22
	sndnote $20
	sndnote $1B
	sndnote $1D
	sndnote $1A
	sndnote $1B
	sndnote $17
	sndnote $1A
	sndnote $16
	sndnote $14
	sndnote $16
	sndnote $12
	sndnote $16
	sndnote $11
	sndnote $12
	sndnote $16
	sndlen 64
	sndlenpre $40
	sndret
SndData_BGM_ToTheSky_Ch4:
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndcall .call0
	sndloop SndData_BGM_ToTheSky_Ch4
.call0:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 96
	sndlenpre $10
	sndch4 3, 0, 6
	sndlen 8
	sndch4 3, 0, 6
	sndlen 8
	sndenv 5, SNDENV_DEC, 4
	sndch4 3, 0, 2
	sndlen 48
	sndch4 3, 0, 2
	sndlen 8
	sndch4 3, 0, 2
	sndlen 8
	sndch4 3, 0, 2
	sndlen 16
	sndch4 3, 0, 2
	sndlen 8
	sndch4 3, 0, 2
	sndlen 8
	sndch4 3, 0, 2
	sndlen 16
	sndch4 3, 0, 2
	sndlen 8
	sndch4 3, 0, 2
	sndlen 8
	sndloopcnt $00, 2, .call0
.call0b:
	sndenv 4, SNDENV_DEC, 4
	sndch4 3, 0, 2
	sndlen 48
	sndch4 1, 0, 0
	sndlen 8
	sndch4 1, 0, 0
	sndlen 8
	sndloopcnt $00, 4, .call0b
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 96
	sndlenpre $10
	sndch4 3, 0, 6
	sndlen 8
	sndch4 3, 0, 6
	sndlen 8
	sndch4 3, 0, 6
	sndlen 48
	sndch4 3, 0, 6
	sndlen 8
	sndch4 3, 0, 6
	sndlen 8
	sndenv 5, SNDENV_DEC, 4
	sndch4 3, 0, 2
	sndlen 16
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 16
	sndenv 5, SNDENV_DEC, 4
	sndch4 3, 0, 2
	sndlen 16
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 16
	sndret
