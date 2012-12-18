; Terminal utility routines

; Reads a string into (IX)
term_readString:
    push IX
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
        djnz readString_delay
        jr readString_cursorLoop
readString_handleKey:
        ; Check for key and go back if it's not a character        
        ld a, c ; unjuggle registers
        or a
        jr nz, ++_
        ; Not a character, handle special keys
        ld a, b
        cp kLeft
        jr nz, _
            ; Handle left scroll
            ; Don't allow it to grow past the start
            inc sp \ inc sp \ pop bc \ push bc \ dec sp \ dec sp ; Get start of string in BC (slightly hacky)
            push hl
                push ix \ pop hl
                call cpHLBC
            pop hl
            jr z, handleKey_loopBack
            ; Perform the left scroll
            kcall readString_doLeftScroll
            jr handleKey_loopBack
_:      cp kRight
        jr nz, handleKey_loopBack
            ; Handle right scroll
        
handleKey_loopBack:
        pop bc
        jr readString_delay
        
_:      inc sp \ inc sp
        cp $08 ; Backspace
        jr z, readString_handleBackspace
        
        cp '\n'
        jr z, _
        
        ; Ensure it isn't too long
        push hl
        push bc
            push ix
                call memSeekToEnd
                push ix \ pop hl
            pop bc \ push bc \ pop ix
            call cpHLBC
        pop bc
        pop hl
        jr z, readString_cursorLoop
        
_:      kld a, (cursorState)
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
        
        kjp readString_cursorLoop
        
readString_handleBackspace:
    ; Don't allow it to grow past the start
    pop bc \ push bc ; BC is start of string
    push hl
        push ix \ pop hl
        call cpHLBC
    pop hl
    kjp z, readString_cursorLoop
    
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
    
_:  ld a, (IX + -1)
    ;libtext(measureChar)
    rst $10 \ .db libtextId \ call measureChar
    ; Back up cursor
    ld c, a
    ld a, d
    sub c
    ld d, a
    ; Check for overflow
    jr nc, _
    ld a, e
    sub 6
    ld e, a
    ld d, 2
_:  ld b, 5 ; Erase character
    push de
    push hl
        ld l, e
        ld e, d
        call rectAND
    pop hl
    pop de
    dec ix
    xor a
    ld (ix), a
    call flushKeys
    kjp readString_cursorLoop
        
readString_done:
        call flushKeys
        xor a
        ld (ix), a
    pop IX
    ret
    
readString_doLeftScroll:
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
    
    ; Move display pointer back a character
_:  ld a, (IX + -1)
    ;libtext(measureChar)
    rst $10 \ .db libtextId \ call measureChar
    ; Back up cursor
    ld c, a
    ld a, d
    sub c
    ld d, a
    ; Check for overflow
    jr nc, _
    ld a, e
    sub 6
    ld e, a
    ld d, 2
_:  ; Move text pointer back a character
    dec ix
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
    push de \ pop bc
        ; Put a 6-byte buffer on the stack to hold the ASCII number
        ; 65535 (5 digits) plus the null terminator
        ex de, hl
        ld hl, -6
        add hl, sp
        ld sp, hl
        push bc
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
    
term_printHex:
    push af
        rrca
        rrca
        rrca
        rrca
        kcall dispha
    pop af
    kcall dispha
    ret
dispha:
    and 15
    cp 10
    jr nc,dhlet
    add a, 48
    jr dispdh
dhlet:
    add a,55
dispdh:
    kcall term_printChar
    ret
    
cursorState:
    .db 0 ; Only the low bit matters