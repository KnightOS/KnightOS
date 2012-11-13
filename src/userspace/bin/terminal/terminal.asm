.nolist
#include "kernel.inc"
#include "macros.inc"
#include "libtext.inc"
#include "applib.inc"
#include "keys.inc"
#include "defines.inc"
#include "terminal.lang"
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
   
_:  call fastCopy
    
    ;applib(getCharacterInput)
    rst $10 \ .db applibId
    call getCharacterInput
    
    or a
    jr z, _ ; Check non-character keys
    push bc
    
        ; Clear area
        push af
            ld e, 2 \ ld l, 8 \ ld bc, $0508 \ call rectAND ; TODO: Make rect routine safe
        pop af
    
        ; Handle characters
        ld de, $0208
        ; libtext(drawChar)
        rst $10 \ .db libTextId
        call drawChar
    
    pop bc
_:  ld a, b
    cp kClear
    ret z
    
    jr --_ ; Loop
    
windowTitle:
    .db lang_windowTitle, 0
libTextPath:
    .db "/lib/libtext", 0
applibPath:
    .db "/lib/applib", 0