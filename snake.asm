SCREEN_X = 32
SCREEN_Y = 25

OFFSET_X = 4
OFFSET_Y = 1

snake .namespace

UP    = 1
DOWN  = 2
LEFT  = 4
RIGHT = 8

STATE_END  = 5                       ; Quit game
STATE_RESTART = 7                    ; Restart game
STATE_GAME = 6                       ; During game
STATE_WAITING = 8                    ; Waiting for restart or quit

HEAD_RIGHT = 212
HEAD_LEFT  = 213
HEAD_UP    = 211
HEAD_DOWN  = 210
BODY_CHAR  = 215
FOOD_CHAR  = 255
BACKGROUND_CHAR = 200

snake_t .struct
    xPos      .byte OFFSET_X
    yPos      .byte OFFSET_Y
    direction .byte 0
    speed     .byte 12
    state     .byte STATE_WAITING
    spawnFood .byte BOOL_TRUE
    points    .word 0
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
    lda GAME.speed
    sta TIMER_SPEED
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
    lda #TXT_GREEN | TXT_GRAY << 4
    sta txtdraw.RECT_PARAMS.col
    lda #BOOL_TRUE
    sta txtdraw.RECT_PARAMS.overwrite
    jsr txtdraw.drawRect

    lda #RIGHT
    sta GAME.direction

    jsr data.init
    jsr renderInitialQueue

    lda #SCREEN_Y/2
    sta GAME.yPos
    lda #SCREEN_X/2 + 4
    sta GAME.xPos

    #load16BitImmediate 0, GAME.points
    jsr drawPoints

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
    lda #TXT_GREEN
    sta PLOT_TEMP_COL
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
    lda #TXT_GREEN
    sta PLOT_TEMP_COL
    lda #BODY_CHAR
    jmp plot


testBody
    cmp #BODY_CHAR
    rts


plotBackground
    lda #TXT_GREEN | TXT_GRAY << 4
    sta PLOT_TEMP_COL
    lda #BACKGROUND_CHAR
    jmp plot


testBackground
    cmp #BACKGROUND_CHAR
    rts


plotFood
    lda #TXT_GREEN | TXT_RED << 4
    sta PLOT_TEMP_COL
    lda #FOOD_CHAR
    jmp plot


; does not make much sense at the moment. Maybe
; we have several food items in the future
testFood
    cmp #FOOD_CHAR
    rts


PLOT_TEMP_CHAR .byte 0
PLOT_TEMP_COL  .byte 0
PLOT_TEMP_X    .byte 0
PLOT_TEMP_Y    .byte 0
plot
    sta PLOT_TEMP_CHAR
    stx PLOT_TEMP_X
    sty PLOT_TEMP_Y
    #toScreenXCoord PLOT_TEMP_X
    #toScreenYCoord PLOT_TEMP_Y

    ldx PLOT_TEMP_X
    ldy PLOT_TEMP_Y
    lda PLOT_TEMP_CHAR

    jsr txtio.pokeChar

    ldx PLOT_TEMP_X
    ldy PLOT_TEMP_Y
    lda PLOT_TEMP_COL

    jsr txtio.pokeColor

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


; carry set if game can continue, else carry clear
TEMP_CHAR .byte 0
checkEnd
    #toScreenX GAME.xPos    
    tax
    #toScreenY GAME.yPos
    jsr txtio.peekChar
    jsr testBody
    bne _notEnd
    lda #snake.STATE_WAITING
    sta snake.GAME.state
    #locate 3, 27
    #printString TXT_END, len(TXT_END)
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
    #mod8x8Immediate SCREEN_X, CANDIDATE_X, REMAINDER_X
    #mod8x8Immediate SCREEN_Y, CANDIDATE_Y, REMAINDER_Y

    #toScreenX REMAINDER_X
    tax
    #toScreenY REMAINDER_Y
    jsr txtio.peekChar
    jsr testBackground
    bne _done

    ldx REMAINDER_X
    ldy REMAINDER_Y
    jsr plotFood
    
    lda #BOOL_FALSE
    sta GAME.spawnFood
_done
    rts


checkFood
    #toScreenX GAME.xPos
    tax
    #toScreenY GAME.yPos
    jsr txtio.peekChar
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
    #locate 0, 1
    #move16Bit GAME.points, txtio.WORD_TEMP
    jsr txtio.printWordDecimal
    rts

.endnamespace