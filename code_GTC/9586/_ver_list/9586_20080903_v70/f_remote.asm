.NOLIST
.INCLUDE	include/REG_D22.inc
.INCLUDE	include/MD22U.inc
.INCLUDE	include/CONST.inc

.GLOBAL	REMOTE_PRO
;-------------------------------------------------------------------------------
.EXTERN	GetOneConst
.EXTERN	INIT_DAM_FUNC
.EXTERN	INT_STOR_MSG

.EXTERN	CLR_FUNC
.EXTERN	CLR_TIMER

.EXTERN	DAM_BIOSFUNC
.EXTERN	DAM_STOP
.EXTERN	DELAY

.EXTERN	GC_CHK
.EXTERN	GET_LANGUAGE
.EXTERN	GET_MSG

;.EXTERN	HEX_DGT

.EXTERN	LINE_START
.EXTERN	LOCAL_PRO

.EXTERN	PUSH_FUNC

.EXTERN	REQ_START
.EXTERN	REC_START

.EXTERN	SET_TIMER

.EXTERN	STOR_MSG

;-------------------------------------------------------------------------------
.LIST
;-------------------------------------------------------------------------------
.ORG	ADDR_SECOND
;-------------------------------------------------------------------------------
.LIST
REMOTE_PRO:
	CALL	GET_RESPOND
	
	CALL	GET_MSG
	BS	ACZ,REMOTE_PRO_END
	SAH	MSG	
;-------------------------------------------------------------------------------
	LAC	MSG
	XORL	CSEG_END
	BS	ACZ,REMOTE_PRO_SEGEND	;SEG-end
;---
	LAC	MSG
	XORL	CMSG_SER
	BS	ACZ,REMOTE_PRO_SER	;SEG-end

	LAC	MSG
	XORL	CPHONE_ON
	BS	ACZ,REMOTE_PRO_HFREE
	LAC	MSG
	XORL	CHOOK_OFF
	BS	ACZ,REMOTE_PRO_HSETOFF

	LAC	PRO_VAR
	ANDK	0X0F
	BS	ACZ,REMOTE_PRO0		;0 = IDEL
	SBHK	2
	BS	ACZ,REMOTE_PROPMSG	;2 = play message all/new
	SBHK	2
	BS	ACZ,REMOTE_PROMVOP	;4 = Play Menu vop
	SBHK	1
	BS	ACZ,REMOTE_PROONFF	;5 = on/off vop
	SBHK	4
	BS	ACZ,REMOTE_PROEXIT	;9 = exit
REMOTE_PRO_END:
	RET
;---------------------------------------
REMOTE_PRO_SEGEND:
	CALL	GET_VP
	BS	ACZ,REMOTE_PRO_SEGEND0
	CALL	INT_BIOS_START
	
	RET
REMOTE_PRO_SEGEND0:
	CALL	INIT_DAM_FUNC
	LACL	CVP_STOP		;通知系统播放完毕
	CALL	STOR_MSG
	
	RET
;---------------------------------------
REMOTE_PRO_SER:
	CALL	GETR_DAT
	ANDL	0XFF
	SAH	MSG
;-------------------
	LAC	MSG
	SBHK	0X5A
	BS	ACZ,REMOTE_PRO_SER_0X5A	;(0X5A)stop
	SBHK	0X04
	BS	ACZ,REMOTE_PRO_SER_0X5E	;(0X5E)Phone on/off
	SBHK	0X02
	BS	ACZ,REMOTE_PRO_SER_0X60	;(0X60)Handset on/off
	
	RET
;---------------------------------------
;-----------------------------
REMOTE_PRO_SER_0X5A:	;Stop(Same as CPC)
	LACL	CMSG_CPC
	CALL	STOR_MSG
	
	RET	
;-----------------------------
REMOTE_PRO_SER_0X5E:
	CALL	GETR_DAT
	ANDL	0X0FF
	BS	ACZ,REMOTE_PRO_SER_0X5E0X00
	SBHK	1
	BS	ACZ,ANS_STATE_SER_0X5E0X01
	
	RET
