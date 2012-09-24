.nolist
#include "kernel.inc"
#include "macros.inc"
#include "libtext.inc"
#include "applib.inc"
#include "keys.inc"
#include "defines.inc"
.list
; Header
    .db 0  ; TODO: Thread flags
    .db 50 ; Stack size
; Program
.org 0
; KnightOS Header
    jr start
    .db 'K'
    .db "Hello world", 0
    .db %00000010

start:
    call getLcdLock
    call getKeypadLock

    call allocScreenBuffer
    call clearBuffer
    
    ; Load dependencies
    kld de, libTextPath
    call loadLibrary
    kld de, applibPath
    call loadLibrary
    
    ld b, 0
    ld de, 0
    kld hl, helloString
    ;libtext(drawStr)
    rst $10 \ .db libTextId
    call drawStr
    call fastCopy
    
_:  call flushKeys
    rst $10 \ .db applibId
    call appWaitKey
    cp kClear
    jr nz, -_
    ret
    
helloString:
    .db "Hello, world!\nPress [Clear] to exit.", 0
libTextPath:
    .db "/lib/libtext", 0
applibPath:
    .db "/lib/applib", 0