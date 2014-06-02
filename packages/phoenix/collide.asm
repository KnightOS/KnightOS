;##################################################################
;
;   Phoenix-Z80 (Collision detection)
;
;   Programmed by Patrick Davidson (pad@calc.org)
;        
;   Copyright 2001 by Patrick Davidson.  This software may be freely
;   modified and/or copied with no restrictions.  There is no warranty.
;
;   This file was last updated March 30, 2001.
;
;##################################################################     

;############## Test for collisions between two objects
;
; Carry flag set if they collided, clear if they didn't
; Each object's information is in a structure consisting of four bytes:
;    X-Coordinate, Width, Y-Coorinate, Height in that order
; Routine takes one object pointed to by HL, other in test_coords

collision_check:

;############## Ensure that X1 < X2 + W2

        ld      de,(test_coords)    ; E = X2, D = W2
        ld      a,(hl)              ; A = X1
        sub     e                   ; A = X1 - X2
        jr      c,cc1               ; (X1 < X2) --> (X1 < X2 + W2)
        cp      d
        ret     nc                  ; Exit if (X1 - X2) >= W2
        inc     hl
        jr      cc2                 ; (X2 <= X1) --> (X2 < X1 + W1)

;############## Ensure that X2 < X1 + W1

cc1:    neg                         ; A = X2 - X1 (which is > 0)
        inc     hl
        cp      (hl)
        ret     nc                  ; Exit if (X2 - X1) >= W1

;############## Ensure that Y1 < Y2 + H2

cc2:    ld      de,(test_coords+2)  ; E = Y2, D = H2
        inc     hl
        ld      a,(hl)              ; A = Y1
        sub     e                   ; A = Y1 - Y2
        jr      c,cc3               ; (Y1 < Y2) --> (Y1 < Y2 + H2)
        cp      d                   ; Carry set if (Y1 - Y2) < H2
        ret                         ; End of testing (last cond. certain
                                    ; since Y2 <= Y1, due to jr c,cc3)

;############## Ensure that Y2 < Y1 + H1

cc3:    neg                         ; A = Y2 - Y1 (which is > 0)
        inc     hl
        cp      (hl)
        ret                         ; Carry set if (Y2 - Y1) < H1
