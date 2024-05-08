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
	
IF REV_LOGO_EN == 0
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
	
	; FarCall to self bank. In 95, this subroutine was in a different bank.
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
IF REV_LOGO_EN == 0
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
IF REV_LOGO_EN == 0
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
IF REV_LOGO_EN == 0
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
IF REV_LOGO_EN == 0
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
IF REV_LOGO_EN == 1
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
IF REV_LOGO_EN == 0
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
IF REV_VER_2 == 1
	call ModeSelect_CheckEndlessCpuVsCpuMode		; Full watch mode?
	jp   c, .startSingleVS							; If so, skip the serial checks (no 2P inputs required)
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
IF REV_VER_2 == 0
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
IF REV_VER_2 == 1
	call ModeSelect_CheckEndlessCpuVsCpuMode		; Full watch mode?
	jp   c, .startTeamVS							; If so, skip the serial checks (no 2P inputs required)
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
IF REV_VER_2 == 0
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
IF REV_VER_2 == 0
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

IF REV_VER_2 == 0	
; [TCRF] Unreferenced code.
;        Sets up a CPU vs CPU battle in VS mode, which in the Japanese version
;        can't be triggered by one player.
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
Options_Item_BGMTest:
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
	
; =============== Options_Item_SFXTest ===============
Options_Item_SFXTest:
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
	ret ; We never get here
	
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
IF REV_LOGO_EN == 0
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
IF REV_LOGO_EN == 0
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
	
IF REV_VER_2 == 1
; =============== ModeSelect_CheckEndlessCpuVsCpuMode ===============
; Initializes the CPU/Human player status for VS mode.
;
; [POI] Also handles the secret where holding LEFT+B enables alternate CPU vs CPU battle in VS mode (aka Watch Mode).
;
;       Having both players set as CPU in a VS mode triggers a special case that causes the following:
;       - Both players automatically pick their team members.
;         Normally, even with a single CPU player, both sides have to manually pick their characters.
;       - Team order is autoselected
;       - When a round ends, both teams are cleared, forcing to autopick new ones.
;         In VS mode, normally, both teams stay as-is between matches unless you explicitly select new ones.
;
;       While the code to handle the mode existed in the Japanese version, it could only be done
;       by having both players hold B when selecting a VS mode, and even then it was disallowed on
;       the DMG/serial cable since the normal CPU vs CPU code is disabled there.
;       Note that, in 95, the DMG/serial cable wasn't blacklisted.
;
;       The existing checks are still in the English version, but since this mode doesn't require
;       a second player, a new code was added that allows to enter the mode with a single DMG.
;
;       Newer games using this engine (ie: Real Bout Fatal Fury) would use an invisible menu option
;       enabled through dipswitches instead of a code, but worked identically otherwise.
; OUT
; - C flag: If set, CPU vs CPU is enabled.
ModeSelect_CheckEndlessCpuVsCpuMode:
	; Default with both human players
	ld   hl, wPlInfo_Pl1+iPlInfo_Flags0
	res  PF0B_CPU, [hl]
	ld   hl, wPlInfo_Pl2+iPlInfo_Flags0
	res  PF0B_CPU, [hl]
	
	; If we're holding LEFT+B, turn both players into a CPU.
	; Since such a mode requires no inputs from the other side, it is allowed even if no DMG is connected.
	; The return value has the purpose of telling whoever's calling this to skip the serial cable checks.
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
IF REV_LOGO_EN == 0
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
	cp   $0F				; Did we get Kagura's slot? ($0F's character in the sequence)
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
	db .end-.start
.start:
	db "GAME SELECT"
.end:
TextDef_Menu_SinglePlay:
	dw $9924
	db .end-.start
.start:
	db "SINGLE PLAY"
.end:
TextDef_Menu_TeamPlay:
	dw $9964
	db .end-.start
.start:
	db "TEAM PLAY"
.end:
TextDef_Menu_SingleVS: 
	dw $99A4
	db $09
	db "SINGLE VS"
