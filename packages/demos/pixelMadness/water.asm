; ==================================================================================================
; Constants
; ==================================================================================================

#define textSpacing	18
#define cityDisplay	150

; ==================================================================================================
; Variables
; ==================================================================================================

#define waterMem SavesScreen+(14*32)

Start_Of_Line	=	waterMem+0
Ripple_Val	=	waterMem+2
Scale_Pointer	=	waterMem+3
Char_Space	=	waterMem+5
Ripple_Delay	=	waterMem+6
Dither_Pointer	=	waterMem+7
Dither_Count	=	waterMem+9
Text_Pointer	=	waterMem+10
City_Delay	=	waterMem+12
City_Height	=	waterMem+13
Water_Paused	=	waterMem+14


Start_Water_Effect:
Effect_Water:
	ld a,cityDisplay
	ld (City_Delay),a
	ld a,31
	ld (City_Height),a

main_Loop:
	bcall(_grbufclr)
	ld a,(City_Height)
	or a
	jr z,No_Shift_City_Up
	dec a
	ld (City_Height),a
No_Shift_City_Up:
	ld l,a
	ld h,0
	add hl,hl
	add hl,hl
	ld d,h
	ld e,l
	add hl,hl
	add hl,de
	ld de,PlotsScreen
	add hl,de
	ld d,h
	ld e,l
	ld hl,City
	ld bc,12*32
	call RLE

	call ripple_Reflect
	

	ld a,(City_Delay)
	dec a
	ld (City_Delay),a
	or a
	jr z,Start_Scrolling_Text

	bcall(_getcsc)
	cp skClear
	ret z
	jr main_Loop

Start_Scrolling_Text:
	ld a,textSpacing
	ld (Char_Space),a
	ld hl,SavesScreen
	ld bc,14*32
	xor a
	bcall(_memset)
	ld (Water_Paused),a
	ld hl,Text_String
	ld (Text_Pointer),hl
	ld de,SavesScreen
	ld hl,PlotsScreen
	ld a,32
Copy_City_Loop:
	ld bc,12
	ldir
	inc de
	inc de
	dec a
	or a
	jr nz,Copy_City_Loop

Scrolling_Text_Loop:
	ld hl,SavesScreen
	ld de,PlotsScreen
	ld a,32
Copy_Text_Loop:
	ld bc,12
	ldir
	inc hl
	inc hl
	dec a
	or a
	jr nz,Copy_Text_Loop

	call ripple_Reflect


	ld a,(Water_Paused)
	or a
	jr nz,Do_Not_Pause_Text
	
	ld b,32
	ld hl,SavesScreen+13
	call Shift_14_Left

	ld a,(Char_Space)
	dec a
	ld (Char_Space),a
	or a
	jr nz,Not_Time_To_Add_Char
	ld a,textSpacing
	ld (Char_Space),a
	call Add_Char
Not_Time_To_Add_Char:


Do_Not_Pause_Text:

	bcall(_getcsc)
	cp skClear
	ret z
	cp sk2nd
	jr nz,Scrolling_Text_Loop
	ld a,(Water_Paused)
	xor 1
	ld (Water_Paused),a
	jr Scrolling_Text_Loop
	


Add_Char:
	ld hl,(Text_Pointer)
	ld a,(hl)
	inc hl
	ld (Text_Pointer),hl
	cp ' '
	ret z
	or a
	jr nz,Not_End_Text_List
	pop hl
	jp Start_Water_Effect

Not_End_Text_List:
	call Mul_32
	ld de,Big_Letters-('a'*32)
	add hl,de
	push hl
	ld b,16
	call ionRandom
	add a,a
	ld b,a
	add a,a
	ld c,a
	add a,a
	add a,b
	add a,c
	ld l,a
	ld h,0
	ld de,SavesScreen+12
	add hl,de
	ld d,h
	ld e,l
	pop hl
	ld b,16
Add_Char_Loop:
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
	djnz Add_Char_Loop
	ret

Text_String:
	.db "water scroller { "
	.db "ben ryves { "
	.db "for greenfire| "
	.db "the quick brown fox "
	.db "jumps over the lazy dog { "
	.db "it had to be said|      ",0


