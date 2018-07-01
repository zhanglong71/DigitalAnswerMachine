;//2006.01.17-------------------------------------------------------------------
;//2006.11.29-4B5E--------------------------------------------------------------
;MX93L111S2
;TMR1;用于时间更新DateTime(0--1000)
;TMR2;用于key detect
;TMR3;用于ring detect
;PRO_VAR = 
;ANN_FG :	bit0=
;		bit1=
;		bit2=	1/0-------current OGM exist/not
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
;			
;		bit10=	
;			
;		bit11=	
;
;
;		bit12=	0/1---no/new messages(current mailbox current message type)---(STATUS_CHK)
;
;		bit13=	0,not memory full---(STATUS_CHK)
;			1,memory full
;		bit14=	0,no message---(current mailbox current message type)
;			1,have message
;		bit15=
;		--------------------------
;EVENT :	bit0=	1/0------speakerphone/not	;LED FLASH
;		bit1=	1/0------record(memo/OGM)
;		bit2=	1/0------play(memo/OGM/VoicePrompt)
;		bit3=	1/0------remote/local
;		bit4=	1/0------line mode/not
;		bit5=	1/0------beep mode/not
;		bit6=	1/0------vp mode/not
;		bit7=	1/0------record mode/not
;		bit8=	1/0------answer only/ICM(flag)
;		bit9=	1/0------answer on/off
;		bit10=	
;		bit11=
;		bit12=	0/1------ring in no/ok
;		bit13=	0/1------for test model(beening pressed/realeased)
;		bit14=	
;		bit15=
;		--------------------------
;IPTR :		bit0 = 0/1/0==>1---TEST MODEL(reset)/NO TEST MODEL(reset)/CMSG_TEST
;
;BIOR :		bit(1,0)----- (10=2),(01=6),(11=2/6) 铃声
;		bit2 = 0/1--- ICM/only
;		bit3 = 
;		bit(6,5,4)--- SIO(clk,wr,dat)
;		bit7 = 
;		--------------------------
;OPTR :		bit10 --- BUSY
;		bit11 --- ACK
;		bit12 --- LED new messages
;		bit13 --- HOOK
;		bit14 --- 0/1(INDOOR MONITOR监听,正逻辑)
;//------------------------------------------------------------------------------

.NOLIST

.INCLUDE mx111S2.INC
.INCLUDE reg2523b.inc
.INCLUDE CONST.INC
.LIST

ALC_ON		.EQU   		0
MODE9		.EQU		0X9050
GCVP_TLEN	.EQU   		1000	;录满了一次做GC_CHK的最长时间(ms)
GCTEL_TLEN	.EQU   		1000	;录满了一次做GC_TEL_CHK的最长时间(ms)
CPC_TLEN	.EQU   		201	;CPC检测的有效宽度

TEXT_IVOP	.EQU   		0	;0
TEXT_EVOP	.EQU   		0	;1
TEXT_FVOP	.EQU   		1	;0

TEXT_m58	.EQU   		0	;1/0 = 有/无CID
TEXT_WR		.EQU   		1	;有效脚位起作用,通迅用
TEXT_RING_CHK	.EQU   		0	;1/0 = 有/无中断来铃检测
TEXT_KSCAN	.EQU   		0	;1===>同时将BUSY_H/L屏蔽
TEXT_SIOVP	.EQU   		0	;0===>接收命令测试
TEXT_VOP	.EQU   		0	;0/1===>没/有一般性的语音提示
TEXT_0X9051	.EQU   		0	;0===>format
TEXT_0XE900	.EQU   		0
TEXT_CLOCK	.EQU   		0	;0===>不用模拟CLOCK
TEXT_WTELNUM	.EQU   		0	;0===>不用模拟写号码
TEXT_OUTTELNUM	.EQU   		0	;0===>不用模拟读出发送号码

DAM_BIOS  	.EQU   		0X20
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
;-----------------------------------------------------------/ ??
INT_CODEC:
        ldpk    0
        bit     FLAG2531_0,0
        bz      TB,SkipSetCodec
        lac     FLAG2531_0
        andl    0xfffe			;// bit0 in FLAG2531_0 set 0
        sah     FLAG2531_0
        lipk    3
        out    CODECREG0,CDCTLR0
        out    CODECREG1,CDCTLR1
        out    CODECREG2,CDCTLR2
        LIPK	0
