SCREEN_X = 32
SCREEN_Y = 25

OFFSET_X = 4
OFFSET_Y = 1

.include "screens.asm"

snake .namespace

UP    = 1
DOWN  = 2
LEFT  = 4
RIGHT = 8

STATE_END  = 5                       ; Quit game
STATE_RESTART = 7                    ; Restart game
STATE_GAME = 6                       ; During game
STATE_WAITING = 8                    ; Waiting for restart or quit

HEAD_RIGHT = HEAD_RIGHT_TILE
HEAD_LEFT  = HEAD_LEFT_TILE
HEAD_UP    = HEAD_UP_TILE
HEAD_DOWN  = HEAD_DOWN_TILE
BODY_CHAR  = CT_SEGMENT_TILE
FOOD_CHAR  = APPLE_TILE
BACKGROUND_CHAR = GRASS_TILE
OBSTACLE_CHAR = OBSTACLE_TILE

GAME_SPEED = 12

snake_t .struct
    xPos      .byte OFFSET_X
    yPos      .byte OFFSET_Y
    direction .byte 0
    speed     .byte GAME_SPEED
    state     .byte STATE_WAITING
    spawnFood .byte BOOL_TRUE
    points    .word 0
    locked    .byte BOOL_FALSE
    paused    .byte BOOL_FALSE
    levelNr   .byte screens.ONE
    tsStart   .dstruct TimeStamp_t, 0, 0, 0
.endstruct

GAME .dstruct snake_t


toScreenX .macro memAddr
    lda \memAddr
    clc
    adc #OFFSET_X
.endmacro


toScreenY .macro memAddr
    lda \memAddr
    clc
    adc #OFFSET_Y
.endmacro


toScreenXCoord .macro memAddr
    #toScreenX \memAddr
    sta \memAddr
.endmacro


toScreenYCoord .macro memAddr
    #toScreenY \memAddr
    sta \memAddr
.endmacro


init 
    lda #BOOL_FALSE
    sta GAME.locked
    sta GAME.paused
    jsr txtio.init40x30
    lda #TXT_GREEN
    sta CURSOR_STATE.col 
    jsr txtio.clear
    lda #BOOL_FALSE
    sta CURSOR_STATE.scrollOn

    lda CURSOR_STATE.xMax
    sta txtdraw.X_MAX_MEM
    lda CURSOR_STATE.yMax
    sta txtdraw.Y_MAX_MEM

    lda #OFFSET_X - 1
    sta txtdraw.RECT_PARAMS.xpos
    lda #OFFSET_Y - 1
    sta txtdraw.RECT_PARAMS.ypos
    lda #SCREEN_X
    sta txtdraw.RECT_PARAMS.lenx
    lda #SCREEN_Y
    sta txtdraw.RECT_PARAMS.leny
    lda #TXT_GREEN
    sta txtdraw.RECT_PARAMS.col
    lda #BOOL_TRUE
    sta txtdraw.RECT_PARAMS.overwrite
    jsr txtdraw.drawRect

    ldx #OFFSET_X
    ldy #OFFSET_Y
    lda #GRASS_TILE
_loop
    jsr tiles.plotTileReg
    inx
    cpx #OFFSET_X+SCREEN_X
    bne _loop
    ldx #OFFSET_X
    iny
    cpy #OFFSET_Y+SCREEN_Y
    bne _loop

    lda #RIGHT
    sta GAME.direction

    lda GAME.levelNr
    jsr screens.modifyLevel

    jsr data.init
    jsr renderInitialQueue

    lda #SCREEN_Y/2
    sta GAME.yPos
    lda #SCREEN_X/2
    clc
    adc data.STATE.len
    dea
    sta GAME.xPos

    #load16BitImmediate 0, GAME.points
    jsr drawPoints

    #getTimestamp GAME.tsStart
    jsr showTime

    lda #BOOL_TRUE
    sta GAME.spawnFood

    rts


execLeft
    lda GAME.xPos
    beq _wrapAround
    dec GAME.xPos
    bra _set
_wrapAround
    lda #SCREEN_X-1
    sta GAME.xPos
_set
    rts


execRight
    lda GAME.xPos
    cmp #SCREEN_X-1
    beq _wrapAround
    inc GAME.xPos
    bra _set
_wrapAround
    stz GAME.xPos
_set 
    rts


execUp 
    lda GAME.yPos
    beq _wrapAround
    dec GAME.yPos
    bra _set
_wrapAround
    lda #SCREEN_Y-1
    sta GAME.yPos
_set
    rts


execDown
    lda GAME.yPos
    cmp #SCREEN_Y-1
    beq _wrapAround
    inc GAME.yPos
    bra _set
_wrapAround
    stz GAME.yPos
_set 
    rts


plotHeadCurrent
    ldx GAME.xPos
    ldy GAME.yPos
plotHead
    lda GAME.direction
    cmp #RIGHT
    bne _left
    lda #HEAD_RIGHT
    jmp plot
_left
    cmp #LEFT
    bne _up
    lda #HEAD_LEFT
    jmp plot
_up 
    cmp #UP
    bne _down
    lda #HEAD_UP
    jmp plot
_down
    lda #HEAD_DOWN
    jmp plot


plotBody
    lda #BODY_CHAR
    jmp plot


