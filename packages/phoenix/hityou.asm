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
        ld      a,(companion_x)
        ld      l,a
        ld      h,7
        ld      (test_coords),hl
        ld      a,(companion_y)
        ld      l,a
        ld      h,7
        ld      (test_coords+2),hl
        ld      c,1
        jr      player_hit_scan

hit_player:
        ld      a,(player_x)
        ld      l,a
        ld      h,8
        ld      (test_coords),hl
        ld      a,(player_y)
        ld      l,a
        ld      h,6
        ld      (test_coords+2),hl

;############## Enemy bullet scanning loop

        ld      c,0
player_hit_scan:
        ld      hl,eb_array         ; HL -> enemy bullet to check
        ld      b,eb_num
loop_player_hit_scan:
        ld      a,(hl)              ; Check if this bullet exists
        or      a
        jr      z,no_ebullet_here
        jp      m,no_ebullet_here

        push    hl
        inc     hl
        inc     hl                  ; HL -> X coordinate of bullet

        call    collision_check     ; Does it collide?
        jr      nc,no_player_collision

;############## Collision handling

        pop     hl
        push    hl

        ld      (hl),-5             ; enemy bullet type to -5

        inc     hl
        ld      a,(hl)              ; A = damage amount
        or      a
        jr      z,money

        ld      e,a                 ; E = damage amount

        xor     a
        ld      (hl),a              ; phase in explosion -> 0

        inc     hl                  ; shift X and Y
        dec     (hl)
        dec     (hl)
        dec     (hl)
        inc     hl
        inc     hl
        dec     (hl)
        dec     (hl)

        bit     0,c
        jr      nz,did_hit_companion
        
        ld      a,(player_pwr)
        sub     e
        ld      (player_pwr),a

        jr      c,game_lose
        jr      no_player_collision

did_hit_companion:
        ld      a,(companion_pwr)
        sub     e
        ld      (companion_pwr),a

        dec     a
        bit     7,a
        jr      z,no_player_collision

        ld      a,-1
        ld      (companion_pwr),a
        ld      hl,x1
        ld      (companion_img),hl

;############## End of collision handling

no_player_collision:
        pop     hl

no_ebullet_here:
        ld      de,eb_size          ; Next bullet in array
        add     hl,de
        djnz    loop_player_hit_scan

        ret

;############## Money collection

money:  dec     hl
        xor     a
        ld      (hl),a
        ld      hl,(player_cash)
        ld      a,(money_amount)
        call    ADD_HL_A
        ld      de,9901
        call    DO_CP_HL_DE
        jr      nc,cash_overflow
        ld      (player_cash),hl

        push    bc
        ld      hl,decimal_cash+1
        ld      de,decimal_amount+1
        call    ADD_BCD         
        pop     bc
        jr      no_player_collision

cash_overflow:
        ld      hl,9900
        ld      (player_cash),hl
        ld      hl,$0099
        ld      (decimal_cash),hl
        jr      no_player_collision

;############## Losing the game

game_lose:
        call    no_high_score
        jp      game_exit
