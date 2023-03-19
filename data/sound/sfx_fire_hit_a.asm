SndHeader_SFX_FireHitA:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_FireHitA_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_FireHitA_Ch4:
	sndenv 15, SNDENV_DEC, 7
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndch4 4, 0, 5
	sndlen 1
	sndsetskip
	sndch4 5, 0, 5
	sndlen 2
	sndch4 4, 0, 7
	sndlen 2
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
	sndlen 1
	sndch4 4, 0, 0
	sndlen 1
	sndclrskip
	sndenv 15, SNDENV_DEC, 2
	sndch4 3, 0, 2
	sndlen 30
	sndendch
