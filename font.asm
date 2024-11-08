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

NUM_CHANGED_CHARS = 1
CHANGED_CHARS
C1   .dstruct ModChar_t, APPLE_CHAR, APPLE


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

APPLE_CHAR = 195
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