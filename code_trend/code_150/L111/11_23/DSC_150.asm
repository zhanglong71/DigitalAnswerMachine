.NOLIST
;MX93L111S2---2007/07/20-B77A
;Register indirect Addressing save only in interrupt==>AR1
;TMR1;用于时间更新DateTime(0--1000)
;TMR2;用于key detect
;TMR3;用于ring detect
;PRO_VAR = 
;ANN_FG :	bit0=	1/0---initial/initial complete
;		bit1=	1/0---caller id valid/caller id invalid(来铃失败/来第一次铃声时清除,收到来电信息时置位)
;		bit2=	1/0---receiving CID/receive CID end
;		bit3=	0/1 = OGM1/OGM2(select vp and status)
;		------
;		bit4=	0,remote operation-DTMF end
;			1,remote operation-DTMF happened---(DTMF detected process for"busy_chk")
;		------
;		bit5=	0/1---no/new ICM messages(mailbox1)
;		bit6=	0/1---no/new ICM messages(mailbox2)
;		bit7=	0/1---no/new ICM messages(mailbox3)
;		bit8=	0/1---no/new ICM messages(current mailbox current message type)---(MSG_CHK)
;		bit9=	0/1---no/new messages(mailbox1)	
;		bit10=	0/1---no/new messages(mailbox2)
;		bit11=	0/1---no/new messages(mailbox3)
;		bit12=	0/1---no/new messages(current mailbox current message type)---(MSG_CHK)
;
;		bit13=	0,not memory full---(MSG_CHK)
;			1,memory full
;		bit14=	0,no message---(current mailbox current message type)
;			1,have message
;		bit15=	0/1---12.8/4.8kbps
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
;		bit10=	1/0---发送显示命令(当EVENT(3..0)=0时执行)
;		bit11=  1/0---12/24时制选择(由BIOR.3输入口决定default=(EVENT.11=0) ==>24时制)
;		bit12=	1/0------ring in ok/no
;		bit13=	1/0------LED1 flash	(new caller_id)
;		bit14=	1/0------LED2 flash	(answer ON/OFF---new messages)
;		bit15=
;VOI_ATT:	bit(3..0) = ATT1
;		bit(7..4) = RING_CNT
;		bit(11..8)= OGM_ID
;		bit(13,12)= LANGUAGE
;		bit14 = 1/0------BeepVoicePrompt/not
;		bit15 = 1/0------NewMsgBeepPrompt/not
;		--------------------------
;IPTR :		bit(3,2,1,0) --- KEY SCAN IN
;		bit4 --- RING-DET
;		bit5 --- 
;		bit6 --- CPC-DET
;		--------------------------
;BIOR :		bit0 = ------ LED 背光					O
;		bit1 = ------
;		bit2 = ------ 1/0 = ICM/only				I
;		bit3 = ------ 1/0 = 12/24时制选择			I
;		bit(5,4)----- SIO(wr,dat)				I,I/O,I/O
;		bit6 = ------ 
;		bit7 = ------ 1/0--- 初始语言选择(English/German)	I
;		--------------------------
;OPTR :		bit11 --- LED1
;		bit12 --- LED2
;		bit13 --- HOOK
;		bit14 --- TWO_WAY HOOK
;		bit15 --- Scan for 12.8/4.8kbps select
;------------------------------------------------------------------------------
;telphone - mode working group 0 ==>(0XE600) 存贮来电号码
;telphone - mode working group 1 ==>(0XE601) 存贮MAILBOX1中ICM对应的电话号码
;telphone - mode working group 2 ==>(0XE602) 存贮MAILBOX2中ICM对应的电话号码
;telphone - mode working group 3 ==>(0XE603) 存贮MAILBOX3中ICM对应的电话号码
;telphone - mode working group 4 ==>(0XE604) 存贮电话本电话号码
;telphone - mode working group 5 ==>(0XE605) 存贮DAM信息PSWORD---(byte0..2)
;							local code---(byte3..7)
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
.INCLUDE mx111S4.INC
.INCLUDE reg2523b.inc
.INCLUDE CONST.INC
.LIST

CBEEP_COMMAND	.EQU		0X48F9	;BEEP CON

ALC_ON		.EQU   		1

CMODE9		.EQU		0X0040	;NEW/OLD SEL
GCVP_TLEN	.EQU   		2000	;录满了一次做GC_CHK的最长时间(ms)
GCTEL_TLEN	.EQU   		1000	;录满了一次做GC_TEL_CHK的最长时间(ms)
CPC_TLEN	.EQU   		61	;CPC检测的有效宽度
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

DAM_BIOS  	.EQU   		0X20
.global	INT_STOR_MSG
.extern	RING_CHK		;from ring_det.asm
.extern	KEYSCAN_CHK		;from key_det.asm

.extern	SER_TMR
.extern	SER_DET
.extern	SER_EXE
.extern	SER_CLK
.extern	STOR_DAT
;//==============================================================================
;//+                        DAM DEMO PROGRAM                                    +
;//==============================================================================

