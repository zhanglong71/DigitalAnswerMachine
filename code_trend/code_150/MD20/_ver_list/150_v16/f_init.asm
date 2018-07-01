.NOLIST
.INCLUDE MD20U.INC
.INCLUDE REG_D20.inc
.INCLUDE CONST.INC
.INCLUDE EXTERN.inc
;-------------------------------------------------------------------------------
.EXTERN	SetFlashStartAddress
.EXTERN	LoadHostCode
.EXTERN	GetOneConst	;(INPUT=ACCH(ProgramRamAddress),OUTPUT=ACCH(ReadData))
.EXTERN	GetMoreConst	;(INPUT=ACCH(ProgramRamStartingAddress)ACCL(ReadWordNumber)AR1(StoreDataRamAddress),OUTPUT=)
;-------------------------------------------------------------------------------
.GLOBAL	INITIAL
.GLOBAL	INITMCU
;-------------------------------------------------------------------------------
.LIST
.ORG    ADDR_SECOND
;-------------------------------------------------------------------------------
;	Function : INITIAL
;	上电初始化
;-------------------------------------------------------------------------------
INITIAL:
	dint
	LDPK	0
	MAR	+0,1
	LARK	0,1
	LACK	0
	LUPK	127,0 			; LOOP 127 + 1 = 128 TIMES
	SAH	+,1             	; USE ' 0 ' TO SAVE INTERNAL RAM
;---------------
	LIPK	7
	IN	SYSTMP0,DSPINTEN	;Iic interrupt mask control = Enable
	LAC	SYSTMP0			;I/O interrupt mask control = Disable
	ANDL	0XFFDF		;Reset bit5
	ORL	0X0010		;Set bit4
	SAH	SYSTMP0
	OUT	SYSTMP0,DSPINTEN
	ADHK	0
;----------------------
	LIPK    8                  	;initial I/O setting
	OUTL    0x0E00,GPAC    		;pin [11,10,9] as output-pin(to key)
;---GPBD.13=1,enable IIC;GPBD.4-2way;
	OUTL    ((1<<13)|(1<<9)|(1<<7)|(1<<6)|(1<<5)|(1<<4)|(1<<3)),GPBC 

	OUTL    0x0FFF,GPAD 		;init. Port-A= 0x0FFF for key & LED
	OUTL    ((1<<9)|(1<<7)|(1<<3)),GPBD		;init. port-B= 0x0040 for LED off & un-MUTE, on-HOOK

	OUTK    0X00,GPBIEN		;
;----------------------
	LIPK    9
	OUTK    0x00,GPBITP		;define io-interrupt as "falling-edge trigger"
;!!!!!!!!!!!!!!!!!!!!!
;-----				;-----
	lipk	5
	outl	0x0003,IICPW		;Enable power first
	outl	0x6200,IICCR		;(bit14=Enable iic control)&(bit13=Reset iic)&(Enable iic interrupt)Default is Slave mode
	NOP
	NOP
	outl	0xFFFF,IICSR		;Reset status register
	outl	0x8000+(0X82>>1),IICAR	;(bit15,14=7-bit-Slave address assigned)&(Slave address) = 0x41
	outl	0x0021,IICTR		;IIC SCLK=409KHz
;-----				;-----
;!!!!!!!!!!!!!!!!!!!!!
	LIPK	6
	OUTK	0x0000,ANAPWR
	NOP
InitCodec_wait:
	IN	SYSTMP0,MUTE
	LAC	SYSTMP0
	ANDL	0xe000
	XORL	0xe000
	BZ	ACZ,InitCodec_wait	;Wait for DAC ready
	OUTL	0x1fff,MUTE

;----------------------
        call    InitDateTime	;set date/time before initweek
        EINT
 ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X5124		;NewMsgBeepPrompt(15) = 0/BeepVoicePrompt(14) = 1/LANGUAGE(13,12)/OGM_ID(11..8)/RING_CNT(7..4)/ATT1(3..0)
        SAH	VOI_ATT
   
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
	LAC	ANN_FG
	ORK	1
	SAH	ANN_FG		;Initialing
;------------Enable DAC-1/0
	LACL	0xD106
	CALL	DAM_BIOSFUNC
;------------set VOX level
	LACL    0XD700|25
	CALL    DAM_BIOSFUNC
;------------Set silence threshold
	LACK	0X07		;set silence threshold
	CALL	SET_SILENCE


        LACL    0XFFFF
        SAH     KEY             ;// initial KEY value=FFFF

	LACL	1000	;delay 1s(wait for MCU initial)
	CALL	DELAY

	CALL	SENDLANGUAGE	;(2bytes)语言选择(Default = German)Make Sure it is the first command to MCU after Power-on
	LACL	0X0FF
	CALL	SEND_DAT	;(1byte) 

	LACL	100	;delay 1s(wait for MCU initial)
	CALL	DELAY
