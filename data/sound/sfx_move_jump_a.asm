SndHeader_SFX_MoveJumpA:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_MoveJumpA_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_SFX_MoveJumpA_Ch4:
	envelope $A9
	panning $88
	wait 49
	wait 3
	lock_envelope
	wait 50
	wait 3
	wait 51
	wait 3
	wait 52
	wait 3
	wait 53
	wait 3
	wait 54
	wait 3
	wait 55
	wait 3
	wait 67
	wait 3
	wait 68
	wait 3
	wait 69
	wait 3
	wait 70
	wait 3
	wait 71
	wait 3
	unlock_envelope
	chan_stop
