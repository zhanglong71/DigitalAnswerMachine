;*******************************************************************************
;
;	MXIC MX93U20 CODE
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
;GPA(0..7)	- 7SegLED	(OUTPUT)
;GPA(8..11)	- 7SegLED&&KEY	(OUTPUT)
;GPA15		- for Iic ~INT
;GPA(12..14)	- KEY		(INPUT)
;-----
;GPB.0		- reserved
;GPB.1		- reserved
;GPB.2		- RING_DET
;GPB.3		- CPC_DET
;GPB.4		- TWHOOK
;GPB.5		- reserved
;GPB.6		- LED1
;GPB.7		- HOOK
;GPB.8		-
;GPB.9		- A2/Ans(Answer Only/Record)
;GPB(10,11)	- 2/6/TS(铃声次数)
;GPB.12		- Language Select
;Register indirect Addressing save only in interrupt==>AR1
;TMR1;用于时间更新DateTime(0--1000)
;TMR2;用于key detect
;TMR3;用于ring detect
;PRO_VAR = 
;ANN_FG :	bit0=
;		bit1=
;		bit2=
;		bit3=
;		bit4=
;		bit5=
;               -------------------------
;		bit6=
;
;		bit7=	
;		bit8=

;		bit9=
;		bit10=
;		bit11=
;
;		bit12=	0/1---no/new messages(current mailbox current message type)---(MSG_CHK)
;
;		bit13=	0,not memory full---(MSG_CHK)
;			1,memory full
;		bit14=	0,no message---(current mailbox current message type)
;			1,have message
;		bit15=	1/0 --- 9.6/4.8kbps
;		--------------------------
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
;		bit10=	1/0------hook on/off(可等同于是/否接通线路)

;		bit11=	1/0------DTMF happened/end
;		bit12=	1/0------Cas-Tone happened/end

;		bit13=
;		bit14=
;		bit15=
;VOI_ATT:	bit(15..12) = RING_CNT
;		bit(11.8) = language 
;		bit(7..4) = reserved
;		bit(3..0) = SPK_VOL
;-------------------------------------------------------------------------------
.NOLIST
.INCLUDE	REG_D20.inc
.INCLUDE	MX93D20.inc
.INCLUDE	MACRO.inc
.INCLUDE	CONST.inc
;-------------------------------------------------------------------------------
.GLOBAL	ANNOUNCE_NUM
.GLOBAL	CMIN_GET
.GLOBAL	CHOUR_GET
.GLOBAL	CWEEK_GET
.GLOBAL	CURR_WEEK
.GLOBAL	CURR_HOUR
.GLOBAL	CURR_MIN

.GLOBAL	INIT_DAM_FUNC
.GLOBAL	DAA_LIN_SPK
.GLOBAL	DAA_LIN_REC
.GLOBAL	DAA_ROM_MOR
.GLOBAL	DAA_SPK
.GLOBAL	DAA_REC
.GLOBAL	DAA_OFF
.GLOBAL	DAT_WRITE_STOP
.GLOBAL	DEL_ONETEL

.GLOBAL	SEC_SET
.GLOBAL	MIN_SET
.GLOBAL	HOUR_SET
.GLOBAL	WEEK_SET

.GLOBAL	LBEEP
.GLOBAL	LLBEEP
.GLOBAL	BBBEEP
.GLOBAL	BBEEP
.GLOBAL	BEEP

.GLOBAL	HOOK_ON
.GLOBAL	HOOK_OFF

.GLOBAL	PUSH_FUNC
.GLOBAL	CLR_FUNC

