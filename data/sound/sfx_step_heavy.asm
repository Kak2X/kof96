SndHeader_SFX_StepHeavy:
	db $01 ; Number of channels
.ch4:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH4_PTR ; Sound channel ptr
	dw SndData_SFX_StepHeavy_Ch4 ; Data ptr
	db 0 ; Initial fine tune
	db $81 ; Unused
SndData_SFX_StepHeavy_Ch4:
	envelope $A1
	panning $88
	wait 81
	wait 2
	wait 69
	wait 2
	wait 0
	wait 2
	wait 65
	wait 2
	wait 39
	wait 2
	wait 8
	wait 1
	wait 0
	wait 1
	chan_stop
