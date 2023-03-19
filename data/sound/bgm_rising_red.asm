SndHeader_BGM_RisingRed:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_RisingRed_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_RisingRed_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_RisingRed_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_RisingRed_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_BGM_RisingRed_Ch1:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH1R|SNDOUT_CH1L
	sndnr11 2, 0
.main:
	sndcall .call0
	sndloop .main
.call0:
	sndnote $2A
	sndlen 60
	sndnote $29
	sndlen 80
	sndlenpre $14
	sndlenpre $78
	sndlenpre $14
	sndnote $27
	sndlen 10
	sndnote $29
	sndnote $2A
	sndlen 120
	sndlenpre $14
	sndnote $29
	sndlen 10
	sndnote $27
	sndnote $29
	sndlen 20
	sndnote $25
	sndlen 120
	sndnote $27
	sndlen 10
	sndnote $29
	sndnote $2A
	sndlen 120
	sndlenpre $14
	sndnote $2E
	sndlen 10
	sndnote $30
	sndnote $2C
	sndlen 80
	sndlenpre $50
	sndlenpre $78
	sndnote $29
	sndlen 13
	sndnote $2A
	sndlen 14
	sndnote $2E
	sndlen 13
	sndnote $2C
	sndlen 80
	sndlenpre $50
	sndlenpre $50
	sndlenpre $50
	sndnote $2C
	sndlen 80
	sndlenpre $14
	sndnote $28
	sndnote $2A
	sndnote $2C
	sndnote $2C
	sndlen 80
	sndnote $2C
	sndlen 30
	sndnote $2D
	sndnote $2F
	sndlen 20
	sndnote $2A
	sndlen 120
	sndlenpre $14
	sndnote $27
	sndlen 10
	sndnote $28
	sndnote $27
	sndlen 80
	sndlenpre $50
	sndnote $2C
	sndlen 80
	sndlenpre $14
	sndnote $28
	sndnote $2A
	sndnote $2C
	sndnote $2C
	sndlen 80
	sndnote $2F
	sndlen 30
	sndnote $2D
	sndnote $2C
	sndlen 20
	sndnote $2A
	sndlen 80
	sndlenpre $50
	sndnote $2F
	sndlen 120
	sndlenpre $14
	sndnote $2E
	sndlen 10
	sndnote $2F
	sndnote $2E
	sndlen 120
	sndlenpre $14
	sndnote $2E
	sndlen 10
	sndnote $2F
	sndnote $31
	sndlen 80
	sndlenpre $14
	sndnote $31
	sndnote $2F
	sndnote $2E
	sndnote $2F
	sndlen 120
	sndlenpre $14
	sndnote $2C
	sndlen 10
	sndnote $2F
	sndnote $34
	sndlen 120
	sndlenpre $14
	sndnote $34
	sndnote $33
	sndnote $2F
	sndlen 120
	sndnote $31
	sndlen 10
	sndnote $33
	sndnote $31
	sndlen 20
	sndnote $2E
	sndlen 120
	sndnote $2F
	sndlen 10
	sndnote $2E
	sndnote $2F
	sndlen 120
	sndlenpre $14
	sndnote $2C
	sndlen 10
	sndnote $2F
	sndnote $34
	sndlen 80
	sndlenpre $14
	sndnote $34
	sndnote $33
	sndnote $31
	sndnote $2F
	sndlen 80
	sndlenpre $50
	sndlenpre $50
	sndlenpre $50
	sndret
SndData_BGM_RisingRed_Ch2:
	sndenv 1, SNDENV_DEC, 1
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 2, 0
	sndnote $01
	sndlen 10
	sndlenpre $05
	sndenv 3, SNDENV_DEC, 7
.main:
	sndcall SndData_BGM_RisingRed_Ch1.call0
	sndloop .main
SndData_BGM_RisingRed_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH3R|SNDOUT_CH3L
	sndwave $01
	sndch3len $00
	sndcall .call0
	sndcall .call1
	sndcall .call0
	sndnote $19
	sndlen 20
	sndnote $20
	sndnote $25
	sndnote $29
	sndnote $25
	sndnote $29
	sndnote $25
	sndnote $29
	sndcall .call2
	sndcall .call3
	sndcall .call2
	sndcall .call3
	sndnote $19
	sndlen 20
	sndnote $1E
	sndnote $22
	sndnote $25
	sndnote $22
	sndnote $25
	sndnote $22
	sndnote $25
	sndnote $19
	sndlen 20
	sndnote $1E
	sndnote $22
	sndnote $25
	sndnote $22
	sndnote $25
	sndnote $22
	sndnote $25
	sndcall .call2
	sndcall .call4
	sndcall .call2
	sndcall .call3
	sndloop SndData_BGM_RisingRed_Ch3
.call0:
	sndnote $19
	sndlen 20
	sndnote $20
	sndnote $25
	sndnote $29
	sndnote $25
	sndnote $29
	sndnote $25
	sndnote $29
	sndloopcnt $00, 2, .call0
	sndret
.call1:
	sndnote $19
	sndlen 20
	sndnote $1E
	sndnote $22
	sndnote $25
	sndnote $22
	sndnote $25
	sndnote $22
	sndnote $25
	sndnote $19
	sndlen 20
	sndnote $20
	sndnote $25
	sndnote $29
	sndnote $25
	sndnote $29
	sndnote $25
	sndnote $29
	sndloopcnt $00, 2, .call1
	sndret
	;--
	; [TCRF] Unreferenced song section
	sndnote $18 ;X
	sndlen 20 ;X
	sndnote $20 ;X
	sndnote $24 ;X
	sndnote $27 ;X
	sndnote $24 ;X
	sndnote $27 ;X
	sndnote $24 ;X
	sndnote $27 ;X
	sndret ;X
	;--
.call2:
	sndnote $1C
	sndlen 20
	sndnote $20
	sndnote $23
	sndnote $28
	sndnote $23
	sndnote $28
	sndnote $23
	sndnote $28
	sndloopcnt $00, 2, .call2
	sndret
.call3:
	sndnote $1B
	sndlen 20
	sndnote $1E
	sndnote $23
	sndnote $27
	sndnote $23
	sndnote $27
	sndnote $23
	sndnote $27
	sndloopcnt $00, 2, .call3
	sndret
.call4:
	sndnote $1B
	sndlen 20
	sndnote $1E
	sndnote $23
	sndnote $27
	sndnote $23
	sndnote $27
	sndnote $23
	sndnote $27
	sndnote $19
	sndnote $1E
	sndnote $22
	sndnote $25
	sndnote $22
	sndnote $25
	sndnote $22
	sndnote $25
	sndret
SndData_BGM_RisingRed_Ch4:
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndcall .call0
.main:
	sndcall .call1
	sndloop .main
.call0:
	sndenv 5, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 10
	sndenv 4, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 10
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 10
	sndenv 2, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 80
	sndlenpre $0A
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 40
	sndloopcnt $00, 9, .call0
	sndret
.call1:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 5, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 10
	sndenv 4, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 4, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 30
	sndenv 4, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 2, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 30
	sndenv 2, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 40
	sndret