.GLOBAL	STOR_MSG
.GLOBAL	STORBYTE_DAT
.GLOBAL	OGM_SELECT
.GLOBAL	OGM_STATUS
.GLOBAL	DGT_TAB
;.GLOBAL	SET_LED1
;.GLOBAL	SET_LED2
.GLOBAL	SET_LED3
.GLOBAL	SET_LED4
.GLOBAL	GET_SEGCODE
.GLOBAL	LED_HLDISP
.GLOBAL	STOR_VP
.GLOBAL	LOCAL_PRO
.GLOBAL	SET_TIMER
.GLOBAL	CLR_TIMER
.GLOBAL	REC_START
.GLOBAL	LINE_START
.GLOBAL	BCVOX_INIT
.GLOBAL	FFW_MANAGE
.GLOBAL	PAUBEEP
.GLOBAL	REW_MANAGE
.GLOBAL	VPMSG_CHK
.GLOBAL	CLR_FLAG
.GLOBAL	SET_DELMARK
.GLOBAL	DAM_BIOSFUNC
.GLOBAL	VPMSG_DEL
.GLOBAL	GC_CHK
.GLOBAL	TEL_GC_CHK
.GLOBAL	TELNUM_WRITE
.GLOBAL	REAL_DEL
.GLOBAL	VALUE_ADD
.GLOBAL	VALUE_SUB
.GLOBAL	VOL_TAB
;-------------------------------------------------------------------------------
.LIST
;-------------------------------------------------------------------------------
CMODE9		.EQU		0X9240	;===>测试用
CID_PAGE	.equ		1	;for CID and Display
CPC_TLEN	.EQU		80	;for CPC
LED1_60		.EQU		60	;for LED1 on
CPC_DELAY	.EQU   		1000	;HOOK_ON之后与开始CPC检测时间间隔

DspTest		.EQU   	0	;0===>测试用
BeepTest	.EQU   	0	;0===>测试用
;-------------------------------------------------------------------------------
.EXTERN	SetFlashStartAddress
.EXTERN	LoadHostCode
.EXTERN	GetOneConst	;(INPUT=ACCH(ProgramRamAddress),OUTPUT=ACCH(ReadData))
.EXTERN	GetMoreConst	;(INPUT=ACCH(ProgramRamStartingAddress)ACCL(ReadWordNumber)AR1(StoreDataRamAddress),OUTPUT=)
.EXTERN	ANS_STATE
.EXTERN	LOCAL_PROREC
.EXTERN	LOCAL_PROPLY
.EXTERN	LOCAL_PROOGM
.EXTERN	LOCAL_PROTWR
.EXTERN	LOCAL_PROMNU

.ORG	0x4400
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
	LAC	TMR2
	ADHK	0X01
	ANDK	0X07
	SAH	TMR2	;+1/1ms
	
	LAC     TMR2
        ANDK	0X03
        BZ	ACZ,IntTimer1_1
        
        LAC     TMR_BTONE	;for BUSY TONE(+1/4ms)
        ADHK    0X01
        SAH     TMR_BTONE
IntTimer1_1:
	LAC	TMR_VOX		;for VOX detection(-1/ms)
	SBHK	0X01
	SAH	TMR_VOX

	LAC	TMR_CTONE	;for CONT TONE(-1/ms)
	SBHK	0X01
	SAH	TMR_CTONE
		
	LAC	TMR3		;for ring detection(-1/ms)
	SBHK	0X01
	SAH	TMR3
;------ BELOWS ARE FOR LED DISPLAY ---------------------------------------------
IntTimer1_7SEGLED:
	CALL	INT_LEDDISP
IntTimer1_7SEGLED_END:	
;------ BELOWS ARE FOR RING CHECKING (FREQUENCY RANGE : 15 - 95 Hz) ------------
IntTimer1_RingChk:
	CALL	RING_CHK
IntTimer1_RingChk_END:
;-------belows are for key_scan-------------------------------------------------
	CALL	KEYSCAN_CHK
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
;-------belows are led1 on/off/flash--------------------------------------------
;	DAM status : 	OFF - LED1_L
;			ON  - 	ANN_FG.12(new message) =1 - LED1_FLASH
;							0 - LED1_H
;-------------------------------------------------------------------------------
IntTimer1_LED1:
	;BIT	EVENT,9
	;BS	TB,IntTimer1_LED1_OFF
	BIT	ANN_FG,12
	BZ	TB,IntTimer1_LED1_OFF
;---LED1-flash
	LAC	TMR_LED1
	BS	SGN,IntTimer1_LED1_Flash
	SBHK	1
	SAH	TMR_LED1
	BS	B1,IntTimer1_LED1_end
IntTimer1_LED1_Flash:
	LACL	(2000-LED1_60)
	SAH	TMR_LED1
	
	IN      INT_TTMP1,GPBD
        BIT	INT_TTMP1,6
        BZ	TB,IntTimer1_LED1_FlashExe
        
	LACK	LED1_60
	SAH	TMR_LED1
	;BS	B1,IntTimer1_LED1_FlashExe
