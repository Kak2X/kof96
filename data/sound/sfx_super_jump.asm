SndHeader_SFX_SuperJump:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_SuperJump_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_SFX_SuperJump_Ch4:
	envelope $29
	panning $88
	wait 48
	wait 2
	lock_envelope
	wait 49
	wait 2
	wait 50
	wait 2
	wait 51
	wait 2
	wait 52
	wait 2
	wait 53
	wait 2
	wait 54
	wait 2
	wait 55
	wait 2
	wait 54
	wait 2
	wait 53
	wait 2
	wait 52
	wait 2
	wait 51
	wait 2
	wait 50
	wait 2
	wait 49
	wait 2
	wait 48
	wait 2
	chan_stop
