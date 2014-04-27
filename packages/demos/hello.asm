#include "kernel.inc"
#include "corelib.inc"
#include "hello.lang"
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
    
    ld b, 2
    ld de, 0x0208
    kld(hl, helloString)
    pcall(drawStr)

    kld(hl, kernelString)
    pcall(drawStr)

    ld hl, kernelVersion
    pcall(drawStr)
    
    kld(hl, bootCodeString)
    pcall(drawStr)
    
    pcall(getBootCodeVersionString)
    pcall(drawStr)
    pcall(free)
    
_:  pcall(fastCopy)
    pcall(flushKeys)
    corelib(appWaitKey)
    cp kMode
    jr nz, -_
    ret

helloString:
    .db lang_helloString, 0
windowTitle:
    .db lang_windowTitle, 0
kernelString:
    .db "\n\nKernel Version: \n", 0
bootCodeString:
    .db "\n\nBoot Code Version: \n", 0
corelibPath:
    .db "/lib/core", 0
