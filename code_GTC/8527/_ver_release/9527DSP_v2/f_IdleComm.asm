.NOLIST
.INCLUDE	include/REG_D22.inc
.INCLUDE	include/MD22U.inc
.INCLUDE	include/CONST.inc
.INCLUDE	include/EXTERN.inc

.GLOBAL	SER_COMMAND
;-------------------------------------------------------------------------------
.EXTERN	GetOneConst	;(INPUT=ACCH(ProgramRamAddress),OUTPUT=ACCH(ReadData))
.EXTERN	GetMoreConst	;(INPUT=ACCH(ProgramRamStartingAddress)ACCL(ReadWordNumber)AR1(StoreDataRamAddress),OUTPUT=)
;---
.LIST
;-------------------------------------------------------------------------------
.ORG	ADDR_SECOND
;-------------------------------------------------------------------------------
SER_COMMAND:
	CALL	GETR_DAT
	SBHK	0X40
	SAH	MSG
;---make sure the value [0x40 - 0x8F]
	LAC	MSG
	BS	SGN,SYS_MSG_YES		;0x00<= x <0x40
	SBHK	0X4F
	BZ	SGN,SYS_MSG_YES		;0x8F<= x --
;---	
	LAC	MSG
	ADHL	COMMAND_TAB
	CALL	GetOneConst
	ADHK	0
	BACC		;jump to ...
;---------------------------------------
SYS_MSG_YES:
SYS_MSG_NO:
	RET

;---------------------------------------
SYS_SER_RUN_SetMenuVOP:
	LACL	CKEY_VOP	;Setup_menu
	CALL	STOR_MSG
	
	LACK	0X73		;Setup_menu ...
	SAH	DTMF_VAL
	
	BS	B1,SYS_MSG_YES
;---------------------------------------
SYS_SER_RUN_SetWeek:
	LAC	PRO_VAR
	BZ	ACZ,SYS_MSG_YES		;Playing
;---------------------------------------idle	
	CALL	INIT_DAM_FUNC
	
	CALL	GETR_DAT
	CALL	WEEK_SET
	
	BS	B1,SYS_MSG_YES
;---------------------------------------
SYS_SER_RUN_SetMDHM:
	LAC	PRO_VAR
	BZ	ACZ,SYS_MSG_YES		;Playing
	
;---------------------------------------idle
	CALL	INIT_DAM_FUNC

	LACK	0	;clear timer-second first
	CALL	SEC_SET		;second

	CALL	GETR_DAT
	CALL	DGT_HEX
	CALL	MON_SET		;month
	
	CALL	GETR_DAT
	CALL	DGT_HEX
	CALL	DAY_SET		;day
	
	CALL	GETR_DAT
	CALL	HOUR_CONV
	CALL	DGT_HEX
	CALL	HOUR_SET	;hour
	
	CALL	GETR_DAT
	CALL	DGT_HEX
	CALL	MIN_SET		;minute

;-------

;---------------------------------------

	BS	B1,SYS_MSG_YES
;---------------------------------------

;---------------
SYS_SER_RUN_0X51:
	CALL	GETR_DAT
	ANDL	0X0FF
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X510X01
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X510X02
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X510X01:		;select OGM1
	LAC	EVENT
	ANDL	~(1<<8)
	SAH	EVENT
	BS	B1,SYS_MSG_YES
	
SYS_SER_RUN_0X510X02:		;select OGM2
	LAC	EVENT
	ORL	1<<8
	SAH	EVENT
	BS	B1,SYS_MSG_YES
;---------------
SYS_SER_RUN_0X52:		;play current OGM
	LACL	CMSG_KEY5S
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X53:		;record current OGM
	LACL	CMSG_KEY5L
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
;---------------
SYS_SER_RUN_0X54:
	LACL	CMSG_PLY	;play message
	CALL	STOR_MSG

	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X55:	;pause playing
SYS_SER_RUN_0X56:	;next message
SYS_SER_RUN_0X57:	;previous/repeat message
	BS	B1,SYS_MSG_YES
