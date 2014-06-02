;##################################################################
;
;   Phoenix-Z80 ("sprite" drawing routine)
;
;   Programmed by Patrick Davidson (pad@calc.org)
;        
;   Copyright 2005 by Patrick Davidson.  This software may be freely
;   modified and/or copied with no restrictions.  There is no warranty.
;
;   This file was last updated November 28, 2005.
;
;##################################################################     

#ifdef __85OR86__
#define COMBINE_HL xor (hl)
#define COMBINE_C  xor c
#else
#define COMBINE_HL or (hl)
#define COMBINE_C  or c
#endif

drw_spr_wide:
        ld      a,(hl)
        cp      9
        jr      c,drw_spr
dswl:   push    de
        push    hl
        call    drw_spr
        pop     hl
        pop     de
        ld      a,8
        add     a,d
        ld      d,a
        ld      b,(hl)
        inc     hl
        ld      a,(hl)
        inc     hl
        call    ADD_HL_A
        ld      a,8
        cp      b
        jr      c,dswl
        ret

MIN_Y   =32
MAX_Y   =96
                
clip_top:
        pop     hl              ; HL -> image data
        inc     hl
        add     a,(hl)          ; A = bottom Y coordinate + 1
        sub     MIN_Y+1         ; A = # of lines past 32 
        ret     c
        inc     a               ; A = number of lines on screen
        ld      b,a             ; B = number of lines to draw
        sub     (hl)
        neg                     ; A = number of lines skipped
        inc     a               ; A = number of bytes to skip
        
        add     a,l
        jr      nc,ctad
        inc     h
ctad:   ld      l,a             ; HL -> start of image data to use

        ld      a,d             ; A = X coordinate
        
        ex      de,hl           ; DE -> start of image data to use

smc_gfxmem_start:
        ld      hl,GFX_AREA
        rra
        rra
        rra
        and     15
        add     a,l
        ld      l,a             ; HL -> screen address
        jr      nc,drw_spr_main
        inc     h
        jr      drw_spr_main
        
drw_spr:
#ifdef __85OR86__
        ld      a,d                     ; A = X coordinate
#else
        ld      a,(x_offset)
        sub     d
        neg
        ld      d,a
        cp      112
        ret     nc
#endif
        and     7
        ld      b,a
        add     a,a
        add     a,b
        ld      (jumpintable+1),a       ; Save selected shift amount 
        
        push    hl                      ; Save sprite image pointer

        ld      b,0
smc_gfxmem_minus512:
        ld      hl,GFX_AREA-512         ; HL -> start of buffer
        ld      a,e

        cp      MIN_Y
        jr      c,clip_top

        ld      (smc_start_y_coord+1),a
        
        add     a,a                     ; A = Y * 2
        add     a,a
        rl      b                       ; BA = Y * 4
        add     a,a                    
        rl      b                       ; BA = Y * 8
        add     a,a
        rl      b                       ; BA = Y * 16
        ld      c,d             
        srl     c
        srl     c
        srl     c                       ; C = X / 8
        or      c
        ld      c,a
        add     hl,bc                   ; HL = Screen address

        ex      de,hl                   ; DE = Screen address

        pop     hl
        inc     hl
        ld      b,(hl)                  ; B = height
        inc     hl                      ; HL -> image

        ex      de,hl                   ; HL -> screen, DE -> image

smc_start_y_coord:
        ld      a,0                     ; Self-modification stores Y here
        cp      MAX_Y
        ret     nc
        add     a,b                     ; A = maximum Y coordinate
        cp      MAX_Y
        jr      c,drw_spr_main
        sub     b
        sub     MAX_Y
        neg
        ld      b,a        
                
drw_spr_main:   
        ld      c,0
        and     a
        
jumpintable:
        jr      table

table:
        jp      routine0
        jp      routine1
        jp      routine2
        jp      routine3
        jp      routine4
        jp      routine5
        jp      routine6

routine7:
        inc     hl
routine7l:
        ld      a,(de)          ;7
        inc     de              ;6

        add     a,a             ;4
        rl      c               ;8
        COMBINE_HL              ;7
        ld      (hl),a          ;7
        dec     hl              ;6
        ld      a,(hl)          ;7
        COMBINE_C               ;4
        ld      (hl),a          ;7

        ld      a,b             ;4
        ld      bc,17           ;10
        add     hl,bc           ;11
        ld      c,b             ;4
        ld      b,a             ;4
        djnz    routine7l
        ret

