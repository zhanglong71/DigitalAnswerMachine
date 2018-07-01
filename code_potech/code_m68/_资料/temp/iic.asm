/*************************************************
IIC标准协议
*************************************************/
SDA	==	4
SCL	==	5
DSP	==	7

IIC:

IicSendData:
	MOV	ax,A
	BLOCK	4
	MOV	_RC,@(2)
	INC	_RD
	ADD	_RC,_RD
	MOV	_RD,ax
	RET



SerProtocol:

IicSer:
	JPNB	hardware,POWERSTATUS,IicSer_ret
	BLOCK	4
IicSer_loop:
	DISI
	JPNB	_P8,DSP,IicSer_receive
	MOV	_RC,@(2)
	MOV	A,_RD
	JPNZ	IicSer_send
IicSer_ret:
	RETI

IicSer_fail:
	CALL	IicStop

IicSer_restart:
	ENI
	NOP
	JPB	_P7,POWERSTATUS,IicSer_loop
IicSer_powdown:
	MOV	_RC,@(1)
	MOV	cnt,@(255)
	CLR	ax
	LCALL	LibClearRam
	RETL	@(0)
	

IicSer_receive:
	CALL	IicStart			; 产生一个起始条件
	CLR	_RC
	RLCA	_RD				; 从机地址
	OR	A,@(0x01)			; 读状态
	CALL	IicSendByte			; 发送地址和读状态
	CALL	IicGetAck			; 收ACK
	JPNZ	IicSer_fail
	CALL	IicGetByte			; 第一个字节为数据长度
	JPZ	IicSer_fail			; "0"阻塞信号
	MOV	bx,A				; 长度保存在bx中
	CALL	IicStoreData
	MOV	A,bx
	CALL	IicCommandLength
	MOV	bx,A
	JMP	IicSer_receive_loop_1
IicSer_receive_loop:
	CALL	IicGetByte
	CALL	IicStoreData
IicSer_receive_loop_1:
	DJZ	bx
	JMP	$+3
	CALL	IicSendNoAck			; 最后一个字节发送NOACK
	JMP	IicSer_receive_stop		; 停止
	CALL	IicSendAck
	JMP	IicSer_receive_loop
IicSer_receive_stop:
	CALL	IicStop
	JMP	IicSer_restart

IicSer_send:
	MOV	bx,A				; 发送的长度
	MOV	_RC,@(1)
	JPB	_RD,6,IicSer_restart		; 从机忙，不能发送
	CLR	exb
	CALL	IicStart			; 产生一个起始条件
	CLR	_RC
	RLCA	_RD				; 从机地址
	AND	A,@(0xfe)			; 写状态
	CALL	IicSendByte			; 发送地址和写状态
	CALL	IicGetAck			; 得到从机的ACK
	JPNZ	IicSer_fail			; 没有得到ACK，fail
	;CALL	IicWaitDsp
	;JPZ	IicSer_fail
IicSer_send_loop:
	INC	exb
	ADDA	exb,@(2)
	MOV	_RC,A
	MOV	A,_RD				; 得到要发送的数据
	CALL	IicSendByte			; 发送数据
	CALL	IicGetAck
	JPNZ	IicSer_fail
	SUBA	exb,bx
	JPNZ	IicSer_send_loop
	CALL	IicStop				; 发送完毕，停止
	;MOV	_RC,@(1)
	;BS	_RD,6
	;BS	_RD,5
	MOV	_RC,@(2)
	CLR	_RD
	;SUB	_RD,bx
	;MOV	cnt,bx
	;ADD	A,@(3)
	;MOV	ax,A
	;MOV	bx,@(3)
	;LCALL	LibCopyRam			; 移动发送缓冲区
	JMP	IicSer_restart
	
	

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
	CALL	IicDelay
	CALL	IicDelay
	CALL	IicDelay
	CALL	IicDelay
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
	CALL	IicDelay			; 延时5us
	CALL	IicHighScl			; 拉高SCL线
	CALL	IicDelay
	CALL	IicDelay			; 延时5us
	ANDA	_P7,@(1<<SDA)			; 得到ACK状态,(z)
	BC	_P7,SCL				; 拉低SCL线
	RET
	
	

; 每条单周期指令0.6us
; 延时7*0.6us=4.2us，再加上调用时0.6us，共4.8us。
IicDelay:
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
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


IicStoreData:
	MOV	ax,A
	MOV	_RC,@(128)
	SUBA	_RD,@(0x7f)
	JPNC	$+2
	CLR	_RD
	INC	_RD
	ADD	_RC,_RD
	MOV	_RD,ax
	RET

IicCommandLength:
	ADD	A,@(0)
	JPZ	IicCommandLength_0
	ADD	A,@(0x100-0x80)
	JPZ	IicCommandLength_80
	ADD	A,@(0x80-0x7f)
	JPZ	IicCommandLength_7f
	ADD	A,@(0x7f-0x40)
	JPZ	IicCommandLength_40
	RETL	@(2)
IicCommandLength_0:
	RETL	@(1)
IicCommandLength_40:
	RETL	@(9)
IicCommandLength_7f:
	RETL	@(14)
IicCommandLength_80:
	RETL	@(58)


