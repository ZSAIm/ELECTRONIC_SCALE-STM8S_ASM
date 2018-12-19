stm8/
    
    #include "ADC.inc"
    
    
    EXTERN DispADC.W
    EXTERN DispMass.W
    EXTERN MassHex2DecChar.W
    
    INTEL
    segment 'rom'
    
;***********************************************************
;name   : ADC_Init()
;fun    :
;params :   
;           IN  : 
;           OUT : 
;***********************************************************
.ADC_Init.W
    push CC
    push A
    ; PD6 = PD_SCK  => OUTPUT
    ;
    ;bset ADC_SCK
    bset ADC_SCK
    bset PD_DDR, #6
    bset PD_CR1, #6 ; open drain for debug
    bset PD_CR2, #6

    ; PD6 = DOUT
    bres PD_DDR, #7
    bres PD_CR2, #7
    bres PD_CR1, #7
    
    ; PD0 = DRDY => INPUT interrupt : falling and low
    bres PD_DDR, #0
    bres PD_CR1, #0
    
    ; PF4 = DIN => OUTPUT 
    bset ADC_DIN
    bset PF_DDR, #4
    bset PF_CR1, #4 ; open drain for debug
    bset PF_CR2, #4
    
    sim
    ld A, EXTI_CR1
    and A, #00111111B
    ;or A, #10000000B
    ;and A, #10111111B
    ld EXTI_CR1, A
    
    
    ; init ADC_NEXT_PTR
    clr {ADC_NEXT_PTR+0}
    clr {ADC_NEXT_PTR+1}

    ;clr {ADC_MIN_PTR+0}
    ;mov {ADC_MIN_PTR+1}, #9
   
    ;clr {ADC_MAX_PTR+0}
    ;mov {ADC_MAX_PTR+1}, #6
    
    
    ld A, ITC_SPR2
    and A, #11001111B
    ld ITC_SPR2, A
    
    
    bset PD_CR2, #0
    
    
    
    bset ADC_SCK
    bset ADC_DOUT
    bset ADC_DIN
    bset ADC_DRDY
    
    bset PD_ODR, #0
    bset PD_ODR, #6
    
    
    
    call ADC_Config
    
    rim
    
    
    

    
    
    
    pop A
    pop CC
    ret

;***********************************************************
;name   : ADC_Config()
;fun    :
;params :   
;           IN  : 
;           OUT : 
;***********************************************************
.ADC_Config.W
    push CC
    push A
    ; reset TM7705
    
    call ADC_Reset
    ; activate write mode
    ;ld A, #00H
    ;call ADC_SerData

    ; 
    
    ; activate test register
    ;ld A, #40H
    ;call ADC_WriData
    
    ;ld A, #01H
    ;call ADC_WriData
    
    ; activate clock register

    ld A, #20H
    call ADC_WriData
    call ADC_Delay
    ld A, #8CH
    call ADC_WriData
    call ADC_Delay
    

    
    
    ; activate settings register
    
    ld A, #10H
    call ADC_WriData
    call ADC_Delay
    ld A, #46H
    call ADC_WriData
    call ADC_Delay
    

    call ADC_Delay
    call ADC_Delay
    call ADC_Delay
    call ADC_Delay
    call ADC_Delay
    call ADC_Delay
    call ADC_Delay
    
    pop A
    pop CC
    ret


;***********************************************************
;name   : ADC_Reset()
;fun    :
;params :   
;           IN  : 
;           OUT : 
;***********************************************************
.ADC_Reset.W
    push CC
    push A
    
    ld A, #48
adc_reset_loop:
    bset ADC_DIN
    call ADC_Delay
    bres ADC_SCK
    call ADC_Delay
    bset ADC_SCK
    
    dec A
    jrne adc_reset_loop
    ;call ADC_WriData
    ;call ADC_WriData
    ;call ADC_WriData
    ;call ADC_WriData
    ;call ADC_WriData
    ;call ADC_WriData
    ;call ADC_WriData
    ;call ADC_WriData
    ;call ADC_WriData
    
    pop A
    pop CC
    ret


;***********************************************************
;name   : ADC_ReadData()
;fun    :
;params :   
;           IN  : 
;           OUT : A
;***********************************************************
.ADC_ReadData.W
    push CC
    ;push A
    pushw X
    ;bres ADC_SCK  
    ;call ADC_Delay
    ;call ADC_Delay

    clr A
    ldw X, #8
read_data_start:
    call ADC_Delay
    bres ADC_SCK   
    call ADC_Delay
    
    bset ADC_SCK   

    call ADC_Delay
    btjt ADC_DOUT,read_data_get_carry
    ; C <= Tested bit
read_data_get_carry:      
    rlc A
    

    decw X
    jrne read_data_start
    
    
    
    popw X
    ;pop A
    pop CC
    ret


;***********************************************************
;name   : ADC_Cal_Handler
;from   : PD0 = falling edge and low level
;go     : handle adc serial receiving
;params :
;           IN  : NULL
;           OUT : NULL
;***********************************************************
.ADC_Cal_Handler.l
    INTERRUPT ADC_Cal_Handler
    ;push CC
    ;bres PD_CR2, #6
    ; inverter
    btjt ADC_DRDY,cal_end_jp
    jra cal_start
