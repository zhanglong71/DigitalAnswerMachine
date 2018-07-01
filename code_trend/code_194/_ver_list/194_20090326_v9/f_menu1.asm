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
.GLOBAL	LOCAL_PROMENU1
;-------------------------------------------------------------------------------
.LIST
.ORG    ADDR_SECOND
;-------------------------------------------------------------------------------
LOCAL_PROMENU1:				;MENU设置状态要考虑的消息(PRO_VAR)
.IF	1	
	LAC	MSG
	XORL	CMSG_KEY2S
	BS	ACZ,LOCAL_PROMENU1_2_REW	;REW
	LAC	MSG
	XORL	CMSG_KEY1S
	BS	ACZ,LOCAL_PROMENU1_2_FFW	;FFW
	LAC	MSG
	XORL	CMSG_KEY2P
	BS	ACZ,LOCAL_PROMENU1_2_PREW	;REW
	LAC	MSG
	XORL	CMSG_KEY1P
	BS	ACZ,LOCAL_PROMENU1_2_PFFW	;FFW
.ENDIF
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,LOCAL_PROMENU1_RING
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PROMENU1_TMR		;TMR
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROMENU1_VPSTOP	;VP end
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,LOCAL_PROMENU1_STOP	;STOP

	LAC	PRO_VAR
	ANDK	0X0F
	BS	ACZ,LOCAL_PROMENU1_0	;local-idle to adjust
	SBHK	1
	BS	ACZ,LOCAL_PROMENU1_1	;wait for'MENU'key release
	SBHK	1
	BS	ACZ,LOCAL_PROMENU1_2	;language adjust
	SBHK	1
	BS	ACZ,LOCAL_PROMENU1_3	;wait(Wait for "MENU" key released then goto adjust time)
	
	RET
;---------------------------------------common respond
LOCAL_PROMENU1_0:
	LAC	MSG
	XORL	CMENU_LGGE
	BS	ACZ,LOCAL_PROMENU1_0_LANGUAGE
	
	RET
;---------------------------------------
LOCAL_PROMENU1_0_LANGUAGE:
	CALL	BLED_ON
	
	LAC	VOP_FG
	ANDL	0X0FF
	BS	ACZ,LOCAL_PROMENU1_2_MENU_NOLANG	;没有语言选择项

	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
		
	LAC	VOP_FG
	ORL	1<<15
	SAH	VOP_FG
;---语言选择	
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	CCOMMOND_LANGUAGE	;COMMAND = 0X90
	CALL	SEND_DAT
	LAC	VOI_ATT		;LANGUAGE/OGM_ID/RING_CNT/ATT1
	SFR	12
	ANDK	0X03
	SAH	MSG_N		;CURRENT VALUE
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	BLED_ON

	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER		;打开定时,按键清零,超时退出	
;---发送菜单命令---语言选择
	LACK	0X01
	SAH	PRO_VAR
;---从Flash读出一些参数
	LACK	CGROUP_DATT
	CALL	SET_TELGROUP
	CALL	GET_TELT
	SAH	MSG_ID
	
	LACL	TEL_RAM
	SAH	ADDR_D		;保存地址(在菜单调节部分不能修改)
	SAH	ADDR_S		;提取地址(在菜单调节部分不能修改)
	LACK	0
	SAH	OFFSET_D	;保存地址
	LAC	MSG_ID		;条目号
	CALL	READ_TELNUM	;读当前条目数据
	CALL	STOPREADDAT

	RET
;-------------------------------------------------------------------------------
LOCAL_PROMENU1_VPSTOP:
	LACK	0
	SAH	PRO_VAR1		;计数器清零(按键松开后BEEP结束)	
	CALL	DAA_OFF

	RET
;-------------------------------------------------------------------------------
LOCAL_PROMENU1_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	30
	BZ	SGN,LOCAL_PROMENU1_TMROVER
	
	RET
LOCAL_PROMENU1_TMROVER:		;超时退出
	BS	B1,LOCAL_PROMENU1_STOP
;-----------------------------------------------------------
LOCAL_PROMENU1_2_MENU:		;保存后进入下一项
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LAC	VOI_ATT
	ANDL	0XCFFF
        SAH	VOI_ATT
	LAC	MSG_N
	SFL	12
	OR	VOI_ATT
	SAH	VOI_ATT		;dsp SAVE language set
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	CALL	SENDLANGUAGE	;mcu SAVE
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;---
	LACL	TEL_RAM
	SAH	ADDR_D
	LACK	10
	SAH	OFFSET_D
	LAC	VOI_ATT
	SFR	12
	ANDK	0x03
	CALL	STORBYTE_DAT
	
	LACK	11
	SAH	OFFSET_D
	LACL	0XFF
	CALL	STORBYTE_DAT	;以0XFF结尾
;---
	LACK	CGROUP_DATT
	CALL	SET_TELGROUP
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
;---Next function
	CALL	CLR_FUNC
	LACK	0X0
	SAH	PRO_VAR
	LACL	CMENU_TIME
	CALL	STOR_MSG
	
	RET
