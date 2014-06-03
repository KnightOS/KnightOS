;##################################################################
;
;   Phoenix-Z80 (Enemy firing)
;
;   Programmed by Patrick Davidson (pad@calc.org)
;        
;   Copyright 2002 by Patrick Davidson.  This software may be freely
;   modified and/or copied with no restrictions.  There is no warranty.
;
;   This file was last updated July 7, 2002.
;
;##################################################################     

enemy_shoot:
    ld de, e_firetype
    add hl, de
    ld a, (hl)
    inc hl
    kld((smc_enemy_fire_select + 1), a)
smc_enemy_fire_select:
    jr enemy_fire_table
enemy_fire_table:
    jr fire_random             ; 0
    ret                             ; 2
                                    ; 3
fire_periodic:
    ld a, (hl)                  ; B = rate
    inc hl
    inc (hl)                    ; increment counter
    cp (hl)
    ret nz                      ; exit if rate not reached
    ld (hl), 0                  ; reset counter
    inc hl
    jr select_weapon

fire_random:
    kcall(FAST_RANDOM)
    cp (hl)
    ret nc
    inc hl
    inc hl

select_weapon:
    ld a, (hl)                  ; A = weapon type
    push de
        ; A /= 3
        ld d, a
        ld e, 3
        pcall(div8by8)
        ld a, d
        ; A *= 4
        sla a \ sla a
    pop de
    kld((smc_enemy_weapon_select + 1), a)
    inc hl
    ld a, (hl)                  ; A = weapon power
    kld((smc_enemy_bullet_power+1), a)
smc_enemy_weapon_select:
    jr enemy_weapon_table
enemy_weapon_table: ; TODO
    kjp(normal_weapon)           ; 0
    kjp(double_weapon)           ; 3
    kjp(semi_aim_shoot_now)      ; 6
    kjp(double_big)              ; 9
    kjp(double_huge)             ; 12
    kjp(fire_arrow)              ; 15
    kjp(single_big)              ; 18

;############## Single big shots

single_huge:    
    ld de, e_x-e_firepower
    add hl, de
    inc (hl)
    push hl
    kcall(fire_huge_bullet)
    pop hl
    dec (hl)
    ret

single_big:
    ld de, e_x-e_firepower
    add hl, de
    inc (hl)
    inc (hl)
    push hl
    kcall(fire_big_bullet)
    pop hl
    dec (hl)
    dec (hl)
    ret

;############## Fire arrow

fire_arrow:
    ld de, e_w-e_firepower
    add hl, de
    kld(de, arrow_ebullet_data)
    kjp(fire_enemy_bullet)
    
arrow_ebullet_data:
    .db 21
    .db 3
    .db 7

;############## Double shots

double_big:
    kld(de, fire_big_bullet)
    ld a, 13
    kjp(double_weapon_main)

double_huge:
    kld(de, fire_huge_bullet)
    ld a, 11
    kjp(double_weapon_main)

;############## a large, fully-aimed bullet (HL -> X)

fire_huge_bullet:
    ld d, -1
    jr fire_large_common

fire_big_bullet:
    ld d, 0
fire_large_common:
    inc hl
    inc hl
    kld(a, (player_y))
    sub (hl)
    ret c
    srl a
    srl a
    ld b, a                     ; B = (PY - EY)
    srl a
    add a, b
    ret z
    ld b, a                     ; B = (3/8) * (PY - EY)
    dec hl
    dec hl
    kld(a, (player_x))
    sub (hl)                    ; A = PX - EX
    inc hl
    jr c, fire_big_left
    kcall(get_angle)
    ld a, c
    
deploy_big:
    kld(bc, (which_shot))
    bit 7, d
    jr nz, deploy_huge
    add a, 27
    kld(de, big_ebullet_data)
    ld (de), a
    kjp(fire_enemy_bullet)

deploy_huge:
    add a, 36
    kld(de, big_ebullet_data)
    ld (de), a
    kjp(fire_enemy_bullet)

fire_big_left:
    neg
    kcall(get_angle)
    ld a, c
    neg
    jr deploy_big

get_angle:
    ld c, 0
    sub b
    ret c                       ; DX < (3/8) DY -> straight down
    inc c
    sub b
    ret c                       ; DX < (3/4) DY -> slight angle
    inc c
    sub b
    ret c                       ; DX < (3/2) DY -> 45 deg angle
    sub b
    ret c
    inc c                       ; DX > (3/2) DY -> high angle
    ret

