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
.global	LOCAL_PROFIXF	;fixf function
;-------------------------------------------------------------------------------
.LIST
.ORG    ADDR_SECOND
;-------------------------------------------------------------------------------
LOCAL_PROFIXF:
	LAC	PRO_VAR
	ANDK	0X0F
	BS	ACZ,LOCAL_PROFIXF_0	;(0xyyy0)
	SBHK	1
	BS	ACZ,LOCAL_PROVOL	;(0xyyy1)
	SBHK	1
	BS	ACZ,LOCAL_PROBOX	;(0xyyy2)
	SBHK	1
	BS	ACZ,LOCAL_PRODEL	;(0xyyy3)
	SBHK	1
	BS	ACZ,LOCAL_PROTIM	;(0xyyy4)
	SBHK	1
	BS	ACZ,LOCAL_PROFMT	;(0xyyy5)
	SBHK	1
	BS	ACZ,LOCAL_PROONOFF	;(0xyyy6)

	RET
;-------------------------------------------------------------------------------
LOCAL_PROFIXF_0:
	LAC	MSG
	XORL	CMSG_KEY3S
	BS	ACZ,LOCAL_PROFIXF_0_TIME
	LAC	MSG
	XORL	CMSG_KEY8L
	BS	ACZ,LOCAL_PROFIXF_0_ERAS
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,LOCAL_PROFIXF_0_ONOFF
	LAC	MSG
	XORL	CMSG_KEY7L
	BS	ACZ,LOCAL_PROFIXF_0_FORMAT
	LAC	MSG
	XORL	CMSG_KEY6L
	BS	ACZ,LOCAL_PROFIXF_0_MBOX_1
	LAC	MSG
	XORL	CMSG_KEY6S
	BS	ACZ,LOCAL_PROFIXF_0_MBOX
	
	LAC	MSG
	XORL	CMSG_KEYBD
	BS	ACZ,LOCAL_PROFIXF_0_VOL
	;LAC	MSG
	;XORL	CMSG_KEYBP
	;BS	ACZ,LOCAL_PROFIXF_0_VOL
	
	RET
;---------------------------------------
LOCAL_PROFIXF_0_TIME:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	CURR_WEEK
	CALL	CURR_HOUR
	CALL	CURR_MIN
	CALL	BLED_ON
	
	LACK	0X04
	SAH	PRO_VAR
	
	RET
;---------------------------------------
LOCAL_PROFIXF_0_FORMAT:
	CALL	INIT_DAM_FUNC

	LACL	4000
	CALL	SET_TIMER
	LACK	0X05
	SAH	PRO_VAR
	
	RET
;---------------------------------------
LOCAL_PROFIXF_0_ERAS:
	CALL	INIT_DAM_FUNC
	
	CALL	BLED_ON
	
	LACK	0X03
	SAH	PRO_VAR
	
	CALL	VPMSG_CHK
	LAC	MSG_T
	BS	ACZ,LOCAL_PROFIXF_0_ERAS_1	;No messages
	SBH	MSG_N
	BS	ACZ,LOCAL_PROFIXF_0_ERAS_2	;No old messages
	
	LACL	0X6100
	CALL	DAM_BIOSFUNC
	
	LACL	0X6080
	CALL	DAM_BIOSFUNC
	CALL	TELNUMALL_DEL	;删除没有对应message的电话号码
	CALL	TEL_GC_CHK

	CALL	VPMSG_CHK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	SEND_MSGNUM	;录音数量同步(4bytes)

	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	DAA_SPK
	LACL	0XFF00|VOP_INDEX_AllOldMessagesErased
	CALL	STOR_VP
	CALL	BB_VOP
	BS	B1,LOCAL_PROFIXF_0_ERAS_END	
LOCAL_PROFIXF_0_ERAS_1:
	CALL	DAA_SPK
	LACL	0XFF00|VOP_INDEX_YouHave
	CALL	STOR_VP
	LACL	0XFF00|VOP_INDEX_No
	CALL	STOR_VP
	LACL	0XFF00|VOP_INDEX_Messages
	CALL	STOR_VP
	CALL	BB_VOP		;替换语音BB
	BS	B1,LOCAL_PROFIXF_0_ERAS_END
