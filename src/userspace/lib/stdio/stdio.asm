; KnightOS stdio library
; Handles complex communication between threads via signals

.nolist
libId .equ 0x03
#include "kernel.inc"
#include "macros.inc"
; Commands
cmdNone .equ 0
cmdPrintChar .equ 1
cmdPrintString .equ 2
cmdPrintLine .equ 3
cmdClearTerminal .equ 4
cmdPrintDecimal .equ 5
cmdReadLine .equ 6
cmdPrintHex .equ 7
cmdEnableUpdates .equ 8
cmdDisableUpdates .equ 9
.list

.dw 0x0003

.org 0

jumpTable:
    ret \ nop \ nop
    ret \ nop \ nop
    jp registerThread
    jp releaseThread
    jp readCommand
    jp printChar
    jp printString
    jp printLine
    jp clearTerminal
    jp getSupervisor
    jp printDecimal
    jp readLine
    jp printHex
    jp enableUpdates
    jp disableUpdates
    
threadRegistration:
    ; Supervisor, Child
    .db 0xFF, 0xFF
    .db 0xFF, 0xFF
    .db 0xFF, 0xFF
    .db 0xFF, 0xFF
    .db 0xFF, 0xFF
    .db 0xFF, 0xFF

; TODO: Thread registration might not even really be needed
    
; A: Thread ID
; Registers the current thread as the supervisor for a given thread
registerThread:
    push bc
    push hl
    push af
    ; Find a suitible registration entry
    ld b, 6
    ild(hl, threadRegistration)
_:  ld a, (hl)
    cp 0xFF
    jr z, _
    inc hl \ inc hl
    djnz -_
    pop af
    pop hl
    pop bc
    ret
_:  ; Use (hl)
    call getCurrentThreadId
    ld (hl), a \ inc hl
    pop af
    ld (hl), a
    pop hl
    pop bc
    ret
    
; A: Thread ID
; Releases control of the specified thread. Note that this does not happen automatically -
; you must call this when the thread exits.
releaseThread:
    push bc
    push hl
    push af
    ld c, a
    ld b, 6
    ild(hl, threadRegistration + 1)
_:  ld a, (hl)
    cp c
    jr z, _
    inc hl \ inc hl
    djnz -_
    pop af
    pop hl
    pop bc
    ret
_:  ; Use (hl)
    ld a, 0xFF
    ld (hl), a \ dec hl \ ld (hl), a
    pop af
    pop hl
    pop bc
    ret
    
getSupervisor:
    push bc
    push hl
    ; Find a suitible registration entry
    ld b, 6
    call getCurrentThreadId
    ld c, a
    ild(hl, threadRegistration + 1)
_:  ld a, (hl)
    cp c
    jr z, _
    inc hl \ inc hl
    djnz -_
    pop hl
    pop bc
    or 1
    ret
_:  ; Use (hl)
    dec hl
    ld a, (hl)
    pop hl
    pop bc
    cp a
    ret
    
; Reads the latest command
readCommand:
    push bc
    call readSignal
    jr z, _
    xor a
    pop bc
    ret
_:  ld a, b
    pop bc
    ret

printChar:
    push af
    push bc
    push hl
        ld h, a
        ld b, cmdPrintChar
        icall(getSupervisor)
        jr nz, _
        call createSignal
_:  pop hl
    pop bc
    pop af
    call contextSwitch
    ret
    
printString:
    push af
    push bc
        ld b, cmdPrintString
        icall(getSupervisor)
        jr nz, _
        call createSignal
_:  pop bc
    pop af
    call contextSwitch
    ret
    
printLine:
    push af
    push bc
        ld b, cmdPrintLine
        icall(getSupervisor)
        jr nz, _
        call createSignal
_:  pop bc
    pop af
    call contextSwitch
    ret

clearTerminal:
    push af
    push bc
        ld b, cmdClearTerminal
        icall(getSupervisor)
        jr nz, _
        call createSignal
_:  pop bc
    pop af
    call contextSwitch
    ret
    
printDecimal:
    push af
    push bc
        ld b, cmdPrintDecimal
        icall(getSupervisor)
        jr nz, _
        call createSignal
_:  pop bc
    pop af
    call contextSwitch
    ret
    
readLine:
    push af
    push bc
        ld b, cmdReadLine
        icall(getSupervisor)
        jr nz, ++_
        call createSignal
        ; Wait for signal to be consumed
_:      call readSignal
        jr nz, -_
_:  pop bc
    pop af
    ret
    
printHex:
    push af
    push bc
    push hl
        ld h, a
        ld b, cmdPrintHex
        icall(getSupervisor)
        jr nz, _
        call createSignal
_:  pop hl
    pop bc
    pop af
    call contextSwitch
    ret
    
enableUpdates:
    push af
    push bc
        ld b, cmdEnableUpdates
        icall(getSupervisor)
        jr nz, _
        call createSignal
_:  pop bc
    pop af
    call contextSwitch
    ret
    
disableUpdates:
    push af
    push bc
        ld b, cmdDisableUpdates
        icall(getSupervisor)
        jr nz, _
        call createSignal
_:  pop bc
    pop af
    call contextSwitch
    ret
    