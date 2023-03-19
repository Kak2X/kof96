SndHeader_BGM_StageClear:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_StageClear_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_StageClear_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_StageClear_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_StageClear_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_BGM_StageClear_Ch1:
	sndenv 7, SNDENV_DEC, 7
	sndenach SNDOUT_CH1R|SNDOUT_CH1L
	sndnr11 3, 0
	sndnote $0D
	sndlen 14
	sndnote $01
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $0B
	sndlen 14
	sndnote $0B
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $14
	sndlen 56
	sndnote $08
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $14
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $15
	sndlen 14
	sndnote $09
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $14
	sndlen 21
	sndnote $12
	sndlen 14
	sndnote $15
	sndlen 14
	sndnote $09
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $14
	sndlen 21
	sndnote $12
	sndlen 14
	sndnote $0D
	sndlen 14
	sndnote $0F
	sndendch
SndData_BGM_StageClear_Ch2:
	sndenv 6, SNDENV_DEC, 7
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 1, 0
	sndnote $14
	sndlen 14
	sndnote $00
	sndlen 7
	sndnote $12
	sndlen 14
	sndnote $00
	sndlen 7
	sndnote $19
	sndlen 28
	sndnote $19
	sndlen 5
	sndnote $17
	sndlen 4
	sndnote $14
	sndlen 5
	sndnote $17
	sndnote $14
	sndlen 4
	sndnote $12
	sndlen 5
	sndnote $14
	sndnote $0F
	sndlen 4
	sndnote $0B
	sndlen 5
	sndnote $1A
	sndlen 14
	sndnote $00
	sndlen 7
	sndnote $19
	sndlen 21
	sndnote $17
	sndlen 14
	sndnote $1A
	sndnote $00
	sndlen 7
	sndnote $19
	sndlen 21
	sndnote $17
	sndlen 14
	sndnote $12
	sndnote $14
	sndendch
SndData_BGM_StageClear_Ch3:
	sndenvch3 2
	sndenach SNDOUT_CH3R|SNDOUT_CH3L
	sndwave $04
	sndch3len $32
	sndnote $14
	sndlen 21
	sndnote $12
	sndnote $0D
	sndnote $0D
	sndlen 7
	sndnote $0B
	sndnote $08
	sndnote $0B
	sndnote $0D
	sndnote $08
	sndnote $14
	sndnote $12
	sndlen 14
	sndnote $12
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $14
	sndlen 21
	sndnote $15
	sndlen 14
	sndnote $12
	sndlen 14
	sndnote $12
	sndlen 3
	sndnote $00
	sndlen 4
	sndnote $14
	sndlen 21
	sndnote $15
	sndlen 14
	sndch3len $1E
	sndnote $14
	sndnote $14
	sndendch
SndData_BGM_StageClear_Ch4:
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 3
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
	sndch4 3, 0, 6
	sndlen 7
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 3
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 4
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 7
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
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndenv 6, SNDENV_DEC, 1
	sndch4 3, 0, 6
	sndlen 4
	sndch4 3, 0, 6
	sndlen 5
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 5
	sndch4 2, 0, 4
	sndlen 4
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 5
	sndenv 3, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 5
	sndenv 4, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 4
	sndenv 5, SNDENV_DEC, 4
	sndch4 2, 0, 6
	sndlen 5
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
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 7
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
	sndlen 7
	sndch4 3, 0, 6
	sndlen 7
	sndenv 6, SNDENV_DEC, 2
	sndch4 2, 0, 4
	sndlen 14
	sndch4 2, 0, 4
	sndlen 14
	sndendch

