getLCDLock:
    push af
        call getCurrentThreadId
        ld (hwLockLCD), a
    pop af
    ret
    
getIOLock:
    push af
        call getCurrentThreadId
        ld (hwLockIO), a
    pop af
    ret
    
getKeypadLock:
    push af
        call getCurrentThreadId
        ld (hwLockKeypad), a
    pop af
    ret
    
getUSBLock:
    push af
        call getCurrentThreadId
        ld (hwLockUSB), a
    pop af
    ret
    
hasLCDLock:
    push hl
    push af
        call getCurrentThreadId
        ld hl, hwLockLCD
        cp (hl)
    pop hl
    ld a, h
    pop hl
    ret
    
hasIOLock:
    push hl
    push af
        call getCurrentThreadId
        ld hl, hwLockIO
        cp (hl)
    pop hl
    ld a, h
    pop hl
    ret
    
hasKeypadLock:
    push hl
    push af
        call getCurrentThreadId
        ld hl, hwLockKeypad
        cp (hl)
    pop hl
    ld a, h
    pop hl
    ret
    
hasUSBLock:
#ifdef USB
    push hl
    push af
        call getCurrentThreadId
        ld hl, hwLockUsb
        cp (hl)
    pop hl
    ld a, h
    pop hl
    ret
#else
    push bc
        ld b, a
        or a
        ld a, b
    pop bc
#endif
    ret
    