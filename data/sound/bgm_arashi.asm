SndHeader_BGM_Arashi:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_Arashi_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_Arashi_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_Arashi_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_Arashi_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_BGM_Arashi_Ch1:
	sndenv 7, SNDENV_DEC, 2
	sndenach SNDOUT_CH1R|SNDOUT_CH1L
	sndnr11 2, 0
	sndcall .call0
	sndcall .call1
	sndcall .call2
	sndcall .call3
	sndcall .call4
	sndcall .call5
	sndcall .call4
	sndcall .call6
	sndcall .call7
	sndcall .call8
	sndloop SndData_BGM_Arashi_Ch1
.call0:
	sndnote $1A
	sndlen 7
	sndnote $20
	sndnote $1A
	sndnote $20
	sndlen 14
	sndnote $1A
	sndlen 7
	sndnote $1F
	sndlen 14
	sndnote $16
	sndlen 7
	sndnote $1F
	sndnote $16
	sndnote $16
	sndnote $1F
	sndnote $1F
	sndnote $16
	sndnote $1B
	sndret
.call1:
	sndnote $1A
	sndlen 7
	sndnote $20
	sndnote $1A
	sndnote $20
	sndlen 14
	sndnote $1A
	sndlen 7
	sndnote $1F
	sndlen 14
	sndnote $16
	sndlen 7
	sndnote $22
	sndnote $22
	sndnote $1D
	sndnote $21
	sndnote $1D
	sndnote $1E
	sndnote $18
	sndret
.call2:
	sndenv 1, SNDENV_DEC, 1
	sndnr11 3, 0
	sndnote $0A
	sndlen 28
	sndenv 7, SNDENV_INC, 0
	sndnote $16
	sndlen 7
	sndnote $19
	sndnote $1D
	sndnote $20
	sndnote $00
	sndlen 14
	sndnote $22
	sndlen 28
	sndnote $1D
	sndlen 7
	sndnote $00
	sndnote $1F
	sndlen 21
	sndnote $1B
	sndlen 7
	sndnote $00
	sndlen 14
	sndnote $16
	sndlen 28
	sndnote $1B
	sndnote $16
	sndlen 7
	sndnote $00
	sndnote $19
	sndlen 21
	sndnote $1B
	sndlen 7
	sndenv 1, SNDENV_DEC, 1
	sndnote $03
	sndlen 28
	sndlenpre $15
	sndenv 7, SNDENV_INC, 0
	sndnote $12
	sndlen 14
	sndnote $16
	sndlen 7
	sndnote $19
	sndnote $00
	sndnote $1B
	sndlen 21
	sndnote $19
	sndlen 7
	sndenv 1, SNDENV_DEC, 1
	sndnote $01
	sndlen 112
	sndenv 7, SNDENV_INC, 0
	sndnote $16
	sndlen 7
	sndnote $19
	sndnote $1D
	sndnote $20
	sndnote $00
	sndlen 14
	sndnote $22
	sndlen 28
	sndnote $1D
	sndlen 7
	sndnote $00
	sndnote $1F
	sndlen 21
	sndnote $1B
	sndlen 7
	sndnote $00
	sndlen 14
	sndnote $16
	sndnote $00
	sndnote $1B
	sndnote $16
	sndlen 7
	sndnote $1B
	sndnote $00
	sndnote $16
	sndnote $1B
	sndlen 21
	sndnote $19
	sndlen 14
	sndret
.call3:
	sndenv 1, SNDENV_DEC, 1
	sndnote $01
	sndlen 7
	sndenv 7, SNDENV_DEC, 2
	sndnr11 2, 0
	sndnote $14
	sndlen 21
	sndnote $11
	sndnote $15
	sndlen 28
	sndnote $0F
	sndlen 7
	sndnote $11
	sndlen 14
	sndnote $11
	sndlen 21
	sndnote $14
	sndnote $16
	sndnote $15
	sndlen 14
	sndnote $14
	sndret
.call4:
	sndenv 7, SNDENV_INC, 0
	sndnr11 3, 0
	sndnote $1B
	sndlen 21
	sndnote $1D
	sndlen 35
	sndnote $00
	sndlen 14
	sndnote $1B
	sndlen 3
	sndnote $1D
	sndlen 4
	sndnote $20
	sndlen 35
	sndlenpre $1C
	sndnote $00
	sndlen 14
	sndnote $20
	sndlen 28
	sndnote $22
	sndnote $20
	sndlen 7
	sndnote $00
	sndret
.call5:
	sndnote $1F
	sndlen 14
	sndnote $00
	sndlen 7
	sndnote $1B
	sndlen 35
	sndnote $00
	sndlen 21
	sndnote $13
	sndlen 14
	sndnote $14
	sndlen 7
	sndnote $16
	sndnote $17
	sndlenpre $15
	sndnote $16
	sndnote $12
	sndlen 14
	sndnote $00
	sndnote $1B
	sndnote $00
	sndlen 7
	sndnote $1B
	sndlen 14
	sndnote $11
	sndlen 7
	sndret
.call6:
	sndnote $1F
	sndlen 14
	sndnote $00
	sndlen 7
	sndnote $1B
	sndlen 35
	sndnote $00
	sndlen 21
	sndnote $1E
	sndlen 14
	sndnote $20
	sndlen 7
	sndnote $22
	sndnote $23
	sndlenpre $15
	sndnote $22
	sndnote $21
	sndnote $1D
	sndlen 10
	sndnote $00
	sndlen 11
	sndnote $18
	sndlen 7
	sndnote $1B
	sndlen 21
	sndret
.call7:
	sndnote $1D
	sndlen 56
	sndnote $00
	sndlen 14
	sndnote $20
	sndnote $00
	sndlen 7
	sndnote $1E
	sndlen 21
	sndnote $1D
	sndlen 28
	sndnote $00
	sndlen 14
	sndnote $18
	sndlen 28
	sndnote $00
	sndlen 7
	sndnote $19
	sndlen 21
	sndnote $1B
	sndlen 14
	sndnote $1B
	sndnote $1D
	sndlen 7
	sndnote $1D
	sndlen 28
	sndnote $00
	sndlen 14
	sndnote $14
	sndlen 2
	sndnote $20
	sndlen 3
	sndnote $21
	sndlen 2
	sndnote $22
	sndlen 28
	sndnote $16
	sndlen 14
	sndnote $1B
	sndnote $0F
	sndlen 7
	sndnote $19
	sndlen 21
	sndnote $16
	sndlen 28
	sndnote $00
	sndlen 14
	sndnote $14
	sndlen 5
	sndnote $16
	sndlen 4
	sndnote $18
	sndlen 5
	sndnote $19
	sndnote $1B
	sndlen 4
	sndnote $1D
	sndlen 5
	sndnote $19
	sndlen 28
	sndnote $00
	sndlen 14
	sndnote $19
	sndlen 28
	sndnote $1E
	sndlen 14
	sndnote $16
	sndlen 28
	sndnote $18
	sndnote $00
	sndlen 14
	sndnote $1D
	sndlen 28
	sndnote $1B
	sndlen 21
	sndnote $14
	sndret
.call8:
	sndnote $19
	sndlen 14
	sndnote $00
	sndlen 7
	sndnote $1B
	sndlen 35
	sndnote $00
	sndlen 7
	sndnote $1D
	sndlen 2
	sndnote $1E
	sndlen 3
	sndnote $1F
	sndlen 2
	sndnote $20
	sndlen 35
	sndnote $00
	sndlen 7
	sndnote $21
	sndlen 21
	sndnote $1D
	sndlen 7
	sndnote $00
	sndlen 14
	sndnote $1B
	sndlen 21
	sndnote $18
	sndlen 10
	sndnote $00
	sndlen 11
	sndnote $18
	sndlen 7
	sndnote $1E
	sndlen 21
	sndret
