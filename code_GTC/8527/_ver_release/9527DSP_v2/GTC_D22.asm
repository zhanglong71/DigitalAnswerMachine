;*******************************************************************************
;
;	MXIC MD20U CODE
;
;*******************************************************************************
;telphone - mode working group 0 ==>(0XE600) 存贮来电号码
;telphone - mode working group 1 ==>(0XE601) 存贮MAILBOX1中ICM对应的电话号码
;telphone - mode working group 2 ==>(0XE604) 存贮电话本电话号码
;telphone - mode working group 3 ==>(0XE605) 存贮DAM信息PSWORD---(byte0..2)
;							contrast---(byte3)
;							local code---(byte4..7)
;MAILBOX1 - 0XD001_0XD200(MEMO)
;MAILBOX1 - 0XD001_0XD202(OGM)
;-----------
;GPA(0..3)	- OFF_HOOK/SPK_ON/CIDTALK_MUTE/HFAMP(OUTPUT)
;GPA(4..7)	- reserved	(INPUT)
;GPA(8,9)	- ~MSG_LED/~SPK_LED	(OUTPUT)
;GPA(10..15)	- for SPEAKERPHONE attribute	(INPUT)
;-----
;GPB.0		- CPC_DET	(INPUT)
;GPB.1		- LINE_REV	(INPUT)
;GPB.2		- RING_DET	(INPUT)
;GPB.3		- reserved
;GPB.4		- HW-ALC control port		(OUTPUT)
;GPB(5..8)	- for SPEAKERPHONE attribute	(INPUT)

;GPB.9		- IIC Request	(OUTPUT)
;GPB(10,11)	- IIC commulication
;GPB.12		- /MUTE
;Register indirect Addressing save only in interrupt==>AR1
;TMR2;用于key detect
;TMR3;用于ring detect
;PRO_VAR = 
;静态状态	------------------------
;ANN_FG :	bit0=	0/1---not/initial
;		bit1=
;		bit2=
;		bit3=
;		------
;		bit4=	
;		bit5=
;		bit6=
;		bit7=	
;		------
;		bit8=	0/1---no/have current OGM
;		bit9=	1/0---review CID/not
;		bit10=	1/0---up/down review CID/not
;		bit11=	1/0---MUTE port(GPBD,12) status
;		------
;		bit12=	0/1---no/new messages(current mailbox current message type)---(MSG_CHK)
;
;		bit13=	0,not memory full---(VPMSG_CHK)
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

;		bit11=	1/0------DTMF happened/end
;		bit12=	1/0------Cas-Tone happened/end

;		bit13=	1/0------Enable/disable amplify
;		bit14=	1/0------MSGLED ctrl
;		bit15=	1/0------TestMode
;
;VOI_ATT:	bit(15..12) = RING_CNT
;		bit11 = CallScreening
;		bit10 = CompressRate
;		bit(9,8) = language 
;		bit(7..4) = SPK_Gain
;		bit(3..0) = SPK_VOL
;ERR_FG		bit(15..2)reserved
;		bit1 --- All new messages played but new message exist/not
;		bit0 --- 1/0 --> FFW/REW key pressed/not
;-------------------------------------------------------------------------------
.NOLIST
.INCLUDE	include/REG_D22.inc
.INCLUDE	include/MD22U.inc
.INCLUDE	include/CONST.inc
;-------------------------------------------------------------------------------
.GLOBAL	SYS_MSG_ANS
.GLOBAL	SYS_MSG_RMT
;---------------------------------------

.GLOBAL	CLR_FUNC
.GLOBAL	CLR_MSG
.GLOBAL	CLR_TIMER

.GLOBAL	DAM_BIOSFUNC
.GLOBAL	DAM_STOP
.GLOBAL	DELAY
;.GLOBAL	DGT_HEX

.GLOBAL	GC_CHK
.GLOBAL	GET_LANGUAGE
.GLOBAL	GET_MSG

;.GLOBAL	HEX_DGT

.GLOBAL	INIT_DAM_FUNC
.GLOBAL	INT_STOR_MSG

.GLOBAL	LINE_START
.GLOBAL	LOCAL_PRO

.GLOBAL	PUSH_FUNC

.GLOBAL	REC_START
.GLOBAL	REQ_START

