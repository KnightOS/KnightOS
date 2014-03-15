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
    .db 0xff
    
.macro sdiv64()
    add hl, hl
    sbc a, a
    add hl, hl
    rla
    ld l, h
    ld h, a
.endmacro
    
;; rotateVertex [3dfxlib]
;;  Rotates a 3D vertex according to two angles.
;; Inputs:
;;  HL: location of the 3D vertex
;;  DE: where to write the resulting vertex
;;  C: X angle
;;  B: Y angle
;; Outputs:
;;  DE: rotated vertex written there
;; Notes:
;;  Each coordinate is two-bytes long. Each angle
;;  is in [0, 255].
rotateVertex:
    push af \ push hl
        push de
            ild((angles), bc)
            push bc
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
                ; sra a
                .db 0xCB, 0x2F
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
                        ; sra a
                        .db 0xCB, 0x2F
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
                ; sra a
                .db 0xCB, 0x2F
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
                        ; sra a
                        .db 0xCB, 0x2F
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
            pop bc
        pop de
        push de
            push bc
                ld bc, 6
                ldir
            pop bc
        pop de
    pop hl \ pop af
    ret
    
;; projectVertex [3dfxlib]
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
    push af \ push bc
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
            pcall(DEMulBC)
            sdiv64()
            ex (sp), hl
            ; x = rx * FOV / rz
            ld c, l
            ld b, h
            ild(de, (currentVertex))
            pcall(DEMulBC)
            sdiv64()
        pop de
    pop bc \ pop af
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
    