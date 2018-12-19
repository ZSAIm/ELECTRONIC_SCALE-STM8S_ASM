stm8/

    segment 'ram0'
    
    BYTES
;;; COMMON TEMP VARIABLE, FOR LCD
;   ++ 0x0F
.LCD_VAR0.B ds.b 1  ; LCD coor x
.LCD_VAR1.B ds.b 1  ; LCD coor y
.LCD_VAR2.B ds.b 1  ; char




.ADC_COUNTER.B ds.b 1


;;; ADC 24bit store :8 consecutive result
;   ++ 0x04
.ADC_SUM.B
.ADC_SUM3.B ds.b 1
.ADC_SUM2.B ds.b 1
.ADC_SUM1.B ds.b 1
.ADC_SUM0.B ds.b 1
;   ++ 0x04
; ADC_AVG3 for convenience
.ADC_AVG.B
.ADC_AVG3.B ds.b 1
.ADC_AVG2.B ds.b 1
.ADC_AVG1.B ds.b 1
.ADC_AVG0.B ds.b 1


;   ++ 0x01
.ADC_STORE.B
    
;   ++ 0x18
.ADC_S02.B ds.b 1
.ADC_S01.B ds.b 1
.ADC_S00.B ds.b 1

.ADC_S12.B ds.b 1
.ADC_S11.B ds.b 1
.ADC_S10.B ds.b 1

.ADC_S22.B ds.b 1
.ADC_S21.B ds.b 1
.ADC_S20.B ds.b 1

.ADC_S32.B ds.b 1
.ADC_S31.B ds.b 1
.ADC_S30.B ds.b 1

.ADC_S42.B ds.b 1
.ADC_S41.B ds.b 1
.ADC_S40.B ds.b 1

.ADC_S52.B ds.b 1
.ADC_S51.B ds.b 1
.ADC_S50.B ds.b 1

.ADC_S62.B ds.b 1
.ADC_S61.B ds.b 1
.ADC_S60.B ds.b 1

.ADC_S72.B ds.b 1
.ADC_S71.B ds.b 1
.ADC_S70.B ds.b 1

;   ++ 0x03
;   extra 24bit : rotate to reduce manipulation
.ADC_S82.B ds.b 1
.ADC_S81.B ds.b 1
.ADC_S80.B ds.b 1

.ADC_S92.B ds.b 1
.ADC_S91.B ds.b 1
.ADC_S90.B ds.b 1

.ADC_SA2.B ds.b 1
.ADC_SA1.B ds.b 1
.ADC_SA0.B ds.b 1

.ADC_SB2.B ds.b 1
.ADC_SB1.B ds.b 1
.ADC_SB0.B ds.b 1

.ADC_SC2.B ds.b 1
.ADC_SC1.B ds.b 1
.ADC_SC0.B ds.b 1

.ADC_SD2.B ds.b 1
.ADC_SD1.B ds.b 1
.ADC_SD0.B ds.b 1

.ADC_SE2.B ds.b 1
.ADC_SE1.B ds.b 1
.ADC_SE0.B ds.b 1

.ADC_SF2.B ds.b 1
.ADC_SF1.B ds.b 1
.ADC_SF0.B ds.b 1

.ADC_SG2.B ds.b 1
.ADC_SG1.B ds.b 1
.ADC_SG0.B ds.b 1

.ADC_SH2.B ds.b 1
.ADC_SH1.B ds.b 1
.ADC_SH0.B ds.b 1

.ADC_SI2.B ds.b 1
.ADC_SI1.B ds.b 1
.ADC_SI0.B ds.b 1

.ADC_SJ2.B ds.b 1
.ADC_SJ1.B ds.b 1
.ADC_SJ0.B ds.b 1

.ADC_SK2.B ds.b 1
.ADC_SK1.B ds.b 1
.ADC_SK0.B ds.b 1

.ADC_SL2.B ds.b 1
.ADC_SL1.B ds.b 1
.ADC_SL0.B ds.b 1

.ADC_SM2.B ds.b 1
.ADC_SM1.B ds.b 1
.ADC_SM0.B ds.b 1

