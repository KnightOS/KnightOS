;##################################################################
;
;   Phoenix-82 (Screen display routines)
;
;   Programmed by Patrick Davidson (pad@calc.org)
;        
;   Copyright 2008 by Patrick Davidson.  This software may be freely
;   modified and/or copied with no restrictions.  There is no warranty.
;
;   This file was last updated September 9, 2008.
;
;##################################################################   

;############## Initialize side data

set_up_sides:
    ld a, 1
    kld((leftsidevel), a)
    inc a
    kld((leftsidecoord), a)
    kld((rightsidecoord), a)
    ld a, -1
    kld((rightsidevel), a)
    ld b, 64
loop_sus:
    push bc
    kcall(scroll_sides)
    pop bc
    djnz loop_sus
    ret

;############## Scroll the sides down one pixel 
        
scroll_sides:
    kld(de, rightside + 0x41)
    kld(hl, rightside + 0x40)
    ld bc, 0x40
    lddr

    dec hl
    dec hl
    dec de
    dec de
    ld bc, 0x40
    lddr

    kld(hl, rightsidecoord)
    kcall(scroll_side)
    kld(hl, rightsidetable)
    add a, l \ ld l, a \ jr nc, $+3 \ inc h
    ld a, (hl)
    kld((rightside + 2), a)

    kld(hl, leftsidecoord)
    kcall(scroll_side)
    kld(hl, leftsidetable)
    add a, l \ ld l, a \ jr nc, $+3 \ inc h
    ld a, (hl)
    kld((leftside + 2), a)
    ret

;############## Calculate new position of side at (HL) 
        
scroll_start:
    ld (hl), 1
    kcall(FAST_RANDOM)
    add a, a
    jr c, scroll_adjust_done
    ld (hl), -1
    jr scroll_adjust_done        
        
scroll_side:
    kcall(FAST_RANDOM)
    and 7
    jr nz, nosiderand
    inc hl
    ld a, (hl)
    or a
    jr z, scroll_start
    ld (hl), 0
scroll_adjust_done:
    dec hl
nosiderand:     
    ld a, (hl)
    inc hl
    add a, (hl)
    jr nz, noforceli
    ld (hl), 1
noforceli:
    cp 8
    jr nz, noforceld
    ld (hl), -1
noforceld:      
    dec hl
    ld (hl), a
    ret

rightsidetable:
    .db 0b00000000
    .db 0b00000000
    .db 0b00000100
    .db 0b00001100
    .db 0b00011100
    .db 0b00111100
    .db 0b01111100
    .db 0b11111100
    .db 0b11111100

leftsidetable:
    .db 0b00000000
    .db 0b10000000
    .db 0b11000000
    .db 0b11100000
    .db 0b11110000
    .db 0b11111000
    .db 0b11111100
    .db 0b11111110
    .db 0b11111111

;############## Display -1 terminated list of strings at (HL)

display_hl_msgs:
    pcall(clearBuffer)
    ld de, 0
    kld((_puts_shim_cur), de)
show_loop:
    kcall(puts)
    ld a, (hl)
    inc a
    ret z
    inc e
    jr show_loop

;############## Show information panel

display_money:
    push bc
        ;ld de, GFX_AREA+0x3B3
        push iy \ pop hl
        ld bc, 0x3B3
        add hl, bc
        kld(a, (player_x))
        cp 60
        jr nc, left_side
        pcall(colorSupported)
        jr nz, _
        ld a, 0x3BB - 0x3B7
        add a, l \ ld l, a \ jr nc, $+3 \ inc h
        jr left_side
_:      ld a, 0x3BB - 0x3B3
        ;ld de, GFX_AREA+0x3BB
        add a, l \ ld l, a \ jr nc, $+3 \ inc h
left_side:
    pop bc
    ex de, hl
    kld(hl, decimal_cash)
    kjp(display_number_bcd)

;############## Prepares on-screen shield indicator

prepare_indicator:
    kld(a,(player_pwr))
    or a
    ret z
    ret m
    ld b,a
    ;ld hl,GFX_AREA+1024-3
    push iy \ pop hl
    push bc
        ld bc, 1024 - 3
        add hl, bc
    pop bc
    ld de,-16
    pcall(colorSupported)
    jr z, .color
