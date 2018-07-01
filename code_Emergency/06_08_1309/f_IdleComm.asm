.NOLIST
;---------------------------------------
.INCLUDE	include.inc
;---------------------------------------
;-------------------------------------------------------------------------------
.GLOBAL	UPDATE_FLASHDATA
.GLOBAL	IDLE_COMMAND
;-------------------------------------------------------------------------------
.EXTERN	GetOneConst	;(INPUT=ACCH(ProgramRamAddress),OUTPUT=ACCH(ReadData))
.EXTERN	GetMoreConst	;(INPUT=ACCH(ProgramRamStartingAddress)ACCL(ReadWordNumber)AR1(StoreDataRamAddress),OUTPUT=)
;-------------------
.LIST
;-------------------------------------------------------------------------------
.ORG	ADDR_SECOND
;-------------------------------------------------------------------------------
IDLE_COMMAND:
	CALL	GETR_DAT
	SBHK	0X40
	SAH	MSG
;---make sure the value [0x40 - 0x8F]
	LAC	MSG
	BS	SGN,IDLE_CMD_OVER		;0x00<= x <0x40
	SBHK	0X4F
	BZ	SGN,IDLE_CMD_OVER		;0x8F<= x --
;---	
	LAC	MSG
	ADHL	COMMAND_TAB
	CALL	GetOneConst
	ADHK	0
	BACC		;jump to ...
;---------------------------------------
IDLE_CMD_OVER:
	RET

;---------------------------------------
IDLE_COMMAND_0X41:
	LACL	CMSG_PLY	;play message
	CALL	STOR_MSG

	BS	B1,IDLE_CMD_OVER
;---------------
IDLE_COMMAND_0X46:
	LACL	CREC_MEMO	;record MEMO
	CALL	STOR_MSG

	BS	B1,IDLE_CMD_OVER
;---------------
IDLE_COMMAND_0X47:
	LACL	CREC_2WAY	;record 2way
	CALL	STOR_MSG

	BS	B1,IDLE_CMD_OVER
;---------------
IDLE_COMMAND_0X48:
	LAC	EVENT
	ANDL	~(1<<9)
	SAH	EVENT		;Set ANS-on fisrt

	CALL	GETR_DAT
	ANDK	0X07F
	BS	ACZ,IDLE_CMD_OVER
	
	LAC	EVENT		;ANS-off
	ORL	1<<9
	SAH	EVENT

	BS	B1,IDLE_CMD_OVER
;---------------
IDLE_COMMAND_0X49:
	LAC	EVENT
	ANDL	~(1<<8)
	SAH	EVENT		;Set OGM1 first
	
	CALL	GETR_DAT
	ANDL	0X0FF
	SBHK	1
	BS	ACZ,IDLE_CMD_OVER
	
	LAC	EVENT
	ORL	1<<8
	SAH	EVENT		;Not OGM1, set OGM2
	BS	B1,IDLE_CMD_OVER
;---------------
IDLE_COMMAND_0X4A:		;Play OGM
	LACL	CPLY_OGM
	CALL	STOR_MSG
	
	LAC	ANN_FG
	ANDL	~(1<<8)
	SAH	ANN_FG
	
	CALL	GETR_DAT
	ANDK	0X007
	SBHK	1
	BS	ACZ,IDLE_CMD_OVER

	LAC	ANN_FG
	ORL	1<<8
	SAH	ANN_FG
	BS	B1,IDLE_CMD_OVER
;---------------------------------------
IDLE_COMMAND_0X4B:		;record OGM
	LACL	CREC_OGM
	CALL	STOR_MSG
	
	LAC	ANN_FG
	ANDL	~(1<<8)
	SAH	ANN_FG
	
	CALL	GETR_DAT
	ANDK	0X007
	SBHK	1
	BS	ACZ,IDLE_CMD_OVER
	
	LAC	ANN_FG
	ORL	1<<8
	SAH	ANN_FG
	BS	B1,IDLE_CMD_OVER
;---------------
IDLE_COMMAND_0X4D:	
	LACL	COLD_ERAS	;erase all old messages
	CALL	STOR_MSG
	BS	B1,IDLE_CMD_OVER
