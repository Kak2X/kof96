GFX_Char_Kyo_RedKickL4: INCBIN "data/gfx/char/kyo_redkickl4.bin"
GFX_Char_Kyo_OniyakiL3: INCBIN "data/gfx/char/kyo_oniyakil3.bin"
GFX_Char_Kyo_OniyakiL4: INCBIN "data/gfx/char/kyo_oniyakil4.bin"
GFX_Char_Kyo_KototsukiYouL0: INCBIN "data/gfx/char/kyo_kototsukiyoul0.bin"

; 
; =============== START OF MODULE Title ===============
;
; =============== Module_Title ===============
; EntryPoint for Title Screen and Menus.
Module_Title:
	ld   sp, $DD00
	di
	;-----------------------------------
	rst  $10				; Stop LCD
	call DisableSectLYC
	ld   hl, wMisc_C028
	res  MISCB_PL_RANGE_CHECK, [hl]
	set  MISCB_TITLE_SECT, [hl]			; Enable title parallax mode
	
	; Init vars
	xor  a
	ldh  [rBGP], a
	ldh  [rOBP0], a
	ldh  [rOBP1], a
	ld   [wTitleMode], a
	ld   [wJoyActivePl], a
	ld   [wTitleMenuOptId], a
	ld   [wTitleMenuCursorXBak], a
	ld   [wTitleMenuCursorYBak], a
	ld   [wTitleSubMenuOptId], a
	ld   [wOptionsSGBSndOptId], a
	ld   [wOptionsBGMId], a
	ld   [wOptionsSFXId], a
	ld   [wOptionsMenuMode], a
	ld   [wTitleBlinkTimer], a
	ld   [wOptionsSGBSndIdA], a
	ld   [wOptionsSGBSndBankA], a
	ld   [wOptionsSGBSndIdB], a
	ld   [wOptionsSGBSndBankB], a
	ld   [wTitleParallaxBaseSpeed], a
	ld   [wTitleParallaxBaseSpeedSub], a
	
	; After 30 seconds of inactivity in GM_TITLE_TITLE, return to the intro
	ld   a, HIGH(TITLE_RESET_TIMER)
	ld   [wTitleResetTimer_High], a
	ld   a, LOW(TITLE_RESET_TIMER)
	ld   [wTitleResetTimer_Low], a
	
	; Copy the SGB packet used to play audio in the SGB Sound Test at the start of the LZSS Buffer.
	; This will take up $10 bytes, and cause the actual LZSS buffer in the module to start $10 bytes after.
	ld   hl, SGBPacketDef_Options_PlaySnd
	ldi  a, [hl]					; B = Bytes to copy
	ld   b, a						
	ld   de, wOptionsSGBPacketSnd	; DE = Target
	; The remaining bytes are copied into the buffer
.cpLoop:
	ldi  a, [hl]			
	ld   [de], a			
	inc  de
	dec  b					; Are we done?
	jp   nz, .cpLoop		; If not, loop
	
	; Load SGB palettes
	ld   de, SCRPAL_TITLE
	call HomeCall_SGB_ApplyScreenPalSet
	
	; Clear tilemaps
	call ClearBGMap
	call ClearWINDOWMap
	
	; Init scroll positions for BG layer, used for the parallax clouds.
	xor  a
	ldh  [hScrollX], a
	ldh  [hTitleParallax1X], a
	ldh  [hTitleParallax2X], a
	ldh  [hTitleParallax3X], a
	ldh  [hTitleParallax4X], a
	ldh  [hTitleParallax5X], a
	ld   [wOBJScrollX], a
	
IF ENGLISH == 0
	ld   a, $00
	ld   [wOBJScrollY], a
	ld   a, $7C
	ldh  [hScrollY], a
ELSE
	; To make space for the extra two rows of copyright text at the bottom of the screen,
	; everything is shifted up by 16px.
	ld   a, $10
	ld   [wOBJScrollY], a
	ld   a, $8C
	ldh  [hScrollY], a
ENDC
	
	; FarCall to self bank... did it use to be elsewhere?
	ld   b, BANK(Title_LoadVRAM) ; BANK $1C
	ld   hl, Title_LoadVRAM
	rst  $08
	
	;
	; Write the menu text in the BG layer.
	;
	; Because the BG layer only contains a 3-tiles tall horizontal strip, there's enough space
	; to generate both text-only menu screens.
	; The tilemap won't be touched again when navigating through the title screen/menus,
	; only the graphics will be reloaded.
	;
	
	ld   hl, TextDef_Menu_Title
	call TextPrinter_Instant
	ld   hl, TextDef_Menu_SinglePlay
	call TextPrinter_Instant
	ld   hl, TextDef_Menu_TeamPlay
	call TextPrinter_Instant
	ld   hl, TextDef_Menu_SingleVS
	call TextPrinter_Instant
	ld   hl, TextDef_Menu_TeamVS
	call TextPrinter_Instant
	ld   hl, TextDef_Options_Title
	call TextPrinter_Instant
	ld   hl, TextDef_Options_Time
	call TextPrinter_Instant
	ld   hl, TextDef_Options_Level
	call TextPrinter_Instant
	ld   hl, TextDef_Options_BGMTest
	call TextPrinter_Instant
	ld   hl, TextDef_Options_SFXTest
	call TextPrinter_Instant
	ld   hl, TextDef_Options_Exit
	call TextPrinter_Instant
	
	; If dip switches are set, display the dip value and any extra options
	ld   a, [wDipSwitch]
	or   a						; Any dip switch set?
	jp   z, .noDip				; If not, skip
	ld   hl, TextDef_Options_Dip
	call TextPrinter_Instant
.noDip:
	; Print text for SGB sound test
	ld   a, [wMisc_C025]
	bit  MISCB_IS_SGB, a		; Running on a SGB?
	jp   z, .initOBJ			; If not, skip
	ld   a, [wDipSwitch]
	bit  DIPB_SGB_SOUND_TEST, a	; SGB sound test enabled?
	jp   z, .initOBJ			; If not, skip
	
	ld   hl, TextDef_Options_SGBSndTest
	call TextPrinter_Instant
	ld   hl, TextDef_Options_SGBSndTypes
	call TextPrinter_Instant
	ld   hl, TextDef_Options_SGBSndPlaceholders
	call TextPrinter_Instant
.initOBJ:
	;
	; Prepare sprites.
	; These all use OBJLstPtrTable_Title, with different offsets.
	;
	
	call ClearOBJInfo
	
	; OBJ2 - (C)SNK 1996 text
	ld   hl, wOBJInfo_SnkText+iOBJInfo_Status
	ld   de, OBJInfoInit_Title
	call OBJLstS_InitFrom
IF ENGLISH == 0
	; Centered in the Japanese version (like the Takara copyright in the tilemap)
	ld   hl, wOBJInfo_SnkText+iOBJInfo_X
	ld   [hl], $34
	ld   hl, wOBJInfo_SnkText+iOBJInfo_Y
	ld   [hl], $48
ELSE
	; Left aligned in the English version
	ld   hl, wOBJInfo_SnkText+iOBJInfo_X
	ld   [hl], $00
	ld   hl, wOBJInfo_SnkText+iOBJInfo_Y
	ld   [hl], $47
ENDC
	ld   hl, wOBJInfo_SnkText+iOBJInfo_OBJLstPtrTblOffset
	ld   [hl], TITLE_OBJ_SNKCOPYRIGHT*OBJLSTPTR_ENTRYSIZE
	
	; OBJ1 - Title screen menu text (PUSH START, ...)
	ld   hl, wOBJInfo_MenuText+iOBJInfo_Status
	ld   de, OBJInfoInit_Title
	call OBJLstS_InitFrom
	ld   hl, wOBJInfo_MenuText+iOBJInfo_Status
	res  OSTB_VISIBLE, [hl]
	ld   hl, wOBJInfo_MenuText+iOBJInfo_X
	ld   [hl], $28
	ld   hl, wOBJInfo_MenuText+iOBJInfo_Y
IF ENGLISH == 0
	ld   [hl], $43
ELSE
	; Moved 1px down, to avoid having white text touch the white part of the new logo
	ld   [hl], $44
ENDC
	; Entry $00
	
	; OBJ0 - Cursor pointing right
	ld   hl, wOBJInfo_CursorR+iOBJInfo_Status
	ld   de, OBJInfoInit_Title
	call OBJLstS_InitFrom
	ld   hl, wOBJInfo_CursorR+iOBJInfo_Status
	res  OSTB_VISIBLE, [hl]
	ld   hl, wOBJInfo_CursorR+iOBJInfo_X
	ld   [hl], $28
	ld   hl, wOBJInfo_CursorR+iOBJInfo_Y
IF ENGLISH == 0
	ld   [hl], $43	; Needs to be aligned with menu text
ELSE
	ld   [hl], $44
ENDC
	ld   hl, wOBJInfo_CursorR+iOBJInfo_OBJLstPtrTblOffset
	ld   [hl], TITLE_OBJ_CURSOR_R*OBJLSTPTR_ENTRYSIZE
	
	; OBJ3 - Cursor pointing up (for SGB Sound Test)
	ld   hl, wOBJInfo_CursorU+iOBJInfo_Status
	ld   de, OBJInfoInit_Title
	call OBJLstS_InitFrom
	ld   hl, wOBJInfo_CursorU+iOBJInfo_Status
	res  OSTB_VISIBLE, [hl]
	ld   hl, wOBJInfo_CursorU+iOBJInfo_X
	ld   [hl], $50
	ld   hl, wOBJInfo_CursorU+iOBJInfo_Y
	ld   [hl], $60
	ld   hl, wOBJInfo_CursorU+iOBJInfo_OBJLstPtrTblOffset
	ld   [hl], TITLE_OBJ_CURSOR_U*OBJLSTPTR_ENTRYSIZE
	
	; Put WINDOW over BG
	xor  a
	ldh  [rWY], a
	ld   a, $07
	ldh  [rWX], a
	
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_OBJSIZE|LCDC_WENABLE|LCDC_WTILEMAP|LCDC_ENABLE
	rst  $18				; Resume LCD
	;-----------------------------------
	
	; Enable LYC, start parallax at line $66
	ldh  a, [rSTAT]
	or   a, STAT_LYC
	ldh  [rSTAT], a
IF ENGLISH == 0
	ld   a, $66
ELSE
	ld   a, $56
ENDC
	ldh  [rLYC], a
	ldh  a, [rIE]
	or   a, I_STAT|I_VBLANK
	ldh  [rIE], a
	
	ei
	
	call Task_PassControl_NoDelay
	
	; Load DMG palettes
	ld   a, $3F
	ldh  [rOBP0], a
	ld   a, $00
	ldh  [rOBP1], a
	ld   a, $1B
	ldh  [rBGP], a
	
	; Stop music
	ld   a, SND_MUTE
	call HomeCall_Sound_ReqPlayExId_Stub
	
	; Disable serial since the game shouldn't process the other GB inputs on the menu
	; (outside of when a VS mode is selected)
	call Title_DisableSerial
	
	
	; The English version forces you to wait for a few seconds before enabling controls,
	; presumably so you're forced to see those copyrights covering more of the screen.
	; By the time this loop is finished, the cloud layer will have fully scrolled up.
IF ENGLISH == 1
	ld   b, $78		; B = Number of frames
.delayLoop:
	push bc
		call Title_UpdateParallaxCoords		; Update effect
		call Task_PassControl_NoDelay		; Wait frame
	pop  bc
	dec  b					; Are we done waiting?
	jp   nz, .delayLoop		; If not, loop
ENDC
	
.mainLoop:
	call JoyKeys_DoCursorDelayTimer
	call .execMode
	call Task_PassControl_NoDelay
	jp   .mainLoop
.execMode:
	; DynJump for title screen mode
	ld   hl, Title_ModePtrTable	; HL = Title_ModePtrTable
	ld   d, $00
	ld   a, [wTitleMode]		; DE = wTitleMode
	ld   e, a
	add  hl, de					; Offset the table
	ld   e, [hl]				; Read out jump target to DE
	inc  hl
	ld   d, [hl]
	push de
	pop  hl						; Move to HL and jump there
	jp   hl
	
Title_ModePtrTable:
	dw Title_Mode_TitleScreen
	dw Title_Mode_TitleMenu
	dw Title_Mode_ModeSelect
	dw Title_Mode_Options
	
; =============== Title_Mode_TitleScreen ===============
; Title screen - Initial mode.
Title_Mode_TitleScreen:
	call TitleScreen_CheckReset
	call TitleScreen_BlinkPushStartText
	call Title_UpdateParallaxCoords
	call TitleScreen_IsStartPressed ; Pressed START?
	jp   c, .switchToTitleMenu ; If so, jump
	ret
.switchToTitleMenu:
	;
	; Activate the GAME START/OPTIONS menu on the title screen
	;
	ld   a, GM_TITLE_TITLEMENU		; Next mode
	ld   [wTitleMode], a
	ld   a, $00						; Select GAME START
	ld   [wTitleMenuOptId], a
	
	; Display cursor
	ld   hl, wOBJInfo_CursorR+iOBJInfo_Status
	set  OSTB_VISIBLE, [hl]
	ld   hl, wOBJInfo_CursorR+iOBJInfo_Y
IF ENGLISH == 0
	ld   [hl], $43
ELSE
	ld   [hl], $44
ENDC

	; Change OBJLst id to GAME START/OPTIONS text
	ld   hl, wOBJInfo_MenuText+iOBJInfo_Status
	set  OSTB_VISIBLE, [hl]
	ld   hl, wOBJInfo_MenuText+iOBJInfo_OBJLstPtrTblOffset
	ld   [hl], TITLE_OBJ_MENU*OBJLSTPTR_ENTRYSIZE
	ret
	
; =============== TitleScreen_CheckReset ===============
; Checks if enough time has passed without pressing START.
; If enough frames have passed, reset to the intro.
TitleScreen_CheckReset:
	; wTitleResetTimer--
	ld   hl, wTitleResetTimer_Low	
	dec  [hl]							; Decrement low byte
	jp   nz, .ret						; Is it 0 now? If not, return
	ld   [hl], LOW(TITLE_RESET_TIMER)	; Reset to 60 frames
	ld   hl, wTitleResetTimer_High	
	dec  [hl]							; Decrement high byte
	jp   nz, .ret						; Is it 0 now? If not, return
	
	; If we got here, wTitleResetTimer_Low and wTitleResetTimer_High are 0.
	; Return to the TAKARA logo.
	xor  a
	ldh  [rBGP], a
	ldh  [rOBP0], a
	ldh  [rOBP1], a
	ld   b, BANK(Module_TakaraLogo) ; BANK $0A
	ld   hl, Module_TakaraLogo
	rst  $00
.ret:
	ret
	
; =============== Title_Mode_TitleMenu ===============
; Title screen - Menu.
Title_Mode_TitleMenu:
	call Title_BlinkCursorR
	call Title_UpdateParallaxCoords
	call TitleMenu_DoCtrl
	ret  nc	; If we're not switching (C flag clear), return
	
	cp   TITLEMENU_TO_TITLE
	jp   z, .toTitle
	cp   TITLEMENU_TO_MODESELECT
	jp   z, .toModeSelect
	cp   TITLEMENU_TO_OPTIONS
	jp   z, .toOptions
	ret ; We never get here
	
.toTitle:
	;
	; Return back to PUSH START prompt
	;
	ld   a, GM_TITLE_TITLE			
	ld   [wTitleMode], a
	ld   a, HIGH(TITLE_RESET_TIMER)	
	ld   [wTitleResetTimer_High], a
	ld   a, LOW(TITLE_RESET_TIMER)
	ld   [wTitleResetTimer_Low], a
	
	; Hide cursor
	ld   hl, wOBJInfo_CursorR+iOBJInfo_Status
	res  OSTB_VISIBLE, [hl]
	; Switch to PUSH START text
	ld   hl, wOBJInfo_MenuText+iOBJInfo_OBJLstPtrTblOffset
	ld   [hl], TITLE_OBJ_PUSHSTART
	ret
	
.toModeSelect:
	
	call Title_DisableSerial
	
	; Reset pal
	ld   a, $FF
	ldh  [rBGP], a
	ldh  [rOBP0], a
	ldh  [rOBP1], a
	
	; Start over SINGLE PLAY
	ld   a, $00
	ld   [wTitleSubMenuOptId], a
	
	; Next mode
	ld   a, GM_TITLE_MODESELECT
	ld   [wTitleMode], a
	
	; Set the BG scroll to where the mode select text is
	xor  a
	ldh  [hScrollX], a
	ldh  [hTitleParallax1X], a
	ldh  [hTitleParallax2X], a
	ldh  [hTitleParallax3X], a
	ldh  [hTitleParallax4X], a
	ldh  [hTitleParallax5X], a
	ld   a, $20
	ldh  [hScrollY], a
	
	; Move cursor sprite down 8px by pretending the screen is scrolled up by 8px.
	;
	; We aren't using sections in menus so the BG is unaffected, 
	; but the sprite mapping writer still takes this into consideration.
	ld   a, -$08					
	ld   [wOBJScrollY], a
	
	; Save current cursor location
	ld   a, [wOBJInfo_CursorR+iOBJInfo_X]
	ld   [wTitleMenuCursorXBak], a
	ld   a, [wOBJInfo_CursorR+iOBJInfo_Y]
	ld   [wTitleMenuCursorYBak], a
	
	jp   .initMenu
.toOptions:

	; Reset pal
	ld   a, $FF
	ldh  [rBGP], a
	ldh  [rOBP0], a
	ldh  [rOBP1], a
	
	; Reset cursor pos
	ld   a, $00
	ld   [wTitleSubMenuOptId], a
	ld   [wOptionsSGBSndOptId], a
	ld   [wOptionsMenuMode], a
	ld   [wOptionsBGMId], a
	ld   [wOptionsSFXId], a
	
	; Next mode
	ld   a, GM_TITLE_OPTIONS
	ld   [wTitleMode], a
	
	; Set the BG scroll to where the option menu text is
	ld   a, $80
	ldh  [hScrollX], a
	ld   a, $20
	ldh  [hScrollY], a
	ld   a, $08
	ld   [wOBJScrollY], a
	
	; Save current cursor location
	ld   a, [wOBJInfo_CursorR+iOBJInfo_X]
	ld   [wTitleMenuCursorXBak], a
	ld   a, [wOBJInfo_CursorR+iOBJInfo_Y]
	ld   [wTitleMenuCursorYBak], a
	
	; Print the current option values
	call Options_PrintMatchTime
	call Options_PrintDifficulty
	call Options_PrintBGMId
	call Options_PrintSFXId
	call Options_PrintSGBSndTestVals
	call Options_PrintDipSwitch
.initMenu:

	;
	; Common menu loader
	;

	; Menu options start at the same X position
	; The screen scrolling and text positions must account for this and be aligned perfectly.
	ld   a, $20
	ld   [wOBJInfo_CursorR+iOBJInfo_X], a
	ld   a, $00
	ld   [wOBJInfo_CursorR+iOBJInfo_Y], a
	
	; Show horizontal cursor
	ld   hl, wOBJInfo_CursorR+iOBJInfo_Status
	set  OSTB_VISIBLE, [hl]
	; Hide title screen menu & SNK copyright
	ld   hl, wOBJInfo_MenuText+iOBJInfo_Status
	res  OSTB_VISIBLE, [hl]
	ld   hl, wOBJInfo_SnkText+iOBJInfo_Status
	res  OSTB_VISIBLE, [hl]
	
	; Disable title screen parallax
	ld   hl, wMisc_C028
	res  MISCB_TITLE_SECT, [hl]		; Disable parallax mode
	xor  a
	ldh  [rSTAT], a					; Disable LYC
	
	; Load generic font
	call LoadGFX_1bppFont_Default
	
	; Disable WINDOW
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_OBJSIZE|LCDC_WTILEMAP|LCDC_ENABLE
	rst  $18				; Resume LCD
	;-----------------------------------
	
	call Task_PassControl_NoDelay
	
	; Load palettes.
	; Note that the SGB palette configuration remains the same as the title screen.
	ld   a, $3F
	ldh  [rOBP0], a
	ld   a, $00
	ldh  [rOBP1], a
	ld   a, $1B
	ldh  [rBGP], a
	ret
	
; =============== TitleMenu_DoCtrl ===============
; Checks for player input in the title screen menu.
; OUT
; - C flag: If set, the game should transition to another submode.
; - A: Determines the new mode (TITLEMENU_TO_*)
TitleMenu_DoCtrl:
	call Title_GetMenuInput
	bit  KEYB_DOWN, b
	jp   nz, .moveV
	bit  KEYB_UP, b
	jp   nz, .moveV
	bit  KEYB_LEFT, b
	jp   nz, .incParallaxSpeed
	bit  KEYB_RIGHT, b
	jp   nz, .decParallaxSpeed
	bit  KEYB_START, a
	jp   nz, .enter
	bit  KEYB_SELECT, a
	jp   nz, .exit
	bit  KEYB_A, a
	jp   nz, .enter
	xor  a
	ret
	
; [POI] Secret.
;       Hold right or left to change cloud speed.
.incParallaxSpeed:
	ld   hl, wTitleParallaxBaseSpeed
	ld   bc, $0008
	call Title_AddWithSubpixels
	xor  a
	ret
.decParallaxSpeed:
	ld   hl, wTitleParallaxBaseSpeed
	ld   bc, -$0008
	call Title_AddWithSubpixels
	xor  a
	ret
.moveV:
	;--
	; Not necessary
	ld   hl, wOBJInfo_CursorR+iOBJInfo_Status
	set  OSTB_VISIBLE, [hl]
	;--
	
	; Change selected option
	; Because there are only two menu options, a xor is all that's needed
	ld   a, [wTitleMenuOptId]
	xor  $01
	ld   [wTitleMenuOptId], a
	
	; Move the cursor 8px up or down depending on the new selected option
	cp   TITLEMENU_TO_MODESELECT-1		; wTitleMenuOptId == 0?
	jp   z, .modeSelect					; If so, jump
.options:
	ld   a, [wOBJInfo_CursorR+iOBJInfo_Y]	; Low option, move down
	add  a, $08
	ld   [wOBJInfo_CursorR+iOBJInfo_Y], a
	xor  a
	ret
.modeSelect:
	ld   a, [wOBJInfo_CursorR+iOBJInfo_Y]	; High option, move up
	sub  a, $08
	ld   [wOBJInfo_CursorR+iOBJInfo_Y], a
	xor  a
	ret
.enter:
	; RetVal = wTitleMenuOptId+1
	; Will be TITLEMENU_TO_MODESELECT or TITLEMENU_TO_OPTIONS
	ld   a, [wTitleMenuOptId]
	inc  a
	scf			; Change mode
	ret
.exit:
	ld   a, TITLEMENU_TO_TITLE
	scf			; Change mode
	ret
	
; =============== Title_Mode_ModeSelect ===============
; Mode selection menu.
Title_Mode_ModeSelect:
	call ModeSelect_SetSerialIdle	; Every time so the GBs are always ready to listen to each other.
	call Title_BlinkCursorR
	call ModeSelect_DoCtrl
	jr   nc, .checkOtherPl			; No action returned? If so, jump
.chkAct:
	cp   MODESELECT_ACT_EXIT
	jp   z, TitleSubMenu_Exit
	cp   MODESELECT_ACT_SINGLE1P
	jp   z, .single1P
	cp   MODESELECT_ACT_TEAM1P
	jp   z, .team1P
	cp   MODESELECT_ACT_SINGLEVS
	jp   z, .singleVS
	cp   MODESELECT_ACT_TEAMVS
	jp   z, .teamVS
	ret ; We never get here
.checkOtherPl:
	; Check if the other player (over serial only) sent us a mode id value.
	; If so, start the mode directly.
	call ModeSelect_GetCtrlFromSerial
	cp   MODESELECT_SBCMD_TEAMVS
	jp   z, .startTeamVS
	cp   MODESELECT_SBCMD_SINGLEVS
	jp   z, .startSingleVS
	ret
	
.single1P:
	; 1P Modes don't need special checks
	ld   a, MODE_SINGLE1P
	ld   [wPlayMode], a
	jp   ModeSelect_PrepSingle
.team1P:
	ld   a, MODE_TEAM1P
	ld   [wPlayMode], a
	jp   ModeSelect_PrepSingle
	
.singleVS:
	;
	; Verify that there's a second player
	;
IF ENGLISH == 1
	call ModeSelect_CheckWatchMode		; Full watch mode?
	jp   c, .startSingleVS					; If so, skip the serial checks (no 2P inputs required)
ENDC
	ld   a, [wMisc_C025]
	bit  MISCB_IS_SGB, a		; Playing on SGB?
	jp   nz, .startSingleVS		; If so, skip the serial checks
	
	; [Master 1/3] Send out VS mode option
	ld   a, MODESELECT_SBCMD_SINGLEVS
	call ModeSelect_Serial_SendAndWait
	; Try to send the rest for sync
	call ModeSelect_TrySendVSData
	cp   MODESELECT_SBCMD_IDLE		; Did the other GB listen to the original request? 
	jr   z, .startSingleVS			; If so, jump
IF ENGLISH == 0
	ld   a, SFX_GAMEOVER
ELSE
	ld   a, SFX_PSYCTEL
ENDC
	jp   HomeCall_Sound_ReqPlayExId
.startSingleVS:
	ld   a, MODE_SINGLEVS
	ld   [wPlayMode], a
	jp   ModeSelect_PrepVS
	
.teamVS:
IF ENGLISH == 1
	call ModeSelect_CheckWatchMode		; Full watch mode?
	jp   c, .startTeamVS					; If so, skip the serial checks (no 2P inputs required)
ENDC
	ld   a, [wMisc_C025]
	bit  MISCB_IS_SGB, a		; Playing on SGB?
	jp   nz, .startTeamVS		; If so, skip the serial checks
	; [Master 1/3] Send out VS mode option
	ld   a, MODESELECT_SBCMD_TEAMVS
	call ModeSelect_Serial_SendAndWait
	; Try to send the rest for sync
	call ModeSelect_TrySendVSData
	cp   MODESELECT_SBCMD_IDLE		; Did the other GB listen to the original request? 
	jr   z, .startTeamVS			; If so, jump
	; Otherwise, play an error sound
IF ENGLISH == 0
	ld   a, SFX_GAMEOVER
ELSE
	ld   a, SFX_PSYCTEL
ENDC
	jp   HomeCall_Sound_ReqPlayExId
.startTeamVS: 
	ld   a, MODE_TEAMVS
	ld   [wPlayMode], a
	jp   ModeSelect_PrepVS
	
; =============== ModeSelect_Prep* ===============
; Sets of functions to set which players are controlled by the CPU, depending on the mode.

ModeSelect_PrepSingle:
	; SGB-only, wJoyActivePl is always PL1 in DMG
	ld   a, [wJoyActivePl]
	cp   PL1		; Does player 1 have control?
	jp   nz, .pl2	; If not, jump
.pl1:
	; P1: Player, P2: CPU
	ld   hl, wPlInfo_Pl1+iPlInfo_Flags0
	res  PF0B_CPU, [hl]
	ld   hl, wPlInfo_Pl2+iPlInfo_Flags0
	set  PF0B_CPU, [hl]
	call ModeSelect_MakeStageSeq
	jp   ModeSelect_SwitchToCharSelect
.pl2:
	; P1: CPU, P2: Player
	ld   hl, wPlInfo_Pl1+iPlInfo_Flags0
	set  PF0B_CPU, [hl]
	ld   hl, wPlInfo_Pl2+iPlInfo_Flags0
	res  PF0B_CPU, [hl]
	call ModeSelect_MakeStageSeq
	jp   ModeSelect_SwitchToCharSelect
	
ModeSelect_PrepVS:
IF ENGLISH == 0
	; P1: Player, P2: Player
	; Removed in the English version since it gets done earlier.
	ld   hl, wPlInfo_Pl1+iPlInfo_Flags0
	res  PF0B_CPU, [hl]
	ld   hl, wPlInfo_Pl2+iPlInfo_Flags0
	res  PF0B_CPU, [hl]
ENDC
	; No stage sequence in 2P mode
	ld   hl, wCharSeqId
	ld   [hl], $00
	jp   ModeSelect_SwitchToCharSelect

IF ENGLISH == 0	
; [TCRF] Unreferenced code.
;        Sets up a CPU vs CPU battle in VS mode, which in the Japanese version can't be triggered
;        by one player.
ModeSelect_Unused_PrepVSCPU:
	; P1: CPU, P2: CPU
	ld   hl, wPlInfo_Pl1+iPlInfo_Flags0
	set  PF0B_CPU, [hl]
	ld   hl, wPlInfo_Pl2+iPlInfo_Flags0
	set  PF0B_CPU, [hl]
	; No stage sequence in 2P mode
	ld   hl, wCharSeqId
	ld   [hl], $00
	; Fall-through
ENDC
	
ModeSelect_SwitchToCharSelect:
	call ModeSelect_CheckCPUvsCPU
	
	; Initialize character select vars
	ld   a, $00
	ld   [wLastWinner], a
	ld   [wUnused_ContinueUsed], a
	ld   a, $00
	ld   [wCharSelP1CursorPos], a
	ld   a, $05
	ld   [wCharSelP2CursorPos], a
	ld   a, $FF
	ld   [wCharSelP1Char0], a
	ld   [wCharSelP1Char1], a
	ld   [wCharSelP1Char2], a
	ld   [wCharSelP2Char0], a
	ld   [wCharSelP2Char1], a
	ld   [wCharSelP2Char2], a
	
	; Force cursor to be visible while waiting
	ld   hl, wOBJInfo_Pl1+iOBJInfo_Status
	set  OSTB_VISIBLE, [hl]
	
	; Wait $3C frames
	ld   b, $3C
.wait:
	call Task_PassControl_NoDelay
	dec  b
	jp   nz, .wait
	
	ld   hl, wMisc_C028
	res  MISCB_TITLE_SECT, [hl]		; Not necessary
	
	di
	;-----------------------------------
	rst  $10				; Stop LCD
	
	; Reset screen coords
	xor  a
	ldh  [rWY], a
	ldh  [rWX], a
	ldh  [rSTAT], a
	
	; These two influence Rand and should be kept in sync across GBs
	ld   [wRand], a		
	ld   [wTimer], a
	
	; Jump to the character select screen
	ld   b, BANK(Module_CharSel) ; BANK $1E
	ld   hl, Module_CharSel
	rst  $00
	
; =============== ModeSelect_DoCtrl ===============
; Checks for player input in the mode select menu.
; OUT
; - C flag: If set, the returned value should be used
; - A: Action id (MODESELECT_ACT_*)
ModeSelect_DoCtrl:
	call Title_GetMenuInput
	bit  KEYB_START, a
	jp   nz, .select
	bit  KEYB_A, a
	jp   nz, .select
	bit  KEYB_SELECT, a
	jp   nz, .exit
	bit  KEYB_DOWN, b
	jp   nz, .moveD
	bit  KEYB_UP, b
	jp   nz, .moveU
	xor  a
	ret
.moveU:
	; Move cursor up, and wrap around
	ld   a, [wTitleSubMenuOptId]
	dec  a
	and  a, $03
	ld   [wTitleSubMenuOptId], a
	jp   .setYPos
.moveD:
	; Move cursor down, and wrap around
	ld   a, [wTitleSubMenuOptId]
	inc  a
	and  a, $03
	ld   [wTitleSubMenuOptId], a
.setYPos:
	; Set the cursor's Y position (Y = wTitleSubMenuOptId * 10) and show it, even if for a single frame
	; See also: SetCursorYPos on Options_DoCtrl
	swap a
	ld   [wOBJInfo_Pl1+iOBJInfo_Y], a
	ld   hl, wOBJInfo_Pl1+iOBJInfo_Status
	set  OSTB_VISIBLE, [hl]
	xor  a
	ret
.select:
	; A = wTitleSubMenuOptId + 1
	; MODESELECT_ACT_* follows the same order as the mode entries (which are identical to MODE_*)
	ld   a, [wTitleSubMenuOptId]
	inc  a
	scf
	ret
.exit:
	; Exit to GM_TITLE_TITLEMENU
	ld   a, MODESELECT_ACT_EXIT
	scf
	ret
	
; =============== Title_Mode_Options ===============
; Options menu.
Title_Mode_Options:
	;
	; Execute different code depending on the selected menu option.
	; Each jump target will handle controls its own way.
	;
	ld   hl, .targetPtrs			; HL = Jump Table	
	ld   d, $00
	ld   a, [wTitleSubMenuOptId]	; DE = wTitleSubMenuOptId * 2
	sla  a
	ld   e, a
	add  hl, de						; Index this table
	ld   e, [hl]					; E = Low byte target
	inc  hl
	ld   d, [hl]					; D = High byte target
	push de
	pop  hl							; Move DE to HL and jump there
	jp   hl
.targetPtrs:
	dw Options_Item_Time
	dw Options_Item_Level
	dw Options_Item_BGMTest
	dw Options_Item_SFXTest
	dw Options_Item_SGBSndTest
	dw Options_Item_Exit
	
; =============== mOptionMin ===============
; A = MIN(Value - 1, MinValue)
; IN
; - 1: Ptr to value
; - 2: Min value
; - 3: Target location on fail
mOptionMin: MACRO
	ld   a, [\1]
	cp   \2			; Value == MinValue?
	jp   z, \3		; If so, skip
	dec  a			; Value--
ENDM

; =============== mOptionMax ===============
; A = MAX(Value + 1, MaxValue)
; IN
; - 1: Ptr to value
; - 2: Min value
; - 3: Target location on fail
mOptionMax: MACRO
	ld   a, [\1]
	cp   \2			; Value == MaxValue?
	jp   z, \3		; If so, skip
	inc  a			; Value++
ENDM
	
; =============== Options_Item_Exit ===============
; EXIT option selected.
Options_Item_Exit:
	call Title_BlinkCursorR
	call Options_DoCtrl
	ret  nc
	cp   OPTIONS_ACT_EXIT		; Exiting the menu?
	jp   z, TitleSubMenu_Exit	; If so, exit
	cp   OPTIONS_ACT_A			; Pressed A on the EXIT option?
	jp   z, TitleSubMenu_Exit	; If so, exit
	ret
	
