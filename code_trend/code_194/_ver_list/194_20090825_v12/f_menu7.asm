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
.GLOBAL	LOCAL_PROMENU7
;-------------------------------------------------------------------------------
.LIST
.ORG    ADDR_SECOND
;-------------------------------------------------------------------------------
LOCAL_PROMENU7:				;MENU设置状态要考虑的消息(PRO_VAR)
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,MAIN_PROX_RINGIN
	
	LAC	PRO_VAR
	ANDK	0X0F
	BS	ACZ,LOCAL_PROMENU7_0	;local code
	SBHK	1
	BS	ACZ,LOCAL_PROMENU7_1	;OGM select/record/play
	SBHK	1
	BS	ACZ,LOCAL_PROMENU7_2	;End and exit
	
	RET
;-------------------------------------------------------------------------------common respond
MAIN_PRO9_VPSTOP:
	LACK	0
	SAH	PRO_VAR1		;计数器清零(按键松开后BEEP结束)	
	CALL	DAA_OFF

	RET
;---------------------------------------
MAIN_PRO9_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	30
	BZ	SGN,MAIN_PRO9_TMROVER
	
	RET
MAIN_PRO9_TMROVER:		;超时退出
	BS	B1,MAIN_PRO9_X_STOP
;-------------------------------------------------------------------------------
LOCAL_PROMENU7_0:
	LAC	MSG
	XORL	CMENU_OGMC		;Set menu OGM
	BS	ACZ,LOCAL_PROMENU7_0_MOGMC
	
	RET
;---------------------------------------
LOCAL_PROMENU7_0_MOGMC:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
	
	LAC	VOI_ATT		;LANGUAGE/OGM_ID/RING_CNT/ATT1
	SFR	8
	ANDK	0X0F
	SAH	NEW_ID		;load CURRENT VALUE(OGM_ID)
	
	LACL	0XFF00|VOP_INDEX_Announcement
	CALL	STOR_VP
	LAC	NEW_ID
	CALL	ANNOUNCE_NUM
	
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	CCOMMOND_OGMSELECT	;select OGM
	CALL	SEND_DAT
	LAC	NEW_ID
	CALL	SEND_DAT	;goto next(OGM-phone)
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	0X11
	SAH	PRO_VAR
	
	RET
;-----------------------------------------------------------
LOCAL_PROMENU7_1:			;OGM record
	LAC	PRO_VAR
	SFR	4
	ANDK	0X0F
	BS	ACZ,MAIN_PRO9_6_0	;Reserved
	SBHK	1
	BS	ACZ,MAIN_PRO9_6_1	;adjust OGM_ID
	SBHK	1
	BS	ACZ,MAIN_PRO9_6_2	;long beep before record
	SBHK	1
	BS	ACZ,MAIN_PRO9_6_3	;record OGM
	SBHK	1
	BS	ACZ,MAIN_PRO9_6_4	;playing back OGM

	RET
;-------------------------------------------------------------------------------
MAIN_PRO9_6_0:
	
	RET
;---------------------------------------
MAIN_PRO9_X_STOP:			;Save all update except OGM and exit
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

	LACK	0x02
	SAH	PRO_VAR
	
	RET
;-------------------------------------------------------------------------------
MAIN_PRO9_6_1:
	LAC	MSG
	XORL	CMSG_TMR		;TMR
	BS	ACZ,MAIN_PRO9_TMR
;MAIN_PRO9_6_1_0:	
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,MAIN_PRO9_VPSTOP	;VP end
;MAIN_PRO9_6_1_1:		
	LAC	MSG
	XORL	CMSG_KEY2S
	BS	ACZ,MAIN_PRO9_6_1_REW	;REW
;MAIN_PRO9_6_1_2:	
	LAC	MSG
	XORL	CMSG_KEY1S
	BS	ACZ,MAIN_PRO9_6_1_FFW	;FFW
;MAIN_PRO9_6_1_3:	
	LAC	MSG
	XORL	CMSG_KEY2P
	BS	ACZ,MAIN_PRO9_6_1_PREW	;REW
;MAIN_PRO9_6_1_4:	
	LAC	MSG
	XORL	CMSG_KEY1P
	BS	ACZ,MAIN_PRO9_6_1_PFFW	;FFW
;MAIN_PRO9_6_1_5:
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO9_6_1_MENU	;MENU
;MAIN_PRO9_6_1_6:
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,MAIN_PRO9_X_STOP	;STOP
;MAIN_PRO9_6_1_8:
	;LAC	MSG
	;XORL	CMSG_KEY2S
	;BS	ACZ,MAIN_PRO9_6_1_OGM
	
	RET
