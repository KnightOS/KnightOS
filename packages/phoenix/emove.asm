;##################################################################
;
;   Phoenix-Z80 (Enemy moving)
;
;   Programmed by Patrick Davidson (pad@calc.org)
;        
;   Copyright 2007 by Patrick Davidson.  This software may be freely
;   modified and/or copied with no restrictions.  There is no warranty.
;
;   This file was last updated October 28, 2007.
;                                           
;##################################################################     

enemy_move:
        inc     hl
        ld      a,(hl)
        ld      (enemy_move_select+1),a

enemy_move_select:
        jr      enemy_move_table
enemy_move_table:
        jp      em_standard_swing       ; 0
        ret                             ; 3
        jp      boss_move               ; 4
        jp      em_bouncing             ; 7
        jp      pattern_init            ; 10
        jp      pattern_wait            ; 13
        jp      pattern_move            ; 16
        jp      rampage                 ; 19
        jp      rampage_wait            ; 22
        jp      swoop_horiz             ; 25
        jp      swoop_down              ; 28
        jp      swoop_up                ; 31
        jp      swoop_enemy_wait        ; 34
                                        ; 37

;############## Enemy which rampages initially

rampage_init:
        ld      (hl),EM_RAMPAGE
        inc     hl
        inc     hl
        ld      (hl),1
        inc     hl
        ld      (hl),1
        inc     hl
        call    FAST_RANDOM
        and     63
        add     a,28
        ld      (hl),a
        inc     hl
        inc     hl
        call    FAST_RANDOM
        and     8
        ld      (hl),a
        ret

;############## Swooping enemy waiting to enter

swoop_enemy_wait:
        ld      a,(game_timer)
        and     15
        ret     nz
        call    FAST_RANDOM             ; Choose pattern (0 - 3)
        and     %1100
        ld      (smc_hl_storage+1),hl
        ld      hl,swoop_data
        call    ADD_HL_A                ;HL -> pattern data
        ld      de,misc_flags           ;DE -> flags of which patterns used
        ld      a,(de)
        and     (hl)                    ;Check flag; if already set, exit
        ret     nz                      ;since this pattern already entered
        ld      a,(de)                  
        or      (hl)
        ld      (de),a                  ;set the flag

smc_hl_storage:
        ld      de,0                    ;DE -> enemy data
        ld      a,EM_SWOOPDOWN
        ld      (de),a                  ;set type to swooping down
        inc     hl                      ;HL -> entry
        inc     de                      
        inc     de                      ;DE -> e_movedata+1
        ldi                             ;copy Y destination
        ldi                             ;copy X destination
        ldi                             ;copy X entry
        inc     de
        ld      a,2
        ld      (de),a                  ;Y = 2
        ret

;############## Swooping enemy data
;
; Flag bit mask, Y destination, X destination, X entry

swoop_data:                     
        .db     1,59,102,14
        .db     2,50,30,90
        .db     4,41,78,42
        .db     8,32,54,66

;############## Swooping horizontally
;
; e_movedata+1 holds X velocity
; e_movedata+2 holds X coordinate of destinatin

swoop_horiz:
        inc     hl
        inc     hl                      ;HL -> e_phase
        ld      a,(hl)                  ;A = X velocity
        inc     hl
        inc     hl                      ;HL -> X coordinate
        add     a,(hl)
        ld      (hl),a                  ;Update X coordinate
        dec     hl
        cp      (hl)                    ;Compare X coordinate to destination
        ret     nz
        dec     hl
        dec     hl
        dec     hl
        ld      (hl),EM_SWOOPUP
        ret

;############## Swooping enemy going up

swoop_up:
        ld      de,e_y-e_movetype
        add     hl,de
        dec     (hl)
        ret     nz
        ld      de,e_movetype-e_y
        add     hl,de
        ld      (hl),EM_SWOOPWAIT
        ret

;############## Swooping down
;
; e_phase holds Y coordinate of destination of this movement
; e_phase will hold X velocity for the horizontal movement
; e_timer holds X coordinate of destination of horizontal movement

