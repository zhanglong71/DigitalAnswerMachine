.NOLIST
.INCLUDE	include/REG_D22.inc
.INCLUDE	include/MD22U.inc
.INCLUDE	include/CONST.inc
.INCLUDE	include/VERSION.inc
.INCLUDE	include/EXTERN.inc

.GLOBAL	INITDSP
;-------------------------------------------------------------------------------
.EXTERN	GetOneConst
;-------------------------------------------------------------------------------
.LIST
.ORG	ADDR_SECOND
;-------------------------------------------------------------------------------
INITDSP:
	dint
	LDPK	0
	LACK	0
	LUPK    127,0 				; LOOP 127 + 1 = 128 TIMES
	SAHP    +,0             		; USE ' 0 ' TO SAVE INTERNAL RAM
;----------------------
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
	OUTL    ((1<<9)|(1<<8)|(1<<3)|(1<<2)|(1<<1)),GPAC    	;port-A[15:10,7..4]: input-pin   ;pin [9,8,3..0] as output-pin
	OUTL    ((1<<13)|(1<<9)|(1<<4)),GPBC    	;port-B[13]=1, enable IIC
					;pin [9,4]as output-pin
	OUTL    0x0FF8|(1<<1),GPAD 	;init. Port-A= 
	OUTL    (1<<9)|(1<<4),GPBD	;init. port-B= 0x0040 for LED off & un-MUTE, on-HOOK

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
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
.if	EnableWatchDog
;---------------Set WatchDog	
	;OUTL	0X3C2A,WDTFSS	;!!!page-6
	;OUTL	(0X302A|10<<8),WDTFSS	;2048ms
	;OUTL	(0X302A|11<<8),WDTFSS	;4096ms
	;OUTL	(0X302A|12<<8),WDTFSS	;8192ms
	;OUTL	(0X302A|13<<8),WDTFSS	;16384ms
	OUTL	(0X302A|14<<8),WDTFSS	;32768ms
	;OUTL	(0X302A|15<<8),WDTFSS	;65536ms
.endif
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	RESET_WDT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	NOP
InitCodec_wait:
	IN	SYSTMP0,MUTE
	LAC	SYSTMP0
	ANDL	0xe000
	XORL	0xe000
	BZ	ACZ,InitCodec_wait	;Wait for DAC ready

	OUTL	0x0b88,AGC
	;OUTL	0x7ffe,LOUTSPK
	OUTL	0x1fff,MUTE
	OUTL	0x0,SWITCH		;enable Speaker
;----------------------
	CALL	InitDateTime

	LACL	0XFFFF
	SAH	KEY
	SAH	KEY_OLD
	
	LACK	1
	SAH	ANN_FG		;Set initial bit flag(ANN_FG.0)
	SAH	MSGLED_FG
	SAH	PHOLED_FG
;---RING_CNT(15..12)/CallScreening(bit11)/CompressRate(bit10)/Language(bit9,8)/SPK_Gain(7..4)/SPK_VOL(3..0)
	LACL	CVOI_ATT
	SAH	VOI_ATT	
;---ERL_AEC(15..12)/ERL_LEC(bit11,8)/LINE _GAIN(7..4)/T/R & R/T ratio(3..0)	
	LACL	CATT_PHONE1
	SAH	ATT_PHONE1
;---Loop Attenuation(15..12)/reserved(bit11,8)/CMIC_GAIN(7..4)/SPK_VOL(3..0)
	LACL	CATT_PHONE2
	SAH	ATT_PHONE2
;---AD1PGA(15..12)/AD2PGA(bit11,8)/reserved(7..5)/LINE_DRV(4..0)
	LACL	CATT_PHONE3
	SAH	ATT_PHONE3
	
	EINT
;---------------Enable DAC-1/0
	LACL	0xD106
	CALL	DAM_BIOSFUNC
;---------------initial Flash memory
	
INIT_FLASH:
    	LACL	CMODE9|2
    	CALL    DAM_BIOSFUNC
    	BIT     RESP, 8
    	BS	TB, INIT_FLASH_GOOD             
INIT_FORMAT:
    	LACL    CMODE9|1
    	CALL    DAM_BIOSFUNC
    	BIT	RESP, 8
	BS	TB, INIT_FLASH_GOOD
    	CALL	DAA_SPK
	CALL	WBEEP
    	BS	B1,INIT_FORMAT
