suspendDevice:
    ld a, i
    push af
    ld a, 2
    out (0x10), a ; Disable LCD
    di ; And interrupts, for now
    im 1 ; interrupt mode 1, for cleanliness
    ei ; Enable interrupting when ON is pressed
    ld a, 1
    out (3), a ; ON
    halt ; and halt
    di
    ld a, 0xB ; Reset the interrupts
    out (3), a
    ld a, 3
    out (0x10), a ; Enable the screen
    pop af
    ret po
    ei
    ret
    
; Converts ASCII hex string at (hl) to HL
; TODO: This could use some improvement
hexToHL:
    push de
    push af
        ; D
        ld a, (hl)
        or a
        jr z, .done
        call hexToA_doConvert
        rla \ rla \ rla \ rla
        ld d, a \ inc hl
        ld a, (hl)
        or a
        jr z, .done
        call hexToA_doConvert
        or d \ ld d, a \ inc hl
        ; E
        ld a, (hl)
        or a
        jr z, .done
        call hexToA_doConvert
        rla \ rla \ rla \ rla
        ld e, a \ inc hl
        ld a, (hl)
        or a
        jr z, .done
        call hexToA_doConvert
        or e
        ld e, a
        ex de, hl
.done:
    pop af
    pop de
    ret
    
; Converts ASCII hex string at (hl) to A
hexToA:
    push bc
    push hl
        ld b, 0
_:      ld a, (hl)
        or a
        jr z, hexToA_ret
        
        rl b \ rl b \ rl b \ rl b
        call hexToA_doConvert
        or b
        ld b, a
        inc hl
        jr -_
        
hexToA_ret:
        ld a, b
    pop hl
    pop bc
    ret
        
hexToA_doConvert:
    cp 'a' ; Convert to lowercase
    jr c, _
        sub 'a' - 'A'
_:  cp 'A' ; Close gap between numbers and letter
    jr c, _
        sub 'A'-('9'+1)
_:  sub '0' ; To number
    ret
    
lcdDelay:
    push af
_:    in a,(0x10)
    rla
    jr c,-_
    pop af
    ret

; 16-bit Compare routines
cpHLDE:
cpDEHL:
    push hl
    or a
    sbc hl,de
    pop hl
    ret
cpHLBC:
cpBCHL:
    push hl
    or a
    sbc hl,bc
    pop hl
    ret
cpBCDE:
cpDEBC:
    push hl
    ld h,b
    ld l,c 
    or a
    sbc hl,de
    pop hl
    ret

; Inputs:    HL: String
; Outputs:    BC: String length
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
    
; Outputs:    B: Value from 0-4 indicating battery level (0 is critical)
getBatteryLevel:
#ifdef CPU15
    push af
        ld bc, 0x0403
        ; Reset battery threshold
        in a, (4)
        or 0b11000000
        out (4), a
_:      push bc
            rrc c \ rrc c
            in a, (4)
            and 0b11000000
            or c
            out (4), a
            in a, (2)
            bit 0, a
            jr z, _
        pop bc
        dec c
        djnz _
_:  pop af
    ret
#else
    push af
        in a, (2)
        and 0b11111110
        ld b, a
    pop af
    ret
#endif
    
DEMulA: ; HL = DE � A
    push bc
    ld hl, 0 ; Use HL to store the product
    ld b, 8 ; Eight bits to check
.loop:
    rrca ; Check least-significant bit of accumulator
    jr nc, .skip ; If zero, skip addition
    add hl, de
.skip:
    sla e ; Shift DE one bit left
    rl D
    djnz .loop
    pop bc
    ret

; Compare Strings
; Z for equal, NZ for not equal
; Inputs: HL and DE are strings to compare
compareStrings:
    ld a, (de)
    or a
    jr z, .end
    cp (hl)
    ret nz
    inc hl
    inc de
    jr compareStrings
.end:
    ld a, (hl)
    or a
    ret

; String copy
; Copies string at (hl) to (de)
stringCopy:
    push de
    push hl
    ex de, hl
_:  ld a, (de)
    ld (hl), a
    or a
    jr z, _
    inc hl \ inc de
    jr -_
