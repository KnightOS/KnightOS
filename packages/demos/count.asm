.nolist
#include "kernel.inc"
#include "corelib.inc"
#include "count.lang"
.list
    .db 0, 50
.org 0
    jr start
    .db 'K'
    .db 0b00000010
    .db lang_description, 0
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

    cp kClear
    jr nz, -_
    ret

helloString:
    .db lang_hello, 0
windowTitle:
    .db lang_windowTitle, 0
corelibPath:
    .db "/lib/core", 0
