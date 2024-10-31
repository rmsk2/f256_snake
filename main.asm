* = $0300
.cpu "w65c02"

jmp main

.include "api.asm"
.include "zeropage.asm"
.include "arith16.asm"
.include "snes.asm"
.include "khelp.asm"
.include "rtc.asm"
.include "clut.asm"
.include "txtio.asm"
.include "txtdraw.asm"
.include "random.asm"
.include "data.asm"
.include "snake.asm"
.include "font.asm"
.include "title.asm"

USE_SNES_PAD = 1

ASCII_L1 = $30
ASCII_LMAX = $34
ASCII_F3 = 131
ASCII_UP = 16
ASCII_DOWN = 14
ASCII_LEFT = 2
ASCII_RIGHT = 6
ASCII_SPACE = $20

TXT_START      .text "PRESS 0-4 TO PLAY. F3 TO EXIT."
TXT_END        .text "GAME OVER. PRESS 0-4 TO PLAY AGAIN."
TXT_PAUSED     .text "PAUSED"
TXT_NOT_PAUSED .text "      "
TXT_LEVEL      .text "L "

main
    jsr setupMMU
    lda #snake.GAME_SPEED
    sta snake.GAME.speed
    jsr clut.init
    jsr font.init
    jsr initEvents
    jsr random.init
    jsr snes.init

    jsr title.show
    jsr txtio.clear

    lda #snake.STATE_GAME
    sta snake.GAME.state

    #load16BitImmediate processTimerEvent, TIMER_VECTOR 
    #load16BitImmediate processKeyEvent, SIMPLE_FOCUS_VECTOR 
    #load16BitImmediate processJoystick, JOYSTICK_VECTOR 
    #load16BitImmediate processKeyUpEvent, KEY_UP_VECTOR
    #load16BitImmediate processSnesPad, SNES_VECTOR

    lda snake.GAME.speed
    sta TIMER_SPEED
    jsr setTimerAnimation
    jsr setTimerClockTick
_restart
    jsr snake.init
    #locate 5, 27
    #printString TXT_START, len(TXT_START)

    #locate 0, 1
    lda #snake.FOOD_CHAR
    jsr txtio.charOut
    #locate 0, 5
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


charToLevel
    cmp #ASCII_L1
    bcc _done
    cmp #ASCII_LMAX + 1
    bcs _done
    sta TEMP_LVL
    lda #snake.STATE_RESTART
    sta snake.GAME.state
    lda TEMP_LVL
    sec
    sbc #$30
    sta snake.GAME.levelNr
_done    
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
    jsr charToLevel
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
    jsr procPauseRequest
_end
    sec
    rts    
_done
    clc
    rts

; expects contents of $D884 in accu and $D885 in x
processSnesPad
    cmp #%11110111
    bne _checkDown
    lda #snake.UP
    bra _done
_checkDown
    cmp #%11111011
    bne _checkLeft
    lda #snake.DOWN
    bra _done
_checkLeft
    cmp #%11111101
    bne _checkRight
    lda #snake.LEFT
    bra _done
_checkRight
    cmp #%11111110
    bne _checkPause
    lda #snake.RIGHT
    bra _done
_checkPause
    txa
    and #%00000011
    cmp #%00000011
    beq _nothing
    jsr procPauseRequest
    rts
_done
    jsr processJoystick
_nothing
    rts


procPauseRequest
    lda snake.GAME.state
    cmp #snake.STATE_GAME
    bne _end
    lda snake.GAME.paused
    eor #1
    sta snake.GAME.paused
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
    tax
    and #16
    beq _procRequest
    jsr procPauseRequest
    rts
_procRequest
    ldy snake.GAME.locked
    bne _doNothing
    ldy snake.GAME.paused
    beq _continue
_doNothing
    rts
_continue
    txa
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
    cmp TIMER_COOKIE_ANIMATION
    bne _testClock
    lda snake.GAME.paused
    bne _restartTimer
    jsr snake.processUserInput
    jsr snake.spawnFood
_restartTimer
    jsr setTimerAnimation
    lda #BOOL_FALSE
    sta snake.GAME.locked
    rts
_testClock
    cmp TIMER_COOKIE_CLOCK
    bne _doNothing
    jsr showTime
    jsr setTimerClockTick
_doNothing
    rts


TIME_STR .fill 8
CURRENT_TIME .dstruct TimeStamp_t

showTime
    lda snake.GAME.state
    cmp #snake.STATE_GAME
    bne _done
    #getTimestamp CURRENT_TIME
    #diffTime snake.GAME.tsStart, CURRENT_TIME
    #getTimeStr TIME_STR, CURRENT_TIME
    #locate 17, 28
    #printString TIME_STR+3, 5
_done
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