.NOLIST
.INCLUDE	include/REG_D22.inc
.INCLUDE	include/MD22U.inc
.INCLUDE	include/CONST.inc
.INCLUDE	include/EXTERN.inc
;-------------------------------------------------------------------------------
.GLOBAL	UPDATE_FLASHDATA
.GLOBAL	SER_COMMAND
;-------------------------------------------------------------------------------
.EXTERN	GetOneConst	;(INPUT=ACCH(ProgramRamAddress),OUTPUT=ACCH(ReadData))
.EXTERN	GetMoreConst	;(INPUT=ACCH(ProgramRamStartingAddress)ACCL(ReadWordNumber)AR1(StoreDataRamAddress),OUTPUT=)
;-------------------
.GLOBAL	SYS_SER_RUN_0X80	;for speakerphone
.GLOBAL	SYS_SER_RUN_0X81	;for speakerphone
.GLOBAL	SYS_SER_RUN_0X82	;for speakerphone
.GLOBAL	SYS_SER_RUN_0X83	;for speakerphone
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
SYS_SER_RUN_SETVOL:
	LAC	VOI_ATT
	ANDL	0XFFF0
	SAH	VOI_ATT
	
	CALL	GETR_DAT
	ANDK	0X000F
	OR	VOI_ATT
	SAH	VOI_ATT

	LACK	0X7F
	SAH	DTMF_VAL
	LACL	CKEY_VOP
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
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
	ORL	0X7300
	CALL	DAM_BIOSFUNC		;week
	
	BS	B1,SYS_MSG_YES
;---------------------------------------
SYS_SER_RUN_SetMDHM:
	LAC	PRO_VAR
	BZ	ACZ,SYS_MSG_YES		;Playing
	
;---------------------------------------idle
	CALL	INIT_DAM_FUNC
	
	LACL	0X7000		;clear timer-second first
	CALL	DAM_BIOSFUNC		;second

	CALL	GETR_DAT
	CALL	DGT_HEX
	ORL	0X7500
	CALL	DAM_BIOSFUNC	;month
	
	CALL	GETR_DAT
	CALL	DGT_HEX
	ORL	0X7400
	CALL	DAM_BIOSFUNC	;day
	
	CALL	GETR_DAT
	CALL	HOUR_CONV
	CALL	DGT_HEX
	ORL	0X7200
	CALL	DAM_BIOSFUNC	;hour
	
	CALL	GETR_DAT
	CALL	DGT_HEX
	ORL	0X7100
	CALL	DAM_BIOSFUNC	;minute

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
SYS_SER_RUN_0X65:
	CALL	GETR_DAT
	ANDK	0X0F
	BS	ACZ,SYS_SER_RUN_0X650X00
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X650X01
	
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X650X00:
	
	LAC	ANN_FG
	ANDL	~(1<<1)		;Enable auto answer function
	SAH	ANN_FG
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X650X01:
	
	LAC	ANN_FG
	ORK	(1<<1)		;disable auto answer function
	SAH	ANN_FG
	
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
;---cover the old data	
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

	BS	B1,SYS_SER_RUN_0X80_1
SYS_SER_RUN_0X80_END:	;update end-----------------------------------------
	LAC	MSG_ID
	SBHK	5
	BZ	ACZ,SYS_MSG_YES
;---M5 status changed,then check ON/OFF status
	LAC	EVENT
	XOR	MSG_N
	ANDL	(1<<9)
	BS	ACZ,SYS_MSG_YES
;---On/Off changed
	LACL	CKEY_VOP	;按键音
	CALL	STOR_MSG

	BIT	EVENT,9
	BS	TB,SYS_SER_RUN_0X80_ANSOFF	;current status
;off -> on	
	LACK	0X72		;VP_AnswerOn
	SAH	DTMF_VAL
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X80_ANSOFF:
;on -> off	
	LACK	0X71		;VP_AnswerOff
	SAH	DTMF_VAL
	BS	B1,SYS_MSG_YES
;---------------------------------------
SYS_SER_RUN_0X81:	;要求更新Mxx内容
	CALL	GETR_DAT	;Mx
	;SAH	MSG_ID
	SAH	MSG_N	;!!!不要用MSG_ID
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
	LAC	MSG_N	;!!!不要用MSG_ID
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
COMMAND0X83_TAB:
.data	SYS_SER_RUN_0X830X00
.data	SYS_SER_RUN_0X830X01
.data	SYS_SER_RUN_0X830X02
.data	SYS_SER_RUN_0X830X03
.data	SYS_SER_RUN_0X830X04
.data	SYS_SER_RUN_0X830X05
;-------------------
SYS_SER_RUN_0X83:
	CALL	GETR_DAT
	SAH	MSG
;	SBHK	0
;	BS	ACZ,SYS_SER_RUN_0X830X00	;Stor new CID
;	SBHK	1
;	BS	ACZ,SYS_SER_RUN_0X830X01	;Down review CID
;	SBHK	1
;	BS	ACZ,SYS_SER_RUN_0X830X02	;Up review CID
;	SBHK	1
;	BS	ACZ,SYS_SER_RUN_0X830X03	;Del current CID
;	SBHK	1
;	BS	ACZ,SYS_SER_RUN_0X830X04	;Del all CID
;	SBHK	1
;	BS	ACZ,SYS_SER_RUN_0X830X05	;exit
;	BS	B1,SYS_MSG_YES
;-------------------	
;	LAC	MSG
	BS	SGN,SYS_MSG_YES		;0x00<= x <0x40
	SBHK	0X6
	BZ	SGN,SYS_MSG_YES		;0x06<= x --
