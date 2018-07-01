.NOLIST
.INCLUDE	REG_D22.inc
.INCLUDE	MX93D22.inc
.INCLUDE	MACRO.inc
.INCLUDE	CONST.inc

.GLOBAL	LOCAL_PROMNU
;-------------------------------------------------------------------------------
.EXTERN	ANNOUNCE_NUM
;---
.EXTERN	BBBEEP
.EXTERN	BBEEP
.EXTERN	BEEP
.EXTERN	BCVOX_INIT
;---
.EXTERN CMIN_GET
.EXTERN CHOUR_GET
.EXTERN CWEEK_GET
.EXTERN	CLR_FLAG
.EXTERN	CLR_FUNC
.EXTERN	CLR_TIMER
.EXTERN CURR_MIN
.EXTERN CURR_HOUR
.EXTERN CURR_WEEK
;---
.EXTERN	DAA_SPK
.EXTERN	DAA_REC
.EXTERN	DAA_OFF
.EXTERN	DAM_BIOSFUNC
.EXTERN	DAT_WRITE_STOP
.EXTERN	DEL_ONETEL
.EXTERN	DGT_TAB
;---
.EXTERN	FFW_MANAGE
;---
.EXTERN	GC_CHK
.EXTERN	GetOneConst
.EXTERN	GET_SEGCODE
;---
.EXTERN	HOOK_ON
.EXTERN	HOOK_OFF
.EXTERN HOUR_SET
;---
.EXTERN	INIT_DAM_FUNC
;---
.EXTERN	LBEEP
.EXTERN	LED_HLDISP
.EXTERN	LED3_DISP
.EXTERN	LED4_DISP
.EXTERN	LINE_START
.EXTERN	LOCAL_PRO
;---
.EXTERN MIN_SET
.EXTERN	OGM_SELECT
.EXTERN	PUSH_FUNC
;---
.EXTERN	REAL_DEL
.EXTERN	REC_START
.EXTERN	REW_MANAGE
.EXTERN	RATE_TAB
;---
.EXTERN SEC_SET
.EXTERN	SET_DELMARK
.EXTERN	SET_LED1
.EXTERN	SET_LED2
.EXTERN	SET_LED3
.EXTERN	SET_LED4
.EXTERN	SET_TIMER
.EXTERN	STORBYTE_DAT
.EXTERN	STOR_MSG
.EXTERN	STOR_VP
;---
.EXTERN	TEL_GC_CHK
.EXTERN	TELNUM_WRITE
;---
.EXTERN	VALUE_SUB
.EXTERN	VALUE_ADD
.EXTERN	VP_Hour
.EXTERN	VP_Minute
.EXTERN	VPMSG_CHK
.EXTERN	VPMSG_DEL
.EXTERN	VP_SecurityCode
.EXTERN VP_Set
.EXTERN	VPWEEK
;---
.EXTERN WEEK_SET
;---
.LIST
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
LOCAL_PROMNU:				;MENU����״̬Ҫ���ǵ���Ϣ(PRO_VAR)
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,LOCAL_PROX_RINGIN

	LAC	MSG
	XORL	CMSG_KEY5S
	BS	ACZ,LOCAL_PROMNU_X_STOP	;STOP
	LAC	MSG
	XORL	CMSG_EXIT
	BS	ACZ,LOCAL_PROMNU_X_STOP	;STOP

	LAC	PRO_VAR
	SFR	4
	ANDK	0X0F
	BS	ACZ,LOCAL_PROMNU_0		;(0Xyy04)wait for key release
	SBHK	1
	BS	ACZ,LOCAL_PROMNU_PSWORD		;(0Xyy14)psword set
	SBHK	1
	BS	ACZ,LOCAL_PROMNU_TIME		;(0Xyy24)time set
	SBHK	1
	BS	ACZ,LOCAL_PROMNU_RATE		;(0Xyy34)rate set
	SBHK	1
	BS	ACZ,LOCAL_PROMNU_RING		;(0Xyy44)ring set
	SBHK	1
	BS	ACZ,LOCAL_PROMNU_OGM		;(0Xyy54)OGM select
	
	RET
;-------common respond
LOCAL_PROX_RINGIN:
	CALL	INIT_DAM_FUNC
	LACK	0
	SAH	PRO_VAR

	LACL	CMSG_INIT
	CALL	STOR_MSG
	
	RET

