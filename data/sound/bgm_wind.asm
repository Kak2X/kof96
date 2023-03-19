SndHeader_BGM_Wind:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_Wind_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_Wind_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_Wind_Ch3 ; Data ptr
	db $0C ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_Wind_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_BGM_Wind_Ch1:
	sndenv 7, SNDENV_INC, 0
	sndenach SNDOUT_CH1R|SNDOUT_CH1L
	sndnr11 2, 0
	sndnote $27
	sndlen 48
	sndnote $25
	sndlen 96
	sndlenpre $18
	sndnote $00
	sndnote $28
	sndlen 48
	sndnote $2A
	sndlen 96
	sndlenpre $18
	sndnote $00
	sndnote $27
	sndlen 48
	sndnote $25
	sndlen 96
	sndlenpre $18
	sndnote $00
	sndnote $28
	sndlen 48
	sndnote $2A
	sndlen 96
	sndnote $2B
.main:
	sndnote $0B
	sndlen 12
	sndnote $00
	sndloop .main
SndData_BGM_Wind_Ch2:
	sndenv 1, SNDENV_DEC, 1
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 3, 0
	sndnote $01
	sndlen 48
	sndenv 7, SNDENV_INC, 0
	sndnote $15
	sndlen 12
	sndnote $19
	sndnote $1C
	sndnote $20
	sndlen 48
	sndlenpre $0C
	sndlenpre $60
	sndnote $17
	sndlen 12
	sndnote $19
	sndnote $1B
	sndnote $20
	sndlen 48
	sndlenpre $0C
	sndlenpre $60
	sndnote $15
	sndlen 12
	sndnote $19
	sndnote $1C
	sndnote $20
	sndlen 48
	sndlenpre $0C
	sndlenpre $60
	sndnote $17
	sndlen 12
	sndnote $19
	sndnote $1B
	sndnote $20
	sndlen 48
	sndlenpre $0C
	sndnote $21
	sndlen 96
.main:
	sndnote $0F
	sndlen 12
	sndnote $00
	sndloop .main
SndData_BGM_Wind_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH3R|SNDOUT_CH3L
	sndwave $02
	sndch3len $00
	sndnote $0B
	sndlen 48
	sndnote $09
	sndlen 96
	sndlenpre $60
	sndnote $0B
	sndlen 96
	sndlenpre $60
	sndnote $09
	sndlen 96
	sndlenpre $60
	sndnote $06
	sndlen 96
	sndnote $05
	sndch3len $32
.main:
	sndnote $01
	sndlen 24
	sndloop .main
SndData_BGM_Wind_Ch4:
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 24
	sndch4 3, 0, 6
	sndlen 24
	sndcall .intro
.main:
	sndcall .call1
	sndcall .call2
	sndcall .call1
	sndcall .call3
	sndloop .main
.intro:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 36
	sndch4 3, 0, 6
	sndlen 6
	sndch4 3, 0, 6
	sndlen 6
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 12
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 12
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 12
	sndch4 3, 0, 6
	sndlen 24
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 24
	sndch4 3, 0, 2
	sndlen 24
	sndloopcnt $00, 4, .intro
	sndret
.call1:
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 60
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 12
	sndret
.call2:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 6
	sndch4 3, 0, 6
	sndlen 6
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 24
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 36
	sndch4 1, 0, 1
	sndlen 24
	sndret
.call3:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 6
	sndch4 3, 0, 6
	sndlen 6
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 24
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 12
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 12
	sndch4 3, 0, 6
	sndlen 12
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 12
	sndret
