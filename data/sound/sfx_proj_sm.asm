SndHeader_SFX_ProjSm:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_ProjSm_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_SFX_ProjSm_Ch4:
	envelope $A9
	panning $88
	wait 87
	wait 2
	lock_envelope
	wait 86
	wait 2
	wait 85
	wait 2
	wait 84
	wait 2
	wait 83
	wait 2
	wait 71
	wait 2
	wait 70
	wait 2
	wait 69
	wait 2
	wait 68
	wait 2
	wait 67
	wait 2
	wait 66
	wait 2
	wait 65
	wait 2
	unlock_envelope
	envelope $F1
	wait 39
	wait 1
	wait 38
	wait 1
	wait 37
	wait 1
	wait 36
	wait 1
	wait 35
	wait 1
	wait 34
	wait 1
	wait 33
	wait 1
	wait 32
	wait 1
	wait 33
	wait 1
	wait 34
	wait 1
	wait 35
	wait 1
	wait 36
	wait 1
	wait 37
	wait 1
	wait 38
	wait 1
	wait 39
	wait 1
	wait 49
	wait 1
	wait 50
	wait 1
	wait 51
	wait 1
	wait 52
	wait 1
	wait 53
	wait 1
	wait 54
	wait 1
	wait 55
	wait 1
	chan_stop