;---------
REMOTE_PRO_SER_0X5E0X00:
	LACL	CMSG_CPC
	CALL	STOR_MSG

	LACL	CPHONE_OFF	;speaker phone mode
	CALL	STOR_MSG

	RET
;---------	
ANS_STATE_SER_0X5E0X01:
REMOTE_PRO_HFREE:
	LACL	CMSG_CPC
	CALL	STOR_MSG

	LACL	CPHONE_ON	;speaker phone mode
	CALL	STOR_MSG

	RET
;---------------------------------------
REMOTE_PRO_SER_0X60:
	CALL	GETR_DAT
	ANDL	0X0FF
	BS	ACZ,REMOTE_PRO_SER_0X600X00
	SBHK	1
	BS	ACZ,REMOTE_PRO_SER_0X600X01
	
	RET
REMOTE_PRO_SER_0X600X00:
	LACL	CMSG_CPC
	CALL	STOR_MSG
	
	LACL	CHOOK_ON	;put down the handset to on hook for end a call
	CALL	STOR_MSG
	
	RET
REMOTE_PRO_SER_0X600X01:
REMOTE_PRO_HSETOFF:
	LACL	CMSG_CPC
	CALL	STOR_MSG
	
	LACL	CHOOK_OFF	;pickup the handset to off hook in handset mode
	CALL	STOR_MSG
	
	RET
;===============================================================================
REMOTE_PRO0:
	LAC	MSG
	XORL	CMSG_INIT
	BS	ACZ,REMOTE_PRO0_INIT	;INITIAL(发两声BEEP还有MenuVop)
;REMOTE_PRO0_1:
	LAC	MSG
	XORL	CREV_DTMF		;CREV_DTMF
	BS	ACZ,REMOTE_PRO0_REV_DTMF
;REMOTE_PRO0_2:	
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,REMOTE_PRO0_STOPVP	;VP完
;REMOTE_PRO0_3:	
	LAC	MSG
	XORL	CMSG_BTONE
	BS	ACZ,REMOTE_PRO0_TONE
;REMOTE_PRO0_4:	
	LAC	MSG
	XORL	CMSG_CTONE
	BS	ACZ,REMOTE_PRO0_TONE
;REMOTE_PRO0_5:	
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,REMOTE_PRO0_TMR
;REMOTE_PRO0_6:		
	LAC	MSG			;接线后摘机(相当于CPC)
	XORL	CMSG_CPC
	BS	ACZ,REMOTE_PRO0_CPC
		
	RET
;---------------------------------------
REMOTE_PRO0_CPC:
	BS	B1,REMOTE_PROEXIT_VPSTOP
;---------------------------------------
REMOTE_PRO0_INIT:
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_SPK
	CALL	BBEEP		;BB
;-!!!
	LACK	0X2B		;Remote
	CALL	SEND_DAT
	LACK	0X2B
	CALL	SEND_DAT
;-!!!
	BS	B1,REMOTE_PRO0_MENUEXE
;---------------------------------------
REMOTE_PRO0_STOPVP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_REC
;---------------Set DTMF line
	LACK	CDTMF_DETR
	CALL	SET_DTMFTYPE	
	
	CALL	BCVOX_INIT
		
	LACK	0			;开始计时
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER
	
	CALL	LINE_START

	RET
;---------------------------------------	
REMOTE_PRO0_REV_DTMF:
	CALL	CLR_TIMER
	LACK	0
	SAH	PRO_VAR1
	
	CALL	BCVOX_INIT
	
	LAC	DTMF_VAL
	ANDK	0X0F
	SBHK	2
	BS	ACZ,REMOTE_PRO0_PLYMSG		;2---play all
	SBHK	2
	BS	ACZ,REMOTE_PRO0_PROONOFF	;4---on/off
	SBHK	3
	BS	ACZ,REMOTE_PRO0_MENU		;7---Menu

	RET
;---------------
REMOTE_PRO0_PLYMSG:
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_SPK
	CALL	VP_YouHave