IntTimer1_LED1_FlashExe:
	CALL	LED1_FLASH
	BS	B1,IntTimer1_LED1_end	
IntTimer1_LED1_ON:
	CALL	LED1_L
	BS	B1,IntTimer1_LED1_end
IntTimer1_LED1_OFF:
	LACK	0
	SAH	TMR_LED1
	CALL	LED1_H
IntTimer1_LED1_end:
;-------belows are for Ring time------------------------------------------------
INT_T_Rnt:
	LIPK	8
	IN	INT_TTMP1,GPBD
	BIT	INT_TTMP1,10
	BZ	TB,INT_T_Rnt_2
	BIT	INT_TTMP1,11
	BZ	TB,INT_T_Rnt_6
;INT_T_Rnt_TS:	
	BIT	ANN_FG,12	;NEW Messages exist?
	BZ	TB,INT_T_Rnt_6

INT_T_Rnt_2:
	LAC	VOI_ATT
	ANDL	0X0FFF
	ORL	0X2000
	SAH	VOI_ATT
	
	BS	B1,INT_T_Rnt_end
INT_T_Rnt_6:
	LAC	VOI_ATT
	ANDL	0X0FFF
	ORL	0X6000
	SAH	VOI_ATT
	
	;BS	B1,INT_T_Rnt_end
INT_T_Rnt_end:
;-------check ring count
INT_T_ExeRnt:
	BIT	EVENT,10
	BS	TB,INT_T_ExeRnt_0	;HOOK_ON
	BIT	EVENT,9
	BS	TB,INT_T_ExeRnt_10	;OFF
	BIT	ANN_FG,13
	BS	TB,INT_T_ExeRnt_10	;FULL
;---	
	LAC	VOI_ATT
	SFR	12
	ANDK	0X0F
	SAH	INT_TTMP1
	
	LAC	RING_ID
	ANDL	0XFFF0
	OR	INT_TTMP1
	SAH	RING_ID
	
	BS	B1,INT_T_ExeRnt_end
INT_T_ExeRnt_0:				;已在接线状态
	LACK	0
	SAH	RING_ID
	BS	B1,INT_T_ExeRnt_end
INT_T_ExeRnt_10:			;在Answer off状态
	LAC	RING_ID
	ANDL	0XFFF0
	ORK	10
	SAH	RING_ID
	BS	B1,INT_T_ExeRnt_end
	
INT_T_ExeRnt_end:
;-------belows are for ANS-record/ANS-only -------------------------------------
INT_T_ANS:
	IN	INT_TTMP1,GPBD
	BIT	INT_TTMP1,9
	BZ	TB,INT_T_ANS_ONLY
;INT_T_ANS_RECO:
	LAC	EVENT
	ANDL	~(1<<8)
	SAH	EVENT
	BS	B1,INT_T_ANS_END
INT_T_ANS_ONLY:
	LAC	EVENT
	ORL	(1<<8)
	SAH	EVENT
	BS	B1,INT_T_ANS_END
INT_T_ANS_END:	
;-------belows are for language select -----------------------------------------
INT_T_LANGUAGE:
	IN	INT_TTMP1,GPBD
	BIT	INT_TTMP1,12
	BS	TB,INT_T_LANGUAGE_FRENCH
;INT_T_LANGUAGE_GERMAN:
	LAC	VOI_ATT
	ANDL	0XF0FF
	SAH	VOI_ATT
	BS	B1,INT_T_LANGUAGE_END
INT_T_LANGUAGE_FRENCH:	
	LAC	VOI_ATT
	ANDL	0XF0FF
	ORL	0X0100
	SAH	VOI_ATT
	;BS	B1,INT_T_LANGUAGE_END
INT_T_LANGUAGE_END:
;-------belows are for cpc-det--------------------------------------------------
INT_CPC_DET:
	;LIPK	8
	IN	INT_TTMP1,GPBD
        BIT	INT_TTMP1,7		;摘机了(hook_on)吗?
	BZ	TB,INT_CPC_DET_OFFLINE
	
	LAC	TMR_CPC
	SBHL	CPC_TLEN
	BZ	SGN,INT_CPC_DET4

	IN	INT_TTMP1,GPBD
	BIT	INT_TTMP1,0
	BS	TB,INT_CPC_DET2
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
;-------belows are compression check--------------------------------------------
IntTimer1_CompChk:
	;LIPK    8
	IN	INT_TTMP1,GPBD
	BIT	INT_TTMP1,5
	BS	TB,IntTimer1_CompChk_On
	LAC	ANN_FG
	ANDL	~(1<<15)
	SAH	ANN_FG
	BS	B1,IntTimer1_CompChk_END
