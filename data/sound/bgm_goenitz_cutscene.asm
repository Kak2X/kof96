SndHeader_BGM_GoenitzCutscene:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_GoenitzCutscene_Ch1 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_GoenitzCutscene_Ch2 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_GoenitzCutscene_Ch3 ; Data ptr
	db 12 ; Initial fine tune
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_GoenitzCutscene_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_BGM_GoenitzCutscene_Ch1:
	envelope $78
	panning $11
	duty_cycle 2
	note D_,5, 48
	note C_,5, 96
	continue 24
	silence
	note D#,5, 48
	note F_,5, 96
	continue 24
	silence
	note D_,5, 48
	note C_,5, 96
	continue 24
	silence
	note D#,5, 48
	note F_,5, 96
	note F#,5
.loop0:
	note A#,2, 12
	silence
	snd_loop .loop0
SndData_BGM_GoenitzCutscene_Ch2:
	envelope $11
	panning $22
	duty_cycle 3
	note C_,2, 48
	envelope $78
	note G#,3, 12
	note C_,4
	note D#,4
	note G_,4, 48
	continue 12
	continue 96
	note A#,3, 12
	note C_,4
	note D_,4
	note G_,4, 48
	continue 12
	continue 96
	note G#,3, 12
	note C_,4
	note D#,4
	note G_,4, 48
	continue 12
	continue 96
	note A#,3, 12
	note C_,4
	note D_,4
	note G_,4, 48
	continue 12
	note G#,4, 96
.loop0:
	note D_,3, 12
	silence
	snd_loop .loop0
SndData_BGM_GoenitzCutscene_Ch3:
	wave_vol $80
	panning $44
	wave_id $02
	wave_cutoff 0
	note A#,2, 48
	note G#,2, 96
	continue 96
	note A#,2, 96
	continue 96
	note G#,2, 96
	continue 96
	note F_,2, 96
	note E_,2
	wave_cutoff 50
.loop0:
	note C_,2, 24
	snd_loop .loop0
SndData_BGM_GoenitzCutscene_Ch4:
	panning $88
	envelope $61
	note4 F_,5,0, 24
	note4 F_,5,0, 24
	snd_call .call0
.loop0:
	snd_call .call1
	snd_call .call2
	snd_call .call1
	snd_call .call3
	snd_loop .loop0
.call0:
	envelope $61
	note4 F_,5,0, 36
	note4 F_,5,0, 6
	note4 F_,5,0, 6
	envelope $54
	note4 A_,5,0, 12
	envelope $61
	note4 F_,5,0, 12
	envelope $54
	note4 A_,5,0, 12
	envelope $61
	note4 F_,5,0, 12
	envelope $54
	note4 A_,5,0, 12
	envelope $61
	note4 F_,5,0, 12
	note4 F_,5,0, 24
	envelope $54
	note4 A_,5,0, 24
	note4x $32, 24 ; Nearest: A_,5,0
	snd_loop .call0, $00, 4
	snd_ret
.call1:
	envelope $54
	note4 A_,5,0, 12
	envelope $61
	note4 F_,5,0, 60
	envelope $54
	note4 A_,5,0, 12
	envelope $61
	note4 F_,5,0, 12
	snd_ret
.call2:
	envelope $61
	note4 F_,5,0, 6
	note4 F_,5,0, 6
	envelope $54
	note4 A_,5,0, 24
	envelope $53
	note4x $11, 36 ; Nearest: A#,6,0
	note4x $11, 24 ; Nearest: A#,6,0
	snd_ret
.call3:
	envelope $61
	note4 F_,5,0, 6
	note4 F_,5,0, 6
	envelope $54
	note4 A_,5,0, 24
	envelope $61
	note4 F_,5,0, 12
	envelope $54
	note4 A_,5,0, 12
	envelope $61
	note4 F_,5,0, 12
	note4 F_,5,0, 12
	envelope $54
	note4 A_,5,0, 12
	snd_ret