.ORG    0XC000
.DATA   0X1234  0X5678

        BS      B1,MAIN          ;// ORG=0X00
        BS      B1,INT_NMI       ;// ORG=0X02
        BS      B1,INT_SS        ;// ORG=0X04
        BS      B1,INT_1         ;// ORG=0X06
        BS      B1,INT_CODEC     ;// ORG=0X08
        BS      B1,INT_HOSTW     ;// ORG=0X0A
        BS      B1,INT_HOSTR     ;// ORG=0X0C
        BS      B1,INT_STMR      ;// ORG=0X0E

.DATA   0X0111  0X0100           ; MX93L111-version 01.00   ;0x5010(2005.11.10)
;-------------------------------------------------------------------------------
INT_CODEC:
        ldpk    0
        LIPK	0

	SAR	CURT_ADR1,1	;Save AR1
;-------------------------------
	LAC	TMR3		;//for ring detection(-1/125us)
	SBHK	0X01
	SAH	TMR3

	CALL	SER_TMR		;计时
;-------------------------------
	LAR	CURT_ADR1,1
        RET
;-------------------------------------------------------------------------------
INT_1:
	ldpk    0
	LIPK	0

	SAR	CURT_ADR1,1	;Save AR1
;-------------------------------
	CALL	SER_CLK		;侦测CLK
	
	CALL	SER_DET		;检测发送或接收请求
	
	CALL	SER_EXE		;执行发送或接收任务
;-------------------------------
	LAR	CURT_ADR1,1
	RET
;-------------------------------------------------------------------------------
INT_STMR:
	LDPK	0
	LIPK	0
	SAR	CURT_ADR1,1	;Save AR1
;-------------------------------------------------------------------------------				
	LAC     TMR1		;//用于DateTime(0--1000)
        ADHK    0X01
        SAH     TMR1
        
        LAC     TMR1
        ANDK	0X03
        BZ	ACZ,INT_STMR1
        
        LAC     TMR_BTONE	;//for BUSY TONE(+1/4ms)
        ADHK    0X01
        SAH     TMR_BTONE
INT_STMR1:
		
	LAC	TMR_VOX		;//for VOX detection(-1/ms)
	SBHK	0X01
	SAH	TMR_VOX

	LAC	TMR_CTONE	;//for CONT TONE(-1/ms)
	SBHK	0X01
	SAH	TMR_CTONE

	LAC	TMR2		;//used to scan and LED display(+1/ms)
	ADHK	0X01
	SAH	TMR2
	
	LAC	TMR2
	SBHK	0X10
	BS	SGN,INT_STMR2		 
	SAH	TMR2		;//reset TMR2
	call    DateTime	;//execute every 16ms
INT_STMR2:
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
;//------ BELOWS ARE FOR ring detect --------------------------	
	CALL	RING_CHK
;-------belows are for long of beep time,end beep when TMR_BEEP=0------------
INT_T_BEEP:
	LAC	TMR_BEEP
	BS	SGN,INT_T_BEEP_END
	;LAC	TMR_BEEP
	SBHK	1
	SAH	TMR_BEEP
	BZ	ACZ,INT_T_BEEP_END
	LACL	CSEG_END
	CALL	INT_STOR_MSG
INT_T_BEEP_END:
;-------belows are for timer----------------------------------------------
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
;					0 ===> LED2_OFF
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
	CALL	LED1_OFF
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
	
	BIT	EVENT,14
	BZ	TB,INT_LED2_ON

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
	CALL	LED2_ON
	BS	B1,INT_LED2_END	
INT_LED2_OFF:
	CALL	LED2_OFF
INT_LED2_END:
;-------belows are for initial LED1/LED2 flash----------------------------------
;-------------------------------------------------------------------------------
INT_INIT:
	BIT	ANN_FG,0
	BZ	TB,INT_INIT_END		;初始化结束
	
	LAC	TMR_LED2
	BS	ACZ,INT_LED_FLASH
	SBHK	1
	SAH	TMR_LED2
	BS	B1,INT_INIT_END
INT_LED_FLASH:
	CALL	LED1_FLASH
	CALL	LED2_FLASH
	LACL	400
	SAH	TMR_LED2
INT_INIT_END:	
;-------belows are for cpc-det--------------------------------------------------
INT_CPC_DET:
	LIPK	0
        IN	INT_TTMP1,OPTR
        BIT	INT_TTMP1,13		;摘机了(hook_on)吗?
	BZ	TB,INT_LOCAL_FUNC
	
	LAC	TMR_CPC
	SBHL	CPC_TLEN		;CPC时长
	BZ	SGN,INT_CPC_DET4

	IN	INT_TTMP1,IPTR
	BIT	INT_TTMP1,6
	BZ	TB,INT_CPC_DET2
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
	CALL	INT_STOR_MSG
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
;工作原理:	RING_ID_BAK根据 BIOR.0的值确定;BIOR(1,0) = ----- (00/10=2),(01=6),(11=2/6) 铃声
;		RING_ID的取值原理:	DAM空闲时(FUNC_STACK=0),若开答录则RING_ID = RING_ID_BAK,否则RING_ID = 10
;					DAM忙时(FUNC_STACK!=0),RING_ID = 0
;-------------------------------------------------------------------------------
SYS_MONI_RINGCNT:
	LIPK	0
        IN	INT_TTMP1,OPTR
        BIT	INT_TTMP1,13		;摘机了(hook_on)吗?
	BZ	TB,SYS_MONI_RINGCNT1

	LACK	0
	SAH	RING_ID
	BS	B1,SYS_MONI_RINGCNT_END
