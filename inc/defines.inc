#ifdef TI73
privledgedPage .equ $1C
swapSector .equ $18
fatStart .equ $17
bootPage .equ $1F
#endif
#ifdef TI83p
privledgedPage .equ $1C
swapSector .equ $18
fatStart .equ $17
bootPage .equ $1F
#endif
#ifdef TI83pSE
#define CPU15
privledgedPage .equ $7C
swapSector .equ $78
fatStart .equ $77
bootPage .equ $7F
#endif
#ifdef TI84p
#define CPU15
#define USB
#define CLOCK
privledgedPage .equ $3C
swapSector .equ $38
fatStart .equ $37
bootPage .equ $3F
#endif
#ifdef TI84pSE
#define CPU15
#define USB
#define CLOCK
privledgedPage .equ $7C
swapSector .equ $78
fatStart .equ $77
bootPage .equ $7F
#endif
nullThread .equ $FF
errOutOfMem .equ 1
errTooManyThreads .equ 2
errStreamNotFound .equ 3
errEndOfStream .equ 4
errFileNotFound .equ 5
errTooManyStreams .equ 6
errNoSuchThread .equ 7
errTooManyLibraries .equ 8
errUnsupported .equ 9
errTooManySignals .equ 10

kernelMem .equ $8000
kernelGarbage .equ $8100
#ifdef TI84pSE ; We need more space for garbage collection on TI-84+ SEs
kernelGarbageSize .equ $200
#else
kernelGarbageSize .equ $100
#endif
userMemory .equ kernelGarbage + kernelGarbageSize

threadTable .equ kernelMem
libraryTable .equ $8050
threadTableSize .equ libraryTable - threadTable ; TODO: More of these? Less?
signalTable .equ $8078
fileStreamTable .equ $808C
fileStreamTableSize .equ $28

currentThreadIndex .equ $80B4
activeThreads .equ $80B5
loadedLibraries .equ $80B6
activeSignals .equ $80B7
activeFileStreams .equ $80B8
nextThreadId .equ $80B9
nextStreamId .equ $80BA

hwLockIO .equ $80BB
hwLockLCD .equ $80BC
hwLockKeypad .equ $80BD
hwLockUSB .equ $80BE

; Misc.
currentContrast .equ $80BF
bcallHook .equ  $80C0 ; 2 bytes

; Used for line drawing
clip_mask .equ $80C2

priorityHook .equ $80C3

maxThreads .equ 10
maxFileStreams .equ 5
maxLibraries .equ 10
maxSignals .equ 5 ; Consider increasing this

; Filesystem stuff
fsEndOfTable .equ $FF
fsFile .equ $7F
fsDirectory .equ $BF
fsSymLink .equ $DF
fsDeltedFile .equ $00
fsModifiedFile .equ $01
fsDeletedDirectory .equ $02
fsModifiedDirectory .equ $04
fsDeletedSymLink .equ $08