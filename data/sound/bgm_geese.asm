SndHeader_BGM_Geese:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_Geese_Ch1 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_Geese_Ch2 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_Geese_Ch3 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_Geese_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_BGM_Geese_Ch1:
	envelope $77
	panning $11
	duty_cycle 3
	snd_call .call0
.loop0:
	snd_call .call1
	snd_call .call2
	snd_call .call3
	snd_call .call2
	snd_call .call4
	snd_call .call5
	snd_call .call6
	snd_call .call7
	snd_call .call6
	snd_call .call8
	snd_loop .loop0
.call0:
	note G_,3, 60
	silence 10
	note G_,3
	silence
	note G_,3
	note G_,3, 20
	note C_,3
	note D_,3
	snd_loop .call0, $00, 2
	snd_ret
.call1:
	envelope $77
	note G_,3, 60
	silence 10
	note G_,3
	silence
	note G_,3
	note G_,3, 20
	note C_,3
	note D_,3
	note G_,3, 60
	silence 10
	note A#,3
	silence
	note A#,3
	note A#,3, 20
	note C_,4
	note D_,4
	snd_ret
.call2:
	envelope $78
	note A#,4, 30
	note A_,4
	note F_,4, 5
	silence
	note D#,4, 40
	continue 10
	note D#,4
	note F_,4
	note G_,4, 20
	note F_,4, 30
	note G_,4
	note D#,4, 20
	continue 80
	snd_ret
.call3:
	note A#,4, 30
	note A_,4
	note F_,4, 20
	note D#,4, 30
	note A_,4
	note F_,4, 10
	note C_,5
	continue 30
	note B_,4
	note G_,4, 20
	continue 80
	snd_ret
.call4:
	note D_,4, 30
	note D#,4
	note F_,4, 10
	note G_,4
	continue 20
	silence
	note C_,5, 13
	note B_,4, 14
	note G_,4, 13
	note A#,4, 20
	silence 10
	note A_,4, 30
	note F_,4, 10
	note G_,4
	continue 80
	snd_ret
.call5:
	duty_cycle 2
	note G#,3, 60
	note D#,4, 20
	note D_,4
	note C_,4
	note A#,3
	note C_,4
	note B_,3, 60
	note G_,4, 20
	note F_,4
	note D#,4
	note D_,4
	note C_,4
	note D#,4, 60
	note D_,4, 20
	note F_,4, 13
	note B_,4, 14
	note C_,5, 13
	note B_,4
	note G#,4, 14
	note G_,4, 13
	note B_,4, 80
	note C_,5, 30
	note D_,5, 40
	continue 10
	snd_ret
.call6:
	duty_cycle 3
	note C_,4, 13
	note D#,4, 14
	note G_,4, 13
	note A_,4
	note A#,4, 14
	note C_,5, 13
	note A_,4, 80
	snd_ret
.call7:
	note G#,4, 13
	note D#,4, 14
	note D_,4, 13
	note C_,4
	note D_,4, 14
	note G_,4, 13
	continue 80
	snd_ret
.call8:
	note G#,4, 13
	note G_,4, 14
	note A#,4, 13
	note G#,4
	note D_,5, 14
	note D#,5, 13
	continue 80
	note D_,5, 20
	note G_,4, 5
	silence
	note D#,5, 20
	note G#,4, 5
	silence
	note F_,5, 20
	note G_,5, 13
	note D#,5, 14
	note D_,5, 13
	note C_,5
	note B_,4, 14
	note D_,5, 13
	note D#,5, 80
	continue 80
	envelope $11
	note C_,2, 80
	continue 80
	snd_ret
SndData_BGM_Geese_Ch2:
	envelope $77
	panning $22
	duty_cycle 1
	snd_call .call0
	snd_call .call1
	snd_call .call2
	snd_loop SndData_BGM_Geese_Ch2
.call0:
	note C_,3, 20
	note D_,3, 10
	note C_,3, 20
	note D_,3, 10
	note C_,3, 20
	note D_,3, 10
	note C_,3, 20
	note D_,3, 10
	note D#,3, 20
	note F_,3
	snd_loop .call0, $00, 13
	snd_ret
.call1:
	note B_,2, 20
	note D_,3, 10
	note B_,2, 20
	note D_,3, 10
	note B_,2, 20
	note D_,3, 10
	note B_,2, 20
	note D_,3, 10
	note G_,3, 20
	note G#,3
	note F_,3
	note G_,3, 10
	note F_,3, 20
	note G_,3, 10
	note F_,3, 20
	note G_,3, 10
	note F_,3, 20
	note G_,3, 10
	note D#,3, 20
	note F_,3
	note B_,2
	note D_,3, 10
	note B_,2, 20
	note D_,3, 10
	note B_,2, 20
	note D_,3, 10
	note B_,2, 20
	note D_,3, 10
	note B_,3, 20
	note D_,4
	snd_ret
.call2:
	envelope $62
	duty_cycle 0
	note G_,3, 5
	note D#,4
	note C_,4
	note G_,3
	note F_,4
	note D#,4
	note G_,3
	note D#,4
	snd_loop .call2, $00, 16
	envelope $77
	duty_cycle 1
	note B_,3, 20
	note B_,2, 10
	note C_,4, 20
	note C_,3, 10
	note B_,3, 20
	note B_,2, 13
	note C_,4, 14
	note F_,4, 13
	note G_,4
	note D_,5, 14
	note F_,5, 13
	snd_ret
