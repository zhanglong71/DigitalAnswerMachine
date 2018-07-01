.NOLIST
;*******************************************************************************
;*This section use to lookup tel-data(number and name)
;*
;*The program can go to here by the reason as bellow:
;*
;*Press TIME-KEY 2s in idle,respone "CMSG_KEY3L"(Display select option)
;*or
;*No save exit from edit/add TEL-data,respone "CBOOK_SLET"(Display select option)
;*or
;*Save exit from edit/add TEL-data,respone "CSTOR_TYPE"(Display the newest TEL-data)
;*--------------------------------------
;*The program can exit by the reason as bellow:
;*
;*Exit-KEY detected then exit to idle at "phone-idle" status				-Goto idle
;*or
;*Time-KEY detected then exit to idle at "phone-idle-edit" status with "CNUMB_BADD"	-Goto add TEL-data
;*or
;*Time-KEY detected then exit to idle at "TEL-lookup" status with "CNUMB_EDIT"		-Goto edit TEL-data 
;*******************************************************************************
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
	BS	ACZ,LOCAL_PRO1BOOK_VPSTOP

	LAC	PRO_VAR
	ANDK	0X0F
	BS	ACZ,LOCAL_PRO1BOOK_0	;local-idle to display
	SBHK	1
	BS	ACZ,LOCAL_PRO1BOOK_1	;disp/beep prompt
	SBHK	1
	BS	ACZ,LOCAL_PRO1BOOK_2	;lookup phone only
	SBHK	1
	BS	ACZ,LOCAL_PRO1BOOK_3	;Dial
	
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
LOCAL_PRO1BOOK_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	30
	BZ	SGN,LOCAL_PRO1BOOK_EXIT

	RET
;---------------------------------------
LOCAL_PRO1BOOK_VPSTOP:
	LACK	0
	SAH	PRO_VAR1		;����������(�����ɿ���BEEP����)	
	CALL	DAA_OFF
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PRO1BOOK_0:
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,LOCAL_PRO1BOOK_EXIT	;EXIT
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PRO1BOOK_TMR
	LAC	MSG
	XORL	CBOOK_FLT
	BS	ACZ,MAIN_PRO0_PHONEBOOK_SLCT

	RET
;---------------------------------------
MAIN_PRO0_PHONEBOOK_SLCT:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP

	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER

	LACK	CGROUP_PBOOK
	CALL	SET_TELGROUP	;set group 4
	CALL	GET_TELT
	SAH	MSG_T		;ȡ����
	
	LACK	0
	SAH	MSG_ID
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XD1		;lookup phonebook
	CALL	SEND_DAT
	LACK	2		;Filter list
	SAH	MSG_N
	CALL	SEND_DAT	;
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	0X01
	SAH	PRO_VAR
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PRO1BOOK_1:
;MAIN_PRO10_0_1_1:
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,LOCAL_PRO1BOOK_EXIT	;EXIT
;MAIN_PRO10_0_1_4:
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,LOCAL_PRO1BOOK_1_0_MENU	;MENU
;MAIN_PRO10_0_1_5:	
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PRO1BOOK_1_TMR
		
	RET
;---------------------------------------
LOCAL_PRO1BOOK_1_TMR:
	LACK	0X02
	SAH	PRO_VAR

	CALL	GET_TELT
	SAH	MSG_T

	LAC	MSG_T
	BS	ACZ,LOCAL_PRO1BOOK_1_TMR_1
	
	LACL	CMSG_KEY1P	
	CALL	STOR_MSG
LOCAL_PRO1BOOK_1_TMR_1:
	RET
;---------------------------------------
LOCAL_PRO1BOOK_1_0_MENU:	;�Ӻ�����Ŀ�����С�Ŀ�ʼ(����)
	CALL	INIT_DAM_FUNC
	;CALL	DAA_BSPK
	;CALL	BEEP

	LACK	0X02
	SAH	PRO_VAR		;Goto select normal/VIP/Filter
	
	CALL	GET_TELT
	SAH	MSG_T

	LAC	MSG_T
	BS	ACZ,LOCAL_PRO1BOOK_WORN
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XD1		;lookup phonebook
	CALL	SEND_DAT
	LACK	2		;Filter list
	SAH	MSG_N
	CALL	SEND_DAT	;
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	CMSG_KEY1S
	CALL	STOR_MSG
	
	RET
;---------------------------------------
LOCAL_PRO1BOOK_WORN:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BBBEEP

	RET
;---------------------------------------
LOCAL_PRO1BOOK_EXIT:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BBEEP
	
	CALL	CLR_FUNC
	LACK	0
	SAH	PRO_VAR1
	SAH	PRO_VAR

	LAC	VOP_FG
	ANDL	~(1<<15)
	SAH	VOP_FG
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9E		;exit COMMAND
	CALL	SEND_DAT
	LACK	6
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	RET
;-------------------------------------------------------------------------------
LOCAL_PRO1BOOK_2:			;����(Filter)�绰��
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PRO1BOOK_TMR
;LOCAL_PROBOOK1_2_0_2:	
	LAC	MSG
	XORL	CMSG_KEY2S
	BS	ACZ,LOCAL_PRO1BOOK_2_REW	;REW(last one)
;LOCAL_PROBOOK1_2_0_3:
	LAC	MSG
	XORL	CMSG_KEY1S
	BS	ACZ,LOCAL_PRO1BOOK_2_FFW	;FFW(next one)
