SndHeader_SFX_Reflect:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_Reflect_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_Reflect_Ch4:
	sndenv 10, SNDENV_DEC, 7
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndch4 4, 0, 1
	sndlen 1
	sndsetskip
	sndch4 4, 0, 1
	sndlen 1
	sndch4 4, 0, 1
	sndlen 1
	sndch4 3, 1, 1
	sndlen 1
	sndch4 3, 1, 0
	sndlen 1
	sndch4 3, 0, 7
	sndlen 1
	sndch4 3, 0, 6
	sndlen 1
	sndch4 3, 0, 5
	sndlen 1
	sndclrskip
	sndch4 4, 0, 1
	sndlen 1
	sndsetskip
	sndch4 4, 0, 1
	sndlen 1
	sndch4 4, 0, 1
	sndlen 1
	sndch4 3, 1, 1
	sndlen 1
	sndch4 3, 1, 0
	sndlen 1
	sndch4 3, 0, 7
	sndlen 1
	sndch4 3, 0, 6
	sndlen 1
	sndch4 3, 0, 5
	sndlen 1
	sndclrskip
	sndloopcnt $00, 3, SndData_SFX_Reflect_Ch4
	sndendch
