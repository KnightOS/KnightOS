; KnightOS version command
.nolist
#include "kernel.inc"
#include "macros.inc"
#include "stdio.inc"
.nolist
    .db 0, 20
.org 0
start:
    kld(hl, versionString)
    stdio(printLine)
    
    kld(hl, kernelVersion)
    stdio(printString)
    
    ; Print version number
    ld h, 0
    ld a, (5)
    ld l, a
    stdio(printDecimal)
    ld a, '.'
    stdio(printChar)
    ld a, (6)
    ld l, a
    stdio(printDecimal)
    
    ld a, '\n'
    stdio(printChar)
    
    kld(hl, bootCodeVersion)
    stdio(printString)
    
    call getBootCodeVersionString
    stdio(printLine)
    ret
    
; TODO: Localize
versionString:
    .db "KnightOS 0.1 Indev", 0
kernelVersion:
    .db "Kernel version: ", 0
bootCodeVersion:
    .db "Boot code version: ", 0