;LOCAL_PROBOOK1_2_0_4:
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,LOCAL_PRO1BOOK_2_END	;EXIT(exit to serach/add)
;LOCAL_PROBOOK1_2_0_5:
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,LOCAL_PRO1BOOK_2_ERASE	;ERASE
;LOCAL_PROBOOK1_2_0_7:	
	LAC	MSG
	XORL	CMSG_KEY2P
	BS	ACZ,LOCAL_PRO1BOOK_2_PREW	;REW
;LOCAL_PROBOOK1_2_0_8:	
	LAC	MSG
	XORL	CMSG_KEY1P
	BS	ACZ,LOCAL_PRO1BOOK_2_PFFW	;FFW
;LOCAL_PROBOOK1_2_0_9:
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,LOCAL_PRO1BOOK_2_MENU	;MENU-exit

	RET
;---------------------------------------
LOCAL_PRO1BOOK_2_MENU:		;exit
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BBEEP
	
	LACK	0
	SAH	PRO_VAR1	;���¿�ʼ��ʱ,�����ذ���������
	LACL	1000
	CALL	SET_TIMER

	CALL	CLR_FUNC
	LACK	0
	SAH	PRO_VAR1
	SAH	PRO_VAR

	LAC	VOP_FG
	ANDL	~(1<<15)
	SAH	VOP_FG
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9E		;exit COMMAND
	CALL	SEND_DAT
	LACK	6
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	RET
;---------------------------------------	
LOCAL_PRO1BOOK_2_FFW:		;next one
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
LOCAL_PRO1BOOK_2_PFFW:
	LACK	0
	SAH	SYSTMP1
	LAC	MSG_T
	SAH	SYSTMP2

	LAC	MSG_ID
	CALL	VALUE_SUB
	SAH	MSG_ID
	
LOCAL_PRO1BOOK_2_PFFW_1:
;---�ҵ���Ӧ���͵ĺ��� 
	BS	B1,LOCAL_PRO1BOOK_2_REWFFWEXE
;---------------------------------------
LOCAL_PRO1BOOK_2_REW:		;last one
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
LOCAL_PRO1BOOK_2_PREW:
	LACK	0
	SAH	SYSTMP1
	LAC	MSG_T
	SAH	SYSTMP2

	LAC	MSG_ID
	CALL	VALUE_ADD
	SAH	MSG_ID
	
LOCAL_PROBOOK1_2_PREW_1:
;---�ҵ���Ӧ���͵ĺ��� 	
LOCAL_PRO1BOOK_2_REWFFWEXE:
	LACL	0X02
	SAH	PRO_VAR		;
	
	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER	;
;---Set Pbook-group
	LACK	CGROUP_PBOOK
	CALL	SET_TELGROUP
;---������һ��(MSG_ID)������Ŀ
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
LOCAL_PRO1BOOK_2_END:		;no save exit
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP

	CALL	CLR_FUNC
	LACK	0
	SAH	PRO_VAR1
	SAH	PRO_VAR

	LAC	VOP_FG
	ANDL	~(1<<15)
	SAH	VOP_FG
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9E		;exit COMMAND
	CALL	SEND_DAT
	LACK	6
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	RET

;---------------------------------------
LOCAL_PRO1BOOK_2_WARNVP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BBBEEP
	
	RET
;---------------------------------------
LOCAL_PRO1BOOK_2_ERASE:	
	LAC	MSG_ID
	BS	ACZ,LOCAL_PRO1BOOK_2_WARNVP	;ɾ����0������
;---��ʽɾ�������ǰһ��,���ô˴�BEEP
LOCAL_PRO1BOOK_2_ERASE_EXE:
;---ɾ����������Ŀ(MSG_ID)
	LAC	MSG_ID
	CALL	DEL_ONETEL
	CALL	TEL_GC_CHK
	CALL	GC_CHK

	CALL	GET_TELT
	SBH	MSG_T
	BS	ACZ,LOCAL_PRO1BOOK_2_ERASE_EXE	;ɾ�����ɹ�������һ��

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
	
	BS	B1,LOCAL_PRO1BOOK_2_FFW

;-------------------------------------------------------------------------------
LOCAL_PRO1BOOK_3:
	LAC	PRO_VAR
	SFR	4
	ANDK	0XF
	BS	ACZ,LOCAL_PRO1BOOK_3_0	;�ȴ�(�κŷ�ʽ)
	SBHK	1
	BS	ACZ,LOCAL_PRO1BOOK_3_1	;��ʽ�κ�
	
	RET
;---------------------------------------
LOCAL_PRO1BOOK_3_0:
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,LOCAL_PRO1BOOK_3_0_MENU	;MENU
;LOCAL_PRO1BOOK_3_0_1:
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PRO1BOOK_3_0_TMR	;TMR
	
	RET
;---------------------------------------
LOCAL_PRO1BOOK_3_0_MENU:	;��0�κ�
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
LOCAL_PRO1BOOK_3_0_TMR:		;�κ�
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	2
	BS	SGN,LOCAL_PRO1BOOK_3_0_TMR_END
	
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
LOCAL_PRO1BOOK_3_0_TMR_END:

	RET
;-------------------------------------------------------------------------------
LOCAL_PRO1BOOK_3_1:
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PRO1BOOK_3_1_TMR	;TMR
	
	RET
;---------------------------------------
LOCAL_PRO1BOOK_3_1_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	8
	BS	SGN,LOCAL_PRO1BOOK_3_0_TMR_END	;�����κ������8sec�˳�

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
.INCLUDE l_tel.asm
;-------------------------------------------------------------------------------	
.END

