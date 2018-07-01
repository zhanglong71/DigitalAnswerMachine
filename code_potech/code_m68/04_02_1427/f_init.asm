.NOLIST
.INCLUDE	include/REG_D22.inc
.INCLUDE	include/MD22U.inc
.INCLUDE	include/CONST.inc

.GLOBAL	INITDSP
;-------------------------------------------------------------------------------
.EXTERN	GetOneConst
.EXTERN	DspPly
.EXTERN	DspStop

.EXTERN	INIT_DAM_FUNC
;.EXTERN	ANNOUNCE_NUM

;.EXTERN	BCVOX_INIT
;.EXTERN	BBBEEP
;.EXTERN	BBEEP
.EXTERN	BEEP_START
.EXTERN	BEEP_STOP

.EXTERN	CLR_FUNC
.EXTERN	CLR_TIMER

.EXTERN	DAA_ANS_SPK
.EXTERN	DAA_ANS_REC
.EXTERN	DAA_LIN_SPK
.EXTERN	DAA_LIN_REC
.EXTERN	DAA_SPK
.EXTERN	DAA_OFF
.EXTERN	DAM_BIOSFUNC
.EXTERN	DAM_BIOSFUNC1
.EXTERN	DELAY
.EXTERN	DGT_TAB

.EXTERN	GC_CHK
.EXTERN	GET_VPTLEN
.EXTERN	GETBYTE_DAT

.EXTERN	HOOK_ON

.EXTERN	LBEEP
.EXTERN	LINE_START

.EXTERN	LOCAL_PRO
.EXTERN	OGM_SELECT
.EXTERN	OGM_STATUS

.EXTERN	PUSH_FUNC

.EXTERN	REC_START

.EXTERN	SEND_DAT
.EXTERN	SEND_MSGNUM
.EXTERN	SEND_TEL
.EXTERN	SET_TIMER
.EXTERN	SET_COMPS

.EXTERN	STOR_MSG
.EXTERN	STOR_VP

.EXTERN	TEL_GC_CHK

.EXTERN	TELNUM_WRITE
.EXTERN	TELNUM_READ

.EXTERN	VOL_TAB
.EXTERN	VPMSG_CHK
.EXTERN	VPMSG_DEL
.EXTERN	VPMSG_CHK
;---

.EXTERN	VP_DefOGM

;---
;-------------------------------------------------------------------------------
.LIST
;-------------------------------------------------------------------------------
.ORG	ADDR_SECOND
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
	OUTL    ((1<<13)|(1<<9)|(1<<7)|(1<<6)|(1<<5)|(1<<4)),GPBC    	;port-B[13]=1, enable IIC
					;pin [12,7,6,4]as output-pin

	OUTL    (0x0FFA)&(~(1<<8)),GPAD 		;init. Port-A= 
	OUTL    ((1<<9)|(1<<6)|(1<<4)),GPBD	;init. port-B= 0x0040 for LED off & un-MUTE, on-HOOK

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

	OUTL	0x0b88,AGC
	;OUTL	0x3def,LOUTSPK
	OUTL	0x7ffe,LOUTSPK
	OUTL	0x1fff,MUTE

;----------------------
	CALL	InitDateTime
;-
	LACL	CPASSWORD
	SAH	PASSWORD
;-
	LACL	CLOCACODE
	SAH	LOCACODE
;-
	LACL	CDAM_ATT
	SAH	DAM_ATT
;-	
	LACL	CDAM_ATT0
	SAH	DAM_ATT0
;-
	LACL	CDAM_ATT1
	SAH	DAM_ATT1
;-
	EINT
;---------------Enable DAC-1/0
	LACL	0xD106
	CALL	DAM_BIOSFUNC
;---------------initial Flash memory
	LACL	200
	CALL	DELAY

	CALL	DAA_SPK
INIT_FLASH:
    	LACL	CMODE9|2
    	CALL    DAM_BIOSFUNC
    	BIT     RESP, 8
    	BS	TB, INIT_FLASH_GOOD             
INIT_FORMAT:
    	LACL    CMODE9|1
    	CALL    DAM_BIOSFUNC
    	BIT	RESP, 8
	BS	TB,INIT_FLASH_GOOD

	CALL	WBEEP
    	BS	B1,INIT_FORMAT
