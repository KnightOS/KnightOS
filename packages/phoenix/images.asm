;##################################################################
;
;   Phoenix-Z80 (Images)
;
;   Programmed by Patrick Davidson (pad@calc.org)
;    
;   Copyright 2002 by Patrick Davidson.  This software may be freely
;   modified and/or copied with no restrictions.  There is no warranty.
;                  
;   This file was last updated August 16, 2002.
;
;##################################################################     

;############## Standard enemies

img_enemy_4:
    .db 7, 9
    .db 0b10000010
    .db 0b11000110
    .db 0b11111110
    .db 0b10000010
    .db 0b10000010
    .db 0b10000010
    .db 0b11111110
    .db 0b01111100
    .db 0b00111000

img_enemy_1:
    .db 6, 6     
    .db 0b10000100       
    .db 0b10000100       
    .db 0b11111100       
    .db 0b11111100       
    .db 0b01111000       
    .db 0b00110000

img_enemy_2:
    .db 8, 5
    .db 0b10000001
    .db 0b11011011
    .db 0b11111111
    .db 0b11011011
    .db 0b10000001

img_enemy_2a:
    .db 5, 5
    .db 0b10001000
    .db 0b11111000
    .db 0b10001000
    .db 0b01010000
    .db 0b00100000

img_operator:
    .db 8, 8
    .db 0b01111110
    .db 0b11111111
    .db 0b11000011
    .db 0b11000011
    .db 0b11000011
    .db 0b11000011
    .db 0b11111111
    .db 0b01111110

img_spin1:
    .db 2
    .dw img_spin_1a
    .db 2
    .dw img_spin_1b
    .db 2
    .dw img_spin_1c
    .db 2
    .dw img_spin_1d
    .db 0
    .dw img_spin1

img_spin_1a:
    .db 8, 8
    .db 0b00100000
    .db 0b00111100
    .db 0b01111111
    .db 0b01100110
    .db 0b01100110
    .db 0b11111110
    .db 0b00111100
    .db 0b00000100

img_spin_1b:
    .db 8, 8
    .db 0b00001000
    .db 0b00111100
    .db 0b01111110
    .db 0b11100110
    .db 0b01100111
    .db 0b01111110
    .db 0b00111100
    .db 0b00010000

img_spin_1c:
    .db 8, 8
    .db 0b00000010
    .db 0b10111100
    .db 0b01111110
    .db 0b01100110
    .db 0b01100110
    .db 0b01111110
    .db 0b00111101
    .db 0b01000000

img_spin_1d:
    .db 8, 8
    .db 0b01000000
    .db 0b01111111
    .db 0b01111110
    .db 0b01100110
    .db 0b01100110
    .db 0b01111110
    .db 0b11111110
    .db 0b00000010

img_spin2:
    .db 2
    .dw img_spin_2a
    .db 2
    .dw img_spin_2b
    .db 2
    .dw img_spin_2c
    .db 2
    .dw img_spin_2d
    .db 0
    .dw img_spin2

img_spin_2a:
    .db 8, 8
    .db 0b00100000
    .db 0b00111100
    .db 0b01111111
    .db 0b01111110
    .db 0b01111110
    .db 0b11111110
    .db 0b00111100
    .db 0b00000100

img_spin_2b:
    .db 8, 8
    .db 0b00001000
    .db 0b00111100
    .db 0b01111110
    .db 0b11111110
    .db 0b01111111
    .db 0b01111110
    .db 0b00111100
    .db 0b00010000

img_spin_2c:
    .db 8, 8
    .db 0b00000010
    .db 0b10111100
    .db 0b01111110
    .db 0b01111110
    .db 0b01111110
    .db 0b01111110
    .db 0b00111101
    .db 0b01000000

img_spin_2d:
    .db 8, 8
    .db 0b01000000
    .db 0b01111111
    .db 0b01111110
    .db 0b01111110
    .db 0b01111110
    .db 0b01111110
    .db 0b11111110
    .db 0b00000010

;############## Special enemies

img_bounce:
    .db 8, 9
    .db 0b00011000
    .db 0b00011000
    .db 0b00011000
    .db 0b00100100
    .db 0b01000010
    .db 0b10000001
    .db 0b10011001
    .db 0b10100101
    .db 0b11000011

