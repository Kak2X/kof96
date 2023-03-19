SndHeader_SFX_PsychoTeleport:
	db $01 ; Number of channels
.ch2:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_SFX_PsychoTeleport_Ch2 ; Data ptr
	db $0C ; Base freq/note id
	db $81 ; Unused
SndData_SFX_PsychoTeleport_Ch2:
	sndenv 1, SNDENV_INC, 4
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 3, 0
	sndnote $2E
	sndlen 1
	sndsetskip
	sndnote $2F
	sndloopcnt $00, 30, SndData_SFX_PsychoTeleport_Ch2
	sndendch
