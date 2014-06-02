;   Phoenix-Z80 (Variable and data structure defintions)
;
;   Programmed by Patrick Davidson (pad@ocf.berkeley.edu)
;        
;   Copyright 2011 by Patrick Davidson.  This software may be freely
;   modified and/or copied with no restrictions.  There is no warranty.

;#define ENABLE_CHEATS

;############## Level initialization script commands

.equ L_END 0      ; end level definition
.equ L_SHOP 1      ; go to shop
.equ L_GAMEEND 4      ; mark end of game
.equ L_SET_POWER 7      ; set enemy power (byte)
.equ L_SET_MOVETYPE 10     ; set movement type (byte)
.equ L_SET_MOVEDATA 13     ; set movement data (word)
.equ L_SET_MOVEDATA2 16     ; set third byte of movement data (byte)
.equ L_IMAGE_STILL 19     ; set image to sprite (pointer)
.equ L_IMAGE_ANIM 22     ; set image to animated (pointer)
.equ L_SET_FIRETYPE 25     ; set firing type (byte)
.equ L_SET_FIRERATE 28     ; set firing rate (byte)
.equ L_SET_WEAPON 31     ; set weapon
.equ L_SET_FIREPOWER 34     ; set damage
.equ L_INSTALL_ONE 37     ; install one enemy (byte X, byte Y)
.equ L_INSTALL_ROW 40     ; install enemy row (X, Y, byte num, byte spacing)
.equ L_GOTO 43     ; go to the following word
.equ L_DEFAULT_ROW 46     ; install enemy row (X, Y) num = 6, spacing = 15
                        ; do not use this one in external levels

;############## Enemy movement types

.equ EM_STANDARD 0      ; standard swinging enemy
.equ EM_NONE 3      ; doesn't move
.equ EM_BOSS 4      ; boss
.equ EM_BOUNCE 7      ; bouncing enemy
.equ EM_PATTERNSTART 10     ; pattern-following enemy initialization
.equ EM_PATTERNWAIT 13     ; pattern-following enemy waiting
.equ EM_PATTERNMAIN 16     ; pattern-following enemy in pattern
.equ EM_RAMPAGE 19     ; "rampaging" enemy
.equ EM_RAMPAGEWAIT 22     ; standard enemy which is ready to rampage
.equ EM_SWOOPHORIZ 25     ; stages of swwop
.equ EM_SWOOPDOWN 28
.equ EM_SWOOPUP 31
.equ EM_SWOOPWAIT 34     ; swooping enemy waiting to enter
.equ EM_RAMPAGEINIT 37     ; enemy rampaging from the start

;############## Firing types

.equ FT_RANDOM 0      ; e_firerate/256 probability per frame
.equ FT_NONE 2      ; never fires
.equ FT_PERIODIC 3      ; fires every e_firerate frames

;############## Weapon types

.equ W_NORMAL 0      ; small bullet, straight down
.equ W_DOUBLE 3      ; two aimed bullets (as used by boss)
.equ W_SEMIAIM 6      ; accounting for X and Y position, limited angle
.equ W_BIG 9      ; large, fully aimed bullet
.equ W_HUGE 12     ; huge, fully aimed bullet
.equ W_ARROW 15
.equ W_SINGLEBIG 18     ; single-shot versionsof big, huge
.equ W_SINGLEHUGE 21
                                                             
;############## Player bullet structure definition

.equ pb_type 0
.equ pb_dmg 1
.equ pb_x 2
.equ pb_w 3
.equ pb_y 4
.equ pb_h 5
.equ pb_img 6
.equ pb_data 8

.equ pb_size 9

.equ pb_num 16

;############## Enemy structure definition

.equ e_pwr 0      ; 0 = dead, -1 = exploding
.equ e_movetype 1      ; 0 = nonmoving (code in emove.asm)
.equ e_movedata 2      ; 3 bytes of data for movement sequencing
.equ e_x 5      ; X coordinate
.equ e_w 6      ; width
.equ e_y 7      ; Y coordinate
.equ e_h 8      ; height
.equ e_imageseq 9      ; countdown to next image (0 = still image)
.equ e_imageptr 10     ; pointer to image if still, sequence otherwise
.equ e_firetype 12     
.equ e_firerate 13     ; fire rate (random probability or timing)
.equ e_firedata 14     ; firing countdown
.equ e_fireweapon 15     ; weapon used
.equ e_firepower 16     ; bullet strength

.equ e_size 17
.equ e_num 18

;############## Enemy bullet structure definition

.equ eb_type 0
.equ eb_dmg 1
.equ eb_x 2
.equ eb_w 3
.equ eb_y 4
.equ eb_h 5
.equ eb_data 6

.equ eb_size 6

.equ eb_num 15

;############## Temporary variables

enemy_buffer:
    .fill 100
x_offset:
    .db 0
option_item:
    .db 0
speed:
    .db 0 ; interrupt delay counter
money_amount: ; value of each $ dropped
    .db 0
bonus_score: ; bonus if you win
    .dw 0
decimal_amount: ; money value in decimal
    .dw 0
enemy_pointer:
    .dw 0
gfx_target:
    .dw 0
in_game:
    .db 0
misc_flags:
    .db 0
data_addr:
    .db 0, 0, 0
level_addr:
    .db 0, 0, 0
tempdata:
    .db 0, 0, 0
shop_item:
    .db 0
test_coords:
    .db 0, 0, 0, 0
timer:
    .db 0
jp2nd:
    .fill 16 ; NOTE: Not sure how much this needs, probably just one byte
