SndHeader_SFX_Grab:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_Grab_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_SFX_Grab_Ch4:
	envelope $F2
	panning $88
	wait 97
	wait 3
	wait 0
	wait 1
	wait 37
	wait 4
	chan_stop
