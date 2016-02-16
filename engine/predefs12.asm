; b = new colour for BG colour 0 (usually white) for 4 frames
ChangeBGPalColor0_4Frames: ; 480eb (12:40eb)
	call GetPredefRegisters
	ld a, [rBGP]
	or b
	ld [rBGP], a
	ld c, 4
	call DelayFrames
	ld a, [rBGP]
	and %11111100
	ld [rBGP], a
	ret

PredefShakeScreenVertically: ; 480ff (12:40ff)
; Moves the window down and then back in a sequence of progressively smaller
; numbers of pixels, starting at b.
	call GetPredefRegisters
	ld a, 1
	ld [wDisableVBlankWYUpdate], a
	xor a
.loop
	ld [$ff96], a
	call ShakeScreen_MutateWY
	call ShakeScreen_MutateWY
	dec b
	ld a, b
	jr nz, .loop
	xor a
	ld [wDisableVBlankWYUpdate], a
	ret

ShakeScreen_MutateWY: ; 48119 (12:4119)
	ld a, [$ff96]
	xor b
	ld [$ff96], a
	bit 7, a
	jr z, .skipZeroing
	xor a
.skipZeroing
	ld [rWY], a
	ld c, 3
	jp DelayFrames
	
PredefShakeScreenHorizontally: ; 48125 (12:4125)
; Moves the window right and then back in a sequence of progressively smaller
; numbers of pixels, starting at b.
	call GetPredefRegisters
	xor a
.loop
	ld [$ff97], a
	call .MutateWX
	call DelayFrame
	call .MutateWX
	dec b
	ld a, b
	jr nz, .loop

; restore normal WX
	ld a, 7
	ld [rWX], a
	ret

.MutateWX ; 4813f (12:413f)
	ld a, [$ff97]
	xor b
	ld [$ff97], a
	bit 7, a
	jr z, .skipZeroing
	xor a ; zero a if it's negative
.skipZeroing
	add 7
	ld [rWX], a
	ld c, 4
	jp DelayFrames