;---------------
SYS_SER_RUN_0X58:
	LACL	CKEY_VOP	;按键音
	CALL	STOR_MSG
	
	LACK	0X70		;按键音ID
	SAH	DTMF_VAL

	BS	B1,SYS_MSG_YES
;---------------
SYS_SER_RUN_0X59:
	LACL	CREC_MEMO	;record MEMO
	CALL	STOR_MSG

	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X5A:
	LACL	CMSG_KEY6S	;stop
	CALL	STOR_MSG

SYS_SER_RUN_0X5B:
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X5C:
	LACL	COLD_ERAS	;erase all old messages
	CALL	STOR_MSG

	BS	B1,SYS_MSG_YES
;---------------
SYS_SER_RUN_0X5D:
SYS_SER_RUN_0X5D0X00:	;normal play speed
SYS_SER_RUN_0X5D0X01:	;play speed up 100%
SYS_SER_RUN_0X5D0X02:	;play speed down 100%
	BS	B1,SYS_MSG_YES
;---------------
SYS_SER_RUN_0X5E:
	CALL	GETR_DAT
	ANDL	0X0FF
	BS	ACZ,SYS_SER_RUN_0X5E0X00
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X5E0X01
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X5E0X00:
	LACL	CPHONE_OFF	;speaker phone mode
	CALL	STOR_MSG

	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X5E0X01:
	LACL	CPHONE_ON	;exist speaker phone mode
	CALL	STOR_MSG
;---------------
SYS_SER_RUN_0X60:
	CALL	GETR_DAT
	ANDL	0X0FF
	BS	ACZ,SYS_SER_RUN_0X600X00
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X600X01
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X600X00:
	LACL	CHOOK_ON	;put down the handset to on hook for end a call
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X600X01:
	LACL	CHOOK_OFF	;pickup the handset to off hook in handset mode
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
;---------------
SYS_SER_RUN_0X61:
	LACL	CCID_VOP
	CALL	STOR_MSG	;CID receive
	BS	B1,SYS_MSG_YES
;---------------
SYS_SER_RUN_0X62:
SYS_SER_RUN_0X63:

	BS	B1,SYS_MSG_YES
;---------------
SYS_SER_RUN_0X64:
	CALL	GETR_DAT
	ANDK	0X0F
	BS	ACZ,SYS_SER_RUN_0X640X00
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X640X01
	
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X640X00:
	
	LACL	CSPK_ENABLE	;EnableSpeaker 
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X640X01:
	
	LACL	CSPK_DISABLE	;DisableSpeaker
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
;---------------
SYS_SER_RUN_0X6A:

	CALL	GETR_DAT
	ANDK	0X0F
	SAH	DTMF_VAL

	LACL	CKEY_VOP
	CALL	STOR_MSG

	BS	B1,SYS_MSG_YES
;---------------
SYS_SER_RUN_0X6B:
	CALL	GETR_DAT
	ANDK	0X7F
	BS	ACZ,SYS_SER_RUN_0X6B0X00
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X6B0X01
	
	BS	B1,SYS_MSG_YES

SYS_SER_RUN_0X6B0X01:
	LACL	CTMODE_IN	;enter test mode
	CALL	STOR_MSG
SYS_SER_RUN_0X6B0X00:		;reserved
	BS	B1,SYS_MSG_YES

;---------------------------------------
SYS_SER_RUN_0X6F:

	CALL	INIT_DAM_FUNC

	LACL    CMODE9|1
    	CALL    DAM_BIOSFUNC
;-!!!
	LACK	0X2F
	CALL	SEND_DAT
	LACK	0X2F
	CALL	SEND_DAT
;-!!!
	BS	B1,SYS_MSG_YES	;Erase all VP(Memo/Ogm/Icm)
