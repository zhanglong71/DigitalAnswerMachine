.NOLIST
.INCLUDE MD20U.INC
.INCLUDE REG_D20.inc
.INCLUDE CONST.INC
.INCLUDE EXTERN.INC
;-------------------------------------------------------------------------------
.EXTERN	SetFlashStartAddress
.EXTERN	LoadHostCode
.EXTERN	GetOneConst	;(INPUT=ACCH(ProgramRamAddress),OUTPUT=ACCH(ReadData))
.EXTERN	GetMoreConst	;(INPUT=ACCH(ProgramRamStartingAddress)ACCL(ReadWordNumber)AR1(StoreDataRamAddress),OUTPUT=)
;-------------------------------------------------------------------------------
.GLOBAL	LOCAL_PROMENU5
;-------------------------------------------------------------------------------
.LIST
.ORG    ADDR_SECOND
;-------------------------------------------------------------------------------
LOCAL_PROMENU5:				;MENU����״̬Ҫ���ǵ���Ϣ(PRO_VAR)
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,MAIN_PROX_RINGIN
	LAC	MSG
	XORL	CMSG_TMR		;TMR
	BS	ACZ,MAIN_PRO9_TMR
	
	LAC	PRO_VAR
	ANDK	0X0F
	BS	ACZ,LOCAL_PROMENU5_0	;local-idle to adjust
	SBHK	1
	BS	ACZ,LOCAL_PROMENU5_1	;local-code
	SBHK	1
	BS	ACZ,LOCAL_PROMENU5_2	;Reserved
	
	RET
;-------common respond------------------
MAIN_PRO9_VPSTOP:
	LACK	0
	SAH	PRO_VAR1		;����������(�����ɿ���BEEP����)	
	CALL	DAA_OFF

	RET
MAIN_PRO9_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	30
	BZ	SGN,MAIN_PRO9_TMROVER
	
	RET
MAIN_PRO9_TMROVER:		;��ʱ�˳�
	BS	B1,LOCAL_PROMENU5_1_EXIT
;---------------------------------------	
LOCAL_PROMENU5_0:
	LAC	MSG
	XORL	CMENU_LCOD		;Set menu local-code
	BS	ACZ,LOCAL_PROMENU5_0_MLCOD
	
	RET
LOCAL_PROMENU5_0_MLCOD:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
	
	LAC	LOCACODE
	SFR	12
	ANDK	0X0F
	;SAH	NEW1		;load local code 1
	SAH	MSG_N
	
	LAC	LOCACODE
	SFR	8
	ANDK	0X0F
	;SAH	NEW2		;load local code 2
	
	LAC	LOCACODE
	SFR	4
	ANDK	0X0F
	;SAH	NEW3		;load local code 3
	
	LAC	LOCACODE
	ANDK	0X0F
	;SAH	NEW4		;load local code 4
	
	LAC	LOCACODE1
	ANDK	0X0F
	;SAH	NEW5		;load local code 5

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	CALL	SENDLOCACODE
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!---Display
	LACL	0X9A		;local code1
	SAH	NEW_ID
	CALL	SEND_DAT
	LAC	MSG_N		;
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	LACK	0X01
	SAH	PRO_VAR
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROMENU5_1:
;LOCAL_PROMENU5_1_0:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROMENU5_1_VPSTOP	;VP end
;LOCAL_PROMENU5_1_1:		
	LAC	MSG
	XORL	CMSG_KEY2S
	BS	ACZ,LOCAL_PROMENU5_1_REW	;REW
;LOCAL_PROMENU5_1_2:	
	LAC	MSG
	XORL	CMSG_KEY1S
	BS	ACZ,LOCAL_PROMENU5_1_FFW	;FFW
;LOCAL_PROMENU5_1_3:	
	LAC	MSG
	XORL	CMSG_KEY2P
	BS	ACZ,LOCAL_PROMENU5_1_PREW	;REW
