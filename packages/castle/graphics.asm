#include "castle.lang"

drawChrome:
    call clearBuffer
    ; Castle top
    xor a
    ld l, 2
    call setPixel
    kld(hl, castleTopSprite)
    ld b, 12
    ld de, 0x0100
_:  ld a, 8
    push bc
        ld b, 3
        call putSpriteOR
    pop bc
    add a, d
    ld d, a
    djnz -_
    
    kld(hl, hotkeyLeftSprite)
    ld b, 8
    ld de, 0x0038
    call putSpriteOR
    
    kld(hl, hotkeyRightSprite)
    ld de, 0x5838
    call putSpriteOR
    
    ld hl, 0x000A
    ld de, 0x5F0A
    call drawLine
    
    kld(hl, batteryIndicatorSprite)
    ld b, 4
    ld de, 0x193B
    call putSpriteOR
    
    call getBatteryLevel
    xor a
    cp b
    jr z, ++_
    ld a, 26
_:  ld l, 60
    call setPixel
    inc l
    call setPixel
    inc a
    djnz -_
_:    
#ifdef CLOCK
    ; Get time
    push ix
        call getTime
        ; TODO
        kld(hl, dummyTimeString)
        ld de, (69 << 8) | 4
        call drawStr
    pop ix
#endif
    ret
    
drawHome:
    kld(hl, hotkeyPlusSprite)
    ld b, 5
    ld de, 0x013A
    call putSpriteOR
    
    kld(hl, hotkeyArrowRightSprite)
    ld de, 0x593A
    call putSpriteOR
    
    kld(hl, menuArrowSprite)
    ld b, 3
    ld de, 0x353B
    call putSpriteOR
    
    ld de, lang_more_position
    kld(hl, moreString)
    call drawStr
    
    ld de, lang_menu_position
    kld(hl, menuString)
    call drawStr
    
    ld de, lang_running_position
    kld(hl, runningString)
    call drawStr
    ret
    
drawHomeIcons:
    push de
    ld a, d
    push af
        ; Clear away old icons
        ld e, 0 \ ld l, 11 \ ld c, 96 \ ld b, 45
        call rectAND
        ld e, 0 \ ld l, 3 \ ld c, 69 \ ld b, 7
        call rectAND
        
        ld hl, 0x0021
        ld de, 0x5F21
        call drawLine
        
        ; Load config
        kld(de, configPath)
        call openFileRead
        push de
            call getStreamInfo
        pop de
        call malloc
        call streamReadBuffer
        call closeStream
        
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
            call putSprite16OR
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
            call putSprite16OR
        pop bc
        ld a, 19
        add a, d \ ld d, a
        djnz ---_
        
    pop af
    dec ix
    call memSeekToStart
    call free
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
            call rectOR
        pop bc \ pop hl \ pop de
        inc e \ inc l \ dec b \ dec b \ dec c \ dec c
        call rectXOR
    pop af \ pop bc \ pop hl \ pop de
    ret
    
drawSelectedName:
    push ix
        call memSeekToStart
        add ix, bc
        push ix \ pop hl
    pop ix
    ; Draw name string
    push de
        ld de, 0x0104
        call drawStr
    pop de
    ret
    
drawEmptySlotName:
    push de
        kld(hl, naString)
        ld de, 0x0104
        call drawStr
    pop de
    ret
    
drawPowerMenu:
    ld e, 27
    ld l, 36
    ld c, 67-26
    ld b, 56-35
    call rectOR
    ld e, 28
    ld l, 37
    ld c, 66-27
    ld b, 55-36
    call rectXOR
    ld de, 0x2339
    ld hl, 0x233F
    call drawLine
    ld de, 0x3B39
    ld hl, 0x3B3F
    call drawLine

    ld e, 36
    ld l, 56
    ld c, 23
    ld b, 1
    call rectXOR

    kld(hl, sleepString)
    ld de, lang_sleep_position
    call drawStr

    kld(hl, shutdownString)
    ld de, lang_shutdown_position
    call drawStr

    kld(hl, restartString)
    ld de, lang_restart_position
    call drawStr

    kld(hl, menuArrowSprite)
    ld de, 0x353B
    ld b, 3
    call putSpriteXOR

    kld(hl, menuArrowSpriteFlip)
    ld de, 0x353B
    ld b, 3
    call putSpriteOR

    kld(hl, selectionIndicatorSprite)
    ld de, 0x1D26
    ld b, 5
    call putSpriteOR
    ret

drawConfirmationDialog:
    ld e, 18 ; e, l, c, b
    ld l, 16
    ld c, 78-17
    ld b, 49-15
    call rectOR
    
    ld e, 19
    ld l, 17
    ld c, 77-18
    ld b, 48-16
    call rectXOR
    
    kld(hl, exclamationSprite1)
    ld b, 8
    ld de, 0x1820
    call putSpriteOR
    
    kld(hl, exclamationSprite2)
    ld b, 8
    ld de, 0x1828
    call putSpriteOR
    
    kld(hl, confirmString1)
    ld de, lang_areYouSure_position
    call drawStr
    
    kld(hl, confirmString2)
    ld de, lang_unsavedData_position
    call drawStr
    
    kld(hl, confirmString3)
    ld de, lang_mayBeLost_position
    call drawStr
    
    kld(hl, yesString)
    ld de, lang_yes_position
    call drawStr
    
    kld(hl, noString)
    ld de, lang_no_position
    call drawStr
    
    kld(hl, selectionIndicatorSprite)
    ld de, 0x282B
    ld b, 5
    call putSpriteOR
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
    
exclamationSprite1: ; 8x8
    .db 0b01110000
    .db 0b10001000
    .db 0b10001000
    .db 0b10001000
    .db 0b10001000
    .db 0b10001000
    .db 0b10001000
    .db 0b10001000

exclamationSprite2: ; 8x8
    .db 0b10001000
    .db 0b01110000
    .db 0b00000000
    .db 0b01110000
    .db 0b10001000
    .db 0b10001000
    .db 0b10001000
    .db 0b01110000
    
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
    .db lang_more, 0
runningString:
    .db lang_running, 0
menuString:
    .db lang_menu, 0
backString:
    .db lang_back, 0
optionsString:
    .db lang_options, 0
addToCastleString:
    .db lang_addToCastle, 0
removeFromCastleString:
    .db lang_removeFromCastle, 0
sleepString:
    .db lang_sleep, 0
shutdownString:
    .db lang_shutDown, 0
restartString:
    .db lang_restart, 0
confirmString1:
    .db lang_areYouSure, 0
confirmString2:
    .db lang_unsavedData, 0
confirmString3:
    .db lang_beLost, 0
yesString:
    .db lang_Yes, 0
noString:
    .db lang_no, 0
noProgramsInstalledString:
    .db lang_noPrograms, 0
configPath:
    .db "/etc/castle.config", 0
naString:
    .db lang_nonApp, 0
#ifdef CLOCK
dummyTimeString:
    .db "12:00 AM", 0
#endif
