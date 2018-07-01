;-------------------------------------------------------------------------------
;---timer1
	CTMR10S		==	160
	CTMR8S		==	128
	CTMR5S		==	80
	CTMR4S		==	64
	CTMR3S		==	48
	CTMR2S		==	32
	CTMR1S		==	16
	CTMR500MS	==	8
	CTMR375MS	==	6
	CTMR312MS	==	5
	CTMR250MS	==	4
	CTMR125MS	==	2
;---timer2
	CTMR100MS	==	100
	CTMR200MS	==	200
;---Cut tail
	CTAIL10S	==	25
	CTAIL8S		==	20
;-------------------------------------------------------------------------------
CKEYTMR_UNIT	==	10
;-------------------------------------------------------------------------------
	BANK0	==	0X0
	BANK1	==	0X40
	BANK2	==	0X80
	BANK3	==	0XC0
;-------------------------------------------------------------------------------
OTP		==	0
VALUE_IOCA	==	0x0		;p8 as normal
;###############################################################################
;	BLOCK	0
;---显示缓冲空间.直接与LCD上的显示位置一一对应
;128---reserved
;128+1---icon 1
;128+2---icon 2
;128+(3..12)---date/time/num
;128+(13..29)---second line
;128+(30..44)---third line

;128+(45)	---reserved
;128+(46) = 174	---LCD_CBUF
;---------------------------------------
;---显示缓冲空间.送入LCD一一对应区前的缓冲处理空间
;180---reserved
;180+1---icon 1
;180+2---icon 2

;180+3---1st LCTRL
;180+4---1st HEAD
;180+5---1st TAIL
;180+(6..15)---1st ADDR

;180+16---2nd LCTRL
;180+17---2nd HEAD
;180+18---2nd TAIL
;180+(19..33)---2nd ADDR

;180+34---3rd LCTRL
;180+35---3rd HEAD
;180+36---3rd TAIL
;180+(37..51)---3rd ADDR
;###############################################################################
LCD_CTRL	==	128

LENGTH1STL	==	10
LENGTH2NDL	==	15
LENGTH3RDL	==	15

OFFSETSTMP	==	1
OFFSETDATE	==	3
OFFSET1STL	==	OFFSETDATE
OFFSET2NDL	==	OFFSET1STL+LENGTH1STL	;3+10
OFFSET3RDL	==	OFFSET2NDL+LENGTH2NDL	;3+10+15

LCD_1STAMP	==	LCD_CTRL+OFFSETSTMP	;128+1	 - (0x81)
LCD_2STAMP	==	LCD_CTRL+OFFSETSTMP+1	;128+1+1 - (0x82)
LCD_1STLINE	==	LCD_CTRL+OFFSET1STL	;128+3	 - (0x83..0x8C)
LCD_2NDLINE	==	LCD_CTRL+OFFSET2NDL	;128+13	 - (0x8D..0x9B)
LCD_3RDLINE	==	LCD_CTRL+OFFSET3RDL	;128+28	 - (0x9C..0xAA)
;LCD3RDL_END	==	LCD_3RDLINE+15		;128+43	 - (0xAB..)
;---------------------------------------
LCD_CBUF	==	180		;DISP buffer
LCD_CBUF_1STMP	==	181
LCD_CBUF_2STMP	==	182

LCD_1CBUF_CTRL	==	LCD_CBUF_2STMP+1	;183
LCD_1CBUF_HEAD	==	LCD_1CBUF_CTRL+1	;184
LCD_1CBUF_TAIL	==	LCD_1CBUF_HEAD+1	;185
LCD_1CBUF_ADDR	==	LCD_1CBUF_TAIL+1	;186(186..195)10个byte - 0XBA..

LCD_2CBUF_CTRL	==	LCD_1CBUF_ADDR+10	;196
LCD_2CBUF_HEAD	==	LCD_2CBUF_CTRL+1	;197
LCD_2CBUF_TAIL	==	LCD_2CBUF_HEAD+1	;198
LCD_2CBUF_ADDR	==	LCD_2CBUF_TAIL+1	;199(199..213)15个byte - 0XC7..

