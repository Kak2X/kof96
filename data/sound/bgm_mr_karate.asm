SndHeader_BGM_MrKarate:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_MrKarate_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_MrKarate_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_MrKarate_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_MrKarate_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_BGM_MrKarate_Ch1:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH1R|SNDOUT_CH1L
	sndnr11 3, 0
	sndcall .call0
.main:
	sndcall .call1
	sndcall .call2
	sndcall .call3
	sndcall .call0
	sndloop .main
.call0:
	sndenv 7, SNDENV_DEC, 5
	sndnr11 3, 0
	sndnote $24
	sndlen 20
	sndnote $20
	sndlen 10
	sndnote $1D
	sndnote $27
	sndnote $1D
	sndnote $29
	sndnote $1D
	sndnote $24
	sndlen 20
	sndnote $20
	sndlen 10
	sndnote $1D
	sndnote $22
	sndnote $1B
	sndnote $1F
	sndnote $16
	sndloopcnt $00, 2, .call0
	sndret
.call1:
	sndnote $27
	sndlen 20
	sndnote $22
	sndlen 2
	sndnote $00
	sndlen 3
	sndnote $22
	sndlen 5
	sndnote $2B
	sndlen 10
	sndnote $22
	sndlen 2
	sndnote $00
	sndlen 3
	sndnote $22
	sndlen 5
	sndnote $27
	sndlen 10
	sndnote $22
	sndlen 2
	sndnote $00
	sndlen 3
	sndnote $22
	sndlen 5
	sndnote $1B
	sndlen 10
	sndnote $27
	sndlen 20
	sndnote $22
	sndlen 2
	sndnote $00
	sndlen 3
	sndnote $22
	sndlen 5
	sndnote $2B
	sndlen 10
	sndnote $22
	sndlen 2
	sndnote $00
	sndlen 3
	sndnote $22
	sndlen 5
	sndnote $27
	sndnote $26
	sndnote $25
	sndnote $24
	sndnote $23
	sndnote $22
	sndloopcnt $00, 4, .call1
	sndret
.call2:
	sndenv 7, SNDENV_INC, 0
	sndnr11 2, 0
	sndnote $22
	sndlen 40
	sndnote $24
	sndlen 30
	sndnote $20
	sndnote $1B
	sndlen 40
	sndnote $22
	sndlen 10
	sndnote $24
	sndnote $25
	sndlen 40
	sndlenpre $0A
	sndnote $1B
	sndnote $27
	sndnote $25
	sndnote $24
	sndlenpre $28
	sndlenpre $0A
	sndnote $25
	sndnote $27
	sndnote $28
	sndlen 40
	sndnote $2A
	sndlen 30
	sndnote $28
	sndlen 10
	sndnote $27
	sndnote $00
	sndnote $24
	sndnote $20
	sndnote $1B
	sndlen 60
	sndenv 7, SNDENV_DEC, 7
	sndnr11 3, 0
	sndnote $1B
	sndlen 5
	sndnote $00
	sndnote $1B
	sndlen 10
	sndnote $1A
	sndnote $1B
	sndnote $1A
	sndnote $1B
	sndret
.call3:
	sndenv 7, SNDENV_INC, 0
	sndnr11 3, 0
	sndnote $22
	sndlen 20
	sndnote $21
	sndlen 10
	sndnote $22
	sndnote $25
	sndlen 20
	sndnote $19
	sndlen 5
	sndnote $00
	sndnote $24
	sndlen 10
	sndnote $27
	sndlen 30
	sndnote $1B
	sndlen 5
	sndnote $00
	sndnote $29
	sndlen 10
	sndnote $00
	sndnote $2C
	sndnote $00
	sndnote $29
	sndlen 80
	sndnote $27
	sndlen 5
	sndnote $29
	sndnote $27
	sndlen 30
	sndnote $25
	sndlen 5
	sndnote $27
	sndnote $25
	sndlen 20
	sndnote $00
	sndlen 10
	sndnote $24
	sndnote $25
	sndnote $24
	sndnote $20
	sndnote $1B
	sndnote $00
	sndnote $24
	sndlen 30
	sndlenpre $50
	sndenv 1, SNDENV_DEC, 1
	sndnote $01
	sndlen 80
	sndlenpre $3C
	sndlenpre $0A
	sndloopcnt $00, 2, .call3
	sndret
