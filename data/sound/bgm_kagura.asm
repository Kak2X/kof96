SndHeader_BGM_Kagura:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_Kagura_Ch1 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_Kagura_Ch2 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_Kagura_Ch3 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_Kagura_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_BGM_Kagura_Ch1:
	envelope $77
	panning $11
	duty_cycle 3
	snd_call .call0
	snd_call .call1
	snd_call .call2
	snd_call .call3
	snd_call .call4
	snd_call .call5
	snd_loop SndData_BGM_Kagura_Ch1
.call0:
	envelope $11
	note E_,2, 20
	envelope $77
	note E_,4, 10
	envelope $11
	note E_,2, 20
	envelope $77
	note E_,4, 10
	note D_,4
	note B_,3
	envelope $11
	note D_,2, 20
	envelope $77
	note D_,4, 10
	envelope $11
	note D_,2, 20
	envelope $77
	note D_,4, 10
	note D_,4
	note A_,3
	envelope $11
	note A_,2, 20
	envelope $77
	note A_,4, 10
	envelope $11
	note A_,2, 20
	envelope $77
	note A_,4, 10
	envelope $11
	note A_,2, 20
	envelope $77
	note A_,4, 10
	envelope $11
	note A_,2, 20
	envelope $77
	note A_,4, 10
	silence
	note A_,4, 20
	silence 10
	snd_loop .call0, $00, 2
	snd_ret
.call1:
	envelope $68
	duty_cycle 2
	note A_,3, 30
	note A_,4, 80
	continue 10
	note D_,5, 10
	note B_,4
	note G_,4
	note F#,4, 40
	note D_,4, 30
	note A_,3, 80
	envelope $11
	note A_,2, 20
	envelope $68
	note A_,3, 30
	note A_,4, 80
	continue 10
	silence
	note C_,5
	note B_,4
	note G_,4
	note F#,4
	note G_,4
	note F#,4
	note D_,4, 20
	note A_,3
	note C_,4, 40
	note D_,4, 7
	note C_,4, 6
	note D_,4, 7
	note C_,4
	note D_,4, 6
	note C_,4, 7
	note D_,4, 10
	note C_,4, 30
	note G_,4
	note A_,4, 80
	silence 10
	note F#,4
	note A_,4, 30
	note C_,5
	note E_,5, 60
	envelope $11
	note E_,2, 20
	continue 7
	envelope $68
	note D_,5, 6
	note E_,5, 7
	note G_,5, 30
	note B_,5
	note E_,5
	note C_,5, 20
	silence 10
	note A_,4, 20
	note D_,5, 10
	note C_,5
	continue 40
	silence 20
	note C_,5, 10
	note E_,5, 20
	note D_,5, 20
	continue 3
	note E_,4, 7
	note F#,4, 6
	note A_,4, 7
	note C_,5
	note E_,5, 6
	note G_,5, 7
	note B_,5
	snd_ret
.call2:
	envelope $77
	duty_cycle 3
	envelope $11
	note E_,2, 20
	envelope $77
	note E_,4, 10
	envelope $11
	note E_,2, 20
	envelope $77
	note E_,4, 10
	envelope $11
	note E_,2, 20
	envelope $77
	note E_,4, 10
	envelope $11
	note E_,2, 20
	envelope $77
	note E_,4, 10
	envelope $11
	note E_,2
	envelope $77
	note D_,4
	note D_,4
	note E_,4
	snd_loop .call2, $00, 3
	envelope $11
	note E_,2, 20
	envelope $77
	note E_,4, 10
	envelope $11
	note E_,2, 20
	envelope $77
	note D_,4, 10
	note D_,4
	note E_,4
	envelope $11
	note E_,2, 20
	envelope $77
	note G_,4, 10
	envelope $11
	note E_,2, 20
	envelope $77
	note D_,4, 10
	note A_,4
	note D_,4
	snd_ret
