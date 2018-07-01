SDA	.EQU		10
SCL	.EQU		11
;-------------------------------------------------------------------------------
;SER_FG		bit(7..0) : counter()
;		bit8	  : receiving
;		bit9	  : sending
;-------------------------------------------------------------------------------
;	SEND_BYTE
;	input : ACCH
;	output:	no
;-------------------------------------------------------------------------------
SEND_BYTE:
	SAH	SYSTMP0		;
	LACK	8
	SAH	SYSTMP1
SEND_BYTE_LOOP:
	CALL	DELAY_2US
	BIT	SYSTMP0,7
	BS	TB,SEND_BYTE_H
	CALL	SDA_L
	BS	B1,SEND_BYTE_1
SEND_BYTE_H:
	CALL	SDA_H
SEND_BYTE_1:
	CALL	SCL_WAIT	;Set SCL-port as a input port
	CALL	DELAY_2US
	CALL	SCL_OUT
	CALL	SCL_L
	
	LAC	SYSTMP0
	SFL	1
	SAH	SYSTMP0
	
	LAC	SYSTMP1
	SBHK	1
	SAH	SYSTMP1
	BZ	ACZ,SEND_BYTE_LOOP

	RET
;-------------------------------------------------------------------------------
;	input : no
;	output:	ACCH
;-------------------------------------------------------------------------------
RECEIVE_BYTE:
	LACK	0
	SAH	SYSTMP0
	LACK	8
	SAH	SYSTMP1
	CALL	SDA_IN
RECEIVE_BYTE_LOOP:
	LAC	SYSTMP0
	SFL	1
	SAH	SYSTMP0
	
	CALL	SCL_WAIT
	CALL	DELAY_2US
	CALL	GET_SDA
	OR	SYSTMP0
	SAH	SYSTMP0
	
	CALL	SCL_OUT
	CALL	SCL_L
	CALL	DELAY_2US
	
	LAC	SYSTMP1
	SBHK	1
	SAH	SYSTMP1
	BZ	ACZ,RECEIVE_BYTE_LOOP

	CALL	SDA_OUT
	LAC	SYSTMP0

	RET

;-------------------------------------------------------------------------------
SLAVE_ACK:		; 从机发送ACK
	CALL	SDA_IN		;set SDA as input port
	CALL	DELAY_2US
	CALL	SCL_WAIT
	CALL	DELAY_2US
	CALL	SCL_OUT
	CALL	SCL_L
	
	CALL	SDA_OUT		;set SDA as output port
	
	
	RET
;-------
HOST_ACK:		; 主机发送ACK
	CALL	SDA_OUT		;set SDA as output port
	CALL	SCL_OUT		;set SDA as output port
	CALL	SCL_L
	CALL	SDA_L
	CALL	SCL_IN
	CALL	DELAY_2US
	CALL	SCL_OUT
	CALL	SCL_L
	CALL	DELAY_2US
	CALL	DELAY_2US
	CALL	SDA_IN		;set SDA as input port
	

	RET
HOST_NACK:		; 主机发送NACK
	CALL	SDA_OUT		;set SDA as output port
	CALL	SDA_H

	CALL	SCL_IN
	CALL	DELAY_2US
	CALL	SCL_OUT
	CALL	SCL_L
	CALL	DELAY_2US
	CALL	DELAY_2US

	RET
;-------------------------------------------------------------------------------
IIC_START:
	CALL	SDA_OUT
	CALL	SDA_H

	CALL	SCL_IN
	CALL	DELAY_2US
	CALL	DELAY_2US
	CALL	DELAY_2US
	CALL	DELAY_2US
	CALL	SDA_L
	CALL	DELAY_2US
	CALL	SCL_OUT
	CALL	SCL_L

	RET

IIC_STOP:
	
	CALL	SDA_OUT
	CALL	SDA_L
	
	CALL	SCL_IN
	CALL	DELAY_2US
	CALL	SDA_H
	CALL	DELAY_2US	;停止之后总线空闲时间
	CALL	DELAY_2US
	CALL	DELAY_2US
	CALL	DELAY_2US
	CALL	SCL_OUT
	CALL	SCL_L

	RET
