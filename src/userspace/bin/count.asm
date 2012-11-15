.nolist
#include "kernel.inc"
#include "macros.inc"
#include "libtext.inc"
#include "applib.inc"
#include "keys.inc"
#include "defines.inc"
#include "count.lang"
.list
; Header
    .db %00000010
    .db 50 ; Stack size
; Program
.org 0
; KnightOS Header
    jr start
    .db 'K'
    .db lang_description, 0
    .db %00000010

start:
    call getLcdLock
    call getKeypadLock

    call allocScreenBuffer
    
    ; Load dependencies
    kld de, libTextPath
    call loadLibrary
    kld de, applibPath
    call loadLibrary
    ld b, 0
_:  push bc
        kld hl, windowTitle
        xor a
        ;applib(drawWindow)
        rst $10 \ .db applibId
        call drawWindow
        
        ld b, 2
        ld de, $0208
        kld hl, helloString
        ;libtext(drawStr)
        rst $10 \ .db libTextId
        call drawStr
    pop bc
    
    ld a, b \ inc b
    ld de, $0210
    ;libtext(drawHexA)
    rst $10 \ .db libTextId
    call drawHexA
    
    call fastCopy
    rst $10 \ .db applibId
    call appGetKey
    
    cp kClear
    jr nz, -_
    ret
    
helloString:
    .db lang_hello, 0
windowTitle:
    .db lang_windowTitle, 0
libTextPath:
    .db "/lib/libtext", 0
applibPath:
    .db "/lib/applib", 0