.GLOBAL	SET_TIMER
.GLOBAL	STOR_MSG
;-------------------------------------------------------------------------------
.LIST
;-------------------------------------------------------------------------------
;CID_PAGE	.equ		1	;for CID and Display

DspTest		.EQU   	0	;0===>测试用
BeepTest	.EQU   	0	;0===>测试用
NoUse		.EQU   	0	;0===>测试用
;-------------------------------------------------------------------------------
.EXTERN	SetFlashStartAddress
.EXTERN	LoadHostCode
.EXTERN	GetOneConst	;(INPUT=ACCH(ProgramRamAddress),OUTPUT=ACCH(ReadData))
.EXTERN	GetMoreConst	;(INPUT=ACCH(ProgramRamStartingAddress)ACCL(ReadWordNumber)AR1(StoreDataRamAddress),OUTPUT=)
;-------------------------------------------------------------------------------
.EXTERN	INITDSP		;f_init
.EXTERN	ANS_STATE
.EXTERN	REMOTE_PRO
.EXTERN	LOCAL_PROREC
.EXTERN	LOCAL_PROPLY
.EXTERN	LOCAL_PROOGM
.EXTERN	LOCAL_PROPHO
.EXTERN	LOCAL_PROTXT
.EXTERN	LOCAL_PROERA
.EXTERN	LOCAL_PROKEYVP
.EXTERN	LOCAL_PROCIDVP
;---------
.EXTERN	SER_COMMAND	;GET_COMMAND
.EXTERN	INT_KEYMUTE	;Detect key mute
.EXTERN	INT_CPC_DET
;-------------------------------------------------------------------------------
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
IntTimer2:	;0.5ms timer interrupt
IntIo1:		;Io-port interrupt---portB-0
IntIo2:		;Io-port interrupt---portB-1
	RET
;-------------------------------------------------------------------------------
;	1ms timer interrupt
;-------------------------------------------------------------------------------
IntTimer1:
	
	SAR	CURT_ADR1,1	;Save AR1
;---------------------------------------
	LAC	TMR2
	ADHK	0X01
	ANDK	0X0f
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
;------ BELOWS ARE FOR RING CHECKING (FREQUENCY RANGE : 15 - 95 Hz) ------------
IntTimer1_RingChk:
	CALL	RING_CHK
IntTimer1_RingChk_END:
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
;-------belows are for Delay----------------------------------------------------
INT_T_DELAY:
	LAC	TMR_DELAY
	BS	SGN,INT_T_DELAY_END
	SBHK	1
	SAH	TMR_DELAY
	BZ	ACZ,INT_T_DELAY_END
	
INT_T_DELAY_END:
;-------------------------------------------------------------------------------
INT_PHOLED_FG:
	LAC	PHOLED_FG
	BS	ACZ,INT_PHOLED_FG_END	;On

	LACK	1
	BIT     RING_ID,10        ;check if in ring on state ?
        BZ      TB,INT_PHOLED_FG_END
        LACK	74

INT_PHOLED_FG_END:
	SAH	PHOLED_FG
;-------belows are MSGLED/PHOLED on/off/flash-----------------------------------

;-------------------------------------------------------------------------------
.if	0

.else
	LIPK	8

	IN      INT_GPAD,GPAD
	LAC     INT_GPAD
	ANDL    ~((1<<CbMSGLED)|(1<<CbPHOLED))
	SAH     INT_GPAD
	
	MAR	+0,1
	LARK	MSGLED_FG,1
	CALL    INT_TIMER
	ANDL    1<<CbMSGLED
	OR      INT_GPAD
	SAH     INT_GPAD
	
	LARK	PHOLED_FG,1
	CALL    INT_TIMER
	ANDL    1<<CbPHOLED
	OR      INT_GPAD
	SAH     INT_GPAD

	OUT     INT_GPAD,GPAD
	ADHK    0
.endif
;-------check ring count
.if	1
INT_T_ExeRnt:
	BIT	EVENT,10
	BS	TB,INT_T_ExeRnt_0	;HOOK_Off-摘机了吗？
	BIT	EVENT,9
	BS	TB,INT_T_ExeRnt_10	;OFF
	BIT	ANN_FG,13
	BS	TB,INT_T_ExeRnt_10	;FULL