LCD_3CBUF_CTRL	==	LCD_2CBUF_ADDR+15	;214
LCD_3CBUF_HEAD	==	LCD_3CBUF_CTRL+1	;215
LCD_3CBUF_TAIL	==	LCD_3CBUF_HEAD+1	;216
LCD_3CBUF_ADDR	==	LCD_3CBUF_TAIL+1	;217(217..231)15个byte - 0XD9..
;---------------------------------------
STYLE_NORMAL	==	(0x00+0x80)
STYLE_LEFT	==	(0x01+0x80)	; 靠左
STYLE_RIGHT	==	(0x02+0x80)	; 靠右
STYLE_CENTER	==	(0x03+0x80)	; 居中

STYLE_TOBCD	==	(1<<5)		; To BCD
;-------------------------------------------------------------------------------
PRO_STACK	==	235		;235(235..242)(0xEB..0xF2)

MSG_QUEUE	==	243		;243(0xf3)
MSG_QUEUE_START	==	MSG_QUEUE+1	;244(244..251)(0xf4..0xfb)
;###############################################################################
;	BLOCK	1
;0..5---Command
;6..7---Respond
;
;0x10---TONE_QUEUE_HEAD
;0x11---TONE_QUEUE_TAIL
;0x12---CTONE_QUEUE_START
;0x12..0x59---VP message queue
;
;0x60..0xA0
;DAM/TEL编辑区空间分配(book-func)
;PBOOK/CID/DIALED-CALL以固定长度,固定格式编辑保存
;
;0x60---TEL-flag	(1byte) - 
;0x61---time-flag	(1byte) - Because the time length is aways 4-bytes,the byte can use for Expend-TEL-flag
;0x62---num-flag	(1byte)
;0x63---name-flag	(1byte)
;0x64..0x67---time	(4bytes)
;0x68..0x87---num	(32bytes)
;0x88..0x96---name	(15bytes)
;
;
;---for M1/M2/M3 data(64Byte)
;M123_BUF_START	==	0xB0
;M123_BUF_END	==	M123_BUF_START+0X40 = 0xF0
;###############################################################################
COMMAND		==	0x0
RESPOND		==	0x6
;---for VP-queue
TONE_QUEUE_HEAD		==	0x10			;VP-queue head pointer
TONE_QUEUE_TAIL		==	TONE_QUEUE_HEAD+1	;VP-queue tail pointer
CTONE_QUEUE_START	==	TONE_QUEUE_HEAD+2	;VP-queue start address
;CTONE_QUEUE_START..CTONE_QUEUE_START+0x40	

;---The offset of tel-flag/time-flag/num-flag/name-flag/time-start/num-start/name-start
TEL_FGOFFSET	==	0
TIME_FGOFFSET	==	1
NUM_FGOFFSET	==	2
NAME_FGOFFSET	==	3
TIME_OFFSET	==	4
NUM_OFFSET	==	8
NAME_OFFSET	==	40
;---for tel/Cid/numeric-key
DATA_ZONE_START ==	0x60
TEL_FLAG	==	DATA_ZONE_START
TIME_FLAG	==	DATA_ZONE_START+1
NUM_FLAG	==	DATA_ZONE_START+2
NAME_FLAG	==	DATA_ZONE_START+3
TIME_START	==	DATA_ZONE_START+4		;(4..7)
NUM_START	==	DATA_ZONE_START+4+4		;(8..39)
NAME_START	==	DATA_ZONE_START+4+4+32		;(40..54)
PHOUR_START	==	DATA_ZONE_START+4+4+32+15	;(55)	;It's valid only for dial-num
PMIN_START	==	DATA_ZONE_START+4+4+32+16	;(56)	;It's valid only for dial-num
PSEC_START	==	DATA_ZONE_START+4+4+32+17	;(57)	;It's valid only for dial-num
DATA_ZONE_END	==	DATA_ZONE_START+4+4+32+18	;(58)
;DATA_ZONE_START+0x40 = 0XA0

