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
	
	CALL	VPMSG_CHK
	LACK	CTAG_MEMO	;set memo flag
	CALL	SET_USRDAT1

	LACK	0
	SAH	PRO_VAR1
	LACL	CTMR1S
	CALL	SET_TIMER
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LAC	PRO_VAR1	;秒
	CALL	SEND_HHMMSS
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	SET_COMPS
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
	CALL	INIT_DAM_FUNC	;stop recording
	CALL	MEMFULL_CHK

	CALL	VP_MEMFUL
	CALL	BB_VOP
	CALL	DAA_SPK	

	LACK	0X03
	SAH	PRO_VAR
		
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
	CALL	GC_CHK		;perhaps delete action happend
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
	CALL	DAA_OFF

	CALL	VPMSG_CHK
	;CALL	GET_VPMSGN
	;SAH	MSG_N
	;CALL	GET_VPMSGT
	;SAH	MSG_T
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	SEND_MSGNUM	;录音数量同步(4bytes)
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
	SBHK	CLMEM
	BZ	SGN,MAIN_PRORECM_2_TMROVER	;???????????????????????????????
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LAC	PRO_VAR1	;秒
	CALL	SEND_HHMMSS
;!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	RET
MAIN_PRORECM_2_TMROVER:
	BS	B1,MAIN_PRORECM_2_STOP
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
	CALL	SEND_MSGNUM	;录音数量同步(4bytes)
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
	CALL	SEND_MSGNUM	;录音数量同步(4bytes)
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
;--------------------------------------------------------------------------------
.INCLUDE	l_math.asm
;-------------------------------------------------------------------------------
.END

