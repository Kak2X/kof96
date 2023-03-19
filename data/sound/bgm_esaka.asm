SndHeader_BGM_Esaka:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_Esaka_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_Esaka_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_Esaka_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_Esaka_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_BGM_Esaka_Ch1:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH1R|SNDOUT_CH1L
	sndnr11 3, 0
	sndnote $14
	sndlen 80
.main:
	sndenv 7, SNDENV_DEC, 7
	sndcall .call0
	sndcall .call1
	sndcall .call2
	sndcall .call3
	sndcall .call4
	sndcall .call5
	sndcall .call6
	sndcall .call7
	sndcall .call8
	sndloop .main
	;--
	; [TCRF] Unreferenced song section
	sndenv 7, SNDENV_DEC, 7 ;X
	sndnr11 3, 0 ;X
	sndnote $14 ;X
	sndlen 40 ;X
	sndnote $08 ;X
	sndlen 5 ;X
	sndnote $00 ;X
	sndnote $14 ;X
	sndlen 30 ;X
	;--
.call0:
	sndnote $14
	sndlen 10
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $0B
	sndnote $00
	sndnote $12
	sndlen 10
	sndnote $12
	sndlen 5
	sndnote $00
	sndnote $0B
	sndnote $00
	sndnote $14
	sndlen 10
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $17
	sndlen 80
	sndnote $17
	sndlen 10
	sndnote $17
	sndlen 5
	sndnote $00
	sndnote $0F
	sndnote $00
	sndnote $16
	sndlen 10
	sndnote $16
	sndlen 5
	sndnote $00
	sndnote $0F
	sndnote $00
	sndnote $17
	sndlen 10
	sndnote $17
	sndlen 5
	sndnote $00
	sndnote $19
	sndlen 80
	sndnote $19
	sndlen 10
	sndnote $19
	sndlen 5
	sndnote $00
	sndnote $14
	sndnote $00
	sndnote $1B
	sndlen 10
	sndnote $1B
	sndlen 5
	sndnote $00
	sndnote $14
	sndnote $00
	sndnote $19
	sndlen 10
	sndnote $19
	sndlen 5
	sndnote $00
	sndnote $1B
	sndlen 80
	sndret
.call1:
	sndnote $16
	sndlen 10
	sndnote $16
	sndlen 5
	sndnote $00
	sndnote $0F
	sndnote $00
	sndnote $17
	sndlen 10
	sndnote $17
	sndlen 5
	sndnote $00
	sndnote $0F
	sndnote $00
	sndnote $19
	sndlen 20
	sndret
.call2:
	sndenv 1, SNDENV_DEC, 1
	sndnote $01
	sndlen 60
	sndret
.call3:
	sndenv 7, SNDENV_INC, 0
	sndnote $20
	sndlen 10
	sndnote $1B
	sndnote $22
	sndnote $23
	sndlen 13
	sndnote $00
	sndlen 7
	sndnote $25
	sndlen 20
	sndnote $23
	sndlen 10
	sndnote $1E
	sndnote $20
	sndlen 30
	sndenv 1, SNDENV_DEC, 1
	sndnote $08
	sndlen 40
	sndenv 7, SNDENV_INC, 0
	sndnote $20
	sndlen 10
	sndnote $1B
	sndnote $22
	sndnote $23
	sndlen 13
	sndnote $00
	sndlen 7
	sndnote $25
	sndlen 20
	sndnote $23
	sndlen 10
	sndnote $22
	sndnote $20
	sndret
.call4:
	sndnote $23
	sndlen 40
	sndnote $00
	sndlen 10
	sndnote $23
	sndnote $22
	sndnote $23
	sndnote $22
	sndlen 20
	sndnote $00
	sndlen 10
	sndnote $25
	sndlen 30
	sndnote $1E
	sndlen 20
	sndnote $20
	sndlen 30
	sndenv 1, SNDENV_DEC, 1
	sndlen 60
	sndnote $0F
	sndlen 10
	sndnote $0D
	sndnote $0F
	sndnote $12
	sndnote $0F
	sndlen 20
	sndret
