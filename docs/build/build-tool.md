# Build Tool

The build tool is a .NET tool written in C# to assist in building KnightOS from source. It performs the following tasks:

* Assemble files with [sass](http://github.com/SirCmpwn/sass/)
* Handle various platform and locale retargeting
* Create ROM and 8xu (or 73u) files, and sign the finished OS
* Create the kernel jump table and include files
* Create the base filesystem and import the userspace files

The source code for the build tool may be found in [build/tool/](https://github.com/KnightSoft/KnightOS/tree/master/build/tool/).

## Usage

    [mono] build.exe [parameters...]

Include "mono" if you use it on Linux or Mac. You must first install Mono if you are on these platforms. The default usage,
with no parameters, is to build the TI-84+ Silver Edition version in English. You may supply the following parameters:

    --all: Build for all supported platforms in English.
    --configuration [target]: Change the target platform configuration.
    --language [language]: Changes the target locale of the build.
    --verbose: Output all sass output to the console.

### Configurations

The possible configuration values are the following:

* TI73
* TI83p
* TI83pSE
* TI84p
* TI84pSE

*Note*: Providing --all will build all of these configurations, in this order.

The tool will use the appropriate signing key based on this selection, as well as defining the configuration value at assembly
time. [inc/defines.inc](https://github.com/KnightSoft/KnightOS/blob/master/inc/defines.inc) will add additional defined values
at assembly time based on the configuration value. The default value is TI84pSE.

KnightOS does not use the same binary to target all platforms. For the sake of optimization, a different binary is distributed
for each target platform.

### Languages

The language selection is the name of a folder in [lang/](https://github.com/KnightSoft/KnightOS/blob/master/lang/). This folder
will be added to the include path for sass, and "lang_[language]" will be defined at assembly time. The default is en_us.

## Build Files

The build tool uses configuration files, which are simple scripts, to determine how it will build the OS. For example, a selection
from the kernel build configuration can be seen here:

    asm 00/base.asm 00.out
    asm privileged/base.asm privileged.out
    asm boot/base.asm boot.out
    link 00.out 0000 4000

    if TI73
        link privileged.out 70000 4000
        link boot.out 7C000 4000
        pages 00 1C
    endif
    # ...
    if TI84pSE
        link privileged.out 1F0000 4000
        link boot.out 1FC000 4000
        pages 00 7C
    endif

    # Jump table and include files
    echo Creating kernel jump table
    load 00.lab
    jump include boot
    jump include reboot
    # ...
    jump include hasUsbLock
    jump include resumeThread
    jump finish 4000 ../../inc/kernel.inc

    # Clean up
    rm 00.out 00.out.lst 00.out.lab
    rm privileged.out privileged.out.lst privileged.out.lab
    rm boot.out boot.out.lst boot.out.lab

It is similar to scripting languages you've seen before, but less powerful and not suitable for use outside of the KnightOS build
process. The following commands are available:

* asm \[input] \[output]: Assembles the specified file with sass and outputs it to \[output].
* cp \[from] \[to]: Copies the \[from] file to \[to].
* echo \[text]: Echos \[text] to the console during the build.
* endif: Closes the corresponding if statement.
* fscreate \[path]: \[path] must be a directory. This directory will be copied into the final output and formatted as a KFS disk.
* if \[configuration]: If the specified \[configuration] is not the target, the script will be ignored until endif. This may not be
  nested.
* jump include \[label]: Adds the label specified to the jump table. This label must be loaded via the load command.
* jump finish \[address] \[include file]: Creates the jump table, starting at \[address] and working backwards. Also outputs an
  include file to \[include file] with equates for each label that point to locations in the jump table.
* link \[file] \[target] \[length]: Copies the first \[length] bytes from \[file] to the final ROM at \[target].
* load \[file]: Loads the labels in the specified file into the build tool's memory for use when creating jump tables and include
  files.
* mkdir \[name]: Creates the directory specified.
* pages \[hex...]: Adds the specified pages, in hex, to the final 8xu or 73u files.
* rm \[targets...]: Deletes \[targets...], either files or directories.

The build tool will first build [src/kernel/build.cfg](https://github.com/KnightSoft/KnightOS/blob/master/src/kernel/build.cfg), then
[src/userspace/build.cfg](https://github.com/KnightSoft/KnightOS/blob/master/src/userspace/build.cfg).

## Include Files

sass will be instructed to add [inc/](https://github.com/KnightSoft/KnightOS/blob/master/inc/) to the include path, as well as the
selected language folder in [lang/](https://github.com/KnightSoft/KnightOS/blob/master/lang/).

## Output

The build tool outputs the final files to `bin/<configuration>/KnightOS-<locale>.[rom|8xu|73u]`.

8xu and 73u files are signed with one of the keys in [build/](https://github.com/KnightSoft/KnightOS/blob/master/build/), based on
the configuration value.
