.LIST

;-------------------------------------------------------------------------------
;SER_FG		;bit8 = receive
		;bit9 = send
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

	;call	SET_SEND_FG

	;LACL	0x5F
	call	INT_GETS_DAT
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

	;lacl	0x8A
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
	BS	ACZ,IicTx_01_REQUEST_STOP	;无数据,不请求发送
;IicTx_01_REQUEST_START:
	;CALL	REQ_START
	BS	B1,IicTx_01_REQUEST_DETEND
IicTx_01_REQUEST_STOP:
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
	lack    0
	sah	RECE_QUEUE	;接收队列初始化
	
	;call	SET_RECE_FG
	
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
	CALL	INT_RECE_DAT	;接收结束以0XFF结尾
	
	;CALL	CLR_FG
	LACL	CMSG_SER
	CALL	INT_STOR_MSG

	;CALL	STATUS_READY_OFF	;Device can`t receive new command

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
.if	0	;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
RECEBUF_CHK:
	LAC	RECE_QUEUE
	ANDK	0X01F
	SAH	INT_TTMP1
	LAC	RECE_QUEUE
	SFR	8
	SBH	INT_TTMP1
	
	RET
.endif
;-------------------------------------------------------------------------------
;	Function : SENDBUF_CHK	
;	查发送缓冲是否空(头指针 - 尾指针 = 0/~0 ===>空/不空)
;	input : no
;	output : 0/!0 = 空/不空
;-------------------------------------------------------------------------------
SENDBUF_CHK:
	LAC	SEND_QUEUE
	ANDK	CMASKCODES
	SAH	INT_TTMP1
	LAC	SEND_QUEUE
	SFR	8
	SBH	INT_TTMP1
	
	RET

;-------------------------------------------------------------------------------
;	Function : INT_GETS_DAT	
;	从发送缓冲队列取数据以备发送
;-------------------------------------------------------------------------------
INT_GETS_DAT:
	CALL	SENDBUF_CHK
	BS	ACZ,INT_GETS_DAT_EMPT	;NO DAT

	LAC	SEND_QUEUE
	ADHK	1
	ANDL	(CMASKCODES<<8)|(CMASKCODES)
	SAH	SEND_QUEUE

	ANDK	CMASKCODES
	SFR	1
	ADHL	SEND_BUF1		;GET ADDR
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
	CALL	REQ_STOP
	LACL	0X0FF
	RET
;-------------------------------------------------------------------------
;	Function : INT_RECE_DAT	

;	将接收到的数据保存在RECE_BUF1为基地址RECE_QUEUE(15..8)为偏移的存贮区
;-------------------------------------------------------------------------
INT_RECE_DAT:			;中断存DAT

	SAH	INT_TTMP1

	LAC	RECE_QUEUE
	ADHL	0X100
	ANDL	(CMASKCODER<<8)|(CMASKCODER)
	SAH	RECE_QUEUE

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

;	将待发送的数据保存在SEND_BUF1为基地址SEND_QUEUE(15..8)为偏移的存贮区
;-------------------------------------------------------------------------

GETR_DAT:
INT_GETR_DAT:
SEND_DAT:
INT_SEND_DAT:
;---------------------------------------
	RET
;---------------------------------------
.if	0
SET_RECE_FG:
	LAC	SER_FG
	ANDL	~(1<<9)
	ORL	1<<8
	SAH	SER_FG
	
	RET
SET_SEND_FG:
	LAC	SER_FG
	ANDL	~(1<<8)
	ORL	1<<9
	SAH	SER_FG
	
	RET
CLR_FG:
	LAC	SER_FG
	ANDL	~((1<<8)|(1<<9))
	SAH	SER_FG
	
	RET
.endif
;-------
REQ_START:
	lipk	8
	IN      INT_TTMP1,GPBD
	LAC	INT_TTMP1
	ANDL	~(1<<REQ)
	SAH	INT_TTMP1
	OUT     INT_TTMP1,GPBD
	ADHK	0

	RET
REQ_STOP:
	lipk	8
	IN      INT_TTMP1,GPBD
	LAC	INT_TTMP1
	ORL	1<<REQ
	SAH	INT_TTMP1
	OUT     INT_TTMP1,GPBD
	ADHK	0

	RET
;-------------------------------------------------------------------------------
.END