img_enemy_3:
    .db 4
    .dw img_enemy_3a
    .db 4
    .dw img_enemy_3b
    .db 4
    .dw img_enemy_3c
    .db 4
    .dw img_enemy_3d
    .db 0
    .dw img_enemy_3

img_enemy_3a:
    .db 8, 8
    .db 0b00111100
    .db 0b01000010
    .db 0b10000001
    .db 0b11111111
    .db 0b11111111
    .db 0b10000001
    .db 0b01000010
    .db 0b00111100
img_enemy_3b:
    .db 8, 8
    .db 0b00111100
    .db 0b01000110
    .db 0b10001111
    .db 0b10011101
    .db 0b10111001
    .db 0b11110001
    .db 0b01100010
    .db 0b00111100
img_enemy_3c:
    .db 8, 8
    .db 0b00111100
    .db 0b01011010
    .db 0b10011001
    .db 0b1011001
    .db 0b10011001
    .db 0b10011001
    .db 0b01011010
    .db 0b00111100
img_enemy_3d:
    .db 8, 8
    .db 0b00111100
    .db 0b01100010
    .db 0b11110001
    .db 0b10111001
    .db 0b10011101
    .db 0b10001111
    .db 0b01000110
    .db 0b00111100

;############## Bosses

img_boss2:
    .db 16, 12
    .db 0b11111000
    .db 0b10001111
    .db 0b10001000
    .db 0b10001000
    .db 0b10001000
    .db 0b10001000
    .db 0b10001000
    .db 0b10001111
    .db 0b11111000
    .db 0b11111000
    .db 0b01110000
    .db 0b00100000
    .db 8, 12
    .db 0b00011111
    .db 0b11110001
    .db 0b00010001
    .db 0b00010001
    .db 0b00010001
    .db 0b00010001
    .db 0b00010001
    .db 0b11110001
    .db 0b00011111
    .db 0b00011111
    .db 0b00001110
    .db 0b00000100

img_boss:
    .db 16, 12
    .db 0b10000000
    .db 0b11000000 
    .db 0b11100000
    .db 0b11111111
    .db 0b11000111
    .db 0b11000011       
    .db 0b11000001
    .db 0b11000001
    .db 0b11100001
    .db 0b01110001
    .db 0b00111111
    .db 0b00011111
    .db 8, 12
    .db 0b00000001
    .db 0b00000011
    .db 0b00000111
    .db 0b11111111
    .db 0b11100011
    .db 0b11000011
    .db 0b10000011
    .db 0b10000011
    .db 0b10000111
    .db 0b10001110
    .db 0b11111100
    .db 0b11111000

;############## Swooping enemy

img_swoop:
    .db 2
    .dw swoop_stage1
    .db 2
    .dw swoop_stage2
    .db 0
    .dw img_swoop

swoop_stage1:
    .db 11, 8
    .db 0b11100000
    .db 0b10101110
    .db 0b11101110
    .db 0b10111111
    .db 0b11111111
    .db 0b10101110
    .db 0b11101110
    .db 0b10100100
    .db 3, 8
    .db 0b11100000
    .db 0b10100000
    .db 0b11100000
    .db 0b10100000
    .db 0b11100000
    .db 0b10100000
    .db 0b11100000
    .db 0b10100000

swoop_stage2:
    .db 11, 8
    .db 0b11100000
    .db 0b10101110
    .db 0b11101110
    .db 0b10111111
    .db 0b11111111
    .db 0b10101110
    .db 0b11101110
    .db 0b10100100
    .db 3, 8
    .db 0b11100000
    .db 0b10100000
    .db 0b11100000
    .db 0b10100000
    .db 0b11100000
    .db 0b10100000
    .db 0b11100000
    .db 0b10100000

;############## Players

img_player_ship_normal:
    .db 8, 6
    .db 0b10000001
    .db 0b10000001
    .db 0b10011001
    .db 0b10100101
    .db 0b11000011
    .db 0b10000001

img_player_ship_damaged:
    .db 8, 6
    .db 0b10000000
    .db 0b00000001
    .db 0b10010000
    .db 0b00000101
    .db 0b11000000
    .db 0b00000001

img_companion:
    .db 7, 7     
    .db 0b00010000       
    .db 0b00111000       
    .db 0b10111010       
    .db 0b10111010       
    .db 0b10111010       
    .db 0b11111110       
    .db 0b11111110

;############## Player bullets