INIT_FLASH_GOOD:
;---------------Declare TEL-message Number in FLASH
	CALL	REAL_DEL
	CALL	TEL_GC_CHK
	CALL	MIDI_STOP	;reset MIDI IC

	CALL	INITBEEP
	CALL	DAA_OFF
;---------------first function
	CALL	CLR_FUNC	;先空
    	LACL	LOCAL_PRO
     	CALL	PUSH_FUNC
;---------------Set VOX
	LACL	0xD700|0x19
	CALL	DAM_BIOSFUNC
;---------------Set silence threshold	
	LACL	0X7700|1
	CALL	DAM_BIOSFUNC
;---------------Set DTMF sensitivity	
	LACL	0X5800|45	;Default setting = -44DB
	CALL	DAM_BIOSFUNC
;---------------Set silence-to-voice change rate
	LACK	3
	CALL	SET_CHSVRATE
;---------------Set ALC gain
	LACK	10	
	CALL	SET_ALCGAIN
;---------------Set DTMF type    	
	LACK	1
	CALL	SET_DTMFTYPE
;---------------Set COMPRESS 	
	CALL	SET_COMPS
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

.IF	1
;---M1
INIT_M1TEL:
	LACK	CGROUP_M1
	CALL	SET_TELGROUP
	CALL	GET_TELT
	BS	ACZ,INIT_M2TEL		;No M1 TEL
	SAH	MSG_ID

	LACL	CidData
	SAH	ADDR_D
	LACK	0
	SAH	OFFSET_D	;The address TEL will saved
	LAC	MSG_ID
	CALL	TELNUM_READ

	LACL	CidData
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	LACK	58
	SAH	COUNT
	CALL	SEND_TEL

	LACK	0X01
	CALL	SEND_TELOK
	LACK	100
	CALL	DELAY		;Delay 5ms
;---M2
INIT_M2TEL:
	LACK	CGROUP_M2
	CALL	SET_TELGROUP
	CALL	GET_TELT
	BS	ACZ,INIT_M3TEL		;No M2 TEL
	SAH	MSG_ID

	LACL	CidData
	SAH	ADDR_D
	LACK	0
	SAH	OFFSET_D
	LAC	MSG_ID
	CALL	TELNUM_READ
	
	LACL	CidData
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	LACK	58
	SAH	COUNT
	CALL	SEND_TEL

	LACK	0X02
	CALL	SEND_TELOK
	LACK	100
	CALL	DELAY		;Delay 5ms
;---M3
INIT_M3TEL:
	LACK	CGROUP_M3
	CALL	SET_TELGROUP
	CALL	GET_TELT
	BS	ACZ,INIT_ENDMTEL	;No M3 TEL
	SAH	MSG_ID

	LACL	CidData
	SAH	ADDR_D
	LACK	0
	SAH	OFFSET_D
	LAC	MSG_ID
	CALL	TELNUM_READ

	LACL	CidData
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	LACK	58
	SAH	COUNT
	CALL	SEND_TEL

	LACK	0X03
	CALL	SEND_TELOK
	LACK	100
	CALL	DELAY		;Delay 5ms
INIT_ENDMTEL:

.ENDIF
;---------------------------------------
.IF	1
;---Pbook
	LACK	CGROUP_PBOOK
	CALL	SET_TELGROUP
	CALL	GET_TELT
	CALL	SEND_PBOOK
;---Miss-cid
	LACK	CGROUP_MISSCID
	CALL	SET_TELGROUP
;---total
	CALL	GET_TELT
	CALL	SEND_MISSCID
;---new 
	CALL	GET_TELN
	CALL	SEND_NEWCID
;---Answered-cid
	LACK	CGROUP_ANSWCID
	CALL	SET_TELGROUP
	CALL	GET_TELT
	CALL	SEND_ANSWCID
;---Dial-cid
	LACK	CGROUP_DIAL
	CALL	SET_TELGROUP
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
	CALL	SET_TELGROUP

	CALL	GET_DAMINIT
	CALL	SEND_DAMINIT
	
;---DAM-MSG ok
	CALL	VPMSG_CHK
	CALL	SEND_MSGNUM
;---Version
	LACK	0X0F
	CALL	SEND_DAT
	LACK	CVersion
	CALL	SEND_DAT
