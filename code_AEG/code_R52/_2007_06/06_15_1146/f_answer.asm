;-------------------------------------------------------------------------------
.NOLIST
.INCLUDE	REG_D20.inc
.INCLUDE	MX93D20.inc
.INCLUDE	MACRO.inc
.INCLUDE	CONST.inc

.GLOBAL	ANS_STATE
;-------------------------------------------------------------------------------
.EXTERN	GetOneConst
.EXTERN	INIT_DAM_FUNC
.EXTERN	DAA_LIN_SPK
.EXTERN	DAA_LIN_REC
.EXTERN	DAA_ROM_MOR
.EXTERN	DAA_SPK
.EXTERN	DAA_OFF
.EXTERN	LBEEP
.EXTERN	LLBEEP
.EXTERN	BBBEEP
.EXTERN	BBEEP
.EXTERN	BEEP

.EXTERN	HOOK_ON
.EXTERN	HOOK_OFF

.EXTERN	PUSH_FUNC
.EXTERN	PAUBEEP
.EXTERN	CLR_FUNC

.EXTERN	STOR_MSG
.EXTERN	OGM_SELECT
.EXTERN	OGM_STATUS
.EXTERN	DGT_TAB
.EXTERN	SET_LED3
.EXTERN	SET_LED4
.EXTERN	STOR_VP
.EXTERN	LOCAL_PRO
.EXTERN	SET_TIMER
.EXTERN	CLR_TIMER
.EXTERN	REC_START
.EXTERN	LINE_START
.EXTERN	LED_HLDISP
.EXTERN	BCVOX_INIT
.EXTERN	FFW_MANAGE
.EXTERN	REW_MANAGE
.EXTERN	VPMSG_CHK
.EXTERN	CLR_FLAG
.EXTERN	SET_DELMARK
.EXTERN	DAM_BIOSFUNC
.EXTERN	VPMSG_DEL
.EXTERN	VOL_TAB
.EXTERN	GC_CHK
;-------------------------------------------------------------------------------
.LIST
;-------------------------------------------------------------------------------
.ORG	0x5400
ANS_STATE:
	LAC	MSG
	XORL	CMSG_CPC		;接线后摘机(相当于CPC)
	BS	ACZ,ANS_STATE_CPC
	LAC	MSG
	XORL	CMSG_KEY6S		;接线按ON/OFF(相当于CPC)
	BS	ACZ,ANS_STATE_CPC
	
	LAC	MSG
	XORL	CMSG_KEY7S		;VOL+++
	BS	ACZ,ANS_STATE_VOLA
	LAC	MSG
	XORL	CMSG_KEY8S		;VOL---
	BS	ACZ,ANS_STATE_VOLS
;-----
	LAC	PRO_VAR
	ANDK	0XF
	BS	ACZ,ANS_STATE0		;for initial
	SBHK	1
	BS	ACZ,ANS_STATE_REC	;for record(ANSWER AND RECORD ICM)
	SBHK	1
	BS	ACZ,ANS_STATE_LINE	;for line(ANSWER ONLY)
	SBHK	1
	BS	ACZ,ANS_STATE_EXIT	;for end(TimeOut/BTONE/CTONE/VOX_ON)

	RET
;---------------------------------------
ANS_STATE_CPC:
	BS	B1,ICM_STATE_EXIT_END

ANS_STATE_VOLS:
	LACL	CMSG_VOLS
	CALL	STOR_MSG
	
	RET

ANS_STATE_VOLA:
	LACL	CMSG_VOLA
	CALL	STOR_MSG
	
	RET	
;=============================================================
ANS_STATE0:
	LAC	MSG
	XORL	CMSG_INIT		;INITIAL
	BS	ACZ,ANS_STATE_INIT
;ANS_STATE0_1:	
	LAC	MSG
	XORL	CVP_STOP		
	BS	ACZ,ICM_STATE0_VPSTOP	;CVP_STOP,OGM播放完毕
;ANS_STATE0_2:
	LAC	MSG
	XORL	CREV_DTMF		;CREV_DTMF
	BS	ACZ,ANS_STATE_LINE_DTMF

	RET
