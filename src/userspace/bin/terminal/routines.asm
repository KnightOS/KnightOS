; Terminal utility routines

; Reads a string into (IX)
term_readString:
    push IX
    ; TODO: Limit characters input to buffer size
readString_cursorLoop:
        ; TODO: Try to refactor cursor drawing to use the column
        ; on the right properly
        ; Update cursor
        ld a, cursorChar
        kcall term_printChar
        kld hl, cursorState
        inc (hl)
        
        ; cursor delay/keyboard input loop
#ifdef CPU15
        ld b, $80
#else
        ld b, $20
#endif
readString_delay:
        call fastCopy
        push bc
            ; applib(getCharacterInput)
            rst $10 \ .db applibId \ call getCharacterInput
            ld c, a ; Some register juggling to preserve values
            ld a, b
            or a
            jr nz, readString_handleKey
        pop bc
        jr nz, readString_handleKey
        djnz readString_delay
        jr readString_cursorLoop
readString_handleKey:
        ; TODO: DEL and such
        ; Check for key and go back if it's not a character
        ld a, c ; unjuggle registers
        or a
        jr nz, _
        pop bc
        jr readString_delay
        
_:      inc sp \ inc sp
        kld a, (cursorState)
        bit 0, a
        jr z, _
        ; Get rid of cursor
        res 0, a
        kld (cursorState), a
        ld a, cursorChar
        kcall term_printChar
        
_:      ld a, c
        kcall term_printChar
        cp '\n'
        jr z, readString_done
        kcall term_advanceCursor
        ld (ix), a
        inc ix
        
        call flushKeys
        
        jr readString_cursorLoop
readString_done:
        call flushKeys
    pop IX
    ret
    
term_printChar:
    push de
        cp '\n'
        jr z, _
        ; libtext(drawCharXOR)
        rst $10 \ .db libTextId \ call drawCharXOR
    pop de
    ret
_:
    pop de
    push af
        ld d, 2
        ld a, e \ add a, 6 \ ld e, a
        kcall term_checkScroll
    pop af
    ret

; Wraps to the next line if the character is too wide.
term_advanceCursor:
    ; Measure character
    push af
        ; libtext(measureChar)
        rst $10 \ .db libTextId \ call measureChar
        add a, d
        ld d, a
        cp 90
        jr c, _
        ld d, 2
        ld a, e \ add a, 6 \ ld e, a
        kcall term_checkScroll
_:  pop af
    ret
    
; Scrolls the entire terminal down a line if needed
term_checkScroll:
    ld a, e
    add a, 5
    cp 57
    ret c
    ; Do scroll
    sub 11
    ld e, a
    push hl \ push de \ push bc
        push iy \ pop hl
        push iy \ pop de
        ; Screen buffer start in HL, DE
        ld bc, 7 * 12
        add hl, bc ; Add 6 rows to skip window chrome
        ex de, hl ; DE is destination
        ld bc, 13 * 12 ; Add 12 rows, window chrome + 1 row
        add hl, bc
        ld bc, 46 * 12 ; Size to shift
        ldir
        ; Clear out artifacts
        ld e, 1 \ ld l, 52
        ld bc, 6 << 8 | 94 ; height << 8 | width
        call rectAND
    pop bc \ pop de \ pop hl
    ret
    
cursorState:
    .db 0 ; Only the low bit matters