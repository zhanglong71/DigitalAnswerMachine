.LIST

;-------------------------------------------------------------------------------
;	Function : PAUBEEP
;	
;	INPUT : ACCH = BEEP LENGTH
;	Generate a warning beep
;-------------------------------------------------------------------------------
PAUBEEP:
	PSH	COMMAND
;---
	SAH	SYSTMP1

	LACL	0X2000		;Fre1
	SAH	COMMAND1
	LACK	0		;Fre2
	SAH	COMMAND2
	LACL	CBEEP_COMMAND	;beep start
	CALL    DAM_BIOSFUNC
	
	LAC	SYSTMP1
	CALL	DELAY
	LACL	0X4400
	CALL    DAM_BIOSFUNC	;beep stop
;---	
	POP	COMMAND
	
	RET
;-------------------------------------------------------------------------------
.END