;---------------------------------------
SYS_SER_RUN_0X70:	;Message Error
	CALL	GETR_DAT
	BS	ACZ,SYS_SER_RUN_0X700X00
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X700X01
SYS_SER_RUN_0X700X00:
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X700X01:
	CALL	INIT_DAM_FUNC
	
	LACL    CMODE9|1
    	CALL    DAM_BIOSFUNC

	;LAC	ERR_FG
	;ANDL	~((1<<1)|(1))
	;SAH	ERR_FG

    	LACK	0X005
    	CALL	STOR_VP

	BS	B1,SYS_MSG_YES
;---------------------------------------
SYS_SER_RUN_0X71:	;LEC

SYS_SER_RUN_0X72:	;T/R Ratio

SYS_SER_RUN_0X73:	;LINE_GAIN

SYS_SER_RUN_0X74:	;Loop Attenuation

SYS_SER_RUN_0X75:	;MIC-PRE-PGA

SYS_SER_RUN_0X76:	;LIN-DRV

SYS_SER_RUN_0X77:	;AD1-PGA

SYS_SER_RUN_0X78:	;AD2-PGA

SYS_SER_RUN_0X79:	;SPK-DRV

	BS	B1,SYS_MSG_YES
;---------------------------------------
SYS_SER_RUN_0X80:

	CALL	GETR_DAT
	SAH	MSG_ID
	SBHK	8
	BZ	SGN,SYS_SER_RUN_0X80_END
;---Save it first
	CALL	GETR_DAT
	SAH	ADDR_BUF+12
	CALL	GETR_DAT
	SAH	ADDR_BUF+13	;perhaps no data

;---then Read old data
	LACK	ADDR_BUF
	SAH	ADDR_D
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	SAH	OFFSET_D
;---
	LACL	0XE600|CGROUP_DATT	;set working group
	CALL	DAM_BIOSFUNC	
	LACL	0XE401
	CALL	DAM_BIOSFUNC
	CALL	TELNUM_READ	;read	
	LACL	0XE300		;Stop read
	CALL	DAM_BIOSFUNC
	
	LAC	MSG_ID
	SBHK	1
	SAH	OFFSET_D
	LAC	ADDR_BUF+12
	CALL	STORBYTE_DAT
	
	LAC	MSG_ID
	SBHK	2
	BS	ACZ,SYS_SER_RUN_0X80_2BYTE	;psword
	SBHK	5
	BS	ACZ,SYS_SER_RUN_0X80_2BYTE	;area-code
	BS	B1,SYS_SER_RUN_0X80_2BYTE_END
SYS_SER_RUN_0X80_2BYTE:
	LAC	ADDR_BUF+13
	CALL	STORBYTE_DAT
SYS_SER_RUN_0X80_2BYTE_END:
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
.if	1
	LAC	VOI_ATT
	ANDL	0X00F0
	SAH	VOI_ATT		;RING_CNT(15..12)/CallScreening(bit11)/CompressRate(bit10)/Language(bit9,8)/SPK_Gain(7..4)/SPK_VOL(3..0)

	LAC	EVENT
	SAH	MSG_N
	ANDL	~(1<<9)
	SAH	EVENT		;On-off flag

	CALL	GETBYTE_DAT	;byte1 - vol
	ANDK	0X0F
	OR	VOI_ATT
	SAH	VOI_ATT
;-	
	CALL	GETBYTE_DAT	;byte2 - ps1,2
	SFL	4
	ANDL	0X0FF0
	SAH	PASSWORD
;-
	CALL	GETBYTE_DAT	;byte3 - ps3
	SFR	4
	ANDK	0X0F
	OR	PASSWORD
	SAH	PASSWORD		
;-
	CALL	GETBYTE_DAT	;byte4 - ringcnt
	SFL	12
	ANDL	0XF000		;bit(3..0) -> bit(15..12)
	OR	VOI_ATT
	SAH	VOI_ATT
;-
	CALL	GETBYTE_DAT	;byte5 - CompressRate/on-off/MessageLength
	SAH	SYSTMP0
	
	BIT	SYSTMP0,7
	BZ	TB,SYS_SER_RUN_0X80_60COMPS

	LAC	VOI_ATT
	ORL	1<<10
	SAH	VOI_ATT
