
;-----------------------------// Constant key defines,全部以C开头。--------------------------------
;---SYS MSG CONST------------------
	CMSG_KEY1S	.EQU	0X01	;messages for key released(松开按键UP)
	CMSG_KEY2S	.EQU	0X02
	CMSG_KEY3S	.EQU	0X03
	CMSG_KEY4S	.EQU	0X04
	CMSG_KEY5S	.EQU	0X05
	CMSG_KEY6S	.EQU	0X06
	CMSG_KEY7S	.EQU	0X07
	CMSG_KEY8S	.EQU	0X08
	CMSG_KEY9S	.EQU	0X09
	CMSG_KEYAS	.EQU	0X0A
	CMSG_KEYBS	.EQU	0X0B
	CMSG_KEYCS	.EQU	0X0C
;---	
	CMSG_KEY1L	.EQU	0X11	;messages for key beening pressed 2s
	CMSG_KEY2L	.EQU	0X12
	CMSG_KEY3L	.EQU	0X13
	CMSG_KEY4L	.EQU	0X14
	CMSG_KEY5L	.EQU	0X15
	CMSG_KEY6L	.EQU	0X16
	CMSG_KEY7L	.EQU	0X17
	CMSG_KEY8L	.EQU	0X18
	CMSG_KEY9L	.EQU	0X19
	CMSG_KEYAL	.EQU	0X1A
	CMSG_KEYBL	.EQU	0X1B
	CMSG_KEYCL	.EQU	0X1C
;---	
	CMSG_KEY1P	.EQU	0X21	;messages for key beening pressed every 512ms
	CMSG_KEY2P	.EQU	0X22
	CMSG_KEY3P	.EQU	0X23
	CMSG_KEY4P	.EQU	0X24
	CMSG_KEY5P	.EQU	0X25
	CMSG_KEY6P	.EQU	0X26
	CMSG_KEY7P	.EQU	0X27
	CMSG_KEY8P	.EQU	0X28
	CMSG_KEY9P	.EQU	0X29
	CMSG_KEYAP	.EQU	0X2A
	CMSG_KEYBP	.EQU	0X2B
	CMSG_KEYCP	.EQU	0X2C
	
	CMSG_KEY1D	.EQU	0X31	;messages for key beening pressed DOWN(48ms later)
	CMSG_KEY2D	.EQU	0X32
	CMSG_KEY3D	.EQU	0X33
	CMSG_KEY4D	.EQU	0X34
	CMSG_KEY5D	.EQU	0X35
	CMSG_KEY6D	.EQU	0X36
	CMSG_KEY7D	.EQU	0X37
	CMSG_KEY8D	.EQU	0X38
	CMSG_KEY9D	.EQU	0X39
	CMSG_KEYAD	.EQU	0X3A
	CMSG_KEYBD	.EQU	0X3B
	CMSG_KEYCD	.EQU	0X3C
;---messages for function	
	
	CMSG_INIT	.EQU	0X81
	
	CMSG_TIFAT	.EQU	0X83	;向MCU发送时间制式
	CMSG_CTONE	.EQU	0X84
	CMSG_BTONE	.EQU	0X85
	CREV_DTMF	.EQU	0X86
	CMSG_VOX	.EQU	0X87

	CSEG_STOP	.EQU	0X89
	CSEG_PAUSE	.EQU	0X8A

;	CTWAY_REC	.EQU	0X8C
	CMSG_VOLA	.EQU	0X8D
	CMSG_VOLS	.EQU	0X8E
;---------------------------------------	
	CMSG_TMR	.EQU	0X90	;MSG OF BASE TIME
	CSEG_END	.EQU	0X91	;播放等到一段尾
	CVP_STOP	.EQU	0X92	;播放完毕；
;---
	CMENU_LGGE	.EQU	0X94	;Adjust language
	CMENU_TIME	.EQU	0X95	;Adjust time
	CMENU_CTRT	.EQU	0X96	;Adjust contrast
	CMENU_PSWD	.EQU	0X97	;Adjust PSWORD
	CMENU_LCOD	.EQU	0X98	;Adjust local code
	CMENU_RCNT	.EQU	0X99	;Adjust ring counter
	CMENU_OGMC	.EQU	0X9A	;Adjust OGM
;---------------------------------------	
	CBOOK_SLET	.EQU	0XA0	;Select option --- 添加/编辑(edit/search)
	CNUMB_BADD	.EQU	0XA1	;Add TEL-number in phone-book
