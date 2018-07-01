.LIST

;############################################################################
;       Function : SET_TELUSR1ID
;	为新来电项目写入INDEX-1
;
;	input  : ACCH = (COMMAND1)TEL_ID
;		 COMMAND2 =  Index-0
;
;	OUTPUT : ACCH
;############################################################################
SET_TELUSR1ID:		;Used as new flag
SET_TELUSRID1:
	SAH	COMMAND1

	LACL	0XE700
	CALL	DAM_BIOSFUNC
	
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
	SAH	COMMAND1
	
	LACL	0XE800
	CALL	DAM_BIOSFUNC
	
	RET
;-------------------------------------------------------------------------------
.END
