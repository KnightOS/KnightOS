#include "kernel.inc"
#include "corelib.inc"
.org 0
    .db "KEXC"
    .db KEXC_ENTRY_POINT
    .dw Init_All
    .db KEXC_STACK_SIZE
    .dw 100
    .db KEXC_NAME
    .dw programName
    .db KEXC_DESCRIPTION
    .dw description
    .db KEXC_HEADER_END

programName:
    .db "Pixel Madness", 0
description:
    .db "Pixel Madness Ben Ryves", 0

; ==================================================================================================
; Variables
; ==================================================================================================
saveSScreen:
    .fill 768
appBackupScreen:
    .fill 768

.equ plasmaMem appBackupScreen
.equ plasma_Y plasmaMem + 0
.equ plasma_Scroll plasmaMem + 1
.equ plasma_X plasmaMem + 2
.equ textX plasmaMem + 3
.equ textY plasmaMem + 4
.equ plasmaBuffer plasmaMem + 50

.equ introMem appBackupScreen
.equ introTextPosY introMem + 0
.equ introTextPosX introMem + 1
.equ demoLoop introMem + 2
.equ whichText introMem + 3 ; word
.equ intro_Screen introMem + 5

.equ textSwapDelay 150

; ==================================================================================================
; Start demo!
; ==================================================================================================

#include "workaround.asm"

Init_All:
    ld a, textSwapDelay
    kld((demoLoop), a)

    kld(hl, intro_Screens)
    kld((whichText), hl)
    kld(de, intro_Screen)
    ld bc, 14
    ldir
    
    pcall(allocScreenBuffer)
    pcall(getLcdLock)
    pcall(getKeypadLock)
    pcall(flushKeys)
    
    kld(de, corelibPath)
    pcall(loadLibrary)
    
Intro_Text_Loop:
    pcall(clearBuffer)
    ld hl, 19 + (256 * 6)
    kld((introTextPosY), hl)
    kld(bc, intro_Screen)
Draw_Pixel_Loop:
    ld a, (bc)
    cp ' '
    jr z, Skip_Pixel_Char
    or a
    jr z, Draw_Madness
    kcall(Mul_32)
    
    kld(de, Big_Letters - ('a' * 32))
    add hl, de
    
    kld(de, (introTextPosY))
    push bc
        ld b, 16
        pcall(putSprite16OR)
    pop bc
Skip_Pixel_Char:
    kld(a, (introTextPosX))
    add a, 17
    kld((introTextPosX), a)
    inc bc
    jr Draw_Pixel_Loop
Draw_Madness:
    ld hl, 38 + (256 * 5)
    kld((introTextPosY), hl)
Draw_Madness_Loop:
    inc bc
    ld a, (bc)
    cp ' '
    jr z, Skip_Madness_Char
    or a
    jr z, Drawn_Madness
    kcall(Mul_14)
    kld(de, Small_Letters - ('a' * 14))
    add hl, de
    
    push bc
        ld b, 7
        kld(de, (introTextPosY))
        pcall(putSpriteOR)
    pop bc
    
Skip_Madness_Char:
    kld(a, (introTextPosX))
    add a, 13
    kld((introTextPosX), a)
    jr Draw_Madness_Loop
    
Drawn_Madness:
    pcall(fastCopy)
    corelib(appGetKey)
    jr nz, Drawn_Madness
    or a
    jr nz, Start_Demos

    ld b, 14
    kcall(ionRandom)
    push af
        ld l, a
        ld h, 0
        kld(de, intro_Screen)
        add hl, de
    pop af \ push hl
        ld l, a
        ld h, 0
        kld(de, (whichText))
        add hl, de
    pop de
    ld a, (hl)
    ld (de), a
    
    kld(a, (demoLoop))
    dec a
    jr nz, Not_Time_Swap_Text

    kld(hl, (whichText))
    ld de, 14
    add hl, de

    ld a, (hl)
    or a
    jr nz, No_Need_Loop_IntoTexts
    kld(hl, intro_Screens)
No_Need_Loop_IntoTexts:
    kld((whichText), hl)
    ld a, textSwapDelay
Not_Time_Swap_Text:
    kld((demoLoop), a)
    
    kjp(Intro_Text_Loop)


; ==================================================================================================
; Roll the demos
; ==================================================================================================