;---------------Set DTMF play
	LACK	CDTMF_DETP
	CALL	SET_DTMFTYPE	
			
	CALL	VPMSG_CHK		;进入播放子功能
	LACK	0X0002
	SAH	PRO_VAR	
	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER

	LACK	0
	SAH	MSG_ID

	BIT	ANN_FG,12
	BS	TB,REMOTE_PRO0_PLYMSG_NEW
	BIT	ANN_FG,14
	BS	TB,REMOTE_PRO0_PLYMSG_ALL

	CALL	VP_No
	CALL	VP_Messages
	CALL	BBEEP
	
	LACK	0
	SAH	PRO_VAR
	
	RET

REMOTE_PRO0_PLYMSG_ALL:
	LAC	MSG_T
	CALL	ANNOUNCE_NUM

	LAC	MSG_T
	SBHK	1
	BS	ACZ,REMOTE_PRO0_PLYMSG_ALL_1
	
	CALL	VP_Messages
	RET
REMOTE_PRO0_PLYMSG_ALL_1:
	CALL	VP_Message
	RET
;---------------
REMOTE_PRO0_PLYMSG_NEW:
	LAC	MSG_N
	CALL	ANNOUNCE_NUM

	LAC	MSG_N
	SBHK	1
	BS	ACZ,REMOTE_PRO0_PLYMSG_NEW_1
	
	CALL	VP_NewMessages
	RET
REMOTE_PRO0_PLYMSG_NEW_1:
	CALL	VP_NewMessage
	RET
;---------------------------------------

REMOTE_PRO0_RECMEMO:
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_SPK
	
	BIT	ANN_FG,13
	BS	TB,REMOTE_PROX_DTMF_MFUL
	
	LACK	0X0003
	SAH	PRO_VAR
	CALL	LBEEP		;Lbee...

	RET
REMOTE_PROX_DTMF_MFUL:		;mfull 直接退出
	CALL	BBBEEP
	LACK	0
	SAH	PRO_VAR

	RET

REMOTE_PRO0_PROONOFF:
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_SPK
	LAC	EVENT
	XORL	1<<9
	SAH	EVENT
;---------------Set DTMF play
	LACK	CDTMF_DETP
	CALL	SET_DTMFTYPE	
			
	LACK	0
	SAH	PRO_VAR

	BIT	EVENT,9
	BS	TB,REMOTE_PRO0_PROOFF
;REMOTE_PRO0_PROON:
	CALL	VP_AnswerOn
	CALL	BEEP
	
	RET
REMOTE_PRO0_PROOFF:
	CALL	VP_AnswerOff
	CALL	BEEP

	RET

;---------------------------------------
REMOTE_PRO0_MENU:

	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_SPK
REMOTE_PRO0_MENUEXE:

	LACK	0X03D
	CALL	STOR_VP		;延时0.3 second
	CALL	VP_RemoteMenu
	LACK	0X03D
	CALL	STOR_VP		;延时0.3 second
;---------------Set DTMF play 	
	LACK	CDTMF_DETP
	CALL	SET_DTMFTYPE	
	
	LACK	4
	SAH	PRO_VAR

	RET
;---

REMOTE_PRO0_EXIT:
REMOTE_PRO0_TMROUT:		;remote idle time out
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_SPK
		
	LACK	0X009
	SAH	PRO_VAR

	CALL	VP_EndOf
	CALL	VP_Call
	CALL	BEEP

	RET
;---------------------------------------
REMOTE_PRO0_TONE:

	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_SPK

	LACK	0X009
	SAH	PRO_VAR

	LACK	0X005
	CALL	STOR_VP

	RET

;-------
REMOTE_PRO0_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	20		;20s无操作退出
	BZ	SGN,REMOTE_PRO0_TMROUT
	
	RET