SYS_SER_RUN_0X80_60COMPS:
	BIT	SYSTMP0,6
	BS	TB,SYS_SER_RUN_0X80_ONOFF

	LAC	EVENT
	ORL	1<<9
	SAH	EVENT
SYS_SER_RUN_0X80_ONOFF:
;-
	CALL	GETBYTE_DAT	;byte6 - Language/LCD Contrast
	;SAH	SYSTMP0
	SFL	4
	ANDL	0X0300		;bit4,5 -> bit8,9
	OR	VOI_ATT
	SAH	VOI_ATT
;-------------------
	;CALL	GETBYTE_DAT	;byte7
	;CALL	GETBYTE_DAT	;byte8
;-------------------
.endif	
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	12	;预留4个Byte
	SAH	COUNT
	LACK	0
	SAH	OFFSET_S
	CALL	TELNUM_WRITE
	LACL	0XE100		;Stop write
	CALL	DAM_BIOSFUNC
	
SYS_SER_RUN_0X80_1:
;---number chk	
	LACL	0XE401
	CALL	DAM_BIOSFUNC
	SBHK	2
	BS	SGN,SYS_SER_RUN_0X80_END
	
	LACL	0XE501
	CALL	DAM_BIOSFUNC
	
	CALL	TEL_GC_CHK
	CALL	GC_CHK
	BS	B1,SYS_SER_RUN_0X80_1
SYS_SER_RUN_0X80_END:	;update end-----------------------------------------
	LAC	MSG_ID
	SBHK	5
	BZ	ACZ,SYS_MSG_YES
;---M5 status changed
	LACL	CKEY_VOP	;按键音
	CALL	STOR_MSG

	BIT	EVENT,9
	BS	TB,SYS_SER_RUN_0X80_ANSOFF	;current status

SYS_SER_RUN_0X80_ANSON:
	BIT	MSG_N,9		;Old status(EVENT)
	BZ	TB,SYS_MSG_YES	;on - on
;off -> on	
	LACK	0X72		;VP_AnswerOn
	SAH	DTMF_VAL
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X80_ANSOFF:
	BIT	MSG_N,9		;Old status(EVENT)
	BS	TB,SYS_MSG_YES	;off - off
;on -> off	
	LACK	0X71		;VP_AnswerOff
	SAH	DTMF_VAL
	BS	B1,SYS_MSG_YES
;---------------------------------------
SYS_SER_RUN_0X81:	;要求更新Mxx内容
	CALL	GETR_DAT	;Mx
	SAH	MSG_ID
	SBHK	13
	BZ	SGN,SYS_SER_RUN_0X81_ERR
;---move data
	LACK	ADDR_BUF
	SAH	ADDR_D
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	SAH	OFFSET_D

	LACK	28
	SAH	COUNT
	CALL	MOVEIIC_DAT
;---write phonebook
	LAC	MSG_ID
	ORL	0XE600|0X10	;set working group
	CALL	DAM_BIOSFUNC
	
	LACK	28
	SAH	COUNT
	CALL	TELNUM_WRITE
	LACL	0XE100		;Stop write
	CALL	DAM_BIOSFUNC
SYS_SER_RUN_0X81_1:
;---number chk	
	LACL	0XE401
	CALL	DAM_BIOSFUNC
	SBHK	2
	BS	SGN,SYS_SER_RUN_0X81_END
	
	LACL	0XE501
	CALL	DAM_BIOSFUNC
	
	CALL	TEL_GC_CHK
	CALL	GC_CHK
	BS	B1,SYS_SER_RUN_0X81_1
SYS_SER_RUN_0X81_ERR:

SYS_SER_RUN_0X81_END:
	BS	B1,SYS_MSG_YES
