; Implements some BCALLs that Phoenix needs

_unpackhl_shim:
    push bc
        ld c, 10
        pcall(divHLByC)
    pop bc
    ret
.equ UNPACK_HL _unpackhl_shim

_putc_shim:
    push de
    push bc
        ld b, 0
        kld(de, (_puts_shim_cur))
        pcall(drawChar)
        kld((_puts_shim_cur), de)
        inc hl
    pop bc
    pop de
    ret
putc .equ _putc_shim

_puts_shim:
    push af
_:      ld a, (hl)
        inc hl
        or a
        jr z, _
        kcall(_putc_shim)
        jr -_
_:  pop af
    ret
_puts_shim_cur:
    .dw 0
puts .equ _puts_shim

_clrlcdf_shim:
    pcall(clearBuffer)
    ld hl, 0
    kld((_puts_shim_cur), hl)
    ret
CLEARLCD .equ _clrlcdf_shim

_disphl_shim:
    kld(de, (_puts_shim_cur))
    pcall(drawHexHL) ; TODO: Do this in decimal
DispHL .equ _disphl_shim

; HL: num
; E: Y pos
drawDecNum:
    ld d, 96 - 11
    push bc
        ld b, 0
_:      ld c, 10
        pcall(divHLbyC)
        add a, '0'
        pcall(drawChar)
        ld a, -8
        add a, d
        ld d, a
        ld c, 0
        pcall(cpHLBC)
        jr nz, -_
    pop bc
    ret
