.nolist
#include "kernel.inc"
.list
    .db 0, 50
.org 0
    ; TODO: Make this read from /etc/inittab
    ; Right now it's pretty much the most useless init program ever
    kld(de, castlePath)
    jp launchProgram
    ;ret

castlePath:
    .db "/bin/castle", 0