; =============== Options_Item_Time ===============	
Options_Item_Time:
	call Title_BlinkCursorR
	call Options_DoCtrl			; Check for current action
	ret  nc						; None specified? If so, return
	cp   OPTIONS_ACT_EXIT		; Act == OPTIONS_ACT_EXIT?
	jp   z, TitleSubMenu_Exit	; If so, jump
	cp   OPTIONS_ACT_L			; ...
	jp   z, .decTimer
	cp   OPTIONS_ACT_R
	jp   z, .incTimer
	ret
.decTimer:
	; Decrement the timer unless it reached the low limit.
	ld   a, [wMatchStartTime]
	cp   OPTIONS_TIMER_MIN		; Time == MinValue? 
	jp   z, .save				; If so, don't decrement
	; Special case to jump from the special Infinite value to the normal max
	cp   TIMER_INFINITE			; Time == Infinite?
	jp   nz, .doDec				; If not, jump
	ld   a, OPTIONS_TIMER_MAX					
	jp   .save
.doDec:
	sub  a, OPTIONS_TIMER_INC	; Time -= Interval
	jp   .save
.incTimer:
	; Increment the timer unless it's at the max.
	ld   a, [wMatchStartTime]	
	cp   TIMER_INFINITE			; Time == Infinite? 
	jp   z, .save				; If so, don't increment
	; Special case to jump from the normal max value to Infinite
	cp   OPTIONS_TIMER_MAX		; Time == MaxValue?
	jp   nz, .doInc				; If not, jump
	ld   a, TIMER_INFINITE
	jp   .save
.doInc:
	add  a, OPTIONS_TIMER_INC	; Time += Interval
.save:
	ld   [wMatchStartTime], a	; Save timer setting
	call Options_PrintMatchTime	; Update tilemap
	ret
	
; =============== Options_PrintMatchTime ===============
; Prints the current value of the match timer.
Options_PrintMatchTime:
	ld   a, [wMatchStartTime]
	cp   TIMER_INFINITE				; Infinite time set?
	jp   z, .infinite				; If so, jump
.num:
	ld   de, $98FE					; Otherwise print A as number
	ld   c, $00
	call NumberPrinter_Instant
	ld   hl, TextDef_Options_ClrOff	; Remove "O" from OFF
	call TextPrinter_Instant
	ret
.infinite:
	ld   hl, TextDef_Options_Off	; Print "OFF"
	call TextPrinter_Instant
	ret
	
; =============== Options_Item_Level ===============	
Options_Item_Level:
	call Title_BlinkCursorR
	call Options_DoCtrl
	ret  nc
	cp   OPTIONS_ACT_EXIT
	jp   z, TitleSubMenu_Exit
	cp   OPTIONS_ACT_L
	jp   z, .dec
	cp   OPTIONS_ACT_R
	jp   z, .inc
	ret
.dec:
	mOptionMin wDifficulty, DIFFICULTY_EASY, .save
	jp   .save
.inc:
	mOptionMax wDifficulty, DIFFICULTY_HARD, .save
.save:
	ld   [wDifficulty], a
	call Options_PrintDifficulty
	ret
	
; =============== Options_PrintDifficulty ===============
; Prints the current difficulty setting.
Options_PrintDifficulty:
	ld   a, [wDifficulty]
	cp   DIFFICULTY_EASY
	jp   z, .easy
	cp   DIFFICULTY_NORMAL
	jp   z, .normal
	cp   DIFFICULTY_HARD
	jp   z, .hard
.easy:
	ld   hl, TextDef_Options_Easy
	call TextPrinter_Instant
	ret
.normal:
	ld   hl, TextDef_Options_Normal
	call TextPrinter_Instant
	ret
.hard:
	ld   hl, TextDef_Options_Hard
	call TextPrinter_Instant
	ret
	
; =============== Options_Item_BGMTest ===============	
Options_Item_BGMTest:;I
	call Title_BlinkCursorR
	call Options_DoCtrl
	ret  nc
	cp   OPTIONS_ACT_EXIT
	jp   z, TitleSubMenu_Exit
	cp   OPTIONS_ACT_L
	jp   z, .dec
	cp   OPTIONS_ACT_R
	jp   z, .inc
	cp   OPTIONS_ACT_A
	jp   z, .play
	cp   OPTIONS_ACT_B
	jp   z, .stop
	ret ; We don't get here
.play:
	; Index the real sound ID off the map table
	ld   a, [wOptionsBGMId]			; A = VisualBGMId
	ld   hl, Options_BGMIdMapTbl	; HL = MapTable
	ld   d, $00
	ld   e, a
	add  hl, de						
	ld   a, [hl]					; SoundId = HL[A]
	; Play that
	call HomeCall_Sound_ReqPlayId
	ret
.stop:
	xor  a
	call HomeCall_Sound_ReqPlayId
	ret
.dec:
	mOptionMin wOptionsBGMId, $00, .save
	jp   .save
.inc:
	mOptionMax wOptionsBGMId, Options_BGMIdMapTbl.end-Options_BGMIdMapTbl-1, .save
.save:
	ld   [wOptionsBGMId], a
	call Options_PrintBGMId
	ret	
; =============== Options_BGMIdMapTbl ===============
; Maps the BGM Ids to the sound IDs used by the sound driver.
Options_BGMIdMapTbl: 
	db BGM_IN1996               ; $01
	db BGM_ESAKA                ; $02
	db BGM_BIGSHOT              ; $03
	db BGM_ARASHI               ; $04
	db BGM_GEESE                ; $05
	db BGM_FAIRY                ; $06
	db BGM_TRASHHEAD            ; $07
	db BGM_MRKARATE             ; $08
	db BGM_ROULETTE             ; $09
	db BGM_STAGECLEAR           ; $0A
	db BGM_WIND                 ; $0B
	db BGM_TOTHESKY             ; $0C
	db BGM_PROTECTOR            ; $0D
	db BGM_MRKARATECUTSCENE     ; $0E
	db BGM_RISINGRED            ; $0F
.end:
                                
; =============== Options_PrintBGMId ===============
; Prints the current BGM number.
Options_PrintBGMId:
	ld   a, [wOptionsBGMId]		; A = wOptionsBGMId+1
	inc  a
	ld   de, $997E				; DE = Location
	ld   c, $00					; C = Tile ID base
	call NumberPrinter_Instant
	ret
	
Options_Item_SFXTest:;I
	call Title_BlinkCursorR
	call Options_DoCtrl
	ret  nc
	cp   OPTIONS_ACT_EXIT
	jp   z, TitleSubMenu_Exit
	cp   OPTIONS_ACT_L
	jp   z, .dec
	cp   OPTIONS_ACT_R
	jp   z, .inc
	cp   OPTIONS_ACT_A
	jp   z, .play
	cp   OPTIONS_ACT_B
	jp   z, .stop
	ret ; We don't get here
.play:
	; Index the real sound ID off the map table
	ld   a, [wOptionsSFXId]			; A = VisualSFXId
	ld   hl, Options_SFXIdMapTbl	; HL = MapTable
	ld   d, $00
	ld   e, a
	add  hl, de						
	ld   a, [hl]					; SoundId = HL[A]
	; Play that
	call HomeCall_Sound_ReqPlayId
	ret
.stop:
	xor  a
	call HomeCall_Sound_ReqPlayId
	ret
.dec:
	mOptionMin wOptionsSFXId, $00, .save
	jp   .save
.inc:
	mOptionMax wOptionsSFXId, Options_SFXIdMapTbl.end-Options_SFXIdMapTbl-1, .save
.save:
	ld   [wOptionsSFXId], a
	call Options_PrintSFXId
	ret
; =============== Options_SFXIdMapTbl ===============
; Maps the SFX Ids to the sound IDs used by the sound driver.
Options_SFXIdMapTbl:
	db SFX_CURSORMOVE     ; $01
	db SFX_CHARSELECTED   ; $02
	db SFX_CHARGEMETER    ; $03
	db SFX_SUPERMOVE      ; $04
	db SFX_LIGHT          ; $05
	db SFX_HEAVY          ; $06
	db SFX_BLOCK          ; $07
	db SFX_TAUNT          ; $08
	db SFX_HIT            ; $09
	db SFX_MULTIHIT       ; $0A
	db SFX_GROUNDHIT      ; $0B
	db SFX_DROP           ; $0C
	db SFX_SUPERJUMP      ; $0D
	db SFX_STEP           ; $0E
	db SFX_STEP_HEAVY     ; $0F
	db SFX_GRAB           ; $10
	db SFX_FIREHIT_A      ; $11
	db SFX_FIREHIT_B      ; $12
	db SFX_MOVEJUMP_A     ; $13
	db SFX_PROJ_SM        ; $14
	db SFX_MOVEJUMP_B     ; $15
	db SFX_REFLECT        ; $16
	db SFX_UNUSED_SIREN   ; $17
	db SFX_UNUSED_NULL    ; $18
	db SFX_PSYCTEL        ; $19
	db SFX_GAMEOVER       ; $1A
.end:
 
; =============== Options_PrintSFXId ===============
; Prints the current SFX number.
Options_PrintSFXId:
	ld   a, [wOptionsSFXId]		; A = wOptionsSFXId+1
	inc  a
	ld   de, $99BE
	ld   c, $00
	call NumberPrinter_Instant
	ret
	
; =============== Options_Item_SGBSndTest ===============
Options_Item_SGBSndTest:
	;
	; There are two cursor modes here because selecting this option
	; activates a submenu.
	;
	ld   hl, .modePtrs			; HL = Jump table
	ld   d, $00
	ld   a, [wOptionsMenuMode]	; DE = wOptionsMenuMode
	ld   e, a
	add  hl, de						
	ld   e, [hl]					
	inc  hl
	ld   d, [hl]
	push de
	pop  hl
	jp   hl
  
.modePtrs:
 	dw SGBSndTest_Hover
	dw SGBSndTest_SubMenu
	
; =============== SGBSndTest_Hover =============== 
; When hovering over the main SGB Test option.
SGBSndTest_Hover:
	call Title_BlinkCursorR
	call Options_DoCtrl
	ret  nc
	cp   a, OPTIONS_ACT_EXIT
	jp   z, TitleSubMenu_Exit
	cp   a, OPTIONS_ACT_R
	jp   z, .enterSubMenu
	ret 
	
.enterSubMenu:
	; Start on leftmost option
	ld   a, $00
	ld   [wOptionsSGBSndOptId], a
	; Enter option
	ld   a, OPTION_MENU_SGBTEST
	ld   [wOptionsMenuMode], a
	; Show both cursors
	ld   hl, wOBJInfo_CursorR+iOBJInfo_Status
	set  OSTB_VISIBLE, [hl]
	ld   hl, wOBJInfo_CursorU+iOBJInfo_Status
	set  OSTB_VISIBLE, [hl]
	; Set initial CursorU position for leftmost option
	ld   hl, wOBJInfo_CursorU+iOBJInfo_X
	ld   [hl], $3C
	ld   hl, wOBJInfo_CursorU+iOBJInfo_Y
	ld   [hl], $60
	ret 
	
; =============== SGBSndTest_SubMenu =============== 
; Selecting a digit.
SGBSndTest_SubMenu:
	call Title_BlinkCursorU
	call Options_SGBSndTest_DoCtrl
	ret  nc
	cp   a, OPTIONS_SACT_EXIT
	jp   z, TitleSubMenu_Exit
	cp   a, OPTIONS_SACT_UP
	jp   z, SGBSndTest_Act_DecNum
	cp   a, OPTIONS_SACT_DOWN
	jp   z, SGBSndTest_Act_IncNum
	cp   a, OPTIONS_SACT_A
	jp   z, SGBSndTest_Act_PlaySound
	cp   a, OPTIONS_SACT_B
	jp   z, SGBSndTest_Act_StopSound
	cp   a, OPTIONS_SACT_SUBEXIT
	jp   z, SGBSndTest_Act_Exit
	ret 
	
; =============== SGBSndTest_SubMenu =============== 
; Returns to the main options selection.
SGBSndTest_Act_Exit:
	ld   a, $00						; Reset CursorU pos
	ld   [wOptionsSGBSndOptId], a
	ld   a, OPTION_MENU_NORMAL		; Back to options
	ld   [wOptionsMenuMode], a
	; Hide up cursor
	ld   hl, wOBJInfo_CursorU+iOBJInfo_Status
	res  OSTB_VISIBLE, [hl]
	ret  
	
; =============== SGBSndTest_Act_DecNum =============== 
; Decreases the selected option digit.
SGBSndTest_Act_DecNum:                  
	; Get the address where the number is stored
	ld   a, [wOptionsSGBSndOptId]		; D = OptionId
	ld   d, a
	call SGBSndTest_GetOptPtr			; HL = Option value
	
	ld   a, [hl]						; A = Current digit
	bit  0, d							; Editing the bank number? (OptionId == 1 || OptionId == 3)
	jp   nz, .dec						; If so, always decrease it (allow wraparound)
.isSet:
	cp   a, $00							; Digit == $00?
	jp   z, SGBSndTest_Act_IncNum.end	; If so, skip
.dec:
	dec  a								; Digit--
	ld   [hl], a						; Save it back
	jp   SGBSndTest_Act_IncNum.end
	
; =============== SGBSndTest_Act_DecNum =============== 
; Increases the selected option digit.
SGBSndTest_Act_IncNum:
	; Get the address where the number is stored
	ld   a, [wOptionsSGBSndOptId]	; D = OptionId
	ld   d, a
	call SGBSndTest_GetOptPtr		; HL = Option value
	
	; There are different upper limits for each number.
	; The bit checks work due to how the Option IDs are ordered.
	ld   a, [hl]			; A = Current digit
	bit  0, d				; Editing the bank number? (OptionId == 1 || OptionId == 3)
	jp   nz, .inc			; If so, always increase (allow wraparound)
	bit  1, d				; Is this for Set B? (OptionId == 2 || OptionId == 3)
	jp   nz, .setB			; If so, jump
.setA:
	cp   a, $30				; Set A max sound ID
	jp   z, .end			; A == $30? If so, don't increase it
	jp   .inc
.setB:
	cp   a, $19				; Set B max sound ID
	jp   z, .end			; A == $19? If so, don't increase it
.inc:
	inc  a					; Digit++
	ld   [hl], a			; Save it back
.end:
	call Options_PrintSGBSndTestVals
	ret  
	
; =============== SGBSndTest_Act_PlaySound =============== 
SGBSndTest_Act_PlaySound:
	ld   a, [wOptionsSGBSndOptId]
	bit  1, a							; Set B selected?
	jp   nz, .setB						; If so, jump
.setA:
	; Set the options in the SGB packet.
	ld   hl, wOptionsSGBPacketSndIdA	; HL = Ptr to SGB Sound Packet byte1
	; Set A Sound ID
	ld   a, [wOptionsSGBSndIdA]			; wOptionsSGBPacketSndIdA = wOptionsSGBSndIdA
	ldi  [hl], a						
	; Nothing in Set B
	ld   a, $00							; wOptionsSGBPacketSndIdB = 0
	ldi  [hl], a				
	; Low nybble -> Bank number for Set A
	ld   a, [wOptionsSGBSndBankA]		; wOptionsSGBPacketSndBank = wOptionsSGBSndBankA & $0F
	and  a, $0F							; filter valid values
	ldi  [hl], a
	jp   .sendPkg
.setB:
	ld   hl, wOptionsSGBPacketSndIdA	; HL = Ptr to SGB Sound Packet byte1
	; Nothing in Set A
	ld   a, $80							; wOptionsSGBPacketSndIdA = $80
	ldi  [hl], a
	; Set B Sound ID
	ld   a, [wOptionsSGBSndIdB]			; wOptionsSGBPacketSndIdB = wOptionsSGBSndIdB
	ldi  [hl], a
	; High nybble -> Bank number for Set B
	ld   a, [wOptionsSGBSndBankB]		; wOptionsSGBPacketSndBank = (wOptionsSGBSndBankB & $0F) << 4
	and  a, $0F							; filter valid values
	swap a
	ldi  [hl], a
.sendPkg:
	call Task_PassControl_NoDelay
	ld   hl, wOptionsSGBPacketSnd
	call SGB_SendPackets
	ret  
	
; =============== SGBSndTest_Act_StopSound =============== 
SGBSndTest_Act_StopSound:
	call Task_PassControl_NoDelay
	ld   hl, SGBPacket_Options_StopSnd
	call SGB_SendPackets
	ei   
	ret  
	
; =============== SGBSndTest_GetOptPtr ===============
; HL = wOptionsSGBBase[wOptionsSGBSndOptId]
; OUT
; - HL: Ptr to value of the currently selected option
SGBSndTest_GetOptPtr:
	; The current values for the four SGB options start at wOptionsSGBBase.
	; They are ordered by OPTION_SITEM_*, so getting their address is like indexing a table.
	ld   hl, wOptionsSGBBase		; HL = Starting address
	ld   a, [wOptionsSGBSndOptId]	; BC = SGB Option Id
	ld   b, $00
	ld   c, a
	add  hl, bc						; Index it
	ret
	
; =============== Options_PrintSGBSndTestVals ===============
; Prints the digits displayed in the SGB sound test.
Options_PrintSGBSndTestVals:

	; SGB Mode only
	ld   a, [wMisc_C025]
	bit  MISCB_IS_SGB, a
	jp   z, .ret
	
	; Don't print if the SGB sound test isn't enabled
	ld   a, [wDipSwitch]
	bit  DIPB_SGB_SOUND_TEST, a
	jp   z, .ret
	
	; Print out all of the digits
	ld   a, [wOptionsSGBSndIdA]
	ld   de, $9A56
	ld   c, $00
	call NumberPrinter_Instant
	
	ld   a, [wOptionsSGBSndBankA]
	ld   de, $9A58
	ld   c, $00
	call NumberPrinter_Instant
	
	ld   a, [wOptionsSGBSndIdB]
	ld   de, $9A5C
	ld   c, $00
	call NumberPrinter_Instant
	
	ld   a, [wOptionsSGBSndBankB]
	ld   de, $9A5E
	ld   c, $00
	call NumberPrinter_Instant
	
	; Blank out high digit of banks A & B
	ld   hl, TextDef_Options_ClrSGBSndA
	call TextPrinter_Instant
	ld   hl, TextDef_Options_ClrSGBSndB
	call TextPrinter_Instant
.ret:
	ret 
	
; =============== Options_PrintDipSwitch ===============
; Prints the current dip switch value.
Options_PrintDipSwitch:
	; Don't reveal the feature if no dipswitches are enabled.
	ld   a, [wDipSwitch]
	or   a					; wDipSwitch == 0?
	jp   z, .ret			; If so, return
.ok:
	ld   de, $9ABE
	ld   c, $00
	call NumberPrinter_Instant
.ret:
	ret
	
; =============== Options_DoCtrl ===============
; Checks for player input in the options menu.
; OUT
; - C flag: If set, the returned value should be used
; - A: Action id (OPTIONS_ACT_*), handled by the option-specific code
Options_DoCtrl:
	call Title_GetMenuInput
	bit  KEYB_START, a
	jp   nz, Options_DoCtrl_Exit
	bit  KEYB_SELECT, a
	jp   nz, Options_DoCtrl_Exit
	bit  KEYB_B, a
	jp   nz, Options_DoCtrl_PressB
	bit  KEYB_DOWN, b
	jp   nz, Options_DoCtrl_MoveD
	bit  KEYB_UP, b
	jp   nz, Options_DoCtrl_MoveU
	bit  KEYB_LEFT, b
	jp   nz, Options_DoCtrl_MoveL
	bit  KEYB_RIGHT, b
	jp   nz, Options_DoCtrl_MoveR
	bit  KEYB_A, b
	jp   nz, Options_DoCtrl_PressA
	xor  a
	ret
	
; =============== Options_DoCtrl_Exit ===============
Options_DoCtrl_Exit:
	ld   a, OPTIONS_ACT_EXIT	; Action
	scf							; Enable action
	ret
; =============== Options_DoCtrl_MoveU ===============
Options_DoCtrl_MoveU:
	;
	; Wrap around from OPTION_ITEM_TIME to OPTION_ITEM_EXIT
	;
	ld   a, [wTitleSubMenuOptId]
	or   a							; Are we over the highest option? (OPTION_ITEM_TIME)
	jp   nz, .chkOpen				; If not, jump
	ld   a, OPTION_ITEM_EXIT		; Otherwise, wrap around
	jp   .end
.chkOpen:
	;
	; Skip the SGB sound test option if it's disabled
	;
	ld   hl, wMisc_C025
	bit  MISCB_IS_SGB, [hl]			; Are we in SGB mode?
	jp   z, .noSGBTest				; If not, jump
	ld   hl, wDipSwitch
	bit  DIPB_SGB_SOUND_TEST, [hl]	; Is the SGB sound test enabled?
	jp   nz, .moveUp				; If so, we can always move up
.noSGBTest:
	; If we got here there's no SGB sound test, so skip it
	cp   OPTION_ITEM_EXIT			; Are we over the EXIT option?
	jp   nz, .moveUp				; If not, move up
	ld   a, OPTION_ITEM_SFXTEST		; Otherwise, skip directly to SFX Test
	jp   .end
.moveUp:
	dec  a							; Move selected option up		
.end:
	ld   [wTitleSubMenuOptId], a
	jp   Options_DoCtrl_SetCursorYPos
	
; =============== Options_DoCtrl_MoveD ===============
Options_DoCtrl_MoveD:
	;
	; Wrap around from OPTION_ITEM_EXIT to OPTION_ITEM_TIME
	;
	ld   a, [wTitleSubMenuOptId]
	cp   OPTION_ITEM_EXIT			; Are we over the lowest option?
	jp   nz, .chkOpen				; If not, jump
	ld   a, OPTION_ITEM_TIME		; Otherwise, wrap around
	jp   .end
.chkOpen:
	ld   hl, wMisc_C025
	bit  MISCB_IS_SGB, [hl]			; Are we in SGB mode?
	jp   z, .noSGBTest				; If not, jump
	ld   hl, wDipSwitch
	bit  DIPB_SGB_SOUND_TEST, [hl]	; Is the SGB sound test enabled?
	jp   nz, .moveDown				; If so, we can always move down
.noSGBTest:
	; If we got here there's no SGB sound test, so skip it
	cp   OPTION_ITEM_SFXTEST		; Are we over the SFX Test option?
	jp   nz, .moveDown				; If not, move down
	ld   a, OPTION_ITEM_EXIT		; Otherwise, skip directly to EXIT
	jp   Options_DoCtrl_MoveU.end	; (Does the same thing as the line below)
	jp   .end						; [TCRF] Unreachable duplicate jump
.moveDown:
	inc  a							; Move selected option down
.end:
	ld   [wTitleSubMenuOptId], a
	; Fall-through
; =============== Options_DoCtrl_SetCursorYPos ===============
; Common code for setting the new cursor Y position.
; The X position is never changed in menus.
; IN
; - A: wTitleSubMenuOptId
Options_DoCtrl_SetCursorYPos:
	cp   OPTION_ITEM_EXIT			; Are we now over the EXIT option?
	jp   nz, .otherY				; If not, jump
.exitY:
	ld   a, $68						; Otherwise, Y pos = $68
	jp   .setY
.otherY:
	; ID trickery.
	; The menu options (outside of EXIT) are positioned in a way so that:
	; CursorY = wTitleSubMenuOptId * 4
	swap a
.setY:
	ld   [wOBJInfo_CursorR+iOBJInfo_Y], a		; Set the Y cursor
	ld   hl, wOBJInfo_CursorR+iOBJInfo_Status
	set  OSTB_VISIBLE, [hl]						; Force cursor visibility, at least for 1 frame
	xor  a
	ret
; =============== Options_DoCtrl_MoveL ===============
Options_DoCtrl_MoveL:
	ld   a, OPTIONS_ACT_L
	scf
	ret
; =============== Options_DoCtrl_MoveR ===============
Options_DoCtrl_MoveR:
	ld   a, OPTIONS_ACT_R
	scf
	ret
; =============== Options_DoCtrl_PressA ===============
Options_DoCtrl_PressA:
	ld   a, OPTIONS_ACT_A
	scf
	ret
; =============== Options_DoCtrl_PressB ===============
Options_DoCtrl_PressB:
	ld   a, OPTIONS_ACT_B
	scf
	ret
	
	
; =============== Options_SGBSndTest_DoCtrl ===============	
; Special version of Options_DoCtrl used for the SGB Sound Test.
; This uses an up cursor moving horizontally, so movement is handled differently.
; OUT
; - C flag: If set, the returned value should be used
; - A: Action id (OPTIONS_SACT_*), handled by the option-specific code
Options_SGBSndTest_DoCtrl:
	call Title_GetMenuInput
	bit  KEYB_START, a
	jp   nz, .exit
	bit  KEYB_SELECT, a
	jp   nz, .exit
	bit  KEYB_LEFT, a
	jp   nz, .moveL
	bit  KEYB_RIGHT, a
	jp   nz, .moveR
	bit  KEYB_B, a
	jp   nz, .b
	bit  KEYB_DOWN, b
	jp   nz, .down
	bit  KEYB_UP, b
	jp   nz, .up
	bit  KEYB_A, b
	jp   nz, .a
	xor  a
	ret
.exit:
	ld   a, OPTIONS_SACT_EXIT
	scf  
	ret  
.up:
	ld   a, OPTIONS_SACT_UP
	scf  
	ret  
.down:
	ld   a, OPTIONS_SACT_DOWN
	scf  
	ret  
.a:
	ld   a, OPTIONS_SACT_A
	scf  
	ret  
.b:
	ld   a, OPTIONS_SACT_B
	scf  
	ret  
;--
.moveL:
	; If we're moving left from the leftmost option, signal out the exit from the submenu
	ld   a, [wOptionsSGBSndOptId]
	cp   a, OPTION_SITEM_ID_A		; OptionId == 0?
	jp   z, .leftMin				; If so, jump
	; Otherwise decrement the option
	dec  a				
	and  a, $03						; And force it in range ($00-$03)
	jp   .setCursorXPos
.leftMin:
	ld   a, OPTIONS_SACT_SUBEXIT
	scf  
	ret 
;--
.moveR:
	; If we're moving right from the leftmost option, ignore it
	ld   a, [wOptionsSGBSndOptId]
	cp   a, OPTION_SITEM_BANK_B		; OptionId == $03?
	jp   z, .setCursorXPos			; If so, jump
	; Otherwise increment the option
	inc  a
	and  a, $03						; And force it in range ($00-$03)
	
.setCursorXPos:
	;
	; Determine the up cursor's X position.
	; Unlike Options_DoCtrl, there's no trickery here, it's just a series of id checks.
	;
	ld   [wOptionsSGBSndOptId], a
	cp   a, OPTION_SITEM_BANK_A		; OptionId == $01?
	jp   z, .x1						; If so, jump
	cp   a, OPTION_SITEM_ID_B		; ...
	jp   z, .x2
	cp   a, OPTION_SITEM_BANK_B
	jp   z, .x3
	; Otherwise, OptionId == $00
.x0:
	ld   a, $3C
	jp   .saveX
.x1:
	ld   a, $50
	jp   .saveX
.x2:
	ld   a, $6C
	jp   .saveX
.x3:
	ld   a, $80
.saveX:
	; Show up cursor and set its position
	ld   [wOBJInfo_CursorU+iOBJInfo_X], a
	ld   hl, wOBJInfo_CursorU+iOBJInfo_Status
	set  OSTB_VISIBLE, [hl]
	xor  a
	ret
	
; =============== TitleSubMenu_Exit ===============
; Exits from the mode select or options menu back to the title menu.
TitleSubMenu_Exit:
	
	; Disable serial (Mode Select)
	xor  a
	ldh  [rSB], a
	
	; Stop any playing SGB sound (Options)
	ld   hl, SGBPacket_Options_StopSnd
	call SGB_SendPackets
	
	; Reset DMG pal
	ld   a, $FF
	ldh  [rBGP], a
	ldh  [rOBP0], a
	ldh  [rOBP1], a
	
	; Next mode
	ld   a, GM_TITLE_TITLEMENU
	ld   [wTitleMode], a
	
	; Load GFX
	ld   b, BANK(Title_LoadVRAM_Mini) ; BANK $1C
	ld   hl, Title_LoadVRAM_Mini
	rst  $08
	
	; Enable title screen parallax mode
	ld   hl, wMisc_C028
	set  MISCB_TITLE_SECT, [hl]
	
	; Restore cursor position & visibility
	ld   a, [wTitleMenuCursorXBak]
	ld   [wOBJInfo_CursorR+iOBJInfo_X], a
	ld   a, [wTitleMenuCursorYBak]
	ld   [wOBJInfo_CursorR+iOBJInfo_Y], a
	ld   hl, wOBJInfo_CursorR+iOBJInfo_OBJLstPtrTblOffset
	ld   [hl], TITLE_OBJ_CURSOR_R*OBJLSTPTR_ENTRYSIZE
	ld   hl, wOBJInfo_Pl1+iOBJInfo_Status
	set  OSTB_VISIBLE, [hl]
	
	; Hide vertical cursor
	ld   hl, wOBJInfo_CursorU+iOBJInfo_Status
	res  OSTB_VISIBLE, [hl]
	
	; Show menu text and SNK copyright
	ld   hl, wOBJInfo_MenuText+iOBJInfo_Status
	set  OSTB_VISIBLE, [hl]
	ld   hl, wOBJInfo_SnkText+iOBJInfo_Status
	set  OSTB_VISIBLE, [hl]
	
	; Reset scrolling to make clouds appear already at the final Y pos
	; without having to move them up again
IF ENGLISH == 0
	ld   a, $00
	ld   [wOBJScrollY], a
	ld   a, $90 		; Matches with Y target in Title_UpdateParallaxCoords
	ldh  [hScrollY], a
ELSE
	ld   a, $10
	ld   [wOBJScrollY], a
	ld   a, $A0
	ldh  [hScrollY], a
ENDC
	
	; Enable WINDOW
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_OBJSIZE|LCDC_WENABLE|LCDC_WTILEMAP|LCDC_ENABLE
	rst  $18				; Resume LCD
	;-----------------------------------
	
	; Enable LYC interrupt
	ldh  a, [rSTAT]
	or   a, STAT_LYC
	ldh  [rSTAT], a
IF ENGLISH == 0
	ld   a, $66			; Same as title init code
ELSE
	ld   a, $56
ENDC
	ldh  [rLYC], a
	ldh  a, [rIE]
	or   a, I_STAT|I_VBLANK
	ldh  [rIE], a
	
	; Stop DMG sound
	ld   a, $00
	call HomeCall_Sound_ReqPlayExId_Stub
	
	call Task_PassControl_NoDelay
	
	; Set DMG title pal
	ld   a, $3F
	ldh  [rOBP0], a
	ld   a, $00
	ldh  [rOBP1], a
	ld   a, $1B
	ldh  [rBGP], a
	ret

; =============== TitleScreen_IsStartPressed ===============
; OUT
; - C flag: If set, START was pressed on either controller
TitleScreen_IsStartPressed:
	; Serial is disabled, so hJoyNewKeys2 will only come from the SGB side.
	
	; Whoever presses START on the PUSH START screen takes control of the main menu,
	; while the other player won't be able to do anything.
	
	ldh  a, [hJoyNewKeys]
	bit  KEYB_START, a		; Pressing START on P1 side?
	jp   nz, .pressed1		; If so, jump
	ldh  a, [hJoyNewKeys2]
	bit  KEYB_START, a		; Pressing START on P2 side?	
	jp   nz, .pressed2		; If so, jump
.notPressed:
	xor  a					; C = 0, not pressed
	ret
.pressed1:
	ld   a, PL1				; Player 1 pressed it
	ld   [wJoyActivePl], a
	scf						; C = 1, pressed
	ret
.pressed2:
	ld   a, PL2				; Player 2 pressed it
	ld   [wJoyActivePl], a
	scf						; C = 1, pressed
	ret
	
; =============== ModeSelect_CheckCPUvsCPU ===============
; [POI] Handles the secret where holding B when selecting a mode activates a CPU vs CPU battle.
ModeSelect_CheckCPUvsCPU:

	; CPU opponents disallowed in VS modes if done through serial.
	; It's perfectly fine if done through the SGB though.
	ld   a, [wMisc_C025]
	bit  MISCB_SERIAL_MODE, a		; Setting up a VS battle?
	ret  nz							; If so, return
	
	; Check both controllers
.chkPl1:
	ldh  a, [hJoyKeys]
	bit  KEYB_B, a					; Holding B on controller 1?
	jp   z, .chkPl2					; If not, jump
	ld   hl, wPlInfo_Pl1+iPlInfo_Flags0
	set  PF0B_CPU, [hl]				; Otherwise, set P1 as CPU
.chkPl2:
	ldh  a, [hJoyKeys2]
	bit  KEYB_B, a					; Holding B on controller 2?
	jp   z, .ret					; If not, jump
	ld   hl, wPlInfo_Pl2+iPlInfo_Flags0
	set  PF0B_CPU, [hl]				; Otherwise, set P2 as CPU
.ret:
	ret
	
IF ENGLISH == 1
; =============== ModeSelect_CheckWatchMode ===============
; Initializes the CPU/Human player status for VS mode.
;
; [POI] Also handles the secret where holding LEFT+B enables the CPU vs CPU battle in VS mode / Watch Mode.
;       This allows accessing the mode without having to rely on two players, and most importantly 
;       makes it accessible outside of SGB mode.
;
;       This way of accessing it wasn't in the Japanese version (the code to set the mode was unreferenced),
;       BUT it could still be done in SGB mode by having both players hold B.
;       
;       |||| which rendered unused the various checks for this mode.
;
; TODO: I was wrong as it wasn't unused, remove the TCRF and rename to Watch Mode
;
; OUT
; - C flag: If set, this is a CPU vs CPU battle / Watch mode.
ModeSelect_CheckWatchMode:
	; Default with both human players
	ld   hl, wPlInfo_Pl1+iPlInfo_Flags0
	res  PF0B_CPU, [hl]
	ld   hl, wPlInfo_Pl2+iPlInfo_Flags0
	res  PF0B_CPU, [hl]
	
	; If we're holding LEFT+B, turn both players into a CPU.
	; Since such a mode requires no inputs from the other side, it is allowed even if
	; no DMG is connected.
	; The return value has the purpose of telling whoever's calling this to skip
	; the serial cable checks.
	ldh  a, [hJoyKeys]
	and  KEY_LEFT|KEY_B		; Holding Left+B?
	cp   KEY_LEFT|KEY_B
	jp   nz, .retClear		; If not, jump
	ld   hl, wPlInfo_Pl1+iPlInfo_Flags0
	set  PF0B_CPU, [hl]
	ld   hl, wPlInfo_Pl2+iPlInfo_Flags0
	set  PF0B_CPU, [hl]