.end:
TextDef_Menu_TeamVS:
	dw $99E4
	db .end-.start
.start:
	db "TEAM VS"
.end:
TextDef_Options_Title:
	dw $98B7
	db .end-.start
.start:
	db "OPTION"
.end:
TextDef_Options_Time:
	dw $98F4
	db .end-.start
.start:
	db "TIME      XX"
.end:
TextDef_Options_Level:
	dw $9934
	db .end-.start
.start:
	db "LEVEL NORMAL"
.end:
TextDef_Options_BGMTest:
	dw $9974
	db .end-.start
.start:
	db "BGM TEST  XX"
.end:
TextDef_Options_SFXTest:
	dw $99B4
	db .end-.start
.start:
	db "S.E.TEST  XX"
.end:
TextDef_Options_SGBSndTest:
	dw $99F4
	db .end-.start
.start:
	db "SGB S.E.TEST"
.end:
TextDef_Options_Exit:
	dw $9A94
	db .end-.start
.start:
	db "EXIT"
.end:
TextDef_Options_Dip:
	dw $9AB8
	db .end-.start
.start:
	db "DIPSW-00"
.end:
TextDef_Options_Off:
	dw $98FD
	db .end-.start
.start:
	db "OFF"
.end:
; Removes the O from OFF when printing a number
TextDef_Options_ClrOff:
	dw $98FD
	db .end-.start
.start:
	db " "
.end:
TextDef_Options_Easy:
	dw $993A
	db .end-.start
.start:
	db "  EASY"
.end:
TextDef_Options_Normal:
	dw $993A
	db .end-.start
.start:
	db "NORMAL"
.end:
TextDef_Options_Hard:
	dw $993A
	db .end-.start
.start:
	db "  HARD"
.end:
TextDef_Options_SGBSndTypes:
	dw $9A36
	db .end-.start
.start:
	db "SE-A  SE-B"
.end:
TextDef_Options_SGBSndPlaceholders: 
	dw $9A56
	db $0A
	db "XX X  XX X"
.end:

; NumberPrinter_Instant always prints two digits.
; These spaces are used to cover the upper digit for the SGB sound test.
TextDef_Options_ClrSGBSndA:
	dw $9A58
	db .end-.start
.start:
	db " "
.end:
TextDef_Options_ClrSGBSndB:
	dw $9A5E
	db .end-.start
.start:
	db " "
.end:
	
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

IF REV_LANG_EN == 0

; Got moved below in the English version for whatever reason.

; =============== Title_LoadVRAM ===============
; Loads tilemaps and GFX for the title screen.
; The menus load the 1bpp text over this, and reuse the cursor already loaded here.
Title_LoadVRAM:
	; Title screen & menu sprites
	ld   hl, GFXDef_TitleOBJ 
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
	
IF REV_LOGO_EN == 0
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

GFXDef_TitleOBJ: mGfxDef "data/gfx/title_obj.bin"

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
			call Intro_Delay
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
	call Intro_Delay
	
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
	call Intro_Delay
	
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
		call Intro_Delay
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
		call Intro_Delay
	pop  af
	dec  a			; Are we done?
	jr   nz, .loop	; If not, loop
	
	; Wait $78 frames
	ld   a, $78
	call Intro_Delay
	
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
		call Intro_Delay
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
		call Intro_Delay
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
	call Intro_Delay
	
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
	
; =============== Intro_Delay ===============
; Pauses/delays the cutscene for the specified amount of frames.
; While this happens, it checks for the START button, which, if pressed,
; ends the intro early.
; IN
; - A: Frames to wait
Intro_Delay:
	push af
		call Intro_Base_IsStartPressed			; Pressed START?
		jp   c, Intro_End						; If so, end the intro
		call Task_PassControl_NoDelay
	pop  af
	dec  a										; Waited all frames?
	jp   nz, Intro_Delay						; If not, loop
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
	
TextC_Win_Marker:
IF REV_LANG_EN == 0
TextC_Win_Kyo:
	db .end-.start