LOCAL_PROMNU_VPSTOP:

	LACK	0
	SAH	PRO_VAR1		;����������(�����ɿ���BEEP����)	
	CALL	DAA_OFF

	RET
LOCAL_PROMNU_X_STOP:

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
MAIN_PRO9_TMROVER:		;��ʱ�˳�
	BS	B1,LOCAL_PROMNU_X_STOP
;-------------------------------------------------------------------------------
LOCAL_PROMNU_0:				;wait for key released

	RET
;-------------------------------------------------------------------------------
LOCAL_PROMNU_PSWORD:		;(0Xyy14)psword set
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
	XORL	CMSG_KEYES		;Announce time
	BS	ACZ,LOCAL_PROMNU_PSWORD_0_CODE
	
	RET

LOCAL_PROMNU_PSWORD_0_CODE:
	LACL	0X0114
	SAH	PRO_VAR

	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER		;�򿪶�ʱ,��������,��ʱ�˳�
	
	CALL	VP_Set
	CALL	VP_SecurityCode

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
	XORL	CMSG_KEYGS
	BS	ACZ,LOCAL_PROMNU_1_X_REW	;REW(DEC)
;LOCAL_PROMNU_PSWORD_1_2:	
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,LOCAL_PROMNU_1_X_FFW	;FFW(INC)
;LOCAL_PROMNU_PSWORD_1_3:	
	LAC	MSG
	XORL	CMSG_KEYGP
	BS	ACZ,LOCAL_PROMNU_1_X_PREW	;REW
;LOCAL_PROMNU_PSWORD_1_4:	
	LAC	MSG
	XORL	CMSG_KEY8P
	BS	ACZ,LOCAL_PROMNU_1_X_PFFW	;FFW
;LOCAL_PROMNU_PSWORD_1_5:
	LAC	MSG
	XORL	CMSG_KEYES
	BS	ACZ,LOCAL_PROMNU_PSWORD_1_CODE	;code

	RET

LOCAL_PROMNU_PSWORD_1_CODE:
	LAC	PASSWORD
	ANDL	0XF0FF
	SAH	PASSWORD

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
	CALL	STORBYTE_DAT	;��0XFF��β

	LACK	1
	CALL	DEL_ONETEL
	CALL	TEL_GC_CHK
	CALL	GC_CHK
	
	LACK	0
	SAH	COUNT
	CALL	TELNUM_WRITE	;д������
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
	CALL	LED4_DISP

	LAC	MSG_N
	CALL	ANNOUNCE_NUM

	LACL	0XB7
	CALL	SET_LED3	;������
	
	LACL	0XC6	;"C2"
	CALL	SET_LED1
	LACL	0XA4
	CALL	SET_LED2

	RET

LOCAL_PROMNU_1_X_REW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	
	LAC	NEW1
	SAH	SYSTMP1
	LAC	NEW2
	SAH	SYSTMP2
	
	LAC	MSG_N
	CALL	VALUE_SUB
	SAH	MSG_N
LOCAL_PROMNU_1_X_VPDISP:
	LAC	MSG_N
	CALL	LED4_DISP
	
	LAC	MSG_N
	CALL	ANNOUNCE_NUM

	RET
LOCAL_PROMNU_1_X_PREW:
	LAC	NEW1
	SAH	SYSTMP1
	LAC	NEW2
	SAH	SYSTMP2

	LAC	MSG_N
	CALL	VALUE_SUB
	SAH	MSG_N
	CALL	LED4_DISP

	RET
;---
LOCAL_PROMNU_1_X_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	
	LAC	NEW1
	SAH	SYSTMP1
	LAC	NEW2
	SAH	SYSTMP2

	LAC	MSG_N
	CALL	VALUE_ADD
	SAH	MSG_N

	BS	B1,LOCAL_PROMNU_1_X_VPDISP
LOCAL_PROMNU_1_X_PFFW:
	LAC	NEW1
	SAH	SYSTMP1
	LAC	NEW2
	SAH	SYSTMP2

	LAC	MSG_N
	CALL	VALUE_ADD
	SAH	MSG_N

	LAC	MSG_N
	CALL	LED4_DISP
	
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
	XORL	CMSG_KEYGS
	BS	ACZ,LOCAL_PROMNU_1_X_REW	;REW