IntTimer1_CompChk_On:
	LAC	ANN_FG
	ORL	1<<15
	SAH	ANN_FG
IntTimer1_CompChk_END:
;-------------------------------------------------------------------------------	
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
;       Function : MSG_CHK
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
;	OGM_CHK
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
	BS	TB,OGM_STATUS0
	
	LACK	COGM1_ID
OGM_SELECT_1:
	SAH	MSG_N
	CALL	OGM_STATUS1
	
	RET
;-------------------------------------------------------------------------------
;	OGM_STATUS
;	check weather the current OGMx exist?
;	input : EVENT.8		= 0/1---answer ICM/answer only
;		EVENT.9		= 0/1---answer on/off
;		ANN_FG.13	= 0/1---not/memoful
;	output: ACCH = 1/0 --- the OGM exist/no OGM
;
;		MSG_ID		= index NO.in current MBOX in current MSG type(OGM)
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
	LACL	0XD001
	CALL	DAM_BIOSFUNC
	LACL	0XD202
	CALL	DAM_BIOSFUNC
	LACL	0X3000
	CALL	DAM_BIOSFUNC
	SAH	MSG_ID
OGM_STATUS2:	
	LAC	MSG_ID
	BS	ACZ,OGM_STATUS_END	;没找到
	ORL	0XA900            	;check if OGMx exists(GET USER INDEX DATA0)?
        CALL	DAM_BIOSFUNC		;LOAD USER ID(MSG_N)
        SBH	MSG_N
        BS      ACZ,OGM_STATUS_END	;找到了
        
	LAC	MSG_ID
	SBHK	1
	SAH	MSG_ID
	BS	B1,OGM_STATUS2		;继续找
OGM_STATUS_END:
	
        LAC	MSG_ID			;OGMx exist/not
        RET

;----------------------------------------------------------------------------
;       Function : GC_CHK
;
;       Check garbage collection
;----------------------------------------------------------------------------
GC_CHK:
	LACL    0X3007   		; do garbage collection
        CALL    DAM_BIOSFUNC

	LACL    0X3005           	; check if garbage collection is required ?
        CALL    DAM_BIOSFUNC
        BZ      ACZ,GC_CHK

	RET
	
;----------------------------------------------------------------------------
;       Function : TEL_GC_CHK
;
;       Check garbage collection
;----------------------------------------------------------------------------
TEL_GC_CHK:
        LACL    0XE405		;check if garbage collection is required ?
        CALL    DAM_BIOSFUNC
        BS      ACZ,TEL_GC_CHK_RTN

        LACL    0XE407		;do garbage collection
        CALL    DAM_BIOSFUNC
        BS      ACZ,TEL_GC_CHK	;full?(for D20)
TEL_GC_CHK_RTN:
        RET
;-------------------------------------------------------------------------------
;	Function : LED1_H/LED1_L/LED1_FLASH - (only - interrupt)
;-------------------------------------------------------------------------------
LED1_H:
	LIPK	8

	IN	INT_TTMP1,GPBD	;GPBD.6 = 1
	LAC	INT_TTMP1
	ORK	1<<6
	SAH	INT_TTMP1
	OUT	INT_TTMP1,GPBD
	ADHK	0
	
	RET
;---------------
LED1_L:
	LIPK	8

	IN	INT_TTMP1,GPBD	;GPBD.6 = 0
	LAC	INT_TTMP1
	ANDL	~(1<<6)
	SAH	INT_TTMP1
	OUT	INT_TTMP1,GPBD
	ADHK	0
	
	RET
;---------------
LED1_FLASH:
	LIPK	8

	IN	INT_TTMP1,GPBD	;GPBD.6 = 0
	LAC	INT_TTMP1
	XORK	1<<6
	SAH	INT_TTMP1
	OUT	INT_TTMP1,GPBD
	ADHK	0
	
	RET
