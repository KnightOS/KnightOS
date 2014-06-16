# KnightOS

KnightOS is a third-party Operating System for Texas Instruments z80 calculators. It offers
many features over the stock OS, including multitasking and a tree-based filesystem, delivered
in a Unix-like environment. KnightOS is written entirely in z80 assembly, with a purpose-built
toolchain. Additionally, the [KnightOS kernel](https://github.com/KnightOS/kernel) is
standalone, and you can use it as the basis for your own powerful operating systems.

You can download the latest (experimental) version here: http://www.knightos.org/download/

## Building KnightOS

To build KnightOS from source, make sure you have all git submodules first. If you haven't
cloned the repository yet, use `git clone --recursive git://github.com/KnightOS/KnightOS.git`
to clone recursively. Otherwise, use `git submodule update --init` to clone submodules for
an existing repository.

You also need to install the kernel's dependencies. See instructions in the
[kernel readme](https://github.com/KnightOS/kernel).

Once you have the source and submodules, run `make` from the root of the repository to build
KnightOS for the TI-84+ SE. You may specify a target (i.e. `make TI83p`) to build for another
calculator model. You may additionally specify a language (i.e. `make LANG=de`) to use a
language other than English. Your binaries will appear in the bin folder. You can use the ROM
files on an emulator like WabbitEmu, or send the 73u/8xu/8cu files to an actual device.

On Windows, run make from Cygwin. You also need git for Cygwin installed.

## Installation

See http://www.knightos.org/download/ for installation instructions.

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
`make [target]`. Use `make clean` before trying to build for a new target. On the TI-84+ Color
Silver Edition, you may want to use `make TI84pCSE UPGRADEEXT=8xu` if sending KnightOS to a
calculator using TiLP version 1.17 or less.

## Help, Bugs, Feedback

If you need help with KnightOS, want to keep up with progress, chat with developers, or
ask any other questions about KnightOS, you can hang out in the IRC channel: [#knightos on
irc.freenode.net](http://webchat.freenode.net/?channels=knightos).

To report bugs, please create [a GitHub issue](https://github.com/KnightOS/KnightOS/issues/new)
or contact us on IRC.
