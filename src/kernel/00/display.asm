; Clears an LCD buffer
; Input: IY: Buffer
clearBuffer:
    push hl
    push de
    push bc
        push iy \ pop hl
        ld (hl), 0
        ld d, h
        ld e, l
        inc de
        ld bc, 767
        ldir
    pop bc
    pop de
    pop hl
    ret

;Input: IY: Buffer
;-----> Copy the gbuf to the screen, guaranteed 
;Input: nothing
;Output:graph buffer is copied to the screen, no matter the speed settings
bufferToLCD:
bufCopy:
fastCopy:
safeCopy:
    call hasLCDLock
    ret nz
fastCopy_skipCheck:
    push hl
    push bc
    push af
    push de
    ld a, i
    push af
    di                 ;DI is only required if an interrupt will alter the lcd.
    push iy \ pop hl
    
    ld c, $10
    ld a, $80
setrow:
    in f, (c)
    jp m, setrow
    out ($10), a
    ld de, 12
    ld a, $20
col:
    in f, (c)
    jp m, col
    out ($10),a
    push af
    ld b,64
row:
    ld a, (hl)
rowwait:
    in f, (c)
    jp m, rowwait
    out ($11), a
    add hl, de
    djnz row
    pop af
    dec h
    dec h
    dec h
    inc hl
    inc a
    cp $2c
    jp nz, col
    pop af
    jp po, _
    ei
_:    
    pop de
    pop af
    pop bc
    pop hl
    ret
    
; brief : utility for pixel manipulation
; input : a -> x coord, l -> y coord, IY -> graph buffer
; output : hl -> address in graph buffer, a -> pixel mask
; destroys : b, de
getPixel:
    ld    h, 0
    ld    d, h
    ld    e, l
    
    add    hl, hl
    add    hl, de
    add    hl, hl
    add    hl, hl
    
    ld    e, a
    srl    e
    srl    e
    srl    e
    add    hl, de
    
    push iy \ pop de
    add    hl, de
    
    and    7
    ld    b, a
    ld    a, $80
    ret    z
    
    rrca
    djnz    $-1
    
    ret
    
; brief : set (darkens) a pixel in the graph buffer
; input : a -> x coord, l -> y coord
; output : none
pixelOn:
setPixel:
    push hl
    push de
    push af
    push bc
        call getPixel
        or (hl)
        ld (hl), a
    pop bc
    pop af
    pop de
    pop hl
    ret

; brief : reset (lighten) a pixel in the graph buffer
; input : a -> x coord, l -> y coord
; output : none
; destroys : a, b, de, hl
pixelOff:
resetPixel:
    push hl
    push de
    push af
    push bc
        call getPixel
        cpl
        and (hl)
        ld (hl), a
    pop bc
    pop af
    pop de
    pop hl
    ret

; brief : flip (invert) a pixel in the graph buffer
; input : a -> x coord, l -> y coord
; output : none
; destroys : a, b, de, hl
invertPixel:
pixelFlip:
pixelInvert:
flipPixel:
    push hl
    push de
    push af
    push bc
        call getPixel
        xor (hl)
        ld (hl), a
    pop bc
    pop af
    pop de
    pop hl
    ret
    
;Fast line routine, only sets pixels
;(d,e),(h,l) = (x1,y1),(x2,y2)
;IY = buffer
;NO clipping
;James Montelongo
drawLineOR:
drawLine:
    push hl
    push de
    push bc
    push af
    push ix
    push iy
        call _drawLine
    pop iy
    pop ix
    pop af
    pop bc
    pop de
    pop hl
    ret

_drawLine:
    ld a, h
    cp d
    jp nc, noswapx
    ex de, hl
noswapx:

    ld a, h
    sub d
    jp nc, posx
    neg
posx:
    ld b, a
    ld a, l
    sub e
    jp nc, posy
    neg
posY:
    ld c, a
    ld a, l
    ld hl, -12
    cp e
    jp c, lineup
    ld hl, 12
lineup:
    ld ix, xbit
    ld a, b
    cp c
    jp nc, xline
    ld b, c
    ld c, a
    ld ix, ybit
