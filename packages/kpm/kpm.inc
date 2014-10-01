.macro libkpm(addr)
    lcall(corelibId, addr)
.endmacro
.macro libkpm(cc, addr)
    lcall(corelibId, cc, addr)
.endmacro

libkpmId .equ 0x04

getPackageList .equ 6
packageDetail .equ 9
removePackage .equ 12
