stm8/
    
    ;#include "stm8s105k4.inc"
    #include "GlobalVar.inc"
    ;#include ""
    
    segment 'rom'
    INTEL
;***********************************************************
;name   : CPU_Delay_1us(VAR0F: )
;fun    : delay time = VAR01 * 1us
;params : 
;         IN  : VAR0F <= delay time(s) 1us each
;         OUT : NULL
;***********************************************************
.CPU_Delay_1us.W
    pushw Y
    pushw X
    ldw X, #0FFFFH
cpu_timer1:
    ldw Y, #0FFFFH
cpu_delay_loop:
    nop
    decw Y
    jrne cpu_delay_loop
    
    decw X
    jrne cpu_timer1
    popw X
    popw Y

    ret
    
;***********************************************************
;name   : LCD_Delay()
;fun    : delay just for LCD
;params : 
;         IN  : NULL
;         OUT : NULL
;***********************************************************
.LCD_Delay.W
    pushw Y
    ldw Y, #0138H
    
lcd_delay_loop:
    decw Y
    jrne lcd_delay_loop
    popw Y

    ret
;***********************************************************
;name   : KeyDelay()
;fun    : delay just for key
;params : 
;         IN  : NULL
;         OUT : NULL
;***********************************************************
.KeyDelay.W
    pushw Y
    ldw Y, #0FFFH
    
key_delay_loop:
    decw Y
    nop
    jrne key_delay_loop
    popw Y

    ret    
    


;***********************************************************
;name   : ADC_Delay()
;fun    : delay just for ADC IC - HX711
;params : 
;         IN  : NULL
;         OUT : NULL
;***********************************************************
.ADC_Delay.W
    pushw Y
    ldw Y, #0100H
    
adc_delay_loop:
    decw Y
    jrne adc_delay_loop
    popw Y

    ret

;***********************************************************
;name   : MassDivider() 
;fun    : do the division specifically (unsigned)
;           X = 32bit / 16bit ; Y = 32bit % 16bit
;params : 
;         IN  : NET_ADC3: dividend(31-24)
;               NET_ADC2: dividend(23-16)
;               NET_ADC1: dividend(15-8)
;               NET_ADC0: dividend(7-0)
;               X       : divisor(15-0)
;         OUT : X       : counting quotient(<=65535)
;               Y       : remainder(<=65535)
;***********************************************************
.MassDivider.W
    push CC
    push A
    
    ; allocate a word for storing quotient
    push #0
    push #0
    ; load NET_ADC2 to A, the 3rd byte
    ld A, NET_ADC2
    ; save divisor, mark as *
    pushw X
    ; move to Y
    ldw Y, X

div_start:
    tnzw Y
    jreq div_end0
    ; div => X:(partial)quotient  Y:(partial)remainder
    ldw X, NET_ADC1
    divw X, Y           ; X/Y
    ; inc before saving partial quotient
    incw X
    addw X, (3,SP)
    ldw (3,SP), X
    ; sub by *, (in SP + 2)
    subw Y, (1,SP)
    ; must carry, so jmp anway
    sbc A, #0
    jrc div_3_borrow
div_restore_loop_status:
    ; write back to keep dividing
    ldw NET_ADC1, Y
    ldw Y, (1,SP)
    jra div_start
div_3_borrow:
    dec NET_ADC3
    jrpl div_restore_loop_status
    inc NET_ADC3
div_end0:
    addw Y, (1,SP)
    ; pop out divisor saver, that is *
    popw X
    ; pop out the quotient
    popw X
    ; roll back to last X before sub
    decw X

    pop A
    pop CC
    ret
    
    

;***********************************************************
;name   : TriMul() - 3 byte
;fun    : 
;params : 
;         IN  : X, A
;         OUT : A:X       (A:X <= X * A)
;***********************************************************
.TriMul.W
    push CC
    pushw Y
    
    cpw X, #0
    jreq trimul_zero_exit
    cp A, #0
    jreq trimul_zero_exit
    jra trimul_not_zero
trimul_zero_exit:
    ldw X, #0
    ld A, #0
    jra trimul_exit
    
trimul_not_zero:
    push #0
    push #0
    push #0
    
    pushw X
    
    mul X, A
    ;-------------
    ;   HIGH STACK
    ;+5 (1)
    ;+4 (2)
    ;+3 (3)
    ;+2 XL(input)
    ;+1 XH(input)
    ;   LOW STACK
    ;-------------
    ldw (4,SP), X
    
    ldw X, #00FFH
    mul X, A
    
    push A
    push #0
    addw X, (1,SP)
    pop A
    pop A
    pushw X
    ;-------------
    ;   HIGH STACK
    ;+7 (1)
    ;+6 (2)
    ;+5 (3)
    ;+4 XL(input)
    ;+3 XH(input)
    ;+2 XL(MUL)
    ;+1 XH(MUL)
    ;   LOW STACK
    ;-------------
    ld A, (3,SP)
    jreq trimul_int_end
trimul_int_loop:
        
        ld A, (5,SP)
        ldw X, (1,SP)
        addw X, (6,SP)
        adc A, #0
        ld (5,SP), A
        ldw (6,SP), X
        dec (3,SP)
    jreq trimul_int_end
        jra trimul_int_loop

