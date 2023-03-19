SndHeader_SFX_Grab:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_Grab_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_Grab_Ch4:
	sndenv 15, SNDENV_DEC, 2
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndch4 6, 0, 1
	sndlen 3
	sndch4 0, 0, 0
	sndlen 1
	sndch4 2, 0, 5
	sndlen 4
	sndendch
