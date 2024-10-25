SCREEN_X = 30
SCREEN_Y = 20

OFFSET_X = 15
OFFSET_Y = 5

snake .namespace

UP    = 1
DOWN  = 2
LEFT  = 4
RIGHT = 8

STATE_END  = 5                       ; Quit game
STATE_RESTART = 7                    ; Restart game
STATE_GAME = 6                       ; During game
STATE_WAITING = 8                    ; Waiting for restart or quit

HEAD_CHAR = 214
BODY_CHAR = 215
FOOD_CHAR = 255

snake_t .struct
    xPos      .byte OFFSET_X
    yPos      .byte OFFSET_Y
    direction .byte 0
    speed     .byte 10
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
    jsr txtio.init80x60
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
    lda CURSOR_STATE.col
    sta txtdraw.RECT_PARAMS.col
    lda #1
    sta txtdraw.RECT_PARAMS.overwrite
    jsr txtdraw.drawRect

    jsr data.init
    jsr renderInitialQueue

    lda #RIGHT
    sta GAME.direction

    lda #BOOL_TRUE
    sta GAME.spawnFood

    rts


crsrSet 
    lda GAME.xPos
    clc
    adc #OFFSET_X
    sta CURSOR_STATE.xPos
    lda GAME.yPos
    clc
    adc #OFFSET_Y
    sta CURSOR_STATE.yPos
    jsr txtio.cursorSet
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
    jsr crsrSet
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
    jsr crsrSet
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
    jsr crsrSet
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
    jsr crsrSet
    rts


plotHead
    lda #HEAD_CHAR
    jsr txtio.plot
    rts


plotBody
    lda #BODY_CHAR
    jsr txtio.plot
    rts


changeHeadIntoBody
    lda GAME.xPos
    sta X_TEMP
    lda GAME.yPos
    sta Y_TEMP

    lda LAST_POS.xPos
    sta GAME.xPos
    lda LAST_POS.yPos
    sta GAME.yPos
    jsr crsrSet

    lda #BODY_CHAR
    jsr txtio.plot

    lda X_TEMP
    sta GAME.xPos
    lda Y_TEMP
    sta GAME.yPos
    jsr crsrSet

    rts


COUNT .byte 0
renderInitialQueue
    lda #SCREEN_X/2
    sta GAME.xPos
    lda #SCREEN_Y/2
    sta GAME.yPos
    jsr crsrSet

    stz COUNT    
_loop
    lda COUNT
    ina
    sta data.STATE.help
    stz data.STATE.help+1
    jsr data.calcMemPos
    jsr data.readWorkEntry

    lda data.WORK_ENTRY.xPos
    sta GAME.xPos
    lda data.WORK_ENTRY.yPos
    sta GAME.yPos
    jsr crsrSet
    jsr plotBody
    
    inc COUNT
    lda COUNT
    cmp data.STATE.len
    bne _loop

    jsr plotHead

    rts


X_TEMP .byte 0
Y_TEMP .byte 0
deleteLast
    lda GAME.xPos
    sta X_TEMP
    lda GAME.yPos
    sta Y_TEMP

    jsr data.popBack
    lda data.WORK_ENTRY.xPos
    sta GAME.xPos
    lda data.WORK_ENTRY.yPos
    sta GAME.yPos
    jsr crsrSet

    lda #$20
    jsr txtio.plot

    lda X_TEMP
    sta GAME.xPos
    lda Y_TEMP
    sta GAME.yPos
    jsr crsrSet
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
    jsr txtio.getChar
    cmp #BODY_CHAR
    bne _notEnd
    lda #snake.STATE_WAITING
    sta snake.GAME.state
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
    jsr plotHead
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

    #toScreenXCoord REMAINDER_X
    #toScreenYCoord REMAINDER_Y

    ldx REMAINDER_X
    lda REMAINDER_Y
    jsr txtio.peekChar
    cmp #$20
    bne _done

    ldx REMAINDER_X
    ldy REMAINDER_Y
    lda #FOOD_CHAR
    jsr txtio.pokeChar
    
    lda #BOOL_FALSE
    sta GAME.spawnFood
_done
    rts


checkFood
    #toScreenX GAME.xPos
    tax
    #toScreenY GAME.yPos
    jsr txtio.peekChar
    cmp #FOOD_CHAR
    beq _eaten
    clc
    rts
_eaten
    lda #BOOL_TRUE
    sta GAME.spawnFood
    sec
    rts

.endnamespace