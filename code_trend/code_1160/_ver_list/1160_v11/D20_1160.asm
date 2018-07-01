.NOLIST
;MD20---2008-5-5 14:28
;Register indirect Addressing save only in interrupt==>AR1
;TMR1;用于时间更新DateTime(0--1000)
;TMR2;用于key detect
;TMR3;用于ring detect
;PRO_VAR = 
;ANN_FG :	bit0=	1/0---initial/initial complete
;		bit1=	1/0---caller id valid/caller id invalid(来铃失败/退出应答/应答密码PASS时清除,收到来电信息时置位)
;		bit2=	1/0---receiving CID/receive CID end
;		bit3=	0/1 = OGM1/OGM2(select vp and status)
;		------
;		bit4=	0,remote operation-DTMF end
;			1,remote operation-DTMF happened---(DTMF detected process for"busy_chk")
;		------
;		bit5=	0/1---no/new ICM messages(mailbox1)
;		bit6=	0/1---no/new ICM messages(mailbox2)
;		bit7=	0/1---no/new ICM messages(mailbox3)
;		bit8=	0/1---no/new ICM messages(current mailbox current message type)---(VPMSG_CHK)
;		bit9=	0/1---no/new messages(mailbox1)	
;		bit10=	0/1---no/new messages(mailbox2)
;		bit11=	0/1---no/new messages(mailbox3)
;		bit12=	0/1---no/new messages(current mailbox current message type)---(VPMSG_CHK)
;
;		bit13=	0,not memory full---(VPMSG_CHK)
;			1,memory full
;		bit14=	0,no message---(current mailbox current message type)
;			1,have message
;		bit15=	reserved
;		--------------------------
;EVENT :	bit0=	1/0---需要等待收/发号码吗?		来电写入判断
;		bit1=	1/0---需要等待收/发姓名吗?		来电写入判断
;		bit2=	1/0---需要等待收/发时间吗?		来电写入判断
;		bit3=	1/0---需要等待收/发OGM号吗?	来电写入判断,全零就开始写入
;		bit4=	1/0------line mode/not
;		bit5=	1/0------beep mode/not
;		bit6=	1/0------vp mode/not
;		bit7=	1/0------record mode/not
;		bit8=	1/0------answer only/ICM(=0时,VOI_ATT11..8有效;=1时无效)
;		bit9=	1/0------answer on/off
;		bit10=	- reserved-发送显示命令(当EVENT(3..0)=0时执行)
;		bit11=  1/0---12/24时制选择;default=(EVENT.11=0) ==>24时制)
;		bit12=	1/0------ring in ok/no
;		bit13=	1/0------LED1 flash	(new caller_id)
;		bit14=	1/0------LED2 flash	(answer ON/OFF---new messages)
;		bit15=	1/0---hook (摘机/挂机)
;		--------------------------
;INT_EVENT	bit0 --- reserved	
;		bit1 --- 1/0 = key pressed/released
;		bit(2..15) --- reserved
;		--------------------------
;VOI_ATT:	bit(3..0) = ATT1
;		bit(7..4) = RING_CNT
;		bit(11..8)= OGM_ID
;		bit(13,12)= LANGUAGE(0/1/2/3 - German/English/Reserved/Reserved)
;		bit14 = 1/0------BeepVoicePrompt/not
;		bit15 = 1/0------NewMsgBeepPrompt/not
;VOP_FG:	bit(7..0) --- Saved 0X88 command
;		bit(9,8) --- reserved	
;		bit10 --- 0/1---no/new ICM messages(mailbox4)
;		bit11 --- 0/1---no/new messages(mailbox4)
;		bit(13,12) = number/VIP/Filter/(for lookup phonebook)	
;		bit14 =	1/0------New VIP-CID exist/not(for BeepRING)
;		bit15 = 1/0------Adjust Menu/not	
;		--------------------------
;GPAD :		bit(8..0) --- reserved			I
;		bit(11..9) ---key 			O
;		bit(15..12)---key			I
;		--------------------------
;GPBD :		bit0 = CPC-DET				I
;		bit1 = CompressRate			I(0/1 - 4.8/9.6kbps)
;		bit2 = ring-det				I
;		bit3 = LED 背光				O
;		bit4 = 2-way hook			O
;		bit5 = LED on/off			O
;		bit6 = CID message			O
;		bit7 = off-hook				O
;		bit8 = language	select			I(0/1 - English/German)
;		bit9 = IIC-REQ				O
;		bit(12,11,10) = IIC(busy/clk/dat)	I/O
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;telphone - mode working group 0 ==>(0XE600) 存贮来电号码
;telphone - mode working group 1 ==>(0XE601) 存贮MAILBOX1中ICM对应的电话号码
;telphone - mode working group 2 ==>(0XE602) 存贮MAILBOX2中ICM对应的电话号码
;telphone - mode working group 3 ==>(0XE603) 存贮MAILBOX3中ICM对应的电话号码
;telphone - mode working group 4 ==>(0XE604) 存贮电话本电话号码
;telphone - mode working group 5 ==>(0XE605) 存贮DAM信息PSWORD---(byte0..3)
;							local code---(byte4..7)(reserved)
;							Rnt	--- (byte8)
;							Contrast--- (byte9)
;							Language--- (byte10)
;
;MAILBOX1 - 0XD001_0XD200(MEMO)
;MAILBOX2 - 0XD002_0XD200(MEMO)
;MAILBOX3 - 0XD003_0XD200(MEMO)

;MAILBOX0 - 0XD000_0XD202(OGM)
;default base(num/name) address = (new1/new10)
;//------------------------------------------------------------------------------
.INCLUDE MD20U.INC
.INCLUDE REG_D20.inc
.INCLUDE CONST.INC
.LIST

