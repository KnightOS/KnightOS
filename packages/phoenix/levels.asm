;##################################################################
;
;   Phoenix-Z80 (Level definitions)
;
;   Programmed by Patrick Davidson (pad@calc.org)
;        
;   Copyright 2005 by Patrick Davidson.  This software may be freely
;   modified and/or copied with no restrictions.  There is no warranty.
;
;   This file was last updated August 28, 2005.
;
;##################################################################     

;############## Table of level descriptions

level_table:
#ifdef VERY_SHORT
	.dw	lev0
	.dw	_over
#endif
        .dw     lev1
        .dw     lev2
        .dw     lev3            ; with boss
        .dw     _shop

        .dw     lev4            ; second set of standard enemies
        .dw     lev5    
        .dw     bounce6         ; bouncing enemies
        .dw     lev6            ; with boss
        .dw     _shop

        .dw     lev4a           ; third set of standard enemies
        .dw     lev5a
        .dw     bounce8         ; bouncing enemies
        .dw     lev6a           ; with boss
        .dw     _shop

        .dw     lev7            ; set of looping enemies  
        .dw     lev8
        .dw     bounce10        ; bouncing enemies
        .dw     lev9            ; with boss
        .dw     _shop

        .dw     lev10           ; set of arrow-launching enemies
        .dw     lev11
        .dw     lev12           ; with boss
        .dw     _shop

        .dw     lev13           ; first set of spinning enemies   
        .dw     lev14
        .dw     lev15           ; with boss
        .dw     _shop

        .dw     lev13a          ; second set of spinning enemies
        .dw     lev14a
        .dw     lev15a          ; with boss
        .dw     _shop

        .dw     levsw1          ; swooping-down enemies
        .dw     levl            ; looping enemies + large boss
        .dw     _shop

        .dw     levo1           ; operator enemies
        .dw     levo2
        .dw     levo3           ; with boss
        .dw     _shop

        .dw     levsw2          ; swooping-down enemies
        .dw     levl            ; looping enemies + large boss

        .dw     _over

;############## Level descrptions:

_shop:  .db     0
        .db     L_SHOP

_over:  .db     0
        .db     L_GAMEEND

#ifdef VERY_SHORT
lev0:   .db     2
        .db     L_INSTALL_ROW,18,10,2,15
        .db     L_END
#endif

lev1:   .db     18
lev1x:  .db     L_DEFAULT_ROW,18,10
lev1y:  .db     L_DEFAULT_ROW,18,0
lev1z:  .db     L_DEFAULT_ROW,18,20
        .db     L_END

lev2:   .db     18
lev2x:  .db     L_DEFAULT_ROW,20,10
        .db     L_GOTO
        .dw     lev1y

lev3:   .db     7
lev3x:  .db     L_DEFAULT_ROW,18,20
lev3y:  .db     L_SET_MOVETYPE,EM_BOSS
        .db     L_SET_POWER,61
        .db     L_SET_MOVEDATA,0,32
        .db     L_IMAGE_STILL
        .dw     img_boss
        .db     L_SET_FIRETYPE,FT_PERIODIC
        .db     L_SET_FIRERATE,64
        .db     L_SET_WEAPON,W_DOUBLE
        .db     L_INSTALL_ONE,90,1
        .db     L_END

lev4:   .db     18
        .db     L_SET_POWER,6
        .db     L_IMAGE_STILL
        .dw     img_enemy_2
        .db     L_GOTO
        .dw     lev1x

lev5:   .db     18
        .db     L_SET_POWER,6
        .db     L_IMAGE_STILL
        .dw     img_enemy_2
        .db     L_GOTO
        .dw     lev2x

bounce6: .db    6
        .db     L_IMAGE_STILL
        .dw     img_bounce
        .db     L_SET_MOVETYPE,EM_BOUNCE
        .db     L_SET_POWER,36
        .db     L_SET_MOVEDATA,3,3
        .db     L_SET_FIRERATE,4
        .db     L_SET_WEAPON,W_SEMIAIM
        .db     L_INSTALL_ROW,14,20,6,10
        .db     L_END