.call3:
	envelope $68
	duty_cycle 2
	note A_,3, 30
	note A_,4, 80
	continue 10
	note C_,5
	note B_,4
	note G_,4
	note F#,4, 40
	note D_,4, 30
	note A_,3, 40
	silence 10
	note D_,4, 20
	note C_,4
	note G_,3, 10
	note E_,3
	note G_,3
	note C_,4
	note G_,4, 40
	continue 10
	note F#,3
	note A_,3
	note C_,4
	note F#,4, 40
	snd_ret
.call4:
	note E_,4, 3
	note G_,4, 4
	note C_,5, 3
	note D_,5, 30
	note C_,5
	silence 20
	note B_,4, 30
	note C_,5
	note D_,5, 20
	note D_,5, 30
	note C_,5
	note E_,5, 20
	note D_,5, 30
	note C_,5
	note B_,4, 20
	snd_ret
.call5:
	note B_,4, 30
	note A_,4, 40
	note D_,5, 10
	note B_,4, 30
	note G_,4
	note E_,4, 20
	note F_,4, 80
	note G_,4
	snd_ret
SndData_BGM_Kagura_Ch2:
	envelope $77
	panning $22
	duty_cycle 3
	snd_call .call0
	snd_call .call1
	snd_call .call2
	snd_call .call1
	snd_call .call3
	snd_call .call1
	snd_call .call2
	snd_call .call1
	snd_call .call4
	snd_call .call5
	snd_call .call6
	snd_call .call7
	snd_call .call8
	snd_loop SndData_BGM_Kagura_Ch2
.call0:
	note A_,3, 5
	silence
	note A_,3
	silence
	note A_,4, 10
	note A_,3, 5
	silence
	note A_,3
	silence
	note A_,4, 10
	note G_,4
	note E_,4
	note G_,3, 5
	silence
	note G_,3
	silence
	note G_,4, 10
	note G_,3, 5
	silence
	note G_,3
	silence
	note G_,4, 10
	note F#,4
	note D_,4
	note D_,4, 5
	silence
	note D_,4
	silence
	note D_,5, 10
	note D_,4, 5
	silence
	note D_,4
	silence
	note D_,5, 10
	note D_,4, 5
	silence
	note D_,4
	silence
	note D_,5, 10
	note D_,4, 5
	silence
	note D_,4
	silence
	note D_,5, 10
	note D_,4, 5
	silence
	note D_,5, 20
	note D_,4, 5
	silence
	snd_loop .call0, $00, 2
	snd_ret
.call1:
	envelope $65
	note E_,5, 10
	note C_,5
	note B_,4
	note G_,4, 20
	note E_,4
	note C_,4
	note A_,3
	note D_,4, 10
	note B_,3
	note G_,3
	note D_,3, 20
	snd_ret
.call2:
	note A_,3, 10
	note D_,3
	note F#,3
	note A_,3
	note E_,4
	note C_,4
	note E_,4
	note G_,4
	note C_,5
	note E_,4
	note G_,4
	note B_,4
	note D_,5
	note F#,5
	note A_,5
	note D_,5
	snd_ret
.call3:
	note C_,3, 10
	note F#,3
	note A_,3
	note E_,3, 30
	note F#,3, 10
	note C_,4
	note D_,4
	note A_,3, 30
	note D_,4, 10
	note F#,4
	note A_,4
	note E_,4
	snd_ret
.call4:
	note C_,3, 10
	note F#,3
	note A_,3
	note E_,3, 30
	note F#,3, 10
	note C_,4
	note D_,4
	note A_,3, 30
	note D_,4, 20
	note B_,4
	snd_ret