ALC_ON		.EQU   		1

GCVP_TLEN	.EQU   		2000	;录满了一次做GC_CHK的最长时间(ms)
GCTEL_TLEN	.EQU   		1000	;录满了一次做GC_TEL_CHK的最长时间(ms)
CPC_TLEN	.EQU   		80	;CPC检测的有效宽度
CPC_DELAY	.EQU   		1000	;HOOK_ON之后与开始CPC检测时间间隔

TESTPLY		.EQU   		0	;0
TEXT_IVOP	.EQU   		0	;0
TEXT_EVOP	.EQU   		1	;1
TEXT_FVOP	.EQU   		0	;0

TEXT_TEST	.EQU   		0	;0===>测试用
TEXT_KSCAN	.EQU   		1	;1===>同时将BUSY_H/L屏蔽
TEXT_SIOVP	.EQU   		0	;0===>正常工作不用接收命令测试
TEXT_0X9041	.EQU   		0	;0===>不要频繁格式化flash
TEXT_WTELNUM	.EQU   		0	;0===>不用模拟写号码

DAM_BIOS  	.EQU   		0X10
;-------------------------------------------------------------------------------
.global	INT_STOR_MSG
;---------------------------------------
.extern	LOCAL_PROMEM	;record memo
.extern	LOCAL_PROOGM	;OGM record OGM
.extern	LOCAL_PROPLY	;local play
.extern	LOCAL_PROCID	;look up CID

.extern	LOCAL_PROBOOK1	;phonebook(look up/dial/)
.extern	LOCAL_PROBOOK2	;phonebook(add)
.extern	LOCAL_PROBOOK3	;phonebook(edit)
.extern	LOCAL_PROBOOK4	;phonebook(edit CID and stor in pbook)

.extern	LOCAL_PROMENU1	;menu1(select language)
.extern	LOCAL_PROMENU2	;menu2(set date/time)
.extern	LOCAL_PROMENU3	;menu3(set contrast)
.extern	LOCAL_PROMENU4	;menu4(set password)
.extern	LOCAL_PROMENU5	;menu5(set local-code)
.extern	LOCAL_PROMENU6	;menu6(set ring cnt)
.extern	LOCAL_PROMENU7	;menu7(select/record/play OGM)

.extern	LOCAL_PROFIXF	;fixf function
.extern	TWAY_STATE	;2-way record
.extern	ANS_STATE	;answering
.extern	REMOTE_PRO	;remote control

;---------------------------------------
.global	ANNOUNCE_NUM
.global	B_VOP
.global	BB_VOP
.global	BEEP
.global	BEEP_START
.global	BEEP_STOP
.global	BBEEP
.global	BBBEEP
.global	PBBEEP
.global	RBEEP
.global	BCVOX_INIT
.global	BLED_ON
.global	BLED_OFF
.global	CLR_BUSY_FG
.global	CLR_FUNC

.global	CLR_MSG
.global	CLR_LED1FG
.global	CLR_TIMER

.global	COMP_ALLTELNUM
.global	CONCEN_DAT
.global	DAA_REC
.global	DAA_SPK
.global	DAA_BSPK

.global	DAA_ANS_SPK
.global	DAA_ANS_REC
.global	DAA_LIN_SPK
.global	DAA_LIN_REC
.global	DAA_TWAY_REC
.global	DAA_OFF
.global	DAM_BIOSFUNC

.global	DAT_WRITE
.global	DAT_WRITE_STOP
.global	DATETIME_WRITE
.global	DECONCEN_DAT
.global	DEFOGM_LOCALPLY
.global	DEFATT_WRITE
.global	DEL_ALLTEL
.global	DELAY

.global	DEL_ONETEL

;.global	FFW_MANAGE

.global	GC_CHK
;.global	GET_FILEID

.global	GETBYTE_DAT
.global	GET_INITLANGUAGE
.global	GET_LANGUAGE
.global	GET_MSG
.global	GETR_DAT

;.global	GET_MSGDAY
;.global	GET_MSGHOUR
;.global	GET_MSGMONTH
;.global	GET_MSGMINUTE

.global	GET_ONLYID
.global	GET_ONLYIDNEW
.global	GET_USRDAT
.global	GET_USRDATNEW

.global	GET_VPTLEN

.global	GET_TELID
.global	GET_TOTALMSG
.global	GET_TELT

.global	HEXDIV
.global	HOOK_OFF
.global	HOOK_ON

.global	INIT_DAM_FUNC
;.global	INITMCU

.global	LINE_START
.global	LBEEP

.global	MEMFULL_CHK
.global	MSG_CHK
.global	VPMSG_CHK

.global	MOVE_HTOL
.global	MOVE_LTOH

.global	NEWICM_CHK

.global	OGM_SELECT
.global	OGM_STATUS

.global	PUSH_FUNC

.global	RAM_STOR
.global	REC_START
.global	READ_TELNUM
.global	REAL_DEL

.global	SENDLANGUAGE

.global	SENDLOCACODE
.global	SEND_HHMMSS
.global	SEND_MSGNUM
.global	SET_COMPS
.global	SET_DECLTEL
.global	SET_LED1FG
;.global	SET_SILENCE
.global	SET_USRDAT
.global	SET_USRDAT1

.global	SET_TIMER
.global	SET_TELUSRDAT
.global	SET_TELGROUP

.global	STOPREADDAT
.global	STORBYTE_DAT
;.global	STOR_DAT
.global	SEND_DAT
.global	STOR_MSG
.global	STOR_VP

.global	TEL_GC_CHK
.global	TEL_SENDCOMM
.global	TELNUMALL_DEL
.global	TELNUM_WRITE
;.global	TELNUM_READ
.global	TOSENDBUF

