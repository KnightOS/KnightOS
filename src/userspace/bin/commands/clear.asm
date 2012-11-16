; KnightOS version command
.nolist
#include "macros.inc"
#include "stdio.inc"
.nolist
; Header
    .db 0, 20
    .org 0
; Code
start:
    ;stdio(clearTerminal)
    rst $10 \ .db stdioId \ call clearTerminal
    ret
    