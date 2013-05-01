.nolist
#include "kernel.inc"
#include "libtext.inc"
.list
    .db 0, 50
.org 0
start:
    call getLcdLock
    call getKeypadLock

    call allocScreenBuffer
    kld(de, libtext)
    call loadLibrary
resetToHome:
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
    kjp(z, launchThreadList)
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
    cp $DF
    jr nz, _
    inc (hl)
    inc a
_:  out (0x10), a
    kjp(homeLoop)
    
launchThreadList:
    kld(de, threadlist)
launch:
    di
    call launchProgram
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
    kcall(drawConfirmationDialog)
        
confirmSelectionLoop:
    call fastCopy
    call flushKeys
    call waitKey

    cp kUp
    jr z, confirmSelectionLoop_Up
    cp kDown
    jr z, confirmSelectionLoop_Down
    cp kEnter
    jr z, confirmSelectionLoop_Select
    cp k2nd
    jr z, confirmSelectionLoop_Select
    cp kClear
    kjp(z, resetToHome)
        
confirmSelectionLoop_Up:
    call putSpriteXOR
    ld de, 0x2825
    call putSpriteOR
    jr confirmSelectionLoop
        
confirmSelectionLoop_Down:
    call putSpriteXOR
    ld de, 0x282B
    call putSpriteOR
    jr confirmSelectionLoop

confirmSelectionLoop_Select:
    pop hl
    ld a, 0x2B
    cp e
    kjp(z, resetToHome)
    ; Before restarting, shut off the screen for a moment
    ; This was added because some people had the impression
    ; that restarting the calculator didn't do anything
    ld a, 2 \ out (10h), a
    ld b, 255 \ djnz $
    jp (hl)
    
libtext:
    .db "/lib/libtext", 0
threadlist:
    .db "/bin/threadlist", 0
    
#include "graphics.asm"