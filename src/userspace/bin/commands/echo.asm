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
    ljp(stdioId, printLine)
    