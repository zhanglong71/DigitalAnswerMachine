
/*****************************
��SPIͨѶ��ʽ�Ĺ���
�������ı�ӿڡ�
��ԭ�����ж�0.5ms��ִ�иĵ�����ѭ����
һ�ν���/����start--stop��һ�����
*****************************/

SER_BASE	EQU	0XE0	; call id ram
SER_DATA	EQU	0X3F
SER_FLAG	EQU	0X3C
;	.7 �յ�һ������(1)
;	.6 ������(1)
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
	JMP	SerIic_ret			; �յ�������û�б���������������/����
	JBC	SER_FLAG,6
	JMP	SerIicSend			; �з�������ת����
	JBS	_P7,P_REQ
	JMP	SerIicReceive			; ������Ϊ�ͣ�DSP��������Ҫ���ͣ�ת����
SerIic_ret:
	RETI

SerIic_fail:
	CALL	IicStop
	RETI

SerIicReceive:					; ����
	CALL	IicStart			; ���Ȳ���һ����ʼ����
	MOV	A,@((SLAVE_ADDR<<1)+1)		; ���ӻ�
	CALL	IicSendByte			; ����һ���ֽڵ�����
	CALL	IicGetAck			; ��ACK
	JPNZ	SerIic_fail			; û���յ�ACK������ʧ��
SerIicReceive_loop:
	CALL	IicGetByte			; ��һ���ֽڵ�����
	MOV	bx,A
	XOR	A,@(0xff)
	JPZ	SerIicReceiveStop		; �յ�0xff��ֹͣ�ź�
	MOV	A,bx
	IIC_STORE_DATA				; ��������
	CALL	IicSendAck			; ����ACK
	JMP	SerIicReceive_loop
SerIicReceiveStop:
	CALL	IicSendNoAck			; ����/ACK
	CALL	IicStop				; ֹͣ
	BS	SER_FLAG,7			; ���յ����ݱ�־λ
	MOV	SER_CONT,exa			; ������Ч����
	JMP	SerIic_ret

SerIicSend:					; ����
	CALL	IicStart			; ����һ����ʼ����
	MOV	A,@((SLAVE_ADDR<<1)+0)		; д�ӻ�
	CALL	IicSendByte			; ���͵�ַ
	CALL	IicGetAck			; ��ACK
	JPNZ	SerIic_fail			; û���յ�ACK������ʧ��
	CLR	exa
SerIicSend_loop:
	IIC_GET_DATA				; �ӻ�������ȡ������
	MOV	bx,A
	XOR	A,@(0xff)
	JPZ	SerIicSendStop			; 0xff��ֹͣ�ź�
	MOV	A,bx
	CALL	IicSendByte			; ��������
	CALL	IicGetAck
	JPNZ	SerIic_fail			; û���յ�ACK������ʧ��
	JMP	SerIicSend_loop
SerIicSendStop:
	CALL	IicStop				; ֹͣ
	CLR	SER_CONT			; ��λ������
	BC	SER_FLAG,6		 	; ������ϣ���λ������
	JMP	SerIic_ret
	


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
	CALL	IicHighScl			; ����SCL��
	CALL	IicDelay			; ��ʱ5us
	ANDA	_P7,@(1<<SDA)			; �õ�ACK״̬,(z)
	BC	_P7,SCL				; ����SCL��
	RET



; ÿ��������ָ��0.6us
; ��ʱ(2+2*X)*0.6us, X=4����ʱ6us��
IicDelay:
	MOV	exb,@(0x4)
	DJZ	exb
	JMP	$-1
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
; SER_STOR_DATA: ��Ҫ���͵����ݴ��뻺����
; SER_BASE: �������Ļ���ַ
; SER_SEND: �������ı�ַ
;---------------------------------------
SER_STOR_DATA:
	MOV	TEMP0,A
	
	ADDA	SER_SEND,@SER_BASE
	MOV	_RC,A
	
	INC	SER_SEND
	
	MOV	_RD,TEMP0
	RET

;---------------------------------------
; SER_GETRECED_DATA: �ӻ�������ȡ���յ�������
; SER_BASE: �������Ļ���ַ
; INPUT: ACC-->�������ı�ַ
; OUTPUT: ACC-->�������ı�ַ��Ӧ������
SER_GETRECED_DATA:
	ADD	A,@SER_BASE
	MOV	_RC,A
	MOV	A,_RD
	RET

