launchErrorStr:
    .db lang_launchError
    .db " ", 0
colonStr:
    .db ": ", 0

errorMessages:
    .dw msg_outOfMem
    .dw msg_tooManyThreads
    .dw msg_streamNotFound
    .dw msg_endOfStream
    .dw msg_fileNotFound
    .dw msg_tooManyStreams
    .dw msg_noSuchThread
    .dw msg_tooManyLibraries
    .dw msg_unsupported
    .dw msg_tooManySignals
    .dw 0xFFFF

; These errors are similar to those found in error.asm in applib,
; but in general they are pithier and more technical.
msg_outOfMem:
    .db "Out of memory", 0
msg_tooManyThreads:
    .db "Too many threads", 0
msg_streamNotFound:
    .db "Stream not found", 0
msg_endOfStream:
    .db "End of stream", 0
msg_fileNotFound:
    .db "File not found", 0
msg_tooManyStreams:
    .db "Too many streams", 0
msg_noSuchThread:
    .db "No such thread", 0
msg_tooManyLibraries:
    .db "Too many loaded libraries", 0
msg_unsupported:
    .db "Unsupported on device", 0
msg_tooManySignals:
    .db "Too many signals", 0
