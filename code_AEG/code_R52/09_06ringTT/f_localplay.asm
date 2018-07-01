.NOLIST
.INCLUDE	REG_D20.inc
.INCLUDE	MX93D20.inc
.INCLUDE	MACRO.inc
.INCLUDE	CONST.inc

.GLOBAL	LOCAL_PROREC
.GLOBAL	LOCAL_PROPLY
.GLOBAL	LOCAL_PROOGM
.GLOBAL	LOCAL_PROTWR
;-------------------------------------------------------------------------------
.EXTERN	GetOneConst
.EXTERN	INIT_DAM_FUNC
;.EXTERN	DAA_LIN_SPK
;.EXTERN	DAA_LIN_REC
;.EXTERN	DAA_ROM_MOR
.EXTERN	DAA_SPK
.EXTERN	DAA_REC
.EXTERN	DAA_OFF
.EXTERN	LBEEP
.EXTERN	BBBEEP
.EXTERN	BBEEP
.EXTERN	BEEP

.EXTERN	HOOK_ON
.EXTERN	HOOK_OFF

.EXTERN	PUSH_FUNC
.EXTERN	PAUBEEP
.EXTERN	CLR_FUNC

;.EXTERN	SET_LED1
;.EXTERN	SET_LED2
.EXTERN	STOR_MSG
.EXTERN	OGM_SELECT
;.EXTERN	OGM_STATUS
.EXTERN	DGT_TAB
.EXTERN	SET_LED3
.EXTERN	SET_LED4
.EXTERN	LED_HLDISP
.EXTERN	GET_SEGCODE
.EXTERN	STOR_VP
.EXTERN	LOCAL_PRO
.EXTERN	SET_TIMER
.EXTERN	CLR_TIMER
.EXTERN	REC_START
.EXTERN	LINE_START
.EXTERN	BCVOX_INIT
.EXTERN	FFW_MANAGE
.EXTERN	REW_MANAGE
.EXTERN	VPMSG_CHK
.EXTERN	CLR_FLAG
.EXTERN	SET_DELMARK
.EXTERN	DAM_BIOSFUNC
.EXTERN	VPMSG_DEL
.EXTERN	GC_CHK
.EXTERN	REAL_DEL

.LIST
;-------------------------------------------------------------------------------
.ORG	0x5500
;-------------------------------------------------------------------------------

LOCAL_PROREC:			;0Xyyy2 = record MEMO
	LAC	MSG
	XORL	CPARA_MINE
	BS	ACZ,LOCAL_PROREC_PMINE
	
	LAC	PRO_VAR
	SFR	4
	ANDK	0X0F
	BS	ACZ,LOCAL_PROREC0	;prompt
	SBHK	1
	BS	ACZ,LOCAL_PROREC1	;record
	SBHK	1
	BS	ACZ,LOCAL_PROREC2	;record
	
	RET
;---------------
LOCAL_PROREC_PMINE:
	LACL	CRING_IN
	CALL	STOR_MSG	;当来铃一样的处理
	
	RET
;---------------
LOCAL_PROREC0:
	LAC	MSG
	XORL	CMSG_KEY4S		;MEMO key released worn and stop
	BS	ACZ,LOCAL_PROWORN
;LOCAL_PROREC0_1:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PRO0_RECSTART	;end beep and start record
;LOCAL_PROREC0_2:	
	LAC	MSG
	XORL	CRING_IN		;RING
	BS	ACZ,LOCAL_PROREC0_RING
	
	RET
LOCAL_PROWORN:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BBBEEP
	
	LACK	0X0
	SAH	PRO_VAR
	
	RET
LOCAL_PROREC0_RING:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LACK	0X005
	CALL	STOR_VP
	
	LACK	0X0
	SAH	PRO_VAR
	
	RET	
LOCAL_PRO0_RECSTART:
	CALL	INIT_DAM_FUNC
	CALL	DAA_REC
	CALL	REC_START

	LACL	1000
	CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1

	LACK	0X012
	SAH	PRO_VAR
	
	RET	
LOCAL_PROREC1:
	LAC	MSG
	XORL	CMSG_KEY4S		;stop record
	BS	ACZ,LOCAL_PROREC_STOP