SkipSetCodec:
	CALL	C_SIO		;计时
	
	CALL	SIO_DET		;检测发送或接收请求
	
	CALL	C_INT1		;执行发送或接收任务
	
	CALL	CLOCK		;侦测CLK

        RET

;-------------------------------------------------------
INT_STMR:
	LDPK	0
	LIPK	0
				
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

	LAC	TMR_CTONE	;//for CONT TONE or GC_CHK(-1/ms)
	SBHK	0X01
	SAH	TMR_CTONE

	LAC	TMR3		;//for ring detection(-1/ms)
	SBHK	0X01
	SAH	TMR3
		
	LAC	TMR2		;//used to scan and LED display(+1/ms)
	ADHK	0X01
	SAH	TMR2
	
	LAC	TMR2
	SBHK	0X0C
	BS	SGN,INT_STMR2		 
	SAH	TMR2		;//reset TMR2
	call    DateTime	;//execute every 12ms
INT_STMR2:
;//------ BELOWS ARE FOR LEDS DISPLAY AND KEY SCAN ----------------------------

;-------belows are for long of beep time,end beep when TMR_BEEP=0--------- 
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
	LACL	CMSG_TMR2
	CALL	INT_STOR_MSG	
INT_T_TIMER_END:
;-------belows are for LED----------------------------------------------
INT_LED_TIMER:
	LAC	TMR_LED_BAK
	BS	ACZ,INT_LED_TIMER_END
	LAC	TMR_LED
	SBHK	1
	SAH	TMR_LED
	BZ	ACZ,INT_LED_TIMER_END
	LAC	TMR_LED_BAK
	SAH	TMR_LED
	LACL	CMSG_LED
	CALL	INT_STOR_MSG	
INT_LED_TIMER_END:
;-------belows are for cpc-det--------------------------------------------
INT_CPC_DET:
	lipk    0
        IN	INT_TTMP1,OPTR
        BIT	INT_TTMP1,13
	BZ	TB,INT_CPC_DET5
	
	LAC	TMR_CPC
	SBHL	CPC_TLEN
	BZ	SGN,INT_CPC_DET4
	
	LIPK	0
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
	LACL	CPC_TLEN
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
;-------no remote
INT_CPC_DET5:
	LACL	1100
	SAH	TMR_CPC
	BS	B1,INT_CPC_DET_END
INT_CPC_DET_END:
;-------belows are for memoful--------------------------------------------
INT_MEMFUL_DET:
	BIT	ANN_FG,13
	BZ	TB,INT_MEMFUL_DET_L
INT_MEMFUL_DET_H:
	CALL	BUSY_L			;告诉memory full
	BS	B1,INT_MEMFUL_DET_END
INT_MEMFUL_DET_L:
	CALL	BUSY_H
INT_MEMFUL_DET_END:			
;-------------------------------------------------------------------------
ACK_DET:
	LAC	EVENT			;EVENT(bit3,2,1)
	ANDL	0X0E
	BS	ACZ,ACK_DET1
	CALL	ACK_L
	BS	B1,ACK_DET_END
ACK_DET1:
	CALL	ACK_H	
ACK_DET_END:
;-------------------------------------------------------------------------
;	(IPTR.0 = 1)&(EVENT.13 = 1) 或 (IPTR.0 = 0)|(EVENT.13 = 0)表示无事件,TMR_KEY清零
;	(IPTR.0 = 0)&(EVENT.13 = 1) 持续10ms 表示有键按下,EVENT.13清0
;	(IPTR.0 = 1)&(EVENT.13 = 0) 持续10ms 表示有键松开,EVENT.13置1
;
;---要求初始值相同(IPTR.0 = 0)&(EVENT.13 = 0) 或 (IPTR.0 = 1)&(EVENT.13 = 1)
;-------------------------------------------------------------------------------
TEST_DET:
	LIPK	0
	IN	INT_TTMP1,IPTR
	BIT	INT_TTMP1,0
	BS	TB,TEST_DET_H
TEST_DET_L:
	BIT	EVENT,13
	BZ	TB,TEST_DET1	;状态保持
