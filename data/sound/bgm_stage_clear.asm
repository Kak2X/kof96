SndHeader_BGM_StageClear:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_StageClear_Ch1 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_StageClear_Ch2 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_StageClear_Ch3 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_StageClear_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_BGM_StageClear_Ch1:
	envelope $77
	panning $11
	duty_cycle 3
	note C_,3, 14
	note C_,2, 3
	silence 4
	note A#,2, 14
	note A#,2, 3
	silence 4
	note G_,3, 56
	note G_,2, 3
	silence 4
	note G_,3, 3
	silence 4
	note G#,3, 14
	note G#,2, 3
	silence 4
	note G_,3, 21
	note F_,3, 14
	note G#,3, 14
	note G#,2, 3
	silence 4
	note G_,3, 21
	note F_,3, 14
	note C_,3, 14
	note D_,3
	chan_stop
SndData_BGM_StageClear_Ch2:
	envelope $67
	panning $22
	duty_cycle 1
	note G_,3, 14
	silence 7
	note F_,3, 14
	silence 7
	note C_,4, 28
	note C_,4, 5
	note A#,3, 4
	note G_,3, 5
	note A#,3
	note G_,3, 4
	note F_,3, 5
	note G_,3
	note D_,3, 4
	note A#,2, 5
	note C#,4, 14
	silence 7
	note C_,4, 21
	note A#,3, 14
	note C#,4
	silence 7
	note C_,4, 21
	note A#,3, 14
	note F_,3
	note G_,3
	chan_stop
SndData_BGM_StageClear_Ch3:
	wave_vol $80
	panning $44
	wave_id $04
	wave_cutoff 50
	note G_,3, 21
	note F_,3
	note C_,3
	note C_,3, 7
	note A#,2
	note G_,2
	note A#,2
	note C_,3
	note G_,2
	note G_,3
	note F_,3, 14
	note F_,3, 3
	silence 4
	note G_,3, 21
	note G#,3, 14
	note F_,3, 14
	note F_,3, 3
	silence 4
	note G_,3, 21
	note G#,3, 14
	wave_cutoff 30
	note G_,3
	note G_,3
	chan_stop
SndData_BGM_StageClear_Ch4:
	panning $88
	envelope $34
	wait 38
	wait 3
	envelope $44
	wait 38
	wait 4
	envelope $61
	wait 54
	wait 7
	wait 54
	wait 7
	envelope $44
	wait 38
	wait 3
	envelope $54
	wait 38
	wait 4
	envelope $61
	wait 54
	wait 7
	wait 54
	wait 7
	envelope $62
	wait 36
	wait 7
	envelope $61
	wait 54
	wait 14
	wait 54
	wait 7
	envelope $62
	wait 36
	wait 5
	envelope $61
	wait 54
	wait 4
	wait 54
	wait 5
	envelope $62
	wait 36
	wait 5
	wait 36
	wait 4
	envelope $34
	wait 38
	wait 5
	envelope $34
	wait 38
	wait 5
	envelope $44
	wait 38
	wait 4
	envelope $54
	wait 38
	wait 5
	envelope $61
	wait 54
	wait 7
	envelope $62
	wait 36
	wait 7
	wait 36
	wait 7
	envelope $61
	wait 54
	wait 7
	envelope $62
	wait 36
	wait 7
	wait 36
	wait 7
	envelope $61
	wait 54
	wait 7
	envelope $62
	wait 36
	wait 7
	envelope $61
	wait 54
	wait 7
	envelope $62
	wait 36
	wait 14
	envelope $61
	wait 54
	wait 7
	envelope $62
	wait 36
	wait 7
	wait 36
	wait 7
	envelope $61
	wait 54
	wait 7
	wait 54
	wait 7
	envelope $62
	wait 36
	wait 14
	wait 36
	wait 14
	chan_stop
