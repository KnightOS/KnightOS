; KnightOS Terminal Input Parser

parseInput:
    push de
        ; Replace the first space with a zero
        push ix \ pop hl
_:      ld a, (hl)
        or a
        jr z, _ ; End if zero
        cp ' '
        jr z, _
        inc hl \ inc de
        jr -_
_:      xor a
        ld (hl), a
        inc hl
        ; Check if that file exists
        call memSeekToStart
        push ix \ pop de
        call fileExists
        ; TODO: Use $PATH and CD, currently just uses "/bin/"
        jr nz, parseInput_error
        ; File exists, execute it
        kcall term_launchProgram
        cp a
parseInput_error:
    pop de
    ret
    
term_launchProgram:
    di
    call launchProgram
    call setInitialHL
    ld b, a
    ei \ halt
ioLoop:
    ; We can be given focus again through the threadlist, so make sure everything
    ; still looks nice and we are responsive
    ; TODO: appGetKey appears to break the thread list here
    ; Probably the same problem as that one problem
    ; applib(appGetKey)
    rst $10 \ .db applibId \ call appGetKey
    call fastCopy
    ; Check if the thread is still alive
    ld a, b
    call getThreadEntry
    jr z, ioLoop
    ; Reset state
    call getLcdLock
    call getKeypadLock
    call flushKeys
    ret