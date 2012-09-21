Sleep:
    ld a, i
    push af
    ld a, 2
    out (10h), a ; Disable LCD
    di ; And interrupts, for now
    im 1 ; interrupt mode 1, for cleanliness
    ei ; Enable interrupting when ON is pressed
    ld a, 1h
    out (03h), a ; ON
    halt ; and halt
    di
    ld a, 0Bh ; Reset the interrupts
    out (03h), a
    ld a, 3
    out (10h), a ; Enable the screen
    pop af
    ret po
    ei
    ret
    
unlockFlash:
    push af
    push bc
    in a, (6)
    push af
    ld a, privledgedPage
    out (6), a
    ld b, $01
    ld c, $14
    call $4001
    pop af
    out (6), a
    pop bc
    pop af
    ret

lockFlash:
    push af
    push bc
    in a, (6)
    push af
    ld a, privledgedPage
    out (6), a
    ld b, $00
    ld c, $14
    call $4017
    pop af
    out (6), a
    pop bc
    pop af
    ret
    
lcdDelay:
    push af
_:    in a,($10)
    rla
    jr c,-_
    pop af
    ret

; 16-bit Compare routines
cpHLDE:
    push hl
    or a
    sbc hl,de
    pop hl
    ret
cpHLBC:
    push hl
    or a
    sbc hl,bc
    pop hl
    ret
cpBCDE:
    push hl
    ld h,b
    ld l,c 
    or a
    sbc hl,de
    pop hl
    ret
cpDEBC:
    push hl
    ld h,d
    ld l,e 
    or a
    sbc hl,bc
    pop hl
    ret

; Inputs:	HL: String
; Outputs:	BC: String length
StringLength:
	push af
	push hl
	ld bc, 0
_:		ld a, (hl)
		or a
		jr z, _
		inc bc
		inc hl
		jr -_
_:	pop hl
	pop af
	ret