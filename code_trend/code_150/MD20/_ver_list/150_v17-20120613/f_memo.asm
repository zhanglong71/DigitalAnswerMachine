.NOLIST
.INCLUDE MD20U.INC
.INCLUDE REG_D20.inc
.INCLUDE CONST.INC
.INCLUDE EXTERN.INC
;-------------------------------------------------------------------------------
.EXTERN	SetFlashStartAddress
.EXTERN	LoadHostCode
.EXTERN	GetOneConst	;(INPUT=ACCH(ProgramRamAddress),OUTPUT=ACCH(ReadData))
.EXTERN	GetMoreConst	;(INPUT=ACCH(ProgramRamStartingAddress)ACCL(ReadWordNumber)AR1(StoreDataRamAddress),OUTPUT=)
;-------------------------------------------------------------------------------
.global	LOCAL_PROMEM
;-------------------------------------------------------------------------------
.LIST
.ORG    ADDR_SECOND
;-------------------------------------------------------------------------------
LOCAL_PROMEM:				;Record memo

	LAC	PRO_VAR
	ANDK	0X0F
	BS	ACZ,MAIN_PRORECM_0	;local-idle to record
	SBHK	1
	BS	ACZ,MAIN_PRORECM_1	;LBEEP before record
	SBHK	1
	BS	ACZ,MAIN_PRORECM_2	;recording
	SBHK	1
	BS	ACZ,MAIN_PRORECM_3	;end record beep/delay
	
	RET
;-------------------------------------------------------------------------------
MAIN_PRORECM_0:	
	LAC	MSG
	XORL	CMSG_KEY1L
	BS	ACZ,MAIN_PRORECM_0_RECCOMM
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,MAIN_PRORECM_0_RINGIN
	
	RET
;-------
MAIN_PRORECM_0_RECCOMM:
	CALL	INIT_DAM_FUNC
	CALL	LBEEP
	CALL	DAA_SPK
	CALL	BLED_ON
	CALL	SET_COMPS	

	LACK	0X01
	SAH	PRO_VAR

	BIT	ANN_FG,13	;check memoful?
	BS	TB,MAIN_PRO0_RECO_MSG1

	RET
MAIN_PRO0_RECO_MSG1:
	CALL	INIT_DAM_FUNC
	LACK	0X03
	SAH	PRO_VAR
	
	CALL	VP_MEMFUL
	CALL	BBBEEP		;memory full(BBB)
			
	RET
;---------------------------------------
MAIN_PRORECM_0_RINGIN:
MAIN_PRORECM_1_RINGIN:
	CALL	INIT_DAM_FUNC
	
	CALL	CLR_FUNC	;先空
	LACK	0
	SAH	PRO_VAR

	CALL	BLED_ON
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9E
	CALL	SEND_DAT
	LACL	6
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LAC	MSG
	CALL	STOR_MSG

	RET
;-------------------------------------------------------------------------------
MAIN_PRORECM_1:
	LAC	MSG
	XORL	CMSG_KEY7S		;press ON/OFF key when playing voice prompt
	BS	ACZ,MAIN_PRORECM_1_STOP
	LAC	MSG
	XORL	CVP_STOP		;end of the voice prompt and begin to record
	BS	ACZ,MAIN_PRORECM_1_RECMEMO
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,MAIN_PRORECM_1_RINGIN

	RET
;---------------------------------------
MAIN_PRORECM_1_STOP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK	
	CALL	BB_VOP		;替换语音BB
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XC6
	CALL	SEND_DAT
	LACK	0
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	0X03
	SAH	PRO_VAR

	RET
;---------------------------------------
MAIN_PRORECM_1_RECMEMO:
	CALL	INIT_DAM_FUNC
	CALL	DAA_REC
	CALL	VPMSG_CHK
	LACK	CTAG_MEMO	;set memo flag
	CALL	SET_USRDAT1
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XC5
	CALL	SEND_DAT
	LACK	0
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	0X02
	SAH	PRO_VAR
	
	LACK	0
	SAH	PRO_VAR1
	LACL	CTMR1S
	CALL	SET_TIMER
	
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LAC	PRO_VAR1	;秒
	CALL	SEND_HHMMSS
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	REC_START
	
	RET
;-------------------------------------------------------------------------------
MAIN_PRORECM_2:			;recording
	LAC	MSG
	XORL	CMSG_KEY7S		;ON/OFF
	BS	ACZ,MAIN_PRORECM_2_STOP
	LAC	MSG
	XORL	CMSG_TMR		;TMR
	BS	ACZ,MAIN_PRORECM_2_TMR
	LAC	MSG
	XORL	CREC_FULL		;REC_FULL
	BS	ACZ,MAIN_PRORECM_2_FULL
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,MAIN_PRORECM_2_RINGIN
	
	
	RET
