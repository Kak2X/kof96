SndHeader_BGM_Arashi:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_Arashi_Ch1 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_Arashi_Ch2 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_Arashi_Ch3 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_Arashi_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_BGM_Arashi_Ch1:
	envelope $72
	panning $11
	duty_cycle 2
	snd_call .call0
	snd_call .call1
	snd_call .call2
	snd_call .call3
	snd_call .call4
	snd_call .call5
	snd_call .call4
	snd_call .call6
	snd_call .call7
	snd_call .call8
	snd_loop SndData_BGM_Arashi_Ch1
.call0:
	note C#,4, 7
	note G_,4
	note C#,4
	note G_,4, 14
	note C#,4, 7
	note F#,4, 14
	note A_,3, 7
	note F#,4
	note A_,3
	note A_,3
	note F#,4
	note F#,4
	note A_,3
	note D_,4
	snd_ret
.call1:
	note C#,4, 7
	note G_,4
	note C#,4
	note G_,4, 14
	note C#,4, 7
	note F#,4, 14
	note A_,3, 7
	note A_,4
	note A_,4
	note E_,4
	note G#,4
	note E_,4
	note F_,4
	note B_,3
	snd_ret
.call2:
	envelope $11
	duty_cycle 3
	note A_,2, 28
	envelope $78
	note A_,3, 7
	note C_,4
	note E_,4
	note G_,4
	silence 14
	note A_,4, 28
	note E_,4, 7
	silence
	note F#,4, 21
	note D_,4, 7
	silence 14
	note A_,3, 28
	note D_,4
	note A_,3, 7
	silence
	note C_,4, 21
	note D_,4, 7
	envelope $11
	note D_,2, 28
	wait2 21
	envelope $78
	note F_,3, 14
	note A_,3, 7
	note C_,4
	silence
	note D_,4, 21
	note C_,4, 7
	envelope $11
	note C_,2, 112
	envelope $78
	note A_,3, 7
	note C_,4
	note E_,4
	note G_,4
	silence 14
	note A_,4, 28
	note E_,4, 7
	silence
	note F#,4, 21
	note D_,4, 7
	silence 14
	note A_,3
	silence
	note D_,4
	note A_,3, 7
	note D_,4
	silence
	note A_,3
	note D_,4, 21
	note C_,4, 14
	snd_ret
.call3:
	envelope $11
	note C_,2, 7
	envelope $72
	duty_cycle 2
	note G_,3, 21
	note E_,3
	note G#,3, 28
	note D_,3, 7
	note E_,3, 14
	note E_,3, 21
	note G_,3
	note A_,3
	note G#,3, 14
	note G_,3
	snd_ret
.call4:
	envelope $78
	duty_cycle 3
	note D_,4, 21
	note E_,4, 35
	silence 14
	note D_,4, 3
	note E_,4, 4
	note G_,4, 35
	wait2 28
	silence 14
	note G_,4, 28
	note A_,4
	note G_,4, 7
	silence
	snd_ret
.call5:
	note F#,4, 14
	silence 7
	note D_,4, 35
	silence 21
	note F#,3, 14
	note G_,3, 7
	note A_,3
	note A#,3
	wait2 21
	note A_,3
	note F_,3, 14
	silence
	note D_,4
	silence 7
	note D_,4, 14
	note E_,3, 7
	snd_ret
.call6:
	note F#,4, 14
	silence 7
	note D_,4, 35
	silence 21
	note F_,4, 14
	note G_,4, 7
	note A_,4
	note A#,4
	wait2 21
	note A_,4
	note G#,4
	note E_,4, 10
	silence 11
	note B_,3, 7
	note D_,4, 21
	snd_ret
.call7:
	note E_,4, 56
	silence 14
	note G_,4
	silence 7
	note F_,4, 21
	note E_,4, 28
	silence 14
	note B_,3, 28
	silence 7
	note C_,4, 21
	note D_,4, 14
	note D_,4
	note E_,4, 7
	note E_,4, 28
	silence 14
	note G_,3, 2
	note G_,4, 3
	note G#,4, 2
	note A_,4, 28
	note A_,3, 14
	note D_,4
	note D_,3, 7
	note C_,4, 21
	note A_,3, 28
	silence 14
	note G_,3, 5
	note A_,3, 4
	note B_,3, 5
	note C_,4
	note D_,4, 4
	note E_,4, 5
	note C_,4, 28
	silence 14
	note C_,4, 28
	note F_,4, 14
	note A_,3, 28
	note B_,3
	silence 14
	note E_,4, 28
	note D_,4, 21
	note G_,3
	snd_ret
