.LIST

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
	OUTL    0x03FF,GPAC    		;port-A[15:10]: input-pin   ;pin [9:0] as output-pin
	OUTL    ((1<<13)|(1<<9)|(1<<7)|(1<<6)|(1<<4)),GPBC    	;port-B[13]=1, enable IIC
						;pin [12,7,6,4]as output-pin
	OUTL    0x0FFF,GPAD 		;init. Port-A= 0x0FFF for key & LED
	OUTL    ((1<<9)|(1<<7)|(1<<6)),GPBD		;init. port-B= 0x0040 for LED off & un-MUTE, on-HOOK

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

	EINT
;----------------------
	CALL	InitDateTime

	LACL	0XFFFF
	SAH	KEY
	SAH	KEY_OLD
	LACL	0X2245
	SAH	VOI_ATT	;RING_CNT(15..12)/CallScreening(bit9)/Language(bit8)/SPK_Gain(7..4)/SPK_VOL(3..0)

	LACL	(CROUT_DRV<<5)|CLOUT_DRV
	SAH	TAD_ATT1	;for remote-line-out/local-line-out

	EINT
;---------------Enable DAC-1/0
	LACL	0xD106
	CALL	DAM_BIOSFUNC
;---------------Set silence-to-voice change rate
	LACK	9
	CALL	SET_CHSVRATE
;---------------Set ALC gain
	call	SET_ALCGAIN
;---------------Set S/W ALC max. amplified level
	call	SET_ALCMAL
;---------------Close SW7
	CALL	DAA_INIT_SPK
;---------------initial Flash memory
	LACL	200
	CALL	DELAY
	
	LAC	KEY
	XORL	0XFFFB
	BS	ACZ,INIT_FORMAT		;按住Del键上电就格式化Flash

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
	;LACL	0X86AF		;Display "Er"
    	;SAH	LED_L
	CALL	WBEEP
    	BS	B1,INIT_FLASH_END
INIT_FLASH_GOOD:
	CALL	REAL_DEL
	CALL	GC_CHK
	CALL	INITBEEP

INIT_FLASH_END: 
;---------------first function

	CALL	CLR_FUNC	;先空
    	LACL	LOCAL_PRO
     	CALL	PUSH_FUNC
     	
     	CALL	VPMSG_CHK

;-!!!
	LACK	0X2F
	CALL	SEND_DAT
	LACK	0X2F
	CALL	SEND_DAT
;-!!!
     	LACL	CMSG_INIT
     	CALL	STOR_MSG
	
	RET
DAA_INIT_SPK:	;(SW3)&(SW7) ==> (DAC->SPK)&(DAC->LOUT)
	LIPK    6
        ;OUTL    ((1<<3)|(1<<7)),switch
        OUTL    ((1<<3)|(1<<7)),SWITCH

	NOP
	LAC	TAD_ATT1	;
	ANDK	0X1f
	ADHL	VOL_TAB
	CALL	GetOneConst
	SAH	CODECREG2
	SFL	5
	OR	CODECREG2
	SAH	CODECREG2
	OUT	CODECREG2,LOUTSPK
	ADHK	0
;---
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
;       Function : get week
;	input : (year=SYSTMP1-7..0/month=SYSTMP1-15..8/day=SYSTMP0)
;	output: ACCH = week
;-------------------------------------------------------------------------------
GET_WEEK:
	LACL	0X8600
	CALL	DAM_BIOSFUNC	;GET year
	ADH	TMR_YEAR
	SAH	SYSTMP1
	
	LACL	0X8500
	CALL	DAM_BIOSFUNC	;GET month
	SFL	8
	OR	SYSTMP1
	SAH	SYSTMP1
	
	LACL	0X8400
	CALL	DAM_BIOSFUNC	;GET day
	SAH	SYSTMP0
;---取闰年数
	LAC	SYSTMP1
	ANDK	0X7F
	SFR	2
	SAH	SYSTMP2		;暂存闰年数
;---查月表	
	LAC	SYSTMP1
	SFR	8
	ANDK	0X0F
	SBHK	1		;没有0月
	ADHL    DATE_TAB
	CALL	GetOneConst
	SAH     SYSTMP3		;暂存月表值
;---具体日
	LAC	SYSTMP1		;年
	ANDK	0X7F
	ADH     SYSTMP3		;月
	ADH	SYSTMP0		;日
	ADH	SYSTMP2		;闰年数
	ADHK	5		;2000年1月1日的(星期六)前一天
	SAH	SYSTMP0
;---以下修正--------------------------------------------------------------------
	LAC	SYSTMP1		;是闰年吗?
	ANDK	0x03
	BZ	ACZ,GET_WEEK_0
;---是闰年再查是否过了三月?	
	LAC	SYSTMP1
	SFR	8
	ANDK	0X0F
	SBHK	3
	BS	SGN,GET_WEEK_1	;只有闰年的小于3月的日期不加1修正
;---当前年份是(闰年)(月份大于2)或平年
GET_WEEK_0:
	LAC	SYSTMP0
	ADHK	1
	SAH	SYSTMP0
;---取星期数(对7取余)
GET_WEEK_1:
	LAC	SYSTMP0
	SBHK	7
	BS	SGN,GET_WEEK_2	;小于7
	SAH	SYSTMP0
	BS	B1,GET_WEEK_1
GET_WEEK_2:
	LAC	SYSTMP0
;---
	RET
;-------------------------------------------------------------------------------
;	Function : SET_AGSL
;	Set AGS level for SVDD voltage setting
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
SET_AGSL:
	SAH	SYSTMP1
;---
	LACL	0X5F13
	CALL	DAM_BIOSFUNC
	LAC	SYSTMP1
	CALL	DAM_BIOSFUNC
;---
	RET
;-------------------------------------------------------------------------------
;	Function : SET_ALCMAXL
;	Set ALC maximum amplified level
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
SET_ALCMAXL:
	SAH	SYSTMP1
;---
	LACL	0X5F41
	CALL	DAM_BIOSFUNC
	LAC	SYSTMP1
	CALL	DAM_BIOSFUNC
;---
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
;-------------------------------------------------------------------------------
SET_ALCGAIN:
	LACL	0X5F40
	CALL	DAM_BIOSFUNC
	LACK	CALCGAIN
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
	LACL	CALCMAL
	CALL	DAM_BIOSFUNC
;---
	RET
;-------------------------------------------------------------------------------
;	Function : INIT_VOP	
;	INPUT : ACCH = the MSGID
;	output: no
;-------------------------------------------------------------------------------
INIT_VOP:
	ANDK	0X7F
	SAH	SYSTMP1
;---
	LAC	SYSTMP1
	ORL	0XB000
	SAH	CONF
INIT_VOP_LOOP:
	CALL    DAM_BIOS
	BIT	RESP,6
	BZ	TB,INIT_VOP_LOOP
	
	RET
;-------------------------------------------------------------------------------
.END
