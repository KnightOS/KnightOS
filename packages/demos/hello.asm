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
    .db "Hello World", 0
start:
    pcall(getLcdLock)
    pcall(getKeypadLock)

    pcall(allocScreenBuffer)
    
    ; Load dependencies
    kld(de, corelibPath)
    pcall(loadLibrary)
    
redraw:
    kld(hl, windowTitle)
    xor a
    corelib(drawWindow)
    
    ld a, 2
    ld de, 0x0208
    ld bc, 95 << 8 | 56         ; Set limits on text area
    kld(hl, helloString)
    pcall(wrapStr)
    
_:  pcall(fastCopy)
    pcall(flushKeys)
    corelib(appWaitKey)
    cp kMode
    ret z
    jr -_

helloString:
    .db "Hello, world! As you can see it's a very long string, so it's fortunate that we have wrapping routines.\nPress [MODE] to exit.", 0
windowTitle:
    .db "Hello, world!", 0
corelibPath:
    .db "/lib/core", 0
