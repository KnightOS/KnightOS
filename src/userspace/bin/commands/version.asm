; KnightOS version command
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
    kld hl, versionString
    ;stdio(printLine)
    rst $10 \ .db stdioId \ call printLine
    
    kld hl, kernelVersion
    ;stdio(printChar)
    rst $10 \ .db stdioId \ call printString
    ; TODO: Print version number
    ld a, '\n'
    ;stdio(printChar)
    rst $10 \ .db stdioId \ call printChar
    
    kld hl, bootCodeVersion
    ;stdio(printString)
    rst $10 \ .db stdioId \ call printString
    
    call getBootCodeVersionString
    ;stdio(printLine)
    rst $10 \ .db stdioId \ call printLine
    ret
    
versionString:
    .db "KnightOS 0.1 Indev", 0
kernelVersion:
    .db "Kernel version: ", 0
bootCodeVersion:
    .db "Boot code version: ", 0