lev6:   .db     7
        .db     L_SET_POWER,6
        .db     L_IMAGE_STILL
        .dw     img_enemy_2
        .db     L_GOTO
        .dw     lev3x

lev4a:  .db     18
        .db     L_SET_POWER,6
        .db     L_IMAGE_STILL
        .dw     img_enemy_2
        .db     L_DEFAULT_ROW,18,0
        .db     L_SET_POWER,8
        .db     L_IMAGE_STILL
        .dw     img_enemy_2a
        .db     L_DEFAULT_ROW,18,10
        .db     L_GOTO
        .dw     lev1z

lev5a:  .db     18
        .db     L_SET_POWER,8
        .db     L_IMAGE_STILL
        .dw     img_enemy_2a
        .db     L_GOTO
        .dw     lev2x

bounce8: .db    8
        .db     L_IMAGE_STILL
        .dw     img_bounce
        .db     L_SET_MOVETYPE,EM_BOUNCE
        .db     L_SET_POWER,36
        .db     L_SET_MOVEDATA,3,3
        .db     L_SET_FIRERATE,4
        .db     L_SET_WEAPON,W_SEMIAIM
        .db     L_INSTALL_ROW,14,20,8,10
        .db     L_END

lev6a:  .db     13
        .db     L_SET_POWER,6
        .db     L_IMAGE_STILL
        .dw     img_enemy_2
        .db     L_DEFAULT_ROW,18,15
        .db     L_SET_POWER,8
        .db     L_IMAGE_STILL
        .dw     img_enemy_2a
        .db     L_DEFAULT_ROW,18,23

        .db     L_GOTO
        .dw     lev3y

lev7:   .db     14
        .db     L_SET_POWER,14
        .db     L_IMAGE_ANIM
        .dw     img_enemy_3
        .db     L_SET_MOVETYPE,EM_PATTERNSTART
        .db     L_SET_FIRERATE,4
        .db     L_SET_WEAPON,W_SEMIAIM
        .db     L_SET_MOVEDATA
        .dw     circle_pattern
        .db     L_INSTALL_ROW,14,18,7,27
        .db     L_INSTALL_ROW,29,74,7,27
        .db     L_END

bounce10:
        .db     10
        .db     L_IMAGE_STILL
        .dw     img_bounce
        .db     L_SET_MOVETYPE,EM_BOUNCE
        .db     L_SET_POWER,36
        .db     L_SET_MOVEDATA,3,3
        .db     L_SET_FIRERATE,4
        .db     L_SET_WEAPON,W_SEMIAIM
        .db     L_INSTALL_ROW,14,20,10,10
        .db     L_END

lev8:   .db     13
        .db     L_SET_POWER,14
        .db     L_IMAGE_ANIM
        .dw     img_enemy_3
        .db     L_SET_MOVETYPE,EM_PATTERNSTART
        .db     L_SET_FIRERATE,4
        .db     L_SET_WEAPON,W_SEMIAIM
        .db     L_SET_MOVEDATA
        .dw     figure_eight_pattern
        .db     L_INSTALL_ROW,14,18,13,15
        .db     L_END

lev9:   .db     14
        .db     L_SET_POWER,14
        .db     L_IMAGE_ANIM
        .dw     img_enemy_3
        .db     L_SET_MOVETYPE,EM_PATTERNSTART
        .db     L_SET_FIRERATE,4
        .db     L_SET_WEAPON,W_SEMIAIM
        .db     L_SET_MOVEDATA
        .dw     oval_pattern
        .db     L_INSTALL_ROW,14,18,13,15

        .db     L_GOTO
        .dw     lev3y

lev10:  .db     18
        .db     L_SET_POWER,17
        .db     L_IMAGE_STILL
        .dw     img_enemy_4
        .db     L_SET_WEAPON,W_ARROW
        .db     L_GOTO
        .dw     lev2x