;MAIN_PRO9_1_2_2:	
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,LOCAL_PROMNU_1_X_FFW	;FFW
;MAIN_PRO9_1_2_3:	
	LAC	MSG
	XORL	CMSG_KEYGP
	BS	ACZ,LOCAL_PROMNU_1_X_PREW	;REW
;MAIN_PRO9_1_2_4:	
	LAC	MSG
	XORL	CMSG_KEY8P
	BS	ACZ,LOCAL_PROMNU_1_X_PFFW	;FFW
;MAIN_PRO9_1_2_5:
	LAC	MSG
	XORL	CMSG_KEYES
	BS	ACZ,LOCAL_PROMNU_PSWORD_2_CODE	;code

	RET

LOCAL_PROMNU_PSWORD_2_CODE:
	LAC	PASSWORD
	ANDL	0XFF0F
	SAH	PASSWORD

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
	CALL	STORBYTE_DAT	;��0XFF��β

	LACK	1
	CALL	DEL_ONETEL
	CALL	TEL_GC_CHK
	CALL	GC_CHK
	
	LACK	0
	SAH	COUNT
	CALL	TELNUM_WRITE	;д������
	CALL	DAT_WRITE_STOP
;---�������
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP		;BEEP
	
	LACL	0X0314
	SAH	PRO_VAR

	LAC	PASSWORD
	ANDK	0X0F
	SAH	MSG_N		;LOAD CURRENT VALUE(ps3)
	CALL	LED4_DISP

	LAC	MSG_N
	CALL	ANNOUNCE_NUM

	LACL	0XB6
	CALL	SET_LED3	;��������
	LACL	0XC6	;"C3"
	CALL	SET_LED1
	LACL	0XB0
	CALL	SET_LED2

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
	XORL	CMSG_KEYGS
	BS	ACZ,LOCAL_PROMNU_1_X_REW	;REW
;LOCAL_PROMNU_PSWORD_3_2:	
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,LOCAL_PROMNU_1_X_FFW	;FFW
;LOCAL_PROMNU_PSWORD_3_3:	
	LAC	MSG
	XORL	CMSG_KEYGP
	BS	ACZ,LOCAL_PROMNU_1_X_PREW	;REW
;LOCAL_PROMNU_PSWORD_3_4:	
	LAC	MSG
	XORL	CMSG_KEY8P
	BS	ACZ,LOCAL_PROMNU_1_X_PFFW	;FFW
;LOCAL_PROMNU_PSWORD_3_5:
	LAC	MSG
	XORL	CMSG_KEYES
	BS	ACZ,LOCAL_PROMNU_PSWORD_3_CODE	;code

	RET

LOCAL_PROMNU_PSWORD_3_CODE:
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
	CALL	STORBYTE_DAT	;��0XFF��β

	LACK	1
	CALL	DEL_ONETEL
	CALL	TEL_GC_CHK
	CALL	GC_CHK
	
	LACK	0
	SAH	COUNT
	CALL	TELNUM_WRITE	;д������
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
	SAH	MSG_N
	CALL	LED4_DISP
	
	LAC	MSG_N
	CALL	ANNOUNCE_NUM
	
	LACL	0XF7
	CALL	SET_LED3		;��λ��ʾ"�»���"

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
	SAH	MSG_N
	CALL	LED4_DISP

	LAC	MSG_N
	CALL	ANNOUNCE_NUM

	LACL	0XB7
	CALL	SET_LED3	;��λ��ʾ"���л���"
	
	RET
LOCAL_PROMNU_PSWORD2_DISP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	
	LACL	0X3414
	SAH	PRO_VAR
	
	LAC	PASSWORD
	ANDK	0X0F		;LOAD CURRENT VALUE(ps3)
	SAH	MSG_N
	CALL	LED4_DISP
	
	LAC	MSG_N
	CALL	ANNOUNCE_NUM
	
	LACL	0XB6
	CALL	SET_LED3	;��λ��ʾ"�����ϻ���"

	RET
LOCAL_PROMNU_PSWORD3_DISP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BBEEP
	
	LACK	0X0
	SAH	PRO_VAR
	
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROMNU_TIME:			;(0Xyy24)time set

	LAC	PRO_VAR
	SFR	8
	ANDK	0X0F
	BS	ACZ,LOCAL_PROMNU_2_0	;wait
	SBHK	1
	BS	ACZ,LOCAL_PROMNU_2_1	;week
	SBHK	1
	BS	ACZ,LOCAL_PROMNU_2_2	;hour
	SBHK	1
	BS	ACZ,LOCAL_PROMNU_2_3	;minute

	RET
