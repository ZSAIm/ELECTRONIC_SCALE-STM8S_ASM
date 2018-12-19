
    
    
    #include "Common.inc"
    #include "GlobalVar.inc"
    #include "MacroFunction.inc"
    #include "LCD.inc"
    ;#include "Key.inc"
    #include "ADC_Handler.inc"
    #include "stm8s105k4.inc"

    #define ADC_SCK PD_ODR,#6
    #define ADC_DOUT PD_IDR,#7
    #define ADC_DIN PF_ODR,#4
    #define ADC_DRDY PD_IDR,#0
    
    #define ADC_MOVING_NUM 18
    #define ADC_MOVING_BYTE 3
    ;#define ADC_SLOPE #101
    ; ADC = Weight * Slope
    
    EXTERN ADC_Init.W
    
    EXTERN ADC_Recv_Sv.W
    EXTERN ADC_Cal_Handler.L
    EXTERN ADC_SerData.W

    
    