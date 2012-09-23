; /etc/castle.config

; Defines the icons on the castle home
; Format:
; Pointer to shortcut name, or 0xFFFF
; If first word is not $FFFF,
;   pointer to file name
;   16x16 icon

; Row 1
;.dw graphStr, todoPath
;.db $84, $01, $84, $02, $84, $04, $84, $08
;.db $44, $10, $44, $20, $44, $40, $24, $80
;.db $25, $00, $16, $00, $ff, $ff, $0d, $00
;.db $14, $80, $24, $80, $44, $40, $84, $40
.dw helloStr, helloPath
.db $a1, $b0, $a4, $92, $ea, $95, $ac, $95
.db $a6, $92, $00, $00, $00, $00, $02, $40
.db $02, $40, $02, $40, $00, $00, $08, $10
.db $04, $20, $03, $c0, $00, $00, $00, $00

.dw mathStr, todoPath
.db $10, $fe, $38, $80, $12, $be, $02, $94
.db $3a, $94, $01, $24, $00, $00, $7c, $28
.db $44, $08, $20, $10, $10, $20, $20, $28
.db $44, $00, $7c, $f0, $00, $00, $00, $f0

.dw blockDudeStr, todoPath
.db $c0, $ff, $a0, $81, $cc, $81, $aa, $81
.db $ca, $81, $0a, $81, $0c, $81, $00, $ff
.db $7e, $0c, $42, $3e, $42, $12, $46, $22
.db $42, $14, $42, $2a, $42, $08, $7e, $36

.dw textEditStr, todoPath
.db $15, $50, $1f, $f8, $2a, $a4, $20, $04
.db $2f, $84, $20, $04, $2f, $c4, $20, $04
.db $2f, $04, $20, $04, $2f, $f4, $20, $04
.db $2f, $84, $20, $04, $20, $04, $3f, $fc

.dw calendarStr, todoPath
.db $ff, $ff, $80, $01, $80, $01, $ff, $ff
.db $9f, $55, $9f, $ff, $95, $55, $9f, $ff
.db $95, $55, $9f, $ff, $95, $55, $9f, $ff
.db $95, $55, $9f, $ff, $95, $7f, $ff, $ff

; Row 2
.dw fileBrowserStr, todoPath
.db $38, $f0, $47, $08, $80, $08, $80, $1e
.db $81, $e1, $86, $01, $48, $79, $48, $19
.db $48, $2a, $48, $ca, $4b, $02, $28, $02
.db $28, $04, $28, $78, $2b, $80, $1c, $00

.dw matrixEditorStr, todoPath
.db $c0, $03, $80, $01, $88, $11, $98, $29
.db $88, $29, $88, $29, $9c, $11, $80, $01
.db $80, $01, $88, $11, $94, $31, $94, $11
.db $94, $11, $88, $39, $80, $01, $c0, $03

.dw connectStr, todoPath
.db $f0, $00, $98, $00, $94, $00, $f4, $00
.db $f4, $fc, $f5, $02, $f5, $7a, $05, $7a
.db $19, $7a, $21, $02, $20, $fc, $21, $02
.db $23, $ff, $22, $01, $1e, $01, $03, $ff

.dw settingsStr, todoPath
.db $00, $1c, $00, $1c, $00, $1c, $00, $14
.db $00, $14, $00, $14, $00, $14, $1f, $94
.db $20, $54, $2f, $54, $29, $54, $29, $58
.db $2f, $50, $20, $40, $2a, $40, $25, $40

.dw terminalStr, todoPath
.db $7f, $fe, $ff, $ff, $ff, $ff, $80, $01
.db $a0, $01, $90, $01, $a0, $01, $87, $01
.db $80, $01, $80, $01, $80, $01, $80, $01
.db $80, $01, $80, $01, $80, $01, $ff, $ff

graphStr:
    .db "Graph", 0
mathStr:
    .db "Math", 0
blockDudeStr:
    .db "Block Dude", 0
textEditStr:
    .db "Text Editor", 0
calendarStr:
    .db "Calendar", 0
fileBrowserStr:
    .db "File Browser", 0
matrixEditorStr:
    .db "Matrix Editor", 0
connectStr:
    .db "Connect to PC", 0
settingsStr:
    .db "Settings", 0
terminalStr:
    .db "Terminal", 0
todoPath:
    .db "/bin/todo", 0
    
helloStr:
    .db "Hello, world!", 0
helloPath:
    .db "/bin/hello", 0