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
#define USB
#define privledgedPage $3C
#endif
#ifdef TI84pSE
#define CPU15
#define USB
#define privledgedPage $7C
#endif
nullThread .equ $FF
errOutOfMem .equ 1
errTooManyThreads .equ 2

kernelMem .equ $8000
kernelGarbage .equ $8100
userMemory .equ $8200

threadTable .equ kernelMem
libraryTable .equ $8050
signalTable .equ $8078
fileStreamTable .equ $808C

currentThreadIndex .equ $80B4
activeThreads .equ $80B5
loadedLibraries .equ $80B6
activeSignals .equ $80B7
activeFileStreams .equ $80B8
nextThreadId .equ $80B9

maxThreads .equ 10
.list

#include "header.asm"
#include "boot.asm"
#include "interrupt.asm"
#include "memory.asm"
#include "thread.asm"
#include "util.asm"