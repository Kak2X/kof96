SndHeader_SFX_MoveJumpB:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_MoveJumpB_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_SFX_MoveJumpB_Ch4:
	envelope $F3
	panning $88
	wait 113
	wait 2
	wait 84
	wait 2
	wait 52
	wait 2
	wait 84
	wait 2
	wait 52
	wait 5
	wait 113
	wait 30
	chan_stop
