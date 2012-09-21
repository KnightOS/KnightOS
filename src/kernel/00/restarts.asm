; rst $08
kcall:
    push hl
    inc sp \ inc sp
    pop hl
    push hl
    dec sp \ dec sp
    push de
    push bc
    push af

    ; HL has return address, stack is intact
    dec hl
    ld (hl), 0
    inc hl

    ld a, (hl)
    cp $DD
    jr z, _
    cp $FD
    jr nz, ++_
_:
    inc hl ; Handle IX/IY prefix
_:

    inc hl

    ld c, (hl)
    inc hl
    ld b, (hl)
    dec hl

    push hl
        ld hl, threadTable + 1
        ld a, (currentThreadIndex)
        add a, a
        add a, a
        add a, a
        add a, l
        ld l, a
        jr nc, $+3
        inc h

        ld e, (hl)
        inc hl
        ld d, (hl)
    pop hl

    ex de, hl
    add hl, bc
    ex de, hl

    ld (hl), e
    inc hl
    ld (hl), d

    pop af
    pop bc
    pop de
    pop hl
    ret
    