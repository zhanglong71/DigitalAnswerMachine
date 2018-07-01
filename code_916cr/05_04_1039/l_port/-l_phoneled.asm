.LIST
;-------------------------------------------------------------------------------
;	Function : PHOLED_H/PHOLED_L/PHOLED_FLASH - (only - interrupt)
;-------------------------------------------------------------------------------
.if	0
PHOLED_H:
	LIPK	8

	IN	SYSTMP0,GPAD	;GPAD.CbMSGLED = 1
	LAC	SYSTMP0
	ORL	1<<CbPHOLED
	SAH	SYSTMP0
	OUT	SYSTMP0,GPAD
	ADHK	0
	
	RET
;---------------
PHOLED_L:
	LIPK	8

	IN	SYSTMP0,GPAD	;GPAD.CbMSGLED = 0
	LAC	SYSTMP0
	ANDL	~(1<<CbPHOLED)
	SAH	SYSTMP0
	OUT	SYSTMP0,GPAD
	ADHK	0
	
	RET
;---------------
PHOLED_FLASH:
	LIPK	8

	IN	SYSTMP0,GPAD	;GPAD.CbMSGLED = 0
	LAC	SYSTMP0
	XORL	1<<CbPHOLED
	SAH	SYSTMP0
	OUT	SYSTMP0,GPAD
	ADHK	0
	
	RET
.endif
;-------------------------------------------------------------------------------
.END
