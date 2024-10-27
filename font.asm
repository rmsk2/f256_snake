font .namespace 

COUNT   .byte 0
OFFSET  .word 0 
init
    stz COUNT
    #load16BitImmediate 0, OFFSET
_loop
    #load16BitImmediate CHANGED_CHARS, FONT_PTR3
    #add16Bit OFFSET, FONT_PTR3
    ldy #ModChar_t.addr
    lda (FONT_PTR3), y
    sta FONT_PTR1
    iny
    lda (FONT_PTR3), y
    sta FONT_PTR1 + 1
    ldy #ModChar_t.code
    lda (FONT_PTR3), y
    jsr modifyCharacter
    inc COUNT
    lda COUNT
    sta OFFSET
    stz OFFSET + 1
    #double16Bit OFFSET
    #double16Bit OFFSET
    lda COUNT
    cmp #NUM_CHANGED_CHARS
    bne _loop
    rts


ModChar_t .struct charCode, memAddr
    code    .byte \charCode
    addr    .word \memAddr
    reserve .byte 0
.endstruct

NUM_CHANGED_CHARS = 8

CHANGED_CHARS
C1   .dstruct ModChar_t, snake.FOOD_CHAR, APPLE
C2   .dstruct ModChar_t, snake.BODY_CHAR, CT_SEGMENT
C3   .dstruct ModChar_t, snake.HEAD_RIGHT, HEAD_RIGHT 
C4   .dstruct ModChar_t, snake.HEAD_LEFT, HEAD_LEFT 
C5   .dstruct ModChar_t, snake.HEAD_UP, HEAD_UP
C6   .dstruct ModChar_t, snake.HEAD_DOWN, HEAD_DOWN 
C7   .dstruct ModChar_t, snake.BACKGROUND_CHAR, GRASS
C18  .dstruct ModChar_t, snake.OBSTACLE_CHAR, OBSTACLE
C8   .dstruct ModChar_t, $30, dataChar0
C9   .dstruct ModChar_t, $31, dataChar1
C10  .dstruct ModChar_t, $32, dataChar2
C11  .dstruct ModChar_t, $33, dataChar3
C12  .dstruct ModChar_t, $34, dataChar4
C13  .dstruct ModChar_t, $35, dataChar5
C14  .dstruct ModChar_t, $36, dataChar6
C15  .dstruct ModChar_t, $37, dataChar7
C16  .dstruct ModChar_t, $38, dataChar8
C17  .dstruct ModChar_t, $39, dataChar9



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

OBSTACLE
    .byte $0
    .byte %00011100
    .byte %00100010
    .byte %01001001
    .byte %01011101
    .byte %01001001
    .byte %01001001
    .byte %01111111

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
    .byte %00011110
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