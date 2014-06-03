;##################################################################
;
;   Phoenix-Z80 (Level initialization)
;
;   Programmed by Patrick Davidson (pad@calc.org)
;        
;   Copyright 2005 by Patrick Davidson.  This software may be freely
;   modified and/or copied with no restrictions.  There is no warranty.
;
;   This file was last updated August 28, 2005.
;
;##################################################################     

;############## Set up a level

entryPoint:
    .dw 0

restart:
    kld(hl, level)
    ld (hl), 0

relocate_defaults:
    kld(bc, (entryPoint))
    kld(hl, (default_reloc))
    add hl, bc
    kld((default_reloc), hl)
    ret

load_level:
    kld(hl, default_data)
    kld(de, enemy_buffer)         ; zero enemy buffer
    ld bc, e_size
    ldir

    kld(hl, e_array)              ; set destination position
    kld((enemy_pointer), hl)

    kld(hl, level)
    ld a, (hl)
    inc (hl)                    ; increment level number
    kld(hl, (level_addr))
    add a, a
    add a, l \ ld l, a \ jr nc, $+3 \ inc h ; HL -> position in level list
    kcall(DO_LD_HL_MHL_EP)            ; HL -> level pointer

    ld a, (hl)                  ; read number of enemies
    kld((enemies_left), a)
    inc hl

level_loader:
    ld a, (hl)
    inc hl
    ; NOTE: This keeps compatability with existing Phoenix levels
    ; We might be able to skip this step if we relocate the jump table manually.
    ; Kernel support might be called for here, considering that libraries do this
    ; exact procedure themselves.
    ; The purpose of this code is to change A from a multiple of 3 to a multiple
    ; of 4, since jp is a 3-byte instruction and kjp is 4 bytes.
    push de
        ; A /= 3
        ld d, a
        ld e, 3
        pcall(div8by8)
        ld a, d
        ; A *= 4
        sla a \ sla a
    pop de
    or a
    jr z, _
    inc a
_:  kld((smc_loader_jump + 1), a)
smc_loader_jump:
    jr loader_table

;############## Command table

loader_table:
    ret                          ;0
    nop \ nop \ nop \ nop        ;jp shop                    ;1
    nop \ nop \ nop \ nop        ;jp game_finished           ;4
    kjp(set_power)               ;7
    kjp(set_movetype)            ;10
    kjp(set_movedata)            ;13
    kjp(set_movedata2)           ;16
    kjp(set_imagestill)          ;19
    kjp(set_imageanim)           ;22
    kjp(set_firetype)            ;25
    kjp(set_firerate)            ;28
    kjp(set_fireweapon)          ;31
    kjp(set_firepower)           ;34
    kjp(install_single)          ;37
    kjp(install_row)             ;40
    kjp(level_goto)              ;43
    ;kjp(install_standard_row)

;############## install row with default parameters

install_standard_row:
    kcall(install_first)
    ld b, 6-1                           ; B = # of enemies
    ld c, 15                            ; C = spacing
    jr pre_install_loop

;############## goto

level_goto:
    kcall(DO_LD_HL_MHL_EP)
    jr level_loader

;############## Set enemy data

set_power:
    kld(de, enemy_buffer+e_pwr)
copy_byte:
    ldi
back_to_loader:
    jr level_loader

set_movetype:
    kld(de, enemy_buffer+e_movetype)
    jr copy_byte

set_movedata:
    kld(de, enemy_buffer+e_movedata)
copy_word:
    ldi
    jr copy_byte

set_movedata2:
    kld(de, enemy_buffer+e_movedata+2)
    jr copy_byte

set_imagestill:
    xor a
    kld((enemy_buffer+e_imageseq), a)
    kld(de, enemy_buffer+e_imageptr)
    push bc
        kld(bc, (entryPoint))
        ex de, hl
        add hl, bc
        ex de, hl
    pop bc
    jr copy_word

set_firetype:
    kld(de, enemy_buffer+e_firetype)
    jr copy_byte

set_firerate:
    kld(de, enemy_buffer+e_firerate)
    jr copy_byte

set_fireweapon:
    kld(de, enemy_buffer+e_fireweapon)
    jr copy_byte

set_firepower:
    kld(de, enemy_buffer+e_firepower)
    jr copy_byte

set_imageanim:
    ld e, (hl)
    inc hl
    ld d, (hl)
    inc hl
    ld a, (de)
    inc de
    kld((enemy_buffer+e_imageseq), a)
    kld((enemy_buffer+e_imageptr), de)
    push bc
        kld(bc, (entryPoint))
        ex de, hl
        add hl, bc
        ex de, hl
    pop bc
back_to_loader_2:
    jr back_to_loader

;############## Install enemies

install_single:
    kcall(install_first)
    jr back_to_loader_2

install_row:
    kcall(install_first)
    ld b, (hl)                          ; B = # of enemies
    inc hl
    ld c, (hl)                          ; C = spacing
    inc hl
    dec b
pre_install_loop:
    push hl
install_loop:
    kld(a, (enemy_buffer+e_x))            ; move to next position
    add a, c
    kld((enemy_buffer+e_x), a)
    push bc
    kcall(install_enemy_buffer)
    pop bc
    djnz install_loop
    pop hl
    jr back_to_loader_2

install_first:
    kld(de, enemy_buffer+e_x)             ; read specified coordinates
    ldi
    inc de                      
    ldi
    push hl

    kld(hl, (enemy_buffer+e_imageptr))    ; load image size
    kld(a, (enemy_buffer+e_imageseq))
    or a
    jr z, not_animated
    kcall(DO_LD_HL_MHL_EP)
not_animated:
    kld(de, enemy_buffer+e_w)
    ldi
    inc de
    ldi
    kcall(install_enemy_buffer)            ; copy buffer to enemy array
    pop hl
    ret

install_enemy_buffer:
    kld(hl, enemy_buffer)
    kld(de, (enemy_pointer))
    ld bc, e_size
    ldir
    kld((enemy_pointer), de)
    ret     
 
;############## Default enemy data

default_data:
    .db 4               ; e_pwr
    .db EM_STANDARD     ; e_movetype
    .db 0, -60, 0         ; e_movedata
    .db 10, 0, 10, 0       ; e_x, e_w, e_y, e_h
    .db 0               ; e_imageseq
default_reloc:
    .dw img_enemy_1     ; e_imageptr
    .db FT_RANDOM       ; e_firetype
    .db 2, 0             ; e_firerate, e_firedata
    .db W_NORMAL, 1      ; e_fireweapon, e_firepower
