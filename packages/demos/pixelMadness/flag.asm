; ==================================================================================================
; Variables
; ==================================================================================================

.equ flagMem AppBackupScreen

.equ column flagMem
.equ steps flagMem + 1
.equ shift_byte flagMem + 2 ; word
.equ start_word flagMem + 4 ; word
.equ copy_word flagMem + 6 ; word
.equ scale_val_f flagMem + 8
.equ scale_inc flagMem + 9
.equ text_pos flagMem + 10 ; word
.equ text_Inc_Count flagMem + 12

.equ textDelay 100

#define textScrollFlag

Effect_Flag:

    ; set textWrite,(iy+sGrFlags)
    ; TODO : see what that does
    ; it probably makes it so that _vputmap displays things on plotSScreen instead of the screen
    ; which KOS's drawChar does on its own anyway
    xor a
    kld((scale_val_f), a)
    ld a, 1
    kld((scale_inc), a)
    kld(hl, Flag_Text)
    kld((text_pos), hl)
    
    ld hl, 0
    kld((text_Inc_Count), hl)
Flag_Loop:
    pcall(clearBuffer)
    kld(hl, (text_pos))
    ld a, (hl)
    ld de, 0x0500
    ; bcall(_vputmap) was here
    pcall(drawChar)
    
    kld(bc, saveSScreen)
    ld a, 5
    ; ld ix, PlotsScreen + 12
    push iy \ pop ix
    ld de, 12
    add ix, de
Not_Hit_Bottom_Char_Yet:
    push af
        ld l, (ix)
        ld a, l
        add a, a
        add a, l
        ld l, a
        ld h, 0
        kld(de, Text_Expander)
        add hl, de
        
        ld a, 8
Scale_Vert_Char:
        push hl
            ld d, b
            ld e, c
            push bc
                ld bc, 3
                ldir
            pop hl
            ld de, 3
            add hl, de
            ld b, h
            ld c, l
        pop hl
        dec a
        or a
        jr nz, Scale_Vert_Char
        push bc
            ld bc, 12
            add ix, bc
        pop bc
    pop af
    dec a
    or a
    jr nz, Not_Hit_Bottom_Char_Yet
    
    ; needed ?
    ; di
    kld(hl, Flag)
    ; ld de, PlotsScreen
    push iy \ pop de
    ld bc, 768
    kcall(RLE)
    
#ifdef textScrollFlag
    kld(ix, saveSScreen)
    ld h, 32
    ld l, 12
    push hl
        dec h
        dec h
        dec l
        dec l
        push hl
            ld a, h
            add a, 4
            ld h, a
            push hl
                ld a, l
                add a, 4
                ld l, a
                push hl
                    ld a, h
                    sub 4
                    ld h, a
                    kld(ix, saveSScreen)
                    ld bc, ((8 * 5) * 256) + 3
                    kcall(largeORSprite)
                pop hl
                ld a, h
                kld(ix, saveSScreen)
                ld bc, ((8 * 5) * 256) + 3
                kcall(largeORSprite)
            pop hl
            ld a, h
            kld(ix, saveSScreen)
            ld bc, ((8 * 5) * 256) + 3
            kcall(largeORSprite)
        pop hl
        ld a, h
        kld(ix, saveSScreen)
        ld bc, ((8 * 5) * 256) + 3
        kcall(largeORSprite)
    pop hl
    ld a, h
    kld(ix, saveSScreen)
    ld bc, ((8 * 5) * 256) + 3
    ; TODO : work around that
    ; call ionLargeSprite
    kcall(largeORSprite)
#endif
    
    kcall(Inc_Text_Counter)
    kcall(Inc_Text_Counter)
    kcall(Inc_Text_Counter)
    kcall(Inc_Text_Counter)
    kcall(Inc_Text_Counter)
    
    ld a, 11
    kld((column), a)

    kld(hl, Flag_Wave)