.global	VALUE_ADD
.global	VALUE_SUB
;-------------------------------------------------------------------------------
.global	VP_DEFAULTOGM
.global	VP_DEFOGM5
.global	VP_ENDOF

.global	VP_MAILBOX
.global	VP_MESSAGE
.global	VP_MESSAGES
.global	VP_ONE
.global	VP_NO
.global	VP_NEW
.global	VP_MEMFUL
;-----------------------------
.global	TEST_VOP
;-------------------------------------------------------------------------------
.EXTERN	INITDSP
.EXTERN	INITMCU
.EXTERN	WAIT_MCUINIT
;---
.EXTERN	SetFlashStartAddress
.EXTERN	LoadHostCode
.EXTERN	GetOneConst	;(INPUT=ACCH(ProgramRamAddress),OUTPUT=ACCH(ReadData))
.EXTERN	GetMoreConst	;(INPUT=ACCH(ProgramRamStartingAddress)ACCL(ReadWordNumber)AR1(StoreDataRamAddress),OUTPUT=)

;//==============================================================================
;//+                        DAM DEMO PROGRAM                                    +
;//==============================================================================
.ORG    ADDR_FIRST
	BS	B1,Main
	BS	B1,IntTimer1	;0x02:  1-ms timer, goto _timerInt_1
	BS	B1,IntTimer2	;0x04:  0.125-ms timer, goto _timerInt_2
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
;-------------------------------------------------------------------------------
; 	0.125ms timer interrupt
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
;-------------------------------------------------------------------------------				

	LAC	TMR2
	ADHK	0X01
	ANDL	0XFF0F		;高8位另作他用
	SAH	TMR2		;+1/1ms
        ANDK	0X03
        BZ	ACZ,IntTimer1_1
        
        LAC     TMR_BTONE	;for BUSY TONE(+1/4ms)
        ADHK    0X01
        SAH     TMR_BTONE
IntTimer1_1:
		
	LAC	TMR_VOX		;//for VOX detection(-1/ms)
	SBHK	0X01
	SAH	TMR_VOX

	LAC	TMR_CTONE	;//for CONT TONE(-1/ms)
	SBHK	0X01
	SAH	TMR_CTONE

;//------ BELOWS ARE FOR LEDS DISPLAY AND KEY SCAN --------------------------
INT_FUNC_SCANKEY:
	;BIT	ANN_FG,2
	;BS	TB,INT_FUNC_SCANKEY_END		;收来电时,不响应按键
	
	;LAC	RING_ID
	;ANDL	0X0F0
	;BZ	ACZ,INT_FUNC_SCANKEY_END
	
	;BIT	RING_ID,10
	;BS	TB,INT_FUNC_SCANKEY_END		;有铃流(OFF)不响应按键
	
	CALL	KEYSCAN_CHK
INT_FUNC_SCANKEY_END:
;--------BELOWS ARE FOR ring detect -----------------------------------------
	LAC	TMR3		;for ring detection(-1/ms)
	SBHK	0X01
	SAH	TMR3
;---------------
	CALL	RING_CHK
;-------belows are for long of beep time,end beep when TMR_BEEP=0---------------
INT_T_BEEP:
	LAC	TMR_BEEP
	BS	SGN,INT_T_BEEP_END
	SBHK	1
	SAH	TMR_BEEP
	BZ	ACZ,INT_T_BEEP_END
	LACL	CSEG_END
	CALL	INT_STOR_MSG
INT_T_BEEP_END:
;-------belows are for long delay-----------------------------------------------
INT_T_DELAY:
	LAC	TMR_DELAY	;//for Delay(-1/ms)
	BS	SGN,INT_T_DELAY_END
	SBHK	1
	SAH	TMR_DELAY
INT_T_DELAY_END:
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
;-------belows are for LED1----------------------------------------------
;LED1工作原理:	闪烁标志EVENT.13为:	1 ===> 闪烁
;					0 ===> LED1 OFF
;								
;------------------------------------------------------------------------
INT_LED1:
	BIT	ANN_FG,0
	BS	TB,INT_LED1_END		;正在初始化
	
	BIT	EVENT,13
	BZ	TB,INT_LED1_2

	LAC	TMR_LED1
	BS	SGN,INT_LED1_1
	SBHK	1
	SAH	TMR_LED1
	BS	B1,INT_LED1_END
INT_LED1_1:
	CALL	LED1_FLASH
	LACL	1500
	SAH	TMR_LED1
	BS	B1,INT_LED1_END	
;-------
INT_LED1_2:
	CALL	LED1_HIGH
	;BS	B1,INT_LED1_END	
INT_LED1_END:
;-------belows are for LED2----------------------------------------------
;LED2工作原理:	DAM开关EVENT.9:	1 ===> LED2_OFF
;				0 ===> LED2_ON/LED2_FLASH
;						EVENT.14为:	1 ===> LED2_FLASH
;								0 ===> LED2_ON
;------------------------------------------------------------------------
INT_LED2:
	BIT	ANN_FG,0
	BS	TB,INT_LED2_END		;正在初始化
	
	BIT	EVENT,9
	BS	TB,INT_LED2_OFF
	;BS	B1,INT_LED2_OFF
	
	BIT	EVENT,14
	BZ	TB,INT_LED2_ON
	;BS	B1,INT_LED2_ON

	LAC	TMR_LED2
	BS	ACZ,INT_LED2_FLASH
	SBHK	1
	SAH	TMR_LED2
	BS	B1,INT_LED2_END
INT_LED2_FLASH:
	CALL	LED2_FLASH
	LACL	400
	SAH	TMR_LED2
	BS	B1,INT_LED2_END	
;-------
INT_LED2_ON:
	CALL	LED2_LOW
	BS	B1,INT_LED2_END	