;---------------------------------------
SYS_SER_RUN_0X82:		;要求回送Mxx内容
	CALL	GETR_DAT
	SAH	MSG_ID
	SBHK	13
	BZ	SGN,SYS_SER_RUN_0X82_END

	LACK	ADDR_BUF
	SAH	ADDR_D
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	SAH	OFFSET_D

	LAC	MSG_ID
	ORL	0XE600|0X10	;set working group
	CALL	DAM_BIOSFUNC
	
	LACL	0XE401
	CALL	DAM_BIOSFUNC
	BS	ACZ,SYS_SER_RUN_0X82_END	;no specific tel-data
	CALL	TELNUM_READ	
	LACL	0XE300		;Stop read
	CALL	DAM_BIOSFUNC
	
	LACL	0X82
	CALL	SEND_DAT
	LAC	MSG_ID
	CALL	SEND_DAT
	
	LACK	28
	SAH	COUNT
	CALL	DUMPIIC_DAT
SYS_SER_RUN_0X82_END:
	BS	B1,SYS_MSG_YES
;---------------------------------------
SYS_SER_RUN_0X83:
	CALL	GETR_DAT
	SBHK	0
	BS	ACZ,SYS_SER_RUN_0X830X00	;Stor new CID
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X830X01	;Down review CID
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X830X02	;Up review CID
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X830X03	;Del current CID
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X830X04	;Del all CID
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X830X05	;exit
	BS	B1,SYS_MSG_YES
;-----------------------------	
SYS_SER_RUN_0X830X00:
	CALL	GETR_DAT
	SFL	8
	SAH	MSG_N		;flag-byte
;---Set address
	LACK	ADDR_BUF
	SAH	ADDR_D
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	SAH	OFFSET_D

	LACK	27
	SAH	COUNT
;---move
	CALL	MOVEIIC_DAT
;---write into flash
	LACL	0XE600|CGROUP_CID		;set working group
	CALL	DAM_BIOSFUNC

	LACK	27		;
	SAH	COUNT
	CALL	TELNUM_WRITE
	LACL	0XE100		;Stop write
	CALL	DAM_BIOSFUNC
;---Set tag-byte	
	LACL	0XE401
	CALL	DAM_BIOSFUNC
	SAH	MSG_T
	OR	MSG_N		;Note(index15..8,TEL-number7..0)
	CALL	SET_TELUSR1ID
;---check the total number of CID	
	LAC	MSG_T
	SBHK	100
	BS	SGN,SYS_SER_RUN_0X830X00_1
	
	LACL	0XE501
	CALL	DAM_BIOSFUNC
	CALL	TEL_GC_CHK
SYS_SER_RUN_0X830X00_1:
	LACL	0XE401
	CALL	DAM_BIOSFUNC
	SAH	MSG_T
	CALL	GET_TELN
	SAH	MSG_N
;!!!!!!!!!!!!!!!!!!!
	LACL	0X85
	CALL	SEND_DAT
	LACK	0X0
	CALL	SEND_DAT
	LAC	MSG_T
	CALL	SEND_DAT
	LACL	0X85
	CALL	SEND_DAT
	LACK	0X1
	CALL	SEND_DAT
	LAC	MSG_N
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!
	BS	B1,SYS_MSG_YES

;-----------------------------
SYS_SER_RUN_0X830X01:	;Down Review CID
	LAC	ANN_FG
	ANDL	~(1<<10)
	SAH	ANN_FG	;Down-Review flag
	
	BIT	ANN_FG,9
	BZ	TB,SYS_SER_RUN_0X83ENTRY

SYS_SER_RUN_0X830X01_START:	
	LACK	0
	SAH	SYSTMP1
	LAC	MSG_T
	SAH	SYSTMP2
	
	LAC	MSG_ID
	CALL	VALUE_SUB	;index decrease
	SAH	MSG_ID
	BS	ACZ,SYS_SER_RUN_0X83STARTEND
	BS	B1,SYS_SER_RUN_0X83_READ
SYS_SER_RUN_0X83ENTRY:		;Review CID from idle
	LAC	ANN_FG
	ORL	1<<9
	SAH	ANN_FG	;set ReviewCID flag

	LACL	0XE600|CGROUP_CID	;set working group
	CALL	DAM_BIOSFUNC	
	LACL	0XE401
	CALL	DAM_BIOSFUNC
	SAH	MSG_T
	SAH	MSG_ID
	BS	ACZ,SYS_SER_RUN_0X830X05	;No CID,exit