INIT_FLASH_GOOD:

;---------------Set VOX
	;LACL	0xD700|25	;!!!Set it before record
	;CALL	DAM_BIOSFUNC
;---------------Set silence threshold	
	;LACL	0X7700|7	;!!!Set it before record
	;CALL	DAM_BIOSFUNC
;---------------Set silence-to-voice change rate
	CALL	SET_CHSVRATE
;---------------Set voice-to-silence change rate
	CALL	SET_CHVSRATE
;---------------Set ALC gain	
	CALL	SET_ALCGAIN
;---------------Set ALC MAX.amplified level
	CALL	SET_ALCMAL
;---------------Set AGS level for SVDD
	CALL	SET_AGSVDD
;---------------Set ALC VAD level
	CALL	SET_ALCVAD
;---------------Set DTMF type    	
	LACK	1
	CALL	SET_DTMFTYPE	;0/1 = for normal/CID mode
;!!!!!!!	
	LACK	10		; set denoise level 0: off - 15 max.
	SAH	DENOISE
	CALL	SET_NOISELEV
;!!!!!!!
;---------------first function
	CALL	CLR_FUNC	;ох©у
	LACK	0
	SAH	PRO_VAR
;---------------------------------------
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	CALL	GC_CHK
	CALL	VPMSG_CHK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	2000
	SAH	TMR_DELAY
Init_MCUCOMMAND:	
	LAC	TMR_DELAY
	BS	SGN,Init_MCUCOMMAND_END
	
	CALL	GET_MSG
	BS	ACZ,Init_MCUCOMMAND
	SBHL	CMSG_SER
	BZ	ACZ,Init_MCUCOMMAND
	
	CALL	GETR_DAT
	;ANDL	0XFF
	SBHK	0X5E
	BZ	ACZ,Init_MCUCOMMAND
Init_MCUCOMMAND_END:		;Receive 0x5E, then go on
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	;CALL	SEND_MSGNUM	;
;-check memoryfull
	LACK	0X26
	CALL	SEND_DAT
	LAC	ANN_FG
	SFR	13
	ANDK	0X01
	CALL	SEND_DAT
;-new message number
	LACK	0X20
	CALL	SEND_DAT
	LAC	MSG_N
	CALL	SEND_DAT
;-total message number
	LACK	0X21
	CALL	SEND_DAT
	LAC	MSG_T
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	MSGLED_IDLE
;-!!!
	CALL	SEND_VERSION	;send version NO.first
;-!!!
	LACK	0X2F
	CALL	SEND_DAT
	LACK	0X2F
	CALL	SEND_DAT
;-!!!
	LACL	500
	CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1
;---
	
	RET

;-------------------------------------------------------------------------------
;       InitDateTime : initial RTC register
;	
;-------------------------------------------------------------------------------
InitDateTime:       ;test ok
	lipk    9

	outl    0x0000, RTCMS	; min=00, sec=00
	outl    0x0100, RTCWH	; week=1, hour=00
	outl    0x0101, RTCMD	; month=01, day=01
	outl    0x0707, RTCCY	; control, year=07
	OUTL    0x0307, RTCCY	; 
	
        RET

;-------------------------------------------------------------------------------
;	Function : SET_CHSVRATE
;	Set silence-to-voice change rate
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
SET_CHSVRATE:
	LACL	0X5F43
	CALL	DAM_BIOSFUNC
	LACK	9
	;LACK	5	;Default = 5
	CALL	DAM_BIOSFUNC
;---
	RET
;-------------------------------------------------------------------------------
;	Function : SET_CHVSRATE
;	Set voice-to-silence change rate
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
SET_CHVSRATE:
	LACL	0X5F42
	CALL	DAM_BIOSFUNC
	LACK	9
	;LACK	5	;Default = 5
	CALL	DAM_BIOSFUNC
;---
	RET
;-------------------------------------------------------------------------------
;	Function : SET_ALCGAIN
;	Set S/W ALC On/Off during Recording
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
SET_ALCGAIN:
	LACL	0X5F40
	CALL	DAM_BIOSFUNC
	LACK	32
	;LACK	35	;Default value
	CALL	DAM_BIOSFUNC
;---
	RET
