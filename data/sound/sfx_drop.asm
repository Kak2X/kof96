SndHeader_SFX_Drop:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_Drop_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_Drop_Ch4:
	sndenv 15, SNDENV_DEC, 3
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndch4 3, 0, 6
	sndlen 2
	sndch4 7, 0, 2
	sndlen 2
	sndch4 3, 0, 6
	sndlen 3
	sndch4 5, 0, 7
	sndlen 10
	sndendch
