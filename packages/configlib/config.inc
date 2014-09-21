.macro config(addr)
    lcall(configlibId, addr)
.endmacro
.macro config(cc, addr)
    lcall(configlibId, cc, addr)
.endmacro

configlibId .equ 0x04

openConfigRead .equ 6
openConfigWrite .equ 9
closeConfig .equ 12
readOption .equ 15
readOption_8 .equ 18
readOption_16 .equ 21
readOption_32 .equ 24
readOption_float .equ 27
readOption_bool .equ 30
writeOption .equ 33
writeOption_u8 .equ 36
writeOption_u16 .equ 39
writeOption_s8 .equ 42
writeOption_s16 .equ 45
writeOption_float .equ 48
writeOption_bool .equ 51
