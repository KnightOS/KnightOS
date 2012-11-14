# Kernel Thread Routines

The kernel provides a number of routines for creating, manipulating, and killing threads.

* [getCurrentThreadId](#getcurrentthreadid)
* [getThreadEntry](#getthreadentry)
* [killCurrentThread](#killcurrentthread)
* [killThread](#killthread)
* [launchProgram](#launchprogram)
* [resumeThread](#resumethread)
* [setInitialDE](#setinitialde)
* [setInitialHL](#setinitialhl)
* [setReturnPoint](#setreturnpoint)
* [startThread](#startthread)
* [suspendCurrentThread](#suspendcurrentthread)

The code for these routines may be found in
[src/kernel/00/thread.asm](https://github.com/SirCmpwn/KnightOS/blob/master/src/kernel/00/thread.asm).

## getCurrentThreadId

Retrieves the ID of the currently executing thread.

*Outputs*

* **A**: Current thread ID

## getThreadEntry

Gets a pointer to the specified thread in the kernel thread table.

*Inputs*

* **A**: Thread ID

*Outputs*

* **HL**: Pointer to entry in kernel thread table

*Possible Errors*

* errNoSuchThread

## killCurrentThread

Immediately kills the currently executing thread.

*Notes*

This may be used to kill sub-threads that are under your control. However, the correct
means of exiting a primary thread is generally to simply use RET. Many programs that
may launch your thread will set a custom return point, including the KnightOS terminal
and castle, via [setReturnPoint](#setreturnpoint).

This routine does not return; you should call it with JP instead of CALL.

## killThread

Immediately kills the specified thread.

*Inputs*

* **A**: Thread ID

*Possible Errors*

* errNoSuchThread

## launchProgram

Loads the given file into memory and executes it as a program.

*Inputs*

* **DE**: Pointer to file name

*Outputs*

* **A**: Thread ID

*Possible Errors*

* errOutOfMem
* errFileNotFound
* errTooManyThreads

*Notes*

The file specified must be a well-formed kernel program, with the correct header. The
header is used to determine how much stack memory to allocate, and the thread flags.

## resumeThread

Resumes execution of the specified suspended thread.

*Inputs*

* **A**: Thread ID

*Possible Errors*

* errNoSuchThread

*Notes*

Execution does not begin immediately after this is called. The thread will be resumed
on the next context switch.

## setInitialDE

Sets the value of DE at the time a new thread starts.

*Inputs*

* **A**: Thread ID
* **DE**: Initial value

## setInitialHL

Sets the value of HL at the time a new thread starts.

*Inputs*

* **A**: Thread ID
* **HL**: Initial value

## setReturnPoint

Overrides the default return point of the specified thread. The default is
[killCurrentThread](#killcurrentthread).

*Inputs*

* **A**: Thread ID
* **HL**: Pointer to return point

*Possible Errors*

* errNoSuchThread

*Notes*

If you wish to set the return point before launching the thread, disable interrupts with
DI before calling launchProgram or startThread. Re-enable interrupts when you wish for
context switching to resume, and your thread to be started.

## startThread

Starts a new thread.

*Inputs*

* **A**: Thread flags
* **B**: Stack size, divided by two
* **HL**: Pointer to start of thread

*Outputs*

* **A**: Thread ID

*Possible Errors*

* errOutOfMem
* errTooManyThreads

*Notes*

The maximum stack size for any new thread is 512. The system adds an additional 24 bytes to
the provided stack size, which is required for context switching.

If you wish to manipulate the thread before it begins (such as setting the return point, any
initial register values, or modifying thread flags), you may call startThread with interrupts
disabled (DI) and it will preserve the interrupt state. When you re-enable interrupts, the
next context switch cycle will begin the new thread.

## suspendCurrentThread

Suspends the executing thread.

*Notes*

It is impossible to return from this routine until a seperate thread resumes it.