.nolist
#include "stdio.inc"
#include "macros.inc"
#include "kernel.inc"
.nolist
; Header
    .db 0, 20
; Code
.org 0
start:
    kld hl, message
    ;stdio(printString)
    rst $10 \ .db stdioId \ call printString
    
    ld bc, 128
    call malloc
    push ix \ pop hl
    
    ;stdio(readLine)
    rst $10 \ .db stdioId \ call readLine
    
    push hl
        kld hl, message2
        ;stido(printString)
        rst $10 \ .db stdioId \ call printString
    pop hl
    
    ;stido(printString)
    rst $10 \ .db stdioId \ call printString
    
    kld hl, message3
    ;stido(printString)
    rst $10 \ .db stdioId \ call printString
    ret
    
message:
    .db "What is your name?\n", 0
message2:
    .db "Hello, ", 0
message3:
    .db "!\n", 0