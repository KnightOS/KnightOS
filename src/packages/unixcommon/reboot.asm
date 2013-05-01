.nolist
#include "kernel.inc"
#include "macros.inc"
#include "stdio.inc"
.list
; Header
    .db 0
    .db 0 ; Stack size
; Program
.org 0

start:
    jp reboot