Vertical_Shift_Loop:
    push hl
        ld a, (hl)
        or a
        jr z, Shifted_Vertical_Flag
        and 0b10000000
        jr nz, Is_Shift_Up
        ld a, (hl)
        kcall(scale_Shift)
        kld(a, (column))
        kcall(Shift_Column_Down)
        jr Shifted_Vertical_Flag
Is_Shift_Up:
        ld a, (hl)
        and 0b01111111
        kcall(scale_Shift)
        kld(a, (column))
        kcall(Shift_Column_Up)
Shifted_Vertical_Flag:
    pop hl
    inc hl
    kld(a, (column))
    dec a
    kld((column), a)
    cp -1
    jr nz, Vertical_Shift_Loop
    
    ld a, 7
    kld((column), a)
    kld(hl, Flag_Wave)
Horizontal_Shift_Loop:
    push hl
        ld a, (hl)
        or a
        jr z, Shifted_Horizontal_Flag
        and 0b10000000
        jr nz, Is_Row_Up
        ld a, (hl)
        kcall(scale_Shift)
        kld(a, (column))
        kcall(Shift_Row_Down)
        jr Shifted_Horizontal_Flag
Is_Row_Up:
        ld a, (hl)
        and 0b01111111
        kcall(scale_Shift)
        kld(a, (column))
        kcall(Shift_Row_Up)
Shifted_Horizontal_Flag:
    pop hl
    inc hl
    kld(a, (column))
    dec a
    kld((column), a)
    cp -1
    jr nz, Horizontal_Shift_Loop
    
    pcall(fastCopy)
    
    ;SCROLL THE WAVE TABLE
    kld(a, (Flag_Wave))
    kld(hl, Flag_Wave + 1)
    kld(de, Flag_Wave)
    ld bc, (Flag_Wave_End - Flag_Wave) - 1
    ldir
    kld((Flag_Wave_End - 1), a)
    
    ;CHANGE THE SCALING OF THE FLAG WAVE
    
    kld(a, (scale_val_f))
    ld b, a
    kld(a, (scale_inc))
    add a, b
    kld((scale_val_f), a)
    or a
    jr nz, No_Toggle_Inc_Flag
    kld(a, (scale_inc))
    neg
    kld((scale_inc), a)
    ld b, a
    kld(a, (scale_val_f))
    add a, b
    kld((scale_val_f), a)
No_Toggle_Inc_Flag:
    
    kld(a, (text_Inc_Count))
    cp textDelay
    jr c, Not_Time_Advance_Text
    xor a
    kld((text_Inc_Count), a)
    
    kld(hl, (text_pos))
    inc hl
    ld a, (hl)
    or a
    jr nz, Not_End_Of_Text
    kld(hl, Flag_Text)
Not_End_Of_Text:
    kld((text_pos), hl)
Not_Time_Advance_Text:
    corelib(appGetKey)
    jr nz, Not_Time_Advance_Text
    cp kClear
    ret z
    kjp(Flag_Loop)
    ret
    
Shift_Column_Up:
    ld a, c
    or a
    ret z
    ld hl, 12
    kld((shift_byte), hl)
    ; ld hl, PlotsScreen
    push iy \ pop hl
    kcall(get_Start_Locations)
    kld((start_word), hl)
    kld((copy_word), de)
    jr Shift_Column
Shift_Column_Down:
    ld a, c
    or a
    ret z
    ld hl, -12
    kld((shift_byte), hl)
    ;ld hl,PlotsScreen+(768-12)
    push iy \ pop hl
    ld de, 768 - 12
    add hl, de
    kcall(get_Start_Locations)
    kld((start_word), de)
    kld((copy_word), hl)
Shift_Column:
    ld b, 63
    kld(hl, (start_word))
    kld(de, (copy_word))
