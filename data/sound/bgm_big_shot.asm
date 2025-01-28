SndHeader_BGM_BigShot:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_BigShot_Ch1 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_BigShot_Ch2 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_BigShot_Ch3 ; Data ptr
	db 12 ; Initial fine tune
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_BigShot_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_BGM_BigShot_Ch1:
	envelope $77
	panning $11
	duty_cycle 2
.loop0:
	envelope $77
	duty_cycle 2
	snd_call .call0
	snd_call .call1
	snd_call .call2
	snd_loop .loop0
.call0:
	note G_,4, 16
	note C_,5, 8
	continue 72
	note G_,4, 16
	note A#,4, 8
	continue 72
	note G_,4, 16
	note F_,4, 8
	continue 72
	note C_,5, 16
	note D_,5, 48
	note C_,5, 8
	envelope $11
	note C_,2, 24
	envelope $77
	note F_,5, 16
	note E_,5, 8
	continue 40
	snd_ret
.call1:
	note G_,5, 8
	envelope $11
	note G_,2, 96
	continue 16
	envelope $77
	note D_,4, 8
	note D_,5, 16
	note C_,5, 8
	continue 72
	note F_,5, 16
	note A#,5, 8
	snd_ret
.call2:
	envelope $11
	duty_cycle 3
	note F_,2, 48
	envelope $78
	note F_,4, 16
	note G_,4
	note F_,4
	note E_,4, 96
	continue 48
	envelope $11
	note E_,2, 40
	envelope $78
	note E_,4, 8
	note F_,4, 48
	note D_,4, 40
	note A_,4, 8
	continue 72
	envelope $11
	note A_,2, 24
	envelope $78
	note A#,4, 32
	silence 8
	note A_,4, 40
	silence 8
	note F_,4
	continue 48
	envelope $11
	note F_,2, 24
	envelope $78
	note A_,4, 16
	note G_,4, 8
	continue 96
	envelope $11
	duty_cycle 2
	note G_,2, 16
	envelope $77
	note E_,5, 8
	note F_,5
	note E_,5
	note D_,5
	note C_,5, 40
	note D_,5, 8
	envelope $11
	note D_,2, 48
	envelope $77
	note A_,5, 16
	envelope $11
	note A_,2, 24
	envelope $78
	duty_cycle 3
	note C_,4, 8
	note D_,4, 32
	envelope $11
	note D_,2, 16
	envelope $78
	note A_,4
	note G_,4, 8
	note F_,4, 16
	note E_,4, 8
	continue 48
	continue 8
	envelope $11
	note E_,2, 16
	envelope $77
	duty_cycle 2
	note F_,5, 16
	note E_,5, 24
	envelope $78
	duty_cycle 3
	note F_,4, 8
	note E_,4, 16
	note D_,4, 8
	note E_,4, 24
	note C_,4
	note A#,3, 48
	note F_,4
	envelope $11
	duty_cycle 2
	note A#,2, 24
	envelope $73
	note A#,4, 8
	note A_,4
	note G_,4
	note C_,5, 16
	note G_,4
	note A_,4
	envelope $75
	note D_,4
	continue 72
	note E_,4, 24
	continue 72
	continue 8
	note D#,4, 16
	continue 72
	note F_,4, 24
	continue 48
	continue 8
	snd_ret
SndData_BGM_BigShot_Ch2:
	envelope $11
	panning $22
	duty_cycle 2
	envelope $11
	note C_,2, 24
.loop0:
	snd_call .call0
	snd_call .call1
	snd_call .call0
	snd_call .call2
	snd_call .call3
	snd_call .call4
	snd_call .call5
	snd_call .call6
	snd_call .call6
	snd_call .call7
	snd_call .call6
	snd_call .call8
	snd_loop .loop0
.call0:
	envelope $54
	note E_,4, 16
	note C_,4, 8
	note G_,4, 16
	note D_,4, 8
	note A#,4, 16
	note C_,4, 8
	note G_,4, 16
	note D_,4, 24
	note A#,3, 8
	note G_,4, 16
	note E_,4, 8
	note A#,4, 16
	note D_,4, 8
	note A#,3
	note C_,4
	note A_,3, 24
	note F_,3, 8
	note C_,4, 16
	note A_,3, 8
	note D#,4, 16
	note A_,3, 8
	note F_,3, 16
	note G#,4, 24
	snd_ret
.call1:
	note A#,3, 8
	note G#,4, 16
	note D_,4, 8
	note G_,4, 16
	note D_,4, 8
	note A#,3, 24
	snd_ret
.call2:
	continue 72
	continue 8
	snd_ret
.call3:
	envelope $42
	note G_,5, 8
	note C_,5
	note E_,5
	note C_,5
	note D_,6
	note C_,5
	note E_,5
	note C_,5
	note G_,5
	note C_,5
	note D_,6
	note E_,5
	snd_loop .call3, $00, 2
	snd_ret
