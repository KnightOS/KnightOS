.macro config(addr)
    lcall(configlibId, addr)
.endmacro
.macro config(cc, addr)
    lcall(configlibId, cc, addr)
.endmacro

configlibId .equ 0x04

openConfig .equ 6
closeConfig .equ 9
readOption .equ 12
readOption_8 .equ 15
readOption_16 .equ 18
readOption_s8 .equ 21
readOption_s16 .equ 24
readOption_float .equ 27
readOption_bool .equ 30
writeOption .equ 33
writeOption_8 .equ 36
writeOption_16 .equ 39
writeOption_s8 .equ 42
writeOption_s16 .equ 45
writeOption_float .equ 48
writeOption_bool . equ 51
