drawChrome:
    pcall(clearBuffer)
    ; Castle top
    xor a
    ld l, 2
    pcall(setPixel)
    kld(hl, castleTopSprite)
    ld b, 12
    ld de, 0x0100
_:  ld a, 8
    push bc
        ld b, 3
        pcall(putSpriteOR)
    pop bc
    add a, d
    ld d, a
    djnz -_

    kld(hl, hotkeyLeftSprite)
    ld b, 8
    ld de, 0x0038
    pcall(putSpriteOR)

    kld(hl, hotkeyRightSprite)
    ld de, 0x5838
    pcall(putSpriteOR)

    ld hl, 0x000A
    ld de, 0x5F0A
    pcall(drawLine)

    kld(hl, batteryIndicatorSprite)
    ld b, 4
    ld de, 0x193B
    pcall(putSpriteOR)

    pcall(getBatteryLevel)
    xor a
    cp b
    jr z, ++_
    ld a, 26
_:  ld l, 60
    pcall(setPixel)
    inc l
    pcall(setPixel)
    inc a
    djnz -_
_:
#ifdef CLOCK
    ; Get time
    push ix
        pcall(getTime)
        ; TODO
        kld(hl, dummyTimeString)
        ld de, (69 << 8) | 4
        pcall(drawStr)
    pop ix
#endif
    ret

drawHome:
    kld(hl, hotkeyPlusSprite)
    ld b, 5
    ld de, 0x013A
    pcall(putSpriteOR)

    kld(hl, hotkeyArrowRightSprite)
    ld de, 0x593A
    pcall(putSpriteOR)

    kld(hl, menuArrowSprite)
    ld b, 3
    ld de, 0x353B
    pcall(putSpriteOR)

    ld de, 0x093A
    kld(hl, moreString)
    pcall(drawStr)

    ld de, 0x253A
    kld(hl, menuString)
    pcall(drawStr)

    ld de, 0x3E3A
    kld(hl, runningString)
    pcall(drawStr)
    ret

drawHomeIcons:
    push de
    ld a, d
    push af
        ; Clear away old icons
        ld e, 0 \ ld l, 11 \ ld c, 96 \ ld b, 45
        pcall(rectAND)
        ld e, 0 \ ld l, 3 \ ld c, 69 \ ld b, 7
        pcall(rectAND)

        ld hl, 0x0021
        ld de, 0x5F21
        pcall(drawLine)

        ; Load config
        kld(de, configPath)
        pcall(openFileRead)
        pcall(getStreamInfo)
        pcall(malloc)
        pcall(streamReadBuffer)
        pcall(closeStream)

        ; First row
        ld de, 0x020E
        ld bc, 0x0500
_:      ; Check to see if this item is selected
        pop af \ push af
        cp c \ kcall(z, drawSelectionRectangle) \ inc c

        ld l, (ix)
        ld h, (ix + 1)
        ld a, 0xFF
        push bc
            cp h \ jr nz, _ \ cp l \ jr nz, _
            kld(hl, emptySlotIcon)
            inc ix \ inc ix
            jr ++_

_:          ld bc, 4
            add ix, bc
            push ix \ pop hl
            ld bc, 32
            add ix, bc
_:
            ld b, 16
            pcall(putSprite16OR)
        pop bc
        ld a, 19
        add a, d \ ld d, a
        djnz ---_

        ; Second row
        ld de, 0x0225
        ld bc, 0x0505
_:      ; Check to see if this item is selected
        pop af \ push af
        cp c \ kcall(z, drawSelectionRectangle) \ inc c

        ld l, (ix)
        ld h, (ix + 1)
        ld a, 0xFF
        push bc
            cp h \ jr nz, _ \ cp l \ jr nz, _
            kld(hl, emptySlotIcon)
            inc ix \ inc ix
            jr ++_

_:          ld bc, 4
            add ix, bc
            push ix \ pop hl
            ld bc, 32
            add ix, bc
_:
            ld b, 16
            pcall(putSprite16OR)
        pop bc
        ld a, 19
        add a, d \ ld d, a
        djnz ---_

    pop af
    dec ix
    pcall(memSeekToStart)
    pcall(free)
    pop de
    ret

drawSelectionRectangle:
    push de \ push hl \ push bc \ push af
        ; Find name string
        ld c, (ix)
        ld b, (ix + 1)
        ld a, 0xFF
        cp b
        jr nz, _
        cp c
        jr nz, _
        kcall(drawEmptySlotName)
        jr ++_
_:      kcall(drawSelectedName)
_:      ld a, e ; Get x
        sub 2
        ld l, a
        ld a, d ; Get y
        sub 2
        ld e, a
        ld bc, 0x1414
        push de \ push hl \ push bc
            pcall(rectOR)
        pop bc \ pop hl \ pop de
        inc e \ inc l \ dec b \ dec b \ dec c \ dec c
        pcall(rectXOR)
    pop af \ pop bc \ pop hl \ pop de
    ret

drawSelectedName:
    push ix
        pcall(memSeekToStart)
        add ix, bc
        push ix \ pop hl
    pop ix
    ; Draw name string
    push de
        ld de, 0x0104
        pcall(drawStr)
    pop de
    ret

drawEmptySlotName:
    push de
        kld(hl, naString)
        ld de, 0x0104
        pcall(drawStr)
    pop de
    ret

