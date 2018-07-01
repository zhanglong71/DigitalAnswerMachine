.LIST
;-------------------------------------------------------------------------------
;       Function : SEND_DSPSTAT
;	
;	dsp iic status
;       Input  : ACCH
;       Output : no
;-------------------------------------------------------------------------------
SEND_DSPSTAT:
	SAH	SYSTMP0
	
	LACK	CMDT_DSPStatus
	CALL	SEND_DAT
	LAC	SYSTMP0
	CALL	SEND_DAT
	
	RET
;-------------------------------------------------------------------------------
.END
