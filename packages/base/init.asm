#include "kernel.inc"
    .db "KEXC"
    .db KEXC_ENTRY_POINT
    .dw start
    .db KEXC_STACK_SIZE
    .dw 20
    .db KEXC_KERNEL_VER
    .db 0, 6
    .db KEXC_NAME
    .dw name
    .db KEXC_HEADER_END
name:
    .db "init", 0
start:
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
    .asciiz "/etc/inittab"
