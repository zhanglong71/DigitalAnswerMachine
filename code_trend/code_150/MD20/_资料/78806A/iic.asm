
/*****************************
由SPI通讯方式改过。
尽量不改变接口。
由原来在中断0.5ms中执行改到程序循环中
一次接收/发送start--stop的一组命令。
*****************************/

SER_BASE	EQU	0XE0	; call id ram
SER_DATA	EQU	0X3F
SER_FLAG	EQU	0X3C
;	.7 收到一串数据(1)
;	.6 请求发送(1)
SER_CONT	EQU	0X3D
SER_SEND	EQU	0X3E


P_REQ		EQU	0
P_WR		EQU	0

SDA		EQU	1
SCL		EQU	2

ax		EQU	int_temp0
exa		EQU	int_temp1
cnt		EQU	int_temp2
bx		EQU	int_temp3
exb		EQU	int_temp4

SLAVE_ADDR	EQU	0x41


SerIic:
	DISI
	CLR	exa
	JBC	SER_FLAG,7
	JMP	SerIic_ret			; 收到的数据没有被处理，不启动接收/发送
	JBC	SER_FLAG,6
	JMP	SerIicSend			; 有发送请求，转发送
	JBS	_P7,P_REQ
	JMP	SerIicReceive			; 请求线为低，DSP有数据需要发送，转接收
SerIic_ret:
	RETI

SerIic_fail:
	CALL	IicStop
	RETI

SerIicReceive:					; 接收
	CALL	IicStart			; 首先产生一个起始条件
	MOV	A,@((SLAVE_ADDR<<1)+1)		; 读从机
	CALL	IicSendByte			; 发送一个字节的数据
	CALL	IicGetAck			; 读ACK
	JPNZ	SerIic_fail			; 没有收到ACK，传输失败
SerIicReceive_loop:
	CALL	IicGetByte			; 读一个字节的数据
	MOV	bx,A
	XOR	A,@(0xff)
	JPZ	SerIicReceiveStop		; 收到0xff，停止信号
	MOV	A,bx
	IIC_STORE_DATA				; 保存数据
	CALL	IicSendAck			; 发送ACK
	JMP	SerIicReceive_loop
SerIicReceiveStop:
	CALL	IicSendNoAck			; 发送/ACK
	CALL	IicStop				; 停止
	BS	SER_FLAG,7			; 置收到数据标志位
	MOV	SER_CONT,exa			; 数据有效长度
	JMP	SerIic_ret

SerIicSend:					; 发送
	CALL	IicStart			; 产生一个起始条件
	MOV	A,@((SLAVE_ADDR<<1)+0)		; 写从机
	CALL	IicSendByte			; 发送地址
	CALL	IicGetAck			; 读ACK
	JPNZ	SerIic_fail			; 没有收到ACK，传输失败
	CLR	exa
SerIicSend_loop:
	IIC_GET_DATA				; 从缓冲区中取出数据
	MOV	bx,A
	XOR	A,@(0xff)
	JPZ	SerIicSendStop			; 0xff，停止信号
	MOV	A,bx
	CALL	IicSendByte			; 发送数据
	CALL	IicGetAck
	JPNZ	SerIic_fail			; 没有收到ACK，传输失败
	JMP	SerIicSend_loop
SerIicSendStop:
	CALL	IicStop				; 停止
	CLR	SER_CONT			; 复位缓冲区
	BC	SER_FLAG,6		 	; 发送完毕，复位请求发送
	JMP	SerIic_ret
	


IicStart:
	BC	_P7,SDA				; 拉低SDA线，产生一个start条件
	CALL	IicDelay			; 延时5us
	BC	_P7,SCL				; SCL变低
	CALL	IicDelay
	RET

IicStop:
	BC	_P7,SCL
	IOR	_IOC7
	AND	A,@((1<<SDA)^0xff)		; 将SDA改为输出状态
	IOW	_IOC7
	BC	_P7,SDA				; SDA输出低
	CALL	IicDelay
	CALL	IicHighScl
	CALL	IicDelay
	BS	_P7,SDA				; SDA输出高
	RET
	

IicSendByte:
	MOV	ax,A
	MOV	cnt,@(8)			; 一次发送8位
