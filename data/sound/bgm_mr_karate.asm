SndHeader_BGM_MrKarate:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_MrKarate_Ch1 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_MrKarate_Ch2 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_MrKarate_Ch3 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_MrKarate_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_BGM_MrKarate_Ch1:
	envelope $77
	panning $11
	duty_cycle 3
	snd_call .call0
.loop0:
	snd_call .call1
	snd_call .call2
	snd_call .call3
	snd_call .call0
	snd_loop .loop0
.call0:
	envelope $75
	duty_cycle 3
	note B_,4, 20
	note G_,4, 10
	note E_,4
	note D_,5
	note E_,4
	note E_,5
	note E_,4
	note B_,4, 20
	note G_,4, 10
	note E_,4
	note A_,4
	note D_,4
	note F#,4
	note A_,3
	snd_loop .call0, $00, 2
	snd_ret
.call1:
	note D_,5, 20
	note A_,4, 2
	silence 3
	note A_,4, 5
	note F#,5, 10
	note A_,4, 2
	silence 3
	note A_,4, 5
	note D_,5, 10
	note A_,4, 2
	silence 3
	note A_,4, 5
	note D_,4, 10
	note D_,5, 20
	note A_,4, 2
	silence 3
	note A_,4, 5
	note F#,5, 10
	note A_,4, 2
	silence 3
	note A_,4, 5
	note D_,5
	note C#,5
	note C_,5
	note B_,4
	note A#,4
	note A_,4
	snd_loop .call1, $00, 4
	snd_ret
.call2:
	envelope $78
	duty_cycle 2
	note A_,4, 40
	note B_,4, 30
	note G_,4
	note D_,4, 40
	note A_,4, 10
	note B_,4
	note C_,5, 40
	continue 10
	note D_,4
	note D_,5
	note C_,5
	note B_,4
	continue 40
	continue 10
	note C_,5
	note D_,5
	note D#,5, 40
	note F_,5, 30
	note D#,5, 10
	note D_,5
	silence
	note B_,4
	note G_,4
	note D_,4, 60
	envelope $77
	duty_cycle 3
	note D_,4, 5
	silence
	note D_,4, 10
	note C#,4
	note D_,4
	note C#,4
	note D_,4
	snd_ret
.call3:
	envelope $78
	duty_cycle 3
	note A_,4, 20
	note G#,4, 10
	note A_,4
	note C_,5, 20
	note C_,4, 5
	silence
	note B_,4, 10
	note D_,5, 30
	note D_,4, 5
	silence
	note E_,5, 10
	silence
	note G_,5
	silence
	note E_,5, 80
	note D_,5, 5
	note E_,5
	note D_,5, 30
	note C_,5, 5
	note D_,5
	note C_,5, 20
	silence 10
	note B_,4
	note C_,5
	note B_,4
	note G_,4
	note D_,4
	silence
	note B_,4, 30
	continue 80
	envelope $11
	note C_,2, 80
	continue 60
	continue 10
	snd_loop .call3, $00, 2
	snd_ret
SndData_BGM_MrKarate_Ch2:
	envelope $67
	panning $22
	duty_cycle 1
	snd_call .call0
.loop0:
	snd_call .call1
	snd_call .call2
	snd_call .call0
	snd_call .call0
	snd_call .call0
	snd_call .call0
	snd_call .call0
	snd_loop .loop0
.call0:
	note E_,4, 20
	note C_,4, 10
	note A_,3
	note G_,4
	note A_,3
	note A_,4
	note A_,3
	note E_,4, 20
	note C_,4, 10
	note A_,3
	note D_,4
	note G_,3
	note B_,3
	note D_,3
	snd_loop .call0, $00, 2
	snd_ret
.call1:
	note G_,4, 20
	note D_,4, 2
	silence 3
	note D_,4, 5
	note B_,4, 10
	note D_,4, 2
	silence 3
	note D_,4, 5
	note G_,4, 10
	note D_,4, 2
	silence 3
	note D_,4, 5
	note G_,3, 10
	note G_,4, 20
	note D_,4, 2
	silence 3
	note D_,4, 5
	note B_,4, 10
	note D_,4, 2
	silence 3
	note D_,4, 5
	note G_,4
	note F#,4
	note F_,4
	note E_,4
	note D#,4
	note D_,4
	snd_loop .call1, $00, 4
	snd_ret
.call2:
	envelope $68
	note E_,4, 10
	continue 40
	note F#,4
	note G_,4
	note A_,4, 30
	note A#,4, 10
	continue 40
	note D#,4
	note G_,4, 60
	note B_,4, 10
	note C_,5, 30
	note A#,4, 20
	note G#,4
	note D#,4, 10
	note B_,4
	continue 80
	envelope $67
	silence 10
	note B_,4, 5
	silence
	note B_,4, 10
	note A#,4
	note B_,4
	note A#,4
	note B_,4
	snd_ret
