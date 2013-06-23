characterMapUppercase:
    ; $9 = Enter
    .db '\n', '"', 'W', 'R', 'M', 'H', 0x08, 0 ; 0x08 is Backspace, which is mapped to CLEAR
    ; Theta
    .db '?', 0, 'V', 'Q', 'L', 'G', 0, 0
    .db ':', 'Z', 'U', 'P', 'K', 'F', 'C', 0
    .db ' ', 'Y', 'T', 'O', 'J', 'E', 'B', 'X'
    ; ON
    .db 0, 'X', 'S', 'N', 'I', 'D', 'A', 0

characterMapLowercase:
    ; $9 = Enter
    .db '\n', '"', 'w', 'r', 'm', 'h', 0x08, 0
    ; Theta
    .db '?', 0, 'v', 'q', 'l', 'g', 0, 0
    .db ':', 'z', 'u', 'p', 'k', 'f', 'c', 0
    .db ' ', 'y', 't', 'o', 'j', 'e', 'b', 'x'
    ; ON
    .db 0, 'x', 's', 'n', 'i', 'd', 'a', 0

characterMapSymbol:
    ; $9 = Enter
    .db '\n', '+', '-', '*', '/', '^', 0x08, 0
    .db '-', '3', '6', '9', ')', 0, 0, 0
    .db '.', '2', '5', '8', '(', 0, 0, 0
    .db '0', '1', '4', '7', ',', 0, 0, 0
    .db 0, 0, 0, 0, 0, 0, 0, 0

characterMapExtended:
    ; $9 = Enter
    .db '\n', '\'', ']', '[', '\\', '_', 0x08, 0
    .db '-', '3', '6', '9', '}', '>', '`', 0
    .db 'i', '2', '5', '8', '{', '<', '|', 0
    .db '0', '1', '4', '7', ',', 0, 0, 0
    .db 0, '&', '%', '$', '#', '@', '!', 0
