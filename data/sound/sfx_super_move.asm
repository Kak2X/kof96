SndHeader_SFX_SuperMove:
	db $03 ; Number of channels
.ch2:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_SFX_SuperMove_Ch2 ; Data ptr
	db $0C ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_SFX_SuperMove_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_SuperMove_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_SuperMove_Ch2:
	sndenv 9, SNDENV_DEC, 4
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 1, 0
	sndnote $00
	sndlen 6
	sndnote $22
	sndlen 2
	sndnote $2E
	sndlen 6
	sndenv 7, SNDENV_DEC, 7
	sndnote $22
	sndlen 1
	sndnote $2E
	sndlen 5
	sndenv 5, SNDENV_DEC, 7
	sndnote $22
	sndlen 1
	sndnote $2E
	sndlen 5
	sndenv 3, SNDENV_DEC, 7
	sndnote $22
	sndlen 1
	sndnote $2E
	sndlen 5
	sndenv 2, SNDENV_DEC, 7
	sndnote $22
	sndlen 1
	sndnote $2E
	sndlen 29
	sndendch
SndData_SFX_SuperMove_Ch3:
	sndenvch3 2
	sndendch
SndData_SFX_SuperMove_Ch4:
	sndenv 15, SNDENV_DEC, 2
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndch4 7, 0, 1
	sndlen 6
	sndendch