NUM_1LEN	==	15	;
NUM_2LEN	==	24	;for pbook
NUM_3LEN	==	32	;for dial
NAME_LEN	==	15
;---------------------------------------
;---for M1/M2/M3 data
M123_BUF_START	==	0xB0
M123_BUF_END	==	M123_BUF_START+0X40
;M123_BUF_START+0x40 = 0XF0
;###############################################################################
;	BLOCK	2
;receive CID
;Offset	0,1 - Qpoint for CID
;	2..7 -offset
;	0x16..0xBF	;Raw-CID
;	0xC0..0xFF	;Cook-CID
;the CID type:
;		0=normal
;		1=Secret;
;		2=Unknown-number or error;
;		3=MessageWaitingActivate;
;		4=MessageWaitingDeactivate;
;		5=international
;
;###############################################################################
;Raw Data
CID_ZONE_START 	==	0x00
TIMETYPE	==	CID_ZONE_START+2	;1
TIMELEN		==	CID_ZONE_START+3	;8
NUMTYPE		==	CID_ZONE_START+4	;2/3/4
NUMLEN		==	CID_ZONE_START+5	;
NAMETYPE	==	CID_ZONE_START+6	;7/8
NAMELEN		==	CID_ZONE_START+7	;

CID_TYPE	==	CID_ZONE_START+16
CID_LEN		==	CID_TYPE+1

;Cooked Data
CIDTEL_ZONE_START 	==	0xC0
CIDTEL_FLAG	 	==	0xC0
CIDTIME_FLAG	==	CIDTEL_FLAG+1
CIDNUM_FLAG	==	CIDTEL_FLAG+2
CIDNAME_FLAG	==	CIDTEL_FLAG+3
CIDTIME_START	==	CIDTEL_FLAG+4		;(4..7)
CIDNUM_START	==	CIDTEL_FLAG+4+4		;(8..39)
CIDNAME_START	==	CIDTEL_FLAG+4+4+32		;(40..54)

CID_ZONE_END	==	0XFF	;0xff
;###############################################################################
;	BLOCK	3
;for pbook index-table
;
;Read from flash when power on
;update it when add/del pbook
;Write it into flash after exit to idle when the index-table changed
;
;###############################################################################
IDXTAB_START 	==	0x00
IDXTAB_END 	==	IDXTAB_START+120

;-------------------------------------------------------------------------------
DEFAULT_MINUTE	==	00
DEFAULT_HOUR	==	00
DEFAULT_DAY	==	1
DEFAULT_MONTH	==	1
DEFAULT_YEAR	==	10
DEFAULT_WEEK	==	0

DEFAULT_LANGUAGE	==	0
DEFAULT_FLASH		==	0
DEFAULT_CONTRAST	==	3
DEFAULT_RING	==	5	;Default = 5
DEFAULT_MSGLEN	==	2