;---
ANS_STATE_INIT:
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_SPK
	CALL	CLR_TIMER
	
	LACL	0XFFFF
	SAH	PSWORD_TMP
	
	BIT	EVENT,9		;answer off?
	BS	TB,ANS_STATE_INIT3
	BIT	ANN_FG,13	;memoful?
	BS	TB,ANS_STATE_INIT4
	BIT	EVENT,8		;answer only?
	BS	TB,ANS_STATE_INIT2

;---可以录音---OGM1
	LACL	0X8C88	;"PR"(PA)
	SAH	LED_L

	LACK	0X0010
	SAH	PRO_VAR

	CALL	OGM_STATUS

	LACK	0X07D
	CALL	STOR_VP		;延时1 second
	LAC	MSG_ID
	ORL	0XFE00
	CALL	STOR_VP
	CALL	LBEEP

	CALL	OGM_SELECT
	BZ	ACZ,ANS_STATE_INIT1
	
	CALL	INIT_DAM_FUNC
	LACK	0X07D
	CALL	STOR_VP		;延时1 second
	CALL	LBEEP

ANS_STATE_INIT1:
	RET
;---不能录音---OGM2
ANS_STATE_INIT2:
	LACL	0X8C88	;"PR"(PA)
	SAH	LED_L
	
	LACK	0X0020
	SAH	PRO_VAR

	CALL	OGM_STATUS

	LACK	0X07D
	CALL	STOR_VP		;延时1 second
	LAC	MSG_ID
	ORL	0XFE00
	CALL	STOR_VP
	CALL	BEEP

	CALL	OGM_STATUS
	BZ	ACZ,ANS_STATE_INIT2_1
	
	CALL	INIT_DAM_FUNC
	LACK	0X07D
	CALL	STOR_VP		;延时1 second
	CALL	BEEP
ANS_STATE_INIT2_1:	
	RET
;---------------------------------------
ANS_STATE_INIT3:		;off
	LACL	0XBFBF	;"--"(--)
	SAH	LED_L
	
	LACK	0X0020
	SAH	PRO_VAR

	CALL	OGM_STATUS

	LACK	0X07D
	CALL	STOR_VP		;延时1 second
	LAC	MSG_ID
	ORL	0XFE00
	CALL	STOR_VP
	CALL	LLBEEP

	CALL	OGM_STATUS
	BZ	ACZ,ANS_STATE_INIT3_1
	
	CALL	INIT_DAM_FUNC
	LACK	0X07D
	CALL	STOR_VP		;延时1 second
	CALL	LLBEEP		;3s
ANS_STATE_INIT3_1:
	
	
	RET
ANS_STATE_INIT4:		;full
	LACL	0X8C88	;"PR"(PA)
	SAH	LED_L
	
	LACK	0X0020
	SAH	PRO_VAR

	CALL	OGM_STATUS

	LACK	0X07D
	CALL	STOR_VP		;延时1 second
	LAC	MSG_ID
	ORL	0XFE00
	CALL	STOR_VP
	CALL	BEEP
	CALL	BEEP
	CALL	BEEP

	CALL	OGM_STATUS
	BZ	ACZ,ANS_STATE_INIT4_1
	
	CALL	INIT_DAM_FUNC
	LACK	0X07D
	CALL	STOR_VP		;延时1 second
	CALL	BEEP
	CALL	BEEP
	CALL	BEEP
ANS_STATE_INIT4_1:
	
	RET
;---------------------------------------
ICM_STATE0_VPSTOP:			;开始录音(ICM)/ON_LINE(only)
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_REC
	CALL	BCVOX_INIT

	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER
;---	
	LAC	PRO_VAR
	SFR	4
	ANDK	0XF
	SBHK	1
	BS	ACZ,ICM_STATE0_VPSTOP1
	SBHK	1
	BS	ACZ,ICM_STATE0_VPSTOP2
	
	RET
;---PRO_VAR = 0X0010
ICM_STATE0_VPSTOP1:

	LACK	0X0001
	SAH	PRO_VAR
	
	CALL	VPMSG_CHK
	CALL	REC_START

	RET
