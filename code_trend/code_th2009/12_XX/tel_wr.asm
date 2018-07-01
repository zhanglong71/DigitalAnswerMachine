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
	ANDK	0X7F
	
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
	SFR	8
DEL_ONETEL_END:	
	RET
;############################################################################
;
;       Function : DEL_ALLTEL
;	delete the ALL telehone number in current group and do GC_CHK
;
;	INPUT  : ACCH = the total number you will delete
;	OUTPUT :	 
;############################################################################
DEL_ALLTEL:
	SAH	SYSTMP1
DEL_ALLTEL_LOOP:	
	LAC	SYSTMP1
	ANDL	0XFF
	BS	ACZ,DEL_ALLTEL_END
	CALL	DEL_ONETEL

	CALL	TEL_GC_CHK
	CALL	GC_CHK
	LAC	SYSTMP1
	SBHK	1
	SAH	SYSTMP1

	BS	B1,DEL_ALLTEL_LOOP
DEL_ALLTEL_END:	
	
	RET
	

;############################################################################
;       Function : GET_TELUSRDAT
;	����TEL_IDȡ��USR-DAT(��ǰGroup��)
;
;	input  : ACCH = TEL_ID
;	OUTPUT : USR-DAT
;
;############################################################################
GET_TELUSRDAT:
	ANDK	0X7F
	ORL	0XEA00
	CALL	DAM_BIOSFUNC

	RET
;############################################################################
;       Function : SET_TELUSRDAT
;	Ϊ��������Ŀд��USR-DAT(��ǰGroup��û���õ���)
;
;	input  : ACCH = TEL_ID
;		 BUF1 = usr-dat
;	OUTPUT : ACCH
;
;############################################################################
SET_TELUSRDAT:
	ANDK	0X7F
	ORL	0XE700
	CALL	DAM_BIOSFUNC
	SFR	8
	
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
	BZ	ACZ,DEFATT_WRITE_END	;ps1û�������/���������
	LACK	0
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;ps2û�������/���������
	LACK	0
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;ps3û�������/���������

	LACK	4
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;����û�������/���������
	
	CALL	DAT_WRITE_STOP
DEFATT_WRITE_END:	
	RET
;############################################################################
;
;	Function : UPDATEATT_WRITE
;	��ɾ�����еģ���д���µ�(�յ�������ʱ���ϸ���)
;	Update the DAM ATT in working group
;	input  : no
;	output : ACCH = 0/!0 ==>SUCCESS/ERROR
;############################################################################
UPDATEATT_WRITE:
	CALL	GET_TELT
	SAH	SYSTMP1
	BS	ACZ,UPDATEATT_WRITE1
;---del all first
	LACK	1
	CALL	DEL_ONETEL
	CALL	TEL_GC_CHK
	CALL	GC_CHK
	BS	B1,UPDATEATT_WRITE

UPDATEATT_WRITE1:

	LAC	PASSWORD	;ps1
	SFR	8
	ANDK	0X0F
	CALL	DAT_WRITE
	BZ	ACZ,UPDATEATT_WRITE2	;Flash write error
	LAC	PASSWORD	;ps2
	SFR	4
	ANDK	0X0F
	CALL	DAT_WRITE
	BZ	ACZ,UPDATEATT_WRITE2	;Flash write error
	LAC	PASSWORD	;ps3
	ANDK	0X0F
	CALL	DAT_WRITE
	BZ	ACZ,UPDATEATT_WRITE2	;Flash write error
		
	LAC	VOI_ATT
	ANDK	0X0F
	CALL	DAT_WRITE
	BZ	ACZ,UPDATEATT_WRITE2	;Flash write error
	
	CALL	DAT_WRITE_STOP
UPDATEATT_WRITE2:	
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
	SFR	8
	
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
       	CALL    DAM_BIOSFUNC

	RET


;############################################################################
;
;	Function : TELNUM_WRITE
;	save the telephone number in working group
;
;	����ADDR_SΪ��ʼ��ַ��COUNTΪ��ʼƫ�Ƶ�����д��FLASH(��BYTEΪ��λ),��0XFF����
;	input  : COUNT = offset of first data
;		 ADDR_S = the base addr of the TEL_NUM
;	output : ACCH = 0/!0---success/error
;	variable : SYSTMP1
;
;############################################################################
TELNUM_WRITE:
	CALL	GETBYTE_DAT
	SAH	SYSTMP1
	XORL	0XFF
	BS	ACZ,TELNUM_WRITE_EXIT	;�����0XFF�ͽ���
	
	LAC	COUNT
	ADHK	1
	SAH	COUNT
	
	LAC	SYSTMP1
	CALL	DAT_WRITE
	BS	ACZ,TELNUM_WRITE	;û�������/���������
TELNUM_WRITE_EXIT:

	RET

;############################################################################

;       Function : READ_ONETELNUM
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

	LACK	1		;���������Ч
	RET
READ_ONETELNUM_END:
	CALL	STOPREADDAT

       	LACK	0	;���������Ч
;-----------------------------------------	
	RET
;############################################################################
;       Function : READ_BYTEDAT
;	���ݵõ���TEL_ID�ӵ�ǰGroup�����绰����ĵ�COUNT(���㿪ʼ)���ֽ�
;
;	input  : ACCH = TEL_ID
;		 COUNT = Ҫ�������ݵ����
;	OUTPUT : ACCH = 1/0---�����Ľ����/����Ч
;		 SYSTEMP1 = �����Ľ�� 
;
;############################################################################
READ_BYTEDAT:
	PSH	SYSTMP2
	PSH	COUNT
	
	ANDK	0X7F
	BS	ACZ,READ_BYTEDAT_END
	SAH	SYSTMP2
