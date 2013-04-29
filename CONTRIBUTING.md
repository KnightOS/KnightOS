# Contributing to KnightOS

If you wish to contribute, please create a fork and submit pull requests. If your pull requests are
frequent and high-quality and you wish to have a deeper role in the project, you should get in touch
and you may be granted access to the repository and assigned tasks.

It's also worth noting that small changes are better than broad ones. The all pull requests are
inspected before merging them, and huge diffs are a pain to inspect and will be rejected. Your code
should also be tidy and understandable - this is assembly, after all.

## Code Style

A small bit of example code is shown below:

    labelName:
        ld a, 10 + 0x13
        push af
        push bc
            add a, b
            jr c, labelName
        pop bc
        pop af
    .localLabel
        dec a
        cp 10
        jr z, .localLabel
        ret

Some important notes:

* All instructions should be in lowercase.
* Spaces after commas and between operators (+, -, etc)
* Indent with respect to the stack. You may group push/pop operations before indenting.
* Indent with four spaces, not tabs.
* Use local labels (labels preceeded with a '.') whenever possible.
* Use 0xHEX for hexadecimal literals, not $HEX or HEXh. Also use 0bBINARY.

## Functional Guidelines

All kernel routines should keep all registers intact, aside from those it returns values in.

## Documentation

All kernel routines that are included in the jump table should have the following text preceed
their label:

    ;; functionName [Category]
    ;;  Description
    ;; Inputs:
    ;;  HL: Something
    ;;  A: Something else
    ;; Outputs:
    ;;  BC: Something
    ;; Notes:
    ;;  Lorem ipsum
    functionName:

You may omit any section it has no contents. For example, routines with no input would not need
an "Input" section. Additionally, you do not have to simply list registers - you can also include
flags, or other forms of input/output.

The "description" field may be in markdown format. If you wish to link to another function, use
this format: [[functionName]].

Here's an example for "fastCopy":

    ;; fastCopy [Display]
    ;;  Copies the contents of a 768 byte buffer to the LCD.
    ;; Inputs:
    ;;  IY: Screen buffer
    ;; Outputs:
    ;;  Buffer is drawn to the LCD
    ;; Notes:
    ;;  You must have an LCD lock for this function to work properly. Otherwise, it will simply
    ;;  return without drawing to the screen. You may acquire an LCD lock with [[getLcdLock]].
    fastCopy:

Do not use the `;;` comment syntax outside of documentation.
