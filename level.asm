levels .namespace

ONE   = 0
TWO   = 1
THREE = 2


LEVELS
    .word level1Func
    .word level2Func
    .word level3Func


MOD_VECTOR .word 0

LEVEL1_BLOCKS = 16
LEVEL1_OBSTACLES
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

LEVEL2_BLOCKS = 24
LEVEL2_OBSTACLES
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

LEVEL3_BLOCKS1 = 32
LEVEL3_OBSTACLES1
    .byte 0, 0
    .byte 1, 0
    .byte 2, 0
    .byte 3, 0
    .byte 4, 0
    .byte 5, 0
    .byte 6, 0
    .byte 7, 0
    .byte 8, 0
    .byte 9, 0
    .byte 10, 0
    .byte 11, 0
    .byte 12, 0
    .byte 13, 0
    .byte 14, 0
    .byte 15, 0
    .byte 16, 0
    .byte 17, 0
    .byte 18,0
    .byte 19, 0
    .byte 20, 0
    .byte 21, 0
    .byte 22, 0
    .byte 23, 0
    .byte 24, 0
    .byte 25, 0
    .byte 26, 0
    .byte 27, 0
    .byte 28, 0
    .byte 29, 0
    .byte 30, 0
    .byte 31, 0


LEVEL3_BLOCKS3 = 24
LEVEL3_OBSTACLES3
    .byte 0, 1
    .byte 0, 2
    .byte 0, 3
    .byte 0, 4
    .byte 0, 5
    .byte 0, 6
    .byte 0, 7
    .byte 0, 8
    .byte 0, 9
    .byte 0, 10
    .byte 0, 11
    .byte 0, 12
    .byte 0, 13
    .byte 0, 14
    .byte 0, 15
    .byte 0, 16
    .byte 0, 17
    .byte 0, 18
    .byte 0, 19
    .byte 0, 20
    .byte 0, 21
    .byte 0, 22
    .byte 0, 23 
    .byte 0, 24

LEVEL3_BLOCKS2 = 36
LEVEL3_OBSTACLES2
    .byte 8, 6
    .byte 9, 6
    .byte 10, 6
    .byte 11, 6
    .byte 12, 6
    .byte 8, 7
    .byte 8, 8
    .byte 8, 9
    .byte 8, 10
    .byte 23, 15
    .byte 23, 16
    .byte 23, 17
    .byte 23, 18
    .byte 23, 19
    .byte 22, 19
    .byte 21, 19
    .byte 20, 19
    .byte 19, 19
    .byte 23, 10
    .byte 23, 9
    .byte 23, 8
    .byte 23, 7
    .byte 23, 6
    .byte 22, 6
    .byte 21, 6
    .byte 20, 6
    .byte 19, 6
    .byte 8, 15
    .byte 8, 16
    .byte 8, 17
    .byte 8, 18
    .byte 8, 19
    .byte 9, 19
    .byte 10, 19
    .byte 11, 19
    .byte 12, 19
 


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


level3Func
    lda #TXT_GREEN | TXT_BROWN << 4
    sta snake.PLOT_TEMP_COL
    lda #snake.OBSTACLE_CHAR
    sta snake.PLOT_TEMP_CHAR

    #load16BitImmediate LEVEL3_OBSTACLES1, LVL_PTR2
    lda #LEVEL3_BLOCKS1
    jsr plotObstacles

    #load16BitImmediate LEVEL3_OBSTACLES3, LVL_PTR2
    lda #LEVEL3_BLOCKS3
    jsr plotObstacles

    #load16BitImmediate LEVEL3_OBSTACLES2, LVL_PTR2
    lda #LEVEL3_BLOCKS2
    jsr plotObstacles

    rts


level1Func
    lda #TXT_GREEN | TXT_BROWN << 4
    sta snake.PLOT_TEMP_COL
    lda #snake.OBSTACLE_CHAR
    sta snake.PLOT_TEMP_CHAR

    #load16BitImmediate LEVEL1_OBSTACLES, LVL_PTR2
    lda #LEVEL1_BLOCKS
    jsr plotObstacles
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

.endnamespace