LOCAL_PROFIXF_0_ERAS_2:
	CALL	DAA_SPK
	LACL	0XFF00|VOP_INDEX_No
	CALL	STOR_VP
	LACL	0XFF00|VOP_INDEX_Messages
	CALL	STOR_VP
	LACL	0XFF00|VOP_INDEX_Erased
	CALL	STOR_VP
	CALL	BB_VOP
	BS	B1,LOCAL_PROFIXF_0_ERAS_END
LOCAL_PROFIXF_0_ERAS_END:
		
	RET
;---------------------------------------
LOCAL_PROFIXF_0_MBOX:		;release Mbox-Key
	CALL	INIT_DAM_FUNC

	CALL	VPMSG_CHK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	SEND_MSGNUM	;录音数量同步(4bytes)
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X0FF
	CALL	SEND_DAT	
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9E
	CALL	SEND_DAT
	LACL	6
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT	;由于要求及时显示,所以要发
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	DAA_SPK
	CALL	BLED_ON

	CALL	VP_MAILBOX	;mailbox
	LAC	MBOX_ID		;messages
	CALL	ANNOUNCE_NUM

	LACK	0X12
	SAH	PRO_VAR
	
	RET
;---------------------------------------
LOCAL_PROFIXF_0_MBOX_1:		;pressed Mbox-Key
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BLED_ON
	
	CALL	VPMSG_CHK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	SEND_MSGNUM	;录音数量同步(4bytes)
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X0FF
	CALL	SEND_DAT	
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9E
	CALL	SEND_DAT
	LACL	6
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT	;由于要求及时显示,所以要发
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	VP_MAILBOX	;mailbox
	LAC	MBOX_ID		;messages
	CALL	ANNOUNCE_NUM

	LACK	0X02
	SAH	PRO_VAR
	
	RET
;---------------------------------------
LOCAL_PROFIXF_0_VOL:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BLED_ON	
	LAC	MSG
	CALL	STOR_MSG
	
	LACK	0
	SAH	PRO_VAR1
	LACL	400
	CALL	SET_TIMER

	LACK	0X01
	SAH	PRO_VAR
	
	RET
;-------------------------------------------------------------------------------	
LOCAL_PROVOL:
	LAC	PRO_VAR
	SFR	4
	ANDK	0XF
	BS	ACZ,LOCAL_PROVOL_0	;处理Vol-KEY持续按下时的事件
	SBHK	1
	BS	ACZ,LOCAL_PROVOL_1	;处理Vol-KEY已经松开时的事件
	
	RET
;-----------------------------------------------------------	
LOCAL_PROVOL_0:			;处理Vol-KEY持续按下
	LAC	MSG
	XORL	CMSG_KEYBS
	BS	ACZ,LOCAL_PROVOL_0_VOLAEND	;检到Vol-KEY松开
	LAC	MSG
	XORL	CMSG_KEYBP
	BS	ACZ,LOCAL_PROVOL_0_VOLA
	LAC	MSG
	XORL	CMSG_KEYBD
	BS	ACZ,LOCAL_PROVOL_0_VOLA

	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,LOCAL_PROVOL_RING
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,LOCAL_PROVOL_STOP
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROVOL_0_VPSTOP

	RET
;---------------------------------------
LOCAL_PROVOL_0_VOLAEND:
	;CALL	INIT_DAM_FUNC
	;CALL	DAA_OFF
	LACK	0X005
	CALL	STOR_VP
	LACK	0X11
	SAH	PRO_VAR
	
	RET
LOCAL_PROVOL_0_VOLA:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	
	LACL	CMSG_VOLA
	CALL	STOR_MSG
;---	
	LACK	CMIN_VOL
	SAH	SYSTMP1
	LACK	CMAX_VOL
	SAH	SYSTMP2
	
	LAC	VOI_ATT
	ANDK	0XF
	CALL	VALUE_ADD
	SAH	SYSTMP0
	
	LAC	VOI_ATT
	ANDL	0XFFF0
	OR	SYSTMP0
	SAH	VOI_ATT
