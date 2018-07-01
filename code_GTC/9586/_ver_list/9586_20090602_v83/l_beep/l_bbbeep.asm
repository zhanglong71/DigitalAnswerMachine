.LIST
;-------------------------------------------------------------------------------
;	Function : BBBEEP
;	
;	Generate three "BEEP"	---BBB
;-------------------------------------------------------------------------------
BBBEEP:
	LACL	0X200C
	CALL	STOR_VP		;B
	LACL	0X005
	CALL	STOR_VP
	LACL	0X200C
	CALL	STOR_VP	
	LACL	0X005
	CALL	STOR_VP
	LACL	0X200C
	CALL	STOR_VP	
	
	RET
;-------------------------------------------------------------------------------
.END
