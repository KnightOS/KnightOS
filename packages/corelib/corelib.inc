.macro corelib(addr)
    lcall(corelibId, addr)
.endmacro
.macro corelib(cc, addr)
    lcall(corelibId, cc, addr)
.endmacro

corelibId .equ 0x02

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
open .equ 42
drawScrollBar .equ 45

; Character sets
charSetUppercase .equ 0
charSetLowercase .equ 1
charSetSymbol .equ 2
charSetExtended .equ 3
