; TODO:
;   streamReadBuffer
;   streamReadToEnd
;   Writable streams

; Inputs:
;   DE: File name
; Outputs:
; (Failure)
;   A: Error code
;   Z: Reset
; (Success)
;   D: File stream ID
;   E: Garbage    
openFileRead:
    push hl
    push de
    push bc
    push af
    ld a, i
    push af
        di
        call findFileEntry
        ex de, hl
        jr nz, .notFound
        ; Create stream based on file entry
        out (6), a
        ld a, (activeFileStreams)
        cp maxFileStreams
        jr nc, .tooManyStreams
        inc a \ ld (activeFileStreams), a
        ld hl, fileHandleTable
        ; Search for open slot
        ld b, 0
_:      ld a, (hl)
        cp 0xFF
        jr z, _
        push bc
            ld bc, 8
            add hl, bc
        pop bc
        inc b
        jr -_
_:      push bc
            ; HL points to next entry in table
            call getCurrentThreadId
            ld (hl), a ; Flags/owner (no need to set readable flag, it should be zero)
            inc hl \ inc hl \ inc hl ; Skip buffer address
            ex de, hl
            ; Seek HL to file size in file entry
            ld bc, 7
            or a \ sbc hl, bc
            ; Do some logic with the file size and save it for later
            ld a, (hl) \ inc hl \ or a \ ld a, (hl)
            push af
                dec hl \ dec hl \ dec hl ; Seek HL to block address
                ; Write block address to table
                ld c, (hl) \ dec hl \ ld b, (hl)
                ex de, hl
                ld (hl), c \ inc hl \ ld (hl), b \ inc hl
                ; Flash address always starts as zero
                ld (hl), 0 \ inc hl
            pop af
            ; Write the size of the final block
            inc hl \ ld (hl), a \ dec hl
            ; Get the size of this block in A
            jr z, _
            xor a
_:          ; A is block size
            ld (hl), a
        pop bc
        ld d, b
    pop af
    jp po, _
    ei
_:  pop af
    pop bc
    inc sp \ inc sp ; Don't pop de
    pop hl
    cp a
    ret
.tooManyStreams:
    pop af
    jp po, _
    ei
_:  pop af
    pop bc
    pop de
    pop hl
    or 1
    ld a, errTooManyStreams
    ret
.notFound:
    pop af
    jp po, _
    ei
_:  pop af
    pop bc
    pop de
    pop hl
    or 1
    ld a, errFileNotFound
    ret

; Inputs:
;   D: Stream ID
; Outputs:
; (Failure)
;   A: Error code
;   Z: Reset
; (Success)
;   HL: Pointer to entry
getStreamEntry:
    push af
    push hl
    push bc
        ld a, d
        cp maxFileStreams
        jr nc, .notFound
        or a \ rla \ rla \ rla ; A *= 8
        ld hl, fileHandleTable
        add l \ ld l, a
        ld a, (hl)
        cp 0xFF
        jr z, .notFound
    pop bc
    inc sp \ inc sp
    pop af
    cp a
    ret
.notFound:
    pop bc
    pop hl
    pop af
    or 1
    ld a, errStreamNotFound
    ret


; Inputs:
;   D: Stream ID
; Outputs:
; (Failure)
;   A: Error code
;   Z: Reset
; (Success)
;   Z: Set
closeStream:
    push hl
        call getStreamEntry
        jr z, .doClose
    pop hl
    ret
.doClose:
        push af
            ld a, (hl)
            bit 7, a
            jr nz, .closeWritableStream
            ; Close readable stream (just remove the entry)
            ld (hl), 0xFF
        pop af
    pop hl
    cp a
    ret
.closeWritableStream:
    ; TODO

; Inputs:
;   D: Stream ID
; Outputs:
; (Failure)
;   A: Error code
;   Z: Reset
; (Success)
;   A: Byte read
streamReadByte:
    push hl
        call getStreamEntry
        jr z, .doRead
    pop hl
    ret
.doRead:
        push af
        ld a, i
        push af
        push de
        push bc
            di
            ld a, (hl) \ inc hl
            bit 7, a
            jr nz, .readFromWritableStream
            ; Read from read-only stream
            inc hl \ inc hl
            ld e, (hl) \ inc hl \ ld d, (hl)
            ; If DE is 0xFFFF, we've reached the end of this file (and the "next" block is an empty one)
            ld a, 0xFF
            cp e \ jr nz, +_
            cp d \ jr nz, +_
            ; End of stream
            jr .endOfStream_early
