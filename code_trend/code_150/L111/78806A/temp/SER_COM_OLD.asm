;org 0x0400
;-------------------------------------------------------------------------
SER_BASE	EQU	0XE0	;CALL ID RAM
SER_DATA	EQU	0X3F
SER_FLAG	EQU	0X3C	
;				bit7=收到一串数据/命令
;				bit6=请求发
;				bit5=正在发
;				bit4=正在收
;				bit(3..0)=CLK计数
SER_CONT	EQU	0X3D
SER_SEND	EQU	0X3E
;-------------------------------------------------------------------------
;DAT      	equ 0x03---serial's data line
;WR      	equ 0x04---serial's read and write line
;CLK      	equ 0x05---serial's clock line
;--------------------------------------------------------------------
P_DAT		==	3	;3
P_WR		==	4
P_CLK		==	5
;-------------------------------------------------------------------------------
;	SER_RECE_DATA : 将收到的数据存入缓冲区
;		SER_BASE : 缓冲区的基地址
;		SER_CONT : 缓冲区的变址
;-------------------------------------------------------------------------------
SER_RECE_DATA	MACRO
	MOV	A,@SER_BASE
	ADD	A,SER_CONT
	MOV	RC,A

	MOV	A,SER_DATA
	MOV	RD,A
	
ENDM
;-------------------------------------------------------------------------------
;	SER_GET_DATA : 取出缓冲区中待发送的数据,准备发送
;		SER_BASE : 缓冲区的基地址
;		SER_CONT : 缓冲区的变址
;-------------------------------------------------------------------------------
SER_GET_DATA	MACRO
	MOV	A,@SER_BASE
	ADD	A,SER_CONT
	MOV	RC,A

	MOV	A,RD
	MOV	SER_DATA,A
ENDM
;-------------------------------------------------------------------------------
;	SER_STOR_DATA : 将要发送的数据存入缓冲区中,待发送(多处使用,建议改成子程序)
;			SER_BASE,SER_BASE+1,SER_BASE+2,...,SER_BASE+n
;		SER_BASE : 缓冲区的基地址
;		SER_SEND : 缓冲区的变址
;-------------------------------------------------------------------------------
SER_STOR_DATA:
	MOV	TEMP0,A
	
	MOV	A,@SER_BASE
	ADD	A,SER_SEND
	MOV	RC,A
	
	INC	SER_SEND
	
	MOV	A,TEMP0
	MOV	RD,A
	RET
;-------------------------------------------------------------------------------
;	SER_GETRECED_DATA : 从缓冲区中取出收到的数据
;			SER_BASE,SER_BASE+1,SER_BASE+2,...,SER_BASE+n
;		SER_BASE : 缓冲区的基地址
;		INPUT : ACC==>缓冲区的变址
;		OUTPUT: ACC==>缓冲区的变址对应的数据
;-------------------------------------------------------------------------------
SER_GETRECED_DATA:
	MOV	TEMP0,A
	
	MOV	A,@SER_BASE
	ADD	A,TEMP0
	MOV	RC,A

	MOV	A,RD
	RET
;--------------------------------------------------------------------
;	串口通信
;--------------------------------------------------------------------
SER_COMM	MACRO	;分二个部分
;--------------------------------------------------------------------
;	部分一:	任务检测
;		正在收/发就退出，否则检测收/发请求
;--------------------------------------------------------------------
SER_DET:
	JBC	SER_FLAG,4
	JMP	SER_DET_END
	JBC	SER_FLAG,5
	JMP	SER_DET_END
;---完全空闲的状态，检测收/发请求
SER_DET1:
	JBC	_R7,P_WR
	JMP	SER_DET2
			;WR处于有效状态(DSP请求发送)
			;接收过程开始!!!
	CLR	SER_CONT
	BS	SER_FLAG,4

	JMP	SER_DET_END
SER_DET2:		;WR处于无效状态(查78806A发送请求)
	JBS	SER_FLAG,6
	JMP	SER_DET_END
			;有发送请求,置发送标志清请求标志并使WR有效(WR=LOW)
			;发送过程开始!!!
	CLR	SER_CONT
	BS	SER_FLAG,5
	BC	SER_FLAG,6
	
	SER_GET_DATA	;开始发送第一次取数据
	/*
	ior	R7
	AND	A,@0Xe7
	iow	R7	;set R7(4,3)(WR,DAT) as output port
	*/
	CIO	_R7,P_WR
	CIO	_R7,P_DAT
	BC	R7,P_WR	
