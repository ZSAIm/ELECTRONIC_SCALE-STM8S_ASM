
    
    
    #IFDEF __MACRO_FUNCTION_
    
    #ELSE
    #define __MACRO_FUNCTION_ 1
    
    #include "LCD.inc"
    
    #include "GlobalVar.inc"
    #include "Common.inc"
    
;***********************************************************
;name   :(void)
;          PrintChar (cor_x: x,
;                     cor_y: y,
;                     _char: char)
;fun    : print char to LCD
;***********************************************************
PrintChar MACRO cor_x,cor_y,_char
    mov LCD_VAR0, cor_x
    mov LCD_VAR1, cor_y
    mov LCD_VAR2, _char
    call LCD_WriChar
    MEND

;***********************************************************
;name   :(void)
;          LCD_ClearLine (line: _line)
;fun    : print char to LCD
;***********************************************************
LCD_ClearLine MACRO _line
    PrintStr #0, #{_line+1}, #EMPTY_LINE
    MEND


;***********************************************************
;name   :(void)
;          LCD_Scmd (_cmd: cmd)
;fun    : print char to LCD
;***********************************************************
LCD_SCmd MACRO _cmd
    ld A, _cmd
    call LCD_WriCMD
    MEND
    
;***********************************************************
;name   :(void)
;          LCD_SetCursor (_cmd: cmd)
;fun    : print char to LCD
;***********************************************************
LCD_SetCursor_Macro MACRO _x,_y
    mov LCD_VAR0, _x
    mov LCD_VAR1, _y
    call LCD_SetCursor
    MEND    

    
;***********************************************************
;name   :(void)
;          LCD_Clear ()
;fun    : clear LCD
;***********************************************************
LCD_Clear MACRO 
    ld A, #01H
    call LCD_WriCMD
    MEND

;***********************************************************
;name   :(void)
;          PrintStr (start_x: start_x,
;                    start_y: start_y,
;                    str_ptr.W: str_ptr)
;fun    : print char to LCD,
;         string end with 0
;***********************************************************
PrintStr MACRO start_x,start_y,str_ptr
    pushw X
    mov LCD_VAR0, start_x
    mov LCD_VAR1, start_y
    ldw X, str_ptr
    call LCD_WriString
    popw X
    MEND

;***********************************************************
;name   : (Quotient: X, Remainder: Y)
;           ADC_Convert (X: _divisor)
;fun    : divide from [NET_ADC2:NET_ADC1:NET_ADC0]
;***********************************************************
ADC_Convert MACRO _divisor
    ldw X, _divisor
    call MassDivider
    MEND





    
    #ENDIF
    
    
    
    
    
    
    
    
    