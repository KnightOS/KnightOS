# Userspace

KnightOS userspace is considered every file in the filesystem. The kernel is considered everything on
page 0, and is perpetually swapped in to bank 0. The filesystem is the remainder of Flash, and various
pages of the filesystem are swapped into bank 1 to facilitate reading and writing with it.

To build userspace, the build tool reads the
[userspace configuration](https://github.com/SirCmpwn/KnightOS/blob/master/src/userspace/build.cfg).
This file instructs it to build several files in
[src/userspace/](https://github.com/SirCmpwn/KnightOS/blob/master/docs/build/build-tool.md) and copy
them to src/out/. src/userspace/ is organized in a similar manner to how it appears in the final
filesystem. Once all files are assembled and copied, src/userspace/out/ becomes the root folder of
the filesystem installed on the final binaries.

In order to add additional userspace programs, you should create assembly files in src/userspace/, in
the correct location. If your program is complex and requires more than one file (such as libtext, or
the castle), you should give it a subdirectory. However, ensure that the output file is not placed
in its own subdirectory in the final filesystem - the castle goes to /bin/castle, and libtext to
/lib/libtext, even though both of them have several files in the userspace code.

Note that you can also add any non-assembly files or non-executables you require by simply adding them
to the appropriate place in src/userspace/ and adding a cp command to the build configuration to move
them to src/userspace/out/ where they are to be located in the final OS.

When you have added your files to the source, you should add an entry in the build configuration for
them to ensure they are assembled and moved into the output filesystem. Follow the model of the existing
entries:

    asm bin/castle/castle.asm out/bin/castle
    rm out/bin/castle.lab out/bin/castle.lst

Ensure that you remove extraneous files, such as .lab and .lst files.

## Adding to the Castle

If you want your program to appear in the castle, you need to update
[src/userspace/etc/castle.config](https://github.com/SirCmpwn/KnightOS/blob/master/src/userspace/etc/castle.config).