.call4:
	note F_,5, 8
	note C_,5
	note A_,5
	note C_,5
	note C_,6
	note C_,5
	note F_,5
	note C_,5
	note A_,5
	note C_,5
	note C_,6
	note C_,5
	snd_loop .call4, $00, 2
	snd_ret
.call5:
	envelope $57
	note D_,4, 40
	note E_,4, 48
	note A_,4, 24
	note G_,4, 8
	note D_,4, 16
	note C_,5, 32
	note B_,4, 16
	note A#,4, 8
	continue 96
	continue 96
	snd_ret
.call6:
	envelope $42
	note G_,4, 8
	note D_,4, 4
	note C_,4
	note G_,4, 8
	note F_,5, 16
	note D_,4, 8
	snd_loop .call6, $00, 2
	snd_ret
.call7:
	note G_,4, 8
	note E_,4, 4
	note D_,4
	note G_,4, 8
	note F_,5, 16
	note D_,4, 8
	snd_loop .call7, $00, 4
	snd_ret
.call8:
	envelope $11
	note F_,2, 24
	envelope $53
	note F_,4, 8
	note E_,4
	note D_,4
	note G_,4, 16
	note D_,4
	note E_,4
	envelope $55
	note A#,3, 16
	continue 72
	note C_,4, 24
	continue 72
	continue 8
	note C_,4, 16
	continue 72
	note D_,4, 24
	continue 72
	continue 8
	snd_ret
SndData_BGM_BigShot_Ch3:
	wave_vol $00
	panning $44
	wave_id $02
	wave_cutoff 60
	note C_,2, 24
.loop0:
	wave_vol $80
	snd_call .call0
	snd_call .call1
	snd_call .call0
	snd_call .call2
	snd_call .call3
	snd_loop .loop0
.call0:
	note C_,3, 16
	note B_,2, 8
	note C_,3, 24
	note E_,2, 16
	note G_,2, 8
	note C_,3, 16
	note A#,2, 24
	note A_,2, 8
	note A#,2, 24
	note A#,2, 16
	note D_,2, 8
	note E_,2, 16
	note F_,2, 24
	note E_,2, 8
	note F_,2, 24
	note F_,2, 16
	note E_,2, 8
	note A_,2, 16
	note A#,2, 24
	snd_ret
.call1:
	note A_,2, 8
	note A#,2, 16
	note F_,2, 8
	note A#,2, 16
	note A_,2, 8
	note A#,2, 24
	snd_ret
.call2:
	continue 72
	continue 8
	snd_ret
.call3:
	note A_,2, 24
	note A_,2
	note A_,2, 16
	note E_,2, 8
	note A_,2, 24
	snd_loop .call3, $00, 2
	note A#,2, 24
	note A#,2
	note A#,2, 16
	note F_,2, 8
	note A#,2, 24
	note A#,2, 24
	note A#,2
	note A#,2, 16
	note F_,2, 8
	note A#,2, 16
	note A#,2, 8
	note G_,2, 16
	note F#,2, 8
	note G_,2, 16
	note A_,2, 24
	note G_,2, 8
	note A_,2, 16
	note A#,2, 24
	note A_,2, 8
	note A#,2, 24
	note B_,2, 16
	note F_,2, 8
	note B_,2, 16
	note C_,3, 24
	note B_,2, 8
	note C_,3, 24
	note C_,3, 16
	note G_,2, 8
	note A_,2, 16
	note C_,3, 24
	note B_,2, 8
	note C_,3, 16
	note G_,2, 8
	note C_,3
	note G_,2
	note C_,3
	note B_,2, 16
	note A#,2, 32
	note A#,2, 24
	note A#,2, 16
	note F_,2, 8
	note A#,2, 24
	note A#,2, 24
	note A#,2
	note A#,2, 8
	note F_,2
	note A#,2
	note B_,2, 16
	note C_,3, 32
	note C_,3, 24
	note C_,3, 16
	note G_,2, 8
	note C_,3, 16
	note G_,2, 8
	note C_,3, 24
	note C_,3
	note C_,3, 16
	note G_,2, 8
	note C_,3, 16
	note F_,2, 8
	note A#,2, 24
	note A#,2, 16
	note A_,2, 8
	note A#,2, 16
	note F_,2, 8
	note G_,2, 16
	note A#,2
	continue 72
	continue 16
	note G_,2
	continue 72
	note A_,2, 16
	continue 72
	continue 16
	note G#,2
	continue 72
	note A#,2, 16
	continue 72
	continue 8
	note C_,3
	snd_ret
SndData_BGM_BigShot_Ch4:
	panning $88
	envelope $31
	wait 33
	wait 24
.loop0:
	snd_call .call0
	snd_call .call1
	snd_call .call1
	snd_call .call2
	snd_call .call3
	snd_loop .loop0
