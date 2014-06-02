.nolist
libId .equ 0x04
#include "kernel.inc"
.list

.dw 0x0004

.org 0

jumpTable:
    ret \ nop \ nop ; Init
    ret \ nop \ nop ; Deinit
    jp openConfig
    jp closeConfig
    jp readOption
    jp readOption_8
    jp readOption_16
    jp readOption_s8
    jp readOption_s16
    jp readOption_float
    jp readOption_bool
    jp writeOption
    jp writeOption_8
    jp writeOption_16
    jp writeOption_s8
    jp writeOption_s16
    jp writeOption_float
    jp writeOption_bool
    .db 0xFF

openConfig:
closeConfig:
readOption:
readOption_8:
readOption_16:
readOption_s8:
readOption_s16:
readOption_float:
readOption_bool:
writeOption:
writeOption_8:
writeOption_16:
writeOption_s8:
writeOption_s16:
writeOption_float:
writeOption_bool:
    ret
