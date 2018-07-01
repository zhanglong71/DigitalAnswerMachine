.NOLIST
;---------------------------------------
.INCLUDE	include.inc
;---------------------------------------
.GLOBAL	INITDSP
.GLOBAL	INITMCU
;-------------------------------------------------------------------------------
.EXTERN	GetOneConst	;(INPUT=ACCH(ProgramRamAddress),OUTPUT=ACCH(ReadData))
.EXTERN	GetMoreConst	;(INPUT=ACCH(ProgramRamStartingAddress)ACCL(ReadWordNumber)AR1(StoreDataRamAddress),OUTPUT=)
;---
;-------------------------------------------------------------------------------
.LIST
.ORG	ADDR_SECOND
;-------------------------------------------------------------------------------
INITDSP:
	DINT

	LDPK	0
	MAR	+0,1
	LARK	0,1
	LACK	0
	LUPK    127,0			; LOOP 127 + 1 = 128 TIMES
	SAH	+,1			; USE ' 0 ' TO SAVE INTERNAL RAM
;----------------------
	LIPK	7
	outl	0x0012,DSPINTEN             ;0x12-->DSPINTEN (has to set this value)
;----------------------
	LIPK    8                  	;initial I/O setting
	OUTL    ((1<<CbPHOLED)|(1<<CbMSGLED)|(1<<CbHOOK)|(1<<CbMUTE_RING)|(1<<CbSPK)),GPAC    	;port-A[15:10,7..4]: input-pin   ;pin [9,8,3..0] as output-pin
	OUTL    ((1<<13)|(1<<CbIICREQ)|(1<<CbALC)|(1<<CbBLIGHT)),GPBC    	;port-B[13]=1, enable IIC
					;pin [9,4]as output-pin
	OUTL    0x0CF0,GPAD 		;init. Port-A= 
	OUTL    (1<<CbIICREQ)|(1<<4),GPBD	;init. port-B= 0x0040 for LED off & un-MUTE, on-HOOK

	;OUTK    0X00,GPBIEN
;----------------------
	;LIPK    9
	;OUTK    0x00,GPBITP		;define io-interrupt as "falling-edge trigger"
;!!!!!!!!!!!!!!!!!!!!!
;-----				;-----
	lipk	5
	outl	0x0003,IICPW		;Enable power first
	outl	0x6200,IICCR		;(bit14=Enable iic control)&(bit13=Reset iic)&(Enable iic interrupt)Default is Slave mode
	NOP
	outl	0xFFFF,IICSR		;Reset status register
	outl	0x8000+(0X82>>1),IICAR	;(bit15,14=7-bit-Slave address assigned)&(Slave address) = 0x41
	outl	0x0021,IICTR		;IIC SCLK=409KHz
;-----				;-----
;!!!!!!!!!!!!!!!!!!!!!
	LIPK	6
	OUTK	0x0,ANAPWR
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
InitCodec_wait:
	IN	SYSTMP0,MUTE
	LAC	SYSTMP0
	ANDL	0xe000
	XORL	0xe000
	BZ	ACZ,InitCodec_wait	;Wait for DAC ready
	OUTL	0x1fff,MUTE
	
	;OUTL	0x0b88,AGC
	;OUTL	0x7ffe,LOUTSPK
	;OUTL	0x80,SWITCH		;enable Speaker
;----------------------
	CALL	InitDateTime

	LACK	1
	SAH	ANN_FG		;Set initial bit flag(ANN_FG.0)
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
	
	LACL	1000
	CALL	DELAY
;---------------Enable DAC-1/0
	LACL	0xD106
	CALL	DAM_BIOSFUNC
;---------------initial Flash memory
	;bs	b1,INIT_FORMAT
INIT_FLASH:
    	LACL	CMODE9|2
    	CALL    DAM_BIOSFUNC
    	BIT     RESPONSE,8
    	BS	TB, INIT_FLASH_GOOD
INIT_FORMAT:
    	LACL    CMODE9|1
    	CALL    DAM_BIOSFUNC
    	BIT	RESPONSE,8
	BS	TB, INIT_FLASH_GOOD

    	BS	B1,INIT_FORMAT
INIT_FLASH_GOOD:
;---------------
	LACL	0X6100
	CALL	DAM_BIOSFUNC
	CALL	TEL_GC_CHK
;---------------Set VOX
	;LACL	0xD700|25	;!!!Set it before record
	;CALL	DAM_BIOSFUNC
;---------------Set silence threshold	
	;LACL	0X7700|7	;!!!Set it before record
	;CALL	DAM_BIOSFUNC
;---------------Set silence-to-voice change rate
	LACL	0X5F43
	CALL	DAM_BIOSFUNC
	LACK	5
	CALL	DAM_BIOSFUNC
;---------------Set ALC gain	
	LACL	0X5F40
	CALL	DAM_BIOSFUNC
	LACK	4
	CALL	DAM_BIOSFUNC
