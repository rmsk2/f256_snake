levels .namespace

ONE   = 0
TWO   = 1
THREE = 2


LEVELS
    .word level1Func
    .word level2Func
    .word level3Func


MOD_VECTOR .word 0

LEVEL2_BLOCKS = 16
LEVEL2_OBSTACLES
    .byte 4, 1
    .byte 3, 2
    .byte 2, 3
    .byte 1, 4
    .byte 30, 20
    .byte 29, 21
    .byte 28, 22
    .byte 27, 23
    .byte 14, 9
    .byte 15, 9
    .byte 16, 9
    .byte 17, 9
    .byte 14, 14
    .byte 15, 14
    .byte 16, 14
    .byte 17, 14   

LEVEL3_BLOCKS = 24
LEVEL3_OBSTACLES
    .byte 0, 9
    .byte 1, 9
    .byte 2, 9
    .byte 3, 9

    .byte 10, 9
    .byte 11, 9
    .byte 12, 9
    .byte 13, 9

    .byte 20, 9
    .byte 21, 9
    .byte 22, 9
    .byte 23, 9

    .byte 7, 15
    .byte 8, 15
    .byte 9, 15
    .byte 10, 15

    .byte 17, 15
    .byte 18, 15
    .byte 19, 15
    .byte 20, 15

    .byte 28, 15
    .byte 29, 15
    .byte 30, 15
    .byte 31, 15


; This only works for a mximum number of 128 blocks
NUM_BLOCKS .byte 0
plotObstacles
    sta NUM_BLOCKS
    ldy #0
    ldx #0
_loop
    lda (LVL_PTR2), y
    sta snake.PLOT_TEMP_X
    iny
    lda (LVL_PTR2), y
    sta snake.PLOT_TEMP_Y
    iny
    phy
    phx
    jsr snake.plotInternal
    plx
    ply
    inx
    cpx NUM_BLOCKS
    bne _loop
    rts

; accu has to contain level number. At the moment only
; 128 levels are supported.
modifyLevel
    ; determine function to call
    asl
    clc
    adc #<LEVELS
    sta LVL_PTR1
    lda #>LEVELS
    adc #0
    sta LVL_PTR1 + 1
    lda (LVL_PTR1)
    sta MOD_VECTOR
    ldy #1
    lda (LVL_PTR1), y
    sta MOD_VECTOR + 1
    jmp (MOD_VECTOR)


level1Func
    rts


level2Func
    lda #TXT_GREEN | TXT_BROWN << 4
    sta snake.PLOT_TEMP_COL
    lda #snake.OBSTACLE_CHAR
    sta snake.PLOT_TEMP_CHAR

    #load16BitImmediate LEVEL2_OBSTACLES, LVL_PTR2
    lda #LEVEL2_BLOCKS
    jsr plotObstacles
    rts


level3Func
    lda #TXT_GREEN | TXT_BROWN << 4
    sta snake.PLOT_TEMP_COL
    lda #snake.OBSTACLE_CHAR
    sta snake.PLOT_TEMP_CHAR

    #load16BitImmediate LEVEL3_OBSTACLES, LVL_PTR2
    lda #LEVEL3_BLOCKS
    jsr plotObstacles
    rts

.endnamespace