xline:
    push hl
    ld a, d
    ld d, 0
    ld h, d
    sla e
    sla e
    ld l, e
    add hl, de
    add hl, de
    ld e, a
    and %00000111
    srl e
    srl e
    srl e
    add hl, de
    push iy \ pop de
    ;ld de,gbuf
    add hl, de
    add a, a
    ld e, a
    ld d, 0
    add ix, de
    ld e, (ix)
    ld d, (ix+1)
    push hl
    pop ix
    ex de, hl
    pop de
    push hl
    ld h, b
    ld l, c
    ld a, h
    srl a
    inc b
    ret

Xbit:
 .dw drawX0, drawX1, drawX2, drawX3
 .dw drawX4, drawX5, drawX6, drawX7
Ybit:
 .dw drawY0, drawY1, drawY2, drawY3
 .dw drawY4, drawY5, drawY6, drawY7
    
drawX0:
    set 7, (ix)
    add a, c
    cp h
    jp c, $+3+2+1
    add ix, de
    sub h
    djnz drawX1
    ret
drawX1:
    set 6, (ix)
    add a, c
    cp h
    jp c, $+3+2+1
    add ix, de
    sub h
    djnz drawX2
    ret
drawX2:
    set 5, (ix)
    add a, c
    cp h
    jp c, $+3+2+1
    add ix, de
    sub h
    djnz drawX3
    ret
drawX3:
    set 4, (ix)
    add a, c
    cp h
    jp c, $+3+2+1
    add ix, de
    sub h
    djnz drawX4
    ret
drawX4:
    set 3, (ix)
    add a, c
    cp h
    jp c, $+3+2+1
    add ix, de
    sub h
    djnz drawX5
    ret
drawX5:
    set 2, (ix)
    add a, c
    cp h
    jp c, $+3+2+1
    add ix, de
    sub h
    djnz drawX6
    ret
drawX6:
    set 1, (ix)
    add a, c
    cp h
    jp c, $+3+2+1
    add ix, de
    sub h
    djnz drawX7
    ret
drawX7:
    set 0, (ix)
    inc ix
    add a, c
    cp h
    jp c, $+3+2+1
    add ix, de
    sub h
    djnz drawX0
    ret

drawY0_:
    inc ix
    sub h
    dec b
    ret z
drawY0:
    set 7, (ix)
    add ix, de
    add a, l
    cp h
    jp nc, drawY1_
    djnz drawY0
    ret
drawY1_:
    sub h
    dec b
    ret z
drawY1:
    set 6, (ix)
    add ix, de
    add a, l
    cp h
    jp nc, drawY2_
    djnz drawY1
    ret
drawY2_:
    sub h
    dec b
    ret z
DrawY2:
    set 5, (ix)
    add ix, de
    add a, l
    cp h
    jp nc, drawY3_
    djnz drawY2
    ret
drawY3_:
    sub h
    dec b
    ret z
drawY3:
    set 4, (ix)
    add ix, de
    add a, l
    cp h
    jp nc, drawY4_
    djnz drawY3
    ret
drawY4_:
    sub h
    dec b
    ret z
drawY4:
    set 3, (ix)
    add ix, de
    add a, l
    cp h
    jp nc, drawY5_
    djnz drawY4
    ret
drawY5_:
    sub h
    dec b
    ret z
drawY5:
    set 2, (ix)
    add ix, de
    add a, l
    cp h
    jp nc, drawY6_
    djnz drawY5
    ret
drawY6_:
    sub h
    dec b
    ret z
drawY6:
    set 1, (ix)
    add ix, de
    add a, l
    cp h
    jp nc, drawY7_
    djnz drawY6
    ret
drawY7_:
    sub h
    dec b
    ret z
drawY7:
    set 0, (ix)
    add ix, de
    add a, l
    cp h
    jp nc, drawY0_
    djnz drawY7
    ret

; ====SPRITE ROUTINES====

; D = xpos
; E = ypos
; B = height
; HL = image address
; IY = buffer address
putSpriteXOR:
    push af
    push bc
    push hl
    push de
    push ix
        push hl \ pop ix
        call _clipSprXOR
    pop ix
    pop de
    pop hl
    pop bc
    pop af
    ret
    