INT_LED2_OFF:
	CALL	LED2_HIGH
INT_LED2_END:
;-------belows are for initial LED1/LED2 flash----------------------------------
;-------------------------------------------------------------------------------
INT_INIT:
	BIT	ANN_FG,0
	BZ	TB,INT_INIT_END		;初始化结束
	
	LAC	TMR_LED2
	BS	ACZ,INT_INIT_LED
	SBHK	1
	SAH	TMR_LED2
	BS	B1,INT_INIT_END
INT_INIT_LED:
	LIPK	8
	IN	INT_TTMP1,GPBD
	BIT	INT_TTMP1,5
	BS	TB,INT_INIT_LED_H
;INT_INIT_LED_L:
	
	CALL	LED1_HIGH
	CALL	LED2_HIGH
	BS	B1,INT_INIT_LED1
INT_INIT_LED_H:
	CALL	LED1_LOW
	CALL	LED2_LOW
INT_INIT_LED1:	
	LACL	400
	SAH	TMR_LED2
INT_INIT_END:	
;-------belows are for cpc-det--------------------------------------------------
INT_CPC_DET:
	LIPK	8
        IN	INT_TTMP1,GPBD
        BIT	INT_TTMP1,7		;摘机了(hook_on)吗?
	BZ	TB,INT_LOCAL_FUNC
	
	LAC	TMR_CPC
	SBHL	CPC_TLEN		;CPC时长
	BZ	SGN,INT_CPC_DET4

	LIPK	8
	IN	INT_TTMP1,GPBD
	BIT	INT_TTMP1,0
	;BZ	TB,INT_CPC_DET2		;For high pulse
	BS	TB,INT_CPC_DET2		;For low pulse
INT_CPC_DET1:
	LAC     TMR_CPC
        SBHK    1
        SAH     TMR_CPC
        BS	ACZ,INT_CPC_DET3
	BS	B1,INT_CPC_DET_END
INT_CPC_DET2:
	LACK	CPC_TLEN		;重新赋CPC时长
	SAH	TMR_CPC

	BS	B1,INT_CPC_DET_END
INT_CPC_DET3:	
	LACL	CMSG_CPC
	CALL	INT_STOR_MSG	;?????????????????????????????????????
	BS	B1,INT_CPC_DET_END
INT_CPC_DET4:
	LAC	TMR_CPC
	SBHK	1
	SAH	TMR_CPC		
	BS	B1,INT_CPC_DET_END
;-------hook_off,bellow for line detect
INT_LOCAL_FUNC:
	LACL	(CPC_DELAY+CPC_TLEN)
	SAH	TMR_CPC	

INT_CPC_DET_END:
;-------belows are for RING COUNT-----------------------------------------------
;工作原理:	RING_ID_BAK根据 GPBD.0的值确定;GPBD(1,0) = ----- (00/10=2),(01=6),(11=2/6) 铃声
;		RING_ID的取值原理:	DAM空闲时(FUNC_STACK=0),若开答录则RING_ID = RING_ID_BAK,否则RING_ID = 10
;					DAM忙时(FUNC_STACK!=0),RING_ID = 0
;-------------------------------------------------------------------------------
INT_RINGCNT:
	;LIPK	8
        ;IN	INT_TTMP1,GPBD
        ;BIT	INT_TTMP1,7		;摘机了(hook_on)吗?
	;BZ	TB,INT_RINGCNT1

	BIT	EVENT,15
	BZ	TB,INT_RINGCNT1

	LACK	0
	SAH	RING_ID
	BS	B1,INT_RINGCNT_END

INT_RINGCNT1:
	BIT	EVENT,9
	BZ	TB,INT_RINGCNT1_0

	LAC	RING_ID
	ANDL	0XFFF0
	ORK	10
	SAH	RING_ID	
	BS	B1,INT_RINGCNT_END
INT_RINGCNT1_0:
	LAC	RING_ID
	ANDL	0XFFF0
	SAH	RING_ID
	
	LAC	VOI_ATT
	SFR	4
	ANDK	0XF
	SBHK	2
	BS	SGN,INT_RINGCNT1_1

	LAC	VOI_ATT
	SFR	4
	ANDK	0X0F
	OR	RING_ID
	SAH	RING_ID
	
	BS	B1,INT_RINGCNT_END
INT_RINGCNT1_1:		;TollSaver
	LAC	RING_ID
	ORK	0X0002
	SAH	RING_ID
	
	BIT	VOP_FG,11		;(MBOX-4)new messages exist?
	BS	TB,INT_RINGCNT_END
	LAC	ANN_FG			;(MBOX-123)new messages exist?
	ANDL	0X0E00
	BZ	ACZ,INT_RINGCNT_END
	
	;BIT	ANN_FG,12
	;BS	TB,INT_RINGCNT_END
	
	LAC	RING_ID
	ORK	0X0006
	SAH	RING_ID	
INT_RINGCNT_END:

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
                                      
INT_REQUEST_DETOK:	;有数据或忙	
;---REQUEST START
	CALL	REQ_START
	BS	B1,INT_REQUEST_DET_END
INT_REQUEST_STOP:
	CALL	REQ_STOP
	CALL	INT_CLR_BUSY_FG	;MCU强制发送
INT_REQUEST_DET_END:
.endif	
;-------------------------------------------------------------------------------
	LAR	CURT_ADR1,1
	
	RET

;-------------------------------------------------------------------------------


;----------------------------------------------------------------------------
;       Function : TEL_GC_CHK/GC_CHK
;
;       Check garbage collection
;-------------------------------------------------------------------------------
TEL_GC_CHK:
	LACK	0
	SAH	SYSTMP0		;Clr flag	
	
	LACL    0XE404		;Get used TEL block number
        CALL    DAM_BIOSFUNC
        SBHK	31
        BS	SGN,TEL_GC_CHK_1

	LACK	1
	SAH	SYSTMP0		;Set flag