IicSendByte_loop:
	JPB	ax,7,$+3			; 数据从最高位开始发送
	BC	_P7,SDA				; 改变SDA线的状态
	JMP	$+2
	BS	_P7,SDA				; 改变SDA线的状态
	IOR	_IOC7
	AND	A,@((1<<SDA)^0xff)		; 将SDA线改为输出
	IOW	_IOC7
	RLC	ax
	CALL	IicDelay			; 延时5us
	CALL	IicHighScl			; 拉高SCL线
	CALL	IicDelay			; 延时5us
	BC	_P7,SCL				; 拉低SCL线
	DJZ	cnt
	JMP	IicSendByte_loop
	RET


IicGetByte:
	IOR	_IOC7
	OR	A,@(1<<SDA)			; 将SDA线改为输入状态
	IOW	_IOC7
	MOV	cnt,@(8)
	CLR	ax
IicGetByte_loop:
	CALL	IicDelay			; 低SCL延时
	CALL	IicHighScl			; 等待SCL变高
	CALL	IicDelay			; 延时
	BC	_STATUS,C
	JBC	_P7,SDA				; 读SDA的状态
	BS	_STATUS,C
	RLC	ax				; 保存在ax中
	BC	_P7,SCL				; SCL变低
	DJZ	cnt
	JMP	IicGetByte_loop
	MOV	A,ax
	RET
	

IicSendAck:
	BC	_P7,SDA				; ACK = 0
	JMP	IicAck

IicSendNoAck:
	BS	_P7,SDA				; ACK = 1
IicAck:
	IOR	_IOC7
	AND	A,@((1<<SDA)^0xff)		; 将SDA线改为输出
	IOW	_IOC7
	CALL	IicDelay			; 延时
	CALL	IicHighScl
	CALL	IicDelay
	BC	_P7,SCL
	RET

IicGetAck:
	IOR	_IOC7
	OR	A,@(1<<SDA)			; 将SDA线改为输入状态
	IOW	_IOC7
	CALL	IicDelay			; 延时5us
	CALL	IicHighScl			; 拉高SCL线
	CALL	IicDelay			; 延时5us
	ANDA	_P7,@(1<<SDA)			; 得到ACK状态,(z)
	BC	_P7,SCL				; 拉低SCL线
	RET



; 每条单周期指令0.6us
; 延时(2+2*X)*0.6us, X=4，延时6us。
IicDelay:
	MOV	exb,@(0x4)
	DJZ	exb
	JMP	$-1
	RET

; 将SCL线拉高，拉高之前必须检查SCL线是否为低，为低时则需要等待其变高。
IicHighScl:
	IOR	_IOC7
	OR	A,@(1<<SCL)			; 将SCL改为输入状态
	IOW	_IOC7
	JBS	_P7,SCL
	JMP	$-1				; 等待SCL线变高
	BS	_P7,SCL				; 拉高SCL线
	IOR	_IOC7
	AND	A,@((1<<SCL)^0xff)		; 将SCL改为输出状态
	IOW	_IOC7
	RET


IIC_STORE_DATA	MACRO
	MOV	ax,A
	ADDA	exa,@SER_BASE
	MOV	_RC,A
	INC	exa
	
	MOV	_RD,ax
	ENDM
	

IIC_GET_DATA	MACRO
	SUBA	exa,SER_CONT
	JPC	IIC_GET_DATA_end
	ADDA	exa,@SER_BASE
	MOV	_RC,A
	INC	exa
	
	MOV	A,_RD
	JMP	$+2
IIC_GET_DATA_end:
	MOV	A,@(0xff)
	ENDM

;---------------------------------------
; SER_STOR_DATA: 将要发送的数据存入缓冲区
; SER_BASE: 缓冲区的基地址
; SER_SEND: 缓冲区的变址
;---------------------------------------
SER_STOR_DATA:
	MOV	TEMP0,A
	
	ADDA	SER_SEND,@SER_BASE
	MOV	_RC,A
	
	INC	SER_SEND
	
	MOV	_RD,TEMP0
	RET

;---------------------------------------
; SER_GETRECED_DATA: 从缓冲区中取出收到的数据
; SER_BASE: 缓冲区的基地址
; INPUT: ACC-->缓冲区的变址
; OUTPUT: ACC-->缓冲区的变址对应的数据
SER_GETRECED_DATA:
	ADD	A,@SER_BASE
	MOV	_RC,A
	MOV	A,_RD
	RET

