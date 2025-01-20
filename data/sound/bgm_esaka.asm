SndHeader_BGM_Esaka:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_Esaka_Ch1 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_Esaka_Ch2 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_Esaka_Ch3 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_Esaka_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_BGM_Esaka_Ch1:
	envelope $77
	panning $11
	duty_cycle 3
	note G_,3, 80
.loop0:
	envelope $77
	snd_call .call0
	snd_call .call1
	snd_call .call2
	snd_call .call3
	snd_call .call4
	snd_call .call5
	snd_call .call6
	snd_call .call7
	snd_call .call8
	snd_loop .loop0
	;--
	; [TCRF] Unreferenced song section
.unused_call:
	envelope $77
	duty_cycle 3
	note G_,3, 40
	note G_,2, 5
	silence
	note G_,3, 30
	;--
.call0:
	note G_,3, 10
	note G_,3, 5
	silence
	note A#,2
	silence
	note F_,3, 10
	note F_,3, 5
	silence
	note A#,2
	silence
	note G_,3, 10
	note G_,3, 5
	silence
	note A#,3, 80
	note A#,3, 10
	note A#,3, 5
	silence
	note D_,3
	silence
	note A_,3, 10
	note A_,3, 5
	silence
	note D_,3
	silence
	note A#,3, 10
	note A#,3, 5
	silence
	note C_,4, 80
	note C_,4, 10
	note C_,4, 5
	silence
	note G_,3
	silence
	note D_,4, 10
	note D_,4, 5
	silence
	note G_,3
	silence
	note C_,4, 10
	note C_,4, 5
	silence
	note D_,4, 80
	snd_ret
.call1:
	note A_,3, 10
	note A_,3, 5
	silence
	note D_,3
	silence
	note A#,3, 10
	note A#,3, 5
	silence
	note D_,3
	silence
	note C_,4, 20
	snd_ret
.call2:
	envelope $11
	note C_,2, 60
	snd_ret
.call3:
	envelope $78
	note G_,4, 10
	note D_,4
	note A_,4
	note A#,4, 13
	silence 7
	note C_,5, 20
	note A#,4, 10
	note F_,4
	note G_,4, 30
	envelope $11
	note G_,2, 40
	envelope $78
	note G_,4, 10
	note D_,4
	note A_,4
	note A#,4, 13
	silence 7
	note C_,5, 20
	note A#,4, 10
	note A_,4
	note G_,4
	snd_ret
.call4:
	note A#,4, 40
	silence 10
	note A#,4
	note A_,4
	note A#,4
	note A_,4, 20
	silence 10
	note C_,5, 30
	note F_,4, 20
	note G_,4, 30
	envelope $11
	wait 60
	note D_,3, 10
	note C_,3
	note D_,3
	note F_,3
	note D_,3, 20
	snd_ret
.call5:
	envelope $78
	note E_,4, 2
	note F_,4
	note G_,4
	note A_,4
	note A#,4
	note C_,5, 30
	silence 10
	note C_,5
	note G_,4
	note A#,4
	note C_,5, 13
	silence 7
	note C_,5, 10
	note A#,4
	note C_,5
	note G_,4
	note F_,5, 20
	silence 10
	note F_,5
	note G_,4, 20
	envelope $11
	note G_,2, 40
	wait2 10
	snd_ret
.call6:
	envelope $11
	note G_,2, 40
	envelope $78
	note G_,4, 20
	note A_,4
	note A#,4, 40
	silence 10
	note G_,4
	note A_,4
	note A#,4
	note C_,5, 20
	silence 10
	note D_,5, 30
	note F_,5, 20
	note E_,5, 30
	silence 10
	note E_,5
	note D_,5
	note E_,5
	note G_,5, 30
	silence 10
	note C_,5, 40
	silence 10
	snd_ret
.call7:
	envelope $78
	note D_,5, 60
	silence 10
	note A_,5
	wait2 60
	note F_,5, 10
	note G_,5
	wait2 60
	silence 10
	note A_,5, 30
	note G_,5, 20
	snd_ret
.call8:
	note A_,5, 13
	note A#,5, 14
	note C_,6, 13
	note D_,6, 40
	silence 10
	note D_,6
	note F_,5
	note G_,5, 30
	note F_,5, 20
	note G_,5, 10
	note F_,5
	note E_,5
	note F_,5, 30
	silence 10
	note G_,5, 30
	note E_,5, 20
	silence 10
	note A_,5
	note A#,5
	note C_,6
	note F_,6, 13
	note E_,6, 14
	note C_,6, 13
	note D_,6, 80
	snd_ret
SndData_BGM_Esaka_Ch2:
	envelope $62
	panning $22
	duty_cycle 2
