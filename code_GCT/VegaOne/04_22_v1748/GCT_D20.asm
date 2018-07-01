;*******************************************************************************
;
;	MXIC MX93U20 CODE
;
;*******************************************************************************
;telphone - mode working group 0 ==>(0XE600) �����������
;telphone - mode working group 1 ==>(0XE601) ����MAILBOX1��ICM��Ӧ�ĵ绰����
;telphone - mode working group 2 ==>(0XE604) �����绰���绰����
;telphone - mode working group 3 ==>(0XE605) ����DAM��ϢPSWORD---(byte0..2)
;							contrast---(byte3)
;							local code---(byte4..7)
;MAILBOX1 - 0XD001_0XD200(MEMO)
;MAILBOX1 - 0XD001_0XD202(OGM)
;-----------
;GPA(0..7)	- 7SegLED	(OUTPUT)
;GPA(8..11)	- 7SegLED&&KEY	(OUTPUT)
;GPA(12..15)	- KEY		(INPUT)
;-----
;GPB.0		- CPC_DET	(INPUT)
;GPB.1		-
;GPB.2		- RING_DET	(INPUT)
;GPB.3		- 
;GPB.4		- TWHOOK	(OUTPUT)
;GPB.5		-
;GPB.6		- LED1
;GPB.7		- HOOK
;GPB.8		-
;GPB.9		-
;GPB(10,11)	- IIC commulication
;GPB.12		- IIC Request	(OUTPUT)
;Register indirect Addressing save only in interrupt==>AR1
;TMR1;����ʱ�����DateTime(0--1000)
;TMR2;����key detect
;TMR3;����ring detect
;PRO_VAR = 
;ANN_FG :	bit0=
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
;		bit9=
;		bit10=
;		bit11=	
;		------
;		bit12=	0/1---no/new messages(current mailbox current message type)---(MSG_CHK)
;
;		bit13=	0,not memory full---(MSG_CHK)
;			1,memory full
;		bit14=	0,no message---(current mailbox current message type)
;			1,have message
;		bit15=
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
;		bit10=	1/0------hook on/off(�ɵ�ͬ����/���ͨ��·)

;		bit11=	1/0------DTMF happened/end
;		bit12=	1/0------Cas-Tone happened/end

;		bit13=
;		bit14=
;		bit15=
;
;VOI_ATT:	bit(15..12) = RING_CNT
;		bit(11.8) = language 
;		bit(7..4) = reserved
;		bit(3..0) = SPK_VOL
;TAD_ATT1:	
;		bit(15..10) = reserved
;		bit(9..5) = Line-out for remote/answer play
;		bit(4..0) = Line-out for local play
;-------------------------------------------------------------------------------
.NOLIST
.INCLUDE	REG_D20.inc
.INCLUDE	MD20U.inc
.INCLUDE	CONST.inc
;-------------------------------------------------------------------------------
.GLOBAL	ANNOUNCE_NUM

.GLOBAL	BBBEEP
.GLOBAL	BBEEP
.GLOBAL	BEEP
.GLOBAL	BCVOX_INIT

.GLOBAL	CMIN_GET
.GLOBAL	CHOUR_GET
.GLOBAL	CWEEK_GET
.GLOBAL	CURR_WEEK
.GLOBAL	CURR_HOUR
.GLOBAL	CURR_MIN
;.GLOBAL	CLR_FLAG
.GLOBAL	CLR_FUNC
.GLOBAL	CLR_TIMER
.GLOBAL CLR_TIMER2

.GLOBAL	DAA_SPK
.GLOBAL	DAA_REC
.GLOBAL	DAA_OFF
.GLOBAL	DAA_ANS_SPK
.GLOBAL	DAA_ANS_REC
.GLOBAL	DAA_LIN_SPK
.GLOBAL	DAA_LIN_REC
.GLOBAL	DAM_BIOSFUNC
.GLOBAL	DAT_WRITE_STOP
.GLOBAL	DEL_ONETEL
.GLOBAL	DGT_TAB

.GLOBAL	EXIT_TOIDLE

.GLOBAL	GC_CHK
.GLOBAL	GET_SEGCODE
.GLOBAL	GET_VPTLEN