.call0:
	envelope $61
	wait 54
	wait 16
	envelope $31
	wait 33
	wait 8
	envelope $62
	wait 36
	wait 16
	envelope $61
	wait 54
	wait 24
	envelope $31
	wait 33
	wait 8
	envelope $62
	wait 36
	wait 16
	envelope $61
	wait 54
	wait 8
	snd_loop .call0, $00, 6
	envelope $61
	wait 54
	wait 16
	envelope $31
	wait 33
	wait 8
	envelope $62
	wait 36
	wait 16
	envelope $61
	wait 54
	wait 24
	envelope $31
	wait 33
	wait 8
	envelope $62
	wait 36
	wait 16
	envelope $61
	wait 54
	wait 96
	continue 8
	snd_ret
.call1:
	envelope $61
	wait 54
	wait 16
	envelope $31
	wait 33
	wait 8
	envelope $62
	wait 36
	wait 16
	envelope $53
	wait 17
	wait 8
	snd_loop .call1, $00, 3
	envelope $61
	wait 54
	wait 8
	envelope $62
	wait 36
	wait 8
	envelope $31
	wait 33
	wait 8
	envelope $62
	wait 36
	wait 16
	envelope $53
	wait 17
	wait 8
	snd_ret
.call2:
	envelope $61
	wait 54
	wait 16
	envelope $53
	wait 17
	wait 8
	envelope $62
	wait 36
	wait 16
	envelope $61
	wait 54
	wait 24
	envelope $53
	wait 17
	wait 8
	envelope $62
	wait 36
	wait 16
	envelope $61
	wait 54
	wait 24
	wait 54
	wait 8
	envelope $34
	wait 38
	wait 8
	envelope $44
	wait 38
	wait 8
	envelope $54
	wait 38
	wait 8
	envelope $62
	wait 36
	wait 8
	envelope $61
	wait 54
	wait 8
	envelope $62
	wait 36
	wait 8
	envelope $61
	wait 54
	wait 16
	wait 54
	wait 24
	envelope $31
	wait 33
	wait 8
	envelope $62
	wait 36
	wait 16
	envelope $53
	wait 17
	wait 8
	envelope $61
	wait 54
	wait 8
	envelope $62
	wait 36
	wait 8
	envelope $31
	wait 33
	wait 8
	envelope $62
	wait 36
	wait 16
	envelope $61
	wait 54
	wait 24
	envelope $31
	wait 33
	wait 8
	envelope $62
	wait 36
	wait 16
	envelope $53
	wait 17
	wait 8
	envelope $61
	wait 54
	wait 8
	envelope $62
	wait 36
	wait 8
	envelope $31
	wait 33
	wait 8
	envelope $62
	wait 36
	wait 8
	wait 36
	wait 8
	envelope $61
	wait 54
	wait 8
	snd_ret
.call3:
	envelope $61
	wait 54
	wait 8
	envelope $31
	wait 33
	wait 8
	envelope $61
	wait 54
	wait 8
	envelope $62
	wait 36
	wait 8
	envelope $53
	wait 17
	wait 8
	envelope $61
	wait 54
	wait 8
	wait 54
	wait 8
	envelope $62
	wait 36
	wait 8
	envelope $61
	wait 54
	wait 8
	envelope $62
	wait 36
	wait 8
	envelope $31
	wait 33
	wait 8
	envelope $53
	wait 17
	wait 8
	snd_loop .call3, $00, 5
	envelope $31
	wait 33
	wait 24
	envelope $62
	wait 36
	wait 8
	wait 36
	wait 8
	wait 36
	wait 8
	envelope $34
	wait 38
	wait 4
	wait 38
	wait 4
	envelope $61
	wait 54
	wait 8
	envelope $44
	wait 38
	wait 4
	wait 16
	wait 4
	envelope $61
	wait 54
	wait 8
	envelope $54
	wait 38
	wait 4
	wait 50
	wait 4
	envelope $61
	wait 54
	wait 8
	wait 54
	wait 40
	wait 54
	wait 8
	wait 54
	wait 8
	envelope $62
	wait 36
	wait 8
	wait 36
	wait 8
	envelope $44
	wait 38
	wait 16
	envelope $61
	wait 54
	wait 24
	envelope $62
	wait 36
	wait 8
	envelope $54
	wait 38
	wait 8
	envelope $62
	wait 36
	wait 8
	wait 36
	wait 8
	envelope $44
	wait 38
	wait 4
	wait 16
	wait 4
	wait 16
	wait 8
	wait 16
	wait 8
	envelope $34
	wait 38
	wait 4
	wait 38
	wait 4
	wait 38
	wait 8
	wait 38
	wait 8
	envelope $61
	wait 54
	wait 8
	envelope $62
	wait 36
	wait 8
	wait 36
	wait 8
	wait 36
	wait 8
	envelope $61
	wait 54
	wait 8
	wait 54
	wait 8
	envelope $62
	wait 36
	wait 8
	envelope $44
	wait 38
	wait 4
	envelope $34
	wait 38
	wait 4
	envelope $54
	wait 38
	wait 8
	envelope $61
	wait 54
	wait 8
	wait 54
	wait 8
	envelope $53
	wait 17
	wait 8
	continue 48
	envelope $62
	wait 36
	wait 8
	envelope $61
	wait 54
	wait 16
	envelope $62
	wait 36
	wait 16
	wait 36
	wait 8
	snd_ret
