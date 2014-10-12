Effect_Globe:
    ld hl, 0
    kld((xRot), hl)
Globe_Loop:
    pcall(clearBuffer)
    kld(a, (Mask_Type))
    or a
    jr z, Skip_Backface_Clear
    kld(hl, saveSScreen)
    kld(de, saveSScreen + 1)
    ld (hl), 0
    ld bc, 767
    ldir
Skip_Backface_Clear:
    kld(ix, model)
    kcall(getPoints)
    kld(ix, model)
Draw_Next_Line:
    kld(hl, (yPos))
    kld((lastPos), hl)
    
    kcall(getPoints)
    
    ; ld hl, PlotsScreen
    push iy \ pop hl
    
    kld(a, (Mask_Type))
    cp 3
    jr z, No_Set_Backface
    
    kld(a, (isBackface))
    or a
    jr z, No_Set_Backface
    kld(a, (Mask_Type))
    or a
    jr z, Skip_Drawing_No_Backface
    kld(hl, saveSScreen)
No_Set_Backface:
    kld(hl, (yPos))
    kld(de, (lastPos))
    pcall(drawLine)
    
Skip_Drawing_No_Backface:
    ld a, (ix)
    cp -1
    jr z, Done_All_Lines
    cp -2
    jr nz, Draw_Next_Line
    
    inc ix
    kcall(getPoints)
    jr Draw_Next_Line
    
Done_All_Lines:
    ; ld hl, PlotsScreen
    push iy \ pop hl
    kld(de, saveSScreen)
    
    ld c, 64
    kld(a, (Mask_Type))
    or a
    jr z, No_Masking
    cp 1
    jr nz, Not_Mask_1a
    ld c, 32
Not_Mask_1a:
    
Dither_Back_Main_Loop:
    ld b, 12
Dither_Back_Loop:
    ld a, (de)
Mask:
    and 0b10101010
    or (hl)
    ld (hl), a
    inc hl
    inc de
    djnz Dither_Back_Loop
    
    kld(a, (Mask_Type))
    cp 1
    jr nz, Not_Mask_1b
    push de
        ld de, 12
        add hl, de
    pop de \ push hl
        ld hl, 12
        add hl, de
        ld d, h
        ld e, l
    pop hl
Not_Mask_1b:
    kld(a, (Mask_Type))
    cp 2
    jr nz, Not_Mask_2a
    
    kld(a, (Mask + 1))
    xor 0xff
    kld((Mask + 1), a)
    
Not_Mask_2a:
    dec c
    ld a, c
    jr nz, Dither_Back_Main_Loop
    
No_Masking:
    pcall(fastCopy)
    
    kld(a, (xRot))
    inc a
    kld((xRot), a)
    
Key_Loop:
    corelib(appGetKey)
    jr nz, Key_Loop
    cp kClear
    ret z
    cp k2nd
    jr nz,Not_2nd
    
    kld(a, (Mask_Type))
    inc a
    and 0b00000011
    kld((Mask_Type), a)
    kjp(Globe_Loop)

Not_2nd:
    cp kAlpha
    kjp(nz, Globe_Loop)
    
    kld(a, (Halve_LOD))
    xor 1
    kld((Halve_LOD), a)
    
    kjp(Globe_Loop)
    
getPoints:
    ld a, (ix + 1)
    kcall(getSin_Globe)
    add a, 32
    kld((yPos), a)
    
    ;RESET +/- SIGN
    xor a
    kld((negF), a)
    kld((isBackface), a)
    
    ld b, (ix)
    kld(a, (xRot))
    add a, b
    ld b, a
    add a, 64
    cp 128
    jr c, Not_Backface
    ld a, 1
    kld((isBackface), a)
    
Not_Backface:
    ld a, b
    
    kcall(getSin_Globe)
    kcall(getSign)
    push af
        ld a, (ix + 1)
        kcall(getCos_Globe)
        kcall(getSign)
        
        add a, a
        add a, a
        add a, a
        ld e, a
        ld d, 0
        ld hl, 0
    pop bc
    ld a, b
    or a
    jr z, Multiplied_Already
Multiply_Loop:
    add hl, de
    djnz Multiply_Loop
Multiplied_Already:
    ld b, h
    kld(a, (negF))
    or a
    jr z, No_Need_Neg
    ld a, b
    neg
    add a, 48
    kld((xPos), a)
    jr Calculated_X_Y
No_Need_Neg:
    ld a, b
    add a, 48
    kld((xPos), a)
Calculated_X_Y:
    inc ix
    inc ix
    
    kld(a, (Halve_LOD))
    or a
    ret z
    
    ld a, (ix)
    cp -1
    ret z
    cp -2
    ret z
    
    inc ix
    inc ix
    ret
    
getCos_Globe:
    add a, 64
getSin_Globe:
    ld l, a
    ld h, 0
    kld(de, trigTable)
    add hl,de
    ld a, (hl)
    ret
    
getSign:
    ld b, a
    rla    ;Check MSB
    jr nc, Is_Fine    ;Number is fine
    kld(a, (negF))
    xor 1
    kld((negF), a)
    ld a, b
    neg
    ret
Is_Fine:
    ld a, b
    ret
negY:
    .db 0

xRot:    .db 0

yPos:    .db 0
xPos:    .db 0

lastPos: .dw 0


negF:    .db 0

isBackface:    .db 0

Mask_Type:    .db 2

Halve_LOD:    .db 0
