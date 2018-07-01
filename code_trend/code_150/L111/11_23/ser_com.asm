;���ն���ֽ�����2006-7-13 10:15
.LIST
;Auxiliary Registers ALL use AR0
;-------BELOWS ARE FOR SIO BETWEEN DSP AND 78806---------------------
;BIOR:	bit4=SDI=dat(DSP<==>CPU,DSP R/T from this port)
;	bit5=SDO=wr(CPU==>DSP,DSP receive command from this port,contral by CPU)
;	bit6=TRX=clk(CPU==>DSP,DSP receive clock from this port,contral by CPU)
;-------(��¼����״̬��־)---------
;TRS_FG:	bit0..3��¼�Ѵ���/���յ�λ�ĸ���(clk�������)
;		bit4 = reserved
;		bit5 = 1---�½��ش���,�ⲿ�жϱ�־
;		bit6 = 1---��������(����ǰ�Ķ���,ͬʱDAT = low)
;		bit7 = 1---����(�����Ƕ��ֽ�����)��������ִ��,���ձ�־
;		bit8 =
;		bit9 = 1---�ֽڷ���״̬.(һ���ֽڴ�bit7��bit0�ڴ�״̬)
;		bit10= 1---��������ǰ��ĵȴ�״̬
;		BIT11= 1---�շ���Ч(WR=LOWʱ��1)
;		bit12= 1---������ʱ,���ɷ��͵Ŀ���״̬(��ʱ���ɷ���,���ɽ���)
;		bit13= 1---
;TMR_TR:��¼�ϴ�λ���͵����ڵ�ʱ����;������һ�ֽں�,��¼�����ϴ��ֽڵ����ڵ�ʱ��
;-------
;SIO_CNT:	bit0..7��¼�Ѵ���/���յ�λ�ĸ���
;		bit8..11��¼�ѽ����ֽڸ���(����״̬)---���ѷ��͵��ֽڸ���(����״̬)
TEXT_CLOCK	.EQU   		0	;0===>����ģ��CLOCK
TEXT_WR		.EQU   		1	;1===>��Ч��λ������,ͨѸ��
;-------------------------------------------------------------------------------
.if	0
END_BIT		.EQU   		2	;>1ms - last bit to return idel(FOR DAT)
REQ_SEND	.EQU   		1	;1ms - 8
END_SEND	.EQU   		3	;3ms - end of send(8ms)
WAIT_TMR	.EQU   		3	;3ms
INIT_TMR	.EQU   		4	;4ms
MAX_TMR		.EQU   		5	;5ms
.ENDIF
;---------------
.if	1
;---TMR_1MS = 0ʱ
END_BIT		.EQU   		10	;>1ms - last bit to return idel(FOR DAT)
REQ_SEND	.EQU   		8	;1ms - 8
END_SEND	.EQU   		24	;3ms - end of send(8ms)
WAIT_TMR	.EQU   		24	;3ms
INIT_TMR	.EQU   		32	;4ms
MAX_TMR		.EQU   		40	;5ms
.ENDIF
;-------------------------------------------------------------------------------

.INCLUDE mx111S4.INC
.INCLUDE reg2523b.inc
.INCLUDE CONST.INC

.global	SER_TMR
.global	SER_DET
.global	SER_EXE
.global	SER_CLK
.global	STOR_DAT

.extern	INT_STOR_MSG

.org 0xfe30
;-------------------------------------------------------
;	Function : RECEIVE
;	receive data from BIOR.4
;	receive from STARTBIT to bit7 to bit0 end in ENDBIT
;-------------------------------------------------------
RECEIVE:
	BIT	TRS_FG,7
	BZ	TB,RECEIVE_END2

	LAC	RECE_BUF
	SFL	1
	SAH	RECE_BUF
	
	LIPK	0
	CALL	DAT_IDEL
	NOP
	IN	INT_TTMP0,BIOR
	LAC	INT_TTMP0
	ANDL	0X010
	SFR	4
	OR	RECE_BUF	;receive data from BIOR.4 and store it in RECE_BUF.0
	SAH	RECE_BUF

	LAC	TRS_FG	;;;;;;;;;;;;;
	ANDK	0X0F
	SBHK	8
	BZ	ACZ,RECEIVE_END1
	
