; Sets the clock to HLDE, in ticks
setClock:
#ifndef CLOCK
    ld a, errUnsupported
    or a
    ret
#else
    push af
        ld a, h
        out (0x41), a
        ld a, l
        out (0x42), a
        ld a, d
        out (0x43), a
        ld a, e
        out (0x44), a
        ld a, 1
        out (0x40), a
        ld a, 3
        out (0x40), a
    pop af
    cp a
    ret
#endif
    
; Time in HLDE
getTimeInTicks:
#ifndef CLOCK
    ld a, errUnsupported
    or a
    ret
#else
    push af
        in a, (0x45)
        ld h, a
        in a, (0x46)
        ld l, a
        in a, (0x47)
        ld d, a
        in a, (0x48)
        ld e, a
    pop af
    cp a
    ret
#endif
    
; Converts HLDE (ticks) to:
; H: Day
; L: Month
; IX: Year
; B: Hour
; C: Minute
; D: Second
; A: Day of Week
; Epoch is January 1st, 1997 (Wednesday)
; Based on Linux's time.c
; Reference: https://github.com/torvalds/linux/blob/master/kernel/time/timeconv.c
convertTimeFromTicks:
    ; TODO
    ret
    
; H: Day
; L: Month
; IX: Year
; B: Hour
; C: Minute
; D: Second
; A: Day of Week
; Output: HLDE: Ticks
convertTimeToTicks:
    ; TODO
    ret
    
; H: Day
; L: Month
; D: Year
; B: Hours
; C: Minutes
; E: Seconds
; A: Day of Week
getTime:
#ifndef CLOCK
    ld a, errUnsupported
    or a
    ret
#else
    call getTimeInTicks
    call convertTimeFromTicks
    cp a
    ret
#endif
