;##################################################################
;
;   Phoenix-Z80 (Enemies)
;
;   Programmed by Patrick Davidson (pad@calc.org)
;        
;   Copyright 2003 by Patrick Davidson.  This software may be freely
;   modified and/or copied with no restrictions.  There is no warranty.
;
;   This file was last updated February 11, 2003.
;
;##################################################################     

;############## Enemy handling
;
; Iterates through the array of enemies, processing each one.

enemies:
        xor     a                       ;Reset list of used swoop patterns
        ld      (misc_flags),a          ;(used to prevent multiple entries
                                        ;of the same pattern in one frame)

        ld      hl,e_array
        ld      b,e_num
loop_enemies:
        ld      a,(hl)                  ; test if enemy exists
        or      a
        jr      z,no_enemy

        push    bc

        push    hl
        call    enemy_move              ; call movement routine
        pop     hl

        push    hl
        call    enemy_shoot             ; call firing routine
        pop     hl

        push    hl
        call    enemy_display           ; call display routine
        pop     hl

        pop     bc

no_enemy:
        ld      de,e_size
        add     hl,de
        djnz    loop_enemies
        ret

;############## Display enemy at (HL)

enemy_display:
        ld      bc,e_x
        add     hl,bc                   
        ld      d,(hl)                  ; D = X coordinate
        inc     hl
        inc     hl
        ld      e,(hl)                  ; E = Y coordinate
        inc     hl
        inc     hl
        ld      a,(hl)                  ; A = image sequence countdown
        or      a
        jr      nz,animated
        inc     hl
        call    DO_LD_HL_MHL
        jp      drw_spr_wide

animated:
        push    hl
        inc     hl
        call    DO_LD_HL_MHL            ; HL -> sprite list
        call    DO_LD_HL_MHL            ; HL -> sprite
        call    drw_spr_wide
        pop     hl

        dec     (hl)                    ; decrement countdown
        ret     nz                      ; done if not at end

        push    hl
        inc     hl
        call    DO_LD_HL_MHL            ; HL -> sprite list
        inc     hl
        inc     hl
        ld      a,(hl)                  ; A = time for next image
        inc     hl
        ex      de,hl                   ; DE -> sprite list
        pop     hl                      ; HL -> e_imageseq

        cp      -1
        jr      z,kill_enemy
        or      a
        jr      z,restart_sequence

store_new_anim_data:
        ld      (hl),a                  ; save new time
        inc     hl
        ld      (hl),e                  ; save new list pointer
        inc     hl
        ld      (hl),d
        ret

restart_sequence:
        ex      de,hl                   ; DE -> e_imageseq, HL -> sprite list
        call    DO_LD_HL_MHL            ; HL -> sprite list new position
        ld      a,(hl)                  ; A = time for next image
        inc     hl
        ex      de,hl
        jr      store_new_anim_data

kill_enemy:
        ld      de,-e_imageseq
        add     hl,de
        ld      (hl),0

        push    hl
        ld      hl,enemies_left         
        dec     (hl)                    ; decrement enemies remaining
        ld      hl,money_counter        
        dec     (hl)                    ; decrement time to next drop
        pop     hl

        ret     nz                      ; if still above zero, exit
        call    FAST_RANDOM
        and     7
        add     a,4
        ld      (money_counter),a

        ld      de,e_w
        add     hl,de                   ; HL -> e_w

;############## Deploy cash bonus (HL -> enemy Y coordinate)

deploy_bonus:
        xor     a
        ld      (smc_enemy_bullet_power+1),a
        ld      de,bonus_data
        jp      fire_enemy_bullet

bonus_data:
        .db     6
        .db     5
        .db     7