_clipSprXOR:
; Start by doing vertical clipping
    ld a, %11111111         ; Reset clipping mask
    ld (clip_mask), a
    ld a, e                 ; If ypos is negative
    or a                    ; try clipping the top
    jp m, clipTop           ;
    sub 64                  ; If ypos is >= 64
    ret nc                  ; sprite is off-screen
    neg                     ; If (64 - ypos) > height
    cp b                    ; don't need to clip
    jr nc, vertClipDone     ; 
    ld b, a                 ; Do bottom clipping by
    jr vertClipDone         ; setting height to (64 - ypos)

clipTop:
    ld a, b                 ; If ypos <= -height
    neg                     ; sprite is off-screen
    sub e                   ;
    ret nc                  ;
    push af
    add a, b                ; Get the number of clipped rows
    ld e, 0                 ; Set ypos to 0 (top of screen)
    ld b, e                 ; Advance image data pointer
    ld c, a                 ;
    add ix, bc              ;
    pop af
    neg                     ; Get the number of visible rows
    ld b, a                 ; and set as height

vertClipDone:
; Now we're doing horizontal clipping
    ld c, 0                 ; Reset correction factor
    ld a, d
    cp -7                   ; If 0 > xpos >= -7
    jr nc, clipLeft         ; clip the left side
    cp 96                   ; If xpos >= 96
    ret nc                  ; sprite is off-screen
    cp 89                   ; If 0 <= xpos < 89
    jr c, horizClipDone     ; don't need to clip

clipRight:
    and 7                   ; Determine the clipping mask
    LD C, A
    LD A, %11111111
findRightMask:
    add a, a
    dec c
    jr NZ, findRightMask
    ld (clip_mask), a
    ld a, d
    jr horizClipDone
    
clipLeft:
    AND    7                    ; Determine the clipping mask
    LD     C, A
    LD     A, %11111111
findLeftMask:
    ADD    A, A
    DEC    C
    JR     NZ, findLeftMask
    CPL
    LD     (clip_mask), A
    LD     A, D
    ADD    A, 96                ; Set xpos so sprite will "spill over"
    LD     C, 12                ; Set correction

horizClipDone:
; A = xpos
; E = ypos
; B = height
; IX = image address

; Now we can finally display the sprite.
    LD     H, 0
    LD     D, H
    LD     L, E
    ADD    HL, HL
    ADD    HL, DE
    ADD    HL, HL
    ADD    HL, HL

    LD     E, A
    SRL    E
    SRL    E
    SRL    E
    ADD    HL, DE

    push iy \ pop de ; LD     DE, PlotSScreen
    ADD    HL, DE

    LD     D, 0                 ; Correct graph buffer address
    LD     E, C                 ; if clipping the left side
    SBC    HL, DE               ;

    AND    7
    JR     Z, _aligned

    LD     C, A
    LD     DE, 11

_rowLoop:
    PUSH   BC
    LD     B, C
    LD     A, (clip_mask)       ; Mask out the part of the sprite
    AND    (IX)                 ; to be horizontally clipped
    LD     C, 0

_shiftLoop:
    SRL    A
    RR     C
    DJNZ   _shiftLoop

    XOR    (HL)
    LD     (HL), A

    INC    HL
    LD     A, C
    XOR    (HL)
    LD     (HL), A

    ADD    HL, DE
    INC    IX
    POP    BC
    DJNZ   _rowLoop
    RET

_aligned:
    LD     DE, 12

_putLoop:
    LD     A, (IX)
    XOR    (HL)
    LD     (HL), A
    INC    IX
    ADD    HL, DE
    DJNZ   _putLoop
    RET
    
; D = xpos
; E = ypos
; B = height
; HL = image address
; IY = buffer address
PutSpriteAND:
    push af
    push bc
    push hl
    push de
    push ix
        push hl \ pop ix
        call _ClipSprAND
    pop ix
    pop de
    pop hl
    pop bc
    pop af
    ret
    