_:          ; Set A to the flash page and DE to the address (relative to 0x4000)
            ld a, e \ or a \ rra \ rra \ rra \ rra \ rra \ and 0b111
            sla d \ sla d \ sla d \ or d
            out (6), a
            ; Now get the address of the entry on the page
            ld a, e \ and 0b11111 \ ld d, a
            inc hl \ ld a, (hl) \ ld e, a
            push de
                ld bc, 0x4000 \ ex de, hl \ add hl, bc
                ; Read the byte into A
                ld a, (hl)
                ex de, hl
            pop de
            push af
                xor a
                inc e
                cp e
                jr nz, ++_
                ; Handle block overflow
                dec hl \ dec hl \ ld a, (hl)
                and %11111
                rla \ rla ; A *= 4
                ld d, 0x40 \ ld e, a
                ; DE points to header entry, which tells us where the next block is
                inc de \ inc de
                ex de, hl
                ld c, (hl) \ inc hl \ ld b, (hl)
                ex de, hl
                ; Determine if this is the final block
                push bc
                    ld a, c \ or a \ rra \ rra \ rra \ rra \ rra \ and 0b111
                    sla b \ sla b \ sla b \ or b
                    out (6), a
                    ld a, c \ and %11111 \ rla \ rla \ ld d, 0x40 \ ld e, a
                    ; DE points to header entry of next block
                    inc de \ inc de
                    ex de, hl
                        ld a, 0xFF
                        cp (hl) \ jr nz, _
                        inc hl \ cp (hl) \ jr nz, _
                        ; It is the final block, copy the block size from the final size
                        ex de, hl
                            inc hl \ inc hl \ inc hl \ inc hl \ ld a, (hl) \ dec hl \ ld (hl), a
                            dec hl \ dec hl \ dec hl
                        ex de, hl
_:                  ex de, hl
                pop bc
                ; Update block address in stream entry
                ld (hl), c \ inc hl \ ld (hl), b \ inc hl
                ld e, 0
_:              ; Update flash address
                ld (hl), e
                inc hl
                ld a, (hl) ; Block size
                or a ; Handle 0x100 size
                jr z, _
                cp e
                jr c, .endOfStream
_:          pop af
            ; Return A
.success:
        ld h, a
        pop bc
        pop de
        pop af
        jp po, _
        ei
_:      pop af
        ld a, h
    pop hl
    cp a
    ret
.endOfStream:
            dec hl \ dec hl \ dec (hl)
            pop af
.endOfStream_early:
        pop bc
        pop de
        pop af
        jp po, _
        ei
_:      pop af
    pop hl
    or 1
    ld a, errEndOfStream
    ret
.readFromWritableStream:
    jr .success ; TODO

; Inputs:
;   D: Stream ID
; Outputs:
; (Failure)
;   A: Error code
;   Z: Reset
; (Success)
;   HL: Word read
streamReadWord:
; TODO: Perhaps optimize this into something like streamReadByte
; The problem here is that reading two bytes requires you to do some
; additional bounds checks that would make us basically put the same
; code in twice (i.e. what happens when the word straddles a block
; boundary?)
    push af
        call streamReadByte
        jr nz, .error
        ld l, a
        call streamReadByte
        jr nz, .error
        ld h, a
    pop af
    ret
.error:
    inc sp \ inc sp
    ret

; Inputs:
;   D: Stream ID
;   IX: Destination address
;   BC: Length
; Outputs:
; (Failure)
;   A: Error code
;   Z: Reset
; (Success)
;   File is read into (IX)
;   Z: Set    
streamReadBuffer:
    push hl
        call getStreamEntry
        jr z, .doRead
    pop hl
    ret
.doRead:
        push af
        ld a, i
        push af
        push de
        push bc
        push ix
            di
            ld a, (hl) \ inc hl
            bit 7, a
            jr nz, .readFromWritableStream
            ; Read from read-only stream
            inc hl \ inc hl
            ld e, (hl) \ inc hl \ ld d, (hl)
            ; If DE is 0xFFFF, we've reached the end of this file (and the "next" block is an empty one)
            ld a, 0xFF
            cp e \ jr nz, +_
            cp d \ jr nz, +_
            ; End of stream
            jr .endOfStream
_:          ; Set A to the flash page and DE to the address (relative to 0x4000)
            ld a, e \ or a \ rra \ rra \ rra \ rra \ rra \ and 0b111
            sla d \ sla d \ sla d \ or d
            out (6), a
            ; Now get the address of the entry on the page
            ld a, e \ and 0b11111 \ ld d, a
            inc hl \ ld a, (hl) \ ld e, a
            push bc ; TODO: Can be optimized
                ld bc, 0x4000
                ex de, hl
                add hl, bc
                ld a, e
                sub 5
                ld e, a
            pop bc
            push de \ push ix \ pop de \ pop ix
            ; HL refers to the block in Flash
            ; IX refers to the file stream entry in RAM
            ; DE refers to the destination address
            ; BC is the amount to read
.readLoop:
            ; Calculate remaining space in the block
            ld a, (ix + 6)
            sub (ix + 5)
            ; A is remaining space in block
            ; if (bc > A) BC = A
            push af
                xor a
                cp b
                jr nz, _
            pop af
            cp c
            jr nc, ++_
            ld a, c
            jr ++_
            
_:          pop af
            ; A is length to read
_:          push bc
                ld b, 0
                or a
                jr nz, _
                inc b
_:              ld c, a
                ldir
            pop bc
            ; BC -= A
            push af
                or a
                jr nz, _
                dec b
                jr ++_
