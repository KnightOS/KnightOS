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

;;############## Show information panel
;
;display_money:
;        ld      de,GFX_AREA+$3b3
;        ld      a,(player_x)
;        cp      60
;        jr      nc,left_side
;        ld      de,GFX_AREA+$3bb
;left_side:
;        ld      hl,decimal_cash
;        jp      display_number_bcd
;
;;############## Prepares on-screen shield indicator
;
;prepare_indicator:
;        ld      a,(player_pwr)
;        or      a
;        ret     z
;        ret     m
;        ld      b,a
;        ld      hl,GFX_AREA+1024-3
;        ld      de,-16
;loop_ind:
;        set     0,(hl)
;        add     hl,de
;        set     0,(hl)
;        add     hl,de
;        set     0,(hl)
;        add     hl,de
;        set     0,(hl)
;        add     hl,de
;        djnz    loop_ind
;        ret

############## Display sides over the screen
	
render_sides:
    kld(a, (sides_flag))
    or a
    ret z

    kld(hl, leftside)
    ld de, MIN_Y
    kcall(drw_spr)

    kld(hl, rightside)
    ld de, MIN_Y+(122<<8)
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
    out (0x10), a
    push iy \ pop hl
    inc hl \ inc hl
    ld c, 0x20
dispColumn:
    in a, (0x10) \ and 0b10010000 \ jr nz, $-4
    ld a, c
    out (0x10), a
    cp 0x2C
    ret z
    ld b, 64
    ld de, 16
dispByte:
    in a, (0x10) \ and 0b10010000 \ jr nz, $-4
    ld a, (hl)
smc_invert:
    cpl                            ; invert or not depending on smc
    out (0x11), a
    add hl, de
    djnz dispByte
    ld de, -1023
    add hl, de
    inc c
    jr dispColumn
