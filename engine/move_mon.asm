_MoveMon: ; f51e (3:751e)
	ld a, [wMoveMonType]
	and a
	jr z, .checkPartyMonSlots
	cp DAYCARE_TO_PARTY
	jr z, .checkPartyMonSlots
	cp PARTY_TO_DAYCARE
	ld hl, wDayCareMon
	jr z, .asm_f575
	ld hl, wNumInBox
	ld a, [hl]
	cp MONS_PER_BOX
	jr nz, .partyOrBoxNotFull
	jr .boxFull
.checkPartyMonSlots
	ld hl, wPartyCount
	ld a, [hl]
	cp PARTY_LENGTH
	jr nz, .partyOrBoxNotFull
.boxFull
	scf
	ret
.partyOrBoxNotFull
	inc a
	ld [hl], a           ; increment number of mons in party/box
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [wMoveMonType]
	cp DAYCARE_TO_PARTY
	ld a, [wDayCareMon]
	jr z, .asm_f556
	ld a, [wcf91]
.asm_f556
	ld [hli], a          ; write new mon ID
	ld [hl], $ff         ; write new sentinel
	ld a, [wMoveMonType]
	dec a
	ld hl, wPartyMons
	ld bc, wPartyMon2 - wPartyMon1 ; $2c
	ld a, [wPartyCount]
	jr nz, .skipToNewMonEntry
	ld hl, wBoxMons
	ld bc, wBoxMon2 - wBoxMon1 ; $21
	ld a, [wNumInBox]
.skipToNewMonEntry
	dec a
	call AddNTimes
.asm_f575
	push hl
	ld e, l
	ld d, h
	ld a, [wMoveMonType]
	and a
	ld hl, wBoxMons
	ld bc, wBoxMon2 - wBoxMon1 ; $21
	jr z, .asm_f591
	cp DAYCARE_TO_PARTY
	ld hl, wDayCareMon
	jr z, .asm_f597
	ld hl, wPartyMons
	ld bc, wPartyMon2 - wPartyMon1 ; $2c
.asm_f591
	ld a, [wWhichPokemon]
	call AddNTimes
.asm_f597
	push hl
	push de
	ld bc, wBoxMon2 - wBoxMon1
	call CopyData
	pop de
	pop hl
	ld a, [wMoveMonType]
	and a
	jr z, .asm_f5b4
	cp DAYCARE_TO_PARTY
	jr z, .asm_f5b4
	ld bc, wBoxMon2 - wBoxMon1
	add hl, bc
	ld a, [hl]
	inc de
	inc de
	inc de
	ld [de], a
.asm_f5b4
	ld a, [wMoveMonType]
	cp PARTY_TO_DAYCARE
	ld de, wDayCareMonOT
	jr z, .asm_f5d3
	dec a
	ld hl, wPartyMonOT
	ld a, [wPartyCount]
	jr nz, .asm_f5cd
	ld hl, wBoxMonOT
	ld a, [wNumInBox]
.asm_f5cd
	dec a
	call SkipFixedLengthTextEntries
	ld d, h
	ld e, l
.asm_f5d3
	ld hl, wBoxMonOT
	ld a, [wMoveMonType]
	and a
	jr z, .asm_f5e6
	ld hl, wDayCareMonOT
	cp DAYCARE_TO_PARTY
	jr z, .asm_f5ec
	ld hl, wPartyMonOT
.asm_f5e6
	ld a, [wWhichPokemon]
	call SkipFixedLengthTextEntries
.asm_f5ec
	ld bc, NAME_LENGTH
	call CopyData
	ld a, [wMoveMonType]
	cp PARTY_TO_DAYCARE
	ld de, wDayCareMonName
	jr z, .asm_f611
	dec a
	ld hl, wPartyMonNicks
	ld a, [wPartyCount]
	jr nz, .asm_f60b
	ld hl, wBoxMonNicks
	ld a, [wNumInBox]
.asm_f60b
	dec a
	call SkipFixedLengthTextEntries
	ld d, h
	ld e, l
.asm_f611
	ld hl, wBoxMonNicks
	ld a, [wMoveMonType]
	and a
	jr z, .asm_f624
	ld hl, wDayCareMonName
	cp DAYCARE_TO_PARTY
	jr z, .asm_f62a
	ld hl, wPartyMonNicks
.asm_f624
	ld a, [wWhichPokemon]
	call SkipFixedLengthTextEntries
.asm_f62a
	ld bc, NAME_LENGTH
	call CopyData
	pop hl
	ld a, [wMoveMonType]
	cp PARTY_TO_BOX
	jr z, .asm_f664
	cp PARTY_TO_DAYCARE
	jr z, .asm_f664
	push hl
	srl a
	add $2
	ld [wMonDataLocation], a
	call LoadMonData
	callba CalcLevelFromExperience
	ld a, d
	ld [wCurEnemyLVL], a
	pop hl
	ld bc, wBoxMon2 - wBoxMon1
	add hl, bc
	ld [hli], a
	ld d, h
	ld e, l
	ld bc, -18
	add hl, bc
	ld b, $1
	call CalcStats
.asm_f664
	and a
	ret