Shift_Column_Loop:
    ld a, (hl)
    ld (de), a
    push hl
        kld(hl, (shift_byte))
        add hl, de
        ld d, h
        ld e, l
    pop hl
    push de
        kld(de, (shift_byte))
        add hl, de
    pop de
    djnz Shift_Column_Loop
    kcall(Inc_Text_Counter)
    dec c
    ld a, c
    or a
    jr nz, Shift_Column
    ret
get_Start_Locations:
    kld(de, (column))
    ld d, 0
    add hl, de
    push hl
        ld de, 12
        add hl, de
    pop de
    ret
    
scale_Shift:
    push hl \ push de
        ld d, 0
        ld e, a
        
        kld(a, (scale_val_f))
        or a
        jr z, Done_Scale_Flag
        ld b, a
        ld d, 0
        ld hl, 0
Scale_Flag_Loop:
        add hl, de
        djnz Scale_Flag_Loop
        ld c, h
Done_Scale_Flag:
    pop de \ pop hl
    ret


Shift_Row_Up:
    ld a, c
    or a
    ret z
    kcall(get_Row_Offset)
    ld b, 8
Shift_Row_Up_Loop:
    xor a
    rr (hl) \ inc hl
    rr (hl) \ inc hl
    rr (hl) \ inc hl
    rr (hl) \ inc hl
    rr (hl) \ inc hl
    rr (hl) \ inc hl
    rr (hl) \ inc hl
    rr (hl) \ inc hl
    rr (hl) \ inc hl
    rr (hl) \ inc hl
    rr (hl) \ inc hl
    rr (hl) \ inc hl
    djnz Shift_Row_Up_Loop
    dec c
    ld a, c
    or a
    jr nz, Shift_Row_Up
    ret

Shift_Row_Down:
    ld a, c
    or a
    ret z
    kcall(get_Row_Offset)
    ld de, 95
    add hl, de
    ld b, 8
Shift_Row_Down_Loop:
    xor a
    rl (hl) \ dec hl
    rl (hl) \ dec hl
    rl (hl) \ dec hl
    rl (hl) \ dec hl
    rl (hl) \ dec hl
    rl (hl) \ dec hl
    rl (hl) \ dec hl
    rl (hl) \ dec hl
    rl (hl) \ dec hl
    rl (hl) \ dec hl
    rl (hl) \ dec hl
    rl (hl) \ dec hl
    djnz Shift_Row_Down_Loop
    dec c
    ld a, c
    or a
    jr nz, Shift_Row_Down
    ret

get_Row_Offset:
    kld(hl, (column))
    ld h, 0
    add hl, hl    ;*2
    add hl, hl    ;*4
    add hl, hl    ;*8
    add hl, hl    ;*16
    add hl, hl    ;*32
    ld d, h
    ld e, l        ;de = a*32
    add hl, hl    ;*64
    add hl, de    ;hl=a*96
    ; ld de, PlotsScreen
    push iy \ pop de
    add hl, de
    ret

Inc_Text_Counter:
    kld(a, (text_inc_count))
    inc a
    or a
    ret z
    kld((text_inc_count), a)
    ret

Text_Expander:
.db $00,$00,$00
.db $00,$00,$FF
.db $00,$FF,$00
.db $00,$FF,$FF
.db $FF,$00,$00
.db $FF,$00,$FF
.db $FF,$FF,$00
.db $FF,$FF,$FF

Flag_Wave:
.db     0
.db     2
.db     4
.db     5
.db     4
.db     3
.db     0
.db     130
.db     132
.db     133
.db     132
.db     131
Flag_Wave_End:

Flag_Text:
    ;LWR - not i, m, w, z
    .db "ONCE AGAIN I KILL YOUR EYES, "
    .db "THIS TIME WITH A FUNKY FLAG "
    .db "STYLE DEMO - "
    .db "SORRY ABOUT THE WAY YOU HAVE "
    .db "TO READ THE TEXT. YOU WILL "
    .db "GET USED TO IT! "
    .db "1-2-3- IT IS TIME TO "
    .db "LOOP. BYE! ",0
