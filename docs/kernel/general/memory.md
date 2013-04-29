# KnightOS Memory Layout

Memory in KnightOS is seperated into four sections - kernel code, Flash paging, kernel memory, and userspace memory.

It is laid out as follows:

<table>
    <th>Address</th><th>Length</th><th>Description</th>
    <tr><td>0x0000</td><td>0x4000</td><td>Kernel</td></tr>
    <tr><td>0x4000</td><td>0x4000</td><td>Flash paging</td></tr>
    <tr><td>0x8000</td><td>0x50</td><td>Thread table**</td></tr>
    <tr><td>0x8050</td><td>0x28</td><td>Library table**</td></tr>
    <tr><td>0x8078</td><td>0x14</td><td>Signal table**</td></tr>
    <tr><td>0x808C</td><td>0x28</td><td>File stream table**</td></tr>
    <tr><td>...</td><td>...</td><td>Various kernel variables*</td></tr>
    <tr><td>0x8100</td><td>0x100</td><td>Kernel garbage</td></tr>
    <tr><td>0x8200</td><td>0x7E00</td><td>Userspace memory</td></tr>
</table>

_\* See [defines.inc](https://github.com/KnightSoft/KnightOS/blob/master/inc/defines.inc#L66) for details_

_\*\* The size of this section could change if the maximum value is changed in [defines.inc](https://github.com/KnightSoft/KnightOS/blob/master/inc/defines.inc#L66")_

Kernel garbage is throwaway memory that the kernel uses for specific purposes for short periods of time. For example, it is used
for garbage collection, and for writing to Flash, and as temporary storage during file lookups.

Userspace memory is where all memory allocated with `malloc` is allocated to. This is where all userspace programs run.

## Data Structures

Information about kernel memory tables follows.

### Thread Table

The thread table contains state information about all currently executing threads. Each entry is 8 bytes long.

<table>
    <th>Offset</th><th>Length</th><th>Description</th>
    <tr><td>0000</td><td>1</td><td>Thread ID</td></tr>
    <tr><td>0001</td><td>2</td><td>Executable address</td></tr>
    <tr><td>0003</td><td>2</td><td>Stack pointer</td></tr>
    <tr><td>0005</td><td>1</td><td>Flags</td></tr>
    <tr><td>0006</td><td>2</td><td>Reserved for future use</td></tr>
</table>

Flags is a bitfield:

<table>
    <th>Bit</th><th>Description</th>
    <tr><td>0</td><td>May be suspended</td></tr>
    <tr><td>1</td><td>Is suspended</td></tr>
</table>

### Library Table

The library table stores information about all libraries currently loaded in the system. Each entry is 4 bytes long.

**NOTE**: This table will likely be revised to track which threads are using which libraries, and for 16 bit library IDs.

<table>
    <th>Offset</th><th>Length</th><th>Description</th>
    <tr><td>0000</td><td>1</td><td>Library ID</td></tr>
    <tr><td>0001</td><td>2</td><td>Library address</td></tr>
    <tr><td>0003</td><td>1</td><td>Number of dependent threads</td></tr>
</table>

### Signal Table

All pending signals are stored in the signal table. Each entry is 4 bytes long.

<table>
    <th>Offset</th><th>Length</th><th>Description</th>
    <tr><td>0000</td><td>1</td><td>Target thread</td></tr>
    <tr><td>0001</td><td>1</td><td>Message type</td></tr>
    <tr><td>0002</td><td>2</td><td>Payload</td></tr>
</table>

### File Stream Table

All active file streams are stored in this table. The buffer is only used for writable streams, and is garbage for read-only streams.

<table>
    <th>Offset</th><th>Length</th><th>Description</th>
    <tr><td>0000</td><td>1</td><td>Flags/Owner</td></tr>
    <tr><td>0001</td><td>2</td><td>Buffer address</td></tr>
    <tr><td>0003</td><td>2</td><td>Block address</td></tr>
    <tr><td>0005</td><td>1</td><td>Flash address</td></tr>
    <tr><td>0006</td><td>1</td><td>Block size</td></tr>
    <tr><td>0007</td><td>1</td><td>Final block size</td></tr>
</table>

The buffer address refers to the in-memory buffer for writable streams. The block address is a "section identifier", as described in the
filesystem specification, referring to the current block. The Flash address is the offset within the block address, these two fields combined
describe the stream's current position. The block size refers to the size of the block - 256 execpt for the last block. This allows us to
avoid looking up the file entry every time we do a read. Instead, we just look up the entry when we seek out of the current block.

The most significant bit of `Flags/Owner` indicates if the stream is writable: 1 for writable, 0 for read-only. The remaining bits are the
thread ID of the owner.