SYS_MONI_RINGCNT1:
	BIT	EVENT,9
	BZ	TB,SYS_MONI_RINGCNT1_0

	LAC	RING_ID
	ANDL	0XFFF0
	ORK	10
	SAH	RING_ID	
	BS	B1,SYS_MONI_RINGCNT_END
SYS_MONI_RINGCNT1_0:

	LAC	RING_ID
	ANDL	0XFFF0
	SAH	RING_ID
	
	LAC	VOI_ATT
	SFR	4
	ANDK	0XF
	SBHK	2
	BS	SGN,SYS_MONI_RINGCNT1_1

	LAC	VOI_ATT
	SFR	4
	ANDK	0X0F
	OR	RING_ID
	SAH	RING_ID
	
	BS	B1,SYS_MONI_RINGCNT_END

SYS_MONI_RINGCNT1_1:
	LAC	RING_ID
	ORK	0X0002
	SAH	RING_ID
	
	LAC	ANN_FG			;new messages exist?
	ANDL	0X0E00
	BZ	ACZ,SYS_MONI_RINGCNT_END
	
	;BIT	ANN_FG,12
	;BS	TB,SYS_MONI_RINGCNT_END
	
	LAC	RING_ID
	ORK	0X0006
	SAH	RING_ID
SYS_MONI_RINGCNT_END:	
;-------初始时间制式选择12/24---------------------------------------------------
INI_SELTIME:
	CIO	11,BIOR			;set BIOR.3 as a input port
        IN      INT_TTMP1,BIOR
	BIT	INT_TTMP1,3
	BS	TB,INI_SELTIME2
;INI_SELTIME1:	

	BIT	EVENT,11
	BZ	TB,INI_SELTIME_END

	CRAM	EVENT,11		;(BIOR.3 = 0)有变化
	BS	B1,INI_SELTIME_CHANGED
INI_SELTIME2:	
	
	BIT	EVENT,11
	BS	TB,INI_SELTIME_END
	SRAM	EVENT,11		;(BIOR.3 = 1)有变化
INI_SELTIME_CHANGED:
	LACL	CMSG_TIFAT
	CALL	INT_STOR_MSG
INI_SELTIME_END:	
;-------------------------------------------------------------------------------

	LAR	CURT_ADR1,1
	
	RET

;-------------------------------------------------------------------------------
SetFlashWaitState:
        LIPK    0X01
        IN      SYSTMP1,WSTR
        LAC     SYSTMP1
	ANDL    0xf038
        ORL     0x08C3
        SAH     SYSTMP1
        OUT     SYSTMP1,WSTR
        LIPK	0
        RET
;-------------------------------------------------------------------------------
SetDspRunMode:               ;// dsp in fast/slow mode
        LIPK    0X0          ;// for 2523 set fast mode
        in      SYSTMP1,CTLR
        lac     SYSTMP1
        orl     0x3100       ;// fastmode+enable codec
        sah     SYSTMP1
        Out     SYSTMP1,CTLR
WaitCodecRdy:
        in      SYSTMP1,CTLR
        lac     SYSTMP1
        bit     SYSTMP1,9
        bS      TB,WaitCodecRdy
        RET

;----------------------------------------------------------------------------
;       Function : GC_CHK
;
;       Check garbage collection
;----------------------------------------------------------------------------
GC_CHK:
	LACL	20000
	SAH	TMR_CTONE	;20 seconds
GC_CHK_LOOP:
	LAC	TMR_CTONE
	BS	SGN,GC_CHK_RTN
	
	LACL    0X3007   		; do garbage collection
        SAH     CONF
        CALL    DAM_BIOS

	LACL    0X3005           	; check if garbage collection is required ?
        SAH     CONF
        CALL    DAM_BIOS
        LAC     RESP
        BZ      ACZ,GC_CHK_LOOP
GC_CHK_RTN:	
	
	RET
;----------------------------------------------------------------------------
;       Function : TEL_GC_CHK
;
;       Check garbage collection
;----------------------------------------------------------------------------
TEL_GC_CHK:
	LACL	GCTEL_TLEN
	SAH	TMR_CTONE
TEL_GC_LOOP:
        LACL    0XE407          ; do garbage collection first
        SAH     CONF
        CALL    DAM_BIOS

	LAC	TMR_CTONE
	BS	SGN,TEL_GC_CHK_RTN
	
        LACL    0XE405            ; check if garbage collection is required ?
        SAH     CONF
        CALL    DAM_BIOS
        LAC     RESP
        BZ      ACZ,TEL_GC_LOOP

