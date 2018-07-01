.LIST
;-------------------------------------------------------------------------------
MAXR_LEN	.EQU   		64	;接收缓冲区最多容纳的数据Byte
MAXS_LEN	.EQU   		64	;发送缓冲区最多容纳的数据Byte
CbREQ		.EQU   		9	;Request bit(GPBD)

;-------------------------------------------------------------------------------

		
;-------------------------------------------------------------------------------
IicTx:
.if	1
    	lipk    0x05
    	in	INT_TTMP1,IICSR	;IICSR-->INT_TTMP1
	bit	INT_TTMP1, 6
	bs	TB,IicTx_01		;IICSR.6==0 (not address match), goto _10
	bit     INT_TTMP1, 1
    	bs      TB,IicTx_20
    	bit     INT_TTMP1, 3
    	bs      TB,IicTx_20		;bus-error (Tx end), goto _end
    	bs      b1,IicTx_10

;-----				;----- addresss match process
IicTx_01:
	in	INT_TTMP1,IICCR
	lac	INT_TTMP1
	orl	0x0800
	sah	INT_TTMP1
	out	INT_TTMP1,IICCR		;1-->IICCR.11 (set as Tx mode)
	adhk	0

	call	SET_SEND_FG

	call	INT_GETS_DAT		;Send first data
    	sah     INT_TTMP1
    	lipk    0x05
    	out     INT_TTMP1,IICDR		;TxBuffer(0).(7-0)-->IICDR
	adhk	0

	outl	0xFFFF,IICSR		;1-->IICSR.6 (clear address-match status-bit)

	in	INT_TTMP1,IICCR
	lac	INT_TTMP1
	ork     0x08
	sah	INT_TTMP1
	out	INT_TTMP1,IICCR		;1-->IICCR.3 (set resume)
	adhk	0

	bs      b1,IicTx_End		;goto _End
;-----					;----- send byte process
IicTx_10:
	outl	0xFFFF,IICSR		;0xFFFF-->iic_stathus_reg (clear status register)

	call	INT_GETS_DAT
    	sah     INT_TTMP1
    	lipk    0x05
    	out     INT_TTMP1,IICDR		;TxBuffer(0).(7-0)-->IICDR
	adhk	0

	in	INT_TTMP1,IICCR
	lac	INT_TTMP1
	ork     0x08
	sah	INT_TTMP1
	out	INT_TTMP1,IICCR		;1-->IICCR.3 (set resume)
	adhk	0

	bs	b1,IicTx_End		;goto _end
;-----				;----- Tx end process
IicTx_20:
	outl	0x6200,IICCR		;reset IIC circuit
	outl	0xFFFF,IICSR		;0xFFFF-->IICSR
	lupk    20, 0
	nop
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
.if	1
	CALL	SENDBUF_CHK
	ADHK	0
	BZ	ACZ,IicTx_01_REQUEST_DETEND	;有数据,不能复位Req

	BIT	SER_FG,CbBUSY
	BS	TB,IicTx_01_REQUEST_DETEND	;IIC Busy,不能复位Req(可能不停的发0)

	CALL	REQ_STOP
IicTx_01_REQUEST_DETEND:
.endif
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;----- ----- ------		;----- ----- -----
IicTx_End:
.endif
    	ret

;----- ----- ----- ----- ----- ----- ----- ----- ----- 
;purpose:   
;input:     
;output:    IicDataLength-->got total word number
;           RxFlag.0--> 1: process end
;----- ----- ----- ----- ----- ----- ----- ----- ----- 
IicRx:          ;
.if	1
    	lipk    0x05
    	in	INT_TTMP1,IICSR		;IICSR-->INT_TTMP1
	bit	INT_TTMP1,6
	bs	TB, IicRx_10		;iic_statys_reg.6==1 (Rx Address match), goto _10
	bit 	INT_TTMP1,1
	bs	TB, IicRx_30		;IICSR.1==1 (Rx end), goto _end
    	bs      b1, IicRx_20
;-----				;----- RX address match process
IicRx_10:
	outl	0xFFFF,IICSR
	lacl    0x3f3f
	sah	RECE_QUEUE	;接收队列初始化
	;sah	SEND_QUEUE	;发送队列初始化
	
	call	SET_RECE_FG
	
	in	INT_TTMP1,IICCR
	lac	INT_TTMP1
	andl    0xE7FF			;0-->IICCR.11 (receiver slave mode)
	ork     0x08			;1-->IICCR.3 (set resume)
	sah	INT_TTMP1
	out	INT_TTMP1,IICCR
	adhk	0
	bs      b1, IicRx_End

;-----				;----- get a byte process
IicRx_20:
	in	INT_TTMP1,IICDR
	lac     INT_TTMP1
	CALL	INT_RECE_DAT

	outl	0xFFFF,IICSR		;0xFFFF-->IICSR
    	nop
	in	INT_TTMP1,IICCR
	lac	INT_TTMP1
	ork     0x08
	sah	INT_TTMP1		;1-->IICCR.3 (set resume)
	out	INT_TTMP1,IICCR
	adhk	0
	bs	b1,IicRx_End

