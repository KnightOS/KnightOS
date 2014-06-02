;##################################################################
;
;   Phoenix-Z80 (Collisions between enemies and player's bullets)
;
;   Programmed by Patrick Davidson (pad@calc.org)
;        
;   Copyright 2002 by Patrick Davidson.  This software may be freely
;   modified and/or copied with no restrictions.  There is no warranty.
;
;   This file was last updated June 29, 2002.  
;
;##################################################################

;############## Builds table of enemies in GFX_AREA
;
; This puts enemies into columns, 0 to 7, on the high bits of their X
; coordinates.  Column 0 is for X coordinates 0 to 15, 1 for 16 to 31, and
; so on.  Then, they are split into groups; for enemies in only 1 column,
; the group is column * 2 + 1, for enemies that spill into the next column,
; the group is column * 2 + 2.
;
; Each group data structure has a one-byte size, followed by a list of
; pointers to each enemy in the group.  The first column starts at
; GFX_AREA+48, the next at GFX_AREA+96, and so on.  Empty columns are put
; at the edges to allow proper checking of side bullets.  This allows up to
; 23 entries per column, more than enough to accomodate all enemies.

hit_enemies:
        xor     a                       ; Initialize all columns as empty
        ld      b,19
        ld      de,48
smc_test_1:
        ld      hl,GFX_AREA
loop_empty_columns:
        ld      (hl),a
        add     hl,de
        djnz    loop_empty_columns

        ld      hl,e_array              ; HL -> enemy
        ld      b,e_num                 
build_table_loop:
        ld      a,(hl)                  ; Skip empty enemy entries
        or      a
        jr      z,none_here
        inc     a
        jr      z,none_here 

        ld      de,e_x
        add     hl,de
        ld      a,(hl)                  ; A = enemy X coordinate
        inc     hl
        ld      e,(hl)                  ; E = enemy width
        dec     hl
        dec     hl
        dec     hl
        dec     hl
        dec     hl
        dec     hl                      ; HL -> start of enemy
        or      a
        jr      z,none_here             ; Skip non-ready enemies

        call    which_group             ; Compute group number in A

        ld      c,a
        add     a,a                     ; A = 2 * group number
        add     a,c                     ; A = 3 * group number
        add     a,a
        add     a,a                     ; A = 12 * group number

        push    hl

        ld      l,a
        ld      h,0                     ; HL = 12 * group number
        add     hl,hl
        add     hl,hl                   ; HL = 48 * group number
smc_test_2:
        ld      de,GFX_AREA
        add     hl,de                   ; HL -> group data structure

        ld      a,(hl)                  ; A = group size before insertion
        inc     (hl)                    ; increment group size
        add     a,a
        inc     a
        call    ADD_HL_A                ; HL = new entry in group     

        pop     de                      ; DE -> enemy
        ld      (hl),e                  ; store DE in group
        inc     hl
        ld      (hl),d
        ex      de,hl                   ; HL -> enemy

none_here:
        ld      de,e_size
        add     hl,de
        djnz    build_table_loop

;############## Process player bullets
;
; This routine will process every player bullet by checking it for collisions
; with appropriate columns.  If it is all in one column, it must be tested
; against three groups, as shown below
;
; Column 2     |     Column 3      |     Column 4
;              |                   |
;               <-----Bullet------>
;     <---Enemy group 6--->
;               <--Enemy group 7-->
;                         <---Enemy group 8--->
;
; If the bullet straddles two columns, it then must be checked against
; five groups of enemies, as indicated below
;
; Column 2     |    Column 3       |     Column 4     |      Column 5
;              |                   |                  |
;                      <--------Bullet-------->
;    <---Enemy group 6--->
;               <--Enemy group 7-->
;                      <-----Enemy group 8---->
;                                   <-Enemy group 9-->
;                                           <---Enemy group 10--->
;
; Even so, this still saves a lot of time over the default collision testing
; strategy, to test all combinations of objects, which would effectively
; require testing with 15 groups in all cases (though without the sorting
; overhead introduced here).

        ld      hl,pb_array
        ld      b,pb_num

loop_process_bullets:
        ld      a,(hl)
        or      a          
        jr      z,no_bullet

        push    hl
        push    bc

        ld      (collision+1),hl
        inc     hl
        inc     hl
        ld      a,(hl)
        inc     hl
        ld      e,(hl)
        dec     hl

        call    which_group             ; A = group number

        ld      de,test_coords          ; Copy bullet data to test coords
        ldi
        ldi
        ldi
        ldi

        ld      b,a
        dec     a                       
        ld      c,a
        add     a,a                     ; A = 2 * group number
        add     a,c                     ; A = 3 * group number
        add     a,a
        add     a,a                     ; A = 12 * group number

        ld      l,a
        ld      h,0                     ; HL = 12 * group number
        add     hl,hl
        add     hl,hl                   ; HL = 48 * group number
smc_test_3:
        ld      de,GFX_AREA
        add     hl,de                   ; HL -> group data structure
                                        
        bit     0,b
        jr      nz,check_3_groups

check_5_groups:
        call    list_collision_check
        ld      bc,-48
        add     hl,bc
        call    list_collision_check
        ld      bc,96
        add     hl,bc
check_3_groups:
        call    list_collision_check
        ld      bc,48
        add     hl,bc
        call    list_collision_check
        ld      bc,48
        add     hl,bc
        call    list_collision_check

        pop     bc
        pop     hl

no_bullet:
        ld      de,pb_size
        add     hl,de
        djnz    loop_process_bullets
        ret

;############## Determine which group object is in
;
; Determines which group an object is in.  A holds the X coordinate, E holds
; the width.  Returns results in A.  Modifies A, C, and D.

which_group:
        ld      d,a
        rlca
        rlca
        rlca
        rlca
        and     7
        add     a,a
        inc     a
        ld      c,a
        ld      a,d
        and     15
        add     a,e
        cp      16
        ld      a,c
        ret     c 
        inc     a
        ret

;############## Check bullet for collisions within one group
;
; Checks the bullet whose data is int test_coords with group (HL)

list_collision_check:
        push    hl
        ld      a,(hl)
        or      a
        jr      z,exit_cc_list
        inc     hl                  ; HL -> group data
        ld      b,a                 ; B = number in group

loop_column_scan:
        push    hl                  ; HL -> somewhere in the list
        ld      a,(hl)
        inc     hl
        ld      h,(hl)
        ld      l,a                     ; HL -> item retrieved from list
        ld      de,e_x
        push    hl
        add     hl,de
        call    collision_check
        pop     hl
        jr      c,collision
        pop     hl
        inc     hl                      ; Move HL to next in list
        inc     hl
        djnz    loop_column_scan

exit_cc_list:
        pop     hl
        ret
                
collision:
        ld      de,0                    ; DE -> bullet (smc)
        ex      de,hl                   ; DE -> enemy, HL -> bullet

        ld      (hl),0                  ; Delete bullet
        inc     hl
        ld      c,(hl)                  ; C = bullet damage

        ld      hl,e_pwr
        add     hl,de                   ; HL -> enemy damage
        ld      a,(hl)
        sub     c
        ld      (hl),a
        jr      z,collision_yes
        jr      nc,collision_done       ; If enemy not destroyed
collision_yes:

        ex      de,hl
        ld      (hl),-1                 ; Enemy power to -1
        inc     hl
        ld      (hl),EM_NONE            ; exploding enemy not moving
        ld      de,e_imageseq-1
        add     hl,de
        ld      (hl),2                  ; set image to exploding
        inc     hl
        ld      de,explosion_sequence+1
        ld      (hl),e
        inc     hl
        ld      (hl),d
        inc     hl
        ld      (hl),FT_NONE            ; explosion doesn't shoot

collision_done:
        ld      sp,0
        pop     bc
        pop     hl
        jr      no_bullet
