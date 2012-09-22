
drawCastleChrome:
    call clearBuffer
    ; Castle top
	xor a
	ld l, 2
	call setPixel
	kld hl, CastleTopSprite
	ld b, 12
	ld de, $0100
_:	ld a, 8
	push bc
		ld b, 3
		call PutSpriteOR
	pop bc
	add a, d
	ld d, a
	djnz -_
    
	kld hl, HotkeyLeftSprite
	ld b, 8
	ld de, $0038
	call PutSpriteOR
	
	kld hl, HotkeyRightSprite
	ld de, $5838
	call PutSpriteOR
	
	ld hl, $000A
	ld de, $5F0A
	call DrawLine
	
	kld hl, BatteryIndicatorSprite
	ld b, 4
	ld de, $193B
	call PutSpriteOR
	
	call GetBatteryLevel
	xor a
	cp b
	jr z, ++_
	ld a, 26
_:	ld l, 60
	call setPixel
	inc l
	call setPixel
	inc a
	djnz -_
_:	
    ; Get time
    push ix
    
    pop ix

    ret
    
    
CastleTopSprite: ; 8x3
	.db %11110000
	.db %10010000
	.db %10011111
	
HotkeyLeftSprite: ; 8x8
	.db %01111100
	.db %10000010
	.db %00000001
	.db %00000001
	.db %00000001
	.db %00000001
	.db %00000001
	.db %10000010
	
HotkeyRightSprite: ; 8x8
	.db %00111110
	.db %01000001
	.db %10000000
	.db %10000000
	.db %10000000
	.db %10000000
	.db %10000000
	.db %01000001
	
HotkeyPlusSprite: ; 8x5
	.db %00100000
	.db %00100000
	.db %11111000
	.db %00100000
	.db %00100000
	
HotkeyArrowLeftSprite: ; 8x5
	.db %0010000
	.db %0100000
	.db %1111100
	.db %0100000
	.db %0010000
	
HotkeyArrowRightSprite: ; 8x5
	.db %0010000
	.db %0001000
	.db %1111100
	.db %0001000
	.db %0010000
	
HotkeyArrowUpSprite: ; 8x5
	.db %0010000
	.db %0111000
	.db %1010100
	.db %0010000
	.db %0010000
	
MenuArrowSprite: ; 8x3
	.db %00100000
	.db %01110000
	.db %11111000
	
MenuArrowSpriteFlip: ; 8x3
	.db %11111000
	.db %01110000
	.db %00100000
	
BatteryIndicatorSprite: ; 8x4
	.db %11111100
	.db %10000110
	.db %10000110
	.db %11111100

SelectionIndicatorSprite: ; 8x5
	.db %10000000
	.db %11000000
	.db %11100000
	.db %11000000
	.db %10000000
	
ExclamationSprite1: ; 8x8
	.db %01110000
	.db %10001000
	.db %10001000
	.db %10001000
	.db %10001000
	.db %10001000
	.db %10001000
	.db %10001000

ExclamationSprite2: ; 8x8
	.db %10001000
	.db %01110000
	.db %00000000
	.db %01110000
	.db %10001000
	.db %10001000
	.db %10001000
	.db %01110000
	
DefaultIconSprite: ; 16x16
	.db %01111111, %11111110
	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %10000000, %00000001
	.db %10111111, %10111101
	.db %10100000, %10111101
	.db %10100000, %10111101
	.db %10111111, %10111101
	.db %10000000, %00111101
	.db %10111100, %00111101
	.db %10000000, %00111101
	.db %10111111, %00111101
	.db %10000000, %00111101
	.db %10111110, %00111101
	.db %10000000, %00000001
	.db %11111111, %11111111