;---	
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	LACL	0XCB
	CALL	SEND_DAT
	LAC	VOI_ATT
	ANDK	0XF
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LAC	VOI_ATT
	ANDK	0XF
	SBHK	CMAX_VOL
	BZ	SGN,LOCAL_PROVOL_0_VPWORN	;最大音量报警

	CALL	INIT_DAM_FUNC	
	CALL	BEEP
	RET
LOCAL_PROVOL_0_VPWORN:		;MAX/MIN Volume
	CALL	INIT_DAM_FUNC	;
	CALL	BBBEEP

	RET
;---------------------------------------
LOCAL_PROVOL_0_VPSTOP:
LOCAL_PROVOL_1_VPSTOP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LACL	3000
	CALL	SET_TIMER
	
	RET
;---------------------------------------
LOCAL_PROVOL_TMR:
	BS	B1,LOCAL_PROX_RINGIN
LOCAL_PROVOL_RING:
	BS	B1,LOCAL_PROX_RINGIN
;---------------------------------------
LOCAL_PROVOL_STOP:
	BS	B1,LOCAL_PROX_RINGIN
;-------------------------------------------------------------------------------
LOCAL_PROVOL_1:		;处理Vol-KEY松开
	LAC	MSG
	XORL	CMSG_KEYBP
	BS	ACZ,LOCAL_PROFIXF_0_VOL
	LAC	MSG
	XORL	CMSG_KEYBD
	BS	ACZ,LOCAL_PROFIXF_0_VOL
;---	
	LAC	MSG
	XORL	CMSG_KEYAD
	BS	ACZ,LOCAL_PROFIXF_0_NOACTION
;---
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,LOCAL_PROVOL_1_RING
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,LOCAL_PROVOL_1_STOP
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROVOL_1_VPSTOP
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PROVOL_TMR
;---	
	LAC	MSG
	SBHL	0X80
	BS	SGN,LOCAL_PROVOL_1_ANOTHER	;KEY
	LAC	MSG
	SBHL	0XE0
	BZ	SGN,LOCAL_PROVOL_1_ANOTHER	;Another event
	
	RET
;---------------------------------------
LOCAL_PROFIXF_0_NOACTION:
	RET
LOCAL_PROVOL_1_RING:
	BS	B1,LOCAL_PROX_RINGIN
LOCAL_PROVOL_1_STOP:
	BS	B1,LOCAL_PROX_RINGIN
LOCAL_PROVOL_1_ANOTHER:

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
	LAC	MSG
	CALL	STOR_MSG
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PRODEL:
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,LOCAL_PRODEL_RING
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,LOCAL_PRODEL_STOP
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PRODEL_VPSTOP
	
	RET
;---------------------------------------
LOCAL_PRODEL_RING:
	BS	B1,LOCAL_PROX_RINGIN
;---------------------------------------
LOCAL_PRODEL_VPSTOP:
	BS	B1,LOCAL_PROX_RINGIN
;---------------------------------------
LOCAL_PRODEL_STOP:
	BS	B1,LOCAL_PROX_RINGIN
;-------------------------------------------------------------------------------
LOCAL_PROBOX:		;Change mailbox
	LAC	PRO_VAR
	SFR	4
	ANDK	0XF
	BS	ACZ,LOCAL_PROBOX_0	;Announce mailbox nr
	SBHK	1
	BS	ACZ,LOCAL_PROBOX_1	;Key-released
	SBHK	1
	BS	ACZ,LOCAL_PROBOX_2	;Key-pressed
		
	RET
;-----------------------------------------------------------
LOCAL_PROBOX_0:		;"mbox"按下状态
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,LOCAL_PROBOX_RING
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROBOX_VPSTOP
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,LOCAL_PROBOX_STOP
	LAC	MSG
	XORL	CMSG_KEY6S
	BS	ACZ,LOCAL_PROBOX_0_MBOX

	RET
;---------------------------------------
LOCAL_PROBOX_0_MBOX:
	BS	B1,LOCAL_PROFIXF_0_MBOX