;---------------Set ALC MAX.amplified level
	LACL	0X5F41
	CALL	DAM_BIOSFUNC
	LACL	26000
	CALL	DAM_BIOSFUNC
;---------------Set AGS level for SVDD
	LACL	0x5F13		;set AGS level for SVDD
	CALL	DAM_BIOSFUNC
	LACK	0X00		;SVDD = 1.00*AVDD
	;LACK	0X01		;SVDD = 0.80*AVDD
	;LACK	0X02		;SVDD = 1.20*AVDD
	;LACK	0X03		;SVDD = 1.33*AVDD
	CALL	DAM_BIOSFUNC
;---------------Set DTMF type    	
	LACL	0x5F46		;set Acceptable DTMF duration
	CALL	DAM_BIOSFUNC
	LACK	6
	CALL	DAM_BIOSFUNC
;---------------set denoise level 0: off - 15 max. 
	LACL	0x5F47
	CALL	DAM_BIOSFUNC
	LACK	0
	CALL	DAM_BIOSFUNC
	
;-------------------------------------------------------------------------------
INITMCU:
;---Pbook
	LACK	CGROUP_PBOOK		;set working group
	CALL	SET_TELGROUP
	CALL	GET_TELT
	CALL	SEND_PBOOK
;---verify CID number
	LACK	CGROUP_CID		;set working group
	CALL	SET_TELGROUP
;-
	CALL	GET_TELT
	SAH	MSG_T
	CALL	SEND_TOTALCID
;-
	CALL	GET_TELN
	SAH	MSG_N
	CALL	SEND_NEWCID
;---Dial-cid
	LACK	CGROUP_DIAL
	CALL	DAM_BIOSFUNC
	CALL	GET_TELT
	CALL	SEND_DIALCID
;---dam_att
	LACL	CidData		;Base Address
	SAH	ADDR_S
	SAH	ADDR_D
	LACK	0
	SAH	OFFSET_D
	SAH	OFFSET_S
	LACK	CGROUP_DATT
	CALL	DAM_BIOSFUNC

	CALL	GET_DAMINIT
	CALL	SEND_DAMINIT
;-
;---verify message number
	CALL	VPMSG_CHK
	CALL	SEND_MSGNUM
;!!!!!!!!!	
;---send version NO.first
	LACK	0X0F
	CALL	SEND_DAT
	LACK	CVersion
	CALL	SEND_DAT
;!!!!!!!!!
	CALL	DAA_SPK
	CALL	INITBEEP
	CALL	DAA_OFF
	CALL	MSGLED_IDLE
	LACK	1
	SAH	PHOLED_FG
;!!!!!!!!!
;---------------first function
	CALL	CLR_FUNC	;先空
	LACK	0
	SAH	PRO_VAR
;---DSP reset
	LACK	0X3F		;Tell Mcu DSP reset ok
	CALL	SEND_DAT
	LACK	0X3F
	CALL	SEND_DAT
;---
	;CALL	INIT_DAM_FUNC
;---------------------------------------
	CALL	CLR_MSG
;---------------------------------------
;-!!!
	LACL	CMSG_INIT
	;LACL	CREC_OGM	;???????????????????????????????????????????????
	CALL	STOR_MSG

	RET

;-------------------------------------------------------------------------------
;	Function : LOAD_DAMATT
;---Note Get data by WORD,but stor data by Byte
;	input : no
;	output: no
;-------------------------------------------------------------------------------
LOAD_DAMATT:		;上电时读出
	LACL	CDAM_ATT
	ANDL	0X0CFF
	SAH	DAM_ATT

	LACK	0
	SAH	EVENT
	SAH	LOCACODE
	SAH	PASSWORD
	SAH	DAM_ATT0
	SAH	DAM_ATT1
;---	
	MAR	+0,1
	LARL	CTEL_BASE,1
;---Word1 ==> ps1,2,3,4	
	LAC	+
	SAH	PASSWORD
;---Word2 ==> lc1,2,3,4	
	LAC	+
	SAH	LOCACODE
;---Word3 ==> pause time(15..12)/flash time(11..10)/Language(9,8)/ring melody(7..4)/LCD constrast(3..0)
	LAC	+
	SAH	DAM_ATT
;---Word4 ==> 
	LAC	+
	SAH	DAM_ATT0
;---Word5 ==> 
	LAC	+
	SAH	DAM_ATT1
;---Word6 ==> 
	LAC	+
	ANDL	0X0300
	SAH	EVENT
	
	RET
