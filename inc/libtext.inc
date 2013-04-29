.macro libtext(addr)
    lcall(libtextId, addr)
.endmacro
.macro libtext(cc, addr)
    lcall(libtextId, cc, addr)
.endmacro

libtextId .equ 0x01

drawChar				.equ 0x0006
drawCharOR				.equ 0x0006
drawCharAND				.equ 0x0009
drawCharXOR				.equ 0x000C
drawStr					.equ 0x000F
drawStrOR				.equ 0x000F
drawStrAND				.equ 0x0012
drawStrXOR				.equ 0x0015
drawStrFromStream		.equ 0x0018
drawHexA				.equ 0x001B
measureChar				.equ 0x001E
measureStr				.equ 0x0021