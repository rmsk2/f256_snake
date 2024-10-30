snes .namespace

PAD_REG = $D880
PAD1_REG1 = $D884
PAD1_REG2 = $D885
SET_NES_EN =   %00000001
SET_MODE =     %00000100
SET_NES_TRIG = %10000000
CLR_NES_TRIG = %01111111
TEST_DONE =    %01000000
DEBOUNCE_MAX = 64

REG1_VAL .byte 0
REG2_VAL .byte 0

init
    ; 1. Set NES_EN of NES_CTRL to enable the NES/SNES support (see table 12.2) and set or clear
    ;    MODE, to choose between NES mode or SNES mode.
    lda #SET_NES_EN | SET_MODE
    sta PAD_REG
    rts

querySnesPad
    ; 2. Set NES_TRIG of NES_CTRL to sample the buttons and transfer the data to the registers.
    lda PAD_REG
    ora #SET_NES_TRIG
    sta PAD_REG

    ; 3. Read NES_STAT and wait until the DONE bit is set
_sample
    ; now wait for DONE
    lda PAD_REG
    and #TEST_DONE
    beq _sample

    ; 4. Check the appropriate NES or SNES control registers (see table 12.3)    
    lda PAD1_REG1
    sta REG1_VAL
    lda PAD1_REG2
    sta REG2_VAL

    ; 5. Clear NES_TRIG
    lda PAD_REG
    and #CLR_NES_TRIG
    sta PAD_REG

    lda REG1_VAL

    rts


SNES_NEUTRAL_COUNT .byte 0
SNES_VALUE .byte 0

debounceSnesPad    
    jsr snes.querySnesPad                                       ; query button state of SNES pad
    sta SNES_VALUE                                              ; save current button state
    cmp #$FF                                                    ; are we in neutral?
    beq _isNeutral                                              ; yes
    lda SNES_NEUTRAL_COUNT                                      ; no => Check counter for neutral position
    beq _wasNeutral                                             ; We have seen seen DEBOUNCE_MAX consecutive $FFs before seeing this non neutral value
    lda #DEBOUNCE_MAX                                           ; We have not seen DEBOUNCE_MAX consecutive $FFs before this non neutral value
    sta SNES_NEUTRAL_COUNT                                      ;     =>reset counter for $FF
    lda #$FF                                                    ; return $FF
    rts
_wasNeutral    
    lda #DEBOUNCE_MAX                                           ; reset counter for neutral position
    sta SNES_NEUTRAL_COUNT                                      ;
    lda SNES_VALUE                                              ; return non neutral value
    rts
_isNeutral
    lda SNES_NEUTRAL_COUNT                                      ; have we reached the desired number of consecutive reads in neutral position?
    beq _neutralENough                                          ; yes => we are done and return $FF
    dec SNES_NEUTRAL_COUNT                                      ; no => decrement count for neutral position
_neutralENough
    lda #$FF                                                    ; return $FF
    rts


.endnamespace