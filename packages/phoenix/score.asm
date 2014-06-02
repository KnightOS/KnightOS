;##################################################################
;
;   Phoenix-Z80 (High scores)
;
;   Programmed by Patrick Davidson (pad@calc.org)
;        
;   Copyright 2007 by Patrick Davidson.  This software may be freely
;   modified and/or copied with no restrictions.  There is no warranty.
;
;   This file was last updated August 10, 2007..
;
;##################################################################     

scoring_msg:
        .db     "Shields",0
        .db     "Speed",0
        .db     "Bonus",0
        .db     "Money",0
        .db     0
        .db     "Score",0
        .db     0
        .db     "  Press (ENTER)",0
        .db     -1

highscore_title:
        .db     "   High Scores",0

highscore_prompt:
        .db     " Enter your name",0

;############## Calculate and display player's score

game_finished:
        ld      hl,completed
        ld      a,(hl)
        or      a
        jp      nz,no_high_score
        ld      (hl),1

        call    synchronize
        call    synchronize

#ifndef __TI82__
        call    restore_memory
#endif

        ROM_CALL(CLEARLCD)
        ld      hl,scoring_msg
        call    display_hl_msgs

        ld      hl,$0B03
        ld      (CURSOR_ROW),hl
        ld      hl,(player_cash)        ; max 10000
        ROM_CALL(D_HL_DECI)

        ld      hl,$0B02
        ld      (CURSOR_ROW),hl
        ld      hl,(bonus_score)        ; max 20000
        ROM_CALL(D_HL_DECI)

        ld      hl,$0B01
        ld      (CURSOR_ROW),hl
        ld      hl,(time_score)         ; max 19000
        ROM_CALL(D_HL_DECI)

        ld      a,(player_pwr)          ; max 16000
        ld      hl,0
        ld      de,1000
        or      a
        jr      z,shield_done
        ld      b,a
shield_addup:
        add     hl, de
        djnz    shield_addup
shield_done:
        push    hl
        ld      de,(time_score)
        add     hl,de
        ld      de,(bonus_score)
        add     hl,de
        ld      de,(player_cash)
        add     hl,de
        ld      (bonus_score),hl

        ld      de,$0B05
        ld      (CURSOR_ROW),de
        ROM_CALL(D_HL_DECI)

        ld      hl,$0B00
        ld      (CURSOR_ROW),hl
        pop     hl
        ROM_CALL(D_HL_DECI)

loop_show_score:
        call    GET_KEY
        cp      KEY_CODE_ENTER
        jr      nz,loop_show_score

        ld      a,(extlevel)
        or      a
        jp      nz,restart

;############## Check if you have high score

        ld      hl,(high_scores_end)            ; Check against lowest score
        ld      de,(bonus_score)
        call    DO_CP_HL_DE
        jr      nc,no_high_score

        ld      (high_scores_end),de            ; Put your score in bottom
        ld      hl,high_scores+(13*6)
        ld      b,10
loop_space:
        ld      (hl),' '
        inc     hl
        djnz    loop_space
        
        ld      b,6                             ; Bubble it towards the top
        ld      de,high_scores_end              ; DE -> entry to move up
loop_bubble:                                    
        ld      hl,-13
        add     hl,de                           ; HL -> entry to compare with

        push    de

        call    DO_LD_HL_MHL                    ; HL = score above this one
        push    hl
        ex      de,hl
        ld      e,(hl)
        inc     hl
        ld      d,(hl)                          ; DE = this score
        pop     hl
        call    DO_CP_HL_DE
        pop     de                              ; DE -> this entry
        jr      nc,no_bubble_up

        inc     de                              ; DE -> very end of entry
        ld      hl,-13
        add     hl,de                           ; HL -> previous entry
        push    bc
        ld      b,13
loop_exchange:
        ld      a,(de)
        ld      c,a
        ld      a,(hl)
        ld      (de),a
        ld      (hl),c
        dec     hl
        dec     de
        djnz    loop_exchange
        pop     bc
        dec     de                              ; DE -> previous entry

        djnz    loop_bubble

