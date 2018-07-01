;*******************************************************************************
;
;	MXIC MX93U20 CODE
;
;*******************************************************************************
;telphone - mode working group 0 ==>(0XE600) 存贮来电号码
;telphone - mode working group 1 ==>(0XE601) 存贮MAILBOX1中ICM对应的电话号码
;telphone - mode working group 2 ==>(0XE602) 存贮MAILBOX2中ICM对应的电话号码
;telphone - mode working group 3 ==>(0XE603) 存贮MAILBOX3中ICM对应的电话号码
;telphone - mode working group 4 ==>(0XE604) 存贮电话本电话号码
;telphone - mode working group 5 ==>(0XE605) 存贮DAM信息PSWORD---(byte0..2)
;							contrast---(byte3)
;							local code---(byte4..7)
;MAILBOX1 - 0XD001_0XD200(MEMO)
;MAILBOX2 - 0XD002_0XD200(MEMO)
;MAILBOX3 - 0XD003_0XD200(MEMO)

;MAILBOX1 - 0XD001_0XD202(OGM)
;-----------
;GPA(0..7)	- 7SegLED	(OUTPUT)
;GPA(8..11)	- 7SegLED&&KEY	(OUTPUT)
;GPA(12..15)	- KEY		(INPUT)
;-----
;GPB.0		- IntIo1
;GPB.1		- IntIo2
;GPB.2		- RING_DET
;GPB.3		- CPC_DET
;GPB.4		- LINE_REV
;GPB(5/6)	- SER(DAT/WR)
;GPB.7		- HOOK
;GPB(8,9)	-
;GPB(10/11)	- I2CDA/I2CLK
;GPB.12		-
;Register indirect Addressing save only in interrupt==>AR1
;TMR1;用于时间更新DateTime(0--1000)
;TMR2;用于key detect
;TMR3;用于ring detect
;PRO_VAR = 
;ANN_FG :	bit0=
;		bit1=
;		bit2=	1/0---receiving CID/not
;		bit3=	0/1 = OGM1/OGM2(select vp and status)
;		bit4=
;		bit5=
;               -------------------------
;		bit6=
;
;		bit7=	0,remote operation-DTMF end
;			1,remote operation-DTMF happened---(DTMF detected process for"busy_chk")
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
;		bit3=
;		bit4=	1/0------line mode/not
;		bit5=	1/0------beep mode/not
;		bit6=	1/0------vp mode/not
;		bit7=	1/0------record mode/not
;		bit8=	1/0------answer only/ICM(=0时,VOI_ATT11..8有效;=1时无效)
;		bit9=	1/0------answer on/off
;		bit10=
;		bit11=
;		bit12=
;		bit13=
;		bit14=
;		bit15=
;-------------------------------------------------------------------------------
.NOLIST
.INCLUDE	REG_D20.inc
.INCLUDE	MX93D20.inc
.INCLUDE	MACRO.inc
.INCLUDE	CONST.inc

.LIST


.EXTERN	GetOneConst	;(INPUT=ACCH(ProgramRamAddress),OUTPUT=ACCH(ReadData))
.EXTERN	GetMoreConst	;(INPUT=ACCH(ProgramRamStartingAddress)ACCL(ReadWordNumber)AR1(StoreDataRamAddress),OUTPUT=)

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
IicInt:    ;INT_TTMP1,1,2
;------
	lipk	5
	in	INT_TTMP1,IICSR    	;IICSR-->INT_TTMP1
	bit	INT_TTMP1,15
	bz	TB, IicInt_01		;INT_TTMP1.15==0 (in Rx opertion)
	call	IicTx
	RET
IicInt_01:
	call    IicRx
	RET
;-------------------------------------------------------------------------------
;	1ms timer interrupt
;-------------------------------------------------------------------------------
IntTimer1:
	LAC	TMR2
	ADHK	0X01
	ANDK	0X0F
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
;------ BELOWS ARE FOR RING CHECKING (FREQUENCY RANGE : 15 - 95 Hz) ------------
IntTimer1_RingChk:
	;CALL	RING_CHK
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
;-------belows are for receive detect-------------------------------------------
INT_REQUEST_DET:
	BIT	SER_FG,8
	BS	TB,INT_REQUEST_DET_END	;正在收
	BIT	SER_FG,9
	BS	TB,INT_REQUEST_DET_END	;正在发
	
	IN	INT_TTMP1,GPBD
	BIT	INT_TTMP1,9
	BS	TB,INT_REQUEST_DET2
