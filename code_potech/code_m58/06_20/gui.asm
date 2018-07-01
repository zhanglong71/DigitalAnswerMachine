.LIST

;-------------------------------------------------------------------------
;	Function : GET_MSG	
;-------------------------------------------------------------------------
GET_MSG:
	DINT
	
	LAC	MSG_QUEUE
	ANDK	0X07
	SAH	INT_TTMP0
	LAC	MSG_QUEUE
	SFR	8
	SBH	INT_TTMP0
	BS	ACZ,GET_MSG_END		;NO MESSAGE
GET_MSG_GET:
	LAC	MSG_QUEUE
	ADHK	1
	ANDL	0X707
	SAH	MSG_QUEUE
	
	ANDK	0X07
	ADHL	MSG_ADDR		;GET ADDR
	SAH	INT_TTMP0
	
	MAR	+0,1
	LAR	INT_TTMP0,1
	LAC	+0,1
GET_MSG_END:
	EINT
	RET
;-------------------------------------------------------------------------
;	Function : INT_STOR_MSG	
;-------------------------------------------------------------------------
INT_STOR_MSG:			;中断存消息
	SAH	INT_TTMP0
	
	LAC	MSG_QUEUE
	ADHL	0X100
	ANDL	0X707
	SAH	MSG_QUEUE
	
	SFR	8
	ADHL	MSG_ADDR	;GET ADDR
	SAH	INT_TTMP1
	
	MAR	+0,1
	LAR	INT_TTMP1,1
	LAC	INT_TTMP0
	SAH	+0,1
	RET
;---
STOR_MSG:
	DINT
	CALL	INT_STOR_MSG
	EINT
	RET
;//-------------------------------------------------------
;---
GET_FUNC:
	LAC	FUNC_STACK
	BS	ACZ,GET_FUNC_MAIN
	ADHL	FUNC_STACK
	SAH	SYSTMP0
	
	MAR	+0,1
	LAR	SYSTMP0,1
	LAC	+0,1
GET_FUNC_END:
	RET
GET_FUNC_MAIN:			;如果没有就是主程序
	LACL	MAIN_PRO
	RET

;//--------------------------------------------------------------------------
;	Function : PUSH_FUNC
;	input 	 : ACCH
;	output	 : no
;	variable : SYSTMP0,SYSTMP1
;//--------------------------------------------------------------------------
PUSH_FUNC:
	SAH	SYSTMP0
	LAC	FUNC_STACK
	ADHK	1
	ANDK	0X03
	SAH	FUNC_STACK
	ADHL	FUNC_STACK
	SAH	SYSTMP1
	
	MAR	+0,1
	LAR	SYSTMP1,1
	LAC	SYSTMP0
	SAH	+0,1
	RET

;---
CLR_FUNC:
	LACK	0
	SAH	FUNC_STACK
	CALL	DAA_OFF		;(默认)线路空置
	RET

;--------------------
GET_VP:
	LAC	VP_QUEUE
	ANDK	0X0F
	SAH	SYSTMP0
	LAC	VP_QUEUE
	SFR	8
	SBH	SYSTMP0
	BS	ACZ,GET_VP_END
	
	LAC	VP_QUEUE
	ADHK	1
	ANDL	0X0F0F
	SAH	VP_QUEUE
	
	ANDK	0XF
	ADHL	VP_ADDR
	SAH	SYSTMP0		;ADDRESS
	
	MAR	+0,1
	LAR	SYSTMP0,1
	LAC	+0,1
GET_VP_END:
	RET
;----------------
;------------------------------------------------------------------------------
;	Function : STOR_VP
;
;		input : ACCH
;		output: no
;------------------------------------------------------------------------------
STOR_VP:
	SAH	SYSTMP
	LAC	VP_QUEUE
	ADHL	0X100
	ANDL	0X0F0F
	SAH	VP_QUEUE
	
	SFR	8
	ADHL	VP_ADDR
	SAH	SYSTMP0		;ADDRESS
	
	MAR	+0,1
	LAR	SYSTMP0,1
	LAC	SYSTMP
	SAH	+0,1
	RET
;---

.END
	