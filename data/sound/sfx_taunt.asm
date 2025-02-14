SndHeader_SFX_Taunt:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_Taunt_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_SFX_Taunt_Ch4:
	envelope $B7
	panning $88
	note4 G#,5,0, 2
	note4 D_,5,0, 2
	note4 C_,6,0, 2
	lock_envelope
	note4 D#,6,0, 2
	note4 C_,6,0, 2
	unlock_envelope
	chan_stop
