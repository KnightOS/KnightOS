; TODO: Add routines to erase certificate sectors (or add this to eraseFlashSector?)
    rst 0 ; Safety, prevents runaway code from unlocking flash
unlockFlash:
    push af
    push bc
    in a, (6)
    push af
    ld a, privledgedPage
    out (6), a
    ld b, 0x01
    ld c, 0x14
    call 0x4001
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
    ld b, 0x00
    ld c, 0x14
    call 0x4017
    pop af
    out (6), a
    pop bc
    pop af
    ret

; Inputs:    A: Value to write
;            HL: Address to write to
; Outputs:    None
; Comments:    Flash must be unlocked
writeFlashByte:
    push bc
    ld b, a
    push af
    ld a, i
    push af
    di
    ld a, b

    push hl
    push de
    push bc
        push hl
        push de
        push bc
            ld hl, .ram
            ld de, kernelGarbage
            ld bc, .ram_end - .ram
            ldir
        pop bc
        pop de
        pop hl
        call kernelGarbage
    pop bc
    pop de
    pop hl
    
    pop af
    jp po, _
    ei
_:    pop af
    pop bc
    ret

; Flash operations must be done from RAM
.ram:
    and (hl) ; Ensure that no bits are set
    ld b, a
        ld a, 0xAA
        ld (0x0AAA), a    ; Unlock
        ld a, 0x55
        ld (0x0555), a    ; Unlock
        ld a, 0xA0
        ld (0x0AAA), a    ; Write command
    ld (hl), b        ; Data
    
    ; Wait for chip
_:  ld a, b
    xor (hl)
    bit 7, a
    jr z, .done
    bit 5, (hl)
    jr z, -_
    ; Error, abort
.done:
    ld (hl), 0xF0
    ret
.ram_end:

; Inputs:    DE: Address to write to
;            HL: Address to read from (must be in RAM)
;            BC: Size of data to be written
; Outputs:    None
; Comments:    Flash must be unlocked
writeFlashBuffer:
    push af
    ld a, i
    push af
    di

    push hl
    push de
    push bc
        push hl
        push de
        push bc
            ld hl, .ram
            ld de, kernelGarbage
            ld bc, .ram_end - .ram
            ldir
        pop bc
        pop de
        pop hl
        call kernelGarbage
    pop bc
    pop de
    pop hl
    
    pop af
    jp po, _
    ei
_:  pop af
    ret
    
.ram:
.loop:
    ld a, 0xAA
    ld (0x0AAA), a    ; Unlock
    ld a, 0x55
    ld (0x0555), a    ; Unlock
    ld a, 0xA0
    ld (0x0AAA), a    ; Write command
    ld a, (hl)
    ld (de), a        ; Data
    
    inc de
    dec bc
    
_:  xor (hl)
    bit 7, a
    jr z, _
    bit 5, a
    jr z, -_
    ; Error, abort
    ld (hl), 0xF0
    ret
_:
    ld (hl), 0xF0
    inc hl
    ld a, b
    or a
    jr nz, .loop
    ld a, c
    or a
    jr nz, .loop
    ret
.ram_end:

eraseSwapSector:
    ld a, swapSector
    call eraseFlashSector
    ret

; Inputs:    A: Any page within the sector to be erased
; Outputs:    None
; Comments:    Flash must be unlocked
eraseFlashSector:
    push bc
    ld b, a
    push af
    ld a, i
    ld a, i
    push af
    di
    ld a, b

    push hl
    push de
    push bc
        push hl
        push de
        push bc
            ld hl, .ram
            ld de, kernelGarbage
            ld bc, .ram_end - .ram
            ldir
        pop bc
        pop de
        pop hl
        call kernelGarbage
    pop bc
    pop de
    pop hl
    
    pop af
    jp po, _
    ei
_:  pop af
    pop bc
    ret
    