;-------------------------------------------------------------------------------
LOCAL_PROMNU_2_0:
	LAC	MSG
	XORL	CMSG_KEYBS		;Announce time
	BS	ACZ,LOCAL_PROMNU_2_0_TIME
	
	RET
LOCAL_PROMNU_2_0_TIME:
	LACL	0X0124
	SAH	PRO_VAR

	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER
	
	LAC	MSG_N
	CALL	VPWEEK
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROMNU_2_1:			;adjust week
	
;LOCAL_PROMNU_2_1_1:		
	LAC	MSG
	XORL	CMSG_KEYGS
	BS	ACZ,LOCAL_PROMNU_2_1_REW	;REW
;LOCAL_PROMNU_2_1_2:	
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,LOCAL_PROMNU_2_1_FFW	;FFW
;LOCAL_PROMNU_2_1_3:	
	LAC	MSG
	XORL	CMSG_KEYGP
	BS	ACZ,LOCAL_PROMNU_2_X_PREW	;REW
;LOCAL_PROMNU_2_1_4:	
	LAC	MSG
	XORL	CMSG_KEY8P
	BS	ACZ,LOCAL_PROMNU_2_X_PFFW	;FFW
;LOCAL_PROMNU_2_1_5:
	LAC	MSG
	XORL	CMSG_KEYBS
	BS	ACZ,LOCAL_PROMNU_2_1_TIME	;TIME = CONFIRM
	
	RET
;-------respond9-2-1-week
LOCAL_PROMNU_2_1_REW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP		;BEEP

	LAC	NEW1
	SAH	SYSTMP1
	LAC	NEW2
	SAH	SYSTMP2

	LAC	MSG_N
	CALL	VALUE_SUB
	SAH	MSG_N
LOCAL_PROMNU_2_1_VPDISP:
	LAC	MSG_N
	CALL	VPWEEK

	LAC	MSG_N
	CALL	LED_HLDISP

	RET
LOCAL_PROMNU_2_1_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP		;BEEP

	LAC	NEW1
	SAH	SYSTMP1
	LAC	NEW2
	SAH	SYSTMP2

	LAC	MSG_N
	CALL	VALUE_ADD
	SAH	MSG_N
	
	BS	B1,LOCAL_PROMNU_2_1_VPDISP
;-------respond9-2-X
LOCAL_PROMNU_2_X_PREW:
	LAC	NEW1
	SAH	SYSTMP1
	LAC	NEW2
	SAH	SYSTMP2

	LAC	MSG_N
	CALL	VALUE_SUB
	SAH	MSG_N
	CALL	LED_HLDISP

	RET
LOCAL_PROMNU_2_X_PFFW:

	LAC	NEW1
	SAH	SYSTMP1
	LAC	NEW2
	SAH	SYSTMP2

	LAC	MSG_N
	CALL	VALUE_ADD
	SAH	MSG_N
	CALL	LED_HLDISP
	
	RET

LOCAL_PROMNU_2_1_TIME:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP		;BEEP
	
	LAC	MSG_N
	CALL	WEEK_SET
	
	LACL	0X0224
	SAH	PRO_VAR
;---���������	
	CALL	CHOUR_GET
	SAH	MSG_N		;CURRENT VALUE
	CALL	LED_HLDISP
	
	LAC	MSG_N
	CALL	ANNOUNCE_NUM
	CALL	VP_Hour
	
	LACK	0
	SAH	NEW1		;MIN VALUE
	LACK	23
	SAH	NEW2		;MAX VALUE

	RET
;-------------------------------------------------------------------------------
LOCAL_PROMNU_2_2:		;hour
	
;MAIN_PRO9_2_2_1:		
	LAC	MSG
	XORL	CMSG_KEYGS
	BS	ACZ,LOCAL_PROMNU_2_2_REW	;REW
;MAIN_PRO9_2_2_2:	
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,LOCAL_PROMNU_2_2_FFW	;FFW
;MAIN_PRO9_2_2_3:	
	LAC	MSG
	XORL	CMSG_KEYGP
	BS	ACZ,LOCAL_PROMNU_2_X_PREW	;REW
