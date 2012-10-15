; Dummy boot page to get emulators to boot the OS
    jr _
    .fill $0F - $
    .db "Emulated Boot Code", 0
_:
#ifdef TI84p
    in a, ($21)
    res 0, a
    out ($21), a
#else
    in a, ($21)
    set 0, a
    out ($21), a
#endif
    jp $4000