;=======================================================================
;11111111111111111111111111111111111111111111111111111111111111111111111
;=======================================================================
;22222222222222222222222222222222222222222222222222222222222222222222222
REMOTE_PROPMSG:
	LAC	MSG			;接线后摘机(相当于CPC)
	XORL	CMSG_CPC
	BS	ACZ,REMOTE_PROPMSG_CPC
	
	LAC	PRO_VAR
	SFR	4
	ANDK	0XF
	BS	ACZ,REMOTE_PROPMSG0		;播放
	SBHK	1
	BS	ACZ,REMOTE_PROPMSG1_PAUSE		;功能暂停

	RET
;---------------
REMOTE_PROPMSG_CPC:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LACK	0X005
	CALL	STOR_VP

	LACL	0X6100
	CALL	DAM_BIOSFUNC
	CALL	GC_CHK
	CALL	VPMSG_CHK
	
	LACK	0X09
	SAH	PRO_VAR
	
	RET
;---------------
REMOTE_PROPMSG0:
	LAC	MSG
	XORL	CVP_STOP		;PLAY END
	BS	ACZ,REMOTE_PROPMSG_OVER
;REMOTE_PROPMSG0_1:
	LAC	MSG
	XORL	CREV_DTMF		;CREV_DTMF
	BS	ACZ,REMOTE_PROPMSG_DTMF
;REMOTE_PROPMSG0_2:
	LAC	MSG
	XORL	CMSG_BTONE		;CMSG_BTONE
	BS	ACZ,REMOTE_PROEXIT_VPSTOP
;REMOTE_PROPMSG0_3:	
	LAC	MSG
	XORL	CMSG_TMR		;CMSG_TMR
	BS	ACZ,REMOTE_PROPMSG_TMR

	RET
;---------------处理消息
REMOTE_PROPMSG_TMR:
	;CALL	BCVOX_INIT
	
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1

	RET

REMOTE_PROPMSG_OVER:
	BIT	ANN_FG,12
	BS	TB,REMOTE_PROPMSG_NEWOVER
	
	LAC	MSG_ID
	SBH	MSG_T
	BZ	SGN,REMOTE_PROMSG_PLYSTOP

	LAC	MSG_ID			;next message
	ADHK	1
	SAH	MSG_ID
REMOTE_PROPLY_LOADVP:
	CALL	INIT_DAM_FUNC
	CALL	VP_Message
	LAC	MSG_ID
	CALL	ANNOUNCE_NUM

	CALL	MSG_WEEK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	GET_LANGUAGE
	SBHK	1
	BZ	ACZ,REMOTE_PROPLY_LOADVP_1	;Not French
;---French(24-hour format)
	LAC	MSG_ID
	ORL	0XA200
	CALL	DAM_BIOSFUNC
	CALL	VP_HourFre
	
	LAC	MSG_ID
	ORL	0XA100
	CALL	DAM_BIOSFUNC
	CALL	VP_MinutFre

	BS	B1,REMOTE_PROPLY_LOADVP_2
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
REMOTE_PROPLY_LOADVP_1:
	CALL	MSG_HOUR
	CALL	MSG_MIN
	CALL	MSG_AMPM
REMOTE_PROPLY_LOADVP_2:
	LAC	MSG_ID
	ORL	0XFE00
	CALL	STOR_VP

	RET

;---------------------------------------
REMOTE_PROPMSG_NEWOVER:
	LAC	MSG_ID
	SBH	MSG_N
	BZ	SGN,REMOTE_PROMSG_PLYSTOP

	LAC	MSG_ID			;next message
	ADHK	1
	SAH	MSG_ID

REMOTE_PROPLY_LOADNEWVP:
	CALL	INIT_DAM_FUNC
	CALL	VP_Message
	LAC	MSG_ID
	CALL	ANNOUNCE_NUM

	CALL	MSG_WEEKNEW
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	GET_LANGUAGE
	SBHK	1
	BZ	ACZ,REMOTE_PROPLY_LOADNEWVP_1	;Not French