RECEIVE1:	
;-------�������յ���һ���ֽ�(�����ջ���ռ䲻����,�ɼ�����������)--------
	
	LAC	RECE_BUF
	ANDL	0XFF
	CALL	INT_RECE_DAT

	LAC	SIO_CNT
	ADHL	0X0100
	SAH	SIO_CNT		;received byte increase one(count11..8)

	LAC	TRS_FG
	ANDL	0XFFF0
	SAH	TRS_FG	;;;;;;;;;;;;;

RECEIVE_END1:
	LACK	0
	SAH	TMR_TR		;λ���ռ�ʱ��λ

RECEIVE_END2:	
	RET
;-------------------------------------------------------
;	Function : TRANSMIT
;	send data from BIOR.4
;	send from bit7 to bit0
;-------------------------------------------------------
TRANSMIT:
	BIT	TRS_FG,9
	BZ	TB,TRANSMIT_END1	
	
	CALL	SEND_BIT
	
	LAC	TRS_FG
	ANDK	0X0F
	SBHK	8
	BZ	ACZ,TRANSMIT_END
	
	LAC	TRS_FG
	ANDL	0XFFF0
	SAH	TRS_FG	;;;;;;;;;;;;;

	CALL	INT_GET_DAT	;ȡ����
	SAH	RECE_BUF
	
	BIT	TRS_FG,6		;��DSP��������(CPU����clock=BIOR.6=0?)
	BZ	TB,TRANSMIT_BUFEMPTY	;�������
	
	LAC	RECE_BUF
	XORL	0X0FF
	BS	ACZ,TRANSMIT_TEND	;�ȴ�
	
	CRAM	TRS_FG,10
	CRAM	TRS_FG,6

	BS	B1,TRANSMIT_END
TRANSMIT_BUFEMPTY:	;��������
	CRAM	TRS_FG,9
	
	LACL	CBUF_EMPTY		;֪ͨϵͳ�������
	CALL	INT_STOR_MSG		
TRANSMIT_TEND:	
	
	LAC	TRS_FG
	ANDL	0XFFF0
	SAH	TRS_FG
	
	CRAM	TRS_FG,6
	CRAM	TRS_FG,9		;�������
;����ҲҪ�ָ�WR=HIGH,����CLOCK��һ��TRS_FG.9=0�ͽ�WR��Ϊ�����,�����������������WR=HIGH
TRANSMIT_END:
	LACK	0
	SAH	TMR_TR
	
TRANSMIT_END1:	
	RET

;-------------------------------------------------------------------------------
;	ʱ�Ӽ���ع���
;
;	���������������û����,�������/���������־,��ִ�������־
;-------------------------------------------------------------------------------
SER_TMR:
;0>---��ʱ����------------------------------------------------------------------
	LAC	TMR_TR
	SBHK	MAX_TMR
	BZ	SGN,SER_TMR_CHK
	
	LAC	TMR_TR
	ADHK	1
	SAH	TMR_TR		;increase one every interrupt
;---initial DAT need ?
	LAC	TMR_TR
	SBHK	END_BIT
	BZ	ACZ,SER_TMR0_0
	CALL	DAT_IDEL		;���е�DAT�ָ�Ϊ�����,�����������Ͳ�ִ��
SER_TMR0_0:
	LAC	TMR_TR
	SBHK	INIT_TMR
	BZ	ACZ,SER_TMR0_1
;---initial
	LACK	0
	SAH	TRS_FG

	BS	B1,SER_TMR_CHK