.call5:
	sndenv 7, SNDENV_INC, 0
	sndnote $1D
	sndlen 2
	sndnote $1E
	sndnote $20
	sndnote $22
	sndnote $23
	sndnote $25
	sndlen 30
	sndnote $00
	sndlen 10
	sndnote $25
	sndnote $20
	sndnote $23
	sndnote $25
	sndlen 13
	sndnote $00
	sndlen 7
	sndnote $25
	sndlen 10
	sndnote $23
	sndnote $25
	sndnote $20
	sndnote $2A
	sndlen 20
	sndnote $00
	sndlen 10
	sndnote $2A
	sndnote $20
	sndlen 20
	sndenv 1, SNDENV_DEC, 1
	sndnote $08
	sndlen 40
	sndlenpre $0A
	sndret
.call6:
	sndenv 1, SNDENV_DEC, 1
	sndnote $08
	sndlen 40
	sndenv 7, SNDENV_INC, 0
	sndnote $20
	sndlen 20
	sndnote $22
	sndnote $23
	sndlen 40
	sndnote $00
	sndlen 10
	sndnote $20
	sndnote $22
	sndnote $23
	sndnote $25
	sndlen 20
	sndnote $00
	sndlen 10
	sndnote $27
	sndlen 30
	sndnote $2A
	sndlen 20
	sndnote $29
	sndlen 30
	sndnote $00
	sndlen 10
	sndnote $29
	sndnote $27
	sndnote $29
	sndnote $2C
	sndlen 30
	sndnote $00
	sndlen 10
	sndnote $25
	sndlen 40
	sndnote $00
	sndlen 10
	sndret
.call7:
	sndenv 7, SNDENV_INC, 0
	sndnote $27
	sndlen 60
	sndnote $00
	sndlen 10
	sndnote $2E
	sndlenpre $3C
	sndnote $2A
	sndlen 10
	sndnote $2C
	sndlenpre $3C
	sndnote $00
	sndlen 10
	sndnote $2E
	sndlen 30
	sndnote $2C
	sndlen 20
	sndret
.call8:
	sndnote $2E
	sndlen 13
	sndnote $2F
	sndlen 14
	sndnote $31
	sndlen 13
	sndnote $33
	sndlen 40
	sndnote $00
	sndlen 10
	sndnote $33
	sndnote $2A
	sndnote $2C
	sndlen 30
	sndnote $2A
	sndlen 20
	sndnote $2C
	sndlen 10
	sndnote $2A
	sndnote $29
	sndnote $2A
	sndlen 30
	sndnote $00
	sndlen 10
	sndnote $2C
	sndlen 30
	sndnote $29
	sndlen 20
	sndnote $00
	sndlen 10
	sndnote $2E
	sndnote $2F
	sndnote $31
	sndnote $36
	sndlen 13
	sndnote $35
	sndlen 14
	sndnote $31
	sndlen 13
	sndnote $33
	sndlen 80
	sndret
SndData_BGM_Esaka_Ch2:
	sndenv 6, SNDENV_DEC, 2
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 2, 0
.main:
	sndcall .call0
	sndcall .call1
	sndcall .call2
	sndenv 5, SNDENV_INC, 0
	sndnote $14
	sndlen 10
	sndnote $19
	sndnote $1A
	sndcall .call3
	sndcall .call4
	sndcall .call3
	sndcall .call5
	sndloop .main
.call0:
	sndenv 6, SNDENV_DEC, 2
	sndnr21 2, 0
	sndnote $2C
	sndlen 10
	sndnote $27
	sndnote $33
	sndnote $27
	sndnote $2F
	sndnote $27
	sndnote $31
	sndnote $27
	sndnote $2F
	sndnote $27
	sndnote $2E
	sndnote $27
	sndnote $31
	sndnote $27
	sndnote $2E
	sndnote $27
	sndloopcnt $00, 4, .call0
	sndret
.call1:
	sndenv 6, SNDENV_DEC, 7
	sndnr21 0, 0
	sndnote $12
	sndlen 10
	sndnote $12
	sndlen 5
	sndnote $00
	sndnote $0B
	sndnote $00
	sndnote $14
	sndlen 30
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $14
	sndnote $00
	sndnote $14
	sndlen 10
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $0B
	sndnote $00
	sndnote $14
	sndlen 10
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $14
	sndnote $00
	sndnote $0B
	sndlen 10
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $12
	sndlen 10
	sndnote $12
	sndlen 5
	sndnote $00
	sndnote $0B
	sndnote $00
	sndnote $14
	sndlen 30
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $14
	sndnote $00
	sndnote $14
	sndlen 10
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $0B
	sndnote $00
	sndnote $14
	sndlen 10
	sndnote $14
	sndlen 5
	sndnote $00
	sndnote $14
	sndnote $00
	sndnote $16
	sndlen 20
	sndnote $17
	sndnote $0F
	sndlen 5
	sndnote $00
	sndnote $17
	sndlen 15
	sndnote $00
	sndlen 5
	sndnote $17
	sndlen 10
	sndnote $0F
	sndlen 5
	sndnote $00
	sndnote $17
	sndlen 10
	sndnote $12
	sndlen 20
	sndnote $06
	sndlen 5
	sndnote $00
	sndnote $12
	sndlen 30
	sndnote $0D
	sndlen 20
	sndnote $14
	sndlen 10
	sndnote $12
	sndnote $14
	sndenv 1, SNDENV_DEC, 1
	sndnote $08
	sndlen 20
	sndenv 6, SNDENV_DEC, 7
	sndnote $14
	sndlen 10
	sndnote $12
	sndnote $14
	sndnote $00
	sndnote $20
	sndnote $1E
	sndnote $20
	sndnote $23
	sndnote $20
	sndlen 20
	sndnote $00
	sndlen 10
	sndret
.call2:
	sndnote $12
	sndlen 20
	sndnote $06
	sndlen 5
	sndnote $00
	sndnote $12
	sndlen 30
	sndnote $06
	sndlen 5
	sndnote $00
	sndnote $12
	sndlen 10
	sndnote $06
	sndlen 10
	sndnote $12
	sndnote $06
	sndlen 5
	sndnote $00
	sndnote $06
	sndnote $00
	sndnote $12
	sndlen 10
	sndnote $12
	sndlen 5
	sndnote $00
	sndnote $06
	sndlen 10
	sndnote $13
	sndnote $12
	sndlen 10
	sndnote $14
	sndnote $08
	sndlen 2
	sndnote $00
	sndlen 8
	sndnote $08
	sndlen 2
	sndnote $00
	sndlen 8
	sndnote $17
	sndlen 10
	sndnote $14
	sndnote $08
	sndlen 2
	sndnote $00
	sndlen 8
	sndnote $12
	sndlen 10
	sndlenpre $0A
	sndnote $14
	sndnote $00
	sndnote $06
	sndlen 2
	sndnote $00
	sndlen 8
	sndnote $14
	sndlen 20
	sndnote $16
	sndnote $10
	sndlen 40
	sndnote $10
	sndlen 10
	sndnote $0B
	sndlen 5
	sndnote $00
	sndnote $0B
	sndnote $00
	sndnote $10
	sndlen 10
	sndlenpre $0A
	sndnote $0B
	sndlen 5
	sndnote $00
	sndnote $0B
	sndlen 2
	sndnote $00
	sndlen 8
	sndnote $17
	sndlen 20
	sndnote $0B
	sndlen 10
	sndnote $17
	sndlen 20
	sndnote $16
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndnote $0A
	sndlen 5
	sndnote $0A
	sndnote $0A
	sndnote $0A
	sndenv 6, SNDENV_DEC, 7
	sndnote $16
	sndlen 20
	sndnote $0A
	sndlen 2
	sndnote $00
	sndlen 8
	sndnote $0A
	sndlen 2
	sndnote $00
	sndlen 8
	sndnote $19
	sndlen 20
	sndnote $0D
	sndlen 2
	sndnote $00
	sndlen 8
	sndnote $0D
	sndlen 2
	sndnote $00
	sndlen 8
	sndnote $19
	sndlen 20
	sndret
.call3:
	sndnote $1B
	sndlen 40
	sndlenpre $0A
	sndnote $0F
	sndlen 5
	sndnote $00
	sndnote $1B
	sndlen 10
	sndnote $19
	sndlen 60
	sndnote $0D
	sndlen 2
	sndnote $00
	sndlen 8
	sndnote $19
	sndlen 10
	sndnote $17
	sndlenpre $28
	sndnote $0B
	sndlen 10
	sndnote $0B
	sndlen 5
	sndnote $00
	sndnote $17
	sndlen 10
	sndret
