SndHeader_SFX_GameOver:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_31_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_SFX_31_Ch4:
	envelope $1B
	panning $88
	note4 G#,5,0, 10
	lock_envelope
	note4 A_,5,0, 10
	note4 A#,5,0, 10
	note4 B_,5,0, 10
	note4x $23, 10 ; Nearest: G#,5,0
	note4x $22, 10 ; Nearest: A_,5,0
	chan_stop

