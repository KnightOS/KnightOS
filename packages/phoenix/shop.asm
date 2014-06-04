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

shop:
    kld(hl, (player_cash))
    ld a, h
    or l
    ret z

    xor a
    kld((shop_item), a)

    kcall(CLEARLCD)
    ld hl, 0
    kld((_puts_shim_cur), hl)
    kld(hl, shopmessage)
    ld b, 0x16
    ld de, 0x1000
    pcall(drawStr)
    kld(hl, caret_sprite)
    ld b, 5
    ld de, 0x120C
    pcall(putSpriteOR)


;############## Shop main loop

shop_loop:
    ; Clear out the money space
    push bc
    push de
    push hl
        ld e, 0
        ld l, 0x3A
        ld c, 30
        ld b, 6
        pcall(rectAND)
    pop hl
    pop de
    pop bc
    ;/Clear out
    ld de, 0x003A
    ld a, '$'
    pcall(drawChar)
    kcall(convert_to_decimal)
    kld(hl, (decimal_cash))
    ld a, h
    ld h, l
    ld l, a
    pcall(drawHexHL)
    kcall(show_shop_status)
    pcall(fastCopy)

    pcall(flushKeys)
    corelib(appwaitKey)
    kld(hl, shop_item)
    cp kDown
    jr z, shop_down
    cp kUp
    jr z, shop_up
    cp kMODE
    ret z
    cp kDEL
    ret z
    cp kCLEAR
    ret z
    cp kEnter
    push af
    kcall(z, shop_select)
    pop af
    cp k2nd
    kcall(z, shop_select)
    jr shop_loop

;############## Shop cursor movement

shop_down:
    ld a, (hl)
    cp 6
    jr z, shop_loop

    push hl
        add a, a \ ld e, a \ add a, a \ add a, e
        add a, 0xC
        ld e, a
        ld d, 0x12
        kld(hl, caret_sprite)
        ld b, 5
        pcall(putSpriteXOR)
        add a, 6
        ld e, a
        pcall(putSpriteXOR)
    pop hl
    inc (hl)
    jr shop_loop
shop_up:
    ld a, (hl)
    or a
    kjp(z, shop_loop)

    push hl
        add a, a \ ld e, a \ add a, a \ add a, e
        add a, 0xC
        ld e, a
        ld d, 0x12
        kld(hl, caret_sprite)
        ld b, 5
        pcall(putSpriteXOR)
        sub a, 6
        ld e, a
        pcall(putSpriteXOR)
    pop hl
    dec (hl)
    kjp(shop_loop)

;############## Shop item purchases

item3:
    ld bc, 500
    sbc hl, bc
    ret c

    kld(a, (companion_pwr))
    cp 16
    ret z
    kld((player_cash), hl)
get_companion:
    kld(hl, companion_pwr)
    ld (hl), 16
    inc hl
    ld (hl), 90
    inc hl
    ld (hl), 60
    ret

shop_select:
    ld a, (hl)
    add a, a
    kld((shop_jump_offset + 1), a) ; OH SHIT IT'S SMC (will probably work without changes)
    kld(hl, (player_cash))
shop_jump_offset:
    jr item_list
item_list:
    jr item1
    jr item2
    jr item3
    jr item4
    jr item5
    jr item6

item7:
    ld bc, 2000
    ld a, 4
    jr common_weapon_add

item1:
    ld bc, 100
    sbc hl, bc
    ret c
    kld(a, (player_pwr))
    cp 16
    ret z
    inc a
    kld((player_pwr), a)
    kld((player_cash), hl)
    ret

item2:
    ld bc, 300                  ; BC = weapon cost
    ld a, 1                     ; A = weapon # - 1
common_weapon_add:
    sbc hl, bc                   ; HL = money left after purcahse
    ret c                       ; if negative, can't purchase
    ex de, hl                   ; DE = money left after purchase
    kld((chosen_weapon), a)       ; set chosen weapon to this one
    kld(hl, weapon_2-1)
    add a, l \ ld l, a \ jr nc, $+3 \ inc h ; HL -> weapon purchase flag
    ld a, (hl)
    or a
    ret nz                      ; exit if already purchased
    inc (hl)                    ; flag as purchased
    kld((player_cash), de)        ; set cash to new value
    ret

item5:
    ld bc, 1000
    ld a, 2
    jr common_weapon_add

item6:
    ld bc, 1250
    ld a, 3
    jr common_weapon_add

item4:
    kld(de, weapon_upgrade)
    ld a, (de)
    or a
    ret nz
    ld bc, 750
    sbc hl, bc
    ret c
    kld((player_cash), hl)
    inc a
    ld (de), a
    ret

;############## Display the shield bar

show_shop_status:
    kld(a,(player_pwr))
    or a
    ret z
    ret m
    ld b,a
    push iy \ pop hl
    push bc
        ld bc, 0x300 - 1
        add hl, bc
    pop bc
    ld de, -12
.loop_ind:
    set 0, (hl)
    add hl, de
    set 0, (hl)
    add hl, de
    set 0, (hl)
    add hl, de
    set 0, (hl)
    add hl, de
    djnz .loop_ind
    ret

;############## Shop messages

shopmessage:
    .db "--Phoenix Shop--\n\n"
    .db "Repair          $100\n"
    .db "Weapon 2   $300\n"
    .db "Helper         $500\n"
    .db "Upgrade    $750\n"
    .db "Weapon 3   $1000\n"
    .db "Weapon 4   $1250\n"
    .db "Weapon 5   $2000\n", 0