testObstacle
    cmp #BODY_CHAR
    beq _done
    cmp #OBSTACLE_CHAR
_done
    rts


plotBackground
    lda #BACKGROUND_CHAR
    jmp plot


testBackground
    cmp #BACKGROUND_CHAR
    rts


plotFood
    lda #FOOD_CHAR
    jmp plot


PLOT_TEMP_CHAR .byte 0
PLOT_TEMP_X    .byte 0
PLOT_TEMP_Y    .byte 0
plot
    sta PLOT_TEMP_CHAR
    stx PLOT_TEMP_X
    sty PLOT_TEMP_Y
plotInternal
    #toScreenXCoord PLOT_TEMP_X
    #toScreenYCoord PLOT_TEMP_Y

    ldx PLOT_TEMP_X
    ldy PLOT_TEMP_Y
    lda PLOT_TEMP_CHAR

    jsr tiles.plotTileReg

    rts


changeHeadIntoBody
    ldx LAST_POS.xPos
    ldy LAST_POS.yPos
    jsr plotBody
    rts


COUNT .byte 0
renderInitialQueue    
    stz COUNT    
_loop
    lda COUNT
    ina
    sta data.STATE.help
    stz data.STATE.help+1
    jsr data.calcMemPos
    jsr data.readWorkEntry

    ldx data.WORK_ENTRY.xPos
    ldy data.WORK_ENTRY.yPos    
    jsr plotBody
    
    inc COUNT
    lda COUNT
    cmp data.STATE.len
    bne _loop

    ldx data.WORK_ENTRY.xPos
    ldy data.WORK_ENTRY.yPos
    jsr plotHead

    rts


deleteLast
    jsr data.popBack
    ldx data.WORK_ENTRY.xPos
    ldy data.WORK_ENTRY.yPos
    jsr plotBackground
    rts


pushPos
    lda GAME.xPos
    sta data.WORK_ENTRY.xPos
    lda GAME.yPos
    sta data.WORK_ENTRY.yPos
    jsr data.pushFront
    rts

TXT_OVER       .text " GAME OVER! "
TXT_END        .text "PRESS F3 TO EXIT"
TXT_REPLAY     .text "PRESS 0-4 OR SPACE TO PLAY AGAIN"

; carry set if game can continue, else carry clear
TEMP_CHAR .byte 0
checkEnd
    #toScreenX GAME.xPos    
    tax
    #toScreenY GAME.yPos
    jsr tiles.peekTileReg
    jsr testObstacle
    bne _notEnd
    lda #snake.STATE_WAITING
    sta snake.GAME.state
    #locate 15, 0
    #printString TXT_OVER, len(TXT_OVER)
    #locate 12, 27
    #printString TXT_END, len(TXT_END)
    #locate 4, 29
    #printString TXT_REPLAY, len(TXT_REPLAY)
    clc
    rts
_notEnd
    sec
    rts


LAST_POS .dstruct entry_t

processUserInput
    lda GAME.state
    cmp #STATE_GAME
    beq _game
    bra _finished
_game
    lda GAME.xPos
    sta LAST_POS.xPos
    lda GAME.yPos
    sta LAST_POS.yPos

    lda GAME.direction
    tax
    and #UP
    beq _down
    jsr execUp
    bra _done
_down
    txa
    and #DOWN
    beq _left
    jsr execDown
    bra _done
_left
    txa
    and #LEFT
    beq _right
    jsr execLeft
    bra _done
_right
    txa
    and #RIGHT
    beq _done
    jsr execRight    
_done
    jsr checkEnd
    bcc _finished
    jsr pushPos
    jsr checkFood
    bcs _foodEaten    
    jsr deleteLast
_foodEaten    
    jsr changeHeadIntoBody
    jsr plotHeadCurrent
_finished
    rts


REMAINDER_X .byte 0
REMAINDER_Y .byte 0
CANDIDATE_X .byte 0
CANDIDATE_Y .byte 0
spawnFood
    lda GAME.spawnFood
    beq _done
    
    jsr random.get
    sta CANDIDATE_X
    stx CANDIDATE_Y
    ; no uniform distribution, but hey this is not a cryptographic
    ; application
    #mod8x8Immediate SCREEN_X, CANDIDATE_X, REMAINDER_X
    #mod8x8Immediate SCREEN_Y, CANDIDATE_Y, REMAINDER_Y

    #toScreenX REMAINDER_X
    tax
    #toScreenY REMAINDER_Y
    jsr tiles.peekTileReg
    jsr testBackground
    bne _done

    ldx REMAINDER_X
    ldy REMAINDER_Y
    jsr plotFood
    
    lda #BOOL_FALSE
    sta GAME.spawnFood
_done
    rts


; does not make much sense at the moment. Maybe
; we have several food items in the future
testFood
    cmp #FOOD_CHAR
    rts


checkFood
    #toScreenX GAME.xPos
    tax
    #toScreenY GAME.yPos
    jsr tiles.peekTileReg
    jsr testFood
    beq _eaten
    clc
    rts
_eaten
    #inc16Bit GAME.points
    jsr drawPoints
    lda #BOOL_TRUE
    sta GAME.spawnFood
    sec
    rts


drawPoints
    #locate 0, 3
    #move16Bit GAME.points, txtio.WORD_TEMP
    jsr txtio.printWordDecimal
    rts

.endnamespace