;-------------------------------------------------------------------------------
DAA_SPK:	;(SW2)&(SW3) ==>(AUX->ADC) (ADC->SPK)
	LIPK    6
	OUTL	((1<<2)+(1<<7)),SWITCH

	NOP
	LAC	VOI_ATT
	ANDK	0X07
	ADHL	VOL_TAB
	CALL	GetOneConst
	SAH	CODECREG2
	SFL	5
	OR	CODECREG2
	SAH	CODECREG2
	
	OUT	CODECREG2,LOUTSPK
	ADHK	0
	
	RET
;---
DAA_REC:	;(SW0)(SW2) ==> (AUX->ADC)&(MIC->ADC)
	LIPK    6
	OUTK    (1|(1<<2)),SWITCH

	NOP
	IN	SYSTMP0,AGC
	LAC	SYSTMP0
	ANDL	0xF00F
	ORL	0X0999
	SAH	SYSTMP0
	OUT     SYSTMP0,AGC	; Lin-pga=c ; AD-PGA=c(0dB) ; MIC-pre-pga=c (+21dB)
	ADHK	0
;---
	RET

DAA_LIN_SPK:	;(SW1)&(SW3) ==> (LIN->ADC)&(DAC->SPK)&(DAC->LOUT)
	LIPK    6
        OUTL    ((1<<1)|(1<<3)),SWITCH
        NOP
	;OUTL	0x7CCC,LOUTSPK
	OUTL	((0x17<<5)|(0x17<<10)),LOUTSPK
	NOP
	RET
DAA_LIN_REC:	;(SW1) ==> (LIN->ADC)&(DAC->SPK)
	LIPK    6
        ;OUTL    0x0082,SWITCH
        OUTL    (1<<1),SWITCH
	NOP
	OUTL	((0x17<<5)|(0x17<<10)),LOUTSPK
	NOP
	IN	SYSTMP0,AGC
	LAC	SYSTMP0
	ANDL	0xF00F
	ORL	0X0999
	SAH	SYSTMP0
	OUT     SYSTMP0,AGC
	ADHK	0
	
	RET
DAA_ROM_MOR:	;(SW0)&(SW4)			
				; MIC ->pre-pga -> ad1-pga -> SW4 -> LOUT
				; LIN -> ad2-pga -> ADC2
	LIPK    6
	OUTK	0x0013,SWITCH
        NOP
	OUTL	0x7fEC,LOUTSPK
	NOP
	OUTL	0X0BCC,AGC
	NOP
	
	RET
;---
DAA_OFF:		;(SW2 - AUX)
.if	1
	LIPK	6
        OUTK	(1<<2),SWITCH	;all switch open
.else
	;PSH	CONF
	LACL	0x5E08		;AUX -> AD0
	CALL	DAM_BIOSFUNC
	;POP	CONF
.endif
	RET

;--
SetCodecReg:
        LIPK    6
        
	;OUT	CODECREG0,SWITCH
        ;ADHK	0
	;OUT	CODECREG1,AGC
	;ADHK	0
	OUT	CODECREG2,LOUTSPK
	ADHK	0

        RET
;----------------------------------------------------------------------------
;       Function : SET_COMPS
;
;       Set the speech compression algorithm
;----------------------------------------------------------------------------
SET_COMPS:
	;BIT	ANN_FG,15
	;BS	TB,SET_COMPS_96
;SET_COMPS_48:	
	;LACL	0XD10F		;4.8kbps
	LACL	0XD117		;6.0kbps
	BS	B1,SET_COMPS_END
SET_COMPS_96:
	LACL	0XD12F		;9.6kbps
SET_COMPS_END:	
	CALL	DAM_BIOSFUNC
	RET
;//----------------------------------------------------------------------------
;//       Function : WBEEP
;//
;//       Generate a warning beep
;//----------------------------------------------------------------------------
WBEEP:
;---1700 Hz (1700 X 8.19)
	CALL    BEEP_START

	LACL	0X3663
	CALL    DAM_BIOSFUNC
	LACK	0
	CALL    DAM_BIOSFUNC
	
	LACK	63
	CALL	DELAY
	CALL    BEEP_STOP	;// beep stop
