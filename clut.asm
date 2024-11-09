saveIo .macro
    lda $01
    pha
.endmacro

setIo .macro page
    lda #\page
    sta $01
.endmacro

restoreIo .macro
    pla
    sta $01
.endmacro


TXT_BLACK = 0
TXT_WHITE = 1
TXT_BLUE = 2
TXT_GREEN = 3
TXT_AMBER = 4
TXT_RED = 5
TXT_GRAY = 6
TXT_BROWN = 7

HEAD_COL = 1
APPLE_COL = 2
SEGMENT_COL = 3
GRASS_COL = 4
OBSTACLE_COL = 5
SEG_COL2 = 6

.include "auto_cols.inc"

clut .namespace

TXT_LUT_FORE_GROUND_BASE = $D800
TXT_LUT_BACK_GROUND_BASE = $D840
GFX_LUT_BASE = $D000


setTxtColInt .macro colNum, red, green, blue, alpha
    lda #\blue
    sta TXT_LUT_FORE_GROUND_BASE + ((\colNum & 15) * 4)
    sta TXT_LUT_BACK_GROUND_BASE + ((\colNum & 15) * 4)
    lda #\green
    sta TXT_LUT_FORE_GROUND_BASE + ((\colNum & 15) * 4) + 1
    sta TXT_LUT_BACK_GROUND_BASE + ((\colNum & 15) * 4) + 1
    lda #\red
    sta TXT_LUT_FORE_GROUND_BASE + ((\colNum & 15) * 4) + 2
    sta TXT_LUT_BACK_GROUND_BASE + ((\colNum & 15) * 4) + 2
    lda #\alpha
    sta TXT_LUT_FORE_GROUND_BASE + ((\colNum & 15) * 4) + 3
    sta TXT_LUT_BACK_GROUND_BASE + ((\colNum & 15) * 4) + 3
.endmacro


setTxtCol .macro colNum, red, green, blue, alpha
    #saveIo
    #setIo 0
    #setTxtColInt \colNum, \red, \green, \blue, \alpha
    #restoreIo
.endmacro


setGfxColInt .macro colNum, red, green, blue, alpha
    lda #\blue
    sta GFX_LUT_BASE + (\colNum * 4)
    lda #\green
    sta GFX_LUT_BASE + (\colNum * 4) + 1
    lda #\red
    sta GFX_LUT_BASE + (\colNum * 4) + 2
    lda #\alpha
    sta GFX_LUT_BASE + (\colNum * 4) + 3
.endmacro


setGfxColAlternate .macro colNum, val
    lda #<\val
    sta GFX_LUT_BASE + (\colNum * 4)
    lda #>\val
    sta GFX_LUT_BASE + (\colNum * 4) + 1
    lda #`\val
    sta GFX_LUT_BASE + (\colNum * 4) + 2
    lda #$FF
    sta GFX_LUT_BASE + (\colNum * 4) + 3
.endmacro


setGfxCol .macro colNum, red, green, blue, alpha
    #saveIo
    #setIo 1
    #setGfxColInt \colNum, \red, \green, \blue, \alpha
    #restoreIo
.endmacro

init
    #saveIo
    
    #setIo 1
    #setGfxColInt HEAD_COL,  $00, $00, $00, $FF
    #setGfxColInt APPLE_COL,  $FF, $00, $00, $FF
    #setGfxColInt SEGMENT_COL,  196, 164, 132, $FF
    #setGfxColInt GRASS_COL,  $00, $B0, $00, $FF
    #setGfxColInt OBSTACLE_COL,  $00, $00, $00, $FF
    #setGfxColInt SEG_COL2,  $00, $00, $00, $FF

.include "auto_clut.inc"

    #setIo 0
    #setTxtColInt TXT_BLACK,  $00, $00, $00, $FF
    #setTxtColInt TXT_WHITE,  $FF, $FF, $FF, $FF
    #setTxtColInt TXT_BLUE,   $00, $80, $FF, $FF
    #setTxtColInt TXT_GREEN,  $00, $FF, $00, $FF
    #setTxtColInt TXT_AMBER,  $FA, $63, $05, $FF
    #setTxtColInt TXT_RED,    $FF, $00, $00, $FF
    #setTxtColInt TXT_GRAY,   $00, $B0, $00, $FF
    #setTxtColInt TXT_BROWN,   196, 164, 132, $FF

    #restoreIo
    rts

.endnamespace