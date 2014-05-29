; KnightOS fx3dlib
; Various functions for drawing real-time 3D scenes

.nolist
libId .equ 0x03
#include "kernel.inc"
.list

.dw 0x0003

.org 0

jumpTable:
    ; Init
    ret \ nop \ nop
    ; De-init
    ret \ nop \ nop
    jp rotateVertex
    jp projectVertex
    jp drawTriangle
    .db 0xFF
    
.macro sdiv64()
    add hl, hl
    sbc a, a
    add hl, hl
    rla
    ld l, h
    ld h, a
.endmacro
    
;; rotateVertex [fx3dlib]
;;  Rotates a 3D vertex according to two angles.
;; Inputs:
;;  HL: location of the 3D vertex
;;  DE: where to write the resulting vertex
;;  C, B: X, Y angles
;; Outputs:
;;  DE: rotated vertex written there
;; Notes:
;;  Each coordinate is two-bytes long. Each angle
;;  is in [0, 255].
rotateVertex:
    ld a, i
    di
    push af
        push de
            ild((angles), bc)
            ild(de, currentVertex)
            ld bc, 6
            ldir
            
            ild(hl, curCosX)
            ild(de, angles)
            ld a, (de)
            pcall(icos)
            ld (hl), a
            inc hl
            ld a, (de)
            pcall(isin)
            ld (hl), a
            inc hl
            inc de
            
            ld a, (de)
            pcall(icos)
            ld (hl), a
            inc hl
            ld a, (de)
            pcall(isin)
            ld (hl), a
            
            ; rx = x * cos(ay) + z * sin(ay)
            ; ild(a, (curCosY))
            dec hl
            ld a, (hl)
            ild(de, (currentVertex))
            pcall(sDEMulA)
            push hl
                ild(a, (curSinY))
                ild(de, (currentVertex + 4))
                pcall(sDEMulA)
            pop de
            add hl, de
            sdiv64()
            ild((currentRVertex), hl)
            
            ; ry = x * (cos(ax - ay) - cos(ax + ay))/2 + y * cos(ax) + z * (-sin(ax - ay) - sin(ax + ay))/2
            ild(hl, angles)
            ld a, (hl)
            inc hl
            add a, (hl)
            pcall(icos)
            ld b, a
            dec hl
            ld a, (hl)
            inc hl
            sub (hl)
            pcall(icos)
            sub b
            sra a
            ild(de, (currentVertex))
            pcall(sDEMulA)
            push hl
                ild(a, (curCosX))
                ild(de, (currentVertex + 2))
                pcall(sDEMulA)
                push hl
                    ild(hl, angles)
                    ld a, (hl)
                    inc hl
                    add a, (hl)
                    pcall(isin)
                    ld b, a
                    dec hl
                    ld a, (hl)
                    inc hl
                    sub (hl)
                    pcall(isin)
                    neg
                    sub b
                    sra a
                    ild(de, (currentVertex + 4))
                    pcall(sDEMulA)
                pop de
                add hl, de
            pop de
            add hl, de
            sdiv64()
            ild((currentRVertex + 2), hl)
            
            ; rz = x * (sin(ax - ay) - sin(ax + ay))/2 + y * sin(ax) + z * (cos(ax - ay) + cos(ax + ay))/2
            ; camera offset for the sake of visibility : rz += 150
            ild(hl, angles)
            ld a, (hl)
            inc hl
            add a, (hl)
            pcall(isin)
            ld b, a
            dec hl
            ld a, (hl)
            inc hl
            sub (hl)
            pcall(isin)
            sub b
            sra a
            ild(de, (currentVertex))
            pcall(sDEMulA)
            push hl
                ild(a, (curSinX))
                ild(de, (currentVertex + 2))
                pcall(sDEMulA)
                push hl
                    ild(hl, angles)
                    ld a, (hl)
                    inc hl
                    add a, (hl)
                    pcall(icos)
                    ld b, a
                    dec hl
                    ld a, (hl)
                    inc hl
                    sub (hl)
                    pcall(icos)
                    add a, b
                    sra a
                    ild(de, (currentVertex + 4))
                    pcall(sDEMulA)
                pop de
                add hl, de
            pop de
            add hl, de
            sdiv64()
            ld de, 150
            add hl, de
            ild((currentRVertex + 4), hl)
            
            ild(hl, currentRVertex)
        pop de \ push de
            ld bc, 6
            ldir
        pop de
    pop af
    ret po
    ei
    ret
    
;; projectVertex [fx3dlib]
;;  Projects a 3D vertex into 2D coordinates.
;; Inputs:
;;  DE: location of the 3D vertex
;; Outputs:
;;  HL: X coordinate
;;  DE: Y coordinate
;; Notes:
;;  Outputted coordinates are relative to (0, 0),
;;  not the center of the screen.
projectVertex:
    ld a, i
    di
    push af
        ild(hl, currentVertex)
        ld bc, 6
        ex de, hl
        ldir

        ; FOV = 42
        ; 42 * 64 = 0x0A80
        ild(de, (currentVertex + 4))
        ld a, 0x0A
        ld c, 0x80
        pcall(divACbyDE)
        ld h, a
        ld l, c
        push hl
            ; y = ry * FOV / rz
            ld b, h
            ild(de, (currentVertex + 2))
            push de
                pcall(mul16By16To32)
            pop de
            sdiv64()
            ex (sp), hl
            ; x = rx * FOV / rz
            ld c, l
            ld b, h
            ild(de, (currentVertex))
            push de
                pcall(mul16By16To32)
            pop de
            sdiv64()
        pop de
    pop af
    ret po
    ei
    ret
