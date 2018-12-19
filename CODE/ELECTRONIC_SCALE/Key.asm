stm8/


    #include "stm8s105k4.inc"
    #include "MacroFunction.inc"
    #include "Key.inc"
    #include "LCD.inc"
    #include "GlobalVar.inc"
    #include "Common.inc"
    ;#include "Timer.inc"
    
    
    EXTERN KeyCalibrWizard_1.W
    INTEL
    segment 'rom'

;.KeyCalibrWizard_1.W STRING "***CALIBRATION**",0
;.KeyCalibrWizard_2.W STRING " push 10g weight",0
    
.KeyZero_Init.W
    push CC
    push A
    ; PB0 = Calibration Key
    ; --- INPUT: interrupt - falling edge
    
    bres PB_DDR, #0
    bset PB_CR1, #0

    sim
    ld A, EXTI_CR1
    or A, #00001000B
    and A, #11111011B
    ld EXTI_CR1, A
    
    
    ld A, ITC_SPR2
    and A, #11111100B
    ld ITC_SPR2, A
    
    
    bset PB_CR2, #0
    rim
    
    pop A
    pop CC
    ret


;***********************************************************
;name   : KEY_Zero_Handler()
;from   : PB0 = falling edge
;go     : calibrate ADC_Slope
;pins   :
;           IN  : NULL
;           OUT : NULL
;***********************************************************
.KeyZero_Handler.l
    INTERRUPT KeyZero_Handler
    
    ;call KeyDelay
    btjt KEY_ZERO,keyzero_handle_end
    ;LCD_Clear
    ;PrintStr #0,#0,#KeyCalibrWizard_1
    ;PrintStr #0,#1,#KeyCalibrWizard_2
    ;push CC
    ;sim
    mov ZERO_ADC3, ADC_AVG3
    mov ZERO_ADC2, ADC_AVG2
    mov ZERO_ADC1, ADC_AVG1
    mov ZERO_ADC0, ADC_AVG0
    ;pop CC

keyzero_handle_end:
    ;LCD_Clear
    
zero_wait_keyup:
    btjf KEY_ZERO, zero_wait_keyup
    
    iret



;***********************************************************
;name   : KeyArray_Init()
;from   : PE4: interrupt input ; PC1~4: row ; PC5~7 : col
;go     : 
;pins   :
;           IN  : NULL
;           OUT : NULL
;***********************************************************
.KeyArray_Init.W
    push CC
    push A
    
    
    ; PC4~7
    ; OUTPUT
    mov PC_ODR, #0
    
    ld A, PC_DDR
    or A, #11110000B
    ld PC_DDR, A
    
    ; open-drain output
    ld A, PC_CR1
    and A, #00001111B
    ld PC_CR1, A
    
    ; PC1~3
    ; INPUT: interrupt
    
    ld A, PC_DDR
    and A, #11110001B
    ld PC_DDR, A
    
    ; pull-up input
    ld A, PC_CR1
    or A, #11110000B
    ld PC_CR1, A
    
    ; disable input interrupt, 2mhz output
    mov PC_CR2, #0
    
    
    ; PE4 - input interrupt 
    bres PE_DDR, #5
    bres PE_CR1, #5

    sim
    ld A, EXTI_CR2
    or A, #00000010B
    and A, #11111110B
    ld EXTI_CR2, A
    
    
    ld A, ITC_SPR2
    and A, #00111111B
    ;or A, #01000000B
    ld ITC_SPR2, A
    
    
    bset PE_CR2, #5
    rim
    
    ; init menu 1
    mov KEY_ARRAY_MENU, #1
    
    pop A
    pop CC
    ret 


;***********************************************************
;name   : KeyArray_Handler()
;from   : PE5 = falling edge
;go     : 
;pins   :
;           IN  : NULL
;           OUT : NULL
;***********************************************************
.KeyArray_Handler.l
    INTERRUPT KeyArray_Handler
    
    
    ; check KEYDOWN_FLAG
    ld A, KEYDOWN_FLAG
    
    call KeyDelay
    call KeyDelay
    call KeyDelay
    call KeyDelay
    ; if KEYDOWN_FLAG == 0
    jrne keyarray_handle_end
    


