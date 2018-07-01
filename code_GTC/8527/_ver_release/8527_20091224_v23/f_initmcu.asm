.NOLIST
.INCLUDE	include/REG_D22.inc
.INCLUDE	include/MD22U.inc
.INCLUDE	include/CONST.inc
.INCLUDE	include/EXTERN.inc
.INCLUDE	include/VERSION.inc

.GLOBAL	INITMCU
;-------------------------------------------------------------------------------
.EXTERN	GetOneConst	;(INPUT=ACCH(ProgramRamAddress),OUTPUT=ACCH(ReadData))
.EXTERN	GetMoreConst	;(INPUT=ACCH(ProgramRamStartingAddress)ACCL(ReadWordNumber)AR1(StoreDataRamAddress),OUTPUT=)
;---
;-------------------------------------------------------------------------------
.LIST
.ORG	ADDR_SECOND
;-------------------------------------------------------------------------------
INITMCU:
;---------------
.if	1
	CALL	INIT_ATT
.endif
;---------------
.if	1
	CALL	INITPBOOK
.endif
;---------------------------------------
;---verify CID number
	LACL	0XE600|CGROUP_CID		;set working group
	CALL	DAM_BIOSFUNC
	LACL	0XE401
	CALL	DAM_BIOSFUNC
	SAH	MSG_T
	CALL	GET_TELN
	SAH	MSG_N
;!!!
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
;!!!	
	LACK	50
	CALL	DELAY
;---verify message number
	CALL	GC_CHK
	CALL	VPMSG_CHK
	CALL	SEND_MSGNUM
;!!!!!!!!!	;send version NO.first
	LACK	0X30
	CALL	SEND_DAT
	LACL	CVersion
	CALL	SEND_DAT
;!!!!!!!!!
	CALL	EXIT_TOIDLE
;!!!!!!!!!
	LACK	50
	CALL	DELAY
;---------------first function
	CALL	CLR_FUNC	;先空
	LACK	0
	SAH	PRO_VAR
;---------------------------------------
	CALL	INIT_DAM_FUNC
;---------------------------------------	
	CALL	CLR_MSG
;---------------------------------------
	LACK	0X74
	SAH	DTMF_VAL

	LACL	CKEY_VOP
	CALL	STOR_MSG
;-!!!
	LACL	500
	CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1
;---
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
;.INCLUDE	l_wdt.asm

;.INCLUDE	l_CodecPath/l_allopen.asm
;.INCLUDE	l_CodecPath/l_lply.asm


;.INCLUDE	l_flashmsg/l_biosfull.asm
;.INCLUDE	l_flashmsg/l_flashmsg.asm

.INCLUDE	l_iic/l_storsqueue.asm
.INCLUDE	l_iic/l_flashmsg.asm
.INCLUDE	l_iic/l_exit.asm


.INCLUDE	l_move/l_stordata.asm
.INCLUDE	l_move/l_getdata.asm
.INCLUDE	l_move/l_dumpiic_tel.asm
.INCLUDE	l_move/l_ramstor.asm

.INCLUDE	l_port/l_spkctl.asm
.INCLUDE	l_port/l_msgled.asm

.INCLUDE	l_table/l_voltable.asm

.INCLUDE	l_tel/l_newtel.asm
.INCLUDE	l_tel/l_tel_read.asm

;.INCLUDE	l_voice/l_poweron.asm
;-------------------------------------------------------------------------------
.END
