; upper bound in B
; result in A
ionRandom:
    push de
        pcall(getRandom)
        ld d, a
        ld e, b
        pcall(div8By8)
    pop de
    ret
    