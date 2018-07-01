.LIST
;-------------------------------------------------------------------------------
;       Function : SEND_TOTALCID
;	
;	the number of misscid
;       Input  : ACCH
;       Output : no
;-------------------------------------------------------------------------------
SEND_TOTALCID:
	SAH	SYSTMP0
	
	LACK	CMDT_TotalCall
	CALL	SEND_DAT
	LAC	SYSTMP0
	CALL	SEND_DAT
	
	RET
;-------------------------------------------------------------------------------
;       Function : SEND_NEWCID
;	
;	the number of new cid
;       Input  : ACCH
;       Output : no
;-------------------------------------------------------------------------------
SEND_NEWCID:
	SAH	SYSTMP0
	
	LACK	CMDT_NewCall
	CALL	SEND_DAT
	LAC	SYSTMP0
	CALL	SEND_DAT
	
	RET
;-------------------------------------------------------------------------------
.END
