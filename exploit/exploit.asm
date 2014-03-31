; This is a somewhat modified version of BrandonW's fakesign exploit.

; It is this code's responsibility to:
;	Restore sectors F0 and F4 from backup (E4 and EB).
;	Erase sectors E4 and EB.
;	Mark the OS as valid (both at 0056h and in the certificate).
;	Reboot with RAM page 1 unhooked
;	  (as the boot code does, which tells the OS this is the initial boot).
.equ curRow 0x8459
.equ tempSwapArea 0x8B8C
.equ _dispBootVer 0x808A
.equ _WriteAByteSafe 0x80C6
.equ _WriteFlashSafe 0x80C9
.equ _EraseFlash 0x8024
.equ _MarkOSValid 0x8099
.org 0x0A60B
    ;Find the first "ret" on the boot page, for the flash writing/erasing routines
    ld hl, 0x4000
    ld a, 0xC9
    ld b, h
    ld c, l
    cpir
    dec hl
    ld (location_ret), hl

    ;Clear LCD and display status message
    ld hl, 0
    ld (curRow), hl
    ld bc, 10 * 26
clearLoop:
    push bc
    ld a, ' '
    call PutC
    pop bc
    dec bc
    ld a, b
    or c
    jr nz, clearLoop
    ld hl, 0
    ld (curRow), hl
    ld hl, sCleaningUp
    call PutS

    ;Erase sectors F0 and F4
#ifdef TI84pCSE
    ld a, 0xF0
#else
    ld a, 0x70
#endif
    ld hl, 0x4000
    call EraseFlash
    call UpdateProgress
#ifdef TI84pCSE
    ld a, 0xF4
#else
    ld a, 0x74
#endif
    ld hl, 0x4000
    call EraseFlash
    call UpdateProgress

    ;Copy data from pages E4-EB to F0-F7
#ifdef TI84pCSE
    ld a, 0xE4
    ld b, 0xF0
#else
    ld a, 0x64
    ld b, 0x70
#endif
    ld c, 8
copyLoop:
    push af
    push bc
    call CopyFlashPage
    call UpdateProgress
    pop bc
    pop af
    inc a
    inc b
    dec c
    jr nz,copyLoop
    call UpdateProgress

    ;Erase sectors E4 and E8
#ifdef TI84pCSE
    ld a, 0xE4
#else
    ld a, 0x74
#endif
    ld hl, 0x4000
    call EraseFlash
    call UpdateProgress
#ifdef TI84pCSE
    ld a, 0xE8
#else
    ld a, 0x78
#endif
    ld hl, 0x4000
    call EraseFlash
    call UpdateProgress

    ;Mark OS valid
    xor a
    ld de, 0x0056
    ld b, 0x5A
    call WriteAByte
    call UpdateProgress
    call MarkOSValid
    call UpdateProgress

    ;Set final OS valid marker
    ;Any boot code display routines after this will relock flash back.
    xor a
    ld de, 0x0026
    ld b, 0
    call WriteAByte

    ;Boot
    xor a
    out (7), a
    jp 0x0053

CopyFlashPage:
    ld c, a
    in a, (6)
    push af
    in a, (0xE)
    push af
    ld a, c
    ld de, 0x4000
cfpLoop:
    push af
    push bc
    bit 7, a
    res 7, a
    out (6), a
    ld a, 1
    jr nz, cfp1
    xor a
cfp1:
    out (0xE), a
    ld hl, tempSwapArea
    push hl
    ex de, hl
    push hl
    ld bc, 128
    push bc
    ldir
    pop bc
    pop de
    pop hl
    ld a, 0x7F
    out (6), a
    ld a, 1
    out (0xE), a
    pop af
    push af
    push de
    push bc
    call WriteFlash
    pop de
    pop hl
    add hl, de
    ex de, hl
    pop bc
    pop af
    bit 7, d
    jr z, cfpLoop
    pop af
    out (0xE), a
    pop af
    out (6), a
    ret

PutS:
    ld a, (hl)
    inc hl
    or a
    ret z
    call PutC
    jr PutS

UpdateProgress:
    push af
    push bc
    push de
    push hl
    push ix
    ld a, '.'
    call PutC
    pop ix
    pop hl
    pop de
    pop bc
    pop af
    ret

ldhlind:
    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a
    ret
DispHexHL:
    push af
    ld a, h
    call DispHexA
    ld a, l
    call DispHexA
    pop af
    ret
DispHexA:
    push af
    push hl
    push bc
    push af
    rrca
    rrca
    rrca
    rrca
    call dispha
    pop af
    call dispha
    pop bc
    pop hl
    pop	af
    ret
dispha:
    and 15
    cp 10
    jp nc, dhlet
    add a, 48
    jp dispdh
dhlet:
    add a, 55
dispdh:
    jp PutC
PutC:
    push hl
    push af
    ld hl, _dispBootVer - 0x4000
    call ldhlind
    ld de, 10
    add hl, de
    call ldhlind
    ld a, 0xCD
    ld b, a
    ld c, a
    cpir
    call ldhlind
    push hl
    pop ix
    pop af
    pop hl
    jp (ix)
WriteAByte:
    ld ix, (location_ret)
    push ix
    push ix
    ld ix, _WriteAByteSafe - 0x4000
    ex (sp), hl
    ld l, (ix + 0)
    ld h, (ix + 1)
    ex (sp), hl
    ret
WriteFlash:
    ld ix, (location_ret)
    push ix
    push ix
    ld ix, _WriteFlashSafe - 0x4000
    ex (sp), hl
    ld l, (ix + 0)
    ld h, (ix + 1)
    ex (sp), hl
    ret
EraseFlash:
    ld ix, (location_ret)
    push ix
    push ix
    ld ix, _EraseFlash - 0x4000
    ex (sp), hl
    ld l, (ix + 0)
    ld h, (ix + 1)
    ex (sp), hl
    ret
MarkOSValid:
    ld ix, (location_ret)
    push ix
    push ix
    ld ix, _MarkOSValid - 0x4000
    ex (sp), hl
    ld l, (ix + 0)
    ld h, (ix + 1)
    ex (sp), hl
    ret

sCleaningUp:
    .db "Preparing, please wait...",0
location_ret:
    .dw 0
