SndHeader_SFX_ProjSm:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_ProjSm_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_SFX_ProjSm_Ch4:
	envelope $A9
	panning $88
	note4 G#,4,0, 2
	lock_envelope
	note4 A_,4,0, 2
	note4 A#,4,0, 2
	note4 B_,4,0, 2
	note4x $53, 2 ; Nearest: G#,4,0
	note4 C_,5,0, 2
	note4 C#,5,0, 2
	note4 D_,5,0, 2
	note4 D#,5,0, 2
	note4x $43, 2 ; Nearest: G#,5,0
	note4x $42, 2 ; Nearest: A_,5,0
	note4x $41, 2 ; Nearest: A#,5,0
	unlock_envelope
	envelope $F1
	note4 G#,5,0, 1
	note4 A_,5,0, 1
	note4 A#,5,0, 1
	note4 B_,5,0, 1
	note4x $23, 1 ; Nearest: G#,5,0
	note4x $22, 1 ; Nearest: A_,5,0
	note4x $21, 1 ; Nearest: A#,5,0
	note4x $20, 1 ; Nearest: B_,5,0
	note4x $21, 1 ; Nearest: A#,5,0
	note4x $22, 1 ; Nearest: A_,5,0
	note4x $23, 1 ; Nearest: G#,5,0
	note4 B_,5,0, 1
	note4 A#,5,0, 1
	note4 A_,5,0, 1
	note4 G#,5,0, 1
	note4x $31, 1 ; Nearest: A#,5,0
	note4x $32, 1 ; Nearest: A_,5,0
	note4x $33, 1 ; Nearest: G#,5,0
	note4 G_,5,0, 1
	note4 F#,5,0, 1
	note4 F_,5,0, 1
	note4 E_,5,0, 1
	chan_stop
