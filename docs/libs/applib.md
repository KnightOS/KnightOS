# applib Documentation

applib provides several features specific to KnightOS, including access to the Castle and thread switcher, as
well as routines for providing UIs based on the standard KnightOS UI.

The source for applib may be found in
[src/userspace/lib/applib/](https://github.com/KnightSoft/KnightOS/tree/master/src/userspace/lib/applib).

If you are interested in writing applications that use the UI framework, you should consider reading the UI
application tutorial. (TODO)

The following routines are available:

* [appGetKey](#appgetkey)
* [appWaitKey](#appwaitkey)
* [drawWindow](#drawwindow)
* [getCharacterInput](#getcharacterinput)
* [drawCharSetIndicator](#drawcharsetindicator)
* [setCharSet](#setcharset)
* [getCharSet](#getcharset)
* [launchCastle](#launchCastle)
* [launchThreadList](#launchThreadList)

## appGetKey

Provides a layer on top of the kernel getKey routine, listening for UI hotkeys.

*Outputs*

* **A**: Pressed key

*Notes*

If F1 or F5 is pressed, the application is suspended and control is given to the Castle or Thread List,
respectively.

## appWaitKey

Provides a layer on top of the kernel waitKey routine, listening for UI hotkeys.

*Outputs*

* **A**: Pressed key

*Notes*

If F1 or F5 is pressed, the application is suspended and control is given to the Castle or Thread List,
respectively.

## drawWindow

Draws the standard UI window chrome. Usually called by the built-in UI stack.

*Inputs*

* **HL**: Window title string
* **A**: Window flags
    * **A[0]**: Set to skip castle graphic
    * **A[1]**: Set to skip thread list graphic
    * **A[2]**: Set to draw menu graphic *(note the opposite usage)*
* **IY**: Screen buffer

*Outputs*

![Sample Window](http://i.imgur.com/gFnoR.png)

## getCharacterInput

Gets an ANSI character from the keyboard, with standard UI character set usage.

*Outputs*

* **A**: ANSI character
* **B**: Raw key code

*Notes*

This routine draws the selected character set in the upper-right corner of the screen. It also
watches for F1/F5 hotkeys and launches the castle or thread list if needed.

## drawCharSetIndicator

Draws the indication sprite for the current character set on the pre-drawn window.

## setCharSet

Manually sets the selected character set.

*Inputs*

* **A**: Character set

*Notes*

Valid character sets include:

* 0: Uppercase
* 1: Lowercase
* 2: Symbol
* 3: Extended

## getCharSet

Gets the selected character set.

*Outputs*

* **A**: Selected character set

## launchCastle

Suspends the current thread and launches the castle.

*Outputs*

* **A**: 0

## launchThreadList

Suspends the current thread and launches the thread list.

*Outputs*

* **A**: 0