SndData_BGM_Arashi_Ch2:
	sndenv 6, SNDENV_DEC, 2
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 2, 0
	sndcall .call0
	sndcall .call1
	sndcall .call2
	sndcall .call3
	sndcall .call2
	sndcall .call4
	sndcall .call5
	sndcall .call6
	sndcall .call5
	sndcall .call7
	sndcall .call8
	sndcall .call9
	sndcall .call10
	sndloop SndData_BGM_Arashi_Ch2
.call0:
	sndnote $1D
	sndlen 7
	sndnote $25
	sndnote $1D
	sndnote $25
	sndlen 14
	sndnote $1D
	sndlen 7
	sndnote $25
	sndlen 14
	sndnote $1B
	sndlen 7
	sndnote $24
	sndnote $1B
	sndnote $1B
	sndnote $25
	sndnote $24
	sndnote $1B
	sndnote $1F
	sndret
.call1:
	sndnote $1D
	sndlen 7
	sndnote $25
	sndnote $1D
	sndnote $25
	sndlen 14
	sndnote $1D
	sndlen 7
	sndnote $25
	sndlen 14
	sndnote $1B
	sndlen 7
	sndnote $27
	sndnote $26
	sndnote $22
	sndnote $25
	sndnote $21
	sndnote $23
	sndnote $1D
	sndret
.call2:
	sndnote $25
	sndlen 7
	sndnote $25
	sndnote $19
	sndnote $25
	sndnote $16
	sndnote $22
	sndnote $19
	sndnote $25
	sndlen 21
	sndnote $27
	sndlen 7
	sndnote $20
	sndnote $19
	sndnote $25
	sndnote $19
	sndnote $24
	sndlen 21
	sndnote $18
	sndlen 7
	sndnote $24
	sndnote $18
	sndnote $24
	sndnote $18
	sndnote $1D
	sndlen 21
	sndnote $11
	sndlen 7
	sndnote $1D
	sndnote $11
	sndnote $24
	sndnote $18
	sndnote $1D
	sndret
.call3:
	sndnote $20
	sndlen 7
	sndnote $14
	sndnote $20
	sndnote $25
	sndnote $16
	sndnote $22
	sndnote $19
	sndnote $25
	sndlen 21
	sndnote $14
	sndlen 7
	sndnote $20
	sndnote $19
	sndnote $25
	sndnote $19
	sndnote $21
	sndlen 21
	sndnote $15
	sndlen 7
	sndnote $21
	sndnote $15
	sndnote $17
	sndnote $21
	sndnote $27
	sndnote $2C
	sndnote $29
	sndnote $20
	sndnote $1D
	sndnote $28
	sndnote $1E
	sndnote $23
	sndnote $26
	sndret
.call4:
	sndnote $0F
	sndlen 7
	sndnote $11
	sndnote $0A
	sndnote $11
	sndnote $0A
	sndnote $0A
	sndnote $19
	sndlen 14
	sndnote $0A
	sndlen 7
	sndnote $16
	sndnote $0A
	sndnote $0A
	sndnote $1A
	sndlen 14
	sndnote $08
	sndlen 7
	sndnote $08
	sndnote $14
	sndnote $16
	sndnote $0A
	sndnote $16
	sndnote $0A
	sndnote $0A
	sndnote $19
	sndlen 14
	sndnote $0A
	sndlen 7
	sndnote $1B
	sndnote $0A
	sndnote $0A
	sndnote $1A
	sndlen 14
	sndnote $19
	sndret
.call5:
	sndnote $20
	sndlen 7
	sndnote $19
	sndnote $20
	sndnote $16
	sndnote $20
	sndnote $19
	sndlen 14
	sndnote $20
	sndnote $16
	sndlen 7
	sndnote $20
	sndnote $16
	sndnote $20
	sndnote $16
	sndlen 14
	sndnote $19
	sndlen 7
	sndloopcnt $00, 2, .call5
	sndret
