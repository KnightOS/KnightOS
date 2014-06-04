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
show_title:
    pcall(clearBuffer)
    ; This could probably be made more efficient
    ld de, 0x1700
    ld b, d
    kld(hl, title_main)
    pcall(drawStr)
    kld(hl, author)
    ld de, 0x0E2F
    ld b, d
    pcall(drawStr)
    ld de, 0x1D08
    kld(hl, title_options)
    ld b, d
    pcall(drawStr)
    kld(hl, caret_sprite)
    ld b, 5
    ld de, 0x1908
    pcall(putSpriteOR)
    ld d, 0
title_loop:
    pcall(fastCopy)
    pcall(getKey)
    pcall(flushKeys)

    cp kDown
    jr z, .down
    cp kUp
    jr z, .up
    cp k2nd
    jr z, .select
    cp kEnter
    jr z, .select

    cp kMODE
    pcall(z, exitThread)
    cp kCLEAR
    pcall(z, exitThread)
    cp kDEL
    pcall(z, exitThread)
    jr title_loop
.down:
    ld a, d
    cp 5
    jr z, title_loop
    push de
        ; Erase current cursor
        add a, a \ ld e, a \ add a, a \ add a, e
        add a, 8
        ld e, a
        ld d, 0x19
        ld b, 5
        kld(hl, caret_sprite)
        pcall(putSpriteXOR)
        ; Draw new one
        ld a, e
        add a, 6
        ld e, a
        pcall(putSpriteXOR)
    pop de
    ld a, d
    inc a
    ld d, a
    jr title_loop
.up:
    ld a, d
    or a
    jr z, title_loop
    push de
        ; Erase current cursor
        add a, a \ ld e, a \ add a, a \ add a, e
        add a, 8
        ld e, a
        ld d, 0x19
        ld b, 5
        kld(hl, caret_sprite)
        pcall(putSpriteXOR)
        ; Draw new one
        ld a, e
        sub 6
        ld e, a
        pcall(putSpriteXOR)
    pop de
    ld a, d
    dec a
    ld d, a
    jr title_loop
.select:
    ld a, d
    add a, a
    kld((.selection + 1), a)
.selection:
    jr $
.table:
    jr .start_game
    jr .high_scores
    jr .instructions
    jr .settings
    jr .contact_info
    pcall(exitThread) ; Last option
.start_game:
    kjp(initialize_game)
.high_scores:
.instructions:
.settings:
.contact_info:
    ; TODO
    pcall(exitThread)

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
    ;add a, l \ ld l, a \ jr nc, $+3 \ inc h ; TODO: Difficulty
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

options_msg:
    .db "Use up/down/2nd\n", 0
    .db 0
    .db " Level ......\n", 0
level_end:
    .db " Backgr .....\n", 0
terrain_end:
    .db " Speed ....\n", 0
speed_end:
    .db " Sides ...\n", 0
sides_end:
    .db " Scrolling ...\n", 0
scroll_end:
    .db " Exit options\n", 0
    .db -1

;############## Title screen messages

title_main:
    .db "=== Phoenix ===", 0
author:
    .db "        Patrick Davidson\n"
    .db "ported for KnightOS by\n"
    .db "             Drew DeVault", 0
title_options:
    .db "Start Game\n"
    .db "High Scores\n"
    .db "Instructions\n"
    .db "Settings\n"
    .db "Contact Info\n"
    .db "Quit", 0
caret_sprite:
    .db 0b10000000
    .db 0b11000000
    .db 0b11100000
    .db 0b11000000
    .db 0b10000000