.GLOBAL	HOOK_ON
.GLOBAL	HOOK_OFF
.GLOBAL	HOUR_SET

.GLOBAL	INIT_DAM_FUNC

.GLOBAL	LED_HLDISP
.GLOBAL	LINE_START
.GLOBAL	LBEEP
.GLOBAL	LLBEEP
.GLOBAL	LOCAL_PRO

.GLOBAL	MIN_SET
;.GLOBAL	MSG_WEEK
;.GLOBAL	MSG_HOUR
;.GLOBAL	MSG_MIN

.GLOBAL	OGM_SELECT
.GLOBAL	OGM_STATUS

.GLOBAL	PAUBEEP
.GLOBAL	PUSH_FUNC

.GLOBAL	REAL_DEL
.GLOBAL	REC_START


.GLOBAL	SEND_DAT
.GLOBAL	SEND_MSGNUM

;.GLOBAL	SET_DELMARK
.GLOBAL	SET_LED3
.GLOBAL	SET_LED4
.GLOBAL	SEC_SET
.GLOBAL	SET_TIMER
.GLOBAL	SET_COMPS
.GLOBAL SET_TIMER2

.GLOBAL	STOR_MSG
.GLOBAL	STORBYTE_DAT
.GLOBAL	STOR_VP

.GLOBAL	TEL_GC_CHK
.GLOBAL	TELNUM_WRITE

.GLOBAL	VALUE_ADD
.GLOBAL	VALUE_SUB
.GLOBAL	VOL_TAB
.GLOBAL	VPMSG_CHK
.GLOBAL	VPMSG_DEL

.GLOBAL	WEEK_SET
;---
.GLOBAL	VP_All
.GLOBAL	VP_Announcement
.GLOBAL	VP_AnswerOff
.GLOBAL	VP_AnswerOn
.GLOBAL	VP_DefOGM
.GLOBAL	VP_DefOGM1
.GLOBAL	VP_DefOGM2
.GLOBAL	VP_Erased
.GLOBAL	VP_EndOfMessages
.GLOBAL	VP_Message
.GLOBAL	VP_Messages
.GLOBAL	VP_MemoryFull
.GLOBAL	VP_CHKMemoryFull
.GLOBAL	VP_NEW
.GLOBAL	VP_No
.GLOBAL	VP_YouHave
.GLOBAL	VP_YouHaveNoMessages
;-------------------------------------------------------------------------------
.LIST
;-------------------------------------------------------------------------------
CID_PAGE	.equ		1	;for CID and Display
CPC_TLEN	.EQU		60	;for CPC
;PHONE_TLEN	.EQU		80	;
LED1_60		.EQU		60	;for LED1 on
CPC_DELAY	.EQU   		1000	;HOOK_Off֮���뿪ʼCPC���ʱ����

DspTest		.EQU   	0	;0===>������
BeepTest	.EQU   	0	;0===>������
NoUse		.EQU   	0	;0===>������
;-------------------------------------------------------------------------------
.EXTERN	SetFlashStartAddress
.EXTERN	LoadHostCode
.EXTERN	GetOneConst	;(INPUT=ACCH(ProgramRamAddress),OUTPUT=ACCH(ReadData))
.EXTERN	GetMoreConst	;(INPUT=ACCH(ProgramRamStartingAddress)ACCL(ReadWordNumber)AR1(StoreDataRamAddress),OUTPUT=)
.EXTERN	ANS_STATE
.EXTERN	REMOTE_PRO
.EXTERN	LOCAL_PROREC
;.EXTERN	LOCAL_PROPLY
.EXTERN	LOCAL_PROPNEW
.EXTERN	LOCAL_PROPALL
.EXTERN	LOCAL_PROOGM
.EXTERN	LOCAL_PROTWR
.EXTERN	LOCAL_PROMNU
.EXTERN	LOCAL_PROTXT

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
test1:	
	;BS	B1,test1
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
;-------belows are for VOX timer-----
	LAC	TMR_VOX		;for VOX detection(-1/ms when >0)
	BS	SGN,IntTimer1_2
	SBHK	0X01
	SAH	TMR_VOX
IntTimer1_2:
;-------belows are for CTONE timer-----
	LAC	TMR_CTONE	;for CONT TONE(-1/ms when >0)
	BS	SGN,IntTimer1_3
	SBHK	0X01
	SAH	TMR_CTONE