SER_DET_END:

;-------------------------------------------------------------------------
;	部分二:时钟产生及任务执行
;-------------------------------------------------------------------------
CLOCK:
	JBC	_R7,P_WR
	JMP	CLOCK4
;---有传送
	JBS	_R7,P_CLK
	JMP	CLOCK2
;----------------------------------
CLOCK1:			;HIGH==>LOW
	JBS	SER_FLAG,5
	JMP	CLOCK1_2
;---	
	MOV	A,SER_SEND	;发送完毕了吗?
	SUB	A,SER_CONT
	JBC	_STATUS,Z
	JMP	CLOCK1_1
	
	BC	_R7,P_CLK		;发送过程计数(低电平发)
	INC	SER_FLAG

	MOV	A,SER_FLAG		;计数调整(MOD 8)
	AND	A,@0X0F
	SUB	A,@0X8
	JBC	_STATUS,C
	JMP	SEREXE_SEND
	
	MOV	A,@8
	SUB	SER_FLAG,A
SEREXE_SEND:	;处理发送开始
;!!!!!!!!!!!!!!!
	RLC	SER_DATA
	;RLC	0X3F
	JBC	_STATUS,C
	JMP	SEREXE_SEND1
	BC	_R7,P_DAT
	JMP	SEREXE_SEND2
SEREXE_SEND1:
	BS	_R7,P_DAT
SEREXE_SEND2:
	MOV	A,SER_FLAG
	AND	A,@0X0F
	SUB	A,@8
	JBS	_STATUS,Z
	JMP	SEREXE_SEND_END
;以下作发送下一个BYTE的准备
	INC	SER_CONT
	SER_GET_DATA		;取下一个BYTE的数据

SEREXE_SEND_END:
;!!!!!!!!!!!!!!!
	JMP	CLOCK_END
CLOCK1_1:		;发送过程完毕!!!清除相关标志
	CLR	SER_FLAG
	CLR	SER_SEND
	/*
	ior	R7
	or	A,@0X18
	iow	R7	;set R7(4,3)(WR,DAT) as intput port
	*/
	SIO	_R7,P_WR
	SIO	_R7,P_DAT
	JMP	CLOCK_END
CLOCK1_2:		;非发送过程
	BC	_R7,P_CLK		;(低电平)
	JMP	CLOCK_END
;-------------------------------------------------------------------------------
CLOCK2:			;LOW==>HIGH
	BS	_R7,P_CLK
	
	JBS	SER_FLAG,4	;如果是接收过程就计数(高电平收)
	JMP	CLOCK_END
	
	INC	SER_FLAG	
;-------------------------------;计数调整(MOD 8)
	MOV	A,SER_FLAG
	AND	A,@0X0F
	SUB	A,@0X8
	JBC	_STATUS,C
	JMP	SEREXE_RECE
	
	MOV	A,@8
	SUB	SER_FLAG,A
SEREXE_RECE:	;处理接收开始
;!!!!!!!!!!!!!!!	;开始收(一个bit)
	BS	_STATUS,C	
	JBS	_R7,P_DAT
	BC	_STATUS,C
	RLC	SER_DATA

	MOV	A,SER_FLAG
	AND	A,@0X0F
	SUB	A,@8
	JBS	_STATUS,Z
	JMP	SEREXE_RECE_END
;以下作接收下一个BYTE的准备
	SER_RECE_DATA
	INC	SER_CONT

	JBS	R7,P_WR
	JMP	SEREXE_RECE_END
	
	CLR	SER_FLAG	;接收过程完毕!!!
	BS	SER_FLAG,7	;可以取收到的数据进行处理

SEREXE_RECE_END:
;!!!!!!!!!!!!!!!
	JMP	CLOCK_END
CLOCK4:			;(收)最后一个bit?
	JBS	_R7,P_CLK
	JMP	CLOCK2
CLOCK_END:
;----------------------------------------------------------------------------

ENDM

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

;eop
