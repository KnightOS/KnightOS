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
    jp readOption_float
    jp readOption_bool
    jp writeOption
    jp writeOption_u8
    jp writeOption_u16
    jp writeOption_s8
    jp writeOption_s16
    jp writeOption_float
    jp writeOption_bool
    .db 0xFF

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
;;  Closes an open config file, saving any change
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
;;  Reads an option as a string in an open config file.
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
        ld bc, 0
        pcall(seek)
        jr nz, .exit
        icall(findVar)
        jr nz, .exit
        push ix \ pop hl \ push hl
            ld b, '='
            pcall(strchr)
            inc hl
.goToValue:
            ld a, (hl)
            cp ' '
            jr nz, .valueFound
            inc hl
            jr .goToValue
.valueFound:
            pcall(strlen)
            inc bc
            pcall(malloc)
            push ix \ pop de \ push de
                dec bc
                ldir
                xor a
                ld (de), a
            pop hl
        pop ix
        pcall(free)
.exit:
    pop de
    ret
    
readOption_8:
readOption_16:
readOption_s8:
readOption_s16:
readOption_float:
readOption_bool:
writeOption:
writeOption_u8:
writeOption_u16:
writeOption_s8:
writeOption_s16:
writeOption_float:
writeOption_bool:
    ret