_ClipSprAND:
; Start by doing vertical clipping
    LD     A, %11111111         ; Reset clipping mask
    LD     (clip_mask), A
    LD     A, E                 ; If ypos is negative
    OR     A                    ; try clipping the top
    JP     M, ClipTop2           ;
 
    SUB    64                   ; If ypos is >= 64
    RET    NC                   ; sprite is off-screen

    NEG                         ; If (64 - ypos) > height
    CP     B                    ; don't need to clip
    JR     NC, VertClipDone2     ; 

    LD     B, A                 ; Do bottom clipping by
    JR     VertClipDone2         ; setting height to (64 - ypos)

ClipTop2:
    LD     A, B                 ; If ypos <= -height
    NEG                         ; sprite is off-screen
    SUB    E                    ;
    RET    NC                   ;

    PUSH   AF
    ADD    A, B                 ; Get the number of clipped rows
    LD     E, 0                 ; Set ypos to 0 (top of screen)
    LD     B, E                 ; Advance image data pointer
    LD     C, A                 ;
    ADD    IX, BC               ;
    POP    AF
    NEG                         ; Get the number of visible rows
    LD     B, A                 ; and set as height

VertClipDone2:
; Now we're doing horizontal clipping
    LD     C, 0                 ; Reset correction factor
    LD     A, D

    CP     -7                   ; If 0 > xpos >= -7
    JR     NC, ClipLeft2         ; clip the left side

    CP     96                   ; If xpos >= 96
    RET    NC                   ; sprite is off-screen

    CP     89                   ; If 0 <= xpos < 89
    JR     C, HorizClipDone2     ; don't need to clip

ClipRight2:
    AND    7                    ; Determine the clipping mask
    LD     C, A
    LD     A, %11111111
FindRightMask2:
    ADD    A, A
    DEC    C
    JR     NZ, FindRightMask2
    LD     (clip_mask), A
    LD     A, D
    JR     HorizClipDone2

ClipLeft2:
    AND    7                    ; Determine the clipping mask
    LD     C, A
    LD     A, %11111111
FindLeftMask2:
    ADD    A, A
    DEC    C
    JR     NZ, FindLeftMask2
    CPL
    LD     (clip_mask), A
    LD     A, D
    ADD    A, 96                ; Set xpos so sprite will "spill over"
    LD     C, 12                ; Set correction

HorizClipDone2:
; A = xpos
; E = ypos
; B = height
; IX = image address

; Now we can finally display the sprite.
    LD     H, 0
    LD     D, H
    LD     L, E
    ADD    HL, HL
    ADD    HL, DE
    ADD    HL, HL
    ADD    HL, HL

    LD     E, A
    SRL    E
    SRL    E
    SRL    E
    ADD    HL, DE

    push iy \ pop de ; LD     DE, PlotSScreen
    ADD    HL, DE

    LD     D, 0                 ; Correct graph buffer address
    LD     E, C                 ; if clipping the left side
    SBC    HL, DE               ;

    AND    7
    JR     Z, _Aligned2

    LD     C, A
    LD     DE, 11

_RowLoop2:
    PUSH   BC
    LD     B, C
    LD     A, (clip_mask)       ; Mask out the part of the sprite
    AND    (IX)                 ; to be horizontally clipped
    LD     C, 0

_ShiftLoop2:
    SRL    A
    RR     C
    DJNZ   _ShiftLoop2

    CPL
    AND    (HL)
    LD     (HL), A

    INC    HL
    LD     A, C
    CPL
    AND    (HL)
    LD     (HL), A

    ADD    HL, DE
    INC    IX
    POP    BC
    DJNZ   _RowLoop2
    RET

_Aligned2:
    LD     DE, 12

_PutLoop2:
    LD     A, (IX)
    CPL
    AND    (HL)
    LD     (HL), A
    INC    IX
    ADD    HL, DE
    DJNZ   _PutLoop2
    RET
    
; D = xpos
; E = ypos
; B = height
; IX = image address
; IY = buffer address
PutSpriteOR:
    push af
    push bc
    push hl
    push de
    push ix
        push hl \ pop ix
        call _ClipSprOR
    pop ix
    pop de
    pop hl
    pop bc
    pop af
    ret
    