TEL_GC_CHK_0:
        LACL    0XE405		;check if garbage collection is required ?
        CALL    DAM_BIOSFUNC
        BS      ACZ,TEL_GC_CHK_1

        LACL    0XE407
        CALL    DAM_BIOSFUNC
        BS      ACZ,TEL_GC_CHK_0

        CALL	DAM_GC_CHK
        BS	B1,TEL_GC_CHK_0
TEL_GC_CHK_1:
	CALL	DAM_GC_CHK
TEL_GC_CHK_END:

	RET
;---------------------------------------
GC_CHK:
	LACK	0
	SAH	SYSTMP0			;Clr flag
DAM_GC_CHK:	
	LACL    0X3005           	; check if garbage collection is required ?
        CALL    DAM_BIOSFUNC
        BS      ACZ,DAM_GC_CHK_1
        
        LACL    0X3007   		; do garbage collection
        CALL    DAM_BIOSFUNC
        BS	B1,DAM_GC_CHK
DAM_GC_CHK_1:
	LAC	SYSTMP0
	BS	ACZ,SET_DECLTEL_END
;-------
SET_DECLTEL:
	LACL	0X5FA0
	CALL	DAM_BIOSFUNC
	ANDL	0XFF00
	BZ	ACZ,SET_DECLTEL_END	;error,exit
	LACK	CTEL_MNUM
	CALL	DAM_BIOSFUNC
SET_DECLTEL_END:

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
.if	0	;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	(0XD107)|(WRATE)
	CALL	DAM_BIOSFUNC
.else
	LIPK	8
	IN      SYSTMP0,GPBD
	BIT	SYSTMP0,1
	BS	TB,SET_COMPS_96

;SET_COMPS_48:	
	LACL	(0XD107)|(CRATE48bps)	;1 - 4.8kbps
	BS	B1,SET_COMPS_END
SET_COMPS_96:
	LACL	(0XD107)|(CRATE96bps)	;5 - 9.6kbps
SET_COMPS_END:	
	CALL	DAM_BIOSFUNC
	
.endif
	RET
;----------------------------------------------------------------------------
;       Function : SET_SILENCE
;
;       Set silence threshold level
;----------------------------------------------------------------------------
.if	1
SET_SILENCE:

	ANDK	0X0F
	ORL	0X7700
	CALL	DAM_BIOSFUNC

	RET
.endif	
;-------------------------------------------------------------------------------
;       Function : GET_TOTALMSG
;	for DSP
;	input  : no
;	output : ACCH = the number of total messages
;----------------------------------------------------------------------------
GET_TOTALMSG:
	LACL    0X3000
        CALL    DAM_BIOSFUNC

	RET
;----------------------------------------------------------------------------
;       Function : GET_NEWMSGNUM
;	input  : no
;	output : ACCH = the number of total messages in current mailbox in current message type
;----------------------------------------------------------------------------
GET_NEWMSGNUM:
	LACL    0X3001
        CALL    DAM_BIOSFUNC

	RET
;----------------------------------------------------------------------------
;       Function : MEMFULL_CHK(current mailbox current message type)
;	input  : no
;	output : ACCH = 1/0 ==>Full/no
;----------------------------------------------------------------------------
MEMFULL_CHK:
	
        CALL	GET_TOTALMSG
        SBHK    99		;check if the total message number >= 99 ?
        BZ      SGN,MEMFULL_CHK_FULL

        LACL    0X3003		;check if memory is less 4s ?
        CALL    DAM_BIOSFUNC
        SBHK	4
	BZ      SGN,MEMFULL_CHK_NOTFULL
MEMFULL_CHK_FULL:
	LACK	1
	
	RET
MEMFULL_CHK_NOTFULL:
	LACK	0
	RET

;----------------------------------------------------------------------------
;       Function : VPMSG_CHK
;       Check some FLASH status:ANN_FG : bit0..15
;	input  : MBOX_ID(1,2,3)
;	output : 

;	ANN_FG :
;		bit9=   0/1---no/new messages mailbox1
;		bit10=  0/1---no/new messages mailbox2
;		bit11=  0/1---no/new messages mailbox3

;		bit12=	0/1---no/new messages(current mailbox current message type)---(VPMSG_CHK)

;		bit13=	0,not memory full
;			1,memory full
;		bit14=	0,current mailbox have no message
;			1,current mailbox have message

;		MSG_T=	the number of TOTAL MESSAGE in current MAILBOX
;		MSG_N=	the number of NEW MESSAGE in current MAILBOX
;----------------------------------------------------------------------------
MSG_CHK:
VPMSG_CHK:
	LACL	0XD000
	OR	MBOX_ID
	CALL	DAM_BIOSFUNC
	
	LACL	0XD200
	CALL	DAM_BIOSFUNC
;-------get the new message number,save it in MSG_N-------------------------
MSG_CHK1:
        
        CALL    GET_NEWMSGNUM	;save the number of TOTAL messages		;save the number of NEW messages
        SAH	MSG_N
        BZ      ACZ,MSG_CHK1_1

	LAC	ANN_FG
	ANDL	~(1<<12)
	SAH	ANN_FG
	
        BS	B1,MSG_CHK1_OVER
MSG_CHK1_1:
	LAC	ANN_FG
	ORL	1<<12
	SAH	ANN_FG		;ANN_FG(bit12)=0/1---not have/have new message(current mbox,current type)
 