;---French(24-hour format)
	LAC	MSG_ID
	ORL	0XA280
	CALL	DAM_BIOSFUNC
	CALL	VP_HourFre
	
	LAC	MSG_ID
	ORL	0XA180
	CALL	DAM_BIOSFUNC
	CALL	VP_MinutFre

	BS	B1,REMOTE_PROPLY_LOADNEWVP_2
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
REMOTE_PROPLY_LOADNEWVP_1:
	CALL	MSG_HOURNEW
	CALL	MSG_MINNEW
	CALL	MSG_AMPMNEW
REMOTE_PROPLY_LOADNEWVP_2:
	LAC	MSG_ID
	ORL	0XFD00
	CALL	STOR_VP

	RET

;---------------------------------------
REMOTE_PROPMSG_DTMF:
	LAC	DTMF_VAL
	ANDL	0X0F
	BS	ACZ,REMOTE_PROPMSG_ERAPLYING	;0---erase playing message
	SBHK	1
	BS	ACZ,REMOTE_PROPMSG_REPEAT	;1---repeat message
	SBHK	1
	BS	ACZ,REMOTE_PROMSG_PLYSTOP	;2---STOP
	SBHK	1
	BS	ACZ,REMOTE_PROPMSG_NEXT		;3---skip to next message
	;SBHK	1
	;BS	ACZ,REMOTE_PROPMSG_PLYPRE	;4---previous message
	;SBHK	7
	;BS	ACZ,REMOTE_PROMSG_DO_PAUSE	;*---do pause

	RET
;---------------------------------------
REMOTE_PROPMSG_ERAPLYING:

	CALL	INIT_DAM_FUNC
	BIT	ANN_FG,12
	BS	TB,REMOTE_PROPMSG_ERANEW
	BS	B1,REMOTE_PROPMSG_ERAALL

REMOTE_PROPMSG_ERANEW:
	LAC	MSG_ID
	ORL	0X2480
	CALL	DAM_BIOSFUNC
	BS	B1,REMOTE_PROMSG_ERADONE
	
REMOTE_PROPMSG_ERAALL:
	LAC	MSG_ID
	ORL	0X2080
	CALL	DAM_BIOSFUNC
REMOTE_PROMSG_ERADONE:
	CALL	INIT_DAM_FUNC
	CALL	VP_Message
	CALL	VP_Erased
	LACK	0X005
	CALL	STOR_VP
	
	RET
;---------------------------------------
REMOTE_PROMSG_DO_PAUSE:		;Reserved
	LAC	CONF
	ORL	0X0100
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	PRO_VAR
	ORK	0X10
	SAH	PRO_VAR
	
	LACL	1000
	CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1
	
	RET
;---------------------------------------
REMOTE_PROPMSG_PLYPRE:		;前一个
	LAC	MSG_ID
	SBHK	1
	BS	ACZ,REMOTE_PROPALL_PLYPRE_1 ;第一个吗?
	
	LAC	MSG_ID
	SBHK	1
	SAH	MSG_ID
REMOTE_PROPALL_PLYPRE_1:
	BIT	ANN_FG,12
	BS	TB,REMOTE_PROPLY_LOADNEWVP
	BS	B1,REMOTE_PROPLY_LOADVP
;---------------------------------------
REMOTE_PROPMSG_REPEAT:
	BIT	ANN_FG,12
	BZ	TB,REMOTE_PROPLY_LOADVP
	BS	B1,REMOTE_PROPLY_LOADNEWVP
;---------------------------------------
REMOTE_PROPMSG_NEXT:		;下一个
	BS	B1,REMOTE_PROPMSG_OVER
;-------
REMOTE_PROMSG_PLYSTOP:
	CALL	INIT_DAM_FUNC
	CALL	BBEEP		;BB
	CALL	BCVOX_INIT	;有键按下BCVOX要清零

	LACL	0X6100
	CALL	DAM_BIOSFUNC
	CALL	GC_CHK
	
	CALL	VPMSG_CHK
;-!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	SEND_MSGNUM
;-!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	0
	SAH	PRO_VAR
	SAH	PRO_VAR1
	
	RET
