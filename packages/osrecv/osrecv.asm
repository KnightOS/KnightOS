; UOSRECV - Unsigned OS Receiver
; Originally by BrandonW, ported to KnightOS
; Included in the base package for 84+, 84+ SE, and 84+ CSE
; Run `osrecv` to receive an unsigned OS
; TODO: Make this work on 73, 83+, and 83+ SE

#define BOOT0_RAM_PAGE 0x87
#define BOOT1_RAM_PAGE 0x80

#ifdef TI84pCSE
#define BOOT0_ROM_PAGE 0xFF
#define BOOT1_ROM_PAGE 0xFD
#else
#define BOOT0_ROM_PAGE 0x7F
#define BOOT1_ROM_PAGE 0x6F
#endif

#define JUMP0_START 0x401A
#define JUMP0_END   0x40D4
#define JUMP1_START 0x40E6
#define JUMP1_END   0x412B

#include <kernel.inc>
.db 0, 20
.org 0
start:
    pcall(getLcdLock)
    di
    ; Move executable to 0x9D95 so we don't have to relocate everything
    kld(hl, start)
    ld de, 0x9D95
    ld bc, end - start
    ldir
    jp 0x9D95 + tiosStart
tiosStart:
    .org 0x9D95 + tiosStart
    ld iy, 0x9340 ; plotSScreen on TIOS
    ld hl, (kernelGarbage)
    ld (kernelGarbage + 1), hl

    ; Display unlocking message
.macro showMessage(string)
    push hl
    push de
        pcall(clearBuffer)
        ld hl, string
        ld de, 0
        ld b, 0
        pcall(drawStr)
        pcall(fastCopy)
    pop de
    pop hl
.endmacro
    showMessage(sUnlocking)

    pcall(unlockFlash)

    ; Display "preparing" message
    showMessage(sPreparing)

    ; Copy the first boot page to RAM
    ld a, BOOT0_ROM_PAGE
    call outputPage
    ld a, BOOT0_RAM_PAGE & 0x7F
    out (5), a
    ld hl, 0x4000
    ld de, 0xC000
    ld bc, 0x4000
    ldir

    ; Copy the second boot page to RAM
    ld a,BOOT1_ROM_PAGE
    call outputPage
    ld a, BOOT1_RAM_PAGE & 0x7F
    out (5), a
    ld hl, 0x4000
    ld de, 0xC000
    ld bc, 0x4000
    ldir
    xor a
    out (5),a

#ifndef TI84pCSE
    ; Copy replacement USB "zone 1 RAM" routines to the start of the second boot page (which contains 0xFFs,
    ; because of the BCALL jump table in the same location on the first boot page)
    ld sp, 0x8100
    ld a, BOOT1_RAM_PAGE | 0x80
    out (6), a
    call FindEmptyBlock
    ld hl, 0x4000
    or a
    sbc hl, bc
    ld de, 0x4000
    add hl, de
    ld ix, USBBufferReadCodeOffset + 1
    ld (ix), l
    ld (ix + 1), h
    ld ix, USBBufferWriteCodeOffset + 1
    ld (ix), l
    ld (ix + 1), h
    ld hl, USBBufferCodeStart
    ld de, 0x4000
    ld bc, USBBufferCodeEnd-USBBufferCodeStart
    ldir
