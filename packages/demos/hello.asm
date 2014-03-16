.nolist
#include "kernel.inc"
#include "corelib.inc"
#include "hello.lang"
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