;-------------------------------------------------------------------------------
;	Function : SET_ALCMAL
;	Set S/W ALC max. amplified level
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
SET_ALCMAL:
	LACL	0X5F41
	CALL	DAM_BIOSFUNC
	LACL	17000
	;LACL	26000	;Default value
	CALL	DAM_BIOSFUNC
;---
	RET
;-------------------------------------------------------------------------------
;	Function : SET_ALCVAD
;	input : no
;	output: ACCH
;-------------------------------------------------------------------------------
SET_ALCVAD:
	LACL	0x5F44		;set ALC VAD level
	CALL	DAM_BIOSFUNC
	LACL	750
	;LACL	2400		;Default = 2400
	CALL	DAM_BIOSFUNC

	RET

;-------------------------------------------------------------------------------
;	Function : SET_DTMFTYPE
;	input : ACCH(0..F)
;	output: ACCH
;-------------------------------------------------------------------------------
SET_DTMFTYPE:
	PSH	CONF
;-------
	SAH	SYSTMP0
;---	
	LACL	0x5F46		;set DTMFTYPE
	CALL	DAM_BIOSFUNC
	LAC	SYSTMP0		; --dB
	CALL	DAM_BIOSFUNC
;------
	POP	CONF
	
	RET
;-------------------------------------------------------------------------------
;	Function : SET_AGSVDD
;	input : no
;	output: ACCH
;-------------------------------------------------------------------------------
SET_AGSVDD:
	PSH	CONF
;-------
	LACL	0x5F13		;set AGS level for SVDD
	CALL	DAM_BIOSFUNC
	LACK	0X00		;SVDD = 1.00*AVDD
	;LACK	0X01		;SVDD = 0.80*AVDD
	;LACK	0X02		;SVDD = 1.20*AVDD
	;LACK	0X03		;SVDD = 1.33*AVDD
	CALL	DAM_BIOSFUNC
;------
	POP	CONF
	
	RET

;-------------------------------------------------------------------------------
;	Function : WBEEP
;	
;	Generate a warning beep
;-------------------------------------------------------------------------------
WBEEP:
;---1700 Hz (1700 X 8.19)
	LACL	CBEEP_COMMAND
	CALL    DAM_BIOSFUNC
	LACL	0X3663
	CALL    DAM_BIOSFUNC
	LACK	0
	CALL    DAM_BIOSFUNC
	LACK	63
	CALL	DELAY
	LACL	CBEEP_STOP
	CALL    DAM_BIOSFUNC	;beep stop
;---1600 Hz (1600 X 8.19)	
	LACL	CBEEP_COMMAND
	CALL    DAM_BIOSFUNC
	LACL	0X3330
	CALL    DAM_BIOSFUNC
	LACK	0
	CALL    DAM_BIOSFUNC
	
	LACK	63
	CALL	DELAY
	LACL	CBEEP_STOP
	CALL    DAM_BIOSFUNC	;beep stop
;---1900 Hz (1900 X 8.19)	
	LACL	CBEEP_COMMAND
	CALL    DAM_BIOSFUNC
	LACL	0X3CC9
	CALL    DAM_BIOSFUNC
	LACK	0
	CALL    DAM_BIOSFUNC
	
	LACK	63
	CALL	DELAY
	LACL	CBEEP_STOP
	CALL    DAM_BIOSFUNC	;beep stop

        RET

;-------------------------------------------------------------------------------
;       Function : SEND_VERSION
;
;       Input  : no
;       Output : no
;-------------------------------------------------------------------------------
SEND_VERSION:
	LACK	0X30
	CALL	SEND_DAT
	LACL	CVersion
	CALL	SEND_DAT
	
	RET
;-------------------------------------------------------------------------------


.INCLUDE	l_CodecPath/l_allopen.asm
.INCLUDE	l_CodecPath/l_lply.asm

.INCLUDE	l_flashmsg/l_plynoise.asm
.INCLUDE	l_flashmsg/l_biosfull.asm
.INCLUDE	l_flashmsg/l_flashmsg.asm

.INCLUDE	l_iic/l_storsqueue.asm
.INCLUDE	l_iic/l_getrqueue.asm
;.INCLUDE	l_iic/l_flashmsg.asm

.INCLUDE	l_port/l_spkctl.asm
.INCLUDE	l_port/l_msgled.asm

.INCLUDE	l_table/l_voltable.asm
;-------------------------------------------------------------------------------
.END