keyarray_down_start:

    btjt KEY_ARRAY,keyarray_handle_end
    
    
    call KeyArray_Scan
    
wait_keyup:
    btjf KEY_ARRAY, wait_keyup
    ; enable time4 interrupt to check and wait for key up 
    ;bset CLK_PCKENR1, #6
    ;mov KEYDOWN_FLAG, #1
    ;bset TIM3_CR1, #0
    ;mov TIM3_CNTRH, #00H
    ;mov TIM3_CNTRL, #00H
    ;bset TIM3_IER, #0
    ;call Timer4_KeyUp_Init
    
    ;bres PE_CR2, #5
    
    
    
keyarray_handle_end:
    
    iret




;***********************************************************
;name   : KeyArray_Scan()
;from   : PE4: interrupt input ; 
;       : PC1~4: row - output
;       : PC5~7 : col - input
;go     : 
;pins   :
;           IN  : KEYBOARD_STATUS, KEYBOARD_S4~0
;                 KEYBOARD_STORE , KEYBOARD_PTR
;           OUT : KEYBOARD_STATUS, KEYBOARD_PTR
;                 KEYBOARD_S4~0
;       ----------
;       7   8   9
;       4   5   6
;       1   2   3
;       0   .   h
;       ----------
;   0xFE = '.'      0xFF = 'done'
;***********************************************************
.KeyArray_Scan.W
    push CC
    push A
    pushw X

    
   

keyarray_determine_col_start:
    ; determine col
    btjf KEY_COL1, keyarray_col1
    btjf KEY_COL2, keyarray_col2
    btjf KEY_COL3, keyarray_col3_jp
    
    jp keyarray_scan_exit

keyarray_col3_jp:
    jp keyarray_col3
    ; ------- column 1 --------
keyarray_col1:
    
col1_row1:
    bset KEY_ROW1
    call KeyDelay
    btjf KEY_COL1, col1_row2
    ld A, #7
    ;call 
    jp keyarray_num
col1_row2:
    bset KEY_ROW2
    call KeyDelay
    btjf KEY_COL1, col1_row3
    ld A, #4
    ;call
    jp keyarray_num
col1_row3:
    bset KEY_ROW3
    call KeyDelay
    btjf KEY_COL1, col1_row4
    ld A, #1
    ;call
    jp keyarray_num
col1_row4:
    bset KEY_ROW4
    call KeyDelay
    btjf KEY_COL1, keyarray_exit_jp
    ld A, #0
    ;call
    jp keyarray_num
    
; because of the limit of the addressing mode
keyarray_exit_jp:
    jp keyarray_scan_exit


    ; ------- column 2 --------
keyarray_col2:

col2_row1:
    bset KEY_ROW1
    call KeyDelay
    btjf KEY_COL2, col2_row2
    ld A, #8
    ;call 
    jra keyarray_num
col2_row2:
    bset KEY_ROW2
    call KeyDelay
    btjf KEY_COL2, col2_row3
    ld A, #5
    ;call
    jra keyarray_num
col2_row3:
    bset KEY_ROW3
    call KeyDelay
    btjf KEY_COL2, col2_row4
    ld A, #2
    ;call
    jra keyarray_num
col2_row4:
    bset KEY_ROW4
    call KeyDelay
    btjf KEY_COL2, col23_keyarray_exit_jp
    ld A, #KEY_NUM_DOT ; 0xFE + 0x30 = .  (0x28 - ASCII)
    ;call
    jp keyarray_dot



    ; ------- column 3 --------
keyarray_col3:

col3_row1:
    bset KEY_ROW1
    call KeyDelay
    btjf KEY_COL3, col3_row2
    ld A, #9
    ;call 
    jra keyarray_num
col3_row2:
    bset KEY_ROW2
    call KeyDelay
    btjf KEY_COL3, col3_row3
    ld A, #6
    ;call
    jra keyarray_num
col3_row3:
    bset KEY_ROW3
    call KeyDelay
    btjf KEY_COL3, col3_row4
    ld A, #3
    ;call
    jra keyarray_num
