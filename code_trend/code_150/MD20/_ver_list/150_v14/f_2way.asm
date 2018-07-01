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
.global	TWAY_STATE
;-------------------------------------------------------------------------------
.LIST
.ORG    ADDR_SECOND
;-------------------------------------------------------------------------------
TWAY_STATE:
	LAC	PRO_VAR
	ANDK	0X0F
	BS	ACZ,TWAY_STATE0		;local-idle to record
	SBHK	1
	BS	ACZ,TWAY_STATE1		;LBEEP before record
	SBHK	1
	BS	ACZ,TWAY_STATE2		;recording
	SBHK	1
	BS	ACZ,TWAY_STATE3		;end record beep/delay

	RET
;-------------------------------------------------------------------------------
TWAY_STATE0:	
	LAC	MSG
	XORL	CMSG_KEY4L		;"Play"key for 2-way
	BS	ACZ,TWAY_STATE0_2WAY
;TWAY_STATE0_1:	
	LAC	MSG
	XORL	CMSG_KEY7S		
	BS	ACZ,TWAY_STATE0_STOP	;CVP_STOP,LBEEP播放完毕
;TWAY_STATE0_2:

	RET
;---------------------------------------
TWAY_STATE0_2WAY:
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_SPK
	;CALL	DAA_SPK

	CALL	TWHOOK_ON
     	CALL	SET_COMPS

     	LACK	1
     	SAH	MBOX_ID		;Common mailbox
	CALL	VPMSG_CHK
	BIT	ANN_FG,13
	BS	TB,TWAY_STATE0_2WAY_FULL	;满了不准再录,退出


	CALL	LBEEP
	LACK	0X01
	SAH	PRO_VAR
	
	RET
TWAY_STATE0_2WAY_FULL:
	CALL	BBBEEP
	LACK	0X03
	SAH	PRO_VAR
	
	RET
TWAY_STATE0_STOP:
	BS	B1,TWAY_STATE1_STOP
;-------------------------------------------------------------------------------
TWAY_STATE1:
	LAC	MSG
	XORL	CVP_STOP		
	BS	ACZ,TWAY_STATE1_REC2WAY	;LBEEP end
;TWAY_STATE1_2:
	LAC	MSG
	XORL	CMSG_KEY7S		;STOP
	BS	ACZ,TWAY_STATE1_STOP

	RET
;---------------------------------------
TWAY_STATE1_REC2WAY:
	CALL	INIT_DAM_FUNC
	CALL	DAA_TWAY_REC
	;CALL	DAA_REC

	CALL	BCVOX_INIT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XD0		;告诉MCU摘机了
	CALL	SEND_DAT
	LACK	0
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XC5
	CALL	SEND_DAT
	LACK	2
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
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
	CALL	SET_USRDAT
	LACK	CTAG_MEMO		;set memo flag
	CALL	SET_USRDAT1
	
	CALL	REC_START
		
	RET
;---------------------------------------
TWAY_STATE1_STOP:
;!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XC6		;还没开始就结束了
	CALL	SEND_DAT
	LACK	2
	CALL	SEND_DAT
	
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	INIT_DAM_FUNC
	;CALL	GET_TOTALMSG
	;CALL	GET_USRDAT

	LACK	0X03
	SAH	PRO_VAR

	CALL	BB_VOP
	CALL	DAA_SPK
	
	RET
;-------------------------------------------------------------------------------	
TWAY_STATE2:
;TWAY_STATE2_0:
	LAC	MSG
	XORL	CMSG_TMR		;time 1s
	BS	ACZ,TWAY_STATE2_TMR
;TWAY_STATE2_1:
	LAC	MSG
	XORL	CMSG_KEY7S		;STOP
	BS	ACZ,TWAY_STATE2_RECSTOP
;TWAY_STATE2_2:
	LAC	MSG
	XORL	CREC_FULL		;REC_FULL
	BS	ACZ,TWAY_STATE2_FULL
;TWAY_STATE2_3:	
	
	RET
;---------------------------------------				;由于后BTONE,CTONE,VOX要持续一段时间,可不考虑小长度的录音删除问题
TWAY_STATE2_RECSTOP:
	LAC	PRO_VAR1
	SBHK	3
	BZ	SGN,TWAY_STATE2_RECSTOP_1
	
	LAC	CONF
	ORL	1<<11
	CALL	DAM_BIOSFUNC
TWAY_STATE2_RECSTOP_1:	
	CALL	INIT_DAM_FUNC
	CALL	GC_CHK
	CALL	DAA_SPK	
	CALL	BB_VOP
	
	CALL	VPMSG_CHK
;!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XC6		;停止TWAY录音
	CALL	SEND_DAT
	LACK	2
	CALL	SEND_DAT
	
	LACL	0XFF
	CALL	SEND_DAT

;!!!!!!!!!!!!!!!!!!!!!!!!!!

	;CALL	GET_TOTALMSG
	;CALL	GET_USRDAT

	LACK	0X03
	SAH	PRO_VAR
	
	RET
;---------------------------------------
TWAY_STATE2_FULL:	;MFULL退出
	LAC	PRO_VAR1
	SBHK	3
	BZ	SGN,TWAY_STATE2_FULL_1
	
	LAC	CONF
	ORL	1<<11
	CALL	DAM_BIOSFUNC
TWAY_STATE2_FULL_1:	
	
	CALL	INIT_DAM_FUNC
	CALL	VPMSG_CHK
	BIT	ANN_FG,13
	BZ	TB,TWAY_STATE2_NOFULL

	CALL	GC_CHK
	CALL	DAA_SPK
	CALL	BBBEEP
	CALL	VP_MEMFUL	;警告语音

	LACK	0X03
	SAH	PRO_VAR

	RET
TWAY_STATE2_NOFULL:	;还可以继续录音
	CALL	REC_START
	
	RET
;---------------------------------------
TWAY_STATE2_TMR:
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
;=================================================================
TWAY_STATE3:
	LAC	MSG
	XORL	CVP_STOP		
	BS	ACZ,TWAY_STATE3_EXIT	;VP play end
	LAC	MSG
	XORL	CMSG_KEY7S		
	BS	ACZ,TWAY_STATE3_EXIT	;stop

	RET
;---------------------------------------
TWAY_STATE3_EXIT:
	CALL	INIT_DAM_FUNC
	CALL	CLR_FUNC	;先空
	LACK	0
	SAH	PRO_VAR
	CALL	TWHOOK_OFF
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XD0		;告诉MCU挂机了
	CALL	SEND_DAT
	LACK	1
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
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
	LACL	CMSG_INIT
	CALL	STOR_MSG

	RET
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;	Function : TWHOOK_ON
;	
;	hand on the telephone
;-------------------------------------------------------------------------------
TWHOOK_ON:
	LIPK	8

	IN	SYSTMP0,GPBD
	LAC	SYSTMP0
	ORL	1<<4
	SAH	SYSTMP0
	OUT	SYSTMP0,GPBD
	ADHK	0		;2-way on----GPBD(bit4)
	
	RET
;-------------------------------------------------------------------------------
;	Function : TWHOOK_OFF
;	
;	hand off the telephone
;-------------------------------------------------------------------------------
TWHOOK_OFF:
	LIPK	8

	IN	SYSTMP0,GPBD
	LAC	SYSTMP0
	ANDL	~(1<<4)
	SAH	SYSTMP0
	OUT	SYSTMP0,GPBD
	ADHK	0		;2-way off----GPBD(bit4)
	
	RET
;--------------------------------------------------------------------------------
.INCLUDE 	l_math.asm
;-------------------------------------------------------------------------------
.END
