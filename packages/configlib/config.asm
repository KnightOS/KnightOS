.nolist
libId .equ 0x04
#include "kernel.inc"
.list

.dw 0x0004

.org 0

jumpTable:
    ret \ nop \ nop ; Init
    ret \ nop \ nop ; Deinit
    jp openConfigRead
    jp openConfigWrite
    jp closeConfig
    jp readOption
    jp readOption_8
    jp readOption_16
    jp readOption_32
    jp readOption_float
    jp readOption_bool
    jp writeOption
    jp writeOption_u8
    jp writeOption_u16
    jp writeOption_u32
    jp writeOption_s8
    jp writeOption_s16
    jp writeOption_s32
    jp writeOption_float
    jp writeOption_bool
    .db 0xFF

; Inputs:
;  HL: string
; Notes:
;  Destroys A
skipSpaces:
    ld a, (hl)
    cp ' '
    ret nz
    inc hl
    jr skipSpaces
    
; Inputs:
;  D: stream ID
;  IX: where to store (saved)
;  Z: set on success, reset on failure
corelib_streamReadLine:
    push ix
.loop:
        pcall(streamReadByte)
        jr nz, .error
        cp '\n'
        jr z, .end
        ld (ix), a
        inc ix
        jr .loop
.end:
        xor a
        ld (ix), a
.error:
    pop ix
    ret
    
; Inputs:
;  D: stream ID
;  HL: var name
; Outputs:
;  IX: pointer on line containing the variable (free after usage)
;  Z: set if variable found
findVar:
    ld bc, 256
    pcall(malloc)
    push ix
        push hl
.testNewLine:
        pop hl \ pop ix \ push ix \ push hl
            icall(corelib_streamReadLine)
            jr nz, .error
            ld a, (ix)
            cp '#'
            jr z, .testNewLine
.findVarNameLoop:
            ld a, (ix)
            cp (hl)
            jr z, .noFurtherTesting
            pcall(isAlphaNum)
            jr c, .testNewLine
            ld a, (hl)
            or a
            jr z, .success
            jr .testNewLine
.noFurtherTesting:
            inc ix
            inc hl
            jr .findVarNameLoop
.error:
        pop hl
    pop ix
    pcall(free)
    or a
    ret
.success:
        pop hl
    pop ix
    cp a
    ret

;; openConfigRead [configlib]
;;  Opens a config file in read-only mode.
;; Inputs:
;;  DE: Path to file (string pointer)
;; Outputs:
;;  Z: set on success, reset on failure
;;  A: error code (on failure)
;;  D: config file ID (on success)
;;  E: garbage (on success)
openConfigRead:
    pcall(openFileRead)
    ret

;; openConfigWrite [configlib]
;;  Opens a config file in write mode. The file
;;  gets created if it doesn't exist.
;; Inputs:
;;  DE: Path to file (string pointer)
;; Outputs:
;;  Z: set on success, reset on failure
;;  A: error code (on failure)
;;  D: config file ID (on success)
;;  E: garbage (on success)
openConfigWrite:
    pcall(openFileWrite)
    ret
    
;; closeConfig [configlib]
;;  Closes an opened config file, saving any change
;;  made to it.
;; Inputs:
;;  D: stream ID
;; Outputs:
;;  Z: Set on success, reset on failure
;;  A: Error code (on failure)
closeConfig:
    pcall(closeStream)
    ret
    
;; readOption [configlib]
;;  Reads an option as a string in an opened config file.
;; Inputs:
;;  D: stream ID
;;  HL: pointer to name of option
;; Outputs:
;;  HL: pointer to option value
;;  Z: set on success, reset on failure
;; Notes:
;;  Remember to free HL when you're done with it !
;;  Destroys AF, BC, HL, IX
readOption:
    push de
        ld e, 0
        ld b, e
        ld c, e
        pcall(seek)
        jr nz, .exit
        icall(findVar)
        jr nz, .exit
        push ix \ pop hl \ push hl
            ld b, '='
            pcall(strchr)
            jr nz, .free
            inc hl
            icall(skipSpaces)
            pcall(strlen)
            inc bc
            pcall(malloc)
            push ix \ pop de \ push de
                dec bc
                ldir
                xor a
                ld (de), a
            pop hl
.free:
        pop ix
        pcall(free)
.exit:
    pop de
    ret
    
;; readOption_8 [configlib]
;;  Reads an option as a signed byte in an opened config file.
;; Inputs:
;;  D: stream ID
;;  HL: pointer to name of option
;; Outputs:
;;  A: signed byte value on success
;;  Z: set on success, reset on failure
;; Notes:
;;  The command will only read the first three digits it will encounter.
;;  Destroys BC, HL, IX, BC', DE', HL'
readOption_8:
    ld b, 3
    push de
        icall(readOption_asNum)
    pop de
    ld a, l
    ret
    
;; readOption_16 [configlib]
;;  Reads an option as a signed 16-bits value in an opened config file.
;; Inputs:
;;  D: stream ID
;;  HL: pointer to name of option
;; Outputs:
;;  HL: signed 16-bits value on success
;;  Z: set on success, reset on failure
;; Notes:
;;  The command will only read the first 5 digits it will encounter.
;   Destroys AF, BC, IX, BC', DE', HL'
readOption_16:
    ld b, 5
    push de
        icall(readOption_asNum)
    pop de
    ret
    
;; readOption_32 [configlib]
;;  Reads an option as a signed 32-bits value in an opened config file.
;; Inputs:
;;  D: stream ID
;;  HL: pointer to name of option
;; Outputs:
;;  DEHL: signed 32-bits value on success
;;  Z: set on success, reset on failure
;; Notes:
;;  Make sure to save D before calling this if it contains the stream ID.
;;  The command will only read the first 5 digits it will encounter.
;;  Destroys AF, BC, IX, BC', DE', HL'
readOption_32:
    ld b, 10
    ijp(readOption_asNum)
    
; readOption_asNum
;  Takes a number of digits to read an option as a number.
; Inputs:
;  B: max digits
;  Same as all the readOption_x number reading routines
; Outputs:
;;  DEHL: signed 32-bits value on success
;;  Z: set on success, reset on failure
; Notes:
;  Destroys AF, IX, BC', DE', HL'
readOption_asNum:
    push bc
        ld e, 0
        ld b, e
        ld c, e
        pcall(seek)
        jr nz, .exit
        icall(findVar)
        jr nz, .exit
        push ix \ pop hl
        ld b, '='
        pcall(strchr)
        jr nz, .free
        inc hl
        icall(skipSpaces)
    pop bc
    pcall(strtoi)
.free:
    pcall(free)
    ret
.exit:
    pop bc
    ret
    
readOption_float:
readOption_bool:
writeOption:
writeOption_u8:
writeOption_u16:
writeOption_u32:
writeOption_s8:
writeOption_s16:
writeOption_s32:
writeOption_float:
writeOption_bool:
    ret
