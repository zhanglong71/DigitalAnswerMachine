.NOLIST
.INCLUDE	REG_D20.inc
.INCLUDE	MD20U.inc
.INCLUDE	CONST.inc

.GLOBAL	LOCAL_PROPNEW
;-------------------------------------------------------------------------------
.EXTERN	GetOneConst
.EXTERN	INIT_DAM_FUNC

.EXTERN	ANNOUNCE_NUM
.EXTERN	BCVOX_INIT
.EXTERN	BBBEEP
.EXTERN	BBEEP
.EXTERN	BEEP

.EXTERN	CLR_FUNC
.EXTERN	CLR_TIMER

.EXTERN	DAA_SPK
.EXTERN	DAA_REC
.EXTERN	DAA_OFF
.EXTERN	DAM_BIOSFUNC
.EXTERN	DGT_TAB

.EXTERN	EXIT_TOIDLE

.EXTERN	GC_CHK
.EXTERN	GET_SEGCODE

.EXTERN	HOOK_ON
.EXTERN	HOOK_OFF

.EXTERN	LBEEP
.EXTERN	LED_HLDISP
.EXTERN	LINE_START
.EXTERN	LOCAL_PRO

.EXTERN	OGM_SELECT

.EXTERN	PUSH_FUNC
.EXTERN	PAUBEEP

.EXTERN	REAL_DEL
.EXTERN	REC_START

.EXTERN	SET_TIMER
.EXTERN	SEND_DAT
.EXTERN	SEND_MSGNUM

.EXTERN	STOR_MSG
.EXTERN	STOR_VP

.EXTERN	VPMSG_CHK
.EXTERN	VPMSG_DEL
;---
.EXTERN	VP_DefOGM
.EXTERN	VP_Erased
.EXTERN	VP_EndOfMessages
.EXTERN	VP_Message
.EXTERN	VP_MemoryFull

.LIST
;-------------------------------------------------------------------------------
.ORG	ADDR_SECOND
;-------------------------------------------------------------------------------
LOCAL_PROPLY:			;0Xyyy1
LOCAL_PROPNEW:
	LAC	MSG
	XORL	CMSG_KEY8D		;VOL-
	BS	ACZ,LOCAL_PROX_VOLS
	LAC	MSG
	XORL	CMSG_KEY7D		;VOL+
	BS	ACZ,LOCAL_PROX_VOLA
	LAC	MSG
	XORL	CRING_IN		;ON/OFF(stop)
	BS	ACZ,LOCAL_PROPLY_RING
	LAC	MSG
	XORL	CPARA_MINE
	BS	ACZ,LOCAL_PROPLY_RING

	LAC	PRO_VAR
	SFR	4
	ANDK	0X0F
	BS	ACZ,LOCAL_PROPLY_0	;(0X0y01)playing
	SBHK	1
	BS	ACZ,LOCAL_PROPLY_1	;(0X0y11)pauseing

	RET

LOCAL_PROPLY_0:	
	LAC	MSG
	XORL	CPLY_PAUSE		;pause
	BS	ACZ,LOCAL_PROPLY_PAUSE

	LAC	PRO_VAR
	SFR	8
	ANDK	0X0F
	BS	ACZ,LOCAL_PROPLY_0_0	;(0X0001)playing Vop(total message/new message)
	SBHK	1
	BS	ACZ,LOCAL_PROPLY_0_1	;(0X0101)playing Message
	SBHK	1
	BS	ACZ,LOCAL_PROPLY_0_2	;(0X0y21)playing Vop(end of message)
	
	RET
;---------------------------------------
LOCAL_PROPLY_0_0:
	LAC	MSG
	XORL	CVP_STOP		;PLAY END
	BS	ACZ,LOCAL_PROPLY_0_OVER
	LAC	MSG
	XORL	CMSG_KEY6S		;ON/OFF(stop)
	BS	ACZ,LOCAL_PROPLY_STOP
	
	RET
LOCAL_PROPLY_0_OVER:
	LACL	0X0108
	SAH	PRO_VAR
	BS	B1,LOCAL_PROPLY_OVER
;---------------------------------------
LOCAL_PROPLY_0_1:	
	LAC	MSG
	XORL	CMSG_TMR		;TMR
	BS	ACZ,LOCAL_PROPLY_0_TMR
;LOCAL_PROPLY_0_1_1:
	LAC	MSG
	XORL	CPLY_NEXT		;play next message
	BS	ACZ,LOCAL_PROPLY_0_FFW
;LOCAL_PROPLY_0_1_2:
	LAC	MSG
	XORL	CPLY_ERAS		;erase the playing message
	BS	ACZ,LOCAL_PROPLY_ERASE
;LOCAL_PROPLY_0_1_3:
	LAC	MSG
	XORL	CPLY_PREV		;repeat/previous message
	BS	ACZ,LOCAL_PROPLY_REW
;LOCAL_PROPLY_0_1_4:
	LAC	MSG
	XORL	CVP_STOP		;PLAY END
	BS	ACZ,LOCAL_PROPLY_OVER
;LOCAL_PROPLY_0_1_5:
	LAC	MSG
	XORL	CMSG_KEY6S		;ON/OFF(stop)
	BS	ACZ,LOCAL_PROPLY_STOP

	RET
;---------------
LOCAL_PROPLY_0_FFW:
	BS	B1,LOCAL_PROPLY_OVER
LOCAL_PROPLY_0_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	
	RET
;---------------------------------------
LOCAL_PROPLY_REW:

	LAC	MSG_ID
	SBHK	1
	BS	ACZ,LOCAL_PROPLY_REW_1	;第一个吗?
	
	LAC	PRO_VAR1
	BZ	ACZ,LOCAL_PROPLY_REW_2

	LAC	MSG_ID
	SBHK	1
	SAH	MSG_ID
	
	CALL	CLR_TIMER
	LACK	1
	SAH	PRO_VAR1

	CALL	INIT_DAM_FUNC
	LAC	PRO_VAR
	ANDL	0XFF0F
	SAH	PRO_VAR
	BS	B1,LOCAL_PROPLY_REWEXE
LOCAL_PROPLY_REW_1:
	CALL	INIT_DAM_FUNC
	LAC	PRO_VAR
	ANDL	0XFF0F
	SAH	PRO_VAR
	
	CALL	CLR_TIMER
	LACK	1
	SAH	PRO_VAR1

	BS	B1,LOCAL_PROPLY_REWEXE
LOCAL_PROPLY_REW_2:
	LACL	1000
	CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1

	CALL	INIT_DAM_FUNC
	LAC	PRO_VAR
	ANDL	0XFF0F
	SAH	PRO_VAR

	;BS	B1,LOCAL_PROPLY_REWEXE
LOCAL_PROPLY_REWEXE:
	BS	B1,LOCAL_PROPLY_LOADNEWVP
;---------------------------------------
LOCAL_PROPLY_PAUSE:
	LAC	CONF
	ANDL	0XF000
	SBHL	0X2000
	BS	ACZ,LOCAL_PROPLY_PAUSE0		;0X2000(message)
	SBHL	0X9000
	BS	ACZ,LOCAL_PROPLY_PAUSE0		;0XB000(voice prompt)
	BS	B1,LOCAL_PROPLY_PAUSE1
LOCAL_PROPLY_PAUSE0:
	LACL	0X8C88		;"PA"
	SAH	LED_L
	
	LAC	CONF
	ORL	1<<8
	CALL	DAM_BIOSFUNC
	
	;LACL	100
	;CALL	PAUBEEP		;BEEP Prompt
	
	CALL	DAA_OFF
	
	LAC	PRO_VAR
	ANDL	0XFF0F
	ORK	0X010
	SAH	PRO_VAR
	
	LACK	1		;Note!!!暂停计时从1开始(Previous按键从0开始)
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER

	RET
LOCAL_PROPLY_PAUSE1:		;若是BEEP,则循环再发
	LACL	CMSG_KEY1D
	CALL	STOR_MSG

	RET

LOCAL_PROX_VOLS:
	LACL	CMSG_VOLS
	CALL	STOR_MSG
	
	RET

LOCAL_PROX_VOLA:
	LACL	CMSG_VOLA
	CALL	STOR_MSG
	
	RET
LOCAL_PROPLY_ERASE:		;删除后放下一条
	CALL	INIT_DAM_FUNC	;the MSG_ID is related to new messages
	LAC	MSG_ID
	CALL	SET_DELMARKNEW
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	VP_Message
	CALL	VP_Erased
	LACK	0X001
	CALL	STOR_VP
	
	LACL	0X0108
	SAH	PRO_VAR
	
	RET
