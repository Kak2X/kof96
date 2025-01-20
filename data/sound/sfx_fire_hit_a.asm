SndHeader_SFX_FireHitA:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_FireHitA_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_SFX_FireHitA_Ch4:
	envelope $F7
	panning $88
	wait 69
	wait 1
	lock_envelope
	wait 85
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
	wait 1
	wait 64
	wait 1
	unlock_envelope
	envelope $F2
	wait 50
	wait 30
	chan_stop
