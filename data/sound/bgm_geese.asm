SndHeader_BGM_Geese:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_Geese_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_Geese_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_Geese_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_Geese_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_BGM_Geese_Ch1:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH1R|SNDOUT_CH1L
	sndnr11 3, 0
	sndcall .intro
.main:
	sndcall .call1
	sndcall .call2
	sndcall .call3
	sndcall .call2
	sndcall .call4
	sndcall .call5
	sndcall .call6
	sndcall .call7
	sndcall .call6
	sndcall .call8
	sndloop .main
.intro:
	sndnote $14
	sndlen 60
	sndnote $00
	sndlen 10
	sndnote $14
	sndnote $00
	sndnote $14
	sndnote $14
	sndlen 20
	sndnote $0D
	sndnote $0F
	sndloopcnt $00, 2, .intro
	sndret
.call1:
	sndenv 7, SNDENV_DEC, 7
	sndnote $14
	sndlen 60
	sndnote $00
	sndlen 10
	sndnote $14
	sndnote $00
	sndnote $14
	sndnote $14
	sndlen 20
	sndnote $0D
	sndnote $0F
	sndnote $14
	sndlen 60
	sndnote $00
	sndlen 10
	sndnote $17
	sndnote $00
	sndnote $17
	sndnote $17
	sndlen 20
	sndnote $19
	sndnote $1B
	sndret
.call2:
	sndenv 7, SNDENV_INC, 0
	sndnote $23
	sndlen 30
	sndnote $22
	sndnote $1E
	sndlen 5
	sndnote $00
	sndnote $1C
	sndlen 40
	sndlenpre $0A
	sndnote $1C
	sndnote $1E
	sndnote $20
	sndlen 20
	sndnote $1E
	sndlen 30
	sndnote $20
	sndnote $1C
	sndlen 20
	sndlenpre $50
	sndret
.call3:
	sndnote $23
	sndlen 30
	sndnote $22
	sndnote $1E
	sndlen 20
	sndnote $1C
	sndlen 30
	sndnote $22
	sndnote $1E
	sndlen 10
	sndnote $25
	sndlenpre $1E
	sndnote $24
	sndnote $20
	sndlen 20
	sndlenpre $50
	sndret
.call4:
	sndnote $1B
	sndlen 30
	sndnote $1C
	sndnote $1E
	sndlen 10
	sndnote $20
	sndlenpre $14
	sndnote $00
	sndnote $25
	sndlen 13
	sndnote $24
	sndlen 14
	sndnote $20
	sndlen 13
	sndnote $23
	sndlen 20
	sndnote $00
	sndlen 10
	sndnote $22
	sndlen 30
	sndnote $1E
	sndlen 10
	sndnote $20
	sndlenpre $50
	sndret
.call5:
	sndnr11 2, 0
	sndnote $15
	sndlen 60
	sndnote $1C
	sndlen 20
	sndnote $1B
	sndnote $19
	sndnote $17
	sndnote $19
	sndnote $18
	sndlen 60
	sndnote $20
	sndlen 20
	sndnote $1E
	sndnote $1C
	sndnote $1B
	sndnote $19
	sndnote $1C
	sndlen 60
	sndnote $1B
	sndlen 20
	sndnote $1E
	sndlen 13
	sndnote $24
	sndlen 14
	sndnote $25
	sndlen 13
	sndnote $24
	sndnote $21
	sndlen 14
	sndnote $20
	sndlen 13
	sndnote $24
	sndlen 80
	sndnote $25
	sndlen 30
	sndnote $27
	sndlen 40
	sndlenpre $0A
	sndret
.call6:
	sndnr11 3, 0
	sndnote $19
	sndlen 13
	sndnote $1C
	sndlen 14
	sndnote $20
	sndlen 13
	sndnote $22
	sndnote $23
	sndlen 14
	sndnote $25
	sndlen 13
	sndnote $22
	sndlen 80
	sndret
.call7:
	sndnote $21
	sndlen 13
	sndnote $1C
	sndlen 14
	sndnote $1B
	sndlen 13
	sndnote $19
	sndnote $1B
	sndlen 14
	sndnote $20
	sndlen 13
	sndlenpre $50
	sndret
