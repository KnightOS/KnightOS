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
        kcall(term_launchProgram)
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
    push bc \ pop de ; Terminal X, Y
    jr nz, .error ; Handle error by just telling the user which error it is
    call setInitialHL
    stdio(registerThread)
    ei \ halt
.ioLoop:
    di
    push af
        ; We can be given focus again through the threadlist, so make sure everything
        ; still looks nice and we are responsive
        applib(appGetKey)
        ; Check if LCD updates are enabled
        push af
            kld(a, (enableLcdUpdates))
            or a
            jr z, _
                call fastCopy
_:      pop af
        
        stdio(readCommand)
        or a
        kcall(nz, handleCommand)
        call contextSwitch ; TODO: This is too slow, suspend the thread and make stdio wake it up
    ; Check if the thread is still alive
    pop af
    call getThreadEntry
    jr z, .ioLoop
    push af
        ; Final command check
        stdio(readCommand)
        or a
        kcall(nz, handleCommand)
    pop af
    stdio(releaseThread)
.cleanup:
    ; Reset state
    call getLcdLock
    call getKeypadLock
    call flushKeys
    ret
.error:
    push af
        kld(hl, launchErrorStr)
        kcall(term_printString)
    pop af \ push af
        kcall(term_printHex)
        kld(hl, colonStr)
        kcall(term_printString)
    pop af
    ; This next bit stolen from applib
    dec a
    push de
        kld(hl, errorMessages)
        add a \ add l \ ld l, a \ jr nc, $+3 \ inc h
        ld e, (hl) \ inc hl \ ld d, (hl)
        push de
        push ix
            push hl \ pop ix
            call memSeekToStart
            push ix \ pop bc
        pop ix
        pop hl
        add hl, bc
    pop de
    kcall(term_printString)
    ld a, '\n'
    kcall(term_printChar)
    ei
    jr .cleanup

handleCommand:
    push bc
        cp cmdDisableUpdates
        jr nz, _
        push af
            xor a
            kld((enableLcdUpdates), a)
        pop af
        
_:      cp cmdEnableUpdates
        jr nz, _
        push af
            ld a, 1
            kld((enableLcdUpdates), a)
        pop af
        
_:      cp cmdPrintHex
        jr nz, _
        push af
            ld a, h
            kcall(term_printHex)
        pop af
        
_:      cp cmdReadLine
        jr nz, _
        push ix
            push hl \ pop ix
            kcall(term_readString)
            push ix \ pop hl
        pop ix
        ld b, a
        pop af \ push af
        call createSignal
        ld a, b
        
_:      cp cmdPrintDecimal
        jr nz, _
        kcall(term_printDecimal)
        
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
        kcall(term_printChar)
        ld a, c
        
_:      cp cmdPrintString
        jr nz, _
        kcall(term_printString)
        
_:      cp cmdPrintLine
        jr nz, _
        kcall(term_printString)
        ld a, '\n'
        kcall(term_printChar)
_:  pop bc
    ret

#include "errors.asm"

enableLcdUpdates:
    .db 1
