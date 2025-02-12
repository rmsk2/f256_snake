screens .namespace

ONE   = 0
TWO   = 1
THREE = 2
FOUR  = 3
FIVE  = 4


LEVELS
    .word level1Func
    .word level2Func
    .word level3Func
    .word level4Func
    .word level5Func


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
 

LEVEL4_BLOCKS = 36
LEVEL4_OBSTACLES
    .byte 5, 13
    .byte 6, 13
    .byte 7, 13
    .byte 8, 13
    .byte 9, 13
    .byte 10, 13
    .byte 11, 13
    .byte 12, 13
    .byte 13, 13
    .byte 14, 13
    .byte 15, 13
    .byte 16, 13
    .byte 17, 13
    .byte 18, 13
    .byte 19, 13
    .byte 20, 13
    .byte 21, 13
    .byte 22, 13
    .byte 23, 13
    .byte 24, 13
    .byte 25, 13
    .byte 26, 13

    .byte 15, 6
    .byte 15, 7
    .byte 15, 8
    .byte 15, 9
    .byte 15, 10
    .byte 15, 11
    .byte 15, 12
    .byte 15, 13
    .byte 15, 14
    .byte 15, 15
    .byte 15, 16
    .byte 15, 17
    .byte 15, 18
    .byte 15, 19


LEVEL5_BLOCKS = 12
LEVEL5_OBSTACLES
    .byte 7, 3
    .byte 6, 4
    .byte 5, 5
    .byte 24 , 22
    .byte 25 , 21
    .byte 26 , 20
    .byte 7, 21
    .byte 8, 21
    .byte 9, 21
    .byte 24, 4
    .byte 23, 4
    .byte 22, 4

; This only works for a maximum number of 255 blocks
NUM_BLOCKS .byte 0
plotObstacles
    sta NUM_BLOCKS
    cmp #0
    beq _nothing
    ldx #0
_loop
    ldy #0
    lda (LVL_PTR2), y
    sta snake.PLOT_TEMP_X
    iny
    lda (LVL_PTR2), y
    sta snake.PLOT_TEMP_Y
    #add16bitImmediate 2, LVL_PTR2
    phx
    jsr snake.plotInternal
    plx
    inx
    cpx NUM_BLOCKS
    bne _loop
_nothing    
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


level4Func
    lda #snake.OBSTACLE_CHAR
    sta snake.PLOT_TEMP_CHAR

    #load16BitImmediate LEVEL3_OBSTACLES1, LVL_PTR2
    lda #LEVEL3_BLOCKS1
    jsr plotObstacles

    #load16BitImmediate LEVEL4_OBSTACLES, LVL_PTR2
    lda #LEVEL4_BLOCKS
    jsr plotObstacles

    #load16BitImmediate LEVEL3_OBSTACLES3, LVL_PTR2
    lda #LEVEL3_BLOCKS3
    jsr plotObstacles

    rts


level5Func
    jsr level4Func

    #load16BitImmediate LEVEL5_OBSTACLES, LVL_PTR2
    lda #LEVEL5_BLOCKS
    jsr plotObstacles

    rts


level1Func
    lda #snake.OBSTACLE_CHAR
    sta snake.PLOT_TEMP_CHAR

    #load16BitImmediate LEVEL1_OBSTACLES, LVL_PTR2
    lda #LEVEL1_BLOCKS
    jsr plotObstacles
    rts


level2Func
    lda #snake.OBSTACLE_CHAR
    sta snake.PLOT_TEMP_CHAR

    #load16BitImmediate LEVEL2_OBSTACLES, LVL_PTR2
    lda #LEVEL2_BLOCKS
    jsr plotObstacles
    rts

.endnamespace