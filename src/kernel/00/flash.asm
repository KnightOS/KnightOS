; TODO: Add routines to erase certificate sectors (or add this to eraseFlashSector?)

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
            ld hl, writeFlashByte_RAM
            ld de, kernelGarbage
            ld bc, writeFlashByte_RAM_End - writeFlashByte_RAM
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
writeFlashByte_RAM:
    and (hl) ; Ensure that no bits are set
    ld b, a
        ld a, $AA
        ld ($0AAA), a    ; Unlock
        ld a, $55
        ld ($0555), a    ; Unlock
        ld a, $A0
        ld ($0AAA), a    ; Write command
    ld (hl), b        ; Data
    
    ; Wait for chip
_:  ld a, b
    xor (hl)
    bit 7, a
    jr z, writeFlashByte_Done
    bit 5, (hl)
    jr z, -_
    ; Error, abort
writeFlashByte_Done:
    ld (hl), $F0
    ret
writeFlashByte_RAM_End:

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
            ld hl, writeFlashBuffer_RAM
            ld de, kernelGarbage
            ld bc, writeFlashBuffer_RAM_End - writeFlashBuffer_RAM
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
    
writeFlashBuffer_RAM:
writeFlashBuffer_Loop:
    ld a, $AA
    ld ($0AAA), a    ; Unlock
    ld a, $55
    ld ($0555), a    ; Unlock
    ld a, $A0
    ld ($0AAA), a    ; Write command
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
    ld (hl), $F0
    ret
_:
    ld (hl), $F0
    inc hl
    ld a, b
    or a
    jr nz, writeFlashBuffer_Loop
    ld a, c
    or a
    jr nz, writeFlashBuffer_Loop
    ret
writeFlashBuffer_RAM_End:

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
            ld hl, eraseFlashSector_RAM
            ld de, kernelGarbage
            ld bc, eraseFlashSector_RAM_End - eraseFlashSector_RAM
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
    
eraseFlashSector_RAM:
    out (6), a
    ld a, $AA
    ld ($0AAA), a ; Unlock
    ld a, $55
    ld ($0555), a ; Unlock
    ld a, $80
    ld ($0AAA), a ; Write command
    ld a, $AA
    ld ($0AAA), a ; Unlock
    ld a, $55
    ld ($0555), a ; Unlock
    ld a, $30
    ld ($4000), a ; Erase
    ; Wait for chip
_:  ld a, ($4000)
    bit 7, a
    ret nz
    bit 5, a
    jr z, -_
    ; Error, abort
    ld a, $F0
    ld ($4000), a
    ret
eraseFlashSector_RAM_End:

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
        and %11111100
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
        and %11111100
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

    and %11111100 ; Get the sector for the specified page
    
    push hl
    push de
        ld hl, copySectorToSwap_RAM
#ifdef CPU15
        push af
            ld a, 1
            out (5), a
        
            ld de, kernelGarbage + $4000 ; By rearranging memory, we can make the routine perform better
            ld bc, copySectorToSwap_RAM_End - copySectorToSwap_RAM
            ldir
        pop af
#else
        ld de, kernelGarbage
        ld bc, copySectorToSwap_RAM_End - copySectorToSwap_RAM
        ldir
#endif
#ifdef CPU15
        ld hl, $4000
        add hl, sp
        ld sp, hl
        call kernelGarbage + $4000
        xor a
        out (5), a ; Restore correct memory mapping
        ld hl, 0
        add hl, sp
        ld bc, $4000
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
copySectorToSwap_RAM:
    out (7), a
    ld a, swapSector
    out (6), a
    
copySectorToSwap_PreLoop:    
    ld hl, $8000
    ld de, $4000
    ld bc, $4000
copySectorToSwap_Loop:
    ld a, $AA
    ld ($0AAA), a    ; Unlock
    ld a, $55
    ld ($0555), a    ; Unlock
    ld a, $A0
    ld ($0AAA), a    ; Write command
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
    ld a, $F0
    ld (0), a
    ld a, $81
    out (7), a
    ret
