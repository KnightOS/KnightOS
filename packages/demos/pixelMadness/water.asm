; ==================================================================================================
; Constants
; ==================================================================================================

.equ textSpacing 18
.equ cityDisplay 150

; ==================================================================================================
; Variables
; ==================================================================================================

; .equ waterMem saveSScreen+(14*32)
.equ waterMem appBackupScreen

.equ Start_Of_Line waterMem ; word
.equ Ripple_Val waterMem + 2
.equ Scale_Pointer waterMem + 3 ; word
.equ Char_Space waterMem + 5
.equ Ripple_Delay waterMem + 6
.equ Dither_Pointer waterMem + 7 ; word
.equ Dither_Count waterMem + 9
.equ Text_Pointer waterMem + 10 ; word
.equ City_Delay waterMem + 12
.equ City_Height waterMem + 13
.equ Water_Paused waterMem + 14

Start_Water_Effect:
Effect_Water:
    ld a, cityDisplay
    kld((City_Delay), a)
    ld a, 31
    kld((City_Height), a)
    
main_Loop:
    pcall(clearBuffer)
    kld(a, (City_Height))
    or a
    jr z, No_Shift_City_Up
    dec a
    kld((City_Height), a)
No_Shift_City_Up:
    ld l, a
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
    ld d, h
    ld e, l
    kld(hl, City)
    ld bc, 12 * 32
    kcall(RLE)
    
    kcall(ripple_Reflect)
    
    kld(a, (City_Delay))
    dec a
    kld((City_Delay), a)
    or a
    jr z, Start_Scrolling_Text
    
Key_Loop:
    corelib(appGetKey)
    jr nz, Key_Loop
    cp kClear
    ret z
    jr main_Loop

Start_Scrolling_Text:
    ld a, textSpacing
    kld((Char_Space), a)
    kld(hl, saveSScreen)
    kld(de, saveSScreen + 1)
    ld bc, (14 * 32) - 1
    xor a
    ld (hl), a
    ldir
    kld((Water_Paused), a)
    kld(hl, Text_String)
    kld((Text_Pointer), hl)
    kld(de, saveSScreen)
    ; ld hl, PlotsScreen
    push iy \ pop hl
    ld a, 32
Copy_City_Loop:
    ld bc, 12
    ldir
    inc de
    inc de
    dec a
    or a
    jr nz, Copy_City_Loop
    
Scrolling_Text_Loop:
    kld(hl, saveSScreen)
    ; ld de, PlotsScreen
    push iy \ pop de
    ld a, 32
Copy_Text_Loop:
    ld bc, 12
    ldir
    inc hl
    inc hl
    dec a
    or a
    jr nz, Copy_Text_Loop
    
    kcall(ripple_Reflect)
    
    kld(a, (Water_Paused))
    or a
    jr nz, Do_Not_Pause_Text
    
    ld b, 32
    kld(hl, saveSScreen + 13)
    kcall(Shift_14_Left)
    
    kld(a, (Char_Space))
    dec a
    kld((Char_Space), a)
    or a
    jr nz, Not_Time_To_Add_Char
    ld a, textSpacing
    kld((Char_Space), a)
    kcall(Add_Char)
Not_Time_To_Add_Char:
    
Do_Not_Pause_Text:
    corelib(appGetKey)
    jr nz, Do_Not_Pause_Text
    cp kClear
    ret z
    cp k2nd
    jr nz, Scrolling_Text_Loop
    kld(a, (Water_Paused))
    xor 1
    kld((Water_Paused), a)
    jr Scrolling_Text_Loop
    
Add_Char:
        kld(hl, (Text_Pointer))
        ld a, (hl)
        inc hl
        kld((Text_Pointer), hl)
        cp ' '
        ret z
        or a
        jr nz, Not_End_Text_List
        ; throw the RET address away
    pop hl
    kjp(Start_Water_Effect)

Not_End_Text_List:
    kcall(Mul_32)
    kld(de, Big_Letters - ('a' * 32))
    add hl, de
    push hl
        ld b, 16
        kcall(ionRandom)
        add a, a
        ld b, a
        add a, a
        ld c, a
        add a, a
        add a, b
        add a, c
        ld l, a
        ld h, 0
        kld(de, saveSScreen + 12)
        add hl, de
        ld d, h
        ld e, l
    pop hl
    ld b, 16
Add_Char_Loop:
    ld a, (hl)
    ld (de), a
    inc hl
    inc de
    ld a, (hl)
    ld (de), a
    inc hl
    push hl
        ld hl, 13
        add hl, de
        ld d, h
        ld e, l
    pop hl
    djnz Add_Char_Loop
    ret

Text_String:
    .db "water scroller { "
    .db "ben ryves { "
    .db "for greenfire| "
    .db "the quick brown fox "
    .db "jumps over the lazy dog { "
    .db "it had to be said|      ",0