.loop_ind:
    set 0, (hl)
    add hl, de
    set 0, (hl)
    add hl, de
    set 0, (hl)
    add hl, de
    set 0, (hl)
    add hl, de
    djnz .loop_ind
    ret
.color:
    push bc
    push de
    push hl
        ld b, 16 ; Color fix (TODO: it's a bug somewhere else, just don't know where)
.loop:
        res 0, (hl)
        res 1, (hl)
        add hl, de
        res 0, (hl)
        res 1, (hl)
        add hl, de
        res 0, (hl)
        res 1, (hl)
        add hl, de
        res 0, (hl)
        res 1, (hl)
        add hl, de
        djnz .loop
    pop hl
    pop de
    pop bc
    jr .loop_ind

############## Display sides over the screen
	
render_sides:
    kld(a, (sides_flag))
    or a
    ret z
    pcall(colorSupported)
    jr z, .color
    kld(hl, leftside)
    ld de, MIN_Y
    kcall(drw_spr)

    kld(hl, rightside)
    ld de, MIN_Y+(120<<8)
    kjp(drw_spr)

.color:
    kld(hl, leftside)
    ld de, MIN_Y+(-24<<8)
    kcall(drw_spr_skip_offset)

    kld(hl, rightside)
    ld de, MIN_Y+(120<<8)
    kjp(drw_spr)

;############## Clears screen buffer

clear_buffer:
    push hl
    push de
    push bc
        push iy \ pop hl
        ld (hl), 0
        ld d, h
        ld e, l
        inc de
        ld bc, 16*64
        ldir
    pop bc
    pop de
    pop hl
    ret
	
;############## Display entire screen from buffer

display_screen:
    kld(a, (invert))
    or a
    ld a, 0x2F                   ; A = CPL
    jr nz, ds_inverted
    xor a                       ; A = NOP
ds_inverted:
    kld((smc_invert), a)

    ld a, 0x80
    out (0x10), a ; Set row to 0
    push iy \ pop hl
    inc hl \ inc hl
    ld c, 0x20
dispColumn:
    in a, (0x10) \ and 0b10010000 \ jr nz, $-4 ; Wait for LCD to be ready
    ld a, c
    out (0x10), a ; Set row to 0
    cp 0x2C
    ret z
    ld b, 64 ; 64 times (one for each column)
    ld de, 16 ; This draws from top to bottom in each column, so add 16 each time
dispByte:
    in a, (0x10) \ and 0b10010000 \ jr nz, $-4 ; Wait for LCD
    ld a, (hl)
smc_invert:
    cpl                            ; invert or not depending on smc
    out (0x11), a ; Write byte
    add hl, de
    djnz dispByte ; Loop back to write MORE bytes
    ld de, -1023 ; Subtract backwards to next column to draw
    add hl, de
    inc c
    jr dispColumn

display_screen_cse:
    push hl \ push bc \ push de \ push af
        push iy \ pop hl
        ; Draws a 96x64 monochrome LCD buffer (legacy buffer) to the color LCD
        ld bc, 64 << 8 | PORT_LCD_DATA ; 64 rows in b, and the data port in c
        ld de, ((240 - 128) / 2) << 8 | 0 ; Top of the current window in d, 0xFF in e
.loop:
        ; Set cursor column to 0
        ld a, LCDREG_CURSOR_COLUMN
        out (PORT_LCD_CMD), a \ out (PORT_LCD_CMD), a
        dec a ; ld a, 32
        out (c), a \ out (c), a
        ; Set window top and cursor row to d
        ;ld a, 0x20 ; (aka 32)
        out (PORT_LCD_CMD), a \ out (PORT_LCD_CMD), a
        out (c), e \ out (c), d ; Cursor row
        ld a, LCDREG_WINDOW_HORIZ_START
        out (PORT_LCD_CMD), a \ out (PORT_LCD_CMD), a
        out (c), e \ out (c), d ; Window top
        ; Window bottom to d + 1
        inc d \ inc a
        out (PORT_LCD_CMD), a \ out (PORT_LCD_CMD), a
        out (c), e \ out (c), d
        ; Select data register
        ld a, LCDREG_GRAM
        out (PORT_LCD_CMD), a \ out (PORT_LCD_CMD), a
        ; Draw row
        push de
        push bc
            ld d, 0xFF
            ld b, 16
