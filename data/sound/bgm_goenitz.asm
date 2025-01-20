SndHeader_BGM_Goenitz:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_Goenitz_Ch1 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_Goenitz_Ch2 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_Goenitz_Ch3 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_Goenitz_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_BGM_Goenitz_Ch1:
	envelope $11
	panning $11
	duty_cycle 2
	note A_,2, 14
.loop0:
	snd_call .call0
	snd_call .call1
	snd_call .call2
	fine_tune 12
	snd_call .call1
	fine_tune -12
	snd_loop .loop0
.call0:
	envelope $11
	note A_,2, 28
	envelope $68
	note E_,4, 14
	note G_,4, 28
	note F#,4
	note E_,4, 7
	note D_,4
	note E_,4, 84
	silence 28
	note D_,4, 84
	silence 14
	note C_,4, 7
	note B_,3
	note C_,4, 84
	silence 42
	note E_,4, 14
	note A_,4
	note C_,5, 28
	note B_,4
	note A_,4, 7
	note G_,4
	note F#,4, 112
	wait2 112
	wait2 112
	snd_ret
.call1:
	silence 14
	note C_,4
	note A_,3
	note C_,4
	note B_,3, 7
	silence
	note E_,3, 28
	silence 14
	silence 14
	note C_,4
	note A_,3
	note C_,4
	note B_,3, 7
	silence
	note E_,3, 28
	silence 14
	silence 14
	note C_,4
	note A_,3
	note C_,4
	note B_,3
	note E_,3
	note D_,4
	note B_,3
	note C_,4
	note B_,3, 42
	note A_,3, 14
	note G_,3, 28
	silence 14
	snd_loop .call1, $00, 2
	snd_ret
.call2:
	silence 14
	note F_,5
	note D_,5
	note F_,5
	note E_,5, 7
	silence
	note C#,5, 28
	silence 14
	silence
	note F_,5
	note D_,5
	note F_,5
	note E_,5, 7
	silence
	note C#,5, 28
	silence 14
	silence
	note F_,5
	note D_,5
	note F_,5
	note E_,5
	note A_,4
	note C_,6
	note G_,5
	note A#,5
	note A_,5, 42
	note G_,5, 14
	note F#,5, 28
	silence 14
	snd_ret
SndData_BGM_Goenitz_Ch2:
	envelope $78
	panning $22
	duty_cycle 3
	note C_,3, 7
	note C_,3
.loop0:
	snd_call .call1
	snd_call .call2
	envelope $38
	duty_cycle 2
	silence 10
	snd_call SndData_BGM_Goenitz_Ch1.call1
	snd_call .call3
	snd_call .call4
	snd_loop .loop0
.call1:
	note C_,3, 84
	wait2 14
	note C_,3, 7
	note C_,3
	note C_,3, 28
	note C_,3, 4
	silence 10
	note A_,4, 42
	note C_,3, 4
	silence 10
	note C_,3, 7
	note C_,3
	note C_,3, 28
	note C_,3, 4
	silence 10
	note C_,5, 42
	note C_,3, 4
	silence 10
	note C_,3, 7
	note C_,3
	note C_,3, 28
	note C_,3, 4
	silence 10
	note D_,5, 42
	note C_,3, 4
	silence 10
	note C_,3, 7
	note C_,3
	note C_,3, 112
	snd_ret
.call2:
	envelope $62
	note D_,4, 5
	note F#,4, 4
	note A_,4, 5
	note C_,5
	note D_,5, 4
	note D#,5, 5
	note F#,5
	note D#,5, 4
	note D_,5, 5
	note C_,5
	note A_,4, 4
	note F#,4, 5
	snd_loop .call2, $00, 6
	snd_ret
.call3:
	silence 14
	note F_,5
	note D_,5
	note F_,5
	note E_,5, 7
	silence
	note C#,5, 28
	silence 14
	silence
	note F_,5
	note D_,5
	note F_,5
	note E_,5, 7
	silence
	note C#,5, 28
	silence 14
	silence
	note F_,5
	note D_,5
	note F_,5
	note E_,5
	note A_,4
	note C_,6
	note G_,5
	note A#,5
	note A_,5, 42
	note G_,5, 14
	note F#,5, 28
	silence 4
	snd_ret
.call4:
	envelope $78
	duty_cycle 3
	note E_,4, 84
	wait2 14
	note E_,4, 7
	note E_,4
	note E_,4, 84
	wait2 14
	note E_,4, 7
	note E_,4
	note F_,4, 84
	wait2 14
	note F_,4, 7
	note F_,4
	note G_,4, 84
	wait2 14
	note G_,4, 7
	note G_,4
	snd_loop .call4, $00, 2
	snd_ret
SndData_BGM_Goenitz_Ch3:
	wave_vol $80
	panning $44
	wave_id $04
	wave_cutoff 25
	note A_,3, 7
	note A_,3
.loop0:
	snd_call .call0
	snd_call .call1
	snd_call .call1
	snd_call .call2
	snd_loop .loop0
