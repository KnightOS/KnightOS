; KnightOS Signal Management
; For handling communication between threads

; Inputs:   A:  Target thread ID
;           B:  Message type
;           HL: Message payload
; Adds a signal to the signal queue
createSignal:
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
    pop de
    jp po, _
    ei
_:  pop af
    ret
createSignal_tooMany:
    pop af
    or 1
    ld a, errTooManySignals
    ret
    
; Outputs:  NZ: No signals to read, or Z: Signal read, and:
;           BC: Message type
;           HL: Message payload
; Reads the next signal for the current thread.
readSignal:
    
    ret
    