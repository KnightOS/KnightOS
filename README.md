# KnightOS

[![builds.sr.ht status](https://builds.sr.ht/~pixelherodev/knightos.svg)](https://builds.sr.ht/~pixelherodev/knightos?)

**KnightOS** is a third-party operating system for TI calculators. It provides a
passable Unix-like system for calculators. KnightOS is built on top of [the
KnightOS kernel](https://github.com/KnightOS/kernel) - this repository is the
official userspace. KnightOS runs on the following calculators:

* TI-73
* TI-83+
* TI-83+ Silver Edition
* TI-84+
* TI-84+ Silver Edition
* TI-84+ Color Silver Edition

KnightOS also runs on the French variations of these same calculators.

## What is this repository?

All of the pieces of KnightOS are maintained as separate projects under the
KnightOS organization [on GitHub](https://github.com/KnightOS). This project
exists to tie them all together. The `package.config` file lists the packages
that are installed on the default userspace. The KnightOS SDK is used to install
these packages, and then the default KnightOS settings are installed on top of
that. Additionally, this builds upgrade files and applies any required exploits.

## Compiling

To compile KnightOS, first install the KnightOS SDK. Instructions for the SDK
installation can be found [on the website](https://knightos.org/sdk).

In addition to the SDK, you will need
[mktiupgrade](https://github.com/KnightOS/mktiupgrade),
[sass](https://github.com/KnightOS/sass) and [kimg](https://github.com/KnightOS/kimg).

Then, run the following:

    knightos init --platform=<platform>

Change `<platform>` to the appropriate platform for your needs:

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

Then you can use various make targets to compile the system:

    make            # Compiles and places a ROM file in bin/
    make upgrade    # Compiles and places an upgrade file in bin/
    make run        # Compiles and runs in an emulator
    make debug      # Compiles and runs in a debugger

If you just want something you can install on your calculator, try `make
upgrade` and check the `bin/` directory. Installation instructions are available
online at http://www.knightos.org/download.

## Custom Kernels

You can use a custom kernel during development if you like. Add
`--kernel-source=/path/to/your/kernel` to `knightos init`. You will, of course,
need to install all of the kernel's dependencies for this to work.

## Help, Bugs, Feedback

If you need help with KnightOS, want to keep up with progress, chat with
developers, or ask any other questions about KnightOS, you can hang out in the
IRC channel: [#knightos on irc.freenode.net](https://webchat.freenode.net/?channels=knightos).
You can also subscribe to our [mailing list](http://lists.knightos.org/).

To report bugs, please create [a GitHub issue](https://github.com/KnightOS/KnightOS/issues/new) or contact us on [IRC](https://webchat.freenode.net/?channels=knightos).

If you'd like to contribute to the project, please see the [contribution guidelines](http://www.knightos.org/contributing).
