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
.GLOBAL	LOCAL_PROBOOK1
;-------------------------------------------------------------------------------
.LIST
.ORG    ADDR_SECOND
;-------------------------------------------------------------------------------
;	����/�༭�绰��
;	NOTE : MSG_ID/MSG_T/MSG_N = current_TEL_ID/the total number of tel/the order of current tel
;-------------------------------------------------------------------------------
LOCAL_PROBOOK1:
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,LOCAL_PROBOOK_RING
	LAC	MSG
	XORL	CVP_STOP		;PLAY END
	BS	ACZ,LOCAL_PROBOOK_VPSTOP

	LAC	PRO_VAR
	ANDK	0X0F
	BS	ACZ,LOCAL_PROBOOK1_0	;local-idle to display
	SBHK	1
	BS	ACZ,LOCAL_PROBOOK1_1	;Display(adjust edit/search)
	SBHK	1
	BS	ACZ,LOCAL_PROBOOK1_2	;lookup phone
	SBHK	1
	BS	ACZ,LOCAL_PROBOOK1_3	;Dial

	RET
;---------------------------------------
LOCAL_PROBOOK_RING:
	CALL	INIT_DAM_FUNC
	CALL	CLR_FUNC
	LACK	0
	SAH	PRO_VAR
	CALL	BLED_ON
	LACL	CMSG_INIT
	CALL	STOR_MSG
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9E
	CALL	SEND_DAT
	LACL	6
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	
	RET
;---------------------------------------
LOCAL_PROBOOK1_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	30
	BZ	SGN,LOCAL_PROBOOK_EXIT

	RET
;---------------------------------------
LOCAL_PROBOOK_VPSTOP:
	LACK	0
	SAH	PRO_VAR1		;����������(�����ɿ���BEEP����)	
	CALL	DAA_OFF
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROBOOK1_0:
	LAC	MSG
	XORL	CMSG_KEY5S
	BS	ACZ,MAIN_PRO10_0_1_SADJ	;REW
	LAC	MSG
	XORL	CMSG_KEY9S
	BS	ACZ,MAIN_PRO10_0_1_SADJ	;FFW
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,LOCAL_PROBOOK_EXIT	;EXIT
	
	LAC	MSG
	XORL	CMSG_KEY3L
	BS	ACZ,MAIN_PRO0_PHONEBOOK		;�绰��
	LAC	MSG
	XORL	CMSG_KEY3S
	BS	ACZ,MAIN_PRO0_PHONEBOOK_TIME	;release"TIME"key
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PROBOOK1_TMR
	LAC	MSG
	XORL	CBOOK_SLET
	BS	ACZ,MAIN_PRO0_PHONEBOOK_SLCT	;�绰��ѡ����
	
	RET
;---------------------------------------
MAIN_PRO0_PHONEBOOK:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
	CALL	BLED_ON
	LACK	CGROUP_PBOOK
	CALL	SET_TELGROUP	;set group 4

	CALL	GET_TELT
	SAH	MSG_T		;ȡ����
	
	LACK	0
	SAH	MSG_N
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	LACL	0X9E		;SEND COMMAND(Enter edit menu)
	CALL	SEND_DAT
	LACK	0
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	RET
;---------------------------------------
MAIN_PRO0_PHONEBOOK_TIME:
	LACK	0X01
	SAH	PRO_VAR
	
	RET
;--------------------------------------
MAIN_PRO0_PHONEBOOK_SLCT:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP

	LACK	CGROUP_PBOOK
	CALL	SET_TELGROUP	;set group 4

	CALL	GET_TELT
	SAH	MSG_T		;ȡ����

	LACK	0X01
	SAH	PRO_VAR
	
	LACK	0
	SAH	MSG_N
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	LACL	0X9E		;SEND COMMAND(Enter edit menu)
	CALL	SEND_DAT
	LACK	0
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROBOOK1_1:		;����TIME��̧��֮���������ʼ״̬(Display Edit/Search)
;MAIN_PRO10_0_1_1:	
	LAC	MSG
	XORL	CMSG_KEY5S
	BS	ACZ,MAIN_PRO10_0_1_SADJ	;REW
;MAIN_PRO10_0_1_2:
	LAC	MSG
	XORL	CMSG_KEY9S
	BS	ACZ,MAIN_PRO10_0_1_SADJ	;FFW