;---------------------------------------
SDA_IN:
	lipk	8
	IN      SYSTMP2,GPBC
	LAC	SYSTMP2
	ANDL	~(1<<SDA)
	SAH	SYSTMP2
	OUT     SYSTMP2,GPBC
	ADHK	0
	RET
SDA_OUT:
	lipk	8
	IN      SYSTMP2,GPBC
	LAC	SYSTMP2
	ORL	1<<SDA
	SAH	SYSTMP2
	OUT     SYSTMP2,GPBC
	ADHK	0
	RET
;-------
SDA_H:
	lipk	8
	IN      SYSTMP2,GPBD
	LAC	SYSTMP2
	ORL	1<<SDA
	SAH	SYSTMP2
	OUT     SYSTMP2,GPBD
	ADHK	0
	
	RET
;---
SDA_L:
	lipk	8
	IN      SYSTMP2,GPBD
	LAC	SYSTMP2
	ANDL	~(1<<SDA)
	SAH	SYSTMP2
	OUT     SYSTMP2,GPBD
	ADHK	0

	RET
;-------------------------------------------------------------------------------
;	Input :no
;	output:ACCH = 0/1
;-------------------------------------------------------------------------------
GET_SDA:
	lipk	8
	IN      SYSTMP2,GPBD
	LAC	SYSTMP2
	SFR	SDA
	ANDK	0X01
	ADHK	0

	RET
;---------------
SCL_H:
	lipk	8
	IN      SYSTMP2,GPBD
	LAC	SYSTMP2
	ORL	1<<SCL
	SAH	SYSTMP2
	OUT     SYSTMP2,GPBD
	ADHK	0

	RET
SCL_L:
	lipk	8
	IN      SYSTMP2,GPBD
	LAC	SYSTMP2
	ANDL	~(1<<SCL)
	SAH	SYSTMP2
	OUT     SYSTMP2,GPBD
	ADHK	0

	RET
;---------------
SCL_WAIT:
;---Set SCL-PORT as input port
	lipk	8
	IN      SYSTMP2,GPBC
	LAC	SYSTMP2
	ANDL	~(1<<SCL)
	SAH	SYSTMP2
	OUT     SYSTMP2,GPBC
	ADHK	0
;---wait until SCL-PORT=high
SCL_WAIT_LOOP:
	lipk	8
	IN      SYSTMP2,GPBD
	BIT	SYSTMP2,SCL
	BZ	TB,SCL_WAIT_LOOP	;
	
	RET
;---------------
SCL_IN:
;---Set SCL-PORT as output port
	lipk	8
	IN      SYSTMP2,GPBC
	LAC	SYSTMP2
	ANDL	~(1<<SCL)
	SAH	SYSTMP2
	OUT     SYSTMP2,GPBC
	ADHK	0

	RET
SCL_OUT:
;---Set SCL-PORT as output port
	lipk	8
	IN      SYSTMP2,GPBC
	LAC	SYSTMP2
	ORL	1<<SCL
	SAH	SYSTMP2
	OUT     SYSTMP2,GPBC
	ADHK	0

	RET
;-------------------------------------------------------------------------------
;	Note:23ns/cycles
;	
;	前三条指令:	1+1+1	  	=3cycles
;	最后一次循环:	1+1+1+3+1+1 	=8cycles
;	中间循环n次,每次1+1+1+4	 	=7cycles
;	(3+8+7n)*23=2000 ==> n=10
;	(3+8+7n)*23=4000 ==> n=23
;	(3+8+7n)*23=10000 ==> n=60
;-------------------------------------------------------------------------------
DELAY_2US:
DELAY_4US:
	PSH	SYSTMP2
	
	LACK	23
	SAH	SYSTMP2
DELAY_2US_1:
	LAC	SYSTMP2
	SBHK	1
	SAH	SYSTMP2
	BZ	SGN,DELAY_2US_1

	POP	SYSTMP2

	RET

;-------------------------------------------------------------------------------
.END
