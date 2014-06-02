;##################################################################
;
;   Phoenix-82 (Shop)
;
;   Programmed by Patrick Davidson (pad@calc.org)
;        
;   Copyright 2005 by Patrick Davidson.  This software may be freely
;   modified and/or copied with no restrictions.  There is no warranty.
;
;   This file was last updated November 28, 2005.
;
;##################################################################     

;############## Test for money and intialize shop screen

shop:   ld      hl,(player_cash)
        ld      a,h
        or      l
        ret     z

#ifdef __TI83__
        call    restore_memory
#endif

        ROM_CALL(CLEARLCD)
        ld      hl,0
        ld      (CURSOR_ROW),hl
        ld      hl,shopmessage
        ROM_CALL(D_ZT_STR)

        ld      a,1
        ld      (shop_item),a

;############## Shop main loop

        ld      hl,convert_to_decimal
        push    hl

shop_loop:
        call    synchronize

        ld      hl,$0B00
        ld      (CURSOR_ROW),hl
        ld      hl,(player_cash)
        ld      a,l
        or      h
        ret     z
        ROM_CALL(D_HL_DECI)
        call    show_shop_status
                
        call    SUPER_GET_KEY
        ld      hl,shop_item
        cp      KEY_CODE_DOWN
        jr      z,shop_down
        cp      KEY_CODE_UP
        jr      z,shop_up
        cp      KEY_CODE_MODE
        ret     z
        cp      KEY_CODE_DEL
        ret     z
        cp      KEY_CODE_CLEAR
        ret     z
        cp      KEY_CODE_ENTER
        call    z,shop_select
        jr      shop_loop

;############## Shop cursor movement

shop_down:
        ld      a,(hl)
        cp      7
        jr      z,shop_loop

        push    hl
        ld      l,a
        ld      h,0
        ld      (CURSOR_ROW),hl
        ld      a,' '
        ROM_CALL(TX_CHARPUT)
        pop     hl

        inc     (hl)
        ld      a,(hl)
        ld      l,a
        ld      h,0
        ld      (CURSOR_ROW),hl
        ld      a,'>'
        ROM_CALL(TX_CHARPUT)
        jr      shop_loop

shop_up:
        ld      a,(hl)
        cp      1
        jr      z,shop_loop

        push    hl
        ld      l,a
        ld      h,0
        ld      (CURSOR_ROW),hl
        ld      a,' '
        ROM_CALL(TX_CHARPUT)
        pop     hl

        dec     (hl)
        ld      a,(hl)
        ld      l,a
        ld      h,0
        ld      (CURSOR_ROW),hl
        ld      a,'>'
        ROM_CALL(TX_CHARPUT)
        jr      shop_loop

;############## Shop item purchases

item3:  ld      bc,500
        sbc     hl,bc
        ret     c

        ld      a,(companion_pwr)
        cp      16
        ret     z
        ld      (player_cash),hl
get_companion:
        ld      hl,companion_pwr
        ld      (hl),16
        inc     hl
        ld      (hl),90
        inc     hl
        ld      (hl),60
        ret

shop_select:
        ld      a,(hl)
        dec     a
        add     a,a
        ld      (shop_jump_offset+1),a
        ld      hl,(player_cash)
shop_jump_offset:
        jr      item_list
item_list:
        jr      item1
        jr      item2
        jr      item3
        jr      item4
        jr      item5
        jr      item6

item7:  ld      bc,2000
        ld      a,4
        jr      common_weapon_add

item1:  ld      bc,100
        sbc     hl,bc
        ret     c
        ld      a,(player_pwr)
        cp      16
        ret     z
        inc     a
        ld      (player_pwr),a
        ld      (player_cash),hl
        ret

item2:  ld      bc,300                  ; BC = weapon cost
        ld      a,1                     ; A = weapon # - 1
common_weapon_add:
        sbc     hl,bc                   ; HL = money left after purcahse
        ret     c                       ; if negative, can't purchase
        ex      de,hl                   ; DE = money left after purchase
        ld      (chosen_weapon),a       ; set chosen weapon to this one
        ld      hl,weapon_2-1
        call    ADD_HL_A                ; HL -> weapon purchase flag
        ld      a,(hl)
        or      a
        ret     nz                      ; exit if already purchased
        inc     (hl)                    ; flag as purchased
        ld      (player_cash),de        ; set cash to new value
        ret

item5:  ld      bc,1000
        ld      a,2
        jr      common_weapon_add

item6:  ld      bc,1250
        ld      a,3
        jr      common_weapon_add

item4:  ld      de,weapon_upgrade
        ld      a,(de)
        or      a
        ret     nz
        ld      bc,750
        sbc     hl,bc
        ret     c
        ld      (player_cash),hl
        inc     a
        ld      (de),a
        ret

;############## Display the shield bar

show_shop_status:
        call    set_position
        ld      hl,GRAPH_MEM
        ld      b,64
        in      a,($11)
loop_read_dc:
        call    waste_time
        in      a,($11)
        ld      (hl),a
        inc     hl
        djnz    loop_read_dc

        ld      a,(player_pwr)
        or      a
        ret     z
        ret     m
        add     a,a
        add     a,a
        ld      b,a
        ld      hl,GFX_AREA+63
loop_ind_shop:
        set     0,(hl)
        dec     hl
        djnz    loop_ind_shop

        call    set_position
        ld      hl,GRAPH_MEM
        ld      b,64
loop_write_dc:
        call    waste_time
        ld      a,(hl)
        out     ($11),a
        inc     hl
        djnz    loop_write_dc
        ret

set_position:
        call    waste_time
        ld      a,$80
        out     ($10),a
        call    waste_time
        ld      a,$2b
        out     ($10),a

waste_time:
        push    bc
        ld      b,3
waste_loop:
        djnz    waste_loop
        pop     bc
        ret

;############## Shop messages

shopmessage:
        .db     "Phx Shop -      "
        .db     "> Shield +   100"
        .db     "  Weapon 2   300"
        .db     "  Helper     500"
        .db     "  Upgrade    750"
        .db     "  Weapon 3  1000"
        .db     "  Weapon 4  1250"
        .db     "  Weapon 5  2000",0
