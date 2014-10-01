libkpmId .equ 0x05

.macro libkpm(addr)
    lcall(libkpmId, addr)
.endmacro
.macro libkpm(cc, addr)
    lcall(libkpmId, cc, addr)
.endmacro

getPackageList .equ 6
packageDetail .equ 9
removePackage .equ 12
freePackageList .equ 15
