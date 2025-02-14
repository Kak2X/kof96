SndHeader_SFX_Reflect:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_Reflect_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_SFX_Reflect_Ch4:
	envelope $A7
	panning $88
	note4x $41, 1 ; Nearest: A#,5,0
	lock_envelope
	note4x $41, 1 ; Nearest: A#,5,0
	note4x $41, 1 ; Nearest: A#,5,0
	note4x $39, 1 ; Nearest: A#,5,1
	note4x $38, 1 ; Nearest: B_,5,1
	note4 E_,5,0, 1
	note4 F_,5,0, 1
	note4 F#,5,0, 1
	unlock_envelope
	note4x $41, 1 ; Nearest: A#,5,0
	lock_envelope
	note4x $41, 1 ; Nearest: A#,5,0
	note4x $41, 1 ; Nearest: A#,5,0
	note4x $39, 1 ; Nearest: A#,5,1
	note4x $38, 1 ; Nearest: B_,5,1
	note4 E_,5,0, 1
	note4 F_,5,0, 1
	note4 F#,5,0, 1
	unlock_envelope
	snd_loop SndData_SFX_Reflect_Ch4, $00, 3
	chan_stop