.call5:
	envelope $77
	note A_,3, 5
	silence
	note A_,3
	silence
	note A_,4, 10
	note A_,3, 5
	silence
	note A_,3
	silence
	note A_,4, 10
	note A_,3, 5
	silence
	note A_,3
	silence
	note A_,4, 10
	note A_,3, 5
	silence
	note A_,3
	silence
	note A_,4, 10
	note A_,3, 5
	silence
	note F#,4, 10
	note G_,4
	note A_,4
	note G_,3, 5
	silence
	note G_,3
	silence
	note A_,4, 10
	note G_,3, 5
	silence
	note G_,3
	silence
	note A_,4, 10
	note G_,3, 5
	silence
	note G_,3
	silence
	note A_,4, 10
	note G_,3, 5
	silence
	note G_,3
	silence
	note A_,4, 10
	note G_,3, 5
	silence
	note F#,4, 10
	note G_,4
	note A_,4
	note F#,3, 5
	silence
	note F#,3
	silence
	note A_,4, 10
	note F#,3, 5
	silence
	note F#,3
	silence
	note A_,4, 10
	note F#,3, 5
	silence
	note F#,3
	silence
	note A_,4, 10
	note F#,3, 5
	silence
	note F#,3
	silence
	note A_,4, 10
	note F#,3, 5
	silence
	note F#,4, 10
	note G_,4
	note A_,4
	note F_,3, 5
	silence
	note F_,3
	silence
	note A_,4, 10
	note F_,3, 5
	silence
	note F_,3
	silence
	note F_,4, 10
	note G_,4
	note A_,4
	note G_,3, 5
	silence
	note G_,3
	silence
	note D_,4, 10
	note G_,3, 5
	silence
	note G_,3
	silence
	note G_,4, 10
	note D_,5
	note G_,4
	snd_ret
.call6:
	envelope $65
	note C_,5, 10
	note G_,5
	note C_,5, 5
	note C_,5
	note E_,5, 10
	note G_,5
	note C_,5
	note C_,4
	note A_,4
	note E_,3, 5
	note E_,3
	note G_,4, 10
	note C_,5, 5
	note C_,5
	note C_,4, 10
	note G_,4, 5
	note G_,4
	note F#,4, 10
	note G_,4
	note A_,4
	note C_,5, 10
	note G_,5
	note C_,5, 5
	note C_,5
	note E_,5, 10
	note G_,5
	note C_,5
	note C_,4
	note A_,4
	note F_,3, 5
	note F_,3
	note A_,4, 10
	note C_,5, 5
	note C_,5
	note C_,4, 10
	note A_,4, 5
	note A_,4
	note E_,4
	note A_,4
	note E_,4
	note C_,4
	note F_,3
	note A_,3
	note C_,5, 10
	note G_,5
	note C_,5, 5
	note C_,5
	note E_,5, 10
	note G_,5
	note C_,5
	note C_,4
	note A_,4
	note F#,3, 5
	note F#,3
	note G_,4, 10
	note C_,5, 5
	note C_,5
	note C_,4, 10
	note G_,4, 5
	note G_,4
	note F#,4, 10
	note G_,4
	note A_,4
	snd_ret
.call7:
	envelope $65
	fine_tune 12
	note F_,3, 10
	note A_,3
	note C_,4
	note A_,3
	note F_,2
	note F_,3
	note C_,3
	note C_,4
	note E_,3
	note G_,3
	note C_,4
	note G_,3
	note E_,2
	note E_,3
	note C_,3
	note E_,3
	note E_,3
	note A_,3
	note C_,4
	note A_,3
	note E_,2
	note E_,3
	note C_,3
	note A_,3
	note F#,3
	note A_,3
	note C_,4
	note A_,3
	note F#,2
	note F#,3
	note D_,3
	note C_,4
	note F_,3, 10
	note A_,3
	note C_,4
	note A_,3
	note F_,2
	note F_,3
	note C_,3
	note C_,4
	note E_,3
	note G_,3
	note C_,4
	note G_,3
	note E_,2
	note E_,3
	note C_,3
	note E_,3
	fine_tune -12
	snd_ret
.call8:
	envelope $67
	note A_,4, 30
	note F_,5
	note E_,5, 20
	note B_,4, 30
	note G_,5, 20
	note F_,5
	note E_,5, 10
	snd_ret
SndData_BGM_Kagura_Ch3:
	wave_vol $80
	panning $44
	wave_id $04
	wave_cutoff 30
	snd_call .call0
	snd_call .call1
	snd_call .call0
	snd_call .call2
	snd_call .call3
	snd_call .call4
	snd_call .call5
	snd_call .call6
	snd_call .call7
	snd_loop SndData_BGM_Kagura_Ch3
