.NOLIST
.INCLUDE	REG_D20.inc
.INCLUDE	MX93D20.inc
.INCLUDE	MACRO.inc
.INCLUDE	CONST.inc

.GLOBAL	LOCAL_PROMNU
;-------------------------------------------------------------------------------
.EXTERN	ANNOUNCE_NUM

.EXTERN	BBBEEP
.EXTERN	BBEEP
.EXTERN	BEEP
.EXTERN	BCVOX_INIT

.EXTERN CMIN_GET
.EXTERN CHOUR_GET
.EXTERN CWEEK_GET
.EXTERN	CLR_FLAG
.EXTERN	CLR_FUNC
.EXTERN	CLR_TIMER
.EXTERN CURR_MIN
.EXTERN CURR_HOUR
.EXTERN CURR_WEEK

;.EXTERN	DAA_LIN_SPK
;.EXTERN	DAA_LIN_REC
;.EXTERN	DAA_ROM_MOR
.EXTERN	DAA_SPK
.EXTERN	DAA_REC
.EXTERN	DAA_OFF
.EXTERN	DAM_BIOSFUNC
.EXTERN	DAT_WRITE_STOP
.EXTERN	DEL_ONETEL
.EXTERN	DGT_TAB

.EXTERN	FFW_MANAGE

.EXTERN	HOOK_ON
.EXTERN	HOOK_OFF
.EXTERN HOUR_SET

.EXTERN	GC_CHK
.EXTERN	GetOneConst
.EXTERN	GET_SEGCODE
.EXTERN	INIT_DAM_FUNC

.EXTERN	LBEEP
.EXTERN	LED_HLDISP
.EXTERN	LINE_START
.EXTERN	LOCAL_PRO

.EXTERN MIN_SET
.EXTERN	OGM_SELECT
.EXTERN	PUSH_FUNC

.EXTERN	REAL_DEL
.EXTERN	REC_START
.EXTERN	REW_MANAGE

.EXTERN SEC_SET
.EXTERN	SET_DELMARK
.EXTERN	SET_LED3
.EXTERN	SET_LED4
.EXTERN	SET_TIMER
.EXTERN	STORBYTE_DAT
.EXTERN	STOR_MSG
.EXTERN	STOR_VP

.EXTERN	TEL_GC_CHK
.EXTERN	TELNUM_WRITE

.EXTERN	VALUE_SUB
.EXTERN	VALUE_ADD
.EXTERN	VPMSG_CHK
.EXTERN	VPMSG_DEL

.EXTERN WEEK_SET

.LIST
;-------------------------------------------------------------------------------
.ORG	0x5500
;-------------------------------------------------------------------------------
LOCAL_PROMNU:				;MENU设置状态要考虑的消息(PRO_VAR)
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,MAIN_PROX_RINGIN

	LAC	MSG
	XORL	CMSG_KEY6S
	BS	ACZ,MAIN_PRO9_X_STOP	;STOP
	LAC	MSG
	XORL	CMSG_EXIT
	BS	ACZ,MAIN_PRO9_X_STOP	;STOP

	LAC	PRO_VAR
	SFR	4
	ANDK	0X0F
	BS	ACZ,LOCAL_PROMNU_0		;(0Xyy04)wait for key release
	SBHK	1
	BS	ACZ,LOCAL_PROMNU_PSWORD		;(0Xyy14)psword set
	SBHK	1
	BS	ACZ,LOCAL_PROMNU_TIME		;(0Xyy24)time set
	
	RET
;-------common respond
MAIN_PROX_RINGIN:
	CALL	INIT_DAM_FUNC
	LACK	0
	SAH	PRO_VAR

	LACL	CMSG_INIT
	CALL	STOR_MSG
	
	RET

LOCAL_PROMNU_VPSTOP:

	LACK	0
	SAH	PRO_VAR1		;计数器清零(按键松开后BEEP结束)	
	CALL	DAA_OFF

	RET
MAIN_PRO9_X_STOP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BBEEP		;BB

	LACK	0X0
	SAH	PRO_VAR
	
	RET

LOCAL_PROMNU_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	30
	BZ	SGN,MAIN_PRO9_TMROVER
	
	RET
MAIN_PRO9_TMROVER:		;超时退出
	BS	B1,MAIN_PRO9_X_STOP
;-------------------------------------------------------------------------------
LOCAL_PROMNU_0:				;wait for key released

	RET
