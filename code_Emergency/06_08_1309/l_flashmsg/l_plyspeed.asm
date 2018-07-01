.LIST
;-------------------------------------------------------------------------------
;	Function : SET_PLYPSA
;	Set PSA duing playing
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
SET_PLYPSA:
	PSH	COMMAND
;-------	
	SAH	SYSTMP0
;---
	LACL	0X5F45
	CALL	DAM_BIOSFUNC
	LAC	SYSTMP0
	CALL	DAM_BIOSFUNC
;-------
	POP	COMMAND

	RET
;-------------------------------------------------------------------------------
.END
