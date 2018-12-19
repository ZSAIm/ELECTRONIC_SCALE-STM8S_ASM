stm8/
    
    #include "ADC_Handler.inc"


    INTEL
    segment 'rom'


;***********************************************************
;name   : ADC_Sub_Sum
;fun    : 
;params :
;           IN  : X = ADC_STORE + ADC_PTR(NEXT|MAX|MIN)
;           OUT : NULL
;***********************************************************
.ADC_Sub_Sum.W
    push CC
    push A
    
    ; ADC_SUM(7-0) 1st byte
    ld A, ADC_SUM0
    sub A, (2,X)
    push CC
    ld ADC_SUM0, A
    ; ADC_SUM(15-8) 2nd byte
    ld A, ADC_SUM1
    pop CC
    sbc A, (1,X)
    push CC
    ld ADC_SUM1, A
    ; ADC_SUM(23-16) 3rd byte
    ld A, ADC_SUM2
    pop CC
    sbc A, (X)
    push CC
    ld ADC_SUM2, A
    ; ADC_SUM(31-24) take borrow
    ld A, ADC_SUM3
    pop CC
    sbc A, #0
    ld ADC_SUM3, A
    
    pop A
    pop CC
    ret
    
;***********************************************************
;name   : ADC_Add_Sum
;fun    : 
;params :
;           IN  : X = ADC_STORE + ADC_PTR(NEXT|MAX|MIN)
;           OUT : NULL
;***********************************************************
.ADC_Add_Sum.W
    push CC
    push A
    ; ADC_SUM(7-0) 1st byte
    ld A, ADC_SUM0
    add A, (2,X)
    push CC
    ld ADC_SUM0, A
    ; ADC_SUM(15-8) 2nd byte
    ld A, ADC_SUM1
    pop CC
    adc A, (1,X)
    push CC
    ld ADC_SUM1, A
    ; ADC_SUM(23-16) 3rd byte
    ld A, ADC_SUM2
    pop CC
    adc A, (X)
    push CC
    ld ADC_SUM2, A
    ; ADC_SUM(31-24) take carry
    ld A, ADC_SUM3
    pop CC
    adc A, #0
    ld ADC_SUM3, A

    pop A
    pop CC

    ret


;***********************************************************
;name   : ADC_Moving_Avg
;fun    : calculate the moving average, after remove
;           the polar value
;caution: the method of the function just compares
;           the high 2 bytes, so not exactly removing
;           the two polar values, but enough to smooth ADC.
;params :
;           IN  : ADC_STORE, ADC_SUM
;           OUT : ADC_SUM, ADC_AVG
;***********************************************************
.ADC_Moving_Avg.W
    push CC
    push A
    pushw X
    pushw Y
    
    
    clr ADC_SUM3
    clr ADC_SUM2
    clr ADC_SUM1
    clr ADC_SUM0

    ld A, #ADC_MOVING_NUM
    ldw X, #ADC_STORE
accumulation_start:
    call ADC_Add_Sum
    addw X, #ADC_MOVING_BYTE
    dec A
    jrne accumulation_start
    
    
remove_polar_value:
    call ADC_Find_Max
    ; X => max data
    call ADC_Sub_Sum
    
    call ADC_Find_Min
    ; X => min data
    call ADC_Sub_Sum
    

    ;---------------- averaging -----------------
    ; X : high 16bits
    ; Y : low  16bits
    ldw X, {ADC_SUM+0}
    ldw Y, {ADC_SUM+2}
    ; divide by 16
    rcf
    rrcw X
    rrcw Y
    rcf
    rrcw X
    rrcw Y
    rcf
    rrcw X
    rrcw Y
    rcf
    rrcw X
    rrcw Y


    ldw {ADC_AVG+0}, X
    ldw {ADC_AVG+2}, Y

    popw Y
    popw X
    pop A
    pop CC
    ret

;***********************************************************
;name   : ADC_Find_Max
;fun    : roll back to find the max value
;params :
;           IN  : 
;           OUT : X => max data
;***********************************************************
.ADC_Find_Max.W
    push CC
    pushw Y

    
    ldw X, #ADC_STORE

    ldw Y, X
find_max_loop:
    addw Y, #ADC_MOVING_BYTE
    cpw Y, #{ADC_STORE+ADC_MOVING_BYTE*ADC_MOVING_NUM}
    jreq find_max_end
    pushw Y
    ldw Y, (Y)
    cpw Y, (X)
    jrnc find_max_exchange
    popw Y
    jra find_max_loop
find_max_exchange:
    popw Y
    ldw X, Y
    jra find_max_loop

find_max_end:


    popw Y
    pop CC
    ret