SndData_BGM_MrKarate_Ch2:
	sndenv 6, SNDENV_DEC, 7
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 1, 0
	sndcall .call0
.main:
	sndcall .call1
	sndcall .call2
	sndcall .call0
	sndcall .call0
	sndcall .call0
	sndcall .call0
	sndcall .call0
	sndloop .main
.call0:
	sndnote $1D
	sndlen 20
	sndnote $19
	sndlen 10
	sndnote $16
	sndnote $20
	sndnote $16
	sndnote $22
	sndnote $16
	sndnote $1D
	sndlen 20
	sndnote $19
	sndlen 10
	sndnote $16
	sndnote $1B
	sndnote $14
	sndnote $18
	sndnote $0F
	sndloopcnt $00, 2, .call0
	sndret
.call1:
	sndnote $20
	sndlen 20
	sndnote $1B
	sndlen 2
	sndnote $00
	sndlen 3
	sndnote $1B
	sndlen 5
	sndnote $24
	sndlen 10
	sndnote $1B
	sndlen 2
	sndnote $00
	sndlen 3
	sndnote $1B
	sndlen 5
	sndnote $20
	sndlen 10
	sndnote $1B
	sndlen 2
	sndnote $00
	sndlen 3
	sndnote $1B
	sndlen 5
	sndnote $14
	sndlen 10
	sndnote $20
	sndlen 20
	sndnote $1B
	sndlen 2
	sndnote $00
	sndlen 3
	sndnote $1B
	sndlen 5
	sndnote $24
	sndlen 10
	sndnote $1B
	sndlen 2
	sndnote $00
	sndlen 3
	sndnote $1B
	sndlen 5
	sndnote $20
	sndnote $1F
	sndnote $1E
	sndnote $1D
	sndnote $1C
	sndnote $1B
	sndloopcnt $00, 4, .call1
	sndret
.call2:
	sndenv 6, SNDENV_INC, 0
	sndnote $1D
	sndlen 10
	sndlenpre $28
	sndnote $1F
	sndnote $20
	sndnote $22
	sndlen 30
	sndnote $23
	sndlen 10
	sndlenpre $28
	sndnote $1C
	sndnote $20
	sndlen 60
	sndnote $24
	sndlen 10
	sndnote $25
	sndlen 30
	sndnote $23
	sndlen 20
	sndnote $21
	sndnote $1C
	sndlen 10
	sndnote $24
	sndlenpre $50
	sndenv 6, SNDENV_DEC, 7
	sndnote $00
	sndlen 10
	sndnote $24
	sndlen 5
	sndnote $00
	sndnote $24
	sndlen 10
	sndnote $23
	sndnote $24
	sndnote $23
	sndnote $24
	sndret
SndData_BGM_MrKarate_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH3R|SNDOUT_CH3L
	sndwave $04
	sndch3len $00
	sndcall .call0
.main:
	sndcall .call1
	sndcall .call2
	sndcall .call3
	sndcall .call4
	sndcall .call3
	sndloop .main
.call0:
	sndnote $16
	sndlen 10
	sndlenpre $3C
	sndnote $00
	sndlen 10
	sndnote $19
	sndlen 30
	sndnote $00
	sndlen 10
	sndnote $11
	sndnote $00
	sndnote $14
	sndnote $00
	sndnote $16
	sndlenpre $3C
	sndnote $00
	sndlen 10
	sndnote $19
	sndlen 30
	sndnote $00
	sndlen 10
	sndnote $11
	sndnote $00
	sndnote $14
	sndnote $00
	sndret