.retSet:
	scf  	; C flag set
	ret  
.retClear:
	scf  	; C flag clear
	ccf  
	ret 
ENDC
	
; =============== Title_GetMenuInput ===============
; Gets the player input for the menu screens.
; This merges the key info from the delayed held input fields set in JoyKeys_DoCursorDelayTimer.
; OUT
; - B: Pressed KEY_*
Title_GetMenuInput:
	
	;
	; Pick the controller from the active side
	;
	ld   a, [wJoyActivePl]
	cp   PL1					; Is pad 1 active?
	jp   nz, .usePl2			; If not, jump
.usePl1:
	ld   hl, hJoyKeys			; HL = Controller 1 input
	jp   .getKeys
.usePl2:
	ld   hl, hJoyKeys2			; HL = Controller 2 input

.getKeys:

	;
	; If we're holding any key, force blinking sprites to be visible (in practice, the cursor)
	;
	ld   a, [hl]				; A = Held keys
	or   a						; Holding anything?
	jp   z, .calcKeys			; If not, skip
	xor  a						; Otherwise, reset the blink timer
	ld   [wTitleBlinkTimer], a
	
.calcKeys:
	inc  hl						; Seek to hJoyNewKeys
	ld   a, [hl]				; A = Newly pressed keys
	push af
		inc  hl
		inc  hl					; Seek to hJoyKeysDelayTbl
		
		;
		; Merge back the bits in the 8 iKeyMenuHeld fields into a into a KEY_* bitmask.
		;
		
		; For each DelayTbl entry mark the MSB if needed and rotate left.
		
		ld   b, $00				; B = Output KEY_* mask
		ld   c, $08				; C = Bits in byte
	.loop:
		ldi  a, [hl]			; A = iKeyMenuHeld
		inc  hl					; Skip to next entry
		; Only use key entries with value $01, which means that either:
		; - The key was just pressed
		; - The delay countdown reached 0, which set the key entry to $01
		cp   $01				; iKeyMenuHeld == $01?
		jp   nz, .next			; If not, skip
		set  7, b				; Set the MSB
	.next:
		rlc  b					; Next bit (<<R 1)
		dec  c					; BitsLeft--
		jp   nz, .loop			; Are we done? If not, loop
	pop  af
	ret
	
; =============== TitleScreen_BlinkPushStartText ===============
; Blinks the PUSH START text every $10 frames.
TitleScreen_BlinkPushStartText:
	ld   a, [wTitleBlinkTimer]		; Timer++
	inc  a
	ld   [wTitleBlinkTimer], a
	bit  4, a						; Timer & $10 == 0?
	jp   z, .show					; If so, show it
.hide:								; Otherwise, hide it
	ld   hl, wOBJInfo_MenuText+iOBJInfo_Status
	res  OSTB_VISIBLE, [hl]
	ret
.show:
	ld   hl, wOBJInfo_MenuText+iOBJInfo_Status
	set  OSTB_VISIBLE, [hl]
	ret
; =============== Title_BlinkCursorR ===============
; Blinks the horizontal cursor every $08 frames.
Title_BlinkCursorR:
	ld   a, [wTitleBlinkTimer]		; Timer++
	inc  a
	ld   [wTitleBlinkTimer], a
	bit  3, a						; Timer & $08 == 0?
	jp   z, .show					; If so, show it
.hide:								; Otherwise, hide it
	ld   hl, wOBJInfo_CursorR+iOBJInfo_Status
	res  OSTB_VISIBLE, [hl]
	ret
.show:
	ld   hl, wOBJInfo_CursorR+iOBJInfo_Status
	set  OSTB_VISIBLE, [hl]
	ret
; =============== Title_BlinkCursorU ===============
; Blinks the vertical cursor every $08 frames.
Title_BlinkCursorU:
	ld   a, [wTitleBlinkTimer]		; Timer++
	inc  a
	ld   [wTitleBlinkTimer], a
	bit  3, a						; Timer & $08 == 0?
	jp   z, .show					; If so, show it
.hide:								; Otherwise, hide it
	ld   hl, wOBJInfo_CursorU+iOBJInfo_Status
	res  OSTB_VISIBLE, [hl]
	ret
.show:
	ld   hl, wOBJInfo_CursorU+iOBJInfo_Status
	set  OSTB_VISIBLE, [hl]
	ret
	
; =============== Title_UpdateParallaxCoords ===============
; Updates the positions for the various cloud strips for the parallax effect.
Title_UpdateParallaxCoords:

	;
	; Move clouds up by scrolling the BG down $00.40px/frame until Y $90 is reached.
	;
	ldh  a, [hScrollY]
IF ENGLISH == 0
	cp   $90				; hScrollY == $90?
ELSE
	cp   $A0				; hScrollY == $A0?
ENDC
	jp   z, .scrollX		; If so, skip
	ld   hl, hScrollY		
	ld   bc, $0040			; hScrollY += $00.40
	call .addToPos	
	
.scrollX:

	;
	; Scroll the clouds horizontally.
	; The higher the section number, the faster it will scroll.
	;
	ld   hl, hScrollX
	ld   bc, $0040
	call .addToPos
	ld   hl, hTitleParallax1X
	ld   bc, $0060
	call .addToPos
	ld   hl, hTitleParallax2X
	ld   bc, $0080
	call .addToPos
	ld   hl, hTitleParallax3X
	ld   bc, $00A0
	call .addToPos
	ld   hl, hTitleParallax4X
	ld   bc, $00C0
	call .addToPos
	ld   hl, hTitleParallax5X
	ld   bc, $00E0
	call .addToPos
	ret

; IN
; - HL: Ptr to pixel position
; - BC: Amount to add
.addToPos:
	; HL += BC + *wTitleParallaxBaseSpeed
	push hl
		; HL += BC
		call Title_AddWithSubpixels
		
		; HL += wTitleParallaxBaseSpeed
		ld   hl, wTitleParallaxBaseSpeed
		ld   b, [hl]		; Pixel count
		inc  hl
		ld   c, [hl]		; Subpixel count
	pop  hl
	call Title_AddWithSubpixels
	ret
	
; =============== Title_AddWithSubpixels ===============
; Adds the specified number of pixels to a coordinate.
; This requires the coordinate pointed by HL to be 2 bytes large:
; - 0 -> Pixel value
; - 2 -> Subpixel value
; IN
; - HL: Ptr to pixel position
; - B: Pixels to add
; - C: Subpixels to add
Title_AddWithSubpixels:
	push hl ; Save coord ptr
		; HL = Coordinate
		ld   d, [hl]	; D = Pixels
		inc  hl
		ld   e, [hl]	; E = Subpixels
		push de			;
		pop  hl			; Move to HL
		
		; DE = HL + BC
		add  hl, bc		
		push hl
		pop  de
	pop  hl ; Restore coord ptr
	
	; Write back updated coord
	ld  [hl], d		; Write pixels
	inc  hl
	ld   [hl], e	; Write subpixels
	ret
	
; =============== ModeSelect_MakeStageSeq ===============
; Generates the sequence of opponents to fight in 1P modes.
ModeSelect_MakeStageSeq:
	; Reset starting stage
	ld   hl, wCharSeqId
	ld   [hl], $00
	
	;
	; Fill the sequence with $FF values.
	;
	ld   b, $12				; B = Total number of opponents
	ld   hl, wCharSeqTbl	; HL = Ptr to start of table
	ld   a, $FF				; A = Overwrite with
.fillLoop:
	ldi  [hl], a			
	dec  b
	jr   nz, .fillLoop
	
	;
	; Randomize the first 14 opponents (all of the normal ones).
	; This *does* mean you will always fight both normal and boss Chizuru.
	;
	
	; This is done by going through character *select* portrait IDs from highest allowed to lowest,
	; and placing that character in a randomly generated slot in wCharSeqTbl.
	ld   b, $0E				; B = Current CHARSEL_ID_* / Remaining chars
.getRand:
	call RandLY				; A = Random opponent slot
	and  a, $0F				; Filter valid IDs only
	cp   $0F				; Did we get Kagura's slot? (15th character in the sequence)
	jr   z, .getRand		; If so, reroll again
	
	; HL = Ptr to generated slot
	ld   d, $00				; DE = Current index
	ld   e, a
	ld   hl, wCharSeqTbl	; HL = wCharSeqTbl
	add  hl, de				; Index it
	
	; Avoid overwriting already filled slots, which don't have the $FF placeholder anymore
	ld   a, [hl]			; A = SlotVal
	cp   $FF				; SlotVal != $FF?
	jr   nz, .getRand		; If so, reroll
	
	; Replace Mr Karate ($0E) with Leona ($11)
	; The CHARSEL_ID_* values are in the same order as the character select screen from left to right, top to bottom.
	; Leona is the only character after the hidden ones, as the last one in the lower right corner.
	ld   a, b					; B = CHARSEL_ID_* value
	cp   CHARSEL_ID_MRKARATE0	; B == $0E?
	jr   nz, .setCharId			; If so, skip
	ld   a, CHARSEL_ID_LEONA
.setCharId:
	ld   [hl], a			; Write value
	dec  b					; CharsLeft--
	ld   a, b				
	cp   $FF				; CharsLeft < 0?
	jp   nz, .getRand		; If not, generate the next one
	
	;
	; Add the 2 bosses and the secret at the end.
	; These are raw character IDs as they don't go through the char select screen.
	;
	ld   hl, wCharSeqTbl+$0F
	ld   [hl], CHAR_ID_KAGURA/2 ; STAGESEQ_KAGURA
	inc  hl
	ld   [hl], CHAR_ID_GOENITZ/2 ; STAGESEQ_GOENITZ
	inc  hl
	ld   [hl], $00 ; Placeholder for STAGESEQ_BONUS, value not used
	inc  hl
	ld   [hl], CHAR_ID_MRKARATE/2 ; STAGESEQ_MRKARATE
	ret
	
OBJInfoInit_Title:
	db OST_VISIBLE
	db $00 ; iOBJInfo_OBJLstFlags
	db $00 ; iOBJInfo_OBJLstFlagsView
	db $28 ; iOBJInfo_X
	db $00 ; iOBJInfo_XSub
	db $40 ; iOBJInfo_Y
	db $00 ; iOBJInfo_YSub
	db $00 ; iOBJInfo_SpeedX
	db $00 ; iOBJInfo_SpeedXSub
	db $00 ; iOBJInfo_SpeedY
	db $00 ; iOBJInfo_SpeedYSub
	db $00 ; iOBJInfo_RelX (auto)
	db $00 ; iOBJInfo_RelY (auto)
	db $00 ; iOBJInfo_TileIDBase
	db LOW($8000) ; iOBJInfo_VRAMPtr_Low
	db HIGH($8000) ; iOBJInfo_VRAMPtr_High
	db BANK(OBJLstPtrTable_Title)
	db LOW(OBJLstPtrTable_Title)
	db HIGH(OBJLstPtrTable_Title)
	db TITLE_OBJ_PUSHSTART*OBJLSTPTR_ENTRYSIZE ; iOBJInfo_OBJLstPtrTblOffset
	db $00 ; iOBJInfo_BankNumView
	db LOW(OBJLstPtrTable_Title) ; iOBJInfo_OBJLstPtrTbl_LowView
	db HIGH(OBJLstPtrTable_Title) ; iOBJInfo_OBJLstPtrTbl_HighView
	db $00 ; iOBJInfo_OBJLstPtrTblOffset
	db $00 ; iOBJInfo_ColiBoxId (auto)
	db $00 ; iOBJInfo_HitboxId (auto)
	db $00 ; iOBJInfo_ForceHitboxId
	db $00 ; iOBJInfo_FrameLeft
	db $00 ; iOBJInfo_FrameTotal
	db LOW(wGFXBufInfo_Pl1) ; iOBJInfo_BufInfoPtr_Low
	db HIGH(wGFXBufInfo_Pl1) ; iOBJInfo_BufInfoPtr_High

INCLUDE "data/objlst/title.asm"

TextDef_Menu_Title:
	dw $98C4
	db $0B
	db "GAME SELECT"
TextDef_Menu_SinglePlay:
	dw $9924
	db $0B
	db "SINGLE PLAY"
TextDef_Menu_TeamPlay:
	dw $9964
	db $09
	db "TEAM PLAY"
TextDef_Menu_SingleVS: 
	dw $99A4
	db $09
	db "SINGLE VS"
TextDef_Menu_TeamVS:
	dw $99E4
	db $07
	db "TEAM VS"
TextDef_Options_Title:
	dw $98B7
	db $06
	db "OPTION"
TextDef_Options_Time:
	dw $98F4
	db $0C
	db "TIME      XX"
TextDef_Options_Level:
	dw $9934
	db $0C
	db "LEVEL NORMAL"
TextDef_Options_BGMTest:
	dw $9974
	db $0C
	db "BGM TEST  XX"
TextDef_Options_SFXTest:
	dw $99B4
	db $0C
	db "S.E.TEST  XX"
TextDef_Options_SGBSndTest:
	dw $99F4
	db $0C
	db "SGB S.E.TEST"
TextDef_Options_Exit:
	dw $9A94
	db $04
	db "EXIT"
TextDef_Options_Dip:
	dw $9AB8
	db $08
	db "DIPSW-00"
TextDef_Options_Off:
	dw $98FD
	db $03
	db "OFF"
; Removes the O from OFF when printing a number
TextDef_Options_ClrOff:
	dw $98FD
	db $01
	db " "
TextDef_Options_Easy:
	dw $993A
	db $06
	db "  EASY"
TextDef_Options_Normal:
	dw $993A
	db $06
	db "NORMAL"
TextDef_Options_Hard:
	dw $993A
	db $06
	db "  HARD"
TextDef_Options_SGBSndTypes:
	dw $9A36
	db $0A
	db "SE-A  SE-B"
TextDef_Options_SGBSndPlaceholders: 
	dw $9A56
	db $0A
	db "XX X  XX X"
; NumberPrinter_Instant always prints two digits.
; These spaces are used to cover the upper digit for the SGB sound test.
TextDef_Options_ClrSGBSndA:
	dw $9A58
	db $01
	db " "
TextDef_Options_ClrSGBSndB:
	dw $9A5E
	db $01
	db " "
	
; =============== SGBPacket_Options_PlaySnd ===============
; Used to play a SGB sound in the SGB Sound Test.
; This is copied to RAM to allow updating the bytes marking the Sound IDs to play.

SGBPacketDef_Options_PlaySnd: 
	db SGBPacket_Options_PlaySnd.end-SGBPacket_Options_PlaySnd ; Copy $10 bytes
SGBPacket_Options_PlaySnd:
	pkg SGB_PACKET_SOUND, $01
	db $00 ; wOptionsSGBPacketSndIdAA
	db $00 ; wOptionsSGBPacketSndIdAB
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
.end:

; =============== SGBPacket_Options_StopSnd ===============
; Used to stop any SGB Sound currently playing.
SGBPacket_Options_StopSnd:
	pkg SGB_PACKET_SOUND, $01
	db $80 ; Stop A
	db $80 ; Stop B
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00

; =============== Title_DisableSerial ===============
Title_DisableSerial:
	xor  a
	ldh  [rSB], a
	ld   [wSerialDataReceiveBuffer], a
	ld   [wSerialPlayerId], a
	ld   [wSerialTransferDone], a
	ld   [wSerialDataSendBuffer], a
	ret
	
; =============== ModeSelect_SetSerialIdle ===============
; Marks that the GB is ready to listen to the other player.
ModeSelect_SetSerialIdle:
	; Prepare default the serial settings with what we're replying to 
	; if the other GB sends something through serial.
	ld   a, MODESELECT_SBCMD_IDLE			; Set idle flag
	ldh  [rSB], a							; It will be checked by the other GB in ModeSelect_TrySendVSData
	ld   a, START_TRANSFER_EXTERNAL_CLOCK	; Autoreply MODESELECT_SBCMD_IDLE when the other GB sends something
	ldh  [rSC], a
	ret
	
; =============== ModeSelect_Serial_SendAndWait ===============
; Sends a byte through the serial cable, and waits a reply from the other GB.
; This marks us as master, overwriting what was set in ModeSelect_SetSerialIdle.
; IN
; - A: Byte to send (MODESELECT_SBCMD_*)
ModeSelect_Serial_SendAndWait:
	ldh  [rSB], a
	ld   a, START_TRANSFER_INTERNAL_CLOCK	; Start master transfer
	ldh  [rSC], a
	
	
; =============== ModeSelect_Serial_Wait ===============
; Waits for a byte to be fully received.
ModeSelect_Serial_Wait:
	ld   a, [wSerialTransferDone]
	and  a							; Are we done?
	jr   z, ModeSelect_Serial_Wait	; If not, wait
	xor  a							; Reset marker before exit
	ld   [wSerialTransferDone], a
	ret
	
; =============== ModeSelect_TrySendVSData ===============
; Attempts to send the additional data to sync up both players.
; OUT
; - A: Value received from the slave
ModeSelect_TrySendVSData:
	; [Master 1/3 Recv] If the slave didn't isn't ready (see: not at the Mode Select menu), return
	ld   a, [wSerialDataReceiveBuffer]
	cp   MODESELECT_SBCMD_IDLE			; RecByte == MODESELECT_SBCMD_IDLE?
	jr   z, .send						; If so, jump
	ret
.send: 
	; Save the received byte for later in wSerialPlayerId.
	; This also has the effect of always writing SERIAL_PL1_ID, marking the current
	; player as being 1P / using hJoyKeys for the serial input handler.
	;
	; This works because only the master can ever write MODESELECT_SBCMD_IDLE here (which has the same value as SERIAL_PL1_ID),
	; while the slave can only write in ModeSelect_GetCtrlFromSerial the command IDs we send
	; (MODESELECT_SBCMD_TEAMVS or MODESELECT_SBCMD_SINGLEVS).
	ld   [wSerialPlayerId], a 		; Save received byte
	
	; Set ourselves as master
	ld   hl, wMisc_C025
	set  MISCB_SERIAL_MODE, [hl]
	res  MISCB_SERIAL_SLAVE, [hl]
	
	; Wait for a bit.
	; This also disables wSerialTransferDone on VBlank.
	call Task_PassControl_NoDelay
	call Task_PassControl_NoDelay
	call Task_PassControl_NoDelay
	
	; [Master 2/3] Send out the timer setting and wait some more
	ld   a, [wMatchStartTime]
	call ModeSelect_Serial_SendAndWait
	; Wait for a bit and reset wSerialTransferDone
	call Task_PassControl_NoDelay
	call Task_PassControl_NoDelay
	call Task_PassControl_NoDelay
	
	; [Master 3/3] Send out the dip settings (unlocked chars, etc...)
	ld   a, [wDipSwitch]
	call ModeSelect_Serial_SendAndWait
	
	ld   a, [wSerialPlayerId]		; Restore received byte
	ret  
	
; =============== ModeSelect_GetCtrlFromSerial ===============
; Listens to the serial port to check if the other player selected a VS mode.
; If so, it syncs up the options.
; OUT
; - A: Action id (MODESELECT_SBCMD_*) received by master, if it's there
ModeSelect_GetCtrlFromSerial:
	; If we were sent a VS Mode option ID, also listen to the next two settings bytes.
	ld   a, [wSerialDataReceiveBuffer] ; A = Value from master
	cp   MODESELECT_SBCMD_TEAMVS			
	jr   z, .receiveVSData
	cp   MODESELECT_SBCMD_SINGLEVS
	jr   z, .receiveVSData
	; Otherwise, nothing happened.
	ret
.receiveVSData:
	; Save the MODESELECT_ACT_* value we were sent here.
	; This also has the effect of marking the current player as being 2P / using hJoyKeys2.
	; See also: ModeSelect_TrySendVSData.
	ld   [wSerialPlayerId], a
	
	; Set ourselves as slave, since we're on the receiving end.
	ld   hl, wMisc_C025
	set  MISCB_SERIAL_MODE, [hl]
	set  MISCB_SERIAL_SLAVE, [hl]
	
	; [Slave 2/3] Wait for the other GB to send wMatchStartTime
	xor  a
	ld   [wSerialTransferDone], a
	call ModeSelect_Serial_Wait
	ld   a, [wSerialDataReceiveBuffer]
	ld   [wMatchStartTime], a
	
	; [Slave 3/3] Wait for the other GB to send wDipSwitch
	xor  a
	ld   [wSerialTransferDone], a
	call ModeSelect_Serial_Wait
	ld   a, [wSerialDataReceiveBuffer]
	ld   [wDipSwitch], a
	
	; Return the action ID
	ld   a, [wSerialPlayerId]		; Restore MODESELECT_ACT_* value
	ret  

IF ENGLISH == 0

; Got moved below in the English version for whatever reason.

; =============== Title_LoadVRAM ===============
; Loads tilemaps and GFX for the title screen.
; The menus load the 1bpp text over this, and reuse the cursor already loaded here.
Title_LoadVRAM:
	; Title screen & menu sprites
	ld   hl, GFXAuto_TitleOBJ 
	ld   de, Tiles_Begin		
	call CopyTilesAutoNum
	
	; wLZSS_Buffer offset by $10 since a SGB packet got copied at the start of the buffer.
	
	; KOF96 Title logo tilemap
	ld   hl, BGLZ_Title_Logo
	ld   de, wLZSS_Buffer+$10
	call DecompressLZSS
	ld   de, wLZSS_Buffer+$10
	ld   hl, WINDOWMap_Begin
	ld   b, $14
	ld   c, $0F
	call CopyBGToRect
	
	; Title screen logo GFX (2 parts)
	ld   hl, GFXLZ_Title_Logo1
	ld   de, wLZSS_Buffer+$10
	call DecompressLZSS
	ld   hl, wLZSS_Buffer+$10
	ld   de, $8800				; Block 2
	ld   b, $80
	call CopyTiles
	
	ld   hl, GFXLZ_Title_Logo0
	ld   de, wLZSS_Buffer+$10
	call DecompressLZSS
	ld   hl, wLZSS_Buffer+$10
	ld   de, $9000				; Block 3
	ld   b, $80
	call CopyTiles
	
	; Tilemap in BG layer for cloud parallax, repeated to fill the tilemap's width
I = 0
REPT 8
	ld   de, BG_Title_Clouds
	ld   hl, BGMap_Begin+($04*I)
	ld   b, $04	; 4 tiles width * 8 = $20 (tilemap length)
	ld   c, $03 ; 3 tiles tall
	call CopyBGToRect
I = I + 1
ENDR
	ret
	
; =============== Title_LoadVRAM_Mini ===============
; Loads the title screen GFX which were overwritten by the 1bpp font.
Title_LoadVRAM_Mini:
	; Title screen logo GFX (2nd part, at $9000)
	
	; This takes advantage that GFXLZ_Title_Logo0 was the last LZSS data to be decompressed.
	; As a result, the decompressed copy is still stored in the buffer.

	ld   hl, wLZSS_Buffer+$10	; HL = Source
	ld   de, $9000				; DE = Destination
	ld   b, $80					; B = Tiles to copy
	call CopyTilesHBlank
	ret
	
IF ENGLISH == 0
GFXLZ_Title_Logo0: INCBIN "data/gfx/jp/title_logo0.lzc"
GFXLZ_Title_Logo1: INCBIN "data/gfx/jp/title_logo1.lzc"
BGLZ_Title_Logo: INCBIN "data/bg/jp/title_logo.lzs"
BG_Title_Clouds: INCBIN "data/bg/jp/title_clouds.bin"
ELSE
GFXLZ_Title_Logo0: INCBIN "data/gfx/en/title_logo0.lzc"
GFXLZ_Title_Logo1: INCBIN "data/gfx/en/title_logo1.lzc"
BGLZ_Title_Logo: INCBIN "data/bg/en/title_logo.lzs"
BG_Title_Clouds: INCBIN "data/bg/en/title_clouds.bin"
ENDC


GFXAuto_TitleOBJ:
	db (GFXAuto_TitleOBJ.end-GFXAuto_TitleOBJ.start)/TILESIZE ; Number of tiles
.start:
	INCBIN "data/gfx/title_obj.bin"
.end:

ENDC

; 
; =============== END OF MODULE Title ===============
;



; 
; =============== START OF MODULE Intro ===============
;
; =============== Module_Intro ===============
; EntryPoint for Intro. Called by rst $00 jump from Module_TakaraLogo.
Module_Intro:
	ld   sp, $DD00
	di
	;-----------------------------------
	rst  $10				; Stop LCD
	
	ld   hl, wMisc_C028
	res  MISCB_PL_RANGE_CHECK, [hl]
	
	; Reset DMG Pal & vars
	xor  a
	ldh  [rBGP], a
	ldh  [rOBP0], a
	ldh  [rOBP1], a
	ld   [wIntroScene], a
	
	; Don't execute special code
	ld   a, TXB_NONE
	ld   [wTextPrintFrameCodeBank], a
	
	ld   de, SCRPAL_INTRO
	call HomeCall_SGB_ApplyScreenPalSet
	
	; Reset screen & coords
	call ClearBGMap
	call ClearWINDOWMap
	
	xor  a
	ldh  [hScrollX], a
	ldh  [hScrollY], a
	ld   [wOBJScrollX], a
	ld   [wOBJScrollY], a
	
	call LoadGFX_1bppFont_Default
	call ClearOBJInfo
	
	; Hide WINDOW
	ld   a, $90
	ldh  [rWY], a
	ld   a, $07
	ldh  [rWX], a
	
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_OBJSIZE|LCDC_WENABLE|LCDC_WTILEMAP|LCDC_ENABLE
	rst  $18				; Resume LCD
	;-----------------------------------
	ei
	
	; Wait $3C frames
	ld   b, $3C
.wait0:
	call Task_PassControl_NoDelay
	dec  b
	jp   nz, .wait0
	
	
	ld   a, $3F			; [POI] Overwritten
	
	; Set DMG pal
	ld   a, $18
	ldh  [rOBP0], a
	ld   a, $00
	ldh  [rOBP1], a
	ld   a, $1B
	ldh  [rBGP], a
	
.mainLoop:
	;
	; Main loop of the intro.
	; Each intro scene is its own submodule which take over control.
	; Only when they are done, they return to this loop.
	;
	
	;--
	; [POI] This is practically impossible to trigger here.
	call Intro_Base_IsStartPressed	; Did we abort prematurely?
	jp   c, Intro_End				; If so, end the intro.
	;--
	
	; Execute the scene
	ld   a, [wIntroScene]
	ld   hl, Intro_ScenePtrTable
	call Intro_ExecScene
	; If that was the last scene or we ended prematurely (C flag set), end the intro
	jp   c, Intro_End
	call Task_PassControl_NoDelay
	jp   .mainLoop
	
; =============== Intro_ExecScene ===============
; DynJump using the specified jump table and offset.
; Used for jumping to init code of a specific scene or subscene.
; IN
; - A: Scene or subscene "ID" (offset to ptr table)
; - HL: Ptr to Scene Ptr Table
Intro_ExecScene:
	ld   d, $00		; DE = A
	ld   e, a
	add  hl, de		; Offset it
	ld   e, [hl]	; Read out ptr to DE
	inc  hl
	ld   d, [hl]
	push de			; Move it to HL and jump there
	pop  hl
	jp   hl
; =============== Intro_End ===============	
; Switches to the title screen mode.
Intro_End:
	; Blank palette
	ld   a, $FF
	ldh  [rBGP], a
	ldh  [rOBP0], a
	ldh  [rOBP1], a
	
	; Disable LYC
	xor  a
	ldh  [rSTAT], a
	
	ld   [wGFXBufInfo_Pl1+iGFXBufInfo_TilesLeftA], a
	ld   [wGFXBufInfo_Pl1+iGFXBufInfo_TilesLeftB], a
	ld   [wGFXBufInfo_Pl2+iGFXBufInfo_TilesLeftA], a
	ld   [wGFXBufInfo_Pl2+iGFXBufInfo_TilesLeftB], a
	
	; Jump to title screen
	ld   b, BANK(Module_Title)
	ld   hl, Module_Title
	rst  $00
	
Intro_ScenePtrTable:
	dw IntroScene_TextPrint ; Text print
	dw IntroScene_Chars ; Char sprites animating (including the scene after Iori rises)
	dw IntroScene_IoriRise ; Iori rising
	dw IntroScene_IoriKyo ; Iori / Kyo scene
	
; =============== IntroScene_TextPrint ===============
; Prints the intro text to the screen.
; OUT
; - C flag: If set, end the intro prematurely
IntroScene_TextPrint:
	ld   hl, IntroTextPtrTable
	ld   b, [hl]			; B = Number of string/TextDef pointers
	inc  hl					
.loop:
	push bc
		push hl
			
			; HL = Ptr to TextDef structure
			ld   e, [hl]		
			inc  hl
			ld   d, [hl]
			push de
			pop  hl
			
			; Print the string from the intro
			ld   b, BANK(IntroTextPtrTable) ; Bank with strings
			ld   c, $04 ; 4 frame delay between letters
			ld   a, TXT_PLAYSFX|TXT_ALLOWSKIP 	; Flags
			call TextPrinter_MultiFrameFar		; Do it
			jr   c, .abort						; Did we abort the printing? If so, jump
			
			; Wait $14 frames before clearing the screen, while that happens
			; still listen to abort requests
			ld   a, $14
			call Intro_ChkStartPressed_MultiFrame
			call ClearBGMap
		pop  hl
		inc  hl		; Next TextDef ptr
		inc  hl
	pop  bc
	dec  b				; Processed all strings?
	jr   nz, .loop		; If not, loop
.done:
	; Wait $3C frames on the black screen
	ld   a, $3C
	call Intro_ChkStartPressed_MultiFrame
	
	; Prepare next scene
	ld   a, BGM_IN1996
	call HomeCall_Sound_ReqPlayExId_Stub
	call Intro_CharS_LoadVRAM
	ld   a, GM_INTRO_CHAR
	ld   [wIntroScene], a
	ret
.abort:
	; Set C flag to end the intro
	pop  hl
	pop  bc
	scf
	ret

; =============== IntroScene_Chars ===============
; Animates character sprites while moving rectangles across the screen.
; OUT
; - C flag: If set, end the intro prematurely
IntroScene_Chars:
	; Use wIntroCharScene as offset to the jump table Intro_CharScene_PtrTable.
	; There are also a few special cases for exiting to different intro scenes.
	
	ld   a, [wIntroCharScene]
	cp   INTRO_SCENE_CHG_IORIRISE	; SceneId == $1C?
	jr   z, .startIoriRise	; If so, jump
	cp   INTRO_SCENE_CHG_IORIKYO	; SceneId == $26?
	jr   z, .startIoriKyo	; If so, jump
.dynJump:
	ld   hl, Intro_CharScene_PtrTable
	call Intro_ExecScene
	jr   IntroScene_Chars	; Handle next
	
.startIoriRise:
	; Prepare VRAM and exit
	; (we disabled player sprites at the end of Intro_CharScene_Mature)
	call Intro_IoriRise_LoadVRAM
	ld   a, GM_INTRO_IORIRISE
	ld   [wIntroScene], a
	xor  a
	ret
	
.startIoriKyo:
	; Disable player sprites, they aren't needed anymore
	ld   hl, wOBJInfo_Pl1+iOBJInfo_Status
	res  OSTB_VISIBLE, [hl]
	ld   hl, wOBJInfo_Pl2+iOBJInfo_Status
	res  OSTB_VISIBLE, [hl]
	; Prepare VRAM and exit
	call Intro_IoriKyo_LoadVRAM
	ld   a, GM_INTRO_IORIKYO		
	ld   [wIntroScene], a
	xor  a
	ret
	
Intro_CharScene_PtrTable:
	dw Intro_CharScene_Init
	dw Intro_CharScene_Terry
	dw Intro_CharScene_Andy
	dw Intro_CharScene_Mai
	dw Intro_CharScene_Athena
	dw Intro_CharScene_Leona
	dw Intro_CharScene_Robert
	dw Intro_CharScene_Ryo
	dw Intro_CharScene_MrKarate
	dw Intro_CharScene_MrBig
	dw Intro_CharScene_Geese
	dw Intro_CharScene_Krauser
	dw Intro_CharScene_Daimon
	dw Intro_CharScene_Mature
	dw $0000 ; N/A
	dw Intro_CharScene_Kyo
	dw Intro_CharScene_IoriKyoA
	dw Intro_CharScene_IoriKyoB
	dw Intro_CharScene_IoriKyoC
	