_:
    inc hl
    ld a, b
    or a
    jr nz, copySectorToSwap_Loop
    ld a, c
    or a
    jr nz, copySectorToSwap_Loop
    
    in a, (7)
    inc a
    out (7), a
    
    in a, (6)
    inc a
    out (6), a
    and %00000011
    or a
    jr nz, copySectorToSwap_PreLoop
    
    ld a, $81
    out (7), a
    ret
copySectorToSwap_RAM_End:

#else ; Models that don't support placing RAM page 01 in bank 3 (much slower)
copySectorToSwap_RAM:
    ld e, a
    
    ld a, swapSector
    ld (kernelGarbage + kernelGarbageSize - 1), a
copySectorToSwap_PreLoop:
    ld hl, $4000
    ld bc, $4000
copySectorToSwap_Loop:
    push af
        ld a, e
        out (6), a ; The inefficiency on this model comes from swapping pages during the loop
        ld d, (hl)
    pop af
    out (6), a
    ; copy D to (HL)
    ld a, $AA
    ld ($0AAA), a    ; Unlock
    ld a, $55
    ld ($0555), a    ; Unlock
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
    jr nz, copySectorToSwap_Loop
    ld a, c
    or a
    ld a, (kernelGarbage + kernelGarbageSize - 1)
    jr nz, copySectorToSwap_Loop
    
    inc e
    ld a, (kernelGarbage + kernelGarbageSize - 1)
    inc a
    ld (kernelGarbage + kernelGarbageSize - 1), a
    and %00000011
    or a
    ld a, (kernelGarbage + kernelGarbageSize - 1)
    jr nz, copySectorToSwap_PreLoop
    ret
copySectorToSwap_RAM_End:
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
        ld hl, copyFlashPage_RAM
#ifdef CPU15
            ld a, 1
            out (5), a
        
            ld de, kernelGarbage + $4000 ; By rearranging memory, we can make the routine perform better
            ld bc, copyFlashPage_RAM_End - CopyFlashPage_RAM
            ldir
#else
        ld de, kernelGarbage
        ld bc, copyFlashPage_RAM_End - CopyFlashPage_RAM
        ldir
#endif
        pop bc
        pop af
#ifdef CPU15
        ld hl, $4000
        add hl, sp
        ld sp, hl
        call kernelGarbage + $4000
        xor a
        out (5), a ; Restore correct memory mapping
        ld hl, 0
        add hl, sp
        ld bc, $4000
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
_:    pop af
    ret
    
#ifdef CPU15
copyFlashPage_RAM:
    out (6), a ; Destination
    ld a, b
    out (7), a ; Source
    
copyFlashPage_PreLoop:    
    ld hl, $8000
    ld de, $4000
    ld bc, $4000
copyFlashPage_Loop:
    ld a, $AA
    ld ($0AAA), a    ; Unlock
    ld a, $55
    ld ($0555), a    ; Unlock
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
    ld a, $F0
    ld (0), a
    ld a, $81
    out (7), a
    ret
_:
    inc hl
    ld a, b
    or a
    jr nz, copyFlashPage_Loop
    ld a, c
    or a
    jr nz, copyFlashPage_Loop
    
    ld a, $81
    out (7), a
    ret
copyFlashPage_RAM_End:

#else ; Models that don't support placing RAM page 01 in bank 3 (much slower)
copyFlashPage_RAM:
    ld e, b
    
    ld (kernelGarbage + kernelGarbageSize - 1), a
copyFlashPage_PreLoop:
    ld hl, $4000
    ld bc, $4000
copyFlashPage_Loop:
    push af
        ld a, e
        out (6), a ; The inefficiency on this model comes from swapping pages during the loop
        ld d, (hl)
    pop af
    out (6), a
    ; copy D to (HL)
    ld a, $AA
    ld ($0AAA), a    ; Unlock
    ld a, $55
    ld ($0555), a    ; Unlock
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
    jr nz, copyFlashPage_Loop
    ld a, c
    or a
    ld a, (kernelGarbage + kernelGarbageSize - 1)
    jr nz, copyFlashPage_Loop
    ret
copyFlashPage_RAM_End:
#endif
