# KnightOS Filesystem Format

**Note**: All details may change before the initial release.

Multi-byte numbers are stored in little endian.

The filesystem consists of two parts: the FAT (File Allocation Table), and the DAT (Data Allocation Table).
The FAT begins at the end of Flash, and grows towards the beginning, backwards. The DAT begins on page 04,
and grows towards the end of Flash. When these two tables reach each other, a garbage collection is performed.

If either table grows into a page that is not permitted for filesystem use (the boot pages, or the privledged
pages), these pages are simply skipped, and storage continues on the following page.

## File Allocation Table

All data structures in this section are shown reversed from their actual format, for easier comprehension.

The FAT stores information about the structure of the filesystem, including files, folders, and more. It
consists of a number of entries that describe folders, files, and symlinks.

The KnightOS filesystem supports up to 65,535 unique directories. No other entry is limited in this way. All
entries have a parent - a directory. The root directory does not have an entry, and is assigned ID 0.

Each entry is structured, at a high level, as follows:

<table>
    <th>Offset</th><th>Length (bytes)</th><th>Description</th>
    <tr><td>0000</td><td>1</td><td>Identifier</td></tr>
    <tr><td>0001</td><td>2</td><td>Entry length</td></tr>
    <tr><td>0003</td><td>*</td><td>Entry</td></tr>
</table>

The format of `Entry` varies by entry type, which is determined by the identifier. The following types are
available:

<table>
    <th>ID</th><th>Description</th>
    <tr><td>0xFF</td><td>End of Table</td></tr>
    <tr><td>0x7F</td><td>File</td></tr>
    <tr><td>0xBF</td><td>Directory</td></tr>
    <tr><td>0xDF</td><td>Symbolic Link</td></tr>
    <tr><td>0x00</td><td>Deleted File</td></tr>
    <tr><td>0x01</td><td>Modified File</td></tr>
    <tr><td>0x02</td><td>Deleted Directory</td></tr>
    <tr><td>0x04</td><td>Modified Directory</td></tr>
    <tr><td>0x08</td><td>Deleted Symbolic Link</td></tr>
</table>

These identifiers are chosen based on their ability to be modified. For instance, a file entry may be changed
to a deleted file entry by only resetting bits - thus making it possible to do so without clearing the entire
Flash page first. Any entry that would continue off of the page will instead continue on the next page, as if
continuously linked. Pages follow each other in reverse order - the page after 0x12 would be 0x11.

Each entry's format is documented below.

### End of Table

No further data. This entry does not include the length field.

### File

<table>
    <th>Offset</th><th>Length (bytes)</th><th>Description</th>
    <tr><td>0000</td><td>2</td><td>Parent ID</td></tr>
    <tr><td>0001</td><td>1</td><td>Flags (For future use)</td></tr>
    <tr><td>0003</td><td>3</td><td>File size</td></tr>
    <tr><td>0006</td><td>2</td><td><a href="#section-identifiers">Section Identifier</a></td></tr>
    <tr><td>0008</td><td>*</td><td>File name</td></tr>
</table>

### Directory

<table>
    <th>Offset</th><th>Length (bytes)</th><th>Description</th>
    <tr><td>0000</td><td>2</td><td>Parent ID</td></tr>
    <tr><td>0002</td><td>2</td><td>Directory ID</td></tr>
    <tr><td>0004</td><td>1</td><td>Flags (For future use)</td></tr>
    <tr><td>0005</td><td>*</td><td>Directory Name</td></tr>
</table>

### Symbolic Link

<table>
    <th>Offset</th><th>Length (bytes)</th><th>Description</th>
    <tr><td>0000</td><td>2</td><td>Parent ID</td></tr>
    <tr><td>0001</td><td>1</td><td>Length of link name</td></tr>
    <tr><td>0002</td><td>*</td><td>Link name</td></tr>
    <tr><td>xxxx</td><td>*</td><td>Full path</td></tr>
</table>

### Deleted File

Deleted file entries use the same format as file entries, with a different identifier.

### Modified File

Modified file entries use the same format as file entries, with a different identifier.

### Deleted Directory

Deleted directory entries use the same format as directory entries, with a different identifier.

### Modified Directory

Modified directory entries use the same format as directory entries, with a different identifier.