.ram:
    out (6), a
    ld a, 0xAA
    ld (0x0AAA), a ; Unlock
    ld a, 0x55
    ld (0x0555), a ; Unlock
    ld a, 0x80
    ld (0x0AAA), a ; Write command
    ld a, 0xAA
    ld (0x0AAA), a ; Unlock
    ld a, 0x55
    ld (0x0555), a ; Unlock
    ld a, 0x30
    ld (0x4000), a ; Erase
    ; Wait for 0xcip
_:  ld a, (0x4000)
    bit 7, a
    ret nz
    bit 5, a
    jr z, -_
    ; Error, abort
    ld a, 0xF0
    ld (0x4000), a
    ret
.ram_end:

; Inputs:    A: Page to erase
; Erases a single flash page
eraseFlashPage:
    push af
    push bc
        push af
            call copySectorToSwap
        pop af
        push af
            call eraseFlashSector
        pop af
        
        ld c, a
        and 0b011111100
        ld b, swapSector
_:
        cp c
        jr z, _
        call copyFlashPage
_:
        inc b
        inc a
        push af
        ld a, b
        and 0b011111100
        or a
        jr z, _
        pop af
        jr --_
_:        
        pop af
    pop bc
    pop af
    ret

; Inputs:    A: Any page within the sector to be copied
; Outputs:    None
; Comments:    Flash must be unlocked
copySectorToSwap:
    push af
    call eraseSwapSector
    pop af

    push bc
    ld b, a
    push af
    ld a, i
    ld a, i
    push af
    di
    ld a, b

    and 0b011111100 ; Get the sector for the specified page
    
    push hl
    push de
        ld hl, .ram
#ifdef CPU15
        push af
            ld a, 1
            out (5), a
        
            ld de, kernelGarbage + 0x4000 ; By rearranging memory, we can make the routine perform better
            ld bc, .end - .ram
            ldir
        pop af
#else
        ld de, kernelGarbage
        ld bc, .end - .ram
        ldir
#endif
#ifdef CPU15
        ld hl, 0x4000
        add hl, sp
        ld sp, hl
        call kernelGarbage + 0x4000
        xor a
        out (5), a ; Restore correct memory mapping
        ld hl, 0
        add hl, sp
        ld bc, 0x4000
        or a
        sbc hl, bc
        ld sp, hl
#else
        call kernelGarbage
#endif
    pop de
    pop hl
    
    pop af
    jp po, _
    ei
_:  pop af
    pop bc
    ret
    
#ifdef CPU15
.ram:
    out (7), a
    ld a, swapSector
    out (6), a
    
.preLoop:    
    ld hl, 0x8000
    ld de, 0x4000
    ld bc, 0x4000
.loop:
    ld a, 0xAA
    ld (0x0AAA), a    ; Unlock
    ld a, 0x55
    ld (0x0555), a    ; Unlock
    ld a, 0xA0
    ld (0x0AAA), a    ; Write command
    ld a, (hl)
    ld (de), a        ; Data
    inc de
    dec bc
    
_:  xor (hl)
    bit 7, a
    jr z, _
    bit 5, a
    jr z, -_
    ; Error, abort
    ld a, 0xF0
    ld (0), a
    ld a, 0x81
    out (7), a
    ret
_:
    inc hl
    ld a, b
    or a
    jr nz, .loop
    ld a, c
    or a
    jr nz, .loop
    
    in a, (7)
    inc a
    out (7), a
    
    in a, (6)
    inc a
    out (6), a
    and 0b000000011
    or a
    jr nz, .preLoop
    
    ld a, 0x81
    out (7), a
    ret
.end:

#else ; Models that don't support placing RAM page 01 in bank 3 (mu0xc slower)
.ram:
    ld e, a
    
    ld a, swapSector
    ld (kernelGarbage + kernelGarbageSize - 1), a
.preLoop:
    ld hl, 0x4000
    ld bc, 0x4000
.loop:
    push af
        ld a, e
        out (6), a ; The inefficiency on this model comes from swapping pages during the loop
        ld d, (hl)
    pop af
    out (6), a
    ; copy D to (HL)
    ld a, 0xAA
    ld (0x0AAA), a    ; Unlock
    ld a, 0x55
    ld (0x0555), a    ; Unlock
    ld a, 0xA0
    ld (0x0AAA), a    ; Write command
    ld (hl), d        ; Data
    
    ld a, d
