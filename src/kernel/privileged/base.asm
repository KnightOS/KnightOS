; Privledged Page Routines
; Created 9/4/2011

.org $4000

    rst 00h    ; Safety
               ; If a program errors out and runs into this code,
               ; it should help avoid serious problems with outputting
               ; bad values to protected ports.
unlockFlash:
    ld a,i
    jp pe, _
    ld a, i
_:  push af
    di
    ld a, 1
    nop
    nop
    im 1
    di
    out ($14),a
    pop af
    ret po
    ei
    ret
    
lockFlash:
    ld a,i
    jp pe, _
    ld a, i
_:  push af
    di
    xor a
    nop
    nop
    im 1
    di
    out ($14),a
    pop af
    ret po
    ei
    ret
    
.db 0 ; Update on this page has been applied
; Kernel updates are simply an 8xu file that has page 00 containing the new kernel version
; OS updates are more difficult
; An OS update patch has this value as 0xFF, and only distributes this page
; The following structure is the remainder of the update:
; .db "full/path/to/file", 0
; .dw fileSize
; .db fileData
; This continues for as many files as are included in this update
; The kernel should check this value, and if it is 0xFF, delete all files included in the
; update, then garbage collect
; After this, it should re-add all of the latest versions of these files, then set this byte to 0.