;---对方有发送请求	
	LAC	SER_FG
	ANDK	0X7F
	BS	ACZ,INT_REQUEST_DET1
	
	LAC	SER_FG
	SBHK	1
	SAH	SER_FG
	BS	B1,INT_REQUEST_DET_END
INT_REQUEST_DET1:
	LACL	CMSG_SER
	CALL	INT_STOR_MSG
		
	LAC	SER_FG
	ORK	0X0F
	;SAH	SER_FG
	BS	B1,INT_REQUEST_DET_END
INT_REQUEST_DET2:
	LAC	SER_FG
	ANDL	0XFF80
	SAH	SER_FG
INT_REQUEST_DET_END:	
;-------------------------------------------------------------------------------	
	RET
;-------------------------------------------------------------------------------
; 	0.5ms timer interrupt
;-------------------------------------------------------------------------------
IntTimer2:
	RET
;-------------------------------------------------------------------------------
;	Io-port interrupt---portB-0
;-------------------------------------------------------------------------------
;Io-port interrupt
IntIo1:
	;CALL	SER_EXE

	RET
;-------------------------------------------------------------------------------
;	Io-port interrupt---portB-1
;-------------------------------------------------------------------------------
IntIo2:
	RET
;-------------------------------------------------------------------------------
;	Function : DAM_BIOSFUNC
;	input : ACCH = command
;	output: ACCH = respone
;-------------------------------------------------------------------------------
DAM_BIOSFUNC:
	SAH     CONF
	CALL    DAM_BIOS
	LAC     RESP

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
        LAC	ANN_FG		;ANN_FG(bit12)=0/1---not have/have new message(current mbox,current type)
	ORL	0X1000
	SAH	ANN_FG
        
        LACL	0X3001
	CALL	DAM_BIOSFUNC		;save the number of NEW messages
	SAH	MSG_N
	BZ      ACZ,VPMSG_CHK1_1

	LAC	ANN_FG		;clear ANN_FG.12
	ANDL	0XEFFF
	SAH	ANN_FG
VPMSG_CHK1_1:
;-------get the total message number,save it in MSG_T---------------------
;VPMSG_CHK2: 
	LAC	ANN_FG    	;ANN_FG(bit14)=1/0---have/not have message(current mbox,current type)
	ORL	0X4000
	SAH	ANN_FG

        LACL	0X3000
	CALL	DAM_BIOSFUNC	;save the number of TOTAL messages
	SAH	MSG_T
        BZ	ACZ,VPMSG_CHK2_1

	LAC	ANN_FG		;clear ANN_FG.14
	ANDL	0XBFFF
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
  	ORL	0X2000		;set ANN_FG.13
	SAH	ANN_FG
	BS	B1,VPMSG_CHK3_3
VPMSG_CHK3_2:
	LAC	ANN_FG		;clear ANN_FG.13
	ANDL	0XDFFF
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
;		MSG_N = 1/2	= the current OGM index(USR INDEX DATA0)
;-------------------------------------------------------------------------------
OGM_SELECT:			;用于录音/放音时确定OGM_ID(非接线时用)
	SAH	MSG_N

OGM_SELECT_1:
	CALL	OGM_STATUS1
	
	RET
;-------------------------------------------------------------------------------
;	OGM_STATUS
;	check weather the current OGMx exist?
;	input : EVENT.8		= 0/1---answer ICM/answer only
;		EVENT.9		= 0/1---answer on/off
;		ANN_FG.13	= 0/1---not/memoful
;		VOI_ATT(11..8)
;	output: ACCH = 1/0 --- no OGM/the OGM exist
;
;		MSG_ID		= index NO.in current MBOX in current MSG type(OGM)
;		MSG_N = 1/2/3/4/5 = the current OGM index(USR INDEX DATA0)
;-------------------------------------------------------------------------------
OGM_STATUS:			;接线时用
	LAC	VOI_ATT
	SFR	8
	ANDK	0X0F
	SAH	MSG_N
	
	LAC	VOI_ATT		;answer only?
	SFR	8
	ANDK	0X0F
	SBHK	5
	BS	ACZ,OGM_STATUS0
	BIT	EVENT,8		;answer only?
	BS	TB,OGM_STATUS0
	BIT	EVENT,9		;answer off?
	BS	TB,OGM_STATUS0
	BIT	ANN_FG,13	;memoful?
	BS	TB,OGM_STATUS0
	BS	B1,OGM_STATUS1
