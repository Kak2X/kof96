SndHeader_SFX_Heavy:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_Heavy_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_Heavy_Ch4:
	sndenv 3, SNDENV_INC, 1
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndch4 4, 0, 7
	sndlen 2
	sndsetskip
	sndch4 4, 0, 6
	sndlen 2
	sndch4 4, 0, 5
	sndlen 2
	sndch4 4, 0, 4
	sndlen 2
	sndch4 4, 0, 3
	sndlen 2
	sndch4 4, 0, 2
	sndlen 2
	sndch4 4, 0, 1
	sndlen 2
	sndch4 4, 0, 0
	sndlen 2
	sndclrskip
	sndendch
