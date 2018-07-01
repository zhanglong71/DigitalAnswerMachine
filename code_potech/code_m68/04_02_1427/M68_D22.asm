;*******************************************************************************
;
;	MXIC MD20U CODE
;
;*******************************************************************************
;telphone - mode working group 0 ==>(0XE600) 存贮来电号码
;telphone - mode working group 1 ==>(0XE601) 存贮MAILBOX1中ICM对应的电话号码
;telphone - mode working group 2 ==>(0XE602) 存贮去电号码(redail)
;telphone - mode working group 3 ==>(0XE603) 存贮紧急号码(M1,M2,M3)
;telphone - mode working group 4 ==>(0XE604) 存贮电话本电话号码
;telphone - mode working group 5 ==>(0XE605) 存贮DAM信息PSWORD---(byte0..2)
;							contrast---(byte3)
;							local code---(byte4..7)
;MAILBOX1 - 0XD001_0XD200(MEMO)
;MAILBOX1 - 0XD001_0XD202(OGM)
;-----------
;GPA(0..3)	- reserved
;GPA(4..7)	- reserved	(INPUT)
;GPA(8,9)	- ~MSG_LED/~SPK_LED	(OUTPUT)
;GPA(10..15)	- reserved	(INPUT)
;-----
;GPB.0		- CPC_DET	(INPUT)
;GPB.1		- LINE_REV	(INPUT)
;GPB.2		- RING_DET	(INPUT)
;GPB.3		- reserved
;GPB.4		- reserved	(INPUT)
;GPB.5		- reserved	(OUTPUT)follow GPBD.1
;GPB.6		- reserved	(OUTPUT)
;GPB.7		- OFF_HOOK	(OUTPUT)
;GPB.8		- reserved	(INPUT)
;GPB.9		- IIC Request	(OUTPUT)
;GPB(10,11)	- IIC commulication
;GPB.12		- /MUTE		(INPUT)
;Register indirect Addressing save only in interrupt==>AR1
;TMR1;用于时间更新DateTime(0--1000)
;TMR2;用于key detect
;TMR3;用于ring detect
;PRO_VAR = 
;静态状态	------------------------
;ANN_FG :	bit0=
;		bit1=	0/1 - ring invaild/vaild
;		bit2=	0/1 - New FSK/DTMF - CID received
;		bit3=	
;		------
;		bit4=
;		bit5=
;		bit6=
;		bit7=	
;		------
;		bit8=	0/1---record/play OGM_ID(temp flag for OGM)
;		bit9=
;		bit10=
;		bit11=	0/1---mute(the last state of GPBD.12)
;		------
;		bit12=	0/1---no/new messages(current mailbox current message type)---(MSG_CHK)
;
;		bit13=	0,not memory full---(MSG_CHK)
;			1,memory full
;		bit14=	0,no message---(current mailbox current message type)
;			1,have message
;		bit15=
;动态事件	------------------------
;EVENT :	bit0=
;		bit1=
;		bit2=
;		bit3=	1/0------speakerphone/not
;		bit4=	1/0------line mode/not
;		bit5=	1/0------beep mode/not
;		bit6=	1/0------vp mode/not
;		bit7=	1/0------record mode/not

;		bit8=	1/0------answer only/ICM
;		bit9=	1/0------answer off/on
;		bit10=	1/0------hook off/on(可等同于是/否接通线路)

;		bit11=	1/0------DTMF happened/no(for remote)
;		bit12=	1/0------DTMF happened/no(for cid)

;		bit13=	1/0------Cas-Tone happened/end
;		bit14=
;		bit15=
;
;DAM_ATT:	bit(15..12) = RING_CNT
;		bit11 = CallScreening
;		bit10 = ???reserved
;		bit(9,8) = language 
;		bit(7..4) = SPK_Gain
;		bit(3..0) = PLAY_VOL
;
;DAM_ATT0:	bit(15..12)= pause time
;		bit(11..8) = flash time
;		bit(7..4) = ring melody
;		bit(3..0) = LCD contrast
;
;DAM_ATT1:	bit(15..12)= ???reserved
;		bit(11..8) = ???reserved
;		bit(7..4) = CompressRate
;		bit(3..0) = ring volume
;-------------------------------------------------------------------------------
.NOLIST
.INCLUDE	include/REG_D22.inc
.INCLUDE	include/MD22U.inc
.INCLUDE	include/CONST.inc
;-------------------------------------------------------------------------------
.GLOBAL	DspPly
.GLOBAL	DspStop

;.GLOBAL	ANNOUNCE_NUM

.GLOBAL	BBBEEP
.GLOBAL	BBEEP
.GLOBAL	BEEP
.GLOBAL	BEEP_START
.GLOBAL	BEEP_STOP
.GLOBAL	BCVOX_INIT

;.GLOBAL	CMIN_GET
;.GLOBAL	CHOUR_GET
;.GLOBAL	CWEEK_GET
;.GLOBAL	CURR_WEEK
;.GLOBAL	CURR_HOUR
;.GLOBAL	CURR_MIN


.GLOBAL	CLR_FUNC
.GLOBAL	CLR_TIMER
.GLOBAL CLR_TIMER0

.GLOBAL	DAA_SPK
.GLOBAL	DAA_REC
.GLOBAL	DAA_OFF
.GLOBAL	DAA_ANS_SPK
.GLOBAL	DAA_ANS_REC
.GLOBAL	DAA_LIN_SPK
.GLOBAL	DAA_LIN_REC
.GLOBAL	DAM_BIOSFUNC
.GLOBAL	DAM_BIOSFUNC1
.GLOBAL	DELAY
;.GLOBAL	DAT_WRITE
;.GLOBAL	DAT_WRITE_STOP
;.GLOBAL	DEL_ALLTEL
;.GLOBAL	DEL_ONETEL
.GLOBAL	DGT_TAB
.GLOBAL	DGT_HEX