;LOCAL_PROMENU5_1_4:	
	LAC	MSG
	XORL	CMSG_KEY1P
	BS	ACZ,LOCAL_PROMENU5_1_PFFW	;FFW
;LOCAL_PROMENU5_1_5:
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,LOCAL_PROMENU5_1_MENU	;MENU
;LOCAL_PROMENU5_1_6:
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,LOCAL_PROMENU5_1_EXIT	;STOP(��һ�β������˳�,û��Ҫ���������)
;LOCAL_PROMENU5_1_7:
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,LOCAL_PROMENU5_1_ERASE	;ERASE
	
	RET
;-------common respond------------------
LOCAL_PROMENU5_1_VPSTOP:
	LACK	0
	SAH	PRO_VAR1		;����������(�����ɿ���BEEP����)	
	CALL	DAA_OFF

	RET	
;---------------------------------------
LOCAL_PROMENU5_1_MENU:
	LAC	MSG_N		;blank ?
	ANDK	0X0F
	XORK	0X0A
	BS	ACZ,LOCAL_PROMENU5_1_SAVEEXIT	;��Ч������,������˳�
	
	LAC	NEW_ID
	XORL	0XCF
	BS	ACZ,LOCAL_PROMENU5_1_SAVEEXIT	;���һ����Ч������,������˳�
;---��Ч�������Ҳ��Ǻ���һλ
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
;---Save Local code	
	LACL	TEL_RAM		;BASE address
	SAH	ADDR_S
	SAH	ADDR_D
	LAC	NEW_ID
	CALL	COMMID_OFFSET
	SAH	OFFSET_D
	LAC	MSG_N		;ֵ
	CALL	STORBYTE_DAT
;---Get	next command
	LAC	NEW_ID
	CALL	COMM_NEXT
	SAH	NEW_ID
;---Get	next local code
	LAC	NEW_ID
	CALL	COMMID_OFFSET
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	SAH	MSG_N
LOCAL_PROMENU5_1_SENDCOMM:
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LAC	NEW_ID
	CALL	SEND_DAT
	LAC	MSG_N
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	RET
;-----------------------------------------------------------
LOCAL_PROMENU5_1_SAVEEXIT:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	
	LACL	TEL_RAM		;BASE address
	SAH	ADDR_S
	SAH	ADDR_D
;---Save Local code	
	LACL	TEL_RAM		;BASE address
	SAH	ADDR_S
	SAH	ADDR_D
	LAC	NEW_ID
	CALL	COMMID_OFFSET
	SAH	OFFSET_D
	LAC	MSG_N		;ֵ
	CALL	STORBYTE_DAT
;---
	LACK	3		;local code1
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	SAH	LOCACODE
	SFL	4
	SAH	LOCACODE
;-
	LACK	4		;local code2
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	OR	LOCACODE
	SFL	4
	SAH	LOCACODE
;-
	LACK	5		;local code3
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	OR	LOCACODE
	SFL	4
	SAH	LOCACODE
;-
	LACK	6		;local code4
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	OR	LOCACODE
	SAH	LOCACODE
;-	
	LAC	LOCACODE1
	ANDL	0xFFF0
	SAH	LOCACODE1

	LACK	7		;local code5
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	ANDK	0x0F
	OR	LOCACODE1
	SAH	LOCACODE1
;-
	LACK	11
	SAH	OFFSET_D
	LACL	0XFF
	CALL	STORBYTE_DAT	;��0XFF��β
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	CALL	SENDLOCACODE
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
.if	0
	LACK	CGROUP_DATT
	CALL	SET_TELGROUP
	LACK	1
	CALL	DEL_ONETEL
	CALL	TEL_GC_CHK
	CALL	GC_CHK
	
	LACL	TEL_RAM
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	CALL	TELNUM_WRITE	;д������	
	CALL	DAT_WRITE_STOP
