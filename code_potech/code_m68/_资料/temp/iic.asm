/*************************************************
IIC��׼Э��
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
	CALL	IicStart			; ����һ����ʼ����
	CLR	_RC
	RLCA	_RD				; �ӻ���ַ
	OR	A,@(0x01)			; ��״̬
	CALL	IicSendByte			; ���͵�ַ�Ͷ�״̬
	CALL	IicGetAck			; ��ACK
	JPNZ	IicSer_fail
	CALL	IicGetByte			; ��һ���ֽ�Ϊ���ݳ���
	JPZ	IicSer_fail			; "0"�����ź�
	MOV	bx,A				; ���ȱ�����bx��
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
	CALL	IicSendNoAck			; ���һ���ֽڷ���NOACK
	JMP	IicSer_receive_stop		; ֹͣ
	CALL	IicSendAck
	JMP	IicSer_receive_loop
IicSer_receive_stop:
	CALL	IicStop
	JMP	IicSer_restart

IicSer_send:
	MOV	bx,A				; ���͵ĳ���
	MOV	_RC,@(1)
	JPB	_RD,6,IicSer_restart		; �ӻ�æ�����ܷ���
	CLR	exb
	CALL	IicStart			; ����һ����ʼ����
	CLR	_RC
	RLCA	_RD				; �ӻ���ַ
	AND	A,@(0xfe)			; д״̬
	CALL	IicSendByte			; ���͵�ַ��д״̬
	CALL	IicGetAck			; �õ��ӻ���ACK
	JPNZ	IicSer_fail			; û�еõ�ACK��fail
	;CALL	IicWaitDsp
	;JPZ	IicSer_fail
IicSer_send_loop:
	INC	exb
	ADDA	exb,@(2)
	MOV	_RC,A
	MOV	A,_RD				; �õ�Ҫ���͵�����
	CALL	IicSendByte			; ��������
	CALL	IicGetAck
	JPNZ	IicSer_fail
	SUBA	exb,bx
	JPNZ	IicSer_send_loop
	CALL	IicStop				; ������ϣ�ֹͣ
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
	;LCALL	LibCopyRam			; �ƶ����ͻ�����
	JMP	IicSer_restart
	
	

IicStart:
	BC	_P7,SDA				; ����SDA�ߣ�����һ��start����
	CALL	IicDelay			; ��ʱ5us
	BC	_P7,SCL				; SCL���
	CALL	IicDelay
	RET

IicStop:
	BC	_P7,SCL
	IOR	_IOC7
	AND	A,@((1<<SDA)^0xff)		; ��SDA��Ϊ���״̬
	IOW	_IOC7
	BC	_P7,SDA				; SDA�����
	CALL	IicDelay
	CALL	IicHighScl
	CALL	IicDelay
	BS	_P7,SDA				; SDA�����
	CALL	IicDelay
	CALL	IicDelay
	CALL	IicDelay
	CALL	IicDelay
	RET
	

IicSendByte:
	MOV	ax,A
	MOV	cnt,@(8)			; һ�η���8λ
IicSendByte_loop:
	JPB	ax,7,$+3			; ���ݴ����λ��ʼ����
	BC	_P7,SDA				; �ı�SDA�ߵ�״̬
	JMP	$+2
	BS	_P7,SDA				; �ı�SDA�ߵ�״̬
	IOR	_IOC7
	AND	A,@((1<<SDA)^0xff)		; ��SDA�߸�Ϊ���
	IOW	_IOC7
	RLC	ax
	CALL	IicDelay			; ��ʱ5us
	CALL	IicHighScl			; ����SCL��
	CALL	IicDelay			; ��ʱ5us
	BC	_P7,SCL				; ����SCL��
	DJZ	cnt
	JMP	IicSendByte_loop
	RET


IicGetByte:
	IOR	_IOC7
	OR	A,@(1<<SDA)			; ��SDA�߸�Ϊ����״̬
	IOW	_IOC7
	MOV	cnt,@(8)
	CLR	ax
IicGetByte_loop:
	CALL	IicDelay			; ��SCL��ʱ
	CALL	IicHighScl			; �ȴ�SCL���
	CALL	IicDelay			; ��ʱ
	BC	_STATUS,C
	JBC	_P7,SDA				; ��SDA��״̬
	BS	_STATUS,C
	RLC	ax				; ������ax��
	BC	_P7,SCL				; SCL���
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
	AND	A,@((1<<SDA)^0xff)		; ��SDA�߸�Ϊ���
	IOW	_IOC7
	CALL	IicDelay			; ��ʱ
	CALL	IicHighScl
	CALL	IicDelay
	BC	_P7,SCL
	RET

IicGetAck:
	IOR	_IOC7
	OR	A,@(1<<SDA)			; ��SDA�߸�Ϊ����״̬
	IOW	_IOC7
	CALL	IicDelay			; ��ʱ5us
	CALL	IicDelay			; ��ʱ5us
	CALL	IicHighScl			; ����SCL��
	CALL	IicDelay
	CALL	IicDelay			; ��ʱ5us
	ANDA	_P7,@(1<<SDA)			; �õ�ACK״̬,(z)
	BC	_P7,SCL				; ����SCL��
	RET
	
	

; ÿ��������ָ��0.6us
; ��ʱ7*0.6us=4.2us���ټ��ϵ���ʱ0.6us����4.8us��
IicDelay:
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	RET

; ��SCL�����ߣ�����֮ǰ������SCL���Ƿ�Ϊ�ͣ�Ϊ��ʱ����Ҫ�ȴ����ߡ�
IicHighScl:
	IOR	_IOC7
	OR	A,@(1<<SCL)			; ��SCL��Ϊ����״̬
	IOW	_IOC7
	JBS	_P7,SCL
	JMP	$-1				; �ȴ�SCL�߱��
	BS	_P7,SCL				; ����SCL��
	IOR	_IOC7
	AND	A,@((1<<SCL)^0xff)		; ��SCL��Ϊ���״̬
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


