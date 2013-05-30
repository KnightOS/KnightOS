.macro applib(addr)
    lcall(applibId, addr)
.endmacro
.macro applib(cc, addr)
    lcall(applibId, cc, addr)
.endmacro

applibId .equ 0x02

appGetKey .equ 6
appWaitKey .equ 9
drawWindow .equ 12
getCharacterInput .equ 15
drawCharSetIndicator .equ 18
setCharSet .equ 21
getCharSet .equ 24
launchCastle .equ 27
launchThreadList .equ 30
showMessage .equ 33
showError .equ 36
showErrorAndQuit .equ 39

; Character sets
charSetUppercase .equ 0
charSetLowercase .equ 1
charSetSymbol .equ 2
charSetExtended .equ 3
