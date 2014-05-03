#include "kernel.inc"
#include "corelib.inc"
    .db "KEXC"
    .db KEXC_ENTRY_POINT
    .dw start
    .db KEXC_STACK_SIZE
    .dw 50
    .db KEXC_KERNEL_VER
    .db 0, 6
    .db KEXC_NAME
    .dw name
    .db KEXC_HEADER_END
name:
    .db "Text Viewer", 0
start:
    or a
    ret z ; TODO: Handle launched w/o args

    push de ; Save file path
        pcall(getLcdLock)
        pcall(getKeypadLock)

        kld(de, corelibPath)
        pcall(loadLibrary)

        pcall(allocScreenBuffer)
        pcall(clearBuffer)

        ld de, 0x0006
        ld hl, 96 << 8 | 6
        pcall(drawLine)
    pop hl
    ld de, 0
    ld b, 0
    pcall(drawStr)
    ld a, ':'
    pcall(drawChar)

    ex de, hl
    pcall(openFileRead)
    ret nz
    ; For testing purposes, we'll load the file into RAM
    pcall(getStreamInfo)
    inc bc
    pcall(malloc)
    ret nz
    pcall(streamReadToEnd)
    pcall(closeStream)

    pcall(memSeekToEnd)
    ld (ix), 0
    pcall(memSeekToStart)
    
    push ix \ pop hl
    ld b, 0
    ld de, 0x000A
    pcall(drawStr)

    pcall(fastCopy)

    pcall(flushKeys)
    pcall(waitKey)
    ret

corelibPath:
    .db "/lib/core", 0
