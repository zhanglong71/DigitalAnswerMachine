.LIST

;-------------------------------------------------------------------------
;	Function : LOAD_CIDVP	
;	input : ACCH = the data you will announce(0,1,2,3,4,5,6,7,8,9)
;
;	output: no
;
;-------------------------------------------------------------------------
LOAD_CIDVP:
	
	LACK	0X005
	CALL	STOR_VP
	
	RET
;-------------------------------------------------------------------------------

.END
	