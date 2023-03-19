SndHeader_Pause:
	db $03 ; Number of channels
.ch1:
	db SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_PauseUnpause_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_PauseUnpause_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_PauseUnpause_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndHeader_Unpause:
	db $03 ; Number of channels
.ch1:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH1_PTR ; Sound channel ptr
	dw SndData_PauseUnpause_Ch1 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch2:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_PauseUnpause_Ch2 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
.ch3:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH3_PTR ; Sound channel ptr
	dw SndData_PauseUnpause_Ch3 ; Data ptr
	db $00 ; Base freq/note id
	db $81 ; Unused
SndData_PauseUnpause_Ch1:
	sndenach SNDOUT_CH1R|SNDOUT_CH1L
	sndnr11 2, 0
	sndenv 0, SNDENV_DEC, 0
	sndendch
SndData_PauseUnpause_Ch2:
	sndenach SNDOUT_CH2R|SNDOUT_CH2L
	sndnr21 2, 0
	sndenv 0, SNDENV_DEC, 0
	sndendch
SndData_PauseUnpause_Ch3:
	sndenach SNDOUT_CH3R|SNDOUT_CH3L
	sndenvch3 0
	sndendch