SER_TMR0_1:
;0>---���Ƿ�������/��/����/�ȴ�-------------------------------------------------

	BIT	TRS_FG,9
	BS	TB,SER_TMR_SENDING	;�Ƿ���״̬��?
	CALL	WR_IN
	BIT	TRS_FG,7
	BS	TB,SER_TMR_RECING	;�ǽ���״̬��?
	BIT	TRS_FG,6
	BS	TB,SER_TMR_REQING	;�Ƿ�������״̬��?
	BIT	TRS_FG,10
	BS	TB,SER_TMR_WAITTING	;�ǵȴ�״̬��?
;---����״̬
	BS	B1,SER_TMR_CHK
;1-1>-------------------------------------------------------------------------------
SER_TMR_RECING:			;---����ʱ�����
	BIT	TRS_FG,11
	BS	TB,SER_TMR_END		;����ʱTRS_FG.11=0��ʾ���ս���

	CRAM	TRS_FG,7		;TRS_FG(bit7)=0;���Ƿ���״̬,��λ����COUNT(7..4)=0��TRAN_BUFx=0ȷ��
					;ֻ��TMR_TR2>10msʱ�ű�ʾһ�ν����������ʽ����
	LAC	TRS_FG
	ANDL	0XFFF0
	SAH	TRS_FG
	
	LACL	CMSG_SER
	CALL	INT_STOR_MSG
	BS	B1,SER_TMR_END
;1-2>-------------------------------------------------------------------------------
SER_TMR_SENDING:		;---����ʱ�鳬ʱ

	LAC	TMR_TR
	SBHK	END_SEND
	BS	ACZ,SER_TMR_ERROR
	BS	B1,SER_TMR_END
;1-3>-------------------------------------------------------------------------------
SER_TMR_WAITTING:		;---�ȴ�ʱ�鳬ʱ
	LAC	TMR_TR
	SBHK	WAIT_TMR
	BS	ACZ,SER_TMR_ERROR
	BS	B1,SER_TMR_END
;---------------------------------------
SER_TMR_ERROR:
	LAC	TRS_FG
	ANDL	0XFFF0
	SAH	TRS_FG
	
	CRAM	TRS_FG,9 	;;;;;;;;;
	CRAM	TRS_FG,10 	;;;;;;;;;
	
	CALL	CIRCLEBUF_CHK
	BZ	ACZ,SER_TMR_END

	LACK	0
	SAH	RECE_QUEUE
	
	LACL	CBUF_EMPTY		;֪ͨϵͳ��������
	CALL	INT_STOR_MSG
	BS	B1,SER_TMR_END
;1-4>---�������Ƿ���Ч------------------------------------------------------------
SER_TMR_REQING:			;---����ʱ�鿪ʼ
	LAC	TMR_TR
	SBHK	REQ_SEND
	BZ	SGN,SER_TMR_SEND	;������Ч��?
	BS	B1,SER_TMR_END
;---------------------------------------
SER_TMR_SEND:	;---��ʼ����
	;SRAM	TRS_FG,9
	CALL	WR_L
	LACK	0
	SAH	TMR_TR
	BS	B1,SER_TMR_END
;2>---���Ƿ�����/������---------------------------------------------------------
SER_TMR_CHK:
	CALL	INT_GET_DAT	;ȡ����������
	SAH	RECE_BUF
	
	BIT	TRS_FG,6	;��DSP��������(���������Ƿ�������)
	BZ	TB,SER_TMR5	;(������)����
	
	LAC	RECE_BUF
	XORL	0X0FF
	BS	ACZ,SER_TMR_WAIT	;(������)�ȴ�
;SER_TMR_REQ:	;---��ʼ����
	CRAM	TRS_FG,10
	CALL	DAT_L		;��mcu������
	LACK	0
	SAH	TMR_TR
	BS	B1,SER_TMR5	;???????????????????????????????