no_bubble_up:
        ld      hl,-11
        add     hl,de

        push    hl
        push    bc
        call    display_high_scores
        ld      hl,0
        ld      (CURSOR_ROW),hl
        ld      hl,highscore_prompt
        ROM_CALL(D_ZT_STR)
        pop     bc
        pop     hl
        inc     b
        ld      c,b
        ld      b,0
        ld      (CURSOR_ROW),bc
        call    input_name

;############## Show high scores

no_high_score:
        call    display_high_scores
        ld      hl,0
        ld      (CURSOR_ROW),hl
        ld      hl,highscore_title
        ROM_CALL(D_ZT_STR)
        call    loop_show_highs
        jp      restart

loop_show_highs:
        call    GET_KEY
        cp      6
        jr      c,loop_show_highs
        ret

;############## Prompt for name entry

input_name:
        push    hl
        pop     ix

#ifdef HORRIBLE_KEYBOARD
        push    hl
        ld      b,0
redraw_name:
        xor     a
        ld      (CURSOR_COL),a
        pop     hl
        push    hl
        ROM_CALL(D_ZT_STR)
lame_entry_loop:
        call    GET_KEY
        cp      KEY_CODE_ENTER
        jr      z,lame_exit
        cp      KEY_CODE_LEFT
        jr      z,lame_left
        cp      KEY_CODE_RIGHT
        jr      z,lame_right
        cp      KEY_CODE_UP
        jr      z,lame_up
        cp      KEY_CODE_DOWN
        jr      nz,lame_entry_loop

lame_down:
        ld      a,(ix)
        dec     a
        cp      ' ' -  1
        jr      nz,nbs
        ld      a,'Z'
nbs:    cp      'A' - 1
        jr      rs

lame_exit:
        pop     hl
        ret

lame_left:
        xor     a
        cp      b
        jr      z,lame_entry_loop
        dec     b
        dec     ix
        jr      lame_entry_loop

lame_right:
        ld      a,9
        cp      b
        jr      z,lame_entry_loop
        inc     b
        inc     ix
        jr      lame_entry_loop

lame_up:
        ld      a,(ix)
        inc     a
        cp      ' ' + 1
        jr      nz,nps
        ld      a,'A'
nps:    cp      'Z' + 1
rs:     jr      nz,nrs
        ld      a,' '
nrs:    ld      (ix),a
        jr      redraw_name

#else
enter_name_loop:
        call    GET_KEY
        or      a
        jr      z,enter_name_loop
        cp      KEY_CODE_DEL
        jr      z,backup
        cp      KEY_CODE_ENTER
        ret     z
        ld      c,a
        ld      a,10
        cp      b
        jr      z,enter_name_loop
        ld      hl,chartable-10
        ld      e,c
        ld      d,0
        add     hl,de
        ld      a,(hl)
        ld      (ix),a
        ROM_CALL(TX_CHARPUT) 
        inc     b
        inc     ix
        jr      enter_name_loop
backup: xor     a
        cp      b
        jr      z,enter_name_loop
        dec     b
        dec     ix
        ld      (ix),32
        ld      hl,CURSOR_COL
        dec     (hl)
        ld      a,32
        ROM_CALL(TX_CHARPUT)
        dec     (hl)
        jr      enter_name_loop

chartable:
        .db     ":WRMH."
        .db     "..0VQLG!..ZUPKFC"
        .db     "..YTOJEBX.>SNIDA"
        .db     ".12345.."
#endif

;############## Display the high score table

display_high_scores:
#ifndef __TI82__
        call    restore_memory
#endif

        ROM_CALL(CLEARLCD)
        call    GET_KEY

        ld      hl,high_scores
        ld      b,7
        ld      a,1
        ld      (CURSOR_ROW),a
loop_display_hs:
#ifdef __TI82__
        push    bc
#endif
        xor     a
        ld      (CURSOR_COL),a
        push    hl
        ROM_CALL(D_ZT_STR)
        pop     hl
        ld      de,11
        add     hl,de
        push    hl
        call    DO_LD_HL_MHL
        ld      a,$b
        ld      (CURSOR_COL),a
        ROM_CALL(D_HL_DECI)
#ifdef TI83P
        ld      hl,CURSOR_ROW
        inc     (hl)
#endif
        pop     hl
        inc     hl
        inc     hl
#ifdef __TI82__
        pop     bc
#endif
        djnz    loop_display_hs
        ret
        ret
