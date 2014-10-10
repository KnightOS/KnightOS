ripple_Reflect:
	ld ix,Ripple_Table
	ld hl,Scale_Val
	ld (Scale_Pointer),hl
	ld hl,Dither_Pattern
	ld (Dither_Pointer),hl
	ld a,4
	ld (Dither_Count),a
	ld a,$FF
	ld (Water_Mask+1),a
	ld hl,PlotsScreen+(12*31)
	ld de,PlotsScreen+(12*32)
	ld c,32
Copy_Line:
	ld b,12
	ld (Start_Of_Line),de
Copy_Loop:
	ld a,(hl)
Water_Mask:
	and 0
	ld (de),a
	inc hl
	inc de
	djnz Copy_Loop
	push de
	ld de,-24
	add hl,de
	push bc
	push hl
		ld a,(Dither_Count)
		dec a
		ld (Dither_Count),a
		or a
		jr nz,Not_Hit_Zero_Dither
		ld a,4
		ld (Dither_Count),a
		ld hl,(Dither_Pointer)
		inc hl
		ld (Dither_Pointer),hl
		ld a,(hl)
		ld (Water_Mask+1),a
Not_Hit_Zero_Dither:
		ld a,(Water_Mask+1)
		rr a
		jr nc,No_Extra_Bit
		or %10000000
No_Extra_Bit:
		ld (Water_Mask+1),a
		ld a,(ix+0)
		or a
		jr z,Shift_Done
		bit 7,a
		jr nz,Is_Left_Shift
		ld a,(ix+0)
		ld b,a
		call get_Scaled_Val
		ld a,h
		or a
		jr z,Shift_Done
		ld b,h
		call Shift_Line_Right
		jr Shift_Done
Is_Left_Shift:
		ld a,(ix+0)
		and %01111111		
		ld b,a
		call get_Scaled_Val
		ld a,h
		or a
		jr z,Shift_Done
		ld b,h
		call Shift_Line_Left
Shift_Done:
	inc ix
	pop hl
	pop bc
	pop de
	dec c
	ld a,c
	or a
	jr nz,Copy_Line
	call ionFastCopy
	;Shift wave pattern
	ld a,(Ripple_Delay)
	inc a
	ld (Ripple_Delay),a
	and %00000010
	jr nz,Not_Shift_Ripple
	ld a,(Ripple_Table)
	ld hl,Ripple_Table+1
	ld de,Ripple_Table
	ld bc,31
	ldir
	ld (Ripple_Table+31),a
Not_Shift_Ripple:
	ret


get_Scaled_Val:
	ld hl,(Scale_Pointer)
	ld a,(hl)
	inc hl
	ld (Scale_Pointer),hl
Calc_Scale:
	ld hl,0
	ld e,a
	ld d,0
	ld a,b
Calc_Scale_Loop:
	or a
	ret z
	add hl,de
	dec a
	jr Calc_Scale_Loop


Ripple_Table:
.db 	0
.db 	6
.db 	9
.db 	10
.db 	7
.db 	2
.db 	132
.db 	136
.db 	138
.db 	136
.db 	132
.db 	2
.db 	7
.db 	10
.db 	9
.db 	6
.db 	0
.db 	134
.db 	137
.db 	138
.db 	135
.db 	130
.db 	4
.db 	8
.db 	10
.db 	8
.db 	4
.db 	130
.db 	135
.db 	138
.db 	137
.db 	134

Dither_Pattern:
.db %11111111
.db %10110111
.db %01011011
.db %10101010
.db %01010101
.db %10010010
.db %00100100
.db %00000000


Scale_Val:
.db 	0
.db 	8
.db 	16
.db 	24
.db 	32
.db 	40
.db 	48
.db 	56
.db 	64
.db 	72
.db 	80
.db 	88
.db 	96
.db 	104
.db 	112
.db 	120
.db 	128
.db 	136
.db 	144
.db 	152
.db 	160
.db 	168
.db 	176
.db 	184
.db 	192
.db 	200
.db 	208
.db 	216
.db 	224
.db 	232
.db 	240
.db 	248