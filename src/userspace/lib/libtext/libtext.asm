; KnightOS Text Library
; 9/24/2011
; Facilitates drawing of text onto buffers

.nolist
libID .equ $01
#include "kernel.inc"
.list

.dw $0001

.org 0

JumpTable:
    ; Init
    ret \ nop \ nop
    ; Deinit
    ret \ nop \ nop
    jp DrawChar
    jp DrawCharAND
    jp DrawCharXOR
    jp DrawStr
    jp DrawStrAND
    jp DrawStrXOR
    jp DrawStrFromStream
    jp DrawHexA
    jp MeasureChar
    jp MeasureStr
    .db $FF

; Inputs:    A: Character to print
;            D,E: X,Y
;            B: Left X (used for \n)
;            IY: Buffer
; Outputs:    Updates DE
DrawChar:
DrawCharOR:
    push af
    push hl
    push ix
    push bc
        cp '\n'
        jr nz, _
        ld a, e
        add a, 6
        ld e, a
        ld d, b
        jr ++_
    
_:        push de
            ld de, 6
            sub $20
            call DEMulA
            ex de, hl
            ; ild(hl, Font)
            rst $10
            .db libID
            ld hl, Font
            add hl, de
            ld a, (hl)
            inc hl
        pop de
        ld b, 5
        call PutSpriteOR
        add a, d
        ld d, a
_:    pop bc
    pop ix
    pop hl
    pop af
    ret
    
DrawCharAND:
    push af
    push hl
    push ix
    push bc
        cp '\n'
        jr nz, _
        ld a, e
        add a, 6
        ld e, a
        ld d, b
        jr ++_
    
_:        push de
            ld de, 6
            sub $20
            call DEMulA
            ex de, hl
            ; ild(hl, Font)
            rst $10
            .db libID
            ld hl, Font
            add hl, de
            ld a, (hl)
            inc hl
        pop de
        ld b, 5
        call PutSpriteAND
        add a, d
        ld d, a
_:    pop bc
    pop ix
    pop hl
    pop af
    ret

DrawCharXOR:
    push af
    push hl
    push ix
    push bc
        cp '\n'
        jr nz, _
        ld a, e
        add a, 6
        ld e, a
        ld d, b
        jr ++_
    
_:        push de
            ld de, 6
            sub $20
            call DEMulA
            ex de, hl
            ; ild(hl, Font)
            rst $10
            .db libID
            ld hl, Font
            add hl, de
            ld a, (hl)
            inc hl
        pop de
        ld b, 5
        call PutSpriteXOR
        add a, d
        ld d, a
_:    pop bc
    pop ix
    pop hl
    pop af
    ret

; Inputs:    HL: String
;            DE: Location
;            B (Optional): Left X (Used for \n)
;            IY: Buffer
DrawStr:
    push hl
    push af
_:        ld a, (hl)
        or a
        jr z, _
        ; icall(PutChar)
        rst $10
        .db libID
        call DrawChar
        inc hl
        jr -_
_:    pop af
    pop hl
    ret

DrawStrAND:
    push hl
    push af
_:        ld a, (hl)
        or a
        jr z, _
        ; icall(PutChar)
        rst $10
        .db libID
        call DrawCharAND
        inc hl
        jr -_
_:    pop af
    pop hl
    ret
    
DrawStrXOR:
    push hl
    push af
_:        ld a, (hl)
        or a
        jr z, _
        ; icall(PutChar)
        rst $10
        .db libID
        call DrawCharXOR
        inc hl
        jr -_
_:    pop af
    pop hl
    ret
    ret

; Inputs:    B: Stream ID
; Prints a string from a stream
DrawStrFromStream:
    push af
_:      call StreamReadByte
        jr nz, _
        or a
        jr z, _
        ; icall(PutChar)
        rst $10
        .db libID
        call DrawChar
        jr -_
_:    pop af
    ret
    
DrawHexA:
   push af
   rrca
   rrca
   rrca
   rrca
   ; icall(dispha)
   rst $10 \ .db libID \ call dispha
   pop af
   ; icall(dispha)
   rst $10 \ .db libID \ call dispha
   ret
dispha:
   and 15
   cp 10
   jr nc,dhlet
   add a, 48
   jr dispdh
dhlet:
   add a,55
dispdh:
   ;icall(DrawCharOR)
   rst $10 \ .db libId
   call DrawCharOR
   ret
   
; Inputs:    A: Character to measure
; Outputs:    A: Width of character (height is always 5)
; Note: The width of most characters include a column of
; whitespace on the right side.
MeasureChar:
    push hl
    push de
        ld de, 6
        sub $20
        call DEMulA
        ex de, hl
        ;ild(hl, Font)
        rst $10
        .db libID
        ld hl, Font
        add hl, de
        ld a, (hl)
    pop de
    pop hl
    ret

; Inputs:    HL: String to measure
; Outputs:    A: Width of string
MeasureStr:
    push hl
    push bc
_:        push af
            ld a, (hl)
            or a
            jr z, _
            ;icall(MeasureChar)
            rst $10
            .db libID
            call MeasureChar
        pop bc
        add a, b
        ld a, b
        inc hl
        jr -_
_:    pop af
    pop bc
    pop hl
    ret
    
#include "font.asm"