col3_row4:
    bset KEY_ROW4
    call KeyDelay
    btjf KEY_COL3, col23_keyarray_exit_jp
    ld A, #0FFH
    ;call
    jra col3_keyarray_done_jp


col3_keyarray_done_jp:
    jp keyarray_done

    ;;;;;;;;;;;;;
col23_keyarray_exit_jp:
    jp keyarray_scan_exit


    ; -----------------------------------------------
    ; -----------------------------------------------
keyarray_num:
    push A
    ld A, KEY_ARRAY_MENU
    cp A, #2
    jrne keyarray_num_start
    
keyarray_num_menu_2:
    pop A
    jra col23_keyarray_exit_jp
;keyarray_num_menu_2_to_1:
;    LCD_ClearLine 2

keyarray_num_start:
    
    
    
    mov KEY_TYPING_FLAG, #1
    ;ld A, KEY_ARRAY_MENU
    cp A, #3
    jreq keyarray_num_menu_3
    
    ;mov KEY_ARRAY_MENU, #1
    ;ld A, 
    
keyarray_num_menu_1:
    pop A
    ldw X, KEYBOARD_PTR
    ; if current ptr is 3, but it has to be a dot .
    ; , so mov it to KEYBOARD_S0(ptr = 4)
    push A
    ld A, KEYBOARD_DOT_OK
    jreq keyarray_num_no_dot
    pop A
    ld (KEYBOARD_STORE,X), A
    jra keyarray_done
    
keyarray_num_menu_3:
    pop A
    ldw X, KEYBOARD_PTR
    ld (KEYBOARD_STORE,X), A
    cpw X, #4
    jreq keyarray_done
    
    jra keyarray_num_dot_exit_inc_jp

keyarray_num_no_dot:
    pop A
    cpw X, #3
    jreq keyarray_num_dot_exit_inc_jp
    

    ; inc ptr
    ;incw X
keyarray_ptr_cur:
    ;ld (KEYBOARD_STORE,X), A

    cpw X, #4
    jreq keyarray_done
    ; done
    
    ;call KeyArray_Settle
    jra keyarray_num_dot_exit_inc_jp
    ;call done
    
    ;;;;;;;;;
keyarray_num_dot_exit_inc_jp:    
    jp keyarray_scan_exit_inc
    
keyarray_num_dot_exit_jp:
    jp keyarray_scan_exit    
    
    
    ; -----------------------------------------------
    ; -----------------------------------------------
keyarray_dot:
    push A
    ld A, KEY_ARRAY_MENU
    cp A, #1
    jreq keyarray_dot_menu_1
    cp A, #2
    jreq keyarray_dot_menu_2
    jra keyarray_num_dot_exit_jp
    
keyarray_dot_menu_2:
    pop A
    ; clear max hold
    
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
    
    jra keyarray_num_dot_exit_jp
keyarray_dot_menu_1:
    pop A
    ;mov KEY_TYPING_FLAG, #1
    ld A, KEYBOARD_DOT_OK
    jrne keyarray_num_dot_exit_jp
    
    ld A, #KEY_NUM_DOT
    
    ldw X, KEYBOARD_PTR
    ; if current ptr is 0, but it has to be a num.
    ; , so handle it as a fraction with 0 integer
    ;cpw X, #0
    ;incw X
    cpw X, #4
    jreq keyarray_num_dot_exit_jp
    
    mov KEYBOARD_DOT_OK, #1
    ;ld (KEYBOARD_STORE,X), A
    
    cpw X, #0
    jrne keyarray_scan_exit_inc
    ; if ptr = 0
    
    ;ld (KEYBOARD_STORE,X), A
    incw X
    jra keyarray_scan_exit_inc
    
    ; -----------------------------------------------
    ; -----------------------------------------------
keyarray_done:
    push A
    
    ld A, KEY_TYPING_FLAG
    jrne keyarray_done_menu_1_3

    ld A, KEY_ARRAY_MENU
    cp A, #1
    jreq keyarray_menu_to_2
    
    cp A, #2
    jreq keyarray_menu_to_3

    cp A, #3
    jreq keyarray_menu_to_1