.call8:
	sndnote $21
	sndlen 13
	sndnote $20
	sndlen 14
	sndnote $23
	sndlen 13
	sndnote $21
	sndnote $27
	sndlen 14
	sndnote $28
	sndlen 13
	sndlenpre $50
	sndnote $27
	sndlen 20
	sndnote $20
	sndlen 5
	sndnote $00
	sndnote $28
	sndlen 20
	sndnote $21
	sndlen 5
	sndnote $00
	sndnote $2A
	sndlen 20
	sndnote $2C
	sndlen 13
	sndnote $28
	sndlen 14
	sndnote $27
	sndlen 13
	sndnote $25
	sndnote $24
	sndlen 14
	sndnote $27
	sndlen 13
	sndnote $28
	sndlen 80
	sndlenpre $50
	sndenv 1, SNDENV_DEC, 1
	sndnote $01
	sndlen 80
	sndlenpre $50
	sndret
SndData_BGM_Geese_Ch2:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 1, 0
	sndcall .call0
	sndcall .call1
	sndcall .call2
	sndloop SndData_BGM_Geese_Ch2
.call0:
	sndnote $0D
	sndlen 20
	sndnote $0F
	sndlen 10
	sndnote $0D
	sndlen 20
	sndnote $0F
	sndlen 10
	sndnote $0D
	sndlen 20
	sndnote $0F
	sndlen 10
	sndnote $0D
	sndlen 20
	sndnote $0F
	sndlen 10
	sndnote $10
	sndlen 20
	sndnote $12
	sndloopcnt $00, 13, .call0
	sndret
.call1:
	sndnote $0C
	sndlen 20
	sndnote $0F
	sndlen 10
	sndnote $0C
	sndlen 20
	sndnote $0F
	sndlen 10
	sndnote $0C
	sndlen 20
	sndnote $0F
	sndlen 10
	sndnote $0C
	sndlen 20
	sndnote $0F
	sndlen 10
	sndnote $14
	sndlen 20
	sndnote $15
	sndnote $12
	sndnote $14
	sndlen 10
	sndnote $12
	sndlen 20
	sndnote $14
	sndlen 10
	sndnote $12
	sndlen 20
	sndnote $14
	sndlen 10
	sndnote $12
	sndlen 20
	sndnote $14
	sndlen 10
	sndnote $10
	sndlen 20
	sndnote $12
	sndnote $0C
	sndnote $0F
	sndlen 10
	sndnote $0C
	sndlen 20
	sndnote $0F
	sndlen 10
	sndnote $0C
	sndlen 20
	sndnote $0F
	sndlen 10
	sndnote $0C
	sndlen 20
	sndnote $0F
	sndlen 10
	sndnote $18
	sndlen 20
	sndnote $1B
	sndret
.call2:
	sndenv 6, SNDENV_DEC, 2
	sndnr21 0, 0
	sndnote $14
	sndlen 5
	sndnote $1C
	sndnote $19
	sndnote $14
	sndnote $1E
	sndnote $1C
	sndnote $14
	sndnote $1C
	sndloopcnt $00, 16, .call2
	sndenv 7, SNDENV_DEC, 7
	sndnr21 1, 0
	sndnote $18
	sndlen 20
	sndnote $0C
	sndlen 10
	sndnote $19
	sndlen 20
	sndnote $0D
	sndlen 10
	sndnote $18
	sndlen 20
	sndnote $0C
	sndlen 13
	sndnote $19
	sndlen 14
	sndnote $1E
	sndlen 13
	sndnote $20
	sndnote $27
	sndlen 14
	sndnote $2A
	sndlen 13
	sndret
SndData_BGM_Geese_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH3R|SNDOUT_CH3L
	sndwave $02
	sndch3len $19
	sndcall .call0
	sndcall .call1
	sndcall .call2
	sndcall .call1
	sndcall .call3
	sndcall .call4
	sndnotebase $FC
	sndcall .call4
	sndnotebase $04
	sndcall .call4
	sndnotebase $FC
	sndcall .call4
	sndnotebase $04
	sndcall .call5
	sndloop SndData_BGM_Geese_Ch3
