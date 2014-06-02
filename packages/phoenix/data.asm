;##################################################################
;
;   Phoenix-Z80 (Save/Restore)
;
;   Programmed by Patrick Davidson (pad@calc.org)
;        
;   Copyright 2007 by Patrick Davidson.  This software may be freely
;   modified and/or copied with no restrictions.  There is no warranty.
;
;   This file was last updated August 10, 2007.
;
;##################################################################     

;############## Save the game

game_save:
        ld      a,1
        ld      (saved_flag),a
        jp      game_exit

;############## Test for saved game, restoring if it exists

restore_game:
        ld      hl,saved_flag
        ld      a,(hl)
        or      a
        ret     z

        ld      a,(extlevel)
        or      a
        call    nz,extlevel_saved
        xor     a
#ifdef __85OR86__
        ld      (LEVEL_LOCATION),a
#endif   
        ld      (saved_flag),a
        jp      pre_main_loop
