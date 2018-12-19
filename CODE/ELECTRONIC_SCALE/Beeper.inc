    
    #IFDEF __BEEPER_
    
    #ELSE
    
    #define __BEEPER_ 1
    #include "stm8s105k4.inc"
    #include "GlobalVar.inc"
    
    EXTERN ThresholdCheck.W
    
    #ENDIF
    
    