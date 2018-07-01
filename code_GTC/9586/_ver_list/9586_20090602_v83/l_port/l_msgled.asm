.LIST
;-------------------------------------------------------------------------------
;	Function : MSGLED_H/MSGLED_L/MSGLED_FLASH
;-------------------------------------------------------------------------------
MSGLED_IDLE:
	LACK    1
	BIT	ANN_FG,12
	BZ	TB,MSGLED_IDLE_MSGLED
	LACL    500
MSGLED_IDLE_MSGLED:
	SAH	MSGLED_FG	;MsgLED off/flash
        
        RET
;-------------------------------------------------------------------------------
;MSGLED_H:
;	LIPK	8
;
;	IN	SYSTMP0,GPAD	;GPAD.CbMSGLED = 1
;	LAC	SYSTMP0
;	ORL	1<<CbMSGLED
;	SAH	SYSTMP0
;	OUT	SYSTMP0,GPAD
;	ADHK	0
;	
;	RET
;---------------
;MSGLED_L:
;	LIPK	8
;
;	IN	SYSTMP0,GPAD	;GPAD.CbMSGLED = 0
;	LAC	SYSTMP0
;	ANDL	~(1<<CbMSGLED)
;	SAH	SYSTMP0
;	OUT	SYSTMP0,GPAD
;	ADHK	0
;	
;	RET
;---------------
;MSGLED_FLASH:
;	LIPK	8
;
;	IN	SYSTMP0,GPAD	;GPAD.CbMSGLED = 0
;	LAC	SYSTMP0
;	XORL	1<<CbMSGLED
;	SAH	SYSTMP0
;	OUT	SYSTMP0,GPAD
;	ADHK	0
;	
	RET
;-------------------------------------------------------------------------------
.END
