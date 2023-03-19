SndHeader_SFX_ChargeMeter:
	db $01 ; Number of channels
.ch2:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_SFX_ChargeMeter_Ch2 ; Data ptr
	db $0C ; Base freq/note id
	db $81 ; Unused
SndData_SFX_ChargeMeter_Ch2:
	sndenv 6, SNDENV_INC, 2
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 0, 0
	sndcall .playSet
	sndnotebase $01
	sndcall .playSet
	sndnotebase $01
	sndcall .playSet
	sndnotebase $01
	sndcall .playSet
	sndnotebase $01
	sndcall .playSet
	sndnotebase $01
	sndcall .playSet
	sndnotebase $01
	sndcall .playSet
	sndnotebase $01
	sndcall .playSet
	sndnotebase $01
	sndcall .playSet
	sndnotebase $01
	sndcall .playSet
	sndnotebase $01
	sndcall .playSet
	sndnotebase $01
	sndcall .playSet
	sndnotebase $01
	sndcall .playSet
	sndendch
.playSet:
	sndnote $25
	sndlen 1
	sndnote $26
	sndnote $27
	sndnote $26
	sndloopcnt $00, 2, .playSet
	sndret