MSG_CHK1_OVER:	;-----------------------
	LAC	MBOX_ID
	SBHK	1
	BS	ACZ,MSG_CHK1_1_1
	SBHK	1
	BS	ACZ,MSG_CHK1_2_1
	SBHK	1
	BS	ACZ,MSG_CHK1_3_1
	SBHK	1
	BS	ACZ,MSG_CHK1_4_1
MSG_CHK1_1_1:	;---MBOX 1--------------
	BIT	ANN_FG,12
	BS	TB,MSG_CHK1_1_2
	
	LAC	ANN_FG
	ANDL	~(1<<9)
	SAH	ANN_FG
	BS	B1,MSG_CHK1_1_OVER
MSG_CHK1_1_2:
	LAC	ANN_FG
	ORL	1<<9
	SAH	ANN_FG
MSG_CHK1_1_OVER:
	BS	B1,MSG_CHK1_5
MSG_CHK1_2_1:	;---MBOX 2--------------
	BIT	ANN_FG,12
	BS	TB,MSG_CHK1_2_2
	LAC	ANN_FG
	ANDL	~(1<<10)
	SAH	ANN_FG
	BS	B1,MSG_CHK1_2_OVER
MSG_CHK1_2_2:
	LAC	ANN_FG
	ORL	1<<10
	SAH	ANN_FG
MSG_CHK1_2_OVER:
	BS	B1,MSG_CHK1_5
MSG_CHK1_3_1:	;---MBOX 3--------------
	
	BIT	ANN_FG,12
	BS	TB,MSG_CHK1_3_2

	LAC	ANN_FG
	ANDL	~(1<<11)
	SAH	ANN_FG
	BS	B1,MSG_CHK1_3_OVER
MSG_CHK1_3_2:
	LAC	ANN_FG
	ORL	1<<11
	SAH	ANN_FG
MSG_CHK1_3_OVER:
	BS	B1,MSG_CHK1_5
MSG_CHK1_4_1:	;---MBOX 4--------------
	
	BIT	ANN_FG,12
	BS	TB,MSG_CHK1_4_2

	LAC	VOP_FG
	ANDL	~(1<<11)
	SAH	VOP_FG
	BS	B1,MSG_CHK1_4_OVER
MSG_CHK1_4_2:
	LAC	VOP_FG
	ORL	1<<11
	SAH	VOP_FG
MSG_CHK1_4_OVER:
	;BS	B1,MSG_CHK1_5
;-------
MSG_CHK1_5:
	BIT	VOP_FG,11
	BS	TB,MSG_CHK1_5_SET
	LAC	ANN_FG
	ANDL	0X0E00
	BS	ACZ,MSG_CHK1_5_1
	;BS	B1,MSG_CHK1_5_1
MSG_CHK1_5_SET:
	CALL	SET_LED2FG
	BS	B1,MSG_CHK1_5_2
MSG_CHK1_5_1:
	CALL	CLR_LED2FG
MSG_CHK1_5_2:
	;BS	B1,MSG_CHK1_6
MSG_CHK1_6:
;-------get the total message number,save it in MSG_T---------------------
MSG_CHK2:     
        CALL    GET_TOTALMSG	;save the number of TOTAL messages
	SAH	MSG_T
        BS	ACZ,MSG_CHK2_1

        LAC	ANN_FG
	ORL	1<<14
	SAH	ANN_FG
        BS	B1,MSG_CHK2_OVER
MSG_CHK2_1:
	LAC	ANN_FG
	ANDL	~(1<<14)
	SAH	ANN_FG	;ANN_FG(bit14)=1/0---have/not have message(current mbox,current type)
	
MSG_CHK2_OVER:
;-------check if memory is full ?-----------------------------------------
MSG_CHK3:
	
        CALL	MEMFULL_CHK
        BS	ACZ,MSG_CHK3_1
	
  	LAC	ANN_FG
	ORL	1<<13
	SAH	ANN_FG
  	BS	B1,MSG_CHK3_OVER
MSG_CHK3_1:
	LAC	ANN_FG
	ANDL	~(1<<13)
	SAH	ANN_FG
MSG_CHK3_OVER:
;------------------------------------------------------------------------------
MSG_CHK_RET:
;------------------------------------------------------------------------------
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

;//----------------------------------------------------------------------------
;//       Function : BEEP_START
;//
;//       The general function for beep generation
;//       Input  : BUF1=the beep frequency
;//-----------------------------------------------------------------------------
BEEP_START:
	LACL    CBEEP_COMMAND	;// beep start
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
	ADHK	10
	SAH	TMR_DELAY
DELAY_LOOP:
	LAC     TMR_DELAY
	SBHK	10
        BZ      SGN,DELAY_LOOP
	RET
;-------------------------------------------------------------------------------
;	INPUT : ACCH
;	OUTPUT:	ACCH
;-------------------------------------------------------------------------------
SET_CODECPATH:
	PSH	CONF
;---
	CALL	DAM_BIOSFUNC
;---
	POP	CONF
	RET
;//-----------------------------------------------------------------------------
;//       Function : DAA_SPK
;//       Change analog switches for LOCAL OGM SPK/RECORD play
;//----------------------------------------------------------------------------
DAA_SPK:
	LACL	0X5E07
	CALL	SET_CODECPATH	

     	LIPK    6
        ;OUTL    ((1<<1)|(1<<3)|(1<<7)),SWITCH

	;NOP
	LAC	VOI_ATT		;
	ANDK	0X0F
	ADHL	VOL_TAB
	CALL	GetOneConst
	SAH	SYSTMP0
	OUT	SYSTMP0,LOUTSPK
	ADHK	0
	
	;OUTK	0,ANAPWR	;all power on
;---
	RET

;//-----------------------------------------------------------------------------
;//       Function : DAA_BSPK
;//       Change analog switches for LOCAL BEEP voice prompt play
;//----------------------------------------------------------------------------
DAA_BSPK:
	BIT	VOI_ATT,14
	
	BS	TB,DAA_SPK
	BS	B1,DAA_OFF
	