;MAIN_PRO9_2_2_4:	
	LAC	MSG
	XORL	CMSG_KEY8P
	BS	ACZ,LOCAL_PROMNU_2_X_PFFW	;FFW
;MAIN_PRO9_2_2_5:
	LAC	MSG
	XORL	CMSG_KEYBS
	BS	ACZ,LOCAL_PROMNU_2_2_TIME	;TIME
	
	RET
;-------respond9-2-2-hour
LOCAL_PROMNU_2_2_REW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP		;BEEP

	LAC	NEW1
	SAH	SYSTMP1
	LAC	NEW2
	SAH	SYSTMP2

	LAC	MSG_N
	CALL	VALUE_SUB
	SAH	MSG_N
LOCAL_PROMNU_2_2_VPDISP:
	LAC	MSG_N
	CALL	ANNOUNCE_NUM
	CALL	VP_Hour

	LAC	MSG_N
	CALL	LED_HLDISP

	RET
LOCAL_PROMNU_2_2_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP		;BEEP

	LAC	NEW1
	SAH	SYSTMP1
	LAC	NEW2
	SAH	SYSTMP2

	LAC	MSG_N
	CALL	VALUE_ADD
	SAH	MSG_N
	
	BS	B1,LOCAL_PROMNU_2_2_VPDISP
LOCAL_PROMNU_2_2_TIME:

	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP		;BEEP
	
	LAC	MSG_N
	CALL	HOUR_SET
	
	LACL	0X0324
	SAH	PRO_VAR
;---���������	
	CALL	CMIN_GET
	SAH	MSG_N		;CURRENT VALUE
	CALL	LED_HLDISP
	
	LAC	MSG_N
	CALL	ANNOUNCE_NUM
	CALL	VP_Minute
	LACK	0
	SAH	NEW1		;MIN VALUE
	LACK	59
	SAH	NEW2		;MAX VALUE

	RET
;-------------------------------------------------------------------------------
LOCAL_PROMNU_2_3:		;minute			
;MAIN_PRO9_2_3_1:		
	LAC	MSG
	XORL	CMSG_KEYGS
	BS	ACZ,LOCAL_PROMNU_2_3_REW	;REW
;MAIN_PRO9_2_3_2:	
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,LOCAL_PROMNU_2_3_FFW	;FFW
;MAIN_PRO9_2_3_3:	
	LAC	MSG
	XORL	CMSG_KEYGP
	BS	ACZ,LOCAL_PROMNU_2_X_PREW	;REW
;MAIN_PRO9_2_3_4:	
	LAC	MSG
	XORL	CMSG_KEY8P
	BS	ACZ,LOCAL_PROMNU_2_X_PFFW	;FFW
;MAIN_PRO9_2_3_5:
	LAC	MSG
	XORL	CMSG_KEYBS
	BS	ACZ,LOCAL_PROMNU_2_3_TIME	;TIME

	RET
;-------respond9-2-3-minute
LOCAL_PROMNU_2_3_REW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP		;BEEP
	
	LAC	NEW1
	SAH	SYSTMP1
	LAC	NEW2
	SAH	SYSTMP2

	LAC	MSG_N
	CALL	VALUE_SUB
	SAH	MSG_N
LOCAL_PROMNU_2_3_VPDISP:
	LAC	MSG_N
	CALL	ANNOUNCE_NUM
	CALL	VP_Minute
	LAC	MSG_N
	CALL	LED_HLDISP

	RET
LOCAL_PROMNU_2_3_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP		;BEEP

	LAC	NEW1
	SAH	SYSTMP1
	LAC	NEW2
	SAH	SYSTMP2

	LAC	MSG_N
	CALL	VALUE_ADD
	SAH	MSG_N
	
	BS	B1,LOCAL_PROMNU_2_3_VPDISP
	
LOCAL_PROMNU_2_3_TIME:

	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK

	LAC	MSG_N
	CALL	MIN_SET
	LACK	0
	CALL	SEC_SET
	
	CALL	CURR_WEEK
	CALL	CURR_HOUR
	CALL	CURR_MIN
	
	LACL	0X0
	SAH	PRO_VAR
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROMNU_RATE:		;(0Xyy34)psword set
	LAC	PRO_VAR
	SFR	8
	ANDK	0X0F
	BS	ACZ,LOCAL_PROMNU_3_0	;wait
	SBHK	1
	BS	ACZ,LOCAL_PROMNU_3_1	;adjust

	RET
