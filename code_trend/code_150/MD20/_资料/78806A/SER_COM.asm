;org 0x0400
;-------------------------------------------------------------------------
SER_BASE	EQU	0XE0	;CALL ID RAM
SER_DATA	EQU	0X3F
SER_FLAG	EQU	0X3C	
;				bit7=�յ�һ������/����
;				bit6=����
;				bit5=���ڷ�
;				bit4=������
;				bit(3..0)=CLK����
SER_CONT	EQU	0X3D
SER_SEND	EQU	0X3E
;-------------------------------------------------------------------------------
;DAT      	equ 0x03---serial's data line
;WR      	equ 0x04---serial's read and write line
;CLK      	equ 0x05---serial's clock line
;-------------------------------------------------------------------------------
P_DAT		==	3	;3
P_WR		==	4
P_CLK		==	5
;-------------------------------------------------------------------------------
;SER_FLAG
;	BIT.7	= receive end
;	BIT.6	= send request
;	BIT.5	= sending
;	BIT.4	= receiving
;	bit(3..0) = ��/��bit ����
;-------------------------------------------------------------------------------
;	SER_RECE_DATA : ���յ������ݴ��뻺����
;		SER_BASE : �������Ļ���ַ
;		SER_CONT : �������ı�ַ
;-------------------------------------------------------------------------------
SER_RECE_DATA	MACRO
	MOV	A,@SER_BASE
	ADD	A,SER_CONT
	MOV	RC,A

	MOV	A,SER_DATA
	MOV	RD,A
	
ENDM
;-------------------------------------------------------------------------------
;	SER_GET_DATA : ȡ���������д����͵�����,׼������
;		SER_BASE : �������Ļ���ַ
;		SER_CONT : �������ı�ַ
;-------------------------------------------------------------------------------
SER_GET_DATA	MACRO
	MOV	A,@SER_BASE
	ADD	A,SER_CONT
	MOV	RC,A

	MOV	A,RD
	MOV	SER_DATA,A
ENDM
;-------------------------------------------------------------------------------
;	SER_SEND_BIT : ȡ���������д����͵�����(һ��bit)
;-------------------------------------------------------------------------------
SER_SEND_BIT:
	RLC	SER_DATA
	JBC	_STATUS,C
	JMP	SER_SEND_BITH
	BC	_R7,P_DAT
	JMP	SER_SEND_BIT_END
SER_SEND_BITH:
	BS	_R7,P_DAT
SER_SEND_BIT_END:
	RET
;-------------------------------------------------------------------------------
;	SER_STOR_DATA : ��Ҫ���͵����ݴ��뻺������,������(�ദʹ��,����ĳ��ӳ���)
;			SER_BASE,SER_BASE+1,SER_BASE+2,...,SER_BASE+n
;		SER_BASE : �������Ļ���ַ
;		SER_SEND : �������ı�ַ
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
;	SER_GETRECED_DATA : �ӻ�������ȡ���յ�������
;			SER_BASE,SER_BASE+1,SER_BASE+2,...,SER_BASE+n
;		SER_BASE : �������Ļ���ַ
;		INPUT : ACC==>�������ı�ַ
;		OUTPUT: ACC==>�������ı�ַ��Ӧ������
;-------------------------------------------------------------------------------
SER_GETRECED_DATA:
	MOV	TEMP0,A
	
	MOV	A,@SER_BASE
	ADD	A,TEMP0
	MOV	RC,A

	MOV	A,RD
	RET
;--------------------------------------------------------------------
;	����ͨ��
;--------------------------------------------------------------------
SER_COMM	MACRO	;�ֶ�������
;--------------------------------------------------------------------
;	����һ:	������
;		������/�����˳�����������/������
;--------------------------------------------------------------------
SER_DET:
	JBC	SER_FLAG,4
	JMP	SER_DET_END
	JBC	SER_FLAG,5
	JMP	SER_DET_END
;---��ȫ���е�״̬�������/������
SER_DET1:
	JBC	_R7,P_WR
	JMP	SER_DET2
			;WR������Ч״̬(DSP������)
			;���չ��̿�ʼ!!!
	CLR	SER_CONT
	BS	SER_FLAG,4

	JMP	SER_DET_END
SER_DET2:		;WR������Ч״̬(��78806A��������)
	JBS	SER_FLAG,6
	JMP	SER_DET_END
			;�з�������,�÷��ͱ�־�������־��ʹWR��Ч(WR=LOW)
			;���͹��̿�ʼ!!!
	CLR	SER_CONT
	BS	SER_FLAG,5
	BC	SER_FLAG,6
	
	SER_GET_DATA	;��ʼ���͵�һ��ȡ����

	CIO	_R7,P_WR
	CIO	_R7,P_DAT
	BC	R7,P_WR	
	
	CALL	SER_SEND_BIT
	INC	SER_FLAG	;���͵�һ��������(first bit)
	JMP	CLOCK_END	;!!!!!!!!!!(��һλ�ȴ��������ʹ֮��Ϊһ������������)
