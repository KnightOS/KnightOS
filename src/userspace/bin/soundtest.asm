.nolist
#include "macros.inc"
#include "defines.inc"
#include "keys.inc"
#include "kernel.inc"
.nolist
; Header
    .db 0, 20
; Code
.org 0
start:
    call getKeypadLock
    call getIOLock
    kcall(hook)
    kld(hl, hook)
    ld (priorityHook), hl
_:  ld a, $FF
    out (1), a
    ld a, $FD
    out (1), a
    nop \ nop
    in a, (1)
    bit 6, a
    jr nz, -_
    
    ld hl, 0
    ld (priorityHook), hl
    ret

hook:
    kld(a, (state))
    out (0), a
    xor %11
    kld((state), a)
    ret
    
state:
    .db 0