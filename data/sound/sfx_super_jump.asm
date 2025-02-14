SndHeader_SFX_SuperJump:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_SuperJump_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_SFX_SuperJump_Ch4:
	envelope $29
	panning $88
	note4x $30, 2 ; Nearest: B_,5,0
	lock_envelope
	note4x $31, 2 ; Nearest: A#,5,0
	note4x $32, 2 ; Nearest: A_,5,0
	note4x $33, 2 ; Nearest: G#,5,0
	note4 G_,5,0, 2
	note4 F#,5,0, 2
	note4 F_,5,0, 2
	note4 E_,5,0, 2
	note4 F_,5,0, 2
	note4 F#,5,0, 2
	note4 G_,5,0, 2
	note4x $33, 2 ; Nearest: G#,5,0
	note4x $32, 2 ; Nearest: A_,5,0
	note4x $31, 2 ; Nearest: A#,5,0
	note4x $30, 2 ; Nearest: B_,5,0
	chan_stop