Start_Demos:
    pcall(flushKeys)
    kld(hl, text_Field)
    kcall(Display_Text_Screen)
    pcall(flushKeys)
    kcall(Effect_Field)
    
    pcall(flushKeys)
    kld(hl, text_Flag)
    kcall(Display_Text_Screen)
    pcall(flushKeys)
    kcall(Effect_Flag)
    
    pcall(flushKeys)
    kld(hl, text_Globe)
    kcall(Display_Text_Screen)
    pcall(flushKeys)
    kcall(Effect_Globe)

    ; ld hl,48*32*2
    ; bcall(_enoughmem)
    ; jr nc,Can_Run_Tunnel
    ; ld hl,text_Low_RAM
    ; call Display_Text_Screen
    ; jr Done_Tunnel
; Can_Run_Tunnel:
    ; ld hl,text_Tunnel
    ; call Display_Text_Screen
    ; call Effect_Tunnel
; Done_Tunnel:


    ; ld hl,text_Water
    ; call Display_Text_Screen
    ; call Effect_Water

    ; ld hl,text_Plasma
    ; call Display_Text_Screen
    ; ld hl,text_ShowPlasma
    ; call Display_Text_Screen
    ; ld hl,text_SeenPlasma
    ; call Display_Text_Screen

    ret

Text_To_Display:



; ==================================================================================================
; Modules
; ==================================================================================================


; TUNNEL EFFECT
; #include "tunnel.asm"


; WATER EFFECT
; #include "water.asm"



; 3D GLOBE EFFECT
#include "globe.asm"
; #include "linedraw.asm"


; FLAG EFFECT
#include "flag.asm"


; CHECKERBOARD FIELD EFFECT
#include "field.asm"



; ==================================================================================================
; Low RAM warning
; ==================================================================================================

text_Low_RAM:
    .db "warning|||"
    .db "you do not"
    .db "   have   "
    .db "enough ram"
    .db "to run the"
    .db " tunnel|", 0

; ==================================================================================================
; Global include files
; ==================================================================================================

; #include "ripple.asm"
#include "shifts.asm"
#include "general.asm"

; ==================================================================================================
; Intro screen stuff
; ==================================================================================================


intro_Screens:
    .db "pixel", 0 \ .db "madness", 0
    .db "funky", 0 \    .db "program", 0
    .db "super", 0 \ .db "d e m o", 0
    .db "great", 0 \ .db "codings", 0
    .db "weird", 0 \ .db "effects", 0
    .db "neato", 0 \ .db "graphix", 0
    .db "press", 0 \ .db "any key", 0
    .db " ||| ", 0 \ .db "go away", 0
    .db "hurry", 0 \ .db "come on", 0
    .db "i  am", 0 \ .db "waiting", 0
    .db "cheap", 0 \ .db " plug{ ", 0
    .db "visit", 0 \ .db "website", 0
    .db "still", 0 \ .db "why not", 0
    .db "sigh{", 0 \ .db "give up", 0
    .db "{why{", 0 \ .db "are you", 0
    .db "still", 0 \ .db "here|||", 0
    .db "there", 0 \ .db "is more", 0
    .db "later", 0 \ .db "in this", 0
    .db "demo{", 0 \ .db "and you", 0
    .db " are ", 0 \ .db "wasting", 0
    .db "your ", 0 \ .db "   time", 0
    .db "ok|||", 0 \ .db "you win", 0
    .db "it is", 0 \ .db "time to", 0
    .db "loop|", 0 \ .db "byeeeee", 0
    .db 0