.start:
	db "なってねえ!", C_NL
	db C_NL
	db "おれとふﾞつかってそのていとﾞてﾞ", C_NL
	db C_NL
	db "すんたﾞのはきせきてきたﾞな。", C_NL
.end:
TextC_Win_Daimon:
	db .end-.start
.start:
	db "わさﾞはそれほとﾞ", C_NL
	db C_NL
	db "しﾞゅうようてﾞはない!", C_NL
	db C_NL
	db "すへﾞてはこころのもちようたﾞ!", C_NL
.end:
TextC_Win_Terry:
	db .end-.start
.start:
	db "おれのなかにいるおおかみを", C_NL
	db C_NL
	db "おこしちまったようたﾞな。", C_NL
	db C_NL
	db "わるくおもうなよ!", C_NL
.end:
TextC_Win_Andy:
	db .end-.start
.start:
	db "ひつようなのはかくこﾞ!", C_NL
	db C_NL
	db "そのいしさえあれはﾞまけはしない!", C_NL
.end:
TextC_Win_Ryo:
	db .end-.start
.start:
	db "きょくけﾞんリゅうはきょくけﾞんに", C_NL
	db C_NL
	db "おいてのみはっするちからのけﾞい", C_NL
	db C_NL
	db "しﾞゅつたﾞ!やすやすとおちはしない", C_NL
.end:
TextC_Win_Robert:
	db .end-.start
.start:
	db "とﾞないした?", C_NL
	db C_NL
	db "かおかﾞゆめうつつっちゅうかんしﾞ", C_NL
	db C_NL
	db "やてﾞ。 しゃきっとせな!", C_NL
.end:
TextC_Win_Athena:
	db .end-.start
.start:
	db "つきﾞかﾞあったならまたたたかい", C_NL
	db C_NL
	db "ましょう。", C_NL
	db C_NL
	db "たのしみにまってます!", C_NL
.end:
TextC_Win_Mai:
	db .end-.start
.start:
	db "まあ、ほんきをちょっとたﾞせはﾞ", C_NL
	db C_NL
	db "かるいかるい! しらぬいリゅう", C_NL
	db C_NL
	db "にんしﾞゅつ、さいきょうってとこね!", C_NL
.end:
TextC_Win_Leona:
	db .end-.start
.start:
	db "あなたはしなないわ。", C_NL
	db C_NL
	db "ここはせんしﾞょうしﾞゃないもの。", C_NL
.end:
TextC_Win_Geese:
	db .end-.start
.start:
	db "あっとうてきなちからにしはいされる", C_NL
	db C_NL
	db "のは、とﾞんなきもちたﾞ!", C_NL
	db C_NL
	db "さあ! おそれるかﾞいい!", C_NL
.end:
TextC_Win_Krauser:
	db .end-.start
.start:
	db "わたしをたおせるならせかいさいきょう", C_NL
	db C_NL
	db "はまちかﾞいないたﾞろう!", C_NL
	db C_NL
	db "かてれはﾞのはなしたﾞかﾞな!", C_NL
.end:
TextC_Win_MrBig:
	db .end-.start
.start:
	db "ヒｰロｰにてﾞも、なったつもリか!", C_NL
	db C_NL
	db "おかしくてなみたﾞかﾞとまらんそﾞ!", C_NL
.end:
TextC_Win_Iori:
	db .end-.start
.start:
	db "はﾞかにつけるくすリはないというかﾞ", C_NL
	db C_NL
	db "まるてﾞおまえたちのことを", C_NL
	db C_NL
	db "いっているようたﾞ!", C_NL
.end:
TextC_Win_Mature:
	db .end-.start
.start:
	db "あなたたちもゆめをみるてﾞしょ。", C_NL
	db C_NL
	db "さあえいえんのゆめのせかいにあんない", C_NL
	db C_NL
	db "してあけﾞるわ!", C_NL
.end:
TextC_Win_Chizuru:
	db .end-.start
.start:
	db "あなたたちはほんとうのちからかﾞ", C_NL
	db C_NL
	db "なにかをしらないようね。", C_NL
	db C_NL
	db "それてﾞはわたしはたおせない。", C_NL
