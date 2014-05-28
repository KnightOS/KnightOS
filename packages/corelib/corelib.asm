; KnightOS corelib
; General purpose application library

.nolist
libId .equ 0x02
#include "kernel.inc"
.list

.dw 0x0002

.org 0

jumpTable:
    ; Init
    ret \ nop \ nop
    ; Deinit
    ret \ nop \ nop
    jp appGetKey
    jp appWaitKey
    jp drawWindow
    jp getCharacterInput
    jp drawCharSetIndicator
    jp setCharSet
    jp getCharSet
    jp launchCastle
    jp launchThreadList
    jp showMessage
    jp showError
    jp showErrorAndQuit
    jp open
    .db 0xFF

; Same as kernel getKey, but listens for
; F1 and F5 and acts accordingly
; Z is reset if the thread lost focus during this call
appGetKey:
    pcall(getKey)
    jr checkKey

appWaitKey:
    pcall(waitKey)
    jr checkKey

checkKey:
    cp kYEqu
    ijp(z, launchCastle)
    cp kGraph
    ijp(z, launchThreadList)
    cp a
    ret

launchCastle:
    pcall(fullScreenWindow)
    push de
        ild(de, castlePath)
        di
        pcall(launchProgram)
    pop de
    pcall(suspendCurrentThread)
    pcall(flushKeys)
    or 1
    ret

launchThreadList:
    pcall(fullScreenWindow)
    push de
        ild(de, threadListPath)
        di
        pcall(launchProgram)
    pop de
    pcall(suspendCurrentThread)
    pcall(flushKeys)
    or 1
    ret

;; drawWindow [corelib]
;;  Draws a window layout on the screen buffer.
;; Inputs:
;;  IY: Screen buffer
;;  HL: Window title text
;;  A: Flags:
;;     Bit 0: Set to skip castle graphic
;;     Bit 1: Set to skip thread list graphic
;;     Bit 2: Set to draw menu graphic (note the opposite use from others)
;; Notes:
;;  Clears the buffer, then draws the standard frame and other items on it
drawWindow:
    push de
    push bc
    push hl
    push af
        pcall(clearBuffer)
        ; "window"
        push iy \ pop hl
        ld (hl), 0xff
        ld e, l
        ld d, h
        inc de
        ld bc, 57 * 12 - 1
        ldir
        
        ld e, 1
        ld l, 7
        ld c, 94
        ld b, 49
        pcall(rectXOR)
        
        res 7, (iy + 0)
        res 0, (iy + 11)
        
        bit 0, a
        jr nz, _
            ild(hl, castleSprite)
            ld b, 5
            ld de, 0x013A
            pcall(putSpriteOR)
_:      pop af \ push af
        bit 1, a
        jr nz, _
            ild(hl, threadListSprite)
            ld de, 89 * 256 + 58
            ld b, 6
            pcall(putSpriteOR)
_:      pop af \ push af
        bit 2, a
        jr z, _
            ild(hl, menuText)
            ld de, 40 * 256 + 58
            pcall(drawStr)

            ild(hl, menuSprite)
            ld d, 56
            inc e
            ld b, 3
            pcall(PutSpriteOR)
_:      pop af \ pop hl \ push hl \ push af
        ld de, 0x0201
        pcall(drawStrXOR)
    pop af
    pop hl
    pop bc
    pop de
    ret

;; showMessage [corelib]
;;  Displays a message box on the screen buffer.
;; Inputs:
;;  HL: Message text
;;  DE: Option list
;;  A: Default option, zero based
;;  B: Icon index (0: Exclamation mark)
;;  IY: Screen buffer
;; Outputs:
;;  A: Selected option index
;; Notes:
;;  Option list may be up to two different options, preceded by the number of options. Example:
;;      .db 2, "Yes", 0, "No", 0
;;  Or:
;;      .db 1, "Dismiss", 0
showMessage:
    push af
        push de
            push hl
                push bc
                    ld e, 18
                    ld l, 16
                    ld bc, (49 - 15) * 256 + (78 - 17)
                    pcall(rectOR)

                    ld e, 19
                    ld l, 17
                    ld bc, (48 - 16) * 256 + (77 - 18)
                    pcall(rectXOR)

                    ; Draw our nice icon. Note, in the future it might be nice to have a table of
                    ; different icons and then do something like
                    ; ld hl, iconTable \ ld e, b \ ld d, 0 \ add hl, de
                    ; to get a pointer to the table (with a check to ensure the icon index is valid.)
                pop bc \ push bc
                    ld a, b
                    or a ; cp 0
                    jr nz, .skipIcon

                    ld b, 8
                    ld de, 20 * 256 + 18
                    ild(hl, exclamationSprite1)
                    pcall(putSpriteOR)
                    ld e, 26
                    ild(hl, exclamationSprite2)
                    pcall(putSpriteOR)