.call4:
	sndnote $19
	sndlen 10
	sndlenpre $28
	sndnote $16
	sndlen 13
	sndnote $12
	sndlen 14
	sndnote $12
	sndlen 13
	sndret
.call5:
	sndnote $19
	sndlen 40
	sndnote $0D
	sndlen 2
	sndnote $00
	sndlen 8
	sndnote $1E
	sndlen 10
	sndnote $1B
	sndlen 20
	sndnote $19
	sndlen 10
	sndret
SndData_BGM_Esaka_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH3R|SNDOUT_CH3L
	sndwave $04
	sndch3len $01
.main:
	sndch3len $19
	sndnotebase $0C
	sndcall .call0
	sndnotebase $F4
	sndcall .call1
	sndcall .call2
	sndcall .call3
	sndcall .call4
	sndcall .call5
	sndcall .call4
	sndcall .call6
	sndloop .main
.call0:
	sndnote $08
	sndlen 10
	sndloopcnt $00, 56, .call0
	sndch3len $5A
	sndnote $0A
	sndlen 20
	sndnote $03
	sndlen 10
	sndnote $0B
	sndlen 20
	sndnote $03
	sndlen 10
	sndnote $0D
	sndlen 20
	sndret
.call1:
	sndch3len $3C
	sndnote $06
	sndlen 10
	sndnote $08
	sndlen 20
	sndnote $08
	sndlen 30
	sndnote $08
	sndlen 10
	sndnote $08
	sndch3len $1E
	sndnote $08
	sndnote $08
	sndnote $03
	sndnote $08
	sndnote $08
	sndnote $08
	sndnote $0B
	sndnote $06
	sndch3len $3C
	sndnote $06
	sndlen 10
	sndnote $06
	sndlen 20
	sndnote $08
	sndlen 30
	sndnote $08
	sndlen 10
	sndnote $08
	sndch3len $1E
	sndnote $08
	sndnote $08
	sndnote $03
	sndnote $08
	sndnote $03
	sndnote $08
	sndnote $0A
	sndlen 20
	sndnote $0B
	sndlen 10
	sndnote $0B
	sndnote $03
	sndnote $0B
	sndnote $0B
	sndnote $03
	sndnote $0B
	sndnote $06
	sndlen 20
	sndnote $06
	sndlen 10
	sndnote $06
	sndnote $06
	sndnote $06
	sndnote $05
	sndnote $06
	sndnote $01
	sndnote $08
	sndnote $08
	sndnote $08
	sndlen 30
	sndnote $08
	sndlen 10
	sndnote $08
	sndnote $08
	sndlen 20
	sndch3len $3C
	sndnote $14
	sndlen 10
	sndnote $12
	sndnote $14
	sndnote $17
	sndnote $14
	sndlen 30
	sndret
.call2:
	sndch3len $19
	sndnote $12
	sndlen 10
	sndnote $06
	sndnote $06
	sndnote $12
	sndnote $06
	sndnote $06
	sndnote $06
	sndnote $12
	sndnote $06
	sndnote $06
	sndnote $12
	sndnote $06
	sndnote $06
	sndnote $05
	sndnote $06
	sndnote $07
	sndch3len $3C
	sndnote $19
	sndnote $1B
	sndlen 30
	sndnote $1E
	sndlen 10
	sndnote $1B
	sndlen 20
	sndnote $19
	sndret
.call3:
	sndnote $1B
	sndlen 30
	sndnote $14
	sndlen 20
	sndnote $16
	sndch3len $28
	sndnote $04
	sndlen 10
	sndnote $04
	sndnote $0B
	sndnote $04
	sndlen 20
	sndnote $04
	sndlen 10
	sndnote $08
	sndnote $04
	sndlen 20
	sndnote $04
	sndlen 10
	sndnote $04
	sndnote $0B
	sndlen 20
	sndnote $06
	sndlen 10
	sndnote $0B
	sndnote $06
	sndnote $0A
	sndlen 10
	sndnote $0A
	sndlen 20
	sndnote $0A
	sndnote $05
	sndlen 10
	sndnote $0A
	sndnote $0D
	sndlen 20
	sndnote $0D
	sndnote $0D
	sndnote $08
	sndlen 10
	sndnote $0D
	sndnote $0E
	sndret
