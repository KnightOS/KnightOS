;##################################################################
;
;   Phoenix-Z80 (Memory area swapping routine)
;
;   Programmed by Patrick Davidson (pad@calc.org)
;        
;   Copyright 2001 by Patrick Davidson.  This software may be freely
;   modified and/or copied with no restrictions.  There is no warranty.
;
;   This file was last updated November 24, 2001.
;
;##################################################################     

;############## MEMORY EXCHANGE ROUTINE
; Moves BC bytes of memory from (HL) to (DE)
; Backs up original contents of destination into source
; If overlapping regions, part of destination to be backed up is placed in
; non-overlapped part of source

exchange:
        call    DO_CP_HL_DE
        jr      c,move_down

exir:   ld      a,(de)
        ldi
        dec     hl
        ld      (hl),a
        inc     hl
        ld      a,b
        or      c
        jr      nz,exir
        ret

move_down:
        dec     bc
        add     hl,bc
        push    hl
        ex      de,hl
        add     hl,bc
        pop     de
        inc     bc

exdr:   ld      a,(de)
        ldd
        inc     hl
        ld      (hl),a
        dec     hl
        ld      a,b
        or      c
        jr      nz,exdr
        ret
