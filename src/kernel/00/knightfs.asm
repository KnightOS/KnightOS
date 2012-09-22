
streamSeekToStart:
	push hl
	push bc
		call getStreamInfo
		push hl
			ld bc, 7
			add hl, bc
			ld a, (hl)
			inc hl
			ld c, (hl)
			inc hl
			ld b, (hl)
		pop hl
		inc hl
		ld (hl), a
		inc hl
		ld (hl), c
		inc hl
		ld (hl), b
	pop bc
	pop hl
	ret

; Inputs:	D: Stream ID
;			BC: Amount to seek
; Outputs:	Stream is moved to BC bytes from the beginning
streamSeekFromBeginning:
	push hl
	push de
	push bc
		push bc
			call getStreamInfo
			push hl
				ld bc, 7
				add hl, bc
				ld a, (hl)
				inc hl
				ld c, (hl)
				inc hl
				ld b, (hl)
			pop hl
			push hl
				inc hl
				ld (hl), a
				inc hl
				ld (hl), c
				inc hl
				ld (hl), b
			pop hl
		pop bc
		; Update position
		inc hl
		ld a, (hl)
		inc hl
		ld e, (hl)
		inc hl
		ld d, (hl)
		ex de, hl
		add hl, bc
		ex de, hl
		; Handle page changes
		dec a
		push bc
			ld bc, $4000
			or a
			sbc hl, bc
			ld bc, $8000
_:			inc a
			sbc hl, bc
			jr c, -_
			ld bc, $4000
			add hl, bc
		pop bc
		ex de, hl
		ld (hl), d
		dec hl
		ld (hl), e
		dec hl
		ld (hl), a
		inc hl \ inc hl \ inc hl
		ld e, (hl)
		inc hl
		ld d, (hl)
		inc hl
		ld a, (hl) ; ADE holds remaining size
		ex de, hl
		add hl, bc
		jr c, $+3
		inc a
		ex de, hl
		ld (hl), a
		dec hl
		ld (hl), d
		dec hl
		ld (hl), e
	pop bc
	pop de
	pop hl
	ret

; Inputs:	D: Stream ID
;			BC: Amount to seek
; Outputs:	Stream is moved to BC bytes from the end
streamSeekFromEnd:
	ret

; Inputs:	D: Stream ID
;			BC: Amount to seek
; Outputs:	Stream is moved to BC bytes from the current position
streamSeekForward:
	push hl
	push de
	push bc
		push bc
			call getStreamInfo
		pop bc
		; Update position
		inc hl
		ld a, (hl)
		inc hl
		ld e, (hl)
		inc hl
		ld d, (hl)
		ex de, hl
		add hl, bc
		ex de, hl
		; Handle page changes
		dec a
		push bc
			ld bc, $4000
			or a
			sbc hl, bc
			ld bc, $8000
_:			inc a
			sbc hl, bc
			jr c, -_
			ld bc, $4000
			add hl, bc
		pop bc
		ex de, hl
		ld (hl), d
		dec hl
		ld (hl), e
		dec hl
		ld (hl), a
		inc hl \ inc hl \ inc hl
		ld e, (hl)
		inc hl
		ld d, (hl)
		inc hl
		ld a, (hl) ; ADE holds remaining size
		ex de, hl
		add hl, bc
		jr c, $+3
		inc a
		ex de, hl
		ld (hl), a
		dec hl
		ld (hl), d
		dec hl
		ld (hl), e
	pop bc
	pop de
	pop hl
	ret
	
streamSeekBackward:
	ret

; Inputs:	D: Stream ID
;			IX: Area of memory to read to
; Outputs:	Writes the remainder of the stream to (IX)
;			A: Preserved unless error
;			Z: Success
;			NZ: Failure
streamReadToEnd:
	push af
	ld a, i
	push af	
		push bc
		push de
		push hl
		di
		call getStreamInfo
		jp nz, streamReadToEnd_NoStream
		
		push hl
		
		inc hl
		ld a, (hl)
		out (6), a
		inc hl
		ld e, (hl)
		inc hl
		ld d, (hl)
		inc hl
		push de
			ld c, (hl)
			inc hl
			ld b, (hl)
			inc hl
			ld d, (hl)
		pop hl