SER_TMR_WAIT:	;---��ʼ�ȴ�

	CRAM	TRS_FG,6
	BS	B1,SER_TMR5

;-------
SER_TMR5:			;���л�ȴ�

	CRAM	TRS_FG,9
	
	LAC	TRS_FG
	ANDL	0XFFF0 		;���ڿ���״̬(����TRS_FG.10,9,8,7,6,5,4)������
	SAH	TRS_FG
SER_TMR_END:

	RET
;-------------------------------------------------------------------------------
;	������
;
;	�������˳�,�������/���������־,��ִ�������־
;-------------------------------------------------------------------------------
SER_DET:
;2>---���Ƿ�������/��/����------------------------------------------------------
	BIT	TRS_FG,7
	BS	TB,SER_DETR_END		;�ǽ���״̬��?
	BIT	TRS_FG,9
	BS	TB,SER_DETR_END		;�Ƿ���״̬��?
;4>---���Ƿ��н�������----------------------------------------------------------
	BIT	TRS_FG,5
	BZ	TB,SER_DETR1
;SER_DETR_RECE:	;---��ʼ����(��ʼ��Ϊ0XFFFF��Ϊ���ڲ���)

	LACL	0XFFFF
	SAH	RECE_BUF1
	SAH	RECE_BUF2
	SAH	RECE_BUF3
	SAH	RECE_BUF4
	SAH	RECE_BUF5
	SAH	RECE_BUF6
	SAH	RECE_BUF7
	SAH	RECE_BUF8
	SAH	RECE_BUF9
	SAH	RECE_BUF10	;�����յ����ȴ���18bytes������

	LACK	0
	SAH	RECE_QUEUE
	SAH	SIO_CNT		;BYTE���ռ�����ʼ
	SAH	TMR_TR
	
	SRAM	TRS_FG,7	;set the flag of receive bit(TRS_FG.7=1)
	CRAM	TRS_FG,10

	CALL	DAT_IDEL
	RET
;-------
SER_DETR1:			;���л�ȴ�
	LAC	TRS_FG
	ANDL	0XFFF0 		;���ڿ���״̬(����TRS_FG.10,9,8,7,6,5,4)������
	SAH	TRS_FG
SER_DETR_END:

	RET

;-------------------------------------------------------------------------------
;	��������,��ִ����Ӧ���շ�����;������
;-------------------------------------------------------------------------------
SER_EXE:
	BIT	TRS_FG,5
	BZ	TB,SER_EXE_END	;��clock(BIOR.6) fail edge flag
	
	CALL	TRANSMIT
	CALL	RECEIVE
	
	CRAM	TRS_FG,5		;clear fail edge flag TRS_FG(bit5)
SER_EXE_END:
	RET
;-------------------------------------------------------------------------------
;		CLK������
;-------------------------------------------------------------------------------
SER_CLK:
	BIT	TRS_FG,9
	BS	TB,SER_CLK0
	CALL	WR_IN
SER_CLK0:	
	BIT	TRS_FG,11	;�������Ƿ���Ч
	BZ	TB,SER_CLK_END

	SRAM	TRS_FG,5	;if 78806 send clock(rose edge) then TRS_FG.5=1

	LAC	TRS_FG
	ADHK	1
	SAH	TRS_FG

	LAC	TRS_FG
	ANDK	0X0F
	SBHK	9
	BZ	ACZ,SER_CLK_END
	
	LAC	TRS_FG
	ANDL	0XFFF0
	ADHK	1
	SAH	TRS_FG

SER_CLK_END:
	RET
;-------
.if	0
SEND_TELNUM:
	BIT	TRS_FG,7
	BS	TB,SEND_TELNUM_END
	BIT	TRS_FG,11
	BS	TB,SEND_TELNUM_END
SEND_TELNUM_END:
	RET
