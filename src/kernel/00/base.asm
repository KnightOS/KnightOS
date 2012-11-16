; Base file for KnightOS kernel

.nolist
#include "defines.inc"
.list

#include "header.asm"
#include "boot.asm"
#include "restarts.asm"
#include "interrupt.asm"
#include "memory.asm"
#include "thread.asm"
#include "signals.asm"
#include "libraries.asm"
#include "flash.asm"
#include "knightfs.asm"
#include "locks.asm"
#include "display.asm"
#include "keyboard.asm"
#include "time.asm"
#include "util.asm"