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
        pop bc \ push bc ; BC is X, Y
        ; File exists, execute it
        kcall term_launchProgram
        pop bc \ push de ; Update X, Y
        cp a
parseInput_error:
    pop de
    ret
    
; Launches a program and attaches to it
; Blocks until the program exits
term_launchProgram:
    di
    call launchProgram
    ;stdio(registerThread)
    rst $10 \ .db stdioId \ call registerThread
    call setInitialHL
    ld d, b \ ld e, c ; Terminal X, Y
    ei \ halt
ioLoop:
    push af
        ; We can be given focus again through the threadlist, so make sure everything
        ; still looks nice and we are responsive
        ; applib(appGetKey)
        rst $10 \ .db applibId \ call appGetKey
        call fastCopy
        
        ;stdio(readCommand)
        rst $10 \ .db stdioId \ call readCommand
        or a
        jr z, pingThread
        ; Handle command
        cp cmdPrintHex
        jr nz, _
        push af
            ld a, h
            kcall term_printHex
        pop af
        
_:      cp cmdReadLine
        jr nz, _
        push ix
            push hl \ pop ix
            kcall term_readString
            push ix \ pop hl
        pop ix
        ld b, a
        pop af \ push af
        call createSignal
        ld a, b
        
_:      cp cmdPrintDecimal
        jr nz, _
        kcall term_printDecimal
        
_:      cp cmdClearTerminal
        jr nz, _
        ld de, leftMargin << 8 | 8
        push de \ push bc \ push hl \ push af
            ld e, 1 \ ld l, 7
            ld bc, 50 << 8 | 94
            call rectAND
        pop af \ pop hl \ pop bc \ pop de
        
_:      cp cmdPrintChar
        jr nz, _
        ld c, a \ ld a, h
        kcall term_printChar
        ld a, c
        
_:      cp cmdPrintString
        jr nz, _
        kcall term_printString
        
_:      cp cmdPrintLine
        jr nz, _
        kcall term_printString
        ld a, '\n'
        kcall term_printChar
_:
pingThread:
    ; Check if the thread is still alive
    pop af
    ld b, a
    call getThreadEntry
    jr z, ioLoop
    ; Release thread
    ld a, b
    ;stdio(releaseThread)
    rst $10 \ .db stdioId \ call releaseThread
    ; Reset state
    call getLcdLock
    call getKeypadLock
    call flushKeys
    ret