;##################################################################
;
;   Phoenix-Z80 (Enemy bullets)
;
;   Programmed by Patrick Davidson (pad@calc.org)
;        
;   Copyright 2002 by Patrick Davidson.  This software may be freely
;   modified and/or copied with no restrictions.  There is no warranty.
;
;   This file was last updated June 23, 2002.
;
;##################################################################     

;############## Enemy bullet routine
;
; Calls the code specified by the bullet 'type'.  The 'type', which must
; be a multiple of 3, is an index into the table of jumps for bullet code.
; Bullet routines should move the bullet and draw its image.  They are
; called with HL pointing to the bullet entry, and can change all registers.

enemy_bullets:
    kld(hl, eb_array)
    ld b, eb_num
loop_enemy_bullets:
    ld a, (hl)
    cp -5
    jr c, _
    ld a, -6
    jr ++_
    ; NOTE: This keeps compatability with existing Phoenix levels
    ; We might be able to skip this step if we relocate the jump table manually.
    ; Kernel support might be called for here, considering that libraries do this
    ; exact procedure themselves.
    ; The purpose of this code is to change A from a multiple of 3 to a multiple
    ; of 4, since jp is a 3-byte instruction and kjp is 4 bytes.
_:  push de
        ; A /= 3
        ld d, a
        ld e, 3
        pcall(div8by8)
        ld a, d
        ; A *= 4
        sla a \ sla a
    pop de
    ; /end NOTE
_:  kld((do_enemy_bullet + 1), a) ; SMC
    push hl
    push bc
    kcall(do_enemy_bullet)
    pop bc
    pop hl
    ld de, eb_size
    add hl, de
    djnz loop_enemy_bullets
    ret

    kjp(exploding) ; Part of the no_ebullet table
do_enemy_bullet:
    jr point_to_ebullet_code    ; Updated via SMC
point_to_ebullet_code:

;############## Enemy bullet routine table starts here

no_ebullet:
    nop \ nop \ nop \ ret

    kjp(std_ebullet)            ; 4
    kjp(bonus_ebullet)          ; 8
    kjp(left_ebullet)           ; 12
    kjp(right_ebullet)          ; 16
    kjp(half_left_ebullet)      ; 20
    kjp(half_right_ebullet)     ; 24
    kjp(arrow_bullet)           ; 28
    nop \ nop \ nop \ nop       ; 32
    nop \ nop \ nop \ nop       ; 36
    kjp(big_ebullet)            ; 40
    nop \ nop \ nop \ nop       ; 44
    nop \ nop \ nop \ nop       ; 48
    nop \ nop \ nop \ nop       ; 52
    ;kjp(huge_ebullet)          ; 56

;############## Huge bullets

huge_ebullet:
    push hl

    sub 33
    kcall(table_look_up)
    ld e, (hl)
    inc hl
    ld a, (hl)

    kld(bc, img_eb_4)
    jr main_large_ebullet

big_ebullet:
    push hl

    sub 24
    kcall(table_look_up)

    ld a, (hl)
    kcall(div_by_2)
    ld e, a                     ; E = adjusted Y velocity
    inc hl
    ld a, (hl)
    kcall(div_by_2)                ; A = adjusted X velocity

    kld(bc, img_eb_3)

main_large_ebullet:
    pop hl

    inc hl
    inc hl
    add a, (hl)
    kjp(m, destroy_ebullet_x)
    cp 128
    jr nc, destroy_ebullet_x
    ld (hl), a
    ld d, a                     ; D = final X coordinate

    inc hl
    inc hl
    ld a, e
    add a, (hl)
    cp 96
    jr nc, destroy_ebullet
    ld (hl), a
    ld e, a

    ld h, b
    ld l, c
    kjp(drw_spr)

speed_table:
    .db 1, -2
    .db 2, -2
    .db 2, -1
    .db 2, 0
    .db 2, 1
    .db 2, 2
    .db 1, 2

div_by_2:
    ; Note that this does not just divide A by 2, that'd be stupid
    sra a
    ret nc
    kld(bc, (game_timer))
    rr c
    ret nc
    inc a
    ret

destroy_ebullet:
    ld de, -4
    add hl, de
    ld (hl), 0
    ret

;############## Arrow enemy bullet

arrow_bullet:
    inc hl
    inc hl
    ld d, (hl)
    inc hl
    inc hl
    inc (hl)
    ld e, (hl)
    ld a, 96
    sub e
    jr z, destroy_ebullet
    kld(hl, img_eb_2)
    kjp(drw_spr)

;############## Bullet moving half right

half_right_ebullet:
    kld(a, (game_timer))
    rra
    jr c, right_ebullet
    jr std_ebullet

;############## Bullet moving half left

half_left_ebullet:
    ld a, (game_timer)
    rra
    jr c, left_ebullet
    jr std_ebullet

;############## Bullet moving right

right_ebullet:
    inc hl
    inc hl
    inc (hl)
    ld a, 126
    cp (hl)
    jr decide_ebullet

;############## Bullet moving left

left_ebullet:
    inc hl
    inc hl
    dec (hl)
decide_ebullet:
    jr z, destroy_ebullet_x
    jr common_ebullet

;############## Standard enemy bullet

std_ebullet:
    inc hl
    inc hl
common_ebullet:
    ld d, (hl)
    inc hl
    inc hl
    inc (hl)
    ld e, (hl)
    ld a, 96
    sub e
    jr z, destroy_ebullet
    kld(hl, img_eb_1)
    kjp(drw_spr)

destroy_ebullet_x:
    dec hl
    dec hl
    ld (hl), 0
    ret

;############## Falling bonus

bonus_ebullet:
    inc hl
    inc hl
    ld d, (hl)
    inc hl
    inc hl
    kld(a, (game_timer))
    rra
    jr c, no_fall_bonus
    inc (hl)
no_fall_bonus:
    ld e, (hl)
    ld a, 96
    sub e
    jr z, destroy_ebullet
    kld(hl, img_money)
    kjp(drw_spr)

;############## Explosion

exploding:
    push hl
    inc hl
    kld(a, (game_timer))
    rrca
    jr c, no_next_step
    inc (hl)

no_next_step:
    ld b, (hl)
    inc hl                      ; HL -> e_x     
    ld d, (hl)                  ; D = X
    inc hl
    inc hl                      ; HL -> e_y
    ld e, (hl)                  ; E = Y

    kld(hl, x1) ; x1 is the explosion sprite's first frame
    ld a, b
    add a, a
    add a, a
    add a, a
    add a, l \ ld l, a \ jr nc, $+3 \ inc h

    ld a, (hl)
    inc a
    jr z, end_of_explosion      ; -1 -> end of list

    pop bc                      ; Restore stacl
    kjp(drw_spr)

end_of_explosion:
    pop hl
    ld (hl), a
    ret