;-----------------------------------------------------------------------------
;       Function : DAA_REC
;       Change analog switches for LOCAL OGM/MEMO RECORD
;----------------------------------------------------------------------------
DAA_REC:	;(SW0) ==> (MIC->ADC)
	LACL	0X5E00
	CALL	SET_CODECPATH	

	LIPK    6
	;OUTK	1,SWITCH

	;NOP
	OUTL	(CMIC_PRE_GAIN<<8)|(CAD0_PRE_GAIN<<4),AGC
	;OUTK	0,ANAPWR	;all power on
	RET

;//---------------------------------------
DAA_LIN_SPK:
	LACL	0X5E05
	CALL	SET_CODECPATH	

	LIPK    6
        ;OUTL    ((1<<1)|(1<<3)),SWITCH
	OUTL	(CAD0_PRE_RGAIN<<4),AGC
        NOP
	OUTL	(CLNE_VOL<<5),LOUTSPK
	;OUTK	0,ANAPWR	;all power on
        RET
;---------------
DAA_LIN_REC:	;LIN==>SWC(b->A)==>SWD==>AD1
	LACL	0X5E04
	CALL	SET_CODECPATH	

	LIPK    6
        ;OUTL    (1<<1),SWITCH
	;NOP
	OUTL	(CAD0_PRE_RGAIN<<4),AGC
	NOP	
	OUTL	(CLNE_VOL<<5),LOUTSPK
	;OUTK	0,ANAPWR	;all power on

        RET
;---------------------------------------
DAA_ANS_REC:	;(SW1)&(SW7) ==> (LIN->ADC)&(DAC->SPK)
	LACL	0X5E05
	CALL	SET_CODECPATH
;---
	LIPK    6
        ;OUTL    ((1<<1)|(1<<7)),SWITCH
	;NOP
;---
	OUTL	(CAD0_PRE_RGAIN<<4),AGC
	;NOP
;---
	LAC	VOI_ATT
	ANDK	0X0F
	ADHL	VOL_TAB
	CALL	GetOneConst
	ORL	(CLNE_VOL<<5)	;Lout gain
	SAH	SYSTMP0
	OUT	SYSTMP0,LOUTSPK
	ADHK	0
	;OUTK	0,ANAPWR	;all power on
	
	RET
;---------------
DAA_ANS_SPK:	;(SW1)&(SW3)&(SW7) ==> (LIN->ADC)&(DAC->SPK)&(DAC->LOUT)
	LACL	0X5E07
	CALL	SET_CODECPATH		

	LIPK    6
        ;OUTL    ((1<<1)|(1<<3)|(1<<7)),SWITCH
	OUTL	(CAD0_PRE_RGAIN<<4),AGC
	;NOP
	;NOP
	LAC	VOI_ATT		;
	ANDK	0X0F
	ADHL	VOL_TAB
	CALL	GetOneConst
	ORL	(CLNE_VOL<<5)	;Lout gain
	SAH	SYSTMP0
	OUT	SYSTMP0,LOUTSPK
	ADHK	0
	
	;OUTK	0,ANAPWR	;all power on
;---
	RET
;----------------------------------------------------------------
;DAA_TWAY_RECORD:
DAA_TWAY_REC:
	LACL	0X5E08
	CALL	SET_CODECPATH	
	
        LIPK    6
	;OUTK    (1<<2),SWITCH

	OUTL	(0X7<<4),AGC
	;OUTK	0,ANAPWR	;all power on
        RET

;-------------------------------------------------------------------------------
;	Function : DAA_OFF
;	
;	Change analog switches for LOCAL/LINE off
;-------------------------------------------------------------------------------
DAA_OFF:
	LACL	0X5E10
	CALL	SET_CODECPATH	

	;LIPK	6
	;OUTL	0XFFFF,ANAPWR	;all power off
	;OUTK	0,SWITCH	;all switch open

        RET
;-------------------------------------------------------------------------------
;	Function : HOOK_ON
;	
;	hand on the telephone
;-------------------------------------------------------------------------------
HOOK_ON:
	LIPK	8

	IN	SYSTMP0,GPBD
	LAC	SYSTMP0
	ORL	(1<<7)
	SAH	SYSTMP0
	OUT	SYSTMP0,GPBD
	ADHK	0

	LAC	EVENT
	ORL	(1<<15)
	SAH	EVENT
	
	RET
;-------------------------------------------------------------------------------
;	Function : HOOK_OFF
;	
;	hand off the telephone
;-------------------------------------------------------------------------------
HOOK_OFF:		;Reset GPBD.7&EVENT.10
	LIPK	8

	IN	SYSTMP0,GPBD
	LAC	SYSTMP0
	ANDL	~(1<<7)
	SAH	SYSTMP0
	OUT	SYSTMP0,GPBD
	ADHK	0
	
	LAC	EVENT
	ANDL	~(1<<15)
	SAH	EVENT
	
	RET
;------------------------------------------------------------------------------
;	Function : BLED_ON
;	
;	Used only in main
;-------------------------------------------------------------------------------
BLED_ON:
	LIPK	8

	IN	SYSTMP0,GPBD
	LAC	SYSTMP0
	ORL	(1<<3)
	SAH	SYSTMP0
	OUT	SYSTMP0,GPBD
	ADHK	0		;back LED on----GPBD(bit3)
	
	RET
;-------------------------------------------------------------------------------
;	Function : BLED_OFF
;	
;	Used only in main
;-------------------------------------------------------------------------------
BLED_OFF:
	LIPK	8

	IN	SYSTMP0,GPBD
	LAC	SYSTMP0
	ANDL	~(1<<3)
	SAH	SYSTMP0
	OUT	SYSTMP0,GPBD
	ADHK	0		;back LED on----GPBD(bit3)
	
	RET
