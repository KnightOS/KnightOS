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

restart:
        ld      hl,level
        ld      (hl),0

load_level:
        ld      hl,default_data
        ld      de,enemy_buffer         ; zero enemy buffer
        ld      bc,e_size
        ldir

        ld      hl,e_array              ; set destination position
        ld      (enemy_pointer),hl

        ld      hl,level
        ld      a,(hl)
        inc     (hl)                    ; increment level number
        ld      hl,(level_addr)
        add     a,a
        call    ADD_HL_A                ; HL -> position in level list
        call    DO_LD_HL_MHL            ; HL -> level pointer

        ld      a,(hl)                  ; read number of enemies
        ld      (enemies_left),a
        inc     hl

level_loader:
        ld      a,(hl)
        inc     hl
        ld      (smc_loader_jump+1),a
smc_loader_jump:
        jr      loader_table

;############## Command table

loader_table:
        ret                             ;0
        jp      shop                    ;1
        jp      game_finished           ;4
        jp      set_power               ;7
        jp      set_movetype            ;10
        jp      set_movedata            ;13
        jp      set_movedata2           ;16
        jp      set_imagestill          ;19
        jp      set_imageanim           ;22
        jp      set_firetype            ;25
        jp      set_firerate            ;28
        jp      set_fireweapon          ;31
        jp      set_firepower           ;34
        jp      install_single          ;37
        jp      install_row             ;40
        jp      level_goto              ;43
                                        ;46

;############## install row with default parameters

install_standard_row:
        call    install_first
        ld      b,6-1                           ; B = # of enemies
        ld      c,15                            ; C = spacing
        jr      pre_install_loop

;############## goto

level_goto:
        call    DO_LD_HL_MHL
        jr      level_loader

;############## Set enemy data

set_power:
        ld      de,enemy_buffer+e_pwr
copy_byte:
        ldi
back_to_loader:
        jr      level_loader

set_movetype:
        ld      de,enemy_buffer+e_movetype
        jr      copy_byte

set_movedata:
        ld      de,enemy_buffer+e_movedata
copy_word:
        ldi
        jr      copy_byte

set_movedata2:
        ld      de,enemy_buffer+e_movedata+2
        jr      copy_byte

set_imagestill:
        xor     a
        ld      (enemy_buffer+e_imageseq),a
        ld      de,enemy_buffer+e_imageptr
        jr      copy_word

set_firetype:
        ld      de,enemy_buffer+e_firetype
        jr      copy_byte

set_firerate:
        ld      de,enemy_buffer+e_firerate
        jr      copy_byte

set_fireweapon:
        ld      de,enemy_buffer+e_fireweapon
        jr      copy_byte

set_firepower:
        ld      de,enemy_buffer+e_firepower
        jr      copy_byte

set_imageanim:
        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        inc     hl
        ld      a,(de)
        inc     de
        ld      (enemy_buffer+e_imageseq),a
        ld      (enemy_buffer+e_imageptr),de
back_to_loader_2:
        jr      back_to_loader

;############## Install enemies

install_single:
        call    install_first
        jr      back_to_loader_2

install_row:
        call    install_first
        ld      b,(hl)                          ; B = # of enemies
        inc     hl
        ld      c,(hl)                          ; C = spacing
        inc     hl
        dec     b
pre_install_loop:
        push    hl
install_loop:
        ld      a,(enemy_buffer+e_x)            ; move to next position
        add     a,c
        ld      (enemy_buffer+e_x),a
        push    bc
        call    install_enemy_buffer
        pop     bc
        djnz    install_loop
        pop     hl
        jr      back_to_loader_2

install_first:
        ld      de,enemy_buffer+e_x             ; read specified coordinates
        ldi
        inc     de                      
        ldi
        push    hl

        ld      hl,(enemy_buffer+e_imageptr)    ; load image size
        ld      a,(enemy_buffer+e_imageseq)
        or      a
        jr      z,not_animated
        call    DO_LD_HL_MHL
not_animated:
        ld      de,enemy_buffer+e_w
        ldi
        inc     de
        ldi
        call    install_enemy_buffer            ; copy buffer to enemy array
        pop     hl
        ret

install_enemy_buffer:
        ld      hl,enemy_buffer
        ld      de,(enemy_pointer)
        ld      bc,e_size
        ldir
        ld      (enemy_pointer),de
        ret     
 
;############## Default enemy data

default_data:
        .db     4               ; e_pwr
        .db     EM_STANDARD     ; e_movetype
        .db     0,-60,0         ; e_movedata
        .db     10,0,10,0       ; e_x, e_w, e_y, e_h
        .db     0               ; e_imageseq
        .dw     img_enemy_1     ; e_imageptr
        .db     FT_RANDOM       ; e_firetype
        .db     2,0             ; e_firerate, e_firedata
        .db     W_NORMAL,1      ; e_fireweapon, e_firepower
