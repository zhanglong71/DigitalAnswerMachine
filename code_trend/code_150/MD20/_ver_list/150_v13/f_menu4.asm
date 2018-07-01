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
.GLOBAL	LOCAL_PROMENU4
;-------------------------------------------------------------------------------
.LIST
.ORG    ADDR_SECOND
;-------------------------------------------------------------------------------
LOCAL_PROMENU4:				;MENU设置状态要考虑的消息(PRO_VAR)
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,MAIN_PROX_RINGIN
	LAC	MSG
	XORL	CMSG_TMR		;TMR
	BS	ACZ,MAIN_PRO9_TMR
	
	LAC	PRO_VAR
	ANDK	0X0F
	BS	ACZ,LOCAL_PROMENU4_0	;local-idle to adjust
	SBHK	1
	BS	ACZ,LOCAL_PROMENU4_1	;password
	SBHK	1
	BS	ACZ,LOCAL_PROMENU4_2	;End
	
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
	BZ	SGN,MAIN_PRO9_X_STOP
	
	RET

;-------------------------------------------------------------------------------
LOCAL_PROMENU4_0:
	LAC	MSG
	XORL	CMENU_PSWD		;Set menu PSWORD
	BS	ACZ,LOCAL_PROMENU4_0_MPSWD
	
	RET
;---------------------------------------
LOCAL_PROMENU4_0_MPSWD:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
;---Send data first
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	SENDPSWORD
	LACL	0X0FF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;---再发调节项	
	LAC	PASSWORD
	SFR	8
	ANDK	0X0F
	SAH	MSG_N		;CURRENT VALUE

	LACK	0X11
	SAH	PRO_VAR
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	CCOMMOND_PSWORD1		;COMMAND = 0X97+value
	SAH	NEW_ID
	CALL	SEND_DAT
	LAC	MSG_N
	CALL	SEND_DAT
	LACL	0X0FF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	
	RET
;-----------------------------------------------------------
LOCAL_PROMENU4_1:
	LAC	PRO_VAR
	SFR	4
	ANDK	0X0F
	BS	ACZ,MAIN_PRO9_3_0	;display
	SBHK	1
	BS	ACZ,MAIN_PRO9_3_1	;adjust ps1
	SBHK	1
	BS	ACZ,MAIN_PRO9_3_2	;adjust ps2
	SBHK	1
	BS	ACZ,MAIN_PRO9_3_3	;adjust ps3

	RET
MAIN_PRO9_3_0:
	
	RET
;-----------------------------------------------------------
MAIN_PRO9_3_1:
;MAIN_PRO9_3_1_0:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,MAIN_PRO9_VPSTOP	;VP end
;MAIN_PRO9_3_1_1:		
	LAC	MSG
	XORL	CMSG_KEY5S
	BS	ACZ,MAIN_PRO9_3_X_REW	;REW
;MAIN_PRO9_3_1_2:	
	LAC	MSG
	XORL	CMSG_KEY9S
	BS	ACZ,MAIN_PRO9_3_X_FFW	;FFW
;MAIN_PRO9_3_1_3:	
	LAC	MSG
	XORL	CMSG_KEY5P
	BS	ACZ,MAIN_PRO9_3_X_PREW	;REW
;MAIN_PRO9_3_1_4:	
	LAC	MSG
	XORL	CMSG_KEY9P
	BS	ACZ,MAIN_PRO9_3_X_PFFW	;FFW
;MAIN_PRO9_3_1_5:
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO9_3_1_MENU	;MENU
;MAIN_PRO9_3_1_6:
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,MAIN_PRO9_X_STOP	;STOP(第一次操作就退出,没有要保存的数据)

	RET
;---------------------------------------
MAIN_PRO9_3_1_MENU:
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
;	CALL	SENDPSWORD
;	LACL	0XFF
;	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	0
	SAH	OFFSET_D
	LAC	MSG_N
	ANDK	0X0F
	CALL	STORBYTE_DAT
	
	LACK	11
	SAH	OFFSET_D
	LACL	0XFF
	CALL	STORBYTE_DAT	;以0XFF结尾
;---
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
	
	LACL	0X021
	SAH	PRO_VAR
	
	LACL	CCOMMOND_PSWORD2		;for ps2
	SAH	NEW_ID

	LAC	PASSWORD
	SFR	4
	ANDK	0X0F
	SAH	MSG_N		;LOAD CURRENT VALUE(ps2)
MAIN_PRO9_3_X_SENDCOMM:
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LAC	NEW_ID		;SEND COMMAND
	CALL	SEND_DAT
	LAC	MSG_N
	CALL	SEND_DAT
	LACL	0X0FF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	RET

MAIN_PRO9_3_X_REW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
MAIN_PRO9_3_X_PREW:
	LACK	0
	SAH	SYSTMP1
	LACK	9
	SAH	SYSTMP2

	LAC	MSG_N
	CALL	VALUE_SUB
	SAH	MSG_N

	BS	B1,MAIN_PRO9_3_X_SENDCOMM

MAIN_PRO9_3_X_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
MAIN_PRO9_3_X_PFFW:
	LACK	0
	SAH	SYSTMP1
	LACK	9
	SAH	SYSTMP2

	LAC	MSG_N
	CALL	VALUE_ADD
	SAH	MSG_N
	
	BS	B1,MAIN_PRO9_3_X_SENDCOMM

