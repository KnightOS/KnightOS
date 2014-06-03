;##################################################################
;
;   Phoenix-Z80 (low-level support routines)
;
;   Programmed by Patrick Davidson (pad@calc.org)
;        
;   Copyright 2001 by Patrick Davidson.  This software may be freely
;   modified and/or copied with no restrictions.  There is no warranty.
;
;   This file was last updated January 15, 2005.
;
;##################################################################   

;############## Simple routines

DO_LD_HL_MHL:
    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a
    ret

DO_LD_HL_MHL_EP:
    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a
    push bc
        kld(bc, (entryPoint))
        add hl, bc
    pop bc
    ret

; kernel cpHLDE would do fine here
; Leaving this for now because it'd be faster than the pcall
DO_CP_HL_DE:
    push    hl
    and     a
    sbc     hl,de
    pop     hl
    ret

; Waits a while
; This was done with a custom ISR in the original phoenix
synchronize:
    ; TODO: Change this by difficulty
    ; TODO: Change this by clock speed
    push bc
    push af
        ld b, 0x70
_:      pcall(getKey)
        cp kF1
        corelib(z, launchCastle)
        cp kF5
        corelib(z, launchThreadList)
        djnz -_
    pop af
    pop bc
    ret

; NOTE: Contrast adjustment removed from this part

;############## Basic computations

table_look_up:
    add a, a
    kld(hl, speed_table)
ADD_HL_A:
    add a, l
    ld l, a
    ret nc
    inc h
    ret

;############## Frame-averaging division by 16
;                                                
; Divides the value in A by 16.  This routine uses the timer to decide
; whether fractions are rounded up, so a fractional part of x/16 is rounded
; up x frame out of every 16.  This allows movement of objects by fractional
; amounts to appear smooth.  Changes A, B, and C.

Div_A_16:
    kld(bc, (game_timer))
    ld b, a
    xor a
    rr c
    rla
    rr c
    rla
    rr c
    rla
    rr c
    rla
    add a, b
    sra a
    sra a
    sra a
    sra a
    ret

;############## Frame initialize / random numbers

frame_init:
    kld(hl, (game_timer))                 ; count frame
    inc hl
    kld((game_timer), hl)

    bit 0, l                             ; count down score
    ret z
    kld(hl, (time_score))
    ld a, h
    or l
    ret z
    dec hl
    kld((time_score), hl)
    ret 

init_rand:
    kld(hl, (game_timer))                 ; seed random numbers
    kld(a, (player_x))
    rlca
    xor l
    xor h
    rlca
    rlca
    rlca
    ld e, a
    ld d, 0
    kld(hl, img_enemy_4)
    add hl, de
    kld((FAST_RANDOM + 2), hl)
    ret
        

FAST_RANDOM:
    push hl
    ld hl, 0
    ld a, (hl)
    inc hl
    rrca
    add a, (hl)
    inc hl
    rrca
    xor (hl)
    inc hl
    kld((FAST_RANDOM + 2),hl)
    pop hl
    ret