.skipIcon:
        pop bc \ pop hl \ pop de \ pop af \ push hl \ push bc \ push af \ push de
                    ; For now we'll hardcode the location of the text, but if wider icons get
                    ; implemented the text's X coordinate needs to be calculated (or pre-stored).
                    ld de, 26 * 256 + 18 ; d = 26, e = 18
                    ld b, d ; margin
                    pcall(drawStr)

                    ; Draw all the options
                    ld de, 24 * 256 + 37
                    ld b, d ; left margin
                pop hl \ pop af \ push hl \ push af ; need the address of options, originally in de
                ld c, (hl)
                dec c ; We need our number of options to be zero-based
                inc hl ; Go to start of first string
                pcall(drawStr)
                ld a, c
                or a
                jr z, _ ; Skip drawing second option if there isn't one
                xor a
                push bc \ ld bc, -1 \ cpir \ pop bc ; Seek to end of string
                ld a, '\n' \ pcall(drawChar)
                pcall(drawStr)

_:          pop af \ push af ; default option
                cp c
                jr c, _
                jr z, _
                xor a ; default option is too large
_:              ld b, 5 ; height of sprite
.answerloop:
                    push af
                        or a \ rlca \ ld d, a \ rlca \ add d ; A *= 6
                        ld d, 0x14
                        add a, 37 \ ld e, a
                    pop af
                    ; Draw!
                    ild(hl, selectionIndicatorSprite)
                    pcall(putSpriteOR)

                    pcall(fastCopy)
                    push af
_:                      pcall(flushKeys)
                        pcall(waitKey)
                        cp kEnter
                        jr z, .answerloop_Select
                        cp k2nd
                        jr z, .answerloop_Select
                        cp kDown
                        jr z, .answerloop_Down
                        cp kUp
                        jr nz, -_ ; fall thru to .answerloop_Up
.answerloop_Up:
                    pop af
                    pcall(putSpriteXOR)
                    or a
                    jr z, .answerloop
                    dec a
                    jr .answerloop
.answerloop_Down:
                    pop af
                    pcall(putSpriteXOR)
                    cp c
                    jr z, .answerloop
                    inc a
                    jr .answerloop
.answerloop_Select:
                    pop af
                inc sp \ inc sp
            pop de
        pop bc
    pop hl
    ret

;; getCharacterInput [corelib]
;;  Gets a key input from the user.
;; Outputs:
;;  A: ANSI character
;;  B: raw keypress
;; Notes:
;;  Uses the upper-right hand corner of the screen to display
;;  input information, assumes you have a window chrome prepared.
;;  Possible values include \n and backspace (0x08).
;;  Also watches for F1/F5 to launch castle/thread list
getCharacterInput:
    icall(drawCharSetIndicator)

    ld b, 0
    icall(appGetKey)
    or a
    ret z ; Return if zero

    ld b, a

    ; Check for special keys
    cp kAlpha
    jr z, setCharSetFromKey
    cp k2nd
    jr z, setCharSetFromKey

    push bc

    ; Get key value
    sub 9
    jr c, _
    cp 41
    jr nc, _

    push hl
        push af
            ild(a, (charSet))
            add a, a \ add a, a \ add a, a \ ld b, a \ add a, a \ add a, a \ add a, b ; A * 40
            ild(hl, characterMapUppercase)
            add a, l
            ld l, a
            jr nc, $+3 \ inc h
        pop af

        add a, l
        ld l, a
        jr nc, $+3 \ inc h
        ld a, (hl)
    pop hl
    pop bc
    ret

_:  xor a
    pop bc
    ret

setCharSetFromKey:
    cp kAlpha
    icall(z, setAlphaKey)
    cp k2nd
    icall(z, set2ndKey)
    pcall(flushKeys)
    xor a
    ret

setAlphaKey: ; Switch between alpha charsets
    ild(a, (charSet))
    inc a
    cp 2 ; Clamp to <2
    jr c, _
        xor a
_:  ild((charSet), a)
    ret

set2ndKey: ; Switch between symbol charsets
    ild(a, (charSet))
    inc a
    cp 4 ; Clamp 1 < A < 4
    jr c, _
        ld a, 2
_:  cp 2
    jr nc, _
        ld a, 2
_:  ild((charSet), a)
    ret

; Draws the current character set indicator on a window
drawCharSetIndicator:
    push hl
    push de
    push bc
    push af
        ; Clear old sprite, if present
        ild(hl, clearCharSetSprite)
        ld de, 0x5C02
        ld b, 4
        pcall(putSpriteOR)

        ild(a, (charSet))
        ; Get sprite in HL
        add a, a \ add a, a ; A * 4
        ild(hl, charSetSprites)
        add a, l
        ld l, a
        jr nc, $+3 \ inc h
        ; Draw sprite
        pcall(putSpriteXOR)
    pop af
    pop bc
    pop de
    pop hl
    ret

charSet:
    .db 0

; Sets the character mapping to A.
; 0: uppercase \ 1: lowercase \ 2: symbols \ 3: extended
setCharSet:
    cp 4
    ret nc ; Only allow 0-3
    ild((charSet), a)
    ret

getCharSet:
    ild(a, (charSet))
    ret

