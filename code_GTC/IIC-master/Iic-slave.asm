.LIST
;----- ----- ----- ----- ----- ----- ----- ----- ----- 
;purpose:   in IIC interrupt routine: slave Tx process
;input:     
;output:    
;----- ----- ----- ----- ----- ----- ----- ----- ----- 
IicTx:
.if	1
    	lipk    0x05
    	in	INT_TTMP1,IICSR	;IICSR-->INT_TTMP1
	bit	INT_TTMP1, 6
	bs	TB,IicTx_01		;IICSR.6==0 (not address match), goto _10
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
	outl	0x0040,IICSR		;1-->IICSR.6 (clear address-match status-bit)?????

    	CALL	INT_GET_DAT
    	sah     INT_TTMP1
    	lipk    0x05
    	out     INT_TTMP1,IICDR		;TxBuffer(0).(7-0)-->IICDR

IicTx_03:
	in	INT_TTMP1,IICCR
	lac	INT_TTMP1
	ork     0x08
	sah	INT_TTMP1
	out	INT_TTMP1,IICCR		;1-->IICCR.3 (set resume)
	bs      b1,IicTx_End		;goto _End
;-----					;----- send byte process
IicTx_10:
	outl	0xFFFF,IICSR		;0xFFFF-->iic_stathus_reg (clear status register)

    	CALL	INT_GET_DAT
    	sah     INT_TTMP1
    	lipk    0x05
    	out     INT_TTMP1,IICDR		;TxBuffer(0).(7-0)-->IICDR

	in	INT_TTMP1,IICCR
	lac	INT_TTMP1
	ork     0x08
	sah	INT_TTMP1
	out	INT_TTMP1,IICCR		;1-->IICCR.3 (set resume)
	bs	b1,IicTx_End		;goto _end
    
;-----				;----- Tx end process
IicTx_20:
	outl	0x6200,IICCR		;reset IIC circuit
	outl	0xFFFF,IICSR		;0xFFFF-->IICSR

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
    	;lac     RxFlag
   	;andl    0xFFFE
    	;sah     RxFlag			;0-->RxFlag.0
	lack    0
    	sah     IicCnt			;0-->IicCnt

	in	INT_TTMP1,IICCR
	lac	INT_TTMP1
	andl    0xF7FF			;0-->IICCR.11 (receiver slave mode)
	ork     0x08			;1-->IICCR.3 (set resume)
	sah	INT_TTMP1
	out	INT_TTMP1,IICCR
	bs      b1, IicRx_End

;-----				;----- get a byte process
IicRx_20:
	in	INT_TTMP1,IICDR
	lac     INT_TTMP1
	CALL	INT_RECE_DAT

    	lac     IicCnt
    	adhk    1
    	sah     IicCnt

	outl	0xFFFF,IICSR		;0xFFFF-->IICSR
    	nop
	in	INT_TTMP1,IICCR
	lac	INT_TTMP1
	ork     0x08
	sah	INT_TTMP1		;1-->IICCR.3 (set resume)
	out	INT_TTMP1,IICCR
	bs	b1,IicRx_End

;----- 				;-----	
IicRx_30:
    	lac     IicCnt
    	sfr     1
    	sah     IicDataLength
	outl	0xFFFF, IICSR		;0xFFFF-->IICSR (clear status register)
	
	LACL	CMSG_SER
	CALL	INT_STOR_MSG
;----- ---- -----		;----- ----- -----
IicRx_End:
.endif
    	ret
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;	Function : INT_RECE_DAT	
;	将收到的数据放在以RECE_BUF1开始的空间IicCnt是保存地址的偏移
;-------------------------------------------------------------------------------
INT_RECE_DAT:			;中断存DAT
	SAH	INT_TTMP1
	
	LAC	IicCnt
	SFR	1
	ANDK	0X0F
	ADHL	RECE_BUF1	;GET ADDR(RECE_BUF1..RECE_BUF1+15)
	SAH	INT_TTMP2

	MAR     +0,1
	LAR	INT_TTMP2,1
	
	BIT	IicCnt,0
	BZ	TB,INT_RECE_DAT2

	LAC	+0,1		;奇地址
	ANDL	0X00FF
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
;-------------------------------------

;-------------------------------------------------------------------------
;	Function : CIRCLEBUF_CHK	
;	查发送缓冲是否空(头指针 - 尾指针 = 0/~0 ===>空/不空)
;	input : no
;	output : 0/!0 = 空/不空
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
;	从环形缓冲队列取数据,准备发送(20BYTE共占用10 WORDS)
;-------------------------------------------------------------------------
INT_GET_DAT:
	CALL	CIRCLEBUF_CHK
	BS	ACZ,INT_GET_DAT_END	;NO DAT

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
	SAH	RECE_QUEUE
INT_GET_DAT_ADJUST2:
	ANDK	0X01F
	SFR	1
	ADHL	RECE_BUF1		;GET ADDR
	SAH	INT_TTMP1
	
	MAR	+0,1
	LAR	INT_TTMP1,1
	
	LAC	RECE_QUEUE
	ANDK	0X01
	BS	ACZ,INT_GET_DAT_GET2
	LAC	+0,1			;奇地址
	SFR	8
	ANDL	0X0FF
	RET
INT_GET_DAT_GET2:			;偶地址
	LAC	+0,1
	ANDL	0X0FF
INT_GET_DAT_END:

	RET
;-------------------------------------------------------------------------
;	Function : INT_PUT_DAT	
;	将该区作为环形缓冲区使用

;	将传递过来的数据保存在RECE_BUF1为基地址RECE_QUEUE(15..8)为偏移的存贮区
;-------------------------------------------------------------------------
INT_PUT_DAT:			;中断存DAT
	SAH	INT_TTMP1

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
	
	LAC	+0,1		;奇地址
	ANDL	0XFF
	SAH	+0,1
	
	LAC	INT_TTMP1
	SFL	8
	ANDL	0XFF00
	OR	+0,1
	SAH	+0,1
	BS	B1,INT_STOR_DAT_END
INT_STOR_DAT2:
	LAC	+0,1		;偶地址
	ANDL	0XFF00
	OR	INT_TTMP1
	SAH	+0,1
INT_STOR_DAT_END:
	
	RET
;-------------------------------------
PUT_DAT:
	DINT
	CALL	INT_PUT_DAT
	EINT
	
	RET

.END
