.LIST
;-------------------------------------------------------------------------------
;       Function : SEND_MSGATT
;
;       load new message number,total message number and DAM status into sendbuffer
;       Input  : no
;       Output : no
;-------------------------------------------------------------------------------
SEND_MSGID:
	LACK	0X23
	CALL	SEND_DAT
	LAC	MSG_ID
	CALL	SEND_DAT
	
	RET
;-------------------------------------------------------------------------------
;       Function : SEND_MSGATT
;
;       load new message number,total message number and DAM status into sendbuffer
;       Input  : no
;       Output : no
;-------------------------------------------------------------------------------
SEND_MSGATT:
;---MSG year
	;LAC	MSG_ID
	;ORL	0XAC00
	;CALL	DAM_BIOSFUNC
	;ADH	TMR_YEAR	;加入修正
	;SAH	SYSTMP0

	;LACK	0X4C
	;CALL	SEND_DAT
	;LAC	SYSTMP0
	;CALL	SEND_DAT
;---MSG mouth
	LAC	MSG_ID
	ORL	0XAD00
	CALL	DAM_BIOSFUNC
	SAH	SYSTMP0

	LACK	0X46
	CALL	SEND_DAT
	LAC	SYSTMP0
	CALL	SEND_DAT
;---MSG date
	LAC	MSG_ID
	ORL	0XAE00
	CALL	DAM_BIOSFUNC
	SAH	SYSTMP0

	LACK	0X47
	CALL	SEND_DAT
	LAC	SYSTMP0
	CALL	SEND_DAT
;---MSG hour
	LAC	MSG_ID
	ORL	0XA200
	CALL	DAM_BIOSFUNC
	SAH	SYSTMP0

	LACK	0X48
	CALL	SEND_DAT
	LAC	SYSTMP0
	CALL	SEND_DAT
;---MSG minute
	LAC	MSG_ID
	ORL	0XA100
	CALL	DAM_BIOSFUNC
	SAH	SYSTMP0

	LACK	0X49
	CALL	SEND_DAT
	LAC	SYSTMP0
	CALL	SEND_DAT
	
	RET
;-------------------------------------------------------------------------------
;       Function : SEND_MSGATTNEW
;
;       load new message number,total message number and DAM status into sendbuffer
;       Input  : no
;       Output : no
;-------------------------------------------------------------------------------
SEND_MSGATTNEW:
;---MSG year
	;LAC	MSG_ID
	;ORL	0XAC00
	;CALL	DAM_BIOSFUNC
	;ADH	TMR_YEAR	;加入修正
	;SAH	SYSTMP0

	;LACK	0X4C
	;CALL	SEND_DAT
	;LAC	SYSTMP0
	;CALL	SEND_DAT
;---MSG mouth
	LAC	MSG_ID
	ORL	0XAD80
	CALL	DAM_BIOSFUNC
	SAH	SYSTMP0

	LACK	0X46
	CALL	SEND_DAT
	LAC	SYSTMP0
	CALL	SEND_DAT
;---MSG date
	LAC	MSG_ID
	ORL	0XAE80
	CALL	DAM_BIOSFUNC
	SAH	SYSTMP0

	LACK	0X47
	CALL	SEND_DAT
	LAC	SYSTMP0
	CALL	SEND_DAT
;---MSG hour
	LAC	MSG_ID
	ORL	0XA280
	CALL	DAM_BIOSFUNC
	SAH	SYSTMP0

	LACK	0X48
	CALL	SEND_DAT
	LAC	SYSTMP0
	CALL	SEND_DAT
;---MSG minute
	LAC	MSG_ID
	ORL	0XA180
	CALL	DAM_BIOSFUNC
	SAH	SYSTMP0

	LACK	0X49
	CALL	SEND_DAT
	LAC	SYSTMP0
	CALL	SEND_DAT
	
	RET
;-------------------------------------------------------------------------------
;	Function : MSG_WEEK/MSG_HOUR/MSG_MIN
;	
;-------------------------------------------------------------------------------
MSG_WEEKNEW:
	LAC	MSG_ID
	ORL	0XA380
	CALL	DAM_BIOSFUNC
	BS	B1,MSG_WEEK_STOR
MSG_WEEK:
	LAC	MSG_ID
	ORL	0XA300
	CALL	DAM_BIOSFUNC
MSG_WEEK_STOR:
	ADHK	30
	ORL	0XFF00
	CALL	STOR_VP
	
	RET
;---
MSG_HOURNEW:
	LAC	MSG_ID
	ORL	0XA280
	CALL	DAM_BIOSFUNC
	BS	B1,MSG_HOUR_STOR
MSG_HOUR:
	LAC	MSG_ID
	ORL	0XA200
	CALL	DAM_BIOSFUNC
MSG_HOUR_STOR:
	SAH	SYSTMP0
	BS	ACZ,MSG_HOUR_0		;0
	SBHK	12
	BS	ACZ,MSG_HOUR_12		;12
	BS	SGN,MSG_HOUR_LESS12	;1,2,3,4,5,6,7,8,9,10,11,
;---	
	SAH	SYSTMP0			;13,14,15,16,17,18,19,20,21,22,23
	BS	B1,MSG_HOUR_LESS12
MSG_HOUR_0:
MSG_HOUR_12:
	LACK	12	
MSG_HOUR_EXE:
	CALL	ANNOUNCE_NUM
	
	RET
MSG_HOUR_LESS12:
	LAC	SYSTMP0
	BS	B1,MSG_HOUR_EXE
;---

MSG_MINNEW:
	LAC	MSG_ID
	ORL	0XA180
	CALL	DAM_BIOSFUNC
	BS	B1,MSG_MIN_STOR
MSG_MIN:
	LAC	MSG_ID
	ORL	0XA100
	CALL	DAM_BIOSFUNC
MSG_MIN_STOR:
	BS	ACZ,MSG_MIN_END	;0不发声
	CALL	ANNOUNCE_NUM
MSG_MIN_END:
	RET
;---
;---------------
MSG_AMPMNEW:
	LAC	MSG_ID
	ORL	0XA280
	CALL	DAM_BIOSFUNC
	BS	B1,AM_PM_STOR
MSG_AMPM:
;---Get hour
	LAC	MSG_ID
	ORL	0XA200
	CALL	DAM_BIOSFUNC
AM_PM_STOR:
	SBHK	12
	BS	SGN,MSG_MIN_AM
;MSG_MIN_PM
	CALL	VP_PM	
	RET
MSG_MIN_AM:
	CALL	VP_AM	
	RET

;---------------
;	input : no
;	output: no
;---------------
VP_AM:
	LACL	0XFF00|54
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_PM:
	LACL	0XFF00|55
	CALL	STOR_VP
	RET
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
;-------------------------------------------------------------------------------	

;-------------------------------------------------------------------------------
.END