keyarray_menu_to_3:
    LCD_ClearLine 2
    pop A
    mov KEY_ARRAY_MENU, #3
    jra keyarray_scan_exit

keyarray_menu_to_2:
    LCD_ClearLine 2
    pop A
    mov KEY_ARRAY_MENU, #2
    jra keyarray_scan_exit
    
keyarray_menu_to_1:
    LCD_ClearLine 2
    pop A
    mov KEY_ARRAY_MENU, #1
    jra keyarray_scan_exit
    

keyarray_done_menu_1_3:
    pop A

    ld (KEYBOARD_STORE,X), A
    ld A, {KEYBOARD_PTR+1}
    jreq keyarray_scan_exit
    
    ;call Price_Align
    call KeyArray_Settle
    jra keyarray_scan_exit



keyarray_scan_exit_inc:
    ld (KEYBOARD_STORE,X), A
    incw X
    ldw KEYBOARD_PTR, X
    
    ld A, KEY_ARRAY_MENU
    cp A, #1
    jreq scan_exit_inc_menu_1
    call ThresholdInputHandle
    jra keyarray_scan_exit
scan_exit_inc_menu_1:
    call PriceAlign
    ;call KeyArray_Display
    
keyarray_scan_exit:
    ; restore output 0
    mov PC_ODR, #0
    
    call KeyArray_Display
    
    ; -----------------------------------------------
    ; -----------------------------------------------    
    ld A, KEY_ARRAY_MENU
    cp A, #2
    jreq keyarray_scan_menu_2
    cp A, #3
    jreq keyarray_scan_menu_3
    PrintChar #13, #0, #CHAR_I_R
    PrintChar #14, #0, #CHAR_II
    PrintChar #15, #0, #CHAR_III
    jra keyarray_scan_menu_exit
keyarray_scan_menu_2:
    PrintChar #13, #0, #CHAR_I
    PrintChar #14, #0, #CHAR_II_R
    PrintChar #15, #0, #CHAR_III
    jra keyarray_scan_menu_exit
keyarray_scan_menu_3:
    PrintChar #13, #0, #CHAR_I
    PrintChar #14, #0, #CHAR_II
    PrintChar #15, #0, #CHAR_III_R
    
keyarray_scan_menu_exit:
    popw X
    pop A
    pop CC
    ret


;***********************************************************
;name   : KeyArray_Settle()
;from   : PE4: interrupt input ; 
;       : PC1~4: row - output
;       : PC5~7 : col - input
;go     : 
;pins   :
;           IN  : NULL
;           OUT : NULL
;                       0xFE = '.'
;***********************************************************

.KeyArray_Settle.W
    push CC
    push A
    
    ld A, KEY_ARRAY_MENU
    cp A, #3
    jreq keyarray_settle_menu_3
    
keyarray_settle_menu_1:
    call PriceAlign
    ;call KeyArray_Display
    
    clr KEYBOARD_S4
    clr KEYBOARD_S3
    clr KEYBOARD_S2
    clr KEYBOARD_S1
    ;mov KEYBOARD_S1, #KEY_DOT_NUM
    clr KEYBOARD_S0
    
    
    
    mov KEYBOARD_DOT_OK, #0
    
    LCD_SCmd LCD_CMD_FOSC_OFF
    jra keyarray_settle_exit
    
keyarray_settle_menu_3:

    call ThresholdInputHandle
    LCD_SCmd LCD_CMD_FOSC_OFF
    
    
keyarray_settle_exit:
    ; 
    clr {KEYBOARD_PTR+0}
    clr {KEYBOARD_PTR+1}
    mov KEY_TYPING_FLAG, #0
    
    pop A
    pop CC
    ret


