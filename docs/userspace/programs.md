# Userspace Programs

Programs in KnightOS are files in the filesystem. These are binary files, and have little additional structure beyond
the executable data. All programs have a header that describes their flags and stack size, and then the code. A basic
assembly template is provided below:

    .nolist
    #include "macros.inc"
    #include "kernel.inc"
    #include "userspace.inc"
    .list
        .db 0, 20
    .org 0
    start:
        ; ...
        ret

The first section, between `.nolist` and `.list` should be a list of `#include` directives. The following include files
are provided for use with the kernel, with basic equates and macros:

* **kernel.inc** provides equates for all kernel routines
* **macros.inc** provides basic macros for working with the kernel, such as kcall
* **keys.inc** provides equates for all keys on a standard TI-83+ keypad
* **userspace.inc** includes a few equates for userspace programs

Additionally, you may want to add the include files for various libraries or other dependencies. Following this, please
specify the kernel flags (8 bits) and the stack size (divided by two, 8 bits). For instance, the template has the default
flags, and a 40 byte stack. After this, simply use `.org 0` and fill in the rest of your code.

The text above describes the standard kernel program structure. For KnightOS userspace programs, additional metadata
is required, to interact with the system. A template is provided below:

    .nolist
    #include "kernel.inc"
    #include "macros.inc"
    #include "userspace.inc"
    .list
        .db 0, 20
    .org 0
        jr start
        .db 'K'
        .db 0
        .db "description", 0
    start:

This template is slightly more complex. The kernel program header is still included, but immediately after, a `jr start` is
used to skip userspace metadata. This metadata includes a magic number ('K'), which should always be the same, then the
userspace flags, and a short zero-delimited description string. The code follows.

Use of this template will allow your thread to show up in the thread list, and specify userspace flags.

## Flags

### Kernel Flags

Kernel flags are your thread flags. Equates are provided in `userspace.inc` that define the following flags:

* **k_nosuspend**: Indicates that the thread cannot be suspended

To use these, OR together several of them. For example, a nonsuspendable thread might look like this:

    .equ k_nosuspend

*Note*: Further bits are reserved for future use

### Userspace Flags

Userspace flags describe how the operating system interacts with your program. Equates are provided in `userspace.inc` that
define the following flags:

* **u_invisible**: Specifies that this program should not appear in the thread list
* **u_terminal**: Specifies that this program should be launched in a terminal

An invisible terminal thread might look like this:

    .equ u_invisible | u_terminal

## Installation

Programs may be run from anywhere. The generally accepted location, however, is to place executables in `/bin`. To "install" a
program, simply include it there and it may be run from the file explorer, terminal, or 3rd party programs. If you wish for
your program to appear in the Castle, modify `/etc/castle.list`. A package manager will eventually be available to make this
process easier.

## Relocation

Threads are loaded into memory at a location that cannot be determined until runtime. As such, they must be relocated. Threads
are launched without relocation, and are relocated on demand. Whenever you reference a location within your program, you must
use a relocatable instruction. This is accomplished through several macros provided in `macros.inc`. The following macros are
available:

* **kcall(xxxx)**: A relocatable version of the `call` instruction. Relocates and calls `xxxx`.
* **kcall(cc, xxxx)**: A conditional kcall. Always relocates, but does not call unless the `cc` flag condition is met.
* **kld(reg, xxxx)**: A relocatable version of the `ld` instruction. Relocates `xxxx` and loads its value into `reg`.
* **kjp(xxxx)**: A relocatable version of the `jp` instruction. Relocates and jumps to `xxxx`.
* **kjp(cc, xxxx)**: A conditional kjp. Always relocates, but does not jump unless the `cc` flag condition is met.

These are all interchangable versions of pre-located z80 instructions. When they execute, the code is modified to a pre-located
z80 instruction, and subsequent execution of the code will be considerably faster.

*Note*: There are plans to offer a means to relocate programs before execution to make execution faster. This has not been
implemented.

## Using Libraries

