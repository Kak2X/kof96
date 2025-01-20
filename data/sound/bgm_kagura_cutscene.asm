SndHeader_BGM_KaguraCutscene:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_KaguraCutscene_Ch1 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_KaguraCutscene_Ch2 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_KaguraCutscene_Ch3 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_KaguraCutscene_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_BGM_KaguraCutscene_Ch1:
	envelope $77
	panning $11
	duty_cycle 2
	snd_call .call0
	snd_call .call1
	snd_loop SndData_BGM_KaguraCutscene_Ch1
.call0:
	envelope $84
	note F_,4, 10
	note G_,4
	note B_,4
	note E_,5
	note F_,4
	note G_,4
	note B_,4
	note E_,5
	envelope $44
	note F_,4
	note G_,4
	note B_,4
	note E_,5
	note F_,4
	note G_,4
	note B_,4
	note E_,5
	envelope $84
	note F#,4
	note G_,4
	note B_,4
	note E_,5
	note F#,4
	note G_,4
	note B_,4
	note E_,5
	envelope $44
	note F#,4
	note G_,4
	note B_,4
	note E_,5
	note F#,4
	note G_,4
	note B_,4
	note E_,5
	snd_loop .call0, $00, 4
	snd_ret
.call1:
	envelope $84
	note F_,5, 10
	note A_,5
	note E_,6
	note F_,5
	note A_,5
	note E_,6
	envelope $44
	note F_,5
	note A_,5
	note E_,6
	note F_,5
	note A_,5
	note E_,6
	envelope $27
	note F_,5
	note A_,5
	note E_,6, 20
	envelope $84
	note E_,5, 10
	note G#,5
	note E_,6
	note E_,5
	note G#,5
	note E_,6
	envelope $44
	note E_,5
	note G#,5
	note E_,6
	note E_,5
	note G#,5
	note E_,6
	envelope $27
	note E_,5
	note G#,5
	note E_,6, 20
	snd_loop .call1, $00, 3
	envelope $84
	note F_,5, 10
	note A_,5
	note E_,6
	note F_,5
	note A_,5
	note E_,6
	envelope $44
	note F_,5
	note A_,5
	note E_,6
	note F_,5
	note A_,5
	note E_,6
	envelope $27
	note F_,5
	note A_,5
	note E_,6, 20
	envelope $84
	note G_,5, 10
	note B_,5
	note G_,6
	note G_,5
	note B_,5
	note G_,6
	envelope $44
	note G#,5
	note B_,5
	note G#,6
	note G#,5
	note B_,5
	note G#,6
	envelope $27
	note G#,5
	note B_,5
	note G#,6, 20
	snd_ret
SndData_BGM_KaguraCutscene_Ch2:
	envelope $34
	panning $22
	duty_cycle 2
	silence 15
.loop0:
	snd_call .call0
	snd_call .call1
	snd_loop .loop0
.call0:
	envelope $47
	note F_,4, 10
	note G_,4
	note B_,4
	note E_,5
	note F_,4
	note G_,4
	note B_,4
	note E_,5
	envelope $27
	note F_,4
	note G_,4
	note B_,4
	note E_,5
	note F_,4
	note G_,4
	note B_,4
	note E_,5
	envelope $47
	note F#,4
	note G_,4
	note B_,4
	note E_,5
	note F#,4
	note G_,4
	note B_,4
	note E_,5
	envelope $27
	note F#,4
	note G_,4
	note B_,4
	note E_,5
	note F#,4
	note G_,4
	note B_,4
	note E_,5
	snd_loop .call0, $00, 4
	snd_ret
