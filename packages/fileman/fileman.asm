.nolist
#include "kernel.inc"
#include "applib.inc"
.list
    .db 0, 100
.org 0
    jr start
    .db 'K'
    .db 0b00000010
    .db "File Manager", 0
start:
    pcall(getLcdLock)
    pcall(getKeypadLock)

    kld(de, applibPath)
    pcall(loadLibrary)

    pcall(allocScreenBuffer)

    ; Set current path
    ld bc, 1024 + 13
    pcall(malloc)
    push ix \ pop de
    kld(hl, titlePrefix)
    ld bc, titlePrefixEnd - titlePrefix
    ldir
    ex de, hl
    dec hl \ dec hl
    kld((currentPath), hl)
    
    ; Allocate space for fileList and directoryList
    ld bc, 1024 ; Max 512 subdirectories and 512 files per directory
    pcall(malloc)
    push ix \ pop hl
    kld((fileList), hl)
    pcall(malloc)
    push ix \ pop hl
    kld((directoryList), hl)

doListing:
    pcall(clearBuffer)
    kld(hl, (currentPath))
    push hl \ pop ix
    pcall(memSeekToStart)
    push ix \ pop hl
    ld a, 0b00000100
    applib(drawWindow)
    
    kld(hl, (currentPath))
    inc hl
    ld a, (hl)
    or a ; cp 0
    ld de, 0x0208
    push de ; See ->
    jr z, _
        ; Draw the ".." (not done for root directory)
        ld b, 6
        kld(hl, folderIcon)
        pcall(putSpriteOR)
        ld d, 0x09
        kld(hl, upText)
        pcall(drawStr)
        inc sp \ inc sp \ push de

_:  kld(hl, (currentPath))
    ex de, hl
    kld(hl, listCallback)
    exx
        pop de ; <- this
        ld b, 0x06
    exx
    pcall(listDirectory)

    ; Sort results
    ; TODO

    ; Draw remainder of UI
    ld e, 8 ; x
    ld l, 7 ; y
    ld c, 87 ; w
    ld b, 7 ; h
    pcall(rectXOR)

keyLoop:
    pcall(fastCopy)
    pcall(flushKeys)
    applib(appWaitKey)
    jr nz, keyLoop
    ; Handle keys (TODO)
    ret

listCallback:
    exx
        kld(hl, fileIcon)
        cp fsFile
        jr z, _
        kld(hl, folderIcon)
_:      ld d, 2
        pcall(putSpriteOR)
        ld hl, kernelGarbage
        ld d, 9
        pcall(drawStr)
        pcall(newline)
    exx
    ret

currentPath:
    .dw 0
; These are lists of pointers to allocated strings with node names
fileList:
    .dw 0
directoryList:
    .dw 0

applibPath:
    .db "/lib/applib", 0
upText:
    .db "..\n", 0
titlePrefix:
    .db "File Manager: /", 0
titlePrefixEnd:
folderIcon:
    .db 0b11100000
    .db 0b10011000
    .db 0b11101000
    .db 0b10001000
    .db 0b11111000
    .db 0
fileIcon:
    .db 0b01111000
    .db 0b10001000
    .db 0b10001000
    .db 0b10001000
    .db 0b11111000
    .db 0
