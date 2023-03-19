SndHeader_SFX_FireHitB:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_FireHitB_Ch4 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_FireHitB_Ch4:
	sndenv 3, SNDENV_INC, 3
	sndenach SNDOUT_CH4R|SNDOUT_CH4L
	sndch4 5, 0, 5
	sndlen 70
	sndendch
