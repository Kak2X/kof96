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
	note4x $51, 2 ; Nearest: A#,4,0
	note4 D_,5,0, 2
	note4 B_,6,0, 2
	note4x $41, 2 ; Nearest: A#,5,0
	note4 G#,5,0, 2
	note4 B_,6,1, 1
	note4 B_,6,0, 1
	chan_stop
