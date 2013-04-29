# Kernel Filesystem Routines

The kernel provides several routines for working with a KnightOS Filesystem formatted Flash chip.

**Note**: Many of these routines do not currently work. For instance, most of the writable filesystem
routines do not work. Most of the routines related to reading from streams are functional.

Some of these routines may trigger a garbage collection, in which case they will block until the
garbage collection is complete.

* [closeStream](#closestream)
* [deleteDirectory](#deletedirectory)
* [deleteFile](#deletefile)
* [fileExists](#fileexists)
* [getStreamInfo](#getstreaminfo)
* [findFileEntry](#findfileentry)
* [openFileRead](#openfileread)
* [openFileWrite](#openfilewrite)
* [renameFile](#renamefile)
* [streamReadByte](#streamreadbyte)
* [streamReadWord](#streamreadword)
* [streamReadBuffer](#streamreadbuffer)
* [streamReadToEnd](#streamreadtoend)
* [streamSeekBackward](#streamseekbackward)
* [streamSeekForward](#streamseekforward)
* [streamSeekFromBeginning](#streamseekfrombeginning)
* [streamSeekFromEnd](#streamseekfromend)
* [streamSeekToStart](#streamSeekToStart)

The source for these routines may be found in
[src/kernel/00/knighfs.asm](https://github.com/KnightSoft/KnightOS/blob/master/src/kernel/00/knightfs.asm).

## closeStream

**Address**: 0x3F5B

Closes an open stream.

*Inputs*

* **D**: Stream ID

## deleteFile

**Address**: 0x3EFE

Deletes a file, if it exists.

*Inputs*

* **DE**: Pointer to file name string

*Outputs*

* **Z**: set if the file existed (and was successfully deleted); reset if the file did not exist.

## fileExists

**Address**: 0x3EFB

Searches for a file and returns whether or not it exists.

*Inputs*

* **DE**: Pointer to file name string

*Outputs*

* **Z**: reset if the file exists; set if the file does not.

## getStreamInfo

**Address**: 0x3EE0

Returns the amount of remaining space in a stream.

*Inputs*

* **D**: Stream ID

*Outputs*

(Failure)
* **Z**: Set on success; reset on failure
* **A**: Error code (on failure)
* **DBC**: remaining space in the stream (on success)

## findFileEntry

**Address**: 0x3EF8

Searches for the FAT entry for the specified file.

*Inputs*

* **DE**: Points to a filename string

*Outputs*

(Failure)
* **Z**: Set on success; reset on failure
* **A**: Error code (on failure), flash page of the FAT entry (on success)
* **HL**: Address of the FAT entry (relative to the start of the flash page, so add 0x4000 to get a physical address when the flash is swapped in) (on success)

## openFileRead

**Address**: 0x3EF5

Opens a file in read-only mode and returns a stream ID.

*Inputs*

* **DE**: A pointer to a filename string

*Outputs*

* **Z**: Set on success; reset on failure
* **A**: Error code (on failure)
* **D**: File stream ID (on success)
* **E**: Garbage (on success)

*Notes*

Keep track of the returned ID!  You need it to do further operations with the file,
including reading, writing, and closing it.

## streamReadByte

**Address**: 0x3EEC

Gets a single byte from an open read-only stream.

*Inputs*

* **D**: Stream ID

*Outputs*

* **Z**: Set on success, reset on failure
* **A**: Error code (on failure), byte read (on success)

## streamReadWord

**Address**: 0x3EE9

Gets a single word from an open read-only stream.

*Inputs*

* **D**: Stream ID

*Outputs*

* **Z**: Set on success, reset on failure
* **A**: Error code (on failure)
* **HL**: Word read (on success)

## streamReadBuffer

**Address**: 0x3EE6

Reads a section of a file into a given block of memory.

*Inputs*

* **D**: Stream ID
* **IX**: Address of memory to copy into
* **BC**: Number of bytes to read in

*Outputs*

* **Z**: Set on success, reset on failure
* **A**: Error code (on failure)
* File is read into (IX) on success

## streamReadToEnd

**Address**: 0x3EE3

Reads the rest of the file into a given block of memory.

*Inputs*

* **D**: Stream ID
* **IX**: Address of memory to copy into

*Outputs*

* **Z**: Set on success, reset on failure
* **A**: Error code (on failure)
* File is read into (IX) on success

*Notes*

Ensure your buffer at (IX) is big enough, or this routine has the potential to corrupt
memory!
