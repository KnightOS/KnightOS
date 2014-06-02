;##################################################################
;
;   Phoenix-Z80 (Player firing)
;
;   Programmed by Patrick Davidson (pad@calc.org)
;        
;   Copyright 2011 by Patrick Davidson.  This software may be freely
;   modified and/or copied with no restrictions.  There is no warranty.
;
;   This file was last updated June 2, 2011.
;
;##################################################################

;############## Main shooting routine

player_shoot:
        ld      a,(chosen_weapon)
        or      a
        jr      z,player_shoot_1
        dec     a
        jr      z,player_shoot_2
        dec     a
        jr      z,player_shoot_3
        dec     a
        jr      z,player_shoot_4

player_shoot_5:
        ld      hl,33*256+20
        ld      b,$57
        ld      a,(weapon_5)
        xor     2
        ld      (weapon_5),a
        rrca
        and     1
        inc     a
        ld      c,a
        call    fire_bullet

        ld      hl,36*256+8
        ld      bc,$44fe
        call    fire_bullet

        ld      h,39
        ld      c,6
        jr      fire_bullet

player_shoot_4:
        ld      a,(weapon_4)    ; alternate firing from left/right side
        xor     128
        ld      (weapon_4),a
        ld      a,0
        jp      m,ps4l
        ld      a,7
ps4l:
        ld      c,a
        ld      hl,24*256+8
        ld      b,$35
        call    fire_bullet     ; left aimed bullet

        dec     c
        dec     c
        ld      h,27
        jr      fire_bullet     ; right aimed bullet

player_shoot_3:
        ld      hl,21*256+4
        ld      bc,$4402
        call    fire_bullet

        ld      hl,15*256+3
        ld      c,0
        call    fire_bullet

        ld      h,18
        ld      c,4
        jr      fire_bullet

player_shoot_2:
        ld      hl,9*256+2
        ld      bc,$37ff
        call    fire_bullet

        ld      hl,12*256+2
        ld      c,6
        jr      fire_bullet

player_shoot_1:
        ld      a,(weapon_upgrade)
        or      a
        jr      nz,shoot_enhanced
        ld      hl,6*256+2
        ld      bc,$2603
        jr      fire_bullet

shoot_enhanced:    
        ld      bc,$4802
        ld      hl,3*256+4

;############## Fire bullet with H = type, L = damage, B = width/height, C = X offset

fire_bullet:
        push    bc
        push    hl
        ld      hl,pb_array            ; Locate unused bullet in HL
        ld      b,pb_num
        ld      de,pb_size
loop_search_bullet:
        ld      a,(hl)
        or      a
        jr      z,found_bullet
        add     hl,de
        djnz    loop_search_bullet
        pop     de
        pop     bc
        ret

found_bullet:
        pop     de
        pop     bc

;############## Copy bullet data, D = type, E = damage, B = width/height, HL->data, C = X offset

bullet_copy:
        ld      (hl),d                  ; Type
        inc     hl 
        ld      (hl),e                  ; Amount of damage
        inc     hl                       
        ld      a,(player_x)
        add     a,c
        ld      (hl),a                  ; X-coordinate
        inc     hl
        ld      a,b
        rra
        rra
        rra
        rra
        and     15
        ld      (hl),a                  ; Width
        inc     hl
        ld      a,(player_y)
        add     a,-3
        ld      (hl),a                  ; Y-coordinate
        inc     hl
        ld      a,b
        and     15
        ld      (hl),a                  ; Height
        inc     hl
        inc     hl
        inc     hl
        ld      (hl),7                  ; Data
        ret
