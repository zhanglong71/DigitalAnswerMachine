.LIST
;############################################################################
;	FUNCTION : GET_TELN
;	Get the new Tel-message number in current group
;	INPUT  : No
;	OUTPUT : ACCH = The number of NEW Tel-message in current TEL group
;############################################################################
GET_TELN:
	LACL	0XE401
	CALL	DAM_BIOSFUNC
	
	RET

;-------------------------------------------------------------------------------
.END
