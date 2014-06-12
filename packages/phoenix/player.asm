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
    kcall(OTH_ARROW)
    ld c, a

    kld(hl, fire_counter)
    bit 5, c
    jr z, player_fire
    ld (hl), 0
    jr fire_done

player_fire:
    ld d, 4
    kld(a, (weapon_upgrade))
    or a
    jr nz, autofire
    ld d, 10
autofire:
    ld a, (hl)
    or a
    jr z, do_shoot
    dec (hl)
    jr fire_done
do_shoot:
    ld (hl), d
    push bc
    kcall(player_shoot)
    pop bc
fire_done:
    kld(hl, player_y)
    rr c
    jr c, no_down
    ld a, (hl)
    add a, 1
    cp 90
    jr z, no_down
    ld (hl), a
no_down:
    inc hl
    rr c
    jr c, no_left
    ld a, (hl)
    add a, -2
    cp 14
    jr z, no_left
    ld (hl), a
no_left:
    rr c
    jr c, no_right
    ld a, (hl)
    add a, 2
    cp 106
    jr z, no_right
    ld (hl), a
no_right:
    ld d, (hl)
    dec hl
    rr c
    jr c, no_up
    ld a, (hl)
    add a, -1
    cp 68
    jr z, no_up
    ld (hl), a
no_up:
    kld(de, (player_y))
    kld(hl, img_player_ship_normal)
    kld(a, (player_pwr))
    cp 4
    kjp(nc, drw_spr)
    kld(hl, img_player_ship_damaged)
    kjp(drw_spr)

;############## Control keys (GET_KEY)

pause:
    pcall(flushKeys)
loop_pause:
    corelib(appGetKey)
    kcall(nz, display_screen) ; TODO: Dunno why this leaves artifacts on the screen
    cp kEnter
    jr nz, loop_pause
    pcall(flushKeys)
    ret

pause_msg:
    .db "PAUSED (ENTER)", 0

handle_input:
    pcall(getKey)
    cp kF1
    corelib(z, launchCastle)
    cp kF5
    corelib(z, launchThreadList)
    cp kEnter
    jr z, pause
    cp kMODE
    ;kjp(z, game_save) ; TODO
    cp kDEL
    pcall(z, exitThread)
    cp kCLEAR
    pcall(z, exitThread)

    kld(hl, chosen_weapon)
    cp k5
    jr z, select_weapon_5
    cp k4
    jr z, select_weapon_4
    cp k3
    jr z, select_weapon_3
    cp k2
    jr z, select_weapon_2
    sub k1
    ret nz
    ld (hl), a
    ret

select_weapon_2:
    kld(a, (weapon_2))
    or a
    ret z
    ld (hl), a
    ret

select_weapon_3:
    kld(a, (weapon_3))
    or a
    ret z
    ld (hl), 2
    ret

select_weapon_4:
    kld(a, (weapon_4))
    or a
    ret z
    ld (hl), 3
    ret

select_weapon_5:
    kld(a, (weapon_5))
    or a
    ret z
    ld (hl), 4
    ret
