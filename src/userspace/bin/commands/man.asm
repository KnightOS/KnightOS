.nolist
#include "kernel.inc"
#include "macros.inc"
#include "stdio.inc"
.list
; Header
    .db 0
    .db 10 ; Stack size
; Program
.org 0

start:
    push hl
        kld hl, manDirectory
        ld bc, 128
        call malloc
        push ix \ pop de
        call stringCopy ; Copy man directory to allocated memory
        call stringLength
        or a \ adc hl, bc
        ex de, hl
        pop hl \ push hl
        dec de
        call stringCopy ; Copy command to allocated memory
        push ix \ pop de
        call fileExists
        jr z, _
        ; File doesn't exist
        kld hl, commandNotFoundText
        ;stdio(printString)
        rst $10 \ .db stdioId \ call printString
    pop hl
    rst $10 \ .db stdioId \ call printLine
    call free
    ret
    
_:  inc sp \ inc sp ; Discard this bit
    ; Display manual entry
    ;stdio(clearTerminal)
    rst $10 \ .db stdioId \ call clearTerminal
    ; TODO
    call free
    ret

manDirectory: ; TODO: Try loading these from config files
    .db "/etc/man/", 0
commandNotFoundText:
    .db "No manual entry for ", 0