SndData_BGM_MrKarate_Ch3:
	wave_vol $80
	panning $44
	wave_id $04
	wave_cutoff 0
	snd_call .call0
.loop0:
	snd_call .call1
	snd_call .call2
	snd_call .call3
	snd_call .call4
	snd_call .call3
	snd_loop .loop0
.call0:
	note A_,3, 10
	continue 60
	silence 10
	note C_,4, 30
	silence 10
	note E_,3
	silence
	note G_,3
	silence
	note A_,3
	continue 60
	silence 10
	note C_,4, 30
	silence 10
	note E_,3
	silence
	note G_,3
	silence
	snd_ret
.call1:
	wave_cutoff 60
	note A_,3, 20
	wave_cutoff 30
	note F#,3, 10
	note G_,3
	note G#,3
	note A_,3
	note F#,3
	note G_,3
	wave_cutoff 60
	note A_,3, 20
	wave_cutoff 30
	note D_,3, 10
	note D_,4
	note D_,3
	note A_,3
	note D_,3
	note G_,3
	snd_loop .call1, $00, 4
	snd_ret
.call2:
	wave_cutoff 0
	note C_,4, 40
	wave_cutoff 30
	note G_,3, 10
	note C_,4
	note G_,3
	note C_,4
	wave_cutoff 0
	note B_,3, 60
	wave_cutoff 30
	note C#,4, 10
	note D_,4
	wave_cutoff 0
	note D#,4, 40
	wave_cutoff 30
	note A#,3, 10
	note D#,4
	note A#,3
	note D#,4
	wave_cutoff 0
	note D_,4, 60
	wave_cutoff 30
	note E_,4, 10
	note F_,4
	wave_cutoff 0
	note F#,4, 40
	wave_cutoff 30
	note C#,4, 10
	note F#,4
	note C#,4
	note F#,4
	wave_cutoff 60
	note G_,4, 20
	wave_cutoff 30
.call2b:
	note G_,3, 10
	snd_loop .call2b, $00, 8
	note D_,3
	note G_,3
	note F#,3
	note G_,3
	note F#,3
	note G_,3
	snd_ret
.call3:
	wave_cutoff 60
	note A_,3, 20
	wave_cutoff 30
	note A_,3, 10
	note A_,3
	note A_,3
	note A_,3
	note A_,3
	note A_,3
	wave_cutoff 60
	note C_,4, 20
	wave_cutoff 30
	note C_,4, 10
	note C_,4
	wave_cutoff 60
	note E_,3, 20
	wave_cutoff 30
	note D_,3, 10
	note G_,3
	snd_loop .call3, $00, 4
	snd_ret
.call4:
	wave_cutoff 60
	note F_,3, 20
	wave_cutoff 25
	note F_,3, 10
	note F_,3
	note F_,3
	note F_,3
	note F_,3
	note F_,3
	note F_,3
	note F_,3
	note F_,3
	note F_,3
	note F_,3
	note C_,3
	note G_,3
	note C_,3
	snd_loop .call4, $00, 2
	snd_ret
SndData_BGM_MrKarate_Ch4:
	panning $88
	snd_call .call0
.loop0:
	snd_call .call1
	snd_call .call2
	snd_call .call3
	snd_call .call2
	snd_call .call4
	snd_call .call4
	snd_call .call5
	snd_call .call2
	snd_loop .loop0
.call0:
	envelope $61
	note4 F_,5,0, 30
	envelope $62
	note4 B_,5,0, 5
	note4 B_,5,0, 5
	envelope $61
	note4 F_,5,0, 5
	note4 F_,5,0, 5
	envelope $34
	note4 A_,5,0, 10
	envelope $44
	note4 A_,5,0, 10
	envelope $54
	note4 A_,5,0, 10
	envelope $61
	note4 F_,5,0, 20
	note4 F_,5,0, 10
	envelope $62
	note4 B_,5,0, 10
	envelope $61
	note4 F_,5,0, 10
	envelope $62
	note4 B_,5,0, 10
	envelope $34
	note4 A_,5,0, 3
	envelope $44
	note4 A_,5,0, 4
	envelope $54
	note4 A_,5,0, 3
	envelope $61
	note4 F_,5,0, 10
	note4 F_,5,0, 20
	note4 F_,5,0, 5
	note4 F_,5,0, 5
	envelope $62
	note4 B_,5,0, 5
	note4 B_,5,0, 5
	envelope $61
	note4 F_,5,0, 5
	note4 F_,5,0, 5
	envelope $62
	note4 B_,5,0, 5
	note4 B_,5,0, 5
	note4 B_,5,0, 3
	note4 B_,5,0, 4
	note4 B_,5,0, 3
	note4 B_,5,0, 5
	note4 B_,5,0, 5
	envelope $61
	note4 F_,5,0, 20
	note4 F_,5,0, 10
	envelope $62
	note4 B_,5,0, 10
	envelope $61
	note4 F_,5,0, 5
	note4 F_,5,0, 5
	envelope $54
	note4 A_,5,0, 5
	note4x $32, 5 ; Nearest: A_,5,0
	envelope $61
	note4 F_,5,0, 5
	envelope $62
	note4 B_,5,0, 5
	note4 B_,5,0, 5
	note4 B_,5,0, 5
	envelope $61
	note4 F_,5,0, 10
	snd_ret
