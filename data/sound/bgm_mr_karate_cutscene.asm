SndHeader_BGM_MrKarateCutscene:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_MrKarateCutscene_Ch1 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_MrKarateCutscene_Ch2 ; Data ptr
	db -7 ; Initial fine tune
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_MrKarateCutscene_Ch3 ; Data ptr
	db 12 ; Initial fine tune
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_MrKarateCutscene_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_BGM_MrKarateCutscene_Ch1:
	envelope $77
	panning $11
	duty_cycle 3
	snd_call .call0
	snd_loop SndData_BGM_MrKarateCutscene_Ch1
.call0:
	note A_,4, 12
	note A_,4
	note G_,3, 3
	silence
	note G_,3, 6
	note G_,3, 3
	silence
	note G_,3, 6
	note C_,5, 24
	note G_,3, 6
	silence
	note G_,3, 12
	note A_,4, 12
	note A_,4
	note G_,3, 3
	silence
	note G_,3, 6
	note G_,3, 3
	silence
	note G_,3, 6
	note C#,5, 24
	note G_,3, 6
	silence
	note G_,3, 12
	note A_,4, 12
	note A_,4
	note G_,3, 3
	silence
	note G_,3, 6
	note G_,3, 3
	silence
	note G_,3, 6
	note D#,5, 24
	note G_,3, 6
	silence
	note G_,3, 12
	note A_,4, 12
	note A_,4
	note G_,3, 3
	silence 9
	note E_,5, 24
	note G_,3, 6
	silence
	note F_,5, 24
	snd_loop .call0, $00, 2
	note G_,4, 12
	note F#,4
	note F_,4
	note F#,4
	note F_,4
	note E_,4
	note D#,4, 24
	snd_ret
SndData_BGM_MrKarateCutscene_Ch2:
	envelope $77
	panning $22
	duty_cycle 1
	snd_call SndData_BGM_MrKarateCutscene_Ch1.call0
	snd_loop SndData_BGM_MrKarateCutscene_Ch2
SndData_BGM_MrKarateCutscene_Ch3:
	wave_vol $80
	panning $44
	wave_id $02
	wave_cutoff 90
	note G_,2, 12
	note G_,2, 24
	note G_,2, 12
	note A#,2, 36
	note G_,2, 12
	note G_,2, 12
	note G_,2, 24
	note G_,2, 12
	note B_,2, 36
	note G_,2, 12
	note G_,2, 12
	note G_,2, 24
	note G_,2, 12
	note C#,3, 36
	note G_,2, 12
	note G_,2, 12
	note G_,2
	note G_,2
	note D_,3, 24
	note G_,2, 12
	note D#,3, 24
	snd_loop SndData_BGM_MrKarateCutscene_Ch3, $00, 2
	note D_,3, 12
	note C#,3
	note C_,3
	note C#,3
	note C_,3
	note B_,2, 36
	snd_loop SndData_BGM_MrKarateCutscene_Ch3
SndData_BGM_MrKarateCutscene_Ch4:
	panning $88
	snd_call .call0
	snd_call .call0
	envelope $54
	wait 38
	wait 12
	envelope $61
	wait 54
	wait 6
	envelope $62
	wait 36
	wait 6
	wait 36
	wait 12
	envelope $54
	wait 38
	wait 12
	envelope $44
	wait 38
	wait 12
	envelope $54
	wait 38
	wait 12
	envelope $61
	wait 54
	wait 24
	snd_loop SndData_BGM_MrKarateCutscene_Ch4
.call0:
	envelope $61
	wait 54
	wait 12
	wait 54
	wait 24
	wait 54
	wait 6
	wait 54
	wait 6
	envelope $62
	wait 36
	wait 36
	envelope $61
	wait 54
	wait 12
	snd_loop .call0, $00, 3
	envelope $62
	wait 36
	wait 12
	envelope $61
	wait 54
	wait 12
	wait 54
	wait 12
	envelope $62
	wait 36
	wait 12
	envelope $61
	wait 54
	wait 12
	wait 54
	wait 12
	envelope $62
	wait 36
	wait 12
	envelope $61
	wait 54
	wait 12
	snd_ret