;---H==>L	
	LAC	TMR_KEY
	ADHK	1
	SAH	TMR_KEY		;按下时间计数
	
	SBHK	10
	BS	SGN,TEST_DET_END	;KEY PRESSED time > 10ms?

	LACL	CMSG_TESTD	;test key PRESSED
	CALL	INT_STOR_MSG
	
	CRAM	EVENT,13
	BS	B1,TEST_DET_END
;---------------------------------------
TEST_DET_H:
	BIT	EVENT,13
	BS	TB,TEST_DET1	;状态保持
;---L==>H	
	LAC	TMR_KEY
	ADHK	1
	SAH	TMR_KEY		;松开时间计数

	SBHK	10
	BS	SGN,TEST_DET_END	;KEY release time > 10ms?

	LACL	CMSG_TEST
	CALL	INT_STOR_MSG	;test key released
	
	SRAM	EVENT,13
	BS	B1,TEST_DET_END
TEST_DET1:

	LACK	0
	SAH	TMR_KEY
TEST_DET_END:
;-------------------------------------------------------------------------
	;MOD     IMODR
	RET
;//-----------------------------------------------------------------------


;----------------------------------------------------------------------------

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
;//-----------------------------------------------------------
;//===========================================
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
;//----------------------------------------------------------------------------
SET_MSGTYPE:
	LACL	0XD000
	SAH	CONF
	CALL	DAM_BIOS
	
	LACL	0XD200
	SAH	CONF
	CALL	DAM_BIOS
	
	RET
;----------------------------------------------------------------------------
;       Function : GET_TOTALMSG
;	input  : no
;	output : ACCH = the number of total messages
;----------------------------------------------------------------------------
GET_TOTALMSG:
	LACL    0X3000
        SAH     CONF
        CALL    DAM_BIOS
        LAC     RESP
        ANDL	0XFF
        SAH	MSG_T

	RET

;----------------------------------------------------------------------------
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
;----------------------------------------------------------------------------
MSG_CHK:
        PSH     CONF
;-------get the new message number,save it in MSG_N--------------------------

	CALL	SET_MSGTYPE
	
MSG_CHK1:
        SRAM	ANN_FG,12	;ANN_FG(bit12)=0/1---not have/have new message(current mbox,current type)
        
        LACL    0X3001
        SAH     CONF
        CALL    DAM_BIOS
        LAC     RESP
        SAH     MSG_N		;save the number of NEW messages
       
        BZ      ACZ,MSG_CHK1_1

	CRAM	ANN_FG,12
MSG_CHK1_1:
;-------get the total message number,save it in MSG_T---------------------
MSG_CHK2:     
	SRAM	ANN_FG,14	;ANN_FG(bit14)=1/0---have/not have message(current mbox,current type)
	
        CALL    GET_TOTALMSG	;save the number of TOTAL messages

        BZ	ACZ,MSG_CHK2_1

        CRAM	ANN_FG,14
MSG_CHK2_1:
;-------check if memory is full ?-----------------------------------------
MSG_CHK3:
        LAC     MSG_T
        SBHK    99		;check if the total message number >= 99 ?
        BZ      SGN,MSG_CHK3_1

        LACL    0X3003		;check if memory is full ?
        SAH     CONF
        CALL    DAM_BIOS

        LAC     RESP
       	SBHK	3
        BZ      SGN,MSG_CHK3_2
MSG_CHK3_1:	
  	SRAM	ANN_FG,13
	BS	B1,MSG_CHK3_3
MSG_CHK3_2:
	CRAM	ANN_FG,13
MSG_CHK3_3:
;------------------------------------------------------------------------------
MSG_CHK_RET:
;------------------------------------------------------------------------------
        POP     CONF
        RET
;------------------------------------------------------------------------------
;	FUNCTION : LED_STATUS
;------------------------------------------------------------------------------
LED_STATUS:
	CALL	CLR_LEDTIMER
	
	BIT	ANN_FG,12
	BZ	TB,LED_STATUS1
	LACL	300
	CALL	SET_LEDTIMER
	BS	B1,LED_STATUS2
LED_STATUS1:
	LACL	CNO_NMSG
	CALL	STOR_MSG
	
	
	;CALL	LED_OFF
