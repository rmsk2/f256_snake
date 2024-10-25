pushImmediate .macro x, y, flags 
    lda #\x
    sta data.WORK_ENTRY.xPos
    lda #\y
    sta data.WORK_ENTRY.yPos
    #load16BitImmediate \flags, data.WORK_ENTRY.flags
    jsr data.pushFront
.endmacro

entry_t .struct 
    xPos  .byte 0
    yPos  .byte 0 
    flags .word 0
.endstruct

data .namespace 

MAX_ENTRIES = 4096
QUEUE .fill MAX_ENTRIES * size(entry_t)
MASK = %0000111111111111

state_t .struct 
    front .word 0
    back  .word 0
    tempX .byte 0
    tempY .byte 0
    temp  .byte 0
    help  .word 0
    len   .word 0
.endstruct

STATE .dstruct state_t
WORK_ENTRY .dstruct entry_t


calcMemFront
    #move16Bit STATE.front, STATE.help
    bra calcMemPos
calcMemBack
    #move16Bit STATE.back, STATE.help
calcMemPos
    #double16Bit STATE.help
    #double16Bit STATE.help
    #add16BitImmediate QUEUE, STATE.help
    #move16Bit STATE.help, DATA_PTR1
    rts


init
    #load16BitImmediate 0, STATE.front
    #load16BitImmediate 0, STATE.back
    #load16BitImmediate 0, STATE.len

    #pushImmediate SCREEN_X/2, SCREEN_Y/2, 0
    #pushImmediate SCREEN_X/2 + 1, SCREEN_Y/2, 0
    #pushImmediate SCREEN_X/2 + 2, SCREEN_Y/2, 0
    #pushImmediate SCREEN_X/2 + 3, SCREEN_Y/2, 0
    #pushImmediate SCREEN_X/2 + 4, SCREEN_Y/2, 0

    #load16BitImmediate 1, STATE.back

    rts


writeWorkEntry
    lda WORK_ENTRY.xPos
    ldy #entry_t.xPos    
    sta (DATA_PTR1), y
    
    lda WORK_ENTRY.yPos
    ldy #entry_t.yPos
    sta (DATA_PTR1), y
    
    ldy #entry_t.flags
    lda WORK_ENTRY, y
    sta (DATA_PTR1), y
    iny  
    lda WORK_ENTRY, y
    sta (DATA_PTR1), y
    rts


readWorkEntry
    ldy #entry_t.xPos
    lda (DATA_PTR1), Y
    sta WORK_ENTRY.xPos

    ldy #entry_t.yPos
    lda (DATA_PTR1), Y
    sta WORK_ENTRY.yPos

    ldy #entry_t.flags
    lda (DATA_PTR1), y
    sta WORK_ENTRY, y
    iny
    lda (DATA_PTR1), y
    sta WORK_ENTRY, y
    rts


; Push WORK_ENTRY to front of queue
pushFront
    #inc16Bit STATE.front
    #and16BitImmediate MASK, STATE.front
    #inc16Bit STATE.len
    jsr calcMemFront
    jsr writeWorkEntry    
    rts


; Pop last positon in queue. Return it in WORK_ENTRY
popBack
    jsr calcMemBack
    jsr readWorkEntry
    #inc16Bit STATE.back
    #and16BitImmediate MASK, STATE.back
    #dec16Bit STATE.len
    rts


.endnamespace