TEL_GC_CHK_RTN:
        RET

;----------------------------------------------------------------------------
;       Function : SET_COMPS
;
;       Set compress 
;----------------------------------------------------------------------------
SET_COMPS:
	BIT	ANN_FG,15
	BS	TB,SET_COMPS_128
;SET_COMPS_48:	
	LACL	0XD101		;4.8kbps
	BS	B1,SET_COMPS_END
SET_COMPS_128:
	LACL	0XD109		;12.8kbps
SET_COMPS_END:	
	SAH	CONF
	CALL	DAM_BIOS
	RET
;----------------------------------------------------------------------------
;       Function : SET_SILENCE
;
;       Set silence threshold level
;----------------------------------------------------------------------------
SET_SILENCE:

	ANDK	0X0F
	ORL	0X7700
	SAH	CONF
	CALL	DAM_BIOS
	
	RET
;-------------------------------------------------------------------------------
;       Function : GET_TOTALMSG
;	for DSP
;	input  : no
;	output : ACCH = the number of total messages
;----------------------------------------------------------------------------
GET_TOTALMSG:
	LACL    0X3000
        SAH     CONF
        CALL    DAM_BIOS
        LAC     RESP

	RET
;----------------------------------------------------------------------------
;       Function : GET_NEWMSGNUM
;	input  : no
;	output : ACCH = the number of total messages in current mailbox in current message type
;----------------------------------------------------------------------------
GET_NEWMSGNUM:
	LACL    0X3001
        SAH     CONF
        CALL    DAM_BIOS
        LAC     RESP

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
        SAH     CONF
        CALL    DAM_BIOS
        LAC     RESP
        SBHK	4
	BZ      SGN,MEMFULL_CHK_NOTFULL
MEMFULL_CHK_FULL:
	LACK	1
	
	RET
MEMFULL_CHK_NOTFULL:
	LACK	0
	RET
;-------------------------------------------------------------------------------
;       Function : GET_VPMSGT
;	for user
;	input  : no
;	output : ACCH = the number of total messages(User)
;----------------------------------------------------------------------------
GET_VPMSGT:
	CALL	GET_TOTALMSG
	ADHK	1
	SAH	SYSTMP0		;The number of total messages(DSP)
	
	LACL	0X0FF
	SAH	SYSTMP1		;first User_data
	
	LACK	0
	SAH	SYSTMP2		;The number of total messages(user)
GET_VPMSGT_LOOP:

	LAC	SYSTMP0
	SBHK	1
	SAH	SYSTMP0
	BS	ACZ,GET_VPMSGT_END
	CALL	GET_USRDAT
	SBH	SYSTMP1
	BS	ACZ,GET_VPMSGT_LOOP
	
	LAC	SYSTMP0		;保存新的User_data
	CALL	GET_USRDAT
	SAH	SYSTMP1
	
	LAC	SYSTMP2		;总数加一
	ADHK	1
	SAH	SYSTMP2
	BS	B1,GET_VPMSGT_LOOP
	
GET_VPMSGT_END:
	LAC	SYSTMP2
	RET
;-------------------------------------------------------------------------------
;       Function : GET_VPMSGN
;	for user
;	input  : no
;	output : ACCH = the number of new messages(User)
;----------------------------------------------------------------------------
GET_VPMSGN:
	CALL	GET_TOTALMSG
	ADHK	1
	SAH	SYSTMP0		;The number of total messages(DSP)
	
	LACL	0X0FF
	SAH	SYSTMP1		;first User_data
	
	LACK	0
	SAH	SYSTMP2		;The number of total messages(user)
GET_VPMSGN_LOOP:

	LAC	SYSTMP0
	SBHK	1
	SAH	SYSTMP0
	BS	ACZ,GET_VPMSGN_END	;check new status
	CALL	GET_VPMSG_NSTATUS
	BZ	ACZ,GET_VPMSGN_LOOP

	LAC	SYSTMP0
	CALL	GET_USRDAT
	SBH	SYSTMP1
	BS	ACZ,GET_VPMSGN_LOOP

	LAC	SYSTMP0		;保存新的User_data
	CALL	GET_USRDAT
	SAH	SYSTMP1

	LAC	SYSTMP2		;总数加一
	ADHK	1
	SAH	SYSTMP2
	BS	B1,GET_VPMSGN_LOOP
	
GET_VPMSGN_END:
	LAC	SYSTMP2
	RET
;----------------------------------------------------------------------------
;       Function : MSG_CHK
;       Check some FLASH status:ANN_FG : bit0..15
;	input  : MBOX_ID(1,2,3)
;	output : 

;	ANN_FG :
;		bit9=   0/1---no/new messages mailbox1
;		bit10=  0/1---no/new messages mailbox2
;		bit11=  0/1---no/new messages mailbox3

;		bit12=	0/1---no/new messages(current mailbox current message type)---(MSG_CHK)

