SndHeader_SFX_CursorMove:
	db $01 ; Number of channels
.ch2:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_SFX_CursorMove_Ch2 ; Data ptr
	db 12 ; Initial fine tune
	db $81 ; Unused
SndData_SFX_CursorMove_Ch2:
	envelope $C3
	panning $22
	duty_cycle 3
	note A_,4, 2
	note C_,5
	note E_,5
	note G_,5
	envelope $73
	note A_,4
	note C_,5
	note E_,5
	note G_,5
	envelope $43
	note A_,4
	note C_,5
	note E_,5
	note G_,5
	envelope $23
	note A_,4
	note C_,5
	note E_,5
	note G_,5
	chan_stop