.call6:
	sndnote $1F
	sndlen 7
	sndnote $18
	sndnote $1F
	sndnote $16
	sndnote $26
	sndnote $22
	sndlen 14
	sndnote $1F
	sndnote $16
	sndlen 7
	sndnote $1F
	sndnote $16
	sndnote $1F
	sndnote $16
	sndlen 14
	sndnote $29
	sndnote $25
	sndlen 7
	sndnote $20
	sndnote $1B
	sndnote $17
	sndnote $16
	sndnote $12
	sndnote $17
	sndnote $1B
	sndnote $20
	sndnote $25
	sndnote $22
	sndnote $27
	sndnote $2C
	sndnote $2A
	sndnote $27
	sndret
.call7:
	sndnote $1F
	sndlen 7
	sndnote $18
	sndnote $1F
	sndnote $16
	sndnote $26
	sndnote $22
	sndlen 14
	sndnote $1F
	sndnote $16
	sndlen 7
	sndnote $1F
	sndnote $16
	sndnote $1F
	sndnote $13
	sndlen 14
	sndnote $27
	sndnote $25
	sndlen 7
	sndnote $20
	sndnote $1B
	sndnote $17
	sndnote $16
	sndnote $12
	sndnote $11
	sndnote $1D
	sndlen 5
	sndnote $18
	sndlen 4
	sndnote $1D
	sndlen 5
	sndnote $20
	sndnote $1B
	sndlen 4
	sndnote $1E
	sndlen 5
	sndnote $21
	sndnote $1D
	sndlen 4
	sndnote $21
	sndlen 5
	sndnote $22
	sndnote $27
	sndlen 4
	sndnote $29
	sndlen 5
	sndret
.call8:
	sndnote $2C
	sndlen 7
	sndnote $20
	sndnote $27
	sndnote $20
	sndloopcnt $00, 14, .call8
	sndret
.call9:
	sndnote $2C
	sndlen 7
	sndnote $20
	sndnote $25
	sndnote $20
	sndloopcnt $00, 6, .call9
	sndret
.call10:
	sndnote $2C
	sndlen 7
	sndnote $20
	sndnote $27
	sndnote $20
	sndloopcnt $00, 8, .call10
	sndnote $2A
	sndlen 7
	sndnote $1E
	sndnote $27
	sndnote $1E
	sndnote $27
	sndnote $1D
	sndnote $24
	sndnote $29
	sndnote $2C
	sndnote $20
	sndnote $2A
	sndnote $20
	sndnote $29
	sndnote $1E
	sndnote $25
	sndnote $1E
	sndret
SndData_BGM_Arashi_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH3R|SNDOUT_CH3L
	sndwave $04
	sndch3len $32
	sndcall .call0
	sndcall .call1
	sndcall .call2
	sndcall .call3
	sndcall .call2
	sndcall .call4
	sndcall .call5
	sndcall .call6
	sndcall .call5
	sndcall .call7
	sndcall .call8
	sndcall .call9
	sndcall .call8
	sndcall .call10
	sndloop SndData_BGM_Arashi_Ch3
.call0:
	sndnote $14
	sndlen 7
	sndnote $16
	sndnote $0F
	sndnote $16
	sndlen 14
	sndnote $14
	sndlen 7
	sndnote $1B
	sndlen 14
	sndnote $0F
	sndlen 7
	sndnote $13
	sndlen 14
	sndnote $0F
	sndlen 7
	sndnote $1B
	sndlen 14
	sndnote $19
	sndret
.call1:
	sndnote $14
	sndlen 7
	sndnote $16
	sndnote $0F
	sndnote $16
	sndlen 14
	sndnote $14
	sndlen 7
	sndnote $1B
	sndlen 14
	sndnote $0F
	sndlen 7
	sndnote $1B
	sndnote $1A
	sndnote $16
	sndnote $19
	sndnote $15
	sndnote $17
	sndnote $11
	sndret
