.LIST

;############################################################################
;	FUNCTION : SET_USR1ID
;	Set message index-1 information
;	INPUT : ACCH = MSG_ID
;	OUTPUT: ACCH = USER INDEX DATA1
;############################################################################
SET_USR1ID:
	ANDL	0XFF
	ORL	0X8E00
	CALL	DAM_BIOSFUNC
	
	RET


;-------------------------------------------------------------------------------
.END
