SndHeader_SFX_Step:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_Step_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_SFX_Step_Ch4:
	envelope $F7
	panning $88
	wait 71
	wait 1
	wait 85
	wait 1
	wait 0
	wait 1
	wait 71
	wait 1
	lock_envelope
	wait 52
	wait 1
	wait 85
	wait 1
	chan_stop
