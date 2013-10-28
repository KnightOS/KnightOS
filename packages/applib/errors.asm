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

msg_outOfMem:
    .db "Error:\nOut of memory", 0
msg_tooManyThreads:
    .db "Too many apps\nare already\nopen.", 0
msg_streamNotFound:
    .db "The stream\ncannot be\nfound.", 0
msg_endOfStream:
    .db "Error:\nEnd of stream", 0
msg_fileNotFound:
    .db "Error:\nFile not found.", 0
msg_tooManyStreams:
    .db "Too many\nfiles are\nopen.", 0
msg_noSuchThread:
    .db "The specified\napp is not\nopen.", 0
msg_tooManyLibraries:
    .db "Too many\nlibraries have\nbeen loaded.", 0
msg_unsupported:
    .db "This is not\nsupported on\nyour device.", 0
msg_tooManySignals:
    .db "Error:\nToo many\nsignals", 0

dismissOption:
    .db 1
    .db "Dismiss", 0
