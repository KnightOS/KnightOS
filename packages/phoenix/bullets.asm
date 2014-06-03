;##################################################################
;
;   Phoenix-Z80 (Player bullet code)
;
;   Programmed by Patrick Davidson (pad@calc.org)
;        
;   Copyright 2001 by Patrick Davidson.  This software may be freely
;   modified and/or copied with no restrictions.  There is no warranty.
;
;   This file was last updated April 1, 2001.
;
;##################################################################     

;############## Player bullet routine
;
; Calls the code specified by the bullet 'type'.  The 'type', which must
; be a multiple of 3, is an index into the table of jumps for bullet code.
; Bullet routines should move the bullet and draw its image.  They are
; called with HL pointing to the bullet entry, and can change all registers.

player_bullets:
    kld(hl, pb_array)
    ld b, pb_num
loop_player_bullets:
    ld a, (hl)
    ; NOTE: This keeps compatability with existing Phoenix levels
    ; We might be able to skip this step if we relocate the jump table manually.
    ; Kernel support might be called for here, considering that libraries do this
    ; exact procedure themselves.
    ; The purpose of this code is to change A from a multiple of 3 to a multiple
    ; of 4, since jp is a 3-byte instruction and kjp is 4 bytes.
    push de
        ; A /= 3
        ld d, a
        ld e, 3
        pcall(div8by8)
        ld a, d
        ; A *= 4
        sla a \ sla a
    pop de
    ; /end NOTE
    kld((do_player_bullet + 1), a) ; SMC
    push hl
    push bc
    kcall(do_player_bullet)
    pop bc
    pop hl
    ld de, pb_size
    add hl, de
    djnz loop_player_bullets
    ret

do_player_bullet:
    jr point_to_pbullet_code
point_to_pbullet_code:

;############## Bullet routine table starts here

no_pbullet:
    ld (hl), 0
    ret \ nop
    kjp(enhanced_bullet)           ;3
    kjp(standard_bullet)           ;6
    kjp(double_left)               ;9
    kjp(double_right)              ;12
    kjp(triple_right)              ;15
    kjp(triple_left)               ;18
    kjp(triple_center)             ;21
    kjp(quad_left)                 ;24
    kjp(quad_right)                ;27
    kjp(quad_goup)                 ;30
    kjp(super_shot)                ;33
    kjp(swing_left)                ;36

;############## Swinging right bullet

swing_right:
    push hl

    inc hl
    inc hl
    dec (hl)
    jr z, destroy_bullet_stack

    jr swing_common

;############## Swinging left bullet

swing_left:
    push hl

    inc hl
    inc hl
    inc (hl)
    ld a, 124
    cp (hl)
    jr z, destroy_bullet_stack

swing_common:
    ld de, 6
    add hl, de
    dec (hl)
    ld a, (hl)
    sra a
    pop hl

    kld(bc, img_quad_bullet)
    jr common_bullet

destroy_bullet_stack:
    pop hl
    ld (hl), 0
    ret

;############## Super-powered bullet

super_shot:
    ld a, -5
    kld(bc, img_player_bullet_5)
    jr common_bullet

;############## Companion ship's weapons

companion_shots:
quad_goup:
    ld a, -4
    kld(bc, img_quad_bullet)
    jr common_bullet

;############## Quadruple shot right

quad_right:
    kld(a, (game_timer))
    rrca
    jr c, quad_goup
    inc hl
    inc hl
    inc (hl)
    ld a, (hl)
    cp 124
    jr quad_x_updated

;############## Quadruple shot left

quad_left:
    kld(a, (game_timer))
    rrca
    jr c, quad_goup
    inc hl
    inc hl
    dec (hl)
    ld a, (hl)
    or a

quad_x_updated:
    ld d, a
    ld a, -4
    kld(bc, img_quad_bullet)
    jr nz, common_after_x_done
    jr destroy_bullet_x

;############## Triple shot center

triple_center:
    ld a, -5
    kld(bc, img_player_bullet_3)
    jr common_bullet

;############## Double shot right side

double_right:
    ld a, -4
    kld(bc, img_player_bullet_2r)
    jr common_bullet

;############## Double shot left side

double_left:
    ld a, -4
    kld(bc, img_player_bullet_2l)
    jr common_bullet

;############## Standard bullet

standard_bullet:
    kld(bc, img_player_bullet_0)
    jr common_bullet_2

;############## Enhanced bullet

enhanced_bullet:
    kld(bc, img_player_bullet_1)
common_bullet_2:
    ld a, -2
common_bullet:
    inc hl
    inc hl
    ld d, (hl)
common_after_x_done:
    inc hl
    inc hl
    add a, (hl)
    cp 24
    jr c, destroy_bullet
    ld e, a
    ld (hl), e
    push bc
    pop hl
    kjp(drw_spr)

destroy_bullet:
    ld bc, -4
    add hl, bc
    ld (hl), 0
    ret

;############## Triple shot right side

triple_right:
    inc hl
    inc hl
    ld d, (hl)
    dec d
    jr z, destroy_bullet_x
    dec d
    jr z, destroy_bullet_x
common_triple:
    ld (hl), d
    ld a, -4
    kld(bc, img_player_bullet_3)
    jr common_after_x_done

destroy_bullet_x:
    dec hl
    dec hl
    ld (hl),0
    ret

;############## Triple shot left side

triple_left:
    inc hl
    inc hl
    ld a, (hl)
    add a, 2
    ld d, a
    cp 124
    jr nc, destroy_bullet_x
    jr common_triple