.loop0:
	snd_call .call0
	snd_call .call1
	snd_call .call2
	envelope $58
	note G_,3, 10
	note C_,4
	note C#,4
	snd_call .call3
	snd_call .call4
	snd_call .call3
	snd_call .call5
	snd_loop .loop0
.call0:
	envelope $62
	duty_cycle 2
	note G_,5, 10
	note D_,5
	note D_,6
	note D_,5
	note A#,5
	note D_,5
	note C_,6
	note D_,5
	note A#,5
	note D_,5
	note A_,5
	note D_,5
	note C_,6
	note D_,5
	note A_,5
	note D_,5
	snd_loop .call0, $00, 4
	snd_ret
.call1:
	envelope $67
	duty_cycle 0
	note F_,3, 10
	note F_,3, 5
	silence
	note A#,2
	silence
	note G_,3, 30
	note G_,3, 5
	silence
	note G_,3
	silence
	note G_,3, 10
	note G_,3, 5
	silence
	note A#,2
	silence
	note G_,3, 10
	note G_,3, 5
	silence
	note G_,3
	silence
	note A#,2, 10
	note G_,3, 5
	silence
	note F_,3, 10
	note F_,3, 5
	silence
	note A#,2
	silence
	note G_,3, 30
	note G_,3, 5
	silence
	note G_,3
	silence
	note G_,3, 10
	note G_,3, 5
	silence
	note A#,2
	silence
	note G_,3, 10
	note G_,3, 5
	silence
	note G_,3
	silence
	note A_,3, 20
	note A#,3
	note D_,3, 5
	silence
	note A#,3, 15
	silence 5
	note A#,3, 10
	note D_,3, 5
	silence
	note A#,3, 10
	note F_,3, 20
	note F_,2, 5
	silence
	note F_,3, 30
	note C_,3, 20
	note G_,3, 10
	note F_,3
	note G_,3
	envelope $11
	note G_,2, 20
	envelope $67
	note G_,3, 10
	note F_,3
	note G_,3
	silence
	note G_,4
	note F_,4
	note G_,4
	note A#,4
	note G_,4, 20
	silence 10
	snd_ret
.call2:
	note F_,3, 20
	note F_,2, 5
	silence
	note F_,3, 30
	note F_,2, 5
	silence
	note F_,3, 10
	note F_,2, 10
	note F_,3
	note F_,2, 5
	silence
	note F_,2
	silence
	note F_,3, 10
	note F_,3, 5
	silence
	note F_,2, 10
	note F#,3
	note F_,3, 10
	note G_,3
	note G_,2, 2
	silence 8
	note G_,2, 2
	silence 8
	note A#,3, 10
	note G_,3
	note G_,2, 2
	silence 8
	note F_,3, 10
	wait2 10
	note G_,3
	silence
	note F_,2, 2
	silence 8
	note G_,3, 20
	note A_,3
	note D#,3, 40
	note D#,3, 10
	note A#,2, 5
	silence
	note A#,2
	silence
	note D#,3, 10
	wait2 10
	note A#,2, 5
	silence
	note A#,2, 2
	silence 8
	note A#,3, 20
	note A#,2, 10
	note A#,3, 20
	note A_,3, 10
	envelope $61
	note A_,2, 5
	note A_,2
	note A_,2
	note A_,2
	envelope $67
	note A_,3, 20
	note A_,2, 2
	silence 8
	note A_,2, 2
	silence 8
	note C_,4, 20
	note C_,3, 2
	silence 8
	note C_,3, 2
	silence 8
	note C_,4, 20
	snd_ret
.call3:
	note D_,4, 40
	wait2 10
	note D_,3, 5
	silence
	note D_,4, 10
	note C_,4, 60
	note C_,3, 2
	silence 8
	note C_,4, 10
	note A#,3
	wait2 40
	note A#,2, 10
	note A#,2, 5
	silence
	note A#,3, 10
	snd_ret
.call4:
	note C_,4, 10
	wait2 40
	note A_,3, 13
	note F_,3, 14
	note F_,3, 13
	snd_ret
.call5:
	note C_,4, 40
	note C_,3, 2
	silence 8
	note F_,4, 10
	note D_,4, 20
	note C_,4, 10
	snd_ret
SndData_BGM_Esaka_Ch3:
	wave_vol $80
	panning $44
	wave_id $04
	wave_cutoff 1
.loop0:
	wave_cutoff 25
	fine_tune 12
	snd_call .call0
	fine_tune -12
	snd_call .call1
	snd_call .call2
	snd_call .call3
	snd_call .call4
	snd_call .call5
	snd_call .call4
	snd_call .call6
	snd_loop .loop0