;***********************************************************
;name   : ThresholdInputHandle()
;from   : 
;go     : 
;pins   :
;           IN  : NULL
;           OUT : NULL
;***********************************************************
.ThresholdInputHandle.W
    push CC
    push A
    pushw X
    
    ;clr CHAR_THRESHOLD7
    ;clr CHAR_THRESHOLD6
    ;clr CHAR_THRESHOLD5
    ;clr CHAR_THRESHOLD4
    ;clr CHAR_THRESHOLD3
    ;clr CHAR_THRESHOLD2
    ;clr CHAR_THRESHOLD1
    ;clr CHAR_THRESHOLD0
    LCD_SCmd LCD_CMD_FOSC_ON
    mov KEYBOARD_THRESHOLD_BUF_S4, KEYBOARD_S4
    mov KEYBOARD_THRESHOLD_BUF_S3, KEYBOARD_S3
    mov KEYBOARD_THRESHOLD_BUF_S2, KEYBOARD_S2
    mov KEYBOARD_THRESHOLD_BUF_S1, KEYBOARD_S1
    mov KEYBOARD_THRESHOLD_BUF_S0, KEYBOARD_S0
    
    
    push #0
    push #0
    
    ;-------------
    ;   HIGH STACK
    ;+2 XL(threshold)
    ;+1 XH(threshold)
    ;   LOW STACK
    ;-------------
    
    ; x100000
    ld A, KEYBOARD_THRESHOLD_BUF_S4
    ldw X, #10000
    call TriMul
    ; A:X < 0x00FFFF
    addw X, (1,SP)
    ldw (1,SP), X
    
    ; x1000
    ld A, KEYBOARD_THRESHOLD_BUF_S3
    ldw X, #1000
    call TriMul

    addw X, (1,SP)
    ldw (1,SP), X
    
    ; x100
    ld A, KEYBOARD_THRESHOLD_BUF_S2
    ldw X, #100
    call TriMul

    addw X, (1,SP)
    ldw (1,SP), X
    
    ; x10
    ld A, KEYBOARD_THRESHOLD_BUF_S1
    ldw X, #10
    call TriMul

    addw X, (1,SP)
    ldw (1,SP), X
    
    ; x1
    ld A, KEYBOARD_THRESHOLD_BUF_S0
    clrw X
    ld XL, A

    addw X, (1,SP)
    ;ldw (1,SP), X
    popw X
    ldw ADC_THRESHOLD_QUOTIENT, X
    
    

    popw X
    pop A
    pop CC
    ret




;***********************************************************
;name   : PriceAlign()
;from   : 
;go     : 
;pins   :
;           IN  : NULL
;           OUT : NULL
;                       0xFE = '.'
;***********************************************************
.PriceAlign.W
    push CC
    push A
    pushw X
    
    ;clr KEYBOARD_BUF_S4
    clr KEYBOARD_PRICE_BUF_S4
    clr KEYBOARD_PRICE_BUF_S3
    clr KEYBOARD_PRICE_BUF_S2
    mov KEYBOARD_PRICE_BUF_S1, #KEY_NUM_DOT
    clr KEYBOARD_PRICE_BUF_S0
    
    ld A, {KEYBOARD_PTR+1}
    jreq price_align_exit
    ; align the num and dot
    cp A, #1
    jrne keyarray_align_start
    LCD_SCmd LCD_CMD_FOSC_ON

keyarray_align_start:
    ld A, KEYBOARD_DOT_OK
    ; cp A, #0
    jreq keyarray_dot_false;
keyarray_dot_true:
        ;ldw X, KEYBOARD_PTR
        ld A, {KEYBOARD_PTR+1}
        dec A
        ; A = ptr
        ;push A
        ; 3 - A = -(A - 3)
        sub A, #3
        neg A
        ; A = 3-A
        clrw X
        ld XL, A
        ;pop A
        ld A, {KEYBOARD_PTR+1}
        addw X, #KEYBOARD_PRICE_BUF_S4
        ; X = ptr + buf_start
        ldw Y, #KEYBOARD_STORE
        ;addw Y, KEYBOARD_PTR
        ; Y => X
        ; Y = ptr + keyboard_start
        ; A = loop counter
keyarray_dot_true_align_loop:
        ;ld A, #KEYBOARD_STORE
            push A
            ld A, (Y)
            ;add A, #30H  ; ascii : A + '0'
            ld (X), A
            pop A
            incw Y
            incw X
            dec A
        jrne keyarray_dot_true_align_loop
        
        ld A, (Y)
        ;add A, #30H
        ld KEYBOARD_PRICE_BUF_S0, A
        jra price_align_exit
    
    
