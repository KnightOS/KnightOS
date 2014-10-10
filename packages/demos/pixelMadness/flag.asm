; ==================================================================================================
; Variables
; ==================================================================================================

#define flagMem	AppBackupScreen

column		=	flagMem+0
steps		=	flagMem+1
shift_byte	=	flagMem+2	;w
start_word	=	flagMem+4	;w
copy_word	=	flagMem+6	;w
scale_val_f	=	flagMem+8
scale_inc	=	flagMem+9
text_pos	=	flagMem+10	;w
text_Inc_Count	=	flagMem+12


#define textDelay 100

#define textScrollFlag


Effect_Flag:

	set textWrite,(iy+sGrFlags)

	xor a
	ld (scale_val_f),a
	ld a,1
	ld (scale_inc),a
	ld hl,Flag_Text
	ld (text_pos),hl

	ld hl,0
	ld (text_Inc_Count),hl

Flag_Loop:

	bcall(_grbufclr)
	ld hl,(text_pos)
	ld a,(hl)
	ld hl,5
	ld (penCol),hl
	bcall(_vputmap)

	ld bc,SavesScreen


	ld a,5

	
	ld ix,PlotsScreen+12
Not_Hit_Bottom_Char_Yet:
	push af
		ld l,(ix+0)
		ld a,(ix+0)
		add a,a
		add a,l
		ld l,a
		ld h,0
		ld de,Text_Expander
		add hl,de

		ld a,8
Scale_Vert_Char:
		push hl
			ld d,b
			ld e,c
			push bc
				ld bc,3
				ldir
				pop hl
			ld de,3
			add hl,de
			ld b,h
			ld c,l
			pop hl
		dec a
		or a
		jr nz,Scale_Vert_Char
		push bc
			ld b,12
Scan_Next_Row_Char:
			inc ix
			djnz Scan_Next_Row_Char
			pop bc
		pop af
	dec a
	or a
	jr nz,Not_Hit_Bottom_Char_Yet



	di
	ld hl,Flag
	ld de,PlotsScreen
	ld bc,768
	call RLE

#ifdef textScrollFlag

	ld ix,SavesScreen
	ld h,32
	ld l,12
	push hl
	dec h
	dec h
	dec l
	dec l
	push hl
	ld a,h
	add a,4
	ld h,a
	push hl
	ld a,l
	add a,4
	ld l,a
	push hl
	ld a,h
	sub 4
	ld h,a
	
	ld a,h
	ld ix,SavesScreen
	ld bc,((8*5)*256)+3
	call largeORSprite

	pop hl
	ld a,h
	ld ix,SavesScreen
	ld bc,((8*5)*256)+3
	call largeORSprite

	pop hl
	ld a,h
	ld ix,SavesScreen
	ld bc,((8*5)*256)+3
	call largeORSprite

	pop hl
	ld a,h
	ld ix,SavesScreen
	ld bc,((8*5)*256)+3
	call largeORSprite

	pop hl
	ld a,h
	ld ix,SavesScreen
	ld bc,((8*5)*256)+3
	call ionLargeSprite

#endif


	call Inc_Text_Counter
	call Inc_Text_Counter
	call Inc_Text_Counter
	call Inc_Text_Counter
	call Inc_Text_Counter

	ld a,11
	ld (column),a

	ld hl,Flag_Wave
Vertical_Shift_Loop:
	push hl
	ld a,(hl)
	or a
	jr z,Shifted_Vertical_Flag
	and %10000000
	jr nz,Is_Shift_Up
	ld a,(hl)
	call scale_Shift
	ld a,(column)
	call Shift_Column_Down
	jr Shifted_Vertical_Flag
Is_Shift_Up:
	ld a,(hl)
	and %01111111
	call scale_Shift
	ld a,(column)
	call Shift_Column_Up
Shifted_Vertical_Flag:
	pop hl
	inc hl
	ld a,(column)
	dec a
	ld (column),a
	cp -1
	jr nz,Vertical_Shift_Loop

	ld a,7
	ld (column),a
	ld hl,Flag_Wave
Horizontal_Shift_Loop:
	push hl
	ld a,(hl)
	or a
	jr z,Shifted_Horizontal_Flag
	and %10000000
	jr nz,Is_Row_Up
	ld a,(hl)
	call scale_Shift
	ld a,(column)
	call Shift_Row_Down
	jr Shifted_Horizontal_Flag
Is_Row_Up:
	ld a,(hl)
	and %01111111
	call scale_Shift
	ld a,(column)
	call Shift_Row_Up
Shifted_Horizontal_Flag:
	pop hl
	inc hl
	ld a,(column)
	dec a
	ld (column),a
	cp -1
	jr nz,Horizontal_Shift_Loop


	call ionFastCopy

	;SCROLL THE WAVE TABLE
	ld a,(Flag_Wave)
	ld hl,Flag_Wave+1
	ld de,Flag_Wave
	ld bc,Flag_Wave_End-Flag_Wave-1
	ldir
	ld (Flag_Wave_End-1),a

	;CHANGE THE SCALING OF THE FLAG WAVE

	ld a,(scale_val_f)
	ld b,a
	ld a,(scale_inc)
	add a,b
	ld (scale_val_f),a
	or a
	jr nz,No_Toggle_Inc_Flag
	ld a,(scale_inc)
	neg
	ld (scale_inc),a
	ld b,a
	ld a,(scale_val_f)
	add a,b
	ld (scale_val_f),a
