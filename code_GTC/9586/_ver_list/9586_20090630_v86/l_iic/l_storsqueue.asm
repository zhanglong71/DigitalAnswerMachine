.LIST
;-------------------------------------------------------------------------
;	Function : INT_RECE_DAT	

;	�������͵����ݱ�����SEND_BUF1Ϊ����ַSEND_QUEUE(15..8)Ϊƫ�ƵĴ�����
;-------------------------------------------------------------------------
INT_SEND_DAT:			;�жϴ�DAT
	SAH	INT_TTMP1

	LAC	SEND_QUEUE
	ADHL	0X100
	ANDL	(CMASKCODES<<8)|(CMASKCODES)
	SAH	SEND_QUEUE

	LAC	SEND_QUEUE
	SFR	9
	ADHL	SEND_BUF1	;GET ADDR
	SAH	INT_TTMP0
	
	MAR	+0,1
	LAR	INT_TTMP0,1
	
	LAC	SEND_QUEUE
	ANDL	0X100
	BS	ACZ,INT_SEND_DAT2
	
	LAC	+0,1		;���ַ
	ANDL	0XFF
	SAH	+0,1
	
	LAC	INT_TTMP1
	SFL	8
	ANDL	0XFF00
	OR	+0,1
	SAH	+0,1
	BS	B1,INT_SEND_DAT_END
INT_SEND_DAT2:
	LAC	+0,1		;ż��ַ
	ANDL	0XFF00
	OR	INT_TTMP1
	SAH	+0,1
INT_SEND_DAT_END:
	RET
;---------------------------------------
SEND_DAT:	
	DINT
	CALL	INT_SEND_DAT
	CALL	REQ_START
	EINT

	RET
;---------------------------------------

;-------------------------------------------------------------------------------
.END