.call2:
	sndnote $19
	sndlen 14
	sndnote $16
	sndlen 7
	sndnote $20
	sndlen 28
	sndnote $1B
	sndlen 21
	sndnote $1B
	sndlen 14
	sndnote $19
	sndch3len $00
	sndnote $25
	sndlen 42
	sndch3len $32
	sndnote $1D
	sndlen 7
	sndnote $25
	sndlen 14
	sndnote $20
	sndlen 7
	sndnote $11
	sndlen 14
	sndnote $1D
	sndlen 21
	sndnote $14
	sndlen 14
	sndnote $11
	sndlen 7
	sndret
.call3:
	sndch3len $00
	sndnote $1E
	sndlen 56
	sndnote $1B
	sndlen 21
	sndch3len $32
	sndnote $12
	sndlen 14
	sndnote $12
	sndlen 7
	sndnote $14
	sndch3len $00
	sndnote $17
	sndlen 56
	sndlenpre $07
	sndch3len $32
	sndnote $20
	sndnote $1D
	sndnote $14
	sndnote $1D
	sndnote $1C
	sndnote $12
	sndnote $17
	sndnote $1A
	sndret
.call4:
	sndnote $14
	sndlen 14
	sndnote $11
	sndlen 7
	sndnote $16
	sndlen 21
	sndnote $19
	sndlen 14
	sndnote $11
	sndlen 7
	sndnote $16
	sndlen 14
	sndnote $0E
	sndlen 7
	sndnote $1A
	sndlen 28
	sndnote $14
	sndlen 14
	sndnote $11
	sndlen 7
	sndnote $16
	sndlen 14
	sndnote $11
	sndlen 7
	sndnote $19
	sndlen 14
	sndnote $0F
	sndlen 7
	sndnote $1B
	sndlen 14
	sndnote $0E
	sndlen 7
	sndnote $1A
	sndlen 14
	sndnote $19
	sndret
.call5:
	sndnote $16
	sndlen 7
	sndnote $15
	sndnote $16
	sndnote $1D
	sndlen 14
	sndnote $16
	sndlen 7
	sndnote $16
	sndnote $15
	sndnote $16
	sndnote $1D
	sndlen 14
	sndnote $16
	sndlen 7
	sndnote $11
	sndnote $16
	sndnote $1D
	sndlen 14
	sndnote $19
	sndlen 7
	sndnote $14
	sndnote $19
	sndnote $20
	sndlen 14
	sndnote $14
	sndlen 7
	sndnote $19
	sndnote $14
	sndnote $19
	sndnote $20
	sndlen 14
	sndnote $14
	sndlen 7
	sndnote $14
	sndnote $1B
	sndnote $1D
	sndlen 14
	sndnote $18
	sndlen 7
	sndnote $13
	sndnote $18
	sndnote $1F
	sndlen 14
	sndnote $13
	sndlen 7
	sndnote $18
	sndnote $13
	sndnote $18
	sndnote $1F
	sndlen 14
	sndnote $13
	sndlen 7
	sndnote $13
	sndnote $16
	sndnote $1B
	sndlen 14
	sndret
.call6:
	sndnote $17
	sndlen 7
	sndnote $12
	sndnote $17
	sndnote $1E
	sndlen 14
	sndnote $12
	sndlen 7
	sndnote $23
	sndlen 14
	sndnote $17
	sndlen 7
	sndnote $22
	sndlen 14
	sndnote $17
	sndlen 7
	sndnote $1E
	sndnote $20
	sndnote $1B
	sndnote $12
	sndret
.call7:
	sndnote $17
	sndlen 7
	sndnote $12
	sndnote $17
	sndnote $1E
	sndlen 14
	sndnote $12
	sndlen 7
	sndnote $1B
	sndnote $1D
	sndlen 14
	sndnote $18
	sndnote $11
	sndnote $15
	sndlen 21
	sndret
