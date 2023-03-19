SndHeader_BGM_Protector:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_Protector_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_Protector_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_Protector_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_Protector_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_BGM_Protector_Ch1:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH1R|SNDOUT_CH1L
	sndnr11 2, 0
	sndcall .call0
	sndcall .call1
	sndloop SndData_BGM_Protector_Ch1
.call0:
	sndenv 8, SNDENV_DEC, 4
	sndnote $1E
	sndlen 10
	sndnote $20
	sndnote $24
	sndnote $29
	sndnote $1E
	sndnote $20
	sndnote $24
	sndnote $29
	sndenv 4, SNDENV_DEC, 4
	sndnote $1E
	sndnote $20
	sndnote $24
	sndnote $29
	sndnote $1E
	sndnote $20
	sndnote $24
	sndnote $29
	sndenv 8, SNDENV_DEC, 4
	sndnote $1F
	sndnote $20
	sndnote $24
	sndnote $29
	sndnote $1F
	sndnote $20
	sndnote $24
	sndnote $29
	sndenv 4, SNDENV_DEC, 4
	sndnote $1F
	sndnote $20
	sndnote $24
	sndnote $29
	sndnote $1F
	sndnote $20
	sndnote $24
	sndnote $29
	sndloopcnt $00, 4, .call0
	sndret
.call1:
	sndenv 8, SNDENV_DEC, 4
	sndnote $2A
	sndlen 10
	sndnote $2E
	sndnote $35
	sndnote $2A
	sndnote $2E
	sndnote $35
	sndenv 4, SNDENV_DEC, 4
	sndnote $2A
	sndnote $2E
	sndnote $35
	sndnote $2A
	sndnote $2E
	sndnote $35
	sndenv 2, SNDENV_DEC, 7
	sndnote $2A
	sndnote $2E
	sndnote $35
	sndlen 20
	sndenv 8, SNDENV_DEC, 4
	sndnote $29
	sndlen 10
	sndnote $2D
	sndnote $35
	sndnote $29
	sndnote $2D
	sndnote $35
	sndenv 4, SNDENV_DEC, 4
	sndnote $29
	sndnote $2D
	sndnote $35
	sndnote $29
	sndnote $2D
	sndnote $35
	sndenv 2, SNDENV_DEC, 7
	sndnote $29
	sndnote $2D
	sndnote $35
	sndlen 20
	sndloopcnt $00, 3, .call1
	sndenv 8, SNDENV_DEC, 4
	sndnote $2A
	sndlen 10
	sndnote $2E
	sndnote $35
	sndnote $2A
	sndnote $2E
	sndnote $35
	sndenv 4, SNDENV_DEC, 4
	sndnote $2A
	sndnote $2E
	sndnote $35
	sndnote $2A
	sndnote $2E
	sndnote $35
	sndenv 2, SNDENV_DEC, 7
	sndnote $2A
	sndnote $2E
	sndnote $35
	sndlen 20
	sndenv 8, SNDENV_DEC, 4
	sndnote $2C
	sndlen 10
	sndnote $30
	sndnote $38
	sndnote $2C
	sndnote $30
	sndnote $38
	sndenv 4, SNDENV_DEC, 4
	sndnote $2D
	sndnote $30
	sndnote $39
	sndnote $2D
	sndnote $30
	sndnote $39
	sndenv 2, SNDENV_DEC, 7
	sndnote $2D
	sndnote $30
	sndnote $39
	sndlen 20
	sndret
SndData_BGM_Protector_Ch2:
	sndenv 3, SNDENV_DEC, 4
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 2, 0
	sndnote $00
	sndlen 15
.main:
	sndcall .call0
	sndcall .call1
	sndloop .main
.call0:
	sndenv 4, SNDENV_DEC, 7
	sndnote $1E
	sndlen 10
	sndnote $20
	sndnote $24
	sndnote $29
	sndnote $1E
	sndnote $20
	sndnote $24
	sndnote $29
	sndenv 2, SNDENV_DEC, 7
	sndnote $1E
	sndnote $20
	sndnote $24
	sndnote $29
	sndnote $1E
	sndnote $20
	sndnote $24
	sndnote $29
	sndenv 4, SNDENV_DEC, 7
	sndnote $1F
	sndnote $20
	sndnote $24
	sndnote $29
	sndnote $1F
	sndnote $20
	sndnote $24
	sndnote $29
	sndenv 2, SNDENV_DEC, 7
	sndnote $1F
	sndnote $20
	sndnote $24
	sndnote $29
	sndnote $1F
	sndnote $20
	sndnote $24
	sndnote $29
	sndloopcnt $00, 4, .call0
	sndret