LOCAL_PROMNU_3_0:
	LAC	MSG
	XORL	CMSG_KEYDS
	BS	ACZ,LOCAL_PROMNU_3_0_RATE
	
	RET

LOCAL_PROMNU_3_0_RATE:
	LACL	0X0134
	SAH	PRO_VAR

	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER		;�򿪶�ʱ,��������,��ʱ�˳�

	RET
LOCAL_PROMNU_3_1:

	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PROMNU_TMR	;TMR
	
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROMNU_VPSTOP	;VP end

;LOCAL_PROMNU_3_1_1:		
	LAC	MSG
	XORL	CMSG_KEYGS
	BS	ACZ,LOCAL_PROMNU_3_X_REW	;REW(DEC)
;LOCAL_PROMNU_3_1_2:	
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,LOCAL_PROMNU_3_X_FFW	;FFW(INC)
;LOCAL_PROMNU_3_1_3:	
	LAC	MSG
	XORL	CMSG_KEYGP
	BS	ACZ,LOCAL_PROMNU_3_X_PREW	;REW
;LOCAL_PROMNU_3_1_4:	
	LAC	MSG
	XORL	CMSG_KEY8P
	BS	ACZ,LOCAL_PROMNU_3_X_PFFW	;FFW
;LOCAL_PROMNU_3_1_5:
	LAC	MSG
	XORL	CMSG_KEYDS
	BS	ACZ,LOCAL_PROMNU_3_1_RATE	;rate

	RET
LOCAL_PROMNU_3_X_REW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
LOCAL_PROMNU_3_X_PREW:
	LAC	NEW1
	SAH	SYSTMP1
	LAC	NEW2
	SAH	SYSTMP2

	LAC	MSG_N
	CALL	VALUE_SUB
	SAH	MSG_N
	ADHL	RATE_TAB
	CALL	GetOneConst
	CALL	LED_HLDISP
	
	RET
LOCAL_PROMNU_3_X_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
LOCAL_PROMNU_3_X_PFFW:
	LAC	NEW1
	SAH	SYSTMP1
	LAC	NEW2
	SAH	SYSTMP2

	LAC	MSG_N
	CALL	VALUE_ADD
	SAH	MSG_N
	ADHL	RATE_TAB
	CALL	GetOneConst
	CALL	LED_HLDISP

	RET

LOCAL_PROMNU_3_1_RATE:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BBEEP
	
	LAC	TAD_ATT
	ANDL	0XFF0F
	SAH	TAD_ATT

	LAC	MSG_N
	SFL	4
	ANDL	0X00F0
	OR	TAD_ATT
	SAH	TAD_ATT

	LACL	0X0
	SAH	PRO_VAR
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROMNU_RING:		;(0Xyy44)psword set
	LAC	PRO_VAR
	SFR	8
	ANDK	0X0F
	BS	ACZ,LOCAL_PROMNU_4_0	;wait
	SBHK	1
	BS	ACZ,LOCAL_PROMNU_4_1	;adjust

	RET
;---------------
LOCAL_PROMNU_4_0:
	LAC	MSG
	XORL	CMSG_KEYAS
	BS	ACZ,LOCAL_PROMNU_4_0_RING
	
	RET

LOCAL_PROMNU_4_0_RING:
	LACL	0X0144
	SAH	PRO_VAR

	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER		;�򿪶�ʱ,��������,��ʱ�˳�

	RET
LOCAL_PROMNU_4_1:
	
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PROMNU_TMR	;TMR
	
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROMNU_VPSTOP	;VP end

;LOCAL_PROMNU_4_1_1:		
	LAC	MSG
	XORL	CMSG_KEYGS
	BS	ACZ,LOCAL_PROMNU_4_X_REW	;REW(DEC)
;LOCAL_PROMNU_4_1_2:	
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,LOCAL_PROMNU_4_X_FFW	;FFW(INC)
;LOCAL_PROMNU_4_1_3:	
	LAC	MSG
	XORL	CMSG_KEYGP
	BS	ACZ,LOCAL_PROMNU_4_X_PREW	;REW
