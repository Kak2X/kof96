SndHeader_SFX_Taunt:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_Taunt_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_SFX_Taunt_Ch4:
	envelope $B7
	panning $88
	wait 39
	wait 2
	wait 69
	wait 2
	wait 23
	wait 2
	lock_envelope
	wait 20
	wait 2
	wait 23
	wait 2
	unlock_envelope
	chan_stop
