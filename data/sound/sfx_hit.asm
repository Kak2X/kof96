SndHeader_SFX_Hit:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_Hit_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_Hit_Ch4:
	sndenv 15, SNDENV_DEC, 2
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndch4 7, 0, 1
	sndlen 5
	sndch4 0, 0, 0
	sndlen 1
	sndch4 3, 0, 5
	sndlen 6
	sndendch
