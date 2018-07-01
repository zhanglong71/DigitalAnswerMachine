.LIST

;-------------------------------------------------------------------------------
;	Function : RECEBUF_CHK	
;	查接收缓冲是否空(头指针 - 尾指针 = 0/~0 ===>空/不空)
;	input : no
;	output : 0/!0 = 空/不空
;-------------------------------------------------------------------------------
RECEBUF_CHK:
	LAC	RECE_QUEUE
	ANDK	CMASKCODER
	SAH	INT_TTMP1
	LAC	RECE_QUEUE
	SFR	8
	SBH	INT_TTMP1
	
	RET

;-------------------------------------------------------------------------------
;	Function : INT_GETR_DAT	
;	从接收缓冲队列取接收到的数据(用以判断下一步动作)
;-------------------------------------------------------------------------------
INT_GETR_DAT:
	CALL	RECEBUF_CHK
	BS	ACZ,INT_GETR_DAT_EMPT	;NO DAT

	LAC	RECE_QUEUE
	ADHK	1
	ANDL	(CMASKCODER<<8)|(CMASKCODER)
	SAH	RECE_QUEUE

	ANDK	CMASKCODER
	SFR	1
	ADHL	RECE_BUF1		;GET ADDR
	SAH	INT_TTMP1
	
	MAR	+0,1
	LAR	INT_TTMP1,1
	
	LAC	RECE_QUEUE
	ANDK	0X01
	BS	ACZ,INT_GETR_DAT_GET2
	LAC	+0,1			;奇地址
	SFR	8
	ANDL	0X0FF
	RET
INT_GETR_DAT_GET2:			;偶地址

	LAC	+0,1
	ANDL	0X0FF
	RET
INT_GETR_DAT_EMPT:			;队列空
	LACL	0X0FF
	RET

;---------------------------------------
GETR_DAT:
	DINT
	CALL	INT_GETR_DAT
	EINT
	
	RET

;-------------------------------------------------------------------------------
.END
