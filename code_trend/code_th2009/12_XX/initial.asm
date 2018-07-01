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
	OUTL    0x0FFF,GPAC    		;port-A[15:12]: input-pin   ;pin [11:0] as output-pin
	OUTL    ((1<<4)|(1<<6)|(1<<7)),GPBC    	;port-B[13]=0, disable IIC
						;pin [7,6,5,4,3]as output-pin
	OUTL    0x0FFF,GPAD 		;init. Port-A= 0x0FFF for key & LED
	OUTL    (1<<6),GPBD		;init. port-B= 0x0040 for LED off & un-MUTE, on-HOOK

	OUTK    0X00,GPBIEN		;
;----------------------
	LIPK    9
	OUTK    0x00,GPBITP		;define io-interrupt as "falling-edge trigger"
;!!!!!!!!!!!!!!!!!!!!!
;-----				;-----
	lipk	5
	outl	0x0003,IICPW		;Enable power first
	outl	0x6200,IICCR		;(bit14=Enable iic control)&(bit13=Reset iic)&(Enable iic interrupt)Default is Slave mode
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
	OUTL	0x0080,SWITCH		;打开Speaker
	
	eint
;----------------------
	CALL	InitDateTime

	LACL	0XFFFF
	SAH	KEY
	SAH	KEY_OLD

	LACL	0X2444
        SAH	VOI_ATT		;RING_CNT/Line_Gain/SPK_Gain/SPK_VOL
        LACK	0X0002
        SAH	RING_ID
	
	EINT
;---------------Enable DAC-1/0
	LACL	0xD106
	CALL	DAM_BIOSFUNC
;---------------Set VOX
	LACL	0xD711
	;LACL	0xD70E
	;LACL	0xD717	;???????????????????????????????????????????????????????
	CALL	DAM_BIOSFUNC
;---------------Set AGS level for SVDD voltage setting
	;LACK	2
	;CALL	SET_AGSL
;---------------Set voice-to-silence change rate
	LACK	8
	CALL	SET_CHVSRATE
;---------------Set silence-to-voice change rate
	LACK	8
	CALL	SET_CHSVRATE
;---------------Close SW7
	CALL	DAA_SPK
;---------------initial Flash memory
	LACL	200
	CALL	DELAY
	
	LAC	KEY
	XORL	0XFFF7
	BS	ACZ,INIT_FORMAT	;按住Del键上电就格式化Flash
	;BIT	KEY,2
	;BZ	TB,INIT_FORMAT
INIT_FLASH:
    	LACL	CMODE9|2
    	CALL    DAM_BIOSFUNC
    	BIT     RESP, 8
    	BS	TB, INIT_FLASH_GOOD             
INIT_FORMAT:
    	LACL	CMODE9|1
    	CALL    DAM_BIOSFUNC
    	BIT	RESP, 8
	BS	TB,INIT_FLASH_GOOD
	LACL	0XAF		;Display "r"
    	SAH	LED_L
	CALL	WBEEP
    	BS	B1,INIT_FORMAT
    	;BS	B1,INIT_FLASH_END
INIT_FLASH_GOOD:
	LAC	KEY
	XORL	0XFFF9
	BS	ACZ,INIT_FLASH_TESTMODE	;按住Del&>>键3s上电就进入TestMode
	
	CALL	INITBEEP
	BS	B1,INIT_FLASH_END
INIT_FLASH_TESTMODE:	
	LACL	3000
	SAH	TMR_DELAY
	LACL	0X87
	SAH	LED_L	;Display "t"
	
INIT_FLASH_TESTMODE_WAIT:
	LAC	KEY
	XORL	0XFFE7
	BZ	ACZ,INIT_FLASH_END	;Del&on/off键松开就不会进入TestMode
	LAC	TMR_DELAY
	BZ	SGN,INIT_FLASH_TESTMODE_WAIT
;---进入TestMode
	CALL	CLR_MSG		;清除……

	LACL	CMSG_TMODE
     	CALL	STOR_MSG
INIT_FLASH_END: 
;---------------first function
	LACK	10
	CALL	SET_DECLTEL
	CALL	INITATT		;---

	CALL	CLR_FUNC	;先空
    	LACL	LOCAL_PRO
     	CALL	PUSH_FUNC
     	
     	;CALL	CLR_MSG
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
;	Function : SET_CHVSRATE
;	Set voice-to-silence change rate
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
SET_CHVSRATE:
	SAH	SYSTMP1
;---
	LACL	0X5F42
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
;	Function : SET_DECLTEL
;	Set TEL-message declare
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
SET_DECLTEL:
	SAH	SYSTMP1
;---
	LACL	0X5FA0
	CALL	DAM_BIOSFUNC
	SFR	8
	ANDL	0XFF
	BZ	ACZ,SET_DECLTEL_END	;error,exit
	LAC	SYSTMP1
	CALL	DAM_BIOSFUNC
;---
SET_DECLTEL_END:
	RET
;-------------------------------------------------------------------------------
;	Function : INITATT
;	send data to initial mcu
;-------------------------------------------------------------------------------
INITATT:
	LACK	3
	CALL	SET_TELGROUP
	CALL	GET_TELT
	BS	ACZ,INITATT_1
	SAH	MSG_ID		;只一个,也是最后一个
	BS	B1,INITATT_2
INITATT_1:
	CALL	DEFATT_WRITE
	
	LACK	1
	SAH	MSG_ID
INITATT_2:
	LACK	NEW1
	SAH	ADDR_D		;保存地址
	SAH	ADDR_S		;提取地址
	LAC	MSG_ID		;条目号
	CALL	READ_TELNUM	;读当前条目数据
	CALL	STOPREADDAT
;---
	LACK	0		;PS1
	SAH	COUNT
	CALL	GETBYTE_DAT
	ANDK	0XF
	SAH	PASSWORD
	SFL	4
	SAH	PASSWORD
	LACK	1		;PS2
	SAH	COUNT
	CALL	GETBYTE_DAT
	OR	PASSWORD
	SFL	4
	SAH	PASSWORD
	LACK	2		;PS3
	SAH	COUNT
	CALL	GETBYTE_DAT
	OR	PASSWORD
	SAH	PASSWORD
;---	
	LAC	VOI_ATT
	ANDL	0XFFF0
	SAH	VOI_ATT
	
	LACK	3		;Vol
	SAH	COUNT
	CALL	GETBYTE_DAT
	ANDK	0X0F
	OR	VOI_ATT
	SAH	VOI_ATT

	RET
;-------------------------------------------------------------------------------
.END