.ADC_SN2.B ds.b 1
.ADC_SN1.B ds.b 1
.ADC_SN0.B ds.b 1

.ADC_SO2.B ds.b 1
.ADC_SO1.B ds.b 1
.ADC_SO0.B ds.b 1

.ADC_SP2.B ds.b 1
.ADC_SP1.B ds.b 1
.ADC_SP0.B ds.b 1

.ADC_SQ2.B ds.b 1
.ADC_SQ1.B ds.b 1
.ADC_SQ0.B ds.b 1

.ADC_SR2.B ds.b 1
.ADC_SR1.B ds.b 1
.ADC_SR0.B ds.b 1

.ADC_SS2.B ds.b 1
.ADC_SS1.B ds.b 1
.ADC_SS0.B ds.b 1

.ADC_ST2.B ds.b 1
.ADC_ST1.B ds.b 1
.ADC_ST0.B ds.b 1

.ADC_SU2.B ds.b 1
.ADC_SU1.B ds.b 1
.ADC_SU0.B ds.b 1

.ADC_SV2.B ds.b 1
.ADC_SV1.B ds.b 1
.ADC_SV0.B ds.b 1

.ADC_SW2.B ds.b 1
.ADC_SW1.B ds.b 1
.ADC_SW0.B ds.b 1

.ADC_SX2.B ds.b 1
.ADC_SX1.B ds.b 1
.ADC_SX0.B ds.b 1

.ADC_SY2.B ds.b 1
.ADC_SY1.B ds.b 1
.ADC_SY0.B ds.b 1


;.ADC_THRESHOLD3 ds.b 1
;.ADC_THRESHOLD2 ds.b 1
.ADC_THRESHOLD_QUOTIENT.B
.ADC_THRESHOLD_QUOTIENT1.B ds.b 1
.ADC_THRESHOLD_QUOTIENT0.B ds.b 1

.ADC_MAX_QUOTIENT.B
.ADC_MAX_QUOTIENT_S1 ds.b 1
.ADC_MAX_QUOTIENT_S0 ds.b 1

.ADC_MAX_REMAINDER.B
.ADC_MAX_REMAINDER_S1 ds.b 1
.ADC_MAX_REMAINDER_S0 ds.b 1

;   ++ 0x01
;   next store pointer, def a word for convenience
.ADC_NEXT_PTR.B ds.w 1 
;
;.ADC_MAX_PTR.B ds.w 1
;.ADC_MIN_PTR.B ds.w 1


.ADC_SLOPE.B ds.w 1
;ADC = Weight * Slope

;;; ZERO g <=> ADC 24bit, Calibrated ADC
;   ++ 0x04
.ZERO_ADC.B     ; 01 6A 00
.ZERO_ADC3.B ds.b 1
.ZERO_ADC2.B ds.b 1
.ZERO_ADC1.B ds.b 1
.ZERO_ADC0.B ds.b 1

;;
.NET_ADC.B
.NET_ADC3.B ds.b 1
.NET_ADC2.B ds.b 1
.NET_ADC1.B ds.b 1
.NET_ADC0.B ds.b 1

.NET_BUF.B
.NET_BUF3.B ds.b 1
.NET_BUF2.B ds.b 1
.NET_BUF1.B ds.b 1
.NET_BUF0.B ds.b 1

.WEIGHT.B
.WEIGHT_QUOTIENT.B ds.w 1
.WEIGHT_REMAINDER.B ds.w 1

;corresponding Voltage * 1000

.PRICE_MUL.B
.PRICE_MUL3.B ds.b 1    ;must be 0; <= 40 * 9999 < 2^24
.PRICE_MUL2.B ds.b 1    
.PRICE_MUL1.B ds.b 1
.PRICE_MUL0.B ds.b 1
    

.KEYDOWN_FLAG.B ds.b 1

    
.KEYBOARD_STORE.B

; MAX number 999.9
.KEYBOARD_S4.B ds.b 1       ; num 0-9(integer)
.KEYBOARD_S3.B ds.b 1       ; num 0-9 / dot
.KEYBOARD_S2.B ds.b 1       ; num 0-9 / dot
.KEYBOARD_S1.B ds.b 1       ; dot / num(fraction)
.KEYBOARD_S0.B ds.b 1       ; num 0-9(fraction)