;***********************************************************
;name   : ADC_Find_Min
;fun    : roll back to find the min value
;params :
;           IN  : 
;           OUT : X => min data  (increment ptr)
;***********************************************************
.ADC_Find_Min.W
    push CC
    pushw Y
 

    ldw X, #ADC_STORE

    ldw Y, X
find_min_loop:
    addw Y, #ADC_MOVING_BYTE
    cpw Y, #{ADC_STORE+ADC_MOVING_BYTE*ADC_MOVING_NUM}
    jreq find_min_end
    pushw Y
    ldw Y, (Y)
    cpw Y, (X)
    jrnc find_min_exchange
    popw Y
    ldw X, Y
    jra find_min_loop
find_min_exchange:
    popw Y
    jra find_min_loop

find_min_end:


    
    popw Y
    pop CC
    ret






    
;***********************************************************
;name   : ADC_Convert_Mass
;fun    : calculate the final mass of the thing
;params : 
;           IN  : ADC_AVG
;           OUT : NET_ADC
;***********************************************************
.ADC_Convert_Mass.W
    push CC
    pushw X
    pushw Y
    push A
    
    
    ; cal increment
    ld A, ADC_AVG0
    sub A, ZERO_ADC0
    push CC
    ld NET_ADC0, A

    ld A, ADC_AVG1
    pop CC
    sbc A, ZERO_ADC1
    push CC
    ld NET_ADC1, A

    ld A, ADC_AVG2
    pop CC
    sbc A, ZERO_ADC2
    ld NET_ADC2, A
    
    mov NET_ADC3, #00H
    
    
    ;call DispADC
    ; adc data to mass
    mov NET_BUF3, NET_ADC3
    mov NET_BUF2, NET_ADC2
    mov NET_BUF1, NET_ADC1
    mov NET_BUF0, NET_ADC0
    
    
    ;; make ADC_AVG be signed
    btjf NET_ADC2,#7,adc_pos
    ld A, NET_ADC2
    xor A, #0FFH
    ldw X, NET_ADC1
    negw X
    ccf
    adc A, #0
    push CC
    ldw NET_ADC1, X
    ld NET_ADC2, A
    ld A, NET_ADC3
    xor A, #0FFH
    pop CC
    adc A, #0
    ld NET_ADC3, A
adc_pos:
    
    
    
    ; in order to avoiding float operation, 
    ; for accuracy ,so let NET_ADC * 2^8 , 
    ; eventually the slope and the remainder
    ;   will times 2^8.
    ; -------------------------

    mov NET_ADC3, NET_ADC2
    mov NET_ADC2, NET_ADC1
    mov NET_ADC1, NET_ADC0
    mov NET_ADC0, #00

    ldw X, ADC_SLOPE
    call MassDivider
    
    call SaveMaxMass
    
    call ThresholdCheck
    
    call MassHex2DecChar
    
    ;PrintStr #0,#0,#STR_MASS
    
    
    ;call PriceCursorFlash
    pop A
    popw Y
    popw X
    pop CC
    
    ret


;***********************************************************
;name   : MassHex2DecChar()
;fun    : hexadecimal to decimal char
;           X = 24bit / 16bit ; Y = 24bit % 16bit
;params : 
;         IN  : X   : quotient  (mass)
;               Y   : remainder (mass)
;         OUT : MASS_STR: MASS_CHAR7~0
;***********************************************************
.MassHex2DecChar.W
    push CC
    push A
    pushw Y
    pushw X
    
    ; save weight quotient
    ldw WEIGHT_QUOTIENT, X
    
    
    mov CHAR_MASS9, #06H
    
    mov CHAR_MASS_1, #07H
    
    btjt NET_BUF2,#7,mass_neg
    ld A, #' '
    jra mass_pos
mass_neg:
    ld A, #'-'
mass_pos:
    ld CHAR_MASS8, A
    
    
    ; ----------
    ; HIGH STACK
    ;+4 YL - REMAINDER
    ;+3 YH - REMAINDER
    ;+2 XL - QUOTIENT
    ;+1 XH - QUOTIENT
    ; LOW  STACK
    ; ----------
    ; 10k
    ldw Y, #10000
    divw X, Y
    ld A, XL
    add A, #30H
    ld CHAR_MASS7, A
    ; 1k
    ldw X, Y
    ldw Y, #1000
    divw X, Y
    ld A, XL
    add A, #30H
    ld CHAR_MASS6, A
    ; 100
    ldw X, Y
    ldw Y, #100
    divw X, Y
    ld A, XL
    add A, #30H
    ld CHAR_MASS5, A
    ; 10
    ldw X, Y
    ldw Y, #10
    divw X, Y
    ld A, XL
    add A, #30H
    ld CHAR_MASS4, A
    ; 1
    ld A, YL
    add A, #30H
    ld CHAR_MASS3, A
    ; 0.1
    ;  (remainder / slope) * 10 
    ; = remainder / (slope / 10)
    ; = remainder / (quotient + r)  , (r < 1)
    ; ~= remainder / quotient
    ldw X, ADC_SLOPE
    ld A, #10
    div X, A
    
    ; ----------
    ; HIGH STACK
    ;+4 YL - REMAINDER
    ;+3 YH - REMAINDER
    ;+2 XL - QUOTIENT
    ;+1 XH - QUOTIENT
    ; LOW  STACK
    ; ----------
    ldw Y, X
    ldw X, (3,SP)   ; (3,SP) => Y: remainder
    divw X, Y
    
    ld A, XL
    add A, #30H
    ld CHAR_MASS1, A
    
    
    mov CHAR_MASS2, #'.'
    mov CHAR_MASS0, #'g'
    
    ; save weight fraction
    clrw Y
    sub A, #30H
    ld YL, A
    ldw WEIGHT_REMAINDER, Y
    
    

    popw X
    popw Y
    
    pop A
    pop CC

    ret 




