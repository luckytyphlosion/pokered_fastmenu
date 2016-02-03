AnimateHallOfFame: ; 701a0 (1c:41a0)
	call HoFFadeOutScreenAndMusic
	call ClearScreen
	ld c, 100
	call DelayFrames
	call LoadFontTilePatterns
	call LoadTextBoxTilePatterns
	call DisableLCD
	ld hl,vBGMap0
	ld bc, $800
	ld a, " "
	call FillMemory
	call EnableLCD
	ld hl, rLCDC
	set 3, [hl]
	xor a
	ld hl, wHallOfFame
	ld bc, HOF_TEAM
	call FillMemory
	xor a
	ld [wUpdateSpritesEnabled], a
	ld [hTilesetType], a
	ld [wSpriteFlipped], a
	ld [wLetterPrintingDelayFlags], a ; no delay
	ld [wHoFMonOrPlayer], a ; mon
	inc a
	ld [H_AUTOBGTRANSFERENABLED], a
	ld hl, wNumHoFTeams
	ld a, [hl]
	inc a
	jr z, .skipInc ; don't wrap around to 0
	inc [hl]
.skipInc
	ld a, $90
	ld [hWY], a
	ld c, BANK(Music_HallOfFame)
	ld a, MUSIC_HALL_OF_FAME
	call PlayMusic
	ld hl, wPartySpecies
	ld c, $ff
.partyMonLoop
	ld a, [hli]
	cp $ff
	jr z, .doneShowingParty
	inc c
	push hl
	push bc
	ld [wHoFMonSpecies], a
	ld a, c
	ld [wHoFPartyMonIndex], a
	ld hl, wPartyMon1;ANM-I'm removing "Level" from this and will add this later. I want to store the value so I can use it later
	ld bc, wPartyMon2 - wPartyMon1
	call AddNTimes
	
	;ANM -because I changed the wPartyMon1Level to wPartyMon1,
	;I can now push the location of the current mon. 
	;But I have to add back up to get to level
	push hl
	ld bc, wPartyMon1Level - wPartyMon1
	add hl,bc
	
	ld a, [hl]
	ld [wHoFMonLevel], a
	call HoFShowMonOrPlayer
	call HoFDisplayAndRecordMonInfo
	ld c, 80
	call DelayFrames
	coord hl, 2, 13
	ld b, $3
	ld c, $e
	call TextBoxBorder

	
	;ANM-draw the DVs
	pop hl;lets get the hl that points to the current partymon
	call DrawDVs
	
	
	ld c, 180
	call DelayFrames
	call GBFadeOutToWhite
	pop bc
	pop hl
	jr .partyMonLoop
.doneShowingParty
	ld a, c
	inc a
	ld hl, wHallOfFame
	ld bc, HOF_MON
	call AddNTimes
	ld [hl], $ff
	call SaveHallOfFameTeams
	xor a
	ld [wHoFMonSpecies], a
	inc a
	ld [wHoFMonOrPlayer], a ; player
	call HoFShowMonOrPlayer
	call HoFDisplayPlayerStats
	call HoFFadeOutScreenAndMusic
	xor a
	ld [hWY], a
	ld hl, rLCDC
	res 3, [hl]
	ret

	;ANM -Draw DVs for current pokemon
DrawDVs::
	ld de, wPartyMon1DVs - wPartyMon1;loading the difference into a different reg
	add hl, de;hl pointed to the level of the current mon. now it points to the first dv
	ld a, [hl];get the first byte that contains 2 dvs
	swap a;the first dv is in the most significant 4 bits
	and $f;get rid of those pesky 4 bits
	ld [wBuffer], a;store the dv value in a buffer
	ld a, [hli];repeat but for the other dv in the first byte
	and $f;^ also go to the next DV
	ld [wBuffer+1], a
	;Repeat above but with the next byte (two DVs)
	;This would be a loop if I could get it to work without creating 20 extrea lines
	ld a, [hl]
	swap a
	and $f
	ld [wBuffer+2], a
	ld a, [hl]
	and $f
	ld [wBuffer+3], a

	ld c, 2 ;there are a maximum of 2 digits per dv
	ld b, LEFT_ALIGN | 1;sets some flags or something, copied from printLevel
	coord hl, 4, 15 ;set the x and y location in hl, this is taken from the original "Hall Of Fame" drawer
	ld de, wBuffer;//make de point to wBuffer	
	
