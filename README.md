# KnightOS

KnightOS is a 3rd party operating system for the following Texas Instruments calculators:

* TI-73
* TI-83+
* TI-83+ Silver Edition
* TI-84+
* TI-84+ Silver Edition

It aims to provide a unix-like enviornment with multitasking and a tree-based filesystem,
in addition to generally being a better experience than the official TIOS.

## Building

In build/, run "build" from the command line. You can use "build --help" for more information.
The default configuration is TI84pSE, or TI-84+ Silver Edition. If you have a different
calculator, refer to --help for information on building for your model.

*Note for Linux/Mac users*: Wait a few days for me to update the build tool. Then, install mono
and run it the same as you would on Windows, but with "mono" at the start. Think of it like
Java.

## Installing

When you build from source, ROM files for emulation are output to bin/<configuration>/KnightOS.rom.
8xu files are output to bin/<configuration>/KnightOS.8xu, signed and ready for transfer to actual
hardware. Basically, if you just want an installable version, do this from the command line:

    $ cd build/
    $ build --configuration <your calculator model>

<your calculator model> can be one of the following values:

* TI73
* TI83p
* TI83pSE
* TI84p
* TI84pSE

You install KnightOS at your own risk.