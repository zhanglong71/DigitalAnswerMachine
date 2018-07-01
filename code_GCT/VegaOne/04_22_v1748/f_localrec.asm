.NOLIST
.INCLUDE	REG_D20.inc
.INCLUDE	MD20U.inc
.INCLUDE	CONST.inc

.GLOBAL	LOCAL_PROREC
.GLOBAL	LOCAL_PROOGM
.GLOBAL	LOCAL_PROTWR
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

;.EXTERN	MSG_WEEK
;.EXTERN	MSG_HOUR
;.EXTERN	MSG_MIN

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
.EXTERN	VP_DefOGM1
.EXTERN	VP_DefOGM2
.EXTERN	VP_Erased
.EXTERN	VP_EndOfMessages
.EXTERN	VP_Message
.EXTERN	VP_MemoryFull
.EXTERN	VP_CHKMemoryFull

.LIST
;-------------------------------------------------------------------------------
.ORG	ADDR_SECOND
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
	BS	ACZ,LOCAL_PROREC2	;prompt(memful/BB/EndOfRecord)
	
	RET
;---------------------------------------
LOCAL_PROREC_PMINE:
	LACL	CRING_IN
	CALL	STOR_MSG	;当来铃一样的处理
	
	RET
;---------------------------------------
LOCAL_PROREC0:
	LAC	MSG
	XORL	CMSG_KEY6S			;stop  worn and stop
	BS	ACZ,LOCAL_PROWORN
;LOCAL_PROREC0_1:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROREC0_RECSTART	;end beep and start record
;LOCAL_PROREC0_2:	
	LAC	MSG
	XORL	CRING_IN			;RING
	BS	ACZ,LOCAL_PROREC0_RING
	
	RET
;---------------------------------------
LOCAL_PROWORN:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BBBEEP
	
	CALL	VPMSG_CHK
;---!!!	
	CALL	SEND_MSGNUM
	CALL	EXIT_TOIDLE
;---!!!	
	LACK	0X0
	SAH	PRO_VAR
	
	RET
LOCAL_PROREC0_RING:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LACK	0X005
	CALL	STOR_VP
	
	CALL	VPMSG_CHK
;---!!!	
	CALL	SEND_MSGNUM
	CALL	EXIT_TOIDLE
;---!!!	
	LACK	0X0
	SAH	PRO_VAR
	
	RET
LOCAL_PROREC0_RECSTART:
	CALL	INIT_DAM_FUNC
	CALL	DAA_REC

	LACL	0xD700|CLVOX_LEVEL	;Set VOX
	CALL	DAM_BIOSFUNC
	LACL	0X7700|CLSILENCE_LEVEL	;Set silence threshold
	CALL	DAM_BIOSFUNC

	CALL	REC_START

	LACL	1000
	CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1

	LACK	0X012
	SAH	PRO_VAR
	
	RET	
;-------------------------------------------------------------------------------
LOCAL_PROREC1:
	LAC	MSG
	XORL	CMSG_KEY6S		;stop record
	BS	ACZ,LOCAL_PROREC1_STOP
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
;---------------------------------------
LOCAL_PROREC1_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1	;MEMO最长录180s
	SBHL	CMEM_LEN
	BZ	SGN,LOCAL_PROREC1_STOP
	
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
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	CALL	VP_MemoryFull

	LACK	0X0022
	SAH	PRO_VAR

	RET
;---------------------------------------	
LOCAL_PROREC1_STOP:
	LAC	PRO_VAR1
	SBHK	2
	BS	SGN,LOCAL_PRORECFAIL_STOP
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP

	LACK	0X022
	SAH	PRO_VAR
	
	;CALL	VPMSG_CHK
;---!!!	
	;CALL	SEND_MSGNUM
	;CALL	EXIT_TOIDLE
;---!!!
	RET
;---------------------------------------
LOCAL_PRORECFAIL_STOP:		;录音失败(非正常)有声退出
	LAC	CONF
	ORL	0X0800
	CALL	DAM_BIOSFUNC
	CALL	INIT_DAM_FUNC
	
	CALL	DAA_SPK
	CALL	BBBEEP
	
	LACK	0X022
	SAH	PRO_VAR
;!!!
	;CALL	SEND_MSGNUM
	;CALL	EXIT_TOIDLE
;!!!	
	;LACK	0
	;SAH	PRO_VAR
	
	RET
;---------------------------------------
LOCAL_PROREC_RING:
	LAC	PRO_VAR1
	SBHK	2
	BS	SGN,LOCAL_PROREC_RINGRECFAIL_STOP
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LACK	0X001
	CALL	STOR_VP
	
	CALL	VPMSG_CHK
;!!!
	CALL	SEND_MSGNUM
	CALL	EXIT_TOIDLE
;!!!
	LACK	0X0
	SAH	PRO_VAR

	RET
LOCAL_PROREC_RINGRECFAIL_STOP:		;录音失败(非正常)无声退出
	LAC	CONF
	ORL	0X0800
	CALL	DAM_BIOSFUNC
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	LACK	0X001
	CALL	STOR_VP
	
	CALL	VPMSG_CHK
;!!!
	CALL	SEND_MSGNUM
	CALL	EXIT_TOIDLE
;!!!	
	LACK	0
	SAH	PRO_VAR

	RET

