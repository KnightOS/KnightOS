#include "kernel.inc"
#include "corelib.inc"
#include "config.inc"
    .db "KEXC"
    .db KEXC_ENTRY_POINT
    .dw start
    .db KEXC_STACK_SIZE
    .dw 100
    .db KEXC_KERNEL_VER
    .db 0, 6
    .db KEXC_NAME
    .dw window_title
    .db KEXC_HEADER_END
window_title:
    .db "File Manager", 0
start:
    pcall(getLcdLock)
    pcall(getKeypadLock)

    kld(de, corelibPath)
    pcall(loadLibrary)
    kld(de, configlibPath)
    pcall(loadLibrary)

    kcall(loadConfiguration)

    pcall(allocScreenBuffer)

    ; Set current path
    ld bc, 1024
    pcall(malloc)
    push ix \ pop de
    push de
        kld(hl, (config_initialPath))
        pcall(strlen)
        inc bc
        ldir
        dec de \ dec de
        ex de, hl
        ld a, '/'
        cp (hl)
        jr z, _
        inc hl
        ld (hl), a
        xor a
        inc hl
        ld (hl), a
_:      ex de, hl
    pop de
    ex de, hl
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
    kld(a, (config_browseRoot))
    or a
    jr nz, _
    kld(hl, (currentPath))
    kld(de, (config_initialPath))
    pcall(strcmp)
    jr z, +++_

