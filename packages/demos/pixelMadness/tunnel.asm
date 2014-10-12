; ==================================================================================================
; Variables
; ==================================================================================================


.equ tunnelMem appBackupScreen
#define tunnelPixelDouble            ;When enabled, use pixel doubling (uses diff. LUT).


#ifdef tunnelPixelDouble
.equ startMask 0b11000000
.equ numLines 32
#else
.equ startMask 0b10000000
.equ numLines 64
#endif

.equ rot_Tunnel tunnelMem
.equ trav_Tunnel tunnelMem + 1
.equ LUTX tunnelMem + 2
.equ LUTY tunnelMem + 3
.equ expandType tunnelMem + 4
.equ LUT_Loc tunnelMem + 5 ; word


; ==================================================================================================
; Start; create LUT in RAM and 'explode' precalculated tables into memory.
; ==================================================================================================

Effect_Tunnel:
    kld(hl, Angle_LUT)
    kld(de, (LUT_Loc))
    ld a, 1
    kcall(Expand_LUT)

    kld(hl, (LUT_Loc))
    ld de, 48 * 32
    add hl, de
    ld d, h
    ld e, l
    kld(hl, Dist_LUT)
    xor a
    kcall(Expand_LUT)
    
    xor a
    kld((rot_Tunnel), a)
    kld((trav_Tunnel), a)

; ==================================================================================================
; Render tunnel, kinda thing.
; ==================================================================================================

Tunnel_Main_Loop:
    pcall(clearBuffer)
    kld(hl, (LUT_Loc))
    ; ld de, PlotsScreen
    push iy \ pop de
    ld a, numLines
    kld((Lines_Done_Count + 1), a)
Draw_Next_ScanLine:
    ld b, 12
    ld c, startMask
Scan_Next_Wall:
    push bc \ push de
        ld a, (hl)
        ld b, a
        kld(a, (rot_Tunnel))
        add a, b
        srl a
        srl a
        srl a
        ld b, a
        push hl
            ld de, 48 * 32
            add hl, de
            kld(a, (trav_Tunnel))
            add a, (hl)
            srl a
            srl a
            srl a
            add a, b
        pop hl
    pop de \ pop bc
Wall_Mask:
    and 0b0000011
    jr z, Draw_In_Grey
Wall_Mask_2:
    and 0b0000001
    jr z, Skip_Drawing_Tunnel_Wall
    
Fill_Black:
    ld a, (de)
    or c
    ld (de), a
    jr Skip_Drawing_Tunnel_Wall

Draw_In_Grey:
    push bc
        ld a, c
        and 0b10101010
        ld c, a
        ld a, (de)
        or c
        ld (de), a
    pop bc
    push de \ pop ix
    ld a, (ix + 12)
    or c
    ld (ix + 12), a
Skip_Drawing_Tunnel_Wall:
    inc hl
    srl c
    srl c
    jr nc, Not_Looped_Pixel_Bitmask
    ld c, startMask
    inc de
    dec b
    ld a, b
    or a
    jr z, Done_Line
Not_Looped_Pixel_Bitmask:
    jr Scan_Next_Wall
Done_Line:
    
#ifdef tunnelPixelDouble
    push hl
        ld hl, -12
        add hl, de
        ex de, hl
        ld bc, 12
Double_Row_Height:
        ld a, (de)
        xor (hl)
        ld (hl), a
        inc hl
        inc de
        dec bc
        ld a, b
        or c
        jr nz, Double_Row_Height
        ex de,hl
    pop hl
#endif
    
Lines_Done_Count:
    ld a, 0
    dec a
    kld((Lines_Done_Count + 1), a)
    or a
    jr nz, Draw_Next_ScanLine
    
; ==================================================================================================
; Done rendering, copy to display and handle keys.
; ==================================================================================================
    pcall(fastCopy)
    
    kld(ix, rot_Tunnel)
    ; ld a, KeyRow_Pad
    ld a, 0xfd
    out (1), a
    in a, (1)
    
    cp 255
    jr z, No_Key_Pressed
    
    bit 0, a
    jr nz, Not_Tunnel_Down
    dec (ix + 1)
Not_Tunnel_Down:
    bit 1, a
    jr nz, Not_Tunnel_Left
    dec (ix)
Not_Tunnel_Left:
    bit 2, a
    jr nz, Not_Tunnel_Right
    inc (ix)
Not_Tunnel_Right:
    bit 3, a
    jr nz, Not_Tunnel_Up
    inc (ix + 1)
Not_Tunnel_Up:
    jr Parsed_Key_Presses
No_Key_Pressed:
    inc (ix)
    inc (ix + 1)
Parsed_Key_Presses:
    corelib(appGetKey)
    jr nz, Parsed_Key_Presses
    cp kClear
    jr z, Close_Tunnel
    
    cp k2nd
    kjp(nz, Tunnel_Main_Loop)
    
    ld b, 16
    kcall(ionRandom)
    kld((Wall_Mask+1), a)
    ld b, 16
    kcall(ionRandom)
    kld((Wall_Mask_2 + 1), a)
    kjp(Tunnel_Main_Loop)

; ==================================================================================================
; Jump here (don't just RET) to delete LUT from RAM.
; ==================================================================================================

Close_Tunnel:
    kld(ix, (LUT_Loc))
    pcall(free)
    ret

; ==================================================================================================
; Expand_LUT: in [hl] table to explode, [de] location to explode to, [a=0/1] whether to flip angles.
; ==================================================================================================

Expand_LUT:
    ld bc, 16
    kld((expandType), a)
    kld((Write_LUT_1 + 1), de)
    kld((Write_LUT_2 + 1), de)
    push hl
        ld hl, 47
        add hl, de
        kld((Write_LUT_3 + 1), hl)
        ld de, (48 * 31) - 47
        add hl, de
        kld((Write_LUT_4 + 1), hl)
    pop hl
    kld(de, (Write_LUT_1 + 1))
Expand_A_LUT:
    push bc
        ld bc, 24
        ldir
        push hl
            ex de, hl
            ld de, 24
            add hl, de
            ex de, hl
        pop hl
    pop bc
    dec bc
    ld a, b
    or c
    jr nz, Expand_A_LUT
Write_LUT_1:
    ld hl, 0
Write_LUT_3:
    ld de, 0
    ld c, 16
Flip_TL_TR_Line:
    ld b, 24
Flip_TL_TR:
    kld(a, (expandType))
    or a
    jr z, Is_Unflipped_A
    ld a, 128
    sub (hl)
    jr Write_A_LUT
Is_Unflipped_A:
    ld a, (hl)
Write_A_LUT:
    ld (de), a
    inc hl
    dec de
    djnz Flip_TL_TR
    push de
        ld de, 24
        add hl,de
    pop de
    push hl
        ld hl, 48 + 24
        add hl, de
        ld d, h
        ld e, l
    pop hl
    dec c
    ld a, c
    or a
    jr nz, Flip_TL_TR_Line
Write_LUT_2:
    ld hl, 0
Write_LUT_4:
    ld de, 0
    ld c, 16
Flip_T_B_Line:
    ld b, 48
Flip_T_B:
    kld(a, (expandType))
    or a
    jr z, Is_Unflipped_B
    ld a, 64
    sub (hl)
    jr Write_B_LUT
Is_Unflipped_B:
    ld a, (hl)
Write_B_LUT:
    ld (de), a
    inc hl
    inc de
    djnz Flip_T_B
    push hl
        ld hl, -96
        add hl, de
        ld d, h
        ld e, l
    pop hl
    dec c
    ld a, c
    or a
    jr nz, Flip_T_B_Line
    ret
