#include "kernel.inc"
#include "config.inc"
    .db "KEXC"
    .db KEXC_ENTRY_POINT
    .dw start
    .db KEXC_STACK_SIZE
    .dw 100
    .db KEXC_HEADER_END
start:
    pcall(getLcdLock)
    pcall(getKeypadLock)
    
    pcall(allocScreenBuffer)
	pcall(clearBuffer)
    
    kld(de, configLibPath)
    pcall(loadLibrary)
    
    kld(de, filePath)
    config(openConfigRead)
    ret nz
    
    kld(hl, optionName1)
    config(readOption)
    jr nz, .var1NotFound
    kld((values), hl)
    ld a, 1
    kld((varFound), a)  
    jr .doVar2
.var1NotFound:
    kld(hl, notFound)
    kld((values), hl)
    xor a
    kld((varFound), a)
    
.doVar2:
    kld(hl, optionName2)
    config(readOption)
    jr nz, .var2NotFound
    kld((values + 2), hl)
    ld a, 1
    kld((varFound + 1), a)
    jr .doVar3
.var2NotFound:
    kld(hl, notFound)
    kld((values + 2), hl)
    xor a
    kld((varFound + 1), a)
    
.doVar3:
    kld(hl, optionName3)
    config(readOption)
    jr nz, .var3NotFound
    kld((values + 4), hl)
    ld a, 1
    kld((varFound + 2), a)
    jr .doVar4
.var3NotFound:
    kld(hl, notFound)
    kld((values + 4), hl)
    xor a
    kld((varFound + 2), a)
    
.doVar4:
    kld(hl, optionName4)
    config(readOption)
    jr nz, .var4NotFound
    kld((values + 6), hl)
    ld a, 1
    kld((varFound + 3), a)
    jr .varsDone
.var4NotFound:
    kld(hl, notFound)
    kld((values + 6), hl)
    xor a
    kld((varFound + 3), a)
    
.varsDone:
    config(closeConfig)
    
    ld b, 4
    ld de, 0
    kld(hl, optionName1)
    exx
    ld de, 0
    kld(hl, values)
    exx
.drawLoop:
    push bc
        pcall(drawStr)
        ld a, '='
        pcall(drawChar)
        ld b, 0
        pcall(strchr)
        inc hl
        push de \ exx \ pop de
        ld a, (hl)
        inc hl
        ld c, (hl)
        inc hl
        push hl
            ld l, a
            ld h, c
            pcall(drawStr)
        pop hl
        push de \ exx \ pop de
        ld b, 0
        pcall(newline)
    pop bc
    djnz .drawLoop
    
    pcall(fastCopy)
    
    pcall(flushKeys)
    pcall(waitKey)
    
    ; free the values' strings
    ld b, 4
    kld(hl, values)
    kld(de, varFound)
.freeLoop:
    ld ixl, (hl)
    inc hl
    ld ixh, (hl)
    inc hl
    ld a, (de)
    or a
    pcall(nz, free)
    inc de
    djnz .freeLoop
    
    ret

configLibPath:
    .db "/lib/config", 0
filePath:
    .db "/etc/cfgtest.conf", 0
optionName1:
    .db "string", 0
optionName2:
    .db "number", 0
optionName3:
    .db "signednumber", 0
optionName4:
    .db "idontexist", 0
values:
    .dw 0, 0, 0, 0
varFound:
    .db 0, 0, 0, 0
notFound:
    .db "option not found !", 0
    