; Waits for a key to be pressed, then returns it
waitKey:
_:  call HasKeypadLock
    jr nz, -_
_:  call getKey
    or a
    jr z, -_
    ret
	
; Waits for all keys to be released
flushkeys:
    call HasKeypadLock
    ret nz
    push af
    push bc
    ; Done in a loop; runs far too fast on actual hardware
        ld b, $80
_:      xor a
        out (1), a
        nop \ nop
        in a, (1)
        inc a
        jr nz, -_
        djnz -_
    pop bc
    pop af
    ret

getKey:
    call HasKeypadLock
    jr _
    xor a
    ret
_:  push bc
    ld a, i
    push af
    push de
    push hl
gs_GetK2:
    ld b,7
gs_GetK_loop:
    ld a,7
    sub b
    ld hl,gs_keygroups
    ld d,0 \ ld e,a
    add hl,de
    ld a,(hl)
    ld c,a

    ld a,0ffh
    out (1),a
    ld a,c
    out (1),a
    nop \ nop \ nop \ nop
    in a,(1)

    ld de,0
    cp 254 \ jr z,gs_GetK_254
    cp 253 \ jr z,gs_GetK_253
    cp 251 \ jr z,gs_GetK_251
    cp 247 \ jr z,gs_GetK_247
    cp 239 \ jr z,gs_GetK_239
    cp 223 \ jr z,gs_GetK_223
    cp 191 \ jr z,gs_GetK_191
    cp 127 \ jr z,gs_GetK_127

gs_GetK_loopend:
    djnz gs_GetK_loop

    xor a
    ld (kernelGarbage),a
    jr gs_GetK_end
gs_GetK_127:
    inc e
gs_GetK_191:
    inc e
gs_GetK_223:
    inc e
gs_GetK_239:
    inc e
gs_GetK_247:
    inc e
gs_GetK_251:
    inc e
gs_GetK_253:
    inc e
gs_GetK_254:
    push de
        ld a,7
        sub b
        add a,a \ add a,a \ add a,a
        ld d,0 \ ld e,a
        ld hl,gs_keygroup1
        add hl,de
    pop de
    add hl,de
    ld a,(hl)

    ld d,a
    ld a,(kernelGarbage)
    cp d \ jr z,gs_getK_end
    ld a,d
    ld (kernelGarbage),a
    
gs_GetK_end:
    pop hl
    pop de
    ld b, a
    pop af
    jp po, _
    ei
_:  ld a, b
    pop bc
    ret

gs_keygroups:
    .db $FE, $FD, $FB, $F7, $EF, $DF, $BF
gs_keygroup1:
    .db $01, $02, $03, $04, $00, $00, $00, $00
gs_keygroup2:
    .db $09, $0A, $0B, $0C, $0D, $0E, $0F, $00
gs_keygroup3:
    .db $11, $12, $13, $14, $15, $16, $17, $00
gs_keygroup4:
    .db $19, $1A, $1B, $1C, $1D, $1E, $1F, $20
gs_keygroup5:
    .db $21, $22, $23, $24, $25, $26, $27, $28
gs_keygroup6:
    .db $00, $2A, $2B, $2C, $2D, $2E, $2F, $30
gs_keygroup7:
    .db $31, $32, $33, $34, $35, $36, $37, $38