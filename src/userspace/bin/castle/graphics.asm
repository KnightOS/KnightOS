
drawChrome:
    call clearBuffer
    ; Castle top
	xor a
	ld l, 2
	call setPixel
	kld hl, CastleTopSprite
	ld b, 12
	ld de, $0100
_:	ld a, 8
	push bc
		ld b, 3
		call PutSpriteOR
	pop bc
	add a, d
	ld d, a
	djnz -_
    
	kld hl, HotkeyLeftSprite
	ld b, 8
	ld de, $0038
	call PutSpriteOR
	
	kld hl, HotkeyRightSprite
	ld de, $5838
	call PutSpriteOR
	
	ld hl, $000A
	ld de, $5F0A
	call DrawLine
	
	kld hl, BatteryIndicatorSprite
	ld b, 4
	ld de, $193B
	call PutSpriteOR
	
	call GetBatteryLevel
	xor a
	cp b
	jr z, ++_
	ld a, 26
_:	ld l, 60
	call setPixel
	inc l
	call setPixel
	inc a
	djnz -_
_:	
    #ifdef CLOCK
    .echo "test"
    ; Get time
    push ix
        call getTime
        ; TODO
        kld hl, dummyTimeString
        ld de, 69 << 8 | 4
        ; libtext(DrawStr)
        rst $10
        .db libtextID
        call DrawStr
    pop ix
    #endif

    ret
    
drawHome:
	kld hl, HotkeyPlusSprite
	ld b, 5
	ld de, $013A
	call PutSpriteOR
	
	kld hl, HotkeyArrowRightSprite
	ld de, $593A
	call PutSpriteOR
	
	kld hl, MenuArrowSprite
	ld b, 3
	ld de, $353B
	call PutSpriteOR
	
	ld de, $093A
	kld hl, MoreString
	; libtext(DrawStr)
	rst $10
	.db libtextID
	call DrawStr
	
	ld de, $253A
	kld hl, MenuString
	; libtext(DrawStr)
	rst $10
	.db libtextID
	call DrawStr
	
	ld de, $3E3A
	kld hl, RunningString
	; libtext(DrawStr)
	rst $10
	.db libtextID
	call DrawStr
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
        
        ld hl, $0021
        ld de, $5F21
        call DrawLine
        
        jr _
        pop af \ pop de \ ret
_:
        
        ; Load config
        kld de, configPath
        call openFileRead
        push de
            call getStreamInfo
        pop de
        call allocMem
        push ix
            call streamReadToEnd
            call closeStream
        pop ix
        
        ; First row
        ld de, $020E
        ld bc, $0500
_:      ; Check to see if this item is selected
        pop af \ push af
        cp c \ kcall z, drawSelectionRectangle \ inc c
        
        ld l, (ix)
        ld h, (ix + 1)
        ld a, $FF
        push bc
            cp h \ jr nz, _ \ cp l \ jr nz, _
            kld hl, emptySlotIcon
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
        ld de, $0225
        ld bc, $0505
_:      ; Check to see if this item is selected
        pop af \ push af
        cp c \ kcall z, drawSelectionRectangle \ inc c
        
        ld l, (ix)
        ld h, (ix + 1)
        ld a, $FF
        push bc
            cp h \ jr nz, _ \ cp l \ jr nz, _
            kld hl, emptySlotIcon
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
    call freeMem
    pop de
	ret
    
drawSelectionRectangle:
    push de \ push hl \ push bc \ push af
        ; Find name string
        ld c, (ix)
        ld b, (ix + 1)
        ld a, $FF
        cp b
        jr nz, _
        cp c
        jr nz, _
        kcall drawEmptySlotName
        jr ++_
_:      kcall drawSelectedName
_:      ld a, e ; Get x
        sub 2
        ld l, a
        ld a, d ; Get y
        sub 2
        ld e, a
        ld bc, $1414
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
        ld de, $0104
        ; libtext(drawStr)
        rst $10
        .db libtextID
        call drawStr
    pop de
    ret
    
drawEmptySlotName:
    push de
        kld hl, naString
        ld de, $0104
        ; libtext(drawStr)
        rst $10
        .db libtextID
        call drawStr
    pop de
    ret
    
drawPowerMenu:
    ld e, 27
    ld l, 36
    ld c, 67-26
    ld b, 56-35
    call RectOR
    ld e, 28
    ld l, 37
    ld c, 66-27
    ld b, 55-36
    call RectXOR
    ld de, $2339
    ld hl, $233F
    call DrawLine
    ld de, $3B39
    ld hl, $3B3F
    call DrawLine

    ld e, 36
    ld l, 56
    ld c, 23
    ld b, 1
    call RectXOR

    kld hl, SleepString
    ld de, $2126
    ;libtext(DrawStr)
    rst $10
    .db libtextID
    call DrawStr

    kld hl, ShutdownString
    ld de, $212C
    ;libtext(DrawStr)
    rst $10
    .db libtextID
    call DrawStr

    kld hl, RestartString
    ld de, $2132
    ;libtext(RestartStr)
    rst $10
    .db libtextID
    call DrawStr

    kld hl, MenuArrowSprite
    ld de, $353B
    ld b, 3
    call PutSpriteXOR

    kld hl, MenuArrowSpriteFlip
    ld de, $353B
    ld b, 3
    call PutSpriteOR

    kld hl, SelectionIndicatorSprite
    ld de, $1D26
    ld b, 5
    call PutSpriteOR
    ret
    