.call1:
	envelope $01
	note4 B_,5,0, 10
	envelope $53
	note4x $11, 10 ; Nearest: A#,6,0
	envelope $62
	note4 B_,5,0, 10
	envelope $61
	note4 F_,5,0, 5
	envelope $62
	note4 B_,5,0, 5
	envelope $61
	note4 F_,5,0, 5
	envelope $62
	note4 B_,5,0, 5
	envelope $53
	note4x $11, 10 ; Nearest: A#,6,0
	envelope $62
	note4 B_,5,0, 10
	envelope $61
	note4 F_,5,0, 10
	snd_loop .call1, $00, 7
	snd_ret
.call2:
	envelope $01
	note4 B_,5,0, 10
	envelope $61
	note4 F_,5,0, 10
	envelope $62
	note4 B_,5,0, 5
	note4 B_,5,0, 5
	envelope $61
	note4 F_,5,0, 5
	note4 F_,5,0, 5
	envelope $62
	note4 B_,5,0, 5
	note4 B_,5,0, 5
	envelope $34
	note4 A_,5,0, 5
	note4 A_,5,0, 5
	envelope $44
	note4 A_,5,0, 5
	note4x $10, 5 ; Nearest: B_,6,0
	envelope $61
	note4 F_,5,0, 10
	snd_ret
.call3:
	envelope $31
	note4x $21, 10 ; Nearest: A#,5,0
	envelope $61
	note4 F_,5,0, 10
	envelope $53
	note4x $11, 20 ; Nearest: A#,6,0
	envelope $62
	note4 B_,5,0, 10
	envelope $31
	note4x $21, 10 ; Nearest: A#,5,0
	envelope $53
	note4x $11, 10 ; Nearest: A#,6,0
	envelope $61
	note4 F_,5,0, 10
	snd_loop .call3, $00, 6
	snd_ret
.call4:
	envelope $01
	note4 B_,5,0, 10
	envelope $61
	note4 F_,5,0, 10
	envelope $62
	note4 B_,5,0, 20
	envelope $61
	note4 F_,5,0, 10
	note4 F_,5,0, 10
	envelope $62
	note4 B_,5,0, 10
	envelope $61
	note4 F_,5,0, 20
	note4 F_,5,0, 10
	envelope $62
	note4 B_,5,0, 10
	envelope $61
	note4 F_,5,0, 20
	note4 F_,5,0, 10
	envelope $62
	note4 B_,5,0, 10
	envelope $61
	note4 F_,5,0, 10
	snd_loop .call4, $00, 4
	snd_ret
.call5:
	envelope $01
	note4 B_,5,0, 10
	envelope $61
	note4 F_,5,0, 10
	envelope $62
	note4 B_,5,0, 20
	envelope $61
	note4 F_,5,0, 10
	note4 F_,5,0, 10
	envelope $62
	note4 B_,5,0, 10
	envelope $61
	note4 F_,5,0, 20
	note4 F_,5,0, 10
	envelope $62
	note4 B_,5,0, 10
	envelope $61
	note4 F_,5,0, 20
	note4 F_,5,0, 10
	envelope $62
	note4 B_,5,0, 10
	envelope $61
	note4 F_,5,0, 10
	envelope $01
	note4 B_,5,0, 10
	envelope $61
	note4 F_,5,0, 10
	envelope $62
	note4 B_,5,0, 10
	envelope $61
	note4 F_,5,0, 5
	note4 F_,5,0, 5
	envelope $62
	note4 B_,5,0, 5
	note4 B_,5,0, 5
	note4 B_,5,0, 3
	note4 B_,5,0, 4
	note4 B_,5,0, 3
	note4 B_,5,0, 5
	note4 B_,5,0, 5
	envelope $61
	note4 F_,5,0, 5
	note4 F_,5,0, 5
	snd_ret
