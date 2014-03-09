.nolist
#include "kernel.inc"
.list
    .db 0, 50
.org 0
    kld(de, inittab)
    pcall(openFileRead)
    pcall(getStreamInfo)
    pcall(malloc)
    pcall(streamReadToEnd)
    pcall(closeStream)
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
        pcall(launchProgram)
        pcall(contextSwitch)
        inc ix
        push ix \ pop de
        djnz .loop
        dec c
        jr nz, .loop

.end:
    pop ix
    pcall(free)
    ret

inittab:
    .db "/etc/inittab", 0
