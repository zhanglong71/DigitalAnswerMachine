.LIST
;-------------------------------------------------------------------------------
;       Function : SEND_RECSTART
;
;       Input  : ACCH
;       Output : no
;-------------------------------------------------------------------------------
SEND_RECSTART:
	SAH	SYSTMP0
;---
	LACK	0X12
	CALL	SEND_DAT
	LAC	SYSTMP0
	CALL	SEND_DAT
	
	RET

;-------------------------------------------------------------------------------
;       Function : SEND_MFULL
;
;       Input  : no
;       Output : no
;-------------------------------------------------------------------------------
SEND_MFULL:
	LACK	0X18
	CALL	SEND_DAT
	LACK	0X18
	CALL	SEND_DAT
	
	RET

;-------------------------------------------------------------------------------
.END
