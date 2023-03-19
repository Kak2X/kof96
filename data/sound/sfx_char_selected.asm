SndHeader_SFX_CharSelected:
	db $01 ; Number of channels
.ch2:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_SFX_CharSelected_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_SFX_CharSelected_Ch2:
	sndenv 15, SNDENV_DEC, 2
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 3, 0
	sndnote $1D
	sndlen 2
	sndnote $25
	sndnote $20
	sndnote $29
	sndnote $25
	sndnote $2C
	sndnote $29
	sndnote $31
	sndenv 9, SNDENV_DEC, 2
	sndnote $1D
	sndlen 2
	sndnote $25
	sndnote $20
	sndnote $29
	sndnote $25
	sndnote $2C
	sndnote $29
	sndnote $31
	sndenv 5, SNDENV_DEC, 2
	sndnote $1D
	sndlen 2
	sndnote $25
	sndnote $20
	sndnote $29
	sndnote $25
	sndnote $2C
	sndnote $29
	sndnote $31
	sndenv 2, SNDENV_DEC, 2
	sndnote $1D
	sndlen 2
	sndnote $25
	sndnote $20
	sndnote $29
	sndnote $25
	sndnote $2C
	sndnote $29
	sndnote $31
	sndendch