;-------------------------------------------------------------------------------
;	GET_DAMINIT
;	input : the total number of att
;	output: no
;-------------------------------------------------------------------------------
GET_DAMINIT:
	CALL	GET_TELT
	SAH	SYSTMP1
	BS	ACZ,DAM_ATT_INIT_FIRST
	SBHK	2
	BZ	SGN,DAM_ATT_INIT_MORE	;总数大于2条
	
	LAC	SYSTMP1
	CALL	DAT_READ
	;CALL	DspStop	;???????????????????????????????????????
	CALL	LOAD_DAMATT
	BS	B1,DAM_ATT_INIT_END
DAM_ATT_INIT_FIRST:		;第一次进入,直接将默认值写入就OK了
	CALL	DAM_ATT_WRITE
	BS	B1,DAM_ATT_INIT_END
DAM_ATT_INIT_MORE:
	LACK	1
	CALL	DEL_ONETEL	;delete the first one
	CALL	TEL_GC_CHK
	BS	B1,GET_DAMINIT
DAM_ATT_INIT_END:
	RET
;-------------------------------------------------------------------------------
;	SEND_DAMINIT:
;	input : no
;	output: no
;-------------------------------------------------------------------------------
SEND_DAMINIT:
;---Byte0
	LACK	0X7F
	CALL	SEND_DAT
;---Byte1 ==> ps1,2
	LAC	PASSWORD
	SFR	8
	ANDL	0X0FF
	CALL	SEND_DAT
;---Byte2 ==> ps3,4
	LAC	PASSWORD
	ANDL	0X0FF
	CALL	SEND_DAT
;---Byte3 ==> lc1,2
	LAC	LOCACODE
	SFR	8
	ANDL	0X0FF
	CALL	SEND_DAT
;---Byte4 ==> lc3,4
	LAC	LOCACODE
	ANDL	0X0FF
	CALL	SEND_DAT
;---Byte5 ==> LCD constrast
	LAC	DAM_ATT0
	ANDK	0X00F
	CALL	SEND_DAT
;---Byte6 ==> Language
	LAC	DAM_ATT0
	SFR	8
	ANDK	0X003
	CALL	SEND_DAT
;---byte7 ==> ring melody
	LAC	DAM_ATT0
	SFR	4
	ANDK	0X00F
	CALL	SEND_DAT
;---byte8 ==> ring volume
	LAC	DAM_ATT1
	ANDK	0X00F
	CALL	SEND_DAT
;---byte9 ==> ring delay
	LAC	DAM_ATT
	SFR	12
	ANDK	0X00F
	CALL	SEND_DAT
;---byte10 ==> compression rate
	LAC	DAM_ATT1
	SFR	4
	ANDK	0X00F
	CALL	SEND_DAT
;---byte11 ==> flash time
	LAC	DAM_ATT0
	SFR	8
	ANDK	0X00F
	CALL	SEND_DAT
;---byte12 ==> pause time
	LAC	DAM_ATT0
	SFR	12
	ANDK	0X00F
	CALL	SEND_DAT
;---byte13 ==> DTAM status
	LACK	0X001
	SAH	SYSTMP0
	
	BIT	EVENT,9
	BZ	TB,SEND_DAMINIT_SELOGM
	
	LAC	SYSTMP0
	ORL	1<<7
	SAH	SYSTMP0
SEND_DAMINIT_SELOGM:	
	BIT	EVENT,8
	BZ	TB,SEND_DAMINIT_STATUS
	
	LAC	SYSTMP0
	ANDL	0XFFFC
	ORK	0X002
	SAH	SYSTMP0
SEND_DAMINIT_STATUS:
	LAC	SYSTMP0
	CALL	SEND_DAT

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
.if	0
PS_TAB:	;0	1	2	3	4	5	6	7
.DATA	0X0135	0X0314	0X0728	0X0	0X0382	0X0905	0X0824	0X0212
.endif
;-------------------------------------------------------------------------------
.INCLUDE	l_beep/l_initbeep.asm

.INCLUDE	l_iic/l_storsqueue.asm
.INCLUDE	l_iic/l_flashmsg.asm
.INCLUDE	l_iic/l_exit.asm

.INCLUDE	l_iic/l_pbook.asm
.INCLUDE	l_iic/l_cid.asm
.INCLUDE	l_iic/l_dialcid.asm

.INCLUDE	l_move/l_stordata.asm
.INCLUDE	l_move/l_getdata.asm
.INCLUDE	l_move/l_dumpiic_tel.asm
.INCLUDE	l_move/l_ramstor.asm

.INCLUDE	l_port/l_spkctl.asm
.INCLUDE	l_port/l_msgled.asm

.INCLUDE	l_tel/l_alltel.asm
.INCLUDE	l_tel/l_damatt.asm
.INCLUDE	l_tel/l_del.asm
.INCLUDE	l_tel/l_group.asm
.INCLUDE	l_tel/l_newtel.asm
.INCLUDE	l_tel/l_read.asm
;.INCLUDE	l_tel/l_tel_read.asm
.INCLUDE	l_tel/l_write.asm
;-------------------------------------------------------------------------------
.END
