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
UppercaseASprite:
	.db %01000000
	.db %10100000
	.db %11100000
	.db %10100000
LowercaseASprite:
	.db %00000000
	.db %01100000
	.db %10100000
	.db %01100000
SymbolSprite:
	.db %01000000
	.db %11000000
	.db %01000000
	.db %11100000
ExtendedSprite:
	.db %01000000
	.db %01000000
	.db %00000000
	.db %01000000