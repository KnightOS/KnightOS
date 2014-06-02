;##################################################################
;
;   Phoenix-Z80 (External level handling for TI-82/83/83+)
;
;   Programmed by Patrick Davidson (pad@calc.org)
;        
;   Copyright 2007 by Patrick Davidson.  This software may be freely
;   modified and/or copied with no restrictions.  There is no warranty.
;
;   This file was last updated August 10, 2007.
;
;##################################################################     

;############## Basic searching functions

#ifdef __TI82__
#define GET_START ld hl,program_end
#endif

#ifndef __TI82__
#define GET_START ld hl,(progptr)
#endif

;############## Level selector

lsup:   xor     a
        cp      e
        jr      z,select_loop
        ld      (CURSOR_ROW),de
        dec     e
lsmove: ld      a,32
        push    de
        ROM_CALL(TX_CHARPUT)
        pop     de
        ld      (CURSOR_ROW),de
        ld      a,'*'
        push    de
        ROM_CALL(TX_CHARPUT)
        pop     de
        jr      select_loop

lsdown: ld      a,(misc_flags)
        cp      e
        jr      z,select_loop
        ld      (CURSOR_ROW),de
        inc     e
        jr      lsmove

level_selector:
        ROM_CALL(CLEARLCD)
        ld      de,0
        ld      (CURSOR_ROW),de
        ld      hl,default_msg
        ROM_CALL(D_ZT_STR)

        call    show_list

        ld      a,(misc_flags)
        or      a
        ret     z

        ld      de,0
select_loop:
        call    GET_KEY
        cp      KEY_CODE_UP
        jr      z,lsup
        cp      KEY_CODE_DOWN
        jr      z,lsdown
        cp      KEY_CODE_CLEAR
        jp      z,game_exit
        cp      KEY_CODE_DEL
        jp      z,game_exit
        cp      KEY_CODE_MODE
        jp      z,game_exit
        cp      KEY_CODE_ENTER
        jr      nz,select_loop

        ld      a,e
        ld      (extlevel),a
        or      a
        ret     z

find_ext_lev:
        ld      b,a
        GET_START
loop_hunt:
        push    bc
        call    memory_scan
        ld      (memory_exchange+1),bc
        pop     bc
        ex      de,hl
        djnz    loop_hunt

        ex      de,hl
        inc     hl

        ld      de,level_name
        ld      bc,8
        ldir

load_external_level:
        xor     a
        ld      (check_restore),a
        ld      (saved_flag),a

        ld      de,$F00C
        ld      (level_addr),de
        ld      (restore_mem+1),hl

memory_exchange:
        ld      bc,$c00
        jp      exchange

;############## Restore game saved in external level

extlevel_saved:
        GET_START
el_search:
        call    memory_scan
        jr      nz,load_error
        push    de
        ld      b,8
        ld      de,level_name
evloop: inc     hl
        ld      a,(de)
        cp      (hl)
        jr      nz,els_nomatch
        inc     de
        djnz    evloop

        inc     hl
        call    load_external_level
        ld      a,1
        ld      (extlevel),a
        jp      pre_main_loop

els_nomatch:
        pop     hl
        jr      el_search

;############## Get list of levels

show_list:
        xor     a
        ld      (misc_flags),a

        GET_START
loop_list:
        call    memory_scan
        ret     nz

        push    de

        ld      de,misc_flags
        ld      a,(de)
        inc     a
        ld      (de),a
        ld      (CURSOR_ROW),a
        ld      a,2
        ld      (CURSOR_COL),a

        ld      b,8
ldisp:  inc     hl
        push    bc
        push    hl
        ld      a,(hl)
        ROM_CALL(TX_CHARPUT)
        pop     hl
        pop     bc
        djnz    ldisp

        pop     hl

        ld      a,(misc_flags)
        cp      7
        ret     z
        jr      loop_list

;############## Display loading error message

load_error:
        ld      hl,0
        ld      (CURSOR_ROW),hl
        ld      hl,load_error_msg
        ROM_CALL(D_ZT_STR)
error_loop:
        call    GET_KEY
        cp      KEY_CODE_CLEAR
        jp      z,game_exit
        cp      KEY_CODE_1
        jr      nz,error_loop

        xor     a
        ld      (saved_flag),a
        ld      (extlevel),a
        ld      sp,(initsp+1)
        jp      no_saved_game

load_error_msg:
        .db     "ERROR:  Unable  "
        .db     "to locate level "
        .db     "you saved the   "
        .db     "game in.  Press "
        .db     "1 to start a new"
        .db     "game, or CLEAR  "
        .db     "to exit.",0

;############## Memory searching
;
; Searches the memory for external level files.  On the Ion version, this
; is a simple call to ionDetect.  For the TI-82, it manually searches the
; memory for the corre  ct type of data.
;
; Called with HL pointing to the area to begin the search
;
; Returns with:
;
; zero flag set for success, clear for error
; A, IX destroyed
; DE pointing to place to resume search at
; HL pointing to one byte before of the data
; BC holds the "size" of data to copy

#ifndef __TI82__
identification:
        .db     "pHX",0

memory_scan:
        ld      ix,identification
        call    ionDetect
        ret     nz
#endif

#ifdef __TI82__

scan_done:
        inc     a
        ret

match_strings:
        ld      a,(de)
        cp      (hl)
        ret     nz              ; indicates no match
        inc     hl
        inc     de
        cp      $c9
        ret     z               ; indicates end of strings
        jr      match_strings

identification1:
        .db     "Levels for Phoenix",0,$c9

identification2:
        .db     "pHx",$c9

memory_scan:
        ld      a,h
        or      l
        jr      z,scan_done

        inc     hl              ; HL -> next place to search
        push    hl
        ld      de,identification1
        call    match_strings
        ex      de,hl           ; DE -> end of checked place in memory
        pop     hl
        jr      nz,memory_scan  ; search at next position if no match

        push    hl
        push    de
        ex      de,hl           ; HL -> end of checked place in memory
        call    DO_LD_HL_MHL    ; HL = offset of level end
        pop     bc              ; BC -> end of checked place in memory
        push    bc
        add     hl,bc           ; HL -> supposed end of level
        ld      de,identification2
        call    match_strings
        pop     de              ; DE -> end of checked place in memory
        pop     hl              ; HL -> next place to search
        jr      nz,memory_scan  ; search at next position if invalid

        ex      de,hl           ; DE -> next search, HL -> data - 2
        inc     hl
#endif

calculate_size:
        push    de
        ld      de,$F26E        ; Is end of max size past stack start?
        call    DO_CP_HL_DE
        pop     de
        ld      bc,$c00
        jr      c,scan_found    ; If not, return maximum as "size"

        push    hl
        ld      b,h
        ld      c,l             ; BC = start
        and     a
        ld      hl,$FE6E
        sbc     hl,bc           ; HL = end-start
        ld      b,h
        ld      c,l             ; BC = end-start
        pop     hl

scan_found:
        xor     a
        ret

;############## Messages

default_msg:
        .db     "* Built-In World",0