_ClipSprOR:
; Start by doing vertical clipping
    LD     A, %11111111         ; Reset clipping mask
    LD     (clip_mask), A
    LD     A, E                 ; If ypos is negative
    OR     A                    ; try clipping the top
    JP     M, ClipTop3           ;
 
    SUB    64                   ; If ypos is >= 64
    RET    NC                   ; sprite is off-screen

    NEG                         ; If (64 - ypos) > height
    CP     B                    ; don't need to clip
    JR     NC, VertClipDone3     ; 

    LD     B, A                 ; Do bottom clipping by
    JR     VertClipDone3         ; setting height to (64 - ypos)

ClipTop3:
    LD     A, B                 ; If ypos <= -height
    NEG                         ; sprite is off-screen
    SUB    E                    ;
    RET    NC                   ;

    PUSH   AF
    ADD    A, B                 ; Get the number of clipped rows
    LD     E, 0                 ; Set ypos to 0 (top of screen)
    LD     B, E                 ; Advance image data pointer
    LD     C, A                 ;
    ADD    IX, BC               ;
    POP    AF
    NEG                         ; Get the number of visible rows
    LD     B, A                 ; and set as height

VertClipDone3:
; Now we're doing horizontal clipping
    LD     C, 0                 ; Reset correction factor
    LD     A, D

    CP     -7                   ; If 0 > xpos >= -7
    JR     NC, ClipLeft3         ; clip the left side

    CP     96                   ; If xpos >= 96
    RET    NC                   ; sprite is off-screen

    CP     89                   ; If 0 <= xpos < 89
    JR     C, HorizClipDone3     ; don't need to clip

ClipRight3:
    AND    7                    ; Determine the clipping mask
    LD     C, A
    LD     A, %11111111
FindRightMask3:
    ADD    A, A
    DEC    C
    JR     NZ, FindRightMask3
    LD     (clip_mask), A
    LD     A, D
    JR     HorizClipDone3

ClipLeft3:
    AND    7                    ; Determine the clipping mask
    LD     C, A
    LD     A, %11111111
FindLeftMask3:
    ADD    A, A
    DEC    C
    JR     NZ, FindLeftMask3
    CPL
    LD     (clip_mask), A
    LD     A, D
    ADD    A, 96                ; Set xpos so sprite will "spill over"
    LD     C, 12                ; Set correction

HorizClipDone3:
; A = xpos
; E = ypos
; B = height
; IX = image address

; Now we can finally display the sprite.
    LD     H, 0
    LD     D, H
    LD     L, E
    ADD    HL, HL
    ADD    HL, DE
    ADD    HL, HL
    ADD    HL, HL

    LD     E, A
    SRL    E
    SRL    E
    SRL    E
    ADD    HL, DE

    push iy \ pop de ; LD     DE, PlotSScreen
    ADD    HL, DE

    LD     D, 0                 ; Correct graph buffer address
    LD     E, C                 ; if clipping the left side
    SBC    HL, DE               ;

    AND    7
    JR     Z, _Aligned3

    LD     C, A
    LD     DE, 11

_RowLoop3:
    PUSH   BC
    LD     B, C
    LD     A, (clip_mask)       ; Mask out the part of the sprite
    AND    (IX)                 ; to be horizontally clipped
    LD     C, 0

_ShiftLoop3:
    SRL    A
    RR     C
    DJNZ   _ShiftLoop3

    OR    (HL)
    LD     (HL), A

    INC    HL
    LD     A, C
    OR    (HL)
    LD     (HL), A

    ADD    HL, DE
    INC    IX
    POP    BC
    DJNZ   _RowLoop3
    RET

_Aligned3:
    LD     DE, 12

_PutLoop3:
    LD     A, (IX)
    OR    (HL)
    LD     (HL), A
    INC    IX
    ADD    HL, DE
    DJNZ   _PutLoop3
    RET
    