;MAIN_PRO10_0_1_3:
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,LOCAL_PROBOOK_EXIT	;EXIT
;MAIN_PRO10_0_1_4:
	LAC	MSG
	XORL	CMSG_KEY3S
	BS	ACZ,MAIN_PRO10_0_1_TIME	;TIME
;MAIN_PRO10_0_1_5:	
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PROBOOK1_TMR
		
	RET
;---------------------------------------
MAIN_PRO10_0_1_SADJ:
	LAC	MSG_N
	BS	ACZ,MAIN_PRO10_0_1_SADJ_SEARCH
;MAIN_PRO10_0_1_SADJ_EDIT:	
	LACK	0
	SAH	MSG_N

	BS	B1,MAIN_PRO10_0_1_SADJ_END
MAIN_PRO10_0_1_SADJ_SEARCH:
	LACK	1
	SAH	MSG_N
MAIN_PRO10_0_1_SADJ_END:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9E
	CALL	SEND_DAT
	LAC	MSG_N
	ANDK	1		;0 or 1
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	RET

;---------------------------------------
MAIN_PRO10_0_1_TIME:
	LAC	MSG_N
	BS	ACZ,MAIN_PRO10_0_1_EDIT
	;BS	B1,MAIN_PRO10_0_1_SEARCH

MAIN_PRO10_0_1_SEARCH:		;�Ӻ�����Ŀ�����С�Ŀ�ʼ(����)
	CALL	GET_TELT
	SAH	MSG_T
	LACK	0
	SAH	MSG_ID
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X84
	CALL	SEND_DAT
	LAC	MSG_T
	CALL	SEND_DAT	;MSG_T������
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LAC	MSG_T
	BS	ACZ,MAIN_PRO10_0_2_NOTEL
	
	LACL	CMSG_KEY9S
	CALL	STOR_MSG	;��һ��

	LACK	0X02
	SAH	PRO_VAR		;�������״̬
	
	RET
;---------------------------------------
MAIN_PRO10_0_1_EDIT:			;������Ŀ
	CALL	GET_TELT
	SBHK	99
	BZ	SGN,MAIN_PRO10_0_1_BOOKFUL	;��Ŀ���ﵽ99����,����������
.if	0
.else
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
;---
	CALL	CLR_FUNC	;�ȿ�
     	LACK	0
     	SAH	PRO_VAR
     	LACL	CNUMB_BADD
     	CALL	STOR_MSG
.endif
	RET
;-----------------------------
MAIN_PRO10_0_1_BOOKFUL:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK	
	CALL	BBBEEP
	
	;LACL	0X81		;telphone book full
	;CALL	SEND_DAT
	;LACL	0X95
	;CALL	SEND_DAT
	;LACL	0XFF
	;CALL	SEND_DAT
	
	RET
;---------------------------------------
MAIN_PRO10_0_2_NOTEL:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK	
	CALL	BBBEEP

	RET
;---------------------------------------
LOCAL_PROBOOK_EXIT:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BBEEP
	
	CALL	CLR_FUNC
	LACK	0
	SAH	PRO_VAR1
	SAH	PRO_VAR
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9E		;exit COMMAND
	CALL	SEND_DAT
	LACK	6
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	RET

;-------------------------------------------------------------------------
LOCAL_PROBOOK1_2:		;����绰��
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PROBOOK1_TMR
;MAIN_PRO10_1_0_0_2:	
	LAC	MSG
	XORL	CMSG_KEY5S
	BS	ACZ,MAIN_PRO10_1_0_0_REW	;REW
;MAIN_PRO10_1_0_0_3:
	LAC	MSG
	XORL	CMSG_KEY9S
	BS	ACZ,MAIN_PRO10_1_0_0_FFW	;FFW
;MAIN_PRO10_1_0_0_4:
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,MAIN_PRO10_X_END		;EXIT
;MAIN_PRO10_1_0_0_5:
	LAC	MSG
	XORL	CMSG_KEY3S
	BS	ACZ,MAIN_PRO10_1_0_0_TIME	;TIME
;MAIN_PRO10_1_0_0_6:
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,MAIN_PRO10_1_0_0_ERASE	;ERASE
;MAIN_PRO10_1_0_0_7:	
	LAC	MSG
	XORL	CMSG_KEY5P
	BS	ACZ,MAIN_PRO10_1_0_0_PREW	;REW
