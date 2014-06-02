;##################################################################
;
;   Phoenix-82 (Player handling)
;
;   Programmed by Patrick Davidson (pad@calc.org)
;        
;   Copyright 2005 by Patrick Davidson.  This software may be freely
;   modified and/or copied with no restrictions.  There is no warranty.
;
;   This file was last updated September 17, 2005.
;
;##################################################################     

;############## Movement, Firing (by OTH_ARROW) and ship display

do_player:
        call    OTH_ARROW
        ld      c,a

        ld      hl,fire_counter
        bit     5,c
        jr      z,player_fire
        ld      (hl),0
        jr      fire_done

player_fire:
        ld      d,4
        ld      a,(weapon_upgrade)
        or      a
        jr      nz,autofire
        ld      d,10
autofire:
        ld      a,(hl)
        or      a
        jr      z,do_shoot
        dec     (hl)
        jr      fire_done
do_shoot:
        ld      (hl),d
        push    bc
        call    player_shoot
        pop     bc
fire_done:

        ld      hl,player_y
        rr      c     
        jr      c,no_down       
        ld      a,(hl)  
        add     a,1     
        cp      90
        jr      z,no_down       
        ld      (hl),a  
no_down:
        inc     hl      
        rr      c       
        jr      c,no_left       
        ld      a,(hl)  
        add     a,-2
        cp      14
        jr      z,no_left       
        ld      (hl),a  
no_left:
        rr      c       
        jr      c,no_right      
        ld      a,(hl)  
        add     a,2
        cp      106    
        jr      z,no_right      
        ld      (hl),a  
no_right:
        ld      d,(hl)  
        dec     hl      
        rr      c       
        jr      c,no_up 
        ld      a,(hl)  
        add     a,-1     
        cp      68            
        jr      z,no_up 
        ld      (hl),a  
no_up:                                  
        ld      de,(player_y)
        ld      hl,img_player_ship_normal
        ld      a,(player_pwr)
        cp      4
        jp      nc,drw_spr
        ld      hl,img_player_ship_damaged
        jp      drw_spr

;############## Control keys (GET_KEY)

pause:  ld      hl,$0104
        ld      (CURSOR_ROW),hl
        ld      hl,pause_msg
        ROM_CALL(D_ZT_STR)
loop_pause:
        call    SUPER_GET_KEY
        cp      KEY_CODE_ENTER
        jr      nz,loop_pause
        ret

pause_msg:
        .db     "PAUSED (ENTER)",0

handle_input:
        call    SUPER_GET_KEY
        cp      KEY_CODE_ENTER
        jr      z,pause
        cp      KEY_CODE_MODE
        jp      z,game_save
        cp      KEY_CODE_DEL
        jp      z,game_exit
        cp      KEY_CODE_CLEAR
        jp      z,game_exit

        ld      hl,chosen_weapon
        cp      KEY_CODE_5
        jr      z,select_weapon_5
        cp      KEY_CODE_4
        jr      z,select_weapon_4
        cp      KEY_CODE_3
        jr      z,select_weapon_3
        cp      KEY_CODE_2
        jr      z,select_weapon_2
        sub     KEY_CODE_1
        ret     nz
        ld      (hl),a
        ret

select_weapon_2:
        ld      a,(weapon_2)
        or      a
        ret     z
        ld      (hl),a
        ret

select_weapon_3:
        ld      a,(weapon_3)    
        or      a
        ret     z
        ld      (hl),2
        ret

select_weapon_4:
        ld      a,(weapon_4)
        or      a
        ret     z
        ld      (hl),3
        ret

select_weapon_5:
        ld      a,(weapon_5)
        or      a
        ret     z
        ld      (hl),4
        ret
