SndHeader_SFX_GameOver:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_31_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_SFX_31_Ch4:
	envelope $1B
	panning $88
	wait 39
	wait 10
	lock_envelope
	wait 38
	wait 10
	wait 37
	wait 10
	wait 36
	wait 10
	wait 35
	wait 10
	wait 34
	wait 10
	chan_stop
