; TODO:
;   findDirectoryEntry
;   openStreamRead
;   streamReadByte
;   streamReadWord
;   streamReadBuffer
;   streamReadToEnd

; Inputs:
;   DE: File name
; Outputs:
;   Z: File exists
;   NZ: File does not exist
fileExists:
    push hl
    push af
        call findFileEntry
        jr nz, _
    pop af
    pop hl
    cp a
    ret
_:  ld h, a
    pop af
    or 1
    ld a, h
    pop hl
    ret

; Inputs:
;   DE: File name
; Outputs:
; (Failure)
;   A: Error code
;   Z flag reset
; (Success)
;   A: Flash page
;   HL: Address (relative from 0x4000)
findFileEntry:
    push de
    push bc
    push af
    ld a, i
    push af ; Save interrupt state
    di
        ld a, fatStart
        out (6), a
        ld hl, 0
        ld (kernelGarbage), hl ; Used as temporary storage of parent directory ID
        ld hl, 0x7FFF
        push af
            push de \ call checkForRemainingSlashes \ pop de
            jp z, findFileEntry_fileLoop
_:          ld a, (hl)
            dec hl \ ld c, (hl) \ dec hl \ ld b, (hl) \ dec hl
            cp fsDirectory
            jr z, .handleDirectory
            cp fsSymLink ; TODO
            cp fsEndOfTable
            jr z, findFileEntry_handleEndOfTable
.continueSearch:
            or a
            sbc hl, bc
            ; TODO: Handle running off the page
            jr -_
.handleDirectory:
            push bc
                push hl
                    ld c, (hl) \ dec hl \ ld b, (hl)
                    ld hl, (kernelGarbage)
                    call cpHLBC
                    jr z, .compareNames
                    ; Not correct parent
                pop hl
            pop bc
            jr .continueSearch
.compareNames:
                    pop hl \ push hl
                    ld bc, 5
                    or a
                    sbc hl, bc
                    push de
                        call compareDirectories
                        jr z, .updateDirectory
                    pop de
                pop hl
            pop bc
            jr .continueSearch
.updateDirectory:
                    inc sp \ inc sp
                    inc de
                    push de \ call checkForRemainingSlashes \ pop de
                pop hl \ push hl
                    dec hl \ dec hl
                    ld c, (hl) \ dec hl \ ld b, (hl)
                    ld h, b \ ld l, c
                    ld (kernelGarbage), hl
                pop hl
            pop bc
            jr nz, .continueSearch
            or a
            sbc hl, bc
            jr findFileEntry_fileLoop
findFileEntry_handleEndOfTable:
        pop af    
    pop af ; Restore interrupts
    jp po, _
    ei
_:  pop af
    ld a, errFileNotFound
    or a ; Resets z
    pop bc
    pop de
    ret
findFileEntry_fileLoop:
            ; Run once we've eliminated all slashes in the path
_:          ld a, (hl)
            dec hl \ ld c, (hl) \ dec hl \ ld b, (hl) \ dec hl
            cp fsFile
            jr z, .handleFile
            cp fsSymLink ; TODO
            cp fsEndOfTable
            jr z, findFileEntry_handleEndOfTable
.continueSearch:
            or a
            sbc hl, bc
            jr -_
.handleFile:
            push bc
                push hl
                    ; Check parent directory ID
                    ld c, (hl) \ dec hl \ ld b, (hl)
                    ld hl, (kernelGarbage)
                    call cpHLBC
                    jr z, .compareNames
                    ; Not correct parent
                pop hl
            pop bc
            jr .continueSearch
.compareNames:
                pop hl \ push hl
                    ld bc, 8
                    or a
                    sbc hl, bc
                    push de
                        call compareFileStrings
                    pop de
                pop hl
            pop bc
            jr z, .fileFound
            jr .continueSearch
.fileFound:
            ld bc, 3
            add hl, bc
        pop bc ; pop af
    pop af ; pop af
    jp po, _
    ei
_:  pop af
    ld a, b
    pop bc
    pop de
    cp a
    ret


; checks string at (DE) for '/'
; Z for no slashes, NZ for slashes
checkForRemainingSlashes:
    ld a, (de)
    or a ; CP 0
    ret z
    cp '/'
    jr z, .found
    inc de
    jr checkForRemainingSlashes
.found:
    or a
    ret

; Compare string, but also allows '/' as a delimiter.  Also compares HL in reverse.
; Z for equal, NZ for not equal
; HL = backwards string
; DE = fowards string
compareDirectories:
    ld a, (de)
    or a
    jr z, .return
    cp '/'
    jr z, .return
    cp ' '
    jr z, .return
    cp (hl)
    ret nz
    dec hl
    inc de
    jr compareDirectories
.return:
    ld a, (hl)
    or a
    ret

; Compare File Strings (HL is reverse)
; Z for equal, NZ for not equal
; Inputs: HL and DE are strings to compare
compareFileStrings:
    ld a, (de)
    or a
    jr z, .return
    cp ' '
    jr z, .return
    cp (hl)
    ret nz
    dec hl
    inc de
    jr compareFileStrings
.return:
    ld a, (hl)
    or a
    ret
