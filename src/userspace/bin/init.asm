#include "kernel.inc"
#include "macros.inc"
; Header
    .db 0  ; TODO: Thread flags
    .db 10 ; Stack size
; Program
.org 0
start:
    kld de, castlePath
    call launchProgram
    ;jr $
    ret

castlePath:
    .db "/bin/castle", 0
terminalPath:
    .db "/bin/terminal", 0