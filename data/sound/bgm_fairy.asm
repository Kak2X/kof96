SndHeader_BGM_Fairy:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_Fairy_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_Fairy_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_Fairy_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_Fairy_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_BGM_Fairy_Ch1:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH1R|SNDOUT_CH1L
	sndnr11 3, 0
	sndcall .call0
	sndcall .call1
	sndcall .call2
	sndcall .call3
	sndcall .call4
	sndcall .call5
	sndloop SndData_BGM_Fairy_Ch1
.call0:
	sndenv 1, SNDENV_DEC, 1
	sndnote $05
	sndlen 20
	sndenv 7, SNDENV_DEC, 7
	sndnote $1D
	sndlen 10
	sndenv 1, SNDENV_DEC, 1
	sndnote $05
	sndlen 20
	sndenv 7, SNDENV_DEC, 7
	sndnote $1D
	sndlen 10
	sndnote $1B
	sndnote $18
	sndenv 1, SNDENV_DEC, 1
	sndnote $03
	sndlen 20
	sndenv 7, SNDENV_DEC, 7
	sndnote $1B
	sndlen 10
	sndenv 1, SNDENV_DEC, 1
	sndnote $03
	sndlen 20
	sndenv 7, SNDENV_DEC, 7
	sndnote $1B
	sndlen 10
	sndnote $1B
	sndnote $16
	sndenv 1, SNDENV_DEC, 1
	sndnote $0A
	sndlen 20
	sndenv 7, SNDENV_DEC, 7
	sndnote $22
	sndlen 10
	sndenv 1, SNDENV_DEC, 1
	sndnote $0A
	sndlen 20
	sndenv 7, SNDENV_DEC, 7
	sndnote $22
	sndlen 10
	sndenv 1, SNDENV_DEC, 1
	sndnote $0A
	sndlen 20
	sndenv 7, SNDENV_DEC, 7
	sndnote $22
	sndlen 10
	sndenv 1, SNDENV_DEC, 1
	sndnote $0A
	sndlen 20
	sndenv 7, SNDENV_DEC, 7
	sndnote $22
	sndlen 10
	sndnote $00
	sndnote $22
	sndlen 20
	sndnote $00
	sndlen 10
	sndloopcnt $00, 2, .call0
	sndret
.call1:
	sndenv 6, SNDENV_INC, 0
	sndnr11 2, 0
	sndnote $16
	sndlen 30
	sndnote $22
	sndlen 80
	sndlenpre $0A
	sndnote $27
	sndlen 10
	sndnote $24
	sndnote $20
	sndnote $1F
	sndlen 40
	sndnote $1B
	sndlen 30
	sndnote $16
	sndlen 80
	sndenv 1, SNDENV_DEC, 1
	sndnote $0A
	sndlen 20
	sndenv 6, SNDENV_INC, 0
	sndnote $16
	sndlen 30
	sndnote $22
	sndlen 80
	sndlenpre $0A
	sndnote $00
	sndnote $25
	sndnote $24
	sndnote $20
	sndnote $1F
	sndnote $20
	sndnote $1F
	sndnote $1B
	sndlen 20
	sndnote $16
	sndnote $19
	sndlen 40
	sndnote $1B
	sndlen 7
	sndnote $19
	sndlen 6
	sndnote $1B
	sndlen 7
	sndnote $19
	sndnote $1B
	sndlen 6
	sndnote $19
	sndlen 7
	sndnote $1B
	sndlen 10
	sndnote $19
	sndlen 30
	sndnote $20
	sndnote $22
	sndlen 80
	sndnote $00
	sndlen 10
	sndnote $1F
	sndnote $22
	sndlen 30
	sndnote $25
	sndnote $29
	sndlen 60
	sndenv 1, SNDENV_DEC, 1
	sndnote $05
	sndlen 20
	sndlenpre $07
	sndenv 6, SNDENV_INC, 0
	sndnote $27
	sndlen 6
	sndnote $29
	sndlen 7
	sndnote $2C
	sndlen 30
	sndnote $30
	sndnote $29
	sndnote $25
	sndlen 20
	sndnote $00
	sndlen 10
	sndnote $22
	sndlen 20
	sndnote $27
	sndlen 10
	sndnote $25
	sndlenpre $28
	sndnote $00
	sndlen 20
	sndnote $25
	sndlen 10
	sndnote $29
	sndlen 20
	sndnote $27
	sndlen 20
	sndlenpre $03
	sndnote $1D
	sndlen 7
	sndnote $1F
	sndlen 6
	sndnote $22
	sndlen 7
	sndnote $25
	sndnote $29
	sndlen 6
	sndnote $2C
	sndlen 7
	sndnote $30
	sndret
