.LIST

;-------------------------------------------------------------------------------
;	Function : PAUBEEP
;	
;	INPUT : ACCH = BEEP LENGTH
;	Generate a warning beep
;-------------------------------------------------------------------------------
PAUBEEP:
	PSH	CONF
;---
	SAH	SYSTMP1

	LACL	CBEEP_COMMAND	;beep start
	CALL    DAM_BIOSFUNC
	LACL	0X2000		;Fre1
	CALL    DAM_BIOSFUNC
	LACK	0		;Fre2
	CALL    DAM_BIOSFUNC
	LAC	SYSTMP1
	CALL	DELAY
	LACL	0X4400
	CALL    DAM_BIOSFUNC	;beep stop
;---	
	POP	CONF
	
	RET
;-------------------------------------------------------------------------------
.END
