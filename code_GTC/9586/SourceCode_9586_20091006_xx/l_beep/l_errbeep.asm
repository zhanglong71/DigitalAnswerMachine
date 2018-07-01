.LIST
;-------------------------------------------------------------------------------
;	Function : ERRBEEP
;	
;	Generate three "BEEP"	---±®¥Ì”√
;-------------------------------------------------------------------------------
ERRBEEP:
	LACL	0X200C
	CALL	STOR_VP	
	LACL	0X005
	CALL	STOR_VP
	LACL	0X200C
	CALL	STOR_VP	
	LACL	0X005
	CALL	STOR_VP
	LACL	0X200C
	CALL	STOR_VP
	LACL	0X005
	CALL	STOR_VP
	LACL	0X200C
	CALL	STOR_VP
	LACL	0X005
	CALL	STOR_VP
	LACL	0X200C
	CALL	STOR_VP		;BBBBB
	
	RET
;-------------------------------------------------------------------------------
.END
