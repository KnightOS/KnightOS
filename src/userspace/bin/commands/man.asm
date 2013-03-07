.nolist
#include "kernel.inc"
#include "macros.inc"
#include "stdio.inc"
#include "libtext.inc"
maxPages .equ 16
.list
; Header
    .db 0
    .db 10 ; Stack size
; Program
.org 0

start:
    push hl
        kld(hl, manDirectory)
        ld bc, 128
        call malloc
        push ix \ pop de
        call stringCopy ; Copy man directory to allocated memory
        call stringLength
        or a \ adc hl, bc
        ex de, hl
        pop hl \ push hl
        dec de
        call stringCopy ; Copy command to allocated memory
        push ix \ pop de
        call fileExists
        jr z, _
        ; File doesn't exist
        kld(hl, commandNotFoundText)
        stdio(printString)
    pop hl
    stdio(printLine)
    call free
    ret
    
_:  inc sp \ inc sp ; Discard this
    call free
    ; Display manual entry
    stdio(clearTerminal)
    ; Load man file into memory
    call openFileRead
    push de
        call getStreamInfo
    pop de
    push bc
        ; Increase the buffer size, we need room to add some zeroes in during formatting
        ld a, maxPages \ add a, c \ ld c, a
        jr nc, _
            inc b
_:      call malloc
        call streamReadToEnd
        call closeStream
    ; Modify the file in memory to add pagination
    pop hl
    ld b, l \ ld c, h ; Load the file size in CB
    call memSeekToStart
    ; We need libtext to do some calculations for displaying text in the terminal
    kld(de, libTextPath)
    call loadLibrary
    ; We calculate the space required on the terminal and insert zeroes for pagination.
    ; D, E is X, Y for the cursor location (starts at 2, 8)
    ld de, 2 << 8 | 8
formatLoop:
        ld a, (ix)
        cp '\n'
        jr z, format_handleNewline
        ; Handle other characters with libtext
        ;libtext(measureChar)
        rst $10 \ .db libTextId \ call measureChar
        add a, d \ ld d, a
        cp 90
         ; We let the \n handler deal with advancing past the edge of the screen
        jr nc, format_handleNewLine
formatLoop_end:
        ; Check if we've gone off the bottom of the screen yet
        ld a, e \ add a, 5 \ cp 57
        jr c, _
        ; We have gone off the bottom, let's deal with it
        xor a \ ld (ix), a ; TODO: Shift memory over a bit, instead of overwriting this character
_:  inc ix
    djnz formatLoop
    dec c
    jr nc, formatLoop
    jr format_done
format_handleNewline:
    ld a, e \ add a, 6 \ ld e, a
    ld d, 2
    jr formatLoop_end
format_done:
    ld (ix), 0
    ; Display file
    call memSeekToStart
    push ix \ pop hl
    stdio(printString)
    ; TODO: Paging
    call flushKeys
    call waitKey
    call free
    ret

manDirectory: ; TODO: Try loading these from config files
    .db "/etc/man/", 0
commandNotFoundText:
    .db "No manual entry for ", 0
libTextPath:
    .db "/lib/libtext", 0