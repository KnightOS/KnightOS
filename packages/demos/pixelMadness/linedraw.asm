; -------------------- lineDraw --------------------
;
; Draws to the graph buffer a line between two points.
;
; Version: 1.0
; Author: Badja <http://badja.calc.org> <badja@calc.org>
; Date: 19 June 2001
; Size: 234 bytes
;
; Input:
;   (D, E) = (x0, y0), the first point
;   (H, L) = (x1, y1), the second point
;
; Input constraints:
;   Both points must be within the bounds of the screen.
;
; Output:
;   A line between the two points is ORed to the graph buffer.
;
; Destroys:
;   AF, BC, DE, HL, IX
;
; Requires:
;   Ion's getPixel routine.
;
; Comments:
;   This routine is based on the classic algorithm by Bresenham.
;   It produces the best possible pixel representation of a line,
;   and is very fast because it uses only integer arithmetic.

lineDraw:
      ld    a,h
      sub   d
      jr    nc,ld_noAbsX
      neg
ld_noAbsX:
      ld    b,a               ; B = |dx|
      ld    a,l
      sub   e
      ld    c,a               ; C = dy
      jr    nc,ld_noAbsY
      neg
ld_noAbsY:                    ; A = |dy|
      cp    b
      jr    nc,ld_rotated

      ld    a,h
      sub   d                 ; A = dx
      bit   7,a
      jr    z,ld_noSwap1
      ex    de,hl
      ld    a,b               ; A = |dx|
ld_noSwap1:
      push  af
      push  de
      neg
      ld    d,a               ; D = -dx
      ld    bc,12
      ld    a,e
      cp    l
      jr    c,ld_noReflectX
      ld    e,l
      ld    l,a
      ld    bc,-12
ld_noReflectX:
      ld    (ld_setIncrY),bc
      ld    b,$ff
      ld    c,d               ; BC = -dx
      ld    h,0               ; HL = y1
      ld    d,h               ; DE = y0
      and   a                 ; set C flag to zero
      sbc   hl,de             ; HL = dy
      add   hl,hl
      ld    (ld_setIncrE),hl
      add   hl,bc
      ld    d,h
      ld    e,l               ; DE = d
      add   hl,bc
      ld    (ld_setIncrESE),hl
      pop   bc                ; B = x0, C = y0
      push  de
      ld    a,b
      ld    e,c
      call  getPixel       ; HL -> graphbuffer offset, A = pixel mask
      push  hl
      pop   ix                ; IX -> graphbuffer offset
      pop   hl                ; HL = d
      pop   bc                ; B = |dx|
      ld    d,a
      or    (ix)
      ld    (ix),a
      ld    a,b
      or    a
      ret   z
ld_lineLoopE:
      ld    a,d
      bit   7,h
      jr    z,ld_goESE
ld_setIncrE = $ + 1
      ld    de,$0000
      add   hl,de
      jr    ld_incrementX
ld_goESE:
ld_setIncrESE = $ + 1
      ld    de,$0000
      add   hl,de
ld_setIncrY = $ + 1
      ld    de,$0000
      add   ix,de
ld_incrementX:
      rrca
      jr    nc,ld_sameByte1
      inc   ix
ld_sameByte1:
      ld    d,a
      or    (ix)
      ld    (ix),a
      djnz  ld_lineLoopE
      ret

ld_rotated:
      bit   7,c               ; C = dy
      jr    z,ld_noSwap2
      ex    de,hl
      ld    c,a               ; C = |dy|
ld_noSwap2:
      ld    a,c
      push  af
      push  de
      neg
      ld    c,a               ; C = -dy
      ld    l,h
      ld    e,d
      ld    a,e
      cp    l
      ld    a,$0f             ; opcode for RRCA
      ld    b,$23             ; second byte of opcode for INC IX
      jr    c,ld_noReflectY
      ld    e,l
      ld    l,d
      ld    a,$07             ; opcode for RLCA
      ld    b,$2b             ; second byte of opcode for DEC IX
ld_noReflectY:
      ld    (ld_setIncrX1),a
      ld    a,b
      ld    (ld_setIncrX2),a
      ld    b,$ff             ; BC = -dy
      ld    h,0               ; HL = x1
      ld    d,h               ; DE = x0
      and   a                 ; set C flag to zero
      sbc   hl,de             ; HL = dx
      add   hl,hl
      ld    (ld_setIncrS),hl
      add   hl,bc
      ld    d,h
      ld    e,l               ; DE = d
      add   hl,bc
      ld    (ld_setIncrSSE),hl
      pop   bc                ; B = x0, C = y0
      push  de
      ld    a,b
      ld    e,c
      call  getPixel       ; HL -> graphbuffer offset, A = pixel mask
      push  hl
      pop   ix                ; IX -> graphbuffer offset
      pop   hl                ; HL = d
      pop   bc                ; B = |dy|
      ld    d,a
      or    (ix)
      ld    (ix),a
      ld    a,b
      or    a
      ret   z
ld_lineLoopS:
      ld    a,d
      bit   7,h
      jr    z,ld_goSSE
ld_setIncrS = $ + 1
      ld    de,$0000
      add   hl,de
      jr    ld_incrementY
ld_goSSE:
ld_setIncrSSE = $ + 1
      ld    de,$0000
      add   hl,de
ld_setIncrX1 = $
      rrca
      jr    nc,ld_sameByte2
ld_setIncrX2 = $ + 1
      inc   ix
ld_sameByte2:
ld_incrementY:
      ld    de,12
      add   ix,de
      ld    d,a
      or    (ix)
      ld    (ix),a
      djnz  ld_lineLoopS
      ret

.end