SER_DET_END:

;-------------------------------------------------------------------------
;	���ֶ�:ʱ�Ӳ���������ִ��
;-------------------------------------------------------------------------
CLOCK:
	JBC	_R7,P_WR
	JMP	CLOCK4
;---�д���
	JBS	_R7,P_CLK
	JMP	CLOCK2
;----------------------------------
;---HIGH==>LOW
	JBC	SER_FLAG,4	;����ǽ��չ��̾ͼ���(�ߵ�ƽ��)
	JMP	CLOCK_COM
	JBC	SER_FLAG,5	;����Ƿ��͹��̾ͼ���(�ߵ�ƽ��)
	JMP	CLOCK_COM
	JBS	SER_FLAG,3	;����8λ(ֻ�з�����ϲŻ�ִ�е��˴�)
	JMP	CLOCK_END
	BC	SER_FLAG,3
CLOCK_COM:
	
	BC	_R7,P_CLK	;(�͵�ƽ)
	JMP	CLOCK_END
;-------------------------------------------------------------------------------
CLOCK_SEND:
;---	
	MOV	A,SER_SEND	;�����������?
	SUB	A,SER_CONT
	JBC	_STATUS,Z
	JMP	CLOCK1_1

	INC	SER_FLAG

	MOV	A,SER_FLAG		;��������(MOD 8)
	AND	A,@0X0F
	SUB	A,@0X8
	JBC	_STATUS,C
	JMP	SEREXE_SEND
	
	MOV	A,@8
	SUB	SER_FLAG,A
SEREXE_SEND:	;�����Ϳ�ʼ

	CALL	SER_SEND_BIT

	MOV	A,SER_FLAG
	AND	A,@0X0F
	SUB	A,@8
	JBS	_STATUS,Z
	JMP	SEREXE_SEND_END
;������������һ��BYTE��׼��
	INC	SER_CONT
	SER_GET_DATA		;ȡ��һ��BYTE������

SEREXE_SEND_END:
;!!!!!!!!!!!!!!!
	JMP	CLOCK_END
CLOCK1_1:		;���͹������!!!�����ر�־
	CLR	SER_FLAG
	CLR	SER_SEND

	SIO	_R7,P_WR
	SIO	_R7,P_DAT
	JMP	CLOCK_END
CLOCK1_2:		;�Ƿ��͹���
	BC	_R7,P_CLK		;(�͵�ƽ)
	JMP	CLOCK_END
;-------------------------------------------------------------------------------
CLOCK2:			;LOW==>HIGH
	BS	_R7,P_CLK
	
	JBC	SER_FLAG,4	;����ǽ��չ��̾ͼ���(�ߵ�ƽ��)
	JMP	CLOCK_RECE
	JBC	SER_FLAG,5	;����Ƿ��͹��̾ͼ���(�ߵ�ƽ��)
	JMP	CLOCK_SEND
	JMP	CLOCK_END
CLOCK4:
	;BC	SER_FLAG,4
	;JBC	_R7,P_CLK
	;JMP	CLOCK_END
	;BS	_R7,P_CLK	;CLOCK=0,(��)���һ��bit?
	;JMP	CLOCK_RECE

	JPNB	_R7,P_CLK,CLOCK5
	JPNB	SER_FLAG,4,CLOCK_END
	CLR	SER_FLAG
	JMP	CLOCK_END

CLOCK5:
	BS	_R7,P_CLK	;CLOCK=0,(��)���һ��bit?
	;JMP	CLOCK_RECE

CLOCK_RECE:	
	INC	SER_FLAG	
;-------------------------------;��������(MOD 8)
	MOV	A,SER_FLAG
	AND	A,@0X0F
	SUB	A,@0X8
	JBC	_STATUS,C
	JMP	SEREXE_RECE
	
	MOV	A,@8
	SUB	SER_FLAG,A
SEREXE_RECE:		;������տ�ʼ
;!!!!!!!!!!!!!!!	;��ʼ��(һ��bit)
	BS	_STATUS,C	
	JBS	_R7,P_DAT
	BC	_STATUS,C
	RLC	SER_DATA

	MOV	A,SER_FLAG
	AND	A,@0X0F
	SUB	A,@8
	JBS	_STATUS,Z
	JMP	SEREXE_RECE_END
;������������һ��BYTE��׼��
	SER_RECE_DATA
	INC	SER_CONT

	JBS	R7,P_WR
	JMP	SEREXE_RECE_END
	
	CLR	SER_FLAG	;���չ������!!!
	BS	SER_FLAG,7	;����ȡ�յ������ݽ��д���

SEREXE_RECE_END:
;!!!!!!!!!!!!!!!
	;JMP	CLOCK_END
CLOCK_END:
;----------------------------------------------------------------------------

ENDM

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

;eop
