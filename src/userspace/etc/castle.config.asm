; /etc/castle.config

; Defines the icons on the castle home
; Format:
; Pointer to shortcut name, or 0xFFFF
; if not 0xFFFF, pointer to file name
; if not 0xFFFF, 16x16 icon

; Row 1
.dw graphStr, $0000
.db $84, $01, $84, $02, $84, $04, $84, $08
.db $44, $10, $44, $20, $44, $40, $24, $80
.db $25, $00, $16, $00, $ff, $ff, $0d, $00
.db $14, $80, $24, $80, $44, $40, $84, $40

.dw mathStr, $0000
.db $10, $fe, $38, $80, $12, $be, $02, $94
.db $3a, $94, $01, $24, $00, $00, $7c, $28
.db $44, $08, $20, $10, $10, $20, $20, $28
.db $44, $00, $7c, $f0, $00, $00, $00, $f0

.dw mosaicStr, $0000
.db $ff, $ff, $84, $01, $85, $fd, $85, $05
.db $85, $0d, $85, $1d, $85, $3d, $85, $7d
.db $85, $fd, $84, $01, $ff, $ff, $84, $01
.db $95, $fd, $a5, $fd, $84, $01, $ff, $ff

.dw textEditStr, $0000
.db $15, $50, $1f, $f8, $2a, $a4, $20, $04
.db $2f, $84, $20, $04, $2f, $c4, $20, $04
.db $2f, $04, $20, $04, $2f, $f4, $20, $04
.db $2f, $84, $20, $04, $20, $04, $3f, $fc

.dw $FFFF

; Row 2
.dw fileBrowserStr, $0000
.db $38, $f0, $47, $08, $80, $08, $80, $1e
.db $81, $e1, $86, $01, $48, $79, $48, $19
.db $48, $2a, $48, $ca, $4b, $02, $28, $02
.db $28, $04, $28, $78, $2b, $80, $1c, $00

.dw $FFFF
.dw $FFFF

.dw terminalStr, $0000
.db $7f, $fe, $ff, $ff, $ff, $ff, $80, $01
.db $a0, $01, $90, $01, $a0, $01, $87, $01
.db $80, $01, $80, $01, $80, $01, $80, $01
.db $80, $01, $80, $01, $80, $01, $ff, $ff

.dw $FFFF

graphStr:
    .db "Graph", 0
mathStr:
    .db "Math", 0
mosaicStr:
    .db "Mosaic", 0
textEditStr:
    .db "Text Editor", 0
fileBrowserStr:
    .db "File Browser", 0
terminalStr:
    .db "Terminal", 0