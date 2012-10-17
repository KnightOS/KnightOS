# Kernel Keyboard Routines

The kernel provides several routines for interfacing with the keyboard.

*Note*: An include file is provided in 
[inc/keys.inc](https://github.com/SirCmpwn/KnightOS/blob/master/inc/keys.inc) that
includes all key codes used by the kernel.

* [flushKeys](#flushkeys)
* [getKey](#getkey)
* [waitKey](#waitkey)

The code for these routines may be found in
[src/kernel/00/keyboard.asm](https://github.com/SirCmpwn/KnightOS/blob/master/src/kernel/00/keyboard.asm).

# flushKeys

**Address**: 0x3FD3

Waits for all keys to be released, then returns.

*Notes*

This does not detect the ON key.

# getKey

**Address**: 0x3FD6

Returns the key that is currently pressed, or zero if no keys are pressed.

*Outputs*

* **A**: Key code

*Notes*

This does not detect the ON key.

# waitKey

Waits for a key to be pressed, then returns the key code of the pressed key.

*Outputs*

* **A**: Key code

*Notes*

This does not detect the ON key.