;-------------------------------------------------------------------------------
LOCAL_PROMNU_PSWORD:
	LAC	PRO_VAR
	SFR	8
	ANDK	0X0F
	BS	ACZ,LOCAL_PROMNU_PSWORD_0	;wait
	SBHK	1
	BS	ACZ,LOCAL_PROMNU_PSWORD_1	;adjust ps1
	SBHK	1
	BS	ACZ,LOCAL_PROMNU_PSWORD_2	;adjust ps2
	SBHK	1
	BS	ACZ,LOCAL_PROMNU_PSWORD_3	;adjust ps3
	SBHK	1
	BS	ACZ,LOCAL_PROMNU_PSWORD_DISP	;Display

	RET

LOCAL_PROMNU_PSWORD_0:
	LAC	MSG
	XORL	CMSG_KEY2S		;Announce time
	BS	ACZ,LOCAL_PROMNU_PSWORD_0_TIME
	
	RET
LOCAL_PROMNU_PSWORD_0_TIME:	
	LACL	0X0114
	SAH	PRO_VAR

	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER		;打开定时,按键清零,超时退出	

	RET
;-----------------------------------------------------------
LOCAL_PROMNU_PSWORD_1:
	
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PROMNU_TMR	;TMR
	
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROMNU_VPSTOP	;VP end
;LOCAL_PROMNU_PSWORD_1_1:		
	LAC	MSG
	XORL	CMSG_KEY5S
	BS	ACZ,MAIN_PRO9_1_X_REW	;REW(DEC)
;LOCAL_PROMNU_PSWORD_1_2:	
	LAC	MSG
	XORL	CMSG_KEY2S
	BS	ACZ,MAIN_PRO9_1_X_FFW	;FFW(INC)
;LOCAL_PROMNU_PSWORD_1_3:	
	LAC	MSG
	XORL	CMSG_KEY5P
	BS	ACZ,MAIN_PRO9_1_X_PREW	;REW
;LOCAL_PROMNU_PSWORD_1_4:	
	LAC	MSG
	XORL	CMSG_KEY2P
	BS	ACZ,MAIN_PRO9_1_X_PFFW	;FFW
;LOCAL_PROMNU_PSWORD_1_5:
	LAC	MSG
	XORL	CMSG_KEY1S
	BS	ACZ,LOCAL_PROMNU_PSWORD_1_PLAY	;PLAY	

	RET

LOCAL_PROMNU_PSWORD_1_PLAY:
	LAC	PASSWORD
	ANDL	0XF0FF
	SAH	PASSWORD

	LACL	0XB700
	SAH	MSG_ID		;中下线

	LAC	MSG_N
	SFL	8
	ANDL	0X0F00
	OR	PASSWORD
	SAH	PASSWORD
;---	
	LACK	0
	SAH	COUNT
	LAC	PASSWORD
	SFR	8
	ANDK	0X0F
	CALL	STORBYTE_DAT
	LACK	8
	SAH	COUNT
	LACL	0XFF
	CALL	STORBYTE_DAT	;以0XFF结尾

	LACK	1
	CALL	DEL_ONETEL
	CALL	TEL_GC_CHK
	CALL	GC_CHK
	
	LACK	0
	SAH	COUNT
	CALL	TELNUM_WRITE	;写入数据
	CALL	DAT_WRITE_STOP
;---
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP		;BEEP
	
	LACL	0X0214
	SAH	PRO_VAR

	LAC	PASSWORD
	SFR	4
	ANDK	0X0F
	SAH	MSG_N		;LOAD CURRENT VALUE(ps2)
	CALL	LED_HLDISP

	LAC	LED_L		;识别码
	ANDL	0X00FF
	OR	MSG_ID
	SAH	LED_L

	RET

MAIN_PRO9_1_X_REW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
MAIN_PRO9_1_X_PREW:
	LAC	NEW1
	SAH	SYSTMP1
	LAC	NEW2
	SAH	SYSTMP2

	LAC	MSG_N
	CALL	VALUE_SUB
	SAH	MSG_N
	CALL	LED_HLDISP
	
	LAC	LED_L
	ANDL	0X00FF
	OR	MSG_ID
	SAH	LED_L
	
	RET
