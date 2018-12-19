
    #IFDEF __KEY_

    #ELSE
    #define __KEY_ 1

    #define KEY_ZERO PB_IDR,#0
    #define KEY_ARRAY PE_IDR,#5
    
    #define KEY_ROW1 PC_ODR,#7
    #define KEY_ROW2 PC_ODR,#6
    #define KEY_ROW3 PC_ODR,#5
    #define KEY_ROW4 PC_ODR,#4
    
    #define KEY_COL1 PC_IDR,#3
    #define KEY_COL2 PC_IDR,#2
    #define KEY_COL3 PC_IDR,#1
    
    #define KEY_NUM_DOT 0FEH
    
    

    EXTERN KeyZero_Init.W
    EXTERN KeyZero_Handler.L
    
    EXTERN KeyArray_Init.W
    EXTERN KeyArray_Scan.W
    EXTERN KeyArray_Handler.L
    EXTERN KeyArray_Settle.W
    EXTERN KeyArray_Display.W
    EXTERN TypingCursorFlash.W
    EXTERN PriceAlign.W
    EXTERN MoneyHandle.W
    EXTERN Cal_Money.W
    
    #ENDIF
    