;-------------------------------------------------------------------------------
.NOLIST
.INCLUDE	include/REG_D22.inc
.INCLUDE	include/MD22U.inc
.INCLUDE	include/CONST.inc

.GLOBAL	ANS_STATE
;-------------------------------------------------------------------------------
.EXTERN	GetOneConst
.EXTERN	DspPly

.EXTERN	INIT_DAM_FUNC
;.EXTERN	ANNOUNCE_NUM

.EXTERN	BCVOX_INIT
.EXTERN	BBBEEP
.EXTERN	BBEEP
.EXTERN	BEEP

.EXTERN	CLR_FUNC
.EXTERN	CLR_TIMER

.EXTERN	DAA_ANS_SPK
.EXTERN	DAA_ANS_REC
.EXTERN	DAA_LIN_SPK
.EXTERN	DAA_LIN_REC
.EXTERN	DAA_SPK
.EXTERN	DAA_OFF
.EXTERN	DAM_BIOSFUNC
.EXTERN	DGT_TAB

.EXTERN	GC_CHK
.EXTERN	GET_VPTLEN

.EXTERN	HOOK_ON

.EXTERN	LBEEP
.EXTERN	LINE_START

.EXTERN	LOCAL_PRO

.EXTERN	OGM_SELECT
.EXTERN	OGM_STATUS

.EXTERN	PUSH_FUNC

.EXTERN	REC_START
;.EXTERN REAL_DEL

.EXTERN	SEND_DAT
.EXTERN	SEND_MSGNUM
.EXTERN	SET_TIMER

.EXTERN	STOR_MSG
.EXTERN	STOR_VP

.EXTERN	VOL_TAB
.EXTERN	VPMSG_CHK
.EXTERN	VPMSG_DEL
.EXTERN	VPMSG_CHK
;---

.EXTERN	VP_DefOGM

;---
;-------------------------------------------------------------------------------
.LIST
;-------------------------------------------------------------------------------
.ORG	ADDR_SECOND
ANS_STATE:
	LAC	MSG
	XORL	CMSG_STOP		;接线按ON/OFF(相当于CPC)
	BS	ACZ,ANS_STATE_STOP
	LAC	MSG
	XORL	CVOL_INC		;VOL+++
	BS	ACZ,ANS_STATE_VOLA
	LAC	MSG
	XORL	CVOL_DEC		;VOL---
	BS	ACZ,ANS_STATE_VOLS

	LAC	MSG
	XORL	CHOOK_OFF
	BS	ACZ,ANS_STATE_PHONE	;摘机
	LAC	MSG
	XORL	CPHONE_ON
	BS	ACZ,ANS_STATE_PHONE	;免提

;-----
	LAC	PRO_VAR
	ANDK	0XF
	BS	ACZ,ANS_STATE0		;for initial
	SBHK	1
	BS	ACZ,ANS_STATE_REC	;for record(ANSWER AND RECORD ICM)
	SBHK	1
	BS	ACZ,ANS_STATE_LINE	;for line(ANSWER ONLY)
	SBHK	1
	BS	ACZ,ANS_STATE_EXIT	;for end(TimeOut/BTONE/CTONE/VOX_ON/CPC)

	RET
;---------------------------------------
ANS_STATE_STOP:
	LACL	CMSG_CPC
	SAH	MSG
	BS	B1,ANS_STATE	;excute immediately
ANS_STATE_PHONE:
	LAC	MSG
	CALL	STOR_MSG
	
	LACL	CMSG_CPC
	SAH	MSG
	BS	B1,ANS_STATE	;excute immediately
ANS_STATE_CPC:
	BS	B1,ICM_STATE_EXIT_END
;---------------------------------------
ANS_STATE_VOLS:
	LACL	CMSG_VOLS
	CALL	STOR_MSG
	
	RET

ANS_STATE_VOLA:
	LACL	CMSG_VOLA
	CALL	STOR_MSG
	
	RET
;-------------------------------------------------------------------------------
ANS_STATE0:
	LAC	MSG
	XORL	CMSG_INIT		;INITIAL
	BS	ACZ,ANS_STATE_INIT
