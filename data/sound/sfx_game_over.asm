SndHeader_SFX_GameOver:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_GameOver_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_GameOver_Ch4:
	sndenv 1, SNDENV_INC, 3
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndch4 2, 0, 7
	sndlen 10
	sndsetskip
	sndch4 2, 0, 6
	sndlen 10
	sndch4 2, 0, 5
	sndlen 10
	sndch4 2, 0, 4
	sndlen 10
	sndch4 2, 0, 3
	sndlen 10
	sndch4 2, 0, 2
	sndlen 10
	sndendch
