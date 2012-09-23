.nolist
#include "kernel.inc"
#include "macros.inc"
#include "libtext.inc"
#include "defines.inc"
.list
; Header
    .db 0  ; TODO: Thread flags
    .db 50 ; Stack size
; Program
.org 0
start:
    call allocScreenBuffer
    call clearBuffer
    
    kld de, libTextPath
    call loadLibrary
    
    ld b, 0
    ld de, 0
    kld hl, helloString
    ;libtext(drawStr)
    rst $10
    .db libTextId
    call drawStr
    call fastCopy
    
    call flushKeys
    call waitKey
    ret
helloString:
    .db "Hello, world!\nPress any key to exit.", 0
libTextPath:
    .db "/lib/libtext", 0