keyarray_dot_false:
        ld A, {KEYBOARD_PTR+1}
        ; A = ptr
        ;push A
        ; 3 - A = -(A - 3)
        sub A, #3
        neg A
        ; A = 3-A
        clrw X
        ld XL, A
        ;pop A
        ld A, {KEYBOARD_PTR+1}
        addw X, #KEYBOARD_PRICE_BUF_S4
        ; X = ptr + buf_start
        ldw Y, #KEYBOARD_STORE
        ;addw Y, KEYBOARD_PTR
        ; Y => X
        ; Y = ptr + keyboard_start
        ; A = loop counter
keyarray_dot_false_align_loop:
        ;ld A, #KEYBOARD_STORE
            push A
            ld A, (Y)
            ;add A, #30H  ; ascii : A + '0'
            ld (X), A
            pop A
            incw Y
            incw X
            dec A
        jrne keyarray_dot_false_align_loop

price_align_exit:

    popw X
    pop A
    pop CC
    ret

;***********************************************************
;name   : KeyArray_Display()
;from   : PE4: interrupt input ; 
;       : PC1~4: row - output
;       : PC5~7 : col - input
;go     : 
;pins   :
;           IN  : NULL
;           OUT : NULL
;                       0xFE = '.'
;***********************************************************
.KeyArray_Display.W
    push CC
    push A
    pushw X
    
    ld A, KEY_ARRAY_MENU
    cp A, #3
    jreq keyarray_display_menu_3
    cp A, #2
    jreq keyarray_display_exit
    
    
    ;LCD_SetCursor_Macro #0,#1
keyarray_display_menu_1:
    mov CHAR_PRICE5, #'#'   
    
    ld A, KEYBOARD_PRICE_BUF_S4
    add A, #30H
    ld CHAR_PRICE4, A
    
    ld A, KEYBOARD_PRICE_BUF_S3
    add A, #30H
    ld CHAR_PRICE3, A
    
    ld A, KEYBOARD_PRICE_BUF_S2
    add A, #30H
    ld CHAR_PRICE2, A
    
    mov CHAR_PRICE1, #'.'
    ;ld A, KEYBOARD_BUF_S1
    ;add A, #30H
    ;ld CHAR_PRICE1, A
    
    ld A, KEYBOARD_PRICE_BUF_S0
    add A, #30H
    ld CHAR_PRICE0, A
    
    
    ;ld A, KEY_ARRAY_MENU
    ;cp A, #1
    ;jrne print_max_str_in_menu_2
    
    PrintStr #0,#1,#STR_PRICE
    jra keyarray_display_exit

keyarray_display_menu_3:
    mov CHAR_THRESHOLD7, #'T'
    mov CHAR_THRESHOLD6, #0A2H
    mov CHAR_THRESHOLD0, #0A3H
    
    ld A, KEYBOARD_THRESHOLD_BUF_S4
    add A, #30H
    ld CHAR_THRESHOLD5, A
    
    ld A, KEYBOARD_THRESHOLD_BUF_S3
    add A, #30H
    ld CHAR_THRESHOLD4, A
    
    ld A, KEYBOARD_THRESHOLD_BUF_S2
    add A, #30H
    ld CHAR_THRESHOLD3, A
    
    ld A, KEYBOARD_THRESHOLD_BUF_S1
    add A, #30H
    ld CHAR_THRESHOLD2, A
    
    ld A, KEYBOARD_THRESHOLD_BUF_S0
    add A, #30H
    ld CHAR_THRESHOLD1, A


    PrintStr #0,#1,#STR_THRESHOLD

    ;PrintStr #0, #1, #STR_MAX_MASS
    
    ;mov KEYBOARD_BUF_S4, KEYBOARD_S4
    ;mov KEYBOARD_BUF_S3, KEYBOARD_S3
    ;mov KEYBOARD_BUF_S2, KEYBOARD_S2
    ;mov KEYBOARD_BUF_S1, KEYBOARD_S1
    ;mov KEYBOARD_BUF_S0, KEYBOARD_S0
    
    ;ld A, #30
    ;add A, KEYBOARD_BUF_S4
    
    
    ; A = display counter, dec
    ;ld A, KEYBOARD_DOT_OK
    ;jreq keyarray_display_start
    ;dec



