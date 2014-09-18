#include "kernel.inc"
#include "corelib.inc"
    .db "KEXC"
    .db KEXC_ENTRY_POINT
    .dw start
    .db KEXC_STACK_SIZE
    .dw 20
    .db KEXC_KERNEL_VER
    .db 0, 6
    .db KEXC_NAME
    .dw name
    .db KEXC_HEADER_END
name:
    .db "System Settings", 0
start:
    pcall(getLcdLock)
    pcall(getKeypadLock)

    pcall(allocScreenBuffer)
    
    ; Load dependencies
    kld(de, corelibPath)
    pcall(loadLibrary)
    
redraw:
    kld(hl, windowTitle)
    xor a
    corelib(drawWindow)
    
    ; Print items
    ld de, 0x0508
    kld(hl, systemInfoStr)
    ld b, 6
    pcall(drawStr)
    
    kld(hl, backStr)
    pcall(drawStr)
    
    pcall(newline)
_:
    kld(hl, (item))
    add hl, hl
    ld b, h
    ld c, l
    add hl, hl
    add hl, bc
    ld de, 0x0208
    add hl, de
    ld e, l
    kld(hl, caretIcon)
    ld b, 5
    pcall(putSpriteOR)

    pcall(fastCopy)
    pcall(flushKeys)
    corelib(appWaitKey)
    jr nz, -_
    cp kUp
    kcall(z, doUp)
    cp kDown
    kcall(z, doDown)
    cp k2nd
    kcall(z, doSelect)
    cp kEnter
    kcall(z, doSelect)
    cp kMode
    ret z
    jr -_
    
doUp:
    kld(hl, item)
    ld a, (hl)
    or a
    ret z
    dec a
    ld (hl), a
    kld(hl, caretIcon)
    pcall(putSpriteXOR)
    xor a
    ret
#define NB_ITEM 2
doDown:
    kld(hl, item)
    ld a, (hl)
    inc a
    cp NB_ITEM
    ret nc
    ld (hl), a
    kld(hl, caretIcon)
    pcall(putSpriteXOR)
    xor a
    ret
doSelect:
    kld(hl, (item))
    ld h, 0
    kld(de, itemTable)
    add hl, hl
    add hl, de
    ld e, (hl)
    inc hl
    ld d, (hl)
    pcall(getCurrentThreadID)
    pcall(getEntryPoint)
    add hl, de
    pop de \ kld(de, redraw) \ push de
    jp (hl)
    
itemTable:
    .dw printSystemInfo, exit
    
printSystemInfo:
    pcall(clearBuffer)
    
    kld(hl, windowTitle)
    xor a
    corelib(drawWindow)
    
    ld de, 0x0208
    ld b, 2

    kld(hl, systemVersionStr)
    pcall(drawStr)

    push de
        kld(de, etcVersion)
        pcall(openFileRead)
        jr nz, .noVersion
        pcall(getStreamInfo)
        pcall(malloc)
        inc bc
        pcall(streamReadToEnd)
        pcall(closeStream)
        push ix \ pop hl
        add hl, bc
        dec hl
        xor a
        ld (hl), a
        push ix \ pop hl
    pop de
.writeVersion:
    ld b, 2
    inc d \ inc d \ inc d
    pcall(drawStr)
    pcall(free)

    kld(hl, kernelVersionStr)
    pcall(drawStr)
    
    ld hl, kernelVersion
    inc d \ inc d \ inc d
    pcall(drawStr)
    pcall(newline)
    
    kld(hl, bootCodeVersionStr)
    pcall(drawStr)
    
    pcall(getBootCodeVersionString)
    inc d \ inc d \ inc d
    pcall(drawStr)
    push hl \ pop ix
    pcall(free)

    pcall(newline)
    pcall(newline)

    kld(hl, backStr)
    ld d, 6
    ld b, 5
    push de
        pcall(drawStr)
    pop de
    ld d, 2
    kld(hl, caretIcon)
    pcall(putSpriteOR)

_:  pcall(fastCopy)
    pcall(flushKeys)
    corelib(appWaitKey)
    jr nz, -_
    ret

.noVersion:
    pop de
    kld(hl, notFoundStr)
    jr .writeVersion
    
exit:
    pop hl
    ret
    
item:
    .db 0
corelibPath:
    .db "/lib/core", 0
etcVersion:
    .db "/etc/version", 0
windowTitle:
    .db "System Settings", 0
systemVersionStr:
    .db "KnightOS version:\n", 0
kernelVersionStr:
    .db "Kernel version:\n", 0
bootCodeVersionStr:
    .db "Boot Code version:\n", 0
    
systemInfoStr:
    .db "System info\n", 0
backStr:
    .db "Back", 0
notFoundStr:
    .db "Not found\n", 0

caretIcon:
    .db 0b10000000
    .db 0b11000000
    .db 0b11100000
    .db 0b11000000
    .db 0b10000000
