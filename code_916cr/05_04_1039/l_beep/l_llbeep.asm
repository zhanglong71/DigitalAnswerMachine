.LIST
;-------------------------------------------------------------------------------
;	Function : LLBEEP
;	
;	Generate a "LLONG BEEP"---��ʾ��
;-------------------------------------------------------------------------------	
LLBEEP:
	LACL	0X005
	CALL	STOR_VP
	LACL	0X20FF
	CALL	STOR_VP

	RET
;-------------------------------------------------------------------------------
.END
