    
    #IFDEF __LCD_ 1
    
    #ELSE
    #define __LCD_ 1
    
    #include "stm8s105k4.inc"
    #include "GlobalVar.inc"
    #include "MacroFunction.inc"
    #include "Common.inc"
    

    ;#define LCD_OE PB_ODR,#3
    #define LCD_RS PB_ODR,#5
    #define LCD_RW PB_ODR,#4
    #define LCD_E PB_ODR,#3
    #define LCD_SER PD_ODR,#2
    #define LCD_SRCLK PD_ODR,#5
    #define LCD_RCK PD_ODR,#3
    
    
    #define CHAR_I 0
    #define CHAR_I_R 1
    #define CHAR_II 2
    #define CHAR_II_R 3
    #define CHAR_III 4
    #define CHAR_III_R 5
    
    ;#define LCD_OE PB_ODR,#0
    
    
    #define LCD_CMD_INIT #00111000B
    ;   enable display, no cursor, no twinkle
    #define LCD_CMD_ON #00001100B
    ;   disable display, no cursor, no twinkle
    #define LCD_CMD_OFF #0000000B
    #define LCD_CMD_CLEAR #01H
    #define LCD_CMD_FOSC_ON #00001101B
    #define LCD_CMD_FOSC_OFF #00001100B
    
    
    
    EXTERN LCD_Init.W
    EXTERN LCD_WriChar.W
    EXTERN LCD_WriCMD.W
    EXTERN LCD_WriData.W
    EXTERN LCD_SerData.W
    EXTERN LCD_WriString.W
    EXTERN LCD_SetCursor.W
    EXTERN LCD_InitCustom.W
    ;EXTERN LCD_ClearLine.W
    
    EXTERN EMPTY_LINE.W
;
;
;
;
    #ENDIF
    
    

    
    
    
    
    
    
    