LOCAL_PROBOX_RING:
	BS	B1,LOCAL_PROX_RINGIN
LOCAL_PROBOX_STOP:
	BS	B1,LOCAL_PROX_RINGIN
;---------------------------------------
LOCAL_PROBOX_VPSTOP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LACL	1000
	CALL	SET_TIMER
	LACK	0X22
	SAH	PRO_VAR
	
	CALL	VPMSG_CHK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	SEND_MSGNUM	;录音数量同步(4bytes)
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X0FF
	CALL	SEND_DAT	

	RET
;---------------------------------------
LOCAL_PROBOX_OK:
	BS	B1,LOCAL_PROFIXF_0_MBOX
;-------------------------------------------------------------------------------
LOCAL_PROBOX_1:		;"mbox"松开状态
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,LOCAL_PROBOX_1_RING
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROBOX_1_VPSTOP
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,LOCAL_PROBOX_1_STOP
	LAC	MSG
	XORL	CMSG_KEY6S
	BS	ACZ,LOCAL_PROBOX_1_MBOX
	LAC	MSG
	XORL	CMSG_KEY6L
	BS	ACZ,LOCAL_PROBOX_1_MBOXL

	RET
;---------------------------------------
LOCAL_PROBOX_1_MBOX:
	BS	B1,LOCAL_PROFIXF_0_MBOX
LOCAL_PROBOX_1_MBOXL:
	BS	B1,LOCAL_PROFIXF_0_MBOX_1
LOCAL_PROBOX_1_RING:
	BS	B1,LOCAL_PROX_RINGIN
LOCAL_PROBOX_1_VPSTOP:
	BS	B1,LOCAL_PROX_RINGIN
LOCAL_PROBOX_1_STOP:
	BS	B1,LOCAL_PROX_RINGIN
;-------------------------------------------------------------------------------
LOCAL_PROBOX_2:		;"mbox"按下的VOP间隙状态
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,LOCAL_PROBOX_RING
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROBOX_2_VPSTOP
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,LOCAL_PROBOX_STOP
	LAC	MSG
	XORL	CMSG_KEY6S
	BS	ACZ,LOCAL_PROBOX_2_MBOX
	LAC	MSG
	XORL	CMSG_KEY6L
	BS	ACZ,LOCAL_PROBOX_2_MBOXL
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PROBOX_2_TMR

	RET
;---------------------------------------
LOCAL_PROBOX_2_MBOX:
	BS	B1,LOCAL_PROFIXF_0_MBOX
LOCAL_PROBOX_2_VPSTOP:
	CALL	DAA_OFF
	
	RET
;---------------------------------------
LOCAL_PROBOX_2_MBOXL:
	BS	B1,LOCAL_PROFIXF_0_MBOX_1
;---------------------------------------
LOCAL_PROBOX_2_TMR:
	CALL	CLR_TIMER
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	
	LACK	1
	SAH	SYSTMP1		;MIN.Value
	LACK	4
	SAH	SYSTMP2		;MAX.Value
	LAC	MBOX_ID
	CALL	VALUE_ADD
	SAH	MBOX_ID	

	SAH	MBOX_ID		;mbox-id(1,2,3,4)
	CALL	ANNOUNCE_NUM
	
	CALL	VPMSG_CHK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	SEND_MSGNUM	;录音数量同步(4bytes)
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X0FF
	CALL	SEND_DAT	
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9E
	CALL	SEND_DAT
	LACL	6
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT	;由于要求及时显示,所以要发
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	0X02
	SAH	PRO_VAR
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROTIM:
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,LOCAL_PROTIM_RING
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROTIM_VPSTOP
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,LOCAL_PROTIM_STOP

	RET
;---------------------------------------
LOCAL_PROTIM_STOP:
LOCAL_PROTIM_VPSTOP:
LOCAL_PROTIM_RING:
	BS	B1,LOCAL_PROX_RINGIN

;-------------------------------------------------------------------------------
LOCAL_PROFMT:
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PROFMT_TMR		;
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,LOCAL_PROFMT_STOP
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROFMT_VPSTOP
	
	RET
