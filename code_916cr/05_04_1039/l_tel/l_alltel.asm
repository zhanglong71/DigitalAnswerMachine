.LIST
;############################################################################
;
;	Function : DAT_WRITE
;	save the DAT in working group
;	input  : ACCH = the dat write
;	output : ACCH = error code
;############################################################################	
GET_TELT:
	LACL	0XE401
	CALL	DAM_BIOSFUNC

	RET
;-------------------------------------------------------------------------------
.END
