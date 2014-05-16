.nolist
#include "kernel.inc"
#include "corelib.inc"
.list
    .db "KEXC"
    .db KEXC_ENTRY_POINT
    .dw start
    .db KEXC_STACK_SIZE
    .dw 50
    .db KEXC_KERNEL_VER
    .db 0, 6
    .db KEXC_NAME
    .dw name
    .db KEXC_THREAD_FLAGS
    .db THREAD_NON_SUSPENDABLE, 0
    .db KEXC_HEADER_END
name:
    .db "Counting Demo", 0
start:
    pcall(getLcdLock)
    pcall(getKeypadLock)

    pcall(allocScreenBuffer)

    ; Load dependencies
    kld(de, corelibPath)
    pcall(loadLibrary)
    ld b, 0
_:  push bc
        kld(hl, windowTitle)
        xor a
        corelib(drawWindow)

        ld b, 2
        ld de, 0x0208
        kld(hl, helloString)
        pcall(drawStr)
    pop bc

    ld a, b \ inc b
    ld de, 0x0210
    pcall(drawHexA)

    pcall(fastCopy)
    corelib(appGetKey)

    cp kMode
    jr nz, -_
    ret

helloString:
    .db "Press [MODE] to exit.", 0
windowTitle:
    .db "Counting Demo", 0
corelibPath:
    .db "/lib/core", 0
