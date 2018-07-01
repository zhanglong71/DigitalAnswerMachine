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
.END