img_player_bullet_0:
    .db 2, 6
    .db 0b11000000
    .db 0b11000000
    .db 0b11000000
    .db 0b11000000
    .db 0b11000000
    .db 0b11000000

img_player_bullet_1:
    .db 4, 8
    .db 0b01100000
    .db 0b11110000
    .db 0b10100000
    .db 0b01010000
    .db 0b10100000
    .db 0b01010000
    .db 0b10100000
    .db 0b01010000

img_player_bullet_2l:
    .db 3, 7
    .db 0b00100000
    .db 0b01100000
    .db 0b11100000
    .db 0b11100000
    .db 0b11100000
    .db 0b11000000
    .db 0b10000000

img_player_bullet_2r:
    .db 3, 7
    .db 0b10000000
    .db 0b11000000
    .db 0b11100000
    .db 0b11100000
    .db 0b11100000
    .db 0b01100000
    .db 0b00100000

img_player_bullet_3:
    .db 4, 4
    .db 0b01100000
    .db 0b11110000
    .db 0b11110000
    .db 0b01100000

img_player_bullet_5:
    .db 5, 7
    .db 0b00100000
    .db 0b01110000
    .db 0b11111000
    .db 0b11111000
    .db 0b11111000
    .db 0b11011000
    .db 0b10001000

img_quad_bullet:
    .db 3, 5     
    .db 0b01000000       
    .db 0b11100000       
    .db 0b11100000       
    .db 0b11100000       
    .db 0b11100000

;############## Dropped items

img_eb_1:
    .db 2, 2
    .db 0b11000000
    .db 0b11000000

img_eb_3:
    .db 3, 3
    .db 0b01000000
    .db 0b11100000
    .db 0b01000000

img_eb_2:
    .db 3, 7
    .db 0b10100000
    .db 0b11100000
    .db 0b11100000
    .db 0b01000000
    .db 0b01000000
    .db 0b11100000
    .db 0b01000000

img_money:
    .db 5, 7
    .db 0b00100000
    .db 0b11111000
    .db 0b10100000
    .db 0b11111000
    .db 0b00101000
    .db 0b11111000
    .db 0b00100000

img_eb_4:
    .db 5, 5
    .db 0b01110000
    .db 0b11111000
    .db 0b11111000
    .db 0b11111000
    .db 0b01110000

;############## Explosion

; Note: This probably loads sprite addresses relatively speaking
; We may have to udpate it to be relocatable
explosion_sequence:
    .db 2
    .dw x1
    .db 2
    .dw x2
    .db 2
    .dw x3
    .db 2
    .dw x4
    .db 2
    .dw x5
    .db 2
    .dw x6
    .db 2
    .dw x7
    .db 2
    .dw x8
    .db -1 ; kill enemy

x1: 
    .db 8, 6
    .db 0b00000000       
    .db 0b00011100       
    .db 0b00111110       
    .db 0b01010110       
    .db 0b00111000       
    .db 0b00000000

x2: 
    .db 8, 6     
    .db 0b00110000       
    .db 0b01001110       
    .db 0b10111110       
    .db 0b01001111       
    .db 0b00111000       
    .db 0b00011010

x3: 
    .db 8, 6     
    .db 0b11110011       
    .db 0b01001110       
    .db 0b10110101       
    .db 0b01000101       
    .db 0b00111110       
    .db 0b11011010

x4: 
    .db 8, 6     
    .db 0b11110011       
    .db 0b01001110       
    .db 0b10110101       
    .db 0b01000101       
    .db 0b00111110       
    .db 0b11011010

x5: 
    .db 8, 6     
    .db 0b01000001       
    .db 0b00100110       
    .db 0b00010101       
    .db 0b01000100       
    .db 0b00010010       
    .db 0b10011010

x6: 
    .db 8, 6     
    .db 0b01000010       
    .db 0b00100000       
    .db 0b00000001       
    .db 0b01000100       
    .db 0b00100010
    .db 0b10001010

x7: 
    .db 8, 6     
    .db 0b00001000       
    .db 0b11000010       
    .db 0b00000000       
    .db 0b00100000       
    .db 0b00000001       
    .db 0b00110000

x8: 
    .db 8, 6     
    .db 0b00000100       
    .db 0b00000000       
    .db 0b01000000       
    .db 0b00000000       
    .db 0b00000001       
    .db 0b00100100

    .db -1
