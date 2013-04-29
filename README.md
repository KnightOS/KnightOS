# KnightOS

KnightOS is a 3rd party Operating System for Texas Instruments z80 calculators. It offers
many features over the stock OS, including multitasking, a tree-based filesystem, delivered
in a Unix-like enviornment. KnightOS is written entirely in z80 assembly, with a purpose-
built toolchain. Additionally, the KnightOS kernel is standalone, and you can use it as the
basis for your own powerful operating systems.

## Building KnightOS

Precompiled packages are not currently being distributed. However, you may build KnightOS from
its source yourself. From a command line, navigate to the build directory. On Windows, run
`build --all` to build KnightOS for all calculators. On Linux/Mac, install Mono. Then, run
`mono build.exe --all`. You may want to change some details in `inc/config.asm` to customize
some aspects of KnightOS.

Once the build completes, look in `bin/` for the completed OS upgrade files, which are signed
and ready to send to a calculator. ROM files will also be generated for use in emulators.

For details on advanced usage of the build tool, see
[its documentation](https://github.com/KnightSoft/KnightOS/blob/master/docs/build/build-tool.md).
This documentation includes details on building for specific platforms, and targetting
languages other than English.

## Installation

When you have produced a KnightOS 8xu (or 73u) upgrade file, you may send it to your calculator.
**Installing KnightOS will clear all memory on your calculator, including the TIOS Archive.**
First, install TI-Connect (Windows/Mac) or TILP (Windows/Linux/Mac) to facilitate the transfer.
Remove one battery from your calculator for a moment, hold down the `DEL` key, and replace the
battery. Plug your calculator into the computer.

*TI-Connect*: Use "TI OS Downloader" to install KnightOS.

*TILP*: Run `tilp path/to/KnightOS.8xu` as root to install KnightOS.

You may repeat this procedure with the official OS upgrade file to install the stock OS again.

## Supported Devices

The following devices are supported:

* TI-73 [TI73]
* TI-73 Explorer [TI73]
* TI-83+ [TI83p]
* TI-83+ SE [TI83pSE]
* TI-84+ [TI84p]
* TI-84+ SE [TI84pSE]
* TI-84 Pocket.fr [TI84p]
* TI-84 Plus Pocket SE [TI84pSE]

Indicated next to each device is the name used internally. The files for this device appear in
`bin/<device>` when built with the instructions above. Use these files if you wish to install
KnightOS on those devices.

**NOTE**: Newer versions of the TI-84+, TI-84+ SE, and all TI-84 Pocket.fr and TI-84 Plus Pocket SE
calculators are shipped with boot code 1.03, which prevents the installation of 3rd party operating
systems. You must patch these calculators before you will be able to install KnightOS on them.
Instructions for doing so may be found [here](https://github.com/KnightSoft/KnightOS/tree/master/boot-patch).

## Help, Bugs, Feedback

If you need help with KnightOS, want to keep up with progress, chat with developers, or learn
ask any other questions about KnightOS, you can drop by the IRC channel: [#knightos on
irc.freenode.net](http://webchat.freenode.net/?channels=knightos).

To report bugs, please create [a GitHub issue](https://github.com/KnightOS/KnightOS/issues/new)
or contact us on IRC.
