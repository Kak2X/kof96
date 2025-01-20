SndHeader_SFX_GroundHit:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_GroundHit_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_SFX_GroundHit_Ch4:
	envelope $F7
	panning $88
	wait 69
	wait 2
	wait 39
	wait 3
	wait 53
	wait 2
	wait 39
	wait 2
	wait 52
	wait 8
	wait 113
	wait 2
	wait 84
	wait 2
	wait 71
	wait 2
	wait 100
	wait 10
	wait 113
	wait 100
	chan_stop