;	CNAME_BADD	.EQU	0XA2	;Add TEL-name in phone-book
	CNUMB_EDIT	.EQU	0XA3	;Edit TEL-number in phone-book
	CNAME_EDIT	.EQU	0XA4	;Edit TEL-name in phone-book

;	CNAME_ACID	.EQU	0XA5	;Add CID-name in phone-book

	CNUMB_ECID	.EQU	0XA6	;Edit CID-number in phone-book
	CNAME_ECID	.EQU	0XA7	;Edit CID-name in phone-book

	CSTOR_TYPE	.EQU	0XA8	;Select the type which the TEL Stor to phone-book as(Normal/VIP/Filter)

;	CLOOK_ATEL	.EQU	0XA9	;Lookup specific ALL-Phone-book(MSG_ID)
;	CLOOK_VTEL	.EQU	0XAA	;Lookup specific VIP-Phone-book(MSG_ID)
;	CLOOK_FTEL	.EQU	0XAB	;Lookup specific FILTER-Phone-book(MSG_ID)
;	CLOOK_NTEL	.EQU	0XAC	;Lookup specific NORMAL-Phone-book(MSG_ID)
;---------------------------------------
	CREC_FULL	.EQU	0XB1	;FLASH FULL
;---------------------------------------
;---外部事件消息(按键之外的)	
	CMSG_SER	.EQU	0XE7	;收到命令
	CMSG_CPC	.EQU	0XE8
	CFIRST_RI	.EQU	0XE9	;第一次铃声
	CRING_OK	.EQU	0XEA
	CRMOT_OK	.EQU	0XEB	;ENTER REMOTE stat
	CRING_IN	.EQU	0XEC
	CRING_FAIL	.EQU	0XED
	CMSG_CID	.EQU	0XEE	;New CID received and write into flash
;-------------------------------------------------------------------------------
CTAG_ICM	.EQU		120
CTAG_MEMO	.EQU		121
CTEL_MNUM	.EQU		15	;Declare TEL-Message Number in FLASH
;---
CTMR_CTONE	.EQU	8000
CTMR_CVOX	.EQU	8000
;-------------------------------------------------------------------------------
COGM1_ID	.EQU	0x71	;for OGM VP USR-DAT
COGM2_ID	.EQU	0x72
COGM3_ID	.EQU	0x73
COGM4_ID	.EQU	0x74
COGM5_ID	.EQU	0x75
;-------------------------------------------------------------------------------
CMAX_VOL	.EQU	0x8
CMIN_VOL	.EQU	0x1

;-------------------------------------------------------------------------------
CBEEP_COMMAND	.EQU		0X48F7	;BEEP CON
;-------------------------------------------------------------------------------
CMODE9		.EQU		0x9240	;Enable S/W-ALC
;CMODE9		.EQU		0x9040	;Disable S/W-ALC
;-------------------------------------------------------------------------------
;SER_FG	(change only in interrupt)
CbRx		.EQU   	4	;bit4 = receive
CbTx		.EQU   	5	;bit5 = send

