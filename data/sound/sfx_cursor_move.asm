SndHeader_SFX_CursorMove:
	db $01 ; Number of channels
.ch2:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_SFX_CursorMove_Ch2 ; Data ptr
	db $0C ; Base freq/note id
	db $81 ; Unused
SndData_SFX_CursorMove_Ch2:
	sndenv 12, SNDENV_DEC, 3
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 3, 0
	sndnote $22
	sndlen 2
	sndnote $25
	sndnote $29
	sndnote $2C
	sndenv 7, SNDENV_DEC, 3
	sndnote $22
	sndnote $25
	sndnote $29
	sndnote $2C
	sndenv 4, SNDENV_DEC, 3
	sndnote $22
	sndnote $25
	sndnote $29
	sndnote $2C
	sndenv 2, SNDENV_DEC, 3
	sndnote $22
	sndnote $25
	sndnote $29
	sndnote $2C
	sndendch