;-----------------------------------------------------------
MAIN_PRO9_3_2:
;MAIN_PRO9_3_2_0:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,MAIN_PRO9_VPSTOP	;VP end
;MAIN_PRO9_3_2_1:		
	LAC	MSG
	XORL	CMSG_KEY5S
	BS	ACZ,MAIN_PRO9_3_X_REW	;REW
;MAIN_PRO9_3_2_2:	
	LAC	MSG
	XORL	CMSG_KEY9S
	BS	ACZ,MAIN_PRO9_3_X_FFW	;FFW
;MAIN_PRO9_3_2_3:	
	LAC	MSG
	XORL	CMSG_KEY5P
	BS	ACZ,MAIN_PRO9_3_X_PREW	;REW
;MAIN_PRO9_3_2_4:	
	LAC	MSG
	XORL	CMSG_KEY9P
	BS	ACZ,MAIN_PRO9_3_X_PFFW	;FFW
;MAIN_PRO9_3_2_5:
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO9_3_2_MENU	;MENU
;MAIN_PRO9_3_2_6:
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,MAIN_PRO9_X_STOP	;STOP(先保存前面的设置,再退出)

	RET
;---------------------------------------
MAIN_PRO9_3_2_MENU:
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
;	CALL	SENDPSWORD
;	LACL	0XFF
;	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	1
	SAH	OFFSET_D
	LAC	MSG_N
	ANDK	0X0F
	CALL	STORBYTE_DAT
	LACK	11
	SAH	OFFSET_D
	LACL	0XFF
	CALL	STORBYTE_DAT	;以0XFF结尾
;---保存完毕
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
	
	LACL	0X031
	SAH	PRO_VAR
	
	LACL	CCOMMOND_PSWORD3	;for ps3
	SAH	NEW_ID

	LAC	PASSWORD
	ANDK	0X0F
	SAH	MSG_N		;LOAD CURRENT VALUE(ps2)

	BS	B1,MAIN_PRO9_3_X_SENDCOMM
;-------------------------------------------------------------------------------	
MAIN_PRO9_3_3:
;MAIN_PRO9_3_3_0:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,MAIN_PRO9_VPSTOP	;VP end
;MAIN_PRO9_3_3_1:		
	LAC	MSG
	XORL	CMSG_KEY5S
	BS	ACZ,MAIN_PRO9_3_X_REW	;REW
;MAIN_PRO9_3_3_2:	
	LAC	MSG
	XORL	CMSG_KEY9S
	BS	ACZ,MAIN_PRO9_3_X_FFW	;FFW
;MAIN_PRO9_3_3_3:	
	LAC	MSG
	XORL	CMSG_KEY5P
	BS	ACZ,MAIN_PRO9_3_X_PREW	;REW
;MAIN_PRO9_3_3_4:	
	LAC	MSG
	XORL	CMSG_KEY9P
	BS	ACZ,MAIN_PRO9_3_X_PFFW	;FFW
;MAIN_PRO9_3_3_5:
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO9_3_3_MENU	;MENU
;MAIN_PRO9_3_3_6:
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,MAIN_PRO9_X_STOP	;STOP(先保存前面的设置,再退出)
	
	RET
;---------------------------------------
MAIN_PRO9_3_3_MENU:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF

	LACK	2
	SAH	OFFSET_D
	LAC	MSG_N
	ANDK	0X0F
	CALL	STORBYTE_DAT
	LACK	11
	SAH	OFFSET_D
	LACL	0XFF
	CALL	STORBYTE_DAT	;以0XFF结尾
;---
	LACK	0		;PS1
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	ANDK	0XF
	SAH	PASSWORD
	SFL	4
	SAH	PASSWORD
	
	LACK	1		;PS2
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	ANDK	0XF
	OR	PASSWORD
	SFL	4
	SAH	PASSWORD

	LACK	2		;PS3
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	ANDK	0XF
	OR	PASSWORD
	SAH	PASSWORD
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	CALL	SENDPSWORD
	LACL	0XFF
	CALL	SEND_DAT
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
;----------End password and begin local code
	CALL	CLR_FUNC
	LACK	0
	SAH	PRO_VAR
	LACL	CMENU_LCOD
	CALL	STOR_MSG

	RET
;-------------------------------------------------------------------------------
LOCAL_PROMENU4_2:
	RET
;-----------------------------------------------------------


MAIN_PRO9_X_STOP:
	CALL	INIT_DAM_FUNC
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
	CALL	DAA_BSPK
	CALL	BBEEP		;BB
	
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

;-------------------------------------------------------------------------------
MAIN_PROX_RINGIN:
	CALL	INIT_DAM_FUNC

	CALL	BLED_ON
	LACL	CMSG_INIT
	CALL	STOR_MSG

	LAC	VOP_FG
	ANDL	~(1<<15)
	SAH	VOP_FG
	
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9E
	CALL	SEND_DAT
	LACL	6
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	CALL	CLR_FUNC
	LACK	0
	SAH	PRO_VAR
	
	RET

;############################################################################
;       Function : SENDPSWORD
;	PSWORD码同步(4byte)
;
;	input  : no
;	output : no
;
;############################################################################
SENDPSWORD:
	LACL	0X85		;PSWORD码同步(4byte)
	CALL	SEND_DAT
	LAC	PASSWORD
	SFR	8
	ANDK	0X0F
	CALL	SEND_DAT	;PS1
	LAC	PASSWORD
	SFR	4
	ANDK	0X0F
	CALL	SEND_DAT	;PS2
	LAC	PASSWORD
	ANDK	0X0F
	CALL	SEND_DAT	;PS3
	
	RET
;=========================================================================
	
.END

