stm8/
    
    #include "Beeper.inc"
    
    segment 'rom'
    
    INTEL

.Beeper_Init.W
    push CC
    push A
    pushw X
    
    ldw X, #10000
    ldw ADC_THRESHOLD_QUOTIENT, X
    mov KEYBOARD_THRESHOLD_BUF_S4, #1
    mov KEYBOARD_THRESHOLD_BUF_S3, #0
    mov KEYBOARD_THRESHOLD_BUF_S2, #0
    mov KEYBOARD_THRESHOLD_BUF_S1, #0
    mov KEYBOARD_THRESHOLD_BUF_S0, #0
    
    
    ;mov CHAR_THRESHOLD5, #'1'
    ;mov CHAR_THRESHOLD4, #'0'
    ;mov CHAR_THRESHOLD3, #'0'
    ;mov CHAR_THRESHOLD2, #'0'
    ;mov CHAR_THRESHOLD1, #'0'
    ;mov CHAR_THRESHOLD0, #'0'
    
    ; PD4 : output
    
    bset PD_DDR, #4
    bset PD_CR1, #4
    
    
    bset CLK_ICKR, #3
wait_LSI_ready:
    btjf CLK_ICKR, #4, wait_LSI_ready
    
    ; measure LSI clock frequency
    ;bset AWU_CSR, #0
    ;ld A, #3EH
    ;ld AWU_APR, A

    
    ld A, #05H
    ld BEEP_CSR, A
    
    
    ;bset BEEP_CSR, #5
    
    
    
    
    popw X
    pop A
    pop CC
    ret

;***********************************************************
;name   : ThresholdCheck()
;fun    : 
;params : 
;         IN  : X   : quotient  (mass)
;               Y   : remainder (mass)
;         OUT : NULL
;***********************************************************
.ThresholdCheck.W
    push CC
    push A
    pushw X
    pushw Y
    
    
    btjt NET_BUF2,#7,no_exceed_threshold
    ; ----------
    ; HIGH STACK
    ;+4 XL - QUOTIENT
    ;+3 XH - QUOTIENT
    ;+2 YL - REMAINDER
    ;+1 YH - REMAINDER
    ; LOW  STACK
    ; ----------
    
    ldw X, ADC_THRESHOLD_QUOTIENT
    cpw X, (3,SP)
    jrnc no_exceed_threshold

exceed_threshold:
    btjt BEEP_CSR, #5, threshold_check_exit
    bset BEEP_CSR, #5
    
    jra threshold_check_exit
no_exceed_threshold:
    jreq exceed_threshold
    bres BEEP_CSR, #5
threshold_check_exit:

    popw Y
    popw X
    pop A
    pop CC
    ret 










    end
    
    
    
    