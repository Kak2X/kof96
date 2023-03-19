SndHeader_BGM_Roulette:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_Roulette_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR; Sound channel ptr
	dw SndData_BGM_Roulette_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_Roulette_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR; Sound channel ptr
	dw SndData_BGM_Roulette_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_BGM_Roulette_Ch1:
	sndenv 1, SNDENV_DEC, 1
	sndenach SNDOUT_CH1R|SNDOUT_CH1L
	sndnr11 3, 0
	sndnote $0A
	sndlen 48
	sndenv 7, SNDENV_DEC, 6
.main:
	sndcall .call0
	sndcall .call1
	sndcall .call0
	sndcall .call2
	sndloop .main
.call0:
	sndenv 7, SNDENV_DEC, 6
	sndnote $0A
	sndlen 12
	sndenv 1, SNDENV_DEC, 1
	sndnote $0A
	sndlen 72
	sndenv 7, SNDENV_DEC, 6
	sndnote $08
	sndlen 12
	sndnote $0A
	sndenv 1, SNDENV_DEC, 1
	sndnote $0A
	sndlen 36
	sndenv 7, SNDENV_DEC, 6
	sndnote $0D
	sndlen 12
	sndnote $0A
	sndlen 6
	sndret
.call1:
	sndnote $0F
	sndlen 6
	sndnote $00
	sndnote $0D
	sndnote $08
	sndlen 12
	sndret
.call2:
	sndnote $0F
	sndlen 12
	sndnote $08
	sndlen 6
	sndnote $0F
	sndlen 12
	sndret
SndData_BGM_Roulette_Ch2:
	sndenv 1, SNDENV_DEC, 1
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 2, 0
	sndnote $0A
	sndlen 48
	sndenv 5, SNDENV_DEC, 2
.main:
	sndcall .call0
	sndcall .call1
	sndloop .main
.call0:
	sndnote $2C
	sndlen 6
	sndnote $27
	sndnote $31
	sndlen 12
	sndnote $2C
	sndlen 6
	sndnote $27
	sndnote $31
	sndnote $27
	sndloopcnt $00, 3, .call0
	sndret
.call1:
	sndnote $2C
	sndlen 6
	sndnote $27
	sndnote $31
	sndlen 12
	sndnote $2C
	sndlen 6
	sndnote $27
	sndnote $31
	sndnote $33
	sndret
SndData_BGM_Roulette_Ch3:
	sndenvch3 0
	sndenach SNDOUT_CH3R|SNDOUT_CH3L
	sndwave $04
	sndch3len $32
	sndnote $0A
	sndlen 48
	sndenvch3 2
.main:
	sndcall .call0
	sndcall .call1
	sndcall .call0
	sndcall .call2
	sndloop .main
.call0:
	sndnote $0A
	sndlen 12
	sndnote $08
	sndlen 6
	sndnote $0A
	sndnote $00
	sndnote $0D
	sndnote $08
	sndnote $09
	sndnote $0A
	sndlen 3
	sndnote $00
	sndlen 9
	sndnote $0F
	sndlen 12
	sndnote $0D
	sndlen 6
	sndnote $0A
	sndlen 12
	sndnote $08
	sndlen 6
	sndret
.call1:
	sndnote $0A
	sndlen 12
	sndnote $08
	sndlen 6
	sndnote $0A
	sndnote $00
	sndnote $0D
	sndnote $08
	sndlen 12
	sndnote $03
	sndlen 6
	sndnote $08
	sndnote $0A
	sndnote $0F
	sndnote $00
	sndnote $0D
	sndnote $08
	sndlen 12
	sndret
.call2:
	sndnote $0A
	sndlen 12
	sndnote $08
	sndlen 6
	sndnote $0A
	sndnote $00
	sndnote $0D
	sndnote $08
	sndlen 12
	sndnote $0D
	sndnote $0A
	sndlen 6
	sndnote $0F
	sndlen 12
	sndnote $08
	sndlen 6
	sndnote $0F
	sndlen 12
	sndret
SndData_BGM_Roulette_Ch4:
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 12
	sndch4 2, 0, 4
	sndlen 6
	sndch4 2, 0, 4
	sndlen 12
	sndch4 2, 0, 4
	sndlen 6
	sndch4 2, 0, 4
	sndlen 6
.main:
	sndcall .call0
	sndloop .main
.call0:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 12
	sndch4 3, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 24
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 12
	sndch4 3, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 18
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 6
	sndch4 3, 0, 6
	sndlen 12
	sndch4 3, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 18
	sndch4 2, 0, 4
	sndlen 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 12
	sndch4 3, 0, 6
	sndlen 6
	sndch4 6, 0, 1
	sndlen 12
	sndch4 3, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 24
	sndch4 6, 0, 1
	sndlen 12
	sndch4 3, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 24
	sndch4 3, 0, 6
	sndlen 12
	sndch4 3, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 18
	sndch4 2, 0, 4
	sndlen 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 6
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 12
	sndch4 2, 0, 4
	sndlen 6
	sndch4 2, 0, 4
	sndlen 6
	sndret
