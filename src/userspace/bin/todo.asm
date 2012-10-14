.nolist
#include "kernel.inc"
#include "macros.inc"
#include "libtext.inc"
#include "defines.inc"
.list
; Header
    .db 0
    .db 50 ; Stack size
; Program
.org 0
start:
    call getLcdLock
    call getKeypadLock

    call allocScreenBuffer
    call clearBuffer
    
    kld de, libTextPath
    call loadLibrary
    
    ld b, 0
    ld de, 0
    kld hl, todoString
    ;libtext(drawStr)
    rst $10
    .db libTextId
    call drawStr
    call fastCopy
    
    call flushKeys
    call waitKey
    ret
todoString:
    .db "Cette fonctionnalité n'a pas \n encore été implémentée.\nAppuyez sur une touche pour quitter.", 0
libTextPath:
    .db "/lib/libtext", 0