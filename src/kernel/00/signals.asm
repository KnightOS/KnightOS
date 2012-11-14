; KnightOS Signal Management
; For handling communication between threads

; Inputs:   A:  Target thread ID
;           B:  Message type
;           HL: Message payload
; Adds a signal to the signal queue
createSignal:
    push af
    push hl
    push de
    ld d, a ; Save thread ID
    ld a, i
    push af
        ld a, d
        push af
            ex de, hl
            ld a, (activeSignals)
            cp maxSignals
            jr nc, createSignal_tooMany
            add a, a \ add a, a
            ld hl, signalTable
            add a, l
            ld l, a
            jr nc, $+3 \ inc h
            ; HL points to target signal address
        pop af
        ld (hl), a \ inc hl \ ld (hl), b \ inc hl
        ld (hl), e \ inc hl \ ld (hl), d
        ld hl, activeSignals
        inc (hl)
    pop af
    jp po, _
    ei
_:  pop de
    pop hl
    pop af
    cp a
    ret
createSignal_tooMany:
    pop af
    pop af
    pop de
    pop hl
    jp po, _
    ei
_:  pop af
    or 1
    ld a, errTooManySignals
    ret
    
; Outputs:  NZ: No signals to read, or Z: Signal read, and:
;           B:  Message type
;           HL: Message payload
; Reads the next signal for the current thread.
readSignal:
    push af
    ld a, i
    push af
    push hl
    push bc
    push de
        ld de, 4
        ld a, (activeSignals)
        ld b, a
        call getCurrentThreadId
        ld hl, signalTable
        
_:      cp (hl)
        jr z, readSignal_found
        add hl, de
        djnz -_
    
readSignal_none:
    ; We don't want to destroy anything if it isn't found
    pop de
    pop bc
    pop hl
    pop af
    jp po, _
    ei
_:  pop af
    or 1
    ret
    
readSignal_found:
    inc hl \ ld a, (hl)
    inc hl \ ld e, (hl)
    inc hl \ ld d, (hl)
    ; Push values to return
    push af
    push de
        ; Remove signal
        dec hl \ dec hl \ dec hl
        ld d, h \ ld e, l
        ld bc, 4 \ add hl, bc
        ld a, (activeSignals)
        dec a ; Note: this will copy more than needed, but it isn't a problem
        jr z, _
        ld (activeSignals), a
        add a, a \ add a, a
        ld c, a \ ld b, 0
        ldir
    
_:  pop de
    pop af
    ex de, hl
    pop de
    pop bc
    ld b, a
    inc sp \ inc sp ; pop hl    
    pop af
    jp po, _
    ei
_:  pop af
    cp a
    ret
    