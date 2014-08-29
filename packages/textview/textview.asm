#include "kernel.inc"
#include "corelib.inc"
    .db "KEXC"
    .db KEXC_ENTRY_POINT
    .dw start
    .db KEXC_STACK_SIZE
    .dw 50
    .db KEXC_KERNEL_VER
    .db 0, 6
    .db KEXC_NAME
    .dw name
    .db KEXC_HEADER_END
name:
    .db "Text Viewer", 0

start:
    ; End program if no arguments are passed (A is 0)
    ; TODO: Handle launched w/o args
    or a
    ret z

    push de                     ; Save file path
        pcall(getLcdLock)
        pcall(getKeypadLock)

        kld(de, corelibPath)
        pcall(loadLibrary)

        pcall(allocScreenBuffer)
    pop hl

    ; Draw Window
    xor a                       ; Set flags to draw castle and thread icons
    corelib(drawWindow)

    ; Open file or end program if it fails
    ex de, hl
    pcall(openFileRead)
    ret nz

    ; For testing purposes, we'll load the entire file into RAM
    pcall(getStreamInfo)
    ; Allocate file size+2 bytes. Gives starting point in IX
    ; End program if memory allocation failed
    inc bc
    kld((fileLength), bc)
    inc bc
    pcall(malloc)        
    ret nz            
    ld (ix), 0                  ; Prepend file with 0
    inc ix
    kld((fileStart), ix)
    pcall(streamReadToEnd)
    pcall(closeStream)

    ; Put 0 at end of file in RAM
    pcall(memSeekToEnd)    
    ld (ix), 0
    pcall(memSeekToStart)

    ; Count the number of wrapped lines of text in the file
    ; length = 0
    ; lines = 1
    ; for char in file:
    ;   if char == 0:
    ;       break
    ;   elif char == \n:
    ;       lines = lines +1
    ;       length = 0
    ;   length = length + measureChar
    ;       if length > width
    ;           lines = lines + 1
    ;           length = measureChar
    ld b, 0                     ; B = length
    ld de, 1                    ; DE = lines
countLoop:
    inc ix
    ld a, (ix)
    or a
    jr z, .exit
    cp '\n'
    jr nz, _
    inc de
    ld b, 0
    jr countLoop
_:  pcall(measureChar)
    ld c, a
    add b
    ld b, a
    cp 93
    jr c, countLoop
    inc de
    ld b, c
    jr countLoop
.exit: 
    dec de

    ; If total lines <= 8
    ; do not draw scroll bar
    ld bc, 8
    pcall(cpBCDE)
    jr nc, ++_

    ; Length of scrollbar
    ; 50 pixels * 8 lines / total lines
    ld a, 0x01
    ld c, 0x90
    pcall(divACByDE)
    ld d, a
    ld e, c
    ; If result is < 1, set bar length to 1 pixel
    or c
    jr nz, _
    ld de, 1
    ld a, e
_:  kld((barLength), a)
_:

    ; Go back to beginning of file
    pcall(memSeekToStart)
    inc ix
    
    push ix \ pop hl
    ld de, 0x0208               ; Set drawing coordinates to 2,8

drawLoop:
    ; Draw Text
    ld a, 2                     ; Set left margin to 2
    ld bc, 95 << 8 | 56         ; Set limits on text area
    pcall(wrapStr)

    ; Don't draw scrollbar if bar length is 0
    kld(a, (barLength))
    ld b, a
    or a
    jr z, ++_
    ; Scroll bar position
    ; 50 pixels * (text pointer - start of file) / (length of file) - length of bar
    push de
    push hl
    push ix
        kld(bc, (fileStart))
        sbc hl, bc
        ex hl, de
        ld a, 50
        pcall(mul16by8)
        push hl \ pop ix
        ld c, a
        xor a
        kld(de, (fileLength))
        pcall(div32by16)
        ; Why does it give me ValueTruncated when I load directly into B?
        kld(a, (barLength))
        ld b, a
        ld a, ixl
        sub a, b
        ; Set position to 0 if value is negative
        jr nc, _
        xor a
