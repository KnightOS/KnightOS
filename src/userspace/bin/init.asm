#include "kernel.inc"
#include "macros.inc"
#include "keys.inc"
; Header
    .db 0
    .db 10 ; Stack size
; Program
.org 0
    jr start
    
returnToCastle:
    ; 0x8205
    ld de, 0 ; Changed to castle path at runtime
    call launchProgram
    jp killCurrentThread
    
start:
    ; Boot status codes
    cp 1 ; ON+MODE pressed
    jr z, launchCastle
    
    ; Set init memory to be permenant
    kcall(_)
_:  pop ix
    call memSeekToStart
    dec ix \ dec ix \ dec ix
    ld (ix), $FE
    
    ; Load /lib/stdio so that it's always available
    kld(de, stdioPath)
    call loadLibrary
    
    ; Update returnToCastle
    kld(de, castlePath)
    ld (ix + 6), e
    ld (ix + 7), d
    
    call getKey
    cp kT
    jr z, launchTerminal

launchCastle:
    kld(de, castlePath)
    call launchProgram
    ret
    
launchTerminal:
    kld(de, terminalPath)
    di
    call launchProgram
    kld(hl, returnToCastle)
    call setReturnPoint
    ei
    ret

castlePath:
    .db "/bin/castle", 0
terminalPath:
    .db "/bin/terminal", 0
stdioPath:
    .db "/lib/stdio", 0