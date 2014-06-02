; Programmed by Patrick Davidson (pad@calc.org)
; Ported to KnightOS by Drew DeVault (sir@cmpwn.com)
;        
; Copyright 2005 by Patrick Davidson.  This software may be freely
; modified and/or copied with no restrictions.  There is no warranty.
#include "kernel.inc"
    .db "KEXC"
    .db KEXC_ENTRY_POINT
    .dw start
    .db KEXC_STACK_SIZE
    .dw 100
    .db KEXC_KERNEL_VER
    .db 0, 6
    .db KEXC_NAME
    .dw name
    .db KEXC_HEADER_END
name:
    .db "Phoenix", 0
start:

;interrupt_entry =$9898
;interrupt_byte  =$98
;interrupt_table =$9900
;interrupt_reg   =$99

;GFX_AREA        =plotsscreen

    ret
    jr  nc,start

;D_ZT_STR        =_puts
;D_HL_DECI       =_disphl
;TX_CHARPUT      =_putc
;CLEARLCD        =_clrlcdf
;CURSOR_ROW      =currow
;CURSOR_COL      =curcol
;UNPACK_HL       =_divhlby10

#include "phoenixz.i"

    call main

;############## Include remainder of game files

#include "main.asm"
;#include "extlev.asm"
;#include "exchange.asm"
;#include "lib.asm"
;#include "lib.asm"
;#include "title.asm"
;#include "disp.asm"
;#include "drwspr.asm"
;#include "player.asm"
;#include "shoot.asm"
;#include "bullets.asm"
;#include "enemies.asm"
;#include "init.asm"
;#include "enemyhit.asm"
;#include "collide.asm"
;#include "ebullets.asm"
;#include "hityou.asm"
;#include "shop.asm"
;#include "helper.asm"
;#include "eshoot.asm"
;#include "score.asm"
;#include "emove.asm"
;#include "images.asm"
;#include "info.asm"
;#include "data.asm"
;#include "levels.asm"
;#include "vars.asm"