.call2:
	sndenv 7, SNDENV_DEC, 7
	sndnr11 3, 0
	sndenv 1, SNDENV_DEC, 1
	sndnote $05
	sndlen 20
	sndenv 7, SNDENV_DEC, 7
	sndnote $1D
	sndlen 10
	sndenv 1, SNDENV_DEC, 1
	sndnote $05
	sndlen 20
	sndenv 7, SNDENV_DEC, 7
	sndnote $1D
	sndlen 10
	sndenv 1, SNDENV_DEC, 1
	sndnote $05
	sndlen 20
	sndenv 7, SNDENV_DEC, 7
	sndnote $1D
	sndlen 10
	sndenv 1, SNDENV_DEC, 1
	sndnote $05
	sndlen 20
	sndenv 7, SNDENV_DEC, 7
	sndnote $1D
	sndlen 10
	sndenv 1, SNDENV_DEC, 1
	sndnote $05
	sndenv 7, SNDENV_DEC, 7
	sndnote $1B
	sndnote $1B
	sndnote $1D
	sndloopcnt $00, 3, .call2
	sndenv 1, SNDENV_DEC, 1
	sndnote $05
	sndlen 20
	sndenv 7, SNDENV_DEC, 7
	sndnote $1D
	sndlen 10
	sndenv 1, SNDENV_DEC, 1
	sndnote $05
	sndlen 20
	sndenv 7, SNDENV_DEC, 7
	sndnote $1B
	sndlen 10
	sndnote $1B
	sndnote $1D
	sndenv 1, SNDENV_DEC, 1
	sndnote $05
	sndlen 20
	sndenv 7, SNDENV_DEC, 7
	sndnote $20
	sndlen 10
	sndenv 1, SNDENV_DEC, 1
	sndnote $05
	sndlen 20
	sndenv 7, SNDENV_DEC, 7
	sndnote $1B
	sndlen 10
	sndnote $22
	sndnote $1B
	sndret
.call3:
	sndenv 6, SNDENV_INC, 0
	sndnr11 2, 0
	sndnote $16
	sndlen 30
	sndnote $22
	sndlen 80
	sndlenpre $0A
	sndnote $25
	sndnote $24
	sndnote $20
	sndnote $1F
	sndlen 40
	sndnote $1B
	sndlen 30
	sndnote $16
	sndlen 40
	sndnote $00
	sndlen 10
	sndnote $1B
	sndlen 20
	sndnote $19
	sndnote $14
	sndlen 10
	sndnote $11
	sndnote $14
	sndnote $19
	sndnote $20
	sndlen 40
	sndlenpre $0A
	sndnote $13
	sndnote $16
	sndnote $19
	sndnote $1F
	sndlen 40
	sndret
.call4:
	sndnote $1D
	sndlen 3
	sndnote $20
	sndlen 4
	sndnote $25
	sndlen 3
	sndnote $27
	sndlen 30
	sndnote $25
	sndnote $00
	sndlen 20
	sndnote $24
	sndlen 30
	sndnote $25
	sndnote $27
	sndlen 20
	sndnote $27
	sndlen 30
	sndnote $25
	sndnote $29
	sndlen 20
	sndnote $27
	sndlen 30
	sndnote $25
	sndnote $24
	sndlen 20
	sndret
