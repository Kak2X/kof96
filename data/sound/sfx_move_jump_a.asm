SndHeader_SFX_MoveJumpA:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_MoveJumpA_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_SFX_MoveJumpA_Ch4:
	envelope $A9
	panning $88
	note4x $31, 3 ; Nearest: A#,5,0
	lock_envelope
	note4x $32, 3 ; Nearest: A_,5,0
	note4x $33, 3 ; Nearest: G#,5,0
	note4 G_,5,0, 3
	note4 F#,5,0, 3
	note4 F_,5,0, 3
	note4 E_,5,0, 3
	note4x $43, 3 ; Nearest: G#,5,0
	note4 D#,5,0, 3
	note4 D_,5,0, 3
	note4 C#,5,0, 3
	note4 C_,5,0, 3
	unlock_envelope
	chan_stop

