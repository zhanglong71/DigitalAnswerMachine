.LIST
;############################################################################
;       Function : SET_TELGROUP
;	�õ�������Ŀ����
;
;	input  : ACCH = Group_id
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
	LACK	0
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;ps4û�������/���������

	;LAC	DAM_ATT
	;CALL	DAT_WRITE
	;BZ	ACZ,DEFATT_WRITE_END	;DAM_ATTû�������/���������
	
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
UPDATEATT_WRITE_LOOP:
	BS	ACZ,UPDATEATT_WRITE1
	
	CALL	DEL_ONETEL
	LAC	SYSTMP1
	SBHK	1
	SAH	SYSTMP1
	BS	B1,UPDATEATT_WRITE_LOOP
	
UPDATEATT_WRITE1:
	LAC	PASSWORD	;ps1
	SFR	12
	ANDK	0X0F
	CALL	DAT_WRITE
	BZ	ACZ,UPDATEATT_WRITE2	;Flash write error
	LAC	PASSWORD	;ps2
	SFR	8
	ANDK	0X0F
	CALL	DAT_WRITE
	BZ	ACZ,UPDATEATT_WRITE2	;Flash write error
	LAC	PASSWORD	;ps3
	SFR	4
	ANDK	0X0F
	CALL	DAT_WRITE
	BZ	ACZ,UPDATEATT_WRITE2	;Flash write error
	LAC	PASSWORD	;ps4
	ANDK	0X0F
	CALL	DAT_WRITE
	BZ	ACZ,UPDATEATT_WRITE2	;Flash write error
		
	;LAC	DAM_ATT
	;CALL	DAT_WRITE
	;BZ	ACZ,UPDATEATT_WRITE2	;Flash write error
	
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
;-------------------------------------------------------------------------------
;	Function : WRITE_EMPCID
;	���Group0����CID���˳�
;	���Group0��û��CID��д��һ��û�к����CID
;	input : no
;	output: no
;-------------------------------------------------------------------------------
WRITE_EMPCID:
	LACK	0
	CALL	SET_TELGROUP

	CALL	GET_TELT
	BZ	ACZ,WRITE_EMPCID_END
	
	CALL	TELTIME_WRITE
	LACK	0		;NUM-LENGTH
	CALL	DAT_WRITE
	LACK	0		;NAME-LENGTH
	CALL	DAT_WRITE
	CALL	DAT_WRITE_STOP
WRITE_EMPCID_END:
	RET
;############################################################################
;
;	Function : TELTIME_WRITE
;	save the TIME in working group
;
;	����ʱ��������е�����д��FLASH(��BYTEΪ��λ),
;	input  : no
;	output : ACCH = 0/!0---success/error
;	variable : SYSTMP1
;
;############################################################################
TELTIME_WRITE:
	;LAC	TMR_MIN
	CALL	HEX_DGT
	CALL	DAT_WRITE	;��
	BZ	ACZ,TELTIME_WRITE_EXIT	;û�������/���������
	;LAC	TMR_HOUR
	CALL	HEX_DGT
	CALL	DAT_WRITE	;ʱ
	BZ	ACZ,TELTIME_WRITE_EXIT	;û�������/���������
	;LAC	TMR_DAY
	CALL	HEX_DGT
	CALL	DAT_WRITE	;��
	BZ	ACZ,TELTIME_WRITE_EXIT	;û�������/���������
	;LAC	TMR_MONTH
	CALL	HEX_DGT
	CALL	DAT_WRITE	;��
TELTIME_WRITE_EXIT:
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
	
	CALL	VPMSG_CHK		;get the number of TOTAL messages
TELNUMALL_DEL_LOOP:
	LAC	SYSTMP1
	BS	ACZ,TELNUMALL_DEL_EXIT
	
	LACL	0XEA00
	OR	SYSTMP1
	CALL	DAM_BIOSFUNC
	SFR	8
	BZ	ACZ,TELNUMALL_DEL_EXIT
	LAC	RESP
	SAH	MSG_N
	
	CALL	GET_MSGID
	BZ	ACZ,TELNUMALL_DEL_LOOP_1

	LAC	SYSTMP1
	CALL	DEL_ONETEL		;û����Ӧ��¼����ɾ��֮
	
	CALL	TEL_GC_CHK
	CALL	GC_CHK
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
;	�ڵ�ǰGroup�и���USER-DAT0��MSG_ID
;		��MSG_T��message����usr data0=MSG_N��message 
;		input : MSG_T = the total message in current mailbox
;			MSG_N=the specific usr data0
;		output: ACCH = the MSG_ID you find(���ʾû�ҵ�)
;############################################################################
.if	1
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
;-------------------------------------------------------------------------------
	
.END
