.LIST

;###############################################################################
;       Function : COMP_ONETELNUM
;�����ڵ�ַ(ADDR_S/OFFSET_S)��,����ΪCOUNT��������ָ��TEL_ID�����ݽ��бȽ�
;
;	input  : ACCH = TEL_ID
;		 COUNT = �Ƚ����ݵĳ���
;		 ADDR_S = ����ȽϺ������ڵ�ַ�Ļ���ַ
;		 OFFSET_S = ����ȽϺ���������ʼƫ�Ƶ�ַ
;	OUTPUT : ACCH = 0/1 ---�����/���
;
;	variable:,SYSTMP1,SYSTMP2,COUNT,OFFSET_D
;###############################################################################
COMP_ONETELNUM:
	
	PSH	SYSTMP1
	PSH	SYSTMP2
	PSH	COUNT
	
	SAH	SYSTMP2		;save TEL_ID

	MAR	+0,1
	LAR	ADDR_S,1

	LACK	0
	SAH	OFFSET_D
COMP_ONETELNUM_0:		;�ȵ�������Ӧ�ıȽ�λ
	LAC	OFFSET_S
	SBH	OFFSET_D
	BS	ACZ,COMP_ONETELNUM_LOOP
	
	LAC	SYSTMP2
	CALL	DAT_READ
	BS	ACZ,COMP_ONETELNUM_ENDNO	;��Ч����,�˳�

	LAC	OFFSET_D
	ADHK	1
	SAH	OFFSET_D	;��һ��Ҫȡ�õ����ݵ�ƫ��
	BS	B1,COMP_ONETELNUM_0

COMP_ONETELNUM_LOOP:
	LAC	SYSTMP2
	CALL	DAT_READ
	BS	ACZ,COMP_ONETELNUM_ENDNO	;��Ч����,�˳�

	CALL	GETBYTE_DAT
	SBH	SYSTMP1
	BZ	ACZ,COMP_ONETELNUM_ENDNO	;��һ�������,�˳�

	LAC	OFFSET_D
	ADHK	1
	SAH	OFFSET_D

	;LAC	OFFSET_S
	;ADHK	1
	;SAH	OFFSET_S

	LAC	COUNT
	SBHK	1
	SAH	COUNT
	BS	SGN,COMP_ONETELNUM_ENDYES
	BZ	ACZ,COMP_ONETELNUM_LOOP	

COMP_ONETELNUM_ENDYES:		;�Ƚ����,û�ҵ�����ȵ�����
	POP	COUNT
	POP	SYSTMP2
	POP	SYSTMP1
	
	LACK	1
	
	RET
COMP_ONETELNUM_ENDNO:

	POP	COUNT
	POP	SYSTMP2
	POP	SYSTMP1

	LACK	0	;
	RET

;############################################################################
;       Function : COMP_ALLDAT
;�ӵ�ǰGroup�����绰���벢�����к���Ƚ�.����ͬ�ͷ���ACCH = TEL_ID/0
;
;	input  : ADDR_S = ����Ƚ����ݵ����ڵ�ַ�Ļ���ַ
;		 OFFSET_S = ����Ƚ����ݵ����ڵ�ַ��ƫ��
;		 COUNT = ����ȽϺ��볤��
;	OUTPUT : ACCH = 0/!0 --û�ҵ�/�ҵ��ĺ�������
;
;	variable:,SYSTMP1,SYSTMP2,SYSTMP3,COUNT
;############################################################################
COMP_ALLDAT:
	CALL	GET_TELT
	ADHK	1
	SAH	SYSTMP2

COMP_ALLDAT_LOOP_1:
	LAC	SYSTMP2
	SBHK	1
	SAH	SYSTMP2		;TEL_ID
	BS	ACZ,COMP_ALLDAT_END	;find fail

	LAC	SYSTMP2
	CALL	COMP_ONETELNUM
	BZ	ACZ,COMP_ALLDAT_END	;find ok
	
	CALL	DAT_READ_STOP
	BS	B1,COMP_ALLDAT_LOOP_1	;next one
COMP_ALLDAT_END:
	LAC	SYSTMP2

	RET
;############################################################################
;       Function : COMP_ALLTELNUM
;�ӵ�ǰGroup�����绰���벢������"����"�Ƚ�.����ͬ�ͷ���ACCH = TEL_ID/0
;
;	input  : ADDR_S = ����ȽϺ�������ڵ�ַ�Ļ���ַ
;	OUTPUT : ACCH = 0/!0 --û�ҵ�/�ҵ��ĺ�������
;
;!!!----Note : Num
;
;	variable:,SYSTMP1,SYSTMP2,SYSTMP3,COUNT
;############################################################################
COMP_ALLTELNUM:
	CALL	GET_TELT
	ADHK	1
	SAH	SYSTMP2
COMP_ALLTELNUM_LOOP_1:			;�ȱȽϺ��볤��
	LACK	5
	SAH	OFFSET_S
	SAH	OFFSET_D		;specific offset(��Ӧ���볤��)

	LAC	SYSTMP2
	SBHK	1
	SAH	SYSTMP2			;TEL_ID
	BS	ACZ,COMP_ALLTELNUM_END	;find fail
	CALL	READ_BYTEDAT
	BS	ACZ,COMP_ALLTELNUM_LOOP_1	;��Ч����(����һ��)
	LAC	SYSTMP0
	SAH	COUNT			;Ҫ�Ƚϵĺ���ĳ���

	CALL	GETBYTE_DAT
	SBH	COUNT	
	BZ	ACZ,COMP_ALLTELNUM_LOOP_1	;���볤�Ȳ����(����һ��)
	CALL	DAT_READ_STOP
