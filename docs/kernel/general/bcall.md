# System bcall hook

A bcall is restart 0x28 in TIOS, the stock OS. It allows programs targeting TIOS to call system
routines. On KnightOS, however, bcalls are not supported. Whenever a bcall is executed in KnightOS,
the originating thread is immediately killed to avoid a crash (which will likely happen anyway if
you try to execute a TIOS program). However, you can override this behavior as a userspace program.
If you wish to provide a compatibility layer of some sort, you can handle bcalls yourself.

The code for the system handler is in
[src/kernel/00/restarts.asm](https://github.com/KnightSoft/KnightOS/blob/master/src/kernel/00/restarts.asm).

Use of the system bcall hook is simple. Here's an example:

        #include "macros.inc"
        #include "defines.inc"
        #include "kernel.inc"
        #include "stdio.inc"

        kld(hl, hook)
        ld (bcallHook), hl

        ; Do a bcall
        rst $28
        .dw $1234
        ret

    hook:
        kld(hl, text)
        stdio(printline)
        ; HL is pushed by the system restart handler, so skip past it
        inc sp \ inc sp
        ; Pop off the return address
        pop hl
        ; Increment past the .dw (we don't actually handle bcalls here)
        inc hl \ inc hl
        push hl

        dec sp \ dec sp
        pop hl ; Restore HL
        ret

    text:
        .asciiz "bcall executed!"

You'll notice that we had to do some trickery around the stack here. In the system bcall handler, HL is pushed
to the stack. You will need to restore this before returning to the caller.
