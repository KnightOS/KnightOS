;##################################################################
;
;   Phoenix-Z80 (New game initialization)
;
;   Programmed by Patrick Davidson (pad@ocf.berkeley.edu)
;    
;   Copyright 2011 by Patrick Davidson.  This software may be freely
;   modified and/or copied with no restrictions.  There is no warranty.
;
;   This file was last updated June 2, 2011.
;
;##################################################################     

;############## Main title screen

title_screen:
    kcall(convert_settings)
redraw_title:
    kld(hl, title_main)

show_title:
    kcall(display_hl_msgs)
    pcall(fastCopy)
    pcall(flushKeys)
    
title_loop:
    pcall(getKey) ; TODO: corelib integration
    cp k5
    jr z, redraw_title
    cp k4
    jr z, show_instructions
    cp k3
    jr z, show_contact
    cp k2
    jr z, _options_screen
    cp k1
    kjp(z, initialize_game)
    cp kAlpha
    jr z, show_highs
    cp kMODE
    jr z, title_exit
    cp kCLEAR
    jr z, title_exit
    cp kDEL
    jr nz, title_loop
title_exit:
    pcall(exitThread)

show_highs:
    ;kcall(no_high_score)
    jr redraw_title

show_contact:
    kld(hl, title_contact)
    jr show_title

show_instructions:
    kld(hl, title_instructions)
    jr show_title

;############## Options screen

_options_screen:             ; initialize options screen
    xor a
    kld((option_item), a)

option_redraw:              ; redraw options screen
    kcall(convert_settings)
    kld(hl, options_msg)
    kcall(display_hl_msgs)
    pcall(fastCopy)

option_draw:                ; draw option arrow
    kcall(option_position)
    kld(hl, draw_pointer)
    kcall(puts)
    pcall(fastCopy)

options_loop:               ; option main loop
    pcall(flushKeys)
    pcall(getKey)
    cp k5
    jr z, redraw_title
    cp kMODE
    jr z, redraw_title
    cp kCLEAR
    jr z, redraw_title
    cp kDEL
    kjp(z, redraw_title)
    cp kUp
    jr z, options_up
    cp kDown
    jr z, options_down
    cp k2nd
    jr nz, options_loop

    kld(a, (option_item))     ; dispatch chosen optoin
    add a, a
    ld (smc_optionjump + 1), a

smc_optionjump:
    jr option_jumptable
option_jumptable:
    jr option_skill
    jr option_terrain
    jr option_speed
    jr option_side
    jr option_scroll
    kjp(redraw_title)

options_up:                 ; move arrow up
    kcall(option_erase)
    ld hl, option_item
    dec (hl)
    kjp(p, option_draw)
    ld (hl), 5
    jr option_draw

options_down:               ; move arrow down
    kcall(option_erase)
    kld(hl, option_item)
    inc (hl)
    ld a, 6
    cp (hl)
    jr nz, option_draw
    ld (hl), 0
    jr option_draw

option_erase:               ; erase arrow
    kcall(option_position)
    ld hl, erase_pointer
    kcall(puts)
    pcall(fastCopy)

option_position:            ; calculate arrow position
    kld(a, (option_item))
    add a, 2
    ld l, a
    ld h, 0
    ld (_puts_shim_cur), hl
    ret

erase_pointer:
    .db "  ", 0
draw_pointer:
    .db "->", 0

option_skill:               ; change skill
    kld(hl, difficulty)
    ld c, 3
option_common:
    ld a, (hl)
    inc a
    cp c
    jr c, difficulty_ok
    xor a
difficulty_ok:
    ld (hl), a
goto_option_redraw:
    kjp(option_redraw)
    
option_speed:               ; change speed
    kld(hl, speed_option)
    ld c, 2
    jr option_common

option_terrain:             ; change color
    ld hl, invert
    ld a, (hl)
    cpl
    ld (hl), a
    jr goto_option_redraw

option_side:
    kld(hl, sides_flag)
    ld a, 1
    xor (hl)
    ld (hl), a
    jr goto_option_redraw

option_scroll:
    kld(hl, scroll_flag)
    ld a, 1
    xor (hl)
    ld (hl), a
    jr goto_option_redraw

;############## Prepare new game

initialize_game:
    kld(hl, data_zero_start)
    ld bc, data_zero_end - data_zero_start - 1
    kjp(OTH_CLEAR)

