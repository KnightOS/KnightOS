; Programmed by Patrick Davidson (pad@calc.org)
; Ported to KnightOS by Drew DeVault (sir@cmpwn.com)
;        
; Copyright 2005 by Patrick Davidson.  This software may be freely
; modified and/or copied with no restrictions.  There is no warranty.
#include "kernel.inc"
#include "corelib.inc"
    .db "KEXC"
    .db KEXC_ENTRY_POINT
    .dw start
    .db KEXC_STACK_SIZE
    .dw 200
    .db KEXC_KERNEL_VER
    .db 0, 6
    .db KEXC_NAME
    .dw name
    .db KEXC_HEADER_END
name:
    .db "Phoenix", 0

;D_ZT_STR        =_puts
;D_HL_DECI       =_disphl
;TX_CHARPUT      =_putc
;CLEARLCD        =_clrlcdf

#include "phoenixz.i"

start:
    kld(de, corelibPath)
    pcall(loadLibrary)

    pcall(getCurrentThreadId)
    pcall(getEntryPoint)
    kld((entryPoint), hl)
    kcall(relocate_defaults)

    pcall(getLcdLock)
    pcall(getKeypadLock)
    ld bc, 16*64 ; Larger screen size than usual
    pcall(malloc)
    jr nz, .quit
    push ix \ pop iy
    kcall(main)
    ret
.quit:
    push af
        pcall(allocScreenBuffer)
        pcall(nz, exitThread) ; Nothing we can do about it
    pop af
    corelib(showErrorAndQuit)
    ret

_unpackhl_shim:
    push bc
        ld c, 10
        pcall(divHLByC)
    pop bc
    ret
    
.equ UNPACK_HL _unpackhl_shim

_puts_shim:
    push de
    push bc
        ld b, 0
        kld(de, (_puts_shim_cur))
        pcall(wrapStr)
        kld((_puts_shim_cur), de)
        pcall(stringLength)
        add hl, bc
        inc hl
    pop bc
    pop de
    ret
_puts_shim_cur:
    .dw 0
puts .equ _puts_shim

corelibPath:
    .db "/lib/core", 0

#include "main.asm"
#include "lib.asm"
#include "title.asm"
#include "disp.asm"
#include "drwspr.asm"
#include "player.asm"
#include "shoot.asm"
#include "bullets.asm"
#include "enemies.asm"
#include "init.asm"
#include "enemyhit.asm"
#include "collide.asm"
#include "ebullets.asm"
#include "hityou.asm"
;#include "shop.asm"
;#include "helper.asm"
#include "eshoot.asm"
;#include "score.asm"
#include "emove.asm"
#include "images.asm"
#include "info.asm"
#include "data.asm"
#include "levels.asm"
#include "vars.asm"
