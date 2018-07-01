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
;GPA.0	- 	NC		(INPUT)
;GPA.1	- 	~SPK_ON		(OUTPUT)
;GPA.2	- 	MUTE_RING	(OUTPUT)
;GPA.3	- 	OFF_HOOK	(OUTPUT)
;GPA.4	- 	BOOST		(OUTPUT)
;GPA.5	- 	MUTE_RING ???	(OUTPUT)
;GPA.6	- 	MUTE_HS		(OUTPUT)
;GPA.7	- 	NC		(INPUT)
;GPA.8	- 	MSGLED		(OUTPUT)
;GPA.9	- 	HFLED		(OUTPUT)
;GPA.10	- 	J2		(INPUT)
;GPA.11	- 	J1		(INPUT)
;GPA.12	- 	NC		(INPUT)
;GPA.13	- 	NC		(INPUT)
;GPA.14	- 	NC		(INPUT)
;GPA.15	- 	DATA ???	(INPUT)

;-----
;GPB.0		- CPC_DET	(INPUT)
;GPB.1		- LINE_REV	(INPUT)
;GPB.2		- RING_DET	(INPUT)
;GPB.3		- Blight	(OUTPUT)
;GPB.4		- HW-ALC	(OUTPUT)
;GPB.5		- NC		(INPUT)
;GPB.6		- NC		(INPUT)
;GPB.7		- NC		(INPUT)
;GPB.8		- J3		(INPUT)

;GPB.9		- IIC Request	(OUTPUT)
;GPB(10,11)	- IIC commulication
;GPB.12		- /MUTE
;Register indirect Addressing save only in interrupt==>AR1
;TMR2;用于key detect
;TMR3;用于ring detect
;PRO_VAR = 
;
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
;		bit8=	1/0---OGM2/OGM1 playing/recording
;		bit9=	
;		bit10=
;		bit11=	1/0---MUTE port(GPBD,12) status
;		------
;		bit12=	0/1---no/new messages(current mailbox current message type)---(VPMSG_CHK)
;
;		bit13=	0,not memory full---(VPMSG_CHK)
;			1,memory full
;		bit14=	0,no message---(current mailbox current message type)
;			1,have message
;		bit15=
;动态事件	------------------------
;EVENT :	bit0=
;		bit1=	1/0------CS-MS-DS/not
;		bit2=	1/0------mute/not
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

;		bit13=	1/0------request update vol(write into flash)
;		bit14=	1/0------MSGLED ctrl
;		bit15=	1/0------TestMode
;
;VOI_ATT:	bit(15..12) = RING_CNT
;		bit11 = CallScreening
;		bit10 = CompressRate
;		bit(9,8) = language 
;		bit(7..4) = SPK_Gain
;		bit(3..0) = SPK_VOL
;-------------------------------------------------------------------------------
.NOLIST
.INCLUDE	include/REG_D22.inc
.INCLUDE	include/MD22U.inc
.INCLUDE	include/CONST.inc
.INCLUDE	include/MACRO.inc
;-------------------------------------------------------------------------------
.GLOBAL	SYS_MSG_ANS
.GLOBAL	SYS_MSG_RMT
;---------------------------------------

.GLOBAL	BEEP
.GLOBAL	BEEP_RAW
.GLOBAL	BBEEP

.GLOBAL	CLR_FUNC
.GLOBAL	CLR_MSG
.GLOBAL	CLR_TIMER

.GLOBAL	DAA_OFF
.GLOBAL	DAA_SPK
.GLOBAL	DAM_BIOSFUNC
.GLOBAL	DAM_STOP
.GLOBAL	DELAY

.GLOBAL	GC_CHK
.GLOBAL	GET_LANGUAGE
.GLOBAL	GET_MSG

.GLOBAL	INIT_DAM_FUNC
.GLOBAL	INT_STOR_MSG

.GLOBAL	LINE_START
.GLOBAL	LOCAL_PRO
.GLOBAL	MEMFUL_CHK
.GLOBAL	PUSH_FUNC

