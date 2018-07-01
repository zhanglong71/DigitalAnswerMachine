.LIST
;-------------------------------------------------------------------------------
;Set byte index-0 data of a specific TEL-message
;	input : ACCH(bit15..8=index,bit7..0=TEL-ID)
;	output: ACCH
;-------------------------------------------------------------------------------
SET_TEL0ID:
	SAH	SYSTMP0
;---
	LAC	SYSTMP0
	ANDL	0XFF
	ORL	0XEE00
	CALL	DAM_BIOSFUNC

	LAC	SYSTMP0
	SFR	8
	ANDL	0XFF
	ORL	0XEE00
	CALL	DAM_BIOSFUNC
	
	RET
;-------------------------------------------------------------------------------
;	FUNCTION : GET_TELN
;	Get the new number of current TEL group
;	INPUT : NO
;	OUTPUT : ACCH = The total number of NEW TEL current TEL group
;-------------------------------------------------------------------------------
GET_TELN:
	LACL	0XE401
	CALL	DAM_BIOSFUNC
	ANDK	0X7F
	SAH	SYSTMP1
	SAH	SYSTMP2
GET_TELN_LOOP:
	LAC	SYSTMP1
	BS	ACZ,GET_TELN_END	;查完了,退出
	ORL	0XEA00
	CALL	DAM_BIOSFUNC

	LAC	SYSTMP1
	SBHK	1
	SAH	SYSTMP1

	LAC	RESP
	ANDL	0XFF00
	BZ	ACZ,GET_TELN_ERROR	;Error 
	BIT	RESP,7
	BS	TB,GET_TELN_LOOP	;New flag exist ?
GET_TELN_ERROR:
;--	
	LAC	SYSTMP2
	SBHK	1
	SAH	SYSTMP2
	BS	B1,GET_TELN_LOOP
GET_TELN_END:	
	LAC	SYSTMP2

	RET
;-------------------------------------------------------------------------------
;	FUNCTION : GET_VIPNTEL
;	Get the number of TEL-message with specific flag current TEL group
;	INPUT : no
;	OUTPUT : ACCH = The total number of VIP TEL current TEL group
;-------------------------------------------------------------------------------
GET_VIPNTEL:
	PSH	SYSTMP1
	PSH	SYSTMP2
;---	
	LACL	0XE401
	CALL	DAM_BIOSFUNC
	ANDK	0X7F
	SAH	SYSTMP1
	LACK	0
	SAH	SYSTMP2
GET_VIPNTEL_LOOP:
	LAC	SYSTMP1
	BS	ACZ,GET_VIPNTEL_END	;无号码,退出
	ORL	0XEA00
	CALL	DAM_BIOSFUNC
	ANDL	0XFF00
	BZ	ACZ,GET_VIPNTEL_END	;Error 
	LAC	RESP
	ANDL	0X83
	SBHL	0X81
	BS	ACZ,GET_VIPNTEL_YES	;new VIP flag exist ?

	BS	B1,GET_VIPNTEL_END
GET_VIPNTEL_YES:	
	LACK	1
	SAH	SYSTMP2
GET_VIPNTEL_END:	
	LAC	SYSTMP2
;---
	POP	SYSTMP2
	POP	SYSTMP1
	ADHK	0

	RET
;-------------------------------------------------------------------------------
.END
