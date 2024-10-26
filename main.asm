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


ASCII_F1 = 129
ASCII_F3 = 131
ASCII_UP = 16
ASCII_DOWN = 14
ASCII_LEFT = 2
ASCII_RIGHT = 6

TXT_START .text "Press F1 to play. F3 to exit."
TXT_END   .text "GAME OVER. Press F1 to play again."

main
    jsr setupMMU
    jsr clut.init
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


processKeyEvent
    cmp #ASCII_F1
    bne _checkF3
    lda #snake.STATE_RESTART
    sta snake.GAME.state
    bra _done
_checkF3
    cmp #ASCII_F3
    bne _checkCrsr
    lda #snake.STATE_END
    sta snake.GAME.state
    bra _done
_checkCrsr
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
    bne _end
    lda #snake.RIGHT
_procPress
    jsr processJoystick
_end
    sec
    rts    
_done
    clc
    rts


processJoystick
    tax
    and #snake.UP
    beq _down
    lda snake.GAME.direction
    cmp #snake.DOWN
    beq _illegalUp
    lda #snake.UP
    sta snake.GAME.direction
    jsr snake.processUserInput
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
    jsr snake.processUserInput
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
    jsr snake.processUserInput
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
    jsr snake.processUserInput
_done
    rts


processTimerEvent
    jsr snake.processUserInput
    jsr snake.spawnFood
    jsr setTimerAnimation
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