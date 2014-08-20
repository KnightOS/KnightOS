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
    or a	; OR register A with itself (does nothing)
    		; if A is 0, set Z flag
    ret z 	; Return if Z flag is set
    		; TODO: Handle launched w/o args

    push de ; Save file path
        pcall(getLcdLock)
        pcall(getKeypadLock)

        kld(de, corelibPath)
        pcall(loadLibrary)

        pcall(allocScreenBuffer)	; Allocates 768 byte screen buffer
					; and stores address in IY
    pop hl	; Put file path in hl

    ; Draw Window
    xor a			; Set flags to draw caste and thread icons
    corelib(drawWindow)

    ; Open file
    ex de, hl			; Load file path into DE
    pcall(openFileRead)		; Open file
    				; A=Error Code, Z=Success, E=Garbage, D=Stream ID
    ret nz			; End Program if opening file failed

    ; For testing purposes, we'll load the entire file into RAM
    pcall(getStreamInfo)	; Get bytes left in file stream (puts in EBC)
    inc bc
    pcall(malloc)		; Allocate file size+1 bytes. Gives starting point in IX
    ret nz			; End program if memory allocation failed
    pcall(streamReadToEnd)	; Read entire file into allocated RAM at IX
    pcall(closeStream)

    ; Put 0 at end of file in RAM
    pcall(memSeekToEnd)		; Set IX to end of allocated memory block
    ld (ix), 0			; Set byte pointed to by IX to 0
    pcall(memSeekToStart)	; Set IX to beginning of allocated memory block
    
    ;push ix \ pop hl		; Ridiculous way to load IX into HL
    ld b, 2			; Set left margin (indent?) to 0
    ld de, 0x0208		; Set drawing coordinates to 2,10
    ld hl, 95 << 8 | 56		; Set limits on text area

drawLoop:
    pcall(wrapStr)		; Draw a bunch of text to screen buffer
_:  pcall(fastCopy)		; Copy screen buffer to LCD

    ; Wait for key press and interpret it
    pcall(flushKeys)
    corelib(appWaitKey)

    cp kMODE
    ret z
    cp kDown
    jr z, .down
    cp kEnter
    jr z, .down
    jr -_			; Loop

.down:
    ; If byte at ix is 0 (end of file), then do nothing
    ld a, (ix)
    or a
    jr z, -_ ; Skip this if at end of file

    push hl			; Push bounding box limits
    push de			; and drawing coordinates to stack
        ; Shift text up by one row
        push iy \ pop hl	; Load screen buffer address into HL
        ld bc, 12 * 8		; 96 pixels / 8 bits = 12 bytes per horizontal line
        add hl, bc		
        push hl \ pop de	; Set DE to beginning of line 8
        ld bc, 12 * 6
        add hl, bc		; Set HL to 6 lines after (1 row of text)
        ;ld bc, (96 * 48) / 8	; Set counter for 42 lines of screen
				; 64 - 8 (header) - 8 (menu bar) = 48
	ld bc, 0x0240
        ldir			; Copy BC bytes from address at HL to address at DE

	; Clear last row
        push iy \ pop hl	; Load screen buffer address into HL
	; ASSEMBLER BUG
	;ld bc, 12 * (64 - 6 - 8)
	; is not the same as...
        ld bc, 0x0258		; 12 bytes per line * (64 - 6 - 8) pixels
        add hl, bc
        push hl \ pop de	; Set DE to beginning of last row of text
        inc de			; Set DE to second byte of row
        xor a
        ld (hl), a		; Set first byte of row to zero
        ld bc, 6 * 12 - 1	; Set counter for 6 rows of pixels
        ldir			; Copy 0 from first byte to second byte,
				; increment, and repeat BC times
	; Redraw window sides
	ld a, 0
	ld l, 50		; Set starting coordinates to 0,50
	ld c, 6			; Set height to 6
	pcall(drawVLine)	
	ld a, 95		; Set starting coordinates to 95,50
	pcall(drawVLine)	

    pop de			; Put back drawing coordinates
    pop hl			; and bounding box limits

    ; Shift drawing coordinates up by 6 pixels (1 row of text)
    ld a, -6
    add a, e
    ld e, a

    ld d, 2			; Set X coordinate to 2
    ld b, 2			; Set margin to 2

    ; Hacky workaround
    ; Increment string pointer if its pointing at a newline char
    ; and go back to the loop
    ld a, (ix)
    cp '\n'
    jr nz, drawLoop
    inc ix
    jr drawLoop


corelibPath:
    .db "/lib/core", 0