;LOCAL_PROMNU_4_1_4:	
	LAC	MSG
	XORL	CMSG_KEY8P
	BS	ACZ,LOCAL_PROMNU_4_X_PFFW	;FFW
;LOCAL_PROMNU_4_1_5:
	LAC	MSG
	XORL	CMSG_KEYAS
	BS	ACZ,LOCAL_PROMNU_4_1_RING	;ring

	RET
LOCAL_PROMNU_4_X_REW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
LOCAL_PROMNU_4_X_PREW:
	LAC	NEW1
	SAH	SYSTMP1
	LAC	NEW2
	SAH	SYSTMP2

	LAC	MSG_N
	CALL	VALUE_SUB
	SAH	MSG_N
	CALL	LED_HLDISP
	
	RET
LOCAL_PROMNU_4_X_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
LOCAL_PROMNU_4_X_PFFW:
	LAC	NEW1
	SAH	SYSTMP1
	LAC	NEW2
	SAH	SYSTMP2

	LAC	MSG_N
	CALL	VALUE_ADD
	SAH	MSG_N
	CALL	LED_HLDISP

	RET
LOCAL_PROMNU_4_1_RING:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BBEEP
	
	LAC	VOI_ATT
	ANDL	0X0FFF
	SAH	VOI_ATT

	LAC	MSG_N
	SFL	12
	ANDL	0XF000
	OR	VOI_ATT
	SAH	VOI_ATT

	LACL	0X0
	SAH	PRO_VAR
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROMNU_OGM:
	LAC	PRO_VAR
	SFR	8
	ANDK	0X0F
	BS	ACZ,LOCAL_PROMNU_OGM_0	;(0X0054)wait
	SBHK	1
	BS	ACZ,LOCAL_PROMNU_OGM_1	;(0X0154)OGM select

	RET
;---------------
LOCAL_PROMNU_OGM_0:
	LAC	MSG
	XORL	CMSG_KEY6S
	BS	ACZ,LOCAL_PROMNU_OGM_0_OGM	;FFW(INC)

	RET
LOCAL_PROMNU_OGM_0_OGM:
	LACL	0X0154
	SAH	PRO_VAR

	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER		;�򿪶�ʱ,��������,��ʱ�˳�

	RET
;---------------
LOCAL_PROMNU_OGM_1:

	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PROMNU_TMR	;TMR
	
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROMNU_VPSTOP	;VP end

;LOCAL_PROMNU_OGM_1_1:		
	LAC	MSG
	XORL	CMSG_KEYGS
	BS	ACZ,LOCAL_PROMNU_OGM_1_REW	;REW(DEC)
;LOCAL_PROMNU_OGM_1_2:	
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,LOCAL_PROMNU_OGM_1_FFW	;FFW(INC)
;LOCAL_PROMNU_OGM_1_3:	
	LAC	MSG
	XORL	CMSG_KEYGP
	BS	ACZ,LOCAL_PROMNU_OGM_1_PREW	;REW
;LOCAL_PROMNU_OGM_1_4:	
	LAC	MSG
	XORL	CMSG_KEY8P
	BS	ACZ,LOCAL_PROMNU_OGM_1_PFFW	;FFW
;LOCAL_PROMNU_OGM_1_5:
	LAC	MSG
	XORL	CMSG_KEY6S
	BS	ACZ,LOCAL_PROMNU_OGM_1_OGM	;OGM

	RET
LOCAL_PROMNU_OGM_1_REW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
LOCAL_PROMNU_OGM_1_PREW:
	LAC	EVENT
	XORL	1<<8
	SAH	EVENT
	
	LAC	EVENT
	SFR	8
	ANDK	0X01
	ADHK	1
	CALL	LED_HLDISP
	
	RET
LOCAL_PROMNU_OGM_1_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
LOCAL_PROMNU_OGM_1_PFFW:
	LAC	EVENT
	XORL	1<<8
	SAH	EVENT
	
	LAC	EVENT
	SFR	8
	ANDK	0X01
	ADHK	1
	CALL	LED_HLDISP

	RET

LOCAL_PROMNU_OGM_1_OGM:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BBEEP
	
	LAC	EVENT
	SFR	8
	ANDK	0X01
	ADHK	1
	CALL	LED_HLDISP

	LACL	0X0
	SAH	PRO_VAR

	RET
;===============================================================================
	
.END