drawPowerMenu:
    ld e, 27
    ld l, 36
    ld c, 67-26
    ld b, 56-35
    pcall(rectOR)
    ld e, 28
    ld l, 37
    ld c, 66-27
    ld b, 55-36
    pcall(rectXOR)
    ld de, 0x2339
    ld hl, 0x233F
    pcall(drawLine)
    ld de, 0x3B39
    ld hl, 0x3B3F
    pcall(drawLine)

    ld e, 36
    ld l, 56
    ld c, 23
    ld b, 1
    pcall(rectXOR)

    kld(hl, sleepString)
    ld de, 0x2126
    pcall(drawStr)

    kld(hl, shutdownString)
    ld de, 0x212C
    pcall(drawStr)

    kld(hl, restartString)
    ld de, 0x2132
    pcall(drawStr)

    kld(hl, menuArrowSprite)
    ld de, 0x353B
    ld b, 3
    pcall(putSpriteXOR)

    kld(hl, menuArrowSpriteFlip)
    ld de, 0x353B
    ld b, 3
    pcall(putSpriteOR)

    kld(hl, selectionIndicatorSprite)
    ld de, 0x1D26
    ld b, 5
    pcall(putSpriteOR)
    ret

castleTopSprite: ; 8x3
    .db 0b11110000
    .db 0b10010000
    .db 0b10011111

hotkeyLeftSprite: ; 8x8
    .db 0b01111100
    .db 0b10000010
    .db 0b00000001
    .db 0b00000001
    .db 0b00000001
    .db 0b00000001
    .db 0b00000001
    .db 0b10000010

hotkeyRightSprite: ; 8x8
    .db 0b00111110
    .db 0b01000001
    .db 0b10000000
    .db 0b10000000
    .db 0b10000000
    .db 0b10000000
    .db 0b10000000
    .db 0b01000001

hotkeyPlusSprite: ; 8x5
    .db 0b00100000
    .db 0b00100000
    .db 0b11111000
    .db 0b00100000
    .db 0b00100000

hotkeyArrowLeftSprite: ; 8x5
    .db 0b0010000
    .db 0b0100000
    .db 0b1111100
    .db 0b0100000
    .db 0b0010000

hotkeyArrowRightSprite: ; 8x5
    .db 0b0010000
    .db 0b0001000
    .db 0b1111100
    .db 0b0001000
    .db 0b0010000

hotkeyArrowUpSprite: ; 8x5
    .db 0b0010000
    .db 0b0111000
    .db 0b1010100
    .db 0b0010000
    .db 0b0010000

menuArrowSprite: ; 8x3
    .db 0b00100000
    .db 0b01110000
    .db 0b11111000

menuArrowSpriteFlip: ; 8x3
    .db 0b11111000
    .db 0b01110000
    .db 0b00100000

batteryIndicatorSprite: ; 8x4
    .db 0b11111100
    .db 0b10000110
    .db 0b10000110
    .db 0b11111100

selectionIndicatorSprite: ; 8x5
    .db 0b10000000
    .db 0b11000000
    .db 0b11100000
    .db 0b11000000
    .db 0b10000000

defaultIconSprite: ; 16x16
    .db 0b01111111, 0b11111110
    .db 0b11111111, 0b11111111
    .db 0b11111111, 0b11111111
    .db 0b10000000, 0b00000001
    .db 0b10111111, 0b10111101
    .db 0b10100000, 0b10111101
    .db 0b10100000, 0b10111101
    .db 0b10111111, 0b10111101
    .db 0b10000000, 0b00111101
    .db 0b10111100, 0b00111101
    .db 0b10000000, 0b00111101
    .db 0b10111111, 0b00111101
    .db 0b10000000, 0b00111101
    .db 0b10111110, 0b00111101
    .db 0b10000000, 0b00000001
    .db 0b11111111, 0b11111111

emptySlotIcon: ; 16x16
    .db 0b10101010, 0b10101011
    .db 0b00000000, 0b00000001
    .db 0b10101000, 0b00000000
    .db 0b00010000, 0b00000001
    .db 0b10101000, 0b00000000
    .db 0b00000000, 0b00000001
    .db 0b10000000, 0b00000000
    .db 0b00000000, 0b00000001
    .db 0b10000000, 0b00000000
    .db 0b00000000, 0b00000001
    .db 0b10000000, 0b00000000
    .db 0b00000000, 0b00000001
    .db 0b10000000, 0b00000000
    .db 0b00000000, 0b00000001
    .db 0b10000000, 0b00000000
    .db 0b11010101, 0b01010101

moreString:
    .db "More", 0
runningString:
    .db "Running", 0
menuString:
    .db "Menu", 0
backString:
    .db "Back", 0
optionsString:
    .db "Options", 0
addToCastleString:
    .db "Add to Castle", 0
removeFromCastleString:
    .db "Remove from Castle", 0
sleepString:
    .db "Sleep", 0
shutdownString:
    .db "Shut Down", 0
restartString:
    .db "Restart", 0
noProgramsInstalledString:
    .db "No programs installed!", 0
configPath:
    .db "/etc/castle.conf", 0
naString:
    .db "[n/a]", 0
#ifdef CLOCK
dummyTimeString:
    .db "12:00 AM", 0
#endif