.startDrawDVs
	push de;PrintNumber and PlaceString modify this but I need it
	call PrintNumber	
	
	;check if we've just printed the last DV
	push bc;push bc because we still need the flags
	ld bc, wBuffer + 2;load the target value to bc (i.e. if(bc == de))
	ld a, c;we can only sub 1 byte from a. c and e can only be a maximum of 4 different, we don't need to check much
	sub e
	pop bc;this should not affect the flags
	jr z, .finishDrawDVs;if we're at wBuffer+2 then we can go ahead and finish up
	
	ld de, SlashText;we didn't finish, let's load the slash sign into memory
	push bc;place string messes up our flags
	call PlaceString;place the / on screen
	pop bc;bring back our flags
	inc hl;for some reason PlaceString does not move where you're going to draw, so I had to move it one unit to the right manually
	pop de;get back the location of the last DV we drew
	inc de;move on to the next DV
	jr .startDrawDVs;start the DV drawing process again!
	
.finishDrawDVs;We're done drawing them!
	pop de;We need to fix our pushpops for other scripts to work
	ret;return to the Hall Of Fame code

SlashText:;As far as I know, this is the way you have to do it because you also need the @, but I'm not sure
	db "/@"
	;End ANM code

HoFShowMonOrPlayer: ; 70278 (1c:4278)
	call ClearScreen
	ld a, $d0
	ld [hSCY], a
	ld a, $c0
	ld [hSCX], a
	ld a, [wHoFMonSpecies]
	ld [wcf91], a
	ld [wd0b5], a
	ld [wBattleMonSpecies2], a
	ld [wWholeScreenPaletteMonSpecies], a
	ld a, [wHoFMonOrPlayer]
	and a
	jr z, .showMon
; show player
	call HoFLoadPlayerPics
	jr .next1
.showMon
	coord hl, 12, 5
	call GetMonHeader
	call LoadFrontSpriteByMonIndex
	predef LoadMonBackPic
.next1
	ld b, SET_PAL_POKEMON_WHOLE_SCREEN
	ld c, 0
	call RunPaletteCommand
	ld a, %11100100
	ld [rBGP], a
	ld c, $31 ; back pic
	call HoFLoadMonPlayerPicTileIDs
	ld d, $a0
	ld e, 4
	ld a, [wOnSGB]
	and a
	jr z, .next2
	sla e ; scroll more slowly on SGB
.next2
	call .ScrollPic ; scroll back pic left
	xor a
	ld [hSCY], a
	ld c, a ; front pic
	call HoFLoadMonPlayerPicTileIDs
	ld d, 0
	ld e, -4
; scroll front pic right

.ScrollPic
	call DelayFrame
	ld a, [hSCX]
	add e
	ld [hSCX], a
	cp d
	jr nz, .ScrollPic
	ret

HoFDisplayAndRecordMonInfo: ; 702e1 (1c:42e1)
	ld a, [wHoFPartyMonIndex]
	ld hl, wPartyMonNicks
	call GetPartyMonName
	call HoFDisplayMonInfo
	jp HoFRecordMonInfo

HoFDisplayMonInfo: ; 702f0 (1c:42f0)
	coord hl, 0, 2
	ld b, 9
	ld c, 10
	call TextBoxBorder
	coord hl, 2, 6
	ld de, HoFMonInfoText
	call PlaceString
	coord hl, 1, 4
	ld de, wcd6d
	call PlaceString
	ld a, [wHoFMonLevel]
	coord hl, 8, 7
	call PrintLevelCommon
	ld a, [wHoFMonSpecies]
	ld [wd0b5], a
	coord hl, 3, 9
	predef PrintMonType
	ld a, [wHoFMonSpecies]
	jp PlayCry