.end:
TextC_Win_Goenitz:
	db .end-.start
.start:
	db "せかいかﾞそﾞうおのなかてﾞもえてい", C_NL
	db C_NL
	db "ます。 しんのこんとんはおさめる", C_NL
	db C_NL
	db "ことはふかのうてﾞす。", C_NL
.end:
TextC_Win_MrKarate:
	db .end-.start
.start:
	db "なんとﾞてﾞもいおう!", C_NL
	db C_NL
	db "わかﾞきょくけﾞんリゅうに", C_NL
	db C_NL
	db "てきはいない。", C_NL
.end:
TextC_Win_OIori:
	db .end-.start
.start:
	db "くﾞうおおおううう!!", C_NL
.end:
TextC_Win_OLeona:
	db .end-.start
.start:
	db "・・・・・・・・・・", C_NL
.end:
TextC_Win_Kagura:
	db .end-.start
.start:
	db "なにこﾞとにもせﾞんリょくてﾞ", C_NL
	db C_NL
	db "いとﾞむ! それかﾞいつかしょうリ", C_NL
	db C_NL
	db "するきほﾞうにつなかﾞるのよ。", C_NL
.end:
TextC_CutsceneKagura0:
	db .end-.start
.start:
	db "おめてﾞとうこﾞさﾞいます。", C_NL
	db C_NL
	db "すはﾞらしいしあいてﾞしたわ。", C_NL
.end:
TextC_CutsceneKagura1:
	db .end-.start
.start:
	db "わたしのなは、かくﾞらちつﾞる・・・", C_NL
	db C_NL
	db "こんたいかいをしゅさいしたものてﾞす", C_NL
.end:
TextC_CutsceneKagura2:
	db .end-.start
.start:
	db "RUGALをたおしたそのちから", C_NL
	db C_NL
	db "のほとﾞはいけんしたかった", C_NL
	db C_NL
	db "のてﾞすかﾞ。", C_NL
.end:
TextC_CutsceneKagura3:
	db .end-.start
.start:
	db "あなたたちのほんとうのちからかﾞ", C_NL
	db C_NL
	db "みたいわ。", C_NL
.end:
TextC_CutsceneKagura4:
	db .end-.start
.start:
	db "トｰナメントてﾞみせたのかﾞ", C_NL
	db C_NL
	db "しﾞつリょくというのなら", C_NL
	db C_NL
	db "はなしはへﾞつたﾞけとﾞ・・・。", C_NL
.end:
TextC_CutsceneGoenitz00:
	db .end-.start
.start:
	db "なせﾞRUGALのことを!?", C_NL
.end:
TextC_CutsceneGoenitz01:
	db .end-.start
.start:
	db "RUGALかﾞてにいれようとして", C_NL
	db C_NL
	db "てﾞきなかったオロチのちから。", C_NL
.end:
TextC_CutsceneGoenitz02:
	db .end-.start
.start:
	db "ふうしﾞられし、そのちからを", C_NL
	db C_NL
	db "わたしはまもってきた。", C_NL
.end:
TextC_CutsceneGoenitz03:
	db .end-.start
.start:
	db "それをRUGALかﾞかいほうした?", C_NL
.end:
TextC_CutsceneGoenitz04:
	db .end-.start
.start:
	db "RUGALは、かいほうされたちからを", C_NL
	db C_NL
	db "よこからうはﾞいとったたﾞけ。", C_NL
.end:
TextC_CutsceneGoenitz05:
	db .end-.start
.start:
	db "それと、あなたとたたかったことと", C_NL
	db C_NL
	db "とﾞういうかんけいかﾞ?", C_NL
.end:
TextC_CutsceneGoenitz06:
	db .end-.start
.start:
	db "あなたたちのしﾞつリょくをみるために", C_NL
	db C_NL
	db "ト-ナメントをひらいた。", C_NL
.end:
TextC_CutsceneGoenitz07:
	db .end-.start
