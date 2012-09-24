.nolist
libId .equ $02
#include "kernel.inc"
#include "libtext.inc" ; TODO: Support loading libraries from others
#include "keys.inc"
.list

.dw $0002

.org 0

JumpTable:
	; Init
	ret \ nop \ nop
	; Deinit
	ret \ nop \ nop
    jp appGetKey
    jp appWaitKey
	.db $FF
    
; Same as kernel getKey, but listens for
; F1 and F5 and acts accordingly
appGetKey:
    call getKey
    jr checkKey

appWaitKey:
    call waitKey
    jr checkKey
    
checkKey:
    cp kYEqu
    ;ijp(z, launchCastle)
    rst $10 \ .db libId
    jp z, launchCastle
    ret
    
launchCastle:
    ;ild(de, castlePath)
    rst $10 \ .db libId
    ld de, castlePath
    call launchProgram
    call suspendCurrentThread
    xor a
    ret

castlePath:
    .db "/bin/castle", 0
threadlistPath:
    .db "/bin/threadlist", 0
    