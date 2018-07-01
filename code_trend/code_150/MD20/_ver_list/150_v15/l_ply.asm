.LIST
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;	Function : MSG_WEEK/MSG_GWEEK
;
;	Generate a VP
;-------------------------------------------------------------------------------
MSG_WEEKNEW:	;for English
	LAC	MSG_ID
	ANDL	0X0FF
	ORL	0XA380
	CALL	DAM_BIOSFUNC
	BS	B1,MSG_WEEK_STOR
MSG_WEEK:	;for English
	LAC	MSG_ID
	ANDL	0X0FF
	ORL	0XA300
	CALL	DAM_BIOSFUNC
MSG_WEEK_STOR:
	CALL	GET_LANGUAGE
	BZ	ACZ,MSG_GWEEK
	
	LAC	RESP
	ADHK	28
	ORL	0XFF00
	CALL	STOR_VP
	
	RET
;---------------
MSG_GWEEK:	;for German
	LAC	RESP
	ADHK	92			;92 = 28+64
	ORL	0XFF00
	CALL	STOR_VP
	
	RET
;//----------------------------------------------------------------------------
;//       Function : MSG_HOUR/MSG_GHOUR
;//
;//       Generate a VP
;//----------------------------------------------------------------------------
MSG_HOURNEW:
	LAC	MSG_ID
	CALL	GET_MSGHOURNEW
	SAH	SYSTMP1
	BS	B1,MSG_HOUR_STOR
MSG_HOUR:	;for English/German
	LAC	MSG_ID
	CALL	GET_MSGHOUR
	SAH	SYSTMP1
MSG_HOUR_VPCHK:	
MSG_HOUR_STOR:	
	CALL	GET_LANGUAGE
	BZ	ACZ,MSG_GHOUR	
	
	BIT	EVENT,11
	BS	TB,MSG_HOUR_12
	
	LAC	SYSTMP1
	CALL	ANNOUNCE_NUM
	RET
MSG_GHOUR:
	LAC	SYSTMP1
	BS	ACZ,MSG_GHOUR_NULL
	SBHK	1
	BS	ACZ,MSG_GHOUR_EIN
	
	LAC	SYSTMP1
	CALL	ANNOUNCE_NUM
	BS	B1,MSG_GHOUR_HUR
MSG_GHOUR_NULL:	
	LACK	102		;null(64+38)
	ORL	0XFF00
	CALL	STOR_VP
	BS	B1,MSG_GHOUR_HUR
MSG_GHOUR_EIN:
	LACK	99		;ein(64+35)
	ORL	0XFF00
	CALL	STOR_VP
MSG_GHOUR_HUR:	
	LACK	110		;Uhr(64+46)
	ORL	0XFF00
	CALL	STOR_VP
	
	RET
;-------	
MSG_HOUR_12:
	LAC	SYSTMP1
	BS	ACZ,MSG_HOUR_12_0
	SBHK	12
	BS	ACZ,MSG_HOUR_12_12
	BS	SGN,MSG_HOUR_12_AM
	
	CALL	ANNOUNCE_NUM	;13..23
	
	RET
MSG_HOUR_12_0:			;0,12
MSG_HOUR_12_12:
	LACK	12
	CALL	ANNOUNCE_NUM

	RET

MSG_HOUR_12_AM:			;1..11
	LAC	SYSTMP1
	CALL	ANNOUNCE_NUM

	RET
;//----------------------------------------------------------------------------
;//       Function : MSG_MIN/MSG_GMIN
;//
;//       Generate a VP
;//----------------------------------------------------------------------------
MSG_MINNEW:
	LAC	MSG_ID
	CALL	GET_MSGMINUTENEW
	SAH	SYSTMP1
	BS	B1,MSG_MIN_STOR
MSG_MIN:
	LAC	MSG_ID
	CALL	GET_MSGMINUTE
	SAH	SYSTMP1
MSG_MIN_STOR:	
	CALL	GET_LANGUAGE
	BZ	ACZ,MSG_GMIN

	LAC	SYSTMP1
	CALL	ANNOUNCE_NUM
	
	BIT	EVENT,11
	BS	TB,MSG_MIN_12_CHK
	
	RET
MSG_GMIN:		;德语规则不报零分
	LAC	SYSTMP1
	BS	ACZ,MSG_GMIN_RET
	CALL	ANNOUNCE_NUM
MSG_GMIN_RET:	
	RET	

MSG_MIN_12_CHK:		;英语12小时制用以判断AM/PM
	LAC	MSG_ID
	CALL	GET_MSGHOUR
	SAH	SYSTMP1
MSG_MIN_12:		;通过小时值(SYSTMP1)判断AM/PM
	LAC	SYSTMP1
	BS	ACZ,MSG_MIN_AM
	SBHK	12
	BZ	SGN,MSG_MIN_PM
MSG_MIN_AM:
	LACK	35	;AM
	ORL	0XFF00
	CALL	STOR_VP
	RET
MSG_MIN_PM:
	LACK	36	;PM
	ORL	0XFF00
	CALL	STOR_VP
	RET
;############################################################################
;	get MONTH message with specific MSG_ID
;	FUNCTION : GET_MSGMONTH
;
;	input : ACCH = MSG_ID
;	output: ACCH = MONTH
;############################################################################
GET_MSGMONTH:
	ANDK	0X7F
	ORL	0XAD00
	CALL	DAM_BIOSFUNC

	RET
GET_MSGMONTHNEW:
	ANDK	0X7F
	ORL	0XAD80
	CALL	DAM_BIOSFUNC

	RET

;############################################################################
;	get DAY message with specific MSG_ID
;	FUNCTION : GET_MSGDAY
;
;	input : ACCH = MSG_ID
;	output: ACCH = DAY
;############################################################################
GET_MSGDAY:
	ANDK	0X7F
	ORL	0XAE00 
	CALL	DAM_BIOSFUNC

	RET
GET_MSGDAYNEW:
	ANDK	0X7F
	ORL	0XAE80 
	CALL	DAM_BIOSFUNC

	RET
;############################################################################
;	get HOUR message with specific MSG_ID
;	FUNCTION : GET_MSGHOUR/GET_MSGHOURNEW
;
;	input : ACCH = MSG_ID
;	output: ACCH = HOUR
;############################################################################
GET_MSGHOUR:
	ANDK	0X7F
	ORL	0XA200  
	CALL	DAM_BIOSFUNC

	RET
GET_MSGHOURNEW:
	ANDK	0X7F
	ORL	0XA280  
	CALL	DAM_BIOSFUNC

	RET
;############################################################################
;	get MINUTE message with specific MSG_ID
;	FUNCTION : GET_MSGMINUTE
;
;	input : ACCH = MSG_ID
;	output: ACCH = MINUTE
;############################################################################
GET_MSGMINUTE:
	ANDK	0X7F
	ORL	0XA100
	CALL	DAM_BIOSFUNC

	RET
GET_MSGMINUTENEW:
	ANDK	0X7F
	ORL	0XA180
	CALL	DAM_BIOSFUNC

	RET
;-------------------------------------------------------------------------------
.END
