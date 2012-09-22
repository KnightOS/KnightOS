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
    ex de, hl
    ld a, (currentThreadIndex)
    push af
    ld a, (activeThreads)
    ld (currentThreadIndex), a ; Set the current thread to the new one so that allocated memory is owned appropraitely
    add a, a \ add a, a \ add a, a
    ld hl, threadTable
    add a, l
    ld l, a
    ld a, (nextThreadId)
    ; A is now a valid thread id, and hl points to the next-to-last entry
    ; DE is address of code, B is stack size / 2
    ld (hl), a \ inc hl ; *hl++ = a
    ld (hl), e \ inc hl \ ld (hl), d \ inc hl
    ; Allocate a stack
    push hl
    push ix
        ld a, b
        add a, b
        ld b, 0
        add a, 24 ; Required minimum stack size for system use
        ld c, a
        jr nc, $+3 \ inc b
        call allocMem
        jr nz, startThread_mem
        push ix \ pop hl
        add hl, bc
        push de
            ld de, killThread
            ld (hl), d \ dec hl \ ld (hl), e ; Put return point on stack
        pop de
        dec hl \ ld (hl), d \ dec hl \ ld (hl), e ; Put entry point on stack
        ld bc, 20 ; Size of registers on the stack
        or a \ sbc hl, bc
        ld b, h \ ld c, l
    pop ix
    pop hl
    pop af
    ld (currentThreadIndex), a
    ld (hl), c \ inc hl \ ld (hl), b \ inc hl ; Stack address
    pop af \ ld (hl), a \ inc hl ; Flags
    ld a, l
    sub 6
    ld l, a
    ld a, (activeThreads)
    inc a \ ld (activeThreads), a
    ld a, (nextThreadId) \ inc a \ ld (nextThreadId), a
    ld a, (hl)
    cp a
    ret
    
startThread_mem: ; Out of memory
    pop af \ pop af \ pop af
    ld (currentThreadIndex), a
    pop af
    ld a, errOutOfMem
    or 1
    ret
    
killThread:
    di
    
    ei
    ret
    