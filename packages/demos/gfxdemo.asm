; KnightOS graphical demo
; Portions of the color demo provided by Christopher Mitchell
#include "kernel.inc"
#include "corelib.inc"
#include "fx3dlib.inc"
    .db "KEXC"
    .db KEXC_ENTRY_POINT
    .dw start
    .db KEXC_STACK_SIZE
    .dw 100
    .db KEXC_KERNEL_VER
    .db 0, 6
    .db KEXC_NAME
    .dw name
    .db KEXC_HEADER_END
name:
    .db "Graphical Demo", 0
start:
    ; Load dependencies
    kld(de, corelibPath)
    pcall(loadLibrary)
    
    kld(de, fx3dlibPath)
    pcall(loadLibrary)
    
    pcall(getLcdLock)
    pcall(getKeypadLock)

    pcall(colorSupported)
    kjp(nz, noColor)
    
    ; Short intro message in legacy mode
    pcall(allocScreenBuffer)
    pcall(clearBuffer)
    kld(hl, introString)
    ld de, 0
    ld b, 0
    pcall(drawStr)
    pcall(fastCopy)
    pcall(flushKeys)
    pcall(waitKey)
    pcall(resetLegacyLcdMode)

_:  ld iy, 0b1111100000000000 ; Red
    pcall(clearColorLcd)
    pcall(flushKeys)
    corelib(appWaitKey)
    jr nz, -_

_:  ld iy, 0b0000011111100000 ; Green
    pcall(clearColorLcd)
    pcall(flushKeys)
    corelib(appWaitKey)
    jr nz, -_

_:  ld iy, 0b0000000000011111 ; Blue
    pcall(clearColorLcd)
    pcall(flushKeys)
    corelib(appWaitKey)
    jr nz, -_
    
_:  pcall(flushKeys)
    ld h, 0
    ld d, 0
    pcall(getRandom)
    ld l, a
    pcall(getRandom)
    ld e, a
    pcall(getRandom)
    ld b, a
    pcall(getRandom)
    ld c, a
    pcall(getRandom)
    ld iyl, a
    pcall(getRandom)
    ld iyh, a
    pcall(clipColorRectangle)
    corelib(appGetKey)
    jr nz, .handleRedraw
    or a
    jr z, -_
    
    kjp(ballDemo)
    
.handleRedraw:
    ld iy, 0b0000000000011111
    pcall(clearColorLcd)
    jr -_

noColor:

.macro sdiv64()
    add hl, hl
    sbc a, a
    add hl, hl
    rla
    ld l, h
    ld h, a
.endmacro
    
    pcall(allocScreenBuffer)
    
    ld hl, 0
    kld((angle), hl)
    ; allocate some space to hold the rotated vertices for backface culling
    ; 8 vertices, 6 bytes each
    ld bc, 8 * 6
    pcall(malloc)
.demoLoop:
    kld(hl, windowTitle)
    xor a
    corelib(drawWindow)
    kld(hl, exitString)
    ld de, 0x0208
    pcall(drawStr)
    
    ; first rotate and projects the vertices
    xor a
    kld((vertexNb), a)
    kld(hl, vertices)
.calculationLoop:
    push hl
        kld(de, currentRVertex)
        kld(bc, (angle))
        
        fx3dlib(rotateVertex)
        ; save the rotated vertex for backface culling
        push ix \ pop de
        kld(hl, currentRVertex)
        ld bc, 6
        ldir
        push de \ pop ix
        kld(de, currentRVertex)
        fx3dlib(projectVertex)
        
        ld bc, 48
        add hl, bc
        ex de, hl
        ld bc, 32
        add hl, bc
        
        kld(a, (vertexNb))
        add a, a
        ld c, a
        ld b, 0
        push hl
            kld(hl, projected)
            add hl, bc
            ld (hl), e
            inc hl
        pop de
        ld (hl), e
        
    pop hl
    ld de, 6
    add hl, de
    kld(a, (vertexNb))
    inc a
    kld((vertexNb), a)
    cp 8
    kjp(c, .calculationLoop)
    
    ; then, draw lines between the vertices
    ; at this point, all the rotated vertices must be in IX
    dec ix
    pcall(memSeekToStart)
    push ix \ pop hl
    kld(bc, faces)
    ; 6 faces in a cube
    ld a, 6