;-------------------------------------------------------------------------------
LOCAL_PROREC2:			;timer over|full了,等待松手
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROREC2_STOP
LOCAL_PROREC2_1:
	LAC	MSG
	XORL	CMSG_KEY6S
	BS	ACZ,LOCAL_PROREC2_STOP	;
LOCAL_PROREC2_2:	
	LAC	MSG
	XORL	CRING_IN		;RING
	BS	ACZ,LOCAL_PROREC2_STOP

	RET
;---------------------------------------
LOCAL_PROREC2_STOP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LACK	0X001
	CALL	STOR_VP

	CALL	VPMSG_CHK
;!!!
	CALL	SEND_MSGNUM
	CALL	EXIT_TOIDLE

;!!!	
	LACK	0X0
	SAH	PRO_VAR

	RET
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
;-------------------------------------------------------------------------------
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
    	LAC	OGM_ID
    	ORL	0X8D00
    	CALL	DAM_BIOSFUNC
;---	
	LACL	0xD700|CLVOX_LEVEL	;Set VOX
	CALL	DAM_BIOSFUNC
	LACL	0X7700|CLSILENCE_LEVEL	;Set silence threshold
	CALL	DAM_BIOSFUNC

	CALL	REC_START
	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER

	RET
;-------------------------------------------------------------------------------
LOCAL_PROOGM_RECOGM:			;record OGM
	LAC	MSG
	XORL	CMSG_KEY6S		;OGM key released on/off stop record
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
;---------------------------------------
LOCAL_PROOGM_RECTMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHL	COGM_LEN
	BZ	SGN,LOCAL_PROOGM_RECTMR_1_TMROVER

	RET
LOCAL_PROOGM_RECTMR_1_TMROVER:		;计时或FULL
	CALL	INIT_DAM_FUNC
	;CALL	DAA_SPK
	;CALL	BEEP
	LACK	0X03F
	CALL	STOR_VP

	CALL	CLR_TIMER

	RET
;---------------------------------------
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
;!!!
	;CALL	EXIT_TOIDLE	;stop record and start play
;!!!
	LACK	0X0023
	SAH	PRO_VAR		;进入播放OGM子功能
;PROOGM_LOADOGM:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	LAC	OGM_ID
	CALL	OGM_SELECT
	CALL	CLR_TIMER

	CALL	BEEP
	CALL	VP_CHKMemoryFull	;If Memful play "VP_MemoryFull"
	LAC	MSG_ID
	ORL	0XFE00
	CALL	STOR_VP

	LAC	OGM_ID
	CALL	OGM_SELECT
	BZ	ACZ,MAIN_PRO0_PLAY_OGM1
;---default OGM	
	CALL	INIT_DAM_FUNC
	CALL	VP_CHKMemoryFull	;If Memful play "VP_MemoryFull"
	CALL	VP_DefOGM1

	LAC	OGM_ID
	SBHK	COGM1_ID
	BS	ACZ,MAIN_PRO0_PLAY_OGM1

	CALL	INIT_DAM_FUNC
	CALL	VP_CHKMemoryFull	;If Memful play "VP_MemoryFull"
	CALL	VP_DefOGM2

MAIN_PRO0_PLAY_OGM1:

	RET
;-------------------------------------------------------------------------------
LOCAL_PROOGM_PLYOGM:		;PLAY 
	LAC	MSG
	XORL	CMSG_KEY6S		;stop record(手动停止)
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
LOCAL_PROOGM_PLYOGM0_4:
	LAC	MSG
	XORL	CPLY_ERAS
	BS	ACZ,LOCAL_PROOGM_PLYOGM_ERASE
		
	RET
LOCAL_PROOGM_PLYOGM_RING:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LACK	0X005
	CALL	STOR_VP

	LACK	0
	SAH	PRO_VAR
	
	RET

LOCAL_PROOGM_PLYOGM_ERASE:
	CALL	INIT_DAM_FUNC
	
	LAC	MSG_ID
	CALL	VPMSG_DEL
	CALL	GC_CHK

	
	CALL	BEEP
	CALL	VP_Message
	CALL	VP_Erased
	
	RET

LOCAL_PROOGM_PLYOGM_STOP:	;播放完后发BEEP声
	CALL	INIT_DAM_FUNC
	CALL	BEEP
	CALL	VPMSG_CHK
;!!!
	CALL	SEND_MSGNUM
	CALL	EXIT_TOIDLE
;!!!
	LACK	0
	SAH	PRO_VAR
	
	RET
LOCAL_PROX_VOLS:
	LACL	CMSG_VOLS
	CALL	STOR_MSG
	
	RET

LOCAL_PROX_VOLA:
	LACL	CMSG_VOLA
	CALL	STOR_MSG
	
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

	LACL	0xD700|CLVOX_LEVEL	;Set VOX
	CALL	DAM_BIOSFUNC
	LACL	0X7700|CLSILENCE_LEVEL	;Set silence threshold
	CALL	DAM_BIOSFUNC	

	CALL	REC_START
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROTWR1:
	LAC	MSG
	XORL	CMSG_TMR		;time 1s
	BS	ACZ,LOCAL_PROTWR1_TMR
;LOCAL_PROTWR1_1:
	LAC	MSG
	XORL	CMSG_KEY6S		;stop record
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