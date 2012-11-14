.nolist
#include "kernel.inc"
#include "macros.inc"
#include "libtext.inc"
#include "applib.inc"
#include "keys.inc"
#include "defines.inc"
#include "terminal.lang"
bufferSize .equ 512 ; For reading input
leftMargin .equ 2
commandChar .equ '$'
cursorChar .equ '_'
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
    rst $10 \ .db applibId \ call drawWindow
    
    ; Set default character set
    ld a, charSetLowercase
    ;applib(setCharSet)
    rst $10 \ .db applibId \ call setCharSet
    
    call flushKeys
    
    ld bc, bufferSize
    call malloc
    
    ld de, leftMargin << 8 | 8
idleLoop: ; Run when there is no attached program
    ; Draw out the command character
    ld a, commandChar
    kcall term_printChar
    kcall term_advanceCursor
    kcall term_readString
    jr idleLoop
    
#include "routines.asm"
   
windowTitle:
    .db lang_windowTitle, 0
libTextPath:
    .db "/lib/libtext", 0
applibPath:
    .db "/lib/applib", 0