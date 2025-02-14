SndHeader_SFX_Block:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_Block_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_SFX_Block_Ch4:
	envelope $F7
	panning $88
	note4 E_,5,0, 1
	note4 D_,5,0, 1
	note4 E_,5,0, 1
	lock_envelope
	note4 B_,5,0, 1
	note4 A#,4,0, 1
	chan_stop
