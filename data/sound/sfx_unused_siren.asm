SndHeader_SFX_Unused_Siren:
	db $01 ; Number of channels
.ch2:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndHeader_SFX_Unused_Siren_Ch2 ; Data ptr
	db $06 ; Base freq/note id
	db $81 ; Unused
SndHeader_SFX_Unused_Siren_Ch2:
	sndenv 0, SNDENV_INC, 7
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 3, 0
	sndnote $0F
	sndlen 1
	sndsetskip
	sndnote $11
	sndnote $12
	sndnote $14
	sndnote $16
	sndnote $18
	sndnote $19
	sndnote $1B
	sndnote $1D
	sndnote $1E
	sndnote $20
	sndnote $22
	sndnote $24
	sndnote $25
	sndnote $27
	sndloop SndHeader_SFX_Unused_Siren_Ch2