.call5:
	sndnote $24
	sndlen 30
	sndnote $22
	sndlen 40
	sndnote $27
	sndlen 10
	sndnote $24
	sndlen 30
	sndnote $20
	sndnote $1D
	sndlen 20
	sndnote $1E
	sndlen 80
	sndnote $20
	sndret
SndData_BGM_Fairy_Ch2:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 3, 0
	sndcall .call0
	sndcall .call1
	sndcall .call2
	sndcall .call1
	sndcall .call3
	sndcall .call1
	sndcall .call2
	sndcall .call1
	sndcall .call4
	sndcall .call5
	sndcall .call6
	sndcall .call7
	sndcall .call8
	sndloop SndData_BGM_Fairy_Ch2
.call0:
	sndnote $16
	sndlen 5
	sndnote $00
	sndnote $16
	sndnote $00
	sndnote $22
	sndlen 10
	sndnote $16
	sndlen 5
	sndnote $00
	sndnote $16
	sndnote $00
	sndnote $22
	sndlen 10
	sndnote $20
	sndnote $1D
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $14
	sndnote $00
	sndnote $20
	sndlen 10
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $14
	sndnote $00
	sndnote $20
	sndlen 10
	sndnote $1F
	sndnote $1B
	sndnote $1B
	sndlen 5
	sndnote $00
	sndnote $1B
	sndnote $00
	sndnote $27
	sndlen 10
	sndnote $1B
	sndlen 5
	sndnote $00
	sndnote $1B
	sndnote $00
	sndnote $27
	sndlen 10
	sndnote $1B
	sndlen 5
	sndnote $00
	sndnote $1B
	sndnote $00
	sndnote $27
	sndlen 10
	sndnote $1B
	sndlen 5
	sndnote $00
	sndnote $1B
	sndnote $00
	sndnote $27
	sndlen 10
	sndnote $1B
	sndlen 5
	sndnote $00
	sndnote $27
	sndlen 20
	sndnote $1B
	sndlen 5
	sndnote $00
	sndloopcnt $00, 2, .call0
	sndret
.call1:
	sndenv 6, SNDENV_DEC, 5
	sndnote $29
	sndlen 10
	sndnote $25
	sndnote $24
	sndnote $20
	sndlen 20
	sndnote $1D
	sndnote $19
	sndnote $16
	sndnote $1B
	sndlen 10
	sndnote $18
	sndnote $14
	sndnote $0F
	sndlen 20
	sndret
.call2:
	sndnote $16
	sndlen 10
	sndnote $0F
	sndnote $13
	sndnote $16
	sndnote $1D
	sndnote $19
	sndnote $1D
	sndnote $20
	sndnote $25
	sndnote $1D
	sndnote $20
	sndnote $24
	sndnote $27
	sndnote $2B
	sndnote $2E
	sndnote $27
	sndret
.call3:
	sndnote $0D
	sndlen 10
	sndnote $13
	sndnote $16
	sndnote $11
	sndlen 30
	sndnote $13
	sndlen 10
	sndnote $19
	sndnote $1B
	sndnote $16
	sndlen 30
	sndnote $1B
	sndlen 10
	sndnote $1F
	sndnote $22
	sndnote $1D
	sndret
.call4:
	sndnote $0D
	sndlen 10
	sndnote $13
	sndnote $16
	sndnote $11
	sndlen 30
	sndnote $13
	sndlen 10
	sndnote $19
	sndnote $1B
	sndnote $16
	sndlen 30
	sndnote $1B
	sndlen 20
	sndnote $24
	sndret