.GLOBAL	HEX_DGT

;.GLOBAL	EXIT_TOIDLE

.GLOBAL	GC_CHK
;.GLOBAL	GET_SEGCODE
.GLOBAL	GETBYTE_DAT
.GLOBAL	GET_VPTLEN

.GLOBAL	HOOK_ON
.GLOBAL	HOOK_OFF
.GLOBAL	HOUR_SET

.GLOBAL	INIT_DAM_FUNC


.GLOBAL	LINE_START
.GLOBAL	LBEEP
.GLOBAL	LOCAL_PRO

.GLOBAL	MIN_SET
.GLOBAL	MIDI_STOP
.GLOBAL	MIDI_WCOM

.GLOBAL	OGM_SELECT
.GLOBAL	OGM_STATUS
.GLOBAL	OGM_TEMP

.GLOBAL	PHONE_START
.GLOBAL	PUSH_FUNC

;.GLOBAL	REAL_DEL
.GLOBAL	REC_START

.GLOBAL	SEC_SET
.GLOBAL	SEND_DAT
.GLOBAL	SEND_MSGNUM
;.GLOBAL	SEND_MFULL
;.GLOBAL	SEND_RECSTART
.GLOBAL	SEND_TEL
.GLOBAL	SET_DECLTEL

;.GLOBAL	SET_DTMFTYPE
;.GLOBAL	SET_MICGAIN
.GLOBAL	SET_COMPS
.GLOBAL	SET_PLYPSA
;.GLOBAL	SET_SPKVOL

.GLOBAL	SET_TIMER
.GLOBAL SET_TIMER0

.GLOBAL	STOR_MSG
.GLOBAL	STORBYTE_DAT
.GLOBAL	STOR_VP

.GLOBAL	TEL_GC_CHK

.GLOBAL	TELNUM_WRITE
.GLOBAL	TELNUM_READ

.GLOBAL	VALUE_ADD
.GLOBAL	VALUE_SUB
.GLOBAL	VOL_TAB
.GLOBAL	VPMSG_CHK
.GLOBAL	VPMSG_DEL
.GLOBAL	VPMSG_DELOLD

.GLOBAL	WEEK_SET
;---
.GLOBAL	VP_DefOGM
;-------------------------------------------------------------------------------
.LIST
;-------------------------------------------------------------------------------
;CID_PAGE	.equ		1	;for CID and Display
CPC_TLEN	.EQU		80	;for CPC
;PHONE_TLEN	.EQU		80	;
LED1_60		.EQU		60	;for LED1 on
LED1_300	.EQU		300	;for LED1 on
CPC_DELAY	.EQU   		1000	;HOOK_ON之后与开始CPC检测时间间隔
CLINE_DELAY	.EQU   		10	;LINE回到高到GPBD5回到低的时间延迟

DspTest		.EQU   	0	;0===>测试用
BeepTest	.EQU   	0	;0===>测试用
NoUse		.EQU   	0	;0===>测试用
;-------------------------------------------------------------------------------
.EXTERN	SetFlashStartAddress
.EXTERN	LoadHostCode
.EXTERN	GetOneConst	;(INPUT=ACCH(ProgramRamAddress),OUTPUT=ACCH(ReadData))
.EXTERN	GetMoreConst	;(INPUT=ACCH(ProgramRamStartingAddress)ACCL(ReadWordNumber)AR1(StoreDataRamAddress),OUTPUT=)
.EXTERN	SET_PHONERUN	;LOCAL_PROPHO

.EXTERN	INITDSP
.EXTERN	ANS_STATE
.EXTERN	REMOTE_PRO
.EXTERN	LOCAL_PROREC
.EXTERN	LOCAL_PROPLY
.EXTERN	LOCAL_PROOGM
.EXTERN	LOCAL_PROTWR
.EXTERN	LOCAL_PROMNU
.EXTERN	LOCAL_PROPHO
.EXTERN	LOCAL_PROTXT
.EXTERN	LOCAL_PROCID
.EXTERN	LOCAL_PROTEL

;-----------------------------------------------------------------------------------------
.ORG	ADDR_FIRST
	BS	B1,Main
	BS	B1,IntTimer1	;0x02:  1-ms timer, goto _timerInt_1
	BS	B1,IntTimer2	;0x04:  0.5-ms timer, goto _timerInt_2
	BS	B1,IntIo1	;0x06:  GPIO interrupt portB-0
	BS	B1,IntIo2	;0x08:  GPIO interrupt portB-1
	BS	B1,IicInt	;0x0A;  IIC interrupt for MCU I/F
;******************************************************************************************* 
;purpose:   IIC interrupt, non-use in DSP mode
;*******************************************************************************************
IicInt:
	SAR	CURT_ADR1,1	;Save AR1
;---------------------------------------
	ldpk    0
	lipk	5
	in	INT_TTMP1,IICSR    	;IICSR-->INT_TTMP1
	bit	INT_TTMP1,0
	bz	TB, IicIntEnd
	bit	INT_TTMP1,15
	bz	TB, IicInt_01		;INT_TTMP1.15==0 (in Rx opertion)
	call	IicTx
	BS	B1,IicIntEnd
IicInt_01:
	call    IicRx
IicIntEnd:
;---------------------------------------
	LAR	CURT_ADR1,1	;reload AR1

	RET
;-------------------------------------------------------------------------------
; 	0.5ms timer interrupt
;-------------------------------------------------------------------------------
IntTimer2:
	RET
;-------------------------------------------------------------------------------
;	Io-port interrupt---portB-0
;-------------------------------------------------------------------------------
IntIo1:
	RET
