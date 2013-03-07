.macro stdio(addr)
    lcall(stdioId, addr)
.endmacro
.macro stdio(cc, addr)
    lcall(stdioId, cc, addr)
.endmacro

stdioId .equ $03

; Commands
cmdNone .equ 0
cmdPrintChar .equ 1
cmdPrintString .equ 2
cmdPrintLine .equ 3
cmdClearTerminal .equ 4
cmdPrintDecimal .equ 5
cmdReadLine .equ 6
cmdPrintHex .equ 7
cmdEnableUpdates .equ 8
cmdDisableUpdates .equ 9

; Routines
registerThread .equ 6
releaseThread .equ 9
readCommand .equ 12
printChar .equ 15
printString .equ 18
printLine .equ 21
clearTerminal .equ 24
getSupervisor .equ 27
printDecimal .equ 30
readLine .equ 33
printHex .equ 36
enableUpdates .equ 39
disableUpdates .equ 42