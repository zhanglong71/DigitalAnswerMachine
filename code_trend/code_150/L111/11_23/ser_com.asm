;可收多个字节数据2006-7-13 10:15
.LIST
;Auxiliary Registers ALL use AR0
;-------BELOWS ARE FOR SIO BETWEEN DSP AND 78806---------------------
;BIOR:	bit4=SDI=dat(DSP<==>CPU,DSP R/T from this port)
;	bit5=SDO=wr(CPU==>DSP,DSP receive command from this port,contral by CPU)
;	bit6=TRX=clk(CPU==>DSP,DSP receive clock from this port,contral by CPU)
;-------(记录各种状态标志)---------
;TRS_FG:	bit0..3记录已传送/接收的位的个数(clk脉冲个数)
;		bit4 = reserved
;		bit5 = 1---下降沿触发,外部中断标志
;		bit6 = 1---正在请求(发送前的动作,同时DAT = low)
;		bit7 = 1---命令(可能是多字节命令)接收正在执行,接收标志
;		bit8 =
;		bit9 = 1---字节发送状态.(一个字节从bit7到bit0在此状态)
;		bit10= 1---发送数据前后的等待状态
;		BIT11= 1---收发有效(WR=LOW时置1)
;		bit12= 1---正在延时,不可发送的空闲状态(此时不可发送,但可接收)
;		bit13= 1---
;TMR_TR:记录上次位传送到现在的时间间隔;当传完一字节后,记录的是上次字节到现在的时间
;-------
;SIO_CNT:	bit0..7记录已传送/接收的位的个数
;		bit8..11记录已接收字节个数(接收状态)---或已发送的字节个数(发送状态)
TEXT_CLOCK	.EQU   		0	;0===>不用模拟CLOCK
TEXT_WR		.EQU   		1	;1===>有效脚位起作用,通迅用
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
;---TMR_1MS = 0时
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
;-------保存已收到的一个字节(若接收缓冲空间不够用,可继续往后增加)--------
	
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
	SAH	TMR_TR		;位接收计时复位

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

	CALL	INT_GET_DAT	;取数据
	SAH	RECE_BUF
	
	BIT	TRS_FG,6		;查DSP发送请求(CPU发送clock=BIOR.6=0?)
	BZ	TB,TRANSMIT_BUFEMPTY	;发送完毕
	
	LAC	RECE_BUF
	XORL	0X0FF
	BS	ACZ,TRANSMIT_TEND	;等待
	
	CRAM	TRS_FG,10
	CRAM	TRS_FG,6

	BS	B1,TRANSMIT_END
TRANSMIT_BUFEMPTY:	;缓冲区空
	CRAM	TRS_FG,9
	
	LACL	CBUF_EMPTY		;通知系统发送完毕
	CALL	INT_STOR_MSG		
TRANSMIT_TEND:	
	
	LAC	TRS_FG
	ANDL	0XFFF0
	SAH	TRS_FG
	
	CRAM	TRS_FG,6
	CRAM	TRS_FG,9		;发送完毕
;本来也要恢复WR=HIGH,但在CLOCK中一旦TRS_FG.9=0就将WR置为输入口,在上拉电阻的作用下WR=HIGH
TRANSMIT_END:
	LACK	0
	SAH	TMR_TR
	
TRANSMIT_END1:	
	RET

;-------------------------------------------------------------------------------
;	时钟及相关功能
;
;	接收任务结束或者没任务,清除发送/接收任务标志,置执行命令标志
;-------------------------------------------------------------------------------
SER_TMR:
;0>---计时部分------------------------------------------------------------------
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
	CALL	DAT_IDEL		;空闲的DAT恢复为输入口,如果正在请求就不执行
SER_TMR0_0:
	LAC	TMR_TR
	SBHK	INIT_TMR
	BZ	ACZ,SER_TMR0_1
;---initial
	LACK	0
	SAH	TRS_FG

	BS	B1,SER_TMR_CHK
SER_TMR0_1:
;0>---查是否正在收/发/请求/等待-------------------------------------------------

	BIT	TRS_FG,9
	BS	TB,SER_TMR_SENDING	;是发送状态吗?
	CALL	WR_IN
	BIT	TRS_FG,7
	BS	TB,SER_TMR_RECING	;是接收状态吗?
	BIT	TRS_FG,6
	BS	TB,SER_TMR_REQING	;是发送请求状态吗?
	BIT	TRS_FG,10
	BS	TB,SER_TMR_WAITTING	;是等待状态吗?
;---空闲状态
	BS	B1,SER_TMR_CHK
;1-1>-------------------------------------------------------------------------------
SER_TMR_RECING:			;---接收时查结束
	BIT	TRS_FG,11
	BS	TB,SER_TMR_END		;接收时TRS_FG.11=0表示接收结束

	CRAM	TRS_FG,7		;TRS_FG(bit7)=0;若是发送状态,此位可由COUNT(7..4)=0或TRAN_BUFx=0确定
					;只有TMR_TR2>10ms时才表示一次接收任务的正式结束
	LAC	TRS_FG
	ANDL	0XFFF0
	SAH	TRS_FG
	
	LACL	CMSG_SER
	CALL	INT_STOR_MSG
	BS	B1,SER_TMR_END
;1-2>-------------------------------------------------------------------------------
SER_TMR_SENDING:		;---发送时查超时

	LAC	TMR_TR
	SBHK	END_SEND
	BS	ACZ,SER_TMR_ERROR
	BS	B1,SER_TMR_END
;1-3>-------------------------------------------------------------------------------
SER_TMR_WAITTING:		;---等待时查超时
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
	
	LACL	CBUF_EMPTY		;通知系统缓冲区空
	CALL	INT_STOR_MSG
	BS	B1,SER_TMR_END