lev11:  .db     18
        .db     L_SET_POWER,17
        .db     L_IMAGE_STILL
        .dw     img_enemy_4
        .db     L_SET_WEAPON,W_ARROW
        .db     L_GOTO
        .dw     lev1x

lev12:  .db     13
        .db     L_SET_POWER,6
        .db     L_IMAGE_STILL
        .dw     img_enemy_2
        .db     L_DEFAULT_ROW,18,12
        .db     L_DEFAULT_ROW,18,21

lev12x: .db     L_SET_MOVETYPE,EM_BOSS
        .db     L_SET_POWER,101
        .db     L_SET_MOVEDATA,0,31
        .db     L_IMAGE_STILL
        .dw     img_boss2
        .db     L_SET_FIREPOWER,2
        .db     L_SET_FIRETYPE,FT_PERIODIC
        .db     L_SET_FIRERATE,64
        .db     L_SET_WEAPON,W_BIG
        .db     L_INSTALL_ONE,90,1
        .db     L_END

lev13:  .db     18
        .db     L_IMAGE_ANIM
        .dw     img_spin1
        .db     L_SET_POWER,21
lev13x: .db     L_SET_WEAPON,W_SEMIAIM
        .db     L_SET_MOVETYPE,EM_RAMPAGEWAIT
        .db     L_SET_FIRERATE,8
        .db     L_GOTO
        .dw     lev1x

lev14:  .db     18
        .db     L_IMAGE_ANIM
        .dw     img_spin1
        .db     L_SET_POWER,21
lev14x: .db     L_SET_WEAPON,W_SEMIAIM
        .db     L_SET_MOVETYPE,EM_RAMPAGEWAIT
        .db     L_SET_FIRERATE,8
        .db     L_DEFAULT_ROW,19,10
        .db     L_DEFAULT_ROW,12,0
        .db     L_DEFAULT_ROW,12,20
        .db     L_END

lev15:  .db     14
        .db     L_IMAGE_ANIM
        .dw     img_spin1
        .db     L_SET_POWER,21
lev15x: .db     L_SET_WEAPON,W_SEMIAIM
        .db     L_SET_MOVETYPE,EM_RAMPAGEWAIT
        .db     L_SET_FIRERATE,8
        .db     L_INSTALL_ROW,16,12,7,15
        .db     L_DEFAULT_ROW,22,21
        .db     L_GOTO
        .dw     lev12x

lev13a: .db     18
        .db     L_IMAGE_ANIM
        .dw     img_spin2
        .db     L_SET_POWER,31
        .db     L_GOTO
        .dw     lev13x

lev14a: .db     18
        .db     L_IMAGE_ANIM
        .dw     img_spin2
        .db     L_SET_POWER,31
        .db     L_GOTO
        .dw     lev14x

lev15a: .db     14
        .db     L_IMAGE_ANIM
        .dw     img_spin2
        .db     L_SET_POWER,31
        .db     L_GOTO
        .dw     lev15x

levsw1: .db     9
        .db     L_SET_WEAPON,W_SINGLEBIG
levswx: .db     L_IMAGE_ANIM
        .dw     img_swoop
        .db     L_SET_MOVETYPE,EM_SWOOPWAIT
        .db     L_SET_FIRERATE,4
        .db     L_SET_POWER,14
        .db     L_INSTALL_ROW,0,0,9,0
        .db     L_END

levl:   .db     18
        .db     L_SET_POWER,14
        .db     L_IMAGE_ANIM
        .dw     img_enemy_3
        .db     L_SET_MOVETYPE,EM_PATTERNSTART
        .db     L_SET_FIRERATE,4
        .db     L_SET_WEAPON,W_SEMIAIM
        .db     L_SET_MOVEDATA
        .dw     huge_oval_pattern
        .db     L_INSTALL_ROW,14,18,17,15

        .db     L_SET_MOVETYPE,EM_BOSS
        .db     L_SET_POWER,151
        .db     L_SET_MOVEDATA,0,31
        .db     L_IMAGE_STILL
        .dw     img_boss2
        .db     L_SET_FIREPOWER,2
        .db     L_SET_FIRETYPE,FT_PERIODIC
        .db     L_SET_FIRERATE,64
        .db     L_SET_WEAPON,W_HUGE
        .db     L_INSTALL_ONE,90,15
        .db     L_END

