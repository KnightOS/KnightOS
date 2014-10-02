; KnightOS Package Management (kpm) library

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

;; getPackageList [kpm]
;;  Returns a list of all packages installed on the system.
;; Outputs:
;;  HL: Pointer to list
;; Notes:
;;  The list begins with the 16-bit total length of the list and continues with pointers to the name of each package, unsorted.
;;  Use [[freePackageList]] to get rid of it when you're done.
getPackageList:
    icall(checkPackageLock)
    ret z
    icall(setPackageLock)
    push hl
    push bc
    push de
    push af
        ld bc, 256 ; List of package repositories ; NOTE: Max 128 repos until realloc is implemented
        pcall(malloc)
        jr nz, .exit_error
        ild((.repos), ix)
        exx \ push ix \ pop hl \ ld b, 0 \ exx
        jr nz, .exit
        ild(hl, .callback)
        ild(de, package_root)
        pcall(listDirectory)
        exx \ push bc \ exx \ pop bc
        ld a, b \ ild((.repos + 2), a)
        ; (.repos) is a list of pointers to repository names
        ; B is the total number of repositories
        push bc
            ld bc, 256 ; NOTE: Max 128 packages total until realloc is implemented
            pcall(malloc) ; TODO: OOM
            jr z, _
                pop bc
                jr .free_repos_
                ; (handles errors)
_:      pop bc
        ild((.packages), ix)
        ld c, 0 ; Total packages
        ild(hl, (.repos))
.repo_loop:
        ld e, (hl) \ inc hl
        ld d, (hl) \ inc hl
        icall(list_repository)
        djnz .repo_loop
        pcall(memSeekToStart)

.free_repos_:
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
    icall(resetPackageLock)
    pop af
    pop de
    pop bc
    pop hl
    cp a
    ret
.exit_error:
    icall(resetPackageLock)
    pop af
    pop de
    pop bc
    ld h, a \ or 1 \ ld a, h
    pop hl
    ret
.repos:
    .dw 0 ; Pointer to list
    .db 0 ; Total number of repos
.packages:
    .dw 0 ; Pointer to list
    .db 0 ; Total number of packages
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

; Internal - searches for packages in a particular repository (in DE)
list_repository:
    push hl
    push bc
    push de
        push ix
        push bc
            ; Append /var/packages/ to this string
            ex de, hl
            pcall(strlen)
            ex de, hl
            ld h, b \ ld l, c
            ld bc, package_root_end - package_root
            add hl, bc
            ld b, h \ ld c, l
            ; BC is length of combined strings
            pcall(malloc)
            push ix
                push de
                    ild(hl, package_root)
                    push ix \ pop de
                    ldir
                pop hl
                push ix \ pop de
                ex de, hl
                pcall(strlen)
                add hl, bc
                ex de, hl
                inc bc
                ldir
            pop de
        pop bc
        pop ix
        
        ild(hl, .callback)
        push bc \ exx \ pop bc \ exx
        pcall(listDirectory)
        push ix
            push de \ pop ix
            pcall(free)
        pop ix
    pop de
    pop bc
    pop hl
    ret
.callback:
    jr $
    exx
        cp fsFile
        jr nz, .exit_callback
        push bc
        push ix
            ld hl, kernelGarbage
            pcall(strlen)
            inc bc
            pcall(malloc)
            push ix \ pop de
        pop ix
        pop bc
        ld (ix), e
        ld (ix + 1), d
        inc ix \ inc ix
.exit_callback:
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

setPackageLock:
    push hl
    push af
        ild(hl, packageLock)
        ld a, 1
        ld (hl), a
    pop af
    pop hl
    ret

resetPackageLock:
    push hl
    push af
        ild(hl, packageLock)
        xor a
        ld (hl), a
    pop af
    pop hl
    ret

packageLock:
    .db 0

package_root:
    .db "/var/packages/", 0
package_root_end:
