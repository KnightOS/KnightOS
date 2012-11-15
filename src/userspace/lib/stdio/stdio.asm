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

; A: Thread ID
; Registers the current thread as the supervisor for a given thread
registerThread:
    ret
    
; A: Thread ID
; Releases control of the specified thread. Note that this does not happen automatically -
; you must call this when the thread exits.
releaseThread:
    ret
    
; A: Thread ID
; Reads the latest command from the specified thread.
readCommand:
    xor a
    ; TODO
    ret

printChar:
    ret
    
printString:
    ret
    
printLine:
    ret

clearTerminal:
    ret