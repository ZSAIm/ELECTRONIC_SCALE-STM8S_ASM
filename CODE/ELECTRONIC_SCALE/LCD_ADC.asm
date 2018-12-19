stm8/
    #include "LCD.inc"
    #include "ADC.inc"
    #include "MacroFunction.inc"
    
    
    INTEL
    segment 'rom'
HEX_CODE.W dc.b "0123456789ABCDEF"


;***********************************************************
;name   : DispADC()
;fun    : 
;params :   
;         IN  : NET_ADC
;         OUT : NULL
;***********************************************************
.DispADC.W
    push CC
    push A
    pushw X
    pushw Y
    
    ;push CC
    ;sim
    mov NET_BUF3, NET_ADC3
    mov NET_BUF2, NET_ADC2
    mov NET_BUF1, NET_ADC1
    mov NET_BUF0, NET_ADC0
    ;rim
    ;pop CC

    clrw X
    ld A, NET_BUF3
    and A, #0F0H
    swap A
    ld XL, A
    ld A, (HEX_CODE,X)
;    ld LCD_VAR2, A
    PrintChar #0,#0,LCD_VAR2
    
    
    ld A, NET_BUF3
    and A, #0FH
    ld XL, A
    ld A, (HEX_CODE,X)
    ld LCD_VAR2, A
    PrintChar #1,#0,LCD_VAR2
    ;;;;;;
    
    

    ld A, NET_BUF2
    and A, #0F0H
    swap A
    ld XL, A
    ld A, (HEX_CODE,X)
    ld LCD_VAR2, A
    PrintChar #2,#0,LCD_VAR2
    
    ld A, NET_BUF2
    and A, #0FH
    ld XL, A
    ld A, (HEX_CODE,X)
    ld LCD_VAR2, A
    PrintChar #3,#0,LCD_VAR2
    ;;;;;;
    
    

    ld A, NET_BUF1
    and A, #0F0H
    swap A
    ld XL, A
    ld A, (HEX_CODE,X)
    ld LCD_VAR2, A
    PrintChar #4,#0,LCD_VAR2
    
    ld A, NET_BUF1
    and A, #0FH
    ld XL, A
    ld A, (HEX_CODE,X)
    ld LCD_VAR2, A
    PrintChar #5,#0,LCD_VAR2
    ;;;;;;
    
    

    ld A, NET_BUF0
    and A, #0F0H
    swap A
    ld XL, A
    ld A, (HEX_CODE,X)
    ld LCD_VAR2, A
    PrintChar #6,#0,LCD_VAR2
    
    ld A, NET_BUF0
    and A, #0FH
    ld XL, A
    ld A, (HEX_CODE,X)
    ld LCD_VAR2, A
    PrintChar #7,#0,LCD_VAR2
    ;;;;;;
    
    


    ; high 16bits
    ;ldw X, NET_ADC
    ;ldw Y, #1000 
    ;div X, Y
    ;ldw NET_ADC, X
    ; low 16bits
    
    popw Y
    popw X
    pop A
    pop CC
    ret

    
;***********************************************************
;name   : DispMass()
;fun    : 
;params :   
;         IN  : NET_ADC
;         OUT : NULL
;***********************************************************
.DispMass.W
    push CC
    
    

    pop cc
    ret






    end
    
    
    
    
    