;---��ʼ�ȽϺ���
	LACK	6
	SAH	OFFSET_S		;��ʼƫ��ֵ

	LAC	SYSTMP2
	CALL	COMP_ONETELNUM
	BZ	ACZ,COMP_ALLTELNUM_END
	
	CALL	DAT_READ_STOP
	BS	B1,COMP_ALLTELNUM_LOOP_1	;�������ݲ����(����һ��)
COMP_ALLTELNUM_END:
	CALL	DAT_READ_STOP
	LAC	SYSTMP2

	RET
;############################################################################
;       Function : COMP_ALLTEL
;�ӵ�ǰGroup�����绰���뼰����������"���뼰����"�Ƚ�.����ͬ�ͷ���ACCH = TEL_ID/0
;
;	input  : ADDR_S = ����ȽϺ�������ڵ�ַ�Ļ���ַ
;	OUTPUT : ACCH = 0/!0 --û�ҵ�/�ҵ��ĺ�������
;
;!!!---Note : Num+Name
;
;	variable:,SYSTMP1,SYSTMP2,SYSTMP3,COUNT
;############################################################################
COMP_ALLTEL:
	CALL	GET_TELT
	ADHK	1
	SAH	SYSTMP2
COMP_ALLTEL_LOOP_1:		;�ȱȽϺ��볤��
	LACK	5
	SAH	OFFSET_S
	SAH	OFFSET_D		;specific offset(��Ӧ���볤��)

	LAC	SYSTMP2
	SBHK	1
	SAH	SYSTMP2			;TEL_ID
	BS	ACZ,COMP_ALLTEL_END	;find fail
	CALL	READ_BYTEDAT
	BS	ACZ,COMP_ALLTEL_LOOP_1	;��Ч����(����һ��)
	LAC	SYSTMP0
	SAH	COUNT		;Ҫ�Ƚϵĺ���ĳ���

	CALL	GETBYTE_DAT
	SBH	COUNT	
	BZ	ACZ,COMP_ALLTEL_LOOP_1	;���볤�Ȳ����(����һ��)
	CALL	DAT_READ_STOP
;---��ʼ�ȽϺ���
	LACK	6
	SAH	OFFSET_S

	LAC	SYSTMP2
	CALL	COMP_ONETELNUM
	BZ	ACZ,COMP_ALLTEL_1
	
	CALL	DAT_READ_STOP
	BS	B1,COMP_ALLTEL_LOOP_1	;�������ݲ����(����һ��)
COMP_ALLTEL_1:		;����Ƚϳɹ����,��ʼ�������ֵıȽ�	
	CALL	DAT_READ_STOP

	LACK	38
	SAH	OFFSET_S
	SAH	OFFSET_D		;specific offset(��Ӧ��������)

	LAC	SYSTMP2
	CALL	READ_BYTEDAT
	BS	ACZ,COMP_ALLTEL_LOOP_1	;��Ч����(����һ��)
	LAC	SYSTMP0
	SAH	COUNT		;Ҫ�Ƚϵ������ĳ���

	CALL	GETBYTE_DAT
	SBH	COUNT	
	BZ	ACZ,COMP_ALLTEL_LOOP_1	;�������Ȳ����(����һ��)
	CALL	DAT_READ_STOP
;---��ʼ�Ƚ���������
;COMP_ALLTEL_LOOP_2:		
	LACK	39
	SAH	OFFSET_S

	LAC	SYSTMP2
	CALL	COMP_ONETELNUM
	BZ	ACZ,COMP_ALLTEL_END	;find ok
	
	CALL	DAT_READ_STOP
	BS	B1,COMP_ALLTEL_LOOP_1	;�������ݲ����(����һ��)
	
COMP_ALLTEL_END:
	CALL	DAT_READ_STOP
	LAC	SYSTMP2

	RET
;###############################################################################
;       Function : READ_BYTEDAT
;	���ݵõ���TEL_ID�ӵ�ǰGroup�����绰����ĵ�COUNT(���㿪ʼ)���ֽ�
;
;	input  : ACCH = TEL_ID
;		 OFFSET_D = Ҫ�������ݵ����
;	OUTPUT : ACCH = 1/0---�����Ľ����/����Ч
;		 SYSTEMP0 = �����Ľ�� 
;
;
;
;###############################################################################
READ_BYTEDAT:

	PSH	SYSTMP1
	PSH	OFFSET_D
	
	ANDL	0X0FF
	BS	ACZ,READ_BYTEDAT_END
	SAH	SYSTMP1
READ_BYTEDAT_LOOP:	
	LAC	SYSTMP1
	CALL	DAT_READ
	BS	ACZ,READ_BYTEDAT_END
	
	LAC	OFFSET_D
	SBHK	1
	SAH	OFFSET_D
	BZ	SGN,READ_BYTEDAT_LOOP
	
	CALL	DAT_READ_STOP
	
	POP	OFFSET_D
	POP	SYSTMP1
	LACK	1		;�õ�Ԥ�ڵ�DATA
	RET
READ_BYTEDAT_END:
	POP	OFFSET_D
	POP	SYSTMP1
       	LACK	0		;���������Ч
;-----------------------------------------

	RET
;-------------------------------------------------------------------------------
.END
