.nolist
#include "kernel.inc"
.list
    .db 0, 50
.org 0
    kld(de, inittab)
    call openFileRead
    call getStreamInfo
    call malloc
    call streamReadToEnd
    call closeStream
    ld d, b \ ld b, c \ ld c, d
    inc c
    push ix \ pop de
    push ix
.loop:
        ld a, (ix)
        cp '\n'
        jr z, .launch
        
        inc ix
        djnz .loop
        dec c
        jr nz, .end

.launch:
        xor a
        ld (ix), a
        call launchProgram
        call contextSwitch
        inc ix
        push ix \ pop de
        djnz .loop
        dec c
        jr nz, .loop

.end:
    pop ix
    call free
    ret

inittab:
    .db "/etc/inittab", 0