.endif
;---------------------------------------------------------
;	Function : SEND_BIT
;	����Ҫ���͵�λ��״̬,�������H/L,��׼����һλ
;---------------------------------------------------------
SEND_BIT:	
	BIT	RECE_BUF,7
	BS	TB,SEND_BIT3
	
SEND_BIT2:
	CALL	DAT_L
	BS	B1,SEND_BIT_END
SEND_BIT3:
	CALL	DAT_H
SEND_BIT_END:
	LAC	RECE_BUF
	SFL	1
	ANDL	0X0FF
	SAH	RECE_BUF
	
	RET

;----------------------------------------------------------------------------
;	Function : DAT_H
;	dat(BIOR.4=1)
;----------------------------------------------------------------------------
DAT_H:
	LIPK	0
	SIO	12,BIOR
	SIO	4,BIOR
	RET
;----------------------------------------------------------------------------
;	Function : DAT_L
;	dat(BIOR.4=0)
;----------------------------------------------------------------------------
DAT_L:
	LIPK	0
	SIO	12,BIOR
	CIO	4,BIOR
	RET
;----------------------------------------------------------------------------
;	Function : DAT_IDEL
;	dat(BIOR.12=0)
;----------------------------------------------------------------------------
DAT_IDEL:
	LIPK	0
	CIO	12,BIOR
	
	RET
;----------------------------------------------------------------------------
;	Function : WR_IN
;	(BIOR.5)
;----------------------------------------------------------------------------
WR_IN:
	SRAM	TRS_FG,11
.if	TEXT_WR	
	LIPK	0
	CIO	13,BIOR
	NOP
	IN	INT_TTMP0,BIOR
	BIT	INT_TTMP0,5
	BZ	TB,WR_IN_END
	
	CRAM	TRS_FG,11
.endif
WR_IN_END:	
	RET
;----------------------------------------------------------------------------
;	Function : WR_L
;	(BIOR.5)����ʱ��
;----------------------------------------------------------------------------
WR_L:
	SRAM	TRS_FG,11	;(��/��)æ
	SRAM	TRS_FG,9	;������Ч,������ʽ��ʼ
.if	TEXT_WR	
	LIPK	0
	SIO	13,BIOR
	CIO	5,BIOR
.endif
;WR_L_END:
	RET
;-------------------------------------------------------------------------

;-------------------------------------------------------------------------
;	Function : INT_RECE_DAT	
;	���յ������ݷ�����RECE_BUF1��ʼ�Ŀռ�
;-------------------------------------------------------------------------
INT_RECE_DAT:			;�жϴ�DAT
	SAH	INT_TTMP1
	
	LAC	SIO_CNT
	SFR	8
	ANDK	0X01F
	SBHK	20		;����20Bytes��
	BZ	SGN,INT_RECE_DAT_END
	
	LAC	SIO_CNT
	SFR	9
	ANDK	0X0F
	ADHL	RECE_BUF1	;GET ADDR(RECE_BUF1..RECE_BUF1+15)
	SAH	INT_TTMP2

	MAR     +0,1
	LAR	INT_TTMP2,1
	
	LAC	SIO_CNT
	ANDL	0X100
	BS	ACZ,INT_RECE_DAT2
	
	LAC	+0,1		;���ַ
	ANDL	0X00FF
	SAH	+0,1
	
	LAC	INT_TTMP1
	SFL	8
	ANDL	0XFF00
	OR	+0,1
	SAH	+0,1
	BS	B1,INT_RECE_DAT_END
INT_RECE_DAT2:
	LAC	+0,1		;ż��ַ
	ANDL	0XFF00
	OR	INT_TTMP1
	SAH	+0,1
INT_RECE_DAT_END:
	RET

;-------------------------------------------------------------------------
;	Function : CIRCLEBUF_CHK	
;	�鷢�ͻ����Ƿ��
;	input : no
;	output : 0/!0 = ��/����
;-------------------------------------------------------------------------
CIRCLEBUF_CHK:
	
	LAC	RECE_QUEUE
	ANDK	0X01F
	SAH	INT_TTMP1
	LAC	RECE_QUEUE
	SFR	8
	SBH	INT_TTMP1
	