.call4:
	sndch3len $14
	sndnote $0F
	sndlen 10
	sndnote $0F
	sndlen 5
	sndnote $0F
	sndnote $0F
	sndlen 10
	sndnote $0F
	sndlen 5
	sndnote $0F
	sndnote $0F
	sndlen 10
	sndnote $0F
	sndlen 5
	sndnote $0F
	sndnote $0F
	sndlen 10
	sndch3len $3C
	sndnote $0D
	sndlen 20
	sndch3len $14
	sndnote $0D
	sndlen 5
	sndnote $0D
	sndnote $0D
	sndlen 10
	sndnote $0D
	sndlen 5
	sndnote $0D
	sndnote $0D
	sndlen 10
	sndnote $0D
	sndlen 5
	sndnote $0D
	sndnote $0D
	sndlen 10
	sndch3len $3C
	sndnote $0B
	sndlen 20
	sndch3len $14
	sndnote $0B
	sndlen 5
	sndnote $0B
	sndnote $0B
	sndlen 10
	sndnote $0B
	sndlen 5
	sndnote $0B
	sndnote $0B
	sndlen 10
	sndnote $0B
	sndlen 5
	sndnote $0B
	sndnote $0B
	sndlen 10
	sndret
.call5:
	sndch3len $3C
	sndnote $0D
	sndlen 20
	sndch3len $14
	sndnote $0D
	sndlen 5
	sndnote $0D
	sndnote $0D
	sndlen 10
	sndnote $0D
	sndlen 5
	sndnote $0D
	sndch3len $3C
	sndnote $16
	sndlen 13
	sndnote $06
	sndlen 14
	sndnote $06
	sndlen 13
	sndret
.call6:
	sndch3len $3C
	sndnote $0D
	sndlen 20
	sndnote $01
	sndlen 10
	sndnote $0D
	sndnote $0D
	sndnote $0F
	sndnote $0F
	sndlen 20
	sndnote $0D
	sndlen 10
	sndch3len $19
	sndret
SndData_BGM_Esaka_Ch4:
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
.main:
	sndcall .call0
	sndcall .call1
	sndcall .call2
	sndcall .call3
	sndcall .call4
	sndcall .call3
	sndcall .call5
	sndcall .call6
	sndcall .call7
	sndcall .call8
	sndloop .main
.call0:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
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
	sndlen 20
	sndloopcnt $00, 3, .call0
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
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
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 10
	sndch4 2, 0, 4
	sndlen 10
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 3
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 4
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 3
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndret
.call1:
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndch4 2, 0, 4
	sndlen 20
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 30
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndenv 5, SNDENV_DEC, 3
	sndch4 1, 0, 1
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 20
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndch4 2, 0, 4
	sndlen 10
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndret
.call2:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
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
	sndlen 20
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 20
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
	sndlen 5
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 3
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 4
	sndch4 2, 0, 4
	sndlen 3
	sndch4 2, 0, 4
	sndlen 10
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
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndret
.call3:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
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
	sndlen 10
	sndloopcnt $00, 2, .call3
	sndret
.call4:
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
	sndlen 20
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
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
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 10
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 10
	sndret
.call5:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 5
	sndch4 3, 0, 6
	sndlen 15
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
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
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
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndch4 2, 0, 4
	sndlen 3
	sndch4 2, 0, 4
	sndlen 4
	sndch4 2, 0, 4
	sndlen 3
	sndch4 2, 0, 4
	sndlen 10
	sndret
.call6:
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
	sndloopcnt $00, 3, .call6
	sndret
.call7:
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
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 13
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 14
	sndch4 3, 0, 6
	sndlen 13
	sndret
.call8:
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
	sndloopcnt $00, 2, .call8
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
	sndch4 3, 0, 6
	sndlen 10
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 10
	sndch4 3, 0, 6
	sndlen 20
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
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 20
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 10
	sndret