currentVertex:
    .dw 0, 0, 0
currentRVertex:
    .dw 0, 0, 0
angles:
    .db 0, 0
curCosX:
    .db 0
curSinX:
    .db 0
curCosY:
    .db 0
curSinY:
    .db 0
    
;; drawTriangle [fx3dlib]
;;  Draws a filled triangle on the screen buffer.
;; Inputs:
;;  L, H: X1, Y1
;;  E, D: X2, Y2
;;  C, B: X3, Y3
;;  A: 0 for white, non-zero for black
;; Notes:
;;
drawTriangle:
    ld a, i
    di
    push af
        ild((x1), hl)
        ild((x2), de)
        ild((x3), bc)
        ; sort coordinates
        ld a, d
        cp h
        jr nc, .pt12sorted
        ; next checks do it right
        ex de, hl
        ild((x1), hl)
        ild((x2), de)
.pt12sorted:
        ld a, b
        cp d
        jr nc, .pt23sorted
        ild((x2), bc)
        ild((x3), de)
        push bc
            ld c, e
            ld b, d
        pop de
.pt23sorted:
        ld a, d
        cp h
        jr nc, .pt12sorted_again
        ex de, hl
        ild((x1), hl)
        ild((x2), de)
.pt12sorted_again:
        
        ; crash is between here
        
        ; dx1 = (x2 - x1) * 256 / (y2 - y1)
        ; beware the division by 0
        ld a, d
        sub h
        jr z, .dx1NoDiv
        ld b, a
        ld a, e
        sub l
        ld c, a
        jr z, .dx1done
        ld a, b
        ld e, a
        rla
        sbc a, a
        ld d, a
        ld a, c
        ld c, 0
        pcall(sDivACbyDE)
        jr .dx1done
.dx1NoDiv:
        ld a, e
        sub l
        ld c, 0
.dx1done:
        ild(hl, dx1)
        ld (hl), c
        inc hl
        ld (hl), a
        
        ; and here
        
        ; dx2 = (x3 - x1) * 256 / (y3 - y1)
        ; BUT registers are stashed due to the previous calculations
        ild(hl, (x1))
        ild(de, (x3))
        ld a, d
        sub h
        jr z, .dx2NoDiv
        ld b, a
        ld a, e
        sub l
        ld c, a
        jr z, .dx2done
        ld a, b
        ld e, a
        rla
        sbc a, a
        ld d, a
        ld a, c
        ld c, 0
        pcall(sDivACbyDE)
        jr .dx2done
.dx2NoDiv:
        ld a, e
        sub l
        ld c, 0
.dx2done:
        ild(hl, dx2)
        ld (hl), c
        inc hl
        ld (hl), a

        ; dx3 = (x3 - x2) * 256 / (y3 - y2)
        ild(hl, (x2))
        ild(de, (x3))
        ld a, d
        sub h
        jr z, .dx3NoDiv
        ld b, a
        ld a, e
        sub l
        ld c, a
        jr z, .dx3done
        ld a, b
        ld e, a
        rla
        sbc a, a
        ld d, a
        ld a, c
        ld c, 0
        pcall(sDivACbyDE)
        jr .dx3done
.dx3NoDiv:
        ld a, e
        sub l
        ld c, 0
.dx3done:
        ild(hl, dx3)
        ld (hl), c
        inc hl
        ld (hl), a

        ; px1 = px2 = x1 * 256
        ; h = (x1)
        ild(hl, (x1 - 1))
        ld l, 0
        ild((px1), hl)
        ild((px2), hl)

        ; indicates if we're on the first or second edge
        ld b, l
.drawLoop:
        ; drawHLine(y1, px1 / 256, px2 / 256)
        ; but later
        ild(a, (px2 + 1))
        ild(de, (px1 + 1))
        cp e
        jr nc, .noSwitch
        ld c, a
        ld a, e
        ld e, c
.noSwitch:
        sub e
        ld c, a
        inc c
        push bc
            ld b, 1
            ild(hl, (y1))
            pcall(rectOR)
        pop bc

        ; px1 += currentEdge ? dx3 : dx1
        xor a
        cp b
        ild(hl, (px1))
        jr z, .firstEdge
.secondEdge:
        ild(de, (dx3))
        jr +_
.firstEdge:
        ild(de, (dx1))
_:
        add hl, de
        ild((px1), hl)

        ; px2 += dx2
        ild(hl, (px2))
        ild(de, (dx2))
        add hl, de
        ild((px2), hl)

        ; if(y1++ >= y2) currentEdge = 1
        ild(hl, y1)
        inc (hl)
        ld a, (hl)
        inc hl
        inc hl
        cp (hl)
        jr c, .noNextEdge
        ld b, 1
.noNextEdge:
        ; while(y1 <= y3)
        inc hl
        inc hl
        dec a
        cp (hl)
        jr c, .drawLoop
    pop af
    ret po
    ei
    ret
    
x1:
    .db 0
y1:
    .db 0
x2:
    .db 0
y2:
    .db 0
x3:
    .db 0
y3:
    .db 0
px1:
    .dw 0
px2:
    .dw 0
dx1:
    .dw 0
dx2:
    .dw 0
dx3:
    .dw 0
triangleColor:
    .db 0
    
