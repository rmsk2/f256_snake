* = $0300
.cpu "w65c02"

jmp main

.include "api.asm"
.include "zeropage.asm"
.include "arith16.asm"
.include "khelp.asm"
.include "clut.asm"
.include "txtio.asm"
.include "txtdraw.asm"
.include "random.asm"
.include "data.asm"
.include "snake.asm"
.include "font.asm"


ASCII_L1 = $30
ASCII_LMAX = $32
ASCII_F3 = 131
ASCII_UP = 16
ASCII_DOWN = 14
ASCII_LEFT = 2
ASCII_RIGHT = 6
ASCII_SPACE = $20

TXT_START      .text "PRESS 0-2 TO PLAY. F3 TO EXIT."
TXT_END        .text "GAME OVER. PRESS 0-2 TO PLAY AGAIN."
TXT_PAUSED     .text "PAUSED"
TXT_NOT_PAUSED .text "      "
TXT_LEVEL      .text "L "

main
    jsr setupMMU
    ; set speed for K
    lda #snake.SPEED_F256_K
    sta snake.GAME.speed
    ; check machine id. The Jr. seems to run a bit faster.
    lda $D6A7
    cmp #$02
    bne _defaultSpeed
    ; Jr. was detected => modify speed
    lda #snake.SPEED_F256_JR
    sta snake.GAME.speed
_defaultSpeed
    jsr clut.init
    jsr font.init
    jsr initEvents
    jsr random.init

    #load16BitImmediate processTimerEvent, TIMER_VECTOR 
    #load16BitImmediate processKeyEvent, SIMPLE_FOCUS_VECTOR 
    #load16BitImmediate processJoystick, JOYSTICK_VECTOR 
    #load16BitImmediate processKeyUpEvent, KEY_UP_VECTOR

    jsr setTimerAnimation
_restart
    jsr snake.init
    #locate 5, 27
    #printString TXT_START, len(TXT_START)
    #locate 0, 3
    printString TXT_LEVEL, len(TXT_LEVEL)
    lda snake.GAME.levelNr
    clc
    adc #$30
    jsr txtio.charOut
    jsr simpleKeyEventLoop

    lda snake.GAME.state
    cmp #snake.STATE_RESTART
    bne _quit
    lda #snake.STATE_GAME
    sta snake.GAME.state
    bra _restart
_quit
    jsr exitToBasic
    ; I guess we never get here ....
    jsr sys64738
    rts


processKeyUpEvent
    rts

TEMP_LVL .byte 0
processKeyEvent
    cmp #ASCII_UP
    bne _down
    lda #snake.UP
    bra _procPress
_down
    cmp #ASCII_DOWN
    bne _left
    lda #snake.DOWN
    bra _procPress
_left
    cmp #ASCII_LEFT
    bne _right
    lda #snake.LEFT
    bra _procPress
_right
    cmp #ASCII_RIGHT
    bne _level
    lda #snake.RIGHT
_procPress
    jsr processJoystick
    bra _end
_level
    cmp #ASCII_L1
    bcc _checkF3
    cmp #ASCII_LMAX
    bcc _calcLevel
    beq _calcLevel
    bra _checkF3
_calcLevel
    sta TEMP_LVL
    lda #snake.STATE_RESTART
    sta snake.GAME.state
    lda TEMP_LVL
    sec
    sbc #$30
    sta snake.GAME.levelNr
    bra _done
_checkF3
    cmp #ASCII_F3
    bne _pause
    lda #snake.STATE_END
    sta snake.GAME.state
    bra _done
_pause
    cmp #ASCII_SPACE
    bne _end
    lda snake.GAME.state
    cmp #snake.STATE_GAME
    bne _end
    lda snake.GAME.paused
    eor #1
    sta snake.GAME.paused
    jsr printPaused
_end
    sec
    rts    
_done
    clc
    rts


printPaused
    #locate 17, 29    
    lda snake.GAME.paused
    beq _notPaused
    #printString TXT_PAUSED, len(TXT_PAUSED)
    bra _end
_notPaused
    #printString TXT_NOT_PAUSED, len(TXT_NOT_PAUSED)
_end
    rts


lockState
    lda #BOOL_TRUE
    sta snake.GAME.locked
    rts


processJoystick
    ldy snake.GAME.locked
    bne _doNothing
    ldy snake.GAME.paused
    beq _continue
_doNothing
    rts
_continue
    tax
    and #snake.UP
    beq _down
    lda snake.GAME.direction
    cmp #snake.DOWN
    beq _illegalUp
    lda #snake.UP
    sta snake.GAME.direction
    jsr lockState
_illegalUp
    rts
_down
    txa
    and #snake.DOWN
    beq _left
    lda snake.GAME.direction
    cmp #snake.UP
    beq _illegalDown
    lda #snake.DOWN
    sta snake.GAME.direction
    jsr lockState
_illegalDown    
    rts
_left
    txa
    and #snake.LEFT
    beq _right
    lda snake.GAME.direction
    cmp #snake.RIGHT
    beq _illegalLeft
    lda #snake.LEFT
    sta snake.GAME.direction
    jsr lockState
_illegalLeft    
    rts
_right
    txa
    and #snake.RIGHT
    beq _done
    lda snake.GAME.direction
    cmp #snake.LEFT
    beq _done
    lda #snake.RIGHT
    sta snake.GAME.direction
    jsr lockState
_done
    rts


processTimerEvent
    lda snake.GAME.paused
    bne _restartTimer
    jsr snake.processUserInput
    jsr snake.spawnFood
_restartTimer
    jsr setTimerAnimation
    lda #BOOL_FALSE
    sta snake.GAME.locked
    rts


setupMMU
    lda #%10110011                         ; set active and edit LUT to three and allow editing
    sta 0
    lda #%00000000                         ; enable io pages and set active page to 0
    sta 1

    ; map BASIC ROM out and RAM in
    lda #4
    sta 8+4
    lda #5
    sta 8+5
    rts