.call0:
	wave_cutoff 0
	note A_,3, 84
	wait2 14
	wave_cutoff 25
	note A_,3, 7
	note A_,3
	wave_cutoff 0
	note A_,3, 42
	note C#,5, 56
	wave_cutoff 25
	note A_,3, 7
	note A_,3
	wave_cutoff 0
	note A_,3, 42
	note A_,3, 28
	note C_,4
	wave_cutoff 25
	note A_,3, 7
	note A_,3
	wave_cutoff 0
	note A_,3, 42
	note A_,3, 28
	note C_,4
	wave_cutoff 25
	note G_,3, 7
	note G#,3
	wave_cutoff 0
	note A_,3, 84
	wait2 14
	wave_cutoff 25
	note A_,3, 7
	note A_,3
	wave_cutoff 0
	note D_,5, 112
	wait2 112
	wait2 112
	snd_ret
.call1:
	wave_cutoff 50
	note A_,3, 28
	snd_loop .call1, $00, 15
	note A_,3, 14
	note E_,3
	snd_ret
.call2:
	note G_,3, 28
	note G_,3
	note G_,3
	note G_,3
	note G_,3
	note G_,3
	note G_,3
	note G_,3, 14
	note D_,3
	wave_cutoff 25
.call2b:
	note G_,3, 7
	snd_loop .call2b, $00, 32
.call2c:
	wave_cutoff 0
	note A_,3, 84
	wait2 14
	wave_cutoff 25
	note A_,3, 7
	note A_,3
	snd_loop .call2c, $00, 4
.call2d:
	wave_cutoff 25
	note A_,3, 14
	note A_,3, 7
	note A_,3
	wave_cutoff 0
	note A_,3, 42
	wave_cutoff 25
	note A_,3, 7
	note A_,3
	note A_,3, 14
	note A_,3, 7
	note A_,3
	snd_loop .call2d, $00, 4
	snd_ret
SndData_BGM_Goenitz_Ch4:
	panning $88
	envelope $54
	wait 38
	wait 7
	wait 50
	wait 7
.loop0:
	snd_call .call0
	snd_call .call1
	snd_call .call0
	snd_call .call2
	snd_call .call0
	envelope $61
	wait 54
	wait 28
	wait 54
	wait 28
	wait 54
	wait 28
	wait 54
	wait 28
	snd_call .call3
	snd_call .call4
	snd_call .call3
	snd_call .call5
	snd_loop .loop0
.call0:
	envelope $61
	wait 54
	wait 14
	envelope $31
	wait 33
	wait 14
	envelope $62
	wait 36
	wait 14
	envelope $31
	wait 33
	wait 28
	envelope $61
	wait 54
	wait 14
	envelope $62
	wait 36
	wait 14
	envelope $53
	wait 17
	wait 14
	snd_ret
.call1:
	envelope $31
	wait 33
	wait 14
	envelope $62
	wait 36
	wait 7
	wait 36
	wait 7
	envelope $61
	wait 54
	wait 42
	wait 54
	wait 7
	wait 54
	wait 7
	envelope $44
	wait 38
	wait 7
	wait 16
	wait 7
	envelope $54
	wait 38
	wait 7
	wait 50
	wait 7
	snd_ret
.call2:
	envelope $31
	wait 33
	wait 14
	envelope $62
	wait 36
	wait 7
	wait 36
	wait 7
	envelope $61
	wait 54
	wait 28
	envelope $31
	wait 33
	wait 14
	envelope $61
	wait 54
	wait 14
	envelope $62
	wait 36
	wait 14
	envelope $61
	wait 54
	wait 14
	snd_ret
.call3:
	envelope $61
	wait 54
	wait 7
	envelope $22
	wait 36
	wait 7
	wait 36
	wait 7
	wait 36
	wait 7
	envelope $61
	wait 54
	wait 7
	envelope $22
	wait 36
	wait 7
	wait 36
	wait 7
	envelope $42
	wait 36
	wait 7
	envelope $61
	wait 54
	wait 7
	envelope $42
	wait 36
	wait 7
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
	wait 36
	wait 7
	envelope $62
	wait 36
	wait 14
	envelope $44
	wait 38
	wait 14
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
	envelope $54
	wait 38
	wait 7
	wait 50
	wait 7
	envelope $61
	wait 54
	wait 7
	envelope $62
	wait 36
	wait 7
	wait 36
	wait 7
	wait 36
	wait 7
	envelope $44
	wait 38
	wait 5
	envelope $34
	wait 38
	wait 4
	envelope $54
	wait 38
	wait 5
	snd_ret
.call4:
	envelope $61
	wait 54
	wait 14
	envelope $53
	wait 17
	wait 14
	envelope $61
	wait 54
	wait 7
	envelope $31
	wait 33
	wait 7
	envelope $53
	wait 17
	wait 14
	snd_loop .call4, $00, 20
	snd_ret
.call5:
	envelope $61
	wait 54
	wait 14
	envelope $53
	wait 17
	wait 14
	envelope $62
	wait 36
	wait 7
	envelope $31
	wait 33
	wait 7
	envelope $53
	wait 17
	wait 28
	envelope $61
	wait 54
	wait 14
	envelope $62
	wait 36
	wait 7
	envelope $31
	wait 33
	wait 7
	envelope $53
	wait 17
	wait 14
	snd_loop .call5, $00, 8
	snd_ret
