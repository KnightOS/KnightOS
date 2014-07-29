#ifndef __DISPLAY_H
#define __DISPLAY_H

// TODO: It would probably be a good idea to move these to a library instead of including
// them in every binary.

typedef unsigned char SCREEN;

#define ALLOCSCREENBUFFER 0x4B00
#define FASTCOPY 0x2500

SCREEN * create_screen() __naked {
	__asm
	PUSH IY
	CALL ALLOCSCREENBUFFER
	PUSH IY
	POP HL
	POP IY
	RET
	__endasm;
}

inline void fast_copy(SCREEN *screen) __naked {
	__asm
	PUSH IY
	INC SP
	INC SP
	POP IY
	PUSH IY
	CALL FASTCOPY
	DEC SP
	DEC SP
	POP IY
	__endasm;
	screen; // Squelch warning
}

#endif
