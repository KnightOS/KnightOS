.nolist
#include "kernel.inc"
#include "stdio.inc"
.list
; Header
    .db 0, 10
.org 0
start:
    stdio(printLine)
    ret