;---
MAIN_PRO9_1_X_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
MAIN_PRO9_1_X_PFFW:
	LAC	NEW1
	SAH	SYSTMP1
	LAC	NEW2
	SAH	SYSTMP2

	LAC	MSG_N
	CALL	VALUE_ADD
	SAH	MSG_N
	CALL	LED_HLDISP

	LAC	LED_L
	ANDL	0X00FF
	OR	MSG_ID
	SAH	LED_L

	RET

;-----------------------------------------------------------
LOCAL_PROMNU_PSWORD_2:
	
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PROMNU_TMR	;TMR
	
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROMNU_VPSTOP	;VP end

;MAIN_PRO9_1_2_1:		
	LAC	MSG
	XORL	CMSG_KEY5S
	BS	ACZ,MAIN_PRO9_1_X_REW	;REW
;MAIN_PRO9_1_2_2:	
	LAC	MSG
	XORL	CMSG_KEY2S
	BS	ACZ,MAIN_PRO9_1_X_FFW	;FFW
;MAIN_PRO9_1_2_3:	
	LAC	MSG
	XORL	CMSG_KEY5P
	BS	ACZ,MAIN_PRO9_1_X_PREW	;REW
;MAIN_PRO9_1_2_4:	
	LAC	MSG
	XORL	CMSG_KEY2P
	BS	ACZ,MAIN_PRO9_1_X_PFFW	;FFW
;MAIN_PRO9_1_2_5:
	LAC	MSG
	XORL	CMSG_KEY1S
	BS	ACZ,MAIN_PRO9_1_2_PLAY	;PLAY

	RET

MAIN_PRO9_1_2_PLAY:
	LAC	PASSWORD
	ANDL	0XFF0F
	SAH	PASSWORD

	LACL	0XB600
	SAH	MSG_ID


	LAC	MSG_N
	SFL	4
	ANDL	0X00F0
	OR	PASSWORD
	SAH	PASSWORD
;---
	LACK	1
	SAH	COUNT
	LAC	PASSWORD
	SFR	4
	ANDK	0X0F
	CALL	STORBYTE_DAT
	LACK	8
	SAH	COUNT
	LACL	0XFF
	CALL	STORBYTE_DAT	;以0XFF结尾

	LACK	1
	CALL	DEL_ONETEL
	CALL	TEL_GC_CHK
	CALL	GC_CHK
	
	LACK	0
	SAH	COUNT
	CALL	TELNUM_WRITE	;写入数据
	CALL	DAT_WRITE_STOP
;---保存完毕
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP		;BEEP
	
	LACL	0X0314
	SAH	PRO_VAR

	LAC	PASSWORD
	ANDK	0X0F
	SAH	MSG_N		;LOAD CURRENT VALUE(ps3)
	CALL	LED_HLDISP

	LAC	LED_L		;识别码
	ANDL	0X00FF
	OR	MSG_ID
	SAH	LED_L

	RET
;-------------------------------------------------------------------------------
LOCAL_PROMNU_PSWORD_3:
	
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PROMNU_TMR	;TMR
	
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROMNU_VPSTOP	;VP end

;LOCAL_PROMNU_PSWORD_3_1:		
	LAC	MSG
	XORL	CMSG_KEY5S
	BS	ACZ,MAIN_PRO9_1_X_REW	;REW
;LOCAL_PROMNU_PSWORD_3_2:	
	LAC	MSG
	XORL	CMSG_KEY2S
	BS	ACZ,MAIN_PRO9_1_X_FFW	;FFW
;LOCAL_PROMNU_PSWORD_3_3:	
	LAC	MSG
	XORL	CMSG_KEY5P
	BS	ACZ,MAIN_PRO9_1_X_PREW	;REW
;LOCAL_PROMNU_PSWORD_3_4:	
	LAC	MSG
	XORL	CMSG_KEY2P
	BS	ACZ,MAIN_PRO9_1_X_PFFW	;FFW
;LOCAL_PROMNU_PSWORD_3_5:
	LAC	MSG
	XORL	CMSG_KEY1S
	BS	ACZ,MAIN_PRO9_1_3_PLAY	;PLAY

	RET

MAIN_PRO9_1_3_PLAY:
	LAC	PASSWORD
	ANDL	0XFFF0
	SAH	PASSWORD

	LAC	MSG_N
	ANDK	0X00F
	OR	PASSWORD
	SAH	PASSWORD
