;##################################################################
;
;   Phoenix-Z80 (Collisions between player and other objects)
;
;   Programmed by Patrick Davidson (pad@calc.org)
;        
;   Copyright 2005 by Patrick Davidson.  This software may be freely
;   modified and/or copied with no restrictions.  There is no warranty.
;
;   This file was last updated November 25, 2005.
;
;##################################################################     

hit_companion:
    kld(a, (companion_x))
    ld l, a
    ld h, 7
    kld((test_coords), hl)
    kld(a, (companion_y))
    ld l, a
    ld h, 7
    kld((test_coords + 2), hl)
    ld c, 1
    jr player_hit_scan

hit_player:
    kld(a, (player_x))
    ld l, a
    ld h, 8
    kld((test_coords), hl)
    kld(a, (player_y))
    ld l, a
    ld h, 6
    kld((test_coords + 2), hl)

;############## Enemy bullet scanning loop

    ld c, 0
player_hit_scan:
    kld(hl, eb_array)         ; HL -> enemy bullet to check
    ld b, eb_num
loop_player_hit_scan:
    ld a, (hl)              ; Check if this bullet exists
    or a
    kjp(z, no_ebullet_here)
    kjp(m, no_ebullet_here)

    push hl
    inc hl
    inc hl                  ; HL -> X coordinate of bullet

    kcall(collision_check)     ; Does it collide?
    kjp(nc, no_player_collision)

;############## Collision handling
    pop hl
    push hl

    ld (hl), -5             ; enemy bullet type to -5

    inc hl
    ld a, (hl)              ; A = damage amount
    or a
    kjp(z, money)

    ld e, a                 ; E = damage amount

    xor a
    ld (hl), a              ; phase in explosion -> 0

    inc hl                  ; shift X and Y
    dec (hl)
    dec (hl)
    dec (hl)
    inc hl
    inc hl
    dec (hl)
    dec (hl)

    bit 0, c
    jr nz, did_hit_companion
    
    kld(a, (player_pwr))
    sub e
    kld((player_pwr), a)

    kjp(c, game_lose)
    jr no_player_collision

did_hit_companion:
    kld(a, (companion_pwr))
    sub e
    kld((companion_pwr), a)

    dec a
    bit 7, a
    jr z, no_player_collision

    ld a, -1
    kld((companion_pwr), a)
    kld(hl, x1)
    kld((companion_img), hl)

;############## of collision handling

no_player_collision:
    pop hl

no_ebullet_here:
    ld de, eb_size          ; Next bullet in array
    add hl, de
    djnz loop_player_hit_scan
    ret
    ld hl, eb_array

;############## Money collection

money:
    dec hl
    xor a
    ld (hl), a
    kld(hl, (player_cash))
    kld(a, (money_amount))
    add a, l \ ld l, a \ jr nc, $+3 \ inc h
    ld de, 9901
    kcall(DO_CP_HL_DE)
    jr nc, cash_overflow
    kld((player_cash), hl)

    push bc
    kld(hl, decimal_cash + 1)
    kld(de, decimal_amount + 1)
    kcall(ADD_BCD)
    pop bc
    jr no_player_collision

cash_overflow:
    ld hl, 9900
    kld((player_cash), hl)
    ld hl, 0x0099
    kld((decimal_cash), hl)
    jr no_player_collision

;############## Losing the game

game_lose:
    pcall(exitThread)
    ; TODO
    ;call no_high_score
    ;jp game_exit