; =============== Intro_CharScene_Init ===============
; Init code for the Terry scene.
Intro_CharScene_Init:
	ld   a, $FF				; Clear BG Palette
	ldh  [rBGP], a
	
	;
	; The way the intro backgrounds work is a combination of moving the screen
	; (while keeping the sprites at the same positions) and updating the tilemap
	; when shrinking the white cut-in.
	;

	; Fill the screen with a black tile that hides sprites
	ld   d, TILE_INTRO_BLACK				
	call ClearBGMapCustom

	; Draw a full (visible) screen white rectangle off-screen where sprites inside are visible.
	; This will be later moved upwards by scrolling the screen down.
	ld   hl, $9A40 ; Left corner pos
	ld   b, $14 ; Rect Width
	ld   c, $06 ; Rect Height
	ld   d, TILE_INTRO_WHITE ; Tile ID
	call FillBGRect
	
	; Set Terry sprite pos
	ld   a, $20
	ld   [wOBJInfo_Pl1+iOBJInfo_X], a
	ld   a, $00
	ld   [wOBJInfo_Pl1+iOBJInfo_Y], a
	
	; Set Andy sprite pos
	ld   a, $80
	ld   [wOBJInfo_Pl2+iOBJInfo_X], a
	ld   a, $40
	ld   [wOBJInfo_Pl2+iOBJInfo_Y], a
	
	; Screen in top left corner
	xor  a
	ldh  [hScrollX], a
	ldh  [hScrollY], a
	
	; Next scene
	ld   a, [wIntroCharScene]
	add  a, $02
	ld   [wIntroCharScene], a
	
	ld   a, $01
	call Intro_ChkStartPressed_MultiFrame
	
	; Enable Terry sprite
	ld   hl, wOBJInfo_Pl1+iOBJInfo_Status
	set  OSTB_VISIBLE, [hl]
	
	ld   a, $F0				; Set actual BG Palette
	ldh  [rBGP], a
	ret
	
; =============== Intro_CharScene_Terry ===============
; Terry scene.
Intro_CharScene_Terry:
	; Move white bar up $10*$10 px
	ld   a, $10
	call Intro_CharS_MoveBGUp_MultiFrame
	
	; Show Andy
	ld   hl, wOBJInfo_Pl2+iOBJInfo_Status
	set  OSTB_VISIBLE, [hl]
	
	; Wait $0F frames animating chars
	ld   a, $0F
	call Intro_CharS_WaitVBlank
	
	jp   Intro_CharS_NextMode
	
; =============== Intro_CharScene_Andy ===============
; Andy scene.
Intro_CharScene_Andy:

	; Move white bar down $0B*$0B px
	ld   a, $0B
	call Intro_CharS_MoveBGDown_MultiFrame
	
	; Shrink left side $0D tiles
	ld   a, $0D ; Black out $0D columns
	ld   b, $01 ; Width
	ld   c, $06 ; Height
	ld   d, TILE_INTRO_BLACK ; Tile ID
	ld   hl, $9A40 ; Origin
	call Intro_CharS_FillBGRectRight_MultiFrame
	
	; Shrink right side $02 tiles
	ld   a, $02
	ld   b, $01
	ld   c, $06
	ld   d, TILE_INTRO_BLACK
	ld   hl, $9A53
	call Intro_CharS_FillBGRectLeft_MultiFrame
	
	; Grow bottom side
	ld   a, $03
	ld   b, $05
	ld   c, $01
	ld   d, TILE_INTRO_WHITE
	ld   hl, $9B0D
	call Intro_CharS_FillBGRectDown_MultiFrame
	
	; Grow top side
	ld   a, $0B
	ld   b, $05
	ld   c, $01
	ld   d, TILE_INTRO_WHITE
	ld   hl, $9A4D
	call Intro_CharS_FillBGRectUp_MultiFrame
	
	; Wait $0F frames
	ld   a, $0F
	call Intro_CharS_WaitVBlank
	
	; Next scene
	call Intro_CharS_SetNextChar
	jp   Intro_CharS_NextMode
	
; =============== Intro_CharScene_Mai ===============
; Mai scene.
Intro_CharScene_Mai:
	; Move white section to the middle
	ld   a, $09
	call Intro_CharS_MoveBGLeft_MultiFrame
	
	ld   a, $0F
	call Intro_CharS_WaitVBlank
	
	call Intro_CharS_SetNextChar
	jp   Intro_CharS_NextMode
	
; =============== Intro_CharScene_Athena ===============
; Athena scene.
Intro_CharScene_Athena:
	; Move white section to the left
	ld   a, $09
	call Intro_CharS_MoveBGLeft_MultiFrame
	
	ld   a, $0F
	call Intro_CharS_WaitVBlank
	
	call Intro_CharS_SetNextChar
	jp   Intro_CharS_NextMode
	
; =============== Intro_CharScene_Leona ===============
; Leona scene.
Intro_CharScene_Leona:
	; Move white section to the middle
	ld   a, $09
	call Intro_CharS_MoveBGRight_MultiFrame
	
	; Shrink from below
	ld   a, $04
	ld   b, $05
	ld   c, $01
	ld   d, TILE_INTRO_BLACK
	ld   hl, $9B6D
	call Intro_CharS_FillBGRectUp_MultiFrame
	
	; Shrink from above
	ld   a, $0A
	ld   b, $05
	ld   c, $01
	ld   d, TILE_INTRO_BLACK
	ld   hl, $990D
	call Intro_CharS_FillBGRectDown_MultiFrame
	
	; Hide Athena
	ld   hl, wOBJInfo_Pl2+iOBJInfo_Status
	res  OSTB_VISIBLE, [hl]
	
	; Expand horizontally to full screen
	ld   a, $08
	ld   c, $06
	ld   hl, $9A4C
	ld   de, $9A52
	call Intro_CharS_CropOpenH_MultiFrame
	
	ld   a, $0A
	call Intro_CharS_WaitVBlank
	call Intro_CharS_SetNextChar
	jp   Intro_CharS_NextMode
; =============== Intro_CharScene_Robert ===============
; Robert scene.
Intro_CharScene_Robert:
	; Move bar up near the top
	ld   a, $0B
	call Intro_CharS_MoveBGUp_MultiFrame
	
	ld   a, $0F
	call Intro_CharS_WaitVBlank
	call Intro_CharS_SetNextChar
	jp   Intro_CharS_NextMode
; =============== Intro_CharScene_Ryo ===============
; Ryo scene.
Intro_CharScene_Ryo:
	; Move bar down near the bottom
	ld   a, $0C
	call Intro_CharS_MoveBGDown_MultiFrame
	
	ld   a, $0F
	call Intro_CharS_WaitVBlank
	call Intro_CharS_SetNextChar
	jp   Intro_CharS_NextMode
; =============== Intro_CharScene_MrKarate ===============
; Mr. Karate scene.
Intro_CharScene_MrKarate:
	; Move bar up at the middle
	ld   a, $09
	call Intro_CharS_MoveBGUp_MultiFrame
	
	ld   a, $0F
	call Intro_CharS_WaitVBlank
	
	; Completely close vertically
	ld   a, $03
	ld   hl, $9A45
	ld   de, $9AE5
	call Intro_CharS_CropCloseH_MultiFrame
	
	call Intro_CharS_SetNextChar
	jp   Intro_CharS_NextMode
; =============== Intro_CharScene_MrBig ===============
; Mr. Big scene.
Intro_CharScene_MrBig:

	; Use the opportunity of the tilemap being completely black to reset the X scroll
	xor  a
	ldh  [hScrollX], a
	
	; Open window with Mr. Big on the left
	ld   a, $05
	ld   b, $01
	ld   c, $06
	ld   d, TILE_INTRO_WHITE
	ld   hl, $9A45
	call Intro_CharS_FillBGRectLeft_MultiFrame
	
	ld   a, $0F
	call Intro_CharS_WaitVBlank
	
	; Completely close window we just opened
	ld   a, $05
	ld   b, $01
	ld   c, $06
	ld   d, TILE_INTRO_BLACK
	ld   hl, $9A45
	call Intro_CharS_FillBGRectLeft_MultiFrame
	
	call Intro_CharS_SetNextChar
	jp   Intro_CharS_NextMode
; =============== Intro_CharScene_Geese ===============
; Geese scene.
Intro_CharScene_Geese:

	; Open window on the right
	ld   a, $05
	ld   b, $01
	ld   c, $06
	ld   d, TILE_INTRO_WHITE
	ld   hl, $9A4E
	call Intro_CharS_FillBGRectRight_MultiFrame
	
	ld   a, $0F
	call Intro_CharS_WaitVBlank
	
	; Close it
	ld   a, $05
	ld   b, $01
	ld   c, $06
	ld   d, TILE_INTRO_BLACK
	ld   hl, $9A4E
	call Intro_CharS_FillBGRectRight_MultiFrame
	
	call Intro_CharS_SetNextChar
	jp   Intro_CharS_NextMode
; =============== Intro_CharScene_Krauser ===============
; Krauser scene.
Intro_CharScene_Krauser:
	; Move slightly left to center the window
	ld   a, $FC
	ldh  [hScrollX], a
	
	; Open window at the center
	ld   a, $06
	ld   b, $05
	ld   c, $01
	ld   d, TILE_INTRO_WHITE
	ld   hl, $9AE7
	call Intro_CharS_FillBGRectUp_MultiFrame
	
	ld   a, $0F
	call Intro_CharS_WaitVBlank
	
	; Close it
	ld   a, $06
	ld   b, $05
	ld   c, $01
	ld   d, TILE_INTRO_BLACK
	ld   hl, $9AE7
	call Intro_CharS_FillBGRectUp_MultiFrame
	
	call Intro_CharS_SetNextChar
	jp   Intro_CharS_NextMode
; =============== Intro_CharScene_Daimon ===============
; Daimon scene.
Intro_CharScene_Daimon:
	; Reset coords to top-left
	xor  a
	ldh  [hScrollX], a
	ldh  [hScrollY], a
	
	; Open tall section on the right side
	ld   a, $05
	ld   b, $01
	ld   c, $12
	ld   d, TILE_INTRO_WHITE
	ld   hl, $980E
	call Intro_CharS_FillBGRectRight_MultiFrame
	
	ld   a, $0F
	call Intro_CharS_WaitVBlank
	
	; Close section
	ld   a, $05
	ld   b, $01
	ld   c, $12
	ld   d, TILE_INTRO_BLACK
	ld   hl, $980E
	call Intro_CharS_FillBGRectRight_MultiFrame
	
	call Intro_CharS_SetNextChar
	jp   Intro_CharS_NextMode
; =============== Intro_CharScene_Mature ===============
; Mature scene.
Intro_CharScene_Mature:
	; Open tall section on the left side
	ld   a, $05
	ld   b, $01
	ld   c, $12
	ld   d, TILE_INTRO_WHITE
	ld   hl, $9805
	call Intro_CharS_FillBGRectLeft_MultiFrame
	
	ld   a, $0F
	call Intro_CharS_WaitVBlank
	
	; Close section
	ld   a, $05
	ld   b, $01
	ld   c, $12
	ld   d, TILE_INTRO_BLACK
	ld   hl, $9805
	call Intro_CharS_FillBGRectLeft_MultiFrame
	
	; Hide player sprites since we're moving to GM_INTRO_IORIRISE
	ld   hl, wOBJInfo_Pl1+iOBJInfo_Status
	res  OSTB_VISIBLE, [hl]
	ld   hl, wOBJInfo_Pl2+iOBJInfo_Status
	res  OSTB_VISIBLE, [hl]
	
	; Flip both sprites for Intro_CharScene_Kyo, to make Iori and Kyo face each other
	ld   a, [wOBJInfo_Pl1+iOBJInfo_OBJLstFlags] ; Make Kyo face left
	xor  OST_XFLIP
	ld   [wOBJInfo_Pl1+iOBJInfo_OBJLstFlags], a
	ld   a, [wOBJInfo_Pl2+iOBJInfo_OBJLstFlags] ; Make Kyo face right
	xor  OST_XFLIP
	ld   [wOBJInfo_Pl2+iOBJInfo_OBJLstFlags], a
	
	jp   Intro_CharS_NextMode
; =============== Intro_CharScene_Kyo ===============
; Kyo scene.
Intro_CharScene_Kyo:

	; Reset coords
	xor  a
	ldh  [hScrollX], a
	ldh  [hScrollY], a
	
	; Open tall section on the right side
	ld   a, $05
	ld   b, $01
	ld   c, $12
	ld   d, TILE_INTRO_WHITE
	ld   hl, $980E
	call Intro_CharS_FillBGRectRight_MultiFrame
	
	ld   a, $0F
	call Intro_CharS_WaitVBlank
	
	call Intro_CharS_SetNextChar
	jp   Intro_CharS_NextMode
; =============== Intro_CharScene_IoriKyoA ===============
; Iori + Kyo sprite scene.
Intro_CharScene_IoriKyoA:
	; Open tall section on the left side
	ld   a, $05
	ld   b, $01
	ld   c, $12
	ld   d, TILE_INTRO_WHITE
	ld   hl, $9805
	call Intro_CharS_FillBGRectLeft_MultiFrame
	
	; Wait for a bit
	ld   a, $28
	call Intro_CharS_WaitVBlank
	
	; Remove left border
	ld   a, $01
	ld   b, $01
	ld   c, $12
	ld   d, TILE_INTRO_WHITE
	ld   hl, $9813
	call Intro_CharS_FillBGRectLeft_MultiFrame
	
	; Remove right border
	ld   a, $01
	ld   b, $01
	ld   c, $12
	ld   d, $00
	ld   hl, BGMap_Begin
	call Intro_CharS_FillBGRectLeft_MultiFrame
	
	call Intro_CharS_SetNextChar ; Set Kyo run anim.
	jp   Intro_CharS_NextMode
	
; =============== Intro_CharScene_IoriKyoB ===============
; Iori + Kyo sprite scene II.
Intro_CharScene_IoriKyoB:
	call Intro_CharS_SetNextChar ; Set Iori run anim
	jp   Intro_CharS_NextMode
; =============== Intro_CharScene_IoriKyoC ===============
; Iori + Kyo sprite scene III.
Intro_CharScene_IoriKyoC:

	;
	; Make the attack animations freeze at a certain point.
	; It's a little bit odd -- setting OSTB_ANIMEND prematurely will cause the
	; currently loading frame to be the last one to be applied (several frames later).
	;
	; This (with help from the animation speed definition in Intro_CharS_SetNextChar) is
	; specifically timed so that the player sprites change into a good
	; attack frame when they get to the center of the screen.
	;
	ld   a, [wOBJInfo_Pl1+iOBJInfo_OBJLstPtrTblOffset]
	cp   $04*OBJLSTPTR_ENTRYSIZE			; Reached frame 4? (which is still loading)
	jr   nz, .chkIori						; If not, skip
	ld   hl, wOBJInfo_Pl1+iOBJInfo_Status	; End animation. The frame will still applied when it loads.
	set  OSTB_ANIMEND, [hl]
.chkIori:
	ld   a, [wOBJInfo_Pl2+iOBJInfo_OBJLstPtrTblOffset]
	cp   $01*OBJLSTPTR_ENTRYSIZE			; Reached frame 1? (which is still loading)
	jr   nz, .waitEnd						; If not, skip
	ld   hl, wOBJInfo_Pl2+iOBJInfo_Status	; End animation. The frame will still applied when it loads.
	set  OSTB_ANIMEND, [hl]
.waitEnd:

	; Wait 1 frane
	ld   a, $01
	call Intro_CharS_WaitVBlank
	
	; Continue looping until both anims are marked as ended
	ld   a, [wOBJInfo_Pl1+iOBJInfo_Status]
	ld   b, a								; B = StatusPl1
	ld   a, [wOBJInfo_Pl2+iOBJInfo_Status]	; A = StatusPl2
	and  a, b								; 
	bit  OSTB_ANIMEND, a					; (A & B) & OSTB_ANIMEND != 0? (OSTB_ANIMEND set on both players?)
	jr   z, Intro_CharScene_IoriKyoC		; If not, loop
	
	;
	; Remove the middle black section while moving Iori and Kyo to the center of the screen.
	;
	ld   a, -$07							; Make Kyo move to the left
	ld   [wOBJInfo_Pl1+iOBJInfo_SpeedX], a
	ld   a, $07								; Make Iori move to the right
	ld   [wOBJInfo_Pl2+iOBJInfo_SpeedX], a
	
	; White out center section
	ld   a, $04
	ld   c, $12
	ld   hl, $980D
	ld   de, $9806
	call Intro_CharS_CropOpenH_MultiFrame
	
.end:
	; Reset speed
	xor  a
	ld   [wOBJInfo_Pl1+iOBJInfo_SpeedX], a
	ld   [wOBJInfo_Pl2+iOBJInfo_SpeedX], a
	
	; Wait for a bit so the last anim frames get applied
	ld   a, $0A
	call Intro_CharS_WaitVBlank
	jp   Intro_CharS_NextMode
	
; =============== Intro_CharS_NextMode ===============
; Switches to the next character scene.
Intro_CharS_NextMode:
	ld   a, [wIntroCharScene]
	add  a, $02
	ld   [wIntroCharScene], a
	ret
	
; =============== Intro_CharS_SetNextChar ===============
; Set the next player sprites on the first free slot where the win animation ended.
;
; This will update the player's sprite mappings and positions.
;
; It should be only used on players hidden behind the black background, to give
; time for the new graphics to load and to avoid having the sprite visibly change position.
Intro_CharS_SetNextChar:
	
	;
	; Get the table index and starting ptr
	;
	ld   hl, .charDefTbl			; HL = .charDefTbl
	; Generate the index to the table
	ld   a, [wIntroCharScene]	; A = (wIntroCharScene / 2) - 2
	srl  a						; /2 because it's an offset, not index
	sub  a, (INTRO_SCENE_ANDY/2)		; -2 to save bytes, since the Andy scene is the first one to call this
	
	; Pick the first player slot whose animation is ended.
	;
	; Because it relies on OSTB_GFXLOAD on being cleared, care should be taken
	; to make sure the visible sprite is still animating when this is called. (more or less)
	;
	; (The win animations are set to *not* loop, so OSTB_GFXLOAD is unset when the animation ends)
	
	ld   de, wOBJInfo_Pl1+iOBJInfo_Status
	bit  OSTB_GFXLOAD, a					; GFX loading on Pl1 side?
	jr   z, .go								; If not, jump
	ld   de, wOBJInfo_Pl2+iOBJInfo_Status	; Otherwise use Pl2
.go:

	;
	; Index the table
	;
	
	; Build the index to a table with 6 byte entries
	; BC = A * 6
	sla  a			; B = A * 2		
	ld   b, a		
	sla  a			; A = A * 4
	add  b			; A += B
	ld   b, $00		; Put that in BC
	ld   c, a
	
	; Seek to the table entry
	add  hl, bc		; BC = HL + BC
	push hl
	pop  bc
	
	;
	; Update the wOBJInfo field
	;
	
	
	; Reinitialize status
	ld   a, [de]		; A = iOBJInfo_Status
	and  a, $FF^OST_ANIMEND ; Remove repeat flag
	or   a, OST_VISIBLE	    ; Force visibility
	ld   [de], a
	
	; byte0 -> iOBJInfo_BankNum
	ld   hl, iOBJInfo_BankNum	; Seek to iOBJInfo_BankNum
	add  hl, de
	ld   a, [bc]		; Read byte0
	ldi  [hl], a		; Write to iOBJInfo_BankNum
	inc  bc
	
	; byte1-2 to iOBJInfo_OBJLstPtrTbl_*0
	ld   a, [bc]
	ldi  [hl], a
	inc  bc
	ld   a, [bc]
	ldi  [hl], a
	inc  bc
	
	; $00 -> iOBJInfo_OBJLstPtrTblOffset
	xor  a
	ld   [hl], a
	
	; The target position should also hide the sprite behind the background.
	
	; byte3 -> iOBJInfo_X
	ld   hl, iOBJInfo_X	; Seek to iOBJInfo_X
	add  hl, de
	ld   a, [bc]
	ldi  [hl], a
	inc  bc
	inc  hl				; Ignore subpixel val
	
	; byte4 -> iOBJInfo_Y
	ld   a, [bc]
	ld   [hl], a
	inc  bc
	
	; Anim speed
	; byte5 -> iOBJInfo_FrameLeft & iOBJInfo_FrameTotal
	ld   hl, iOBJInfo_FrameLeft
	add  hl, de
	ld   a, [bc]
	ldi  [hl], a ; iOBJInfo_FrameLeft
	ld   [hl], a ; iOBJInfo_FrameTotal
	push de
	pop  hl	; DE = Start of wOBJInfo
	
	; Initialize animation with newly written settings
	call OBJLstS_DoAnimTiming_Initial
	
	; Wait $08 frames
	ld   a, $08
	call Intro_CharS_WaitVBlank
	ret
	
.charDefTbl:

mIntroCharDef: MACRO
	db BANK(\1)
	dw \1
	db \2,\3,\4
ENDM

	;;;;;;;;;;;;; ANIMATION TABLE                   |  X|   Y| ANIMDELAY ; BANK | For Scene Loading
	mIntroCharDef OBJLstPtrTable_Mai_WinA,           $50, $40,       $00 ;  $08 | INTRO_SCENE_MAI        
	mIntroCharDef OBJLstPtrTable_Athena_WinA,        $20, $40,       $00 ;  $08 | INTRO_SCENE_ATHENA     
	mIntroCharDef OBJLstPtrTable_OLeona_WinB,        $50, $40,       $03 ;  $0A | INTRO_SCENE_LEONA      
	mIntroCharDef OBJLstPtrTable_Robert_Intro,       $80, $00,       $06 ;  $07 | INTRO_SCENE_ROBERT     
	mIntroCharDef OBJLstPtrTable_Ryo_Intro,          $20, $50,       $04 ;  $0A | INTRO_SCENE_RYO        
	mIntroCharDef OBJLstPtrTable_MrKarate_DemoIntro, $50, $24,       $08 ;  $0A | INTRO_SCENE_MRKARATE   
	mIntroCharDef OBJLstPtrTable_MrBig_WinB,         $20, $24,       $00 ;  $07 | INTRO_SCENE_MRBIG      
	mIntroCharDef OBJLstPtrTable_Geese_IntroSpec,    $80, $24,       $00 ;  $07 | INTRO_SCENE_GEESE      
	mIntroCharDef OBJLstPtrTable_Krauser_WinB,       $50, $24,       $00 ;  $09 | INTRO_SCENE_KRAUSER    
	mIntroCharDef OBJLstPtrTable_Daimon_Taunt,       $84, $40,       $00 ;  $09 | INTRO_SCENE_DAIMON     
	mIntroCharDef OBJLstPtrTable_Mature_WinB,        $1C, $40,       $06 ;  $09 | INTRO_SCENE_MATURE     
	db      $00,  $00,$00,                           $00, $00,       $00 ;  $00 | INTRO_SCENE_CHG_IORIRISE (N/A)
	mIntroCharDef OBJLstPtrTable_Kyo_DemoIntro,      $84, $40,       $00 ;  $07 | INTRO_SCENE_KYO        
	mIntroCharDef OBJLstPtrTable_OIori_ChargeMeter,  $1C, $40,       $00 ;  $05 | INTRO_SCENE_IORIKYOA   
	mIntroCharDef OBJLstPtrTable_Kyo_UraOrochiNagiS, $84, $40,       $03 ;  $07 | INTRO_SCENE_IORIKYOB   
	mIntroCharDef OBJLstPtrTable_Iori_KinYaOtomeS,   $1C, $40,       $0F ;  $05 | INTRO_SCENE_IORIKYOC 
	
; =============== IntroScene_IoriRise ===============
; OUT
; - C flag: If set, end the intro prematurely
IntroScene_IoriRise:
	;
	; Move Iori sprite upwards for $012C frames
	;
	ld   bc, $012C		; BC = Frames to move up
.loop:
	push bc
		; Move BG Sun up at $00.04px/frame
		ld   hl, hScrollY	; Pos ptr
		ld   bc, $0004		; Speed
		call .addToPos
		
		; Move Iori up at $00.36px/frame
		ld   hl, wOBJInfo_IIoriH+iOBJInfo_Y
		ld   bc, -$0036
		call .addToPos
		ld   hl, wOBJInfo_IIoriL+iOBJInfo_Y
		ld   bc, -$0036
		call .addToPos
		
		; When Iori is about to overlap the Sun, disable its BG priority.
		;
		; The reason the flag is set to begin with is because, otherwise,
		; it would be visible on the lower section.
		;
		; The lower half of the sprite in wOBJInfo_IIoriL never reaches
		; high enough, so it gets to keep its BG Priority flag.
		
		ld   a, [wOBJInfo_IIoriH+iOBJInfo_Y]
		cp   $30										; Has Y position $30?
		jr   nz, .noRemBGPr								; If not, skip
		ld   hl, wOBJInfo_IIoriH+iOBJInfo_OBJLstFlags	; Otherwise, remove BG priority
		res  SPRB_BGPRIORITY, [hl]
	.noRemBGPr:
	
		; Wait 1 frame
		ld   a, $01
		call Intro_ChkStartPressed_MultiFrame
	pop  bc
	
	dec  bc			; BC--
	ld   a, b
	or   a, c		; BC == 0?
	jr   nz, .loop	; If not, loop
	
.end:

	; Reset pal
	ld   a, $FF
	ldh  [rBGP], a
	ldh  [rOBP0], a
	ldh  [rOBP1], a
	
	call DisableSectLYC
	
	ld   d, TILE_INTRO_BLACK
	call ClearBGMapCustom
	
	; Reset scroll for char mode
	xor  a
	ldh  [hScrollX], a
	ldh  [hScrollY], a
	
	; Hide WINDOW
	ld   a, $90
	ldh  [rWY], a
	ld   a, $07
	ldh  [rWX], a
	
	; Disable LYC
	xor  a
	ldh  [rSTAT], a
	
	; Hide large sprite
	ld   hl, wOBJInfo_IIoriH+iOBJInfo_Status
	res  OSTB_VISIBLE, [hl]
	ld   hl, wOBJInfo_IIoriL+iOBJInfo_Status
	res  OSTB_VISIBLE, [hl]
	
	; Set new pal
	ld   a, $F0
	ldh  [rBGP], a
	ld   a, $8C
	ldh  [rOBP0], a
	ld   a, $4C
	ldh  [rOBP1], a
	
	; Loop the animations from the remainder of the modes (INTRO_SCENE_KYO and above) 
	ld   a, $FF
	ld   [wIntroLoopOBJAnim], a
	
	; Next mode
	call Intro_CharS_SetNextChar
	ld   a, INTRO_SCENE_KYO
	ld   [wIntroCharScene], a
	ld   a, GM_INTRO_CHAR
	ld   [wIntroScene], a
	xor  a
	ret
	
; IN
; - HL: Ptr to pixel position
; - BC: Amount to add
.addToPos:
	push hl ; Save coord ptr
		; HL = Coordinate
		ld   d, [hl]	; D = Pixels
		inc  hl
		ld   e, [hl]	; E = Subpixels
		push de			;
		pop  hl			; Move to HL
		
		; DE = HL + BC
		add  hl, bc		
		push hl
		pop  de
	pop  hl ; Restore coord ptr
	
	; Write back updated coord
	ld  [hl], d		; Write pixels
	inc  hl
	ld   [hl], e	; Write subpixels
	ret
	
; =============== IntroScene_IoriKyo ===============
; Iori and Kyo cutouts scroll towards the center of the screen.
; OUT
; - C flag: If set, end the intro
IntroScene_IoriKyo:
	
	;
	; Move "sections" at 15 frames at 15px/frame
	;
	ld   a, $0F	
.loop:
	push af
		ld   b, a	
		; Move Iori to the right
		ldh  a, [hScrollX]	; hScrollX -= A
		sub  a, b
		ldh  [hScrollX], a
		; Move Kyo to the left
		ldh  a, [rWX]		; rWX -= A
		sub  a, b
		ldh  [rWX], a
		
		; Wait 1 frame
		ld   a, $01
		call Intro_ChkStartPressed_MultiFrame
	pop  af
	dec  a			; Are we done?
	jr   nz, .loop	; If not, loop
	
	; Wait $78 frames
	ld   a, $78
	call Intro_ChkStartPressed_MultiFrame
	
	; End the intro 
	scf 		; Set C flag
	ret
	
; =============== Intro_CharS_MoveBG*_MultiFrame ===============
; Sets of subroutines to move the background across multiple frames.
; 
; IN
; - A: Number of frames *and* movement speed.
;      This value is used for both purposes, meaning the target
;      location grows exponentially.
;

; =============== Intro_CharS_MoveBGUp_MultiFrame ===============
; Moves the background up across multiple frames.
; IN
; - A: Number of frames *and* movement speed
Intro_CharS_MoveBGUp_MultiFrame:
	push af
		; Scroll screen down to move BG up
		ld   b, a
		ldh  a, [hScrollY]	; hScrollY += A
		add  b
		ldh  [hScrollY], a
		
		; Wait 1 frame
		ld   a, $01
		call Intro_CharS_WaitVBlank
	pop  af
	dec  a								; FramesLeft--
	jr   nz, Intro_CharS_MoveBGUp_MultiFrame	; No frames left? If not, loop
	ret
	
; =============== Intro_CharS_MoveBGDown_MultiFrame ===============
; Moves the background down across multiple frames.
; IN
; - A: Number of frames *and* movement speed
Intro_CharS_MoveBGDown_MultiFrame:
	push af
		; Scroll screen up to move BG down
		ld   b, a
		ldh  a, [hScrollY]	; hScrollY -= A
		sub  a, b
		ldh  [hScrollY], a
		
		; Wait 1 frame
		ld   a, $01
		call Intro_CharS_WaitVBlank
	pop  af
	dec  a									; FramesLeft--
	jr   nz, Intro_CharS_MoveBGDown_MultiFrame	; No frames left? If not, loop
	ret
	
; =============== Intro_CharS_MoveBGLeft_MultiFrame ===============
; Moves the background left across multiple frames.
; IN
; - A: Number of frames *and* movement speed
Intro_CharS_MoveBGLeft_MultiFrame:
	push af
		; Scroll screen right to move BG left
		ld   b, a
		ldh  a, [hScrollX]	; hScrollX += A
		add  b
		ldh  [hScrollX], a
		
		; Wait 1 frame
		ld   a, $01
		call Intro_CharS_WaitVBlank
	pop  af
	dec  a									; FramesLeft--
	jr   nz, Intro_CharS_MoveBGLeft_MultiFrame	; No frames left? If not, loop
	ret
	
; =============== Intro_CharS_MoveBGRight_MultiFrame ===============
; Moves the background right across multiple frames.
; IN
; - A: Number of frames *and* movement speed
Intro_CharS_MoveBGRight_MultiFrame:
	push af
		; Scroll screen left to move BG right
		ld   b, a
		ldh  a, [hScrollX] ; hScrollX -= A
		sub  a, b
		ldh  [hScrollX], a
		
		; Wait 1 frame
		ld   a, $01
		call Intro_CharS_WaitVBlank
	pop  af
	dec  a									; FramesLeft--
	jr   nz, Intro_CharS_MoveBGRight_MultiFrame	; No frames left? If not, loop
	ret
	
; =============== Intro_CharS_FillBGRect* ===============
; Set of functions that animate the tilemap to enlarge or shrink the white rectangles during the intro.
; These work by drawing a small rectangle to the tilemap and then moving the starting position.
; This is repeated for the specified amount of frames.
;
; Since the tilemap isn't cleared before drawing the rectangles, this allows the growing/shrinking
; effect to work, otherwise it would look like small rectangles moving.
; 
	
; =============== Intro_CharS_FillBGRectUp ===============
; Draws a rectangle that grows upwards every frame.
; IN
; - A: Number of frames
; IN (FillBGRect)
; - HL: Initial rect top left corner in tilemap
; - B: Rect Width
; - C: Rect Height
; - D: Tile ID to use
Intro_CharS_FillBGRectUp_MultiFrame:
	push af
	push bc
	push de
		push hl
			; Draw rectangle with current settings
			call FillBGRect
			
			; Wait 1 frame
			ld   a, $01
			call Intro_CharS_WaitVBlank
		pop  hl
		
		; Move origin up by 1 tile
		ld   de, -BG_TILECOUNT_H
		add  hl, de
	pop  de
	pop  bc
	pop  af
	
	dec  a											; Are we done?
	jr   nz, Intro_CharS_FillBGRectUp_MultiFrame	; If not, loop
	ret

; =============== Intro_CharS_FillBGRectDown_MultiFrame ===============
; Draws a rectangle that grows downwards every frame.
; IN
; - A: Number of frames
; IN (FillBGRect)
; - HL: Initial rect top left corner in tilemap
; - B: Rect Width
; - C: Rect Height
; - D: Tile ID to use
Intro_CharS_FillBGRectDown_MultiFrame:
	push af
	push bc
	push de
		push hl
			; Draw rectangle with current settings
			call FillBGRect
			
			; Wait 1 frame
			ld   a, $01
			call Intro_CharS_WaitVBlank
		pop  hl
		
		; Move origin down by 1 tile
		ld   de, BG_TILECOUNT_H
		add  hl, de
	pop  de
	pop  bc
	pop  af
	
	dec  a											; Are we done?
	jr   nz, Intro_CharS_FillBGRectDown_MultiFrame	; If not, loop
	ret
	
; =============== Intro_CharS_FillBGRectLeft_MultiFrame ===============
; Draws a rectangle that grows left every frame.
; IN
; - A: Number of frames
; IN (FillBGRect)
; - HL: Initial rect top left corner in tilemap
; - B: Rect Width
; - C: Rect Height
; - D: Tile ID to use
Intro_CharS_FillBGRectLeft_MultiFrame:
	push af
	push bc
	push de
		push hl
			; Draw rectangle with current settings
			call FillBGRect
			
			; Wait 1 frame
			ld   a, $01
			call Intro_CharS_WaitVBlank
		pop  hl
		
		; Move origin left by 1 tile
		dec  hl
	pop  de
	pop  bc
	pop  af
	
	dec  a											; Are we done?
	jr   nz, Intro_CharS_FillBGRectLeft_MultiFrame	; If not, loop
	ret
	
; =============== Intro_CharS_FillBGRectRight_MultiFrame ===============
; Draws a rectangle that grows right every frame.
; IN
; - A: Number of frames
; IN (FillBGRect)
; - HL: Initial rect top left corner in tilemap
; - B: Rect Width
; - C: Rect Height
; - D: Tile ID to use
Intro_CharS_FillBGRectRight_MultiFrame:
	push af
	push bc
	push de
		push hl
			; Draw rectangle with current settings
			call FillBGRect
			
			; Wait 1 frame
			ld   a, $01
			call Intro_CharS_WaitVBlank
		pop  hl
		
		; Move origin right by 1 tile
		inc  hl
	pop  de
	pop  bc
	pop  af
	
	dec  a	
	jr   nz, Intro_CharS_FillBGRectRight_MultiFrame	; If not, loop
	ret
	
