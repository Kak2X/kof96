SndHeader_SFX_Reflect:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_Reflect_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_SFX_Reflect_Ch4:
	envelope $A7
	panning $88
	wait 65
	wait 1
	lock_envelope
	wait 65
	wait 1
	wait 65
	wait 1
	wait 57
	wait 1
	wait 56
	wait 1
	wait 55
	wait 1
	wait 54
	wait 1
	wait 53
	wait 1
	unlock_envelope
	wait 65
	wait 1
	lock_envelope
	wait 65
	wait 1
	wait 65
	wait 1
	wait 57
	wait 1
	wait 56
	wait 1
	wait 55
	wait 1
	wait 54
	wait 1
	wait 53
	wait 1
	unlock_envelope
	snd_loop SndData_SFX_Reflect_Ch4, $00, 3
	chan_stop