LOCAL_PROREC1_1:
	LAC	MSG
	XORL	CREC_FULL		;timer
	BS	ACZ,LOCAL_PROREC_MFUL
LOCAL_PROREC1_2:
	LAC	MSG
	XORL	CMSG_TMR		;timer
	BS	ACZ,LOCAL_PROREC1_TMR
LOCAL_PROREC1_3:
	LAC	MSG
	XORL	CRING_IN		;RING
	BS	ACZ,LOCAL_PROREC_RING
	RET

LOCAL_PROREC1_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	;SBHK	60
	;BZ	SGN,LOCAL_PROREC1_TMR_OVER	;最长录60s(MEMO时长不受限制)
	
	RET
LOCAL_PROREC1_TMR_OVER:		;录满60s | full
	CALL	CLR_TIMER
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	
	CALL	VPMSG_CHK
	LAC	MSG_T
	CALL	LED_HLDISP	;VP总数
	
	LACK	0X022
	SAH	PRO_VAR		;时间到了,等待松手

	RET
;---------------------------------------
LOCAL_PROREC_MFUL:
	;CALL	STATUS_OVF_ON
LOCAL_PROREC_STOP:
	LAC	PRO_VAR1
	SBHK	2
	BS	SGN,LOCAL_PRORECFAIL_STOP
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP

	LACK	0X0
	SAH	PRO_VAR
	
	CALL	VPMSG_CHK
	BIT	ANN_FG,12
	BS	TB,LOCAL_PROREC_STOP1
	LAC	MSG_T
	CALL	LED_HLDISP	;VP总数

	RET			;录音完毕后(正常)退出
LOCAL_PROREC_STOP1:
	LAC	MSG_N
	CALL	LED_HLDISP	;VP总数
	
	RET
;---------------------------------------
LOCAL_PROREC_RING:
	LAC	PRO_VAR1
	SBHK	2
	BS	SGN,LOCAL_PRORECFAIL_STOP
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LACK	0X005
	CALL	STOR_VP

	LACK	0X0
	SAH	PRO_VAR
	
	CALL	VPMSG_CHK
	BIT	ANN_FG,12
	BS	TB,LOCAL_PROREC_RING1
	LAC	MSG_T
	CALL	LED_HLDISP	;VP总数

	RET			;录音完毕后(正常)退出
LOCAL_PROREC_RING1:
	LAC	MSG_N
	CALL	LED_HLDISP	;VP总数
	
	RET

LOCAL_PRORECFAIL_STOP:		;录音失败(非正常)退出
	LAC	CONF
	ORL	0X0800
	SAH	CONF
	CALL	DAM_BIOSFUNC
	CALL	INIT_DAM_FUNC
	
	CALL	DAA_SPK
	CALL	BBBEEP
	
	LACK	0
	SAH	PRO_VAR
	
	RET
;---------------------------------------
LOCAL_PROREC2:			;timer over|full了,等待松手
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROREC2_VPSTOP
LOCAL_PROREC2_1:
	LAC	MSG
	XORL	CMSG_KEY4S
	BS	ACZ,LOCAL_PROREC2_STOP	;
LOCAL_PROREC2_2:	
	LAC	MSG
	XORL	CRING_IN		;RING
	BS	ACZ,LOCAL_PROREC2_STOP
	RET
LOCAL_PROREC2_VPSTOP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	
	RET
LOCAL_PROREC2_STOP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	
	LACK	0X0
	SAH	PRO_VAR
	
	LACL	CMSG_INIT
	CALL	STOR_MSG
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROPLY:			;0Xyyy1
	LAC	MSG
	XORL	CMSG_KEY8D		;VOL-
	BS	ACZ,LOCAL_PROX_VOLS
	LAC	MSG
	XORL	CMSG_KEY7D		;VOL+
	BS	ACZ,LOCAL_PROX_VOLA
	LAC	MSG
	XORL	CMSG_KEY6S		;ON/OFF(stop)
	BS	ACZ,LOCAL_PROPLY_STOP
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
	SBHK	1
	BS	ACZ,LOCAL_PROPLY_2	;(0X0y21)pauseing(waiting for REW key release)
	
	RET