;MAIN_PRO10_1_0_0_8:	
	LAC	MSG
	XORL	CMSG_KEY9P
	BS	ACZ,MAIN_PRO10_1_0_0_PFFW	;FFW
;MAIN_PRO10_1_0_0_9:
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO10_1_0_0_MENU	;MENU(�ذ�)

	RET
;---------------------------------------
MAIN_PRO10_1_0_0_MENU:
	LAC	MSG_ID
	BS	ACZ,MAIN_PRO10_WARN_VP	;��Ŀ��Ϊ��,���ܻذ�
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
	
	LACK	0X03
	SAH	PRO_VAR
	
	LACK	0
	SAH	PRO_VAR1	;���¿�ʼ��ʱ,�����ذ���������
	LACL	1000
	CALL	SET_TIMER

	RET
;---------------------------------------	
MAIN_PRO10_1_0_0_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
MAIN_PRO10_1_0_0_PFFW:
	LACK	0
	SAH	SYSTMP1
	LAC	MSG_T
	SAH	SYSTMP2

	LAC	MSG_ID
	CALL	VALUE_ADD
	SAH	MSG_ID
	BS	B1,MAIN_PRO10_1_0_REWFFWEXE
;---------------------------------------
MAIN_PRO10_1_0_0_REW:

	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
MAIN_PRO10_1_0_0_PREW:
	LACK	0
	SAH	SYSTMP1
	LAC	MSG_T
	SAH	SYSTMP2

	LAC	MSG_ID
	CALL	VALUE_SUB
	SAH	MSG_ID

MAIN_PRO10_1_0_REWFFWEXE:
	LAC	MSG_ID
	BS	ACZ,MAIN_PRO10_1_0_ENDLIST	;���鵽��0��

	LACL	0X02
	SAH	PRO_VAR		;
	
	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER	;
;������һ��(MSG_ID)������Ŀ
	LACK	CGROUP_PBOOK
	CALL	SET_TELGROUP

	LACL	TEL_RAM	;(TEL_RAM..)
	SAH	ADDR_D		;����ַ(base)
	LACK	0
	SAH	OFFSET_D	;ƫ�Ƶ�ַ(offset)

	LAC	MSG_ID		;��Ŀ��
	CALL	READ_TELNUM	;����ǰ��Ŀ����
	CALL	STOPREADDAT
;---������/����/ʱ��(�����)
	LACL	TEL_RAM		;(TEL_RAM..)
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	CALL	TEL_SENDCOMM
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9F
	CALL	SEND_DAT
	LAC	MSG_ID
	CALL	SEND_DAT	;��ʾ����
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	RET
;---------------------------------------
MAIN_PRO10_1_0_ENDLIST:		;��0��
	LAC	MSG_T
	BS	ACZ,MAIN_PRO10_1_0_NOLIST	;����Ŀ��Ϊ0
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X84
	CALL	SEND_DAT
	LAC	MSG_T
	CALL	SEND_DAT	;MSG_T������(�绰��ͬ��)
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9F
	CALL	SEND_DAT
	LACK	0		;End of list/empty
	CALL	SEND_DAT
	LACL	0X0FF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	RET
MAIN_PRO10_1_0_NOLIST:	;no list(�ڷ���/�༭����ʱ�˳�.���������ɾ����û����,�Ż�ִ�е���)
.if	1
	LACK	0X02
	SAH	PRO_VAR		;�绰��״̬
	LACL	CMSG_KEY7S
	CALL	STOR_MSG

	RET
.else
	BS	B1,MAIN_PRO10_X_END
.endif
;---------------------------------------
MAIN_PRO10_X_END:		;no save exit
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
	
	LACL	0X01
	SAH	PRO_VAR		;�绰��״̬
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	LACL	0X9E
	CALL	SEND_DAT
	LACK	0
	SAH	MSG_N
	CALL	SEND_DAT
	LACL	0X0FF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	RET
;---------------------------------------
MAIN_PRO10_1_0_0_TIME:		;����绰��ʱ����༭״̬
	LAC	MSG_ID
	BS	ACZ,MAIN_PRO10_WARN_VP	;�༭��0������
		CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
;---
	CALL	CLR_FUNC	;�ȿ�
     	LACK	0
     	SAH	PRO_VAR
     	LACL	CNUMB_EDIT
     	CALL	STOR_MSG	
	
	RET