;		bit13=	0,not memory full
;			1,memory full
;		bit14=	0,current mailbox have no message
;			1,current mailbox have message

;		MSG_T=	the number of TOTAL MESSAGE in current MAILBOX
;		MSG_N=	the number of NEW MESSAGE in current MAILBOX
;----------------------------------------------------------------------------
MSG_CHK:
	LACL	0XD000
	OR	MBOX_ID
	SAH	CONF
	CALL	DAM_BIOS
	
	LACL	0XD200
	SAH	CONF
	CALL	DAM_BIOS
;-------get the new message number,save it in MSG_N-------------------------
MSG_CHK1:

        SRAM	ANN_FG,12	;ANN_FG(bit12)=0/1---not have/have new message(current mbox,current type)
        
        CALL    GET_NEWMSGNUM	;save the number of TOTAL messages		;save the number of NEW messages
        SAH	MSG_N
        
        BZ      ACZ,MSG_CHK1_1
        
	CRAM	ANN_FG,12
MSG_CHK1_1:
	LAC	MBOX_ID
	SBHK	1
	BS	ACZ,MSG_CHK1_1_1
	SBHK	1
	BS	ACZ,MSG_CHK1_2_1
	SBHK	1
	BS	ACZ,MSG_CHK1_3_1
MSG_CHK1_1_1:		;---MBOX 1
	SRAM	ANN_FG,9
	BIT	ANN_FG,12
	BS	TB,MSG_CHK1_1_2
	CRAM	ANN_FG,9
MSG_CHK1_1_2:
	BS	B1,MSG_CHK1_5
MSG_CHK1_2_1:		;---MBOX 2
	SRAM	ANN_FG,10
	BIT	ANN_FG,12
	BS	TB,MSG_CHK1_2_2
	CRAM	ANN_FG,10
MSG_CHK1_2_2:
	BS	B1,MSG_CHK1_5
MSG_CHK1_3_1:		;---MBOX 3
	SRAM	ANN_FG,11
	BIT	ANN_FG,12
	BS	TB,MSG_CHK1_3_2
	CRAM	ANN_FG,11
MSG_CHK1_3_2:
	BS	B1,MSG_CHK1_5
;-------
MSG_CHK1_5:
	LAC	ANN_FG
	ANDL	0X0E00
	BS	ACZ,MSG_CHK1_5_1
	CALL	SET_LED2FG
	BS	B1,MSG_CHK1_5_2
MSG_CHK1_5_1:
	CALL	CLR_LED2FG
MSG_CHK1_5_2:
	;BS	B1,MSG_CHK1_6
MSG_CHK1_6:
;-------get the total message number,save it in MSG_T---------------------
MSG_CHK2:     
	SRAM	ANN_FG,14	;ANN_FG(bit14)=1/0---have/not have message(current mbox,current type)
	
        CALL    GET_TOTALMSG	;save the number of TOTAL messages
	SAH	MSG_T
	
        BZ	ACZ,MSG_CHK2_1

        CRAM	ANN_FG,14
MSG_CHK2_1:
;-------check if memory is full ?-----------------------------------------
MSG_CHK3:
	CRAM	ANN_FG,13

        CALL	MEMFULL_CHK
        BS	ACZ,MSG_CHK3_1
	
  	SRAM	ANN_FG,13
MSG_CHK3_1:
;------------------------------------------------------------------------------
MSG_CHK_RET:
;------------------------------------------------------------------------------
        RET
;//----------------------------------------------------------------------------
;//       Function : INITBEEP
;//
;//       Generate a warning beep
;//----------------------------------------------------------------------------
INITBEEP:
        PSH     CONF		;// push CONF to stack
        PSH     BUF1		;// push BUF1 to stack
        PSH     BUF2   		;// push BUF2 to stack

	LACL    0X3663 		;// 1700 Hz (1700 X 8.19)
        SAH     BUF1
        
        CALL    BEEP_START	;63ms

	LACL	2000
	CALL	DELAY

        CALL    BEEP_STOP	;// beep stop

        POP     BUF2		;// recover BUF2
        POP     BUF1		;// recover BUF1
        POP     CONF              ;// recover CONF

        RET
;//----------------------------------------------------------------------------
;//       Function : BEEP_START
;//
;//       The general function for beep generation
;//       Input  : BUF1=the beep frequency
;//-----------------------------------------------------------------------------
BEEP_START:
        LACL    0X48FB            	;// beep start
        SAH     CONF
        CALL    DAM_BIOS

        RET
;//----------------------------------------------------------------------------
;//       Function : BEEP_STOP
;//
;//       The general function for beep generation
;//-----------------------------------------------------------------------------
BEEP_STOP:
        LACL    0X4400            	;// beep stop
        SAH     CONF
        CALL    DAM_BIOS

        RET