LOCAL_PROPLY_0:	
	LAC	MSG
	XORL	CMSG_KEY1D		;pause
	BS	ACZ,LOCAL_PROPLY_PAUSE

	LAC	PRO_VAR
	SFR	8
	ANDK	0X0F
	BS	ACZ,LOCAL_PROPLY_0_0	;(0X0001)playing Vop
	SBHK	1
	BS	ACZ,LOCAL_PROPLY_0_1	;(0X0101)playing Message
	
	RET
;---------------------------------------
LOCAL_PROPLY_0_0:
	LAC	MSG
	XORL	CVP_STOP		;PLAY END
	BS	ACZ,LOCAL_PROPLY_0_OVER
	
	RET
LOCAL_PROPLY_0_OVER:
	LACL	0X0101
	SAH	PRO_VAR
	BS	B1,LOCAL_PROPLY_OVER
;---------------------------------------
LOCAL_PROPLY_0_1:	
	
LOCAL_PROPLY_0_1_1:
	LAC	MSG
	XORL	CMSG_KEY2D		;FFW
	BS	ACZ,LOCAL_PROPLY_FFW
LOCAL_PROPLY_0_1_2:
	LAC	MSG
	XORL	CMSG_KEY3D		;erase
	BS	ACZ,LOCAL_PROPLY_ERASE
LOCAL_PROPLY_0_1_3:
	LAC	MSG
	XORL	CMSG_KEY5D		;repeat
	BS	ACZ,LOCAL_PROPLY_REW
LOCAL_PROPLY_0_1_4:
	LAC	MSG
	XORL	CVP_STOP		;PLAY END
	BS	ACZ,LOCAL_PROPLY_OVER

	RET
;---------------
LOCAL_PROPLY_FFW:

	BS	B1,LOCAL_PROPLY_OVER


LOCAL_PROPLY_REW:
	LAC	PRO_VAR
	ANDL	0XFF0F
	ORK	0X020
	SAH	PRO_VAR

	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER

	;LAC	CONF
	;ORL	1<<8
	;CALL	DAM_BIOSFUNC

	CALL	INIT_DAM_FUNC
	
	RET
LOCAL_PROPLY_REW1:
	
	RET	
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
	
	LACL	320
	CALL	PAUBEEP		;BEEP Prompt
	
	CALL	DAA_OFF
	
	LAC	PRO_VAR
	ANDL	0XFF0F
	ORK	0X010
	SAH	PRO_VAR
	
	LACK	0
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
	LAC	MSG_ID
	CALL	SET_DELMARK
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	
	LACL	0X0101
	SAH	PRO_VAR
	
	LACL	0XA186
	SAH	LED_L		;Display "dE"
	
	LACK	0X040
	CALL	STOR_VP

	RET
LOCAL_PROPLY_OVER:
	CALL	INIT_DAM_FUNC

	LAC	MSG_ID
	SBH	MSG_T
	BZ	SGN,LOCAL_PROPLY_STOP

	LAC	MSG_ID			;next message
	ADHK	1
	SAH	MSG_ID
	
	LAC	FILE_ID			;next message
	ADHK	1
	SAH	FILE_ID
	
	BIT	ANN_FG,12
	BZ	TB,LOCAL_PROPLY_LOADVP

	CALL	FFW_MANAGE
	BZ	ACZ,LOCAL_PROPLY_STOP	;THE LAST ONE	

LOCAL_PROPLY_LOADVP:

	LAC	FILE_ID
	CALL	LED_HLDISP
	
	CALL	BEEP

	LAC	MSG_ID
	ORL	0XFE00
	CALL	STOR_VP
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROPLY_STOP:		;全播放完毕或强行退出Play-Mode
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BBEEP
	
	CALL	CLR_TIMER
	
	LACK	0X0
	SAH	PRO_VAR

	CALL	REAL_DEL
	CALL	GC_CHK
	
	CALL	VPMSG_CHK

	BIT	ANN_FG,12
	BS	TB,LOCAL_PROPLY_STOP1
	
	LAC	MSG_T
	CALL	LED_HLDISP
	
	RET
