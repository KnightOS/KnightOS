.nolist
#include "kernel.inc"
#include "macros.inc"
#include "libtext.inc"
#include "keys.inc"
#include "defines.inc"
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
    cp kUp
    jr z, homeUpKey
    cp kDown
    jr z, homeDownKey
    jr -_
homeRightKey:
    ld a, 9
    cp d
    jr z, -_
    inc d
    jr homeLoop
homeLeftKey:
    xor a
    cp d
    jr z, -_
    dec d
    jr homeLoop
homeUpKey:
    ld a, 4
    cp d
    jr nc, -_
    ld a, d \ sub 5 \ ld d, a
    jr homeLoop
homeDownKey:
    ld a, 4
    cp d
    jr c, -_
    inc a \ add a, d \ ld d, a
    jr homeLoop
    
libtext:
    .db "/lib/libtext", 0
    
#include "castle/graphics.asm"