streamReadToEnd_CopyLoop:
		ld a, (hl)
		ld (ix), a
		inc ix
		inc hl
		push bc
			ld bc, $8000
			call CpHLBC
			jr nz, _
			in a, (6)
			inc a
			out (6), a
_:
		pop bc
		ld a, $FF
		
		dec c
		cp c
		jr nz, _
		
		dec b
		cp b
		jr nz, _
		
		dec d
		cp d
		
_:
		xor a
		cp c
		jp nz, streamReadToEnd_CopyLoop
		cp b
		jp nz, streamReadToEnd_CopyLoop
		cp d
		jp nz, streamReadToEnd_CopyLoop
		
		ex de, hl
		pop hl
		; DE has current position in stream, HL has stream entry
		inc hl
		in a, (6)
		ld (hl), a ; Flash page update
		
		inc hl
		ld (hl), e
		inc hl
		ld (hl), e ; Address update
		
		inc hl
		ld (hl), 0
		inc hl
		ld (hl), 0
		inc hl
		ld (hl), 0 ; Space left in stream
	
	pop hl
	pop de
	pop bc
	pop af
	jp po, _
	ei
_:	pop af
	ret
	
streamReadToEnd_NoStream:
	pop hl
	pop de
	pop bc
	pop af
	jp po, _
	ei
_:	inc sp \ inc sp
	ld a, ErrStreamNotFound
	or a
	ret

; Inputs:	D: Stream ID
; Outputs:	HL: Word read (or error)
;			Advances stream
;			Z: Success
;			NZ: Error
streamReadWord:
	push bc
	ld a, i
	jp pe, _
	ld a, i
_:	push af
	push de
		di
		call getStreamInfo
		jr nz, streamReadWord_NoStream
		
		inc hl
		ld a, (hl)
		inc hl
		ld e, (hl)
		inc hl
		ld d, (hl)
		
		or a ; NZ

		push de
		push af
			ld a, $FF
			inc hl
			ld c, (hl)
			inc hl
			ld b, (hl)
			inc hl
			ld d, (hl)
			dec c ; LSB
			cp c
			jr nz, _
			dec b ; Middle
			cp b
			jr nz, _
			dec d ; MSB
			cp d
			jr nz, _
			; The end of the stream has been reached, error out
			jr streamReadWord_EndOfStream	
_:
			dec c ; LSB
			cp c
			jr nz, _
			dec b ; Middle
			cp b
			jr nz, _
			dec d ; MSB
			cp d
			jr nz, _
			; The end of the stream has been reached, error out
			jr streamReadWord_EndOfStream		
_:
			
			; Update stream size
			ld (hl), d
			dec hl
			ld (hl), b
			dec hl
			ld (hl), c
			dec hl
		pop af
		pop de
		
		out (6), a ; Load the appropriate page into bank 1
		ld a, (de) ; Byte to read
		
		inc e
		jr nc, _
		inc d
_:		
		push af
			in a, (6)
			ld b, a
			
			ld a, e
			or a
			jr nz, _
			ld a, d
			cp $80 ; We've reached the end of the page
			jr nz, _
			inc b
			ld de, $4000
_:
			ld a, (de)
			push af
			inc de
			
			ld a, e
			or a
			jr nz, _
			ld a, d
			cp $80 ; We've reached the end of the page
			jr nz, _
			inc b
			ld de, $4000
_:
			
			ld (hl), d
			dec hl
			ld (hl), e
			dec hl
			ld (hl), b ; Update info in stream table
		pop af
		ld h, a
		pop af
		ld l, a
		
	pop de
	pop af
	jp po, _
	ei
_:	pop bc
	ret
	
streamReadWord_EndOfStream:
		pop af
		pop de
	pop bc
	pop de
	inc sp \ inc sp
	ld a, ErrEndOfStream
	or a
	ret
	