.endif
;MAIN_PRO9_4_LOCCODEEXIT:
	CALL	CLR_FUNC	;goto next(RING_CNT)
	LACK	0
	SAH	PRO_VAR
	LACL	CMENU_RCNT	;�ɴ˾����������һ��
	CALL	STOR_MSG
		
	RET
;---------------------------------------
LOCAL_PROMENU5_1_REW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
LOCAL_PROMENU5_1_PREW:
	LACK	0
	SAH	SYSTMP1
	LACK	9
	SAH	SYSTMP2

	LAC	MSG_N
	CALL	VALUE_ADD
	SAH	MSG_N
	BS	B1,LOCAL_PROMENU5_1_SENDCOMM
;---------------------------------------
LOCAL_PROMENU5_1_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
LOCAL_PROMENU5_1_PFFW:
	LACK	0
	SAH	SYSTMP1
	LACK	9
	SAH	SYSTMP2

	LAC	MSG_N
	CALL	VALUE_SUB
	SAH	MSG_N

	BS	B1,LOCAL_PROMENU5_1_SENDCOMM
;---------------------------------------	
LOCAL_PROMENU5_1_ERASE:
	LAC	NEW_ID
	XORL	0X9A
	BS	ACZ,LOCAL_PROMENU5_1_ERASE_1	;��һλ?
	
	LAC	MSG_N
	SBHK	0XA
	BZ	SGN,LOCAL_PROMENU5_1_ERASE_2	;��Чλ?
;---��һλ����Ч�ǵ�һλ,����һλ���ǵ�ǰλ,֮���Ա༭��ǰλ
LOCAL_PROMENU5_1_ERASE_1:
	LACL	TEL_RAM
	SAH	ADDR_S		;BASE address
	SAH	ADDR_D

	LAC	NEW_ID
	CALL	COMMID_OFFSET
	SAH	OFFSET_D	;��ǰλΪĿ����ʼoffset
	ADHK	1
	SAH	OFFSET_S	;��ǰλ����һλΪԴ��ʼoffset
	LACK	5+3
	SBH	OFFSET_S
	SAH	COUNT		;�ƶ��ĳ���
	CALL	MOVE_HTOL
;---��0X0A��β	
	LACK	7
	SAH	OFFSET_D
	LACK	0X0A		
	CALL	STORBYTE_DAT
;---ȡ��ǰ������
	LAC	NEW_ID
	CALL	COMMID_OFFSET
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	SAH	MSG_N
	
LOCAL_PROMENU5_1_ERASE_SENDCOMM:
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	LAC	NEW_ID		;SEND COMMAND
	CALL	SEND_DAT
	LACL	0X80
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP

	RET
LOCAL_PROMENU5_1_ERASE_2:
;---�ǵ�һλ����Чλ,�õ�ǰλ����ǰһλ,֮���Ա༭ǰһλ
	LACL	TEL_RAM
	SAH	ADDR_S		;BASE address
	SAH	ADDR_D

	LAC	NEW_ID
	CALL	COMMID_OFFSET
	SAH	OFFSET_S	;��ǰλΪԴ��ʼoffset
	SBHK	1
	SAH	OFFSET_D	;��ǰλ����һλΪĿ����ʼoffset
	LACK	5+3
	SBH	OFFSET_S
	SAH	COUNT		;�ƶ��ĳ���
	CALL	MOVE_HTOL
;---��0X0A��β	
	LACK	7
	SAH	OFFSET_D
	LACK	0X0A		;��0X0F��β
	CALL	STORBYTE_DAT
;---ȡǰһλ������
	LAC	NEW_ID
	CALL	COMM_LAST
	SAH	NEW_ID

	LAC	NEW_ID
	CALL	COMMID_OFFSET
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	SAH	MSG_N
	
	BS	B1,LOCAL_PROMENU5_1_ERASE_SENDCOMM
