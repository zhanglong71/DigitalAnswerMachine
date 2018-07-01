.LIST
LOCAL_PRO:
	;CALL	GET_RESPOND	;No getting respond
;-------------------------------------------------------------------------------
	LAC	PRO_VAR
	ANDK	0X0F
	BS	ACZ,LOCAL_PRO0		;(F0)0 = idle
	SBHK	1
	BS	ACZ,LOCAL_PROPLY	;(F1) = play memo/icm
	SBHK	1
	BS	ACZ,LOCAL_PROREC	;(F2) = record memo
	SBHK	1
	BS	ACZ,LOCAL_PROOGM	;(F3) = record/play OGM
	SBHK	1
	BS	ACZ,LOCAL_PROMNU	;(F4) = for set time and remote code
	SBHK	1
	;BS	ACZ,LOCAL_PROTWR	;(F5) = two way record
	SBHK	1
	BS	ACZ,LOCAL_PROPHO	;(F6) = for VOP test
	SBHK	1
	BS	ACZ,LOCAL_PROTXT	;(F7) = for test mode
IDLE_INVALID_MSG:
	
	RET

;-------------------------------------------------------------------------------
LOCAL_PROMNU:
;---------------�¼���Ӧ��
LOCAL_PRO0:
	LAC	PRO_VAR
	SFR	4
	ANDK	0X0F
	BS	ACZ,LOCAL_PRO0_0	;0 = idel
	SBHK	1
	BS	ACZ,LOCAL_PROKEYVP	;1 = VOP(for key mode)
	SBHK	1
	BS	ACZ,LOCAL_PROCIDVP	;2 = VOP(for CID)
	SBHK	1
	BS	ACZ,LOCAL_PROERA	;3 = Erase all old message/Del all VP
	SBHK	1
	BS	ACZ,LOCAL_PROALARM	;4 = smoke/switch/door alarm

	RET
;---------------------------------------
	
LOCAL_PRO0_0:	
	CALL	GET_MSG
	BS	ACZ,IDLE_INVALID_MSG
	SAH	MSG
;-------------------------------------------------------------------------------
	LAC	MSG
	XORL	CRING_OK
	BS	ACZ,SYS_MSG_ANS
	LAC	MSG
	XORL	CRMOT_OK
	BS	ACZ,SYS_MSG_RMT

	LAC	MSG
	XORL	CPHONE_ON
	BS	ACZ,LOCAL_PRO0_PHONE	;����HFree
	LAC	MSG
	XORL	CHOOK_OFF
	BS	ACZ,LOCAL_PRO0_HOOKOFF	;����HSet
	
	LAC	MSG
	XORL	CCID_VOP
	BS	ACZ,LOCAL_PRO0_CIDVP	;play CID data
	LAC	MSG
	XORL	CKEY_VOP
	BS	ACZ,LOCAL_PRO0_KEYVOP	;play KEY value
	
	LAC	MSG
	XORL	CMSG_SER
	BS	ACZ,LOCAL_PRO0_0_SER
	
	LAC	MSG
	XORL	CMSG_INIT		;INITIAL
	BS	ACZ,LOCAL_PRO0_INIT
;LOCAL_PRO0_0_1:
	LAC	MSG
	XORL	CMSG_PLY		;Record message
	BS	ACZ,LOCAL_PRO0_PLYMSG
;LOCAL_PRO0_0_2:
	
;LOCAL_PRO0_0_3:
	LAC	MSG
	XORL	COLD_ERAS
	BS	ACZ,LOCAL_PRO0_REAALL	;Erase all old messages
;LOCAL_PRO0_0_4:
	LAC	MSG
	XORL	CREC_MEMO		;Record message
	BS	ACZ,LOCAL_PRO0_RECMSG
;LOCAL_PRO0_0_5:
	LAC	MSG
	XORL	CMSG_KEY5S		;play OGM
	BS	ACZ,LOCAL_PRO0_PLYOGM
	LAC	MSG
	XORL	CMSG_KEY5L		;record OGM
	BS	ACZ,LOCAL_PRO0_RECOGM