;//----------------------------------------------------------------------------
;//       Function : WBEEP
;//
;//       Generate a warning beep
;//----------------------------------------------------------------------------
WBEEP:
        PSH     CONF              ;// push CONF to stack
        PSH     BUF1              ;// push BUF1 to stack
        PSH     BUF2              ;// push BUF2 to stack

        LACL    0X3663            ;// 1700 Hz (1700 X 8.19)
        SAH     BUF1
        CALL    BEEP_ACT

        LACL    0X3330            ;// 1600 Hz (1600 X 8.19)
        SAH     BUF1
        CALL    BEEP_ACT

        LACL    0X3CC9            ;// 1900 Hz (1900 X 8.19)
        SAH     BUF1
        CALL    BEEP_ACT

        POP     BUF2              ;// recover BUF2
        POP     BUF1              ;// recover BUF1
        POP     CONF              ;// recover CONF

        RET
        
;//----------------------------------------------------------------------------
;//       Function : BEEP_ACT
;//
;//       The general function for beep generation
;//       Input  : BUF1=the beep frequency
;//-----------------------------------------------------------------------------
BEEP_ACT:
        CALL    BEEP_START		;// beep start

        LACK    0X3F                	;// delay 63 ms
        SAH     TMR_BEEP
        CALL	DELAY

        CALL    BEEP_STOP

        RET
        
;-------------------------------------------------------------------------------
DELAY:
	ADHK	10
	SAH	TMR_BEEP
DELAY_LOOP:
	LAC     TMR_BEEP
	SBHK	10
        BZ      SGN,DELAY_LOOP
	RET
;//-----------------------------------------------------------------------------
;//       Function : DAA_SPK
;//       Change analog switches for LOCAL OGM SPK/RECORD play
;//----------------------------------------------------------------------------
DAA_SPK:
        LACL    0X0300          	;// ATT1
        SAH     CODECREG0
        
	LAC	VOI_ATT
        ANDL	0X07
        ADHL    VOL_TAB
        RPTK    0
        TBR     SYSTMP0
        LAC     SYSTMP0    
	;ORL	0X02
	ORK	0X03
        SAH     CODECREG2
        CALL    InSetCodecReg

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
DAA_REC:
.IF	ALC_ON
	LACL	0X4800			;ALC on
.ELSE
	LACL    0X5800			;ALC off
.ENDIF
        
        SAH     CODECREG0
	;LACL    0XB000
	LACL    0XA001
	;LACL    0X8002
        SAH     CODECREG1
        CALL	InSetCodecReg

	RET

;//---------------------------------------
DAA_LIN_SPK:
;.IF	ALC_ON	
;	LACL    0XCB08		;	ALC on
;.ELSE
        LACL    0XD808		;LIN==>SWC(b->A)==>SWD==>AD1;DA1==>SWL==>LINDRV==>TEL LINE
;.ENDIF
        SAH	CODECREG0
	LACL    0X8860
	SAH	CODECREG1
        LACL	0X0602
        SAH	CODECREG2

        CALL	InSetCodecReg
        
        RET
;---------------
DAA_LIN_REC:	;LIN==>SWC(b->A)==>SWD==>AD1
;.IF	ALC_ON
 	LACL    0XC800
;.ELSE
;       LACL    0XD800
;.ENDIF
        SAH     CODECREG0

	LACL    0X8860
	SAH	CODECREG1

        CALL	InSetCodecReg
        
        RET
;---------------
DAA_ANS_REC:			;相比DAA_LIN_REC打开SPK(关LOUT)

	LACL    0XCB00
	SAH     CODECREG0

	LACL    0X8860
        SAH	CODECREG1
        
        LAC	VOI_ATT
        ANDL	0X07
        ADHL    VOL_TAB
        RPTK    0
        TBR     SYSTMP0
        LAC     SYSTMP0    
        ORL	0X0602
        SAH     CODECREG2

        CALL	InSetCodecReg
        
        RET
;---------------
DAA_ANS_SPK:			;for OGM play back when DAM work相比DAA_LIN_SPK打开SPK(接通LOUT)

	LACL    0XCB08
	SAH     CODECREG0

	LACL    0X8860
	SAH	CODECREG1
        
        LAC	VOI_ATT
        ANDL	0X07
        ADHL    VOL_TAB
        RPTK    0
        TBR     SYSTMP0
        LAC     SYSTMP0    
        ORL	0X0602
        SAH     CODECREG2

        CALL	InSetCodecReg
        
        RET
;----------------------------------------------------------------
DAA_TWAY_RECORD:
        LACL    0X8800		;ALC_ON
        SAH	CODECREG0
	;LACL    0X4231
        LACL    0X4230
        SAH	CODECREG1

        CALL	InSetCodecReg
        
        RET
;----------------------------------------------------------------
DAA_ROM_MOR:
	LACL    0X4060			;MIC==>SWC(a->A)==>SWJ==>LIN DRV
        SAH     CODECREG0
        LACL    0X9002
        SAH     CODECREG1
        LACL	0X0800
        SAH	CODECREG2
        CALL    InSetCodecReg
        RET
;----------------------------------------------------------------

InSetCodecReg:
        LDPK	0
        LIPK	3
        OUT	CODECREG0,CDCTLR0
        OUT	CODECREG1,CDCTLR1
        OUT	CODECREG2,CDCTLR2
        LIPK	0

        RET
