.nolist
#include "kernel.inc"
#include "macros.inc"
#include "libtext.inc"
#include "keys.inc"
.list
; Header
    .db 0  ; TODO: Thread flags
    .db 50 ; Stack size
; Program
.org 0
start:
    call allocScreenBuffer

    kld de, libtext
    call loadLibrary
    
    kcall drawChrome
    kcall drawHome
    ld d, 0 ; Selection index
homeLoop:
    kcall drawHomeIcons
    call fastCopy
_:  call flushKeys
    call waitKey
    cp kClear
    jp z, boot
    cp kRight
    jr z, homeRightKey
    cp kLeft
    jr z, homeLeftKey
    jr -_
homeRightKey:
    inc d
    ;jr $
    jr homeLoop
homeLeftKey:
    dec d
    jr homeLoop
    
libtext:
    .db "/lib/libtext", 0
    
#include "castle/graphics.asm"