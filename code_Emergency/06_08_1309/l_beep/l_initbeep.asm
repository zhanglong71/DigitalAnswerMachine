.LIST

;-------------------------------------------------------------------------------
;	Function : INITBEEP
;	
;	Generate a warning beep
;-------------------------------------------------------------------------------
INITBEEP:
	LACL	0X2000
	SAH	COMMAND1
	LACK	0
	SAH	COMMAND2
	LACL	CBEEP_COMMAND
	CALL    DAM_BIOSFUNC
        
	LACL	1000
	CALL	DELAY

	LACL	CBEEP_STOP
	CALL    DAM_BIOSFUNC	;beep stop

        RET
;-------------------------------------------------------------------------------
.END
