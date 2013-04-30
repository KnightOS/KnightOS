;; contextSwitch [System]
;;  Triggers a context switch early.
contextSwitch:
    di
    push af
    push bc
    push de
    push hl
    push ix
    push iy
    exx
    ex af, af'
    push af
    push bc
    push de
    push hl
    jr doContextSwitch

sysInterrupt:
    di
    push af
    push bc
    push de
    push hl
    push ix
    push iy
    exx
    ex af, af'
    push af
    push bc
    push de
    push hl
    
#ifdef USB
    jp usbInterrupt
interruptResume:
#endif
    
    in a, (0x04)
    bit 0, a
    jr nz, intHandleON
    bit 1, a
    jr nz, intHandleTimer1
    bit 2, a
    jr nz, intHandleTimer2
    bit 4, a
    jr nz, intHandleLink
    jr contextSwitch
intHandleON:
    in a, (0x03)
    res 0, a
    out (0x03), a
    set 0, a
    out (0x03), a
    
    ; 0xCeck for special keycodes
    jp handleKeyboard
intHandleTimer1:
    in a, (0x03)
    res 1, a
    out (0x03), a
    set 1, a
    out (0x03), a
    ; Timer 1 interrupt
doContextSwitch:
    ld a, (currentThreadIndex)
    add a, a
    add a, a
    add a, a
    ld hl, threadTable + 3
    add a, l
    ld l, a
    ex de, hl
        ld hl, 0
        add hl, sp
    ex de, hl
    ; Save stack pointer
    ld (hl), e
    inc hl
    ld (hl), d
  
contextSwitch_search:
    ld a, (currentThreadIndex)
    inc a \ ld (currentThreadIndex), a
    ld b, a
    ld a, (activeThreads)
    or a \ jp z, boot ; Reboot when there are no active threads
    dec a \ cp b
    jr nc, _
    xor a
    ld b, a
    ld (currentThreadIndex), a
_:  ld a, b
    add a, a
    add a, a
    add a, a
    
    ld hl, threadTable + 5
    add a, l
    ld l, a
    ld a, (hl)
    bit 1, a ; May be suspended
    jr nz, _
    bit 2, a
    jr nz, contextSwitch_search ; Suspended
    
_:  dec hl
    ld d, (hl)
    dec hl
    ld e, (hl)
    ex de, hl
    ld sp, hl
    
    jr sysInterruptDone
intHandleTimer2:
    in a, (0x03)
    res 2, a
    out (0x03), a
    set 2, a
    out (0x03), a
    ; Timer 2 interrupt
    
    ; Run priority hook
    ld hl, (priorityHook)
    xor a
    cp h
    jr z, sysInterruptDone
    cp l
    jr z, sysInterruptDone
    ld de, sysInterruptDone
    push de
    jp (hl)    
    
intHandleLink:
    in a, (0x03)
    res 4, a
    out (0x03), a
    set 4, a
    out (0x03), a
    ; Link interrupt
sysInterruptDone:
    pop hl
    pop de
    pop bc
    pop af
    exx
    ex af, af'
    pop iy
    pop ix
    pop hl
    pop de
    pop bc
    pop af
    ei
    ret
    
handleKeyboard:
    ld a, 0xFF
    out (1), a
    ; Try ON+MODE
    ld a, 0xBF
    out (1), a
    in a, (1)
    bit 6, a
    jr z, handleOnMODE
    jr sysInterruptDone
    
handleOnMODE:
    ld de, bootFile
    call launchProgram
    ld h, 1
    call setInitialA
    jr sysInterruptDone
    
#ifdef USB
usbInterrupt:
    in a, (0x55) ; USB Interrupt status
    bit 0, a
    jr z, usbUnknownEvent
    bit 2, a
    jr z, usbLineEvent
    bit 4, a
    jr z, usbProtocolEvent
    jp interruptResume
    
usbUnknownEvent:
    jp interruptResume
    
usbLineEvent:
    in a, (0x56) ; USB Line Events
    xor 0xFF
    out (0x57), a ; Acknowledge interrupt and disable further interrupts
    jp interruptResume
    
usbProtocolEvent:
    in a, (0x82)
    in a, (0x83)
    in a, (0x84)
    in a, (0x85)
    in a, (0x86) ; Merely reading from these will acknowledge the interrupt
    jp interruptResume
#endif