;---------------------------------------
LOCAL_PROFMT_TMR:
	CALL	INIT_DAM_FUNC
	CALL	BLED_ON
	LACL	0X9001
	CALL	DAM_BIOSFUNC
	LACL	CMODE9
	CALL	DAM_BIOSFUNC
	CALL	SET_DECLTEL

	;CALL	GET_INITLANGUAGE

	;CALL	SENDLANGUAGE	;(2bytes)语言选择(Default = German)Make Sure it is the first command to MCU after Power-on
	;LACL	0X0FF
	;CALL	SEND_DAT	;(1byte)

	CALL	DATETIME_WRITE
	CALL	INITMCU

	CALL	CLR_LED1FG	;clear new call flag
	
	LACK	3
	SAH	MBOX_ID
	CALL	VPMSG_CHK
        CALL	NEWICM_CHK
        
	LACK	2
	SAH	MBOX_ID
	CALL	VPMSG_CHK
        CALL	NEWICM_CHK
        
	LACK	1
	SAH	MBOX_ID
	CALL	VPMSG_CHK
	CALL	NEWICM_CHK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	SEND_MSGNUM	;录音数量同步(4bytes)

	LACL	0XFF
	CALL	SEND_DAT
	
	LACL	0X82		;新旧来电同步(3bytes)
	CALL	SEND_DAT
	LACK	0	;???????????????
	CALL	SEND_DAT
	LACK	0
	CALL	SET_TELGROUP
	CALL	GET_TELT	;来电总数同步
	CALL	SEND_DAT
	
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK	
	CALL	INITBEEP
	CALL	CLR_MSG
LOCAL_PROFMT_KEYRELEASE:
	BIT	INT_EVENT,1
	BS	TB,LOCAL_PROFMT_KEYRELEASE
	CALL	CLR_MSG	
	BS	B1,LOCAL_PROX_RINGIN	;Key released then exit to idle
;---------------------------------------
LOCAL_PROFMT_STOP:
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
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK	
	CALL	BEEP
	
	RET
;---------------------------------------
LOCAL_PROFMT_VPSTOP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROX_RINGIN:
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
LOCAL_PROFIXF_0_ONOFF:
	CALL	BLED_ON

	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	CLR_TIMER

	LAC	EVENT
	XORL	1<<9
	SAH	EVENT

	LACK	0x06
	SAH	PRO_VAR

	BIT	EVENT,9
	BS	TB,REMOTE_PRO0_REV_DTMF_9_OFF
;REMOTE_PRO0_REV_DTMF_9_OFF:	
	LACL	0XFF00|VOP_INDEX_AnswerMachine
	CALL	STOR_VP
	LACL	0XFF00|VOP_INDEX_On
	CALL	STOR_VP
	
	CALL	B_VOP
	
	RET
REMOTE_PRO0_REV_DTMF_9_OFF:
	LACL	0XFF00|VOP_INDEX_AnswerMachine
	CALL	STOR_VP
	LACL	0XFF00|VOP_INDEX_Off
	CALL	STOR_VP
	
	CALL	B_VOP

	RET
;-------------------------------------------------------------------------------
LOCAL_PROONOFF:
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,LOCAL_PROONOFF_RING
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,LOCAL_PROFIXF_0_ONOFF
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PRODEL_VPSTOP
	
	LAC	MSG
	SBHL	0X80
	BS	SGN,LOCAL_PROONOFF_FUNCTION	;KEY
	LAC	MSG
	SBHL	0XE0
	BZ	SGN,LOCAL_PROONOFF_FUNCTION	;Another event
	
	RET
LOCAL_PROONOFF_RING:	
	BS	B1,LOCAL_PROX_RINGIN
LOCAL_PROONOFF_VPSTOP:
	BS	B1,LOCAL_PROX_RINGIN
LOCAL_PROONOFF_FUNCTION:	
	CALL	INIT_DAM_FUNC
	CALL	CLR_FUNC
	LACK	0
	SAH	PRO_VAR
	
	LAC	MSG
	CALL	STOR_MSG
	
	RET
