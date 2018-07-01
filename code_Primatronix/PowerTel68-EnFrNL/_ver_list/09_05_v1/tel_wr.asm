.LIST
;############################################################################
;       Function : SET_TELGROUP
;	�õ�������Ŀ����
;
;	input  : ACCH = 
;	OUTPUT : ACCH = ������Ŀ����
;
;############################################################################
SET_TELGROUP:
	ANDK	0X1F
	ORL	0XE600
	CALL	DAM_BIOSFUNC

	RET
;############################################################################
;	FUNCTION : GET_TELT
;	�õ���ǰGroup��Ŀ����
;	INPUT : NO
;	OUTPUT: ACCH = ��ǰGroup��Ŀ����
;############################################################################
GET_TELT:
	LACL	0XE401
	CALL	DAM_BIOSFUNC

	RET
;############################################################################
;
;       Function : DEL_ONETEL
;	delete the specific telehone number
;
;	INPUT  : ACCH	= TEL_ID you will delete
;	OUTPUT :	 
;############################################################################
DEL_ONETEL:
	ANDL	0XFF
	BS	ACZ,DEL_ONETEL_END
	ORL	0XE500
	CALL	DAM_BIOSFUNC

DEL_ONETEL_END:	
	RET

;############################################################################
;
;	Function : DEFATT_WRITE
;	save the DAM ATT in flash of working group
;	input  : no
;	output : ACCH = 0/!0 ==>SUCCESS/ERROR
;############################################################################
DEFATT_WRITE:
	LACK	0
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;ps1(offset=0)û�������/���������
	LACK	0
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;ps2(offset=1)û�������/���������
	LACK	0
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;ps3(offset=2)û�������/���������
	LACK	0
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;ps4(offset=3)û�������/���������
	LACK	0
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;language(offset=4)
	LACK	0
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;reerved
	LACK	0
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;reerved
	LACK	0
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;reerved
	LACK	0
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;reerved
	LACK	0
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;reerved

	CALL	DAT_WRITE_STOP
DEFATT_WRITE_END:	
	RET

;############################################################################
;
;	Function : DAT_WRITE
;	save the DAT in working group
;	input  : ACCH = the dat write
;	output : ACCH = error code
;############################################################################	
DAT_WRITE:
	ANDL	0XFF
	ORL	0XE000
	CALL	DAM_BIOSFUNC

	RET
;############################################################################

;       Function : DAT_WRITE_STOP
;	ֹͣ�ӵ�ǰGroupд������
;
;	input  : no
;	OUTPUT : ACCH
;############################################################################
DAT_WRITE_STOP:
       	LACL	0XE100
	CALL	DAM_BIOSFUNC
	
	RET

;############################################################################
;
;	Function : TELNUM_WRITE
;	save the telephone number in working group
;
;	����(ADDR_S,OFFSET_S)Ϊ��ʼ��ַ��COUNT������д��FLASH(��BYTEΪ��λ)
;	input  : OFFSET_S = offset of first data
;		 ADDR_S = the base addr of the data
;	output : no
;	variable :
;
;############################################################################
TELNUM_WRITE:
	LAC	COUNT
	SBHK	1
	SAH	COUNT
	BS	SGN,TELNUM_WRITE_EXIT
	
	CALL	GETBYTE_DAT
	CALL	DAT_WRITE
	BS	ACZ,TELNUM_WRITE	;û�������/���������
TELNUM_WRITE_EXIT:

	RET

;############################################################################

;       Function : DAT_READ_STOP
;	���ݵõ���TEL_ID�ӵ�ǰGroup�����绰����(һ���ֽ�BYTE)
;
;	input  : ACCH = TEL_ID
;	OUTPUT : ACCH = 1/0---�����Ľ����/����Ч
;		 SYSTEMP1 = �����Ľ�� 
;
;############################################################################
READ_ONETELNUM:
	ANDK	0X7F
	BS	ACZ,READ_ONETELNUM_END

	ORL	0XE200		;1 byte
       	CALL    DAM_BIOSFUNC
       	SAH	SYSTMP1
       	SFR     8
       	BZ      ACZ,READ_ONETELNUM_END

	LACK	1	;���������Ч
	RET
READ_ONETELNUM_END:
	CALL	DAT_READ_STOP
       	LACK	0	;���������Ч
;-----------------------------------------	
	RET
;############################################################################

;       Function : DAT_READ_STOP
;	ֹͣ�ӵ�ǰGroup�����绰����
;
;	input  : no
;	OUTPUT : no
;############################################################################
DAT_READ_STOP:
	LACL	0XE300
       	CALL    DAM_BIOSFUNC

	RET
;############################################################################
;       Function : TELNUM_READ
;	����TEL_ID�ӵ�ǰGroup�����绰����(����Ŀ��ȫ��)
;
;	input  : ACCH = TEL_ID
;		 (ADDR_D,OFFSET_D) = �����ַ����ʼ��ַ
;	OUTPUT : COUNT = the number of read data(byte)
;
;	variable:SYSTMP1,COUMT
;############################################################################
TELNUM_READ:
	SAH	SYSTMP1
	
	MAR	+0,1
	LAR	ADDR_D,1
	
	LACK	0
	SAH	COUNT
TELNUM_READ_LOOP:	
	LAC	SYSTMP1
	ORL	0XE200		;1 byte
       	CALL    DAM_BIOSFUNC
       	SAH	SYSTMP0
	SFR     8
       	BZ      ACZ,TELNUM_READ_END

	LAC	SYSTMP0
	CALL	STORBYTE_DAT
	LAC	COUNT
	ADHK	1
	SAH	COUNT
	BS	B1,TELNUM_READ_LOOP
TELNUM_READ_END:
	CALL	DAT_READ_STOP

	RET

;-------------------------------------------------------------------------------
	
.END
