#include "kernel.inc"
#include "corelib.inc"
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
    .db "System Settings", 0
start:
    pcall(getLcdLock)
    pcall(getKeypadLock)

    pcall(allocScreenBuffer)
    
    ; Load dependencies
    kld(de, corelibPath)
    pcall(loadLibrary)
    
    kld(hl, windowTitle)
    xor a
    corelib(drawWindow)

    ld de, 0x0208
    ld b, 2

    kld(hl, systemVersionStr)
    pcall(drawStr)

    push de
        kld(de, etcVersion)
        pcall(openFileRead)
        pcall(getStreamInfo)
        pcall(malloc)
        inc bc
        pcall(streamReadToEnd)
        pcall(closeStream)
        push ix \ pop hl
        add hl, bc
        dec hl
        xor a
        ld (hl), a
        push ix \ pop hl
    pop de
    ld b, 2
    inc d \ inc d \ inc d
    pcall(drawStr)
    pcall(free)

    kld(hl, kernelVersionStr)
    pcall(drawStr)
    
    ld hl, kernelVersion
    inc d \ inc d \ inc d
    pcall(drawStr)
    pcall(newline)
    
    kld(hl, bootCodeVersionStr)
    pcall(drawStr)
    
    pcall(getBootCodeVersionString)
    inc d \ inc d \ inc d
    pcall(drawStr)
    push hl \ pop ix
    pcall(free)

    pcall(newline)
    pcall(newline)

    kld(hl, backStr)
    ld d, 6
    ld b, 5
    push de
        pcall(drawStr)
    pop de
    ld d, 2
    kld(hl, caretIcon)
    pcall(putSpriteOR)

_:  pcall(fastCopy)
    pcall(flushKeys)
    corelib(appWaitKey)
    jr nz, -_
    ret

corelibPath:
    .db "/lib/core", 0
etcVersion:
    .db "/etc/version", 0
windowTitle:
    .db "System Settings", 0
systemVersionStr:
    .db "KnightOS version:\n", 0
kernelVersionStr:
    .db "Kernel version:\n", 0
bootCodeVersionStr:
    .db "Boot Code version:\n", 0
backStr:
    .db "Back", 0

caretIcon:
    .db 0b10000000
    .db 0b11000000
    .db 0b11100000
    .db 0b11000000
    .db 0b10000000