;---
	LACK	2
	SAH	COUNT
	LAC	PASSWORD
	SFR	4
	ANDK	0X0F
	CALL	STORBYTE_DAT
	LACK	8
	SAH	COUNT
	LACL	0XFF
	CALL	STORBYTE_DAT	;以0XFF结尾

	LACK	1
	CALL	DEL_ONETEL
	CALL	TEL_GC_CHK
	CALL	GC_CHK
	
	LACK	0
	SAH	COUNT
	CALL	TELNUM_WRITE	;写入数据
	CALL	DAT_WRITE_STOP
;---
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP		;BEEP

	LACL	0X0414
	SAH	PRO_VAR

	RET
;-------------------------------------------------------------------------------
LOCAL_PROMNU_PSWORD_DISP:
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PROMNU_PSWORD_DISP_TMR	;TMR
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROMNU_VPSTOP			;VP end

	RET
	
LOCAL_PROMNU_PSWORD_DISP_TMR:	
	LAC	PRO_VAR
	SFR	12
	ANDK	0X0F
	BS	ACZ,LOCAL_PROMNU_PSWORD0_DISP	;0X0414
	SBHK	1
	BS	ACZ,LOCAL_PROMNU_PSWORD1_DISP	;0X1414
	SBHK	1
	BS	ACZ,LOCAL_PROMNU_PSWORD2_DISP	;0X2414
	SBHK	1
	BS	ACZ,LOCAL_PROMNU_PSWORD3_DISP	;0X3414
	
	RET
LOCAL_PROMNU_PSWORD0_DISP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	
	LACL	0X1414
	SAH	PRO_VAR
	
	LAC	PASSWORD
	SFR	8
	ANDK	0X0F		;LOAD CURRENT VALUE(ps1)
	CALL	LED_HLDISP
	
	LAC	LED_L
	ANDL	0X00FF
	ORL	0XF700		;高位显示"下划线"
	SAH	LED_L
	
	RET
LOCAL_PROMNU_PSWORD1_DISP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	
	LACL	0X2414
	SAH	PRO_VAR
	
	LAC	PASSWORD
	SFR	4
	ANDK	0X0F		;LOAD CURRENT VALUE(ps2)
	CALL	LED_HLDISP

	LAC	LED_L
	ANDL	0X00FF
	ORL	0XB700		;高位显示"下中划线"
	SAH	LED_L

	RET
LOCAL_PROMNU_PSWORD2_DISP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	
	LACL	0X3414
	SAH	PRO_VAR
	
	LAC	PASSWORD
	ANDK	0X0F		;LOAD CURRENT VALUE(ps3)
	CALL	LED_HLDISP
	
	LAC	LED_L
	ANDL	0X00FF
	ORL	0XB600		;高位显示"下中上划线"
	SAH	LED_L
	
	RET
LOCAL_PROMNU_PSWORD3_DISP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BBEEP
	
	LACK	0X0
	SAH	PRO_VAR
	
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROMNU_TIME:			;adjust time

	LAC	PRO_VAR
	SFR	8
	ANDK	0X0F
	BS	ACZ,MAIN_PRO9_2_0	;wait
	SBHK	1
	BS	ACZ,MAIN_PRO9_2_1	;week
	SBHK	1
	BS	ACZ,MAIN_PRO9_2_2	;hour
	SBHK	1
	BS	ACZ,MAIN_PRO9_2_3	;minute


	RET
;-------------------------------------------------------------------------------
MAIN_PRO9_2_0:
	LACL	0X0125
	SAH	PRO_VAR

	LAC	MSG
	CALL	STOR_MSG
	
	RET
;-------------------------------------------------------------------------------
MAIN_PRO9_2_1:			;adjust week
;MAIN_PRO9_2_1_0:
	
;MAIN_PRO9_2_1_1:		
	LAC	MSG
	XORL	CMSG_KEY5S
	BS	ACZ,MAIN_PRO9_2_X_REW	;OGM = REW
;MAIN_PRO9_2_1_2:	
	LAC	MSG
	XORL	CMSG_KEY2S
	BS	ACZ,MAIN_PRO9_2_X_FFW	;TIME = FFW
;MAIN_PRO9_2_1_3:	
	LAC	MSG
	XORL	CMSG_KEY5P
	BS	ACZ,MAIN_PRO9_2_X_PREW	;OGM = REW