.KEYBOARD_PTR.B ds.w 1    

.KEYBOARD_DOT_OK.B ds.b 1


.KEYBOARD_PRICE_BUF_S4.B ds.b 1
.KEYBOARD_PRICE_BUF_S3.B ds.b 1
.KEYBOARD_PRICE_BUF_S2.B ds.b 1
.KEYBOARD_PRICE_BUF_S1.B ds.b 1
.KEYBOARD_PRICE_BUF_S0.B ds.b 1


.KEYBOARD_THRESHOLD_BUF_S4.B ds.b 1
.KEYBOARD_THRESHOLD_BUF_S3.B ds.b 1
.KEYBOARD_THRESHOLD_BUF_S2.B ds.b 1
.KEYBOARD_THRESHOLD_BUF_S1.B ds.b 1
.KEYBOARD_THRESHOLD_BUF_S0.B ds.b 1


.KEY_ARRAY_MENU.B ds.b 1
.KEY_TYPING_FLAG.B ds.b 1



.STR_MASS.B
.CHAR_MASS9.B ds.b 1    ; 
.CHAR_MASS8.B ds.b 1    ; '-' or ' '
.CHAR_MASS7.B ds.b 1
.CHAR_MASS6.B ds.b 1
.CHAR_MASS5.B ds.b 1
.CHAR_MASS4.B ds.b 1
.CHAR_MASS3.B ds.b 1
.CHAR_MASS2.B ds.b 1
.CHAR_MASS1.B ds.b 1
.CHAR_MASS0.B ds.b 1    ; 'g'
.CHAR_MASS_1.B ds.b 1
.str_mass_end.b ds.b 1



.STR_PRICE.B
.CHAR_PRICE5.B ds.b 1   ; '#'
.CHAR_PRICE4.B ds.b 1
.CHAR_PRICE3.B ds.b 1
.CHAR_PRICE2.B ds.b 1
.CHAR_PRICE1.B ds.b 1
.CHAR_PRICE0.B ds.b 1
.str_price_end.b ds.b 1

.STR_THRESHOLD.B
.CHAR_THRESHOLD7.B ds.b 1   ; 'T'
.CHAR_THRESHOLD6.B ds.b 1   ; '['
.CHAR_THRESHOLD5.B ds.b 1   
.CHAR_THRESHOLD4.B ds.b 1
.CHAR_THRESHOLD3.B ds.b 1
.CHAR_THRESHOLD2.B ds.b 1
.CHAR_THRESHOLD1.B ds.b 1
.CHAR_THRESHOLD0.B ds.b 1   ; ']'
.str_threshold_end.b ds.b 1



.STR_MONEY.B
.CHAR_MONEY7.B ds.b 1   ; 'гд'
.CHAR_MONEY6.B ds.b 1
.CHAR_MONEY5.B ds.b 1
.CHAR_MONEY4.B ds.b 1
.CHAR_MONEY3.B ds.b 1
.CHAR_MONEY2.B ds.b 1
.CHAR_MONEY1.B ds.b 1
.CHAR_MONEY0.B ds.b 1
.str_money_end.b ds.b 1


.STR_MAX_MASS.B
;.CHAR_MAX_MASS11.B ds.b 1   ; 'M'
;.CHAR_MAX_MASS10.B ds.b 1   ; 'M'
.CHAR_MAX_MASS9.B ds.b 1    ; 'M'
.CHAR_MAX_MASS8.B ds.b 1    ; '['
.CHAR_MAX_MASS7.B ds.b 1
.CHAR_MAX_MASS6.B ds.b 1
.CHAR_MAX_MASS5.B ds.b 1
.CHAR_MAX_MASS4.B ds.b 1
.CHAR_MAX_MASS3.B ds.b 1
.CHAR_MAX_MASS2.B ds.b 1    ; '.'
.CHAR_MAX_MASS1.B ds.b 1    ; 
.CHAR_MAX_MASS0.B ds.b 1    ; 'g'
.CHAR_MAX_MASS_1.B ds.b 1    ; ']'

.str_max_mass_end.b ds.b 1

    end
    
    