; From Axe's Commands.inc by Quigibo
; Inputs:    (e, l): X, Y
;        (c, b): width, height
RectXOR:
    ld    a,96        ;Clip Top
    sub    e
    ret    c
    ret    z
    cp    c        ;Clip Bottom
    jr    nc,$+3
    ld    c,a
    ld    a,64        ;Clip Left
    sub    l
    ret    c
    ret    z
    cp    b        ;Clip Right
    jr    nc,$+3
    ld    b,a

    xor    a        ;More clipping...
    cp    b
    ret    z
    cp    c
    ret    z
    ld    h,a
    ld    d,a

    push    bc
    push    iy
    pop    bc
    ld    a,l
    add    a,a
    add    a,l
    ld    l,a
    add    hl,hl
    add    hl,hl        ;(e,_) = (X,Y)
    add    hl,bc        ;(_,_) = (width,height)

    ld    a,e
    srl    e
    srl    e
    srl    e
    add    hl,de
    and    %00000111    ;(a,_) = (X^8,Y)
    pop    de        ;(e,d) = (width,height)

    ld    b,a
    add    a,e
    sub    8
    ld    e,0
    jr    c,__BoxInvSkip
    ld    e,a
    xor    a
__BoxInvSkip:

__BoxInvShift:            ;Input:  b = Left shift
    add    a,8        ;Input:  a = negative right shift
    sub    b        ;Output: a = mask
    ld    c,0
__BoxInvShift1:
    scf
    rr    c
    dec    a
    jr    nz,__BoxInvShift1
    ld    a,c
    inc    b
    rlca
__BoxInvShift2:
    rrca
    djnz    __BoxInvShift2

__BoxInvLoop1:            ;(e,d) = (width,height)
    push    hl        ;    a = bitmask
    ld    b,d
    ld    c,a
    push    de
    ld    de,12
__BoxInvLoop2:
    ld    a,c
    xor    (hl)
    ld    (hl),a
    add    hl,de
    djnz    __BoxInvLoop2
    pop    de
    pop    hl
    inc    hl
    ld    a,e
    or    a
    ret    z
    sub    8
    ld    e,b
    jr    c,__BoxInvShift
    ld    e,a
    ld    a,%11111111
    jr    __BoxInvLoop1
__BoxInvEnd:

; From Axe's Commands.inc by Quigibo
; Inputs:    (e, l): X, Y
;        (c, b): width, height
RectOR:
    ld    a,96        ;Clip Top
    sub    e
    ret    c
    ret    z
    cp    c        ;Clip Bottom
    jr    nc,$+3
    ld    c,a
    ld    a,64        ;Clip Left
    sub    l
    ret    c
    ret    z
    cp    b        ;Clip Right
    jr    nc,$+3
    ld    b,a

    xor    a        ;More clipping...
    cp    b
    ret    z
    cp    c
    ret    z
    ld    h,a
    ld    d,a

    push    bc
    push    iy
    pop    bc
    ld    a,l
    add    a,a
    add    a,l
    ld    l,a
    add    hl,hl
    add    hl,hl        ;(e,_) = (X,Y)
    add    hl,bc        ;(_,_) = (width,height)

    ld    a,e
    srl    e
    srl    e
    srl    e
    add    hl,de
    and    %00000111    ;(a,_) = (X^8,Y)
    pop    de        ;(e,d) = (width,height)

    ld    b,a
    add    a,e
    sub    8
    ld    e,0
    jr    c,__BoxORSkip
    ld    e,a
    xor    a
__BoxORSkip:

__BoxORShift:            ;Input:  b = Left shift
    add    a,8        ;Input:  a = negative right shift
    sub    b        ;Output: a = mask
    ld    c,0
__BoxORShift1:
    scf
    rr    c
    dec    a
    jr    nz,__BoxORShift1
    ld    a,c
    inc    b
    rlca
__BoxORShift2:
    rrca
    djnz    __BoxORShift2

__BoxORLoop1:            ;(e,d) = (width,height)
    push    hl        ;    a = bitmask
    ld    b,d
    ld    c,a
    push    de
    ld    de,12
__BoxORLoop2:
    ld    a,c
    or    (hl)
    ld    (hl),a
    add    hl,de
    djnz    __BoxORLoop2
    pop    de
    pop    hl
    inc    hl
    ld    a,e
    or    a
    ret    z
    sub    8
    ld    e,b
    jr    c,__BoxORShift
    ld    e,a
    ld    a,%11111111
    jr    __BoxORLoop1
__BoxOREnd:

; From Axe's Commands.inc by Quigibo
; Inputs:    (e, l): X, Y
;        (c, b): width, height
RectAND:
    ld    a,96        ;Clip Top
    sub    e
    ret    c
    ret    z
    cp    c        ;Clip Bottom
    jr    nc,$+3
    ld    c,a
    ld    a,64        ;Clip Left
    sub    l
    ret    c
    ret    z
    cp    b        ;Clip Right
    jr    nc,$+3
    ld    b,a

    xor    a        ;More clipping...
    cp    b
    ret    z
    cp    c
    ret    z
    ld    h,a
    ld    d,a

    push    bc
    push    iy
    pop    bc
    ld    a,l
    add    a,a
    add    a,l
    ld    l,a
    add    hl,hl
    add    hl,hl        ;(e,_) = (X,Y)
    add    hl,bc        ;(_,_) = (width,height)

    ld    a,e
    srl    e
    srl    e
    srl    e
    add    hl,de
    and    %00000111    ;(a,_) = (X^8,Y)
    pop    de        ;(e,d) = (width,height)

    ld    b,a
    add    a,e
    sub    8
    ld    e,0
    jr    c,__BoxANDSkip
    ld    e,a
    xor    a
__BoxANDSkip:

__BoxANDShift:            ;Input:  b = Left shift
    add    a,8        ;Input:  a = negative right shift
    sub    b        ;Output: a = mask
    ld    c,0
__BoxANDShift1:
    scf
    rr    c
    dec    a
    jr    nz,__BoxANDShift1
    ld    a,c
    inc    b
    rlca
__BoxANDShift2:
    rrca
    djnz    __BoxANDShift2

__BoxANDLoop1:            ;(e,d) = (width,height)
    push    hl        ;    a = bitmask
    ld    b,d
    ld    c,a
    push    de
    ld    de,12
__BoxANDLoop2:
    ld    a,c
    cpl
    and    (hl)
    ld    (hl),a
    add    hl,de
    djnz    __BoxANDLoop2
    pop    de
    pop    hl
    inc    hl
    ld    a,e
    or    a
    ret    z
    sub    8
    ld    e,b
    jr    c,__BoxANDShift
    ld    e,a
    ld    a,%11111111
    jr    __BoxANDLoop1
__BoxANDEnd:

;2-byte (across) sprite xor routine by Jon Martin
;optimized to be faster than Joe Wingbermeuhle's largesprite routine
;based on the 1-byte xor routine from "learn ti 83+ asm in 28 days"
;inputs:
;d=xc
;e=yc
;b=height
;hl=sprite pointer
;destroys all except shadow registers
PutSprite16XOR:
    push af
    push hl
    push bc
    push de
    push ix
        push hl \ pop ix
        ld a, d
        call _PutSprite16XOR
    pop ix
    pop de
    pop bc
    pop hl
    pop af
    ret

_PutSprite16XOR:                
    ld h,0             ;7        
    ld l,e            ;4        
    ld d,h         ;4
    add hl,hl        ;11
    add hl,de        ;11
    add hl,hl        ;11
    add hl,hl        ;11
    push iy \ pop de    ;10
    add hl,de        ;11
    ld e,a            ;4
    srl e            ;8
    srl e            ;8
    srl e            ;8
    ld d,0            ;7
    add hl,de        ;11
    ld d,h            ;4
    ld e,l            ;4
    and 7            ;4
    jp z,aligned        ;10
    ld c,a            ;4
    ld de,12        ;10
rowloop:        ;total: 194
    push bc        ;11
    ld b,c         ;4
    xor a            ;4
    ld d,(ix)        ;19
    ld e,(ix+1)        ;19
shiftloop:        ;60 per loop
    srl d            ;8
    rr e            ;8
    rra            ;4
    djnz shiftloop        ;13/8,37 per loop
    inc hl
    inc hl
    xor (hl)
    ld (hl),a
    ld a,e
    dec hl
    xor (hl)
    ld (hl),a
    ld a,d
    dec hl
    xor (hl)
    ld (hl),a    
    pop bc            ;10
    ld de,12        ;10
    add hl,de        ;11
    inc ix            ;10
    inc ix            ;10
    djnz rowloop        ;13/8
    ret            ;10
aligned:
    ld de,11 