.call1:
	sndenv 4, SNDENV_DEC, 7
	sndnote $2A
	sndlen 10
	sndnote $2E
	sndnote $35
	sndnote $2A
	sndnote $2E
	sndnote $35
	sndenv 2, SNDENV_DEC, 7
	sndnote $2A
	sndnote $2E
	sndnote $35
	sndnote $2A
	sndnote $2E
	sndnote $35
	sndenv 1, SNDENV_DEC, 7
	sndnote $2A
	sndnote $2E
	sndnote $35
	sndlen 20
	sndenv 4, SNDENV_DEC, 7
	sndnote $29
	sndlen 10
	sndnote $2D
	sndnote $35
	sndnote $29
	sndnote $2D
	sndnote $35
	sndenv 2, SNDENV_DEC, 7
	sndnote $29
	sndnote $2D
	sndnote $35
	sndnote $29
	sndnote $2D
	sndnote $35
	sndenv 1, SNDENV_DEC, 7
	sndnote $29
	sndnote $2D
	sndnote $35
	sndlen 20
	sndloopcnt $00, 3, .call1
	sndenv 4, SNDENV_DEC, 7
	sndnote $2A
	sndlen 10
	sndnote $2E
	sndnote $35
	sndnote $2A
	sndnote $2E
	sndnote $35
	sndenv 2, SNDENV_DEC, 7
	sndnote $2A
	sndnote $2E
	sndnote $35
	sndnote $2A
	sndnote $2E
	sndnote $35
	sndenv 1, SNDENV_DEC, 7
	sndnote $2A
	sndnote $2E
	sndnote $35
	sndlen 20
	sndenv 4, SNDENV_DEC, 7
	sndnote $2C
	sndlen 10
	sndnote $30
	sndnote $38
	sndnote $2C
	sndnote $30
	sndnote $38
	sndenv 2, SNDENV_DEC, 7
	sndnote $2D
	sndnote $30
	sndnote $39
	sndnote $2D
	sndnote $30
	sndnote $39
	sndenv 1, SNDENV_DEC, 7
	sndnote $2D
	sndnote $30
	sndnote $39
	sndlen 20
	sndret
SndData_BGM_Protector_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH3R|SNDOUT_CH3L
	sndwave $02
	sndch3len $00
	sndcall .call0
	sndcall .call1
	sndloop SndData_BGM_Protector_Ch3
.call0:
	sndnote $12
	sndlen 80
	sndlenpre $50
	sndch3len $14
	sndnote $11
	sndlen 10
	sndch3len $00
	sndnote $11
	sndlen 120
	sndlenpre $1E
	sndloopcnt $00, 4, .call0
	sndret
.call1:
	sndch3len $1E
	sndnote $12
	sndlen 30
	sndch3len $00
	sndnote $12
	sndlen 120
	sndlenpre $0A
	sndch3len $1E
	sndnote $11
	sndlen 30
	sndch3len $00
	sndnote $11
	sndlen 120
	sndlenpre $0A
	sndloopcnt $00, 3, .call1
	sndch3len $1E
	sndnote $12
	sndlen 30
	sndch3len $00
	sndnote $12
	sndlen 120
	sndlenpre $0A
	sndch3len $1E
	sndnote $14
	sndlen 30
	sndch3len $00
	sndnote $14
	sndlen 40
	sndlenpre $0A
	sndnote $15
	sndlen 80
	sndret
SndData_BGM_Protector_Ch4:
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndcall .call0
	sndcall .call1
	sndcall .call2
	sndloop SndData_BGM_Protector_Ch4
.call0:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 80
	sndlenpre $50
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 120
	sndlenpre $1E
	sndch4 3, 0, 6
	sndlen 80
	sndlenpre $50
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 80
	sndlenpre $1E
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 30
	sndret
.call1:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 20
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 20
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 40
	sndch4 2, 0, 1
	sndlen 20
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 20
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 20
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 10
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 20
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 20
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 40
	sndch4 2, 0, 1
	sndlen 20
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 30
	sndloopcnt $00, 2, .call1
	sndret
.call2:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 30
	sndch4 3, 0, 6
	sndlen 120
	sndlenpre $0A
	sndloopcnt $00, 4, .call2
.call2b:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 10
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 20
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 20
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 20
	sndloopcnt $00, 4, .call2b
	sndret