_:  cp (hl)
    jr nz, -_ ; Does this work?
    
    dec bc
    inc hl
    
    ld a, b
    or a
    ld a, (kernelGarbage + kernelGarbageSize - 1)
    jr nz, .loop
    ld a, c
    or a
    ld a, (kernelGarbage + kernelGarbageSize - 1)
    jr nz, .loop
    
    inc e
    ld a, (kernelGarbage + kernelGarbageSize - 1)
    inc a
    ld (kernelGarbage + kernelGarbageSize - 1), a
    and 0b000000011
    or a
    ld a, (kernelGarbage + kernelGarbageSize - 1)
    jr nz, .preLoop
    ret
.end:
#endif

; Inputs:    A: Destination page
;            B: Source page
; Outputs:   None
; Copies the contents of one page to another.  The destination should be cleared to $FF first.
copyFlashPage:
    push de
    ld d, a
    push af
    ld a, i
    ld a, i
    push af
    di
    ld a, d
    
    push hl
    push de
        push af
        push bc
        ld hl, .ram
#ifdef CPU15
            ld a, 1
            out (5), a
        
            ld de, kernelGarbage + 0x4000 ; By rearranging memory, we can make the routine perform better
            ld bc, .ram_end - .ram
            ldir
#else
        ld de, kernelGarbage
        ld bc, .ram_end - .ram
        ldir
#endif
        pop bc
        pop af
#ifdef CPU15
        ld hl, 0x4000
        add hl, sp
        ld sp, hl
        call kernelGarbage + 0x4000
        xor a
        out (5), a ; Restore correct memory mapping
        ld hl, 0
        add hl, sp
        ld bc, 0x4000
        or a
        sbc hl, bc
        ld sp, hl
#else
        call kernelGarbage
#endif
    pop de
    pop hl
    
    pop bc
    pop af
    jp po, _
    ei
_:  pop af
    ret
    
#ifdef CPU15
.ram:
    out (6), a ; Destination
    ld a, b
    out (7), a ; Source
    
.preLoop:    
    ld hl, 0x8000
    ld de, 0x4000
    ld bc, 0x4000
.loop:
    ld a, $AA
    ld ($0AAA), a    ; Unlock
    ld a, 0x55
    ld (0x0555), a    ; Unlock
    ld a, $A0
    ld ($0AAA), a    ; Write command
    ld a, (hl)
    ld (de), a        ; Data
    inc de
    dec bc
    
_:    xor (hl)
    bit 7, a
    jr z, _
    bit 5, a
    jr z, -_
    ; Error, abort
    ld a, 0xF0
    ld (0), a
    ld a, 0x81
    out (7), a
    ret
_:
    inc hl
    ld a, b
    or a
    jr nz, .loop
    ld a, c
    or a
    jr nz, .loop
    
    ld a, 0x81
    out (7), a
    ret
.ram_end:
#else ; Models that don't support placing RAM page 01 in bank 3 (mu0xc slower)
.ram:
    ld e, b
    
    ld (kernelGarbage + kernelGarbageSize - 1), a
.preLoop:
    ld hl, 0x4000
    ld bc, 0x4000
.loop:
    push af
        ld a, e
        out (6), a ; The inefficiency on this model comes from swapping pages during the loop
        ld d, (hl)
    pop af
    out (6), a
    ; copy D to (HL)
    ld a, $AA
    ld ($0AAA), a    ; Unlock
    ld a, 0x55
    ld (0x0555), a    ; Unlock
    ld a, $A0
    ld ($0AAA), a    ; Write command
    ld (hl), d        ; Data
    
    ld a, d
_:  cp (hl)
    jr nz, -_ ; Does this work?
    
    dec bc
    inc hl
    
    ld a, b
    or a
    ld a, (kernelGarbage + kernelGarbageSize - 1)
    jr nz, .loop
    ld a, c
    or a
    ld a, (kernelGarbage + kernelGarbageSize - 1)
    jr nz, .loop
    ret
.ram_end:
#endif
