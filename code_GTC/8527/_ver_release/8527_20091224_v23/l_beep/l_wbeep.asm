.LIST
;-------------------------------------------------------------------------------
;	Function : WBEEP
;	
;	INPUT : ACCH = no
;	Generate a warning bbbeep
;-------------------------------------------------------------------------------
WBEEP:
	PSH	CONF
	NOP
;---B-100MS
	LACL	CBEEP_COMMAND
	CALL    DAM_BIOSFUNC
	LACL	0X2000		;Fre1
	CALL    DAM_BIOSFUNC
	LACK	0		;Fre2
	CALL    DAM_BIOSFUNC
	LACK	100
	CALL	DELAY
	LACL	CBEEP_STOP
	CALL    DAM_BIOSFUNC	;beep stop
;---Delay	
	LACK	40
	CALL	DELAY
;---B-100MS
	LACL	CBEEP_COMMAND
	CALL    DAM_BIOSFUNC
	LACL	0X2000		;Fre1
	CALL    DAM_BIOSFUNC
	LACK	0		;Fre2
	CALL    DAM_BIOSFUNC
	LACK	100
	CALL	DELAY
	LACL	CBEEP_STOP
	CALL    DAM_BIOSFUNC	;beep stop
;---Delay
	LACK	40
	CALL	DELAY
;---B-100MS
	LACL	CBEEP_COMMAND
	CALL    DAM_BIOSFUNC
	LACL	0X2000		;Fre1
	CALL    DAM_BIOSFUNC
	LACK	0		;Fre2
	CALL    DAM_BIOSFUNC
	LACK	100
	CALL	DELAY
	LACL	CBEEP_STOP
	CALL    DAM_BIOSFUNC	;beep stop
	
	POP	CONF
	NOP
	RET
;-------------------------------------------------------------------------------
.END