_:      ld c, a
    pop ix
    pop hl
    pop de
    
    
    ; Draw Scrollbar
    kcall(drawScrollBar)
_:  pcall(fastCopy)

    ; Hacky workaround
    ; Increment string pointer if its pointing at a newline char
    ; and go back to the loop
    ld a, (hl)
    cp '\n'
    jr nz, _
    inc hl

_:  ; Wait for key press and interpret it
    pcall(flushKeys)
    corelib(appWaitKey)

    cp kMODE
    ret z
    cp kUp
    jr z, .up
    cp kDown
    jr z, .down
    cp kEnter
    jr z, .down
    jr --_

.up:
    push hl
    push de
        ; Clear text area
        push iy \ pop hl
        ld bc, 12 * 8
        add hl, bc              ; Start at line 8
        push hl \ pop de
        inc de                  ; Set DE to second byte of first row of text
        xor a
        ld (hl), a              ; Clear first byte of row
        ld bc, 48 * 12 - 1      ; Set counter for 48 lines of pixels
        ldir

        ; Redraw window sides
        ld a, 0
        ld l, 8                 ; Set starting coordinates to 0,8
        ld c, 48                ; Set height to 48 pixels
        pcall(drawVLine)    
        ld a, 95                ; Set starting coordinates to 95,8
        pcall(drawVLine)    
    pop de
    pop hl
    ld bc, 9 << 8 | 92          ; Set width of text area and number of lines to scroll back
    kcall(scrollBack)
    ld de, 0x0208               ; Set drawing coordinates to 2,8

    kjp(drawLoop)

.down:
    ; If byte at hl is 0 (end of file), then do nothing
    ld a, (hl)
    or a
    jr z, -_

    push hl
    push de
        ; Shift text up by one row
        push iy \ pop hl        ; Load screen buffer address into HL
        ld bc, 12 * 8           ; 96 pixels / 8 bits = 12 bytes per horizontal line
        add hl, bc        
        push hl \ pop de        ; Set DE to beginning of line 8
        ld bc, 12 * 6
        add hl, bc              ; Set HL to 6 lines after (1 row of text)
        ;ld bc, (96 * 48) / 8   ; Set counter for 48 lines of screen
                                ; 64 - 8 (header) - 8 (menu bar) = 48
        ld bc, 0x0240
        ldir

        ; Clear last row
        push iy \ pop hl
        ; ASSEMBLER BUG
        ;ld bc, 12 * (64 - 6 - 8)
        ; is not the same as...
        ld bc, 0x0258           ; 12 bytes per line * (64 - 6 - 8) pixels
        add hl, bc
        push hl \ pop de
        inc de                  ; Set DE to second byte of last row of text
        xor a
        ld (hl), a              ; Set first byte of row to zero
        ld bc, 6 * 12 - 1       ; Set counter for 6 rows of pixels
        ldir

        ; Redraw window sides
        ld a, 0
        ld l, 50                ; Set starting coordinates to 0,50
        ld c, 6                 ; Set height to 6
        pcall(drawVLine)    
        ld a, 95                ; Set starting coordinates to 95,50
        pcall(drawVLine)    
    pop de
    pop hl

    ; Shift drawing coordinates up by 6 pixels (1 row of text)
    ld a, -6
    add a, e
    ld e, a
    ld d, 2                     ; Set X coordinate to 2

    kjp(drawLoop)

; scrollBack [text]
;  Moves backwards B lines, taking into account text wrapping, and returns pointer. String must be prepended with 0.
; Inputs:
;  B: Number of lines to go back
;  C: Width of text area
;  HL: String pointer (start of current line)
; Outputs:
;  HL: String pointer (start of previous line)
scrollBack:
    push af
    push bc
    push de
    push ix
    push iy