LED_STATUS2:	
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

        LACL    0X2063            ;// 1700 Hz (1700 X 8.19)
        SAH     BUF1
        CALL    WBEEP_ACT

        LACL    0X2C30            ;// 1600 Hz (1600 X 8.19)
        SAH     BUF1
        CALL    WBEEP_ACT

        LACL    0X3CC9            ;// 1900 Hz (1900 X 8.19)
        SAH     BUF1
        CALL    WBEEP_ACT

        POP     BUF2              ;// recover BUF2
        POP     BUF1              ;// recover BUF1
        POP     CONF              ;// recover CONF

        RET
;//----------------------------------------------------------------------------
;//       Function : WBEEP_ACT
;//
;//       The general function for beep generation
;//       Input  : BUF1=the beep frequency
;//----------------------------------------------------------------------------
WBEEP_ACT:
        LACL    0X48FB            	;// beep start
        SAH     CONF
        CALL    DAM_BIOS

        LACK    0X3F                	;// delay 63 ms
        SAH     TMR_BEEP
WBEEP_ACT1:
        LAC     TMR_BEEP
        BZ      SGN,WBEEP_ACT1

        LACL    0X4400            	;// beep stop
        SAH     CONF
        CALL    DAM_BIOS

        RET

;//----------------------------------------------------------------------------
;//       Function : DAA_SPK
;//       Change analog switches for SPK/RECORD play
;//----------------------------------------------------------------------------

DAA_SPK:
        EINT
        LACL    0X0300          	;// ATT1
        SAH     CODECREG0
        
	LAC	VOI_ATT
        ANDL	0X07
        ADHL    VOL_TAB
        RPTK    0
        TBR     SYSTMP
        LAC     SYSTMP    
        ORK	0X01
        SAH     CODECREG2
        CALL    InSetCodecReg

	RET
;//----------------------------------------------------------------------------
;//       Function : DAA_LINE_SPK
;//       Change analog switches for SPK play
;//----------------------------------------------------------------------------

DAA_LINE_SPK:
        EINT
        LACL    0X008          	;// SWL
        SAH     CODECREG0
        
        LACL	0X0800
        SAH     CODECREG2
        CALL    InSetCodecReg

	RET
DAA_RECORD:
;.IF	ALC_ON
	LACL	0X4800			;ALC on
;.ELSE
        ;LACL    0X5800			;ALC off
;.ENDIF
        
        SAH     CODECREG0
        ;LACL    0XC002
	;LACL    0XA002
	LACL    0X7001
        SAH     CODECREG1
        call    InSetCodecReg

	RET

;//---------------------------------------
DAA_LIN_RECORD:
;.IF	ALC_ON	
;	LACL    0XCB08		;	ALC on
;.ELSE
        LACL    0XDB08		;LIN==>SWC(b->A)==>SWD==>AD1;DA1==>SWF==>(ATT1)SWG==>SPK DRV
;.ENDIF
        sah     CODECREG0
        ;LACL    0XEFE2
        LACL    0XEFB3
        sah     CODECREG1
        LACL	0X0182
        SAH	CODECREG2

        CALL	HOOK_ON
        call    InSetCodecReg
        
        RET
DAA_ICM_RECORD:
;.IF	ALC_ON
; 	LACL    0XCB00
;.ELSE
        LACL    0XDB00
;.ENDIF
        sah     CODECREG0
        ;LACL    0XEFE2
        LACL    0XEFB3
        sah     CODECREG1
;.IF	ALC_ON
;        LACL	0X0482
;.ELSE
        LACL	0X0482
;.ENDIF
        SAH	CODECREG2

        CALL	HOOK_ON
        call    InSetCodecReg
        
        RET
;----------------------------------------------------------------
DAA_TWAY_RECORD:
;.IF	ALC_ON
;	LACL    0XC800
;.ELSE	
	LACL    0XD800		;关SPK
;.ENDIF
        SAH     CODECREG0
        ;LACL    0XEFE2
        LACL    0XEFB3
        SAH     CODECREG1

       	LACL	0X0462
        SAH	CODECREG2
        
        CALL    InSetCodecReg
        RET

