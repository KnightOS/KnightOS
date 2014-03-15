.macro threeDlib(addr)
    lcall(threeDlibId, addr)
.endmacro
.macro threeDlib(cc, addr)
    lcall(threeDlibId, cc, addr)
.endmacro

threeDlibId .equ 0x03

rotateVertex .equ 6
projectVertex .equ 9