.lineloop:
        push hl                 ; Store original string pointer
            push hl \ pop ix    ; Copy pointer to IX
            ld hl, 0            ; HL = pixel length counter
            ld de, 0            ; Used for math and things
            ld iy, 0            ; Character counter
; Find length (in pixels) of previous line in file (from string pointer to previous newline or 0)
; Divide length of line by width of screen
; take remainder and count backwards from string pointer (count >= remainder)
; if remainder is 0, count back width of screen
; return new string pointer
.lenloop:
            ; Move backwards one char
            dec ix
            ld a, (ix)
            ; Break if char is newline and this isn't the first char
            ; Should also do this for carriage return
            cp '\n'
            jr nz, _
            ld a, iyh
            or iyl
            jr nz, .lend
            ld a, (ix)
_:          ; Break if char is 0
            or a
            jr z, .lend
            ; Add length to pixel counter
            pcall(measureChar)
            ld e, a
            add hl, de
            ; Increment character counter
            ; IY is kinda unecessary. You can also subtract IX from the original pointer
            inc iy
            ; Repeat
            jr .lenloop
.lend:
            ; If pixel length == 0
            ;   and character length > 0
            ;       subtract char length from original string pointer
            ;   and character length == 0
            ;       return original string pointer
            ld a, h
            or l
            jr nz, ++_
            ld a, iyh
            or iyl
            jr z, _
            push iy \ pop de
        pop hl
        sbc hl, de
        jr .end
_:      pop hl
        jr .end
_:          ; Divide length of line by width of screen
            pcall(divHLByC)   
            ; If remainder is 0 (each row is exactly the screen width),
            ; then count back width of screen
            or a
            jr nz, _
            ld a, c
            ; If HL < B, it can be used to speed things up
_:      pop hl                  ; copy original string pointer back into HL
        ld d, a                 ; D = remainder
        ld e, 0                 ; E = counter
.remloop:   
        ; Break if counter >= remainder
        cp e
        jr c, .end
        jr z, .end
        ; Move backwards one char
        dec hl
        ld a, (hl)
        ; Add length to counter
        pcall(measureChar)
        add a, e
        ld e, a
        ; Repeat
        ld a, d
        jr .remloop
.end:   ; Decrement line counter (B) and repeat if its 0
        djnz .lineloop
    pop iy
    pop ix
    pop de
    pop bc
    pop af
    ret

; drawScrollBar
; Inputs:
;  B: Length of bar in pixels
;  C: Position of top of bar (0-49)
;  IY: Screen Buffer
drawScrollBar:
    push af
    push hl
        push bc
            ; Draw left side
            ld a, 94
            ld l, 7
            ld c, 49
            pcall(drawVLine)
            ; Clear right side
            ld a, 95
            kcall(drawVLineAND)
        ; Draw bar
        pop bc
        ; Set Y
        ld a, 7
        add c
        ld l, a
        ; Set X
        ld a, 95
        ; Set length
        ld c, b
        pcall(drawVLine)
    pop hl
    pop af
    ret

; drawVLineAND [Display]
;  Draws a vertical line on the screen buffer using AND (turns pixels OFF) logic.
;  Does clipping.
; Inputs:
;  IY: screen buffer
;  A, L: X, Y
;  C: height
drawVLineAND:
    push af \ push bc \ push de \ push hl
        ld b, a
        ld a, 63
        sub l
        cp c
        jr c, .exitEarly
        ld a, b
        pcall(getPixel)
        cpl
        ld b, a
        ld a, h
        or l
        jr z, .exitEarly
        ld a, b
        ld b, c
        ld c, a
        ld de, 12
.vline_loop:
        ld a, c
        and (hl)
        ld (hl), a
        add hl, de
        djnz .vline_loop
.exitEarly:
    pop hl \ pop de \ pop bc \ pop af
    ret

fileStart:
    .dw 0
fileLength:
    .dw 0
barLength:
    .db 0

corelibPath:
    .db "/lib/core", 0
