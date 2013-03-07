rkcall .equ $08
rlcall .equ $10

.macro kcall(addr)
    rst rkcall
    call addr
.endmacro
.macro kcall(cc, addr)
    rst rkcall
    call cc, addr
.endmacro
.macro kjp(addr)
    rst rkcall
    jp addr
.endmacro
.macro kjp(cc, addr)
    rst rkcall
    jp cc, addr
.endmacro
.macro kld(to, from)
    rst rkcall
    ld to, from
.endmacro

.macro lcall(id, addr)
    rst rlcall
    .db id
    call addr
.endmacro
.macro lcall(id, cc, addr)
    rst rlcall
    .db id
    call cc, addr
.endmacro
.macro ljp(id, addr)
    rst rlcall
    .db id
    jp addr
.endmacro
.macro ljp(id, cc, addr)
    rst rlcall
    .db id
    jp cc, addr
.endmacro
.macro lld(id, to, from)
    rst rlcall
    .db id
    ld to, from
.endmacro

.macro icall(addr)
    rst rlcall
    .db libId
    call addr
.endmacro
.macro icall(cc, addr)
    rst rlcall
    .db libId
    call cc, addr
.endmacro
.macro ijp(addr)
    rst rlcall
    .db libId
    jp addr
.endmacro
.macro ijp(cc, addr)
    rst rlcall
    .db libId
    jp cc, addr
.endmacro
.macro ild(to, from)
    rst rlcall
    .db libId
    ld to, from
.endmacro