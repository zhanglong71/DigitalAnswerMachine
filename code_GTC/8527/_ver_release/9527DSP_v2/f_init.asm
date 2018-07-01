.NOLIST
.INCLUDE	include/REG_D22.inc
.INCLUDE	include/MD22U.inc
.INCLUDE	include/CONST.inc
.INCLUDE	include/EXTERN.inc

.GLOBAL	INITDSP
;-------------------------------------------------------------------------------
.EXTERN	GetOneConst	;(INPUT=ACCH(ProgramRamAddress),OUTPUT=ACCH(ReadData))
.EXTERN	GetMoreConst	;(INPUT=ACCH(ProgramRamStartingAddress)ACCL(ReadWordNumber)AR1(StoreDataRamAddress),OUTPUT=)
;---
;-------------------------------------------------------------------------------
.LIST
.ORG	ADDR_SECOND
;-------------------------------------------------------------------------------
INITDSP:
	dint	; disable Interrupt

	LDPK	0
;----- clear data ram address 0 ~ 127 --------
	LARK	0,AR0
	MAR	+0,AR0 
	LACK	 0
	LUPK    127,0 				; LOOP 127 + 1 = 128 TIMES
	SAH     +,0             		; USE ' 0 ' TO SAVE INTERNAL RAM(0..127)
	LUPK    127,0 				; LOOP 127 + 1 = 128 TIMES
	SAH     +,0             		; USE ' 0 ' TO SAVE INTERNAL RAM(128..255)
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
	OUTL    0x0FF8,GPAD 	;init. Port-A= 
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
.if	DebugWatchDog
;---------------Set WatchDog	
	;OUTL	0X3C2A,WDTFSS	;!!!
	;OUTL	(0X302A|10<<8),WDTFSS	;2048ms
	;OUTL	(0X302A|11<<8),WDTFSS	;4096ms
	;OUTL	(0X302A|12<<8),WDTFSS	;8192ms
	;OUTL	(0X302A|13<<8),WDTFSS	;16384ms
	OUTL	(0X302A|14<<8),WDTFSS	;32768ms
	;OUTL	(0X302A|15<<8),WDTFSS	;65536ms
	CALL	RESET_WDT
.endif
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	NOP
InitCodec_wait:
	IN	SYSTMP0,MUTE
	LAC	SYSTMP0
	ANDL	0xe000
	XORL	0xe000
	BZ	ACZ,InitCodec_wait	;Wait for DAC ready

	;OUTL	0x0b88,AGC
	;OUTL	0x7ffe,LOUTSPK
	OUTL	0x1fff,MUTE
	;OUTL	0x80,SWITCH		;enable Speaker
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
	;bs	b1,INIT_FORMAT
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

    	BS	B1,INIT_FORMAT
INIT_FLASH_GOOD:
;---------------
SET_DECLTEL:
	LACL	0X5FA0
	CALL	DAM_BIOSFUNC
	ANDL	0XFF00
	BZ	ACZ,SET_DECLTEL_END	;error,exit
	LACK	CTEL_MNUM
	CALL	DAM_BIOSFUNC
SET_DECLTEL_END:
;---------------Set VOX
	;LACL	0xD700|25	;!!!Set it before record
	;CALL	DAM_BIOSFUNC
;---------------Set silence threshold	
	;LACL	0X7700|7	;!!!Set it before record
	;CALL	DAM_BIOSFUNC
;---------------Set silence-to-voice change rate
	LACL	0X5F43
	CALL	DAM_BIOSFUNC
	LACK	9
	CALL	DAM_BIOSFUNC
;---------------Set voice-to-silence change rate
	LACL	0X5F42
	CALL	DAM_BIOSFUNC
	LACK	9
	CALL	DAM_BIOSFUNC
;---------------Set ALC gain	
	LACL	0X5F40
	CALL	DAM_BIOSFUNC
	LACK	32
	CALL	DAM_BIOSFUNC
;---------------Set ALC MAX.amplified level
	LACL	0X5F41
	CALL	DAM_BIOSFUNC
	LACL	17000
	CALL	DAM_BIOSFUNC
;---------------Set AGS level for SVDD
	LACL	0x5F13		;set AGS level for SVDD
	CALL	DAM_BIOSFUNC
	LACK	0X00		;SVDD = 1.00*AVDD
	;LACK	0X01		;SVDD = 0.80*AVDD
	;LACK	0X02		;SVDD = 1.20*AVDD
	;LACK	0X03		;SVDD = 1.33*AVDD
	CALL	DAM_BIOSFUNC
