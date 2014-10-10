
#define warpMem AppBackupScreen

#define denW		warpMem+0
#define progress	warpMem+1
#define vprogress	warpMem+2
#define warpTextDelay	warpMem+3
#define warpString	warpMem+4	;w
#define wXSpeed		warpMem+6
#define wYSpeed		warpMem+7
#define wtextScroll	warpMem+30	;takes up 14*16 bytes
#define warpTextCount	9

Effect_Field:

	ld hl,Terrain_Back
	ld de,SavesScreen
	ld bc,216
	call RLE

	ld hl,Warp_Text_String-1
	ld (warpString),hl

	ld a,warpTextCount
	ld (warpTextDelay),a

	xor a
	ld hl,wtextScroll
	ld bc,14*16
	bcall(_memset)

	ld (progress),a
	ld (vprogress),a

	ld hl,8+(256*1)
	ld (wXSpeed),hl

Main_Terrain_Loop:
	bcall(_grbufclr)

	ld hl,SavesScreen
	ld de,PlotsScreen+(17*12)
	ld bc,216
	ldir

	ld hl,wtextScroll
	ld de,PlotsScreen

	ld a,16
Copy_Warp_Text:
	ld bc,12
	ldir
	inc hl
	inc hl
	dec a
	jr nz,Copy_Warp_Text

	ld b,32

Warp_Draw_Terrain_Loop:
	push bc
	ld c,b
	ld a,(progress)
	call Scale_Progress
	add a,48

	push af
	ld e,c
	call ionGetPixel
	pop bc

	

	;b = start location of pixel
	;a = start bit mask
	ld c,a
	ld a,b
	pop de
	push de
	ld e,d
	;sra e

	push af
	push hl
	push bc
	push de

	inc a
	inc a
	call Reverse_Inverting_Line

	pop de
	pop bc
	pop hl
	pop af

	ld a,97
	sub b

	call Create_Inverting_Line

	pop bc
	dec b
	ld a,b
	cp 3
	jr nz,Warp_Draw_Terrain_Loop


	;Now draw in the horizontal lines.

	ld hl,PlotsScreen+(63*12)
	ld ix,Terrain_Horiz_LUT

	ld c,29
Horiz_Terrain_Loop:
	ld d,(ix+0)
	ld a,(vprogress)
	add a,d
	and %00010000
	jr z,Skip_Drawing_Horiz_Terrain
	ld b,12
Terrain_Horiz_Invert:
	ld a,(hl)
	xor $FF
	ld (hl),a
	inc hl
	djnz Terrain_Horiz_Invert
	ld de,-24
	jr Set_Horiz_Terrain_Offset	
Skip_Drawing_Horiz_Terrain:
	ld de,-12
Set_Horiz_Terrain_Offset:
	add hl,de
	inc ix
	dec c
	ld a,c
	or a
	jr nz,Horiz_Terrain_Loop
	

	call ionFastCopy
	bcall(_getcsc)
	cp skClear
	ret z

	cp sk2nd
	call z,random_Direction_Set

	ld a,(progress)
	ld b,a
	ld a,(wXSpeed)
	add a,b
	add a,32
	and %00111111
	sub 32
	ld (progress),a

	ld a,(vprogress)
	ld b,a
	ld a,(wYSpeed)
	add a,b
	and %00011111
	ld (vprogress),a

	ld b,16
	ld hl,wtextScroll+13
	call Shift_14_Left
	ld b,16
	ld hl,wtextScroll+13
	call Shift_14_Left


	ld a,(warpTextDelay)
	dec a
	jr nz,Not_Time_Add_Char_Warp
	call Draw_Char_Warp_Text
	ld a,warpTextCount
Not_Time_Add_Char_Warp:
	ld (warpTextDelay),a
	jp Main_Terrain_Loop


Create_Inverting_Line:
	push de
	ld de,31*12
	add hl,de
	pop de

	ld b,a
	ld a,e
	ld (denW),a

	ld d,$FF

	
Create_Inverting_Line_Loop:
	dec b
	ld a,b
	or a
	ret z
	ld a,c
	and d
	or (hl)
	ld (hl),a
	srl c
	jr nc,Not_Overflowed_Byte
	inc hl
	ld c,%10000000
Not_Overflowed_Byte:
	ld a,(denW)
	dec a
	or a
	jr nz,Not_Invert_Colour
	ld a,d
	xor $FF
	ld d,a
	ld a,e
Not_Invert_Colour:
	ld (denW),a
	jr Create_Inverting_Line_Loop



Reverse_Inverting_Line:

	push de
	ld de,31*12
	add hl,de
	pop de

	ld b,a
	ld a,e
	ld (denW),a



	ld d,$00
	

	
Reverse_Inverting_Line_Loop:
	dec b
	ld a,b
	or a
	ret z
	ld a,c
	and d
	or (hl)
	ld (hl),a
	sla c
	jr nc,Not_R_Overflowed_Byte
	dec hl
	ld c,1
