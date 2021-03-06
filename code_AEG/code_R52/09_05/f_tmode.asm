;-------------------------------------------------------------------------------
.NOLIST
.INCLUDE	REG_D20.inc
.INCLUDE	MX93D20.inc
.INCLUDE	MACRO.inc
.INCLUDE	CONST.inc

.GLOBAL	LOCAL_PROTXT
;-------------------------------------------------------------------------------
.EXTERN	GetOneConst
.EXTERN	INIT_DAM_FUNC

.EXTERN	DAA_REC
.EXTERN	DAA_SPK
.EXTERN DAA_ANS_SPK
.EXTERN DAA_ANS_REC
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
.ORG	0x5500
LOCAL_PROTXT:			;PRO_VAR = 0Xyyy7
	LAC	PRO_VAR
	SFR	4
	ANDK	0X0F
	BS	ACZ,LOCAL_PROTEST0	;idle
	SBHK	1
	BS	ACZ,LOCAL_PROTEST1	;MIC Recording
	SBHK	1
	BS	ACZ,LOCAL_PROTEST2	;LINE Recording
	SBHK	1
	BS	ACZ,LOCAL_PROTEST3	;PlayBackCurrentMessage
	SBHK	1
	BS	ACZ,LOCAL_PROTEST4	;QuiteMode(Line seize only)
	SBHK	1
	BS	ACZ,LOCAL_PROTEST5	;Ringer
	SBHK	1
	BS	ACZ,LOCAL_PROTEST6	;Del all messages(FormatFlash)
	SBHK	1
	BS	ACZ,LOCAL_PROTEST7	;Exit

	RET
;-------------------------------------------------------------------------------
LOCAL_PROTEST0:		;Idle
	LAC	MSG
	XORL	CMSG_KEY5D		;OGM
	BS	ACZ,LOCAL_PROTEST0_MICREC
;---
	LAC	MSG
	XORL	CMSG_KEY2D		;>>
	BS	ACZ,LOCAL_PROTEST0_LINREC
;---
	LAC	MSG
	XORL	CMSG_KEY1D		;PLAY
	BS	ACZ,LOCAL_PROTEST0_PLYMSG
;---
	LAC	MSG
	XORL	CMSG_KEY3D		;DEL
	BS	ACZ,LOCAL_PROTEST0_QITMOD
;---
	LAC	MSG
	XORL	CMSG_KEY7D		;VOL+
	BS	ACZ,LOCAL_PROTEST0_RNTMOD
;---
	LAC	MSG
	XORL	CMSG_KEY6L		;STOP
	BS	ACZ,LOCAL_PROTEST0_EXTMOD
;---
	LAC	MSG
	XORL	CVP_STOP		;STOP
	BS	ACZ,LOCAL_PROTEST0_INIT
	
	RET
;---------------响应区
LOCAL_PROTEST0_INIT:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	CALL	HOOK_OFF
	CALL	VPMSG_CHK
	LACK	0X0007
	SAH	PRO_VAR
;---Display "tt"
	LACL	0X8787
	SAH	LED_L	
	
	RET
LOCAL_PROTEST0_MICREC:
	CALL	INIT_DAM_FUNC
	CALL	DAA_REC
	;CALL	SET_COMPS
;---Display "-0"
	LACL	0XBFC0
	SAH	LED_L
	
	CALL	VPMSG_CHK		;进入播放子功能
	LACK	0X0017
	SAH	PRO_VAR

	LACL	1000
	CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1

	CALL	REC_START

	RET
LOCAL_PROTEST0_LINREC:
	CALL	HOOK_ON
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_REC
	CALL	BCVOX_INIT
	CALL	VPMSG_CHK		;进入播放子功能
	LACK	0X0027
	SAH	PRO_VAR
;---Display "-L"
	LACL	0XBFC7
	SAH	LED_L
	
	LACK	0
	SAH	PRO_VAR1
	LACL	100
	CALL	SET_TIMER	;为了查VOX

	CALL	REC_START
	
	RET
LOCAL_PROTEST0_PLYMSG:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	LACK	0X005
	CALL	STOR_VP

	LACK	0X0037
	SAH	PRO_VAR

	LACL	0X8CC7		;Display "PL"
	SAH	LED_L

	CALL	VPMSG_CHK		;进入播放子功能
	CALL	CLR_FLAG

	LACK	0
	SAH	MSG_ID
	
	RET
LOCAL_PROTEST0_QITMOD:
	LACK	0X0047
	SAH	PRO_VAR
	CALL	HOOK_ON
	
	RET
LOCAL_PROTEST0_RNTMOD:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	LACK	0X0005
	CALL	STOR_VP
	
	LACK	0X0057
	SAH	PRO_VAR
	
	LACL	100
	CALL	SET_TIMER

	LACK	0
	SAH	RING_ID
	
	SAH	PRO_VAR1	;铃声次数清零
	CALL	LED_HLDISP	;Display "count"

	RET
LOCAL_PROTEST0_EXTMOD:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	LACK	0X0005
	CALL	STOR_VP

	LACK	0X0077
	SAH	PRO_VAR

	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROTEST1:			;MIC Recording
	LAC	PRO_VAR
	SFR	8
	ANDK	0X0F
	BS	ACZ,LOCAL_PROTEST1_0
	SBHK	1
	BS	ACZ,LOCAL_PROTEST1_1
	
	RET