#endif

    ; HACK: This is assuming that the second boot page still has enough room at the end for the hardware stack
    ; (which is the case on every version I've ever seen)
    ld sp, 0

    ;Patch the boot page BCALL jump table
    ld a, BOOT0_RAM_PAGE | 0x80
    out (6), a
    call FixJumpTableEntries

    ;Apply patches to first boot page
    call ApplyPatches

    ;Apply patches to second boot page
    ld a, BOOT1_RAM_PAGE | 0x80
    out (6), a
    call ApplyPatches

#ifndef TI84PCSE
    ; Patch the USB "zone 1 RAM" routines to use the empty space towards the end of the boot page (between end of code and hardware stack)
    ld ix, bufferReadPattern
    ld de, 0x412C ; safe place beyond jump table and replacement routines
    call FindPattern
    jr nz, skipReadPattern
    ld hl, (kernelGarbage) ; Important?
    ld (hl), 0xC3
    inc hl
    ld (hl), (USBBufferReadCode-USBBufferCodeStart+0x4000) & 0xFF
    inc hl
    ld (hl), (USBBufferReadCode-USBBufferCodeStart+0x4000) >> 8
skipReadPattern:
    ld ix, bufferWritePattern
    ld de, 0x412C ; safe place beyond jump table and replacement routines
    call FindPattern
    jr nz, skipWritePattern
    ld hl, (kernelGarbage)
    ld (hl), 0xC3
    inc hl
    ld (hl), (USBBufferWriteCode-USBBufferCodeStart+0x4000) & 0xFF
    inc hl
    ld (hl), (USBBufferWriteCode-USBBufferCodeStart+0x4000) >> 8
skipWritePattern:
#endif

    ;Jump into the boot code for receiving the OS
    ld a, BOOT0_RAM_PAGE | 0x80
    out (6), a
    ld hl, (kernelGarbage + 1) ; Important?
    ld de, jumpPointPatternEnd - jumpPointPattern
    add hl, de
    di
    jp (hl)

bufferReadPattern:
    xor a
    out (0x0F), a
    ld a,b
    sla a
    out (5), a
    inc a
    or 0x80
    out (7), a
    ld b, (hl)
    .db 0xFF
bufferWritePattern:
    xor a
    out (0x0F), a
    ld a, b
    pop bc
    sla a
    out (5), a
    inc a
    or 0x80
    out (7), a
    ld a, b
    ld (de), a
    .db 0xFF
USBBufferCodeStart:
USBBufferReadCode:
    push hl
    push de
USBBufferReadCodeOffset:
    ld de, 0
    add hl, de
    ld a, (hl)
    pop de
    pop hl
    ret
USBBufferWriteCode:
    pop bc
    push hl
    push de
USBBufferWriteCodeOffset:
    ld hl, 0
    add hl, de
    ex de, hl
    ld a, b
    ld (de), a
    pop de
    pop hl
    ret
USBBufferCodeEnd:
sError:
    .db "Error!", 0
sUnlocking:
    .db "Unlocking Flash...", 0
sPreparing:
    .db "Preparing to receive OS...\n\nUOSRECV by BrandonW", 0
; We'll want to jump just beyond here (past the valid OS check) and start receiving the OS.
jumpPointPattern:
    ld hl, (0x0056)
    ld bc, 0xA55A
    or a
    sbc hl, bc
    jp z, 0x0053
jumpPointPatternEnd:
    .db 0xFF
PatchTable:
    .db OldCode1End - OldCode1Start
    .dw OldCode1Start
    .dw NewCode1
    .db OldCode2End - OldCode2Start
    .dw OldCode2Start
    .dw NewCode2
    .db OldCode3End - OldCode3Start
    .dw OldCode3Start
    .dw NewCode3
    .db OldCode4End - OldCode4Start
    .dw OldCode4Start
    .dw NewCode4
    .db OldCode5End - OldCode5Start
    .dw OldCode5Start
    .dw NewCode5
    .db OldCode6End - OldCode6Start
    .dw OldCode6Start
    .dw NewCode6
    .db OldCode7End - OldCode7Start
    .dw OldCode7Start
    .dw NewCode7
    .db OldCode8End - OldCode8Start
    .dw OldCode8Start
    .dw NewCode8
    .db OldCode9End - OldCode9Start
    .dw OldCode9Start
    .dw NewCode9
    .db OldCode10End - OldCode10Start
    .dw OldCode10Start
    .dw NewCode10
    .db OldCode11End - OldCode11Start
    .dw OldCode11Start
    .dw NewCode11
    .db OldCode12End - OldCode12Start
    .dw OldCode12Start
    .dw NewCode12
    .db OldCode13End - OldCode13Start
    .dw OldCode13Start
    .dw NewCode13
    .db OldCode14End - OldCode14Start
    .dw OldCode14Start
    .dw NewCode14
    .db OldCode15End - OldCode15Start
    .dw OldCode15Start
    .dw NewCode15
    .db 0
; Remove the security checks to ensure we're running on a boot page (non-84+ only).
OldCode1Start:
    in a, (6)
    and 0x7F
    cp 0x7F
OldCode1End:
    .db 0xFF
NewCode1:
    in a, (6)
    xor a \ nop
    nop \ nop
; Remove the security checks to ensure we're running on a boot page (84+ only).
; This can't be merged with the above patch without modifying the FindPattern
; routine to use something other than 0FEh as a wildcard (since that's the "cp" opcode).
OldCode11Start:
    in a, (6)
    and 0x3F
    cp 0x3F
OldCode11End:
    .db 0xFF
NewCode11:
    in a, (6)
    xor a \ nop
    nop \ nop
; Patch the code that swaps in the first boot page.
OldCode2Start:
    ld a, BOOT0_ROM_PAGE & 0x7F
    out (6), a
OldCode2End:
    .db 0xFF
NewCode2:
    ld a, BOOT0_RAM_PAGE | 0x80
    out (6), a
; Patch the code that swaps in the second boot page.
OldCode3Start:
    ld a, BOOT1_ROM_PAGE & 0x7F
    out (6), a
OldCode3End:
    .db 0xFF
NewCode3:
    ld a, BOOT1_RAM_PAGE | 0x80
    out (6), a
; Patch out the BCALL/BJUMP code that assumes we're swapping in a Flash page.
OldCode4Start:
    ld a, (de)
    ld (hl), a
    inc de
    ld a, (de)
    and 0xFE
    pop de
    pop bc
OldCode4End:
    .db 0xFF
NewCode4:
    ld a, (de)
    ld (hl), a
    inc de
    ld a, (de)
    nop \ nop
    pop de
    pop bc
; Remove the writes to port 0x14, in case the RAM pages have the ability to lock Flash back.
; I don't think they can, but you never know.
OldCode5Start:
    out (0x14), a
OldCode5End:
    .db 0xFF
NewCode5:
    nop \ nop
; Patch the second boot page's ability to return to the first so it works correctly (non-84+ only).
OldCode6Start:
    ld a, 0x7F
    jp 0x40D5
OldCode6End:
    .db 0xFF
NewCode6:
    ld a, BOOT0_RAM_PAGE | 0x80
    jp 0x40D5
; Patch the second boot page's ability to return to the first so it works correectly (84+ only).
; This can probably be merged with the above patch.
OldCode10Start:
    ld a, 0x3F
    jp 0x40D5
OldCode10End:
    .db 0xFF
NewCode10:
    ld a, BOOT0_RAM_PAGE | 0x80
    jp 0x40D5
; Remove the stupid 6-7 minute 2048-bit RSA security check.
OldCode7Start:
    call 0xFEFE
    ret nz
    call 0xFEFE
    ld hl, 0x4000
    ld de, 0x8000
    ld bc, 0x100
    ld a, 0xFA
OldCode7End:
    .db 0xFF
NewCode7:
    xor a
    ret
; Reset the hardware stack to the highest possible value (we need all we can get).
OldCode8Start:
    ld sp, 0xFFC5
OldCode8End:
    .db 0xFF
NewCode8:
    ld sp, 0xFFFF
; Only wipe out RAM page 0x81 (system RAM), because we need the last page for the second boot page.
OldCode9Start:
    ld hl, 0x8000
    ld de, 0x8001
    ld bc, 0xFEFE
    ld (hl), 0
    ldir
OldCode9End:
    .db 0xFF
NewCode9:
    ld hl, 0x8000
    ld de, 0x8001
    ld bc, 0x3FFF
    ld (hl), 0
    ldir
; Remove any "oh noes, h4x0rz, must reset" checks (not strictly necessary, but annoying).
OldCode12Start:
    jp z, 0x0000
OldCode12End:
    .db 0xFF
NewCode12:
    nop \ nop \ nop
; Remove any "oh noes, h4x0rz, must reset" checks (not strictly necessary, but annoying).
OldCode13Start:
    jp nz, 0x0000
OldCode13End:
    .db 0xFF
NewCode13:
    nop \ nop \ nop
; Remove any masking of the Flash page before writing to port 6.
; I don't think this is really necessary, but it doesn't hurt.
OldCode14Start:
    and 0x7F
    out (6), a
OldCode14End:
    .db 0xFF
NewCode14:
    nop \ nop
    out (6), a
; Modify the boot-page-specific _LoadAIndPaged calls to point to the right page.
; This isn't really necessary since the correct values are also on the real boot page,
; but it doesn't hurt.
OldCode15Start:
    ld a, 0x7F
    .db 0x18 ; jr xx
OldCode15End:
    .db 0xFF
NewCode15:
    ld a, BOOT0_RAM_PAGE | 0x80
    .db 0x18 ; jr xx

ApplyPatches:
    ld ix, PatchTable
applyPatchesLoop:
    ld a, (ix)
    or a
    ret z
    ld de, 0x4000
doPatch:
    ld l, (ix + 1)
    ld h, (ix + 2)
    push ix
    push hl
    pop ix
    call FindPattern
    pop ix
    jr nz, continueNextPatch
    ;We have a match; get its location
    ld de, (kernelGarbage) ; Important?
    ;Get the new code pointer and size
    ld l, (ix + 3)
    ld h, (ix + 4)
    ld c, (ix)
    ld b, 0
    ;Copy it
    ldir
    ;DE points to next potential match
    jr doPatch
continueNextPatch:
    ld bc, 5
    add ix, bc
    jr applyPatchesLoop

FixJumpTableEntries:
    ld hl, JUMP0_START
    ld b, (JUMP0_END - JUMP0_START) / 3
    call fjte_1
    ld hl, JUMP1_START
    ld b, (JUMP1_END - JUMP1_START) / 3
fjte_1:
    ld a, (hl)
    and 0x3F
    cp BOOT0_ROM_PAGE & 0x3F
    jr nz, fjteNot0
    ld a, BOOT0_RAM_PAGE
    ld (hl), a
fjteNot0:
    ld a, (hl)
    and 0x3F
    cp BOOT1_ROM_PAGE & 0x3F
    jr nz, fjteNot1
    ld a, BOOT1_RAM_PAGE
    ld (hl), a
fjteNot1:
    inc hl
    inc hl
    inc hl
    djnz fjte_1
dummyRet:
    ret

outputPage:
    bit 7, a
    res 7, a
    ld b, a
    ld a, 1
    jr nz, opBig
    dec a
opBig:
    out (0x0E), a
    ld a, b
    call translatePage
    out (6), a
    ret
translatePage:
    ld b, a
    in a, (2)
    and 0x80
    jr z, _is83P
    in a, (0x21)
    and 3
    ld a, b
    ret nz
    and 0x3F
    ret
_is83P:
    ld a, b
    and 0x1F
    ret

FindEmptyBlock:
; Returns location in DE
; Returns size in BC
; Returns carry flag set if not found at all
    ld de, 0x8000
febLoop:
    dec de
    bit 6, d
    scf
    ret z
    ld a, (de)
    inc a
    jr z, febLoop
    inc de
    ld hl, 0x8000
    or a
    sbc hl, de
    push hl
    pop bc
    ret

FindPattern:
; Pattern in IX, starting address in DE
; Returns NZ if pattern not found
; (kernelGarbage) contains the address of match found
; Search pattern:    terminated by 0xFF
;                    0xFE is ? (one-byte wildcard)
;                    0xFD is * (multi-byte wildcard)
    ld hl, dummyRet
    push hl
    dec de
searchLoopRestart:
    inc de
    ld (kernelGarbage), de ; Important?
    push ix
    pop hl
searchLoop:
    ld b, (hl)
    ld a, b
    inc a
    or a
    ret z
    inc de
    inc a
    jr z, matchSoFar
    dec de
    inc a
    ld c, a
    ; At this point, we're either the actual byte (match or no match) (C != 0)
    ; or * wildcard (keep going until we find our pattern byte) (C == 0)
    or a
    jr nz, findByte
    inc hl
    ld b, (hl)
findByte:
    ld a, (de)
    inc de
    bit 7, d
    ret nz
    cp b
    jr z, matchSoFar
    ; This isn't it; do we start over at the beginning of the pattern,
    ; or do we keep going until we find that byte?
    inc c
    dec c
    jr z, findByte
    ld de, (kernelGarbage)
    jr searchLoopRestart
matchSoFar:
    inc hl
    jr searchLoop
end:
