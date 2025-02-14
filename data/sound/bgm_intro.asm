SndHeader_BGM_Intro:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_Intro_Ch1 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_Intro_Ch2 ; Data ptr
	db 24 ; Initial fine tune
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_Intro_Ch3 ; Data ptr
	db 12 ; Initial fine tune
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_Intro_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_BGM_Intro_Ch1:
	envelope $71
	panning $11
	duty_cycle 2
	silence 56
.loop0:
	silence 7
	note B_,4
	note E_,5, 14
	note D_,5, 7
	note E_,5, 14
	note E_,5
	note B_,4, 7
	note E_,5, 14
	note D_,5, 7
	note E_,5, 21
	snd_loop .loop0, $00, 3
	envelope $77
	duty_cycle 3
	silence 7
	note E_,3
	silence 14
	note E_,3, 7
	note E_,3
	silence
	note C#,3, 21
	note C#,3, 14
	note E_,3, 7
	note E_,3
	silence
	envelope $78
	note A_,4, 21
	note B_,4, 56
	continue 7
	silence
	note D_,5, 14
	note B_,4, 3
	silence 4
	note D_,5, 21
	note E_,5, 35
	silence 7
	note E_,5, 28
	note B_,5, 21
	note A_,5, 7
	continue 112
	silence 7
	note B_,5
	silence 14
	note A_,5
	note B_,5, 7
	note D_,6, 84
	continue 3
	silence 4
	note E_,6, 7
	note B_,5, 3
	silence 4
	note E_,6, 10
	silence 4
	note D_,6, 14
	silence 7
	note E_,6, 28
	silence 7
	chan_stop
SndData_BGM_Intro_Ch2:
	envelope $68
	panning $22
	duty_cycle 1
	silence 28
	note G_,2, 14
	note A_,2, 7
	note A_,2, 21
	note E_,2, 84
	note E_,2, 3
	silence 4
	note G_,2, 7
	continue 56
	silence 14
	note E_,2
	note G_,2
	note E_,2, 3
	silence 4
	note G_,2, 7
	continue 14
	note A_,2, 56
	note A_,2, 14
	note G_,2
	note A_,2
	silence 7
	note B_,2
	silence 14
	note A_,2, 7
	note B_,2
	silence
	note A_,2, 21
	note F#,2, 14
	note A_,2, 7
	note B_,2
	silence
	note B_,2
	fine_tune -12
	continue 14
	note E_,2, 56
	continue 14
	note E_,2, 7
	note E_,2, 3
	silence 4
	note E_,2, 3
	silence 4
	note G_,2, 7
	continue 56
	note G_,2, 7
	note G_,2, 3
	silence 4
	note D_,2, 3
	silence 4
	note D_,2, 3
	silence 4
	note G_,2, 7
	note G_,2, 3
	silence 4
	note G_,2, 3
	silence 4
	note A_,2, 7
	continue 56
	note E_,3, 7
	note E_,2, 3
	silence 4
	note E_,3, 3
	silence 4
	note A_,2, 14
	note A_,2, 3
	silence 4
	note G_,2, 7
	note A_,2
	note E_,3, 3
	silence 4
	note F#,3, 10
	silence 4
	note B_,2, 7
	note F#,2
	note F#,2, 3
	silence 4
	note G_,2, 7
	note A_,2, 84
	silence 7
	note F#,3
	note B_,2, 3
	silence 4
	note F#,3, 14
	note E_,3, 14
	silence 7
	note E_,3, 28
	silence 7
	fine_tune 12
	chan_stop
SndData_BGM_Intro_Ch3:
	wave_vol $80
	panning $44
	wave_id $03
	wave_cutoff 30
	silence 28
	note G_,2, 7
	note C_,2
	note A_,3
	wave_cutoff 60
	note A_,2, 21
	wave_cutoff 30
	note E_,2, 7
	note E_,3
	note B_,3
	note E_,3
	note E_,2
	note D_,3, 14
	note B_,2, 7
	note E_,2
	note E_,3
	note B_,2
	note D#,2
	note E_,2
	wave_cutoff 60
	note G_,2, 21
	wave_cutoff 30
	note E_,2, 7
	note G_,2
	note G_,3
	note D_,3
	note G_,2
	note B_,2, 14
	note D_,3, 7
	note G_,2
	note G_,3
	note G_,2, 14
	note D_,2, 7
	wave_cutoff 60
	note G_,2, 21
	wave_cutoff 30
	note E_,2, 7
	note A_,3
	note E_,2
	note A_,2
	note E_,3
	note A_,2, 14
	note A_,3, 7
	note E_,3, 14
	note G_,2, 7
	note D_,3
	note E_,2, 14
	silence 7
	note D_,3, 21
	note C#,3, 7
	note D_,3, 14
	note C#,3, 21
	note A_,2, 14
	note C#,3, 7
	note D_,3, 14
	note B_,2, 14
	note E_,2, 7
	note D_,2
	note E_,2, 14
	note E_,3, 7
	note B_,2
	note D_,2
	note E_,2
	note B_,2
	note D_,2
	note E_,2
	note D_,3
	note E_,2
	note G_,2, 14
	note G_,3, 7
	note F#,3
	note E_,2
	note G_,2
	note G_,2
	note A_,2
	note D_,3, 14
	note G_,3, 7
	note C_,3
	note F#,3
	note G_,2
	note E_,2
	note G_,2
	note A_,2, 14
	note A_,3, 7
	note G_,3
	note E_,3
	note D_,3
	note A_,2
	note E_,2
	note A_,2, 14
	note E_,3, 7
	note A_,2
	note A_,3
	note A_,2
	note G_,3
	note A_,3
	note D_,4
	note E_,2
	note F#,3, 14
	note B_,2, 7
	note F_,2
	note E_,2
	note F#,2
	wave_cutoff 0
	note D_,3, 84
	continue 7
	wave_cutoff 30
	note F#,3, 7
	note B_,2
	note F#,3, 14
	note E_,2, 21
	note E_,2, 35
	chan_stop
