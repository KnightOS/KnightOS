; KnightOS applib
; General purpose application library

.nolist
libId .equ 0x02
#include "kernel.inc"
#include "libtext.inc" ; TODO: Support loading libraries from others
.list

.dw 0x0002

.org 0

jumpTable:
    ; Init
    ret \ nop \ nop
    ; Deinit
    ret \ nop \ nop
    jp appGetKey
    jp appWaitKey
    jp drawWindow
    jp getCharacterInput
    jp drawCharSetIndicator
    jp setCharSet
    jp getCharSet
    jp launchCastle
    jp launchThreadList
    .db 0xFF
    
; Same as kernel getKey, but listens for
; F1 and F5 and acts accordingly
appGetKey:
    call getKey
    jr checkKey

appWaitKey:
    call waitKey
    jr checkKey
    
checkKey:
    cp kYEqu
    ijp(z, launchCastle)
    cp kGraph
    ijp(z, launchThreadList)
    ret
    
launchCastle:
    push de
        ild(de, castlePath)
        di
        call launchProgram
    pop de
    call suspendCurrentThread
    call flushKeys
    xor a
    ret
    
launchThreadList:
    push de
        ild(de, threadListPath)
        di
        call launchProgram ; This is called several times when it should be called once
    pop de
    call suspendCurrentThread
    xor a
    ret
    
; Inputs:   IY: Screen buffer
;           HL: Window title text
;           A: Flags:
;               Bit 0: Set to skip castle graphic
;               Bit 1: Set to skip thread list graphic
;               Bit 2: Set to draw menu graphic (note the opposite use from others)
; Clears the buffer, then draws the standard frame and other items on it
drawWindow:
    push de
    push bc
    push hl
    push af
        call clearBuffer
        ld e, 0
        ld l, 0
        ld c, 96
        ld b, 59
        call rectOR
        ld e, 1
        ld l, 7
        ld c, 94
        ld b, 51
        call rectXOR
        
        push af
            xor a
            ld l, 0
            call resetPixel
            
            ld a, 95
            call resetPixel
        pop af
        
        bit 0, a
        jr nz, _        
            ild(hl, castleSprite1)
            ld b, 4
            ld de, $003C
            call putSprite16OR
            
            ild(hl, castleSprite2)
            ld d, 16
            call putSpriteOR
_:      pop af \ push af
        bit 1, a
        jr nz, _
            ild(hl, threadListSprite)
            ld de, 89 * 256 + 59
            ld b, 5
            call putSpriteOR
_:      pop af \ push af
        bit 2, a
        jr z, _
            ild(hl, menuSprite1)
            ld b, 4
            ld de, 40 * 256 + 60
            call putSprite16OR
            
            ild(hl, menuSprite2)
            ld d, 56
            dec b
            call PutSpriteOR
_:      pop af \ pop hl \ push hl \ push af
        ld de, $0201
        libtext(DrawStrXOR)
    pop af
    pop hl
    pop bc
    pop de
    ret
    
; Returns a character (ANSI) in A based on the pressed key.
; Returns actual raw keypress in B.
; Uses the upper-right hand corner of the screen to display
; input information, assumes you have a window chrome prepared.
; Possible values include \n and backspace (0x08).
; Also watches for F1/F5 to launch castle/thread list
getCharacterInput:
    icall(drawCharSetIndicator)
    
    ld b, 0
    icall(appGetKey)
    or a
    ret z ; Return if zero
    
    ld b, a
    
    ; Check for special keys
    cp kAlpha
    jr z, setCharSetFromKey
    cp k2nd
    jr z, setCharSetFromKey
    
    push bc
    
    ; Get key value
    sub 9
    jr c, _
    cp 41
    jr nc, _
    
    push hl
        push af
            ild(a, (charSet))
            add a, a \ add a, a \ add a, a \ ld b, a \ add a, a \ add a, a \ add a, b ; A * 40
            ild(hl, characterMapUppercase)
            add a, l
            ld l, a
            jr nc, $+3 \ inc h
        pop af
        
        add a, l
        ld l, a
        jr nc, $+3 \ inc h
        ld a, (hl)
    pop hl
    pop bc
    ret
    
_:  xor a
    pop bc
    ret
    
setCharSetFromKey:
    cp kAlpha
    icall(z, setAlphaKey)
    cp k2nd
    icall(z, set2ndKey)
    call flushKeys
    xor a
    ret
    
setAlphaKey: ; Switch between alpha charsets
    ild(a, (charSet))
    inc a
    cp 2 ; Clamp to <2
    jr c, _
        xor a
_:  ild((charSet), a)
    ret
    
set2ndKey: ; Switch between symbol charsets
    ild(a, (charSet))
    inc a
    cp 4 ; Clamp 1 < A < 4
    jr c, _
        ld a, 2
_:  cp 2
    jr nc, _
        ld a, 2
_:  ild((charSet), a)
    ret
    
; Draws the current character set indicator on a window
drawCharSetIndicator:
    push hl
    push de
    push bc
    push af
        ; Clear old sprite, if present
        ild(hl, clearCharSetSprite)
        ld de, 0x5C02
        ld b, 4
        call putSpriteOR
    
        ild(a, (charSet))
        ; Get sprite in HL
        add a, a \ add a, a ; A * 4
        ild(hl, charSetSprites)
        add a, l
        ld l, a
        jr nc, $+3 \ inc h
        ; Draw sprite
        call putSpriteXOR
    pop af
    pop bc
    pop de
    pop hl
    ret
    
charSet:
    .db 0
    
; Sets the character mapping to A.
; 0: uppercase \ 1: lowercase \ 2: symbols \ 3: extended
setCharSet:
    cp 4
    ret nc ; Only allow 0-3
    ild((charSet), a)
    ret
    
getCharSet:
    ild(a, (charSet))
    ret
    
#include "characters.asm"

castlePath:
    .db "/bin/castle", 0
threadlistPath:
    .db "/bin/threadlist", 0
    
castleSprite1: ; 16x4
    .db 0b10100110, 0b01101101
    .db 0b11101000, 0b10101001
    .db 0b10101000, 0b10100101
    .db 0b11100110, 0b01101100
    
castleSprite2: ; 8x4
    .db 0b00110010
    .db 0b10010101
    .db 0b00010110
    .db 0b10010011
    
threadListSprite: ; 8x5
    .db 0b00000000
    .db 0b00011100
    .db 0b00001100
    .db 0b00010100
    .db 0b00100000
    
menuSprite1: ; 16x4
    .db 0b10100100, 0b11001010
    .db 0b11101010, 0b10101010
    .db 0b11101100, 0b10101010
    .db 0b10100110, 0b10101110
    
menuSprite2: ; 8x3
    .db 0b00100000
    .db 0b01110000
    .db 0b11111000
    
clearCharSetSprite:
    .db 0b11100000
    .db 0b11100000
    .db 0b11100000
    .db 0b11100000
charSetSprites:

uppercaseASprite:
    .db 0b01000000
    .db 0b10100000
    .db 0b11100000
    .db 0b10100000
    
lowercaseASprite:
    .db 0b00000000
    .db 0b01100000
    .db 0b10100000
    .db 0b01100000
    
symbolSprite:
    .db 0b01000000
    .db 0b11000000
    .db 0b01000000
    .db 0b11100000
    
extendedSprite:
    .db 0b01000000
    .db 0b01000000
    .db 0b00000000
    .db 0b01000000