.call0:
	note G_,3, 5
	note A_,3
	note A_,3, 10
	note A_,3
	note G_,3, 5
	note A_,3
	note A_,3, 10
	note A_,3
	note A_,3
	note A_,3
	note F#,3, 5
	note G_,3
	note G_,3, 10
	note G_,3
	note F#,3, 5
	note G_,3
	note G_,3, 10
	note G_,3
	note G_,3
	note G_,3
	note F_,3, 5
	note F#,3
	note F#,3, 10
	note F#,3
	note F_,3, 5
	note F#,3
	note F#,3, 10
	note F#,3
	note F#,3
	note F#,3
	snd_ret
.call1:
	note C_,4, 5
	note D_,4
	note D_,4, 10
	note D_,4
	note C_,4, 5
	note D_,4
	note D_,4, 10
	note D_,4
	note D_,4
	note D_,4
	snd_ret
.call2:
	note C_,4, 5
	note D_,4
	note D_,4, 10
	note D_,4
	wave_cutoff 60
	note C_,4, 20
	wave_cutoff 30
	note F#,3, 10
	note G_,3
	note G#,3
	snd_ret
.call3:
	wave_cutoff 0
	note A_,3, 30
	note A_,4
	note G_,4
	note D_,4
	note E_,4, 20
	note C_,4
	note F#,3, 30
	note F#,4
	note D_,4
	note C_,4
	note D_,4, 20
	note G_,3
	snd_loop .call3, $00, 3
	note A_,3, 30
	note A_,4
	note G_,4
	note D_,4
	note E_,4, 20
	note C_,4
	note F#,3, 30
	note F#,4
	note C_,4
	note F_,4
	note F_,3, 20
	note G_,3
	snd_ret
.call4:
	wave_cutoff 30
	note G_,3, 5
	note A_,3
	note A_,3, 10
	note A_,3
	note G_,3, 5
	note A_,3
	note A_,3, 10
	note A_,3
	note G_,3, 5
	note A_,3
	note A_,3, 10
	note A_,3
	note G#,3, 5
	note A_,3
	note A_,3, 10
	note E_,3
	note A_,3
	note A_,3
	note E_,3
	note A_,3
	note F#,3, 5
	note G_,3
	note G_,3, 10
	note G_,3
	note F#,3, 5
	note G_,3
	note G_,3, 10
	note G_,3
	note F#,3, 5
	note G_,3
	note G_,3, 10
	note G_,3
	note F#,3, 5
	note G_,3
	note G_,3, 10
	note D_,3
	note G_,3
	note G_,3
	note D_,3
	note G_,3
	note F_,3, 5
	note F#,3
	note F#,3, 10
	note F#,3
	note F_,3, 5
	note F#,3
	note F#,3, 10
	note F#,3
	note F_,3, 5
	note F#,3
	note F#,3, 10
	note F#,3
	note F_,3, 5
	note F#,3
	note F#,3, 10
	note C_,4
	note F#,3
	note D_,3
	note A_,3
	note D_,3
	note E_,3, 5
	note F_,3
	note F_,3, 10
	note F_,3
	note E_,3, 5
	note F_,3
	note F_,3, 10
	note F_,3
	note E_,3, 5
	note F_,3
	note F_,3, 10
	note F#,3, 5
	note G_,3
	note G_,3, 10
	note G_,3
	wave_cutoff 60
	note D_,4, 20
	note C_,4
	note G_,3, 10
	wave_cutoff 30
	snd_ret
