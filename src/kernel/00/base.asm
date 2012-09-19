; Base file for KnightOS kernel

.nolist
#ifdef TI73
#define privledgedPage $1C
#endif
#ifdef TI83p
#define privledgedPage $1C
#endif
#ifdef TI83pSE
#define CPU15
#define privledgedPage $7C
#endif
#ifdef TI84p
#define CPU15
#define privledgedPage $3C
#endif
#ifdef TI84pSE
#define CPU15
#define privledgedPage $7C
#endif
; TODO: More platform-specific defines
nullThread .equ $FF
errOutOfMem .equ 1

kernelMem .equ $8000
kernelGarbage .equ $8100
userMemory .equ $8200
.list

#include "header.asm"
#include "boot.asm"
#include "memory.asm"
#include "thread.asm"
#include "util.asm"