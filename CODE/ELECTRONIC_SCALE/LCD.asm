stm8/

    
    #include "LCD.inc"
    
    segment 'rom'
    
    INTEL

.EMPTY_LINE.W 
    dc.b "                ", 0 ; 16 space
;***********************************************************
;name   : LCD_Init()
;fun    : init LCD after reset
;params : 
;         IN  : NULL
;         OUT : NULL
;***********************************************************
.LCD_Init.w
    push CC
    push A
    ;   --------    init gpio
    ; PB3, PB4, PB5, PB1, PD5, PD3
    ; ---------------------
    ;; PB3 - LCD(E)
    ;bres LCD_E
    bset LCD_E
    bset PB_CR1, #3
    bset PB_DDR, #3
    
    ;; PB5 - LCD(RS)
    bres LCD_RS
    bset PB_CR1, #5
    bset PB_DDR, #5
    
    ;; PB4 - LCD(RW)
    bres LCD_RW
    bset PB_CR1, #4
    bset PB_DDR, #4
    
    ;; PD3 - 74HC595(RCK)
    ;bres LCD_RCK
    bset LCD_RCK
    bset PD_DDR, #3
    bset PD_CR1, #3
    bset PD_CR2, #3
    
    ;; PD2 - 74HC595(SER)
    ;bres LCD_SER
    bset LCD_SER
    bset PD_DDR, #2
    bset PD_CR1, #2
    bset PD_CR2, #2
    
    ;; PD5 - 74HC595(SRCLK)
    ;bres LCD_SRCLK
    bset LCD_SRCLK
    bset PD_DDR, #5
    bset PD_CR1, #5
    bset PD_CR2, #5

    
    ;; init lcd
    LCD_SCmd #38H
    call LCD_Delay
    call LCD_Delay
    LCD_SCmd #38H
    LCD_SCmd #08H
    LCD_SCmd #01H
    LCD_SCmd #06H
    LCD_SCmd #0CH



   ;PrintChar #0, #0, #'A'
    

    pop A
    pop CC
    ret







;***********************************************************
;name   : LCD_InitCustom(VARB0:x, VARB1:y, VARB2:char)
;fun    : 
;params :   
;         IN  : LCD_VAR0 <= cor x (<=15)
;               LCD_VAR1 <= cor y (<=1)
;               LCD_VAR2 <= char
;         OUT : NULL
;***********************************************************

DC_CHAR_I      dc.b 000H,000H,000H,004H,004H,000H,000H,000H
DC_CONVERT_I   dc.b 0FFH,0FFH,0FFH,0FBH,0FBH,0FFH,0FFH,0FFH
DC_CHAR_II     dc.b 000H,000H,004H,000H,000H,004H,000H,000H
DC_CONVERT_II  dc.b 0FFH,0FFH,0FBH,0FFH,0FFH,0FBH,0FFH,0FFH
DC_CHAR_III    dc.b 000H,000H,000H,004H,00AH,000H,000H,000H
DC_CONVERT_III dc.b 0FFH,0FFH,0FFH,0FBH,0F5H,0FFH,0FFH,0FFH

DC_CHAR_LEFT   dc.b 008H,00CH,00EH,00FH,00EH,00CH,008H,000H
DC_CHAR_RIGHT  dc.b 002H,006H,00EH,01EH,00EH,006H,002H,000H

.LCD_InitCustom.W
    push CC
    push A
    pushw X

    ; --------------- 00: , 
    ld A, #40H
    call LCD_WriCMD
    clrw X
    ;ldw X, #0
init_custom_data_loop_0:
    ld A, (DC_CHAR_I,X)
    call LCD_WriData
    incw X
    cpw X, #8
    jrne init_custom_data_loop_0
    
    ; --------------- 01
    ld A, #48H
    call LCD_WriCMD
    clrw X
    ;ldw X, #0
init_custom_data_loop_1:
    ld A, (DC_CONVERT_I,X)
    call LCD_WriData
    incw X
    cpw X, #8
    jrne init_custom_data_loop_1
    
    
    ; --------------- 02: , 
    ld A, #50H
    call LCD_WriCMD
    clrw X
    ;ldw X, #0
init_custom_data_loop_2:
    ld A, (DC_CHAR_II,X)
    call LCD_WriData
    incw X
    cpw X, #8
    jrne init_custom_data_loop_2
    
    ; --------------- 03
    ld A, #58H
    call LCD_WriCMD
    clrw X
    ;ldw X, #0
init_custom_data_loop_3:
    ld A, (DC_CONVERT_II,X)
    call LCD_WriData
    incw X
    cpw X, #8
    jrne init_custom_data_loop_3
    
    
    ; --------------- 04: , 
    ld A, #60H
    call LCD_WriCMD
    clrw X
    ;ldw X, #0
init_custom_data_loop_4:
    ld A, (DC_CHAR_III,X)
    call LCD_WriData
    incw X
    cpw X, #8
    jrne init_custom_data_loop_4
    
    ; --------------- 05
    ld A, #68H
    call LCD_WriCMD
    clrw X
    ;ldw X, #0
init_custom_data_loop_5:
    ld A, (DC_CONVERT_III,X)
    call LCD_WriData
    incw X
    cpw X, #8
    jrne init_custom_data_loop_5
    
    ; --------------- 06
    ld A, #70H
    call LCD_WriCMD
    clrw X
    ;ldw X, #0