.call5:
	note G_,3, 5
	note A_,3
	note A_,3, 10
	note A_,3
	note G_,3, 5
	note A_,3
	note A_,3, 10
	note A_,3
	note G_,3, 5
	note A_,3
	note A_,3, 10
	note F#,3, 5
	note G_,3
	note G_,3, 10
	note G_,3
	note F#,3, 5
	note G_,3
	note G_,3, 10
	note G_,3
	note F#,3, 5
	note G_,3
	note G_,3, 10
	note F_,3, 5
	note F#,3
	note F#,3, 10
	note F#,3
	note F_,3, 5
	note F#,3
	note F#,3, 10
	note F#,3
	note F_,3, 5
	note F#,3
	note F#,3, 10
	note E_,3, 5
	note F_,3
	note F_,3, 10
	note F_,3
	wave_cutoff 60
	note A_,3, 20
	wave_cutoff 30
	note D_,4, 10
	note C_,4
	note E_,3
	note B_,3, 5
	note C_,4
	note C_,4, 10
	note C_,4
	note B_,3, 5
	note C_,4
	note C_,4, 10
	note C_,4
	note B_,3, 5
	note C_,4
	note C_,4, 10
	note C#,4, 5
	note D_,4
	note D_,4, 10
	note D_,4
	note C#,4, 5
	note D_,4
	note D_,4, 10
	note D_,4
	note C#,4, 5
	note D_,4
	note D_,4, 10
	snd_ret
.call6:
	wave_cutoff 0
	note F_,3, 30
	note A_,3, 10
	note C_,4
	note D_,4
	note F_,3, 20
	note E_,3, 40
	note E_,3, 20
	note G_,3
	note A_,3, 40
	continue 10
	note A_,3, 10
	note E_,3
	note C_,3
	note D_,3, 60
	continue 10
	note D_,3
	note F_,3, 30
	note C_,4
	note F_,3, 20
	note E_,3, 30
	note B_,3
	note E_,3, 20
	snd_ret
.call7:
	note F_,3, 30
	note F_,4
	note C_,4, 20
	note G_,3, 30
	note G_,4
	note D_,4, 20
	wave_cutoff 30
	snd_ret
SndData_BGM_Kagura_Ch4:
	panning $88
	snd_call .call0
	snd_call .call1
	snd_call .call0
	snd_call .call2
	snd_call .call3
	snd_call .call4
	snd_call .call3
	snd_call .call5
	snd_call .call3
	snd_call .call4
	snd_call .call3
	snd_call .call5
	snd_call .call6
	snd_call .call7
	snd_call .call6
	snd_call .call8
	snd_call .call0
	snd_call .call1
	snd_call .call0
	snd_call .call2
	snd_call .call9
	snd_call .callA
	snd_loop SndData_BGM_Kagura_Ch4
.call0:
	envelope $61
	wait 54
	wait 10
	wait 54
	wait 10
	envelope $62
	wait 36
	wait 10
	envelope $61
	wait 54
	wait 10
	snd_loop .call0, $00, 6
	snd_ret
.call1:
	envelope $61
	wait 54
	wait 10
	wait 54
	wait 10
	envelope $62
	wait 36
	wait 10
	envelope $61
	wait 54
	wait 5
	envelope $62
	wait 36
	wait 5
	envelope $61
	wait 54
	wait 10
	wait 54
	wait 10
	envelope $62
	wait 36
	wait 10
	envelope $61
	wait 54
	wait 5
	envelope $62
	wait 36
	wait 5
	snd_ret
.call2:
	envelope $61
	wait 54
	wait 5
	envelope $62
	wait 36
	wait 5
	envelope $61
	wait 54
	wait 5
	wait 54
	wait 5
	envelope $62
	wait 36
	wait 10
	envelope $61
	wait 54
	wait 10
	wait 54
	wait 10
	wait 54
	wait 5
	wait 54
	wait 5
	envelope $62
	wait 36
	wait 2
	wait 36
	wait 3
	wait 36
	wait 5
	wait 36
	wait 5
	wait 36
	wait 5
	snd_ret
.call3:
	envelope $61
	wait 54
	wait 10
	wait 54
	wait 10
	envelope $53
	wait 17
	wait 10
	envelope $62
	wait 36
	wait 20
	envelope $34
	wait 38
	wait 10
	envelope $44
	wait 38
	wait 10
	envelope $61
	wait 54
	wait 10
	snd_ret
