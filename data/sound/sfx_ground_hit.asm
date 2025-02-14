SndHeader_SFX_GroundHit:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_GroundHit_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_SFX_GroundHit_Ch4:
	envelope $F7
	panning $88
	note4 D_,5,0, 2
	note4 G#,5,0, 3
	note4 F#,5,0, 2
	note4 G#,5,0, 2
	note4 G_,5,0, 8
	note4x $71, 2 ; Nearest: A#,4,0
	note4 B_,4,0, 2
	note4 C_,5,0, 2
	note4 G_,4,0, 10
	note4x $71, 100 ; Nearest: A#,4,0
	chan_stop
