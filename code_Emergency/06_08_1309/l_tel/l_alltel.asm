.LIST
;############################################################################
;
;	Function : GET_TELT
;	Get total TEL-message numbers in current group
;	input  : No
;	output : ACCH = the number
;############################################################################	
GET_TELT:
	LACL	0XE400
	CALL	DAM_BIOSFUNC

	RET
;-------------------------------------------------------------------------------
.END