DrawConfirmationDialog:
	ld e, 18 ; e, l, c, b
	ld l, 16
	ld c, 78-17
	ld b, 49-15
	call RectOR
	
	ld e, 19
	ld l, 17
	ld c, 77-18
	ld b, 48-16
	call RectXOR
	
	kld hl, ExclamationSprite1
	ld b, 8
	ld de, $1820
	call PutSpriteOR
	
	kld hl, ExclamationSprite2
	ld b, 8
	ld de, $1828
	call putSpriteOR
	
	kld hl, ConfirmString1
	ld de, $1A12
	;libtext(DrawStr)
	rst $10
	.db libtextID
	call drawStr
	
	kld hl, ConfirmString2
	ld de, $1418
	;libtext(DrawStr)
	rst $10
	.db libtextID
	call DrawStr
	
	kld hl, ConfirmString3
	ld de, $241E
	;libtext(DrawStr)
	rst $10
	.db libtextID
	call drawStr
	
	kld hl, YesString
	ld de, $2C25
	;libtext(DrawStr)
	rst $10
	.db libtextID
	call drawStr
	
	kld hl, NoString
	ld de, $2C2B
	;libtext(DrawStr)
	rst $10
	.db libtextID
	call drawStr
	
	kld hl, selectionIndicatorSprite
	ld de, $282B
	ld b, 5
	call putSpriteOR
	ret
    
CastleTopSprite: ; 8x3
	.db %11110000
	.db %10010000
	.db %10011111
	
HotkeyLeftSprite: ; 8x8
	.db %01111100
	.db %10000010
	.db %00000001
	.db %00000001
	.db %00000001
	.db %00000001
	.db %00000001
	.db %10000010
	
HotkeyRightSprite: ; 8x8
	.db %00111110
	.db %01000001
	.db %10000000
	.db %10000000
	.db %10000000
	.db %10000000
	.db %10000000
	.db %01000001
	
HotkeyPlusSprite: ; 8x5
	.db %00100000
	.db %00100000
	.db %11111000
	.db %00100000
	.db %00100000
	
HotkeyArrowLeftSprite: ; 8x5
	.db %0010000
	.db %0100000
	.db %1111100
	.db %0100000
	.db %0010000
	
HotkeyArrowRightSprite: ; 8x5
	.db %0010000
	.db %0001000
	.db %1111100
	.db %0001000
	.db %0010000
	
HotkeyArrowUpSprite: ; 8x5
	.db %0010000
	.db %0111000
	.db %1010100
	.db %0010000
	.db %0010000
	
MenuArrowSprite: ; 8x3
	.db %00100000
	.db %01110000
	.db %11111000
	
MenuArrowSpriteFlip: ; 8x3
	.db %11111000
	.db %01110000
	.db %00100000
	
BatteryIndicatorSprite: ; 8x4
	.db %11111100
	.db %10000110
	.db %10000110
	.db %11111100

SelectionIndicatorSprite: ; 8x5
	.db %10000000
	.db %11000000
	.db %11100000
	.db %11000000
	.db %10000000
	
ExclamationSprite1: ; 8x8
	.db %01110000
	.db %10001000
	.db %10001000
	.db %10001000
	.db %10001000
	.db %10001000
	.db %10001000
	.db %10001000

ExclamationSprite2: ; 8x8
	.db %10001000
	.db %01110000
	.db %00000000
	.db %01110000
	.db %10001000
	.db %10001000
	.db %10001000
	.db %01110000
	
DefaultIconSprite: ; 16x16
	.db %01111111, %11111110
	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %10000000, %00000001
	.db %10111111, %10111101
	.db %10100000, %10111101
	.db %10100000, %10111101
	.db %10111111, %10111101
	.db %10000000, %00111101
	.db %10111100, %00111101
	.db %10000000, %00111101
	.db %10111111, %00111101
	.db %10000000, %00111101
	.db %10111110, %00111101
	.db %10000000, %00000001
	.db %11111111, %11111111

emptySlotIcon: ; 16x16
    .db %10101010, %10101011
    .db %00000000, %00000001
    .db %10101000, %00000000
    .db %00010000, %00000001
    .db %10101000, %00000000
    .db %00000000, %00000001
    .db %10000000, %00000000
    .db %00000000, %00000001
    .db %10000000, %00000000
    .db %00000000, %00000001
    .db %10000000, %00000000
    .db %00000000, %00000001
    .db %10000000, %00000000
    .db %00000000, %00000001
    .db %10000000, %00000000
    .db %11010101, %01010101

    #include "castle.lang"
MoreString:
	.db lang_more, 0
RunningString:
	.db lang_running, 0
MenuString:
	.db lang_menu, 0
BackString:
	.db lang_back, 0
OptionsString:
	.db lang_options, 0
AddToCastleString:
	.db lang_addToCastle, 0
RemoveFromCastleString:
	.db lang_removeFromCastle, 0
SleepString:
	.db lang_sleep, 0
ShutdownString:
	.db lang_shutDown, 0
RestartString:
	.db lang_restart, 0
ConfirmString1:
	.db lang_areYouSure, 0
ConfirmString2:
	.db lang_unsavedData, 0
ConfirmString3:
	.db lang_beLost, 0
YesString:
	.db lang_Yes, 0
NoString:
	.db lang_no, 0
NoProgramsInstalledString:
	.db lang_noPrograms, 0
configPath:
    .db "/etc/castle.config", 0
naString:
    .db lang_nonApp, 0
dummyTimeString:
    .db "12:00 AM", 0