;-------------------------------------------------------------------------------
;	Io-port interrupt---portB-1
;-------------------------------------------------------------------------------
IntIo2:
	RET
;-------------------------------------------------------------------------------
;	1ms timer interrupt
;-------------------------------------------------------------------------------
IntTimer1:
	
	SAR	CURT_ADR1,1	;Save AR1
;---------------------------------------
	LAC	TMR2
	ADHK	0X01
	ANDL	0Xff0f
	SAH	TMR2	;+1/1ms
	
	LAC     TMR2
	ANDK	0X03
	BZ	ACZ,IntTimer1_1
	
	LAC     TMR_BTONE	;for BUSY TONE(+1/4ms)
	ADHK    0X01
	SAH     TMR_BTONE

IntTimer1_1:
;-------belows are for key_scan_out-----
	LAC	TMR_VOX		;for VOX detection(-1/ms when >0)
	BS	SGN,IntTimer1_2
	SBHK	0X01
	SAH	TMR_VOX
IntTimer1_2:
;-------belows are for key_scan_out-----
	LAC	TMR_CTONE	;for CONT TONE(-1/ms when >0)
	BS	SGN,IntTimer1_3
	SBHK	0X01
	SAH	TMR_CTONE
IntTimer1_3:
;-------belows are for TMR3-------------
	LAC	TMR3		;for ring detection(-1/ms)
	SBHK	0X01
	SAH	TMR3
IntTimer1_key_scan:
;-------belows are for key_scan_out-----
	;CALL	INT_KEYSCAN_OUT
;------ BELOWS ARE FOR RING CHECKING (FREQUENCY RANGE : 15 - 95 Hz) ------------
IntTimer1_RingChk:
	CALL	RING_CHK
IntTimer1_RingChk_END:
;------ BELOWS ARE FOR LINE CHECKING------------------------------- ------------
IntTimer1_LineChk:
	LIPK	8
	IN	INT_TTMP1,GPBD
	BIT	INT_TTMP1,1
	BS	TB,IntTimer1_LineChk_H
;IntTimer1_LineChk_L:
	LACK	0
	SAH	TMR_LINE
	
	LAC	SER_FG
	ORL	1<<CbLINE
	SAH	SER_FG
	
	CALL	GPBD5_H
	BS	B1,IntTimer1_LineChk_END
IntTimer1_LineChk_H:	
	LAC	TMR_LINE
	SBHK	CLINE_DELAY	;
	BS	SGN,IntTimer1_LineChk_H_1

	LAC	SER_FG
	ANDL	~(1<<CbLINE)
	SAH	SER_FG

	CALL	GPBD5_L
	BS	B1,IntTimer1_LineChk_END
IntTimer1_LineChk_H_1:
	
	LAC	TMR_LINE
	ADHK	1
	SAH	TMR_LINE
	
IntTimer1_LineChk_END:
;-------belows are for timer----------------------------------------------------
INT_T_TIMER:
	LAC	TMR_BAK
	BS	ACZ,INT_T_TIMER_END
	LAC	TMR
	SBHK	1
	SAH	TMR
	BZ	ACZ,INT_T_TIMER_END
	LAC	TMR_BAK
	SAH	TMR
	LACL	CMSG_TMR
	CALL	INT_STOR_MSG	
INT_T_TIMER_END:
;-------belows are for timer2 -------------------------------------------------
INT_T_TIMER2:
	LAC	TMR0_BAK
	BS	ACZ,INT_T_TIMER2_END
	LAC	TMR0
	SBHK	1
	SAH	TMR0
	BZ	ACZ,INT_T_TIMER2_END

	LAC	TMR0_BAK
	SAH	TMR0
	LACL	CMSG_TMR0
	CALL	INT_STOR_MSG
INT_T_TIMER2_END:
;-------belows are forbeep time,stor msg when TMR_BEEP=0--------------
INT_T_BEEP:
	LAC	TMR_BEEP
	BS	SGN,INT_T_BEEP_END
	SBHK	1
	SAH	TMR_BEEP
	BZ	ACZ,INT_T_BEEP_END
	LACL	CSEG_END
	CALL	INT_STOR_MSG
INT_T_BEEP_END:
;-------belows are for Delay------------------------------------------
INT_T_DELAY:
	LAC	TMR_DELAY
	BS	SGN,INT_T_DELAY_END
	SBHK	1
	SAH	TMR_DELAY
	BZ	ACZ,INT_T_DELAY_END
	;LACL	CMSG_DELAY
	;CALL	INT_STOR_MSG
INT_T_DELAY_END:
;-------belows are for key_scan_in----------------------------------------------
	;CALL	INT_KEYSCAN_IN
;------ BELOWS ARE FOR LED DISPLAY ---------------------------------------------
IntTimer1_7SEGLED:
	;CALL	INT_LEDDISP
IntTimer1_7SEGLED_END:	
;-------belows are LED1 on/off/flash--------------------------------------------
;	DAM status : 	OFF - MSGLED_L
;			ON  - 	ANN_FG.12(new message) =1 - MSGLED_FLASH
;							0 - MSGLED_H
;-------------------------------------------------------------------------------
IntTimer1_LED1:
	BIT	EVENT,9
	BS	TB,IntTimer1_LED1_OFF
	BIT	ANN_FG,12
	BZ	TB,IntTimer1_LED1_ON
;---LED1-flash
	LAC	TMR_LED1
	BS	SGN,IntTimer1_LED1_Flash
	SBHK	1
	SAH	TMR_LED1
	BS	B1,IntTimer1_LED1_end