;---------------
IDLE_COMMAND_0X4F:
	BS	B1,IDLE_CMD_OVER
;---------------
IDLE_COMMAND_0X50:	;00/01/02/03 - spk-off
	CALL	GETR_DAT
	SAH	SYSTMP0
	
	LAC	EVENT
	ORK	(1<<2)
	SAH	EVENT			;Set mute on first
	
	BIT	SYSTMP0,0
	BS	TB,IDLE_COMMAND_0X50_1	;Check mute status
	
	LAC	EVENT
	ANDL	~(1<<2)
	SAH	EVENT
	
IDLE_COMMAND_0X50_1:
	LACL	CHF_WORK
	
	BIT	SYSTMP0,0
	BS	TB,IDLE_COMMAND_0X50_2	;Check Speaker status
	
	LACL	CHF_IDLE
	
IDLE_COMMAND_0X50_2:
	CALL	STOR_MSG
	
	BS	B1,IDLE_CMD_OVER
;-----------------------------------------------------------
IDLE_COMMAND_0X51:

	CALL	GETR_DAT
	ANDK	0X07
	BS	ACZ,IDLE_COMMAND_0X510X00
	SBHK	1
	BS	ACZ,IDLE_COMMAND_0X510X01
	BS	B1,IDLE_CMD_OVER
IDLE_COMMAND_0X510X00:		;hook-on
	LACL	CHS_IDLE
	CALL	STOR_MSG
	BS	B1,IDLE_CMD_OVER	;excute immediately
IDLE_COMMAND_0X510X01:		;hook-off
	LACL	CHS_WORK
	CALL	STOR_MSG
	
	BS	B1,IDLE_CMD_OVER
;-----------------------------------------------------------
TAB_COMMAND_0X52:
.data	COMMAND_0X520X00	;Save book0
.data	COMMAND_0X520X01	;Save M1
.data	COMMAND_0X520X02	;Save M2
.data	COMMAND_0X520X03	;Save M3
;---------------------------------------
IDLE_COMMAND_0X52:		;save phonebook-TEL into flash
	CALL	INIT_DAM_FUNC

	CALL	GETR_DAT
	ANDK	0X03
	ADHL	TAB_COMMAND_0X52
	CALL	GetOneConst
	;ADHK	0
	BACC		;jump to ...
;---------------------------------------	
COMMAND_0X520X00:
	LACK	CGROUP_PBOOK
	CALL	SET_TELGROUP

	LACL	CidData
	SAH	ADDR_S
	CALL	COMP_ALLTELNUM			;从电话本中找有相同号码的条目
	BS	ACZ,LOCAL_PROTEL_SAVEBOOK_0_1	;电话本里没有找到相同号码的条目,直接开始比较CID
	SAH	SYSTMP1
	CALL	DEL_ONETEL			;删除找到的号码
	CALL	TEL_GC_CHK
LOCAL_PROTEL_SAVEBOOK_WRITE:
;---------------------------------------
	LACL	CidData
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	LACK	57
	SAH	COUNT

	CALL	TELNUM_WRITE
	;CALL	DAT_WRITE_STOP
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	GET_TELT
	CALL	SEND_PBOOK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	;CALL	LINE_START

	RET
LOCAL_PROTEL_SAVEBOOK_0_1:
	CALL	GET_TELT
	SBHK	CMAX_PBOOK	;The MAX. number of Phone-book
	BS	SGN,LOCAL_PROTEL_SAVEBOOK_EXE
;---CMAX_PBOOK TEL exist,delete oldest one
	LACK	1
	CALL	DEL_ONETEL
	CALL	TEL_GC_CHK
LOCAL_PROTEL_SAVEBOOK_EXE:

	BS	B1,LOCAL_PROTEL_SAVEBOOK_WRITE
;---------------------------------------
COMMAND_0X520X01:
	LACK	CGROUP_M1
	CALL	SET_TELGROUP
	BS	B1,LOCAL_PROTEL_DELOLD
COMMAND_0X520X02:
	LACK	CGROUP_M2
	CALL	SET_TELGROUP
	BS	B1,LOCAL_PROTEL_DELOLD
