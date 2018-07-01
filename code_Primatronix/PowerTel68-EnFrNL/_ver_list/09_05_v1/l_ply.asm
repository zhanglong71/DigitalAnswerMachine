.LIST
;-------------------------------------------------------------------------------
;	Function : MSG_WEEK/MSG_HOUR/MSG_MIN
;	
;-------------------------------------------------------------------------------
MSG_WEEK:
	LAC	MSG_ID
	ORL	0XA300
	CALL	DAM_BIOSFUNC
	
MSG_WEEK_STOR:
	CALL	VP_WEEK
	
	RET
;---------------------------------------
MSG_HOUR:
	LAC	MSG_ID
	ORL	0XA200
	CALL	DAM_BIOSFUNC
	SAH	SYSTMP0

	CALL	GET_LANGUAGE
	SBHK	1
	BS	ACZ,MSG_HOUR_FR
	SBHK	1
	BS	ACZ,MSG_HOUR_DE

;MSG_HOUR_STOR:
	LAC	SYSTMP0
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
;---------
MSG_HOUR_DE:
	LAC	SYSTMP0
	SBHK	1
	BS	ACZ,MSG_HOUR_DE_1HOUR
MSG_HOUR_FR:
	LAC	SYSTMP0		;Announce CURRENT hour
	ANDK	0X7F
	CALL	ANNOUNCE_NUM

	CALL	ANN_HOUR

	RET
	
MSG_HOUR_DE_1HOUR:	
	LACL	0XFF00|VOPIDX_NL_ein
	CALL	STOR_VP
	CALL	ANN_HOUR
	
	RET
;-----------------------------
MSG_MIN:
	LAC	MSG_ID
	ORL	0XA100
	CALL	DAM_BIOSFUNC
	BS	ACZ,MSG_MIN_END	;0²»·¢Éù
	CALL	ANNOUNCE_NUM
MSG_MIN_END:
	RET
;---

;---------------------------------------
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

;-------------------------------------------------------------------------------	

;-------------------------------------------------------------------------------
.END