READ_BYTEDAT_LOOP:	
	LAC	SYSTMP2
	CALL	READ_ONETELNUM
	BS	ACZ,READ_BYTEDAT_END
	
	LAC	COUNT
	SBHK	1
	SAH	COUNT
	BZ	SGN,READ_BYTEDAT_LOOP
	
	CALL	STOPREADDAT
	
	POP	COUNT
	POP	SYSTMP2
	LACK	1		;�õ�Ԥ�ڵ�DATA
	RET
READ_BYTEDAT_END:
	POP	COUNT
	POP	SYSTMP2
       	LACK	0		;���������Ч
;-----------------------------------------	
	RET

;############################################################################

;       Function : STOPTELNUM_READ
;	ֹͣ�ӵ�ǰGroup�����绰����
;
;	input  : no
;	OUTPUT : no
;############################################################################
STOPREADDAT:
       	LACL	0XE300
       	CALL    DAM_BIOSFUNC

	RET
;############################################################################
;       Function : READ_TELNUM
;	����TEL_ID�ӵ�ǰGroup�����绰����(����Ŀ��ȫ��)
;
;	input  : ACCH = TEL_ID
;		 ADDR_D = �����ַ�Ļ���ַ
;	OUTPUT : ACCH = 
;
;	variable:SYSTMP1,SYSTMP2,COUMT
;############################################################################
.IF	1
READ_TELNUM:
	SAH	SYSTMP2
	
	MAR	+0,1
	LAR	ADDR_D,1
	
	LACK	0
	SAH	COUNT
READ_TELNUM_LOOP:	
	LAC	SYSTMP2
	CALL	READ_ONETELNUM
	BS	ACZ,READ_TELNUM_END
	LAC	SYSTMP1
	CALL	STORBYTE_DAT
	LAC	COUNT
	ADHK	1
	SAH	COUNT
	BS	B1,READ_TELNUM_LOOP
READ_TELNUM_END:

	RET

.ENDIF
;############################################################################
;	Fumction : GET_MSGID
;	�ڵ�ǰGroup�и���USER-DAT0��MSG_ID
;		��MSG_T��message����usr data0=MSG_N��message 
;		input : MSG_T = the total message in current mailbox
;			MSG_N=the specific usr data0
;		output: ACCH = the MSG_ID you find(���ʾû�ҵ�)
;############################################################################
.if	0
GET_MSGID:
	LAC	MSG_T
	SAH	MSG_ID
GET_MSGID_1:
	LAC	MSG_ID
	BS	ACZ,GET_MSGID_2		;not find
		
	LACL	0XA900 			;GET USER INDEX DATA0
	OR	MSG_ID
        CALL    DAM_BIOSFUNC
	SBH	MSG_N
	BS	ACZ,GET_MSGID_2		;find
	
	LAC	MSG_ID
	SBHK	1
	SAH	MSG_ID
	BS	B1,GET_MSGID_1		;next
GET_MSGID_2:
	LAC	MSG_ID
	
	RET
.endif

;############################################################################
;	FUNCTION : GET_TELID
;	�ڵ�ǰGroup�и���index-0��TEL_ID
;	INPUT : ACCH = index-0
;	OUTPUT: ACCH = ���ص�MSG_ID(0��ʾû�ҵ�)
;############################################################################
.IF	0
GET_TELID:
	ANDL	0XFF
	ORL	0XE900
	CALL	DAM_BIOSFUNC
	SFR	8
	BZ	ACZ,GET_TELID1
	LAC	RESP
	RET
GET_TELID1:
	LACK	0
	RET
.ENDIF
;############################################################################
;	FUNCTION : UPDATE_FLASH
;	�ڵ�ǰGroup�и���
;	INPUT : no
;	OUTPUT: ACCH = ���ص�MSG_ID(0��ʾû�ҵ�)
;############################################################################
UPDATE_FLASH:
	LACK	NEW1
	SAH	ADDR_D		;�����ַ
	SAH	ADDR_S		;��ȡ��ַ
	
	LACK	0		;ps1
	SAH	COUNT
	LAC	PASSWORD
	SFR	8
	ANDK	0X0F
	CALL	STORBYTE_DAT

	LACK	1		;ps2
	SAH	COUNT
	LAC	PASSWORD
	SFR	4
	ANDK	0X0F
	CALL	STORBYTE_DAT

	LACK	2		;ps3
	SAH	COUNT
	LAC	PASSWORD
	ANDK	0X0F
	CALL	STORBYTE_DAT

	LACK	3		;vol
	SAH	COUNT
	LAC	VOI_ATT
	ANDK	0X0F
	CALL	STORBYTE_DAT

	LACK	8
	SAH	COUNT
	LACL	0XFF
	CALL	STORBYTE_DAT	;��0XFF��β
;---del old data first
	LACK	3
	CALL	SET_TELGROUP

	LACK	1
	CALL	DEL_ONETEL
	CALL	TEL_GC_CHK
	CALL	GC_CHK
	LACK	10
	CALL	SET_DECLTEL
;---write new data
	LACK	0
	SAH	COUNT
	CALL	TELNUM_WRITE	;д������
	CALL	DAT_WRITE_STOP
	
	RET
;-------------------------------------------------------------------------------
	
.END