; =============== Intro_CharS_CropOpenH_MultiFrame ===============
; Applies an horizontal crop opening transition to the tilemap.
;
; This is handled by drawing two white vertical strips, one at the left and one at the right.
; After the frame ends, the origin points are moved outwards.
;
; IN
; - A: Number of frames
; - HL: Left origin point
; - DE: Right origin point
; - C: Rect Height
Intro_CharS_CropOpenH_MultiFrame:
	push af
		push bc
			;#####
			push de
				push hl
					;------
					; Draw vertical strip on the left
					push bc
						push de
							ld   b, $01 				; B = Width
							ld   d, TILE_INTRO_WHITE
							call FillBGRect
						pop  de
					pop  bc
					
					; Draw vertical strip on the right		
					push de
					pop  hl						; HL = Right origin point
					ld   b, $01					; B = Width
					ld   d, TILE_INTRO_WHITE
					call FillBGRect
					
					; Wait 1 frame
					ld   a, $01
					call Intro_CharS_WaitVBlank
					;------
				pop  hl ; Restore left origin
			pop  de ; Restore right origin
			;#####
			
			; Move left origin point left by 1 tile
			dec  hl 
			; Move right origin point right by 1 tile
			inc  de
		pop  bc
	pop  af
	dec  a
	jr   nz, Intro_CharS_CropOpenH_MultiFrame
	ret
	
; =============== Intro_CharS_CropCloseH_MultiFrame ===============
; Applies a vertical crop closing transition to the tilemap.
;
; This is handled by drawing two black horizontal strips, one at the top and the other at the bottom.
; After the frame ends, the origin points are moved inwards.
;
; See also: Intro_CharS_CropOpenH_MultiFrame
;
; IN
; - A: Number of frames
; - HL: Top origin point
; - DE: Bottom origin point
Intro_CharS_CropCloseH_MultiFrame:
		push af
		push de
			push hl
				;------
				; Draw horizontal strip at the top
				push de
					ld   b, $15					; B = Width
					ld   c, $01					; C = Height
					ld   d, TILE_INTRO_BLACK	
					call FillBGRect
				pop  de
				
				; Draw horizontal strip at the bottom
				push de
				pop  hl							; HL = Bottom origin point
					ld   b, $15					; B = Width
					ld   c, $01					; C = Height
				ld   d, TILE_INTRO_BLACK
				call FillBGRect
				
				; Wait 4 frames
				ld   a, $04
				call Intro_CharS_WaitVBlank
				;------
			pop  hl ; Restore top origin 
		pop  de ; Restore bottom origin 
		
		; Move top origin point down by 1 tile
		ld   bc, BG_TILECOUNT_H			; HL += BG_TILECOUNT_H 
		add  hl, bc
		
		; Move bottom origin point up by 1 tile
		push hl
			ld   hl, -BG_TILECOUNT_H	; DE -= BG_TILECOUNT_H 
			add  hl, de
			push hl
			pop  de
		pop  hl
	pop  af
	dec  a
	jr   nz, Intro_CharS_CropCloseH_MultiFrame
	ret
	
; =============== Intro_CharS_WaitVBlank ===============
; Common code shared across character scenes.
Intro_CharS_WaitVBlank:
	; If wIntroLoopOBJAnim is set, use OBJLstS_DoAnimTiming_Loop as animation function,
	; otherwise use OBJLstS_DoAnimTiming_NoLoop. The two code paths are otherwise identical. 
	push af
		ld   a, [wIntroLoopOBJAnim]
		ld   b, a
		or   a				; wIntroLoopOBJAnim != 0?
		jr   nz, .useLoop	; If so, jump
.noLoop:
	pop  af
.delay1:
	push af
		; Animate Pl1 and Pl2 sprites
		ld   hl, wOBJInfo_Pl1+iOBJInfo_Status
		call OBJLstS_DoAnimTiming_NoLoop
		ld   hl, wOBJInfo_Pl2+iOBJInfo_Status
		call OBJLstS_DoAnimTiming_NoLoop
		; Apply H speed
		ld   de, wOBJInfo_Pl1+iOBJInfo_Status
		call OBJLstS_ApplyXSpeed
		ld   de, wOBJInfo_Pl2+iOBJInfo_Status
		call OBJLstS_ApplyXSpeed
		; Wait 1 frame
		ld   a, $01
		call Intro_ChkStartPressed_MultiFrame
	pop  af
	dec  a				; Waited all frames?
	jr   nz, .delay1	; If not, loop
	ret
	
.useLoop:
	pop  af
.delay2:
	push af
		; Animate Pl1 and Pl2 sprites
		ld   hl, wOBJInfo_Pl1+iOBJInfo_Status
		call OBJLstS_DoAnimTiming_Loop
		ld   hl, wOBJInfo_Pl2+iOBJInfo_Status
		call OBJLstS_DoAnimTiming_Loop
		; Apply H speed
		ld   de, wOBJInfo_Pl1+iOBJInfo_Status
		call OBJLstS_ApplyXSpeed
		ld   de, wOBJInfo_Pl2+iOBJInfo_Status
		call OBJLstS_ApplyXSpeed
		; Wait 1 frame
		ld   a, $01
		call Intro_ChkStartPressed_MultiFrame
	pop  af
	dec  a				; Waited all frames?
	jr   nz, .delay2	; If not, loop
	ret
	
; =============== Intro_CharS_LoadVRAM ===============
Intro_CharS_LoadVRAM:
	di
	;-----------------------------------
	rst  $10				; Stop LCD
	
	; Reset DMG Pal & vars
	ld   a, $FF
	ldh  [rBGP], a
	ldh  [rOBP0], a
	ldh  [rOBP1], a
	xor  a
	ld   [wIntroScene], a		; Not necessary
	ld   [wIntroCharScene], a
	ld   [wIntroLoopOBJAnim], a
	
	; Reset screen & coords
	call ClearBGMap
	call ClearWINDOWMap
	
	xor  a
	ldh  [hScrollX], a
	ldh  [hScrollY], a
	ld   [wOBJScrollX], a
	ld   [wOBJScrollY], a
	
	; Load GFX for scene
	ld   hl, GFXLZ_IntroBG
	ld   de, wLZSS_Buffer
	call DecompressLZSS
	ld   hl, wLZSS_Buffer
	ld   de, $9000			; full 3rd section	
	ld   b, $80
	call CopyTiles
	ld   hl, wLZSS_Buffer+$0800
	ld   de, $8800			; 2nd section
	ld   b, $2A				
	call CopyTiles
	
	ld   hl, GFXLZ_Intro_IoriRiseOBJ
	ld   de, wLZSS_Buffer
	call DecompressLZSS
	ld   hl, wLZSS_Buffer
	ld   de, $8800+$0460	; lower part of 2nd section
	ld   b, $3A
	call CopyTiles
	
	; Fill BG black
	ld   hl, BGMap_Begin
	ld   b, $20
	ld   c, $20
	ld   d, $01
	call FillBGRect
	
	; Load default sprite mappings
	ld   hl, wOBJInfo_Pl1+iOBJInfo_Status
	ld   de, OBJInfoInit_Pl1
	call OBJLstS_InitFrom
	ld   hl, wOBJInfo_Pl2+iOBJInfo_Status
	ld   de, OBJInfoInit_Pl2
	call OBJLstS_InitFrom
	
	; Hide both sprites while the GFX are loading, and make them display
	; behind the background (for the window reveal effect to work).
	ld   hl, wOBJInfo_Pl1+iOBJInfo_Status
	res  OSTB_VISIBLE, [hl]					; Hide for now
	inc  hl									; Seek to iOBJInfo_OBJLstFlags
	set  SPRB_BGPRIORITY, [hl]				; Set BG priority
	ld   hl, wOBJInfo_Pl2+iOBJInfo_Status	; Do the same for Andy's sprite
	res  OSTB_VISIBLE, [hl]
	inc  hl
	set  SPRB_BGPRIORITY, [hl]
	
	; Initialize buffer info
	ld   hl, wOBJInfo_Pl1+iOBJInfo_Status
	call OBJLstS_DoAnimTiming_Initial
	ld   hl, wOBJInfo_Pl2+iOBJInfo_Status
	call OBJLstS_DoAnimTiming_Initial
	
	; Hide WINDOW
	ld   a, $90
	ldh  [rWY], a
	ld   a, $07
	ldh  [rWX], a
	
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_OBJSIZE|LCDC_WENABLE|LCDC_WTILEMAP|LCDC_ENABLE
	rst  $18				; Resume LCD
	;-----------------------------------
	ei
	
	; Delay $14 frames.
	ld   a, $14
	call Intro_ChkStartPressed_MultiFrame
	
	ld   a, $8C		; 1P Pal
	ldh  [rOBP0], a
	ld   a, $4C		; 2P Pal
	ldh  [rOBP1], a
	ld   a, $C0		; BG
	ldh  [rBGP], a
	ret
	
; =============== Intro_IoriRise_LoadVRAM ===============
; Sets up the scene for Iori rising from below.
Intro_IoriRise_LoadVRAM:
	di
	;-----------------------------------
	rst  $10				; Stop LCD
	
	; The scene uses the sector system to display the black borders thanks to the WINDOW layer.
	
	; Set the middle section start/end, where the WINDOW is disabled and sprites are visible.
	ld   a, $1E			; Disable at this scanline
	ld   b, $6F			; Enable again here
	call SetSectLYC
	
	; Reset DMG Pal & vars
	xor  $FF
	ldh  [rBGP], a
	ldh  [rOBP0], a
	ldh  [rOBP1], a
	xor  a
	ld   [wIntroScene], a
	
	; Clear BG layer
	call ClearBGMap
	; Color WINDOW black to hide sprites
	ld   d, TILE_INTRO_BLACK
	call ClearWINDOWMapCustom
	
	; Reset coords
	xor  a
	ldh  [hScrollY], a
	ld   [wOBJScrollX], a
	ld   [wOBJScrollY], a
	
	;
	; Display "Sun" at the center of the tilemap
	;
	
	; Set BG scrolling to partially hide it behind the WINDOW.
	; As frames pass it will become progressively more visible.
	ld   a, $F0
	ldh  [hScrollX], a
	ld   a, $E0
	ldh  [hScrollY], a
	
	; Decompress Sun tilemap to a rectangle area
	ld   hl, BGLZ_Intro_Sun
	ld   de, wLZSS_Buffer
	call DecompressLZSS
	ld   de, wLZSS_Buffer
	ld   hl, BGMap_Begin
	ld   b, $10			; Width
	ld   c, $06			; Height
	call CopyBGToRect
	
	; Really disable the player sprites, to be sure I guess
	ld   hl, wOBJInfo_Pl1+iOBJInfo_Status
	res  OSTB_VISIBLE, [hl]
	ld   hl, wOBJInfo_Pl2+iOBJInfo_Status
	res  OSTB_VISIBLE, [hl]
	
	; Write Iori's sprites to the special slots.
	; This Iori is big enough that two sprites are needed to display him.
	ld   hl, wOBJInfo_IIoriH+iOBJInfo_Status
	ld   de, OBJInfoInit_Intro_Iori
	call OBJLstS_InitFrom
	ld   hl, wOBJInfo_IIoriL+iOBJInfo_Status
	ld   de, OBJInfoInit_Intro_Iori
	call OBJLstS_InitFrom
	
	; Set second sprite mapping (wOBJInfo_IIoriH keeps its INTRO_OBJ_IORIH)
	ld   a, INTRO_OBJ_IORIL*OBJLSTPTR_ENTRYSIZE
	ld   [wOBJInfo_IIoriL+iOBJInfo_OBJLstPtrTblOffset], a
	
	; Display the WINDOW
	ld   a, $00
	ldh  [rWY], a
	ld   a, $07
	ldh  [rWX], a
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_OBJSIZE|LCDC_WENABLE|LCDC_WTILEMAP|LCDC_ENABLE
	rst  $18				; Resume LCD
	;-----------------------------------
	
	; Enable scanline (and VBlank, for some reason) interrupts
	ldh  a, [rSTAT]
	or   a, STAT_LYC
	ldh  [rSTAT], a
	ldh  a, [rIE]
	or   a, I_STAT|I_VBLANK
	ldh  [rIE], a
	
	ei
	
	; Wait 2 frames while the sprite graphics load
	call Task_PassControl_NoDelay
	call Task_PassControl_NoDelay
	
	; Only after that set the proper palettes to make things visible
	ld   a, $8C					; OBJ palettes
	ldh  [rOBP0], a
	ld   a, $00
	ldh  [rOBP1], a
	ld   a, $1B					; Standard colors for the BG
	ldh  [hScreenSect1BGP], a
	ld   a, $FF					; Completely black borders
	ldh  [hScreenSect0BGP], a
	ldh  [hScreenSect2BGP], a
	ret
	
; =============== Intro_IoriKyo_LoadVRAM ===============
; Sets up the scene for Iori and Kyo cutouts moving into view.
Intro_IoriKyo_LoadVRAM:
	di
	;-----------------------------------
	rst  $10				; Stop LCD
	
	; Reset DMG Pal & vars
	xor  a
	ldh  [rBGP], a
	ldh  [rOBP0], a
	ldh  [rOBP1], a
	ld   [wIntroScene], a
	
	; Reset screen & coords
	call ClearBGMap
	call ClearWINDOWMap
	
	xor  a
	ldh  [hScrollY], a
	ld   [wOBJScrollX], a
	ld   [wOBJScrollY], a
	
	; 
	ld   a, $60
	ldh  [hScrollX], a
	
	; Notes:
	; - Due to the palettes used, Black and White are inverted in this scene.
	; - This scene does not use the section system.
	;   Instead, Kyo is in the WINDOW layer and gets scrolled independently.
	
	; Create white horizontal bar for Iori for upper section
	ld   hl, $9820
	ld   b, $20
	ld   c, $07
	ld   d, TILE_INTRO_BLACK
	call FillBGRect
	
	; Create white horizontal bar for Kyo in the lower section
	ld   hl, $9920
	ld   b, $20
	ld   c, $08
	ld   d, TILE_INTRO_BLACK
	call FillBGRect
	
	; Create white backdrop for the section used to display Kyo
	ld   hl, WINDOWMap_Begin
	ld   b, $14
	ld   c, $08
	ld   d, $01
	call FillBGRect
	
	; Draw Iori tilemap on the left side of the upper section.
	; Written to the BG layer.
	ld   hl, BGLZ_Intro_IoriCutout
	ld   de, wLZSS_Buffer
	call DecompressLZSS
	ld   de, wLZSS_Buffer
	ld   hl, $9820
	ld   b, $0E
	ld   c, $07
	call CopyBGToRect
	
	; Draw Kyo tilemap on the right side of the lower section
	; Written to the top of the WINDOW, which will be moved down
	ld   hl, BGLZ_Intro_KyoCutout
	ld   de, wLZSS_Buffer
	call DecompressLZSS
	ld   de, wLZSS_Buffer
	ld   hl, WINDOWMap_Begin
	ld   b, $0E
	ld   c, $08
	call CopyBGToRect
	
	; Remove all sprites
	call ClearOBJInfo
	
	; Align WINDOW with lower horizontal bar, off-screen on the right
	ld   a, $90
	ld   a, $48
	ldh  [rWY], a
	ld   a, $A3
	ldh  [rWX], a
	
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_OBJSIZE|LCDC_WENABLE|LCDC_WTILEMAP|LCDC_ENABLE
	rst  $18				; Resume LCD
	;-----------------------------------
	ei
	call Task_PassControl_NoDelay
	call Task_PassControl_NoDelay
	
	; Set palettes
	ld   a, $18
	ldh  [rOBP0], a
	ld   a, $00
	ldh  [rOBP1], a
	ld   a, $1B
	ldh  [rBGP], a
	ret
	
; =============== Intro_ChkStartPressed_MultiFrame ===============
; Checks if the START button is pressed for the specified amount of frames.
; While this happens the task is essentially paused.
; IN
; - A: Frames to check
Intro_ChkStartPressed_MultiFrame:
	push af
		call Intro_Base_IsStartPressed			; Pressed START?
		jp   c, Intro_End						; If so, end the intro
		call Task_PassControl_NoDelay
	pop  af
	dec  a										; Waited all frames?
	jp   nz, Intro_ChkStartPressed_MultiFrame	; If not, loop
	ret
	
; =============== Intro_Base_IsStartPressed ===============
; Checks if START is pressed on any controller.
; OUT
; - C flag: If set, START is pressed on any controller.
Intro_Base_IsStartPressed:
	ldh  a, [hJoyNewKeys]
	bit  KEYB_START, a		; Pressed START on controller 1?
	jp   nz, .pressed		; If so, jump
	ldh  a, [hJoyNewKeys2]
	bit  KEYB_START, a		; Pressed START on controller 1?
	jp   nz, .pressed		; If so, jump
.not:
	xor  a	; clear C flag
	ret
.pressed:
	scf		; set C flag
	ret
	
IntroTextPtrTable:
	db $04				; Number of strings to print
	dw TextDef_Intro0
	dw TextDef_Intro1
	dw TextDef_Intro2
	dw TextDef_Intro3
TextDef_Intro0: 
	dw $9900	; Tilemap ptr
.c:	db $24		; String length
.s:	db " VIOLENT FIGHTING",C_NL,C_NL,"  TO COME AGAIN!",C_NL
TextDef_Intro1: 
	dw $98E0
.c:	db $2E
.s: db " AS A YEAR FLEW-BY",C_NL,C_NL,"  FROM",C_NL,C_NL,"  THE EXCITEMENT,",C_NL
TextDef_Intro2: 
	dw $98C0
.c:	db $45
.s: db " WE NOW DECLARE THE",C_NL,C_NL,"  OPENING OF OUR",C_NL,C_NL,"  SPECIAL TEAM",C_NL,C_NL,"  TOURNAMENT",C_NL,C_NL
TextDef_Intro3: 
	dw $9920
.c:	db $14
.s: db "       AGAIN....",C_NL,C_NL,C_NL,C_NL

OBJInfoInit_Intro_Iori:
	db OST_VISIBLE ; iOBJInfo_Status
	db $80 ; iOBJInfo_OBJLstFlags
	db $00 ; iOBJInfo_OBJLstFlagsView
	db $18 ; iOBJInfo_X
	db $00 ; iOBJInfo_XSub
	db $50 ; iOBJInfo_Y
	db $00 ; iOBJInfo_YSub
	db $00 ; iOBJInfo_SpeedX
	db $00 ; iOBJInfo_SpeedXSub
	db $00 ; iOBJInfo_SpeedY
	db $00 ; iOBJInfo_SpeedYSub
	db $00 ; iOBJInfo_RelX (auto)
	db $00 ; iOBJInfo_RelY (auto)
	db $C6 ; iOBJInfo_TileIDBase
	db LOW($8000) ; iOBJInfo_VRAMPtr_Low
	db HIGH($8000) ; iOBJInfo_VRAMPtr_High
	db BANK(OBJLstPtrTable_Intro_Iori) ; iOBJInfo_BankNum (BANK $1C)
	db LOW(OBJLstPtrTable_Intro_Iori) ; iOBJInfo_OBJLstPtrTbl_Low
	db HIGH(OBJLstPtrTable_Intro_Iori) ; iOBJInfo_OBJLstPtrTbl_High
	db $00 ; iOBJInfo_OBJLstPtrTblOffset
	db $00 ; iOBJInfo_BankNumView
	db LOW(OBJLstPtrTable_Intro_Iori) ; iOBJInfo_OBJLstPtrTbl_LowView
	db HIGH(OBJLstPtrTable_Intro_Iori) ; iOBJInfo_OBJLstPtrTbl_HighView
	db $00 ; iOBJInfo_OBJLstPtrTblOffset
	db $00 ; iOBJInfo_ColiBoxId (auto)
	db $00 ; iOBJInfo_HitboxId (auto)
	db $00 ; iOBJInfo_ForceHitboxId
	db $02 ; iOBJInfo_FrameLeft
	db $02 ; iOBJInfo_FrameTotal
	db LOW(wGFXBufInfo_Pl1) ; iOBJInfo_BufInfoPtr_Low
	db HIGH(wGFXBufInfo_Pl1) ; iOBJInfo_BufInfoPtr_High

INCLUDE "data/objlst/intro_iori.asm"
GFXLZ_IntroBG: INCBIN "data/gfx/intro_bg.lzc"
BGLZ_Intro_IoriCutout: INCBIN "data/bg/intro_ioricutout.lzs"
BGLZ_Intro_KyoCutout: INCBIN "data/bg/intro_kyocutout.lzs"
BGLZ_Intro_Sun: INCBIN "data/bg/intro_sun.lzs"
GFXLZ_Intro_IoriRiseOBJ: INCBIN "data/gfx/intro_ioririse_obj.lzc"
	mIncJunk "L1C6672"
	
IF ENGLISH == 0
TextC_Win_Marker:
TextC_Win_Kyo:
	db $2B
	db "なってねえ!", C_NL
	db C_NL
	db "おれとふﾞつかってそのていとﾞてﾞ", C_NL
	db C_NL
	db "すんたﾞのはきせきてきたﾞな。", C_NL
TextC_Win_Daimon:
	db $2A
	db "わさﾞはそれほとﾞ", C_NL
	db C_NL
	db "しﾞゅうようてﾞはない!", C_NL
	db C_NL
	db "すへﾞてはこころのもちようたﾞ!", C_NL
TextC_Win_Terry:
	db $28
	db "おれのなかにいるおおかみを", C_NL
	db C_NL
	db "おこしちまったようたﾞな。", C_NL
	db C_NL
	db "わるくおもうなよ!", C_NL
TextC_Win_Andy:
	db $20
	db "ひつようなのはかくこﾞ!", C_NL
	db C_NL
	db "そのいしさえあれはﾞまけはしない!", C_NL
TextC_Win_Ryo:
	db $38
	db "きょくけﾞんリゅうはきょくけﾞんに", C_NL
	db C_NL
	db "おいてのみはっするちからのけﾞい", C_NL
	db C_NL
	db "しﾞゅつたﾞ!やすやすとおちはしない", C_NL
TextC_Win_Robert:
	db $2A
	db "とﾞないした?", C_NL
	db C_NL
	db "かおかﾞゆめうつつっちゅうかんしﾞ", C_NL
	db C_NL
	db "やてﾞ。 しゃきっとせな!", C_NL
TextC_Win_Athena:
	db $25
	db "つきﾞかﾞあったならまたたたかい", C_NL
	db C_NL
	db "ましょう。", C_NL
	db C_NL
	db "たのしみにまってます!", C_NL
TextC_Win_Mai:
	db $36
	db "まあ、ほんきをちょっとたﾞせはﾞ", C_NL
	db C_NL
	db "かるいかるい! しらぬいリゅう", C_NL
	db C_NL
	db "にんしﾞゅつ、さいきょうってとこね!", C_NL
TextC_Win_Leona:
	db $1E
	db "あなたはしなないわ。", C_NL
	db C_NL
	db "ここはせんしﾞょうしﾞゃないもの。", C_NL
TextC_Win_Geese:
	db $30
	db "あっとうてきなちからにしはいされる", C_NL
	db C_NL
	db "のは、とﾞんなきもちたﾞ!", C_NL
	db C_NL
	db "さあ! おそれるかﾞいい!", C_NL
TextC_Win_Krauser:
	db $33
	db "わたしをたおせるならせかいさいきょう", C_NL
	db C_NL
	db "はまちかﾞいないたﾞろう!", C_NL
	db C_NL
	db "かてれはﾞのはなしたﾞかﾞな!", C_NL
TextC_Win_MrBig:
	db $26
	db "ヒｰロｰにてﾞも、なったつもリか!", C_NL
	db C_NL
	db "おかしくてなみたﾞかﾞとまらんそﾞ!", C_NL
TextC_Win_Iori:
	db $2E
	db "はﾞかにつけるくすリはないというかﾞ", C_NL
	db C_NL
	db "まるてﾞおまえたちのことを", C_NL
	db C_NL
	db "いっているようたﾞ!", C_NL
TextC_Win_Mature:
	db $2F
	db "あなたたちもゆめをみるてﾞしょ。", C_NL
	db C_NL
	db "さあえいえんのゆめのせかいにあんない", C_NL
	db C_NL
	db "してあけﾞるわ!", C_NL
TextC_Win_Chizuru:
	db $30
	db "あなたたちはほんとうのちからかﾞ", C_NL
	db C_NL
	db "なにかをしらないようね。", C_NL
	db C_NL
	db "それてﾞはわたしはたおせない。", C_NL
TextC_Win_Goenitz:
	db $32
	db "せかいかﾞそﾞうおのなかてﾞもえてい", C_NL
	db C_NL
	db "ます。 しんのこんとんはおさめる", C_NL
	db C_NL
	db "ことはふかのうてﾞす。", C_NL
TextC_Win_MrKarate:
	db $24
	db "なんとﾞてﾞもいおう!", C_NL
	db C_NL
	db "わかﾞきょくけﾞんリゅうに", C_NL
	db C_NL
	db "てきはいない。", C_NL
TextC_Win_OIori:
	db $0C
	db "くﾞうおおおううう!!", C_NL
TextC_Win_OLeona:
	db $0B
	db "・・・・・・・・・・", C_NL
TextC_Win_Kagura:
	db $34
	db "なにこﾞとにもせﾞんリょくてﾞ", C_NL
	db C_NL
	db "いとﾞむ! それかﾞいつかしょうリ", C_NL
	db C_NL
	db "するきほﾞうにつなかﾞるのよ。", C_NL
TextC_CutsceneKagura0:
	db $20
	db "おめてﾞとうこﾞさﾞいます。", C_NL
	db C_NL
	db "すはﾞらしいしあいてﾞしたわ。", C_NL
TextC_CutsceneKagura1:
	db $27
	db "わたしのなは、かくﾞらちつﾞる・・・", C_NL
	db C_NL
	db "こんたいかいをしゅさいしたものてﾞす", C_NL
TextC_CutsceneKagura2:
	db $28
	db "RUGALをたおしたそのちから", C_NL
	db C_NL
	db "のほとﾞはいけんしたかった", C_NL
	db C_NL
	db "のてﾞすかﾞ。", C_NL
TextC_CutsceneKagura3:
	db $18
	db "あなたたちのほんとうのちからかﾞ", C_NL
	db C_NL
	db "みたいわ。", C_NL
TextC_CutsceneKagura4:
	db $2F
	db "トｰナメントてﾞみせたのかﾞ", C_NL
	db C_NL
	db "しﾞつリょくというのなら", C_NL
	db C_NL
	db "はなしはへﾞつたﾞけとﾞ・・・。", C_NL
TextC_CutsceneGoenitz00:
	db $0F
	db "なせﾞRUGALのことを!?", C_NL
TextC_CutsceneGoenitz01:
	db $22
	db "RUGALかﾞてにいれようとして", C_NL
	db C_NL
	db "てﾞきなかったオロチのちから。", C_NL
TextC_CutsceneGoenitz02:
	db $1C
	db "ふうしﾞられし、そのちからを", C_NL
	db C_NL
	db "わたしはまもってきた。", C_NL
TextC_CutsceneGoenitz03:
	db $12
	db "それをRUGALかﾞかいほうした?", C_NL
TextC_CutsceneGoenitz04:
	db $24
	db "RUGALは、かいほうされたちからを", C_NL
	db C_NL
	db "よこからうはﾞいとったたﾞけ。", C_NL
TextC_CutsceneGoenitz05:
	db $1F
	db "それと、あなたとたたかったことと", C_NL
	db C_NL
	db "とﾞういうかんけいかﾞ?", C_NL
TextC_CutsceneGoenitz06:
	db $21
	db "あなたたちのしﾞつリょくをみるために", C_NL
	db C_NL
	db "ト-ナメントをひらいた。", C_NL
TextC_CutsceneGoenitz07:
	db $08
	db "なんのために?", C_NL
TextC_CutsceneGoenitz08:
	db $31
	db "オロチのちからをふうしﾞるのに、", C_NL
	db C_NL
	db "あなたのちからをかしてほしいのよ。", C_NL
	db C_NL
	db "しﾞかんはもうないわ。", C_NL
TextC_CutsceneGoenitz09:
	db $1C
	db "けはいてﾞわかるの。", C_NL
	db C_NL
	db "もうそこまてﾞきている・・・。", C_NL
TextC_CutsceneGoenitz0A:
	db $06
	db "きている?", C_NL
TextC_CutsceneGoenitz0B:
	db $23
	db "そう・・・。ふうしﾞられていた", C_NL
	db C_NL
	db "オロチをかいほうしたおとこ・・・。", C_NL
TextC_CutsceneGoenitz0C:
	db $10
	db "な、なに!?  かせﾞかﾞ!?", C_NL
TextC_CutsceneGoenitz0D:
	db $06
	db "うわあｰ!", C_NL
TextC_CutsceneGoenitz0E:
	db $27
	db "さすかﾞてﾞすね。これくﾞらいてﾞは", C_NL
	db C_NL
	db "とﾞうということはあリませんか・・・", C_NL
TextC_CutsceneGoenitz0F:
	db $05
	db "たﾞれ?", C_NL
TextC_CutsceneGoenitz10:
	db $19
	db "はしﾞめまして。", C_NL
	db C_NL
	db "GOENITZともうします.", C_NL
TextC_CutsceneGoenitz11:
	db $2A
	db "いままてﾞのことは、はいけんさせて", C_NL
	db C_NL
	db "いたたﾞきました。", C_NL
	db C_NL
	db "しかし、むたﾞてﾞす。", C_NL
TextC_CutsceneGoenitz12:
	db $26
	db "あなたたちにはなにもてﾞきません。", C_NL
	db C_NL
	db "とくへﾞつにせんたくしをあけﾞます。", C_NL
TextC_CutsceneGoenitz13:
	db $17
	db "たたかわすﾞにしぬか、", C_NL
	db C_NL
	db "たたかってしぬか。", C_NL
TextC_CutsceneGoenitz14:
	db $16
	db "とﾞちらてﾞもない!", C_NL
	db C_NL
	db "たたかってかつ!!", C_NL
TextC_Ending_Generic0:
	db $17
	db "おとﾞろきてﾞすね。", C_NL
	db C_NL
	db "これほとﾞとは・・・", C_NL
TextC_Ending_Generic1:
	db $2F
	db "しかし、あなたかﾞたのててﾞオロチを", C_NL
	db C_NL
	db "ふうしﾞようなとﾞとはかんかﾞえない", C_NL
	db C_NL
	db "ことてﾞす。", C_NL
TextC_Ending_Generic2:
	db $11
	db "てをひくことをおすすめしますよ。", C_NL
TextC_Ending_Generic3:
	db $16
	db "ふうしﾞてみせるわ。", C_NL
	db C_NL
	db "かならすﾞ・・・。", C_NL
TextC_Ending_Generic4:
	db $2A
	db "かちきなおかたたﾞ・・・。", C_NL
	db C_NL
	db "いいかせﾞかﾞきました。", C_NL
	db C_NL
	db "そろそろころあいてﾞす。", C_NL
TextC_Ending_Generic5:
	db $07
	db "にけﾞる!?", C_NL
TextC_Ending_GoenitzLeave0:
	db $0D
	db "いえ、めされるのてﾞす。", C_NL
TextC_Ending_GoenitzLeave2:
	db $09
	db "・・・てん へ。", C_NL
TextC_CutsceneGoenitz0C_Easy:
	db $26
	db "このくﾞらいのしﾞつリょくてﾞは、", C_NL
	db C_NL
	db "わたしかﾞてﾞるまてﾞもあリません。", C_NL
TextC_CutsceneGoenitz0D_Easy:
	db $1C
	db "NORMALいしﾞょうてﾞ", C_NL
	db C_NL
	db "おあいしましょう・・・。", C_NL
TextC_Ending_GoenitzLeave1:
	db $15
	db "                    ", C_NL
TextC_Ending_KaguraGeneric0:
	db $27
	db "みなさん、あリかﾞとう。", C_NL
	db C_NL
	db "これてﾞあのおとこのけﾞんそうも", C_NL
	db C_NL
	db "きえました。", C_NL
TextC_Ending_KaguraGeneric1:
	db $3A
	db "てﾞも、くらやみてﾞうこﾞめくもの", C_NL
	db C_NL
	db "とﾞもは、いつ、ひとひﾞとをそのやみ", C_NL
	db C_NL
	db "につつみこもうとするかわかリません。", C_NL
TextC_Ending_KaguraGeneric2:
	db $32
	db "それは、ちかいしょうらい、おとすﾞ", C_NL
	db C_NL
	db "れるかも・・・。  そのときは、", C_NL
	db C_NL
	db "また、おあいしましょう。", C_NL
TextC_CheatList:
	db $3E
	db "TAKARAロコﾞのひょうしﾞ", C_NL
	db C_NL
	db "ちゅうにSELECTホﾞタンを", C_NL
	db C_NL
	db "3かいおすと、", C_NL
	db C_NL
	db "GOENITZかﾞしようてﾞきます。", C_NL
ELSE

TextC_Win_Marker:

