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
    pcall(getLcdLock)
    pcall(getKeypadLock)

    pcall(allocScreenBuffer)
    
    ; Load dependencies
    kld(de, applibPath)
    pcall(loadLibrary)
    
redraw:
    kld(hl, windowTitle)
    xor a
    applib(drawWindow)
    
    ld b, 2
    ld de, 0x0208
    kld(hl, helloString)
    pcall(drawStr)
    
    ld de, 0x0219
    kld(hl, bootCodeString)
    pcall(drawStr)
    
    pcall(getBootCodeVersionString)
    pcall(drawStr)
    pcall(free)
    
_:  pcall(fastCopy)
    pcall(flushKeys)
    applib(appWaitKey)
    cp kMode
    jr z, testMessage
    cp kClear
    ret z
    jr -_

testMessage:
    kld(hl, messageText)
    kld(de, options)
    xor a
    ld b, a
    applib(showMessage)
    or a ; cp 0
    jr nz, _
    kld(hl, option1)
    kld(de, dismiss)
    xor a
    applib(showMessage)
    jr redraw
_:  kld(hl, option2)
    kld(de, dismiss)
    xor a
    applib(showMessage)
    jr redraw
    
helloString:
    .db lang_helloString, 0
windowTitle:
    .db lang_windowTitle, 0
bootCodeString:
    .db "Boot Code Version: \n", 0
applibPath:
    .db "/lib/applib", 0
messageText:
    .db "Hello, world!\nThis is a test", 0
options:
    .db 2
option1:
    .db "Option 1", 0
option2:
    .db "Option 2", 0
dismiss:
    .db 1
    .db "Dismiss", 0
