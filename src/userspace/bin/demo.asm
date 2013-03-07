.nolist
#include "stdio.inc"
#include "macros.inc"
.nolist
; Header
    .db 0, 20
; Code
.org 0
start:
    kld(hl, message)
    stdio(printLine)
    ret
    
message:
    .db "Hello, world!", 0