_:  kld(hl, (currentPath))
    inc hl
    ld a, (hl)
    dec hl
    or a ; cp 0 (basically, test if we're at the root
    jr z, ++_

_:  ; Add a .. entry if this is not the root
    kld(hl, directoryIcon)
    kld((dotdot), hl)
    kld(hl, (directoryList))
    kld(de, dotdot)
    ld (hl), e
    inc hl
    ld (hl), d
    inc hl
    kld((directoryList), hl)

_:  kld(hl, (currentPath))
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
    ; Add the imaginary .. entry to the list
    push de
        kld(ix, (directoryList))
        pcall(memSeekToStart)
        kld((directoryList), ix)
        ld l, (ix)
        ld h, (ix + 1)
        kld(de, dotdot)
        pcall(cpHLDE)
    pop de
    jr nz, _ 
    inc b
_:  push bc ; Sort results
        ld a, b
        or a
        jr z, ++_
        ld a, b
        ld b, 0
        ld c, a
        ; Check for root and move past the .. if not
        ld l, (ix)
        ld h, (ix + 1)
        kld(de, dotdot)
        pcall(cpHLDE)
        push ix \ pop hl
        jr nz, _
        ; We are not on the root, so skip the .. entry for sorting
        inc hl \ inc hl
        dec bc
_:      ld d, h \ ld e, l
        add hl, bc
        add hl, bc
        ex hl, de
        dec de \ dec de
        ld bc, 2
        kld(ix, sort_callback)
        pcall(callbackSort) ; Sort directory list
    pop bc \ push bc
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
        kld(ix, sort_callback)
        pcall(callbackSort) ; Sort file list
_:  pop bc
    ld a, b
    kld((totalDirectories), a)
    ld a, c
    kld((totalFiles), a)
    ; All sorted, now draw it
drawList:
    pcall(clearBuffer)
    kld(hl, (currentPath))
    ld a, 0b00000100
    corelib(drawWindow)
    xor a
    cp b
    jr nz, _
    cp c
    jr nz, _
    ; There are no files or folders here
    ld de, 0x0208
    kld(hl, nothingHereText)
    pcall(drawStr)
    kjp(.done)

_:  ld de, 0x0808
    kld(a, (scrollTop))
    ld h, a
    push bc
        kld(ix, (directoryList))
        xor a
_:      cp h
        jr z, _
        dec h
        inc ix \ inc ix
        dec b
        jr nz, -_
_:      ld a, b
        or a
        jr z, .drawFiles
        xor a
        push hl \ kcall(.draw) \ pop hl
.drawFiles:
    pop bc \ push bc
        kld(ix, (fileList))
        xor a
_:      cp h
        jr z, _
        dec h
        inc ix \ inc ix
        dec c
        jr nz, -_
_:      ld a, c
        ld b, a
        or a
        jr z, ._done
        ld a, 1
        kcall(.draw)
._done:
    pop bc
    jr .done

.draw:
    push af
        ld a, e
        cp 0x38 ; Stop drawing at Y=0x38
        jr nz, ++_
        ld a, b
        or a
        jr z, _
        kld(hl, downCaretIcon)
        ld b, 3
        push de
            ld de, 0x5934
            pcall(putSpriteOR)
        pop de
_:  pop af
    ret
_:  pop af
    ld l, (ix)
    ld h, (ix + 1)
    inc hl
    inc hl
    pcall(drawStr)
    push bc
        or a
        jr z, _
        kld(a, (config_showSize))
        or a
        jr z, _
        ; File size
        pcall(strlen)
        or a
        push hl
            adc hl, bc
            inc hl
            push af
                push de
                    ld e, (hl)
                    inc hl
                    ld d, (hl)
                    inc hl
                    ld a, (hl)
                    ex de, hl
                pop de
                cp 0xFF ; TODO: Check all of AHL
                kcall(nz, drawFileSize)
            pop af
        pop hl
_:      ld b, 6
        push de
            dec hl \ dec hl
            ld e, (hl)
            inc hl
            ld d, (hl)
            ex de, hl
        pop de
        ld d, 2
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
            ld hl, 0
            pcall(cpHLBC)
            jr z, idleLoop

            ; Draw remainder of UI
            kld(a, (scrollTop))
            or a
            jr z, _
            kld(hl, upCaretIcon)
            ld de, 0x5908
            ld b, 3
            pcall(putSpriteOR)

_:          ld e, 8 ; x
            kld(a, (scrollOffset))
            kld(hl, scrollTop)
            sub (hl)
            ld l, a
            add a, a
            add a, a
            add a, l
            add a, l
            add a, 7
            ld l, a ; y
            ld c, 87 ; w
            ld b, 7 ; h
            pcall(rectXOR)

            kld(a, (scrollOffset))
            ld d, a ; Index

idleLoop:
            pcall(fastCopy)
            pcall(flushKeys)
            corelib(appWaitKey)
            jr nz, idleLoop

            cp kMode
            kjp(z, .exit)
            ld hl, 0
            pcall(cpHLBC)
            jr z, idleLoop

            cp kDown
            kjp(z, .handleDown)
            cp kUp
            kjp(z, .handleUp)
            cp kLeft
            kjp(z, .handleParent)
            cp kClear
            kjp(z, .handleParent)
            cp kEnter
            kjp(z, .handleEnter)
            cp k2nd
            kjp(z, .handleEnter)
            cp kRight
            kjp(z, .handleEnter)
            cp kDel
            kjp(z, .handleDelete)
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
            push hl
                kld(hl, scrollTop)
                sub (hl)
            pop hl
            cp 7
            jr z, .tryScrollDown
            push de
                ld d, a
                add a, a
                add a, a
                add a, d
                add a, d ; A *= 6
                add a, 7
            pop de
            ld l, a
            pcall(rectXOR)
            add a, 6
            ld l, a
            pcall(rectXOR)
            inc d
            ld a, d
            kld((scrollOffset), a)
            kjp(idleLoop)
.tryScrollDown:
            inc d
            ld a, d
            kld((scrollOffset), a)
            kld(hl, scrollTop)
            inc (hl)
        pop bc
    pop bc
    kjp(drawList)
.handleUp:
            ld a, d
            or a
            kjp(z, idleLoop)
            push hl
                kld(hl, scrollTop)
                sub (hl)
            pop hl
            or a ; cp 0
            jr z, .tryScrollUp
            push de
                ld d, a
                add a, a
                add a, a
                add a, d
                add a, d ; A *= 6
                add a, 7
            pop de
            ld l, a
            pcall(rectXOR)
            sub a, 6
            ld l, a
            pcall(rectXOR)
            dec d
            ld a, d
            kld((scrollOffset), a)
            kjp(idleLoop)
.tryScrollUp:
            dec d
            ld a, d
            kld((scrollOffset), a)
            kld(hl, scrollTop)
            dec (hl)
        pop bc
    pop bc
    kjp(drawList)
.handleEnter:
        pop bc
    pop bc
    ; Determine if it's a file or a directory
    ld a, d
    cp b
    kjp(nc, openFile)
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
    inc de \ inc de ; Skip icon
    ld a, (de)
    cp '.'
    kjp(z, .handleParent_noPop)
    kld(hl, (currentPath))
    xor a
    ld bc, 0
    cpir
    dec hl
    ex de, hl
    pcall(strlen)
    inc bc
    ldir
    ex de, hl
    dec hl
    ld a, '/' ; Add trailing slash
    ld (hl), a
    inc hl
    xor a
    ld (hl), a
    kjp(freeAndLoopBack)
.handleDelete:
        pop bc
    pop bc
    ld a, d
    cp b
    jr c, .deleteDirectory
    push de
    push bc
        kld(hl, deletionMessage)
        kld(de, deletionOptions)
        xor a
        ld b, 0
        corelib(showMessage)
    pop bc
    pop de
    or a ; cp 0
    kjp(z, freeAndLoopBack)
    ; DELETE IT
    ; Load it onto currentPath for a moment
    ld a, d
    sub b
    add a, a
    kld(hl, (fileList))
    add l
    ld l, a
    jr nc, $+3
    inc h
    ld e, (hl)
    inc hl
    ld d, (hl)
    inc de \ inc de
    kld(hl, (currentPath))
    xor a
    ld bc, 0
    cpir
    dec hl
    ex de, hl
    pcall(strlen)
    inc bc
    ldir
    kld(de, (currentPath))
    pcall(deleteFile)
    ex de, hl
    pcall(strlen)
    add hl, bc
    ld a, '/'
    cpdr
    inc hl
    xor a
    ld (hl), a
    jr freeAndLoopBack
.deleteDirectory:
    ; TODO: delete directories
    kjp(freeAndLoopBack)
.exit:
        pop bc
    pop bc
    ret
.handleParent:
        pop bc
    pop bc
.handleParent_noPop:
    kld(hl, (currentPath))
    push hl \ pop de
    pcall(strlen)
    add hl, bc
    ld a, '/'
    ld bc, 0
    cpdr \ cpdr
    inc hl \ inc hl
    pcall(cpHLDE)
    jr nz, _
    inc hl
_:  xor a
    ld (hl), a
    ;jr freeAndLoopBack

freeAndLoopBack:
    xor a
    kld((scrollTop), a)
    kld((scrollOffset), a)

    kld(a, (totalDirectories))
    or a
    jr z, +_
    ld b, a
    kld(hl, (directoryList))
.freeDirs:
    ld e, (hl)
    inc hl
    ld d, (hl)
    inc hl
    push de \ pop ix
    ld a, (ix)
    cp '.'
    pcall(nz, free)
    djnz .freeDirs
_:  kld(a, (totalFiles))
    or a
    kjp(z, doListing)
    ld b, a
    kld(hl, (fileList))
.freeFiles:
    ld e, (hl)
    inc hl
    ld d, (hl)
    inc hl
    push de \ pop ix
    pcall(free)
    djnz .freeFiles
    kjp(doListing)

openFile:
    sub b
    add a, a
    kld(hl, (fileList))
    add l
    ld l, a
    jr nc, $+3
    inc h
    ld e, (hl)
    inc hl
    ld d, (hl)
    inc de \ inc de
    ; Copy DE into the current path, but not for long
    kld(hl, (currentPath))
    xor a
    ld bc, 0
    cpir
    dec hl
    di
    push hl
        ex de, hl
        pcall(strlen)
        inc bc
        ldir
        kld(de, (currentPath))
        corelib(open)
    pop hl
    push af
        xor a
        ld (hl), a
    pop af
    jr nz, .fail
    ; Set up the trampoline
    ; This is what takes users back to fileman when the program exits
    push hl
    push de
    push ix
        ld bc, trampoline_end - trampoline
        pcall(malloc)
        pcall(reassignMemory)
        kld(hl, trampoline)
        push ix \ pop de
        ldir
        push ix \ pop hl
        pcall(setReturnPoint)
        pcall(getCurrentThreadId)
        ld (ix + 1), a
    pop ix
    pop de
    pop hl
    ei
    pcall(suspendCurrentThread)
    kjp(freeAndLoopBack)
.fail:
    ei
    ; It failed to open, complain to the user
    kld(hl, openFailMessage)
    kld(de, openFailOptions)
    xor a
    ld b, 0
    corelib(showMessage)
    kjp(freeAndLoopBack)

; AHL: File size
; E: Y pos
drawFileSize:
    ; TODO: Files >65535 bytes
    ld d, 96 - 11
    push bc
        ld b, 0
_:      ld c, 10
        pcall(divHLbyC)
        add a, '0'
        pcall(drawChar)
        ld a, -8
        add a, d
        ld d, a
        ld c, 0
        pcall(cpHLBC)
        jr nz, -_
    pop bc
    ret

listCallback:
    push hl
    exx
    pop hl
        push bc
            cp fsFile
            jr z, .handleFile
            cp fsSymLink
            kjp(z, .handleLink)
            cp fsDirectory
            kjp(nz, .handleUnknown)

            ; Handle directory
            ld hl, kernelGarbage
            kld(a, (config_showHidden))
            or a
            jr nz, _
            ld a, (hl)
            cp '.'
            kjp(z, .handleUnknown) ; Skip hidden directory
_:          pcall(strlen)
            inc bc \ inc bc \ inc bc ; Include delimiter and icon
            pcall(malloc) ; TODO: Handle out of memory (how?)
            kld(de, directoryIcon)
            ld (ix), e \ ld (ix + 1), d
            push ix \ pop de \ inc de \ inc de
            ldir

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
.handleFile:
            push hl
                ld hl, kernelGarbage
                kld(a, (config_showHidden))
                or a
                jr nz, _
                ld a, (hl)
                cp '.'
                jr nz, _
            pop hl
            kjp(.handleUnknown) ; Skip hidden file
_:              pcall(strlen)
                ld a, 6
                add c \ ld c, a \ jr nc, $+3 \ inc b ; Add delimter, file size, icon
                pcall(malloc) ; TODO: Handle out of memory (how?)
                kld(de, fileIcon)
                ld (ix), e \ ld (ix + 1), d
                push ix \ pop de \ inc de \ inc de
                dec bc \ dec bc \ dec bc \ dec bc \ dec bc
                ldir
            pop hl
            ; File size
            ld bc, -6
            or a
            adc hl, bc
            ld a, (hl)
            ld (de), a
            dec hl \ inc de
            ld a, (hl)
            ld (de), a
            dec hl \ inc de
            ld a, (hl)
            ld (de), a

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
.handleLink:
_:          push hl
                ld hl, kernelGarbage
                ld hl, kernelGarbage
                kld(a, (config_showHidden))
                or a
                jr nz, _
                ld a, (hl)
                cp '.'
                jr nz, _
            pop hl
            kjp(.handleUnknown) ; Skip hidden file
_:              pcall(strlen)
                ld a, 6
                add c \ ld c, a \ jr nc, $+3 \ inc b ; Add delimter, file size, icon
                pcall(malloc) ; TODO: Handle out of memory (how?)
                kld(de, symlinkIcon)
                ld (ix), e \ ld (ix + 1), d
                push ix \ pop de \ inc de \ inc de
                dec bc \ dec bc \ dec bc \ dec bc \ dec bc
                ldir
            pop hl
            ; File size
            ; Symlinks need to be sorted with files so there's some workarounds
            ; One of these is that the file size is set to 0xFFFFF
            ld a, 0xFF
            ld (de), a
            inc de
            ld (de), a
            inc de
            ld (de), a

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
.handleUnknown:
        pop bc
    exx
    ret

trampoline:
    ld a, 0 ; Thread ID will be loaded here
    pcall(getThreadEntry)
    corelib(nz, launchCastle)
    ld (hwLockLCD), a
    ld (hwLockKeypad), a
    pcall(resumeThread)
    pcall(killCurrentThread)
trampoline_end:

sort_callback:
    push de
    push hl
        pcall(indirect16HLDE)
        inc hl \ inc hl
        inc de \ inc de
        pcall(strcmp)
    pop hl
    pop de
    ret

loadConfiguration:
    ; Set defaults
    kld(hl, initialPath)
    kld((config_initialPath), hl)
    ; Load actual
    kld(de, configPath)
    config(openConfigRead)
    ret nz

    kld(hl, config_browseRoot_s)
    config(readOption_bool)
    kld((config_browseRoot), a)

    kld(hl, config_editSymLinks_s)
    config(readOption_bool)
    kld((config_editSymLinks), a)
    
    kld(hl, config_showHidden_s)
    config(readOption_bool)
    kld((config_showHidden), a)
    
    kld(hl, config_showSize_s)
    config(readOption_bool)
    kld((config_showSize), a)

    kld(hl, config_initialPath_s)
    config(readOption)
    kld((config_initialPath), hl)

    config(closeConfig)
    ret

; Config options
config_initialPath:
    .dw initialPath
config_browseRoot:
    .db 0
config_editSymLinks:
    .db 0
config_showHidden:
    .db 0
config_showSize:
    .db 0

config_initialPath_s:
    .db "startdir", 0
config_browseRoot_s:
    .db "browseroot", 0
config_editSymLinks_s:
    .db "editsymlinks", 0
config_showHidden_s:
    .db "showhidden", 0
config_showSize_s:
    .db "showsize", 0

configPath:
    .db "/etc/fileman.conf", 0

; Variables
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
scrollOffset:
    .db 0
scrollTop:
    .db 0

corelibPath:
    .db "/lib/core", 0
configlibPath:
    .db "/lib/config", 0
upText:
    .db "..\n", 0
dotdot:
    .dw 0
    .db "..", 0
initialPath:
    .db "/home/", 0
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
symlinkIcon:
    .db 0b00100000
    .db 0b00110000
    .db 0b01111000
    .db 0b10110000
    .db 0b00100000
    .db 0
downCaretIcon:
    .db 0b11111000
    .db 0b01110000
    .db 0b00100000
upCaretIcon:
    .db 0b00100000
    .db 0b01110000
    .db 0b11111000
nothingHereText:
    .db "Nothing here!", 0
deletionMessage:
    .db "Are you sure\nyou want to\ndelete this?", 0
deletionOptions:
    .db 2
    .db "Cancel", 0
    .db "Delete", 0
openFailMessage:
    .db "Sorry, this\nfile could not\nbe opened.", 0
openFailOptions:
    .db 1
    .db "Dismiss", 0

; Settings
showHidden:
    .db 0
showSizes:
    .db 1
browseRoot:
    .db 1
initialDir:
    .dw 0