; TODO: TextC_
TextC_Win_Kyo: db $38
L1C6674: db $59
L1C6675: db $6F
L1C6676: db $75
L1C6677: db $20
L1C6678: db $77
L1C6679: db $65
L1C667A: db $72
L1C667B: db $65
L1C667C: db $20
L1C667D: db $6C
L1C667E: db $75
L1C667F: db $63
L1C6680: db $6B
L1C6681: db $79
L1C6682: db $20
L1C6683: db $74
L1C6684: db $6F
L1C6685: db $FF
L1C6686: db $20
L1C6687: db $74
L1C6688: db $61
L1C6689: db $6B
L1C668A: db $65
L1C668B: db $20
L1C668C: db $6D
L1C668D: db $65
L1C668E: db $20 ; M
L1C668F: db $6F
L1C6690: db $6E
L1C6691: db $20
L1C6692: db $61
L1C6693: db $6E
L1C6694: db $64
L1C6695: db $20
L1C6696: db $67
L1C6697: db $65
L1C6698: db $74
L1C6699: db $FF
L1C669A: db $20
L1C669B: db $6F
L1C669C: db $66
L1C669D: db $66
L1C669E: db $20
L1C669F: db $74
L1C66A0: db $68
L1C66A1: db $69
L1C66A2: db $73
L1C66A3: db $20
L1C66A4: db $65
L1C66A5: db $61
L1C66A6: db $73
L1C66A7: db $69
L1C66A8: db $6C
L1C66A9: db $79
L1C66AA: db $2E
L1C66AB: db $FF
TextC_Win_Daimon: db $40
L1C66AD: db $4D
L1C66AE: db $6F
L1C66AF: db $76
L1C66B0: db $65
L1C66B1: db $73
L1C66B2: db $20
L1C66B3: db $61
L1C66B4: db $72
L1C66B5: db $65
L1C66B6: db $6E
L1C66B7: db $60
L1C66B8: db $74
L1C66B9: db $20
L1C66BA: db $74
L1C66BB: db $68
L1C66BC: db $61
L1C66BD: db $74
L1C66BE: db $FF
L1C66BF: db $20
L1C66C0: db $69
L1C66C1: db $6D
L1C66C2: db $70
L1C66C3: db $6F
L1C66C4: db $72
L1C66C5: db $74
L1C66C6: db $61
L1C66C7: db $6E
L1C66C8: db $74
L1C66C9: db $2E
L1C66CA: db $20
L1C66CB: db $49
L1C66CC: db $74
L1C66CD: db $60
L1C66CE: db $73 ; M
L1C66CF: db $FF
L1C66D0: db $20
L1C66D1: db $79
L1C66D2: db $6F
L1C66D3: db $75
L1C66D4: db $72
L1C66D5: db $20
L1C66D6: db $61
L1C66D7: db $74
L1C66D8: db $74
L1C66D9: db $69
L1C66DA: db $74
L1C66DB: db $75
L1C66DC: db $64
L1C66DD: db $65
L1C66DE: db $20
L1C66DF: db $74
L1C66E0: db $68
L1C66E1: db $61
L1C66E2: db $74
L1C66E3: db $FF
L1C66E4: db $20
L1C66E5: db $63
L1C66E6: db $6F
L1C66E7: db $75
L1C66E8: db $6E
L1C66E9: db $74
L1C66EA: db $73 ; M
L1C66EB: db $2E
L1C66EC: db $FF
TextC_Win_Terry: db $38
L1C66EE: db $44
L1C66EF: db $6F
L1C66F0: db $6E ; M
L1C66F1: db $60
L1C66F2: db $74
L1C66F3: db $20
L1C66F4: db $74
L1C66F5: db $61
L1C66F6: db $6B
L1C66F7: db $65
L1C66F8: db $20 ; M
L1C66F9: db $69
L1C66FA: db $74 ; M
L1C66FB: db $20
L1C66FC: db $74
L1C66FD: db $6F
L1C66FE: db $6F ; M
L1C66FF: db $FF ; M
L1C6700: db $20
L1C6701: db $68
L1C6702: db $61
L1C6703: db $72
L1C6704: db $64
L1C6705: db $20
L1C6706: db $2D
L1C6707: db $20
L1C6708: db $79
L1C6709: db $6F
L1C670A: db $75 ; M
L1C670B: db $20 ; M
L1C670C: db $61
L1C670D: db $77
L1C670E: db $61
L1C670F: db $6B
L1C6710: db $65
L1C6711: db $6E
L1C6712: db $65
L1C6713: db $64
L1C6714: db $FF ; M
L1C6715: db $20 ; M
L1C6716: db $74
L1C6717: db $68
L1C6718: db $65
L1C6719: db $20
L1C671A: db $77
L1C671B: db $6F
L1C671C: db $6C
L1C671D: db $66
L1C671E: db $20
L1C671F: db $69
L1C6720: db $6E
L1C6721: db $20
L1C6722: db $6D
L1C6723: db $65
L1C6724: db $2E
L1C6725: db $FF
TextC_Win_Andy: db $4C
L1C6727: db $49
L1C6728: db $46
L1C6729: db $20
L1C672A: db $79
L1C672B: db $6F
L1C672C: db $75
L1C672D: db $60
L1C672E: db $72
L1C672F: db $65 ; M
L1C6730: db $20
L1C6731: db $74
L1C6732: db $6F
L1C6733: db $74 ; M
L1C6734: db $61 ; M
L1C6735: db $6C
L1C6736: db $6C
L1C6737: db $79
L1C6738: db $FF ; M
L1C6739: db $20
L1C673A: db $66
L1C673B: db $6F
L1C673C: db $63
L1C673D: db $75
L1C673E: db $73
L1C673F: db $65
L1C6740: db $64
L1C6741: db $20
L1C6742: db $61
L1C6743: db $6E
L1C6744: db $64
L1C6745: db $FF
L1C6746: db $20
L1C6747: db $64
L1C6748: db $65
L1C6749: db $74 ; M
L1C674A: db $65
L1C674B: db $72 ; M
L1C674C: db $6D
L1C674D: db $69
L1C674E: db $6E
L1C674F: db $65
L1C6750: db $64
L1C6751: db $20
L1C6752: db $74
L1C6753: db $6F
L1C6754: db $20 ; M
L1C6755: db $77
L1C6756: db $69
L1C6757: db $6E
L1C6758: db $2C
L1C6759: db $FF
L1C675A: db $20
L1C675B: db $76
L1C675C: db $69
L1C675D: db $63
L1C675E: db $74
L1C675F: db $6F
L1C6760: db $72
L1C6761: db $79
L1C6762: db $20
L1C6763: db $77
L1C6764: db $69
L1C6765: db $6C
L1C6766: db $6C
L1C6767: db $20
L1C6768: db $62
L1C6769: db $65 ; M
L1C676A: db $FF ; M
L1C676B: db $20
L1C676C: db $79
L1C676D: db $6F
L1C676E: db $75 ; M
L1C676F: db $72
L1C6770: db $73
L1C6771: db $21 ; M
L1C6772: db $FF
TextC_Win_Ryo: db $50
L1C6774: db $4B
L1C6775: db $79
L1C6776: db $6F
L1C6777: db $6B
L1C6778: db $75
L1C6779: db $67
L1C677A: db $65
L1C677B: db $6E
L1C677C: db $20
L1C677D: db $6B
L1C677E: db $61
L1C677F: db $72
L1C6780: db $61
L1C6781: db $74
L1C6782: db $65 ; M
L1C6783: db $20
L1C6784: db $69
L1C6785: db $73
L1C6786: db $FF
L1C6787: db $20
L1C6788: db $74
L1C6789: db $68 ; M
L1C678A: db $65
L1C678B: db $20 ; M
L1C678C: db $61
L1C678D: db $72
L1C678E: db $74
L1C678F: db $20
L1C6790: db $6F
L1C6791: db $66
L1C6792: db $20 ; M
L1C6793: db $75
L1C6794: db $6C
L1C6795: db $74
L1C6796: db $69
L1C6797: db $6D
L1C6798: db $61
L1C6799: db $74
L1C679A: db $65
L1C679B: db $FF
L1C679C: db $20
L1C679D: db $70
L1C679E: db $6F
L1C679F: db $77
L1C67A0: db $65
L1C67A1: db $72 ; M
L1C67A2: db $21
L1C67A3: db $FF
L1C67A4: db $59
L1C67A5: db $6F
L1C67A6: db $75 ; M
L1C67A7: db $20
L1C67A8: db $63
L1C67A9: db $61
L1C67AA: db $6E
L1C67AB: db $60
L1C67AC: db $74 ; M
L1C67AD: db $20
L1C67AE: db $62
L1C67AF: db $65
L1C67B0: db $61
L1C67B1: db $74
L1C67B2: db $20
L1C67B3: db $69
L1C67B4: db $74
L1C67B5: db $FF
L1C67B6: db $20
L1C67B7: db $74
L1C67B8: db $68
L1C67B9: db $61
L1C67BA: db $74
L1C67BB: db $20
L1C67BC: db $65
L1C67BD: db $61
L1C67BE: db $73
L1C67BF: db $69
L1C67C0: db $6C
L1C67C1: db $79
L1C67C2: db $21
L1C67C3: db $FF
TextC_Win_Robert: db $35
L1C67C5: db $48
L1C67C6: db $65
L1C67C7: db $79 ; M
L1C67C8: db $2C
L1C67C9: db $61
L1C67CA: db $72
L1C67CB: db $65 ; M
L1C67CC: db $20
L1C67CD: db $79
L1C67CE: db $6F
L1C67CF: db $75
L1C67D0: db $FF
L1C67D1: db $20
L1C67D2: db $64
L1C67D3: db $61
L1C67D4: db $79
L1C67D5: db $2D
L1C67D6: db $64
L1C67D7: db $72
L1C67D8: db $65
L1C67D9: db $61
L1C67DA: db $6D
L1C67DB: db $69 ; M
L1C67DC: db $6E
L1C67DD: db $67
L1C67DE: db $20
L1C67DF: db $6F
L1C67E0: db $72
L1C67E1: db $FF
L1C67E2: db $20
L1C67E3: db $74
L1C67E4: db $68
L1C67E5: db $61
L1C67E6: db $74 ; M
L1C67E7: db $3F
L1C67E8: db $20
L1C67E9: db $FF
L1C67EA: db $53
L1C67EB: db $6E
L1C67EC: db $61
L1C67ED: db $70
L1C67EE: db $20 ; M
L1C67EF: db $6F
L1C67F0: db $75
L1C67F1: db $74
L1C67F2: db $20
L1C67F3: db $6F
L1C67F4: db $66
L1C67F5: db $20
L1C67F6: db $69
L1C67F7: db $74
L1C67F8: db $21
L1C67F9: db $FF
TextC_Win_Athena: db $46
L1C67FB: db $4C
L1C67FC: db $65
L1C67FD: db $74 ; M
L1C67FE: db $60
L1C67FF: db $73
L1C6800: db $20 ; M
L1C6801: db $66
L1C6802: db $69
L1C6803: db $67
L1C6804: db $68
L1C6805: db $74
L1C6806: db $20
L1C6807: db $61
L1C6808: db $67
L1C6809: db $61 ; M
L1C680A: db $69
L1C680B: db $6E
L1C680C: db $20 ; M
L1C680D: db $69
L1C680E: db $66 ; M
L1C680F: db $FF
L1C6810: db $20
L1C6811: db $77
L1C6812: db $65
L1C6813: db $20
L1C6814: db $68
L1C6815: db $61
L1C6816: db $76
L1C6817: db $65
L1C6818: db $20
L1C6819: db $74
L1C681A: db $68
L1C681B: db $65
L1C681C: db $20
L1C681D: db $63
L1C681E: db $68
L1C681F: db $61
L1C6820: db $6E
L1C6821: db $63
L1C6822: db $65 ; M
L1C6823: db $2E
L1C6824: db $FF
L1C6825: db $49
L1C6826: db $60
L1C6827: db $6D
L1C6828: db $20
L1C6829: db $6C
L1C682A: db $6F
L1C682B: db $6F
L1C682C: db $6B ; M
L1C682D: db $69
L1C682E: db $6E
L1C682F: db $67
L1C6830: db $20
L1C6831: db $66
L1C6832: db $6F
L1C6833: db $72
L1C6834: db $77
L1C6835: db $61
L1C6836: db $72
L1C6837: db $64 ; M
L1C6838: db $FF
L1C6839: db $20
L1C683A: db $74
L1C683B: db $6F
L1C683C: db $20
L1C683D: db $69
L1C683E: db $74
L1C683F: db $21
L1C6840: db $FF
TextC_Win_Mai: db $31
L1C6842: db $57
L1C6843: db $68
L1C6844: db $65
L1C6845: db $6E
L1C6846: db $20
L1C6847: db $49
L1C6848: db $20
L1C6849: db $70
L1C684A: db $75
L1C684B: db $74
L1C684C: db $20
L1C684D: db $6D
L1C684E: db $79
L1C684F: db $20 ; M
L1C6850: db $6D
L1C6851: db $69
L1C6852: db $6E
L1C6853: db $64
L1C6854: db $FF
L1C6855: db $20
L1C6856: db $74
L1C6857: db $6F
L1C6858: db $20 ; M
L1C6859: db $69
L1C685A: db $74
L1C685B: db $20
L1C685C: db $69
L1C685D: db $74
L1C685E: db $60
L1C685F: db $73 ; M
L1C6860: db $20 ; M
L1C6861: db $61
L1C6862: db $20
L1C6863: db $70
L1C6864: db $69
L1C6865: db $65
L1C6866: db $63
L1C6867: db $65
L1C6868: db $FF ; M
L1C6869: db $20 ; M
L1C686A: db $6F
L1C686B: db $66
L1C686C: db $20
L1C686D: db $63
L1C686E: db $61
L1C686F: db $6B
L1C6870: db $65
L1C6871: db $21
L1C6872: db $FF
TextC_Win_Leona: db $35
L1C6874: db $59
L1C6875: db $6F
L1C6876: db $75
L1C6877: db $20 ; M
L1C6878: db $77
L1C6879: db $69
L1C687A: db $6C
L1C687B: db $6C
L1C687C: db $20
L1C687D: db $6E
L1C687E: db $6F
L1C687F: db $74
L1C6880: db $20
L1C6881: db $64
L1C6882: db $69
L1C6883: db $65
L1C6884: db $2E
L1C6885: db $FF
L1C6886: db $54
L1C6887: db $68
L1C6888: db $69
L1C6889: db $73 ; M
L1C688A: db $20
L1C688B: db $69
L1C688C: db $73
L1C688D: db $20
L1C688E: db $6E
L1C688F: db $6F
L1C6890: db $74
L1C6891: db $20 ; M
L1C6892: db $61
L1C6893: db $FF
L1C6894: db $20
L1C6895: db $20
L1C6896: db $20 ; M
L1C6897: db $20
L1C6898: db $20 ; M
L1C6899: db $20
L1C689A: db $20
L1C689B: db $20
L1C689C: db $62
L1C689D: db $61
L1C689E: db $74
L1C689F: db $74
L1C68A0: db $6C
L1C68A1: db $65
L1C68A2: db $66
L1C68A3: db $69
L1C68A4: db $65
L1C68A5: db $6C
L1C68A6: db $64
L1C68A7: db $2E ; M
L1C68A8: db $FF
TextC_Win_Geese: db $58
L1C68AA: db $48
L1C68AB: db $6F
L1C68AC: db $77
L1C68AD: db $20
L1C68AE: db $64
L1C68AF: db $6F ; M
L1C68B0: db $65
L1C68B1: db $73
L1C68B2: db $20
L1C68B3: db $69
L1C68B4: db $74
L1C68B5: db $20
L1C68B6: db $66
L1C68B7: db $65
L1C68B8: db $65 ; M
L1C68B9: db $6C
L1C68BA: db $20 ; M
L1C68BB: db $74
L1C68BC: db $6F ; M
L1C68BD: db $FF
L1C68BE: db $20 ; M
L1C68BF: db $62
L1C68C0: db $65
L1C68C1: db $20
L1C68C2: db $72
L1C68C3: db $75 ; M
L1C68C4: db $6C
L1C68C5: db $65
L1C68C6: db $64 ; M
L1C68C7: db $20
L1C68C8: db $62
L1C68C9: db $79
L1C68CA: db $FF
L1C68CB: db $20 ; M
L1C68CC: db $75
L1C68CD: db $6C
L1C68CE: db $74
L1C68CF: db $69
L1C68D0: db $6D
L1C68D1: db $61 ; M
L1C68D2: db $74
L1C68D3: db $65
L1C68D4: db $20 ; M
L1C68D5: db $70
L1C68D6: db $6F
L1C68D7: db $77
L1C68D8: db $65
L1C68D9: db $72
L1C68DA: db $21 ; M
L1C68DB: db $FF
L1C68DC: db $42
L1C68DD: db $65
L1C68DE: db $20
L1C68DF: db $61
L1C68E0: db $66
L1C68E1: db $72
L1C68E2: db $61
L1C68E3: db $69
L1C68E4: db $64
L1C68E5: db $20
L1C68E6: db $2D
L1C68E7: db $20
L1C68E8: db $76
L1C68E9: db $65
L1C68EA: db $72
L1C68EB: db $79
L1C68EC: db $FF ; M
L1C68ED: db $20
L1C68EE: db $20
L1C68EF: db $20
L1C68F0: db $20
L1C68F1: db $20
L1C68F2: db $20
L1C68F3: db $20
L1C68F4: db $20
L1C68F5: db $20 ; M
L1C68F6: db $20
L1C68F7: db $20
L1C68F8: db $20
L1C68F9: db $20
L1C68FA: db $61
L1C68FB: db $66
L1C68FC: db $72
L1C68FD: db $61 ; M
L1C68FE: db $69
L1C68FF: db $64
L1C6900: db $21
L1C6901: db $FF
TextC_Win_Krauser: db $57
L1C6903: db $44
L1C6904: db $65
L1C6905: db $66
L1C6906: db $65
L1C6907: db $61
L1C6908: db $74
L1C6909: db $69
L1C690A: db $6E
L1C690B: db $67
L1C690C: db $20
L1C690D: db $6D
L1C690E: db $65
L1C690F: db $20 ; M
L1C6910: db $77
L1C6911: db $6F ; M
L1C6912: db $75
L1C6913: db $6C ; M
L1C6914: db $64 ; M
L1C6915: db $FF ; M
L1C6916: db $20
L1C6917: db $6D
L1C6918: db $61
L1C6919: db $6B ; M
L1C691A: db $65
L1C691B: db $20
L1C691C: db $79
L1C691D: db $6F ; M
L1C691E: db $75
L1C691F: db $20
L1C6920: db $74
L1C6921: db $68
L1C6922: db $65 ; M
L1C6923: db $FF
L1C6924: db $20
L1C6925: db $73
L1C6926: db $74
L1C6927: db $72
L1C6928: db $6F
L1C6929: db $6E
L1C692A: db $67
L1C692B: db $65 ; M
L1C692C: db $73
L1C692D: db $74
L1C692E: db $20
L1C692F: db $69
L1C6930: db $6E ; M
L1C6931: db $20
L1C6932: db $74
L1C6933: db $68
L1C6934: db $65
L1C6935: db $FF ; M
L1C6936: db $20
L1C6937: db $77
L1C6938: db $6F
L1C6939: db $72
L1C693A: db $6C
L1C693B: db $64
L1C693C: db $20
L1C693D: db $2D
L1C693E: db $20
L1C693F: db $62
L1C6940: db $75
L1C6941: db $74 ; M
L1C6942: db $20 ; M
L1C6943: db $69
L1C6944: db $74
L1C6945: db $FF
L1C6946: db $20 ; M
L1C6947: db $69
L1C6948: db $73
L1C6949: db $6E
L1C694A: db $60
L1C694B: db $74
L1C694C: db $20
L1C694D: db $65
L1C694E: db $61
L1C694F: db $73
L1C6950: db $79
L1C6951: db $20
L1C6952: db $74
L1C6953: db $6F
L1C6954: db $20
L1C6955: db $64
L1C6956: db $6F
L1C6957: db $20
L1C6958: db $21
L1C6959: db $FF
TextC_Win_MrBig: db $61
L1C695B: db $53
L1C695C: db $6F ; M
L1C695D: db $20
L1C695E: db $79
L1C695F: db $6F ; M
L1C6960: db $75
L1C6961: db $20
L1C6962: db $77
L1C6963: db $65
L1C6964: db $72
L1C6965: db $65
L1C6966: db $20
L1C6967: db $70
L1C6968: db $6C
L1C6969: db $61
L1C696A: db $6E
L1C696B: db $6E ; M
L1C696C: db $69
L1C696D: db $6E
L1C696E: db $67
L1C696F: db $FF
L1C6970: db $20
L1C6971: db $6F
L1C6972: db $6E
L1C6973: db $20
L1C6974: db $62
L1C6975: db $65
L1C6976: db $63
L1C6977: db $6F
L1C6978: db $6D
L1C6979: db $69
L1C697A: db $6E ; M
L1C697B: db $67 ; M
L1C697C: db $20
L1C697D: db $61
L1C697E: db $20
L1C697F: db $68
L1C6980: db $65
L1C6981: db $72
L1C6982: db $6F
L1C6983: db $3F
L1C6984: db $FF
L1C6985: db $54 ; M
L1C6986: db $68
L1C6987: db $61
L1C6988: db $74 ; M
L1C6989: db $60
L1C698A: db $73
L1C698B: db $20
L1C698C: db $73
L1C698D: db $6F
L1C698E: db $20
L1C698F: db $66
L1C6990: db $75
L1C6991: db $6E
L1C6992: db $6E
L1C6993: db $79
L1C6994: db $20
L1C6995: db $69
L1C6996: db $74 ; M
L1C6997: db $FF
L1C6998: db $20
L1C6999: db $6D
L1C699A: db $61
L1C699B: db $6B
L1C699C: db $65
L1C699D: db $73
L1C699E: db $20
L1C699F: db $6D
L1C69A0: db $65
L1C69A1: db $20
L1C69A2: db $77
L1C69A3: db $61
L1C69A4: db $6E
L1C69A5: db $74
L1C69A6: db $FF
L1C69A7: db $20 ; M
L1C69A8: db $20
L1C69A9: db $20
L1C69AA: db $20
L1C69AB: db $20
L1C69AC: db $20
L1C69AD: db $20 ; M
L1C69AE: db $20
L1C69AF: db $20 ; M
L1C69B0: db $20
L1C69B1: db $20 ; M
L1C69B2: db $20
L1C69B3: db $20 ; M
L1C69B4: db $74
L1C69B5: db $6F
L1C69B6: db $20
L1C69B7: db $63
L1C69B8: db $72
L1C69B9: db $79
L1C69BA: db $21 ; M
L1C69BB: db $FF
TextC_Win_Iori: db $3C
L1C69BD: db $54
L1C69BE: db $68
L1C69BF: db $65
L1C69C0: db $72
L1C69C1: db $65
L1C69C2: db $60
L1C69C3: db $73
L1C69C4: db $20
L1C69C5: db $6E
L1C69C6: db $6F
L1C69C7: db $20 ; M
L1C69C8: db $63
L1C69C9: db $75 ; M
L1C69CA: db $72
L1C69CB: db $65 ; M
L1C69CC: db $20
L1C69CD: db $66
L1C69CE: db $6F
L1C69CF: db $72 ; M
L1C69D0: db $FF
L1C69D1: db $20 ; M
L1C69D2: db $61
L1C69D3: db $20 ; M
L1C69D4: db $66
L1C69D5: db $6F
L1C69D6: db $6F
L1C69D7: db $6C ; M
L1C69D8: db $2E ; M
L1C69D9: db $FF
L1C69DA: db $41 ; M
L1C69DB: db $20
L1C69DC: db $70
L1C69DD: db $65
L1C69DE: db $72
L1C69DF: db $66 ; M
L1C69E0: db $65
L1C69E1: db $63 ; M
L1C69E2: db $74
L1C69E3: db $FF
L1C69E4: db $20
L1C69E5: db $64
L1C69E6: db $65
L1C69E7: db $73
L1C69E8: db $63 ; M
L1C69E9: db $72
L1C69EA: db $69
L1C69EB: db $70
L1C69EC: db $74
L1C69ED: db $69
L1C69EE: db $6F
L1C69EF: db $6E
L1C69F0: db $20
L1C69F1: db $6F
L1C69F2: db $66
L1C69F3: db $20
L1C69F4: db $79
L1C69F5: db $6F
L1C69F6: db $75 ; M
L1C69F7: db $21
L1C69F8: db $FF
TextC_Win_Mature: db $5D
L1C69FA: db $59
L1C69FB: db $6F
L1C69FC: db $75
L1C69FD: db $20
L1C69FE: db $68
L1C69FF: db $61 ; M
L1C6A00: db $76 ; M
L1C6A01: db $65
L1C6A02: db $20
L1C6A03: db $64
L1C6A04: db $72
L1C6A05: db $65
L1C6A06: db $61
L1C6A07: db $6D ; M
L1C6A08: db $73
L1C6A09: db $20
L1C6A0A: db $74
L1C6A0B: db $6F
L1C6A0C: db $6F
L1C6A0D: db $2C ; M
L1C6A0E: db $FF
L1C6A0F: db $20
L1C6A10: db $64
L1C6A11: db $6F
L1C6A12: db $20
L1C6A13: db $79
L1C6A14: db $6F
L1C6A15: db $75
L1C6A16: db $20
L1C6A17: db $6E
L1C6A18: db $6F
L1C6A19: db $74
L1C6A1A: db $3F ; M
L1C6A1B: db $FF ; M
L1C6A1C: db $4C
L1C6A1D: db $65
L1C6A1E: db $74
L1C6A1F: db $20
L1C6A20: db $6D
L1C6A21: db $65
L1C6A22: db $20
L1C6A23: db $67
L1C6A24: db $75
L1C6A25: db $69
L1C6A26: db $64
L1C6A27: db $65
L1C6A28: db $20
L1C6A29: db $79
L1C6A2A: db $6F
L1C6A2B: db $75
L1C6A2C: db $20 ; M
L1C6A2D: db $6E
L1C6A2E: db $6F
L1C6A2F: db $77
L1C6A30: db $FF
L1C6A31: db $20
L1C6A32: db $74
L1C6A33: db $6F
L1C6A34: db $20 ; M
L1C6A35: db $74
L1C6A36: db $68
L1C6A37: db $65
L1C6A38: db $20
L1C6A39: db $6C
L1C6A3A: db $61
L1C6A3B: db $6E ; M
L1C6A3C: db $64
L1C6A3D: db $20
L1C6A3E: db $6F
L1C6A3F: db $66
L1C6A40: db $20
L1C6A41: db $FF
L1C6A42: db $20
L1C6A43: db $20
L1C6A44: db $20
L1C6A45: db $20
L1C6A46: db $20
L1C6A47: db $65
L1C6A48: db $74
L1C6A49: db $65
L1C6A4A: db $72 ; M
L1C6A4B: db $6E
L1C6A4C: db $61
L1C6A4D: db $6C ; M
L1C6A4E: db $20
L1C6A4F: db $64
L1C6A50: db $72
L1C6A51: db $65
L1C6A52: db $61
L1C6A53: db $6D
L1C6A54: db $73
L1C6A55: db $21
L1C6A56: db $FF
TextC_Win_Chizuru: db $51
L1C6A58: db $59
L1C6A59: db $6F
L1C6A5A: db $75
L1C6A5B: db $20
L1C6A5C: db $64
L1C6A5D: db $6F
L1C6A5E: db $20
L1C6A5F: db $6E
L1C6A60: db $6F
L1C6A61: db $74 ; M
L1C6A62: db $20
L1C6A63: db $73
L1C6A64: db $65 ; M
L1C6A65: db $65
L1C6A66: db $6D ; M
L1C6A67: db $20 ; M
L1C6A68: db $74
L1C6A69: db $6F
L1C6A6A: db $FF
L1C6A6B: db $20
L1C6A6C: db $6B
L1C6A6D: db $6E
L1C6A6E: db $6F ; M
L1C6A6F: db $77
L1C6A70: db $20
L1C6A71: db $77
L1C6A72: db $68
L1C6A73: db $61
L1C6A74: db $74
L1C6A75: db $20 ; M
L1C6A76: db $72
L1C6A77: db $65
L1C6A78: db $61
L1C6A79: db $6C
L1C6A7A: db $FF
L1C6A7B: db $20
L1C6A7C: db $70
L1C6A7D: db $6F
L1C6A7E: db $77
L1C6A7F: db $65 ; M
L1C6A80: db $72
L1C6A81: db $20
L1C6A82: db $69
L1C6A83: db $73
L1C6A84: db $2E
L1C6A85: db $FF
L1C6A86: db $54 ; M
L1C6A87: db $68
L1C6A88: db $61
L1C6A89: db $74
L1C6A8A: db $20
L1C6A8B: db $69
L1C6A8C: db $73
L1C6A8D: db $20 ; M
L1C6A8E: db $77
L1C6A8F: db $68
L1C6A90: db $79
L1C6A91: db $20
L1C6A92: db $79
L1C6A93: db $6F
L1C6A94: db $75
L1C6A95: db $FF
L1C6A96: db $20
L1C6A97: db $63
L1C6A98: db $61
L1C6A99: db $6E
L1C6A9A: db $6E
L1C6A9B: db $6F
L1C6A9C: db $74 ; M
L1C6A9D: db $20
L1C6A9E: db $64
L1C6A9F: db $65
L1C6AA0: db $66
L1C6AA1: db $65
L1C6AA2: db $61
L1C6AA3: db $74 ; M
L1C6AA4: db $20
L1C6AA5: db $6D
L1C6AA6: db $65 ; M
L1C6AA7: db $2E ; M
L1C6AA8: db $FF
TextC_Win_Goenitz: db $60
L1C6AAA: db $54 ; M
L1C6AAB: db $68
L1C6AAC: db $65
L1C6AAD: db $20 ; M
L1C6AAE: db $77
L1C6AAF: db $6F
L1C6AB0: db $72
L1C6AB1: db $6C
L1C6AB2: db $64
L1C6AB3: db $20
L1C6AB4: db $62
L1C6AB5: db $75
L1C6AB6: db $72
L1C6AB7: db $6E
L1C6AB8: db $73
L1C6AB9: db $20
L1C6ABA: db $77
L1C6ABB: db $69
L1C6ABC: db $74
L1C6ABD: db $68
L1C6ABE: db $FF
L1C6ABF: db $20
L1C6AC0: db $6D
L1C6AC1: db $61 ; M
L1C6AC2: db $6C
L1C6AC3: db $69
L1C6AC4: db $63
L1C6AC5: db $65
L1C6AC6: db $20
L1C6AC7: db $61
L1C6AC8: db $6E
L1C6AC9: db $64
L1C6ACA: db $20
L1C6ACB: db $68
L1C6ACC: db $61
L1C6ACD: db $74
L1C6ACE: db $72 ; M
L1C6ACF: db $65
L1C6AD0: db $64
L1C6AD1: db $2E
L1C6AD2: db $FF
L1C6AD3: db $54
L1C6AD4: db $68
L1C6AD5: db $65
L1C6AD6: db $72
L1C6AD7: db $65 ; M
L1C6AD8: db $20 ; M
L1C6AD9: db $69
L1C6ADA: db $73
L1C6ADB: db $20
L1C6ADC: db $6E
L1C6ADD: db $6F ; M
L1C6ADE: db $20
L1C6ADF: db $77
L1C6AE0: db $61
L1C6AE1: db $79
L1C6AE2: db $20
L1C6AE3: db $74
L1C6AE4: db $6F
L1C6AE5: db $FF
L1C6AE6: db $20
L1C6AE7: db $6F
L1C6AE8: db $76
L1C6AE9: db $65 ; M
L1C6AEA: db $72
L1C6AEB: db $63
L1C6AEC: db $6F ; M
L1C6AED: db $6D ; M
L1C6AEE: db $65
L1C6AEF: db $20
L1C6AF0: db $74
L1C6AF1: db $72
L1C6AF2: db $75
L1C6AF3: db $65
L1C6AF4: db $FF
L1C6AF5: db $20 ; M
L1C6AF6: db $20
L1C6AF7: db $20
L1C6AF8: db $20
L1C6AF9: db $20
L1C6AFA: db $20
L1C6AFB: db $20 ; M
L1C6AFC: db $20
L1C6AFD: db $20
L1C6AFE: db $20
L1C6AFF: db $20
L1C6B00: db $20
L1C6B01: db $20
L1C6B02: db $20
L1C6B03: db $63 ; M
L1C6B04: db $68
L1C6B05: db $61
L1C6B06: db $6F ; M
L1C6B07: db $73
L1C6B08: db $2E
L1C6B09: db $FF
TextC_Win_MrKarate: db $37
L1C6B0B: db $49
L1C6B0C: db $60 ; M
L1C6B0D: db $6C
L1C6B0E: db $6C
L1C6B0F: db $20
L1C6B10: db $73
L1C6B11: db $61
L1C6B12: db $79
L1C6B13: db $20 ; M
L1C6B14: db $69
L1C6B15: db $74
L1C6B16: db $20
L1C6B17: db $61
L1C6B18: db $67
L1C6B19: db $61 ; M
L1C6B1A: db $69
L1C6B1B: db $6E ; M
L1C6B1C: db $20
L1C6B1D: db $21
L1C6B1E: db $FF
L1C6B1F: db $4D ; M
L1C6B20: db $79
L1C6B21: db $20 ; M
L1C6B22: db $4B
L1C6B23: db $79 ; M
L1C6B24: db $6F
L1C6B25: db $6B
L1C6B26: db $75 ; M
L1C6B27: db $67
L1C6B28: db $65
L1C6B29: db $6E ; M
L1C6B2A: db $20
L1C6B2B: db $6B
L1C6B2C: db $61
L1C6B2D: db $72
L1C6B2E: db $61 ; M
L1C6B2F: db $74
L1C6B30: db $65
L1C6B31: db $FF
L1C6B32: db $20 ; M
L1C6B33: db $69
L1C6B34: db $73 ; M
L1C6B35: db $20
L1C6B36: db $69
L1C6B37: db $6E
L1C6B38: db $76
L1C6B39: db $69
L1C6B3A: db $6E
L1C6B3B: db $63
L1C6B3C: db $69
L1C6B3D: db $62
L1C6B3E: db $6C
L1C6B3F: db $65 ; M
L1C6B40: db $21
L1C6B41: db $FF
TextC_Win_OIori: db $17
L1C6B43: db $FF ; M
L1C6B44: db $FF
L1C6B45: db $4B
L1C6B46: db $4B
L1C6B47: db $4B
L1C6B48: db $79
L1C6B49: db $79
L1C6B4A: db $79
L1C6B4B: db $6F ; M
L1C6B4C: db $6F
L1C6B4D: db $6F
L1C6B4E: db $65
L1C6B4F: db $65
L1C6B50: db $65
L1C6B51: db $65
L1C6B52: db $2D
L1C6B53: db $2D
L1C6B54: db $2D
L1C6B55: db $2D
L1C6B56: db $21
L1C6B57: db $21
L1C6B58: db $21
L1C6B59: db $FF
TextC_Win_OLeona: db $0D
L1C6B5B: db $FF
L1C6B5C: db $FF
L1C6B5D: db $2E
L1C6B5E: db $2E
L1C6B5F: db $2E
L1C6B60: db $2E
L1C6B61: db $2E
L1C6B62: db $2E
L1C6B63: db $2E
L1C6B64: db $2E
L1C6B65: db $2E ; M
L1C6B66: db $2E
L1C6B67: db $FF
TextC_Win_Kagura: db $59
L1C6B69: db $52
L1C6B6A: db $69
L1C6B6B: db $73
L1C6B6C: db $65
L1C6B6D: db $20
L1C6B6E: db $74
L1C6B6F: db $6F
L1C6B70: db $20
L1C6B71: db $65
L1C6B72: db $76
L1C6B73: db $65
L1C6B74: db $72
L1C6B75: db $79
L1C6B76: db $FF
L1C6B77: db $20
L1C6B78: db $63
L1C6B79: db $68 ; M
L1C6B7A: db $61
L1C6B7B: db $6C
L1C6B7C: db $6C
L1C6B7D: db $65
L1C6B7E: db $6E ; M
L1C6B7F: db $67
L1C6B80: db $65
L1C6B81: db $20
L1C6B82: db $77
L1C6B83: db $69
L1C6B84: db $74 ; M
L1C6B85: db $68
L1C6B86: db $20
L1C6B87: db $79
L1C6B88: db $6F
L1C6B89: db $75
L1C6B8A: db $72
L1C6B8B: db $FF
L1C6B8C: db $20
L1C6B8D: db $66
L1C6B8E: db $75
L1C6B8F: db $6C
L1C6B90: db $6C
L1C6B91: db $20
L1C6B92: db $70
L1C6B93: db $6F
L1C6B94: db $77
L1C6B95: db $65
L1C6B96: db $72
L1C6B97: db $2C ; M
L1C6B98: db $61
L1C6B99: db $6E
L1C6B9A: db $64
L1C6B9B: db $FF
L1C6B9C: db $20
L1C6B9D: db $65
L1C6B9E: db $76
L1C6B9F: db $65
L1C6BA0: db $6E ; M
L1C6BA1: db $74
L1C6BA2: db $75
L1C6BA3: db $61
L1C6BA4: db $6C
L1C6BA5: db $6C
L1C6BA6: db $79
L1C6BA7: db $20
L1C6BA8: db $79
L1C6BA9: db $6F
L1C6BAA: db $75
L1C6BAB: db $20
L1C6BAC: db $77
L1C6BAD: db $69
L1C6BAE: db $6C
L1C6BAF: db $6C
L1C6BB0: db $FF
L1C6BB1: db $20
L1C6BB2: db $61
L1C6BB3: db $63
L1C6BB4: db $68
L1C6BB5: db $69
L1C6BB6: db $65
L1C6BB7: db $76
L1C6BB8: db $65
L1C6BB9: db $20
L1C6BBA: db $76
L1C6BBB: db $69
L1C6BBC: db $63
L1C6BBD: db $74
L1C6BBE: db $72
L1C6BBF: db $79
L1C6BC0: db $21
L1C6BC1: db $FF
TextC_CutsceneGoenitz00: db $0F
L1C6BC3: db $57
L1C6BC4: db $68
L1C6BC5: db $79
L1C6BC6: db $20
L1C6BC7: db $52
L1C6BC8: db $75
L1C6BC9: db $67
L1C6BCA: db $61
L1C6BCB: db $6C
L1C6BCC: db $2E
L1C6BCD: db $2E
L1C6BCE: db $2E
L1C6BCF: db $3F
L1C6BD0: db $21
L1C6BD1: db $FF
TextC_CutsceneGoenitz01: db $3F
L1C6BD3: db $52
L1C6BD4: db $75
L1C6BD5: db $67
L1C6BD6: db $61
L1C6BD7: db $6C ; M
L1C6BD8: db $20
L1C6BD9: db $74
L1C6BDA: db $72
L1C6BDB: db $69
L1C6BDC: db $65 ; M
L1C6BDD: db $64
L1C6BDE: db $20
L1C6BDF: db $74
L1C6BE0: db $6F
L1C6BE1: db $20
L1C6BE2: db $73
L1C6BE3: db $74 ; M
L1C6BE4: db $65
L1C6BE5: db $61
L1C6BE6: db $6C
L1C6BE7: db $FF
L1C6BE8: db $20
L1C6BE9: db $74
L1C6BEA: db $68
L1C6BEB: db $65
L1C6BEC: db $20
L1C6BED: db $70
L1C6BEE: db $6F
L1C6BEF: db $77
L1C6BF0: db $65
L1C6BF1: db $72
L1C6BF2: db $20
L1C6BF3: db $6F
L1C6BF4: db $66 ; M
L1C6BF5: db $20
L1C6BF6: db $4F
L1C6BF7: db $72
L1C6BF8: db $6F
L1C6BF9: db $63
L1C6BFA: db $68 ; M
L1C6BFB: db $69
L1C6BFC: db $FF
L1C6BFD: db $20
L1C6BFE: db $20
L1C6BFF: db $20
L1C6C00: db $20
L1C6C01: db $20 ; M
L1C6C02: db $20
L1C6C03: db $20 ; M
L1C6C04: db $20
L1C6C05: db $20
L1C6C06: db $62
L1C6C07: db $75
L1C6C08: db $74
L1C6C09: db $20
L1C6C0A: db $66
L1C6C0B: db $61
L1C6C0C: db $69
L1C6C0D: db $6C
L1C6C0E: db $65
L1C6C0F: db $64
L1C6C10: db $2E
L1C6C11: db $FF
TextC_CutsceneGoenitz02: db $39
L1C6C13: db $54
L1C6C14: db $68 ; M
L1C6C15: db $65
L1C6C16: db $20
L1C6C17: db $4F
L1C6C18: db $72
L1C6C19: db $6F
L1C6C1A: db $63 ; M
L1C6C1B: db $68
L1C6C1C: db $69
L1C6C1D: db $60
L1C6C1E: db $73
L1C6C1F: db $20 ; M
L1C6C20: db $70
L1C6C21: db $6F ; M
L1C6C22: db $77 ; M
L1C6C23: db $65 ; M
L1C6C24: db $72 ; M
L1C6C25: db $FF ; M
L1C6C26: db $20
L1C6C27: db $69
L1C6C28: db $73
L1C6C29: db $20
L1C6C2A: db $6C
L1C6C2B: db $6F
L1C6C2C: db $63
L1C6C2D: db $6B
L1C6C2E: db $65
L1C6C2F: db $64
L1C6C30: db $20
L1C6C31: db $61
L1C6C32: db $77
L1C6C33: db $61
L1C6C34: db $79
L1C6C35: db $2C
L1C6C36: db $61
L1C6C37: db $6E
L1C6C38: db $64
L1C6C39: db $FF
L1C6C3A: db $20
L1C6C3B: db $49
L1C6C3C: db $20
L1C6C3D: db $61
L1C6C3E: db $6D
L1C6C3F: db $20
L1C6C40: db $69
L1C6C41: db $74
L1C6C42: db $73
L1C6C43: db $20
L1C6C44: db $6B
L1C6C45: db $65
L1C6C46: db $65 ; M
L1C6C47: db $70
L1C6C48: db $65
L1C6C49: db $72
L1C6C4A: db $2E
L1C6C4B: db $FF
TextC_CutsceneGoenitz03: db $1A
L1C6C4D: db $44
L1C6C4E: db $69 ; M
L1C6C4F: db $64
L1C6C50: db $20
L1C6C51: db $52
L1C6C52: db $75
L1C6C53: db $67
L1C6C54: db $61 ; M
L1C6C55: db $6C
L1C6C56: db $FF ; M
L1C6C57: db $20
L1C6C58: db $20
L1C6C59: db $20
L1C6C5A: db $20
L1C6C5B: db $72
L1C6C5C: db $65
L1C6C5D: db $6C
L1C6C5E: db $65 ; M
L1C6C5F: db $61
L1C6C60: db $73
L1C6C61: db $65
L1C6C62: db $20
L1C6C63: db $69
L1C6C64: db $74
L1C6C65: db $3F
L1C6C66: db $FF
TextC_CutsceneGoenitz04: db $43 ; M
L1C6C68: db $4E
L1C6C69: db $6F ; M
L1C6C6A: db $2C
L1C6C6B: db $52
L1C6C6C: db $75
L1C6C6D: db $67
L1C6C6E: db $61
L1C6C6F: db $6C
L1C6C70: db $20
L1C6C71: db $73
L1C6C72: db $69
L1C6C73: db $6D
L1C6C74: db $70
L1C6C75: db $6C
L1C6C76: db $79
L1C6C77: db $FF
L1C6C78: db $20
L1C6C79: db $73
L1C6C7A: db $74
L1C6C7B: db $6F ; M
L1C6C7C: db $6C
L1C6C7D: db $65
L1C6C7E: db $20
L1C6C7F: db $74
L1C6C80: db $68
L1C6C81: db $65
L1C6C82: db $20
L1C6C83: db $70
L1C6C84: db $6F
L1C6C85: db $77 ; M
L1C6C86: db $65
L1C6C87: db $72
L1C6C88: db $FF
L1C6C89: db $20
L1C6C8A: db $6F
L1C6C8B: db $6E
L1C6C8C: db $63
L1C6C8D: db $65
L1C6C8E: db $20
L1C6C8F: db $69
L1C6C90: db $74
L1C6C91: db $20 ; M
L1C6C92: db $77
L1C6C93: db $61 ; M
L1C6C94: db $73
L1C6C95: db $FF
L1C6C96: db $20
L1C6C97: db $20
L1C6C98: db $20
L1C6C99: db $20
L1C6C9A: db $20
L1C6C9B: db $20
L1C6C9C: db $20
L1C6C9D: db $20
L1C6C9E: db $20
L1C6C9F: db $20
L1C6CA0: db $20
L1C6CA1: db $72
L1C6CA2: db $65
L1C6CA3: db $6C
L1C6CA4: db $65 ; M
L1C6CA5: db $61
L1C6CA6: db $73
L1C6CA7: db $65
L1C6CA8: db $64
L1C6CA9: db $2E
L1C6CAA: db $FF
TextC_CutsceneGoenitz05: db $23
L1C6CAC: db $42
L1C6CAD: db $75
L1C6CAE: db $74
L1C6CAF: db $20
L1C6CB0: db $77
L1C6CB1: db $68
L1C6CB2: db $79
L1C6CB3: db $20
L1C6CB4: db $64
L1C6CB5: db $69
L1C6CB6: db $64
L1C6CB7: db $20
L1C6CB8: db $79
L1C6CB9: db $6F
L1C6CBA: db $75 ; M
L1C6CBB: db $20
L1C6CBC: db $77
L1C6CBD: db $61
L1C6CBE: db $6E ; M
L1C6CBF: db $74
L1C6CC0: db $FF ; M
L1C6CC1: db $20
L1C6CC2: db $74
L1C6CC3: db $6F
L1C6CC4: db $20
L1C6CC5: db $66
L1C6CC6: db $69
L1C6CC7: db $67
L1C6CC8: db $68
L1C6CC9: db $74
L1C6CCA: db $20
L1C6CCB: db $75
L1C6CCC: db $73
L1C6CCD: db $3F ; M
L1C6CCE: db $FF
TextC_CutsceneGoenitz06: db $36
L1C6CD0: db $49
L1C6CD1: db $20
L1C6CD2: db $6F
L1C6CD3: db $72
L1C6CD4: db $67
L1C6CD5: db $61
L1C6CD6: db $6E
L1C6CD7: db $69
L1C6CD8: db $7A
L1C6CD9: db $65
L1C6CDA: db $64
L1C6CDB: db $20
L1C6CDC: db $74
L1C6CDD: db $68
L1C6CDE: db $65
L1C6CDF: db $FF
L1C6CE0: db $20
L1C6CE1: db $74
L1C6CE2: db $6F
L1C6CE3: db $75
L1C6CE4: db $72
L1C6CE5: db $6E ; M
L1C6CE6: db $61
L1C6CE7: db $6D
L1C6CE8: db $65
L1C6CE9: db $6E
L1C6CEA: db $74
L1C6CEB: db $20
L1C6CEC: db $74
L1C6CED: db $6F ; M
L1C6CEE: db $20
L1C6CEF: db $73
L1C6CF0: db $65
L1C6CF1: db $65
L1C6CF2: db $FF
L1C6CF3: db $20
L1C6CF4: db $79
L1C6CF5: db $6F
L1C6CF6: db $75
L1C6CF7: db $72
L1C6CF8: db $20
L1C6CF9: db $74
L1C6CFA: db $72 ; M
L1C6CFB: db $75
L1C6CFC: db $65
L1C6CFD: db $20
L1C6CFE: db $70
L1C6CFF: db $6F
L1C6D00: db $77
L1C6D01: db $65
L1C6D02: db $72
L1C6D03: db $73
L1C6D04: db $2E
L1C6D05: db $FF
TextC_CutsceneGoenitz07: db $0A
L1C6D07: db $57
L1C6D08: db $68
L1C6D09: db $61
L1C6D0A: db $74 ; M
L1C6D0B: db $20
L1C6D0C: db $66
L1C6D0D: db $6F
L1C6D0E: db $72
L1C6D0F: db $3F
L1C6D10: db $FF
TextC_CutsceneGoenitz08: db $47
L1C6D12: db $49
L1C6D13: db $20
L1C6D14: db $77
L1C6D15: db $61
L1C6D16: db $6E
L1C6D17: db $74
L1C6D18: db $20
L1C6D19: db $79
L1C6D1A: db $6F
L1C6D1B: db $75
L1C6D1C: db $20
L1C6D1D: db $74
L1C6D1E: db $6F
L1C6D1F: db $20
L1C6D20: db $75
L1C6D21: db $73
L1C6D22: db $65
L1C6D23: db $FF
L1C6D24: db $20
L1C6D25: db $79
L1C6D26: db $6F
L1C6D27: db $75
L1C6D28: db $72 ; M
L1C6D29: db $20
L1C6D2A: db $70
L1C6D2B: db $6F
L1C6D2C: db $77 ; M
L1C6D2D: db $65
L1C6D2E: db $72
L1C6D2F: db $20
L1C6D30: db $74
L1C6D31: db $6F
L1C6D32: db $FF ; M
L1C6D33: db $20
L1C6D34: db $63
L1C6D35: db $6F
L1C6D36: db $6E
L1C6D37: db $74 ; M
L1C6D38: db $61
L1C6D39: db $69
L1C6D3A: db $6E
L1C6D3B: db $20
L1C6D3C: db $74
L1C6D3D: db $68
L1C6D3E: db $65
L1C6D3F: db $20
L1C6D40: db $4F
L1C6D41: db $72 ; M
L1C6D42: db $6F ; M
L1C6D43: db $63
L1C6D44: db $68
L1C6D45: db $69
L1C6D46: db $FF
L1C6D47: db $20
L1C6D48: db $70
L1C6D49: db $6F
L1C6D4A: db $77
L1C6D4B: db $65
L1C6D4C: db $72
L1C6D4D: db $20
L1C6D4E: db $6F
L1C6D4F: db $6E
L1C6D50: db $63
L1C6D51: db $65 ; M
L1C6D52: db $20
L1C6D53: db $6D
L1C6D54: db $6F
L1C6D55: db $72
L1C6D56: db $65 ; M
L1C6D57: db $2E
L1C6D58: db $FF
TextC_CutsceneGoenitz09: db $50
L1C6D5A: db $54
L1C6D5B: db $68
L1C6D5C: db $65
L1C6D5D: db $72
L1C6D5E: db $65
L1C6D5F: db $20
L1C6D60: db $69
L1C6D61: db $73 ; M
L1C6D62: db $20
L1C6D63: db $6E
L1C6D64: db $6F
L1C6D65: db $20
L1C6D66: db $74
L1C6D67: db $69
L1C6D68: db $6D
L1C6D69: db $65
L1C6D6A: db $FF
L1C6D6B: db $20
L1C6D6C: db $20
L1C6D6D: db $20
L1C6D6E: db $20
L1C6D6F: db $20 ; M
L1C6D70: db $20
L1C6D71: db $20
L1C6D72: db $20
L1C6D73: db $20 ; M
L1C6D74: db $20
L1C6D75: db $20
L1C6D76: db $20
L1C6D77: db $74
L1C6D78: db $6F
L1C6D79: db $20
L1C6D7A: db $6C
L1C6D7B: db $6F
L1C6D7C: db $73
L1C6D7D: db $65
L1C6D7E: db $2E
L1C6D7F: db $FF
L1C6D80: db $49
L1C6D81: db $20
L1C6D82: db $63
L1C6D83: db $61
L1C6D84: db $6E
L1C6D85: db $20
L1C6D86: db $73
L1C6D87: db $65
L1C6D88: db $65
L1C6D89: db $20
L1C6D8A: db $62
L1C6D8B: db $79
L1C6D8C: db $20 ; M
L1C6D8D: db $73
L1C6D8E: db $69
L1C6D8F: db $67 ; M
L1C6D90: db $6E ; M
L1C6D91: db $73 ; M
L1C6D92: db $2E ; M
L1C6D93: db $FF
L1C6D94: db $FF
L1C6D95: db $48 ; M
L1C6D96: db $65 ; M
L1C6D97: db $20 ; M
L1C6D98: db $69
L1C6D99: db $73
L1C6D9A: db $20
L1C6D9B: db $61
L1C6D9C: db $6C
L1C6D9D: db $72
L1C6D9E: db $65
L1C6D9F: db $61 ; M
L1C6DA0: db $64
L1C6DA1: db $79
L1C6DA2: db $20
L1C6DA3: db $63
L1C6DA4: db $6F
L1C6DA5: db $6D ; M
L1C6DA6: db $65
L1C6DA7: db $2E
L1C6DA8: db $2E
L1C6DA9: db $FF
TextC_CutsceneGoenitz0A: db $07
L1C6DAB: db $48
L1C6DAC: db $65
L1C6DAD: db $2E
L1C6DAE: db $2E
L1C6DAF: db $2E
L1C6DB0: db $3F
L1C6DB1: db $FF ; M
TextC_CutsceneGoenitz0B: db $30
L1C6DB3: db $59
L1C6DB4: db $65
L1C6DB5: db $73
L1C6DB6: db $2E
L1C6DB7: db $2E
L1C6DB8: db $2E
L1C6DB9: db $20
L1C6DBA: db $54
L1C6DBB: db $68
L1C6DBC: db $65
L1C6DBD: db $20
L1C6DBE: db $6D
L1C6DBF: db $61
L1C6DC0: db $6E
L1C6DC1: db $20 ; M
L1C6DC2: db $77
L1C6DC3: db $68
L1C6DC4: db $6F
L1C6DC5: db $FF
L1C6DC6: db $20
L1C6DC7: db $72
L1C6DC8: db $65
L1C6DC9: db $6C
L1C6DCA: db $65 ; M
L1C6DCB: db $61
L1C6DCC: db $73
L1C6DCD: db $65
L1C6DCE: db $64
L1C6DCF: db $FF
L1C6DD0: db $20
L1C6DD1: db $74
L1C6DD2: db $68 ; M
L1C6DD3: db $65
L1C6DD4: db $20
L1C6DD5: db $4F
L1C6DD6: db $72
L1C6DD7: db $6F
L1C6DD8: db $63
L1C6DD9: db $68
L1C6DDA: db $69
L1C6DDB: db $20 ; M
L1C6DDC: db $70
L1C6DDD: db $6F
L1C6DDE: db $77
L1C6DDF: db $65
L1C6DE0: db $72
L1C6DE1: db $21
L1C6DE2: db $FF
TextC_CutsceneGoenitz0C: db $19
L1C6DE4: db $48
L1C6DE5: db $65
L1C6DE6: db $79 ; M
L1C6DE7: db $21 ; M
L1C6DE8: db $21
L1C6DE9: db $FF
L1C6DEA: db $57
L1C6DEB: db $68
L1C6DEC: db $61
L1C6DED: db $74 ; M
L1C6DEE: db $60
L1C6DEF: db $73
L1C6DF0: db $20
L1C6DF1: db $74
L1C6DF2: db $68
L1C6DF3: db $61
L1C6DF4: db $74
L1C6DF5: db $20
L1C6DF6: db $77
L1C6DF7: db $69
L1C6DF8: db $6E
L1C6DF9: db $64
L1C6DFA: db $21 ; M
L1C6DFB: db $3F
L1C6DFC: db $FF
TextC_CutsceneGoenitz0D: db $09 ; M
L1C6DFE: db $41
L1C6DFF: db $61
L1C6E00: db $61
L1C6E01: db $68 ; M
L1C6E02: db $68 ; M
L1C6E03: db $2D
L1C6E04: db $21
L1C6E05: db $21
L1C6E06: db $FF
TextC_Ending_Generic0: db $37 ; M
L1C6E08: db $59
L1C6E09: db $6F
L1C6E0A: db $75
L1C6E0B: db $20
L1C6E0C: db $73
L1C6E0D: db $75 ; M
L1C6E0E: db $72
L1C6E0F: db $70
L1C6E10: db $72
L1C6E11: db $69
L1C6E12: db $73
L1C6E13: db $65
L1C6E14: db $20
L1C6E15: db $6D
L1C6E16: db $65
L1C6E17: db $2E
L1C6E18: db $FF
L1C6E19: db $49
L1C6E1A: db $20
L1C6E1B: db $75
L1C6E1C: db $6E
L1C6E1D: db $64
L1C6E1E: db $65
L1C6E1F: db $72
L1C6E20: db $65
L1C6E21: db $73
L1C6E22: db $74
L1C6E23: db $69
L1C6E24: db $6D
L1C6E25: db $61 ; M
L1C6E26: db $74
L1C6E27: db $65
L1C6E28: db $64
L1C6E29: db $FF
L1C6E2A: db $20
L1C6E2B: db $20
L1C6E2C: db $20 ; M
L1C6E2D: db $20
L1C6E2E: db $79
L1C6E2F: db $6F
L1C6E30: db $75
L1C6E31: db $72
L1C6E32: db $20
L1C6E33: db $73
L1C6E34: db $74
L1C6E35: db $72
L1C6E36: db $65
L1C6E37: db $6E
L1C6E38: db $67
L1C6E39: db $74
L1C6E3A: db $68 ; M
L1C6E3B: db $2E
L1C6E3C: db $2E
L1C6E3D: db $2E
L1C6E3E: db $FF
TextC_Ending_Generic1: db $63
L1C6E40: db $42
L1C6E41: db $75
L1C6E42: db $74
L1C6E43: db $20
L1C6E44: db $74
L1C6E45: db $68
L1C6E46: db $65 ; M
L1C6E47: db $72
L1C6E48: db $65
L1C6E49: db $20
L1C6E4A: db $69
L1C6E4B: db $73
L1C6E4C: db $20 ; M
L1C6E4D: db $6E
L1C6E4E: db $6F ; M
L1C6E4F: db $20
L1C6E50: db $77
L1C6E51: db $61
L1C6E52: db $79
L1C6E53: db $FF
L1C6E54: db $20
L1C6E55: db $79
L1C6E56: db $6F
L1C6E57: db $75
L1C6E58: db $20
L1C6E59: db $63
L1C6E5A: db $61
L1C6E5B: db $6E
L1C6E5C: db $20
L1C6E5D: db $63
L1C6E5E: db $6F
L1C6E5F: db $6E
L1C6E60: db $74
L1C6E61: db $61
L1C6E62: db $69
L1C6E63: db $6E
L1C6E64: db $FF
L1C6E65: db $20
L1C6E66: db $20
L1C6E67: db $20
L1C6E68: db $74
L1C6E69: db $68
L1C6E6A: db $65
L1C6E6B: db $20
L1C6E6C: db $4F
L1C6E6D: db $72
L1C6E6E: db $6F ; M
L1C6E6F: db $63
L1C6E70: db $68
L1C6E71: db $69
L1C6E72: db $20
L1C6E73: db $70
L1C6E74: db $6F
L1C6E75: db $77
L1C6E76: db $65
L1C6E77: db $72
L1C6E78: db $2E
L1C6E79: db $FF
L1C6E7A: db $59
L1C6E7B: db $6F
L1C6E7C: db $75
L1C6E7D: db $72
L1C6E7E: db $20
L1C6E7F: db $70
L1C6E80: db $6F ; M
L1C6E81: db $77
L1C6E82: db $65
L1C6E83: db $72 ; M
L1C6E84: db $73
L1C6E85: db $20
L1C6E86: db $61
L1C6E87: db $72 ; M
L1C6E88: db $65
L1C6E89: db $20
L1C6E8A: db $6E
L1C6E8B: db $6F
L1C6E8C: db $74
L1C6E8D: db $FF
L1C6E8E: db $20
L1C6E8F: db $20
L1C6E90: db $20
L1C6E91: db $20
L1C6E92: db $20
L1C6E93: db $67
L1C6E94: db $72
L1C6E95: db $65
L1C6E96: db $61
L1C6E97: db $74
L1C6E98: db $20
L1C6E99: db $65
L1C6E9A: db $6E
L1C6E9B: db $6F
L1C6E9C: db $75
L1C6E9D: db $67
L1C6E9E: db $68
L1C6E9F: db $2E
L1C6EA0: db $2E
L1C6EA1: db $2E
L1C6EA2: db $FF
TextC_Ending_Generic2: db $3A
L1C6EA4: db $54
L1C6EA5: db $61
L1C6EA6: db $6B
L1C6EA7: db $65 ; M
L1C6EA8: db $20
L1C6EA9: db $6D
L1C6EAA: db $79
L1C6EAB: db $20
L1C6EAC: db $61
L1C6EAD: db $64
L1C6EAE: db $76
L1C6EAF: db $69
L1C6EB0: db $63 ; M
L1C6EB1: db $65
L1C6EB2: db $20 ; M
L1C6EB3: db $2D
L1C6EB4: db $FF ; M
L1C6EB5: db $20
L1C6EB6: db $77
L1C6EB7: db $69
L1C6EB8: db $74
L1C6EB9: db $68 ; M
L1C6EBA: db $64
L1C6EBB: db $72
L1C6EBC: db $61 ; M
L1C6EBD: db $77 ; M
L1C6EBE: db $20
L1C6EBF: db $6E
L1C6EC0: db $6F
L1C6EC1: db $77 ; M
L1C6EC2: db $20
L1C6EC3: db $77
L1C6EC4: db $68
L1C6EC5: db $69
L1C6EC6: db $6C
L1C6EC7: db $65
L1C6EC8: db $FF ; M
L1C6EC9: db $20
L1C6ECA: db $79
L1C6ECB: db $6F
L1C6ECC: db $75
L1C6ECD: db $60
L1C6ECE: db $72
L1C6ECF: db $65 ; M
L1C6ED0: db $20
L1C6ED1: db $73
L1C6ED2: db $74
L1C6ED3: db $69
L1C6ED4: db $6C
L1C6ED5: db $6C
L1C6ED6: db $20
L1C6ED7: db $61
L1C6ED8: db $6C
L1C6ED9: db $69
L1C6EDA: db $76
L1C6EDB: db $65
L1C6EDC: db $2E
L1C6EDD: db $FF
TextC_Ending_Generic3: db $22
L1C6EDF: db $57
L1C6EE0: db $65
L1C6EE1: db $60 ; M
L1C6EE2: db $6C
L1C6EE3: db $6C
L1C6EE4: db $20 ; M
L1C6EE5: db $64
L1C6EE6: db $65
L1C6EE7: db $66
L1C6EE8: db $65 ; M
L1C6EE9: db $61
L1C6EEA: db $74
L1C6EEB: db $FF
L1C6EEC: db $20
L1C6EED: db $20
L1C6EEE: db $20
L1C6EEF: db $74
L1C6EF0: db $68 ; M
L1C6EF1: db $65
L1C6EF2: db $20
L1C6EF3: db $4F
L1C6EF4: db $72
L1C6EF5: db $6F
L1C6EF6: db $63
L1C6EF7: db $68
L1C6EF8: db $69
L1C6EF9: db $20 ; M
L1C6EFA: db $70
L1C6EFB: db $6F ; M
L1C6EFC: db $77
L1C6EFD: db $65
L1C6EFE: db $72
L1C6EFF: db $2E ; M
L1C6F00: db $FF
TextC_Ending_Generic4: db $28
L1C6F02: db $44
L1C6F03: db $65
L1C6F04: db $74
L1C6F05: db $65
L1C6F06: db $72
L1C6F07: db $6D
L1C6F08: db $69
L1C6F09: db $6E
L1C6F0A: db $65
L1C6F0B: db $64
L1C6F0C: db $20
L1C6F0D: db $74
L1C6F0E: db $6F ; M
L1C6F0F: db $20
L1C6F10: db $77
L1C6F11: db $69
L1C6F12: db $6E
L1C6F13: db $2C
L1C6F14: db $FF
L1C6F15: db $20
L1C6F16: db $20
L1C6F17: db $20 ; M
L1C6F18: db $20
L1C6F19: db $20
L1C6F1A: db $20
L1C6F1B: db $20
L1C6F1C: db $20
L1C6F1D: db $20
L1C6F1E: db $20
L1C6F1F: db $20
L1C6F20: db $20
L1C6F21: db $20
L1C6F22: db $20
L1C6F23: db $49
L1C6F24: db $20
L1C6F25: db $73
L1C6F26: db $65
L1C6F27: db $65
L1C6F28: db $2E
L1C6F29: db $FF
TextC_Ending_Generic5: db $4F
L1C6F2B: db $4E
L1C6F2C: db $6F
L1C6F2D: db $77
L1C6F2E: db $2E ; M
L1C6F2F: db $2E
L1C6F30: db $20
L1C6F31: db $74
L1C6F32: db $68
L1C6F33: db $65
L1C6F34: db $20
L1C6F35: db $77
L1C6F36: db $69
L1C6F37: db $6E ; M
L1C6F38: db $64
L1C6F39: db $20 ; M
L1C6F3A: db $69
L1C6F3B: db $73 ; M
L1C6F3C: db $FF
L1C6F3D: db $20 ; M
L1C6F3E: db $20
L1C6F3F: db $20 ; M
L1C6F40: db $20
L1C6F41: db $20 ; M
L1C6F42: db $20
L1C6F43: db $20 ; M
L1C6F44: db $20
L1C6F45: db $20 ; M
L1C6F46: db $20
L1C6F47: db $62 ; M
L1C6F48: db $6C
L1C6F49: db $6F
L1C6F4A: db $77 ; M
L1C6F4B: db $69
L1C6F4C: db $6E
L1C6F4D: db $67
L1C6F4E: db $2E
L1C6F4F: db $2E
L1C6F50: db $2E
L1C6F51: db $FF
L1C6F52: db $20
L1C6F53: db $74
L1C6F54: db $68
L1C6F55: db $65
L1C6F56: db $20
L1C6F57: db $74
L1C6F58: db $69
L1C6F59: db $6D
L1C6F5A: db $65
L1C6F5B: db $20
L1C6F5C: db $68
L1C6F5D: db $61
L1C6F5E: db $73
L1C6F5F: db $20 ; M
L1C6F60: db $63
L1C6F61: db $6F ; M
L1C6F62: db $6D
L1C6F63: db $65 ; M
L1C6F64: db $FF ; M
L1C6F65: db $20 ; M
L1C6F66: db $20
L1C6F67: db $20 ; M
L1C6F68: db $20
L1C6F69: db $66
L1C6F6A: db $6F
L1C6F6B: db $72 ; M
L1C6F6C: db $20
L1C6F6D: db $6D
L1C6F6E: db $65
L1C6F6F: db $20
L1C6F70: db $74
L1C6F71: db $6F
L1C6F72: db $20
L1C6F73: db $6C
L1C6F74: db $65
L1C6F75: db $61
L1C6F76: db $76
L1C6F77: db $65
L1C6F78: db $2E
L1C6F79: db $FF
TextC_Ending_Generic6: db $23
L1C6F7B: db $52
L1C6F7C: db $75
L1C6F7D: db $6E
L1C6F7E: db $6E
L1C6F7F: db $69
L1C6F80: db $6E
L1C6F81: db $67
L1C6F82: db $20 ; M
L1C6F83: db $61
L1C6F84: db $77
L1C6F85: db $61
L1C6F86: db $79
L1C6F87: db $2C ; M
L1C6F88: db $FF ; M
L1C6F89: db $20 ; M
L1C6F8A: db $20
L1C6F8B: db $20
L1C6F8C: db $20
L1C6F8D: db $61
L1C6F8E: db $72
L1C6F8F: db $65
L1C6F90: db $20
L1C6F91: db $79
L1C6F92: db $6F
L1C6F93: db $75
L1C6F94: db $2C
L1C6F95: db $47
L1C6F96: db $6F
L1C6F97: db $65
L1C6F98: db $6E
L1C6F99: db $69 ; M
L1C6F9A: db $74
L1C6F9B: db $7A
L1C6F9C: db $3F
L1C6F9D: db $FF
TextC_Ending_GoenitzLeave0: db $19
L1C6F9F: db $4E
L1C6FA0: db $6F
L1C6FA1: db $2E
L1C6FA2: db $FF
L1C6FA3: db $49
L1C6FA4: db $20 ; M
L1C6FA5: db $61
L1C6FA6: db $6D ; M
L1C6FA7: db $20
L1C6FA8: db $62
L1C6FA9: db $65
L1C6FAA: db $69
L1C6FAB: db $6E ; M
L1C6FAC: db $67
L1C6FAD: db $20 ; M
L1C6FAE: db $63
L1C6FAF: db $61
L1C6FB0: db $6C
L1C6FB1: db $6C
L1C6FB2: db $65
L1C6FB3: db $64
L1C6FB4: db $2E
L1C6FB5: db $2E
L1C6FB6: db $2E
L1C6FB7: db $FF
TextC_Ending_GoenitzLeave2: db $10
L1C6FB9: db $54
L1C6FBA: db $6F
L1C6FBB: db $20
L1C6FBC: db $74
L1C6FBD: db $68
L1C6FBE: db $65
L1C6FBF: db $20
L1C6FC0: db $68
L1C6FC1: db $65
L1C6FC2: db $61
L1C6FC3: db $76
L1C6FC4: db $65 ; M
L1C6FC5: db $6E ; M
L1C6FC6: db $73
L1C6FC7: db $21
L1C6FC8: db $FF
TextC_CutsceneGoenitz0C_Easy: db $54
L1C6FCA: db $57
L1C6FCB: db $68
L1C6FCC: db $65 ; M
L1C6FCD: db $6E
L1C6FCE: db $20
L1C6FCF: db $6F
L1C6FD0: db $70
L1C6FD1: db $70
L1C6FD2: db $6F
L1C6FD3: db $6E
L1C6FD4: db $65
L1C6FD5: db $6E
L1C6FD6: db $74
L1C6FD7: db $73
L1C6FD8: db $20
L1C6FD9: db $61
L1C6FDA: db $72
L1C6FDB: db $65 ; M
L1C6FDC: db $FF
L1C6FDD: db $20
L1C6FDE: db $74
L1C6FDF: db $68
L1C6FE0: db $69 ; M
L1C6FE1: db $73
L1C6FE2: db $20
L1C6FE3: db $77
L1C6FE4: db $65
L1C6FE5: db $61 ; M
L1C6FE6: db $6B
L1C6FE7: db $2C
L1C6FE8: db $74
L1C6FE9: db $68
L1C6FEA: db $65
L1C6FEB: db $72
L1C6FEC: db $65
L1C6FED: db $60
L1C6FEE: db $73
L1C6FEF: db $FF
L1C6FF0: db $20
L1C6FF1: db $6E
L1C6FF2: db $6F
L1C6FF3: db $20
L1C6FF4: db $6E
L1C6FF5: db $65
L1C6FF6: db $65
L1C6FF7: db $64
L1C6FF8: db $20
L1C6FF9: db $66
L1C6FFA: db $6F
L1C6FFB: db $72
L1C6FFC: db $20
L1C6FFD: db $6D
L1C6FFE: db $65
L1C6FFF: db $20
L1C7000: db $74
L1C7001: db $6F
L1C7002: db $FF
L1C7003: db $20
L1C7004: db $77
L1C7005: db $61
L1C7006: db $73
L1C7007: db $74 ; M
L1C7008: db $65
L1C7009: db $20
L1C700A: db $6D
L1C700B: db $79 ; M
L1C700C: db $20
L1C700D: db $74
L1C700E: db $69
L1C700F: db $6D
L1C7010: db $65
L1C7011: db $20
L1C7012: db $77
L1C7013: db $69
L1C7014: db $74
L1C7015: db $68
L1C7016: db $FF
L1C7017: db $20
L1C7018: db $74
L1C7019: db $68
L1C701A: db $65
L1C701B: db $6D
L1C701C: db $2E
L1C701D: db $FF
TextC_CutsceneGoenitz0D_Easy: db $38
L1C701F: db $4C
L1C7020: db $65
L1C7021: db $74
L1C7022: db $60
L1C7023: db $73
L1C7024: db $20
L1C7025: db $6D
L1C7026: db $65
L1C7027: db $65
L1C7028: db $74
L1C7029: db $20 ; M
L1C702A: db $61
L1C702B: db $67
L1C702C: db $61
L1C702D: db $69
L1C702E: db $6E
L1C702F: db $20
L1C7030: db $61
L1C7031: db $74 ; M
L1C7032: db $FF
L1C7033: db $20
L1C7034: db $61
L1C7035: db $20
L1C7036: db $6C
L1C7037: db $65
L1C7038: db $76
L1C7039: db $65
L1C703A: db $6C
L1C703B: db $20 ; M
L1C703C: db $61
L1C703D: db $62
L1C703E: db $6F
L1C703F: db $76 ; M
L1C7040: db $65
L1C7041: db $FF
L1C7042: db $20
L1C7043: db $20
L1C7044: db $20
L1C7045: db $20
L1C7046: db $20
L1C7047: db $20
L1C7048: db $20
L1C7049: db $20
L1C704A: db $20
L1C704B: db $20
L1C704C: db $20
L1C704D: db $20
L1C704E: db $20
L1C704F: db $4E
L1C7050: db $4F
L1C7051: db $52
L1C7052: db $4D
L1C7053: db $41 ; M
L1C7054: db $4C
L1C7055: db $2E
L1C7056: db $FF
TextC_Ending_GoenitzLeave1: db $15
L1C7058: db $20
L1C7059: db $20
L1C705A: db $20
L1C705B: db $20
L1C705C: db $20
L1C705D: db $20
L1C705E: db $20
L1C705F: db $20
L1C7060: db $20 ; M
L1C7061: db $20
L1C7062: db $20
L1C7063: db $20
L1C7064: db $20 ; M
L1C7065: db $20
L1C7066: db $20 ; M
L1C7067: db $20
L1C7068: db $20 ; M
L1C7069: db $20
L1C706A: db $20 ; M
L1C706B: db $20
L1C706C: db $FF ; M
ENDC
	
