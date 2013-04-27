# Libraries

Libraries are special files in the filesystem, usually in `/lib`. These files contain code, but are not directly executed.
They instead provide support to other programs. Most libraries include these two things:

* Library file (in `/lib`)
* Include file (distributed seperately)

The include file should include equates for each of your routines, and lcall macros. All libraries are also assigned a
unique 8-bit ID, which identifies them to the system and for use in code (this may later change to 16 bits). An example
include file (the libtext include file) is shown here:

    .macro libtext(addr)
        lcall(libtextId, addr)
    .endmacro
    .macro libtext(cc, addr)
        lcall(libtextId, cc, addr)
    .endmacro

    .equ libtextId 0x01

    .equ drawChar            0x0006
    .equ drawCharOR          0x0006
    .equ drawCharAND         0x0009
    .equ drawCharXOR         0x000C
    .equ drawStr             0x000F
    .equ drawStrOR           0x000F
    .equ drawStrAND          0x0012
    .equ drawStrXOR          0x0015
    .equ drawStrFromStream   0x0018
    .equ drawHexA            0x001B
    .equ measureChar         0x001E
    .equ measureStr          0x0021

It includes two macros for calling libtext functions, the library ID, and a list of routines. This include file should be
distributed to users who wish to use your library.

The other portion of a library is the code. This includes a jump table and some simple metadata. They follow the following
format:

    .nolist
    .equ libId 0x01
    #include "kernel.inc"
    #include "macros.inc"
    .list

    .dw 0x0001 ; Library ID

    .org 0

    jumpTable:
        ; Init
        ret \ nop \ nop
        ; Deinit
        ret \ nop \ nop
        jp drawChar
        jp drawCharAND
        jp drawCharXOR
        jp drawStr
        jp drawStrAND
        jp drawStrXOR
        jp drawStrFromStream
        jp drawHexA
        jp measureChar
        jp measureStr
        .db 0xFF

This example is taken from libtext. The jump table is a list of JP instructions, each to a different function exposed by the
library. It should end with 0xFF. Note the "init" and "deinit" functions in the jump table - these are special functions that
the system calls when your library is loaded or unloaded, respectively. If you do not need to execute code upon loading, simply
include "ret \ nop \ nop", like the example does. Otherwise, use another JP instruction to jump to your setup and teardown code.

## Relocation

Like programs, libraries need to be relocated. This is done via the "i" macros, which correspond to the k macros programs use
(kcall, kld, kjp).  You must include your library ID when using these. For example:

    .equ libId 0x12
    
        icall(libId, example)
    
    example:
        ret