COMMAND_0X520X03:
	LACK	CGROUP_M3
	CALL	SET_TELGROUP
	;BS	B1,LOCAL_PROTEL_DELOLD
LOCAL_PROTEL_DELOLD:
;---Delete old first
	CALL	GET_TELT
	SBHK	1
	BS	SGN,LOCAL_PROTEL_SAVETEL	;All old TEL deleted
;---more than 1	
	LACk	1		;delete old one,Make sure only one TEL exist
	CALL	DEL_ONETEL
	CALL	TEL_GC_CHK
	BS	B1,LOCAL_PROTEL_DELOLD
LOCAL_PROTEL_SAVETEL:	
;---Save new TEL
	LACL	CidData
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	LACK	57
	SAH	COUNT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	TELNUM_WRITE
	;CALL	DAT_WRITE_STOP
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	;LAC	OGM_ID		;
	;CALL	SET_TELUSRID1
	
	;CALL	LINE_START
	
	BS	B1,IDLE_CMD_OVER
;-----------------------------------------------------------
IDLE_COMMAND_0X54:	;stop
	LACL	CMSG_EXIT	;stop
	CALL	STOR_MSG
	BS	B1,IDLE_CMD_OVER
;-----------------------------------------------------------
IDLE_COMMAND_0X56:	;find new call, find CID with specific TEL-ID
	CALL	INIT_DAM_FUNC
	
	CALL	GETR_DAT
	SAH	MSG

	LACK	CGROUP_CID
	CALL	SET_TELGROUP
	
	LAC	MSG
	BS	ACZ,IDLE_COMMAND_0X56_END
	BS	SGN,IDLE_COMMAND_0X56_END
	
	CALL	GET_TELT
	ADHK	1
	SBH	MSG
	SAH	MSG_ID		;查找时将倒序进行
	BS	ACZ,IDLE_COMMAND_0X56_END
	BS	SGN,IDLE_COMMAND_0X56_END
;---Read TEL with specified TEL-ID
	LACL	CidData
	SAH	ADDR_D
	LACK	0
	SAH	OFFSET_D
	
	LAC	MSG_ID
	CALL	DAT_READ
;--Read New flag 
	LACL	CidData
	SAH	ADDR_D
	LACK	57
	SAH	OFFSET_D

	LAC	MSG_ID
	CALL	GET_TELUSRID1
	CALL	STORBYTE_DAT
;---Set New flag(0)
	LAC	MSG_ID		;Set index-1 = 0(new flag)
	;ORL	0X0000
	CALL	SET_TELUSRID1
;---!!!!!将号码返回送给MCU
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;---total
	CALL	GET_TELT
	CALL	SEND_TOTALCID
;---new 
	CALL	GET_TELN
	CALL	SEND_NEWCID
	
	LACK	5
	CALL	DELAY	
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;---
	LACL	CidData
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	LACK	58
	SAH	COUNT

	CALL	SEND_TEL
	LACK	0X04		;tell MCU:MCU searched TEL-number send ok
	CALL	SEND_TELOK
;---
IDLE_COMMAND_0X56_END:
	BS	B1,IDLE_CMD_OVER
;-----------------------------------------------------------
IDLE_COMMAND_0X57:	;find answered call
	CALL	GETR_DAT
	SAH	MSG

	CALL	INIT_DAM_FUNC
	
	;LACK	CGROUP_ANSWCID
	CALL	SET_TELGROUP
	
	LAC	MSG
	BS	ACZ,IDLE_COMMAND_0X57_END
	BS	SGN,IDLE_COMMAND_0X57_END
	
	CALL	GET_TELT
	ADHK	1
	SBH	MSG
	SAH	MSG_ID		;查找时将倒序进行
	BS	ACZ,IDLE_COMMAND_0X57_END
	BS	SGN,IDLE_COMMAND_0X57_END

;---Read TEL with specified TEL-ID
	LACL	CidData
	SAH	ADDR_D
	LACK	0
	SAH	OFFSET_D
	
	LAC	MSG_ID
	CALL	DAT_READ