SYS_SER_RUN_0X83_READ:		;read and send data
;---read	
	LACK	ADDR_BUF	;Set address
	SAH	ADDR_D
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	SAH	OFFSET_D

	LAC	MSG_ID
	CALL	GET_TELUSR1ID
	SAH	MSG_N		;read tag

	LAC	MSG_ID		;read
	CALL	TELNUM_READ
	LACL	0XE300		;Stop read
	CALL	DAM_BIOSFUNC
;---send cid-data	
	LACL	0X83
	CALL	SEND_DAT
	LACK	0X01
	CALL	SEND_DAT
	LAC	MSG_N
	CALL	SEND_DAT

	LACK	27
	SAH	COUNT
	CALL	DUMPIIC_DAT
;---change new-flag	
	LAC	MSG_N
	ANDL	~(1<<1)
	SFL	8
	OR	MSG_ID
	CALL	SET_TELUSR1ID
	
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X83STARTEND:	;Start/End of list
	LACL	0X84
	CALL	SEND_DAT
	LACK	0X00
	CALL	SEND_DAT
	BS	B1,SYS_MSG_YES
;-----------------------------	
SYS_SER_RUN_0X830X02:	;Up Review CID
	LAC	ANN_FG
	ORL	1<<10
	SAH	ANN_FG	;Up-Review flag
	
	BIT	ANN_FG,9
	BZ	TB,SYS_SER_RUN_0X83ENTRY

SYS_SER_RUN_0X830X02_START:	
	LACK	0
	SAH	SYSTMP1
	LAC	MSG_T
	SAH	SYSTMP2
	
	LAC	MSG_ID
	CALL	VALUE_ADD	;index increase
	SAH	MSG_ID
	BS	ACZ,SYS_SER_RUN_0X83STARTEND
	BS	B1,SYS_SER_RUN_0X83_READ
;-----------------------------
SYS_SER_RUN_0X830X03:	;Del current CID
	BIT	ANN_FG,9
	BZ	TB,SYS_SER_RUN_0X830X03ENTER	;Delete the newest CID received just now
SYS_SER_RUN_0X830X03_DOING:
	LAC	MSG_ID
	ORL	0XE500
	CALL	DAM_BIOSFUNC
	
	CALL	TEL_GC_CHK
	CALL	GC_CHK

	LACL	0XE401
	CALL	DAM_BIOSFUNC
	SAH	MSG_T
	
	BIT	ANN_FG,10
	BZ	TB,SYS_SER_RUN_0X830X01		;down
	
	LAC	MSG_ID
	SBHK	1
	SAH	MSG_ID

	BS	B1,SYS_SER_RUN_0X830X02	;up-read the CID with current CID-index
SYS_SER_RUN_0X830X03ENTER:
	LAC	ANN_FG
	ANDL	~(1<<10)
	ORL	1<<9
	SAH	ANN_FG
	
	LACL	0XE401
	CALL	DAM_BIOSFUNC
	SAH	MSG_T
	SAH	MSG_ID
	BS	B1,SYS_SER_RUN_0X830X03_DOING
;-----------------------------	
SYS_SER_RUN_0X830X04:	;Del all CID
	LACL	0XE600|CGROUP_CID	;set working group
	CALL	DAM_BIOSFUNC	

SYS_SER_RUN_0X830X04_DEL:	
	
	LACL	0XE501
	CALL	DAM_BIOSFUNC
	LACL	0XE401
	CALL	DAM_BIOSFUNC
	BZ	ACZ,SYS_SER_RUN_0X830X04_DEL
	
	CALL	TEL_GC_CHK
	CALL	GC_CHK

	;BS	B1,SYS_MSG_YES	;借用0x8E0x05退出标记
;-----------------------------
SYS_SER_RUN_0X830X05:		;Exit review CID
	LAC	ANN_FG
	ANDL	~(1<<9)
	SAH	ANN_FG
