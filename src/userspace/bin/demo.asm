.nolist
#include "stdio.inc"
#include "macros.inc"
#include "kernel.inc"
#include "keys.inc"
#include "applib.inc"
.nolist
; Header
    .db 0, 20
; Code
.org 0
start:
    kld hl, message
    ;stdio(printLine)
    rst $10 \ .db stdioId \ call printLine
    
    kld de, applibPath
    call loadLibrary
    
    call getKeypadLock
_:  rst $10 \ .db applibId \ call appGetKey
    cp kMode
    jr nz, -_
    ret
    
message:
    .db "Hello, world!", 0
    
applibPath:
    .db "/lib/applib", 0