;----------------------------------------------------------------------------
;	Function : LED2_HIGH
;	input : no
;	output: no
;----------------------------------------------------------------------------
LED2_HIGH:
	LIPK	8

	IN	INT_TTMP1,GPBD
	LAC	INT_TTMP1
	ORK	(1<<5)
	SAH	INT_TTMP1
	OUT	INT_TTMP1,GPBD
	ADHK	0
	RET
;----------------------------------------------------------------------------
;	Function : LED2_LOW
;	input : no
;	output: no
;----------------------------------------------------------------------------
LED2_LOW:
	LIPK	8

	IN	INT_TTMP1,GPBD
	LAC	INT_TTMP1
	ANDL	~(1<<5)
	SAH	INT_TTMP1
	OUT	INT_TTMP1,GPBD
	ADHK	0
	
	RET

;----------------------------------------------------------------------------
;	Function : LED2_FLASH
;	input : no
;	output: no
;----------------------------------------------------------------------------
LED2_FLASH:
	LIPK	8

	IN	INT_TTMP1,GPBD
	LAC	INT_TTMP1
	XORK	(1<<5)
	SAH	INT_TTMP1
	OUT	INT_TTMP1,GPBD
	ADHK	0
	
	RET

;----------------------------------------------------------------------------
;	Function : LED1_HIGH
;	input : no
;	output: no
;----------------------------------------------------------------------------
LED1_HIGH:
	LIPK	8

	IN	INT_TTMP1,GPBD
	LAC	INT_TTMP1
	ORL	(1<<6)
	SAH	INT_TTMP1
	OUT	INT_TTMP1,GPBD
	ADHK	0
	
	RET
;----------------------------------------------------------------------------
;	Function : LED1_LOW
;	input : no
;	output: no
;----------------------------------------------------------------------------
LED1_LOW:
	LIPK	8

	IN	INT_TTMP1,GPBD
	LAC	INT_TTMP1
	ANDL	~(1<<6)
	SAH	INT_TTMP1
	OUT	INT_TTMP1,GPBD
	ADHK	0
	
	RET
;----------------------------------------------------------------------------
;	Function : LED1_FLASH
;	input : no
;	output: no
;----------------------------------------------------------------------------
LED1_FLASH:
	LIPK	8

	IN	INT_TTMP1,GPBD
	LAC	INT_TTMP1
	XORK	1<<6
	SAH	INT_TTMP1
	OUT	INT_TTMP1,GPBD
	ADHK	0
	
	RET
;----------------------------------------------------------------------------
;	Function : SET_LED2FG
;	
;----------------------------------------------------------------------------
SET_LED2FG:
	;SRAM	EVENT,14
	
	LAC	EVENT
	ORL	1<<14
	SAH	EVENT
	RET
;----------------------------------------------------------------------------
;	Function : CLR_LED2FG
;	
;----------------------------------------------------------------------------
CLR_LED2FG:
	;CRAM	EVENT,14
	
	LAC	EVENT
	ANDL	~(1<<14)
	SAH	EVENT
	
	RET


;----------------------------------------------------------------------------
;	Function : SET_LED1FG
;	
;----------------------------------------------------------------------------
SET_LED1FG:
	;SRAM	EVENT,13
	
	LAC	EVENT
	ORL	1<<13
	SAH	EVENT
	
	RET
;----------------------------------------------------------------------------
;	Function : CLR_LED1FG
;	
;----------------------------------------------------------------------------
CLR_LED1FG:
	;CRAM	EVENT,13
	
	LAC	EVENT
	ANDL	~(1<<13)
	SAH	EVENT
	
	RET
;----------------------------------------------------------------------------
;	Function : SET_TIMER
;	SET/CLEAR  TIMER/COUNTER
;----------------------------------------------------------------------------
SET_TIMER:
	SAH	TMR
	SAH	TMR_BAK
	RET
CLR_TIMER:
	LACK	0X00
	SAH	TMR
	SAH	TMR_BAK
	RET
;----------------------------------------------------------------------------
;       Function : GET_INITLANGUAGE
;
;	input  : no
;	output : no
;
;----------------------------------------------------------------------------
GET_INITLANGUAGE:
.if	0
	LAC	VOI_ATT
	ORL	1<<12
	SAH	VOI_ATT		;language = German
.endif
	RET
;-------------------------------------------------------------------------------
TEST_VOP:		;for Test
.if	1	;???????????????????????????????
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	
	LACL    CBEEP_COMMAND	;// beep start
	CALL    DAM_BIOSFUNC
	LACL	0X2000
	CALL    DAM_BIOSFUNC
	LACK	0
	CALL    DAM_BIOSFUNC
TEST_VOP_1:	
	BS	B1,TEST_VOP_1
.endif
;-------------------------------------------------------------------------------
VOL_TAB:			;1..8
	;0	1	2	3	4	5	6	7	8
;.DATA	0X00	0X05	0X0A	0X0F	0X13	0X17	0X1B	0X1D	0X1F
.DATA	0X00	0X03	0X06	0X0A	0X0D	0X10	0X13	0X17	0X1B

;//----------------------------------------------------------------------

;-----------------------------------------------------------------------
.INCLUDE main.asm
.INCLUDE ring_det.asm
.INCLUDE key_det.asm
.INCLUDE Iic.asm
.INCLUDE l_init.asm
.INCLUDE syspro.asm
.INCLUDE syswatch.asm
.INCLUDE gui.asm
.INCLUDE f_local.asm
.INCLUDE drive.asm
.INCLUDE tel_wr.asm
.INCLUDE l_voice.asm

.END