.GLOBAL	REC_START
.GLOBAL	REQ_START

.GLOBAL	RESET_WDT

.GLOBAL	SILENCE40MS_VP
.GLOBAL	SET_DECLTEL
.GLOBAL	SET_SPKVOL
.GLOBAL	SET_TIMER
.GLOBAL	STOR_MSG
.GLOBAL	STOR_VP

.GLOBAL	TEL_GC_CHK

.GLOBAL	VOL_TAB
.GLOBAL	VPMSG_CHK
;-------------------------------------------------------------------------------
.LIST
;-------------------------------------------------------------------------------

DspTest		.EQU   	0	;0===>测试用
BeepTest	.EQU   	0	;0===>测试用
NoUse		.EQU   	0	;0===>测试用
;-------------------------------------------------------------------------------
.EXTERN	SetFlashStartAddress
.EXTERN	LoadHostCode
.EXTERN	GetOneConst	;(INPUT=ACCH(ProgramRamAddress),OUTPUT=ACCH(ReadData))
.EXTERN	GetMoreConst	;(INPUT=ACCH(ProgramRamStartingAddress)ACCL(ReadWordNumber)AR1(StoreDataRamAddress),OUTPUT=)
;-------------------------------------------------------------------------------
.EXTERN	INITDSP		;f_initdsp
.EXTERN	INITMCU		;f_initmcu
.EXTERN	ANS_STATE
.EXTERN	REMOTE_PRO
.EXTERN	LOCAL_PROREC
.EXTERN	LOCAL_PROPLY
.EXTERN	LOCAL_PROOGM
.EXTERN	LOCAL_PROPHO
.EXTERN	LOCAL_PROTXT
.EXTERN	RECEIVE_CID
.EXTERN	CidRawData
;---------
.EXTERN	UPDATE_FLASHDATA
.EXTERN	IDLE_COMMAND	;IDLE_COMMAND
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
;-------belows are for timer2 -------------------------------------------------
INT_T_TIMER2:
	LAC	TMR_TIMER
	BS	ACZ,INT_T_TIMER2_END
	LAC	TMR_TIMER
	SBHK	1
	SAH	TMR_TIMER
	BZ	ACZ,INT_T_TIMER2_END

	LAC	TMR_TIMER_BAK
	SAH	TMR_TIMER
	
	LACL	CMSG_2TMR
	CALL	INT_STOR_MSG
INT_T_TIMER2_END:
;-------belows are forbeep time,stor msg when TMR_BEEP=0--------------
INT_T_BEEP:
	LAC	TMR_BEEP
	BS	ACZ,INT_T_BEEP_END
	SBHK	1
	SAH	TMR_BEEP
	;BZ	ACZ,INT_T_BEEP_END
	;LACL	CSEG_END
	;CALL	INT_STOR_MSG
INT_T_BEEP_END:
;-------belows are for Delay----------------------------------------------------
INT_T_DELAY:
	LAC	TMR_DELAY
	BS	SGN,INT_T_DELAY_END
	SBHK	1
	SAH	TMR_DELAY
	;BZ	ACZ,INT_T_DELAY_END
INT_T_DELAY_END:
;-------belows are MSGLED/PHOLED on/off/flash-----------------------------------
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
;-------Power On check----------------------------------------------------------
.if	0
INT_PowerOn_chk:
	LIPK	8
	IN      INT_TTMP0,GPBD
	BIT	INT_TTMP0,CbPower
	BZ	TB,INT_PowerOn_chk
.endif
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;The pole com before CID
;POLE_TMR	bit12 - low to high
;		bit11..0 timer
;
;-------------------------------------------------------------------------------
.if	1
INT_T_POLE:
	LIPK	8
	IN      INT_TTMP0,GPBD
	BIT	INT_TTMP0,1
	BS	TB,INT_T_POLE_H
INT_T_POLE_L:
	LACK	0
	SAH	POLE_TMR
	BS	B1,INT_T_POLE_END