.call0:
	sndnote $0D
	sndlen 10
	sndnote $0D
	sndlen 5
	sndnote $0D
	sndnote $0D
	sndlen 10
	sndnote $0D
	sndnote $0D
	sndlen 5
	sndnote $0D
	sndnote $0D
	sndlen 10
	sndnote $0D
	sndnote $0D
	sndlen 5
	sndnote $0D
	sndnote $0D
	sndlen 10
	sndnote $0D
	sndnote $0D
	sndlen 5
	sndnote $0D
	sndnote $0D
	sndlen 10
	sndnote $09
	sndnote $09
	sndlen 5
	sndnote $09
	sndnote $0B
	sndlen 10
	sndnote $0B
	sndlen 5
	sndnote $0B
	sndloopcnt $00, 12, .call0
	sndret
.call1:
	sndnote $09
	sndlen 10
	sndnote $09
	sndlen 5
	sndnote $09
	sndnote $09
	sndlen 10
	sndnote $09
	sndlen 5
	sndnote $09
	sndnote $09
	sndlen 10
	sndnote $06
	sndnote $08
	sndch3len $3C
	sndnote $09
	sndlen 20
	sndch3len $1E
	sndnote $06
	sndlen 10
	sndnote $08
	sndnote $09
	sndnote $0B
	sndnote $09
	sndnote $06
	sndnote $01
	sndch3len $19
	sndnote $08
	sndlen 10
	sndnote $08
	sndlen 5
	sndnote $08
	sndnote $14
	sndlen 10
	sndnote $08
	sndlen 5
	sndnote $08
	sndnote $08
	sndlen 10
	sndnote $03
	sndnote $08
	sndnote $0D
	sndret
.call2:
	sndnote $18
	sndlen 10
	sndnote $24
	sndnote $14
	sndnote $20
	sndlen 5
	sndnote $18
	sndnote $0F
	sndlen 10
	sndnote $0F
	sndnote $0D
	sndlen 5
	sndnote $0F
	sndnote $10
	sndlen 10
	sndret
.call3:
	sndnote $27
	sndlen 5
	sndnote $25
	sndnote $24
	sndnote $21
	sndnote $20
	sndnote $1E
	sndnote $1C
	sndnote $1B
	sndnote $19
	sndnote $18
	sndnote $19
	sndnote $1B
	sndnote $1C
	sndnote $1E
	sndnote $20
	sndnote $1A
	sndret
.call4:
	sndnote $19
	sndlen 5
	sndnote $19
	sndnote $19
	sndnote $19
	sndnote $25
	sndlen 10
	sndnote $19
	sndlen 5
	sndnote $19
	sndloopcnt $00, 4, .call4
	sndret
.call5:
	sndch3len $1E
	sndnote $14
	sndlen 10
	sndnote $14
	sndnote $08
	sndnote $15
	sndnote $15
	sndnote $09
	sndnote $14
	sndnote $14
	sndnote $08
	sndlen 13
	sndnote $12
	sndlen 14
	sndnote $14
	sndlen 13
	sndnote $1B
	sndnote $18
	sndlen 14
	sndnote $12
	sndlen 13
	sndret
SndData_BGM_Geese_Ch4:
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndcall .call0
	sndcall .call1
	sndcall .call0
	sndcall .call2
	sndcall .call0
	sndcall .call1
	sndcall .call0
	sndcall .call2
	sndcall .call0
	sndcall .call1
	sndcall .call0
	sndcall .call3
	sndcall .call4
	sndcall .call5
	sndcall .call3
	sndcall .call6
	sndloop SndData_BGM_Geese_Ch4
.call0:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 15
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndloopcnt $00, 7, .call0
	sndret
.call1:
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
	sndch4 2, 0, 4
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
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
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndret
.call3:
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
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
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndret
.call4:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 15
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndloopcnt $00, 7, .call4
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
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 5
	sndch4 2, 0, 6
	sndlen 5
	sndch4 2, 0, 6
	sndlen 5
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 5
	sndch4 1, 0, 0
	sndlen 5
	sndch4 1, 0, 0
	sndlen 5
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 5
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
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndret
.call5:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 5
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
	sndloopcnt $00, 15, .call5
	sndret
.call6:
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 10
	sndloopcnt $00, 4, .call6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndch4 2, 0, 4
	sndlen 10
	sndch4 2, 0, 4
	sndlen 10
	sndch4 2, 0, 4
	sndlen 10
	sndret