;----------------------------------------------------------------
DAA_ROM_MOR:
	LACL    0X4060			;MIC==>SWC(a->A)==>SWJ==>LIN DRV
        SAH     CODECREG0
        ;LACL    0XE0D2
        LACL    0XA002
        SAH     CODECREG1
        LACL	0X0800
        SAH	CODECREG2
        CALL    InSetCodecReg
        RET
;----------------------------------------------------------------

InSetCodecReg:
        lac     FLAG2531_0
        ork     1
        sah     FLAG2531_0
StillInSetCodec:
CheckSetCodecOk:
        bit     FLAG2531_0,0
        bs      TB,StillInSetCodec
        RET


;//----------------------------------------------------------------------------
;//       Function : DAA_OFF
;//
;//       Change analog switches for LOCAL/LINE off
;//----------------------------------------------------------------------------
DAA_OFF:
        LACL    0X0300		;SWF/SWG(A)
        sah     CODECREG0
   
        call    InSetCodecReg
        
        RET
;//----------------------------------------------------------------------------
;//       Function : HOOK_ON
;//
;//       hand on the telephone
;//----------------------------------------------------------------------------
HOOK_ON:
	lipk    0
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
;//       Function : BUSY_H
;//
;//       not memory full
;//----------------------------------------------------------------------------
BUSY_H:
.IF	TEXT_KSCAN
.ELSE
	lipk    0
	SIO	10,OPTR		;BUSY OFF---OPTR(bit10)
.ENDIF
	RET
;//----------------------------------------------------------------------------
;//       Function : BUSY_L
;//
;//       memory full
;//----------------------------------------------------------------------------
BUSY_L:
.IF	TEXT_KSCAN
.ELSE
	lipk    0
	CIO	10,OPTR		;BUSY OFF---OPTR(bit10)
.ENDIF
	RET


;//---------------------------------------------------------------------
;	Function : SET_TIMER
;	SET/CLEAR  TIMER/COUNTER
;//---------------------------------------------------------------------
SET_TIMER:
	SAH	TMR
	SAH	TMR_BAK
	RET
CLR_TIMER:
	LACK	0X00
	SAH	TMR
	SAH	TMR_BAK
	RET
;//---------------------------------------------------------------------
;	Function : SET_TIMER
;	SET/CLEAR  TIMER/COUNTER
;//---------------------------------------------------------------------
SET_LEDTIMER:
	;LACL	300
	SAH	TMR_LED
	SAH	TMR_LED_BAK
	RET
CLR_LEDTIMER:
	LACK	0X00
	SAH	TMR_LED
	SAH	TMR_LED_BAK
	RET
;//---------------------------------------------------------------------
;//	Function : INITIAL
;//
;//---------------------------------------------------------------------
INITIAL:
	
	LIPK    2
	OUTk    11,PLLMR		;// 11 → PLLMR
	OUTk    0x02,TESTR  		;// test_erdb=1

DspModeMain:
        LACK    0               	;// CLEAR ALL INTERNAL RAM TO ZERO
        LARK    0,0             	;// INTERNAL RAM FOR 93010
        LARK    1,1              	;// IS 0000 ~ 1024
        MAR     +0,0            	;// FOR 93011 IS 0000 ~ 2048
DspMAIN_CLR:
        LUPK    127,1           	;// LOOP 127 + 1 = 128 TIMES
        SAHP    +,0             	;// USE ' 0 ' TO SAVE INTERNAL RAM
        NOP
        MAR     +0,1
        MAR     -,0			;// USE AR1 TO DECREMENT
        BZ      ARZ,DspMAIN_CLR    	;// TOTAL IS 128 * 8 = 1024 TIMES
        LDPK    0
        
        call    InitDateTime
        
        EINT
	CALL	PLY_EEXE	;欺骗DSP-MCU,使之初始化时不能发命令;初始化成功后自动恢复进入待机状态
	
        LIPK    0	
        OUTL    0XA0FF,BIOR	;// set the BIOR register initial value
        OUTK    0X1B,IMR 	;// set the IMR register, INT_STMR & INT_CODEC
        ;OUTK    0X19,IMR 	;// set the IMR register, INT_STMR & INT_CODEC & INT_INT1M