;---------------Set ALC VAD level
	LACL	0x5F44		;set ALC VAD level
	CALL	DAM_BIOSFUNC
	LACL	750
	CALL	DAM_BIOSFUNC
;---------------Set DTMF type    	
	LACL	0x5F46		;set DTMFTYPE
	CALL	DAM_BIOSFUNC
	LACK	1
	CALL	DAM_BIOSFUNC	;0/1 = for normal/CID mode
;!!!!!!!	
	LACK	10		; set denoise level 0: off - 15 max.
	SAH	DENOISE
	CALL	SET_NOISELEV
;!!!!!!!
;---------------
	CALL	INIT_ATT
;---------------
	CALL	INITPBOOK
;---------------first function
	CALL	CLR_FUNC	;先空
	LACK	0
	SAH	PRO_VAR
;---------------------------------------
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	VP_ElectrifyOn
	CALL	DAA_OFF
;---------------------------------------
	CALL	GC_CHK
	CALL	VPMSG_CHK
	CALL	SEND_MSGNUM
;---------------------------------------
;---verify CID number
	LACL	0XE600|CGROUP_CID		;set working group
	CALL	DAM_BIOSFUNC
	LACL	0XE401
	CALL	DAM_BIOSFUNC
	SAH	MSG_T
	CALL	GET_TELN
	SAH	MSG_N
;!!!!!!!!!!!!!!!!!!!
	LACL	0X85
	CALL	SEND_DAT
	LACK	0X0
	CALL	SEND_DAT
	LAC	MSG_T
	CALL	SEND_DAT
	LACL	0X85
	CALL	SEND_DAT
	LACK	0X1
	CALL	SEND_DAT
	LAC	MSG_N
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!	
;---------------------------------------	
	CALL	MSGLED_IDLE
	call	CLR_MSG
;---------------------------------------
;!!!!!!!!!	;send version NO.first
	LACK	0X30
	CALL	SEND_DAT
	LACL	CVersion
	CALL	SEND_DAT
;!!!!!!!!!
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
;	Function : INITBEEP
;	
;	Generate a init beep
;-------------------------------------------------------------------------------
INITBEEP:
	LACL	CBEEP_COMMAND
	CALL    DAM_BIOSFUNC
	
	LACL	0X2000
	CALL    DAM_BIOSFUNC
	LACK	0
	CALL    DAM_BIOSFUNC
	
	LACL	500
	CALL	DELAY

	LACL	CBEEP_STOP
	CALL    DAM_BIOSFUNC

	RET
;-------------------------------------------------------------------------------
INIT_ATT:
	LACK	ADDR_BUF
	SAH	ADDR_D
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	SAH	OFFSET_D

	LACL	0XE600|CGROUP_DATT	;set working group
	CALL	DAM_BIOSFUNC
	LACL	0XE401
	CALL	DAM_BIOSFUNC
	SAH	MSG_T
	BZ	ACZ,INIT_ATT_READ
;---Write first PowerOn data	
	LACL	0xE000|DVOL
	CALL	DAM_BIOSFUNC			;M1
	LACL	0xE000|(D1PSWD<<4)|(D2PSWD)
	CALL	DAM_BIOSFUNC			;M2
	LACL	0xE000|(D3PSWD<<4)|0xF
	CALL	DAM_BIOSFUNC			;M3
	LACL	0xE000|DM1ATT
	CALL	DAM_BIOSFUNC			;M4
	LACL	0xE000|DM2ATT
	CALL	DAM_BIOSFUNC			;M5
	LACL	0xE000|(DLANG<<4)|DCONTRAST
	CALL	DAM_BIOSFUNC			;M6
	LACL	0xE000|DAREAC12
	CALL	DAM_BIOSFUNC			;M7
	LACL	0xE000|DAREAC34
	CALL	DAM_BIOSFUNC			;M8
	
	LACL	0xE100
	CALL	DAM_BIOSFUNC
	
	LACK	1
	SAH	MSG_T
INIT_ATT_READ:
	LAC	MSG_T
	CALL	TELNUM_READ
	LACL	0XE300		;Stop read
	CALL	DAM_BIOSFUNC
;---------
	LAC	VOI_ATT
	ANDL	0X00F0
	SAH	VOI_ATT		;RING_CNT(15..12)/CallScreening(bit11)/CompressRate(bit10)/Language(bit9,8)/SPK_Gain(7..4)/SPK_VOL(3..0)

	CALL	GETBYTE_DAT	;byte1 - vol
	ANDK	0X0F
	OR	VOI_ATT
	SAH	VOI_ATT
