.LIST
;############################################################################
;	FUNCTION : GET_TELN
;	Get the total number of current TEL group
;	INPUT  : ACCH = the number of total tel-message
;	OUTPUT : ACCH = The total number of NEW TEL current TEL group
;############################################################################
GET_TELN:
	LACL	0XE401
	CALL	DAM_BIOSFUNC
	ANDK	0X7F
	SAH	SYSTMP1
	SAH	SYSTMP2
GET_TELN_LOOP:
	LAC	SYSTMP1
	BS	ACZ,GET_TELN_END	;查完了,退出
	SAH	CONF1
	LACL	0XE705
	CALL	DAM_BIOSFUNC

	LAC	SYSTMP1
	SBHK	1
	SAH	SYSTMP1

	BIT	RESP,1
	BS	TB,GET_TELN_LOOP	;New flag
;--	
	LAC	SYSTMP2
	SBHK	1
	SAH	SYSTMP2
	BS	B1,GET_TELN_LOOP
GET_TELN_END:	
	LAC	SYSTMP2

	RET

;-------------------------------------------------------------------------------
.END
