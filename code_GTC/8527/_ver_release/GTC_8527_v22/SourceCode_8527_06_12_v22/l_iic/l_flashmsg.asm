.LIST
;-------------------------------------------------------------------------------
;       Function : SEND_MSGNUM
;
;       load new message number,total message number and DAM status into sendbuffer
;       Input  : no
;       Output : no
;-------------------------------------------------------------------------------
SEND_MSGNUM:
;-DAM Full check
	LACK	0X26
	CALL	SEND_DAT
	LAC	ANN_FG
	SFR	13
	ANDK	0X01
	CALL	SEND_DAT
;-new message number
	LACK	0X20
	CALL	SEND_DAT
	LAC	MSG_N
	CALL	SEND_DAT
;-total message number
	LACK	0X21
	CALL	SEND_DAT
	LAC	MSG_T
	CALL	SEND_DAT

;-DAM status
	LACK	0X06
	SAH	SYSTMP0
;-(ANN_FG.13)与(SYSTMP0.0)是正逻辑关系
	;BIT	ANN_FG,13
	;BS	TB,SEND_MSGNUM_3_1
	;LAC	SYSTMP0
	;ANDL	~(1)
	;SAH	SYSTMP0
;SEND_MSGNUM_3_1:
;-(EVENT.9)与(SYSTMP0.1)是反逻辑关系
	BIT	EVENT,9
	BZ	TB,SEND_MSGNUM_3_2
	LAC	SYSTMP0
	ANDL	~(1<<1)
	SAH	SYSTMP0
SEND_MSGNUM_3_2:
;-(EVENT.8)与(SYSTMP0.2)是反逻辑关系
	BIT	EVENT,8
	BZ	TB,SEND_MSGNUM_3_3
	LAC	SYSTMP0
	ANDL	~(1<<2)
	SAH	SYSTMP0
SEND_MSGNUM_3_3:	
	LACK	0X24
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
