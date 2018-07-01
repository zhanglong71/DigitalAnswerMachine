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
.GLOBAL	LOCAL_PROMENU3
;-------------------------------------------------------------------------------
.LIST
.ORG    ADDR_SECOND
;-------------------------------------------------------------------------------
LOCAL_PROMENU3:				;contrast设置状态要考虑的消息(PRO_VAR)
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,MAIN_PROX_RINGIN
	LAC	MSG
	XORL	CMSG_TMR		;TMR
	BS	ACZ,MAIN_PRO9_TMR

	LAC	PRO_VAR
	ANDK	0X0F
	BS	ACZ,LOCAL_PROMENU3_0	;local-idle to adjust
	SBHK	1
	BS	ACZ,LOCAL_PROMENU3_1	;contrast
	SBHK	1
	BS	ACZ,LOCAL_PROMENU3_2	;end
	SBHK	1
	BS	ACZ,LOCAL_PROMENU3_3	;end and exit

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
LOCAL_PROMENU3_0:
	LAC	MSG
	XORL	CMENU_CTRT		;Set menu contrast
	BS	ACZ,LOCAL_PROMENU3_0_MCTRT

	RET
;---------------------------------------
LOCAL_PROMENU3_0_MCTRT:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
	
	LACL	0X01
	SAH	PRO_VAR

	LAC	LOCACODE1
	SFR	4
	ANDK	0x0F
	SAH	MSG_N		;CURRENT VALUE
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	CCOMMOND_CONTRAST		;COMMAND = 0X96+value
	CALL	SEND_DAT
	LAC	MSG_N
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	RET
;-------------------------------------------------------------------------------
LOCAL_PROMENU3_1:			;adjust contrast
;MAIN_PRO9_2_1_0:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,MAIN_PRO9_VPSTOP	;VP end
;MAIN_PRO9_2_1_1:		
	LAC	MSG
	XORL	CMSG_KEY2S
	BS	ACZ,MAIN_PRO9_2_1_REW	;REW
;MAIN_PRO9_2_1_2:	
	LAC	MSG
	XORL	CMSG_KEY1S
	BS	ACZ,MAIN_PRO9_2_1_FFW	;FFW
;MAIN_PRO9_2_1_3:	
	LAC	MSG
	XORL	CMSG_KEY2P
	BS	ACZ,MAIN_PRO9_2_1_PREW	;REW
;MAIN_PRO9_2_1_4:	
	LAC	MSG
	XORL	CMSG_KEY1P
	BS	ACZ,MAIN_PRO9_2_1_PFFW	;FFW
;MAIN_PRO9_2_1_5:
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO9_2_1_MENU	;MENU
;MAIN_PRO9_2_1_6:	
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,MAIN_PRO9_2_STOP	;STOP(操作退出,要恢复以前的亮度)
	
	RET
;-------contrast------------------------
MAIN_PRO9_2_STOP:
MAIN_PRO9_X_STOP:
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
	LACL	0X87		;LCD 亮度
	CALL	SEND_DAT
	LAC	LOCACODE1
	SFR	4
	ANDK	0x07
	CALL	SEND_DAT
	LACL	0X0FF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	INIT_DAM_FUNC
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
	LACK	0x03
	SAH	PRO_VAR

	RET

;---------------------------------------
MAIN_PRO9_2_1_REW:	
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
MAIN_PRO9_2_1_PREW:
	LACK	1
	SAH	SYSTMP1
	LACK	5
	SAH	SYSTMP2

	LAC	MSG_N
	CALL	VALUE_SUB
	SAH	MSG_N
MAIN_PRO9_2_1_SENDCOMM:		;Send and save LCD contrast
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	LACL	CCOMMOND_CONTRAST	;SEND COMMAND
	CALL	SEND_DAT
	LAC	MSG_N
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	RET
;---------------------------------------
MAIN_PRO9_2_1_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
MAIN_PRO9_2_1_PFFW:
	LACK	1
	SAH	SYSTMP1
	LACK	5
	SAH	SYSTMP2

	LAC	MSG_N
	CALL	VALUE_ADD
	SAH	MSG_N
	BS	B1,MAIN_PRO9_2_1_SENDCOMM
;---------------------------------------
MAIN_PRO9_2_1_MENU:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LAC	LOCACODE1
	ANDL	0xFF0F
	SAH	LOCACODE1
	
	LAC	MSG_N
	SFL	4
	ANDL	0x0F0
	OR	LOCACODE1
	SAH	LOCACODE1
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	CCOMMOND_SETCONTRAST		;LCD 亮度
	CALL	SEND_DAT
	LAC	MSG_N
	CALL	SEND_DAT
	LACL	0X0FF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	9
	SAH	OFFSET_D
	LAC	LOCACODE1
	SFR	4
	ANDK	0x07
	CALL	STORBYTE_DAT
	
	LACK	11
	SAH	OFFSET_D
	LACL	0XFF
	CALL	STORBYTE_DAT	;以0XFF结尾
;---进入下一项
	CALL	CLR_FUNC
	LACK	0
	SAH	PRO_VAR
	
	LACL	CMENU_PSWD
	CALL	STOR_MSG

	RET
;-------------------------------------------------------------------------------
LOCAL_PROMENU3_2:
	
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROMENU3_3:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROMENU3_3_VPSTOP	;VP end
	
	RET
;---------------------------------------
LOCAL_PROMENU3_3_VPSTOP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LACK	0X005
	CALL	STOR_VP

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
;-------------------------------------------------------------------------------

.END