.call0:
	note G_,2, 10
	snd_loop .call0, $00, 56
	wave_cutoff 90
	note A_,2, 20
	note D_,2, 10
	note A#,2, 20
	note D_,2, 10
	note C_,3, 20
	snd_ret
.call1:
	wave_cutoff 60
	note F_,2, 10
	note G_,2, 20
	note G_,2, 30
	note G_,2, 10
	note G_,2
	wave_cutoff 30
	note G_,2
	note G_,2
	note D_,2
	note G_,2
	note G_,2
	note G_,2
	note A#,2
	note F_,2
	wave_cutoff 60
	note F_,2, 10
	note F_,2, 20
	note G_,2, 30
	note G_,2, 10
	note G_,2
	wave_cutoff 30
	note G_,2
	note G_,2
	note D_,2
	note G_,2
	note D_,2
	note G_,2
	note A_,2, 20
	note A#,2, 10
	note A#,2
	note D_,2
	note A#,2
	note A#,2
	note D_,2
	note A#,2
	note F_,2, 20
	note F_,2, 10
	note F_,2
	note F_,2
	note F_,2
	note E_,2
	note F_,2
	note C_,2
	note G_,2
	note G_,2
	note G_,2, 30
	note G_,2, 10
	note G_,2
	note G_,2, 20
	wave_cutoff 60
	note G_,3, 10
	note F_,3
	note G_,3
	note A#,3
	note G_,3, 30
	snd_ret
.call2:
	wave_cutoff 25
	note F_,3, 10
	note F_,2
	note F_,2
	note F_,3
	note F_,2
	note F_,2
	note F_,2
	note F_,3
	note F_,2
	note F_,2
	note F_,3
	note F_,2
	note F_,2
	note E_,2
	note F_,2
	note F#,2
	wave_cutoff 60
	note C_,4
	note D_,4, 30
	note F_,4, 10
	note D_,4, 20
	note C_,4
	snd_ret
.call3:
	note D_,4, 30
	note G_,3, 20
	note A_,3
	wave_cutoff 40
	note D#,2, 10
	note D#,2
	note A#,2
	note D#,2, 20
	note D#,2, 10
	note G_,2
	note D#,2, 20
	note D#,2, 10
	note D#,2
	note A#,2, 20
	note F_,2, 10
	note A#,2
	note F_,2
	note A_,2, 10
	note A_,2, 20
	note A_,2
	note E_,2, 10
	note A_,2
	note C_,3, 20
	note C_,3
	note C_,3
	note G_,2, 10
	note C_,3
	note C#,3
	snd_ret
.call4:
	wave_cutoff 20
	note D_,3, 10
	note D_,3, 5
	note D_,3
	note D_,3, 10
	note D_,3, 5
	note D_,3
	note D_,3, 10
	note D_,3, 5
	note D_,3
	note D_,3, 10
	wave_cutoff 60
	note C_,3, 20
	wave_cutoff 20
	note C_,3, 5
	note C_,3
	note C_,3, 10
	note C_,3, 5
	note C_,3
	note C_,3, 10
	note C_,3, 5
	note C_,3
	note C_,3, 10
	wave_cutoff 60
	note A#,2, 20
	wave_cutoff 20
	note A#,2, 5
	note A#,2
	note A#,2, 10
	note A#,2, 5
	note A#,2
	note A#,2, 10
	note A#,2, 5
	note A#,2
	note A#,2, 10
	snd_ret
.call5:
	wave_cutoff 60
	note C_,3, 20
	wave_cutoff 20
	note C_,3, 5
	note C_,3
	note C_,3, 10
	note C_,3, 5
	note C_,3
	wave_cutoff 60
	note A_,3, 13
	note F_,2, 14
	note F_,2, 13
	snd_ret
.call6:
	wave_cutoff 60
	note C_,3, 20
	note C_,2, 10
	note C_,3
	note C_,3
	note D_,3
	note D_,3, 20
	note C_,3, 10
	wave_cutoff 25
	snd_ret
SndData_BGM_Esaka_Ch4:
	panning $88
.loop0:
	snd_call .call0
	snd_call .call1
	snd_call .call2
	snd_call .call3
	snd_call .call4
	snd_call .call3
	snd_call .call5
	snd_call .call6
	snd_call .call7
	snd_call .call8
	snd_loop .loop0