ICM_STATE0_VPSTOP2:
	
	LACK	0X0002
	SAH	PRO_VAR

	CALL	LINE_START
	
	RET
;---------------for DTMF
ANS_STATE_REC_DTMF:	;Record Mode
	LAC	DTMF_VAL
	XORL	0XFE
	BS	ACZ,ANS_STATE_REC_DTMF_STAR	;"*"
	
	BS	B1,ANS_STATE_DTMF
	
ANS_STATE_LINE_DTMF:	;Line Mode
	LACK	0
	SAH	PRO_VAR1	;有按键计时清零(仅ANS ONLY时)

ANS_STATE_DTMF:		;比较密码
	CALL	BCVOX_INIT	;有键按下BCVOX要清零
	
	LAC	DTMF_VAL
	ANDK	0X0F
	CALL	PSWORD_CHK
	BS	ACZ,ICM_REV_DTMF_PASS

	RET
;-------
ANS_STATE_REC_DTMF_STAR:	;刚进入答录时收到直截进入
	LAC	CONF
	SFR	12
	SBHK	1
	BZ	ACZ,ANS_STATE_REC_DTMF_STAR1
	
	LAC	CONF
	ORL	1<<11
	CALL	DAM_BIOSFUNC	;若是录音过程,则删除之
ANS_STATE_REC_DTMF_STAR1:	
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_REC
	CALL	BCVOX_INIT

	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER
	
	LACK	0X0002
	SAH	PRO_VAR

	CALL	LINE_START
	
	RET
;-------
ICM_REV_DTMF_PASS:		;密码成功
	LAC	CONF
	SFR	12
	SBHK	1
	BZ	ACZ,ICM_REV_DTMF_YES1

	LAC	CONF
	ORL	1<<11
	CALL	DAM_BIOSFUNC	;若是录音过程,则删除之
ICM_REV_DTMF_YES1:	
	LACL	0XC7AB	;"Ln"
	SAH	LED_L
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_REC

	CALL	CLR_FUNC	;先空
	LACL	REMOTE_PRO	;进入遥控
	CALL	PUSH_FUNC

	LACL	CMSG_INIT
	CALL	STOR_MSG
	
	LACK	0
	SAH	PRO_VAR		;程序步骤
	SAH	PRO_VAR1	;计时清零
	SAH	PSWORD_TMP	;功能字符清零
	CALL	BCVOX_INIT
	
	RET
;-------

;=============================================================
ANS_STATE_REC:
	LAC	MSG
	XORL	CREV_DTMF		;CREV_DTMF
	BS	ACZ,ANS_STATE_REC_DTMF
;ANS_STATE_REC_1:
	LAC	MSG
	XORL	CMSG_TMR		;time 1s
	BS	ACZ,ICM_TMR_DET
;ANS_STATE_REC_2:
	LAC	MSG
	XORL	CMSG_VOX		;VOX_ON 8s
	BS	ACZ,ICM_VOX_DET
;ANS_STATE_REC_3:
	LAC	MSG
	XORL	CMSG_CTONE		;CTONE 8s
	BS	ACZ,ICM_CTONE_DET
;ANS_STATE_REC_4:
	LAC	MSG
	XORL	CMSG_BTONE		;BTONE 8s
	BS	ACZ,ICM_BTONE_DET
;ANS_STATE_REC_5:
	LAC	MSG
	XORL	CREC_FULL		;REC_FULL
	BS	ACZ,ICM_REC_FUL
;ANS_STATE_REC_6:
	LAC	MSG
	XORL	CVP_STOP		;PLAY END
	BS	ACZ,ICM_FUL_EVP
	
	RET
;-------
ICM_VOX_DET:				;由于后BTONE,CTONE,VOX要持续一段时间,可不考虑小长度的录音删除问题
ICM_CTONE_DET:
ICM_BTONE_DET:
	CALL	INIT_DAM_FUNC
	CALL	VPMSG_CHK
;---
	LACK	0X0003
	SAH	PRO_VAR
	
;	CALL	DAA_OFF
	CALL	DAA_SPK		;???????????????????
	CALL	BBEEP		;替换语音BB

	RET