trimul_int_end:
    popw X
    popw X
    
    ;-------------
    ;   HIGH STACK
    ;+3 (1)
    ;+2 (2)
    ;+1 (3)
    ;   LOW STACK
    ;-------------
    
    pop A
    popw X
    

trimul_exit:
    popw Y
    pop CC
    ret


;***********************************************************
;name   : QuadMul() - 4 byte
;fun    : 
;params : 
;         IN  : X, Y
;         OUT : X:Y       (X:Y <= X * Y)
;***********************************************************
.QuadMul.W
    push CC
    push A
    
        cpw X, #0
    jreq quadmul_zero_exit
        cpw Y, #0
    jreq quadmul_zero_exit
        jra quadmul_not_zero
quadmul_zero_exit:
        ldw X, #0
        ldw Y, #0
        jra quadmul_exit

quadmul_not_zero:
        push #0
        push #0
        push #0
        push #0
        ;pushw X
        pushw X
        
        ;ld X, X
        ld A, YL
        call TriMul
        ; A:X
        ;-------------
        ;   HIGH STACK
        ;+6 (1)
        ;+5 (2)
        ;+4 (3)
        ;+3 (4)
        ;+2 XL(input)
        ;+1 XH(input)
        ;   LOW STACK
        ;-------------
        ldw (5,SP), X
        ld (4,SP), A
        
        popw X
        ;-------------
        ;   HIGH STACK
        ;+4 (1)
        ;+3 (2)
        ;+2 (3)
        ;+1 (4)
        ;   LOW STACK
        ;-------------
        ; X = input
        pushw X
        ld A, #0FFH
        call TriMul
        ; A:X
        ;-------------
        ;   HIGH STACK
        ;+6 (1)
        ;+5 (2)
        ;+4 (3)
        ;+3 (4)
        ;+2 XL(input)
        ;+1 XH(input)
        ;   LOW STACK
        ;-------------
        addw X, (1,SP)
        ldw (1,SP), X
        popw X
        adc A, #0
        
        pushw X
        push A
        
        ld A, YH
        push A  ; decrment
        ;-------------
        ;   HIGH STACK
        ;+8 (1)
        ;+7 (2)
        ;+6 (3)
        ;+5 (4)
        ;+4 XL(MUL) - 1
        ;+3 XH(MUL) - 2
        ;+2 A(MUL)  - 3
        ;+1 YH(dec) - decrement
        ;   LOW STACK
        ;-------------
        ld A, (1,SP)
        jreq quadmul_end
quadmul_accu_loop:
        
        push A
        ld A, (2,SP)
        ldw X, (3,SP)
        addw X, (7,SP)
        adc A, (2,SP)
        push CC
        ld (6,SP), A
        ld A, (5,SP)
        pop CC
        adc A, #0
        ld (5,SP), A
        ldw (7,SP), X
        pop A
        ld (1,SP), A
        dec A
    jreq quadmul_end
        jra quadmul_accu_loop

quadmul_end:
    pop A
    pop A
    popw Y
    
    ; X:Y
    popw X
    popw Y
    
quadmul_exit:
    pop A
    pop CC
    ret

;***********************************************************
;name   : TriDiv() - 3 byte
;fun    : 
;params : 
;         IN  : A:X, Y
;         OUT : quotient: A:X   remainder: Y
;                  (A:X <= A:X / Y)
;***********************************************************
.TriDiv.W
    push CC

    
    cpw Y, #0
    jreq tridiv_exit
    cp A, #0
    jrne long_div
    divw X, Y
    jra tridiv_exit
    
long_div:
    ;push #0     ;(1) - Y
    ;push #0     ;(2) - Y

    push #0     ;(1) - A:X
    push #0     ;(2) - A:X
    push #0     ;(3) - A:X

    pushw X
    pushw Y
    push A
    ;-------------
    ;   HIGH STACK
    ;+8 (1) - A:X   - return quotient
    ;+7 (2) - A:X   - return quotient
    ;+6 (3) - A:X   - return quotient
    ;+5 XL(input)   - variable
    ;+4 XH(input)   - variable
    ;+3 YL(input)   - invariable
    ;+2 YH(input)   - invariable
    ;+1 A(input)    - variable
    ;   LOW STACK
    ;-------------
tridiv_acc_loop:
        ldw Y, (2,SP)
        ldw X, (4,SP)
        divw X, Y
        ; handle quotient 
        ld A, (6,SP)
        addw X, (7,SP)
        adc A, #0
        ;ld (6,SP), A
        addw X, #1
        adc A, #0
        ld (6,SP), A
        ldw (7,SP), X
        ; handle remainder 
        subw Y, (2,SP)
        ldw (4,SP), Y
        ;addw X
        dec (1,SP)
    jreq tridiv_end
        jra tridiv_acc_loop
        
tridiv_end:
    ldw Y, (2,SP)
    ldw X, (4,SP)
    divw X, Y
    ldw (4,SP), Y
    ; handle quotient 
    ld A, (6,SP)
    addw X, (7,SP)
    adc A, #0
    ;ld (6,SP), A
    ld (6,SP), A
    ldw (7,SP), X
    ; handle remainder 




    pop A
    popw Y
    
    ; remainder
    popw Y
    ; quotient A:X
    pop A
    popw X


tridiv_exit:
    pop CC
    ret




    end
    
    
    