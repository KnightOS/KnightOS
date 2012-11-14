; Calculator boot-up code
#include "keys.inc"

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

    call suspendDevice

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

    ; Set CPU speed to 15 MHz ; TODO: This doesn't work in WabbitEmu?
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

    #ifdef USB
    ld a, $EF
    #else
    #ifdef TI73
    ld a, $FB
    #else
    ld a, $F4
    #endif
    #endif
    ld (currentContrast), a
    call lcdDelay
    out (10h), a ; Contrast
    
    ; Configure filesystem memory
    ld hl, 0
    ld (CurrentDirectoryID), hl
    ld (EndOfTableAddress), hl
    ld (EndOfDataPage), hl
    ld (EndOfDataAddress), hl

    ld a, AllocTableStart
    out (6), a
    ld hl, $7FFF
Boot_FileSystemConfigLoop:
    ld a, (hl)
    dec hl
    ld c, (hl)
    dec hl
    ld b, (hl)
    dec hl
    cp FSDirectory
    jr z, Boot_FileSystemConfig_Dir
    cp FSDeletedDirectory
    jr z, Boot_FileSystemConfig_Dir
    cp FSFile
    jr z, Boot_FileSystemConfig_File
    cp FSDeletedFile
    jr z, Boot_FileSystemConfig_File
    cp FSModifiedFile
    jr z, Boot_FileSystemConfig_File
    cp FSEndOfPage
    jr z, Boot_FileSystemConfig_EoP
    cp FSEndOfTable
    jr z, Boot_FileSystemConfig_EoT

    or a
    sbc hl, bc
    inc hl
    jr Boot_FilesystemConfigLoop

Boot_FileSystemConfig_Dir:
    push hl
    push bc
    dec hl \ dec hl
    ld c, (hl)
    dec hl
    ld b, (hl)

    ld hl, (CurrentDirectoryID)
    call CpHLBC
    jr nc, _
    push bc \ pop hl
    ld (CurrentDirectoryID), hl ; Update the current directory ID if needed
_:
    pop bc
    pop hl

    or a
    sbc hl, bc
    inc hl
    jr Boot_FileSystemConfigLoop

Boot_FileSystemConfig_File:
    push hl
    push bc
    dec hl \ dec hl
    dec hl
    ld c, (hl)
    dec hl
    ld b, (hl)
    dec hl
    ld d, (hl) ; TODO: Handle files larger than 0x4000 bytes
    dec hl

    push bc
    ld a, (hl)
    ld b, a
    ld a, (EndOfDataPage)
    cp b
    jr nc, _
    ld a, b
    ld (EndOfDataPage), a
_:
    pop bc

    dec hl
    ld e, (hl)
    dec hl
    ld d, (hl)

    ex de, hl
    add hl, bc
    ex de, hl

    ld hl, (EndOfDataAddress)
    call CpHLDE
    jr nc, _
    push de \ pop hl
    ld (EndOfDataAddress), hl
_:
    pop bc
    pop hl
    or a
    sbc hl, bc
    inc hl
    jp Boot_FileSystemConfigLoop

Boot_FileSystemConfig_EoP:
    in a, (6)
    dec a
    out (6), a
    jp Boot_FileSystemConfigLoop

Boot_FileSystemConfig_EoT:
    inc hl \ inc hl \ inc hl
    ld (EndOfTableAddress), hl
    in a, (6)
    ld (EndOfTablePage), a
    
    ; Good place to test kernel routines
    
    ; ...
    
    ; /Good place to test kernel routines
    
    ld a, 0
    ld (nextThreadId), a
    ld (nextStreamId), a
    
    ld de, bootFile
    call launchProgram
    
    jp contextSwitch_search
    
bootFile:
    .db "/bin/init", 0