IntTimer1_3:
;-------belows are for TMR3-------------
	LAC	TMR3		;for ring detection(-1/ms)
	SBHK	0X01
	SAH	TMR3
;-------belows are for key_scan_out-------------------------------------------------
	;CALL	INT_KEYSCAN_OUT
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
	LAC	TMR0_BAK
	BS	ACZ,INT_T_TIMER2_END
	LAC	TMR0
	SBHK	1
	SAH	TMR0
	BZ	ACZ,INT_T_TIMER2_END

	LAC	TMR0_BAK
	SAH	TMR0
	LACL	CMSG_TMR2
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
;-------belows are led1 on/off/flash--------------------------------------------
;	DAM status : 	OFF - LED1_L
;			ON  - 	ANN_FG.12(new message) =1 - LED1_FLASH
;							0 - LED1_H
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
	SBHK	2
	BS	SGN,INT_T_ExeRnt_TS
		
	LAC	RING_ID
	ANDL	0XFFF0
	OR	INT_TTMP1
	SAH	RING_ID
	
	BS	B1,INT_T_ExeRnt_end
INT_T_ExeRnt_TS:
	BIT	ANN_FG,12
	BS	TB,INT_T_ExeRnt_TS2
;INT_T_ExeRnt_TS5:	
	LAC	RING_ID
	ANDL	0XFFF0
	ORK	5
	SAH	RING_ID
	BS	B1,INT_T_ExeRnt_end
INT_T_ExeRnt_TS2:
	LAC	RING_ID
	ANDL	0XFFF0
	ORK	2
	SAH	RING_ID
	BS	B1,INT_T_ExeRnt_end
INT_T_ExeRnt_0:				;���ڽ���״̬
	LACK	0
	SAH	RING_ID
	BS	B1,INT_T_ExeRnt_end
INT_T_ExeRnt_10:			;��Answer off״̬
	LAC	RING_ID
	ANDL	0XFFF0
	ORK	10
	SAH	RING_ID
	BS	B1,INT_T_ExeRnt_end
	
INT_T_ExeRnt_end:
;-------belows are for cpc-det--------------------------------------------------
INT_CPC_DET:
        BIT	EVENT,10		;ժ����(hook_off)��?
	BZ	TB,INT_CPC_DET_OFFLINE
	
	LAC	TMR_CPC
	SBHL	CPC_TLEN
	BZ	SGN,INT_CPC_DET4
	
	LIPK	8
	IN	INT_TTMP1,GPBD
	BIT	INT_TTMP1,0
	BZ	TB,INT_CPC_DET2		;Detect High pulse
	;BS	TB,INT_CPC_DET2		;Detect Low pulse
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
;-------belows are for Iic Req--------------------------------------------------
INT_REQUEST_DET:
	BIT	SER_FG,8
	BS	TB,INT_REQUEST_STOP	;������,��������
	
	CALL	SENDBUF_CHK
	ADHK	0
	BS	ACZ,INT_REQUEST_STOP	;������,��������
;---REQUEST START
	CALL	REQ_START
	BS	B1,INT_REQUEST_DET_END
INT_REQUEST_STOP:
	CALL	REQ_STOP
INT_REQUEST_DET_END:
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
        SBHK    55		;check if the total message number >= 55 ?
        BZ      SGN,VPMSG_CHK3_1

        LACL    0X3003		;check if memory is full ?
	CALL	DAM_BIOSFUNC
       	SBHK	CMEMFUL
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
;	input : ACCH = 	OGMx(COGM1_ID/COGM2_ID)
;	output: ACCH = 	MSG_ID(OGMx��Ӧ��ID��)
;			0/~0 ---�޶�ӦOGM/OGMx��Ӧ��ID��
;
;		MSG_ID		= index NO.in current MBOX in current MSG type(OGM)
;		MSG_N = 101/102	= the current OGM index(USR INDEX DATA0)
;-------------------------------------------------------------------------------
OGM_SELECT:			;����¼��/����ʱȷ��OGM_ID(�ǽ���ʱ��)
	SAH	MSG_N
	BS	B1,OGM_STATUS1
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
OGM_STATUS:			;����ʱ��
	LACK	COGM1_ID
	SAH	MSG_N

	BIT	EVENT,9		;answer off?
	BS	TB,OGM_STATUS0
	BIT	ANN_FG,13	;memoful?
	BS	TB,OGM_STATUS0
	BIT	EVENT,8		;answer only?
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
	BS	ACZ,OGM_STATUS_END		;û�ҵ�
	ORL	0XA900            	;check if OGMx exists(GET USER INDEX DATA0)?
        CALL	DAM_BIOSFUNC		;LOAD USER ID(MSG_N)
        SBH	MSG_N
        BS      ACZ,OGM_STATUS_END		;�ҵ���
        
	LAC	MSG_ID
	SBHK	1
	SAH	MSG_ID
	BS	B1,OGM_STATUS2		;������

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
DAA_SPK:	;(SW3) ==> (DAC->LOUT)
	LIPK    6