_:              push bc
                    ld b, a
                    ld a, c
                    sub b
                pop bc
                ld c, a
                jr nc, _
                dec b
_:          pop af
            add (ix + 5)
            or a
            jr nz, .iter
            ; We need to use the next block
            push bc
                ; Grab the new one
                ld a, (ix + 3) \ and 0b11111 \ rla \ rla \ ld l, a
                ld h, 0x40
                inc hl \ inc hl
                ld c, (hl) \ inc hl \ ld b, (hl)
                ld a, c \ rra \ rra \ rra \ rra \ rra \ and 0b111
                sla b \ sla b \ or b
                ld b, (hl)
                ; Change flash page
                out (6), a
                ; Update entry
                ld (ix + 3), c
                ld (ix + 4), b
                ; Update block size
                ld a, c \ and 0b11111 \ rla \ rla \ ld l, a
                inc hl \ inc hl
                ld a, 0xFF
                cp (hl)
                jr nz, _
                inc hl
                cp (hl)
                jr nz, _
                ld a, (ix + 7) ; Final block
_:              xor a
                ld (ix + 6), a ; Not final block
_:              ; Update HL
                ld hl, 0x4000
                ld a, c \ and 0b11111 \ add h \ ld h, a
            pop bc
            xor a
.iter:
            ld (ix + 5), a
            ; BC is remaining length to read
            ; Check to see if we're done
            xor a
            cp b
            jp nz, .readLoop
            cp c
            jp nz, .readLoop
        pop ix
        pop bc
        pop de
        pop af
        jp po, _
        ei
_:      pop af
    pop hl
    cp a
    ret
.endOfStream_pop:
            pop af
.endOfStream:
        pop ix
        pop bc
        pop de
        pop af
        jp po, _
        ei
_:      pop af
    pop hl
    or 1
    ld a, errEndOfStream
    ret

.readFromWritableStream:
    ; TODO
	
; Inputs:
; 	D: Stream ID
; Outputs:
; (Failure)
;	A: Error
;	Z: Reset
; (Success)
;	Z: Set
;	DBC: Remaining space in stream
getStreamInfo:
    push hl
        call getStreamEntry
        jr z, _
    pop hl
    ret
_:	    push af
        ld a, i
        push af
        di
        push ix
        push de
            push hl \ pop ix
            ld bc, 0 \ ld d, 0
            ld a, (ix + 6)
            sub (ix + 5)
            ; Update with remaining space in current block
            or a \ jr z, _
            add c \ ld c, a
            jr nc, ++_
_:              inc b
                ld a, b \ or a
                jr nz, _
                inc d
_:          ; Loop through remaining blocks
            ld a, (ix + 3) \ or a \ rra \ rra \ rra \ rra \ rra \ and 0b111
            ld h, (ix + 4) \ sla h \ sla h \ sla h \ or h
            out (6), a
            ld a, (ix + 3) \ and 0b11111 \ rla \ rla \ ld l, a
            ld h, 0x40
            ; Check for early exit
            push de
                inc hl \ inc hl ; Skip "prior block" entry
                ld e, (hl)
                inc hl
                ld d, (hl)
                dec hl \ dec hl \ dec hl
                ld a, 0xFF
                cp e \ jr nz, _
                cp d \ jr nz, _
                ; Current block is last block, exit
            pop de
        inc sp \ inc sp
        pop ix
        pop af
        jp po, $+4
        ei
        pop af
    pop hl
    cp a
    ret
            ; Continue into mid-block loop
_:          pop de
            ; Loop conditions:
            ; HL: Address of current block header
            ; DBC: Working size
            ; Memory bank 1: Flash page of current block
.loop:      ; Locate next block
            push de
                inc hl \ inc hl
                ld e, (hl)
                inc hl
                ld d, (hl)
                ld a, 0xFF
                cp e \ jr nz, ++_
                cp d \ jr nz, ++_
                ; Last block, update accordingly and return
                dec b
                ld a, (ix + 7)
                add c \ ld c, a
                jr nc, _
                inc b
                xor a
                cp b
                jr nz, _
            pop de
            inc d
            jr $+3
_:          pop de
            ; DBC is now correct to return
        inc sp \ inc sp
        pop ix
        pop af
        jp po, $+4
        ei
        pop af
    pop hl
    cp a
    ret
_:              ; Navigate to new block and update working size
                push de
                    ld a, e
                    or a \ rra \ rra \ rra \ rra \ rra \ and 0b111
                    sla d \ sla d \ sla d \ or d
                pop de
                out (6), a
                ld a, e \ and 0b11111 \ rla \ rla \ ld l, a
                ld h, 0x40
            pop de
            inc b
            jr .loop

; Inputs:
;   D: Stream ID
; Outputs:
; (Failure)
;   A: Error
;   Z: Reset
; (Success)
;   Z: Set
streamReadToEnd:
    push bc
    push de
        call getStreamInfo
        jr z, _
    pop de
    pop bc
    ret
_:      pop de \ push de
        call streamReadBuffer
    pop de
    pop bc
    ret
