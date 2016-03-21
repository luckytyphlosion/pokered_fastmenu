PrintSafariZoneSteps: ; c52f (3:452f)
	ld a, [wCurMap]
	cp SAFARI_ZONE_EAST
	ret c
	cp UNKNOWN_DUNGEON_2
	ret nc
	coord hl, 0, 0
	ld b, 3
	ld c, 7
	call TextBoxBorder
	coord hl, 1, 1
	ld de, wSafariSteps
	lb bc, 2, 3
	call PrintNumber
	coord hl, 4, 1
	ld de, SafariSteps
	call PlaceString
	coord hl, 1, 3
	ld de, SafariBallText
	call PlaceString
	ld a, [wNumSafariBalls]
	cp 10
	jr nc, .asm_c56d
	coord hl, 5, 3
	ld a, " "
	ld [hl], a
.asm_c56d
	coord hl, 6, 3
	ld de, wNumSafariBalls
	lb bc, 1, 2
	jp PrintNumber

SafariSteps: ; c579 (3:4579)
	db "/500@"

SafariBallText: ; c57e (3:457e)
	db "BALL×× @"