;--Ignore New flag 
	LACL	CidData
	SAH	ADDR_D
	LACK	57
	SAH	OFFSET_D
	LACK	0
	CALL	STORBYTE_DAT
;---!!!!!将号码返回送给MCU
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;---total
	CALL	GET_TELT
	;CALL	SEND_ANSWCID
	
	LACK	5
	CALL	DELAY	
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;---
	LACL	CidData
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	LACK	58
	SAH	COUNT

	CALL	SEND_TEL
	LACK	0X04	;tell MCU:MCU searched TEL-number send ok
	CALL	SEND_TELOK
;---
IDLE_COMMAND_0X57_END:
	BS	B1,IDLE_CMD_OVER
;---------------------------------------
IDLE_COMMAND_0X58:	;find dialed call with specific TEL-ID
	CALL	INIT_DAM_FUNC
	
	CALL	GETR_DAT
	SAH	MSG

	LACK	CGROUP_DIAL
	CALL	SET_TELGROUP
	
	LAC	MSG
	BS	ACZ,IDLE_COMMAND_0X58_END	;非法序号
	BS	SGN,IDLE_COMMAND_0X58_END	;非法序号
.if	1	
	CALL	GET_TELT
	ADHK	1
	SBH	MSG
	SAH	MSG_ID		;查找时将倒序进行
.else
	LAC	MSG
	SAH	MSG_ID
.endif	
	LAC	MSG_ID
	BS	ACZ,IDLE_COMMAND_0X58_END	;非法序号
	BS	SGN,IDLE_COMMAND_0X58_END	;非法序号
;---Read TEL with specified TEL-ID
	LACL	CidData
	SAH	ADDR_D
	LACK	0
	SAH	OFFSET_D
		
	LAC	MSG_ID
	CALL	DAT_READ
;---!!!!!将号码返回送给MCU
	LACL	CidData
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	LACK	58
	SAH	COUNT

	CALL	SEND_TEL
	LACK	0X04	;tell MCU:MCU searched TEL-number send ok
	CALL	SEND_TELOK
;---
IDLE_COMMAND_0X58_END:
	BS	B1,IDLE_CMD_OVER
;-----------------------------------------------------------
IDLE_COMMAND_0X59:	;find phonebook with specific TEL-ID
	CALL	INIT_DAM_FUNC

	CALL	GETR_DAT
	SAH	MSG

	LACK	CGROUP_PBOOK
	CALL	SET_TELGROUP
	
	CALL	GET_TELT
	SBH	MSG
	BS	SGN,IDLE_COMMAND_0X59_END	;check if vaild TEL-ID(the number of total TEL must greater than TEL-ID)
;---读出指定的条目,并放到指定的位置
	LACL	CidData
	SAH	ADDR_D
	LACK	0
	SAH	OFFSET_D
			
	LAC	MSG
	SAH	MSG_ID
	CALL	DAT_READ
;---!!!!!将号码返回送给MCU
	LACL	CidData
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	LACK	58
	SAH	COUNT

	CALL	SEND_TEL
	LACK	0X04		;tell MCU:MCU searched TEL-number send ok
	CALL	SEND_TELOK
;---
IDLE_COMMAND_0X59_END:
;---
	BS	B1,IDLE_CMD_OVER
;-----------------------------------------------------------
IDLE_COMMAND_0X5A:		;find phonebook-TEL with specific TEL-NUM
	CALL	INIT_DAM_FUNC
	
	LACK	CGROUP_PBOOK
	CALL	SET_TELGROUP

	CALL	COMP_ALLTELNUM			;从电话本中找到有相同号码的条目
	BS	ACZ,IDLE_COMMAND_0X5A_END	;电话本里没有找到相同号码的条目,直接开始比较CID
	SAH	SYSTMP1
;---读出比较得到的条目,将收到的CID覆盖
	LACL	CidData
	SAH	ADDR_D
	LACK	0
	SAH	OFFSET_D
	LAC	SYSTMP1
	CALL	DAT_READ
IDLE_COMMAND_0X5A_END:		;---!!!!!将号码返回送给MCU
	LACL	CidData
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	LACK	58
	SAH	COUNT
	CALL	SEND_TEL
	LACK	0X04	;tell MCU:MCU searched TEL-number send ok
	CALL	SEND_TELOK
	
	CALL	LINE_START

	BS	B1,IDLE_CMD_OVER