;//=================================	
	
	;call    SetFlashWaitState
        LIPK	1
	OUTL	0XF9FA,WSTR	; set FLASHWAIT(WSTR11..9)=100, PROGWAIT(WSTR2..0)=010
	LIPK	0
      
        call    SetDspRunMode
       
;//-----------------------------
.IF	ALC_ON	
        LACL    0XD710
.ELSE        
        LACL    0XD734
.ENDIF	
        SAH     CONF
        CALL    DAM_BIOS        ;// set VOX level
       
        LACL    0X770B          ;// set silence threshold
        SAH     CONF
        CALL    DAM_BIOS
       
;------------------------------------------------
;	force   CODEC_INT  release
;------------------------------------------------
        LDPK    1																	;//????????????
        LAC     0X35
        ORL     0X0100
        SAH     0X35
;------------------------------------------------
	LIPK	0
	LDPK	0

	LACL	0X0000
	SAH	PASSWORD
	;sah	CLK_CN		;?????????????????????????????
	
        LACL	0X0885			;LOUT_VOL,SPK_VOL,ATT1
        SAH	VOI_ATT

        LACK	0X0006
        SAH	RING_ID
        SAH	RING_ID_BAK
				
        LACL    0XFFFF
        SAH     KEY             ;// initial KEY value=FFFF
        
        LACL	2
        SAH	VPLEN		;//the length of the shortest record
        
        ;LACL	0
        ;SAH	EVENT		;//EVENT(bit9)=0(answer on)
        ;SAH	FUNC_STACK
        ;SAH	MSG_QUEUE
        ;SAH	PRO_VAR
        

        LACK    0
	SAH	SIO_CNT
	SAH	TMR_TR
	SAH	TRS_FG

        CALL	BUSY_H
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
.if	0	;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
AF_TEST:
.IF	TEXT_0X9051	
	LACL    0X9051
.ELSE
	LACL	0X9052
.ENDIF
        SAH     CONF
        CALL    DAM_BIOS        ;// do AFLASH initialization

        BIT     RESP,8          ;// check the result of initialization ?
        BS      TB,INIT_GOOD
          
INIT_BAD:                       ;// initialization fails
        lac     RESP
        andk    0x0070
        sbhk    0x0010
        BZ      ACZ,InitError  	;// flash id ok,but init pattern error

        LACL	0X9051      
        SAH     CONF        
        CALL    DAM_BIOS        ;// do AFLASH initialization

        BIT     RESP,8          ;// check the result of initialization ?
        BS      TB,INIT_GOOD
InitError:												;// bad,display 'Ar'
        CALL    WBEEP

        BS      B1,AF_TEST
INIT_GOOD:                       ;// initialization succeed
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
.else	;!!!!!!!!!!!!!!!!!!!!!!!!
SF_TEST:
.IF	TEXT_0X9051	
	LACL    0X9051
.ELSE
	LACL	0X9052
.ENDIF
        SAH     CONF
	CALL    DAM_BIOS        ; replace by Mode9
        BIT     RESP,8          ;// check the result of initialization ?
        BS      TB,INIT_GOOD

INIT_FLASHFMT:                       ;// initialization fails
        LACL	0X9051      
        SAH     CONF        
        CALL    DAM_BIOS        ;// do AFLASH initialization

        BIT     RESP,8          ;// check the result of initialization ?
        BS      TB,INIT_GOOD
        
        LAC     RESP
        ANDK    0x0070
        SBHK    0x0010
        BZ      ACZ,INIT_FLASHFMT  	;// flash id ok,but init pattern error
InitError:
	CALL	DAA_SPK												;// bad,display 'Ar'
        CALL    WBEEP

        BS      B1,SF_TEST
INIT_GOOD:                       ;// initialization succeed
.endif	;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
;--------设置voice prompt
E_V_TEST:
	
.IF	TEXT_FVOP
	LACL	0X7604	;// set voice prompt configuration: flash voice prompt
.ENDIF
.IF	TEXT_EVOP
	LACL	0X7602	;// set voice prompt configuration: external voice prompt
.ENDIF
.IF	TEXT_IVOP
	LACL	0X7601	;// set voice prompt configuration: internal voice prompt
.ENDIF
	SAH	CONF
 	CALL	DAM_BIOS

	
