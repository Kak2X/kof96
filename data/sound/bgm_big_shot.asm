SndHeader_BGM_BigShot:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_BigShot_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_BigShot_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_BigShot_Ch3 ; Data ptr
	db $0C ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_BigShot_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_BGM_BigShot_Ch1:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH1R|SNDOUT_CH1L
	sndnr11 2, 0
.main:
	sndenv 7, SNDENV_DEC, 7
	sndnr11 2, 0
	sndcall .call0
	sndcall .call1
	sndcall .call2
	sndloop .main
.call0:
	sndnote $20
	sndlen 16
	sndnote $25
	sndlen 8
	sndlenpre $48
	sndnote $20
	sndlen 16
	sndnote $23
	sndlen 8
	sndlenpre $48
	sndnote $20
	sndlen 16
	sndnote $1E
	sndlen 8
	sndlenpre $48
	sndnote $25
	sndlen 16
	sndnote $27
	sndlen 48
	sndnote $25
	sndlen 8
	sndenv 1, SNDENV_DEC, 1
	sndnote $01
	sndlen 24
	sndenv 7, SNDENV_DEC, 7
	sndnote $2A
	sndlen 16
	sndnote $29
	sndlen 8
	sndlenpre $28
	sndret
.call1:
	sndnote $2C
	sndlen 8
	sndenv 1, SNDENV_DEC, 1
	sndnote $08
	sndlen 96
	sndlenpre $10
	sndenv 7, SNDENV_DEC, 7
	sndnote $1B
	sndlen 8
	sndnote $27
	sndlen 16
	sndnote $25
	sndlen 8
	sndlenpre $48
	sndnote $2A
	sndlen 16
	sndnote $2F
	sndlen 8
	sndret
.call2:
	sndenv 1, SNDENV_DEC, 1
	sndnr11 3, 0
	sndnote $06
	sndlen 48
	sndenv 7, SNDENV_INC, 0
	sndnote $1E
	sndlen 16
	sndnote $20
	sndnote $1E
	sndnote $1D
	sndlen 96
	sndlenpre $30
	sndenv 1, SNDENV_DEC, 1
	sndnote $05
	sndlen 40
	sndenv 7, SNDENV_INC, 0
	sndnote $1D
	sndlen 8
	sndnote $1E
	sndlen 48
	sndnote $1B
	sndlen 40
	sndnote $22
	sndlen 8
	sndlenpre $48
	sndenv 1, SNDENV_DEC, 1
	sndnote $0A
	sndlen 24
	sndenv 7, SNDENV_INC, 0
	sndnote $23
	sndlen 32
	sndnote $00
	sndlen 8
	sndnote $22
	sndlen 40
	sndnote $00
	sndlen 8
	sndnote $1E
	sndlenpre $30
	sndenv 1, SNDENV_DEC, 1
	sndnote $06
	sndlen 24
	sndenv 7, SNDENV_INC, 0
	sndnote $22
	sndlen 16
	sndnote $20
	sndlen 8
	sndlenpre $60
	sndenv 1, SNDENV_DEC, 1
	sndnr11 2, 0
	sndnote $08
	sndlen 16
	sndenv 7, SNDENV_DEC, 7
	sndnote $29
	sndlen 8
	sndnote $2A
	sndnote $29
	sndnote $27
	sndnote $25
	sndlen 40
	sndnote $27
	sndlen 8
	sndenv 1, SNDENV_DEC, 1
	sndnote $03
	sndlen 48
	sndenv 7, SNDENV_DEC, 7
	sndnote $2E
	sndlen 16
	sndenv 1, SNDENV_DEC, 1
	sndnote $0A
	sndlen 24
	sndenv 7, SNDENV_INC, 0
	sndnr11 3, 0
	sndnote $19
	sndlen 8
	sndnote $1B
	sndlen 32
	sndenv 1, SNDENV_DEC, 1
	sndnote $03
	sndlen 16
	sndenv 7, SNDENV_INC, 0
	sndnote $22
	sndnote $20
	sndlen 8
	sndnote $1E
	sndlen 16
	sndnote $1D
	sndlen 8
	sndlenpre $30
	sndlenpre $08
	sndenv 1, SNDENV_DEC, 1
	sndnote $05
	sndlen 16
	sndenv 7, SNDENV_DEC, 7
	sndnr11 2, 0
	sndnote $2A
	sndlen 16
	sndnote $29
	sndlen 24
	sndenv 7, SNDENV_INC, 0
	sndnr11 3, 0
	sndnote $1E
	sndlen 8
	sndnote $1D
	sndlen 16
	sndnote $1B
	sndlen 8
	sndnote $1D
	sndlen 24
	sndnote $19
	sndnote $17
	sndlen 48
	sndnote $1E
	sndenv 1, SNDENV_DEC, 1
	sndnr11 2, 0
	sndnote $0B
	sndlen 24
	sndenv 7, SNDENV_DEC, 3
	sndnote $23
	sndlen 8
	sndnote $22
	sndnote $20
	sndnote $25
	sndlen 16
	sndnote $20
	sndnote $22
	sndenv 7, SNDENV_DEC, 5
	sndnote $1B
	sndlenpre $48
	sndnote $1D
	sndlen 24
	sndlenpre $48
	sndlenpre $08
	sndnote $1C
	sndlen 16
	sndlenpre $48
	sndnote $1E
	sndlen 24
	sndlenpre $30
	sndlenpre $08
	sndret
