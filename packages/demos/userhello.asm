.nolist
#include "stdio.inc"
#include "kernel.inc"
.nolist
    .db 0, 20
.org 0
start:
    kld(hl, message)
    stdio(printString)
    
    ld bc, 128
    call malloc
    push ix \ pop hl
    
    stdio(readLine)
    
    push hl
        kld(hl, message2)
        stido(printString)
    pop hl
    
    stido(printString)
    
    kld(hl, message3)
    stido(printString)
    ret
    
message:
    .db "What is your name?\n", 0
message2:
    .db "Hello, ", 0
message3:
    .db "!\n", 0