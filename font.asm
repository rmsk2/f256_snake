font .namespace 

init
    #load16BitImmediate APPLE, FONT_PTR1
    lda #snake.FOOD_CHAR
    jsr modifyCharacter

    #load16BitImmediate CT_SEGMENT, FONT_PTR1
    lda #snake.BODY_CHAR
    jsr modifyCharacter

    #load16BitImmediate HEAD_RIGHT, FONT_PTR1
    lda #snake.HEAD_RIGHT
    jsr modifyCharacter

    #load16BitImmediate HEAD_LEFT, FONT_PTR1
    lda #snake.HEAD_LEFT
    jsr modifyCharacter

    #load16BitImmediate HEAD_DOWN, FONT_PTR1
    lda #snake.HEAD_DOWN
    jsr modifyCharacter

    #load16BitImmediate HEAD_UP, FONT_PTR1
    lda #snake.HEAD_UP
    jsr modifyCharacter

    #load16BitImmediate GRASS, FONT_PTR1
    lda #snake.BACKGROUND_CHAR
    jsr modifyCharacter

    #load16BitImmediate dataChar0, FONT_PTR1
    lda #$30
    jsr modifyCharacter

    #load16BitImmediate dataChar1, FONT_PTR1
    lda #$31
    jsr modifyCharacter

    #load16BitImmediate dataChar2, FONT_PTR1
    lda #$32
    jsr modifyCharacter

    #load16BitImmediate dataChar3, FONT_PTR1
    lda #$33
    jsr modifyCharacter

    #load16BitImmediate dataChar4, FONT_PTR1
    lda #$34
    jsr modifyCharacter

    #load16BitImmediate dataChar5, FONT_PTR1
    lda #$35
    jsr modifyCharacter

    #load16BitImmediate dataChar6, FONT_PTR1
    lda #$36
    jsr modifyCharacter

    #load16BitImmediate dataChar7, FONT_PTR1
    lda #$37
    jsr modifyCharacter

    #load16BitImmediate dataChar8, FONT_PTR1
    lda #$38
    jsr modifyCharacter

    #load16BitImmediate dataChar9, FONT_PTR1
    lda #$39
    jsr modifyCharacter

    rts


TEMP_INDEX .word 0
CHAR_LEN   .byte 8
; accu contains character code to modify. FONT_PTR1 has to 
; point to the character data
modifyCharacter
    sta TEMP_INDEX
    #saveIo
    #setIo 1
    ;#mul8x8BitCoproc TEMP_INDEX, CHAR_LEN, FONT_PTR2
    #move16Bit TEMP_INDEX, FONT_PTR2
    #double16Bit FONT_PTR2
    #double16Bit FONT_PTR2
    #double16Bit FONT_PTR2
    #add16BitImmediate $C000, FONT_PTR2

    ldy #0
_loop
    lda (FONT_PTR1), y
    sta (FONT_PTR2), y
    iny
    cpy #8
    bne _loop

    #restoreIo
    rts


APPLE
    .byte %00000100
    .byte %00001000
    .byte %00111110
    .byte %01111111
    .byte %01111111    
    .byte %01111111
    .byte %01111111
    .byte %00111110

CT_SEGMENT
    .byte %01111110
    .byte %10000001
    .byte %10100001
    .byte %10100001
    .byte %10000101
    .byte %10000101    
    .byte %10000001
    .byte %01111110

HEAD_RIGHT
    .byte %11001110
    .byte %11111001
    .byte %11111100
    .byte %11111100
    .byte %11111100
    .byte %11111100
    .byte %11111001
    .byte %11001110

HEAD_LEFT
    .byte %01110011
    .byte %10011111
    .byte %00111111
    .byte %00111111    
    .byte %00111111
    .byte %00111111
    .byte %10011111
    .byte %01110011

HEAD_UP
    .byte %01000010
    .byte %10000001
    .byte %10111101
    .byte %11111111
    .byte %01111110
    .byte %01111110
    .byte %11111111
    .byte %11111111

HEAD_DOWN
    .byte %11111111
    .byte %11111111
    .byte %01111110
    .byte %01111110
    .byte %11111111
    .byte %10111101
    .byte %10000001
    .byte %01000010

GRASS
    .byte 0
    .byte 0
    .byte %00000100
    .byte %00101000
    .byte %00011000
    .byte %10001000
    .byte %01000000
    .byte %01000000

dataChar0
    .byte %01111110
    .byte %01000010
    .byte %01000010
    .byte %01000010
    .byte %01000110
    .byte %01000110
    .byte %01111110
    .byte %00000000

dataChar1
    .byte %00011000
    .byte %00001000
    .byte %00001000
    .byte %00001000
    .byte %00001000
    .byte %00001000
    .byte %00001000
    .byte %00000000

dataChar2
    .byte %01111110
    .byte %00000010
    .byte %00000010
    .byte %01111110
    .byte %01000000
    .byte %01100000
    .byte %01111110
    .byte %00000000

dataChar3
    .byte %01111110
    .byte %00000010
    .byte %00000010
    .byte %01111110
    .byte %00000010
    .byte %00000110
    .byte %01111110
    .byte %00000000

dataChar4
    .byte %01000010
    .byte %01000010
    .byte %01100010
    .byte %01111110
    .byte %00000010
    .byte %00000010
    .byte %00000010
    .byte %00000000

dataChar5
    .byte %01111110
    .byte %01000000
    .byte %01000000
    .byte %01111110
    .byte %00000010
    .byte %00000110
    .byte %01111110
    .byte %00000000

dataChar6
    .byte %01000000
    .byte %01000000
    .byte %01000000
    .byte %01111110
    .byte %01000010
    .byte %01000110
    .byte %01111110
    .byte %00000000

dataChar7
    .byte %01111110
    .byte %00000110
    .byte %00000010
    .byte %00000010
    .byte %00000010
    .byte %00000010
    .byte %00000010
    .byte %00000000

dataChar8
    .byte %01111110
    .byte %01000010
    .byte %01000010
    .byte %01111110
    .byte %01000010
    .byte %01000110
    .byte %01111110
    .byte %00000000

dataChar9
    .byte %01111110
    .byte %01000010
    .byte %01100010
    .byte %01111110
    .byte %00000010
    .byte %00000010
    .byte %00000010
    .byte %00000000    
.endnamespace