;---	
	LAC	VOI_ATT
	SFR	12
	ANDK	0X0F
	SBHK	1
	BS	ACZ,INT_T_ExeRnt_TollSave
	SAH	INT_TTMP1
	
	LAC	RING_ID
	ANDL	0XFFF0
	OR	INT_TTMP1
	SAH	RING_ID
	
	BS	B1,INT_T_ExeRnt_end
INT_T_ExeRnt_TollSave:
	BIT	ANN_FG,12
	BS	TB,INT_T_ExeRnt_3
	BS	B1,INT_T_ExeRnt_5
INT_T_ExeRnt_0:				;已在接线状态
	LACK	0
	SAH	RING_ID
	BS	B1,INT_T_ExeRnt_end
INT_T_ExeRnt_3:				;TollSave(new message exist)
	LAC	RING_ID
	ANDL	0XFFF0
	ORK	3
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
.endif

;-------belows are for cpc-det--------------------------------------------------
IntTimer1_CPC:
        BIT	EVENT,10		;摘机了(hook_off)吗?
	BZ	TB,IntTimer1_CPC_OFFLINE	;Note!!!Speakerphone完全由MCU控制,DSP不必对HOOK脚位进行控制

	CALL	INT_CPC_DET
	BS	B1,IntTimer1_CPC_END
IntTimer1_CPC_OFFLINE:
	LACL	(CPC_DELAY+CPC_TLEN)
	SAH	TMR_CPC
IntTimer1_CPC_END:
;-------belows are for MUTE-----------------------------------------------------
INT_MUTE_DET:	
	BIT	EVENT,3		;SPKPHONE(免提状态)吗?
	BZ	TB,INT_MUTE_DET_END
	CALL	INT_KEYMUTE
INT_MUTE_DET_END:
;-------belows are for Iic Req--------------------------------------------------
.if	0
INT_REQUEST_DET:
	BIT	SER_FG,8
	BS	TB,INT_REQUEST_STOP	;正在收,不请求发送
	
	CALL	SENDBUF_CHK
	ADHK	0
	BS	ACZ,INT_REQUEST_STOP	;无数据,不请求发送
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
	CALL    0x10
	LAC     0x01

	RET
;-------------------------------------------------------------------------------
DELAY:
	SAH	TMR_DELAY
DELAY_LOOP:
	LAC     TMR_DELAY
        BZ      SGN,DELAY_LOOP
	RET

;----------------------------------------------------------------------------
;       Function : GC_CHK
;
;       Check garbage collection
;----------------------------------------------------------------------------
GC_CHK:
	LACL    0X3005           	; check if garbage collection is required ?
        CALL    DAM_BIOSFUNC
        BS      ACZ,GC_CHK_END
        
        LACL    0X3007   		; do garbage collection
        CALL    DAM_BIOSFUNC
        BS	B1,GC_CHK
GC_CHK_END:      
	RET
;----------------------------------------------------------------------------
;       Function : INT_TIMER
;
;       TIMER
;----------------------------------------------------------------------------
INT_TIMER:
	LAC     +		;The current indirector pointer the next address
        SAH     INT_TTMP1       ;Get cycle timer
        BS      ACZ,INT_TIMER_INVERT_0
        SBHK    1
        BS      ACZ,INT_TIMER_INVERT_1
INT_TIMER_INVERT:
        LAC     +0	;Note!!!This get the TimerCounter
        ADHK    1
        SAH     +0
        ANDL    0x0FFF
        SBH     INT_TTMP1
        BS      SGN,INT_TIMER_INVERT_CHK
        LAC     +0
        ANDL    0xF000
	XORL    0x1000
        SAH     +0
INT_TIMER_INVERT_CHK:
        BIT     +0,12
        BS      TB,INT_TIMER_INVERT_1
INT_TIMER_INVERT_0:
        LACK    0
        RET
INT_TIMER_INVERT_1:
        LACL    0xFFFF
        
        RET
;-------------------------------------------------------------------------------

.INCLUDE	l_ring/ring_det.asm
.INCLUDE	l_Iic/l_iic.asm

.INCLUDE	l_wdt.asm
.INCLUDE	main.asm
.INCLUDE	gui.asm
.INCLUDE	syspro.asm
.INCLUDE	local.asm
.INCLUDE	drive.asm

;.INCLUDE	l_flashmsg/l_plynoise.asm
;---------------------------------------------
.END