;-----------------------------------------------------------
IDLE_COMMAND_0X5B:	;save dialed-TEL into flash
	CALL	INIT_DAM_FUNC
	LACK	CGROUP_DIAL
	CALL	SET_TELGROUP
	
	CALL	GET_TELT
	SBHK	CMAX_DIALCID	;The MAX. number off miss-CID
	BS	SGN,IDLE_COMMAND_0X5B_EXE
;---CMAX_DIALCID TEL exist,delete oldest one
	LACK	1
	CALL	DEL_ONETEL
	CALL	TEL_GC_CHK
IDLE_COMMAND_0X5B_EXE:
;---------------------------------------
	LACL	CidData
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	LACK	58
	SAH	COUNT

	CALL	TELNUM_WRITE
	;CALL	DAT_WRITE_STOP
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!		
	CALL	GET_TELT
	CALL	SEND_DIALCID
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	LINE_START
	
	BS	B1,IDLE_CMD_OVER
;-----------------------------------------------------------
IDLE_COMMAND_0X5C:	;delete CID with specific TEL-ID
	CALL	GETR_DAT
	SAH	MSG
;!!!
	LACK	1		;Tell MCU:DSP busy
	CALL	SEND_DSPSTAT
;!!!
	CALL	INIT_DAM_FUNC
	LACK	CGROUP_CID
	CALL	SET_TELGROUP
	
	LAC	MSG
	BS	ACZ,IDLE_COMMAND_0X5C_1
	
	CALL	GET_TELT
	ADHK	1
	SBH	MSG
	SAH	MSG_ID		;删除时将倒序进行
	CALL	DEL_ONETEL
IDLE_COMMAND_0X5C_END:
	CALL	TEL_GC_CHK
;!!!!!!!!!!!!!!!
;!!!
	LACK	0		;Tell MCU:DSP idle
	CALL	SEND_DSPSTAT
;!!!
;---total cid
	LACK	CGROUP_CID
	CALL	SET_TELGROUP
	CALL	GET_TELT
	CALL	SEND_TOTALCID
;---new cid
	CALL	GET_TELN
	CALL	SEND_NEWCID
;!!!!!!!!!!!!!!!
	CALL	LINE_START

	RET
IDLE_COMMAND_0X5C_1:
	CALL	GET_TELT
	BS	ACZ,IDLE_COMMAND_0X5C_END
	LACK	1
	CALL	DEL_ONETEL
	
	BS	B1,IDLE_COMMAND_0X5C_1
;-----------------------------------------------------------
IDLE_COMMAND_0X5D:	;delete CID with specific TEL-ID
	CALL	GETR_DAT
	SAH	MSG
;!!!
	LACK	1		;Tell MCU:DSP busy
	CALL	SEND_DSPSTAT
;!!!
	CALL	INIT_DAM_FUNC
	;LACK	CGROUP_ANSWCID
	CALL	SET_TELGROUP
	
	LAC	MSG
	BS	ACZ,IDLE_COMMAND_0X5D_1
	
	CALL	GET_TELT
	ADHK	1
	SBH	MSG
	SAH	MSG_ID		;删除时将倒序进行
	CALL	DEL_ONETEL
IDLE_COMMAND_0X5D_END:
	CALL	TEL_GC_CHK
;!!!!!!!!!!!!!!!
;!!!
	LACK	0		;Tell MCU:DSP idle
	CALL	SEND_DSPSTAT
;!!!
;---total Answered cid
	;LACK	CGROUP_ANSWCID
	CALL	SET_TELGROUP
	CALL	GET_TELT
	;CALL	SEND_ANSWCID
;!!!!!!!!!!!!!!!
	CALL	LINE_START

	RET
IDLE_COMMAND_0X5D_1:
	CALL	GET_TELT
	BS	ACZ,IDLE_COMMAND_0X5D_END
	LACK	1
	CALL	DEL_ONETEL
	
	BS	B1,IDLE_COMMAND_0X5D_1	
