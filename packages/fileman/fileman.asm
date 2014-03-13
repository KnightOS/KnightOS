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

    ld de, 0x0808
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

sortComparer:
    in a, (6) ; TODO: This, but in a cross-platform way
    push af
        pcall(indirect16HLDE)
        pcall(compareStrings)
    pop af
    out (6), a
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
testFile:
    .db "abc", 0