;---------------------------------------
LOCAL_PROMENU1_2_MENU_NOLANG:	;No language select then wait for key release and goto next adjust
	CALL	INIT_DAM_FUNC

	LAC	VOP_FG
	ORL	1<<15
	SAH	VOP_FG

	CALL	CLR_FUNC
	LACK	0X0
	SAH	PRO_VAR
	SAH	PRO_VAR1
	LACL	CMENU_TIME
	CALL	STOR_MSG
;---从Flash读出一些参数
	LACK	CGROUP_DATT
	CALL	SET_TELGROUP
	CALL	GET_TELT
	SAH	MSG_ID
	
	LACL	TEL_RAM
	SAH	ADDR_D		;保存地址(在菜单调节部分不能修改)
	SAH	ADDR_S		;提取地址(在菜单调节部分不能修改)
	LACK	0
	SAH	OFFSET_D	;保存地址
	LAC	MSG_ID		;条目号
	CALL	READ_TELNUM	;读当前条目数据
	CALL	STOPREADDAT
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROMENU1_1:
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,LOCAL_PROMENU1_1_MENU	;MENU

	RET
LOCAL_PROMENU1_1_MENU:
	LACK	0X02
	SAH	PRO_VAR
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROMENU1_2:
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,LOCAL_PROMENU1_2_MENU	;MENU
;LOCAL_PROMENU1_2_6:
	
	RET

;-------respond9-0-1(language)	
LOCAL_PROMENU1_2_REW:	
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
LOCAL_PROMENU1_2_PREW:
	LACK	0
	SAH	SYSTMP1
	LACK	3
	SAH	SYSTMP2

	LAC	MSG_N
	CALL	VALUE_ADD
	SAH	MSG_N
	CALL	LANG_CHK
	BS	ACZ,LOCAL_PROMENU1_2_PREW	;Check if current Language not exist, get next one
	
LOCAL_PROMENU1_2_SENDCOMM:
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	CCOMMOND_LANGUAGE	;COMMAND = 0X90
	CALL	SEND_DAT
	LAC	MSG_N
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	RET
;---------------------------------------
LOCAL_PROMENU1_2_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
LOCAL_PROMENU1_2_PFFW:
	LACK	0
	SAH	SYSTMP1
	LACK	3
	SAH	SYSTMP2

	LAC	MSG_N
	CALL	VALUE_SUB
	SAH	MSG_N
	CALL	LANG_CHK
	BS	ACZ,LOCAL_PROMENU1_2_PFFW	;Check if current Language not exist, get next one
	
	BS	B1,LOCAL_PROMENU1_2_SENDCOMM
;-------------------------------------------------------------------------------
LOCAL_PROMENU1_3:
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,LOCAL_PROMENU1_3_MENU	;MENU
	
	RET
;---------------------------------------
LOCAL_PROMENU1_3_MENU:
	CALL	INIT_DAM_FUNC
;---Next function
	CALL	CLR_FUNC
	LACK	0X0
	SAH	PRO_VAR
	LACL	CMENU_TIME
	CALL	STOR_MSG
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROMENU1_STOP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BBEEP		;BB
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	CALL	SENDLANGUAGE	;mcu SAVE
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LAC	VOP_FG
	ANDL	~(1<<15)
	SAH	VOP_FG
		
	CALL	CLR_FUNC
	LACK	0
	SAH	PRO_VAR
;!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	LACL	0X9E		;exit COMMAND = 0X9E+6
	CALL	SEND_DAT
	LACK	6
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!

	RET
;-------------------------------------------------------------------------------
LOCAL_PROMENU1_RING:
	CALL	INIT_DAM_FUNC
	CALL	CLR_FUNC
	LACK	0
	SAH	PRO_VAR
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
	LACL	0xFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	
	RET

;-------------------------------------------------------------------------------
;	Funtion : transmit the address of bit=1 to messages
;	input : ACCH = The bit number that you will check
;		VOP_FG(7..0) = The data you will check
;	output: ACCH = the value you checked 
;	查VOP_FG的(数字对应)位是否是1
;-------------------------------------------------------------------------------
LANG_CHK:
	ANDK	0X03		;2bit
	BS	ACZ,LANG_CHK_END0	;无调节项
	SAH	SYSTMP0	
	
	LAC	VOP_FG
	ANDK	0X7F
	SAH	SYSTMP1		;计数
LANG_CHK_LOOP:
	LAC	SYSTMP0
	SBHK	1
	SAH	SYSTMP0
	BS	ACZ,LANG_CHK_END
	
	LAC	SYSTMP1
	SFR	1
	SAH	SYSTMP1
	BS	B1,LANG_CHK_LOOP
LANG_CHK_END:
	LAC	SYSTMP1
	ANDK	0X01
	RET
LANG_CHK_END0:
	LACK	1
	
	RET

;===============================================================================
	
.END