.call4:
	envelope $11
	wait 33
	wait 10
	envelope $61
	wait 54
	wait 10
	wait 54
	wait 20
	envelope $62
	wait 36
	wait 20
	envelope $61
	wait 54
	wait 20
	snd_ret
.call5:
	envelope $11
	wait 33
	wait 10
	envelope $61
	wait 54
	wait 10
	envelope $53
	wait 17
	wait 20
	envelope $62
	wait 36
	wait 10
	envelope $44
	wait 38
	wait 10
	envelope $54
	wait 38
	wait 20
	snd_ret
.call6:
	envelope $61
	wait 54
	wait 10
	wait 54
	wait 10
	envelope $53
	wait 17
	wait 20
	envelope $62
	wait 36
	wait 10
	envelope $61
	wait 54
	wait 10
	envelope $53
	wait 17
	wait 20
	snd_loop .call6, $00, 3
	snd_ret
.call7:
	envelope $61
	wait 54
	wait 10
	wait 54
	wait 10
	envelope $53
	wait 17
	wait 10
	envelope $61
	wait 54
	wait 5
	wait 54
	wait 5
	envelope $62
	wait 36
	wait 10
	envelope $53
	wait 17
	wait 20
	envelope $61
	wait 54
	wait 10
	snd_ret
.call8:
	envelope $61
	wait 54
	wait 10
	envelope $62
	wait 36
	wait 10
	wait 36
	wait 2
	wait 36
	wait 3
	wait 36
	wait 5
	wait 36
	wait 5
	wait 36
	wait 5
	wait 36
	wait 5
	wait 36
	wait 2
	wait 36
	wait 3
	wait 36
	wait 5
	wait 36
	wait 5
	envelope $44
	wait 38
	wait 5
	wait 16
	wait 5
	envelope $54
	wait 38
	wait 5
	wait 50
	wait 5
	snd_ret
.call9:
	envelope $61
	wait 54
	wait 10
	wait 54
	wait 5
	wait 54
	wait 5
	envelope $62
	wait 36
	wait 10
	envelope $61
	wait 54
	wait 5
	wait 54
	wait 5
	snd_loop .call9, $00, 7
	envelope $61
	wait 54
	wait 10
	wait 54
	wait 5
	wait 54
	wait 5
	envelope $62
	wait 36
	wait 5
	wait 36
	wait 5
	wait 36
	wait 5
	wait 36
	wait 5
.call9b:
	envelope $61
	wait 54
	wait 10
	wait 54
	wait 5
	wait 54
	wait 5
	envelope $62
	wait 36
	wait 10
	envelope $61
	wait 54
	wait 5
	wait 54
	wait 5
	snd_loop .call9b, $00, 3
	envelope $61
	wait 54
	wait 10
	envelope $34
	wait 38
	wait 10
	envelope $44
	wait 38
	wait 10
	envelope $54
	wait 38
	wait 10
	snd_ret
.callA:
	envelope $61
	wait 54
	wait 10
	envelope $31
	wait 33
	wait 10
	envelope $53
	wait 17
	wait 20
	snd_loop .callA, $00, 7
	envelope $62
	wait 36
	wait 10
	envelope $34
	wait 38
	wait 10
	envelope $44
	wait 38
	wait 10
	envelope $54
	wait 38
	wait 10
.callAb:
	envelope $61
	wait 54
	wait 10
	envelope $31
	wait 33
	wait 10
	envelope $53
	wait 17
	wait 20
	snd_loop .callAb, $00, 3
	envelope $62
	wait 36
	wait 10
	wait 36
	wait 10
	wait 36
	wait 10
	envelope $61
	wait 54
	wait 10
.callAc:
	envelope $62
	wait 36
	wait 10
	envelope $61
	wait 54
	wait 20
	snd_loop .callAc, $00, 3
	envelope $62
	wait 36
	wait 10
	envelope $61
	wait 54
	wait 10
	envelope $62
	wait 36
	wait 10
	wait 36
	wait 10
	envelope $44
	wait 38
	wait 10
	envelope $54
	wait 38
	wait 20
	snd_ret
