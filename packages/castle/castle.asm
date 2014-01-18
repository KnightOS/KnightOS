.nolist
#include "kernel.inc"
#include "applib.inc"
#include "castle.lang"
#include "platforms.inc"
.list
    .db 0, 50
.org 0
start:
    call getLcdLock
    call getKeypadLock

    call allocScreenBuffer
    kld(de, applibPath)
    call loadLibrary
resetToHome:
    ei
    ld d, 0
redrawHome:
    push de
        kcall(drawChrome)
        kcall(drawHome)
    pop de
homeLoop:
    kcall(drawHomeIcons)
    call fastCopy
    
_:  call flushKeys
    call waitKey
    
    cp kRight
    jr z, homeRightKey
    cp kLeft
    jr z, homeLeftKey
    cp kUp
    jr z, homeUpKey
    cp kDown
    jr z, homeDownKey
    cp kZoom
    kjp(z, powerMenu)
    cp kEnter
    jr z, homeSelect
    cp k2nd
    jr z, homeSelect
    cp kGraph
    kjp(z, openThreadList)
    cp kPlus
    kjp(z, incrementContrast)
    cp kMinus
    kjp(z, decrementContrast)
    jr -_
homeRightKey:
    ld a, 9
    cp d
    jr z, -_
    inc d
    jr homeLoop
homeLeftKey:
    xor a
    cp d
    jr z, -_
    dec d
    jr homeLoop
homeUpKey:
    ld a, 4
    cp d
    jr nc, -_
    ld a, d \ sub 5 \ ld d, a
    jr homeLoop
homeDownKey:
    ld a, 4
    cp d
    jr c, -_
    inc a \ add a, d \ ld d, a
    jr homeLoop
    
homeSelect:
    ld a, d
    push af
        ; Load config
        kld(de, configPath)
        call openFileRead
        push de
            call getStreamInfo
        pop de
        call malloc
        call streamReadToEnd
        call closeStream
    
        ; IX is the config file
        ld bc, 0x0AFF
_:      inc c
        ld l, (ix)
        ld h, (ix + 1)
        inc ix \ inc ix
        ld a, 0xFF
        cp h \ jr nz, _ \ cp l \ jr nz, _
        ; Empty slot
        djnz -_
_:  pop af \ push af
        cp c
        jr nz, _
        ; This is the correct slot
        ld e, (ix)
        ld d, (ix + 1)
        call memSeekToStart
        push ix \ pop hl
        add hl, de \ ex de, hl
    pop af
    kjp(launch)
_:      push bc
            ld bc, 34
            add ix, bc
        pop bc
        djnz ---_
    pop af
    call memSeekToStart
    call free
    kjp(homeLoop)
    
incrementContrast:
    ld hl, currentContrast
    inc (hl)
    ld a, (hl)
    or a
    jr nz, _
    dec (hl)
    dec a
_:  out (0x10), a
    kjp(homeLoop)
    
decrementContrast:
    ld hl, currentContrast
    dec (hl)
    ld a, (hl)
    cp 0xDF
    jr nz, _
    inc (hl)
    inc a
_:  out (0x10), a
    kjp(homeLoop)
    
openThreadList:
    kld(de, threadlist)
    jr _
launch:
    ld a, (activeThreads)
    cp maxThreads - 1
    jr nz, _
    or 1
    ld a, errTooManyThreads
    applib(showError)
    kjp(resetToHome)
_:  di
    jr $
    call launchProgram
    applib(nz, showError)
    kjp(nz, resetToHome)
    ; ENORMOUS HACK
    ld hl, userMemory + 5
    call setReturnPoint
    ret
    
powerMenu:
    push de
    kcall(drawPowerMenu)
    ld e, 38
powerMenuLoop:
    call fastCopy
    call flushKeys
    call waitKey
    
    cp kUp
    jr z, powerMenuUp
    cp kDown
    jr z, powerMenuDown
    cp k2nd
    jr z, powerMenuSelect
    cp kEnter
    jr z, powerMenuSelect
    cp kClear
    kjp(z, resetToHome)
    cp kZoom
    kjp(z, resetToHome)
    
    jr powerMenuLoop
    
powerMenuUp:
    ld a, 38
    cp e
    jr z, powerMenuLoop
    call putSpriteAND
    ld a, e
    ld e, 6
    sub e
    ld e, a
    call putSpriteOR
    jr powerMenuLoop
    
powerMenuDown:
    ld a, 50
    cp e
    jr z, powerMenuLoop
    call putSpriteAND
    ld a, 6
    add a, e
    ld e, a
    call PutSpriteOR
    jr powerMenuLoop
    
powerMenuSelect:
    ld a, e
    pop de
    cp 44
    jr z, confirmShutDown
    cp 50
    jr z, confirmRestart
    call suspendDevice
    kjp(redrawHome)
    
confirmShutDown:
    ld hl, boot
    jr confirmSelection
confirmRestart:
    ld hl, reboot
confirmSelection:
    push hl
        kld(hl, confirmMessage)
        kld(de, shutdownOptions)
        xor a
        ld b, a
        applib(showMessage)
    pop hl
    or a
    jr nz, _
    kjp(resetToHome)
_:  ld a, 2 \ out (0x10), a
    ld b, 255 \ djnz $
    jp (hl)

#include "graphics.asm"

threadlist:
    .db "/bin/threadlist", 0
applibPath:
    .db "/lib/applib", 0
confirmMessage:
    .db lang_confirmShutdown, 0
shutdownOptions:
    .db 2
    .db lang_no, 0
    .db lang_yes, 0