;-------------------------------------------------------------------------------
;	Function : CURR_WEEK/CURR_GWEEK
;	
;	Generate a VP
;-------------------------------------------------------------------------------
CURR_WEEK:
	LACL	0X8300
	CALL	DAM_BIOSFUNC
	
	CALL	GET_LANGUAGE
	BZ	ACZ,CURR_EWEEK
CURR_GWEEK:
	LAC	RESP
	ADHK	VOP_INDEX_Sunday
	ORL	0XFF00
	CALL	STOR_VP
	
	RET
CURR_EWEEK:
	LACK	0x005
	CALL	STOR_VP
	
	RET
;-------------------------------------------------------------------------------
;	Function : CURR_HOUR
;	
;	Generate a VP
;-------------------------------------------------------------------------------
CURR_HOUR:
	LACL	0X8200
	CALL	DAM_BIOSFUNC
	SAH	SYSTMP1

	CALL	GET_LANGUAGE
	BS	ACZ,CURR_GHOUR	
	
	BIT	EVENT,11	;default=(EVENT.11=0) ==>24时制
	BS	TB,CURR_HOUR_12
	
	LAC	SYSTMP1
	CALL	ANNOUNCE_NUM
	RET

CURR_GHOUR:
	LAC	SYSTMP1
	BS	ACZ,CURR_GHOUR_NULL
	SBHK	1
	BS	ACZ,CURR_GHOUR_EIN
	
	LAC	SYSTMP1
	CALL	ANNOUNCE_NUM
	BS	B1,CURR_GHOUR_HUR
CURR_GHOUR_NULL:	
	LACL	0XFF00|VOP_INDEX_Null	;null
	CALL	STOR_VP
	BS	B1,CURR_GHOUR_HUR
CURR_GHOUR_EIN:
	LACL	0XFF00|VOP_INDEX_Ein	;ein
	CALL	STOR_VP	
CURR_GHOUR_HUR:
	LACL	0XFF00|VOP_INDEX_Uhr	;Uhr
	CALL	STOR_VP
	
	RET
;---------------------------------------
CURR_HOUR_12:
	LAC	SYSTMP1
	BS	ACZ,CURR_HOUR_12_0
	SBHK	12
	BS	ACZ,CURR_HOUR_12_0
	BS	SGN,CURR_HOUR_12_AM
	
	CALL	ANNOUNCE_NUM	;13..23
	
	RET
CURR_HOUR_12_0:			;0,12
	LACK	12
	CALL	ANNOUNCE_NUM

	RET

CURR_HOUR_12_AM:		;1..11

	LAC	SYSTMP1
	CALL	ANNOUNCE_NUM

	RET
;-------------------------------------------------------------------------------
;	Function : MSG_MIN
;	
;	Generate a VP
;-------------------------------------------------------------------------------
CURR_MIN:
	LACL	0X8100
	CALL	DAM_BIOSFUNC
	SAH	SYSTMP1

	CALL	GET_LANGUAGE
	BS	ACZ,CURR_GMIN
;---Language = English
	LAC	SYSTMP1
	CALL	ANNOUNCE_NUM

	BIT	EVENT,11	;default=(EVENT.11=0) ==>24时制;12小时制要报AM/PM
	BS	TB,CURR_MIN_12_CHK
	
	RET

CURR_MIN_12_CHK:	
	LACL	0X8200
	CALL	DAM_BIOSFUNC
	SAH	SYSTMP1

	BS	ACZ,CURR_MIN_AM
	SBHK	12
	BZ	SGN,CURR_MIN_PM
CURR_MIN_AM:

	LACL	0XFF00|VOP_INDEX_AM	;AM
	CALL	STOR_VP
	RET
CURR_MIN_PM:

	LACL	0XFF00|VOP_INDEX_PM	;PM
	CALL	STOR_VP
	RET
;-----------------------
CURR_GMIN:		;---Language = German	
	LAC	SYSTMP1
	BS	ACZ,CURR_GMIN_RET
	CALL	ANNOUNCE_NUM
CURR_GMIN_RET:
	RET	
;-------------------------------------------------------------------------------
.INCLUDE l_init.asm
;-------------------------------------------------------------------------------	
.END

