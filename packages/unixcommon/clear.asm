; KnightOS clear command
.nolist
#include "kernel.inc"
#include "stdio.inc"
.nolist
    .db 0, 20
.org 0
start:
    stdio(clearTerminal)
    ret