IntTimer1_LED1_Flash:
	LACL	(2000-LED1_300)
	SAH	TMR_LED1
	
	IN      INT_TTMP1,GPAD
        BIT	INT_TTMP1,CbMSGLED
        BZ	TB,IntTimer1_LED1_FlashExe
        
	LACL	LED1_300
	SAH	TMR_LED1
	;BS	B1,IntTimer1_LED1_FlashExe
IntTimer1_LED1_FlashExe:
	CALL	MSGLED_FLASH
	BS	B1,IntTimer1_LED1_end	
IntTimer1_LED1_ON:
	CALL	MSGLED_L
	BS	B1,IntTimer1_LED1_end
IntTimer1_LED1_OFF:
	LACK	0
	SAH	TMR_LED1
	CALL	MSGLED_H
IntTimer1_LED1_end:
;-------belows are for Ring time------------------------------------------------
;-------check ring count
INT_T_ExeRnt:
	BIT	EVENT,10
	BS	TB,INT_T_ExeRnt_0	;HOOK_Off-摘机了吗？
	BIT	EVENT,9
	BS	TB,INT_T_ExeRnt_10	;OFF
	BIT	ANN_FG,13
	BS	TB,INT_T_ExeRnt_10	;FULL
;---	
	LAC	DAM_ATT
	SFR	12
	ANDK	0X0F
	BS	ACZ,INT_T_ExeRnt_TollSave
	SAH	INT_TTMP1
	
	LAC	RING_ID
	ANDL	0XFFF0
	OR	INT_TTMP1
	SAH	RING_ID
	
	BS	B1,INT_T_ExeRnt_end
INT_T_ExeRnt_TollSave:
	BIT	ANN_FG,12
	BS	TB,INT_T_ExeRnt_2
	BS	B1,INT_T_ExeRnt_5
INT_T_ExeRnt_0:				;已在接线状态
	LACK	0
	SAH	RING_ID
	BS	B1,INT_T_ExeRnt_end
INT_T_ExeRnt_2:				;TollSave(new message exist)
	LAC	RING_ID
	ANDL	0XFFF0
	ORK	2
	SAH	RING_ID
	BS	B1,INT_T_ExeRnt_end
INT_T_ExeRnt_5:				;TollSave
	LAC	RING_ID
	ANDL	0XFFF0
	ORK	5
	SAH	RING_ID
	BS	B1,INT_T_ExeRnt_end
INT_T_ExeRnt_10:			;在Answer off状态
	LAC	RING_ID
	ANDL	0XFFF0
	ORK	10
	SAH	RING_ID
	BS	B1,INT_T_ExeRnt_end
	
INT_T_ExeRnt_end:
;-------belows are for cpc-det--------------------------------------------------
INT_CPC_DET:
        BIT	EVENT,10		;摘机了(hook_off)吗?
	BZ	TB,INT_CPC_DET_OFFLINE
	
	LAC	TMR_CPC
	SBHL	CPC_TLEN
	BZ	SGN,INT_CPC_DET4
	
	LIPK	8	
	IN	INT_TTMP1,GPBD
	BIT	INT_TTMP1,0
	BS	TB,INT_CPC_DET2		;高电平复位计数(Low pulse)
	;BZ	TB,INT_CPC_DET2		;低电平复位计数(High pulse)
INT_CPC_DET1:
	LAC     TMR_CPC
        SBHK    1
        SAH     TMR_CPC
        BS	ACZ,INT_CPC_DET3
	BS	B1,INT_CPC_DET_END
INT_CPC_DET2:
	LACK	CPC_TLEN
	SAH	TMR_CPC

	BS	B1,INT_CPC_DET_END
INT_CPC_DET3:	
	LACL	CMSG_CPC
	CALL	INT_STOR_MSG
	BS	B1,INT_CPC_DET_END
INT_CPC_DET4:
	LAC	TMR_CPC
	SBHK	1
	SAH	TMR_CPC		
	BS	B1,INT_CPC_DET_END
	
INT_CPC_DET_OFFLINE:
	LACL	(CPC_DELAY+CPC_TLEN)
	SAH	TMR_CPC
INT_CPC_DET_END:
;-------belows are for MUTE--------------------------------------------------
INT_MUTE_DET:
        BIT	EVENT,3		;SPKPHONE(免提状态)吗?
	BZ	TB,INT_MUTE_DET_END
	
	BIT	ANN_FG,11
	BS	TB,INT_MUTE_DET_HIGH
;INT_MUTE_DET_LOW:	
	LIPK	8
	IN	INT_TTMP1,GPBD
	BIT	INT_TTMP1,12
	BZ	TB,INT_MUTE_DET_END
;---LOW -> HIGH	
	LACL	CMSG_UNMUTE
	CALL	INT_STOR_MSG
	
	LAC	ANN_FG
	ORL	1<<11
	SAH	ANN_FG
	
	BS	B1,INT_MUTE_DET_END
INT_MUTE_DET_HIGH:
	LIPK	8
	IN	INT_TTMP1,GPBD
	BIT	INT_TTMP1,12
	BS	TB,INT_MUTE_DET_END
;---HIGH -> LOW
	LACL	CMSG_MUTE
	CALL	INT_STOR_MSG
	
	LAC	ANN_FG
	ANDL	~(1<<11)
	SAH	ANN_FG
	
	;BS	B1,INT_MUTE_DET_END	
INT_MUTE_DET_END:
;-------belows are for Iic Req--------------------------------------------------
.if	1
INT_REQUEST_DET:
	BIT	SER_FG,CbRx
	BS	TB,INT_REQUEST_STOP	;正在收,不请求发送
	
	CALL	SENDBUF_CHK
	ADHK	0
	BZ	ACZ,INT_REQUEST_DETOK	;有数据,请求发送
	
	BIT	SER_FG,CbBUSY
	BZ	TB,INT_REQUEST_STOP	;IIC Busy
                                      