There are many occasions when you will want to use a library. Libraries are files, and to use them, you must first load them.
This is accomplished via the `loadLibrary` kernel function. An example here is provided for loading libtext:

        kld(de, libtextPath)
        call loadLibrary
        ; ...
    libtextPath:
        .db "/lib/libtext", 0

You must determine the file location of the library, then include that path in your program. Pass the path to `loadLibrary` in
DE and it will be loaded. You may then use functions provided by the library. In order to do so, you should first add the relevant
include file. For libtext, this is simply called `libtext.inc`. Most libraries will expose a macro for using their functions. In
libtext, this is the `libtext` macro. For instance, to call `drawStr`, you'd do this:

    libtext(drawStr)

Most libraries also offer a conditional equivalent, such as `libtext(cc, xxxx)`. Consult the documentation for each library for
more details. Here is a simple example program that uses libtext to draw a string on screen:

    .nolist
    #include "kernel.inc"
    #include "macros.inc"
    #include "userspace.inc"
    #include "libtext.inc"
    .list
        .db 0, 20
    .org 0
    start:
        kld(de, libtextPath)
        call loadLibrary
        
        ; Set up some things:
        ;  -Acquire exclusive use of the LCD and keypad
        ;  -Allocate and clear a display buffer
        call getLcdLock
        call getKeypadLock
        call allocScreenBuffer
        call clearBuffer
        
        ld de, 0 ; X, Y
        kld(hl, message)
        libtext(drawStr)
        
        ; Draws the buffer to the LCD
        call fastCopy
        
        ; Waits for user to press any key and then exits
        call waitKey
        ret
    message:
        .db "Hello, world!", 0

## Terminal Programs

Many programs run within a terminal. All terminal commands, in fact, are programs located in `/bin`. To communicate with a terminal
(or another supervising thread), the `stdio` library is used. Note that this is somewhat similar to the stdio you may be familiar
with in C or other languages, it works in an entirely different way. The basic structure of a terminal program is this:

    .nolist
    #include "kernel.inc"
    #include "macros.inc"
    #include "userspace.inc"
    #include "stdio.inc"
    .list
        .db 0, 20
    .org 0
    start:
        kld(de, stdioPath)
        call loadLibrary
        ; ...
        ret
    stdioPath:
        .db "/lib/stdio", 0

If your program is included in the Castle, you should include the userspace header and specify that it should be run within a terminal.

All programs may be passed parameters, and this is done via HL. When your program starts, HL will point to the argument string, or it
will be zero.

Further information on working with a terminal can be found in the stdio documentation.

## Graphical Programs

A "graphical program" is distinct from a "terminal program" in that graphical programs handle all LCD interaction and do not have a
supervising thread. A terminal program generally does not work directly with the LCD, instead offloading this to the supervisor thread
via stdio. A graphical program also generally includes a userspace header and is included in the Castle. However, graphical programs are
not explicitly required to use the LCD, though it is strongly recommended. The Castle will exit upon launching your program, and if it
does not assert control over the LCD, a non-interactive image of the Castle will remain on the display.

## Example Program

A simple "hello world" program is provided below:

    .nolist
    #include "kernel.inc"
    #include "macros.inc"
    #include "userspace.inc"
    #include "stdio.inc"
    .list
        .db 0, 20
    .org 0
    start:
        ; Load stdio
        kld(de, stdioPath)
        call loadLibrary
        ; Print message to terminal
        kld(hl, message)
        stdio(printLine)
        ret
    message:
        .db "Hello, world!", 0
    stdioPath:
        .db "/lib/stdio", 0

This is a terminal program. When run with any arguments, it will simply print "Hello, world!" to the terminal and exit.

## Example Graphical Program

The following program simply displays "Hello, world!" on the screen, but does so without a terminal.

    .nolist
    #include "kernel.inc"
    #include "macros.inc"
    #include "userspace.inc"
    #include "libtext.inc"
    .list
        .db 0, 20
    .org 0
        jr start
    .db 'K'
    .db 0
    .db "Hello world!", 0
    start:
        kld(de, libtextPath)
        call loadLibrary
        
        call getLcdLock
        call getKeypadLock
        call allocScreenBuffer
        call clearBuffer
        
        ld de, 0
        kld(hl, message)
        libtext(drawStr)
        
        call fastCopy
        
        call waitKey
        ret
    message:
        .db "Hello, world!", 0

