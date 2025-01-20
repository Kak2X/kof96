SndHeader_BGM_CharSelect:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_CharSelect_Ch1 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_CharSelect_Ch2 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_CharSelect_Ch3 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_CharSelect_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_BGM_CharSelect_Ch1:
	envelope $11
	panning $11
	duty_cycle 3
	note A_,2, 48
	envelope $76
.loop0:
	snd_call .call0
	snd_call .call1
	snd_call .call0
	snd_call .call2
	snd_loop .loop0
.call0:
	envelope $76
	note A_,2, 12
	envelope $11
	note A_,2, 72
	envelope $76
	note G_,2, 12
	note A_,2
	envelope $11
	note A_,2, 36
	envelope $76
	note C_,3, 12
	note A_,2, 6
	snd_ret
.call1:
	note D_,3, 6
	silence
	note C_,3
	note G_,2, 12
	snd_ret
.call2:
	note D_,3, 12
	note G_,2, 6
	note D_,3, 12
	snd_ret
SndData_BGM_CharSelect_Ch2:
	envelope $11
	panning $22
	duty_cycle 2
	note A_,2, 48
	envelope $52
.loop0:
	snd_call .call0
	snd_call .call1
	snd_loop .loop0
.call0:
	note G_,5, 6
	note D_,5
	note C_,6, 12
	note G_,5, 6
	note D_,5
	note C_,6
	note D_,5
	snd_loop .call0, $00, 3
	snd_ret
.call1:
	note G_,5, 6
	note D_,5
	note C_,6, 12
	note G_,5, 6
	note D_,5
	note C_,6
	note D_,6
	snd_ret
SndData_BGM_CharSelect_Ch3:
	wave_vol $00
	panning $44
	wave_id $04
	wave_cutoff 50
	note A_,2, 48
	wave_vol $80
.loop0:
	snd_call .call0
	snd_call .call1
	snd_call .call0
	snd_call .call2
	snd_loop .loop0
.call0:
	note A_,2, 12
	note G_,2, 6
	note A_,2
	silence
	note C_,3
	note G_,2
	note G#,2
	note A_,2, 3
	silence 9
	note D_,3, 12
	note C_,3, 6
	note A_,2, 12
	note G_,2, 6
	snd_ret
.call1:
	note A_,2, 12
	note G_,2, 6
	note A_,2
	silence
	note C_,3
	note G_,2, 12
	note D_,2, 6
	note G_,2
	note A_,2
	note D_,3
	silence
	note C_,3
	note G_,2, 12
	snd_ret
.call2:
	note A_,2, 12
	note G_,2, 6
	note A_,2
	silence
	note C_,3
	note G_,2, 12
	note C_,3
	note A_,2, 6
	note D_,3, 12
	note G_,2, 6
	note D_,3, 12
	snd_ret
SndData_BGM_CharSelect_Ch4:
	panning $88
	envelope $61
	wait 54
	wait 6
	envelope $62
	wait 36
	wait 12
	wait 36
	wait 6
	wait 36
	wait 12
	wait 36
	wait 6
	wait 36
	wait 6
.loop0:
	snd_call .call0
	snd_loop .loop0
.call0:
	envelope $61
	wait 54
	wait 12
	wait 54
	wait 12
	envelope $62
	wait 36
	wait 24
	envelope $61
	wait 54
	wait 12
	wait 54
	wait 12
	envelope $62
	wait 36
	wait 18
	envelope $61
	wait 54
	wait 6
	wait 54
	wait 12
	wait 54
	wait 12
	envelope $62
	wait 36
	wait 18
	wait 36
	wait 6
	envelope $61
	wait 54
	wait 6
	envelope $62
	wait 36
	wait 6
	envelope $61
	wait 54
	wait 12
	envelope $62
	wait 36
	wait 6
	envelope $61
	wait 54
	wait 12
	wait 54
	wait 6
	wait 97
	wait 12
	wait 54
	wait 12
	envelope $62
	wait 36
	wait 24
	wait 97
	wait 12
	wait 54
	wait 12
	envelope $62
	wait 36
	wait 24
	wait 54
	wait 12
	wait 54
	wait 12
	envelope $62
	wait 36
	wait 18
	wait 36
	wait 6
	envelope $61
	wait 54
	wait 6
	envelope $62
	wait 36
	wait 6
	envelope $61
	wait 54
	wait 12
	envelope $62
	wait 36
	wait 12
	wait 36
	wait 6
	wait 36
	wait 6
	snd_ret
