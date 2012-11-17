; KnightOS dump command
.nolist
#include "kernel.inc"
#include "macros.inc"
#include "stdio.inc"
.nolist
; Header
    .db 0, 20
    .org 0
; Code
start:
    call hexToHL
    ;stdio(disableUpdates)
    rst $10 \ .db stdioId \ call disableUpdates
    
    ;stdio(clearTerminal)
    rst $10 \ .db stdioId \ call clearTerminal
    
    ld b, 7
verticalLoop:
    push bc
        ld b, 8
horizLoop:
        ld a, (hl)
        ;stdio(printHex)
        rst $10 \ .db stdioId \ call printHex
        ld a, ' '
        ;stdio(printChar)
        rst $10 \ .db stdioId \ call printChar
        inc hl
        djnz horizLoop
    ld a, '\n'
    ;stdio(printChar)
    rst $10 \ .db stdioId \ call printChar
    pop bc
    djnz verticalLoop
    
    ;stdio(enableUpdates)
    rst $10 \ .db stdioId \ call enableUpdates
    ret