;---------------------------------------
LOCAL_PROMENU5_1_EXIT:
	CALL	INIT_DAM_FUNC
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	CGROUP_DATETIME
	CALL	SET_TELGROUP
	
	LACK	1
	CALL	DEL_ONETEL
	CALL	TEL_GC_CHK
	CALL	GC_CHK

	CALL	DATETIME_WRITE
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
.if	1
	LACK	CGROUP_DATT
	CALL	SET_TELGROUP
	
	LACK	1
	CALL	DEL_ONETEL
	CALL	TEL_GC_CHK
	CALL	GC_CHK
	
	LACL	TEL_RAM
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	CALL	TELNUM_WRITE	;д������	
	CALL	DAT_WRITE_STOP
.endif
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	CALL	DAA_BSPK
	CALL	BBEEP		;BB
	
	LAC	VOP_FG
	ANDL	~(1<<15)
	SAH	VOP_FG
;!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	LACL	0X9E		;exit COMMAND = 0X9E+6
	CALL	SEND_DAT
	LACK	6
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	CLR_FUNC
	LACK	0
	SAH	PRO_VAR
	
	RET
;---------------------------------------
MAIN_PROX_RINGIN:
	CALL	INIT_DAM_FUNC
	
	CALL	BLED_ON
	LACL	CMSG_INIT
	CALL	STOR_MSG

	LAC	VOP_FG
	ANDL	~(1<<15)
	SAH	VOP_FG
	
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9E
	CALL	SEND_DAT
	LACL	6
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	CALL	CLR_FUNC
	LACK	0
	SAH	PRO_VAR
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROMENU5_2:
	RET
;-------------------------------------------------------------------------------
;Function : ���������������ŵõ�����������ʱ��������ƫ��
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
COMMID_OFFSET:
	SAH	SYSTMP1
	SBHL	0XCF
	BS	ACZ,COMMID_OFFSET_1	;0XCF
	
	LAC	SYSTMP1			;0X9A/0X9B/0X9C/0X9D
	ANDK	0X0F
	SBHK	7
	
	RET
COMMID_OFFSET_1:
	LACK	7
	
	RET
;-------------------------------------------------------------------------------
;Function : ���������������ŵõ���һλ�������������
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
COMM_NEXT:
	SAH	SYSTMP1

	LAC	SYSTMP1			;0X9A/0X9B/0X9C/0X9D
	SBHL	0X9A
	BS	ACZ,COMM_NEXT_1	;0X9A
	SBHK	0X01
	BS	ACZ,COMM_NEXT_2	;0X9B
	SBHK	0X01
	BS	ACZ,COMM_NEXT_3	;0X9C
	SBHK	0X01
	BS	ACZ,COMM_NEXT_4	;0X9D

	LACL	0XFF
	RET
COMM_NEXT_1:
	LACL	0X9B
	RET
COMM_NEXT_2:
	LACL	0X9C	;
	RET
COMM_NEXT_3:
	LACL	0X9D
	RET
COMM_NEXT_4:
	LACL	0XCF	;
	RET
;-------------------------------------------------------------------------------
;Function : ���������������ŵõ���һλ�������������
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
COMM_LAST:
	SAH	SYSTMP1

	LAC	SYSTMP1
	SBHL	0XCF
	BS	ACZ,COMM_LAST_4	;0XCF

	LAC	SYSTMP1			;0X9A/0X9B/0X9C/0X9D
	SBHL	0X9B
	BS	ACZ,COMM_LAST_1	;0X9B
	SBHK	0X01
	BS	ACZ,COMM_LAST_2	;0X9C
	SBHK	0X01
	BS	ACZ,COMM_LAST_3	;0X9D

	LACL	0XFF
	RET
COMM_LAST_1:
	LACL	0X9A
	RET
COMM_LAST_2:
	LACL	0X9B	;
	RET
COMM_LAST_3:
	LACL	0X9C
	RET
COMM_LAST_4:
	LACL	0X9D	;
	RET
;-------------------------------------------------------------------------------
.END

