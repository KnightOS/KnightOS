.nolist
#include "kernel.inc"
#include "defines.inc"
#include "macros.inc"
#include "libtext.inc"
#include "keys.inc"
.list

; Header
.db 0
.db 20
.org 0

start:
    call getLcdLock
    call getKeypadLock
    
    kld de, libTextPath
    call loadLibrary
    
    call allocScreenBuffer
    kcall drawInterface
    
    ld a, (activeThreads) \ dec a
    kjp z, noThreads
    
    kcall drawThreads
    call fastCopy
    
    call flushKeys
    call waitKey
    ret
    
noThreads:
    ld de, 1 << 8 + 12
    kld hl, noProgramsStr
	;libtext(DrawStr)
	rst $10
	.db libtextID
	call drawStr
	
	call fastCopy
	
_:	call flushKeys
	call waitKey
	
	cp kClear
	jr z, _
	cp kYEqu
	jr nz, -_
	
_:	call flushKeys
    ret
    
drawThreads:
    ld de, 5 << 8 + 12
    ld hl, threadTable
    ld a, (activeThreads) \ dec a \ ld b, a
_:  push hl \ push de
        inc hl
        push de
            ld e, (hl) \ inc hl \ ld d, (hl)
            ld a, 3 \ add a, e \ ld e, a
            ex de, hl
        pop de
        ;libtext(drawStr)
        rst $10 \ .db libTextId
        call drawStr
    pop de \ pop hl
    ld a, 6 \ add a, e \ ld e, a
    ld a, 8 \ add a, l \ ld l, a
    djnz -_
    ret
    
drawInterface:
    call clearBuffer
    ; Castle top
	xor a
	ld l, 2
	call setPixel
	kld hl, castleTopSprite
	ld b, 12
	ld de, $0100
_:	ld a, 8
	push bc
		ld b, 3
		call putSpriteOR
	pop bc
	add a, d
	ld d, a
	djnz -_
    
    kld hl, hotkeyLeftSprite
	ld b, 8
	ld de, $0038
	call putSpriteOR
	
	kld hl, hotkeyRightSprite
	ld de, $5838
	call putSpriteOR
	
	kld hl, hotkeyArrowLeftSprite
	ld b, 5
	ld de, $003A
	call putSpriteOR
	
	kld hl, hotkeyPlusSprite
	ld b, 5
	ld de, $5A3A
	call putSpriteOR
	
	kld hl, backStr
	ld de, 9 * 256 + 58
	;libtext(DrawStr)
	rst $10
	.db libtextID
	call DrawStr
	
	kld hl, optionsStr
	ld de, 64 * 256 + 58
	;libtext(DrawStr)
	rst $10
	.db libtextID
	call drawStr
    
    kld hl, runningProgramsStr
	ld de, 1 * 256 + 4
	;libtext(DrawStr)
	rst $10
	.db libtextID
	call drawStr
	
	ld hl, $000A
	ld de, $5F0A
	call drawLine
    
    ret
    
castleTopSprite: ; 8x3
	.db %11110000
	.db %10010000
	.db %10011111
    
hotkeyLeftSprite: ; 8x8
	.db %01111100
	.db %10000010
	.db %00000001
	.db %00000001
	.db %00000001
	.db %00000001
	.db %00000001
	.db %10000010
	
hotkeyRightSprite: ; 8x8
	.db %00111110
	.db %01000001
	.db %10000000
	.db %10000000
	.db %10000000
	.db %10000000
	.db %10000000
	.db %01000001
	
hotkeyPlusSprite: ; 8x5
	.db %00100000
	.db %00100000
	.db %11111000
	.db %00100000
	.db %00100000
	
hotkeyArrowLeftSprite: ; 8x5
	.db %0010000
	.db %0100000
	.db %1111100
	.db %0100000
	.db %0010000
    
backStr:
    .db "Back", 0
optionsStr:
    .db "Options", 0
runningProgramsStr:
    .db "Running Programs", 0
noProgramsStr:
    .db "No programs running!", 0
    
libTextPath:
    .db "/lib/libtext", 0