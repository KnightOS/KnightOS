; KnightOS corelib
; General purpose application library

.nolist
libId .equ 0x02
#include "kernel.inc"
.list

.dw 0x0002

.org 0

jumpTable:
    ; Init
    ret \ nop \ nop
    ; Deinit
    ret \ nop \ nop
    jp getPackageList
    jp packageDetail
    jp removePackage
    .db 0xFF

getPackageList:
packageDetail:
removePackage:
    ret