.renderLoop:
    push af
        push bc \ push hl
            fx3dlib(testBackface)
        pop hl \ pop bc
        jr c, .noDraw
        
        push bc \ push hl
            ; draws 4 lines
            ld a, 4
.drawLoop:
            push af
                ; retrieve first point
                dec a
                ld e, c
                ld d, b
                add a, e
                ld e, a
                ld a, 0
                adc a, d
                ld d, a
                ld a, (de)
                add a, a
                ld e, a
                ld d, 0
                kld(hl, projected)
                add hl, de
                ld d, (hl)
                inc hl
                ld e, (hl)
                
            pop af \ push af
                push de
                    ; retrieve second point
                    and 3
                    ld e, c
                    ld d, b
                    add a, e
                    ld e, a
                    ld a, 0
                    adc a, d
                    ld d, a
                    ld a, (de)
                    add a, a
                    ld e, a
                    ld d, 0
                    kld(hl, projected)
                    add hl, de
                    ld d, (hl)
                    inc hl
                    ld e, (hl)
                pop hl
                pcall(drawLine)
            pop af
            dec a
            jr nz, .drawLoop
        
        pop hl \ pop bc
.noDraw:
        ; 4 vertices per face in a cube
        inc bc \ inc bc \ inc bc \ inc bc
    pop af
    dec a
    jr nz, .renderLoop
    
    push hl \ pop ix
    
    ; we're done rendering
    pcall(fastCopy)
    pcall(clearBuffer)
    corelib(appGetKey)
    kjp(nz, .demoLoop)
    cp kMode
    kjp(z, .exitDemo)
    
    kld(hl, (angle))
    inc h
    inc l
    kld((angle), hl)
    
    kjp(.demoLoop)
.exitDemo:
    pcall(free)
    ret
    
curSin:
    .db 0
curCos:
    .db 0
angle:
    .db 0, 0
    
vertexNb:
    .db 0
currentVertex:
    .dw 0, 0, 0
currentRVertex:
    .dw 0, 0, 0
vertices:
    .dw -40, 40, -40
    .dw 40, 40, -40
    .dw 40, -40, -40
    .dw -40, -40, -40
    .dw -40, 40, 40
    .dw 40, 40, 40
    .dw 40, -40, 40
    .dw -40, -40, 40
projected:
    .block 8 * 2
faces:
    .db 0, 1, 2, 3
    .db 5, 4, 7, 6
    .db 1, 5, 6, 2
    .db 4, 0, 3, 7
    .db 4, 5, 1, 0
    .db 3, 2, 6, 7
    
exitString:
    .db "Press [MODE] to exit.", 0
windowTitle:
    .db "Graphical Demo", 0
corelibPath:
    .db "/lib/core", 0
fx3dlibPath:
    .db "/lib/fx3d", 0
introString:
    .db "Graphical demo for KnightOS\n\n"
    .db "Portions of this demo by\nChristopher Mitchell\n\n"
    .db "Press any key to begin.", 0

.equ nballs 10
ballDemo:
    pcall(flushKeys)
    ld iy, 0xFFFF
    pcall(clearColorLcd)
    ld bc, nballs * 5 + 1
    pcall(malloc)
    inc ix
    ld a, r
    ld (ix + -1), a
    ld a, 1
    ld b, nballs
    push ix \ pop hl
    ld de, 8 ;starting x
    ;ld c,5  ;starting y
InitSetupLoop:
    ld (hl), e ;x
    inc hl
    ld (hl), d ;x
    inc hl
    pcall(getRandom)
    and 0x02
    dec a
    ld (hl), a ;x velocity
    inc hl
    pcall(getRandom)
    cp 240 - 16
    jr c,InitSetupLoop_XOK
    and 0x7F
InitSetupLoop_XOK:
    ld (hl), a ;y
    inc hl
    pcall(getRandom)
    and 0x02
    dec a
    ld (hl), a ;y velocity
    inc hl
    push hl
        ld hl, 20
        add hl, de
    pop de
    ex de, hl
    ld a, 10
    add a, c
    ld c, a
    djnz initSetupLoop
    
ballTime:
    ld b, nballs
    push ix \ pop hl