;---
ICM_TMR_DET:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	;CALL	LED_HLDISP	;Dug显示计时

	LAC	PRO_VAR1
	;SBHK	60			;ICM录音时长1分钟
	SBHK	CICM_LEN		;ICM录音时长
	BS	SGN,ICM_TMR_DET_END
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_SPK
	CALL	BBEEP
	
	LACK	0X0003
	SAH	PRO_VAR

ICM_TMR_DET_END:
	RET
;-------
ICM_REC_FUL:			;录满退出
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_SPK
	CALL	BBEEP
	
	LACK	0X0003
	SAH	PRO_VAR
	
	RET
ICM_FUL_EVP:
	LACK	0
	SAH	PRO_VAR1
	CALL	INIT_DAM_FUNC
	CALL	LINE_START
	
	RET
;=================================================================
ANS_STATE_EXIT:
	LAC	MSG
	XORL	CVP_STOP		
	BS	ACZ,ICM_STATE_EXIT_END	;CVP_STOP,EXIT播放完毕
	
	RET
ICM_STATE_EXIT_END:		;退出答录状态
	CALL	INIT_DAM_FUNC
	CALL	HOOK_OFF
	CALL	CLR_FUNC	;先空
   	LACL	LOCAL_PRO	;进入本地操作
     	CALL	PUSH_FUNC
	
	LACK	0
	SAH	PRO_VAR
	
	LACL	CMSG_INIT
	CALL	STOR_MSG

	RET
;========================================================================
ANS_STATE_LINE:
	LAC	MSG
	XORL	CREV_DTMF		;CREV_DTMF
	BS	ACZ,ANS_STATE_LINE_DTMF
;ANS_STATE_LINE_1:
	LAC	MSG
	XORL	CMSG_TMR		;time 1s
	BS	ACZ,LINE_TMR_DET
;ANS_STATE_LINE_2:
	LAC	MSG
	XORL	CMSG_VOX		;VOX_ON 8s
	BS	ACZ,ICM_VOX_DET
;ANS_STATE_LINE_3:
	LAC	MSG
	XORL	CMSG_CTONE		;CTONE 8s
	BS	ACZ,ICM_CTONE_DET
;ANS_STATE_LINE_4:
	LAC	MSG
	XORL	CMSG_BTONE		;BTONE 8s
	BS	ACZ,ICM_BTONE_DET

	RET
;-------
LINE_TMR_DET:		;for memful/answer only/answer off
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	8
	BS	SGN,LINE_TMR_DET_END

	LACK	0X0003
	SAH	PRO_VAR
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_SPK
	CALL	BBEEP	;替换语音BB

LINE_TMR_DET_END:
	RET
;-------------------------------------------------------------------------------
;###############################################################################
;----------------------------------------------------------------------------
;       Function : PSWORD_CHK
;       Password check
;	Input  : ACCH = VALUE(DTMF_VAL)
;       Output : ACCH = 0 - password in ok
;                       1 - password for mailbox 1
;                       2 - password for mailbox 2
;                       3 - password for mailbox 3
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
        ANDL	0X0FFF
        BS      ACZ,PSWORD_IN_OK
;---
PSWORD_NOT_IN:		;the intput not digital or wrong remote access code
        LACL    0XFF
        RET	
PSWORD_IN_OK:
	LACK	0
        RET
;----------------------------------------------------------------------------
;       Function : RMTFUNC_CHK
;       Password check
;	Input  : ACCH = VALUE(DTMF_VAL)
;       Output : ACCH = 0 - password in ok
;                       1 - password for mailbox 1
;                       2 - password for mailbox 2
;                       3 - password for mailbox 3
;                       0XFF - password fail
;-------------------------------------------------------------------------------
RMTFUNC_CHK:
        SAH	SYSTMP0
;RMTFUNC_CHK1:
        LAC     PSWORD_TMP
        SFL	8
	OR	SYSTMP0
        SAH     PSWORD_TMP	;PSWORD_TMP keep the new input digit string
        
        LAC     PSWORD_TMP
	SAH     SYSTMP0
	
	LACK	0
	SAH	PSWORD_TMP