IF ENGLISH == 1

; Got moved from above in the English version for whatever reason.

; =============== Title_LoadVRAM ===============
; Loads tilemaps and GFX for the title screen.
; The menus load the 1bpp text over this, and reuse the cursor already loaded here.
Title_LoadVRAM:
	; Title screen & menu sprites
	ld   hl, GFXAuto_TitleOBJ 
	ld   de, Tiles_Begin		
	call CopyTilesAutoNum
	
	; wLZSS_Buffer offset by $10 since a SGB packet got copied at the start of the buffer.
	
	; KOF96 Title logo tilemap
	ld   hl, BGLZ_Title_Logo
	ld   de, wLZSS_Buffer+$10
	call DecompressLZSS
	ld   de, wLZSS_Buffer+$10
	ld   hl, WINDOWMap_Begin
	ld   b, $14
	ld   c, $0F
	call CopyBGToRect
	
	; Title screen logo GFX (2 parts)
	ld   hl, GFXLZ_Title_Logo1
	ld   de, wLZSS_Buffer+$10
	call DecompressLZSS
	ld   hl, wLZSS_Buffer+$10
	ld   de, $8800				; Block 2
	ld   b, $80
	call CopyTiles
	
	ld   hl, GFXLZ_Title_Logo0
	ld   de, wLZSS_Buffer+$10
	call DecompressLZSS
	ld   hl, wLZSS_Buffer+$10
	ld   de, $9000				; Block 3
	ld   b, $80
	call CopyTiles
	
	; Tilemap in BG layer for cloud parallax, repeated to fill the tilemap's width
