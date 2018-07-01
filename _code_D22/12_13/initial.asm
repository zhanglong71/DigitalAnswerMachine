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
	OUTL    ((1<<13)+(1<<7)+(1<<6)),GPBC    	;port-B[13]=0, enable IIC  ;pin [12:8] as input-pin  
						;pin [7,6]as output-pin ;pin [5:0] as input-pin
	OUTL    0x0FFF,GPAD 		;init. Port-A= 0x8FFF for key & LED
	OUTL    0x0040,GPBD		;init. port-B= 0x0040 for LED off & un-MUTE, on-HOOK

	OUTK    0X00,GPBIEN		;
;----------------------
	LIPK    9
	OUTK    0x00,GPBITP		;define io-interrupt as "falling-edge trigger"
;!!!!!!!!!!!!!!!!!!!!!
;-----				;-----
	lipk	5
	outl	0x0003,IICPW		;Enable power first
	outl	0x6200,IICCR		;(bit14=Enable iic control)&(bit13=Reset iic)&(Enable iic interrupt)Default is Slave mode
    	;nop

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
	BZ	ACZ,InitCodec_wait
	OUTL	0x0b88,AGC
	;OUTL	0x3def,LOUTSPK
	OUTL	0x7ffe,LOUTSPK
	OUTL	0x1fff,MUTE
	OUTL	0x0080,SWITCH		;打开Speaker
	
	eint
;----------------------
	CALL	InitDateTime

	LACL	0XFFFF
	SAH	KEY_OLD
	SAH	KEY

	LACL	0X3042
	SAH	PHONE_ATT	;ERL_LEC(15..12)/ERL_AEC(11..8)/LOOP att(7..4)/T|R(3..0)
	LACL	0X6455		;Ring-cnt(15..12)/Line_Gain(11..8)/SPK_Gain(7..4)/SPK_VOL(3..0)
        SAH	VOI_ATT
        LACL	0X010		;Reserved(15..12)/Reserved(11..8)/rate(7..4)/Reserved(3..0)
        SAH	TAD_ATT
        LACK	0X0002
        SAH	RING_ID
        
        LACK	0
        SAH	PASSWORD
	
	EINT
	
;---------------Enable DAC-1/0
	LACL	0xD106
	CALL	DAM_BIOSFUNC
;---------------Set VOX
	LACL	0xD719
	CALL	DAM_BIOSFUNC
;---------------Close SW7
	CALL	DAA_SPK
	
	LACL	100
	CALL	DELAY
;---按住ERASE format Flash
	LAC	KEY
	XORL	0XF7FF
	BS	ACZ,INIT_FORMAT
;---------------initial Flash memory
INIT_FLASH:
    	LACL    0x9042
    	CALL    DAM_BIOSFUNC
    	BIT     RESP, 8
    	BS	TB, INIT_FLASH_GOOD             
INIT_FORMAT:
    	LACL    0x9041
    	CALL    DAM_BIOSFUNC
    	BIT	RESP, 8
    	BS	TB, INIT_FLASH_GOOD
    	CALL	WBEEP
    	BS	B1,INIT_FLASH_END
INIT_FLASH_GOOD:
	CALL	INITBEEP
INIT_FLASH_END: 
;---------------first function
	CALL	CLR_FUNC	;先空
    	LACL	LOCAL_PRO
     	CALL	PUSH_FUNC
	
	RET
	
;-------------------------------------------------------------------------
;       InitDateTime : initial RTC register
;	
;-------------------------------------------------------------------------
InitDateTime:       ;test ok
	lipk    9

	outl    0x0000, RTCMS	; min=00, sec=00
	outl    0x0000, RTCWH	; week=0, hour=00
	outl    0x0101, RTCMD	; month=01, day=01
	outl    0x0707, RTCCY	; control, year=07
	OUTL    0x0307, RTCCY	; 
        RET
        	
;-------------------------------------------------------------------------------
.END
