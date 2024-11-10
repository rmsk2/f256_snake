title .namespace

TITLE .text "F256 SNAKE v1.2.0"
TXT_AUTHOR .text "BY MARTIN GRAP (@mgr42)"
TXT_PAUSE .text "PRESS SPACE TO PAUSE OR RESUME GAME"
TXT_LEVEL .text "PRESS 0-4 TO ENTER CORRESPONDING SCREEN"
TXT_USAGE .text "USE CURSOR KEYS, JOYSTICK OR SNES PAD"

FRAME_X = 4
FRAME_Y = 5
SIZE_X = 30
SIZE_Y = 15


show
    jsr txtio.init40x30
    lda #TXT_GREEN
    sta CURSOR_STATE.col 
    jsr txtio.clear
    lda #BOOL_FALSE
    sta CURSOR_STATE.scrollOn

    #locate 11,1
    #printString TITLE, len(TITLE)
    #locate 8, 3
    #printString TXT_AUTHOR, len(TXT_AUTHOR)
    #locate 1,23
    #printString TXT_USAGE, len(TXT_USAGE)
    #locate 2,25
    #printString TXT_PAUSE, len(TXT_PAUSE)
    #locate 0,27
    #printString TXT_LEVEL, len(TXT_LEVEL)

    lda CURSOR_STATE.xMax
    sta txtdraw.X_MAX_MEM
    lda CURSOR_STATE.yMax
    sta txtdraw.Y_MAX_MEM

    ldx #FRAME_X + 1
    ldy #FRAME_Y + 1
    lda #GRASS_TILE
_loop
    jsr tiles.plotTileReg
    inx
    cpx #FRAME_X+SIZE_X+1
    bne _loop
    ldx #FRAME_X + 1
    iny
    cpy #FRAME_Y+SIZE_Y+1
    bne _loop

    lda #FRAME_X
    sta txtdraw.RECT_PARAMS.xpos
    lda #FRAME_Y
    sta txtdraw.RECT_PARAMS.ypos
    lda #SIZE_X
    sta txtdraw.RECT_PARAMS.lenx
    lda #SIZE_Y
    sta txtdraw.RECT_PARAMS.leny
    lda #TXT_GREEN
    sta txtdraw.RECT_PARAMS.col
    lda #BOOL_TRUE
    sta txtdraw.RECT_PARAMS.overwrite
    jsr txtdraw.drawRect

    #plotTile 10, 10, APPLE_TILE
    #plotTile 15, 15, CT_SEGMENT_TILE
    #plotTile 16, 15, CT_SEGMENT_TILE
    #plotTile 17, 15, CT_SEGMENT_TILE
    #plotTile 18, 15, CT_SEGMENT_TILE
    #plotTile 19, 15, CT_SEGMENT_TILE
    #plotTile 20, 15, CT_SEGMENT_TILE
    #plotTile 21, 15, CT_SEGMENT_TILE
    #plotTile 21, 14, CT_SEGMENT_TILE
    #plotTile 21, 13, CT_SEGMENT_TILE
    #plotTile 21, 12, HEAD_UP_TILE
    #plotTile 25, 14, OBSTACLE_TILE
    #plotTile 26, 13, OBSTACLE_TILE
    #plotTile 27, 12, OBSTACLE_TILE
    #plotTile 28, 11, OBSTACLE_TILE

    jsr waitForKey
    jsr charToLevel

    rts

.endnamespace