# Kernel General Routines

The kernel provides a large number of general-purpose routines to accomplish miscellaneous
tasks.

* [boot](#boot)
* [compareStrings](#comparestrings)
* [convertTimeFromTicks](#converttimefromticks)
* [cpHLDE](#cphlde)
* [cpHLBC](#cphlbc)
* [cpBCDE](#cpbcde)
* [cpDEBC](#cpdebc)
* [DEMulA](#demula)
* [div32By16](#div32by16)
* [divACbyDE](#divacbyde)
* [divHLbyC](#divhlbyc)
* [getBatteryLevel](#getbatterylevel)
* [getBootCodeVersionString](#getbootcodeversionstring)
* [getTime](#gettime)
* [getTimeInTicks](#gettimeinticks)
* [quicksort](#quicksort)
* [reboot](#reboot)
* [stringLength](#stringlength)
* [sub16from32](#sub16from32)
* [setClock](#setclock)

The code for these routines may be found in 
[src/kernel/00/util.asm](https://github.com/SirCmpwn/KnightOS/blob/master/src/kernel/00/util.asm),
and in
[src/kernel/00/time.asm](https://github.com/SirCmpwn/KnightOS/blob/master/src/kernel/00/time.asm),
and in
[src/kernel/00/boot.asm](https://github.com/SirCmpwn/KnightOS/blob/master/src/kernel/00/boot.asm).

## boot

**Address**: 0x3FFD

Shuts down the device.

*Notes*

This routine will never return. You should run it with RST 0 instead of CALL.

## compareStrings

**Address**: 0x3F7F

Compares two zero-delimited strings. May also be used to compare any arbituary zero-
delimited data.

*Inputs*

* **HL**: String 1
* **DE**: String 2

*Outputs*

* **Z**: Set if equal, reset otherwise

## convertTimeFromTicks

**Address**: 0x3F28

Converts the specified time in ticks to month, day, year, etc.

*Inputs*

* **HLDE**: Time in seconds since January 1st, 1997

*Outputs*

* **H**: Day
* **L**: Month
* **B**: Hour
* **C**: Minute
* **D**: Second
* **A**: Day of week (0-6, 0 is Monday)
* **IX**: Year

## convertTimeToTicks

**Address**: 0x3EE9

Converts the given values to a time in ticks.

*Inputs*

* **H**: Day
* **L**: Month
* **B**: Hour
* **C**: Minute
* **D**: Second
* **A**: Day of week (0-6, 0 is Monday)
* **IX**: Year

*Outputs*

* **HLDE**: Time in seconds since January 1st, 1997

## cpHLDE

**Address**: 0x3F94

Compares HL to DE.

*Inputs*

* **HL**
* **DE**

*Outputs*

* Flags are modified as defined.

## cpHLBC

**Address**: 0x3F91

Compares HL to BC.

*Inputs*

* **HL**
* **BC**

*Outputs*

* Flags are modified as defined.

## cpBCDE

**Address**: 0x3F8E

Compares BC to DE.

*Inputs*

* **BC**
* **DE**

*Outputs*

* Flags are modified as defined.

## cpDEBC

**Address**: 0x3F8B

Compares DE to BC.

*Inputs*

* **DE**
* **BC**

*Outputs*

* Flags are modified as defined.

## DEMulA

**Address**: 0x3F82

Multiplies DE by A.

*Inputs*

* **DE**
* **A**

*Outputs*

* **HL**: DE * A

## div32By16

**Address**: 0x3F3D

Divides ACIX by DE and stores the remainder in HL.

*Inputs*

* **ACIX**: Dividend
* **DE**: Divisor

*Outputs*

* **ACIX**: Quotient
* **HL**: Remainder

## divACbyDE

**Address**: 0x3F34

Divides AC by DE and stores the remainder in HL.

*Inputs*

* **AC**: Dividend
* **DE**: Divisor

*Outputs*

* **AC**: Quotient
* **HL**: Remainder

## divHLbyC

**Address**: 0x3F37

Divides HL by C and stores the remainder in A.

*Inputs*

* **HL**: Dividend
* **C**: Divisor

*Outputs*

* **HL**: Quotient
* **A**: Remainder

## getBatteryLevel

**Address**: 0x3F85

Gets the current battery level.

*Outputs*

* **B**: Value from 0-4, where 0 is critical

*Notes*

This is less accurate on the following platforms:

* TI-73
* TI-73 Explorer
* TI-83+

## getBootCodeVersionString

**Address**: 0x3F01

Gets the boot code version string and loads it into memory.

*Outputs*

* **HL**: Pointer to version string

*Notes*

You should call
[freeMem](https://github.com/SirCmpwn/KnightOS/blob/master/docs/kernel/routines/memory.md#freemem)
when you are done with the string to free memory.

This assumes that the string is at 0xF of the boot page, which is true for all
official TI boot codes.

## getTime

**This routine is only available on the platforms listed [here](#clock-platforms).**

**Address**: 0x3F2B

Gets the current time.

*Outputs*

* **H**: Day
* **L**: Month
* **B**: Hour
* **C**: Minute
* **D**: Second
* **A**: Day of week (0-6, 0 is Monday)
* **IX**: Year

## getTimeInTicks

**This routine is only available on the platforms listed [here](#clock-platforms).**

**Address**: 0x3F31

Gets the current time in ticks.

*Outputs*

* **HLDE**: Time in ticks

## quicksort

**Address**: 0x3F7C

Sorts a list of bytes in ascending order.

*Inputs*

* **BC**: First byte included in range to sort
* **DE**: Last byte included in range to sort

*Notes*

This is a stack-based routine, and sorting high volumes of data may result in a
stack overflow.

## reboot

**Address**: 0x3FFA

Reboots the device without turning off the screen or waiting for the user to press \[ON].

*Notes*

This routine will never return. You should run it with JP instead of CALL.

## stringLength

**Address**: 0x3F88

Determines the length of a zero-delimited string.

*Inputs*

* **HL**: Pointer to string

*Outputs*

* **BC**: String length

## sub16from32

**Address**: 0x3F3A

Subtracts DE from ACIX.

*Inputs*

* **ACIX**
* **DE**

*Outputs*

* **ACIX**: ACIX - DE

## setClock

**This routine is only available on the platforms listed [here](#clock-platforms).**

**Address**: 0x3F2E

Sets the clock to the specified time in ticks.

*Inputs*

* **HLDE**: Time in seconds since January 1st, 1997

# Clock Platforms

The routines that get and set the system time are only available on the following platforms:

* TI-83+ Silver Edition
* TI-84+
* TI-84+ Silver Edition
* TI-84 Pocket.fr

Clock routines will simply set errUnsupported and return on unsupported devices.