;1-4>---查请求是否有效------------------------------------------------------------
SER_TMR_REQING:			;---请求时查开始
	LAC	TMR_TR
	SBHK	REQ_SEND
	BZ	SGN,SER_TMR_SEND	;请求有效吗?
	BS	B1,SER_TMR_END
;---------------------------------------
SER_TMR_SEND:	;---开始发送
	;SRAM	TRS_FG,9
	CALL	WR_L
	LACK	0
	SAH	TMR_TR
	BS	B1,SER_TMR_END
;2>---查是否有收/发任务---------------------------------------------------------
SER_TMR_CHK:
	CALL	INT_GET_DAT	;取待发送数据
	SAH	RECE_BUF
	
	BIT	TRS_FG,6	;查DSP发送请求(缓冲区中是否有数据)
	BZ	TB,SER_TMR5	;(无数据)空闲
	
	LAC	RECE_BUF
	XORL	0X0FF
	BS	ACZ,SER_TMR_WAIT	;(有数据)等待
;SER_TMR_REQ:	;---开始请求
	CRAM	TRS_FG,10
	CALL	DAT_L		;向mcu发请求
	LACK	0
	SAH	TMR_TR
	BS	B1,SER_TMR5	;???????????????????????????????

SER_TMR_WAIT:	;---开始等待

	CRAM	TRS_FG,6
	BS	B1,SER_TMR5

;-------
SER_TMR5:			;空闲或等待

	CRAM	TRS_FG,9
	
	LAC	TRS_FG
	ANDL	0XFFF0 		;处于空闲状态(保留TRS_FG.10,9,8,7,6,5,4)无请求
	SAH	TRS_FG
SER_TMR_END:

	RET
;-------------------------------------------------------------------------------
;	任务检测
;
;	有任务退出,清除发送/接收任务标志,置执行命令标志
;-------------------------------------------------------------------------------
SER_DET:
;2>---查是否正在收/发/请求------------------------------------------------------
	BIT	TRS_FG,7
	BS	TB,SER_DETR_END		;是接收状态吗?
	BIT	TRS_FG,9
	BS	TB,SER_DETR_END		;是发送状态吗?
;4>---查是否有接收任务----------------------------------------------------------
	BIT	TRS_FG,5
	BZ	TB,SER_DETR1
;SER_DETR_RECE:	;---开始接收(初始化为0XFFFF是为便于测试)

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
	SAH	RECE_BUF10	;不会收到长度大于18bytes的数据

	LACK	0
	SAH	RECE_QUEUE
	SAH	SIO_CNT		;BYTE接收计数开始
	SAH	TMR_TR
	
	SRAM	TRS_FG,7	;set the flag of receive bit(TRS_FG.7=1)
	CRAM	TRS_FG,10

	CALL	DAT_IDEL
	RET
;-------
SER_DETR1:			;空闲或等待
	LAC	TRS_FG
	ANDL	0XFFF0 		;处于空闲状态(保留TRS_FG.10,9,8,7,6,5,4)无请求
	SAH	TRS_FG
SER_DETR_END:

	RET

;-------------------------------------------------------------------------------
;	有脉冲来,则执行相应的收发操作;否则查错
;-------------------------------------------------------------------------------
SER_EXE:
	BIT	TRS_FG,5
	BZ	TB,SER_EXE_END	;查clock(BIOR.6) fail edge flag
	
	CALL	TRANSMIT
	CALL	RECEIVE
	
	CRAM	TRS_FG,5		;clear fail edge flag TRS_FG(bit5)
SER_EXE_END:
	RET
;-------------------------------------------------------------------------------
;		CLK脉冲检测
;-------------------------------------------------------------------------------
SER_CLK:
	BIT	TRS_FG,9
	BS	TB,SER_CLK0
	CALL	WR_IN
SER_CLK0:	
	BIT	TRS_FG,11	;检测接收是否有效
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
;	根据要发送的位的状态,置输出口H/L,并准备下一位
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
;	(BIOR.5)发送时用
;----------------------------------------------------------------------------
WR_L:
	SRAM	TRS_FG,11	;(收/发)忙
	SRAM	TRS_FG,9	;请求有效,发送正式开始
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
;	将收到的数据放在以RECE_BUF1开始的空间
;-------------------------------------------------------------------------
INT_RECE_DAT:			;中断存DAT
	SAH	INT_TTMP1
	
	LAC	SIO_CNT
	SFR	8
	ANDK	0X01F
	SBHK	20		;超过20Bytes丢
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

;-------------------------------------------------------------------------
;	Function : CIRCLEBUF_CHK	
;	查发送缓冲是否空
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
;	从环形缓冲队列取数据,准备发送(32BYTE共占用16 WORDS)
;-------------------------------------------------------------------------
INT_GET_DAT:
	CRAM	TRS_FG,6
	CRAM	TRS_FG,10

	CALL	CIRCLEBUF_CHK
	BS	ACZ,INT_GET_DAT_END	;NO DAT
;INT_GET_DAT_GET:
	SRAM	TRS_FG,6
	SRAM	TRS_FG,10	;有数据要发送

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
;	Function : INT_STOR_DAT	
;-------------------------------------------------------------------------
INT_STOR_DAT:			;中断存DAT
	SAH	INT_TTMP1
;???
	BIT	TRS_FG,7
	BS	TB,INT_STOR_DAT_END	;正在收数据
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
STOR_DAT:
	DINT
	CALL	INT_STOR_DAT
	EINT
	
	RET
;------------------------------------------------------------------

;------------------------------------------------------------------


.END