Not_R_Overflowed_Byte:
	ld a,(denW)
	dec a
	or a
	jr nz,Not_R_Invert_Colour
	ld a,d
	xor $FF
	ld d,a
	ld a,e
Not_R_Invert_Colour:
	ld (denW),a
	jr Reverse_Inverting_Line_Loop



Scale_Progress:
	or a
	ret z
	push af
	push af
	and %10000000
	jr z,Simple_Scale_Progress
	pop af
	neg
	jr Start_Scale_As_Normal
Simple_Scale_Progress:
	pop af
Start_Scale_As_Normal:
	add a,a
	add a,a
	add a,a
	jr c,Scale_Progress_Full_Value
	ld e,a
	ld d,0
	ld hl,0
	ld a,b
	or a
	jr z,Quit_Scale_Progress
Scale_Progress_Loop:
	add hl,de
	djnz Scale_Progress_Loop
	pop af
	and %10000000
	jr z,Normal_Quit_Scale
	ld a,h
	neg
	ret
Normal_Quit_Scale:
	ld a,h
	ret
Scale_Progress_Full_Value:
	pop af
	ld a,b
	ret
Quit_Scale_Progress:
	pop af
	ret

Draw_Char_Warp_Text:
	ld hl,(warpString)
	inc hl
	ld (warpString),hl
	ld a,(hl)
	or a
	jr nz,Not_Hit_End_Warp_String

	ld hl,Warp_Text_String-1
	ld (warpString),hl
	jr Skip_Drawing_Char_Warp

Not_Hit_End_Warp_String:
	cp ' '
	jr z,Skip_Drawing_Char_Warp
	call Mul_32
	ld de,Big_Letters-('a'*32)
	add hl,de
	ld de,wtextScroll+12
	ld b,16
Copy_Warp_Char_Loop:
	ld a,(hl)
	ld (de),a
	inc hl
	inc de
	ld a,(hl)
	ld (de),a
	inc hl
	push hl
	ld hl,13
	add hl,de
	ld d,h
	ld e,l
	pop hl
	djnz Copy_Warp_Char_Loop	
Skip_Drawing_Char_Warp:
	ld a,warpTextCount
	ld (warpTextDelay),a
	ret

Warp_Text_String:
	.db "here is a nice smooth "
	.db "landscape with a "
	.db "perspective{correct "
	.db "checkerboard effect| "
	.db "do not forget to press "
	.db "{znd{ to change the "
	.db "speed the landscape "
	.db "scrolls past at|||",0

random_Direction_Set:
	ld b,16
	call ionRandom
	sub 8
	ld (wXSpeed),a
	ld b,8
	call ionRandom
	sub 4
	ld (wYSpeed),a
	ret

Terrain_Back:
 .db $91,$00,$04,$18,$00,$00,$03,$E0,$91,$00,$07,$6E,$00,$00,$0D,$10
 .db $00,$60,$91,$00,$05,$AE,$00,$00,$1F,$F8,$00,$B0,$91,$00,$05,$AF
 .db $00,$00,$1F,$FC,$03,$F8,$00,$38,$00,$00,$01,$5B,$80,$00,$3F,$DE
 .db $5F,$FE,$6C,$4C,$00,$00,$02,$AF,$C0,$00,$7F,$FF,$FF,$FF,$D3,$BF
 .db $00,$00,$0E,$AA,$FF,$F8,$FB,$FF,$FF,$EF,$FD,$9F,$80,$00,$DD,$5F
 .db $FF,$DF,$DF,$FF,$FF,$FE,$DC,$4F,$E0,$0B,$2D,$AB,$BE,$91,$FF,$05
 .db $BB,$27,$B8,$5F,$A6,$D6,$91,$FF,$05,$FE,$EF,$DE,$EF,$FD,$8F,$AD
 .db $9F,$91,$FF,$04,$FB,$FD,$EB,$FA,$B6,$C7,$FF,$FF,$FF,$FB,$FF,$FF
 .db $FF,$BF,$B7,$EF,$D8,$EF,$F5,$FF,$FF,$E7,$7F,$FF,$F7,$F7,$FD,$7A
 .db $DB,$65,$DE,$BF,$FF,$FF,$BB,$FF,$FD,$DF,$DE,$FE,$F0,$BF,$7B,$BF
 .db $FF,$DF,$FF,$FF,$FF,$A7,$DF,$FF,$FF,$5F,$7D,$FF,$FF,$F7,$DF,$FF
 .db $FF,$EB,$BF,$FD,$FA,$FA,$FF,$FF,$FF,$FD,$BF,$F7,$6F,$D7,$FF,$FF
 .db $FB,$7F,$DF,$FF,$F7,$F7,$DF,$FF,$F6,$D7

Terrain_Horiz_LUT:
.db	0
.db	0
.db	1
.db	2
.db	3
.db	5
.db	7
.db	9
.db	11
.db	13
.db	15
.db	18
.db	20
.db	23
.db	25
.db	28
.db	31
.db	34
.db	37
.db	40
.db	44
.db	47
.db	51
.db	54
.db	58
.db	61
.db	65
.db	69
.db	73


