;##################################################################
;
;   Phoenix-Z80 ("sprite" drawing routine)
;
;   Programmed by Patrick Davidson (pad@calc.org)
;        
;   Copyright 2005 by Patrick Davidson.  This software may be freely
;   modified and/or copied with no restrictions.  There is no warranty.
;
;   This file was last updated November 28, 2005.
;
;##################################################################     

drw_spr_wide:
    ld a, (hl)
    cp 9
    jr c, drw_spr
dswl:
    push de
    push hl
    kcall(drw_spr)
    pop hl
    pop de
    ld a, 8
    add a, d
    ld d, a
    ld b, (hl)
    inc hl
    ld a, (hl)
    inc hl
    add a, l \ ld l, a \ jr nc, $+3 \ inc h
    ld a, 8
    cp b
    jr c, dswl
    ret

.equ MIN_Y 32
.equ MAX_Y 96

clip_top:
    pop hl              ; HL -> image data
    inc hl
    add a, (hl)          ; A = bottom Y coordinate + 1
    sub MIN_Y + 1         ; A = # of lines past 32 
    ret c
    inc a               ; A = number of lines on screen
    ld b, a             ; B = number of lines to draw
    sub (hl)
    neg ; A = number of lines skipped
    inc a               ; A = number of bytes to skip
    
    add a, l
    jr nc, ctad
    inc h
ctad:
    ld l, a             ; HL -> start of image data to use

    ld a, d             ; A = X coordinate
    
    ex de, hl           ; DE -> start of image data to use

smc_gfxmem_start:
    push iy \ pop hl
    rra
    rra
    rra
    and 15
    add a, l
    ld l, a             ; HL -> screen address
    jr nc, drw_spr_main
    inc h
    jr drw_spr_main
        
drw_spr:
    kld(a, (x_offset)) ; This adjusts by some offset all sprites move by
    sub d
    neg
    ld d, a
    cp 112
    ret nc
    and 7
    ld b, a ; NOTE: Is this needed after I changed the logic to *= 4?
    add a, a \ add a, a
    kld((jumpintable + 1), a)       ; Save selected shift amount
    
    push hl                      ; Save sprite image pointer

    ld b, 0
smc_gfxmem_minus512:
    ;ld hl, GFX_AREA-512         ; HL -> start of buffer
    push iy \ pop hl
    dec h \ dec h ; - 512
    ; NOTE: This seems dangerous. The graphics buffer is dynamically allocated and
    ; writing to buffer - 512 will likely crash the calc
    ; Will have to figure out if this actually does that or if it's just for something
    ; else. I'm comforted by the fact that plotSScreen-512 (on TIOS) is in the middle
    ; of nowhere.
    ld a, e

    cp MIN_Y
    jr c, clip_top

    kld((smc_start_y_coord + 1), a) ; SMC
    
    add a, a                     ; A = Y * 2
    add a, a
    rl b                       ; BA = Y * 4
    add a, a                    
    rl b                       ; BA = Y * 8
    add a, a
    rl b                       ; BA = Y * 16
    ld c, d             
    srl c
    srl c
    srl c                       ; C = X / 8
    or c
    ld c, a
    add hl, bc                   ; HL = Screen address

    ex de, hl                   ; DE = Screen address

    pop hl
    inc hl
    ld b, (hl)                  ; B = height
    inc hl                      ; HL -> image

    ex de, hl                   ; HL -> screen, DE -> image

smc_start_y_coord:
    ld a, 0                     ; Self-modification stores Y here
    cp MAX_Y
    ret nc
    add a, b                     ; A = maximum Y coordinate
    cp MAX_Y
    jr c, drw_spr_main
    sub b
    sub MAX_Y
    neg
    ld b, a        
                
drw_spr_main:   
    ld c, 0
    and a
        
jumpintable:
    jr table

table:
    kjp(routine0)
    kjp(routine1)
    kjp(routine2)
    kjp(routine3)
    kjp(routine4)
    kjp(routine5)
    kjp(routine6)

routine7:
    inc hl
routine7l:
    ld a, (de)
    inc de

    add a, a
    rl c
    or (hl)
    ld (hl), a
    dec hl
    ld a, (hl)
    or c
    ld (hl), a

    ld a, b
    ld bc, 17
    add hl, bc
    ld c, b
    ld b, a
    djnz routine7l
    ret

routine0:
    ld c, 16
routine0l:
    ld a, (de)
    inc de

    or (hl)
    ld (hl), a

    ld a, c
    add a, l
    ld l, a
    kjp(nc, done0)
    inc h
done0:
    djnz routine0l
    ret

routine1:
    ld a, (de)
    inc de

    rra
    rr c
    or (hl)
    ld (hl), a
    inc hl
    ld a, (hl)
    or c
    ld (hl), a

    ld a, b
    ld bc, 15
    add hl, bc
    ld c, b
    ld b, a
    djnz routine1
    ret

routine2:
    ld a, (de)
    inc de

    rrca
    rrca
    ld c, a
    and 0x3F
    or (hl)
    ld (hl), a
    ld a, c
    and 0xC0
    inc hl
    or (hl)
    ld (hl), a

    ld a, 15
    add a, l
    ld l, a
    kjp(nc, done2)
    inc h
done2:
    djnz routine2
    ret

routine3:
    ld a, (de)
    inc de

    rrca
    rrca
    rrca
    ld c, a
    and 0x1F
    or (hl)
    ld (hl), a
    ld a, c
    and 0xE0
    inc hl
    or (hl)
    ld (hl), a

    ld a, 15
    add a, l
    ld l, a
    kjp(nc, done3)
    inc h
done3:
    djnz routine3
    ret

routine4:
    ld a, (de)
    inc de

    rrca
    rrca
    rrca
    rrca
    ld c, a
    and 0x0F
    or (hl)
    ld (hl), a
    ld a, c
    and 0xF0
    inc hl
    or (hl)
    ld (hl), a

    ld a, 15
    add a, l
    ld l, a
    kjp(nc, done4)
    inc h
done4:
    djnz routine4
    ret

routine6:
    ld a, (de)
    inc de

    rlca
    rlca
    ld c, a
    and 0x03
    or (hl)
    ld (hl), a
    ld a, c
    and 0xFC
    inc hl
    or (hl)
    ld (hl), a

    ld a, 15
    add a, l
    ld l, a
    kjp(nc, done6)
    inc h
done6:
    djnz routine6
    ret
                           
routine5:
    ld a, (de)
    inc de

    rlca
    rlca
    rlca
    ld c, a
    and 0x07
    or (hl)
    ld (hl), a
    ld a, c
    and 0xF8
    inc hl
    or (hl)
    ld (hl), a

    ld a, 15
    add a, l
    ld l, a
    kjp(nc, done5)
    inc h
done5:
    djnz routine5
    ret