.call5:
	sndenv 7, SNDENV_DEC, 7
	sndnote $16
	sndlen 5
	sndnote $00
	sndnote $16
	sndnote $00
	sndnote $22
	sndlen 10
	sndnote $16
	sndlen 5
	sndnote $00
	sndnote $16
	sndnote $00
	sndnote $22
	sndlen 10
	sndnote $16
	sndlen 5
	sndnote $00
	sndnote $16
	sndnote $00
	sndnote $22
	sndlen 10
	sndnote $16
	sndlen 5
	sndnote $00
	sndnote $16
	sndnote $00
	sndnote $22
	sndlen 10
	sndnote $16
	sndlen 5
	sndnote $00
	sndnote $1F
	sndlen 10
	sndnote $20
	sndnote $22
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $14
	sndnote $00
	sndnote $22
	sndlen 10
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $14
	sndnote $00
	sndnote $22
	sndlen 10
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $14
	sndnote $00
	sndnote $22
	sndlen 10
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $14
	sndnote $00
	sndnote $22
	sndlen 10
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $1F
	sndlen 10
	sndnote $20
	sndnote $22
	sndnote $13
	sndlen 5
	sndnote $00
	sndnote $13
	sndnote $00
	sndnote $22
	sndlen 10
	sndnote $13
	sndlen 5
	sndnote $00
	sndnote $13
	sndnote $00
	sndnote $22
	sndlen 10
	sndnote $13
	sndlen 5
	sndnote $00
	sndnote $13
	sndnote $00
	sndnote $22
	sndlen 10
	sndnote $13
	sndlen 5
	sndnote $00
	sndnote $13
	sndnote $00
	sndnote $22
	sndlen 10
	sndnote $13
	sndlen 5
	sndnote $00
	sndnote $1F
	sndlen 10
	sndnote $20
	sndnote $22
	sndnote $12
	sndlen 5
	sndnote $00
	sndnote $12
	sndnote $00
	sndnote $22
	sndlen 10
	sndnote $12
	sndlen 5
	sndnote $00
	sndnote $12
	sndnote $00
	sndnote $1E
	sndlen 10
	sndnote $20
	sndnote $22
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $14
	sndnote $00
	sndnote $1B
	sndlen 10
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $14
	sndnote $00
	sndnote $20
	sndlen 10
	sndnote $27
	sndnote $20
	sndret
.call6:
	sndenv 6, SNDENV_DEC, 5
	sndnote $25
	sndlen 10
	sndnote $2C
	sndnote $25
	sndlen 5
	sndnote $25
	sndnote $29
	sndlen 10
	sndnote $2C
	sndnote $25
	sndnote $19
	sndnote $22
	sndnote $11
	sndlen 5
	sndnote $11
	sndnote $20
	sndlen 10
	sndnote $25
	sndlen 5
	sndnote $25
	sndnote $19
	sndlen 10
	sndnote $20
	sndlen 5
	sndnote $20
	sndnote $1F
	sndlen 10
	sndnote $20
	sndnote $22
	sndnote $25
	sndlen 10
	sndnote $2C
	sndnote $25
	sndlen 5
	sndnote $25
	sndnote $29
	sndlen 10
	sndnote $2C
	sndnote $25
	sndnote $19
	sndnote $22
	sndnote $12
	sndlen 5
	sndnote $12
	sndnote $22
	sndlen 10
	sndnote $25
	sndlen 5
	sndnote $25
	sndnote $19
	sndlen 10
	sndnote $22
	sndlen 5
	sndnote $22
	sndnote $1D
	sndnote $22
	sndnote $1D
	sndnote $19
	sndnote $12
	sndnote $16
	sndnote $25
	sndlen 10
	sndnote $2C
	sndnote $25
	sndlen 5
	sndnote $25
	sndnote $29
	sndlen 10
	sndnote $2C
	sndnote $25
	sndnote $19
	sndnote $22
	sndnote $13
	sndlen 5
	sndnote $13
	sndnote $20
	sndlen 10
	sndnote $25
	sndlen 5
	sndnote $25
	sndnote $19
	sndlen 10
	sndnote $20
	sndlen 5
	sndnote $20
	sndnote $1F
	sndlen 10
	sndnote $20
	sndnote $22
	sndret