_:  pop de
    pop hl
    ret

;; radixSort [Utils]
;;  Sorts a specified array of numbers.
;; Inputs:
;;  HL: first element in array
;;  DE: Last element in array
;; Outputs:
;;  (Array is sorted)
;;  HL, DE, and BC preserved
;; Notes:
;;  This routine is an in-place version of a radix sort, which has an O(k*n)
;;  runtime for k-bit numbers.  It also requires a smaller, fixed amount of
;;  stack space.
radixSort:
    ld b, 0b10000000
radixSortRecurse:
    push bc
        push de
            push hl
                or a                    ; We must initially clear CA bit, later it's never modified.
.nextbyte:
                sbc hl,de \ add hl,de   ; Check if our bins have met up
                jr c, _
                jr nz, .nextbit         ; If they have, restart with next bit

_:              ld a, (hl)              ; Perform our bit test
                and b
                jr nz, _
                inc hl                  ; It's already in the 0s bin.  0s bin gets larger.
                jr .nextbyte
_:              ld a, (hl)              ; Switch number at top of 1s bin with this one
                ex de, hl
                ld c, (hl)
                ld (hl), a
                ex de, hl
                ld (hl), c
                dec de                  ; 1s bin gets larger.
                jr .nextbyte

.nextbit:
                srl b                   ; Next bit please
                jr c, .done             ; If our carry is 1, we've been through all 8 bits (base case).
            pop hl
            call radixSortRecurse       ; Sort the 0s bin
            push de \ pop hl
            inc hl
        pop de
        call radixSortRecurse           ; Sort the 1s bin
    pop bc
    ret
.done:
            pop hl
        pop de
    pop bc
    ret

; >>> Quicksort routine v1.1 <<<
; by Frank Yaul 7/14/04
; Usage: bc->first, de->last,
;        call qsort
quicksort:
    push hl
    push de
    push bc
    push af
    ld hl, 0
    push hl
qsloop:
    ld h, b
    ld l, c
    or a
    sbc hl, de
    jp c, next1 ; loop until lo<hi
    pop bc
    ld a,b
    or c
    jr z, endqsort
    pop de
    jp qsloop
next1:
    push de ; save hi,lo
    push bc
    ld a, (bc) ; pivot
    ld h, a
    dec bc
    inc de
fleft:
    inc bc ; do i++ while cur<piv
    ld a, (bc)
    cp h
    jp c, fleft
fright:
    dec de ; do i-- while cur>piv
    ld a, (de)
    ld l, a
    ld a, h
    cp l
    jp c, fright
    push hl ; save pivot
    ld h, d ; exit if lo>hi
    ld l, e
    or a
    sbc hl, bc
    jp c, next2
    ld a, (bc) ; swap (bc),(de)
    ld h, a
    ld a, (de)
    ld (bc), a
    ld a, h
    ld (de), a
    pop hl ; restore pivot
    jp fleft
next2:
    pop hl ; restore pivot
    pop hl ; pop lo
    push bc ; stack=left-hi
    ld b, h
    ld c, l ; bc=lo,de=right
    jp qsloop
endqsort:
    pop af
    pop bc
    pop de
    pop hl
    ret
        
div32By16:
; IN:    ACIX=dividend, DE=divisor
; OUT:    ACIX=quotient, DE=divisor, HL=remainder, B=0
    ld hl, 0
    ld b, 32
.loop:
    add ix, ix
    rl c
    rla
    adc hl,hl
    jr  c, .overflow
    sbc hl,de
    jr  nc, .setBit
    add hl,de
    djnz .loop
    ret
.overflow:
    or a
    sbc hl,de
.setBit:
    inc ixl
    djnz .loop
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
   xor a
   ld b, 16
_: add hl, hl
   rla
   cp c
   jr c, $+4
   sub c
   inc l
   djnz -_
   ret
 
; remainder in HL
divACbyDE:
   ld hl, 0
   ld b, 16
_: srl c
   rla
   adc hl, hl
   sbc hl, de
   jr nc, $+4
   add hl, de
   dec c
   djnz -_
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
            ld hl, 0x400F ; Location of boot code version string
            call stringLength
            inc bc
            call malloc
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
    