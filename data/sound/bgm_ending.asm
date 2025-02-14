SndHeader_BGM_Ending:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_Ending_Ch1 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_Ending_Ch2 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_Ending_Ch3 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_Ending_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_BGM_Ending_Ch1:
	envelope $78
	panning $11
	duty_cycle 3
	note D_,5, 96
	continue 8
	silence
	note D_,5
	note D_,5
	note C#,5, 32
	envelope $11
	note C#,2, 96
	envelope $78
	note D_,5, 96
	continue 8
	silence
	note D_,5
	note D_,5
	note E_,5, 32
	envelope $11
	note C#,2, 96
	envelope $78
	note D_,5, 32
	note C#,5, 16
	silence
	note E_,5, 32
	note F_,5, 16
	silence
	note F#,5, 32
	note G_,5, 16
	silence
	note G#,5, 64
	note A_,5, 64
	continue 64
	envelope $11
	note E_,2, 48
	envelope $67
	note E_,3, 8
	note E_,3
	note E_,3
	silence
	note E_,3
	note E_,3
	note E_,3
	silence
	note E_,3
	note E_,3
	snd_loop SndData_BGM_Ending_Ch1
SndData_BGM_Ending_Ch2:
	envelope $58
	panning $22
	duty_cycle 2
	note A_,3, 32
	note G_,3
	note F_,3
	note A_,3
	note G_,4
	note C#,4
	note E_,4
	note A_,3
	note A_,3
	note G_,3
	note F_,3
	note A_,3
	note G_,4
	note C#,4
	note E_,4
	note G_,4
	note F_,4
	note C#,4, 16
	silence
	note G_,4, 32
	note D_,4, 16
	silence
	note A_,4, 32
	note E_,4, 16
	silence
	note B_,4, 64
	note E_,5, 8
	note F_,5
	note E_,5
	note C#,5
	note E_,5
	note A#,4
	note C#,5
	note G_,4
	note A#,4
	note E_,4
	note G_,4
	note D_,4
	note C#,4
	note E_,4
	note G_,4
	note C#,4
	note A_,3
	note A_,4
	note G_,4
	note D_,4
	note F_,4
	note C#,4
	note D_,4
	note A#,3
	note C#,4
	note A_,3
	note G_,3
	note A_,3
	note F_,3
	note A_,3
	note E_,3
	note F_,3
	snd_loop SndData_BGM_Ending_Ch2
SndData_BGM_Ending_Ch3:
	wave_vol $80
	panning $44
	wave_id $02
	wave_cutoff 25
	snd_call .call0
	snd_call .call1
	snd_call .call0
	snd_call .call2
	snd_loop SndData_BGM_Ending_Ch3
.call0:
	note D_,4, 8
	note A_,3
	note D_,4
	note E_,4
	note F_,4
	note A_,3
	note F_,4
	note D_,4
	note A_,4
	note D_,4
	note G_,4
	note D_,4
	note F_,4
	note D_,4
	note C#,4
	note D_,4
	note E_,4
	note A_,3
	note C#,4
	note A_,3
	note G_,4
	note A_,3
	note E_,4
	note F_,4
	snd_ret
.call1:
	note C#,5, 8
	note E_,4
	note A#,4
	note E_,4
	note A_,4
	note E_,4
	note C#,4
	note A_,3
	snd_ret
.call2:
	note C#,5, 8
	note D_,5
	note A#,4
	note C#,5
	note A_,4
	note A#,4
	note G_,4
	note C#,4
	note A_,4
	note F_,4
	note C#,4
	note A_,3
	note G_,4
	note E_,4
	note C#,4
	note G_,3
	note A#,4
	note E_,4
	note C#,4
	note A#,3
	note A_,4
	note F_,4
	note D_,4
	note A_,3
	note C_,5
	note A_,4
	note F#,4
	note C_,4
	note B_,4
	note G_,4
	note E_,4
	note B_,3
	note D_,5
	note B_,4
	note G#,4
	note D_,4
	note B_,4
	note G#,4
	note D_,4
	note B_,3
	note A_,3
	note A_,4
	note G_,4
	note D_,4
	note E_,4
	note C#,4
	note D_,4
	note A#,3
	note C#,4
	note A_,3
	note G_,3
	note A_,3
	note F_,3
	note A_,3
	note E_,3
	note F_,3
	note A_,3, 64
	continue 64
	snd_ret
SndData_BGM_Ending_Ch4:
	panning $88
	snd_call .call0
	snd_loop SndData_BGM_Ending_Ch4
.call0:
	envelope $61
	note4 F_,5,0, 96
	continue 16
	note4 F_,5,0, 8
	note4 F_,5,0, 8
	envelope $54
	note4x $32, 48 ; Nearest: A_,5,0
	note4x $32, 8 ; Nearest: A_,5,0
	note4x $32, 8 ; Nearest: A_,5,0
	note4x $32, 16 ; Nearest: A_,5,0
	note4x $32, 8 ; Nearest: A_,5,0
	note4x $32, 8 ; Nearest: A_,5,0
	note4x $32, 16 ; Nearest: A_,5,0
	note4x $32, 8 ; Nearest: A_,5,0
	note4x $32, 8 ; Nearest: A_,5,0
	snd_loop .call0, $00, 2
.loop1:
	envelope $44
	note4x $32, 48 ; Nearest: A_,5,0
	note4x $10, 8 ; Nearest: B_,6,0
	note4x $10, 8 ; Nearest: B_,6,0
	snd_loop .loop1, $00, 4
	envelope $61
	note4 F_,5,0, 96
	continue 16
	note4 F_,5,0, 8
	note4 F_,5,0, 8
	note4 F_,5,0, 48
	note4 F_,5,0, 8
	note4 F_,5,0, 8
	envelope $54
	note4x $32, 16 ; Nearest: A_,5,0
	envelope $61
	note4 F_,5,0, 16
	envelope $54
	note4x $32, 16 ; Nearest: A_,5,0
	envelope $61
	note4 F_,5,0, 16
	snd_ret