;---------------------------------------
MAIN_PRO9_6_1_REW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP

	LACK	1
	SAH	SYSTMP1
	LACK	3
	SAH	SYSTMP2

	LAC	NEW_ID
	CALL	VALUE_ADD
	SAH	NEW_ID

	LACL	0XFF00|VOP_INDEX_Announcement
	CALL	STOR_VP
	LAC	NEW_ID
	CALL	ANNOUNCE_NUM

	BS	B1,MAIN_PRO9_6_SAVE
MAIN_PRO9_6_1_PREW:
	LACK	1
	SAH	SYSTMP1
	LACK	3
	SAH	SYSTMP2

	LAC	NEW_ID
	CALL	VALUE_ADD
	SAH	NEW_ID

	BS	B1,MAIN_PRO9_6_SAVE
;---------------------------------------
MAIN_PRO9_6_1_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP

	LACK	1
	SAH	SYSTMP1
	LACK	3
	SAH	SYSTMP2

	LAC	NEW_ID
	CALL	VALUE_SUB
	SAH	NEW_ID
	
	LACL	0XFF00|VOP_INDEX_Announcement
	CALL	STOR_VP
	LAC	NEW_ID
	CALL	ANNOUNCE_NUM
	
	BS	B1,MAIN_PRO9_6_SAVE
MAIN_PRO9_6_1_PFFW:
	LACK	1
	SAH	SYSTMP1
	LACK	3
	SAH	SYSTMP2

	LAC	NEW_ID
	CALL	VALUE_SUB
	SAH	NEW_ID
	
	BS	B1,MAIN_PRO9_6_SAVE
;---
MAIN_PRO9_6_SAVE:

;MAIN_PRO9_6_SAVE_END:
	LAC	NEW_ID
	CALL	OGM_SELECT
;!!!!!!!!!!!!!!!!!!!!!!!!!!	
	LACL	CCOMMOND_OGMSELECT
	CALL	SEND_DAT
	LAC	NEW_ID
	ANDK	0X0F
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!
	RET
;---------------------------------------
MAIN_PRO9_6_1_OGM:		;start play OGM
	CALL	INIT_DAM_FUNC	;进入播放OGM子功能
	CALL	DAA_SPK

	LACL	0X041
	SAH	PRO_VAR
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XC3
	CALL	SEND_DAT
	LAC	NEW_ID
	ANDK	0X0F
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LAC	NEW_ID
	CALL	OGM_SELECT
	BZ	ACZ,MAIN_PRO9_6_1_END_2
	
	;CALL	VP_DEFAULTOGM
	LAC	NEW_ID
	CALL	DEFOGM_LOCALPLY		;load default OGM

	BS	B1,MAIN_PRO9_6_1_END_3
MAIN_PRO9_6_1_END_2:
	LAC	MSG_ID
	ANDL	0X0FF
	ORL	0XFE00
	CALL	STOR_VP
	
MAIN_PRO9_6_1_END_3:
	LACK	0X005
	CALL	STOR_VP

	RET
;---------------------------------------
MAIN_PRO9_6_1_MENU:		;Save all update and exit
	CALL	INIT_DAM_FUNC

	BIT	EVENT,8
	BS	TB,MAIN_PRO9_6_SAVEOGMSEL_END

	LAC	VOI_ATT
	ANDL	0XF0FF
	SAH	VOI_ATT
	
	LAC	NEW_ID
	ANDK	0X0F
	SFL	8
	OR	VOI_ATT		;LANGUAGE/OGM_ID/RING_CNT/ATT1
	SAH	VOI_ATT	
MAIN_PRO9_6_SAVEOGMSEL_END:
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
	CALL	CLR_FUNC
	LACK	0
	SAH	PRO_VAR		;goto next(OGM-phone)
	LACL	CBOOK_FLT
	CALL	STOR_MSG

	RET
;-------------------------------------------------------------------------------
MAIN_PRO9_6_2:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,MAIN_PRO9_6_2_VPSTOP	;VP end
;MAIN_PRO9_6_2_1:
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,MAIN_PRO9_6_X_IDEL		;STOP
	
	RET
;---------------------------------------
MAIN_PRO9_6_2_VPSTOP:
	CALL	INIT_DAM_FUNC

	LAC	NEW_ID
	CALL	OGM_SELECT
;-------delete the old OGM----------------	
	LAC	MSG_ID		;对应OGM存在就删除,没有对应OGM做此操作也无所谓
	ORL	0X6000
	CALL	DAM_BIOSFUNC
	CALL	GC_CHK
;---	
    	LAC	NEW_ID
	ORL	0X8D00|0X70
    	CALL	DAM_BIOSFUNC	;set user index data0"OGM_ID"

	CALL	SET_COMPS
	
	LACL	0X31
	SAH	PRO_VAR

	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER
	CALL	DAA_REC
	CALL	REC_START
;!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XC1
	CALL	SEND_DAT
	LAC	NEW_ID
	ANDK	0XF
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!
	RET