SndData_BGM_BigShot_Ch2:
	sndenv 1, SNDENV_DEC, 1
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 2, 0
	sndenv 1, SNDENV_DEC, 1
	sndnote $01
	sndlen 24
.main:
	sndcall .call0
	sndcall .call1
	sndcall .call0
	sndcall .call2
	sndcall .call3
	sndcall .call4
	sndcall .call5
	sndcall .call6
	sndcall .call6
	sndcall .call7
	sndcall .call6
	sndcall .call8
	sndloop .main
.call0:
	sndenv 5, SNDENV_DEC, 4
	sndnote $1D
	sndlen 16
	sndnote $19
	sndlen 8
	sndnote $20
	sndlen 16
	sndnote $1B
	sndlen 8
	sndnote $23
	sndlen 16
	sndnote $19
	sndlen 8
	sndnote $20
	sndlen 16
	sndnote $1B
	sndlen 24
	sndnote $17
	sndlen 8
	sndnote $20
	sndlen 16
	sndnote $1D
	sndlen 8
	sndnote $23
	sndlen 16
	sndnote $1B
	sndlen 8
	sndnote $17
	sndnote $19
	sndnote $16
	sndlen 24
	sndnote $12
	sndlen 8
	sndnote $19
	sndlen 16
	sndnote $16
	sndlen 8
	sndnote $1C
	sndlen 16
	sndnote $16
	sndlen 8
	sndnote $12
	sndlen 16
	sndnote $21
	sndlen 24
	sndret
.call1:
	sndnote $17
	sndlen 8
	sndnote $21
	sndlen 16
	sndnote $1B
	sndlen 8
	sndnote $20
	sndlen 16
	sndnote $1B
	sndlen 8
	sndnote $17
	sndlen 24
	sndret
.call2:
	sndlenpre $48
	sndlenpre $08
	sndret
.call3:
	sndenv 4, SNDENV_DEC, 2
	sndnote $2C
	sndlen 8
	sndnote $25
	sndnote $29
	sndnote $25
	sndnote $33
	sndnote $25
	sndnote $29
	sndnote $25
	sndnote $2C
	sndnote $25
	sndnote $33
	sndnote $29
	sndloopcnt $00, 2, .call3
	sndret
.call4:
	sndnote $2A
	sndlen 8
	sndnote $25
	sndnote $2E
	sndnote $25
	sndnote $31
	sndnote $25
	sndnote $2A
	sndnote $25
	sndnote $2E
	sndnote $25
	sndnote $31
	sndnote $25
	sndloopcnt $00, 2, .call4
	sndret
.call5:
	sndenv 5, SNDENV_DEC, 7
	sndnote $1B
	sndlen 40
	sndnote $1D
	sndlen 48
	sndnote $22
	sndlen 24
	sndnote $20
	sndlen 8
	sndnote $1B
	sndlen 16
	sndnote $25
	sndlen 32
	sndnote $24
	sndlen 16
	sndnote $23
	sndlen 8
	sndlenpre $60
	sndlenpre $60
	sndret