LOCAL_PROTEST1_0:	;---Record	
	LAC	MSG
	XORL	CMSG_KEY6S		;Stop record
	BS	ACZ,LOCAL_PROTEST1_0_EXIT	
	
	RET
LOCAL_PROTEST1_0_EXIT:
	CALL	HOOK_ON
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_SPK
	CALL	VPMSG_CHK
	
	LACL	0X0117
	SAH	PRO_VAR

	CALL	BEEP
	LAC	MSG_T
	ORL	0XFE00
	CALL	STOR_VP

	RET
;-------
LOCAL_PROTEST1_1:	;---Play
	LAC	MSG
	XORL	CVP_STOP		;Play end
	BS	ACZ,LOCAL_PROTEST1_1_EXIT	
	
	RET

LOCAL_PROTEST1_1_EXIT:	;退回到测试平台
	BS	B1,LOCAL_PROTEST0_INIT
;---------------------------------------
LOCAL_PROTESTX_EXIT:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	
	LACK	0X0007
	SAH	PRO_VAR
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROTEST2:			;LINE Recording
	LAC	PRO_VAR
	SFR	8
	ANDK	0X0F
	BS	ACZ,LOCAL_PROTEST2_0
	SBHK	1
	BS	ACZ,LOCAL_PROTEST2_1

	RET
LOCAL_PROTEST2_0:
	LAC	MSG
	XORL	CMSG_KEY6S		;Stop Record
	BS	ACZ,LOCAL_PROTEST2_0_EXIT
	
	LAC	MSG
	XORL	CMSG_TMR		;TMR
	BS	ACZ,LOCAL_PROTEST2_0_TMR	
	
	RET
LOCAL_PROTEST2_0_EXIT:
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_SPK
	CALL	VPMSG_CHK
	
	LACL	1000
	CALL	SET_TIMER

	LACL	0X0127
	SAH	PRO_VAR
	
	CALL	BEEP
	LAC	MSG_T
	ORL	0XFE00
	CALL	STOR_VP

	RET
LOCAL_PROTEST2_0_TMR:
	BIT	RESP,6
	BS	TB,LOCAL_PROTEST2_0_TMRVOX1
	
	LACL	0XBFC7		;Display "-L"
	SAH	LED_L
	
	RET
LOCAL_PROTEST2_0_TMRVOX1:
	LACL	0XBFC1		;Display "-V"
	SAH	LED_L
		
	RET
;---------------
LOCAL_PROTEST2_1:
	LAC	MSG
	XORL	CVP_STOP		;Play end
	BS	ACZ,LOCAL_PROTEST1_1_EXIT	
	
	RET
LOCAL_PROTEST2_1_EXIT:		;退回到测试平台
	BS	B1,LOCAL_PROTEST0_INIT
;-------------------------------------------------------------------------------
LOCAL_PROTEST3:			;PlayBackCurrentMessage
	LAC	MSG
	XORL	CMSG_KEY6S		;STOP
	BS	ACZ,LOCAL_PROTEST3_EXIT	
	
	LAC	MSG
	XORL	CVP_STOP		;STOP
	BS	ACZ,LOCAL_PROTEST3_OVER	
	
	RET

LOCAL_PROTEST3_OVER:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	LAC	MSG_ID
	SBH	MSG_T
	BZ	SGN,LOCAL_PROTEST3_EXIT

	LAC	MSG_ID			;next message
	ADHK	1
	SAH	MSG_ID
	
	CALL	BEEP
	LAC	MSG_ID
	ORL	0XFE00
	CALL	STOR_VP
	
	RET
LOCAL_PROTEST3_EXIT:
	BS	B1,LOCAL_PROTESTX_EXIT
;-------------------------------------------------------------------------------
LOCAL_PROTEST4:			;QuiteMode(Line seize only)
	LAC	MSG
	XORL	CMSG_KEY6S		;STOP
	BS	ACZ,LOCAL_PROTEST4_EXIT	
	
	RET
LOCAL_PROTEST4_EXIT:
	BS	B1,LOCAL_PROTESTX_EXIT
;-------------------------------------------------------------------------------
LOCAL_PROTEST5:			;Ringer
	LAC	MSG
	XORL	CMSG_KEY6S		;STOP
	BS	ACZ,LOCAL_PROTESTX_EXIT	
;---
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,LOCAL_PROTEST5_RING
	
	LAC	RING_ID
	ANDL	0XFF0F
	SAH	RING_ID		;防摘机

	RET
LOCAL_PROTEST5_RING:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	
	;LAC	PRO_VAR1
	CALL	LED_HLDISP	;Display "count"
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROTEST6:			;Del all messages(FormatFlash)
	LAC	MSG
	XORL	CMSG_KEY6S		;STOP
	BS	ACZ,LOCAL_PROTESTX_EXIT	
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROTEST7:
	LAC	MSG
	XORL	CMSG_TMR		;STOP
	BS	ACZ,LOCAL_PROTEST7_TMR
	
	RET
LOCAL_PROTEST7_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	3
	BZ	SGN,LOCAL_PROTEST7_EXIT
	
	RET
LOCAL_PROTEST7_EXIT:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BBEEP
	LACK	0X0
	SAH	PRO_VAR

	RET	

;-------------------------------------------------------------------------------
.END
