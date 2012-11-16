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
        push de
            ; libtext(drawCharXOR)
            rst $10 \ .db libTextId \ call drawCharXOR
        pop de
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
        push de
            ; libtext(drawCharXOR)
            rst $10 \ .db libTextId \ call drawCharXOR
        pop de
        
_:      ld a, c
        kcall term_printChar
        cp '\n'
        jr z, readString_done
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
    kcall term_advanceCursor
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
    cp '\n'
    ret z
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
    
; Prints (hl) to the terminal
term_printString:
    push hl
_:      ld a, (hl)
        or a
        jr z, _
        kcall term_printChar
        inc hl
        jr -_
_:  pop hl
    ret
    
; Prints a decimal number to the terminal
term_printDecimal:
    push hl
    push bc
    push af
    push de
        ; Put a 6-byte buffer on the stack to hold the ASCII number
        ; 65535 (5 digits) plus the null terminator
        ex de, hl
        ld hl, -6
        add hl, sp
        ld sp, hl
        ld bc, 6 \ add hl, bc
        ; Load the null terminator
        xor a \ ld (hl), a \ dec hl
        ex de, hl
        ; (de) is a 5 byte buffer for conversion
        ; hl is the number to print
        ld c, 10
_:      call divHLbyC ; HL = HL / 10; A = HL % 10;
        add a, '0'
            ; Load that value into the buffer
            ex de, hl
            ld (hl), a
            dec hl
            ex de, hl
        ; Check to see if HL is zero, or loop if not
        ld a, h
        or a \ jr nz, -_
        ld a, l
        or a \ jr nz, -_
        ex de, hl
    pop de
        ; Print the string
        inc hl
        kcall term_printString
    ; Reset the stack
    ld hl, 6
    add hl, sp
    ld sp, hl
    pop af
    pop bc
    pop hl
    ret
    
cursorState:
    .db 0 ; Only the low bit matters