.call7:
	sndenv 6, SNDENV_DEC, 5
	sndnotebase $0C
	sndnote $12
	sndlen 10
	sndnote $16
	sndnote $19
	sndnote $16
	sndnote $06
	sndnote $12
	sndnote $0D
	sndnote $19
	sndnote $11
	sndnote $14
	sndnote $19
	sndnote $14
	sndnote $05
	sndnote $11
	sndnote $0D
	sndnote $11
	sndnote $11
	sndnote $16
	sndnote $19
	sndnote $16
	sndnote $05
	sndnote $11
	sndnote $0D
	sndnote $16
	sndnote $13
	sndnote $16
	sndnote $19
	sndnote $16
	sndnote $07
	sndnote $13
	sndnote $0F
	sndnote $19
	sndnote $12
	sndlen 10
	sndnote $16
	sndnote $19
	sndnote $16
	sndnote $06
	sndnote $12
	sndnote $0D
	sndnote $19
	sndnote $11
	sndnote $14
	sndnote $19
	sndnote $14
	sndnote $05
	sndnote $11
	sndnote $0D
	sndnote $11
	sndnotebase $F4
	sndret
.call8:
	sndenv 6, SNDENV_DEC, 7
	sndnote $22
	sndlen 30
	sndnote $2A
	sndnote $29
	sndlen 20
	sndnote $24
	sndlen 30
	sndnote $2C
	sndlen 20
	sndnote $2A
	sndnote $29
	sndlen 10
	sndret
SndData_BGM_Fairy_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH3R|SNDOUT_CH3L
	sndwave $04
	sndch3len $1E
	sndcall .call0
	sndcall .call1
	sndcall .call0
	sndcall .call2
	sndcall .call3
	sndcall .call4
	sndcall .call5
	sndcall .call6
	sndcall .call7
	sndloop SndData_BGM_Fairy_Ch3
.call0:
	sndnote $14
	sndlen 5
	sndnote $16
	sndnote $16
	sndlen 10
	sndnote $16
	sndnote $14
	sndlen 5
	sndnote $16
	sndnote $16
	sndlen 10
	sndnote $16
	sndnote $16
	sndnote $16
	sndnote $13
	sndlen 5
	sndnote $14
	sndnote $14
	sndlen 10
	sndnote $14
	sndnote $13
	sndlen 5
	sndnote $14
	sndnote $14
	sndlen 10
	sndnote $14
	sndnote $14
	sndnote $14
	sndnote $12
	sndlen 5
	sndnote $13
	sndnote $13
	sndlen 10
	sndnote $13
	sndnote $12
	sndlen 5
	sndnote $13
	sndnote $13
	sndlen 10
	sndnote $13
	sndnote $13
	sndnote $13
	sndret
.call1:
	sndnote $19
	sndlen 5
	sndnote $1B
	sndnote $1B
	sndlen 10
	sndnote $1B
	sndnote $19
	sndlen 5
	sndnote $1B
	sndnote $1B
	sndlen 10
	sndnote $1B
	sndnote $1B
	sndnote $1B
	sndret
.call2:
	sndnote $19
	sndlen 5
	sndnote $1B
	sndnote $1B
	sndlen 10
	sndnote $1B
	sndch3len $3C
	sndnote $19
	sndlen 20
	sndch3len $1E
	sndnote $13
	sndlen 10
	sndnote $14
	sndnote $15
	sndret
.call3:
	sndch3len $00
	sndnote $16
	sndlen 30
	sndnote $22
	sndnote $20
	sndnote $1B
	sndnote $1D
	sndlen 20
	sndnote $19
	sndnote $13
	sndlen 30
	sndnote $1F
	sndnote $1B
	sndnote $19
	sndnote $1B
	sndlen 20
	sndnote $14
	sndloopcnt $00, 3, .call3
	sndnote $16
	sndlen 30
	sndnote $22
	sndnote $20
	sndnote $1B
	sndnote $1D
	sndlen 20
	sndnote $19
	sndnote $13
	sndlen 30
	sndnote $1F
	sndnote $19
	sndnote $1E
	sndnote $12
	sndlen 20
	sndnote $14
	sndret
