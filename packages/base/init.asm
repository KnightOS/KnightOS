; KnightOS init program (/bin/init)
; Run by the kernel at system boot up, and initializes the system.
; This is what KnightOS's init code accomplishes:
; 1. Sets itself to be permanently allocated
;    a. This is done because it provides the returnToCastle routine, which is set as
;       the return point for programs launched from the castle. Since /bin/init stops
;       running once it's finished, we need to set the memory to permanent so that the
;       returnToCastle routine is never deallocated.
; 2. Handles boot status codes, such as the ON+MODE handler. In KnightOS, pressing ON+MODE
;    at any time will return you to the castle.
; 3. Launches the castle. If "T" is held down on boot up, it will instead launch the
;    terminal.

.nolist
#include "kernel.inc"
.list
    .db 0, 20
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
    ld (ix + -3), $FE
    
    ; Update returnToCastle
    kld(de, castlePath)
    ld (ix + 3), e
    ld (ix + 4), d

    ; TODO: Read /etc/inittab instead
launchCastle:
    kld(de, castlePath)
    call launchProgram
    ret

castlePath:
    .db "/bin/castle", 0