;-------------------------------------------------------------------------------
	LAC     SYSTMP0
        XORL	0XF0FF		;"0","F"
        BS      ACZ,RMTFUNC_0_F_OK
        LAC     SYSTMP0
        XORL	0XF2F5		;"2","5"
        BS      ACZ,RMTFUNC_2_5_OK
        LAC     SYSTMP0
        XORL	0XF2FF		;"2","#"
        BS      ACZ,RMTFUNC_2_POU_OK
        LAC     SYSTMP0
        XORL	0XF3FF		;"3","#"
        BS      ACZ,RMTFUNC_3_POU_OK
        LAC     SYSTMP0
        XORL	0XF5FF		;"5","#"
        BS      ACZ,RMTFUNC_5_POU_OK
        LAC     SYSTMP0
        XORL	0XF6FF		;"6","#"
        BS      ACZ,RMTFUNC_6_POU_OK
        LAC     SYSTMP0
        XORL	0XF7FF		;"7","#"
        BS      ACZ,RMTFUNC_7_POU_OK
        LAC     SYSTMP0
        XORL	0XF8FF		;"8","#"
        BS      ACZ,RMTFUNC_8_POU_OK
        LAC     SYSTMP0
        XORL	0XF9FF		;"9","#"
        BS      ACZ,RMTFUNC_9_POU_OK
        LAC     SYSTMP0
        XORL	0XFEFF		;"*","#"
        BS      ACZ,RMTFUNC_AST_POU_OK
        LAC     SYSTMP0
        XORL	0XFFFF		;"#","#"
        BS      ACZ,RMTFUNC_POU_POU_OK
;---
RMTFUNC_NOT_IN:		;the intput not digital or wrong remote access code
	LAC     SYSTMP0
	SAH     PSWORD_TMP
	
        LACL    0XFF
        RET	
RMTFUNC_INDMONITOR_OK:
RMTFUNC_0_F_OK:
	LACK	0

        RET
RMTFUNC_2_5_OK:

	LACK	1
        RET
RMTFUNC_2_POU_OK:
	LACK	2
	RET
RMTFUNC_3_POU_OK:
	LACK	3
	RET
RMTFUNC_5_POU_OK:
	LACK	5
	RET
RMTFUNC_6_POU_OK:
	
	LACK	6
	RET
RMTFUNC_7_POU_OK:

	LACK	7
	RET
RMTFUNC_8_POU_OK:

	LACK	8
	RET
RMTFUNC_9_POU_OK:

	LACK	9
	RET
RMTFUNC_AST_POU_OK:
	
	LACK	0XE
	RET
RMTFUNC_POU_POU_OK:

	LACK	0XF
	RET
;---------------------------------------
DAA_ANS_SPK:	;(SW1)&(SW3)&(SW7) ==> (LIN->ADC)&(DAC->SPK)&(DAC->LOUT)
	LIPK    6
        OUTL    ((1<<1)|(1<<3)|(1<<7)),SWITCH
        NOP
;---
	LAC	VOI_ATT
	ANDK	0X07
	ADHL	VOL_TAB
	CALL	GetOneConst
	ORL	(0X1A<<5)	;Lout gain
	SAH	CODECREG2
	OUT	CODECREG2,LOUTSPK
	ADHK	0
	
	RET
;---------------------------------------
DAA_ANS_REC:	;(SW1)&(SW7) ==> (LIN->ADC)&(DAC->SPK)
;---
	LIPK    6
        OUTL    0x0082,SWITCH
        OUTL    ((1<<1)|(1<<7)),SWITCH
	NOP
;---
	IN	SYSTMP0,AGC
	LAC	SYSTMP0
	ANDL	0xF00F
	ORL	0X0997
	SAH	SYSTMP0
	OUT     SYSTMP0,AGC
	ADHK	0
;---
	LAC	VOI_ATT
	ANDK	0X07
	ADHL	VOL_TAB
	CALL	GetOneConst

	ORL	(0X1A<<5)	;Lout gain
	SAH	CODECREG2
	OUT	CODECREG2,LOUTSPK
	ADHK	0
	
	RET
;-------------------------------------------------------------------------------
.INCLUDE	f_remote.ASM
;-------------------------------------------------------------------------------
.END