.call8:
	note C_,4, 14
	silence 7
	note D_,4, 35
	silence 7
	note E_,4, 2
	note F_,4, 3
	note F#,4, 2
	note G_,4, 35
	silence 7
	note G#,4, 21
	note E_,4, 7
	silence 14
	note D_,4, 21
	note B_,3, 10
	silence 11
	note B_,3, 7
	note F_,4, 21
	snd_ret
SndData_BGM_Arashi_Ch2:
	envelope $62
	panning $22
	duty_cycle 2
	snd_call .call0
	snd_call .call1
	snd_call .call2
	snd_call .call3
	snd_call .call2
	snd_call .call4
	snd_call .call5
	snd_call .call6
	snd_call .call5
	snd_call .call7
	snd_call .call8
	snd_call .call9
	snd_call .callA
	snd_loop SndData_BGM_Arashi_Ch2
.call0:
	note E_,4, 7
	note C_,5
	note E_,4
	note C_,5, 14
	note E_,4, 7
	note C_,5, 14
	note D_,4, 7
	note B_,4
	note D_,4
	note D_,4
	note C_,5
	note B_,4
	note D_,4
	note F#,4
	snd_ret
.call1:
	note E_,4, 7
	note C_,5
	note E_,4
	note C_,5, 14
	note E_,4, 7
	note C_,5, 14
	note D_,4, 7
	note D_,5
	note C#,5
	note A_,4
	note C_,5
	note G#,4
	note A#,4
	note E_,4
	snd_ret
.call2:
	note C_,5, 7
	note C_,5
	note C_,4
	note C_,5
	note A_,3
	note A_,4
	note C_,4
	note C_,5, 21
	note D_,5, 7
	note G_,4
	note C_,4
	note C_,5
	note C_,4
	note B_,4, 21
	note B_,3, 7
	note B_,4
	note B_,3
	note B_,4
	note B_,3
	note E_,4, 21
	note E_,3, 7
	note E_,4
	note E_,3
	note B_,4
	note B_,3
	note E_,4
	snd_ret
.call3:
	note G_,4, 7
	note G_,3
	note G_,4
	note C_,5
	note A_,3
	note A_,4
	note C_,4
	note C_,5, 21
	note G_,3, 7
	note G_,4
	note C_,4
	note C_,5
	note C_,4
	note G#,4, 21
	note G#,3, 7
	note G#,4
	note G#,3
	note A#,3
	note G#,4
	note D_,5
	note G_,5
	note E_,5
	note G_,4
	note E_,4
	note D#,5
	note F_,4
	note A#,4
	note C#,5
	snd_ret
.call4:
	note D_,3, 7
	note E_,3
	note A_,2
	note E_,3
	note A_,2
	note A_,2
	note C_,4, 14
	note A_,2, 7
	note A_,3
	note A_,2
	note A_,2
	note C#,4, 14
	note G_,2, 7
	note G_,2
	note G_,3
	note A_,3
	note A_,2
	note A_,3
	note A_,2
	note A_,2
	note C_,4, 14
	note A_,2, 7
	note D_,4
	note A_,2
	note A_,2
	note C#,4, 14
	note C_,4
	snd_ret
.call5:
	note G_,4, 7
	note C_,4
	note G_,4
	note A_,3
	note G_,4
	note C_,4, 14
	note G_,4
	note A_,3, 7
	note G_,4
	note A_,3
	note G_,4
	note A_,3, 14
	note C_,4, 7
	snd_loop .call5, $00, 2
	snd_ret
.call6:
	note F#,4, 7
	note B_,3
	note F#,4
	note A_,3
	note C#,5
	note A_,4, 14
	note F#,4
	note A_,3, 7
	note F#,4
	note A_,3
	note F#,4
	note A_,3, 14
	note E_,5
	note C_,5, 7
	note G_,4
	note D_,4
	note A#,3
	note A_,3
	note F_,3
	note A#,3
	note D_,4
	note G_,4
	note C_,5
	note A_,4
	note D_,5
	note G_,5
	note F_,5
	note D_,5
	snd_ret
.call7:
	note F#,4, 7
	note B_,3
	note F#,4
	note A_,3
	note C#,5
	note A_,4, 14
	note F#,4
	note A_,3, 7
	note F#,4
	note A_,3
	note F#,4
	note F#,3, 14
	note D_,5
	note C_,5, 7
	note G_,4
	note D_,4
	note A#,3
	note A_,3
	note F_,3
	note E_,3
	note E_,4, 5
	note B_,3, 4
	note E_,4, 5
	note G_,4
	note D_,4, 4
	note F_,4, 5
	note G#,4
	note E_,4, 4
	note G#,4, 5
	note A_,4
	note D_,5, 4
	note E_,5, 5
	snd_ret
