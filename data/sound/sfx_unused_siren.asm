SndHeader_SFX_Unused_Siren:
	db $01 ; Number of channels
.ch2:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_SFX_Unused_Siren_Ch2 ; Data ptr
	db 6 ; Initial fine tune
	db $81 ; Unused
SndData_SFX_Unused_Siren_Ch2:
	envelope $0F
	panning $22
	duty_cycle 3
	note D_,3, 1
	lock_envelope
	note E_,3
	note F_,3
	note G_,3
	note A_,3
	note B_,3
	note C_,4
	note D_,4
	note E_,4
	note F_,4
	note G_,4
	note A_,4
	note B_,4
	note C_,5
	note D_,5
	snd_loop SndData_SFX_Unused_Siren_Ch2
