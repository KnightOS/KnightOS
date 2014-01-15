# KnightOS

KnightOS is a 3rd party Operating System for Texas Instruments z80 calculators. It offers
many features over the stock OS, including multitasking, a tree-based filesystem, delivered
in a Unix-like enviornment. KnightOS is written entirely in z80 assembly, with a purpose-
built toolchain. Additionally, the [KnightOS kernel](https://github.com/KnightSoft/kernel)
is standalone, and you can use it as the basis for your own powerful operating systems.

## Building KnightOS

To build KnightOS from source, make sure you have all git submodules first. If you haven't
cloned the repository yet, use `git clone --recursive git://github.com/KnightSoft/KnightOS.git`
to clone recursively. Otherwise, use `git submodule update --init` to clone submodules for
an existing repository.

Once you have the source and submodules, run `make` from the root of the repository to build
KnightOS for the TI-84+ SE. You may specify a target (i.e. `make TI83p`) to build for another
calculator model. You may additionally specify a language (i.e. `make LANG=de`) to use a
language other than English. Your binaries will appear in the bin folder.

On Windows, run make from Cygwin.

## Installation

When you have produced a KnightOS 8xu (or 73u) upgrade file, you may send it to your calculator.
**Installing KnightOS will clear all memory on your calculator, including the TIOS Archive.**
First, install TI-Connect (Windows/Mac) or TILP (Windows/Linux/Mac) to facilitate the transfer.
Remove one battery from your calculator for a moment, hold down the `DEL` key, and replace the
battery. Plug your calculator into the computer.

*TI-Connect*: Use "TI OS Downloader" to install KnightOS.

*TILP*: Run `tilp path/to/KnightOS.8xu` as root to install KnightOS.

You may repeat this procedure with the official OS upgrade file to install the stock OS again.

### TI-84+ Color Silver Edition

For the TI-84+ CSE, the process is a bit more involved. You must first install the stock OS (or
just leave it there if you already have it). Then, download and install Brandon Wilson's
[UOSRECV](http://www.cemetech.net/forum/viewtopic.php?t=9111) tool. Run it with `Asm(prgmUOSRECV)`
on the target calculator. Then, you can send the KnightOS upgrade file to your TI-84+ CSE using
**TI-Connect only**. It does not work with TiLP. I have had success sending it with TI-Connect
in a VM, though.

## Supported Devices

The following devices are supported:

| Model                | `make` Target |
| -------------------- | ------------- |
| TI-73                | TI73          |
| TI-73 Explorer       | TI73          |
| TI-83+               | TI83p         |
| TI-83+ SE            | TI83pSE       |
| TI-84+               | TI84p         |
| TI-84+ SE            | TI84pSE       |
| TI-84+ CSE           | TI84pCSE      |
| TI-84 Pocket.fr      | TI84p         |
| TI-84 Plus Pocket SE | TI84pSE       |

The make target is listed next to each supported device. To build KnightOS for that device, use
`make [target]`.

## Help, Bugs, Feedback

If you need help with KnightOS, want to keep up with progress, chat with developers, or learn
ask any other questions about KnightOS, you can drop by the IRC channel: [#knightos on
irc.freenode.net](http://webchat.freenode.net/?channels=knightos).

To report bugs, please create [a GitHub issue](https://github.com/KnightSoft/KnightOS/issues/new)
or contact us on IRC.