INIT_FLASH:
	BIT	KEY,6
	BS	TB,INIT_FLASHNORAML	;on/off KEY
	BIT	KEY,7
	BS	TB,INIT_FLASHNORAML	;Del KEY
;---上电时同时按住Del和On/Off键格式化Flash
	BS	B1,INIT_FORMAT
INIT_FLASHNORAML:	
    	LACL	CMODE9|2
    	CALL    DAM_BIOSFUNC
    	BIT     RESP,8
    	BS	TB, INIT_FLASH_GOOD             
INIT_FORMAT:
    	LACL    CMODE9|1
    	CALL    DAM_BIOSFUNC
    	BIT	RESP,8
	BS	TB, INIT_FLASH_GOOD
	CALL	DAA_SPK
	CALL	WBEEP
    	BS	B1,INIT_FORMAT	;Error
INIT_FLASH_GOOD:		;initialization succeed
	CALL	SET_DECLTEL
INIT_FLASH_END:
;-------------------------------------------------------------------------------
	CALL	REAL_DEL
	CALL	TEL_GC_CHK
	CALL	GC_CHK
	
	ROVM
	CALL	INITFDATETIME	;set week
	LACK	3
	SAH	MBOX_ID
	CALL	VPMSG_CHK
        CALL	NEWICM_CHK
        
	LACK	2
	SAH	MBOX_ID
	CALL	VPMSG_CHK
        CALL	NEWICM_CHK
        
	LACK	1
	SAH	MBOX_ID
	CALL	VPMSG_CHK
	CALL	NEWICM_CHK
	
	LACL	1000	;delay 0.5s(wait for MCU initial)
	CALL	DELAY
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	VPMSG_CHK
	LACL	0X83		;录音数量同步(3bytes)
	CALL	SEND_DAT
	LAC	MSG_N
	CALL	SEND_DAT
	LAC	MSG_T
	CALL	SEND_DAT
	
	LACL	0XFF
	CALL	SEND_DAT
	
	LACL	0X82		;新旧来电同步(3bytes)
	CALL	SEND_DAT
	LACK	0	;???????????????
	CALL	SEND_DAT
	LACK	0
	CALL	SET_TELGROUP
	CALL	GET_TELT	;来电总数同步
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;-------	
	LACL	0XFF
	CALL	SEND_DAT
;-------
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	SENDTIME
	LACL	0XFF
	CALL	SEND_DAT
	
	
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9E		;
	CALL	SEND_DAT
	LACK	6
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
;---initial complete-----------------------------------------------------------
	CALL	DAA_SPK
	CALL	INITBEEP

	LAC	ANN_FG
	ANDL	~(1)
	SAH	ANN_FG		;initial end

	CALL	BLED_OFF
;---initial over----------------------------------------------------------------

INITIAL_RET:
	
	RET

;-------------------------------------------------------------------------------
;	Function : WBEEP
;	
;	Generate a warning beep
;-------------------------------------------------------------------------------
WBEEP:
	CALL	BEEP_START      ;// 1700 Hz (1700 X 8.19)
	LACL	0X3663
	CALL    DAM_BIOSFUNC
	LACK	0
	CALL    DAM_BIOSFUNC
	LACK	63
	CALL	DELAY
	CALL    BEEP_STOP
	
	CALL	BEEP_START      ;// 1600 Hz (1600 X 8.19)
	LACL	0X3330
	CALL    DAM_BIOSFUNC
	LACK	0
	CALL    DAM_BIOSFUNC
	LACK	63
	CALL	DELAY
	CALL    BEEP_STOP

        CALL	BEEP_START      ;// 1900 Hz (1900 X 8.19)
	LACL	0X3CC9
	CALL    DAM_BIOSFUNC
	LACK	0
	CALL    DAM_BIOSFUNC
	LACK	63
	CALL	DELAY
	CALL    BEEP_STOP

        RET
;-------------------------------------------------------------------------------
;       InitDateTime : initial RTC register
;	
;-------------------------------------------------------------------------------
InitDateTime:       ;2009-1-1 星期日
	lipk    9

	outl    0x0000, RTCMS	; min=00, sec=00
	outl    0x0000, RTCWH	; week=0, hour=00
	outl    0x0101, RTCMD	; month=01, day=01
	outl    0x0709, RTCCY	; control, year=07
	OUTL    0x0309, RTCCY	; 
        RET
;-------------------------------------------------------------------------------
.INCLUDE l_init.asm
.INCLUDE l_sendtime.asm
;-------------------------------------------------------------------------------
.END