;-----------------------------------------------------------
REMOTE_PROPMSG1_PAUSE:
	LAC	MSG
	XORL	CREV_DTMF		;CREV_DTMF
	BS	ACZ,REMOTE_PROMSG_PAUSE_DTMF
;REMOTE_PROPMSG1_PAUSE_1:
	LAC	MSG
	XORL	CMSG_TMR		;CMSG_TMR
	BS	ACZ,REMOTE_PROX_PAUSE_TIMER
	
	RET
;---------------
REMOTE_PROMSG_PAUSE_DTMF:		;reserved
	
	LAC	DTMF_VAL
	ANDL	0X0F
	BS	ACZ,REMOTE_PROMSG_PAUSE_ERASE	;0---pause playing message
	SBHK	1
	BS	ACZ,REMOTE_PROMSG_PAUSE_REPEAT	;1---repeat playing message
	SBHK	1
	BS	ACZ,REMOTE_PROMSG_PLYSTOP	;2---stop playing message
	SBHK	1
	BS	ACZ,REMOTE_PROMSG_PAUSE_NEXT	;3---skip playing message
	SBHK	1
	;BS	ACZ,REMOTE_PROPMSG_PLYPRE	;4---skip to previous message
	;SBHK	7
	;BS	ACZ,REMOTE_PROX_DO_CONPLY	;*---play again
	
	RET
;---------------
REMOTE_PROX_PAUSE_TIMER:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	10
	BS	SGN,REMOTE_PROX_PAUSE_TIMER_1
	
	CALL	INIT_DAM_FUNC
	CALL	BBEEP
	LACK	0
	SAH	PRO_VAR

REMOTE_PROX_PAUSE_TIMER_1:	
	RET

;---------------------------------------
REMOTE_PROMSG_PAUSE_ERASE:
	
	LAC	PRO_VAR
	ANDL	0XFF0F
	SAH	PRO_VAR

	BS	B1,REMOTE_PROPMSG_ERAPLYING
REMOTE_PROMSG_PAUSE_REPEAT:
	LAC	PRO_VAR
	ANDL	0XFF0F
	SAH	PRO_VAR

	BS	B1,REMOTE_PROPMSG_REPEAT
REMOTE_PROMSG_PAUSE_NEXT:
	LAC	PRO_VAR
	ANDL	0XFF0F
	SAH	PRO_VAR

	BS	B1,REMOTE_PROPMSG_NEXT
;---------------------------------------
REMOTE_PROX_DO_CONPLY:
	LAC	CONF
	ANDL	~(1<<8)
	CALL	DAM_BIOSFUNC
	
	LAC	PRO_VAR
	ANDL	0XFF0F
	SAH	PRO_VAR
	
	RET
;=======================================================================
;33333333333333333333333333333333333333333333333333333333333333333333333
REMOTE_PRODALL:

;=======================================================================
;44444444444444444444444444444444444444444444444444444444444444444444444
REMOTE_PROMVOP:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,REMOTE_PROMVOP_STOPVP	;VP完
;REMOTE_PROMVOP_1:	
	LAC	MSG
	XORL	CREV_DTMF			;CREV_DTMF
	BS	ACZ,REMOTE_PROMVOP_DTMF
;REMOTE_PROMVOP_2:
	LAC	MSG				;CPC/ONOFF
	XORL	CMSG_CPC
	BS	ACZ,REMOTE_PROMVOP_CPC
	
	RET
;---------------
REMOTE_PROMVOP_CPC:
	BS	B1,REMOTE_PRO0_CPC	;相当于待机状态

REMOTE_PROMVOP_DTMF:
	BS	B1,REMOTE_PRO0_REV_DTMF

REMOTE_PROMVOP_STOPVP:
REMOTE_PROMVOP_VPOVER:
	CALL	BBEEP

	LACK	0
	SAH	PRO_VAR
	SAH	PRO_VAR1
	
	RET
;=======================================================================
;55555555555555555555555555555555555555555555555555555555555555555555555
REMOTE_PROONFF:
	RET
