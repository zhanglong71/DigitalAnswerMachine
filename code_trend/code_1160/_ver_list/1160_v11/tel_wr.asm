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
	SFR	8
DEL_ONETEL_END:	
	RET
;############################################################################
;
;       Function : DEL_ALLTEL
;	delete the ALL telehone number in current group
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

	;CALL	TEL_GC_CHK
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
;	Ϊ��������Ŀд��index-0 before writing TEL data
;
;	input  : ACCH = usr-dat(8-ibt)
;
;	OUTPUT : ACCH
;
;############################################################################
SET_TELUSRDAT:
	ANDL	0XFF
	ORL	0XE700
	CALL	DAM_BIOSFUNC
	SFR	8
	
	RET

;############################################################################
;
;	Function : TELTIME_WRITE
;	save the time of income call in working group
;	input  : no
;	output : ACCH = 0/!0 ==>SUCCESS/ERROR
;############################################################################
TELTIME_WRITE:
;---Month	
	lipk    9
	IN	SYSTMP0,RTCMD	;month/day
	LAC	SYSTMP0
	SFR	8
	ANDK	0X03F
	CALL	DGT_HEX		;!!!!!!
	CALL	DAT_WRITE
	BZ	ACZ,TELTIME_WRITE_END	;û�������/���������
;---Day
	LAC	SYSTMP0
	ANDK	0X03F
	CALL	DGT_HEX		;!!!!!!
	CALL	DAT_WRITE
	BZ	ACZ,TELTIME_WRITE_END	;û�������/���������
;---Hour
	lipk    9
	IN	SYSTMP0,RTCWH	;week/hour
	LAC	SYSTMP0
	ANDK	0X3F
	CALL	DGT_HEX		;!!!!!!
	CALL	DAT_WRITE
	BZ	ACZ,TELTIME_WRITE_END	;û�������/���������
;---Minute
	lipk    9
	IN	SYSTMP0,RTCMS	;min/sec
	LAC	SYSTMP0
	SFR	8
	ANDK	0X07F
	CALL	DGT_HEX		;!!!!!!
	CALL	DAT_WRITE
	BZ	ACZ,TELTIME_WRITE_END	;û�������/���������

TELTIME_WRITE_END:	
	RET
;############################################################################
;
;	Function : DEFATT_WRITE
;	save the DAM ATT in working group
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
	LACK	0
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;ps4û�������/���������
;---
	LACK	0XA
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;reserved	
	LACK	0XA
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;reserved
	LACK	0XA
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;reserved
	LACK	0XA
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;reserved
;---	
	LACK	0X2
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;Rntû�������/���������
	
	LACK	0X3
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;Contrastû�������/���������
	
	LACK	0X0
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;Languageû�������/���������

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
	SFR	8
	
	RET
;############################################################################

;       Function : DAT_WRITE_STOP
;	ֹͣ�ӵ�ǰGroupд������
;
;	input  : no
;	OUTPUT : no
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
;	����ADDR_SΪ��ʼ��ַ�Ե�����д��FLASH(��BYTEΪ��λ)
;	input  : OFFSET_S = the offset addr of the TEL_NUM
;		 ADDR_S = the base addr of the TEL_NUM
;	output : ACCH = error-code(0/!0---success/error)
;	variable : SYSTMP6
;
;############################################################################
TELNUM_WRITE:
	CALL	GETBYTE_DAT
	SAH	SYSTMP1
	XORL	0XFF
	BS	ACZ,TELNUM_WRITE_EXIT	;�����0XFF�ͽ���
	
	LAC	SYSTMP1
	CALL	DAT_WRITE
	BS	ACZ,TELNUM_WRITE	;û�������/���������
TELNUM_WRITE_EXIT:
	;CALL	STOPWRITETELNUM

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
;###############################################################################
;
;       Function : READ_BYTEDAT
;	���ݵõ���TEL_ID�ӵ�ǰGroup�����绰����ĵ�OFFSET_D(���㿪ʼ)���ֽ�
;
;	input  : ACCH = TEL_ID
;		 OFFSET_D = Ҫ�������ݵ����
;	OUTPUT : ACCH = 1/0---�����Ľ����/����Ч
;		 SYSTEMP1 = �����Ľ�� 
;
;###############################################################################
READ_BYTEDAT:
	PSH	SYSTMP2
	PSH	OFFSET_D
	
	ANDK	0X7F
	BS	ACZ,READ_BYTEDAT_END
	SAH	SYSTMP2
