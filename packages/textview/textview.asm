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
        kld(hl, test)
        ld de, 0
        ld b, 0
        pcall(drawStr)
    pop hl
    pcall(drawStr)

    pcall(fastCopy)

    pcall(flushKeys)
    pcall(waitKey)
    ret

corelibPath:
    .db "/lib/core", 0
test:
    .db "File: ", 0
