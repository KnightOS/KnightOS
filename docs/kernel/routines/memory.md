# Kernel Memory Routines

The kernel provides many routines for manipulating allocation and freeing of memory.
Several routines are also provided for manipulating pre-allocated memory.

* [malloc](#malloc)
* [allocScreenBuffer](#allocscreenbuffer)
* [formatMem](#formatmem)
* [free](#free)
* [memSeekToStart](#memseektostart)

The code for these routines may be found in 
[src/kernel/00/memory.asm](https://github.com/SirCmpwn/KnightOS/blob/master/src/kernel/00/memory.asm).

## malloc

**Address**: 0x3FEB

Allocates memory and assigns it to the current thread.

*Inputs*

* **BC**: Amount to allocate (bytes)

*Outputs*

* **IX**: Pointer to allocated memory

*Possible Errors*

* errOutOfMem

## allocScreenBuffer

**Address**: 0x3F43

Allocates 768 bytes of memory, enough to hold one screen buffer.

*Outputs*

* **IY**: Pointer to allocated memory

*Possible Errors*

* errOutOfMem

## formatMem

**Address**: 0x3FF1

**This routine is not intended for use under normal conditions.**

Deallocates all memory and reformats RAM to prepare it for new allocations.

*Destroys*

* **A**
* **HL**

*Notes*

This routine is used during the boot sequence of KnightOS, and should not be used under
normal contitions.

## free

**Address**: 0x3FE8

Frees previously allocated memory.

*Inputs*

* **IX**: Pointer to first byte of allocated memory.

## memSeekToStart

**Address**: 0x3FEE

Seeks the memory pointer to the beginning of the section it points to.

*Inputs*

* **IX**: Pointer to anywhere in a section of allocated memory.

*Outputs*

* **IX**: Pointer to first byte of the allocated section.