INT_REQUEST_DETOK:	
;---REQUEST START
	CALL	REQ_START
	BS	B1,INT_REQUEST_DET_END
INT_REQUEST_STOP:
	CALL	REQ_STOP
INT_REQUEST_DET_END:
.endif
;-------------------------------------------------------------------------------
	LAR	CURT_ADR1,1	;reload AR1
;---------------------------------------
	RET

;-------------------------------------------------------------------------------
;	Function : DAM_BIOSFUNC
;	input : ACCH = command
;	output: ACCH = respone
;-------------------------------------------------------------------------------
DAM_BIOSFUNC:
	SAH     0x00
DAM_BIOSFUNC_DOING:
	CALL    0x10
	LAC     0x01

	RET
;-------------------------------------------------------------------------------
;	Function : DAM_BIOSFUNC1
;	input : ACCH = command
;	output: ACCH = respone
;-------------------------------------------------------------------------------
DAM_BIOSFUNC1:
	SAH     0x02
	BS	B1,DAM_BIOSFUNC_DOING
;-------------------------------------------------------------------------------
;       Function : VPMSG_CHK
;       Check some FLASH status:ANN_FG : bit0..15
;	input  : no
;	output : no
;	ANN_FG :
;		bit12=	0/1---no/new messages(current mailbox current message type)---(MSG_CHK)

;		bit13=	0,not memory full
;			1,memory full
;		bit14=	0,current mailbox have no message
;			1,current mailbox have message

;		MSG_T=	the number of TOTAL MESSAGE
;		MSG_N=	the number of NEW MESSAGE
;-------------------------------------------------------------------------------
VPMSG_CHK:
        PSH     CONF
;-------get the new message number,save it in MSG_N-----------------------------

	LACL    0xD001          ;set mailbox number
	CALL	DAM_BIOSFUNC
	LACL    0xD200          ;set message type MEMO
	CALL	DAM_BIOSFUNC
;VPMSG_CHK1:
	
        LACL	0X3001
	CALL	DAM_BIOSFUNC		;save the number of NEW messages
	SAH	MSG_N
	BZ      ACZ,VPMSG_CHK1_1

	LAC	ANN_FG		;clear ANN_FG.12
	ANDL	~(1<<12)
	SAH	ANN_FG
	BS	B1,VPMSG_CHK1_2
VPMSG_CHK1_1:
	LAC	ANN_FG		;ANN_FG(bit12)=0/1---not have/have new message(current mbox,current type)
	ORL	1<<12
	SAH	ANN_FG
VPMSG_CHK1_2:
;-------get the total message number,save it in MSG_T---------------------
;VPMSG_CHK2: 
	LAC	ANN_FG    	;ANN_FG(bit14)=1/0---have/not have message(current mbox,current type)
	ORL	1<<14
	SAH	ANN_FG

        LACL	0X3000
	CALL	DAM_BIOSFUNC	;save the number of TOTAL messages
	SAH	MSG_T
        BZ	ACZ,VPMSG_CHK2_1

	LAC	ANN_FG		;clear ANN_FG.14
	ANDL	~(1<<14)
	SAH	ANN_FG

VPMSG_CHK2_1:
;-------check if memory is full ?-----------------------------------------
;VPMSG_CHK3:
        LAC     MSG_T
        SBHK    99		;check if the total message number >= 99 ?
        BZ      SGN,VPMSG_CHK3_1

	LACL    0X3003		;check if memory is full ?
	CALL	DAM_BIOSFUNC
       	SBHK	3
        BZ      SGN,VPMSG_CHK3_2
VPMSG_CHK3_1:	
  	LAC	ANN_FG
  	ORL	1<<13		;set ANN_FG.13
	SAH	ANN_FG
	BS	B1,VPMSG_CHK3_3
VPMSG_CHK3_2:
	LAC	ANN_FG		;clear ANN_FG.13
	ANDL	~(1<<13)
	SAH	ANN_FG
VPMSG_CHK3_3:
;------------------------------------------------------------------------------
VPMSG_CHK_RET:
;-------------------------------------------------------------------------------
        POP     CONF
        RET

;-------------------------------------------------------------------------------
;	OGM_SELECT
;	check weather the current OGMx exist?
;	input : ACCH = 	OGMx
;	output: ACCH = 	MSG_ID(OGMx对应的ID号)
;			0/~0 ---无对应OGM/OGMx对应的ID号
;
;		MSG_ID		= index NO.in current MBOX in current MSG type(OGM)
;		MSG_N = 101/102	= the current OGM index(USR INDEX DATA0)
;-------------------------------------------------------------------------------
OGM_SELECT:			;用于录音/放音时确定OGM_ID(非接线时用)
	LACK	COGM2_ID

	BIT	EVENT,8		;answer only?
	BS	TB,OGM_SELECT_1
	
	LACK	COGM1_ID
OGM_SELECT_1:
	SAH	MSG_N
	CALL	OGM_STATUS1
	
	RET
;-------------------------------------------------------------------------------
OGM_TEMP:			;本地录音/播放时使用
	LACK	COGM2_ID

	BIT	ANN_FG,8	;OGM2
	BS	TB,OGM_SELECT_1
	
	LACK	COGM1_ID
	BS	B1,OGM_SELECT_1
