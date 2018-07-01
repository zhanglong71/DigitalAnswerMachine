.NOLIST
.INCLUDE	include/REG_D22.inc
.INCLUDE	include/MD22U.inc
.INCLUDE	include/CONST.inc
.INCLUDE	include/EXTERN.inc
.INCLUDE	include/VERSION.inc

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
.if	EnableWatchDog
;---------------Set WatchDog	
	;OUTL	0X3C2A,WDTFSS	;!!!
	;OUTL	(0X302A|10<<8),WDTFSS	;2048ms
	;OUTL	(0X302A|11<<8),WDTFSS	;4096ms
	;OUTL	(0X302A|12<<8),WDTFSS	;8192ms
	;OUTL	(0X302A|13<<8),WDTFSS	;16384ms
	OUTL	(0X302A|14<<8),WDTFSS	;32768ms
	;OUTL	(0X302A|15<<8),WDTFSS	;65536ms
.endif
	CALL	RESET_WDT
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

	;LACL	0XFFFF
	;SAH	KEY
	;SAH	KEY_OLD
	
	LACK	1
	SAH	ANN_FG		;Set initial bit flag(ANN_FG.0)

;	LAC	ANN_FG
;	ork	(1<<1)		;Test-Disable auto answer function
;	SAH	ANN_FG

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
;---------------set denoise level 0: off - 15 max. 
	LACL	0x5F47
	CALL	DAM_BIOSFUNC
	LACk	10
	CALL	DAM_BIOSFUNC
;!!!!!!!
;---------------
.if	0
	CALL	INIT_ATT
.endif
;---------------
.if	0
	CALL	INITPBOOK
.endif
;---------------first function
.if	0
	CALL	CLR_FUNC	;ох©у
	LACK	0
	SAH	PRO_VAR
.endif
;---------------------------------------
.if	0
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	VP_ElectrifyOn
	CALL	DAA_OFF
.endif
;---------------------------------------
.if	0
	CALL	GC_CHK
	CALL	VPMSG_CHK
	CALL	SEND_MSGNUM
.endif
;---------------------------------------
.if	0
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
.endif
;---------------------------------------
.if	0	
	CALL	MSGLED_IDLE
	CALL	CLR_MSG
.endif
;---------------------------------------
.if	0
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
.endif
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
;.INCLUDE	l_wdt.asm

;.INCLUDE	l_CodecPath/l_allopen.asm
;.INCLUDE	l_CodecPath/l_lply.asm


;.INCLUDE	l_flashmsg/l_plynoise.asm
;.INCLUDE	l_flashmsg/l_biosfull.asm
;.INCLUDE	l_flashmsg/l_flashmsg.asm

;.INCLUDE	l_iic/l_storsqueue.asm
;.INCLUDE	l_iic/l_flashmsg.asm


;.INCLUDE	l_move/l_stordata.asm
;.INCLUDE	l_move/l_getdata.asm
;.INCLUDE	l_move/l_dumpiic_tel.asm
;.INCLUDE	l_move/l_ramstor.asm

;.INCLUDE	l_port/l_spkctl.asm
;.INCLUDE	l_port/l_msgled.asm

;.INCLUDE	l_table/l_voltable.asm

;.INCLUDE	l_tel/l_newtel.asm
;.INCLUDE	l_tel/l_tel_read.asm

;.INCLUDE	l_voice/l_poweron.asm
;-------------------------------------------------------------------------------
.END