keyarray_display_exit:


    popw X
    pop A
    pop CC
    ret






;***********************************************************
;name   : TypingCursorFlash()
;from   : 
;go     : 
;pins   :
;           IN  : NULL
;           OUT : NULL
;***********************************************************
.TypingCursorFlash.W
    push CC
    push A
    pushw X
    
    ld A, KEY_ARRAY_MENU
    cp A, #3
    jreq cursorflash_menu_3
    
cursorflash_menu_1:
    mov LCD_VAR1, #1    ; y = 1, line 2
    
    mov LCD_VAR0, #5    ; x = 4, col 5
    ld A, KEYBOARD_DOT_OK
    jrne setcursor_ok
    
    ld A, {KEYBOARD_PTR+1}
    mov LCD_VAR0, #3
    cp A, #3    ; next =? CHAR_PRICE1
    jrne setcursor_ok
    mov LCD_VAR0, #4
setcursor_ok:
    
    call LCD_SetCursor
    
    jra cursorflash_exit
    
cursorflash_menu_3:
    mov LCD_VAR1, #1    ; y = 1, line 2
    ld A, {KEYBOARD_PTR+1}
    add A, #2
    ld LCD_VAR0, A
    
    call LCD_SetCursor
    
cursorflash_exit:
    popw X
    pop A
    pop CC
    ret 


;***********************************************************
;name   : Cal_Money()
;fun    : 
;params : 
;         IN  : WEIGHT_QUOTIENT
;               WEIGHT_REMAINDER
;         OUT : 
;***********************************************************
.Cal_Money.W
    push CC
    push A
    pushw X
    pushw Y
    
    ;-------------
    ;   HIGH STACK
    ;+2 YL(price*10)
    ;+1 YH(price*10)
    ;   LOW STACK
    ;-------------
    ; ----- get price ------
    ; X <= price * 10
    ld A, KEYBOARD_PRICE_BUF_S4
    ldw X, #1000
    call TriMul
    ; A:X
    ldw (1,SP), X

    
    ld A, KEYBOARD_PRICE_BUF_S3
    ldw X, #100
    call TriMul
    ; A:X
    addw X, (1,SP)
    ldw (1,SP), X
    
    ld A, KEYBOARD_PRICE_BUF_S2
    ldw X, #10
    call TriMul
    addw X, (1,SP)
    ldw (1,SP), X
    
    
    ld A, KEYBOARD_PRICE_BUF_S0
    clrw X
    ld XL, A
    addw X, (1,SP)
    ldw (1,SP), X


    ;-------------
    ;   HIGH STACK
    ;+2 YL(price*10)
    ;+1 YH(price*10)
    ;   LOW STACK
    ;-------------
    
    
    ldw X, WEIGHT_QUOTIENT
    ldw Y, #500
    divw X, Y
    ; MAX WEIGHT = 20kg, X[max] = 20kg / 500g = 40 
    ld A, XL
    
    popw X
    
    call MoneyHandle
    
    
    
    
    
    ;popw Y
    popw X
    pop A
    pop CC

    ret 


