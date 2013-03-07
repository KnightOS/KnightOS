; $0000
; RST $00
    jp boot
; Magic Number
; $0003
.db "KK"
; $0005
.db 0 ; Major version
.db 1 ; Minor version

; $0008
; RST $08
.fill $08-$
rkcall:
    jp kcall
.fill $10-$
; $0010
; RST $10
rlcall:
    jp lcall
.fill $18-$
; $0018
; RST $18
    ret
.fill $20-$
; $0020
; RST $20
    ret
.fill $28-$
; $0028
; RST $28
    jp bcall
.fill $30-$    
; $0030
; RST $30
    ret
.fill $38-$
; $0038
; RST $38
; SYSTEM INTERRUPT
    jp sysInterrupt
; $003B

.fill $53-$
; $0053
    jp boot
; $0056
.db $FF, $A5, $FF
#ifdef TI84pSE
.fill $64-$
    .db '2' ; For the sake of WabbitEmu
#endif