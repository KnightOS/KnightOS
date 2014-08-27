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
    inc bc
    pcall(malloc)        
    ret nz            
    ld (ix), 0                  ; Prepend file with 0
    inc ix
    pcall(streamReadToEnd)
    pcall(closeStream)

    ; Put 0 at end of file in RAM
    pcall(memSeekToEnd)    
    ld (ix), 0
    pcall(memSeekToStart)
    inc ix
    
    push ix \ pop hl
    ld de, 0x0208               ; Set drawing coordinates to 2,8

drawLoop:
    ld a, 2                     ; Set left margin to 2
    ld bc, 95 << 8 | 56         ; Set limits on text area
    pcall(wrapStr)
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

    jr drawLoop

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
            kcall(xmeasureChar)
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
        kcall(xmeasureChar)
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

;; measureChar [Text]
;;  Measures the width of a character in pixels.
;; Inputs:
;;  A: Character to measure
;; Outputs:
;;  A: Width of character
;; Notes:
;;  The height of each character is always 5 pixels. The width also often includes a column of empty pixels on the right (exceptions include '_
xmeasureChar:
    push hl
    push de
        ld de, 6
        sub 0x20
        jr c, _         ; Return 0 if character < 0x20
        pcall(mul16By8)
        ex de, hl
        kld(hl, xkernel_font)
        add hl, de
        ld a, (hl)
.exit:
    pop de
    pop hl
    ret 

_:  xor a
    jr .exit

corelibPath:
    .db "/lib/core", 0

; .db width (in pixels)
; .db 0b00000000
; .db 0b00000000
; .db 0b00000000
; .db 0b00000000
; .db 0b00000000

xkernel_font:
    ; [space]
    .db 1
    .db 0b00000000
    .db 0b00000000
    .db 0b00000000
    .db 0b00000000
    .db 0b00000000

    ; !
    .db 2
    .db 0b10000000
    .db 0b10000000
    .db 0b10000000
    .db 0b00000000
    .db 0b10000000

    ; "
    .db 4
    .db 0b10100000
    .db 0b10100000
    .db 0b00000000
    .db 0b00000000
    .db 0b00000000

    ; #
    .db 6
    .db 0b01010000
    .db 0b11111000
    .db 0b01010000
    .db 0b11111000
    .db 0b01010000

    ; $
    .db 4
    .db 0b01000000
    .db 0b01100000
    .db 0b11000000
    .db 0b01100000
    .db 0b11000000

    ; %
    .db 4
    .db 0b10100000
    .db 0b00100000
    .db 0b01000000
    .db 0b10000000
    .db 0b10100000

    ; &
    .db 5
    .db 0b00100000
    .db 0b01010000
    .db 0b01100000
    .db 0b10100000
    .db 0b01010000

    ; '
    .db 2
    .db 0b10000000
    .db 0b10000000
    .db 0b00000000
    .db 0b00000000
    .db 0b00000000

    ; (
    .db 3
    .db 0b01000000
    .db 0b10000000
    .db 0b10000000
    .db 0b10000000
    .db 0b01000000

    ; )
    .db 3
    .db 0b10000000
    .db 0b01000000
    .db 0b01000000
    .db 0b01000000
    .db 0b10000000

    ; *
    .db 4
    .db 0b01000000
    .db 0b11100000
    .db 0b01000000
    .db 0b10100000
    .db 0b00000000

    ; +
    .db 4
    .db 0b00000000
    .db 0b01000000
    .db 0b11100000
    .db 0b01000000
    .db 0b00000000
    
    ; ,
    .db 3
    .db 0b00000000
    .db 0b00000000
    .db 0b01000000
    .db 0b01000000
    .db 0b10000000

    ; -
    .db 4
    .db 0b00000000
    .db 0b00000000
    .db 0b11100000
    .db 0b00000000
    .db 0b00000000

    ; .
    .db 2
    .db 0b00000000
    .db 0b00000000
    .db 0b00000000
    .db 0b00000000
    .db 0b10000000

    ; /
    .db 4
    .db 0b00100000
    .db 0b00100000
    .db 0b01000000
    .db 0b10000000
    .db 0b10000000

    ; 0
    .db 4
    .db 0b01000000
    .db 0b10100000
    .db 0b10100000
    .db 0b10100000
    .db 0b01000000

    ; 1
    .db 4
    .db 0b01000000
    .db 0b11000000
    .db 0b01000000
    .db 0b01000000
    .db 0b11100000

    ; 2
    .db 4
    .db 0b11000000
    .db 0b00100000
    .db 0b01000000
    .db 0b10000000
    .db 0b11100000

    ; 3
    .db 4
    .db 0b11000000
    .db 0b00100000
    .db 0b01000000
    .db 0b00100000
    .db 0b11000000

    ; 4
    .db 4
    .db 0b10100000
    .db 0b10100000
    .db 0b11100000
    .db 0b00100000
    .db 0b00100000

    ; 5
    .db 4
    .db 0b11100000
    .db 0b10000000
    .db 0b11000000
    .db 0b00100000
    .db 0b11000000

    ; 6
    .db 4
    .db 0b01100000
    .db 0b10000000
    .db 0b11100000
    .db 0b10100000
    .db 0b11100000

    ; 7
    .db 4
    .db 0b11100000
    .db 0b00100000
    .db 0b01000000
    .db 0b10000000
    .db 0b10000000

    ; 8
    .db 4
    .db 0b11100000
    .db 0b10100000
    .db 0b11100000
    .db 0b10100000
    .db 0b11100000

    ; 9
    .db 4
    .db 0b11100000
    .db 0b10100000
    .db 0b11100000
    .db 0b00100000
    .db 0b11000000

    ; :
    .db 2
    .db 0b00000000
    .db 0b10000000
    .db 0b00000000
    .db 0b10000000
    .db 0b00000000

    ; ;
    .db 3
    .db 0b00000000
    .db 0b01000000
    .db 0b00000000
    .db 0b01000000
    .db 0b10000000

    ; <
    .db 4
    .db 0b00100000
    .db 0b01000000
    .db 0b10000000
    .db 0b01000000
    .db 0b00100000

    ; =
    .db 4
    .db 0b00000000
    .db 0b11100000
    .db 0b00000000
    .db 0b11100000
    .db 0b00000000

    ; >
    .db 4
    .db 0b10000000
    .db 0b01000000
    .db 0b00100000
    .db 0b01000000
    .db 0b10000000

    ;?
    .db 4
    .db 0b11000000
    .db 0b00100000
    .db 0b01000000
    .db 0b00000000
    .db 0b01000000
    
    ; @
    .db 5
    .db 0b01110000
    .db 0b10010000
    .db 0b10110000
    .db 0b10000000
    .db 0b01110000

    ; A
    .db 4
    .db 0b01000000
    .db 0b10100000
    .db 0b11100000
    .db 0b10100000
    .db 0b10100000

    ; B
    .db 4
    .db 0b11000000
    .db 0b10100000
    .db 0b11000000
    .db 0b10100000
    .db 0b11000000

    ; C
    .db 4
    .db 0b01100000
    .db 0b10000000
    .db 0b10000000
    .db 0b10000000
    .db 0b01100000

    ; D
    .db 4
    .db 0b11000000
    .db 0b10100000
    .db 0b10100000
    .db 0b10100000
    .db 0b11000000

    ; E
    .db 4
    .db 0b11100000
    .db 0b10000000
    .db 0b11000000
    .db 0b10000000
    .db 0b11100000

    ; F
    .db 4
    .db 0b11100000
    .db 0b10000000
    .db 0b11000000
    .db 0b10000000
    .db 0b10000000

    ; G
    .db 4
    .db 0b01100000
    .db 0b10000000
    .db 0b10100000
    .db 0b10100000
    .db 0b01100000

    ; H
    .db 4
    .db 0b10100000
    .db 0b10100000
    .db 0b11100000
    .db 0b10100000
    .db 0b10100000
    
    ; I
    .db 4
    .db 0b11100000
    .db 0b01000000
    .db 0b01000000
    .db 0b01000000
    .db 0b11100000

    ; J
    .db 4
    .db 0b11100000
    .db 0b01000000
    .db 0b01000000
    .db 0b01000000
    .db 0b10000000

    ; K
    .db 4
    .db 0b10100000
    .db 0b10100000
    .db 0b11000000
    .db 0b10100000
    .db 0b10100000
    
    ; L
    .db 4
    .db 0b10000000
    .db 0b10000000
    .db 0b10000000
    .db 0b10000000
    .db 0b11100000

    ; M
    .db 4
    .db 0b10100000
    .db 0b11100000
    .db 0b11100000
    .db 0b10100000
    .db 0b10100000

    ; N
    .db 4
    .db 0b11000000
    .db 0b10100000
    .db 0b10100000
    .db 0b10100000
    .db 0b10100000

    ; O
    .db 4
    .db 0b11100000
    .db 0b10100000
    .db 0b10100000
    .db 0b10100000
    .db 0b11100000

    ; P
    .db 4
    .db 0b11000000
    .db 0b10100000
    .db 0b11000000
    .db 0b10000000
    .db 0b10000000

    ; Q
    .db 4
    .db 0b01000000
    .db 0b10100000
    .db 0b10100000
    .db 0b11100000
    .db 0b01100000

    ; R
    .db 4
    .db 0b11000000
    .db 0b10100000
    .db 0b11000000
    .db 0b10100000
    .db 0b10100000

    ; S
    .db 4
    .db 0b01100000
    .db 0b10000000
    .db 0b01000000
    .db 0b00100000
    .db 0b11000000

    ; T
    .db 4
    .db 0b11100000
    .db 0b01000000
    .db 0b01000000
    .db 0b01000000
    .db 0b01000000

    ; U
    .db 4
    .db 0b10100000
    .db 0b10100000
    .db 0b10100000
    .db 0b10100000
    .db 0b11100000
    
    ; V
    .db 4
    .db 0b10100000
    .db 0b10100000
    .db 0b10100000
    .db 0b10100000
    .db 0b01000000

    ; W
    .db 4
    .db 0b10100000
    .db 0b10100000
    .db 0b11100000
    .db 0b11100000
    .db 0b10100000

    ; X
    .db 4
    .db 0b10100000
    .db 0b10100000
    .db 0b01000000
    .db 0b10100000
    .db 0b10100000

    ; Y
    .db 4
    .db 0b10100000
    .db 0b10100000
    .db 0b01000000
    .db 0b01000000
    .db 0b01000000

    ; Z
    .db 4
    .db 0b11100000
    .db 0b00100000
    .db 0b01000000
    .db 0b10000000
    .db 0b11100000

    ; [
    .db 3
    .db 0b11000000
    .db 0b10000000
    .db 0b10000000
    .db 0b10000000
    .db 0b11000000

    ; \
    .db 4
    .db 0b10000000
    .db 0b10000000
    .db 0b01000000
    .db 0b00100000
    .db 0b00100000

    ; ]
    .db 3
    .db 0b11000000
    .db 0b01000000
    .db 0b01000000
    .db 0b01000000
    .db 0b11000000

    ; ^
    .db 4
    .db 0b01000000
    .db 0b10100000
    .db 0b00000000
    .db 0b00000000
    .db 0b00000000

    ; _
    .db 4
    .db 0b00000000
    .db 0b00000000
    .db 0b00000000
    .db 0b00000000
    .db 0b11110000

    ; `
    .db 3
    .db 0b10000000
    .db 0b01000000
    .db 0b00000000
    .db 0b00000000
    .db 0b00000000

    ; a
    .db 4
    .db 0b00000000
    .db 0b01100000
    .db 0b10100000
    .db 0b10100000
    .db 0b01100000

    ; b
    .db 4
    .db 0b10000000
    .db 0b11000000
    .db 0b10100000
    .db 0b10100000
    .db 0b11000000

    ; c
    .db 4
    .db 0b00000000
    .db 0b01100000
    .db 0b10000000
    .db 0b10000000
    .db 0b01100000

    ; d
    .db 4
    .db 0b00100000
    .db 0b01100000
    .db 0b10100000
    .db 0b10100000
    .db 0b01100000

    ; e
    .db 4
    .db 0b00000000
    .db 0b01000000
    .db 0b10100000
    .db 0b11000000
    .db 0b01100000

    ; f
    .db 4
    .db 0b00100000
    .db 0b01000000
    .db 0b11100000
    .db 0b01000000
    .db 0b01000000

    ; g
    .db 4
    .db 0b01100000
    .db 0b10100000
    .db 0b01100000
    .db 0b00100000
    .db 0b11000000

    ; h
    .db 4
    .db 0b10000000
    .db 0b11000000
    .db 0b10100000
    .db 0b10100000
    .db 0b10100000

    ; i
    .db 2
    .db 0b10000000
    .db 0b00000000
    .db 0b10000000
    .db 0b10000000
    .db 0b10000000

    ; j
    .db 4
    .db 0b00100000
    .db 0b00000000
    .db 0b00100000
    .db 0b10100000
    .db 0b01000000

    ; k
    .db 4
    .db 0b10000000
    .db 0b10100000
    .db 0b11000000
    .db 0b10100000
    .db 0b10100000

    ; l
    .db 3
    .db 0b11000000
    .db 0b01000000
    .db 0b01000000
    .db 0b01000000
    .db 0b01000000

    ; m
    .db 6
    .db 0b00000000
    .db 0b11010000
    .db 0b10101000
    .db 0b10101000
    .db 0b10001000

    ; n
    .db 4
    .db 0b00000000
    .db 0b11000000
    .db 0b10100000
    .db 0b10100000
    .db 0b10100000

    ; o
    .db 4
    .db 0b00000000
    .db 0b01000000
    .db 0b10100000
    .db 0b10100000
    .db 0b01000000

    ; p
    .db 4
    .db 0b00000000
    .db 0b11000000
    .db 0b10100000
    .db 0b11000000
    .db 0b10000000

    ; q
    .db 4
    .db 0b00000000
    .db 0b01100000
    .db 0b10100000
    .db 0b01100000
    .db 0b00100000
    
    ; r
    .db 4
    .db 0b00000000
    .db 0b10100000
    .db 0b11000000
    .db 0b10000000
    .db 0b10000000

    ; s
    .db 3
    .db 0b00000000
    .db 0b11000000
    .db 0b10000000
    .db 0b01000000
    .db 0b11000000
    
    ; t
    .db 3
    .db 0b10000000
    .db 0b11000000
    .db 0b10000000
    .db 0b10000000
    .db 0b01000000

    ; u
    .db 4
    .db 0b00000000
    .db 0b10100000
    .db 0b10100000
    .db 0b10100000
    .db 0b11100000

    ; v
    .db 4
    .db 0b00000000
    .db 0b10100000
    .db 0b10100000
    .db 0b10100000
    .db 0b01000000

    ; w
    .db 6
    .db 0b00000000
    .db 0b10001000
    .db 0b10101000
    .db 0b10101000
    .db 0b01010000

    ; x
    .db 4
    .db 0b00000000
    .db 0b10100000
    .db 0b01000000
    .db 0b01000000
    .db 0b10100000

    ; y
    .db 4
    .db 0b00000000
    .db 0b10100000
    .db 0b01100000
    .db 0b00100000
    .db 0b11000000

    ; z
    .db 3
    .db 0b00000000
    .db 0b11000000
    .db 0b01000000
    .db 0b10000000
    .db 0b11000000

    ; {
    .db 4
    .db 0b01100000
    .db 0b01000000
    .db 0b10000000
    .db 0b01000000
    .db 0b01100000
    
    ; |
    .db 2
    .db 0b10000000
    .db 0b10000000
    .db 0b10000000
    .db 0b10000000
    .db 0b10000000

    ; }
    .db 4
    .db 0b11000000
    .db 0b01000000
    .db 0b00100000
    .db 0b01000000
    .db 0b11000000

    ; ~
    .db 5
    .db 0b01010000
    .db 0b10100000
    .db 0b00000000
    .db 0b00000000
    .db 0b00000000
    
    ; (DEL)
    .db 0, 0, 0, 0, 0, 0
    
    ; €
    .db 5
    .db 0b00110000
    .db 0b11000000
    .db 0b01100000
    .db 0b11000000
    .db 0b00110000
    
    ; n/a
    .db 0, 0, 0, 0, 0, 0
    
    ; ‚
    .db 3
    .db 0b00000000
    .db 0b00000000
    .db 0b00000000
    .db 0b01000000
    .db 0b10000000
    
    ; ƒ
    .db 4
    .db 0b00100000
    .db 0b01000000
    .db 0b11100000
    .db 0b01000000
    .db 0b10000000
    
    ; „
    .db 5
    .db 0b00000000
    .db 0b00000000
    .db 0b00000000
    .db 0b01010000
    .db 0b10100000
    
    ; …
    .db 5
    .db 0b00000000
    .db 0b00000000
    .db 0b00000000
    .db 0b00000000
    .db 0b00000000
    
    ; †
    .db 4
    .db 0b01000000
    .db 0b11100000
    .db 0b01000000
    .db 0b01000000
    .db 0b01000000
    
    ; ‡
    .db 4
    .db 0b01000000
    .db 0b11100000
    .db 0b01000000
    .db 0b11100000
    .db 0b01000000
    
    ; ˆ
    .db 4
    .db 0b01000000
    .db 0b10100000
    .db 0b00000000
    .db 0b00000000
    .db 0b00000000
    
    ; ‰
    .db 5
    .db 0b10100000
    .db 0b00100000
    .db 0b01000000
    .db 0b10010000
    .db 0b10100000
    
    ; Š
    .db 4
    .db 0b01100000
    .db 0b10000000
    .db 0b01000000
    .db 0b00100000
    .db 0b11000000
    
    ; ‹
    .db 3
    .db 0b00000000
    .db 0b01000000
    .db 0b10000000
    .db 0b01000000
    .db 0b00000000
    
    ; Œ
    .db 6
    .db 0b01111000
    .db 0b10100000
    .db 0b10110000
    .db 0b10100000
    .db 0b01111000
    
    ; n/a
    .db 0, 0, 0, 0, 0, 0
    
    ; Ž
    .db 5
    .db 0b11100000
    .db 0b00100000
    .db 0b01000000
    .db 0b10000000
    .db 0b11100000
    
    ; n/a
    .db 0, 0, 0, 0, 0, 0
    
    ; n/a
    .db 0, 0, 0, 0, 0, 0
    
    ; ‘
    .db 3
    .db 0b10000000
    .db 0b01000000
    .db 0b00000000
    .db 0b00000000
    .db 0b00000000
    
    ; ’
    .db 3
    .db 0b01000000
    .db 0b10000000
    .db 0b00000000
    .db 0b00000000
    .db 0b00000000
    
    ; “
    .db 5
    .db 0b10100000
    .db 0b01010000
    .db 0b00000000
    .db 0b00000000
    .db 0b00000000
    
    ; ”
    .db 5
    .db 0b01010000
    .db 0b10100000
    .db 0b00000000
    .db 0b00000000
    .db 0b00000000
    
    ; •
    .db 6
    .db 0b01110000
    .db 0b11111000
    .db 0b11111000
    .db 0b11111000
    .db 0b01110000
    
    ; –
    .db 5
    .db 0b00000000
    .db 0b00000000
    .db 0b11110000
    .db 0b00000000
    .db 0b00000000
    
    ; —
    .db 5
    .db 0b00000000
    .db 0b00000000
    .db 0b11111000
    .db 0b00000000
    .db 0b00000000
    
    ; ˜
    .db 5
    .db 0b01010000
    .db 0b10100000
    .db 0b00000000
    .db 0b00000000
    .db 0b00000000

    ; ™
    .db 7
    .db 0b11111100
    .db 0b01011100
    .db 0b01010100
    .db 0b00000000
    .db 0b00000000
    
    ; š
    .db 3
    .db 0b00000000
    .db 0b11000000
    .db 0b10000000
    .db 0b01000000
    .db 0b11000000
    
    ; ›
    .db 3
    .db 0b00000000
    .db 0b10000000
    .db 0b01000000
    .db 0b10000000
    .db 0b00000000
    
    ; œ
    .db 7
    .db 0b00000000
    .db 0b01001000
    .db 0b10110100
    .db 0b10111000
    .db 0b01011100
    
    ; n/a
    .db 0, 0, 0, 0, 0, 0
    
    ; ž
    .db 3
    .db 0b00000000
    .db 0b11000000
    .db 0b01000000
    .db 0b10000000
    .db 0b11000000
    
    ; Ÿ
    .db 4
    .db 0b10100000
    .db 0b00000000
    .db 0b10100000
    .db 0b01000000
    .db 0b01000000
    
    ; n/a
    .db 0, 0, 0, 0, 0, 0
    
    ; ¡
    .db 2
    .db 0b10000000
    .db 0b00000000
    .db 0b10000000
    .db 0b10000000
    .db 0b10000000
    
    ; ¢
    .db 5
    .db 0b00100000
    .db 0b01110000
    .db 0b10100000
    .db 0b01110000
    .db 0b00000000
    
    ; £
    .db 5
    .db 0b00110000
    .db 0b01000000
    .db 0b11100000
    .db 0b01000000
    .db 0b01110000
    
    ; ¤
    .db 5
    .db 0b10001000
    .db 0b01110000
    .db 0b01010000
    .db 0b01110000
    .db 0b10001000
    
    ; ¥
    .db 5
    .db 0b10100000
    .db 0b10100000
    .db 0b01000000
    .db 0b11100000
    .db 0b01000000
    
    ; ¦
    .db 2
    .db 0b10000000
    .db 0b10000000
    .db 0b00000000
    .db 0b10000000
    .db 0b10000000
    
    ; §
    .db 4
    .db 0b01100000
    .db 0b11000000
    .db 0b10100000
    .db 0b01100000
    .db 0b11000000
    
    ; ¨
    .db 4
    .db 0b10100000
    .db 0b00000000
    .db 0b00000000
    .db 0b00000000
    .db 0b00000000
    
    ; ©
    .db 5
    .db 0b01110000
    .db 0b10111000
    .db 0b11001000
    .db 0b10111000
    .db 0b01110000
    
    ; ª
    .db 5
    .db 0b01100000
    .db 0b10100000
    .db 0b01100000
    .db 0b00000000
    .db 0b00000000
    
    ; «
    .db 5
    .db 0b00000000
    .db 0b01010000
    .db 0b10100000
    .db 0b01010000
    .db 0b00000000
    
    ; ¬
    .db 5
    .db 0b00000000
    .db 0b00000000
    .db 0b11100000
    .db 0b00100000
    .db 0b00000000
    
    ; »
    .db 5
    .db 0b00000000
    .db 0b10100000
    .db 0b01010000
    .db 0b10100000
    .db 0b00000000
    
    ; ®
    .db 5
    .db 0b01110000
    .db 0b10111000
    .db 0b11001000
    .db 0b11001000
    .db 0b01110000
    
    ; ¯
    .db 4
    .db 0b11110000
    .db 0b00000000
    .db 0b00000000
    .db 0b00000000
    .db 0b00000000
    
    ; °
    .db 4
    .db 0b01000000
    .db 0b10100000
    .db 0b01000000
    .db 0b00000000
    .db 0b00000000
    
    ; ±
    .db 4
    .db 0b01000000
    .db 0b11100000
    .db 0b01000000
    .db 0b00000000
    .db 0b11100000
    
    ; ²
    .db 3
    .db 0b11000000
    .db 0b01000000
    .db 0b10000000
    .db 0b11000000
    .db 0b00000000
    
    ; ³
    .db 3
    .db 0b11000000
    .db 0b01000000
    .db 0b11000000
    .db 0b00000000
    .db 0b00000000
    
    ; ´
    .db 3
    .db 0b01000000
    .db 0b10000000
    .db 0b00000000
    .db 0b00000000
    .db 0b00000000
    
    ; µ
    .db 4
    .db 0b00000000
    .db 0b10100000
    .db 0b10100000
    .db 0b11100000
    .db 0b10000000
    
    ; ¶
    .db 5
    .db 0b01110000
    .db 0b10110000
    .db 0b10110000
    .db 0b01110000
    .db 0b00110000
    
    ; ·
    .db 2
    .db 0b00000000
    .db 0b10000000
    .db 0b00000000
    .db 0b00000000
    .db 0b00000000
    
    ; ¸
    .db 2
    .db 0b00000000
    .db 0b00000000
    .db 0b00000000
    .db 0b01000000
    .db 0b11000000
    
    ; ¹
    .db 4
    .db 0b11000000
    .db 0b01000000
    .db 0b11100000
    .db 0b00000000
    .db 0b00000000
    
    ; º
    .db 5
    .db 0b01100000
    .db 0b10010000
    .db 0b10010000
    .db 0b01100000
    .db 0b00000000
    
    ; »
    .db 5
    .db 0b00000000
    .db 0b10100000
    .db 0b01010000
    .db 0b10100000
    .db 0b00000000    
    
    ; ¼
    .db 7
    .db 0b10010000
    .db 0b10010000
    .db 0b00101000
    .db 0b01001100
    .db 0b01000100
    
    ; ½
    .db 8
    .db 0b10010000
    .db 0b10010100
    .db 0b00100010
    .db 0b01000100
    .db 0b01000110
    
    ; ¾
    .db 8
    .db 0b11001000
    .db 0b01001000
    .db 0b11010100
    .db 0b00100110
    .db 0b00100010
    
    ; ¿
    .db 4
    .db 0b01000000
    .db 0b00000000
    .db 0b01000000
    .db 0b10000000
    .db 0b01100000
    
    ; À
    .db 4
    .db 0b10000000
    .db 0b01000000
    .db 0b10100000
    .db 0b11100000
    .db 0b10100000
    
    ; Á
    .db 4
    .db 0b00100000
    .db 0b01000000
    .db 0b10100000
    .db 0b11100000
    .db 0b10100000
    
    ; Â
    .db 4
    .db 0b11100000
    .db 0b01000000
    .db 0b10100000
    .db 0b11100000
    .db 0b10100000
    
    ; Ã
    .db 4
    .db 0b01100000
    .db 0b11000000
    .db 0b10100000
    .db 0b11100000
    .db 0b10100000
    
    ; Ä
    .db 4
    .db 0b10100000
    .db 0b01000000
    .db 0b10100000
    .db 0b11100000
    .db 0b10100000
    
    ; Å
    .db 4
    .db 0b01000000
    .db 0b01000000
    .db 0b10100000
    .db 0b11100000
    .db 0b10100000
    
    ; Æ
    .db 6
    .db 0b01111000
    .db 0b10100000
    .db 0b11110000
    .db 0b10100000
    .db 0b10111000
    
    ; Ç
    .db 4
    .db 0b01100000
    .db 0b10000000
    .db 0b10000000
    .db 0b01100000
    .db 0b11000000
    
    ; È
    .db 4
    .db 0b11100000
    .db 0b10000000
    .db 0b11000000
    .db 0b10000000
    .db 0b11100000
    
    ; É
    .db 4
    .db 0b11100000
    .db 0b10000000
    .db 0b11000000
    .db 0b10000000
    .db 0b11100000
    
    ; Ê
    .db 4
    .db 0b11100000
    .db 0b10000000
    .db 0b11000000
    .db 0b10000000
    .db 0b11100000
    
    ; Ë
    .db 4
    .db 0b11100000
    .db 0b10000000
    .db 0b11000000
    .db 0b10000000
    .db 0b11100000
    
    ; Ì
    .db 4
    .db 0b10000000
    .db 0b01000000
    .db 0b11100000
    .db 0b01000000
    .db 0b11100000
    
    ; Í
    .db 4
    .db 0b00100000
    .db 0b01000000
    .db 0b11100000
    .db 0b01000000
    .db 0b11100000
    
    ; Î
    .db 4
    .db 0b11100000
    .db 0b00000000
    .db 0b11100000
    .db 0b01000000
    .db 0b11100000
    
    ; Ï
    .db 4
    .db 0b10100000
    .db 0b00000000
    .db 0b01000000
    .db 0b01000000
    .db 0b01000000
   
    ; Ð    
    .db 4
    .db 0b11000000
    .db 0b10100000
    .db 0b11100000
    .db 0b10100000
    .db 0b11000000

    ; Ñ    
    .db 4
    .db 0b11100000
    .db 0b00000000
    .db 0b10100000
    .db 0b11100000
    .db 0b11100000
    
    ; Ò    
    .db 4
    .db 0b10000000
    .db 0b01000000
    .db 0b10100000
    .db 0b10100000
    .db 0b01000000    
    
    ; Ó    
    .db 4
    .db 0b00100000
    .db 0b01000000
    .db 0b10100000
    .db 0b10100000
    .db 0b01000000
       
    ; Ô    
    .db 4
    .db 0b01000000
    .db 0b11100000
    .db 0b10100000
    .db 0b10100000
    .db 0b01000000
    
    ; Õ    
    .db 4
    .db 0b11100000
    .db 0b01000000
    .db 0b10100000
    .db 0b10100000
    .db 0b01000000
       
    ; Ö    
    .db 4
    .db 0b10100000
    .db 0b00000000
    .db 0b11100000
    .db 0b10100000
    .db 0b01000000
    
    ; ×    
    .db 4
    .db 0b00000000
    .db 0b10100000
    .db 0b01000000
    .db 0b10100000
    .db 0b00000000
    
    ; Ø    
    .db 4
    .db 0b00100000
    .db 0b01000000
    .db 0b10100000
    .db 0b01000000
    .db 0b10000000
   
    ; Ù    
    .db 4
    .db 0b10000000
    .db 0b01000000
    .db 0b10100000
    .db 0b10100000
    .db 0b01000000
    
    ; Ú    
    .db 4
    .db 0b00100000
    .db 0b01000000
    .db 0b10100000
    .db 0b10100000
    .db 0b01000000
    
    ; Û    
    .db 4
    .db 0b11100000
    .db 0b00000000
    .db 0b10100000
    .db 0b10100000
    .db 0b01000000
    
    ; Ü    
    .db 4
    .db 0b10100000
    .db 0b00000000
    .db 0b10100000
    .db 0b10100000
    .db 0b01000000
    
    ; Ý    
    .db 4
    .db 0b00100000
    .db 0b00000000
    .db 0b10100000
    .db 0b01000000
    .db 0b01000000
    
    ; Þ    
    .db 4
    .db 0b10000000
    .db 0b11000000
    .db 0b10100000
    .db 0b11000000
    .db 0b10000000
    
    ; ß    
    .db 4
    .db 0b11000000
    .db 0b10100000
    .db 0b11000000
    .db 0b11100000
    .db 0b10000000
       
    ; à    
    .db 4
    .db 0b10000000
    .db 0b01000000
    .db 0b01100000
    .db 0b10100000
    .db 0b01100000

    ; á    
    .db 4
    .db 0b00100000
    .db 0b01000000
    .db 0b01100000
    .db 0b10100000
    .db 0b01100000
    
    ; â
    .db 4
    .db 0b01000000
    .db 0b10100000
    .db 0b01100000
    .db 0b10100000
    .db 0b01100000
       
    ; ã
    .db 4
    .db 0b10100000
    .db 0b01000000
    .db 0b01100000
    .db 0b10100000
    .db 0b01100000

    ; ä    
    .db 4
    .db 0b10100000
    .db 0b00000000
    .db 0b01100000
    .db 0b10100000
    .db 0b01100000

    ; å
    .db 4
    .db 0b00000000
    .db 0b01100000
    .db 0b10100000
    .db 0b10100000
    .db 0b01100000
    
    ; æ
    .db 7
    .db 0b00000000
    .db 0b01101100
    .db 0b10110100
    .db 0b10111000
    .db 0b01101100
       
    ; ç
    .db 4
    .db 0b01100000
    .db 0b10000000
    .db 0b01100000
    .db 0b01000000
    .db 0b11000000
   
    ; è
    .db 4
    .db 0b10000000
    .db 0b01100000
    .db 0b10100000
    .db 0b11000000
    .db 0b01100000
   
    ; é
    .db 4
    .db 0b00100000
    .db 0b01000000
    .db 0b10100000
    .db 0b11000000
    .db 0b01100000
    
    ; ê
    .db 4
    .db 0b00000000
    .db 0b01100000
    .db 0b10100000
    .db 0b11000000
    .db 0b01100000
    
    ; ë
    .db 4
    .db 0b10100000
    .db 0b01100000
    .db 0b10100000
    .db 0b11000000
    .db 0b01100000
    
    ; ì
    .db 4
    .db 0b01000000
    .db 0b00100000
    .db 0b01000000
    .db 0b01000000
    .db 0b01100000
    
    ; í
    .db 4
    .db 0b01000000
    .db 0b10000000
    .db 0b01000000
    .db 0b01000000
    .db 0b11100000
    
    ; î
    .db 4
    .db 0b01000000
    .db 0b10100000
    .db 0b01000000
    .db 0b01000000
    .db 0b01100000
    
    ; ï
    .db 4
    .db 0b10100000
    .db 0b00000000
    .db 0b01000000
    .db 0b01000000
    .db 0b11100000
    
    ; ð
    .db 4
    .db 0b11000000
    .db 0b00100000
    .db 0b01100000
    .db 0b10100000
    .db 0b01000000
    
    ; ñ
    .db 4
    .db 0b10100000
    .db 0b01000000
    .db 0b11000000
    .db 0b10100000
    .db 0b10100000
    
    ; ò
    .db 4
    .db 0b01000000
    .db 0b00100000
    .db 0b01000000
    .db 0b10100000
    .db 0b01000000
    
    ; ó
    .db 4
    .db 0b01000000
    .db 0b10000000
    .db 0b01000000
    .db 0b10100000
    .db 0b01000000
    
    ; ô    
    .db 4
    .db 0b01000000
    .db 0b00000000
    .db 0b01000000
    .db 0b10100000
    .db 0b01000000
    
    ; õ
    .db 4
    .db 0b11100000
    .db 0b00000000
    .db 0b01000000
    .db 0b10100000
    .db 0b01000000
    
    ; ö
    .db 4
    .db 0b10100000
    .db 0b00000000
    .db 0b01000000
    .db 0b10100000
    .db 0b01000000
    
    ; ÷
    .db 4
    .db 0b01000000
    .db 0b00000000
    .db 0b11100000
    .db 0b00000000
    .db 0b01000000
    
    ; ø
    .db 4
    .db 0b00100000
    .db 0b01100000
    .db 0b10100000
    .db 0b11000000
    .db 0b10000000
    
    ; ù
    .db 4
    .db 0b11000000
    .db 0b00100000
    .db 0b01100000
    .db 0b10100000
    .db 0b01000000
    
    ; ú
    .db 4
    .db 0b00100000
    .db 0b01000000
    .db 0b10100000
    .db 0b10100000
    .db 0b01100000
    
    ; û
    .db 4
    .db 0b11100000
    .db 0b00000000
    .db 0b10100000
    .db 0b10100000
    .db 0b01100000
    
    ; ü
    .db 4
    .db 0b10100000
    .db 0b00000000
    .db 0b10100000
    .db 0b10100000
    .db 0b01100000
    
    ; ý
    .db 4
    .db 0b00100000
    .db 0b01000000
    .db 0b10100000
    .db 0b01000000
    .db 0b10000000
    
    ; þ
    .db 4
    .db 0b10000000
    .db 0b11000000
    .db 0b10100000
    .db 0b11000000
    .db 0b10000000
    
    ; ÿ
    .db 4
    .db 0b10100000
    .db 0b00000000
    .db 0b10100000
    .db 0b01000000
    .db 0b10000000
