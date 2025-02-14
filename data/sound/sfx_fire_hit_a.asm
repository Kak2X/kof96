SndHeader_SFX_FireHitA:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_FireHitA_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_SFX_FireHitA_Ch4:
	envelope $F7
	panning $88
	note4 D_,5,0, 1
	lock_envelope
	note4 A#,4,0, 2
	note4 C_,5,0, 2
	note4 C#,5,0, 2
	note4 D_,5,0, 2
	note4 D#,5,0, 2
	note4x $43, 2 ; Nearest: G#,5,0
	note4x $42, 2 ; Nearest: A_,5,0
	note4x $41, 1 ; Nearest: A#,5,0
	note4x $40, 1 ; Nearest: B_,5,0
	unlock_envelope
	envelope $F2
	note4x $32, 30 ; Nearest: A_,5,0
	chan_stop