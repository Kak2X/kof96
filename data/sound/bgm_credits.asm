SndHeader_BGM_Credits:
	db $04 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_BGM_Credits_Ch1 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_BGM_Credits_Ch2 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_BGM_Credits_Ch3 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
.ch4:
	db SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_BGM_Credits_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_BGM_Credits_Ch1:
	envelope $77
	panning $11
	duty_cycle 2
.loop0:
	snd_call .call0
	snd_loop .loop0
.call0:
	note F_,5, 60
	note E_,5, 80
	continue 20
	continue 120
	continue 20
	note D_,5, 10
	note E_,5
	note F_,5, 120
	continue 20
	note E_,5, 10
	note D_,5
	note E_,5, 20
	note C_,5, 120
	note D_,5, 10
	note E_,5
	note F_,5, 120
	continue 20
	note A_,5, 10
	note B_,5
	note G_,5, 80
	continue 80
	continue 120
	note E_,5, 13
	note F_,5, 14
	note A_,5, 13
	note G_,5, 80
	continue 80
	continue 80
	continue 80
	note G_,5, 80
	continue 20
	note D#,5
	note F_,5
	note G_,5
	note G_,5, 80
	note G_,5, 30
	note G#,5
	note A#,5, 20
	note F_,5, 120
	continue 20
	note D_,5, 10
	note D#,5
	note D_,5, 80
	continue 80
	note G_,5, 80
	continue 20
	note D#,5
	note F_,5
	note G_,5
	note G_,5, 80
	note A#,5, 30
	note G#,5
	note G_,5, 20
	note F_,5, 80
	continue 80
	note A#,5, 120
	continue 20
	note A_,5, 10
	note A#,5
	note A_,5, 120
	continue 20
	note A_,5, 10
	note A#,5
	note C_,6, 80
	continue 20
	note C_,6
	note A#,5
	note A_,5
	note A#,5, 120
	continue 20
	note G_,5, 10
	note A#,5
	note D#,6, 120
	continue 20
	note D#,6
	note D_,6
	note A#,5, 120
	note C_,6, 10
	note D_,6
	note C_,6, 20
	note A_,5, 120
	note A#,5, 10
	note A_,5
	note A#,5, 120
	continue 20
	note G_,5, 10
	note A#,5
	note D#,6, 80
	continue 20
	note D#,6
	note D_,6
	note C_,6
	note A#,5, 80
	continue 80
	continue 80
	continue 80
	snd_ret
SndData_BGM_Credits_Ch2:
	envelope $11
	panning $22
	duty_cycle 2
	note C_,2, 10
	continue 5
	envelope $37
.loop0:
	snd_call SndData_BGM_Credits_Ch1.call0
	snd_loop .loop0
SndData_BGM_Credits_Ch3:
	wave_vol $80
	panning $44
	wave_id $01
	wave_cutoff 0
	snd_call .call0
	snd_call .call1
	snd_call .call0
	note C_,4, 20
	note G_,4
	note C_,5
	note E_,5
	note C_,5
	note E_,5
	note C_,5
	note E_,5
	snd_call .call2
	snd_call .call3
	snd_call .call2
	snd_call .call3
	note C_,4, 20
	note F_,4
	note A_,4
	note C_,5
	note A_,4
	note C_,5
	note A_,4
	note C_,5
	note C_,4, 20
	note F_,4
	note A_,4
	note C_,5
	note A_,4
	note C_,5
	note A_,4
	note C_,5
	snd_call .call2
	snd_call .call4
	snd_call .call2
	snd_call .call3
	snd_loop SndData_BGM_Credits_Ch3
.call0:
	note C_,4, 20
	note G_,4
	note C_,5
	note E_,5
	note C_,5
	note E_,5
	note C_,5
	note E_,5
	snd_loop .call0, $00, 2
	snd_ret
.call1:
	note C_,4, 20
	note F_,4
	note A_,4
	note C_,5
	note A_,4
	note C_,5
	note A_,4
	note C_,5
	note C_,4, 20
	note G_,4
	note C_,5
	note E_,5
	note C_,5
	note E_,5
	note C_,5
	note E_,5
	snd_loop .call1, $00, 2
	snd_ret
	;--
	; [TCRF] Unreferenced song call
.unused_call:
	note B_,3, 20
	note G_,4
	note B_,4
	note D_,5
	note B_,4
	note D_,5
	note B_,4
	note D_,5
	snd_ret
	;--
.call2:
	note D#,4, 20
	note G_,4
	note A#,4
	note D#,5
	note A#,4
	note D#,5
	note A#,4
	note D#,5
	snd_loop .call2, $00, 2
	snd_ret
.call3:
	note D_,4, 20
	note F_,4
	note A#,4
	note D_,5
	note A#,4
	note D_,5
	note A#,4
	note D_,5
	snd_loop .call3, $00, 2
	snd_ret
.call4:
	note D_,4, 20
	note F_,4
	note A#,4
	note D_,5
	note A#,4
	note D_,5
	note A#,4
	note D_,5
	note C_,4
	note F_,4
	note A_,4
	note C_,5
	note A_,4
	note C_,5
	note A_,4
	note C_,5
	snd_ret
SndData_BGM_Credits_Ch4:
	panning $88
	snd_call .call0
.loop0:
	snd_call .call1
	snd_loop .loop0
.call0:
	envelope $51
	wait 33
	wait 10
	envelope $41
	wait 33
	wait 10
	envelope $31
	wait 33
	wait 10
	envelope $21
	wait 33
	wait 80
	continue 10
	envelope $53
	wait 17
	wait 40
	snd_loop .call0, $00, 9
	snd_ret
.call1:
	envelope $61
	wait 54
	wait 10
	envelope $51
	wait 33
	wait 10
	envelope $41
	wait 33
	wait 10
	envelope $61
	wait 54
	wait 10
	envelope $41
	wait 54
	wait 30
	envelope $41
	wait 54
	wait 10
	envelope $21
	wait 54
	wait 30
	envelope $21
	wait 54
	wait 10
	envelope $53
	wait 17
	wait 40
	snd_ret