;LOCAL_PRO0_0_6:
	LAC	MSG
	XORL	CPLY_HELP		;play help message
	BS	ACZ,LOCAL_PRO0_PLYHELP
	LAC	MSG
	XORL	CREC_HELP		;Record help message
	BS	ACZ,LOCAL_PRO0_RECHELP
	LAC	MSG
	XORL	CHMOD_OK		;Goto help mode(play help message 3 times)
	BS	ACZ,LOCAL_PRO0_HELPMOD
;LOCAL_PRO0_0_7:
	LAC	MSG
	XORL	CPLY_SMALM		;play smoke alarm
	BS	ACZ,LOCAL_PRO0_SMKALM
	LAC	MSG
	XORL	CPLY_SWALM		;play switch alarm
	BS	ACZ,LOCAL_PRO0_SWHALM
	LAC	MSG
	XORL	CPLY_DBELL		;play Door bell
	BS	ACZ,LOCAL_PRO0_DORBEL
;LOCAL_PRO0_0_8:
	
;LOCAL_PRO0_0_9:

;LOCAL_PRO0_0_11:
	LAC	MSG
	XORL	CMSG_TMR		;CMSG_TMR
	BS	ACZ,LOCAL_PRO0_TMR
	LAC	MSG
	XORL	CTMODE_IN
	BS	ACZ,LOCAL_PRO0_TMODE

	RET

;-------------------------------------------------------------------------------
LOCAL_PRO0_INIT:
LOCAL_PRO0_TMR:
	CALL	INIT_DAM_FUNC
	
	LACL	500
	CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1
	SAH	PRO_VAR
;---
	RET
;---------------------------------------
LOCAL_PRO0_HOOKOFF:
	BS	B1,LOCAL_PRO0_INIT
;---------------------------------------
LOCAL_PRO0_TMODE:
	CALL	INIT_DAM_FUNC
	LACL	0X5EA3
	CALL	DAM_BIOSFUNC

	LACK	0x0007
	SAH	PRO_VAR
;-------
	LACL	FlashLoc_H_f_tmode
	ADLL	FlashLoc_L_f_tmode
	CALL	SetFlashStartAddress
	nop	
	LACL	RamLoc_f_tmode
	ADLL	CodeSize_f_tmode
	CALL	LoadHostCode
;-------
	LACL	CTMODE_IN
	CALL	STOR_MSG
	
	RET

;-------------------------------------------------------------------------------
LOCAL_PRO0_REAALL:
	
	LACK	0X030
	SAH	PRO_VAR

	BS	B1,LOCAL_PRO0_LOCFVR_EXE
;---------------------------------------
LOCAL_PRO0_RECMSG:

	LACK	0X02
	SAH	PRO_VAR
LOCAL_PRO0_LOCFVR_EXE:
	CALL	INIT_DAM_FUNC
;!!!!!!
	LACL	0X5EA2
	CALL	DAM_BIOSFUNC

	CALL	LOAD_LOCF_VR
;!!!!!!
	LAC	MSG
	CALL	STOR_MSG

	
	RET
;---------------------------------------
LOCAL_PRO0_RECOGM:		;׼��¼��OGM
LOCAL_PRO0_PLYOGM:		;׼������OGM
LOCAL_PRO0_PLYHELP:		;׼������HLP
LOCAL_PRO0_RECHELP:		;׼��¼��HLP
	
	CALL	INIT_DAM_FUNC
	LACK	0X0003
	SAH	PRO_VAR
;!!!!!!
	LACL	0X5EA2
	CALL	DAM_BIOSFUNC
;!!!!!!
	LAC	MSG
	CALL	STOR_MSG
;-------
	LACL	FlashLoc_H_f_logm
	ADLL	FlashLoc_L_f_logm
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_logm
	ADLL	CodeSize_f_logm
	CALL	LoadHostCode
;-------
	RET
;---------------------------------------
LOCAL_PRO0_KEYVOP:
	LACK	0X010
	SAH	PRO_VAR
	
	BS	B1,LOCAL_PRO0_VOP
;---------------------------------------
LOCAL_PRO0_SMKALM:
LOCAL_PRO0_SWHALM:
LOCAL_PRO0_DORBEL:
	LACK	0X040
	SAH	PRO_VAR
	
	BS	B1,LOCAL_PRO0_VOP