INT_T_POLE_H:
	BIT	POLE_TMR,12
	BS	TB,INT_T_POLE_TMRH	;H => H
;L => H
	LACL	(1<<12)+30
	SAH	POLE_TMR
	BS	B1,INT_T_POLE_END
INT_T_POLE_TMRH:
	
	LAC	POLE_TMR
	SBHK	1
	SAH	POLE_TMR
	ANDL	0X03F
	BZ	ACZ,INT_T_POLE_END
	
	;LACL	CRDY_CID		;!!!!!!!!
	;CALL	INT_STOR_MSG
INT_T_POLE_END:
.endif
;-------check ring count--------------------------------------------------------
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
	SAH	INT_TTMP1
	SBHK	1
	BS	ACZ,INT_T_ExeRnt_TollSave

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
	;BS	B1,INT_T_ExeRnt_end
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
.if	1
INT_REQUEST_DET:

	CALL	SENDBUF_CHK
	ADHK	0
	BZ	ACZ,INT_REQUEST_DET_END	;有数据,请求发送
	
	BIT	SER_FG,CbBUSY
	BS	TB,INT_REQUEST_DET_END	;IIC Busy(Some data waiting been get)

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
	CALL	DAM_BIOSFUNC	;save the number of NEW messages
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

        CALL	MEMFUL_CHK
        BS	ACZ,VPMSG_CHK3_2
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
;-------------------------------------------------------------------------------
VPMSG_CHK_RET:
;-------------------------------------------------------------------------------
        POP     CONF
        RET

;-------------------------------------------------------------------------------
;	MEMFUL_CHK
;	memory full check
;	input : no
;	output: ACCH = 0/1-no/full
;-------------------------------------------------------------------------------
MEMFUL_CHK:
	LACL    0X3003		;check if memory is full ?(OGM use it)
	CALL	DAM_BIOSFUNC
       	SBHK	3
	BZ      SGN,MEMFUL_CHK_END
	
	LACK	1
	
	RET
MEMFUL_CHK_END:
	LACK	0
	
       	RET
;-------------------------------------------------------------------------------
DAA_OFF:			;(all open except SW2)
	CALL	SPK_H
	LIPK	6
	OUTL	(CAD0_GAIN<<4),AGC
	OUTK	1<<2,SWITCH	;AUX -> AD0
	
	RET
;-------------------------------------------------------------------------------
DAA_SPK:	;(SW7) ==> (DAC->SPK)
	LIPK    6
        OUTL    (1<<7),SWITCH

        CALL	SPK_L
SET_SPKVOL:
	LAC	VOI_ATT		;
	ANDK	0X07
	ADHL	VOL_TAB
	CALL	GetOneConst
	ORL	(CLINE_DRV<<5)	;Lout gain
	SAH	SYSTMP0
	
	LIPK    6
	OUT	SYSTMP0,LOUTSPK
	ADHK	0
;---
	RET
;-------------------------------------------------------------------------------
VOL_TAB:
	;0	1	2	3	4	5	6	7
;.DATA	0X01	0X05	0X0A	0X0F	0X13	0X17	0X1B	0X1F
.DATA	0X01	0X05	0X0A	0X0E	0X12	0X14	0X16	0X18
;.DATA	0X01	0X02	0X04	0X05	0X06	0X07	0X08	0X09
;.DATA	0X01	0X02	0X04	0X06	0X08	0X0A	0X0C	0X0E
;Note: We use bit(4..0) for SPVOL
;-------------------------------------------------------------------------------

.INCLUDE	l_ring/ring_det.asm
.INCLUDE	l_port/l_spkctl.asm
.INCLUDE	l_Iic/l_iic.asm
.INCLUDE	l_respond/l_cid.asm

.INCLUDE	main.asm
.INCLUDE	kernel.asm
.INCLUDE	syspro.asm
.INCLUDE	local.asm
.INCLUDE	drive.asm

;---------------------------------------------
.END