;ANS_STATE0_1:	
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,ANS_STATE0_VPSTOP	;CVP_STOP,OGM播放完毕
;ANS_STATE0_2:
	LAC	MSG
	XORL	CREV_DTMF		;DTMF detect
	BS	ACZ,ANS_STATE0_DTMF
;ANS_STATE0_3:
	LAC	MSG
	XORL	CMSG_TMR		;TMR
	BS	ACZ,ANS_STATE0_TMR
;ANS_STATE0_4:	
	LAC	MSG
	XORL	CMSG_CPC		;接线后摘机(相当于CPC)
	BS	ACZ,ANS_STATE_CPC
;ANS_STATE0_5:

	RET
;---------------
ANS_STATE0_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	
	RET
;---------------
ANS_STATE_INIT:
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_SPK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	SEND_LINESEIZE
	;CALL	SEND_ANSPLYOGM
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	CALL	CLR_TIMER
	
	LACL	0X0FFF		;!!!Note PSWORD_TMP(15..12)是计数器
	SAH	PSWORD_TMP

	BIT	ANN_FG,13		;memoful?
	BS	TB,ANS_STATE_INIT4
	BIT	EVENT,9			;answer off?
	BS	TB,ANS_STATE_INIT2

;---可以录音---OGM1

	LACK	0X0010
	SAH	PRO_VAR

	CALL	OGM_STATUS

	LACK	0X07D
	CALL	STOR_VP			;延时1 second
	LAC	MSG_ID
	ORL	0XFE00
	CALL	STOR_VP
	CALL	LBEEP

	CALL	OGM_SELECT
	BZ	ACZ,ANS_STATE_INIT1_1
	
	CALL	INIT_DAM_FUNC
	LACK	0X07D
	CALL	STOR_VP			;延时1 second
	CALL	VP_DefOGM
	CALL	LBEEP

ANS_STATE_INIT1_1:
	RET
;---Answer off---
ANS_STATE_INIT2:

	LACK	0X0020
	SAH	PRO_VAR

	CALL	INIT_DAM_FUNC
	LACK	0X037
	CALL	STOR_VP		;延时300ms second
	
	;CALL	VP_AnswerOff
	;CALL	VP_YouCannotLeaveAMsg	;VP_YouCannotLeaveAMsg
	;LACL	0X00FA
	;CALL	STOR_VP		;延时2.0 second
	CALL	BBBEEP

	RET
;---------------------------------------
ANS_STATE_INIT4:		;full

	LACK	0X0020
	SAH	PRO_VAR

	CALL	INIT_DAM_FUNC
	LACK	0X03E
	CALL	STOR_VP		;延时0.5 second
	CALL	BBBEEP
	
	RET
;---------------------------------------
ANS_STATE0_VPSTOP:		;开始录音(ICM)/ON_LINE(only)
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_REC
	CALL	BCVOX_INIT

	LACK	0
	SAH	PRO_VAR1
	LACL	400
	CALL	SET_TIMER
;---	
	LAC	PRO_VAR
	SFR	4
	ANDK	0XF
	SBHK	1
	BS	ACZ,ANS_STATE0_VPSTOP1
	SBHK	1
	BS	ACZ,ANS_STATE0_VPSTOP2
	
	RET
;---PRO_VAR = 0X0010
ANS_STATE0_VPSTOP1:
	LACK	0X0001
	SAH	PRO_VAR
	
	CALL	VPMSG_CHK
	CALL	REC_START

	RET
ANS_STATE0_VPSTOP2:	
	LACK	0X0002
	SAH	PRO_VAR

	CALL	LINE_START
	
	RET
;---------------for DTMF
ANS_STATE0_DTMF:
	LAC	DTMF_VAL
	XORL	0XFE
	BZ	ACZ,ANS_STATE_DTMF
;---放OGM时,有"*"键按下
	LACK	0X0020
	SAH	PRO_VAR

	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_SPK

	LACK	0X040
	CALL	STOR_VP		;延时0.5 second

	RET

ANS_STATE_LINE_DTMF:		;Line Mode
	LACK	0
	SAH	PRO_VAR1	

