;##################################################################
;
;   Phoenix-82 (Screen display routines)
;
;   Programmed by Patrick Davidson (pad@calc.org)
;        
;   Copyright 2008 by Patrick Davidson.  This software may be freely
;   modified and/or copied with no restrictions.  There is no warranty.
;
;   This file was last updated September 9, 2008.
;
;##################################################################   

;############## Show information panel

display_money:
        ld      de,GFX_AREA+$3b3
        ld      a,(player_x)
        cp      60
        jr      nc,left_side
        ld      de,GFX_AREA+$3bb
left_side:
        ld      hl,decimal_cash
        jp      display_number_bcd

;############## Display -1 terminated list of strings at (HL)

display_hl_msgs:
        push    hl
        ROM_CALL(CLEARLCD)
        pop     hl
        ld      de,0
show_loop:
        ld      (CURSOR_ROW),de
        push    de
        ROM_CALL(D_ZT_STR)
        pop     de
        ld      a,(hl)
        inc     a
        ret     z
        inc     e
        jr      show_loop

;############## Prepares on-screen shield indicator

prepare_indicator:
        ld      a,(player_pwr)
        or      a
        ret     z
        ret     m
        ld      b,a
        ld      hl,GFX_AREA+1024-3
        ld      de,-16
loop_ind:
        set     0,(hl)
        add     hl,de
        set     0,(hl)
        add     hl,de
        set     0,(hl)
        add     hl,de
        set     0,(hl)
        add     hl,de
        djnz    loop_ind
        ret

;############## Display sides over the screen
	
render_sides:
        ld      a,(sides_flag)
        or      a
        ret     z

        ld      hl,leftside
        ld      de,MIN_Y
        call    drw_spr

        ld      hl,rightside
        ld      de,MIN_Y+(120<<8)
        jp      drw_spr

;############## Clears screen buffer

clear_buffer:
        ld      (smc_savesp+1),sp
        ld      hl,0
        ld      sp,GFX_AREA+1024
        ld      b,63
loop_super_clear:
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        djnz    loop_super_clear
smc_savesp:
        ld      sp,0

        ld      hl,GFX_AREA+2
        ld      bc,11
        jp      OTH_CLEAR

;############## Initialize side data

set_up_sides:
        ld      a,1
        ld      (leftsidevel),a
        inc     a
        ld      (leftsidecoord),a
        ld      (rightsidecoord),a
        ld      a,-1
        ld      (rightsidevel),a
        ld      b,64
loop_sus:
        push    bc
        call    scroll_sides
        pop     bc
        djnz    loop_sus
        ret

;############## Scroll the sides down one pixel 
        
scroll_sides:
        ld      de,rightside+$41
        ld      hl,rightside+$40
        ld      bc,$40
        lddr

        dec     hl
        dec     hl
        dec     de
        dec     de
        ld      bc,$40
        lddr

        ld      hl,rightsidecoord
        call    scroll_side
        ld      hl,rightsidetable
        call    ADD_HL_A
        ld      a,(hl)
        ld      (rightside+2),a
	
        ld      hl,leftsidecoord
        call    scroll_side
        ld      hl,leftsidetable
        call    ADD_HL_A
        ld      a,(hl)
        ld      (leftside+2),a
        ret

;############## Calculate new position of side at (HL) 
        
scroll_start:
        ld      (hl),1
        call    FAST_RANDOM
        add     a,a
        jr      c,scroll_adjust_done
        ld      (hl),-1
        jr      scroll_adjust_done        
        
scroll_side:
        call    FAST_RANDOM
        and     7
        jr      nz,nosiderand
        inc     hl
        ld      a,(hl)
        or      a
        jr      z,scroll_start
        ld      (hl),0
scroll_adjust_done:
        dec     hl
nosiderand:     
        ld      a,(hl)
        inc     hl
        add     a,(hl)
	jr      nz,noforceli
        ld      (hl),1
noforceli:
        cp      8
        jr      nz,noforceld
        ld      (hl),-1
noforceld:      
        dec     hl
        ld      (hl),a
        ret

rightsidetable:
        .db     %00000000
        .db     %00000000
        .db     %00000100
        .db     %00001100
        .db     %00011100
        .db     %00111100
        .db     %01111100
        .db     %11111100
        .db     %11111100

leftsidetable:
        .db     %00000000
        .db     %10000000
        .db     %11000000
        .db     %11100000
        .db     %11110000
        .db     %11111000
        .db     %11111100
        .db     %11111110
        .db     %11111111
	
;############## Display entire screen from buffer

#define DWAIT in a,($10) \ and %10010000 \ jr nz, $-4

display_screen:
        ld      a,(invert)
        or      a
        ld      a,$2f                   ; A = CPL
        jr      nz,ds_inverted
        xor     a                       ; A = NOP
ds_inverted:
        ld      (smc_invert),a

        ld      a,$80
        out     ($10),a
        ld      hl,GFX_AREA+2
        ld      c,$20
dispColumn:
        DWAIT
        ld      a,c
        out     ($10),a
        cp      $2c
        ret     z
        ld      b,64
        ld      de,16
dispByte:
        DWAIT
        ld      a,(hl)
smc_invert:
        cpl                            ; invert or not depending on smc
        out     ($11),a
        add     hl,de
        djnz    dispByte
        ld      de,-1023
        add     hl,de
        inc     c
        jr      dispColumn