;-------处理消息------------------------
MAIN_PRORECM_2_FULL:
	LAC	PRO_VAR1
	SBHK	3
	BZ	SGN,MAIN_PRORECM_2_FULL_1
	
	LAC	CONF
	ORL	1<<11
	CALL	DAM_BIOSFUNC	
MAIN_PRORECM_2_FULL_1:	
	CALL	INIT_DAM_FUNC
	CALL	VPMSG_CHK
	BIT	ANN_FG,13
	BZ	TB,MAIN_PRORECM_2_NOFULL

	CALL	GC_CHK
	CALL	DAA_SPK
	CALL	BBBEEP
	CALL	VP_MEMFUL	;警告语音

	LACK	0X03
	SAH	PRO_VAR

	RET
MAIN_PRORECM_2_NOFULL:	;还可以继续录音

	CALL	REC_START
	
	RET

;---------------------------------------
MAIN_PRORECM_2_STOP:
	LAC	PRO_VAR1
	SBHK	3
	BZ	SGN,MAIN_PRORECM_2_STOP_1		;要求满足录音时间t>=3s才能保留

	LAC	CONF
	ORL	1<<11
	CALL	DAM_BIOSFUNC
MAIN_PRORECM_2_STOP_1:
	LAC	CONF
	ANDL	0XFFC0
	SAH	CONF
	CALL	INIT_DAM_FUNC
	CALL	GC_CHK
	
	CALL	DAA_SPK	
	CALL	BB_VOP	;替换语音BB
	CALL	VPMSG_CHK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XC6
	CALL	SEND_DAT
	LACK	0
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!

	LACK	0X03
	SAH	PRO_VAR

	RET
;---------------------------------------
MAIN_PRORECM_2_RINGIN:
	LAC	PRO_VAR1
	SBHK	3
	BZ	SGN,MAIN_PRORECM_2_RINGIN_1		;要求满足录音时间t>=3s才能保留

	LAC	CONF
	ORL	1<<11
	CALL	DAM_BIOSFUNC
MAIN_PRORECM_2_RINGIN_1:
	CALL	INIT_DAM_FUNC
	CALL	GC_CHK
	
	CALL	DAA_OFF

	CALL	VPMSG_CHK
	;CALL	GET_VPMSGN
	;SAH	MSG_N
	;CALL	GET_VPMSGT
	;SAH	MSG_T
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X83		;录音数量同步(3bytes)
	CALL	SEND_DAT
	LAC	MSG_N
	CALL	SEND_DAT
	LAC	MSG_T
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9E
	CALL	SEND_DAT
	LACL	6
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	CLR_FUNC	;先空
	LACK	0
	SAH	PRO_VAR

	LAC	MSG
	CALL	STOR_MSG

	RET
;---------------------------------------
MAIN_PRORECM_2_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LAC	PRO_VAR1	;秒
	CALL	SEND_HHMMSS
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	
	RET
;-------------------------------------------------------------------------------
MAIN_PRORECM_3:
	LAC	MSG
	XORL	CMSG_KEY7S		;press ON/OFF key when playing voice prompt
	BS	ACZ,MAIN_PRORECM_3_STOP
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,MAIN_PRORECM_3_RINGIN
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,MAIN_PRORECM_3_STOP
	
	RET
MAIN_PRORECM_3_STOP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF

	CALL	VPMSG_CHK
	;CALL	GET_VPMSGN
	;SAH	MSG_N
	;CALL	GET_VPMSGT
	;SAH	MSG_T
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X83		;录音数量同步(3bytes)
	CALL	SEND_DAT
	LAC	MSG_N
	CALL	SEND_DAT
	LAC	MSG_T
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9E
	CALL	SEND_DAT
	LACL	6
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	CLR_FUNC	;先空
	LACK	0
	SAH	PRO_VAR

	LACL	CMSG_INIT
	CALL	STOR_MSG

	RET	
;---------------------------------------
MAIN_PRORECM_3_RINGIN:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF

	CALL	VPMSG_CHK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X83		;录音数量同步(3bytes)
	CALL	SEND_DAT
	LAC	MSG_N
	CALL	SEND_DAT
	LAC	MSG_T
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9E
	CALL	SEND_DAT
	LACL	6
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	CLR_FUNC	;先空
	LACK	0
	SAH	PRO_VAR

	LAC	MSG
	CALL	STOR_MSG
	
	RET
;-------------------------------------------------------------------------------
.INCLUDE 	l_math.asm
;-------------------------------------------------------------------------------	
.END

