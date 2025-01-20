SndHeader_SFX_Drop:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_Drop_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_SFX_Drop_Ch4:
	envelope $F3
	panning $88
	wait 54
	wait 2
	wait 114
	wait 2
	wait 54
	wait 3
	wait 87
	wait 10
	chan_stop
