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
    stdio(disableUpdates)
    
    stdio(clearTerminal)
    
    ld b, 7
verticalLoop:
    push bc
        ld b, 8
horizLoop:
        ld a, (hl)
        stdio(printHex)
        ld a, ' '
        stdio(printChar)
        inc hl
        djnz horizLoop
    ld a, '\n'
    stdio(printChar)
    pop bc
    djnz verticalLoop
    
    ljp(stdioId, enableUpdates)