;---DSP reset
	LACK	0X3F		;Tell Mcu DSP reset ok
	CALL	SEND_DAT
	LACK	0X3F
	CALL	SEND_DAT
;---------------------------------------
.ENDIF
;-------	
     	LACL	CMSG_INIT
     	CALL	STOR_MSG
	
	RET

;-------------------------------------------------------------------------------
;       InitDateTime : initial RTC register
;	
;-------------------------------------------------------------------------------
InitDateTime:       ;test ok
	lipk    9

	outl    0x0000, RTCMS	; min=00, sec=00
	outl    0x0000, RTCWH	; week=0, hour=00
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

	SAH	SYSTMP1
;---
	LACL	0X5F43
	CALL	DAM_BIOSFUNC
	LAC	SYSTMP1
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
	SAH	SYSTMP1
;---
	LACL	0X5F40
	CALL	DAM_BIOSFUNC
	LAC	SYSTMP1
	CALL	DAM_BIOSFUNC
;---
	RET

;-------------------------------------------------------------------------------
;	Function : WBEEP
;	
;	Generate a warning beep
;-------------------------------------------------------------------------------
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
	SAH	LOCACODE
	SAH	PASSWORD
	SAH	DAM_ATT0
	SAH	DAM_ATT1
;---Byte1 ==> ps1,2	
	LACK	0
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	SFL	8
	SAH	PASSWORD
;---Byte2 ==> ps3,4	
	LACK	1
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	OR	PASSWORD
	SAH	PASSWORD
;---Byte3 ==> lc1,2	
	LACK	2
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	SFL	8
	SAH	LOCACODE
;---Byte4 ==> lc3,4	
	LACK	3
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	OR	LOCACODE
	SAH	LOCACODE
;---Byte5 ==> LCD constrast(DAM_ATT0)
	LACK	4
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	ANDK	0X0F
	SAH	DAM_ATT0	;clear old data in "DAM_ATT0"
;---Byte6 ==> Language(DAM_ATT)
	LACK	5
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	SFL	8
	ANDL	0X0300
	OR	DAM_ATT
	SAH	DAM_ATT
;---byte7 ==> ring melody
	LACK	6
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	SFL	4
	ANDL	0X00F0
	OR	DAM_ATT0
	SAH	DAM_ATT0
;---byte8 ==> ring volume
	LACK	7
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	ANDK	0X00F
	OR	DAM_ATT1
	SAH	DAM_ATT1
;---byte9 ==> ring delay
	LACK	8
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	SFL	12
	ANDL	0XF000
	OR	DAM_ATT
	SAH	DAM_ATT
;---byte10 ==> compression rate
	LACK	9
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	SFL	4
	ANDL	0X00F0
	OR	DAM_ATT1
	SAH	DAM_ATT1
;---byte11 ==> flash time
	LACK	10
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	SFL	8
	ANDL	0X0F00
	OR	DAM_ATT0
	SAH	DAM_ATT0
;---byte12 ==> pause time
	LACK	11
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	SFL	12
	ANDL	0XF000
	OR	DAM_ATT0
	SAH	DAM_ATT0
	
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
	CALL	TELNUM_READ
	;CALL	DspStop	;???????????????????????????????????????
	CALL	LOAD_DAMATT
	BS	B1,DAM_ATT_INIT_END
DAM_ATT_INIT_FIRST:		;第一次进入,直接将默认值写入就OK了
	CALL	DAM_ATT_WRITE
	BS	B1,DAM_ATT_INIT_END
DAM_ATT_INIT_MORE:
	LACL	0XE501
	CALL	DAM_BIOSFUNC	;delete the first one
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
	ORK	0X002
	SAH	SYSTMP0
SEND_DAMINIT_STATUS:
	LAC	SYSTMP0
	CALL	SEND_DAT

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
	LACL	0x5F46		;set DTMF type
	CALL	DAM_BIOSFUNC
	LAC	SYSTMP0		;value
	CALL	DAM_BIOSFUNC
;------
	POP	CONF
	
	RET
;---------------------------------------
;-------------------------------------------------------------------------------
.INCLUDE	block/damatt_wr.asm
.INCLUDE	block/l_telcomm.asm
.INCLUDE	block/l_midi.ASM
.INCLUDE	block/l_plydel.ASM
.INCLUDE	block/tel_init.ASM
;-------------------------------------------------------------------------------
.END
