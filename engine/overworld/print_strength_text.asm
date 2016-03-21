PrintStrengthTxt: ; cd99 (3:4d99)
	ld hl, wd728
	set 0, [hl]
	ld hl, UsedStrengthText
	call PrintText
	ld hl, CanMoveBouldersText
	jp PrintText

UsedStrengthText: ; cdaa (3:4daa)
	TX_FAR _UsedStrengthText
	TX_ASM
	ld a, [wcf91]
	call PlayCry
	call Delay3
	jp TextScriptEnd

CanMoveBouldersText: ; cdbb (3:4dbb)
	TX_FAR _CanMoveBouldersText
	db "@"