.start:
	db "なんのために?", C_NL
.end:
TextC_CutsceneGoenitz08:
	db .end-.start
.start:
	db "オロチのちからをふうしﾞるのに、", C_NL
	db C_NL
	db "あなたのちからをかしてほしいのよ。", C_NL
	db C_NL
	db "しﾞかんはもうないわ。", C_NL
.end:
TextC_CutsceneGoenitz09:
	db .end-.start
.start:
	db "けはいてﾞわかるの。", C_NL
	db C_NL
	db "もうそこまてﾞきている・・・。", C_NL
.end:
TextC_CutsceneGoenitz0A:
	db .end-.start
.start:
	db "きている?", C_NL
.end:
TextC_CutsceneGoenitz0B:
	db .end-.start
.start:
	db "そう・・・。ふうしﾞられていた", C_NL
	db C_NL
	db "オロチをかいほうしたおとこ・・・。", C_NL
.end:
TextC_CutsceneGoenitz0C:
	db .end-.start
.start:
	db "な、なに!?  かせﾞかﾞ!?", C_NL
.end:
TextC_CutsceneGoenitz0D:
	db .end-.start
.start:
	db "うわあｰ!", C_NL
.end:
TextC_CutsceneGoenitz0E:
	db .end-.start
.start:
	db "さすかﾞてﾞすね。これくﾞらいてﾞは", C_NL
	db C_NL
	db "とﾞうということはあリませんか・・・", C_NL
.end:
TextC_CutsceneGoenitz0F:
	db .end-.start
.start:
	db "たﾞれ?", C_NL
.end:
TextC_CutsceneGoenitz10:
	db .end-.start
.start:
	db "はしﾞめまして。", C_NL
	db C_NL
	db "GOENITZともうします.", C_NL
.end:
TextC_CutsceneGoenitz11:
	db .end-.start
.start:
	db "いままてﾞのことは、はいけんさせて", C_NL
	db C_NL
	db "いたたﾞきました。", C_NL
	db C_NL
	db "しかし、むたﾞてﾞす。", C_NL
.end:
TextC_CutsceneGoenitz12:
	db .end-.start
.start:
	db "あなたたちにはなにもてﾞきません。", C_NL
	db C_NL
	db "とくへﾞつにせんたくしをあけﾞます。", C_NL
.end:
TextC_CutsceneGoenitz13:
	db .end-.start
.start:
	db "たたかわすﾞにしぬか、", C_NL
	db C_NL
	db "たたかってしぬか。", C_NL
.end:
TextC_CutsceneGoenitz14:
	db .end-.start
.start:
	db "とﾞちらてﾞもない!", C_NL
	db C_NL
	db "たたかってかつ!!", C_NL
.end:
TextC_Ending_Generic0:
	db .end-.start
.start:
	db "おとﾞろきてﾞすね。", C_NL
	db C_NL
	db "これほとﾞとは・・・", C_NL
.end:
TextC_Ending_Generic1:
	db .end-.start
.start:
	db "しかし、あなたかﾞたのててﾞオロチを", C_NL
	db C_NL
	db "ふうしﾞようなとﾞとはかんかﾞえない", C_NL
	db C_NL
	db "ことてﾞす。", C_NL
.end:
TextC_Ending_Generic2:
	db .end-.start
.start:
	db "てをひくことをおすすめしますよ。", C_NL
.end:
TextC_Ending_Generic3:
	db .end-.start
.start:
	db "ふうしﾞてみせるわ。", C_NL
	db C_NL
	db "かならすﾞ・・・。", C_NL
.end:
TextC_Ending_Generic4:
	db .end-.start
.start:
	db "かちきなおかたたﾞ・・・。", C_NL
	db C_NL
	db "いいかせﾞかﾞきました。", C_NL
	db C_NL
	db "そろそろころあいてﾞす。", C_NL
.end:
TextC_Ending_Generic5:
	db .end-.start
.start:
	db "にけﾞる!?", C_NL
.end:
TextC_Ending_GoenitzLeave0:
	db .end-.start