I = 0
REPT 8
	ld   de, BG_Title_Clouds
	ld   hl, BGMap_Begin+($04*I)
	ld   b, $04	; 4 tiles width * 8 = $20 (tilemap length)
	ld   c, $03 ; 3 tiles tall
	call CopyBGToRect
I = I + 1
ENDR
	ret
	
; =============== Title_LoadVRAM_Mini ===============
; Loads the title screen GFX which were overwritten by the 1bpp font.
Title_LoadVRAM_Mini:
	; Title screen logo GFX (2nd part, at $9000)
	
	; This takes advantage that GFXLZ_Title_Logo0 was the last LZSS data to be decompressed.
	; As a result, the decompressed copy is still stored in the buffer.

	ld   hl, wLZSS_Buffer+$10	; HL = Source
	ld   de, $9000				; DE = Destination
	ld   b, $80					; B = Tiles to copy
	call CopyTilesHBlank
	ret
	
IF ENGLISH == 0
GFXLZ_Title_Logo0: INCBIN "data/gfx/jp/title_logo0.lzc"
GFXLZ_Title_Logo1: INCBIN "data/gfx/jp/title_logo1.lzc"
BGLZ_Title_Logo: INCBIN "data/bg/jp/title_logo.lzs"
BG_Title_Clouds: INCBIN "data/bg/jp/title_clouds.bin"
ELSE
GFXLZ_Title_Logo0: INCBIN "data/gfx/en/title_logo0.lzc"
GFXLZ_Title_Logo1: INCBIN "data/gfx/en/title_logo1.lzc"
BGLZ_Title_Logo: INCBIN "data/bg/en/title_logo.lzs"
BG_Title_Clouds: INCBIN "data/bg/en/title_clouds.bin"
ENDC


GFXAuto_TitleOBJ:
	db (GFXAuto_TitleOBJ.end-GFXAuto_TitleOBJ.start)/TILESIZE ; Number of tiles
.start:
	INCBIN "data/gfx/title_obj.bin"
.end:

ENDC

IF ENGLISH == 0
; Got moved to Bank $02 in the English version

; =============== MoveC_Base_NormL_2Hit_D06_A03 ===============
; Generic move code used for light normals that hit twice.
; See also: MoveC_Base_NormH_2Hit_D06_A04
MoveC_Base_NormL_2Hit_D06_A03:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]		; A = OBJLst ID
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj0
; --------------- frame #1-(end) ---------------
	mMvC_ChkTarget .chkEnd
	jp   .anim
; --------------- frame #0 ---------------
; When visually switching to #1, use new damage info.
.obj0:
	mMvC_ValFrameEnd .anim ; About to advance the anim? If not, skip to .anim
	; Otherwise, request new damage fields to apply when visually switching frames
	mMvC_SetDamageNext $06, HITTYPE_HIT_MID0, PF3_HEAVYHIT
	jp   .anim
; --------------- common ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
	call Play_Pl_EndMove
	jr   .ret
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Base_NormH_2Hit_D06_A04 ===============
; Generic move code used for heavy normals that hit twice.
MoveC_Base_NormH_2Hit_D06_A04:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]		; A = OBJLst ID
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
; --------------- frame #0,2-(end) ---------------
	mMvC_ChkTarget .chkEnd
	jp   .anim
; --------------- frame #1 ---------------
; When visually switching to #2, use new damage info.
; Doing this allows the move to hit twice, since hitting the opponent removes
; the damage value for the move, to avoid multiple hits.
; So, if we hit the opponent before the the new damage gets applied (ie: pretty much always)
; the move will hit twice.
.obj1:
	mMvC_ValFrameEnd .anim ; About to advance the anim? If not, skip to .anim
	; Otherwise, request new damage fields to apply when visually switching frames
	mMvC_SetDamageNext $06, HITTYPE_HIT_MID1, PF3_HEAVYHIT
	jp   .anim
; --------------- common ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
	call Play_Pl_EndMove
	jr   .ret
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_MrBig_PunchH ===============
; Move code used for Mr.Big's heavy punch. 
; This is like MoveC_Base_NormH_2Hit_D06_A04, except the player moves
; forward 7px at the start of #0 and #1.
MoveC_MrBig_PunchH:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]		; A = OBJLst ID
	cp   $00*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj0
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
; --------------- frame #2-(end) ---------------
	mMvC_ChkTarget .chkEnd
	jp   .anim
; --------------- frame #0 ---------------
; The first time we get here, move 7px forward.
.obj0:
	mMvC_ValFrameStart .anim					; If not, jump
	mMvC_SetMoveH $0700
	jp   .anim
; --------------- frame #1 ---------------
.obj1:
	;
	; The first time we get here, move 7px forward.
	;
	mMvC_ValFrameStart .obj1_chkAdv			; If not, jump
	mMvC_SetMoveH $0700
.obj1_chkAdv:
	;
	; When visually switching to #2, use new damage info.
	;
	mMvC_ValFrameEnd .anim ; About to advance the anim? If not, skip to .anim
	; Otherwise, request new damage fields to apply when visually switching frames
	mMvC_SetDamageNext $06, HITTYPE_HIT_MID1, PF3_HEAVYHIT
	jp   .anim
; --------------- common ---------------	
.chkEnd:
	mMvC_ValFrameEnd .anim
	call Play_Pl_EndMove
	jr   .ret
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Mature_PunchH ===============
; Move code used for Mature's heavy punch, this is almost the same
; as the one for Mr.Big's heavy punch, except for the logic of #0 being moved to #3,
; and different code to account for it.
;
; See also: MoveC_MrBig_PunchH
MoveC_Mature_PunchH:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj3
	
; --------------- frame #0,#2 ---------------
	; [POI] Could have been just "jp .anim". We get to .chkEnd anyway in #3
	mMvC_ChkTarget .chkEnd
	jp   .anim
; --------------- frame #3 ---------------
; The first time we get here, move 7px forward.
; When attempting to visually switch to #4, end the move instead.
.obj3:
	mMvC_ValFrameStart .obj3_chkAdv		; If not, jump
	mMvC_SetMoveH $0700				; Otherwise move forward
.obj3_chkAdv:
	;--
	; [POI] This is pointless, as .chkEnd checks it anyway.
	mMvC_ValFrameEnd .anim
	;--
	jp   .chkEnd
; --------------- frame #1 ---------------
.obj1:
	;
	; The first time we get here, move 7px forward.
	;
	mMvC_ValFrameStart .obj1_chkAdv
	mMvC_SetMoveH $0700
.obj1_chkAdv:
	;
	; When visually switching to #2, use new damage info.
	;
	mMvC_ValFrameEnd .anim ; About to advance the anim? If not, skip to .anim
	; Otherwise, request new damage fields to apply when visually switching frames
	mMvC_SetDamageNext $06, HITTYPE_HIT_MID1, PF3_HEAVYHIT
	jp   .anim
; --------------- common ---------------	
.chkEnd:
	mMvC_ValFrameEnd .anim
	call Play_Pl_EndMove
	jr   .ret
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Goenitz_PunchH ===============
; Move code used for Goenitz's heavy punch, which hits 3 times.
;
; This is like Mature's heavy punch except for the extra hit on #4.
;
; See also: MoveC_Mature_PunchH	
MoveC_Goenitz_PunchH:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
	cp   $03*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj3
	cp   $04*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj4
; --------------- frame #0,#2,#5-(end) ---------------
	mMvC_ChkTarget .chkEnd
	jp   .anim
; --------------- frame #1 ---------------
.obj1:
	; The first time we get here, move 7px forward.
	mMvC_ValFrameStart .obj1_chkAdv
	mMvC_SetMoveH $0700
.obj1_chkAdv:
	; When visually switching to #2, use new damage info.
	mMvC_ValFrameEnd .anim ; About to advance the anim? If not, skip to .anim
	; Otherwise, request new damage fields to apply when visually switching frames
	mMvC_SetDamageNext $06, HITTYPE_HIT_MID1, $00
	jp   .anim
; --------------- frame #3 ---------------
.obj3:
	; The first time we get here, move 7px forward.
	mMvC_ValFrameStart .obj3_chkAdv
	mMvC_SetMoveH $0700
.obj3_chkAdv:
	; When visually switching to #2, use new damage info.
	mMvC_ValFrameEnd .anim ; About to advance the anim? If not, skip to .anim
	; Otherwise, request new damage fields to apply when visually switching frames
	mMvC_SetDamageNext $06, HITTYPE_HIT_MID0, PF3_HEAVYHIT
	jp   .anim
; --------------- frame #4 ---------------
.obj4:
	; The first time we get here, move 7px forward.
	mMvC_ValFrameStart .anim
	mMvC_SetMoveH $0700
	jp   .anim
; --------------- common ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
	call Play_Pl_EndMove
	jr   .ret
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
	
; =============== MoveC_Goenitz_PunchH ===============
; Move code used for Goenitz's heavy kick, which hits 2 times.	
MoveC_Goenitz_KickH:
	call Play_Pl_MoveByColiBoxOverlapX
	mMvC_ValLoaded .ret
	
	; Depending on the visible frame...
	ld   hl, iOBJInfo_OBJLstPtrTblOffsetView
	add  hl, de
	ld   a, [hl]
	cp   $01*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj1
	cp   $02*OBJLSTPTR_ENTRYSIZE
	jp   z, .obj2
; --------------- frame #0,#3-(end) ---------------
	mMvC_ChkTarget .chkEnd
	jp   .anim
; --------------- frame #1 ---------------
.obj1:
	; The first time we get here, move 7px forward.
	mMvC_ValFrameStart .anim
	mMvC_SetMoveH $0700
	jp   .anim
; --------------- frame #2 ---------------
.obj2:
	; The first time we get here, move 7px forward.
	mMvC_ValFrameStart .obj2_chkAdv
	mMvC_SetMoveH $0700
.obj2_chkAdv:
	mMvC_ValFrameEnd .anim ; About to advance the anim? If not, skip to .anim
	; Otherwise, request new damage fields to apply when visually switching frames
	mMvC_SetDamageNext $06, HITTYPE_HIT_MID1, PF3_HEAVYHIT
	jp   .anim
; --------------- common ---------------
.chkEnd:
	mMvC_ValFrameEnd .anim
	call Play_Pl_EndMove
	jr   .ret
.anim:
	jp   OBJLstS_DoAnimTiming_Loop_by_DE
.ret:
	ret
ENDC
	
IF ENGLISH == 0
; =============== END OF BANK ===============
; Junk area below.
; [TCRF] Contains win screen text from the English version of KOF95.
	mIncJunk "L1C7F4D"
ELSE


L1C7DCA: db $00
L1C7DCB: db $00
L1C7DCC: db $00
L1C7DCD: db $00
L1C7DCE: db $00
L1C7DCF: db $00
L1C7DD0: db $05
L1C7DD1: db $00
L1C7DD2: db $40
L1C7DD3: db $00
L1C7DD4: db $00
L1C7DD5: db $83
L1C7DD6: db $52
L1C7DD7: db $00
L1C7DD8: db $92
L1C7DD9: db $A0
L1C7DDA: db $00
L1C7DDB: db $00
L1C7DDC: db $42
L1C7DDD: db $04
L1C7DDE: db $00
L1C7DDF: db $22
L1C7DE0: db $FF
L1C7DE1: db $FF
L1C7DE2: db $FF
L1C7DE3: db $FF
L1C7DE4: db $FF
L1C7DE5: db $FF
L1C7DE6: db $FF
L1C7DE7: db $FF
L1C7DE8: db $FF
L1C7DE9: db $FF
L1C7DEA: db $FF
L1C7DEB: db $FF
L1C7DEC: db $FF
L1C7DED: db $FF
L1C7DEE: db $FF
L1C7DEF: db $FF
L1C7DF0: db $FF
L1C7DF1: db $FF
L1C7DF2: db $FF
L1C7DF3: db $FF
L1C7DF4: db $FF
L1C7DF5: db $FF
L1C7DF6: db $FF
L1C7DF7: db $FF
L1C7DF8: db $FF
L1C7DF9: db $FF
L1C7DFA: db $FF
L1C7DFB: db $FF
L1C7DFC: db $FF
L1C7DFD: db $FF
L1C7DFE: db $FF
L1C7DFF: db $FF
L1C7E00: db $00
L1C7E01: db $00
L1C7E02: db $00
L1C7E03: db $00
L1C7E04: db $00
L1C7E05: db $00
L1C7E06: db $00
L1C7E07: db $00
L1C7E08: db $00 ; M
L1C7E09: db $00
L1C7E0A: db $00
L1C7E0B: db $00
L1C7E0C: db $00
L1C7E0D: db $00
L1C7E0E: db $00
L1C7E0F: db $00
L1C7E10: db $01
L1C7E11: db $00
L1C7E12: db $40
L1C7E13: db $00
L1C7E14: db $00
L1C7E15: db $80
L1C7E16: db $00
L1C7E17: db $00
L1C7E18: db $10
L1C7E19: db $40
L1C7E1A: db $40
L1C7E1B: db $00
L1C7E1C: db $02
L1C7E1D: db $00
L1C7E1E: db $02
L1C7E1F: db $00
L1C7E20: db $FF
L1C7E21: db $FF
L1C7E22: db $FF
L1C7E23: db $FF
L1C7E24: db $FF ; M
L1C7E25: db $FF
L1C7E26: db $FF
L1C7E27: db $FF
L1C7E28: db $FF
L1C7E29: db $FD
L1C7E2A: db $FF
L1C7E2B: db $FF
L1C7E2C: db $FF
L1C7E2D: db $FF
L1C7E2E: db $FF
L1C7E2F: db $FF
L1C7E30: db $FF
L1C7E31: db $FF
L1C7E32: db $FF
L1C7E33: db $FF
L1C7E34: db $FF
L1C7E35: db $FF
L1C7E36: db $FF
L1C7E37: db $FF
L1C7E38: db $FF
L1C7E39: db $FF
L1C7E3A: db $FF
L1C7E3B: db $FF
L1C7E3C: db $FF
L1C7E3D: db $FF
L1C7E3E: db $FF
L1C7E3F: db $FF
L1C7E40: db $00
L1C7E41: db $00
L1C7E42: db $20
L1C7E43: db $00
L1C7E44: db $00 ; M
L1C7E45: db $00
L1C7E46: db $00
L1C7E47: db $00
L1C7E48: db $00
L1C7E49: db $00
L1C7E4A: db $00
L1C7E4B: db $00
L1C7E4C: db $00
L1C7E4D: db $00
L1C7E4E: db $00
L1C7E4F: db $00
L1C7E50: db $04
L1C7E51: db $00
L1C7E52: db $00
L1C7E53: db $04
L1C7E54: db $00
L1C7E55: db $80
L1C7E56: db $01
L1C7E57: db $08
L1C7E58: db $A1
L1C7E59: db $00
L1C7E5A: db $20
L1C7E5B: db $00
L1C7E5C: db $00 ; M
L1C7E5D: db $38
L1C7E5E: db $01
L1C7E5F: db $00
L1C7E60: db $FF ; M
L1C7E61: db $FF
L1C7E62: db $FF
L1C7E63: db $FF
L1C7E64: db $FF
L1C7E65: db $FF
L1C7E66: db $FF
L1C7E67: db $FF
L1C7E68: db $FF
L1C7E69: db $FF
L1C7E6A: db $FF
L1C7E6B: db $FF
L1C7E6C: db $FF
L1C7E6D: db $FF
L1C7E6E: db $FF
L1C7E6F: db $FF
L1C7E70: db $FF
L1C7E71: db $FF
L1C7E72: db $FF
L1C7E73: db $FF
L1C7E74: db $FF
L1C7E75: db $FF
L1C7E76: db $FF
L1C7E77: db $FF
L1C7E78: db $FF
L1C7E79: db $FF
L1C7E7A: db $FF
L1C7E7B: db $FF
L1C7E7C: db $FF
L1C7E7D: db $FF
L1C7E7E: db $FF
L1C7E7F: db $FF
L1C7E80: db $00
L1C7E81: db $00
L1C7E82: db $00
L1C7E83: db $00
L1C7E84: db $00
L1C7E85: db $00
L1C7E86: db $00
L1C7E87: db $00
L1C7E88: db $00
L1C7E89: db $00
L1C7E8A: db $01
L1C7E8B: db $00
L1C7E8C: db $00
L1C7E8D: db $00
L1C7E8E: db $00
L1C7E8F: db $00
L1C7E90: db $40
L1C7E91: db $08
L1C7E92: db $00
L1C7E93: db $00
L1C7E94: db $02
L1C7E95: db $20
L1C7E96: db $0C
L1C7E97: db $02
L1C7E98: db $C0 ; M
L1C7E99: db $50
L1C7E9A: db $00
L1C7E9B: db $08
L1C7E9C: db $22
L1C7E9D: db $00
L1C7E9E: db $20
L1C7E9F: db $84
L1C7EA0: db $FF
L1C7EA1: db $FF
L1C7EA2: db $FF
L1C7EA3: db $FF ; M
L1C7EA4: db $FF
L1C7EA5: db $FF
L1C7EA6: db $FF
L1C7EA7: db $FF
L1C7EA8: db $FF
L1C7EA9: db $FB
L1C7EAA: db $FF
L1C7EAB: db $FF
L1C7EAC: db $FF
L1C7EAD: db $FF
L1C7EAE: db $FF
L1C7EAF: db $FF
L1C7EB0: db $FF
L1C7EB1: db $FF
L1C7EB2: db $FF
L1C7EB3: db $FF
L1C7EB4: db $FF
L1C7EB5: db $FF
L1C7EB6: db $FF
L1C7EB7: db $FF
L1C7EB8: db $FF
L1C7EB9: db $FF
L1C7EBA: db $FF
L1C7EBB: db $FF
L1C7EBC: db $FF
L1C7EBD: db $FF
L1C7EBE: db $FF
L1C7EBF: db $FF
L1C7EC0: db $00
L1C7EC1: db $00
L1C7EC2: db $00
L1C7EC3: db $00
L1C7EC4: db $00
L1C7EC5: db $00
L1C7EC6: db $00
L1C7EC7: db $00
L1C7EC8: db $00
L1C7EC9: db $00
L1C7ECA: db $00
L1C7ECB: db $00
L1C7ECC: db $00
L1C7ECD: db $00
L1C7ECE: db $00
L1C7ECF: db $00
L1C7ED0: db $00
L1C7ED1: db $81
L1C7ED2: db $04
L1C7ED3: db $00
L1C7ED4: db $08
L1C7ED5: db $00
L1C7ED6: db $40
L1C7ED7: db $04
L1C7ED8: db $04
L1C7ED9: db $94
L1C7EDA: db $08
L1C7EDB: db $89
L1C7EDC: db $00
L1C7EDD: db $64
L1C7EDE: db $00
L1C7EDF: db $0A
L1C7EE0: db $FF
L1C7EE1: db $FF
L1C7EE2: db $FF
L1C7EE3: db $FF
L1C7EE4: db $FF
L1C7EE5: db $FF
L1C7EE6: db $FF
L1C7EE7: db $FF
L1C7EE8: db $FF
L1C7EE9: db $FF
L1C7EEA: db $FF
L1C7EEB: db $FF
L1C7EEC: db $FF
L1C7EED: db $FF
L1C7EEE: db $FF
L1C7EEF: db $FF
L1C7EF0: db $FF
L1C7EF1: db $FF
L1C7EF2: db $FF
L1C7EF3: db $FF
L1C7EF4: db $FF
L1C7EF5: db $FF
L1C7EF6: db $FF
L1C7EF7: db $FF
L1C7EF8: db $FF
L1C7EF9: db $FF
L1C7EFA: db $FF
L1C7EFB: db $FF
L1C7EFC: db $FF
L1C7EFD: db $FF
L1C7EFE: db $FF
L1C7EFF: db $FF
L1C7F00: db $00
L1C7F01: db $00
L1C7F02: db $00
L1C7F03: db $00
L1C7F04: db $00
L1C7F05: db $00
L1C7F06: db $00
L1C7F07: db $00
L1C7F08: db $00
L1C7F09: db $00
L1C7F0A: db $00
L1C7F0B: db $00
L1C7F0C: db $00
L1C7F0D: db $00
L1C7F0E: db $00
L1C7F0F: db $00
L1C7F10: db $02
L1C7F11: db $00
L1C7F12: db $00
L1C7F13: db $00
L1C7F14: db $00
L1C7F15: db $00
L1C7F16: db $20
L1C7F17: db $80
L1C7F18: db $02
L1C7F19: db $02
L1C7F1A: db $01
L1C7F1B: db $06
L1C7F1C: db $08
L1C7F1D: db $00
L1C7F1E: db $01
L1C7F1F: db $01
L1C7F20: db $FF
L1C7F21: db $FF
L1C7F22: db $FF
L1C7F23: db $FF
L1C7F24: db $FF
L1C7F25: db $FF
L1C7F26: db $FF
L1C7F27: db $FF
L1C7F28: db $FF
L1C7F29: db $FF
L1C7F2A: db $FF
L1C7F2B: db $FF
L1C7F2C: db $FF
L1C7F2D: db $FF
L1C7F2E: db $FF
L1C7F2F: db $7F
L1C7F30: db $FF
L1C7F31: db $FF
L1C7F32: db $FF
L1C7F33: db $FF
L1C7F34: db $FF
L1C7F35: db $FF
L1C7F36: db $FF
L1C7F37: db $FF
L1C7F38: db $FF
L1C7F39: db $FF
L1C7F3A: db $FF
L1C7F3B: db $FF
L1C7F3C: db $FF
L1C7F3D: db $FF
L1C7F3E: db $FF
L1C7F3F: db $FF
L1C7F40: db $00
L1C7F41: db $00
L1C7F42: db $00
L1C7F43: db $00
L1C7F44: db $00
L1C7F45: db $00
L1C7F46: db $00
L1C7F47: db $00
L1C7F48: db $00
L1C7F49: db $10
L1C7F4A: db $00
L1C7F4B: db $08
L1C7F4C: db $00
L1C7F4D: db $00
L1C7F4E: db $00
L1C7F4F: db $00
L1C7F50: db $0C
L1C7F51: db $8A
L1C7F52: db $00
L1C7F53: db $10
L1C7F54: db $09
L1C7F55: db $11
L1C7F56: db $00
L1C7F57: db $00
L1C7F58: db $00 ; M
L1C7F59: db $00
L1C7F5A: db $00
L1C7F5B: db $41
L1C7F5C: db $26
L1C7F5D: db $10
L1C7F5E: db $44
L1C7F5F: db $08
L1C7F60: db $FF
L1C7F61: db $FF
L1C7F62: db $FF
L1C7F63: db $FF
L1C7F64: db $FF
L1C7F65: db $FF
L1C7F66: db $FF
L1C7F67: db $FF
L1C7F68: db $FF
L1C7F69: db $FF
L1C7F6A: db $FF
L1C7F6B: db $FF
L1C7F6C: db $FF
L1C7F6D: db $FF
L1C7F6E: db $FF
L1C7F6F: db $FF
L1C7F70: db $FF
L1C7F71: db $FF
L1C7F72: db $FF
L1C7F73: db $FF
L1C7F74: db $FF
L1C7F75: db $FF
L1C7F76: db $FF
L1C7F77: db $FF
L1C7F78: db $FF
L1C7F79: db $FF
L1C7F7A: db $FF
L1C7F7B: db $FF
L1C7F7C: db $FF
L1C7F7D: db $FF
L1C7F7E: db $FF
L1C7F7F: db $FF
L1C7F80: db $00
L1C7F81: db $00
L1C7F82: db $00
L1C7F83: db $00
L1C7F84: db $00
L1C7F85: db $00
L1C7F86: db $00
L1C7F87: db $00
L1C7F88: db $00
L1C7F89: db $00
L1C7F8A: db $00
L1C7F8B: db $00
L1C7F8C: db $00
L1C7F8D: db $00
L1C7F8E: db $00
L1C7F8F: db $00
L1C7F90: db $20
L1C7F91: db $05
L1C7F92: db $40
L1C7F93: db $40
L1C7F94: db $01
L1C7F95: db $02
L1C7F96: db $20
L1C7F97: db $00 ; M
L1C7F98: db $80
L1C7F99: db $10
L1C7F9A: db $00
L1C7F9B: db $00
L1C7F9C: db $00
L1C7F9D: db $20
L1C7F9E: db $00
L1C7F9F: db $00 ; M
L1C7FA0: db $FF
L1C7FA1: db $FF
L1C7FA2: db $FF
L1C7FA3: db $FF
L1C7FA4: db $FF
L1C7FA5: db $FF
L1C7FA6: db $FF
L1C7FA7: db $FF
L1C7FA8: db $FF
L1C7FA9: db $FF
L1C7FAA: db $FF
L1C7FAB: db $FF
L1C7FAC: db $FF
L1C7FAD: db $FF
L1C7FAE: db $FF
L1C7FAF: db $FF
L1C7FB0: db $FF
L1C7FB1: db $FF
L1C7FB2: db $FF
L1C7FB3: db $FF
L1C7FB4: db $FF
L1C7FB5: db $FF
L1C7FB6: db $FF
L1C7FB7: db $FF
L1C7FB8: db $FF
L1C7FB9: db $FF
L1C7FBA: db $FF
L1C7FBB: db $FF
L1C7FBC: db $FF
L1C7FBD: db $FF
L1C7FBE: db $FF
L1C7FBF: db $FF
L1C7FC0: db $00
L1C7FC1: db $00
L1C7FC2: db $00
L1C7FC3: db $00
L1C7FC4: db $00
L1C7FC5: db $00
L1C7FC6: db $00
L1C7FC7: db $00
L1C7FC8: db $00
L1C7FC9: db $20
L1C7FCA: db $00
L1C7FCB: db $00 ; M
L1C7FCC: db $00
L1C7FCD: db $00
L1C7FCE: db $00
L1C7FCF: db $00
L1C7FD0: db $55
L1C7FD1: db $94
L1C7FD2: db $20
L1C7FD3: db $84
L1C7FD4: db $84
L1C7FD5: db $00
L1C7FD6: db $80
L1C7FD7: db $00
L1C7FD8: db $00
L1C7FD9: db $01
L1C7FDA: db $00
L1C7FDB: db $20
L1C7FDC: db $00
L1C7FDD: db $50
L1C7FDE: db $08
L1C7FDF: db $80
L1C7FE0: db $FF
L1C7FE1: db $FF
L1C7FE2: db $FF
L1C7FE3: db $FF
L1C7FE4: db $F3
L1C7FE5: db $BF
L1C7FE6: db $FF
L1C7FE7: db $FF
L1C7FE8: db $F7
L1C7FE9: db $FD
L1C7FEA: db $FF
L1C7FEB: db $FF
L1C7FEC: db $FF
L1C7FED: db $FF
L1C7FEE: db $9F
L1C7FEF: db $FF
L1C7FF0: db $FF
L1C7FF1: db $FF
L1C7FF2: db $FF
L1C7FF3: db $FF
L1C7FF4: db $FF
L1C7FF5: db $FF
L1C7FF6: db $FF
L1C7FF7: db $FF
L1C7FF8: db $FF
L1C7FF9: db $FF
L1C7FFA: db $FF
L1C7FFB: db $FF
L1C7FFC: db $FF
L1C7FFD: db $FF
L1C7FFE: db $FF
L1C7FFF: db $FF
ENDC