SndData_BGM_Intro_Ch4:
	panning $88
	snd_call .call0
	snd_call .call1
	chan_stop
.call0:
	envelope $62
	note4 B_,5,0, 7
	note4 B_,5,0, 7
	envelope $61
	note4 F_,5,0, 7
	envelope $62
	note4 B_,5,0, 7
	note4 B_,5,0, 14
	note4 B_,5,0, 7
	envelope $61
	note4 F_,5,0, 21
	note4 F_,5,0, 14
	envelope $62
	note4 B_,5,0, 28
	envelope $61
	note4 F_,5,0, 28
	envelope $62
	note4 B_,5,0, 21
	envelope $61
	note4 F_,5,0, 21
	note4 F_,5,0, 14
	envelope $62
	note4 B_,5,0, 28
	envelope $61
	note4 F_,5,0, 14
	note4 F_,5,0, 14
	envelope $62
	note4 B_,5,0, 14
	envelope $61
	note4 F_,5,0, 7
	envelope $62
	note4 B_,5,0, 21
	envelope $61
	note4 F_,5,0, 14
	envelope $62
	note4 B_,5,0, 28
	envelope $61
	note4 F_,5,0, 14
	note4 F_,5,0, 14
	envelope $62
	note4 B_,5,0, 14
	envelope $61
	note4 F_,5,0, 21
	envelope $62
	note4 B_,5,0, 21
	envelope $34
	note4 A_,5,0, 7
	envelope $44
	note4 A_,5,0, 7
	envelope $54
	note4 A_,5,0, 7
	envelope $61
	note4 F_,5,0, 14
	note4 F_,5,0, 7
	envelope $62
	note4 B_,5,0, 14
	envelope $61
	note4 F_,5,0, 14
	envelope $62
	note4 B_,5,0, 7
	snd_ret
.call1:
	envelope $61
	note4 F_,5,0, 14
	note4 F_,5,0, 7
	envelope $62
	note4 B_,5,0, 14
	envelope $61
	note4 F_,5,0, 14
	envelope $62
	note4 B_,5,0, 14
	envelope $61
	note4 F_,5,0, 14
	envelope $62
	note4 B_,5,0, 14
	envelope $61
	note4 F_,5,0, 14
	envelope $62
	note4 B_,5,0, 7
	snd_loop .call1, $00, 2
	envelope $61
	note4 F_,5,0, 14
	note4 F_,5,0, 7
	envelope $62
	note4 B_,5,0, 14
	envelope $61
	note4 F_,5,0, 14
	envelope $62
	note4 B_,5,0, 14
	envelope $61
	note4 F_,5,0, 14
	note4 F_,5,0, 7
	envelope $62
	note4 B_,5,0, 14
	envelope $61
	note4 F_,5,0, 7
	envelope $62
	note4 B_,5,0, 7
	note4 B_,5,0, 7
	envelope $61
	note4 F_,5,0, 7
	envelope $62
	note4 B_,5,0, 21
	envelope $44
	note4 A_,5,0, 7
	note4x $10, 7 ; Nearest: B_,6,0
	envelope $54
	note4 A_,5,0, 7
	envelope $62
	note4 B_,5,0, 14
	envelope $54
	note4 A_,5,0, 7
	envelope $34
	note4 A_,5,0, 7
	note4 A_,5,0, 7
	envelope $44
	note4 A_,5,0, 7
	note4x $10, 7 ; Nearest: B_,6,0
	envelope $54
	note4 A_,5,0, 7
	note4x $32, 7 ; Nearest: A_,5,0
	envelope $54
	note4 A_,5,0, 7
	envelope $44
	note4 A_,5,0, 3
	note4x $10, 4 ; Nearest: B_,6,0
	envelope $34
	note4 A_,5,0, 7
	note4 A_,5,0, 7
	envelope $62
	note4 B_,5,0, 7
	envelope $61
	note4 F_,5,0, 7
	envelope $62
	note4 B_,5,0, 7
	envelope $61
	note4 F_,5,0, 7
	envelope $62
	note4 B_,5,0, 7
	envelope $61
	note4 F_,5,0, 7
	note4 F_,5,0, 7
	envelope $62
	note4 B_,5,0, 35
	snd_ret