OGM_STATUS0:	
	LACK	5
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
        SAH     CONF
        CALL    DAM_BIOS

	LACL    0X3005           	; check if garbage collection is required ?
        SAH     CONF
        CALL    DAM_BIOS
        LAC     RESP
        BZ      ACZ,GC_CHK

	RET
	

;-------------------------------------------------------------------------------
BINVIO:
	LIPK	8
	
	IN	SYSTMP0,GPBD
	LAC	SYSTMP0
	XORL	0X0060
	SAH	SYSTMP0
	OUT	SYSTMP0,GPBD
	ADHK	0
	
	RET
;-------------------------------------------------------------------------------
DAA_SPK:	;(SW3) ==> (ADC->LOUT)
	LIPK    6
	OUTL    0x0008, SWITCH	; DAC -> LOUT
	OUTL    0x0088, SWITCH	; (DAC -> SPK)&(DAC -> LOUT)

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
DAA_REC:	;(SW0)(SW1) ==> (LIN->ADC)&(MIC->ADC)
	LIPK    6
	OUTK    0x0003,SWITCH	;

	NOP
	IN	SYSTMP0,AGC
	LAC	SYSTMP0
	ANDL	0xF00F
	ORL	0X0CCC
	SAH	SYSTMP0
	OUT     SYSTMP0,AGC	; Lin-pga=c ; AD-PGA=c(0dB) ; MIC-pre-pga=c (+21dB)
	ADHK	0
;---

	RET
DAA_OFF:
	LIPK    6
	OUTK   0x0000,SWITCH
	RET
DAA_LIN_SPK:	;(SW1)&(SW3)&(SW7) ==> (LIN->ADC)&(DAC->SPK)&(DAC->LOUT)
	LIPK    6
        OUTL    0x008A,SWITCH
        NOP
	OUTL	0x7fff,LOUTSPK
	NOP
	RET
DAA_LIN_REC:	;(SW1)&(SW7) ==> (LIN->ADC)&(DAC->SPK)
	LIPK    6
        OUTL    0x0082,SWITCH
	NOP
	OUTL	0x7fff,LOUTSPK
	NOP
	
	RET
DAA_ROM_MOR:	;(SW0)&(SW4)			
				; MIC ->pre-pga -> ad1-pga -> SW4 -> LOUT
				; LIN -> ad2-pga -> ADC2
	LIPK    6
	;OUTK	0x0011,SWITCH
	OUTK	0x0013,SWITCH
        NOP
	OUTL	0x7fE0,LOUTSPK
	NOP
	OUTL	0X0BCC,AGC
	NOP
	
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
;-------------------------------------------------------------------------------
HOOK_ON:		;GPBD.7
	LIPK	8

	IN	SYSTMP0,GPBD
	LAC	SYSTMP0
	ORL	0X0080
	SAH	SYSTMP0
	OUT	SYSTMP0,GPBD
	ADHK	0
	RET
;---
HOOK_OFF:		;GPBD.7
	LIPK	8

	IN	SYSTMP0,GPBD
	LAC	SYSTMP0
	ANDL	0XFF7F
	SAH	SYSTMP0
	OUT	SYSTMP0,GPBD
	ADHK	0
	RET
;-------------------------------------------------------------------------------
DspStop:
	dint
DspStop_loop:
	nop
	nop
	nop
	nop
	bs	b1,DspStop_loop
;-------
;DspPly:
	adhk	1
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
.DATA	0X00	0X05	0X0A	0X0F	0X13	0X17	0X1B	0X1F
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
      ;// 0      1      2      3      4      5      6      7
.DATA   0XC0   0XF9   0XA4   0XB0   0X99   0X92   0X82   0XF8
      ;// 8      9      A      B      C      D      E      F
.DATA   0X80   0X90   0X88   0X83   0XC6   0XA1   0X86   0X8E
;-------------------------------------------------------------------------------
.INCLUDE	initial.asm
.INCLUDE	ring_det.asm
.INCLUDE	key_det.asm
.INCLUDE	main.asm
.INCLUDE	Iic-slave.asm
.INCLUDE	Iic-host.asm
.INCLUDE	gui.asm
.INCLUDE	syspro.asm
.INCLUDE	local.asm
.INCLUDE	drive.asm

.INCLUDE	answer.asm
.INCLUDE	remote.asm

;.INCLUDE	table.asm
;.INCLUDE	error.asm	;调试用

.END