ANS_STATE_DTMF:			;比较密码
	CALL	BCVOX_INIT	;有键按下BCVOX要清零

	LAC	DTMF_VAL
	ANDK	0X0F
	CALL	PSWORD_CHK
	BS	ACZ,ANS_STATE_DTMF_PASS	;次数到3,并且PASSWORD匹配成功

	RET
;---------------------------------------
ANS_STATE_DTMF_PASS:		;密码成功
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_REC

	LACL	CRMOT_OK
	CALL	STOR_MSG

	RET
;=============================================================
ANS_STATE_REC:
	LAC	MSG
	XORL	CREV_DTMF		;DTMF detect
	BS	ACZ,ANS_STATE_REC_DTMF
;ANS_STATE_REC_1:
	LAC	MSG
	XORL	CMSG_TMR		;TMR 400ms
	BS	ACZ,ANS_STATE_REC_TMR
;ANS_STATE_REC_2:
	LAC	MSG
	XORL	CMSG_VOX		;VOX_ON 7s
	BS	ACZ,ANS_STATE_REC_VOX
;ANS_STATE_REC_3:
	LAC	MSG
	XORL	CMSG_CTONE		;CTONE 7s
	BS	ACZ,ANS_STATE_REC_CTONE
;ANS_STATE_REC_4:
	LAC	MSG
	XORL	CMSG_BTONE		;BTONE xs
	BS	ACZ,ANS_STATE_REC_BTONE
;ANS_STATE_REC_5:
	LAC	MSG
	XORL	CREC_FULL		;REC_FULL
	BS	ACZ,ANS_STATE_REC_FULL
;ANS_STATE_REC_6:
	LAC	MSG
	XORL	CMSG_CPC		;接线后摘机(相当于CPC)
	BS	ACZ,ANS_STATE_REC_CPC
;ANS_STATE_REC_7:

	RET
	
;---------------------------------------
ANS_STATE_REC_DTMF:
	CALL	BCVOX_INIT	;有键按下BCVOX要清零

	LAC	DTMF_VAL
	ANDK	0X0F
	CALL	PSWORD_CHK
	BS	ACZ,ANS_STATE_REC_DTMF_PASS	;次数到3,并且PASSWORD匹配成功

	RET
ANS_STATE_REC_DTMF_PASS:
	LAC	CONF
	ORL	1<<11
	CALL	DAM_BIOSFUNC	;是录音过程,则删除之
	
	BS	B1,ANS_STATE_DTMF_PASS

;---------------------------------------
ANS_STATE_REC_CPC:		;录音时
	LAC	PRO_VAR1
	SBHK	2
	BZ	SGN,ANS_STATE_REC_CPC1
	
	LAC	CONF
	ORL	1<<11
	SAH	CONF
	CALL	DAM_BIOSFUNC
ANS_STATE_REC_CPC1:	
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LACK	0X005
	CALL	STOR_VP

	CALL	VPMSG_CHK
	
	LACK	0X0003
	SAH	PRO_VAR

	RET

;---------------------------------------
ANS_STATE_REC_VOX:		;由于后BTONE,CTONE,VOX要持续一段时间,要考虑小长度的录音删除问题
ANS_STATE_REC_CTONE:
	LAC	CONF
	ORK	17
	SAH	CONF		;切除静音/TONE声
ANS_STATE_REC_BTONE:
	CALL	INIT_DAM_FUNC
	CALL	VPMSG_CHK
	LAC	MSG_T
	CALL	GET_VPTLEN
	SBHK	3
	BZ	SGN,ANS_STATE_BTONE_DET
;---删除比3s短的录音
	LAC	MSG_T
	CALL	VPMSG_DEL
	CALL	GC_CHK
ANS_STATE_BTONE_DET:
	CALL	INIT_DAM_FUNC
	CALL	VPMSG_CHK
;---
	LACK	0X0003
	SAH	PRO_VAR
	
;	CALL	DAA_OFF
	CALL	DAA_SPK		;???????????????????
	CALL	BBEEP		;替换语音BB

	RET

;---------------------------------------
ANS_STATE_REC_TMR:
	LAC	PRO_VAR1	;400ms/1cnt
	ADHK	1
	SAH	PRO_VAR1

	LAC	PRO_VAR1
	SBHL	CICM_LEN		;ICM录音时长
	BZ	SGN,ICM_TMR_DET_END