LOCAL_PROPLY_STOP1:
	LAC	MSG_N
	CALL	LED_HLDISP
	
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

	BIT	ANN_FG,12
	BS	TB,LOCAL_PROPLY_RING1
	
	LAC	MSG_T
	CALL	LED_HLDISP
	
	RET
LOCAL_PROPLY_RING1:
	LAC	MSG_N
	CALL	LED_HLDISP
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROPLY_1:			;PAUSE
	LAC	MSG
	XORL	CMSG_KEY1D		;pause
	BS	ACZ,LOCAL_PROPLY_1_PLAY
LOCAL_PROPLY_1_2:
	;LAC	MSG
	;XORL	CMSG_KEY3D		;erase
	;BS	ACZ,LOCAL_PROPLY_ERASE
LOCAL_PROPLY_1_3:
	LAC	MSG
	XORL	CMSG_TMR		;TMR
	BS	ACZ,LOCAL_PROPLY_TMR
	
	RET
LOCAL_PROPLY_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	8
	BZ	SGN,LOCAL_PROPLY_STOP
	
	
	RET

LOCAL_PROPLY_1_PLAY:
	CALL	DAA_SPK
	
	LAC	PRO_VAR
	ANDL	0XFF0F
	SAH	PRO_VAR

	CALL	CLR_TIMER

	LAC	CONF
	ANDL	~(1<<8)
	CALL	DAM_BIOSFUNC

	;LAC	MSG_ID
	LAC	FILE_ID
	CALL	LED_HLDISP

	RET
;---------------------------------------
LOCAL_PROPLY_2:			;等待REW松开
	LAC	MSG
	XORL	CMSG_TMR		;TMR
	BS	ACZ,LOCAL_PROPLY_REWEXE
	LAC	MSG
	XORL	CMSG_KEY5S		;repeat
	BS	ACZ,LOCAL_PROPLY_REP
	
	RET
LOCAL_PROPLY_REP:
	CALL	INIT_DAM_FUNC
	
	LAC	PRO_VAR
	ANDL	0XFF0F
	SAH	PRO_VAR
	
	BS	B1,LOCAL_PROPLY_LOADVP
;---------------------------------------
LOCAL_PROPLY_REWEXE:	
	LAC	MSG_ID
	SBHK	1
	BS	ACZ,LOCAL_PROPLY_REWEXE_1	;第一个吗?

	LAC	MSG_ID
	SBHK	1
	SAH	MSG_ID
	
	LAC	FILE_ID
	SBHK	1
	BS	ACZ,LOCAL_PROPLY_REWEXE_1
	SAH	FILE_ID
LOCAL_PROPLY_REWEXE_1:	
	BIT	ANN_FG,12
	BZ	TB,LOCAL_PROPLY_REWEXE_2

	CALL	REW_MANAGE
LOCAL_PROPLY_REWEXE_2:
	CALL	INIT_DAM_FUNC
	
	LAC	PRO_VAR
	ANDL	0XFF0F
	SAH	PRO_VAR
	
	CALL	CLR_TIMER
	BS	B1,LOCAL_PROPLY_LOADVP
;-------------------------------------------------------------------------------
LOCAL_PROOGM:				;0Xyyy3
	LAC	MSG
	XORL	CPARA_MINE
	BS	ACZ,LOCAL_PROOGM_PMINE
	
	LAC	PRO_VAR
	SFR	4
	ANDK	0X0F
	BS	ACZ,LOCAL_PROOGM_PLYVOP		;0 - VOP
	SBHK	1
	BS	ACZ,LOCAL_PROOGM_RECOGM		;1 - record OGM
	SBHK	1
	BS	ACZ,LOCAL_PROOGM_PLYOGM		;2 - play OGM

	RET
;---------------
LOCAL_PROOGM_PMINE:
	LACL	CRING_IN
	CALL	STOR_MSG	;当来铃一样的处理
	
	RET
