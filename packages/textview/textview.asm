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

        xor a
        ld l, 7
        pcall(resetPixel)
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
drawLoop:
    pcall(wrapStr)

_:  pcall(fastCopy)

    pcall(flushKeys)
    pcall(waitKey)

    cp kMODE
    ret z

    cp kDown
    jr z, .down
    cp kEnter
    jr z, .down
    jr -_
.down:
    ld a, (hl)
    or a
    jr z, -_ ; Skip this if at end of file
    push hl
    push de
        push iy \ pop hl
        ld bc, 12 * 10
        add hl, bc
        push hl \ pop de
        ld bc, 12 * 6
        add hl, bc
        ld bc, (96 * 53) / 8
        ldir

        push iy \ pop hl
        ld bc, 12 * (64 - 6)
        add hl, bc
        push hl \ pop de
        inc de
        xor a
        ld (hl), a
        ld bc, 6 * 12 - 1
        ldir
    pop de
    pop hl
    ld a, -6
    add a, e
    ld e, a
    ld d, 0
    ld b, 0
    ; Hacky workaround
    ld a, (hl)
    cp '\n'
    jr nz, drawLoop
    inc hl
    jr drawLoop

corelibPath:
    .db "/lib/core", 0
