SndHeader_SFX_ChargeMeter:
	db $01 ; Number of channels
.ch2:
	db SIS_SFX|SIS_ENABLED ; Initial playback status
	db SND_CH2_PTR ; Sound channel ptr
	dw SndData_SFX_ChargeMeter_Ch2 ; Data ptr
	db 12 ; Initial fine tune
	db $81 ; Unused
SndData_SFX_ChargeMeter_Ch2:
	envelope $6A
	panning $22
	duty_cycle 0
	snd_call .playSet
	fine_tune 1
	snd_call .playSet
	fine_tune 1
	snd_call .playSet
	fine_tune 1
	snd_call .playSet
	fine_tune 1
	snd_call .playSet
	fine_tune 1
	snd_call .playSet
	fine_tune 1
	snd_call .playSet
	fine_tune 1
	snd_call .playSet
	fine_tune 1
	snd_call .playSet
	fine_tune 1
	snd_call .playSet
	fine_tune 1
	snd_call .playSet
	fine_tune 1
	snd_call .playSet
	fine_tune 1
	snd_call .playSet
	chan_stop
.playSet:
	note C_,5, 1
	note C#,5
	note D_,5
	note C#,5
	snd_loop .playSet, $00, 2
	snd_ret
