.LIST

;############################################################################
;	FUNCTION : SET_DELMARK
;	INPUT : ACCH = MSG_ID     
;	OUTPUT: NO
;############################################################################
SET_DELMARK:
	ANDK	0X7F
	ORL	0X2080
	CALL	DAM_BIOSFUNC

	RET
;############################################################################
;	FUNCTION : SET_DELMARKNEW
;	INPUT : ACCH = MSG_ID(the MSG_ID is related to new messages)  
;	OUTPUT: NO
;############################################################################
SET_DELMARKNEW:
	ANDK	0X7F
	ORL	0X2480
	CALL	DAM_BIOSFUNC

	RET

;############################################################################
;	FUNCTION : REAL_DEL
;	INPUT : NO
;	OUTPUT: NO
;############################################################################
REAL_DEL:
	LACL	0X6100
	CALL	DAM_BIOSFUNC
	
	RET
;-------------------------------------------------------------------------------
.END
