.LIST

;-------------------------------------------------------------------------------
;	Function : INITBEEP
;	
;	Generate a warning beep
;-------------------------------------------------------------------------------
INITBEEP:
	LACL	CBEEP_COMMAND
	CALL    DAM_BIOSFUNC
        
	LACL	0X2000
	CALL    DAM_BIOSFUNC
	LACK	0
	CALL    DAM_BIOSFUNC
	
	LACL	1000
	CALL	DELAY

	LACL	CBEEP_STOP
	CALL    DAM_BIOSFUNC	;beep stop

        RET
;-------------------------------------------------------------------------------
.END
