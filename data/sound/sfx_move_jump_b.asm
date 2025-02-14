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
	note4x $71, 2 ; Nearest: A#,4,0
	note4 B_,4,0, 2
	note4 G_,5,0, 2
	note4 B_,4,0, 2
	note4 G_,5,0, 5
	note4x $71, 30 ; Nearest: A#,4,0
	chan_stop