;//----------------------------------------------------------------------------
;//       Function : DAA_OFF
;//
;//       Change analog switches for LOCAL/LINE off
;//----------------------------------------------------------------------------
DAA_OFF:
        LACK	0X0
        SAH	CODECREG0
   
        CALL	InSetCodecReg
        
        RET
;//----------------------------------------------------------------------------
;//       Function : HOOK_ON
;//
;//       hand on the telephone
;//----------------------------------------------------------------------------
HOOK_ON:
	LIPK	0
        SIO	13,OPTR		;HOOK ON----OPTR(bit13)
	
	RET
;//----------------------------------------------------------------------------
;//       Function : HOOK_OFF
;//
;//       hand off the telephone
;//----------------------------------------------------------------------------
HOOK_OFF:
	lipk    0
	CIO	13,OPTR		;HOOK OFF---OPTR(bit13)
	
	RET
;//----------------------------------------------------------------------------
;//       Function : BLED_ON
;//
;//       hand on the telephone
;//----------------------------------------------------------------------------
BLED_ON:
	LIPK	0
	SIO	8,BIOR
        SIO	0,BIOR		;back LED on----BIOR(bit0)
	
	RET
;//----------------------------------------------------------------------------
;//       Function : BLED_OFF
;//
;//       hand off the telephone
;//----------------------------------------------------------------------------
BLED_OFF:
	LIPK	0
	SIO	8,BIOR
	CIO	0,BIOR		;back LED off---BIOR(bit0)
	
	RET
;//----------------------------------------------------------------------------
;//       Function : TWHOOK_ON
;//
;//       hand on the telephone
;//----------------------------------------------------------------------------
TWHOOK_ON:
	LIPK	0
        SIO	14,OPTR		;HOOK ON----OPTR(bit14)
	
	RET
;//----------------------------------------------------------------------------
;//       Function : TWHOOK_OFF
;//
;//       hand off the telephone
;//----------------------------------------------------------------------------
TWHOOK_OFF:
	LIPK	0
	CIO	14,OPTR		;HOOK OFF---OPTR(bit14)
	
	RET
;----------------------------------------------------------------------------
;	Function : LED2_ON
;	input : no
;	output: no
;----------------------------------------------------------------------------
LED2_ON:
	LIPK	0
	SIO	12,OPTR		;LED2 ON---OPTR(bit12)
	
	RET
;----------------------------------------------------------------------------
;	Function : LED2_OFF
;	input : no
;	output: no
;----------------------------------------------------------------------------
LED2_OFF:
	LIPK	0
	CIO	12,OPTR		;LED2 OFF---OPTR(bit12)

	RET
;----------------------------------------------------------------------------
;	Function : LED2_FLASH
;	input : no
;	output: no
;----------------------------------------------------------------------------
LED2_FLASH:
	LIPK	0
	BINV	12,OPTR		;LED2 FLASH---OPTR(bit12)

	RET
;----------------------------------------------------------------------------
;	Function : SET_LED2FG
;	
;----------------------------------------------------------------------------
SET_LED2FG:
	SRAM	EVENT,14
	RET
;----------------------------------------------------------------------------
;	Function : CLR_LED2FG
;	
;----------------------------------------------------------------------------
CLR_LED2FG:
	CRAM	EVENT,14
	RET
;----------------------------------------------------------------------------
;	Function : LED1_OFF
;	input : no
;	output: no
;----------------------------------------------------------------------------
LED1_OFF:
	lipk    0
	CIO	11,OPTR		;LED1 OFF---OPTR(bit11)

	RET
;----------------------------------------------------------------------------
;	Function : LED1_FLASH
;	input : no
;	output: no
;----------------------------------------------------------------------------
LED1_FLASH:
	lipk    0
	BINV	11,OPTR		;LED1 FLASH---OPTR(bit11)

	RET
;----------------------------------------------------------------------------
;	Function : SET_LED1FG
;	
;----------------------------------------------------------------------------
SET_LED1FG:
	SRAM	EVENT,13
	RET
;----------------------------------------------------------------------------
;	Function : CLR_LED1FG
;	
;----------------------------------------------------------------------------
CLR_LED1FG:
	CRAM	EVENT,13
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
	LAC	VOI_ATT
	ANDL	0XCFFF
	SAH	VOI_ATT
;---
	LIPK    0
        IN      SYSTMP1,BIOR
	BIT	SYSTMP1,7
	BS	TB,GET_INITLANGUAGE_END
	
	LAC	VOI_ATT
	ORL	0X1000
	SAH	VOI_ATT		;German/English
GET_INITLANGUAGE_END:
	RET
