SndHeader_BGM_MrKarateCutscene:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_MrKarateCutscene_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_MrKarateCutscene_Ch2 ; Data ptr
	db $F9 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_MrKarateCutscene_Ch3 ; Data ptr
	db $0C ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_MrKarateCutscene_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_BGM_MrKarateCutscene_Ch1:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH1R|SNDOUT_CH1L
	sndnr11 3, 0
	sndcall .call0
	sndloop SndData_BGM_MrKarateCutscene_Ch1
.call0:
	sndnote $22
	sndlen 12
	sndnote $22
	sndnote $14
	sndlen 3
	sndnote $00
	sndnote $14
	sndlen 6
	sndnote $14
	sndlen 3
	sndnote $00
	sndnote $14
	sndlen 6
	sndnote $25
	sndlen 24
	sndnote $14
	sndlen 6
	sndnote $00
	sndnote $14
	sndlen 12
	sndnote $22
	sndlen 12
	sndnote $22
	sndnote $14
	sndlen 3
	sndnote $00
	sndnote $14
	sndlen 6
	sndnote $14
	sndlen 3
	sndnote $00
	sndnote $14
	sndlen 6
	sndnote $26
	sndlen 24
	sndnote $14
	sndlen 6
	sndnote $00
	sndnote $14
	sndlen 12
	sndnote $22
	sndlen 12
	sndnote $22
	sndnote $14
	sndlen 3
	sndnote $00
	sndnote $14
	sndlen 6
	sndnote $14
	sndlen 3
	sndnote $00
	sndnote $14
	sndlen 6
	sndnote $28
	sndlen 24
	sndnote $14
	sndlen 6
	sndnote $00
	sndnote $14
	sndlen 12
	sndnote $22
	sndlen 12
	sndnote $22
	sndnote $14
	sndlen 3
	sndnote $00
	sndlen 9
	sndnote $29
	sndlen 24
	sndnote $14
	sndlen 6
	sndnote $00
	sndnote $2A
	sndlen 24
	sndloopcnt $00, 2, .call0
	sndnote $20
	sndlen 12
	sndnote $1F
	sndnote $1E
	sndnote $1F
	sndnote $1E
	sndnote $1D
	sndnote $1C
	sndlen 24
	sndret
SndData_BGM_MrKarateCutscene_Ch2:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 1, 0
	sndcall SndData_BGM_MrKarateCutscene_Ch1.call0
	sndloop SndData_BGM_MrKarateCutscene_Ch2
SndData_BGM_MrKarateCutscene_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH3R|SNDOUT_CH3L
	sndwave $02
	sndch3len $5A
	sndnote $08
	sndlen 12
	sndnote $08
	sndlen 24
	sndnote $08
	sndlen 12
	sndnote $0B
	sndlen 36
	sndnote $08
	sndlen 12
	sndnote $08
	sndlen 12
	sndnote $08
	sndlen 24
	sndnote $08
	sndlen 12
	sndnote $0C
	sndlen 36
	sndnote $08
	sndlen 12
	sndnote $08
	sndlen 12
	sndnote $08
	sndlen 24
	sndnote $08
	sndlen 12
	sndnote $0E
	sndlen 36
	sndnote $08
	sndlen 12
	sndnote $08
	sndlen 12
	sndnote $08
	sndnote $08
	sndnote $0F
	sndlen 24
	sndnote $08
	sndlen 12
	sndnote $10
	sndlen 24
	sndloopcnt $00, 2, SndData_BGM_MrKarateCutscene_Ch3
	sndnote $0F
	sndlen 12
	sndnote $0E
	sndnote $0D
	sndnote $0E
	sndnote $0D
	sndnote $0C
	sndlen 36
	sndloop SndData_BGM_MrKarateCutscene_Ch3
SndData_BGM_MrKarateCutscene_Ch4:
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndcall .call0
	sndcall .call0
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 6
	sndch4 2, 0, 4
	sndlen 12
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 12
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 12
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 24
	sndloop SndData_BGM_MrKarateCutscene_Ch4
.call0:
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 12
	sndch4 3, 0, 6
	sndlen 24
	sndch4 3, 0, 6
	sndlen 6
	sndch4 3, 0, 6
	sndlen 6
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 36
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 12
	sndloopcnt $00, 3, .call0
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 12
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 12
	sndch4 3, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 12
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 12
	sndch4 3, 0, 6
	sndlen 12
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 12
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 12
	sndret
