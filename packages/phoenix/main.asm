;##################################################################
;
;   P H O E N I X     F O R    T I - 8 2 / 8 3 / 8 3 +
;
;   Programmed by Patrick Davidson (pad@calc.org)
;    
;   Copyright 2007 by Patrick Davidson.  This software may be freely
;   modified and/or copied with no restrictions.  There is no warranty.
;
;   This file was last updated August 10, 2007.
;
;##################################################################     

leftside:
    .fill 0xFEB2 - 0xFE70
rightside:
    .fill 0xFEB2 - 0xFE70
leftsidecoord:
    .db 0
leftsidevel:
    .dw 0
rightsidecoord:
    .db 0
rightsidevel:
    .dw 0

main:
    ld hl, 0x4008
    kld((leftside), hl)
    kld((rightside), hl)

    kcall(set_up_sides)

    ; NOTE: We have to set up a second thread here, I think?
    ; Only syncronize uses it, afaik. We can probably get away with just sleeping to slow down
    ; The ISR is in lib.asm
    ;ld hl, timer_interrupt
    ;ld (custintaddr), hl
    ;ld a, 34
    ;call setupint

    ;ei

    kld(hl, level_table) ; use default level data
    kld((level_addr), hl)

    ;call restore_game ; check for saved game

    xor a ; by default, no external level
    kld((extlevel), a)

no_saved_game:
    kcall(title_screen)

prepare_new_game:
    kld(hl, player_y)
    ld (hl), 70         ; Player Y coord = 70
    inc hl
    ld (hl), 60         ; Player X coord = 60
    inc hl
    inc hl
    inc hl
    ld (hl), 16         ; Status of player's ship

    ld hl, 19000
    kld((time_score), hl)
    ld a, 4
    kld((money_counter), a)

pre_main_loop:
    kcall(convert_settings)    ; decode configuration
    ; This does some SMC to load the current stack pointer (less 3 PUSHes)
    ; into collision_done. I don't know why and it seems esoteric, we should
    ; refactor it away.
    ld hl, -6
    add hl, sp
    kld((collision_done + 1), hl)
    xor a
    kld((x_offset), a)
    
;############## Game main loop
    
main_loop:
    kcall(frame_init)

    kcall(clear_buffer)       ; Prepare main display buffer

    kcall(init_rand)

    kcall(do_player)         ; Move and draw player
;    call do_companion       ; Move and draw companion ship
;
    kcall(enemies)            ; Move and draw enemies
;
;    call player_bullets     ; Move and draw player bullets
;
;    call enemy_bullets      ; Move and draw enemy bullets
;    call hit_player         ; Collisions involving player

    kcall(scroll_sides)
    kcall(render_sides)
;    call prepare_indicator  ; Prepare the shield indicator
;
;    call display_money
;    call synchronize        ; Wait for next 1/30 second cycle
    kcall(display_screen)    ; Copy display buffer to video memory

    kld(a, (scroll_flag))
    or a
    jr z, no_scrolling
    kld(a, (player_x))
    cp 28
    jr c, scrolled_leftmost
    cp 92
    jr nc, scrolled_rightmost
    sub 28
    rra
    and 31
    sub 16
    kld((x_offset), a)
    jr no_scrolling
scrolled_leftmost:
    ld a, -16
    kld((x_offset), a)
    jr no_scrolling
scrolled_rightmost:
    ld a, 16
    kld((x_offset), a)
no_scrolling:

;    call hit_enemies        ; Collisions btw. bullets  enemies
;
    kcall(handle_input)       ; Process control keys
;    ld a, (enemies_left)
;    or a
;    call z, load_level
    jr main_loop

;;############## TI-82 library

; Clears a block of memory
; BC: Length
; HL: Block to clear
; Destroys HL DE BC
OTH_CLEAR:
    ld (hl), 0
OTH_FILL:
    ld d, h
    ld e, l
    inc de
    ldir
    ret

; Educated guess: checks for arrow keys
OTH_ARROW:
    ld a, 0b00111111
    out (1), a
    push ix
    pop ix
    in a, (1)
    or 0b00001111
    ld b, a
    ld a, 0b01111110
    out (1), a
    push ix
    pop ix
    in a, (1)
    and b
    ret
