SndHeader_SFX_CharSelected:
	db $01 ; Number of channels
.ch2:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_SFX_CharSelected_Ch2 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_SFX_CharSelected_Ch2:
	envelope $F2
	panning $22
	duty_cycle 3
	note E_,4, 2
	note C_,5
	note G_,4
	note E_,5
	note C_,5
	note G_,5
	note E_,5
	note C_,6
	envelope $92
	note E_,4, 2
	note C_,5
	note G_,4
	note E_,5
	note C_,5
	note G_,5
	note E_,5
	note C_,6
	envelope $52
	note E_,4, 2
	note C_,5
	note G_,4
	note E_,5
	note C_,5
	note G_,5
	note E_,5
	note C_,6
	envelope $22
	note E_,4, 2
	note C_,5
	note G_,4
	note E_,5
	note C_,5
	note G_,5
	note E_,5
	note C_,6
	chan_stop
