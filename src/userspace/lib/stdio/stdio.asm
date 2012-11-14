; KnightOS stdio library
; Handles complex communication between threads via signals

.nolist
libId .equ $03
#include "kernel.inc"
; Commands
cmdNone .equ 0
cmdPrintString .equ 1
cmdPrintLine .equ 2
.list

.dw $0002

.org 0

jumpTable:
    ret \ nop \ nop
    ret \ nop \ nop
    jp registerThread
    jp releaseThread
    
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
    ret
    
printString:
    
    ret
