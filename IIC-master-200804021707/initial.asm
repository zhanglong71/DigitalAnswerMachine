.LIST

INITDSP:
	LDPK	0
	LACK	0
	LUPK    127,0 				; LOOP 127 + 1 = 128 TIMES
	SAHP    +,0             		; USE ' 0 ' TO SAVE INTERNAL RAM
;----------------------
	LIPK    8                  	;initial I/O setting
	OUTL    0x0FFF, GPAC    	;port-A[15:12]: input-pin   ;pin [11:0] as output-pin
	OUTL    ((1<<4)|(1<<10)|(1<<11)|(1<<7)),GPBC    	;port-B[13]=0, disable IIC
						;pin [7,6,5,4,3]as output-pin
	OUTL    0x0FFF,GPAD 		;init. Port-A= 0x0FFF for key & LED
	OUTL    ((1<<5)|(1<<6)),GPBD		;init. port-B= 0x0040 for LED off & un-MUTE, on-HOOK

	OUTK    0X00,GPBIEN		;
;----------------------
	LIPK    9
	OUTK    0x00, GPBITP		;define io-interrupt as "falling-edge trigger"
;!!!!!!!!!!!!!!!!!!!!!
;-----				;-----
	lipk	5
	outl	0x0003, IICEN		;Enable power first
	outl	0x6200, IICCR		;(bit14=Enable iic control)&(bit13=Reset iic)&(Enable iic interrupt)Default is Slave mode
    	;nop

	outl	0xFFFF, IICSR		;Reset status register
	outl	0x8000+(0X82>>1), IICAR		;(bit15,14=7-bit-Slave address assigned)&()Slave address = 0x41
	outl	0x0021, IICTR		;IIC SCLK=409KHz
;-----				;-----
;!!!!!!!!!!!!!!!!!!!!!
;----------------------
	LIPK	7
	IN	SYSTMP0,DSPINTEN	;GPIO interrupt mask control = Enable
	LAC	SYSTMP0
	ANDL	0XFFEF
	SAH	SYSTMP0
	OUT	SYSTMP0,DSPINTEN
	ADHK	0
;----------------------	
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
	OUTL	0x0080,SWITCH		;´ò¿ªSpeaker
;----------------------
	CALL	InitDateTime

	LACL	0XFFFF
	SAH	KEY

	LACL	0X0124		;LANGUAGE/OGM_ID/RING_CNT/SPK_VOL
        SAH	VOI_ATT
        LACK	0X0002
        SAH	RING_ID
	
	EINT
;---------------Enable DAC-1/0
	LACL	0xD106
	SAH	CONF
	CALL	DAM_BIOS
;---------------Set VOX
	LACL	0xD719
	SAH	CONF
	CALL	DAM_BIOS

;---------------initial Flash memory
INIT_FLASH:
    	LACL    0x9042
    	SAH	CONF
    	CALL    DAM_BIOS
    	BIT     RESP, 8
    	BS	TB, INIT_FLASH_GOOD             
INIT_FORMAT:
    	LACL    0x9041                      
    	SAH     CONF
    	CALL    DAM_BIOS
    	BIT	RESP, 8
    	BS	TB, INIT_FLASH_GOOD
    	CALL	DAA_SPK
    	CALL	BBBEEP
    	BS	B1,INIT_FLASH_END
INIT_FLASH_GOOD:
	CALL	DAA_SPK
	CALL	INITBEEP
INIT_FLASH_END: 
;---------------first function
	CALL	CLR_FUNC	;ÏÈ¿Õ
    	LACL	LOCAL_PRO
     	CALL	PUSH_FUNC
	
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
	
	LACL	200
	CALL	DELAY

	CALL    BEEP_STOP	;// beep stop

	RET
;-------------------------------------------------------------------------------
;	Function : BEEP_START
;	
;	The general function for beep generation
;	Input  : BUF1=the beep frequency
;-------------------------------------------------------------------------------
BEEP_START:
        LACL    CBEEP_COMMAND            	;// beep start
        CALL    DAM_BIOSFUNC

        RET

;-------------------------------------------------------------------------------
;	Function : BEEP_STOP
;	
;	The general function for beep generation
;-------------------------------------------------------------------------------
BEEP_STOP:
        LACL    0X4400            	;// beep stop
        CALL    DAM_BIOSFUNC

        RET
;-------------------------------------------------------------------------------
DELAY:
	SAH	TMR_DELAY
DELAY_LOOP:
	LAC     TMR_DELAY
        BZ      SGN,DELAY_LOOP
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
