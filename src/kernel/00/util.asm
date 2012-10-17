suspendDevice:
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
    
    jp 0 ; Safety
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
stringLength:
	push af
	push hl
        ld bc, 0
        xor a
        cpir
        ; bc = -bc
        ld a, b \ xor $FF \ ld b, a \ ld a, c \ xor $FF \ add a, 1 \ jr nc, $+3 \ inc b \ ld c, a
    pop hl
	pop af
	ret
    
; Outputs:	B: Value from 0-4 indicating battery level (0 is critical)
getBatteryLevel:
	push af
#ifdef TI83p
	in a, (2)
	and 1
	ld b, a
	pop af
	ret
#else
	ld b, 0
	ld a, %00000110
	out (6), a
	in a, (2)
	bit 0, a
	jr z, GetBatteryLevel_Done
	
	ld b, 1
	ld a, %01000110
	out (6), a
	in a, (2)
	bit 0, a
	jr z, GetBatteryLevel_Done
	
	ld b, 2
	ld a, %10000110
	out (6), a
	in a, (2)
	bit 0, a
	jr z, GetBatteryLevel_Done
	
	ld b, 3
	ld a, %11000110
	out (6), a
	in a, (2)
	bit 0, a
	jr z, GetBatteryLevel_Done
	
	ld b, 4
GetBatteryLevel_Done:
	ld a, %110
	out (6), a
	pop af
	ret
#endif

DEMulA:          ; HL = DE × A
    LD     HL, 0      ; Use HL to store the product
    LD     B, 8       ; Eight bits to check
_loop:
    RRCA             ; Check least-significant bit of accumulator
    JR     NC, _skip  ; If zero, skip addition
    ADD    HL, DE
_skip:
    SLA    E         ; Shift DE one bit left
    RL     D
    DJNZ   _loop
    RET

; Compare Strings
; Z for equal, NZ for not equal
; Inputs: HL and DE are strings to compare
compareStrings:
	ld a, (de)
	or a
	jr z, CompareStringsEoS
	cp (hl)
	ret nz
	inc hl
	inc de
	jr CompareStrings
CompareStringsEoS:
	ld a, (hl)
	or a
	ret
    
; >>> Quicksort routine v1.1 <<<
; by Frank Yaul 7/14/04
;
; Usage: bc->first, de->last,
;        call qsort
quicksort:
		push hl
		push de
		push bc
		push af
		ld      hl,0
        push    hl
qsloop: ld      h,b
        ld      l,c
        or      a
        sbc     hl,de
        jp      c,next1 ;loop until lo<hi
        pop     bc
        ld      a,b
        or      c
        jr z, endqsort
        pop     de
        jp      qsloop
next1:  push    de      ;save hi,lo
        push    bc
        ld      a,(bc)  ;pivot
        ld      h,a
        dec     bc
        inc     de
fleft:  inc     bc      ;do i++ while cur<piv
        ld      a,(bc)
        cp      h
        jp      c,fleft
fright: dec     de      ;do i-- while cur>piv
        ld      a,(de)
        ld      l,a
        ld      a,h
        cp      l
        jp      c,fright
        push    hl      ;save pivot
        ld      h,d     ;exit if lo>hi
        ld      l,e
        or      a
        sbc     hl,bc
        jp      c,next2
        ld      a,(bc)  ;swap (bc),(de)
        ld      h,a
        ld      a,(de)
        ld      (bc),a
        ld      a,h
        ld      (de),a
        pop     hl      ;restore pivot
        jp      fleft
next2:  pop     hl      ;restore pivot
        pop     hl      ;pop lo
        push    bc      ;stack=left-hi
        ld      b,h
        ld      c,l     ;bc=lo,de=right
        jp      qsloop
endqsort:
		pop af
		pop bc
		pop de
		pop hl
		ret
        
Div32By16:
; IN:	ACIX=dividend, DE=divisor
; OUT:	ACIX=quotient, DE=divisor, HL=remainder, B=0
	ld	hl,0
	ld	b,32
Div32By16_Loop:
	add	ix,ix
	rl	c
	rla
	adc	hl,hl
	jr	c,Div32By16_Overflow
	sbc	hl,de
	jr	nc,Div32By16_SetBit
	add	hl,de
	djnz	Div32By16_Loop
	ret
Div32By16_Overflow:
	or	a
	sbc	hl,de
Div32By16_SetBit:
	.db	$DD,$2C		; inc ixl, change to inc ix to avoid undocumented
	djnz	Div32By16_Loop
	ret
    
; Subtracts DE from ACIX
sub16from32:
    push hl
    push de
    push bc
        push ix \ pop hl
        push de
            ld d, a
            ld e, c
        pop bc
        
        or a
        sbc hl, bc
        jr nc, _
        dec de
_:  push hl \ pop ix
    ld a, d \ ld c, e
    pop bc
    pop de
    pop hl
    ret
    
; Adds DE to ACIX
add16to32:
    push hl
    push de
    push bc
    pop bc
        push ix \ pop hl
        push de
            ld d, a
            ld e, c
        pop bc
        add hl, bc
        jr nc, _
        inc de
_:  push hl \ pop ix
    ld a, d \ ld c, e
    pop de
    pop bc
    ret
    
; remainder in a
divHLbyC:
   xor	a
   ld	b, 16
_: add	hl, hl
   rla
   cp	c
   jr	c, $+4
   sub	c
   inc	l
   djnz	-_
   ret
 
; remainder in HL
divACbyDE:
   ld	hl, 0
   ld	b, 16
_: sll	c
   rla
   adc	hl, hl
   sbc	hl, de
   jr	nc, $+4
   add	hl, de
   dec	c
   djnz	-_
   ret
   
; Returns HL as pointer to allocated memory containing version
; string. Free this memory when you're done with it.
getBootCodeVersionString:
    ld a, i
    push af
    di
        push af
        push bc
        push ix
        push de
            ld a, bootPage
            out (6), a
            ld hl, $400F ; Location of boot code version string
            call stringLength
            inc bc
            call allocMem
            push ix \ pop de
            ldir
            push ix \ pop hl
        pop de
        pop ix
        pop bc
        pop af
    pop af
    ret po
    ei
    ret
    