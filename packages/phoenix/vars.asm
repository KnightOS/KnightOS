;##################################################################
;
;   Phoenix-Z80 (Stored data)
;
;   Programmed by Patrick Davidson (pad@calc.org)
;        
;   Copyright 2007 by Patrick Davidson.  This software may be freely
;   modified and/or copied with no restrictions.  There is no warranty.
;
;   This file was last updated August 10, 2007.
;
;##################################################################     

perm_vars:                              ; start of variables to save

level_name:     .db     "!!!!!!!!"
ext_level:
extlevel:       .db     0

data_zero_start:                        ; area cleared on newgame

saved_flag:     .db     0               ; 1 if saved game here

posqueue:       .ds     20              ; queue of positions (for helper)
player_y:       .db     0               ; player ship coordinates
player_x:       .db     0
enemies_left:   .db     0               ; # enemies still alive
level:          .db     0               ; level number
player_pwr:     .db     0               ; shield level
player_cash:    .dw     0
decimal_cash:   .dw     0
weapon_upgrade: .db     0               ; weapons available
weapon_2:       .db     0
weapon_3:       .db     0
weapon_4:       .db     0
weapon_5:       .db     0
fire_counter:   .db     0               ; timer for autofire
chosen_weapon:  .db     0               ; which weapon selected
game_timer:     .dw     0
pattern:        .dw     0
companion_pwr:  .db     0
companion_y:    .db     0
companion_x:    .db     0
companion_img:  .db     0
which_shot:     .db     0
time_score:     .dw     0               ; time bonus (counts down)
completed:      .db     0
money_counter:  .db     0               ; countdown to next money bonus

pb_array:       .ds     pb_size*pb_num
e_array:        .ds     e_size*e_num
eb_array:       .ds     eb_size*eb_num

data_zero_end:                          ; end of area cleared on newgame

invert:         .db     -1
#ifdef __85OR86__
speed_option:   .db     2               ; 0=slow, 1=medium, 2=fast
#else
speed_option:   .db     1
scroll_flag:    .db     1
#endif
sides_flag:     .db     1
difficulty:     .db     0               ; 0=easy, 1=medium, 2=hard

high_scores:
        .db     "Patrick D ",0
        .dw     30000
        .db     "Patrick D ",0
        .dw     25000
        .db     "Patrick D ",0
        .dw     20000
        .db     "Patrick D ",0
        .dw     18000
        .db     "Patrick D ",0
        .dw     16000
        .db     "Patrick D ",0
        .dw     14000
        .db     "Patrick D ",0
high_scores_end:
        .dw     8000

perm_vars_end:                          ; end of variables to save
