# Kernel Library Routines

The kernel provides only one routine related to libraries.

The code for these routines may be found in 
[src/kernel/00/libraries.asm](https://github.com/SirCmpwn/KnightOS/blob/master/src/kernel/00/libraries.asm).

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

If the library is already noted, this routine instead notes that this thread
depends on the library.

Once loaded, you will be able to perform LCALLs that use this library.

Libraries are automatically unloaded with the last program that depends on it
exits.

Note: The library mechanism is incomplete. All loaded libraries will persist
in memory until the device reboots. This behavior will change before the release
of KnightOS. However, all other functions of library 