;----- 				;-----	
IicRx_30:

	LACL	0XFF
	CALL	INT_RECE_DAT		;receive end data
	
	CALL	CLR_TR_FG
	CALL	SET_BUSY_FG		;Device can`t receive new command

	LACL	CMSG_SER
	CALL	INT_STOR_MSG

	lipk    0x05
	outl	0x6200, IICCR		;reset IIC circuit
	outl	0xFFFF, IICSR		;0xFFFF-->IICSR (clear status register)
	
	lupk    20, 0
	nop
;----- ---- -----		;----- ----- -----
IicRx_End:
.endif
    	ret
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;	Function : RECEBUF_CHK	
;	查接收缓冲是否空(头指针 - 尾指针 = 0/~0 ===>空/不空)
;	input : no
;	output : 0/!0 = 空/不空
;-------------------------------------------------------------------------------
RECEBUF_CHK:
	LAC	RECE_QUEUE
	ANDK	0X03F
	SAH	INT_TTMP1
	LAC	RECE_QUEUE
	SFR	8
	SBH	INT_TTMP1
	
	RET
;-------------------------------------------------------------------------------
;	Function : SENDBUF_CHK	
;	查发送缓冲是否空(头指针 - 尾指针 = 0/~0 ===>空/不空)
;	input : no
;	output : 0/!0 = 空/不空
;-------------------------------------------------------------------------------
SENDBUF_CHK:
	LAC	SEND_QUEUE
	ANDK	0X03F
	SAH	INT_TTMP1
	LAC	SEND_QUEUE
	SFR	8
	SBH	INT_TTMP1
	
	RET
;-------------------------------------------------------------------------------
;SENDBUFLEN_CHK:
	;LAC	SEND_QUEUE
	;ANDK	0X03F
	;SAH	INT_TTMP1
	;LAC	SEND_QUEUE
	;SFR	8
	;ADHK	0X040
	;SBH	INT_TTMP1
	;ANDK	0X03F

	;RET
;-------------------------------------------------------------------------------
;	Function : INT_GETR_DAT	
;	从接收缓冲队列取接收到的数据(用以判断下一步动作)
;	input : no
;	output: ACCH = DATA(if no vaild data in buffer,return ACCH = 0xff)
;-------------------------------------------------------------------------------
INT_GETR_DAT:
	CALL	RECEBUF_CHK
	BS	ACZ,INT_GETR_DAT_EMPT	;NO DAT

	LAC	RECE_QUEUE
	ANDK	0X3F
	SBHK	(MAXR_LEN-1)
	BS	SGN,INT_GETR_DAT_ADJUST1
	LAC	RECE_QUEUE	;
	ANDL	0X3F00
	SAH	RECE_QUEUE
	BS	B1,INT_GETR_DAT_ADJUST2
INT_GETR_DAT_ADJUST1:
	LAC	RECE_QUEUE
	ADHK	1
	SAH	RECE_QUEUE
INT_GETR_DAT_ADJUST2:
	ANDK	0X03F
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
	ADHK	0
	RET
INT_GETR_DAT_GET2:			;偶地址

	LAC	+0,1
	ANDL	0X0FF
	RET
INT_GETR_DAT_EMPT:			;队列空
	LACL	0X0FF
	RET
;-------------------------------------------------------------------------------
;	Function : INT_GETS_DAT	
;	从发送缓冲队列取数据以备发送
;-------------------------------------------------------------------------------
INT_GETS_DAT:
	CALL	SENDBUF_CHK
	BS	ACZ,INT_GETS_DAT_EMPT	;NO DAT

	LAC	SEND_QUEUE
	ANDK	0X3F
	SBHK	(MAXS_LEN-1)
	BS	SGN,INT_GETS_DAT_ADJUST1
	LAC	SEND_QUEUE	;
	ANDL	0X3F00
	SAH	SEND_QUEUE
	BS	B1,INT_GETS_DAT_ADJUST2
INT_GETS_DAT_ADJUST1:
	LAC	SEND_QUEUE
	ADHK	1
	SAH	SEND_QUEUE
INT_GETS_DAT_ADJUST2:
	ANDK	0X03F
	SFR	1
	ADHL	RECE_BUF1		;GET ADDR
	SAH	INT_TTMP1
	
	MAR	+0,1
	LAR	INT_TTMP1,1
	
	LAC	SEND_QUEUE
	ANDK	0X01
	BS	ACZ,INT_GETS_DAT_GET2
	LAC	+0,1			;奇地址
	SFR	8
	ANDL	0X0FF
	RET
INT_GETS_DAT_GET2:			;偶地址

	LAC	+0,1
	ANDL	0X0FF
	RET
INT_GETS_DAT_EMPT:			;队列空
	LACL	0X0FF
	;LACK	0X0
	RET
;-------------------------------------------------------------------------
;	Function : INT_RECE_DAT	

;	将接收到的数据保存在RECE_BUF1为基地址RECE_QUEUE(15..8)为偏移的存贮区
;-------------------------------------------------------------------------
INT_RECE_DAT:			;中断存DAT

	SAH	INT_TTMP1

	LAC	RECE_QUEUE
	SFR	8
	SBHK	(MAXR_LEN-1)
	BS	SGN,INT_RECE_DAT_ADJUST1
	
	LAC	RECE_QUEUE
	ANDK	0X03F
	SAH	RECE_QUEUE
	BS	B1,INT_RECE_DAT_ADJUST2
INT_RECE_DAT_ADJUST1:
	LAC	RECE_QUEUE
	ADHL	0X100
	SAH	RECE_QUEUE
INT_RECE_DAT_ADJUST2:
	LAC	RECE_QUEUE
	SFR	9
	ADHL	RECE_BUF1	;GET ADDR
	SAH	INT_TTMP0
	
	MAR	+0,1
	LAR	INT_TTMP0,1
	
	LAC	RECE_QUEUE
	ANDL	0X100
	BS	ACZ,INT_RECE_DAT2
	
	LAC	+0,1		;奇地址
	ANDL	0XFF
	SAH	+0,1
	
	LAC	INT_TTMP1
	SFL	8
	ANDL	0XFF00
	OR	+0,1
	SAH	+0,1
	BS	B1,INT_RECE_DAT_END
INT_RECE_DAT2:
	LAC	+0,1		;偶地址
	ANDL	0XFF00
	OR	INT_TTMP1
	SAH	+0,1
INT_RECE_DAT_END:
	RET
;-------------------------------------------------------------------------
;	Function : INT_RECE_DAT	

;	将待发送的数据保存在RECE_BUF1为基地址SEND_QUEUE(15..8)为偏移的存贮区
;-------------------------------------------------------------------------
INT_SEND_DAT:			;中断存DAT
	SAH	INT_TTMP1

	LAC	SEND_QUEUE
	SFR	8
	SBHK	(MAXS_LEN-1)
	BS	SGN,INT_SEND_DAT_ADJUST1
	
	LAC	SEND_QUEUE
	ANDK	0X03F
	SAH	SEND_QUEUE
	BS	B1,INT_SEND_DAT_ADJUST2
INT_SEND_DAT_ADJUST1:

	LAC	SEND_QUEUE
	ADHL	0X100
	SAH	SEND_QUEUE
INT_SEND_DAT_ADJUST2:

	LAC	SEND_QUEUE
	SFR	9
	ADHL	RECE_BUF1	;GET ADDR
	SAH	INT_TTMP0
	
	MAR	+0,1
	LAR	INT_TTMP0,1
	
	LAC	SEND_QUEUE
	ANDL	0X100
	BS	ACZ,INT_SEND_DAT2
	
	LAC	+0,1		;奇地址
	ANDL	0XFF
	SAH	+0,1
	
	LAC	INT_TTMP1
	SFL	8
	ANDL	0XFF00
	OR	+0,1
	SAH	+0,1
	BS	B1,INT_SEND_DAT_END
INT_SEND_DAT2:
	LAC	+0,1		;偶地址
	ANDL	0XFF00
	OR	INT_TTMP1
	SAH	+0,1
INT_SEND_DAT_END:
	RET
;---------------------------------------
GETR_DAT:
	DINT
	CALL	INT_GETR_DAT
	EINT
	
	RET
SEND_DAT:
	BIT	SER_FG,CbRx
	BS	TB,SEND_DAT_END	;正在收,不请求发送
;!!!		
	DINT
	CALL	INT_SEND_DAT
	CALL	REQ_START	;Pull down the request line
	EINT
;!!!	
SEND_DAT_END:	
	RET
;---------------------------------------
SET_RECE_FG:
	LAC	SER_FG
	ANDL	~(1<<CbTx)
	ORL	(1<<CbRx)
	SAH	SER_FG
	
	RET
SET_SEND_FG:
	LAC	SER_FG
	ANDL	~(1<<CbRx)
	ORL	(1<<CbTx)
	SAH	SER_FG
	
	RET
CLR_TR_FG:
	LAC	SER_FG
	ANDL	~((1<<CbRx)|(1<<CbTx))
	SAH	SER_FG
	
	RET
;---------------------------------------
SET_BUSY_FG:		;阻塞IIC通信
	LAC	SER_FG
	ORL	(1<<CbBUSY)
	SAH	SER_FG

	CALL	REQ_START

	RET
CLR_BUSY_FG:		;解除阻塞IIC通信
	DINT
	CALL	INT_CLR_BUSY_FG
	EINT
	
	RET
INT_CLR_BUSY_FG:
	LAC	SER_FG
	ANDL	~(1<<CbBUSY)
	SAH	SER_FG

	RET
;-------------------------------------------------------------------------------
REQ_START:
	lipk	8
	IN      INT_TTMP1,GPBD
	LAC	INT_TTMP1
	ANDL	~(1<<CbREQ)
	SAH	INT_TTMP1
	OUT     INT_TTMP1,GPBD
	ADHK	0

	RET
REQ_STOP:
	lipk	8
	IN      INT_TTMP1,GPBD
	LAC	INT_TTMP1
	ORL	1<<CbREQ
	SAH	INT_TTMP1
	OUT     INT_TTMP1,GPBD
	ADHK	0

	RET
;-------------------------------------------------------------------------------
.END