### Deleted Symbolic Link

Deleted symbolic link entries use the same format as symbolic link entries, with a different identifier.

## Data Allocation Table

KnightOS is a fragmented filesystem. The data allocation table is split into 256 byte sections, each of which
may contain all or part of the contents of one file. Each flash page has 63 of these sections. At the beginning
of each Flash page is a simple table, which represents which section follows each from within the page.

Starting at address 0, on each page, the header consists of 64 four-byte entries, each representing one section of
the page's sections. There is one entry (the first entry) that is always 0xFFFFFFFF, and is not used. Each entry is
set to 0xFFFFFFFF if that entry is not used, otherwise, it is further split into two 16-bit numbers. The first is
the preceeding section, or 0xFFFF if this is the first section of that file. The second is the next section, or
0xFFFF if this is the last section of the file.

For instance, say you have a file that starts on section 7, continues on 3, and ends on 12. The header for section
7 would be 0xFFFF, 0x0003. The section 3 header is 0x0007, 0x000C. The section 12 header is 0x0003, 0xFFFF.

The data allocation section may become severely fragmented over time. Defragmentation is not necessary.

### Section Identifiers

A section identifier is a two-byte identifer that refers to a location within the DAT. The upper 11 bits refer to
the Flash page the section resides on, and the remaining five bits refer to its address (divided by 256). Though
Flash pages may usually be represented in 8 bits, 11 bits are used for future-proofing. The TI-84+ CSE demands 9
bits to refer to a Flash page, and future calculators may add even more.

## Filesystem Operations

### Deleting a file

To delete a file, change its identifier to "deleted file". This indicates to the garbage collector that the entry
is to be removed, as well as its sections from the DAT.

### Modifying/Renaming a file

Change its identifier to "modified file" and create a new entry at the end of the FAT with the new details. Modified
file entries will be removed by the garbage collector, but the data sections will not be.

### Renaming a directory

For optimization in the filesystem routines, the fact that file entries will always come after their parent directory's
entries is taken advantage of. As such, renaming a directory is not as simple of a task as renaming a file. In order to
do so, you must change the entry to "modified directory", and then do so again for all children, and create updated
entries at the end of the FAT.

### Deleting a directory

To delete a directory, mark its entry as deleted and do the same for all children.

### Manipulating files

When working with files, 256 bytes of memory should be allocated to manipulate the current section. When creating a file,
locate the first free section and mark it as taken, but do not write to it. Allocate 256 bytes and set them to 0xFF. Streams
will use this as working memory for modifying files. If the users writes or seeks past the end of that section, write the
changes to Flash and continue from the new section. If the user seeks backwards *into* a section that has previously been
written, copy that section to RAM and clear it before writing it again.

Additionally offer a means of flushing all changes and writing them to Flash without closing the stream or seeking through
pages.

## Garbage Collection

When the two sections (the FAT and DAT) meet somewhere in the middle of Flash, a garbage collection will be required,
though it may not free up enough storage to continue with the pending operation. The procedure for doing so is as follows:

1. Save the screen to memory. If additional RAM pages are available, use them, otherwise, save the screen to allocated
   memory. If enough memory is not available, the screen will not be saved. Therefore, programs are encouraged to redraw
   the screen after file operations, which may be interrupted for a garbage collection.
2. With the screen safely saved (or maybe not), inform the user that a garbage collection is being performed.

Once this is complete, you may begin consoldating the DAT, 2048 sections at a time. Clear kernel garbage (0x200 bytes long),
and fill it with zeroes. Scan through the FAT and determine which sections are in use from the first 2048 sections. Indicate
a section's usage in kernel garbage by setting the corresponding bit. After determining if all of these sections are in use,
begin to clear unused sections. One sector at a time, copy each DAT sector to the swap sector. Inspect kernel garbage and
only copy the spoken-for sections back to the disk.

Once the DAT is cleaned up, cleaning up the FAT is simple. Copy each sector to the swap sector, and only copy back entries
that have not expired (such as deleted files).

**Note**: On the TI-83+ SE and TI-84+ SE, Flash is large enough to require two iterations of the DAT cleanup phase to complete.
The TI-84+ CSE (not yet supported) will require four iterations.

Garbage collection is to be done with interrupts disabled during the entire operation.