alignedloop:
    ld a,(ix)
    xor (hl)
    ld (hl),a
    ld a,(ix+1)
    inc hl
    xor (hl)
    ld (hl),a
    add hl,de
    inc ix
    inc ix
    djnz alignedloop
    ret
 
PutSprite16OR:
    push af
    push hl
    push bc
    push de
    push ix
        push hl \ pop ix
        ld a, d
        call _PutSprite16OR
    pop ix
    pop de
    pop bc
    pop hl
    pop af
    ret

_PutSprite16OR:                
    ld h,0             ;7        
    ld l,e            ;4        
    ld d,h         ;4
    add hl,hl        ;11
    add hl,de        ;11
    add hl,hl        ;11
    add hl,hl        ;11
    push iy \ pop de    ;10
    add hl,de        ;11
    ld e,a            ;4
    srl e            ;8
    srl e            ;8
    srl e            ;8
    ld d,0            ;7
    add hl,de        ;11
    ld d,h            ;4
    ld e,l            ;4
    and 7            ;4
    jp z,alignedOR        ;10
    ld c,a            ;4
    ld de,12        ;10
rowloopOR:        ;total: 194
    push bc        ;11
    ld b,c         ;4
    xor a            ;4
    ld d,(ix)        ;19
    ld e,(ix+1)        ;19
shiftloopOR:        ;60 per loop
    srl d            ;8
    rr e            ;8
    rra            ;4
    djnz shiftloopOR        ;13/8,37 per loop
    inc hl
    inc hl
    xor (hl)
    ld (hl),a
    ld a,e
    dec hl
    or (hl)
    ld (hl),a
    ld a,d
    dec hl
    or (hl)
    ld (hl),a    
    pop bc            ;10
    ld de,12        ;10
    add hl,de        ;11
    inc ix            ;10
    inc ix            ;10
    djnz rowloopOR        ;13/8
    ret            ;10
alignedOR:
    ld de,11 
alignedloopOR:
    ld a,(ix)
    or (hl)
    ld (hl),a
    ld a,(ix+1)
    inc hl
    or (hl)
    ld (hl),a
    add hl,de
    inc ix
    inc ix
    djnz alignedloopOR
    ret
 
PutSprite16AND:
    push af
    push hl
    push bc
    push de
    push ix
        push hl \ pop ix
        ld a, d
        call _PutSprite16AND
    pop ix
    pop de
    pop bc
    pop hl
    pop af
    ret

_PutSprite16AND:                
    ld h,0             ;7        
    ld l,e            ;4        
    ld d,h         ;4
    add hl,hl        ;11
    add hl,de        ;11
    add hl,hl        ;11
    add hl,hl        ;11
    push iy \ pop de    ;10
    add hl,de        ;11
    ld e,a            ;4
    srl e            ;8
    srl e            ;8
    srl e            ;8
    ld d,0            ;7
    add hl,de        ;11
    ld d,h            ;4
    ld e,l            ;4
    and 7            ;4
    jp z,alignedAND        ;10
    ld c,a            ;4
    ld de,12        ;10
rowloopAND:        ;total: 194
    push bc        ;11
    ld b,c         ;4
    xor a            ;4
    ld d,(ix)        ;19
    ld e,(ix+1)        ;19
shiftloopAND:        ;60 per loop
    srl d            ;8
    rr e            ;8
    rra            ;4
    djnz shiftloopAND        ;13/8,37 per loop
    inc hl
    inc hl
    xor (hl)
    ld (hl),a
    ld a,e
    dec hl
    cpl
    and (hl)
    ld (hl),a
    ld a,d
    dec hl
    cpl
    and (hl)
    ld (hl),a    
    pop bc            ;10
    ld de,12        ;10
    add hl,de        ;11
    inc ix            ;10
    inc ix            ;10
    djnz rowloopAND        ;13/8
    ret            ;10
alignedAND:
    ld de,11 
alignedloopAND:
    ld a,(ix)
    cpl
    and (hl)
    ld (hl),a
    ld a,(ix+1)
    inc hl
    cpl
    and (hl)
    ld (hl),a
    add hl,de
    inc ix
    inc ix
    djnz alignedloopAND
    ret