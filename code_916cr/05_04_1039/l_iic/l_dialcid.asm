.LIST
;-------------------------------------------------------------------------------
;       Function : SEND_DIALCID
;	
;	the number of dialcid
;       Input  : ACCH
;       Output : no
;-------------------------------------------------------------------------------
SEND_DIALCID:
	SAH	SYSTMP0
	
	LACK	CMDT_DialedCall
	CALL	SEND_DAT
	LAC	SYSTMP0
	CALL	SEND_DAT
	
	RET
;-------------------------------------------------------------------------------
.END
