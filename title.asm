title .namespace

TITLE .text "F256 SNAKE"
TXT_AUTHOR .text "WRITTEN BY MARTIN GRAP (@mgr42)"
TXT_PAUSE .text "PRESS SPACE TO PAUSE OR RESUME GAME"
TXT_LEVEL .text "PRESS 0-2 TO ENTER CORRESPONDING LEVEL"
TXT_USAGE .text "USE CURSOR KEYS, JOYSTICK OR SNES PAD"

drawChar .macro x, y, char, col
    ldx #\x
    ldy #\y
    lda #\col
    sta COL_TEMP
    lda #\char
    jsr pokeColChar
.endmacro

RED_ON_GREEN = TXT_GREEN | TXT_RED << 4
BROWN_ON_GREEN = TXT_GREEN | TXT_BROWN << 4

show
    jsr txtio.init40x30
    lda #TXT_GREEN
    sta CURSOR_STATE.col 
    jsr txtio.clear
    lda #BOOL_FALSE
    sta CURSOR_STATE.scrollOn

    #locate 15,1
    #printString TITLE, len(TITLE)
    #locate 5, 3
    #printString TXT_AUTHOR, len(TXT_AUTHOR)
    #locate 1,23
    #printString TXT_USAGE, len(TXT_USAGE)
    #locate 2,25
    #printString TXT_PAUSE, len(TXT_PAUSE)
    #locate 1,27
    #printString TXT_LEVEL, len(TXT_LEVEL)

    lda CURSOR_STATE.xMax
    sta txtdraw.X_MAX_MEM
    lda CURSOR_STATE.yMax
    sta txtdraw.Y_MAX_MEM

    lda #4
    sta txtdraw.RECT_PARAMS.xpos
    lda #5
    sta txtdraw.RECT_PARAMS.ypos
    lda #30
    sta txtdraw.RECT_PARAMS.lenx
    lda #15
    sta txtdraw.RECT_PARAMS.leny
    lda #TXT_GREEN | TXT_GRAY << 4
    sta txtdraw.RECT_PARAMS.col
    lda #BOOL_TRUE
    sta txtdraw.RECT_PARAMS.overwrite
    jsr txtdraw.drawRect

    #drawChar 10, 10, snake.FOOD_CHAR, RED_ON_GREEN
    #drawChar 15, 15, snake.BODY_CHAR, TXT_GREEN
    #drawChar 16, 15, snake.BODY_CHAR, TXT_GREEN
    #drawChar 17, 15, snake.BODY_CHAR, TXT_GREEN
    #drawChar 18, 15, snake.BODY_CHAR, TXT_GREEN
    #drawChar 19, 15, snake.BODY_CHAR, TXT_GREEN
    #drawChar 20, 15, snake.BODY_CHAR, TXT_GREEN
    #drawChar 21, 15, snake.BODY_CHAR, TXT_GREEN
    #drawChar 21, 14, snake.BODY_CHAR, TXT_GREEN
    #drawChar 21, 13, snake.BODY_CHAR, TXT_GREEN
    #drawChar 21, 12, snake.HEAD_UP, TXT_GREEN
    #drawChar 25, 14, snake.OBSTACLE_CHAR, BROWN_ON_GREEN
    #drawChar 26, 13, snake.OBSTACLE_CHAR, BROWN_ON_GREEN
    #drawChar 27, 12, snake.OBSTACLE_CHAR, BROWN_ON_GREEN
    #drawChar 28, 11, snake.OBSTACLE_CHAR, BROWN_ON_GREEN

    jsr waitForKey
    jsr charToLevel

    rts


COL_TEMP .byte 0
pokeColChar
    phx
    phy
    jsr txtio.pokeChar
    ply
    plx
    lda COL_TEMP
    jsr txtio.pokeColor
    rts

.endnamespace