.call1:
	sndch3len $3C
	sndnote $16
	sndlen 20
	sndch3len $1E
	sndnote $13
	sndlen 10
	sndnote $14
	sndnote $15
	sndnote $16
	sndnote $13
	sndnote $14
	sndch3len $3C
	sndnote $16
	sndlen 20
	sndch3len $1E
	sndnote $0F
	sndlen 10
	sndnote $1B
	sndnote $0F
	sndnote $16
	sndnote $0F
	sndnote $14
	sndloopcnt $00, 4, .call1
	sndret
.call2:
	sndch3len $00
	sndnote $19
	sndlen 40
	sndch3len $1E
	sndnote $14
	sndlen 10
	sndnote $19
	sndnote $14
	sndnote $19
	sndch3len $00
	sndnote $18
	sndlen 60
	sndch3len $1E
	sndnote $1A
	sndlen 10
	sndnote $1B
	sndch3len $00
	sndnote $1C
	sndlen 40
	sndch3len $1E
	sndnote $17
	sndlen 10
	sndnote $1C
	sndnote $17
	sndnote $1C
	sndch3len $00
	sndnote $1B
	sndlen 60
	sndch3len $1E
	sndnote $1D
	sndlen 10
	sndnote $1E
	sndch3len $00
	sndnote $1F
	sndlen 40
	sndch3len $1E
	sndnote $1A
	sndlen 10
	sndnote $1F
	sndnote $1A
	sndnote $1F
	sndch3len $3C
	sndnote $20
	sndlen 20
	sndch3len $1E
.call2b:
	sndnote $14
	sndlen 10
	sndloopcnt $00, 8, .call2b
	sndnote $0F
	sndnote $14
	sndnote $13
	sndnote $14
	sndnote $13
	sndnote $14
	sndret
.call3:
	sndch3len $3C
	sndnote $16
	sndlen 20
	sndch3len $1E
	sndnote $16
	sndlen 10
	sndnote $16
	sndnote $16
	sndnote $16
	sndnote $16
	sndnote $16
	sndch3len $3C
	sndnote $19
	sndlen 20
	sndch3len $1E
	sndnote $19
	sndlen 10
	sndnote $19
	sndch3len $3C
	sndnote $11
	sndlen 20
	sndch3len $1E
	sndnote $0F
	sndlen 10
	sndnote $14
	sndloopcnt $00, 4, .call3
	sndret
.call4:
	sndch3len $3C
	sndnote $12
	sndlen 20
	sndch3len $19
	sndnote $12
	sndlen 10
	sndnote $12
	sndnote $12
	sndnote $12
	sndnote $12
	sndnote $12
	sndnote $12
	sndnote $12
	sndnote $12
	sndnote $12
	sndnote $12
	sndnote $0D
	sndnote $14
	sndnote $0D
	sndloopcnt $00, 2, .call4
	sndret
SndData_BGM_MrKarate_Ch4:
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndcall .call0
.main:
	sndcall .call1
	sndcall .call2
	sndcall .call3
	sndcall .call2
	sndcall .call4
	sndcall .call4
	sndcall .call5
	sndcall .call2
	sndloop .main
.call0:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 30
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 10
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 10
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 3
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 4
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 3
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 3
	sndch4 2, 0, 4
	sndlen 4
	sndch4 2, 0, 4
	sndlen 3
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 5
	sndch4 3, 0, 2
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndret
.call1:
	sndenv 0, SNDENV_DEC, 1
	sndch4 2, 0, 4
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndloopcnt $00, 7, .call1
	sndret
.call2:
	sndenv 0, SNDENV_DEC, 1
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 5
	sndch4 2, 0, 6
	sndlen 5
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 5
	sndch4 1, 0, 0
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndret
.call3:
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 20
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndloopcnt $00, 6, .call3
	sndret
.call4:
	sndenv 0, SNDENV_DEC, 1
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 20
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndloopcnt $00, 4, .call4
	sndret
.call5:
	sndenv 0, SNDENV_DEC, 1
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 20
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 0, SNDENV_DEC, 1
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 3
	sndch4 2, 0, 4
	sndlen 4
	sndch4 2, 0, 4
	sndlen 3
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndret
