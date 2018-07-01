.LIST

;-------------------------------------------------------------------------------
;       Function : SEND_MSGNUM
;
;       load new message number,total message number and DAM status into sendbuffer
;       Input  : no
;       Output : no
;-------------------------------------------------------------------------------
SEND_MSGNUM:
;-new message number
	LACK	CMDT_NewMessage
	CALL	SEND_DAT
	LAC	MSG_N
	CALL	SEND_DAT
;-total message number
	LACK	CMDT_TotalMessage
	CALL	SEND_DAT
	LAC	MSG_T
	CALL	SEND_DAT
;-DAM status
EXIT_TOIDLE:	;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XC1
	SAH	SYSTMP0
;-(ANN_FG.13)与(SYSTMP0.6)是正逻辑关系
	BIT	ANN_FG,13
	BS	TB,SEND_MSGNUM_3_1
	LAC	SYSTMP0
	ANDL	~(1<<6)
	SAH	SYSTMP0
SEND_MSGNUM_3_1:
;-(EVENT.9)与(SYSTMP0.7)是正逻辑关系
	BIT	EVENT,9
	BS	TB,SEND_MSGNUM_3_2
	LAC	SYSTMP0
	ANDL	~(1<<7)
	SAH	SYSTMP0
SEND_MSGNUM_3_2:
;-(EVENT.8)与(SYSTMP03..0)
	BIT	EVENT,8
	BZ	TB,SEND_MSGNUM_3_3
	LAC	SYSTMP0
	ANDL	0XF0
	ORK	0X02
	SAH	SYSTMP0
SEND_MSGNUM_3_3:	
	LACK	CMDT_ExitToIdle
	CALL	SEND_DAT
	LAC	SYSTMP0
	CALL	SEND_DAT
;-
	RET
;-------------------------------------------------------------------------------
;       Function : SEND_MSGID
;
;       load new message number,total message number and DAM status into sendbuffer
;       Input  : no
;       Output : no
;-------------------------------------------------------------------------------
SEND_MSGID:
	LACK	CMDT_StartPlay
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

	RET
;-------------------------------------------------------------------------------
;       Function : SEND_MSGATTNEW
;
;       load new message number,total message number and DAM status into sendbuffer
;       Input  : no
;       Output : no
;-------------------------------------------------------------------------------
SEND_MSGATTNEW:

	RET
;-------------------------------------------------------------------------------
.END
