SndHeader_SFX_Taunt:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_Taunt_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_Taunt_Ch4:
	sndenv 11, SNDENV_DEC, 7
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndch4 2, 0, 7
	sndlen 2
	sndch4 4, 0, 5
	sndlen 2
	sndch4 1, 0, 7
	sndlen 2
	sndsetskip
	sndch4 1, 0, 4
	sndlen 2
	sndch4 1, 0, 7
	sndlen 2
	sndclrskip
	sndendch