READ_BYTEDAT_LOOP:	
	LAC	SYSTMP2
	CALL	READ_ONETELNUM
	BS	ACZ,READ_BYTEDAT_END

	LAC	OFFSET_D
	SBHK	1
	SAH	OFFSET_D
	BZ	SGN,READ_BYTEDAT_LOOP
	
	CALL	STOPREADDAT
	
	POP	OFFSET_D
	POP	SYSTMP2
	LACK	1		;�õ�Ԥ�ڵ�DATA
	RET
READ_BYTEDAT_END:
	POP	OFFSET_D
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
;		 ADDR_D = the base address
;		 OFFSET_D = the offset address
;	OUTPUT : ACCH = 
;
;	variable:SYSTMP1,SYSTMP2,COUMT
;############################################################################
READ_TELNUM:
	SAH	SYSTMP2
	
	MAR	+0,1
	LAR	ADDR_D,1

READ_TELNUM_LOOP:	
	LAC	SYSTMP2
	CALL	READ_ONETELNUM
	BS	ACZ,READ_TELNUM_END
	LAC	SYSTMP1
	CALL	STORBYTE_DAT
	BS	B1,READ_TELNUM_LOOP
READ_TELNUM_END:
	;CALL	STOPREADDAT
	
	RET
;############################################################################
;       Function : COMP_ONETELNUM
;	����TEL_ID�ӵ�ǰGroup�����绰���벢�����к���Ƚ�.�����ĵ�4(��0��ʼ)
;		��������offset = 4,���� = COUNT �����ݱȽ�
;
;	input  : ACCH = TEL_ID
;		 COUNT = �Ƚ����ݵĳ���(BYTE)
;		 OFFSET_S = ����ȽϺ���,�������ڵ�ַ����ʼƫ��(��0��ʼ)
;		 OFFSET_D = ����ȽϺ���,��Flash�ж�ȡ����ʼ���(��0��ʼ)
;		 ADDR_S = ����ȽϺ���,�����ַ�Ļ���ַ
;	OUTPUT : ACCH = 0/1 ---�����/���
;
;	variable:,SYSTMP1,SYSTMP2,SYSTMP3,COUNT
;############################################################################
COMP_ONETELNUM:
	PSH	SYSTMP1
	PSH	SYSTMP2
	
	SAH	SYSTMP2		;save TEL_ID
	
	MAR	+0,1
	LAR	ADDR_S,1

COMP_ONETELNUM_LOOP:
	LAC	SYSTMP2
	CALL	READ_BYTEDAT
	BS	ACZ,COMP_ONETELNUM_ENDNO	;��Ч����,�˳�
	
	CALL	GETBYTE_DAT
	SBH	SYSTMP1
	BZ	ACZ,COMP_ONETELNUM_ENDNO	;��һ�������,�˳�
;---���,�Ƚ���һ��

	LAC	OFFSET_D
	ADHK	1
	SAH	OFFSET_D
	
	LAC	COUNT
	SBHK	1
	SAH	COUNT
	BZ	ACZ,COMP_ONETELNUM_LOOP	

COMP_ONETELNUM_ENDYES:				;�Ƚ����,�ҵ�(SYSTMP3 = 0)
	POP	SYSTMP2
	POP	SYSTMP1
	
	LACK	1
	
	RET
COMP_ONETELNUM_ENDNO:
	POP	SYSTMP2
	POP	SYSTMP1
	
	LACK	0	;
	RET

;############################################################################
;       Function : COMP_ALLTELNUM
;	�ӵ�ǰGroup�����绰���벢�����к���Ƚ�.����ͬ�ͷ���ACCH = TEL_ID/0
;
;	input  : ADDR_S = ����ȽϺ�������ڵ�ַ�Ļ���ַ
;		 FILE_LEN = ���к���ĳ�����Ϣ���ڵ�
;	OUTPUT : ACCH = 0/!0 --û�ҵ�/�ҵ��ĺ�������
;
;	variable:,SYSTMP1,SYSTMP2,SYSTMP3,COUNT
;############################################################################
COMP_ALLTELNUM:
	CALL	GET_TELT
	ADHK	1
	SAH	SYSTMP2

	MAR	+0,1
	LAR	ADDR_S,1
COMP_ALLTELNUM_LOOP_1:
	LACK	0
	SAH	OFFSET_D			;offset
	
	LAC	SYSTMP2
	SBHK	1
	SAH	SYSTMP2				;TEL_ID
	BS	ACZ,COMP_ALLTELNUM_END		;û�ҵ�
	CALL	READ_BYTEDAT
	BS	ACZ,COMP_ALLTELNUM_LOOP_1	;��Ч����

	LAC	FILE_LEN
	XOR	SYSTMP1
	ANDK	0X7F

	BZ	ACZ,COMP_ALLTELNUM_LOOP_1	;��SYSTMP2���ĵ�OFFSET_D�ֽ���FILE_LEN���ֽ���ͬ