.call4:
	sndch3len $1E
	sndnote $14
	sndlen 5
	sndnote $16
	sndnote $16
	sndlen 10
	sndnote $16
	sndnote $14
	sndlen 5
	sndnote $16
	sndnote $16
	sndlen 10
	sndnote $16
	sndnote $14
	sndlen 5
	sndnote $16
	sndnote $16
	sndlen 10
	sndnote $16
	sndnote $15
	sndlen 5
	sndnote $16
	sndnote $16
	sndlen 10
	sndnote $11
	sndnote $16
	sndnote $16
	sndnote $11
	sndnote $16
	sndnote $13
	sndlen 5
	sndnote $14
	sndnote $14
	sndlen 10
	sndnote $14
	sndnote $13
	sndlen 5
	sndnote $14
	sndnote $14
	sndlen 10
	sndnote $14
	sndnote $13
	sndlen 5
	sndnote $14
	sndnote $14
	sndlen 10
	sndnote $14
	sndnote $13
	sndlen 5
	sndnote $14
	sndnote $14
	sndlen 10
	sndnote $0F
	sndnote $14
	sndnote $14
	sndnote $0F
	sndnote $14
	sndnote $12
	sndlen 5
	sndnote $13
	sndnote $13
	sndlen 10
	sndnote $13
	sndnote $12
	sndlen 5
	sndnote $13
	sndnote $13
	sndlen 10
	sndnote $13
	sndnote $12
	sndlen 5
	sndnote $13
	sndnote $13
	sndlen 10
	sndnote $13
	sndnote $12
	sndlen 5
	sndnote $13
	sndnote $13
	sndlen 10
	sndnote $19
	sndnote $13
	sndnote $0F
	sndnote $16
	sndnote $0F
	sndnote $11
	sndlen 5
	sndnote $12
	sndnote $12
	sndlen 10
	sndnote $12
	sndnote $11
	sndlen 5
	sndnote $12
	sndnote $12
	sndlen 10
	sndnote $12
	sndnote $11
	sndlen 5
	sndnote $12
	sndnote $12
	sndlen 10
	sndnote $13
	sndlen 5
	sndnote $14
	sndnote $14
	sndlen 10
	sndnote $14
	sndch3len $3C
	sndnote $1B
	sndlen 20
	sndnote $19
	sndnote $14
	sndlen 10
	sndch3len $1E
	sndret
.call5:
	sndnote $14
	sndlen 5
	sndnote $16
	sndnote $16
	sndlen 10
	sndnote $16
	sndnote $14
	sndlen 5
	sndnote $16
	sndnote $16
	sndlen 10
	sndnote $16
	sndnote $14
	sndlen 5
	sndnote $16
	sndnote $16
	sndlen 10
	sndnote $13
	sndlen 5
	sndnote $14
	sndnote $14
	sndlen 10
	sndnote $14
	sndnote $13
	sndlen 5
	sndnote $14
	sndnote $14
	sndlen 10
	sndnote $14
	sndnote $13
	sndlen 5
	sndnote $14
	sndnote $14
	sndlen 10
	sndnote $12
	sndlen 5
	sndnote $13
	sndnote $13
	sndlen 10
	sndnote $13
	sndnote $12
	sndlen 5
	sndnote $13
	sndnote $13
	sndlen 10
	sndnote $13
	sndnote $12
	sndlen 5
	sndnote $13
	sndnote $13
	sndlen 10
	sndnote $11
	sndlen 5
	sndnote $12
	sndnote $12
	sndlen 10
	sndnote $12
	sndch3len $3C
	sndnote $16
	sndlen 20
	sndch3len $1E
	sndnote $1B
	sndlen 10
	sndnote $19
	sndnote $11
	sndnote $18
	sndlen 5
	sndnote $19
	sndnote $19
	sndlen 10
	sndnote $19
	sndnote $18
	sndlen 5
	sndnote $19
	sndnote $19
	sndlen 10
	sndnote $19
	sndnote $18
	sndlen 5
	sndnote $19
	sndnote $19
	sndlen 10
	sndnote $1A
	sndlen 5
	sndnote $1B
	sndnote $1B
	sndlen 10
	sndnote $1B
	sndnote $1A
	sndlen 5
	sndnote $1B
	sndnote $1B
	sndlen 10
	sndnote $1B
	sndnote $1A
	sndlen 5
	sndnote $1B
	sndnote $1B
	sndlen 10
	sndret
