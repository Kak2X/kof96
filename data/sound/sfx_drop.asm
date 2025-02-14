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
	note4 F_,5,0, 2
	note4x $72, 2 ; Nearest: A_,4,0
	note4 F_,5,0, 3
	note4 G#,4,0, 10
	chan_stop
