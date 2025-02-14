SndHeader_SFX_FireHitB:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_FireHitB_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_SFX_FireHitB_Ch4:
	envelope $3B
	panning $88
	note4 A#,4,0, 70
	chan_stop