;---------------
LOCAL_PROOGM_PLYVOP:
	LAC	MSG
	XORL	CMSG_KEY5S
	BS	ACZ,LOCAL_PROOGM_RECOGMSUCC_STOP	;REC stop AND PLAY
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,LOCAL_PROOGM_PLYVOP_RING	;RING
;LOCAL_PROOGM_PLYVOP0_1:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROOGM_RECSTART	;end beep and start record
	
	RET
LOCAL_PROOGM_PLYVOP_RING:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LACK	0X005
	CALL	STOR_VP
	
	LACK	0X0
	SAH	PRO_VAR
	
	RET	
LOCAL_PROOGM_RECSTART:
	CALL	INIT_DAM_FUNC
	CALL	DAA_REC
	LACK	0X0013
	SAH	PRO_VAR

	CALL	OGM_SELECT
;---set user index data0"OGM_ID"	
    	LAC	MSG_N
    	ORL	0X8D00
    	CALL	DAM_BIOSFUNC
;---delete the old OGM fisrt------------
	;LAC	MSG_ID
	;CALL	VPMSG_DEL
	;CALL	GC_CHK
;---	
	CALL	REC_START
	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER

	RET
LOCAL_PROOGM_RECOGM:			;record OGM
	LAC	MSG
	XORL	CMSG_KEY5S		;OGM key released on/off stop record
	BS	ACZ,LOCAL_PROOGM_RECOGM_STOP
	LAC	MSG
	XORL	CRING_IN		;RING
	BS	ACZ,LOCAL_PROOGM_RECOGM_RING
LOCAL_PROOGM_REC1_1:
	LAC	MSG
	XORL	CMSG_TMR		;timer
	BS	ACZ,LOCAL_PROOGM_RECTMR
LOCAL_PROOGM_REC1_2:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROOGM_RECOGMSUCC_STOP	;end beep and start PLAY OGM
LOCAL_PROOGM_REC1_3:
	LAC	MSG
	XORL	CREC_FULL		;FULL
	BS	ACZ,LOCAL_PROOGM_RECTMR_1_TMROVER		;end beep and start PLAY OGM
		
	
	RET
LOCAL_PROOGM_RECOGM_RING:
	LAC	PRO_VAR1
	SBHK	2
	BZ	SGN,LOCAL_PROOGM_RECOGM_RING1
	LAC	CONF
	ORL	1<<11
	SAH	CONF
	CALL	DAM_BIOSFUNC
LOCAL_PROOGM_RECOGM_RING1:	
	CALL	INIT_DAM_FUNC
	LACK	0X005
	CALL	STOR_VP
	
	LACK	0
	SAH	PRO_VAR
	
	RET	
LOCAL_PROOGM_RECTMR:
	LAC	PRO_VAR
	SFR	8
	ANDK	0X0F
	BS	ACZ,LOCAL_PROOGM_RECTMR_0
	SBHK	1
	BS	ACZ,LOCAL_PROOGM_RECTMR_1

	RET
	
LOCAL_PROOGM_RECTMR_0:		;50s
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	50
	BZ	SGN,LOCAL_PROOGM_RECTMR_0_TMROVER
	
	RET
LOCAL_PROOGM_RECTMR_0_TMROVER:
	LACL	0X0113
	SAH	PRO_VAR
	
	LACL	200
	CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1
	
	RET
;---------------------------------------
LOCAL_PROOGM_RECTMR_1:		;200ms	timer
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	50
	BZ	SGN,LOCAL_PROOGM_RECTMR_1_TMROVER
	
	LAC	LED_L
	XORL	0XFFFF
	BS	ACZ,LOCAL_PROOGM_RECTMR_1_0
	
	LACL	0XFFFF		;LED OFF
	SAH	LED_L
	
	RET
LOCAL_PROOGM_RECTMR_1_0:
	LACL	0XAF88		;"0XrA"
	SAH	LED_L
	
	RET
LOCAL_PROOGM_RECTMR_1_TMROVER:		;计时或FULL
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	LACK	0X03F
	CALL	STOR_VP
	
	LACL	0XAF88		;"0XrA"
	SAH	LED_L
	CALL	CLR_TIMER

	RET