streamReadWord_NoStream:
	pop bc
	pop de
	inc sp \ inc sp
	ld a, ErrStreamNotFound
	ret

; Inputs:	D: Stream ID
; Outputs:	A: Byte read (or error)
;			Advances stream
;			Z: Success
;			NZ: Error
streamReadByte:
	push bc
	ld a, i
	jp pe, _
	ld a, i
_:	push af
	push hl
	push de
		di
		call getStreamInfo
		jr nz, streamReadByte_NoStream
		
		inc hl
		ld a, (hl)
		inc hl
		ld e, (hl)
		inc hl
		ld d, (hl)
		
		or a ; NZ

		push de
		push af
			ld a, $FF
			inc hl
			ld c, (hl)
			inc hl
			ld b, (hl)
			inc hl
			ld d, (hl)
			dec c ; LSB
			cp c
			jr nz, _
			dec b ; Middle
			cp b
			jr nz, _
			dec d ; MSB
			cp d
			jr nz, _
			; The end of the stream has been reached, error out
			jr streamReadByte_EndOfStream
			
_:
			; Update stream size
			ld (hl), d
			dec hl
			ld (hl), b
			dec hl
			ld (hl), c
			dec hl
		pop af
		pop de
		
		out (6), a ; Load the appropriate page into bank 1
		ld a, (de) ; Byte to read
		
		inc de
		
		push af
			in a, (6)
			ld b, a
			
			ld a, e
			or a
			jr nz, _
			ld a, d
			cp $80 ; We've reached the end of the page
			jr nz, _
			inc b
_:
			ld (hl), d
			dec hl
			ld (hl), e
			dec hl
			ld (hl), b ; Update info in stream table
		pop af
	
	ld b, a
	pop de
	pop hl
	pop af
	jp po, _
	ei
_:	ld a, b
	pop bc
	ret
	
streamReadByte_EndOfStream:
		pop af
		pop de
	pop bc
	pop de
	pop hl
	inc sp \ inc sp
	ld a, ErrEndOfStream
	or a
	ret
	
streamReadByte_NoStream:
	pop bc
	pop de
	pop hl
	inc sp \ inc sp
	ld a, ErrStreamNotFound
	ret
	
; Inputs:	DE: Pointer to full path of file
; Outputs:	D: Stream ID
;			A: Preserved unless error
;			Z: Success
;			NZ: Error
openFileRead:
	ld a, i
	jp pe, _
	ld a, i
_:	push af
	di
	push hl
	push bc
		ld a, (activeFileStreams)
		cp MaxFileStreams
		jr c, ++_
		pop bc
		pop hl
		pop af
		jp po, _
		ei
_:		ld a, ErrTooManyStreams
		or a
		ret
		
_:		call lookUpFile
		jr z, ++_
		pop bc
		pop hl
		pop af
		jp po, _
		ei
_:		ld a, ErrFileNotFound
		or a
		ret
		
_:		push de
		push bc
		ld bc, 6
		or a
		sbc hl, bc ; Move to flash page
		
		ex de, hl
		ld a, (nextStreamId)
		inc a
		ld (nextStreamId), a
		ld a, (activeFileStreams)
		inc a
		ld (activeFileStreams), a
		ld hl, fileStreamTable
		dec a
		add a, a
		add a, a
		add a, a ; A *= 8
		
		add a,l
		ld l,a
		jr nc, $+3
		inc h
		
		ld a, (nextStreamId)
		dec a
		ld (hl), a	; Stream ID
		inc hl
		ld a, (de)
		ld (hl), a ; Flash page
		inc hl
		dec de
		ld a, (de)
		ld (hl), a ; Start address MSB
		inc hl
		dec de
		ld a, (de)
		ld (hl), a ; Start address LSB
		inc hl
		push hl \ push de \ push bc
			ld bc, 3
			ld d, h
			ld e, l
			inc de \ inc de \ inc de
			dec hl \ dec hl \ dec hl
			ldir
		pop bc \ pop de \ pop hl
		; Load size
		pop bc
		pop de		
		ld (hl), c
		inc hl
		ld (hl), b
		inc hl
		ld (hl), d		
		; End of stream opening
		
	pop bc
	ld a, (nextStreamId)
	dec a
	ld d, a
	pop hl
	pop af
	ret po
	ei
	ret
	