;-	
	CALL	GETBYTE_DAT	;byte2 - ps1,2
	SFL	4
	ANDL	0X0FF0
	SAH	PASSWORD
;-
	CALL	GETBYTE_DAT	;byte3 - ps3
	SFR	4
	ANDK	0X0F
	OR	PASSWORD
	SAH	PASSWORD		
;-
	CALL	GETBYTE_DAT	;byte4 - ringcnt
	SFL	12
	ANDL	0XF000		;bit(3..0) -> bit(15..12)
	OR	VOI_ATT
	SAH	VOI_ATT
;-
	CALL	GETBYTE_DAT	;byte5 - CompressRate/on-off/MessageLength
	SAH	SYSTMP0
	
	BIT	SYSTMP0,7
	BZ	TB,INIT_ATT_READ_0X80_60COMPS

	LAC	VOI_ATT
	ORL	1<<10
	SAH	VOI_ATT
INIT_ATT_READ_0X80_60COMPS:
	BIT	SYSTMP0,6
	BS	TB,INIT_ATT_READ_0X80_ONOFF

	LAC	EVENT
	ORL	1<<9
	SAH	EVENT
INIT_ATT_READ_0X80_ONOFF:
;-
	CALL	GETBYTE_DAT	;byte6 - Language/LCD Contrast
	SFL	4
	ANDL	0X0300
	OR	VOI_ATT
	SAH	VOI_ATT
;-
	;CALL	GETBYTE_DAT	;byte7
	;CALL	GETBYTE_DAT	;byte8
;-----------------------------
	LACL	0X80
	CALL	SEND_DAT

	LACK	8
	SAH	COUNT
	LACK	0
	SAH	OFFSET_S
	CALL	DUMPIIC_DAT

	LACK	5
	CALL	DELAY

	RET
;-------------------------------------------------------------------------------
INITPBOOK:
	LACK	13
	SAH	MSG_T
INITPBOOK_LOOP:
	LAC	MSG_T
	SBHK	1
	SAH	MSG_T
	BS	SGN,INITPBOOK_END
	
	LACK	ADDR_BUF
	SAH	ADDR_D
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	SAH	OFFSET_D
	
	LAC	MSG_T
	ORL	0XE600|0X10
	CALL	DAM_BIOSFUNC
	LACL	0XE401
	CALL	DAM_BIOSFUNC
	BS	ACZ,INITPBOOK_NODATA	;没有数据,不必读也不必发送
	CALL	TELNUM_READ
	LACL	0XE300		;Stop read
	CALL	DAM_BIOSFUNC
;---
INITPBOOK_SEND:
	LACL	0X81
	CALL	SEND_DAT
	LAC	MSG_T
	CALL	SEND_DAT
	LACK	28
	SAH	COUNT
	CALL	DUMPIIC_DAT
	
	LACK	50
	CALL	DELAY
	BS	B1,INITPBOOK_LOOP
INITPBOOK_NODATA:	;set default data(Note: the offset_d increase)
	LACK	16
	SAH	COUNT
	LACL	0XFF		;Default num
	CALL	RAM_STOR
	LACK	12
	SAH	COUNT
	LACK	0X20		;Default name
	CALL	RAM_STOR
	BS	B1,INITPBOOK_SEND
INITPBOOK_END:	
	RET
;-------------------------------------------------------------------------------
.INCLUDE	l_wdt.asm

.INCLUDE	l_CodecPath/l_allopen.asm
.INCLUDE	l_CodecPath/l_lply.asm


.INCLUDE	l_flashmsg/l_plynoise.asm
.INCLUDE	l_flashmsg/l_biosfull.asm
.INCLUDE	l_flashmsg/l_flashmsg.asm

.INCLUDE	l_iic/l_storsqueue.asm
.INCLUDE	l_iic/l_flashmsg.asm


.INCLUDE	l_move/l_stordata.asm
.INCLUDE	l_move/l_getdata.asm
.INCLUDE	l_move/l_dumpiic_tel.asm
.INCLUDE	l_move/l_ramstor.asm

.INCLUDE	l_port/l_spkctl.asm
.INCLUDE	l_port/l_msgled.asm

.INCLUDE	l_table/l_voltable.asm

.INCLUDE	l_tel/l_newtel.asm
.INCLUDE	l_tel/l_tel_read.asm

.INCLUDE	l_voice/l_poweron.asm
;-------------------------------------------------------------------------------
.END