levo1:  .db     8
        .db     L_SET_MOVETYPE,EM_RAMPAGEINIT  
        .db     L_SET_FIRERATE,4
        .db     L_SET_POWER,41
        .db     L_IMAGE_STILL
        .dw     img_operator
        .db     L_SET_WEAPON,W_SEMIAIM
        .db     L_INSTALL_ROW,0,0,8,0
        .db     L_END

levo2:  .db     12
levox:  .db     L_SET_MOVETYPE,EM_RAMPAGEINIT
        .db     L_SET_FIRERATE,4
        .db     L_SET_POWER,41
        .db     L_IMAGE_STILL
        .dw     img_operator
        .db     L_SET_WEAPON,W_SEMIAIM
        .db     L_INSTALL_ROW,0,0,12,0
        .db     L_END

levo3:  .db     13
        .db     L_SET_MOVETYPE,EM_BOSS
        .db     L_SET_POWER,151
        .db     L_SET_MOVEDATA,0,31
        .db     L_IMAGE_STILL
        .dw     img_boss2
        .db     L_SET_FIREPOWER,2
        .db     L_SET_FIRETYPE,FT_PERIODIC
        .db     L_SET_FIRERATE,64
        .db     L_SET_WEAPON,W_HUGE
        .db     L_INSTALL_ONE,90,1

        .db     L_SET_FIREPOWER,1
        .db     L_GOTO
        .dw     levox

levsw2: .db     9
        .db     L_SET_WEAPON,W_SINGLEHUGE
        .db     L_GOTO
        .dw     levswx

;############## Pattens

huge_oval_pattern:
        .db     32,0,19
huge_oval_loop:
        .db     64,20,0
        .db     10,16,0
        .db     8,12,-12
        .db     28,0,-12
        .db     8,-12,-12
        .db     10,-16,0
        .db     64,-20,0
        .db     10,-16,0
        .db     8,-12,12
        .db     28,0,12
        .db     8,12,12
        .db     10,16,0
        .db     0
        .dw     huge_oval_loop

;     KKK            EEE
;    L   JJ        DD   F
;   L      JJ    DD      F
;| A         JJDD         G |
;| A         DDJJ         G |
;v A       DD    JJ       G v
;   B    DD        JJ    H
;    BCCC            IIIH

figure_eight_pattern:
        .db     32,0,12
figure_eight_loop:
        .db     12,12,12        ;B
        .db     16,16,0         ;C
        .db     34,16,-12       ;D
        .db     16,15,0         ;E
        .db     12,12,12        ;F
        .db     8,0,14          ;G
        .db     12,-12,12       ;H
        .db     16,-15,0        ;I
        .db     34,-16,-12      ;J
        .db     16,-16,0        ;K
        .db     12,-12,12       ;L
        .db     8,0,16          ;A
        .db     0
        .dw     figure_eight_loop

circle_pattern:
        .db     32,0,14
circle_loop:
        .db     8,12,12
        .db     16,16,0
        .db     8,12,-12
        .db     16,0,-16
        .db     8,-12,-12
        .db     16,-16,0
        .db     8,-12,12
        .db     16,0,16
        .db     0
        .dw     circle_loop

oval_pattern:
        .db     32,0,16
oval_loop:
        .db     4,12,12
        .db     76,16,0
        .db     4,12,-12
        .db     6,0,-16
        .db     4,-12,-12
        .db     76,-16,0
        .db     4,-12,12
        .db     6,0,16
        .db     0
        .dw     oval_loop