; Inputs:	DE: Pointer to full path of file
; Outputs:	D: Stream ID
;			A: Preserved unless error
;			Z: Success
;			NZ: Error
openFileWrite:
	ld a, i
	ld a, i
	push af
	di
	push hl
	push bc
		ld a, (activeFileStreams)
		cp MaxThreads
		jr c, ++_
		pop bc
		pop hl
		pop af
		jp po, _
		ei
_:		ld a, ErrTooManyStreams
		or a
		ret
		
_:		ld a, (nextStreamId)
		inc a
		ld (nextStreamId), a
		ld a, (activeFileStreams)
		inc a
		ld (activeFileStreams), a
		
		
	pop bc
	ld a, (nextStreamId)
	dec a
	ld d, a
	pop hl
	pop af
	ret po
	ei
	ret
	
; Inputs:	D: Stream ID
; Closes an open stream
closeStream:
	push hl
	push bc
	push de
	push af
		ld a, i
		jp pe, _
		ld a, i
_:		push af
			di
			call getStreamInfo
			push hl
			pop de
			
			ld bc, 8
			add hl, bc
			
			; HL points to next entry
			; DE points to destination for shifting
			push hl
				push hl \ pop bc
				ld hl, fileStreamTable + fileStreamTableSize
				or a
				sbc hl, bc
				push hl \ pop bc
			pop hl
			ldir
			
			ld a, (activeFileStreams)
			dec a
			ld (activeFileStreams), a
			
		pop af
		jp po, _
		ei
_:	pop af
	pop de
	pop bc
	pop hl
	ret
	
; Retrieves information about a file stream
; Inputs:	D: Stream ID
; Outputs:	HL: Stream table entry
;			DBC: Space left in stream
;			A: Preserved unless error
GetStreamInfo:
	push af
		ld hl, fileStreamTable
		
_:		ld a, (hl)
		cp d
		jr z, _
		ld bc, 8
		add hl, bc
		ld bc, fileStreamTable + fileStreamTableSize + 1
		call CpHLBC
		jr c, -_
		pop bc
		pop af
		ld a, ErrStreamNotFound
		or a
		ret
_:
	push hl
		inc hl \ inc hl \ inc hl \ inc hl
		ld c, (hl)
		inc hl
		ld b, (hl)
		inc hl
		ld d, (hl)
	pop hl
	
	pop af
	cp a ; Z for success
	ret
	
; Inputs:	DE: Pointer to full path of file
; Outputs:	Z: Exists
;			NZ: Does not exist
FileExists:
	push hl
	push de
	push bc
		call LookUpFile
	pop bc
	pop de
	pop hl
	ret
	
; Inputs:	DE: Pointer to full path of file
; Outputs:	A: Preserved unless error
;			Z: Success
;			NZ: Failure
DeleteFile:
	push hl
	push de
	push af
	call LookUpFile
	jr z, _
	ld a, ErrFileNotFound
	inc sp \ inc sp
	pop de
	pop hl
	ret
_:
	ld d, a
	ld a, i
	push af
	di
	ld a, d
	out (6), a

	ld a, FSDeletedFile
	inc hl \ inc hl \ inc hl
	call UnlockFlash
	call WriteFlashByte
	call LockFlash
	
	pop af
	jp po, _
	ei
_:	pop af
	pop de
	pop hl
	ret
	
; Inputs:	DE: Pointer to full path of directory
; Outputs:	A: Preserved unless error
;			Z: Success
;			NZ: Failure
DeleteDirectory:
	ret