;-------------------
LOCAL_PRO0_CIDVP:
	LACK	0X020
	SAH	PRO_VAR
	
	LACK	0
	SAH	MSG_ID
LOCAL_PRO0_VOP:	
	CALL	INIT_DAM_FUNC

	LACL	0X5EA2
	CALL	DAM_BIOSFUNC
	
	LAC	MSG
	CALL	STOR_MSG
;-------
	LACL	FlashLoc_H_f_lvop
	ADLL	FlashLoc_L_f_lvop
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_lvop
	ADLL	CodeSize_f_lvop
	CALL	LoadHostCode
;-------
	RET

;---------------------------------------
LOCAL_PRO0_PLYMSG:
	CALL	INIT_DAM_FUNC
	LACK	0X001
	SAH	PRO_VAR

	LACL	0X5EA2
	CALL	DAM_BIOSFUNC
;!!!!!!
	LAC	MSG
	CALL	STOR_MSG
;-------
	LACL	FlashLoc_H_f_lply
	ADLL	FlashLoc_L_f_lply
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_lply
	ADLL	CodeSize_f_lply
	CALL	LoadHostCode
;-------
	RET
;-------------------------------------------------------------------------------
LOCAL_PRO0_PHONE:
	CALL	INIT_DAM_FUNC
	LACK	0X006
	SAH	PRO_VAR

	LACL	0X5EA2
	CALL	DAM_BIOSFUNC
;!!!!!!	
	CALL	CLR_TIMER
	LAC	MSG
	CALL	STOR_MSG
;-------
	LACL	FlashLoc_H_f_phone
	ADLL	FlashLoc_L_f_phone
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_phone
	ADLL	CodeSize_f_phone
	CALL	LoadHostCode
;-------

	RET
;---------------------------------------
LOCAL_PRO0_HELPMOD:
	LAC	ANN_FG
	ORL	(1<<9)		;Help mode
	SAH	ANN_FG
	BS	B1,SYS_MSG_SIZELINE
;---------------
SYS_MSG_ANS:

	LAC	ANN_FG
	ANDL	~(1<<9)
	SAH	ANN_FG
	
	;LAC	ANN_FG	;????????????????????????????????????
	;ORL	(1<<9)		;Help mode
	;SAH	ANN_FG	;????????????????????????????????????
SYS_MSG_SIZELINE:	
	CALL	INIT_DAM_FUNC
	
	LACL	0X5EA3
	CALL	DAM_BIOSFUNC
	
	CALL	CLR_FUNC	;�ȿ�
	LACL	ANS_STATE	;��¼״̬
	CALL	PUSH_FUNC
	LACK	0
	SAH	PRO_VAR		;������
;-------
	LACL	FlashLoc_H_f_answer
	ADLL	FlashLoc_L_f_answer
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_answer
	ADLL	CodeSize_f_answer
	CALL	LoadHostCode
;-------
	LACL	CMSG_INIT
	CALL	STOR_MSG
	
	RET
;---------------------------------------
SYS_MSG_RMT:
	CALL	INIT_DAM_FUNC

	CALL	CLR_FUNC	;�ȿ�
	LACL	REMOTE_PRO	;����ң��
	CALL	PUSH_FUNC

;-------
	LACL	FlashLoc_H_f_remote
	ADLL	FlashLoc_L_f_remote
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_remote
	ADLL	CodeSize_f_remote
	CALL	LoadHostCode
;-------
	LACK	0
	SAH	PRO_VAR		;������
	SAH	PRO_VAR1	;��ʱ����
;	SAH	PSWORD_TMP	;�����ַ�����

	LACL	CMSG_INIT
	CALL	STOR_MSG

	RET
;-------------------------------------------------------------------------------
LOCAL_PRO0_0_SER:
;-------
	LACL	FlashLoc_H_f_IdleComm
	ADLL	FlashLoc_L_f_IdleComm
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_IdleComm
	ADLL	CodeSize_f_IdleComm
	CALL	LoadHostCode
;-------
	CALL	SER_COMMAND

	RET
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
	
.END