; ==================================================================================================
; Display_Text_Screen: Call to display a text screen (text screen location in [hl].
; ==================================================================================================

Display_Text_Screen:
    kld((Text_Offset + 1), hl)
Plasma_Text_Loop:
    ; Render background
    pcall(clearBuffer)
    ; ld ix, PlotsScreen
    push iy \ pop ix
    ld a, 32
    kld((Plasma_Done_Count + 1), a)
Draw_Next_Plasma_ScanLine:
    ; Calculate the Y value
    
    kld(a, (Plasma_Done_Count + 1))
    ld b, a
    kld(a, (plasma_Scroll))
    add a, b
    srl a
    kcall(getSin)
    ld c, a
    
    kld(a, (Plasma_Done_Count + 1))
    add a, a
    ld b, a
    kld(a, (plasma_Scroll))
    add a, b
    kcall(getSin)
    add a, c
    ld c, a

    kld(a, (Plasma_Done_Count + 1))
    add a, a
    add a, a
    ld b, a
    kld(a, (plasma_Scroll))
    srl a
    srl a
    add a, b
    kcall(getSin)
    add a, c
    kld((Plasma_Y), a)


    ld a, 48
    kld((plasma_X), a)
    
    ld b, 12
    ld c, 0b11000000
Calculate_Next_Plasma:


    ; Decide what colour to draw the pixels
    ; Calculate X value
    push bc
    
        kld(a, (Plasma_X))
        ld b, a
        kld(a, (plasma_Scroll))
        srl a
        add a, b
        kcall(getSin)
        ld c, a
        kld(a, (Plasma_X))
        add a, a
        add a, a
        ld b, a
        kld(a, (plasma_Scroll))
        add a, b
        kcall(getSin)
        add a, c
        ld b, a
        kld(a, (Plasma_Y))
        add a, b
    
    pop bc
    
    cp 140
    jr nc, Draw_In_White
    cp 120
    jr nc, Draw_In_Grey_White
    cp 100
    jr nc, Draw_Plasma_Grey
    cp 80
    jr nc, Draw_In_Grey_Black
    ; Draw wall
    ld d, c
    
    ld a, (ix)
    or c
    ld (ix), a
    ld a, (ix + 12)
    or c
    ld (ix + 12), a
    jr Draw_In_White
Draw_Plasma_Grey:
    ld a, c
Grey_Plasma:
    and 0b10101010
    or (ix)
    ld (ix), a
    ld a, c
    and 0b01010101
    or (ix + 12)
    ld (ix + 12), a
    jr Draw_In_White


Draw_In_Grey_White:
    ld a, c
    and 0b10101010
    or (ix)
    ld (ix), a
    jr Draw_In_White


Draw_In_Grey_Black:
    ld a, c
    or (ix)
    ld (ix), a

    ld a, c
    and 0b01010101
    or (ix + 12)
    ld (ix + 12), a

    jr Draw_In_White    


Draw_In_White:
    ; Done
    srl c
    srl c
    kld(hl, plasma_X)
    dec (hl)
    jr nc, Not_Looped_Plasma_Bitmask
    ld c, 0b11000000
    inc ix
    dec b
    ld a, b
    or a
    jr z, Done_Plasma_Line
Not_Looped_Plasma_Bitmask:
    kjp(Calculate_Next_Plasma)
Done_Plasma_Line:
    ld de, 12
    add ix, de


Plasma_Done_Count:
    ld a, 0
    dec a
    kld((Plasma_Done_Count + 1), a)
    or a
    kjp(nz, Draw_Next_Plasma_ScanLine)
    kld(a, (plasma_Scroll))
    add a, 5
    kld((plasma_Scroll), a)
    kld(a, (Grey_Plasma + 1))
    xor 0xff
    kld((Grey_Plasma + 1), a)
    ;Draw in text
    ld hl, 1 + (256 * 8)
    kld((textX), hl)
Text_Offset:
    ld bc, 0

Draw_Next_Letter_Loop:
    ld a, (bc)
    or a
    jr z, Done_All_Text_Tiled
    cp ' '
    jr z, Skip_Draw_Letter
    kcall(Mul_14)
    kld(de, Small_Letters - ('a' * 14))
    add hl, de
    push hl \ pop ix
    kld(a, (textY))
    ld l, a
    kld(a, (textX))
    push bc
        ld b, 7
        kcall(drawMaskedAlignedSprite)
    pop bc
Skip_Draw_Letter:
    kld(a, (textX))
    inc a
    cp 11
    jr nz, Not_Next_Row_Text
    kld(a, (textY))
    add a, 8
    kld((textY), a)
    ld a, 1
Not_Next_Row_Text:
    kld((textX), a)
    inc bc
    jr Draw_Next_Letter_Loop
Done_All_Text_Tiled:
    pcall(fastCopy)
    corelib(appGetKey)
    jr nz, Done_All_Text_Tiled
    or a
    ret nz
    kjp(Plasma_Text_Loop)

drawMaskedAlignedSprite:
    ld h, 0
    add hl, hl
    add hl, hl
    ld d, h
    ld e, l
    add hl, hl
    add hl, de
    ; ld de, PlotsScreen
    push iy \ pop de
    add hl, de
    ld e, a
    ld d, 0
    add hl, de
    ld de, 12
Copy_Sprite_Loop:
    ld a, (ix + 7)
    xor 0xff
    and (hl)
    ld (hl), a
    ld a, (ix)
    or (hl)
    ld (hl), a
    add hl, de
    inc ix
    djnz Copy_Sprite_Loop
    ret

getSin:
    ld d, 0
    ld e, a
    kld(hl, Plasma_LUT)
    add hl, de
    ld a, (hl)
    ret


#include "letters.asm"

Plasma_LUT:
.db 20
.db 22
.db 24
.db 26
.db 28
.db 30
.db 31
.db 33
.db 34
.db 36
.db 37
.db 38
.db 39
.db 39
.db 40
.db 40
.db 40
.db 40
.db 40
.db 39
.db 38
.db 37
.db 36
.db 35
.db 34
.db 32
.db 31
.db 29
.db 27
.db 25
.db 23
.db 21
.db 19
.db 17
.db 15
.db 13
.db 12
.db 10
.db 8
.db 7
.db 5
.db 4
.db 3
.db 2
.db 1
.db 1
.db 0
.db 0
.db 0
.db 0
.db 1
.db 1
.db 2
.db 3
.db 4
.db 5
.db 7
.db 8
.db 10
.db 12
.db 14
.db 16
.db 17
.db 19
.db 21
.db 23
.db 25
.db 27
.db 29
.db 31
.db 32
.db 34
.db 35
.db 36
.db 37
.db 38
.db 39
.db 40
.db 40
.db 40
.db 40
.db 40
.db 39
.db 39
.db 38
.db 37
.db 35
.db 34
.db 33
.db 31
.db 29
.db 28
.db 26
.db 24
.db 22
.db 20
.db 18
.db 16
.db 14
.db 12
.db 10
.db 9
.db 7
.db 6
.db 4
.db 3
.db 2
.db 1
.db 1
.db 0
.db 0
.db 0
.db 0
.db 1
.db 1
.db 2
.db 3
.db 4
.db 5
.db 6
.db 8
.db 10
.db 11
.db 13
.db 15
.db 17
.db 19
.db 21
.db 23
.db 25
.db 27
.db 29
.db 30
.db 32
.db 33
.db 35
.db 36
.db 37
.db 38
.db 39
.db 39
.db 40
.db 40
.db 40
.db 40
.db 39
.db 39
.db 38
.db 37
.db 36
.db 35
.db 33
.db 32
.db 30
.db 28
.db 26
.db 24
.db 22
.db 20
.db 18
.db 16
.db 15
.db 13
.db 11
.db 9
.db 8
.db 6
.db 5
.db 3
.db 2
.db 2
.db 1
.db 0
.db 0
.db 0
.db 0
.db 0
.db 1
.db 2
.db 2
.db 3
.db 5
.db 6
.db 7
.db 9
.db 11
.db 13
.db 14
.db 16
.db 18
.db 20
.db 22
.db 24
.db 26
.db 28
.db 30
.db 31
.db 33
.db 34
.db 36
.db 37
.db 38
.db 39
.db 39
.db 40
.db 40
.db 40
.db 40
.db 39
.db 39
.db 38
.db 37
.db 36
.db 35
.db 34
.db 32
.db 30
.db 29
.db 27
.db 25
.db 23
.db 21
.db 19
.db 17
.db 15
.db 13
.db 11
.db 10
.db 8
.db 6
.db 5
.db 4
.db 3
.db 2
.db 1
.db 1
.db 0
.db 0
.db 0
.db 0
.db 1
.db 1
.db 2
.db 3
.db 4
.db 6
.db 7
.db 9
.db 10
.db 12
.db 14
.db 16
.db 18
.db 20
.db 22
.db 24

#include "trig.asm"
#include "tnllut.asm"
#include "images.asm"

corelibPath:
    .db "/lib/core", 0

text_Field:
    .db "chessboard"
    .db "landscapes"
    .db " { you can"
    .db "never have"
    .db "enough  of"
    .db "them|||", 0
text_Tunnel:
    .db "spiro{    "
    .db "   {tunnel"
    .db " press }~ "
    .db "and  arrow"
    .db " keys  to "
    .db "control it", 0
text_Water:
    .db " rippling "
    .db "water{ hit"
    .db "  }~  to  "
    .db "pause  the"
    .db "scrolling "
    .db "  text|", 0
text_Globe:
    .db " spinning "
    .db "three{ dee"
    .db "globe| hit"
    .db "}~ to swap"
    .db " backface "
    .db "  modes|", 0
text_Flag:
    .db "wavy flag{"
    .db "and a very"
    .db " annoying "
    .db "message to"
    .db "read|||", 0
text_Plasma:
    .db " did  you "
    .db "notice the"
    .db "plasma  on"
    .db "these text"
    .db "screens|||"
    .db " press }~", 0
text_ShowPlasma:
    .db " ", 0
text_SeenPlasma:
    .db "i hope you"
    .db " enjoyed  "
    .db "the  demos"
    .db "here|press"
    .db "}~ to quit"
    .db "from here|", 0