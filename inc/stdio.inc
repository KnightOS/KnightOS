stdioId .equ $03

; Commands
cmdNone .equ 0
cmdPrintString .equ 1
cmdPrintLine .equ 2

; Routines
registerThread .equ 6
releaseThread .equ 9
readCommand .equ 12
printString .equ 15
printLine .equ 18