Shift_Line_Right:
	ld hl,(Start_Of_Line)
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
	rr (hl)
	djnz Shift_Line_Right
	ret

Shift_Line_Left:
	ld hl,(Start_Of_Line)
	ld de,11
	add hl,de
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
	rl (hl)
	djnz Shift_Line_Left
	ret

Shift_14_Left:
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
	rl (hl) \ dec hl
	rl (hl) \ dec hl
	ld de,28
	add hl,de
	djnz Shift_14_Left
	ret