;------------------------------------------------------------------------------
InitDateTime:			;2006.1.1	00:00:00	Sunday
	
        lacl    0x01
        sah     TMR_MONTH   	;initial to jaunary,1
        lacl    0x01
        sah     TMR_DAY 
        lacl    0x06
        sah     TMR_YEAR	;initial year to 2006,link index 2 = 0xff
        
        LACK	0
        SAH	TMR_HOUR;;;;;	; set the hour time '0'
        LACK	0 
        SAH	TMR_MIN;;;;;;	; set the  minute time 0
        LACK	0 
        SAH	TMR1
        SAH	TMR_SEC;;;;;; 	; clear the second time
        
        LACK	0
	SAH	TMR_WEEK	;initial to Monday
        ret
        
;------------------------------------------------------------------------------
DateTime:
        LAC     TMR1
        SBHL    1000   		; 0X400 * 1 = 1000 MINI SECOND ; 8/29 json
        BS      SGN,DateTimeRet
INT_STMR22:	
        SAH     TMR1

        LAC     TMR_SEC 	; FOR TIMER SECOND USE
        ADHK    0X01
        SAH     TMR_SEC
        SBHK    0X03C		; 0X3C = 60 SECOND
        BS      SGN,DateTimeRet

        LACK    0X0
        SAH     TMR_SEC

        LAC     TMR_MIN 	; FOR TIMER MINUS USE
        ADHK    0X01
        SAH     TMR_MIN
        SBHK    0X03C   	; 0X3C = 60 MINUS
        BS      SGN,DateTimeRet

        LACK    0X0
        SAH     TMR_MIN

        LAC     TMR_HOUR                ; FOR TIMER HOUR USE
        ADHK    0X01
        SAH     TMR_HOUR
        SBHK    0X018               ; 0X18 = 24 HOUR
        BS      SGN,DateTimeRet       ; < 0X18
        LACK    0X0
        SAH     TMR_HOUR

        LAC     TMR_WEEK
        ADHK    0X01
        SAH     TMR_WEEK
        SBHK    0X07                 ;3/24/97; 0(1)~ 6(7) IS WEEK COUNTER
        BS      SGN,TimeDatePlus     ;for mx93111-s2
        LACK    0X0
        SAH     TMR_WEEK
;for mx93132-n2 ++++++++++++++++++++++++++++
TimeDatePlus:
        LAC     TMR_DAY
        ADHK    0X01
        SAH     TMR_DAY
        andl    0xff
        sbhk    29   		;it is 28 days in February
        BS      SGN,DateTimeRet
        bs      ACZ,CheckFebruary28
        sbhk    1   		;it is 29 days in February
        bs      ACZ,CheckFebruary29
        sbhk    1   		;it is 30 days in April,june,September,November
        bs      ACZ,CheckMonth30
        sbhk    1   		;it is 31 days in jaunary,march,may,july,auguest,Oct,Dec.
        bs      ACZ,CheckMonth31
CheckFebruary28:
        lac     TMR_YEAR	;是润年吗?
        andk    0x0003
        BS      ACZ,DateTimeRet
CheckFebruary29:
        LAC     TMR_MONTH
        sbhk    2
        BZ      ACZ,DateTimeRet
        lacl    0x03
        SAH     TMR_MONTH
        lacl    0x01
        SAH     TMR_DAY	
        BS      B1,DateTimeRet
CheckMonth30:
        LAC     TMR_MONTH
        andk    0x0f
        sbhk    4   	;april
        bs      ACZ,PlusMonth
        sbhk    2   	;june
        bs      ACZ,PlusMonth
        sbhk    3   	;September
        bs      ACZ,PlusMonth
        sbhk    2   	;November
        bs      ACZ,PlusMonth
        BS      B1,DateTimeRet
PlusMonth:
CheckMonth31:
        lac     TMR_MONTH
        adhl    0x01
        sah     TMR_MONTH
	
	lacl	0x01
        sah     TMR_DAY
        
        lac     TMR_MONTH
        sbhk    13
        bz      ACZ,DateTimeRet
        lac     TMR_YEAR
        andl    0xff00
        sah     TMR_DAY		;as a register

        lac     TMR_YEAR
        adhk    1
        andl    0x00ff
        or      TMR_DAY
        sah     TMR_YEAR

        lacl    0x01
        sah     TMR_DAY
        sah	TMR_MONTH
DateTimeRet:
        ret

;//----------------------------------------------------------------------
VOL_TAB:			;1..5

	;0	1	2	3	4	5	6	7
.DATA	0X0F0	0X0F0	0X080	0X40	0X20	0X00	0X00	0X00

;//----------------------------------------------------------------------
INT_HOSTW:
INT_HOSTR:
INT_NMI:
INT_SS:
	RET

;-----------------------------------------------------------------------
.INCLUDE main.asm
.INCLUDE f_cid.asm
.INCLUDE f_menu.asm
.INCLUDE f_pbook.asm
.INCLUDE initial.asm
.INCLUDE syspro.asm
.INCLUDE syswatch.asm
.INCLUDE gui.asm
.INCLUDE f_answer.asm
.INCLUDE f_remote.asm
.INCLUDE drive.asm
.INCLUDE f_twoway.asm
.INCLUDE tel_wr.asm
;.INCLUDE ser_com.asm
;.INCLUDE ring_det.asm
;.INCLUDE key_det.asm

.END
