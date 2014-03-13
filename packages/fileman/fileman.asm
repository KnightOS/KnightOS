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
    ld bc, 512 ; Max 256 subdirectories and 256 files per directory
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
    push de
        jr z, _
        ; Draw the ".." (not done for root directory)
        ld b, 6
        kld(hl, directoryIcon)
        pcall(putSpriteOR)
        ld d, 0x09
        kld(hl, upText)
        pcall(drawStr)
    inc sp \ inc sp \ push de

_:      kld(hl, (currentPath))
        ex de, hl
        kld(hl, listCallback)
        exx
            ld bc, 0
        exx
        pcall(listDirectory)
        exx
        push bc
            exx
        pop bc
        ; B: Num directories
        ; C: Num files
        ; Sort results
        push bc
            ld a, b
            or a
            jr z, _
            kld(ix, (directoryList))
            pcall(memSeekToStart)
            kld((directoryList), ix)
            push ix \ pop hl
            ld d, h \ ld e, l
            ld a, b
            ld b, 0
            ld c, a
            add hl, bc
            add hl, bc
            ex hl, de
            dec de \ dec de
            ld bc, 2
            ; This is weird. We know this pcall is on page 0x00, so this
            ; just takes it apart and gets the address in the jump table
            ; directly so that we can offer it to callbackSort
            ld ix, 0x4000 - (((compareStrings_sort >> 8) + 1) * 3)
            pcall(callbackSort) ; Sort directory list
_:      pop bc \ push bc
            ld a, c
            or a
            jr z, _
            kld(ix, (fileList))
            pcall(memSeekToStart)
            kld((fileList), ix)
            push ix \ pop hl
            ld d, h \ ld e, l
            ld b, 0
            add hl, bc
            add hl, bc
            ex hl, de
            dec de \ dec de
            ld bc, 2
            ld ix, 0x4000 - (((compareStrings_sort >> 8) + 1) * 3)
            pcall(callbackSort) ; Sort file list
_:      pop bc
    pop de
    ; All sorted, now draw it

drawList:
    ld d, 0x08
    push bc
        kld(ix, (directoryList))
        ld a, b
        or a
        jr z, _
        xor a
        kcall(.draw)
_:  pop bc \ push bc
        kld(ix, (fileList))
        ld a, c
        ld b, a
        or a
        jr z, _
        ld a, 1
        kcall(.draw)
_:  pop bc
    jr .done

.draw:
    push af
        ld a, e
        cp 0x38 ; Stop drawing at Y=0x38
        jr nz, _
        kld(hl, downCaretIcon)
        ld b, 3
        push de
            ld de, 0x5934
            pcall(putSpriteOR)
        pop de
    pop af
    ret
_:  pop af
    ld l, (ix)
    ld h, (ix + 1)
    pcall(drawStr)
    push bc
        ld b, 6
        or a
        jr z, _
        kld(hl, fileIcon)
        jr ++_
_:      kld(hl, directoryIcon)
_:      ld d, 2
        pcall(putSpriteOR)
        ld d, 8
        ld b, 8
        pcall(newline)
    pop bc
    inc ix \ inc ix
    djnz .draw
    ret

.done:
    push bc
        ld a, b
        add c
        ld b, 0
        ld c, a
        jr nc, $+3
        inc b
        push bc

            ; Draw remainder of UI
            ld e, 8 ; x
            ld l, 7 ; y
            ld c, 87 ; w
            ld b, 7 ; h
            pcall(rectXOR)

            ld d, 0 ; Index

idleLoop:
            pcall(fastCopy)
            pcall(flushKeys)
            applib(appWaitKey)
            jr nz, idleLoop

            cp kDown
            jr z, .handleDown
            cp kUp
            kjp(z, .handleUp)
            cp kEnter
            kjp(z, .handleEnter)
            cp k2nd
            kjp(z, .handleEnter)
            cp kRight
            kjp(z, .handleEnter)
            cp kDel
            kjp(z, .handleDelete)
            cp kClear
            kjp(z, .exit)
            jr idleLoop
.handleDown:
        pop bc
        ld a, d
        inc a
        cp c
        push bc
            ld c, 87
            ld b, 7
            jr nc, idleLoop
            ld a, d
            add a, a
            add a, a
            add a, d
            add a, d ; A *= 6
            add a, 7
            ld l, a
            pcall(rectXOR)
            add a, 6
            ld l, a
            pcall(rectXOR)
            inc d
            kjp(idleLoop)
.handleUp:
            ld a, d
            or a
            jr z, idleLoop
            add a, a
            add a, a
            add a, d
            add a, d ; A *= 6
            add a, 7
            ld l, a
            pcall(rectXOR)
            sub a, 6
            ld l, a
            pcall(rectXOR)
            dec d
            kjp(idleLoop)
.handleEnter:
        pop bc
    pop bc
    ; Determine if it's a file or a directory
    ld a, d
    cp b
    jr nc, openFile
.resumeDirectory:
    ; Handle directory
    add a, a
    kld(hl, (directoryList))
    add l
    ld l, a
    jr nc, $+3
    inc h
    ld e, (hl)
    inc hl
    ld d, (hl)
    kld(hl, (currentPath))
    xor a
    ld bc, 0
    cpir
    dec hl
    ; TODO: Support trailing slashes in low-level filesystem driver
    ;ld a, '/'
    ;ld (hl), a
    ;inc hl
    ex de, hl
    pcall(stringLength)
    inc bc
    ldir
    kjp(doListing)
.handleDelete:
            kjp(idleLoop)
.exit:
        pop bc
    pop bc
    ret

openFile:
    xor a
    cp d
    jr nz, .continue
    kld(hl, (currentPath))
    inc hl
    ld a, (hl)
    or a
    jr z, .continue ; If it's not root, we may have clicked ".."
    kld(hl, (currentPath))
    ld a, '/'
    cpdr
    inc hl
    inc hl
    xor a
    ld (hl), a
    kjp(doListing)
.continue:
    ; TODO: Ask applib to open this file
    ret

listCallback:
    exx
        push bc
            ld hl, kernelGarbage
            pcall(stringLength)
            inc bc ; Include delimiter
            pcall(malloc) ; TODO: Handle out of memory (how?)
            push ix \ pop de
            ldir

            cp fsFile
            jr z, _
            ; Handle directory
            kld(hl, (directoryList))
            push ix \ pop de
            ld (hl), e
            inc hl
            ld (hl), d
            inc hl
            kld((directoryList), hl)
        pop bc
        inc b
    exx
    ret
_:          ; Handle file
            kld(hl, (fileList))
            push ix \ pop de
            ld (hl), e
            inc hl
            ld (hl), d
            inc hl
            kld((fileList), hl)
        pop bc
        inc c
    exx
    ret

currentPath:
    .dw 0
fileList:
    .dw 0
directoryList:
    .dw 0
totalFiles:
    .db 0
totalDirectories:
    .db 0

applibPath:
    .db "/lib/applib", 0
upText:
    .db "..\n", 0
titlePrefix:
    .db "File Manager: /", 0
titlePrefixEnd:
directoryIcon:
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
downCaretIcon:
    .db 0b11111000
    .db 0b01110000
    .db 0b00100000