HoFMonInfoText: ; 70329 (1c:4329)
	db   "LEVEL/"
	next "TYPE1/"
	next "TYPE2/@"

HoFLoadPlayerPics: ; 7033e (1c:433e)
	ld de, RedPicFront
	ld a, BANK(RedPicFront)
	call UncompressSpriteFromDE
	ld hl, sSpriteBuffer1
	ld de, sSpriteBuffer0
	ld bc, $310
	call CopyData
	ld de, vFrontPic
	call InterlaceMergeSpriteBuffers
	ld de, RedPicBack
	ld a, BANK(RedPicBack)
	call UncompressSpriteFromDE
	predef ScaleSpriteByTwo
	ld de, vBackPic
	call InterlaceMergeSpriteBuffers
	ld c, $1

HoFLoadMonPlayerPicTileIDs: ; 7036d (1c:436d)
; c = base tile ID
	ld b, 0
	coord hl, 12, 5
	predef_jump CopyTileIDsFromList

HoFDisplayPlayerStats: ; 70377 (1c:4377)
	SetEvent EVENT_HALL_OF_FAME_DEX_RATING
	predef DisplayDexRating
	coord hl, 0, 4
	ld b, $6
	ld c, $a
	call TextBoxBorder
	coord hl, 5, 0
	ld b, $2
	ld c, $9
	call TextBoxBorder
	coord hl, 7, 2
	ld de, wPlayerName
	call PlaceString
	coord hl, 1, 6
	ld de, HoFPlayTimeText
	call PlaceString
	coord hl, 2, 7
	ld de, wPlayTimeHours + 1
	lb bc, 1, 3
	call PrintNumber
	ld [hl], $6d
	inc hl
	ld de, wPlayTimeMinutes + 1
	lb bc, LEADING_ZEROES | 1, 2
	call PrintNumber
	ld [hl], $6d
	inc hl
	ld de, wPlayTimeSeconds
	lb bc, LEADING_ZEROES | 1, 2
	call PrintNumber
	coord hl, 1, 9
	ld de, HoFMoneyText
	call PlaceString
	coord hl, 4, 10
	ld de, wPlayerMoney
	ld c, $a3
	call PrintBCDNumber
	ld hl, DexSeenOwnedText
	call HoFPrintTextAndDelay
	ld hl, DexRatingText
	call HoFPrintTextAndDelay
	ld hl, wDexRatingText

HoFPrintTextAndDelay: ; 703e2 (1c:43e2)
	call PrintText
	ld c, 120
	jp DelayFrames

HoFPlayTimeText: ; 703ea (1c:43ea)
	db "PLAY TIME@"

HoFMoneyText: ; 703f4 (1c:43f4)
	db "MONEY@"

DexSeenOwnedText: ; 703fa (1c:43fa)
	TX_FAR _DexSeenOwnedText
	db "@"

DexRatingText: ; 703ff (1c:43ff)
	TX_FAR _DexRatingText
	db "@"

HoFRecordMonInfo: ; 70404 (1c:4404)
	ld hl, wHallOfFame
	ld bc, HOF_MON
	ld a, [wHoFPartyMonIndex]
	call AddNTimes
	ld a, [wHoFMonSpecies]
	ld [hli], a
	ld a, [wHoFMonLevel]
	ld [hli], a
	ld e, l
	ld d, h
	ld hl, wcd6d
	ld bc, NAME_LENGTH
	jp CopyData

HoFFadeOutScreenAndMusic: ; 70423 (1c:4423)
	ld a, 10
	ld [wAudioFadeOutCounterReloadValue], a
	ld [wAudioFadeOutCounter], a
	ld a, $ff
	ld [wAudioFadeOutControl], a
	jp GBFadeOutToWhite