;; showError [corelib]
;;  Displays a user-friendly error message if appliciable.
;; Inputs:
;;  A: Error code
showError:
    ret z
    push af
        or a
        jr z, showError_exitEarly
        ; Show error
        push de
        push bc
        push hl
            dec a
            ild(hl, errorMessages)
            add a \ add l \ ld l, a \ jr nc, $+3 \ inc h
            ld e, (hl) \ inc hl \ ld d, (hl)
            push de
            push ix
                push hl \ pop ix
                pcall(memSeekToStart)
                push ix \ pop bc
            pop ix
            pop hl
            add hl, bc

            ild(de, dismissOption)
            xor a
            ld b, a
            icall(showMessage)
        pop hl
        pop bc
        pop de
showError_exitEarly:
    pop af
    ret

;; showErrorAndQuit [corelib]
;;  Displays a user-friendly error message, if applicable,
;;  then quits the current thread.  This function does not
;;  return if NZ and if A != 0.
;; Inputs:
;;  A: Error code
showErrorAndQuit:
    ret z
    push af
        or a
        jr z, showError_exitEarly
        icall(showError)
        jp exitThread

;; open [corelib]
;;  Opens a file with the associated application.
;; Inputs:
;;  DE: Path to file
;; Outputs:
;;  A: New thread ID
;;  Z: Set on success, reset on failure
;; Notes:
;;  This checks to see if it's a KEXC, then looks in /etc/magic,
;;  then /etc/extensions, and then if it looks like a text file, it
;;  opens it with /etc/editor. If all of that fails, it returns NZ.
open:
    di

    push de
        ; Check to see if the file is a KEXC
        ; Open the file
        pcall(openFileRead)
        jr nz, .fail

        ; Allocate some memory for the KEXC text
        ld bc, 5
        pcall(malloc)
        jr nz, .fail

        ; Read the first four characters
        dec bc
        pcall(streamReadBuffer)
        jr nz, .fail

        ; Compare them to "KEXC"
        ld (ix + 4), 0
        push ix \ pop hl
        ild(de, kexcString)
        pcall(compareStrings)
        pcall(free)
    pop de
    ; If the file is a KEXC, directly launch it
    jr z, .isKEXC

    ; Else, open it with the text editor
    ex de, hl

    ; Copy HL into some new memory really quick
    pcall(stringLength)
    inc bc
    pcall(malloc)
    jr nz, .fail
    push ix \ pop de
    ldir

    ild(de, testPath)

.isKEXC:
    pcall(launchProgram)
    jr nz, .fail

    pcall(reassignMemory)
    push ix \ pop hl
    pcall(setInitialDE)
    ld h, 1 ; "open file"
    pcall(setInitialA)
    ild(hl, open_returnPoint)
    pcall(setReturnPoint)

    ei
    cp a
    ret
.fail:
    ei
    ret

open_returnPoint:
    ild(de, castlePath)
    pcall(launchProgram)
    pcall(killCurrentThread)

#include "errors.asm"
#include "characters.asm"

castlePath:
    .db "/bin/castle", 0
threadlistPath:
    .db "/bin/threadlist", 0
magicPath:
    .db "/etc/magic", 0
extensionsPath:
    .db "/etc/extensions", 0
editorPath:
    .db "/etc/editor", 0
testPath:
    .db "/bin/textview", 0

kexcString:
    .db "KEXC", 0

castleSprite:
    .db 0b10101000
    .db 0b00000000
    .db 0b10101000
    .db 0b00000000
    .db 0b10101000

castleText:
    .db "Castle", 0

threadListSprite:
    .db 0b10111100
    .db 0b00000000
    .db 0b10111100
    .db 0b00000000
    .db 0b10111100
    .db 0b00000000

menuSprite:
    .db 0b00100000
    .db 0b01110000
    .db 0b11111000

menuText:
    .db "Menu", 0

clearCharSetSprite:
    .db 0b11100000
    .db 0b11100000
    .db 0b11100000
    .db 0b11100000
charSetSprites:

uppercaseASprite:
    .db 0b01000000
    .db 0b10100000
    .db 0b11100000
    .db 0b10100000

lowercaseASprite:
    .db 0b00000000
    .db 0b01100000
    .db 0b10100000
    .db 0b01100000

symbolSprite:
    .db 0b01000000
    .db 0b11000000
    .db 0b01000000
    .db 0b11100000

extendedSprite:
    .db 0b01000000
    .db 0b01000000
    .db 0b00000000
    .db 0b01000000

exclamationSprite1:
    .db 0b01110000
    .db 0b10001000
    .db 0b10001000
    .db 0b10001000
    .db 0b10001000
    .db 0b10001000
    .db 0b10001000
    .db 0b10001000

exclamationSprite2:
    .db 0b10001000
    .db 0b01110000
    .db 0b00000000
    .db 0b01110000
    .db 0b10001000
    .db 0b10001000
    .db 0b10001000
    .db 0b01110000

selectionIndicatorSprite:
    .db 0b10000000
    .db 0b11000000
    .db 0b11100000
    .db 0b11000000
    .db 0b10000000
