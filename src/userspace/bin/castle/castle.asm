.nolist
#include "kernel.inc"
#include "macros.inc"
#include "libtext.inc"
#include "keys.inc"
#include "defines.inc"
.list
; Header
    .db 0  ; TODO: Thread flags
    .db 50 ; Stack size
; Program
.org 0
start:
    call allocScreenBuffer
    kld de, libtext
    call loadLibrary
resetToHome:
    ld d, 0
    push de
        kcall drawChrome
        kcall drawHome
    pop de
homeLoop:
    kcall drawHomeIcons
    call fastCopy
    
_:  call flushKeys
    call waitKey
    
    cp kRight
    jr z, homeRightKey
    cp kLeft
    jr z, homeLeftKey
    cp kUp
    jr z, homeUpKey
    cp kDown
    jr z, homeDownKey
    cp kZoom
    kjp z, powerMenu
    jr -_
homeRightKey:
    ld a, 9
    cp d
    jr z, -_
    inc d
    jr homeLoop
homeLeftKey:
    xor a
    cp d
    jr z, -_
    dec d
    jr homeLoop
homeUpKey:
    ld a, 4
    cp d
    jr nc, -_
    ld a, d \ sub 5 \ ld d, a
    jr homeLoop
homeDownKey:
    ld a, 4
    cp d
    jr c, -_
    inc a \ add a, d \ ld d, a
    jr homeLoop
    
powerMenu:
	kcall drawPowerMenu
	ld e, 38
powerMenuLoop:
	call fastCopy
	call flushKeys
	call waitKey
	
	cp kUp
	jr z, powerMenuUp
	cp kDown
	jr z, powerMenuDown
	cp k2nd
	jr z, powerMenuSelect
	cp kEnter
	jr z, powerMenuSelect
	cp kClear
	kjp z, resetToHome
	cp kZoom
	kjp z, resetToHome
    
	jr powerMenuLoop
    
powerMenuUp:
	ld a, 38
	cp e
	jr z, powerMenuLoop
	call putSpriteAND
	ld a, e
	ld e, 6
	sub e
	ld e, a
	call putSpriteOR
	jr powerMenuLoop
	
powerMenuDown:
	ld a, 50
	cp e
	jr z, powerMenuLoop
	call putSpriteAND
	ld a, 6
	add a, e
	ld e, a
	call PutSpriteOR
	jr powerMenuLoop
	
powerMenuSelect:
	ld a, e
	cp 44
	jr z, confirmShutDown
	cp 50
	jr z, confirmRestart
	call suspendDevice
	kjp resetToHome
    
confirmShutDown:
	ld hl, boot
	jr confirmSelection
confirmRestart:
	ld hl, reboot
confirmSelection:
	push hl
    kcall drawConfirmationDialog
		
confirmSelectionLoop:
    call fastCopy
    call flushKeys
    call waitKey

    cp kUp
    jr z, confirmSelectionLoop_Up
    cp kDown
    jr z, confirmSelectionLoop_Down
    cp kEnter
    jr z, confirmSelectionLoop_Select
    cp k2nd
    jr z, confirmSelectionLoop_Select
    cp kClear
    kjp z, resetToHome
		
confirmSelectionLoop_Up:
    call putSpriteXOR
    ld de, $2825
    call putSpriteOR
    jr confirmSelectionLoop
		
confirmSelectionLoop_Down:
    call putSpriteXOR
    ld de, $282B
    call putSpriteOR
    jr confirmSelectionLoop

confirmSelectionLoop_Select:
    pop hl
    ld a, $2B
    cp e
    kjp z, resetToHome
    ; Before restarting, shut off the screen for a moment
    ; This was added because some people had the impression
    ; that restarting the calculator didn't do anything
    ld a, 2 \ out (10h), a
    ld b, 255 \ djnz $
    jp (hl)
    
libtext:
    .db "/lib/libtext", 0
    
#include "graphics.asm"