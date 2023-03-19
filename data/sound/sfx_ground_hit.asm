SndHeader_SFX_GroundHit:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_GroundHit_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_GroundHit_Ch4:
	sndenv 15, SNDENV_DEC, 7
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndch4 4, 0, 5
	sndlen 2
	sndch4 2, 0, 7
	sndlen 3
	sndch4 3, 0, 5
	sndlen 2
	sndch4 2, 0, 7
	sndlen 2
	sndch4 3, 0, 4
	sndlen 8
	sndch4 7, 0, 1
	sndlen 2
	sndch4 5, 0, 4
	sndlen 2
	sndch4 4, 0, 7
	sndlen 2
	sndch4 6, 0, 4
	sndlen 10
	sndch4 7, 0, 1
	sndlen 100
	sndendch