.call8:
	note G_,5, 7
	note G_,4
	note D_,5
	note G_,4
	snd_loop .call8, $00, 14
	snd_ret
.call9:
	note G_,5, 7
	note G_,4
	note C_,5
	note G_,4
	snd_loop .call9, $00, 6
	snd_ret
.callA:
	note G_,5, 7
	note G_,4
	note D_,5
	note G_,4
	snd_loop .callA, $00, 8
	note F_,5, 7
	note F_,4
	note D_,5
	note F_,4
	note D_,5
	note E_,4
	note B_,4
	note E_,5
	note G_,5
	note G_,4
	note F_,5
	note G_,4
	note E_,5
	note F_,4
	note C_,5
	note F_,4
	snd_ret
SndData_BGM_Arashi_Ch3:
	wave_vol $80
	panning $44
	wave_id $04
	wave_cutoff 50
	snd_call .call0
	snd_call .call1
	snd_call .call2
	snd_call .call3
	snd_call .call2
	snd_call .call4
	snd_call .call5
	snd_call .call6
	snd_call .call5
	snd_call .call7
	snd_call .call8
	snd_call .call9
	snd_call .call8
	snd_call .callA
	snd_loop SndData_BGM_Arashi_Ch3
.call0:
	note G_,3, 7
	note A_,3
	note D_,3
	note A_,3, 14
	note G_,3, 7
	note D_,4, 14
	note D_,3, 7
	note F#,3, 14
	note D_,3, 7
	note D_,4, 14
	note C_,4
	snd_ret
.call1:
	note G_,3, 7
	note A_,3
	note D_,3
	note A_,3, 14
	note G_,3, 7
	note D_,4, 14
	note D_,3, 7
	note D_,4
	note C#,4
	note A_,3
	note C_,4
	note G#,3
	note A#,3
	note E_,3
	snd_ret
.call2:
	note C_,4, 14
	note A_,3, 7
	note G_,4, 28
	note D_,4, 21
	note D_,4, 14
	note C_,4
	wave_cutoff 0
	note C_,5, 42
	wave_cutoff 50
	note E_,4, 7
	note C_,5, 14
	note G_,4, 7
	note E_,3, 14
	note E_,4, 21
	note G_,3, 14
	note E_,3, 7
	snd_ret
.call3:
	wave_cutoff 0
	note F_,4, 56
	note D_,4, 21
	wave_cutoff 50
	note F_,3, 14
	note F_,3, 7
	note G_,3
	wave_cutoff 0
	note A#,3, 56
	wait2 7
	wave_cutoff 50
	note G_,4
	note E_,4
	note G_,3
	note E_,4
	note D#,4
	note F_,3
	note A#,3
	note C#,4
	snd_ret
.call4:
	note G_,3, 14
	note E_,3, 7
	note A_,3, 21
	note C_,4, 14
	note E_,3, 7
	note A_,3, 14
	note C#,3, 7
	note C#,4, 28
	note G_,3, 14
	note E_,3, 7
	note A_,3, 14
	note E_,3, 7
	note C_,4, 14
	note D_,3, 7
	note D_,4, 14
	note C#,3, 7
	note C#,4, 14
	note C_,4
	snd_ret
.call5:
	note A_,3, 7
	note G#,3
	note A_,3
	note E_,4, 14
	note A_,3, 7
	note A_,3
	note G#,3
	note A_,3
	note E_,4, 14
	note A_,3, 7
	note E_,3
	note A_,3
	note E_,4, 14
	note C_,4, 7
	note G_,3
	note C_,4
	note G_,4, 14
	note G_,3, 7
	note C_,4
	note G_,3
	note C_,4
	note G_,4, 14
	note G_,3, 7
	note G_,3
	note D_,4
	note E_,4, 14
	note B_,3, 7
	note F#,3
	note B_,3
	note F#,4, 14
	note F#,3, 7
	note B_,3
	note F#,3
	note B_,3
	note F#,4, 14
	note F#,3, 7
	note F#,3
	note A_,3
	note D_,4, 14
	snd_ret
.call6:
	note A#,3, 7
	note F_,3
	note A#,3
	note F_,4, 14
	note F_,3, 7
	note A#,4, 14
	note A#,3, 7
	note A_,4, 14
	note A#,3, 7
	note F_,4
	note G_,4
	note D_,4
	note F_,3
	snd_ret
.call7:
	note A#,3, 7
	note F_,3
	note A#,3
	note F_,4, 14
	note F_,3, 7
	note D_,4
	note E_,4, 14
	note B_,3
	note E_,3
	note G#,3, 21
	snd_ret
