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
	OUTL    ((1<<3)|(1<<4)|(1<<6)|(1<<7)),GPBC    	;port-B[13]=0, disable IIC
						;pin [7,6,4,3]as output-pin
	OUTL    0x0FFF,GPAD 		;init. Port-A= 0x0FFF for key & LED
	OUTL    0X0,GPBD		;init. port-B= 0x0000 for b-play=low,b-H-play=low,un-MUTE, on-HOOK

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
	;OUTL	0x0080,SWITCH		;��Speaker
	
	eint
;----------------------
	CALL	InitDateTime

	LACL	0XFFFF
	SAH	KEY
	SAH	KEY_OLD

	LACL	0X3033
	SAH	PHONE_ATT	;ERL_LEC(15..12)/ERL_AEC(11..8)/LOOP att(7..4)/T|R(3..0)
	LACL	0X2047
        SAH	VOI_ATT		;RING_CNT/language/SPK_Gain/SPK_VOL
        LACK	0X0002
        SAH	RING_ID
	
	EINT
;---------------Enable DAC-1/0
	LACL	0xD106
	CALL	DAM_BIOSFUNC
;---------------Set VOX
	LACL	0xD700|CVOX_LEVEL
	CALL	DAM_BIOSFUNC
;---------------Set silence
	;LACL	0x7700|CSILENCE_LEVEL
	;CALL	DAM_BIOSFUNC
;---------------Set AGS level for SVDD voltage setting
	;LACK	2
	;CALL	SET_AGSL
;---------------Set voice-to-silence change rate
	LACK	8
	CALL	SET_CHVSRATE
;---------------Set silence-to-voice change rate
	LACK	8
	CALL	SET_CHSVRATE
;---------------initial Flash memory
	LACL	200
	CALL	DELAY
	
	LAC	KEY
	XORL	0XFFFB
	BS	ACZ,INIT_FORMAT	;��סDel���ϵ�͸�ʽ��Flash
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
	BS	TB, INIT_FLASH_GOOD
	LACL	DISP_Er		;Display "Er"
    	SAH	LED_L
    	
	CALL	DAA_SPK
	CALL	WBEEP
    	BS	B1,INIT_FLASH_END
INIT_FLASH_GOOD:
;---Declare TEL-message Number in FLASH
	CALL	SET_DECLTEL
	CALL	REAL_DEL
	CALL	TEL_GC_CHK
	CALL	GC_CHK
;-------------------------------------------------------------------------------
	CALL	GET_FLASHDATA
;-------------------------------------------------------------------------------
	LAC	KEY
	XORL	0XFFF9
	BS	ACZ,INIT_FLASH_TESTMODE	;��סDel&>>��3s�ϵ�ͽ���TestMode
	CALL	HANDSET_CHK
	;CALL	INITBEEP	;2009-1-7 9:36 Primatronix demand give up the initbeep
	CALL	PORT_HSPLYL
	CALL	PORT_PLYL
;---	
	LAC	KEY
	XORL	0XFFED
	BS	ACZ,INIT_FLASH_SELLANG	;��ס<<&>>��3s�ϵ�ͽ���TestMode
	BS	B1,INIT_FLASH_END
;-----------------------------
INIT_FLASH_SELLANG:
	LACL	DISP_SL
	SAH	LED_L	;Display "SL"

	CALL	CLR_MSG		;�������

	LACL	CMSG_SELL	;select language
     	CALL	STOR_MSG
     	BS	B1,INIT_FLASH_END
;-----------------------------
INIT_FLASH_TESTMODE:	
	LACL	3000
	SAH	TMR_DELAY
	LACL	DISP_tt
	SAH	LED_L	;Display "tt"
	
INIT_FLASH_TESTMODE_WAIT:
	LAC	KEY
	XORL	0XFFF9
	BZ	ACZ,INIT_FLASH_END	;Del&>>���ɿ��Ͳ������TestMode
	LAC	TMR_DELAY
	BZ	SGN,INIT_FLASH_TESTMODE_WAIT
;---����TestMode
	CALL	CLR_MSG		;�������

	LACL	CMSG_TMODE
     	CALL	STOR_MSG
INIT_FLASH_END: 
;---------------first function

	CALL	GET_PSWORD
	
	CALL	CLR_FUNC	;�ȿ�
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
GET_PSWORD:
	lipk	8
        IN      SYSTMP0,GPAD
	LAC	SYSTMP0
	SFR	9
	ANDK	0X06		;GPAD(11,10)
	SAH	SYSTMP0
	
	IN      SYSTMP1,GPBD
	BIT	SYSTMP1,8
	BZ	TB,GET_PSWORD_0
	
	LAC	SYSTMP0
	ORK	0X01
	SAH	SYSTMP0		;SYSTMP0(2,1,0) = (GPBD.8),(GPAD.11),(GPBD.10)
GET_PSWORD_0:
	LAC	SYSTMP0
	BS	ACZ,GET_PSWORD0
	SBHK	1
	BS	ACZ,GET_PSWORD1
	SBHK	1
	BS	ACZ,GET_PSWORD2
	SBHK	1
	BS	ACZ,GET_PSWORD3
	SBHK	1
	BS	ACZ,GET_PSWORD4
	SBHK	1
	BS	ACZ,GET_PSWORD5
	SBHK	1
	BS	ACZ,GET_PSWORD6
	SBHK	1
	BS	ACZ,GET_PSWORD7
	
	RET
GET_PSWORD0:
	LACL	0X0135
	SAH	PASSWORD
	RET
GET_PSWORD1:
	LACL	0X0314
	SAH	PASSWORD
	RET
GET_PSWORD2:
	;LACL	0X0328
	LACL	0X0728
	SAH	PASSWORD
	RET
GET_PSWORD3:
	LACL	0X0
	SAH	PASSWORD
	RET
GET_PSWORD4:
	LACL	0X0382
	SAH	PASSWORD
	RET
GET_PSWORD5:
	LACL	0X0905
	SAH	PASSWORD
	RET
GET_PSWORD6:
	LACL	0X0824
	SAH	PASSWORD
	RET
GET_PSWORD7:
	LACL	0X0212
	SAH	PASSWORD
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
;-------------------------------------------------------------------------------
GET_FLASHDATA:
	LACK	CGROUP_DATT
	CALL	SET_TELGROUP
	CALL	GET_TELT
	BS	ACZ,GET_FLASHDATA_1
	SAH	MSG_ID		;ֻһ��,Ҳ�����һ��
	BS	B1,GET_FLASHDATA_1_2
GET_FLASHDATA_1:
	CALL	DEFATT_WRITE
	
	LACK	1
	SAH	MSG_ID	
GET_FLASHDATA_1_2:
;---read attribute from flash
	LACL	TEL_RAM
	SAH	ADDR_D		;�����ַ
	SAH	ADDR_S		;��ȡ��ַ
	LACK	0
	SAH	OFFSET_D	;����ƫ��
	LAC	MSG_ID		;��Ŀ��
	CALL	TELNUM_READ	;����ǰ��Ŀ����
	CALL	DAT_READ_STOP
;---get language data
	LACK	4
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	CALL	STOR_LANGUAGE
	
	RET
;-------------------------------------------------------------------------------
.END
