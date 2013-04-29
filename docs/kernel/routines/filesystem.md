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
* [lookUpFile](#lookupfile)
* [openFileRead](#openfileread)
* [openFileWrite](#openfilewrite)
* [renameFile](#renamefile)
* [streamReadByte](#streamreadbyte)
* [streamReadToEnd](#streamreadtoend)
* [streamReadWord](#streamreadword)
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