.call1:
	envelope $47
	note F_,5, 10
	note A_,5
	note E_,6
	note F_,5
	note A_,5
	note E_,6
	envelope $27
	note F_,5
	note A_,5
	note E_,6
	note F_,5
	note A_,5
	note E_,6
	envelope $17
	note F_,5
	note A_,5
	note E_,6, 20
	envelope $47
	note E_,5, 10
	note G#,5
	note E_,6
	note E_,5
	note G#,5
	note E_,6
	envelope $27
	note E_,5
	note G#,5
	note E_,6
	note E_,5
	note G#,5
	note E_,6
	envelope $17
	note E_,5
	note G#,5
	note E_,6, 20
	snd_loop .call1, $00, 3
	envelope $47
	note F_,5, 10
	note A_,5
	note E_,6
	note F_,5
	note A_,5
	note E_,6
	envelope $27
	note F_,5
	note A_,5
	note E_,6
	note F_,5
	note A_,5
	note E_,6
	envelope $17
	note F_,5
	note A_,5
	note E_,6, 20
	envelope $47
	note G_,5, 10
	note B_,5
	note G_,6
	note G_,5
	note B_,5
	note G_,6
	envelope $27
	note G#,5
	note B_,5
	note G#,6
	note G#,5
	note B_,5
	note G#,6
	envelope $17
	note G#,5
	note B_,5
	note G#,6, 20
	snd_ret
SndData_BGM_KaguraCutscene_Ch3:
	wave_vol $80
	panning $44
	wave_id $02
	wave_cutoff 0
	snd_call .call0
	snd_call .call1
	snd_loop SndData_BGM_KaguraCutscene_Ch3
.call0:
	note F_,3, 80
	wait2 80
	wave_cutoff 20
	note E_,3, 10
	wave_cutoff 0
	note E_,3, 120
	wait2 30
	snd_loop .call0, $00, 4
	snd_ret
.call1:
	wave_cutoff 30
	note F_,3, 30
	wave_cutoff 0
	note F_,3, 120
	wait2 10
	wave_cutoff 30
	note E_,3, 30
	wave_cutoff 0
	note E_,3, 120
	wait2 10
	snd_loop .call1, $00, 3
	wave_cutoff 30
	note F_,3, 30
	wave_cutoff 0
	note F_,3, 120
	wait2 10
	wave_cutoff 30
	note G_,3, 30
	wave_cutoff 0
	note G_,3, 40
	wait2 10
	note G#,3, 80
	snd_ret
SndData_BGM_KaguraCutscene_Ch4:
	panning $88
	snd_call .call0
	snd_call .call1
	snd_call .call2
	snd_loop SndData_BGM_KaguraCutscene_Ch4
.call0:
	envelope $61
	wait 54
	wait 80
	wait2 80
	wait 54
	wait 10
	wait 54
	wait 120
	wait2 30
	wait 54
	wait 80
	wait2 80
	wait 54
	wait 10
	wait 54
	wait 80
	wait2 30
	envelope $31
	wait 33
	wait 10
	envelope $53
	wait 17
	wait 30
	snd_ret
.call1:
	envelope $61
	wait 54
	wait 20
	envelope $31
	wait 33
	wait 20
	envelope $62
	wait 36
	wait 20
	envelope $31
	wait 33
	wait 40
	wait 33
	wait 20
	envelope $62
	wait 36
	wait 20
	envelope $31
	wait 33
	wait 20
	envelope $61
	wait 54
	wait 10
	wait 54
	wait 10
	envelope $31
	wait 33
	wait 20
	envelope $62
	wait 36
	wait 20
	envelope $31
	wait 33
	wait 40
	wait 33
	wait 20
	envelope $62
	wait 36
	wait 10
	envelope $53
	wait 17
	wait 30
	snd_loop .call1, $00, 2
	snd_ret
.call2:
	envelope $61
	wait 54
	wait 30
	wait 54
	wait 120
	wait2 10
	snd_loop .call2, $00, 4
.loop1:
	envelope $61
	wait 54
	wait 10
	wait 54
	wait 10
	envelope $31
	wait 33
	wait 10
	envelope $61
	wait 54
	wait 10
	envelope $62
	wait 36
	wait 20
	envelope $53
	wait 17
	wait 10
	envelope $61
	wait 54
	wait 20
	envelope $31
	wait 33
	wait 10
	envelope $61
	wait 54
	wait 20
	envelope $62
	wait 36
	wait 20
	envelope $53
	wait 17
	wait 20
	snd_loop .loop1, $00, 4
	snd_ret