.if	DebugSpkOn
        OUTL    ((1<<3)|(1<<7)),SWITCH
.else
        OUTL    (1<<3),SWITCH
.endif
	NOP
	LAC	TAD_ATT1	;
	ANDK	0X1f
	ADHL	VOL_TAB
	CALL	GetOneConst
	SAH	CODECREG2
	SFL	5
	OR	CODECREG2
	SAH	CODECREG2
	OUT	CODECREG2,LOUTSPK
	ADHK	0
;---
	RET
;---
DAA_REC:	;(SW2) ==> (AUX->ADC)
	LIPK    6
	OUTK    (1<<2),SWITCH

	NOP
	OUTL	(CLAD1_GAIN<<4),AGC
;---
	RET

;---------------------------------------
DAA_OFF:	;(all open)
.if	1
	LIPK	6
	OUTK	0,SWITCH	;all switch open
.else
	PSH	CONF
	LACL	0x5E08		;AUX -> AD0
	CALL	DAM_BIOSFUNC
	POP	CONF
.endif
	RET
;---------------------------------------
DAA_ANS_SPK:	;(SW1)&(SW3)&(SW7) ==> (LIN->ADC)&(DAC->SPK)&(DAC->LOUT)
	LIPK    6
        OUTL    ((1<<1)|(1<<3)|(1<<7)),SWITCH
	NOP
	LAC	TAD_ATT1	;
	SFR	5
	ANDK	0X1f
	ADHL	VOL_TAB
	CALL	GetOneConst
	SAH	CODECREG2
	SFL	5
	OR	CODECREG2
	SAH	CODECREG2
	
	OUT	CODECREG2,LOUTSPK
	ADHK	0
;---
	RET
;---------------------------------------
DAA_ANS_REC:	;(SW1)&(SW7) ==> (LIN->ADC)&(DAC->SPK)
;---
	LIPK    6
        OUTL    ((1<<1)|(1<<7)),SWITCH
	NOP
;---
	OUTL	(CRAD1_GAIN<<4),AGC
	NOP
;---
	LAC	TAD_ATT1	;
	SFR	5
	ANDK	0X1f
	ADHL	VOL_TAB
	CALL	GetOneConst
	SAH	CODECREG2
	SFL	5
	OR	CODECREG2
	SAH	CODECREG2
	
	OUT	CODECREG2,LOUTSPK
	ADHK	0

	RET
;---------------------------------------
DAA_LIN_SPK:	;(SW1)&(SW3) ==> (LIN->ADC)&(DAC->LOUT)
	LIPK    6
        OUTL    ((1<<1)|(1<<3)),SWITCH
        NOP
        
	LAC	TAD_ATT1	;
	SFR	5
	ANDK	0X1f
	ADHL	VOL_TAB
	CALL	GetOneConst
	SAH	CODECREG2
	SFL	5
	OR	CODECREG2
	SAH	CODECREG2
	
	OUT	CODECREG2,LOUTSPK
	ADHK	0

	RET
DAA_LIN_REC:	;(SW1) ==> (LIN->ADC)
	LIPK    6
        OUTL    (1<<1),SWITCH
	NOP
	OUTL	(CRAD1_GAIN<<4),AGC
	NOP	
	RET

