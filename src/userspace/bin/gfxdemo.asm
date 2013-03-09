.nolist
#include "kernel.inc"
#include "macros.inc"
#include "libtext.inc"
#include "applib.inc"
#include "keys.inc"
#include "defines.inc"
#include "stdio.inc"
#include "gfxdemo.lang"
.list
; Header
    .db 0
    .db 50 ; Stack size
; Program
.org 0
; KnightOS Header
    jr start
    .db 'K'
    .db %00000010
    .db lang_description, 0

start:
    ; Load dependencies
    kld(de, stdioPath)
    call loadLibrary
    kld(de, libTextPath)
    call loadLibrary
    kld(de, applibPath)
    call loadLibrary

    kld(hl, demoMessage)
    stdio(printLine)
    
    call getLcdLock
    call getKeypadLock

    call allocScreenBuffer
    
    kld(hl, windowTitle)
    xor a
    applib(drawWindow)
    
    ld b, 2
    ld de, $0208
    kld(hl, exitString)
    libtext(drawStr)
    
    kld(hl, smileySprite)
    ld de, $0210
_:  ld b, 5
    call putSpriteXor
    call fastCopy
    applib(appGetKey)
    call putSpriteXor
    cp kClear
    jr z, exit
    cp kUp
    jr z, doUp
    cp kDown
    jr z, doDown
    cp kLeft
    jr z, doLeft
    cp kRight
    jr z, doRight
    jr -_
doUp:
    dec e
    jr -_
doDown:
    inc e
    jr -_
doLeft:
    dec d
    jr -_
doRight:
    inc d
    jr -_
    
exit:
    kld(hl, goodbyeMessage)
    stdio(printLine)
    ret
    
threadListPath:
    .db "/bin/threadlist", 0
    
exitString:
    .db lang_exitString, 0
windowTitle:
    .db lang_windowTitle, 0
libTextPath:
    .db "/lib/libtext", 0
applibPath:
    .db "/lib/applib", 0
stdioPath:
    .db "/lib/stdio", 0
smileySprite:
    .db %01010000
    .db %01010000
    .db %00000000
    .db %10001000
    .db %01110000
goodbyeMessage:
    .db "Goodbye!", 0
demoMessage:
    .db "KnightOS Graphical Demo", 0