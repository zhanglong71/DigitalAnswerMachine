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
.GLOBAL	LOCAL_PROMENU6
;-------------------------------------------------------------------------------
.LIST
.ORG    ADDR_SECOND
;-------------------------------------------------------------------------------
LOCAL_PROMENU6:				;MENU设置状态要考虑的消息(PRO_VAR)
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,MAIN_PROX_RINGIN
	LAC	MSG
	XORL	CMSG_TMR		;TMR
	BS	ACZ,MAIN_PRO9_TMR
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,MAIN_PRO9_VPSTOP	;VP end
	
	LAC	PRO_VAR
	ANDK	0X0F
	BS	ACZ,LOCAL_PROMENU6_0	;language
	SBHK	1
	BS	ACZ,LOCAL_PROMENU6_1	;ring change
	SBHK	1
	BS	ACZ,LOCAL_PROMENU6_2	;end

	RET
;-------common respond
MAIN_PRO9_VPSTOP:
	LACK	0
	SAH	PRO_VAR1		;计数器清零(按键松开后BEEP结束)	
	CALL	DAA_OFF

	RET
MAIN_PRO9_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	30
	BZ	SGN,MAIN_PRO9_TMROVER
	
	RET
MAIN_PRO9_TMROVER:		;超时退出
	BS	B1,MAIN_PRO9_X_STOP
;-----------------------------------------------------------	
LOCAL_PROMENU6_0:
	LAC	MSG
	XORL	CMENU_RCNT		;Set menu ring-count
	BS	ACZ,LOCAL_PROMENU6_0_MRCNT
	
	RET
;---------------------------------------
LOCAL_PROMENU6_0_MRCNT:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
	
	LACL	0X01
	SAH	PRO_VAR

	LAC	VOI_ATT		;LANGUAGE/OGM_ID/RING_CNT/ATT1
	SFR	4
	ANDK	0X0F
	SAH	MSG_N		;load CURRENT VALUE(RING_CNT)
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	CCOMMOND_RINGCNT	;select RING_CNT
	CALL	SEND_DAT
	LAC	MSG_N
	CALL	SEND_DAT	;goto next(RING_CNT)
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROMENU6_1:
;MAIN_PRO9_5_1_0:
	
;MAIN_PRO9_5_1_1:		
	LAC	MSG
	XORL	CMSG_KEY5S
	BS	ACZ,MAIN_PRO9_5_1_REW	;REW
;MAIN_PRO9_5_1_2:	
	LAC	MSG
	XORL	CMSG_KEY9S
	BS	ACZ,MAIN_PRO9_5_1_FFW	;FFW
;MAIN_PRO9_5_1_3:	
	LAC	MSG
	XORL	CMSG_KEY5P
	BS	ACZ,MAIN_PRO9_5_1_PREW	;REW
;MAIN_PRO9_5_1_4:	
	LAC	MSG
	XORL	CMSG_KEY9P
	BS	ACZ,MAIN_PRO9_5_1_PFFW	;FFW
;MAIN_PRO9_5_1_5:
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO9_5_1_MENU	;MENU
;MAIN_PRO9_5_1_6:	
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,MAIN_PRO9_X_STOP	;STOP

	RET
;---------------
MAIN_PRO9_5_1_REW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
MAIN_PRO9_5_1_PREW:
	LACK	1
	SAH	SYSTMP1
	LACK	9
	SAH	SYSTMP2

	LAC	MSG_N
	CALL	VALUE_SUB
	SAH	MSG_N
	BS	B1,MAIN_PRO9_5_X_SENDCOMM
MAIN_PRO9_5_1_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
MAIN_PRO9_5_1_PFFW:	
	LACK	1
	SAH	SYSTMP1
	LACK	9
	SAH	SYSTMP2

	LAC	MSG_N
	CALL	VALUE_ADD
	SAH	MSG_N

MAIN_PRO9_5_X_SENDCOMM:
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	CCOMMOND_RINGCNT	;select RING_CNT
	CALL	SEND_DAT
	LAC	MSG_N
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	RET
MAIN_PRO9_5_1_MENU:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF

	LAC	VOI_ATT
	ANDL	0XFF0F
	SAH	VOI_ATT
	
	LAC	MSG_N
	SFL	4
	OR	VOI_ATT
	SAH	VOI_ATT
	
	LACK	8
	SAH	OFFSET_D
	LAC	MSG_N
	CALL	STORBYTE_DAT
	LACK	11
	SAH	OFFSET_D
	LACL	0XFF
	CALL	STORBYTE_DAT	;以0XFF结尾
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
.if	0
	LACK	1
	CALL	DEL_ONETEL
	CALL	TEL_GC_CHK
	CALL	GC_CHK
	
	LACL	TEL_RAM
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	CALL	TELNUM_WRITE	;写入数据	
	CALL	DAT_WRITE_STOP
.endif
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;---	
	CALL	CLR_FUNC
	LACK	0
	SAH	PRO_VAR		;goto next(OGM-phone)
	LACL	CMENU_OGMC
	CALL	STOR_MSG

	RET
;-------------------------------------------------------------------------------
LOCAL_PROMENU6_2:

	RET
;---------------------------------------
MAIN_PRO9_X_STOP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BBEEP		;BB
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	CGROUP_DATETIME
	CALL	SET_TELGROUP
	
	LACK	1
	CALL	DEL_ONETEL
	CALL	TEL_GC_CHK
	CALL	GC_CHK

	CALL	DATETIME_WRITE
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
.if	1
	LACK	CGROUP_DATT
	CALL	SET_TELGROUP
	LACK	1
	CALL	DEL_ONETEL
	CALL	TEL_GC_CHK
	CALL	GC_CHK
	
	LACL	TEL_RAM
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	CALL	TELNUM_WRITE	;写入数据	
	CALL	DAT_WRITE_STOP
.endif
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	LAC	VOP_FG
	ANDL	~(1<<15)
	SAH	VOP_FG
	
;!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	LACL	0X9E		;exit COMMAND = 0X9E+6
	CALL	SEND_DAT
	LACK	6
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	CLR_FUNC
	LACK	0
	SAH	PRO_VAR

	RET
;---------------------------------------
MAIN_PROX_RINGIN:
	CALL	INIT_DAM_FUNC

	CALL	BLED_ON
	LACL	CMSG_INIT
	CALL	STOR_MSG
	
	
	LAC	VOP_FG
	ANDL	~(1<<15)
	SAH	VOP_FG
	
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9E
	CALL	SEND_DAT
	LACL	6
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	CLR_FUNC
	LACK	0
	SAH	PRO_VAR

	RET
;===============================================================================
	
.END

