; KnightOS clear command
.nolist
#include "macros.inc"
#include "stdio.inc"
.nolist
; Header
    .db 0, 20
    .org 0
; Code
start:
    ljp(stdioId, clearTerminal)