.nolist
libId .equ $02
#include "kernel.inc"
#include "libtext.inc" ; TODO: Support loading libraries from others
#include "keys.inc"
.list

.dw $0002

.org 0

JumpTable:
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
    .db $FF
    
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
    ;ijp(z, launchCastle)
    rst $10 \ .db libId
    jp z, launchCastle
    cp kGraph
    ;ijp(z, launchThreadList)
    rst $10 \ .db libId
    jp z, launchThreadList
    ret
    
launchCastle:
    push de
        ;ild(de, castlePath)
        rst $10 \ .db libId
        ld de, castlePath
        di
        call launchProgram
    pop de
    call suspendCurrentThread
    call flushKeys
    xor a
    ret
    
launchThreadList:
    push de
        ;ild(de, threadListPath)
        rst $10 \ .db libId
        ld de, threadListPath
        di
        call launchProgram
    pop de
    call suspendCurrentThread
    ei
    call flushKeys
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
            ;ild(hl, CastleSprite1)
            rst $10
            .db libID
            ld hl, castleSprite1
            ld b, 4
            ld de, $003C
            call putSprite16OR
            
            ;ild(hl, CastleSprite2)
            rst $10
            .db libID
            ld hl, castleSprite2
            ld d, 16
            call putSpriteOR
_:      pop af \ push af
        bit 1, a
        jr nz, _
            ;ild(hl, ThreadListSprite)
            rst $10
            .db libID
            ld hl, threadListSprite
            ld de, 89 * 256 + 59
            ld b, 5
            call putSpriteOR
_:      pop af \ push af
        bit 2, a
        jr z, _
            ;ild(hl, MenuSprite1)
            rst $10
            .db libID
            ld hl, menuSprite1
            ld b, 4
            ld de, 40 * 256 + 60
            call putSprite16OR
            
            ;ild(hl, MenuSprite2)
            rst $10
            .db libID
            ld hl, menuSprite2
            ld d, 56
            dec b
            call PutSpriteOR
_:      pop af \ pop hl \ push hl \ push af
        ld de, $0201
        ;libtext(DrawStrXOR)
        rst $10
        .db libtextID
        call drawStrXOR
    pop af
    pop hl
    pop bc
    pop de
    ret
    
; Returns a character (ASCII) in A based on the pressed key.
; Uses the upper-right hand corner of the screen to display
; input information, assumes you have a window chrome prepared.
; Possible values include \n and backspace (0x08).
; TODO: Add DEL
getCharacterInput:
    ; lcall(drawCharacterSetIndicator)
    rst $10 \ .db libID \ call drawCharSetIndicator

    call getKey
    or a
    ret z ; Return if zero
    
    ; Check for special keys
    cp kAlpha
    jr z, setCharSetFromKey
    cp k2nd
    jr z, setCharSetFromKey
    ret
    
setCharSetFromKey:
    cp kAlpha
    ; lcall(z, setAlphaKey)
    rst $10 \ .db libID \ call z, setAlphaKey
    cp k2nd
    ; lcall(z, set2ndKey)
    rst $10 \ .db libID \ call z, set2ndKey
    call flushKeys
    xor a
    ret
    
setAlphaKey: ; Switch between alpha charsets
    ; lld(a, (charSet))
    rst $10 \ .db libID \ ld a, (charSet)
    inc a
    cp 2 ; Clamp to <2
    jr c, _
        xor a
_:  ; lld((charSet), a)
    rst $10 \ .db libID \ ld (charSet), a
    ret
    
set2ndKey: ; Switch between symbol charsets
    ; lld(a, (charSet))
    rst $10 \ .db libID \ ld a, (charSet)
    inc a
    cp 4 ; Clamp 1 < A < 4
    jr c, _
        ld a, 2
_:  cp 2
    jr nc, _
        ld a, 2
_:  ; lld((charSet), a)
    rst $10 \ .db libID \ ld (charSet), a
    ret
    
; Draws the current character set indicator on a window
drawCharSetIndicator:
    push hl
    push de
    push bc
    push af
        ; Clear old sprite, if present
        ; lld(hl, clearCharSetSprite)
        rst $10 \ .db libID \ ld hl, clearCharSetSprite
        ld de, $5C02
        ld b, 4
        call putSpriteOR
    
        ; lld(a, (charSet))
        rst $10 \ .db libID \ ld a, (charSet)
        ; Get sprite in HL
        add a, a \ add a, a ; A * 4
        ; lld(hl, charSetSprites)
        rst $10 \ .db libID \ ld hl, charSetSprites
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
    ; lld((charSet), a)
    rst $10 \ .db libID \ ld (charSet), a
    ret
    
getCharSet:
    ; lld(a, (charSet))
    rst $10 \ .db libID \ ld a, (charSet)
    ret
    
#include "characters.asm"

castlePath:
    .db "/bin/castle", 0
threadlistPath:
    .db "/bin/threadlist", 0
    
CastleSprite1: ; 16x4
    .db %10100110, %01101101
    .db %11101000, %10101001
    .db %10101000, %10100101
    .db %11100110, %01101100
    
CastleSprite2: ; 8x4
    .db %00110010
    .db %10010101
    .db %00010110
    .db %10010011
    
ThreadListSprite: ; 8x5
    .db %00000000
    .db %00011100
    .db %00001100
    .db %00010100
    .db %00100000
    
MenuSprite1: ; 16x4
    .db %10100100, %11001010
    .db %11101010, %10101010
    .db %11101100, %10101010
    .db %10100110, %10101110
    
MenuSprite2: ; 8x3
    .db %00100000
    .db %01110000
    .db %11111000
    
clearCharSetSprite:
    .db %11100000
    .db %11100000
    .db %11100000
    .db %11100000
charSetSprites:

uppercaseASprite:
    .db %01000000
    .db %10100000
    .db %11100000
    .db %10100000
    
lowercaseASprite:
    .db %00000000
    .db %01100000
    .db %10100000
    .db %01100000
    
symbolSprite:
    .db %01000000
    .db %11000000
    .db %01000000
    .db %11100000
    
extendedSprite:
    .db %01000000
    .db %01000000
    .db %00000000
    .db %01000000