CbBUSY		.EQU   	6	;bi6 = IIC busy can`t receive command
CbLINE		.EQU   	8	;bi8 = ring or Torev on line
;-------------------------------------------------------------------------------
ADDR_FIRST	.EQU	0X4400
ADDR_SECOND	.EQU	0X5A00
;-------------------------------------------------------------------------------
CCOMMOND_SETCONTRAST	.EQU	0X87
;---
CCOMMOND_LANGUAGE	.EQU	0X90

CCOMMOND_HOUR		.EQU	0X91
CCOMMOND_MINUTE		.EQU	0X92
CCOMMOND_MONTH		.EQU	0X93
CCOMMOND_DAY		.EQU	0X94
CCOMMOND_WEEK		.EQU	0X95

CCOMMOND_CONTRAST	.EQU	0X96

CCOMMOND_PSWORD1	.EQU	0X97
CCOMMOND_PSWORD2	.EQU	0X98
CCOMMOND_PSWORD3	.EQU	0X99
CCOMMOND_PSWORD4	.EQU	0Xd4

CCOMMOND_OGMSELECT	.EQU	0XC0
CCOMMOND_RINGCNT	.EQU	0XCE
;-------------------------------------------------------------------------------
CMIC_PRE_GAIN		.EQU	0X08	;for local record
CAD0_PRE_GAIN		.EQU	0X07	;for local record
;---------------------------------------
CLNE_VOL		.EQU	0X19	;for answer/remote LINE-OUT volume
CAD0_PRE_RGAIN		.EQU	0X09	;for answer/remote AD0
;---------------------------------------
CMICROM_MOR	.EQU	0X08		;for room-monitor
CAD0ROM_MOR	.EQU	0X0C		;for room-monitor
CAD1ROM_MOR	.EQU	0X09		;for room-monitor
;---------------------------------------
;---------------for local-operation
;CLVOX_LEVEL	.EQU	2	;for LOCAL VOX-detect(0xD700)
;CLSILENCE_LEVEL	.EQU	10	;for LOCAL silence-level detect(0x7700) 
;---------------
CRVOX_LEVEL	.EQU	25	;for answer/remote VOX-detect(0xD700)
CRSILENCE_LEVEL	.EQU	7	;for answer/remote silence-level detect(0x7700)
CDTMF_LEVEL	.EQU	44	;for answer/remote silence-level detect(0x5800)
;---------------
CTMR1S		.EQU	1024

CLICM	.EQU	120	;s
CLOGM	.EQU	120	;s
CLMEM	.EQU	120	;s
CL2WAY	.EQU	120*60	;s
;-------------------------------------------------------------------------------
CGROUP_CID	.EQU	0	;CID
;CGROUP_MBOX1	.EQU	1	;与VP关联的CID
;CGROUP_MBOX2	.EQU	2	;与VP关联的CID
;CGROUP_MBOX3	.EQU	3	;与VP关联的CID
;CGROUP_MBOX4	.EQU	4	;与VP关联的CID
CGROUP_PBOOK	.EQU	5	;电话本(Normal/VIP/Filter)
CGROUP_DATT	.EQU	6	;DAM attribute
CGROUP_DATETIME	.EQU	7	;Datetime
;-------------------------------------------------------------------------------
VOP_INDEX_ActivateRoomMonitor	.EQU	58
VOP_INDEX_AllOldMessagesErased	.EQU	82
VOP_INDEX_AnswerMachine		.EQU	91
VOP_INDEX_Announcement		.EQU	56
VOP_INDEX_DefaultOGM		.EQU	48
VOP_INDEX_Default5OGM		.EQU	83

VOP_INDEX_Eine			.EQU	28
VOP_INDEX_Ein			.EQU	29
VOP_INDEX_EndOf			.EQU	46
VOP_INDEX_Erased		.EQU	98

VOP_INDEX_Uhr			.EQU	39

VOP_INDEX_MailBox		.EQU	63
VOP_INDEX_MemoryIsFull		.EQU	47
VOP_INDEX_Message		.EQU	44
VOP_INDEX_Messages		.EQU	45

VOP_INDEX_No			.EQU	41
VOP_INDEX_New			.EQU	42
VOP_INDEX_Null			.EQU	40

VOP_INDEX_On			.EQU	93
VOP_INDEX_Off			.EQU	94

VOP_INDEX_Please		.EQU	73
VOP_INDEX_ReleaseLine		.EQU	62
VOP_INDEX_Ring			.EQU	75
VOP_INDEX_Set			.EQU	74
VOP_INDEX_SecurityCode		.EQU	77
VOP_INDEX_Sunday		.EQU	30

;!!!
VOP_INDEX_Time			.EQU	78
VOP_INDEX_Hour			.EQU	80
VOP_INDEX_Minute		.EQU	81
VOP_INDEX_Day			.EQU	79
VOP_INDEX_AM			.EQU	37
VOP_INDEX_PM			.EQU	38
;!!!

VOP_INDEX_TollSaver		.EQU	76
VOP_INDEX_Und			.EQU	97
VOP_INDEX_YouHave		.EQU	95
;-------------------------------------------------------------------------------
CRATE36bps	.EQU	0
CRATE48bps	.EQU	1<<3
CRATE60bps	.EQU	2<<3
CRATE72bps	.EQU	3<<3
CRATE84bps	.EQU	4<<3
CRATE96bps	.EQU	5<<3
WRATE	.EQU	CRATE48bps		;录音压缩比
;-------------------------------------------------------------------------------
DebugAD1	.EQU	1	;Use for room-monitor
DebugLanguage	.EQU	0	;1/0 = normal/Only one language
;-------------------------------------------------------------------------------
.END