;---------------------------------------
MAIN_PRO10_1_X_SENDCOMM:
	LAC	NEW_ID
	CALL	SEND_DAT	;��(NEW_ID)λ
	LAC	MSG_N
	CALL	SEND_DAT	;ֵ
	LACL	0XFF
	CALL	SEND_DAT	;ֵ
	
	RET
;---------------------------------------
MAIN_PRO10_WARN_VP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BBBEEP
	
	RET
;---------------------------------------
MAIN_PRO10_1_0_0_ERASE:	
	LAC	MSG_ID
	BS	ACZ,MAIN_PRO10_WARN_VP	;ɾ����0������
;---��ʽɾ�������ǰһ��,���ô˴�BEEP
MAIN_PRO10_1_0_0_ERASE_EXE:
;---ɾ����������Ŀ(MSG_ID)
	LAC	MSG_ID
	CALL	DEL_ONETEL
	CALL	TEL_GC_CHK
	CALL	GC_CHK

	CALL	GET_TELT
	SBH	MSG_T
	BS	ACZ,MAIN_PRO10_1_0_0_ERASE_EXE	;ɾ�����ɹ�������һ��

	CALL	GET_TELT
	SAH	MSG_T

	;LACK	0
	;SAH	MSG_ID
	;LACL	0X10A
	;CALL	PRO_VAR
;!!!!!!!!!!!!!!!
	LACL	0XCC
	CALL	SEND_DAT
	LACK	1
	CALL	SEND_DAT	;��(MSG_ID)������
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!
	LAC	MSG_ID
	SBHK	1
	SAH	MSG_ID		;׼����ʾ��һ��;��׼����Ŀ��
	
	BS	B1,MAIN_PRO10_1_0_0_FFW
;-------------------------------------------------------------------------------
LOCAL_PROBOOK1_3:
	LAC	PRO_VAR
	SFR	4
	ANDK	0XF
	BS	ACZ,LOCAL_PROBOOK1_3_0	;�ȴ�(�κŷ�ʽ)
	SBHK	1
	BS	ACZ,LOCAL_PROBOOK1_3_1	;��ʽ�κ�
	
	RET
;---------------------------------------
LOCAL_PROBOOK1_3_0:
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,LOCAL_PROBOOK1_3_0_MENU	;MENU
;LOCAL_PROBOOK1_3_0_1:
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PROBOOK1_3_0_TMR	;TMR
	
	RET
;---------------------------------------
LOCAL_PROBOOK1_3_0_MENU:	;��0�κ�
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP

	LACK	0X13
	SAH	PRO_VAR
	
	CALL	HOOK_ON
;!!!!!!!!!!!!!!! !!!!!!!!!!!!!  	
     	LACL	0XD0		;����MCUժ����
	CALL	SEND_DAT
	LACK	0
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!		
	LACL	0X9E		;����MCU�κ�
	CALL	SEND_DAT
	LACK	4
	CALL	SEND_DAT
	LACL	0xFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	;LACL	1000
	;CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1
	
	RET
;---------------------------------------
LOCAL_PROBOOK1_3_0_TMR:		;�κ�
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	2
	BS	SGN,LOCAL_PROBOOK1_3_0_TMR_END
	
	LACK	0X13
	SAH	PRO_VAR

	LACK	0
	SAH	PRO_VAR1
	CALL	HOOK_ON
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
     	LACL	0XD0		;����MCUժ����
	CALL	SEND_DAT
	LACK	0
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	LACL	0X9E		;����MCU�κ�
	CALL	SEND_DAT
	LACK	3
	CALL	SEND_DAT
	LACL	0xFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
LOCAL_PROBOOK1_3_0_TMR_END:

	RET
;-------------------------------------------------------------------------------
LOCAL_PROBOOK1_3_1:
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PROBOOK1_3_1_TMR	;TMR
	
	RET
;---------------------------------------
LOCAL_PROBOOK1_3_1_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	8
	BS	SGN,LOCAL_PROBOOK1_3_0_TMR_END	;�����κ������8sec�˳�

	CALL	CLR_FUNC
	LACK	0
	SAH	PRO_VAR
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XD0		;����MCU�һ���
	CALL	SEND_DAT
	LACK	1
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!		
	LACL	0X9E
	CALL	SEND_DAT
	LACK	6
	CALL	SEND_DAT
	LACL	0xFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	CALL	HOOK_OFF

	RET
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------	
.END