Note the inclusion of a userspace header (so it may be shown in the Castle). This program loads `libtext`, and acquires locks
on the hardware it needs. It also allocates a 768 byte screen buffer via the `allocScreenBuffer` kernel function. It calls
libtext's `drawStr` function, draws the buffer to the LCD, awaits a keypress, and exits.

The key of any graphical program is the screen buffer. Calling `allocScreenBuffer` is important, and it will allocate a 768 byte
buffer of memory. This will be garbage when allocated - clear it with `clearBuffer`. All functions in the kernel and system
libraries that manipulate a buffer expect it to be passed in IY.

Many KnightOS programs are graphical programs. For example, the terminal is a graphical program that uses libtext to draw text
offered via stdio.

## Example GUI Program

KnightOS will eventually offer a GUI library that will help you design user interfaces. This library is `/lib/applib`, but at the
present time, only simple GUI functions are offered. You can draw the standard KnightOS chrome with `drawWindow`, and there are
several other functions included. For example, `appGetKey` and `appWaitKey` work like the kernel functions `getKey` and `waitKey`,
but they will allow the thread list or Castle to be run when the appropriate function keys are pressed.

A better example program will be offered when the KnightOS GUI system is finished. For now, here is a more simple example:

    .nolist
    #include "kernel.inc"
    #include "macros.inc"
    #include "libtext.inc"
    #include "applib.inc"
    #include "keys.inc"
    #include "userspace.inc"
    .list
        .db 0
        .db 20 ; Stack size
    .org 0
        jr start
        .db 'K'
        .db u_visible ; Enables the thread to be visible in the thread list
        .db "Hello world!", 0
    start:
        call getLcdLock
        call getKeypadLock

        call allocScreenBuffer
        
        ; Load dependencies
        kld(de, libTextPath)
        call loadLibrary
        kld(de, applibPath)
        call loadLibrary
        
        kld(hl, windowTitle)
        xor a ; Window flags
        applib(drawWindow)
        
        ld de, 0x0208 ; X, Y
        kld(hl, helloString)
        libtext(drawStr)
        
        ; Make sure you call fastCopy in a loop when you use appWaitKey or appGetKey
        ; This is because you might lose focus if a function key is pressed, and must
        ; redraw the screen upon getting it back.
        ; It's possible that this might change in the future to automatically redraw
        ; the buffer at IY when resuming, but that is to be determined.
    _:  call fastCopy
        call flushKeys
        applib(appWaitKey)
        cp kClear
        jr nz, -_
        ret
        
    helloString:
        .db "Hello, world!", 0
    windowTitle:
        .db "Window title!", 0
    libTextPath:
        .db "/lib/libtext", 0
    applibPath:
        .db "/lib/applib", 0

## Coorperating with the rest of the OS

KnightOS provides a multitasking enviornment. There are several considerations you should be aware of when working on your
programs to allow the rest of the system to operate smoothly.

Unless you explicitly mark your thread as non-suspendable, it will be suspended when it loses focus. It may lose focus when
function keys are pressed with appGetKey or appWaitKey, for example. When this happens, the thread will stop executing until
it regains focus. Other threads may not be suspendable and might be running concurrently with yours, however. KnightOS uses
a preemptive context swich, which means you do not have to do anything special to sacrifice control to other threads - it is
done for you. However, it requires interrupts. To ensure smooth operation, please do not disable interrupts unless it is
strictly necissary.

A maximum of 10 threads may execute simultaneously. Note that suspended threads count against this number. Try to avoid 
creating lots of threads in your program, as they are very expensive and will detract from your user experience. 10 concurrent
non-suspendable threads will create a heavy tax on the system and will noticably reduce responsiveness, especially on 6 MHz
calculators. Whenever possible, use suspendable threads. Luckily, the circumstances when you may need several non-suspendable
threads are rare, and the system is set up to make it easy to comply with these guidelines.