.IF	TEXT_FVOP
	BIT	RESP,4		;// if flash voice prompt test ok?
.ENDIF
.IF	TEXT_EVOP
	BIT	RESP,1		;// if external	voice prompt test ok?
.ENDIF	
.IF	TEXT_IVOP
	BIT	RESP,0		;// if internal	voice prompt test ok?
.ENDIF				
        BS	TB,E_V_OK

        CALL    DAA_SPK
        CALL    WBEEP
	
	;BS	B1,E_V_TEST
E_V_OK:
	
;//----------------------------------------------------------------
        ROVM

	CALL	MSG_CHK
	
        LACL    0XD101
        ;LACL    0XD103			;// set the output level is equal to the input level
        SAH     CONF
	CALL    DAM_BIOS

	SRAM	EVENT,13	;?测试用
	LACK	10
	SAH	TMR_BEEP
INIT_TEST:				;wait interrupt check
	LAC	TMR_BEEP
	BZ	ACZ,INIT_TEST
	
	LACK	0
	SAH	MSG_QUEUE
;//-------------------------------------------------------------------
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK

	LACL	0X3CF0			;a long beep(initial)
	CALL	STOR_VP
;//-------------------------------------------------------------------	
	BIT	EVENT,13		;test model key pressed?
	;BS	TB,INITIAL_RET
	BS	B1,INITIAL_RET

	CALL	INIT_DAM_FUNC
	CALL	CLR_FUNC		;先空
    	LACL	TEST_STATE
     	CALL	PUSH_FUNC
	LACK	0
	SAH	RING_ID
	SAH	PRO_VAR
	CALL	DAA_SPK
	CALL    WBEEP
INITIAL_RET:
	
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
;------------------------------------------------------------------------
;	Funtion : transmit the address of bit=0 to messages
;	input : KEY
;	output: INT_TTMP1=INT_TTMP2=the address of key bit=0(1..12)key pressed
;			 =0 no key pressed

;------------------------------------------------------------------------
KEYTOMSG:
	LAC	KEY
	SAH	INT_TTMP2
	
	LACK	1
	SAH	INT_TTMP1
	
	BIT	INT_TTMP2,0
	BZ	TB,KEYTOMSG_END
KEYTOMSG_LOOP:
	LAC	INT_TTMP1
	SBHK	12
	BS	SGN,KEYTOMSG1
	
	LACK	0
	SAH	INT_TTMP1
	SAH	INT_TTMP2	;no key pressed
	RET
KEYTOMSG1:	
	LAC	INT_TTMP1
	ADHK	1
	SAH	INT_TTMP1

	LAC	INT_TTMP2
	SFR	1
	SAH	INT_TTMP2
	
	BIT	INT_TTMP2,0
	BS	TB,KEYTOMSG_LOOP
KEYTOMSG_END:
	LAC	INT_TTMP1
	SAH	INT_TTMP2
	
	RET
;//----------------------------------------------------------------------
VOL_TAB:

	;0	1	2	3	4	5	6	7
.DATA	0X0F0	0X0C0	0X0A0	0X80	0X60	0X40	0X20	0X00

;//----------------------------------------------------------------------
DGT_TAB:
;	     A
;	     __
;	  F |G |B
;	    |__|
;	  E |  |C
;	    |__| .	;.FAGBECD<===>OPTR(7..0)
;	     D
	;0	1	2	3	4	5	6	7
.DATA	0X90	0XF5	0XC2	0XC4	0XA5	0X8C	0X88	0XD5
	;8	9	A	B	C	D	E	F
.DATA	0X80	0X84	0X81	0XA8	0X9A	0XE0	0X8A	0X8B

INT_HOSTW:
	RET
INT_HOSTR:
	RET
INT_NMI:
	RET
INT_SS:
        RET
INT_1:
	RET
;-----------------------------------------------------------------------
.INCLUDE main.asm
.INCLUDE sys.asm
.INCLUDE gui.asm
.INCLUDE icm_sta.asm
.INCLUDE remote.asm
.INCLUDE drive.asm
.INCLUDE sed_ree.asm
.INCLUDE two_way.asm

.INCLUDE ICM_T.asm
.INCLUDE test.asm

.END