cal_end_jp:
    jp cal_end
    
cal_start:
    ;LCD_SCmd LCD_CMD_FOSC_OFF
    ;sim
    call ADC_Delay
    call ADC_Recv_Sv

    call ADC_Moving_Avg

    call ADC_Convert_Mass
    
    inc ADC_COUNTER
    ld A, ADC_COUNTER
    cp A, #3
    jreq upgrate_data
    jp show_menu_end
upgrate_data:
    mov ADC_COUNTER, #0
    PrintStr #0,#0,#STR_MASS
    
    call Cal_Money
    
    
    ld A, KEY_ARRAY_MENU
    cp A, #1
    jreq show_menu_1
    cp A, #2
    jreq show_menu_2
    jp show_menu_3
show_menu_2:
    PrintChar #13, #0, #CHAR_I
    PrintChar #14, #0, #CHAR_II_R
    PrintChar #15, #0, #CHAR_III
    
    PrintStr #0, #1, #STR_MAX_MASS
    jp show_menu_end
show_menu_1:
    PrintChar #13, #0, #CHAR_I_R
    PrintChar #14, #0, #CHAR_II
    PrintChar #15, #0, #CHAR_III
    PrintStr #0, #1, #STR_PRICE
    PrintStr #8, #1, #STR_MONEY
    jra show_menu_end
show_menu_3:
    PrintChar #13, #0, #CHAR_I
    PrintChar #14, #0, #CHAR_II
    PrintChar #15, #0, #CHAR_III_R
    PrintStr #0,#1,#STR_THRESHOLD
    
    
show_menu_end:

    ;call KeyArray_Display
    
    ;LCD_SCmd LCD_CMD_FOSC_ON
    call TypingCursorFlash
    ;rim
    ;pop CC

cal_end:
    ;bset PD_CR2, #6  

    iret

;***********************************************************
;name   : ADC_WriData
;fun    : 
;params :
;           IN  : A : written byte
;           OUT : NULL
;***********************************************************
.ADC_WriData.W
    push CC
    pushw X
    
    ;bset ADC_SCK
    
    ldw X, #8
adc_serial_bit_loop:
    call ADC_Delay
    bres ADC_SCK
    call ADC_Delay
    call ADC_Delay
    sll A
    jrc adc_serial_one
    bres ADC_DIN
    jra adc_serial_lock
adc_serial_one:
    bset ADC_DIN
    
adc_serial_lock:
    call ADC_Delay
    bset ADC_SCK
    
    decw X
    jrne adc_serial_bit_loop
    
    popw X
    pop CC
    ret


;***********************************************************
;name   : ADC_Recv_Sv
;fun    : serial receive and save ADC 16bits,  
;         3rd byte is 0x00
;params :
;           IN  : ADC_NEXT_PTR
;           OUT : ADC_SUM, ADC_STORE
;***********************************************************
.ADC_Recv_Sv.W
    push A
    pushw X
    pushw Y
    
    ld A, #38H
    call ADC_WriData
    call ADC_Delay
    call ADC_Delay
    
    ;call ADC_ReadData
    ;call ADC_ReadData
    ; from 3byte adc to 2byte adc, make the 3rd byte 0x00 
    ; default , so inc ADC_NEXT_PTR before saving adc data
    ldw X, ADC_NEXT_PTR
    incw X
    ldw ADC_NEXT_PTR, X
    
    ;popw Y
    ;popw X
    ;pop A
    ;ret
    
    
    ;;;
recv_start:

    ldw Y, #2       ;3 bytes
recv_new_byte:
    clr A
    ldw X, #8
recv_bit_start:
    bres ADC_SCK
    call ADC_Delay
    call ADC_Delay
    call ADC_Delay
    bset ADC_SCK   

    call ADC_Delay

    btjt ADC_DOUT,go_get_carry
    ; C <= Tested bit
go_get_carry:      
    rlc A
    
    call ADC_Delay
    call ADC_Delay
    call ADC_Delay
    ;bres ADC_SCK    
    decw X
    jrne recv_bit_start
    
    ; store 10bits to (ADC_NEXT_PTR->)
    ldw X, ADC_NEXT_PTR
    ld (ADC_STORE,X), A
    incw X
    ldw ADC_NEXT_PTR, X
    
    decw Y
    jrne recv_new_byte
    
    ; ------ end recv
    ; 25 ADC_SCK: 128 gains , channel A
    ; 25th SCK
    ;bset ADC_SCK

    ;call ADC_Delay

    ;bres ADC_SCK
    
    ;;; (ADC_NEXT_PTR < 10*3) or rotate back to 0
    
    ldw X, ADC_NEXT_PTR
    cpw X, #{ADC_MOVING_BYTE*ADC_MOVING_NUM}
    jrne recv_end
    ;;; clear ADC_NEXT_PTR
    clrw X
recv_end:
    ldw ADC_NEXT_PTR, X
    
    
    popw Y
    popw X
    pop A
    ret
    

    
    end
    
    
    
    