;MAIN_PRO9_2_1_4:	
	LAC	MSG
	XORL	CMSG_KEY2P
	BS	ACZ,MAIN_PRO9_2_X_PFFW	;TIME = FFW
;MAIN_PRO9_2_1_5:
	LAC	MSG
	XORL	CMSG_KEY1S
	BS	ACZ,MAIN_PRO9_2_1_PLAY	;PLAY = CONFIRM
	
	RET
;-------respond9-2-x(week/hour/minute)
MAIN_PRO9_2_X_REW:	
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP		;BEEP
MAIN_PRO9_2_X_PREW:
	LAC	NEW1
	SAH	SYSTMP1
	LAC	NEW2
	SAH	SYSTMP2

	LAC	MSG_N
	CALL	VALUE_SUB
	SAH	MSG_N
	CALL	LED_HLDISP

	RET
MAIN_PRO9_2_X_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP		;BEEP
MAIN_PRO9_2_X_PFFW:
	LAC	NEW1
	SAH	SYSTMP1
	LAC	NEW2
	SAH	SYSTMP2

	LAC	MSG_N
	CALL	VALUE_ADD
	SAH	MSG_N
	CALL	LED_HLDISP
	
	RET

MAIN_PRO9_2_1_PLAY:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP		;BEEP
	
	LAC	MSG_N
	;SAH	TMR_WEEK
	CALL	WEEK_SET
	
	LACL	0X0225
	SAH	PRO_VAR
;---载入调节项	
	;LAC	TMR_HOUR
	CALL	CHOUR_GET
	SAH	MSG_N		;CURRENT VALUE
	CALL	LED_HLDISP
	
	LACK	0
	SAH	NEW1		;MIN VALUE
	LACK	23
	SAH	NEW2		;MAX VALUE

	RET
;-------------------------------------------------------------------------------
MAIN_PRO9_2_2:
		
;MAIN_PRO9_2_2_1:		
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,MAIN_PRO9_2_X_REW	;REW
;MAIN_PRO9_2_2_2:	
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO9_2_X_FFW	;FFW
;MAIN_PRO9_2_2_3:	
	LAC	MSG
	XORL	CMSG_KEY8P
	BS	ACZ,MAIN_PRO9_2_X_PREW	;REW
;MAIN_PRO9_2_2_4:	
	LAC	MSG
	XORL	CMSG_KEYCP
	BS	ACZ,MAIN_PRO9_2_X_PFFW	;FFW
;MAIN_PRO9_2_2_5:
	LAC	MSG
	XORL	CMSG_KEY2S
	BS	ACZ,MAIN_PRO9_2_2_TIME	;TIME
	
	RET
MAIN_PRO9_2_2_TIME:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP		;BEEP
	
	LAC	MSG_N
	;SAH	TMR_HOUR
	CALL	HOUR_SET
	
	LACL	0X0325
	SAH	PRO_VAR
;---载入调节项	
	;LAC	TMR_MIN
	CALL	CMIN_GET
	SAH	MSG_N		;CURRENT VALUE
	CALL	LED_HLDISP
	
	LACK	0
	SAH	NEW1		;MIN VALUE
	LACK	59
	SAH	NEW2		;MAX VALUE

	RET
;-------------------------------------------------------------------------------
MAIN_PRO9_2_3:
			
;MAIN_PRO9_2_3_1:		
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,MAIN_PRO9_2_X_REW	;REW
;MAIN_PRO9_2_3_2:	
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO9_2_X_FFW	;FFW
;MAIN_PRO9_2_3_3:	
	LAC	MSG
	XORL	CMSG_KEY8P
	BS	ACZ,MAIN_PRO9_2_X_PREW	;REW
;MAIN_PRO9_2_3_4:	
	LAC	MSG
	XORL	CMSG_KEYCP
	BS	ACZ,MAIN_PRO9_2_X_PFFW	;FFW
;MAIN_PRO9_2_3_5:
	LAC	MSG
	XORL	CMSG_KEY2S
	BS	ACZ,MAIN_PRO9_2_3_TIME	;TIME

	RET
MAIN_PRO9_2_3_TIME:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK

	LAC	MSG_N
	CALL	MIN_SET
	LACK	0
	CALL	SEC_SET
	
	CALL	CURR_WEEK
	CALL	CURR_HOUR
	CALL	CURR_MIN
	
	LACL	0X010
	SAH	PRO_VAR
	
	RET

;===============================================================================
	
.END