;---1600 Hz (1600 X 8.19)	
	CALL    BEEP_START
	
	LACL	0X3330
	CALL    DAM_BIOSFUNC
	LACK	0
	CALL    DAM_BIOSFUNC
	
	LACK	63
	CALL	DELAY
	
	CALL    BEEP_STOP	;// beep stop
;---1900 Hz (1900 X 8.19)	
	CALL    BEEP_START
	
	LACL	0X3CC9
	CALL    DAM_BIOSFUNC
	LACK	0
	CALL    DAM_BIOSFUNC
	
	LACK	63
	CALL	DELAY

	CALL    BEEP_STOP	;// beep stop

        RET
;-------------------------------------------------------------------------------
;	Function : INITBEEP
;	
;	Generate a warning beep
;-------------------------------------------------------------------------------
INITBEEP:
	CALL    BEEP_START
        
	LACL	0X3063
	CALL    DAM_BIOSFUNC
	LACK	0
	CALL    DAM_BIOSFUNC
	
	LACL	2000
	CALL	DELAY

	CALL    BEEP_STOP	;// beep stop

        RET
;-------------------------------------------------------------------------------
;	Function : PAUBEEP
;
;	Generate a warning beep
;-------------------------------------------------------------------------------
PAUBEEP:
	PSH	CONF
	NOP
	CALL    BEEP_START
	LACL	0X2000		;Fre1
	CALL    DAM_BIOSFUNC
	LACK	0		;Fre2
	CALL    DAM_BIOSFUNC
	LACL	500
	CALL	DELAY
	CALL    BEEP_STOP	;// beep stop
	
	POP	CONF
	NOP
	RET
;-------------------------------------------------------------------------------
;	Function : BEEP_START
;	
;	The general function for beep generation
;	Input  : BUF1=the beep frequency
;-------------------------------------------------------------------------------
BEEP_START:
        LACL    0X48FB            	;// beep start
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
HOOK_ON:		;Set GPBD.7&EVENT.10
	LIPK	8

	IN	SYSTMP0,GPBD
	LAC	SYSTMP0
	ORL	1<<7
	SAH	SYSTMP0
	OUT	SYSTMP0,GPBD
	ADHK	0

	LAC	EVENT
	ORL	1<<10
	SAH	EVENT
	
	RET
	
;---
HOOK_OFF:		;Reset GPBD.7&EVENT.10
	LIPK	8

	IN	SYSTMP0,GPBD
	LAC	SYSTMP0
	ANDL	~(1<<7)
	SAH	SYSTMP0
	OUT	SYSTMP0,GPBD
	ADHK	0
	
	LAC	EVENT
	ANDL	~(1<<10)
	SAH	EVENT
	
	RET

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
DGT_TAB:
;	     A
;	     __
;	  F |G |B
;	    |__|
;	  E |  |C
;	    |__| .	;.GFEDCBA<===>OPTR(7..0)
;	     D
;	0	1	2	3	4	5	6	7
.DATA   0XC0	0XF9	0XA4	0XB0	0X99	0X92	0X82	0XF8
;	8	9	A	b	C	d	E	F
.DATA   0X80	0X90	0X88	0X83	0XC6	0XA1	0X86	0X8E
;	bL	rE	dE	--	PA	rA	Ln	FL
;	0X83C7	0XAF86	0XA186	0XBFBF	0X8C88	0XAF88	0XC7AB	0X8EC7
;	下线	中下线	上中下线Fu	PR	Er
;	0XF7	0XB7	0XB6	0X8EE3	0X8C88	0X86Af
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
PHOVOL_TAB:
	;0	1	2	3	4	5	6	7
.DATA	0X00	0X03	0X06	0X08	0X0A	0X0C	0X0E	0X0F
;-------------------------------------------------------------------------------
.INCLUDE	initial.asm
.INCLUDE	ring_det.asm
.INCLUDE	key_det.asm
;.INCLUDE	Iic.asm
.INCLUDE	main.asm

.INCLUDE	gui.asm
.INCLUDE	syspro.asm
.INCLUDE	local.asm
.INCLUDE	drive.asm
.INCLUDE	tel_wr.asm

;.INCLUDE	f_answer.asm
;.INCLUDE	f_remote.asm
		
;.INCLUDE	table.asm
;.INCLUDE	error.asm	;调试用

.END

