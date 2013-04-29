; TODO:
; Unload libraries
; Allocate space to track usage; use maxThreads so that all threads may
; use it at once.

; Inputs:    DE: Pointer to full path of library
; Output:    A: Preserved unless error
;            Z: Success
;            NZ: Failure
loadLibrary:
    push af
    ld a, i
    jp pe, _
    ld a, i
_:  push af
    push hl
    push ix
    push bc
        di
        push de
            call fileExists
            jp nz, .fileNotFound
            
            ld a, (loadedLibraries)
            inc a
            cp maxLibraries
            jp z, .tooManyLibraries
        pop de
        push af
            push hl
            push bc
                call openFileRead
                ld a, d
                push af
                    call streamReadWord
                    ld d, h
                    ld e, l
                
                    ; Check to see if it has already been opened
                    ld a, (loadedLibraries)
                    or a
                    jr z, ++_
                    push bc
                        ld b, a
                        ld hl, libraryTable
_:                      ld a, (hl)
                        cp e
                        jr z, .alreadyLoaded
                        inc hl \ inc hl \ inc hl \ inc hl
                        dec b
                        jr nz, -_
                    pop bc
_:              pop af
            pop bc
            pop hl
            ld d, a
            push af
                call getStreamInfo
                ld a, (currentThreadIndex)
                push af
                    ld a, $FE
                    ld (currentThreadIndex), a
                    call malloc
                    jp nz, .outOfMem
                pop af
                ld (currentThreadIndex), a
            pop af
            
            ld d, a
        pop af
        ld (loadedLibraries), a
        
        call streamReadToEnd
        call closeStream
        ; DE is library ID, IX is location
        
        ld hl, libraryTable
        ld a, (loadedLibraries)
        dec a
        add a, a
        add a, a
        add a, l
        ld l, a
        jr nc, $+3
        inc h
        ld (hl), e
        inc hl
        push ix \ pop de
        ld (hl), e
        inc hl
        ld (hl), d
        inc hl
        ld (hl), 1
        
        push ix \ pop hl
        push ix \ pop bc
.jumpTableLoop:
        ld a, (hl)
        inc hl
        cp $FF
        jr z, .jumpTableDone
        cp $C9
        jr nz, _
        inc hl \ inc hl
        jr .jumpTableLoop
_:      ld e, (hl)
        inc hl
        ld d, (hl)
        
        ex de, hl
        add hl, bc
        ex de, hl
        
        ld (hl), d
        dec hl
        ld (hl), e
        inc hl \ inc hl
        jr .jumpTableLoop
        
.jumpTableDone:
        ld hl, _
        push hl
        jp (ix) ; Run the initialization routine
        
_:  pop bc
    pop ix
    pop hl
    pop af
    jp po, _
    ei
_:  pop af
    cp a
    ret
    
.alreadyLoaded:
    pop bc
    pop af
    ld d, a
    call closeStream
    inc hl \ inc hl \ inc hl
    inc (hl)
    pop bc
    pop hl
    pop af
    pop bc
    pop ix
    pop hl
    pop af ; This routine is awfully stack-heavy
    jp po, _
    ei
_:  pop af
    cp a
    ret
    
.fileNotFound:
    pop de
    pop ix
    pop bc
    pop hl
    pop af
    jp po, _
    ei
_:  pop af
    ld a, ErrFileNotFound
    or a
    ret
    
.tooManyLibraries:
    pop de
    pop ix
    pop bc
    pop hl
    pop af
    jp po, _
    ei
_:  pop af
    ld a, ErrTooManyLibraries
    or a
    ret
    
.outOfMem:
    pop af
    ld (currentThreadIndex), a
    pop ix
    pop bc
    pop hl
    pop af
    jp po, _
    ei
_:  pop af
    ld a, ErrOutOfMem
    or a
    ret