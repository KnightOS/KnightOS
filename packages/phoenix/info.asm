;##################################################################
;
;   Phoenix - information display
;
;   Programmed by Patrick Davidson (pad@calc.org)
;        
;   Copyright 2005 by Patrick Davidson.  This software may be freely
;   modified and/or copied with no restrictions.  There is no warranty.
;
;   This file was last updated November 25, 2005.
;
;##################################################################

;############## Add two four-digit packed BCD numbers
;
; HL -> destination + 1
; DE -> source + 1
;
; Returns with the C flag 0 if no carry out, 1 if carry out.

ADD_BCD:
        ld      b,2
        and     a
loop_bcd:
        ld      a,(de)
        adc     a,(hl)
        daa
        ld      (hl),a
        dec     hl
        dec     de
        djnz    loop_bcd
        ret

;############## Compares BCD numbers
;
; HL ->number to subtract from other
; DE ->number
;
; Returns with flags indicating comparion results.  Changes A, B, DE, HL.

CP_BCD: ld      b,2
cmpl:   ld      a,(de)
        cp      (hl)
        ret     nz
        inc     de
        inc     hl
        djnz    cmpl
        ret

;############## Convert binary money back to decimal

convert_to_decimal:
        ld      hl,(player_cash)
        ROM_CALL(UNPACK_HL)
        ld      d,a
        ROM_CALL(UNPACK_HL)
        add     a,a
        add     a,a
        add     a,a
        add     a,a
        or      d
        ld      d,a
        ROM_CALL(UNPACK_HL)
        ld      e,a
        ROM_CALL(UNPACK_HL)
        add     a,a
        add     a,a
        add     a,a
        add     a,a
        or      e
        ld      e,a
        ld      (decimal_cash),de
        ret

;############## Display hex/BCD numbers in special text (4 digits)
;
; HL -> location of number in memory
; DE -> graphics buffer address (upper-left corner of number)

display_number_bcd:
        ld      b,2
main_bcd_display:
        ld      a,(hl)
        push    de
        push    hl
        push    bc
        call    display_a_bcd
        pop     bc
        pop     hl
        pop     de
        inc     de
        inc     hl
        djnz    main_bcd_display
        ret

display_a_bcd:
        push    af                      ; Save character
        and     15                      ; A = low digit
        ld      c,a
        add     a,a
        add     a,a                   
        add     a,c
        ld      c,a
        ld      b,0
        ld      hl,digit_images
        add     hl,bc                   ; HL -> start of image

        ex      de,hl                   ; DE -> char image, HL -> screen
        push    hl                      ; Save screen address
        ld      c,16
        ld      a,5
loop_copy_digit:
        push    af
        ld      a,(de)
        xor     (hl)
        ld      (hl),a
        pop     af
        inc     de
        add     hl,bc
        dec     a
        jr      nz,loop_copy_digit
        pop     de
                                        ; Restore screen address in DE
        pop     af
        rrca
        rrca
        rrca
        rrca
        and     15
        ld      c,a
        add     a,a
        add     a,a                    
        add     a,c
        ld      c,a
        ld      hl,digit_images
        add     hl,bc                   ; HL -> start of image

        ex      de,hl                   ; DE -> char image, HL -> screen
        ld      c,16
        ld      a,5
loop_or_digit:
        push    af
        ld      a,(de)
        add     a,a
        add     a,a
        add     a,a
        add     a,a
        xor     (hl)
        ld      (hl),a
        pop     af
        inc     de
        add     hl,bc
        dec     a
        jr      nz,loop_or_digit
        ret
        
digit_images:
        .db     %000000100
        .db     %000001010
        .db     %000001010
        .db     %000001010
        .db     %000000100

        .db     %000000100
        .db     %000000100
        .db     %000000100
        .db     %000000100
        .db     %000000100

        .db     %000000100
        .db     %000001010
        .db     %000000010
        .db     %000000100
        .db     %000001110

        .db     %000001100
        .db     %000000010
        .db     %000001100
        .db     %000000010
        .db     %000001100

        .db     %000001010
        .db     %000001010
        .db     %000001110
        .db     %000000010
        .db     %000000010

        .db     %000001110
        .db     %000001000
        .db     %000001100
        .db     %000000010
        .db     %000001100

        .db     %000000110
        .db     %000001000
        .db     %000001100
        .db     %000001010
        .db     %000000100

        .db     %000001110
        .db     %000000010
        .db     %000000010
        .db     %000000100
        .db     %000000100

        .db     %000000100
        .db     %000001010
        .db     %000000100
        .db     %000001010
        .db     %000000100

        .db     %000000100
        .db     %000001010
        .db     %000000110
        .db     %000000010
        .db     %000001100