swoop_down:
        ld      de,e_y-e_movetype
        push    hl
        add     hl,de                   ;HL -> e_y
        inc     (hl)                    ;Increment Y coordinate
        ld      a,(hl)                  ;Load Y coordinate into A
        pop     hl                      
        inc     hl                     
        inc     hl                      ;HL -> e_movedata+1
        cp      (hl)                    ;Compare to destination coordinate
        ret     nz                      ;Exit if not there      
        inc     hl                      ;HL -> e_movedata+2
        ld      a,(hl)                  ;A = X destination
        dec     hl
        ld      (hl),2                  ;Initially set X velocity to 2 
        bit     6,a                     ;Check if X destination >= 64
        jr      nz,swoop_not_left       ;If so, not going lef
        ld      (hl),-2                 ;If going left, change XV to -2
swoop_not_left:
        dec     hl
        dec     hl
        ld      (hl),EM_SWOOPHORIZ      ;Set type to horizontal movement
        ret 

;############## STANDARD ENEMY READY TO RAMPAGE

rampage_wait:
        ld      a,(enemies_left)
        cp      9
        jp      nc,em_standard_swing
        ld      (hl),EM_RAMPAGE
        inc     hl
        inc     hl
        inc     hl
        ld      (hl),-1
        dec     hl
        ld      (hl),-1
        jr      rampage2

;############## RAMPAGING ENEMY

rampage:
        inc     hl
        inc     hl
rampage2:
        ld      b,(hl)                  ; E = XV
        inc     hl
        ld      c,(hl)                  ; D = YV
        inc     hl
        ld      a,(hl)
        add     a,b                     ; A = new X
        ld      (hl),a
        ld      d,a                     ; D = new X
        cp      16
        jr      c,rampage_right
        cp      40
        jr      z,rampage_choosex
        cp      71
        jr      z,rampage_choosex
        cp      93
        jr      z,rampage_choosex
        cp      105
        jr      nc,rampage_left
rampage_xdone:
        inc     hl
        inc     hl                      ; HL -> e_y
        ld      a,(hl)
        add     a,c                     ; A = new Y
        ld      (hl),a
        ld      e,a                     ; E = new X
        cp      41
        jr      c,rampage_down
        cp      51
        jr      z,rampage_choosey
        cp      59
        jr      nc,rampage_up
rampage_ydone:
        dec     hl
        dec     hl
        dec     hl                      ; HL -> YV
        ld      (hl),c
        dec     hl                      ; HL -> VV
        ld      (hl),b
        ret

rampage_choosex:
        call    FAST_RANDOM
        rrca
        jr      c,rampage_left
rampage_right:
        ld      b,1
        jr      rampage_xdone
rampage_left:
        ld      b,-1
        jr      rampage_xdone

rampage_choosey:
        call    FAST_RANDOM
        rrca
        jr      c,rampage_up
rampage_down:
        ld      c,1
        jr      rampage_ydone
rampage_up:
        ld      c,-1
        jr      rampage_ydone

;############## PATTERN-BASED ENEMY MOVING

pattern_move:
        inc     hl
        ld      e,(hl)
        inc     hl
        ld      d,(hl)                  ; DE -> pattern data
        inc     hl
        ld      a,(de)                  ; A = segment length
        inc     (hl)
        cp      (hl)
        jr      nz,not_segment_end

        inc     de                      ; Advance DE to next segment
        inc     de
        inc     de
        ld      a,(de)
        or      a
        jr      nz,no_restart_sequence

        inc     de                      ; Load restart position from sequence
        ld      a,(de)                 
        ld      b,a
        inc     de
        ld      a,(de)
        ld      d,a
        ld      e,b

no_restart_sequence:
        dec     hl
        dec     hl
        ld      (hl),e
        inc     hl
        ld      (hl),d
        inc     hl
        ld      (hl),0

not_segment_end:
        inc     hl                      ; HL -> e_x
        inc     de                      ; DE -> X velocity
        ld      a,(de)
        call    Div_A_16
        add     a,(hl)
        ld      (hl),a

        inc     hl
        inc     hl                      ; HL -> e_y
        inc     de                      ; DE -> Y velocity
        ld      a,(de)
        call    Div_A_16
        add     a,(hl)
        ld      (hl),a
        ret

;############## PATTERN-BASED ENEMY WAITING TO ENTER

pattern_wait:
        ld      de,3
        add     hl,de
        dec     (hl)                    ; decrement countdown
        ret     nz
        dec     (hl)
        sbc     hl,de
        ld      (hl),EM_PATTERNMAIN     ; advance to in-pattern type
        add     hl,de
        add     hl,de
        ld      (hl),24                 ; set Y coordinate to 9
        ret

;############## INITIALIZE ENEMY IN PATTERN

pattern_init:
        ld      (hl),EM_PATTERNWAIT     ; advance type to waiting
        ld      de,e_y-e_movetype
        add     hl,de
        ld      a,(hl)                  ; A = given Y coordinate
        ld      (hl),110                ; set Y coordinate to 110
        dec     hl
        dec     hl
        ld      b,(hl)                  ; B = given X coordinate
        ld      (hl),a                  ; set X coordinate to Y value
        dec     hl
        ld      (hl),b                  ; set delay timer to Y coordinate
        ret

;############## BOUNCING ENEMY

em_bouncing:
        inc     hl
        ld      c,(hl)                  ; C = YV (bit 1 - right, bit 0 - fast)
        inc     hl
        ld      b,(hl)                  ; B = XV (bit 1 - down, bit 0 - fast)
        inc     hl
        inc     hl                      ; HL -> X

        ld      a,(game_timer)
        or      b
        rrca
        jr      nc,bounce_nox
        bit     1,b
        jr      z,bounce_left
bounce_right:
        inc     (hl)
        ld      a,107
        cp      (hl)
        jr      nz,bounce_nox
        dec     hl
        dec     hl
        call    FAST_RANDOM
        and     1
        ld      (hl),a
        inc     hl
        inc     hl
        jr      bounce_nox
bounce_left:
        dec     (hl)
        ld      a,13
        cp      (hl)
        jr      nz,bounce_nox
        dec     hl
        dec     hl
        call    FAST_RANDOM
        and     1
        or      2
        ld      (hl),a
        inc     hl
        inc     hl
bounce_nox:

        inc     hl
        inc     hl
        ld      a,(game_timer)
        or      c
        rrca
        ret     nc
        bit     1,c
        jr      z,bounce_up

bounce_down:
        inc     (hl)
        ld      a,60
        cp      (hl)
        ret     nz
        ld      bc,-5
        add     hl,bc
        call    FAST_RANDOM
        and     1
        ld      (hl),a
        ret

bounce_up:
        dec     (hl)
        ld      a,31
        cp      (hl)
        ret     nz
        ld      bc,-5
        add     hl,bc
        call    FAST_RANDOM
        and     1
        or      2
        ld      (hl),a
        ret 

;############## RECTANGULAR PATTERN ENEMY

em_standard_swing:
        inc     hl                      ; HL -> e_phase
        ld      a,(hl)
     
        ld      (which_phase+1),a
        inc     hl                      ; HL -> e_timer
        inc     (hl)
        ld      a,(hl)
        rrca
        ret     nc
        cp      $88
        jr      nz,not_phase_end

        ld      (hl),0
        dec     hl                      ; HL -> e_phase
        ld      a,(hl)
        add     a,4
        and     12
        ld      (hl),a
        inc     hl                      ; HL -> e_timer
not_phase_end:
        inc     hl
        inc     hl                      ; HL -> e_x

which_phase:
        jr      phase1
phase0: inc     hl
        inc     hl
        inc     (hl)
        ret
phase1: inc     (hl)
        inc     hl
        inc     hl
        ret
phase2: inc     hl
        inc     hl
        dec     (hl)
        ret
phase3: dec     (hl)
        ret

;############## BOSS

boss_move:
        inc     hl
        ld      a,(hl)
        or      a
        jr      z,boss_descending

        inc     hl
        dec     (hl)
        jr      nz,boss_no_reverse
        neg
        dec     hl
        ld      (hl),a
        inc     hl
        ld      (hl),90
boss_no_reverse:
        inc     hl
        inc     hl
        add     a,(hl)
        ld      (hl),a
        ret

boss_descending:
        inc     hl
        dec     (hl)
        jr      nz,not_entered
        dec     hl
        ld      (hl),-1
        inc     hl
        ld      (hl),83
not_entered:
        inc     hl
        inc     hl
        inc     hl
        inc     hl
        inc     (hl)
        ret
