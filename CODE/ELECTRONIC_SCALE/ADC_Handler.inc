
    #IFDEF __ADC_Handler_
    
    #ELSE
    #define __ADC_Handler_ 1

    ;#include "ADC.inc"
    #include "Common.inc"
    #include "GlobalVar.inc"
    #include "MacroFunction.inc"
    ;#include "LCD.inc"
    #include "Key.inc"
    #include "Beeper.inc"
    
    #define ADC_MOVING_NUM 18
    #define ADC_MOVING_BYTE 3
    
    
    
    EXTERN ADC_Add_Sum.W
    EXTERN ADC_Sub_Sum.W
    
    
    
    EXTERN ADC_Moving_Avg.W
    EXTERN ADC_Convert_Mass.W
    EXTERN ADC_Find_Max.W
    EXTERN ADC_Find_Min.W
    
    
    #ENDIF
    
    
    
    