LOCAL_PROOGM_RECTMR_2_VPSTOP:
	BS	B1,LOCAL_PROOGM_RECOGMSUCC_STOP
;---------------------------------------
LOCAL_PROOGM_RECOGM_STOP:
	LAC	PRO_VAR1
	SBHK	2
	BZ	SGN,LOCAL_PROOGM_RECOGMSUCC_STOP

;LOCAL_PROOGM_RECOGMFAIL_STOP:	
	LAC	CONF
	ORL	0X0800
	CALL	DAM_BIOSFUNC
LOCAL_PROOGM_RECOGMSUCC_STOP:	;准备播放OGM
	
	CALL	DAA_SPK
	LACK	0X0023
	SAH	PRO_VAR		;进入播放OGM子功能
PROOGM_LOADOGM:
	CALL	INIT_DAM_FUNC
	CALL	OGM_SELECT
	CALL	CLR_TIMER
;---LED_L "PA"
	LACL	0X8C88
	SAH	LED_L
	
	CALL	BEEP
	LAC	MSG_ID
	ORL	0XFE00
	CALL	STOR_VP

	CALL	OGM_SELECT
	BZ	ACZ,MAIN_PRO0_PLAY_OGM1
	
	LACK	0X0
	SAH	PRO_VAR
	
	CALL	INIT_DAM_FUNC
	CALL	BBEEP

MAIN_PRO0_PLAY_OGM1:

	RET

LOCAL_PROOGM_PLYOGM:		;PLAY 
	LAC	MSG
	XORL	CMSG_KEY6D		;stop record(手动停止)
	BS	ACZ,LOCAL_PROOGM_PLYOGM_STOP
	LAC	MSG
	XORL	CRING_IN		;RING
	BS	ACZ,LOCAL_PROOGM_PLYOGM_RING
LOCAL_PROOGM_PLYOGM0_1:	
	LAC	MSG
	XORL	CVP_STOP		;stop record(播完停止)
	BS	ACZ,LOCAL_PROOGM_PLYOGM_STOP
LOCAL_PROOGM_PLYOGM0_2:	
	LAC	MSG
	XORL	CMSG_KEY8D		;VOL-
	BS	ACZ,LOCAL_PROX_VOLS
LOCAL_PROOGM_PLYOGM0_3:
	LAC	MSG
	XORL	CMSG_KEY7D		;VOL+
	BS	ACZ,LOCAL_PROX_VOLA
		
	RET
LOCAL_PROOGM_PLYOGM_RING:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LACK	0X005
	CALL	STOR_VP

	LACK	0
	SAH	PRO_VAR
	
	RET
LOCAL_PROOGM_PLYOGM_STOP:	;播放完后发BEEP声
	CALL	INIT_DAM_FUNC
	CALL	BEEP
	;LACK	0X001
	;CALL	STOR_VP
	LACK	0
	SAH	PRO_VAR
	
	RET

LOCAL_PROOGM_WORN:
	CALL	INIT_DAM_FUNC
	CALL	BBBEEP
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROTWR:
	LAC	PRO_VAR
	SFR	4
	ANDK	0X0F
	BS	ACZ,LOCAL_PROTWR0	;for initial
	SBHK	1
	BS	ACZ,LOCAL_PROTWR1	;for record/line
	SBHK	1
	BS	ACZ,LOCAL_PROTWR_EXIT	;for end(TimeOut/BTONE/CTONE/VOX_ON)

	RET

;---------------
LOCAL_PROTWR0:
	LAC	MSG
	XORL	CMSG_INIT		;INITIAL
	BS	ACZ,LOCAL_PROTWR0_INIT

	RET
;---
LOCAL_PROTWR0_INIT:			;开始录音	
	CALL	INIT_DAM_FUNC
	CALL	DAA_TWAY_REC
	CALL	TWHOOK_ON

	LACK	0X015
	SAH	PRO_VAR
	
	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER

	;CALL	MSG_CHK
	;CALL	GET_FILEID
	;CALL	SET_USRDAT
	
	CALL	REC_START
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROTWR1:
	LAC	MSG
	XORL	CMSG_TMR		;time 1s
	BS	ACZ,LOCAL_PROTWR1_TMR
