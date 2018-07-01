.LIST
;############################################################################
;       Function : SET_TELGROUP
;	
;	input  : ACCH = Group_id
;	OUTPUT : no
;
;############################################################################
SET_TELGROUP:
	ANDK	0X1F
	ORL	0XE600
	CALL	DAM_BIOSFUNC

	RET
;############################################################################
;	FUNCTION : GET_TELT
;	Get the total number of current TEL group
;	INPUT : NO
;	OUTPUT : ACCH = The total number of current TEL group
;############################################################################
GET_TELT:
	LACL	0XE401
	CALL	DAM_BIOSFUNC
	ANDK	0X7F
	
	RET
;############################################################################
;	FUNCTION : GET_TELN
;	Get the total number of current TEL group
;	INPUT : NO
;	OUTPUT : ACCH = The total number of NEW TEL current TEL group
;############################################################################
.if	1
GET_TELN:
	LACL	0XE401
	CALL	DAM_BIOSFUNC
	ANDK	0X7F
	SAH	SYSTMP1
	SAH	SYSTMP2
GET_TELN_LOOP:
	LAC	SYSTMP1
	BS	ACZ,GET_TELN_END	;������,�˳�
	CALL	GET_TELUSRID1
	;SFR	8
	;BZ	ACZ,GET_TELN_END	;������,�˳�
	
	LAC	SYSTMP1
	SBHK	1
	SAH	SYSTMP1

	LAC	RESP
	BZ	ACZ,GET_TELN_LOOP
;--	
	LAC	SYSTMP2
	SBHK	1
	SAH	SYSTMP2
	BS	B1,GET_TELN_LOOP
GET_TELN_END:	
	LAC	SYSTMP2
	;adhk	1	;?????????????????????????
	
	RET
.else
;############################################################################
GET_TELN:
	LACL	0XE401
	CALL	DAM_BIOSFUNC
	ANDK	0X7F
	SAH	SYSTMP1
	
	lack	0
	SAH	SYSTMP2
GET_TELN_LOOP:
	LAC	SYSTMP1
	BS	ACZ,GET_TELN_END	;������,�˳�
	CALL	GET_TELUSRID1
	;SFR	8
	;BZ	ACZ,GET_TELN_END	;������,�˳�
	
	LAC	SYSTMP1
	SBHK	1
	SAH	SYSTMP1
	
	LAC	RESP
	XORL	CFLAG
	ANDL	0X0FF
	BZ	ACZ,GET_TELN_LOOP
;--	
	LAC	SYSTMP2
	ADHK	1
	SAH	SYSTMP2
	BS	B1,GET_TELN_LOOP
GET_TELN_END:	
	LAC	SYSTMP2
	
	RET
.endif
;############################################################################
;       Function : GET_TELUSRID0
;	
;	Get USR-DAT0 with specified TEL_ID in current working group
;	input  : ACCH(7..0)  = TEL_ID(15..8)
;		 
;
;	OUTPUT : ACCH
;############################################################################
GET_TELUSRID0:
	SAH	CONF1
	
	LACL	0XE704
	CALL	DAM_BIOSFUNC

	RET
;############################################################################
;       Function : SET_TELUSRID0
;	Ϊ��������Ŀд��INDEX-0
;
;	input  : ACCH(15..8) = Index-0
;		 ACCH(7..0)  = TEL_ID
;
;	OUTPUT : ACCH
;############################################################################
SET_TELUSRID0:
	SAH	CONF1

	LACL	0XE700
	CALL	DAM_BIOSFUNC
	SFR	8

	RET
;############################################################################
;       Function : GET_TELUSRID1
;	
;	Get USR-DAT0 with specified TEL_ID in current working group
;	input  : ACCH(7..0)  = TEL_ID(15..8)
;	OUTPUT : ACCH
;############################################################################
GET_TELUSRID1:		;Used as new flag
	SAH	CONF1
	
	LACL	0XE705
	CALL	DAM_BIOSFUNC

	RET
;############################################################################
;       Function : SET_TELUSRID1
;	Ϊ��������Ŀд��INDEX-1
;
;	input  : ACCH(15..8) = Index-1
;		 ACCH(7..0)  = TEL_ID
;
;	OUTPUT : ACCH
;############################################################################
SET_TELUSRID1:		;Used as new flag
	SAH	CONF1

	LACL	0XE701
	CALL	DAM_BIOSFUNC
	SFR	8

	RET
;############################################################################
;	FUNCTION : GETTELID_WITHUSRID0
;	�ڵ�ǰGroup�и���index-0��TEL_ID
;	INPUT : ACCH = index-0
;	OUTPUT: ACCH = ���ص�MSG_ID(0��ʾû�ҵ�)

;	input  : ACCH(15..8) = Index-0/1/2
;		 ACCH(7..0)  = TEL_ID
;############################################################################
.if	0
GETTELID_WITHUSRID0:
	SAH	CONF1
	
	LACL	0XE708
	CALL	DAM_BIOSFUNC
	SFR	8
	BZ	ACZ,GETTELID_WITHUSRID0_END
	LAC	RESP
	RET
GETTELID_WITHUSRID0_END:
	LACK	0
	RET
;############################################################################
;	FUNCTION : GETTELID_WITHUSRID1
;	�ڵ�ǰGroup�и���index-0��TEL_ID
;	INPUT : ACCH = index-0
;	OUTPUT: ACCH = ���ص�MSG_ID(0��ʾû�ҵ�)

;	input  : ACCH(15..8) = Index-1
;		 ACCH(7..0)  = TEL_ID
;############################################################################
GETTELID_WITHUSRID1:
	SAH	CONF1
	
	LACL	0XE709
	CALL	DAM_BIOSFUNC
	SFR	8
	ANDL	0XFF
	BZ	ACZ,GETTELID_WITHUSRID1_END
	LAC	RESP
	RET
GETTELID_WITHUSRID1_END:
	LACK	0
	RET
.endif
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
;       Function : DAT_READ
;	��������
;
;	input  : no
;	OUTPUT : ACCH = 0/1 ===> ��Ч/��Ч
;############################################################################
DAT_READ:
	ANDK	0X7F
	BS	ACZ,DAT_READ_END

	ORL	0XE200		;1 byte
       	CALL    DAM_BIOSFUNC
       	SAH	SYSTMP1
       	SFR     8
       	BZ      ACZ,DAT_READ_END

	LACK	1	;���������Ч
	RET
DAT_READ_END:
	CALL	DAT_READ_STOP

       	LACK	0	;���������Ч
;-----------------------------------------	
	RET
;############################################################################
;       Function : STOPTELNUM_READ
;	ֹͣ�ӵ�ǰGroup�����绰����
;
;	input  : no
;	OUTPUT : no
;############################################################################
DAT_READ_STOP:
       	LACL	0XE300
       	CALL    DAM_BIOSFUNC

	RET

;-------------------------------------------------------------------------------
	
.END
