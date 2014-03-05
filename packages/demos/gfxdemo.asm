.nolist
#include "kernel.inc"
#include "applib.inc"
#include "gfxdemo.lang"
.list
    .db 0, 50 ; Stack size
.org 0
    jr start
    .db 'K'
    .db 0b00000010
    .db lang_description, 0
start:
    ; Load dependencies
    kld(de, applibPath)
    call loadLibrary
    
    call resetLegacyLcdMode
    call getLcdLock
    call getKeypadLock

    call colorSupported
    jr nz, _
_:  ld iy, 0b1111100000000000 ; Red
    call clearColorLcd
    call flushKeys
    applib(appWaitKey)
    jr nz, -_

_:  ld iy, 0b0000011111100000 ; Green
    call clearColorLcd
    call flushKeys
    applib(appWaitKey)
    jr nz, -_

_:  ld iy, 0b0000000000011111 ; Blue
    call clearColorLcd
    call flushKeys
    applib(appWaitKey)
    jr nz, -_

    ; TODO: More color demos

    ret

_:  call allocScreenBuffer
    
    kld(hl, windowTitle)
    xor a
    applib(drawWindow)
    
    ld b, 2
    ld de, 0x0208
    kld(hl, exitString)
    call drawStr
    
    kld(hl, smileySprite)
    ld de, 0x0210
_:  ld b, 5
    call putSpriteXor
    call fastCopy
    applib(appGetKey)
    call putSpriteXor
    cp kClear
    ret z
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
    
threadListPath:
    .db "/bin/threadlist", 0
    
exitString:
    .db lang_exitString, 0
windowTitle:
    .db lang_windowTitle, 0
applibPath:
    .db "/lib/applib", 0
stdioPath:
    .db "/lib/stdio", 0
smileySprite:
    .db 0b01010000
    .db 0b01010000
    .db 0b00000000
    .db 0b10001000
    .db 0b01110000