;---verify CID number	
	LACL	0XE401
	CALL	DAM_BIOSFUNC
	SAH	MSG_T
	CALL	GET_TELN
	SAH	MSG_N
;!!!!!!!!!!!!!!!!!!!
	LACL	0X85
	CALL	SEND_DAT
	LACK	0X0
	CALL	SEND_DAT
	LAC	MSG_T
	CALL	SEND_DAT
	LACL	0X85
	CALL	SEND_DAT
	LACK	0X1
	CALL	SEND_DAT
	LAC	MSG_N
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!	
	BS	B1,SYS_MSG_YES
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;	Function : MON_SET
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
MON_SET:
	ORL	0X7500
	CALL	DAM_BIOSFUNC
	RET
;-------------------------------------------------------------------------------
;	Function : DAY_SET
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
DAY_SET:
	ORL	0X7400
	CALL	DAM_BIOSFUNC
	RET
;===============================================================================
;	Function : WEEK_SET
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
WEEK_SET:
	ORL	0X7300
	CALL	DAM_BIOSFUNC
	RET
;-------------------------------------------------------------------------------
;	Function : HOUR_CONV
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
HOUR_CONV:
	SAH	SYSTMP0
	SBHK	0X12
	BS	SGN,HOUR_COMP_0111	;<12 = 0x01/0x02/0x03/0x04/0x05/0x06/0x07/0x08/0x09/0x10/0x11
	BS	ACZ,HOUR_COMP_0		;=12 = 0x12 
;-
	LAC	SYSTMP0
	SBHL	0X92		
	BS	ACZ,HOUR_COMP_12	;12PM = 0x92
;---13..23(0x81/0x82/0x83/0x84/0x85/0x86/0x87/0x88/0x89/0x90/0x91/)
	LAC	SYSTMP0	
	ADHK	0X12
	ANDK	0X7F
	SAH	SYSTMP0			;More than 13
HOUR_COMP_0111:	
	LAC	SYSTMP0			;Less than 12
	RET
HOUR_COMP_0:
	LACK	0
	RET
HOUR_COMP_12:
	LACK	0X12
	RET
;-------------------------------------------------------------------------------
;	Function : HOUR_SET
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
HOUR_SET:
	ORL	0X7200
	CALL	DAM_BIOSFUNC

	RET
;-------------------------------------------------------------------------------
;	Function : MIN_SET
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
MIN_SET:
	ORL	0X7100
	CALL	DAM_BIOSFUNC
	RET
;-------------------------------------------------------------------------------
;	Function : SEC_SET
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
SEC_SET:
	ORL	0X7000
	CALL	DAM_BIOSFUNC
	RET

;-------------------------------------------------------------------------------
;.INCLUDE	l_beep/l_beep.asm
;.INCLUDE	l_beep/l_bbeep.asm
;.INCLUDE	l_beep/l_bbbeep.asm
;.INCLUDE	l_beep/l_lbeep.asm
;.INCLUDE	l_beep/l_errbeep.asm

.INCLUDE	l_iic/l_getrqueue.asm
.INCLUDE	l_iic/l_storsqueue.asm

.INCLUDE	l_math/l_dgthex.asm
.INCLUDE	l_math/l_hexdgt.asm
.INCLUDE	l_math/l_increase.asm
.INCLUDE	l_math/l_decrease.asm

.INCLUDE	l_move/l_stordata.asm
.INCLUDE	l_move/l_getdata.asm
.INCLUDE	l_move/l_dumpiic_tel.asm
.INCLUDE	l_move/l_moveiic_tel.asm

.INCLUDE	l_respond/l_vpqueue.asm

.INCLUDE	l_table/l_commandtable_idle.asm
.INCLUDE	l_table/l_voltable.asm

.INCLUDE	l_tel/l_newtel.asm
.INCLUDE	l_tel/l_tel_gcchk.asm
.INCLUDE	l_tel/l_tel_read.asm
.INCLUDE	l_tel/l_tel_write.asm
.INCLUDE	l_tel/l_tel_tag.asm

;-------------------------------------------------------------------------------
.END
	