; Inputs:	DE: Pointer to full path of file
;			HL: Pointer to new name of file (without full path)
; Example: If DE points to "bin/hello" and HL points to "world",
; then the file in bin/ called "hello" will be renamed to "world",
; and the full path will become "bin/world"
RenameFile:
	push bc
	push de
	push hl
	push af
	ld a, i
	push af
		di
		call UnlockFlash
		ld b, h
		ld c, l
		push bc
			call LookUpFile
			inc hl \ inc hl \ inc hl ; Move pointer to actual entry data
			; Mark old entry as renamed
			out (6), a
			ld a, FSModifiedFile
			call WriteFlashByte
			; Create new entry data in kernelGarbage (15 bytes only)
			; HL points to entry data
			ld de, kernelGarbage + kernelGarbageSize - 1
			; DE points to destination
			ld bc, 15
			; BC is size
			lddr ; Load the entry data into kernelGarbage
			ld a, FSFile
			ld (kernelGarbage + kernelGarbageSize - 1), a
			
			; TODO: Calculate size of entry and add end of page entry if needed
			
			; Create new entry in file system
			ld a, (EndOfTablePage)
			out (6), a
			ld hl, (EndOfTableAddress)
			ld de, kernelGarbage + kernelGarbageSize - 15
			ld bc, 15
			or a
			sbc hl, bc
			ex de, hl
			inc de
			
			call WriteFlashBuffer
		pop hl ; Pop the name into HL
		dec de
		call StringLength
		ex de, hl
		or a
		sbc hl, bc
		ex de, hl
		
		; Reverse the string in RAM
		; TODO: Move this to external routine in util.asm, and
		; restore original string orientation before returning
		push de
		push bc
		push hl
			ld d, h
			ld e, l
			ex de, hl
			add hl, bc
			ex de, hl
			; HL points to beginning, DE to end
_:			ld a, (hl)
			push af
				ld a, (de)
				ld (hl), a
			pop af
			ld (de), a
			dec de
			inc hl
			; Decrement BC twice
			dec bc \ dec bc
			ld a, b
			cp $FF ; Loop complete
			jr z, _
			ld a, c
			or a ; Loop complete
			jr nz, -_
_:		pop hl
		pop bc
		pop de
		
		inc bc
		call WriteFlashBuffer
		
		call LockFlash
	pop af
	jp po, _
	ei
_:	pop af
	pop hl
	pop de
	pop bc
	ret
	
; This routine will add an EndOfPage entry to the end
; of the table.  If needed, it will also trigger a
; garbage collect, and restore the state of the calculator
; afterwards.
CreateEndOfPageEntry:
	ret
	
; Inputs:	DE: Pointer to full path of file
; Outputs:	HL: Pointer to file entry in allocation table
;			A: Page of entry in allocation table (or error)
;			Z: Success
;			NZ: Error
LookUpFile:
	push de
	push bc
	ld a, i
	jp pe, _
	ld a, i
_:	push af
		di
		
		ld a, (de)
		cp '/'
		jr nz, _
		inc de
_:
		ld a, AllocTableStart
		out (6), a
		
		ld hl, 0
		ld (kernelGarbage), hl ; current parent ID
		ld hl, $7FFF
LookUpFile_Loop:
		ld a, (hl)
		dec hl
		ld c, (hl)
		dec hl
		ld b, (hl)
		dec hl		; A=ID, BC=Entry length, HL=Entry address
		
		cp FSEndOfTable
		jp z, LookUpFile_Failed
		cp FSDirectory
		jp z, LookUpFile_Directory
		cp FSEndOfPage
		jr nz, _
		in a, (6)
		dec a
		out (6), a
		ld hl, $7FFF
_:		
		or a
		sbc hl, bc
		; HL points to next entry
		jr LookUpFile_Loop
	
LookUpFile_Directory:
	push de
	ld c, (hl)
	dec hl
	ld b, (hl)
	dec hl

	push de
		ld de, (kernelGarbage)
		call CpBCDE
		jr nz, LookUpFile_Directory_NotCorrectParent
	pop de
	ld c, (hl)
	dec hl
	ld b, (hl)
	dec hl
	dec hl ; Skip flags (for future use)
	
	call CompareDirectories
	jp nz, LookUpFile_Directory_NotCorrectName
	inc sp
	inc sp ; removes the saved DE from the stack (the new one is correct)
	inc de
	dec hl ; HL points to new ID

	push hl
		ld h, b
		ld l, c
		ld (kernelGarbage), hl ; Update parent ID
	pop hl
	
	push de
		call CheckForRemainingSlashes
	pop de
	
	jp z, LookUpFile_FileLoop
	jp LookUpFile_Loop
	
