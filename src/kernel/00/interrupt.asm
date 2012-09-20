

sysInterrupt:
	di
	push af
	push bc
	push de
	push hl
	push ix
	push iy
	exx
	ex af, af'
	push af
	push bc
	push de
	push hl
	
#ifdef USB
	jp USBInterrupt
InterruptResume:
#endif
	
	in a, (04h)
	bit 0, a
	jr nz, IntHandleON
	bit 1, a
	jr nz, IntHandleTimer1
	bit 2, a
	jr nz, IntHandleTimer2
	bit 4, a
	jr nz, IntHandleLink
	jr SysInterruptDone
IntHandleON:
	in a, (03h)
	res 0, a
	out (03h), a
	set 0, a
	out (03h), a

	jr SysInterruptDone
IntHandleTimer1:
	in a, (03h)
	res 1, a
	out (03h), a
	set 1, a
	out (03h), a
	; Timer 1 interrupt
		jr SysInterruptDone
IntHandleTimer2:
	in a, (03h)
	res 2, a
	out (03h), a
	set 2, a
	out (03h), a
	; Timer 2 interrupt
	jr SysInterruptDone
IntHandleLink:
	in a, (03h)
	res 4, a
	out (03h), a
	set 4, a
	out (03h), a
	; Link interrupt
SysInterruptDone:
	pop hl
	pop de
	pop bc
	pop af
	exx
	ex af, af'
	pop iy
	pop ix
	pop hl
	pop de
	pop bc
	pop af
	ei
	ret
	
#ifdef USB
USBInterrupt:
	in a, ($55) ; USB Interrupt status
	bit 0, a
	jr z, USBUnknownEvent
	bit 2, a
	jr z, USBLineEvent
	bit 4, a
	jr z, USBProtocolEvent
	jp InterruptResume
	
USBUnknownEvent:
	jp InterruptResume
	
USBLineEvent:
	in a, ($56) ; USB Line Events
	xor $FF
	out ($57), a ; Acknowledge interrupt and disable further interrupts
	jp InterruptResume
	
USBProtocolEvent:
	in a, ($82)
	in a, ($83)
	in a, ($84)
	in a, ($85)
	in a, ($86) ; Merely reading from these will acknowledge the interrupt
	jp InterruptResume
#endif