;LOCAL_PROTWR1_1:
	LAC	MSG
	XORL	CMSG_KEY4S		;MEMO stop record
	BS	ACZ,LOCAL_PROTWR1_STOP
;LOCAL_PROTWR1_2:
	LAC	MSG
	XORL	CREC_FULL		;REC_FULL
	BS	ACZ,LOCAL_PROTWR1_FUL
;LOCAL_PROTWR1_3:	
	LAC	MSG
	XORL	CRING_IN		;RING
	BS	ACZ,LOCAL_PROTWR1_STOP
;LOCAL_PROTWR1_4:	
	LAC	MSG
	XORL	CPARA_MINE		;并机
	BS	ACZ,LOCAL_PROTWR1_STOP
	
	

	RET
;---				;由于后BTONE,CTONE,VOX要持续一段时间,可不考虑小长度的录音删除问题

LOCAL_PROTWR1_STOP:
	LAC	PRO_VAR1
	SBHK	2
	BZ	SGN,LOCAL_PROTWR1_STOP1
	LAC	CONF
	ORL	1<<11
	SAH	CONF
	CALL	DAM_BIOSFUNC
LOCAL_PROTWR1_STOP1:	
	CALL	INIT_DAM_FUNC
	LACK	0X005
	CALL	STOR_VP

	LACK	0X025
	SAH	PRO_VAR

	RET
LOCAL_PROTWR1_FUL:
	CALL	INIT_DAM_FUNC
	CALL	VPMSG_CHK
	
	BS	B1,LOCAL_PROTWR1_STOP
	;BIT	ANN_FG,13
	;BS	TB,LOCAL_PROTWR1_FUL_EXIT
	;CALL	REC_START

	;RET
;LOCAL_PROTWR1_FUL_EXIT:
	;BS	B1,LOCAL_PROTWR1_STOP
;---
LOCAL_PROTWR1_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1

	RET
;-------------------------------------------------------------------------------
LOCAL_PROTWR_EXIT:
	LAC	MSG
	XORL	CVP_STOP		
	BS	ACZ,LOCAL_PROTWR_EXIT_END	;CVP_STOP,EXIT播放完毕
	
	RET

LOCAL_PROTWR_EXIT_END:
	CALL	INIT_DAM_FUNC
	LACK	0
	SAH	PRO_VAR
	CALL	TWHOOK_OFF
	
	LACL	CMSG_INIT
	CALL	STOR_MSG

	CALL	VPMSG_CHK
	BIT	ANN_FG,12
	BS	TB,LOCAL_PROTWR_EXIT_END1
	
	
	LAC	MSG_T
	CALL	LED_HLDISP	;VP总数
	
	RET
LOCAL_PROTWR_EXIT_END1:
	LAC	MSG_N
	CALL	LED_HLDISP	;VP总数
	
	
	RET
;-------------------------------------------------------------------------------
TWHOOK_ON:		;Set GPBD.4
	LIPK	8

	IN	SYSTMP0,GPBD
	LAC	SYSTMP0
	ORL	1<<4
	SAH	SYSTMP0
	OUT	SYSTMP0,GPBD
	ADHK	0

	RET
	
;---
TWHOOK_OFF:		;Reset GPBD.4
	LIPK	8

	IN	SYSTMP0,GPBD
	LAC	SYSTMP0
	ANDL	~(1<<4)
	SAH	SYSTMP0
	OUT	SYSTMP0,GPBD
	ADHK	0

	RET
;---
DAA_TWAY_REC:	;(SW0)(SW2) ==> (AUX->ADC)&(MIC->ADC)
	LIPK    6
	OUTK    (1<<2),SWITCH

	NOP
	IN	SYSTMP0,AGC
	LAC	SYSTMP0
	ANDL	0xF00F
	ORL	0X09FF
	SAH	SYSTMP0
	OUT     SYSTMP0,AGC	; Lin-pga=c ; AD-PGA=c(0dB) ; MIC-pre-pga=c (+21dB)
	ADHK	0
;---
	RET
;-------------------------------------------------------------------------------
.END
	