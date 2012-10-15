# Patching Boot Code 1.03

TI calculators have a boot code that handles various tasks, including recieving operating systems.
The latest version, boot code 1.03, is not directly compatible with KnightOS. In order to install
KnightOS on such devices, you must first run a tool to patch the boot code. In order to determine
your boot code, you should do the following tasks from the home screen of the default operating
system:

1. Press `[MODE]`, then `[ALPHA]`, then `[LN]`
2. Your boot code version will be shown on the top of the screen.

If your boot code is version 1.03, then you must run this patch before installing
KnightOS.

**WARNING**: This is a somewhat dangerous activity. While extremely unlikely to encounter problems,
this patch will modify a section of the calcualtor that is usually protected from modification. If
something were to go wrong, this could potentially permanently render your calculator unusable.
That being said, such a scenario is extremely unlikely, but proceed at your own risk.

## Instructions

Please download [patch.8xp](https://github.com/SirCmpwn/KnightOS/tree/master/boot-patch/patch.8xp)
and transfer it to your calcultor with TI-Connect, TILP, or a similar program. When the transfer
completes, do the following from the home screen:

1. Press `[2nd]+[0]` to open the catalog.
2. Scroll down with the arrow keys and press `[Enter]` to select `Asm(`
3. Press `[PRGM]` to open the program menu.
4. Scroll down with the arrow keys and press `[Enter]` to select `PATCH`
5. Press `[Enter]`
6. Read the information provided. If it is all correct, press `[ALPHA]+[1]` to confirm.
   You may press `[ALPHA]+[LOG]` if you choose not to install the patch.

Once you have completed these instructions, you should be able to install KnightOS normally.

Credit to [Brandon Wilson](http://brandonw.net/) for providing the patch.

## Boot Code 1.04+

If your calculator's boot code version is greater than 1.03, this patch will not work for you. However,
you may be able to find a patch that will work. Search Google and you may find what you are looking for.