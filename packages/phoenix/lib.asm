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

DO_CP_HL_DE:
    push    hl
    and     a
    sbc     hl,de
    pop     hl
    ret

;############## Synchronization
;
;synchronize:
;        ei
;        ld      hl,timer
;        ld      a,(speed)
;        cp      (hl)
;        jr      c,too_slow
;
;loop_wait:
;        cp      (hl)            ; Test value of 4 - (timer)
;        jr      nc,loop_wait    ; NC : timer <= 4
;        ld      (hl),0
;
;        ret
;
;too_slow:
;        ld      (hl),0
;        ret
;
;timer_interrupt:
;        push    af
;        push    hl
;        ld      hl,timer
;        inc     (hl)
;        pop     hl
;        pop     af
;#ifdef __MIRAGE__
;        ret
;#else
;        jp      $38
;#endif
;timer_interrupt_end:

; NOTE: Contrast adjustment removed from this part