;-------------------------------------------------------------------------------
;	OGM_STATUS
;	check weather the current OGMx exist?
;	input : EVENT.8		= 0/1---answer ICM/answer only
;		EVENT.9		= 0/1---answer on/off
;		ANN_FG.13	= 0/1---not/memoful
;	output: ACCH = 1/0 --- the OGM exist/no OGM
;
;		MSG_ID		= index NO.in current MBOX in current MSG type(OGM)(0..MSG_T)
;		MSG_N = 101/102 = the current OGM index(USR INDEX DATA0)
;-------------------------------------------------------------------------------
OGM_STATUS:			;接线时用
	LACK	COGM1_ID
	SAH	MSG_N

	BIT	EVENT,8		;answer only?
	BS	TB,OGM_STATUS0
	BIT	EVENT,9		;answer off?
	BS	TB,OGM_STATUS0
	BIT	ANN_FG,13	;memoful?
	BS	TB,OGM_STATUS0
	BS	B1,OGM_STATUS1
OGM_STATUS0:	
	LACK	COGM2_ID
	SAH	MSG_N		;answer only(OGM5)
OGM_STATUS1:
	LACL	0XD000
	CALL	DAM_BIOSFUNC
	
	LACL	0XD201
	CALL	DAM_BIOSFUNC	;OGM1
	
	LAC	MSG_N
	SBHK	COGM1_ID
	BS	ACZ,OGM_STATUS2
OGM_STATUS1_1:	
	LACL	0XD202
	CALL	DAM_BIOSFUNC	;OGM2
	
OGM_STATUS2:
	LACL	0X3000
	CALL	DAM_BIOSFUNC
	SAH	MSG_ID		;OGMx exist/not
        RET
	
;----------------------------------------------------------------------------
;       Function : TEL_GC_CHK/GC_CHK
;
;       Check garbage collection
;-------------------------------------------------------------------------------
TEL_GC_CHK:
	LACL    0XE403		;check if free block number
        CALL    DAM_BIOSFUNC
        SBHK	CTEL_MNUM
        BS	SGN,TEL_GC_CHK_END

        LACL    0XE405		;check if garbage collection is required ?
        CALL    DAM_BIOSFUNC
        BS      ACZ,TEL_GC_CHK_END

        LACL    0XE407		;do garbage collection
        CALL    DAM_BIOSFUNC
        BS      ACZ,TEL_GC_CHK	;full?(for D20)
TEL_GC_CHK_END:
;-------------------------------------------------------------------------------
GC_CHK:
	LACL    0X3007   		; do garbage collection
        CALL    DAM_BIOSFUNC

	LACL    0X3005           	; check if garbage collection is required ?
        CALL    DAM_BIOSFUNC
        BZ      ACZ,GC_CHK

	LACK	CTEL_MNUM
	CALL	SET_DECLTEL

	RET
;-------------------------------------------------------------------------------
;	Function : SET_DECLTEL
;	Set TEL-message declare
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
SET_DECLTEL:
	SAH	SYSTMP1
;---
	LACL	0X5FA0
	CALL	DAM_BIOSFUNC
	ANDL	0XFF00
	BZ	ACZ,SET_DECLTEL_END	;error,exit
	LAC	SYSTMP1
	CALL	DAM_BIOSFUNC
;---
SET_DECLTEL_END:
	RET
;-------------------------------------------------------------------------------
;	Function : MSGLED_H/MSGLED_L/MSGLED_FLASH - (only - interrupt)
;-------------------------------------------------------------------------------
MSGLED_H:
	LIPK	8

	IN	INT_TTMP1,GPAD	;GPAD.CbMSGLED = 1
	LAC	INT_TTMP1
	ORL	1<<CbMSGLED
	SAH	INT_TTMP1
	OUT	INT_TTMP1,GPAD
	ADHK	0
	
	RET
;---------------
MSGLED_L:
	LIPK	8

	IN	INT_TTMP1,GPAD	;GPAD.CbMSGLED = 0
	LAC	INT_TTMP1
	ANDL	~(1<<CbMSGLED)
	SAH	INT_TTMP1
	OUT	INT_TTMP1,GPAD
	ADHK	0
	
	RET
;---------------
MSGLED_FLASH:
	LIPK	8

	IN	INT_TTMP1,GPAD	;GPAD.CbMSGLED = 0
	LAC	INT_TTMP1
	XORL	1<<CbMSGLED
	SAH	INT_TTMP1
	OUT	INT_TTMP1,GPAD
	ADHK	0
	
	RET
;-------------------------------------------------------------------------------
;	Function : SPK_H/SPK_L
;-------------------------------------------------------------------------------
.if	0
SPK_H:
	LIPK	8

	IN	SYSTMP1,GPAD	;GPAD.CbSPK = 1
	LAC	SYSTMP1
	ORL	1<<CbSPK
	SAH	SYSTMP1
	OUT	SYSTMP1,GPAD
	ADHK	0
	
	RET

;-----------------------------
SPK_L:
	LIPK	8

	IN	SYSTMP1,GPAD	;GPAD.CbSPK = 0
	LAC	SYSTMP1
	ANDL	~(1<<CbSPK)
	SAH	SYSTMP1
	OUT	SYSTMP1,GPAD
	ADHK	0
	
	RET
.endif
;-------------------------------------------------------------------------------
;	Function : CIDTALK_H/CIDTALK_L
;-------------------------------------------------------------------------------
.if	0
INT_CIDTALK_H:

	LIPK	8

	IN	INT_TTMP1,GPAD	;GPAD.CbCIDMUTE = 1
	LAC	INT_TTMP1
	ORL	1<<CbCIDMUTE
	SAH	INT_TTMP1
	OUT	INT_TTMP1,GPAD
	ADHK	0
	
	RET

;---
INT_CIDTALK_L:

	LIPK	8

	IN	INT_TTMP1,GPAD	;GPAD.CbCIDMUTE = 0
	LAC	INT_TTMP1
	ANDL	~(1<<CbCIDMUTE)
	SAH	INT_TTMP1
	OUT	INT_TTMP1,GPAD
	ADHK	0
	
	RET