.call6:
	sndenv 4, SNDENV_DEC, 2
	sndnote $20
	sndlen 8
	sndnote $1B
	sndlen 4
	sndnote $19
	sndnote $20
	sndlen 8
	sndnote $2A
	sndlen 16
	sndnote $1B
	sndlen 8
	sndloopcnt $00, 2, .call6
	sndret
.call7:
	sndnote $20
	sndlen 8
	sndnote $1D
	sndlen 4
	sndnote $1B
	sndnote $20
	sndlen 8
	sndnote $2A
	sndlen 16
	sndnote $1B
	sndlen 8
	sndloopcnt $00, 4, .call7
	sndret
.call8:
	sndenv 1, SNDENV_DEC, 1
	sndnote $06
	sndlen 24
	sndenv 5, SNDENV_DEC, 3
	sndnote $1E
	sndlen 8
	sndnote $1D
	sndnote $1B
	sndnote $20
	sndlen 16
	sndnote $1B
	sndnote $1D
	sndenv 5, SNDENV_DEC, 5
	sndnote $17
	sndlen 16
	sndlenpre $48
	sndnote $19
	sndlen 24
	sndlenpre $48
	sndlenpre $08
	sndnote $19
	sndlen 16
	sndlenpre $48
	sndnote $1B
	sndlen 24
	sndlenpre $48
	sndlenpre $08
	sndret
SndData_BGM_BigShot_Ch3:
	sndenvch3 0
	sndenach SNDOUT_CH3R|SNDOUT_CH3L
	sndwave $02
	sndch3len $3C
	sndnote $01
	sndlen 24
.main:
	sndenvch3 2
	sndcall .call0
	sndcall .call1
	sndcall .call0
	sndcall .call2
	sndcall .call3
	sndloop .main
.call0:
	sndnote $0D
	sndlen 16
	sndnote $0C
	sndlen 8
	sndnote $0D
	sndlen 24
	sndnote $05
	sndlen 16
	sndnote $08
	sndlen 8
	sndnote $0D
	sndlen 16
	sndnote $0B
	sndlen 24
	sndnote $0A
	sndlen 8
	sndnote $0B
	sndlen 24
	sndnote $0B
	sndlen 16
	sndnote $03
	sndlen 8
	sndnote $05
	sndlen 16
	sndnote $06
	sndlen 24
	sndnote $05
	sndlen 8
	sndnote $06
	sndlen 24
	sndnote $06
	sndlen 16
	sndnote $05
	sndlen 8
	sndnote $0A
	sndlen 16
	sndnote $0B
	sndlen 24
	sndret
.call1:
	sndnote $0A
	sndlen 8
	sndnote $0B
	sndlen 16
	sndnote $06
	sndlen 8
	sndnote $0B
	sndlen 16
	sndnote $0A
	sndlen 8
	sndnote $0B
	sndlen 24
	sndret
.call2:
	sndlenpre $48
	sndlenpre $08
	sndret