SndData_BGM_Geese_Ch3:
	wave_vol $80
	panning $44
	wave_id $02
	wave_cutoff 25
	snd_call .call0
	snd_call .call1
	snd_call .call2
	snd_call .call1
	snd_call .call3
	snd_call .call4
	fine_tune -4
	snd_call .call4
	fine_tune 4
	snd_call .call4
	fine_tune -4
	snd_call .call4
	fine_tune 4
	snd_call .call5
	snd_loop SndData_BGM_Geese_Ch3
.call0:
	note C_,3, 10
	note C_,3, 5
	note C_,3
	note C_,3, 10
	note C_,3
	note C_,3, 5
	note C_,3
	note C_,3, 10
	note C_,3
	note C_,3, 5
	note C_,3
	note C_,3, 10
	note C_,3
	note C_,3, 5
	note C_,3
	note C_,3, 10
	note G#,2
	note G#,2, 5
	note G#,2
	note A#,2, 10
	note A#,2, 5
	note A#,2
	snd_loop .call0, $00, 12
	snd_ret
.call1:
	note G#,2, 10
	note G#,2, 5
	note G#,2
	note G#,2, 10
	note G#,2, 5
	note G#,2
	note G#,2, 10
	note F_,2
	note G_,2
	wave_cutoff 60
	note G#,2, 20
	wave_cutoff 30
	note F_,2, 10
	note G_,2
	note G#,2
	note A#,2
	note G#,2
	note F_,2
	note C_,2
	wave_cutoff 25
	note G_,2, 10
	note G_,2, 5
	note G_,2
	note G_,3, 10
	note G_,2, 5
	note G_,2
	note G_,2, 10
	note D_,2
	note G_,2
	note C_,3
	snd_ret
.call2:
	note B_,3, 10
	note B_,4
	note G_,3
	note G_,4, 5
	note B_,3
	note D_,3, 10
	note D_,3
	note C_,3, 5
	note D_,3
	note D#,3, 10
	snd_ret
.call3:
	note D_,5, 5
	note C_,5
	note B_,4
	note G#,4
	note G_,4
	note F_,4
	note D#,4
	note D_,4
	note C_,4
	note B_,3
	note C_,4
	note D_,4
	note D#,4
	note F_,4
	note G_,4
	note C#,4
	snd_ret
.call4:
	note C_,4, 5
	note C_,4
	note C_,4
	note C_,4
	note C_,5, 10
	note C_,4, 5
	note C_,4
	snd_loop .call4, $00, 4
	snd_ret
.call5:
	wave_cutoff 30
	note G_,3, 10
	note G_,3
	note G_,2
	note G#,3
	note G#,3
	note G#,2
	note G_,3
	note G_,3
	note G_,2, 13
	note F_,3, 14
	note G_,3, 13
	note D_,4
	note B_,3, 14
	note F_,3, 13
	snd_ret
SndData_BGM_Geese_Ch4:
	panning $88
	snd_call .call0
	snd_call .call1
	snd_call .call0
	snd_call .call2
	snd_call .call0
	snd_call .call1
	snd_call .call0
	snd_call .call2
	snd_call .call0
	snd_call .call1
	snd_call .call0
	snd_call .call3
	snd_call .call4
	snd_call .call5
	snd_call .call3
	snd_call .call6
	snd_loop SndData_BGM_Geese_Ch4
.call0:
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
	snd_loop .call0, $00, 7
	snd_ret
.call1:
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
	wait 36
	wait 5
	envelope $61
	wait 54
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
	wait 5
	wait 36
	wait 5
	wait 36
	wait 5
	wait 36
	wait 5
	snd_ret
.call3:
	envelope $62
	wait 36
	wait 5
	envelope $61
	wait 54
	wait 5
	envelope $62
	wait 36
	wait 5
	wait 36
	wait 5
	envelope $61
	wait 54
	wait 5
	envelope $62
	wait 36
	wait 5
	wait 36
	wait 5
	wait 36
	wait 5
	snd_ret
.call4:
	envelope $61
	wait 54
	wait 5
	envelope $62
	wait 36
	wait 5
	envelope $53
	wait 17
	wait 5
	envelope $61
	wait 54
	wait 5
	envelope $62
	wait 36
	wait 10
	envelope $53
	wait 17
	wait 5
	envelope $61
	wait 54
	wait 15
	envelope $53
	wait 17
	wait 5
	envelope $61
	wait 54
	wait 5
	envelope $62
	wait 36
	wait 10
	envelope $53
	wait 17
	wait 5
	envelope $61
	wait 54
	wait 5
	snd_loop .call4, $00, 7
	envelope $61
	wait 54
	wait 5
	envelope $62
	wait 36
	wait 5
	wait 36
	wait 5
	wait 36
	wait 5
	envelope $34
	wait 38
	wait 5
	wait 38
	wait 5
	wait 38
	wait 5
	envelope $44
	wait 38
	wait 5
	wait 16
	wait 5
	wait 16
	wait 5
	envelope $54
	wait 38
	wait 5
	envelope $61
	wait 54
	wait 5
	envelope $62
	wait 36
	wait 5
	envelope $61
	wait 54
	wait 5
	envelope $62
	wait 36
	wait 5
	envelope $61
	wait 54
	wait 5
	snd_ret
.call5:
	envelope $61
	wait 54
	wait 5
	wait 54
	wait 5
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
	snd_loop .call5, $00, 15
	snd_ret
.call6:
	envelope $62
	wait 36
	wait 10
	envelope $61
	wait 54
	wait 10
	wait 54
	wait 10
	snd_loop .call6, $00, 4
	envelope $62
	wait 36
	wait 10
	wait 36
	wait 10
	wait 36
	wait 10
	wait 36
	wait 10
	snd_ret
