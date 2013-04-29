# Using the KnightOS kernel as a standalone project

The KnightOS kernel does not depend on the KnightOS userspace, which is responsible for presenting everything
to the user. As such, you are able to create a unique experience with your own OS, built on the powerful
KnightOS kernel as a standalone project. In order to do this, you should clone KnightOS and do the following
things:

1. Remove all files and folders in `lang/`
2. Create `lang/en_us` (empty folder, used by the build process as the default language)
3. Remove all files in `inc/`, except for:
  * `defines.inc` - used by the kernel, the kernel will not build without it
  * `macros.inc` - provides kernel macros like kcall and icall
  * `keys.inc` - provides key mappings from the kernel keyboard routines
  * `kernel.inc` - kernel routines. Even if you remove this, it'll be generated again anyway
4. Remove the contents of src/userspace/

Once you've done this, everything KnightOS-specific will be gone. However, you need to add some of your own
stuff to get it to boot up. When the kernel starts up the system, it runs `/bin/init`. You need to set up the
userspace again to assemble everything properly and create the filesystem, and provide an init program.

First, copy this file to `src/userspace/build.cfg` for a basic build configuration:

    # Clean up previous build, set up for this one
    rm out/
    mkdir out/bin/

    # /bin/
    asm bin/init.asm out/bin/init

    # Clean up
    rm out/bin/init.sym out/bin/init.lst

    fscreate out/

You should read the [build tool docs](https://github.com/KnightSoft/KnightOS/tree/master/docs/build). This configuraiton
will set up your userspace in a similar way to KnightOS - it will create the root of the on-calc filesystem in
`src/userspace/out/` and create a filesystem based on it with `fscreate out/`. You then need to create the init program.
This build configuration expects it to be in `src/userspace/bin/init.asm`. Create this file, and populate it with this:

    .nolist
    #include "kernel.inc"
    #include "macros.inc"
    .list
    ; Header
        .db 0
        .db 10 ; Stack size
    ; Program
    .org 0
        jr start

    start:
        ; Boot status codes
        or a ; cp 0
        ret nz

        ; Handle boot up

        ; ...

        ; Temporary code so you know everything worked
        ; Replace this with proper initialization code
        call getLcdLock
        call allocScreenBuffer
        kld(hl, sprite)
        ld de, 0
        ld b, 5
        call putSpriteOR
        call fastCopy

        jr $

    sprite:
        .db %01010000
        .db %01010000
        .db %00000000
        .db %10001000
        .db %01110000

This simile init program will just put a smiley face on the screen so you know that you've set everything up properly.
You should replace this with proper initialization code. For inspiration, you might look to the KnightOS init program,
whose source code is [here](https://github.com/KnightSoft/KnightOS/blob/master/src/userspace/bin/init.asm).

The kernel will run `/bin/init` after boot under certain conditions, with a status code based on those conditions. The
A register always contains the status code, and is set to 0 when booting up normally. You should be able to just skip
all of these unless you need them at some point.

Once you've added your init program, you should be able to compile and boot up your OS. Run `build --verbose --all` from
the `build/` directory to build, like you would with KnightOS.

You may have interest in [KnightOS-deriv](https://github.com/KnightSoft/KnightOS-Deriv), which is a simple example operating
system based on the KnightOS kernel. It is likely to use an outdated kernel, however, so it is advised that you follow the
above steps manually and simply use -deriv as a reference.

## Libraries and KnightOS compatibility

It is possible to retain compatibility with KnightOS programs in your OS. Though not all programs will work between both
(any programs that depend on libraries or programs specific to KnightOS will not work), you can re-implement some KnightOS
libraries yourself and retain support for KnightOS programs. This includes 3rd party programs that target KnightOS, and
programs internally used in KnightOS, such as the thread list.

*Note: KnightOS uses a header format that is not related to the kernel header. You may want to re-implement this header
format in your own OS if you wish to have support for icons and descriptions in KnightOS programs.*

KnightOS uses the MIT license, which permits reuse of its code in unrelated projects. As such, you may find it useful to
include libtext and stdio in your OS, to speed up development. You may also provide your own implementations - simply
duplicate the jump table and KnightOS programs will seamlessly be able to use your alternative libraries.