.start:
	db "いえ、めされるのてﾞす。", C_NL
.end:
TextC_Ending_GoenitzLeave2:
	db .end-.start
.start:
	db "・・・てん へ。", C_NL
.end:
TextC_CutsceneGoenitz0C_Easy:
	db .end-.start
.start:
	db "このくﾞらいのしﾞつリょくてﾞは、", C_NL
	db C_NL
	db "わたしかﾞてﾞるまてﾞもあリません。", C_NL
.end:
TextC_CutsceneGoenitz0D_Easy:
	db .end-.start
.start:
	db "NORMALいしﾞょうてﾞ", C_NL
	db C_NL
	db "おあいしましょう・・・。", C_NL
.end:
TextC_Ending_GoenitzLeave1:
	db .end-.start
.start:
	db "                    ", C_NL
.end:
TextC_Ending_KaguraGeneric0:
	db .end-.start
.start:
	db "みなさん、あリかﾞとう。", C_NL
	db C_NL
	db "これてﾞあのおとこのけﾞんそうも", C_NL
	db C_NL
	db "きえました。", C_NL
.end:
TextC_Ending_KaguraGeneric1:
	db .end-.start
.start:
	db "てﾞも、くらやみてﾞうこﾞめくもの", C_NL
	db C_NL
	db "とﾞもは、いつ、ひとひﾞとをそのやみ", C_NL
	db C_NL
	db "につつみこもうとするかわかリません。", C_NL
.end:
TextC_Ending_KaguraGeneric2:
	db .end-.start
.start:
	db "それは、ちかいしょうらい、おとすﾞ", C_NL
	db C_NL
	db "れるかも・・・。  そのときは、", C_NL
	db C_NL
	db "また、おあいしましょう。", C_NL
.end:
TextC_CheatList:
	db .end-.start
.start:
	db "TAKARAロコﾞのひょうしﾞ", C_NL
	db C_NL
	db "ちゅうにSELECTホﾞタンを", C_NL
	db C_NL
	db "3かいおすと、", C_NL
	db C_NL
	db "GOENITZかﾞしようてﾞきます。", C_NL
.end:
ELSE
TextC_Win_Kyo:
	db .end-.start
.start:
	db "You were lucky to", C_NL
	db " take me on and get", C_NL
	db " off this easily.", C_NL
.end:
TextC_Win_Daimon:
	db .end-.start
.start:
	db "Moves aren`t that", C_NL
	db " important. It`s", C_NL
	db " your attitude that", C_NL
	db " counts.", C_NL
.end:
TextC_Win_Terry:
	db .end-.start
.start:
	db "Don`t take it too", C_NL
	db " hard - you awakened", C_NL
	db " the wolf in me.", C_NL
.end:
TextC_Win_Andy:
	db .end-.start
.start:
	db "IF you`re totally", C_NL
	db " focused and", C_NL
	db " determined to win,", C_NL
	db " victory will be", C_NL
	db " yours!", C_NL
.end:
TextC_Win_Ryo:
	db .end-.start
.start:
	db "Kyokugen karate is", C_NL
	db " the art of ultimate", C_NL
	db " power!", C_NL
	db "You can`t beat it", C_NL
	db " that easily!", C_NL
.end:
TextC_Win_Robert:
	db .end-.start
.start:
	db "Hey,are you", C_NL
	db " day-dreaming or", C_NL
	db " that? ", C_NL
	db "Snap out of it!", C_NL
.end:
TextC_Win_Athena:
	db .end-.start
.start:
	db "Let`s fight again if", C_NL
	db " we have the chance.", C_NL
	db "I`m looking forward", C_NL
	db " to it!", C_NL
.end:
TextC_Win_Mai:
	db .end-.start
.start:
	db "When I put my mind", C_NL
	db " to it it`s a piece", C_NL
	db " of cake!", C_NL
.end:
TextC_Win_Leona:
	db .end-.start
.start:
	db "You will not die.", C_NL
	db "This is not a", C_NL
	db "        battlefield.", C_NL
