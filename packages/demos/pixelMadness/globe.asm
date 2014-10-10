
Effect_Globe:
	ld hl,0
	ld (xRot),hl
Globe_Loop:

	bcall(_grbufclr)
	ld a,(Mask_Type)
	or a
	jr z,Skip_Backface_Clear
	ld hl,SavesScreen
	ld bc,768
	xor a
	bcall(_memset)
Skip_Backface_Clear:
	ld ix,model
	call getPoints
	ld ix,model
Draw_Next_Line:
	ld hl,(yPos)
	ld (lastPos),hl

	call getPoints

	ld hl,PlotsScreen

	ld a,(Mask_Type)
	cp 3
	jr z,No_Set_Backface

	ld a,(isBackface)
	or a
	jr z,No_Set_Backface
	ld a,(Mask_Type)
	or a
	jr z,Skip_Drawing_No_Backface
	ld hl,SavesScreen
No_Set_Backface:
	ld (buffer_Offset+1),hl

	ld hl,(yPos)
	ld de,(lastPos)

	push ix
	call lineDraw
	pop ix	
Skip_Drawing_No_Backface:

	ld a,(ix+0)
	cp -1
	jr z,Done_All_Lines
	cp -2
	jr nz,Draw_Next_Line

	inc ix
	call getPoints
	jr Draw_Next_Line

Done_All_Lines:

	ld hl,PlotsScreen
	ld de,SavesScreen

	ld c,64
	ld a,(Mask_Type)
	or a
	jr z,No_Masking
	cp 1
	jr nz,Not_Mask_1a
	ld c,32
Not_Mask_1a:

Dither_Back_Main_Loop:
	ld b,12
Dither_Back_Loop:
	ld a,(de)
Mask:
	and %10101010
	or (hl)
	ld (hl),a
	inc hl
	inc de
	djnz Dither_Back_Loop


	ld a,(Mask_Type)	
	cp 1
	jr nz,Not_Mask_1b
	push de
		ld de,12
		add hl,de
		pop de
	push hl
		ld hl,12
		add hl,de
		ld d,h
		ld e,l
		pop hl
Not_Mask_1b:
	ld a,(Mask_Type)
	cp 2
	jr nz,Not_Mask_2a

	ld a,(Mask+1)
	xor $FF
	ld (Mask+1),a

Not_Mask_2a:
	dec c
	ld a,c
	jr nz,Dither_Back_Main_Loop
	
No_Masking:

	call ionFastCopy


	ld a,(xRot)
	inc a
	ld (xRot),a

	bcall(_getcsc)
	cp skClear
	ret z
	cp sk2nd

	jr nz,Not_2nd

	ld a,(Mask_Type)
	inc a
	and %00000011
	ld (Mask_Type),a
	jp Globe_Loop

Not_2nd:
	cp skAlpha
	jp nz,Globe_Loop
	
	ld a,(Halve_LOD)
	xor 1
	ld (Halve_LOD),a

	jp Globe_Loop

getPoints:
	ld a,(ix+1)
	call getSin_Globe
	add a,32
	ld (yPos),a

	;RESET +/- SIGN
	xor a
	ld (negF),a
	ld (isBackface),a

	ld b,(ix+0)
	ld a,(xRot)
	add a,b
	ld b,a
	add a,64
	cp 128
	jr c,Not_Backface
	ld a,1
	ld (isBackface),a

Not_Backface:
	ld a,b

	call getSin_Globe
	call getSign
	push af

	ld a,(ix+1)
	call getCos_Globe
	call getSign

	add a,a
	add a,a
	add a,a
	ld e,a
	ld d,0
	ld hl,0

	pop bc
	ld a,b
	or a
	jr z,Multiplied_Already

Multiply_Loop:
	add hl,de
	djnz Multiply_Loop
Multiplied_Already:
	ld b,h
	ld a,(negF)
	or a
	jr z,No_Need_Neg
	ld a,b
	neg
	add a,48
	ld (xPos),a
	jr Calculated_X_Y
No_Need_Neg:
	ld a,b
	add a,48
	ld (xPos),a
Calculated_X_Y:
	inc ix
	inc ix

	ld a,(Halve_LOD)
	or a
	ret z

	ld a,(ix+0)
	cp -1
	ret z
	cp -2
	ret z

	inc ix
	inc ix
	ret
	

getCos_Globe:
	add a,64
getSin_Globe:
	ld l,a
	ld h,0
	ld de,trigTable
	add hl,de
	ld a,(hl)
	ret

getSign:
	ld b,a
	and %10000000	;Check MSB
	jr z,Is_Fine	;Number is fine
	ld a,(negF)
	xor 1
	ld (negF),a
	ld a,b
	neg
	ret
Is_Fine:
	ld a,b

	ret
negY:
	.db 0


getPixel:
	ld	d,$00
	ld	h,d
	ld	l,e
	add	hl,de
	add	hl,de
	add	hl,hl
	add	hl,hl
buffer_Offset:
	ld	de,0
	add	hl,de
	ld	b,$00
	ld	c,a
	and	%00000111
	srl	c
	srl	c
	srl	c
	add	hl,bc
	ld	b,a
	inc	b
	ld	a,%00000001
getPixelLoop:
	rrca
	djnz	getPixelLoop
	ret

xRot:	.db 0

yPos:	.db 0
xPos:	.db 0

lastPos: .dw 0


negF:	.db 0

isBackface:	.db 0

Mask_Type:	.db 2

Halve_LOD:	.db 0
