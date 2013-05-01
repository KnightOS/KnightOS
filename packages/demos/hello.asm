.nolist
#include "kernel.inc"
#include "applib.inc"
#include "hello.lang"
.list
    .db 0, 50
.org 0
    jr start
    .db 'K'
    .db 0b00000010
    .db lang_description, 0
start:
    call getLcdLock
    call getKeypadLock

    call allocScreenBuffer
    
    ; Load dependencies
    kld(de, applibPath)
    call loadLibrary
    
    kld(hl, windowTitle)
    xor a
    applib(drawWindow)
    
    ld b, 2
    ld de, 0x0208
    kld(hl, helloString)
    call drawStr
    
    ld de, 0x0219
    kld(hl, bootCodeString)
    call drawStr
    
    call getBootCodeVersionString
    call drawStr
    call free
    
_:  call fastCopy
    call flushKeys
    applib(appWaitKey)
    cp kClear
    jr nz, -_
    ret
    
helloString:
    .db lang_helloString, 0
windowTitle:
    .db lang_windowTitle, 0
bootCodeString:
    .db "Boot Code Version: \n", 0
applibPath:
    .db "/lib/applib", 0