currentThreadID:
    push hl
        ld a, (currentThreadIndex)
        add a, a
        add a, a
        add a, a
        ld h, $80
        ld l, a
        ld a, (hl)
    pop hl
    ret
    
; Inputs:
; HL: Pointer to code
; B: Stack size to allocate / 2
; A: Thread flags
; Outputs:
; A: Thread ID of new thread, or error (with Z reset)
startThread:
    push af
        ld a, (activeThreads)
        cp maxThreads
        jr c, _
        jr z, _
        ld a, errTooManyThreads
    inc sp
    inc sp
    ret
_:  di
    push bc
        ex de, hl ; Choose a thread ID and locate the table slot to use
        ld hl, threadTable
        ld a, (activeThreads)
        ld b, a
        ld c, 0
_:      ld a, b ; while (b)
        or a
        jr z, ++_
        ld a, (hl) ; {
        cp c ; if (*hl != c)
        jr nz, _
        inc c ; else { inc c; continue; }
        jr -_ ; If the current id is taken, loop back again
_:      dec b
        push af ; HL += 8
            ld a, 8
            add a, l
            ld l, a
        pop af
        jr --_
_:      ld a, b
    pop bc
    ; A is now a valid thread id, and hl points to the next-to-last entry
    ; DE is address of code, BC is stack size / 2
    ; TODO: Works for starting the initial thread, test for subsequent threads
    ld (hl), a \ inc hl ; *hl++ = a
    ld (hl), e \ inc hl \ ld (hl), d \ inc hl
    ; Allocate a stack
    push hl
    push ix
        ld a, b
        add a, b
        ld c, a
        jr nc, $+3 \ inc b
        ld b, 0
        call allocMem
        jr nz, startThread_mem
        push ix \ pop hl
        add hl, bc
        dec hl \ ld (hl), d \ dec hl \ ld (hl), e ; Put entry point on stack
        ld bc, 20 ; Size of registers on the stack
        or a \ sbc hl, bc
        ld b, h \ ld c, l
    pop ix
    pop hl
    ld (hl), c \ inc hl \ ld (hl), b \ inc hl ; Stack address
    pop af \ ld (hl), a \ inc hl ; Stuff
    ld a, l
    sub 6
    ld l, a
    ld a, (activeThreads)
    inc a \ ld (activeThreads), a
    ld a, (hl)
    cp a
    ret
    
startThread_mem: ; Out of memory
    pop af
    ld a, errOutOfMem
    or 1
    ret
    