;---------------------------------------

CIDTALK_L:
	DINT
	CALL	INT_CIDTALK_L
	EINT
	RET
CIDTALK_H:

	DINT
	CALL	INT_CIDTALK_H
	EINT
	RET
.endif
;-------------------------------------------------------------------------------
DAA_MIDI_SPK:	;(SW2)&(SW7) ==> (LIN->ADC)&(AUX->ADC)&(DAC->SPK)
	LIPK    6
        OUTL    ((1<<2)|(1<<7)),SWITCH

	NOP
	OUTL	(0X0A<<4),AGC
	LAC	DAM_ATT1	;
	ANDK	0X07
	ADHL	MIDIVOL_TAB
	CALL	GetOneConst
	SAH	CODECREG2
	OUT	CODECREG2,LOUTSPK
	ADHK	0

	RET
;-------------------------------------------------------------------------------
DAA_SPK:	;(SW2)&(SW7) ==> (LIN->ADC)&(AUX->ADC)&(DAC->SPK)
	LIPK    6
        OUTL    ((1<<2)|(1<<7)),SWITCH

	NOP
	OUTL	(0X0A<<4),AGC
	LAC	DAM_ATT		;
	ANDK	0X07
	ADHL	VOL_TAB
	CALL	GetOneConst
	SAH	CODECREG2
	SFL	5
	OR	CODECREG2
	SAH	CODECREG2
	
	OUT	CODECREG2,LOUTSPK
	ADHK	0
;---
	;CALL	SPK_L		;

	RET
;---
DAA_REC:	;(SW0) ==> (MIC->ADC)
	LIPK    6
	OUTK	1,SWITCH

	NOP
	OUTL	(0X05<<8)|(0X07<<4),AGC
;---
	RET

;---------------------------------------
DAA_OFF:	;(all open)
.if	1
	LIPK	6
	OUTK	1<<2,SWITCH	;AUX -> AD0
	OUTL	(0X0A<<4),AGC
.else
	PSH	CONF
	LACL	0x5E08		;AUX -> AD0
	CALL	DAM_BIOSFUNC
	POP	CONF
.endif
	;CALL	SPK_H		;

	RET
;---------------------------------------
DAA_ANS_SPK:	
	LIPK    6
	OUTL    ((1<<1)|(1<<3)),SWITCH		;(SW1)&(SW3)&(SW7) ==> (LIN->ADC0)&(DAC0->SPK)&(DAC1->LOUT)

	BIT	DAM_ATT,11
	BZ	TB,DAA_ANS_SPK_0

	OUTL    ((1<<1)|(1<<3)|(1<<7)),SWITCH	;(SW1)&(SW3) ==> (LIN->ADC0)&(DAC1->LOUT)
	NOP
DAA_ANS_SPK_0:
	OUTL	(0X7<<4),AGC
	NOP

	LAC	DAM_ATT
	ANDK	0X07
	ADHL	VOL_TAB
	CALL	GetOneConst
	ORL	(0X1F<<5)	;Lout gain
	SAH	CODECREG2
	OUT	CODECREG2,LOUTSPK
	ADHK	0

	RET
;---------------------------------------
DAA_ANS_REC:	
;---
	LIPK    6
        OUTL    (1<<1),SWITCH		;;(SW1) ==> (LIN->ADC)

	BIT	DAM_ATT,11
	BZ	TB,DAA_ANS_SPK_0

        OUTL    ((1<<1)|(1<<7)),SWITCH	;(SW1)&(SW7) ==> (LIN->ADC)&(DAC->SPK)
	NOP
DAA_ANS_REC_0:
;---
	OUTL	(0X7<<4),AGC
	NOP
;---
	LAC	DAM_ATT
	ANDK	0X07
	ADHL	VOL_TAB
	CALL	GetOneConst

	ORL	(0X1F<<5)	;Lout gain
	SAH	CODECREG2
	OUT	CODECREG2,LOUTSPK
	ADHK	0

	RET
;---------------------------------------
DAA_LIN_SPK:	;(SW1)&(SW3) ==> (LIN->ADC)&(DAC->SPK)&(DAC->LOUT)
	LIPK    6
        OUTL    ((1<<1)|(1<<3)),SWITCH
        NOP
	OUTL	((0x1F<<5)|(0x17<<10)),LOUTSPK
	NOP

	RET
DAA_LIN_REC:	;(SW1) ==> (LIN->ADC)&(DAC->SPK)
	LIPK    6
        OUTL    (1<<1),SWITCH
	NOP
	OUTL	((0x1C<<5)|(0x17<<10)),LOUTSPK
	NOP
	;OUTL	(0X9<<4),AGC
	OUTL	(0X7<<4),AGC
	NOP	
	
	RET

;-------------------------------------------------------------------------------
SetCodecReg:
        LIPK    6

	OUT	CODECREG2,LOUTSPK
	ADHK	0

        RET
;----------------------------------------------------------------------------
;       Function : SET_COMPS
;
;       Set the speech compression algorithm
;	(0XD107)	;0 - 3.6kbps
;	(0XD107)|(1<<3)	;1 - 4.8kbps
;	(0XD107)|(2<<3)	;2 - 6.0kbps
;	(0XD107)|(3<<3)	;3 - 7.2kbps
;	(0XD107)|(4<<3)	;4 - 8.4kbps
;	(0XD107)|(5<<3)	;5 - 9.6kbps
;-------------------------------------------------------------------------------
SET_COMPS:
	BIT	DAM_ATT,10
	BS	TB,SET_COMPS_96K

	LACL	(0XD107)|(2<<3)	;2 - 6.0kbps
	BS	B1,SET_COMPS_DONE
