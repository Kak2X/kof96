SndHeader_SFX_SuperMove:
	db $03 ; Number of channels
.ch2:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_SFX_SuperMove_Ch2 ; Data ptr
	db 12 ; Initial fine tune
	db $81 ; Unused
.ch3:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_SFX_SuperMove_Ch3 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_SuperMove_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_SFX_SuperMove_Ch2:
	envelope $94
	panning $22
	duty_cycle 1
	silence 6
	note A_,4, 2
	note A_,5, 6
	envelope $77
	note A_,4, 1
	note A_,5, 5
	envelope $57
	note A_,4, 1
	note A_,5, 5
	envelope $37
	note A_,4, 1
	note A_,5, 5
	envelope $27
	note A_,4, 1
	note A_,5, 29
	chan_stop
SndData_SFX_SuperMove_Ch3:
	wave_vol $80
	chan_stop
SndData_SFX_SuperMove_Ch4:
	envelope $F2
	panning $88
	note4x $71, 6 ; Nearest: A#,4,0
	chan_stop
