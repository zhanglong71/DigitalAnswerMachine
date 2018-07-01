.LIST

;############################################################################
;       Function : SET_TELUSR1ID
;	为新来电项目写入INDEX-1
;
;	input  : ACCH(15..8) = Index-1
;		 ACCH(7..0)  = TEL_ID
;
;	OUTPUT : ACCH
;############################################################################
SET_TELUSR1ID:		;Used as new flag
SET_TELUSRID1:
	SAH	CONF1

	LACL	0XE701
	CALL	DAM_BIOSFUNC
	SFR	8

	RET
;############################################################################
;       Function : GET_TELUSR1ID
;	
;	Get USR-DAT1 with specified TEL_ID in current working group
;	input  : ACCH(7..0)  = TEL_ID
;	OUTPUT : ACCH
;############################################################################
GET_TELUSR1ID:		;Used as new flag
GET_TELUSRID1:
	SAH	CONF1
	
	LACL	0XE705
	CALL	DAM_BIOSFUNC

	RET
;-------------------------------------------------------------------------------
.END
