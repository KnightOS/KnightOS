.nolist
#include "kernel.inc"
#include "macros.inc"
#include "libtext.inc"
#include "applib.inc"
#include "keys.inc"
#include "defines.inc"
#include "terminal.lang"
bufferSize .equ 256
.list
; Header
    .db 0
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
    
    kld hl, windowTitle
    xor a
    ;applib(drawWindow)
    rst $10 \ .db applibId
    call drawWindow
    
    call flushKeys
    
    ld bc, bufferSize
    call malloc
   
idleLoop: ; when there is no attached program
    
    
windowTitle:
    .db lang_windowTitle, 0
libTextPath:
    .db "/lib/libtext", 0
applibPath:
    .db "/lib/applib", 0