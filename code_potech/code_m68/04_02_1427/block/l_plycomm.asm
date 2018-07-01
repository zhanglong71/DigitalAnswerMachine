.LIST
;-------------------------------------------------------------------------------
;       Function : SEND_MSGID
;
;       load new message number,total message number and DAM status into sendbuffer
;       Input  : no
;       Output : no
;-------------------------------------------------------------------------------
SEND_MSGID:
	LACK	0X10
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
.if	0
;---MSG year
	LAC	MSG_ID
	ORL	0XAA00
	CALL	DAM_BIOSFUNC	;录音之前写入的年份差
	SAH	SYSTMP0

	LAC	MSG_ID
	ORL	0XAC00
	CALL	DAM_BIOSFUNC
	ADH	SYSTMP0		;加入修正
	SAH	SYSTMP0

	LACK	0X4C
	CALL	SEND_DAT
	LAC	SYSTMP0
	CALL	SEND_DAT
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
.endif	
	RET
;-------------------------------------------------------------------------------
;       Function : SEND_MSGATTNEW
;
;       load new message number,total message number and DAM status into sendbuffer
;       Input  : no
;       Output : no
;-------------------------------------------------------------------------------
SEND_MSGATTNEW:
.if	0
;---MSG year
	LAC	MSG_ID
	ORL	0XAA80
	CALL	DAM_BIOSFUNC	;录音之前写入的年份差
	SAH	SYSTMP0

	LAC	MSG_ID
	ORL	0XAC80
	CALL	DAM_BIOSFUNC
	ADH	SYSTMP0		;加入修正
	SAH	SYSTMP0

	LACK	0X4C
	CALL	SEND_DAT
	LAC	SYSTMP0
	CALL	SEND_DAT
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
.endif	
	RET

;-------------------------------------------------------------------------------
.END
