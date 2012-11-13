# libtext Documentation

libtext is a library for graphically drawing text on an LCD buffer. It is located at `/lib/libtext` on a normal KnightOS installation.

The source for libtext may be found in
[src/userspace/lib/libtext/](https://github.com/SirCmpwn/KnightOS/tree/master/src/userspace/lib/libtext).

libtext uses the ANSI character set.

The following routines are available:

* [drawChar](#drawchar)
* [drawCharAND](#drawcharand)
* [drawCharXOR](#drawcharxor)
* [drawStr](#drawstr)
* [drawStrAND](#drawstrand)
* [drawStrXOR](#drawstrxor)
* [drawStrFromStream](#drawstrfromstream)
* [drawHexA](#drawhexa)
* [measureChar](#measurechar)
* [measureStr](#measurestr)

## drawChar

Draws a single character to the screen with OR logic (black).

*Inputs*

* **A**: Character to draw
* **D, E**: X, Y
* **B**: Left margin
* **IY**: Screen buffer

*Notes*

This will advance D, E as required. If \n is printed, D will be updated to B, or the left margin.

## drawCharAND

Draws a single character to the screen with AND logic (white).

*Inputs*

* **A**: Character to draw
* **D, E**: X, Y
* **B**: Left margin
* **IY**: Screen buffer

*Notes*

This will advance D, E as required. If \n is printed, D will be updated to B, or the left margin.

## drawCharXOR

Draws a single character to the screen with XOR logic (inverted).

*Inputs*

* **A**: Character to draw
* **D, E**: X, Y
* **B**: Left margin
* **IY**: Screen buffer

*Notes*

This will advance D, E as required. If \n is printed, D will be updated to B, or the left margin.

## drawStr

Draws a zero-delimited string to the screen with OR logic (black).

*Inputs*

* **HL**: String to draw
* **D, E**: X, Y
* **B**: Left margin
* **IY**: Screen buffer

*Notes*

This will advance D, E as required. If \n is printed, D will be updated to B, or the left margin.

## drawStrAND

Draws a zero-delimited string to the screen with AND logic (white).

*Inputs*

* **HL**: String to draw
* **D, E**: X, Y
* **B**: Left margin
* **IY**: Screen buffer

*Notes*

This will advance D, E as required. If \n is printed, D will be updated to B, or the left margin.

## drawStrXOR

Draws a zero-delimited string to the screen with XOR logic (inverted).

*Inputs*

* **HL**: String to draw
* **D, E**: X, Y
* **B**: Left margin
* **IY**: Screen buffer

*Notes*

This will advance D, E as required. If \n is printed, D will be updated to B, or the left margin.

## drawStrFromStream

Draws a zero-delimited string to the screen from a file stream, with OR logic (black).

*Inputs*

* **B**: Stream ID
* **D, E**: X, Y
* **IY**: Screen buffer

*Notes*

This advances the stream pointer to the end of the string (the byte after the zero).

## drawHexA

Draws the value of A in hexadecimal notation to the screen, with OR logic (black).

*Inputs*

* **A**: Value to draw
* **D, E**: X, Y
* **IY**: Screen buffer

## measureChar

Gets the width of a character's sprite.

*Inputs*

* **A**: Character

*Outputs*

* **A**: Width in pixels

*Notes*

All characters have a height of 5 pixels. The width often includes a column of blank pixels on the right of the sprite.

## measureStr

Gets the width of a zero-delimited string.

*Inputs*

* **HL**: String to measure

*Outputs*

* **A**: Width of string, in pixels

*Notes*

All strings have a height of 5 pixels, except for strings that use \n, which aren't handled by this routine.