init_custom_data_loop_6:
    ld A, (DC_CHAR_LEFT,X)
    call LCD_WriData
    incw X
    cpw X, #8
    jrne init_custom_data_loop_6
    
    ; --------------- 07
    ld A, #78H
    call LCD_WriCMD
    clrw X
    ;ldw X, #0
init_custom_data_loop_7:
    ld A, (DC_CHAR_RIGHT,X)
    call LCD_WriData
    incw X
    cpw X, #8
    jrne init_custom_data_loop_7
    
    popw X
    pop A
    pop CC
    ret


;***********************************************************
;name   : LCD_WriChar(LCD_VAR0:x, LCD_VAR1:y, LCD_VAR2:char)
;fun    : write char to LCD
;params :   
;         IN  : LCD_VAR0 <= cor x (<=15)
;               LCD_VAR1 <= cor y (<=1)
;               LCD_VAR2 <= char
;         OUT : NULL
;***********************************************************
.LCD_WriChar.W
    push CC
    push A
    
    ld A, LCD_VAR0
    or A, #80H
    btjf LCD_VAR1, #0, first_line
    or A, #40H
first_line:
    ; A <= LCD_DDRAM address
    call LCD_WriCMD
    
    
    ; write char
    ld A, LCD_VAR2
    call LCD_WriData
    
    pop A
    pop CC
    ret

;***********************************************************
;name   : LCD_WriString(LCD_VAR0:start_x, 
;                       LCD_VAR1:start_y, 
;                       X       :str_ptr.W)
;fun    : write string to LCD
;params :   
;         IN  : LCD_VAR0 <= start_x: cor x (<=15)
;               LCD_VAR1 <= start_y y (<=1)
;               X        <= str_ptr(WORD)
;         OUT : NULL
;***********************************************************
.LCD_WriString.W
    push CC
    push A
    
str_set_line:
    ld A, LCD_VAR0
    cp A, #16
    jrc str_cur_line
    ; set new line - [x=0, y=y+1]
    clr LCD_VAR0
    inc LCD_VAR1
str_cur_line:
    ld A, LCD_VAR0
    or A, #80H
    btjf LCD_VAR1, #0, str_first_line
    or A, #40H
str_first_line:
    ; A <= LCD_DDRAM address
    call LCD_WriCMD
    
cur_char:
    ld A, LCD_VAR0
    cp A, #16
    jreq str_set_line
    ; write char
    ld A, (X)
    jreq str_end
    call LCD_WriData
    inc LCD_VAR0           ; x++
    incw X              ; ptr++
    jra cur_char
    
str_end:
    ;inc VARB0
    
    pop A
    pop CC
    ret


;***********************************************************
;name   : LCD_SetCursor(A: data)
;fun    : write command to LCD
;params :   
;         IN  : LCD_VAR0 <= start_x: cor x (<=15)
;               LCD_VAR1 <= start_y y (<=1)
;         OUT : NULL
;***********************************************************
.LCD_SetCursor.w
    push CC

    push A
    ld A, LCD_VAR0
    or A, #80H
    ldw X, LCD_VAR1
    
    btjf LCD_VAR1, #0, setcursor_loop
    or A, #40H
setcursor_loop:
    call LCD_WriCMD
    pop A

    pop CC
    
    ret


;***********************************************************
;name   : LCD_WriCMD(A: data)
;fun    : write command to LCD
;params :   
;         IN  : A <= CMD DATA
;         OUT : NULL
;***********************************************************
.LCD_WriCMD.w
    push CC

    call LCD_SerData
    
    bres LCD_RS
    bres LCD_RW
    
    ;bset LCD_E
    bres LCD_E
    call LCD_Delay
    ;call LCD_Delay
    ;bres LCD_E
    bset LCD_E
    

    pop CC
    
    ret
    
;***********************************************************
;name   : LCD_WriData(A: data)
;fun    : write data to LCD
;params :   
;         IN  : A <= DATA
;         OUT : NULL
;***********************************************************
.LCD_WriData.w
    push CC

    ; serial 8-bits data
    call LCD_SerData
    
    bset LCD_RS
    bres LCD_RW
    


    ;bset LCD_E
    bres LCD_E
    call LCD_Delay
    ;call LCD_Delay
    ;bres LCD_E
    bset LCD_E

    pop CC
    
    ret




;***********************************************************
;name   : LCD_SerData(A: data)
;fun    : serial 8-bits data
;params :   
;         IN  : A <= 8bits DATA
;         OUT : NULL
;***********************************************************
.LCD_SerData.W
    pushw X
    
    ldw X, #8
serial_data:
    sll A
    jrnc data_zero
    bset LCD_SER
    jra data_one
data_zero:
    bres LCD_SER
data_one:
    ;bset LCD_SRCLK
    bres LCD_SRCLK
    call LCD_Delay
    call LCD_Delay
    ;bres LCD_SRCLK
    bset LCD_SRCLK
    

    
    decw X
    jrne serial_data
    ;bset LCD_RCK
    call LCD_Delay
    bres LCD_RCK    ; inverter
    call LCD_Delay
    ;bres LCD_RCK
    call LCD_Delay
    bset LCD_RCK    ; inverter
    call LCD_Delay
    
    popw X
    ret
    


    end
    