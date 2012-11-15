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
    ; Include stdio
    kld de, stdioPath
    call loadLibrary
    
    ;stdio(printLine)
    rst $10 \ .db stdioId \ call printLine
    ret

stdioPath:
    .db "/lib/stdio", 0