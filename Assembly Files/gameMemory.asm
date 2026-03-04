SCREENMEM = $0400 ; start of screen memory
COLORMEM = $d800 ; start of color memory


; COSTANTI PER I COLORITEMP
BLACK                           = #$00
WHITE                           = #$01
GREEN                           = #$05
YELLOW                          = #$07
ORANGE                          = #$08 ;12
LIGHT_GREEN                     = #$13


; COSTSNTI MOVIMENTI JOY_PORT_A
UP                              = #$01
DOWN                            = #$02
LEFT                            = #$04
RIGHT                           = #$08

; COSTANTI GENERICHE
DISABLE_ALL_SPRITE              = #$0
ENABLE_ALL_SPRITE               = #$FF


; REGISTRI DEL VIC
VIC_SPRITE_POSX_REGISTER        = $D000
VIC_SPRITE_POSY_REGISTER        = $D001
VIC_SPRITE_POSX_EXTENDED_REGISTER = $D010
VIC_RASTER_REGISTER             = $D012
VIC_SPRITE_ENABLE_REGISTER      = $D015
VIC_INTERRUPT_REGISTER          = $D01A
VIC_SPRITE_ENABLE_MULTICOLOR    = $D01C
SPSPCL                          = $D01E
VIC_BORDER_REGISTER             = $D020
VIC_BACKGROUND_REGISTER         = $D021
VIC_SPRITE_MULTICOLOR_0         = $D025
VIC_SPRITE_MULTICOLOR_1         = $D026
VIC_SPRITE_0_COLOR              = $D027
VIC_SPRITE_1_COLOR              = $D028
VIC_SPRITE_0_POINTER            = $7F8
VIC_SPRITE_COLLISION_FOREGROUND = $D01F
        

GETIN  =  $FFE4
SCNKEY =  $FF9F
JOY_PORT_A                      = $DC00

BLOCKED_DIRECTION
    byte 0

COLLISION_OCCURRED     byte 0
COLLISION_DIRECTION    byte 0

COLLISION_X       byte 0
COLLISION_Y       byte 0

temp_y          byte 0
screen_ptr      word 0