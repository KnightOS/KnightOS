; Calculator boot-up code

boot:
    di
    jr _
shutdown:
    ; TODO: Crash detection
_:  di

    ld a, 6
    out (4), a ; Memory mode 0

    #ifdef CPU15
    ; Set memory mapping
    ; Bank 0: Flash Page 00
    ; Bank 1: Flash Page *
    ; Bank 2: RAM Page 01
    ; Bank 3: RAM Page 00 ; In this order for consistency with TI-83+ and TI-73 mapping
    ld a, $81
    out (7), a
    #else
    ; Set memory mapping
    ; Bank 0: Flash Page 00
    ; Bank 1: Flash Page *
    ; Bank 2: RAM Page 01
    ; Bank 3: RAM Page 00
    ld a, $41
    out (7), a
    #endif

    ld sp, userMemory ; end of kernel garbage

    call Sleep

restart:
reboot:
    di

    ld sp, userMemory ; end of kernel garbage
    
    ; Re-map memory
    ld a, 6
    out (4), a
    #ifdef CPU15
    ld a, $81
    out (7), a
    #else
    ld a, $41
    out (7), a
    #endif

    ; Is this needed?
    ;ld a, 3
    ;out ($E), a
    ;xor a
    ;out ($F), a
    
    ; Manipulate protection states
    #ifdef CPU15 ; TI-83+ SE, TI-84+, TI-84+ SE
    call unlockFlash
        ; Remove RAM Execution Protection
        xor a
        out ($25), a ; RAM Lower Limit ; out (25), 0
        dec a
        out ($26), a ; RAM Upper Limit ; out (26), $FF

        ; Remove Flash Execution Protection
        out ($23), a ; Flash Upper Limit ; out (23), $FF
        out ($22), a ; Flash Lower Limit ; out (22), $FF
    call lockFlash

    ; Set CPU speed to 15 MHz
    ld a, 1
    out ($20), a
    
    #else ; TI-73, TI-83+
    #ifndef TI73 ; RAM does not have protection on the TI-73
    
    ; Remove RAM/Flash protection
    call unlockFlash
        xor a
        out (5), a
        out ($16), a

        ld a, %00000001
        out (5), a
        xor a
        out ($16), a

        ld a, %00000010
        out (5), a
        xor a
        out ($16), a

        ld a, %00000111
        out (5), a
        xor a
        out ($16), a
    call lockFlash
    #endif
    #endif

    ; Set intterupt mode
    ld a, %0001011
    out (3), a

    ; Clear RAM
    ld hl, $8000
    ld (hl), 0
    ld de, $8001
    ld bc, $7FFF
    ldir

    call formatMem
        
    ; Initialize LCD
    ld a, 05h
    call lcdDelay
    out (10h), a ; X-Increment Mode

    ld a, 01h
    call lcdDelay
    out (10h), a ; 8-bit mode

    ld a, 3
    call lcdDelay
    out (10h), a ; Enable screen

    ld a, $17 ; versus $13? TIOS uses $17, and that's the only value that works (the datasheet says go with $13)
    call lcdDelay
    out (10h), a ; Op-amp control (OPA1) set to max (with DB1 set for some reason)

    ld a, $B ; B
    call lcdDelay
    out (10h), a ; Op-amp control (OPA2) set to max

    ld a, $EF
    call lcdDelay
    out (10h), a ; Contrast
    
    ld a, 0
    ld (nextThreadId), a
    ld (nextStreamId), a
    
    ld bc, testThread_end - testThread
    call allocMem
    push ix \ pop de
    ld hl, testThread
    ldir
    push ix \ pop hl
    ld b, 10
    xor a
    call startThread
    
    jp contextSwitch_search
    
testThread:
    ld IY, $9000
    rst $08 ; kcall
    jp testLabel - testThread
    jr $ ; hang forever, should never happen
testLabel:
    inc a
    ld (IY), a
    call fastCopy
    jr testLabel
testThread_end:
    
BufferToLCD:
BufCopy:
FastCopy:
SafeCopy:
    push hl
    push bc
    push af
    push de
    ld a, i
    push af
    di                 ;DI is only required if an interrupt will alter the lcd.
    push iy \ pop hl
    ld c,$10
    ld a,$80
setrow:
    in f,(c)
    jp m,setrow
    out ($10),a
    ld de,12
    ld a,$20
col:
    in f,(c)
    jp m,col
    out ($10),a
    push af
    ld b,64
row:
    ld a,(hl)
rowwait:
    in f,(c)
    jp m,rowwait
    out ($11),a
    add hl,de
    djnz row
    pop af
    dec h
    dec h
    dec h
    inc hl
    inc a
    cp $2c
    jp nz,col
    pop af
    jp po, _
    ei
_:    
    pop de
    pop af
    pop bc
    pop hl
    ret