.end:
TextC_Win_Geese:
	db .end-.start
.start:
	db "How does it feel to", C_NL
	db " be ruled by", C_NL
	db " ultimate power!", C_NL
	db "Be afraid - very", C_NL
	db "             afraid!", C_NL
.end:
TextC_Win_Krauser:
	db .end-.start
.start:
	db "Defeating me would", C_NL
	db " make you the", C_NL
	db " strongest in the", C_NL
	db " world - but it", C_NL
	db " isn`t easy to do !", C_NL
.end:
TextC_Win_MrBig:
	db .end-.start
.start:
	db "So you were planning", C_NL
	db " on becoming a hero?", C_NL
	db "That`s so funny it", C_NL
	db " makes me want", C_NL
	db "             to cry!", C_NL
.end:
TextC_Win_Iori:
	db .end-.start
.start:
	db "There`s no cure for", C_NL
	db " a fool.", C_NL
	db "A perfect", C_NL
	db " description of you!", C_NL
.end:
TextC_Win_Mature:
	db .end-.start
.start:
	db "You have dreams too,", C_NL
	db " do you not?", C_NL
	db "Let me guide you now", C_NL
	db " to the land of ", C_NL
	db "     eternal dreams!", C_NL
.end:
TextC_Win_Chizuru:
	db .end-.start
.start:
	db "You do not seem to", C_NL
	db " know what real", C_NL
	db " power is.", C_NL
	db "That is why you", C_NL
	db " cannot defeat me.", C_NL
.end:
TextC_Win_Goenitz:
	db .end-.start
.start:
	db "The world burns with", C_NL
	db " malice and hatred.", C_NL
	db "There is no way to", C_NL
	db " overcome true", C_NL
	db "              chaos.", C_NL
.end:
TextC_Win_MrKarate:
	db .end-.start
.start:
	db "I`ll say it again !", C_NL
	db "My Kyokugen karate", C_NL
	db " is invincible!", C_NL
.end:
TextC_Win_OIori:
	db .end-.start
.start:
	db C_NL
	db C_NL
	db "KKKyyyoooeeee----!!!", C_NL
.end:
TextC_Win_OLeona:
	db .end-.start
.start:
	db C_NL
	db C_NL
	db "..........", C_NL
.end:
TextC_Win_Kagura:
	db .end-.start
.start:
	db "Rise to every", C_NL
	db " challenge with your", C_NL
	db " full power,and", C_NL
	db " eventually you will", C_NL
	db " achieve victry!", C_NL
.end:
TextC_CutsceneGoenitz00:
	db .end-.start
.start:
	db "Why Rugal...?!", C_NL
.end:
TextC_CutsceneGoenitz01:
	db .end-.start
.start:
	db "Rugal tried to steal", C_NL
	db " the power of Orochi", C_NL
	db "         but failed.", C_NL
.end:
TextC_CutsceneGoenitz02:
	db .end-.start
.start:
	db "The Orochi`s power", C_NL
	db " is locked away,and", C_NL
	db " I am its keeper.", C_NL
.end:
TextC_CutsceneGoenitz03:
	db .end-.start
.start:
	db "Did Rugal", C_NL
	db "    release it?", C_NL
.end:
TextC_CutsceneGoenitz04:
	db .end-.start
.start:
	db "No,Rugal simply", C_NL
	db " stole the power", C_NL
	db " once it was", C_NL
	db "           released.", C_NL
.end:
TextC_CutsceneGoenitz05:
	db .end-.start
.start:
	db "But why did you want", C_NL
	db " to fight us?", C_NL
.end:
TextC_CutsceneGoenitz06:
	db .end-.start
.start:
	db "I organized the", C_NL
	db " tournament to see", C_NL
	db " your true powers.", C_NL
.end:
TextC_CutsceneGoenitz07:
	db .end-.start
.start:
	db "What for?", C_NL
.end:
TextC_CutsceneGoenitz08:
	db .end-.start