;---------------------------------------
LOCAL_PROPLY_OVER:
	CALL	INIT_DAM_FUNC
	
	LAC	MSG_ID
	SBH	MSG_N
	BZ	SGN,LOCAL_PROPLY_PLYOVER

	LAC	MSG_ID			;next message
	ADHK	1
	SAH	MSG_ID
LOCAL_PROPLY_LOADNEWVP:
	LAC	MSG_ID
	CALL	LED_HLDISP
	
	CALL	VP_Message
	LAC	MSG_ID
	CALL	ANNOUNCE_NUM

	CALL	SEND_MSGID
	CALL	SEND_MSGATTNEW

	CALL	MSG_WEEKNEW
	CALL	MSG_HOURNEW
	CALL	MSG_MINNEW
	CALL	MSG_AMPMNEW

	LAC	MSG_ID
	ORL	0XFD00
	CALL	STOR_VP
	
	RET

;---------------------------------------
LOCAL_PROPLY_PLYOVER:		;全播放完毕
LOCAL_PROPLY_STOP:		;强行退出Play-Mode
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	VP_EndOfMessages
	CALL	BBEEP
	
	CALL	CLR_TIMER
	
	LACL	0X0208
	SAH	PRO_VAR

	CALL	REAL_DEL
	CALL	GC_CHK
	
	CALL	VPMSG_CHK
	
;---!!!	
	CALL	SER_ENDOFMESSAGE
;---!!!
	RET
;---------------------------------------
LOCAL_PROPLY_RING:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LACK	0X005
	CALL	STOR_VP
	
	CALL	CLR_TIMER
	
	LACK	0X0
	SAH	PRO_VAR

	CALL	REAL_DEL
	CALL	GC_CHK
	
	CALL	VPMSG_CHK
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROPLY_1:			;PAUSE
	LAC	MSG
	XORL	CMSG_PCTU		;pause end
	BS	ACZ,LOCAL_PROPLY_1_PLAY
LOCAL_PROPLY_1_2:
	LAC	MSG
	XORL	CMSG_TMR		;TMR
	BS	ACZ,LOCAL_PROPLY_TMR
LOCAL_PROPLY_1_3:
	LAC	MSG
	XORL	CMSG_KEY6S		;ON/OFF(stop)
	BS	ACZ,LOCAL_PROPLY_STOP
	
	RET
;---------------------------------------
LOCAL_PROPLY_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	8
	BZ	SGN,LOCAL_PROPLY_PLYOVER

	RET

LOCAL_PROPLY_1_PLAY:
	CALL	DAA_SPK
	
	LAC	PRO_VAR
	ANDL	0XFF0F
	SAH	PRO_VAR

	CALL	CLR_TIMER
	LACK	1
	SAH	PRO_VAR1	;for twice 

	LAC	CONF
	ANDL	~(1<<8)
	CALL	DAM_BIOSFUNC

	RET
;-------------------------------------------------------------------------------
LOCAL_PROPLY_0_2:
	LAC	MSG
	XORL	CMSG_KEY6S		;stop EXIT
	BS	ACZ,LOCAL_PROPLY_2_VPSTOP
	LAC	MSG
	XORL	CVP_STOP		;play end EXIT
	BS	ACZ,LOCAL_PROPLY_2_VPSTOP
	
	RET

LOCAL_PROPLY_2_VPSTOP:	
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	CALL	VPMSG_CHK
;!!!
	CALL	SEND_MSGNUM
	CALL	EXIT_TOIDLE
;!!!
	LACK	0
	SAH	PRO_VAR
	
	LACL	CMSG_INIT
	CALL	STOR_MSG
	
	RET
;-------------------------------------------------------------------------------
;       Function : SER_ENDOFMESSAGE
;
;       Input  : no
;       Output : no
;-------------------------------------------------------------------------------
SER_ENDOFMESSAGE:
	LACK	0X28
	CALL	SEND_DAT
	LACK	0X28
	CALL	SEND_DAT
	
	RET
;-------------------------------------------------------------------------------
.INCLUDE	l_ply.asm
;-------------------------------------------------------------------------------
.END
	