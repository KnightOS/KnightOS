.nolist
#include "kernel.inc"
#include "macros.inc"
#include "libtext.inc"
#include "applib.inc"
#include "keys.inc"
#include "defines.inc"
#include "hello.lang"
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
    call getLcdLock
    call getKeypadLock

    call allocScreenBuffer
    
    ; Load dependencies
    kld de, libTextPath
    call loadLibrary
    kld de, applibPath
    call loadLibrary
    
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
    
    ld de, $0219
    kld hl, bootCodeString
    ;libtext(drawStr)
    rst $10 \ .db libTextId
    call drawStr
    
    call getBootCodeVersionString
    ;libtext(drawStr)
    rst $10 \ .db libTextId
    call drawStr
    call free
    
_:  call fastCopy
    call flushKeys
    rst $10 \ .db applibId
    call appWaitKey
    cp kClear
    jr nz, -_
    ret
    
helloString:
    .db lang_helloString, 0
windowTitle:
    .db lang_windowTitle, 0
bootCodeString:
    .db "Boot Code Version: \n", 0
libTextPath:
    .db "/lib/libtext", 0
applibPath:
    .db "/lib/applib", 0