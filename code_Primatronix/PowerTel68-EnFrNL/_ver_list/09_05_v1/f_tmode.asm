;-------------------------------------------------------------------------------
.NOLIST
.INCLUDE	REG_D20.inc
.INCLUDE	MD20U.inc
.INCLUDE	VOPidx.inc
.INCLUDE	CONST.inc
.INCLUDE	EXTERN.inc

.GLOBAL	LOCAL_PROTXT
;-------------------------------------------------------------------------------
.EXTERN	GetOneConst

;-------------------------------------------------------------------------------
.LIST
;-------------------------------------------------------------------------------
.ORG	ADDR_SECOND
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
	CALL	CLR_TIMER2	;for check handset on/off
	
	CALL	PORT_HSPLYL
	CALL	PORT_PLYL

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
	
	CALL	HANDSET_CHK
	LACL	300
	CALL	SET_TIMER2	;for check handset on/off
	
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
	CALL	HANDSET_CHK
	LACL	300
	CALL	SET_TIMER2	;for check handset on/off
	
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

	LAC	MSG
	XORL	CMSG_HSOFF
	BS	ACZ,LOCAL_PROTEST1_HSCHANG	;HandSet off base cradle

	LAC	MSG
	XORL	CMSG_TMR2
	BS	ACZ,LOCAL_PROTEST1_2TMR

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
	CALL	HANDSET_CHK
	LACL	300
	CALL	SET_TIMER2	;for check handset on/off
	
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
	BS	ACZ,LOCAL_PROTEST2_1_EXIT	
	
	LAC	MSG
	XORL	CMSG_HSOFF
	BS	ACZ,LOCAL_PROTEST2_HSCHANG	;HandSet off base cradle

	LAC	MSG
	XORL	CMSG_TMR2
	BS	ACZ,LOCAL_PROTEST2_2TMR

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

	LAC	MSG
	XORL	CMSG_HSOFF
	BS	ACZ,LOCAL_PROTEST3_HSCHANG	;HandSet off base cradle
	
	LAC	MSG
	XORL	CMSG_TMR2
	BS	ACZ,LOCAL_PROTEST3_2TMR

	RET

LOCAL_PROTEST3_OVER:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	HANDSET_CHK
	LACL	300
	CALL	SET_TIMER2	;for check handset on/off
	
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

;---------------------------------------
LOCAL_PROTEST1_2TMR:
LOCAL_PROTEST2_2TMR:
LOCAL_PROTEST3_2TMR:	
LOCAL_PROTEST1_HSCHANG:
LOCAL_PROTEST2_HSCHANG:
LOCAL_PROTEST3_HSCHANG:
	
	CALL	HANDSET_CHK
	
	RET
	
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