;-----------------------------------------------------------
IDLE_COMMAND_0X5E:		;delete dialed-TEL with specific TEL-ID
	CALL	GETR_DAT
	SAH	MSG
;!!!
	LACK	1		;Tell MCU:DSP busy
	CALL	SEND_DSPSTAT
;!!!
	CALL	INIT_DAM_FUNC
	LACK	CGROUP_DIAL
	CALL	SET_TELGROUP

	LAC	MSG
	BS	ACZ,IDLE_COMMAND_0X5E_1
	BS	SGN,IDLE_COMMAND_0X5E_1
.if	1	
	CALL	GET_TELT
	ADHK	1
	SBH	MSG
	SAH	MSG_ID		;删除时将倒序进行
.else
	LAC	MSG
	SAH	MSG_ID
.endif	
	LAC	MSG_ID
	BS	ACZ,IDLE_COMMAND_0X5E_1
	BS	SGN,IDLE_COMMAND_0X5E_1

	LAC	MSG_ID	
	CALL	DEL_ONETEL
IDLE_COMMAND_0X5E_END:
	CALL	TEL_GC_CHK
;!!!
	LACK	0		;Tell MCU:DSP idle
	CALL	SEND_DSPSTAT
;!!!
	CALL	GET_TELT
	CALL	SEND_DIALCID
	CALL	LINE_START
	
	RET
IDLE_COMMAND_0X5E_1:
	CALL	GET_TELT
	BS	ACZ,IDLE_COMMAND_0X5E_END
	LACK	1
	CALL	DEL_ONETEL
	BS	B1,IDLE_COMMAND_0X5E_1
;-----------------------------------------------------------
IDLE_COMMAND_0X5F:	;delete phonebook with specific TEL-ID
	CALL	GETR_DAT
	SAH	MSG
;!!!
	LACK	1		;Tell MCU:DSP busy
	CALL	SEND_DSPSTAT
;!!!
	CALL	INIT_DAM_FUNC
	LACK	CGROUP_PBOOK
	CALL	SET_TELGROUP

	LAC	MSG
	BS	ACZ,IDLE_COMMAND_0X5F_1
	CALL	DEL_ONETEL

IDLE_COMMAND_0X5F_END:
	CALL	TEL_GC_CHK
;!!!
	LACK	0		;Tell MCU:DSP idle
	CALL	SEND_DSPSTAT
;!!!
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	GET_TELT
	CALL	SEND_PBOOK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	LINE_START

	RET
IDLE_COMMAND_0X5F_1:	;Del all phonebook
	CALL	GET_TELT
	BS	ACZ,IDLE_COMMAND_0X5F_END
	LACK	1
	CALL	DEL_ONETEL
	
	BS	B1,IDLE_COMMAND_0X5F_1
;-----------------------------------------------------------
TAB_COMMAND_0X60:
.data	BEEP
.data	BBEEP
.data	LBEEP
.data	BEEP
;-------------------	
IDLE_COMMAND_0X60:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
		
	CALL	GETR_DAT
	ANDK	0X03
	ADHL	TAB_COMMAND_0X60
	CALL	GetOneConst
	CALA			;load beep/bbeep/lbeep
	BS	B1,IDLE_CMD_OVER
;-----------------------------------------------------------
IDLE_COMMAND_0X61:
	BS	B1,IDLE_CMD_OVER
;-----------------------------------------------------------
IDLE_COMMAND_0X62:
	BS	B1,IDLE_CMD_OVER
;-----------------------------------------------------------
IDLE_COMMAND_0X63:
	BS	B1,IDLE_CMD_OVER
;-----------------------------------------------------------
IDLE_COMMAND_0X64:
	BS	B1,IDLE_CMD_OVER
;-----------------------------------------------------------
IDLE_COMMAND_0X65:
	BS	B1,IDLE_CMD_OVER
;-----------------------------------------------------------
IDLE_COMMAND_0X66:
	BS	B1,IDLE_CMD_OVER
;-----------------------------------------------------------
IDLE_COMMAND_0X6B:
	CALL	GETR_DAT
	ANDK	0X7F
	BS	ACZ,IDLE_COMMAND_0X6B0X00
	BS	B1,IDLE_CMD_OVER
