.nolist
#include "kernel.inc"
.list
    .db 0, 50
.org 0
    jr start
returnToCastle:
    ; userMemory + 5
    ; ENORMOUS HACK
    ld de, 0 ; Changed to castle path at runtime
    call launchProgram
    jp killCurrentThread
    
start:
    ; Set init memory to be permanent
    kcall(_)
_:  pop ix
    call memSeekToStart
    ld (ix + -3), 0xFE
    
    ; Update returnToCastle
    kld(de, castlePath)
    ld (ix + 3), e
    ld (ix + 4), d
    call launchProgram
    ret

castlePath:
    .db "/bin/castle", 0