;---	
	LAC	MSG
	ADHL	COMMAND0X83_TAB
	CALL	GetOneConst
	ADHK	0
	BACC		;jump to ...	
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
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;---Get and set date/time
	LACK	22		;!!!Check minute first(this is the 24th byte of the CID-format,the first byte store in MSG_N)
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	SAH	SYSTMP0
	SBHK	60
	BZ	SGN,SYS_SER_RUN_0X830X00_DATETIME_END	;date/time error,don't update date/time
;---Update minute	
	LAC	SYSTMP0
	CALL	HEX_DGT
	SFL	8
	ANDL	0XFF00
	SAH	SYSTMP0
	
	lipk    9
	OUT	SYSTMP0,RTCMS	;  min=SYSTMP0(15..8), sec=SYSTMP0(7..0)
	ADHK	0
;---Get bit-data
SYS_SER_RUN_0X830X00_BIT:
	LACK	0
	SAH	MSG_N

	LACK	8		;!!!Check month(this is the 10th byte of the CID-format,the first byte store in MSG_N)
	SAH	OFFSET_S
	LACK	13
	SAH	COUNT
SYS_SER_RUN_0X830X00_BITLOOP:
	CALL	GETBYTE_DAT
	SAH	SYSTMP0
	
	LAC	MSG_N
	SFL	1
	BIT	SYSTMP0,7
	BZ	TB,SYS_SER_RUN_0X830X00_UPDATEBIT
	ORK	1
SYS_SER_RUN_0X830X00_UPDATEBIT:
	SAH	MSG_N
	
	LAC	COUNT
	SBHK	1
	SAH	COUNT
	BZ	SGN,SYS_SER_RUN_0X830X00_BITLOOP
;---Get bit-data over then update date/time
;-hour
	LAC	MSG_N
	ANDK	0X1F
	CALL	HEX_DGT
	SAH	SYSTMP0	

	lipk    9
	IN	SYSTMP1,RTCWH
	LAC	SYSTMP1
	ANDL	0XFF00
	OR	SYSTMP0
	SAH	SYSTMP1
	OUT	SYSTMP1,RTCWH
	ADHK	0
;-date(month/day)
	LAC	MSG_N
	SFR	5
	ANDK	0X1F
	CALL	HEX_DGT
	SAH	SYSTMP0
	
	LAC	MSG_N
	SFR	10
	ANDK	0XF
	CALL	HEX_DGT
	SFL	8
	OR	SYSTMP0
	SAH	SYSTMP0

	lipk    9
	OUT	SYSTMP0,RTCMD
	ADHK	0
;---control, year reserved	
	IN	SYSTMP0,RTCCY
	LAC	SYSTMP0
	ANDL	0X00FF
	ORL	0X0700
	SAH	SYSTMP0	
	OUT	SYSTMP0,RTCCY
	LAC	SYSTMP0
	ANDL	0X00FF
	ORL	0X0300
	SAH	SYSTMP0	
	OUT	SYSTMP0,RTCCY
SYS_SER_RUN_0X830X00_DATETIME_END:
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
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
	LACL	0XE600|CGROUP_CID	;set working group
	CALL	DAM_BIOSFUNC	
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
SYS_SER_RUN_0X830X03_DEL:
	LACL	0XE401
	CALL	DAM_BIOSFUNC
	SAH	SYSTMP1		;Save the number of total-CID
;---------Delete start
SYS_SER_RUN_0X830X03_DOING:
	LAC	MSG_ID
	ORL	0XE500
	CALL	DAM_BIOSFUNC
;---比较总数,有减少就退出,否则重复执行
	LACL	0XE401
	CALL	DAM_BIOSFUNC
	SAH	MSG_T
	BS	ACZ,SYS_SER_RUN_0X830X05	;No CID exit
	SBH	SYSTMP1
	BZ	SGN,SYS_SER_RUN_0X830X03_DOING	;delete fail,try again
SYS_SER_RUN_0X830X03_DONE:
;---------Delete end	
	;CALL	TEL_GC_CHK

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
	BS	ACZ,SYS_SER_RUN_0X830X05
	BS	B1,SYS_SER_RUN_0X830X03_DEL
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
	;CALL	GC_CHK	;!!!Note 不能与TEL-Mode兼容
;???????????????????????????????????????
	lack	0x001
	sah	CONF1
	LACL	0XE705
	CALL	DAM_BIOSFUNC
;???????????????????????????????????????
	;BS	B1,SYS_SER_RUN_0X830X05	;借用0x8E0x05退出标记
;-----------------------------
SYS_SER_RUN_0X830X05:		;Exit review CID
;---verify CID number	
	CALL	TEL_GC_CHK

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
	LAC	ANN_FG
	ANDL	~(1<<9)
	SAH	ANN_FG
	
	BS	B1,SYS_MSG_YES
;-------------------------------------------------------------------------------
UPDATE_FLASHDATA:
;---then Read old data
	LAC	ERR_FG
	ANDL	~(1<<2)
	SAH	ERR_FG		;clean the update flag

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
	CALL	TELNUM_READ		;read	
	LACL	0XE300			;Stop read
	CALL	DAM_BIOSFUNC
;---------------------------------------
	LACK	0
	SAH	OFFSET_S
	SAH	OFFSET_D
	
	LAC	VOI_ATT	
	ANDK	0X0F
	CALL	STORBYTE_DAT	;byte1 - vol

	BS	B1,SYS_SER_RUN_0X80_2BYTE_END
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