; KnightOS stdio library
; Handles complex communication between threads via signals

.nolist
libId .equ $03
#include "kernel.inc"
; Commands
cmdNone .equ 0
cmdPrintChar .equ 1
cmdPrintString .equ 2
cmdPrintLine .equ 3
cmdClearTerminal .equ 4
.list

.dw $0003

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
    
threadRegistration:
    ; Supervisor, Child
    .db $FF, $FF
    .db $FF, $FF
    .db $FF, $FF
    .db $FF, $FF
    .db $FF, $FF
    .db $FF, $FF

; TODO: Thread registration might not even really be needed
    
; A: Thread ID
; Registers the current thread as the supervisor for a given thread
registerThread:
    push bc
    push hl
    push af
    ; Find a suitible registration entry
    ld b, 6
    ;lld(hl, threadRegistration)
    rst $10 \ .db libId \ ld hl, threadRegistration
_:  ld a, (hl)
    cp $FF
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
    ;lld(hl, threadRegistration)
    rst $10 \ .db libId \ ld hl, threadRegistration + 1
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
    ld a, $FF
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
    ;lld(hl, threadRegistration)
    rst $10 \ .db libId \ ld hl, threadRegistration + 1
_:  ld a, (hl)
    cp c
    jr z, _
    inc hl \ inc hl
    djnz -_
    pop hl
    pop bc
    ret
_:  ; Use (hl)
    dec hl
    ld a, (hl)
    pop hl
    pop bc
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
    push hl
        ld h, a
        ld b, cmdPrintChar
        ;lcall(getSupervisor)
        rst $10 \ .db libId \ call getSupervisor
        call createSignal
    pop hl
    pop af
    halt ; TODO: Wait until signal is read
    ret
    
printString:
    push af
        ld b, cmdPrintString
        ;lcall(getSupervisor)
        rst $10 \ .db libId \ call getSupervisor
        call createSignal
    pop af
    halt ; TODO: Wait until signal is read
    ret
    
printLine:
    push af
        ld b, cmdPrintLine
        ;lcall(getSupervisor)
        rst $10 \ .db libId \ call getSupervisor
        call createSignal
    pop af
    halt ; TODO: Wait until signal is read
    ret

clearTerminal:
    push af
        ld b, cmdClearTerminal
        ;lcall(getSupervisor)
        rst $10 \ .db libId \ call getSupervisor
        call createSignal
    pop af
    halt ; TODO: Wait until signal is read
    ret