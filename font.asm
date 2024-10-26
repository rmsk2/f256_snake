font .namespace 

init
    #load16BitImmediate APPLE, FONT_PTR1
    lda #255
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
.endnamespace