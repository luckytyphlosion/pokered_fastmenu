CalcChecksum:
	ld hl, $0
	ld bc, $14e
	ld d, h
	ld e, l
	call CalcChecksumRange
	inc hl
	inc hl
	ld bc, $4000 - $150
	call CalcChecksumRange
	ld a, $3f
.bankLoop
	ld [H_LOADEDROMBANK], a
	ld [MBC1RomBank], a
	ld hl, $4000
	ld b, h
	ld c, l
	call CalcChecksumRange
	ld a, [H_LOADEDROMBANK]
	dec a
	jr nz, .bankLoop
	ld a, [$14e]
	cp d
	jr nz, .failure
	ld a, [$14f]
	cp e
	jr nz, .failure
	ld a, $1
	ld [hChecksumMatches], a
	ret
.failure
	xor a
	ld [hChecksumMatches], a
	ret
	
CalcChecksumRange:
	inc b
	inc c
	jr .noCarry
.loop
	ld a, [hli]
	add e
	ld e, a
	jr nc, .noCarry
	inc d
.noCarry
	dec c
	jr nz, .loop
	dec b
	jr nz, .loop
	ret