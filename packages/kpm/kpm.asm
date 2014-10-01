; KnightOS corelib
; General purpose application library

.nolist
libId .equ 0x05
#include "kernel.inc"
.list

.dw 0x0005

.org 0

jumpTable:
    ; Init
    ret \ nop \ nop
    ; Deinit
    ret \ nop \ nop
    jp getPackageList
    jp packageDetail
    jp removePackage
    jp freePackageList
    jp checkPackageLock
    .db 0xFF

getPackageList:
    icall(checkPackageLock)
    ret nz
    push hl
    push bc
    push de
    push af
        ld bc, 256 ; List of package repositories
        pcall(malloc)
        ild((.repos), ix)
        exx \ push ix \ pop hl \ ld b, 0 \ exx
        jr nz, .exit
        ild(hl, .callback)
        ild(de, .root)
        pcall(listDirectory)
        exx \ push bc \ exx \ pop bc
        ld a, b \ ild((.repos + 2), a)
        ; (.repos) is a list of pointers to repository names
        ; B is the total number of repositories

        ; TODO: Read each directory

        ild(ix, (.repos))
        ild(b, (.repos + 2))
        push ix
        push ix \ pop hl
.free_repos:
            ld e, (hl) \ inc hl \ ld d, (hl) \ inc hl
            push de \ pop ix
            pcall(free)
            djnz .free_repos
        pop ix
        pcall(free)
.exit:
    pop af
    pop de
    pop bc
    pop hl
    cp a
    ret
.exit_error:
    pop af
    pop de
    pop bc
    ld h, a \ or 1 \ ld a, h
    pop hl
    ret
.root:
    .db "/var/packages/"
.repos:
    .dw 0 ; Pointer to list
    .db 0 ; Total number of repos
.callback:
    exx
    
    cp fsDirectory ; TODO: Support symlinks here
    jr nz, .callback_done

    push bc
    push hl
        ld hl, kernelGarbage
        pcall(strlen) \ inc bc
        push ix
            pcall(malloc) ; TODO: Handle OOM
            push ix \ pop de
        pop ix
        push de
            ldir
            xor a
            ld (de), a
        pop de
    pop hl
    pop bc
    ld (hl), e \ inc hl \ ld (hl), d \ inc hl
    inc b

.callback_done:
    exx
    ret

freePackageList:
    ret

packageDetail:
removePackage:
    ret

;; checkPackageLock [kpm]
;;  Sets Z if there is currently a lock on packages.
checkPackageLock:
    push hl
    push af
        ild(hl, packageLock)
        xor a
        cp (hl)
        jr z, _
    pop af
    pop hl
    cp a
    ret
_:  pop af
    ld h, a \ or 1 \ ld a, h
    pop hl
    ret

packageLock:
    .db 0