.call0:
	envelope $61
	wait 54
	wait 20
	envelope $62
	wait 36
	wait 20
	envelope $61
	wait 54
	wait 10
	wait 54
	wait 10
	envelope $62
	wait 36
	wait 20
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
	wait 20
	wait 54
	wait 10
	envelope $62
	wait 36
	wait 20
	snd_loop .call0, $00, 3
	envelope $61
	wait 54
	wait 20
	envelope $62
	wait 36
	wait 20
	envelope $61
	wait 54
	wait 10
	wait 54
	wait 10
	envelope $62
	wait 36
	wait 20
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
	wait 36
	wait 10
	wait 36
	wait 10
	envelope $44
	wait 38
	wait 3
	envelope $34
	wait 38
	wait 4
	envelope $54
	wait 38
	wait 3
	envelope $61
	wait 54
	wait 10
	snd_ret
.call1:
	envelope $62
	wait 36
	wait 10
	wait 36
	wait 20
	envelope $61
	wait 54
	wait 30
	wait 54
	wait 20
	wait 54
	wait 20
	wait 54
	wait 20
	wait 54
	wait 10
	envelope $53
	wait 17
	wait 10
	envelope $61
	wait 54
	wait 10
	envelope $53
	wait 17
	wait 10
	envelope $61
	wait 54
	wait 20
	wait 54
	wait 20
	wait 54
	wait 20
	wait 54
	wait 20
	wait 54
	wait 20
	wait 54
	wait 20
	wait 54
	wait 10
	envelope $62
	wait 36
	wait 10
	wait 36
	wait 10
	wait 36
	wait 5
	wait 36
	wait 5
	snd_ret
.call2:
	envelope $61
	wait 54
	wait 20
	envelope $62
	wait 36
	wait 20
	envelope $61
	wait 54
	wait 10
	wait 54
	wait 10
	envelope $62
	wait 36
	wait 20
	envelope $61
	wait 54
	wait 20
	envelope $62
	wait 36
	wait 20
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
	wait 5
	envelope $54
	wait 38
	wait 5
	envelope $61
	wait 54
	wait 10
	wait 54
	wait 10
	envelope $62
	wait 36
	wait 5
	wait 36
	wait 5
	envelope $61
	wait 54
	wait 3
	envelope $62
	wait 36
	wait 4
	wait 36
	wait 3
	wait 36
	wait 10
	wait 36
	wait 10
	envelope $61
	wait 54
	wait 10
	envelope $62
	wait 36
	wait 20
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
	wait 5
	wait 54
	wait 5
	envelope $62
	wait 36
	wait 10
	envelope $61
	wait 54
	wait 20
	envelope $62
	wait 36
	wait 10
	snd_ret
.call3:
	envelope $61
	wait 54
	wait 20
	envelope $62
	wait 36
	wait 20
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
	snd_loop .call3, $00, 2
	snd_ret
.call4:
	envelope $61
	wait 54
	wait 10
	wait 54
	wait 20
	wait 54
	wait 5
	wait 54
	wait 5
	envelope $62
	wait 36
	wait 20
	envelope $61
	wait 54
	wait 10
	wait 54
	wait 20
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
	envelope $62
	wait 36
	wait 10
	envelope $44
	wait 38
	wait 10
	envelope $54
	wait 38
	wait 10
	snd_ret
.call5:
	envelope $61
	wait 54
	wait 10
	wait 54
	wait 5
	wait 54
	wait 15
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
	envelope $62
	wait 36
	wait 5
	wait 36
	wait 5
	envelope $61
	wait 54
	wait 20
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
	envelope $62
	wait 36
	wait 10
	wait 36
	wait 3
	wait 36
	wait 4
	wait 36
	wait 3
	wait 36
	wait 10
	snd_ret
.call6:
	envelope $61
	wait 54
	wait 10
	wait 54
	wait 5
	wait 54
	wait 5
	envelope $62
	wait 36
	wait 15
	envelope $61
	wait 54
	wait 5
	wait 54
	wait 10
	wait 54
	wait 5
	wait 54
	wait 5
	envelope $62
	wait 36
	wait 15
	envelope $61
	wait 54
	wait 5
	snd_loop .call6, $00, 3
	snd_ret
.call7:
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
	envelope $62
	wait 36
	wait 5
	wait 36
	wait 13
	envelope $61
	wait 54
	wait 14
	wait 54
	wait 13
	snd_ret
.call8:
	envelope $61
	wait 54
	wait 10
	wait 54
	wait 5
	wait 54
	wait 5
	envelope $62
	wait 36
	wait 15
	envelope $61
	wait 54
	wait 5
	wait 54
	wait 10
	wait 54
	wait 5
	wait 54
	wait 5
	envelope $62
	wait 36
	wait 15
	envelope $61
	wait 54
	wait 5
	snd_loop .call8, $00, 2
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
	wait 54
	wait 10
	envelope $62
	wait 36
	wait 10
	envelope $61
	wait 54
	wait 10
	wait 54
	wait 20
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
	envelope $61
	wait 54
	wait 20
	envelope $62
	wait 36
	wait 10
	snd_ret
