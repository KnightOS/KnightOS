#include "kernel.inc"
#include "macros.inc"
; Header
    .db 0  ; TODO: Thread flags
    .db 10 ; Stack size
; Program
.org 0
start:
    jr $