;***********************************************************
;name   : MoneyHandle()
;fun    : 
;params : 
;         IN  : X <= price * 10
;               A <= weight/500g(quotient) < 40
;               Y <= weight/500g(remainder) < 500
;         OUT : money quotient: A:X
;               money remainder:  Y
;***********************************************************
.MoneyHandle.W
    push CC
    
    pushw X
    
    clr PRICE_MUL3
    clr PRICE_MUL2
    clr PRICE_MUL1
    clr PRICE_MUL0
    ; ---------------------------------------------
    ; integer money: 
    
    ;-------------
    ;   HIGH STACK
    ;+2 XL(price)
    ;+1 XH(price)
    ;   LOW STACK
    ;-------------
    ;ldw X, X
    ;ld A, A
    call TriMul
    ; A:X
    ld PRICE_MUL2, A
    ldw PRICE_MUL1, X
    
    push #0
    push #0
    push #0
    push #0
    ;-------------
    ;   HIGH STACK
    ;+6 XL(price)
    ;+5 XH(price)
    ;+4 (1)
    ;+3 (2)
    ;+2 (3)
    ;+1 (4)
    ;   LOW STACK
    ;-------------
    ;ldw Y, Y
    ldw X, (5,SP)
    call QuadMul
    ; X:Y
    ldw (1,SP), X
    ldw (3,SP), Y
    ; 500 * 9999 < 2^24
    
    
    ; ---------------------------------------------
    ; remainder money:   Y <= remainder 
    ; (Y / 500g < 1)
    ; Y / 500g * price  = (Y * price)  / 500g
    ld A, (2,SP)
    ldw X, (3,SP)
    ldw Y, #500
    call TriDiv
    ; A:X <= quotient, Y <= remainder
    
    addw X, PRICE_MUL1
    adc A, PRICE_MUL2
    push A
    ldw PRICE_MUL1, X
    ld PRICE_MUL2, A
    ld A, PRICE_MUL3
    pop A
    adc A, #0
    ld PRICE_MUL3, A
    
    
    ;-------------
    ;   HIGH STACK
    ;+6 XL(price)
    ;+5 XH(price)
    ;+4 (1)
    ;+3 (2)
    ;+2 (3)
    ;+1 (4)
    ;   LOW STACK
    ;-------------
    ;-------------
    ; (WEIGHT REMAINDER/10) / 500 * price * 10
    ; ((WEIGHT REMAINDER * price * 10) / 500) / 10
    ; + remainder
    
    ; (WEIGHT REMAINDER * price * 10)
    ; WEIGHT REMAINDER * (5,SP)
    ldw X, WEIGHT_REMAINDER
    ldw Y, (5,SP)
    call QuadMul
    ; X:Y
    ; WEIGHT REMAINDER * price * 10 
    ; <= 9 * 999.9 * 10 = 89991 < 2^24
    exgw X, Y
    ld A, YL
    
    ; A:X
    ; / 5000
    ldw Y, #5000
    call TriDiv
    ; <= 89991 / 5000 < 18
    ; A:X   (A = 0x00)
    addw X, PRICE_MUL1
    adc A, #0
    ldw PRICE_MUL1, X
    add A, PRICE_MUL2
    ld PRICE_MUL2, A
    ; 
    
    
    popw X
    popw X
    popw X
    
    
    ; / 10
    ld A, PRICE_MUL2
    ldw X, PRICE_MUL1
    ldw Y, #10
    call TriDiv
    ; A:X <= quotient, Y <= remainder
    
    
    
    call MoneyDisplay

    
    
    pop CC
    ret
    
    
;***********************************************************
;name   : MoneyDisplay()
;fun    : 
;params : 
;         IN  : money quotient: A:X - (A = 0x00)
;               money remainder:  Y
;         OUT :  
;***********************************************************
.MoneyDisplay.W
    push CC
    pushw Y
    
    mov CHAR_MONEY7, #5CH       ;0x5C => гд
    
    ldw Y, #10000
    divw X, Y
    
    addw X, #30H
    ld A, XL
    ld CHAR_MONEY6, A
    
    ldw X, Y
    ldw Y, #1000
    divw X, Y
    
    addw X, #30H
    ld A, XL
    ld CHAR_MONEY5, A
    
    ldw X, Y
    ldw Y, #100
    divw X, Y
    
    addw X, #30H
    ld A, XL
    ld CHAR_MONEY4, A
    
    ldw X, Y
    ldw Y, #10
    divw X, Y
    
    addw X, #30H
    ld A, XL
    ld CHAR_MONEY3, A
    

    addw Y, #30H
    ld A, YL
    ld CHAR_MONEY2, A
    
    
    mov CHAR_MONEY1, #'.'
    
    
    popw Y
    addw Y, #30H
    ld A, YL
    ld CHAR_MONEY0, A
    
    
    ld A, KEY_ARRAY_MENU
    cp A, #1
    jrne moneydisplay_exit
    ;PrintStr #8,#1,#STR_MONEY
    
    ;
moneydisplay_exit:

    pop CC
    ret




    end
    
    