.call8:
	sndnote $12
	sndlen 14
	sndnote $0D
	sndlen 7
	sndnote $12
	sndlen 14
	sndnote $0D
	sndlen 7
	sndnote $18
	sndnote $19
	sndlen 14
	sndnote $0D
	sndlen 7
	sndnote $19
	sndlen 14
	sndnote $0D
	sndlen 7
	sndnote $16
	sndlen 21
	sndnote $11
	sndlen 14
	sndnote $0C
	sndlen 7
	sndnote $11
	sndlen 14
	sndnote $0C
	sndlen 7
	sndnote $16
	sndnote $18
	sndlen 14
	sndnote $0C
	sndlen 7
	sndnote $18
	sndlen 14
	sndnote $0C
	sndlen 7
	sndnote $14
	sndlen 21
	sndret
.call9:
	sndnote $16
	sndlen 14
	sndnote $11
	sndlen 7
	sndnote $16
	sndlen 14
	sndnote $11
	sndlen 7
	sndnote $1B
	sndnote $1D
	sndlen 14
	sndnote $11
	sndlen 7
	sndnote $1D
	sndlen 14
	sndnote $11
	sndlen 7
	sndnote $19
	sndlen 21
	sndnote $16
	sndlen 14
	sndnote $11
	sndlen 7
	sndnote $16
	sndlen 14
	sndnote $11
	sndlen 7
	sndnote $19
	sndnote $1B
	sndlen 14
	sndnote $0F
	sndlen 7
	sndnote $1B
	sndlen 14
	sndnote $0F
	sndlen 7
	sndnote $16
	sndlen 21
	sndret
.call10:
	sndnote $1B
	sndlen 14
	sndnote $0F
	sndlen 7
	sndnote $19
	sndlen 14
	sndnote $0F
	sndlen 7
	sndnote $16
	sndlen 14
	sndnote $0F
	sndlen 7
	sndnote $0F
	sndnote $1B
	sndlen 14
	sndnote $0F
	sndlen 7
	sndnote $19
	sndlen 21
	sndnote $11
	sndlen 14
	sndnote $0C
	sndlen 7
	sndnote $11
	sndlen 14
	sndnote $0C
	sndlen 7
	sndnote $15
	sndlen 14
	sndnote $0C
	sndlen 7
	sndch3len $00
	sndnote $18
	sndlen 21
	sndnote $1B
	sndlen 3
	sndnote $1D
	sndlen 4
	sndnote $1B
	sndlen 3
	sndnote $1D
	sndlen 4
	sndnote $1B
	sndlen 3
	sndnote $1D
	sndlen 4
	sndnote $1B
	sndlen 7
	sndch3len $32
	sndret
SndData_BGM_Arashi_Ch4:
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndcall .call0
	sndcall .call1
	sndcall .call2
	sndcall .call3
	sndcall .call4
	sndcall .call5
	sndcall .call5
	sndloop SndData_BGM_Arashi_Ch4
.call0:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndch4 3, 0, 6
	sndlen 7
	sndch4 3, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
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
	sndret
.call1:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndch4 3, 0, 6
	sndlen 7
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
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndch4 3, 0, 6
	sndlen 7
	sndret
.call2:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndch4 3, 0, 6
	sndlen 7
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 3, SNDENV_DEC, 1
	sndch4 2, 0, 1
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndloopcnt $00, 6, .call2
	sndret
.call3:
	sndenv 6, SNDENV_DEC, 1
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
	sndlen 21
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndch4 3, 0, 6
	sndlen 7
	sndret
.call4:
	sndenv 6, SNDENV_DEC, 1
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
	sndlen 21
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
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
	sndret
.call5:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndch4 3, 0, 6
	sndlen 7
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
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
	sndlen 14
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndloopcnt $00, 7, .call5
	sndenv 6, SNDENV_DEC, 1
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
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
	sndch4 2, 0, 4
	sndlen 7
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 7
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 7
	sndret
