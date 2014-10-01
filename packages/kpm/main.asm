#include "kernel.inc"
#include "kpm.inc"
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
    .db "Package Manager", 0
start:
    kld(de, kpmPath)
    pcall(loadLibrary)

    pcall(getLcdLock)
    pcall(getKeypadLock)

    pcall(allocScreenBuffer)

    kjp(showlist)
kpmPath:
    .db "/lib/kpm", 0

#include "kpm-gui/list.asm"
