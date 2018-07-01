.LIST

;-------------------------------------------------------------------------------
;	Function : INT_TESTR_DAT	
;	从接收缓冲队列取接收到的数据(用以判断下一步动作)
;-------------------------------------------------------------------------------
INT_TESTR_DAT:
	CALL	RECEBUF_CHK
	BS	ACZ,INT_TESTR_DAT_EMPT	;NO DAT

	LAC	RECE_QUEUE
	ADHK	1
	ANDL	(CMASKCODER<<8)|(CMASKCODER)
	SAH	INT_TTMP0

	ANDK	CMASKCODER
	SFR	1
	ADHL	RECE_BUF1		;GET ADDR
	SAH	INT_TTMP1
	
	MAR	+0,1
	LAR	INT_TTMP1,1
	
	LAC	INT_TTMP0
	ANDK	0X01
	BS	ACZ,INT_TESTR_DAT_GET2
	LAC	+0,1			;奇地址
	SFR	8
	ANDL	0X0FF
	RET
INT_TESTR_DAT_GET2:			;偶地址

	LAC	+0,1
	ANDL	0X0FF
	RET
INT_TESTR_DAT_EMPT:			;队列空
	LACL	0X0FF
	RET

;---------------------------------------
TESTGETR_DAT:
	DINT
	CALL	INT_TESTR_DAT
	EINT
	
	RET

;-------------------------------------------------------------------------------
.END
