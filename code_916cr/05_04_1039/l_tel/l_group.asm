.LIST
;############################################################################
;
;	Function : DAT_WRITE
;	save the DAT in working group
;	input  : ACCH = the dat write
;	output : ACCH = error code
;############################################################################	
SET_TELGROUP:
	ANDK	0X01F
	ORL	0XE600
	CALL	DAM_BIOSFUNC

	RET
;-------------------------------------------------------------------------------
.END
