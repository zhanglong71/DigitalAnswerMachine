.LIST
;-------------------------------------------------------------------------------
;	Function : SET_DTMFTYPE
;	input : ACCH(0..F)
;	output: ACCH
;-------------------------------------------------------------------------------
SET_DTMFTYPE:
	PSH	CONF
;-------
	SAH	SYSTMP0
;---	
	LACL	0x5F46		;set DTMFTYPE
	CALL	DAM_BIOSFUNC
	LAC	SYSTMP0		; --dB
	CALL	DAM_BIOSFUNC
;------
	POP	CONF
	
	RET
;-------------------------------------------------------------------------------
;	
;-------------------------------------------------------------------------------
CLR_TIMER2:
CLR_2TIMER:
	LACK	0
SET_TIMER2:
SET_2TIMER:
	SAH	TMR_TIMER
	SAH	TMR_TIMER_BAK
	
	RET
;-------------------------------------------------------------------------------
.END
