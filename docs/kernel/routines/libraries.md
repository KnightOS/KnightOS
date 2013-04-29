# Kernel Library Routines

The kernel provides only one routine related to libraries.

The code for these routines may be found in
[src/kernel/00/libraries.asm](https://github.com/KnightSoft/KnightOS/blob/master/src/kernel/00/libraries.asm).

## loadLibrary

**Address**: 0x3F40

Loads the specified library.

*Inputs*

* **DE**: Full path to library

*Possible Errors*

* errFileNotFound
* errOutOfMem
* errTooManyLibraries

*Notes*

If the library is already in use, this routine instead notes that this thread
depends on the library; it does not load another copy of the library.

Once you have used this routine to load the library, you will be able to perform
LCALLs that use this library.

Libraries are automatically unloaded with the last program that depends on it
exits.

Note: The library mechanism is incomplete.  Currently, all loaded libraries will
persist in memory until a reboot.  Library unloading will be implemented before
the release of KnightOS. However, all other functions of library support are in
working order.
