title .namespace

TITLE .text "F256 SNAKE"
TXT_AUTHOR .text "WRITTEN BY MARTIN GRAP (@mgr42)"
TXT_PRESS_ANY_KEY .text "PRESS ANY KEY TO START"
TXT_USAGE .text "USE CURSOR KEYS OR JOYSTICK TO PLAY"

drawChar .macro x, y, char, col
    ldx #\x
    ldy #\y
    lda #\col
    sta COL_TEMP
    lda #\char
    jsr pokeColChar
.endmacro

show
    jsr txtio.init40x30
    lda #TXT_GREEN
    sta CURSOR_STATE.col 
    jsr txtio.clear
    lda #BOOL_FALSE
    sta CURSOR_STATE.scrollOn
    #locate 15,2
    #printString TITLE, len(TITLE)
    #locate 5, 4
    #printString TXT_AUTHOR, len(TXT_AUTHOR)
    #locate 2,25
    #printString TXT_USAGE, len(TXT_USAGE)
    #locate 10,27
    #printString TXT_PRESS_ANY_KEY, len(TXT_PRESS_ANY_KEY)

    lda CURSOR_STATE.xMax
    sta txtdraw.X_MAX_MEM
    lda CURSOR_STATE.yMax
    sta txtdraw.Y_MAX_MEM

    lda #4
    sta txtdraw.RECT_PARAMS.xpos
    lda #6
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

    #drawChar 10, 10, snake.FOOD_CHAR, TXT_GREEN | TXT_RED << 4

    jsr waitForKey
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