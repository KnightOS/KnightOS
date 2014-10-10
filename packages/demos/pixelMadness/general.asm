RLE:
_DispRLEL:
    ld a, (hl)          ; get the next byte
    cp $91              ; is it a run?
    jr z, _DispRLERun    ; then we need to decode the run
    ldi                 ; copy the byte, and update counters
_DispRLEC:
    ret po              ; ret if bc hit 0
    jr _DispRLEL         ; otherwise do next byte
_DispRLERun:
    inc hl
    inc hl              ; move to the run count
    ld a, (hl)          ; get the run count
_DispRLERunL:
    dec hl              ; go back to run value
    dec a               ; decrease run counter
    ldi                 ; copy byte, dec bc, inc de, inc hl
    jr nz, _DispRLERunL  ; if we're not done, then loop
    inc hl              ; advance the source pointer
    jr _DispRLEC         ; check to see if we should loop

Mul_14:
	ld l, a
	ld h, 0
	add hl, hl
	ld d, h
	ld e, l
	add hl, hl
	add hl, hl
	add hl, hl
	xor a
	sbc hl, de
	ret

Mul_32:
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ret

; largeORSprite:
	; di
	; ex	af,af'
	; ld	a,c
	; push	af
	; ex	af,af'
	; ld	e,l
	; ld	h,$00
	; ld	d,h
	; add	hl,de
	; add	hl,de
	; add	hl,hl
	; add	hl,hl
	; ld	e,a
	; and	$07
	; ld	c,a
	; srl	e
	; srl	e
	; srl	e
	; add	hl,de
	; ld	de,PlotsScreen
	; add	hl,de
; largeSpriteLoop1:
	; push	hl
; largeSpriteLoop2:
	; ld	d,(ix)
	; ld	e,$00
	; ld	a,c
	; or	a
	; jr	z,largeSpriteSkip1
; largeSpriteLoop3:
	; srl	d
	; rr	e
	; dec	a
	; jr	nz,largeSpriteLoop3
; largeSpriteSkip1:
	; ld	a,(hl)
	; or	d
	; ld	(hl),a
	; inc	hl
	; ld	a,(hl)
	; or	e
	; ld	(hl),a
	; inc	ix
	; ex	af,af'
	; dec	a
	; push	af
	; ex	af,af'
	; pop	af
	; jr	nz,largeSpriteLoop2
	; pop	hl
	; pop	af
	; push	af
	; ex	af,af'
	; ld	de,$0C
	; add	hl,de
	; djnz	largeSpriteLoop1
	; pop	af
	; ret