.call6:
	sndch3len $00
	sndnote $12
	sndlen 30
	sndnote $16
	sndlen 10
	sndnote $19
	sndnote $1B
	sndnote $12
	sndlen 20
	sndnote $11
	sndlen 40
	sndnote $11
	sndlen 20
	sndnote $14
	sndnote $16
	sndlen 40
	sndlenpre $0A
	sndnote $16
	sndlen 10
	sndnote $11
	sndnote $0D
	sndnote $0F
	sndlen 60
	sndlenpre $0A
	sndnote $0F
	sndnote $12
	sndlen 30
	sndnote $19
	sndnote $12
	sndlen 20
	sndnote $11
	sndlen 30
	sndnote $18
	sndnote $11
	sndlen 20
	sndret
.call7:
	sndnote $12
	sndlen 30
	sndnote $1E
	sndnote $19
	sndlen 20
	sndnote $14
	sndlen 30
	sndnote $20
	sndnote $1B
	sndlen 20
	sndch3len $1E
	sndret
SndData_BGM_Fairy_Ch4:
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndcall .call0
	sndcall .call1
	sndcall .call0
	sndcall .call2
	sndcall .call3
	sndcall .call4
	sndcall .call3
	sndcall .call5
	sndcall .call3
	sndcall .call4
	sndcall .call3
	sndcall .call5
	sndcall .call6
	sndcall .call7
	sndcall .call6
	sndcall .call8
	sndcall .call0
	sndcall .call1
	sndcall .call0
	sndcall .call2
	sndcall .call9
	sndcall .call10
	sndloop SndData_BGM_Fairy_Ch4
.call0:
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
	sndlen 10
	sndloopcnt $00, 6, .call0
	sndret
.call1:
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
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
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
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndret
.call2:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 2
	sndch4 2, 0, 4
	sndlen 3
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndret
.call3:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 20
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 10
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndret
.call4:
	sndenv 1, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 20
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 20
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndret
.call5:
	sndenv 1, SNDENV_DEC, 1
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
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 10
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 20
	sndret
.call6:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 20
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 20
	sndloopcnt $00, 3, .call6
	sndret
.call7:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 20
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndret
.call8:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndch4 2, 0, 4
	sndlen 2
	sndch4 2, 0, 4
	sndlen 3
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 2
	sndch4 2, 0, 4
	sndlen 3
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 5
	sndch4 1, 0, 0
	sndlen 5
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 5
	sndch4 3, 0, 2
	sndlen 5
	sndret
.call9:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndloopcnt $00, 7, .call9
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
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
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
.call9b:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndloopcnt $00, 3, .call9b
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 10
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 10
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 10
	sndret
.call10:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 20
	sndloopcnt $00, 7, .call10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 10
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 10
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 10
.call10b:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 20
	sndloopcnt $00, 3, .call10b
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndch4 2, 0, 4
	sndlen 10
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
.call10c:
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndloopcnt $00, 3, .call10c
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndch4 2, 0, 4
	sndlen 10
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 10
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 20
	sndret
