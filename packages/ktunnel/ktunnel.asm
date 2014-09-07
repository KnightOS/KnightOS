#define TUNNEL_MAX_SIZE 48
#define TUNNEL_MIN_SIZE 16
#define SHRINK_TIMER 128

#include "kernel.inc"
#include "corelib.inc"

    .db "KEXC"
    .db KEXC_ENTRY_POINT
    .dw start
    .db KEXC_STACK_SIZE
    .dw 50
    .db KEXC_NAME
    .dw name
    .db KEXC_HEADER_END
name:
    .db "KOS tunnel", 0
    
start:
    pcall(getLcdLock)
    pcall(getKeypadLock)
    
    pcall(allocScreenBuffer)
    
    kld(de, corelibPath)
    pcall(loadLibrary)
    
drawMenu:
    kld(hl, windowTitle)
    xor a
    corelib(drawWindow)
    
    kld(hl, titleScreenString)
    ld de, 0x020a
    ld b, 2
    pcall(drawStr)
    kld(hl, (lastScore))
    ld a, h
    and l
    inc a
    jr z, .noLastScore
    pcall(drawDecHL)
.noLastScore:
    
    pcall(fastCopy)
    
.waitMenuLoop:
    pcall(flushKeys)
    corelib(appWaitKey)
    jr nz, .waitMenuLoop
    cp kMode
    ret z
    cp k2nd
    jr nz, .waitMenuLoop
    
    ; play the game
    
    pcall(clearBuffer)
    
gameStart:
    ld a, 30
    kld((playerY), a)
    ld hl, 0
    kld((score), hl)
    kld(hl, tunnelCenter)
    ld (hl), 32
    inc hl
    ld (hl), TUNNEL_MAX_SIZE
    inc hl
    ld (hl), SHRINK_TIMER
    inc hl
    ld (hl), SHRINK_TIMER
gameLoop:
    ; draw a new slice of tunnel
    ld a, 95
    ld l, 0
    ld c, 64
    pcall(drawVLine)
    kld(a, (tunnelHeight))
    ld c, a
    srl a
    ld b, a
    kld(a, (tunnelCenter))
    sub b
    ld l, a
    ld a, 95
    pcall(drawVLineAND)
    
    ; move the center of the tunnel
    pcall(randA)
    and 1
    add a, a
    dec a
    kld(hl, tunnelCenter)
    add a, (hl)
    ld (hl), a
    kld(a, (tunnelHeight))
    srl a
    cp (hl)
    jr c, $+3
    ld (hl), a
    ld b, a
    ld a, 62
    sub b
    cp (hl)
    jr nc, $+3
    ld (hl), a
    
    ; shrink the tunnel if needed
    kld(hl, shrinkTunnelTimer)
    dec (hl)
    jr nz, .noShrink
    inc hl
    ld a, (hl)
    dec hl
    ld (hl), a
    dec hl
    ld a, TUNNEL_MIN_SIZE
    cp (hl)
    jr nc, .noShrink
    dec (hl)
.noShrink:
    ; draw twice faster if the calc is 6 MHz
    in a, (PORT_CALC_STATUS)
    bit BIT_CALC_STATUS_IS83PBE, a
    jr nz, .calcIs15
    kld(hl, drawAnotherFrame)
    inc (hl)
    bit 0, (hl)
    jr z, .calcIs15
    kcall(shiftBufferLeft)
    jr gameLoop
.calcIs15:
    
    kld(de, (playerY))
    ld b, 5
    kld(hl, playerSprite)
    pcall(putSpriteOR)
    pcall(fastCopy)
    kcall(shiftBufferLeft)
    
    kld(hl, playerY)
    corelib(appGetKey)
    kjp(nz, gameLoop)
    cp kUp
    jr nz, $+3
    dec (hl)
    cp kDown
    jr nz, $+3
    inc (hl)
    cp kMode
    jr nz, .noClear
    pcall(flushKeys)
    kjp(drawMenu)
.noClear:
    
    bit 7, (hl)
    jr z, $+4
    ld (hl), 0
    ld a, 59
    cp (hl)
    jr nc, $+4
    ld (hl), 59
    
    ; test collisions
    ld a, 3
    kld(hl, (playerY))
    pcall(getPixel)
    ld c, a
    ld b, 5
    ld de, 12
.collisionLoop:
    and (hl)
    jr nz, .collided
    add hl, de
    djnz .collisionLoop
    
    kjp(gameLoop)
    
.collided:
    push iy \ pop hl
    ld (hl), 0
    ld d, h
    ld e, l
    inc de
    ld bc, 12*6 - 1
    ldir
    kld(hl, endGameStr)
    ld de, 0
    pcall(drawStr)
    kld(hl, (score))
    kld((lastScore), hl)
    pcall(drawDecHL)
    pcall(fastCopy)
    
    pcall(flushKeys)
    corelib(appWaitKey)
    kjp(drawMenu)
    
shiftBufferLeft:
    push iy \ pop hl
    ld de, 767
    add hl, de
    ld b, 64
.shiftLoop:
    push bc
        ld a, (hl)
        sla a
        ld (hl), a
        dec hl
        ld b, 11
.shiftRowLoop:
        ld a, (hl)
        rla
        ld (hl), a
        dec hl
        djnz .shiftRowLoop
    pop bc
    djnz .shiftLoop
    ; also increment score
    kld(hl, (score))
    inc hl
    kld((score), hl)
    ret
    
; game variables
playerY:
    .dw 0
score:
    .dw 0
playerSprite:
    .db 0b10000000 ; #
    .db 0b11000000 ; ##
    .db 0b11100000 ; ###
    .db 0b11000000 ; ##
    .db 0b10000000 ; #
drawAnotherFrame:
    .db 0
    
tunnelCenter:
    .db 32
tunnelHeight:
    .db TUNNEL_MAX_SIZE
shrinkTunnelTimer:
    .db SHRINK_TIMER
timerReset:
    .db SHRINK_TIMER
lastScore:
    .dw -1
; other variables
    
corelibPath:
    .db "/lib/core", 0
windowTitle:
    .db "KnightOS tunnel", 0
titleScreenString:
    .db "Tunnel ! How nice is that ?\nPress 2nd to play or\nmode to quit.\n\nLast score : ", 0
endGameStr:
    .db "Game over ! Score : ", 0
    