;---�ҵ����볤����ͬ����
	CALL	STOPREADDAT
;COMP_ALLTELNUM_LOOP_2:	
	;LAC	+0,1
	LAC	FILE_LEN
	ANDK	0X7F
	ADHK	1
	SFR	1
	SAH	COUNT			;����ռ���ֽڳ���(byte)

	LACK	4
	SAH	OFFSET_D	;�ȽϺ���,�ӵ�4����ʼ
	SAH	OFFSET_S	;�ȽϺ���,�ӵ�4����ʼ

	LAC	SYSTMP2
	BS	ACZ,COMP_ALLTELNUM_END	;û�ҵ�
	CALL	COMP_ONETELNUM
	BZ	ACZ,COMP_ALLTELNUM_END
	
	CALL	STOPREADDAT

	BS	B1,COMP_ALLTELNUM_LOOP_1
COMP_ALLTELNUM_END:

	LAC	SYSTMP2

	RET

;############################################################################
;
;       Function : TELNUMALL_DEL
;	delete the all telehone number that not mapping messages
;
;	INPUT  : no
;	OUTPUT : no
;	variable: SYSTMP1
;		 
;############################################################################
.if	1
TELNUMALL_DEL:
	LAC	MBOX_ID		;set the TEL working group
	CALL	SET_TELGROUP

	CALL	GET_TELT
	SAH	SYSTMP1
	BS	ACZ,TELNUMALL_DEL_EXIT	;no tel-number?
	
	CALL	MSG_CHK		;get the number of TOTAL messages
TELNUMALL_DEL_LOOP:
	LAC	SYSTMP1
	BS	ACZ,TELNUMALL_DEL_EXIT
	
	LACL	0XEA00
	OR	SYSTMP1
	CALL	DAM_BIOSFUNC
	SFR	8
	BZ	ACZ,TELNUMALL_DEL_EXIT
	LAC	RESP
	SAH	MSG_N		;

	CALL	GET_MSGID
	BZ	ACZ,TELNUMALL_DEL_LOOP_1
;---�ҵ���ӦTag
	LAC	SYSTMP1
	CALL	DEL_ONETEL		;û����Ӧ��¼����ɾ��֮
	CALL	TEL_GC_CHK
TELNUMALL_DEL_LOOP_1:	
	LAC	SYSTMP1
	SBHK	1
	SAH	SYSTMP1
	BS	B1,TELNUMALL_DEL_LOOP
TELNUMALL_DEL_EXIT:		
	RET
.endif
;############################################################################
;	Fumction : GET_MSGID
;	�ڵ�ǰGroup�и���only-id��MSG_ID
;		��MSG_T��message����only-id = MSG_N��message 
;		input : MSG_T = the total message in current mailbox
;			MSG_N=the specific only-id
;		output: ACCH = the MSG_ID you find(���ʾû�ҵ�)
;############################################################################
GET_MSGID:
	LAC	MSG_T
	SAH	MSG_ID
GET_MSGID_1:
	LAC	MSG_ID
	BS	ACZ,GET_MSGID_END		;not find
	ORL	0XA600
        CALL    DAM_BIOSFUNC		;GET only-id
	SBH	MSG_N
	BS	ACZ,GET_MSGID_END		;find
	
	LAC	MSG_ID
	SBHK	1
	SAH	MSG_ID
	BS	B1,GET_MSGID_1		;next
GET_MSGID_END:
	LAC	MSG_ID
	
	RET
;############################################################################
;	FUNCTION : GET_TELID
;	�ڵ�ǰGroup�и���index-0��TEL_ID
;	INPUT : ACCH = index-0
;	OUTPUT: ACCH = ���ص�MSG_ID(0��ʾû�ҵ�)
;	
;	variable : SYSTMP0
;		   SYSTMP1
;############################################################################
GET_TELID:
.if	0
	ANDL	0XFF
	ORL	0XE900
	CALL	DAM_BIOSFUNC
.else	;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	SAH	SYSTMP0
	
	LACL	0XE401
	CALL	DAM_BIOSFUNC
	ADHK	1
	SAH	SYSTMP1

GET_TELID_LOOP:
	LAC	SYSTMP1
	SBHK	1
	SAH	SYSTMP1
	BS	ACZ,GET_TELID_END
	
	LAC	SYSTMP1
	ORL	0XEA00
	CALL	DAM_BIOSFUNC
	SBH	SYSTMP0
	BZ	ACZ,GET_TELID_LOOP

	LAC	SYSTMP1
.endif
GET_TELID_END:

	RET
;-------------------------------------------------------------------------------
	
.END