ballTimeLoop:
    push hl
        ld e, (hl)
        inc hl
        ld d, (hl)
        inc hl
        push hl
            ex de, hl
            ld a, 0x52 ;"Vertical" = X for us
            pcall(writeLcdRegister)
            ld a, 0x21 ;"Vertical" = X for us
            pcall(writeLcdRegister)
            push hl
                ld de, 15
                add hl, de
                ld a, 0x53 ;"Vertical" = X for us
                pcall(writeLcdRegister)
                pop hl
            pop de
        ld a, (de)
        ld e, a
        ld d, 0
        cp 0xFF
        jr nz, ballTimeLoop_CheckReverse
        ld d, 0xFF
ballTimeLoop_CheckReverse:
        add hl, de
        pop de
    ex de, hl
    ld (hl), e
    inc hl
    ld (hl), d
    inc hl
    push hl
        ld hl, 320 - 16
        or a
        sbc hl, de
        add hl, de ; cpHLDE
        jr z, ballTimeLoop_DoXFlip
        ld a, e
        or d
        jr nz, ballTimeLoop_NoXFlip
ballTimeLoop_DoXFlip:
        pop hl
    ld c, (hl)
    xor a
    sub c
    ld (hl), a
    push hl
ballTimeLoop_NoXFlip:
        pop hl
    inc hl
    push hl
        ld e, (hl)
        inc hl
        push hl
            ex de, hl
            ld h, 0
            ld a, 0x50 ;"Horizontal" = Y for us
            pcall(writeLcdRegister)
            ld h, 0
            ld a, 0x20 ;"Horizontal" = Y for us
            pcall(writeLcdRegister)
        pop de
        ld a, (de)
        add a, l
        pop de
    ex de, hl
    ld (hl), a
    inc hl
    push hl
        cp 240 - 16
        jr z,BallTimeLoop_DoYFlip
        or a
        jr nz, ballTimeLoop_NoYFlip
ballTimeLoop_DoYFlip:
        pop hl
    ld c, (hl)
    xor a
    sub c
    ld (hl), a
    push hl
ballTimeLoop_NoYFlip:
        pop hl
    inc hl

    push hl
        ld a, 0x22 \ ld c, 0x10 \ out (c),0 \ out (c),a

        push bc
            ld bc, 0x0011 ; 16*16
            kld(hl, redBall)
ballRender1:
            outi
            jr nz, ballRender1
ballRender2:
            outi
            jr nz, ballRender2
            pop bc
        pop hl
    dec b
    ld a, b
    kjp(nz, BallTimeLoop)
    
    corelib(appGetKey)
    pcall(nz, clearColorLcd)
    or a
    kjp(z, ballTime)

    pcall(fullScreenWindow)
    ret
    
redBall:
    .db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0xe8, 0xe4, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .db 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0xe8, 0xe4, 0xff, 0xff, 0xff, 0xff, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff
    .db 0xff, 0xff, 0x00, 0x00, 0xe8, 0xe4, 0xe8, 0xe4, 0xff, 0xff, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff
    .db 0xff, 0xff, 0x00, 0x00, 0xe8, 0xe4, 0xe8, 0xe4, 0xff, 0xff, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0x88, 0x02, 0x00, 0x00, 0xff, 0xff
    .db 0xff, 0xff, 0x00, 0x00, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0x88, 0x02, 0x00, 0x00, 0xff, 0xff
    .db 0xff, 0xff, 0x00, 0x00, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0x88, 0x02, 0x88, 0x02, 0x00, 0x00, 0xff, 0xff
    .db 0xff, 0xff, 0x00, 0x00, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0x88, 0x02, 0x88, 0x02, 0x88, 0x02, 0x00, 0x00, 0xff, 0xff
    .db 0xff, 0xff, 0x00, 0x00, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0x88, 0x02, 0x88, 0x02, 0x88, 0x02, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff
    .db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0x88, 0x02, 0x88, 0x02, 0x88, 0x02, 0x88, 0x02, 0x88, 0x02, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x88, 0x02, 0x88, 0x02, 0x88, 0x02, 0x88, 0x02, 0x88, 0x02, 0x88, 0x02, 0x88, 0x02, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x88, 0x02, 0x88, 0x02, 0x88, 0x02, 0x88, 0x02, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