No_Toggle_Inc_Flag:

	ld a,(text_Inc_Count)
	cp textDelay
	jr c,Not_Time_Advance_Text
	xor a
	ld (text_Inc_Count),a

	ld hl,(text_pos)
	inc hl
	ld a,(hl)
	or a
	jr nz,Not_End_Of_Text
	ld hl,Flag_Text	
Not_End_Of_Text:
	ld (text_pos),hl
Not_Time_Advance_Text:

	bcall(_getcsc)
	cp skClear
	ret z
	jp Flag_Loop

	ret

	
Shift_Column_Up:
	ld a,c
	or a
	ret z
	ld hl,12
	ld (shift_byte),hl
	ld hl,PlotsScreen
	call get_Start_Locations
	ld (start_word),hl
	ld (copy_word),de
	jr Shift_Column
Shift_Column_Down:
	ld a,c
	or a
	ret z
	ld hl,-12
	ld (shift_byte),hl
	ld hl,PlotsScreen+(768-12)
	call get_Start_Locations
	ld (start_word),de
	ld (copy_word),hl
Shift_Column:
	ld b,63
	ld hl,(start_word)
	ld de,(copy_word)
Shift_Column_Loop:
	ld a,(hl)
	ld (de),a
	push hl
	ld hl,(shift_byte)
	add hl,de
	ld d,h
	ld e,l
	pop hl
	push de
	ld de,(shift_byte)
	add hl,de
	pop de
	djnz Shift_Column_Loop
	call Inc_Text_Counter
	dec c
	ld a,c
	or a
	jr nz,Shift_Column

	ret
get_Start_Locations:
	ld de,(column)
	ld d,0
	add hl,de
	push hl
	ld de,12
	add hl,de
	pop de
	ret

scale_Shift:
	push hl
	push de

	ld d,0
	ld e,a

	ld a,(scale_val_f)
	or a
	jr z,Done_Scale_Flag
	ld b,a
	ld d,0
	ld hl,0
Scale_Flag_Loop:
	add hl,de
	djnz Scale_Flag_Loop
	ld c,h
Done_Scale_Flag:


	pop de
	pop hl
	ret


Shift_Row_Up:
	ld a,c
	or a
	ret z
	call get_Row_Offset
	ld b,8
Shift_Row_Up_Loop:
	xor a
	rr (hl) \ inc hl
	rr (hl) \ inc hl
	rr (hl) \ inc hl
	rr (hl) \ inc hl
	rr (hl) \ inc hl
	rr (hl) \ inc hl
	rr (hl) \ inc hl
	rr (hl) \ inc hl
	rr (hl) \ inc hl
	rr (hl) \ inc hl
	rr (hl) \ inc hl
	rr (hl) \ inc hl
	djnz Shift_Row_Up_Loop
	dec c
	ld a,c
	or a
	jr nz,Shift_Row_Up
	ret

Shift_Row_Down:
	ld a,c
	or a
	ret z
	call get_Row_Offset
	ld de,95
	add hl,de
	ld b,8
Shift_Row_Down_Loop:
	xor a
	rl (hl) \ dec hl
	rl (hl) \ dec hl
	rl (hl) \ dec hl
	rl (hl) \ dec hl
	rl (hl) \ dec hl
	rl (hl) \ dec hl
	rl (hl) \ dec hl
	rl (hl) \ dec hl
	rl (hl) \ dec hl
	rl (hl) \ dec hl
	rl (hl) \ dec hl
	rl (hl) \ dec hl
	djnz Shift_Row_Down_Loop
	dec c
	ld a,c
	or a
	jr nz,Shift_Row_Down
	ret

get_Row_Offset:
	ld hl,(column)
	ld h,0
	add hl,hl	;*2
	add hl,hl	;*4
	add hl,hl	;*8
	add hl,hl	;*16
	add hl,hl	;*32
	ld d,h
	ld e,l		;de = a*32
	add hl,hl	;*64
	add hl,de	;hl=a*96
	ld de,PlotsScreen
	add hl,de
	ret

Inc_Text_Counter:
	ld a,(text_inc_count)
	inc a
	or a
	ret z
	ld (text_inc_count),a
	ret

Text_Expander:
.db $00,$00,$00
.db $00,$00,$FF
.db $00,$FF,$00
.db $00,$FF,$FF
.db $FF,$00,$00
.db $FF,$00,$FF
.db $FF,$FF,$00
.db $FF,$FF,$FF

Flag_Wave:
.db 	0
.db 	2
.db 	4
.db 	5
.db 	4
.db 	3
.db 	0
.db 	130
.db 	132
.db 	133
.db 	132
.db 	131
Flag_Wave_End:

Flag_Text:
	;LWR - not i, m, w, z
	.db "ONCE AGAIN I KILL YOUR EYES, "
	.db "THIS TIME WITH A FUNKY FLAG "
	.db "STYLE DEMO - "
	.db "SORRY ABOUT THE WAY YOU HAVE "
	.db "TO READ THE TEXT. YOU WILL "
	.db "GET USED TO IT! "
	.db "1-2-3- IT IS TIME TO "
	.db "LOOP. BYE! ",0