.start:
	db "I want you to use", C_NL
	db " your power to", C_NL
	db " contain the Orochi", C_NL
	db " power once more.", C_NL
.end:
TextC_CutsceneGoenitz09:
	db .end-.start
.start:
	db "There is no time", C_NL
	db "            to lose.", C_NL
	db "I can see by signs.", C_NL
	db C_NL
	db "He is already come..", C_NL
.end:
TextC_CutsceneGoenitz0A:
	db .end-.start
.start:
	db "He...?", C_NL
.end:
TextC_CutsceneGoenitz0B:
	db .end-.start
.start:
	db "Yes... The man who", C_NL
	db " released", C_NL
	db " the Orochi power!", C_NL
.end:
TextC_CutsceneGoenitz0C:
	db .end-.start
.start:
	db "Hey!!", C_NL
	db "What`s that wind!?", C_NL
.end:
TextC_CutsceneGoenitz0D:
	db .end-.start
.start:
	db "Aaahh-!!", C_NL
.end:
TextC_Ending_Generic0:
	db .end-.start
.start:
	db "You surprise me.", C_NL
	db "I underestimated", C_NL
	db "    your strength...", C_NL
.end:
TextC_Ending_Generic1:
	db .end-.start
.start:
	db "But there is no way", C_NL
	db " you can contain", C_NL
	db "   the Orochi power.", C_NL
	db "Your powers are not", C_NL
	db "     great enough...", C_NL
.end:
TextC_Ending_Generic2:
	db .end-.start
.start:
	db "Take my advice -", C_NL
	db " withdraw now while", C_NL
	db " you`re still alive.", C_NL
.end:
TextC_Ending_Generic3:
	db .end-.start
.start:
	db "We`ll defeat", C_NL
	db "   the Orochi power.", C_NL
.end:
TextC_Ending_Generic4:
	db .end-.start
.start:
	db "Determined to win,", C_NL
	db "              I see.", C_NL
.end:
TextC_Ending_Generic5:
	db .end-.start
.start:
	db "Now.. the wind is", C_NL
	db "          blowing...", C_NL
	db " the time has come", C_NL
	db "    for me to leave.", C_NL
.end:
TextC_Ending_Generic6:
	db .end-.start
.start:
	db "Running away,", C_NL
	db "    are you,Goenitz?", C_NL
.end:
TextC_Ending_GoenitzLeave0:
	db .end-.start
.start:
	db "No.", C_NL
	db "I am being called...", C_NL
.end:
TextC_Ending_GoenitzLeave2:
	db .end-.start
.start:
	db "To the heavens!", C_NL
.end:
TextC_CutsceneGoenitz0C_Easy:
	db .end-.start
.start:
	db "When opponents are", C_NL
	db " this weak,there`s", C_NL
	db " no need for me to", C_NL
	db " waste my time with", C_NL
	db " them.", C_NL
.end:
TextC_CutsceneGoenitz0D_Easy:
	db .end-.start
.start:
	db "Let`s meet again at", C_NL
	db " a level above", C_NL
	db "             NORMAL.", C_NL
.end:
TextC_Ending_GoenitzLeave1:
	db .end-.start
.start:
	db "                    ", C_NL
.end:

ENDC
	
IF REV_LANG_EN == 1

; Got moved from above in the English version for whatever reason.

; =============== Title_LoadVRAM ===============
; Loads tilemaps and GFX for the title screen.
; The menus load the 1bpp text over this, and reuse the cursor already loaded here.
Title_LoadVRAM:
	; Title screen & menu sprites
	ld   hl, GFXDef_TitleOBJ 
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
	
IF REV_LOGO_EN == 0
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

GFXDef_TitleOBJ: mGfxDef "data/gfx/title_obj.bin"

ENDC

IF REV_LANG_EN == 0
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
	
IF REV_VER_2 == 0
; =============== END OF BANK ===============
; Junk area below.
; [TCRF] Contains win screen text from the English version of KOF95.
	mIncJunk "L1C7F4D"
ELSE
	mIncJunk "L1C7DCA"
ENDC