;############## Load temporary variables from settings

convert_settings:
    kld(a, (difficulty))
    ld b, a
    add a, a
    add a, b         ; A = difficulty * 3
    add a, a
    add a, a         ; A = difficulty * 12
    sub b           ; A = difficulty * 11
    kld(hl, difficulty_data)
    add a, l \ ld l, a \ jr nc, $+3 \ inc h
    ld de, level_end-7
    ld bc, 6
    ldir

    kld(de, money_amount)
    ld bc, 5
    ldir

    kld(a, (speed_option))
    ld b, a
    add a, a
    add a, b
    add a, a
    add a, b         ; A = speed * 6
    kld(hl, speed_data)
    add a, l \ ld l, a \ jr nc, $+3 \ inc h
    ld de, speed_end-5
    ld bc, 4
    ldir

    ld a, (hl)
    kld((speed), a)

    inc hl
    kcall(DO_LD_HL_MHL)
    kld(de, (bonus_score))
    add hl, de
    kld((bonus_score), hl)

    kld(a, (invert))
    inc a ; 0 = black, 1 = white
    ld b, a        
    add a, a
    add a, a
    add a, b ; 0 = black, 5 = white
    kld(hl, terrain_data)
    add a, l \ ld l, a \ jr nc, $+3 \ inc h
    ld de, terrain_end-6
    ld bc, 5
    ldir

    kld(a, (sides_flag))
    ld b, a
    add a, a
    add a, b
    kld(hl, sides_data)
    add a, l \ ld l, a \ jr nc, $+3 \ inc h
    ld de, sides_end-4
    ld bc, 3
    ldir

    kld(a, (scroll_flag))
    ld b, a
    add a, a
    add a, b
    kld(hl, sides_data)
    add a, l \ ld l, a \ jr nc, $+3 \ inc h
    ld de, scroll_end-4
    ld bc, 3
    ldir
    ret

sides_data:
    .db "OFF"
    .db "ON "

terrain_data:
    .db "BLACK"
    .db "WHITE"
     
speed_data:
    .db "SLOW",3      ; slow (delay 6, bonus 0)
    .dw 0
    .db "FAST",2      ; fast (delay 4, bonus 5000)
    .dw 5000

difficulty_data:
    .db "EASY  ",100    ; easy (cash 100, bonus 0)
    .dw 0
    .db 0x1,0x00
    .db "MEDIUM",50     ; medium (cash 50, bonus 5000)
    .dw 5000
    .db 0x0, 0x50
    .db "HARD  ",25     ; hard (cash 25, bonus 15000)
    .dw 15000
    .db 0x0,0x25
#ifdef ENABLE_CHEATS
    .db "CHEAT ",100    ; hard (cash 100, bonus 0)
    .dw 0
    .db 0x1,0x00
#endif

;############## Title screen messages

title_main:
    ; TODO: Replace this with straight strings
    .db "  Phoenix\n", 0
    .db " Programmed by\n", 0
    .db "Patrick Davidson\n", 0
    .db 0
    .db " 1 - Start Game\n", 0
    .db "  2 - Settings\n", 0
    .db "3 - Contact Info\n", 0
    .db "4 - Instructions\n", 0
    .db -1

title_instructions:
    .db "Arrows Move Ship\n", 0
    .db "#s Select Weapon\n", 0
    .db "2nd Fires Weapon\n", 0
    .db "MORE Saves&Exits\n", 0
    .db "ENTER Pauses\n", 0
    .db "+,- Contrast Adj\n", 0
    .db 0
    .db "5: Main Menu\n", 0
    .db -1

title_contact:
    .db "E-Mail: pad@ocf.\n", 0
    .db "    berkeley.edu\n", 0
    .db "Web: www.ocf.ber\n", 0
    .db " keley.edu/~pad/\n", 0
    .db "IRC: PatrickD on\n", 0
    .db "     EfNet #tcpa\n", 0
    .db 0
    .db "5: Main Menu\n", 0
    .db -1

options_msg:
    .db "Use up/down/2nd\n", 0
    .db 0     
    .db "   Level ......\n", 0
level_end:
    .db "   Backgr .....\n", 0
terrain_end:
    .db "   Speed ....\n", 0
speed_end:
    .db "   Sides ...\n", 0 
sides_end:
    .db "   Scrolling ...\n", 0
scroll_end:
    .db "   Exit options\n", 0
    .db -1