;---	
	RET

ICM_TMR_DET_END:	
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_SPK
	CALL	BBEEP
	
	LACK	0X0003
	SAH	PRO_VAR

	RET
;-------
ANS_STATE_REC_FULL:		;录满退出
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_SPK
	;CALL	VP_MemoryFull
	
	CALL	BBEEP
	
	LACK	0X0003
	SAH	PRO_VAR
	
	RET

;========================================================================
ANS_STATE_LINE:		;off/full
	LAC	MSG
	XORL	CREV_DTMF		;DTMF detect
	BS	ACZ,ANS_STATE_LINE_DTMF
;ANS_STATE_LINE_1:
	LAC	MSG
	XORL	CMSG_TMR		;time 1s
	BS	ACZ,ANS_STATE_LINE_TMR
;ANS_STATE_LINE_2:
	LAC	MSG
	XORL	CMSG_BTONE		;BTONE 8s
	BS	ACZ,ANS_STATE_BTONE_DET
;ANS_STATE_LINE_3:
	LAC	MSG
	XORL	CMSG_CPC		;接线后摘机(相当于CPC)
	BS	ACZ,ANS_STATE_CPC
;ANS_STATE_LINE_4:
	RET
;---------------
ANS_STATE_LINE_TMR:		;for memful/answer only/answer off

	LACL	CTMR_CTONE
	SAH	TMR_VOX
	SAH	TMR_CTONE

	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	20*10/4		;20s wait for PASSWORD
	BZ	SGN,ANS_STATE_LINE_TMR_END
	
	RET
;---
ANS_STATE_LINE_TMR_END:	
	LACK	0X0003
	SAH	PRO_VAR
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_SPK
	CALL	BBEEP	;替换语音BB

	RET

;=================================================================
ANS_STATE_EXIT:
	LAC	MSG
	XORL	CVP_STOP		
	BS	ACZ,ICM_STATE_EXIT_END	;CVP_STOP,EXIT播放完毕
	
	RET
ICM_STATE_EXIT_END:		;exit answer mode
	CALL	INIT_DAM_FUNC
	CALL	HOOK_ON		;hook on
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	VPMSG_CHK
	CALL	SEND_MSGNUM
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	CLR_FUNC
   	LACL	LOCAL_PRO	;goto local mode
     	CALL	PUSH_FUNC
	
	LACL	CMODE9
	CALL	DAM_BIOSFUNC

	LACK	0
	SAH	PRO_VAR
	
	LACL	CMSG_INIT
	CALL	STOR_MSG

	RET
;-------------------------------------------------------------------------------
;       Function : PSWORD_CHK
;       Password check
;	Input  : ACCH = VALUE(DTMF_VAL)
;       Output : ACCH = 0 - password in ok
;                       0XFF - password fail
;-------------------------------------------------------------------------------
PSWORD_CHK:
        SAH	SYSTMP0
PSWORD_CHK1:
        LAC     PSWORD_TMP
        SFL     4
	OR	SYSTMP0
        SAH     PSWORD_TMP        ; PSWORD_TMP keep the new input digit string
;-------------------------------------------------------------------------------
        LAC     PSWORD_TMP
        SBH     PASSWORD
        ;ANDL	0X0FFF
        BS      ACZ,PSWORD_IN_OK
;---
PSWORD_NOT_IN:		;the intput not digital or wrong remote access code
        LACL    0XFF
        RET	
PSWORD_IN_OK:
	LACK	0
        RET
;-------------------------------------------------------------------------------
;       Function : SEND_LINESEIZE
;
;       Input  : no
;       Output : no
;-------------------------------------------------------------------------------
SEND_LINESEIZE:
	LACK	0X15
	CALL	SEND_DAT
	LACK	0X15
	CALL	SEND_DAT
	
	RET
;-------------------------------------------------------------------------------
;       Function : SEND_ANSPLYOGM
;
;       Input  : no
;       Output : no
;-------------------------------------------------------------------------------
SEND_ANSPLYOGM:
	LACK	0X17
	CALL	SEND_DAT
	LACK	0X17
	CALL	SEND_DAT
	
	RET
;-------------------------------------------------------------------------------
.END
