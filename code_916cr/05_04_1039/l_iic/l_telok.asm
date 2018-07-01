.LIST
;-------------------------------------------------------------------------------
;       Function : SEND_MISSCID
;	
;	the number of misscid
;       Input  : ACCH
;       Output : no
;-------------------------------------------------------------------------------
SEND_TELOK:
	SAH	SYSTMP0
	
	LACK	CMDT_TELSendOK
	CALL	SEND_DAT
	LAC	SYSTMP0
	CALL	SEND_DAT
	
	RET
;-------------------------------------------------------------------------------
.END
