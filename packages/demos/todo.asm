.nolist
#include "kernel.inc"
#include "todo.lang"
.list
    .db 0, 50
.org 0
start:
    call getLcdLock
    call getKeypadLock

    call allocScreenBuffer
    call clearBuffer
    
    ld b, 0
    ld de, 0
    kld(hl, todoString)
    call drawStr
    call fastCopy
    
    call flushKeys
    call waitKey
    ret
todoString:
    .db lang_todo, 0