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
        ld      hl,eb_array
        ld      b,eb_num
loop_enemy_bullets:
        ld      a,(hl)
        ld      (do_enemy_bullet+1),a
        push    hl
        push    bc
        call    do_enemy_bullet
        pop     bc
        pop     hl
        ld      de,eb_size
        add     hl,de
        djnz    loop_enemy_bullets
        ret

        jp      exploding               ; This is offset -5
do_enemy_bullet:
        jr      point_to_ebullet_code
point_to_ebullet_code:

;############## Enemy bullet routine table starts here

no_ebullet:
        ;ld      (hl),0
        nop
        nop
        ret

        jp      std_ebullet            ;3
        jp      bonus_ebullet          ;6
        jp      left_ebullet           ;9
        jp      right_ebullet          ;12
        jp      half_left_ebullet      ;15
        jp      half_right_ebullet     ;18
        jp      arrow_bullet           ;21
        nop                            ;24
        nop                            ;25
        nop                            ;26
        nop                            ;27
        nop                            ;28
        nop                            ;29
        jp      big_ebullet            ;30
        nop                            ;33
        nop                            ;34
        nop                            ;35
        nop                            ;36
        nop                            ;37
        nop                            ;38
       ; jp      huge_ebullet           ;39

;############## Huge bullets

huge_ebullet:
        push    hl

        sub     33
        call    table_look_up
        ld      e,(hl)
        inc     hl
        ld      a,(hl)

        ld      bc,img_eb_4
        jr      main_large_ebullet

big_ebullet:
        push    hl

        sub     24
        call    table_look_up

        ld      a,(hl)
        call    div_by_2
        ld      e,a                     ; E = adjusted Y velocity
        inc     hl
        ld      a,(hl)
        call    div_by_2                ; A = adjusted X velocity

        ld      bc,img_eb_3

main_large_ebullet:
        pop     hl

        inc     hl
        inc     hl
        add     a,(hl)
        jp      m,destroy_ebullet_x
        cp      128
        jr      nc,destroy_ebullet_x
        ld      (hl),a
        ld      d,a                     ; D = final X coordinate

        inc     hl
        inc     hl
        ld      a,e
        add     a,(hl)
        cp      96
        jr      nc,destroy_ebullet
        ld      (hl),a
        ld      e,a

        ld      h,b
        ld      l,c
        jp      drw_spr

speed_table:
        .db     1,-2
        .db     2,-2
        .db     2,-1
        .db     2,0
        .db     2,1
        .db     2,2
        .db     1,2

div_by_2:
        sra     a
        ret     nc
        ld      bc,(game_timer)
        rr      c
        ret     nc
        inc     a
        ret

destroy_ebullet:
        ld      de,-4
        add     hl,de
        ld      (hl),0
        ret

;############## Arrow enemy bullet

arrow_bullet:
        inc     hl
        inc     hl
        ld      d,(hl)
        inc     hl
        inc     hl
        inc     (hl)
        ld      e,(hl)
        ld      a,96
        sub     e
        jr      z,destroy_ebullet
        ld      hl,img_eb_2
        jp      drw_spr

;############## Bullet moving half right

half_right_ebullet:
        ld      a,(game_timer)
        rra
        jr      c,right_ebullet
        jr      std_ebullet

;############## Bullet moving half left

half_left_ebullet:
        ld      a,(game_timer)
        rra
        jr      c,left_ebullet
        jr      std_ebullet

;############## Bullet moving right

right_ebullet:
        inc     hl
        inc     hl
        inc     (hl)
        ld      a,126
        cp      (hl)
        jr      decide_ebullet

;############## Bullet moving left

left_ebullet:
        inc     hl
        inc     hl
        dec     (hl)
decide_ebullet:
        jr      z,destroy_ebullet_x
        jr      common_ebullet

;############## Standard enemy bullet

std_ebullet:
        inc     hl
        inc     hl
common_ebullet:
        ld      d,(hl)
        inc     hl
        inc     hl
        inc     (hl)
        ld      e,(hl)
        ld      a,96
        sub     e
        jr      z,destroy_ebullet
        ld      hl,img_eb_1
        jp      drw_spr

destroy_ebullet_x:
        dec     hl
        dec     hl
        ld      (hl),0
        ret

;############## Falling bonus

bonus_ebullet:
        inc     hl
        inc     hl
        ld      d,(hl)
        inc     hl
        inc     hl
        ld      a,(game_timer)
        rra
        jr      c,no_fall_bonus
        inc     (hl)
no_fall_bonus:
        ld      e,(hl)
        ld      a,96
        sub     e
        jr      z,destroy_ebullet
        ld      hl,img_money
        jp      drw_spr

;############## Explosion

exploding:
        push    hl
        inc     hl
        ld      a,(game_timer)
        rrca
        jr      c,no_next_step
        inc     (hl)

no_next_step:
        ld      b,(hl)
        inc     hl                      ; HL -> e_x     
        ld      d,(hl)                  ; D = X
        inc     hl
        inc     hl                      ; HL -> e_y
        ld      e,(hl)                  ; E = Y

        ld      hl,x1
        ld      a,b
        add     a,a
        add     a,a
        add     a,a
        call    ADD_HL_A                ; HL -> explosion image

        ld      a,(hl)
        inc     a
        jr      z,end_of_explosion      ; -1 -> end of list

        pop     bc                      ; Restore stacl
        jp      drw_spr      

end_of_explosion:
        pop     hl
        ld      (hl),a
        ret