;=======================================================================
;66666666666666666666666666666666666666666666666666666666666666666666666
;REMOTE_PRO6:
	;RET
;=======================================================================
;77777777777777777777777777777777777777777777777777777777777777777777777
;REMOTE_PROOGM:
;=======================================================================
;88888888888888888888888888888888888888888888888888888888888888888888888
REMOTE_PROROMMONITOR:
;EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
REMOTE_PROEXIT:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,REMOTE_PROEXIT_VPSTOP
	
	RET
;---------------------------------------
REMOTE_PROEXIT_VPSTOP:		;exist to idle
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF	
	CALL	HOOK_IDLE	;hook idle

	LACL	CMODE9
	CALL	DAM_BIOSFUNC

	CALL	VPMSG_CHK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	SEND_MSGNUM
	CALL	EXIT_TOIDLE
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	MSGLED_IDLE

	CALL	CLR_FUNC
	LACL	LOCAL_PRO	;goto local mode
     	CALL	PUSH_FUNC	
	
	LACK	0
	SAH	PRO_VAR

	LACL	CMSG_INIT
	CALL	STOR_MSG

	RET
;-------------------------------------------------------------------------------
VP_RemoteMenu:
	CALL	GET_LANGUAGE
	BS	ACZ,VP_RemoteMenu_0
	SBHK	1
	BS	ACZ,VP_RemoteMenu_French
	SBHK	1
	BS	ACZ,VP_RemoteMenu_Spanish
VP_RemoteMenu_0:			;English
	LACL	0XFF00|40
	CALL	STOR_VP
	RET
VP_RemoteMenu_Spanish:			;Spanish	
	LACL	0XFF00|99
	CALL	STOR_VP
	RET
VP_RemoteMenu_French:			;French	
	LACL	0XFF00|163
	CALL	STOR_VP
	RET
;===============================================================================
;-------------------------------------------------------------------------------

.INCLUDE	l_beep/l_beep.asm
.INCLUDE	l_beep/l_bbeep.asm
.INCLUDE	l_beep/l_bbbeep.asm
.INCLUDE	l_beep/l_lbeep.asm

.INCLUDE	l_CodecPath/l_allopen.asm
.INCLUDE	l_CodecPath/l_rmtply.asm
.INCLUDE	l_CodecPath/l_rmtrec.asm

.INCLUDE	l_flashmsg/l_biosfull.asm
.INCLUDE	l_flashmsg/l_flashmsg.asm
.INCLUDE	l_flashmsg/l_plymsg.asm

.INCLUDE	l_iic/l_storsqueue.asm
.INCLUDE	l_iic/l_getrqueue.asm
.INCLUDE	l_iic/l_flashfull.asm
.INCLUDE	l_iic/l_flashmsg.asm
.INCLUDE	l_iic/l_exit.asm

.INCLUDE	l_math/l_hexdgt.asm

.INCLUDE	l_line.asm

.INCLUDE	l_port/l_cidtalk.asm
.INCLUDE	l_port/l_hookidle.asm
.INCLUDE	l_port/l_hookoff.asm
.INCLUDE	l_port/l_hookon.asm
.INCLUDE	l_port/l_hwalc.asm
.INCLUDE	l_port/l_msgled.asm
.INCLUDE	l_port/l_spkctl.asm

.INCLUDE	l_respond/l_btone.asm
.INCLUDE	l_respond/l_ctone.asm
.INCLUDE	l_respond/l_vox.asm
.INCLUDE	l_respond/l_dtmf.asm
.INCLUDE	l_respond/l_ansrmt_resp.asm
.INCLUDE	l_respond/l_vpqueue.asm

.INCLUDE	l_table/l_dtmftable.asm

.INCLUDE	l_voice/l_answeroff.asm
.INCLUDE	l_voice/l_answeron.asm
.INCLUDE	l_voice/l_call.asm
.INCLUDE	l_voice/l_endof.asm
.INCLUDE	l_voice/l_num.asm
.INCLUDE	l_voice/l_plymsg.asm
;-------------------------------------------------------------------------------
.END
	