routine0:
        ld      c,16            ;7
routine0l:
        ld      a,(de)          ;7
        inc     de              ;6

        COMBINE_HL              ;7
        ld      (hl),a          ;7

        ld      a,c             ;4
        add     a,l             ;4
        ld      l,a             ;4
        jp      nc,done0        ;10
        inc     h               ;4
done0:
        djnz    routine0l
        ret

routine1:
        ld      a,(de)          ;7
        inc     de              ;6

        rra                     ;4
        rr      c               ;8
        COMBINE_HL              ;7
        ld      (hl),a          ;7
        inc     hl              ;6
        ld      a,(hl)          ;7
        COMBINE_C               ;4
        ld      (hl),a          ;7

        ld      a,b             ;4
        ld      bc,15           ;10
        add     hl,bc           ;11
        ld      c,b             ;4
        ld      b,a             ;4
        djnz    routine1
        ret

routine2:
        ld      a,(de)          ;7
        inc     de              ;6

        rrca                    ;4
        rrca                    ;4
        ld      c,a             ;4
        and     $3F             ;7
        COMBINE_HL              ;7
        ld      (hl),a          ;7
        ld      a,c             ;4
        and     $C0             ;7
        inc     hl              ;6
        COMBINE_HL              ;7
        ld      (hl),a          ;7

        ld      a,15            ;7
        add     a,l             ;4
        ld      l,a             ;4
        jp      nc,done2       ;10
        inc     h               ;4
done2:
        djnz    routine2
        ret

routine3:
        ld      a,(de)          ;7
        inc     de              ;6

        rrca                    ;4
        rrca                    ;4
        rrca                    ;4
        ld      c,a             ;4
        and     $1F             ;7
        COMBINE_HL              ;7
        ld      (hl),a          ;7
        ld      a,c             ;4
        and     $E0             ;7
        inc     hl              ;6
        COMBINE_HL              ;7
        ld      (hl),a          ;7

        ld      a,15            ;7
        add     a,l             ;4
        ld      l,a             ;4
        jp      nc,done3        ;10
        inc     h               ;4
done3:
        djnz    routine3
        ret

routine4:
        ld      a,(de)          ;7
        inc     de              ;6

        rrca                    ;4
        rrca                    ;4
        rrca                    ;4
        rrca                    ;4
        ld      c,a             ;4
        and     $0F             ;7
        COMBINE_HL              ;7
        ld      (hl),a          ;7
        ld      a,c             ;4
        and     $F0             ;7
        inc     hl              ;6
        COMBINE_HL              ;7
        ld      (hl),a          ;7

        ld      a,15            ;7
        add     a,l             ;4
        ld      l,a             ;4
        jp      nc,done4        ;10
        inc     h               ;4
done4:
        djnz    routine4        ;13
        ret

routine6:
        ld      a,(de)          ;7
        inc     de              ;6

        rlca                    ;4
        rlca                    ;4
        ld      c,a             ;4
        and     $03             ;7
        COMBINE_HL              ;7
        ld      (hl),a          ;7
        ld      a,c             ;4
        and     $FC             ;7
        inc     hl              ;6
        COMBINE_HL              ;7
        ld      (hl),a          ;7

        ld      a,15            ;7
        add     a,l             ;4
        ld      l,a             ;4
        jp      nc,done6        ;10
        inc     h               ;4
done6:
        djnz    routine6        ;13
        ret
                               
routine5:
        ld      a,(de)          ;7
        inc     de              ;6

        rlca                    ;4
        rlca                    ;4
        rlca                    ;4
        ld      c,a             ;4
        and     $07             ;7
        COMBINE_HL              ;7
        ld      (hl),a          ;7
        ld      a,c             ;4
        and     $F8             ;7
        inc     hl              ;6
        COMBINE_HL              ;7
        ld      (hl),a          ;7

        ld      a,15            ;7
        add     a,l             ;4
        ld      l,a             ;4
        jp      nc,done5        ;10
        inc     h               ;4
done5:
        djnz    routine5        ;13
        ret