.innerLoop:
            ld a, (hl)
            inc hl

            rla
            jr nc, _ ; Bit 7
            out (c), e \ out (c), e ; Black
            out (c), e \ out (c), e
            jr ++_
_:          out (c), d \ out (c), d ; White
            out (c), d \ out (c), d
_:          rla
            jr nc, _ ; Bit 6
            out (c), e \ out (c), e
            out (c), e \ out (c), e
            jr ++_
_:          out (c), d \ out (c), d
            out (c), d \ out (c), d
_:          rla
            jr nc, _ ; Bit 5
            out (c), e \ out (c), e
            out (c), e \ out (c), e
            jr ++_
_:          out (c), d \ out (c), d
            out (c), d \ out (c), d
_:          rla
            jr nc, _ ; Bit 4
            out (c), e \ out (c), e
            out (c), e \ out (c), e
            jr ++_
_:          out (c), d \ out (c), d
            out (c), d \ out (c), d
_:          rla
            jr nc, _ ; Bit 3
            out (c), e \ out (c), e
            out (c), e \ out (c), e
            jr ++_
_:          out (c), d \ out (c), d
            out (c), d \ out (c), d
_:          rla
            jr nc, _ ; Bit 2
            out (c), e \ out (c), e
            out (c), e \ out (c), e
            jr ++_
_:          out (c), d \ out (c), d
            out (c), d \ out (c), d
_:          rla
            jr nc, _ ; Bit 1
            out (c), e \ out (c), e
            out (c), e \ out (c), e
            jr ++_
_:          out (c), d \ out (c), d
            out (c), d \ out (c), d
_:          rla
            jr nc, _ ; Bit 0
            out (c), e \ out (c), e
            out (c), e \ out (c), e
            jr ++_
_:          out (c), d \ out (c), d
            out (c), d \ out (c), d
_:
            dec b
            kjp(nz, .innerLoop)
        pop bc
        pop de
        inc d
        dec b
        kjp(nz, .loop)
    pop af \ pop de \ pop bc \ pop hl
    ret

.macro lcdout(reg, value)
    ld a, reg
    ld hl, value
    pcall(writeLcdRegister)
.endmacro

setColorParameters:
    push iy
        ld iy, 0x4108
        pcall(clearColorLcd)
    pop iy
    ; Set up partial images
    ld a, LCDREG_PARTIALIMG1_DISPPOS
    ld hl, 0
    pcall(writeLcdRegister)
    inc a
    ; ld hl, 0
    pcall(writeLcdRegister)
    inc a
    ld hl, 159
    pcall(writeLcdRegister)
    inc a
    ld hl, 160
    pcall(writeLcdRegister)
    inc a
    ld hl, 0
    pcall(writeLcdRegister)
    inc a
    ld hl, 159 ; 95
    pcall(writeLcdRegister)
    ; Set BASEE = 0, both partial images = 1
    ld a, LCDREG_DISPCONTROL1
    out (PORT_LCD_CMD), a \ out (PORT_LCD_CMD), a
    ld c, PORT_LCD_DATA
    in a, (PORT_LCD_DATA) \ in l, (c)
    or  0b00110000 ; Partial images
    and 0b11111110 ; BASEE
    out (PORT_LCD_DATA), a
    out (c), l
    ; Set interlacing on
    lcdout(LCDREG_DRIVER_OUTPUTCONTROL1, 0b0000010000000000)
    ; Set window rows
    lcdout(LCDREG_WINDOW_VERT_START, (160 - 128) / 2)
    lcdout(LCDREG_WINDOW_VERT_END, 159 - (160 - 128) / 2)
    ; Set entry mode (down-then-right)
    lcdout(LCDREG_ENTRYMODE, 0b0001000000110000)
    ret