CIRCLEBUF_CHK_END:	
	RET
;-------------------------------------------------------------------------
;	Function : INT_GET_DAT	
;	�ӻ��λ������ȡ����,׼������(32BYTE��ռ��16 WORDS)
;-------------------------------------------------------------------------
INT_GET_DAT:
	CRAM	TRS_FG,6
	CRAM	TRS_FG,10

	CALL	CIRCLEBUF_CHK
	BS	ACZ,INT_GET_DAT_END	;NO DAT
;INT_GET_DAT_GET:
	SRAM	TRS_FG,6
	SRAM	TRS_FG,10	;������Ҫ����

	LAC	RECE_QUEUE
	ANDK	0X1F
	SBHK	20
	BS	SGN,INT_GET_DAT_ADJUST1
	LAC	RECE_QUEUE	;
	ANDL	0X1F00
	SAH	RECE_QUEUE
	BS	B1,INT_GET_DAT_ADJUST2
INT_GET_DAT_ADJUST1:
	LAC	RECE_QUEUE
	ADHK	1
	;ANDL	0X1F1F
	SAH	RECE_QUEUE
INT_GET_DAT_ADJUST2:
	;LAC	RECE_QUEUE
	ANDK	0X01F
	SFR	1
	ADHL	RECE_BUF1		;GET ADDR
	SAH	INT_TTMP1
	
	MAR	+0,1
	LAR	INT_TTMP1,1
	
	LAC	RECE_QUEUE
	ANDK	0X01
	BS	ACZ,INT_GET_DAT_GET2
	LAC	+0,1			;���ַ
	SFR	8
	ANDL	0X0FF
	RET
INT_GET_DAT_GET2:			;ż��ַ
	LAC	+0,1
	ANDL	0X0FF
INT_GET_DAT_END:

	RET
;-------------------------------------------------------------------------
;	Function : INT_STOR_DAT	
;-------------------------------------------------------------------------
INT_STOR_DAT:			;�жϴ�DAT
	SAH	INT_TTMP1
;???
	BIT	TRS_FG,7
	BS	TB,INT_STOR_DAT_END	;����������
;???
	LAC	RECE_QUEUE
	SFR	8
	SBHK	20
	BS	SGN,INT_STOR_DAT_ADJUST1
	
	LAC	RECE_QUEUE
	ANDL	0X01F
	SAH	RECE_QUEUE
	BS	B1,INT_STOR_DAT_ADJUST2
INT_STOR_DAT_ADJUST1:	
	LAC	RECE_QUEUE
	ADHL	0X100
	SAH	RECE_QUEUE
INT_STOR_DAT_ADJUST2:
	LAC	RECE_QUEUE
	SFR	9
	ADHL	RECE_BUF1	;GET ADDR
	SAH	INT_TTMP2
	
	MAR	+0,1
	LAR	INT_TTMP2,1
	
	LAC	RECE_QUEUE
	ANDL	0X100
	BS	ACZ,INT_STOR_DAT2
	
	LAC	+0,1		;���ַ
	ANDL	0XFF
	SAH	+0,1
	
	LAC	INT_TTMP1
	SFL	8
	ANDL	0XFF00
	OR	+0,1
	SAH	+0,1
	BS	B1,INT_STOR_DAT_END
INT_STOR_DAT2:
	LAC	+0,1		;ż��ַ
	ANDL	0XFF00
	OR	INT_TTMP1
	SAH	+0,1
INT_STOR_DAT_END:
	
	RET
;-------------------------------------
STOR_DAT:
	DINT
	CALL	INT_STOR_DAT
	EINT
	
	RET
;------------------------------------------------------------------

;------------------------------------------------------------------


.END
