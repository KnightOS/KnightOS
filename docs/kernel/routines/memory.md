# Kernel Memory Routines

The kernel provides many routines for manipulating allocation and freeing of memory.
Several routines are also provided for manipulating pre-allocated memory.

* [allocMem](#allocMem)
* [allocScreenBuffer](#allocScreenBuffer)
* [formatMem](#formatMem)
* [freeMem](#freeMem)
* [memSeekToStart](#memSeekToStart)

## allocMem

Allocates memory and assigns it to the current thread.

*Inputs*

* **BC**: Amount to allocate (bytes)

*Outputs*

* **IX**: Pointer to allocated memory

*Errors*

* errOutOfMem

## allocScreenBuffer

Allocates 768 bytes of memory, enough to hold one screen buffer.

*Outputs*

* **IY**: Pointer to allocated memory

## formatMem

**This routine is not intended for use under normal conditions.**

Deallocates all memory and reformats RAM to prepare it for new allocations.

*Destroys*

* **A**
* **HL**

*Notes*

This routine is used during the boot sequence of KnightOS, and should not be used under
normal contitions.

## freeMem

Frees previously allocated memory.

*Inputs*

* **IX**: Pointer to first byte of allocated memory.

## memSeekToStart

Seeks the memory pointer to the beginning of the section it points to.

*Inputs*

* **IX**: Pointer to anywhere in a section of allocated memory.

*Outputs*

* **IX**: Pointer to first byte of the allocated section.