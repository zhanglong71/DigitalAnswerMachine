.LIST
	
;############################################################################
;
;       Function : DEL_ONETEL
;	delete the specific telehone number
;
;	INPUT  : ACCH = TEL_ID you will delete
;	OUTPUT : ACCH = 0/~0	 
;############################################################################
DAT_DEL:
DEL_ONETEL:
	SAH	COMMAND1
	
	LACL	0XE500
	CALL	DAM_BIOSFUNC
	SFR	8
	RET
;-------------------------------------------------------------------------------
.END
