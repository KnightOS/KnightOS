;##################################################################
;
;   Phoenix-Z80 (Companion ship)
;
;   Programmed by Patrick Davidson (pad@calc.org)
;        
;   Copyright 2001 by Patrick Davidson.  This software may be freely
;   modified and/or copied with no restrictions.  There is no warranty.
;
;   This file was last updated March 31, 2001.
;
;##################################################################     

do_companion:
        ld      a,(companion_pwr)
        or      a
        jp      m,companion_explode
        ret     z

        call    hit_companion

        ld      de,posqueue             ; Move up ship position history
        ld      hl,posqueue+2
        ld      bc,20
        ldir

        call    companion_dest         ; Calculate destination of companion
        call    companion_move         ; Move
        call    companion_shoot

        ld      de,(companion_y)
        ld      hl,img_companion
        jp      drw_spr

;############## Exploding companion ship

companion_explode:
        ld      hl,(companion_img)
        ld      a,(game_timer)
        rrca
        jr      c,no_new_image
        ld      bc,8
        add     hl,bc
        ld      (companion_img),hl
no_new_image:
        ld      a,(hl)
        add     a,a
        ld      de,(companion_y)
        jp      nc,drw_spr
        xor     a
        ld      (companion_pwr),a
        ret

;############## Calculation of destination at tail of queue

companion_dest:
        ld      hl,posqueue
        dec     (hl)
        inc     hl

        ld      a,(hl)
        cp      60
        jr      c,companion_left
companion_right:
        sub     10
        ld      (hl),a
        ret

companion_left:
        add     a,11
        ld      (hl),a
        ret

;############## Movement of companion towards destination

companion_move:
        ld      hl,companion_y
        ld      a,(posqueue)
        cp      (hl)
        jr      z,companion_movedy
        jr      nc,companion_moveyd
        dec     (hl)
        jr      companion_movedy
companion_moveyd:
        inc     (hl)
companion_movedy:
        inc     hl
        ld      a,(posqueue+1)
        cp      (hl)
        ret     z
        jr      nc,companion_movexr
        dec     (hl)
        ret
companion_movexr:
        inc     (hl)
        ret

;############## Companion shooting, every 8 frames

companion_shoot:
        ld      a,(game_timer)
        and     7
        ret     nz

        ld      hl,pb_array            ; Locate unused bullet in HL
        ld      b,pb_num
        ld      de,pb_size
comp_search_bullet:
        ld      a,(hl)
        or      a
        jr      z,comp_found_bullet
        add     hl,de
        djnz    comp_search_bullet
        ret

comp_found_bullet:
        ld      (hl),30                 ; Type
        inc     hl
        ld      (hl),10                 ; Amount of damage
        inc     hl
        ld      a,(companion_x)
        add     a,2
        ld      (hl),a                  ; X coordinate
        inc     hl
        ld      (hl),3                  ; width
        inc     hl
        ld      a,(companion_y)
        sub     5
        ld      (hl),a                  ; Y coordinate
        inc     hl
        ld      (hl),5                  ; height
        ret