;-------------------------------------------------------------------------------
MAIN_PRO9_6_3:
	LAC	MSG
	XORL	CMSG_KEY7S		;ON/OFF
	BS	ACZ,MAIN_PRO9_6_3_END
;MAIN_PRO9_6_3_1:
	LAC	MSG
	XORL	CMSG_TMR		;TMR
	BS	ACZ,MAIN_PRO9_6_3_TMR	
;MAIN_PRO9_6_3_2:
	LAC	MSG
	XORL	CREC_FULL		;REC_FULL
	BS	ACZ,MAIN_PRO9_6_3_END
	
	RET
;---------------------------------------	
MAIN_PRO9_6_3_END:
	LAC	PRO_VAR1
	SBHK	3
	BZ	SGN,MAIN_PRO9_6_3_END_1	;大于等于3sec就保存

	LAC	CONF
	ORL	1<<11
	CALL	DAM_BIOSFUNC
MAIN_PRO9_6_3_END_1:	
	CALL	INIT_DAM_FUNC		;进入播放OGM子功能
	CALL	DAA_SPK

	LAC	NEW_ID
	ANDK	0XF
	CALL	OGM_SELECT
	BZ	ACZ,MAIN_PRO9_6_3_END_2

	;CALL	VP_DEFAULTOGM	;default OGM
	LAC	NEW_ID
	CALL	DEFOGM_LOCALPLY		;load default OGM
	
	BS	B1,MAIN_PRO9_6_3_END_3
MAIN_PRO9_6_3_END_2:	
	LAC	MSG_ID
	ANDL	0X0FF
	ORL	0XFE00
	CALL	STOR_VP
	
MAIN_PRO9_6_3_END_3:	

	LACL	0X041
	SAH	PRO_VAR
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XC3
	CALL	SEND_DAT
	LAC	NEW_ID
	ANDK	0XF
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	RET
;-------------------------------------------------------------------------------
MAIN_PRO9_6_3_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	120
	BZ	SGN,MAIN_PRO9_6_3_END
	
	RET
;-------------------------------------------------------------------------------
MAIN_PRO9_6_4:
	LACK	0
	SAH	PRO_VAR1
;MAIN_PRO9_6_4_0:
	LAC	MSG
	XORL	CMSG_KEY8S		;ERASE
	BS	ACZ,MAIN_PRO9_6_4_ERASE
;MAIN_PRO9_6_4_1:
	LAC	MSG
	XORL	CMSG_KEY7S		;ON/OFF(stop)
	BS	ACZ,MAIN_PRO9_6_X_IDEL
;MAIN_PRO9_6_4_2:
	LAC	MSG
	XORL	CVP_STOP		;play end
	BS	ACZ,MAIN_PRO9_6_X_IDEL
;MAIN_PRO9_6_4_3:
	LAC	MSG
	XORL	CMSG_KEYBP		;VOL+
	BS	ACZ,MAIN_PRO1_PLAY_VOLA
;MAIN_PRO9_6_4_4:
	LAC	MSG
	XORL	CMSG_KEYBS		;VOL+
	BS	ACZ,MAIN_PRO1_PLAY_VOLA
;MAIN_PRO9_6_4_5:
	LAC	MSG
	XORL	CMSG_KEYAP		;VOL-
	BS	ACZ,MAIN_PRO1_PLAY_VOLS
;MAIN_PRO9_6_4_6:
	LAC	MSG
	XORL	CMSG_KEYAS		;VOL-
	BS	ACZ,MAIN_PRO1_PLAY_VOLS

	RET
;---------------------------------------
MAIN_PRO9_6_4_ERASE:
	LAC	MSG_ID
	ANDL	0X0FF
	ORL	0X2080
	CALL	DAM_BIOSFUNC
	
	LACL	0X6100
	CALL	DAM_BIOSFUNC
	
	CALL	GC_CHK
MAIN_PRO9_6_X_IDEL:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BBEEP

	LACL	0X11
	SAH	PRO_VAR
	LACK	0
	SAH	PRO_VAR1
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	LACL	CCOMMOND_OGMSELECT
	CALL	SEND_DAT
	LAC	NEW_ID
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	RET
;-------------------------------------------------------------------------------
LOCAL_PROMENU7_2:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROMENU7_2_VPSTOP	;VP end
	
	RET
;---------------------------------------
LOCAL_PROMENU7_2_VPSTOP:
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

	LAC	VOP_FG
	ANDL	~(1<<15)
	SAH	VOP_FG
	
	CALL	BLED_ON
	LACL	CMSG_INIT
	CALL	STOR_MSG
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
MAIN_PRO1_PLAY_VOLA:
	
	LACL	CMSG_VOLA
	CALL	STOR_MSG

	RET

MAIN_PRO1_PLAY_VOLS:
	
	LACL	CMSG_VOLS
	CALL	STOR_MSG

	RET

;=========================================================================
	
.END

