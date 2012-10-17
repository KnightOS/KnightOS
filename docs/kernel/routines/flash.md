# Kernel Flash Routines

The kernel provides many routines for manipulating Flash memory directly.

**NOTE**: All routines on this page MUST be called with interrupts **disabled**.
Manipulating Flash manually is very likely to destroy user data when attempted by
a novice, and you should not use these if you do not know exactly what they do.

Additionally, with the exception of [unlockFlash](#unlockflash), none of these
routines will work properly with flash locked.

* copyFlashPage
* copySectorToSwap
* eraseFlashPage
* eraseFlashSector
* eraseSwapSector
* lockFlash
* unlockFlash
* writeFlashBuffer
* writeFlashByte

## copyFlashPage

**Address**: 0x3EFE

Copies data from one page of Flash to another.

*Inputs*

* **A**: Destination page
* **B**: Source page

*Notes*

The destination page should be erased prior to calling copyFlashPage.

## copySectorToSwap

**Address**: 0x3EFB

Copies the specified sector to the swap sector.

*Inputs*

* **A**: Any page within the sector to be copied

*Notes*

The swap sector should be erased prior to calling copySectorToSwap.

## eraseFlashPage

**Address**: 0x3EF5

Erases the contents of a single Flash page.

*Inputs*

* **A**: Page to erase

## eraseFlashSector

**Address**: 0x3EF8

Erases an entire sector of Flash.

*Inputs*

* **A**: Any page within the sector to be erased

## eraseSwapSector

**Address**: 0x3EEC

Erases the swap sector.

## lockFlash

**Address**: 0x3F9A

Locks Flash and protected ports.

## unlockFlash

**Address**: 0x3F9D

Unlocks Flash and protected ports.

## writeFlashBuffer

**Address**: 0x3EF2

Writes a series of bytes from RAM to Flash.

*Inputs*

* **DE**: Address to write to
* **HL**: Address to read from
* **BC**: Amount of data to write

*Notes*

DE must point to an area of memory with Flash swapped in. You are encouraged to use
memory bank 1 to load Flash pages.

HL must point to a location in RAM.

## writeFlashByte

**Address**: 0x3EEF

Writes a single byte to Flash.

*Inputs*

* **A**: Value to write
* **HL**: Address to write to

*Notes*

HL must point ot an area of memory with Flash swapped in. You are encouraged to use
memory bank 1 to load Flash page.