big_ebullet_data:
    .db 3
    .db 5
    .db 5

;############## Fire an aimed bullet, accounting for Y difference

semi_aim_shoot_now:
    ld de, e_y-e_firepower
    add hl, de
    kld(a, (player_y))
    sub (hl)
    ret c
    srl a
    srl a
    ld b, a                     ; B = (PY - EY)
    srl a
    add a, b
    ret z
    ld b, a                     ; B = (3/8) * (PY - EY)
    dec hl
    dec hl
    kld(a, (player_x))
    sub (hl)                    ; A = PX - EX
    inc hl
    jr c, figurefireleft
    cp b
    kjp(c, fire_enemy_bullet_std)
    kjp(fire_bullet_half_right)

figurefireleft:
    neg
    cp b
    kjp(c, fire_enemy_bullet_std)
    kjp(fire_bullet_half_left)

;############## (boss) shot

double_weapon:
    kld(de, fire_aimed_bullet)
    ld a, 14
double_weapon_main:
    kld((smc_which_shot+1), de)
    ld de, e_x-e_firepower
    add hl, de
    ld b, (hl)
    push bc
    add a, b
    ld (hl), a
    push hl
    kcall(smc_which_shot)
    pop hl
    pop bc
    ld (hl), b
smc_which_shot:
    jp 31337

;############## Fire an aimed bullet (HL -> X coordinate)

fire_aimed_bullet:
    kld(a, (player_x))
    add a, 30
    cp (hl)                    ; PlayerX + 30 - ShootX
    jr c, fire_bullet_left      ; If ShootX > PlayerX + 30
    sub 60                      ; PlayerX - 30
    jr c, fire_bullet_std       ; If PlayerX < 30
    cp (hl)                    ; PlayerX - 30 - ShootX
    jr nc, fire_bullet_right    ; If ShootX <= PlayerX - 30

fire_bullet_std:
    inc hl
fire_enemy_bullet_std:
    kld(de, standard_ebullet_data)
    jr fire_enemy_bullet

fire_bullet_left:
    inc hl
    kld(de, left_ebullet_data)
    jr fire_enemy_bullet

fire_bullet_right:
    inc hl
    kld(de, right_ebullet_data)
    jr fire_enemy_bullet

fire_bullet_half_left:
    kld(de, half_left_ebullet_data)
    jr fire_enemy_bullet

fire_bullet_half_right:
    kld(de, half_right_ebullet_data)
    jr fire_enemy_bullet

standard_ebullet_data:
    .db 3               ; Type
    .db 2               ; Width
    .db 2               ; Height

left_ebullet_data:
    .db 9               ; Type
    .db 2               ; Width
    .db 2               ; Height

right_ebullet_data:
    .db 12              ; Type
    .db 2               ; Width
    .db 2               ; Height

half_left_ebullet_data:
    .db 15              ; Type
    .db 2               ; Width
    .db 2               ; Height

half_right_ebullet_data:
    .db 18              ; Type
    .db 2               ; Width
    .db 2               ; Height

;############## Normal (drop small block) shot

normal_weapon:
    ld de, e_w-e_firepower
    add hl, de
    kld(de, standard_ebullet_data)

;############## Fire any type of bullet (HL -> width, DE -> info)

fire_enemy_bullet:
    push hl
    push de

    kcall(locate_enemy_bullet)     ; HL -> enemy bullet entry

    pop de                      ; DE -> bullet description
    pop bc                      ; BC -> enemy Y coordinate
    ex de, hl                   ; HL -> bullet description
                                    ; -> enemy bullet entry

    ldi ; Copy type, BC -> enemy X
smc_enemy_bullet_power:
    ld a, 1
    ld (de), a                  ; store power
    inc de                  
    ld a, (bc)
    add a, 2
    ld (de), a                  ; Store ebullet X
    inc de
    ldi ; Copy width, BC -> enemy X - 1
    inc bc
    inc bc
    inc bc                      ; BC -> enemy Y
    ld a, (bc)
    add a, 7
    ld (de), a                  ; Store ebullet Y
    inc de
    ldi ; Copy height
    ret

;############## Locate an unused enemy bullet

locate_enemy_bullet:
    kld(hl, eb_array)
    ld b, eb_num
    ld de, eb_size
loop_locate_eb:
    ld a, (hl)
    or a
    ret z
    add hl, de
    djnz loop_locate_eb
    pop hl
    pop de
    pop hl
    ret
