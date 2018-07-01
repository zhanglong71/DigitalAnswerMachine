.LIST
;-------------------------------------------------------------------------------
SEND_PBOOK:
	SAH	SYSTMP0
	
	LACK	0X03
	CALL	SEND_DAT
	LAC	SYSTMP0
	CALL	SEND_DAT
	
	RET

;-------------------------------------------------------------------------------
;SEND_TCID:
SEND_MISSCID:
	SAH	SYSTMP0
	
	LACK	0X04
	CALL	SEND_DAT
	LAC	SYSTMP0
	CALL	SEND_DAT
	
	RET
;-------------------------------------------------------------------------------
SEND_ANSWCID:
	SAH	SYSTMP0
	
	LACK	0X05
	CALL	SEND_DAT
	LAC	SYSTMP0
	CALL	SEND_DAT
	
	RET
;-------------------------------------------------------------------------------
SEND_DIALCID:
	SAH	SYSTMP0
	
	LACK	0X06
	CALL	SEND_DAT
	LAC	SYSTMP0
	CALL	SEND_DAT
	
	RET
;-------------------------------------------------------------------------------
SEND_NEWCID:
	SAH	SYSTMP0
	
	LACK	0X07
	CALL	SEND_DAT
	LAC	SYSTMP0
	CALL	SEND_DAT
	
	RET
;-------------------------------------------------------------------------------
SEND_TELOK:
	SAH	SYSTMP0
	
	LACK	0X1A
	CALL	SEND_DAT
	LAC	SYSTMP0
	CALL	SEND_DAT
	
	RET
;-------------------------------------------------------------------------------
SEND_DSPSTAT:
	SAH	SYSTMP0
	
	LACK	0X1C
	CALL	SEND_DAT
	LAC	SYSTMP0
	CALL	SEND_DAT
	
	RET
;-------------------------------------------------------------------------------
.END