LookUpFile_Directory_NotCorrectName:
	pop de
	ld bc, $FFFF
	xor a
	cpdr
	jp LookUpFile_Loop
	
LookUpFile_Directory_NotCorrectParent:
	pop de
	pop de
	dec hl \ dec hl \ dec hl
	
	xor a
	ld bc, $FFFF
	cpdr ; Skip past name string
	jp LookUpFile_Loop
	
LookUpFile_Failed:
	pop af
	jp po, _
	ei
_:	pop de
	pop bc
	ld a, ErrFileNotFound
	or a ; NZ
	ret
	
LookUpFile_FileLoop:
		; HL points to next entry
		ld a, (hl)
		dec hl
		ld c, (hl)
		dec hl
		ld b, (hl)
		dec hl
		
		cp FSFile
		jp z, LookUpFile_File
		cp FSEndOfTable
		jp z, LookUpFile_Failed
		cp FSEndOfPage
		jr nz, _
_:		
		or a
		sbc hl, bc
		inc hl
		; HL points to next entry
		jr LookUpFile_FileLoop
	
LookUpFile_File:
	push hl ; Preserve the entry, this is what we actually return
	ld c, (hl)
	dec hl
	ld b, (hl)
	dec hl
	push de
		ld de, (kernelGarbage)
		call CpBCDE
		jp nz, LookUpFile_File_IncorrectParent
	pop de
	; Correct directory
	ld bc, 10
	or a
	sbc hl, bc ; Move to name
	push de
		call CompareFileStrings
	pop de
	jp z, _
	inc sp
	inc sp
	
	ld bc, $FFFF
	xor a
	cpdr
	
	jp LookUpFile_FileLoop
	
_:
	pop hl
	; This file is correct, return the information
	in a, (6)
	ld b, a
	pop af
	jp po, _
	ei
_:	ld a, b
	inc sp \ inc sp \ inc sp \ inc sp ; pop de \ pop bc
	push hl
		dec hl \ dec hl \ dec hl
		ld c, (hl)
		dec hl
		ld b, (hl)
		dec hl
		ld d, (hl)
	pop hl
	cp a ; Z for success
	ret
	
LookUpFile_File_IncorrectParent:
	pop de
	ld bc, 10
	xor a
	sbc hl, bc
	
	ld bc, $FFFF
	cpdr
	inc sp
	inc sp ; Remove HL from the stack
	jp LookUpFile_FileLoop
	
; checks string at (DE) for '/'
; Z for no slashes, NZ for slashes
CheckForRemainingSlashes:
	ld a, (de)
	or a ; CP 0
	ret z
	cp '/'
	jr z, CheckSlashSlashFound
	inc de
	jr CheckForRemainingSlashes
CheckSlashSlashFound:
	or a
	ret

; Compare string, but also allows '/' as a delimiter.  Also compares HL in reverse.
; Z for equal, NZ for not equal
; HL = backwards string
; DE = fowards string
CompareDirectories:
	ld a, (de)
	or a
	jr z, CompareDirectoriesEoS
	cp '/'
	jr z, CompareDirectoriesEoS
	cp ' '
	jr z, CompareDirectoriesEoS
	cp (hl)
	ret nz
	dec hl
	inc de
	jr CompareDirectories
CompareDirectoriesEoS:
	ld a, (hl)
	or a
	ret

; Compare File Strings (HL is reverse)
; Z for equal, NZ for not equal
; Inputs: HL and DE are strings to compare
CompareFileStrings:
	ld a, (de)
	or a
	jr z, CompareFileStringsEoS
	cp ' '
	jr z, CompareFileStringsEoS
	cp (hl)
	ret nz
	dec hl
	inc de
	jr CompareFileStrings
CompareFileStringsEoS:
	ld a, (hl)
	or a
	ret