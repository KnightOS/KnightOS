#include "kernel.inc"
#include "macros.inc"
#include "libtext.inc"
; Header
    .db 0  ; TODO: Thread flags
    .db 10 ; Stack size
; Program
.org 0
start:
    call allocScreenBuffer
    call clearBuffer

    kld de, libtext
    call loadLibrary
    
    ld de, 0
    kld hl, message
    rst $10
    .db libTextId
    call drawStr
    call fastCopy
    
    call waitKey
    ret
message:    
    .db "Hello, world!", 0
libtext:
    .db "/lib/libtext", 0