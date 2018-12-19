stm8/
    
    #include "stm8s105k4.inc"
    #include "LCD.inc"
    #include "Common.inc"
    #include "ADC.inc"
    #include "Key.inc"
    ;#include "Timer.inc"
    EXTERN Beeper_Init.W
    INTEL
    segment 'rom'

;***********************************************************
;name   : Main_Init()
;fun    : initialization
;params : 
;         IN  : NULL
;         OUT : NULL
;***********************************************************
.Main_Init.W

    ;Clock
    call Clock_Init

    ;LCD
    call LCD_Init
    
    call LCD_InitCustom
    ;Key
    call KeyZero_Init

    call KeyArray_Init
    
    ;call Timer3_KeyUp_Init
    ;ADC
    call ADC_Init

    call Beeper_Init

    ret

;***********************************************************
;name   : StartUp_Init()
;fun    : 
;params : 
;         IN  : NULL
;         OUT : NULL
;***********************************************************
.StartUp_Init.W
    push CC
    push A
    
    sim
    mov ZERO_ADC3, ADC_AVG3
    mov ZERO_ADC2, ADC_AVG2
    mov ZERO_ADC1, ADC_AVG1
    mov ZERO_ADC0, ADC_AVG0
    
    mov CHAR_MAX_MASS7, #'0'
    mov CHAR_MAX_MASS6, #'0'
    mov CHAR_MAX_MASS5, #'0'
    mov CHAR_MAX_MASS4, #'0'
    mov CHAR_MAX_MASS3, #'0'
    mov CHAR_MAX_MASS2, #'.'
    mov CHAR_MAX_MASS1, #'0'
    mov CHAR_MAX_MASS0, #'g'
    
    mov ADC_MAX_QUOTIENT_S1, #0
    mov ADC_MAX_QUOTIENT_S0, #0
    
    mov ADC_MAX_REMAINDER_S1, #0
    mov ADC_MAX_REMAINDER_S0, #0
    
    rim
    
    pop A
    pop CC
    ret


;***********************************************************
;name   : Clock_Init()
;fun    : init clock, => fHSI/1
;params : 
;         IN  : NULL
;         OUT : NULL
;***********************************************************
.Clock_Init.W
    push CC
    push A
    
    ; => fHSI / 1
    ld A, CLK_CKDIVR
    and A, #11100111B
    ld CLK_CKDIVR, A

    pop A
    pop CC
    ret





    end
    
    
    
    
    