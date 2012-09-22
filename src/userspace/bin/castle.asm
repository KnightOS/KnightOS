.nolist
#include "kernel.inc"
#include "macros.inc"
#include "libtext.inc"
.list
; Header
    .db 0  ; TODO: Thread flags
    .db 10 ; Stack size
; Program
.org 0
start:
    call allocScreenBuffer

    kld de, libtext
    call loadLibrary
    
    kcall drawCastleChrome
    call fastCopy
    
    call waitKey
    ret
libtext:
    .db "/lib/libtext", 0
    
#include "castle/graphics.asm"