;***********************************************************
;name   : SaveMaxMass()
;fun    : 
;params : 
;         IN  : X   : quotient  (mass)
;               Y   : remainder (mass)
;         OUT : ADC_MAX_QUOTIENT ; ADC_MAX_REMAINDER
;               CHAR_MAX_MASS7~0
;***********************************************************
.SaveMaxMass.W
    push CC
    push A
    pushw X
    pushw Y

    ; if mass is negative , no need to compare
    btjt NET_BUF2,#7,savemax_handle_str_start
    ; ----------
    ; HIGH STACK
    ;+4 XL - QUOTIENT
    ;+3 XH - QUOTIENT
    ;+2 YL - REMAINDER
    ;+1 YH - REMAINDER
    ; LOW  STACK
    ; ----------

    ; compare quotient first
    ldw X, ADC_MAX_QUOTIENT
    cpw X, (3,SP)
    jrnc savemax_less_or_equal_q 
    ; > max(quotient)

    jra savemax_newmax_exit
    
savemax_less_or_equal_q:
    ; <= max(quotient)
    ; if != max, exit
    jrne savemax_exit
    ldw X, ADC_MAX_REMAINDER
    cpw X, (1,SP)
    ;jrnc savemax_less_or_equal_r
    jrnc savemax_exit
    ; > max(remainder)
    jra savemax_newmax_exit
    
;savemax_less_or_equal_r:
    ; <= max(remainder)
    ;jra savemax_exit
    
savemax_newmax_exit:
    ldw X, (3,SP)
    ldw ADC_MAX_QUOTIENT, X
    
    ldw X, (1,SP)
    ldw ADC_MAX_REMAINDER, X
    
savemax_handle_str_start:
    ; ----------
    ; HIGH STACK
    ;+4 XL - QUOTIENT
    ;+3 XH - QUOTIENT
    ;+2 YL - REMAINDER
    ;+1 YH - REMAINDER
    ; LOW  STACK
    ; ----------

    ; handle max mass str
    ; 10k
    ldw X, ADC_MAX_QUOTIENT
    
    ldw Y, #10000
    divw X, Y
    ld A, XL
    add A, #30H
    ld CHAR_MAX_MASS7, A
    ; 1k
    ldw X, Y
    ldw Y, #1000
    divw X, Y
    ld A, XL
    add A, #30H
    ld CHAR_MAX_MASS6, A
    ; 100
    ldw X, Y
    ldw Y, #100
    divw X, Y
    ld A, XL
    add A, #30H
    ld CHAR_MAX_MASS5, A
    ; 10
    ldw X, Y
    ldw Y, #10
    divw X, Y
    ld A, XL
    add A, #30H
    ld CHAR_MAX_MASS4, A
    ; 1
    ld A, YL
    add A, #30H
    ld CHAR_MAX_MASS3, A
    ; 0.1
    ;  (remainder / slope) * 10 
    ; = remainder / (slope / 10)
    ; = remainder / (quotient + r)  , (r < 1)
    ; ~= remainder / quotient
    ldw X, ADC_SLOPE
    ld A, #10
    div X, A
    
    ldw Y, X
    ldw X, ADC_MAX_REMAINDER   ; (3,SP) => Y: remainder
    divw X, Y
    
    ld A, XL
    add A, #30H
    ld CHAR_MAX_MASS1, A
    
    mov CHAR_MAX_MASS2, #'.'
    mov CHAR_MAX_MASS0, #'g'
    
    ;mov CHAR_MAX_MASS11, #'m'
    ;mov CHAR_MAX_MASS10, #'a'
    mov CHAR_MAX_MASS9, #'M'
    mov CHAR_MAX_MASS8, #0A2H
    mov CHAR_MAX_MASS_1, #0A3H
    
    

savemax_exit:

    popw Y
    popw X
    pop A
    pop CC
    ret













    end
    
    
    
    
    