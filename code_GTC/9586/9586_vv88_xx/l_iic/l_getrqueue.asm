.LIST

;-------------------------------------------------------------------------------
;	Function : RECEBUF_CHK	
;	����ջ����Ƿ��(ͷָ�� - βָ�� = 0/~0 ===>��/����)
;	input : no
;	output : 0/!0 = ��/����
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
;	�ӽ��ջ������ȡ���յ�������(�����ж���һ������)
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
	LAC	+0,1			;���ַ
	SFR	8
	ANDL	0X0FF
	RET
INT_GETR_DAT_GET2:			;ż��ַ

	LAC	+0,1
	ANDL	0X0FF
	RET
INT_GETR_DAT_EMPT:			;���п�
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
