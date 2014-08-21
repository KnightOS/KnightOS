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
    ; Allocate file size+1 bytes. Gives starting point in IX
    ; End program if memory allocation failed
    inc bc
    pcall(malloc)        
    ret nz            
    pcall(streamReadToEnd)
    pcall(closeStream)

    ; Put 0 at end of file in RAM
    pcall(memSeekToEnd)    
    ld (ix), 0
    pcall(memSeekToStart)
    
    push ix \ pop hl
    ld de, 0x0208               ; Set drawing coordinates to 2,8

drawLoop:
    ld a, 2                     ; Set left margin to 2
    ld bc, 95 << 8 | 56         ; Set limits on text area
    pcall(wrapStr)
_:  pcall(fastCopy)

    ; Wait for key press and interpret it
    pcall(flushKeys)
    corelib(appWaitKey)

    cp kMODE
    ret z
    cp kDown
    jr z, .down
    cp kEnter
    jr z, .down
    jr -_

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
        ;ld bc, (96 * 48) / 8   ; Set counter for 42 lines of screen
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
    ld l, 50                    ; Set starting coordinates to 0,50
    ld c, 6                     ; Set height to 6
    pcall(drawVLine)    
    ld a, 95                    ; Set starting coordinates to 95,50
    pcall(drawVLine)    
    pop de
    pop hl

    ; Shift drawing coordinates up by 6 pixels (1 row of text)
    ld a, -6
    add a, e
    ld e, a
    ld d, 2                     ; Set X coordinate to 2

    ; Hacky workaround
    ; Increment string pointer if its pointing at a newline char
    ; and go back to the loop
    ld a, (hl)
    cp '\n'
    jr nz, drawLoop
    inc hl
    jr drawLoop


corelibPath:
    .db "/lib/core", 0