DEFAULT_PS1	==	3
DEFAULT_PS2	==	2
DEFAULT_PS3	==	1
DEFAULT_PS4	==	0
;-------------------------------------------------------------------------------
CMODE9H 	==	0X92
CMODE9L 	==	0X40
CTONE_GAIN	==	0XF7
;---------------------------------------For DAM
CDAM_MIC_GAIN	==	0X08	;0X5F10
CDAM_AD0_GAIN	==	0X07	;0X5F11	;from Mic(for local record)
CDAM_RAD0_GAIN	==	0X01	;0X5F11	;from Line(for remote)
CDAM_AD1_GAIN	==	0X08	;0X5F12
CDAM_SPK_VOL	==	0X1A	;0X5F20
CDAM_LNE_VOL	==	0X18	;0X5F21
;---------------------------------------For SpeakerPhone
;CPHO_MIC_GAIN	==	0X0B	;0X5F10
;CPHO_AD0_GAIN	==	0X08	;0X5F11
;CPHO_AD1_GAIN	==	0X08	;0X5F12
;CPHO_SPK_VOL	==	0X1F	;0X5F20
;CPHO_LNE_VOL	==	0X13	;0X5F21
;---------------------------------------
;CPHO_TONEGAIN	== 	0X21	;0XC1XX	Set Gain of Tone
;CPHO_AECLEC	== 	0X00	;0XC4XX Set ERL
;CPHO_TRRATIO	== 	0X01	;0XC6XX SetT/R ratio
;CPHO_LINEGAIN	== 	0X05	;0XC8XX LINE_GAIN/SPK_GAIN
;CPHO_LOOPATTE	== 	0X05	;0XC9XX Set loop Attenuation
;-------------------------------------------------------------------------------
CTMR_CVOX	==	8*16
CTMR_CTONE	==	8*16
;CTMR_BTONE	==	8*16
;-------------------------------------------------------------------------------
CTEL_MNUM	==	7
CVOX_LEVEL	==	25	;for answer/remote VOX-detect(0xD700)
CSILENCE_LEVEL	==	7	;for answer/remote silence-level detect(0x7700)
CDTMF_SENSTV	==	63	;for answer/remote DTMF sensitivity
;---------------------------------------
CDENOISE_LEVEL	==	2	;De-noise level
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
COGM1		==	1
COGM2		==	2
;-------------------------------------------------------------------------------
;CGROUP_VPCID	==	1	;CID for VP-msg
;---
GROUP_M		==	10
GROUP_M0	==	10
GROUP_M1	==	11
GROUP_M2	==	12
GROUP_M3	==	13
;---
CGROUP_MISSCID	==	14	;Miss-CID
CMAX_MISSCID	==	99	;最大未接来电Miss-CID条目数
;---
CGROUP_ANSWCID	==	15	;Answered-CID
CMAX_ANSWCID	==	40	;最大已接来电Answered-CID条目数
;---
GROUP_DIAL	==	16	;Dial-CID
CMAX_DIALCID	==	50	;最大去电DIAL-CID条目数
;---
GROUP_BOOK	==	17	;Phone-book
CMAX_BOOK	==	120	;最大电话本Phone-book条目数
;---
CGROUP_DATT	==	18	;system attribute
;---
CGROUP_BOOKIDX	==	19	;the phonebook index-table
;-------------------------------------------------------------------------------
VOPID_OH	==	1
VOPID_ONE	==	2
VOPID_TWO	==	3
VOPID_THREE	==	4
VOPID_FOUR	==	5
VOPID_FIVE	==	6
VOPID_SIX	==	7
VOPID_SEVEN	==	8
VOPID_EIGHT	==	9
VOPID_NINE	==	10

VOPID_SUNDAY	==	29
VOPID_MONDAY	==	30
VOPID_TUESDAY	==	31
VOPID_WEDNESDAY	==	32
VOPID_THURDAY	==	33
VOPID_FRIDAY	==	34
VOPID_SATURDAY	==	35
VOPID_AM	==	36
VOPID_PM	==	37
VOPID_DAY	==	38
VOPID_HOUR	==	39
VOPID_MINUTE	==	40
VOPID_DEFOGM1	==	41
VOPID_DEFOGM2	==	42
VOPID_YOUHAVE	==	43
VOPID_NO	==	44
VOPID_NEW	==	45
VOPID_MESSAGE	==	46
VOPID_MESSAGES	==	47
VOPID_ENDOFMESSAGE	==	48
VOPID_SECURITYCODE	==	49
VOPID_TOLLSAVE	==	50
VOPID_TIME	==	51
VOPID_RINGS	==	52
VOPID_RECORD	==	53
VOPID_NOMESSAGE	==	54
VOPID_OLD	==	55
VOPID_DELETED	==	56
VOPID_ANSWER	==	57
VOPID_ANSMACHINE	==	58
VOPID_ANNOUNCEMENT	==	59
VOPID_ALLMESSAGES	==	60
VOPID_PLEASE	==	61
VOPID_ON	==	62
VOPID_OFF	==	63
VOPID_SET	==	64
VOPID_PRESS	==	65
VOPID_TOPLYMSG	==	66
VOPID_TOREPTYMSG	==	67
VOPID_TOSKPMSG	==	68
VOPID_TOPLYANNOUNCE	==	69
VOPID_TORECANNOUNCE	==	70
VOPID_TOSTOP	==	71
VOPID_TOERASEMSG	==	72
VOPID_TOSETANSONOFF	==	73
VOPID_TOERASEALLMSG	==	74
VOPID_TORECMEMO	==	75
VOPID_TOGOBACKMENU	==	76
VOPID_TOSETANNCE1OR2	==	77
VOPID_STAR	==	78
VOPID_HASH	==	79
VOPID_MEMFULL	==	80
VOPID_OUTGOING	==	81
;-------------------------------------------------------------------------------