.call8:
	note F_,3, 14
	note C_,3, 7
	note F_,3, 14
	note C_,3, 7
	note B_,3
	note C_,4, 14
	note C_,3, 7
	note C_,4, 14
	note C_,3, 7
	note A_,3, 21
	note E_,3, 14
	note B_,2, 7
	note E_,3, 14
	note B_,2, 7
	note A_,3
	note B_,3, 14
	note B_,2, 7
	note B_,3, 14
	note B_,2, 7
	note G_,3, 21
	snd_ret
.call9:
	note A_,3, 14
	note E_,3, 7
	note A_,3, 14
	note E_,3, 7
	note D_,4
	note E_,4, 14
	note E_,3, 7
	note E_,4, 14
	note E_,3, 7
	note C_,4, 21
	note A_,3, 14
	note E_,3, 7
	note A_,3, 14
	note E_,3, 7
	note C_,4
	note D_,4, 14
	note D_,3, 7
	note D_,4, 14
	note D_,3, 7
	note A_,3, 21
	snd_ret
.callA:
	note D_,4, 14
	note D_,3, 7
	note C_,4, 14
	note D_,3, 7
	note A_,3, 14
	note D_,3, 7
	note D_,3
	note D_,4, 14
	note D_,3, 7
	note C_,4, 21
	note E_,3, 14
	note B_,2, 7
	note E_,3, 14
	note B_,2, 7
	note G#,3, 14
	note B_,2, 7
	wave_cutoff 0
	note B_,3, 21
	note D_,4, 3
	note E_,4, 4
	note D_,4, 3
	note E_,4, 4
	note D_,4, 3
	note E_,4, 4
	note D_,4, 7
	wave_cutoff 50
	snd_ret
SndData_BGM_Arashi_Ch4:
	panning $88
	snd_call .call0
	snd_call .call1
	snd_call .call2
	snd_call .call3
	snd_call .call4
	snd_call .call5
	snd_call .call5
	snd_loop SndData_BGM_Arashi_Ch4
.call0:
	envelope $61
	wait 54
	wait 7
	envelope $62
	wait 36
	wait 14
	envelope $61
	wait 54
	wait 14
	wait 54
	wait 7
	wait 54
	wait 14
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
	wait 14
	envelope $61
	wait 54
	wait 14
	snd_ret
.call1:
	envelope $61
	wait 54
	wait 7
	envelope $62
	wait 36
	wait 14
	envelope $61
	wait 54
	wait 14
	wait 54
	wait 7
	wait 54
	wait 14
	envelope $62
	wait 36
	wait 14
	envelope $61
	wait 54
	wait 14
	envelope $62
	wait 36
	wait 7
	envelope $61
	wait 54
	wait 14
	wait 54
	wait 7
	snd_ret
.call2:
	envelope $61
	wait 54
	wait 7
	wait 54
	wait 7
	envelope $31
	wait 33
	wait 14
	envelope $62
	wait 36
	wait 14
	envelope $31
	wait 33
	wait 7
	envelope $61
	wait 54
	wait 14
	envelope $31
	wait 33
	wait 7
	envelope $61
	wait 54
	wait 7
	envelope $31
	wait 33
	wait 7
	envelope $62
	wait 36
	wait 14
	envelope $31
	wait 33
	wait 7
	envelope $61
	wait 54
	wait 7
	snd_loop .call2, $00, 6
	snd_ret
.call3:
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
	wait 21
	envelope $62
	wait 36
	wait 14
	envelope $61
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
	snd_ret
.call4:
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
	wait 21
	envelope $62
	wait 36
	wait 14
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
	wait 7
	envelope $61
	wait 54
	wait 7
	snd_ret
.call5:
	envelope $61
	wait 54
	wait 14
	wait 54
	wait 7
	wait 54
	wait 7
	envelope $62
	wait 36
	wait 14
	envelope $61
	wait 54
	wait 7
	wait 54
	wait 14
	envelope $62
	wait 36
	wait 14
	envelope $61
	wait 54
	wait 7
	envelope $62
	wait 36
	wait 14
	envelope $61
	wait 54
	wait 14
	snd_loop .call5, $00, 7
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
	wait 14
	envelope $62
	wait 36
	wait 7
	envelope $61
	wait 54
	wait 14
	envelope $62
	wait 36
	wait 7
	wait 36
	wait 7
	envelope $61
	wait 54
	wait 7
	envelope $44
	wait 38
	wait 7
	envelope $54
	wait 38
	wait 7
	snd_ret