IDLE_COMMAND_0X6B0X00:
	LACL	CTMODE_IN	;enter test mode
	CALL	STOR_MSG
	BS	B1,IDLE_CMD_OVER
;-----------------------------------------------------------
IDLE_COMMAND_0X7F:	;Write new data into flash
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	
	LACK	CGROUP_DATT
	CALL	SET_TELGROUP
;!!!
	LACK	1		;Tell MCU:DSP busy
	CALL	SEND_DSPSTAT
;!!!
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
.if	1
LOCAL_PROTEL_DAMUPDATE_1:
	CALL	GET_TELT
	SBHK	1
	BS	SGN,LOCAL_PROTEL_DAMUPDATE_END
;---2 or more ATT,then delete old one
	LACK	1
	CALL	DEL_ONETEL	;删除找到的号码

	;BS	B1,LOCAL_PROTEL_DAMUPDATE_1
LOCAL_PROTEL_DAMUPDATE_END:
	CALL	TEL_GC_CHK
	CALL	DAM_ATT_WRITE
	;CALL	DAT_WRITE_STOP
.endif
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;!!!
	LACK	0		;Tell MCU:DSP idle
	CALL	SEND_DSPSTAT
;!!!	
	LACK	0
	SAH	PRO_VAR
	
	CALL	INIT_DAM_FUNC

	LACL	CTMR1S
	CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1
	
	CALL	LINE_START

	BS	B1,IDLE_CMD_OVER
;-----------------------------------------------------------
IDLE_COMMAND_0X80:	;
;---
	LACL	CidData
	SAH	ADDR_D
	LACK	0		;the offset of Repeat-Byte
	SAH	OFFSET_D
	
	LACL	0X80
	CALL	STORBYTE_DAT
	
	LACK	1
	SAH	OFFSET_D
	LACK	57
	SAH	COUNT		;Save 57+1 Bytes
SYS_SER_RUN_0X80_MOVE:	
	CALL	GETR_DAT
	CALL	STORBYTE_DAT

	LAC	COUNT
	SBHK	1
	SAH	COUNT		;the counter of remain
	BZ	ACZ,SYS_SER_RUN_0X80_MOVE
;-------
	BS	B1,IDLE_CMD_OVER
;-------------------------------------------------------------------------------
UPDATE_FLASHDATA:
	RET
;-------------------------------------------------------------------------------

.INCLUDE	l_beep/l_lbeep.asm

.INCLUDE	l_iic/l_getrqueue.asm
.INCLUDE	l_iic/l_storsqueue.asm
.INCLUDE	l_iic/l_pbook.asm
.INCLUDE	l_iic/l_cid.asm
.INCLUDE	l_iic/l_telok.asm
.INCLUDE	l_iic/l_dialcid.asm
.INCLUDE	l_iic/l_dspstatus.asm

.INCLUDE	l_math/l_dgthex.asm
.INCLUDE	l_math/l_hexdgt.asm
.INCLUDE	l_math/l_increase.asm
.INCLUDE	l_math/l_decrease.asm

.INCLUDE	l_move/l_stordata.asm
.INCLUDE	l_move/l_getdata.asm
.INCLUDE	l_move/l_dumpiic_tel.asm
.INCLUDE	l_move/l_moveiic_tel.asm

.INCLUDE	l_table/l_commandtable_idle.asm

.INCLUDE	l_tel/l_newtel.asm
.INCLUDE	l_tel/l_alltel.asm
.INCLUDE	l_tel/l_damatt.asm
;.INCLUDE	l_tel/l_tel_gcchk.asm
;.INCLUDE	l_tel/l_tel_read.asm
.INCLUDE	l_tel/l_tel_write.asm
.INCLUDE	l_tel/l_tel_tag.asm
.INCLUDE	l_tel/l_write.asm
.INCLUDE	l_tel/l_group.asm
.INCLUDE	l_tel/l_compare.asm
.INCLUDE	l_tel/l_del.asm
.INCLUDE	l_tel/l_read.asm


;-------------------------------------------------------------------------------
.END
	