SET_COMPS_96K:
	LACL	(0XD107)|(5<<3)	;5 - 9.6kbps
SET_COMPS_DONE:
	CALL	DAM_BIOSFUNC
	RET

;-------------------------------------------------------------------------------
;	Function : BEEP_START
;	
;	The general function for beep generation
;	Input  : BUF1=the beep frequency
;-------------------------------------------------------------------------------
BEEP_START:
	LACL    CBEEP_COMMAND            	;// beep start
	CALL    DAM_BIOSFUNC

        RET

;//----------------------------------------------------------------------------
;//       Function : BEEP_STOP
;//
;//       The general function for beep generation
;//-----------------------------------------------------------------------------
BEEP_STOP:
        LACL    0X4400            	;// beep stop
        CALL    DAM_BIOSFUNC

        RET
;-------------------------------------------------------------------------------
DELAY:
	SAH	TMR_DELAY
DELAY_LOOP:
	LAC     TMR_DELAY
        BZ      SGN,DELAY_LOOP
	RET

;-------------------------------------------------------------------------------
HOOK_OFF:		;Set (GPAD.CbHOOK)&(EVENT.10)(摘机状态)
	
	LAC	EVENT
	ORL	1<<10
	SAH	EVENT

	RET
	
;-------
HOOK_ON:		;Reset (GPAD.CbHOOK)&(EVENT.10)(挂机状态)

	LAC	EVENT
	ANDL	~(1<<10)
	SAH	EVENT

	RET
;-------------------------------------------------------------------------------
GPBD5_H:		;Set (GPBD.5)
	LIPK	8
	IN	INT_TTMP1,GPBD
	LAC	INT_TTMP1
	ORL	1<<5
	SAH	INT_TTMP1
	OUT	INT_TTMP1,GPBD
	ADHK	0

	RET
;-------
GPBD5_L:		;Reset (GPBD.5)
	LIPK	8
	IN	INT_TTMP1,GPBD
	LAC	INT_TTMP1
	ANDL	~(1<<5)
	SAH	INT_TTMP1
	OUT	INT_TTMP1,GPBD
	ADHK	0

	
	RET
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;???????????????????????????????????????????????????????????????????????????????
DspStop:
	dint
DspStop_loop:
	nop
	nop
	nop
	nop
	bs	b1,DspStop_loop
;-------
DspPly:
	adhk	0X11
	sah	SYSTMP0
DspPly1:
	lac	SYSTMP0
	SFR	4
	andk	0xf
	orl	0xB000
	sah	CONF
DspPly_loop1:
	CALL	DAM_BIOS
	BIT	RESP,6
	BZ	TB,DspPly_loop1
	
	lac	SYSTMP0
	andk	0xf
	orl	0xB000
	sah	CONF
DspPly_loop2:
	CALL	DAM_BIOS
	BIT	RESP,6
	BZ	TB,DspPly_loop2
	
	bs	b1,DspPly1
;-------------------------------------------------------------------------------
DTMF_TABLE:
 	;no	1	2	3	4	5	6	7	8	
.DATA	0X00	0XF1	0XF2	0XF3	0XF4	0XF5	0XF6	0XF7	0XF8

	;9	*	0	#	A	B	C	D
.DATA	0XF9	0XFE	0XF0	0XFF	0XFA	0XFB	0XFC	0XFD  
;-------------------------------------------------------------------------------
VOL_TAB:
	;0	1	2	3	4	5	6	7
.DATA	0X01	0X05	0X0A	0X0F	0X13	0X17	0X1B	0X1F

;Note: We use bit(4..0) for SPVOL
;-------------------------------------------------------------------------------
MIDIVOL_TAB:
	;0	1	2	3	4
.DATA	0X01	0X05	0X0A	0X0F	0X13

;Note: We use bit(4..0) for MIDIVOL
;-------------------------------------------------------------------------------
DGT_TAB:
;	     A
;	     __
;	  F |G |B
;	    |__|
;	  E |  |C
;	    |__| .	;.GFEDCBA<===>OPTR(7..0)
;	     D
;	0	1	2	3	4	5	6	7
;.DATA   0XC0	0XF9	0XA4	0XB0	0X99	0X92	0X82	0XF8
;	8	9	A	b	C	d	E	F
;.DATA   0X80	0X90	0X88	0X83	0XC6	0XA1	0X86	0X8E
;	bL	rE	dE	--	PA	rA	Ln	FL
;	0X83C7	0XAF86	0XA186	0XBFBF	0X8C88	0XAF88	0XC7AB	0X8EC7
;	下线	中下线	上中下线Fu	PR	Er	tt
;	0XF7	0XB7	0XB6	0X8EE3	0X8C88	0X86Af	0X8787
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;	上一年最后一天到上个月最后一天的天数,折算成变化的星期数(不算闰年)
DATE_TAB:
	;31	28	31	30	31	30	31	31	30	31	30	31
	;1月	2月	3月	4月	5月	6月	7月	8月	9月	10月	11月	12月
.DATA	0	3	3	6	1	4	6	2	5	0	3	5
;-------------------------------------------------------------------------------

.INCLUDE	syspro.asm
.INCLUDE	local.asm
;---------------------------------------
;.INCLUDE	block\initial.asm

.INCLUDE	block\ring_det.asm
.INCLUDE	block\main.asm
.INCLUDE	block\gui.asm
.INCLUDE	block\Iic.asm
.INCLUDE	block\drive.asm
.INCLUDE	block\l_move.asm
.INCLUDE	block\voice_p.asm
.INCLUDE	block\l_setctime.asm
.INCLUDE	block\l_midi.asm
.INCLUDE	block\telmsg_wr.asm

.END

