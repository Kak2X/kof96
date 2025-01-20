SndHeader_SFX_Hit:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_Hit_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_SFX_Hit_Ch4:
	envelope $F2
	panning $88
	wait 113
	wait 5
	wait 0
	wait 1
	wait 53
	wait 6
	chan_stop
