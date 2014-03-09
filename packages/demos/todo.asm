.nolist
#include "kernel.inc"
#include "todo.lang"
.list
    .db 0, 50
.org 0
start:
    pcall(getLcdLock)
    pcall(getKeypadLock)

    pcall(allocScreenBuffer)
    pcall(clearBuffer)
    
    ld b, 0
    ld de, 0
    kld(hl, todoString)
    pcall(drawStr)
    pcall(fastCopy)
    
    pcall(flushKeys)
    pcall(waitKey)
    ret
todoString:
    .db lang_todo, 0