;-------------------------------------------------------------------------------
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

	;LACL	0XD107		;0 - 3.6kbps
	;LACL	(0XD107)|(1<<3)	;1 - 4.8kbps
	;LACL	(0XD107)|(2<<3)	;2 - 6.0kbps
	LACL	(0XD107)|(3<<3)	;3 - 7.2kbps
	;LACL	(0XD107)|(4<<3)	;4 - 8.4kbps
	;LACL	(0XD107)|(5<<3)	;5 - 9.6kbps

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
	
	LACL	500
	CALL	DELAY

	CALL    BEEP_STOP	;// beep stop

        RET
;-------------------------------------------------------------------------------
;	Function : PAUBEEP
;	
;	INPUT : ACCH = BEEP LENGTH
;	Generate a warning beep
;-------------------------------------------------------------------------------
PAUBEEP:
	PSH	CONF
	NOP
;---
	SAH	SYSTMP1

	CALL    BEEP_START
	LACL	0X2000		;Fre1
	CALL    DAM_BIOSFUNC
	LACK	0		;Fre2
	CALL    DAM_BIOSFUNC
	LAC	SYSTMP1
	CALL	DELAY
	CALL    BEEP_STOP	;// beep stop
;---	
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
HOOK_ON:		;Set EVENT.10 = 1 GPBD.7 = 0
	LIPK	8

	IN	SYSTMP0,GPBD
	LAC	SYSTMP0
	ANDL	~(1<<7)
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
	ORL	1<<7
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
;	��һ�����һ�쵽�ϸ������һ�������,����ɱ仯��������(��������)
DATE_TAB:
	;31	28	31	30	31	30	31	31	30	31	30	31
	;1��	2��	3��	4��	5��	6��	7��	8��	9��	10��	11��	12��
.DATA	0	3	3	6	1	4	6	2	5	0	3	5
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
DTMF_TABLE:
 	;no	1	2	3	4	5	6	7	8	
.DATA	0X00	0XF1	0XF2	0XF3	0XF4	0XF5	0XF6	0XF7	0XF8

	;9	*	0	#	A	B	C	D
.DATA	0XF9	0XFE	0XF0	0XFF	0XFA	0XFB	0XFC	0XFD  
;-------------------------------------------------------------------------------
;VOL_TAB:	;for Speaker
	;0	1	2	3	4	5	6	7
;.DATA	0X01	0X05	0X0A	0X0F	0X13	0X17	0X1B	0X1F
;-------------------------------------------------------------------------------
VOL_TAB:	;for Line-out
	;0	1	2	3	4	5	6	7
.DATA	0X00	0X01	0X02	0X03F	0X04	0X05	0X06	0X07
	;8	9	10	11	12	13	14	15
.DATA	0X08	0X09	0X0A	0X0B	0X0C	0X0D	0X0E	0X0F
	;16	17	18	19	20	21	22	23
.DATA	0X10	0X11	0X12	0X13	0X14	0X15	0X16	0X17
	;24	25	26	27	28	29	30	31
.DATA	0X18	0X19	0X1A	0X1B	0X1C	0X1D	0X1E	0X1F

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
;.DATA   0XC0	0XF9	0XA4	0XB0	0X99	0X92	0X82	0XF8
;	8	9	A	b	C	d	E	F
;.DATA   0X80	0X90	0X88	0X83	0XC6	0XA1	0X86	0X8E
;	bL	rE	dE	--	PA	rA	Ln	FL
;	0X83C7	0XAF86	0XA186	0XBFBF	0X8C88	0XAF88	0XC7AB	0X8EC7
;	����	������	��������Fu	PR	Er	tt
;	0XF7	0XB7	0XB6	0X8EE3	0X8C88	0X86Af	0X8787
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
.INCLUDE	initial.asm
.INCLUDE	ring_det.asm
.INCLUDE	key_det.asm
.INCLUDE	Iic.asm
.INCLUDE	main.asm

.INCLUDE	gui.asm
.INCLUDE	syspro.asm
.INCLUDE	local.asm
.INCLUDE	drive.asm
.INCLUDE	tel_wr.asm
.INCLUDE	voice_p.asm

;.INCLUDE	f_answer.asm
;.INCLUDE	f_remote.asm
		
;.INCLUDE	table.asm
;.INCLUDE	error.asm	;������

.END

