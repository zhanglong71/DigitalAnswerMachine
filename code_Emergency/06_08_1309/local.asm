.LIST
LOCAL_PRO:
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
	;BS	ACZ,LOCAL_PROMNU	;(F4) = for set time and remote code
	SBHK	1
	;BS	ACZ,LOCAL_PROTWR	;(F5) = two way record
	SBHK	1
	BS	ACZ,LOCAL_PROPHO	;(F6) = for VOP test
	SBHK	1
	BS	ACZ,LOCAL_PROTXT	;(F7) = for test mode
IDLE_INVALID_MSG:
	
	RET

;-------------------------------------------------------------------------------
;LOCAL_PROMNU:
;---------------事件响应区
LOCAL_PRO0:
	;LAC	PRO_VAR
	;SFR	4
	;ANDK	0X0F
	;BS	ACZ,LOCAL_PRO0_0	;0 = idel
	;SBHK	1
	;BS	ACZ,LOCAL_PROKEYVP	;1 = VOP(for key mode)
	;SBHK	1
	;BS	ACZ,LOCAL_PROCIDVP	;2 = VOP(for CID)
	;SBHK	1
	;BS	ACZ,LOCAL_PROERA	;3 = Erase all old message/Del all VP

	;RET
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
	XORL	CHF_WORK
	BS	ACZ,LOCAL_PRO0_PHONE	;进入HFree
	LAC	MSG
	XORL	CHS_WORK
	BS	ACZ,LOCAL_PRO0_PHONE	;进入HSet
	
	LAC	MSG
	XORL	CRDY_CID
	BS	ACZ,LOCAL_PRO0_CID	;to receive CID	
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,LOCAL_PRO0_RING	;to receive CID
	LAC	MSG
	XORL	CRING_FAIL
	BS	ACZ,LOCAL_PRO0_INIT	;to receive CID

	LAC	MSG
	XORL	CMSG_SER
	BS	ACZ,LOCAL_PRO0_0_SER
	
	LAC	MSG
	XORL	CMSG_INIT		;INITIAL
	BS	ACZ,LOCAL_PRO0_INIT
;---
	LAC	MSG
	XORL	CMSG_PLY		;Record message
	BS	ACZ,LOCAL_PRO0_PLYMSG
	LAC	MSG
	XORL	COLD_ERAS
	BS	ACZ,LOCAL_PRO0_REAALL	;Erase all old messages
	LAC	MSG
	XORL	CREC_MEMO		;Record message
	BS	ACZ,LOCAL_PRO0_RECMSG
	LAC	MSG
	XORL	CREC_2WAY
	BS	ACZ,LOCAL_PRO0_2WAY
	LAC	MSG
	XORL	CPLY_OGM		;play OGM
	BS	ACZ,LOCAL_PRO0_PLYOGM
	LAC	MSG
	XORL	CREC_OGM		;record OGM
	BS	ACZ,LOCAL_PRO0_RECOGM
;---
	;LAC	MSG
	;XORL	CVP_STOP
	;BS	ACZ,LOCAL_PRO0_VPSTOP
	LAC	MSG
	XORL	CMSG_TMR		;CMSG_TMR
	BS	ACZ,LOCAL_PRO0_TMR
	LAC	MSG
	XORL	CTMODE_IN
	BS	ACZ,LOCAL_PRO0_TMODE

	RET

;-------------------------------------------------------------------------------
LOCAL_PRO0_VPSTOP:
LOCAL_PRO0_INIT:
	CALL	INIT_DAM_FUNC
	LACL	CMODE9
	CALL	DAM_BIOSFUNC
	CALL	LINE_START
LOCAL_PRO0_TMR:
	
	CALL	DAA_OFF
	LACL	CTMR1S
	CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1
	SAH	PRO_VAR
;---
	RET
;---------------------------------------
LOCAL_PRO0_RING:
	CALL	INIT_DAM_FUNC
	
	LACL	CMODE9|(1<<3)	;Line-on/ALC-on
	CALL	DAM_BIOSFUNC
	CALL	LINE_START
		
	RET
;-------------------
LOCAL_PRO0_INIT_UPDATEFLASH:	;VOL changed,write into flash
	CALL	INIT_DAM_FUNC
	LACL	0X5EA3
	CALL	DAM_BIOSFUNC
;-------
	LACL	FlashLoc_H_f_IdleComm
	ADLL	FlashLoc_L_f_IdleComm
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_IdleComm
	ADLL	CodeSize_f_IdleComm
	CALL	LoadHostCode
;-------
	CALL	UPDATE_FLASHDATA
	
	RET
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
;---------------------------------------
LOCAL_PRO0_RECMSG:
LOCAL_PRO0_2WAY:
	CALL	INIT_DAM_FUNC
	LACK	0X0002
	SAH	PRO_VAR
;!!!!!!
	LACL	0X5EA2
	CALL	DAM_BIOSFUNC
	
	CALL	LOAD_LOCF_VR
;!!!!!!
	LAC	MSG
	CALL	STOR_MSG

	RET
;---------------------------------------
LOCAL_PRO0_RECOGM:		;准备录制OGM
LOCAL_PRO0_PLYOGM:		;准备播放OGM
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
LOCAL_PRO0_CID:
	CALL	INIT_DAM_FUNC
.if	1
	LACL	0X5EA3
	CALL	DAM_BIOSFUNC
;-------
	LACL	FlashLoc_H_f_lcid
	ADLL	FlashLoc_L_f_lcid
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_lcid
	ADLL	CodeSize_f_lcid
	CALL	LoadHostCode
;-------

	CALL	RECEIVE_CID	;收Caller id
.else
	CALL	DAA_SPK
	CALL	BEEP
.endif	
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

	LACL	0X5EA3
	CALL	DAM_BIOSFUNC
	
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
SYS_MSG_ANS:
	CALL	INIT_DAM_FUNC
	
	LACL	0X5EA3
	CALL	DAM_BIOSFUNC
	
	CALL	CLR_FUNC	;先空
	LACL	ANS_STATE	;答录状态
	CALL	PUSH_FUNC
	LACK	0
	SAH	PRO_VAR		;程序步骤
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

	CALL	CLR_FUNC	;先空
	LACL	REMOTE_PRO	;进入遥控
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
	SAH	PRO_VAR		;程序步骤
	SAH	PRO_VAR1	;计时清零
;	SAH	PSWORD_TMP	;功能字符清零

	LACL	CMSG_INIT
	CALL	STOR_MSG

	RET
;-------------------------------------------------------------------------------
LOCAL_PRO0_0_SER:
	
	LACL	0X5EA3
	CALL	DAM_BIOSFUNC
;-------
	LACL	FlashLoc_H_f_IdleComm
	ADLL	FlashLoc_L_f_IdleComm
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_IdleComm
	ADLL	CodeSize_f_IdleComm
	CALL	LoadHostCode
;-------
	CALL	IDLE_COMMAND

	RET
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
	
.END