.call3:
	sndnote $0A
	sndlen 24
	sndnote $0A
	sndnote $0A
	sndlen 16
	sndnote $05
	sndlen 8
	sndnote $0A
	sndlen 24
	sndloopcnt $00, 2, .call3
	sndnote $0B
	sndlen 24
	sndnote $0B
	sndnote $0B
	sndlen 16
	sndnote $06
	sndlen 8
	sndnote $0B
	sndlen 24
	sndnote $0B
	sndlen 24
	sndnote $0B
	sndnote $0B
	sndlen 16
	sndnote $06
	sndlen 8
	sndnote $0B
	sndlen 16
	sndnote $0B
	sndlen 8
	sndnote $08
	sndlen 16
	sndnote $07
	sndlen 8
	sndnote $08
	sndlen 16
	sndnote $0A
	sndlen 24
	sndnote $08
	sndlen 8
	sndnote $0A
	sndlen 16
	sndnote $0B
	sndlen 24
	sndnote $0A
	sndlen 8
	sndnote $0B
	sndlen 24
	sndnote $0C
	sndlen 16
	sndnote $06
	sndlen 8
	sndnote $0C
	sndlen 16
	sndnote $0D
	sndlen 24
	sndnote $0C
	sndlen 8
	sndnote $0D
	sndlen 24
	sndnote $0D
	sndlen 16
	sndnote $08
	sndlen 8
	sndnote $0A
	sndlen 16
	sndnote $0D
	sndlen 24
	sndnote $0C
	sndlen 8
	sndnote $0D
	sndlen 16
	sndnote $08
	sndlen 8
	sndnote $0D
	sndnote $08
	sndnote $0D
	sndnote $0C
	sndlen 16
	sndnote $0B
	sndlen 32
	sndnote $0B
	sndlen 24
	sndnote $0B
	sndlen 16
	sndnote $06
	sndlen 8
	sndnote $0B
	sndlen 24
	sndnote $0B
	sndlen 24
	sndnote $0B
	sndnote $0B
	sndlen 8
	sndnote $06
	sndnote $0B
	sndnote $0C
	sndlen 16
	sndnote $0D
	sndlen 32
	sndnote $0D
	sndlen 24
	sndnote $0D
	sndlen 16
	sndnote $08
	sndlen 8
	sndnote $0D
	sndlen 16
	sndnote $08
	sndlen 8
	sndnote $0D
	sndlen 24
	sndnote $0D
	sndnote $0D
	sndlen 16
	sndnote $08
	sndlen 8
	sndnote $0D
	sndlen 16
	sndnote $06
	sndlen 8
	sndnote $0B
	sndlen 24
	sndnote $0B
	sndlen 16
	sndnote $0A
	sndlen 8
	sndnote $0B
	sndlen 16
	sndnote $06
	sndlen 8
	sndnote $08
	sndlen 16
	sndnote $0B
	sndlenpre $48
	sndlenpre $10
	sndnote $08
	sndlenpre $48
	sndnote $0A
	sndlen 16
	sndlenpre $48
	sndlenpre $10
	sndnote $09
	sndlenpre $48
	sndnote $0B
	sndlen 16
	sndlenpre $48
	sndlenpre $08
	sndnote $0D
	sndret
SndData_BGM_BigShot_Ch4:
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 24
.main:
	sndcall .call0
	sndcall .call1
	sndcall .call1
	sndcall .call2
	sndcall .call3
	sndloop .main
.call0:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 16
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 16
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 24
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 16
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 8
	sndloopcnt $00, 6, .call0
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 16
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 16
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 24
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 16
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 96
	sndlenpre $08
	sndret
.call1:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 16
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 16
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 8
	sndloopcnt $00, 3, .call1
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 8
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 16
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 8
	sndret
.call2:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 16
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 16
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 24
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 16
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 24
	sndch4 3, 0, 6
	sndlen 8
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 8
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 8
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 8
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 8
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 16
	sndch4 3, 0, 6
	sndlen 24
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 16
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 8
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 8
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 16
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 24
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 16
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 8
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 8
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 8
	sndch4 2, 0, 4
	sndlen 8
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 8
	sndret
.call3:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 8
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 8
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 8
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 8
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 8
	sndch4 3, 0, 6
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 8
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 8
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 8
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 8
	sndloopcnt $00, 5, .call3
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 24
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 8
	sndch4 2, 0, 4
	sndlen 8
	sndch4 2, 0, 4
	sndlen 8
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 4
	sndch4 2, 0, 6
	sndlen 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 8
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 4
	sndch4 1, 0, 0
	sndlen 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 8
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 4
	sndch4 3, 0, 2
	sndlen 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 8
	sndch4 3, 0, 6
	sndlen 40
	sndch4 3, 0, 6
	sndlen 8
	sndch4 3, 0, 6
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 8
	sndch4 2, 0, 4
	sndlen 8
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 16
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 24
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 8
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 8
	sndch4 2, 0, 4
	sndlen 8
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 4
	sndch4 1, 0, 0
	sndlen 4
	sndch4 1, 0, 0
	sndlen 8
	sndch4 1, 0, 0
	sndlen 8
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 4
	sndch4 2, 0, 6
	sndlen 4
	sndch4 2, 0, 6
	sndlen 8
	sndch4 2, 0, 6
	sndlen 8
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 8
	sndch4 2, 0, 4
	sndlen 8
	sndch4 2, 0, 4
	sndlen 8
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 8
	sndch4 3, 0, 6
	sndlen 8
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 8
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 4
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 4
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 8
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 8
	sndch4 3, 0, 6
	sndlen 8
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 8
	sndlenpre $30
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 8
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 16
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 16
	sndch4 2, 0, 4
	sndlen 8
	sndret
